"use client";

import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Cell,
} from "recharts";

interface CompletionRow {
  formation_code: string;
  formation_title: string;
  enrolled_count: number;
  completion_pct: number;
  accent_color?: string | null;
}

/**
 * Bar chart horizontal : taux de complétion par formation.
 * Couleur de la barre = accent_color de la formation (signal-lime, gold, etc.).
 */
export function CompletionBars({ data }: { data: CompletionRow[] }) {
  if (!data || data.length === 0) {
    return (
      <div className="h-[280px] flex items-center justify-center text-sm text-slate-400">
        Aucune inscription active pour calculer un taux de complétion.
      </div>
    );
  }

  const formatted = data.map((d) => ({
    name: d.formation_code,
    fullTitle: d.formation_title,
    completion: Number(d.completion_pct) || 0,
    enrolled: d.enrolled_count,
    color: d.accent_color || "#0E1240",
  }));

  return (
    <ResponsiveContainer width="100%" height={Math.max(180, formatted.length * 42)}>
      <BarChart
        data={formatted}
        layout="vertical"
        margin={{ top: 5, right: 50, bottom: 5, left: 8 }}
      >
        <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" horizontal={false} />
        <XAxis
          type="number"
          domain={[0, 100]}
          tickFormatter={(v) => `${v}%`}
          tick={{ fontSize: 11, fill: "#64748b" }}
        />
        <YAxis
          type="category"
          dataKey="name"
          tick={{ fontSize: 11, fill: "#0f172a", fontWeight: 600 }}
          width={70}
        />
        <Tooltip
          contentStyle={{
            background: "#0E1240",
            border: "1px solid #1e293b",
            borderRadius: 8,
            color: "#fff",
            fontSize: 12,
          }}
          formatter={(value: any, _name: any, item: any) => {
            const payload = item?.payload ?? {};
            return [
              `${value} % · ${payload.enrolled ?? 0} inscrits`,
              payload.fullTitle ?? "",
            ];
          }}
          labelStyle={{ color: "#9FE220", fontWeight: 600 }}
        />
        <Bar dataKey="completion" radius={[0, 4, 4, 0]} maxBarSize={22}>
          {formatted.map((entry, idx) => (
            <Cell key={idx} fill={entry.color} />
          ))}
        </Bar>
      </BarChart>
    </ResponsiveContainer>
  );
}
