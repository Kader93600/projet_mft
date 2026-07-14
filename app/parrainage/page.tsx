import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import type { Tables, Views } from "@/lib/database.types";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Gift,
  Users,
  CheckCircle2,
  Hourglass,
  XCircle,
  Wallet,
  Sparkles,
  Info,
  type LucideIcon,
} from "lucide-react";
import { ShareCard } from "@/components/referral/share-card";

export const dynamic = "force-dynamic";

/** Résultat du select `referrals` + embed `referred:profiles!…(full_name, email)`. */
type ReferralRow = Pick<
  Tables<"referrals">,
  "id" | "status" | "reward_cents" | "created_at" | "rewarded_at" | "rejection_reason"
> & {
  referred: Pick<Tables<"profiles">, "full_name" | "email"> | null;
};

/** Résultat du select `user_credits`. */
type CreditRow = Pick<
  Tables<"user_credits">,
  "amount_cents" | "kind" | "description" | "created_at"
>;

const STATUS_META = {
  pending: {
    label: "En attente",
    desc: "Code utilisé, en attente du paiement du filleul",
    tone: "slate" as const,
    icon: Hourglass,
  },
  qualified: {
    label: "Validé",
    desc: "Filleul a payé — récompense en cours de validation",
    tone: "gold" as const,
    icon: CheckCircle2,
  },
  rewarded: {
    label: "Crédit reçu",
    desc: "+50 € de crédit appliqué",
    tone: "success" as const,
    icon: Gift,
  },
  rejected: {
    label: "Refusé",
    desc: "Récompense refusée (fraude, doublon)",
    tone: "rose" as const,
    icon: XCircle,
  },
};

const fmtEuros = (cents: number) =>
  new Intl.NumberFormat("fr-FR", {
    style: "currency",
    currency: "EUR",
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(cents / 100);

export default async function ParrainagePage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  // 1. Récupère ou crée le code de parrainage de l'utilisateur
  const { data: codeData } = await supabase
    .rpc("get_or_create_referral_code", { p_user: user.id })
    .single();
  const myCode = (codeData as string) ?? null;

  // 2. Liste de mes parrainages (filleuls)
  const { data: referralsRaw } = await supabase
    .from("referrals")
    .select(`
      id, status, reward_cents, created_at, rewarded_at, rejection_reason,
      referred:profiles!referrals_referred_user_id_fkey ( full_name, email )
    `)
    .eq("referrer_id", user.id)
    .order("created_at", { ascending: false })
    // Le client n'étant pas câblé sur `Database`, postgrest infère l'embed
    // to-one comme un tableau : on impose la forme réelle renvoyée par l'API.
    .overrideTypes<ReferralRow[], { merge: false }>();
  const referrals = referralsRaw ?? [];

  // 3. Solde de mon crédit + historique
  const { data: balance } = await supabase
    .from("user_credit_balance")
    .select("balance_cents")
    .eq("user_id", user.id)
    .maybeSingle();
  const balanceCents =
    (balance as Pick<Views<"user_credit_balance">, "balance_cents"> | null)
      ?.balance_cents ?? 0;

  const { data: creditHistoryRaw } = await supabase
    .from("user_credits")
    .select("amount_cents, kind, description, created_at")
    .eq("user_id", user.id)
    .order("created_at", { ascending: false })
    .limit(10);
  const creditHistory = (creditHistoryRaw ?? []) as CreditRow[];

  // 4. Stats
  const stats = {
    total: referrals.length,
    pending: referrals.filter((r) => r.status === "pending").length,
    qualified: referrals.filter((r) => r.status === "qualified").length,
    rewarded: referrals.filter((r) => r.status === "rewarded").length,
    earned_total_cents: referrals
      .filter((r) => r.status === "rewarded")
      .reduce((s, r) => s + (r.reward_cents ?? 0), 0),
  };

  const remainingThisYear = Math.max(
    0,
    10 - (stats.qualified + stats.rewarded)
  );

  return (
    <div className="space-y-10">
      <header>
        <span className="eyebrow text-gold-700 inline-flex items-center gap-1.5">
          <Gift className="h-3.5 w-3.5" />
          Programme parrainage
        </span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Parrainez, gagnez 50 €
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Partagez votre code à un proche qui souhaite passer un titre
          professionnel transport. Il bénéficie de <strong>−10 %</strong> sur
          sa première inscription. Vous recevez <strong>50 € de crédit</strong>{" "}
          applicable sur votre prochaine formation à chaque parrainage validé.
        </p>
      </header>

      {/* Hero : mon code + partage */}
      {myCode && (
        <ShareCard code={myCode} />
      )}

      {/* Stats compactes */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3 sm:gap-4">
        <Stat
          icon={Users}
          label="Filleuls inscrits"
          value={String(stats.total)}
          hint={`${remainingThisYear} place(s) sur ${10} cette année`}
        />
        <Stat
          icon={Hourglass}
          label="En attente"
          value={String(stats.pending + stats.qualified)}
          hint={stats.qualified > 0 ? `${stats.qualified} prêts pour validation admin` : "Aucun"}
        />
        <Stat
          icon={Wallet}
          label="Crédit disponible"
          value={fmtEuros(balanceCents)}
          hint="Appliqué automatiquement au prochain achat"
          tone="primary"
        />
        <Stat
          icon={Sparkles}
          label="Total gagné"
          value={fmtEuros(stats.earned_total_cents)}
          hint={stats.rewarded > 0 ? `Via ${stats.rewarded} parrainage(s)` : "—"}
        />
      </div>

      {/* Liste des parrainages */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 inline-flex items-center gap-2">
          <Users className="h-5 w-5 text-gold-700" />
          Mes filleuls
        </h2>
        {referrals.length === 0 ? (
          <Card>
            <CardBody className="text-center py-10">
              <div className="mx-auto h-12 w-12 rounded-xl bg-gold-50 border border-gold-200 text-gold-700 flex items-center justify-center">
                <Gift className="h-6 w-6" />
              </div>
              <p className="mt-4 font-medium text-navy-900">
                Aucun filleul pour le moment
              </p>
              <p className="text-sm text-slate-600 mt-1 max-w-md mx-auto">
                Partagez votre code à des proches qui envisagent une formation
                transport. À leur première inscription payée, vous gagnez 50 €.
              </p>
            </CardBody>
          </Card>
        ) : (
          <Card>
            <CardBody className="p-0">
              <ul className="divide-y divide-navy-50">
                {referrals.map((r) => {
                  const meta = STATUS_META[r.status as keyof typeof STATUS_META];
                  const Icon = meta.icon;
                  const refName =
                    r.referred?.full_name ??
                    r.referred?.email?.split("@")[0] ??
                    "—";
                  return (
                    <li
                      key={r.id}
                      className="px-5 py-3.5 flex items-center justify-between gap-3"
                    >
                      <div className="min-w-0 flex-1">
                        <div className="flex items-center gap-2 flex-wrap">
                          <span className="font-medium text-navy-900">
                            {refName}
                          </span>
                          <Badge tone={meta.tone} size="sm">
                            <Icon className="h-3 w-3" />
                            {meta.label}
                          </Badge>
                        </div>
                        <div className="text-xs text-slate-500 mt-0.5">
                          {meta.desc} ·{" "}
                          {new Date(r.created_at).toLocaleDateString("fr-FR", {
                            day: "2-digit",
                            month: "short",
                            year: "numeric",
                          })}
                        </div>
                        {r.rejection_reason && (
                          <div className="text-xs text-rose-700 mt-1">
                            Motif : {r.rejection_reason}
                          </div>
                        )}
                      </div>
                      {r.status === "rewarded" && r.reward_cents != null && (
                        <div className="font-display text-base font-semibold text-emerald-700 tabular-nums shrink-0">
                          +{fmtEuros(r.reward_cents)}
                        </div>
                      )}
                    </li>
                  );
                })}
              </ul>
            </CardBody>
          </Card>
        )}
      </section>

      {/* Historique crédit */}
      {creditHistory.length > 0 && (
        <section>
          <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 inline-flex items-center gap-2">
            <Wallet className="h-5 w-5 text-gold-700" />
            Historique du crédit
          </h2>
          <Card>
            <CardBody className="p-0">
              <ul className="divide-y divide-navy-50">
                {creditHistory.map((c, i) => (
                  <li
                    key={i}
                    className="px-5 py-3 flex items-center justify-between gap-3"
                  >
                    <div className="min-w-0 flex-1">
                      <div className="text-sm font-medium text-navy-900">
                        {c.description ?? c.kind}
                      </div>
                      <div className="text-xs text-slate-500">
                        {new Date(c.created_at).toLocaleDateString("fr-FR", {
                          day: "2-digit",
                          month: "short",
                          year: "numeric",
                        })}
                      </div>
                    </div>
                    <div
                      className={
                        c.amount_cents >= 0
                          ? "font-display text-base font-semibold text-emerald-700 tabular-nums shrink-0"
                          : "font-display text-base font-semibold text-rose-700 tabular-nums shrink-0"
                      }
                    >
                      {c.amount_cents >= 0 ? "+" : "−"}
                      {fmtEuros(Math.abs(c.amount_cents))}
                    </div>
                  </li>
                ))}
              </ul>
            </CardBody>
          </Card>
        </section>
      )}

      {/* Règles du jeu */}
      <Card>
        <CardBody>
          <div className="flex items-start gap-3">
            <Info className="h-5 w-5 text-slate-500 shrink-0 mt-0.5" />
            <div className="text-sm text-slate-600 space-y-2">
              <p className="font-medium text-navy-900">Comment ça marche</p>
              <ul className="space-y-1 list-disc pl-5">
                <li>Partagez votre code avec un proche qui n'a pas encore de compte MFT.</li>
                <li>Il s'inscrit avec votre code lors du paiement → il bénéficie de −10 %.</li>
                <li>Dès qu'il a réglé sa première formation, votre récompense de 50 € est mise en attente de validation.</li>
                <li>Après vérification (≤ 7 jours), votre crédit est appliqué à votre compte. Il est utilisable sur n'importe quelle formation MFT.</li>
                <li>Plafond : 10 parrainages validés / an. Un parrain ne peut pas se parrainer lui-même.</li>
              </ul>
            </div>
          </div>
        </CardBody>
      </Card>
    </div>
  );
}

// ─── Composants internes ─────────────────────────────────────────────

function Stat({
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
  tone?: "default" | "primary";
}) {
  return (
    <Card>
      <CardBody className="p-4 sm:p-5">
        <div className="flex items-start gap-3">
          <div
            className={
              tone === "primary"
                ? "h-10 w-10 rounded-xl bg-gold-500 text-navy-900 flex items-center justify-center shrink-0"
                : "h-10 w-10 rounded-xl bg-gold-50 border border-gold-200 text-gold-700 flex items-center justify-center shrink-0"
            }
          >
            <Icon className="h-5 w-5" />
          </div>
          <div className="min-w-0">
            <div className="text-[11px] uppercase tracking-wider text-slate-500 font-medium leading-tight">
              {label}
            </div>
            <div className="font-display text-xl sm:text-2xl font-semibold text-navy-900 mt-0.5 tabular-nums leading-none">
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
