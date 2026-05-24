"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { GraduationCap, ArrowRight, X } from "lucide-react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { ConfettiBurst } from "./confetti-burst";

/**
 * Overlay de célébration affiché quand un stagiaire valide un module
 * (dernière leçon terminée). Premium, motivant, non enfantin.
 *
 * - Modale centrée (origine centre, cf. Emil : les modales ne sont pas
 *   ancrées à un déclencheur), entrée scale+opacity ease-out.
 * - Sceau « compétence débloquée » qui pop, barre de progression à 100 %,
 *   confettis (montés hors prefers-reduced-motion), étape suivante.
 */
export function ModuleCompleteCelebration({
  moduleTitle,
  lessonsTotal,
  continueHref,
  onClose,
}: {
  moduleTitle: string;
  lessonsTotal: number;
  continueHref: string;
  onClose: () => void;
}) {
  const [shown, setShown] = useState(false);
  const [confettiOn, setConfettiOn] = useState(false);
  const [barFilled, setBarFilled] = useState(false);

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

  return (
    <div
      className="fixed inset-0 z-[100] flex items-center justify-center p-4"
      role="dialog"
      aria-modal="true"
      aria-label="Module validé"
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
          count={120}
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
          <GraduationCap className="relative h-9 w-9 text-night-900" />
        </div>

        <div className="relative mt-5">
          <div className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-700 dark:text-signal-400">
            Compétence débloquée
          </div>
          <h2 className="mt-1 font-display text-2xl font-semibold text-navy-950 dark:text-[hsl(var(--text))]">
            Module validé
          </h2>
          <p className="mt-1 text-slate-600 dark:text-[hsl(var(--text-muted))]">
            {moduleTitle}
          </p>
        </div>

        {/* Progression du module → 100 % */}
        <div className="relative mt-5">
          <div className="mb-1.5 flex items-center justify-between text-xs font-medium text-slate-500 dark:text-[hsl(var(--text-muted))]">
            <span>
              {lessonsTotal} leçon{lessonsTotal > 1 ? "s" : ""} terminée
              {lessonsTotal > 1 ? "s" : ""}
            </span>
            <span className="font-semibold tabular-nums text-emerald-600">100%</span>
          </div>
          <div className="h-2.5 w-full overflow-hidden rounded-full bg-navy-100 dark:bg-white/10">
            <div
              className="h-full rounded-full bg-gradient-to-r from-signal-400 to-emerald-500 transition-[width] duration-700 ease-premium motion-reduce:transition-none"
              style={{ width: barFilled ? "100%" : "0%" }}
            />
          </div>
          <p className="mt-3 text-sm text-slate-600 dark:text-[hsl(var(--text-muted))]">
            Tu te rapproches de ton examen final. Continue comme ça !
          </p>
        </div>

        <div className="relative mt-6 flex flex-col gap-2">
          <Link href={continueHref} className="w-full" onClick={onClose}>
            <Button className="w-full" size="lg">
              Continuer
              <ArrowRight className="h-4 w-4" />
            </Button>
          </Link>
          <button
            type="button"
            onClick={onClose}
            className="text-sm font-medium text-slate-500 transition-colors hover:text-navy-900 dark:hover:text-[hsl(var(--text))]"
          >
            Rester sur la leçon
          </button>
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
