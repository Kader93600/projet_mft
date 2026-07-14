import Link from "next/link";
import { redirect, notFound } from "next/navigation";
import { getTranslations, getLocale } from "next-intl/server";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ProgressBar } from "@/components/ui/progress";
import { ResultCelebration } from "@/components/celebration/result-celebration";
import { getRank, xpLevelFromTotal } from "@/lib/gamification/ranks";
import { QuizRewards } from "./quiz-rewards";
import {
  ArrowLeft,
  Clock,
  CheckCircle2,
  XCircle,
  Sparkles,
  Hourglass,
  MessageSquare,
  Award,
  RotateCcw,
  BarChart3,
  LayoutDashboard,
  HelpCircle,
  Info,
  BookOpen,
  ArrowRight,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { FormationBadge } from "@/components/formation/formation-badge";
import { FormationStripe } from "@/components/formation/formation-stripe";
import { resolveFormationFromQuiz } from "@/lib/formation-resolver";
import type { Tables } from "@/lib/database.types";
import type { RewardBadge } from "@/components/celebration/reward-celebration";

export const dynamic = "force-dynamic";

type QuizResultsT = Awaited<ReturnType<typeof getTranslations<"quizResults">>>;

function statusLabel(status: string, t: QuizResultsT): string {
  switch (status) {
    case "in_progress":
      return t("statusInProgress");
    case "completed":
      return t("statusCompleted");
    case "awaiting_review":
      return t("statusAwaitingReview");
    case "graded":
      return t("statusGraded");
    default:
      return status;
  }
}

interface BankChoice {
  id?: string;
  label?: string;
  is_correct?: boolean;
}

interface BankQuestion {
  id: string;
  type: "qcm" | "qr";
  statement: string;
  choices: BankChoice[] | null;
  explanation: string | null;
  max_score: number;
}

interface ResolvedQuestion extends BankQuestion {
  display_order: number;
}

/** Quiz embarqué dans la tentative (cf. select `quiz:quizzes(...)`). */
type QuizEmbed = Pick<
  Tables<"quizzes">,
  | "id"
  | "title"
  | "description"
  | "type"
  | "is_mock_exam"
  | "pass_threshold"
  | "requires_manual_grading"
  | "module_id"
> & {
  module: Pick<Tables<"modules">, "slug" | "title"> | null;
};

/**
 * Tentative telle que sélectionnée ici. `answers` est un jsonb dont le contrat
 * applicatif est `{ [questionId]: choiceId }` (écrit par le quiz runner).
 */
type AttemptRow = Omit<
  Pick<
    Tables<"quiz_attempts">,
    | "id"
    | "user_id"
    | "quiz_id"
    | "score"
    | "total"
    | "percentage"
    | "passed"
    | "qcm_score"
    | "qr_score"
    | "final_percentage"
    | "final_passed"
    | "status"
    | "finished_at"
    | "started_at"
    | "duration_s"
    | "graded_at"
    | "graded_by"
    | "trainer_global_comment"
    | "mode"
    | "answers"
  >,
  "answers"
> & {
  answers: Record<string, string> | null;
  quiz: QuizEmbed | null;
};

/** Réponse rédigée corrigée (cf. select sur `qr_responses`). */
type QrResponseRow = Pick<
  Tables<"qr_responses">,
  | "id"
  | "question_id"
  | "student_answer"
  | "trainer_score"
  | "max_score"
  | "trainer_comment"
  | "graded_at"
>;

/** Lien quiz ↔ banque + question embarquée (cf. select `question:question_bank(...)`). */
type BankLinkRow = Pick<Tables<"quiz_question_bank">, "display_order"> & {
  question: BankQuestion | null;
};

/** Badge fraîchement débloqué (cf. select `badges(name, description, icon, tier)`). */
type FreshBadgeRow = Pick<Tables<"user_badges">, "earned_at"> & {
  badges: Pick<Tables<"badges">, "name" | "description" | "icon" | "tier"> | null;
};

export default async function QuizResultsPage(
  props: {
    params: Promise<{ attemptId: string }>;
    searchParams?: Promise<{ celebrate?: string }>;
  }
) {
  const searchParams = await props.searchParams;
  const params = await props.params;
  const t = await getTranslations("quizResults");
  const locale = await getLocale();
  const dateLocale = locale === "en" ? "en-GB" : "fr-FR";
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  // Charger la tentative + quiz (+ answers JSON)
  const { data: attemptRaw } = await supabase
    .from("quiz_attempts")
    .select(
      `id, user_id, quiz_id, score, total, percentage, passed,
       qcm_score, qr_score, final_percentage, final_passed, status,
       finished_at, started_at, duration_s, graded_at, graded_by,
       trainer_global_comment, mode, answers,
       quiz:quizzes(id, title, description, type, is_mock_exam, pass_threshold,
                    requires_manual_grading, module_id, module:modules(slug, title))`
    )
    .eq("id", params.attemptId)
    .maybeSingle();

  const attempt = (attemptRaw ?? null) as AttemptRow | null;
  if (!attempt) notFound();

  // Sécurité : seul le propriétaire ou le staff/formateur peut voir
  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .single();
  const isStaff =
    profile?.role === "admin" ||
    profile?.role === "super_admin" ||
    profile?.role === "trainer";
  if (attempt.user_id !== user.id && !isStaff) redirect("/dashboard");

  // Charger les QR responses si applicable
  const { data: qrResponsesRaw } = await supabase
    .from("qr_responses")
    .select(
      "id, question_id, student_answer, trainer_score, max_score, trainer_comment, graded_at"
    )
    .eq("attempt_id", params.attemptId);

  const qrResponses = (qrResponsesRaw ?? []) as QrResponseRow[];
  const quiz = attempt.quiz;
  const status = attempt.status ?? "completed";
  const isGraded = status === "graded" || status === "completed";
  const isAwaiting = status === "awaiting_review";

  // ─── Récompenses « live » (badges débloqués + passage de rang) ──────
  // Uniquement au retour direct de soumission (?celebrate=1) sur un quiz noté.
  // Affichées une fois via <QuizRewards> (qui retire le param de l'URL).
  // L'XP/les badges sont attribués en synchrone par les triggers à l'INSERT
  // de la tentative ; on déduit le « avant » sans snapshot client.
  let quizRewards:
    | {
        xpGained: number;
        rankUp: { label: string; emoji: string } | null;
        badges: RewardBadge[];
      }
    | null = null;
  if (isGraded && searchParams?.celebrate === "1" && attempt.finished_at) {
    // Fenêtre tolérante au décalage d'horloge client/serveur.
    const sinceIso = new Date(
      Date.parse(attempt.finished_at) - 60_000
    ).toISOString();
    const [{ data: xpRows }, { data: gami }, { data: freshBadges }] =
      await Promise.all([
        supabase
          .from("xp_events")
          .select("points")
          .eq("user_id", attempt.user_id)
          .eq("ref_id", params.attemptId),
        supabase
          .from("user_gamification")
          .select("total_xp, level")
          .eq("user_id", attempt.user_id)
          .maybeSingle(),
        supabase
          .from("user_badges")
          .select("earned_at, badges(name, description, icon, tier)")
          .eq("user_id", attempt.user_id)
          .gte("earned_at", sinceIso)
          .order("earned_at", { ascending: false })
          .limit(5)
          // Client non typé globalement : supabase-js infère l'embed to-one
          // comme un tableau. On rétablit la vraie forme (objet | null).
          .overrideTypes<FreshBadgeRow[], { merge: false }>(),
      ]);
    const xpGained = (
      (xpRows ?? []) as Pick<Tables<"xp_events">, "points">[]
    ).reduce((s: number, r) => s + (r.points ?? 0), 0);
    const gamification = (gami ?? null) as Pick<
      Tables<"user_gamification">,
      "total_xp" | "level"
    > | null;
    const totalXp = gamification?.total_xp ?? 0;
    const levelAfter = gamification?.level ?? 1;
    const levelBefore = xpLevelFromTotal(totalXp - xpGained);
    const ra = getRank(levelAfter);
    const rb = getRank(levelBefore);
    const rankUp =
      ra.index > rb.index
        ? { label: ra.rank.label, emoji: ra.rank.emoji }
        : null;
    const badges = (freshBadges ?? [])
      .map((r) => r.badges)
      .filter((b): b is NonNullable<FreshBadgeRow["badges"]> => Boolean(b));
    if (rankUp || badges.length > 0) {
      quizRewards = { xpGained, rankUp, badges };
    }
  }

  // Résolution formation pour identification visuelle
  const formationSlug = await resolveFormationFromQuiz(attempt.quiz_id);

  // ─── Charger les questions du quiz pour afficher le détail QCM ────
  // Modèle moderne : quiz_question_bank → question_bank
  // (legacy quiz_questions → questions est ignoré, le quiz_runner stocke
  // déjà la réponse de l'user dans `answers` indexée par question_id qui
  // est le même côté banque ou legacy)
  const { data: bankLinks } = await supabase
    .from("quiz_question_bank")
    .select(
      `display_order,
       question:question_bank(id, type, statement, choices, explanation, max_score)`
    )
    .eq("quiz_id", attempt.quiz_id)
    .order("display_order")
    // Client non typé globalement : supabase-js infère l'embed to-one comme
    // un tableau. On rétablit la vraie forme (objet | null).
    .overrideTypes<BankLinkRow[], { merge: false }>();

  const resolvedQuestions: ResolvedQuestion[] = (bankLinks ?? [])
    .map((l): ResolvedQuestion | null => {
      const q = l.question;
      if (!q) return null;
      return {
        id: q.id,
        type: q.type,
        statement: q.statement,
        choices: q.choices ?? null,
        explanation: q.explanation,
        max_score: q.max_score ?? 1,
        display_order: l.display_order ?? 0,
      };
    })
    .filter((q): q is ResolvedQuestion => Boolean(q));

  // Réponses utilisateur (jsonb { questionId: choiceId })
  const userAnswers: Record<string, string> = attempt.answers ?? {};

  // Stats QCM auto-corrigées
  const qcmQuestions = resolvedQuestions.filter((q) => q.type === "qcm");
  let qcmCorrect = 0;
  qcmQuestions.forEach((q) => {
    const userPick = userAnswers[q.id];
    const correctChoice = (q.choices ?? []).find((c) => c.is_correct);
    if (userPick && correctChoice && userPick === correctChoice.id) {
      qcmCorrect += 1;
    }
  });

  const finalScore = attempt.final_percentage ?? attempt.percentage ?? 0;
  const finalPassed = attempt.final_passed ?? attempt.passed ?? false;
  const passThreshold = quiz?.pass_threshold ?? 70;

  // Durée formatée
  const durationMin = attempt.duration_s
    ? Math.max(1, Math.round(attempt.duration_s / 60))
    : null;

  // ─── Remédiation adaptative : en cas d'ÉCHEC, on propose de revoir les
  // leçons du module rattaché au quiz (les non terminées en priorité).
  // Quiz global (sans module) → pas de ciblage possible, on n'affiche rien.
  type RemediationLesson = { slug: string; title: string; done: boolean };
  let remediation:
    | { moduleSlug: string; moduleTitle: string; lessons: RemediationLesson[] }
    | null = null;
  const quizModuleId: string | null = quiz?.module_id ?? null;
  const quizModule = quiz?.module ?? null;
  if (isGraded && !finalPassed && quizModuleId && quizModule?.slug) {
    const [{ data: remLessons }, { data: remProgress }] = await Promise.all([
      supabase
        .from("lessons")
        .select("id, slug, title, order")
        .eq("module_id", quizModuleId)
        .order("order"),
      supabase
        .from("lesson_progress")
        .select("lesson_id, completed")
        .eq("user_id", attempt.user_id)
        .eq("completed", true),
    ]);
    const doneSet = new Set(
      (
        (remProgress ?? []) as Pick<
          Tables<"lesson_progress">,
          "lesson_id" | "completed"
        >[]
      ).map((r) => r.lesson_id),
    );
    const lessons: RemediationLesson[] = (
      (remLessons ?? []) as Pick<
        Tables<"lessons">,
        "id" | "slug" | "title" | "order"
      >[]
    ).map((l) => ({
      slug: l.slug,
      title: l.title,
      done: doneSet.has(l.id),
    }));
    if (lessons.length > 0) {
      remediation = {
        moduleSlug: quizModule.slug,
        moduleTitle: quizModule.title,
        lessons,
      };
    }
  }

  return (
    <div className="max-w-3xl mx-auto pb-20">
      {/* Récompenses débloquées par cette tentative (badge / rang) */}
      {quizRewards && (
        <QuizRewards
          xpGained={quizRewards.xpGained}
          rankUp={quizRewards.rankUp}
          badges={quizRewards.badges}
        />
      )}
      {/* Stripe couleur formation en haut de page */}
      {formationSlug && <FormationStripe slug={formationSlug} />}

      <div className="space-y-8 pt-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
        <Link
          href="/quiz"
          className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900 transition-colors"
        >
          <ArrowLeft className="h-4 w-4" /> {t("backToQuiz")}
        </Link>

        <header>
          <div className="flex items-center gap-2 mb-2 flex-wrap">
            {formationSlug && (
              <FormationBadge slug={formationSlug} size="sm" icon />
            )}
            {quiz?.is_mock_exam && (
              <Badge tone="gold" size="sm">
                <Award className="h-3 w-3" />
                {t("examBadge")}
              </Badge>
            )}
            <Badge
              tone={isAwaiting ? "gold" : finalPassed ? "success" : "rose"}
              size="sm"
            >
              {statusLabel(status, t)}
            </Badge>
          </div>
          <h1 className="font-display text-2xl md:text-3xl font-semibold text-navy-950 tracking-tight">
            {quiz?.title ?? t("fallbackTitle")}
          </h1>
          {attempt.finished_at && (
            <p className="mt-1 text-sm text-slate-500">
              {t("submittedOn", {
                date: new Date(attempt.finished_at).toLocaleDateString(dateLocale, {
                  day: "2-digit",
                  month: "long",
                  year: "numeric",
                  hour: "2-digit",
                  minute: "2-digit",
                }),
              })}
            </p>
          )}
        </header>

        {/* === Cas 1 : EN ATTENTE de correction === */}
        {isAwaiting && (
          <>
            <Card>
              <CardBody className="text-center py-10 space-y-5">
                <div className="mx-auto h-16 w-16 rounded-2xl bg-gradient-to-br from-gold-400 to-gold-600 text-white flex items-center justify-center shadow-glow-signal animate-in zoom-in duration-500">
                  <Hourglass className="h-8 w-8" />
                </div>
                <div>
                  <h2 className="font-display text-2xl font-semibold text-navy-950">
                    {t("awaitingTitle")}
                  </h2>
                  <p className="mt-2 text-slate-600 max-w-md mx-auto">
                    {t("awaitingDescription")}
                  </p>
                </div>
                <div className="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-gold-50 border border-gold-200 text-gold-900 text-sm">
                  <Clock className="h-4 w-4" />
                  {t("awaitingDelayLabel")} <strong>{t("awaitingDelayValue")}</strong>
                </div>
              </CardBody>
            </Card>

            {/* Aperçu QCM (uniquement si le quiz CONTIENT vraiment des QCM) */}
            {attempt.qcm_score !== null && qcmQuestions.length > 0 && (
              <Card>
                <CardBody>
                  <CardTitle>{t("qcmScoreAutoTitle")}</CardTitle>
                  <p className="text-sm text-slate-600 mt-1 mb-4">
                    {t("qcmScoreAutoDesc")}
                  </p>
                  <div className="flex items-center justify-between gap-4">
                    <ProgressBar value={attempt.qcm_score ?? 0} />
                    <span className="font-display text-2xl font-semibold text-navy-900">
                      {Math.round(attempt.qcm_score ?? 0)}%
                    </span>
                  </div>
                </CardBody>
              </Card>
            )}
          </>
        )}

        {/* === Cas 2 : SCORE PRÊT (graded ou completed sans QR) === */}
        {isGraded && (
          <>
            {/* Hero — célébration émotionnelle selon le palier de score */}
            <ResultCelebration score={finalScore} passed={finalPassed} />

            {/* Récapitulatif détaillé */}
            <Card>
              <CardBody>

                {/* Stats rapides */}
                <div className="mt-7 grid grid-cols-2 sm:grid-cols-3 gap-3 max-w-2xl mx-auto">
                  {qcmQuestions.length > 0 && (
                    <div className="rounded-xl border border-navy-100 bg-ivory p-3">
                      <div className="text-[10px] uppercase tracking-wider text-slate-500 font-semibold">
                        {t("qcmCorrect")}
                      </div>
                      <div className="font-display text-xl font-semibold text-navy-900 mt-1">
                        {qcmCorrect} / {qcmQuestions.length}
                      </div>
                    </div>
                  )}
                  {/* Carte Score QCM : uniquement si vrais QCM dans le quiz */}
                  {attempt.qcm_score !== null && qcmQuestions.length > 0 && (
                    <div className="rounded-xl border border-navy-100 bg-ivory p-3">
                      <div className="text-[10px] uppercase tracking-wider text-slate-500 font-semibold">
                        {t("qcmScore")}
                      </div>
                      <div className="font-display text-xl font-semibold text-navy-900 mt-1">
                        {Math.round(attempt.qcm_score ?? 0)}%
                      </div>
                    </div>
                  )}
                  {/* Carte Rédigées : uniquement si vraies QR + affiche % ET fraction */}
                  {attempt.qr_score !== null && qrResponses.length > 0 && (
                    (() => {
                      const qrMax = qrResponses.reduce(
                        (s: number, r) => s + (r.max_score ?? 0),
                        0
                      );
                      // `attempt.qr_score` est non-null ici (garde ci-dessus) ;
                      // `?? 0` sert uniquement au flow analysis (closure).
                      const qrScore = attempt.qr_score ?? 0;
                      const qrPct =
                        qrMax > 0 ? Math.round((qrScore / qrMax) * 100) : 0;
                      return (
                        <div className="rounded-xl border border-navy-100 bg-ivory p-3">
                          <div className="text-[10px] uppercase tracking-wider text-slate-500 font-semibold">
                            {t("qrScore")}
                          </div>
                          <div className="font-display text-xl font-semibold text-navy-900 mt-1">
                            {qrPct}%
                            <span className="text-xs font-normal text-slate-500 ml-1.5">
                              · {attempt.qr_score}/{qrMax}
                            </span>
                          </div>
                        </div>
                      );
                    })()
                  )}
                  {durationMin !== null && (
                    <div className="rounded-xl border border-navy-100 bg-ivory p-3">
                      <div className="text-[10px] uppercase tracking-wider text-slate-500 font-semibold">
                        {t("duration")}
                      </div>
                      <div className="font-display text-xl font-semibold text-navy-900 mt-1">
                        {durationMin} min
                      </div>
                    </div>
                  )}
                </div>

                {attempt.graded_at && (
                  <div className="mt-5 text-xs text-slate-500">
                    {t("gradedOn", {
                      date: new Date(attempt.graded_at).toLocaleDateString(dateLocale, {
                        day: "2-digit",
                        month: "long",
                        year: "numeric",
                      }),
                    })}
                  </div>
                )}
              </CardBody>
            </Card>

            {/* Commentaire global du formateur */}
            {attempt.trainer_global_comment && (
              <Card variant="gold">
                <CardBody>
                  <div className="flex items-center gap-2 mb-3">
                    <MessageSquare className="h-4 w-4 text-gold-700" />
                    <span className="eyebrow text-gold-800">
                      {t("trainerComment")}
                    </span>
                  </div>
                  <p className="text-navy-900 leading-relaxed whitespace-pre-wrap">
                    {attempt.trainer_global_comment}
                  </p>
                </CardBody>
              </Card>
            )}

            {/* === DÉTAIL DES QCM avec correction visuelle === */}
            {qcmQuestions.length > 0 && (
              <section>
                <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 flex items-center gap-2">
                  <HelpCircle className="h-5 w-5 text-brand-700" />
                  {t("detailedCorrection")}
                  <span className="ml-2 text-sm font-normal text-slate-500">
                    {t("questionCount", { count: qcmQuestions.length })}
                  </span>
                </h2>
                <div className="space-y-3">
                  {qcmQuestions.map((q, idx) => {
                    const userPick = userAnswers[q.id];
                    const correctChoice = (q.choices ?? []).find(
                      (c) => c.is_correct
                    );
                    const isCorrect =
                      userPick && correctChoice && userPick === correctChoice.id;

                    return (
                      <Card
                        key={q.id}
                        className={cn(
                          "overflow-hidden",
                          isCorrect
                            ? "border-emerald-200"
                            : "border-rose-200"
                        )}
                      >
                        <div
                          className={cn(
                            "h-1",
                            isCorrect ? "bg-emerald-500" : "bg-rose-500"
                          )}
                        />
                        <CardBody>
                          <div className="flex items-start justify-between gap-3 mb-3">
                            <div className="flex items-start gap-3 flex-1 min-w-0">
                              <span className="h-7 w-7 shrink-0 rounded-md bg-navy-50 text-navy-700 flex items-center justify-center font-semibold text-xs">
                                {idx + 1}
                              </span>
                              <div className="flex-1 min-w-0">
                                <div className="text-[15px] text-navy-900 leading-relaxed">
                                  {q.statement}
                                </div>
                              </div>
                            </div>
                            {isCorrect ? (
                              <Badge tone="success" size="sm">
                                <CheckCircle2 className="h-3 w-3" /> {t("correct")}
                              </Badge>
                            ) : (
                              <Badge tone="rose" size="sm">
                                <XCircle className="h-3 w-3" /> {t("incorrect")}
                              </Badge>
                            )}
                          </div>

                          {/* Liste des choix avec mise en évidence */}
                          <ul className="space-y-2 mt-4">
                            {(q.choices ?? []).map((c) => {
                              const isUserPick = userPick === c.id;
                              const isRight = !!c.is_correct;

                              return (
                                <li
                                  key={c.id ?? c.label}
                                  className={cn(
                                    "flex items-start gap-3 px-4 py-3 rounded-xl border-2 transition-colors",
                                    isRight &&
                                      "border-emerald-300 bg-emerald-50/60",
                                    !isRight &&
                                      isUserPick &&
                                      "border-rose-300 bg-rose-50/60",
                                    !isRight &&
                                      !isUserPick &&
                                      "border-navy-100 bg-white"
                                  )}
                                >
                                  <span
                                    className={cn(
                                      "h-5 w-5 shrink-0 rounded-full flex items-center justify-center text-[11px] font-bold uppercase mt-0.5",
                                      isRight && "bg-emerald-600 text-white",
                                      !isRight &&
                                        isUserPick &&
                                        "bg-rose-600 text-white",
                                      !isRight &&
                                        !isUserPick &&
                                        "bg-navy-50 text-navy-600"
                                    )}
                                  >
                                    {c.id?.toUpperCase() ?? "?"}
                                  </span>
                                  <div className="flex-1 min-w-0">
                                    <div
                                      className={cn(
                                        "text-sm",
                                        isRight
                                          ? "text-emerald-900 font-medium"
                                          : !isRight && isUserPick
                                          ? "text-rose-900"
                                          : "text-navy-900"
                                      )}
                                    >
                                      {c.label}
                                    </div>
                                    <div className="mt-0.5 text-[11px] flex items-center gap-2 flex-wrap">
                                      {isRight && (
                                        <span className="inline-flex items-center gap-1 text-emerald-700">
                                          <CheckCircle2 className="h-3 w-3" />
                                          {t("goodAnswer")}
                                        </span>
                                      )}
                                      {isUserPick && (
                                        <span
                                          className={cn(
                                            "inline-flex items-center gap-1",
                                            isRight
                                              ? "text-emerald-700"
                                              : "text-rose-700"
                                          )}
                                        >
                                          {isRight ? (
                                            <CheckCircle2 className="h-3 w-3" />
                                          ) : (
                                            <XCircle className="h-3 w-3" />
                                          )}
                                          {t("yourChoice")}
                                        </span>
                                      )}
                                    </div>
                                  </div>
                                </li>
                              );
                            })}
                            {!userPick && (
                              <li className="text-xs text-slate-500 italic px-4">
                                {t("noAnswerGiven")}
                              </li>
                            )}
                          </ul>

                          {/* Explication */}
                          {q.explanation && (
                            <div className="mt-4 rounded-xl border border-brand-200 bg-brand-50/50 p-4">
                              <div className="flex items-center gap-1.5 mb-1.5">
                                <Info className="h-3.5 w-3.5 text-brand-700" />
                                <div className="text-[10px] uppercase tracking-wider text-brand-800 font-semibold">
                                  {t("explanation")}
                                </div>
                              </div>
                              <p className="text-sm text-navy-900 leading-relaxed whitespace-pre-wrap">
                                {q.explanation}
                              </p>
                            </div>
                          )}
                        </CardBody>
                      </Card>
                    );
                  })}
                </div>
              </section>
            )}

            {/* Détails par QR avec correction (si applicable) */}
            {qrResponses.length > 0 && (
              <section>
                <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 flex items-center gap-2">
                  <Sparkles className="h-5 w-5 text-brand-700" />
                  {t("qrCorrectionsTitle")}
                </h2>
                <div className="space-y-3">
                  {qrResponses.map((r, i) => {
                    const ratio = r.max_score
                      ? (r.trainer_score ?? 0) / r.max_score
                      : 0;
                    const tone =
                      ratio >= 0.7
                        ? "success"
                        : ratio >= 0.4
                        ? "gold"
                        : "rose";
                    return (
                      <Card key={r.id}>
                        <CardBody>
                          <div className="flex items-start justify-between gap-3 mb-3">
                            <div className="text-sm font-medium text-navy-900">
                              {t("questionNumber", { n: i + 1 })}
                            </div>
                            <Badge tone={tone} size="sm">
                              {r.trainer_score ?? 0} / {r.max_score}
                            </Badge>
                          </div>
                          {r.student_answer && (
                            <div className="rounded-xl border border-navy-100 bg-ivory p-4">
                              <div className="text-[10px] uppercase tracking-wider text-slate-500 mb-1">
                                {t("yourAnswer")}
                              </div>
                              <p className="text-sm text-navy-900 whitespace-pre-wrap">
                                {r.student_answer}
                              </p>
                            </div>
                          )}
                          {r.trainer_comment && (
                            <div className="mt-3 rounded-xl border border-gold-200 bg-gold-50 p-4">
                              <div className="flex items-center gap-1.5 mb-1">
                                <MessageSquare className="h-3.5 w-3.5 text-gold-700" />
                                <div className="text-[10px] uppercase tracking-wider text-gold-800 font-semibold">
                                  {t("trainerCommentBadge")}
                                </div>
                              </div>
                              <p className="text-sm text-navy-900 whitespace-pre-wrap">
                                {r.trainer_comment}
                              </p>
                            </div>
                          )}
                        </CardBody>
                      </Card>
                    );
                  })}
                </div>
              </section>
            )}
          </>
        )}

        {/* === Remédiation : revoir les leçons du module (échec) === */}
        {remediation && (
          <section>
            <Card variant="gold">
              <CardBody>
                <div className="flex items-center gap-2 mb-1.5">
                  <BookOpen className="h-4 w-4 text-gold-700" />
                  <span className="eyebrow text-gold-800">
                    {t("remediationTitle")}
                  </span>
                </div>
                <p className="text-sm text-slate-600 mb-4">
                  {t("remediationDesc", { module: remediation.moduleTitle })}
                </p>
                <ul className="space-y-2">
                  {remediation.lessons.map((l) => (
                    <li key={l.slug}>
                      <Link
                        href={`/modules/${remediation!.moduleSlug}/${l.slug}`}
                        className={cn(
                          "group flex items-center gap-3 rounded-xl border px-4 py-3 transition-colors",
                          l.done
                            ? "border-navy-100 bg-white hover:border-navy-200"
                            : "border-gold-200 bg-gold-50/50 hover:border-gold-300",
                        )}
                      >
                        <span
                          className={cn(
                            "h-7 w-7 shrink-0 rounded-lg flex items-center justify-center",
                            l.done
                              ? "bg-emerald-50 text-emerald-600"
                              : "bg-gold-100 text-gold-700",
                          )}
                        >
                          {l.done ? (
                            <CheckCircle2 className="h-4 w-4" />
                          ) : (
                            <BookOpen className="h-4 w-4" />
                          )}
                        </span>
                        <span className="flex-1 min-w-0 text-[14px] font-medium text-navy-900 truncate">
                          {l.title}
                        </span>
                        {l.done && (
                          <span className="text-[11px] text-emerald-700 font-medium shrink-0">
                            {t("remediationDone")}
                          </span>
                        )}
                        <ArrowRight className="h-4 w-4 text-slate-400 shrink-0 transition-transform group-hover:translate-x-0.5" />
                      </Link>
                    </li>
                  ))}
                </ul>
              </CardBody>
            </Card>
          </section>
        )}

        {/* CTA — 3 boutons (recommencer / mes résultats / dashboard) */}
        <div className="grid sm:grid-cols-3 gap-3 pt-2">
          {quiz?.id && (
            <Link
              href={`/quiz/${quiz.id}`}
              className="inline-flex items-center justify-center gap-2 rounded-xl border border-navy-200 bg-white px-5 py-3 text-sm font-medium text-navy-900 hover:bg-navy-50 transition-colors"
            >
              <RotateCcw className="h-4 w-4" />
              {t("ctaRestart")}
            </Link>
          )}
          <Link
            href="/stats"
            className="inline-flex items-center justify-center gap-2 rounded-xl border border-navy-200 bg-white px-5 py-3 text-sm font-medium text-navy-900 hover:bg-navy-50 transition-colors"
          >
            <BarChart3 className="h-4 w-4" />
            {t("ctaMyResults")}
          </Link>
          <Link
            href="/dashboard"
            className="inline-flex items-center justify-center gap-2 rounded-xl bg-navy-900 text-white px-5 py-3 text-sm font-medium hover:bg-navy-800 transition-colors"
          >
            <LayoutDashboard className="h-4 w-4" />
            {t("ctaDashboard")}
          </Link>
        </div>
      </div>
    </div>
  );
}
