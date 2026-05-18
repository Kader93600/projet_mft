// =====================================================================
// Helper côté serveur pour le portail financeur.
//
// Un utilisateur "financeur" est un compte profiles dont l'id est
// référencé par funders.portal_user_id. Le portail /financeur est
// gated par cette association.
//
// Admins ont accès aussi (via override). Trainers : non.
// =====================================================================

import { createClient } from "@/lib/supabase/server";

export interface FunderAccess {
  allowed: boolean;
  funder_id: string | null;
  funder_name: string | null;
  funder_kind: string | null;
  is_admin: boolean;
  reason: string | null;
}

export async function getFunderAccess(): Promise<FunderAccess> {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return {
      allowed: false,
      funder_id: null,
      funder_name: null,
      funder_kind: null,
      is_admin: false,
      reason: "unauthenticated",
    };
  }

  // Admin override
  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();
  const isAdmin =
    profile?.role === "admin" || profile?.role === "super_admin";

  // Funder rattaché à ce user ?
  const { data: funder } = await supabase
    .from("funders")
    .select("id, name, kind")
    .eq("portal_user_id", user.id)
    .maybeSingle();

  if (funder) {
    return {
      allowed: true,
      funder_id: funder.id,
      funder_name: funder.name,
      funder_kind: funder.kind,
      is_admin: isAdmin,
      reason: null,
    };
  }

  if (isAdmin) {
    return {
      allowed: true,
      funder_id: null,
      funder_name: "Admin (vue globale)",
      funder_kind: null,
      is_admin: true,
      reason: null,
    };
  }

  return {
    allowed: false,
    funder_id: null,
    funder_name: null,
    funder_kind: null,
    is_admin: false,
    reason:
      "Votre compte n'est pas rattaché à un financeur. Contactez votre administrateur MFT.",
  };
}
