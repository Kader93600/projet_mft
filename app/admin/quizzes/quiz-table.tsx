"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import { Badge } from "@/components/ui/badge";
import { FormationBadge } from "@/components/formation/formation-badge";
import {
  ChevronRight,
  HelpCircle,
  Clock,
  Search,
  X as XIcon,
} from "lucide-react";

interface QuizRow {
  id: string;
  title: string;
  type: string;
  pass_threshold: number;
  time_limit_s: number | null;
  timer_enabled: boolean | null;
  modules: { id: string; title: string } | null;
  module_id: string | null;
}

interface Props {
  rows: QuizRow[];
  counts: Record<string, number>;
  formationByQuiz: Record<string, string>;
  formations: Array<{ slug: string; code: string }>;
  modules: Array<{ id: string; title: string }>;
  emptyMessage: string;
}

/**
 * Table avec un filtre par colonne (recherche / select selon le type).
 * Filtrage 100% client : la donnée arrive complète depuis le server.
 */
export function QuizTable({
  rows,
  counts,
  formationByQuiz,
  formations,
  modules,
  emptyMessage,
}: Props) {
  // Filtres
  const [titleFilter, setTitleFilter] = useState("");
  const [formationFilter, setFormationFilter] = useState("");
  const [typeFilter, setTypeFilter] = useState("");
  const [moduleFilter, setModuleFilter] = useState("");
  const [questionsMin, setQuestionsMin] = useState("");
  const [timerFilter, setTimerFilter] = useState<"" | "on" | "off">("");
  const [thresholdFilter, setThresholdFilter] = useState("");

  const filtered = useMemo(() => {
    const titleQ = titleFilter.trim().toLowerCase();
    const minQ = questionsMin === "" ? null : parseInt(questionsMin, 10);
    const thr = thresholdFilter === "" ? null : parseInt(thresholdFilter, 10);
    return rows.filter((q) => {
      if (titleQ && !q.title.toLowerCase().includes(titleQ)) return false;
      if (formationFilter) {
        const slug = formationByQuiz[q.id];
        if (slug !== formationFilter) return false;
      }
      if (typeFilter && q.type !== typeFilter) return false;
      if (moduleFilter) {
        const mid = q.module_id ?? q.modules?.id ?? null;
        if (mid !== moduleFilter) return false;
      }
      const nbQ = counts[q.id] ?? 0;
      if (minQ != null && !isNaN(minQ) && nbQ < minQ) return false;
      if (timerFilter === "on" && !(q.timer_enabled && q.time_limit_s)) return false;
      if (timerFilter === "off" && q.timer_enabled && q.time_limit_s) return false;
      if (thr != null && !isNaN(thr) && q.pass_threshold < thr) return false;
      return true;
    });
  }, [
    rows,
    counts,
    formationByQuiz,
    titleFilter,
    formationFilter,
    typeFilter,
    moduleFilter,
    questionsMin,
    timerFilter,
    thresholdFilter,
  ]);

  const hasAnyFilter =
    !!titleFilter ||
    !!formationFilter ||
    !!typeFilter ||
    !!moduleFilter ||
    !!questionsMin ||
    !!timerFilter ||
    !!thresholdFilter;

  function resetAll() {
    setTitleFilter("");
    setFormationFilter("");
    setTypeFilter("");
    setModuleFilter("");
    setQuestionsMin("");
    setTimerFilter("");
    setThresholdFilter("");
  }

  return (
    <div className="overflow-x-auto">
      <table className="w-full text-sm">
        <thead>
          {/* Ligne titres */}
          <tr className="bg-navy-50/60 text-[11px] uppercase tracking-wider text-slate-600">
            <th className="text-left px-5 py-3 font-semibold">Exercice</th>
            <th className="text-left px-5 py-3 font-semibold">Formation</th>
            <th className="text-left px-5 py-3 font-semibold">Type</th>
            <th className="text-left px-5 py-3 font-semibold">Cours</th>
            <th className="text-left px-5 py-3 font-semibold">Questions</th>
            <th className="text-left px-5 py-3 font-semibold">Chrono</th>
            <th className="text-left px-5 py-3 font-semibold">Seuil</th>
            <th className="px-5 py-3 text-right">
              {hasAnyFilter && (
                <button
                  type="button"
                  onClick={resetAll}
                  className="inline-flex items-center gap-1 text-[10px] font-semibold text-rose-700 hover:text-rose-900 normal-case tracking-normal"
                  title="Réinitialiser tous les filtres"
                >
                  <XIcon className="h-3 w-3" />
                  Reset
                </button>
              )}
            </th>
          </tr>

          {/* Ligne filtres */}
          <tr className="bg-white border-b border-navy-100">
            <th className="px-3 py-2 font-normal">
              <div className="relative">
                <Search className="absolute left-2 top-1/2 -translate-y-1/2 h-3 w-3 text-slate-400" />
                <input
                  type="search"
                  value={titleFilter}
                  onChange={(e) => setTitleFilter(e.target.value)}
                  placeholder="Rechercher…"
                  className="w-full pl-7 pr-2 h-7 rounded-md border border-navy-100 bg-white text-[12px] focus:border-navy-300 focus:outline-none"
                />
              </div>
            </th>
            <th className="px-3 py-2 font-normal">
              <select
                value={formationFilter}
                onChange={(e) => setFormationFilter(e.target.value)}
                className="w-full h-7 rounded-md border border-navy-100 bg-white px-2 text-[12px] focus:border-navy-300 focus:outline-none"
              >
                <option value="">Toutes</option>
                {formations.map((f) => (
                  <option key={f.slug} value={f.slug}>
                    {f.code}
                  </option>
                ))}
              </select>
            </th>
            <th className="px-3 py-2 font-normal">
              <select
                value={typeFilter}
                onChange={(e) => setTypeFilter(e.target.value)}
                className="w-full h-7 rounded-md border border-navy-100 bg-white px-2 text-[12px] focus:border-navy-300 focus:outline-none"
              >
                <option value="">Tous</option>
                <option value="entrainement">Entraînement</option>
                <option value="examen">Examen</option>
              </select>
            </th>
            <th className="px-3 py-2 font-normal">
              <select
                value={moduleFilter}
                onChange={(e) => setModuleFilter(e.target.value)}
                className="w-full h-7 rounded-md border border-navy-100 bg-white px-2 text-[12px] focus:border-navy-300 focus:outline-none"
              >
                <option value="">Tous</option>
                {modules.map((m) => (
                  <option key={m.id} value={m.id}>
                    {m.title}
                  </option>
                ))}
              </select>
            </th>
            <th className="px-3 py-2 font-normal">
              <input
                type="number"
                min="0"
                value={questionsMin}
                onChange={(e) => setQuestionsMin(e.target.value)}
                placeholder="≥"
                className="w-full h-7 rounded-md border border-navy-100 bg-white px-2 text-[12px] tabular-nums focus:border-navy-300 focus:outline-none"
                title="Nombre minimum de questions"
              />
            </th>
            <th className="px-3 py-2 font-normal">
              <select
                value={timerFilter}
                onChange={(e) => setTimerFilter(e.target.value as any)}
                className="w-full h-7 rounded-md border border-navy-100 bg-white px-2 text-[12px] focus:border-navy-300 focus:outline-none"
              >
                <option value="">Tous</option>
                <option value="on">Activé</option>
                <option value="off">Désactivé</option>
              </select>
            </th>
            <th className="px-3 py-2 font-normal">
              <input
                type="number"
                min="0"
                max="100"
                value={thresholdFilter}
                onChange={(e) => setThresholdFilter(e.target.value)}
                placeholder="≥ %"
                className="w-full h-7 rounded-md border border-navy-100 bg-white px-2 text-[12px] tabular-nums focus:border-navy-300 focus:outline-none"
                title="Seuil de réussite minimum"
              />
            </th>
            <th className="px-3 py-2 text-right text-[10.5px] text-slate-500">
              {filtered.length}/{rows.length}
            </th>
          </tr>
        </thead>
        <tbody>
          {filtered.map((q) => (
            <tr
              key={q.id}
              className="border-t border-navy-50 hover:bg-navy-50/30 group"
            >
              <td className="px-5 py-3.5">
                <Link
                  href={`/admin/quizzes/${q.id}`}
                  className="font-medium text-navy-900 group-hover:text-gold-700"
                >
                  {q.title}
                </Link>
              </td>
              <td className="px-5 py-3.5">
                {formationByQuiz[q.id] ? (
                  <FormationBadge
                    slug={formationByQuiz[q.id]}
                    size="sm"
                    icon
                  />
                ) : (
                  <span className="text-xs text-slate-400">— Aucune —</span>
                )}
              </td>
              <td className="px-5 py-3.5">
                <Badge tone={q.type === "examen" ? "gold" : "navy"}>
                  {q.type}
                </Badge>
              </td>
              <td className="px-5 py-3.5 text-slate-600 text-xs">
                {q.modules?.title ?? (
                  <span className="text-slate-400">—</span>
                )}
              </td>
              <td className="px-5 py-3.5">
                <span className="inline-flex items-center gap-1 text-slate-600 text-xs">
                  <HelpCircle className="h-3.5 w-3.5" />
                  {counts[q.id] ?? 0}
                </span>
              </td>
              <td className="px-5 py-3.5 text-xs">
                {q.timer_enabled && q.time_limit_s ? (
                  <span className="inline-flex items-center gap-1 text-slate-600">
                    <Clock className="h-3.5 w-3.5" />
                    {Math.round(q.time_limit_s / 60)} min
                  </span>
                ) : (
                  <span className="text-slate-400">—</span>
                )}
              </td>
              <td className="px-5 py-3.5 text-slate-600 text-xs">
                {q.pass_threshold}%
              </td>
              <td className="px-5 py-3.5 text-right">
                <Link
                  href={`/admin/quizzes/${q.id}`}
                  className="inline-flex items-center gap-1 text-xs text-navy-700 group-hover:text-gold-700"
                >
                  Éditer <ChevronRight className="h-3.5 w-3.5" />
                </Link>
              </td>
            </tr>
          ))}
          {filtered.length === 0 && (
            <tr>
              <td
                colSpan={8}
                className="px-5 py-16 text-center text-slate-400 text-sm"
              >
                {rows.length === 0
                  ? emptyMessage
                  : "Aucun quiz ne correspond aux filtres actuels."}
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
