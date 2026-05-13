// =====================================================================
// Parser de questions depuis un texte brut (PDF, paste, etc.).
//
// Stratégie : détection automatique de format. Trois familles supportées :
//
//   1. EXERCISE — "Exercice X.Y — Titre" / "CONTEXTE" / "TRAVAIL A RÉALISER"
//      (livrets d'exercices MFT). Chaque exercice → 1 QR avec contexte
//      intégré à l'énoncé.
//
//   2. QCM_QR  — "Q1./Question 1." + options "a)/b)/c)/d)" + "Réponse: B"
//      (quiz / examens blancs classiques).
//
//   3. NUMBERED — Liste numérotée simple "1./2./3." sans options
//      (questions ouvertes en série).
//
// La détection est faite par scan rapide ; le parser le plus permissif
// gagne, et l'admin peut toujours éditer le résultat dans l'UI avant
// d'insérer en DB.
// =====================================================================

export type DraftQuestionType = "qcm" | "qr";

export interface DraftChoice {
  letter: string;
  label: string;
  isCorrect: boolean;
}

export interface DraftQuestion {
  index: number;
  type: DraftQuestionType;
  statement: string;
  choices?: DraftChoice[];
  expectedAnswer?: string;
  scoringGrid?: string;
  maxScore: number;
  difficulty: "facile" | "moyen" | "difficile";
  tags: string[];
  explanation?: string;
  warnings: string[];
}

export interface ParseResult {
  questions: DraftQuestion[];
  summary: {
    total: number;
    qcm: number;
    qr: number;
    withCorrect: number;
    withWarnings: number;
    /** Format détecté : utile pour debugger côté UI. */
    detectedFormat: "exercise" | "qcm_qr" | "numbered" | "unknown";
  };
}

// ---------------------------------------------------------------------
// Patterns
// ---------------------------------------------------------------------

/** "Exercice 1.1", "Exercice 12.3 —", "EXERCICE N° 5 :" */
const EXERCISE_START_RE =
  /^\s*exercice\s*(?:n°\s*)?(\d+(?:\.\d+)?)\s*(?:[-—–:.]|$)\s*(.*)$/i;

/** "Q1.", "Question 1.", "Q 1 :", "1." */
const Q_START_RE =
  /^(?:(?:question\s*)?(?:Q\s*)?(\d{1,3}))(?:\s*[.\):\-–—])\s+(.+)$/i;

/** Options : "a)", "a.", "A.", "(a)", "□ a", etc. */
const OPTION_RE = /^[\s□☐○•▪]*\(?([a-eA-E])\)?\s*[.\)\-:]\s*(.*)$/;

const ANSWER_LINE_RE =
  /^(?:r[ée]ponse(?:s)?|correct(?:e)?(?:s)?|bonne(?:s)?\s*r[ée]ponse(?:s)?|solution|✓)\s*[:\-]?\s*(.+)$/i;

const SCORING_RE =
  /(?:bar[èe]me|notation|scoring)\s*[:\-]?\s*(.+)/i;

const MAX_SCORE_RE = /\/\s*(\d+(?:[.,]\d+)?)\s*pts?\b|\((\d+(?:[.,]\d+)?)\s*pts?\)/i;

const EXPECTED_RE =
  /^(?:r[ée]ponse\s*attendue|r[ée]ponse\s*mod[èe]le|[ée]l[ée]ments?\s*attendus?|corrig[ée])\s*[:\-]?\s*(.+)$/i;

const EXPLANATION_RE =
  /^(?:explication|commentaire|justification|pour\s*info)\s*[:\-]?\s*(.+)$/i;

const DIFFICULTY_RE = /\b(facile|moyen(?:ne)?|difficile|expert)\b/i;

const SECTION_HEADING_RE =
  /^(?:section|chapitre|partie|module|th[èe]me)\s*\d*\s*[:\-–—]?\s*(.+)$/i;

/** Footers et headers à nettoyer (répétés sur chaque page). */
const NOISE_LINE_REGEXES = [
  /^Page\s+\d+\s+sur\s+\d+\s*$/i,
  /^Page\s+\d+\/\d+\s*$/i,
  /^MFT\s*$/,
  /^\d+\s*$/, // numéro de page seul
];

// ---------------------------------------------------------------------
// Pré-traitement : enlève le bruit
// ---------------------------------------------------------------------

function cleanLines(rawText: string): string[] {
  const lines = rawText.replace(/\r\n?/g, "\n").split("\n");
  const cleaned: string[] = [];
  for (const raw of lines) {
    const line = raw.replace(/\s+/g, " ").trim();
    if (!line) {
      cleaned.push("");
      continue;
    }
    if (NOISE_LINE_REGEXES.some((re) => re.test(line))) continue;
    cleaned.push(line);
  }
  // Compresse les sauts de ligne triples
  const out: string[] = [];
  for (let i = 0; i < cleaned.length; i++) {
    if (cleaned[i] === "" && cleaned[i - 1] === "" && cleaned[i - 2] === "") continue;
    out.push(cleaned[i]);
  }
  return out;
}

// ---------------------------------------------------------------------
// Détection du format
// ---------------------------------------------------------------------

function detectFormat(lines: string[]): ParseResult["summary"]["detectedFormat"] {
  let exoCount = 0;
  let qCount = 0;
  let qDecimalCount = 0; // "1.1", "2.3" (décimal = sous-niveau)
  let optionCount = 0;
  let answerCount = 0;
  for (const l of lines) {
    if (EXERCISE_START_RE.test(l)) exoCount++;
    if (Q_START_RE.test(l)) qCount++;
    if (OPTION_RE.test(l)) optionCount++;
    if (ANSWER_LINE_RE.test(l)) answerCount++;
    if (/^\d+\.\d+\b/.test(l)) qDecimalCount++;
  }
  // Priorité 1 : livret d'exercices ("Exercice X.Y" ≥ 5 → format clair)
  // Les Q_START 1./2./3. trouvées sont en réalité des sous-questions :
  // on ne s'y fie pas tant qu'on voit beaucoup d'EXERCISE_START.
  if (exoCount >= 5) return "exercise";
  // Priorité 2 : QCM (présence d'options + de réponses explicites)
  if (optionCount >= 4 && (qCount >= 2 || answerCount >= 1)) return "qcm_qr";
  // Priorité 3 : exercice avec moins d'occurrences mais signature claire
  if (exoCount >= 2 && exoCount * 2 > qCount) return "exercise";
  // Priorité 4 : liste numérotée simple
  if (qCount >= 3) return "numbered";
  return "unknown";
}

// ---------------------------------------------------------------------
// Parser principal
// ---------------------------------------------------------------------

export function parseQuestions(rawText: string): ParseResult {
  const lines = cleanLines(rawText);
  const format = detectFormat(lines);

  let questions: DraftQuestion[];
  if (format === "exercise") {
    questions = parseExerciseFormat(lines);
  } else if (format === "qcm_qr" || format === "numbered") {
    questions = parseQuestionFormat(lines);
  } else {
    // Fallback : tente le format Q d'abord, sinon renvoie un seul bloc
    const tryQ = parseQuestionFormat(lines);
    if (tryQ.length > 0) {
      questions = tryQ;
    } else {
      // Tentative ultime : tout le texte comme une seule QR
      const joined = lines.join("\n").trim();
      if (joined.length > 20) {
        questions = [
          {
            index: 1,
            type: "qr",
            statement: joined.slice(0, 4000),
            maxScore: 2,
            difficulty: "moyen",
            tags: ["import-non-structure"],
            warnings: [
              "Format non détecté — l'intégralité du texte a été placée dans une seule question. Édite manuellement.",
            ],
          },
        ];
      } else {
        questions = [];
      }
    }
  }

  // Renumérote 1..N
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
      detectedFormat: format,
    },
  };
}

// ---------------------------------------------------------------------
// Format EXERCICE — "Exercice X.Y — Titre / CONTEXTE / TRAVAIL …"
// ---------------------------------------------------------------------

interface ExerciseBlock {
  ref: string; // "1.1", "1.2"
  title: string;
  bodyLines: string[];
}

function parseExerciseFormat(lines: string[]): DraftQuestion[] {
  const blocks: ExerciseBlock[] = [];
  let current: ExerciseBlock | null = null;

  for (const line of lines) {
    const m = line.match(EXERCISE_START_RE);
    if (m) {
      if (current) blocks.push(current);
      current = {
        ref: m[1],
        title: (m[2] ?? "").trim(),
        bodyLines: [],
      };
      continue;
    }
    if (current) current.bodyLines.push(line);
  }
  if (current) blocks.push(current);

  return blocks.map((blk, i) => exerciseToDraft(blk, i + 1));
}

function exerciseToDraft(blk: ExerciseBlock, index: number): DraftQuestion {
  const warnings: string[] = [];
  const tags: string[] = [];

  // Tag par chapitre (premier nombre de X.Y)
  const chapter = blk.ref.split(".")[0];
  if (chapter) tags.push(`chapitre-${chapter}`);
  tags.push(`exercice-${blk.ref.replace(".", "-")}`);

  // Sépare les sections : CONTEXTE / TRAVAIL / ANNEXE / etc.
  const text = blk.bodyLines
    .join("\n")
    .replace(/\n{2,}/g, "\n\n")
    .trim();

  // Détecte les sous-questions (1./2./3.) dans la zone TRAVAIL
  const subQuestionMatches = text.match(/^\s*\d+\.\s+.+/gm) ?? [];
  const subCount = subQuestionMatches.length;

  // Note max : 2 pts par sous-question si détectée, sinon 4 par défaut
  const maxScore = subCount > 0 ? subCount * 2 : 4;

  // Énoncé final : Titre + texte
  const statement =
    (blk.title ? `${blk.title}\n\n` : "") + text;

  if (statement.length < 30) {
    warnings.push("Énoncé court — vérifier le découpage.");
  }
  if (subCount === 0) {
    warnings.push("Pas de sous-questions numérotées détectées dans le corps.");
  }
  if (statement.length > 3500) {
    warnings.push(`Énoncé très long (${statement.length} car) — penser à découper.`);
  }

  return {
    index,
    type: "qr", // les livrets d'exercices sont des QR rédigées
    statement: statement.slice(0, 4000),
    expectedAnswer: undefined, // à compléter par le formateur
    scoringGrid: subCount > 0
      ? `Barème indicatif : ${subCount} sous-question(s) × 2 pts`
      : undefined,
    maxScore,
    difficulty: "moyen",
    tags,
    warnings,
  };
}

// ---------------------------------------------------------------------
// Format QCM/QR classique — Q1./Q2./... + options a)b)c)d)
// ---------------------------------------------------------------------

function parseQuestionFormat(lines: string[]): DraftQuestion[] {
  const blocks: { index: number; statementStart: string; bodyLines: string[]; section: string | null }[] = [];
  let current: typeof blocks[number] | null = null;
  let currentSection: string | null = null;

  for (const line of lines) {
    if (!line) {
      if (current) current.bodyLines.push("");
      continue;
    }

    const sectionMatch = line.match(SECTION_HEADING_RE);
    if (sectionMatch && !current) {
      currentSection = sectionMatch[1].trim();
      continue;
    }

    const qMatch = line.match(Q_START_RE);
    if (qMatch) {
      if (current) blocks.push(current);
      current = {
        index: parseInt(qMatch[1], 10),
        statementStart: qMatch[2].trim(),
        bodyLines: [],
        section: currentSection,
      };
      continue;
    }

    if (current) current.bodyLines.push(line);
  }
  if (current) blocks.push(current);

  return blocks.map((blk, i) => qBlockToDraft(blk, i + 1));
}

function qBlockToDraft(
  blk: { index: number; statementStart: string; bodyLines: string[]; section: string | null },
  outIndex: number,
): DraftQuestion {
  const warnings: string[] = [];
  const tags: string[] = [];
  if (blk.section) tags.push(slugify(blk.section));

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
      explanation = (explanation ?? "") + (explanation ? "\n" : "") + explMatch[1].trim();
      continue;
    }
    const scoringMatch = line.match(SCORING_RE);
    if (scoringMatch) {
      scoringGrid = scoringMatch[1].trim();
      const inlineMax = line.match(MAX_SCORE_RE);
      if (inlineMax) {
        detectedMaxScore = parseFloat((inlineMax[1] ?? inlineMax[2]).replace(",", "."));
      }
      continue;
    }

    const optMatch = line.match(OPTION_RE);
    if (optMatch && optMatch[2].length > 0 && line.length < 280) {
      const letter = optMatch[1].toLowerCase();
      const label = optMatch[2].trim();
      const isCorrect = /\*|✓|\(correct(?:e)?\)/i.test(label);
      choiceLines.push({
        letter,
        label: label.replace(/[\*✓]|\(correct(?:e)?\)/gi, "").trim(),
        isCorrect,
      });
      seenFirstChoice = true;
      continue;
    }

    if (!seenFirstChoice) {
      statementLines.push(line);
    } else if (choiceLines.length > 0) {
      choiceLines[choiceLines.length - 1].label += " " + line;
    }
  }

  const statement = [blk.statementStart, ...statementLines]
    .filter(Boolean)
    .join(" ")
    .trim();

  let difficulty: DraftQuestion["difficulty"] = "moyen";
  const diffMatch = (statement + " " + (explanation ?? "")).match(DIFFICULTY_RE);
  if (diffMatch) {
    const v = diffMatch[1].toLowerCase();
    if (v === "facile") difficulty = "facile";
    else if (v === "difficile" || v === "expert") difficulty = "difficile";
  }

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

  const type: DraftQuestionType = choiceLines.length >= 2 ? "qcm" : "qr";

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

  const maxScore = detectedMaxScore ?? (type === "qcm" ? 1 : 2);

  return {
    index: outIndex,
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

// ---------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------

function slugify(s: string): string {
  return s
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 40);
}
