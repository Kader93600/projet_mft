// =====================================================================
// Calcul de progression du stagiaire — module par module.
//
// Dépend de :
//   - lesson_views (table tracking.sql) : `completed`, `last_ping_at`
//   - quiz_attempts (schema.sql) : `passed`, `percentage`, `started_at`
//   - lessons + quizzes (catalogue) : pour connaître les totaux
//
// Types de modules : 'course' | 'exam' | 'final'
//   - 'final' regroupe le MSP final + le dossier pro / banque entretien
//   - 'exam' est un examen blanc synthétique de bloc
//   - 'course' est tout le reste (modules pédagogiques classiques)
// =====================================================================

export type ModuleKind = "course" | "exam" | "final";

export type ModuleState =
  | "done"
  | "in-progress"
  | "not-started"
  | "locked";

export interface ModuleProgress {
  /** Slug du module. */
  slug: string;
  /** ID du module. */
  id: string;
  /** Type dérivé du slug. */
  kind: ModuleKind;
  /** Numéro d'ordre (display_order de formation_modules). */
  order: number;
  /** Nb de leçons total. */
  lessonsTotal: number;
  /** Nb de leçons complétées. */
  lessonsDone: number;
  /** Nb de quizzes total (entraînement + examen). */
  quizzesTotal: number;
  /** Nb de quizzes réussis (passed = true). */
  quizzesPassed: number;
  /** Pourcentage 0-100. */
  percent: number;
  /** État résultant pour l'affichage. */
  state: ModuleState;
  /** Dernière interaction (lesson_view ou quiz_attempt). */
  lastTouchedAt: string | null;
}

// ---------------------------------------------------------------------
// 1. Détection du type de module via slug
// ---------------------------------------------------------------------

/**
 * Distingue cours / examen blanc synthétique / livrable final
 * (MSP, dossier pro, banque entretien). La logique repose sur des
 * conventions de slug GOTRM mais reste tolérante pour les autres
 * formations qui n'ont pas encore d'examens synthèse.
 */
export function getModuleKind(slug: string): ModuleKind {
  if (slug.includes("msp-final") || slug.includes("dossier-pro")) {
    return "final";
  }
  if (slug.includes("examen-blanc-synthese")) {
    return "exam";
  }
  return "course";
}

// ---------------------------------------------------------------------
// 2. Calcul de l'état d'un module
// ---------------------------------------------------------------------

/**
 * Un module est `done` si toutes ses leçons sont complétées ET
 * (s'il a au moins 1 examen) si son examen blanc est passé.
 *
 * `in-progress` si au moins 1 leçon ouverte ou 1 quiz tenté mais pas
 * encore terminé.
 *
 * `not-started` si rien de touché.
 *
 * Le verrouillage `locked` est appliqué dans une seconde passe par
 * `applyLinearLocking` (voir plus bas), car il dépend de l'ordre.
 */
export function computeModuleState(args: {
  lessonsTotal: number;
  lessonsDone: number;
  quizzesTotal: number;
  quizzesPassed: number;
  hasAnyAttempt: boolean;
}): Exclude<ModuleState, "locked"> {
  const { lessonsTotal, lessonsDone, quizzesTotal, quizzesPassed, hasAnyAttempt } =
    args;

  if (lessonsTotal === 0 && quizzesTotal === 0) {
    // Module vide (édge case admin) : on neutralise.
    return "not-started";
  }

  const allLessonsDone = lessonsTotal === 0 || lessonsDone >= lessonsTotal;
  const allQuizzesPassed = quizzesTotal === 0 || quizzesPassed >= quizzesTotal;

  if (allLessonsDone && allQuizzesPassed && hasAnyAttempt) {
    return "done";
  }

  if (lessonsDone > 0 || quizzesPassed > 0 || hasAnyAttempt) {
    return "in-progress";
  }

  return "not-started";
}

/**
 * Pourcentage 0-100 d'avancement, calculé en pondérant
 * lessons (50 %) et quizzes (50 %) si les deux existent,
 * sinon 100 % sur la dimension présente.
 */
export function computeModulePercent(args: {
  lessonsTotal: number;
  lessonsDone: number;
  quizzesTotal: number;
  quizzesPassed: number;
}): number {
  const { lessonsTotal, lessonsDone, quizzesTotal, quizzesPassed } = args;
  const hasL = lessonsTotal > 0;
  const hasQ = quizzesTotal > 0;
  if (!hasL && !hasQ) return 0;
  if (hasL && !hasQ) return Math.round((lessonsDone / lessonsTotal) * 100);
  if (hasQ && !hasL) return Math.round((quizzesPassed / quizzesTotal) * 100);
  const lp = lessonsDone / lessonsTotal;
  const qp = quizzesPassed / quizzesTotal;
  return Math.round((lp * 0.5 + qp * 0.5) * 100);
}

// ---------------------------------------------------------------------
// 3. Verrouillage linéaire
// ---------------------------------------------------------------------

/**
 * Applique un parcours linéaire bloquant : un module N est déverrouillé
 * si le module N-1 est `done`. Premier module toujours déverrouillé.
 *
 * Les modules `exam` et `final` (synthèse de bloc, MSP, dossier pro)
 * sont traités à part : ils sont déverrouillés quand TOUS les modules
 * `course` qui les précèdent dans l'ordre sont done.
 *
 * Mutation pure : retourne une nouvelle liste, l'entrée est immuable.
 */
export function applyLinearLocking(modules: ModuleProgress[]): ModuleProgress[] {
  const sorted = [...modules].sort((a, b) => a.order - b.order);
  const out: ModuleProgress[] = [];

  // Premier passage : on calcule le verrouillage par type
  const courses = sorted.filter((m) => m.kind === "course");
  let firstUnlockedIdx = 0; // tous les courses sont déverrouillés jusqu'à
  // ce qu'on trouve le premier non-done — celui-là reste déverrouillé.
  for (let i = 0; i < courses.length; i++) {
    if (courses[i].state !== "done") {
      firstUnlockedIdx = i;
      break;
    }
    firstUnlockedIdx = i + 1;
  }

  const lockedCourseIds = new Set(
    courses.slice(firstUnlockedIdx + 1).map((m) => m.id)
  );

  // Les exams et finals sont déverrouillés quand TOUS les courses sont done
  const allCoursesDone =
    courses.length > 0 && courses.every((m) => m.state === "done");

  for (const m of sorted) {
    if (m.kind === "course" && lockedCourseIds.has(m.id)) {
      out.push({ ...m, state: "locked" });
    } else if ((m.kind === "exam" || m.kind === "final") && !allCoursesDone) {
      out.push({ ...m, state: "locked" });
    } else {
      out.push(m);
    }
  }

  return out;
}

// ---------------------------------------------------------------------
// 4. Trouver le "prochain module à faire"
// ---------------------------------------------------------------------

/**
 * Retourne le module à proposer au stagiaire sur la ContinueCard :
 *
 *  1. Le module `in-progress` le plus récemment touché (priorité).
 *  2. À défaut, le premier module `not-started` (verrouillé non compris).
 *  3. À défaut (tout est `done`), null.
 */
export function pickNextModule(
  modules: ModuleProgress[]
): ModuleProgress | null {
  const inProgress = modules
    .filter((m) => m.state === "in-progress")
    .sort((a, b) => {
      const aDate = a.lastTouchedAt ? new Date(a.lastTouchedAt).getTime() : 0;
      const bDate = b.lastTouchedAt ? new Date(b.lastTouchedAt).getTime() : 0;
      return bDate - aDate;
    });
  if (inProgress.length > 0) return inProgress[0];

  const notStarted = modules
    .filter((m) => m.state === "not-started")
    .sort((a, b) => a.order - b.order);
  if (notStarted.length > 0) return notStarted[0];

  return null;
}
