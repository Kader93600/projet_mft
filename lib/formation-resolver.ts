// =====================================================================
// Résolveur server-side : trouve la formation associée à n'importe
// quelle ressource (quiz, module, leçon, tentative, copie QR).
//
// Utilisé par :
//   - Pages /quiz/[id] et /quiz/results/[id]
//   - Pages /modules/[slug]/[lessonSlug]
//   - Pages /formateur/corrections/[id]
//   - Composants en-tête / breadcrumb
// =====================================================================

import { createClient } from "./supabase/server";

/** Résout la formation principale liée à un quiz (via formation_quizzes). */
export async function resolveFormationFromQuiz(
  quizId: string
): Promise<string | null> {
  const supabase = createClient();
  const { data } = await supabase
    .from("formation_quizzes")
    .select("formation:formations(slug)")
    .eq("quiz_id", quizId)
    .limit(1)
    .maybeSingle();
  return (data as any)?.formation?.slug ?? null;
}

/** Résout la formation d'un module (via formation_modules). */
export async function resolveFormationFromModule(
  moduleId: string
): Promise<string | null> {
  const supabase = createClient();
  const { data } = await supabase
    .from("formation_modules")
    .select("formation:formations(slug)")
    .eq("module_id", moduleId)
    .limit(1)
    .maybeSingle();
  return (data as any)?.formation?.slug ?? null;
}

/** Résout la formation depuis une leçon (via le module parent). */
export async function resolveFormationFromLesson(
  lessonId: string
): Promise<string | null> {
  const supabase = createClient();
  const { data: lesson } = await supabase
    .from("lessons")
    .select("module_id")
    .eq("id", lessonId)
    .maybeSingle();
  if (!lesson?.module_id) return null;
  return resolveFormationFromModule(lesson.module_id);
}

/** Résout la formation d'une tentative (via le quiz). */
export async function resolveFormationFromAttempt(
  attemptId: string
): Promise<string | null> {
  const supabase = createClient();
  const { data: attempt } = await supabase
    .from("quiz_attempts")
    .select("quiz_id")
    .eq("id", attemptId)
    .maybeSingle();
  if (!attempt?.quiz_id) return null;
  return resolveFormationFromQuiz(attempt.quiz_id);
}
