import { describe, it, expect } from "vitest";
import { getResultTier, RESULT_TIERS } from "./quiz-result-tiers";

describe("getResultTier", () => {
  it("mappe chaque borne sur le bon palier", () => {
    const cases: [number, string][] = [
      [0, "struggling"],
      [45, "struggling"],
      [46, "almost"],
      [50, "almost"],
      [51, "progress"],
      [69, "progress"],
      [70, "solid"],
      [89, "solid"],
      [90, "excellent"],
      [95, "excellent"],
      [96, "mastery"],
      [100, "mastery"],
    ];
    for (const [score, id] of cases) {
      expect(getResultTier(score).id, `score ${score}`).toBe(id);
    }
  });

  it("borne les scores hors plage", () => {
    expect(getResultTier(-20).id).toBe("struggling");
    expect(getResultTier(150).id).toBe("mastery");
  });

  it("arrondit les scores décimaux", () => {
    expect(getResultTier(69.4).id).toBe("progress"); // 69
    expect(getResultTier(69.6).id).toBe("solid"); // 70
    expect(getResultTier(95.6).id).toBe("mastery"); // 96
  });

  it("couvre 0–100 sans trou ni chevauchement", () => {
    // chaque palier suit immédiatement le précédent
    for (let i = 1; i < RESULT_TIERS.length; i++) {
      expect(RESULT_TIERS[i].min).toBe(RESULT_TIERS[i - 1].max + 1);
    }
    expect(RESULT_TIERS[0].min).toBe(0);
    expect(RESULT_TIERS[RESULT_TIERS.length - 1].max).toBe(100);
  });

  it("n'active les confettis qu'à partir de la progression", () => {
    expect(getResultTier(30).confetti).toBe(0);
    expect(getResultTier(48).confetti).toBe(0);
    expect(getResultTier(60).confetti).toBeGreaterThan(0);
    expect(getResultTier(98).confetti).toBeGreaterThan(getResultTier(75).confetti);
  });
});
