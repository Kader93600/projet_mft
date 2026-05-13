// =====================================================================
// Configuration des filtres "groupe de questions" par formation.
//
// Chaque formation utilise une nomenclature pédagogique différente :
//   - GOTRM (RNCP 40990)  → "Chapitre 1", "Chapitre 2"… (tag `chapitre-N`)
//   - Capacité ≤ 3,5 t    → "Module A", "Module B"…    (tag `module-X`)
//   - Autres              → fallback générique
//
// Côté UI, ces filtres apparaissent en barre de pills dans :
//   - /admin/banque-questions/validation
//   - /admin/banque-questions/validation-qr
//   - /admin/banque-questions/liste
//   - /admin/banque-questions/creer-quiz
//
// Cette config sert UNIQUEMENT à formater l'affichage. Les tags réels
// sur question_bank.tags sont la source de vérité.
// =====================================================================

export interface QuestionFilterConfig {
  /** Préfixe du tag DB : `chapitre-`, `module-`, etc. */
  tagPrefix: string;
  /** Label de la section (singulier) : "Chapitre", "Module". */
  label: string;
  /** Liste des clés autorisées (sans préfixe). Si vide → ouverte. */
  keys: readonly string[];
  /** Formate une clé en libellé affiché : "1" → "Ch. 1", "a" → "A". */
  formatPill: (key: string) => string;
  /** Formate une clé en libellé long : "1" → "Chapitre 1". */
  formatLong?: (key: string) => string;
}

// GOTRM (RNCP 40990) : 17 chapitres au total dans le livret de formation
// (CCP1 + CCP2 + CCP3). La liste est étendue à 20 en sécurité pour absorber
// d'éventuels ajouts futurs sans modifier le code — les chapitres au-delà
// apparaissent automatiquement comme "extra" via auto-discovery des tags.
const GOTRM_CHAPTERS = [
  "1",
  "2",
  "3",
  "4",
  "5",
  "6",
  "7",
  "8",
  "9",
  "10",
  "11",
  "12",
  "13",
  "14",
  "15",
  "16",
  "17",
] as const;
const CAPA_MODULES = ["a", "b", "c", "d", "e", "f"] as const;

/**
 * Configuration par slug de formation. Les formations non listées
 * tombent sur le fallback générique (chapitre-N).
 */
export const QUESTION_FILTERS: Record<string, QuestionFilterConfig> = {
  gotrm: {
    tagPrefix: "chapitre-",
    label: "Chapitre",
    keys: GOTRM_CHAPTERS,
    formatPill: (k) => `Ch. ${k}`,
    formatLong: (k) => `Chapitre ${k}`,
  },
  "capacite-3-5t": {
    tagPrefix: "module-",
    label: "Module",
    keys: CAPA_MODULES,
    formatPill: (k) => k.toUpperCase(),
    formatLong: (k) => `Module ${k.toUpperCase()}`,
  },
  "capacite-plus-3-5t": {
    tagPrefix: "module-",
    label: "Module",
    keys: CAPA_MODULES,
    formatPill: (k) => k.toUpperCase(),
    formatLong: (k) => `Module ${k.toUpperCase()}`,
  },
};

/** Fallback : chapitres 1 à 12 (cas neutre, le plus large). */
const DEFAULT_FILTER: QuestionFilterConfig = {
  tagPrefix: "chapitre-",
  label: "Chapitre",
  keys: GOTRM_CHAPTERS,
  formatPill: (k) => `Ch. ${k}`,
  formatLong: (k) => `Chapitre ${k}`,
};

/**
 * Renvoie la configuration de filtres pour une formation donnée.
 * Toujours non-null (fallback générique si formation inconnue).
 */
export function getQuestionFilterConfig(
  formationSlug: string | null | undefined,
): QuestionFilterConfig {
  if (!formationSlug) return DEFAULT_FILTER;
  return QUESTION_FILTERS[formationSlug] ?? DEFAULT_FILTER;
}
