"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { isStaff } from "@/lib/permissions";
import { DOC_STATUS } from "@/lib/student-documents";

async function requireStaff() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { supabase, ok: false as const };
  const { data: me } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();
  const role = (me as any)?.role;
  const ok = isStaff(role) || role === "trainer";
  return { supabase, ok };
}

export async function setDocumentStatus(
  id: string,
  status: string
): Promise<{ ok: boolean; error?: string }> {
  if (!(status in DOC_STATUS)) return { ok: false, error: "Statut invalide." };
  const { supabase, ok } = await requireStaff();
  if (!ok) return { ok: false, error: "Accès refusé." };
  const { error } = await supabase
    .from("student_documents")
    .update({ status })
    .eq("id", id);
  if (error) return { ok: false, error: "Mise à jour impossible." };
  revalidatePath("/admin/documents");
  return { ok: true };
}

export async function setDocumentNote(
  id: string,
  note: string
): Promise<{ ok: boolean; error?: string }> {
  const { supabase, ok } = await requireStaff();
  if (!ok) return { ok: false, error: "Accès refusé." };
  const { error } = await supabase
    .from("student_documents")
    .update({ admin_note: note.trim() || null })
    .eq("id", id);
  if (error) return { ok: false, error: "Enregistrement impossible." };
  revalidatePath("/admin/documents");
  return { ok: true };
}
