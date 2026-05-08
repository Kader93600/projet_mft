"use client";

import Link from "next/link";
import { useState } from "react";
import { findFormation } from "@/lib/formations-config";
import type { ModuleState, ModuleKind } from "@/lib/module-progress";
import { cn } from "@/lib/utils";
import {
  ArrowRight,
  Clock,
  BookOpen,
  ListChecks,
  Lock,
  Check,
  Play,
  FileText,
  GraduationCap,
  Sparkles,
  Trophy,
  Flame,
} from "lucide-react";

/**
 * Card module — surface premium réutilisable.
 *
 * Refonte 2026-05 : intègre les 4 états de progression (done, in-progress,
 * not-started, locked) avec un traitement visuel discret mais sans ambiguïté.
 *
 * Design (DESIGN.md) :
 *  - Bg blanc, border navy-100, rounded-2xl, shadow-soft
 *  - Stripe 4px gradient couleur formation en haut
 *  - Header : code formation (chip) + durée + indicateur d'état (top right)
 *  - Titre h3 (font-display, Bricolage Grotesque)
 *  - Footer : barre de progression fine + difficulty + CTA contextuel
 *
 * Accessibilité :
 *  - Tile cliquable (Link englobe la card) sauf si locked → div + cadenas
 *  - prefers-reduced-motion désactive translate
 *  - aria-label complet (titre + état + progression)
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
  /** État de progression — défaut: not-started si non précisé. */
  state?: ModuleState;
  /** Type dérivé du slug — défaut: 'course' */
  kind?: ModuleKind;
  /** Pourcentage 0-100 de complétion. */
  percent?: number;
  /** Nb de leçons complétées (pour afficher "3 / 4 leçons"). */
  lessons_done?: number;
}

const difficultyLabel: Record<string, string> = {
  debutant: "Débutant",
  intermediaire: "Intermédiaire",
  avance: "Avancé",
};

export function ModuleCard({ module: m }: { module: ModuleCardData }) {
  const [hovered, setHovered] = useState(false);
  const formation = m.formation_slug ? findFormation(m.formation_slug) : null;
  const accent = formation?.accent ?? "#9FE220";
  const state: ModuleState = m.state ?? "not-started";
  const kind: ModuleKind = m.kind ?? "course";
  const percent = clamp(m.percent ?? 0, 0, 100);

  // ----- Locked : div statique, pas de Link
  if (state === "locked") {
    return (
      <div
        aria-disabled="true"
        aria-label={`${m.title} (verrouillé, terminez le module précédent pour débloquer)`}
        className={cn(
          "relative block overflow-hidden rounded-2xl border border-slate-200 bg-slate-50/60",
          "transition-colors duration-200 select-none cursor-not-allowed"
        )}
      >
        <div
          aria-hidden
          className="absolute inset-x-0 top-0 h-1 bg-slate-200"
        />
        <div className="p-5 md:p-6 flex flex-col h-full min-h-[210px] opacity-60">
          <div className="flex items-start justify-between gap-3">
            <span className="inline-flex items-center gap-1.5 rounded-md bg-slate-100 px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.14em] text-slate-500 border border-slate-200">
              {formation?.code ?? "Module"}
            </span>
            <span className="inline-flex items-center gap-1 text-[11px] font-medium text-slate-500 shrink-0">
              <Lock className="h-3 w-3" />
              Verrouillé
            </span>
          </div>
          <h3 className="mt-4 font-display text-[17px] md:text-[18px] font-semibold text-slate-700 leading-snug tracking-tight">
            {m.title}
          </h3>
          {m.summary && (
            <p className="mt-2 text-[13.5px] text-slate-500 leading-relaxed line-clamp-2">
              {m.summary}
            </p>
          )}
          <div className="mt-auto pt-5 text-[12px] text-slate-500 leading-snug">
            Terminez le module précédent pour débloquer celui-ci.
          </div>
        </div>
      </div>
    );
  }

  // ----- Done / in-progress / not-started : Link cliquable

  const stateBadge = renderStateBadge(state, kind);
  const accentText = shadeForText(accent);
  const ariaLabel = buildAriaLabel(m, state, percent);

  return (
    <Link
      href={`/modules/${m.slug}`}
      aria-label={ariaLabel}
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      onFocus={() => setHovered(true)}
      onBlur={() => setHovered(false)}
      className={cn(
        "group relative block overflow-hidden rounded-2xl border bg-white",
        state === "done"
          ? "border-emerald-100/80"
          : state === "in-progress"
            ? "border-brand-100"
            : "border-navy-100",
        "shadow-soft transition-[transform,box-shadow,border-color] duration-200",
        "hover:-translate-y-0.5 hover:shadow-raised",
        state === "done"
          ? "hover:border-emerald-200"
          : state === "in-progress"
            ? "hover:border-brand-200"
            : "hover:border-navy-200",
        "motion-reduce:hover:translate-y-0 motion-reduce:transition-none",
        "focus:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-brand-500/40"
      )}
    >
      {/* Stripe formation 4px, opacité augmentée au hover */}
      <div
        aria-hidden
        className="absolute inset-x-0 top-0 h-1 transition-opacity duration-200"
        style={{
          background:
            state === "done"
              ? "linear-gradient(90deg, #10b981, #6ee7b7)"
              : `linear-gradient(90deg, ${accent}, ${accent}80)`,
          opacity: hovered ? 1 : 0.85,
        }}
      />

      <div className="p-5 md:p-6 flex flex-col h-full min-h-[210px]">
        {/* Header : code formation + état + durée */}
        <div className="flex items-start justify-between gap-3">
          {formation ? (
            <span
              className="inline-flex items-center gap-1.5 rounded-md px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.14em]"
              style={{
                background: `${accent}1A`,
                color: accentText,
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

          <div className="flex items-center gap-2 shrink-0">
            {stateBadge}
            {m.duration_min ? (
              <span className="inline-flex items-center gap-1 text-[12px] text-slate-500">
                <Clock className="h-3 w-3" />
                {m.duration_min} min
              </span>
            ) : null}
          </div>
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

        {/* Stats inline (toujours visibles, pas de hover) */}
        <div className="mt-4 flex items-center gap-4 text-[11.5px] text-slate-500">
          {typeof m.lessons_count === "number" && m.lessons_count > 0 && (
            <span className="inline-flex items-center gap-1">
              <BookOpen className="h-3 w-3" />
              {typeof m.lessons_done === "number" && state !== "not-started"
                ? `${m.lessons_done} / ${m.lessons_count} leçons`
                : `${m.lessons_count} leçon${m.lessons_count > 1 ? "s" : ""}`}
            </span>
          )}
          {typeof m.quizzes_count === "number" && m.quizzes_count > 0 && (
            <span className="inline-flex items-center gap-1">
              <ListChecks className="h-3 w-3" />
              {m.quizzes_count} quiz
            </span>
          )}
        </div>

        {/* Footer : barre progression + difficulty + CTA */}
        <div className="mt-auto pt-4">
          {/* Barre de progression — visible si in-progress ou done */}
          {(state === "in-progress" || state === "done") && (
            <div className="mb-3">
              <div
                className="h-1 w-full overflow-hidden rounded-full bg-navy-50"
                role="progressbar"
                aria-valuenow={percent}
                aria-valuemin={0}
                aria-valuemax={100}
                aria-label={`Progression : ${percent} %`}
              >
                <div
                  className="h-full rounded-full transition-[width] duration-500 ease-out"
                  style={{
                    width: `${percent}%`,
                    background:
                      state === "done"
                        ? "linear-gradient(90deg, #10b981, #34d399)"
                        : "linear-gradient(90deg, #2530D9, #4f46e5)",
                  }}
                />
              </div>
            </div>
          )}

          <div className="flex items-center justify-between">
            {m.difficulty ? (
              <span className="text-[10px] uppercase tracking-[0.14em] font-semibold text-slate-500">
                {difficultyLabel[m.difficulty] ?? m.difficulty}
              </span>
            ) : (
              <span />
            )}
            <span
              className={cn(
                "inline-flex items-center gap-1 text-[13px] font-medium transition-colors",
                state === "done" ? "text-emerald-700" : "text-navy-900"
              )}
              style={{
                color: hovered && state !== "done" ? accentText : undefined,
              }}
            >
              {state === "done"
                ? "Revoir"
                : state === "in-progress"
                  ? "Continuer"
                  : "Commencer"}
              <ArrowRight
                className={cn(
                  "h-3.5 w-3.5 transition-transform",
                  "group-hover:translate-x-0.5 motion-reduce:group-hover:translate-x-0"
                )}
              />
            </span>
          </div>
        </div>
      </div>

      {/*
        Hover overlay — slide-in depuis le bas avec une vue enrichie.
        Apparaît UNIQUEMENT au hover/focus. Sur mobile (pas de hover),
        le contenu reste accessible via les stats inline ci-dessus.
        prefers-reduced-motion : on dégrade en simple fade sans translate.
      */}
      <div
        aria-hidden
        className={cn(
          "pointer-events-none absolute inset-x-0 bottom-0 px-5 md:px-6 pt-3 pb-4",
          "border-t backdrop-blur-[2px]",
          state === "done"
            ? "border-emerald-100 bg-gradient-to-b from-white/95 via-white to-emerald-50/40"
            : state === "in-progress"
              ? "border-brand-100 bg-gradient-to-b from-white/95 via-white to-brand-50/40"
              : "border-navy-100 bg-gradient-to-b from-white/95 via-white to-navy-50/40",
          "transition-[transform,opacity] duration-[260ms] ease-[cubic-bezier(0.22,1,0.36,1)]",
          "motion-reduce:transition-opacity motion-reduce:duration-150",
          hovered
            ? "translate-y-0 opacity-100 motion-reduce:translate-y-0"
            : "translate-y-full opacity-0 motion-reduce:translate-y-0"
        )}
      >
        {/* Tagline / accroche */}
        <div className="flex items-start gap-2">
          {state === "done" ? (
            <Trophy
              className="h-3.5 w-3.5 shrink-0 mt-0.5 text-emerald-600"
              strokeWidth={2.2}
            />
          ) : state === "in-progress" ? (
            <Flame
              className="h-3.5 w-3.5 shrink-0 mt-0.5 text-brand-600"
              strokeWidth={2.2}
            />
          ) : (
            <Sparkles
              className="h-3.5 w-3.5 shrink-0 mt-0.5"
              style={{ color: accentText }}
              strokeWidth={2.2}
            />
          )}
          <p className="text-[12.5px] leading-snug text-slate-700 font-medium">
            {buildOverlayTagline(m, state, percent)}
          </p>
        </div>

        {/* Stats détaillées en pied d'overlay */}
        <div className="mt-2.5 flex items-center gap-3.5 text-[11px] text-slate-600 tabular-nums">
          {typeof m.lessons_count === "number" && m.lessons_count > 0 && (
            <span className="inline-flex items-center gap-1">
              <BookOpen className="h-3 w-3" />
              {typeof m.lessons_done === "number"
                ? `${m.lessons_done}/${m.lessons_count}`
                : m.lessons_count}
              <span className="text-slate-400">leçons</span>
            </span>
          )}
          {typeof m.quizzes_count === "number" && m.quizzes_count > 0 && (
            <span className="inline-flex items-center gap-1">
              <ListChecks className="h-3 w-3" />
              {m.quizzes_count}
              <span className="text-slate-400">quiz</span>
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

// ---------------------------------------------------------------------
// Helpers internes
// ---------------------------------------------------------------------

function renderStateBadge(state: ModuleState, kind: ModuleKind) {
  if (state === "done") {
    return (
      <span className="inline-flex h-5 items-center gap-1 rounded-full bg-emerald-50 px-1.5 text-[10px] font-semibold text-emerald-700 border border-emerald-100">
        <Check className="h-3 w-3" />
        Terminé
      </span>
    );
  }
  if (state === "in-progress") {
    return (
      <span className="inline-flex h-5 items-center gap-1 rounded-full bg-brand-50 px-1.5 text-[10px] font-semibold text-brand-700 border border-brand-100">
        <Play className="h-2.5 w-2.5 fill-current" />
        En cours
      </span>
    );
  }
  // not-started : on n'affiche un picto que pour les types "exam" / "final"
  if (kind === "exam") {
    return (
      <span className="inline-flex h-5 items-center gap-1 rounded-full bg-amber-50 px-1.5 text-[10px] font-semibold text-amber-700 border border-amber-100">
        <FileText className="h-2.5 w-2.5" />
        Examen blanc
      </span>
    );
  }
  if (kind === "final") {
    return (
      <span className="inline-flex h-5 items-center gap-1 rounded-full bg-amber-100 px-1.5 text-[10px] font-semibold text-amber-800 border border-amber-200">
        <GraduationCap className="h-2.5 w-2.5" />
        Soutenance
      </span>
    );
  }
  return null;
}

function buildAriaLabel(m: ModuleCardData, state: ModuleState, percent: number) {
  const stateText =
    state === "done"
      ? "terminé"
      : state === "in-progress"
        ? `en cours, ${percent} pour cent`
        : "à commencer";
  return `${m.title} — ${stateText}. Cliquez pour ouvrir le module.`;
}

/**
 * Phrase d'accroche révélée au hover. Diffère selon l'état pour donner
 * du contexte plutôt que de répéter le summary déjà visible.
 */
function buildOverlayTagline(
  m: ModuleCardData,
  state: ModuleState,
  percent: number
): string {
  if (state === "done") {
    return "Cours terminé. Revisitez les notions clés ou refaites un exercice.";
  }
  if (state === "in-progress") {
    if (percent >= 75) return `Plus que ${100 - percent} % avant de boucler ce module.`;
    if (percent >= 40) return "Belle progression. Continuez sur votre lancée.";
    return "Reprenez là où vous vous êtes arrêté.";
  }
  // not-started : on prend le tagline ou une troncature courte du summary
  if (m.tagline) return m.tagline;
  if (m.summary) {
    const trimmed = m.summary.trim();
    return trimmed.length > 130 ? trimmed.slice(0, 127) + "…" : trimmed;
  }
  return "Démarrez ce module et progressez à votre rythme.";
}

function clamp(n: number, min: number, max: number) {
  return Math.max(min, Math.min(max, n));
}

/**
 * Pour les chips et accents textuels : on assombrit le hex de base de
 * façon à garantir la lisibilité sur fond clair (WCAG AA).
 */
function shadeForText(hex: string): string {
  const h = hex.replace("#", "");
  if (h.length < 6) return hex;
  const r = parseInt(h.slice(0, 2), 16);
  const g = parseInt(h.slice(2, 4), 16);
  const b = parseInt(h.slice(4, 6), 16);
  const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
  const factor = luminance > 0.7 ? 0.55 : luminance > 0.5 ? 0.7 : 0.85;
  const dark = (c: number) =>
    Math.max(0, Math.round(c * factor)).toString(16).padStart(2, "0");
  return `#${dark(r)}${dark(g)}${dark(b)}`;
}
