import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Building2, Users, Wallet, TrendingUp, CheckCircle2, ChevronRight } from "lucide-react";

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

export default async function FinanceurPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  // Le financeur ne voit que ses propres données (RLS)
  const [{ data: funders }, { data: enrollments }, { data: overview }] =
    await Promise.all([
      supabase
        .from("funders")
        .select("*")
        .eq("portal_user_id", user.id),
      supabase
        .from("enrollments")
        .select(
          "*, user:profiles!enrollments_user_id_fkey(full_name, email), funder:funders(name)"
        )
        .order("created_at", { ascending: false }),
      supabase.from("funder_overview").select("*").eq("portal_user_id", user.id),
    ]);

  if (!funders || funders.length === 0) {
    return (
      <div className="space-y-6">
        <header>
          <span className="eyebrow text-gold-700">Espace financeur</span>
          <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950">
            Bienvenue
          </h1>
        </header>
        <Card>
          <CardBody className="text-sm text-slate-600">
            Aucun compte financeur n'est associé à votre utilisateur. Contactez
            l'administration pour être rattaché à une entité.
          </CardBody>
        </Card>
      </div>
    );
  }

  const totalBudget = (overview ?? []).reduce(
    (s: number, o: any) => s + (o.budget_total_cents ?? 0),
    0
  );
  const totalPaid = (overview ?? []).reduce(
    (s: number, o: any) => s + (o.budget_paid_cents ?? 0),
    0
  );
  const totalStagiaires = (overview ?? []).reduce(
    (s: number, o: any) => s + (o.enrollments_total ?? 0),
    0
  );

  return (
    <div className="space-y-10">
      <header>
        <span className="eyebrow text-gold-700">Espace financeur</span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          {funders.map((f: any) => f.name).join(" · ")}
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Suivi en lecture des dossiers que vous financez.
        </p>
      </header>

      <section className="grid md:grid-cols-4 gap-4">
        <Kpi icon={Users} label="Stagiaires" value={totalStagiaires} />
        <Kpi icon={TrendingUp} label="En cours" value={(overview ?? []).reduce((s:number,o:any)=>s+(o.enrollments_active??0),0)} />
        <Kpi icon={Wallet} label="Budget engagé" value={fmtEuros(totalBudget)} />
        <Kpi icon={Building2} label="Encaissé" value={fmtEuros(totalPaid)} accent />
      </section>

      <section>
        <h2 className="eyebrow text-gold-700 mb-3">Dossiers financés</h2>
        <Card>
          <CardBody className="p-0 overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                <tr>
                  <th className="text-left px-4 py-3">Stagiaire</th>
                  <th className="text-left px-4 py-3">Session</th>
                  <th className="text-right px-4 py-3">Montant</th>
                  <th className="text-right px-4 py-3">Payé</th>
                  <th className="text-left px-4 py-3">Statut</th>
                  <th className="px-3 py-3" aria-label="Détail" />
                </tr>
              </thead>
              <tbody>
                {(enrollments ?? []).map((e: any) => (
                  <tr
                    key={e.id}
                    className="border-t border-navy-50 hover:bg-navy-50/40 cursor-pointer"
                  >
                    <td className="px-4 py-3">
                      <Link
                        href={`/financeur/${e.id}`}
                        className="font-medium text-navy-900 hover:text-gold-700"
                      >
                        {e.user?.full_name ?? e.user?.email}
                      </Link>
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
                      <div className="flex items-center gap-2">
                        <Badge tone={STATUS_TONE[e.status] ?? "slate"} size="sm">
                          {e.status}
                        </Badge>
                        {e.funder_signed_at && (
                          <Badge tone="success" size="sm">
                            <CheckCircle2 className="h-3 w-3" /> Signé
                          </Badge>
                        )}
                      </div>
                    </td>
                    <td className="px-3 py-3 text-slate-400">
                      <ChevronRight className="h-4 w-4" />
                    </td>
                  </tr>
                ))}
                {(!enrollments || enrollments.length === 0) && (
                  <tr>
                    <td colSpan={6} className="px-4 py-6 text-sm text-slate-500">
                      Aucun dossier pour l'instant.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </CardBody>
        </Card>
      </section>
    </div>
  );
}

function Kpi({
  icon: Icon,
  label,
  value,
  accent,
}: {
  icon: any;
  label: string;
  value: any;
  accent?: boolean;
}) {
  return (
    <div
      className={`rounded-2xl border p-5 ${
        accent ? "bg-gold-50 border-gold-200" : "bg-white border-navy-100"
      }`}
    >
      <div className="flex items-center gap-2 text-xs uppercase tracking-wider text-slate-500">
        <Icon className="h-3.5 w-3.5" /> {label}
      </div>
      <div className="mt-1 font-display text-2xl font-semibold text-navy-900">
        {value}
      </div>
    </div>
  );
}
