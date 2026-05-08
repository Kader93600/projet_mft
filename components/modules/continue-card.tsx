import Link from "next/link";
import { findFormation } from "@/lib/formations-config";
import type { ModuleProgress } from "@/lib/module-progress";
import { ArrowRight, Sparkles, Target } from "lucide-react";

/**
 * Bandeau hero "Reprendre" — affiché en haut de la page modules.
 *
 * 3 cas d'usage :
 *  1. Module `in-progress` à reprendre → CTA principal "Reprendre"
 *  2. Module `not-started` à démarrer (premier de la formation) → CTA "Commencer"
 *  3. Tout est terminé → message de félicitations + CTA secondaire vers les
 *     examens blancs ou la soutenance pro.
 *
 * Design : large surface blanche, accent formation discret en arrière-plan,
 * texte généreux. CTA primary (signal-500) — exclusif sur l'écran.
 */
export interface ContinueCardProps {
  /** Prénom du stagiaire (capitalisé). */
  firstName: string | null;
  /** Module à reprendre / démarrer. Null si tout est terminé. */
  nextModule: ModuleProgress | null;
  /** Slug du module à reprendre (pour résoudre le titre, etc.). */
  moduleData?: {
    slug: string;
    title: string;
    formation_slug: string | null;
    duration_min: number | null;
  };
  /** True si tout est terminé. */
  allDone: boolean;
  /** Pourcentage global de complétion de la formation. */
  globalPercent: number;
}

export function ContinueCard({
  firstName,
  nextModule,
  moduleData,
  allDone,
  globalPercent,
}: ContinueCardProps) {
  // Cas 1/2 : module à attaquer
  if (nextModule && moduleData) {
    const f = moduleData.formation_slug
      ? findFormation(moduleData.formation_slug)
      : null;
    const accent = f?.accent ?? "#2530D9";
    const isResume = nextModule.state === "in-progress";

    return (
      <section
        aria-label="Cours à reprendre"
        className="relative overflow-hidden rounded-3xl border border-navy-100 bg-white shadow-soft"
      >
        {/* Accent formation en wash subtil — pas de glassmorphism décoratif */}
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
            <span className="inline-flex items-center gap-1.5 text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-700">
              <Target className="h-3 w-3" />
              {isResume ? "Là où vous vous êtes arrêté" : "Prochaine étape"}
            </span>

            <h2 className="mt-3 font-display text-2xl md:text-[28px] font-semibold text-navy-950 leading-tight tracking-tight text-wrap-balance">
              {moduleData.title}
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
              {moduleData.duration_min && (
                <span className="text-slate-500">
                  ~{moduleData.duration_min} min
                </span>
              )}
              {isResume && nextModule.lessonsTotal > 0 && (
                <span className="text-slate-500">
                  {nextModule.lessonsDone} / {nextModule.lessonsTotal} leçons
                </span>
              )}
            </div>

            {isResume && nextModule.percent > 0 && (
              <div className="mt-5 max-w-md">
                <div
                  className="h-1.5 overflow-hidden rounded-full bg-navy-50"
                  role="progressbar"
                  aria-valuenow={nextModule.percent}
                  aria-valuemin={0}
                  aria-valuemax={100}
                  aria-label={`Progression du module : ${nextModule.percent} %`}
                >
                  <div
                    className="h-full rounded-full transition-[width] duration-700 ease-out"
                    style={{
                      width: `${nextModule.percent}%`,
                      background:
                        "linear-gradient(90deg, #2530D9, #4f46e5, #9FE220)",
                    }}
                  />
                </div>
                <span className="mt-1.5 inline-block text-[12px] text-slate-500">
                  {nextModule.percent} % du module complété
                </span>
              </div>
            )}
          </div>

          {/* CTA primary — exclusif */}
          <Link
            href={`/modules/${moduleData.slug}`}
            className="inline-flex h-11 items-center justify-center gap-2 rounded-xl bg-signal-500 px-6 text-[14px] font-semibold text-night-900 shadow-soft transition-all hover:bg-signal-400 hover:shadow-raised focus:outline-none focus-visible:ring-2 focus-visible:ring-signal-500/40 focus-visible:ring-offset-2 motion-reduce:transition-none"
          >
            {isResume ? "Reprendre" : "Commencer"}
            <ArrowRight className="h-4 w-4" />
          </Link>
        </div>
      </section>
    );
  }

  // Cas 3 : tout est terminé
  if (allDone) {
    return (
      <section
        aria-label="Formation terminée"
        className="relative overflow-hidden rounded-3xl border border-emerald-100 bg-gradient-to-br from-emerald-50/60 via-white to-white p-6 md:p-8 shadow-soft"
      >
        <div
          aria-hidden
          className="pointer-events-none absolute inset-x-0 top-0 h-1 bg-gradient-to-r from-emerald-400 via-signal-500 to-emerald-400"
        />
        <div className="relative">
          <span className="inline-flex items-center gap-1.5 text-[11px] font-semibold uppercase tracking-[0.18em] text-emerald-700">
            <Sparkles className="h-3 w-3" />
            Bravo
          </span>
          <h2 className="mt-3 font-display text-2xl md:text-[28px] font-semibold text-navy-950 leading-tight tracking-tight">
            {firstName
              ? `Vous avez terminé tous les modules, ${firstName}.`
              : "Vous avez terminé tous les modules."}
          </h2>
          <p className="mt-2 max-w-2xl text-[15px] text-slate-600 leading-relaxed">
            Continuez avec les examens blancs et la préparation à l'examen final
            pour confirmer votre maîtrise et arriver serein le jour J.
          </p>
        </div>
      </section>
    );
  }

  // Cas par défaut (aucun module disponible)
  return null;
}
