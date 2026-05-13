import { AuthLayout } from "@/components/auth-layout";
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { FORMATIONS } from "@/lib/formations-config";
import {
  PACK_SLUGS,
  PACK_METADATA,
  isPackAvailableForFormation,
  type PackSlug,
} from "@/lib/packs";
import { listAllPackPrices } from "@/lib/pricing-server";
import { PricingMatrix } from "./pricing-matrix";

export const dynamic = "force-dynamic";

/**
 * /admin/pricing — Matrice de prix éditable
 *
 * Affiche une grille (formation × pack) avec inline-editing.
 * Accessible uniquement aux admins et super_admins.
 *
 * Phase 2.5 — Architecture packs MFT (révision client 2026-05).
 */
export default async function AdminPricingPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  // Garde côté serveur : seul admin/super_admin accèdent à cette page
  const { data: profile } = await supabase
    .from("profiles")
    .select("role, full_name")
    .eq("id", user.id)
    .single();

  if (!profile || !["admin", "super_admin"].includes(profile.role)) {
    redirect("/dashboard");
  }

  const prices = await listAllPackPrices();

  // Index : (formationId × packSlug) → priceCents
  const priceMap = new Map<string, (typeof prices)[number]>();
  for (const p of prices) {
    priceMap.set(`${p.formationId}_${p.pack}`, p);
  }

  // Liste des formations avec leurs IDs (résolution slug → ID)
  const formationSlugs = FORMATIONS.map((f) => f.slug);
  const { data: dbFormations } = await supabase
    .from("formations")
    .select("id, slug, code, title")
    .in("slug", formationSlugs);

  // On garde l'ordre de FORMATIONS (config) mais on ajoute l'ID DB
  const formations = FORMATIONS.map((f) => {
    const db = (dbFormations ?? []).find((d: any) => d.slug === f.slug);
    return {
      slug: f.slug,
      code: f.code,
      title: f.title,
      id: db?.id ?? null,
    };
  }).filter((f) => f.id !== null);

  return (
    <AuthLayout requireAdmin>
      <div className="max-w-6xl mx-auto px-6 py-10">
        <header className="mb-8">
          <div className="text-[11px] font-semibold uppercase tracking-[0.16em] text-white/45 mb-2">
            Administration · Pricing
          </div>
          <h1 className="font-display text-3xl md:text-4xl font-semibold text-white">
            Matrice de prix
          </h1>
          <p className="mt-3 text-white/65 max-w-2xl">
            Définissez le prix de chaque pack pour chaque formation. Les
            modifications sont prises en compte immédiatement pour les
            nouveaux paiements (Stripe Checkout dynamique, pas de produit
            pré-créé). Capacité ≤ 3,5&nbsp;t accepte uniquement le pack
            Initial (contrainte DB).
          </p>
        </header>

        <PricingMatrix
          formations={formations}
          priceMap={Object.fromEntries(
            Array.from(priceMap.entries()).map(([k, v]) => [
              k,
              {
                priceCents: v.priceCents,
                compareAtCents: v.compareAtCents,
                active: v.active,
              },
            ]),
          )}
        />
      </div>
    </AuthLayout>
  );
}
