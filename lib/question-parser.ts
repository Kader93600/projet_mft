// =====================================================================
// Parser de questions depuis un texte brut (PDF, paste, etc.).
//
// Stratégie : "best effort" heuristique. Détecte les patterns courants
// (numérotation, options a/b/c/d, "Réponse:", barème) et renvoie une
// liste de DraftQuestion que l'admin peut ensuite éditer dans l'UI.
//
// Conçu pour les PDFs "mixtes" : il ne plante jamais, il fait juste
// confiance à l'admin pour vérifier/corriger avant l'insert final.
//
// Aucune dépendance, isomorphe (utilisable depuis API route ET client).
// =====================================================================

export type DraftQuestionType = "qcm" | "qr";

export interface DraftChoice {
  /** Lettre originale parsée (a, b, c, d, A, B, …). */
  letter: string;
  /** Texte de l'option. */
  label: string;
  /** Marquée correcte dans le PDF ? */
  isCorrect: boolean;
}

export interface DraftQuestion {
  /** Index dans la séquence (1-based, conservé pour ré-ordonnancement). */
  index: number;
  /** Type détecté. QCM si options trouvées, sinon QR. */
  type: DraftQuestionType;
  /** Énoncé (peut contenir du multi-lignes). */
  statement: string;
  /** QCM uniquement. */
  choices?: DraftChoice[];
  /** QR uniquement : réponse-modèle / éléments attendus. */
  expectedAnswer?: string;
  /** QR uniquement : barème de notation. */
  scoringGrid?: string;
  /** Note maximale (par défaut 1 pour QCM, parsée depuis "/X pts" pour QR). */
  maxScore: number;
  /** Difficulté détectée par mots-clés. */
  difficulty: "facile" | "moyen" | "difficile";
  /** Tags suggérés (depuis titres de section trouvés en amont). */
  tags: string[];
  /** Explication / corrigé court si détecté. */
  explanation?: string;
  /** Warnings non-bloquants à montrer à l'admin (ex. "pas de réponse correcte trouvée"). */
  warnings: string[];
}

export interface ParseResult {
  questions: DraftQuestion[];
  /** Résumé pour affichage : 12 QCM, 3 QR, 2 warnings, etc. */
  summary: {
    total: number;
    qcm: number;
    qr: number;
    withCorrect: number;
    withWarnings: number;
  };
}

// ---------------------------------------------------------------------
// Heuristiques regex
// ---------------------------------------------------------------------

/**
 * Détecte le début d'une question. Couvre :
 *   - "Question 1." / "Question 1 -" / "Question 1 :"
 *   - "Q1." / "Q1 -" / "Q1:" / "Q 1."
 *   - "1." / "1)" / "1-" en début de ligne
 *   - Numérotation à 2-3 chiffres
 */
const Q_START_RE =
  /^(?:(?:question\s*)?(?:Q\s*)?(\d{1,3}))(?:\s*[.\):\-–—])\s+(.*)$/i;

/** Détecte une ligne d'option : "a)", "a.", "A.", "□", "☐", "○", "(a)" */
const OPTION_RE =
  /^\(?([a-eA-E])\)?\s*[.\)\-:]?\s*(.*)$/;

/** Détecte un marqueur de bonne réponse explicite : "Réponse: B" / "Correct: a,c" */
const ANSWER_LINE_RE =
  /^(?:r[ée]ponse(?:s)?|correct(?:e)?(?:s)?|bonne(?:s)?\s*r[ée]ponse(?:s)?|solution|✓)\s*[:\-]?\s*(.+)$/i;

/** Marqueur barème : "Barème: …" / "/5" / "(5 points)" */
const SCORING_RE =
  /(?:bar[èe]me|notation|scoring)\s*[:\-]?\s*(.+)/i;

const MAX_SCORE_RE = /\/\s*(\d+(?:[.,]\d+)?)\s*pts?\b|\((\d+(?:[.,]\d+)?)\s*pts?\)/i;

/** Marqueur réponse-modèle / éléments attendus pour QR. */
const EXPECTED_RE =
  /^(?:r[ée]ponse\s*attendue|r[ée]ponse\s*mod[èe]le|[ée]l[ée]ments?\s*attendus?|corrig[ée])\s*[:\-]?\s*(.+)$/i;

/** Explication / commentaire post-question. */
const EXPLANATION_RE =
  /^(?:explication|commentaire|justification|pour\s*info)\s*[:\-]?\s*(.+)$/i;

/** Difficulté indiquée explicitement. */
const DIFFICULTY_RE = /\b(facile|moyen(?:ne)?|difficile|expert)\b/i;

/** Titre de section : majuscules continues, ou "Section N", "Chapitre N", "Partie N". */
const SECTION_HEADING_RE =
  /^(?:section|chapitre|partie|module|th[èe]me)\s*\d*\s*[:\-–—]?\s*(.+)$/i;

// ---------------------------------------------------------------------
// Parse principal
// ---------------------------------------------------------------------

/**
 * Découpe un texte brut en DraftQuestion.
 *
 * Algorithme :
 *   1. Pré-traitement : normalise les sauts de ligne.
 *   2. Détection des "ancres" de début de question (Q_START_RE).
 *   3. Pour chaque ancre, on récupère le bloc jusqu'à la prochaine ancre.
 *   4. À l'intérieur du bloc : on identifie les options, l'énoncé,
 *      la réponse, le barème, l'explication.
 *   5. Si aucune option trouvée → c'est une QR.
 *
 * Robuste aux PDFs imparfaits : ne plante jamais, accumule des warnings.
 */
export function parseQuestions(rawText: string): ParseResult {
  const lines = rawText.replace(/\r\n?/g, "\n").split("\n");
  const blocks: { index: number; statementStart: string; bodyLines: string[] }[] = [];

  let currentBlock: { index: number; statementStart: string; bodyLines: string[] } | null = null;
  let currentSection: string | null = null;
  const sectionsForBlocks: (string | null)[] = [];

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();
    if (!line) {
      if (currentBlock) currentBlock.bodyLines.push("");
      continue;
    }

    // Capture des titres de sections (avant les premières questions)
    const sectionMatch = line.match(SECTION_HEADING_RE);
    if (sectionMatch && !currentBlock) {
      currentSection = sectionMatch[1].trim();
      continue;
    }

    const qMatch = line.match(Q_START_RE);
    if (qMatch) {
      // Ferme le bloc précédent
      if (currentBlock) {
        blocks.push(currentBlock);
        sectionsForBlocks.push(currentSection);
      }
      const idx = parseInt(qMatch[1], 10);
      currentBlock = {
        index: idx,
        statementStart: qMatch[2].trim(),
        bodyLines: [],
      };
      continue;
    }

    if (currentBlock) {
      currentBlock.bodyLines.push(line);
    }
  }
  if (currentBlock) {
    blocks.push(currentBlock);
    sectionsForBlocks.push(currentSection);
  }

  const questions: DraftQuestion[] = blocks.map((blk, i) =>
    blockToDraft(blk, sectionsForBlocks[i]),
  );

  // Renumérote 1..N pour cohérence affichage (les indices originaux du PDF
  // sont conservés via blk.index, mais on les remap à 1..N).
  const renumbered = questions.map((q, i) => ({ ...q, index: i + 1 }));

  return {
    questions: renumbered,
    summary: {
      total: renumbered.length,
      qcm: renumbered.filter((q) => q.type === "qcm").length,
      qr: renumbered.filter((q) => q.type === "qr").length,
      withCorrect: renumbered.filter(
        (q) => q.type === "qcm" && q.choices?.some((c) => c.isCorrect),
      ).length,
      withWarnings: renumbered.filter((q) => q.warnings.length > 0).length,
    },
  };
}

// ---------------------------------------------------------------------
// Bloc → DraftQuestion
// ---------------------------------------------------------------------

function blockToDraft(
  blk: { index: number; statementStart: string; bodyLines: string[] },
  section: string | null,
): DraftQuestion {
  const warnings: string[] = [];
  const tags: string[] = [];
  if (section) tags.push(slugifySection(section));

  // Sépare les lignes du body en : énoncé (avant 1ère option), options,
  // métadonnées (Réponse, Barème, Explication).
  const statementLines: string[] = [];
  const choiceLines: { letter: string; label: string; isCorrect: boolean }[] = [];
  let answerLine: string | null = null;
  let expectedAnswer: string | null = null;
  let scoringGrid: string | null = null;
  let explanation: string | null = null;
  let detectedMaxScore: number | null = null;

  let seenFirstChoice = false;

  for (const line of blk.bodyLines) {
    if (!line.trim()) continue;

    // Marqueurs métadonnées prioritaires
    const ansMatch = line.match(ANSWER_LINE_RE);
    if (ansMatch) {
      answerLine = ansMatch[1].trim();
      continue;
    }
    const expMatch = line.match(EXPECTED_RE);
    if (expMatch) {
      expectedAnswer = (expectedAnswer ?? "") + (expectedAnswer ? "\n" : "") + expMatch[1].trim();
      continue;
    }
    const explMatch = line.match(EXPLANATION_RE);
    if (explMatch) {
      explanation =
        (explanation ?? "") + (explanation ? "\n" : "") + explMatch[1].trim();
      continue;
    }
    const scoringMatch = line.match(SCORING_RE);
    if (scoringMatch) {
      scoringGrid = scoringMatch[1].trim();
      // Si on trouve "/5 pts" dans le barème, on capture max
      const inlineMax = line.match(MAX_SCORE_RE);
      if (inlineMax) {
        detectedMaxScore = parseFloat(
          (inlineMax[1] ?? inlineMax[2]).replace(",", "."),
        );
      }
      continue;
    }

    // Option (a/b/c/d/…)
    const optMatch = line.match(OPTION_RE);
    if (optMatch && optMatch[2].length > 0 && line.length < 240) {
      // Filtre : exclut les phrases qui commencent juste par "a" mais
      // ne sont pas des options (heuristique : option suivie d'un ".)-:")
      // est déjà couverte par le pattern. On exige aussi qu'il y ait un
      // séparateur après la lettre OU que la lettre soit isolée.
      const letter = optMatch[1].toLowerCase();
      const label = optMatch[2].trim();
      // Marqueur de bonne réponse en ligne : étoile, croix, "(correct)"
      const isCorrect = /\*|✓|\(correct(?:e)?\)/i.test(label);
      choiceLines.push({
        letter,
        label: label.replace(/[\*✓]|\(correct(?:e)?\)/gi, "").trim(),
        isCorrect,
      });
      seenFirstChoice = true;
      continue;
    }

    // Sinon : continuation de l'énoncé (avant 1ère option uniquement)
    if (!seenFirstChoice) {
      statementLines.push(line);
    } else {
      // Continuation d'une option (multi-lignes)
      if (choiceLines.length > 0) {
        choiceLines[choiceLines.length - 1].label += " " + line;
      }
    }
  }

  // Construit l'énoncé final
  const statement = [blk.statementStart, ...statementLines]
    .filter((s) => s.length > 0)
    .join(" ")
    .trim();

  // Difficulté détectée
  let difficulty: DraftQuestion["difficulty"] = "moyen";
  const diffMatch = (statement + " " + (explanation ?? "")).match(DIFFICULTY_RE);
  if (diffMatch) {
    const v = diffMatch[1].toLowerCase();
    if (v === "facile") difficulty = "facile";
    else if (v === "difficile" || v === "expert") difficulty = "difficile";
  }

  // Marque les bonnes réponses depuis "Réponse: B" ou "Correct: a, c"
  if (answerLine && choiceLines.length > 0) {
    const correctLetters = answerLine
      .toLowerCase()
      .replace(/\s/g, "")
      .split(/[,\/;]/)
      .map((s) => s.replace(/[^a-e]/g, ""))
      .filter((s) => s.length === 1);
    for (const c of choiceLines) {
      if (correctLetters.includes(c.letter)) c.isCorrect = true;
    }
  }

  // Déduit le type
  const type: DraftQuestionType = choiceLines.length >= 2 ? "qcm" : "qr";

  // Warnings
  if (type === "qcm" && !choiceLines.some((c) => c.isCorrect)) {
    warnings.push("Aucune bonne réponse détectée — à marquer à la main.");
  }
  if (type === "qr" && !expectedAnswer) {
    warnings.push("Pas de réponse-modèle détectée — penser à l'ajouter.");
  }
  if (statement.length < 10) {
    warnings.push("Énoncé très court — vérifier l'extraction.");
  }
  if (type === "qcm" && choiceLines.length > 6) {
    warnings.push(`${choiceLines.length} options détectées — vérifier le découpage.`);
  }

  // Max score
  const maxScore =
    detectedMaxScore ?? (type === "qcm" ? 1 : 2); // default QR = 2 points

  return {
    index: blk.index,
    type,
    statement,
    choices: type === "qcm" ? choiceLines : undefined,
    expectedAnswer: expectedAnswer ?? undefined,
    scoringGrid: scoringGrid ?? undefined,
    maxScore,
    difficulty,
    tags,
    explanation: explanation ?? undefined,
    warnings,
  };
}

function slugifySection(section: string): string {
  return section
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 40);
}
