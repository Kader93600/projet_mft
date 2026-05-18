import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Gift,
  Users,
  Hourglass,
  CheckCircle2,
  XCircle,
  TrendingUp,
  Wallet,
} from "lucide-react";
import { isStaff } from "@/lib/permissions";
import { ReferralActions } from "./referral-actions";

export const dynamic = "force-dynamic";

const fmtEuros = (cents: number) =>
  new Intl.NumberFormat("fr-FR", {
    style: "currency",
    currency: "EUR",
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(cents / 100);

export default async function AdminReferralsPage() {
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

  // ─── Données ────────────────────────────────────────────────────────
  const [
    { data: qualifiedRaw },
    { data: recentRewardedRaw },
    { data: monthStatsRaw },
  ] = await Promise.all([
    // File d'attente : 'qualified' = filleul a payé, en attente de validation
    supabase
      .from("referrals")
      .select(`
        id, status, code_used, reward_cents, created_at, enrollment_id,
        referrer:profiles!referrals_referrer_id_fkey ( id, full_name, email ),
        referred:profiles!referrals_referred_user_id_fkey ( id, full_name, email )
      `)
      .eq("status", "qualified")
      .order("created_at", { ascending: true })
      .limit(50),

    // 5 dernières récompenses (pour validation visuelle)
    supabase
      .from("referrals")
      .select(`
        id, status, reward_cents, rewarded_at,
        referrer:profiles!referrals_referrer_id_fkey ( full_name, email )
      `)
      .eq("status", "rewarded")
      .order("rewarded_at", { ascending: false })
      .limit(5),

    // Stats : récompenses du mois courant
    supabase
      .from("referrals")
      .select("reward_cents, status, created_at")
      .gte(
        "created_at",
        new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString()
      ),
  ]);

  const queue = (qualifiedRaw ?? []) as any[];
  const recentRewarded = (recentRewardedRaw ?? []) as any[];
  const monthStats = (monthStatsRaw ?? []) as any[];

  const stats = {
    pending: monthStats.filter((r) => r.status === "qualified").length,
    rewarded: monthStats.filter((r) => r.status === "rewarded").length,
    rejected: monthStats.filter((r) => r.status === "rejected").length,
    total_paid_cents: monthStats
      .filter((r) => r.status === "rewarded")
      .reduce((s, r) => s + (r.reward_cents ?? 0), 0),
  };

  return (
    <div className="space-y-8">
      <header>
        <span className="eyebrow text-gold-700 inline-flex items-center gap-1.5">
          <Gift className="h-3.5 w-3.5" />
          Programme parrainage
        </span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Validations à effectuer
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          File d'attente des parrainages dont le filleul a payé. Vérifiez
          rapidement l'absence d'abus (même IP, mêmes nom/prénom, comptes
          fraîchement créés), puis validez ou refusez.
        </p>
      </header>

      {/* KPIs du mois */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3 sm:gap-4">
        <Kpi
          icon={Hourglass}
          label="En attente"
          value={String(queue.length)}
          hint="Action requise"
          tone={queue.length > 0 ? "warning" : "default"}
        />
        <Kpi
          icon={CheckCircle2}
          label="Validés ce mois"
          value={String(stats.rewarded)}
          hint="Crédit attribué"
        />
        <Kpi
          icon={XCircle}
          label="Refusés ce mois"
          value={String(stats.rejected)}
          hint={stats.rejected > 0 ? "Surveiller la fraude" : "RAS"}
        />
        <Kpi
          icon={Wallet}
          label="Versé ce mois"
          value={fmtEuros(stats.total_paid_cents)}
          hint="En crédit applicable"
        />
      </div>

      {/* File d'attente */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 inline-flex items-center gap-2">
          <TrendingUp className="h-5 w-5 text-gold-700" />
          File d'attente ({queue.length})
        </h2>
        {queue.length === 0 ? (
          <Card>
            <CardBody className="text-center py-10">
              <div className="mx-auto h-12 w-12 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-700 flex items-center justify-center">
                <CheckCircle2 className="h-6 w-6" />
              </div>
              <p className="mt-4 font-medium text-navy-900">
                Aucun parrainage en attente
              </p>
              <p className="text-sm text-slate-600 mt-1">
                Tout est à jour. Les nouvelles validations apparaîtront dès qu'un
                filleul aura payé.
              </p>
            </CardBody>
          </Card>
        ) : (
          <Card>
            <CardBody className="p-0">
              <ul className="divide-y divide-navy-50">
                {queue.map((r) => {
                  const referrerName =
                    r.referrer?.full_name ??
                    r.referrer?.email?.split("@")[0] ??
                    "—";
                  const referredName =
                    r.referred?.full_name ??
                    r.referred?.email?.split("@")[0] ??
                    "—";
                  return (
                    <li key={r.id} className="px-5 py-4">
                      <div className="grid md:grid-cols-[1fr_auto] gap-3 items-start">
                        <div className="min-w-0">
                          <div className="flex items-center gap-2 flex-wrap mb-1">
                            <Badge tone="gold" size="sm">
                              <Gift className="h-3 w-3" />
                              Code {r.code_used}
                            </Badge>
                            <span className="text-xs text-slate-500">
                              Inscrit le{" "}
                              {new Date(r.created_at).toLocaleDateString(
                                "fr-FR",
                                {
                                  day: "2-digit",
                                  month: "short",
                                  year: "numeric",
                                }
                              )}
                            </span>
                          </div>
                          <div className="text-sm text-navy-900">
                            <span className="text-slate-500">Parrain : </span>
                            <span className="font-medium">{referrerName}</span>
                            <span className="text-slate-400"> · </span>
                            <span className="text-xs text-slate-500">
                              {r.referrer?.email}
                            </span>
                          </div>
                          <div className="text-sm text-navy-900 mt-0.5">
                            <span className="text-slate-500">Filleul : </span>
                            <span className="font-medium">{referredName}</span>
                            <span className="text-slate-400"> · </span>
                            <span className="text-xs text-slate-500">
                              {r.referred?.email}
                            </span>
                          </div>
                        </div>
                        <ReferralActions referralId={r.id} />
                      </div>
                    </li>
                  );
                })}
              </ul>
            </CardBody>
          </Card>
        )}
      </section>

      {/* Dernières récompenses */}
      {recentRewarded.length > 0 && (
        <section>
          <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 inline-flex items-center gap-2">
            <CheckCircle2 className="h-5 w-5 text-emerald-700" />
            Dernières récompenses
          </h2>
          <Card>
            <CardBody className="p-0">
              <ul className="divide-y divide-navy-50">
                {recentRewarded.map((r) => (
                  <li
                    key={r.id}
                    className="px-5 py-3 flex items-center justify-between gap-3"
                  >
                    <div className="min-w-0">
                      <div className="text-sm font-medium text-navy-900">
                        {r.referrer?.full_name ??
                          r.referrer?.email?.split("@")[0] ??
                          "—"}
                      </div>
                      <div className="text-xs text-slate-500">
                        Validé le{" "}
                        {new Date(r.rewarded_at).toLocaleDateString("fr-FR", {
                          day: "2-digit",
                          month: "short",
                          year: "numeric",
                        })}
                      </div>
                    </div>
                    <div className="font-display text-base font-semibold text-emerald-700 tabular-nums">
                      +{fmtEuros(r.reward_cents ?? 0)}
                    </div>
                  </li>
                ))}
              </ul>
            </CardBody>
          </Card>
        </section>
      )}
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
  return (
    <Card>
      <CardBody className="p-4 sm:p-5">
        <div className="flex items-start gap-3">
          <div
            className={
              tone === "warning"
                ? "h-10 w-10 rounded-xl bg-amber-50 border border-amber-200 text-amber-700 flex items-center justify-center shrink-0"
                : "h-10 w-10 rounded-xl bg-gold-50 border border-gold-200 text-gold-700 flex items-center justify-center shrink-0"
            }
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
              <div className="text-[11px] text-slate-500 mt-1.5 leading-tight">
                {hint}
              </div>
            )}
          </div>
        </div>
      </CardBody>
    </Card>
  );
}
