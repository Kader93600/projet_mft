import { describe, it, expect } from "vitest";
import {
  isRichTextHtml,
  plainTextToHtml,
  richTextToPlain,
  sanitizeRichTextServer,
} from "./rich-text";

describe("isRichTextHtml", () => {
  it("true pour du HTML avec balises de bloc", () => {
    expect(isRichTextHtml("<p>Bonjour</p>")).toBe(true);
    expect(isRichTextHtml("<h2>Titre</h2><p>Texte</p>")).toBe(true);
    expect(isRichTextHtml("<ul><li>item</li></ul>")).toBe(true);
  });
  it("false pour du texte simple", () => {
    expect(isRichTextHtml("Bonjour le monde")).toBe(false);
    expect(isRichTextHtml("Une phrase normale.")).toBe(false);
  });
  it("false pour null / undefined / vide", () => {
    expect(isRichTextHtml(null)).toBe(false);
    expect(isRichTextHtml(undefined)).toBe(false);
    expect(isRichTextHtml("")).toBe(false);
  });
});

describe("plainTextToHtml", () => {
  it("entoure le texte de <p>", () => {
    expect(plainTextToHtml("Bonjour")).toBe("<p>Bonjour</p>");
  });
  it("transforme les retours à la ligne en <br>", () => {
    const out = plainTextToHtml("Ligne 1\nLigne 2");
    expect(out).toContain("Ligne 1");
    expect(out).toContain("Ligne 2");
    expect(out).toContain("<br");
  });
  it("crée des paragraphes pour les doubles retours", () => {
    const out = plainTextToHtml("Para 1\n\nPara 2");
    expect(out.match(/<p>/g)?.length).toBe(2);
  });
  it("échappe les caractères HTML dangereux", () => {
    const out = plainTextToHtml("<script>alert(1)</script>");
    expect(out).not.toContain("<script>");
    expect(out).toContain("&lt;script&gt;");
  });
});

describe("richTextToPlain", () => {
  it("retire toutes les balises HTML", () => {
    expect(richTextToPlain("<p>Bonjour</p>")).toBe("Bonjour");
    expect(richTextToPlain("<h2>Titre</h2><p>Texte</p>")).toContain("Titre");
    expect(richTextToPlain("<h2>Titre</h2><p>Texte</p>")).toContain("Texte");
  });
  it("supporte les listes", () => {
    const out = richTextToPlain("<ul><li>Pomme</li><li>Banane</li></ul>");
    expect(out).toContain("Pomme");
    expect(out).toContain("Banane");
  });
  it("décode les entités HTML supportées", () => {
    expect(richTextToPlain("<p>&amp; et</p>")).toContain("& et");
    expect(richTextToPlain("<p>&lt;div&gt;</p>")).toContain("<div>");
    expect(richTextToPlain("<p>&quot;mot&quot;</p>")).toContain('"mot"');
    expect(richTextToPlain("<p>n&#39;est</p>")).toContain("n'est");
    expect(richTextToPlain("<p>a&nbsp;b</p>")).toContain("a b");
  });
});

describe("sanitizeRichTextServer", () => {
  it("retire les balises <script>", () => {
    const out = sanitizeRichTextServer("<p>OK</p><script>alert(1)</script>");
    expect(out).not.toContain("<script");
    expect(out).toContain("<p>OK</p>");
  });
  it("retire les attributs on* (onclick, onerror, etc.)", () => {
    const out = sanitizeRichTextServer('<p onclick="alert(1)">Texte</p>');
    expect(out).not.toContain("onclick");
    expect(out).toContain("Texte");
  });
  it("retire les liens javascript:", () => {
    const out = sanitizeRichTextServer('<a href="javascript:alert(1)">click</a>');
    expect(out).not.toContain("javascript:");
  });
  it("conserve les balises légitimes (p, h2, ul, li, strong, em, a href https)", () => {
    const html = '<h2>Titre</h2><p>Voir <a href="https://example.com">site</a></p><ul><li>item</li></ul>';
    const out = sanitizeRichTextServer(html);
    expect(out).toContain("<h2>");
    expect(out).toContain("<p>");
    expect(out).toContain("<ul>");
    expect(out).toContain("<li>");
    expect(out).toContain('href="https://example.com"');
  });
});
