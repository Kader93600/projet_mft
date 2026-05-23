/**
 * Paliers émotionnels de résultat de quiz / examen.
 *
 * Source de vérité unique (pure, testable) : un score 0–100 → un palier avec
 * sa couleur, son message, son emoji et l'intensité d'animation associée.
 * Le rendu (anneau, glow, confettis) est piloté par <ResultCelebration>.
 *
 * Calibrage « équilibré premium » : valorisant, jamais clinquant ni enfantin.
 */
export type ResultTierId =
  | "struggling"
  | "almost"
  | "progress"
  | "solid"
  | "excellent"
  | "mastery";

export interface ResultTier {
  id: ResultTierId;
  min: number;
  max: number;
  emoji: string;
  title: string;
  message: string;
  /** Classe Tailwind `stroke-*` pour l'arc de progression. */
  ringClass: string;
  /** Classe Tailwind `text-*` pour le pourcentage. */
  numberClass: string;
  /** Dégradé radial (rgba) du halo derrière l'anneau. */
  glow: string;
  /** Couleurs des confettis (hex). */
  confettiColors: string[];
  /** Nombre de particules de confettis (0 = aucun). */
  confetti: number;
  /** Petite secousse d'encouragement (bas paliers). */
  shake: boolean;
  /** Halo pulsé « presque » (tension positive). */
  suspense: boolean;
  /** Traitement premium « maîtrise » (halo tournant, anneau dégradé). */
  mastery: boolean;
}

const TIERS: ResultTier[] = [
  {
    id: "struggling",
    min: 0,
    max: 45,
    emoji: "💪",
    title: "On ne lâche rien",
    message: "Continue tes efforts : chaque tentative te fait progresser.",
    ringClass: "stroke-rose-500",
    numberClass: "text-rose-600",
    glow: "rgba(244,63,94,0.13)",
    confettiColors: [],
    confetti: 0,
    shake: true,
    suspense: false,
    mastery: false,
  },
  {
    id: "almost",
    min: 46,
    max: 50,
    emoji: "😬",
    title: "Si proche !",
    message: "Tu étais à un cheveu de la validation. La prochaine est la bonne.",
    ringClass: "stroke-orange-500",
    numberClass: "text-orange-600",
    glow: "rgba(249,115,22,0.17)",
    confettiColors: [],
    confetti: 0,
    shake: false,
    suspense: true,
    mastery: false,
  },
  {
    id: "progress",
    min: 51,
    max: 69,
    emoji: "📈",
    title: "Belle progression",
    message: "Tu avances vraiment. Encore un effort pour décrocher la validation.",
    ringClass: "stroke-amber-500",
    numberClass: "text-amber-600",
    glow: "rgba(245,158,11,0.16)",
    confettiColors: ["#f59e0b", "#fbbf24", "#9FE220"],
    confetti: 34,
    shake: false,
    suspense: false,
    mastery: false,
  },
  {
    id: "solid",
    min: 70,
    max: 89,
    emoji: "🏆",
    title: "Très bon résultat",
    message: "Tu maîtrises bien cette compétence. Continue sur ta lancée.",
    ringClass: "stroke-emerald-500",
    numberClass: "text-emerald-600",
    glow: "rgba(16,185,129,0.16)",
    confettiColors: ["#10b981", "#9FE220", "#34d399", "#0E1240"],
    confetti: 80,
    shake: false,
    suspense: false,
    mastery: false,
  },
  {
    id: "excellent",
    min: 90,
    max: 95,
    emoji: "👑",
    title: "Excellent travail",
    message: "Niveau quasi professionnel. Impressionnant de rigueur.",
    ringClass: "stroke-sky-500",
    numberClass: "text-sky-600",
    glow: "rgba(14,165,233,0.18)",
    confettiColors: ["#0ea5e9", "#38bdf8", "#9FE220", "#a16207"],
    confetti: 120,
    shake: false,
    suspense: false,
    mastery: false,
  },
  {
    id: "mastery",
    min: 96,
    max: 100,
    emoji: "🐐",
    title: "Performance exceptionnelle",
    message: "Niveau expert atteint. Tu fais partie des meilleurs.",
    ringClass: "stroke-violet-500",
    numberClass: "text-violet-600",
    glow: "rgba(139,92,246,0.22)",
    confettiColors: ["#8b5cf6", "#a78bfa", "#9FE220", "#a16207", "#ffffff"],
    confetti: 170,
    shake: false,
    suspense: false,
    mastery: true,
  },
];

/** Retourne le palier correspondant au score (borné 0–100). */
export function getResultTier(score: number): ResultTier {
  const s = Math.max(0, Math.min(100, Math.round(score)));
  // Dernier palier dont `min` est atteint.
  let tier = TIERS[0];
  for (const t of TIERS) {
    if (s >= t.min) tier = t;
  }
  return tier;
}

export const RESULT_TIERS = TIERS;
