"use server";
import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

const validIds = (ids: string[]): string[] =>
  Array.from(new Set(ids)).filter((id) => UUID_RE.test(id));

/**
 * Marque toutes les notifications non lues de l'utilisateur courant
 * comme lues. Idempotent côté SQL.
 */
export async function markAllRead() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return;
  await supabase.rpc("mark_notifications_read", { p_ids: null });
  revalidatePath("/notifications");
}

/**
 * Marque une notification précise comme lue (utilisée au clic sur un item).
 */
export async function markOneRead(id: string) {
  if (!UUID_RE.test(id)) return;
  const supabase = createClient();
  await supabase.rpc("mark_notifications_read", { p_ids: [id] });
  revalidatePath("/notifications");
}

/**
 * Marque plusieurs notifications comme lues (bulk).
 */
export async function markManyRead(ids: string[]) {
  const safe = validIds(ids);
  if (safe.length === 0) return;
  const supabase = createClient();
  await supabase.rpc("mark_notifications_read", { p_ids: safe });
  revalidatePath("/notifications");
}

/**
 * Supprime une notification. Le RPC vérifie déjà l'ownership en SQL,
 * mais on revalide la regex côté serveur pour éviter les requêtes
 * malformées.
 */
export async function deleteOne(id: string) {
  if (!UUID_RE.test(id)) return;
  const supabase = createClient();
  await supabase.rpc("delete_notifications", { p_ids: [id] });
  revalidatePath("/notifications");
}

/**
 * Supprime plusieurs notifications (bulk).
 */
export async function deleteMany(ids: string[]) {
  const safe = validIds(ids);
  if (safe.length === 0) return;
  const supabase = createClient();
  await supabase.rpc("delete_notifications", { p_ids: safe });
  revalidatePath("/notifications");
}

/**
 * Vide la boîte de réception de l'utilisateur courant.
 */
export async function deleteAll() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return;
  await supabase.rpc("delete_notifications", { p_ids: null });
  revalidatePath("/notifications");
}
