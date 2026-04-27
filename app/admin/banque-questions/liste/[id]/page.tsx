import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ArrowLeft } from "lucide-react";
import { EditQuestionForm } from "./edit-form";

export const dynamic = "force-dynamic";

export default async function EditQuestionPage({
  params,
}: {
  params: { id: string };
}) {
  const supabase = createClient();
  const { data: q } = await supabase
    .from("question_bank")
    .select(
      "id, type, statement, choices, expected_answer, scoring_grid, max_score, difficulty, tags, active, source_ref, formation_id"
    )
    .eq("id", params.id)
    .maybeSingle();
  if (!q) notFound();

  return (
    <div className="space-y-6 max-w-3xl">
      <Link
        href="/admin/banque-questions/liste"
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
      >
        <ArrowLeft className="h-4 w-4" /> Liste
      </Link>

      <header>
        <div className="flex items-center gap-2 mb-2">
          <Badge tone={q.type === "qr" ? "gold" : "navy"} size="sm">
            {q.type.toUpperCase()}
          </Badge>
          <Badge tone={q.active ? "success" : "rose"} size="sm">
            {q.active ? "Active" : "Inactive"}
          </Badge>
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
          <EditQuestionForm question={q as any} />
        </CardBody>
      </Card>
    </div>
  );
}
