// =====================================================================
// Helpers programme de fidélité (P3 #3) — SERVER ONLY.
//
// Tiers (basés sur nombre d'enrollments payées non-refusées) :
//   • none   : 0 enrollment
//   • bronze : 1 enrollment  (statut affiché, prépare le Silver)
//   • silver : 2 enrollments → -10 % auto sur la prochaine formation
//   • gold   : 3+ enrollments → -15 % auto + certificat doré
//
// Plafond réduction : 200 € (20000 cents) par achat.
// =====================================================================

import "server-only";
import { createClient } from "@/lib/supabase/server";

export type LoyaltyTier = "none" | "bronze" | "silver" | "gold";

export interface LoyaltyDiscount {
  tier: LoyaltyTier;
  pct: number;          // % réduction (0, 10 ou 15)
  amount_cents: number; // montant absolu (cents)
  max_cap_cents: number;
}

const TIER_DISCOUNT_PCT: Record<LoyaltyTier, number> = {
  none: 0,
  bronze: 0,
  silver: 10,
  gold: 15,
};

const MAX_CAP_CENTS = 20000; // 200 €

const TIER_LABEL: Record<LoyaltyTier, string> = {
  none: "Sans statut",
  bronze: "Bronze",
  silver: "Silver",
  gold: "Gold",
};

export function getTierLabel(tier: LoyaltyTier): string {
  return TIER_LABEL[tier];
}

export function getTierDiscountPct(tier: LoyaltyTier): number {
  return TIER_DISCOUNT_PCT[tier];
}

/**
 * Récupère le tier du user via RPC SQL (qui compte les enrollments payées).
 * Côté serveur uniquement.
 */
export async function getUserLoyaltyTier(userId: string): Promise<LoyaltyTier> {
  if (!userId) return "none";
  const supabase = createClient();
  const { data, error } = await supabase
    .rpc("loyalty_tier_for_user", { p_user: userId })
    .single();
  if (error || !data) return "none";
  const tier = String(data) as LoyaltyTier;
  if (["none", "bronze", "silver", "gold"].includes(tier)) return tier;
  return "none";
}

/**
 * Calcule la réduction loyalty applicable AVANT le checkout Stripe.
 * Cette fonction est PURE — ne modifie pas la BD. La consommation
 * effective (insertion ledger) est faite par la RPC apply_loyalty_discount
 * appelée depuis le webhook après payment_success.
 */
export function computeLoyaltyDiscount(
  tier: LoyaltyTier,
  priceCents: number
): LoyaltyDiscount {
  const pct = getTierDiscountPct(tier);
  if (pct === 0 || priceCents <= 0) {
    return {
      tier,
      pct: 0,
      amount_cents: 0,
      max_cap_cents: MAX_CAP_CENTS,
    };
  }
  const raw = Math.floor((priceCents * pct) / 100);
  const amount = Math.min(raw, MAX_CAP_CENTS);
  return {
    tier,
    pct,
    amount_cents: amount,
    max_cap_cents: MAX_CAP_CENTS,
  };
}
