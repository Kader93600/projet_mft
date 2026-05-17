// =====================================================================
// Helper de correction QR par Claude.
//
// Reçoit : la question (statement, expected_answer, scoring_grid, max_score)
//          la réponse du stagiaire
// Retourne : un score + appréciation + critères + confiance.
//
// Le helper est PUR : il ne touche pas la DB. C'est l'endpoint
// /api/tutor/grade-qr qui orchestre {lire QR → appeler ce helper →
// persister via set_qr_ai_grading}.
// =====================================================================

import { ask, CLAUDE_MODEL, estimateCostCents } from "./claude";
import { buildQrGradingSystem } from "./prompts";

export interface QrGradingInput {
  questionStatement: string;
  expectedAnswer: string | null;
  scoringGrid: string | null;
  maxScore: number;
  studentAnswer: string;
}

export interface QrGradingCriterion {
  name: string;
  weight: number;
  awarded: number;
}

export interface QrGradingResult {
  score: number;
  max_score: number;
  feedback_md: string;
  criteria: QrGradingCriterion[];
  confidence: "low" | "medium" | "high";
  concerns: string;
  model: string;
  tokens_in: number;
  tokens_out: number;
  cost_cents: number;
}

/**
 * Appelle Claude pour corriger une QR. Force un format JSON parsable
 * via le system prompt (cf. lib/tutor/prompts.ts). Si Claude retourne
 * du markdown autour du JSON, on tente d'extraire le bloc JSON.
 */
export async function gradeQrWithClaude(
  input: QrGradingInput
): Promise<QrGradingResult> {
  const system = buildQrGradingSystem({
    questionStatement: input.questionStatement,
    expectedAnswer: input.expectedAnswer,
    scoringGrid: input.scoringGrid,
    maxScore: input.maxScore,
  });

  const userMessage = `Réponse du stagiaire :

"""
${(input.studentAnswer ?? "").trim() || "(aucune réponse fournie)"}
"""

Note cette réponse selon les règles ci-dessus. Retourne UNIQUEMENT le JSON.`;

  const { text, inputTokens, outputTokens } = await ask({
    system,
    messages: [{ role: "user", content: userMessage }],
    maxTokens: 1024,
    temperature: 0.1, // basse temp = stable, reproductible
  });

  const parsed = extractJson(text);
  if (!parsed) {
    throw new Error(
      `Réponse Claude non-parsable. Brut (250 chars) : ${text.slice(0, 250)}`
    );
  }

  // Validation et bornes
  const maxScore = input.maxScore;
  const score = Math.max(
    0,
    Math.min(maxScore, Number(parsed.score ?? 0))
  );
  const feedback_md = String(parsed.feedback_md ?? "").trim();
  if (!feedback_md) {
    throw new Error("Feedback IA vide");
  }

  const confidence: "low" | "medium" | "high" =
    parsed.confidence === "low" ||
    parsed.confidence === "medium" ||
    parsed.confidence === "high"
      ? parsed.confidence
      : "medium";

  const criteria: QrGradingCriterion[] = Array.isArray(parsed.criteria)
    ? parsed.criteria
        .filter((c: any) => c && typeof c === "object")
        .map((c: any) => ({
          name: String(c.name ?? "").slice(0, 100),
          weight: Number(c.weight ?? 0),
          awarded: Number(c.awarded ?? 0),
        }))
    : [];

  return {
    score,
    max_score: maxScore,
    feedback_md,
    criteria,
    confidence,
    concerns: String(parsed.concerns ?? "").trim(),
    model: CLAUDE_MODEL,
    tokens_in: inputTokens,
    tokens_out: outputTokens,
    cost_cents: estimateCostCents(inputTokens, outputTokens),
  };
}

/**
 * Tente d'extraire un objet JSON d'une chaîne. Gère le cas où Claude
 * encadre le JSON par ```json ... ``` ou du texte autour.
 */
function extractJson(text: string): Record<string, unknown> | null {
  // Cas 1 : la chaîne entière est du JSON
  try {
    return JSON.parse(text);
  } catch {
    // continue
  }

  // Cas 2 : bloc markdown ```json ... ```
  const fenced = text.match(/```(?:json)?\s*([\s\S]*?)```/);
  if (fenced?.[1]) {
    try {
      return JSON.parse(fenced[1]);
    } catch {
      // continue
    }
  }

  // Cas 3 : 1er objet JSON détecté par balancing
  const firstBrace = text.indexOf("{");
  const lastBrace = text.lastIndexOf("}");
  if (firstBrace >= 0 && lastBrace > firstBrace) {
    try {
      return JSON.parse(text.slice(firstBrace, lastBrace + 1));
    } catch {
      // continue
    }
  }
  return null;
}
