"use server";
import { revalidatePath } from "next/cache";
import { requireAdmin, auditLog, validate } from "@/lib/admin-guard";
import { z } from "zod";

// ─── Schémas ──────────────────────────────────────────────────────────

const choiceSchema = z.object({
  label: z.string().trim().min(1, "Choix vide").max(500),
  is_correct: z.boolean().default(false),
});

const createQcmSchema = z.object({
  formation_slug: z.string().trim().min(1, "Formation requise"),
  module_id: z.string().uuid().optional().nullable(),
  statement: z.string().trim().min(3, "Énoncé trop court").max(5000),
  choices: z
    .array(choiceSchema)
    .min(2, "Au moins 2 choix")
    .max(8, "Maximum 8 choix"),
  difficulty: z.enum(["facile", "moyen", "difficile"]).default("moyen"),
  max_score: z.number().min(0.5).max(20).default(1),
  tags: z.array(z.string().trim().max(60)).default([]),
  explanation: z.string().trim().max(2000).optional().nullable(),
  active: z.boolean().default(true),
});

const createQrSchema = z.object({
  formation_slug: z.string().trim().min(1, "Formation requise"),
  module_id: z.string().uuid().optional().nullable(),
  statement: z.string().trim().min(3, "Énoncé trop court").max(5000),
  expected_answer: z.string().trim().min(3, "Réponse modèle requise").max(5000),
  scoring_grid: z.string().trim().max(2000).optional().nullable(),
  difficulty: z.enum(["facile", "moyen", "difficile"]).default("moyen"),
  max_score: z.number().min(0.5).max(20).default(2),
  tags: z.array(z.string().trim().max(60)).default([]),
  explanation: z.string().trim().max(2000).optional().nullable(),
  active: z.boolean().default(true),
});

type CreateResult =
  | { ok: true; questionId: string }
  | { ok: false; error: string };

// ─── Helpers ──────────────────────────────────────────────────────────

async function resolveFormationId(
  sb: any,
  slug: string
): Promise<string | null> {
  const { data } = await sb
    .from("formations")
    .select("id")
    .eq("slug", slug)
    .maybeSingle();
  return data?.id ?? null;
}

// ─── Création QCM ─────────────────────────────────────────────────────

export async function createQcmQuestion(raw: unknown): Promise<CreateResult> {
  let data: z.infer<typeof createQcmSchema>;
  try {
    const { service } = await requireAdmin();
    data = validate(createQcmSchema, raw);

    // Vérification métier : au moins 1 choix marqué correct
    if (!data.choices.some((c) => c.is_correct)) {
      return { ok: false, error: "Au moins une bonne réponse doit être cochée" };
    }

    const formationId = await resolveFormationId(service, data.formation_slug);
    if (!formationId) {
      return { ok: false, error: `Formation "${data.formation_slug}" introuvable` };
    }

    // Ajoute un id stable à chaque choix (utile pour quiz_attempts ensuite)
    const choicesWithId = data.choices.map((c, idx) => ({
      id: `c${idx + 1}`,
      label: c.label,
      is_correct: c.is_correct,
    }));

    const { data: inserted, error } = await service
      .from("question_bank")
      .insert({
        formation_id: formationId,
        module_id: data.module_id || null,
        type: "qcm",
        statement: data.statement,
        choices: choicesWithId,
        difficulty: data.difficulty,
        max_score: data.max_score,
        tags: data.tags,
        explanation: data.explanation || null,
        active: data.active,
        source_ref: "manual",
      })
      .select("id")
      .single();
    if (error) return { ok: false, error: error.message };

    try {
      await auditLog("create_qcm_question", "question_bank", inserted.id, {
        formation_slug: data.formation_slug,
        active: data.active,
      });
    } catch {
      /* best-effort */
    }
    revalidatePath("/admin/banque-questions");
    revalidatePath("/admin/banque-questions/liste");
    return { ok: true, questionId: inserted.id };
  } catch (e: any) {
    return { ok: false, error: e?.message ?? "Erreur inattendue" };
  }
}

// ─── Création QR ──────────────────────────────────────────────────────

export async function createQrQuestion(raw: unknown): Promise<CreateResult> {
  let data: z.infer<typeof createQrSchema>;
  try {
    const { service } = await requireAdmin();
    data = validate(createQrSchema, raw);

    const formationId = await resolveFormationId(service, data.formation_slug);
    if (!formationId) {
      return { ok: false, error: `Formation "${data.formation_slug}" introuvable` };
    }

    const { data: inserted, error } = await service
      .from("question_bank")
      .insert({
        formation_id: formationId,
        module_id: data.module_id || null,
        type: "qr",
        statement: data.statement,
        expected_answer: data.expected_answer,
        scoring_grid: data.scoring_grid || null,
        difficulty: data.difficulty,
        max_score: data.max_score,
        tags: data.tags,
        explanation: data.explanation || null,
        active: data.active,
        source_ref: "manual",
      })
      .select("id")
      .single();
    if (error) return { ok: false, error: error.message };

    try {
      await auditLog("create_qr_question", "question_bank", inserted.id, {
        formation_slug: data.formation_slug,
        active: data.active,
      });
    } catch {
      /* best-effort */
    }
    revalidatePath("/admin/banque-questions");
    revalidatePath("/admin/banque-questions/liste");
    return { ok: true, questionId: inserted.id };
  } catch (e: any) {
    return { ok: false, error: e?.message ?? "Erreur inattendue" };
  }
}
