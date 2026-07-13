import { describe, it, expect } from "vitest";
import {
  hasPackFeature,
  getMinPackForFeature,
  comparePacks,
  isPackAtLeast,
  getUpgradablePacks,
  getAllPackFeatures,
  isPackAvailableForFormation,
  getAvailablePacksForFormation,
  PACK_SLUGS,
} from "./packs";

describe("packs — hiérarchie d'accès aux features", () => {
  it("aucun pack (null/undefined) → aucune feature", () => {
    expect(hasPackFeature(null, "lessons")).toBe(false);
    expect(hasPackFeature(undefined, "live_sessions")).toBe(false);
  });

  it("une feature de base (Initial) est héritée par les paliers supérieurs", () => {
    expect(hasPackFeature("initial", "qr_ai_grading")).toBe(true);
    expect(hasPackFeature("medium", "qr_ai_grading")).toBe(true);
    expect(hasPackFeature("premium", "qr_ai_grading")).toBe(true);
  });

  it("une feature Medium n'est pas accessible en Initial", () => {
    expect(hasPackFeature("initial", "messaging_dedicated_trainer")).toBe(false);
    expect(hasPackFeature("medium", "messaging_dedicated_trainer")).toBe(true);
    expect(hasPackFeature("premium", "messaging_dedicated_trainer")).toBe(true);
  });

  it("une feature Premium n'est accessible qu'en Premium", () => {
    expect(hasPackFeature("initial", "live_sessions")).toBe(false);
    expect(hasPackFeature("medium", "live_sessions")).toBe(false);
    expect(hasPackFeature("premium", "live_sessions")).toBe(true);
  });

  it("invariant d'héritage : ce qu'a Initial, Medium et Premium l'ont aussi", () => {
    for (const f of getAllPackFeatures("initial")) {
      expect(hasPackFeature("medium", f)).toBe(true);
      expect(hasPackFeature("premium", f)).toBe(true);
    }
  });

  it("getAllPackFeatures cumule la hiérarchie", () => {
    const premium = getAllPackFeatures("premium");
    expect(premium).toContain("lessons"); // hérité d'Initial
    expect(premium).toContain("messaging_dedicated_trainer"); // hérité de Medium
    expect(premium).toContain("ai_tutor_chat"); // propre à Premium
    expect(getAllPackFeatures("initial")).not.toContain("live_sessions");
  });

  it("getMinPackForFeature renvoie le plus petit pack couvrant la feature", () => {
    expect(getMinPackForFeature("lessons")).toBe("initial");
    expect(getMinPackForFeature("messaging_dedicated_trainer")).toBe("medium");
    expect(getMinPackForFeature("ai_tutor_chat")).toBe("premium");
  });

  it("comparePacks ordonne initial < medium < premium", () => {
    expect(comparePacks("initial", "medium")).toBeLessThan(0);
    expect(comparePacks("premium", "initial")).toBeGreaterThan(0);
    expect(comparePacks("medium", "medium")).toBe(0);
  });

  it("isPackAtLeast respecte la hiérarchie", () => {
    expect(isPackAtLeast("premium", "initial")).toBe(true);
    expect(isPackAtLeast("initial", "premium")).toBe(false);
    expect(isPackAtLeast("medium", "medium")).toBe(true);
  });

  it("getUpgradablePacks liste les paliers strictement supérieurs", () => {
    expect(getUpgradablePacks("initial")).toEqual(["medium", "premium"]);
    expect(getUpgradablePacks("premium")).toEqual([]);
  });
});

describe("packs — disponibilité par formation", () => {
  it("Capacité ≤ 3,5 t n'autorise QUE le pack Initial (règle client)", () => {
    expect(isPackAvailableForFormation("initial", "capacite-3-5t")).toBe(true);
    expect(isPackAvailableForFormation("medium", "capacite-3-5t")).toBe(false);
    expect(isPackAvailableForFormation("premium", "capacite-3-5t")).toBe(false);
    expect(getAvailablePacksForFormation("capacite-3-5t")).toEqual(["initial"]);
  });

  it("les autres formations autorisent tous les packs", () => {
    expect(isPackAvailableForFormation("premium", "gotrm")).toBe(true);
    expect(getAvailablePacksForFormation("gotrm")).toEqual([...PACK_SLUGS]);
  });
});
