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
import { ScrollReveal } from "@/components/lesson/scroll-reveal";
import { AnimatedCounter } from "@/components/animated-counter";

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

  // Formations du stagiaire — source de vérité pour le périmètre des stats.
  const { data: enrollments } = await supabase
    .from("enrollments")
    .select("formation_id")
    .eq("user_id", user.id)
    .not("formation_id", "is", null)
    .neq("status", "refuse")
      .neq("status", "abandon");
  const enrolledFormationIds = (enrollments ?? [])
    .map((e: any) => e.formation_id as string)
    .filter(Boolean);

  // Modules accessibles via formation_modules (M:N).
  let allowedModuleIds: string[] = [];
  if (enrolledFormationIds.length > 0) {
    const { data: links } = await supabase
      .from("formation_modules")
      .select("module_id")
      .in("formation_id", enrolledFormationIds);
    allowedModuleIds = Array.from(
      new Set((links ?? []).map((l: any) => l.module_id as string))
    );
  }
  const noModules = allowedModuleIds.length === 0;

  const [
    { data: attemptsRaw },
    { data: allBlocs },
    { data: modules },
    { data: lessons },
    { data: progress },
    { data: daily },
    { data: summary },
  ] = await Promise.all([
    // Quiz attempts : on prend TOUTES les tentatives du user, on filtrera
    // ensuite côté JS via la chaîne `quiz_id → module_id ∈ allowedModuleIds`.
    // Ça évite la dépendance fragile à `quiz_attempts.formation_id` (qui peut
    // être NULL si Sprint 1 / le trigger n'a pas tourné sur cette ligne).
    supabase
      .from("quiz_attempts")
      .select(
        "id, percentage, passed, score, total, finished_at, started_at, duration_s, quiz_id, formation_id, quizzes(title, type, module_id)"
      )
      .eq("user_id", user.id)
      .order("finished_at", { ascending: false }),
    supabase.from("blocs").select("id, code, title").order("order"),
    noModules
      ? Promise.resolve({ data: [] as any[] })
      : supabase
          .from("modules")
          .select("id, title, bloc_id")
          .in("id", allowedModuleIds),
    noModules
      ? Promise.resolve({ data: [] as any[] })
      : supabase
          .from("lessons")
          .select("id, module_id")
          .in("module_id", allowedModuleIds),
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

  // Stats personnelles : toutes les tentatives du user sont SES tentatives.
  // RLS filtre déjà par user_id côté Supabase. On ne sur-filtre PAS — un
  // user veut voir TOUS ses résultats (multi-formation inclus). C'est la
  // BONNE source de vérité même si formation_id est NULL sur certaines
  // lignes (legacy, trigger raté, etc.).
  const attempts = attemptsRaw ?? [];

  // Récupère le détail des formations du user pour grouper la progression.
  let formationsList: Array<{
    id: string;
    slug: string;
    code: string;
    title: string;
  }> = [];
  if (enrolledFormationIds.length > 0) {
    const { data: f } = await supabase
      .from("formations")
      .select("id, slug, code, title")
      .in("id", enrolledFormationIds)
      .order("display_order");
    formationsList = (f ?? []) as any;
  }

  // Mapping module → formation(s) pour agréger par formation.
  let moduleToFormations = new Map<string, string[]>();
  if (allowedModuleIds.length > 0) {
    const { data: links } = await supabase
      .from("formation_modules")
      .select("module_id, formation_id")
      .in("module_id", allowedModuleIds);
    (links ?? []).forEach((l: any) => {
      const arr = moduleToFormations.get(l.module_id) ?? [];
      arr.push(l.formation_id);
      moduleToFormations.set(l.module_id, arr);
    });
  }

  // Blocs : on ne garde que ceux qui ont au moins un module dans le périmètre.
  const usedBlocIds = new Set<number>(
    (modules ?? [])
      .map((m: any) => m.bloc_id)
      .filter((id: number | null) => id != null)
  );
  const blocs = (allBlocs ?? []).filter((b: any) => usedBlocIds.has(b.id));

  // Détecter si le découpage par bloc fait sens pour l'utilisateur :
  // - GOTRM utilise BC1/BC2/BC3 avec des titres dédiés à GOTRM
  // - Les autres formations réutilisent BC1 comme "bucket" → afficher
  //   "BC1 — Concevoir, organiser et piloter…" (titre GOTRM) à un Capa
  //   est trompeur. Dans ce cas on bascule sur un découpage par formation.
  const isGotrmOnly =
    formationsList.length === 1 && formationsList[0].slug === "gotrm";
  const showBlocsBreakdown = isGotrmOnly;

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

  // Progression par formation — granularité plus pertinente que les blocs
  // pour les formations qui ne sont pas GOTRM (ex : Capa qui réutilise BC1).
  type FormationStat = {
    id: string;
    slug: string;
    code: string;
    title: string;
    lessonsDone: number;
    lessonsTotal: number;
    quizPassed: number;
    quizTotal: number;
    avgScore: number | null;
  };
  const byFormation: FormationStat[] = formationsList.map((f) => {
    // Modules rattachés à cette formation
    const modsOfFormation = (modules ?? []).filter((m: any) =>
      (moduleToFormations.get(m.id) ?? []).includes(f.id)
    );
    const modIds = new Set(modsOfFormation.map((m: any) => m.id));
    const lessonsOfFormation = modsOfFormation.flatMap(
      (m: any) => lessonsByModule.get(m.id) ?? []
    );
    const done = lessonsOfFormation.filter((id) =>
      completedLessonIds.has(id)
    ).length;
    const attemptsOfFormation = (attempts ?? []).filter((a: any) =>
      a.quizzes?.module_id ? modIds.has(a.quizzes.module_id) : false
    );
    const passed = attemptsOfFormation.filter((a: any) => a.passed).length;
    const score =
      attemptsOfFormation.length > 0
        ? Math.round(
            attemptsOfFormation.reduce(
              (s, a: any) => s + a.percentage,
              0
            ) / attemptsOfFormation.length
          )
        : null;
    return {
      id: f.id,
      slug: f.slug,
      code: f.code,
      title: f.title,
      lessonsDone: done,
      lessonsTotal: lessonsOfFormation.length,
      quizPassed: passed,
      quizTotal: attemptsOfFormation.length,
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

  const successRate = total > 0 ? Math.round((nbPassed / total) * 100) : 0;
  const totalMinutes = Math.round(totalTime / 60);

  return (
    <div className="space-y-10 md:space-y-12">
      <ScrollReveal>
        <header className="flex items-start justify-between gap-4 flex-wrap">
          <div>
            <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-700">
              Bilan personnel
            </span>
            <h1 className="mt-2 font-display text-[28px] md:text-4xl font-semibold text-navy-950 tracking-tight leading-tight">
              Mes résultats détaillés
            </h1>
            <p className="mt-2 text-slate-600 max-w-2xl text-[15px]">
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
      </ScrollReveal>

      {/* Bandeau KPI premium — score moyen mis en avant à gauche, KPIs satellites à droite */}
      <ScrollReveal delay={60}>
        <section className="grid lg:grid-cols-[1.2fr_2fr] gap-4">
          {/* Carte signature : score moyen XL */}
          <Card variant="solid-navy" className="relative overflow-hidden">
            <div
              className="absolute -right-10 -top-10 h-40 w-40 rounded-full bg-gold-400/10 blur-2xl"
              aria-hidden
            />
            <CardBody className="relative">
              <div className="flex items-start justify-between gap-3 mb-4">
                <div>
                  <div className="text-[11px] uppercase tracking-[0.16em] text-gold-300/90">
                    Score moyen
                  </div>
                  <div className="mt-1 text-[11px] text-slate-300">
                    {total} tentative{total > 1 ? "s" : ""} ·{" "}
                    {nbPassed} réussie{nbPassed > 1 ? "s" : ""}
                  </div>
                </div>
                {trend != null && (
                  <span
                    className={`inline-flex items-center gap-1 rounded-full px-2.5 py-1 text-[11px] font-semibold ${
                      trend > 0
                        ? "bg-emerald-400/15 text-emerald-300"
                        : trend < 0
                        ? "bg-rose-400/15 text-rose-300"
                        : "bg-slate-400/15 text-slate-300"
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
                    {trend} pts · 30 j
                  </span>
                )}
              </div>
              <div className="flex items-end gap-5">
                <RadialProgress
                  value={avg}
                  size={104}
                  strokeWidth={9}
                  label={
                    <span className="font-display text-[22px] font-bold text-white">
                      <AnimatedCounter value={avg} suffix="%" />
                    </span>
                  }
                />
                <div className="flex-1 pb-2">
                  <div className="text-[40px] font-display font-bold text-white leading-none">
                    <AnimatedCounter value={successRate} suffix="%" />
                  </div>
                  <div className="mt-1 text-[12px] text-slate-300 uppercase tracking-wider">
                    Taux de réussite
                  </div>
                </div>
              </div>
            </CardBody>
          </Card>

          {/* Trio de mini-KPIs satellite */}
          <div className="grid sm:grid-cols-3 gap-4">
            <KpiTile
              icon={ClipboardCheck}
              label="Tentatives"
              value={
                <AnimatedCounter
                  value={total}
                  className="font-display text-[28px] font-semibold text-navy-900"
                />
              }
              hint={
                total > 0
                  ? `${nbPassed} validée${nbPassed > 1 ? "s" : ""}`
                  : "Pas encore de quiz"
              }
            />
            <KpiTile
              icon={Timer}
              label="Temps connecté"
              value={
                <AnimatedCounter
                  value={totalMinutes}
                  suffix=" min"
                  className="font-display text-[28px] font-semibold text-navy-900"
                />
              }
              hint={`dont ${fmtHours(lessonTime)} en leçon`}
            />
            <KpiTile
              icon={Trophy}
              label="Exercices réussis"
              value={
                <AnimatedCounter
                  value={nbPassed}
                  className="font-display text-[28px] font-semibold text-navy-900"
                />
              }
              hint={
                total > 0
                  ? `sur ${total} tentative${total > 1 ? "s" : ""}`
                  : "Lancez votre 1er quiz"
              }
              accent
            />
          </div>
        </section>
      </ScrollReveal>

      {/* Graphiques évolution + activité quotidienne */}
      <ScrollReveal delay={120}>
        <section className="grid lg:grid-cols-2 gap-4">
          <Card className="transition-[transform,box-shadow,border-color] duration-200 ease-premium hover:shadow-raised">
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
          <Card className="transition-[transform,box-shadow,border-color] duration-200 ease-premium hover:shadow-raised">
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
      </ScrollReveal>

      {/* Heatmap d'activité */}
      <ScrollReveal delay={180}>
        <section>
          <div className="flex items-center gap-2 mb-4">
            <CalendarRange className="h-4 w-4 text-navy-700" />
            <h2 className="font-display text-xl font-semibold text-navy-900">
              Activité sur 90 jours
            </h2>
          </div>
          <Card className="transition-[transform,box-shadow,border-color] duration-200 ease-premium hover:shadow-raised">
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
      </ScrollReveal>

      {/* Progression — par bloc (GOTRM) ou par formation (autres) */}
      <ScrollReveal delay={240}>
      <section>
        <div className="flex items-center justify-between gap-2 mb-4 flex-wrap">
          <div className="flex items-center gap-2">
            <Layers className="h-4 w-4 text-navy-700" />
            <h2 className="font-display text-xl font-semibold text-navy-900">
              {showBlocsBreakdown
                ? "Progression par bloc de compétence"
                : "Progression par formation"}
            </h2>
          </div>
        </div>

        {/* Affichage par bloc (GOTRM) */}
        {showBlocsBreakdown && (
          <div className="grid md:grid-cols-2 gap-4">
            {byBloc.map((b) => {
              const pct =
                b.lessonsTotal > 0
                  ? Math.round((b.lessonsDone / b.lessonsTotal) * 100)
                  : 0;
              return (
                <Card key={b.id} className="transition-[transform,box-shadow,border-color] duration-200 ease-premium hover:shadow-raised">
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
        )}

        {/* Affichage par formation (cas Capa, multi-formation, etc.) */}
        {!showBlocsBreakdown && (
          <div className="grid md:grid-cols-2 gap-4">
            {byFormation.map((f) => {
              const pct =
                f.lessonsTotal > 0
                  ? Math.round((f.lessonsDone / f.lessonsTotal) * 100)
                  : 0;
              const overallScore =
                f.avgScore != null
                  ? f.avgScore
                  : f.lessonsTotal > 0
                  ? pct
                  : 0;
              return (
                <Card
                  key={f.id}
                  className="transition-[transform,box-shadow,border-color] duration-200 ease-premium hover:shadow-raised hover:-translate-y-0.5"
                  style={{
                    transitionTimingFunction: "cubic-bezier(0.22, 1, 0.36, 1)",
                  }}
                >
                  <CardBody className="space-y-3">
                    <div className="flex items-center justify-between gap-3">
                      <div className="min-w-0">
                        <div className="text-[11px] uppercase tracking-[0.14em] text-brand-700">
                          {f.code}
                        </div>
                        <div className="font-display font-semibold text-navy-900 leading-snug">
                          {f.title}
                        </div>
                      </div>
                      <RadialProgress
                        value={overallScore}
                        size={56}
                        strokeWidth={6}
                        label={
                          <span
                            className={`text-[10px] font-semibold ${
                              f.avgScore != null
                                ? scoreColor(f.avgScore)
                                : "text-navy-900"
                            }`}
                          >
                            {f.avgScore != null ? `${f.avgScore}%` : `${pct}%`}
                          </span>
                        }
                      />
                    </div>

                    <div>
                      <div className="flex justify-between text-xs text-slate-600 mb-1">
                        <span>Leçons terminées</span>
                        <span className="font-semibold text-navy-900">
                          {f.lessonsDone} / {f.lessonsTotal}
                        </span>
                      </div>
                      <ProgressBar value={pct} variant="gradient" />
                    </div>
                    <div className="text-xs text-slate-600">
                      {f.quizTotal === 0
                        ? "Aucun quiz tenté pour cette formation"
                        : `${f.quizPassed} quiz réussi${
                            f.quizPassed > 1 ? "s" : ""
                          } sur ${f.quizTotal} tentative${
                            f.quizTotal > 1 ? "s" : ""
                          }`}
                    </div>
                  </CardBody>
                </Card>
              );
            })}
            {byFormation.length === 0 && (
              <Card className="md:col-span-2">
                <CardBody className="text-center py-10 text-sm text-slate-500">
                  Aucune formation active. Contactez votre référent
                  pédagogique.
                </CardBody>
              </Card>
            )}
          </div>
        )}
      </section>
      </ScrollReveal>

      {/* Points forts / faibles */}
      {moduleStats.length > 0 && (
        <ScrollReveal delay={300}>
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
        </ScrollReveal>
      )}

      {/* Historique */}
      <ScrollReveal delay={360}>
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
                  <th className="text-left px-5 py-3 font-semibold">Exercice</th>
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
      </ScrollReveal>
    </div>
  );
}

// ---------------------------------------------------------------------
// KpiTile — mini KPI card avec icône, label, value (compteur animé), hint
// ---------------------------------------------------------------------
function KpiTile({
  icon: Icon,
  label,
  value,
  hint,
  accent = false,
}: {
  icon: typeof ClipboardCheck;
  label: string;
  value: React.ReactNode;
  hint?: string;
  accent?: boolean;
}) {
  return (
    <div
      className={`group relative rounded-2xl border p-4 transition-[transform,box-shadow,border-color] duration-200 ease-premium hover:shadow-raised hover:-translate-y-0.5 ${
        accent
          ? "bg-gradient-to-br from-gold-50 to-white border-gold-200/80"
          : "bg-white border-navy-100"
      }`}
      style={{
        transitionTimingFunction: "cubic-bezier(0.22, 1, 0.36, 1)",
        transitionDuration: "240ms",
      }}
    >
      <div className="flex items-start gap-3">
        <div
          className={`h-10 w-10 rounded-xl flex items-center justify-center shrink-0 transition-colors ${
            accent
              ? "bg-gold-100 text-gold-800 group-hover:bg-gold-200"
              : "bg-navy-50 text-navy-800 group-hover:bg-navy-100"
          }`}
        >
          <Icon className="h-5 w-5" />
        </div>
        <div className="min-w-0 flex-1">
          <div className="text-[11px] uppercase tracking-[0.14em] text-slate-500">
            {label}
          </div>
          <div className="mt-1">{value}</div>
          {hint && (
            <div className="mt-1 text-[11.5px] text-slate-500 truncate">
              {hint}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
