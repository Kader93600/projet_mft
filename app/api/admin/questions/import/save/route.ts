// =====================================================================
// POST /api/admin/questions/import/save
//
// Reçoit un payload JSON :
//   {
//     import_id: uuid,
//     formation_id: uuid,
//     module_id?: uuid,
//     questions: [
//       {
//         type: 'qcm' | 'qr',
//         statement: string,
//         choices?: [{ letter, label, is_correct }],
//         expected_answer?: string,
//         scoring_grid?: string,
//         max_score: number,
//         difficulty: 'facile' | 'moyen' | 'difficile',
//         tags: string[],
//         explanation?: string,
//       },
//       ...
//     ]
//   }
//
// Effectue un BULK insert dans question_bank, marque l'import comme
// 'inserted', renvoie les IDs créés.
// =====================================================================

import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { requireAdmin } from "@/lib/admin-guard";
import { formatZodError } from "@/lib/validations";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";
export const maxDuration = 60;

const choiceSchema = z.object({
  letter: z.string().min(1).max(2),
  label: z.string().min(1).max(2000),
  is_correct: z.boolean(),
});

const questionSchema = z.object({
  type: z.enum(["qcm", "qr"]),
  statement: z.string().min(5).max(4000),
  choices: z.array(choiceSchema).optional().nullable(),
  expected_answer: z.string().max(8000).optional().nullable(),
  scoring_grid: z.string().max(4000).optional().nullable(),
  max_score: z.number().min(0).max(100),
  difficulty: z.enum(["facile", "moyen", "difficile"]),
  tags: z.array(z.string().trim().max(40)).max(20),
  explanation: z.string().max(4000).optional().nullable(),
  annex_pages: z.array(z.number().int().min(1).max(2000)).max(20).optional().nullable(),
  annex_labels: z.array(z.string().trim().max(160)).max(20).optional().nullable(),
});

const payloadSchema = z.object({
  import_id: z.string().uuid(),
  formation_id: z.string().uuid().nullable().optional(),
  module_id: z.string().uuid().nullable().optional(),
  lesson_id: z.string().uuid().nullable().optional(),
  questions: z.array(questionSchema).min(1).max(500),
  // Phase 6.3 : workflow "import → quiz prêt à jouer"
  /** Si true, les questions sont actives dès l'insert (sinon active=false). */
  activate_immediately: z.boolean().optional(),
  /** Si true, crée aussi un quiz contenant toutes les questions importées. */
  create_quiz: z.boolean().optional(),
  /** Titre du quiz (requis si create_quiz=true). */
  quiz_title: z.string().trim().min(3).max(120).optional(),
  /** Type du quiz (par défaut entraînement). */
  quiz_type: z.enum(["entrainement", "examen"]).optional(),
  /** Description optionnelle du quiz. */
  quiz_description: z.string().trim().max(2000).optional(),
});

export async function POST(req: NextRequest) {
  try {
    const { supabase, admin } = await requireAdmin();

    const body = await req.json();
    const parsed = payloadSchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json(
        { error: formatZodError(parsed.error) },
        { status: 400 },
      );
    }
    const {
      import_id,
      formation_id,
      module_id,
      lesson_id,
      questions,
      activate_immediately,
      create_quiz,
      quiz_title,
      quiz_type,
      quiz_description,
    } = parsed.data;

    // Verifie que l'import existe et appartient au current admin (ou
    // est libre d'être complété — pas de check stricte sur created_by
    // car un admin peut reprendre l'import d'un collègue).
    const { data: importRow, error: impErr } = await supabase
      .from("question_imports")
      .select("id, file_name, status, formation_id")
      .eq("id", import_id)
      .single();
    if (impErr || !importRow) {
      return NextResponse.json(
        { error: "import_not_found" },
        { status: 404 },
      );
    }
    if (importRow.status === "inserted") {
      return NextResponse.json(
        { error: "import_already_inserted" },
        { status: 409 },
      );
    }

    // Prépare les rows pour le bulk insert
    const sourceRef = `import:${import_id}#${importRow.file_name}`;
    const rows = questions.map((q) => ({
      formation_id: formation_id ?? importRow.formation_id ?? null,
      module_id: module_id ?? null,
      lesson_id: lesson_id ?? null,
      type: q.type,
      statement: q.statement,
      choices:
        q.type === "qcm" && q.choices
          ? q.choices.map((c) => ({
              id: c.letter,
              label: c.label,
              is_correct: c.is_correct,
            }))
          : null,
      expected_answer: q.expected_answer ?? null,
      scoring_grid: q.scoring_grid ?? null,
      max_score: q.max_score,
      difficulty: q.difficulty,
      tags: q.tags,
      explanation: q.explanation ?? null,
      source_ref: sourceRef,
      import_id,
      created_by: admin.id,
      active: activate_immediately === true,
      annex_pages: q.annex_pages ?? [],
      annex_labels: q.annex_labels ?? [],
    }));

    const { data: inserted, error: insErr } = await supabase
      .from("question_bank")
      .insert(rows)
      .select("id, type");

    if (insErr) {
      // Update import en 'failed'
      await supabase
        .from("question_imports")
        .update({
          status: "failed",
          errors_count: rows.length,
          completed_at: new Date().toISOString(),
        })
        .eq("id", import_id);

      return NextResponse.json({ error: insErr.message }, { status: 500 });
    }

    // ── Création optionnelle d'un quiz contenant ces questions ─────────
    let createdQuizId: string | null = null;
    let createdQuizLinks = 0;
    if (create_quiz && inserted && inserted.length > 0) {
      if (!quiz_title) {
        return NextResponse.json(
          { error: "quiz_title_required" },
          { status: 400 },
        );
      }
      const { data: quizRow, error: quizErr } = await supabase
        .from("quizzes")
        .insert({
          module_id: module_id ?? null,
          title: quiz_title,
          description: quiz_description ?? null,
          type: quiz_type ?? "entrainement",
          // 70 % par défaut, alignement avec le seed
          pass_threshold: 70,
        })
        .select("id")
        .single();

      if (quizErr) {
        return NextResponse.json(
          {
            error: "quiz_create_failed",
            details: quizErr.message,
            inserted: inserted.length,
          },
          { status: 500 },
        );
      }
      createdQuizId = quizRow.id;

      // Bulk insert dans quiz_question_bank (ordre = ordre d'insertion)
      const links = inserted.map((q: any, i: number) => ({
        quiz_id: createdQuizId,
        question_id: q.id,
        display_order: (i + 1) * 10,
      }));
      const { error: linkErr, count } = await supabase
        .from("quiz_question_bank")
        .insert(links, { count: "exact" });
      if (linkErr) {
        // eslint-disable-next-line no-console
        console.error("[import] lien quiz_question_bank échoué :", linkErr.message);
      } else {
        createdQuizLinks = count ?? links.length;
      }
    }

    // Update import en 'inserted'
    await supabase
      .from("question_imports")
      .update({
        status: "inserted",
        questions_count: inserted?.length ?? 0,
        completed_at: new Date().toISOString(),
      })
      .eq("id", import_id);

    return NextResponse.json({
      ok: true,
      inserted: inserted?.length ?? 0,
      ids: inserted?.map((r: any) => r.id) ?? [],
      activated: activate_immediately === true,
      quiz_id: createdQuizId,
      quiz_links: createdQuizLinks,
    });
  } catch (e: any) {
    return NextResponse.json(
      { error: e?.message ?? "unknown_error" },
      { status: 500 },
    );
  }
}
