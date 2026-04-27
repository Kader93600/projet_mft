"use server";
import { requireAdmin, validate, auditLog } from "@/lib/admin-guard";
import { z } from "zod";
import { revalidatePath } from "next/cache";
import { badgeSchema } from "@/lib/validations";

const updateSchema = badgeSchema.extend({ id: z.string().uuid() });

export async function createBadge(raw: unknown) {
  const { supabase } = await requireAdmin();
  const data = validate(badgeSchema, raw);
  const { data: row, error } = await supabase
    .from("badges")
    .insert(data)
    .select("id")
    .single();
  if (error) throw new Error(error.message);
  await auditLog("create_badge", "badge", row.id);
  revalidatePath("/admin/badges");
  revalidatePath("/reussites");
  return { id: row.id };
}

export async function updateBadge(raw: unknown) {
  const { supabase } = await requireAdmin();
  const data = validate(updateSchema, raw);
  const { id, ...patch } = data as any;
  const { error } = await supabase.from("badges").update(patch).eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("update_badge", "badge", id);
  revalidatePath("/admin/badges");
  revalidatePath("/reussites");
  return { ok: true };
}

export async function deleteBadge(id: string) {
  const { supabase } = await requireAdmin();
  if (!/^[0-9a-f-]{36}$/i.test(id)) throw new Error("id invalide");
  const { error } = await supabase.from("badges").delete().eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("delete_badge", "badge", id);
  revalidatePath("/admin/badges");
  revalidatePath("/reussites");
  return { ok: true };
}

export async function recomputeForAll() {
  const { supabase } = await requireAdmin();
  const { data: users } = await supabase
    .from("profiles")
    .select("id")
    .eq("role", "student");
  for (const u of users || []) {
    await supabase.rpc("recompute_user_achievements", { p_user: u.id });
  }
  await auditLog("recompute_achievements_all", "system", "all", {
    count: users?.length ?? 0,
  });
  revalidatePath("/admin/badges");
  return { ok: true, count: users?.length ?? 0 };
}
