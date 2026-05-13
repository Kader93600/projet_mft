// =====================================================================
// Extraction texte depuis un PDF (server-only).
//
// Wrapper minimaliste autour de pdf-parse. Renvoie le texte brut + des
// métadonnées légères. Le parsing en questions vit dans question-parser.ts.
//
// Limites volontaires :
//   - Pas d'OCR (les PDFs scannés ne sortiront que du texte vide → fallback
//     côté UI : "Le PDF ne contient pas de texte sélectionnable. Copier-
//     coller le contenu dans le champ texte ci-dessous").
//   - Pas d'images, pas de mise en forme.
// =====================================================================

import "server-only";

export interface PdfExtractResult {
  /** Texte brut concaténé de toutes les pages. */
  text: string;
  /** Nombre de pages. */
  pages: number;
  /** Métadonnées PDF (titre, auteur, etc.) si présentes. */
  info?: Record<string, unknown>;
  /** Taille originale du fichier en octets. */
  byteLength: number;
}

/**
 * Extrait le texte d'un buffer PDF.
 * Throw si le PDF est invalide ou chiffré.
 *
 * Important : `require` dynamique pour éviter que webpack importe
 * pdf-parse dans le bundle client.
 */
export async function extractPdfText(
  buffer: Buffer,
): Promise<PdfExtractResult> {
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const pdfParse = require("pdf-parse") as (b: Buffer) => Promise<{
    text: string;
    numpages: number;
    info?: Record<string, unknown>;
  }>;

  const result = await pdfParse(buffer);
  return {
    text: result.text ?? "",
    pages: result.numpages ?? 0,
    info: result.info,
    byteLength: buffer.byteLength,
  };
}

/**
 * Normalise le texte extrait :
 *   - Convertit les CRLF en LF
 *   - Supprime les espaces multiples
 *   - Supprime les sauts de ligne triples ou plus (→ double)
 *   - Trim chaque ligne
 */
export function normalizePdfText(raw: string): string {
  return raw
    .replace(/\r\n/g, "\n")
    .replace(/\r/g, "\n")
    .split("\n")
    .map((line) => line.replace(/[ \t]+/g, " ").trim())
    .join("\n")
    .replace(/\n{3,}/g, "\n\n");
}
