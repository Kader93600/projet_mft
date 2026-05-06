import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { renderMarkdown } from "@/lib/markdown";
import { LessonContent } from "@/lib/lesson-blocks";
import { ProtectedContent } from "@/components/lesson/protected-content";
import { FormationBadge } from "@/components/formation/formation-badge";
import { FormationStripe } from "@/components/formation/formation-stripe";
import { resolveFormationFromModule } from "@/lib/formation-resolver";
import { Card, CardBody } from "@/components/ui/card";
import { ArrowLeft, ArrowRight, Sparkles, Clock, BookOpen } from "lucide-react";
import { MarkDoneButton } from "./mark-done-button";
import { SessionTracker } from "@/components/session-tracker";
import { LessonVideo } from "@/components/lesson-video";
import { LessonResources } from "@/components/lesson-resources";

/**
 * Estimation du temps de lecture : ~210 mots / minute (français adulte).
 * Compte uniquement les mots, ignore les caractères de markdown.
 */
function estimateReadingTime(md: string | null | undefined): number {
  if (!md) return 0;
  const text = md.replace(/[#>*_`~\[\]\(\)\-]/g, " ");
  const words = text.trim().split(/\s+/).filter(Boolean).length;
  return Math.max(1, Math.round(words / 210));
}

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

  // Gate par formation : 404 si l'utilisateur n'est pas inscrit à une
  // formation contenant ce module.
  if (user) {
    const { data: enrollments } = await supabase
      .from("enrollments")
      .select("formation_id")
      .eq("user_id", user.id)
      .not("formation_id", "is", null)
      .not("status", "in", "(refuse,abandon)");
    const enrolledIds = (enrollments ?? [])
      .map((e: any) => e.formation_id as string)
      .filter(Boolean);
    if (enrolledIds.length === 0) notFound();

    const { count } = await supabase
      .from("formation_modules")
      .select("module_id", { count: "exact", head: true })
      .eq("module_id", module.id)
      .in("formation_id", enrolledIds);
    if (!count) notFound();
  }

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

  // Résolution formation pour identification visuelle
  const formationSlug = await resolveFormationFromModule(module.id);
  const readingMin = estimateReadingTime(lesson.content_md);

  return (
    <div className="max-w-[42rem] mx-auto">
      {formationSlug && <FormationStripe slug={formationSlug} />}
      <div className="space-y-10 pt-6">
      <SessionTracker lessonId={lesson.id} />
      <Link
        href={`/modules/${module.slug}`}
        className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-navy-900 transition-colors"
      >
        <ArrowLeft className="w-3.5 h-3.5" /> Retour au module
      </Link>

      <article>
        {/* Eyebrow + métadonnées du module */}
        <div className="flex items-center gap-2.5 mb-4 flex-wrap">
          {formationSlug && (
            <FormationBadge slug={formationSlug} size="sm" icon />
          )}
          <span
            aria-hidden
            className="h-1 w-1 rounded-full bg-slate-300"
          />
          <span className="text-[11px] font-semibold uppercase tracking-[0.16em] text-slate-500">
            {module.title}
            {idx >= 0 && (
              <>
                <span className="mx-1.5 text-slate-300">·</span>
                Leçon {idx + 1}
              </>
            )}
          </span>
        </div>

        {/* H1 — titre de la leçon, fluide, balanced */}
        <h1
          className="font-display font-semibold text-navy-950"
          style={{
            fontSize: "clamp(2rem, 1.6rem + 1.6vw, 3rem)",
            lineHeight: 1.05,
            letterSpacing: "-0.025em",
            textWrap: "balance",
          }}
        >
          {lesson.title}
        </h1>

        {/* Métadonnées de lecture sous le titre */}
        <div className="mt-5 flex items-center gap-4 text-[13px] text-slate-500">
          {readingMin > 0 && (
            <span className="inline-flex items-center gap-1.5">
              <Clock className="h-3.5 w-3.5" />
              <span>
                {readingMin}{" "}
                <span className="text-slate-400">min de lecture</span>
              </span>
            </span>
          )}
          {lesson.video_url && (
            <span className="inline-flex items-center gap-1.5">
              <BookOpen className="h-3.5 w-3.5" />
              <span className="text-slate-400">vidéo + texte</span>
            </span>
          )}
        </div>

        {lesson.video_url && (
          <div className="mt-8">
            <LessonVideo url={lesson.video_url} title={lesson.title} />
          </div>
        )}

        <div className="mt-10">
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

      <div className="grid sm:grid-cols-[1fr_auto_1fr] items-center pt-8 border-t border-navy-100 gap-4">
        <div className="min-w-0">
          {prev && (
            <Link
              href={`/modules/${module.slug}/${prev.slug}`}
              className="group inline-flex items-start gap-2.5 text-left transition-colors"
            >
              <ArrowLeft className="h-3.5 w-3.5 mt-1 text-slate-400 group-hover:text-brand-600 group-hover:-translate-x-0.5 transition-transform shrink-0" />
              <span className="min-w-0">
                <span className="block text-[10px] font-semibold uppercase tracking-[0.16em] text-slate-400">
                  Précédent
                </span>
                <span className="block font-display text-sm font-medium text-navy-800 group-hover:text-brand-700 truncate transition-colors">
                  {prev.title}
                </span>
              </span>
            </Link>
          )}
        </div>
        <div className="flex justify-center">
          <MarkDoneButton lessonId={lesson.id} initialDone={completed} />
        </div>
        <div className="min-w-0 sm:text-right">
          {next && (
            <Link
              href={`/modules/${module.slug}/${next.slug}`}
              className="group inline-flex items-start gap-2.5 text-left sm:flex-row-reverse transition-colors"
            >
              <ArrowRight className="h-3.5 w-3.5 mt-1 text-slate-400 group-hover:text-signal-700 group-hover:translate-x-0.5 transition-transform shrink-0" />
              <span className="min-w-0">
                <span className="block text-[10px] font-semibold uppercase tracking-[0.16em] text-signal-700">
                  Suivant
                </span>
                <span className="block font-display text-sm font-semibold text-navy-900 group-hover:text-brand-700 truncate transition-colors">
                  {next.title}
                </span>
              </span>
            </Link>
          )}
        </div>
      </div>
      </div>
    </div>
  );
}
