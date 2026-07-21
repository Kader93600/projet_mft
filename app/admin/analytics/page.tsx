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
  Smartphone,
  MapPin,
  Mail,
  type LucideIcon,
} from "lucide-react";
import type { Tables, Views } from "@/lib/database.types";
import { AnalyticsToolbar } from "./analytics-toolbar";
import { DeleteAttemptButton } from "./analytics-row-actions";
import { TrendsChart } from "./charts-lazy";
import { CompletionBars } from "./charts-lazy";
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
import { FormationTrendsGrid } from "./charts-lazy";
import { UpcomingSessionsSection } from "./upcoming-sessions";
import { PeriodFilter, KpiWithDelta } from "./period-filter";
import { AnalyticsTabs } from "./analytics-tabs";
import { PrintButton } from "./print-button";
import Link from "next/link";
import { Tv } from "lucide-react";

export const dynamic = "force-dynamic";

/**
 * L'introspection type toutes les colonnes de vue en `| null` (Postgres ne
 * garantit pas la non-nullité d'une expression). Ces vues sont des agrégats
 * (`count`, `coalesce`) qui n'émettent jamais NULL : on lit donc les lignes
 * via ce mapping « non-null », qui correspond au contrat des composants.
 */
type NonNullRow<T> = { [K in keyof T]-?: NonNullable<T[K]> };

type KpiSnapshot = NonNullRow<Views<"vw_admin_kpis_realtime">>;
type TrendsRow = NonNullRow<Views<"vw_admin_trends_30d">>;
type CompletionRow = NonNullRow<Views<"vw_admin_completion_by_formation">>;
type AtRiskRow = NonNullRow<Views<"vw_admin_at_risk_students">>;
type TopStudentRow = NonNullRow<Views<"vw_admin_top_students">>;
type QualiopiRow = NonNullRow<Views<"vw_admin_qualiopi_indicators">>;
type QuizOutlierRow = Omit<
  NonNullRow<Views<"vw_admin_quiz_outliers">>,
  "difficulty_flag"
> & { difficulty_flag: "too_hard" | "too_easy" | "normal" | "unknown" };
type RevenueRow = Omit<
  NonNullRow<Views<"vw_admin_revenue_by_formation_pack">>,
  "pack"
> & { pack: "initial" | "medium" | "premium" };
type FunnelRow = NonNullRow<Views<"vw_admin_funnel_conversion">>;
type HeatmapRow = NonNullRow<Views<"vw_admin_activity_heatmap">>;
type FormationTrendRow = NonNullRow<Views<"vw_admin_trends_by_formation">>;
type UpcomingSessionRow = Omit<
  NonNullRow<Views<"vw_admin_upcoming_sessions_14d">>,
  "kind"
> & { kind: "presentiel" | "distanciel" | "hybride" };
type UtmRow = Pick<
  Views<"vw_admin_funnel_by_utm">,
  "source" | "visitors" | "signups" | "enrollments"
>;
type AcquisitionEventRow = Pick<
  Tables<"acquisition_events">,
  "user_agent" | "ip_country" | "kind"
>;
type QuizOption = Pick<Tables<"quizzes">, "id" | "title">;
type AttemptRow = Tables<"quiz_attempts"> & {
  profiles: Pick<Tables<"profiles">, "id" | "full_name" | "email"> | null;
  quizzes: Pick<Tables<"quizzes">, "title"> | null;
};

/** Retour du RPC `get_admin_kpis_for_period` (absent des types générés). */
interface PeriodKpis {
  signups: number;
  quiz_attempts: number;
  payments: number;
  revenue_cents: number;
  signups_prev: number;
  quiz_attempts_prev: number;
  payments_prev: number;
  revenue_cents_prev: number;
}

function fmtEuro(cents: number): string {
  return new Intl.NumberFormat("fr-FR", {
    style: "currency",
    currency: "EUR",
    maximumFractionDigits: 0,
  }).format((cents ?? 0) / 100);
}

// Code pays ISO 3166-1 alpha-2 → emoji drapeau (indicateurs régionaux).
function flagEmoji(code: string): string {
  const cc = (code ?? "").trim().toUpperCase();
  if (!/^[A-Z]{2}$/.test(cc)) return "🏳️";
  const A = 0x1f1e6; // 🇦
  return String.fromCodePoint(
    A + (cc.charCodeAt(0) - 65),
    A + (cc.charCodeAt(1) - 65)
  );
}

export default async function AdminAnalytics(
  props: {
    searchParams?: Promise<{ period?: string }>;
  }
) {
  const searchParams = await props.searchParams;
  const supabase = await createClient();

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
      .select(
        "*, profiles!quiz_attempts_user_id_fkey(id, full_name, email), quizzes(title)"
      )
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
    { count: leadsTotal },
    { count: leadsConverted },
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
    // Leads (CRM) : total + convertis (counts seuls, head:true).
    supabase
      .from("enrollment_requests")
      .select("id", { count: "exact", head: true }),
    supabase
      .from("enrollment_requests")
      .select("id", { count: "exact", head: true })
      .eq("status", "inscrit"),
  ]);

  // Agrégat Business : packs achetés (depuis vw_admin_revenue_by_formation_pack).
  const packAgg: Record<string, { count: number; revenue: number }> = {
    initial: { count: 0, revenue: 0 },
    medium: { count: 0, revenue: 0 },
    premium: { count: 0, revenue: 0 },
  };
  const revenueRows = (revenueMatrix ?? []) as RevenueRow[];
  for (const r of revenueRows) {
    const p = packAgg[r.pack];
    if (p) {
      p.count += Number(r.enrollments_count) || 0;
      p.revenue += Number(r.revenue_cents) || 0;
    }
  }
  const leadsConvPct =
    (leadsTotal ?? 0) > 0
      ? Math.round(((leadsConverted ?? 0) / (leadsTotal ?? 1)) * 100)
      : 0;

  // Vitrine approfondie : appareils + pays + demandes de contact.
  // Agrégation JS bornée sur la période (acquisition_events n'a pas de vue
  // dédiée ; volume vitrine raisonnable). Un index/vue pourra être ajouté si
  // le trafic explose.
  const sinceIso = new Date(
    Date.now() - periodDays * 86_400_000
  ).toISOString();
  const { data: rawEvents } = await supabase
    .from("acquisition_events")
    .select("user_agent, ip_country, kind")
    .gte("occurred_at", sinceIso)
    .order("occurred_at", { ascending: false })
    .limit(10000);
  const devices = { mobile: 0, desktop: 0, tablet: 0 };
  const countries: Record<string, number> = {};
  let contactForms = 0;
  for (const e of (rawEvents ?? []) as AcquisitionEventRow[]) {
    const ua = String(e.user_agent ?? "").toLowerCase();
    const d = /ipad|tablet|playbook|silk/.test(ua)
      ? "tablet"
      : /mobi|iphone|ipod|android/.test(ua)
        ? "mobile"
        : "desktop";
    devices[d]++;
    if (e.ip_country) countries[e.ip_country] = (countries[e.ip_country] ?? 0) + 1;
    if (e.kind === "contact_form") contactForms++;
  }
  const deviceTotal =
    devices.mobile + devices.desktop + devices.tablet || 1;
  const topCountries = Object.entries(countries)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 5);
  const maxCountry = Math.max(1, ...topCountries.map(([, c]) => c));

  // Agrégats Vitrine (acquisition).
  const utm = (utmFunnel ?? []) as UtmRow[];
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

  const pk: PeriodKpis = (periodKpis as PeriodKpis | null) ?? {
    signups: 0,
    quiz_attempts: 0,
    payments: 0,
    revenue_cents: 0,
    signups_prev: 0,
    quiz_attempts_prev: 0,
    payments_prev: 0,
    revenue_cents_prev: 0,
  };

  // ── Synthèse intelligente & alertes (heuristique, sans IA externe) ──
  const pctDelta = (cur: number, prev: number): number | null =>
    !prev || prev === 0 ? null : Math.round(((cur - prev) / prev) * 100);
  const signupsDelta = pctDelta(Number(pk.signups), Number(pk.signups_prev));
  const quizDelta = pctDelta(
    Number(pk.quiz_attempts),
    Number(pk.quiz_attempts_prev)
  );
  const revenueDelta = pctDelta(
    Number(pk.revenue_cents),
    Number(pk.revenue_cents_prev)
  );

  type Insight = {
    tone: "warning" | "info" | "success";
    title: string;
    detail: string;
  };
  const insights: Insight[] = [];
  if (signupsDelta !== null && signupsDelta <= -20)
    insights.push({
      tone: "warning",
      title: `Inscriptions en baisse (${signupsDelta}%)`,
      detail:
        "Vs période précédente. Relancez l'acquisition (campagnes, contenus, parrainage).",
    });
  if (quizDelta !== null && quizDelta <= -25)
    insights.push({
      tone: "warning",
      title: `Activité quiz en baisse (${quizDelta}%)`,
      detail:
        "L'engagement chute. Vérifiez les modules récents et relancez les stagiaires inactifs.",
    });
  if (Number(k.at_risk_students) > 0)
    insights.push({
      tone: "warning",
      title: `${k.at_risk_students} stagiaire(s) à risque d'abandon`,
      detail:
        "Inactifs depuis plus de 14 jours. Une relance personnalisée améliore nettement la rétention.",
    });
  if (Number(k.pass_rate_30d) > 0 && Number(k.pass_rate_30d) < 60)
    insights.push({
      tone: "warning",
      title: `Taux de réussite faible (${k.pass_rate_30d}%)`,
      detail:
        "Sur 30 jours. Identifiez les examens les plus ratés (section ci-dessous).",
    });
  if (Number(pk.payments) === 0 && periodDays >= 7)
    insights.push({
      tone: "warning",
      title: "Aucune vente sur la période",
      detail:
        "Aucun paiement enregistré. Vérifiez le tunnel de conversion et les devis en attente.",
    });
  if (Number(k.pending_corrections) > 0)
    insights.push({
      tone: "info",
      title: `${k.pending_corrections} copie(s) à corriger`,
      detail:
        "Des stagiaires attendent leur note — un délai long pénalise la satisfaction.",
    });
  if ((leadsTotal ?? 0) > 5 && leadsConvPct < 15)
    insights.push({
      tone: "info",
      title: `Conversion leads faible (${leadsConvPct}%)`,
      detail:
        "Beaucoup de leads non convertis. Renforcez le suivi CRM et les relances.",
    });
  if (signupsDelta !== null && signupsDelta >= 20)
    insights.push({
      tone: "success",
      title: `Inscriptions en hausse (+${signupsDelta}%)`,
      detail:
        "Bonne dynamique d'acquisition — capitalisez sur les canaux performants.",
    });
  if (revenueDelta !== null && revenueDelta >= 20)
    insights.push({
      tone: "success",
      title: `Chiffre d'affaires en hausse (+${revenueDelta}%)`,
      detail: "Le CA progresse vs période précédente. Maintenez l'effort.",
    });

  const summary =
    `Sur les ${periodDays} derniers jours : ${pk.signups} inscription(s), ` +
    `${pk.quiz_attempts} tentative(s) de quiz, ${pk.payments} vente(s) pour ` +
    `${fmtEuro(Number(pk.revenue_cents))}. ${k.active_students_7d} stagiaire(s) ` +
    `actif(s) (7j), taux de réussite ${k.pass_rate_30d}%` +
    (vitrine.visitors
      ? `, ${vitrine.visitors.toLocaleString("fr-FR")} visiteur(s) sur la vitrine.`
      : ".");

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
          <a
            href="/admin/analytics/export/csv"
            className="inline-flex items-center gap-1.5 px-3 h-9 rounded-lg text-xs font-semibold border border-navy-200 bg-white text-navy-800 hover:bg-navy-50 dark:border-white/15 dark:bg-white/5 dark:text-white/80 dark:hover:bg-white/10 transition"
            title="Exporter les tendances 30 jours au format CSV (Excel)"
          >
            <Download className="h-3.5 w-3.5" />
            Export CSV
          </a>
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

      {/* ─────────── Onglets thématiques (page allégée) ─────────── */}
      <AnalyticsTabs
        filter={<PeriodFilter />}
        overview={
          <>
            {/* Indicateurs clés sur la période */}
            <section className="rounded-2xl border border-navy-100 bg-white dark:bg-white/[0.04] dark:border-white/10 p-4">
              <div className="mb-3">
                <h2 className="font-display text-base font-semibold text-navy-900 dark:text-white inline-flex items-center gap-2">
                  <BarChart3 className="h-4 w-4 text-brand-700" />
                  Indicateurs clés
                </h2>
                <p className="text-[11px] text-slate-500 dark:text-white/50 mt-0.5">
                  KPIs sur la période sélectionnée + comparaison vs période précédente
                </p>
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

      {/* ─────────── Synthèse intelligente & alertes ─────────── */}
      <section className="rounded-2xl border border-navy-100 dark:border-white/10 bg-gradient-to-br from-brand-50/60 to-white dark:from-white/[0.05] dark:to-transparent p-5">
        <div className="flex items-center gap-2 mb-2">
          <Sparkles className="h-4 w-4 text-brand-700 dark:text-brand-300" />
          <h2 className="font-display text-base font-semibold text-navy-900 dark:text-white">
            Synthèse intelligente
          </h2>
        </div>
        <p className="text-sm text-slate-600 dark:text-white/70 leading-relaxed max-w-3xl">
          {summary}
        </p>
        {insights.length > 0 ? (
          <div className="mt-4 grid sm:grid-cols-2 gap-2.5">
            {insights.map((ins, i) => {
              const t = {
                warning: {
                  box: "border-gold-200 bg-gold-50/70 dark:border-gold-500/30 dark:bg-gold-500/[0.08]",
                  icon: "text-gold-700 dark:text-gold-300",
                  Icon: AlertTriangle,
                },
                info: {
                  box: "border-brand-200 bg-brand-50/60 dark:border-brand-500/30 dark:bg-brand-500/[0.08]",
                  icon: "text-brand-700 dark:text-brand-300",
                  Icon: Sparkles,
                },
                success: {
                  box: "border-emerald-200 bg-emerald-50/70 dark:border-emerald-500/30 dark:bg-emerald-500/[0.08]",
                  icon: "text-emerald-700 dark:text-emerald-300",
                  Icon: CheckCircle2,
                },
              }[ins.tone];
              const I = t.Icon;
              return (
                <div
                  key={i}
                  className={`flex items-start gap-2.5 rounded-xl border p-3 ${t.box}`}
                >
                  <I className={`h-4 w-4 shrink-0 mt-0.5 ${t.icon}`} />
                  <div className="min-w-0">
                    <div className="text-sm font-semibold text-navy-900 dark:text-white">
                      {ins.title}
                    </div>
                    <div className="text-[12.5px] text-slate-600 dark:text-white/60 leading-snug mt-0.5">
                      {ins.detail}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        ) : (
          <div className="mt-4 flex items-center gap-2 rounded-xl border border-emerald-200 bg-emerald-50/70 dark:border-emerald-500/30 dark:bg-emerald-500/[0.08] p-3 text-sm text-emerald-800 dark:text-emerald-200">
            <CheckCircle2 className="h-4 w-4" /> Aucune alerte : les indicateurs
            sont au vert.
          </div>
        )}
      </section>

            {/* Activité 30j + taux de complétion par formation */}
            <section className="grid lg:grid-cols-2 gap-5">
              <Card>
                <CardBody>
                  <div className="flex items-center justify-between mb-4">
                    <div>
                      <h3 className="font-display text-base font-semibold text-navy-900 dark:text-white">
                        Activité — 30 derniers jours
                      </h3>
                      <p className="text-xs text-slate-500 dark:text-white/50 mt-0.5">
                        Inscriptions, tentatives de quiz, paiements (par jour)
                      </p>
                    </div>
                  </div>
                  <TrendsChart data={(trends ?? []) as TrendsRow[]} />
                </CardBody>
              </Card>

              <Card>
                <CardBody>
                  <div className="flex items-center justify-between mb-4">
                    <div>
                      <h3 className="font-display text-base font-semibold text-navy-900 dark:text-white">
                        Taux de complétion par formation
                      </h3>
                      <p className="text-xs text-slate-500 dark:text-white/50 mt-0.5">
                        Leçons complétées / total leçons (inscriptions actives)
                      </p>
                    </div>
                  </div>
                  <CompletionBars data={(completion ?? []) as CompletionRow[]} />
                </CardBody>
              </Card>
            </section>
          </>
        }
        vitrine={
          <>
            {/* Site vitrine */}
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
                {vitrine.topSources.map((srcRow) => {
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

        {/* Appareils · Pays · Demandes de contact */}
        <div className="mt-3 grid grid-cols-1 lg:grid-cols-3 gap-3">
          <Card>
            <CardBody>
              <div className="text-[11px] uppercase tracking-wider text-slate-500 dark:text-white/50 font-semibold mb-3 inline-flex items-center gap-1.5">
                <Smartphone className="h-3.5 w-3.5" /> Appareils
              </div>
              <div className="space-y-2.5">
                {(
                  [
                    ["Mobile", devices.mobile, "bg-brand-500"],
                    ["Ordinateur", devices.desktop, "bg-signal-500"],
                    ["Tablette", devices.tablet, "bg-gold-500"],
                  ] as const
                ).map(([label, val, color]) => {
                  const pct = Math.round((val / deviceTotal) * 100);
                  return (
                    <div key={label} className="flex items-center gap-3">
                      <div className="w-24 shrink-0 text-sm text-navy-900 dark:text-white/90">
                        {label}
                      </div>
                      <div className="flex-1 h-2.5 rounded-full bg-navy-50 dark:bg-white/10 overflow-hidden">
                        <div
                          className={`h-full rounded-full ${color} transition-[width] duration-700 ease-premium`}
                          style={{ width: `${pct}%` }}
                        />
                      </div>
                      <div className="w-10 text-right text-sm font-medium text-navy-900 dark:text-white tabular-nums">
                        {pct}%
                      </div>
                    </div>
                  );
                })}
              </div>
            </CardBody>
          </Card>

          <Card>
            <CardBody>
              <div className="text-[11px] uppercase tracking-wider text-slate-500 dark:text-white/50 font-semibold mb-3 inline-flex items-center gap-1.5">
                <MapPin className="h-3.5 w-3.5" /> Top pays
              </div>
              {topCountries.length === 0 ? (
                <p className="text-sm text-slate-400">
                  Aucune donnée de géolocalisation sur la période.
                </p>
              ) : (
                <div className="space-y-2.5">
                  {topCountries.map(([country, count]) => {
                    const pct = Math.round((count / maxCountry) * 100);
                    return (
                      <div key={country} className="flex items-center gap-3">
                        <div className="w-20 shrink-0 text-sm text-navy-900 dark:text-white/90 inline-flex items-center gap-1.5">
                          <span className="text-base leading-none" aria-hidden>
                            {flagEmoji(country)}
                          </span>
                          <span className="uppercase">{country}</span>
                        </div>
                        <div className="flex-1 h-2.5 rounded-full bg-navy-50 dark:bg-white/10 overflow-hidden">
                          <div
                            className="h-full rounded-full bg-navy-400 transition-[width] duration-700 ease-premium"
                            style={{ width: `${pct}%` }}
                          />
                        </div>
                        <div className="w-12 text-right text-sm font-medium text-navy-900 dark:text-white tabular-nums">
                          {count.toLocaleString("fr-FR")}
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </CardBody>
          </Card>

          <Card>
            <CardBody className="flex h-full flex-col justify-center">
              <div className="text-[11px] uppercase tracking-wider text-slate-500 dark:text-white/50 font-semibold mb-2 inline-flex items-center gap-1.5">
                <Mail className="h-3.5 w-3.5" /> Demandes de contact
              </div>
              <div className="font-display text-4xl font-semibold text-navy-950 dark:text-white">
                {contactForms.toLocaleString("fr-FR")}
              </div>
              <div className="text-[11px] text-slate-500 dark:text-white/40 mt-1">
                Formulaires « Nous contacter » · {periodDays} derniers jours
              </div>
            </CardBody>
          </Card>
        </div>
      </section>
          </>
        }
        pedagogie={
          <>
            {/* Pédagogie */}
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

      {/* ─────────── Section Qualiopi / RNCP ─────────── */}
      <QualiopiSection data={(qualiopi as QualiopiRow | null) ?? null} />

      {/* ─────────── Section À risque + Top 10 (côte à côte) ─────────── */}
      <section className="grid lg:grid-cols-2 gap-5">
        <AtRiskSection rows={(atRisk ?? []) as AtRiskRow[]} />
        <TopStudentsSection rows={(topStudents ?? []) as TopStudentRow[]} />
      </section>

      {/* ─────────── Quiz à difficulté anormale ─────────── */}
      <QuizOutliersSection rows={(quizOutliers ?? []) as QuizOutlierRow[]} />

      {/* ─────────── Funnel + Sessions à venir (Lot 2) ─────────── */}
      <section className="grid lg:grid-cols-2 gap-5">
        <Card>
          <CardBody>
            <div className="flex items-center gap-2 mb-3">
              <TrendingUp className="h-4 w-4 text-signal-700" />
              <h3 className="font-display text-base font-semibold text-navy-900 dark:text-white">
                Funnel de conversion stagiaire
              </h3>
            </div>
            <p className="text-[11px] text-slate-500 dark:text-white/50 mb-4">
              Signup → 1ère leçon → 1er quiz tenté → 1er quiz réussi → 1er paiement
            </p>
            <FunnelChart data={(funnel as FunnelRow | null) ?? null} />
          </CardBody>
        </Card>

        <UpcomingSessionsSection
          sessions={(upcomingSessions ?? []) as UpcomingSessionRow[]}
        />
      </section>

      {/* ─────────── Heatmap activité hebdomadaire (Lot 2) ─────────── */}
      <Card>
        <CardBody>
          <div className="flex items-center gap-2 mb-3">
            <Calendar className="h-4 w-4 text-brand-700" />
            <h3 className="font-display text-base font-semibold text-navy-900 dark:text-white">
              Heatmap d'activité hebdomadaire
            </h3>
          </div>
          <p className="text-[11px] text-slate-500 dark:text-white/50 mb-4">
            Quand vos stagiaires sont-ils le plus actifs ? Tentatives de quiz par jour × heure (90 derniers jours)
          </p>
          <HeatmapGrid cells={(heatmap ?? []) as HeatmapRow[]} />
        </CardBody>
      </Card>

      {/* ─────────── Évolution par formation (Lot 2) ─────────── */}
      <section>
        <div className="flex items-center gap-2 mb-3">
          <BarChart3 className="h-4 w-4 text-brand-700" />
          <h2 className="font-display text-base font-semibold text-navy-900 dark:text-white">
            Évolution par formation
          </h2>
          <span className="text-[11px] text-slate-500 dark:text-white/50">
            30 derniers jours · top 6 formations
          </span>
        </div>
        <FormationTrendsGrid
          rows={(trendsByFormation ?? []) as FormationTrendRow[]}
        />
      </section>

      {/* ─────────── Tableau dernières tentatives ─────────── */}
      <section>
        <div className="flex items-center justify-between mb-3 flex-wrap gap-2">
          <h2 className="font-display text-lg font-semibold text-navy-900 dark:text-white inline-flex items-center gap-2">
            <TrendingUp className="h-4 w-4 text-brand-700" />
            Dernières tentatives
          </h2>
          <span className="text-xs text-slate-500 dark:text-white/50">
            50 plus récentes ·{" "}
            <span className="text-signal-700 font-medium">
              {attempts?.length ?? 0}
            </span>
          </span>
        </div>

        <AnalyticsToolbar quizzes={(quizzes ?? []) as QuizOption[]} />

        <Card className="mt-3">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="bg-navy-50/60 dark:bg-white/[0.06] text-[11px] uppercase tracking-wider text-slate-600 dark:text-white/50">
                  <th className="text-left px-5 py-3 font-semibold">Stagiaire</th>
                  <th className="text-left px-5 py-3 font-semibold">Exercice</th>
                  <th className="text-left px-5 py-3 font-semibold">Score</th>
                  <th className="text-left px-5 py-3 font-semibold">Statut</th>
                  <th className="text-left px-5 py-3 font-semibold">Date</th>
                  <th className="px-5 py-3" />
                </tr>
              </thead>
              <tbody>
                {((attempts ?? []) as AttemptRow[]).map((a) => (
                  <tr
                    key={a.id}
                    className="border-t border-navy-50 dark:border-white/10 hover:bg-navy-50/30 dark:hover:bg-white/[0.04]"
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
                          <div className="font-medium text-navy-900 dark:text-white group-hover:text-gold-700">
                            {a.profiles?.full_name || a.profiles?.email}
                          </div>
                          <div className="text-xs text-slate-500 dark:text-white/40">
                            {a.profiles?.email}
                          </div>
                        </div>
                      </Link>
                    </td>
                    <td className="px-5 py-3.5 text-slate-700 dark:text-white/70">
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
                    <td className="px-5 py-3.5 text-slate-500 dark:text-white/40 text-xs">
                      {a.finished_at && formatDate(a.finished_at)}
                    </td>
                    <td className="px-5 py-3.5 text-right">
                      <div className="inline-flex items-center gap-1">
                        <a
                          href={`/admin/analytics/export/pdf?attempt=${a.id}`}
                          target="_blank"
                          title="Télécharger la copie corrigée"
                          className="h-7 w-7 rounded-md text-slate-400 hover:text-navy-900 hover:bg-navy-50 dark:text-white/40 dark:hover:text-white dark:hover:bg-white/10 inline-flex items-center justify-center"
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
          </>
        }
        business={
          <>
            {/* Business */}
            <section>
        <h2 className="font-display text-lg font-semibold text-navy-900 dark:text-white mb-3 inline-flex items-center gap-2">
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

        {/* Packs achetés (Initial / Medium / Premium) */}
        <div className="mt-4">
          <div className="text-[11px] uppercase tracking-wider text-slate-500 dark:text-white/50 font-semibold mb-2">
            Packs achetés
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
            {(["initial", "medium", "premium"] as const).map((p) => {
              const agg = packAgg[p];
              const label =
                p === "initial" ? "Initial" : p === "medium" ? "Medium" : "Premium";
              return (
                <div
                  key={p}
                  className="rounded-2xl border border-navy-100 bg-white dark:bg-white/[0.04] dark:border-white/10 p-4 transition-[transform,box-shadow] duration-200 ease-premium hover:-translate-y-0.5 hover:shadow-raised motion-reduce:transition-none motion-reduce:hover:translate-y-0"
                >
                  <div className="flex items-center justify-between gap-2">
                    <span className="text-sm font-semibold text-navy-900 dark:text-white">
                      Pack {label}
                    </span>
                    <Badge
                      tone={p === "premium" ? "gold" : p === "medium" ? "navy" : "slate"}
                      size="sm"
                    >
                      {agg.count} vente{agg.count > 1 ? "s" : ""}
                    </Badge>
                  </div>
                  <div className="mt-2 font-display text-2xl font-semibold text-navy-950 dark:text-white">
                    {fmtEuro(agg.revenue)}
                  </div>
                  <div className="text-[11px] text-slate-500 dark:text-white/40">
                    CA cumulé
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Leads (CRM) */}
        <div className="mt-3 grid grid-cols-2 md:grid-cols-4 gap-3">
          <Kpi
            icon={UserPlus}
            label="Leads générés"
            value={String(leadsTotal ?? 0)}
            hint="Total CRM"
            tone="navy"
            href="/admin/crm"
          />
          <Kpi
            icon={TrendingUp}
            label="Conversion leads"
            value={`${leadsConvPct}%`}
            hint="Leads → inscrits"
            tone={leadsConvPct >= 20 ? "signal" : "gold"}
          />
        </div>
      </section>
            {/* CA par formation × pack */}
            <RevenueMatrixSection rows={revenueRows} />
          </>
        }
      />
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
  icon: LucideIcon;
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
