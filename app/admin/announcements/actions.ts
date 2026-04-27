"use server";
import { requireAdmin, validate, auditLog } from "@/lib/admin-guard";
import { z } from "zod";
import { revalidatePath } from "next/cache";

const createSchema = z.object({
  title: z.string().trim().min(1).max(200),
  body_md: z.string().max(20_000).default(""),
  audience: z.enum(["all", "group"]).default("all"),
  group_id: z.string().uuid().nullable().optional(),
  pinned: z.boolean().default(false),
});

const updateSchema = createSchema.extend({ id: z.string().uuid() });

export async function createAnnouncement(raw: unknown) {
  const { supabase, admin } = await requireAdmin();
  const data = validate(createSchema, raw);
  const payload: any = { ...data, created_by: admin.id };
  if (payload.audience === "all") payload.group_id = null;
  const { data: row, error } = await supabase
    .from("announcements")
    .insert(payload)
    .select("id")
    .single();
  if (error) throw new Error(error.message);
  await auditLog("create_announcement", "announcement", row.id);
  revalidatePath("/admin/announcements");
  return { id: row.id };
}

export async function updateAnnouncement(raw: unknown) {
  const { supabase } = await requireAdmin();
  const data = validate(updateSchema, raw);
  const { id, ...patch } = data;
  if (patch.audience === "all") patch.group_id = null;
  const { error } = await supabase.from("announcements").update(patch).eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("update_announcement", "announcement", id);
  revalidatePath("/admin/announcements");
  return { ok: true };
}

export async function publishAnnouncement(id: string) {
  const { supabase } = await requireAdmin();
  if (!/^[0-9a-f-]{36}$/i.test(id)) throw new Error("id invalide");
  const { data: count, error } = await supabase.rpc("publish_announcement", { p_id: id });
  if (error) throw new Error(error.message);
  await auditLog("publish_announcement", "announcement", id, { notified: count });
  revalidatePath("/admin/announcements");
  return { notified: count };
}

export async function deleteAnnouncement(id: string) {
  const { supabase } = await requireAdmin();
  if (!/^[0-9a-f-]{36}$/i.test(id)) throw new Error("id invalide");
  const { error } = await supabase.from("announcements").delete().eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("delete_announcement", "announcement", id);
  revalidatePath("/admin/announcements");
  return { ok: true };
}
