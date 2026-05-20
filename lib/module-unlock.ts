import "server-only";
import type { SupabaseClient } from "@supabase/supabase-js";
import type { Tables } from "@/lib/database.types";

// Formes typées (Pick sur le schéma réel — cf. lib/database.types.ts) des
// lignes lues ici. Documente + vérifie les colonnes contre la DB.
type ModuleRow = Pick<Tables<"modules">, "id" | "order">;
type LessonRow = Pick<Tables<"lessons">, "id" | "module_id">;
type LessonProgressRow = Pick<Tables<"lesson_progress">, "lesson_id" | "completed">;
type LessonViewRow = Pick<Tables<"lesson_views">, "lesson_id" | "completed">;

/**
 * Calcule l'ensemble des modules "débloqués" pour un stagiaire, selon
 * la règle : un module est accessible si TOUTES les leçons du module
 * précédent (dans l'ordre, au sein de sa formation) sont complétées.
 * Le 1er module de chaque formation est toujours débloqué.
 *
 * Utilisé pour verrouiller les exercices / examens blancs des modules
 * non encore atteints (cohérence avec le verrouillage de /modules).
 *
 * Un module sans leçon est considéré "complet" (rien à faire) pour ne
 * pas bloquer indéfiniment la suite.
 *
 * @param reader        client Supabase (session)
 * @param userId        id du stagiaire
 * @param moduleIds     modules autorisés (rattachés à ses formations)
 * @param moduleToFormation  map module_id → formation_slug
 * @returns Set des module_id débloqués
 */
export async function computeUnlockedModuleIds(
  reader: SupabaseClient,
  userId: string,
  moduleIds: string[],
  moduleToFormation: Map<string, string>,
): Promise<Set<string>> {
  const unlocked = new Set<string>();
  if (moduleIds.length === 0) return unlocked;

  // Une leçon est "terminée" si elle est marquée completed dans
  // lesson_progress (bouton "Marquer terminé") OU dans lesson_views
  // (tracking implicite). On fait l'UNION pour être STRICTEMENT aligné
  // sur le calcul de /modules (sinon décalage : verrouillé ici mais
  // débloqué là-bas, ou l'inverse).
  const [
    { data: modulesData },
    { data: lessonsData },
    { data: progressData },
    { data: viewsData },
  ] = await Promise.all([
    reader.from("modules").select('id, "order"').in("id", moduleIds),
    reader.from("lessons").select("id, module_id").in("module_id", moduleIds),
    reader
      .from("lesson_progress")
      .select("lesson_id, completed")
      .eq("user_id", userId)
      .eq("completed", true),
    reader
      .from("lesson_views")
      .select("lesson_id, completed")
      .eq("user_id", userId)
      .eq("completed", true),
  ]);

  // Leçons par module
  const lessonsByModule = new Map<string, string[]>();
  for (const l of (lessonsData ?? []) as LessonRow[]) {
    const arr = lessonsByModule.get(l.module_id) ?? [];
    arr.push(l.id);
    lessonsByModule.set(l.module_id, arr);
  }
  const completedLessons = new Set<string>();
  for (const p of (progressData ?? []) as LessonProgressRow[]) {
    if (p.completed) completedLessons.add(p.lesson_id);
  }
  for (const v of (viewsData ?? []) as LessonViewRow[]) {
    if (v.completed) completedLessons.add(v.lesson_id);
  }
  const moduleComplete = (mid: string): boolean => {
    const ls = lessonsByModule.get(mid) ?? [];
    if (ls.length === 0) return true; // module sans leçon → ne bloque pas
    return ls.every((id) => completedLessons.has(id));
  };

  // Regroupe les modules par formation, trie par "order"
  const byFormation = new Map<string, Array<{ id: string; order: number }>>();
  for (const m of (modulesData ?? []) as ModuleRow[]) {
    const fslug = moduleToFormation.get(m.id);
    if (!fslug) continue;
    const arr = byFormation.get(fslug) ?? [];
    arr.push({ id: m.id, order: m.order ?? 0 });
    byFormation.set(fslug, arr);
  }

  // Déverrouillage cumulatif : un module est débloqué si tous les
  // précédents (dans sa formation) ont leurs leçons complètes.
  for (const mods of byFormation.values()) {
    mods.sort((a, b) => a.order - b.order);
    let prevComplete = true;
    for (const m of mods) {
      if (prevComplete) unlocked.add(m.id);
      prevComplete = prevComplete && moduleComplete(m.id);
    }
  }

  return unlocked;
}
