// =====================================================================
// Pricing serveur (DB-driven) — Phase 2 architecture packs.
//
// Les prix de chaque (formation × pack) sont stockés dans la table
// `formation_pack_prices` côté Supabase, modifiables par admin/super_admin
// via l'UI /admin/pricing.
//
// Ce module fournit les helpers pour :
//   - Récupérer le prix d'un pack pour une formation (côté API checkout)
//   - Lister tous les prix actifs (UI inscription)
//   - Lister tous les prix incl. inactifs (UI admin pricing)
//   - Mettre à jour un prix (server action admin)
//
// ⚠️ Server-only : ce fichier importe createClient depuis @/lib/supabase/server
// → ne JAMAIS l'importer depuis un composant client.
// =====================================================================

import "server-only";

import { createClient } from "@/lib/supabase/server";
import { fmtEuros, type PackSlug } from "@/lib/packs";
import type { Tables } from "@/lib/database.types";

// ---------------------------------------------------------------------
// Formes exactes des lignes renvoyées par les `select` de ce module.
// Le client Supabase n'étant pas câblé sur `Database` globalement, on
// décrit ici le résultat du select (colonnes + embed `formations!inner`).
// ---------------------------------------------------------------------

/**
 * Embed `formations!inner(slug)` : objet ou tableau selon la version du
 * client. Le `!inner` garantit la présence d'au moins une formation liée
 * (jointure interne) → tableau non vide, jamais null.
 */
type FormationSlugEmbed =
  | Pick<Tables<"formations">, "slug">
  | [Pick<Tables<"formations">, "slug">, ...Pick<Tables<"formations">, "slug">[]];

/** Select sans la colonne `pack` (getPackPrice : le pack vient du filtre `.eq`). */
type PackPriceRowNoPack = Pick<
  Tables<"formation_pack_prices">,
  | "price_cents"
  | "compare_at_cents"
  | "active"
  | "notes"
  | "updated_at"
  | "formation_id"
> & { formations: FormationSlugEmbed };

/** Select complet (fetchPackPrices / upsertPackPrice). */
type PackPriceRow = PackPriceRowNoPack &
  Pick<Tables<"formation_pack_prices">, "pack">;

export interface PackPrice {
  /** Slug de la formation (ex: 'gotrm', 'capacite-3-5t'). */
  formationSlug: string;
  /** ID UUID de la formation. */
  formationId: string;
  /** Pack (initial / medium / premium). */
  pack: PackSlug;
  /** Prix en centimes (ex: 400000 pour 4 000 €). */
  priceCents: number;
  /** Prix barré (optionnel) — pour afficher "à partir de" / promo. */
  compareAtCents: number | null;
  /** Désactivé : non vendable. Visible uniquement par admin. */
  active: boolean;
  /** Notes internes (admin). */
  notes?: string | null;
  updatedAt: string;
}

// ---------------------------------------------------------------------
// 1. Récupération d'un prix unique
// ---------------------------------------------------------------------

/**
 * Récupère le prix actif d'un pack pour une formation.
 * Renvoie `null` si :
 *   - la combinaison n'existe pas (ex: Medium pour Capacité ≤ 3,5 t)
 *   - le prix est désactivé (`active = false`)
 *
 * @example
 *   const p = await getPackPrice("gotrm", "medium");
 *   //   { formationSlug: "gotrm", pack: "medium", priceCents: 600000, ... }
 */
export async function getPackPrice(
  formationSlug: string,
  pack: PackSlug,
): Promise<PackPrice | null> {
  const supabase = createClient();
  const { data, error } = await supabase
    .from("formation_pack_prices")
    .select(
      `
      price_cents,
      compare_at_cents,
      active,
      notes,
      updated_at,
      formation_id,
      formations!inner(slug)
      `,
    )
    .eq("pack", pack)
    .eq("active", true)
    .eq("formations.slug", formationSlug)
    .maybeSingle();

  if (error) {
    // eslint-disable-next-line no-console
    console.error("[pricing-server] getPackPrice error", { formationSlug, pack, error });
    return null;
  }
  if (!data) return null;

  const row = data as PackPriceRowNoPack;

  // Supabase peut renvoyer formations sous forme d'array ou d'objet selon
  // la version du client. On gère les deux.
  const formationsRel = row.formations;
  const slug = Array.isArray(formationsRel)
    ? formationsRel[0]?.slug
    : formationsRel?.slug;

  return {
    formationSlug: slug ?? formationSlug,
    formationId: row.formation_id,
    pack,
    priceCents: row.price_cents,
    compareAtCents: row.compare_at_cents,
    active: row.active,
    notes: row.notes,
    updatedAt: row.updated_at,
  };
}

// ---------------------------------------------------------------------
// 2. Récupération de tous les prix
// ---------------------------------------------------------------------

/**
 * Renvoie tous les prix actifs (visibles publiquement).
 * Utilisé par la page /inscription et la page /tarifs.
 */
export async function listActivePackPrices(): Promise<PackPrice[]> {
  return fetchPackPrices({ activeOnly: true });
}

/**
 * Renvoie TOUS les prix (actifs + inactifs).
 * Utilisé par l'UI /admin/pricing.
 *
 * RLS : nécessite role admin ou super_admin.
 */
export async function listAllPackPrices(): Promise<PackPrice[]> {
  return fetchPackPrices({ activeOnly: false });
}

async function fetchPackPrices(opts: {
  activeOnly: boolean;
}): Promise<PackPrice[]> {
  const supabase = createClient();
  let query = supabase
    .from("formation_pack_prices")
    .select(
      `
      pack,
      price_cents,
      compare_at_cents,
      active,
      notes,
      updated_at,
      formation_id,
      formations!inner(slug)
      `,
    )
    .order("formation_id")
    .order("pack");

  if (opts.activeOnly) {
    query = query.eq("active", true);
  }

  const { data, error } = await query;
  if (error) {
    // eslint-disable-next-line no-console
    console.error("[pricing-server] fetchPackPrices error", error);
    return [];
  }

  return ((data ?? []) as PackPriceRow[]).map((row) => {
    const formationsRel = row.formations;
    const slug = Array.isArray(formationsRel)
      ? formationsRel[0].slug
      : formationsRel.slug;
    return {
      formationSlug: slug,
      formationId: row.formation_id,
      pack: row.pack as PackSlug,
      priceCents: row.price_cents,
      compareAtCents: row.compare_at_cents,
      active: row.active,
      notes: row.notes,
      updatedAt: row.updated_at,
    };
  });
}

// ---------------------------------------------------------------------
// 3. Mise à jour d'un prix (admin only — RLS enforce)
// ---------------------------------------------------------------------

export interface UpdatePackPriceInput {
  formationId: string;
  pack: PackSlug;
  priceCents: number;
  compareAtCents?: number | null;
  active?: boolean;
  notes?: string | null;
}

/**
 * Crée ou met à jour le prix d'une combinaison (formation, pack).
 * RLS bloque les non-admins.
 *
 * @returns Le prix mis à jour, ou null en cas d'erreur (incluant
 *   violation du trigger : Capacité ≤ 3,5 t accepte uniquement Initial).
 */
export async function upsertPackPrice(
  input: UpdatePackPriceInput,
): Promise<PackPrice | { error: string }> {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "not_authenticated" };

  if (input.priceCents <= 0) {
    return { error: "price_must_be_positive" };
  }
  if (
    input.compareAtCents != null &&
    input.compareAtCents <= input.priceCents
  ) {
    return { error: "compare_at_must_be_greater" };
  }

  const { data, error } = await supabase
    .from("formation_pack_prices")
    .upsert(
      {
        formation_id: input.formationId,
        pack: input.pack,
        price_cents: input.priceCents,
        compare_at_cents: input.compareAtCents ?? null,
        active: input.active ?? true,
        notes: input.notes ?? null,
        updated_by: user.id,
      },
      { onConflict: "formation_id,pack" },
    )
    .select(
      `
      pack,
      price_cents,
      compare_at_cents,
      active,
      notes,
      updated_at,
      formation_id,
      formations!inner(slug)
      `,
    )
    .single();

  if (error) {
    // eslint-disable-next-line no-console
    console.error("[pricing-server] upsertPackPrice error", { input, error });
    // Erreur trigger : Capacité ≤ 3,5 t avec pack ≠ initial
    if (error.message.includes("Capacité")) {
      return { error: "capacite_only_initial" };
    }
    return { error: error.message };
  }

  const row = data as PackPriceRow;
  const formationsRel = row.formations;
  const slug = Array.isArray(formationsRel)
    ? formationsRel[0].slug
    : formationsRel.slug;

  return {
    formationSlug: slug,
    formationId: row.formation_id,
    pack: row.pack as PackSlug,
    priceCents: row.price_cents,
    compareAtCents: row.compare_at_cents,
    active: row.active,
    notes: row.notes,
    updatedAt: row.updated_at,
  };
}

// ---------------------------------------------------------------------
// 4. Format d'affichage
// ---------------------------------------------------------------------

/**
 * Renvoie un prix formaté pour affichage : "6 000 €".
 * Délègue à `lib/packs.ts` pour utiliser la même fonction.
 *
 * Wrapper ici pour permettre l'import depuis `pricing-server`.
 */
export function formatPriceEuros(cents: number): string {
  return fmtEuros(cents);
}
