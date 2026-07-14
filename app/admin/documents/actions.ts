"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { sendEmail, documentStatusEmail } from "@/lib/email";
import { isStaff } from "@/lib/permissions";
import { DOC_STATUS } from "@/lib/student-documents";
import type { Tables } from "@/lib/database.types";

/** Ligne renvoyée par le `select("role")` sur `profiles`. */
type RoleRow = Pick<Tables<"profiles">, "role">;
/** Ligne renvoyée par le `select("user_id, title, admin_note")` sur `student_documents`. */
type UpdatedDocRow = Pick<
  Tables<"student_documents">,
  "user_id" | "title" | "admin_note"
>;
/** Ligne renvoyée par le `select("full_name, email")` sur `profiles`. */
type ProfileContactRow = Pick<Tables<"profiles">, "full_name" | "email">;

async function requireStaff() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { supabase, ok: false as const };
  const { data } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();
  const me = data as RoleRow | null;
  const role = me?.role;
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
  const { data, error } = await supabase
    .from("student_documents")
    .update({ status })
    .eq("id", id)
    .select("user_id, title, admin_note")
    .maybeSingle();
  const updated = data as UpdatedDocRow | null;
  if (error || !updated) return { ok: false, error: "Mise à jour impossible." };

  // Notifie le stagiaire pour les décisions (validé / refusé).
  if (status === "valide" || status === "refuse") {
    try {
      const admin = createAdminClient();
      const validated = status === "valide";
      await admin.from("notifications").insert({
        user_id: updated.user_id,
        type: "system",
        title: validated ? "Document validé" : "Document refusé",
        body: `Votre document « ${updated.title} » a été ${
          validated ? "validé" : "refusé"
        }.`,
        link_url: "/mes-documents",
      });
      const { data: profData } = await admin
        .from("profiles")
        .select("full_name, email")
        .eq("id", updated.user_id)
        .maybeSingle();
      const prof = profData as ProfileContactRow | null;
      if (prof?.email) {
        const mail = documentStatusEmail({
          studentName: prof.full_name || "",
          title: updated.title,
          status,
          adminNote: updated.admin_note,
          link: "https://www.maformationtransport.fr/mes-documents",
        });
        await sendEmail({
          to: prof.email,
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
