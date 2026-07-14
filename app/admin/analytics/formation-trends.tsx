"use client";

import {
  ResponsiveContainer,
  AreaChart,
  Area,
  Tooltip,
  YAxis,
} from "recharts";

import { accentVars } from "@/lib/formation-accent";

interface FormationTrendRow {
  formation_id: string;
  formation_slug: string;
  formation_title: string;
  formation_code: string;
  accent_color: string | null;
  day: string;
  quiz_attempts: number;
}

export function FormationTrendsGrid({ rows }: { rows: FormationTrendRow[] }) {
  // Regroupe par formation
  const byFormation = new Map<
    string,
    {
      formation_id: string;
      formation_title: string;
      formation_code: string;
      accent_color: string | null;
      data: { day: string; quiz_attempts: number }[];
      total: number;
    }
  >();

  for (const r of rows) {
    if (!byFormation.has(r.formation_id)) {
      byFormation.set(r.formation_id, {
        formation_id: r.formation_id,
        formation_title: r.formation_title,
        formation_code: r.formation_code,
        accent_color: r.accent_color,
        data: [],
        total: 0,
      });
    }
    const f = byFormation.get(r.formation_id)!;
    f.data.push({ day: r.day, quiz_attempts: r.quiz_attempts });
    f.total += r.quiz_attempts;
  }

  // Trier par total desc, garder les 6 les plus actives
  const list = Array.from(byFormation.values())
    .sort((a, b) => b.total - a.total)
    .slice(0, 6);

  if (list.length === 0) {
    return (
      <div className="rounded-2xl border border-navy-100 bg-white p-6 text-center text-sm text-slate-500">
        Aucune activité quiz détectée sur les formations actives.
      </div>
    );
  }

  return (
    <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
      {list.map((f) => (
        <div
          key={f.formation_id}
          className="rounded-xl border border-navy-100 bg-white p-3 hover:shadow-soft transition"
        >
          <div className="flex items-center justify-between mb-1.5">
            <span
              className="formation-accent inline-flex items-center px-2 py-0.5 rounded text-[10px] font-semibold"
              style={accentVars(f.accent_color ?? "#0E1240")}
            >
              {f.formation_code}
            </span>
            <span className="text-[11px] font-semibold text-navy-900 tabular-nums">
              {f.total}
            </span>
          </div>
          <div className="text-[10px] text-slate-500 truncate mb-2">
            {f.formation_title}
          </div>
          <div className="h-12 -mx-1">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={f.data}>
                <YAxis hide />
                <Tooltip
                  contentStyle={{
                    background: "#0E1240",
                    border: "1px solid #1e293b",
                    borderRadius: 6,
                    color: "#fff",
                    fontSize: 11,
                    padding: 6,
                  }}
                  labelFormatter={(d) =>
                    new Date(d).toLocaleDateString("fr-FR", {
                      day: "numeric",
                      month: "short",
                    })
                  }
                  formatter={(v: any) => [`${v} quiz`, ""]}
                />
                <Area
                  type="monotone"
                  dataKey="quiz_attempts"
                  stroke={f.accent_color ?? "#0E1240"}
                  fill={f.accent_color ?? "#0E1240"}
                  fillOpacity={0.25}
                  strokeWidth={1.5}
                  dot={false}
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>
      ))}
    </div>
  );
}
