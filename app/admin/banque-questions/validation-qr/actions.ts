"use server";
import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import { isStaff } from "@/lib/permissions";

async function ensureStaff() {
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
  if (!isStaff(profile?.role)) throw new Error("Réservé au personnel");
  return { supabase, userId: user.id };
}

/**
 * Met à jour une QR : énoncé, tags, réponse-modèle, barème, score max,
 * difficulté. Persiste en base via Supabase + trace l'auteur de la
 * dernière modification (reformulated_at / reformulated_by).
 */
export async function updateQrMetadata(
  questionId: string,
  payload: {
    statement?: string;
    tags?: string[];
    expected_answer?: string | null;
    scoring_grid?: string | null;
    max_score?: number;
    difficulty?: string;
  }
) {
  const { supabase, userId } = await ensureStaff();

  // Validation côté serveur : statement non vide si fourni
  if (payload.statement !== undefined && !payload.statement.trim()) {
    throw new Error("L'énoncé ne peut pas être vide.");
  }

  const { error } = await supabase
    .from("question_bank")
    .update({
      ...payload,
      reformulated_at: new Date().toISOString(),
      reformulated_by: userId,
    })
    .eq("id", questionId)
    .eq("type", "qr");
  if (error) throw new Error(error.message);
  revalidatePath("/admin/banque-questions/validation-qr");
  revalidatePath("/admin/banque-questions/liste");
}

/** Active une QR. */
export async function activateQr(questionId: string) {
  const { supabase } = await ensureStaff();
  const { error } = await supabase
    .from("question_bank")
    .update({ active: true })
    .eq("id", questionId)
    .eq("type", "qr");
  if (error) throw new Error(error.message);
  revalidatePath("/admin/banque-questions/validation-qr");
  revalidatePath("/admin/banque-questions");
}

/** Active TOUTES les QR inactives d'une formation en lot. */
export async function activateAllQrsForFormation(formationSlug: string) {
  const { supabase } = await ensureStaff();
  const { data: f } = await supabase
    .from("formations")
    .select("id")
    .eq("slug", formationSlug)
    .single();
  if (!f) throw new Error("Formation introuvable");
  const { error, count } = await supabase
    .from("question_bank")
    .update({ active: true }, { count: "exact" })
    .eq("formation_id", f.id)
    .eq("type", "qr")
    .eq("active", false);
  if (error) throw new Error(error.message);
  revalidatePath("/admin/banque-questions/validation-qr");
  revalidatePath("/admin/banque-questions");
  return count ?? 0;
}

/** Désactive une QR. */
export async function deactivateQr(questionId: string) {
  const { supabase } = await ensureStaff();
  const { error } = await supabase
    .from("question_bank")
    .update({ active: false })
    .eq("id", questionId);
  if (error) throw new Error(error.message);
  revalidatePath("/admin/banque-questions/validation-qr");
}
