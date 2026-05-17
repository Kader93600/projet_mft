// =====================================================================
// Calcul de progression vers un badge non débloqué.
//
// Les badges sont définis en SQL avec un `criteria jsonb` :
//   { type: 'first_quiz_passed' }
//   { type: 'quiz_passed_count',  min: 5 }
//   { type: 'perfect_score',      min: 3 }
//   { type: 'mock_exam_passed',   min: 1 }
//   { type: 'lessons_completed',  min: 10 }
//   { type: 'bloc_mastered',      bloc_id: 1 }
//
// Cette fonction *ne fait pas* de requête : on lui passe les stocks
// agrégés (calculés une seule fois par page) et elle retourne un
// triplet (current, target, percent) prêt à afficher.
//
// Si le critère est inconnu, on retourne null pour signaler "pas
// d'indicateur de progression disponible".
// =====================================================================

export type BadgeCriteria = {
  type?: string;
  min?: number;
  bloc_id?: number | string;
};

export interface UserStats {
  /** Nombre de quiz distincts réussis (passed = true). */
  quizPassedCount: number;
  /** Nombre de tentatives avec percentage = 100. */
  perfectScoreCount: number;
  /** Nombre d'examens blancs réussis (is_mock_exam = true et passed = true). */
  mockExamPassedCount: number;
  /** Nombre de leçons complétées (lesson_progress.completed = true). */
  lessonsCompletedCount: number;
  /**
   * Pour chaque bloc : {total_lessons, done_lessons, exams_passed}.
   * Clé = bloc_id (number).
   */
  blocStats: Map<
    number,
    {
      totalLessons: number;
      doneLessons: number;
      examsPassed: number;
    }
  >;
}

export interface BadgeProgress {
  /** Quantité atteinte aujourd'hui. */
  current: number;
  /** Quantité cible pour débloquer. */
  target: number;
  /** 0-100. */
  percent: number;
  /** Libellé court pour l'UI : "Quiz réussis", "Leçons complétées", etc. */
  label: string;
}

export function computeBadgeProgress(
  criteria: BadgeCriteria | null | undefined,
  stats: UserStats
): BadgeProgress | null {
  if (!criteria || typeof criteria !== "object") return null;
  const { type } = criteria;
  const min = Number(criteria.min ?? 1);

  switch (type) {
    case "first_quiz_passed":
      return {
        current: Math.min(stats.quizPassedCount, 1),
        target: 1,
        percent: stats.quizPassedCount >= 1 ? 100 : 0,
        label: "Premier quiz réussi",
      };

    case "quiz_passed_count":
      return {
        current: Math.min(stats.quizPassedCount, min),
        target: min,
        percent: Math.min(100, Math.round((stats.quizPassedCount / min) * 100)),
        label: "Quiz réussis",
      };

    case "perfect_score":
      return {
        current: Math.min(stats.perfectScoreCount, min),
        target: min,
        percent: Math.min(100, Math.round((stats.perfectScoreCount / min) * 100)),
        label: "Scores parfaits (100 %)",
      };

    case "mock_exam_passed":
      return {
        current: Math.min(stats.mockExamPassedCount, min),
        target: min,
        percent: Math.min(
          100,
          Math.round((stats.mockExamPassedCount / min) * 100)
        ),
        label: "Examens blancs réussis",
      };

    case "lessons_completed":
      return {
        current: Math.min(stats.lessonsCompletedCount, min),
        target: min,
        percent: Math.min(
          100,
          Math.round((stats.lessonsCompletedCount / min) * 100)
        ),
        label: "Leçons complétées",
      };

    case "bloc_mastered": {
      const blocId = Number(criteria.bloc_id);
      if (!Number.isFinite(blocId)) return null;
      const bloc = stats.blocStats.get(blocId);
      if (!bloc || bloc.totalLessons === 0) {
        return {
          current: 0,
          target: 1,
          percent: 0,
          label: "Bloc à compléter",
        };
      }
      // Trois sous-critères. On les agrège en un % pondéré.
      // 70 % = leçons, 30 % = examen.
      const lessonsRatio = bloc.doneLessons / bloc.totalLessons;
      const examRatio = bloc.examsPassed >= 1 ? 1 : 0;
      const percent = Math.round((lessonsRatio * 0.7 + examRatio * 0.3) * 100);
      return {
        current: bloc.doneLessons,
        target: bloc.totalLessons,
        percent: Math.min(100, percent),
        label: `Bloc ${blocId} — leçons`,
      };
    }

    default:
      return null;
  }
}
