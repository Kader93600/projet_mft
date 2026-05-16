"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import { headers } from "next/headers";
import { trackServerEvent } from "@/lib/analytics";

// ---------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------

async function requireUser() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");
  return { supabase, userId: user.id };
}

async function getSession(sessionId: string) {
  const supabase = createClient();
  const { data } = await supabase
    .from("live_sessions")
    .select(
      "id, formation_id, status, start_at, end_at, max_participants, kind"
    )
    .eq("id", sessionId)
    .single();
  if (!data) throw new Error("Session introuvable");
  return data;
}

// ---------------------------------------------------------------------
// Auto-inscription stagiaire
// ---------------------------------------------------------------------

export async function selfRegister(sessionId: string) {
  const { supabase, userId } = await requireUser();
  const session = await getSession(sessionId);

  // 1) Pack Premium requis
  const { data: hasPremium } = await supabase.rpc(
    "user_has_premium_for_formation",
    { p_user_id: userId, p_formation_id: session.formation_id }
  );
  if (!hasPremium) {
    throw new Error(
      "Le pack Premium est requis pour vous inscrire à une session"
    );
  }

  // 2) Statut de la session
  if (session.status === "cancelled") {
    throw new Error("Cette session a été annulée");
  }
  if (session.status === "completed") {
    throw new Error("Cette session est terminée");
  }
  if (new Date(session.end_at).getTime() < Date.now()) {
    throw new Error("Cette session est passée");
  }

  // 3) Capacité
  if (session.max_participants) {
    const { count } = await supabase
      .from("session_enrollments")
      .select("*", { count: "exact", head: true })
      .eq("session_id", sessionId)
      .in("status", ["invited", "confirmed"]);
    if ((count ?? 0) >= session.max_participants) {
      throw new Error("Cette session est complète");
    }
  }

  // 4) Inscription (upsert pour gérer le cas re-inscription après cancel)
  const { error } = await supabase.from("session_enrollments").upsert(
    {
      session_id: sessionId,
      user_id: userId,
      status: "confirmed",
      registered_at: new Date().toISOString(),
      cancelled_at: null,
      cancellation_reason: null,
    },
    { onConflict: "session_id,user_id" }
  );
  if (error) throw new Error(error.message);

  revalidatePath("/sessions");
  revalidatePath(`/sessions/${sessionId}`);
}

export async function selfUnregister(
  sessionId: string,
  reason?: string
) {
  const { supabase, userId } = await requireUser();
  const session = await getSession(sessionId);

  // Pas de désinscription après le début (à modérer)
  if (new Date(session.start_at).getTime() < Date.now()) {
    throw new Error(
      "Impossible de se désinscrire après le début de la session"
    );
  }

  const { error } = await supabase
    .from("session_enrollments")
    .update({
      status: "cancelled",
      cancelled_at: new Date().toISOString(),
      cancellation_reason: reason?.trim() || "Désinscription stagiaire",
    })
    .eq("session_id", sessionId)
    .eq("user_id", userId);
  if (error) throw new Error(error.message);

  revalidatePath("/sessions");
  revalidatePath(`/sessions/${sessionId}`);
}

// ---------------------------------------------------------------------
// Émargement stagiaire (auto-signature)
// ---------------------------------------------------------------------

/**
 * Ouvre l'émargement 30 minutes avant le début et jusqu'à 24h après la
 * fin (souplesse pour les sessions multi-séances et les rattrapages
 * justifiés ; le formateur peut toujours invalider).
 */
function canSignWindow(start: string, end: string): boolean {
  const now = Date.now();
  const s = new Date(start).getTime() - 30 * 60_000;
  const e = new Date(end).getTime() + 24 * 3600_000;
  return now >= s && now <= e;
}

export async function signAttendance(
  sessionId: string,
  method: "online_click" | "qr_code" | "signature_pad" = "online_click",
  signatureStoragePath?: string | null
) {
  const { supabase, userId } = await requireUser();
  const session = await getSession(sessionId);

  // 1) Statut
  if (session.status === "cancelled") {
    throw new Error("Cette session a été annulée");
  }

  // 2) Fenêtre temporelle
  if (!canSignWindow(session.start_at, session.end_at)) {
    throw new Error(
      "L'émargement n'est pas ouvert pour cette session (ouvre 30min avant le début)"
    );
  }

  // 3) Inscrit ?
  const { data: enroll } = await supabase
    .from("session_enrollments")
    .select("status")
    .eq("session_id", sessionId)
    .eq("user_id", userId)
    .maybeSingle();
  if (!enroll || !["confirmed", "invited"].includes(enroll.status)) {
    throw new Error("Vous n'êtes pas inscrit à cette session");
  }

  // 4) Audit IP / UA (Qualiopi)
  const h = headers();
  const ip =
    h.get("x-forwarded-for")?.split(",")[0]?.trim() ||
    h.get("x-real-ip") ||
    null;
  const ua = h.get("user-agent") ?? null;

  // 5) Émargement (upsert idempotent)
  const { error } = await supabase.from("session_attendance").upsert(
    {
      session_id: sessionId,
      user_id: userId,
      method,
      signed_at: new Date().toISOString(),
      ip_address: ip,
      user_agent: ua,
      signature_storage_path: signatureStoragePath ?? null,
    },
    { onConflict: "session_id,user_id" }
  );
  if (error) throw new Error(error.message);

  // 6) Met à jour la session si pas encore en cours
  if (session.status === "scheduled") {
    await supabase
      .from("live_sessions")
      .update({ status: "in_progress" })
      .eq("id", sessionId);
  }

  // 7) Analytics : émargement
  await trackServerEvent({
    userId,
    event: "session_signed",
    props: {
      session_id: sessionId,
      session_kind: session.kind,
      method,
    },
  });

  revalidatePath("/sessions");
  revalidatePath(`/sessions/${sessionId}`);
}
