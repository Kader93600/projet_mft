"use server";
import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

function num(v: FormDataEntryValue | null, min: number, max: number) {
  const n = Number(v ?? "");
  return Number.isFinite(n) && n >= min && n <= max ? Math.round(n) : null;
}

export async function submitSurvey(type: "chaud" | "froid", formData: FormData) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");

  const payload = {
    user_id: user.id,
    type,
    note_globale: num(formData.get("note_globale"), 1, 5),
    note_contenu: num(formData.get("note_contenu"), 1, 5),
    note_pedagogie: num(formData.get("note_pedagogie"), 1, 5),
    note_plateforme: num(formData.get("note_plateforme"), 1, 5),
    note_accompagnement: num(formData.get("note_accompagnement"), 1, 5),
    points_forts: ((formData.get("points_forts") as string) ?? "").trim() || null,
    points_ameliorer:
      ((formData.get("points_ameliorer") as string) ?? "").trim() || null,
    recommandation: num(formData.get("recommandation"), 0, 10),
    situation_pro:
      type === "froid"
        ? (formData.get("situation_pro") as string) || null
        : null,
    situation_detail:
      type === "froid"
        ? ((formData.get("situation_detail") as string) ?? "").trim() || null
        : null,
  };

  // Validations métier
  if (
    payload.note_globale === null ||
    payload.recommandation === null
  ) {
    throw new Error(
      "Les questions « Note globale » et « Recommandation NPS » sont obligatoires."
    );
  }

  const { error } = await supabase
    .from("satisfaction_surveys")
    .insert(payload);

  if (error) {
    if (error.code === "23505") {
      throw new Error("Vous avez déjà soumis cette enquête.");
    }
    throw new Error(error.message);
  }

  revalidatePath("/satisfaction");
}
