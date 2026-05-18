"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

async function ensureAdmin() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");
  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();
  if (!profile?.role || !["admin", "super_admin"].includes(profile.role)) {
    throw new Error("Réservé aux administrateurs");
  }
  return supabase;
}

/**
 * Valide un parrainage 'qualified' : crédite 50€ au parrain.
 */
export async function approveReferral(referralId: string, amountCents = 5000) {
  const supabase = await ensureAdmin();
  const { error } = await supabase.rpc("reward_referral", {
    p_referral_id: referralId,
    p_amount_cents: amountCents,
  });
  if (error) {
    return { ok: false, error: error.message };
  }
  revalidatePath("/admin/referrals");
  return { ok: true };
}

/**
 * Refuse un parrainage (fraude, doublon, etc.).
 */
export async function rejectReferral(referralId: string, reason: string) {
  const supabase = await ensureAdmin();
  if (!reason.trim()) {
    return { ok: false, error: "Motif requis" };
  }
  const { error } = await supabase.rpc("reject_referral", {
    p_referral_id: referralId,
    p_reason: reason.trim(),
  });
  if (error) {
    return { ok: false, error: error.message };
  }
  revalidatePath("/admin/referrals");
  return { ok: true };
}
