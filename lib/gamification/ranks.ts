/**
 * Rangs nommés dérivés du niveau (Débutant → Master).
 *
 * Le niveau vient de `user_gamification.level` (déjà calculé à partir de l'XP).
 * Ici on mappe simplement le niveau → un rang valorisant, avec sa couleur et
 * son emblème. Pure et testable ; les seuils sont ajustables.
 */
export type RankId =
  | "debutant"
  | "intermediaire"
  | "avance"
  | "expert"
  | "master";

export interface Rank {
  id: RankId;
  label: string;
  minLevel: number;
  emoji: string;
  /** Dégradé Tailwind de l'emblème. */
  emblem: string;
  /** Chip (texte + fond) du rang. */
  chip: string;
  /** Couleur (rgba) du halo. */
  glow: string;
}

const RANKS: Rank[] = [
  {
    id: "debutant",
    label: "Débutant",
    minLevel: 1,
    emoji: "🌱",
    emblem: "from-slate-400 to-slate-600",
    chip: "bg-slate-100 text-slate-700 dark:bg-white/10 dark:text-white/80",
    glow: "rgba(100,116,139,0.30)",
  },
  {
    id: "intermediaire",
    label: "Intermédiaire",
    minLevel: 5,
    emoji: "📘",
    emblem: "from-sky-400 to-blue-600",
    chip: "bg-sky-100 text-sky-700 dark:bg-sky-500/15 dark:text-sky-300",
    glow: "rgba(14,165,233,0.34)",
  },
  {
    id: "avance",
    label: "Avancé",
    minLevel: 10,
    emoji: "🎯",
    emblem: "from-emerald-400 to-emerald-600",
    chip: "bg-emerald-100 text-emerald-700 dark:bg-emerald-500/15 dark:text-emerald-300",
    glow: "rgba(16,185,129,0.34)",
  },
  {
    id: "expert",
    label: "Expert",
    minLevel: 15,
    emoji: "👑",
    emblem: "from-amber-400 to-amber-600",
    chip: "bg-amber-100 text-amber-800 dark:bg-amber-500/15 dark:text-amber-300",
    glow: "rgba(245,158,11,0.38)",
  },
  {
    id: "master",
    label: "Master",
    minLevel: 25,
    emoji: "🏆",
    emblem: "from-violet-500 via-fuchsia-500 to-amber-400",
    chip: "bg-violet-100 text-violet-700 dark:bg-violet-500/15 dark:text-violet-300",
    glow: "rgba(139,92,246,0.40)",
  },
];

export interface RankInfo {
  rank: Rank;
  index: number;
  next: Rank | null;
  /** Niveaux restants avant le rang suivant (null si Master). */
  levelsToNext: number | null;
}

export function getRank(level: number): RankInfo {
  const lvl = Math.max(1, Math.floor(level || 1));
  let index = 0;
  for (let i = 0; i < RANKS.length; i++) {
    if (lvl >= RANKS[i].minLevel) index = i;
  }
  const rank = RANKS[index];
  const next = RANKS[index + 1] ?? null;
  return {
    rank,
    index,
    next,
    levelsToNext: next ? Math.max(0, next.minLevel - lvl) : null,
  };
}

export const RANKS_LIST = RANKS;
