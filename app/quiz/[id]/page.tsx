import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { QuizRunner } from "./quiz-runner";

export default async function QuizPage({ params }: { params: { id: string } }) {
  const supabase = createClient();
  const { data: quiz } = await supabase.from("quizzes").select("*").eq("id", params.id).single();
  if (!quiz) notFound();

  const { data: questions } = await supabase
    .from("questions")
    .select("id, statement, explanation, order, choices(id, label, is_correct, order)")
    .eq("quiz_id", quiz.id)
    .order("order");

  const list = (questions || []).map((q: any) => ({
    ...q,
    choices: [...q.choices].sort((a, b) => a.order - b.order),
  }));

  const { data: attemptState } = await supabase.rpc("quiz_attempt_state", {
    p_quiz_id: quiz.id,
  });

  return (
    <QuizRunner
      quiz={quiz}
      questions={list}
      attemptState={(attemptState as any) ?? null}
    />
  );
}
