import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  GraduationCap,
  Hourglass,
  ArrowLeft,
  Award,
  AlertCircle,
} from "lucide-react";
import { getOrganizationAccess } from "@/lib/organization/access";

export const dynamic = "force-dynamic";

const fmtEuros = (cents: number) =>
  (cents / 100).toLocaleString("fr-FR", {
    style: "currency",
    currency: "EUR",
    maximumFractionDigits: 0,
  });

const STATUS_LABEL: Record<string, string> = {
  prospect: "Prospect",
  devis: "Devis envoyé",
  accord_financeur: "Accord financeur",
  a_payer: "À payer",
  en_cours: "En cours",
  termine: "Terminée",
};

export default async function OrganisationStagiairesPage() {
  const access = await getOrganizationAccess();
  if (!access.allowed) {
    if (access.reason === "unauthenticated") redirect("/login");
    redirect("/organisation");
  }
  if (!access.is_org_viewer) redirect("/organisation");
  if (!access.organization_id) redirect("/admin/organizations");

  const supabase = createClient();

  const { data: enrollments } = await supabase
    .from("enrollments")
    .select(`
      id, status, pack, created_at, seats_reserved,
      total_amount_cents, paid_amount_cents,
      user:profiles!user_id ( id, full_name, email ),
      formation:formations ( title, code, slug )
    `)
    .eq("organization_id", access.organization_id)
    .order("created_at", { ascending: false });

  const list = (enrollments ?? []) as any[];

  return (
    <div className="space-y-8">
      <div>
        <Link
          href="/organisation"
          className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
        >
          <ArrowLeft className="h-4 w-4" /> Tableau de bord
        </Link>
      </div>

      <header>
        <span className="eyebrow text-gold-700 inline-flex items-center gap-1.5">
          <GraduationCap className="h-3.5 w-3.5" />
          Stagiaires
        </span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Mes stagiaires
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          {list.length} inscription{list.length > 1 ? "s" : ""} active{list.length > 1 ? "s" : ""}{" "}
          dans {access.organization_name}.
        </p>
      </header>

      <Card>
        <CardBody className="p-0 overflow-x-auto">
          {list.length === 0 ? (
            <div className="text-center py-12 px-5">
              <div className="mx-auto h-12 w-12 rounded-xl bg-gold-50 border border-gold-200 text-gold-700 flex items-center justify-center">
                <GraduationCap className="h-6 w-6" />
              </div>
              <p className="mt-4 font-medium text-navy-900">
                Aucun stagiaire inscrit
              </p>
              <p className="text-sm text-slate-600 mt-1 max-w-md mx-auto">
                Aucune inscription n'a encore été faite pour votre organisation.
                Contactez l'équipe MFT pour planifier vos premières formations.
              </p>
            </div>
          ) : (
            <table className="w-full text-sm">
              <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                <tr>
                  <th className="text-left px-4 py-3 font-semibold">Stagiaire</th>
                  <th className="text-left px-4 py-3 font-semibold">Formation</th>
                  <th className="text-left px-4 py-3 font-semibold">Pack</th>
                  <th className="text-right px-4 py-3 font-semibold">Montant</th>
                  <th className="text-left px-4 py-3 font-semibold">Statut</th>
                </tr>
              </thead>
              <tbody>
                {list.map((e) => (
                  <tr key={e.id} className="border-t border-navy-50">
                    <td className="px-4 py-3">
                      {e.seats_reserved ? (
                        <div className="inline-flex items-center gap-1.5 text-slate-500">
                          <Hourglass className="h-3.5 w-3.5" />
                          Place en attente
                        </div>
                      ) : (
                        <div>
                          <div className="font-medium text-navy-900">
                            {e.user?.full_name ?? e.user?.email?.split("@")[0]}
                          </div>
                          <div className="text-xs text-slate-500">
                            {e.user?.email}
                          </div>
                        </div>
                      )}
                    </td>
                    <td className="px-4 py-3">
                      <div className="text-navy-900">{e.formation?.title}</div>
                      <div className="text-xs text-slate-500">
                        {e.formation?.code}
                      </div>
                    </td>
                    <td className="px-4 py-3 text-navy-900 capitalize">
                      {e.pack}
                    </td>
                    <td className="px-4 py-3 text-right">
                      <div className="font-display font-semibold tabular-nums text-navy-900">
                        {fmtEuros(e.total_amount_cents ?? 0)}
                      </div>
                      <div className="text-[11px] text-slate-500 tabular-nums">
                        {fmtEuros(e.paid_amount_cents ?? 0)} payé
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <Badge tone="navy" size="sm">
                        {STATUS_LABEL[e.status] ?? e.status}
                      </Badge>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </CardBody>
      </Card>

      <p className="text-[11px] text-slate-500">
        <AlertCircle className="h-3 w-3 inline -mt-0.5 mr-1" />
        La progression pédagogique détaillée (leçons, scores) sera disponible
        prochainement. Pour l'instant, consultez l'historique des inscriptions
        et leur statut.
      </p>
    </div>
  );
}
