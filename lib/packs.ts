// =====================================================================
// Architecture des 3 packs (Initial / Medium / Premium)
//
// Source unique pour :
//   - Le feature-gating côté front (UI, conditional rendering)
//   - Le pricing par formation (lib/pricing-config.ts)
//   - Les validations côté back (API routes, server actions)
//
// Côté DB :
//   - enrollments.pack (enum 'initial' | 'medium' | 'premium')
//   - RPC user_pack_for_formation(user_id, formation_slug) → pack_slug | NULL
//   - RPC user_has_min_pack(user_id, formation_slug, min_pack) → boolean
//   - Trigger : Capacité ≤ 3,5 t accepte UNIQUEMENT 'initial'
//   Cf. supabase/2026_05_13_packs_architecture.sql
//
// Révision client 2026-05 : packs hérités hiérarchiquement.
// Medium inclut Initial, Premium inclut Medium.
// =====================================================================

export type PackSlug = "initial" | "medium" | "premium";

export const PACK_SLUGS: readonly PackSlug[] = [
  "initial",
  "medium",
  "premium",
] as const;

/**
 * Features disponibles par pack. Une feature appartient au pack qui
 * l'introduit en premier (Initial). Les packs supérieurs en héritent
 * automatiquement via la hiérarchie `PACK_LEVEL`.
 */
export type PackFeature =
  // Initial (toutes formations) — base pédagogique
  | "lessons" //          Cours détaillés
  | "exercises" //        Exercices d'entraînement (QCM + QR)
  | "corrections" //      Corrigés visibles après tentative
  | "qr_ai_grading" //    QR corrigés automatiquement par Claude
  | "exams_ai_grading" // Examens blancs corrigés par Claude
  // Medium — accompagnement personnalisé
  | "messaging_dedicated_trainer" //  Messagerie avec UN formateur dédié
  // Premium — présentiel + visio
  | "live_sessions" //    Sessions présentielles planifiées (admin/formateur)
  | "zoom_link"; //       Lien Zoom optionnel sur sessions présentielles

/**
 * Features INTRODUITES par chaque pack (non cumulatif — pour le cumul,
 * utiliser `hasPackFeature` qui parcourt la hiérarchie).
 */
const PACK_FEATURES: Record<PackSlug, readonly PackFeature[]> = {
  initial: [
    "lessons",
    "exercises",
    "corrections",
    "qr_ai_grading",
    "exams_ai_grading",
  ],
  medium: ["messaging_dedicated_trainer"],
  premium: ["live_sessions", "zoom_link"],
};

/**
 * Hiérarchie : Initial < Medium < Premium.
 * Un pack de niveau N inclut toutes les features des packs de niveau ≤ N.
 */
const PACK_LEVEL: Record<PackSlug, number> = {
  initial: 1,
  medium: 2,
  premium: 3,
};

// ---------------------------------------------------------------------
// 1. Feature gating
// ---------------------------------------------------------------------

/**
 * Renvoie TRUE si le pack du user inclut la feature donnée.
 *
 * Tient compte de la hiérarchie : un user Premium a accès à toutes les
 * features Initial + Medium + Premium.
 *
 * @example
 *   hasPackFeature("medium", "messaging_dedicated_trainer")  // true
 *   hasPackFeature("initial", "messaging_dedicated_trainer") // false
 *   hasPackFeature("premium", "qr_ai_grading")               // true (hérité d'Initial)
 *   hasPackFeature(null, "lessons")                           // false (pas de pack)
 */
export function hasPackFeature(
  pack: PackSlug | null | undefined,
  feature: PackFeature,
): boolean {
  if (!pack) return false;
  const userLevel = PACK_LEVEL[pack];
  // Parcourt les packs du plus bas au plus haut, jusqu'au niveau du user
  for (const p of PACK_SLUGS) {
    if (PACK_LEVEL[p] > userLevel) break;
    if (PACK_FEATURES[p].includes(feature)) return true;
  }
  return false;
}

/**
 * Renvoie le pack minimum qui débloque une feature, ou null si la feature
 * n'est rattachée à aucun pack (cas erreur).
 *
 * @example
 *   getMinPackForFeature("messaging_dedicated_trainer") // "medium"
 *   getMinPackForFeature("zoom_link")                   // "premium"
 *   getMinPackForFeature("lessons")                     // "initial"
 */
export function getMinPackForFeature(feature: PackFeature): PackSlug | null {
  for (const pack of PACK_SLUGS) {
    if (PACK_FEATURES[pack].includes(feature)) return pack;
  }
  return null;
}

// ---------------------------------------------------------------------
// 2. Hiérarchie & comparaisons
// ---------------------------------------------------------------------

/**
 * Compare deux packs selon la hiérarchie.
 * Retourne < 0 si a < b, 0 si a == b, > 0 si a > b.
 *
 * @example
 *   comparePacks("initial", "medium")  // -1
 *   comparePacks("premium", "medium")  //  1
 *   comparePacks("medium", "medium")   //  0
 */
export function comparePacks(a: PackSlug, b: PackSlug): number {
  return PACK_LEVEL[a] - PACK_LEVEL[b];
}

/**
 * Renvoie TRUE si `pack` est au moins de niveau `minPack` dans la hiérarchie.
 *
 * @example
 *   isPackAtLeast("medium", "initial")   // true
 *   isPackAtLeast("premium", "medium")   // true
 *   isPackAtLeast("initial", "medium")   // false
 */
export function isPackAtLeast(
  pack: PackSlug | null | undefined,
  minPack: PackSlug,
): boolean {
  if (!pack) return false;
  return PACK_LEVEL[pack] >= PACK_LEVEL[minPack];
}

/**
 * Renvoie les packs supérieurs accessibles depuis le pack courant
 * (utile pour proposer les upgrades).
 *
 * @example
 *   getUpgradablePacks("initial")  // ["medium", "premium"]
 *   getUpgradablePacks("medium")   // ["premium"]
 *   getUpgradablePacks("premium")  // []
 */
export function getUpgradablePacks(current: PackSlug): PackSlug[] {
  return PACK_SLUGS.filter((p) => PACK_LEVEL[p] > PACK_LEVEL[current]);
}

// ---------------------------------------------------------------------
// 3. Disponibilité par formation
// ---------------------------------------------------------------------

/**
 * Slugs de formations qui n'autorisent QUE le pack Initial.
 * Source : décision client 2026-05 — Capacité ≤ 3,5 t a 1 seul pack.
 *
 * Si demain le client veut ajouter Medium/Premium sur Capacité, il suffit
 * de retirer le slug de cette liste (et de désactiver le trigger SQL).
 */
const INITIAL_ONLY_FORMATIONS: ReadonlySet<string> = new Set([
  "capacite-3-5t",
]);

/**
 * Renvoie TRUE si un pack est disponible à l'achat pour une formation.
 *
 * @example
 *   isPackAvailableForFormation("initial", "capacite-3-5t")  // true
 *   isPackAvailableForFormation("medium",  "capacite-3-5t")  // false (limite client)
 *   isPackAvailableForFormation("premium", "gotrm-rncp-40990") // true
 */
export function isPackAvailableForFormation(
  pack: PackSlug,
  formationSlug: string,
): boolean {
  if (INITIAL_ONLY_FORMATIONS.has(formationSlug)) {
    return pack === "initial";
  }
  return true;
}

/**
 * Renvoie la liste des packs achetables pour une formation donnée.
 * Utilisé par la page /inscription pour ne proposer que les options valides.
 */
export function getAvailablePacksForFormation(
  formationSlug: string,
): PackSlug[] {
  return PACK_SLUGS.filter((p) =>
    isPackAvailableForFormation(p, formationSlug),
  );
}

// ---------------------------------------------------------------------
// 4. Métadonnées d'affichage
// ---------------------------------------------------------------------

export interface PackMetadata {
  /** Slug technique (key DB). */
  slug: PackSlug;
  /** Nom affiché (Initial, Medium, Premium). */
  name: string;
  /** Tagline courte sous le nom. */
  tagline: string;
  /** Description en une phrase (cards inscription). */
  description: string;
  /** Couleur d'accent (hex). Pour les cards, badges. */
  accent: string;
  /** Liste des features pour affichage marketing. */
  features: readonly PackFeature[];
  /** Inclut tout ce que le pack du dessous propose ? */
  inheritsFrom: PackSlug | null;
}

export const PACK_METADATA: Record<PackSlug, PackMetadata> = {
  initial: {
    slug: "initial",
    name: "Initial",
    tagline: "Préparation autonome",
    description:
      "Tous les cours, exercices et corrigés. La correction par IA des QR et examens blancs est incluse. Idéal pour les autonomes.",
    accent: "#9FE220", // signal-lime MFT
    features: PACK_FEATURES.initial,
    inheritsFrom: null,
  },
  medium: {
    slug: "medium",
    name: "Medium",
    tagline: "Avec formateur dédié",
    description:
      "Tout l'Initial + une messagerie privée avec un formateur dédié qui vous accompagne sur toute la durée de votre formation.",
    accent: "#4F46E5", // indigo
    features: PACK_FEATURES.medium,
    inheritsFrom: "initial",
  },
  premium: {
    slug: "premium",
    name: "Premium",
    tagline: "Accompagnement complet",
    description:
      "Tout le Medium + sessions présentielles en salle (lien Zoom optionnel). L'expérience la plus complète pour maximiser vos chances.",
    accent: "#a16207", // gold
    features: PACK_FEATURES.premium,
    inheritsFrom: "medium",
  },
};

/**
 * Renvoie toutes les features qu'un pack offre (cumul hiérarchique).
 * Utilisé pour les cards marketing qui doivent afficher la liste complète
 * (Medium doit montrer "Tout l'Initial +").
 *
 * @example
 *   getAllPackFeatures("medium")
 *   // [
 *   //   'lessons', 'exercises', 'corrections', 'qr_ai_grading', 'exams_ai_grading',
 *   //   'messaging_dedicated_trainer'
 *   // ]
 */
export function getAllPackFeatures(pack: PackSlug): PackFeature[] {
  const out: PackFeature[] = [];
  const userLevel = PACK_LEVEL[pack];
  for (const p of PACK_SLUGS) {
    if (PACK_LEVEL[p] > userLevel) break;
    out.push(...PACK_FEATURES[p]);
  }
  return out;
}

// ---------------------------------------------------------------------
// 5. Libellés humains des features (i18n FR)
// ---------------------------------------------------------------------

export const FEATURE_LABEL: Record<PackFeature, string> = {
  lessons: "Cours détaillés (texte + fiches synthèse)",
  exercises: "Exercices d'entraînement (QCM + QR)",
  corrections: "Corrigés détaillés visibles après tentative",
  qr_ai_grading: "Correction automatique par IA des questions rédigées",
  exams_ai_grading: "Examens blancs corrigés par IA",
  messaging_dedicated_trainer:
    "Messagerie privée avec un formateur dédié",
  live_sessions: "Sessions présentielles en salle (planning admin)",
  zoom_link: "Lien Zoom pour suivre la session à distance",
};

// ---------------------------------------------------------------------
// 6. Type guard
// ---------------------------------------------------------------------

/**
 * Type guard utile pour valider une valeur reçue (form, query string, etc.)
 * avant de la stocker en DB.
 */
export function isPackSlug(value: unknown): value is PackSlug {
  return (
    typeof value === "string" &&
    (PACK_SLUGS as readonly string[]).includes(value)
  );
}
