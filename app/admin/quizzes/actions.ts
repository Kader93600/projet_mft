"use server";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { requireAdmin, validate, auditLog } from "@/lib/admin-guard";
import {
  quizCreateSchema,
  quizUpdateSchema,
  questionCreateSchema,
  questionUpdateSchema,
  choicesArraySchema,
  uuid,
} from "@/lib/validations";

// ---------- QUIZZES ----------
export async function createQuiz(raw: unknown) {
  const { supabase } = await requireAdmin();
  const data = validate(quizCreateSchema, raw);
  const { data: created, error } = await supabase
    .from("quizzes")
    .insert(data)
    .select()
    .single();
  if (error) throw new Error(error.message);
  await auditLog("create_quiz", "quiz", created.id, { title: data.title });
  revalidatePath("/admin/quizzes");
  redirect(`/admin/quizzes/${created.id}`);
}

export async function updateQuiz(id: string, raw: unknown) {
  const { supabase } = await requireAdmin();
  validate(uuid, id);
  const patch = validate(quizUpdateSchema, raw);
  const { error } = await supabase.from("quizzes").update(patch).eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("update_quiz", "quiz", id);
  revalidatePath("/admin/quizzes");
  revalidatePath(`/admin/quizzes/${id}`);
  return { ok: true };
}

export async function deleteQuiz(id: string) {
  const { supabase } = await requireAdmin();
  validate(uuid, id);
  const { error } = await supabase.from("quizzes").delete().eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("delete_quiz", "quiz", id);
  revalidatePath("/admin/quizzes");
  return { ok: true };
}

// ---------- QUESTIONS ----------
export async function createQuestion(raw: unknown) {
  const { supabase } = await requireAdmin();
  const data = validate(questionCreateSchema, raw);
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
  const { supabase } = await requireAdmin();
  validate(uuid, id);
  validate(uuid, quizId);
  const patch = validate(questionUpdateSchema, raw);
  const { error } = await supabase.from("questions").update(patch).eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("update_question", "question", id);
  revalidatePath(`/admin/quizzes/${quizId}`);
  return { ok: true };
}

export async function deleteQuestion(id: string, quizId: string) {
  const { supabase } = await requireAdmin();
  validate(uuid, id);
  validate(uuid, quizId);
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
  const { supabase } = await requireAdmin();
  validate(uuid, questionId);
  validate(uuid, quizId);
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
