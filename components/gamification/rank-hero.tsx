"use client";

import { useEffect, useState } from "react";
import { Flame, Sparkles } from "lucide-react";
import { AnimatedCounter } from "@/components/animated-counter";
import { getRank, RANKS_LIST } from "@/lib/gamification/ranks";
import { cn } from "@/lib/utils";

/**
 * Héros gamifié de /reussites : rang nommé (Débutant→Master), niveau, barre
 * d'XP animée, parcours des rangs, et série (flamme animée si active).
 * Animations gated motion-safe ; compteur XP respecte prefers-reduced-motion.
 */
export function RankHero({
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
  const { rank, index, next, levelsToNext } = getRank(level);
  const [barW, setBarW] = useState(0);

  useEffect(() => {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      setBarW(pct);
      return;
    }
    const r = requestAnimationFrame(() => setBarW(pct));
    return () => cancelAnimationFrame(r);
  }, [pct]);

  const prestige = rank.id === "expert" || rank.id === "master";

  return (
    <div className="relative overflow-hidden rounded-2xl bg-navy-950 text-white shadow-raised">
      <div className="absolute inset-0 bg-mesh-navy opacity-40" aria-hidden />
      <div
        aria-hidden
        className="pointer-events-none absolute -top-24 left-1/4 h-72 w-72 rounded-full blur-3xl"
        style={{ background: rank.glow }}
      />

      <div className="relative grid items-center gap-6 p-6 md:p-7 lg:grid-cols-[auto_1fr_auto]">
        {/* Emblème + rang */}
        <div className="flex items-center gap-4">
          <div className="relative">
            {prestige && (
              <div
                aria-hidden
                className="absolute -inset-2 rounded-3xl opacity-60 blur-xl motion-safe:animate-spin-slow"
                style={{
                  background: `conic-gradient(from 0deg, ${rank.glow}, transparent, ${rank.glow})`,
                }}
              />
            )}
            <div
              className={cn(
                "relative flex h-16 w-16 items-center justify-center rounded-2xl bg-gradient-to-br text-3xl shadow-glow-signal",
                rank.emblem
              )}
            >
              <span aria-hidden>{rank.emoji}</span>
            </div>
          </div>
          <div>
            <div className="text-[11px] uppercase tracking-wider text-white/55">
              Rang
            </div>
            <div className="font-display text-2xl font-semibold leading-tight">
              {rank.label}
            </div>
            <div className="mt-0.5 text-xs text-white/55">
              Niveau{" "}
              <span className="font-semibold tabular-nums text-white/85">
                {level}
              </span>
            </div>
          </div>
        </div>

        {/* XP + parcours des rangs */}
        <div>
          <div className="mb-1.5 flex items-center justify-between text-xs text-white/60">
            <span className="tabular-nums">
              <AnimatedCounter
                value={totalXp}
                className="font-semibold text-white/90"
              />{" "}
              XP
            </span>
            <span className="tabular-nums">{nextStart} XP</span>
          </div>
          <div className="h-2.5 overflow-hidden rounded-full bg-white/10">
            <div
              className="h-full rounded-full bg-gradient-to-r from-signal-400 to-gold-400 transition-[width] duration-[900ms] ease-premium motion-reduce:transition-none"
              style={{ width: `${barW}%` }}
            />
          </div>
          <div className="mt-2 text-xs text-white/55">
            {next ? (
              <>
                Plus que{" "}
                <span className="font-semibold text-white/85">{levelsToNext}</span>{" "}
                niveau{(levelsToNext ?? 0) !== 1 ? "x" : ""} avant le rang{" "}
                <span className="font-semibold text-white/85">{next.label}</span>
              </>
            ) : (
              "Rang maximal atteint — bravo !"
            )}
          </div>

          {/* Parcours des 5 rangs */}
          <div className="mt-3 flex items-center gap-1.5">
            {RANKS_LIST.map((r, i) => (
              <div
                key={r.id}
                title={r.label}
                className={cn(
                  "h-1.5 flex-1 rounded-full transition-colors",
                  i <= index
                    ? "bg-gradient-to-r from-signal-400 to-gold-400"
                    : "bg-white/10"
                )}
              />
            ))}
          </div>
        </div>

        {/* Série */}
        <div className="flex gap-3">
          <div className="flex items-center gap-2 rounded-xl border border-white/10 bg-white/5 px-3 py-2">
            <Flame
              className={cn(
                "h-5 w-5",
                currentStreak > 0
                  ? "text-orange-400 motion-safe:animate-pulse"
                  : "text-white/30"
              )}
            />
            <div>
              <div className="text-[10px] uppercase tracking-wider text-white/55">
                Série
              </div>
              <div className="font-display text-lg font-semibold tabular-nums">
                {currentStreak}
                <span className="text-xs text-white/45"> j</span>
              </div>
            </div>
          </div>
          <div className="flex items-center gap-2 rounded-xl border border-white/10 bg-white/5 px-3 py-2">
            <Sparkles className="h-4 w-4 text-gold-400" />
            <div>
              <div className="text-[10px] uppercase tracking-wider text-white/55">
                Record
              </div>
              <div className="font-display text-lg font-semibold tabular-nums">
                {longestStreak}
                <span className="text-xs text-white/45"> j</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
