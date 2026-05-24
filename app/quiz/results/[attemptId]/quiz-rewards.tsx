"use client";

import { useEffect, useState } from "react";
import {
  RewardCelebration,
  type RewardBadge,
  type RewardRankUp,
} from "@/components/celebration/reward-celebration";

/**
 * Overlay de récompenses (badges débloqués, passage de rang) affiché une fois,
 * par-dessus la page de résultats, juste après la soumission d'un quiz.
 *
 * Ne s'affiche que si le serveur a détecté une vraie récompense. On retire le
 * paramètre `?celebrate` de l'URL au montage pour qu'un rafraîchissement ou un
 * retour arrière ne re-déclenche pas l'animation.
 */
export function QuizRewards({
  xpGained,
  rankUp,
  badges,
}: {
  xpGained: number;
  rankUp: RewardRankUp | null;
  badges: RewardBadge[];
}) {
  const [open, setOpen] = useState(true);

  useEffect(() => {
    try {
      const url = new URL(window.location.href);
      if (url.searchParams.has("celebrate")) {
        url.searchParams.delete("celebrate");
        window.history.replaceState(null, "", url.pathname + url.search);
      }
    } catch {
      /* no-op */
    }
  }, []);

  if (!open) return null;

  return (
    <RewardCelebration
      xpGained={xpGained}
      rankUp={rankUp}
      badges={badges}
      onClose={() => setOpen(false)}
    />
  );
}
