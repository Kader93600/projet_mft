"use server";

import { requireAdmin } from "@/lib/admin-guard";
import { revalidatePath } from "next/cache";

/**
 * Met à jour le branding d'une organisation (logo + couleur primaire),
 * base du "multi-centre" : un organisme cliente personnalise l'espace.
 *
 * Sécurité :
 *   - requireAdmin (admin/super_admin uniquement),
 *   - logo_url restreint à https:// (le logo est rendu en <img src>,
 *     on bloque javascript:/data: pour éviter tout vecteur XSS),
 *   - primary_color validée en hex (#RGB / #RRGGBB).
 */
export async function updateOrgBranding(orgId: string, formData: FormData) {
  const { service } = await requireAdmin();

  const logoUrl = String(formData.get("logo_url") ?? "").trim();
  const primaryColor = String(formData.get("primary_color") ?? "").trim();

  if (primaryColor && !/^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/.test(primaryColor)) {
    return {
      ok: false as const,
      error: "Couleur invalide (format attendu : #RRGGBB).",
    };
  }
  if (logoUrl && !/^https:\/\/\S+$/i.test(logoUrl)) {
    return {
      ok: false as const,
      error: "L'URL du logo doit commencer par https://",
    };
  }

  const { error } = await service
    .from("organizations")
    .update({
      logo_url: logoUrl || null,
      primary_color: primaryColor || null,
    })
    .eq("id", orgId);

  if (error) return { ok: false as const, error: error.message };

  revalidatePath(`/admin/organizations/${orgId}`);
  return { ok: true as const };
}
