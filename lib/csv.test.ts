import { describe, it, expect } from "vitest";
import { toCsv, csvHeaders, fmtDate } from "./csv";

describe("toCsv — formula injection (OWASP)", () => {
  it("préfixe d'une apostrophe les cellules commençant par = + - @", () => {
    const rows = [
      { a: "=SUM(A1:A2)" },
      { a: "+1+1" },
      { a: "-2+3" },
      { a: "@cmd" },
    ];
    const csv = toCsv(rows, ["a"]);
    const lines = csv.replace(/^﻿/, "").split("\r\n");
    // header + 4 lignes
    expect(lines[0]).toBe("a");
    expect(lines[1]).toBe("'=SUM(A1:A2)");
    expect(lines[2]).toBe("'+1+1");
    expect(lines[3]).toBe("'-2+3");
    expect(lines[4]).toBe("'@cmd");
  });

  it("neutralise une formule contenant aussi une virgule (préfixe + quoting)", () => {
    const csv = toCsv([{ a: "=1,2" }], ["a"]);
    const line = csv.replace(/^﻿/, "").split("\r\n")[1];
    // apostrophe ajoutée PUIS quoting car la valeur contient une virgule
    expect(line).toBe('"\'=1,2"');
  });

  it("ne touche pas une valeur texte normale", () => {
    const csv = toCsv([{ a: "Dupont" }], ["a"]);
    expect(csv.replace(/^﻿/, "").split("\r\n")[1]).toBe("Dupont");
  });
});

describe("toCsv — RFC 4180", () => {
  it("entoure de guillemets et double les guillemets internes", () => {
    const csv = toCsv([{ a: 'il a dit "ok"' }], ["a"]);
    expect(csv.replace(/^﻿/, "").split("\r\n")[1]).toBe('"il a dit ""ok"""');
  });

  it("quote les valeurs avec virgule ou retour ligne", () => {
    expect(toCsv([{ a: "x,y" }], ["a"]).split("\r\n")[1]).toBe('"x,y"');
    expect(toCsv([{ a: "x\ny" }], ["a"]).split("\r\n")[1]).toBe('"x\ny"');
  });

  it("ajoute un BOM UTF-8 en tête", () => {
    expect(toCsv([{ a: "1" }], ["a"]).charCodeAt(0)).toBe(0xfeff);
  });

  it("rend les colonnes vides pour null/undefined", () => {
    const csv = toCsv([{ a: null, b: undefined }], ["a", "b"]);
    expect(csv.replace(/^﻿/, "").split("\r\n")[1]).toBe(",");
  });

  it("respecte l'ordre des colonnes fourni", () => {
    const csv = toCsv([{ b: "2", a: "1" }], ["a", "b"]);
    const lines = csv.replace(/^﻿/, "").split("\r\n");
    expect(lines[0]).toBe("a,b");
    expect(lines[1]).toBe("1,2");
  });

  it("renvoie une chaîne vide sans lignes ni colonnes", () => {
    expect(toCsv([])).toBe("");
  });
});

describe("csvHeaders / fmtDate", () => {
  it("assainit le filename et pose le Content-Disposition", () => {
    const h = csvHeaders("export é#.csv") as Record<string, string>;
    expect(h["Content-Type"]).toContain("text/csv");
    expect(h["Content-Disposition"]).toContain('filename="export___.csv"');
    expect(h["Content-Disposition"]).toContain("filename*=UTF-8''");
  });

  it("formate une date ISO en YYYY-MM-DD et tolère le vide", () => {
    expect(fmtDate("2026-05-20T10:00:00Z")).toBe("2026-05-20");
    expect(fmtDate(null)).toBe("");
    expect(fmtDate(undefined)).toBe("");
  });
});
