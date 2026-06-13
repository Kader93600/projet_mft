"use server";

import { requireAdmin, auditLog } from "@/lib/admin-guard";
import { ask } from "@/lib/tutor/claude";
import {
  buildQuestionGenSystem,
  buildQuestionGenUserMessage,
  parseGeneratedQuestions,
} from "@/lib/question-gen";
import { revalidatePath } from "next/cache";

/**
 * Génère des QCM (brouillons) à partir du contenu d'une leçon, via Claude.
 * Les questions sont insérées en `active=false` dans question_bank →
 * elles passent obligatoirement par la validation humaine
 * (/admin/banque-questions/validation) avant d'être utilisables.
 */
export async function generateQuestionsForLesson(
  lessonId: string,
  count = 5,
) {
  let service: Awaited<ReturnType<typeof requireAdmin>>["service"];
  let adminId: string;
  try {
    const r = await requireAdmin();
    service = r.service;
    adminId = r.admin.id;
  } catch {
    return { ok: false as const, error: "Accès refusé." };
  }

  if (!process.env.ANTHROPIC_API_KEY) {
    return {
      ok: false as const,
      error: "Clé ANTHROPIC_API_KEY absente côté serveur — génération IA indisponible.",
    };
  }

  const safeCount = Math.min(10, Math.max(1, Math.round(count)));

  // 1) Leçon + contenu
  const { data: lesson } = await service
    .from("lessons")
    .select("id, title, content_md, module_id")
    .eq("id", lessonId)
    .maybeSingle();
  if (!lesson) return { ok: false as const, error: "Leçon introuvable." };
  if (!lesson.content_md || lesson.content_md.trim().length < 100) {
    return {
      ok: false as const,
      error: "Contenu de leçon trop court pour générer des questions fiables.",
    };
  }

  // 2) Formation (contexte + rattachement)
  let formationId: string | null = null;
  let formationTitle: string | null = null;
  if (lesson.module_id) {
    const { data: fm } = await service
      .from("formation_modules")
      .select("formation:formations(id, title)")
      .eq("module_id", lesson.module_id)
      .limit(1)
      .maybeSingle();
    formationId = (fm as any)?.formation?.id ?? null;
    formationTitle = (fm as any)?.formation?.title ?? null;
  }

  // 3) Appel Claude
  let text: string;
  try {
    const res = await ask({
      system: buildQuestionGenSystem({ count: safeCount, formationTitle }),
      messages: [
        {
          role: "user",
          content: buildQuestionGenUserMessage(lesson.title, lesson.content_md),
        },
      ],
      maxTokens: 3500,
      temperature: 0.4,
    });
    text = res.text;
  } catch (e: any) {
    return {
      ok: false as const,
      error: `Appel IA échoué : ${e?.message ?? "erreur inconnue"}`,
    };
  }

  // 4) Parsing + validation (lib pure testée)
  const questions = parseGeneratedQuestions(text);
  if (questions.length === 0) {
    return {
      ok: false as const,
      error: "L'IA n'a renvoyé aucune question exploitable. Réessaie.",
    };
  }

  // 5) Insertion en BROUILLONS (active=false) → validation humaine ensuite.
  //    source_ref UNIQUE par question (contrainte UNIQUE(source_ref)) :
  //    plusieurs questions sont insérées d'un coup et la génération peut
  //    être relancée sur la même leçon → on suffixe un UUID.
  const rows = questions.map((q) => ({
    formation_id: formationId,
    module_id: lesson.module_id ?? null,
    lesson_id: lesson.id,
    type: "qcm",
    statement: q.statement,
    choices: q.choices.map((c, idx) => ({
      id: `c${idx + 1}`,
      label: c.label,
      is_correct: c.is_correct,
    })),
    difficulty: q.difficulty,
    max_score: 1,
    tags: ["ia-generee"],
    explanation: q.explanation || null,
    active: false,
    source_ref: `ai:lesson:${lesson.id}:${crypto.randomUUID()}`,
  }));

  const { error } = await service.from("question_bank").insert(rows);
  if (error) return { ok: false as const, error: error.message };

  try {
    await auditLog("ai_generate_questions", "lesson", lesson.id, {
      count: questions.length,
      by: adminId,
    });
  } catch {
    /* best-effort */
  }

  revalidatePath("/admin/banque-questions/validation");
  return { ok: true as const, count: questions.length };
}
