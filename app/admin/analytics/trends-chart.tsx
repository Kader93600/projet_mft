"use client";

import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from "recharts";

interface TrendsPoint {
  day: string; // YYYY-MM-DD
  signups: number;
  quiz_attempts: number;
  payments: number;
}

/**
 * Graphique d'activité sur 30 jours.
 * 3 séries empilées : inscriptions, tentatives de quiz, paiements.
 */
export function TrendsChart({ data }: { data: TrendsPoint[] }) {
  // Reformat label : "2026-05-16" → "16 mai"
  const formatted = data.map((d) => ({
    ...d,
    label: new Date(d.day).toLocaleDateString("fr-FR", {
      day: "numeric",
      month: "short",
    }),
  }));

  return (
    <ResponsiveContainer width="100%" height={280}>
      <LineChart
        data={formatted}
        margin={{ top: 5, right: 20, bottom: 5, left: -10 }}
      >
        <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
        <XAxis
          dataKey="label"
          tick={{ fontSize: 11, fill: "#64748b" }}
          interval="preserveStartEnd"
          minTickGap={20}
        />
        <YAxis
          allowDecimals={false}
          tick={{ fontSize: 11, fill: "#64748b" }}
          width={40}
        />
        <Tooltip
          contentStyle={{
            background: "#0E1240",
            border: "1px solid #1e293b",
            borderRadius: 8,
            color: "#fff",
            fontSize: 12,
          }}
          labelStyle={{ color: "#9FE220", fontWeight: 600 }}
        />
        <Legend
          wrapperStyle={{ fontSize: 12, paddingTop: 8 }}
          iconType="circle"
        />
        <Line
          type="monotone"
          dataKey="signups"
          name="Inscriptions"
          stroke="#0E1240"
          strokeWidth={2}
          dot={false}
          activeDot={{ r: 5 }}
        />
        <Line
          type="monotone"
          dataKey="quiz_attempts"
          name="Tentatives quiz"
          stroke="#9FE220"
          strokeWidth={2}
          dot={false}
          activeDot={{ r: 5 }}
        />
        <Line
          type="monotone"
          dataKey="payments"
          name="Paiements"
          stroke="#a16207"
          strokeWidth={2}
          dot={false}
          activeDot={{ r: 5 }}
        />
      </LineChart>
    </ResponsiveContainer>
  );
}
