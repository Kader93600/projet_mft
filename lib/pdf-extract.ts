// =====================================================================
// Extraction texte depuis un PDF (server-only).
//
// Capture le texte global ET le texte par page. Le texte par page est
// nécessaire pour deux choses :
//   - Détecter les pages d'annexes ("ANNEXE", "Annexe N°", tableaux)
//   - Localiser à quelle page se trouve chaque exercice / question
//
// IMPORTANT : import direct de `pdf-parse/lib/pdf-parse.js` pour
// contourner le bug de debug-auto-load de pdf-parse v1.x quand il est
// require()-é depuis Webpack/Next.js serverless.
// =====================================================================

import "server-only";

export interface PdfExtractResult {
  /** Texte brut concaténé de toutes les pages. */
  text: string;
  /** Texte par page (index = numéro de page - 1). */
  pageTexts: string[];
  /** Nombre de pages. */
  pages: number;
  /** Métadonnées PDF (titre, auteur, etc.). */
  info?: Record<string, unknown>;
  /** Taille originale du fichier en octets. */
  byteLength: number;
}

/**
 * Extrait le texte d'un buffer PDF, en gardant la séparation par page.
 */
export async function extractPdfText(
  buffer: Buffer,
): Promise<PdfExtractResult> {
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const pdfParse = require("pdf-parse/lib/pdf-parse.js") as (
    b: Buffer,
    opts?: PdfParseOptions,
  ) => Promise<{
    text: string;
    numpages: number;
    info?: Record<string, unknown>;
  }>;

  const pageTexts: string[] = [];

  const options: PdfParseOptions = {
    pagerender: async (pageData: PdfPageData) => {
      try {
        const content = await pageData.getTextContent({
          // Important : préserve l'ordre de lecture sans normaliser.
          normalizeWhitespace: false,
          disableCombineTextItems: false,
        });
        // Reconstruit le texte de la page en gérant les sauts de ligne.
        // Chaque item.str représente un "run" de texte ; on insère un \n
        // si la position Y change beaucoup entre deux items.
        let lastY: number | null = null;
        const lines: string[] = [];
        let current = "";
        for (const item of content.items as Array<{ str: string; transform?: number[] }>) {
          const y = item.transform?.[5];
          if (lastY != null && y != null && Math.abs(y - lastY) > 4) {
            if (current.trim()) lines.push(current.trim());
            current = "";
          }
          current += item.str;
          if (y != null) lastY = y;
        }
        if (current.trim()) lines.push(current.trim());
        const pageText = lines.join("\n");
        pageTexts.push(pageText);
        return pageText;
      } catch (e) {
        pageTexts.push("");
        return "";
      }
    },
  };

  const result = await pdfParse(buffer, options);

  // pdf-parse concatène ses retours de pagerender avec "\n\n" pour
  // produire result.text. Si pour une raison étrange pageTexts est
  // vide (ex. PDF chiffré), on fallback sur result.text.
  if (pageTexts.length === 0 && result.text) {
    pageTexts.push(result.text);
  }

  return {
    text: result.text ?? pageTexts.join("\n\n"),
    pageTexts,
    pages: result.numpages ?? pageTexts.length,
    info: result.info,
    byteLength: buffer.byteLength,
  };
}

/** Normalise le texte extrait (LF, espaces, sauts de ligne). */
export function normalizePdfText(raw: string): string {
  return raw
    .replace(/\r\n/g, "\n")
    .replace(/\r/g, "\n")
    .split("\n")
    .map((line) => line.replace(/[ \t]+/g, " ").trim())
    .join("\n")
    .replace(/\n{3,}/g, "\n\n");
}

// ---------------------------------------------------------------------
// Types internes (interface pdf-parse non typée nativement)
// ---------------------------------------------------------------------

interface PdfParseOptions {
  pagerender?: (page: PdfPageData) => Promise<string>;
  max?: number;
  version?: string;
}

interface PdfPageData {
  getTextContent: (opts: {
    normalizeWhitespace?: boolean;
    disableCombineTextItems?: boolean;
  }) => Promise<{
    items: unknown[];
  }>;
}
