// =====================================================================
// Découpage d'un contenu Markdown en chunks pour embedding RAG.
//
// Stratégie hybride :
//   1. Split d'abord par sections (titres ## ou ###).
//   2. Si une section > targetTokens, on la sous-coupe par paragraphes.
//   3. Si un paragraphe est encore trop long, on coupe sur caractères.
//   4. Overlap configurable entre chunks consécutifs (par défaut 50
//      tokens) pour préserver le contexte aux frontières.
//
// On n'utilise pas la lib tiktoken (lourde à installer + binaire natif) :
// on estime ~4 caractères = 1 token, c'est suffisant pour le RAG.
// =====================================================================

const CHARS_PER_TOKEN = 4;

export interface ChunkOptions {
  /** Cible en tokens par chunk (défaut 500). */
  targetTokens?: number;
  /** Overlap entre chunks consécutifs (défaut 50 tokens). */
  overlapTokens?: number;
}

export interface Chunk {
  /** Texte du chunk (Markdown nettoyé). */
  content: string;
  /** Tokens estimés. */
  tokenCount: number;
}

function estimateTokens(text: string): number {
  return Math.ceil(text.length / CHARS_PER_TOKEN);
}

/**
 * Découpe un contenu Markdown en chunks de ~targetTokens.
 *
 * Note : le contenu est compté caractère par caractère ; un overlap
 * exprimé en tokens est converti en caractères.
 */
export function chunkMarkdown(
  markdown: string,
  opts: ChunkOptions = {}
): Chunk[] {
  const target = opts.targetTokens ?? 500;
  const overlap = opts.overlapTokens ?? 50;
  const maxChars = target * CHARS_PER_TOKEN;
  const overlapChars = overlap * CHARS_PER_TOKEN;

  // Normalise : retire les blocs de code trop verbeux, supprime images
  const cleaned = markdown
    .replace(/```[\s\S]*?```/g, "")
    .replace(/!\[[^\]]*\]\([^)]*\)/g, "")
    .trim();

  if (cleaned.length === 0) return [];

  // Splits par sections Markdown (## ou ###). Si pas de titres, on
  // tombe sur un seul split (le texte entier) et la logique suivante
  // gère le découpage par paragraphes.
  const sections = cleaned
    .split(/\n(?=#{2,3}\s)/g)
    .map((s) => s.trim())
    .filter(Boolean);

  const chunks: Chunk[] = [];

  function pushFromText(text: string) {
    if (text.length === 0) return;
    if (text.length <= maxChars) {
      chunks.push({ content: text, tokenCount: estimateTokens(text) });
      return;
    }
    // Coupe par paragraphes
    const paragraphs = text.split(/\n{2,}/g);
    let buffer = "";
    for (const p of paragraphs) {
      if ((buffer + "\n\n" + p).length <= maxChars) {
        buffer = buffer ? buffer + "\n\n" + p : p;
        continue;
      }
      if (buffer) {
        chunks.push({ content: buffer, tokenCount: estimateTokens(buffer) });
        // Overlap : on garde les N derniers caractères en début du
        // prochain buffer pour préserver le contexte.
        buffer = buffer.slice(-overlapChars) + "\n\n" + p;
      } else {
        // Paragraphe trop long en soi : coupe brute.
        const slices = sliceByChars(p, maxChars, overlapChars);
        for (const slice of slices) {
          chunks.push({ content: slice, tokenCount: estimateTokens(slice) });
        }
      }
    }
    if (buffer) {
      chunks.push({ content: buffer, tokenCount: estimateTokens(buffer) });
    }
  }

  for (const section of sections) {
    pushFromText(section);
  }

  return chunks;
}

/**
 * Coupe une chaîne en tranches de `maxChars` avec un overlap.
 * Utilisé en dernier recours pour les paragraphes très longs.
 */
function sliceByChars(text: string, maxChars: number, overlap: number): string[] {
  const out: string[] = [];
  let start = 0;
  while (start < text.length) {
    const end = Math.min(text.length, start + maxChars);
    out.push(text.slice(start, end));
    if (end === text.length) break;
    start = end - overlap;
  }
  return out;
}
