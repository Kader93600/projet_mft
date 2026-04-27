import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Briefcase,
  CreditCard,
  Mail,
  Phone,
  Building2,
  ExternalLink,
} from "lucide-react";
import { deleteFunder, deleteEnrollment } from "./actions";

export const dynamic = "force-dynamic";

const STATUS_TONE: Record<string, "gold" | "navy" | "success" | "slate" | "rose"> = {
  prospect: "slate",
  devis: "gold",
  accord_financeur: "gold",
  a_payer: "gold",
  en_cours: "navy",
  termine: "success",
  abandon: "slate",
  refuse: "rose",
};

function fmtEuros(cents: number) {
  return (cents / 100).toLocaleString("fr-FR", {
    style: "currency",
    currency: "EUR",
  });
}

export default async function AdminEnrollmentsPage() {
  const supabase = createClient();
  const [
    { data: enrollments },
    { data: funders },
    { data: overview },
    { data: requests },
  ] = await Promise.all([
    supabase
      .from("enrollments")
      .select(
        "*, user:profiles!enrollments_user_id_fkey(full_name, email), funder:funders(name, kind)"
      )
      .order("created_at", { ascending: false }),
    supabase.from("funders").select("*").order("name"),
    supabase.from("funder_overview").select("*"),
    supabase
      .from("enrollment_requests")
      .select("*")
      .order("created_at", { ascending: false })
      .limit(30),
  ]);

  const openReq = (requests ?? []).filter(
    (r: any) => !["inscrit", "refuse"].includes(r.status)
  );

  const totals = (enrollments ?? []).reduce(
    (acc: any, e: any) => {
      acc.total += e.total_amount_cents ?? 0;
      acc.paid += e.paid_amount_cents ?? 0;
      return acc;
    },
    { total: 0, paid: 0 }
  );

  return (
    <div className="space-y-10">
      <header>
        <span className="eyebrow text-gold-700">Administration</span>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950">
          Inscriptions, financeurs & paiements
        </h1>
      </header>

      {/* KPIs */}
      <section className="grid md:grid-cols-4 gap-4">
        <Kpi label="Dossiers actifs" value={(enrollments ?? []).filter((e: any) => e.status === "en_cours").length} />
        <Kpi label="Demandes à traiter" value={openReq.length} />
        <Kpi label="Budget engagé" value={fmtEuros(totals.total)} />
        <Kpi label="Encaissé" value={fmtEuros(totals.paid)} accent />
      </section>

      {/* Demandes d'inscription */}
      {openReq.length > 0 && (
        <section>
          <h2 className="eyebrow text-gold-700 mb-3">Leads à contacter</h2>
          <Card>
            <CardBody className="p-0 overflow-x-auto">
              <table className="w-full text-sm">
                <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                  <tr>
                    <th className="text-left px-4 py-3">Contact</th>
                    <th className="text-left px-4 py-3">Financement</th>
                    <th className="text-left px-4 py-3">Statut</th>
                    <th className="text-left px-4 py-3">Reçue le</th>
                  </tr>
                </thead>
                <tbody>
                  {openReq.map((r: any) => (
                    <tr key={r.id} className="border-t border-navy-50">
                      <td className="px-4 py-3">
                        <div className="font-medium text-navy-900">{r.full_name}</div>
                        <div className="text-xs text-slate-500 flex items-center gap-2">
                          <Mail className="h-3 w-3" />
                          <a href={`mailto:${r.email}`} className="hover:text-navy-900">
                            {r.email}
                          </a>
                          {r.phone && (
                            <>
                              <Phone className="h-3 w-3 ml-2" />
                              {r.phone}
                            </>
                          )}
                        </div>
                      </td>
                      <td className="px-4 py-3">{r.funding_kind}</td>
                      <td className="px-4 py-3">
                        <Badge size="sm">{r.status}</Badge>
                      </td>
                      <td className="px-4 py-3 text-slate-500">
                        {new Date(r.created_at).toLocaleDateString("fr-FR")}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </CardBody>
          </Card>
        </section>
      )}

      {/* Enrollments */}
      <section>
        <div className="flex items-center justify-between mb-4">
          <h2 className="eyebrow text-gold-700">Dossiers</h2>
          <Link href="/admin/enrollments/new">
            <Button size="sm">+ Nouveau dossier</Button>
          </Link>
        </div>
        <Card>
          <CardBody className="p-0 overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                <tr>
                  <th className="text-left px-4 py-3">Stagiaire</th>
                  <th className="text-left px-4 py-3">Financeur</th>
                  <th className="text-left px-4 py-3">Session</th>
                  <th className="text-right px-4 py-3">Montant</th>
                  <th className="text-right px-4 py-3">Payé</th>
                  <th className="text-left px-4 py-3">Statut</th>
                  <th className="text-right px-4 py-3"></th>
                </tr>
              </thead>
              <tbody>
                {(enrollments ?? []).map((e: any) => (
                  <tr key={e.id} className="border-t border-navy-50">
                    <td className="px-4 py-3">
                      <div className="font-medium text-navy-900">
                        {e.user?.full_name ?? e.user?.email}
                      </div>
                      <div className="text-xs text-slate-500">{e.user?.email}</div>
                    </td>
                    <td className="px-4 py-3 text-slate-700">
                      {e.funder?.name ?? e.funding_kind}
                    </td>
                    <td className="px-4 py-3 text-slate-600">
                      {e.session_label ?? "—"}
                      <div className="text-xs text-slate-400">
                        {e.start_date ?? "—"} → {e.end_date ?? "—"}
                      </div>
                    </td>
                    <td className="px-4 py-3 text-right font-medium">
                      {fmtEuros(e.total_amount_cents)}
                    </td>
                    <td className="px-4 py-3 text-right">
                      {fmtEuros(e.paid_amount_cents)}
                    </td>
                    <td className="px-4 py-3">
                      <Badge tone={STATUS_TONE[e.status] ?? "slate"} size="sm">
                        {e.status}
                      </Badge>
                    </td>
                    <td className="px-4 py-3 text-right">
                      <Link
                        href={`/admin/enrollments/${e.id}`}
                        className="text-sm font-medium text-navy-900 hover:text-gold-700 inline-flex items-center gap-1"
                      >
                        Gérer <ExternalLink className="h-3 w-3" />
                      </Link>
                    </td>
                  </tr>
                ))}
                {(!enrollments || enrollments.length === 0) && (
                  <tr>
                    <td colSpan={7} className="px-4 py-6 text-sm text-slate-500">
                      Aucun dossier enregistré.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </CardBody>
        </Card>
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
                  <div className="mt-4 flex items-center gap-2">
                    <Link
                      href={`/admin/enrollments/funders/${f.id}`}
                      className="text-xs font-medium text-navy-900 hover:text-gold-700"
                    >
                      Modifier
                    </Link>
                    <form action={deleteFunder.bind(null, f.id)}>
                      <button
                        type="submit"
                        className="text-xs font-medium text-rose-700 hover:underline"
                      >
                        Supprimer
                      </button>
                    </form>
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
