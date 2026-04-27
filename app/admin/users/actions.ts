"use server";
import { revalidatePath } from "next/cache";
import { requireAdmin, validate, auditLog } from "@/lib/admin-guard";
import { updateProfileSchema, uuid } from "@/lib/validations";

export async function updateUserProfile(userId: string, raw: unknown) {
  const { supabase, admin } = await requireAdmin();
  validate(uuid, userId);
  const patch = validate(updateProfileSchema, raw);

  // Protection anti auto-rétrogradation : un admin ne peut pas se retirer son
  // propre rôle admin (éviter de se verrouiller hors de l'interface)
  if (userId === admin.id && patch.role && patch.role !== "admin") {
    throw new Error("Vous ne pouvez pas retirer votre propre rôle admin");
  }
  if (userId === admin.id && patch.disabled === true) {
    throw new Error("Vous ne pouvez pas désactiver votre propre compte");
  }

  const { error } = await supabase.from("profiles").update(patch).eq("id", userId);
  if (error) throw new Error(error.message);
  await auditLog("update_profile", "profile", userId, { fields: Object.keys(patch) });
  revalidatePath("/admin/users");
  revalidatePath(`/admin/users/${userId}`);
  return { ok: true };
}

export async function toggleUserDisabled(userId: string, disabled: boolean) {
  return updateUserProfile(userId, { disabled });
}

export async function deleteUser(userId: string) {
  const { supabase, admin } = await requireAdmin();
  validate(uuid, userId);
  if (userId === admin.id) {
    throw new Error("Vous ne pouvez pas supprimer votre propre compte");
  }
  const { error } = await supabase.from("profiles").delete().eq("id", userId);
  if (error) throw new Error(error.message);
  await auditLog("delete_user", "profile", userId);
  revalidatePath("/admin/users");
  return { ok: true };
}

export async function resetUserResults(userId: string) {
  const { supabase } = await requireAdmin();
  validate(uuid, userId);
  const { error: e1 } = await supabase.from("quiz_attempts").delete().eq("user_id", userId);
  const { error: e2 } = await supabase.from("lesson_progress").delete().eq("user_id", userId);
  if (e1 || e2) throw new Error((e1 || e2)!.message);
  await auditLog("reset_user_results", "profile", userId);
  revalidatePath(`/admin/users/${userId}`);
  return { ok: true };
}

export async function deleteAttempt(attemptId: string) {
  const { supabase } = await requireAdmin();
  validate(uuid, attemptId);
  const { error } = await supabase.from("quiz_attempts").delete().eq("id", attemptId);
  if (error) throw new Error(error.message);
  // audit fait automatiquement via trigger SQL
  revalidatePath("/admin/analytics");
  return { ok: true };
}
