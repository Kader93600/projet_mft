import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Store,
  AlertTriangle,
  CheckCircle2,
  XCircle,
  Clock,
  Wallet,
  ExternalLink,
} from "lucide-react";
import { isStaff } from "@/lib/permissions";

export const dynamic = "force-dynamic";

const STATUS_LABEL: Record<string, string> = {
  draft: "Brouillon",
  pending_review: "En attente",
  approved: "Publié",
  rejected: "Refusé",
};

const STATUS_TONE: Record<string, "slate" | "gold" | "success" | "rose"> = {
  draft: "slate",
  pending_review: "gold",
  approved: "success",
  rejected: "rose",
};

const fmtEuros = (cents: number) =>
  (cents / 100).toLocaleString("fr-FR", {
    style: "currency",
    currency: "EUR",
    maximumFractionDigits: 0,
  });

export default async function AdminMarketplacePage() {
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

  // Modules marketplace (formateurs externes)
  const { data: modulesRaw } = await supabase
    .from("modules")
    .select(`
      id, title, slug, marketplace_status, marketplace_price_cents,
      marketplace_published_at, created_at,
      creator:profiles!modules_created_by_fkey ( full_name, email )
    `)
    .not("created_by", "is", null)
    .order("created_at", { ascending: false });
  const modules = (modulesRaw ?? []) as any[];

  // Trainers avec compte payout
  const { data: trainersRaw } = await supabase
    .from("trainer_payouts")
    .select(`
      user_id, kyc_status, stripe_onboarding_complete,
      stripe_charges_enabled, revenue_share_pct,
      trainer:profiles!trainer_payouts_user_id_fkey ( full_name, email )
    `);
  const trainers = (trainersRaw ?? []) as any[];

  // Revenus
  const { data: revenueSummary } = await supabase
    .from("trainer_revenue_summary")
    .select("*")
    .order("trainer_share_total_cents", { ascending: false })
    .limit(10);

  return (
    <div className="space-y-8">
      <header>
        <span className="eyebrow text-gold-700 inline-flex items-center gap-1.5">
          <Store className="h-3.5 w-3.5" />
          Marketplace formateurs
        </span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Modules de formateurs externes
        </h1>
        <p className="mt-2 text-slate-600 max-w-3xl">
          Espace de gestion des modules créés par des formateurs externes
          partenaires. Validation des contenus, suivi des reversements.
        </p>
      </header>

      {/* Bandeau alerte v1 */}
      <Card className="border-amber-300 bg-amber-50">
        <CardBody className="flex items-start gap-3">
          <AlertTriangle className="h-5 w-5 text-amber-700 shrink-0 mt-0.5" />
          <div className="text-sm text-amber-900 space-y-2">
            <p className="font-medium">Feature en cours de configuration</p>
            <p>
              La marketplace nécessite encore l'activation de Stripe Connect,
              la rédaction des CGU partenaires (droits d'auteur + fiscalité),
              et le branchement du workflow de modération. Consulte la roadmap
              détaillée :{" "}
              <Link
                href="https://github.com/Kader93600/projet_mft/blob/main/docs/p3-2-marketplace-roadmap.md"
                className="underline inline-flex items-center gap-0.5"
                target="_blank"
              >
                docs/p3-2-marketplace-roadmap.md
                <ExternalLink className="h-3 w-3" />
              </Link>
              . Les tables DB et les UI minimum sont en place pour préparer le
              terrain.
            </p>
          </div>
        </CardBody>
      </Card>

      {/* KPIs */}
      <section className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
        <Kpi
          icon={Store}
          label="Modules marketplace"
          value={String(modules.length)}
          hint={`${modules.filter((m) => m.marketplace_status === "approved").length} publiés`}
        />
        <Kpi
          icon={Clock}
          label="En attente de validation"
          value={String(
            modules.filter((m) => m.marketplace_status === "pending_review").length
          )}
          hint="Action admin requise"
          tone={
            modules.filter((m) => m.marketplace_status === "pending_review").length > 0
              ? "warning"
              : "default"
          }
        />
        <Kpi
          icon={CheckCircle2}
          label="Formateurs partenaires"
          value={String(trainers.length)}
          hint={`${trainers.filter((t) => t.stripe_charges_enabled).length} avec KYC validé`}
        />
        <Kpi
          icon={Wallet}
          label="Reversé total"
          value={fmtEuros(
            (revenueSummary ?? []).reduce(
              (s: number, r: any) => s + (r.paid_to_trainer_cents ?? 0),
              0
            )
          )}
        />
      </section>

      {/* File d'attente modules */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 inline-flex items-center gap-2">
          <Clock className="h-5 w-5 text-gold-700" />
          File d'attente de validation
        </h2>
        <Card>
          <CardBody className="p-0">
            {modules.length === 0 ? (
              <div className="text-center py-10 px-5">
                <div className="mx-auto h-12 w-12 rounded-xl bg-gold-50 border border-gold-200 text-gold-700 flex items-center justify-center">
                  <Store className="h-6 w-6" />
                </div>
                <p className="mt-4 font-medium text-navy-900">
                  Aucun module marketplace
                </p>
                <p className="text-sm text-slate-600 mt-1 max-w-md mx-auto">
                  Quand un formateur externe créera son premier module, il
                  apparaîtra ici en attente de validation.
                </p>
              </div>
            ) : (
              <ul className="divide-y divide-navy-50">
                {modules.map((m) => (
                  <li
                    key={m.id}
                    className="px-5 py-3 flex items-center justify-between gap-3"
                  >
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center gap-2 flex-wrap mb-1">
                        <span className="font-medium text-navy-900">
                          {m.title}
                        </span>
                        <Badge
                          tone={STATUS_TONE[m.marketplace_status] ?? "slate"}
                          size="sm"
                        >
                          {STATUS_LABEL[m.marketplace_status] ?? m.marketplace_status}
                        </Badge>
                      </div>
                      <div className="text-xs text-slate-500">
                        Par{" "}
                        {m.creator?.full_name ??
                          m.creator?.email?.split("@")[0] ??
                          "—"}
                        {" · "}
                        {m.marketplace_price_cents != null
                          ? fmtEuros(m.marketplace_price_cents)
                          : "Prix non défini"}
                      </div>
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </CardBody>
        </Card>
      </section>

      {/* Trainers partenaires */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 inline-flex items-center gap-2">
          <CheckCircle2 className="h-5 w-5 text-gold-700" />
          Formateurs partenaires
        </h2>
        <Card>
          <CardBody className="p-0">
            {trainers.length === 0 ? (
              <div className="text-center py-10 px-5">
                <p className="text-sm text-slate-500">
                  Aucun formateur n'a encore activé son compte de reversement.
                </p>
              </div>
            ) : (
              <ul className="divide-y divide-navy-50">
                {trainers.map((t) => (
                  <li
                    key={t.user_id}
                    className="px-5 py-3 flex items-center justify-between gap-3"
                  >
                    <div className="min-w-0">
                      <div className="font-medium text-navy-900">
                        {t.trainer?.full_name ?? t.trainer?.email?.split("@")[0]}
                      </div>
                      <div className="text-xs text-slate-500">
                        {t.trainer?.email}
                      </div>
                    </div>
                    <div className="flex items-center gap-2 shrink-0">
                      <Badge
                        tone={
                          t.kyc_status === "verified"
                            ? "success"
                            : t.kyc_status === "rejected"
                            ? "rose"
                            : "slate"
                        }
                        size="sm"
                      >
                        {t.kyc_status === "verified" && (
                          <CheckCircle2 className="h-3 w-3" />
                        )}
                        {t.kyc_status === "rejected" && (
                          <XCircle className="h-3 w-3" />
                        )}
                        KYC : {t.kyc_status}
                      </Badge>
                      <span className="text-xs text-slate-600 tabular-nums">
                        {t.revenue_share_pct}% au trainer
                      </span>
                    </div>
                  </li>
                ))}
              </ul>
            )}
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
