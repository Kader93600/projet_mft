"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { sendEmail, documentStatusEmail } from "@/lib/email";
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
  const { data: updated, error } = await supabase
    .from("student_documents")
    .update({ status })
    .eq("id", id)
    .select("user_id, title, admin_note")
    .maybeSingle();
  if (error || !updated) return { ok: false, error: "Mise à jour impossible." };

  // Notifie le stagiaire pour les décisions (validé / refusé).
  if (status === "valide" || status === "refuse") {
    try {
      const admin = createAdminClient();
      const validated = status === "valide";
      await admin.from("notifications").insert({
        user_id: (updated as any).user_id,
        type: "system",
        title: validated ? "Document validé" : "Document refusé",
        body: `Votre document « ${(updated as any).title} » a été ${
          validated ? "validé" : "refusé"
        }.`,
        link_url: "/mes-documents",
      });
      const { data: prof } = await admin
        .from("profiles")
        .select("full_name, email")
        .eq("id", (updated as any).user_id)
        .maybeSingle();
      if ((prof as any)?.email) {
        const mail = documentStatusEmail({
          studentName: (prof as any).full_name || "",
          title: (updated as any).title,
          status,
          adminNote: (updated as any).admin_note,
          link: "https://www.maformationtransport.fr/mes-documents",
        });
        await sendEmail({
          to: (prof as any).email,
          subject: mail.subject,
          html: mail.html,
        });
      }
    } catch {
      /* notification non bloquante */
    }
  }

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
