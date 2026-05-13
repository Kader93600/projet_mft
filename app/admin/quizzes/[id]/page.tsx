import { createClient } from "@/lib/supabase/server";
import { notFound } from "next/navigation";
import Link from "next/link";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ArrowLeft } from "lucide-react";
import { QuizSettingsForm } from "../quiz-settings-form";
import { QuestionsEditor } from "./questions-editor";
import { QuizDangerZone } from "./quiz-danger-zone";
import { BankQuestionsPicker } from "./bank-questions-picker";
import { getQuestionFilterConfig } from "@/lib/question-filters";

export const dynamic = "force-dynamic";

export default async function EditQuizPage({
  params,
}: {
  params: { id: string };
}) {
  const supabase = createClient();
  const [
    { data: quiz },
    { data: modules },
    { data: questions },
    { data: dbFormations },
    { data: currentLink },
    { data: linkedBank },
  ] = await Promise.all([
    supabase.from("quizzes").select("*").eq("id", params.id).single(),
    supabase.from("modules").select("id, title").order("bloc_id").order("order"),
    supabase
      .from("questions")
      .select("*, choices(*)")
      .eq("quiz_id", params.id)
      .order("order"),
    supabase
      .from("formations")
      .select("slug, code, title")
      .eq("active", true)
      .order("code"),
    supabase
      .from("formation_quizzes")
      .select("formation:formations(slug, id)")
      .eq("quiz_id", params.id)
      .limit(1)
      .maybeSingle(),
    supabase
      .from("quiz_question_bank")
      .select("question_id, display_order")
      .eq("quiz_id", params.id)
      .order("display_order"),
  ]);
  if (!quiz) notFound();

  // 1. D'abord via formation_quizzes (lien direct quiz ↔ formation)
  let initialFormationSlug: string | null =
    (currentLink?.formation as any)?.slug ?? null;
  let formationId: string | null =
    (currentLink?.formation as any)?.id ?? null;

  // 2. Fallback via le module rattaché : si le quiz n'a pas de lien
  //    direct, on remonte module → formation_modules → formation.
  //    Permet aux quizzes historiques du seed (qui n'ont qu'un module_id)
  //    d'hériter automatiquement de la formation du module.
  if (!formationId && quiz.module_id) {
    const { data: fmRow } = await supabase
      .from("formation_modules")
      .select("formation:formations(id, slug)")
      .eq("module_id", quiz.module_id)
      .limit(1)
      .maybeSingle();
    const f = (fmRow?.formation as any) ?? null;
    if (f) {
      initialFormationSlug = f.slug;
      formationId = f.id;
    }
  }

  // Fetch les questions de la banque rattachées à la même formation
  // (et idéalement au même module si le quiz en a un) pour permettre
  // à l'admin de les piocher.
  let bankQuestions: any[] = [];
  if (formationId) {
    let bankQuery = supabase
      .from("question_bank")
      .select(
        "id, type, statement, choices, difficulty, tags, max_score, active, module_id",
      )
      .eq("formation_id", formationId)
      .order("source_ref", { ascending: true });

    // Si le quiz est rattaché à un module spécifique, on filtre
    // (mais on garde toutes les questions de la formation si pas de module).
    // L'utilisateur peut décocher le filtre dans le picker pour voir tout.
    if (quiz.module_id) {
      bankQuery = bankQuery.eq("module_id", quiz.module_id);
    }

    const { data } = await bankQuery;
    bankQuestions = data ?? [];
  }

  const linkedIds = new Set(
    (linkedBank ?? []).map((r: any) => r.question_id as string),
  );
  const filterConfig = getQuestionFilterConfig(initialFormationSlug);

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
          {/* Banque de questions : sélection à la volée depuis question_bank */}
          <Card>
            <div className="px-6 pt-5 pb-3 border-b border-navy-50 flex items-center justify-between flex-wrap gap-2">
              <div>
                <CardTitle className="text-base">
                  Banque de questions ({linkedIds.size})
                </CardTitle>
                <p className="text-[11.5px] text-slate-500 mt-0.5">
                  Cochez les questions de la banque à inclure dans ce quiz.
                </p>
              </div>
              {initialFormationSlug && (
                <Link
                  href={`/admin/banque-questions/liste?f=${initialFormationSlug}`}
                  className="text-[11.5px] font-semibold text-brand-700 hover:text-brand-900"
                >
                  Gérer la banque →
                </Link>
              )}
            </div>
            <CardBody>
              <BankQuestionsPicker
                quizId={quiz.id}
                questions={bankQuestions}
                initialLinkedIds={[...linkedIds]}
                filterConfig={{
                  tagPrefix: filterConfig.tagPrefix,
                  label: filterConfig.label,
                  // Pré-calcul des labels côté server — les fonctions
                  // formatPill/formatLong ne peuvent pas traverser la
                  // boundary RSC (sérialisation impossible).
                  entries: filterConfig.keys.map((k) => ({
                    key: k,
                    pill: filterConfig.formatPill(k),
                    long: filterConfig.formatLong
                      ? filterConfig.formatLong(k)
                      : filterConfig.formatPill(k),
                  })),
                }}
                hasFormation={!!formationId}
                hasModule={!!quiz.module_id}
              />
            </CardBody>
          </Card>

          {/* Questions "legacy" (table questions) — toujours dispo pour
              les quizz historiques. À terme on migrera tout vers la banque. */}
          {(questions?.length ?? 0) > 0 && (
            <Card>
              <div className="px-6 pt-5 pb-3 border-b border-navy-50">
                <CardTitle className="text-base">
                  Questions inline historiques ({questions?.length ?? 0})
                </CardTitle>
                <p className="text-[11.5px] text-slate-500 mt-0.5">
                  Questions saisies directement dans ce quiz (non issues de
                  la banque centralisée).
                </p>
              </div>
              <CardBody>
                <QuestionsEditor
                  quizId={quiz.id}
                  initialQuestions={(questions ?? []) as any[]}
                />
              </CardBody>
            </Card>
          )}
        </div>
        <div className="space-y-5">
          <Card>
            <div className="px-6 pt-5 pb-3 border-b border-navy-50">
              <CardTitle className="text-base">Paramètres</CardTitle>
            </div>
            <CardBody>
              <QuizSettingsForm
                modules={modules ?? []}
                formations={(dbFormations ?? []) as any}
                quiz={quiz}
                initialFormationSlug={initialFormationSlug}
              />
            </CardBody>
          </Card>
          <QuizDangerZone quizId={quiz.id} />
        </div>
      </div>
    </div>
  );
}
