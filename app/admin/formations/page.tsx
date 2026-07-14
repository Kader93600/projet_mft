import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  TrendingUp,
  Users,
  Clock,
  FileText,
  ArrowRight,
  ExternalLink,
  Sparkles,
} from "lucide-react";
import { FORMATIONS, findFormation } from "@/lib/formations-config";
import { accentVars } from "@/lib/formation-accent";
import { LEGAL } from "@/lib/legal-config";

export const dynamic = "force-dynamic";

export default async function AdminFormationsPage() {
  const supabase = await createClient();

  // Demandes agrégées (vue formations_demand)
  const [{ data: demand }, { data: enrollByFormation }] = await Promise.all([
    supabase.from("formations_demand").select("*"),
    supabase
      .from("enrollments")
      .select("formation_slug, status")
      .not("formation_slug", "is", null),
  ]);

  // Indexer la demande par slug
  const demandByFormation = new Map<string, any>();
  (demand ?? []).forEach((row: any) => {
    demandByFormation.set(row.formation_slug, row);
  });

  // Agréger les inscriptions confirmées par slug
  const enrollmentsBySlug = new Map<
    string,
    { total: number; en_cours: number; termine: number }
  >();
  (enrollByFormation ?? []).forEach((row: any) => {
    const slug = row.formation_slug ?? "unspecified";
    const acc =
      enrollmentsBySlug.get(slug) ??
      ({ total: 0, en_cours: 0, termine: 0 } as any);
    acc.total++;
    if (row.status === "en_cours") acc.en_cours++;
    if (row.status === "termine") acc.termine++;
    enrollmentsBySlug.set(slug, acc);
  });

  // Calcul des totaux
  const totalDemand = (demand ?? []).reduce(
    (s: number, r: any) => s + (r.requests ?? 0),
    0
  );
  const totalDemand30d = (demand ?? []).reduce(
    (s: number, r: any) => s + (r.requests_30d ?? 0),
    0
  );
  const totalEnrolled = Array.from(enrollmentsBySlug.values()).reduce(
    (s, v) => s + v.total,
    0
  );
  const totalActive = Array.from(enrollmentsBySlug.values()).reduce(
    (s, v) => s + v.en_cours,
    0
  );

  // Tableau combiné catalogue + métriques
  const rows = FORMATIONS.map((f) => {
    const d = demandByFormation.get(f.slug);
    const e = enrollmentsBySlug.get(f.slug);
    return {
      formation: f,
      requests: d?.requests ?? 0,
      requests_30d: d?.requests_30d ?? 0,
      pending: d?.pending ?? 0,
      enrolled: e?.total ?? 0,
      active: e?.en_cours ?? 0,
      completed: e?.termine ?? 0,
    };
  }).sort((a, b) => b.requests_30d - a.requests_30d);

  // Demandes "unspecified" (legacy)
  const unspecified =
    demandByFormation.get("unspecified") ?? { requests: 0, requests_30d: 0 };

  return (
    <div className="space-y-10">
      <header>
        <span className="eyebrow text-gold-700">Pilotage produit</span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Catalogue formations
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Vue d'ensemble des {FORMATIONS.length} formations du catalogue,
          avec demandes prospects et inscriptions confirmées.
        </p>
      </header>

      {/* KPIs globaux */}
      <section className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <Kpi
          icon={FileText}
          label="Demandes (total)"
          value={totalDemand}
          tone="navy"
        />
        <Kpi
          icon={TrendingUp}
          label="Demandes (30 j)"
          value={totalDemand30d}
          tone="gold"
        />
        <Kpi
          icon={Users}
          label="Inscriptions confirmées"
          value={totalEnrolled}
          tone="navy"
        />
        <Kpi
          icon={Clock}
          label="Stagiaires actifs"
          value={totalActive}
          tone="success"
        />
      </section>

      {/* Tableau catalogue */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4">
          Performance par formation
        </h2>
        <Card>
          <CardBody className="p-0 overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                <tr>
                  <th className="text-left px-6 py-3">Formation</th>
                  <th className="text-right px-3 py-3">Demandes 30 j</th>
                  <th className="text-right px-3 py-3">Demandes total</th>
                  <th className="text-right px-3 py-3">En attente</th>
                  <th className="text-right px-3 py-3">Inscrits</th>
                  <th className="text-right px-3 py-3">Actifs</th>
                  <th className="text-right px-3 py-3">Terminés</th>
                  <th className="text-right px-6 py-3"></th>
                </tr>
              </thead>
              <tbody>
                {rows.map((r) => (
                  <tr
                    key={r.formation.slug}
                    className="border-t border-navy-50 hover:bg-navy-50/40"
                  >
                    <td className="px-6 py-3">
                      <div className="flex items-center gap-2">
                        <div
                          className="formation-accent h-7 w-7 rounded-lg border flex items-center justify-center text-[10px] font-bold"
                          style={accentVars(r.formation.accent)}
                        >
                          {r.formation.code.slice(0, 2)}
                        </div>
                        <div>
                          <div className="font-medium text-navy-900">
                            {r.formation.code}
                          </div>
                          <div className="text-xs text-slate-500 max-w-[280px] truncate">
                            {r.formation.title}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="px-3 py-3 text-right">
                      {r.requests_30d > 0 ? (
                        <Badge tone="gold" size="sm">
                          <Sparkles className="h-3 w-3" />
                          {r.requests_30d}
                        </Badge>
                      ) : (
                        <span className="text-slate-400">0</span>
                      )}
                    </td>
                    <td className="px-3 py-3 text-right text-slate-700">
                      {r.requests}
                    </td>
                    <td className="px-3 py-3 text-right">
                      {r.pending > 0 ? (
                        <span className="font-semibold text-rose-700">
                          {r.pending}
                        </span>
                      ) : (
                        <span className="text-slate-400">0</span>
                      )}
                    </td>
                    <td className="px-3 py-3 text-right font-medium text-navy-900">
                      {r.enrolled}
                    </td>
                    <td className="px-3 py-3 text-right text-slate-700">
                      {r.active}
                    </td>
                    <td className="px-3 py-3 text-right text-slate-700">
                      {r.completed}
                    </td>
                    <td className="px-6 py-3 text-right">
                      <div className="inline-flex items-center gap-3">
                        <Link
                          href={`/admin/enrollments?formation=${r.formation.slug}`}
                          className="text-xs text-navy-700 hover:text-brand-700 font-medium"
                          aria-label="Gérer les inscriptions de cette formation"
                        >
                          Inscriptions
                        </Link>
                        <a
                          href={`/formations/${r.formation.slug}`}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="inline-flex items-center gap-1 text-xs text-slate-500 hover:text-navy-900"
                          aria-label="Voir la page publique de la formation"
                          title="Page publique"
                        >
                          <ExternalLink className="h-3.5 w-3.5" />
                        </a>
                      </div>
                    </td>
                  </tr>
                ))}
                {unspecified.requests > 0 && (
                  <tr className="border-t border-navy-50 bg-amber-50/30">
                    <td className="px-6 py-3">
                      <div className="font-medium text-amber-900">
                        — Sans formation spécifiée —
                      </div>
                      <div className="text-xs text-amber-700">
                        Demandes legacy à rattacher manuellement
                      </div>
                    </td>
                    <td className="px-3 py-3 text-right text-slate-700">
                      {unspecified.requests_30d}
                    </td>
                    <td className="px-3 py-3 text-right text-slate-700">
                      {unspecified.requests}
                    </td>
                    <td className="px-3 py-3 text-right text-slate-400" colSpan={5}>
                      —
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </CardBody>
        </Card>
      </section>

      {/* Top demandes en attente */}
      {rows.some((r) => r.pending > 0) && (
        <section>
          <h2 className="font-display text-xl font-semibold text-navy-900 mb-4">
            À traiter en priorité
          </h2>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-3">
            {rows
              .filter((r) => r.pending > 0)
              .map((r) => (
                <Link
                  key={r.formation.slug}
                  href={`/admin/enrollments?formation=${r.formation.slug}`}
                  className="rounded-xl border border-rose-200 bg-rose-50 hover:bg-rose-100 transition p-4 flex items-start justify-between gap-3"
                >
                  <div>
                    <div className="text-[10px] font-semibold uppercase tracking-wider text-rose-700">
                      {r.formation.code}
                    </div>
                    <div className="font-medium text-rose-900 mt-0.5">
                      {r.pending} demande{r.pending > 1 ? "s" : ""} en attente
                    </div>
                    <div className="text-xs text-rose-700/80 mt-1 truncate max-w-[280px]">
                      {r.formation.title}
                    </div>
                  </div>
                  <ArrowRight className="h-4 w-4 text-rose-700 mt-1 shrink-0" />
                </Link>
              ))}
          </div>
        </section>
      )}
    </div>
  );
}

function Kpi({
  icon: Icon,
  label,
  value,
  tone = "navy",
}: {
  icon: any;
  label: string;
  value: number;
  tone?: "navy" | "gold" | "success";
}) {
  const toneClass =
    tone === "gold"
      ? "bg-gold-50 text-gold-800 border-gold-200"
      : tone === "success"
      ? "bg-emerald-50 text-emerald-800 border-emerald-200"
      : "bg-navy-50 text-navy-900 border-navy-100";
  return (
    <Card>
      <CardBody>
        <div className="flex items-center justify-between gap-3">
          <div>
            <div className="text-xs uppercase tracking-wider text-slate-500">
              {label}
            </div>
            <div className="mt-1 font-display text-3xl font-semibold text-navy-900">
              {value}
            </div>
          </div>
          <div
            className={
              "h-10 w-10 rounded-xl border flex items-center justify-center " +
              toneClass
            }
          >
            <Icon className="h-5 w-5" />
          </div>
        </div>
      </CardBody>
    </Card>
  );
}
