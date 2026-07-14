"use server";
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { isStaff } from "@/lib/permissions";
import type { Tables, TablesInsert } from "@/lib/database.types";

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
  const quizPayload: TablesInsert<"quizzes"> = {
    title,
    description,
    type: isMockExam ? "examen" : "entrainement",
    is_mock_exam: isMockExam,
    time_limit_s: timeLimitMin > 0 ? timeLimitMin * 60 : null,
    pass_threshold: passThreshold,
    generation_mode: "static",
  };
  const { data: quizRow, error: quizErr } = await supabase
    .from("quizzes")
    .insert(quizPayload)
    .select()
    .single();
  if (quizErr) throw new Error(quizErr.message);
  // `.single()` sans erreur ⇒ ligne présente.
  const quiz: Pick<Tables<"quizzes">, "id"> = quizRow;

  // Lien quiz ↔ questions
  const links: TablesInsert<"quiz_question_bank">[] = questionIds.map(
    (qid, idx) => ({
      quiz_id: quiz.id,
      question_id: qid,
      display_order: idx,
    })
  );
  const { error: linkErr } = await supabase
    .from("quiz_question_bank")
    .insert(links);
  if (linkErr) throw new Error(linkErr.message);

  // Lien quiz ↔ formation
  const { data: formationRow } = await supabase
    .from("formations")
    .select("id")
    .eq("slug", formationSlug)
    .single();
  const formation: Pick<Tables<"formations">, "id"> | null = formationRow;
  if (formation) {
    const link: TablesInsert<"formation_quizzes"> = {
      quiz_id: quiz.id,
      formation_id: formation.id,
      is_mock_exam: isMockExam,
    };
    await supabase.from("formation_quizzes").insert(link);
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

  const quizPayload: TablesInsert<"quizzes"> = {
    title,
    description,
    type: isMockExam ? "examen" : "entrainement",
    is_mock_exam: isMockExam,
    time_limit_s: timeLimitMin > 0 ? timeLimitMin * 60 : null,
    pass_threshold: passThreshold,
    generation_mode: "random_from_bank",
    bank_filters: bankFilters,
    requires_manual_grading: qrCount > 0,
  };
  const { data: quizRow, error } = await supabase
    .from("quizzes")
    .insert(quizPayload)
    .select()
    .single();
  if (error) throw new Error(error.message);
  // `.single()` sans erreur ⇒ ligne présente.
  const quiz: Pick<Tables<"quizzes">, "id"> = quizRow;

  // Lien formation
  const { data: formationRow } = await supabase
    .from("formations")
    .select("id")
    .eq("slug", formationSlug)
    .single();
  const formation: Pick<Tables<"formations">, "id"> | null = formationRow;
  if (formation) {
    const link: TablesInsert<"formation_quizzes"> = {
      quiz_id: quiz.id,
      formation_id: formation.id,
      is_mock_exam: isMockExam,
    };
    await supabase.from("formation_quizzes").insert(link);
  }

  revalidatePath("/admin/quizzes");
  redirect(`/admin/quizzes/${quiz.id}`);
}
