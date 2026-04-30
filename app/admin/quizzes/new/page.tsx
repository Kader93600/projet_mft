import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import Link from "next/link";
import { ArrowLeft } from "lucide-react";
import { QuizSettingsForm } from "../quiz-settings-form";
import { FORMATIONS } from "@/lib/formations-config";

export const dynamic = "force-dynamic";

export default async function NewQuizPage() {
  const supabase = createClient();
  const [{ data: modules }, { data: dbFormations }] = await Promise.all([
    supabase
      .from("modules")
      .select("id, title")
      .order("bloc_id")
      .order("order"),
    supabase
      .from("formations")
      .select("slug, code, title")
      .eq("active", true)
      .order("code"),
  ]);

  const formations =
    dbFormations && dbFormations.length > 0
      ? dbFormations
      : FORMATIONS.map((f) => ({ slug: f.slug, code: f.code, title: f.title }));

  return (
    <div className="space-y-6 max-w-3xl">
      <Link
        href="/admin/quizzes"
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
      >
        <ArrowLeft className="h-4 w-4" /> Retour aux quiz
      </Link>
      <Card>
        <div className="px-6 pt-5 pb-3 border-b border-navy-50">
          <CardTitle>Nouveau quiz</CardTitle>
        </div>
        <CardBody>
          <QuizSettingsForm
            modules={modules ?? []}
            formations={formations as any}
          />
        </CardBody>
      </Card>
    </div>
  );
}
