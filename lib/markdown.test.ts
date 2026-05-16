import { describe, it, expect } from "vitest";
import { renderMarkdown } from "./markdown";

describe("renderMarkdown — éléments de base", () => {
  it("transforme # en h1", () => {
    expect(renderMarkdown("# Titre")).toContain("<h1");
    expect(renderMarkdown("# Titre")).toContain("Titre");
  });

  it("transforme ## en h2", () => {
    expect(renderMarkdown("## Sous-titre")).toContain("<h2");
  });

  it("transforme **gras** en <strong>", () => {
    const out = renderMarkdown("Texte **important** ici");
    expect(out).toContain("<strong");
    expect(out).toContain("important");
  });

  it("transforme *italique* en <em>", () => {
    const out = renderMarkdown("Texte *italique* ici");
    expect(out).toContain("<em");
  });

  it("transforme les listes à puces", () => {
    const out = renderMarkdown("- Pomme\n- Banane\n- Cerise");
    expect(out).toContain("<ul");
    expect(out).toContain("<li");
    expect(out).toContain("Pomme");
    expect(out).toContain("Cerise");
  });

  it("transforme les listes numérotées", () => {
    const out = renderMarkdown("1. Un\n2. Deux\n3. Trois");
    expect(out).toContain("<ol");
    expect(out).toContain("<li");
  });

  it("échappe les balises HTML pour la sécurité", () => {
    const out = renderMarkdown("<script>alert(1)</script>");
    expect(out).not.toContain("<script>alert");
    expect(out).toContain("&lt;script&gt;");
  });

  it("transforme les liens [texte](url)", () => {
    const out = renderMarkdown("Voir [Google](https://google.com)");
    expect(out).toContain("<a");
    expect(out).toContain("href=");
    expect(out).toContain("https://google.com");
  });
});

describe("renderMarkdown — blocs personnalisés MFT", () => {
  it("supporte les blocs :::flow / :::", () => {
    const md = ":::flow\nActeur 1\nActeur 2\nActeur 3\n:::";
    const out = renderMarkdown(md);
    expect(out).toBeTruthy();
    // Ne doit pas afficher les ::: littéraux
    expect(out).not.toContain(":::flow");
    expect(out).not.toContain(":::\n");
  });

  it("supporte les blocs :::timeline / :::", () => {
    const md = ":::timeline\nÉtape 1\nÉtape 2\n:::";
    const out = renderMarkdown(md);
    expect(out).not.toContain(":::timeline");
  });

  it("supporte les blocs de code ```", () => {
    const md = "```js\nconst x = 1;\n```";
    const out = renderMarkdown(md);
    expect(out).toContain("<pre");
    expect(out).toContain("const x = 1");
  });
});

describe("renderMarkdown — edge cases", () => {
  it("chaîne vide → sortie vide ou minimale", () => {
    const out = renderMarkdown("");
    expect(typeof out).toBe("string");
  });

  it("texte simple sans balises → enveloppé dans un paragraphe", () => {
    const out = renderMarkdown("Bonjour le monde");
    expect(out).toContain("Bonjour le monde");
  });

  it("conserve les retours à la ligne pour les paragraphes multiples", () => {
    const out = renderMarkdown("Para 1\n\nPara 2");
    expect(out).toContain("Para 1");
    expect(out).toContain("Para 2");
  });
});
