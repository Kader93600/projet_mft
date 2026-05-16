import { describe, it, expect } from "vitest";
import { cn, formatDate, scoreColor, initials, blocTone } from "./utils";

describe("cn (className merger)", () => {
  it("merge des classes simples", () => {
    expect(cn("a", "b")).toBe("a b");
  });
  it("filtre les valeurs falsy", () => {
    expect(cn("a", false && "x", null, undefined, "b")).toBe("a b");
  });
  it("résout les conflits Tailwind via twMerge", () => {
    // twMerge garde la dernière classe d'un même groupe
    expect(cn("px-2", "px-4")).toBe("px-4");
    expect(cn("text-red-500", "text-blue-500")).toBe("text-blue-500");
  });
  it("supporte les conditionnelles", () => {
    expect(cn("base", { active: true, hidden: false })).toBe("base active");
  });
});

describe("formatDate", () => {
  it("formate une date ISO en français court", () => {
    const result = formatDate("2026-05-14");
    // ex. "14 mai 2026" — peut varier selon le locale du runtime CI
    expect(result).toMatch(/14/);
    expect(result).toMatch(/2026/);
  });
  it("accepte un objet Date directement", () => {
    const result = formatDate(new Date("2026-01-01T12:00:00Z"));
    expect(result).toMatch(/2026/);
  });
});

describe("scoreColor", () => {
  it("vert pour score ≥ 80", () => {
    expect(scoreColor(80)).toBe("text-emerald-600");
    expect(scoreColor(95)).toBe("text-emerald-600");
    expect(scoreColor(100)).toBe("text-emerald-600");
  });
  it("or pour score 60-79", () => {
    expect(scoreColor(60)).toBe("text-gold-600");
    expect(scoreColor(70)).toBe("text-gold-600");
    expect(scoreColor(79)).toBe("text-gold-600");
  });
  it("rouge pour score < 60", () => {
    expect(scoreColor(0)).toBe("text-rose-600");
    expect(scoreColor(34)).toBe("text-rose-600");
    expect(scoreColor(59)).toBe("text-rose-600");
  });
});

describe("initials", () => {
  it("retourne ? si pas de nom", () => {
    expect(initials()).toBe("?");
    expect(initials(null)).toBe("?");
    expect(initials("")).toBe("?");
  });
  it("retourne 2 premières initiales en majuscules", () => {
    expect(initials("Jean Dupont")).toBe("JD");
    expect(initials("marie curie")).toBe("MC");
  });
  it("gère les noms simples (1 mot)", () => {
    expect(initials("Madonna")).toBe("M");
  });
  it("ignore les espaces multiples", () => {
    expect(initials("  Jean   Pierre  Dupont")).toBe("JP");
  });
  it("limite à 2 initiales même pour les noms longs", () => {
    expect(initials("Jean Pierre Marie Joseph Dupont")).toBe("JP");
  });
  it("supporte les accents", () => {
    expect(initials("Émilie Étienne")).toBe("ÉÉ");
  });
});

describe("blocTone", () => {
  it("retourne bc1/bc2/bc3 pour les codes GOTRM", () => {
    expect(blocTone("BC1")).toBe("bc1");
    expect(blocTone("BC2")).toBe("bc2");
    expect(blocTone("BC3")).toBe("bc3");
  });
  it("retourne navy par défaut", () => {
    expect(blocTone()).toBe("navy");
    expect(blocTone(undefined)).toBe("navy");
    expect(blocTone("UNKNOWN")).toBe("navy");
    expect(blocTone("CAPA-3-5T")).toBe("navy");
  });
});
