"use server";
import { isStaff } from "@/lib/permissions";
import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

async function ensureAdmin() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");
  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .single();
  if (!isStaff(profile?.role)) throw new Error("Réservé aux administrateurs");
  return { supabase, user };
}

export async function setDeletionStatus(
  id: string,
  status: "approved" | "refused" | "executed",
  note?: string | null
) {
  const { supabase } = await ensureAdmin();
  const { error } = await supabase
    .from("deletion_requests")
    .update({
      status,
      admin_note: note ?? null,
      resolved_at: status === "executed" ? new Date().toISOString() : null,
    })
    .eq("id", id);
  if (error) throw new Error(error.message);
  revalidatePath("/admin/rgpd");
}

export async function anonymizeUser(userId: string) {
  const { supabase } = await ensureAdmin();
  const { error } = await supabase.rpc("anonymize_user", { p_user: userId });
  if (error) throw new Error(error.message);
  revalidatePath("/admin/rgpd");
}
