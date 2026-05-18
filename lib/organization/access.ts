// =====================================================================
// Helper côté serveur pour le portail entreprise (multi-tenant).
//
// Détecte l'organisation du user courant + son rôle.
// =====================================================================

import { createClient } from "@/lib/supabase/server";

export type OrgRole = "org_admin" | "org_viewer" | "org_learner";

export interface OrganizationAccess {
  allowed: boolean;
  organization_id: string | null;
  organization_name: string | null;
  organization_slug: string | null;
  role: OrgRole | null;
  is_admin_mft: boolean;       // admin global MFT, override total
  is_org_admin: boolean;       // org_admin OR is_admin_mft
  is_org_viewer: boolean;      // org_viewer / admin / org_admin
  reason: string | null;
}

export async function getOrganizationAccess(): Promise<OrganizationAccess> {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return {
      allowed: false,
      organization_id: null,
      organization_name: null,
      organization_slug: null,
      role: null,
      is_admin_mft: false,
      is_org_admin: false,
      is_org_viewer: false,
      reason: "unauthenticated",
    };
  }

  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();
  const isAdminMft =
    profile?.role === "admin" || profile?.role === "super_admin";

  const { data: orgRow } = await supabase
    .rpc("my_organization")
    .single();

  const org = orgRow as
    | {
        organization_id: string;
        organization_name: string;
        organization_slug: string;
        role: OrgRole;
        joined_at: string;
      }
    | null;

  if (!org) {
    if (isAdminMft) {
      return {
        allowed: true,
        organization_id: null,
        organization_name: "Admin MFT (vue globale)",
        organization_slug: null,
        role: null,
        is_admin_mft: true,
        is_org_admin: true,
        is_org_viewer: true,
        reason: null,
      };
    }
    return {
      allowed: false,
      organization_id: null,
      organization_name: null,
      organization_slug: null,
      role: null,
      is_admin_mft: false,
      is_org_admin: false,
      is_org_viewer: false,
      reason: "no_organization",
    };
  }

  return {
    allowed: true,
    organization_id: org.organization_id,
    organization_name: org.organization_name,
    organization_slug: org.organization_slug,
    role: org.role,
    is_admin_mft: isAdminMft,
    is_org_admin: isAdminMft || org.role === "org_admin",
    is_org_viewer:
      isAdminMft || org.role === "org_admin" || org.role === "org_viewer",
    reason: null,
  };
}
