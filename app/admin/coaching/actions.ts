"use server";
import { requireAdmin, validate, auditLog } from "@/lib/admin-guard";
import { z } from "zod";
import { revalidatePath } from "next/cache";
import {
  coachingSessionSchema,
  coachingNoteSchema,
  uuid,
} from "@/lib/validations";

const updateSessionSchema = coachingSessionSchema.partial().extend({
  id: uuid,
});
const updateNoteSchema = coachingNoteSchema.partial().extend({ id: uuid });

// ---------- Référent ----------
export async function assignReferent(userId: string, trainerId: string | null) {
  // service_role pour bypass RLS (les RLS sur profiles bloquent les
  // UPDATE par admin/super_admin dans certains contextes — même
  // symptôme qu'on a vu sur enrollments).
  const { service } = await requireAdmin();
  validate(uuid, userId);
  if (trainerId) validate(uuid, trainerId);
  const { error } = await service
    .from("profiles")
    .update({ referent_id: trainerId })
    .eq("id", userId);
  if (error) throw new Error(error.message);
  await auditLog("assign_referent", "profile", userId, { trainerId });
  revalidatePath(`/admin/users/${userId}`);
  revalidatePath("/admin/coaching");
  return { ok: true };
}

// ---------- Sessions ----------
export async function createCoachingSession(raw: unknown) {
  const { supabase } = await requireAdmin();
  const data = validate(coachingSessionSchema, raw);
  const { data: row, error } = await supabase
    .from("coaching_sessions")
    .insert(data)
    .select("id")
    .single();
  if (error) throw new Error(error.message);
  await auditLog("create_coaching_session", "coaching_session", row.id);
  revalidatePath(`/admin/users/${data.user_id}`);
  revalidatePath("/admin/coaching");
  return { id: row.id };
}

export async function updateCoachingSession(raw: unknown) {
  const { supabase } = await requireAdmin();
  const data = validate(updateSessionSchema, raw);
  const { id, ...patch } = data;
  const { error } = await supabase
    .from("coaching_sessions")
    .update(patch)
    .eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("update_coaching_session", "coaching_session", id);
  revalidatePath("/admin/coaching");
  return { ok: true };
}

export async function deleteCoachingSession(id: string) {
  const { supabase } = await requireAdmin();
  validate(uuid, id);
  const { error } = await supabase
    .from("coaching_sessions")
    .delete()
    .eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("delete_coaching_session", "coaching_session", id);
  revalidatePath("/admin/coaching");
  return { ok: true };
}

// ---------- Notes ----------
export async function createCoachingNote(raw: unknown) {
  const { supabase } = await requireAdmin();
  const data = validate(coachingNoteSchema, raw);
  const { data: row, error } = await supabase
    .from("coaching_notes")
    .insert(data)
    .select("id")
    .single();
  if (error) throw new Error(error.message);
  await auditLog("create_coaching_note", "coaching_note", row.id);
  revalidatePath(`/admin/users/${data.user_id}`);
  return { id: row.id };
}

export async function updateCoachingNote(raw: unknown) {
  const { supabase } = await requireAdmin();
  const data = validate(updateNoteSchema, raw);
  const { id, ...patch } = data;
  const { error } = await supabase
    .from("coaching_notes")
    .update(patch)
    .eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("update_coaching_note", "coaching_note", id);
  revalidatePath("/admin/coaching");
  return { ok: true };
}

export async function deleteCoachingNote(id: string) {
  const { supabase } = await requireAdmin();
  validate(uuid, id);
  const { error } = await supabase
    .from("coaching_notes")
    .delete()
    .eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("delete_coaching_note", "coaching_note", id);
  revalidatePath("/admin/coaching");
  return { ok: true };
}
