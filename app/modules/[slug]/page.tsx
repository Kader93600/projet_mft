import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ProgressBar } from "@/components/ui/progress";
import { blocTone } from "@/lib/utils";
import {
  ArrowLeft,
  BookOpen,
  Check,
  ClipboardCheck,
  Clock,
  Target,
  ArrowRight,
} from "lucide-react";

export default async function ModuleDetail({ params }: { params: { slug: string } }) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data: module } = await supabase
    .from("modules")
    .select("*, blocs(code, title)")
    .eq("slug", params.slug)
    .single();
  if (!module) notFound();

  const [{ data: lessons }, { data: quizzes }, { data: progress }] = await Promise.all([
    supabase.from("lessons").select("*").eq("module_id", module.id).order("order"),
    supabase.from("quizzes").select("*").eq("module_id", module.id),
    user
      ? supabase
          .from("lesson_progress")
          .select("lesson_id, completed")
          .eq("user_id", user.id)
      : { data: [] as any[] },
  ]);

  const doneIds = new Set((progress || []).filter((p) => p.completed).map((p) => p.lesson_id));
  const total = lessons?.length ?? 0;
  const done = lessons?.filter((l) => doneIds.has(l.id)).length ?? 0;
  const pct = total ? Math.round((done / total) * 100) : 0;
  const tone = blocTone(module.blocs?.code);

  return (
    <div className="max-w-4xl space-y-8">
      <Link
        href="/modules"
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
      >
        <ArrowLeft className="w-4 h-4" /> Tous les modules
      </Link>

      {/* Header */}
      <header className="space-y-4">
        <div className="flex items-center gap-2">
          <Badge tone={tone} size="sm">{module.blocs?.code}</Badge>
          <span className="text-xs text-slate-500">{module.blocs?.title}</span>
        </div>
        <h1 className="font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          {module.title}
        </h1>
        {module.summary && (
          <p className="text-[15px] text-slate-600 max-w-2xl leading-relaxed">
            {module.summary}
          </p>
        )}
        <div className="flex flex-wrap gap-4 text-sm text-slate-600">
          <span className="inline-flex items-center gap-1.5">
            <Clock className="h-4 w-4 text-slate-400" />
            {module.duration_min} min
          </span>
          <span className="inline-flex items-center gap-1.5 capitalize">
            <Target className="h-4 w-4 text-slate-400" />
            {module.difficulty}
          </span>
          <span className="inline-flex items-center gap-1.5">
            <BookOpen className="h-4 w-4 text-slate-400" />
            {total} leçons
          </span>
        </div>

        {total > 0 && (
          <div className="max-w-md pt-2">
            <div className="flex justify-between text-xs text-slate-600 mb-1.5">
              <span>Votre progression</span>
              <span className="font-medium text-navy-900">
                {done}/{total} · {pct}%
              </span>
            </div>
            <ProgressBar value={pct} variant="gradient" />
          </div>
        )}
      </header>

      {/* Leçons */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 flex items-center gap-2">
          <BookOpen className="w-4 h-4 text-gold-600" /> Leçons
        </h2>
        <Card>
          <div className="divide-y divide-navy-50">
            {lessons?.map((l, i) => {
              const isDone = doneIds.has(l.id);
              return (
                <Link
                  key={l.id}
                  href={`/modules/${module.slug}/${l.slug}`}
                  className="group flex items-center justify-between px-5 py-4 hover:bg-navy-50/50 transition-colors"
                >
                  <div className="flex items-center gap-4 min-w-0">
                    <div
                      className={`w-9 h-9 rounded-xl flex items-center justify-center text-sm font-semibold shrink-0 ${
                        isDone
                          ? "bg-emerald-100 text-emerald-700"
                          : "bg-navy-50 text-navy-700"
                      }`}
                    >
                      {isDone ? <Check className="w-4 h-4" /> : i + 1}
                    </div>
                    <div className="min-w-0">
                      <div className="font-medium text-navy-900 truncate">{l.title}</div>
                      <div className="text-xs text-slate-500 mt-0.5">
                        Leçon {i + 1}
                      </div>
                    </div>
                  </div>
                  <span className="inline-flex items-center gap-1 text-sm font-medium text-navy-900 group-hover:text-gold-700">
                    Lire
                    <ArrowRight className="h-3.5 w-3.5 transition-transform group-hover:translate-x-0.5" />
                  </span>
                </Link>
              );
            })}
            {(!lessons || lessons.length === 0) && (
              <div className="px-5 py-8 text-sm text-slate-500 text-center">
                Aucune leçon pour le moment.
              </div>
            )}
          </div>
        </Card>
      </section>

      {/* Quiz */}
      {quizzes && quizzes.length > 0 && (
        <section>
          <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 flex items-center gap-2">
            <ClipboardCheck className="w-4 h-4 text-gold-600" /> Quiz associés
          </h2>
          <div className="grid md:grid-cols-2 gap-3">
            {quizzes.map((q) => {
              const isExam = q.type === "examen";
              return (
                <Link key={q.id} href={`/quiz/${q.id}`} className="group">
                  <Card
                    variant={isExam ? "gold" : "default"}
                    className="h-full group-hover:shadow-raised transition-all"
                  >
                    <CardBody>
                      {isExam ? (
                        <Badge tone="gold" size="sm">Mode examen</Badge>
                      ) : (
                        <Badge tone="navy" size="sm">Entraînement</Badge>
                      )}
                      <div className="mt-3 font-medium text-navy-900">{q.title}</div>
                      <div className="mt-2 text-xs text-slate-500 flex items-center gap-3">
                        {q.time_limit_s && (
                          <span className="inline-flex items-center gap-1">
                            <Clock className="h-3 w-3" />
                            {Math.round(q.time_limit_s / 60)} min
                          </span>
                        )}
                        <span className="inline-flex items-center gap-1">
                          <Target className="h-3 w-3" />
                          Seuil {q.pass_threshold}%
                        </span>
                      </div>
                      <div className="mt-3 inline-flex items-center gap-1 text-sm font-medium text-navy-900 group-hover:text-gold-700">
                        Démarrer
                        <ArrowRight className="h-3.5 w-3.5 transition-transform group-hover:translate-x-0.5" />
                      </div>
                    </CardBody>
                  </Card>
                </Link>
              );
            })}
          </div>
        </section>
      )}
    </div>
  );
}
