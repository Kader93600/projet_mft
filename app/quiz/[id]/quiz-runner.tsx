"use client";
import { useState, useEffect, useMemo, useRef } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ProgressBar, RadialProgress } from "@/components/ui/progress";
import {
  Check, X, Clock, Target, Lightbulb, ArrowRight, ArrowLeft,
  AlertTriangle, Maximize, ShieldAlert, Lock, Flag, Grid3X3,
  CheckCircle2,
} from "lucide-react";
import { cn, scoreColor } from "@/lib/utils";
import { FormationBadge } from "@/components/formation/formation-badge";
import { FormationStripe } from "@/components/formation/formation-stripe";

interface Choice { id: string; label: string; is_correct: boolean; order: number; }
interface Question {
  id: string;
  statement: string;
  explanation?: string | null;
  choices: Choice[];
  type?: "qcm" | "qr";
  source?: "legacy" | "bank";
  max_score?: number;
}
interface Quiz {
  id: string;
  title: string;
  description: string | null;
  type: "entrainement" | "examen";
  time_limit_s: number | null;
  pass_threshold: number;
  is_mock_exam?: boolean;
  max_attempts?: number | null;
  retake_delay_hours?: number;
  shuffle_questions?: boolean;
  shuffle_choices?: boolean;
  require_fullscreen?: boolean;
  show_explanations_mode?: "always" | "after_pass" | "never";
}
interface AttemptState {
  allowed: boolean;
  reason: string | null;
  attempts_used: number;
  attempts_max: number | null;
  next_available_at: string | null;
  last_attempt_at: string | null;
}

function shuffle<T>(arr: T[]): T[] {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

export function QuizRunner({
  quiz,
  questions,
  attemptState,
  formationSlug,
}: {
  quiz: Quiz;
  questions: Question[];
  attemptState: AttemptState | null;
  formationSlug?: string | null;
}) {
  const router = useRouter();
  const [started, setStarted] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [current, setCurrent] = useState(0);
  const [answers, setAnswers] = useState<Record<string, string>>({});
  // Réponses rédigées (QR) — texte libre du stagiaire
  const [qrAnswers, setQrAnswers] = useState<Record<string, string>>({});
  const [finished, setFinished] = useState(false);
  const [remaining, setRemaining] = useState(quiz.time_limit_s ?? 0);
  const [startedAt, setStartedAt] = useState<Date | null>(null);
  const [focusLoss, setFocusLoss] = useState(0);
  const [showFocusWarning, setShowFocusWarning] = useState(false);
  const focusRef = useRef(0);
  const [flagged, setFlagged] = useState<Set<string>>(new Set());
  const [showPalette, setShowPalette] = useState(false);
  const [showReview, setShowReview] = useState(false);
  const [showFsPrompt, setShowFsPrompt] = useState(false);

  const isMock = !!quiz.is_mock_exam;

  // Ordre questions/choix : shuffle si activé (une fois au démarrage)
  const orderedQuestions = useMemo(() => {
    let qs = questions;
    if (quiz.shuffle_questions) qs = shuffle(qs);
    if (quiz.shuffle_choices) {
      qs = qs.map((q) => ({ ...q, choices: shuffle(q.choices) }));
    }
    return qs;
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [started]);

  // Timer
  useEffect(() => {
    if (!started || finished || !quiz.time_limit_s) return;
    const i = setInterval(() => {
      setRemaining((r) => {
        if (r <= 1) {
          clearInterval(i);
          submit();
          return 0;
        }
        return r - 1;
      });
    }, 1000);
    return () => clearInterval(i);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [started, finished]);

  // Anti-triche pour examen blanc : détecte visibilitychange/blur
  useEffect(() => {
    if (!started || finished || !isMock) return;
    function onHide() {
      if (document.hidden) {
        focusRef.current += 1;
        setFocusLoss(focusRef.current);
        setShowFocusWarning(true);
      }
    }
    document.addEventListener("visibilitychange", onHide);
    window.addEventListener("blur", onHide);
    return () => {
      document.removeEventListener("visibilitychange", onHide);
      window.removeEventListener("blur", onHide);
    };
  }, [started, finished, isMock]);

  // Détection de sortie de plein écran en examen blanc → re-prompt
  useEffect(() => {
    if (!started || finished || !isMock || !quiz.require_fullscreen) return;
    function onFsChange() {
      if (!document.fullscreenElement) {
        setShowFsPrompt(true);
      } else {
        setShowFsPrompt(false);
      }
    }
    document.addEventListener("fullscreenchange", onFsChange);
    return () => document.removeEventListener("fullscreenchange", onFsChange);
  }, [started, finished, isMock, quiz.require_fullscreen]);

  // Bloque copie/clic droit en mode examen blanc
  useEffect(() => {
    if (!started || finished || !isMock) return;
    function block(e: Event) { e.preventDefault(); }
    document.addEventListener("contextmenu", block);
    document.addEventListener("copy", block);
    document.addEventListener("cut", block);
    return () => {
      document.removeEventListener("contextmenu", block);
      document.removeEventListener("copy", block);
      document.removeEventListener("cut", block);
    };
  }, [started, finished, isMock]);

  const result = useMemo(() => {
    if (!finished) return null;
    let score = 0;
    orderedQuestions.forEach((q) => {
      const selected = answers[q.id];
      const correct = q.choices.find((c) => c.is_correct)?.id;
      if (selected && selected === correct) score++;
    });
    const total = orderedQuestions.length;
    const percentage = total ? Math.round((score / total) * 100) : 0;
    const passed = percentage >= quiz.pass_threshold;
    return { score, total, percentage, passed };
  }, [finished, answers, orderedQuestions, quiz.pass_threshold]);

  async function start() {
    // Demande fullscreen si requis
    if (isMock && quiz.require_fullscreen && document.documentElement.requestFullscreen) {
      try {
        await document.documentElement.requestFullscreen();
      } catch {}
    }
    setStarted(true);
    setStartedAt(new Date());
  }

  async function submit() {
    if (finished) return;
    setFinished(true);
    const finishedAt = new Date();
    const supabase = createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return;

    // Sépare QCM et QR
    const qcmList = orderedQuestions.filter((q) => (q.type ?? "qcm") === "qcm");
    const qrList = orderedQuestions.filter((q) => q.type === "qr");

    // Score QCM auto-corrigé
    let score = 0;
    qcmList.forEach((q) => {
      const sel = answers[q.id];
      if (sel && q.choices.find((c) => c.is_correct)?.id === sel) score++;
    });
    const totalQcm = qcmList.length;
    const qcmPercentage = totalQcm ? Math.round((score / totalQcm) * 100) : 0;
    const total = orderedQuestions.length;

    const hasQr = qrList.length > 0;
    const mode = isMock ? "blanc" : quiz.type === "examen" ? "examen" : "entrainement";

    // Insert tentative principale
    const { data: inserted, error: insertErr } = await supabase
      .from("quiz_attempts")
      .insert({
        user_id: user.id,
        quiz_id: quiz.id,
        score,
        total: totalQcm,                                // pour le score QCM
        percentage: qcmPercentage,                       // % QCM auto
        passed: hasQr ? null : qcmPercentage >= quiz.pass_threshold,
        duration_s: startedAt ? Math.round((finishedAt.getTime() - startedAt.getTime()) / 1000) : null,
        answers,
        started_at: startedAt?.toISOString(),
        finished_at: finishedAt.toISOString(),
        focus_loss_count: focusRef.current,
        flagged_questions: Array.from(flagged),
        mode,
        // Statut différé si QR présents (sinon graded comme avant)
        status: hasQr ? "awaiting_review" : "graded",
        qcm_score: qcmPercentage,
      } as any)
      .select("id")
      .single();

    if (insertErr || !inserted) {
      // Diagnostic complet côté serveur ET côté UI — avant ce fix, l'échec
      // était silencieux, le stagiaire ne savait pas pourquoi son score
      // n'apparaissait jamais dans /stats.
      console.error("[quiz submit] insert error", {
        message: insertErr?.message,
        details: (insertErr as any)?.details,
        hint: (insertErr as any)?.hint,
        code: (insertErr as any)?.code,
        full: insertErr,
      });

      const code = (insertErr as any)?.code as string | undefined;
      const msg = insertErr?.message ?? "Erreur inconnue";
      let friendly = `Impossible d'enregistrer votre tentative : ${msg}`;
      // Mappings courants pour parler humain
      if (code === "42703") {
        // colonne inexistante
        friendly =
          "La base de données n'est pas à jour (migration manquante). Contactez votre administrateur.";
      } else if (code === "42501" || /row.level security|policy/i.test(msg)) {
        friendly =
          "Vos droits ne permettent pas d'enregistrer cette tentative. Vérifiez que votre formation est bien active dans votre profil.";
      } else if (code === "23502") {
        // not null violation
        friendly = `Champ obligatoire manquant : ${
          (insertErr as any)?.details ?? msg
        }`;
      } else if (code === "23505") {
        friendly = "Cette tentative a déjà été enregistrée.";
      }
      setSubmitError(friendly);
      return;
    }
    const attemptId = inserted.id;

    // Soumettre chaque réponse rédigée via la RPC sécurisée
    if (hasQr) {
      for (const q of qrList) {
        const text = (qrAnswers[q.id] ?? "").trim();
        try {
          await supabase.rpc("submit_qr_response", {
            p_attempt: attemptId,
            p_question: q.id,
            p_answer: text,
          });
        } catch (e) {
          console.error("[submit_qr_response]", q.id, e);
        }
      }
      // Marque la tentative en attente de correction (notif formateurs)
      try {
        await supabase.rpc("mark_attempt_awaiting_review", {
          p_attempt: attemptId,
          p_qcm_score: qcmPercentage,
        });
      } catch (e) {
        console.error("[mark_attempt_awaiting_review]", e);
      }
    }

    // Sort du fullscreen
    if (document.fullscreenElement) {
      try { await document.exitFullscreen(); } catch {}
    }
    // Redirige vers la page résultats (gère les 3 états : completed/awaiting/graded)
    router.push(`/quiz/results/${attemptId}`);
  }

  // ----- Landing -----
  if (!started) {
    const blocked = attemptState && !attemptState.allowed;
    const attemptsLeft =
      attemptState?.attempts_max != null
        ? Math.max(0, attemptState.attempts_max - attemptState.attempts_used)
        : null;
    return (
      <div className="max-w-2xl mx-auto">
        <Card className="overflow-hidden">
          {/* Stripe couleur formation pour identification immédiate */}
          {formationSlug && <FormationStripe slug={formationSlug} />}
          <CardBody className="text-center space-y-5 py-12 px-8">
            <div className="flex items-center justify-center gap-2 flex-wrap">
              {formationSlug && (
                <FormationBadge slug={formationSlug} size="md" icon withTitle />
              )}
              {isMock ? (
                <Badge tone="gold" size="md">
                  <ShieldAlert className="h-3 w-3" /> Examen blanc officiel
                </Badge>
              ) : quiz.type === "examen" ? (
                <Badge tone="gold" size="sm">Mode examen</Badge>
              ) : (
                <Badge tone="navy" size="sm">Entraînement</Badge>
              )}
            </div>
            <h1 className="font-display text-3xl font-semibold text-navy-950 tracking-tight">
              {quiz.title}
            </h1>
            {quiz.description && (
              <p className="text-slate-600 max-w-md mx-auto">{quiz.description}</p>
            )}

            <div className="mt-6 grid grid-cols-3 gap-3 max-w-md mx-auto">
              <Stat label="Questions" value={String(orderedQuestions.length)} />
              {quiz.time_limit_s && (
                <Stat label="Durée" value={`${Math.round(quiz.time_limit_s / 60)} min`} />
              )}
              <Stat label="Seuil" value={`${quiz.pass_threshold}%`} />
            </div>

            {isMock && (
              <div className="mx-auto max-w-md text-left rounded-xl bg-gold-50 border border-gold-200 p-4 text-sm text-navy-900 space-y-2">
                <div className="font-semibold flex items-center gap-2">
                  <Lock className="h-4 w-4 text-gold-700" /> Conditions officielles
                </div>
                <ul className="text-xs text-slate-700 space-y-1 list-disc list-inside">
                  {quiz.shuffle_questions && <li>Questions tirées aléatoirement</li>}
                  {quiz.shuffle_choices && <li>Réponses mélangées</li>}
                  {quiz.require_fullscreen && <li>Plein écran obligatoire</li>}
                  <li>Changement d'onglet détecté et consigné</li>
                  {quiz.retake_delay_hours ? (
                    <li>Délai de {quiz.retake_delay_hours} h entre deux tentatives</li>
                  ) : null}
                  {quiz.max_attempts ? (
                    <li>
                      {quiz.max_attempts} tentative{quiz.max_attempts > 1 ? "s" : ""} maximum
                    </li>
                  ) : null}
                </ul>
              </div>
            )}

            {attemptState && (
              <div className="text-xs text-slate-600">
                {attemptState.attempts_used > 0 && (
                  <>Déjà {attemptState.attempts_used} tentative{attemptState.attempts_used > 1 ? "s" : ""}</>
                )}
                {attemptsLeft !== null && (
                  <>
                    {" · "}
                    <span className="font-semibold">
                      {attemptsLeft} restante{attemptsLeft > 1 ? "s" : ""}
                    </span>
                  </>
                )}
              </div>
            )}

            {blocked ? (
              <div className="rounded-xl bg-rose-50 border border-rose-200 px-4 py-3 text-sm text-rose-800 text-left">
                {attemptState?.reason === "max_attempts" && (
                  <>Vous avez atteint le nombre maximum de tentatives.</>
                )}
                {attemptState?.reason === "retake_delay" && attemptState.next_available_at && (
                  <>
                    Prochaine tentative disponible le{" "}
                    <span className="font-semibold">
                      {new Date(attemptState.next_available_at).toLocaleString("fr-FR", {
                        day: "2-digit", month: "short", year: "numeric", hour: "2-digit", minute: "2-digit",
                      })}
                    </span>
                    .
                  </>
                )}
              </div>
            ) : (
              <div className="pt-4">
                <Button size="lg" onClick={start} className="group">
                  {isMock && quiz.require_fullscreen && (
                    <Maximize className="h-4 w-4" />
                  )}
                  Démarrer
                  <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-0.5" />
                </Button>
              </div>
            )}
          </CardBody>
        </Card>
      </div>
    );
  }

  // ----- Résultats -----
  if (finished && result) {
    const mode = quiz.show_explanations_mode ?? "always";
    const canShow = mode === "always" || (mode === "after_pass" && result.passed);
    return (
      <div className="max-w-2xl mx-auto space-y-6">
        <Card>
          <CardBody className="text-center py-10">
            <div className="flex justify-center">
              <RadialProgress
                value={result.percentage}
                size={128}
                strokeWidth={10}
                label={
                  <div className="text-center">
                    <div className={cn("font-display text-3xl font-semibold", scoreColor(result.percentage))}>
                      {result.percentage}%
                    </div>
                  </div>
                }
              />
            </div>
            <div className="mt-5 font-display text-2xl font-semibold text-navy-900">
              {result.passed ? "Félicitations !" : "Continuez la préparation"}
            </div>
            <p className="text-slate-600 mt-1">
              {result.score} / {result.total} bonnes réponses
            </p>
            <div className="mt-4 flex justify-center gap-2 flex-wrap">
              {result.passed ? (
                <Badge tone="success" size="md">
                  <Check className="h-3 w-3" /> Seuil atteint
                </Badge>
              ) : (
                <Badge tone="slate" size="md">
                  <Target className="h-3 w-3" /> Seuil : {quiz.pass_threshold}%
                </Badge>
              )}
              {isMock && focusLoss > 0 && (
                <Badge tone="slate" size="md">
                  <AlertTriangle className="h-3 w-3" /> {focusLoss} sortie{focusLoss > 1 ? "s" : ""} d'onglet
                </Badge>
              )}
            </div>
          </CardBody>
        </Card>

        {canShow ? (
          <div className="space-y-3">
            <h2 className="font-display text-xl font-semibold text-navy-900">
              Correction détaillée
            </h2>
            {orderedQuestions.map((q, i) => {
              const sel = answers[q.id];
              const correct = q.choices.find((c) => c.is_correct);
              const selectedChoice = q.choices.find((c) => c.id === sel);
              const isOk = sel === correct?.id;
              return (
                <Card key={q.id}>
                  <CardBody>
                    <div className="flex items-start gap-3">
                      <div
                        className={cn(
                          "h-8 w-8 rounded-lg flex items-center justify-center shrink-0 mt-0.5",
                          isOk ? "bg-emerald-100 text-emerald-700" : "bg-rose-100 text-rose-700"
                        )}
                      >
                        {isOk ? <Check className="w-4 h-4" /> : <X className="w-4 h-4" />}
                      </div>
                      <div className="flex-1">
                        <div className="font-medium text-navy-900">
                          Q{i + 1}. {q.statement}
                        </div>
                        <div className="text-sm mt-3 space-y-1.5">
                          <div className="text-slate-700">
                            Votre réponse :{" "}
                            <span className={isOk ? "text-emerald-700 font-medium" : "text-rose-700 font-medium"}>
                              {selectedChoice?.label || "—"}
                            </span>
                          </div>
                          {!isOk && (
                            <div className="text-slate-700">
                              Bonne réponse :{" "}
                              <span className="text-emerald-700 font-medium">
                                {correct?.label}
                              </span>
                            </div>
                          )}
                        </div>
                        {q.explanation && (
                          <div className="mt-3 flex items-start gap-2 rounded-xl bg-gold-50 border border-gold-200 px-3 py-2.5 text-sm text-navy-800">
                            <Lightbulb className="h-4 w-4 text-gold-700 mt-0.5 flex-none" />
                            <span>{q.explanation}</span>
                          </div>
                        )}
                      </div>
                    </div>
                  </CardBody>
                </Card>
              );
            })}
          </div>
        ) : (
          <Card>
            <CardBody className="py-8 text-center text-sm text-slate-600">
              {mode === "never"
                ? "La correction détaillée n'est pas consultable pour cet examen."
                : "Atteignez le seuil de réussite pour débloquer la correction détaillée."}
            </CardBody>
          </Card>
        )}

        <div className="flex gap-3 justify-center pt-4">
          <Link href="/quiz">
            <Button variant="secondary">Retour aux quiz</Button>
          </Link>
          <Link href="/stats">
            <Button>Voir mes résultats</Button>
          </Link>
        </div>
      </div>
    );
  }

  // ----- Écran de relecture avant soumission (examen) -----
  if (showReview) {
    const unanswered = orderedQuestions.filter((q) => !answers[q.id]);
    const flaggedList = orderedQuestions.filter((q) => flagged.has(q.id));
    return (
      <div className="max-w-2xl mx-auto space-y-5">
        {submitError && (
          <div
            role="alert"
            className="rounded-2xl border border-rose-200 bg-rose-50/80 px-4 py-3 flex items-start gap-3"
          >
            <AlertTriangle className="h-5 w-5 text-rose-600 shrink-0 mt-0.5" />
            <div className="flex-1 min-w-0">
              <div className="text-sm font-semibold text-rose-900">
                Soumission échouée
              </div>
              <div className="mt-1 text-sm text-rose-800 leading-relaxed">
                {submitError}
              </div>
            </div>
            <button
              type="button"
              onClick={() => setSubmitError(null)}
              className="text-rose-700 hover:text-rose-900 text-xs font-medium px-2 py-1 rounded hover:bg-rose-100 transition"
              aria-label="Fermer"
            >
              ✕
            </button>
          </div>
        )}
        <Card>
          <CardBody className="space-y-4">
            <div className="text-center">
              <Badge tone="gold" size="md" className="mx-auto">
                <Grid3X3 className="h-3 w-3" /> Relecture avant validation
              </Badge>
              <h2 className="font-display text-2xl font-semibold text-navy-900 mt-3">
                Vérifiez vos réponses
              </h2>
              <p className="text-sm text-slate-600 mt-1">
                {answers && Object.keys(answers).length} / {orderedQuestions.length}{" "}
                question{orderedQuestions.length > 1 ? "s" : ""} répondue
                {Object.keys(answers).length > 1 ? "s" : ""}
                {unanswered.length > 0 && (
                  <>
                    {" · "}
                    <span className="text-rose-700 font-semibold">
                      {unanswered.length} sans réponse
                    </span>
                  </>
                )}
                {flaggedList.length > 0 && (
                  <>
                    {" · "}
                    <span className="text-gold-700 font-semibold">
                      {flaggedList.length} marquée
                      {flaggedList.length > 1 ? "s" : ""} à revoir
                    </span>
                  </>
                )}
              </p>
            </div>

            <div className="grid grid-cols-6 gap-2 sm:grid-cols-10">
              {orderedQuestions.map((qq, idx) => {
                const answered = !!answers[qq.id];
                const flag = flagged.has(qq.id);
                return (
                  <button
                    key={qq.id}
                    type="button"
                    onClick={() => {
                      setCurrent(idx);
                      setShowReview(false);
                    }}
                    className={cn(
                      "h-10 rounded-lg text-xs font-semibold border relative transition-all",
                      answered
                        ? "bg-navy-900 text-white border-navy-900"
                        : "bg-white text-slate-500 border-rose-300"
                    )}
                  >
                    {idx + 1}
                    {flag && (
                      <span className="absolute -top-1 -right-1 h-2.5 w-2.5 bg-gold-500 rounded-full border border-white" />
                    )}
                  </button>
                );
              })}
            </div>

            <div className="flex flex-wrap gap-3 justify-center pt-2 text-xs text-slate-600">
              <span className="flex items-center gap-1">
                <span className="h-3 w-3 rounded bg-navy-900" /> Répondu
              </span>
              <span className="flex items-center gap-1">
                <span className="h-3 w-3 rounded border border-rose-300 bg-white" />{" "}
                Sans réponse
              </span>
              <span className="flex items-center gap-1">
                <span className="h-2.5 w-2.5 rounded-full bg-gold-500" /> Marqué à
                revoir
              </span>
            </div>

            <div className="flex justify-center gap-3 pt-4">
              <Button
                variant="secondary"
                onClick={() => setShowReview(false)}
              >
                <ArrowLeft className="h-4 w-4" /> Continuer
              </Button>
              <Button variant="gold" onClick={submit}>
                <CheckCircle2 className="h-4 w-4" /> Valider définitivement
              </Button>
            </div>
          </CardBody>
        </Card>
      </div>
    );
  }

  // ----- Question -----
  const q = orderedQuestions[current];
  const selected = answers[q.id];
  const isFlagged = flagged.has(q.id);

  function toggleFlag() {
    setFlagged((s) => {
      const next = new Set(s);
      if (next.has(q.id)) next.delete(q.id);
      else next.add(q.id);
      return next;
    });
  }

  async function reEnterFullscreen() {
    if (document.documentElement.requestFullscreen) {
      try {
        await document.documentElement.requestFullscreen();
        setShowFsPrompt(false);
      } catch {}
    }
  }

  return (
    <div className="max-w-2xl mx-auto space-y-5 select-none">
      {/* Bannière erreur soumission — visible en haut, dismissible */}
      {submitError && (
        <div
          role="alert"
          className="rounded-2xl border border-rose-200 bg-rose-50/80 px-4 py-3 flex items-start gap-3"
        >
          <AlertTriangle className="h-5 w-5 text-rose-600 shrink-0 mt-0.5" />
          <div className="flex-1 min-w-0">
            <div className="text-sm font-semibold text-rose-900">
              Soumission échouée
            </div>
            <div className="mt-1 text-sm text-rose-800 leading-relaxed">
              {submitError}
            </div>
          </div>
          <button
            type="button"
            onClick={() => setSubmitError(null)}
            className="text-rose-700 hover:text-rose-900 text-xs font-medium px-2 py-1 rounded hover:bg-rose-100 transition"
            aria-label="Fermer"
          >
            ✕
          </button>
        </div>
      )}

      {/* Re-prompt plein écran */}
      {showFsPrompt && (
        <div className="fixed inset-0 z-50 bg-navy-950/90 backdrop-blur flex items-center justify-center p-4">
          <Card className="max-w-md w-full">
            <CardBody className="text-center space-y-4 py-8">
              <div className="mx-auto h-12 w-12 rounded-2xl bg-rose-50 text-rose-700 flex items-center justify-center">
                <AlertTriangle className="h-6 w-6" />
              </div>
              <div className="font-display text-xl font-semibold text-navy-900">
                Plein écran requis
              </div>
              <p className="text-sm text-slate-600">
                Cet examen blanc doit être passé en plein écran. La sortie a été
                consignée.
              </p>
              <Button onClick={reEnterFullscreen} className="mx-auto">
                <Maximize className="h-4 w-4" /> Reprendre l'examen
              </Button>
            </CardBody>
          </Card>
        </div>
      )}

      {/* Palette flottante */}
      {showPalette && (
        <div className="fixed inset-0 z-40 bg-navy-950/40 backdrop-blur-sm md:hidden" onClick={() => setShowPalette(false)} />
      )}

      {/* Warning de sortie d'onglet (mode examen blanc) */}
      {showFocusWarning && (
        <div className="rounded-xl bg-rose-50 border border-rose-200 px-4 py-3 text-sm text-rose-800 flex items-start gap-2">
          <AlertTriangle className="h-4 w-4 mt-0.5 shrink-0" />
          <div className="flex-1">
            <div className="font-semibold">
              Sortie de l'examen détectée ({focusLoss})
            </div>
            <div className="text-xs">
              Les pertes de focus sont consignées dans votre copie.
            </div>
          </div>
          <button
            onClick={() => setShowFocusWarning(false)}
            className="text-rose-700 hover:text-rose-900 text-xs font-semibold"
          >
            OK
          </button>
        </div>
      )}

      <div className="flex items-center justify-between text-sm">
        <div className="flex items-center gap-2">
          <button
            type="button"
            onClick={() => setShowPalette((v) => !v)}
            className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-xs font-medium text-slate-600 hover:bg-navy-50 border border-navy-100"
            aria-label="Palette des questions"
          >
            <Grid3X3 className="h-3.5 w-3.5" />
            <span>{current + 1} / {orderedQuestions.length}</span>
          </button>
          <button
            type="button"
            onClick={toggleFlag}
            className={cn(
              "inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-xs font-medium border transition",
              isFlagged
                ? "bg-gold-100 text-gold-800 border-gold-300"
                : "text-slate-600 hover:bg-navy-50 border-navy-100"
            )}
            aria-pressed={isFlagged}
          >
            <Flag className="h-3.5 w-3.5" />
            {isFlagged ? "Marquée" : "À revoir"}
          </button>
        </div>
        <div className="flex items-center gap-2">
          {isMock && (
            <Badge tone="gold" size="sm">
              <ShieldAlert className="h-3 w-3" /> Examen blanc
            </Badge>
          )}
          {quiz.time_limit_s && (
            <div
              className={cn(
                "inline-flex items-center gap-1.5 font-mono font-semibold rounded-lg px-2.5 py-1 border",
                remaining < 60
                  ? "text-rose-700 bg-rose-50 border-rose-200"
                  : "text-navy-900 bg-white border-navy-100"
              )}
            >
              <Clock className="w-3.5 h-3.5" />
              {Math.floor(remaining / 60)}:{String(remaining % 60).padStart(2, "0")}
            </div>
          )}
        </div>
      </div>

      <ProgressBar value={((current + 1) / orderedQuestions.length) * 100} variant="gradient" />

      {showPalette && (
        <Card>
          <CardBody className="space-y-3">
            <div className="text-xs font-semibold uppercase tracking-wider text-slate-500">
              Toutes les questions
            </div>
            <div className="grid grid-cols-8 sm:grid-cols-10 gap-1.5">
              {orderedQuestions.map((qq, idx) => {
                const answered = !!answers[qq.id];
                const flag = flagged.has(qq.id);
                const isCurrent = idx === current;
                return (
                  <button
                    key={qq.id}
                    type="button"
                    onClick={() => {
                      setCurrent(idx);
                      setShowPalette(false);
                    }}
                    className={cn(
                      "h-9 rounded-md text-xs font-semibold border relative transition-all",
                      isCurrent
                        ? "ring-2 ring-gold-500"
                        : "",
                      answered
                        ? "bg-navy-900 text-white border-navy-900"
                        : "bg-white text-slate-500 border-rose-200"
                    )}
                  >
                    {idx + 1}
                    {flag && (
                      <span className="absolute -top-1 -right-1 h-2 w-2 bg-gold-500 rounded-full border border-white" />
                    )}
                  </button>
                );
              })}
            </div>
          </CardBody>
        </Card>
      )}

      <Card>
        <CardBody className="space-y-5">
          <div className="flex items-center gap-2 mb-1">
            {q.type === "qr" ? (
              <Badge tone="gold" size="sm">
                Question rédigée
              </Badge>
            ) : (
              <Badge tone="navy" size="sm">
                QCM
              </Badge>
            )}
            {q.type === "qr" && q.max_score && (
              <span className="text-xs text-slate-500">
                Barème : {q.max_score} pt{q.max_score > 1 ? "s" : ""}
              </span>
            )}
          </div>
          <h2 className="font-display text-xl font-semibold text-navy-900 leading-snug whitespace-pre-wrap">
            {q.statement}
          </h2>
          {q.type === "qr" ? (
            <div>
              <textarea
                value={qrAnswers[q.id] ?? ""}
                onChange={(e) =>
                  setQrAnswers({ ...qrAnswers, [q.id]: e.target.value })
                }
                placeholder="Rédigez votre réponse ici…"
                rows={10}
                className="w-full rounded-xl border border-navy-200 bg-white p-4 text-[15px] text-navy-900 placeholder:text-slate-400 focus:border-navy-500 focus:outline-none focus:ring-2 focus:ring-navy-500/20 resize-y min-h-[180px]"
              />
              <div className="mt-2 flex items-center justify-between text-xs text-slate-500">
                <span>
                  {(qrAnswers[q.id] ?? "").length} caractères
                </span>
                <span className="italic">
                  Cette réponse sera corrigée manuellement par votre formateur.
                </span>
              </div>
            </div>
          ) : (
            <div className="space-y-2.5">
              {q.choices.map((c, i) => {
                const letter = String.fromCharCode(65 + i);
                const isSel = selected === c.id;
                return (
                  <button
                    key={c.id}
                    type="button"
                    onClick={() => setAnswers({ ...answers, [q.id]: c.id })}
                    className={cn(
                      "w-full text-left px-4 py-3.5 rounded-xl border flex items-center gap-3 transition-all",
                      isSel
                        ? "border-navy-900 bg-navy-50 ring-2 ring-navy-900/10"
                        : "border-navy-100 bg-white hover:border-navy-300 hover:bg-navy-50/50"
                    )}
                  >
                    <span
                      className={cn(
                        "h-7 w-7 rounded-md font-semibold text-xs flex items-center justify-center shrink-0",
                        isSel
                          ? "bg-navy-900 text-gold-400"
                          : "bg-navy-50 text-navy-700"
                      )}
                    >
                      {letter}
                    </span>
                    <span className="text-[15px] text-navy-900">{c.label}</span>
                  </button>
                );
              })}
            </div>
          )}
        </CardBody>
      </Card>

      <div className="flex justify-between">
        <Button
          variant="secondary"
          onClick={() => setCurrent(Math.max(0, current - 1))}
          disabled={current === 0}
        >
          <ArrowLeft className="h-4 w-4" /> Précédent
        </Button>
        {current < orderedQuestions.length - 1 ? (
          <Button
            onClick={() => setCurrent(current + 1)}
            disabled={
              q.type === "qr"
                ? false /* on autorise à passer même sans rédaction */
                : !selected
            }
            className="group"
          >
            Suivant
            <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-0.5" />
          </Button>
        ) : (
          <Button variant="gold" onClick={() => setShowReview(true)}>
            <CheckCircle2 className="h-4 w-4" /> Relecture & validation
          </Button>
        )}
      </div>
    </div>
  );
}

function Stat({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-xl bg-ivory border border-navy-100 px-3 py-3">
      <div className="text-[10px] uppercase tracking-wider text-slate-500 font-medium">
        {label}
      </div>
      <div className="font-display text-xl font-semibold text-navy-900 mt-0.5">
        {value}
      </div>
    </div>
  );
}
