import { cn } from "@/lib/utils";

interface Day {
  date: string; // YYYY-MM-DD
  count: number;
}

/**
 * Heatmap calendaire façon GitHub : derniers 90 jours.
 */
export function ActivityHeatmap({
  days,
  max,
}: {
  days: Day[];
  max: number;
}) {
  // index par date
  const byDate = new Map(days.map((d) => [d.date, d.count]));
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  // On construit 13 semaines × 7 jours (91 jours) en partant du lundi de la 13e semaine précédente
  const totalDays = 91;
  const start = new Date(today);
  start.setDate(start.getDate() - (totalDays - 1));
  // Reculer jusqu'au lundi pour aligner les colonnes
  const dow = (start.getDay() + 6) % 7; // 0 = lundi
  start.setDate(start.getDate() - dow);

  const cells: { date: Date; count: number; inRange: boolean }[] = [];
  for (let i = 0; i < 98; i++) {
    const d = new Date(start);
    d.setDate(d.getDate() + i);
    const key = d.toISOString().slice(0, 10);
    cells.push({
      date: d,
      count: byDate.get(key) ?? 0,
      inRange: d >= new Date(today.getTime() - (totalDays - 1) * 86400000) && d <= today,
    });
  }

  function level(count: number) {
    if (!count) return 0;
    if (max <= 1) return 4;
    const ratio = count / max;
    if (ratio > 0.75) return 4;
    if (ratio > 0.5) return 3;
    if (ratio > 0.25) return 2;
    return 1;
  }

  const levelClass = [
    "bg-navy-50/60",
    "bg-gold-200",
    "bg-gold-400",
    "bg-gold-500",
    "bg-gold-600",
  ];

  // Group into columns (weeks)
  const weeks: typeof cells[] = [];
  for (let i = 0; i < cells.length; i += 7) {
    weeks.push(cells.slice(i, i + 7));
  }

  return (
    <div className="flex gap-1 overflow-x-auto pb-1">
      {weeks.map((week, wi) => (
        <div key={wi} className="flex flex-col gap-1">
          {week.map((c, ci) => (
            <div
              key={ci}
              title={`${c.date.toLocaleDateString("fr-FR")} — ${c.count} action${
                c.count > 1 ? "s" : ""
              }`}
              className={cn(
                "h-3.5 w-3.5 rounded-[3px] border border-white/40",
                c.inRange ? levelClass[level(c.count)] : "bg-transparent border-transparent"
              )}
            />
          ))}
        </div>
      ))}
    </div>
  );
}
