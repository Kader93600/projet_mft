// =====================================================================
// Parser de livrets de cours pédagogiques (PDF MFT).
//
// Détecte la structure CHAPITRE N → sous-sections N.M → contenu et
// génère un draft prêt pour l'éditeur riche.
//
// Format MFT standard (cf. COURS_CCP1/CCP2_GOTRM.pdf) :
//   CHAPITRE 1 — Titre du chapitre
//   1.1 — Sous-section
//     Texte du cours…
//     ❖ Item liste à puces
//     1. Item liste numérotée
//   ENCADRE REGLEMENTATION / A RETENIR / METHODE / EXEMPLE
//     Contenu de l'encadré (jusqu'à la prochaine sous-section)
//   1.2 — Sous-section suivante
//   …
//
// Tags d'encadrés reconnus côté UI (rendus avec un style spécifique) :
//   - A RETENIR             → blue
//   - ENCADRE REGLEMENTATION → blue stripe
//   - METHODE                → green
//   - EXEMPLE                → grey
// Pour le MVP on les rend en <blockquote class="callout callout-X">.
// =====================================================================

export interface DraftLesson {
  /** Référence "N.M" originale (ex. "1.1"). */
  ref: string;
  /** Titre nettoyé (sans "1.1 —"). */
  title: string;
  /** Contenu HTML prêt à coller dans TipTap. */
  contentHtml: string;
  /** Numéro de page de début dans le PDF source (1-based). */
  sourcePage?: number | null;
  /** Warnings non-bloquants (énoncé court, encadré orphelin…). */
  warnings: string[];
}

export interface DraftChapter {
  /** Numéro du chapitre (1, 2, … 12). */
  number: number;
  /** Titre du chapitre. */
  title: string;
  /** Slug auto-généré ("chapitre-1-la-sous-traitance"). */
  slug: string;
  /** Leçons de ce chapitre (1+). */
  lessons: DraftLesson[];
  /** Première page du chapitre dans le PDF. */
  sourcePage?: number | null;
}

export interface LessonParseResult {
  chapters: DraftChapter[];
  summary: {
    chapters: number;
    lessons: number;
    withWarnings: number;
    /** Format détecté pour debug UI. */
    detectedFormat: "course" | "unknown";
  };
}

// ---------------------------------------------------------------------
// Patterns
// ---------------------------------------------------------------------

const CHAPTER_RE = /^CHAPITRE\s+(\d{1,2})\s*[—\-–:]\s*(.+)$/i;
const SECTION_RE = /^(\d{1,2})\.(\d{1,2})\s*[—\-–:]\s*(.+)$/;
const CALLOUT_HEADERS = [
  { re: /^(A RETENIR|À RETENIR)\b\s*[:—\-]?\s*(.*)$/i, kind: "retain" as const },
  {
    re: /^(ENCADR[ÉE]?\s+R[ÉE]GLEMENTATION|R[ÉE]GLEMENTATION)\s*[:—\-]?\s*(.*)$/i,
    kind: "regulation" as const,
  },
  { re: /^(METHODE|MÉTHODE)\s*[—\-:]?\s*(.*)$/i, kind: "method" as const },
  { re: /^(EXEMPLE)\s*[—\-:]?\s*(.*)$/i, kind: "example" as const },
];

/** Lignes de bruit récurrentes à filtrer (footers/headers du PDF). */
const NOISE_LINE_REGEXES = [
  /^Page\s+\d+\s+sur\s+\d+\s*$/i,
  /^MFT\s*$/,
  /^LIVRET N°\d+\s+[—\-–]\s+TP.*$/i,
  /^\d+\s*$/,
];

// ---------------------------------------------------------------------
// Pré-traitement
// ---------------------------------------------------------------------

function cleanLines(rawText: string): string[] {
  const lines = rawText.replace(/\r\n?/g, "\n").split("\n");
  const out: string[] = [];
  for (const raw of lines) {
    const line = raw.replace(/[ \t]+/g, " ").trim();
    if (!line) {
      out.push("");
      continue;
    }
    if (NOISE_LINE_REGEXES.some((re) => re.test(line))) continue;
    out.push(line);
  }
  // Compresse les triples lignes vides
  const compressed: string[] = [];
  for (let i = 0; i < out.length; i++) {
    if (out[i] === "" && out[i - 1] === "" && out[i - 2] === "") continue;
    compressed.push(out[i]);
  }
  return compressed;
}

// ---------------------------------------------------------------------
// Parser principal
// ---------------------------------------------------------------------

/**
 * Parse un texte brut (extrait d'un PDF de cours) + le texte par page
 * pour la résolution des pages sources.
 */
export function parseLessons(
  rawText: string,
  pageTexts: string[] = [],
): LessonParseResult {
  const lines = cleanLines(rawText);
  const chapters: DraftChapter[] = [];

  let currentChapter: {
    number: number;
    title: string;
    lessons: DraftLesson[];
    bodyBuffer: string[];
    currentLesson: DraftLesson | null;
  } | null = null;

  const flushLesson = () => {
    if (!currentChapter?.currentLesson) return;
    const lesson = currentChapter.currentLesson;
    lesson.contentHtml = blockToHtml(currentChapter.bodyBuffer);
    if (lesson.contentHtml.length < 60) {
      lesson.warnings.push("Contenu très court — vérifier l'extraction.");
    }
    lesson.sourcePage = findSourcePage(pageTexts, `${lesson.ref}`) ?? null;
    currentChapter.lessons.push(lesson);
    currentChapter.bodyBuffer = [];
    currentChapter.currentLesson = null;
  };

  const flushChapter = () => {
    if (!currentChapter) return;
    flushLesson();
    if (currentChapter.lessons.length > 0) {
      chapters.push({
        number: currentChapter.number,
        title: currentChapter.title,
        slug: makeSlug(`chapitre-${currentChapter.number}`, currentChapter.title),
        lessons: currentChapter.lessons,
        sourcePage: findSourcePage(
          pageTexts,
          `CHAPITRE ${currentChapter.number}`,
        ),
      });
    }
    currentChapter = null;
  };

  for (const line of lines) {
    const chMatch = line.match(CHAPTER_RE);
    if (chMatch) {
      flushChapter();
      currentChapter = {
        number: parseInt(chMatch[1], 10),
        title: chMatch[2].trim(),
        lessons: [],
        bodyBuffer: [],
        currentLesson: null,
      };
      continue;
    }

    const secMatch = line.match(SECTION_RE);
    if (secMatch && currentChapter) {
      // Évite de matcher des sous-questions de cellule (ex "3. CONNAITRE…"
      // dans un tableau) : on n'accepte que si le préfixe correspond bien
      // au chapitre courant ET que la section a un titre clair (> 5 char).
      const chap = parseInt(secMatch[1], 10);
      const sec = parseInt(secMatch[2], 10);
      if (chap === currentChapter.number && secMatch[3].trim().length > 4) {
        flushLesson();
        currentChapter.currentLesson = {
          ref: `${chap}.${sec}`,
          title: secMatch[3].trim().replace(/[:.]$/, ""),
          contentHtml: "",
          sourcePage: null,
          warnings: [],
        };
        continue;
      }
    }

    if (currentChapter?.currentLesson) {
      currentChapter.bodyBuffer.push(line);
    }
  }
  flushChapter();

  return {
    chapters,
    summary: {
      chapters: chapters.length,
      lessons: chapters.reduce((s, c) => s + c.lessons.length, 0),
      withWarnings: chapters.reduce(
        (s, c) => s + c.lessons.filter((l) => l.warnings.length > 0).length,
        0,
      ),
      detectedFormat: chapters.length > 0 ? "course" : "unknown",
    },
  };
}

// ---------------------------------------------------------------------
// Conversion bloc texte → HTML (paragraphes, listes, encadrés)
// ---------------------------------------------------------------------

/**
 * Convertit une suite de lignes en HTML structuré. Détecte :
 *   - Encadrés (A RETENIR, REGLEMENTATION, METHODE, EXEMPLE)
 *   - Listes à puces (❖ - • ●)
 *   - Listes numérotées (1. 2. 3.)
 *   - Paragraphes
 */
export function blockToHtml(lines: string[]): string {
  const html: string[] = [];
  let i = 0;

  while (i < lines.length) {
    const line = lines[i];

    if (!line.trim()) {
      i++;
      continue;
    }

    // Encadré : ligne de header callout → on lit jusqu'à la prochaine
    // ligne vide suivie d'une ligne sans indentation.
    const calloutMatch = matchCallout(line);
    if (calloutMatch) {
      const { kind, headerLabel, rest } = calloutMatch;
      const calloutLines: string[] = rest ? [rest] : [];
      i++;
      while (i < lines.length) {
        const next = lines[i];
        // Stop si on rencontre un nouveau callout ou une section/chapitre
        if (matchCallout(next) || CHAPTER_RE.test(next) || SECTION_RE.test(next)) {
          break;
        }
        // Stop si on a 2 lignes vides consécutives
        if (
          next === "" &&
          (lines[i + 1] === "" || lines[i + 1] === undefined)
        ) {
          i++;
          break;
        }
        calloutLines.push(next);
        i++;
      }
      html.push(renderCallout(kind, headerLabel, calloutLines));
      continue;
    }

    // Liste à puces : commence par ❖, ●, •, *, -
    if (/^[❖❖●•\*]\s+/.test(line) || /^-\s+\S/.test(line)) {
      const items: string[] = [];
      while (i < lines.length && /^[❖❖●•\*\-]\s+/.test(lines[i])) {
        items.push(lines[i].replace(/^[❖❖●•\*\-]\s+/, "").trim());
        i++;
        // Continuation possible sur ligne suivante (indentation préservée)
        while (i < lines.length && /^\s{2,}\S/.test(lines[i])) {
          items[items.length - 1] += " " + lines[i].trim();
          i++;
        }
      }
      html.push(
        `<ul>${items.map((it) => `<li>${escapeHtml(it)}</li>`).join("")}</ul>`,
      );
      continue;
    }

    // Liste numérotée : "1. " "2. " "3. "
    if (/^\d{1,2}\.\s+/.test(line) && !SECTION_RE.test(line)) {
      const items: string[] = [];
      while (
        i < lines.length &&
        /^\d{1,2}\.\s+/.test(lines[i]) &&
        !SECTION_RE.test(lines[i])
      ) {
        items.push(lines[i].replace(/^\d{1,2}\.\s+/, "").trim());
        i++;
      }
      html.push(
        `<ol>${items.map((it) => `<li>${escapeHtml(it)}</li>`).join("")}</ol>`,
      );
      continue;
    }

    // Sinon : paragraphe (jusqu'à la prochaine ligne vide / liste / encadré)
    const paragraphLines: string[] = [line];
    i++;
    while (i < lines.length) {
      const next = lines[i];
      if (
        !next.trim() ||
        matchCallout(next) ||
        /^[❖❖●•\*]\s+/.test(next) ||
        /^-\s+\S/.test(next) ||
        /^\d{1,2}\.\s+/.test(next) ||
        CHAPTER_RE.test(next) ||
        SECTION_RE.test(next)
      ) {
        break;
      }
      paragraphLines.push(next);
      i++;
    }
    const text = paragraphLines.join(" ").trim();
    if (text) html.push(`<p>${escapeHtml(text)}</p>`);
  }

  return html.join("\n");
}

// ---------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------

type CalloutKind = "retain" | "regulation" | "method" | "example";

function matchCallout(
  line: string,
): { kind: CalloutKind; headerLabel: string; rest: string } | null {
  for (const c of CALLOUT_HEADERS) {
    const m = line.match(c.re);
    if (m) {
      return {
        kind: c.kind,
        headerLabel: m[1].trim(),
        rest: (m[2] ?? "").trim(),
      };
    }
  }
  return null;
}

function renderCallout(
  kind: CalloutKind,
  headerLabel: string,
  bodyLines: string[],
): string {
  // Filtre les lignes vides redondantes du body
  const body = bodyLines.filter((l) => l.trim().length > 0);

  // Recompose le HTML interne via blockToHtml pour gérer les listes
  // imbriquées dans le callout (ex. ENCADRE REGLEMENTATION avec puces)
  const inner = blockToHtml(body);

  const tone = {
    retain: { bg: "#EEF6FF", border: "#2563EB", icon: "💡" },
    regulation: { bg: "#F0F4FF", border: "#1D4ED8", icon: "⚖️" },
    method: { bg: "#ECFDF5", border: "#059669", icon: "🛠️" },
    example: { bg: "#F9FAFB", border: "#6B7280", icon: "💼" },
  }[kind];

  return `<blockquote data-callout="${kind}" style="border-left:4px solid ${tone.border};background:${tone.bg};padding:8px 14px;margin:12px 0;border-radius:8px;"><p><strong>${tone.icon} ${escapeHtml(headerLabel)}</strong></p>${inner}</blockquote>`;
}

function escapeHtml(s: string): string {
  return s
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}

function makeSlug(prefix: string, title: string): string {
  const base = title
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 50);
  return `${prefix}-${base}`.replace(/^-+|-+$/g, "");
}

/**
 * Cherche dans quelle page d'un PDF apparaît une référence donnée.
 */
function findSourcePage(pageTexts: string[], needle: string): number | null {
  const norm = (s: string) =>
    s.toLowerCase().replace(/[''`]/g, "'").replace(/\s+/g, " ").trim();
  const target = norm(needle);
  if (!target || target.length < 3) return null;
  for (let i = 0; i < pageTexts.length; i++) {
    if (norm(pageTexts[i]).includes(target)) return i + 1;
  }
  return null;
}
