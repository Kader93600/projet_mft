import Link from "next/link";
import { redirect, notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ProgressBar, RadialProgress } from "@/components/ui/progress";
import {
  ArrowLeft,
  Clock,
  CheckCircle2,
  AlertTriangle,
  Sparkles,
  Hourglass,
  MessageSquare,
  Award,
} from "lucide-react";
import { cn, scoreColor } from "@/lib/utils";
import { FormationBadge } from "@/components/formation/formation-badge";
import { FormationStripe } from "@/components/formation/formation-stripe";
import { resolveFormationFromQuiz } from "@/lib/formation-resolver";

export const dynamic = "force-dynamic";

const STATUS_LABELS: Record<string, string> = {
  in_progress: "En cours",
  completed: "Terminé",
  awaiting_review: "En attente de correction",
  graded: "Corrigé",
};

export default async function QuizResultsPage({
  params,
}: {
  params: { attemptId: string };
}) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  // Charger la tentative + quiz
  const { data: attempt } = await supabase
    .from("quiz_attempts")
    .select(
      `id, user_id, quiz_id, score, total, percentage, passed,
       qcm_score, qr_score, final_percentage, final_passed, status,
       finished_at, started_at, duration_s, graded_at, graded_by,
       trainer_global_comment, mode,
       quiz:quizzes(title, description, type, is_mock_exam, pass_threshold,
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
  const isGraded = status === "graded";
  const isAwaiting = status === "awaiting_review";

  // Résolution formation pour identification visuelle
  const formationSlug = await resolveFormationFromQuiz(attempt.quiz_id);

  return (
    <div className="max-w-3xl mx-auto">
      {/* Stripe couleur formation en haut de page */}
      {formationSlug && <FormationStripe slug={formationSlug} />}

      <div className="space-y-8 pt-6">
      <Link
        href="/quiz"
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
      >
        <ArrowLeft className="h-4 w-4" /> Retour aux quiz
      </Link>

      <header>
        <div className="flex items-center gap-2 mb-2 flex-wrap">
          {formationSlug && (
            <FormationBadge slug={formationSlug} size="sm" icon />
          )}
          {quiz?.is_mock_exam && (
            <Badge tone="gold" size="sm">
              <Award className="h-3 w-3" />
              Examen blanc
            </Badge>
          )}
          <Badge
            tone={
              isGraded ? "success" : isAwaiting ? "gold" : "slate"
            }
            size="sm"
          >
            {STATUS_LABELS[status]}
          </Badge>
        </div>
        <h1 className="font-display text-2xl md:text-3xl font-semibold text-navy-950 tracking-tight">
          {quiz?.title ?? "Résultats"}
        </h1>
        {attempt.finished_at && (
          <p className="mt-1 text-sm text-slate-500">
            Soumis le{" "}
            {new Date(attempt.finished_at).toLocaleDateString("fr-FR", {
              day: "2-digit",
              month: "long",
              year: "numeric",
              hour: "2-digit",
              minute: "2-digit",
            })}
          </p>
        )}
      </header>

      {/* === Cas 1 : EN ATTENTE de correction === */}
      {isAwaiting && (
        <>
          <Card>
            <CardBody className="text-center py-10 space-y-5">
              <div className="mx-auto h-16 w-16 rounded-2xl bg-gradient-to-br from-gold-400 to-gold-600 text-white flex items-center justify-center shadow-glow-signal">
                <Hourglass className="h-8 w-8" />
              </div>
              <div>
                <h2 className="font-display text-2xl font-semibold text-navy-950">
                  Votre copie est en cours de correction
                </h2>
                <p className="mt-2 text-slate-600 max-w-md mx-auto">
                  Cet examen contient des questions rédigées qui doivent être
                  corrigées par un formateur. Vous recevrez une notification
                  dès que votre note finale sera disponible.
                </p>
              </div>
              <div className="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-gold-50 border border-gold-200 text-gold-900 text-sm">
                <Clock className="h-4 w-4" />
                Délai habituel : <strong>48 à 72 h ouvrées</strong>
              </div>
            </CardBody>
          </Card>

          {/* Aperçu QCM (si quiz mixte, la partie QCM est déjà calculée) */}
          {attempt.qcm_score !== null && (
            <Card>
              <CardBody>
                <CardTitle>Score QCM (auto-corrigé)</CardTitle>
                <p className="text-sm text-slate-600 mt-1 mb-4">
                  Ce score sera combiné avec la note manuelle des questions
                  rédigées pour produire la note finale.
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

          {/* Liste des QR soumises (sans note) */}
          {(qrResponses ?? []).length > 0 && (
            <Card>
              <CardBody>
                <CardTitle>Vos questions rédigées</CardTitle>
                <p className="text-sm text-slate-600 mt-1">
                  {qrResponses!.length} réponse
                  {qrResponses!.length > 1 ? "s" : ""} en attente de correction.
                  La note et les commentaires du formateur seront visibles une
                  fois la copie finalisée.
                </p>
                <ul className="mt-4 space-y-2">
                  {qrResponses!.map((r: any, i: number) => (
                    <li
                      key={r.id}
                      className="flex items-center gap-3 px-4 py-3 rounded-xl bg-ivory border border-navy-100"
                    >
                      <span className="h-7 w-7 rounded-md bg-navy-50 text-navy-700 flex items-center justify-center font-semibold text-xs">
                        {i + 1}
                      </span>
                      <div className="flex-1 min-w-0">
                        <div className="text-sm text-navy-900">
                          Question {i + 1}
                        </div>
                        <div className="text-xs text-slate-500">
                          {r.student_answer
                            ? `${r.student_answer.length} caractères soumis`
                            : "Aucune réponse"}
                        </div>
                      </div>
                      <Badge tone="gold" size="sm">
                        <Hourglass className="h-3 w-3" />
                        En attente
                      </Badge>
                    </li>
                  ))}
                </ul>
              </CardBody>
            </Card>
          )}
        </>
      )}

      {/* === Cas 2 : CORRIGÉ === */}
      {isGraded && (
        <>
          <Card>
            <CardBody className="text-center py-10">
              <div className="flex justify-center">
                <RadialProgress
                  value={attempt.final_percentage ?? attempt.percentage ?? 0}
                  size={140}
                  strokeWidth={12}
                  label={
                    <div className="text-center">
                      <div
                        className={cn(
                          "font-display text-4xl font-semibold",
                          scoreColor(
                            attempt.final_percentage ??
                              attempt.percentage ??
                              0
                          )
                        )}
                      >
                        {Math.round(
                          attempt.final_percentage ?? attempt.percentage ?? 0
                        )}
                        %
                      </div>
                    </div>
                  }
                />
              </div>
              <div className="mt-5 font-display text-2xl font-semibold text-navy-950">
                {attempt.final_passed ?? attempt.passed
                  ? "Félicitations, examen réussi !"
                  : "Continuez la préparation"}
              </div>
              {(attempt.final_passed ?? attempt.passed) ? (
                <Badge tone="success" size="md" className="mt-3 mx-auto">
                  <CheckCircle2 className="h-3 w-3" /> Seuil atteint
                </Badge>
              ) : (
                <Badge tone="rose" size="md" className="mt-3 mx-auto">
                  <AlertTriangle className="h-3 w-3" /> Seuil :{" "}
                  {quiz?.pass_threshold ?? 70}%
                </Badge>
              )}

              {/* Détails QCM/QR si quiz mixte */}
              {attempt.qcm_score !== null && attempt.qr_score !== null && (
                <div className="mt-6 grid grid-cols-2 gap-3 max-w-md mx-auto">
                  <div className="rounded-xl border border-navy-100 bg-ivory p-3">
                    <div className="text-[10px] uppercase tracking-wider text-slate-500">
                      QCM
                    </div>
                    <div className="font-display text-xl font-semibold text-navy-900 mt-1">
                      {Math.round(attempt.qcm_score)}%
                    </div>
                  </div>
                  <div className="rounded-xl border border-navy-100 bg-ivory p-3">
                    <div className="text-[10px] uppercase tracking-wider text-slate-500">
                      Rédigées
                    </div>
                    <div className="font-display text-xl font-semibold text-navy-900 mt-1">
                      {attempt.qr_score}/
                      {(qrResponses ?? []).reduce(
                        (s: number, r: any) => s + (r.max_score ?? 0),
                        0
                      )}
                    </div>
                  </div>
                </div>
              )}

              {attempt.graded_at && (
                <div className="mt-5 text-xs text-slate-500">
                  Corrigé le{" "}
                  {new Date(attempt.graded_at).toLocaleDateString("fr-FR", {
                    day: "2-digit",
                    month: "long",
                    year: "numeric",
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
                    Commentaire du formateur
                  </span>
                </div>
                <p className="text-navy-900 leading-relaxed whitespace-pre-wrap">
                  {attempt.trainer_global_comment}
                </p>
              </CardBody>
            </Card>
          )}

          {/* Détails par QR avec correction */}
          {(qrResponses ?? []).length > 0 && (
            <section>
              <h2 className="font-display text-xl font-semibold text-navy-900 mb-3 flex items-center gap-2">
                <Sparkles className="h-5 w-5 text-brand-700" />
                Vos questions rédigées corrigées
              </h2>
              <div className="space-y-3">
                {qrResponses!.map((r: any, i: number) => {
                  const ratio = r.max_score
                    ? (r.trainer_score ?? 0) / r.max_score
                    : 0;
                  const tone =
                    ratio >= 0.7 ? "success" : ratio >= 0.4 ? "gold" : "rose";
                  return (
                    <Card key={r.id}>
                      <CardBody>
                        <div className="flex items-start justify-between gap-3 mb-3">
                          <div className="text-sm font-medium text-navy-900">
                            Question {i + 1}
                          </div>
                          <Badge tone={tone as any} size="sm">
                            {r.trainer_score ?? 0} / {r.max_score}
                          </Badge>
                        </div>
                        {r.student_answer && (
                          <div className="rounded-xl border border-navy-100 bg-ivory p-4">
                            <div className="text-[10px] uppercase tracking-wider text-slate-500 mb-1">
                              Votre réponse
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
                                Commentaire formateur
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

      {/* CTA */}
      <div className="flex justify-center pt-4 gap-3">
        <Link
          href="/quiz"
          className="inline-flex items-center gap-2 rounded-xl border border-navy-200 px-5 py-2.5 text-sm font-medium text-navy-900 hover:bg-navy-50"
        >
          Retour aux quiz
        </Link>
        <Link
          href="/dashboard"
          className="inline-flex items-center gap-2 rounded-xl bg-navy-900 text-white px-5 py-2.5 text-sm font-medium hover:bg-navy-800"
        >
          Tableau de bord
        </Link>
      </div>
      </div>
    </div>
  );
}
