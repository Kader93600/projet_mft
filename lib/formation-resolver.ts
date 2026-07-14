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

import { cache } from "react";
import { createClient } from "./supabase/server";
import type { Tables } from "./database.types";

/** Ligne renvoyée par `select("formation:formations(slug)")` (embed to-one). */
type FormationSlugEmbed = {
  formation: Pick<Tables<"formations">, "slug"> | null;
};

// Tous les résolveurs sont enveloppés dans `cache()` (React) : la
// mémoïsation est SCOPÉE À LA REQUÊTE (aucun risque de données périmées
// entre requêtes). Cela dédoublonne les appels répétés au sein d'un même
// rendu (ex. en-tête + breadcrumb + page résolvant le même module/quiz).

/** Résout la formation principale liée à un quiz (via formation_quizzes). */
export const resolveFormationFromQuiz = cache(async function (
  quizId: string
): Promise<string | null> {
  const supabase = createClient();
  const { data } = await supabase
    .from("formation_quizzes")
    .select("formation:formations(slug)")
    .eq("quiz_id", quizId)
    .limit(1)
    .maybeSingle();
  return (data as FormationSlugEmbed | null)?.formation?.slug ?? null;
});

/** Résout la formation d'un module (via formation_modules). */
export const resolveFormationFromModule = cache(async function (
  moduleId: string
): Promise<string | null> {
  const supabase = createClient();
  const { data } = await supabase
    .from("formation_modules")
    .select("formation:formations(slug)")
    .eq("module_id", moduleId)
    .limit(1)
    .maybeSingle();
  return (data as FormationSlugEmbed | null)?.formation?.slug ?? null;
});

/** Résout la formation depuis une leçon (via le module parent). */
export const resolveFormationFromLesson = cache(async function (
  lessonId: string
): Promise<string | null> {
  const supabase = createClient();
  const { data: lesson } = await supabase
    .from("lessons")
    .select("module_id")
    .eq("id", lessonId)
    .maybeSingle();
  const lessonRow = lesson as Pick<Tables<"lessons">, "module_id"> | null;
  if (!lessonRow?.module_id) return null;
  return resolveFormationFromModule(lessonRow.module_id);
});

/** Résout la formation d'une tentative (via le quiz). */
export const resolveFormationFromAttempt = cache(async function (
  attemptId: string
): Promise<string | null> {
  const supabase = createClient();
  const { data: attempt } = await supabase
    .from("quiz_attempts")
    .select("quiz_id")
    .eq("id", attemptId)
    .maybeSingle();
  const attemptRow = attempt as Pick<
    Tables<"quiz_attempts">,
    "quiz_id"
  > | null;
  if (!attemptRow?.quiz_id) return null;
  return resolveFormationFromQuiz(attemptRow.quiz_id);
});

/**
 * Résout l'ID UUID de la formation pour un quiz donné.
 * Stratégie en 2 paliers :
 *   1. via formation_quizzes (si seedé)
 *   2. via le module du quiz → formation_modules
 *
 * Utilisé pour pré-remplir quiz_attempts.formation_id côté client
 * (le trigger BD ne suffit pas si profiles.current_formation_id est NULL).
 */
export const resolveFormationIdFromQuiz = cache(async function (
  quizId: string
): Promise<string | null> {
  const supabase = createClient();

  // 1) formation_quizzes (mapping direct quiz↔formation)
  const { data: fq } = await supabase
    .from("formation_quizzes")
    .select("formation_id")
    .eq("quiz_id", quizId)
    .limit(1)
    .maybeSingle();
  const fqRow = fq as Pick<Tables<"formation_quizzes">, "formation_id"> | null;
  if (fqRow?.formation_id) return fqRow.formation_id;

  // 2) Fallback : on remonte au module du quiz puis formation_modules
  const { data: q } = await supabase
    .from("quizzes")
    .select("module_id")
    .eq("id", quizId)
    .maybeSingle();
  const quizRow = q as Pick<Tables<"quizzes">, "module_id"> | null;
  if (!quizRow?.module_id) return null;
  const { data: fm } = await supabase
    .from("formation_modules")
    .select("formation_id")
    .eq("module_id", quizRow.module_id)
    .limit(1)
    .maybeSingle();
  const fmRow = fm as Pick<Tables<"formation_modules">, "formation_id"> | null;
  return fmRow?.formation_id ?? null;
});
