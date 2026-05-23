"use client";

import { useEffect, useState } from "react";
import { CheckCircle2 } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { RadialProgress } from "@/components/ui/progress";
import { AnimatedCounter } from "@/components/animated-counter";
import { getResultTier } from "@/lib/quiz-result-tiers";
import { cn } from "@/lib/utils";
import { ConfettiBurst } from "./confetti-burst";

/**
 * Héros de la page de résultats : anneau de score + ambiance émotionnelle
 * selon le palier (couleur, glow, message, emoji, confettis, secousse,
 * traitement « maîtrise »). Calibrage « équilibré premium ».
 *
 * Toutes les animations sont gated `motion-safe` ; les confettis (canvas) ne
 * sont montés qu'après hydratation et hors prefers-reduced-motion.
 */
export function ResultCelebration({
  score,
  passed,
}: {
  score: number;
  passed: boolean;
}) {
  const tier = getResultTier(score);
  const [confettiOn, setConfettiOn] = useState(false);

  useEffect(() => {
    if (tier.confetti === 0) return;
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    // Monté après le 1er paint → le canvas mesure correctement la carte.
    const id = requestAnimationFrame(() => setConfettiOn(true));
    return () => cancelAnimationFrame(id);
  }, [tier.confetti]);

  return (
    <div className="relative overflow-hidden rounded-2xl border border-navy-100 bg-white shadow-soft dark:border-[hsl(var(--border))] dark:bg-[hsl(var(--surface))]">
      {/* Halo de couleur du palier */}
      <div
        aria-hidden
        className="pointer-events-none absolute inset-0"
        style={{
          background: `radial-gradient(circle at 50% 0%, ${tier.glow} 0%, transparent 62%)`,
        }}
      />

      {/* Auréole tournante — maîtrise (96-100) */}
      {tier.mastery && (
        <div
          aria-hidden
          className="pointer-events-none absolute left-1/2 top-6 h-72 w-72 -translate-x-1/2 rounded-full opacity-50 blur-2xl motion-safe:animate-spin-slow"
          style={{
            background:
              "conic-gradient(from 0deg, rgba(139,92,246,0.40), rgba(159,226,32,0.22), rgba(161,98,7,0.30), rgba(139,92,246,0.40))",
          }}
        />
      )}

      {confettiOn && (
        <ConfettiBurst
          count={tier.confetti}
          colors={tier.confettiColors}
          originY={0.42}
        />
      )}

      <div className="relative px-6 py-10 text-center">
        {/* Anneau de score */}
        <div
          className={cn(
            "flex justify-center",
            tier.shake && "motion-safe:[animation:shake_0.55s_ease-in-out]"
          )}
        >
          <RadialProgress
            value={score}
            size={168}
            strokeWidth={14}
            progressClassName={tier.ringClass}
            label={
              <AnimatedCounter
                value={Math.round(score)}
                duration={1100}
                suffix="%"
                className={cn(
                  "font-display text-5xl font-semibold tabular-nums",
                  tier.numberClass
                )}
              />
            }
          />
        </div>

        {/* Emoji + titre */}
        <div className="mt-6 flex items-center justify-center gap-2 motion-safe:[animation:fade-up_0.5s_ease-out_0.2s_both]">
          <span className="text-2xl" aria-hidden>
            {tier.emoji}
          </span>
          <h2 className="font-display text-2xl font-semibold text-navy-950 dark:text-[hsl(var(--text))]">
            {tier.title}
          </h2>
        </div>

        {/* Message motivant */}
        <p className="mx-auto mt-2 max-w-md text-slate-600 motion-safe:[animation:fade-up_0.5s_ease-out_0.3s_both] dark:text-[hsl(var(--text-muted))]">
          {tier.message}
        </p>

        {/* Statut de validation */}
        <div className="mt-4 flex items-center justify-center gap-2">
          {passed ? (
            <Badge tone="success" size="md">
              <CheckCircle2 className="h-3 w-3" /> Seuil de validation atteint
            </Badge>
          ) : (
            <Badge tone="slate" size="md">
              Seuil non atteint
            </Badge>
          )}
          {tier.mastery && (
            <span className="inline-flex items-center rounded-full border border-violet-200 bg-violet-50 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-violet-700 dark:border-violet-500/30 dark:bg-violet-500/10 dark:text-violet-300">
              Niveau expert
            </span>
          )}
        </div>
      </div>
    </div>
  );
}
