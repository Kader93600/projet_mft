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
//
// Modes de déverrouillage (révision client 2026-05) :
//   - 'strict'   (défaut) : module suivant débloqué uniquement si TOUS
//                           les quiz du courant sont RÉUSSIS (passed=true).
//                           Utilisé pour GOTRM et autres formations.
//   - 'flexible'          : module suivant débloqué dès que TOUTES les
//                           leçons sont faites + TOUS les quiz ESSAYÉS
//                           (même ratés). Score sans importance.
//                           Utilisé pour la formation Capacité ≤ 3,5 t.
// =====================================================================

export type ModuleKind = "course" | "exam" | "final";

export type ModuleState =
  | "done"
  | "in-progress"
  | "not-started"
  | "locked";

/** Mode de déverrouillage par formation. */
export type UnlockMode = "strict" | "flexible";

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
  /**
   * Nb de quizzes essayés (au moins 1 quiz_attempt, peu importe le résultat).
   * Utilisé par le mode 'flexible' pour débloquer la suite même si raté.
   */
  quizzesAttempted: number;
  /** Pourcentage 0-100. */
  percent: number;
  /** État résultant pour l'affichage. */
  state: ModuleState;
  /** Dernière interaction (lesson_view ou quiz_attempt). */
  lastTouchedAt: string | null;
  /**
   * Slug de la formation à laquelle appartient ce module.
   * Optionnel : si absent, le mode 'strict' est appliqué par défaut.
   */
  formationSlug?: string;
}

// ---------------------------------------------------------------------
// 0. Helper — Mode de déverrouillage par formation
// ---------------------------------------------------------------------

/**
 * Liste des formations dont la règle de déverrouillage est 'flexible'
 * (révision client 2026-05) : le module suivant se débloque dès que
 * toutes les leçons sont terminées et tous les quiz essayés, même
 * si le score est insuffisant.
 *
 * Toute autre formation reste en mode 'strict' (déverrouillage uniquement
 * si tous les quiz sont RÉUSSIS).
 */
const FLEXIBLE_UNLOCK_FORMATION_SLUGS: ReadonlySet<string> = new Set([
  "capacite-3-5t",
]);

export function getUnlockMode(formationSlug?: string | null): UnlockMode {
  if (!formationSlug) return "strict";
  return FLEXIBLE_UNLOCK_FORMATION_SLUGS.has(formationSlug)
    ? "flexible"
    : "strict";
}

export function isFlexibleUnlockFormation(
  formationSlug?: string | null
): boolean {
  return getUnlockMode(formationSlug) === "flexible";
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
  // Match tous les examens blancs : "examen-blanc-synthese" (livret CCP),
  // "examen-blanc-final" (CCP1 GOTRM transversal), "capa-examen-blanc-final"
  // (DREAL), etc. Tout slug contenant "examen-blanc" est traité comme exam.
  if (slug.includes("examen-blanc")) {
    return "exam";
  }
  return "course";
}

// ---------------------------------------------------------------------
// 2. Calcul de l'état d'un module
// ---------------------------------------------------------------------

/**
 * Un module est `done` selon le mode de déverrouillage :
 *
 *   - 'strict'   (défaut) : toutes les leçons sont complétées ET tous
 *                           les quiz sont RÉUSSIS (passed = true) et au
 *                           moins une tentative existe.
 *
 *   - 'flexible'          : toutes les leçons sont complétées ET tous
 *                           les quiz ont été ESSAYÉS (au moins 1 tentative
 *                           par quiz, peu importe le score).
 *
 * `in-progress` si au moins 1 leçon ouverte ou 1 quiz tenté mais critères
 * de `done` non atteints.
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
  /** Nb de quizzes essayés (au moins 1 attempt). Utilisé en mode 'flexible'. */
  quizzesAttempted?: number;
  hasAnyAttempt: boolean;
  /** Mode de déverrouillage — défaut 'strict'. */
  unlockMode?: UnlockMode;
}): Exclude<ModuleState, "locked"> {
  const {
    lessonsTotal,
    lessonsDone,
    quizzesTotal,
    quizzesPassed,
    quizzesAttempted = 0,
    hasAnyAttempt,
    unlockMode = "strict",
  } = args;

  if (lessonsTotal === 0 && quizzesTotal === 0) {
    // Module vide (édge case admin) : on neutralise.
    return "not-started";
  }

  const allLessonsDone = lessonsTotal === 0 || lessonsDone >= lessonsTotal;
  const allQuizzesPassed = quizzesTotal === 0 || quizzesPassed >= quizzesTotal;
  const allQuizzesAttempted =
    quizzesTotal === 0 || quizzesAttempted >= quizzesTotal;

  if (unlockMode === "flexible") {
    // Capacité ≤ 3,5 t & co : "done" si tout essayé, score sans importance.
    if (allLessonsDone && allQuizzesAttempted) {
      return "done";
    }
  } else {
    // Mode strict (défaut) : "done" requiert tout réussi.
    if (allLessonsDone && allQuizzesPassed && hasAnyAttempt) {
      return "done";
    }
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
 *
 * En mode 'flexible', on pondère sur `quizzesAttempted` plutôt que
 * `quizzesPassed` (cohérent avec la règle de déverrouillage : essayer
 * suffit). Sinon mode strict = passed.
 */
export function computeModulePercent(args: {
  lessonsTotal: number;
  lessonsDone: number;
  quizzesTotal: number;
  quizzesPassed: number;
  quizzesAttempted?: number;
  unlockMode?: UnlockMode;
}): number {
  const {
    lessonsTotal,
    lessonsDone,
    quizzesTotal,
    quizzesPassed,
    quizzesAttempted = 0,
    unlockMode = "strict",
  } = args;
  const hasL = lessonsTotal > 0;
  const hasQ = quizzesTotal > 0;
  if (!hasL && !hasQ) return 0;

  const quizzesEffective =
    unlockMode === "flexible" ? quizzesAttempted : quizzesPassed;

  if (hasL && !hasQ) return Math.round((lessonsDone / lessonsTotal) * 100);
  if (hasQ && !hasL) return Math.round((quizzesEffective / quizzesTotal) * 100);
  const lp = lessonsDone / lessonsTotal;
  const qp = quizzesEffective / quizzesTotal;
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
 * La logique de déverrouillage (strict vs flexible) est portée par
 * `computeModuleState` qui produit le bon `state` selon `unlockMode`.
 * Donc cette fonction reste agnostique du mode — elle se base sur
 * `state === 'done'`.
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
