import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  ArrowLeft,
  TrendingUp,
  Users,
  UserPlus,
  CheckCircle2,
  Globe,
  Target,
  Sparkles,
} from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { isStaff } from "@/lib/permissions";
import type { Views } from "@/lib/database.types";

export const dynamic = "force-dynamic";

// Les vues Postgres perdent les contraintes NOT NULL → l'introspection génère
// toutes leurs colonnes en `| null`. Les colonnes de regroupement ci-dessous
// (source / medium / campaign / day) sont issues d'agrégats COALESCE côté SQL
// et sont donc toujours renseignées : on les resserre en non-null (contrat déjà
// assumé par <DailyChart /> et <SourceBadge />).
type FunnelRow = Views<"vw_admin_funnel_by_utm"> & {
  source: string;
  medium: string;
  campaign: string;
};
type CampaignRow = Views<"vw_admin_top_campaigns"> & {
  source: string;
  campaign: string;
  last_seen_at: string;
};
type DailyRow = Views<"vw_admin_acquisition_daily"> & {
  day: string;
  source: string;
  visitors: number;
};

const SOURCE_LABEL: Record<string, string> = {
  direct: "Direct",
  google: "Google",
  bing: "Bing",
  facebook: "Facebook",
  instagram: "Instagram",
  linkedin: "LinkedIn",
  newsletter: "Newsletter",
};

const SOURCE_COLORS: Record<string, string> = {
  direct: "#64748b",
  google: "#4285F4",
  bing: "#00809D",
  facebook: "#1877F2",
  instagram: "#E1306C",
  linkedin: "#0A66C2",
  newsletter: "#F59E0B",
};

export default async function AdminAcquisitionPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();
  if (!profile?.role || !isStaff(profile.role)) redirect("/dashboard");

  // ─── Données ────────────────────────────────────────────────────────
  const [
    { data: funnelRaw },
    { data: campaignsRaw },
    { data: dailyRaw },
    { data: totalEventsRaw },
  ] = await Promise.all([
    supabase
      .from("vw_admin_funnel_by_utm")
      .select("*")
      .limit(50),
    supabase
      .from("vw_admin_top_campaigns")
      .select("*")
      .limit(20),
    supabase
      .from("vw_admin_acquisition_daily")
      .select("*")
      .order("day", { ascending: true }),
    supabase
      .from("acquisition_events")
      .select("id", { count: "exact", head: true }),
  ]);

  const funnel = (funnelRaw ?? []) as FunnelRow[];
  const campaigns = (campaignsRaw ?? []) as CampaignRow[];
  const daily = (dailyRaw ?? []) as DailyRow[];

  // KPIs agrégés
  const totals = {
    visitors: funnel.reduce((s, r) => s + (r.visitors ?? 0), 0),
    signups: funnel.reduce((s, r) => s + (r.signups ?? 0), 0),
    enrollments: funnel.reduce((s, r) => s + (r.enrollments ?? 0), 0),
    activeSources: new Set(funnel.map((r) => r.source)).size,
  };
  const globalConvPct =
    totals.signups > 0
      ? Math.round((totals.enrollments / totals.signups) * 100)
      : null;

  return (
    <div className="space-y-8">
      <div>
        <Link
          href="/admin/analytics"
          className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
        >
          <ArrowLeft className="h-4 w-4" /> Analytics
        </Link>
      </div>

      <header>
        <span className="eyebrow text-gold-700 inline-flex items-center gap-1.5">
          <Target className="h-3.5 w-3.5" />
          Acquisition — UTM
        </span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          D'où viennent vos prospects ?
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Tracking first-touch des sources d'acquisition. Mesurez le retour sur
          investissement de vos campagnes Instagram, LinkedIn, Google Ads, etc.
        </p>
      </header>

      {/* KPIs */}
      <section className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
        <Kpi
          icon={Globe}
          label="Visiteurs uniques"
          value={totals.visitors.toLocaleString("fr-FR")}
          hint={`Sur ${totals.activeSources} source${totals.activeSources > 1 ? "s" : ""}`}
        />
        <Kpi
          icon={UserPlus}
          label="Inscriptions"
          value={totals.signups.toLocaleString("fr-FR")}
          hint={
            totals.visitors > 0
              ? `${Math.round((totals.signups / totals.visitors) * 100)}% des visiteurs`
              : "—"
          }
        />
        <Kpi
          icon={CheckCircle2}
          label="Payants"
          value={totals.enrollments.toLocaleString("fr-FR")}
          hint={globalConvPct != null ? `${globalConvPct}% des inscrits` : "—"}
          tone="success"
        />
        <Kpi
          icon={TrendingUp}
          label="Top canal"
          value={
            funnel[0]?.source
              ? SOURCE_LABEL[funnel[0].source] ?? funnel[0].source
              : "—"
          }
          hint={
            funnel[0]?.enrollments != null
              ? `${funnel[0].enrollments} conversions`
              : undefined
          }
        />
      </section>

      {/* Tableau funnel par source */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 inline-flex items-center gap-2">
          <TrendingUp className="h-5 w-5 text-gold-700" />
          Funnel par source & medium
        </h2>
        <Card>
          <CardBody className="p-0 overflow-x-auto">
            {funnel.length === 0 ? (
              <div className="text-center py-12 px-5">
                <div className="mx-auto h-12 w-12 rounded-xl bg-gold-50 border border-gold-200 text-gold-700 flex items-center justify-center">
                  <Sparkles className="h-6 w-6" />
                </div>
                <p className="mt-4 font-medium text-navy-900">
                  Pas encore de données d'acquisition
                </p>
                <p className="text-sm text-slate-600 mt-1 max-w-md mx-auto">
                  Le tracking est actif sur les pages publiques. Les premiers
                  événements apparaîtront dès que des visiteurs arriveront avec
                  des paramètres UTM (ex:{" "}
                  <code className="text-xs bg-navy-50 px-1 rounded">
                    ?utm_source=instagram&amp;utm_campaign=summer
                  </code>
                  ).
                </p>
              </div>
            ) : (
              <table className="w-full text-sm">
                <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                  <tr>
                    <th className="text-left px-4 py-3 font-semibold">Source</th>
                    <th className="text-left px-4 py-3 font-semibold">Medium</th>
                    <th className="text-left px-4 py-3 font-semibold">Campagne</th>
                    <th className="text-right px-4 py-3 font-semibold">Visiteurs</th>
                    <th className="text-right px-4 py-3 font-semibold">Inscriptions</th>
                    <th className="text-right px-4 py-3 font-semibold">Payants</th>
                    <th className="text-right px-4 py-3 font-semibold">Taux</th>
                  </tr>
                </thead>
                <tbody>
                  {funnel.map((row, i) => (
                    <tr key={i} className="border-t border-navy-50">
                      <td className="px-4 py-3">
                        <SourceBadge source={row.source} />
                      </td>
                      <td className="px-4 py-3 text-slate-600">
                        {row.medium === "(none)" ? "—" : row.medium}
                      </td>
                      <td className="px-4 py-3 text-slate-600">
                        {row.campaign === "(none)" ? "—" : row.campaign}
                      </td>
                      <td className="px-4 py-3 text-right tabular-nums text-navy-900">
                        {(row.visitors ?? 0).toLocaleString("fr-FR")}
                      </td>
                      <td className="px-4 py-3 text-right tabular-nums text-navy-900">
                        {(row.signups ?? 0).toLocaleString("fr-FR")}
                      </td>
                      <td className="px-4 py-3 text-right">
                        <span className="font-display font-semibold tabular-nums text-emerald-700">
                          {(row.enrollments ?? 0).toLocaleString("fr-FR")}
                        </span>
                      </td>
                      <td className="px-4 py-3 text-right">
                        {row.conversion_pct != null ? (
                          <Badge
                            tone={
                              row.conversion_pct >= 10
                                ? "success"
                                : row.conversion_pct >= 3
                                  ? "gold"
                                  : "slate"
                            }
                            size="sm"
                          >
                            {row.conversion_pct}%
                          </Badge>
                        ) : (
                          <span className="text-slate-400 text-xs">—</span>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </CardBody>
        </Card>
      </section>

      {/* Courbe 30 jours */}
      {daily.length > 0 && (
        <section>
          <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 inline-flex items-center gap-2">
            <Globe className="h-5 w-5 text-gold-700" />
            Visiteurs uniques par jour (30 j)
          </h2>
          <Card>
            <CardBody>
              <DailyChart rows={daily} />
            </CardBody>
          </Card>
        </section>
      )}

      {/* Top campagnes */}
      {campaigns.length > 0 && (
        <section>
          <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 inline-flex items-center gap-2">
            <Sparkles className="h-5 w-5 text-gold-700" />
            Top campagnes
          </h2>
          <Card>
            <CardBody className="p-0">
              <table className="w-full text-sm">
                <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                  <tr>
                    <th className="text-left px-4 py-3 font-semibold">Campagne</th>
                    <th className="text-left px-4 py-3 font-semibold">Source</th>
                    <th className="text-right px-4 py-3 font-semibold">Visiteurs</th>
                    <th className="text-right px-4 py-3 font-semibold">Inscriptions</th>
                    <th className="text-left px-4 py-3 font-semibold">Dernière activité</th>
                  </tr>
                </thead>
                <tbody>
                  {campaigns.map((c, i) => (
                    <tr key={i} className="border-t border-navy-50">
                      <td className="px-4 py-3 font-medium text-navy-900">
                        {c.campaign}
                      </td>
                      <td className="px-4 py-3">
                        <SourceBadge source={c.source} />
                      </td>
                      <td className="px-4 py-3 text-right tabular-nums">
                        {(c.visitors ?? 0).toLocaleString("fr-FR")}
                      </td>
                      <td className="px-4 py-3 text-right tabular-nums text-navy-900 font-medium">
                        {(c.signups ?? 0).toLocaleString("fr-FR")}
                      </td>
                      <td className="px-4 py-3 text-slate-500 text-xs">
                        {new Date(c.last_seen_at).toLocaleDateString("fr-FR", {
                          day: "2-digit",
                          month: "short",
                          year: "numeric",
                        })}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </CardBody>
          </Card>
        </section>
      )}

      {/* Astuce intégration */}
      <Card variant="gold">
        <CardBody className="space-y-3">
          <h3 className="font-display font-semibold text-navy-900">
            Comment utiliser le tracking
          </h3>
          <p className="text-sm text-slate-700">
            Pour mesurer l'efficacité d'une campagne, ajoutez des paramètres
            UTM à vos liens. Exemple pour une story Instagram :
          </p>
          <code className="block text-xs bg-white border border-gold-200 rounded p-3 overflow-x-auto">
            https://maformationtransport.fr/?utm_source=instagram&amp;utm_medium=story&amp;utm_campaign=lancement_2026
          </code>
          <p className="text-xs text-slate-600">
            Paramètres reconnus : <code>utm_source</code>, <code>utm_medium</code>,{" "}
            <code>utm_campaign</code>, <code>utm_content</code>,{" "}
            <code>utm_term</code>. L'attribution est <strong>first-touch</strong> :
            on retient la 1re source par laquelle un visiteur est arrivé.
          </p>
        </CardBody>
      </Card>
    </div>
  );
}

function SourceBadge({ source }: { source: string }) {
  const label = SOURCE_LABEL[source] ?? source;
  const color = SOURCE_COLORS[source] ?? "#64748b";
  return (
    <div className="inline-flex items-center gap-1.5">
      <span
        className="inline-block h-2 w-2 rounded-full shrink-0"
        style={{ backgroundColor: color }}
      />
      <span className="font-medium text-navy-900">{label}</span>
    </div>
  );
}

function Kpi({
  icon: Icon,
  label,
  value,
  hint,
  tone = "default",
}: {
  icon: LucideIcon;
  label: string;
  value: string;
  hint?: string;
  tone?: "default" | "success";
}) {
  const iconBg =
    tone === "success"
      ? "bg-emerald-50 border-emerald-200 text-emerald-700"
      : "bg-gold-50 border-gold-200 text-gold-700";
  return (
    <Card>
      <CardBody className="p-4 sm:p-5">
        <div className="flex items-start gap-3">
          <div
            className={`h-10 w-10 rounded-xl border flex items-center justify-center shrink-0 ${iconBg}`}
          >
            <Icon className="h-5 w-5" />
          </div>
          <div className="min-w-0">
            <div className="text-[11px] uppercase tracking-wider text-slate-500 font-medium leading-tight">
              {label}
            </div>
            <div className="font-display text-2xl font-semibold text-navy-900 mt-0.5 tabular-nums leading-none">
              {value}
            </div>
            {hint && (
              <div className="text-[11px] text-slate-500 mt-1.5">{hint}</div>
            )}
          </div>
        </div>
      </CardBody>
    </Card>
  );
}

function DailyChart({
  rows,
}: {
  rows: Array<{ day: string; source: string; visitors: number }>;
}) {
  // Aggrège par jour (somme toutes sources)
  const byDay = new Map<string, number>();
  for (const r of rows) {
    byDay.set(r.day, (byDay.get(r.day) ?? 0) + r.visitors);
  }
  const entries = Array.from(byDay.entries()).sort();
  const max = Math.max(...entries.map(([, v]) => v), 1);

  return (
    <div className="space-y-1">
      {entries.map(([day, visitors]) => {
        const widthPct = Math.round((visitors / max) * 100);
        const label = new Date(day).toLocaleDateString("fr-FR", {
          day: "2-digit",
          month: "short",
        });
        return (
          <div
            key={day}
            className="grid grid-cols-[60px_1fr_50px] gap-3 items-center"
          >
            <div className="text-[11px] text-slate-500 tabular-nums">
              {label}
            </div>
            <div className="h-3 rounded bg-slate-100 overflow-hidden">
              {widthPct > 0 && (
                <div
                  className="h-full bg-gold-500"
                  style={{ width: `${widthPct}%` }}
                />
              )}
            </div>
            <div className="text-right text-[11px] tabular-nums">
              {visitors}
            </div>
          </div>
        );
      })}
    </div>
  );
}
