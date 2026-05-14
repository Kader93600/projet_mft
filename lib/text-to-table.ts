// =====================================================================
// Conversion texte sélectionné → tableau HTML.
//
// Détecte intelligemment les séparateurs de colonnes :
//   - Tabulation (\t)              → CSV depuis Excel
//   - Pipe (|)                     → markdown
//   - Point-virgule (;)            → CSV européen
//   - Espaces multiples (2+)       → aligné fixe
//   - 1 espace simple              → header 2-col + cellules vides
//
// Conçu pour reconstruire les tableaux des livrets PDF type :
//   "Acteur Rôle"
//   "MD France"
//   "RENAULT"
//   "TRANSGO"
//   "ZALTO"
//
// → tableau 2 colonnes (Acteur / Rôle) avec les noms en colonne 1 et
// la colonne 2 vide à remplir par le stagiaire.
// =====================================================================

export type Separator = "tab" | "pipe" | "semicolon" | "multispace" | "header-then-list";

export interface ParsedTable {
  /** Header (1ère ligne). Au moins 1 cellule. */
  header: string[];
  /** Lignes suivantes. Chaque ligne a exactement header.length cellules. */
  body: string[][];
  /** Séparateur utilisé pour le parse. */
  separator: Separator;
  /** Nombre de colonnes. */
  cols: number;
  /** Nombre de lignes du corps (sans header). */
  rows: number;
}

/**
 * Détecte le meilleur séparateur pour un texte donné.
 * Renvoie le séparateur détecté + une confiance subjective 0..1.
 */
export function detectSeparator(text: string): {
  separator: Separator;
  confidence: number;
} {
  const lines = text
    .split("\n")
    .map((l) => l.trim())
    .filter(Boolean);
  if (lines.length === 0) {
    return { separator: "multispace", confidence: 0 };
  }

  const hasTab = lines.some((l) => /\t/.test(l));
  if (hasTab) return { separator: "tab", confidence: 0.95 };

  const pipeRows = lines.filter((l) => /\|/.test(l)).length;
  if (pipeRows >= Math.ceil(lines.length * 0.8)) {
    return { separator: "pipe", confidence: 0.9 };
  }

  const semiRows = lines.filter((l) => /;/.test(l)).length;
  if (semiRows >= Math.ceil(lines.length * 0.8)) {
    return { separator: "semicolon", confidence: 0.85 };
  }

  // Multispace : au moins 2 lignes ont 2+ espaces consécutifs
  const multiSpaceRows = lines.filter((l) => /\s{2,}/.test(l)).length;
  if (multiSpaceRows >= Math.ceil(lines.length * 0.5) && multiSpaceRows >= 2) {
    return { separator: "multispace", confidence: 0.75 };
  }

  // Fallback : header avec ≥ 2 mots, suivi de lignes courtes (1-2 mots)
  // C'est typiquement le cas des tableaux PDF type "Acteur Rôle".
  if (lines.length >= 3) {
    const firstWords = lines[0].split(/\s+/).length;
    const restAvgWords =
      lines.slice(1).reduce((s, l) => s + l.split(/\s+/).length, 0) /
      (lines.length - 1);
    if (firstWords >= 2 && firstWords <= 4 && restAvgWords <= firstWords) {
      return { separator: "header-then-list", confidence: 0.6 };
    }
  }

  return { separator: "multispace", confidence: 0.3 };
}

/**
 * Parse un texte en table selon le séparateur donné.
 */
export function parseTextAsTable(
  text: string,
  separator: Separator,
): ParsedTable {
  const lines = text
    .split("\n")
    .map((l) => l.replace(/\s+$/g, "")) // trim right
    .filter((l) => l.trim().length > 0);

  if (lines.length === 0) {
    return { header: [""], body: [], separator, cols: 1, rows: 0 };
  }

  let cells: string[][];

  switch (separator) {
    case "tab":
      cells = lines.map((l) => l.split("\t").map((c) => c.trim()));
      break;
    case "pipe":
      // Gère les pipes optionnels en début/fin de ligne (markdown style)
      cells = lines
        .filter((l) => !/^\s*[-:|\s]+\s*$/.test(l)) // skip séparateur markdown
        .map((l) =>
          l
            .replace(/^\s*\|/, "")
            .replace(/\|\s*$/, "")
            .split("|")
            .map((c) => c.trim()),
        );
      break;
    case "semicolon":
      cells = lines.map((l) => l.split(";").map((c) => c.trim()));
      break;
    case "multispace":
      cells = lines.map((l) => l.split(/\s{2,}/).map((c) => c.trim()));
      break;
    case "header-then-list": {
      // Premier item : header (split sur espaces simples)
      // Lignes suivantes : 1 cellule en colonne 1, le reste vide.
      const header = lines[0].split(/\s+/);
      const cols = header.length;
      const body = lines.slice(1).map((l) => {
        const row: string[] = new Array(cols).fill("");
        row[0] = l.trim();
        return row;
      });
      return {
        header,
        body,
        separator,
        cols,
        rows: body.length,
      };
    }
  }

  // Normalise : toutes les lignes ont le même nombre de colonnes
  const maxCols = Math.max(1, ...cells.map((r) => r.length));
  const normalized = cells.map((row) => {
    const padded = row.slice();
    while (padded.length < maxCols) padded.push("");
    return padded;
  });

  const header = normalized[0] ?? [""];
  const body = normalized.slice(1);
  return {
    header,
    body,
    separator,
    cols: header.length,
    rows: body.length,
  };
}

/**
 * Convertit une ParsedTable en HTML compatible TipTap.
 * Le HTML produit sera inséré dans l'éditeur via commands.insertContent.
 */
export function tableToHtml(table: ParsedTable): string {
  const escape = (s: string) =>
    s
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;");

  const headerHtml = table.header
    .map((cell) => `<th><p>${escape(cell) || "&nbsp;"}</p></th>`)
    .join("");
  const bodyHtml = table.body
    .map(
      (row) =>
        `<tr>${row
          .map(
            (cell) => `<td><p>${escape(cell) || "&nbsp;"}</p></td>`,
          )
          .join("")}</tr>`,
    )
    .join("");

  return `<table><tbody><tr>${headerHtml}</tr>${bodyHtml}</tbody></table>`;
}

/**
 * Pipeline complet : texte → ParsedTable (avec séparateur auto-détecté).
 */
export function textToTable(text: string, hint?: Separator): ParsedTable {
  const sep = hint ?? detectSeparator(text).separator;
  return parseTextAsTable(text, sep);
}
