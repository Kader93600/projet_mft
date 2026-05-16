import Link from "next/link";
import {
  Trophy,
  Flame,
  GraduationCap,
  Clock,
  TrendingUp,
  AlertTriangle,
  Sparkles,
  Award,
} from "lucide-react";
import { initials } from "@/lib/utils";

// =====================================================================
// Section : Top 10 stagiaires actifs
// =====================================================================
interface TopStudent {
  user_id: string;
  full_name: string | null;
  email: string;
  lessons_completed_30d: number;
  quiz_attempts_30d: number;
  quiz_passed_30d: number;
  activity_score: number;
  last_quiz_at: string | null;
}

export function TopStudentsSection({ rows }: { rows: TopStudent[] }) {
  if (rows.length === 0) {
    return (
      <div className="rounded-2xl border border-navy-100 bg-white p-6 text-center text-sm text-slate-500">
        Aucune activité sur les 30 derniers jours.
      </div>
    );
  }

  return (
    <div className="rounded-2xl border border-navy-100 bg-white overflow-hidden">
      <div className="px-5 py-3 bg-ivory border-b border-navy-100 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Flame className="h-4 w-4 text-signal-700" />
          <h3 className="font-display font-semibold text-navy-900">
            Top 10 stagiaires actifs
          </h3>
        </div>
        <span className="text-[11px] text-slate-500">30 derniers jours</span>
      </div>
      <ol className="divide-y divide-navy-50">
        {rows.map((s, i) => {
          const medal =
            i === 0 ? "🥇" : i === 1 ? "🥈" : i === 2 ? "🥉" : `#${i + 1}`;
          return (
            <li
              key={s.user_id}
              className="px-5 py-2.5 flex items-center gap-3 hover:bg-ivory/40"
            >
              <div className="w-10 text-center text-sm font-bold text-slate-500">
                {medal}
              </div>
              <Link
                href={`/admin/users/${s.user_id}`}
                className="flex-1 min-w-0 group flex items-center gap-3"
              >
                <div className="h-7 w-7 rounded-full bg-navy-900 text-signal-400 flex items-center justify-center font-semibold text-[10px] shrink-0">
                  {initials(s.full_name || s.email)}
                </div>
                <div className="min-w-0">
                  <div className="font-medium text-navy-900 truncate group-hover:text-signal-700 text-sm">
                    {s.full_name || s.email}
                  </div>
                  <div className="text-[11px] text-slate-500 truncate">
                    {s.lessons_completed_30d} leçons · {s.quiz_attempts_30d} quiz
                    {s.quiz_passed_30d > 0 && ` (${s.quiz_passed_30d} ✓)`}
                  </div>
                </div>
              </Link>
              <div className="font-display text-base font-semibold text-signal-800 tabular-nums">
                {s.activity_score}
              </div>
            </li>
          );
        })}
      </ol>
    </div>
  );
}

// =====================================================================
// Section : Indicateurs Qualiopi
// =====================================================================
interface QualiopiData {
  hours_trained_total: number;
  hours_trained_30d: number;
  abandon_rate_pct: number;
  avg_completion_days: number;
  rncp_success_count: number;
  rncp_attempted_count: number;
  rncp_success_rate_pct: number;
}

export function QualiopiSection({ data }: { data: QualiopiData | null }) {
  const d = data ?? {
    hours_trained_total: 0,
    hours_trained_30d: 0,
    abandon_rate_pct: 0,
    avg_completion_days: 0,
    rncp_success_count: 0,
    rncp_attempted_count: 0,
    rncp_success_rate_pct: 0,
  };

  return (
    <div className="rounded-2xl border border-gold-200 bg-gradient-to-br from-gold-50/30 to-white overflow-hidden">
      <div className="px-5 py-3 border-b border-gold-200 flex items-center gap-2 bg-gold-50/40">
        <Award className="h-4 w-4 text-gold-700" />
        <h3 className="font-display font-semibold text-navy-900">
          Indicateurs Qualiopi / RNCP
        </h3>
        <span className="text-[11px] text-gold-700 ml-auto">
          Pour audit annuel
        </span>
      </div>
      <div className="grid grid-cols-2 md:grid-cols-4 gap-0 divide-x divide-gold-200">
        <KpiCell
          icon={Clock}
          label="Heures formées"
          value={`${Number(d.hours_trained_total).toFixed(0)} h`}
          hint={`${Number(d.hours_trained_30d).toFixed(0)} h ce mois`}
        />
        <KpiCell
          icon={GraduationCap}
          label="Taux RNCP"
          value={`${d.rncp_success_rate_pct}%`}
          hint={`${d.rncp_success_count}/${d.rncp_attempted_count} ex. blancs`}
          accent={d.rncp_success_rate_pct >= 70}
        />
        <KpiCell
          icon={AlertTriangle}
          label="Taux d'abandon"
          value={`${d.abandon_rate_pct}%`}
          hint="Sur formations terminées"
          warning={d.abandon_rate_pct > 20}
        />
        <KpiCell
          icon={TrendingUp}
          label="Délai moyen"
          value={`${d.avg_completion_days} j`}
          hint="Inscription → complétion"
        />
      </div>
    </div>
  );
}

function KpiCell({
  icon: Icon,
  label,
  value,
  hint,
  accent,
  warning,
}: {
  icon: any;
  label: string;
  value: string;
  hint: string;
  accent?: boolean;
  warning?: boolean;
}) {
  return (
    <div className="p-4">
      <div className="flex items-center gap-2 text-[10px] uppercase tracking-wider text-slate-500 font-semibold mb-1.5">
        <Icon className="h-3.5 w-3.5 text-gold-700" />
        {label}
      </div>
      <div
        className={
          "font-display text-2xl font-semibold tabular-nums " +
          (accent
            ? "text-signal-800"
            : warning
              ? "text-rose-700"
              : "text-navy-950")
        }
      >
        {value}
      </div>
      <div className="text-[11px] text-slate-500 mt-0.5">{hint}</div>
    </div>
  );
}

// =====================================================================
// Section : Quiz à difficulté anormale
// =====================================================================
interface QuizOutlier {
  quiz_id: string;
  quiz_title: string;
  is_mock_exam: boolean;
  pass_threshold: number | null;
  attempts_count: number;
  passed_count: number;
  avg_score: number;
  pass_rate_pct: number;
  difficulty_flag: "too_hard" | "too_easy" | "normal" | "unknown";
}

export function QuizOutliersSection({ rows }: { rows: QuizOutlier[] }) {
  if (rows.length === 0) {
    return (
      <div className="rounded-2xl border border-navy-100 bg-white p-6 text-center text-sm text-slate-500">
        Aucun quiz à difficulté anormale détecté sur les 90 derniers jours.
      </div>
    );
  }

  return (
    <div className="rounded-2xl border border-navy-100 bg-white overflow-hidden">
      <div className="px-5 py-3 bg-ivory border-b border-navy-100 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Sparkles className="h-4 w-4 text-brand-700" />
          <h3 className="font-display font-semibold text-navy-900">
            Quiz à difficulté anormale
          </h3>
          <span className="text-xs bg-navy-50 border border-navy-100 rounded-md px-1.5 py-0.5 text-slate-700">
            {rows.length}
          </span>
        </div>
        <span className="text-[11px] text-slate-500">90 derniers jours · &lt;30 % ou &gt;95 %</span>
      </div>
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="bg-navy-50/40 text-[10px] uppercase tracking-wider text-slate-600">
              <th className="text-left px-5 py-2 font-semibold">Quiz</th>
              <th className="text-left px-5 py-2 font-semibold">Tentatives</th>
              <th className="text-left px-5 py-2 font-semibold">Réussite</th>
              <th className="text-left px-5 py-2 font-semibold">Verdict</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-navy-50">
            {rows.map((q) => (
              <tr key={q.quiz_id} className="hover:bg-ivory/40">
                <td className="px-5 py-2.5">
                  <Link
                    href={`/admin/quizzes/${q.quiz_id}`}
                    className="font-medium text-navy-900 hover:text-brand-700 inline-flex items-center gap-2"
                  >
                    {q.quiz_title}
                    {q.is_mock_exam && (
                      <span className="inline-flex items-center gap-0.5 text-[10px] bg-gold-100 text-gold-800 border border-gold-200 rounded px-1.5 py-0.5">
                        <Trophy className="h-2.5 w-2.5" />
                        Examen
                      </span>
                    )}
                  </Link>
                </td>
                <td className="px-5 py-2.5 text-slate-700 tabular-nums">
                  {q.attempts_count}
                </td>
                <td className="px-5 py-2.5">
                  <span
                    className={
                      "font-display font-semibold tabular-nums " +
                      (q.difficulty_flag === "too_hard"
                        ? "text-rose-700"
                        : "text-emerald-700")
                    }
                  >
                    {q.pass_rate_pct}%
                  </span>
                  <span className="text-[11px] text-slate-500 ml-1">
                    ({q.passed_count}/{q.attempts_count})
                  </span>
                </td>
                <td className="px-5 py-2.5">
                  {q.difficulty_flag === "too_hard" ? (
                    <span className="inline-flex items-center gap-1 text-xs font-semibold text-rose-800 bg-rose-50 border border-rose-200 rounded-md px-2 py-0.5">
                      <AlertTriangle className="h-3 w-3" />
                      Trop difficile
                    </span>
                  ) : (
                    <span className="inline-flex items-center gap-1 text-xs font-semibold text-emerald-800 bg-emerald-50 border border-emerald-200 rounded-md px-2 py-0.5">
                      ✓ Trop facile
                    </span>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

// =====================================================================
// Section : CA par formation × pack (tableau croisé)
// =====================================================================
interface RevenueRow {
  formation_id: string;
  formation_slug: string;
  formation_title: string;
  formation_code: string;
  accent_color: string | null;
  pack: "initial" | "medium" | "premium";
  enrollments_count: number;
  revenue_cents: number;
  commitment_cents: number;
}

function fmtEuro(cents: number): string {
  return new Intl.NumberFormat("fr-FR", {
    style: "currency",
    currency: "EUR",
    maximumFractionDigits: 0,
  }).format((cents ?? 0) / 100);
}

export function RevenueMatrixSection({ rows }: { rows: RevenueRow[] }) {
  // Regroupe par formation
  const formations = new Map<
    string,
    {
      formation_id: string;
      formation_code: string;
      formation_title: string;
      accent_color: string | null;
      packs: Record<string, RevenueRow>;
      total_revenue: number;
      total_enrollments: number;
    }
  >();

  for (const r of rows) {
    if (!formations.has(r.formation_id)) {
      formations.set(r.formation_id, {
        formation_id: r.formation_id,
        formation_code: r.formation_code,
        formation_title: r.formation_title,
        accent_color: r.accent_color,
        packs: {},
        total_revenue: 0,
        total_enrollments: 0,
      });
    }
    const f = formations.get(r.formation_id)!;
    f.packs[r.pack] = r;
    f.total_revenue += Number(r.revenue_cents);
    f.total_enrollments += r.enrollments_count;
  }

  const list = Array.from(formations.values()).sort(
    (a, b) => b.total_revenue - a.total_revenue
  );

  if (list.length === 0) {
    return (
      <div className="rounded-2xl border border-navy-100 bg-white p-6 text-center text-sm text-slate-500">
        Aucun encaissement enregistré sur les 12 derniers mois.
      </div>
    );
  }

  const grandTotal = list.reduce((s, f) => s + f.total_revenue, 0);
  const grandEnrollments = list.reduce((s, f) => s + f.total_enrollments, 0);

  return (
    <div className="rounded-2xl border border-navy-100 bg-white overflow-hidden">
      <div className="px-5 py-3 bg-ivory border-b border-navy-100 flex items-center justify-between flex-wrap gap-2">
        <div className="flex items-center gap-2">
          <Trophy className="h-4 w-4 text-gold-700" />
          <h3 className="font-display font-semibold text-navy-900">
            CA par formation &amp; pack
          </h3>
        </div>
        <span className="text-[11px] text-slate-500">
          12 derniers mois · hors abandon/refus
        </span>
      </div>
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="bg-navy-50/40 text-[10px] uppercase tracking-wider text-slate-600">
              <th className="text-left px-5 py-2 font-semibold">Formation</th>
              <th className="text-right px-3 py-2 font-semibold">Initial</th>
              <th className="text-right px-3 py-2 font-semibold">Medium</th>
              <th className="text-right px-3 py-2 font-semibold">Premium</th>
              <th className="text-right px-5 py-2 font-semibold">Total CA</th>
              <th className="text-right px-5 py-2 font-semibold">Inscrits</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-navy-50">
            {list.map((f) => (
              <tr key={f.formation_id} className="hover:bg-ivory/40">
                <td className="px-5 py-2.5">
                  <span
                    className="inline-flex items-center px-2 py-0.5 rounded text-xs font-semibold mr-2"
                    style={{
                      backgroundColor: `${f.accent_color ?? "#0E1240"}22`,
                      color: f.accent_color ?? "#0E1240",
                      border: `1px solid ${f.accent_color ?? "#0E1240"}55`,
                    }}
                  >
                    {f.formation_code}
                  </span>
                  <span className="text-slate-700 text-xs">
                    {f.formation_title}
                  </span>
                </td>
                {(["initial", "medium", "premium"] as const).map((p) => {
                  const cell = f.packs[p];
                  return (
                    <td key={p} className="px-3 py-2.5 text-right tabular-nums">
                      {cell ? (
                        <div>
                          <div className="text-sm font-medium text-navy-900">
                            {fmtEuro(Number(cell.revenue_cents))}
                          </div>
                          <div className="text-[10px] text-slate-500">
                            {cell.enrollments_count} insc.
                          </div>
                        </div>
                      ) : (
                        <span className="text-slate-300">—</span>
                      )}
                    </td>
                  );
                })}
                <td className="px-5 py-2.5 text-right font-display font-semibold text-gold-800 tabular-nums">
                  {fmtEuro(f.total_revenue)}
                </td>
                <td className="px-5 py-2.5 text-right text-slate-700 tabular-nums">
                  {f.total_enrollments}
                </td>
              </tr>
            ))}
            <tr className="bg-navy-50/60 font-semibold">
              <td className="px-5 py-2.5 text-navy-900">Total</td>
              <td colSpan={3} />
              <td className="px-5 py-2.5 text-right font-display text-gold-800 tabular-nums">
                {fmtEuro(grandTotal)}
              </td>
              <td className="px-5 py-2.5 text-right text-navy-900 tabular-nums">
                {grandEnrollments}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  );
}
