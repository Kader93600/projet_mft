"use client";

import { Users, BookOpen, ListChecks, Trophy, Banknote } from "lucide-react";

interface FunnelData {
  signups: number;
  lesson_viewers: number;
  quiz_attempters: number;
  quiz_passers: number;
  payers: number;
}

const STEPS = [
  { key: "signups", label: "Signups", icon: Users, color: "#0E1240" },
  { key: "lesson_viewers", label: "1ère leçon vue", icon: BookOpen, color: "#1e3a8a" },
  { key: "quiz_attempters", label: "1er quiz tenté", icon: ListChecks, color: "#3b82f6" },
  { key: "quiz_passers", label: "1er quiz réussi", icon: Trophy, color: "#9FE220" },
  { key: "payers", label: "1er paiement", icon: Banknote, color: "#a16207" },
] as const;

export function FunnelChart({ data }: { data: FunnelData | null }) {
  const d = data ?? {
    signups: 0,
    lesson_viewers: 0,
    quiz_attempters: 0,
    quiz_passers: 0,
    payers: 0,
  };

  const top = d.signups || 1;

  return (
    <div className="space-y-2.5">
      {STEPS.map((s, i) => {
        const value = d[s.key as keyof FunnelData] as number;
        const widthPct = top > 0 ? (value / top) * 100 : 0;
        const conversionFromPrev =
          i === 0 || !d[STEPS[i - 1].key as keyof FunnelData]
            ? null
            : Math.round(
                (value / (d[STEPS[i - 1].key as keyof FunnelData] as number)) * 100
              );
        const Icon = s.icon;
        return (
          <div key={s.key} className="space-y-1">
            <div className="flex items-center justify-between text-xs">
              <div className="flex items-center gap-2 text-slate-700 font-medium">
                <Icon className="h-3.5 w-3.5" style={{ color: s.color }} />
                {s.label}
              </div>
              <div className="inline-flex items-center gap-2 tabular-nums">
                <span className="font-display text-base font-semibold text-navy-950">
                  {value}
                </span>
                {conversionFromPrev !== null && (
                  <span
                    className={
                      "text-[11px] font-semibold rounded px-1.5 py-0.5 " +
                      (conversionFromPrev >= 50
                        ? "bg-emerald-50 text-emerald-700 border border-emerald-200"
                        : conversionFromPrev >= 20
                          ? "bg-gold-50 text-gold-800 border border-gold-200"
                          : "bg-rose-50 text-rose-700 border border-rose-200")
                    }
                  >
                    {conversionFromPrev}%
                  </span>
                )}
              </div>
            </div>
            <div className="h-7 bg-navy-50 rounded-md overflow-hidden">
              <div
                className="h-full rounded-md flex items-center justify-end pr-2 text-[10px] font-semibold text-white tabular-nums transition-all"
                style={{
                  width: `${Math.max(widthPct, 2)}%`,
                  backgroundColor: s.color,
                }}
              >
                {widthPct >= 8 && top > 0
                  ? `${Math.round((value / top) * 100)}%`
                  : ""}
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}
