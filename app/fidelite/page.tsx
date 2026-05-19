import { redirect } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Trophy,
  Award,
  Gift,
  Sparkles,
  TrendingUp,
  CheckCircle2,
  Lock,
  ArrowRight,
  Info,
} from "lucide-react";
import { getTierLabel, type LoyaltyTier } from "@/lib/loyalty";

export const dynamic = "force-dynamic";

const fmtEuros = (cents: number) =>
  new Intl.NumberFormat("fr-FR", {
    style: "currency",
    currency: "EUR",
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(cents / 100);

const TIER_META: Record<
  LoyaltyTier,
  { label: string; color: string; bg: string; icon: any }
> = {
  none: {
    label: "Sans statut",
    color: "text-slate-500",
    bg: "bg-slate-50 border-slate-200",
    icon: Lock,
  },
  bronze: {
    label: "Bronze",
    color: "text-amber-700",
    bg: "bg-amber-50 border-amber-200",
    icon: Award,
  },
  silver: {
    label: "Silver",
    color: "text-slate-700",
    bg: "bg-slate-100 border-slate-300",
    icon: Trophy,
  },
  gold: {
    label: "Gold",
    color: "text-gold-700",
    bg: "bg-gradient-to-br from-gold-100 to-amber-100 border-gold-300",
    icon: Sparkles,
  },
};

export default async function FidelitePage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  // Statut fidélité
  const { data: statusRaw } = await supabase
    .from("user_loyalty_status")
    .select("*")
    .eq("user_id", user.id)
    .maybeSingle();
  const status = (statusRaw ?? {}) as {
    tier: LoyaltyTier;
    paid_enrollments: number;
    enrollments_to_next_tier: number;
    next_discount_pct: number;
    final_certificates_count: number;
  };
  const tier = status.tier ?? "none";
  const tierMeta = TIER_META[tier];
  const Icon = tierMeta.icon;

  // Historique des événements loyalty
  const { data: eventsRaw } = await supabase
    .from("loyalty_events")
    .select("kind, details, created_at")
    .eq("user_id", user.id)
    .order("created_at", { ascending: false })
    .limit(15);
  const events = (eventsRaw ?? []) as any[];

  // Total économisé via réductions loyalty
  const { data: discountsRaw } = await supabase
    .from("user_credits")
    .select("amount_cents")
    .eq("user_id", user.id)
    .eq("kind", "loyalty_discount");
  const totalSavedCents = -(discountsRaw ?? []).reduce(
    (s, d: any) => s + (d.amount_cents ?? 0),
    0
  );

  // Tier suivant à débloquer
  const NEXT_TIER: Record<LoyaltyTier, LoyaltyTier | null> = {
    none: "bronze",
    bronze: "silver",
    silver: "gold",
    gold: null,
  };
  const nextTier = NEXT_TIER[tier];

  return (
    <div className="space-y-10">
      <header>
        <span className="eyebrow text-gold-700 inline-flex items-center gap-1.5">
          <Trophy className="h-3.5 w-3.5" />
          Programme de fidélité
        </span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Vos avantages stagiaire fidèle
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Plus vous suivez de formations chez MFT, plus vous bénéficiez de
          réductions automatiques et de marques de reconnaissance. Le statut
          est mis à jour à chaque nouvelle inscription payée.
        </p>
      </header>

      {/* Hero : tier actuel */}
      <Card className={`relative overflow-hidden border ${tierMeta.bg}`}>
        <CardBody className="grid lg:grid-cols-[auto_1fr_auto] gap-6 items-center p-6 sm:p-8">
          <div className="flex items-center gap-4">
            <div
              className={`h-16 w-16 rounded-2xl ${tierMeta.bg} border ${tierMeta.color} flex items-center justify-center shrink-0`}
            >
              <Icon className="h-8 w-8" />
            </div>
            <div>
              <div className="text-[11px] uppercase tracking-wider text-slate-500 font-medium">
                Statut actuel
              </div>
              <div
                className={`font-display text-3xl font-semibold ${tierMeta.color}`}
              >
                {tierMeta.label}
              </div>
            </div>
          </div>

          <div className="space-y-2">
            <div className="text-sm text-slate-600">
              {status.paid_enrollments ?? 0} formation
              {status.paid_enrollments > 1 ? "s" : ""} payée
              {status.paid_enrollments > 1 ? "s" : ""} chez MFT
            </div>
            {nextTier && status.enrollments_to_next_tier > 0 && (
              <div className="text-sm text-navy-900">
                <span className="font-medium">
                  {status.enrollments_to_next_tier} formation
                  {status.enrollments_to_next_tier > 1 ? "s" : ""}
                </span>{" "}
                pour atteindre le statut{" "}
                <strong>{TIER_META[nextTier].label}</strong>
              </div>
            )}
            {!nextTier && tier === "gold" && (
              <div className="text-sm text-gold-800 font-medium inline-flex items-center gap-1.5">
                <Sparkles className="h-4 w-4" />
                Vous êtes au statut maximum
              </div>
            )}
          </div>

          {status.next_discount_pct > 0 && (
            <div className="text-right">
              <div className="text-[11px] uppercase tracking-wider text-slate-500 font-medium">
                Prochain achat
              </div>
              <div className="font-display text-3xl font-semibold text-gold-700 tabular-nums">
                -{status.next_discount_pct}%
              </div>
              <div className="text-xs text-slate-500">automatique</div>
            </div>
          )}
        </CardBody>
      </Card>

      {/* Stats compactes */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Stat
          icon={Gift}
          label="Total économisé"
          value={fmtEuros(totalSavedCents)}
          hint="Cumul des réductions fidélité"
          tone="primary"
        />
        <Stat
          icon={CheckCircle2}
          label="Formations payées"
          value={String(status.paid_enrollments ?? 0)}
          hint="Inscrites et financées"
        />
        <Stat
          icon={Award}
          label="Certificats finaux"
          value={String(status.final_certificates_count ?? 0)}
          hint={
            status.final_certificates_count >= 2
              ? "Nouveaux certifs dorés automatiquement"
              : status.final_certificates_count === 1
                ? "Le 2ᵉ sera doré"
                : "À débloquer en validant votre 1ʳᵉ formation"
          }
        />
      </div>

      {/* Échelle des tiers */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 inline-flex items-center gap-2">
          <TrendingUp className="h-5 w-5 text-gold-700" />
          Échelle des avantages
        </h2>
        <div className="grid md:grid-cols-3 gap-4">
          <TierCard
            tier="bronze"
            current={tier}
            condition="1 formation payée"
            benefits={[
              "Statut affiché sur votre profil",
              "Préparation au statut Silver",
            ]}
          />
          <TierCard
            tier="silver"
            current={tier}
            condition="2 formations payées"
            benefits={[
              "−10 % automatique sur la prochaine formation",
              "Plafonné à 200 €",
            ]}
          />
          <TierCard
            tier="gold"
            current={tier}
            condition="3+ formations payées"
            benefits={[
              "−15 % automatique sur les achats suivants",
              "Plafonné à 200 €",
              "Certificat doré sur les nouveaux certifs finals",
              "Priorité sur les nouvelles formations",
            ]}
          />
        </div>
      </section>

      {/* Historique */}
      {events.length > 0 && (
        <section>
          <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 inline-flex items-center gap-2">
            <Gift className="h-5 w-5 text-gold-700" />
            Activité récente
          </h2>
          <Card>
            <CardBody className="p-0">
              <ul className="divide-y divide-navy-50">
                {events.map((e, i) => (
                  <li
                    key={i}
                    className="px-5 py-3 flex items-center justify-between gap-3"
                  >
                    <div className="min-w-0">
                      <div className="text-sm font-medium text-navy-900">
                        {formatEventTitle(e.kind, e.details)}
                      </div>
                      <div className="text-xs text-slate-500">
                        {new Date(e.created_at).toLocaleDateString("fr-FR", {
                          day: "2-digit",
                          month: "long",
                          year: "numeric",
                        })}
                      </div>
                    </div>
                    {e.kind === "discount_applied" && e.details?.amount_cents && (
                      <div className="font-display font-semibold text-emerald-700 tabular-nums">
                        -{fmtEuros(e.details.amount_cents)}
                      </div>
                    )}
                  </li>
                ))}
              </ul>
            </CardBody>
          </Card>
        </section>
      )}

      {/* CTA + règles */}
      <Card variant="gold">
        <CardBody className="space-y-3">
          <div className="flex items-start gap-3">
            <Info className="h-5 w-5 text-gold-700 shrink-0 mt-0.5" />
            <div className="text-sm text-slate-700">
              <p className="font-medium text-navy-900 mb-2">
                Comment fonctionne le programme
              </p>
              <ul className="list-disc pl-5 space-y-1">
                <li>
                  Chaque formation payée chez MFT compte. Tous les packs
                  (Initial, Medium, Premium) sont éligibles.
                </li>
                <li>
                  Le statut est calculé en temps réel : dès qu'une nouvelle
                  inscription est payée, le tier monte automatiquement.
                </li>
                <li>
                  La réduction est <strong>cumulable</strong> avec un code
                  parrainage filleul (-10 % supplémentaires).
                </li>
                <li>
                  Le certificat doré est délivré à partir de votre 2ᵉ
                  certificat final, sans démarche de votre part.
                </li>
              </ul>
            </div>
          </div>
          <div className="pt-2 flex flex-wrap gap-2">
            <Link
              href="/tarifs"
              className="inline-flex items-center gap-1.5 rounded-xl bg-navy-900 hover:bg-navy-800 text-white px-4 py-2 text-sm font-medium transition-colors"
            >
              Voir les formations
              <ArrowRight className="h-3.5 w-3.5" />
            </Link>
            <Link
              href="/parrainage"
              className="inline-flex items-center gap-1.5 rounded-xl bg-white border border-navy-200 hover:bg-navy-50 text-navy-900 px-4 py-2 text-sm font-medium transition-colors"
            >
              <Gift className="h-3.5 w-3.5" />
              Voir mon parrainage
            </Link>
          </div>
        </CardBody>
      </Card>
    </div>
  );
}

// ─── Composants ──────────────────────────────────────────────────────

function TierCard({
  tier,
  current,
  condition,
  benefits,
}: {
  tier: LoyaltyTier;
  current: LoyaltyTier;
  condition: string;
  benefits: string[];
}) {
  const meta = TIER_META[tier];
  const Icon = meta.icon;
  const TIER_RANK: Record<LoyaltyTier, number> = {
    none: 0,
    bronze: 1,
    silver: 2,
    gold: 3,
  };
  const isReached = TIER_RANK[current] >= TIER_RANK[tier];
  const isCurrent = current === tier;

  return (
    <Card
      className={
        isCurrent
          ? `border-2 ${meta.color.replace("text-", "border-")} ${meta.bg}`
          : ""
      }
    >
      <CardBody className="space-y-3">
        <div className="flex items-center justify-between">
          <div className={`inline-flex items-center gap-2 ${meta.color}`}>
            <Icon className="h-5 w-5" />
            <span className="font-display font-semibold text-lg">
              {meta.label}
            </span>
          </div>
          {isCurrent && (
            <Badge tone="gold" size="sm">
              Actuel
            </Badge>
          )}
          {isReached && !isCurrent && (
            <Badge tone="success" size="sm">
              <CheckCircle2 className="h-3 w-3" /> Acquis
            </Badge>
          )}
          {!isReached && (
            <Badge tone="slate" size="sm">
              <Lock className="h-3 w-3" /> À débloquer
            </Badge>
          )}
        </div>
        <p className="text-xs text-slate-500 uppercase tracking-wider font-medium">
          {condition}
        </p>
        <ul className="space-y-1.5 text-sm text-navy-900">
          {benefits.map((b, i) => (
            <li key={i} className="flex items-start gap-2">
              <CheckCircle2
                className={`h-3.5 w-3.5 shrink-0 mt-0.5 ${
                  isReached ? "text-emerald-600" : "text-slate-400"
                }`}
              />
              <span>{b}</span>
            </li>
          ))}
        </ul>
      </CardBody>
    </Card>
  );
}

function Stat({
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

function formatEventTitle(kind: string, details: any): string {
  switch (kind) {
    case "tier_upgraded":
      return `Statut passé à ${getTierLabel(details?.to_tier ?? "none")}`;
    case "discount_applied":
      return `Remise fidélité ${details?.pct ?? "?"}% appliquée à un achat`;
    case "gold_certificate":
      return "Certificat doré délivré";
    default:
      return kind;
  }
}
