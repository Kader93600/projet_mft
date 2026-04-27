import { createClient } from "@/lib/supabase/server";
import { notFound } from "next/navigation";
import Link from "next/link";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { ArrowLeft, Paperclip, History } from "lucide-react";
import { LessonForm } from "./lesson-form";
import { ResourcesManager } from "./resources-manager";
import { Badge } from "@/components/ui/badge";

export const dynamic = "force-dynamic";

export default async function EditLessonPage({
  params,
}: {
  params: { id: string; lessonId: string };
}) {
  const supabase = createClient();
  const [{ data: module }, { data: lesson }, { data: resources }, { data: versions }] =
    await Promise.all([
      supabase.from("modules").select("id, title").eq("id", params.id).single(),
      supabase.from("lessons").select("*").eq("id", params.lessonId).single(),
      supabase
        .from("lesson_resources")
        .select("*")
        .eq("lesson_id", params.lessonId)
        .order("order"),
      supabase
        .from("lesson_versions")
        .select(
          "id, version, edited_at, edited_by, change_note, editor:profiles!lesson_versions_edited_by_fkey(full_name, email)"
        )
        .eq("lesson_id", params.lessonId)
        .order("version", { ascending: false })
        .limit(20),
    ]);
  if (!module || !lesson) notFound();

  return (
    <div className="space-y-6 max-w-5xl">
      <Link
        href={`/admin/modules/${module.id}`}
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
      >
        <ArrowLeft className="h-4 w-4" /> Retour à « {module.title} »
      </Link>
      <div>
        <h1 className="font-display text-2xl font-semibold text-navy-950">
          {lesson.title}
        </h1>
        <p className="text-sm text-slate-500 font-mono mt-1">{lesson.slug}</p>
      </div>
      <Card>
        <div className="px-6 pt-5 pb-3 border-b border-navy-50">
          <CardTitle className="text-base">Édition de la leçon</CardTitle>
        </div>
        <CardBody>
          <LessonForm moduleId={module.id} lesson={lesson} />
        </CardBody>
      </Card>

      <Card>
        <div className="px-6 pt-5 pb-3 border-b border-navy-50 flex items-center gap-2">
          <Paperclip className="h-4 w-4 text-slate-500" />
          <CardTitle className="text-base">Ressources complémentaires</CardTitle>
        </div>
        <CardBody>
          <ResourcesManager
            lessonId={lesson.id}
            initial={(resources ?? []) as any}
          />
        </CardBody>
      </Card>

      <Card>
        <div className="px-6 pt-5 pb-3 border-b border-navy-50 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <History className="h-4 w-4 text-slate-500" />
            <CardTitle className="text-base">
              Historique des versions
            </CardTitle>
          </div>
          <Badge tone="navy" size="sm">
            v{(lesson as any).current_version ?? 1} en cours
          </Badge>
        </div>
        <CardBody className="p-0">
          {(versions ?? []).length === 0 ? (
            <div className="px-6 py-6 text-sm text-slate-500">
              Aucun historique disponible. Les prochaines modifications seront
              versionnées automatiquement.
            </div>
          ) : (
            <ul className="divide-y divide-navy-50">
              {(versions ?? []).map((v: any) => (
                <li
                  key={v.id}
                  className="px-6 py-3 flex items-center gap-4 text-sm"
                >
                  <div className="font-mono font-semibold text-navy-900 w-12">
                    v{v.version}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="text-slate-700">
                      {v.editor?.full_name ?? v.editor?.email ?? "—"}
                    </div>
                    {v.change_note && (
                      <div className="text-xs text-slate-500 truncate">
                        {v.change_note}
                      </div>
                    )}
                  </div>
                  <div className="text-xs text-slate-500 shrink-0">
                    {new Date(v.edited_at).toLocaleString("fr-FR", {
                      dateStyle: "short",
                      timeStyle: "short",
                    })}
                  </div>
                </li>
              ))}
            </ul>
          )}
          <div className="px-6 py-3 text-xs text-slate-500 border-t border-navy-50">
            Conservé pour Qualiopi : preuve de la version réellement suivie par
            chaque stagiaire (table <code>lesson_progress.lesson_version_id</code>).
          </div>
        </CardBody>
      </Card>
    </div>
  );
}
