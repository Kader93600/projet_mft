import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { FORMATIONS } from "@/lib/formations-config";
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
 * Pas de wrapper AuthLayout : le layout admin (app/admin/layout.tsx) gère
 * déjà l'AdminShell avec sidebar + breadcrumb.
 */
export default async function AdminPricingPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  // Garde côté serveur : seul admin/super_admin accèdent à cette page
  // (en plus du middleware admin/layout qui gère déjà la garde principale)
  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
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
  }).filter((f) => f.id !== null) as Array<{
    slug: string;
    code: string;
    title: string;
    id: string;
  }>;

  return (
    <div className="px-8 py-8 space-y-8">
      <header>
        <span className="eyebrow text-gold-700">Administration · Tarification</span>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Matrice de prix
        </h1>
        <p className="mt-2 text-slate-600 max-w-3xl">
          Définissez le prix de chaque pack pour chaque formation. Les
          modifications sont prises en compte <strong>immédiatement</strong> pour
          les nouveaux paiements (Stripe Checkout dynamique). Capacité ≤ 3,5&nbsp;t
          accepte uniquement le pack <strong>Initial</strong> (contrainte DB).
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
  );
}
