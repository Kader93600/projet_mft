import { getTranslations } from "next-intl/server";
import { createClient } from "@/lib/supabase/server";
import { FormationBadge } from "@/components/formation/formation-badge";
import { FormationProgress } from "@/components/modules/formation-progress";
import { QuizCard, type QuizCardData } from "@/components/quiz/quiz-card";
import { QuizContinueCard } from "@/components/quiz/quiz-continue-card";
import { ModuleQuizAccordion } from "@/components/quiz/module-quiz-accordion";
import { findFormation, FORMATIONS } from "@/lib/formations-config";
import {
  computeQuizProgress,
  pickNextQuiz,
  type QuizProgress,
} from "@/lib/quiz-progress";
import {
  applyLinearLocking,
  getUnlockMode,
  computeModulePercent,
  computeModuleState,
  getModuleKind,
  type ModuleProgress,
} from "@/lib/module-progress";
import {
  AlertCircle,
  Dumbbell,
  GraduationCap,
  Lock,
  Sparkles,
} from "lucide-react";

export const dynamic = "force-dynamic";

/**
 * Quiz & Examens — refonte 2026-05.
 *
 * Pivot stratégique : la page n'est plus un mur plat de 75 quiz mais
 * un cockpit organisé par formation puis par type d'exercice.
 *
 *  - Hero personnalisé "Bonjour [Prénom], vos quiz et examens."
 *  - QuizContinueCard : reprend le quiz en cours OU le dernier raté
 *  - Par formation :
 *      • Header (badge + progression nb quiz réussis)
 *      • "Préparer l'examen final" : examens blancs synthèse, MSP, banque
 *        entretien — verrouillés grisés tant que les modules de cours ne
 *        sont pas tous terminés
 *      • "Entraînement par module" : accordéons collapsibles par module
 *        (1er ouvert par défaut)
 *  - États visuels par quiz : passed / failed / in-progress / todo /
 *    blocked-attempts / blocked-delay / locked
 */
export default async function QuizListPage() {
  const t = await getTranslations("quiz");
  const supabase = createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  // Profil pour le prénom
  let firstName: string | null = null;
  if (user) {
    const { data: profile } = await supabase
      .from("profiles")
      .select("full_name")
      .eq("id", user.id)
      .maybeSingle();
    firstName = extractFirstName(profile?.full_name ?? null);
  }

  // Formations où le stagiaire est inscrit + formation active
  let enrolledFormationIds: string[] = [];
  let activeFormationSlug: string | null = null;
  if (user) {
    const { data: enrollments } = await supabase
      .from("enrollments")
      .select("formation_id, formation_slug, status, created_at")
      .eq("user_id", user.id)
      .neq("status", "refuse")
      .neq("status", "abandon")
      .order("created_at", { ascending: false });
    enrolledFormationIds = (enrollments ?? [])
      .map((e: any) => e.formation_id as string)
      .filter(Boolean);
    const sorted = [...(enrollments ?? [])].sort((a: any, b: any) => {
      const ar = a.status === "en_cours" ? 0 : 1;
      const br = b.status === "en_cours" ? 0 : 1;
      if (ar !== br) return ar - br;
      return (
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
      );
    });
    activeFormationSlug = (sorted[0] as any)?.formation_slug ?? null;
  }

  // Filtrage par formations du stagiaire
  let allowedModuleIds: string[] = [];
  let links: any[] = [];
  if (enrolledFormationIds.length > 0) {
    const { data: linkRows } = await supabase
      .from("formation_modules")
      .select("module_id, display_order, formation:formations(slug)")
      .in("formation_id", enrolledFormationIds);
    links = linkRows ?? [];
    allowedModuleIds = Array.from(
      new Set(links.map((l: any) => l.module_id as string))
    );
  }

  // Données catalogue (filtrées)
  const noModules = allowedModuleIds.length === 0;
  const [
    { data: quizzesRaw },
    { data: modulesRaw },
    { data: lessonsRaw },
  ] = noModules
    ? [
        { data: [] as any[] },
        { data: [] as any[] },
        { data: [] as any[] },
      ]
    : await Promise.all([
        supabase
          .from("quizzes")
          .select(
            "id, title, description, type, is_mock_exam, pass_threshold, time_limit_s, max_attempts, retake_delay_hours, module_id, modules(title, slug)"
          )
          .in("module_id", allowedModuleIds)
          .order("type", { ascending: false }),
        supabase
          .from("modules")
          .select("id, slug, title, summary")
          .in("id", allowedModuleIds)
          .order("order"),
        supabase
          .from("lessons")
          .select("id, module_id")
          .in("module_id", allowedModuleIds),
      ]);

  // Tentatives utilisateur (1 requête, agrégée côté JS)
  let userAttempts: any[] = [];
  let userLessonViews: { lesson_id: string; completed: boolean }[] = [];
  // Source secondaire : lesson_progress (clic explicite "Marquer terminé")
  // Cf. /modules — on fait l'union des 2 tables pour éviter le désaccord
  // entre /modules (déverrouillé) et /quiz (verrouillé) signalé par le client.
  let lessonProgressDoneIds: Set<string> = new Set();
  if (user) {
    const [
      { data: attempts },
      { data: views },
      { data: progressRows },
    ] = await Promise.all([
      supabase
        .from("quiz_attempts")
        .select("id, quiz_id, percentage, passed, started_at, finished_at")
        .eq("user_id", user.id),
      supabase
        .from("lesson_views")
        .select("lesson_id, completed")
        .eq("user_id", user.id)
        .eq("completed", true),
      supabase
        .from("lesson_progress")
        .select("lesson_id, completed")
        .eq("user_id", user.id)
        .eq("completed", true),
    ]);
    userAttempts = attempts ?? [];
    userLessonViews = views ?? [];
    lessonProgressDoneIds = new Set(
      (progressRows ?? []).map((r: any) => r.lesson_id as string)
    );
  }

  // Index module → formation, module → ordre
  const formationByModule = new Map<string, string>();
  const orderByModule = new Map<string, number>();
  (links ?? []).forEach((l: any) => {
    if (l.formation?.slug && !formationByModule.has(l.module_id)) {
      formationByModule.set(l.module_id, l.formation.slug);
    }
    if (l.display_order != null && !orderByModule.has(l.module_id)) {
      orderByModule.set(l.module_id, l.display_order);
    }
  });

  // Index module → lessons (pour calculer module state pour le verrouillage)
  const lessonsByModule = new Map<string, string[]>();
  (lessonsRaw ?? []).forEach((l: any) => {
    if (!lessonsByModule.has(l.module_id)) lessonsByModule.set(l.module_id, []);
    lessonsByModule.get(l.module_id)!.push(l.id);
  });
  // Union : leçon "done" si lesson_views.completed OR lesson_progress.completed
  const completedLessonIds = new Set<string>([
    ...userLessonViews.map((v) => v.lesson_id),
    ...lessonProgressDoneIds,
  ]);

  // Index module → quizzes
  const quizzesByModule = new Map<string, any[]>();
  (quizzesRaw ?? []).forEach((q: any) => {
    if (!quizzesByModule.has(q.module_id))
      quizzesByModule.set(q.module_id, []);
    quizzesByModule.get(q.module_id)!.push(q);
  });

  // Pour le verrouillage des examens synthèse/final : on a besoin du
  // ModuleProgress de chaque module pour savoir si tous les "course" sont done.
  // (Précalculs hors map pour éviter les Set recréés par module.)
  const passedQuizIds = new Set(
    userAttempts.filter((a) => a.passed).map((a) => a.quiz_id)
  );
  // Quiz essayés (au moins 1 attempt) — utilisé en mode 'flexible' (Capacité ≤ 3,5 t)
  const attemptedQuizIds = new Set(userAttempts.map((a) => a.quiz_id));

  const modulesProgress: ModuleProgress[] = (modulesRaw ?? []).map((m: any) => {
    const lessonIds = lessonsByModule.get(m.id) ?? [];
    const quizIds = (quizzesByModule.get(m.id) ?? []).map((q: any) => q.id);
    const lessonsTotal = lessonIds.length;
    const lessonsDone = lessonIds.filter((id) =>
      completedLessonIds.has(id)
    ).length;
    const quizzesTotal = quizIds.length;
    const quizzesPassed = quizIds.filter((id: string) =>
      passedQuizIds.has(id)
    ).length;
    const quizzesAttempted = quizIds.filter((id: string) =>
      attemptedQuizIds.has(id)
    ).length;
    const hasAnyAttempt =
      lessonsDone > 0 ||
      quizzesPassed > 0 ||
      lessonIds.some((id) => completedLessonIds.has(id)) ||
      quizIds.some((id: string) =>
        userAttempts.some((a) => a.quiz_id === id)
      );

    // Mode de déverrouillage : 'flexible' pour Capacité ≤ 3,5 t,
    // 'strict' ailleurs (révision client 2026-05).
    const formationSlug = formationByModule.get(m.id);
    const unlockMode = getUnlockMode(formationSlug);

    const baseState = computeModuleState({
      lessonsTotal,
      lessonsDone,
      quizzesTotal,
      quizzesPassed,
      quizzesAttempted,
      hasAnyAttempt,
      unlockMode,
    });
    return {
      slug: m.slug,
      id: m.id,
      kind: getModuleKind(m.slug),
      order: orderByModule.get(m.id) ?? 0,
      lessonsTotal,
      lessonsDone,
      quizzesTotal,
      quizzesPassed,
      quizzesAttempted,
      percent: computeModulePercent({
        lessonsTotal,
        lessonsDone,
        quizzesTotal,
        quizzesPassed,
        quizzesAttempted,
        unlockMode,
      }),
      state: baseState,
      lastTouchedAt: null,
      formationSlug,
    };
  });

  // Verrouillage linéaire par formation
  const moduleStateById = new Map<string, ModuleProgress["state"]>();
  for (const f of FORMATIONS) {
    const inForm = modulesProgress.filter(
      (m) => formationByModule.get(m.id) === f.slug
    );
    const locked = applyLinearLocking(inForm);
    locked.forEach((m) => moduleStateById.set(m.id, m.state));
  }

  // Maintenant on construit, pour chaque quiz, son QuizCardData + QuizProgress
  // en sachant si l'examen synthèse/final est verrouillé (parcours).
  type EnrichedQuiz = {
    quiz: QuizCardData & {
      module_id: string | null;
      module_title: string | null;
      module_slug: string | null;
      module_order: number;
    };
    progress: QuizProgress;
  };

  const enrichedQuizzes: EnrichedQuiz[] = (quizzesRaw ?? []).map((q: any) => {
    const moduleSlug: string | null = q.modules?.slug ?? null;
    const moduleId: string | null = q.module_id ?? null;
    const formationSlug = moduleId ? formationByModule.get(moduleId) ?? null : null;
    const moduleKind = moduleSlug ? getModuleKind(moduleSlug) : "course";

    // Détermination du exam_kind fonctionnel
    let exam_kind: QuizCardData["exam_kind"] = null;
    if (moduleKind === "final" && moduleSlug?.includes("dossier-pro")) {
      exam_kind = "entretien";
    } else if (moduleKind === "final") {
      exam_kind = "msp";
    } else if (moduleKind === "exam") {
      exam_kind = "synthese";
    } else if (q.type === "examen" || q.is_mock_exam) {
      exam_kind = "module-exam";
    }

    // Verrouillage parcours : un quiz est verrouillé si son module est verrouillé
    const moduleState = moduleId ? moduleStateById.get(moduleId) : undefined;
    const lockedByCurriculum = moduleState === "locked";

    const progress = computeQuizProgress(
      {
        id: q.id,
        max_attempts: q.max_attempts ?? null,
        retake_delay_hours: q.retake_delay_hours ?? null,
      },
      userAttempts,
      lockedByCurriculum
    );

    const quiz: EnrichedQuiz["quiz"] = {
      id: q.id,
      title: q.title,
      description: q.description ?? null,
      type: q.type,
      is_mock_exam: q.is_mock_exam ?? null,
      pass_threshold: q.pass_threshold,
      time_limit_s: q.time_limit_s ?? null,
      formation_slug: formationSlug,
      exam_kind,
      module_id: moduleId,
      module_title: q.modules?.title ?? null,
      module_slug: moduleSlug,
      module_order: moduleId ? orderByModule.get(moduleId) ?? 0 : 0,
    };

    return { quiz, progress };
  });

  // Continue card : choisit le quiz à reprendre (toutes formations confondues)
  const continueCandidate = pickNextQuiz(
    enrichedQuizzes
      .filter((eq) => eq.progress.state === "in-progress" || eq.progress.state === "failed")
      .map((eq) => eq.progress)
  );
  const continueQuiz = continueCandidate
    ? enrichedQuizzes.find((eq) => eq.progress.quiz_id === continueCandidate.quiz_id)
    : null;

  // Groupement par formation, puis par module pour l'entraînement
  const grouped = FORMATIONS.map((f) => {
    const ofFormation = enrichedQuizzes.filter(
      (eq) => eq.quiz.formation_slug === f.slug
    );

    // Quiz "examen final" : modules de type final/exam
    const examFinal = ofFormation.filter(
      (eq) =>
        eq.quiz.exam_kind === "synthese" ||
        eq.quiz.exam_kind === "msp" ||
        eq.quiz.exam_kind === "entretien"
    );

    // Quiz "entraînement + examen blanc module" : restent par module
    const trainings = ofFormation.filter(
      (eq) =>
        eq.quiz.exam_kind !== "synthese" &&
        eq.quiz.exam_kind !== "msp" &&
        eq.quiz.exam_kind !== "entretien"
    );

    // Regroupement par module (id + ordre + titre)
    const byModule = new Map<
      string,
      {
        moduleId: string;
        moduleTitle: string;
        moduleSlug: string;
        moduleOrder: number;
        items: EnrichedQuiz[];
      }
    >();
    trainings.forEach((eq) => {
      if (!eq.quiz.module_id || !eq.quiz.module_title) return;
      const key = eq.quiz.module_id;
      if (!byModule.has(key)) {
        byModule.set(key, {
          moduleId: eq.quiz.module_id,
          moduleTitle: eq.quiz.module_title,
          moduleSlug: eq.quiz.module_slug ?? "",
          moduleOrder: eq.quiz.module_order,
          items: [],
        });
      }
      byModule.get(key)!.items.push(eq);
    });
    const trainingModules = Array.from(byModule.values()).sort(
      (a, b) => a.moduleOrder - b.moduleOrder
    );

    // Comptes pour la barre de progression formation
    const totalQuizzes = ofFormation.length;
    const passedQuizzes = ofFormation.filter(
      (eq) => eq.progress.state === "passed"
    ).length;

    return {
      formation: f,
      examFinal,
      trainingModules,
      totalQuizzes,
      passedQuizzes,
    };
  }).filter((g) => g.totalQuizzes > 0);

  // Tri : formation active en premier
  if (activeFormationSlug) {
    grouped.sort((a, b) => {
      if (a.formation.slug === activeFormationSlug) return -1;
      if (b.formation.slug === activeFormationSlug) return 1;
      return 0;
    });
  }

  // Quizzes orphelins (sans formation rattachée)
  const orphans = enrichedQuizzes.filter((eq) => !eq.quiz.formation_slug);

  return (
    <div className="space-y-10 md:space-y-12">
      {/* ----- Hero personnalisé ----- */}
      <header>
        <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-700">
          {t("evaluationEyebrow")}
        </span>
        <h1 className="mt-2 font-display text-[28px] md:text-4xl font-semibold text-navy-950 tracking-tight leading-tight">
          {firstName ? t("helloName", { name: firstName }) : t("helloAnonymous")}{" "}
          <span className="text-slate-600 font-normal">
            {t("helloSuffix")}
          </span>
        </h1>
        <p className="mt-2 max-w-2xl text-[14px] text-slate-600 leading-relaxed">
          {t("heroDescription")}
        </p>
      </header>

      {/* ----- Continue Card ----- */}
      {continueQuiz && (
        <QuizContinueCard
          progress={continueQuiz.progress}
          quiz={{
            id: continueQuiz.quiz.id,
            title: continueQuiz.quiz.title,
            description: continueQuiz.quiz.description,
            pass_threshold: continueQuiz.quiz.pass_threshold,
            time_limit_s: continueQuiz.quiz.time_limit_s,
            formation_slug: continueQuiz.quiz.formation_slug ?? null,
            module_title: continueQuiz.quiz.module_title,
          }}
        />
      )}

      {/* ----- Sections par formation ----- */}
      {grouped.map((g, gi) => (
        <FormationQuizSection
          key={g.formation.slug}
          formationSlug={g.formation.slug}
          examFinal={g.examFinal}
          trainingModules={g.trainingModules}
          totalQuizzes={g.totalQuizzes}
          passedQuizzes={g.passedQuizzes}
          isFirst={gi === 0}
          sectionIdx={gi}
          t={t}
        />
      ))}

      {/* ----- Orphelins (admin) ----- */}
      {orphans.length > 0 && (
        <section className="space-y-4">
          <div className="flex items-start gap-3 rounded-2xl bg-amber-50 border border-amber-200 px-4 py-3">
            <AlertCircle className="h-4 w-4 mt-0.5 text-amber-700 shrink-0" />
            <div className="text-[13px] text-amber-900">
              <strong>
                {t("orphansStrong", { count: orphans.length })}
              </strong>
              . {t("orphansStaffOnly")}
            </div>
          </div>
          <div className="space-y-2">
            {orphans.map(({ quiz, progress }) => (
              <QuizCard
                key={quiz.id}
                quiz={quiz}
                progress={progress}
                variant="compact"
              />
            ))}
          </div>
        </section>
      )}

      {/* ----- État vide global ----- */}
      {grouped.length === 0 && orphans.length === 0 && (
        <div className="rounded-3xl border border-navy-100 bg-white px-8 py-16 text-center shadow-soft">
          <Sparkles className="mx-auto h-8 w-8 text-slate-300" />
          <h2 className="mt-4 font-display text-xl font-semibold text-navy-900">
            {t("emptyTitle")}
          </h2>
          <p className="mt-2 text-sm text-slate-600 max-w-md mx-auto">
            {t("emptyHint")}
          </p>
        </div>
      )}
    </div>
  );
}

// ---------------------------------------------------------------------
// Section formation — examens finaux + entraînements par module
// ---------------------------------------------------------------------

type QuizT = Awaited<ReturnType<typeof getTranslations<"quiz">>>;

function FormationQuizSection({
  formationSlug,
  examFinal,
  trainingModules,
  totalQuizzes,
  passedQuizzes,
  isFirst,
  sectionIdx,
  t,
}: {
  formationSlug: string;
  examFinal: { quiz: any; progress: QuizProgress }[];
  trainingModules: {
    moduleId: string;
    moduleTitle: string;
    moduleSlug: string;
    items: { quiz: any; progress: QuizProgress }[];
  }[];
  totalQuizzes: number;
  passedQuizzes: number;
  isFirst: boolean;
  sectionIdx: number;
  t: QuizT;
}) {
  const f = findFormation(formationSlug);
  if (!f) return null;
  const allFinalLocked =
    examFinal.length > 0 &&
    examFinal.every((q) => q.progress.state === "locked");

  return (
    <section
      className="space-y-6"
      style={{
        animation: `fade-up 0.5s ease-out ${sectionIdx * 80}ms both`,
      }}
    >
      {/* Header formation */}
      <div className="flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
        <div className="min-w-0">
          <FormationBadge slug={formationSlug} size="lg" icon withTitle />
          {f.tagline && (
            <p className="mt-2 text-[14px] text-slate-600 leading-relaxed max-w-2xl">
              {f.tagline}
            </p>
          )}
        </div>
        <div className="md:w-72 shrink-0">
          <FormationProgress
            formationSlug={formationSlug}
            modulesTotal={totalQuizzes}
            modulesDone={passedQuizzes}
          />
          <span className="mt-1.5 inline-block text-[11px] text-slate-500">
            {t("passedOver", { passed: passedQuizzes, total: totalQuizzes })}
          </span>
        </div>
      </div>

      {/* Préparer l'examen final */}
      {examFinal.length > 0 && (
        <div className="space-y-3">
          <div className="flex flex-wrap items-baseline justify-between gap-3">
            <h3 className="font-display text-[15px] font-semibold text-navy-900 tracking-tight inline-flex items-center gap-1.5">
              <GraduationCap className="h-4 w-4 text-amber-700" />
              {t("prepFinalExam")}
            </h3>
            {allFinalLocked && (
              <span className="inline-flex items-center gap-1.5 text-[12px] text-slate-500">
                <Lock className="h-3 w-3" />
                {t("lockedAfterCourses")}
              </span>
            )}
          </div>
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 md:gap-5">
            {examFinal.map(({ quiz, progress }) => (
              <QuizCard
                key={quiz.id}
                quiz={quiz}
                progress={progress}
                variant="featured"
              />
            ))}
          </div>
        </div>
      )}

      {/* Entraînement par module */}
      {trainingModules.length > 0 && (
        <div className="space-y-3">
          <div className="flex items-baseline gap-2">
            <h3 className="font-display text-[15px] font-semibold text-navy-900 tracking-tight inline-flex items-center gap-1.5">
              <Dumbbell className="h-4 w-4 text-navy-700" />
              {t("trainingByModule")}
            </h3>
            <span className="text-[12px] text-slate-500">
              {t("moduleCount", { count: trainingModules.length })}
            </span>
          </div>
          <div className="space-y-2.5">
            {trainingModules.map((mod, i) => (
              <ModuleQuizAccordion
                key={mod.moduleId}
                moduleTitle={mod.moduleTitle}
                moduleSlug={mod.moduleSlug}
                quizzes={mod.items.map((it) => ({
                  quiz: it.quiz,
                  progress: it.progress,
                }))}
                defaultOpen={isFirst && i === 0}
              />
            ))}
          </div>
        </div>
      )}
    </section>
  );
}

// ---------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------

function extractFirstName(fullName: string | null): string | null {
  if (!fullName) return null;
  const trimmed = fullName.trim();
  if (!trimmed) return null;
  const first = trimmed.split(/\s+/)[0];
  if (!first) return null;
  return first
    .toLowerCase()
    .split("-")
    .map((p) => (p ? p[0].toUpperCase() + p.slice(1) : p))
    .join("-");
}
