"use server";

import { requireAdmin, auditLog } from "@/lib/admin-guard";
import { createAdminClient } from "@/lib/supabase/admin";
import { revalidatePath } from "next/cache";

/** Relance un stagiaire en attente de signature (notification in-app). */
export async function relanceSignature(studentId: string) {
  await requireAdmin();
  const admin = createAdminClient();
  const { error } = await admin.from("notifications").insert({
    user_id: studentId,
    title: "Documents à signer",
    body: "Merci de lire et de signer vos documents obligatoires pour accéder à votre formation.",
    type: "system",
    link_url: "/signature-obligatoire",
  });
  if (error) return { ok: false, error: error.message };
  await auditLog("relance_signature", "profile", studentId, {});
  revalidatePath("/admin/signatures");
  return { ok: true };
}
