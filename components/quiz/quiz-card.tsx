"use client";

import Link from "next/link";
import type { QuizProgress } from "@/lib/quiz-progress";
import { findFormation } from "@/lib/formations-config";
import { cn } from "@/lib/utils";
import {
  Clock,
  Target,
  ArrowRight,
  Check,
  X,
  Lock,
  Play,
  RotateCcw,
  GraduationCap,
  FileText,
  Dumbbell,
} from "lucide-react";

/**
 * Carte quiz — 2 variantes :
 *  - "compact"  : 1 ligne dense pour les listes (entraînements dans accordion)
 *  - "featured" : XL pour les examens blancs / MSP / banque entretien
 *
 * États visuels (alignés avec lib/quiz-progress.ts) :
 *  - passed           ✓ vert + score, CTA discret "Refaire"
 *  - failed           • orange + score, CTA mis en avant "Réessayer"
 *  - in-progress      ▸ bleu + accroche, CTA primary "Reprendre"
 *  - todo             gris, CTA "Démarrer"
 *  - blocked-attempts 🔒 + raison, pas de CTA
 *  - blocked-delay    ⏱ + date dispo, pas de CTA
 *  - locked           🔒 + tooltip parcours, pas de CTA
 */
export interface QuizCardData {
  id: string;
  title: string;
  description: string | null;
  type: "entrainement" | "examen" | string;
  is_mock_exam?: boolean | null;
  pass_threshold: number;
  time_limit_s: number | null;
  /** Slug de formation (résolu en amont). */
  formation_slug?: string | null;
  /** Type fonctionnel (pour différencier examens blancs synthèse / module / MSP / final). */
  exam_kind?: "module-exam" | "synthese" | "msp" | "entretien" | null;
}

export interface QuizCardProps {
  quiz: QuizCardData;
  progress: QuizProgress;
  variant?: "compact" | "featured";
}

export function QuizCard({ quiz, progress, variant = "compact" }: QuizCardProps) {
  if (variant === "featured") return <QuizCardFeatured quiz={quiz} progress={progress} />;
  return <QuizCardCompact quiz={quiz} progress={progress} />;
}

// =====================================================================
// Variant COMPACT — 1 ligne pour les listes d'entraînement
// =====================================================================

function QuizCardCompact({ quiz, progress }: { quiz: QuizCardData; progress: QuizProgress }) {
  const isLocked =
    progress.state === "locked" ||
    progress.state === "blocked-attempts" ||
    progress.state === "blocked-delay";

  const wrapperClasses = cn(
    "group relative flex flex-col gap-2 rounded-xl border px-4 py-3 transition-colors duration-150 sm:flex-row sm:items-center sm:gap-4",
    isLocked
      ? "border-slate-200 bg-slate-50/60 cursor-not-allowed opacity-70"
      : progress.state === "passed"
        ? "border-emerald-100 bg-white hover:bg-emerald-50/40 hover:border-emerald-200"
        : progress.state === "in-progress"
          ? "border-brand-100 bg-white hover:bg-brand-50/40 hover:border-brand-200"
          : progress.state === "failed"
            ? "border-rose-100 bg-white hover:bg-rose-50/40 hover:border-rose-200"
            : "border-navy-100 bg-white hover:bg-navy-50/40 hover:border-navy-200"
  );

  const content = (
    <>
      {/* Icône type */}
      <div className="shrink-0">{renderTypeIcon(quiz, "compact")}</div>

      {/* Titre + score */}
      <div className="min-w-0 flex-1">
        <div className="flex items-center gap-2 flex-wrap">
          <span className="text-[14px] font-medium text-navy-900 truncate">
            {quiz.title}
          </span>
          {renderInlineScore(progress)}
        </div>
        {/* Stats meta */}
        <div className="mt-0.5 flex items-center gap-3 text-[11px] text-slate-500">
          {quiz.time_limit_s ? (
            <span className="inline-flex items-center gap-1">
              <Clock className="h-3 w-3" />
              {Math.round(quiz.time_limit_s / 60)} min
            </span>
          ) : null}
          <span className="inline-flex items-center gap-1">
            <Target className="h-3 w-3" />
            seuil {quiz.pass_threshold}%
          </span>
          {progress.attempts_left !== null && progress.state !== "passed" && progress.state !== "locked" && (
            <span className="text-slate-400">
              {progress.attempts_left} tentative{progress.attempts_left > 1 ? "s" : ""} restante{progress.attempts_left > 1 ? "s" : ""}
            </span>
          )}
        </div>
      </div>

      {/* CTA / état bloqué */}
      <div className="shrink-0 sm:ml-auto">
        {renderCTAOrBlock(progress)}
      </div>
    </>
  );

  if (isLocked) {
    const blockReason = renderBlockReason(progress);
    return (
      <div className={wrapperClasses} aria-disabled="true">
        {content}
        {blockReason && (
          <div className="absolute inset-x-0 -bottom-px translate-y-full pt-1 hidden">
            {blockReason}
          </div>
        )}
      </div>
    );
  }

  return (
    <Link
      href={progress.in_progress_attempt_id ? `/quiz/${quiz.id}` : `/quiz/${quiz.id}`}
      className={cn(
        wrapperClasses,
        "focus:outline-none focus-visible:ring-2 focus-visible:ring-offset-1 focus-visible:ring-brand-500/40"
      )}
    >
      {content}
    </Link>
  );
}

// =====================================================================
// Variant FEATURED — XL pour les examens blancs / MSP / final
// =====================================================================

function QuizCardFeatured({ quiz, progress }: { quiz: QuizCardData; progress: QuizProgress }) {
  const isLocked =
    progress.state === "locked" ||
    progress.state === "blocked-attempts" ||
    progress.state === "blocked-delay";

  const examKind = quiz.exam_kind ?? "module-exam";
  const accentColor =
    examKind === "msp"
      ? "#F59E0B" // amber-500
      : examKind === "synthese"
        ? "#D97706" // amber-600
        : examKind === "entretien"
          ? "#475569" // slate-600
          : "#F59E0B"; // module-exam

  const Wrapper = ({ children }: { children: React.ReactNode }) =>
    isLocked ? (
      <div
        aria-disabled="true"
        className={cn(
          "relative block overflow-hidden rounded-2xl border bg-slate-50/60 p-5 md:p-6 cursor-not-allowed",
          "border-slate-200 opacity-75"
        )}
      >
        {children}
      </div>
    ) : (
      <Link
        href={`/quiz/${quiz.id}`}
        className={cn(
          "group relative block overflow-hidden rounded-2xl border bg-white p-5 md:p-6",
          "shadow-soft transition-[transform,box-shadow,border-color] duration-200",
          "hover:-translate-y-0.5 hover:shadow-raised",
          "motion-reduce:hover:translate-y-0 motion-reduce:transition-none",
          "focus:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-amber-500/40",
          progress.state === "passed"
            ? "border-emerald-100 hover:border-emerald-200"
            : progress.state === "in-progress"
              ? "border-brand-100 hover:border-brand-200"
              : progress.state === "failed"
                ? "border-rose-100 hover:border-rose-200"
                : "border-amber-100 hover:border-amber-200"
        )}
      >
        {children}
      </Link>
    );

  return (
    <Wrapper>
      {/* Stripe top — couleur amber pour examens, autres selon état */}
      <div
        aria-hidden
        className="absolute inset-x-0 top-0 h-1"
        style={{
          background: isLocked
            ? "#cbd5e1" // slate-300
            : progress.state === "passed"
              ? "linear-gradient(90deg, #10b981, #6ee7b7)"
              : progress.state === "failed"
                ? "linear-gradient(90deg, #e11d48, #fb7185)"
                : `linear-gradient(90deg, ${accentColor}, ${accentColor}99)`,
        }}
      />

      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0 flex-1">
          <div className="flex items-center gap-2 flex-wrap">
            {renderExamBadge(examKind, isLocked)}
            {renderInlineScore(progress)}
          </div>
          <h3 className="mt-3 font-display text-[17px] md:text-[18px] font-semibold text-navy-900 leading-snug tracking-tight">
            {quiz.title}
          </h3>
          {quiz.description && (
            <p className="mt-1.5 text-[13.5px] text-slate-600 leading-relaxed line-clamp-2">
              {quiz.description}
            </p>
          )}
        </div>
      </div>

      {/* Stats : timer + seuil + attempts */}
      <div className="mt-4 flex items-center gap-4 text-[12px] text-slate-500">
        {quiz.time_limit_s ? (
          <span className="inline-flex items-center gap-1">
            <Clock className="h-3.5 w-3.5" />
            {Math.round(quiz.time_limit_s / 60)} min
          </span>
        ) : null}
        <span className="inline-flex items-center gap-1">
          <Target className="h-3.5 w-3.5" />
          seuil {quiz.pass_threshold}%
        </span>
        {progress.attempts_left !== null && !isLocked && progress.state !== "passed" && (
          <span className="ml-auto text-slate-400">
            {progress.attempts_left} tentative{progress.attempts_left > 1 ? "s" : ""}
          </span>
        )}
      </div>

      {/* Footer : raison de blocage OU CTA */}
      <div className="mt-4">
        {isLocked ? (
          <div className="flex items-center gap-2 text-[12px] text-slate-500 bg-slate-100/60 rounded-lg px-3 py-2">
            {renderLockIcon(progress)}
            <span>{renderLockText(progress)}</span>
          </div>
        ) : (
          <div className="flex items-center justify-end">
            {renderCTAOrBlock(progress, "featured")}
          </div>
        )}
      </div>
    </Wrapper>
  );
}

// =====================================================================
// Helpers de rendu — partagés
// =====================================================================

function renderTypeIcon(quiz: QuizCardData, _variant: "compact" | "featured") {
  const examKind = quiz.exam_kind;
  if (examKind === "msp" || examKind === "entretien") {
    return (
      <span className="inline-flex h-8 w-8 items-center justify-center rounded-lg bg-amber-50 text-amber-700 border border-amber-100">
        <GraduationCap className="h-4 w-4" />
      </span>
    );
  }
  if (examKind === "synthese" || examKind === "module-exam" || quiz.type === "examen") {
    return (
      <span className="inline-flex h-8 w-8 items-center justify-center rounded-lg bg-amber-50 text-amber-700 border border-amber-100">
        <FileText className="h-4 w-4" />
      </span>
    );
  }
  return (
    <span className="inline-flex h-8 w-8 items-center justify-center rounded-lg bg-navy-50 text-navy-700 border border-navy-100">
      <Dumbbell className="h-4 w-4" />
    </span>
  );
}

function renderInlineScore(progress: QuizProgress) {
  if (progress.state === "passed" && progress.best_score != null) {
    return (
      <span className="inline-flex h-5 items-center gap-1 rounded-full bg-emerald-50 border border-emerald-100 px-1.5 text-[11px] font-semibold text-emerald-700 tabular-nums">
        <Check className="h-3 w-3" />
        {progress.best_score} %
      </span>
    );
  }
  if (progress.state === "failed" && progress.best_score != null) {
    return (
      <span className="inline-flex h-5 items-center gap-1 rounded-full bg-rose-50 border border-rose-100 px-1.5 text-[11px] font-semibold text-rose-700 tabular-nums">
        <X className="h-3 w-3" />
        meilleur {progress.best_score} %
      </span>
    );
  }
  if (progress.state === "in-progress") {
    return (
      <span className="inline-flex h-5 items-center gap-1 rounded-full bg-brand-50 border border-brand-100 px-1.5 text-[11px] font-semibold text-brand-700">
        <Play className="h-2.5 w-2.5 fill-current" />
        en cours
      </span>
    );
  }
  return null;
}

function renderExamBadge(
  kind: "module-exam" | "synthese" | "msp" | "entretien",
  isLocked: boolean
) {
  const base =
    "inline-flex h-5 items-center gap-1 rounded-full px-2 text-[10px] font-bold uppercase tracking-[0.12em] border";
  if (isLocked) {
    return (
      <span className={cn(base, "bg-slate-100 text-slate-500 border-slate-200")}>
        <Lock className="h-2.5 w-2.5" />
        Verrouillé
      </span>
    );
  }
  switch (kind) {
    case "msp":
      return (
        <span
          className={cn(base, "bg-amber-100 text-amber-900 border-amber-200")}
        >
          <GraduationCap className="h-2.5 w-2.5" />
          Examen final · 3 h
        </span>
      );
    case "synthese":
      return (
        <span className={cn(base, "bg-amber-50 text-amber-800 border-amber-200")}>
          <FileText className="h-2.5 w-2.5" />
          Examen blanc · bloc
        </span>
      );
    case "entretien":
      return (
        <span className={cn(base, "bg-slate-100 text-slate-700 border-slate-200")}>
          <GraduationCap className="h-2.5 w-2.5" />
          Préparation jury
        </span>
      );
    case "module-exam":
    default:
      return (
        <span className={cn(base, "bg-amber-50 text-amber-700 border-amber-100")}>
          <FileText className="h-2.5 w-2.5" />
          Examen blanc
        </span>
      );
  }
}

function renderCTAOrBlock(
  progress: QuizProgress,
  variant: "compact" | "featured" = "compact"
) {
  // Blocs "verrouillé" : version compacte uniquement (le featured a son propre footer)
  if (variant === "compact") {
    if (progress.state === "blocked-attempts") {
      return (
        <span className="inline-flex items-center gap-1 text-[11px] text-slate-500">
          <Lock className="h-3 w-3" />
          Plus de tentative
        </span>
      );
    }
    if (progress.state === "blocked-delay" && progress.next_available_at) {
      return (
        <span className="inline-flex items-center gap-1 text-[11px] text-slate-500">
          <Clock className="h-3 w-3" />
          {formatNextAvailable(progress.next_available_at)}
        </span>
      );
    }
    if (progress.state === "locked") {
      return (
        <span className="inline-flex items-center gap-1 text-[11px] text-slate-500">
          <Lock className="h-3 w-3" />
          Verrouillé
        </span>
      );
    }
  }

  // CTA actif
  const cta = ctaLabel(progress);
  return (
    <span
      className={cn(
        "inline-flex items-center gap-1 font-medium transition-colors",
        variant === "featured" ? "text-[14px]" : "text-[13px]",
        progress.state === "passed"
          ? "text-emerald-700 group-hover:text-emerald-800"
          : progress.state === "failed"
            ? "text-rose-700 group-hover:text-rose-800"
            : progress.state === "in-progress"
              ? "text-brand-700 group-hover:text-brand-800"
              : "text-navy-900 group-hover:text-brand-700"
      )}
    >
      {cta.icon && <cta.icon className="h-3.5 w-3.5" />}
      {cta.label}
      <ArrowRight className="h-3.5 w-3.5 transition-transform group-hover:translate-x-0.5 motion-reduce:group-hover:translate-x-0" />
    </span>
  );
}

function ctaLabel(progress: QuizProgress): {
  label: string;
  icon: React.ComponentType<{ className?: string }> | null;
} {
  switch (progress.state) {
    case "passed":
      return { label: "Refaire", icon: RotateCcw };
    case "failed":
      return { label: "Réessayer", icon: RotateCcw };
    case "in-progress":
      return { label: "Reprendre", icon: Play };
    case "todo":
      return { label: "Démarrer", icon: null };
    default:
      return { label: "Détails", icon: null };
  }
}

function renderLockIcon(progress: QuizProgress) {
  if (progress.state === "blocked-delay") return <Clock className="h-3.5 w-3.5" />;
  return <Lock className="h-3.5 w-3.5" />;
}

function renderLockText(progress: QuizProgress) {
  if (progress.state === "blocked-attempts") {
    return "Toutes les tentatives ont été utilisées.";
  }
  if (progress.state === "blocked-delay" && progress.next_available_at) {
    return `Disponible ${formatNextAvailable(progress.next_available_at)}`;
  }
  if (progress.state === "locked") {
    return "Terminez les modules de cours pour débloquer cet examen.";
  }
  return "Verrouillé";
}

function renderBlockReason(progress: QuizProgress) {
  if (progress.state === "blocked-attempts") {
    return (
      <span className="text-[11px] text-rose-700">
        Toutes les tentatives utilisées.
      </span>
    );
  }
  if (progress.state === "blocked-delay" && progress.next_available_at) {
    return (
      <span className="text-[11px] text-slate-500">
        Disponible {formatNextAvailable(progress.next_available_at)}
      </span>
    );
  }
  return null;
}

function formatNextAvailable(iso: string) {
  const d = new Date(iso);
  const sameDay = d.toDateString() === new Date().toDateString();
  if (sameDay) {
    return `aujourd'hui à ${d.toLocaleTimeString("fr-FR", { hour: "2-digit", minute: "2-digit" })}`;
  }
  return `le ${d.toLocaleDateString("fr-FR", { day: "2-digit", month: "short", hour: "2-digit", minute: "2-digit" })}`;
}
