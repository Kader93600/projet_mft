import { createClient } from "@/lib/supabase/server";
import { notFound } from "next/navigation";
import Link from "next/link";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ArrowLeft } from "lucide-react";
import { QuizSettingsForm } from "../quiz-settings-form";
import { QuestionsEditor } from "./questions-editor";
import { QuizDangerZone } from "./quiz-danger-zone";

export const dynamic = "force-dynamic";

export default async function EditQuizPage({
  params,
}: {
  params: { id: string };
}) {
  const supabase = createClient();
  const [{ data: quiz }, { data: modules }, { data: questions }] =
    await Promise.all([
      supabase.from("quizzes").select("*").eq("id", params.id).single(),
      supabase.from("modules").select("id, title").order("bloc_id").order("order"),
      supabase
        .from("questions")
        .select("*, choices(*)")
        .eq("quiz_id", params.id)
        .order("order"),
    ]);
  if (!quiz) notFound();

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <Link
          href="/admin/quizzes"
          className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
        >
          <ArrowLeft className="h-4 w-4" /> Retour aux quiz
        </Link>
        <Badge tone={quiz.type === "examen" ? "gold" : "navy"}>{quiz.type}</Badge>
      </div>

      <div>
        <h1 className="font-display text-2xl font-semibold text-navy-950">
          {quiz.title}
        </h1>
        {quiz.description && (
          <p className="text-sm text-slate-600 mt-1">{quiz.description}</p>
        )}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
        <div className="lg:col-span-2 space-y-5">
          <Card>
            <div className="px-6 pt-5 pb-3 border-b border-navy-50">
              <CardTitle className="text-base">
                Questions ({questions?.length ?? 0})
              </CardTitle>
            </div>
            <CardBody>
              <QuestionsEditor
                quizId={quiz.id}
                initialQuestions={(questions ?? []) as any[]}
              />
            </CardBody>
          </Card>
        </div>
        <div className="space-y-5">
          <Card>
            <div className="px-6 pt-5 pb-3 border-b border-navy-50">
              <CardTitle className="text-base">Paramètres</CardTitle>
            </div>
            <CardBody>
              <QuizSettingsForm modules={modules ?? []} quiz={quiz} />
            </CardBody>
          </Card>
          <QuizDangerZone quizId={quiz.id} />
        </div>
      </div>
    </div>
  );
}
