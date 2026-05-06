import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { QuizRunner } from "./quiz-runner";
import {
  resolveFormationFromQuiz,
  resolveFormationIdFromQuiz,
} from "@/lib/formation-resolver";

interface UnifiedQuestion {
  /** id de la question (table source : "questions" ou "question_bank") */
  id: string;
  /** "qcm" (par défaut, compat ancien runner) ou "qr" (rédigée) */
  type: "qcm" | "qr";
  /** Source pour distinguer comment soumettre la réponse */
  source: "legacy" | "bank";
  statement: string;
  explanation?: string | null;
  /** QCM : choix triés. QR : tableau vide. */
  choices: Array<{
    id: string;
    label: string;
    is_correct: boolean;
    order: number;
  }>;
  /** QR : barème max */
  max_score?: number;
}

export default async function QuizPage({ params }: { params: { id: string } }) {
  const supabase = createClient();
  const { data: quiz } = await supabase
    .from("quizzes")
    .select("*")
    .eq("id", params.id)
    .single();
  if (!quiz) notFound();

  // Gate par formation : le module de ce quiz est-il rattaché à une
  // formation où l'utilisateur est inscrit ? Sinon, 404.
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (user && quiz.module_id) {
    const { data: enrollments } = await supabase
      .from("enrollments")
      .select("formation_id")
      .eq("user_id", user.id)
      .not("formation_id", "is", null)
      .not("status", "in", "(refuse,abandon)");
    const enrolledIds = (enrollments ?? [])
      .map((e: any) => e.formation_id as string)
      .filter(Boolean);
    if (enrolledIds.length === 0) notFound();

    const { count } = await supabase
      .from("formation_modules")
      .select("module_id", { count: "exact", head: true })
      .eq("module_id", quiz.module_id)
      .in("formation_id", enrolledIds);
    if (!count) notFound();
  }

  // Source 1 : table historique "questions" (rattachée au quiz)
  const { data: legacyQuestions } = await supabase
    .from("questions")
    .select(
      "id, statement, explanation, order, choices(id, label, is_correct, order)"
    )
    .eq("quiz_id", quiz.id)
    .order("order");

  const fromLegacy: UnifiedQuestion[] = (legacyQuestions || []).map(
    (q: any) => ({
      id: q.id,
      type: "qcm",
      source: "legacy",
      statement: q.statement,
      explanation: q.explanation,
      choices: [...q.choices].sort((a: any, b: any) => a.order - b.order),
    })
  );

  // Source 2 : banque de questions (lien via quiz_question_bank)
  const { data: bankLinks } = await supabase
    .from("quiz_question_bank")
    .select(
      "display_order, question:question_bank(id, type, statement, choices, max_score, explanation)"
    )
    .eq("quiz_id", quiz.id)
    .order("display_order");

  const fromBank: UnifiedQuestion[] = (bankLinks || []).map((link: any) => {
    const q = link.question;
    if (q.type === "qr") {
      return {
        id: q.id,
        type: "qr",
        source: "bank",
        statement: q.statement,
        explanation: q.explanation ?? null,
        choices: [],
        max_score: q.max_score ?? 4,
      };
    }
    // QCM venant de la banque : choices sont en jsonb
    const choices = ((q.choices as any[]) ?? []).map((c, idx) => ({
      id: c.id ?? String.fromCharCode(97 + idx),
      label: c.label,
      is_correct: !!c.is_correct,
      order: idx,
    }));
    return {
      id: q.id,
      type: "qcm",
      source: "bank",
      statement: q.statement,
      explanation: q.explanation ?? null,
      choices,
    };
  });

  const list = [...fromLegacy, ...fromBank];

  // Si quiz en mode random et aucune question linkée → tirage à la volée
  if (
    list.length === 0 &&
    (quiz as any).generation_mode === "random_from_bank"
  ) {
    const f = (quiz as any).bank_filters ?? {};
    const { data: random } = await supabase.rpc("generate_random_exam", {
      p_formation_slug: f.formation_slug,
      p_qcm_count: f.qcm_count ?? 30,
      p_qr_count: f.qr_count ?? 0,
      p_difficulty: f.difficulties ?? null,
      p_module_ids: null,
    });

    if (random) {
      // Recharge les détails complets (choices, max_score) pour chaque id tiré
      const ids = (random as any[]).map((r) => r.id);
      const { data: details } = await supabase
        .from("question_bank")
        .select("id, type, statement, choices, max_score, explanation")
        .in("id", ids);

      const byId = new Map((details ?? []).map((d: any) => [d.id, d]));
      for (const r of random as any[]) {
        const d = byId.get(r.id);
        if (!d) continue;
        if (d.type === "qr") {
          list.push({
            id: d.id,
            type: "qr",
            source: "bank",
            statement: d.statement,
            explanation: d.explanation ?? null,
            choices: [],
            max_score: d.max_score ?? 4,
          });
        } else {
          const choices = ((d.choices as any[]) ?? []).map(
            (c: any, idx: number) => ({
              id: c.id ?? String.fromCharCode(97 + idx),
              label: c.label,
              is_correct: !!c.is_correct,
              order: idx,
            })
          );
          list.push({
            id: d.id,
            type: "qcm",
            source: "bank",
            statement: d.statement,
            explanation: d.explanation ?? null,
            choices,
          });
        }
      }
    }
  }

  const { data: attemptState } = await supabase.rpc("quiz_attempt_state", {
    p_quiz_id: quiz.id,
  });

  // Résolution de la formation associée — slug pour l'UI, ID pour le payload INSERT
  const [formationSlug, formationId] = await Promise.all([
    resolveFormationFromQuiz(quiz.id),
    resolveFormationIdFromQuiz(quiz.id),
  ]);

  return (
    <QuizRunner
      quiz={quiz}
      questions={list}
      attemptState={(attemptState as any) ?? null}
      formationSlug={formationSlug}
      formationId={formationId}
    />
  );
}
