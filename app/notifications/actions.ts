"use server";
import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

export async function markAllRead() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return;
  await supabase.rpc("mark_notifications_read", { p_ids: null });
  revalidatePath("/notifications");
}

export async function markOneRead(id: string) {
  if (!/^[0-9a-f-]{36}$/i.test(id)) return;
  const supabase = createClient();
  await supabase.rpc("mark_notifications_read", { p_ids: [id] });
  revalidatePath("/notifications");
}
