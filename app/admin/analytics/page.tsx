import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { formatDate, initials, scoreColor } from "@/lib/utils";
import { BarChart3, Trophy, TrendingUp, Download } from "lucide-react";
import { AnalyticsToolbar } from "./analytics-toolbar";
import { DeleteAttemptButton } from "./analytics-row-actions";
import Link from "next/link";

export const dynamic = "force-dynamic";

export default async function AdminAnalytics() {
  const supabase = createClient();
  const [{ data: attempts }, { data: quizzes }] = await Promise.all([
    supabase
      .from("quiz_attempts")
      .select("*, profiles(id, full_name, email), quizzes(title)")
      .order("finished_at", { ascending: false })
      .limit(100),
    supabase.from("quizzes").select("id, title").order("title"),
  ]);

  const passed = attempts?.filter((a) => a.passed).length || 0;
  const avg =
    attempts && attempts.length
      ? Math.round(attempts.reduce((s, a) => s + a.percentage, 0) / attempts.length)
      : 0;
  const successRate = attempts?.length ? Math.round((passed / attempts.length) * 100) : 0;

  return (
    <div className="space-y-8">
      <header>
        <span className="eyebrow text-gold-700">Administration</span>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Performances globales
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Indicateurs agrégés sur les 100 dernières tentatives de quiz.
        </p>
      </header>

      <AnalyticsToolbar quizzes={quizzes ?? []} />

      <section className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <KPI
          icon={BarChart3}
          label="Tentatives"
          value={String(attempts?.length ?? 0)}
          hint="100 dernières"
        />
        <KPI
          icon={TrendingUp}
          label="Moyenne"
          value={`${avg}%`}
          hint="score moyen"
          valueClass={scoreColor(avg)}
        />
        <KPI
          icon={Trophy}
          label="Taux de réussite"
          value={`${successRate}%`}
          hint={`${passed} réussites`}
          accent
        />
      </section>

      <Card>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-navy-50/60 text-[11px] uppercase tracking-wider text-slate-600">
                <th className="text-left px-5 py-3 font-semibold">Étudiant</th>
                <th className="text-left px-5 py-3 font-semibold">Quiz</th>
                <th className="text-left px-5 py-3 font-semibold">Score</th>
                <th className="text-left px-5 py-3 font-semibold">Statut</th>
                <th className="text-left px-5 py-3 font-semibold">Date</th>
                <th className="px-5 py-3" />
              </tr>
            </thead>
            <tbody>
              {attempts?.map((a: any) => (
                <tr key={a.id} className="border-t border-navy-50 hover:bg-navy-50/30">
                  <td className="px-5 py-3.5">
                    <Link
                      href={`/admin/users/${a.profiles?.id}`}
                      className="flex items-center gap-3 group"
                    >
                      <div className="h-7 w-7 rounded-full bg-navy-900 text-gold-400 flex items-center justify-center font-semibold text-[10px]">
                        {initials(a.profiles?.full_name || a.profiles?.email)}
                      </div>
                      <div>
                        <div className="font-medium text-navy-900 group-hover:text-gold-700">
                          {a.profiles?.full_name || a.profiles?.email}
                        </div>
                        <div className="text-xs text-slate-500">
                          {a.profiles?.email}
                        </div>
                      </div>
                    </Link>
                  </td>
                  <td className="px-5 py-3.5 text-slate-700">{a.quizzes?.title}</td>
                  <td
                    className={`px-5 py-3.5 font-display font-semibold ${scoreColor(
                      a.percentage
                    )}`}
                  >
                    {a.percentage}%
                  </td>
                  <td className="px-5 py-3.5">
                    {a.passed ? (
                      <Badge tone="success" size="sm">
                        Réussi
                      </Badge>
                    ) : (
                      <Badge tone="slate" size="sm">
                        Échec
                      </Badge>
                    )}
                  </td>
                  <td className="px-5 py-3.5 text-slate-500 text-xs">
                    {a.finished_at && formatDate(a.finished_at)}
                  </td>
                  <td className="px-5 py-3.5 text-right">
                    <div className="inline-flex items-center gap-1">
                      <a
                        href={`/admin/analytics/export/pdf?attempt=${a.id}`}
                        target="_blank"
                        title="Télécharger la copie corrigée"
                        className="h-7 w-7 rounded-md text-slate-400 hover:text-navy-900 hover:bg-navy-50 inline-flex items-center justify-center"
                      >
                        <Download className="h-3.5 w-3.5" />
                      </a>
                      <DeleteAttemptButton id={a.id} />
                    </div>
                  </td>
                </tr>
              ))}
              {(!attempts || attempts.length === 0) && (
                <tr>
                  <td colSpan={6} className="px-5 py-16 text-center text-slate-400">
                    Aucune tentative pour le moment.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}

function KPI({
  icon: Icon,
  label,
  value,
  hint,
  valueClass,
  accent,
}: {
  icon: any;
  label: string;
  value: string;
  hint?: string;
  valueClass?: string;
  accent?: boolean;
}) {
  return (
    <Card variant={accent ? "gold" : "default"}>
      <CardBody className="flex items-start gap-4">
        <div
          className={
            accent
              ? "h-11 w-11 rounded-xl bg-gold-100 text-gold-800 flex items-center justify-center"
              : "h-11 w-11 rounded-xl bg-navy-50 text-navy-800 flex items-center justify-center"
          }
        >
          <Icon className="h-5 w-5" />
        </div>
        <div>
          <div className="text-[11px] uppercase tracking-wider text-slate-500 font-medium">
            {label}
          </div>
          <div
            className={`font-display text-2xl font-semibold mt-0.5 ${
              valueClass ?? "text-navy-900"
            }`}
          >
            {value}
          </div>
          {hint && <div className="text-xs text-slate-500 mt-0.5">{hint}</div>}
        </div>
      </CardBody>
    </Card>
  );
}
