// =====================================================================
// Score de risque de décrochage (heuristique transparente).
//
// PUR (testable). PAS du machine learning : une pondération explicite et
// auditable de signaux observables (inactivité, progression, score,
// engagement). Sert d'aide à la décision pour formateurs/admins (qui
// relancer en priorité). Un vrai modèle prédictif (ML entraîné sur
// l'historique) pourra le remplacer plus tard sans changer l'interface.
// =====================================================================

export interface RiskInputs {
  /** Progression 0-100 (% de leçons terminées). */
  completionPct: number;
  /** Score moyen 0-100 (0 si aucune tentative). */
  avgScorePct: number;
  /** Jours depuis la dernière activité ; null = jamais actif. */
  daysSinceLastActivity: number | null;
  /** Nombre de quiz tentés. */
  attemptsCount: number;
}

export type RiskLevel = "faible" | "moyen" | "eleve";

export interface RiskResult {
  /** 0-100 : plus c'est haut, plus le risque de décrochage est élevé. */
  score: number;
  level: RiskLevel;
  /** Raisons lisibles (pour l'UI). */
  factors: string[];
}

export function computeRiskScore(input: RiskInputs): RiskResult {
  const { completionPct, avgScorePct, daysSinceLastActivity, attemptsCount } =
    input;
  let score = 0;
  const factors: string[] = [];

  // 1) Inactivité (signal le plus prédictif du décrochage)
  if (daysSinceLastActivity === null) {
    score += 35;
    factors.push("Jamais actif depuis l'inscription");
  } else if (daysSinceLastActivity >= 30) {
    score += 40;
    factors.push("Plus de 30 jours d'inactivité");
  } else if (daysSinceLastActivity >= 14) {
    score += 28;
    factors.push("Plus de 2 semaines d'inactivité");
  } else if (daysSinceLastActivity >= 7) {
    score += 15;
    factors.push("Plus d'une semaine d'inactivité");
  }

  // 2) Progression faible
  if (completionPct < 20) {
    score += 25;
    factors.push("Progression très faible (< 20 %)");
  } else if (completionPct < 50) {
    score += 12;
    factors.push("Progression en retard (< 50 %)");
  }

  // 3) Score insuffisant (seulement si des tentatives existent)
  if (attemptsCount > 0 && avgScorePct < 50) {
    score += 25;
    factors.push("Score moyen sous 50 %");
  } else if (attemptsCount > 0 && avgScorePct < 65) {
    score += 12;
    factors.push("Score moyen fragile (< 65 %)");
  }

  // 4) Aucun engagement aux quiz
  if (attemptsCount === 0) {
    score += 12;
    factors.push("Aucun quiz tenté");
  }

  score = Math.max(0, Math.min(100, score));
  const level: RiskLevel =
    score >= 60 ? "eleve" : score >= 30 ? "moyen" : "faible";

  if (factors.length === 0) factors.push("Bonne dynamique, aucun signal d'alerte");

  return { score, level, factors };
}

export const RISK_LEVEL_LABEL: Record<RiskLevel, string> = {
  faible: "Risque faible",
  moyen: "Risque modéré",
  eleve: "Risque élevé",
};
