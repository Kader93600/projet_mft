"use server";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import {
  requireAdmin,
  requireStaffOrFormationTrainer,
  validate,
  auditLog,
} from "@/lib/admin-guard";

/**
 * Récupère le slug de la formation actuellement liée à un quiz.
 * Utilisé pour vérifier l'habilitation trainer avant update/delete.
 */
async function getQuizFormationSlug(
  supabase: any,
  quizId: string
): Promise<string | null> {
  const { data } = await supabase
    .from("formation_quizzes")
    .select("formation:formations(slug)")
    .eq("quiz_id", quizId)
    .limit(1)
    .maybeSingle();
  return (data?.formation as any)?.slug ?? null;
}
import {
  quizCreateSchema,
  quizUpdateSchema,
  questionCreateSchema,
  questionUpdateSchema,
  choicesArraySchema,
  uuid,
} from "@/lib/validations";

// Helper interne : récupère l'ID d'une formation par slug.
async function resolveFormationIdQuiz(
  supabase: any,
  slug: string
): Promise<string> {
  const { data, error } = await supabase
    .from("formations")
    .select("id")
    .eq("slug", slug)
    .maybeSingle();
  if (error) throw new Error(error.message);
  if (!data) throw new Error(`Formation "${slug}" introuvable`);
  return data.id;
}

// ---------- QUIZZES ----------
export async function createQuiz(raw: unknown) {
  const data = validate(quizCreateSchema, raw);
  const { supabase } = await requireStaffOrFormationTrainer(data.formation_slug);

  // 1) Vérifier la formation cible AVANT de créer le quiz
  const formationId = await resolveFormationIdQuiz(supabase, data.formation_slug);

  // 2) Créer le quiz (sans formation_slug, pas une colonne)
  const { formation_slug, ...quizData } = data;
  const { data: created, error } = await supabase
    .from("quizzes")
    .insert(quizData)
    .select()
    .single();
  if (error) throw new Error(error.message);

  // 3) Lier formation_quizzes
  const { error: linkErr } = await supabase
    .from("formation_quizzes")
    .insert({ formation_id: formationId, quiz_id: created.id });
  if (linkErr) {
    await supabase.from("quizzes").delete().eq("id", created.id);
    throw new Error(`Lien formation impossible : ${linkErr.message}`);
  }

  await auditLog("create_quiz", "quiz", created.id, {
    title: data.title,
    formation_slug: data.formation_slug,
  });
  revalidatePath("/admin/quizzes");
  redirect(`/admin/quizzes/${created.id}`);
}

export async function updateQuiz(id: string, raw: unknown) {
  validate(uuid, id);
  const patch = validate(quizUpdateSchema, raw);
  const { formation_slug, ...quizPatch } = patch;
  // Gating trainer
  const sbRead = createClient();
  const currentSlug = await getQuizFormationSlug(sbRead, id);
  const slugToCheck = formation_slug || currentSlug || "";
  const { supabase } = await requireStaffOrFormationTrainer(slugToCheck);

  if (Object.keys(quizPatch).length > 0) {
    const { error } = await supabase
      .from("quizzes")
      .update(quizPatch)
      .eq("id", id);
    if (error) throw new Error(error.message);
  }

  // Re-affectation formation
  if (formation_slug) {
    const formationId = await resolveFormationIdQuiz(supabase, formation_slug);
    const { error: delErr } = await supabase
      .from("formation_quizzes")
      .delete()
      .eq("quiz_id", id);
    if (delErr) throw new Error(delErr.message);
    const { error: insErr } = await supabase
      .from("formation_quizzes")
      .insert({ formation_id: formationId, quiz_id: id });
    if (insErr) throw new Error(insErr.message);
  }

  await auditLog(
    "update_quiz",
    "quiz",
    id,
    formation_slug ? { formation_slug } : undefined
  );
  revalidatePath("/admin/quizzes");
  revalidatePath(`/admin/quizzes/${id}`);
  return { ok: true };
}

export async function deleteQuiz(id: string) {
  validate(uuid, id);
  const sbRead = createClient();
  const currentSlug = await getQuizFormationSlug(sbRead, id);
  // Gate de permission (staff OU formateur de la formation du quiz)
  await requireStaffOrFormationTrainer(currentSlug || "");

  // ⚠️ quiz_attempts.quiz_id est en ON DELETE RESTRICT (préservation des
  // preuves d'examen — audit #15) : un DELETE direct du quiz échoue s'il a
  // des tentatives. La suppression depuis l'admin est une action EXPLICITE
  // et confirmée ("supprime aussi toutes les tentatives") → on retire donc
  // d'abord les tentatives (qr_responses cascade dessus), puis le quiz
  // (questions + quiz_question_bank en CASCADE). Service_role car ces
  // tentatives appartiennent à d'autres utilisateurs (RLS sinon bloquante).
  const service = createAdminClient();

  const { error: attErr } = await service
    .from("quiz_attempts")
    .delete()
    .eq("quiz_id", id);
  if (attErr) throw new Error(attErr.message);

  const { error } = await service.from("quizzes").delete().eq("id", id);
  if (error) throw new Error(error.message);

  await auditLog("delete_quiz", "quiz", id);
  revalidatePath("/admin/quizzes");
  return { ok: true };
}

// ---------- QUESTIONS ----------
export async function createQuestion(raw: unknown) {
  const data = validate(questionCreateSchema, raw);
  // Gating via le quiz parent
  const sbRead = createClient();
  const slug = await getQuizFormationSlug(sbRead, data.quiz_id);
  const { supabase } = await requireStaffOrFormationTrainer(slug || "");
  const { data: created, error } = await supabase
    .from("questions")
    .insert(data)
    .select()
    .single();
  if (error) throw new Error(error.message);
  await auditLog("create_question", "question", created.id);
  revalidatePath(`/admin/quizzes/${data.quiz_id}`);
  return created;
}

export async function updateQuestion(id: string, quizId: string, raw: unknown) {
  validate(uuid, id);
  validate(uuid, quizId);
  const patch = validate(questionUpdateSchema, raw);
  const sbRead = createClient();
  const slug = await getQuizFormationSlug(sbRead, quizId);
  const { supabase } = await requireStaffOrFormationTrainer(slug || "");
  const { error } = await supabase.from("questions").update(patch).eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("update_question", "question", id);
  revalidatePath(`/admin/quizzes/${quizId}`);
  return { ok: true };
}

export async function deleteQuestion(id: string, quizId: string) {
  validate(uuid, id);
  validate(uuid, quizId);
  const sbRead = createClient();
  const slug = await getQuizFormationSlug(sbRead, quizId);
  const { supabase } = await requireStaffOrFormationTrainer(slug || "");
  const { error } = await supabase.from("questions").delete().eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("delete_question", "question", id);
  revalidatePath(`/admin/quizzes/${quizId}`);
  return { ok: true };
}

// ---------- CHOICES (replace all for question) ----------
export async function setChoices(
  questionId: string,
  quizId: string,
  choices: { label: string; is_correct: boolean; order: number }[]
) {
  validate(uuid, questionId);
  validate(uuid, quizId);
  const sbRead = createClient();
  const slug = await getQuizFormationSlug(sbRead, quizId);
  const { supabase } = await requireStaffOrFormationTrainer(slug || "");
  const validated = validate(choicesArraySchema, choices);

  const { error: delErr } = await supabase
    .from("choices")
    .delete()
    .eq("question_id", questionId);
  if (delErr) throw new Error(delErr.message);
  const { error } = await supabase.from("choices").insert(
    validated.map((c) => ({
      question_id: questionId,
      label: c.label,
      is_correct: c.is_correct,
      order: c.order,
    }))
  );
  if (error) throw new Error(error.message);
  await auditLog("set_choices", "question", questionId, { count: validated.length });
  revalidatePath(`/admin/quizzes/${quizId}`);
  return { ok: true };
}

// ---------- LIAISONS BANQUE → QUIZ (quiz_question_bank) ----------
//
// Permet d'ajouter / retirer une question de la banque (question_bank)
// d'un quiz existant. Le trigger SQL `tg_quiz_check_manual_grading`
// recalcule automatiquement requires_manual_grading.

export async function attachBankQuestion(
  quizId: string,
  questionId: string,
  displayOrder?: number,
) {
  validate(uuid, quizId);
  validate(uuid, questionId);
  const sbRead = createClient();
  const slug = await getQuizFormationSlug(sbRead, quizId);
  const { supabase } = await requireStaffOrFormationTrainer(slug || "");

  // Si pas d'ordre fourni, place en dernier (max + 10)
  let order = displayOrder;
  if (order == null) {
    const { data: maxRow } = await supabase
      .from("quiz_question_bank")
      .select("display_order")
      .eq("quiz_id", quizId)
      .order("display_order", { ascending: false })
      .limit(1)
      .maybeSingle();
    order = ((maxRow?.display_order as number | undefined) ?? 0) + 10;
  }

  const { error } = await supabase
    .from("quiz_question_bank")
    .insert({ quiz_id: quizId, question_id: questionId, display_order: order });
  if (error) {
    // Ignore les doublons silencieusement (idempotent)
    if (!error.message.toLowerCase().includes("duplicate")) {
      throw new Error(error.message);
    }
  }
  await auditLog("attach_bank_question", "quiz", quizId, { questionId });
  revalidatePath(`/admin/quizzes/${quizId}`);
  return { ok: true };
}

export async function detachBankQuestion(quizId: string, questionId: string) {
  validate(uuid, quizId);
  validate(uuid, questionId);
  const sbRead = createClient();
  const slug = await getQuizFormationSlug(sbRead, quizId);
  const { supabase } = await requireStaffOrFormationTrainer(slug || "");

  const { error } = await supabase
    .from("quiz_question_bank")
    .delete()
    .eq("quiz_id", quizId)
    .eq("question_id", questionId);
  if (error) throw new Error(error.message);
  await auditLog("detach_bank_question", "quiz", quizId, { questionId });
  revalidatePath(`/admin/quizzes/${quizId}`);
  return { ok: true };
}

/**
 * Bulk : attache N questions d'un coup avec leur ordre.
 * Utilisé par le bouton "Tout cocher" du picker.
 */
export async function setBankQuestionsForQuiz(
  quizId: string,
  questionIds: string[],
) {
  validate(uuid, quizId);
  const sbRead = createClient();
  const slug = await getQuizFormationSlug(sbRead, quizId);
  const { supabase } = await requireStaffOrFormationTrainer(slug || "");

  // 1. Purge les liens existants → 2. Re-insère dans l'ordre fourni
  const { error: delErr } = await supabase
    .from("quiz_question_bank")
    .delete()
    .eq("quiz_id", quizId);
  if (delErr) throw new Error(delErr.message);

  if (questionIds.length > 0) {
    const rows = questionIds.map((qid, i) => ({
      quiz_id: quizId,
      question_id: qid,
      display_order: (i + 1) * 10,
    }));
    const { error } = await supabase.from("quiz_question_bank").insert(rows);
    if (error) throw new Error(error.message);
  }
  await auditLog("set_bank_questions", "quiz", quizId, {
    count: questionIds.length,
  });
  revalidatePath(`/admin/quizzes/${quizId}`);
  return { ok: true, count: questionIds.length };
}
