// =====================================================================
// Génération IA de questions QCM depuis le contenu d'une leçon.
//
// Partie PURE (testable, sans dépendance réseau/DB) :
//   - buildQuestionGenSystem : construit le system prompt.
//   - parseGeneratedQuestions : parse + valide la réponse de Claude
//     (tolère le JSON encadré de markdown ; ignore les questions mal
//     formées plutôt que tout rejeter).
//
// L'action serveur (app/.../ai-actions.ts) orchestre : lit la leçon →
// appelle Claude (lib/tutor/claude) → parse ici → insère des BROUILLONS
// (active=false) dans question_bank, soumis à validation humaine.
// =====================================================================

export type Difficulty = "facile" | "moyen" | "difficile";

export interface GeneratedChoice {
  label: string;
  is_correct: boolean;
}

export interface GeneratedQuestion {
  statement: string;
  choices: GeneratedChoice[];
  explanation: string;
  difficulty: Difficulty;
}

const DIFFICULTIES: Difficulty[] = ["facile", "moyen", "difficile"];

/** System prompt : force un JSON strict, en français, pédagogiquement sûr. */
export function buildQuestionGenSystem(opts: {
  count: number;
  formationTitle?: string | null;
}): string {
  const ctx = opts.formationTitle
    ? ` Les questions s'adressent à des stagiaires de la formation « ${opts.formationTitle} ».`
    : "";
  return `Tu es un concepteur pédagogique expert en formation professionnelle (transport).${ctx}
À partir du CONTENU DE LEÇON fourni par l'utilisateur, génère ${opts.count} questions à choix multiples (QCM) en français.

Règles STRICTES :
- Chaque question porte UNIQUEMENT sur des éléments présents dans le contenu fourni (pas d'invention).
- Exactement 4 propositions par question, dont UNE SEULE correcte.
- Propositions plausibles (pas de réponse évidente ni absurde).
- Ajoute une "explanation" courte justifiant la bonne réponse.
- Varie la difficulté ("facile" | "moyen" | "difficile").

Réponds UNIQUEMENT avec un objet JSON valide, sans texte autour, de la forme :
{"questions":[{"statement":"...","choices":[{"label":"...","is_correct":true},{"label":"...","is_correct":false},{"label":"...","is_correct":false},{"label":"...","is_correct":false}],"explanation":"...","difficulty":"moyen"}]}`;
}

/** Construit le message utilisateur (contenu de leçon tronqué). */
export function buildQuestionGenUserMessage(
  lessonTitle: string,
  contentMd: string,
  maxChars = 6000,
): string {
  const content = (contentMd ?? "").slice(0, maxChars);
  return `Titre de la leçon : ${lessonTitle}

Contenu :
"""
${content}
"""

Génère les QCM selon les règles. Retourne UNIQUEMENT le JSON.`;
}

/** Extrait un objet JSON d'une réponse (gère ```json ... ``` et le texte autour). */
function extractJsonObject(text: string): Record<string, unknown> | null {
  try {
    return JSON.parse(text);
  } catch {
    /* continue */
  }
  const fenced = text.match(/```(?:json)?\s*([\s\S]*?)```/);
  if (fenced?.[1]) {
    try {
      return JSON.parse(fenced[1]);
    } catch {
      /* continue */
    }
  }
  const first = text.indexOf("{");
  const last = text.lastIndexOf("}");
  if (first >= 0 && last > first) {
    try {
      return JSON.parse(text.slice(first, last + 1));
    } catch {
      /* continue */
    }
  }
  return null;
}

/**
 * Parse + valide la réponse de Claude. Ne garde que les QCM bien formés :
 * énoncé non vide, 2 à 6 propositions, EXACTEMENT une correcte. Les autres
 * sont ignorées (on préfère 3 bonnes questions à 5 douteuses).
 */
export function parseGeneratedQuestions(raw: string): GeneratedQuestion[] {
  const obj = extractJsonObject(raw);
  if (!obj) return [];
  const arr = Array.isArray((obj as any).questions)
    ? (obj as any).questions
    : Array.isArray(obj)
      ? (obj as unknown as any[])
      : [];

  const out: GeneratedQuestion[] = [];
  for (const q of arr) {
    if (!q || typeof q !== "object") continue;
    const statement = String((q as any).statement ?? "").trim();
    if (statement.length < 3) continue;

    const rawChoices = Array.isArray((q as any).choices)
      ? (q as any).choices
      : [];
    const choices: GeneratedChoice[] = rawChoices
      .filter((c: any) => c && typeof c === "object")
      .map((c: any) => ({
        label: String(c.label ?? "").trim(),
        is_correct: c.is_correct === true,
      }))
      .filter((c: GeneratedChoice) => c.label.length > 0);

    if (choices.length < 2 || choices.length > 6) continue;
    const correctCount = choices.filter((c) => c.is_correct).length;
    if (correctCount !== 1) continue; // exactement une bonne réponse

    const difficulty: Difficulty = DIFFICULTIES.includes(
      (q as any).difficulty,
    )
      ? (q as any).difficulty
      : "moyen";

    out.push({
      statement,
      choices,
      explanation: String((q as any).explanation ?? "").trim(),
      difficulty,
    });
  }
  return out;
}
