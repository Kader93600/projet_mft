"use client";

import { useState } from "react";
import { ChevronDown, BookOpen, Check } from "lucide-react";
import { cn } from "@/lib/utils";
import { QuizCard, type QuizCardData } from "./quiz-card";
import type { QuizProgress } from "@/lib/quiz-progress";

/**
 * Accordéon module — regroupe les quiz d'un même module.
 *
 * Header :
 *  - Titre du module
 *  - Compteur de progression : "3/5 réussis" ou "0/5"
 *  - Chevron de toggle
 *  - Si tout réussi : badge ✓ Complet
 *
 * Body : liste des quiz en variant compact (1 ligne chacun).
 *
 * Animation : open/close via transition max-height + opacity.
 * Pas de layout-shift brutal grâce à `transition-[max-height,opacity]`.
 *
 * `defaultOpen` permet d'ouvrir le 1er accordéon de la page par défaut.
 */
export interface ModuleQuizAccordionProps {
  moduleTitle: string;
  moduleSlug: string;
  quizzes: { quiz: QuizCardData; progress: QuizProgress }[];
  defaultOpen?: boolean;
}

export function ModuleQuizAccordion({
  moduleTitle,
  moduleSlug,
  quizzes,
  defaultOpen = false,
}: ModuleQuizAccordionProps) {
  const [open, setOpen] = useState(defaultOpen);
  const passed = quizzes.filter((q) => q.progress.state === "passed").length;
  const total = quizzes.length;
  const allPassed = total > 0 && passed === total;

  return (
    <div
      className={cn(
        "overflow-hidden rounded-2xl border bg-white",
        allPassed ? "border-emerald-100" : "border-navy-100",
        "transition-colors"
      )}
    >
      <button
        type="button"
        onClick={() => setOpen((o) => !o)}
        aria-expanded={open}
        aria-controls={`accordion-${moduleSlug}`}
        className={cn(
          "flex w-full items-center gap-4 px-5 py-4 text-left transition-colors",
          "hover:bg-navy-50/40 focus:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-brand-500/40",
          open && "bg-navy-50/30"
        )}
      >
        <BookOpen
          className={cn(
            "h-4 w-4 shrink-0",
            allPassed ? "text-emerald-600" : "text-slate-400"
          )}
        />
        <div className="min-w-0 flex-1">
          <h3 className="font-display text-[15px] md:text-[16px] font-semibold text-navy-900 leading-snug tracking-tight truncate">
            {moduleTitle}
          </h3>
          <div className="mt-0.5 flex items-center gap-2 text-[12px] text-slate-500 tabular-nums">
            <span>
              {passed}/{total} quiz réussi{passed > 1 ? "s" : ""}
            </span>
            {/* Mini barre */}
            <span
              aria-hidden
              className="ml-1 inline-block h-1 w-20 overflow-hidden rounded-full bg-navy-100"
            >
              <span
                className={cn(
                  "block h-full transition-[width] duration-500 ease-out",
                  allPassed ? "bg-emerald-500" : "bg-brand-500"
                )}
                style={{ width: `${total > 0 ? (passed / total) * 100 : 0}%` }}
              />
            </span>
          </div>
        </div>

        {allPassed && (
          <span className="inline-flex h-5 items-center gap-1 rounded-full bg-emerald-50 px-1.5 text-[10px] font-semibold text-emerald-700 border border-emerald-100">
            <Check className="h-3 w-3" />
            Complet
          </span>
        )}

        <ChevronDown
          className={cn(
            "h-4 w-4 text-slate-400 shrink-0 transition-transform duration-200",
            open && "rotate-180"
          )}
          aria-hidden
        />
      </button>

      {/* Corps */}
      <div
        id={`accordion-${moduleSlug}`}
        role="region"
        aria-labelledby={`accordion-trigger-${moduleSlug}`}
        className={cn(
          "grid transition-[grid-template-rows] duration-300 ease-out",
          "motion-reduce:transition-none",
          open ? "grid-rows-[1fr]" : "grid-rows-[0fr]"
        )}
      >
        <div className="overflow-hidden">
          <div className="border-t border-navy-100 p-3 md:p-4 space-y-2 bg-ivory/30">
            {quizzes.map(({ quiz, progress }) => (
              <QuizCard
                key={quiz.id}
                quiz={quiz}
                progress={progress}
                variant="compact"
              />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
