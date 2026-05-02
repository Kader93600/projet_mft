"use server";
import { requireAdmin, validate, auditLog } from "@/lib/admin-guard";
import { formationSettingsSchema } from "@/lib/validations";
import { revalidatePath } from "next/cache";

export async function updateFormationSettings(raw: unknown) {
  const { supabase, admin } = await requireAdmin();
  const data = validate(formationSettingsSchema, raw);
  const { formation_slug, ...payload } = data;

  // Résoudre le formation_id depuis le slug
  const { data: f, error: fErr } = await supabase
    .from("formations")
    .select("id, slug")
    .eq("slug", formation_slug)
    .maybeSingle();
  if (fErr) throw new Error(fErr.message);
  if (!f) throw new Error(`Formation "${formation_slug}" introuvable`);

  // Upsert : crée la ligne si elle n'existe pas, met à jour sinon.
  // PK = formation_id (cf. supabase/formation_settings_multi.sql).
  const { error } = await supabase.from("formation_settings").upsert(
    {
      ...payload,
      formation_id: f.id,
      updated_at: new Date().toISOString(),
      updated_by: admin.id,
    },
    { onConflict: "formation_id" }
  );
  if (error) throw new Error(error.message);

  await auditLog("update_formation_settings", "formation_settings", f.id, {
    formation_slug: f.slug,
  });
  revalidatePath("/admin/settings/formation");
  return { ok: true, formation_slug: f.slug };
}
