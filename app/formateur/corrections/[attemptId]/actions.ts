"use server";
import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

async function ensureTrainerOrStaff() {
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
  const allowed = ["trainer", "admin", "super_admin"];
  if (!profile?.role || !allowed.includes(profile.role)) {
    throw new Error("Réservé aux formateurs et au personnel");
  }
  return { supabase, userId: user.id };
}

/** Note une réponse QR (RPC SQL). */
export async function gradeQrResponse(
  responseId: string,
  score: number,
  comment?: string | null
) {
  const { supabase } = await ensureTrainerOrStaff();
  const { error } = await supabase.rpc("grade_qr_response", {
    p_response: responseId,
    p_score: score,
    p_comment: comment ?? null,
  });
  if (error) throw new Error(error.message);
  revalidatePath("/formateur/corrections");
}

/** Finalise la correction d'une copie (calcul note totale + notif stagiaire). */
export async function finalizeQuizGrading(
  attemptId: string,
  globalComment?: string | null
) {
  const { supabase } = await ensureTrainerOrStaff();
  const { error } = await supabase.rpc("finalize_quiz_grading", {
    p_attempt: attemptId,
    p_global_comment: globalComment ?? null,
  });
  if (error) throw new Error(error.message);
  revalidatePath("/formateur/corrections");
  revalidatePath(`/formateur/corrections/${attemptId}`);
}
