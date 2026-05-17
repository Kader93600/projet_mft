// =====================================================================
// Wrapper Anthropic Claude — IA tuteur MFT
//
// Encapsule l'appel à Claude Sonnet 4 avec :
//   • System prompt MFT (lib/tutor/prompts.ts)
//   • Contexte RAG (top-N chunks de lesson_chunks)
//   • Streaming SSE pour /api/tutor/ask
//   • JSON structuré pour /api/tutor/grade-qr
//
// Côté coût (estimation 2026) :
//   - Sonnet 4 : 3 $/M tokens entrée, 15 $/M tokens sortie
//   - Question moyenne (~500 tokens prompt + ~1500 tokens contexte +
//     ~400 tokens réponse) ≈ 0,015 $ (1,5 ct).
// =====================================================================

import Anthropic from "@anthropic-ai/sdk";

/** Modèle Claude utilisé. Centralisé pour pouvoir basculer facilement. */
export const CLAUDE_MODEL = "claude-sonnet-4-20250514";

let _client: Anthropic | null = null;

/**
 * Singleton du client Anthropic. Throw si ANTHROPIC_API_KEY manquante
 * (vaut mieux échouer fort au démarrage que silencieusement à chaque
 * requête).
 */
export function getClaude(): Anthropic {
  if (_client) return _client;
  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey) {
    throw new Error(
      "ANTHROPIC_API_KEY manquante. Vérifie .env.local et redémarre le serveur."
    );
  }
  _client = new Anthropic({ apiKey });
  return _client;
}

export interface ChatMessage {
  role: "user" | "assistant";
  content: string;
}

export interface AskOptions {
  /** System prompt (RAG context inclus). */
  system: string;
  /** Historique de la conversation + dernier message user en fin. */
  messages: ChatMessage[];
  /** Limite de tokens en sortie (défaut: 1024). */
  maxTokens?: number;
  /** Température (défaut: 0.3 — réponses pédago plus stables). */
  temperature?: number;
  /** Signal d'abort (passé par /api/tutor/ask quand le client coupe). */
  signal?: AbortSignal;
}

/**
 * Demande une réponse complète (non-streamée). Utilisé pour la
 * correction QR (JSON parsable). Retourne le texte généré + métriques.
 */
export async function ask(opts: AskOptions): Promise<{
  text: string;
  inputTokens: number;
  outputTokens: number;
}> {
  const claude = getClaude();
  const response = await claude.messages.create(
    {
      model: CLAUDE_MODEL,
      system: opts.system,
      messages: opts.messages,
      max_tokens: opts.maxTokens ?? 1024,
      temperature: opts.temperature ?? 0.3,
    },
    { signal: opts.signal }
  );

  // Récupère le 1er bloc text. Claude peut renvoyer des tool_use ou
  // thinking blocks, on les ignore (pas utilisés ici).
  const text = response.content
    .filter((b) => b.type === "text")
    .map((b) => (b as { type: "text"; text: string }).text)
    .join("\n");

  return {
    text,
    inputTokens: response.usage.input_tokens,
    outputTokens: response.usage.output_tokens,
  };
}

/**
 * Stream une réponse via Server-Sent Events. Retourne un async iterable
 * de chunks textuels (à transmettre au client tels quels). Les
 * métriques sont émises sur le `onDone` callback à la fin du stream.
 */
export async function askStream(
  opts: AskOptions & {
    onDone?: (m: { inputTokens: number; outputTokens: number }) => void;
  }
): Promise<AsyncIterable<string>> {
  const claude = getClaude();
  const stream = claude.messages.stream(
    {
      model: CLAUDE_MODEL,
      system: opts.system,
      messages: opts.messages,
      max_tokens: opts.maxTokens ?? 1024,
      temperature: opts.temperature ?? 0.3,
    },
    { signal: opts.signal }
  );

  async function* toAsyncIterable(): AsyncIterable<string> {
    for await (const event of stream) {
      if (
        event.type === "content_block_delta" &&
        event.delta.type === "text_delta"
      ) {
        yield event.delta.text;
      }
    }
    // À la fin : on relit les métriques cumulées
    const finalMessage = await stream.finalMessage();
    opts.onDone?.({
      inputTokens: finalMessage.usage.input_tokens,
      outputTokens: finalMessage.usage.output_tokens,
    });
  }

  return toAsyncIterable();
}

// =====================================================================
// Estimation de coût (centimes EUR) à partir des tokens consommés.
//
// Tarifs Claude Sonnet 4 (mai 2026, à vérifier régulièrement) :
//   - Input  :  3 $ / 1M tokens   → 0,30 ct / 1k
//   - Output : 15 $ / 1M tokens   → 1,50 ct / 1k
//
// On stocke en centimes (int) ; on convertit en utilisant un taux $→€
// figé à 0.92 (pas critique, sert juste à monitorer l'ordre de grandeur).
// =====================================================================

const USD_TO_EUR = 0.92;
const COST_INPUT_PER_1K_USD = 0.003;
const COST_OUTPUT_PER_1K_USD = 0.015;

export function estimateCostCents(inputTokens: number, outputTokens: number): number {
  const usd =
    (inputTokens / 1000) * COST_INPUT_PER_1K_USD +
    (outputTokens / 1000) * COST_OUTPUT_PER_1K_USD;
  const eur = usd * USD_TO_EUR;
  return Math.ceil(eur * 100); // arrondi sup au centime
}
