"use client";

import Link from "next/link";
import {
  Clock,
  HelpCircle,
  Target,
  Trophy,
  ShieldCheck,
  Layers,
  Globe2,
  ChevronRight,
  CheckCircle2,
  AlertTriangle,
  Lock,
} from "lucide-react";
import { FormationBadge } from "@/components/formation/formation-badge";

interface ExamData {
  id: string;
  title: string;
  description: string | null;
  formation_slug: string | null;
  module_id: string | null;
  module_title: string | null;
  module_order: number;
  scope: "module" | "global";
  time_limit_s: number | null;
  timer_enabled: boolean | null;
  max_attempts: number | null;
  retake_delay_hours: number | null;
  pass_threshold: number;
  is_mock_exam: boolean | null;
  question_count: number;
  user_stats: {
    bestPercent: number;
    lastAt: string;
    count: number;
    passed: boolean;
  } | null;
  locked: boolean;
}

/**
 * Onglets visuels par catégorie d'examen blanc :
 *   - "Par module" : examens scopés à un module spécifique
 *   - "Globaux"    : examens couvrant toute la formation
 *
 * Navigation server-side via URL ?tab=module|global pour bookmark.
 */
export function ExamensTabs({
  moduleExams,
  globalExams,
  activeTab,
  filterFormation,
}: {
  moduleExams: ExamData[];
  globalExams: ExamData[];
  activeTab: "module" | "global";
  filterFormation: string | null;
}) {
  const exams = activeTab === "global" ? globalExams : moduleExams;
  const fParam = filterFormation ? `&f=${filterFormation}` : "";
  const fParamFirst = filterFormation ? `?f=${filterFormation}` : "";

  return (
    <div className="space-y-5">
      {/* Onglets */}
      <div className="inline-flex rounded-xl bg-ivory border border-navy-100 p-1 gap-0.5">
        <Link
          href={`/examens-blancs${fParamFirst}`}
          className={
            "inline-flex items-center gap-2 px-4 py-2 rounded-lg text-[13px] font-semibold transition " +
            (activeTab === "module"
              ? "bg-white text-navy-950 shadow-soft"
              : "text-slate-600 hover:text-navy-900 hover:bg-white/60")
          }
        >
          <Layers className="h-4 w-4" />
          Par module
          <span
            className={
              "inline-flex items-center justify-center rounded-md text-[10.5px] font-bold tabular-nums px-1.5 h-4 min-w-4 " +
              (activeTab === "module"
                ? "bg-amber-100 text-amber-900"
                : "bg-navy-100 text-navy-700")
            }
          >
            {moduleExams.length}
          </span>
        </Link>
        <Link
          href={`/examens-blancs?tab=global${fParam}`}
          className={
            "inline-flex items-center gap-2 px-4 py-2 rounded-lg text-[13px] font-semibold transition " +
            (activeTab === "global"
              ? "bg-white text-navy-950 shadow-soft"
              : "text-slate-600 hover:text-navy-900 hover:bg-white/60")
          }
        >
          <Globe2 className="h-4 w-4" />
          Examens globaux
          <span
            className={
              "inline-flex items-center justify-center rounded-md text-[10.5px] font-bold tabular-nums px-1.5 h-4 min-w-4 " +
              (activeTab === "global"
                ? "bg-amber-100 text-amber-900"
                : "bg-navy-100 text-navy-700")
            }
          >
            {globalExams.length}
          </span>
        </Link>
      </div>

      {/* Description du tab */}
      <div className="text-[13px] text-slate-600 leading-relaxed max-w-2xl">
        {activeTab === "module" ? (
          <>
            <strong className="text-navy-900">Examens blancs ciblés</strong>{" "}
            sur un module précis. Idéal pour valider une matière avant de
            passer à la suivante.
          </>
        ) : (
          <>
            <strong className="text-navy-900">Simulations complètes</strong>{" "}
            couvrant l'ensemble de la formation, à la manière du jour J.
            Notation globale et chronomètre serré.
          </>
        )}
      </div>

      {/* Liste */}
      {exams.length === 0 ? (
        <div className="rounded-xl border border-dashed border-navy-200 bg-ivory px-4 py-8 text-center text-sm text-slate-500">
          {activeTab === "module"
            ? "Aucun examen par module pour cette formation."
            : "Aucun examen global pour cette formation."}
        </div>
      ) : (
        <div className="grid gap-3 md:grid-cols-2">
          {exams
            .sort((a, b) => {
              // Par module : trier par order du module puis titre
              if (a.scope === "module" && b.scope === "module") {
                if (a.module_order !== b.module_order)
                  return a.module_order - b.module_order;
              }
              return a.title.localeCompare(b.title);
            })
            .map((exam, i) => (
              <div
                key={exam.id}
                style={{
                  animation: `fade-up 0.4s ease-out ${i * 50}ms both`,
                }}
              >
                <ExamenCard exam={exam} />
              </div>
            ))}
        </div>
      )}
    </div>
  );
}

// =====================================================================
// ExamenCard — vibe officielle, gold/amber, timer visible
// =====================================================================
function ExamenCard({ exam: q }: { exam: ExamData }) {
  const passed = q.user_stats?.passed ?? false;
  const triedNotPassed = q.user_stats && !passed;

  // Stats détaillées sur les tentatives
  const remainingAttempts =
    q.max_attempts != null
      ? Math.max(0, q.max_attempts - (q.user_stats?.count ?? 0))
      : null;

  const timerMinutes = q.timer_enabled && q.time_limit_s
    ? Math.round(q.time_limit_s / 60)
    : null;

  // État verrouillé : module précédent non terminé. Card grisée,
  // non cliquable (aligné sur /modules et /exercices).
  if (q.locked) {
    return (
      <div
        aria-disabled
        className="relative flex flex-col rounded-2xl border border-navy-100 bg-slate-50/60 p-4 cursor-not-allowed select-none overflow-hidden"
      >
        <div className="flex items-start justify-between gap-2 mb-2">
          <div className="flex items-center gap-1.5 flex-wrap">
            {q.formation_slug && (
              <FormationBadge slug={q.formation_slug} size="sm" />
            )}
          </div>
          <span className="inline-flex items-center gap-1 px-1.5 py-0.5 rounded-md text-[9.5px] font-bold uppercase tracking-[0.12em] bg-slate-200 text-slate-600 shrink-0">
            <Lock className="h-2.5 w-2.5" />
            Verrouillé
          </span>
        </div>

        <h3 className="font-display text-[15px] font-semibold text-slate-500 leading-snug">
          {q.title}
        </h3>
        {q.module_title && q.scope === "module" && (
          <div className="mt-0.5 text-[11.5px] text-slate-400">
            {q.module_title}
          </div>
        )}

        <div className="mt-3 flex items-center gap-3 text-[11.5px] text-slate-400 flex-wrap">
          <span className="inline-flex items-center gap-1">
            <HelpCircle className="h-3 w-3" />
            {q.question_count} questions
          </span>
          <span className="inline-flex items-center gap-1">
            <Target className="h-3 w-3" />
            seuil {q.pass_threshold}%
          </span>
        </div>

        <div className="mt-auto pt-3 inline-flex items-center gap-1.5 text-[12px] font-medium text-slate-500">
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
        "group relative flex flex-col rounded-2xl border bg-white p-4 hover:shadow-raised hover:-translate-y-0.5 transition overflow-hidden " +
        (passed
          ? "border-emerald-200 bg-emerald-50/30"
          : "border-amber-200 hover:border-amber-400")
      }
      style={{ transitionTimingFunction: "cubic-bezier(0.22, 1, 0.36, 1)" }}
    >
      {/* Bandeau supérieur "officiel" */}
      <div
        aria-hidden
        className="absolute top-0 left-0 right-0 h-0.5 bg-gradient-to-r from-amber-500 via-amber-300 to-amber-500"
      />

      {/* Header avec badges */}
      <div className="flex items-start justify-between gap-2 mb-2">
        <div className="flex items-center gap-1.5 flex-wrap">
          {q.formation_slug && (
            <FormationBadge slug={q.formation_slug} size="sm" />
          )}
          {q.is_mock_exam && (
            <span className="inline-flex items-center gap-1 px-1.5 py-0.5 rounded-md text-[9.5px] font-bold uppercase tracking-[0.12em] bg-amber-500 text-night-900">
              <ShieldCheck className="h-2.5 w-2.5" />
              Examen blanc
            </span>
          )}
          {q.scope === "global" && (
            <span className="inline-flex items-center gap-1 px-1.5 py-0.5 rounded-md text-[9.5px] font-bold uppercase tracking-[0.12em] bg-brand-100 text-brand-800 border border-brand-200">
              <Globe2 className="h-2.5 w-2.5" />
              Global
            </span>
          )}
        </div>
        {passed && (
          <span className="inline-flex items-center gap-1 px-1.5 py-0.5 rounded-md text-[9.5px] font-bold uppercase tracking-[0.12em] bg-emerald-500 text-white shrink-0">
            <CheckCircle2 className="h-2.5 w-2.5" />
            Validé
          </span>
        )}
      </div>

      {/* Titre */}
      <h3 className="font-display text-[15px] font-semibold text-navy-950 leading-snug">
        {q.title}
      </h3>
      {q.module_title && q.scope === "module" && (
        <div className="mt-0.5 text-[11.5px] text-slate-500">
          {q.module_title}
        </div>
      )}

      {q.description && (
        <p className="mt-2 text-[12.5px] text-slate-600 leading-relaxed line-clamp-2">
          {q.description}
        </p>
      )}

      {/* Métadonnées */}
      <div className="mt-3 flex items-center gap-3 text-[11.5px] text-slate-600 flex-wrap">
        <span className="inline-flex items-center gap-1">
          <HelpCircle className="h-3 w-3 text-amber-700" />
          {q.question_count} questions
        </span>
        {timerMinutes && (
          <span className="inline-flex items-center gap-1 font-semibold text-amber-800">
            <Clock className="h-3 w-3" />
            {timerMinutes} min
          </span>
        )}
        <span className="inline-flex items-center gap-1">
          <Target className="h-3 w-3 text-slate-400" />
          seuil {q.pass_threshold}%
        </span>
      </div>

      {/* Stats user */}
      {q.user_stats && (
        <div className="mt-3 rounded-lg bg-ivory border border-navy-100 px-2.5 py-1.5 flex items-center justify-between gap-2 flex-wrap">
          <div className="flex items-center gap-1.5 text-[11.5px]">
            <Trophy
              className={
                "h-3 w-3 " +
                (passed
                  ? "text-emerald-600"
                  : triedNotPassed
                    ? "text-amber-600"
                    : "text-slate-400")
              }
            />
            <span
              className={
                "font-semibold tabular-nums " +
                (passed
                  ? "text-emerald-700"
                  : triedNotPassed
                    ? "text-amber-800"
                    : "text-slate-700")
              }
            >
              Meilleur : {q.user_stats.bestPercent}%
            </span>
            <span className="text-slate-400">
              · {q.user_stats.count} tentative
              {q.user_stats.count > 1 ? "s" : ""}
            </span>
          </div>
          {remainingAttempts !== null && remainingAttempts <= 1 && (
            <span
              className={
                "inline-flex items-center gap-1 text-[10.5px] font-semibold " +
                (remainingAttempts === 0
                  ? "text-rose-700"
                  : "text-amber-700")
              }
            >
              <AlertTriangle className="h-2.5 w-2.5" />
              {remainingAttempts === 0
                ? "Limite atteinte"
                : "Dernière tentative"}
            </span>
          )}
        </div>
      )}

      {/* CTA */}
      <div className="mt-auto pt-3 inline-flex items-center justify-between gap-1 text-[13px] font-semibold text-amber-800">
        <span className="inline-flex items-center gap-1">
          {q.user_stats ? "Repasser" : "Commencer l'examen blanc"}
        </span>
        <ChevronRight className="h-3.5 w-3.5 transition-transform group-hover:translate-x-1" />
      </div>
    </Link>
  );
}
