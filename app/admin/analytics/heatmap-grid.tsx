"use client";

import { useMemo } from "react";

interface HeatmapCell {
  day_of_week: number; // 0=dim, 1=lun, ..., 6=sam
  hour_of_day: number;
  attempts: number;
}

const DAYS_FR = ["Dim", "Lun", "Mar", "Mer", "Jeu", "Ven", "Sam"];
// Ordre d'affichage Lun→Dim (plus naturel en France)
const DAY_ORDER = [1, 2, 3, 4, 5, 6, 0];

export function HeatmapGrid({ cells }: { cells: HeatmapCell[] }) {
  const grid = useMemo(() => {
    const map = new Map<string, number>();
    for (const c of cells) {
      map.set(`${c.day_of_week}-${c.hour_of_day}`, c.attempts);
    }
    return map;
  }, [cells]);

  const max = useMemo(
    () => Math.max(1, ...cells.map((c) => c.attempts)),
    [cells]
  );

  return (
    <div className="space-y-1.5">
      {/* En-tête : heures groupées par 3 */}
      <div className="flex items-center gap-px pl-[44px]">
        {Array.from({ length: 24 }, (_, h) => (
          <div
            key={h}
            className="flex-1 text-[9px] text-slate-400 text-center font-medium tabular-nums"
            style={{ minWidth: 0 }}
          >
            {h % 3 === 0 ? `${h}h` : ""}
          </div>
        ))}
      </div>
      {/* Grille */}
      {DAY_ORDER.map((dow) => (
        <div key={dow} className="flex items-center gap-px">
          <div className="w-[40px] text-[10px] font-semibold text-slate-600 pr-1 text-right">
            {DAYS_FR[dow]}
          </div>
          {Array.from({ length: 24 }, (_, h) => {
            const value = grid.get(`${dow}-${h}`) ?? 0;
            const intensity = max > 0 ? value / max : 0;
            return (
              <div
                key={h}
                className="flex-1 h-5 rounded-[2px] transition cursor-default"
                style={{
                  minWidth: 0,
                  backgroundColor:
                    value === 0
                      ? "#f1f5f9"
                      : intensityToColor(intensity),
                }}
                title={`${DAYS_FR[dow]} ${h}h → ${value} tentative${
                  value > 1 ? "s" : ""
                }`}
              />
            );
          })}
        </div>
      ))}
      {/* Légende */}
      <div className="flex items-center justify-end gap-2 text-[10px] text-slate-500 mt-3 pt-2">
        <span>Moins</span>
        <div className="flex gap-px">
          {[0.1, 0.3, 0.5, 0.7, 1].map((i) => (
            <div
              key={i}
              className="w-3 h-3 rounded-[2px]"
              style={{ backgroundColor: intensityToColor(i) }}
            />
          ))}
        </div>
        <span>Plus</span>
        <span className="ml-2 text-slate-400">(90 derniers jours · max {max})</span>
      </div>
    </div>
  );
}

// Échelle de couleur navy → signal-lime
function intensityToColor(t: number): string {
  // Interpolation linéaire entre #f1f5f9 (presque vide) → #9FE220 (max)
  // En 3 paliers : faible (slate), moyen (signal claire), fort (signal foncé)
  if (t < 0.25) return `rgba(159, 226, 32, ${0.15 + t * 1.4})`;
  if (t < 0.65) return `rgba(159, 226, 32, ${0.45 + t * 0.4})`;
  return `rgba(127, 181, 26, ${0.7 + t * 0.3})`;
}
