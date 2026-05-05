import Link from "next/link";
import type { QuizProgress } from "@/lib/quiz-progress";
import { findFormation } from "@/lib/formations-config";
import { ArrowRight, Clock, Play, RotateCcw, Sparkles, Target } from "lucide-react";

/**
 * Bandeau hero "À reprendre / À refaire" — affiché en haut de /quiz si :
 *  - Une tentative est en cours (in-progress) → CTA "Reprendre"
 *  - Sinon, le dernier quiz raté → CTA "Réessayer" en signal-500
 *
 * Si aucun des deux : on n'affiche rien (la page descend directement
 * sur les sections par formation).
 *
 * Design : surface large blanche, accent ambre/brand selon état,
 * CTA primary (signal-500) exclusif sur l'écran.
 */
export interface QuizContinueCardProps {
  /** Progress du quiz à proposer (in-progress ou failed). */
  progress: QuizProgress;
  /** Données du quiz pour l'affichage. */
  quiz: {
    id: string;
    title: string;
    description: string | null;
    pass_threshold: number;
    time_limit_s: number | null;
    formation_slug: string | null;
    module_title: string | null;
  };
}

export function QuizContinueCard({ progress, quiz }: QuizContinueCardProps) {
  const isInProgress = progress.state === "in-progress";
  const isFailed = progress.state === "failed";
  if (!isInProgress && !isFailed) return null;

  const f = quiz.formation_slug ? findFormation(quiz.formation_slug) : null;
  const accent = f?.accent ?? "#2530D9";

  const eyebrow = isInProgress
    ? "Tentative en cours"
    : "À retravailler";
  const cta = isInProgress ? "Reprendre" : "Réessayer";
  const CtaIcon = isInProgress ? Play : RotateCcw;

  return (
    <section
      aria-label={isInProgress ? "Quiz en cours" : "Quiz à refaire"}
      className="relative overflow-hidden rounded-3xl border border-navy-100 bg-white shadow-soft"
    >
      {/* Wash subtil de la couleur formation */}
      <div
        aria-hidden
        className="pointer-events-none absolute -right-24 -top-24 h-64 w-64 rounded-full opacity-50"
        style={{
          background: `radial-gradient(circle, ${accent}26 0%, transparent 65%)`,
        }}
      />
      <div
        aria-hidden
        className="pointer-events-none absolute inset-x-0 top-0 h-1"
        style={{
          background: `linear-gradient(90deg, ${accent}, ${accent}80, transparent)`,
        }}
      />

      <div className="relative grid gap-6 p-6 md:grid-cols-[1fr_auto] md:items-end md:gap-8 md:p-8">
        <div className="min-w-0">
          <span
            className={
              "inline-flex items-center gap-1.5 text-[11px] font-semibold uppercase tracking-[0.18em] " +
              (isFailed ? "text-rose-700" : "text-signal-700")
            }
          >
            {isFailed ? <Sparkles className="h-3 w-3" /> : <Play className="h-3 w-3" />}
            {eyebrow}
          </span>

          <h2 className="mt-3 font-display text-2xl md:text-[28px] font-semibold text-navy-950 leading-tight tracking-tight text-wrap-balance">
            {quiz.title}
          </h2>

          <div className="mt-3 flex flex-wrap items-center gap-x-4 gap-y-1.5 text-[13px] text-slate-600">
            {f && (
              <span className="inline-flex items-center gap-1.5 font-medium">
                <span
                  aria-hidden
                  className="inline-block h-2 w-2 rounded-full"
                  style={{ background: accent }}
                />
                {f.title}
              </span>
            )}
            {quiz.module_title && (
              <span className="text-slate-500 truncate max-w-[280px]">
                {quiz.module_title}
              </span>
            )}
            {quiz.time_limit_s && (
              <span className="text-slate-500 inline-flex items-center gap-1">
                <Clock className="h-3 w-3" />
                {Math.round(quiz.time_limit_s / 60)} min
              </span>
            )}
            <span className="text-slate-500 inline-flex items-center gap-1">
              <Target className="h-3 w-3" />
              seuil {quiz.pass_threshold}%
            </span>
          </div>

          {isFailed && progress.best_score !== null && (
            <p className="mt-3 max-w-md text-[13px] text-slate-600 leading-relaxed">
              Meilleur score précédent :{" "}
              <span className="font-semibold text-rose-700 tabular-nums">
                {progress.best_score} %
              </span>
              . Vous avez encore{" "}
              {progress.attempts_left ?? "plusieurs"} tentative
              {progress.attempts_left === 1 ? "" : "s"} pour atteindre{" "}
              {quiz.pass_threshold} %.
            </p>
          )}
        </div>

        {/* CTA primary — exclusif */}
        <Link
          href={`/quiz/${quiz.id}`}
          className="inline-flex h-11 items-center justify-center gap-2 rounded-xl bg-signal-500 px-6 text-[14px] font-semibold text-night-900 shadow-soft transition-all hover:bg-signal-400 hover:shadow-raised focus:outline-none focus-visible:ring-2 focus-visible:ring-signal-500/40 focus-visible:ring-offset-2 motion-reduce:transition-none"
        >
          <CtaIcon className="h-4 w-4" />
          {cta}
          <ArrowRight className="h-4 w-4" />
        </Link>
      </div>
    </section>
  );
}
