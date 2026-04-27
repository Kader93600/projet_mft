"use server";
import { requireAdmin, validate, auditLog } from "@/lib/admin-guard";
import { formationSettingsSchema } from "@/lib/validations";
import { revalidatePath } from "next/cache";

export async function updateFormationSettings(raw: unknown) {
  const { supabase, admin } = await requireAdmin();
  const data = validate(formationSettingsSchema, raw);
  const { error } = await supabase
    .from("formation_settings")
    .update({ ...data, updated_at: new Date().toISOString(), updated_by: admin.id })
    .eq("id", true);
  if (error) throw new Error(error.message);
  await auditLog("update_formation_settings", "formation_settings", "singleton");
  revalidatePath("/admin/settings/formation");
  return { ok: true };
}
