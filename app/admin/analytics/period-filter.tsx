"use client";

import { useRouter, useSearchParams } from "next/navigation";
import { useTransition } from "react";

const PERIODS = [
  { label: "7 jours", value: "7" },
  { label: "30 jours", value: "30" },
  { label: "90 jours", value: "90" },
  { label: "12 mois", value: "365" },
] as const;

export function PeriodFilter() {
  const router = useRouter();
  const params = useSearchParams();
  const [, startTransition] = useTransition();
  const current = params?.get("period") ?? "30";

  function setPeriod(value: string) {
    const next = new URLSearchParams(params?.toString() ?? "");
    next.set("period", value);
    startTransition(() => {
      router.replace(`?${next.toString()}`, { scroll: false });
    });
  }

  return (
    <div className="inline-flex bg-white border border-navy-100 rounded-lg p-0.5">
      {PERIODS.map((p) => {
        const active = p.value === current;
        return (
          <button
            key={p.value}
            type="button"
            onClick={() => setPeriod(p.value)}
            className={
              "px-2.5 py-1 text-[11px] font-semibold rounded-md transition " +
              (active
                ? "bg-navy-900 text-white"
                : "text-slate-600 hover:text-navy-900 hover:bg-navy-50")
            }
          >
            {p.label}
          </button>
        );
      })}
    </div>
  );
}

// =====================================================================
// KPI card avec comparaison période précédente
// =====================================================================
export function KpiWithDelta({
  label,
  value,
  previous,
  format,
  hint,
}: {
  label: string;
  value: number;
  previous: number;
  format?: "int" | "euro";
  hint?: string;
}) {
  const fmt = (v: number) => {
    if (format === "euro") {
      return new Intl.NumberFormat("fr-FR", {
        style: "currency",
        currency: "EUR",
        maximumFractionDigits: 0,
      }).format(v / 100);
    }
    return new Intl.NumberFormat("fr-FR").format(v);
  };

  let delta: number | null = null;
  let deltaLabel: string | null = null;
  if (previous > 0) {
    delta = Math.round(((value - previous) / previous) * 100);
    deltaLabel = `${delta > 0 ? "+" : ""}${delta}%`;
  } else if (previous === 0 && value > 0) {
    deltaLabel = "nouveau";
  }

  return (
    <div className="rounded-xl border border-navy-100 bg-white p-3.5">
      <div className="text-[10px] uppercase tracking-wider text-slate-500 font-semibold mb-1">
        {label}
      </div>
      <div className="flex items-baseline gap-2 flex-wrap">
        <div className="font-display text-xl font-semibold text-navy-950 tabular-nums">
          {fmt(value)}
        </div>
        {deltaLabel && (
          <span
            className={
              "text-[11px] font-semibold rounded px-1.5 py-0.5 tabular-nums " +
              (delta === null
                ? "bg-signal-50 text-signal-800 border border-signal-200"
                : delta > 0
                  ? "bg-emerald-50 text-emerald-700 border border-emerald-200"
                  : delta < 0
                    ? "bg-rose-50 text-rose-700 border border-rose-200"
                    : "bg-slate-50 text-slate-600 border border-slate-200")
            }
          >
            {deltaLabel}
          </span>
        )}
      </div>
      {hint && (
        <div className="text-[10px] text-slate-500 mt-0.5">{hint}</div>
      )}
    </div>
  );
}
