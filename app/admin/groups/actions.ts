"use server";
import { revalidatePath } from "next/cache";
import { requireAdmin, validate, auditLog } from "@/lib/admin-guard";
import { groupSchema, uuid } from "@/lib/validations";
import { z } from "zod";

export async function createGroup(raw: unknown) {
  const { supabase } = await requireAdmin();
  const data = validate(groupSchema, raw);
  const { data: created, error } = await supabase
    .from("groups")
    .insert(data)
    .select()
    .single();
  if (error) throw new Error(error.message);
  await auditLog("create_group", "group", created.id, { name: data.name });
  revalidatePath("/admin/groups");
  return { ok: true };
}

export async function updateGroup(id: string, raw: unknown) {
  const { supabase } = await requireAdmin();
  validate(uuid, id);
  const patch = validate(groupSchema.partial(), raw);
  const { error } = await supabase.from("groups").update(patch).eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("update_group", "group", id);
  revalidatePath("/admin/groups");
  return { ok: true };
}

export async function deleteGroup(id: string) {
  const { supabase } = await requireAdmin();
  validate(uuid, id);
  const { error } = await supabase.from("groups").delete().eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("delete_group", "group", id);
  revalidatePath("/admin/groups");
  revalidatePath("/admin/users");
  return { ok: true };
}

export async function assignUserToGroup(userId: string, groupId: string | null) {
  const { supabase } = await requireAdmin();
  validate(uuid, userId);
  if (groupId !== null) validate(uuid, groupId);
  const { error } = await supabase
    .from("profiles")
    .update({ group_id: groupId })
    .eq("id", userId);
  if (error) throw new Error(error.message);
  await auditLog("assign_group", "profile", userId, { group_id: groupId });
  revalidatePath("/admin/groups");
  revalidatePath("/admin/users");
  revalidatePath(`/admin/users/${userId}`);
  return { ok: true };
}

export async function bulkAssignUsers(userIds: string[], groupId: string | null) {
  const { supabase } = await requireAdmin();
  const ids = validate(z.array(uuid).min(1).max(500), userIds);
  if (groupId !== null) validate(uuid, groupId);
  const { error } = await supabase
    .from("profiles")
    .update({ group_id: groupId })
    .in("id", ids);
  if (error) throw new Error(error.message);
  await auditLog("bulk_assign_group", "group", groupId ?? "none", {
    count: ids.length,
  });
  revalidatePath("/admin/groups");
  revalidatePath("/admin/users");
  return { ok: true };
}
