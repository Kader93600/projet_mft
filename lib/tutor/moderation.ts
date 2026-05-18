// =====================================================================
// Modération pré-prompt via OpenAI Moderations API.
//
// Appelé AVANT chaque envoi à Claude dans /api/tutor/ask. Si la question
// du stagiaire est flaggée (haine, contenu sexuel, violence, etc.), on
// renvoie une réponse polie sans toucher au crédit Anthropic.
//
// L'API Moderations est GRATUITE chez OpenAI (omni-moderation-latest)
// donc on l'appelle systématiquement sans crainte de coût supplémentaire.
//
// Cas particulier "self-harm" : on ne refuse pas silencieusement mais
// on redirige avec empathie vers un point de contact humain. Important
// même dans un contexte éducation transport — un stagiaire en détresse
// peut formuler une demande déguisée.
//
// Spec OpenAI :
//   https://platform.openai.com/docs/guides/moderation
//   POST /v1/moderations { input, model }
//   Returns: { results: [{ flagged, categories, category_scores }] }
// =====================================================================

import { getOpenAI } from "./embeddings";

export type ModerationOutcome = "ok" | "blocked" | "self_harm";

export interface ModerationResult {
  outcome: ModerationOutcome;
  /** Liste des catégories qui ont déclenché le flag (vide si ok). */
  flagged_categories: string[];
  /** Message lisible à montrer au stagiaire si refusé. */
  user_message: string | null;
}

/** Modèle modération. `omni-moderation-latest` = multimodal + multilingue (FR OK). */
const MODERATION_MODEL = "omni-moderation-latest";

/**
 * Catégories considérées comme "self-harm" (traitement spécial avec
 * orientation vers aide humaine, pas un simple refus).
 */
const SELF_HARM_CATEGORIES = new Set([
  "self-harm",
  "self-harm/intent",
  "self-harm/instructions",
]);

const REFUSAL_MESSAGE_GENERIC =
  "Je ne peux pas répondre à ce message. Le tuteur est dédié aux questions sur vos modules de formation transport. Merci de reformuler votre question dans ce cadre.";

const REFUSAL_MESSAGE_SELF_HARM = `Votre message me préoccupe et je préfère ne pas y répondre via un chatbot.

Si vous traversez une période difficile, parlez à quelqu'un :
• Votre formateur ou coach pédagogique (via /accompagnement)
• Un proche
• Un professionnel : 3114 (numéro national de prévention du suicide, gratuit, 24h/24, anonyme, France)
• SOS Amitié : 09 72 39 40 50

Pour les questions sur vos modules de transport, je reste à votre disposition.`;

/**
 * Vérifie la modération d'une chaîne. Robuste aux erreurs réseau :
 * en cas d'échec de l'API OpenAI, on laisse passer la requête (fail-open)
 * pour ne pas couper le service. L'incident est loggé pour Sentry.
 */
export async function checkModeration(text: string): Promise<ModerationResult> {
  const cleaned = (text ?? "").trim();
  if (!cleaned || cleaned.length < 3) {
    return { outcome: "ok", flagged_categories: [], user_message: null };
  }

  let response;
  try {
    const openai = getOpenAI();
    response = await openai.moderations.create({
      model: MODERATION_MODEL,
      input: cleaned,
    });
  } catch (e: any) {
    // Fail-open : si l'API modération tombe, on laisse passer.
    // L'objectif est d'empêcher les abus, pas de couper le service.
    console.warn("[moderation] OpenAI API error — fail-open", {
      message: e?.message,
    });
    return { outcome: "ok", flagged_categories: [], user_message: null };
  }

  const result = response.results?.[0];
  if (!result || !result.flagged) {
    return { outcome: "ok", flagged_categories: [], user_message: null };
  }

  // Extraction des catégories actives. OpenAI type ses catégories
  // strictement, on contourne via `unknown` pour itérer génériquement.
  const categoriesRecord = (result.categories ?? {}) as unknown as Record<
    string,
    boolean
  >;
  const flaggedCategories = Object.entries(categoriesRecord)
    .filter(([, v]) => v === true)
    .map(([k]) => k);

  // Self-harm = orientation spéciale, pas un refus sec
  const isSelfHarm = flaggedCategories.some((c) =>
    SELF_HARM_CATEGORIES.has(c)
  );

  return isSelfHarm
    ? {
        outcome: "self_harm",
        flagged_categories: flaggedCategories,
        user_message: REFUSAL_MESSAGE_SELF_HARM,
      }
    : {
        outcome: "blocked",
        flagged_categories: flaggedCategories,
        user_message: REFUSAL_MESSAGE_GENERIC,
      };
}
