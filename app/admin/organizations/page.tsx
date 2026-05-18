import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Building2,
  Plus,
  Users,
  Wallet,
  AlertTriangle,
  ChevronRight,
} from "lucide-react";
import { isStaff } from "@/lib/permissions";

export const dynamic = "force-dynamic";

const fmtEuros = (cents: number) =>
  (cents / 100).toLocaleString("fr-FR", {
    style: "currency",
    currency: "EUR",
    maximumFractionDigits: 0,
  });

const STATUS_LABEL: Record<string, string> = {
  trial: "Essai",
  active: "Active",
  suspended: "Suspendue",
  churned: "Résiliée",
};

const STATUS_TONE: Record<string, "gold" | "success" | "rose" | "slate"> = {
  trial: "gold",
  active: "success",
  suspended: "rose",
  churned: "slate",
};

export default async function AdminOrganizationsPage() {
  const supabase = createClient();
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

  const { data: dashboards } = await supabase
    .from("organization_dashboard")
    .select("*")
    .order("members_total", { ascending: false });
  const list = (dashboards ?? []) as any[];

  // Totaux globaux
  const total = list.length;
  const totalActive = list.filter((o) => o.status === "active").length;
  const totalBudget = list.reduce(
    (s, o) => s + (o.total_budget_cents ?? 0),
    0
  );
  const totalLearners = list.reduce(
    (s, o) => s + (o.learners_count ?? 0),
    0
  );

  return (
    <div className="space-y-8">
      <header className="flex items-start justify-between gap-3 flex-wrap">
        <div>
          <span className="eyebrow text-gold-700 inline-flex items-center gap-1.5">
            <Building2 className="h-3.5 w-3.5" />
            Entreprises clientes
          </span>
          <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
            Organisations
          </h1>
          <p className="mt-2 text-slate-600 max-w-2xl">
            Vue multi-tenant des entreprises clientes ayant souscrit à MFT pour
            former leurs salariés.
          </p>
        </div>
        <Link
          href="/admin/organizations/nouveau"
          className="inline-flex items-center gap-1.5 rounded-xl bg-navy-900 hover:bg-navy-800 text-white px-3.5 py-2 text-sm font-medium transition-colors"
        >
          <Plus className="h-4 w-4" />
          Nouvelle organisation
        </Link>
      </header>

      {/* KPIs */}
      <section className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
        <Kpi
          icon={Building2}
          label="Organisations"
          value={String(total)}
          hint={`${totalActive} actives`}
        />
        <Kpi
          icon={Users}
          label="Stagiaires rattachés"
          value={String(totalLearners)}
          hint="Tous statuts confondus"
        />
        <Kpi
          icon={Wallet}
          label="Budget total"
          value={fmtEuros(totalBudget)}
          hint="Engagé toutes orgas"
        />
        <Kpi
          icon={AlertTriangle}
          label="Suspendues"
          value={String(list.filter((o) => o.status === "suspended").length)}
          tone={
            list.filter((o) => o.status === "suspended").length > 0
              ? "warning"
              : "default"
          }
        />
      </section>

      {/* Liste */}
      <Card>
        <CardBody className="p-0 overflow-x-auto">
          {list.length === 0 ? (
            <div className="text-center py-12 px-5">
              <div className="mx-auto h-12 w-12 rounded-xl bg-gold-50 border border-gold-200 text-gold-700 flex items-center justify-center">
                <Building2 className="h-6 w-6" />
              </div>
              <p className="mt-4 font-medium text-navy-900">
                Aucune organisation
              </p>
              <p className="text-sm text-slate-600 mt-1 max-w-md mx-auto">
                Quand un client B2B rejoindra MFT, créez son organisation ici
                pour activer le portail entreprise (/organisation).
              </p>
              <Link
                href="/admin/organizations/nouveau"
                className="inline-flex items-center gap-1.5 rounded-xl bg-navy-900 hover:bg-navy-800 text-white px-4 py-2 mt-5 text-sm font-medium transition-colors"
              >
                <Plus className="h-4 w-4" />
                Créer la première
              </Link>
            </div>
          ) : (
            <table className="w-full text-sm">
              <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                <tr>
                  <th className="text-left px-4 py-3 font-semibold">Organisation</th>
                  <th className="text-right px-4 py-3 font-semibold">Membres</th>
                  <th className="text-right px-4 py-3 font-semibold">Stagiaires actifs</th>
                  <th className="text-right px-4 py-3 font-semibold">Budget</th>
                  <th className="text-left px-4 py-3 font-semibold">Statut</th>
                  <th className="px-3 py-3" />
                </tr>
              </thead>
              <tbody>
                {list.map((o) => (
                  <tr
                    key={o.organization_id}
                    className="border-t border-navy-50 hover:bg-navy-50/40"
                  >
                    <td className="px-4 py-3">
                      <Link
                        href={`/admin/organizations/${o.organization_id}`}
                        className="block"
                      >
                        <div className="font-medium text-navy-900 hover:text-gold-700">
                          {o.name}
                        </div>
                        <div className="text-xs text-slate-500">{o.slug}</div>
                      </Link>
                    </td>
                    <td className="px-4 py-3 text-right tabular-nums">
                      {o.members_total ?? 0}
                      <div className="text-[11px] text-slate-500">
                        {o.admins_count ?? 0} admin
                      </div>
                    </td>
                    <td className="px-4 py-3 text-right tabular-nums text-navy-900">
                      {o.enrollments_active ?? 0}
                    </td>
                    <td className="px-4 py-3 text-right">
                      <div className="font-display font-semibold tabular-nums text-navy-900">
                        {fmtEuros(o.total_budget_cents ?? 0)}
                      </div>
                      <div className="text-[11px] text-slate-500 tabular-nums">
                        {fmtEuros(o.total_paid_cents ?? 0)} payé
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <Badge tone={STATUS_TONE[o.status] ?? "slate"} size="sm">
                        {STATUS_LABEL[o.status] ?? o.status}
                      </Badge>
                    </td>
                    <td className="px-3 py-3 text-slate-400">
                      <ChevronRight className="h-4 w-4" />
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </CardBody>
      </Card>
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
  icon: any;
  label: string;
  value: string;
  hint?: string;
  tone?: "default" | "warning";
}) {
  const iconBg =
    tone === "warning"
      ? "bg-amber-50 border-amber-200 text-amber-700"
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
