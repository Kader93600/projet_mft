// =====================================================================
// Wrapper OpenAI text-embedding-3-small — IA tuteur MFT
//
// On utilise OpenAI uniquement pour la vectorisation. Le LLM
// principal est Claude (cf. lib/tutor/claude.ts).
//
// Raisons :
//   • text-embedding-3-small est rapide (~5-10 ms) et peu cher
//     (0,02 $ / 1M tokens). 1536 dimensions compatibles pgvector.
//   • Anthropic ne fournit pas (encore) d'API embeddings publique.
//
// Note : si on veut basculer sur Mistral / Voyage AI plus tard pour
// la souveraineté FR, il suffit de remplacer ce wrapper. Le reste de
// l'app (search_lesson_chunks, scripts d'ingestion) reste inchangé.
// =====================================================================

import OpenAI from "openai";

export const EMBEDDING_MODEL = "text-embedding-3-small";
export const EMBEDDING_DIM = 1536;

let _client: OpenAI | null = null;

export function getOpenAI(): OpenAI {
  if (_client) return _client;
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error(
      "OPENAI_API_KEY manquante. Vérifie .env.local et redémarre le serveur."
    );
  }
  _client = new OpenAI({ apiKey });
  return _client;
}

/**
 * Calcule l'embedding d'une chaîne unique. Utilisé côté /api/tutor/ask
 * pour vectoriser la question du stagiaire avant la recherche RAG.
 */
export async function embedOne(text: string): Promise<number[]> {
  const openai = getOpenAI();
  const cleaned = text.replace(/\s+/g, " ").trim();
  if (!cleaned) {
    return new Array(EMBEDDING_DIM).fill(0);
  }
  const res = await openai.embeddings.create({
    model: EMBEDDING_MODEL,
    input: cleaned,
  });
  return res.data[0].embedding;
}

/**
 * Calcule des embeddings en batch. À utiliser depuis le script
 * d'ingestion (`scripts/ingest-lessons-embeddings.ts`).
 *
 * OpenAI accepte ~2048 inputs / call mais on reste à 100 pour limiter
 * la pression mémoire et faciliter les retry.
 */
export async function embedBatch(texts: string[]): Promise<number[][]> {
  if (texts.length === 0) return [];
  const openai = getOpenAI();
  const cleaned = texts.map((t) => t.replace(/\s+/g, " ").trim() || " ");
  const res = await openai.embeddings.create({
    model: EMBEDDING_MODEL,
    input: cleaned,
  });
  // L'ordre est garanti par OpenAI : data[i] correspond à input[i]
  return res.data.map((d) => d.embedding);
}

/**
 * Coût des embeddings (cents EUR). Tarif text-embedding-3-small :
 * 0,02 $ / 1M tokens. Estimation tokens = ~0,25 par caractère.
 */
export function estimateEmbeddingCostCents(charCount: number): number {
  const tokens = Math.ceil(charCount / 4);
  const usd = (tokens / 1_000_000) * 0.02;
  return Math.ceil(usd * 0.92 * 100);
}
