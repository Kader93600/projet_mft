/**
 * Variables d'environnement requises pour les tests E2E.
 *
 * Définies dans .env.test (non commité) ou exportées avant la commande.
 * Voir e2e/README.md pour la liste exhaustive.
 */

function required(name: string): string {
  const v = process.env[name];
  if (!v || v.trim().length === 0) {
    throw new Error(
      `[E2E] Variable d'environnement manquante : ${name}. Voir e2e/README.md`
    );
  }
  return v;
}

export const E2E_ENV = {
  studentEmail: () => required("E2E_STUDENT_EMAIL"),
  studentPassword: () => required("E2E_STUDENT_PASSWORD"),
  trainerEmail: () => required("E2E_TRAINER_EMAIL"),
  trainerPassword: () => required("E2E_TRAINER_PASSWORD"),
  /** ID UUID du quiz mixte QCM+QR utilisé pour le test. */
  quizId: () => required("E2E_QUIZ_ID"),
};
