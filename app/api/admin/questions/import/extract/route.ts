// =====================================================================
// POST /api/admin/questions/import/extract
//
// Reçoit un PDF en multipart/form-data + métadonnées (formation_slug,
// expected_type, module_id?), extrait le texte, le parse en
// DraftQuestion[], crée une ligne d'audit dans question_imports.
//
// Réponse :
//   {
//     import_id: uuid,
//     raw_text: string,            // texte brut (éditable côté UI)
//     questions: DraftQuestion[],  // découpage heuristique
//     summary: {...}
//   }
//
// L'insert effectif des questions est fait par /api/.../save.
// =====================================================================

import { NextRequest, NextResponse } from "next/server";
import { requireAdmin } from "@/lib/admin-guard";
import { extractPdfText, normalizePdfText } from "@/lib/pdf-extract";
import { parseQuestions } from "@/lib/question-parser";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";
export const maxDuration = 60;

const MAX_BYTES = 12 * 1024 * 1024; // 12 MB

export async function POST(req: NextRequest) {
  try {
    const { supabase, admin } = await requireAdmin();

    const form = await req.formData();
    const file = form.get("file");
    const formationSlug = String(form.get("formation_slug") ?? "");
    const expectedType = String(form.get("expected_type") ?? "mixed");
    const moduleId = (form.get("module_id") as string) || null;
    const notes = (form.get("notes") as string) || null;
    const pastedText = (form.get("pasted_text") as string) || null;

    // Validation
    if (!["qcm", "qr", "mixed", "exam"].includes(expectedType)) {
      return NextResponse.json(
        { error: "expected_type_invalid" },
        { status: 400 },
      );
    }

    let rawText = "";
    let byteLength = 0;
    let fileName = "paste.txt";
    let fileKind: "pdf" | "txt" | "paste" = "paste";

    if (file instanceof File) {
      if (file.size > MAX_BYTES) {
        return NextResponse.json(
          { error: "file_too_large", limit: MAX_BYTES },
          { status: 413 },
        );
      }
      fileName = file.name || "document.pdf";
      byteLength = file.size;

      const buffer = Buffer.from(await file.arrayBuffer());
      if (file.type === "application/pdf" || fileName.toLowerCase().endsWith(".pdf")) {
        const extracted = await extractPdfText(buffer);
        rawText = extracted.text;
        fileKind = "pdf";
      } else {
        rawText = buffer.toString("utf-8");
        fileKind = "txt";
      }
    } else if (pastedText) {
      rawText = pastedText;
      fileKind = "paste";
      fileName = "paste-" + new Date().toISOString().slice(0, 16) + ".txt";
      byteLength = pastedText.length;
    } else {
      return NextResponse.json(
        { error: "no_file_or_text" },
        { status: 400 },
      );
    }

    rawText = normalizePdfText(rawText);

    if (rawText.trim().length < 30) {
      return NextResponse.json(
        {
          error: "empty_extraction",
          message:
            "Le PDF ne contient pas (ou peu) de texte sélectionnable. Si c'est un PDF scanné, copiez-collez le contenu dans le champ Texte brut.",
        },
        { status: 422 },
      );
    }

    // Résout formation_id
    let formationId: string | null = null;
    if (formationSlug) {
      const { data: f } = await supabase
        .from("formations")
        .select("id")
        .eq("slug", formationSlug)
        .single();
      formationId = f?.id ?? null;
    }

    // Parse heuristique
    const parsed = parseQuestions(rawText);

    // Crée une ligne d'audit (status = 'parsed', pas encore inséré)
    const { data: importRow, error: importErr } = await supabase
      .from("question_imports")
      .insert({
        file_name: fileName,
        file_size_bytes: byteLength,
        file_kind: fileKind,
        formation_id: formationId,
        module_id: moduleId,
        expected_type: expectedType,
        status: "parsed",
        questions_count: parsed.questions.length,
        raw_text: rawText,
        notes,
        created_by: admin.id,
      })
      .select("id")
      .single();

    if (importErr) {
      return NextResponse.json(
        { error: importErr.message },
        { status: 500 },
      );
    }

    return NextResponse.json({
      import_id: importRow.id,
      raw_text: rawText,
      questions: parsed.questions,
      summary: parsed.summary,
    });
  } catch (e: any) {
    return NextResponse.json(
      { error: e?.message ?? "unknown_error" },
      { status: 500 },
    );
  }
}
