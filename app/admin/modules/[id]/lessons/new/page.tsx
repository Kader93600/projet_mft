import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import Link from "next/link";
import { ArrowLeft } from "lucide-react";
import { LessonForm } from "../[lessonId]/lesson-form";
import { notFound } from "next/navigation";

export const dynamic = "force-dynamic";

export default async function NewLessonPage(
  props: {
    params: Promise<{ id: string }>;
  }
) {
  const params = await props.params;
  const supabase = await createClient();
  const { data: module } = await supabase
    .from("modules")
    .select("id, title")
    .eq("id", params.id)
    .single();
  if (!module) notFound();

  return (
    <div className="space-y-6 max-w-4xl">
      <Link
        href={`/admin/modules/${module.id}`}
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
      >
        <ArrowLeft className="h-4 w-4" /> Retour à « {module.title} »
      </Link>
      <Card>
        <div className="px-6 pt-5 pb-3 border-b border-navy-50">
          <CardTitle>Nouvelle leçon</CardTitle>
        </div>
        <CardBody>
          <LessonForm moduleId={module.id} />
        </CardBody>
      </Card>
    </div>
  );
}
