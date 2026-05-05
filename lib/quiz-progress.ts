// =====================================================================
// Calcul de l'état des quiz côté UI — version enrichie.
//
// Reprend la logique du RPC `quiz_attempt_state` (mock_exam.sql) mais
// l'enrichit avec :
//   - best_score : meilleur pourcentage parmi les tentatives passed
//   - best_passed : au moins 1 tentative réussie
//   - last_score / last_passed
//   - last_attempt_id : pour reprendre un quiz en cours
//   - in_progress : tentative démarrée mais non terminée
//
// Calcul 100 % côté JS pour éviter de faire 75 RPC par chargement de la
// page /quiz. Les seules données nécessaires sont les `quiz_attempts`
// du user (1 requête) + la config des `quizzes` (déjà chargée).
// =====================================================================

export type QuizState =
  | "todo" // jamais tenté
  | "passed" // au moins 1 réussite (best_score retenu)
  | "failed" // ≥ 1 tentative finalisée mais aucune réussite
  | "in-progress" // tentative démarrée non finalisée
  | "blocked-attempts" // max_attempts atteint sans réussite
  | "blocked-delay" // retake_delay non écoulé
  | "locked"; // verrouillé par le parcours pédagogique

export interface QuizAttemptRow {
  id: string;
  quiz_id: string;
  percentage: number;
  passed: boolean;
  started_at: string;
  finished_at: string | null;
}

export interface QuizConfig {
  id: string;
  max_attempts: number | null;
  retake_delay_hours: number | null;
}

export interface QuizProgress {
  quiz_id: string;
  state: QuizState;
  attempts_used: number;
  attempts_max: number | null;
  attempts_left: number | null;
  best_score: number | null;
  best_passed: boolean;
  last_score: number | null;
  last_passed: boolean | null;
  last_attempt_id: string | null;
  last_attempt_at: string | null;
  in_progress_attempt_id: string | null;
  next_available_at: string | null;
  /** Raison de blocage le cas échéant. */
  reason: string | null;
}

/**
 * Calcule l'état complet d'un quiz à partir des attempts du user et de
 * la config du quiz.
 *
 * `lockedByCurriculum` : flag externe indiquant que le quiz est verrouillé
 * par le parcours pédagogique (ex : examen blanc bloc dont les modules
 * de cours ne sont pas tous terminés). Prend toujours le pas sur le reste.
 */
export function computeQuizProgress(
  quiz: QuizConfig,
  userAttempts: QuizAttemptRow[],
  lockedByCurriculum: boolean = false
): QuizProgress {
  const attempts = userAttempts
    .filter((a) => a.quiz_id === quiz.id)
    .sort((a, b) => {
      // Plus récent d'abord (par finished_at, fallback started_at)
      const ta = new Date(a.finished_at ?? a.started_at).getTime();
      const tb = new Date(b.finished_at ?? b.started_at).getTime();
      return tb - ta;
    });

  const finished = attempts.filter((a) => a.finished_at !== null);
  const inProgress = attempts.find((a) => a.finished_at === null);
  const passed = finished.filter((a) => a.passed);

  const attemptsUsed = finished.length;
  const attemptsMax = quiz.max_attempts;
  const attemptsLeft =
    attemptsMax != null ? Math.max(0, attemptsMax - attemptsUsed) : null;

  const bestScore =
    passed.length > 0
      ? Math.max(...passed.map((a) => a.percentage))
      : finished.length > 0
        ? Math.max(...finished.map((a) => a.percentage))
        : null;

  const bestPassed = passed.length > 0;

  const last = finished[0] ?? null;
  const lastScore = last?.percentage ?? null;
  const lastPassed = last?.passed ?? null;
  const lastAttemptId = last?.id ?? null;
  const lastAttemptAt = last?.finished_at ?? null;

  // Verrou parcours pédagogique : prend le pas sur tout
  if (lockedByCurriculum) {
    return baseProgress({
      quiz_id: quiz.id,
      state: "locked",
      attemptsUsed,
      attemptsMax,
      attemptsLeft,
      bestScore,
      bestPassed,
      lastScore,
      lastPassed,
      lastAttemptId,
      lastAttemptAt,
      inProgressId: inProgress?.id ?? null,
      nextAvailableAt: null,
      reason: "curriculum",
    });
  }

  // Tentative en cours non terminée
  if (inProgress) {
    return baseProgress({
      quiz_id: quiz.id,
      state: "in-progress",
      attemptsUsed,
      attemptsMax,
      attemptsLeft,
      bestScore,
      bestPassed,
      lastScore,
      lastPassed,
      lastAttemptId,
      lastAttemptAt,
      inProgressId: inProgress.id,
      nextAvailableAt: null,
      reason: null,
    });
  }

  // max_attempts atteint sans réussite
  if (attemptsMax != null && attemptsUsed >= attemptsMax && !bestPassed) {
    return baseProgress({
      quiz_id: quiz.id,
      state: "blocked-attempts",
      attemptsUsed,
      attemptsMax,
      attemptsLeft,
      bestScore,
      bestPassed,
      lastScore,
      lastPassed,
      lastAttemptId,
      lastAttemptAt,
      inProgressId: null,
      nextAvailableAt: null,
      reason: "max_attempts",
    });
  }

  // retake_delay non écoulé
  let nextAvailableAt: string | null = null;
  if (
    quiz.retake_delay_hours &&
    quiz.retake_delay_hours > 0 &&
    lastAttemptAt
  ) {
    const next = new Date(
      new Date(lastAttemptAt).getTime() +
        quiz.retake_delay_hours * 3600 * 1000
    );
    if (next.getTime() > Date.now()) {
      nextAvailableAt = next.toISOString();
    }
  }
  if (nextAvailableAt) {
    return baseProgress({
      quiz_id: quiz.id,
      state: "blocked-delay",
      attemptsUsed,
      attemptsMax,
      attemptsLeft,
      bestScore,
      bestPassed,
      lastScore,
      lastPassed,
      lastAttemptId,
      lastAttemptAt,
      inProgressId: null,
      nextAvailableAt,
      reason: "retake_delay",
    });
  }

  if (bestPassed) {
    return baseProgress({
      quiz_id: quiz.id,
      state: "passed",
      attemptsUsed,
      attemptsMax,
      attemptsLeft,
      bestScore,
      bestPassed,
      lastScore,
      lastPassed,
      lastAttemptId,
      lastAttemptAt,
      inProgressId: null,
      nextAvailableAt: null,
      reason: null,
    });
  }

  if (attemptsUsed > 0) {
    return baseProgress({
      quiz_id: quiz.id,
      state: "failed",
      attemptsUsed,
      attemptsMax,
      attemptsLeft,
      bestScore,
      bestPassed,
      lastScore,
      lastPassed,
      lastAttemptId,
      lastAttemptAt,
      inProgressId: null,
      nextAvailableAt: null,
      reason: null,
    });
  }

  return baseProgress({
    quiz_id: quiz.id,
    state: "todo",
    attemptsUsed: 0,
    attemptsMax,
    attemptsLeft,
    bestScore: null,
    bestPassed: false,
    lastScore: null,
    lastPassed: null,
    lastAttemptId: null,
    lastAttemptAt: null,
    inProgressId: null,
    nextAvailableAt: null,
    reason: null,
  });
}

function baseProgress(args: {
  quiz_id: string;
  state: QuizState;
  attemptsUsed: number;
  attemptsMax: number | null;
  attemptsLeft: number | null;
  bestScore: number | null;
  bestPassed: boolean;
  lastScore: number | null;
  lastPassed: boolean | null;
  lastAttemptId: string | null;
  lastAttemptAt: string | null;
  inProgressId: string | null;
  nextAvailableAt: string | null;
  reason: string | null;
}): QuizProgress {
  return {
    quiz_id: args.quiz_id,
    state: args.state,
    attempts_used: args.attemptsUsed,
    attempts_max: args.attemptsMax,
    attempts_left: args.attemptsLeft,
    best_score: args.bestScore,
    best_passed: args.bestPassed,
    last_score: args.lastScore,
    last_passed: args.lastPassed,
    last_attempt_id: args.lastAttemptId,
    last_attempt_at: args.lastAttemptAt,
    in_progress_attempt_id: args.inProgressId,
    next_available_at: args.nextAvailableAt,
    reason: args.reason,
  };
}

// ---------------------------------------------------------------------
// Choix du quiz à proposer dans la ContinueCard
// ---------------------------------------------------------------------

/**
 * Priorité :
 *  1. Tentative en cours (in-progress) la plus récente
 *  2. Quiz failed le plus récent (à refaire)
 *  3. Quiz todo le plus tôt dans le parcours (par display_order amont)
 *  4. null si tout est passed/blocked
 */
export function pickNextQuiz(
  progresses: QuizProgress[]
): QuizProgress | null {
  const inProgress = progresses
    .filter((p) => p.state === "in-progress")
    .sort((a, b) => {
      const ta = a.last_attempt_at ? new Date(a.last_attempt_at).getTime() : 0;
      const tb = b.last_attempt_at ? new Date(b.last_attempt_at).getTime() : 0;
      return tb - ta;
    });
  if (inProgress.length > 0) return inProgress[0];

  const failed = progresses
    .filter((p) => p.state === "failed")
    .sort((a, b) => {
      const ta = a.last_attempt_at ? new Date(a.last_attempt_at).getTime() : 0;
      const tb = b.last_attempt_at ? new Date(b.last_attempt_at).getTime() : 0;
      return tb - ta;
    });
  if (failed.length > 0) return failed[0];

  const todo = progresses.filter((p) => p.state === "todo");
  if (todo.length > 0) return todo[0];

  return null;
}
