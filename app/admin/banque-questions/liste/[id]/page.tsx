import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ArrowLeft } from "lucide-react";
import { EditQuestionForm } from "./edit-form";
import { QuestionPreview } from "./question-preview";
import { GroupAssignSelect } from "../../group-assign-select";
import { getQuestionFilterConfig } from "@/lib/question-filters";
import type { Tables } from "@/lib/database.types";

export const dynamic = "force-dynamic";

/** Contrat applicatif de la colonne jsonb `question_bank.choices`. */
type QuestionChoice = {
  id?: string;
  label: string;
  is_correct: boolean;
  order?: number;
};

/**
 * Ligne `question_bank` telle que sélectionnée ici. On resserre deux colonnes
 * par rapport au type DB brut :
 *  - `type` : `text` en base, mais l'app ne connaît que qcm | qr ;
 *  - `choices` : `jsonb` en base, dont le contrat runtime est QuestionChoice[].
 */
type EditableQuestion = Omit<
  Pick<
    Tables<"question_bank">,
    | "id"
    | "type"
    | "statement"
    | "choices"
    | "expected_answer"
    | "scoring_grid"
    | "max_score"
    | "difficulty"
    | "tags"
    | "active"
    | "source_ref"
    | "formation_id"
  >,
  "type" | "choices"
> & {
  type: "qcm" | "qr";
  choices: QuestionChoice[] | null;
};

export default async function EditQuestionPage(
  props: {
    params: Promise<{ id: string }>;
  }
) {
  const params = await props.params;
  const supabase = await createClient();
  const { data } = await supabase
    .from("question_bank")
    .select(
      "id, type, statement, choices, expected_answer, scoring_grid, max_score, difficulty, tags, active, source_ref, formation_id"
    )
    .eq("id", params.id)
    .maybeSingle();
  const q = (data ?? null) as EditableQuestion | null;
  if (!q) notFound();

  // Récupère le slug de la formation pour adapter le sélecteur
  // (Chapitre pour GOTRM, Module pour Capa…).
  let formationSlug: string | null = null;
  if (q.formation_id) {
    const { data: f } = await supabase
      .from("formations")
      .select("slug")
      .eq("id", q.formation_id)
      .maybeSingle();
    formationSlug = f?.slug ?? null;
  }
  const filterConfig = getQuestionFilterConfig(formationSlug);
  const serializableFilterConfig = {
    tagPrefix: filterConfig.tagPrefix,
    label: filterConfig.label,
    entries: filterConfig.keys.map((k) => ({
      key: k,
      pill: filterConfig.formatPill(k),
      long: filterConfig.formatLong
        ? filterConfig.formatLong(k)
        : filterConfig.formatPill(k),
    })),
  };

  return (
    <div className="space-y-6 max-w-3xl">
      <Link
        href="/admin/banque-questions/liste"
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
      >
        <ArrowLeft className="h-4 w-4" /> Liste
      </Link>

      <header>
        <div className="flex items-center gap-2 mb-2 flex-wrap">
          <Badge tone={q.type === "qr" ? "gold" : "navy"} size="sm">
            {q.type.toUpperCase()}
          </Badge>
          <Badge tone={q.active ? "success" : "rose"} size="sm">
            {q.active ? "Active" : "Inactive"}
          </Badge>
          <span className="text-[11px] font-bold uppercase tracking-[0.14em] text-slate-500 ml-2">
            {filterConfig.label}
          </span>
          <GroupAssignSelect
            questionId={q.id}
            currentTags={q.tags ?? []}
            filterConfig={serializableFilterConfig}
            size="md"
          />
          {q.source_ref && (
            <code className="text-xs font-mono text-slate-500">
              {q.source_ref}
            </code>
          )}
        </div>
        <h1 className="font-display text-2xl font-semibold text-navy-950">
          Éditer la question
        </h1>
      </header>

      <Card>
        <CardBody>
          <CardTitle className="mb-4">Prévisualisation stagiaire</CardTitle>
          <QuestionPreview question={q} />
        </CardBody>
      </Card>

      <Card>
        <CardBody>
          <EditQuestionForm question={q} />
        </CardBody>
      </Card>
    </div>
  );
}
