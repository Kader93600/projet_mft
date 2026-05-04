"use client";

import Link from "next/link";
import { useState } from "react";
import { findFormation } from "@/lib/formations-config";
import { cn } from "@/lib/utils";
import {
  ArrowRight,
  Clock,
  BookOpen,
  ListChecks,
  Sparkles,
} from "lucide-react";

/**
 * Card module — surface premium réutilisable.
 *
 * Design (DESIGN.md) :
 *  - Bg blanc, border navy-100, rounded-2xl, shadow-soft
 *  - Stripe 4px gradient couleur formation en haut
 *  - Header : code formation (chip) + durée
 *  - Titre h3 (Bricolage Grotesque)
 *  - Summary 2 lignes (line-clamp)
 *  - Footer : difficulty + "Ouvrir →"
 *
 * Hover :
 *  - Translate-y -2px + shadow-raised
 *  - Stripe passe en gradient plus opaque
 *  - Overlay info en bas slide-in (translateY 100% → 0, 200ms ease-out-expo)
 *    avec phrase d'accroche + 3 stats (leçons, quiz, niveau)
 *
 * Accessibilité :
 *  - Tile entièrement cliquable (le Link englobe la card)
 *  - prefers-reduced-motion désactive translate + slide-in
 */
export interface ModuleCardData {
  id: string;
  slug: string;
  title: string;
  summary: string | null;
  duration_min: number | null;
  difficulty: "debutant" | "intermediaire" | "avance" | string | null;
  formation_slug: string | null;
  /** Nb de leçons, calculé en amont */
  lessons_count?: number;
  /** Nb de quiz, calculé en amont */
  quizzes_count?: number;
  /** Phrase d'accroche révélée au hover. Si absent, on dérive du summary. */
  tagline?: string | null;
}

export function ModuleCard({ module: m }: { module: ModuleCardData }) {
  const [hovered, setHovered] = useState(false);
  const formation = m.formation_slug ? findFormation(m.formation_slug) : null;
  const accent = formation?.accent ?? "#9FE220";

  const difficultyLabel: Record<string, string> = {
    debutant: "Débutant",
    intermediaire: "Intermédiaire",
    avance: "Avancé",
  };

  return (
    <Link
      href={`/modules/${m.slug}`}
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      onFocus={() => setHovered(true)}
      onBlur={() => setHovered(false)}
      className={cn(
        "group relative block overflow-hidden rounded-2xl border border-navy-100 bg-white",
        "shadow-soft transition-[transform,box-shadow,border-color] duration-200",
        "hover:-translate-y-0.5 hover:shadow-raised hover:border-navy-200",
        "motion-reduce:hover:translate-y-0 motion-reduce:transition-none",
        "focus:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-brand-500/40"
      )}
    >
      {/* Stripe formation 4 px, opacité augmentée au hover */}
      <div
        aria-hidden
        className="absolute inset-x-0 top-0 h-1 transition-opacity duration-200"
        style={{
          background: `linear-gradient(90deg, ${accent}, ${accent}80)`,
          opacity: hovered ? 1 : 0.85,
        }}
      />

      <div className="p-5 md:p-6 flex flex-col h-full min-h-[210px]">
        {/* Header : code formation + durée */}
        <div className="flex items-start justify-between gap-3">
          {formation ? (
            <span
              className="inline-flex items-center gap-1.5 rounded-md px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.14em]"
              style={{
                background: `${accent}1A`,
                color: shadeForText(accent),
                border: `1px solid ${accent}40`,
              }}
            >
              {formation.code}
            </span>
          ) : (
            <span className="inline-flex items-center gap-1.5 rounded-md bg-navy-50 px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.14em] text-slate-600 border border-navy-100">
              Module
            </span>
          )}

          {m.duration_min ? (
            <span className="inline-flex items-center gap-1 text-[12px] text-slate-500 shrink-0">
              <Clock className="h-3 w-3" />
              {m.duration_min} min
            </span>
          ) : null}
        </div>

        {/* Titre */}
        <h3 className="mt-4 font-display text-[17px] md:text-[18px] font-semibold text-navy-900 leading-snug tracking-tight text-wrap-balance">
          {m.title}
        </h3>

        {/* Summary 2 lignes */}
        {m.summary ? (
          <p className="mt-2 text-[13.5px] text-slate-600 leading-relaxed line-clamp-2">
            {m.summary}
          </p>
        ) : null}

        {/* Footer : difficulty + Ouvrir */}
        <div className="mt-auto pt-5 flex items-center justify-between">
          {m.difficulty ? (
            <span className="text-[10px] uppercase tracking-[0.14em] font-semibold text-slate-500">
              {difficultyLabel[m.difficulty] ?? m.difficulty}
            </span>
          ) : (
            <span />
          )}
          <span
            className="inline-flex items-center gap-1 text-[13px] font-medium text-navy-900 transition-colors"
            style={{
              color: hovered ? shadeForText(accent) : undefined,
            }}
          >
            Ouvrir
            <ArrowRight
              className={cn(
                "h-3.5 w-3.5 transition-transform",
                "group-hover:translate-x-0.5 motion-reduce:group-hover:translate-x-0"
              )}
            />
          </span>
        </div>
      </div>

      {/* Hover overlay — slide-in depuis le bas avec stats + accroche */}
      <div
        aria-hidden
        className={cn(
          "absolute inset-x-0 bottom-0 px-5 md:px-6 pt-4 pb-5",
          "border-t border-navy-100 bg-gradient-to-b from-white via-white to-navy-50/40",
          "transition-[transform,opacity] duration-200 ease-[cubic-bezier(0.22,1,0.36,1)]",
          "motion-reduce:transition-none motion-reduce:translate-y-0",
          hovered
            ? "translate-y-0 opacity-100"
            : "translate-y-full opacity-0 pointer-events-none"
        )}
      >
        {/* Phrase d'accroche */}
        {(m.tagline || m.summary) && (
          <div className="flex items-start gap-2">
            <Sparkles
              className="h-3.5 w-3.5 shrink-0 mt-0.5"
              style={{ color: shadeForText(accent) }}
            />
            <p className="text-[12.5px] leading-snug text-slate-700 font-medium">
              {m.tagline ?? m.summary}
            </p>
          </div>
        )}

        {/* Stats compactes */}
        <div className="mt-3 flex items-center gap-4 text-[11px] text-slate-600">
          {typeof m.lessons_count === "number" && (
            <span className="inline-flex items-center gap-1">
              <BookOpen className="h-3 w-3" />
              {m.lessons_count} leçon{m.lessons_count > 1 ? "s" : ""}
            </span>
          )}
          {typeof m.quizzes_count === "number" && (
            <span className="inline-flex items-center gap-1">
              <ListChecks className="h-3 w-3" />
              {m.quizzes_count} quiz
            </span>
          )}
          {m.duration_min ? (
            <span className="inline-flex items-center gap-1 ml-auto">
              <Clock className="h-3 w-3" />~{Math.round(m.duration_min / 60)} h
            </span>
          ) : null}
        </div>
      </div>
    </Link>
  );
}

/**
 * Pour les chips et accents textuels, on assombrit le hex de base de
 * façon à garantir la lisibilité sur fond clair (WCAG AA).
 *
 * En pratique pour nos couleurs formation (toutes situées dans la zone
 * mid-saturation), on retire ~15 % de luminosité.
 */
function shadeForText(hex: string): string {
  // Conversion grossière hex → HSL → assombrissement → hex
  const h = hex.replace("#", "");
  if (h.length < 6) return hex;
  const r = parseInt(h.slice(0, 2), 16);
  const g = parseInt(h.slice(2, 4), 16);
  const b = parseInt(h.slice(4, 6), 16);
  // Pour signal-green (#9FE220) la version texte est signal-700 ≈ #5D8A0F
  // On applique un facteur d'assombrissement adaptatif selon la luminosité.
  const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
  const factor = luminance > 0.7 ? 0.55 : luminance > 0.5 ? 0.7 : 0.85;
  const dark = (c: number) => Math.max(0, Math.round(c * factor)).toString(16).padStart(2, "0");
  return `#${dark(r)}${dark(g)}${dark(b)}`;
}
