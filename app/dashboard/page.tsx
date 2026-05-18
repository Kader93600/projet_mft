import Link from "next/link";
import { getTranslations } from "next-intl/server";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ProgressBar, RadialProgress } from "@/components/ui/progress";
import { Button } from "@/components/ui/button";
import { blocTone, scoreColor, formatDate } from "@/lib/utils";
import { SurveyBanner } from "@/components/survey-banner";
import { AnnouncementBanner } from "@/components/announcement-banner";
import { MyFormationsSection } from "@/components/student/my-formations-section";
import { StudentAwaitingReviews } from "@/components/student/awaiting-reviews";
import { PlacementSummary } from "@/components/placement-summary";
import { RecentAchievements } from "@/components/recent-achievements";
import { NextSessionCard } from "@/components/next-session-card";
import { XpWidget } from "@/components/xp-widget";
import {
  BookOpen,
  ClipboardCheck,
  Flame,
  Trophy,
  ArrowRight,
  Clock,
  Target,
  Sparkles,
  TrendingUp,
  Lock,
  CheckCircle2,
} from "lucide-react";
import {
  applyLinearLocking,
  computeModuleState,
  computeModulePercent,
  getModuleKind,
  getUnlockMode,
  type ModuleProgress,
} from "@/lib/module-progress";

export default async function DashboardPage() {
  const t = await getTranslations("dashboard");
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  // Formations du stagiaire (filtrage de la portée)
  const { data: enrollments } = await supabase
    .from("enrollments")
    .select("formation_id")
    .eq("user_id", user.id)
    .not("formation_id", "is", null)
    .not("status", "in", "(refuse,abandon)");
  const enrolledFormationIds = (enrollments ?? [])
    .map((e: any) => e.formation_id as string)
    .filter(Boolean);

  let allowedModuleIds: string[] = [];
  if (enrolledFormationIds.length > 0) {
    const { data: links } = await supabase
      .from("formation_modules")
      .select("module_id")
      .in("formation_id", enrolledFormationIds);
    allowedModuleIds = Array.from(
      new Set((links ?? []).map((l: any) => l.module_id as string))
    );
  }
  const noModules = allowedModuleIds.length === 0;

  const [
    { data: profile },
    { data: modules },
    { data: progress },
    { data: attempts },
    { data: allLessons },
    { data: allModuleQuizzes },
    { data: allModuleAttempts },
    { data: formationModulesOrder },
  ] = await Promise.all([
    supabase.from("profiles").select("*").eq("id", user.id).single(),
    noModules
      ? Promise.resolve({ data: [] as any[] })
      : supabase
          .from("modules")
          .select("id, title, slug, duration_min, bloc_id, blocs(code, title)")
          .in("id", allowedModuleIds)
          .order("bloc_id"),
    supabase.from("lesson_progress").select("lesson_id, completed").eq("user_id", user.id),
    enrolledFormationIds.length > 0
      ? supabase
          .from("quiz_attempts")
          .select("id, percentage, passed, finished_at, quizzes(title)")
          .eq("user_id", user.id)
          .in("formation_id", enrolledFormationIds)
          .order("finished_at", { ascending: false })
          .limit(5)
      : Promise.resolve({ data: [] as any[] }),
    // Toutes les leçons des modules autorisés (pour décompte par module)
    noModules
      ? Promise.resolve({ data: [] as any[] })
      : supabase
          .from("lessons")
          .select("id, module_id")
          .in("module_id", allowedModuleIds),
    // Tous les quizzes des modules autorisés
    noModules
      ? Promise.resolve({ data: [] as any[] })
      : supabase
          .from("quizzes")
          .select("id, module_id")
          .in("module_id", allowedModuleIds),
    // Toutes les tentatives passed/finished du stagiaire (pour les états in-progress / done)
    enrolledFormationIds.length > 0
      ? supabase
          .from("quiz_attempts")
          .select("quiz_id, passed, finished_at")
          .eq("user_id", user.id)
          .in("formation_id", enrolledFormationIds)
      : Promise.resolve({ data: [] as any[] }),
    // Display order des modules dans la formation (pour le verrouillage linéaire)
    // + slug de la formation (pour déterminer le mode 'strict' vs 'flexible'
    //   de déverrouillage — révision client 2026-05).
    enrolledFormationIds.length > 0
      ? supabase
          .from("formation_modules")
          .select("module_id, display_order, formations(slug)")
          .in("formation_id", enrolledFormationIds)
      : Promise.resolve({ data: [] as any[] }),
  ]);

  // ─── Calcul du verrouillage linéaire pour la section "Continuer la formation" ─
  // Index lookup
  const lessonsByModule = new Map<string, string[]>();
  (allLessons ?? []).forEach((l: any) => {
    const arr = lessonsByModule.get(l.module_id) ?? [];
    arr.push(l.id);
    lessonsByModule.set(l.module_id, arr);
  });
  const quizzesByModule = new Map<string, string[]>();
  (allModuleQuizzes ?? []).forEach((q: any) => {
    const arr = quizzesByModule.get(q.module_id) ?? [];
    arr.push(q.id);
    quizzesByModule.set(q.module_id, arr);
  });
  const completedLessonIds = new Set(
    (progress ?? []).filter((p: any) => p.completed).map((p: any) => p.lesson_id)
  );
  const passedQuizIds = new Set(
    (allModuleAttempts ?? []).filter((a: any) => a.passed).map((a: any) => a.quiz_id)
  );
  const attemptedQuizIds = new Set(
    (allModuleAttempts ?? []).map((a: any) => a.quiz_id)
  );
  const orderByModule = new Map<string, number>();
  // module_id → slug de la formation (pour le mode de déverrouillage)
  const formationSlugByModule = new Map<string, string>();
  (formationModulesOrder ?? []).forEach((fm: any) => {
    if (!orderByModule.has(fm.module_id)) {
      orderByModule.set(fm.module_id, fm.display_order ?? 0);
    }
    // Supabase retourne `formations` comme objet (ou array selon le client)
    const formationSlug =
      Array.isArray(fm.formations)
        ? fm.formations[0]?.slug
        : fm.formations?.slug;
    if (formationSlug && !formationSlugByModule.has(fm.module_id)) {
      formationSlugByModule.set(fm.module_id, formationSlug);
    }
  });

  // Construction de la liste ModuleProgress pour applyLinearLocking
  const moduleProgressList: ModuleProgress[] = (modules ?? []).map((m: any) => {
    const lessonIds = lessonsByModule.get(m.id) ?? [];
    const lessonsTotal = lessonIds.length;
    const lessonsDone = lessonIds.filter((id) => completedLessonIds.has(id)).length;
    const quizIds = quizzesByModule.get(m.id) ?? [];
    const quizzesTotal = quizIds.length;
    const quizzesPassed = quizIds.filter((id) => passedQuizIds.has(id)).length;
    const quizzesAttempted = quizIds.filter((id) => attemptedQuizIds.has(id))
      .length;
    const hasAnyAttempt = quizIds.some((id) => attemptedQuizIds.has(id));

    // Mode de déverrouillage : 'flexible' pour Capacité ≤ 3,5 t (révision
    // client 2026-05), 'strict' ailleurs.
    const formationSlug = formationSlugByModule.get(m.id);
    const unlockMode = getUnlockMode(formationSlug);

    const state = computeModuleState({
      lessonsTotal,
      lessonsDone,
      quizzesTotal,
      quizzesPassed,
      quizzesAttempted,
      hasAnyAttempt,
      unlockMode,
    });
    const percent = computeModulePercent({
      lessonsTotal,
      lessonsDone,
      quizzesTotal,
      quizzesPassed,
      quizzesAttempted,
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
      percent,
      state,
      lastTouchedAt: null,
      formationSlug,
    };
  });
  const lockedList = applyLinearLocking(moduleProgressList);
  const stateById = new Map(lockedList.map((p) => [p.id, p.state]));

  // Modules à afficher dans "Continuer la formation" : on garde l'ordre
  // d'origine (par bloc + display_order), tous états confondus, top 6.
  const sortedModules = [...(modules ?? [])].sort((a: any, b: any) => {
    const oa = orderByModule.get(a.id) ?? 9999;
    const ob = orderByModule.get(b.id) ?? 9999;
    return oa - ob;
  });

  // Total de leçons : limité à celles des formations du stagiaire
  const { count: totalLessons } = noModules
    ? { count: 0 }
    : await supabase
        .from("lessons")
        .select("*", { count: "exact", head: true })
        .in("module_id", allowedModuleIds);
  const completedLessons = progress?.filter((p) => p.completed).length || 0;
  const progressPct = totalLessons ? Math.round((completedLessons / totalLessons) * 100) : 0;

  // Note : `percentage` peut être NULL pour les quiz QR-only (en attente de
  // correction formateur). On filtre les tentatives sans pourcentage QCM
  // pour ne pas polluer la moyenne avec des NaN.
  const attemptsWithPct = (attempts ?? []).filter(
    (a: any) => typeof a.percentage === "number"
  );
  const avgScore =
    attemptsWithPct.length > 0
      ? Math.round(
          attemptsWithPct.reduce((s, a: any) => s + a.percentage, 0) /
            attemptsWithPct.length
        )
      : 0;

  const firstName =
    profile?.full_name?.split(" ")[0] || t("studentFallback");

  return (
    <div className="space-y-10">
      {/* Annonces publiées (épinglées d'abord) */}
      <AnnouncementBanner />

      {/* Bannière enquête satisfaction (conditionnelle) */}
      <SurveyBanner progressPct={progressPct} />

      {/* Copies en attente de correction (QR) */}
      <StudentAwaitingReviews />

      {/* Mes formations (multi-formations) */}
      <MyFormationsSection />

      {/* Hero / Welcome */}
      <section className="grid lg:grid-cols-[1.4fr_1fr] gap-4 md:gap-6">
        <Card variant="solid-navy" className="relative overflow-hidden">
          <div className="absolute inset-0 bg-mesh-navy opacity-50" />
          <div className="absolute inset-0 bg-grid-navy opacity-[0.08]" />
          <CardBody className="relative p-6 sm:p-8">
            <div className="flex items-center gap-2 mb-3">
              <Sparkles className="h-4 w-4 text-gold-400" />
              <span className="eyebrow text-gold-300">{t("sessionInProgress")}</span>
            </div>
            <h1 className="font-display text-[26px] sm:text-3xl md:text-4xl font-semibold tracking-tight leading-tight">
              {t("helloName", { name: firstName })}
            </h1>
            <p className="mt-3 text-white/70 text-[15px] max-w-lg leading-relaxed">
              {t("heroIntroBefore")}{" "}
              <span className="relative inline-flex items-baseline">
                <span className="font-display text-2xl font-semibold bg-gradient-to-r from-signal-300 to-signal-500 bg-clip-text text-transparent tabular-nums">
                  {progressPct}%
                </span>
                <span
                  aria-hidden
                  className="absolute -inset-x-1 -bottom-0.5 h-px bg-gradient-to-r from-signal-400/0 via-signal-400/60 to-signal-400/0"
                />
              </span>{" "}
              {t("heroIntroAfter")}
            </p>
            <div className="mt-6 flex flex-col sm:flex-row gap-2.5 sm:gap-3">
              <Link href="/modules" className="contents">
                <Button
                  variant="gold"
                  size="lg"
                  className="group w-full sm:w-auto justify-center"
                >
                  {t("ctaResume")}
                  <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-0.5 motion-reduce:group-hover:translate-x-0" />
                </Button>
              </Link>
              <Link href="/quiz" className="contents">
                <Button
                  size="lg"
                  className="w-full sm:w-auto justify-center bg-white/10 hover:bg-white/15 text-white border border-white/15 shadow-none"
                >
                  {t("ctaQuiz")}
                </Button>
              </Link>
            </div>
          </CardBody>
        </Card>

        <Card className="relative overflow-hidden">
          <CardBody className="flex items-center gap-4 sm:gap-6 h-full p-5 sm:p-6">
            <div className="shrink-0">
              <RadialProgress
                value={progressPct}
                size={96}
                strokeWidth={9}
              />
            </div>
            <div className="min-w-0">
              <div className="eyebrow text-gold-700">{t("overallProgress")}</div>
              <div className="mt-1 font-display text-xl sm:text-2xl font-semibold text-navy-900 tabular-nums">
                {completedLessons} / {totalLessons ?? 0}
              </div>
              <p className="text-sm text-slate-600 mt-0.5">{t("lessonsTerminated")}</p>
              <div className="mt-3 inline-flex items-center gap-1.5 text-xs text-emerald-700 font-medium">
                <TrendingUp className="h-3.5 w-3.5" />
                {t("goodDynamic")}
              </div>
            </div>
          </CardBody>
        </Card>
      </section>

      {/* XP / Niveau / Streak */}
      <XpWidget />

      {/* Prochain rendez-vous d'accompagnement */}
      <NextSessionCard />

      {/* Positionnement initial */}
      <PlacementSummary />

      {/* Badges & certificats récents */}
      <RecentAchievements />

      {/* KPI row */}
      <section className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
        <StatCard
          icon={BookOpen}
          label={t("statLessonsLabel")}
          value={`${completedLessons}`}
          hint={t("statLessonsHint", { total: totalLessons ?? 0 })}
          color="brand"
        />
        <StatCard
          icon={Flame}
          label={t("statProgressLabel")}
          value={`${progressPct}%`}
          hint={t("statProgressHint")}
          color="amber"
        />
        <StatCard
          icon={Trophy}
          label={t("statScoreLabel")}
          value={`${avgScore}%`}
          hint={t("statScoreHint")}
          color="signal"
        />
        <StatCard
          icon={ClipboardCheck}
          label={t("statQuizLabel")}
          value={String(attempts?.length ?? 0)}
          hint={t("statQuizHint")}
          color="emerald"
        />
      </section>

      {/* Continue la formation */}
      <section>
        <div className="flex items-end justify-between mb-5">
          <div>
            <span className="eyebrow text-gold-700">{t("pathEyebrow")}</span>
            <h2 className="mt-1 font-display text-2xl font-semibold text-navy-900 tracking-tight">
              {t("continueFormation")}
            </h2>
          </div>
          <Link
            href="/modules"
            className="text-sm font-medium text-navy-900 hover:text-gold-700 inline-flex items-center gap-1"
          >
            {t("seeAll")}
            <ArrowRight className="h-3.5 w-3.5" />
          </Link>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
          {sortedModules.slice(0, 6).map((m: any) => {
            const state = stateById.get(m.id) ?? "not-started";
            const isLocked = state === "locked";
            const isDone = state === "done";
            const isInProgress = state === "in-progress";

            const ctaLabel = isLocked
              ? t("ctaLocked")
              : isDone
              ? t("ctaReview")
              : isInProgress
              ? t("ctaResumeShort")
              : t("ctaStart");

            const cardClasses = isLocked
              ? "h-full transition-all bg-slate-50 border-slate-200 opacity-70"
              : "h-full transition-all group-hover:-translate-y-0.5 group-hover:shadow-raised";

            const ctaClasses = isLocked
              ? "inline-flex items-center gap-1 text-slate-400"
              : "inline-flex items-center gap-1 group-hover:text-gold-700 transition-colors";

            // Message verrouillé adapté à la formation (révision client 2026-05) :
            // Capacité ≤ 3,5 t = "essayer les exercices suffit" (mode flexible).
            const moduleFormationSlug = formationSlugByModule.get(m.id);
            const lockedHelp =
              getUnlockMode(moduleFormationSlug) === "flexible"
                ? t("lockedHelpFlexible")
                : t("lockedHelpStrict");

            const Wrapper = isLocked
              ? ({ children }: { children: React.ReactNode }) => (
                  <div
                    className="cursor-not-allowed"
                    aria-disabled="true"
                    title={lockedHelp}
                  >
                    {children}
                  </div>
                )
              : ({ children }: { children: React.ReactNode }) => (
                  <Link href={`/modules/${m.slug}`} className="group">
                    {children}
                  </Link>
                );

            return (
              <Wrapper key={m.id}>
                <Card className={cardClasses}>
                  <CardBody className="flex flex-col h-full">
                    <div className="flex items-start justify-between gap-3">
                      <div className="flex items-center gap-2">
                        <Badge tone={blocTone(m.blocs?.code)} size="sm">
                          {m.blocs?.code}
                        </Badge>
                        {isDone && (
                          <Badge tone="success" size="sm">
                            <CheckCircle2 className="h-3 w-3" /> {t("badgeDone")}
                          </Badge>
                        )}
                        {isLocked && (
                          <Badge tone="slate" size="sm">
                            <Lock className="h-3 w-3" /> {t("badgeLocked")}
                          </Badge>
                        )}
                      </div>
                      <span className="inline-flex items-center gap-1 text-xs text-slate-500">
                        <Clock className="h-3 w-3" /> {t("minutes", { min: m.duration_min })}
                      </span>
                    </div>
                    <h3
                      className={
                        "mt-4 font-display text-lg font-semibold leading-snug " +
                        (isLocked ? "text-slate-500" : "text-navy-900")
                      }
                    >
                      {m.title}
                    </h3>
                    <p className="text-xs text-slate-500 mt-1 line-clamp-2">
                      {m.blocs?.title}
                    </p>
                    <div
                      className={
                        "mt-auto pt-5 flex items-center justify-between text-sm font-medium " +
                        (isLocked ? "text-slate-400" : "text-navy-900")
                      }
                    >
                      <span className={ctaClasses}>
                        {isLocked && <Lock className="h-3.5 w-3.5" />}
                        {ctaLabel}
                        {!isLocked && (
                          <ArrowRight className="h-3.5 w-3.5 transition-transform group-hover:translate-x-0.5" />
                        )}
                      </span>
                    </div>
                  </CardBody>
                </Card>
              </Wrapper>
            );
          })}
        </div>
      </section>

      {/* Derniers résultats + Objectif */}
      <section className="grid lg:grid-cols-[1.4fr_1fr] gap-6">
        <div>
          <div className="flex items-end justify-between mb-5">
            <div>
              <span className="eyebrow text-gold-700">{t("activityEyebrow")}</span>
              <h2 className="mt-1 font-display text-2xl font-semibold text-navy-900 tracking-tight">
                {t("recentResults")}
              </h2>
            </div>
            <Link
              href="/stats"
              className="text-sm font-medium text-navy-900 hover:text-gold-700 inline-flex items-center gap-1"
            >
              {t("statisticsLink")}
              <ArrowRight className="h-3.5 w-3.5" />
            </Link>
          </div>

          {attempts && attempts.length > 0 ? (
            <Card>
              <div className="divide-y divide-navy-50">
                {attempts.map((a: any) => (
                  <div
                    key={a.id}
                    className="flex items-center justify-between gap-3 px-4 sm:px-6 py-3.5 sm:py-4"
                  >
                    <div className="min-w-0 flex-1">
                      <div className="font-medium text-navy-900 truncate text-[15px]">
                        {a.quizzes?.title}
                      </div>
                      <div className="flex items-center gap-2 text-xs text-slate-500 mt-0.5">
                        {a.finished_at && (
                          <span className="truncate">
                            {formatDate(a.finished_at)}
                          </span>
                        )}
                        {/* Badge inline mobile (gain de place) */}
                        <span className="sm:hidden">
                          {a.passed ? (
                            <Badge tone="success" size="sm">{t("passed")}</Badge>
                          ) : (
                            <Badge tone="slate" size="sm">{t("toReview")}</Badge>
                          )}
                        </span>
                      </div>
                    </div>
                    <div className="flex items-center gap-3 shrink-0">
                      {/* Badge desktop (caché en mobile) */}
                      <span className="hidden sm:inline">
                        {a.passed ? (
                          <Badge tone="success" size="sm">{t("passed")}</Badge>
                        ) : (
                          <Badge tone="slate" size="sm">{t("toReview")}</Badge>
                        )}
                      </span>
                      <div
                        className={`font-display font-semibold text-lg sm:text-xl tabular-nums ${scoreColor(
                          a.percentage
                        )}`}
                      >
                        {a.percentage}%
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </Card>
          ) : (
            <Card>
              <CardBody className="text-center py-10">
                <div className="mx-auto h-12 w-12 rounded-xl bg-navy-50 text-navy-700 flex items-center justify-center">
                  <ClipboardCheck className="h-5 w-5" />
                </div>
                <p className="mt-4 font-medium text-navy-900">{t("noQuizYet")}</p>
                <p className="text-sm text-slate-600 mt-1">
                  {t("noQuizHelper")}
                </p>
                <Link href="/quiz" className="inline-block mt-5">
                  <Button size="md">{t("ctaStartQuiz")}</Button>
                </Link>
              </CardBody>
            </Card>
          )}
        </div>

        <Card variant="gold">
          <CardBody>
            <div className="flex items-center gap-2">
              <Target className="h-4 w-4 text-gold-700" />
              <span className="eyebrow text-gold-800">{t("weeklyGoalEyebrow")}</span>
            </div>
            <h3 className="mt-3 font-display text-xl font-semibold text-navy-900">
              {t("weeklyGoalTitle")}
            </h3>
            <p className="text-sm text-slate-600 mt-2">
              {t("weeklyGoalDesc")}
            </p>
            <div className="mt-5">
              <ProgressBar value={Math.min(100, (completedLessons % 5) * 20)} variant="gradient" />
              <div className="mt-2 flex justify-between text-xs text-slate-600">
                <span>{t("weeklyProgress", { done: completedLessons % 5 })}</span>
                <span>{t("currentWeek")}</span>
              </div>
            </div>
          </CardBody>
        </Card>
      </section>
    </div>
  );
}

type StatColor = "brand" | "signal" | "amber" | "emerald";

const STAT_COLORS: Record<
  StatColor,
  { iconBg: string; iconText: string; halo: string; bar: string }
> = {
  brand: {
    iconBg: "bg-brand-50",
    iconText: "text-brand-700",
    halo: "rgba(37,48,217,0.18)",
    bar: "bg-brand-500",
  },
  signal: {
    iconBg: "bg-signal-100",
    iconText: "text-signal-800",
    halo: "rgba(159,226,32,0.28)",
    bar: "bg-signal-500",
  },
  amber: {
    iconBg: "bg-amber-100",
    iconText: "text-amber-700",
    halo: "rgba(245,158,11,0.22)",
    bar: "bg-amber-500",
  },
  emerald: {
    iconBg: "bg-emerald-50",
    iconText: "text-emerald-700",
    halo: "rgba(16,185,129,0.22)",
    bar: "bg-emerald-500",
  },
};

function StatCard({
  icon: Icon,
  label,
  value,
  hint,
  color = "brand",
}: {
  icon: any;
  label: string;
  value: string;
  hint?: string;
  color?: StatColor;
}) {
  const c = STAT_COLORS[color];
  return (
    <Card className="relative overflow-hidden group transition-shadow duration-300 hover:shadow-raised">
      {/* Halo radial coloré, doux, animé au hover */}
      <div
        aria-hidden
        className="absolute -top-16 -right-16 h-40 w-40 rounded-full pointer-events-none opacity-60 group-hover:opacity-100 transition-opacity duration-500"
        style={{ background: `radial-gradient(circle, ${c.halo} 0%, transparent 70%)` }}
      />
      {/* Barre verticale d'accent à gauche */}
      <span
        aria-hidden
        className={
          "absolute left-0 top-4 bottom-4 w-[3px] rounded-r-full opacity-80 " + c.bar
        }
      />
      <CardBody className="relative flex items-start gap-3 sm:gap-4 p-4 sm:p-5">
        <div
          className={
            "h-10 w-10 sm:h-11 sm:w-11 rounded-xl flex items-center justify-center shrink-0 transition-transform duration-300 group-hover:scale-105 motion-reduce:group-hover:scale-100 " +
            c.iconBg +
            " " +
            c.iconText
          }
        >
          <Icon className="h-4 w-4 sm:h-5 sm:w-5" />
        </div>
        <div className="min-w-0">
          <div className="text-[10px] sm:text-[11px] uppercase tracking-wider text-slate-500 font-medium leading-tight">
            {label}
          </div>
          <div className="font-display text-2xl sm:text-[28px] font-semibold text-navy-900 mt-0.5 leading-none tabular-nums">
            {value}
          </div>
          {hint && (
            <div className="text-[11px] sm:text-xs text-slate-500 mt-1.5 leading-tight">
              {hint}
            </div>
          )}
        </div>
      </CardBody>
    </Card>
  );
}
