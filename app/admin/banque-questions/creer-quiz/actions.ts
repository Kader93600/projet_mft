"use server";
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
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
 * Crée un quiz statique depuis la banque (sélection manuelle).
 * Le quiz est créé puis lié aux questions via quiz_question_bank.
 */
export async function createStaticQuiz(formData: FormData) {
  const { supabase } = await ensureStaff();
  const title = String(formData.get("title") ?? "").trim();
  const description = (formData.get("description") as string) || null;
  const formationSlug = String(formData.get("formation_slug") ?? "").trim();
  const isMockExam = formData.get("is_mock_exam") === "on";
  const timeLimitMin = parseInt(
    String(formData.get("time_limit_min") ?? "0"),
    10
  );
  const passThreshold = parseInt(
    String(formData.get("pass_threshold") ?? "70"),
    10
  );
  const questionIds = formData.getAll("question_ids[]") as string[];

  if (!title || !formationSlug || questionIds.length === 0) {
    throw new Error(
      "Titre, formation et au moins une question sont obligatoires"
    );
  }

  // Création du quiz
  const { data: quiz, error: quizErr } = await supabase
    .from("quizzes")
    .insert({
      title,
      description,
      type: isMockExam ? "examen" : "entrainement",
      is_mock_exam: isMockExam,
      time_limit_s: timeLimitMin > 0 ? timeLimitMin * 60 : null,
      pass_threshold: passThreshold,
      generation_mode: "static",
    } as any)
    .select()
    .single();
  if (quizErr) throw new Error(quizErr.message);

  // Lien quiz ↔ questions
  const links = questionIds.map((qid, idx) => ({
    quiz_id: quiz.id,
    question_id: qid,
    display_order: idx,
  }));
  const { error: linkErr } = await supabase
    .from("quiz_question_bank")
    .insert(links);
  if (linkErr) throw new Error(linkErr.message);

  // Lien quiz ↔ formation
  const { data: formation } = await supabase
    .from("formations")
    .select("id")
    .eq("slug", formationSlug)
    .single();
  if (formation) {
    await supabase.from("formation_quizzes").insert({
      quiz_id: quiz.id,
      formation_id: formation.id,
      is_mock_exam: isMockExam,
    } as any);
  }

  revalidatePath("/admin/quizzes");
  redirect(`/admin/quizzes/${quiz.id}`);
}

/**
 * Crée un quiz "dynamique" : la sélection se fait au moment du démarrage
 * via l'RPC generate_random_exam (sur les filtres stockés).
 */
export async function createRandomQuiz(formData: FormData) {
  const { supabase } = await ensureStaff();
  const title = String(formData.get("title") ?? "").trim();
  const description = (formData.get("description") as string) || null;
  const formationSlug = String(formData.get("formation_slug") ?? "").trim();
  const qcmCount = parseInt(String(formData.get("qcm_count") ?? "30"), 10);
  const qrCount = parseInt(String(formData.get("qr_count") ?? "0"), 10);
  const isMockExam = formData.get("is_mock_exam") === "on";
  const timeLimitMin = parseInt(
    String(formData.get("time_limit_min") ?? "0"),
    10
  );
  const passThreshold = parseInt(
    String(formData.get("pass_threshold") ?? "70"),
    10
  );
  const difficulties = formData.getAll("difficulties[]") as string[];

  if (!title || !formationSlug) {
    throw new Error("Titre et formation obligatoires");
  }

  const bankFilters = {
    formation_slug: formationSlug,
    qcm_count: qcmCount,
    qr_count: qrCount,
    difficulties: difficulties.length > 0 ? difficulties : null,
  };

  const { data: quiz, error } = await supabase
    .from("quizzes")
    .insert({
      title,
      description,
      type: isMockExam ? "examen" : "entrainement",
      is_mock_exam: isMockExam,
      time_limit_s: timeLimitMin > 0 ? timeLimitMin * 60 : null,
      pass_threshold: passThreshold,
      generation_mode: "random_from_bank",
      bank_filters: bankFilters,
      requires_manual_grading: qrCount > 0,
    } as any)
    .select()
    .single();
  if (error) throw new Error(error.message);

  // Lien formation
  const { data: formation } = await supabase
    .from("formations")
    .select("id")
    .eq("slug", formationSlug)
    .single();
  if (formation) {
    await supabase.from("formation_quizzes").insert({
      quiz_id: quiz.id,
      formation_id: formation.id,
      is_mock_exam: isMockExam,
    } as any);
  }

  revalidatePath("/admin/quizzes");
  redirect(`/admin/quizzes/${quiz.id}`);
}
