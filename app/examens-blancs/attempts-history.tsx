"use client";

import Link from "next/link";
import { useState } from "react";
import {
  History,
  CheckCircle2,
  XCircle,
  TrendingUp,
  TrendingDown,
  Minus,
  Clock,
  ChevronRight,
} from "lucide-react";

interface AttemptRow {
  id: string;
  quiz_id: string;
  quiz_title: string;
  percentage: number;
  passed: boolean;
  finished_at: string;
  duration_s: number | null;
}

/**
 * Historique compact des 10 dernières tentatives d'examens blancs.
 * Inclut un mini sparkline qui montre la progression dans le temps
 * (tendance ↗ / ↘ / →) pour donner un signal de progression au stagiaire.
 */
export function AttemptsHistory({ attempts }: { attempts: AttemptRow[] }) {
  const [expanded, setExpanded] = useState(false);
  if (attempts.length === 0) return null;

  // Sparkline : on inverse pour avoir l'ordre chronologique (ancien → récent)
  const chronological = [...attempts].reverse();
  const minP = Math.min(...chronological.map((a) => a.percentage));
  const maxP = Math.max(...chronological.map((a) => a.percentage));
  const range = Math.max(1, maxP - minP);
  // Tendance simple : compare moyenne 1ère moitié / 2e moitié
  const half = Math.floor(chronological.length / 2);
  const firstHalfAvg =
    chronological.slice(0, half).reduce((s, a) => s + a.percentage, 0) /
    Math.max(1, half);
  const secondHalfAvg =
    chronological.slice(half).reduce((s, a) => s + a.percentage, 0) /
    Math.max(1, chronological.length - half);
  const trend =
    secondHalfAvg > firstHalfAvg + 5
      ? "up"
      : secondHalfAvg < firstHalfAvg - 5
        ? "down"
        : "flat";

  const validatedCount = attempts.filter((a) => a.passed).length;
  const avgScore = Math.round(
    attempts.reduce((s, a) => s + a.percentage, 0) / attempts.length,
  );

  const visible = expanded ? attempts : attempts.slice(0, 5);

  return (
    <section className="rounded-2xl border border-navy-100 bg-white overflow-hidden">
      <header className="px-4 py-3 border-b border-navy-100 bg-ivory flex items-center justify-between gap-3 flex-wrap">
        <div className="flex items-center gap-2">
          <div className="h-8 w-8 rounded-lg bg-brand-50 inline-flex items-center justify-center">
            <History className="h-4 w-4 text-brand-700" />
          </div>
          <div>
            <h2 className="font-display text-[15px] font-semibold text-navy-950">
              Historique de mes tentatives
            </h2>
            <p className="text-[11.5px] text-slate-500">
              {attempts.length} dernière{attempts.length > 1 ? "s" : ""}{" "}
              tentative{attempts.length > 1 ? "s" : ""}
              {validatedCount > 0 && ` · ${validatedCount} validée${validatedCount > 1 ? "s" : ""}`}
              {avgScore > 0 && ` · moyenne ${avgScore}%`}
            </p>
          </div>
        </div>

        {/* Sparkline simple */}
        <div className="flex items-center gap-2">
          <div className="flex items-end gap-0.5 h-7 px-1.5 rounded-md bg-white border border-navy-100">
            {chronological.map((a, i) => {
              const h = Math.max(3, ((a.percentage - minP) / range) * 24);
              return (
                <div
                  key={a.id}
                  className={
                    "w-1 rounded-sm " +
                    (a.passed ? "bg-emerald-500" : "bg-rose-400")
                  }
                  style={{ height: `${h}px` }}
                  title={`${a.percentage}% — ${formatDate(a.finished_at)}`}
                />
              );
            })}
          </div>
          <div
            className={
              "inline-flex items-center gap-1 text-[11px] font-semibold " +
              (trend === "up"
                ? "text-emerald-700"
                : trend === "down"
                  ? "text-rose-700"
                  : "text-slate-500")
            }
          >
            {trend === "up" ? (
              <TrendingUp className="h-3 w-3" />
            ) : trend === "down" ? (
              <TrendingDown className="h-3 w-3" />
            ) : (
              <Minus className="h-3 w-3" />
            )}
            {trend === "up"
              ? "En progression"
              : trend === "down"
                ? "En baisse"
                : "Stable"}
          </div>
        </div>
      </header>

      <ul className="divide-y divide-navy-100">
        {visible.map((a) => (
          <li key={a.id}>
            <Link
              href={`/quiz/results/${a.id}`}
              className="flex items-center gap-3 px-4 py-2.5 hover:bg-ivory transition group"
            >
              {a.passed ? (
                <CheckCircle2 className="h-4 w-4 text-emerald-600 shrink-0" />
              ) : (
                <XCircle className="h-4 w-4 text-rose-500 shrink-0" />
              )}
              <div className="flex-1 min-w-0">
                <div className="text-[13.5px] font-semibold text-navy-900 truncate">
                  {a.quiz_title}
                </div>
                <div className="text-[11px] text-slate-500 inline-flex items-center gap-2 flex-wrap">
                  <span>{formatDate(a.finished_at)}</span>
                  {a.duration_s && (
                    <span className="inline-flex items-center gap-0.5">
                      <Clock className="h-2.5 w-2.5" />
                      {Math.round(a.duration_s / 60)} min
                    </span>
                  )}
                </div>
              </div>
              <div
                className={
                  "font-display text-base font-semibold tabular-nums shrink-0 " +
                  (a.passed ? "text-emerald-700" : "text-rose-700")
                }
              >
                {a.percentage}%
              </div>
              <ChevronRight className="h-3.5 w-3.5 text-slate-300 group-hover:text-navy-700 transition shrink-0" />
            </Link>
          </li>
        ))}
      </ul>

      {attempts.length > 5 && (
        <div className="px-4 py-2 border-t border-navy-100 bg-ivory text-center">
          <button
            type="button"
            onClick={() => setExpanded(!expanded)}
            className="text-[12px] font-semibold text-brand-700 hover:text-brand-900"
          >
            {expanded
              ? "Réduire"
              : `Voir les ${attempts.length - 5} autres tentatives`}
          </button>
        </div>
      )}
    </section>
  );
}

function formatDate(iso: string): string {
  const d = new Date(iso);
  return d.toLocaleString("fr-FR", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}
