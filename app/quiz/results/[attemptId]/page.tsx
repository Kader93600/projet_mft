import Link from "next/link";
import { redirect, notFound } from "next/navigation";
import { getTranslations, getLocale } from "next-intl/server";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ProgressBar, RadialProgress } from "@/components/ui/progress";
import {
  ArrowLeft,
  Clock,
  CheckCircle2,
  XCircle,
  AlertTriangle,
  Sparkles,
  Hourglass,
  MessageSquare,
  Award,
  RotateCcw,
  BarChart3,
  LayoutDashboard,
  HelpCircle,
  Info,
} from "lucide-react";
import { cn, scoreColor } from "@/lib/utils";
import { FormationBadge } from "@/components/formation/formation-badge";
import { FormationStripe } from "@/components/formation/formation-stripe";
import { resolveFormationFromQuiz } from "@/lib/formation-resolver";

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

export default async function QuizResultsPage({
  params,
}: {
  params: { attemptId: string };
}) {
  const t = await getTranslations("quizResults");
  const locale = await getLocale();
  const dateLocale = locale === "en" ? "en-GB" : "fr-FR";
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  // Charger la tentative + quiz (+ answers JSON)
  const { data: attempt } = await supabase
    .from("quiz_attempts")
    .select(
      `id, user_id, quiz_id, score, total, percentage, passed,
       qcm_score, qr_score, final_percentage, final_passed, status,
       finished_at, started_at, duration_s, graded_at, graded_by,
       trainer_global_comment, mode, answers,
       quiz:quizzes(id, title, description, type, is_mock_exam, pass_threshold,
                    requires_manual_grading)`
    )
    .eq("id", params.attemptId)
    .maybeSingle();

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
  const { data: qrResponses } = await supabase
    .from("qr_responses")
    .select(
      "id, question_id, student_answer, trainer_score, max_score, trainer_comment, graded_at"
    )
    .eq("attempt_id", params.attemptId);

  const quiz = (attempt as any).quiz;
  const status = attempt.status ?? "completed";
  const isGraded = status === "graded" || status === "completed";
  const isAwaiting = status === "awaiting_review";

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
    .order("display_order");

  const resolvedQuestions: ResolvedQuestion[] = (bankLinks ?? [])
    .map((l: any) => {
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
      } as ResolvedQuestion;
    })
    .filter(Boolean) as ResolvedQuestion[];

  // Réponses utilisateur (jsonb { questionId: choiceId })
  const userAnswers: Record<string, string> =
    (attempt as any).answers ?? {};

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

  return (
    <div className="max-w-3xl mx-auto pb-20">
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
            {/* Hero score animé */}
            <Card className="overflow-hidden relative">
              <div
                className="absolute inset-0 pointer-events-none opacity-40"
                style={{
                  background: finalPassed
                    ? "radial-gradient(circle at 50% 0%, rgba(159,226,32,0.18) 0%, transparent 60%)"
                    : "radial-gradient(circle at 50% 0%, rgba(244,114,182,0.12) 0%, transparent 60%)",
                }}
                aria-hidden
              />
              <CardBody className="text-center py-10 relative">
                <div className="flex justify-center animate-in zoom-in duration-700">
                  <RadialProgress
                    value={finalScore}
                    size={160}
                    strokeWidth={14}
                    label={
                      <div className="text-center">
                        <div
                          className={cn(
                            "font-display text-5xl font-semibold",
                            scoreColor(finalScore)
                          )}
                        >
                          {Math.round(finalScore)}
                          <span className="text-2xl">%</span>
                        </div>
                      </div>
                    }
                  />
                </div>
                <div className="mt-6 font-display text-2xl font-semibold text-navy-950">
                  {finalPassed
                    ? quiz?.is_mock_exam
                      ? t("passedMockExam")
                      : t("passedExercise")
                    : t("keepGoing")}
                </div>
                <div className="mt-3">
                  {finalPassed ? (
                    <Badge tone="success" size="md" className="mx-auto">
                      <CheckCircle2 className="h-3 w-3" /> {t("thresholdReached")}
                    </Badge>
                  ) : (
                    <Badge tone="rose" size="md" className="mx-auto">
                      <AlertTriangle className="h-3 w-3" />{" "}
                      {t("threshold", { pct: passThreshold })}
                    </Badge>
                  )}
                </div>

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
                  {attempt.qr_score !== null && (qrResponses ?? []).length > 0 && (
                    (() => {
                      const qrMax = (qrResponses ?? []).reduce(
                        (s: number, r: any) => s + (r.max_score ?? 0),
                        0
                      );
                      const qrPct =
                        qrMax > 0
                          ? Math.round((attempt.qr_score / qrMax) * 100)
                          : 0;
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
            {(qrResponses ?? []).length > 0 && (
              <section>
                <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 flex items-center gap-2">
                  <Sparkles className="h-5 w-5 text-brand-700" />
                  {t("qrCorrectionsTitle")}
                </h2>
                <div className="space-y-3">
                  {qrResponses!.map((r: any, i: number) => {
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
                            <Badge tone={tone as any} size="sm">
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
