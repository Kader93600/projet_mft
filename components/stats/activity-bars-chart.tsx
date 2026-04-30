"use client";
import { useEffect, useMemo, useRef, useState } from "react";

interface DailyRow {
  day: string; // YYYY-MM-DD
  total_seconds: number;
}

/**
 * Histogramme des minutes d'apprentissage sur les 30 derniers jours.
 * Chaque barre grandit de bas en haut au scroll-in (stagger 25ms par barre).
 */
export function ActivityBarsChart({ daily }: { daily: DailyRow[] }) {
  const ref = useRef<HTMLDivElement | null>(null);
  const [animated, setAnimated] = useState(false);
  const [hover, setHover] = useState<number | null>(null);

  useEffect(() => {
    if (typeof window === "undefined") return;
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    if (reduce) {
      setAnimated(true);
      return;
    }
    const el = ref.current;
    if (!el) return;
    const io = new IntersectionObserver(
      (entries) => {
        for (const e of entries) {
          if (e.isIntersecting) {
            setAnimated(true);
            io.disconnect();
            break;
          }
        }
      },
      { threshold: 0.2 }
    );
    io.observe(el);
    return () => io.disconnect();
  }, []);

  const series = useMemo(() => {
    const map = new Map<string, number>();
    daily.forEach((d) => map.set(d.day, d.total_seconds));
    const result: { date: Date; minutes: number; key: string }[] = [];
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    for (let i = 29; i >= 0; i--) {
      const d = new Date(today);
      d.setDate(d.getDate() - i);
      const key = d.toISOString().slice(0, 10);
      const sec = map.get(key) ?? 0;
      result.push({ date: d, minutes: Math.round(sec / 60), key });
    }
    return result;
  }, [daily]);

  const max = Math.max(60, ...series.map((s) => s.minutes));
  const totalMin = series.reduce((s, r) => s + r.minutes, 0);
  const totalH = Math.floor(totalMin / 60);
  const totalRemMin = totalMin % 60;

  const fmt = (d: Date) =>
    d.toLocaleDateString("fr-FR", { weekday: "short", day: "2-digit" });

  return (
    <div ref={ref} className="relative">
      <div className="flex items-baseline justify-between mb-3">
        <div>
          <div className="text-xs uppercase tracking-wider text-slate-500 font-medium">
            30 derniers jours
          </div>
          <div className="font-display text-xl font-semibold text-navy-900 mt-0.5 tabular-nums">
            {totalH > 0 && `${totalH}h `}
            {totalRemMin}min
            <span className="text-sm font-normal text-slate-500 ml-1">
              cumulés
            </span>
          </div>
        </div>
        {hover !== null && (
          <div
            className="text-xs text-navy-700 bg-navy-50 border border-navy-100 rounded-lg px-2.5 py-1"
            style={{ animation: "fade-up 0.2s ease-out both" }}
          >
            <span className="font-mono font-semibold tabular-nums">
              {series[hover].minutes} min
            </span>
            <span className="text-slate-500 ml-1.5">{fmt(series[hover].date)}</span>
          </div>
        )}
      </div>

      <div
        className="flex items-end gap-1 h-32"
        onMouseLeave={() => setHover(null)}
      >
        {series.map((d, i) => {
          const h = max > 0 ? (d.minutes / max) * 100 : 0;
          const isWeekend = [0, 6].includes(d.date.getDay());
          return (
            <div
              key={d.key}
              className="flex-1 h-full flex items-end relative group"
              onMouseEnter={() => setHover(i)}
            >
              <div
                className={
                  "w-full rounded-t transition-[height] motion-reduce:transition-none origin-bottom " +
                  (d.minutes > 0
                    ? isWeekend
                      ? "bg-signal-400"
                      : "bg-brand-500"
                    : "bg-navy-100")
                }
                style={{
                  height: animated ? `${Math.max(2, h)}%` : "0%",
                  transition: `height 900ms cubic-bezier(0.22, 1, 0.36, 1) ${
                    i * 25
                  }ms`,
                  boxShadow:
                    hover === i && d.minutes > 0
                      ? "0 4px 12px -2px rgba(37,48,217,0.4)"
                      : undefined,
                }}
              />
            </div>
          );
        })}
      </div>

      {/* Légende inline */}
      <div className="mt-3 flex items-center justify-between text-[11px] text-slate-500">
        <span>{fmt(series[0].date)}</span>
        <span className="inline-flex items-center gap-3">
          <span className="inline-flex items-center gap-1.5">
            <span className="h-2 w-2 rounded-sm bg-brand-500" />
            Semaine
          </span>
          <span className="inline-flex items-center gap-1.5">
            <span className="h-2 w-2 rounded-sm bg-signal-400" />
            Week-end
          </span>
        </span>
        <span>Aujourd'hui</span>
      </div>
    </div>
  );
}
