import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { ProgressBar } from "@/components/ui/progress";
import { FormationStripe } from "@/components/formation/formation-stripe";
import { ModuleIntroVideo } from "@/components/modules/intro-video";
import { FormationBadge } from "@/components/formation/formation-badge";
import { resolveFormationFromModule } from "@/lib/formation-resolver";
import { findFormation } from "@/lib/formations-config";
import { isFlexibleUnlockFormation } from "@/lib/module-progress";
import {
  ArrowLeft,
  BookOpen,
  Check,
  ClipboardCheck,
  Clock,
  Target,
  ArrowRight,
  Flag,
  Sparkles,
  CircleDot,
  Trophy,
} from "lucide-react";

export const dynamic = "force-dynamic";

/**
 * Détail d'un module — refonte 2026-05.
 *
 * Structure :
 *  - FormationStripe en haut + breadcrumb minimal
 *  - Hero : eyebrow formation + h1 module + chips métadonnées + CTA primary
 *  - Carte progression si user a commencé
 *  - Timeline verticale des leçons (numéro + ligne, statut visible)
 *  - Section Quizzes : entraînement à gauche, examen blanc en avant à droite
 */
export default async function ModuleDetail({
  params,
}: {
  params: { slug: string };
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

  // Gate par formation : ce module est-il rattaché à une formation
  // où l'utilisateur est inscrit ? Sinon, 404 (mêmes signaux qu'un slug
  // inexistant — on ne fuite pas l'existence du contenu).
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

  const [{ data: lessons }, { data: quizzes }, { data: progress }] = await Promise.all([
    supabase
      .from("lessons")
      .select("*")
      .eq("module_id", module.id)
      .order("order"),
    supabase.from("quizzes").select("*").eq("module_id", module.id),
    user
      ? supabase
          .from("lesson_progress")
          .select("lesson_id, completed")
          .eq("user_id", user.id)
      : { data: [] as any[] },
  ]);

  // Tentatives du user sur les quiz de ce module — pour afficher les
  // résultats directement sur la page du module (best score, last attempt).
  const quizIds = (quizzes ?? []).map((q: any) => q.id);
  let attempts: any[] = [];
  if (user && quizIds.length > 0) {
    const { data: a } = await supabase
      .from("quiz_attempts")
      .select(
        "id, quiz_id, percentage, passed, score, total, finished_at, status, mode"
      )
      .eq("user_id", user.id)
      .in("quiz_id", quizIds)
      .not("finished_at", "is", null)
      .order("finished_at", { ascending: false });
    attempts = a ?? [];
  }

  // Index par quiz_id : best score + dernière tentative
  type QuizSummary = {
    bestPercentage: number;
    bestPassed: boolean;
    lastAttempt: any | null;
    attemptsCount: number;
  };
  const summaryByQuiz = new Map<string, QuizSummary>();
  for (const a of attempts) {
    const cur = summaryByQuiz.get(a.quiz_id) ?? {
      bestPercentage: 0,
      bestPassed: false,
      lastAttempt: null,
      attemptsCount: 0,
    };
    cur.attemptsCount++;
    if ((a.percentage ?? 0) > cur.bestPercentage) {
      cur.bestPercentage = a.percentage ?? 0;
    }
    if (a.passed) cur.bestPassed = true;
    if (
      !cur.lastAttempt ||
      (a.finished_at &&
        new Date(a.finished_at) > new Date(cur.lastAttempt.finished_at))
    ) {
      cur.lastAttempt = a;
    }
    summaryByQuiz.set(a.quiz_id, cur);
  }

  const formationSlug = await resolveFormationFromModule(module.id);
  const formation = formationSlug ? findFormation(formationSlug) : null;
  const accent = formation?.accent ?? "#9FE220";

  const doneIds = new Set(
    (progress || []).filter((p: any) => p.completed).map((p: any) => p.lesson_id)
  );
  const total = lessons?.length ?? 0;
  const done = lessons?.filter((l: any) => doneIds.has(l.id)).length ?? 0;
  const pct = total ? Math.round((done / total) * 100) : 0;

  // Module entièrement validé ? Critère adapté au mode de déverrouillage
  // de la formation (révision client 2026-05) :
  //   - 'strict'   (défaut) : leçons + quiz RÉUSSIS (alignement /modules)
  //   - 'flexible' (Capacité ≤ 3,5 t) : leçons + quiz ESSAYÉS (score ignoré)
  const allLessonsDone = total > 0 && done >= total;
  const allQuizzesPassed =
    (quizzes?.length ?? 0) === 0 ||
    (quizzes ?? []).every((q: any) => summaryByQuiz.get(q.id)?.bestPassed);
  const allQuizzesAttempted =
    (quizzes?.length ?? 0) === 0 ||
    (quizzes ?? []).every(
      (q: any) => (summaryByQuiz.get(q.id)?.attemptsCount ?? 0) > 0
    );
  const isFlexibleUnlock = isFlexibleUnlockFormation(formationSlug);
  const moduleFullyDone = isFlexibleUnlock
    ? allLessonsDone && allQuizzesAttempted
    : allLessonsDone && allQuizzesPassed;

  // Récupère le module suivant dans l'ordre de la formation (display_order).
  // Sert au CTA "Module suivant" quand l'actuel est terminé.
  let nextModuleData: {
    slug: string;
    title: string;
    locked: boolean;
  } | null = null;
  if (formationSlug && user) {
    const { data: form } = await supabase
      .from("formations")
      .select("id")
      .eq("slug", formationSlug)
      .maybeSingle();
    if (form?.id) {
      const { data: orderedModules } = await supabase
        .from("formation_modules")
        .select("display_order, module:modules(id, slug, title)")
        .eq("formation_id", form.id)
        .order("display_order");

      const ordered = (orderedModules ?? [])
        .map((r: any) => r.module)
        .filter(Boolean);
      const idx = ordered.findIndex((m: any) => m.id === module.id);
      if (idx >= 0 && idx < ordered.length - 1) {
        const next = ordered[idx + 1];
        nextModuleData = {
          slug: next.slug,
          title: next.title,
          locked: !moduleFullyDone,
        };
      }
    }
  }

  // Première leçon non terminée → pour le CTA "Reprendre / Démarrer"
  const nextLesson =
    lessons?.find((l: any) => !doneIds.has(l.id)) ?? lessons?.[0];

  // Quizzes par type
  const trainingQuizzes = (quizzes ?? []).filter((q: any) => q.type !== "examen");
  const examQuizzes = (quizzes ?? []).filter((q: any) => q.type === "examen");

  const totalQuizzes = quizzes?.length ?? 0;

  return (
    <div className="max-w-5xl space-y-10">
      {/* Stripe formation full-width via négatif marges */}
      {formationSlug && (
        <div className="-mx-4 md:-mx-8 -mt-6 md:-mt-10 mb-2">
          <FormationStripe slug={formationSlug} height={4} />
        </div>
      )}

      {/* Breadcrumb */}
      <Link
        href="/modules"
        className="inline-flex items-center gap-1.5 text-[13px] text-slate-500 hover:text-navy-900 transition-colors"
      >
        <ArrowLeft className="w-3.5 h-3.5" />
        Tous les modules
      </Link>

      {/* Hero */}
      <header
        className="space-y-5"
        style={{ animation: "fade-up 0.5s ease-out both" }}
      >
        {/* Eyebrow formation */}
        {formationSlug && (
          <div className="flex items-center gap-2.5">
            <FormationBadge slug={formationSlug} size="sm" icon withTitle />
          </div>
        )}

        {/* Titre */}
        <h1
          className="font-display font-semibold text-navy-950"
          style={{
            fontSize: "clamp(2rem, 1.6rem + 1.4vw, 2.75rem)",
            lineHeight: 1.05,
            letterSpacing: "-0.025em",
            textWrap: "balance",
          }}
        >
          {module.title}
        </h1>

        {module.summary && (
          <p
            className="text-slate-600 leading-relaxed max-w-2xl"
            style={{ fontSize: "clamp(0.95rem, 0.9rem + 0.2vw, 1.0625rem)" }}
          >
            {module.summary}
          </p>
        )}

        {/* Métadonnées */}
        <div className="flex flex-wrap items-center gap-x-5 gap-y-2 text-[13px] text-slate-600">
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
            {total} leçon{total > 1 ? "s" : ""}
          </span>
          {totalQuizzes > 0 && (
            <span className="inline-flex items-center gap-1.5">
              <ClipboardCheck className="h-4 w-4 text-slate-400" />
              {totalQuizzes} quiz
            </span>
          )}
        </div>

        {/* CTA principal */}
        {nextLesson && (
          <div className="pt-2">
            <Link
              href={`/modules/${module.slug}/${nextLesson.slug}`}
              className="inline-flex items-center gap-2 rounded-xl px-5 py-3 text-[14px] font-semibold text-night-900 shadow-soft transition-all hover:scale-[1.01] hover:shadow-raised"
              style={{
                background: accent,
                color: "#0E1240",
              }}
            >
              {done > 0 && done < total ? "Reprendre" : "Démarrer la première leçon"}
              <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
        )}
      </header>

      {/* Vidéo d'introduction (si présente) — affichée juste après le hero,
          avant la progression et la timeline des leçons. */}
      <ModuleIntroVideo
        videoPath={(module as any).intro_video_path ?? null}
        label={(module as any).intro_video_label ?? null}
        durationS={(module as any).intro_video_duration_s ?? null}
      />

      {/* Progression */}
      {user && total > 0 && (
        <section
          className="rounded-2xl border border-navy-100 bg-white p-5 md:p-6 shadow-soft"
          style={{ animation: "fade-up 0.5s ease-out 80ms both" }}
        >
          <div className="flex items-center justify-between gap-4 flex-wrap">
            <div>
              <div className="text-[11px] font-semibold uppercase tracking-[0.16em] text-slate-500">
                Votre progression
              </div>
              <div className="mt-1 font-display text-2xl font-semibold text-navy-900">
                {done} / {total}
                <span className="ml-2 text-base text-slate-500 font-normal">
                  ({pct} %)
                </span>
              </div>
            </div>
            {pct === 100 && (
              <span
                className="inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-[12px] font-semibold"
                style={{
                  background: `${accent}1A`,
                  color: "#0E1240",
                  border: `1px solid ${accent}50`,
                }}
              >
                <Trophy className="h-3.5 w-3.5" />
                Cours terminé
              </span>
            )}
          </div>
          <div className="mt-4">
            <ProgressBar value={pct} variant="gradient" />
          </div>
        </section>
      )}

      {/* CTA module suivant — apparaît dès que ce module est entièrement
          validé (toutes leçons + tous quiz réussis) */}
      {moduleFullyDone && nextModuleData && (
        <section
          className="relative overflow-hidden rounded-2xl border bg-gradient-to-br from-emerald-50 via-white to-signal-50 p-5 md:p-6 shadow-soft"
          style={{
            borderColor: `${accent}66`,
            animation: "fade-up 0.5s ease-out 100ms both",
          }}
        >
          <div
            aria-hidden
            className="absolute -top-10 -right-10 h-32 w-32 rounded-full pointer-events-none opacity-40"
            style={{
              background: `radial-gradient(circle, ${accent}55 0%, transparent 70%)`,
            }}
          />
          <div className="relative flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div className="min-w-0">
              <div className="inline-flex items-center gap-1.5 rounded-md bg-white/70 backdrop-blur-sm px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.14em] text-emerald-800 border border-emerald-200">
                <Trophy className="h-3 w-3" />
                Cours validé · suite déverrouillée
              </div>
              <div className="mt-2 text-[13px] text-slate-600">
                Cours suivant
              </div>
              <div className="mt-0.5 font-display text-lg font-semibold text-navy-900 leading-snug">
                {nextModuleData.title}
              </div>
            </div>
            <Link
              href={`/modules/${nextModuleData.slug}`}
              className="inline-flex items-center justify-center gap-2 rounded-xl bg-navy-900 px-5 py-3 text-sm font-semibold text-white hover:bg-navy-800 transition-all hover:translate-x-0.5 motion-reduce:hover:translate-x-0 shrink-0"
            >
              Démarrer le module suivant
              <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
        </section>
      )}

      {/* Leçons en timeline */}
      <section
        className="space-y-5"
        style={{ animation: "fade-up 0.5s ease-out 160ms both" }}
      >
        <header className="flex items-center justify-between">
          <h2 className="font-display text-xl md:text-2xl font-semibold text-navy-900 tracking-tight">
            Leçons
          </h2>
          <span className="text-[12px] text-slate-500">
            {total} au total
          </span>
        </header>

        {!lessons || lessons.length === 0 ? (
          <div className="rounded-2xl border border-navy-100 bg-white px-6 py-12 text-center shadow-soft">
            <BookOpen className="mx-auto h-7 w-7 text-slate-300" />
            <p className="mt-3 text-sm text-slate-500">
              Les leçons sont en cours de préparation.
            </p>
          </div>
        ) : (
          <ol className="relative space-y-3">
            {/* Timeline verticale */}
            <span
              aria-hidden
              className="absolute left-[19px] top-3 bottom-3 w-px bg-navy-100"
            />
            {lessons.map((l: any, i: number) => {
              const isDone = doneIds.has(l.id);
              const isCurrent = !isDone && nextLesson?.id === l.id;
              return (
                <li
                  key={l.id}
                  className="relative"
                  style={{
                    animation: `fade-up 0.4s ease-out ${200 + i * 40}ms both`,
                  }}
                >
                  <Link
                    href={`/modules/${module.slug}/${l.slug}`}
                    className="group relative flex items-center gap-4 rounded-2xl border border-navy-100 bg-white p-4 md:p-5 shadow-soft transition-all hover:-translate-y-0.5 hover:shadow-raised hover:border-navy-200 motion-reduce:hover:translate-y-0"
                  >
                    {/* Pastille statut */}
                    <span
                      className={`relative z-10 grid place-items-center h-10 w-10 shrink-0 rounded-full text-[13px] font-semibold transition-colors ${
                        isDone
                          ? "bg-emerald-100 text-emerald-700"
                          : isCurrent
                          ? "ring-2 ring-offset-2 ring-offset-white text-navy-900"
                          : "bg-navy-50 text-slate-600"
                      }`}
                      style={
                        isCurrent
                          ? {
                              background: `${accent}1A`,
                              color: "#0E1240",
                              ["--tw-ring-color" as any]: accent,
                            } as React.CSSProperties
                          : undefined
                      }
                    >
                      {isDone ? (
                        <Check className="h-4 w-4" />
                      ) : isCurrent ? (
                        <CircleDot className="h-4 w-4" />
                      ) : (
                        i + 1
                      )}
                    </span>

                    {/* Texte */}
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center gap-2">
                        <span className="text-[10px] font-semibold uppercase tracking-[0.16em] text-slate-400">
                          Leçon {i + 1}
                        </span>
                        {l.duration_min && (
                          <>
                            <span aria-hidden className="h-1 w-1 rounded-full bg-slate-300" />
                            <span className="text-[10px] font-semibold uppercase tracking-[0.16em] text-slate-400">
                              {l.duration_min} min
                            </span>
                          </>
                        )}
                        {isCurrent && (
                          <span
                            className="text-[10px] font-bold uppercase tracking-[0.16em]"
                            style={{ color: "#0E1240" }}
                          >
                            · En cours
                          </span>
                        )}
                      </div>
                      <div className="mt-0.5 font-display text-[15px] md:text-base font-semibold text-navy-900 leading-snug truncate">
                        {l.title}
                      </div>
                    </div>

                    {/* CTA */}
                    <span className="inline-flex items-center gap-1 text-[13px] font-medium text-slate-500 group-hover:text-navy-900 transition-colors shrink-0">
                      {isDone ? "Revoir" : isCurrent ? "Reprendre" : "Lire"}
                      <ArrowRight className="h-3.5 w-3.5 transition-transform group-hover:translate-x-0.5 motion-reduce:group-hover:translate-x-0" />
                    </span>
                  </Link>
                </li>
              );
            })}
          </ol>
        )}
      </section>

      {/* Quizzes & Examens */}
      {totalQuizzes > 0 && (
        <section
          className="space-y-5"
          style={{ animation: "fade-up 0.5s ease-out 240ms both" }}
        >
          <header className="flex items-end justify-between gap-3 flex-wrap">
            <div>
              <h2 className="font-display text-xl md:text-2xl font-semibold text-navy-900 tracking-tight">
                Évaluations
              </h2>
              <p className="mt-1 text-[13.5px] text-slate-600">
                Validez vos acquis avant de passer à l'examen national.
              </p>
            </div>
            {/* Récap des résultats du module */}
            {attempts.length > 0 && (
              <div className="flex items-center gap-2 text-[12px]">
                <span className="inline-flex items-center gap-1.5 rounded-full bg-emerald-50 border border-emerald-200 px-2.5 py-1 text-emerald-800 font-semibold">
                  <Check className="h-3 w-3" />
                  {[...summaryByQuiz.values()].filter((s) => s.bestPassed).length}{" "}
                  / {totalQuizzes} validé
                  {[...summaryByQuiz.values()].filter((s) => s.bestPassed).length > 1
                    ? "s"
                    : ""}
                </span>
                <span className="inline-flex items-center gap-1.5 rounded-full bg-navy-50 border border-navy-100 px-2.5 py-1 text-navy-800 font-medium">
                  <ClipboardCheck className="h-3 w-3" />
                  {attempts.length} tentative{attempts.length > 1 ? "s" : ""}
                </span>
              </div>
            )}
          </header>

          <div className="grid md:grid-cols-2 gap-4 md:gap-5">
            {/* Examens blancs en avant (cards accent) */}
            {examQuizzes.map((q: any) => {
              const s = summaryByQuiz.get(q.id);
              return (
                <Link
                  key={q.id}
                  href={`/quiz/${q.id}`}
                  className="group relative overflow-hidden rounded-2xl border bg-white p-5 md:p-6 shadow-soft transition-all hover:-translate-y-0.5 hover:shadow-raised motion-reduce:hover:translate-y-0"
                  style={{
                    borderColor: `${accent}66`,
                  }}
                >
                  {/* Halo dans le coin */}
                  <div
                    aria-hidden
                    className="absolute -top-12 -right-12 h-32 w-32 rounded-full pointer-events-none opacity-50"
                    style={{
                      background: `radial-gradient(circle, ${accent}55 0%, transparent 70%)`,
                    }}
                  />
                  <div className="relative">
                    <div className="flex items-start justify-between gap-3">
                      <span
                        className="inline-flex items-center gap-1.5 rounded-md px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.14em]"
                        style={{
                          background: `${accent}26`,
                          color: "#0E1240",
                          border: `1px solid ${accent}66`,
                        }}
                      >
                        <Flag className="h-3 w-3" />
                        Mode examen
                      </span>
                      {s && <QuizScoreBadge summary={s} />}
                    </div>
                    <div className="mt-3 font-display text-base font-semibold text-navy-900 leading-snug">
                      {q.title}
                    </div>
                    {q.description && (
                      <p className="mt-1.5 text-[13px] text-slate-600 leading-relaxed line-clamp-2">
                        {q.description}
                      </p>
                    )}
                    <div className="mt-3 flex items-center gap-3 text-[12px] text-slate-500">
                      {q.time_limit_s && (
                        <span className="inline-flex items-center gap-1">
                          <Clock className="h-3 w-3" />
                          {Math.round(q.time_limit_s / 60)} min
                        </span>
                      )}
                      <span className="inline-flex items-center gap-1">
                        <Target className="h-3 w-3" />
                        Seuil {q.pass_threshold} %
                      </span>
                    </div>
                    <div
                      className="mt-4 inline-flex items-center gap-1 text-[13px] font-semibold transition-colors"
                      style={{ color: "#0E1240" }}
                    >
                      {s ? "Refaire l'examen" : "Lancer l'examen"}
                      <ArrowRight className="h-3.5 w-3.5 transition-transform group-hover:translate-x-0.5 motion-reduce:group-hover:translate-x-0" />
                    </div>
                  </div>
                </Link>
              );
            })}

            {/* Quiz d'entraînement */}
            {trainingQuizzes.map((q: any) => {
              const s = summaryByQuiz.get(q.id);
              return (
                <Link
                  key={q.id}
                  href={`/quiz/${q.id}`}
                  className="group rounded-2xl border border-navy-100 bg-white p-5 md:p-6 shadow-soft transition-all hover:-translate-y-0.5 hover:shadow-raised hover:border-navy-200 motion-reduce:hover:translate-y-0"
                >
                  <div className="flex items-start justify-between gap-3">
                    <span className="inline-flex items-center gap-1.5 rounded-md bg-navy-50 px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.14em] text-navy-700 border border-navy-100">
                      <Sparkles className="h-3 w-3" />
                      Entraînement
                    </span>
                    {s && <QuizScoreBadge summary={s} />}
                  </div>
                  <div className="mt-3 font-display text-base font-semibold text-navy-900 leading-snug">
                    {q.title}
                  </div>
                  {q.description && (
                    <p className="mt-1.5 text-[13px] text-slate-600 leading-relaxed line-clamp-2">
                      {q.description}
                    </p>
                  )}
                  <div className="mt-3 flex items-center gap-3 text-[12px] text-slate-500">
                    {q.time_limit_s && (
                      <span className="inline-flex items-center gap-1">
                        <Clock className="h-3 w-3" />
                        {Math.round(q.time_limit_s / 60)} min
                      </span>
                    )}
                    <span className="inline-flex items-center gap-1">
                      <Target className="h-3 w-3" />
                      Seuil {q.pass_threshold} %
                    </span>
                  </div>
                  <div className="mt-4 inline-flex items-center gap-1 text-[13px] font-semibold text-navy-900 group-hover:text-brand-700 transition-colors">
                    {s ? "Refaire le quiz" : "Démarrer"}
                    <ArrowRight className="h-3.5 w-3.5 transition-transform group-hover:translate-x-0.5 motion-reduce:group-hover:translate-x-0" />
                  </div>
                </Link>
              );
            })}
          </div>
        </section>
      )}
    </div>
  );
}

// ---------------------------------------------------------------------
// QuizScoreBadge — pastille de score à droite du chip type de quiz
// ---------------------------------------------------------------------
function QuizScoreBadge({
  summary,
}: {
  summary: {
    bestPercentage: number;
    bestPassed: boolean;
    attemptsCount: number;
  };
}) {
  const passed = summary.bestPassed;
  const pct = Math.round(summary.bestPercentage);
  return (
    <div
      className={`inline-flex items-center gap-1.5 rounded-md px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.12em] border ${
        passed
          ? "bg-emerald-50 text-emerald-800 border-emerald-200"
          : "bg-rose-50 text-rose-800 border-rose-200"
      }`}
      title={
        passed
          ? `Réussi · meilleur score ${pct}%`
          : `À retravailler · meilleur ${pct}%`
      }
    >
      {passed ? <Check className="h-3 w-3" /> : <CircleDot className="h-3 w-3" />}
      {pct}%
      {summary.attemptsCount > 1 && (
        <span className="opacity-70 normal-case font-semibold tracking-normal">
          · {summary.attemptsCount}×
        </span>
      )}
    </div>
  );
}
