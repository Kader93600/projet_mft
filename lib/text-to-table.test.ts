import { describe, it, expect } from "vitest";
import {
  detectSeparator,
  parseTextAsTable,
  tableToHtml,
  textToTable,
} from "./text-to-table";

describe("detectSeparator", () => {
  it("détecte la tabulation (Excel paste)", () => {
    const text = "Nom\tÂge\nAlice\t30\nBob\t25";
    expect(detectSeparator(text).separator).toBe("tab");
  });

  it("détecte le pipe (markdown)", () => {
    const text = "| Nom | Âge |\n| Alice | 30 |\n| Bob | 25 |";
    expect(detectSeparator(text).separator).toBe("pipe");
  });

  it("détecte le point-virgule (CSV européen)", () => {
    const text = "Nom;Âge\nAlice;30\nBob;25";
    expect(detectSeparator(text).separator).toBe("semicolon");
  });

  it("détecte les espaces multiples (aligné fixe)", () => {
    const text = "Nom    Âge\nAlice   30\nBob     25";
    expect(detectSeparator(text).separator).toBe("multispace");
  });
});

describe("parseTextAsTable", () => {
  it("parse un tableau pipe markdown", () => {
    const text = "| Acteur | Rôle |\n| MD France | Transporteur |\n| RENAULT | Constructeur |";
    const table = parseTextAsTable(text, "pipe");
    expect(table.header).toEqual(["Acteur", "Rôle"]);
    expect(table.body).toHaveLength(2);
    expect(table.body[0]).toEqual(["MD France", "Transporteur"]);
    expect(table.body[1]).toEqual(["RENAULT", "Constructeur"]);
  });

  it("parse un CSV avec point-virgule", () => {
    const text = "Nom;Âge\nAlice;30\nBob;25";
    const table = parseTextAsTable(text, "semicolon");
    expect(table.header).toEqual(["Nom", "Âge"]);
    expect(table.body).toEqual([
      ["Alice", "30"],
      ["Bob", "25"],
    ]);
  });

  it("parse un tableau tabulé (Excel)", () => {
    const text = "Nom\tÂge\nAlice\t30";
    const table = parseTextAsTable(text, "tab");
    expect(table.header).toEqual(["Nom", "Âge"]);
    expect(table.body).toEqual([["Alice", "30"]]);
  });

  it("normalise au max des colonnes (header complété si plus court)", () => {
    // 2 colonnes au header, 3 cellules dans une ligne → maxCols=3
    // Le header est complété par une cellule vide.
    const text = "A;B\nX;Y;Z";
    const table = parseTextAsTable(text, "semicolon");
    expect(table.header).toEqual(["A", "B", ""]);
    expect(table.body[0]).toEqual(["X", "Y", "Z"]);
    expect(table.cols).toBe(3);
  });

  it("complète les cellules manquantes par des chaînes vides", () => {
    const text = "A;B;C\nX;Y";
    const table = parseTextAsTable(text, "semicolon");
    expect(table.body[0]).toHaveLength(3);
    expect(table.body[0]).toEqual(["X", "Y", ""]);
  });

  it("trim les espaces autour des cellules", () => {
    const text = "  A  ;  B  \n  X  ;  Y  ";
    const table = parseTextAsTable(text, "semicolon");
    expect(table.header).toEqual(["A", "B"]);
    expect(table.body[0]).toEqual(["X", "Y"]);
  });
});

describe("tableToHtml", () => {
  it("génère un tableau HTML compatible TipTap (table + tbody + th/td)", () => {
    const html = tableToHtml({
      header: ["Nom", "Âge"],
      body: [
        ["Alice", "30"],
        ["Bob", "25"],
      ],
      separator: "semicolon",
      cols: 2,
      rows: 2,
    });
    expect(html).toContain("<table");
    expect(html).toContain("<tbody");
    expect(html).toContain("<th");
    expect(html).toContain("<td");
    expect(html).toContain("Alice");
    expect(html).toContain("30");
    expect(html).toContain("Âge");
  });

  it("échappe les caractères HTML dangereux", () => {
    const html = tableToHtml({
      header: ["<script>"],
      body: [["alert('xss')"]],
      separator: "semicolon",
      cols: 1,
      rows: 1,
    });
    expect(html).not.toContain("<script>alert");
    expect(html).toContain("&lt;script&gt;");
  });
});

describe("textToTable (end-to-end)", () => {
  it("auto-détecte le séparateur et produit un ParsedTable", () => {
    const table = textToTable("A;B\nX;Y\nZ;W");
    expect(table.header).toEqual(["A", "B"]);
    expect(table.body).toHaveLength(2);
    expect(table.separator).toBe("semicolon");
  });

  it("accepte un hint manuel", () => {
    const table = textToTable("A B\nX Y", "multispace");
    expect(table.separator).toBe("multispace");
  });
});
