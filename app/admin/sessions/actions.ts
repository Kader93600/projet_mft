"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { headers } from "next/headers";
import { isStaff } from "@/lib/permissions";

// ---------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------

/**
 * Vérifie que l'utilisateur est staff (admin/super_admin) OU formateur
 * habilité sur la formation cible. Renvoie le client + le profil.
 */
async function requireStaffOrTrainerForFormation(formationId: string) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");

  const { data: profile } = await supabase
    .from("profiles")
    .select("id, role, disabled")
    .eq("id", user.id)
    .single();
  if (!profile || profile.disabled) throw new Error("Accès refusé");

  if (isStaff(profile.role)) return { supabase, profile };

  if (profile.role === "trainer") {
    const { data: link } = await supabase
      .from("trainer_formations")
      .select("trainer_id")
      .eq("trainer_id", profile.id)
      .eq("formation_id", formationId)
      .maybeSingle();
    if (!link) {
      throw new Error("Vous n'êtes pas habilité sur cette formation");
    }
    return { supabase, profile };
  }
  throw new Error("Accès refusé");
}

/**
 * Récupère la session par id + son formation_id (pour les guards).
 */
async function getSessionFormationId(sessionId: string): Promise<string> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("live_sessions")
    .select("formation_id")
    .eq("id", sessionId)
    .single();
  if (!data) throw new Error("Session introuvable");
  return data.formation_id;
}

// ---------------------------------------------------------------------
// CRUD sessions
// ---------------------------------------------------------------------

export async function createSession(formData: FormData) {
  const formationId = String(formData.get("formation_id") ?? "").trim();
  if (!formationId) throw new Error("Formation requise");

  const { supabase, profile } = await requireStaffOrTrainerForFormation(
    formationId
  );

  const payload = {
    title: String(formData.get("title") ?? "").trim(),
    description:
      String(formData.get("description") ?? "").trim() || null,
    formation_id: formationId,
    module_id:
      String(formData.get("module_id") ?? "").trim() || null,
    kind: String(formData.get("kind") ?? "distanciel").trim(),
    start_at: String(formData.get("start_at") ?? "").trim(),
    end_at: String(formData.get("end_at") ?? "").trim(),
    location: String(formData.get("location") ?? "").trim() || null,
    meeting_provider:
      String(formData.get("meeting_provider") ?? "").trim() || null,
    meeting_url: String(formData.get("meeting_url") ?? "").trim() || null,
    meeting_password:
      String(formData.get("meeting_password") ?? "").trim() || null,
    max_participants: formData.get("max_participants")
      ? parseInt(String(formData.get("max_participants")), 10)
      : null,
    trainer_id:
      String(formData.get("trainer_id") ?? "").trim() || profile.id,
    notes_internal:
      String(formData.get("notes_internal") ?? "").trim() || null,
    created_by: profile.id,
  };

  if (!payload.title) throw new Error("Titre requis");
  if (!payload.start_at || !payload.end_at) {
    throw new Error("Dates de début et de fin requises");
  }
  if (new Date(payload.end_at) <= new Date(payload.start_at)) {
    throw new Error("La date de fin doit être après la date de début");
  }
  if (
    (payload.kind === "distanciel" || payload.kind === "hybride") &&
    !payload.meeting_url
  ) {
    throw new Error("URL de visio requise pour le distanciel/hybride");
  }
  if (
    (payload.kind === "presentiel" || payload.kind === "hybride") &&
    !payload.location
  ) {
    throw new Error("Lieu requis pour le présentiel/hybride");
  }

  const { data, error } = await supabase
    .from("live_sessions")
    .insert(payload)
    .select("id")
    .single();
  if (error) throw new Error(error.message);

  // Namespace de redirection : /admin/sessions par défaut, /formateur/sessions
  // si l'appel vient de l'espace formateur (whitelist pour éviter l'open-redirect).
  const redirectBaseRaw = String(formData.get("__redirect_base") ?? "");
  const redirectBase = ["/admin/sessions", "/formateur/sessions"].includes(
    redirectBaseRaw
  )
    ? redirectBaseRaw
    : "/admin/sessions";

  revalidatePath("/admin/sessions");
  revalidatePath("/formateur/sessions");
  revalidatePath("/sessions");
  redirect(`${redirectBase}/${data!.id}`);
}

export async function updateSession(
  sessionId: string,
  formData: FormData
) {
  const formationId = await getSessionFormationId(sessionId);
  const { supabase } = await requireStaffOrTrainerForFormation(formationId);

  const patch: Record<string, any> = {};
  const fields = [
    "title",
    "description",
    "kind",
    "start_at",
    "end_at",
    "location",
    "meeting_provider",
    "meeting_url",
    "meeting_password",
    "trainer_id",
    "notes_internal",
    "status",
  ];
  for (const f of fields) {
    if (formData.has(f)) {
      const v = String(formData.get(f) ?? "").trim();
      patch[f] = v === "" ? null : v;
    }
  }
  if (formData.has("max_participants")) {
    const raw = String(formData.get("max_participants") ?? "").trim();
    patch.max_participants = raw === "" ? null : parseInt(raw, 10);
  }

  if (
    patch.start_at &&
    patch.end_at &&
    new Date(patch.end_at) <= new Date(patch.start_at)
  ) {
    throw new Error("La date de fin doit être après la date de début");
  }

  const { error } = await supabase
    .from("live_sessions")
    .update(patch)
    .eq("id", sessionId);
  if (error) throw new Error(error.message);

  revalidatePath("/admin/sessions");
  revalidatePath(`/admin/sessions/${sessionId}`);
  revalidatePath("/formateur/sessions");
  revalidatePath(`/formateur/sessions/${sessionId}`);
  revalidatePath("/sessions");
}

export async function cancelSession(sessionId: string, reason?: string) {
  const formationId = await getSessionFormationId(sessionId);
  const { supabase } = await requireStaffOrTrainerForFormation(formationId);

  const { error } = await supabase
    .from("live_sessions")
    .update({
      status: "cancelled",
      notes_internal: reason
        ? `[Annulée] ${reason}`
        : "[Annulée]",
    })
    .eq("id", sessionId);
  if (error) throw new Error(error.message);

  revalidatePath("/admin/sessions");
  revalidatePath(`/admin/sessions/${sessionId}`);
  revalidatePath("/formateur/sessions");
  revalidatePath(`/formateur/sessions/${sessionId}`);
  revalidatePath("/sessions");
}

export async function deleteSession(
  sessionId: string,
  redirectBase: string = "/admin/sessions"
) {
  const formationId = await getSessionFormationId(sessionId);
  const { supabase } = await requireStaffOrTrainerForFormation(formationId);

  const { error } = await supabase
    .from("live_sessions")
    .delete()
    .eq("id", sessionId);
  if (error) throw new Error(error.message);

  // Whitelist anti open-redirect
  const safeBase = ["/admin/sessions", "/formateur/sessions"].includes(
    redirectBase
  )
    ? redirectBase
    : "/admin/sessions";

  revalidatePath("/admin/sessions");
  revalidatePath("/formateur/sessions");
  redirect(safeBase);
}

export async function setSessionStatus(
  sessionId: string,
  status: "scheduled" | "in_progress" | "completed" | "cancelled"
) {
  const formationId = await getSessionFormationId(sessionId);
  const { supabase } = await requireStaffOrTrainerForFormation(formationId);

  const { error } = await supabase
    .from("live_sessions")
    .update({ status })
    .eq("id", sessionId);
  if (error) throw new Error(error.message);

  revalidatePath("/admin/sessions");
  revalidatePath(`/admin/sessions/${sessionId}`);
  revalidatePath("/formateur/sessions");
  revalidatePath(`/formateur/sessions/${sessionId}`);
  revalidatePath("/sessions");
}

// ---------------------------------------------------------------------
// Enrollments (invitations / désinscriptions par le staff)
// ---------------------------------------------------------------------

export async function inviteStudent(sessionId: string, userId: string) {
  const formationId = await getSessionFormationId(sessionId);
  const { supabase } = await requireStaffOrTrainerForFormation(formationId);

  // Le stagiaire doit avoir un pack premium actif sur la formation
  const { data: hasPremium } = await supabase.rpc(
    "user_has_premium_for_formation",
    { p_user_id: userId, p_formation_id: formationId }
  );
  if (!hasPremium) {
    throw new Error(
      "Ce stagiaire n'a pas le pack Premium sur cette formation"
    );
  }

  // Vérif capacité
  const { data: session } = await supabase
    .from("live_sessions")
    .select("max_participants")
    .eq("id", sessionId)
    .single();
  if (session?.max_participants) {
    const { count } = await supabase
      .from("session_enrollments")
      .select("*", { count: "exact", head: true })
      .eq("session_id", sessionId)
      .in("status", ["invited", "confirmed"]);
    if ((count ?? 0) >= session.max_participants) {
      throw new Error("Capacité maximale atteinte");
    }
  }

  const { error } = await supabase.from("session_enrollments").upsert(
    {
      session_id: sessionId,
      user_id: userId,
      status: "confirmed",
      cancelled_at: null,
      cancellation_reason: null,
    },
    { onConflict: "session_id,user_id" }
  );
  if (error) throw new Error(error.message);

  revalidatePath(`/admin/sessions/${sessionId}`);
  revalidatePath(`/formateur/sessions/${sessionId}`);
  revalidatePath("/sessions");
}

export async function removeEnrollment(
  sessionId: string,
  userId: string,
  reason?: string
) {
  const formationId = await getSessionFormationId(sessionId);
  const { supabase } = await requireStaffOrTrainerForFormation(formationId);

  const { error } = await supabase
    .from("session_enrollments")
    .update({
      status: "cancelled",
      cancelled_at: new Date().toISOString(),
      cancellation_reason: reason ?? null,
    })
    .eq("session_id", sessionId)
    .eq("user_id", userId);
  if (error) throw new Error(error.message);

  revalidatePath(`/admin/sessions/${sessionId}`);
  revalidatePath(`/formateur/sessions/${sessionId}`);
  revalidatePath("/sessions");
}

// ---------------------------------------------------------------------
// Attendance (émargement manuel par le formateur)
// ---------------------------------------------------------------------

export async function markPresent(
  sessionId: string,
  userId: string,
  notes?: string | null
) {
  const formationId = await getSessionFormationId(sessionId);
  const { supabase, profile } = await requireStaffOrTrainerForFormation(
    formationId
  );

  const { error } = await supabase.from("session_attendance").upsert(
    {
      session_id: sessionId,
      user_id: userId,
      method: "manual",
      signed_at: new Date().toISOString(),
      validated_by: profile.id,
      validated_at: new Date().toISOString(),
      notes: notes ?? null,
    },
    { onConflict: "session_id,user_id" }
  );
  if (error) throw new Error(error.message);

  revalidatePath(`/admin/sessions/${sessionId}`);
  revalidatePath("/formateur/sessions");
  revalidatePath(`/formateur/sessions/${sessionId}`);
}

export async function markAbsent(sessionId: string, userId: string) {
  const formationId = await getSessionFormationId(sessionId);
  const { supabase } = await requireStaffOrTrainerForFormation(formationId);

  // 1) supprime l'émargement éventuel
  await supabase
    .from("session_attendance")
    .delete()
    .eq("session_id", sessionId)
    .eq("user_id", userId);

  // 2) marque l'enrollment en no_show
  const { error } = await supabase
    .from("session_enrollments")
    .update({ status: "no_show" })
    .eq("session_id", sessionId)
    .eq("user_id", userId);
  if (error) throw new Error(error.message);

  revalidatePath(`/admin/sessions/${sessionId}`);
  revalidatePath("/formateur/sessions");
  revalidatePath(`/formateur/sessions/${sessionId}`);
}

export async function validateAttendance(
  sessionId: string,
  userId: string,
  validatorNotes?: string | null
) {
  const formationId = await getSessionFormationId(sessionId);
  const { supabase, profile } = await requireStaffOrTrainerForFormation(
    formationId
  );

  const { error } = await supabase
    .from("session_attendance")
    .update({
      validated_by: profile.id,
      validated_at: new Date().toISOString(),
      notes: validatorNotes ?? null,
    })
    .eq("session_id", sessionId)
    .eq("user_id", userId);
  if (error) throw new Error(error.message);

  revalidatePath(`/admin/sessions/${sessionId}`);
  revalidatePath("/formateur/sessions");
  revalidatePath(`/formateur/sessions/${sessionId}`);
}
