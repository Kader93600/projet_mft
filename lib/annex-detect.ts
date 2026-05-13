// =====================================================================
// Détection des annexes dans un PDF.
//
// Une annexe est une section secondaire référencée depuis le corps
// principal (souvent un tableau, un schéma, ou des données numériques
// pour résoudre un exercice).
//
// Stratégie :
//   1. Parcourt le texte de chaque page.
//   2. Une page est considérée comme "annexe" si elle contient un
//      titre ANNEXE / Annexe N° / ANNEXE 1 — ... au début ou si elle
//      ne contient pas de texte de cours normal (heuristique de longueur).
//   3. Pour chaque énoncé de question, détecte les références
//      ("Annexe 1", "Voir annexe 2", "Cf. annexe A") et résout vers
//      les pages où ces annexes se trouvent.
//
// Limites :
//   - Pas d'OCR (PDFs scannés → texte vide → annexes invisibles).
//   - Si la mise en page met le titre ANNEXE en bas de page, on rate.
// =====================================================================

export interface AnnexPage {
  /** Numéro de page (1-based). */
  pageNumber: number;
  /** Libellé extrait ("Annexe 1", "ANNEXE 2 — barème", etc.). */
  label: string;
  /** Référence canonique pour matching ("1", "A", "principale", etc.). */
  ref: string;
}

const ANNEX_TITLE_RES = [
  /^\s*(?:ANNEXE|Annexe)\s*(?:N[°o]\s*)?([A-Z]|\d+)?\s*[—\-:]?\s*(.{0,200})$/m,
];

const ANNEX_REF_IN_TEXT_RE =
  /\b(?:cf\.?\s*|voir\s+)?annexe\s*(?:n[°o]\s*)?([A-Z]|\d+)/gi;

/**
 * Identifie les pages d'annexes dans un tableau de texte par page.
 */
export function detectAnnexPages(pageTexts: string[]): AnnexPage[] {
  const result: AnnexPage[] = [];

  for (let i = 0; i < pageTexts.length; i++) {
    const pageText = pageTexts[i];
    if (!pageText) continue;

    // Tente de trouver un titre d'annexe dans les ~30 premières lignes
    // (les annexes ont leur titre en haut de page).
    const top = pageText.split("\n").slice(0, 30).join("\n");

    for (const re of ANNEX_TITLE_RES) {
      const m = top.match(re);
      if (m) {
        const num = (m[1] ?? "").trim();
        const after = (m[2] ?? "").trim();
        const label = num
          ? `Annexe ${num}${after ? ` — ${after}` : ""}`
          : `Annexe${after ? ` — ${after}` : ""}`;
        result.push({
          pageNumber: i + 1,
          label: label.slice(0, 120),
          ref: (num || "principale").toLowerCase(),
        });
        break; // une seule annexe par page (cas usuel)
      }
    }
  }

  // Dédoublonne par page (si une page mentionne "Annexe X" 2× au début)
  const seen = new Set<number>();
  return result.filter((a) => {
    if (seen.has(a.pageNumber)) return false;
    seen.add(a.pageNumber);
    return true;
  });
}

/**
 * Détecte les références d'annexes citées dans un énoncé.
 * Renvoie la liste des refs ('1', 'A', '2') trouvées, dédupliquées
 * et minuscules.
 */
export function findAnnexRefsInStatement(statement: string): string[] {
  const refs = new Set<string>();
  let m: RegExpExecArray | null;
  ANNEX_REF_IN_TEXT_RE.lastIndex = 0;
  while ((m = ANNEX_REF_IN_TEXT_RE.exec(statement)) !== null) {
    const ref = (m[1] ?? "").trim().toLowerCase();
    if (ref) refs.add(ref);
  }
  return [...refs];
}

/**
 * Mappe les références trouvées dans un énoncé vers les pages d'annexes.
 * Retourne { pages, labels } pour persister dans question_bank.
 */
export function resolveAnnexesForQuestion(
  statement: string,
  annexes: AnnexPage[],
): { pages: number[]; labels: string[] } {
  const refs = findAnnexRefsInStatement(statement);
  const pages: number[] = [];
  const labels: string[] = [];
  for (const ref of refs) {
    const match = annexes.find((a) => a.ref === ref);
    if (match) {
      pages.push(match.pageNumber);
      labels.push(match.label);
    }
  }
  // Si l'énoncé mentionne "voir annexe" sans numéro et qu'il n'y a
  // qu'une annexe au total, on l'attache automatiquement.
  if (
    pages.length === 0 &&
    /\bannexe\b/i.test(statement) &&
    annexes.length === 1
  ) {
    pages.push(annexes[0].pageNumber);
    labels.push(annexes[0].label);
  }
  return { pages, labels };
}
