"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import {
  ChevronDown,
  Clock,
  CheckCircle2,
  HelpCircle,
  Target,
  Play,
  Lock,
} from "lucide-react";
import { FormationBadge } from "@/components/formation/formation-badge";

interface EnrichedQuiz {
  id: string;
  title: string;
  description: string | null;
  formation_slug: string | null;
  module_id: string | null;
  module_title: string | null;
  module_order: number;
  bloc_id: number | null;
  time_limit_s: number | null;
  timer_enabled: boolean | null;
  max_attempts: number | null;
  pass_threshold: number;
  question_count: number;
  user_stats: { bestPercent: number; lastAt: string; count: number } | null;
  locked: boolean;
}

/**
 * Catalogue d'exercices d'entraînement.
 * Regroupe par formation → module avec accordion module.
 *
 * Design : vibe entraînement, signal-lime accent, cards aérées,
 * stats personnelles visibles, CTA "Démarrer" immédiat.
 */
export function ExercicesCatalog({
  quizzes,
  formationsAvailable,
}: {
  quizzes: EnrichedQuiz[];
  formationsAvailable: Array<{ slug: string; code: string; accent: string }>;
}) {
  // Groupement formation → module → quizzes
  const grouped = useMemo(() => {
    const byFormation = new Map<string, Map<string | null, EnrichedQuiz[]>>();
    for (const q of quizzes) {
      if (!q.formation_slug) continue;
      if (!byFormation.has(q.formation_slug)) {
        byFormation.set(q.formation_slug, new Map());
      }
      const byModule = byFormation.get(q.formation_slug)!;
      const moduleId = q.module_id ?? null;
      if (!byModule.has(moduleId)) byModule.set(moduleId, []);
      byModule.get(moduleId)!.push(q);
    }
    return byFormation;
  }, [quizzes]);

  const [openModules, setOpenModules] = useState<Set<string>>(() => {
    // Première leçon ouverte par formation par défaut
    const initial = new Set<string>();
    for (const [formationSlug, byModule] of grouped) {
      const firstModuleId = Array.from(byModule.keys()).sort((a, b) => {
        const oa = byModule.get(a)?.[0]?.module_order ?? 999;
        const ob = byModule.get(b)?.[0]?.module_order ?? 999;
        return oa - ob;
      })[0];
      if (firstModuleId !== undefined) {
        initial.add(`${formationSlug}-${firstModuleId ?? "null"}`);
      }
    }
    return initial;
  });

  const toggleModule = (key: string) => {
    const next = new Set(openModules);
    if (next.has(key)) next.delete(key);
    else next.add(key);
    setOpenModules(next);
  };

  return (
    <div className="space-y-8">
      {Array.from(grouped.entries()).map(([formationSlug, byModule], fi) => {
        const modulesArr = Array.from(byModule.entries()).sort((a, b) => {
          const oa = a[1][0]?.module_order ?? 999;
          const ob = b[1][0]?.module_order ?? 999;
          return oa - ob;
        });

        return (
          <section
            key={formationSlug}
            style={{
              animation: `fade-up 0.5s ease-out ${fi * 80}ms both`,
            }}
            className="space-y-3"
          >
            <FormationBadge slug={formationSlug} size="lg" icon withTitle />

            <div className="space-y-2">
              {modulesArr.map(([moduleId, mods], mi) => {
                const moduleTitle = mods[0]?.module_title ?? "Module";
                const key = `${formationSlug}-${moduleId ?? "null"}`;
                const isOpen = openModules.has(key);
                const totalCount = mods.length;
                const doneCount = mods.filter(
                  (q) => (q.user_stats?.bestPercent ?? 0) >= q.pass_threshold,
                ).length;
                const moduleLocked =
                  mods.length > 0 && mods.every((q) => q.locked);

                return (
                  <div
                    key={key}
                    className="rounded-2xl border border-navy-100 bg-white overflow-hidden"
                    style={{
                      animation: `fade-up 0.4s ease-out ${
                        fi * 80 + mi * 50
                      }ms both`,
                    }}
                  >
                    <button
                      type="button"
                      onClick={() => toggleModule(key)}
                      aria-expanded={isOpen}
                      className="w-full flex items-center gap-3 text-left px-4 py-3 hover:bg-ivory transition group"
                    >
                      <ChevronDown
                        className={
                          "h-4 w-4 text-slate-400 shrink-0 transition-transform group-hover:text-navy-900 " +
                          (isOpen ? "rotate-0" : "-rotate-90")
                        }
                        style={{
                          transition:
                            "transform 280ms cubic-bezier(0.22, 1, 0.36, 1)",
                        }}
                      />
                      <div className="flex-1 min-w-0">
                        <h3 className="font-display text-[15px] font-semibold text-navy-900 truncate">
                          {moduleTitle}
                        </h3>
                      </div>
                      <div className="text-[11.5px] text-slate-500 flex items-center gap-1 shrink-0">
                        {moduleLocked && (
                          <Lock className="h-3 w-3 text-slate-400 mr-0.5" />
                        )}
                        <strong className="text-navy-900">{totalCount}</strong>
                        <span>exercice{totalCount > 1 ? "s" : ""}</span>
                        {doneCount > 0 && (
                          <span className="ml-1 text-emerald-700">
                            · {doneCount}✓
                          </span>
                        )}
                      </div>
                    </button>

                    <div
                      className="ccp-collapsible"
                      data-open={isOpen ? "true" : "false"}
                    >
                      <div className="ccp-collapsible-inner">
                        <div className="px-4 pb-4 pt-1 grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
                          {mods.map((q, qi) => (
                            <div
                              key={q.id}
                              style={{
                                animation: isOpen
                                  ? `fade-up 0.35s ease-out ${qi * 35}ms both`
                                  : undefined,
                              }}
                            >
                              <ExerciceCard quiz={q} />
                            </div>
                          ))}
                        </div>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </section>
        );
      })}
    </div>
  );
}

// =====================================================================
// ExerciceCard — vibe entraînement (signal-lime, ouvert, CTA fort)
// =====================================================================
function ExerciceCard({ quiz: q }: { quiz: EnrichedQuiz }) {
  const passed =
    q.user_stats && q.user_stats.bestPercent >= q.pass_threshold;
  const triedNotPassed =
    q.user_stats && q.user_stats.bestPercent < q.pass_threshold;

  // État verrouillé : module précédent non terminé. Card grisée,
  // non cliquable, badge cadenas + consigne (aligné sur /modules).
  if (q.locked) {
    return (
      <div
        aria-disabled
        className="group relative flex flex-col rounded-xl border border-navy-100 bg-slate-50/60 p-3.5 cursor-not-allowed select-none"
      >
        <div className="absolute top-2 right-2 inline-flex items-center gap-1 px-1.5 py-0.5 rounded-md text-[10px] font-bold uppercase tracking-[0.1em] bg-slate-200 text-slate-600">
          <Lock className="h-2.5 w-2.5" />
          Verrouillé
        </div>

        <h4 className="font-display text-[14.5px] font-semibold text-slate-500 leading-snug pr-12">
          {q.title}
        </h4>

        <div className="mt-3 flex items-center gap-2 text-[11px] text-slate-400 flex-wrap">
          <span className="inline-flex items-center gap-1">
            <HelpCircle className="h-3 w-3" />
            {q.question_count} Q
          </span>
          <span className="inline-flex items-center gap-1">
            <Target className="h-3 w-3" />
            {q.pass_threshold}%
          </span>
        </div>

        <div className="mt-auto pt-3 inline-flex items-center gap-1.5 text-[11.5px] font-medium text-slate-500">
          <Lock className="h-3 w-3" />
          Terminez d&apos;abord les leçons du module précédent
        </div>
      </div>
    );
  }

  return (
    <Link
      href={`/quiz/${q.id}`}
      className={
        "group relative flex flex-col rounded-xl border bg-white p-3.5 hover:shadow-soft hover:-translate-y-0.5 transition " +
        (passed
          ? "border-emerald-200 bg-emerald-50/30"
          : "border-navy-100 hover:border-signal-300")
      }
      style={{
        transitionTimingFunction: "cubic-bezier(0.22, 1, 0.36, 1)",
      }}
    >
      {/* Ribbon état */}
      {passed && (
        <div className="absolute top-2 right-2 inline-flex items-center gap-1 px-1.5 py-0.5 rounded-md text-[10px] font-bold uppercase tracking-[0.1em] bg-emerald-500 text-white">
          <CheckCircle2 className="h-2.5 w-2.5" />
          Réussi
        </div>
      )}

      <h4 className="font-display text-[14.5px] font-semibold text-navy-950 leading-snug pr-12">
        {q.title}
      </h4>

      {q.description && (
        <p className="mt-1 text-[12px] text-slate-600 leading-relaxed line-clamp-2">
          {q.description}
        </p>
      )}

      <div className="mt-3 flex items-center gap-2 text-[11px] text-slate-500 flex-wrap">
        <span className="inline-flex items-center gap-1">
          <HelpCircle className="h-3 w-3" />
          {q.question_count} Q
        </span>
        {q.time_limit_s && q.timer_enabled && (
          <span className="inline-flex items-center gap-1">
            <Clock className="h-3 w-3" />
            {Math.round(q.time_limit_s / 60)} min
          </span>
        )}
        <span className="inline-flex items-center gap-1">
          <Target className="h-3 w-3" />
          {q.pass_threshold}%
        </span>
      </div>

      {q.user_stats && (
        <div className="mt-2 flex items-center gap-1.5 text-[11px]">
          <span
            className={
              "font-semibold tabular-nums " +
              (passed
                ? "text-emerald-700"
                : triedNotPassed
                  ? "text-amber-700"
                  : "text-slate-600")
            }
          >
            Meilleur : {q.user_stats.bestPercent}%
          </span>
          <span className="text-slate-400">
            · {q.user_stats.count} essai{q.user_stats.count > 1 ? "s" : ""}
          </span>
        </div>
      )}

      <div className="mt-auto pt-3 inline-flex items-center gap-1 text-[12px] font-semibold text-signal-700 group-hover:text-signal-800 transition-colors duration-200">
        <Play className="h-3 w-3 fill-current" />
        {q.user_stats ? "Refaire" : "Démarrer l'entraînement"}
      </div>
    </Link>
  );
}
