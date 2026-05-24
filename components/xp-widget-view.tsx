"use client";

import { useEffect, useState } from "react";
import { Card, CardBody } from "@/components/ui/card";
import { Flame, Sparkles, Trophy } from "lucide-react";
import { AnimatedCounter } from "@/components/animated-counter";
import { cn } from "@/lib/utils";

/**
 * Carte XP / niveau / série du dashboard — version animée (Emil) :
 * la barre se remplit (ease-out), l'XP se compte, la flamme pulse si la série
 * est active. Tout est gated motion-safe ; en prefers-reduced-motion, valeurs
 * finales sans mouvement.
 */
export function XpWidgetView({
  level,
  totalXp,
  nextStart,
  pct,
  currentStreak,
  longestStreak,
}: {
  level: number;
  totalXp: number;
  nextStart: number;
  pct: number;
  currentStreak: number;
  longestStreak: number;
}) {
  const [barW, setBarW] = useState(0);

  useEffect(() => {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      setBarW(pct);
      return;
    }
    const r = requestAnimationFrame(() => setBarW(pct));
    return () => cancelAnimationFrame(r);
  }, [pct]);

  return (
    <Card variant="solid-navy" className="relative overflow-hidden">
      <div className="absolute inset-0 bg-mesh-navy opacity-40" />
      <CardBody className="relative grid md:grid-cols-[auto_1fr_auto] gap-6 items-center">
        <div className="flex items-center gap-4">
          <div className="h-14 w-14 rounded-2xl bg-gold-500 text-navy-900 flex items-center justify-center shrink-0">
            <Trophy className="h-7 w-7" />
          </div>
          <div>
            <div className="text-[11px] uppercase tracking-wider text-gold-300">
              Niveau
            </div>
            <div className="font-display text-3xl font-semibold tabular-nums">
              {level}
            </div>
          </div>
        </div>

        <div>
          <div className="flex items-center justify-between text-xs text-white/70 mb-1.5">
            <span className="tabular-nums">
              <AnimatedCounter value={totalXp} className="font-semibold" /> XP
            </span>
            <span className="tabular-nums">{nextStart} XP</span>
          </div>
          <div className="h-2 rounded-full bg-white/10 overflow-hidden">
            <div
              className="h-full rounded-full bg-gradient-to-r from-gold-400 to-gold-600 transition-[width] duration-[900ms] ease-premium motion-reduce:transition-none"
              style={{ width: `${barW}%` }}
            />
          </div>
          <div className="mt-2 text-xs text-white/60">
            Encore {Math.max(0, nextStart - totalXp)} XP avant le niveau{" "}
            {level + 1}
          </div>
        </div>

        <div className="flex gap-4">
          <div className="flex items-center gap-2 rounded-xl bg-white/5 border border-white/10 px-3 py-2">
            <Flame
              className={cn(
                "h-4 w-4",
                currentStreak > 0
                  ? "text-orange-400 motion-safe:animate-pulse"
                  : "text-gold-400"
              )}
            />
            <div>
              <div className="text-[10px] uppercase tracking-wider text-white/60">
                Série
              </div>
              <div className="font-display text-lg font-semibold tabular-nums">
                {currentStreak}
                <span className="text-xs text-white/50"> j</span>
              </div>
            </div>
          </div>
          <div className="flex items-center gap-2 rounded-xl bg-white/5 border border-white/10 px-3 py-2">
            <Sparkles className="h-4 w-4 text-gold-400" />
            <div>
              <div className="text-[10px] uppercase tracking-wider text-white/60">
                Record
              </div>
              <div className="font-display text-lg font-semibold tabular-nums">
                {longestStreak}
                <span className="text-xs text-white/50"> j</span>
              </div>
            </div>
          </div>
        </div>
      </CardBody>
    </Card>
  );
}
