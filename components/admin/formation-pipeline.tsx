import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  ArrowRight,
  TrendingUp,
  Sparkles,
  Users,
  CheckCircle2,
  Clock,
  Truck,
  Bus,
  GraduationCap,
  Car,
  Briefcase,
  Package,
  Award,
  ShieldCheck,
} from "lucide-react";
import { FORMATIONS } from "@/lib/formations-config";
import { cn } from "@/lib/utils";

const ICONS: Record<string, any> = {
  Truck,
  Bus,
  GraduationCap,
  Car,
  Briefcase,
  Package,
  Award,
  ShieldCheck,
};

/**
 * Section pipeline business du dashboard admin :
 * pour chaque formation, le nombre de demandes 30 j, en cours, terminées,
 * avec un lien direct vers la liste filtrée.
 */
export async function FormationPipeline() {
  // Client session : les RLS sont réparées (cf. migration
  // fix_rls_org_recursion), is_admin() autorise le staff à tout voir.
  const supabase = createClient();

  const [
    { data: demand },
    { data: enrollByFormation },
  ] = await Promise.all([
    supabase.from("formations_demand").select("*"),
    supabase
      .from("enrollments")
      .select("formation_slug, status, total_amount_cents, paid_amount_cents")
      .not("formation_slug", "is", null),
  ]);

  // Indexer
  const demandBySlug = new Map<string, any>();
  (demand ?? []).forEach((row: any) =>
    demandBySlug.set(row.formation_slug, row)
  );

  const enrollBySlug = new Map<
    string,
    {
      total: number;
      en_cours: number;
      termine: number;
      revenue_cents: number;
      paid_cents: number;
    }
  >();
  (enrollByFormation ?? []).forEach((row: any) => {
    const slug = row.formation_slug ?? "unspecified";
    const acc =
      enrollBySlug.get(slug) ??
      {
        total: 0,
        en_cours: 0,
        termine: 0,
        revenue_cents: 0,
        paid_cents: 0,
      };
    acc.total++;
    acc.revenue_cents += row.total_amount_cents ?? 0;
    acc.paid_cents += row.paid_amount_cents ?? 0;
    if (row.status === "en_cours") acc.en_cours++;
    if (row.status === "termine") acc.termine++;
    enrollBySlug.set(slug, acc);
  });

  // Lignes triées par "demandes 30 j" desc puis "actifs" desc
  const rows = FORMATIONS.map((f) => {
    const d = demandBySlug.get(f.slug);
    const e = enrollBySlug.get(f.slug);
    return {
      formation: f,
      requests_30d: d?.requests_30d ?? 0,
      pending: d?.pending ?? 0,
      enrolled: e?.total ?? 0,
      active: e?.en_cours ?? 0,
      completed: e?.termine ?? 0,
      revenue: e?.revenue_cents ?? 0,
      paid: e?.paid_cents ?? 0,
    };
  }).sort((a, b) => {
    if (b.requests_30d !== a.requests_30d)
      return b.requests_30d - a.requests_30d;
    return b.active - a.active;
  });

  const totalRequests30d = rows.reduce((s, r) => s + r.requests_30d, 0);
  const totalActive = rows.reduce((s, r) => s + r.active, 0);
  const totalRevenue = rows.reduce((s, r) => s + r.revenue, 0);
  const totalPaid = rows.reduce((s, r) => s + r.paid, 0);

  return (
    <section className="space-y-5">
      <div className="flex items-end justify-between flex-wrap gap-3">
        <div>
          <span className="text-[11px] font-semibold uppercase tracking-[0.16em] text-brand-700">
            Pilotage business
          </span>
          <h2 className="mt-1 font-display text-2xl font-semibold text-navy-900">
            Pipeline par formation
          </h2>
        </div>
        <Link
          href="/admin/formations"
          className="text-sm font-medium text-brand-700 hover:text-brand-900 inline-flex items-center gap-1.5"
        >
          Vue détaillée <ArrowRight className="h-3.5 w-3.5" />
        </Link>
      </div>

      {/* KPIs business globaux */}
      <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-3">
        <MiniKpi
          icon={TrendingUp}
          label="Demandes 30 j"
          value={totalRequests30d}
          tone="signal"
        />
        <MiniKpi
          icon={Users}
          label="Stagiaires actifs"
          value={totalActive}
          tone="brand"
        />
        <MiniKpi
          icon={Sparkles}
          label="CA engagé"
          value={`${(totalRevenue / 100 / 1000).toFixed(1)} k€`}
          tone="brand"
        />
        <MiniKpi
          icon={CheckCircle2}
          label="CA encaissé"
          value={`${(totalPaid / 100 / 1000).toFixed(1)} k€`}
          tone="signal"
        />
      </div>

      {/* Cards par formation (top 4 par demande) */}
      <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-3">
        {rows.slice(0, 4).map((r) => {
          const Icon = ICONS[r.formation.iconName] ?? Truck;
          const accent = r.formation.accent ?? "#9FE220";
          return (
            <Link
              key={r.formation.slug}
              href={`/admin/enrollments?formation=${r.formation.slug}`}
              className="group relative overflow-hidden rounded-2xl border border-navy-100 bg-white p-5 transition-[border-color,box-shadow] duration-200 ease-premium hover:border-brand-300 hover:shadow-soft"
            >
              <div
                aria-hidden="true"
                className="absolute -top-10 -right-10 h-32 w-32 rounded-full opacity-15 group-hover:opacity-25 transition-opacity blur-2xl"
                style={{ backgroundColor: accent }}
              />
              <div className="relative">
                <div className="flex items-center justify-between gap-2">
                  <div
                    className="h-9 w-9 rounded-lg flex items-center justify-center"
                    style={{
                      backgroundColor: `${accent}22`,
                      border: `1px solid ${accent}55`,
                    }}
                  >
                    <Icon className="h-4 w-4" style={{ color: accent }} />
                  </div>
                  {r.pending > 0 && (
                    <Badge tone="rose" size="sm">
                      {r.pending} à traiter
                    </Badge>
                  )}
                </div>
                <div className="mt-3 text-[10px] font-semibold uppercase tracking-[0.16em] text-slate-500">
                  {r.formation.code}
                </div>
                <div className="font-medium text-navy-900 text-sm leading-tight line-clamp-2 mt-0.5">
                  {r.formation.title}
                </div>
                <div className="mt-3 grid grid-cols-3 gap-2 text-xs">
                  <Stat
                    label="Demandes 30j"
                    value={r.requests_30d}
                    highlight={r.requests_30d > 0}
                  />
                  <Stat label="Actifs" value={r.active} />
                  <Stat label="Terminés" value={r.completed} />
                </div>
              </div>
            </Link>
          );
        })}
      </div>

      {/* Tableau complet (plus dense) */}
      <Card>
        <CardBody className="p-0 overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
              <tr>
                <th className="text-left px-6 py-3">Formation</th>
                <th className="text-right px-3 py-3">Demandes 30j</th>
                <th className="text-right px-3 py-3">À traiter</th>
                <th className="text-right px-3 py-3">Actifs</th>
                <th className="text-right px-3 py-3">CA engagé</th>
                <th className="text-right px-6 py-3">CA encaissé</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((r) => (
                <tr
                  key={r.formation.slug}
                  className="border-t border-navy-50 hover:bg-navy-50/40"
                >
                  <td className="px-6 py-2.5">
                    <Link
                      href={`/admin/enrollments?formation=${r.formation.slug}`}
                      className="font-medium text-navy-900 hover:text-brand-700"
                    >
                      {r.formation.code}
                    </Link>
                  </td>
                  <td className="px-3 py-2.5 text-right">
                    {r.requests_30d > 0 ? (
                      <span className="inline-flex items-center gap-1 text-signal-700 font-semibold">
                        <Sparkles className="h-3 w-3" />
                        {r.requests_30d}
                      </span>
                    ) : (
                      <span className="text-slate-400">—</span>
                    )}
                  </td>
                  <td className="px-3 py-2.5 text-right">
                    {r.pending > 0 ? (
                      <span className="text-rose-700 font-semibold">
                        {r.pending}
                      </span>
                    ) : (
                      <span className="text-slate-400">0</span>
                    )}
                  </td>
                  <td className="px-3 py-2.5 text-right text-slate-700">
                    {r.active}
                  </td>
                  <td className="px-3 py-2.5 text-right text-slate-700">
                    {(r.revenue / 100).toLocaleString("fr-FR")} €
                  </td>
                  <td className="px-6 py-2.5 text-right font-medium text-navy-900">
                    {(r.paid / 100).toLocaleString("fr-FR")} €
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </CardBody>
      </Card>
    </section>
  );
}

function MiniKpi({
  icon: Icon,
  label,
  value,
  tone,
}: {
  icon: any;
  label: string;
  value: string | number;
  tone: "brand" | "signal";
}) {
  const toneClass =
    tone === "signal"
      ? "bg-signal-500/15 border-signal-500/30 text-signal-700"
      : "bg-brand-50 border-brand-200 text-brand-700";
  return (
    <div className="rounded-xl border border-navy-100 bg-white p-4 flex items-center gap-3">
      <div
        className={cn(
          "h-9 w-9 rounded-lg border flex items-center justify-center shrink-0",
          toneClass
        )}
      >
        <Icon className="h-4 w-4" />
      </div>
      <div>
        <div className="text-[10px] uppercase tracking-wider text-slate-500">
          {label}
        </div>
        <div className="font-display text-xl font-semibold text-navy-900">
          {value}
        </div>
      </div>
    </div>
  );
}

function Stat({
  label,
  value,
  highlight,
}: {
  label: string;
  value: number;
  highlight?: boolean;
}) {
  return (
    <div className="text-center">
      <div className="text-[9px] uppercase tracking-wider text-slate-400">
        {label}
      </div>
      <div
        className={cn(
          "mt-0.5 font-display text-base font-semibold",
          highlight ? "text-signal-700" : "text-navy-900"
        )}
      >
        {value}
      </div>
    </div>
  );
}
