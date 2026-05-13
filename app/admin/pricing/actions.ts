"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { upsertPackPrice } from "@/lib/pricing-server";
import { isPackSlug, type PackSlug } from "@/lib/packs";

/**
 * Server action : met à jour le prix d'une combinaison (formation, pack).
 *
 * Garde de sécurité côté serveur en plus de la RLS :
 *   - User authentifié
 *   - Role admin ou super_admin
 *   - Validation des inputs (pack slug, prix > 0, compare > price)
 *
 * @returns Objet avec `ok: true/false` + détails.
 */
export async function updatePackPriceAction(input: {
  formationId: string;
  pack: string;
  priceCents: number;
  compareAtCents?: number | null;
  active?: boolean;
}): Promise<{ ok: boolean; error?: string; price?: any }> {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: "not_authenticated" };

  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .single();
  if (!profile || !["admin", "super_admin"].includes(profile.role)) {
    return { ok: false, error: "forbidden" };
  }

  // Validation
  if (!isPackSlug(input.pack)) {
    return { ok: false, error: "invalid_pack" };
  }
  if (typeof input.priceCents !== "number" || input.priceCents <= 0) {
    return { ok: false, error: "invalid_price" };
  }
  if (input.priceCents > 100_000_000) {
    return { ok: false, error: "price_too_high" };
  }
  if (
    input.compareAtCents != null &&
    input.compareAtCents <= input.priceCents
  ) {
    return { ok: false, error: "compare_at_must_be_greater" };
  }

  const result = await upsertPackPrice({
    formationId: input.formationId,
    pack: input.pack as PackSlug,
    priceCents: input.priceCents,
    compareAtCents: input.compareAtCents ?? null,
    active: input.active ?? true,
  });

  if ("error" in result) {
    return { ok: false, error: result.error };
  }

  // Revalidate les pages qui dépendent du pricing
  revalidatePath("/admin/pricing");
  revalidatePath("/tarifs");
  revalidatePath("/inscription");

  return { ok: true, price: result };
}
