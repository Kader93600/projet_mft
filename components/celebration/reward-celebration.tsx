"use client";

import { useEffect, useState, type ComponentType } from "react";
import Link from "next/link";
import {
  GraduationCap,
  ArrowRight,
  X,
  Sparkles,
  Medal,
  Trophy,
  Star,
  ShieldCheck,
  BookOpen,
  Library,
  Award,
  Crown,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { ConfettiBurst } from "./confetti-burst";

export interface RewardBadge {
  name: string;
  description?: string | null;
  icon?: string | null;
  tier?: "bronze" | "silver" | "gold" | string | null;
}
export interface RewardRankUp {
  label: string;
  emoji: string;
}

const ICONS: Record<string, ComponentType<{ className?: string }>> = {
  Sparkles, Medal, Trophy, Star, ShieldCheck, BookOpen, Library, Award, Crown,
  GraduationCap,
};

const TIER: Record<
  string,
  { label: string; medal: string; chip: string; glow: string }
> = {
  bronze: {
    label: "Commun",
    medal: "from-amber-600 to-amber-800",
    chip: "bg-amber-100 text-amber-800 dark:bg-amber-500/15 dark:text-amber-300",
    glow: "rgba(180,83,9,0.30)",
  },
  silver: {
    label: "Rare",
    medal: "from-slate-300 to-slate-500",
    chip: "bg-slate-100 text-slate-700 dark:bg-white/10 dark:text-white/80",
    glow: "rgba(148,163,184,0.34)",
  },
  gold: {
    label: "Épique",
    medal: "from-amber-300 via-amber-400 to-amber-600",
    chip: "bg-amber-100 text-amber-800 dark:bg-amber-500/15 dark:text-amber-300",
    glow: "rgba(245,158,11,0.42)",
  },
};

/**
 * Overlay de récompense unifié (fin de module, gain d'XP, passage de rang,
 * badges débloqués). Premium, motivant, non enfantin. Modale centrée,
 * confettis hors prefers-reduced-motion, apparition échelonnée des récompenses.
 */
export function RewardCelebration({
  moduleComplete,
  xpGained = 0,
  rankUp,
  badges = [],
  continueHref,
  onClose,
}: {
  moduleComplete?: { title: string; lessonsTotal: number } | null;
  xpGained?: number;
  rankUp?: RewardRankUp | null;
  badges?: RewardBadge[];
  continueHref?: string;
  onClose: () => void;
}) {
  const [shown, setShown] = useState(false);
  const [confettiOn, setConfettiOn] = useState(false);
  const [barFilled, setBarFilled] = useState(false);

  const hasGold = badges.some((b) => b.tier === "gold");
  const confettiCount = 100 + (rankUp ? 50 : 0) + (hasGold ? 40 : 0);

  // Titre principal selon la récompense dominante.
  const headline = moduleComplete
    ? "Module validé"
    : rankUp
      ? "Nouveau rang !"
      : badges.length > 0
        ? badges.length > 1
          ? "Badges débloqués"
          : "Badge débloqué"
        : "Bravo !";
  const eyebrow = moduleComplete
    ? "Compétence débloquée"
    : rankUp
      ? "Progression"
      : "Récompense";

  useEffect(() => {
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    const raf = requestAnimationFrame(() => {
      setShown(true);
      if (!reduce) setConfettiOn(true);
    });
    const tBar = setTimeout(() => setBarFilled(true), reduce ? 0 : 380);
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    document.addEventListener("keydown", onKey);
    const prevOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      cancelAnimationFrame(raf);
      clearTimeout(tBar);
      document.removeEventListener("keydown", onKey);
      document.body.style.overflow = prevOverflow;
    };
  }, [onClose]);

  // Délais d'apparition échelonnés.
  let delay = 0.15;
  const nextDelay = () => {
    delay += 0.12;
    return delay;
  };

  return (
    <div
      className="fixed inset-0 z-[100] flex items-center justify-center p-4"
      role="dialog"
      aria-modal="true"
      aria-label={headline}
    >
      <div
        className={cn(
          "absolute inset-0 bg-navy-950/55 backdrop-blur-sm transition-opacity duration-200",
          shown ? "opacity-100" : "opacity-0"
        )}
        onClick={onClose}
      />

      {confettiOn && (
        <ConfettiBurst
          count={confettiCount}
          colors={["#9FE220", "#10b981", "#2530D9", "#a16207", "#ffffff"]}
          originY={0.3}
          durationMs={2800}
        />
      )}

      <div
        className={cn(
          "relative w-full max-w-sm overflow-hidden rounded-3xl border border-navy-100 bg-white p-7 text-center shadow-2xl",
          "dark:border-[hsl(var(--border))] dark:bg-[hsl(var(--surface))]",
          "transition-[opacity,transform] duration-[240ms] ease-premium motion-reduce:transition-opacity",
          shown ? "scale-100 opacity-100" : "scale-95 opacity-0"
        )}
      >
        <div
          aria-hidden
          className="pointer-events-none absolute inset-x-0 top-0 h-40"
          style={{
            background:
              "radial-gradient(circle at 50% 0%, rgba(159,226,32,0.22), transparent 65%)",
          }}
        />

        {/* Sceau */}
        <div className="relative mx-auto flex h-20 w-20 items-center justify-center">
          <span className="absolute inset-0 rounded-full bg-emerald-400/25 motion-safe:animate-ping-once" />
          <span className="absolute inset-0 rounded-2xl bg-gradient-to-br from-signal-400 to-emerald-500 shadow-glow-signal motion-safe:[animation:badge-unlock_0.7s_cubic-bezier(0.34,1.56,0.64,1)_both]" />
          {rankUp && !moduleComplete ? (
            <span className="relative text-3xl" aria-hidden>
              {rankUp.emoji}
            </span>
          ) : (
            <GraduationCap className="relative h-9 w-9 text-night-900" />
          )}
        </div>

        <div className="relative mt-5">
          <div className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-700 dark:text-signal-400">
            {eyebrow}
          </div>
          <h2 className="mt-1 font-display text-2xl font-semibold text-navy-950 dark:text-[hsl(var(--text))]">
            {headline}
          </h2>
          {moduleComplete && (
            <p className="mt-1 text-slate-600 dark:text-[hsl(var(--text-muted))]">
              {moduleComplete.title}
            </p>
          )}
        </div>

        {/* Barre de progression (module) */}
        {moduleComplete && (
          <div className="relative mt-5">
            <div className="mb-1.5 flex items-center justify-between text-xs font-medium text-slate-500 dark:text-[hsl(var(--text-muted))]">
              <span>
                {moduleComplete.lessonsTotal} leçon
                {moduleComplete.lessonsTotal > 1 ? "s" : ""} terminée
                {moduleComplete.lessonsTotal > 1 ? "s" : ""}
              </span>
              <span className="font-semibold tabular-nums text-emerald-600">100%</span>
            </div>
            <div className="h-2.5 w-full overflow-hidden rounded-full bg-navy-100 dark:bg-white/10">
              <div
                className="h-full rounded-full bg-gradient-to-r from-signal-400 to-emerald-500 transition-[width] duration-700 ease-premium motion-reduce:transition-none"
                style={{ width: barFilled ? "100%" : "0%" }}
              />
            </div>
          </div>
        )}

        {/* Récompenses */}
        <div className="relative mt-5 space-y-2.5">
          {xpGained > 0 && (
            <div
              className="flex items-center justify-center gap-2 motion-safe:[animation:fade-up_0.45s_ease-out_both]"
              style={{ animationDelay: `${nextDelay()}s` }}
            >
              <span className="inline-flex items-center gap-1.5 rounded-full bg-gold-100 px-3 py-1 text-sm font-semibold text-gold-800 dark:bg-gold-500/15 dark:text-gold-300">
                <Sparkles className="h-3.5 w-3.5" /> +{xpGained} XP
              </span>
            </div>
          )}

          {rankUp && moduleComplete && (
            <div
              className="flex items-center justify-center gap-2 rounded-xl border border-violet-200 bg-violet-50 px-3 py-2 text-sm dark:border-violet-500/30 dark:bg-violet-500/10 motion-safe:[animation:fade-up_0.45s_ease-out_both]"
              style={{ animationDelay: `${nextDelay()}s` }}
            >
              <span aria-hidden>{rankUp.emoji}</span>
              <span className="font-medium text-violet-800 dark:text-violet-200">
                Nouveau rang : <strong>{rankUp.label}</strong>
              </span>
            </div>
          )}

          {badges.map((b, i) => {
            const tier = TIER[b.tier ?? "bronze"] ?? TIER.bronze;
            const Icon = ICONS[b.icon ?? "Award"] ?? Award;
            return (
              <div
                key={i}
                className="flex items-center gap-3 rounded-xl border border-navy-100 bg-ivory px-3 py-2.5 text-left dark:border-[hsl(var(--border))] dark:bg-white/[0.04] motion-safe:[animation:fade-up_0.45s_ease-out_both]"
                style={{ animationDelay: `${nextDelay()}s` }}
              >
                <div className="relative shrink-0">
                  <span
                    aria-hidden
                    className="absolute -inset-1 rounded-xl blur-md"
                    style={{ background: tier.glow }}
                  />
                  <div
                    className={cn(
                      "relative flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br text-white",
                      tier.medal
                    )}
                  >
                    <Icon className="h-5 w-5" />
                  </div>
                </div>
                <div className="min-w-0 flex-1">
                  <div className="flex items-center gap-1.5">
                    <span className="truncate text-sm font-semibold text-navy-900 dark:text-[hsl(var(--text))]">
                      {b.name}
                    </span>
                    <span
                      className={cn(
                        "shrink-0 rounded-md px-1.5 py-0.5 text-[9.5px] font-bold uppercase tracking-wider",
                        tier.chip
                      )}
                    >
                      {tier.label}
                    </span>
                  </div>
                  {b.description && (
                    <p className="truncate text-xs text-slate-500 dark:text-[hsl(var(--text-muted))]">
                      {b.description}
                    </p>
                  )}
                </div>
              </div>
            );
          })}
        </div>

        {moduleComplete && (
          <p className="relative mt-4 text-sm text-slate-600 dark:text-[hsl(var(--text-muted))]">
            Tu te rapproches de ton examen final. Continue comme ça !
          </p>
        )}

        <div className="relative mt-6 flex flex-col gap-2">
          {continueHref ? (
            <Link href={continueHref} className="w-full" onClick={onClose}>
              <Button className="w-full" size="lg">
                Continuer
                <ArrowRight className="h-4 w-4" />
              </Button>
            </Link>
          ) : (
            <Button className="w-full" size="lg" onClick={onClose}>
              Continuer
            </Button>
          )}
          {continueHref && (
            <button
              type="button"
              onClick={onClose}
              className="text-sm font-medium text-slate-500 transition-colors hover:text-navy-900 dark:hover:text-[hsl(var(--text))]"
            >
              Rester sur la leçon
            </button>
          )}
        </div>

        <button
          type="button"
          onClick={onClose}
          aria-label="Fermer"
          className="absolute right-3 top-3 inline-flex h-8 w-8 items-center justify-center rounded-lg text-slate-400 transition-colors hover:bg-navy-50 hover:text-navy-900 dark:hover:bg-white/10"
        >
          <X className="h-4 w-4" />
        </button>
      </div>
    </div>
  );
}
