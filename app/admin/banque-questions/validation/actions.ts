"use server";
import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import { isStaff } from "@/lib/permissions";

async function ensureStaff() {
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
  if (!isStaff(profile?.role)) {
    throw new Error("Réservé au personnel");
  }
  return { supabase, userId: user.id };
}

/**
 * Valide un QCM : marque la bonne réponse + active la question.
 * @param questionId  UUID dans question_bank
 * @param correctChoiceId  Lettre (a/b/c/d)
 */
export async function validateQcm(
  questionId: string,
  correctChoiceId: string
) {
  const { supabase, userId } = await ensureStaff();

  // Charge la question pour modifier choices[].is_correct
  const { data: q } = await supabase
    .from("question_bank")
    .select("choices, type")
    .eq("id", questionId)
    .single();

  if (!q) throw new Error("Question introuvable");
  if (q.type !== "qcm") throw new Error("Réservé aux QCM");

  const updated = (q.choices as any[]).map((c) => ({
    ...c,
    is_correct: c.id === correctChoiceId,
  }));

  if (!updated.some((c) => c.is_correct)) {
    throw new Error("Choix introuvable dans la liste");
  }

  const { error } = await supabase
    .from("question_bank")
    .update({
      choices: updated,
      active: true,
      reformulated_at: new Date().toISOString(),
      reformulated_by: userId,
    })
    .eq("id", questionId);

  if (error) throw new Error(error.message);
  revalidatePath("/admin/banque-questions");
  revalidatePath("/admin/banque-questions/validation");
}

/** Réactive une QR (les QR n'ont pas de bonne réponse à cocher). */
export async function activateQr(questionId: string) {
  const { supabase } = await ensureStaff();
  const { error } = await supabase
    .from("question_bank")
    .update({ active: true })
    .eq("id", questionId)
    .eq("type", "qr");
  if (error) throw new Error(error.message);
  revalidatePath("/admin/banque-questions");
}

/** Désactive une question (l'écarte de la circulation). */
export async function deactivateQuestion(questionId: string) {
  const { supabase } = await ensureStaff();
  const { error } = await supabase
    .from("question_bank")
    .update({ active: false })
    .eq("id", questionId);
  if (error) throw new Error(error.message);
  revalidatePath("/admin/banque-questions");
  revalidatePath("/admin/banque-questions/validation");
}
