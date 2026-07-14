import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Mail,
  Phone,
  Building2,
  UserPlus,
  Trash2,
  Download,
  Pencil,
} from "lucide-react";
import { deleteFunder } from "./actions";
import { ConfirmAction } from "@/components/ui/confirm-action";
import { EnrollmentsTable } from "./enrollments-table";
import { LeadsTable } from "./leads-table";

export const dynamic = "force-dynamic";

function fmtEuros(cents: number) {
  return (cents / 100).toLocaleString("fr-FR", {
    style: "currency",
    currency: "EUR",
  });
}

const EPAGE_SIZE = 25;

export default async function AdminEnrollmentsPage(
  props: {
    searchParams?: Promise<{ epage?: string; estatus?: string }>;
  }
) {
  const searchParams = await props.searchParams;
  // Client session : les RLS sont réparées (migration
  // fix_rls_org_recursion), is_admin() autorise le staff à tout lire.
  const supabase = await createClient();

  const epage = Math.max(1, Number(searchParams?.epage ?? 1) || 1);
  const estatus = (searchParams?.estatus ?? "").toString();
  const efrom = (epage - 1) * EPAGE_SIZE;
  const eto = efrom + EPAGE_SIZE - 1;

  // Tableau : requête PAGINÉE (25/page) + filtre statut optionnel — évite de
  // charger toute la table côté serveur (le défaut signalé à l'audit).
  let enrollQuery = supabase
    .from("enrollments")
    .select(
      "*, user:profiles!user_id(full_name, email), funder:funders(name, kind)",
      { count: "exact" }
    )
    .order("created_at", { ascending: false })
    .range(efrom, eto);
  if (estatus) enrollQuery = enrollQuery.eq("status", estatus);

  const [
    { data: enrollments, count: enrollCount },
    { data: funders },
    { data: overview },
    { data: requests },
    { data: aggRows },
  ] = await Promise.all([
    enrollQuery,
    supabase.from("funders").select("*").order("name"),
    supabase.from("funder_overview").select("*"),
    supabase
      .from("enrollment_requests")
      .select("*")
      .order("created_at", { ascending: false })
      .limit(30),
    // Agrégats KPI + répartition par statut : léger (3 colonnes, toutes lignes),
    // pour garder des totaux justes malgré la pagination du tableau.
    supabase
      .from("enrollments")
      .select("status, total_amount_cents, paid_amount_cents"),
  ]);

  const openReq = (requests ?? []).filter(
    (r: any) => !["inscrit", "refuse"].includes(r.status)
  );

  const agg = (aggRows ?? []) as any[];
  const totals = agg.reduce(
    (acc: any, e: any) => {
      acc.total += e.total_amount_cents ?? 0;
      acc.paid += e.paid_amount_cents ?? 0;
      return acc;
    },
    { total: 0, paid: 0 }
  );
  const enCoursCount = agg.filter((e) => e.status === "en_cours").length;

  // Répartition par statut → alimente les puces de filtre (data-driven).
  const statusCounts = new Map<string, number>();
  for (const e of agg) {
    const s = e.status ?? "—";
    statusCounts.set(s, (statusCounts.get(s) ?? 0) + 1);
  }
  const totalPages = Math.max(1, Math.ceil((enrollCount ?? 0) / EPAGE_SIZE));

  const pageHref = (p: number) =>
    `?epage=${p}${estatus ? `&estatus=${encodeURIComponent(estatus)}` : ""}`;
  const statusHref = (s: string) =>
    s ? `?estatus=${encodeURIComponent(s)}` : `?`;

  return (
    <div className="space-y-10">
      <header className="flex items-start justify-between gap-4 flex-wrap">
        <div>
          <span className="eyebrow text-gold-700">Administration</span>
          <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950">
            Inscriptions, financeurs & paiements
          </h1>
          <p className="mt-2 text-sm text-slate-600 max-w-2xl">
            Vue commerciale : leads, dossiers, paiements. Pour inscrire
            un nouveau client de A à Z (compte + dossier), cliquez sur{" "}
            <strong>+ Nouveau stagiaire</strong>.
          </p>
        </div>
        <div className="flex items-center gap-2 shrink-0">
          <Link href="/admin/users/new">
            <Button variant="gold">
              <UserPlus className="h-4 w-4" />+ Nouveau stagiaire
            </Button>
          </Link>
        </div>
      </header>

      {/* KPIs */}
      <section className="grid md:grid-cols-4 gap-4">
        <Kpi label="Dossiers actifs" value={enCoursCount} />
        <Kpi label="Demandes à traiter" value={openReq.length} />
        <Kpi label="Budget engagé" value={fmtEuros(totals.total)} />
        <Kpi label="Encaissé" value={fmtEuros(totals.paid)} accent />
      </section>

      {/* Demandes d'inscription */}
      {openReq.length > 0 && (
        <section>
          <div className="flex items-center justify-between mb-3 gap-3">
            <h2 className="eyebrow text-gold-700">Leads à contacter</h2>
            <a
              href="/api/admin/export/leads"
              className="inline-flex items-center gap-2 h-8 px-3 rounded-lg border border-navy-200 bg-white text-xs text-navy-800 hover:bg-navy-50 transition"
              title="Télécharger un CSV de tous les leads"
            >
              <Download className="h-3.5 w-3.5" /> CSV
            </a>
          </div>
          <LeadsTable requests={openReq} />
        </section>
      )}

      {/* Enrollments */}
      <section>
        <div className="flex items-center justify-between mb-4 gap-3 flex-wrap">
          <h2 className="eyebrow text-gold-700">
            Dossiers{" "}
            <span className="font-normal normal-case tracking-normal text-slate-400">
              ({enrollCount ?? 0})
            </span>
          </h2>
          <Link href="/admin/enrollments/new">
            <Button size="sm">+ Nouveau dossier</Button>
          </Link>
        </div>

        {/* Filtres par statut (pilotés par les données) */}
        <div className="mb-4 flex flex-wrap gap-1.5">
          <StatusChip href={statusHref("")} active={!estatus} label="Tous" count={agg.length} />
          {[...statusCounts.entries()]
            .sort((a, b) => b[1] - a[1])
            .map(([s, n]) => (
              <StatusChip
                key={s}
                href={statusHref(s)}
                active={estatus === s}
                label={s}
                count={n}
              />
            ))}
        </div>

        <EnrollmentsTable enrollments={enrollments ?? []} />

        {/* Pagination serveur */}
        {totalPages > 1 && (
          <div className="mt-4 flex items-center justify-between gap-3 text-sm">
            <span className="text-slate-500">
              Page {epage} / {totalPages}
            </span>
            <div className="flex items-center gap-2">
              {epage > 1 && (
                <Link href={pageHref(epage - 1)}>
                  <Button size="sm" variant="secondary">
                    Précédent
                  </Button>
                </Link>
              )}
              {epage < totalPages && (
                <Link href={pageHref(epage + 1)}>
                  <Button size="sm" variant="secondary">
                    Suivant
                  </Button>
                </Link>
              )}
            </div>
          </div>
        )}
      </section>

      {/* Funders */}
      <section>
        <div className="flex items-center justify-between mb-4">
          <h2 className="eyebrow text-gold-700">Financeurs</h2>
          <Link href="/admin/enrollments/funders/new">
            <Button size="sm">+ Nouveau financeur</Button>
          </Link>
        </div>
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
          {(funders ?? []).map((f: any) => {
            const ov = (overview ?? []).find((o: any) => o.funder_id === f.id);
            return (
              <Card key={f.id}>
                <CardBody>
                  <div className="flex items-start justify-between gap-3">
                    <div className="flex items-center gap-2">
                      <Building2 className="h-4 w-4 text-gold-600" />
                      <CardTitle className="text-base">{f.name}</CardTitle>
                    </div>
                    <Badge size="sm">{f.kind}</Badge>
                  </div>
                  {f.contact_email && (
                    <p className="text-xs text-slate-600 mt-2 truncate">
                      {f.contact_email}
                    </p>
                  )}
                  <div className="mt-4 grid grid-cols-2 gap-3 text-xs">
                    <div>
                      <div className="text-slate-500">Dossiers</div>
                      <div className="font-semibold text-navy-900">
                        {ov?.enrollments_total ?? 0}
                      </div>
                    </div>
                    <div>
                      <div className="text-slate-500">Budget</div>
                      <div className="font-semibold text-navy-900">
                        {fmtEuros(ov?.budget_total_cents ?? 0)}
                      </div>
                    </div>
                  </div>
                  <div className="mt-4 flex items-center justify-end gap-1">
                    {f.contact_email && (
                      <a
                        href={`mailto:${f.contact_email}`}
                        title={`Email — ${f.contact_email}`}
                        aria-label={`Email — ${f.contact_email}`}
                        className="inline-flex h-7 w-7 items-center justify-center rounded-lg border border-navy-200 text-navy-800 hover:bg-navy-50 transition"
                      >
                        <Mail className="h-3.5 w-3.5" />
                      </a>
                    )}
                    {f.contact_phone && (
                      <a
                        href={`tel:${f.contact_phone}`}
                        title={`Appeler — ${f.contact_phone}`}
                        aria-label={`Appeler — ${f.contact_phone}`}
                        className="inline-flex h-7 w-7 items-center justify-center rounded-lg border border-navy-200 text-navy-800 hover:bg-navy-50 transition"
                      >
                        <Phone className="h-3.5 w-3.5" />
                      </a>
                    )}
                    <Link
                      href={`/admin/enrollments/funders/${f.id}`}
                      title="Modifier"
                      aria-label="Modifier le financeur"
                      className="inline-flex h-7 w-7 items-center justify-center rounded-lg border border-gold-200 text-gold-800 hover:bg-gold-50 transition"
                    >
                      <Pencil className="h-3.5 w-3.5" />
                    </Link>
                    <ConfirmAction
                      action={deleteFunder.bind(null, f.id)}
                      title="Supprimer ce financeur ?"
                      description={`Supprime « ${f.name} ». Les dossiers existants rattachés à ce financeur seront détachés (pas supprimés).`}
                      confirmLabel="Supprimer"
                      successMsg="Financeur supprimé"
                      iconLabel="Supprimer le financeur"
                      icon={<Trash2 className="h-3.5 w-3.5" />}
                      tone="rose"
                      variant="solid"
                    />
                  </div>
                </CardBody>
              </Card>
            );
          })}
        </div>
      </section>
    </div>
  );
}

function Kpi({
  label,
  value,
  accent,
}: {
  label: string;
  value: any;
  accent?: boolean;
}) {
  return (
    <div
      className={`rounded-2xl border p-5 ${
        accent
          ? "bg-gold-50 border-gold-200"
          : "bg-white border-navy-100"
      }`}
    >
      <div className="text-xs uppercase tracking-wider text-slate-500">{label}</div>
      <div className="mt-1 font-display text-2xl font-semibold text-navy-900">
        {value}
      </div>
    </div>
  );
}

function StatusChip({
  href,
  active,
  label,
  count,
}: {
  href: string;
  active: boolean;
  label: string;
  count: number;
}) {
  return (
    <Link
      href={href}
      className={`inline-flex items-center gap-1.5 rounded-full border px-3 py-1 text-xs font-medium transition-colors ${
        active
          ? "border-navy-900 bg-navy-900 text-white"
          : "border-navy-200 bg-white text-navy-700 hover:border-navy-400 hover:bg-navy-50"
      }`}
    >
      {label}
      <span
        className={`tabular-nums ${active ? "text-white/70" : "text-slate-400"}`}
      >
        {count}
      </span>
    </Link>
  );
}
