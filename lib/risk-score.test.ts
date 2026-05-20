import { describe, it, expect } from "vitest";
import { computeRiskScore, RISK_LEVEL_LABEL } from "./risk-score";

describe("computeRiskScore", () => {
  it("bon élève actif → risque faible, sans facteur d'alerte", () => {
    const r = computeRiskScore({
      completionPct: 80,
      avgScorePct: 78,
      daysSinceLastActivity: 1,
      attemptsCount: 6,
    });
    expect(r.level).toBe("faible");
    expect(r.score).toBeLessThan(30);
    expect(r.factors[0]).toMatch(/bonne dynamique/i);
  });

  it("inactif 30j + faible progression + jamais de quiz → risque élevé", () => {
    const r = computeRiskScore({
      completionPct: 10,
      avgScorePct: 0,
      daysSinceLastActivity: 45,
      attemptsCount: 0,
    });
    // 40 (inactif) + 25 (progression) + 12 (aucun quiz) = 77
    expect(r.score).toBe(77);
    expect(r.level).toBe("eleve");
    expect(r.factors).toContain("Plus de 30 jours d'inactivité");
    expect(r.factors).toContain("Aucun quiz tenté");
  });

  it("jamais actif → facteur dédié + contribution forte", () => {
    const r = computeRiskScore({
      completionPct: 0,
      avgScorePct: 0,
      daysSinceLastActivity: null,
      attemptsCount: 0,
    });
    expect(r.factors).toContain("Jamais actif depuis l'inscription");
    // 35 + 25 + 12 = 72
    expect(r.score).toBe(72);
    expect(r.level).toBe("eleve");
  });

  it("score faible ne pénalise QUE si des tentatives existent", () => {
    const sansTentative = computeRiskScore({
      completionPct: 60,
      avgScorePct: 0,
      daysSinceLastActivity: 2,
      attemptsCount: 0,
    });
    // pas de pénalité "score" (0 tentative) mais +12 "aucun quiz"
    expect(sansTentative.factors).not.toContain("Score moyen sous 50 %");
    expect(sansTentative.factors).toContain("Aucun quiz tenté");

    const avecTentative = computeRiskScore({
      completionPct: 60,
      avgScorePct: 40,
      daysSinceLastActivity: 2,
      attemptsCount: 3,
    });
    expect(avecTentative.factors).toContain("Score moyen sous 50 %");
  });

  it("niveau moyen sur signaux intermédiaires", () => {
    const r = computeRiskScore({
      completionPct: 40,
      avgScorePct: 60,
      daysSinceLastActivity: 8,
      attemptsCount: 2,
    });
    // 15 (inactif 7+) + 12 (progression <50) + 12 (score <65) = 39
    expect(r.score).toBe(39);
    expect(r.level).toBe("moyen");
  });

  it("borne le score à 100", () => {
    const r = computeRiskScore({
      completionPct: 0,
      avgScorePct: 10,
      daysSinceLastActivity: 90,
      attemptsCount: 1,
    });
    expect(r.score).toBeLessThanOrEqual(100);
  });

  it("expose des libellés de niveau", () => {
    expect(RISK_LEVEL_LABEL.eleve).toBe("Risque élevé");
    expect(RISK_LEVEL_LABEL.faible).toBe("Risque faible");
  });
});
