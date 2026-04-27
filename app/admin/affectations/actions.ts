"use server";
import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

async function ensureAdmin() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");
  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .single();
  if (profile?.role !== "admin" && profile?.role !== "super_admin") {
    throw new Error("Réservé au personnel administrateur");
  }
  return { supabase, userId: user.id };
}

// =====================================================================
// STAGIAIRES — affectations à des formations (via enrollments)
// =====================================================================

export async function assignStudentToFormation(formData: FormData) {
  const { supabase } = await ensureAdmin();
  const studentId = String(formData.get("student_id") ?? "").trim();
  const formationSlug = String(formData.get("formation_slug") ?? "").trim();
  const fundingKind = String(formData.get("funding_kind") ?? "auto").trim();

  if (!studentId || !formationSlug) {
    throw new Error("Stagiaire et formation requis");
  }

  // Vérifier qu'il n'a pas déjà cette inscription
  const { data: existing } = await supabase
    .from("enrollments")
    .select("id")
    .eq("user_id", studentId)
    .eq("formation_slug", formationSlug)
    .maybeSingle();
  if (existing) {
    throw new Error("Ce stagiaire est déjà inscrit à cette formation");
  }

  const { error } = await supabase.from("enrollments").insert({
    user_id: studentId,
    formation_slug: formationSlug,
    funding_kind: fundingKind as any,
    status: "en_cours",
  });
  if (error) throw new Error(error.message);

  revalidatePath("/admin/affectations");
  revalidatePath("/admin/affectations/stagiaires");
}

export async function removeStudentEnrollment(enrollmentId: string) {
  const { supabase } = await ensureAdmin();
  // Sécurité : on vérifie d'abord que l'enrollment n'est pas en cours/terminé
  const { data: e } = await supabase
    .from("enrollments")
    .select("status")
    .eq("id", enrollmentId)
    .single();
  if (e && ["en_cours", "termine"].includes(e.status)) {
    throw new Error(
      "Impossible de supprimer une inscription en cours ou terminée. Marquez-la 'abandon' ou 'refuse' à la place."
    );
  }

  const { error } = await supabase
    .from("enrollments")
    .delete()
    .eq("id", enrollmentId);
  if (error) throw new Error(error.message);

  revalidatePath("/admin/affectations");
  revalidatePath("/admin/affectations/stagiaires");
}

// =====================================================================
// FORMATEURS — habilitations sur formations (trainer_formations)
// =====================================================================

export async function grantTrainerFormation(formData: FormData) {
  const { supabase, userId } = await ensureAdmin();
  const trainerId = String(formData.get("trainer_id") ?? "").trim();
  const formationId = String(formData.get("formation_id") ?? "").trim();
  const isLead = formData.get("is_lead") === "on";
  const canGrade = formData.get("can_grade") !== "off";
  const canEditContent = formData.get("can_edit_content") === "on";

  if (!trainerId || !formationId) {
    throw new Error("Formateur et formation requis");
  }

  const { error } = await supabase.from("trainer_formations").upsert(
    {
      trainer_id: trainerId,
      formation_id: formationId,
      is_lead: isLead,
      can_grade: canGrade,
      can_edit_content: canEditContent,
      granted_by: userId,
    },
    { onConflict: "trainer_id,formation_id" }
  );
  if (error) throw new Error(error.message);

  revalidatePath("/admin/affectations");
  revalidatePath("/admin/affectations/formateurs");
}

export async function revokeTrainerFormation(habilitationId: string) {
  const { supabase } = await ensureAdmin();
  const { error } = await supabase
    .from("trainer_formations")
    .delete()
    .eq("id", habilitationId);
  if (error) throw new Error(error.message);

  revalidatePath("/admin/affectations");
  revalidatePath("/admin/affectations/formateurs");
}
