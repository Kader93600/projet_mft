"use client";
import { useState, useTransition } from "react";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Check } from "lucide-react";
import { useRouter } from "next/navigation";
import {
  RewardCelebration,
  type RewardBadge,
  type RewardRankUp,
} from "@/components/celebration/reward-celebration";
import { getRank } from "@/lib/gamification/ranks";

export function MarkDoneButton({
  lessonId,
  initialDone,
  moduleTitle,
  lessonsTotal = 1,
  moduleDoneOthers = 0,
  continueHref,
}: {
  lessonId: string;
  initialDone: boolean;
  moduleTitle?: string;
  lessonsTotal?: number;
  moduleDoneOthers?: number;
  continueHref?: string;
}) {
  const [done, setDone] = useState(initialDone);
  const [pending, start] = useTransition();
  const router = useRouter();
  const [reward, setReward] = useState<null | {
    moduleComplete: { title: string; lessonsTotal: number } | null;
    xpGained: number;
    rankUp: RewardRankUp | null;
    badges: RewardBadge[];
  }>(null);

  async function toggle() {
    start(async () => {
      const supabase = createClient();
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) return;
      const newDone = !done;

      // État gamification AVANT (uniquement à la complétion) — pour calculer
      // l'XP gagnée, le passage de rang et les nouveaux badges.
      let before: { total_xp: number; level: number } | null = null;
      let beforeBadgeIds = new Set<string>();
      if (newDone) {
        const [g, b] = await Promise.all([
          supabase
            .from("user_gamification")
            .select("total_xp, level")
            .eq("user_id", user.id)
            .maybeSingle(),
          supabase.from("user_badges").select("badge_id").eq("user_id", user.id),
        ]);
        before = (g.data as any) ?? null;
        beforeBadgeIds = new Set((b.data ?? []).map((r: any) => r.badge_id));
      }

      // Upsert (déclenche XP + recompute badges via triggers Postgres).
      await supabase.from("lesson_progress").upsert(
        {
          user_id: user.id,
          lesson_id: lessonId,
          completed: newDone,
          completed_at: newDone ? new Date().toISOString() : null,
        },
        { onConflict: "user_id,lesson_id" }
      );
      if (newDone) {
        try {
          await supabase.rpc("ping_lesson_view", {
            p_lesson_id: lessonId,
            p_completed: true,
          });
        } catch {
          /* non-bloquant */
        }
      }
      setDone(newDone);

      // Récompenses (uniquement à la complétion).
      if (newDone) {
        const moduleComplete =
          !!moduleTitle && moduleDoneOthers + 1 >= lessonsTotal;
        let xpGained = 0;
        let rankUp: RewardRankUp | null = null;
        let badges: RewardBadge[] = [];
        try {
          const [g2, b2] = await Promise.all([
            supabase
              .from("user_gamification")
              .select("total_xp, level")
              .eq("user_id", user.id)
              .maybeSingle(),
            supabase
              .from("user_badges")
              .select("badge_id")
              .eq("user_id", user.id),
          ]);
          const after = (g2.data as any) ?? null;
          if (before && after) {
            xpGained = Math.max(
              0,
              (after.total_xp ?? 0) - (before.total_xp ?? 0)
            );
            const rb = getRank(before.level ?? 1);
            const ra = getRank(after.level ?? 1);
            if (ra.index > rb.index)
              rankUp = { label: ra.rank.label, emoji: ra.rank.emoji };
          }
          const afterIds = (b2.data ?? []).map((r: any) => r.badge_id);
          const newIds = afterIds.filter((id: string) => !beforeBadgeIds.has(id));
          if (newIds.length) {
            const { data: bd } = await supabase
              .from("badges")
              .select("name, description, icon, tier")
              .in("id", newIds);
            badges = (bd ?? []) as RewardBadge[];
          }
        } catch {
          /* non-bloquant : on célèbre avec ce qu'on a pu lire */
        }

        if (moduleComplete || rankUp || badges.length > 0) {
          setReward({
            moduleComplete: moduleComplete
              ? { title: moduleTitle!, lessonsTotal }
              : null,
            xpGained,
            rankUp,
            badges,
          });
          // ⚠️ Ne PAS rafraîchir maintenant : router.refresh() ferait
          // re-suspendre la page (skeleton loading.tsx) → remontage du bouton
          // → l'overlay disparaîtrait aussitôt. On diffère le refresh à la
          // fermeture de l'overlay (handleClose).
          return;
        }
      }

      router.refresh();
    });
  }

  // Fermeture de l'overlay : on synchronise alors l'état serveur.
  function handleClose() {
    setReward(null);
    router.refresh();
  }

  return (
    <>
      <Button
        variant={done ? "secondary" : "gold"}
        onClick={toggle}
        disabled={pending}
        size="md"
      >
        {done ? (
          <>
            <Check className="w-4 h-4" /> Terminé
          </>
        ) : (
          "Marquer terminé"
        )}
      </Button>

      {reward && (
        <RewardCelebration
          moduleComplete={reward.moduleComplete}
          xpGained={reward.xpGained}
          rankUp={reward.rankUp}
          badges={reward.badges}
          continueHref={
            reward.moduleComplete ? continueHref ?? "/modules" : undefined
          }
          onClose={handleClose}
        />
      )}
    </>
  );
}
