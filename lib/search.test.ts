import { describe, it, expect } from "vitest";
import { sanitizeSearchTerm } from "./search";

describe("sanitizeSearchTerm (anti-injection PostgREST)", () => {
  it("laisse passer un terme simple inchangé", () => {
    expect(sanitizeSearchTerm("dupont")).toBe("dupont");
  });

  it("conserve les points et arobases (recherche d'e-mail)", () => {
    expect(sanitizeSearchTerm("jean.dupont@mail.fr")).toBe(
      "jean.dupont@mail.fr"
    );
  });

  it("neutralise la virgule (séparateur de conditions d'un or=(...))", () => {
    // Sans nettoyage, ceci injecterait une condition OR arbitraire.
    const out = sanitizeSearchTerm("x,role.eq.admin");
    expect(out).not.toContain(",");
  });

  it("retire parenthèses, antislash et astérisque (grammaire de filtre)", () => {
    const out = sanitizeSearchTerm("a(b)c\\d*e");
    expect(out).not.toMatch(/[()\\*]/);
  });

  it("échappe les wildcards SQL % et _", () => {
    expect(sanitizeSearchTerm("100%")).toBe("100\\%");
    expect(sanitizeSearchTerm("a_b")).toBe("a\\_b");
  });

  it("trim et normalise les espaces multiples", () => {
    expect(sanitizeSearchTerm("  a   b  ")).toBe("a b");
  });

  it("réduit une chaîne uniquement composée de métacaractères à du vide", () => {
    expect(sanitizeSearchTerm(",,,()**")).toBe("");
  });

  it("une tentative d'injection ne peut plus fermer le or(...)", () => {
    const out = sanitizeSearchTerm("%'),role.eq.admin,tags.cs.{x}");
    expect(out).not.toContain(",");
    expect(out).not.toContain(")");
    expect(out).not.toContain("(");
  });
});
