import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { renderMarkdown } from "@/lib/markdown";
import { LessonContent } from "@/lib/lesson-blocks";
import { ProtectedContent } from "@/components/lesson/protected-content";
import { Card, CardBody } from "@/components/ui/card";
import { ArrowLeft, ArrowRight, Sparkles } from "lucide-react";
import { MarkDoneButton } from "./mark-done-button";
import { SessionTracker } from "@/components/session-tracker";
import { LessonVideo } from "@/components/lesson-video";
import { LessonResources } from "@/components/lesson-resources";

export default async function LessonPage({
  params,
}: {
  params: { slug: string; lessonSlug: string };
}) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data: module } = await supabase
    .from("modules")
    .select("*")
    .eq("slug", params.slug)
    .single();
  if (!module) notFound();

  const { data: lesson } = await supabase
    .from("lessons")
    .select("*")
    .eq("module_id", module.id)
    .eq("slug", params.lessonSlug)
    .single();
  if (!lesson) notFound();

  const { data: lessons } = await supabase
    .from("lessons")
    .select("id, slug, title, order")
    .eq("module_id", module.id)
    .order("order");
  const idx = lessons?.findIndex((l) => l.id === lesson.id) ?? -1;
  const prev = idx > 0 ? lessons?.[idx - 1] : null;
  const next = idx >= 0 && lessons && idx < lessons.length - 1 ? lessons[idx + 1] : null;

  let completed = false;
  if (user) {
    const { data } = await supabase
      .from("lesson_progress")
      .select("completed")
      .eq("user_id", user.id)
      .eq("lesson_id", lesson.id)
      .maybeSingle();
    completed = !!data?.completed;
  }

  return (
    <div className="max-w-3xl mx-auto space-y-8">
      <SessionTracker lessonId={lesson.id} />
      <Link
        href={`/modules/${module.slug}`}
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
      >
        <ArrowLeft className="w-4 h-4" /> Retour au module
      </Link>

      <article>
        <div className="eyebrow text-gold-700">
          Leçon {idx >= 0 ? idx + 1 : ""} · {module.title}
        </div>
        <h1 className="mt-3 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          {lesson.title}
        </h1>
        {lesson.video_url && (
          <div className="mt-6">
            <LessonVideo url={lesson.video_url} title={lesson.title} />
          </div>
        )}
        <div className="mt-8">
          <ProtectedContent>
            <LessonContent source={lesson.content_md} />
          </ProtectedContent>
        </div>
      </article>

      <LessonResources lessonId={lesson.id} />

      {lesson.summary_md && (
        <Card variant="gold">
          <CardBody>
            <div className="flex items-center gap-2 mb-3">
              <Sparkles className="h-4 w-4 text-gold-700" />
              <span className="eyebrow text-gold-800">Fiche de synthèse</span>
            </div>
            <ProtectedContent>
              <div
                className="prose-lesson text-sm"
                dangerouslySetInnerHTML={{ __html: renderMarkdown(lesson.summary_md) }}
              />
            </ProtectedContent>
          </CardBody>
        </Card>
      )}

      <div className="flex items-center justify-between pt-6 border-t border-navy-100 gap-3">
        <div className="flex-1">
          {prev && (
            <Link
              href={`/modules/${module.slug}/${prev.slug}`}
              className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
            >
              <ArrowLeft className="h-3.5 w-3.5" />
              <span className="truncate">{prev.title}</span>
            </Link>
          )}
        </div>
        <MarkDoneButton lessonId={lesson.id} initialDone={completed} />
        <div className="flex-1 text-right">
          {next && (
            <Link
              href={`/modules/${module.slug}/${next.slug}`}
              className="inline-flex items-center gap-1.5 text-sm font-medium text-navy-900 hover:text-gold-700"
            >
              <span className="truncate">{next.title}</span>
              <ArrowRight className="h-3.5 w-3.5" />
            </Link>
          )}
        </div>
      </div>
    </div>
  );
}
