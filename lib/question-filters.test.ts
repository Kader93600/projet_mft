import { describe, it, expect } from "vitest";
import { getQuestionFilterConfig } from "./question-filters";

describe("getQuestionFilterConfig", () => {
  it("fallback générique quand la formation est nulle/inconnue", () => {
    for (const cfg of [
      getQuestionFilterConfig(null),
      getQuestionFilterConfig(undefined),
      getQuestionFilterConfig("formation-inexistante"),
    ]) {
      expect(cfg.tagPrefix).toBe("chapitre-");
      expect(cfg.label).toBe("Chapitre");
    }
  });

  it("GOTRM → nomenclature chapitres", () => {
    const cfg = getQuestionFilterConfig("gotrm");
    expect(cfg.tagPrefix).toBe("chapitre-");
    expect(cfg.formatPill("3")).toBe("Ch. 3");
    expect(cfg.formatLong?.("3")).toBe("Chapitre 3");
    expect(cfg.keys).toContain("1");
    expect(cfg.keys).toContain("17");
  });

  it("Capacité ≤ 3,5 t → modules (libellés en majuscules)", () => {
    const cfg = getQuestionFilterConfig("capacite-3-5t");
    expect(cfg.tagPrefix).toBe("module-");
    expect(cfg.formatPill("a")).toBe("A");
    expect(cfg.formatLong?.("b")).toBe("Module B");
  });

  it("Capacité lourde partage la nomenclature module", () => {
    expect(getQuestionFilterConfig("capacite-plus-3-5t").tagPrefix).toBe(
      "module-"
    );
  });
});
