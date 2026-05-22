import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { formatDate, initials, scoreColor } from "@/lib/utils";
import {
  BarChart3,
  Trophy,
  TrendingUp,
  Download,
  Users,
  AlertTriangle,
  CheckCircle2,
  Banknote,
  Sparkles,
  Calendar,
  CircleDot,
  ListChecks,
  UserPlus,
  Globe,
  GraduationCap,
} from "lucide-react";
import { AnalyticsToolbar } from "./analytics-toolbar";
import { DeleteAttemptButton } from "./analytics-row-actions";
import { TrendsChart } from "./trends-chart";
import { CompletionBars } from "./completion-bars";
import { RealtimeIndicator } from "./realtime-indicator";
import { AtRiskSection } from "./at-risk-section";
import {
  TopStudentsSection,
  QualiopiSection,
  QuizOutliersSection,
  RevenueMatrixSection,
} from "./insights-sections";
import { FunnelChart } from "./funnel-chart";
import { HeatmapGrid } from "./heatmap-grid";
import { FormationTrendsGrid } from "./formation-trends";
import { UpcomingSessionsSection } from "./upcoming-sessions";
import { PeriodFilter, KpiWithDelta } from "./period-filter";
import { PrintButton } from "./print-button";
import Link from "next/link";
import { Tv } from "lucide-react";

export const dynamic = "force-dynamic";

interface KpiSnapshot {
  active_students_7d: number;
  at_risk_students: number;
  quiz_attempts_7d: number;
  live_sessions_scheduled: number;
  live_sessions_completed_30d: number;
  active_enrollments: number;
  revenue_30d_cents: number;
  new_users_7d: number;
  pass_rate_30d: number;
  mock_exams_30d: number;
  pending_corrections: number;
  computed_at: string;
}

function fmtEuro(cents: number): string {
  return new Intl.NumberFormat("fr-FR", {
    style: "currency",
    currency: "EUR",
    maximumFractionDigits: 0,
  }).format((cents ?? 0) / 100);
}

export default async function AdminAnalytics({
  searchParams,
}: {
  searchParams?: { period?: string };
}) {
  const supabase = createClient();

  // Période sélectionnée (par défaut 30 jours)
  const periodDays = Math.max(
    1,
    Math.min(365, parseInt(searchParams?.period ?? "30", 10) || 30)
  );

  // 1. KPIs temps réel
  const { data: kpiRow } = await supabase
    .from("vw_admin_kpis_realtime")
    .select("*")
    .single();
  const k = (kpiRow as KpiSnapshot | null) ?? {
    active_students_7d: 0,
    at_risk_students: 0,
    quiz_attempts_7d: 0,
    live_sessions_scheduled: 0,
    live_sessions_completed_30d: 0,
    active_enrollments: 0,
    revenue_30d_cents: 0,
    new_users_7d: 0,
    pass_rate_30d: 0,
    mock_exams_30d: 0,
    pending_corrections: 0,
    computed_at: new Date().toISOString(),
  };

  // 2. Toutes les autres requêtes en parallèle
  const [
    { data: trends },
    { data: completion },
    { data: attempts },
    { data: quizzes },
    { data: atRisk },
    { data: topStudents },
    { data: qualiopi },
    { data: quizOutliers },
    { data: revenueMatrix },
  ] = await Promise.all([
    supabase
      .from("vw_admin_trends_30d")
      .select("day, signups, quiz_attempts, payments")
      .order("day"),
    supabase
      .from("vw_admin_completion_by_formation")
      .select("*")
      .order("enrolled_count", { ascending: false })
      .limit(10),
    supabase
      .from("quiz_attempts")
      .select("*, profiles(id, full_name, email), quizzes(title)")
      .order("finished_at", { ascending: false })
      .limit(50),
    supabase.from("quizzes").select("id, title").order("title"),
    supabase
      .from("vw_admin_at_risk_students")
      .select("*")
      .limit(30),
    supabase.from("vw_admin_top_students").select("*"),
    supabase.from("vw_admin_qualiopi_indicators").select("*").single(),
    supabase.from("vw_admin_quiz_outliers").select("*").limit(15),
    supabase.from("vw_admin_revenue_by_formation_pack").select("*"),
  ]);

  // 3. Lot 2 : nouvelles requêtes (en parallèle aussi)
  const [
    { data: funnel },
    { data: heatmap },
    { data: trendsByFormation },
    { data: upcomingSessions },
    { data: periodKpis },
    { data: utmFunnel },
  ] = await Promise.all([
    supabase.from("vw_admin_funnel_conversion").select("*").single(),
    supabase.from("vw_admin_activity_heatmap").select("*"),
    supabase.from("vw_admin_trends_by_formation").select("*"),
    supabase.from("vw_admin_upcoming_sessions_14d").select("*").limit(10),
    supabase
      .rpc("get_admin_kpis_for_period", { p_days: periodDays })
      .single(),
    // Site vitrine : trafic par source (vue pré-agrégée, perf-friendly).
    supabase
      .from("vw_admin_funnel_by_utm")
      .select("source, visitors, signups, enrollments")
      .limit(50),
  ]);

  // Agrégats Vitrine (acquisition).
  const utm = (utmFunnel ?? []) as any[];
  const vitrine = {
    visitors: utm.reduce((s, r) => s + (Number(r.visitors) || 0), 0),
    signups: utm.reduce((s, r) => s + (Number(r.signups) || 0), 0),
    sources: new Set(utm.map((r) => r.source).filter(Boolean)).size,
    topSources: [...utm]
      .sort((a, b) => (Number(b.visitors) || 0) - (Number(a.visitors) || 0))
      .slice(0, 4),
  };
  const vitrineConv =
    vitrine.visitors > 0
      ? Math.round((vitrine.signups / vitrine.visitors) * 100)
      : 0;
  const maxSourceVisitors = Math.max(
    1,
    ...vitrine.topSources.map((r) => Number(r.visitors) || 0)
  );

  const pk = (periodKpis as any) ?? {
    signups: 0,
    quiz_attempts: 0,
    payments: 0,
    revenue_cents: 0,
    signups_prev: 0,
    quiz_attempts_prev: 0,
    payments_prev: 0,
    revenue_cents_prev: 0,
  };

  return (
    <div className="space-y-10">
      {/* En-tête */}
      <header className="flex items-end justify-between gap-4 flex-wrap">
        <div>
          <span className="eyebrow text-gold-700">Administration</span>
          <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 dark:text-white tracking-tight">
            Pilotage &amp; analytics
          </h1>
          <p className="mt-2 text-slate-600 dark:text-white/60 max-w-2xl">
            Pilotez votre activité en un seul tableau de bord : site vitrine,
            pédagogie et business. Données actualisées en temps réel.
          </p>
        </div>
        <div className="flex items-center gap-3 flex-wrap print:hidden">
          <RealtimeIndicator />
          <PrintButton />
          <Link
            href="/admin/analytics/tv"
            className="inline-flex items-center gap-1.5 px-3 h-9 rounded-lg text-xs font-semibold bg-navy-900 text-white hover:bg-navy-800 transition"
            title="Mode TV / Kiosk plein écran"
          >
            <Tv className="h-3.5 w-3.5" />
            Mode TV
          </Link>
        </div>
      </header>

      {/* ─────────── Section KPIs avec comparaison période (Lot 2) ─────────── */}
      <section className="rounded-2xl border border-navy-100 bg-white p-4">
        <div className="flex items-center justify-between mb-3 flex-wrap gap-2">
          <div>
            <h2 className="font-display text-base font-semibold text-navy-900 inline-flex items-center gap-2">
              <BarChart3 className="h-4 w-4 text-brand-700" />
              Vue d'ensemble
            </h2>
            <p className="text-[11px] text-slate-500 mt-0.5">
              KPIs sur la période sélectionnée + comparaison vs période précédente
            </p>
          </div>
          <PeriodFilter />
        </div>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          <KpiWithDelta
            label="Inscriptions stagiaire"
            value={Number(pk.signups)}
            previous={Number(pk.signups_prev)}
            hint={`${periodDays} derniers jours`}
          />
          <KpiWithDelta
            label="Tentatives quiz"
            value={Number(pk.quiz_attempts)}
            previous={Number(pk.quiz_attempts_prev)}
            hint={`${periodDays} derniers jours`}
          />
          <KpiWithDelta
            label="Paiements"
            value={Number(pk.payments)}
            previous={Number(pk.payments_prev)}
            hint={`${periodDays} derniers jours`}
          />
          <KpiWithDelta
            label="CA encaissé"
            value={Number(pk.revenue_cents)}
            previous={Number(pk.revenue_cents_prev)}
            format="euro"
            hint={`${periodDays} derniers jours`}
          />
        </div>
      </section>

      {/* ─────────── Section SITE VITRINE ─────────── */}
      <section>
        <div className="flex items-center justify-between mb-3 flex-wrap gap-2">
          <h2 className="font-display text-lg font-semibold text-navy-900 dark:text-white inline-flex items-center gap-2">
            <Globe className="h-4 w-4 text-brand-700" />
            Site vitrine
          </h2>
          <Link
            href="/admin/analytics/acquisition"
            className="text-xs font-medium text-brand-700 hover:underline"
          >
            Détail acquisition →
          </Link>
        </div>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          <Kpi
            icon={Globe}
            label="Visiteurs uniques"
            value={vitrine.visitors.toLocaleString("fr-FR")}
            hint={`${vitrine.sources} source${vitrine.sources > 1 ? "s" : ""}`}
            tone="navy"
          />
          <Kpi
            icon={UserPlus}
            label="Inscriptions (trafic)"
            value={vitrine.signups.toLocaleString("fr-FR")}
            hint="Issues du tracking"
            tone="signal"
          />
          <Kpi
            icon={TrendingUp}
            label="Conversion visiteurs"
            value={`${vitrineConv}%`}
            hint="Visiteurs → inscrits"
            tone={vitrineConv >= 3 ? "signal" : "gold"}
          />
          <Kpi
            icon={Sparkles}
            label="Sources actives"
            value={String(vitrine.sources)}
            hint="Canaux d'acquisition"
            tone="navy"
          />
        </div>
        {vitrine.topSources.length > 0 && (
          <Card className="mt-3">
            <CardBody>
              <div className="text-[11px] uppercase tracking-wider text-slate-500 font-semibold mb-3">
                Top provenances
              </div>
              <div className="space-y-2.5">
                {vitrine.topSources.map((srcRow: any) => {
                  const v = Number(srcRow.visitors) || 0;
                  const pct = Math.round((v / maxSourceVisitors) * 100);
                  return (
                    <div
                      key={srcRow.source ?? "direct"}
                      className="flex items-center gap-3"
                    >
                      <div className="w-28 shrink-0 text-sm text-navy-900 dark:text-white/90 truncate capitalize">
                        {srcRow.source || "Accès direct"}
                      </div>
                      <div className="flex-1 h-2.5 rounded-full bg-navy-50 dark:bg-white/10 overflow-hidden">
                        <div
                          className="h-full rounded-full bg-brand-500 transition-[width] duration-700 ease-premium"
                          style={{ width: `${pct}%` }}
                        />
                      </div>
                      <div className="w-12 text-right text-sm font-medium text-navy-900 dark:text-white tabular-nums">
                        {v.toLocaleString("fr-FR")}
                      </div>
                    </div>
                  );
                })}
              </div>
            </CardBody>
          </Card>
        )}
      </section>

      {/* ─────────── Section ENGAGEMENT (Pédagogie) ─────────── */}
      <section>
        <h2 className="font-display text-lg font-semibold text-navy-900 dark:text-white mb-3 inline-flex items-center gap-2">
          <GraduationCap className="h-4 w-4 text-signal-700" />
          Pédagogie
        </h2>
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-3">
          <Kpi
            icon={Users}
            label="Stagiaires actifs"
            value={String(k.active_students_7d)}
            hint="7 derniers jours"
            tone="signal"
          />
          <Kpi
            icon={AlertTriangle}
            label="À risque"
            value={String(k.at_risk_students)}
            hint=">14j inactifs"
            tone={k.at_risk_students > 0 ? "rose" : "slate"}
          />
          <Kpi
            icon={ListChecks}
            label="Tentatives quiz"
            value={String(k.quiz_attempts_7d)}
            hint="7 derniers jours"
            tone="navy"
          />
          <Kpi
            icon={Trophy}
            label="Taux de réussite"
            value={`${k.pass_rate_30d}%`}
            hint="30 derniers jours"
            tone={k.pass_rate_30d >= 70 ? "signal" : "gold"}
          />
          <Kpi
            icon={CheckCircle2}
            label="Examens blancs"
            value={String(k.mock_exams_30d)}
            hint="30 derniers jours"
            tone="navy"
          />
        </div>
      </section>

      {/* ─────────── Section BUSINESS ─────────── */}
      <section>
        <h2 className="font-display text-lg font-semibold text-navy-900 mb-3 inline-flex items-center gap-2">
          <Banknote className="h-4 w-4 text-gold-700" />
          Business
        </h2>
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-3">
          <Kpi
            icon={Banknote}
            label="CA 30 jours"
            value={fmtEuro(k.revenue_30d_cents)}
            hint="Encaissements"
            tone="gold"
          />
          <Kpi
            icon={UserPlus}
            label="Nouveaux stagiaires"
            value={String(k.new_users_7d)}
            hint="7 derniers jours"
            tone="signal"
          />
          <Kpi
            icon={BarChart3}
            label="Inscriptions actives"
            value={String(k.active_enrollments)}
            hint="En cours"
            tone="navy"
          />
          <Kpi
            icon={Calendar}
            label="Sessions live"
            value={String(k.live_sessions_scheduled)}
            hint={`${k.live_sessions_completed_30d} clôturées 30j`}
            tone="navy"
          />
          <Kpi
            icon={Sparkles}
            label="Copies à corriger"
            value={String(k.pending_corrections)}
            hint="Formateurs"
            tone={k.pending_corrections > 0 ? "gold" : "slate"}
            href="/formateur/corrections"
          />
        </div>
      </section>

      {/* ─────────── Graphique trends 30j ─────────── */}
      <section className="grid lg:grid-cols-2 gap-5">
        <Card>
          <CardBody>
            <div className="flex items-center justify-between mb-4">
              <div>
                <h3 className="font-display text-base font-semibold text-navy-900">
                  Activité — 30 derniers jours
                </h3>
                <p className="text-xs text-slate-500 mt-0.5">
                  Inscriptions, tentatives de quiz, paiements (par jour)
                </p>
              </div>
            </div>
            <TrendsChart data={(trends ?? []) as any[]} />
          </CardBody>
        </Card>

        <Card>
          <CardBody>
            <div className="flex items-center justify-between mb-4">
              <div>
                <h3 className="font-display text-base font-semibold text-navy-900">
                  Taux de complétion par formation
                </h3>
                <p className="text-xs text-slate-500 mt-0.5">
                  Leçons complétées / total leçons (inscriptions actives)
                </p>
              </div>
            </div>
            <CompletionBars data={(completion ?? []) as any[]} />
          </CardBody>
        </Card>
      </section>

      {/* ─────────── Section Qualiopi / RNCP ─────────── */}
      <QualiopiSection data={(qualiopi as any) ?? null} />

      {/* ─────────── Section À risque + Top 10 (côte à côte) ─────────── */}
      <section className="grid lg:grid-cols-2 gap-5">
        <AtRiskSection rows={(atRisk ?? []) as any[]} />
        <TopStudentsSection rows={(topStudents ?? []) as any[]} />
      </section>

      {/* ─────────── CA par formation × pack ─────────── */}
      <RevenueMatrixSection rows={(revenueMatrix ?? []) as any[]} />

      {/* ─────────── Quiz à difficulté anormale ─────────── */}
      <QuizOutliersSection rows={(quizOutliers ?? []) as any[]} />

      {/* ─────────── Funnel + Sessions à venir (Lot 2) ─────────── */}
      <section className="grid lg:grid-cols-2 gap-5">
        <Card>
          <CardBody>
            <div className="flex items-center gap-2 mb-3">
              <TrendingUp className="h-4 w-4 text-signal-700" />
              <h3 className="font-display text-base font-semibold text-navy-900">
                Funnel de conversion stagiaire
              </h3>
            </div>
            <p className="text-[11px] text-slate-500 mb-4">
              Signup → 1ère leçon → 1er quiz tenté → 1er quiz réussi → 1er paiement
            </p>
            <FunnelChart data={(funnel as any) ?? null} />
          </CardBody>
        </Card>

        <UpcomingSessionsSection sessions={(upcomingSessions ?? []) as any[]} />
      </section>

      {/* ─────────── Heatmap activité hebdomadaire (Lot 2) ─────────── */}
      <Card>
        <CardBody>
          <div className="flex items-center gap-2 mb-3">
            <Calendar className="h-4 w-4 text-brand-700" />
            <h3 className="font-display text-base font-semibold text-navy-900">
              Heatmap d'activité hebdomadaire
            </h3>
          </div>
          <p className="text-[11px] text-slate-500 mb-4">
            Quand vos stagiaires sont-ils le plus actifs ? Tentatives de quiz par jour × heure (90 derniers jours)
          </p>
          <HeatmapGrid cells={(heatmap ?? []) as any[]} />
        </CardBody>
      </Card>

      {/* ─────────── Évolution par formation (Lot 2) ─────────── */}
      <section>
        <div className="flex items-center gap-2 mb-3">
          <BarChart3 className="h-4 w-4 text-brand-700" />
          <h2 className="font-display text-base font-semibold text-navy-900">
            Évolution par formation
          </h2>
          <span className="text-[11px] text-slate-500">
            30 derniers jours · top 6 formations
          </span>
        </div>
        <FormationTrendsGrid rows={(trendsByFormation ?? []) as any[]} />
      </section>

      {/* ─────────── Tableau dernières tentatives ─────────── */}
      <section>
        <div className="flex items-center justify-between mb-3 flex-wrap gap-2">
          <h2 className="font-display text-lg font-semibold text-navy-900 inline-flex items-center gap-2">
            <TrendingUp className="h-4 w-4 text-brand-700" />
            Dernières tentatives
          </h2>
          <span className="text-xs text-slate-500">
            50 plus récentes ·{" "}
            <span className="text-signal-700 font-medium">
              {attempts?.length ?? 0}
            </span>
          </span>
        </div>

        <AnalyticsToolbar quizzes={quizzes ?? []} />

        <Card className="mt-3">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="bg-navy-50/60 text-[11px] uppercase tracking-wider text-slate-600">
                  <th className="text-left px-5 py-3 font-semibold">Stagiaire</th>
                  <th className="text-left px-5 py-3 font-semibold">Exercice</th>
                  <th className="text-left px-5 py-3 font-semibold">Score</th>
                  <th className="text-left px-5 py-3 font-semibold">Statut</th>
                  <th className="text-left px-5 py-3 font-semibold">Date</th>
                  <th className="px-5 py-3" />
                </tr>
              </thead>
              <tbody>
                {attempts?.map((a: any) => (
                  <tr
                    key={a.id}
                    className="border-t border-navy-50 hover:bg-navy-50/30"
                  >
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
                    <td className="px-5 py-3.5 text-slate-700">
                      {a.quizzes?.title}
                    </td>
                    <td
                      className={`px-5 py-3.5 font-display font-semibold ${scoreColor(
                        a.percentage ?? 0
                      )}`}
                    >
                      {a.percentage != null ? `${a.percentage}%` : "—"}
                    </td>
                    <td className="px-5 py-3.5">
                      {a.status === "awaiting_review" ? (
                        <Badge tone="gold" size="sm">
                          En correction
                        </Badge>
                      ) : a.passed === true ? (
                        <Badge tone="success" size="sm">
                          Réussi
                        </Badge>
                      ) : a.passed === false ? (
                        <Badge tone="slate" size="sm">
                          Échec
                        </Badge>
                      ) : (
                        <Badge tone="navy" size="sm">
                          —
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
                    <td
                      colSpan={6}
                      className="px-5 py-16 text-center text-slate-400"
                    >
                      Aucune tentative pour le moment.
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

// =====================================================================
// KPI Card — version compacte (5 par ligne au lieu de 3)
// =====================================================================
function Kpi({
  icon: Icon,
  label,
  value,
  hint,
  tone,
  href,
}: {
  icon: any;
  label: string;
  value: string;
  hint?: string;
  tone?: "navy" | "signal" | "gold" | "rose" | "slate";
  href?: string;
}) {
  const styles: Record<string, { bg: string; iconBg: string; iconColor: string; valueColor: string }> = {
    navy: {
      bg: "bg-white border-navy-100 dark:bg-white/[0.04] dark:border-white/10",
      iconBg: "bg-navy-50 dark:bg-white/10",
      iconColor: "text-navy-900 dark:text-white",
      valueColor: "text-navy-950 dark:text-white",
    },
    signal: {
      bg: "bg-white border-signal-500/30 dark:bg-signal-500/[0.06] dark:border-signal-500/25",
      iconBg: "bg-signal-500/15",
      iconColor: "text-signal-800 dark:text-signal-300",
      valueColor: "text-navy-950 dark:text-white",
    },
    gold: {
      bg: "bg-gradient-to-br from-gold-50 to-white border-gold-200 dark:from-gold-500/[0.08] dark:to-transparent dark:border-gold-500/25",
      iconBg: "bg-gold-100 dark:bg-gold-500/15",
      iconColor: "text-gold-800 dark:text-gold-300",
      valueColor: "text-navy-950 dark:text-white",
    },
    rose: {
      bg: "bg-rose-50/40 border-rose-200 dark:bg-rose-500/[0.08] dark:border-rose-500/25",
      iconBg: "bg-rose-100 dark:bg-rose-500/15",
      iconColor: "text-rose-700 dark:text-rose-300",
      valueColor: "text-rose-900 dark:text-rose-200",
    },
    slate: {
      bg: "bg-white border-navy-100 dark:bg-white/[0.03] dark:border-white/10",
      iconBg: "bg-slate-100 dark:bg-white/10",
      iconColor: "text-slate-500 dark:text-white/60",
      valueColor: "text-slate-700 dark:text-white/80",
    },
  };
  const s = styles[tone ?? "navy"];

  const inner = (
    <div
      className={`rounded-2xl border p-4 transition-[transform,box-shadow,border-color] duration-200 ease-premium hover:-translate-y-0.5 hover:shadow-raised motion-reduce:transition-none motion-reduce:hover:translate-y-0 ${s.bg} ${
        href ? "cursor-pointer" : ""
      }`}
    >
      <div className="flex items-start gap-3">
        <div
          className={`h-9 w-9 rounded-lg ${s.iconBg} ${s.iconColor} flex items-center justify-center shrink-0`}
        >
          <Icon className="h-4 w-4" />
        </div>
        <div className="min-w-0 flex-1">
          <div className="text-[10px] uppercase tracking-wider text-slate-500 dark:text-white/50 font-semibold truncate">
            {label}
          </div>
          <div
            className={`font-display text-xl font-semibold mt-0.5 ${s.valueColor} truncate`}
          >
            {value}
          </div>
          {hint && (
            <div className="text-[11px] text-slate-500 dark:text-white/40 mt-0.5 truncate">
              {hint}
            </div>
          )}
        </div>
      </div>
    </div>
  );

  if (href) {
    return <Link href={href}>{inner}</Link>;
  }
  return inner;
}
