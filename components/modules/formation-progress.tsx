import { findFormation } from "@/lib/formations-config";

/**
 * Barre de progression formation — compacte, intégrable :
 *  - Dans le header d'une FormationSection
 *  - Dans un récap haut de page si plusieurs formations
 *
 * Affichage :
 *  - Libellé formation à gauche, % à droite
 *  - Barre fine 4px, gradient couleur formation → signal-500
 *  - Sous-texte : "X / Y modules terminés"
 */
export interface FormationProgressProps {
  formationSlug: string;
  modulesTotal: number;
  modulesDone: number;
  /** Affichage compact (dans une row) ou complet (header) */
  compact?: boolean;
}

export function FormationProgress({
  formationSlug,
  modulesTotal,
  modulesDone,
  compact = false,
}: FormationProgressProps) {
  const f = findFormation(formationSlug);
  const accent = f?.accent ?? "#2530D9";
  const percent =
    modulesTotal === 0 ? 0 : Math.round((modulesDone / modulesTotal) * 100);

  if (compact) {
    return (
      <div className="flex items-center gap-3">
        <span className="text-[12px] font-medium text-slate-700 shrink-0 min-w-[60px]">
          {percent} %
        </span>
        <div
          className="h-1.5 flex-1 overflow-hidden rounded-full bg-navy-50"
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
              background: `linear-gradient(90deg, ${accent}, ${accent}cc, #9FE220)`,
            }}
          />
        </div>
        <span className="text-[12px] text-slate-500 shrink-0 tabular-nums">
          {modulesDone}/{modulesTotal}
        </span>
      </div>
    );
  }

  return (
    <div className="space-y-1.5">
      <div className="flex items-baseline justify-between gap-3">
        <span className="text-[12px] font-medium text-slate-700">
          Progression
        </span>
        <span className="text-[12px] text-slate-500 tabular-nums">
          {modulesDone} / {modulesTotal} modules
          <span className="ml-2 font-semibold text-navy-900">{percent} %</span>
        </span>
      </div>
      <div
        className="h-1.5 w-full overflow-hidden rounded-full bg-navy-50"
        role="progressbar"
        aria-valuenow={percent}
        aria-valuemin={0}
        aria-valuemax={100}
      >
        <div
          className="h-full rounded-full transition-[width] duration-500 ease-out"
          style={{
            width: `${percent}%`,
            background: `linear-gradient(90deg, ${accent}, ${accent}cc, #9FE220)`,
          }}
        />
      </div>
    </div>
  );
}
