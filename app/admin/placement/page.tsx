import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { QuestionEditor } from "./question-editor";
import { Target } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function AdminPlacementPage() {
  const supabase = createClient();

  const [{ data: questions }, { data: blocs }, { count: resultsCount }] =
    await Promise.all([
      supabase
        .from("placement_questions")
        .select("id, bloc_id, prompt, choices, correct_index, difficulty, order, active, blocs(code)")
        .order("bloc_id")
        .order("order"),
      supabase.from("blocs").select("id, code, title").order("order"),
      supabase
        .from("placement_results")
        .select("user_id", { count: "exact", head: true }),
    ]);

  return (
    <div className="space-y-8">
      <header>
        <div className="flex items-center gap-2">
          <Target className="h-4 w-4 text-gold-700" />
          <span className="eyebrow text-gold-700">Individualisation Qualiopi</span>
        </div>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Positionnement initial
        </h1>
        <p className="mt-2 text-slate-600 text-sm max-w-2xl">
          Gérez la banque de questions utilisée pour positionner chaque stagiaire à l'entrée.
          {resultsCount ? ` ${resultsCount} stagiaire${resultsCount > 1 ? "s" : ""} positionné${resultsCount > 1 ? "s" : ""}.` : ""}
        </p>
      </header>

      <Card>
        <CardBody>
          <div className="flex items-center justify-between mb-4">
            <h2 className="font-display text-lg font-semibold text-navy-900">
              Nouvelle question
            </h2>
          </div>
          <QuestionEditor blocs={blocs ?? []} mode="create" />
        </CardBody>
      </Card>

      <section className="space-y-4">
        <h2 className="font-display text-lg font-semibold text-navy-900">
          Banque de questions ({questions?.length ?? 0})
        </h2>

        {(!questions || questions.length === 0) && (
          <Card>
            <CardBody className="py-10 text-center text-slate-500 text-sm">
              Aucune question. Ajoutez-en pour activer le positionnement.
            </CardBody>
          </Card>
        )}

        {questions?.map((q: any) => (
          <Card key={q.id} className={q.active ? "" : "opacity-60"}>
            <CardBody>
              <div className="flex items-center gap-2 mb-3 flex-wrap">
                <Badge tone="navy" size="sm">{q.blocs?.code}</Badge>
                <Badge tone="slate" size="sm">{q.difficulty}</Badge>
                {!q.active && <Badge tone="slate" size="sm">Désactivée</Badge>}
              </div>
              <QuestionEditor
                blocs={blocs ?? []}
                mode="edit"
                question={q}
              />
            </CardBody>
          </Card>
        ))}
      </section>
    </div>
  );
}
