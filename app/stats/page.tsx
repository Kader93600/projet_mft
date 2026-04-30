import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { ProgressBar, RadialProgress } from "@/components/ui/progress";
import { scoreColor, formatDate } from "@/lib/utils";
import {
  ClipboardCheck,
  Trophy,
  BarChart3,
  Download,
  TrendingUp,
  TrendingDown,
  Minus,
  Layers,
  CalendarRange,
  Timer,
  BookOpen,
} from "lucide-react";
import { ActivityHeatmap } from "@/components/activity-heatmap";
import { ScoreEvolutionChart } from "@/components/stats/score-evolution-chart";
import { ActivityBarsChart } from "@/components/stats/activity-bars-chart";

export const dynamic = "force-dynamic";

const LEVEL_LABEL: Record<string, string> = {
  debutant: "Débutant",
  intermediaire: "Intermédiaire",
  avance: "Avancé",
};

function fmtHours(s: number) {
  if (!s) return "0 h";
  const h = Math.floor(s / 3600);
  const m = Math.floor((s % 3600) / 60);
  return h ? `${h} h ${String(m).padStart(2, "0")}` : `${m} min`;
}

export default async function StatsPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const since90 = new Date();
  since90.setDate(since90.getDate() - 90);

  const [
    { data: attempts },
    { data: blocs },
    { data: modules },
    { data: lessons },
    { data: progress },
    { data: daily },
    { data: summary },
  ] = await Promise.all([
    supabase
      .from("quiz_attempts")
      .select(
        "id, percentage, passed, score, total, finished_at, started_at, duration_s, quiz_id, quizzes(title, type, module_id)"
      )
      .eq("user_id", user.id)
      .order("finished_at", { ascending: false }),
    supabase.from("blocs").select("id, code, title").order("order"),
    supabase.from("modules").select("id, title, bloc_id"),
    supabase.from("lessons").select("id, module_id"),
    supabase
      .from("lesson_progress")
      .select("lesson_id, completed, completed_at")
      .eq("user_id", user.id),
    supabase
      .from("user_daily_activity")
      .select("day, sessions, total_seconds")
      .eq("user_id", user.id)
      .gte("day", since90.toISOString().slice(0, 10)),
    supabase
      .from("user_training_summary")
      .select("*")
      .eq("id", user.id)
      .maybeSingle(),
  ]);

  // Agrégats globaux
  const total = attempts?.length ?? 0;
  const avg =
    total > 0
      ? Math.round(
          (attempts ?? []).reduce((s, a: any) => s + a.percentage, 0) / total
        )
      : 0;
  const nbPassed = (attempts ?? []).filter((a: any) => a.passed).length;

  // Tendance 30j vs 30j précédents
  const now = Date.now();
  const last30 = (attempts ?? []).filter(
    (a: any) =>
      a.finished_at && +new Date(a.finished_at) >= now - 30 * 86400000
  );
  const prev30 = (attempts ?? []).filter(
    (a: any) =>
      a.finished_at &&
      +new Date(a.finished_at) >= now - 60 * 86400000 &&
      +new Date(a.finished_at) < now - 30 * 86400000
  );
  const avg30 =
    last30.length > 0
      ? Math.round(last30.reduce((s, a: any) => s + a.percentage, 0) / last30.length)
      : null;
  const avgPrev =
    prev30.length > 0
      ? Math.round(prev30.reduce((s, a: any) => s + a.percentage, 0) / prev30.length)
      : null;
  const trend =
    avg30 != null && avgPrev != null ? avg30 - avgPrev : null;

  // Per bloc breakdown
  const moduleById = new Map((modules ?? []).map((m: any) => [m.id, m]));
  const lessonsByModule = new Map<string, string[]>();
  (lessons ?? []).forEach((l: any) => {
    const arr = lessonsByModule.get(l.module_id) ?? [];
    arr.push(l.id);
    lessonsByModule.set(l.module_id, arr);
  });
  const completedLessonIds = new Set(
    (progress ?? [])
      .filter((p: any) => p.completed)
      .map((p: any) => p.lesson_id)
  );

  type BlocStat = {
    id: number;
    code: string;
    title: string;
    lessonsDone: number;
    lessonsTotal: number;
    quizPassed: number;
    quizTotal: number;
    avgScore: number | null;
  };
  const byBloc: BlocStat[] = (blocs ?? []).map((b: any) => {
    const modsOfBloc = (modules ?? []).filter((m: any) => m.bloc_id === b.id);
    const modIds = new Set(modsOfBloc.map((m: any) => m.id));
    const lessonsOfBloc = modsOfBloc.flatMap(
      (m: any) => lessonsByModule.get(m.id) ?? []
    );
    const done = lessonsOfBloc.filter((id) => completedLessonIds.has(id)).length;
    const attemptsOfBloc = (attempts ?? []).filter((a: any) =>
      a.quizzes?.module_id ? modIds.has(a.quizzes.module_id) : false
    );
    const passed = attemptsOfBloc.filter((a: any) => a.passed).length;
    const score =
      attemptsOfBloc.length > 0
        ? Math.round(
            attemptsOfBloc.reduce((s, a: any) => s + a.percentage, 0) /
              attemptsOfBloc.length
          )
        : null;
    return {
      id: b.id,
      code: b.code,
      title: b.title,
      lessonsDone: done,
      lessonsTotal: lessonsOfBloc.length,
      quizPassed: passed,
      quizTotal: attemptsOfBloc.length,
      avgScore: score,
    };
  });

  // Per module performance (top 5)
  type ModStat = {
    id: string;
    title: string;
    bloc: string;
    avgScore: number;
    attempts: number;
  };
  const moduleStatsMap = new Map<string, { sum: number; n: number }>();
  (attempts ?? []).forEach((a: any) => {
    const mid = a.quizzes?.module_id;
    if (!mid) return;
    const cur = moduleStatsMap.get(mid) ?? { sum: 0, n: 0 };
    cur.sum += a.percentage;
    cur.n += 1;
    moduleStatsMap.set(mid, cur);
  });
  const moduleStats: ModStat[] = Array.from(moduleStatsMap.entries())
    .map(([id, v]) => {
      const m: any = moduleById.get(id);
      if (!m) return null;
      const bloc = (blocs ?? []).find((b: any) => b.id === m.bloc_id);
      return {
        id,
        title: m.title,
        bloc: bloc?.code ?? "",
        avgScore: Math.round(v.sum / v.n),
        attempts: v.n,
      };
    })
    .filter(Boolean) as ModStat[];

  moduleStats.sort((a, b) => a.avgScore - b.avgScore);
  const weakest = moduleStats.slice(0, 3);
  const strongest = [...moduleStats].reverse().slice(0, 3);

  // Heatmap : derniers 90 j
  const heatDays = (daily ?? []).map((d: any) => ({
    date: typeof d.day === "string" ? d.day.slice(0, 10) : new Date(d.day).toISOString().slice(0, 10),
    count: d.sessions ?? 0,
  }));
  const heatMax = heatDays.reduce((m, d) => (d.count > m ? d.count : m), 0);
  const totalTime = (summary as any)?.total_session_s ?? 0;
  const lessonTime = (summary as any)?.lesson_time_s ?? 0;

  return (
    <div className="space-y-10">
      <header className="flex items-start justify-between gap-4 flex-wrap">
        <div>
          <span className="eyebrow text-gold-700">Bilan personnel</span>
          <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
            Mes résultats détaillés
          </h1>
          <p className="mt-2 text-slate-600 max-w-2xl">
            Analyse par bloc de compétence, évolution dans le temps, points
            forts et axes de travail.
          </p>
        </div>
        <a href="/api/my-report/pdf" target="_blank" rel="noopener noreferrer">
          <Button variant="gold">
            <Download className="h-4 w-4" /> Télécharger mon bilan
          </Button>
        </a>
      </header>

      {/* KPIs globaux */}
      <section className="grid md:grid-cols-4 gap-4">
        <Card>
          <CardBody className="flex items-center gap-4">
            <div className="h-12 w-12 rounded-xl bg-navy-50 text-navy-800 flex items-center justify-center">
              <ClipboardCheck className="h-5 w-5" />
            </div>
            <div>
              <div className="text-[11px] uppercase tracking-wider text-slate-500">
                Tentatives
              </div>
              <div className="font-display text-2xl font-semibold text-navy-900">
                {total}
              </div>
              <div className="text-[11px] text-slate-500 mt-0.5">
                dont {nbPassed} réussies
              </div>
            </div>
          </CardBody>
        </Card>

        <Card>
          <CardBody className="flex items-center gap-4">
            <RadialProgress
              value={avg}
              size={64}
              strokeWidth={6}
              label={
                <span className="text-[11px] font-semibold text-navy-900">
                  {avg}%
                </span>
              }
            />
            <div>
              <div className="text-[11px] uppercase tracking-wider text-slate-500">
                Score moyen
              </div>
              <div className={`font-display text-2xl font-semibold ${scoreColor(avg)}`}>
                {avg}%
              </div>
              {trend != null && (
                <div
                  className={`mt-0.5 inline-flex items-center gap-1 text-[11px] font-medium ${
                    trend > 0
                      ? "text-emerald-700"
                      : trend < 0
                      ? "text-rose-700"
                      : "text-slate-500"
                  }`}
                >
                  {trend > 0 ? (
                    <TrendingUp className="h-3 w-3" />
                  ) : trend < 0 ? (
                    <TrendingDown className="h-3 w-3" />
                  ) : (
                    <Minus className="h-3 w-3" />
                  )}
                  {trend > 0 ? "+" : ""}
                  {trend} pts sur 30 j
                </div>
              )}
            </div>
          </CardBody>
        </Card>

        <Card>
          <CardBody className="flex items-center gap-4">
            <div className="h-12 w-12 rounded-xl bg-navy-50 text-navy-800 flex items-center justify-center">
              <Timer className="h-5 w-5" />
            </div>
            <div>
              <div className="text-[11px] uppercase tracking-wider text-slate-500">
                Temps connecté
              </div>
              <div className="font-display text-2xl font-semibold text-navy-900">
                {fmtHours(totalTime)}
              </div>
              <div className="text-[11px] text-slate-500 mt-0.5">
                dont {fmtHours(lessonTime)} en leçon
              </div>
            </div>
          </CardBody>
        </Card>

        <Card variant="gold">
          <CardBody className="flex items-center gap-4">
            <div className="h-12 w-12 rounded-xl bg-gold-100 text-gold-800 flex items-center justify-center">
              <Trophy className="h-5 w-5" />
            </div>
            <div>
              <div className="text-[11px] uppercase tracking-wider text-gold-800">
                Taux de réussite
              </div>
              <div className="font-display text-2xl font-semibold text-navy-900">
                {total > 0 ? Math.round((nbPassed / total) * 100) : 0}%
              </div>
            </div>
          </CardBody>
        </Card>
      </section>

      {/* NOUVEAUX GRAPHIQUES — évolution score + activité 30 jours */}
      <section className="grid lg:grid-cols-2 gap-4">
        <Card>
          <CardBody>
            <div className="flex items-center gap-2 mb-4">
              <TrendingUp className="h-4 w-4 text-brand-600" />
              <h2 className="font-display text-base font-semibold text-navy-900">
                Évolution de mon score (30 jours)
              </h2>
            </div>
            <ScoreEvolutionChart
              attempts={(attempts ?? []) as any}
              passThreshold={70}
            />
          </CardBody>
        </Card>
        <Card>
          <CardBody>
            <div className="flex items-center gap-2 mb-4">
              <BarChart3 className="h-4 w-4 text-brand-600" />
              <h2 className="font-display text-base font-semibold text-navy-900">
                Temps d'apprentissage quotidien
              </h2>
            </div>
            <ActivityBarsChart daily={(daily ?? []) as any} />
          </CardBody>
        </Card>
      </section>

      {/* Heatmap d'activité */}
      <section>
        <div className="flex items-center gap-2 mb-4">
          <CalendarRange className="h-4 w-4 text-navy-700" />
          <h2 className="font-display text-xl font-semibold text-navy-900">
            Activité sur 90 jours
          </h2>
        </div>
        <Card>
          <CardBody>
            <ActivityHeatmap days={heatDays} max={heatMax || 1} />
            <div className="mt-3 flex items-center justify-between text-[11px] text-slate-500">
              <span>
                {heatDays.filter((d) => d.count > 0).length} jour(s) actif(s)
              </span>
              <div className="flex items-center gap-1.5">
                <span>Moins</span>
                <span className="h-3 w-3 rounded-[3px] bg-navy-50/60 border border-white/40" />
                <span className="h-3 w-3 rounded-[3px] bg-gold-200 border border-white/40" />
                <span className="h-3 w-3 rounded-[3px] bg-gold-400 border border-white/40" />
                <span className="h-3 w-3 rounded-[3px] bg-gold-500 border border-white/40" />
                <span className="h-3 w-3 rounded-[3px] bg-gold-600 border border-white/40" />
                <span>Plus</span>
              </div>
            </div>
          </CardBody>
        </Card>
      </section>

      {/* Progression par bloc */}
      <section>
        <div className="flex items-center gap-2 mb-4">
          <Layers className="h-4 w-4 text-navy-700" />
          <h2 className="font-display text-xl font-semibold text-navy-900">
            Progression par bloc de compétence
          </h2>
        </div>
        <div className="grid md:grid-cols-2 gap-4">
          {byBloc.map((b) => {
            const pct =
              b.lessonsTotal > 0
                ? Math.round((b.lessonsDone / b.lessonsTotal) * 100)
                : 0;
            return (
              <Card key={b.id}>
                <CardBody className="space-y-3">
                  <div className="flex items-center justify-between">
                    <div>
                      <div className="text-[11px] uppercase tracking-wider text-slate-500">
                        {b.code}
                      </div>
                      <div className="font-display font-semibold text-navy-900">
                        {b.title}
                      </div>
                    </div>
                    {b.avgScore != null && (
                      <RadialProgress
                        value={b.avgScore}
                        size={52}
                        strokeWidth={5}
                        label={
                          <span
                            className={`text-[10px] font-semibold ${scoreColor(
                              b.avgScore
                            )}`}
                          >
                            {b.avgScore}%
                          </span>
                        }
                      />
                    )}
                  </div>

                  <div>
                    <div className="flex justify-between text-xs text-slate-600 mb-1">
                      <span>Leçons terminées</span>
                      <span className="font-semibold text-navy-900">
                        {b.lessonsDone} / {b.lessonsTotal}
                      </span>
                    </div>
                    <ProgressBar value={pct} variant="gradient" />
                  </div>
                  <div className="text-xs text-slate-600">
                    {b.quizTotal === 0
                      ? "Aucun quiz tenté dans ce bloc"
                      : `${b.quizPassed} quiz réussi(s) sur ${b.quizTotal}`}
                  </div>
                </CardBody>
              </Card>
            );
          })}
        </div>
      </section>

      {/* Points forts / faibles */}
      {moduleStats.length > 0 && (
        <section className="grid md:grid-cols-2 gap-4">
          <Card>
            <CardBody>
              <div className="flex items-center gap-2 mb-3">
                <TrendingUp className="h-4 w-4 text-emerald-600" />
                <h3 className="font-display font-semibold text-navy-900">
                  Points forts
                </h3>
              </div>
              {strongest.length === 0 ? (
                <p className="text-sm text-slate-500">
                  Pas encore assez de données.
                </p>
              ) : (
                <ul className="space-y-2.5">
                  {strongest.map((m) => (
                    <li key={m.id} className="flex items-center gap-3">
                      <Badge tone="slate" size="sm">
                        {m.bloc}
                      </Badge>
                      <div className="flex-1 min-w-0">
                        <div className="text-sm text-navy-900 truncate">
                          {m.title}
                        </div>
                        <div className="text-[11px] text-slate-500">
                          {m.attempts} tentative(s)
                        </div>
                      </div>
                      <div
                        className={`font-display font-semibold ${scoreColor(
                          m.avgScore
                        )}`}
                      >
                        {m.avgScore}%
                      </div>
                    </li>
                  ))}
                </ul>
              )}
            </CardBody>
          </Card>

          <Card>
            <CardBody>
              <div className="flex items-center gap-2 mb-3">
                <TrendingDown className="h-4 w-4 text-rose-600" />
                <h3 className="font-display font-semibold text-navy-900">
                  Axes de travail
                </h3>
              </div>
              {weakest.length === 0 ? (
                <p className="text-sm text-slate-500">
                  Pas encore assez de données.
                </p>
              ) : (
                <ul className="space-y-2.5">
                  {weakest.map((m) => (
                    <li key={m.id} className="flex items-center gap-3">
                      <Badge tone="slate" size="sm">
                        {m.bloc}
                      </Badge>
                      <div className="flex-1 min-w-0">
                        <div className="text-sm text-navy-900 truncate">
                          {m.title}
                        </div>
                        <div className="text-[11px] text-slate-500">
                          {m.attempts} tentative(s)
                        </div>
                      </div>
                      <div
                        className={`font-display font-semibold ${scoreColor(
                          m.avgScore
                        )}`}
                      >
                        {m.avgScore}%
                      </div>
                    </li>
                  ))}
                </ul>
              )}
            </CardBody>
          </Card>
        </section>
      )}

      {/* Historique */}
      <section>
        <div className="flex items-center gap-2 mb-4">
          <BarChart3 className="h-4 w-4 text-navy-700" />
          <h2 className="font-display text-xl font-semibold text-navy-900">
            Historique complet
          </h2>
        </div>
        <Card>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="bg-navy-50/60 text-[11px] uppercase tracking-wider text-slate-600">
                  <th className="text-left px-5 py-3 font-semibold">Quiz</th>
                  <th className="text-left px-5 py-3 font-semibold">Type</th>
                  <th className="text-left px-5 py-3 font-semibold">Score</th>
                  <th className="text-left px-5 py-3 font-semibold">Statut</th>
                  <th className="text-left px-5 py-3 font-semibold">Date</th>
                </tr>
              </thead>
              <tbody>
                {attempts?.map((a: any) => (
                  <tr
                    key={a.id}
                    className="border-t border-navy-50 hover:bg-navy-50/30"
                  >
                    <td className="px-5 py-3.5 font-medium text-navy-900">
                      {a.quizzes?.title}
                    </td>
                    <td className="px-5 py-3.5 text-slate-600 capitalize">
                      {a.quizzes?.type}
                    </td>
                    <td
                      className={`px-5 py-3.5 font-display font-semibold ${scoreColor(
                        a.percentage
                      )}`}
                    >
                      {a.percentage}%{" "}
                      <span className="text-xs text-slate-500 font-sans font-normal">
                        ({a.score}/{a.total})
                      </span>
                    </td>
                    <td className="px-5 py-3.5">
                      {a.passed ? (
                        <Badge tone="success" size="sm">
                          Réussi
                        </Badge>
                      ) : (
                        <Badge tone="slate" size="sm">
                          À retravailler
                        </Badge>
                      )}
                    </td>
                    <td className="px-5 py-3.5 text-slate-500">
                      {a.finished_at && formatDate(a.finished_at)}
                    </td>
                  </tr>
                ))}
                {(!attempts || attempts.length === 0) && (
                  <tr>
                    <td
                      colSpan={5}
                      className="px-5 py-10 text-center text-slate-500"
                    >
                      Aucune tentative.{" "}
                      <Link
                        href="/quiz"
                        className="text-navy-900 font-medium hover:text-gold-700 underline-offset-4 hover:underline"
                      >
                        Lancez votre premier quiz
                      </Link>
                      .
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </Card>
      </section>
    </div>
  );
}
