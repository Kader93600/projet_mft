"use client";
import { useState, useEffect, useMemo, useRef } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useTranslations, useLocale } from "next-intl";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ProgressBar, RadialProgress } from "@/components/ui/progress";
import {
  Check, X, Clock, Target, Lightbulb, ArrowRight, ArrowLeft,
  AlertTriangle, Maximize, ShieldAlert, Lock, Flag, Grid3X3,
  CheckCircle2, Paperclip, ExternalLink, FileText, CloudOff,
} from "lucide-react";
import { cn, scoreColor } from "@/lib/utils";
import { FormationBadge } from "@/components/formation/formation-badge";
import { FormationStripe } from "@/components/formation/formation-stripe";
import { RichTextDisplay } from "@/components/rich-text/rich-text-display";
import { trackEvent } from "@/lib/analytics";
import { enqueueAttempt } from "@/lib/pwa/sync-queue";

interface Choice { id: string; label: string; is_correct: boolean; order: number; }
interface QuestionAnnex {
  pageNumber: number;
  label: string;
  signedUrl: string;
}
interface QuestionAttachment {
  id: string;
  kind: "image" | "pdf" | "document" | "other";
  fileName: string;
  mimeType: string;
  label: string | null;
  signedUrl: string;
}
interface Question {
  id: string;
  statement: string;
  explanation?: string | null;
  choices: Choice[];
  type?: "qcm" | "qr";
  source?: "legacy" | "bank";
  max_score?: number;
  annexes?: QuestionAnnex[];
  attachments?: QuestionAttachment[];
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
  formationId,
}: {
  quiz: Quiz;
  questions: Question[];
  attemptState: AttemptState | null;
  formationSlug?: string | null;
  formationId?: string | null;
}) {
  const t = useTranslations("quizRunner");
  const locale = useLocale();
  const dateLocale = locale === "en" ? "en-GB" : "fr-FR";
  const router = useRouter();
  const [started, setStarted] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [current, setCurrent] = useState(0);
  const [answers, setAnswers] = useState<Record<string, string>>({});
  // Réponses rédigées (QR) — texte libre du stagiaire
  const [qrAnswers, setQrAnswers] = useState<Record<string, string>>({});
  const [finished, setFinished] = useState(false);
  // Tentative QCM enqueuée hors-ligne — sera resync au retour réseau
  // par <OfflineSync /> dans AuthLayout.
  const [offlineQueued, setOfflineQueued] = useState(false);
  const [remaining, setRemaining] = useState(quiz.time_limit_s ?? 0);
  const [startedAt, setStartedAt] = useState<Date | null>(null);
  const [focusLoss, setFocusLoss] = useState(0);
  const [showFocusWarning, setShowFocusWarning] = useState(false);
  const focusRef = useRef(0);
  // Mémorise l'attemptId déjà créé en base : si l'INSERT a réussi mais
  // que l'enregistrement des réponses QR a échoué, un nouveau clic sur
  // "Terminer" réutilise la MÊME tentative au lieu d'en créer une 2e
  // (évite le double-submit + les copies orphelines).
  const submittedAttemptIdRef = useRef<string | null>(null);
  const [flagged, setFlagged] = useState<Set<string>>(new Set());

  // ───── Sauvegarde auto + reprise après crash ────────────────────
  // On stocke les réponses + position courante dans localStorage toutes
  // les 3s pendant qu'une tentative est en cours. Si l'utilisateur ferme
  // l'onglet ou crashe, on lui propose de reprendre au prochain mount.
  const lsKey = `quiz-progress:${quiz.id}`;
  const [resumeAvailable, setResumeAvailable] = useState(false);

  // Détection au mount d'une sauvegarde existante
  useEffect(() => {
    if (typeof window === "undefined") return;
    try {
      const raw = window.localStorage.getItem(lsKey);
      if (raw) {
        const parsed = JSON.parse(raw);
        // Sauvegarde fraîche ? (< 24h pour éviter les vieux restes)
        const ageMs = Date.now() - (parsed.savedAt ?? 0);
        if (ageMs < 24 * 60 * 60 * 1000 && (parsed.answers || parsed.qrAnswers)) {
          setResumeAvailable(true);
        } else {
          window.localStorage.removeItem(lsKey);
        }
      }
    } catch {
      /* ignore */
    }
  }, [lsKey]);

  // Sauvegarde auto pendant l'épreuve
  useEffect(() => {
    if (!started || finished) return;
    const i = setInterval(() => {
      try {
        window.localStorage.setItem(
          lsKey,
          JSON.stringify({
            answers,
            qrAnswers,
            current,
            flagged: [...flagged],
            startedAt: startedAt?.toISOString(),
            savedAt: Date.now(),
          }),
        );
      } catch {
        /* localStorage plein → on ignore */
      }
    }, 3000);
    return () => clearInterval(i);
  }, [
    started,
    finished,
    answers,
    qrAnswers,
    current,
    flagged,
    startedAt,
    lsKey,
  ]);

  // Nettoyage au submit final
  useEffect(() => {
    if (finished) {
      try {
        window.localStorage.removeItem(lsKey);
      } catch {
        /* ignore */
      }
    }
  }, [finished, lsKey]);

  // Bouton "Reprendre" : restaure depuis localStorage
  const resumeFromSave = () => {
    try {
      const raw = window.localStorage.getItem(lsKey);
      if (!raw) return;
      const parsed = JSON.parse(raw);
      if (parsed.answers) setAnswers(parsed.answers);
      if (parsed.qrAnswers) setQrAnswers(parsed.qrAnswers);
      if (typeof parsed.current === "number") setCurrent(parsed.current);
      if (Array.isArray(parsed.flagged))
        setFlagged(new Set(parsed.flagged));
      if (parsed.startedAt) setStartedAt(new Date(parsed.startedAt));
      setResumeAvailable(false);
      setStarted(true);
    } catch {
      /* ignore */
    }
  };

  const discardSave = () => {
    try {
      window.localStorage.removeItem(lsKey);
    } catch {
      /* ignore */
    }
    setResumeAvailable(false);
  };
  const [showPalette, setShowPalette] = useState(false);
  const [showReview, setShowReview] = useState(false);
  const [showFsPrompt, setShowFsPrompt] = useState(false);

  // Mode examen unifié : on considère TOUS les quiz de type "examen" OU
  // marqués is_mock_exam comme du mode strict (fullscreen, anti-triche,
  // correction différée). Les exercices d'entraînement gardent le mode
  // libre (correction immédiate à la fin, pas de fullscreen forcé).
  const isExamMode = quiz.type === "examen" || !!quiz.is_mock_exam;
  const isMock = isExamMode;

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

  // Tous les examens forcent le fullscreen (qu'il soit explicitement
  // marqué require_fullscreen ou non — c'est un standard du mode examen).
  const requireFs = isExamMode;

  // Détection de sortie de plein écran en examen blanc → re-prompt
  useEffect(() => {
    if (!started || finished || !requireFs) return;
    function onFsChange() {
      if (!document.fullscreenElement) {
        setShowFsPrompt(true);
      } else {
        setShowFsPrompt(false);
      }
    }
    document.addEventListener("fullscreenchange", onFsChange);
    return () => document.removeEventListener("fullscreenchange", onFsChange);
  }, [started, finished, requireFs]);

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
    // Analytics : début de tentative
    trackEvent("quiz_started", {
      quiz_id: quiz.id,
      quiz_title: quiz.title,
      formation_slug: formationSlug ?? undefined,
      mode: isMock ? "blanc" : quiz.type === "examen" ? "examen" : "entrainement",
      is_mock_exam: !!quiz.is_mock_exam,
      total_questions: orderedQuestions.length,
    });
  }

  async function submit() {
    // ⚠️ Ne PAS poser finished=true ici. Si on le pose avant l'INSERT et
    // que celui-ci échoue, le user voit un écran "Félicitations !" calculé
    // localement (cf. const result = useMemo...) sans que sa tentative ne
    // soit en base → stats à 0 alors qu'il pense avoir terminé.
    // On pose finished=true UNIQUEMENT après le succès de l'INSERT.
    if (finished) return;
    setSubmitError(null);
    const finishedAt = new Date();
    const supabase = createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      setSubmitError(
        "Session expirée. Reconnectez-vous puis réessayez de soumettre."
      );
      return;
    }

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
    // qcmPercentage doit être NULL quand le quiz ne contient AUCUN QCM,
    // sinon la page de résultats affiche "Score QCM 0%" qui n'a aucun
    // sens et la pondération finale (70 % QCM + 30 % QR) divise le score
    // du stagiaire par 3 sans raison. Cf. fix 2026-05-16.
    const qcmPercentage: number | null =
      totalQcm > 0 ? Math.round((score / totalQcm) * 100) : null;
    const total = orderedQuestions.length;

    const hasQr = qrList.length > 0;
    const mode = isMock ? "blanc" : quiz.type === "examen" ? "examen" : "entrainement";

    // Insert tentative principale.
    // formation_id : passé explicitement depuis la page (résolu via le
    // module du quiz). Le trigger BD est un fallback mais ne couvre pas
    // les cas où profiles.current_formation_id est NULL.
    const insertPayload: any = {
      user_id: user.id,
      quiz_id: quiz.id,
      score,
      total: totalQcm,
      percentage: qcmPercentage,
      passed: hasQr
        ? null
        : qcmPercentage !== null && qcmPercentage >= quiz.pass_threshold,
      duration_s: startedAt
        ? Math.round((finishedAt.getTime() - startedAt.getTime()) / 1000)
        : null,
      answers,
      started_at: startedAt?.toISOString(),
      finished_at: finishedAt.toISOString(),
      focus_loss_count: focusRef.current,
      flagged_questions: Array.from(flagged),
      mode,
      status: hasQr ? "awaiting_review" : "graded",
      qcm_score: qcmPercentage,
    };
    if (formationId) insertPayload.formation_id = formationId;

    // ─── Gate offline : quiz QCM d'entraînement uniquement ─────────────
    // Si le navigateur est hors-ligne ET que le quiz est un entraînement
    // QCM pur (pas QR, pas examen blanc), on enregistre la tentative dans
    // IndexedDB pour resync au retour réseau (cf. <OfflineSync /> dans
    // AuthLayout + endpoint /api/quiz/sync-offline).
    // Décision client 2026-05 : les examens blancs et QR restent online-only
    // pour ne pas polluer les stats officielles ni faire correspondre les
    // QR sans connexion (correction formateur).
    if (
      typeof navigator !== "undefined" &&
      !navigator.onLine &&
      mode === "entrainement" &&
      !hasQr &&
      !quiz.is_mock_exam
    ) {
      try {
        await enqueueAttempt(insertPayload);
        // Pas d'attemptId → on ne redirige pas vers /quiz/results/[id].
        // L'utilisateur voit un écran de confirmation offline.
        setOfflineQueued(true);
        setFinished(true);
        trackEvent("quiz_finished_offline", {
          quiz_id: quiz.id,
          quiz_title: quiz.title,
          formation_slug: formationSlug ?? undefined,
          mode,
          qcm_score: qcmPercentage ?? undefined,
          total_questions: orderedQuestions.length,
        });
        return;
      } catch (e) {
        console.error("[quiz submit] offline enqueue failed", e);
        setSubmitError(t("unableToSave", { msg: String(e) }));
        return;
      }
    }

    // Si une tentative a déjà été créée lors d'un submit précédent dont
    // seules les RPC QR ont échoué, on la réutilise (pas de 2e INSERT).
    let inserted: { id: string } | null = null;
    let insertErr: any = null;
    if (submittedAttemptIdRef.current) {
      inserted = { id: submittedAttemptIdRef.current };
    } else {
      const res = await supabase
        .from("quiz_attempts")
        .insert(insertPayload)
        .select("id")
        .single();
      inserted = res.data;
      insertErr = res.error;
    }

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
      const msg = insertErr?.message ?? t("unknownError");
      let friendly = t("unableToSave", { msg });
      // Mappings courants pour parler humain
      if (code === "42703") {
        // colonne inexistante
        friendly = t("errDbOutdated");
      } else if (code === "42501" || /row.level security|policy/i.test(msg)) {
        friendly = t("errRls");
      } else if (code === "23502") {
        // not null violation
        friendly = t("errMissingField", {
          details: (insertErr as any)?.details ?? msg,
        });
      } else if (code === "23505") {
        friendly = t("errDuplicate");
      }
      setSubmitError(friendly);
      return;
    }
    const attemptId = inserted.id;
    // Mémorise l'attempt pour qu'un retry (échec QR) ne recrée pas de
    // tentative.
    submittedAttemptIdRef.current = attemptId;
    // ✅ INSERT réussi — on bascule en état "fini" (le faux écran de
    // succès local ne peut plus apparaître sans tentative en BD).
    setFinished(true);

    // Analytics : fin de tentative (qu'elle soit gradée ou en attente QR).
    // Si hasQr, le score final viendra après correction formateur — on
    // capture ici le score QCM partiel et le mode pour mesurer l'engagement.
    trackEvent(
      isMock || quiz.type === "examen" ? "exam_finished" : "quiz_finished",
      {
        quiz_id: quiz.id,
        quiz_title: quiz.title,
        attempt_id: attemptId,
        formation_slug: formationSlug ?? undefined,
        mode,
        is_mock_exam: !!quiz.is_mock_exam,
        has_qr: hasQr,
        qcm_score: qcmPercentage ?? undefined,
        passed: hasQr ? undefined : (qcmPercentage ?? 0) >= quiz.pass_threshold,
        duration_s: startedAt
          ? Math.round((finishedAt.getTime() - startedAt.getTime()) / 1000)
          : undefined,
        total_questions: orderedQuestions.length,
      }
    );

    // Soumettre chaque réponse rédigée via la RPC sécurisée.
    // ⚠️ Auparavant les échecs étaient avalés silencieusement (console
    // only) puis le stagiaire était redirigé comme si tout allait bien
    // → copies QR perdues en cas de coupure réseau. Désormais : retry
    // (2 tentatives) par réponse, et si un échec persiste, on AFFICHE
    // l'erreur et on NE redirige PAS (le stagiaire peut réessayer sans
    // perdre sa copie).
    if (hasQr) {
      const rpcWithRetry = async (
        fn: string,
        args: Record<string, unknown>,
      ): Promise<boolean> => {
        for (let attempt = 0; attempt < 2; attempt++) {
          const { error } = await supabase.rpc(fn as any, args as any);
          if (!error) return true;
          console.error(`[${fn}] try ${attempt + 1}`, error);
          if (attempt === 0) await new Promise((r) => setTimeout(r, 600));
        }
        return false;
      };

      const failedQr: string[] = [];
      for (const q of qrList) {
        const text = (qrAnswers[q.id] ?? "").trim();
        const ok = await rpcWithRetry("submit_qr_response", {
          p_attempt: attemptId,
          p_question: q.id,
          p_answer: text,
        });
        if (!ok) failedQr.push(q.id);
      }

      const markOk = await rpcWithRetry("mark_attempt_awaiting_review", {
        p_attempt: attemptId,
        p_qcm_score: qcmPercentage,
      });

      if (failedQr.length > 0 || !markOk) {
        // On garde le quiz en état "fini" mais on montre l'erreur et on
        // ne redirige pas : les réponses sont encore en mémoire (state),
        // l'utilisateur peut re-cliquer "Terminer" pour relancer l'envoi.
        setSubmitError(
          failedQr.length > 0
            ? `Échec d'enregistrement de ${failedQr.length} réponse(s) rédigée(s). Vérifiez votre connexion et cliquez à nouveau sur Terminer — vos réponses sont conservées.`
            : "Votre copie a été enregistrée mais la mise en file de correction a échoué. Cliquez à nouveau sur Terminer pour réessayer.",
        );
        setFinished(false); // ré-autorise un nouveau submit
        return;
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
                  <ShieldAlert className="h-3 w-3" /> {t("mockExamBadge")}
                </Badge>
              ) : quiz.type === "examen" ? (
                <Badge tone="gold" size="sm">{t("examMode")}</Badge>
              ) : (
                <Badge tone="navy" size="sm">{t("training")}</Badge>
              )}
            </div>
            <h1 className="font-display text-3xl font-semibold text-navy-950 tracking-tight">
              {quiz.title}
            </h1>
            {quiz.description && (
              <p className="text-slate-600 max-w-md mx-auto">{quiz.description}</p>
            )}

            <div className="mt-6 grid grid-cols-3 gap-3 max-w-md mx-auto">
              <Stat label={t("questions")} value={String(orderedQuestions.length)} />
              {quiz.time_limit_s && (
                <Stat
                  label={t("duration")}
                  value={t("minutes", { min: Math.round(quiz.time_limit_s / 60) })}
                />
              )}
              <Stat label={t("threshold")} value={`${quiz.pass_threshold}%`} />
            </div>

            {isExamMode ? (
              <div className="mx-auto max-w-md text-left rounded-xl bg-amber-50 border border-amber-200 p-4 text-sm text-navy-900 space-y-2">
                <div className="font-semibold flex items-center gap-2">
                  <ShieldAlert className="h-4 w-4 text-amber-700" />
                  {t("examModeTitle")}
                </div>
                <ul className="text-xs text-slate-700 space-y-1 list-disc list-inside">
                  <li>{t("examFullscreen")}</li>
                  <li>{t("examNoCorrection")}</li>
                  <li>{t("examFocusLossLogged")}</li>
                  <li>{t("examCopyBlocked")}</li>
                  {quiz.time_limit_s && (
                    <li>
                      {t("examTimerWithMinutes", {
                        min: Math.round(quiz.time_limit_s / 60),
                      })}
                    </li>
                  )}
                  {quiz.shuffle_questions && <li>{t("examShuffleQuestions")}</li>}
                  {quiz.shuffle_choices && <li>{t("examShuffleChoices")}</li>}
                  {quiz.retake_delay_hours ? (
                    <li>{t("examRetakeDelay", { hours: quiz.retake_delay_hours })}</li>
                  ) : null}
                  {quiz.max_attempts ? (
                    <li>{t("examMaxAttempts", { count: quiz.max_attempts })}</li>
                  ) : null}
                </ul>
              </div>
            ) : (
              <div className="mx-auto max-w-md text-left rounded-xl bg-signal-50 border border-signal-200 p-4 text-sm text-navy-900 space-y-2">
                <div className="font-semibold flex items-center gap-2">
                  <CheckCircle2 className="h-4 w-4 text-signal-700" />
                  {t("trainingModeTitle")}
                </div>
                <ul className="text-xs text-slate-700 space-y-1 list-disc list-inside">
                  <li>{t("trainingCorrectionVisible")}</li>
                  <li>{t("trainingNoFullscreen")}</li>
                  <li>{t("trainingUnlimited")}</li>
                  <li>{t("trainingNoGrade")}</li>
                </ul>
              </div>
            )}

            {/* Bannière "Reprendre" si une sauvegarde locale existe */}
            {resumeAvailable && !blocked && (
              <div className="rounded-xl bg-signal-50 border border-signal-300 px-4 py-3 text-left space-y-2">
                <div className="flex items-center gap-2 text-signal-900">
                  <CheckCircle2 className="h-4 w-4 text-signal-700" />
                  <strong className="text-[13.5px]">
                    {t("resumeDetectedTitle")}
                  </strong>
                </div>
                <p className="text-[12.5px] text-slate-700">
                  {t("resumeDetectedBody")}
                </p>
                <div className="flex items-center gap-2 flex-wrap">
                  <Button
                    size="sm"
                    onClick={resumeFromSave}
                    className="bg-signal-500 hover:bg-signal-400 text-night-900"
                  >
                    <ArrowRight className="h-3.5 w-3.5" />
                    {t("resumeCta")}
                  </Button>
                  <button
                    type="button"
                    onClick={discardSave}
                    className="text-[12px] text-slate-600 hover:text-rose-700 underline"
                  >
                    {t("restartFromScratch")}
                  </button>
                </div>
              </div>
            )}

            {attemptState && (
              <div className="text-xs text-slate-600">
                {attemptState.attempts_used > 0 && (
                  <>{t("attemptsUsed", { count: attemptState.attempts_used })}</>
                )}
                {attemptsLeft !== null && (
                  <>
                    {" · "}
                    <span className="font-semibold">
                      {t("attemptsLeft", { count: attemptsLeft })}
                    </span>
                  </>
                )}
              </div>
            )}

            {blocked ? (
              <div className="rounded-xl bg-rose-50 border border-rose-200 px-4 py-3 text-sm text-rose-800 text-left">
                {attemptState?.reason === "max_attempts" && (
                  <>{t("blockedMaxAttempts")}</>
                )}
                {attemptState?.reason === "retake_delay" && attemptState.next_available_at && (
                  <>
                    {t("blockedRetakeDelayPrefix")}{" "}
                    <span className="font-semibold">
                      {new Date(attemptState.next_available_at).toLocaleString(dateLocale, {
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
                  {t("start")}
                  <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-0.5" />
                </Button>
              </div>
            )}
          </CardBody>
        </Card>
      </div>
    );
  }

  // ----- Confirmation hors-ligne (avant les résultats normaux) -----
  // Si le quiz a été enqueué offline, on ne peut pas rediriger vers
  // /quiz/results/[id] (pas d'attemptId). On affiche un écran sobre
  // qui rappelle le score local + la sync automatique au retour réseau.
  if (finished && offlineQueued && result) {
    return (
      <div className="max-w-2xl mx-auto space-y-6">
        <Card>
          <CardBody className="text-center py-10">
            <div className="mx-auto h-14 w-14 rounded-2xl bg-amber-100 border border-amber-300 text-amber-700 flex items-center justify-center">
              <CloudOff className="h-7 w-7" />
            </div>
            <div className="mt-5 font-display text-2xl font-semibold text-navy-900">
              Tentative enregistrée hors ligne
            </div>
            <p className="text-slate-700 mt-2 max-w-md mx-auto">
              Votre connexion n&apos;est pas disponible. Vos réponses ont été
              sauvegardées localement et seront envoyées automatiquement dès
              que vous serez à nouveau en ligne.
            </p>
            <div className="mt-6 inline-flex flex-col items-center">
              <div className="text-xs uppercase tracking-wider text-slate-500">
                Score local
              </div>
              <div
                className={cn(
                  "font-display text-3xl font-semibold mt-1",
                  scoreColor(result.percentage)
                )}
              >
                {result.percentage}%
              </div>
              <div className="text-sm text-slate-600 mt-0.5">
                {t("resultScore", {
                  score: result.score,
                  total: result.total,
                })}
              </div>
            </div>
            <div className="mt-6 flex justify-center gap-2 flex-wrap">
              <Link href="/quiz">
                <Button>
                  <ArrowLeft className="h-3.5 w-3.5" />
                  Retour aux quiz
                </Button>
              </Link>
              <Link href="/dashboard">
                <Button variant="ghost">Tableau de bord</Button>
              </Link>
            </div>
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
              {result.passed ? t("resultPassed") : t("resultKeepGoing")}
            </div>
            <p className="text-slate-600 mt-1">
              {t("resultScore", { score: result.score, total: result.total })}
            </p>
            <div className="mt-4 flex justify-center gap-2 flex-wrap">
              {result.passed ? (
                <Badge tone="success" size="md">
                  <Check className="h-3 w-3" /> {t("thresholdReached")}
                </Badge>
              ) : (
                <Badge tone="slate" size="md">
                  <Target className="h-3 w-3" /> {t("thresholdPct", { pct: quiz.pass_threshold })}
                </Badge>
              )}
              {isMock && focusLoss > 0 && (
                <Badge tone="slate" size="md">
                  <AlertTriangle className="h-3 w-3" /> {t("focusLossCount", { count: focusLoss })}
                </Badge>
              )}
            </div>
          </CardBody>
        </Card>

        {canShow ? (
          <div className="space-y-3">
            <h2 className="font-display text-xl font-semibold text-navy-900">
              {t("detailedCorrection")}
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
                          {t("questionPrefix", { n: i + 1 })} {q.statement}
                        </div>
                        <div className="text-sm mt-3 space-y-1.5">
                          <div className="text-slate-700">
                            {t("yourAnswerLabel")}{" "}
                            <span className={isOk ? "text-emerald-700 font-medium" : "text-rose-700 font-medium"}>
                              {selectedChoice?.label || "—"}
                            </span>
                          </div>
                          {!isOk && (
                            <div className="text-slate-700">
                              {t("goodAnswerLabel")}{" "}
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
                ? t("correctionUnavailable")
                : t("correctionLockedUntilPass")}
            </CardBody>
          </Card>
        )}

        <div className="flex gap-3 justify-center pt-4">
          <Link href="/quiz">
            <Button variant="secondary">{t("backToQuiz")}</Button>
          </Link>
          <Link href="/stats">
            <Button>{t("viewMyResults")}</Button>
          </Link>
        </div>
      </div>
    );
  }

  // ----- Écran de relecture avant soumission (examen) -----
  // Helper : une question est "répondue" si :
  //   - QCM : un choice est sélectionné dans `answers`
  //   - QR  : `qrAnswers` contient un texte non vide après trim
  const isQuestionAnswered = (q: Question) => {
    if ((q.type ?? "qcm") === "qr") {
      return ((qrAnswers[q.id] ?? "").trim().length > 0);
    }
    return !!answers[q.id];
  };

  if (showReview) {
    const unanswered = orderedQuestions.filter((q) => !isQuestionAnswered(q));
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
                {t("submitFailedBigTitle")}
              </div>
              <div className="mt-1 text-sm text-rose-800 leading-relaxed">
                {submitError}
              </div>
              <div className="mt-2 flex items-center gap-2">
                <button
                  type="button"
                  onClick={submit}
                  className="inline-flex items-center gap-1 h-8 px-3 rounded-lg bg-rose-600 text-white text-xs font-semibold hover:bg-rose-700 transition"
                >
                  {t("retrySubmit")}
                </button>
                <button
                  type="button"
                  onClick={() => setSubmitError(null)}
                  className="text-rose-700 hover:text-rose-900 text-xs font-medium px-2 h-8 rounded hover:bg-rose-100 transition"
                >
                  {t("hide")}
                </button>
              </div>
            </div>
          </div>
        )}
        <Card>
          <CardBody className="space-y-4">
            <div className="text-center">
              <Badge tone="gold" size="md" className="mx-auto">
                <Grid3X3 className="h-3 w-3" /> {t("reviewBadge")}
              </Badge>
              <h2 className="font-display text-2xl font-semibold text-navy-900 mt-3">
                {t("reviewTitle")}
              </h2>
              <p className="text-sm text-slate-600 mt-1">
                {t("reviewAnsweredCount", {
                  answered: Object.keys(answers).length,
                  total: orderedQuestions.length,
                })}
                {unanswered.length > 0 && (
                  <>
                    {" · "}
                    <span className="text-rose-700 font-semibold">
                      {t("reviewUnanswered", { count: unanswered.length })}
                    </span>
                  </>
                )}
                {flaggedList.length > 0 && (
                  <>
                    {" · "}
                    <span className="text-gold-700 font-semibold">
                      {t("reviewFlagged", { count: flaggedList.length })}
                    </span>
                  </>
                )}
              </p>
            </div>

            <div className="grid grid-cols-6 gap-2 sm:grid-cols-10">
              {orderedQuestions.map((qq, idx) => {
                const answered = isQuestionAnswered(qq);
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
                <span className="h-3 w-3 rounded bg-navy-900" /> {t("legendAnswered")}
              </span>
              <span className="flex items-center gap-1">
                <span className="h-3 w-3 rounded border border-rose-300 bg-white" />{" "}
                {t("legendUnanswered")}
              </span>
              <span className="flex items-center gap-1">
                <span className="h-2.5 w-2.5 rounded-full bg-gold-500" /> {t("legendFlagged")}
              </span>
            </div>

            <div className="flex justify-center gap-3 pt-4">
              <Button
                variant="secondary"
                onClick={() => setShowReview(false)}
              >
                <ArrowLeft className="h-4 w-4" /> {t("continueQuiz")}
              </Button>
              <Button variant="gold" onClick={submit}>
                <CheckCircle2 className="h-4 w-4" /> {t("validateFinal")}
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
              {t("submitFailedShort")}
            </div>
            <div className="mt-1 text-sm text-rose-800 leading-relaxed">
              {submitError}
            </div>
          </div>
          <button
            type="button"
            onClick={() => setSubmitError(null)}
            className="text-rose-700 hover:text-rose-900 text-xs font-medium px-2 py-1 rounded hover:bg-rose-100 transition"
            aria-label={t("close")}
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
                {t("fullscreenRequired")}
              </div>
              <p className="text-sm text-slate-600">
                {t("fullscreenRequiredBody")}
              </p>
              <Button onClick={reEnterFullscreen} className="mx-auto">
                <Maximize className="h-4 w-4" /> {t("resumeExam")}
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
              {t("focusLossDetected", { count: focusLoss })}
            </div>
            <div className="text-xs">
              {t("focusLossLogged")}
            </div>
          </div>
          <button
            onClick={() => setShowFocusWarning(false)}
            className="text-rose-700 hover:text-rose-900 text-xs font-semibold"
          >
            {t("ok")}
          </button>
        </div>
      )}

      <div className="flex items-center justify-between text-sm">
        <div className="flex items-center gap-2">
          <button
            type="button"
            onClick={() => setShowPalette((v) => !v)}
            className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-xs font-medium text-slate-600 hover:bg-navy-50 border border-navy-100"
            aria-label={t("paletteAria")}
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
            {isFlagged ? t("flagged") : t("toFlag")}
          </button>
        </div>
        <div className="flex items-center gap-2">
          {isMock && (
            <Badge tone="gold" size="sm">
              <ShieldAlert className="h-3 w-3" /> {t("mockExamShort")}
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
              {t("allQuestions")}
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
                {t("qrBadge")}
              </Badge>
            ) : (
              <Badge tone="navy" size="sm">
                {t("qcmBadge")}
              </Badge>
            )}
            {q.type === "qr" && q.max_score && (
              <span className="text-xs text-slate-500">
                {t("qrScale", { count: q.max_score })}
              </span>
            )}
          </div>
          <RichTextDisplay
            content={q.statement}
            className="font-display text-xl font-semibold text-navy-900 leading-snug"
          />
          {q.annexes && q.annexes.length > 0 && (
            <AnnexPanel annexes={q.annexes} />
          )}
          {q.attachments && q.attachments.length > 0 && (
            <AttachmentsPanel attachments={q.attachments} />
          )}
          {q.type === "qr" ? (
            <div>
              <textarea
                value={qrAnswers[q.id] ?? ""}
                onChange={(e) =>
                  setQrAnswers({ ...qrAnswers, [q.id]: e.target.value })
                }
                placeholder={t("qrPlaceholder")}
                rows={10}
                className="w-full rounded-xl border border-navy-200 bg-white p-4 text-[15px] text-navy-900 placeholder:text-slate-400 focus:border-navy-500 focus:outline-none focus:ring-2 focus:ring-navy-500/20 resize-y min-h-[180px]"
              />
              <div className="mt-2 flex items-center justify-between text-xs text-slate-500">
                <span>
                  {t("charsCount", { count: (qrAnswers[q.id] ?? "").length })}
                </span>
                <span className="italic">
                  {t("qrManualGrading")}
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
                    data-testid="quiz-choice"
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
          <ArrowLeft className="h-4 w-4" /> {t("previous")}
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
            {t("next")}
            <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-0.5" />
          </Button>
        ) : (
          <Button variant="gold" onClick={() => setShowReview(true)}>
            <CheckCircle2 className="h-4 w-4" /> {t("reviewAndValidate")}
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

/**
 * Panneau d'annexes — affiche les pages PDF référencées par l'énoncé.
 * Le stagiaire peut basculer entre annexes en cliquant sur les onglets,
 * ou ouvrir l'annexe dans un nouvel onglet pour la lire en grand.
 *
 * Utilise un <iframe> qui charge la signed URL avec le fragment #page=N.
 * Compatible Chrome / Safari / Firefox (via pdf.js viewer natif).
 */
function AnnexPanel({ annexes }: { annexes: QuestionAnnex[] }) {
  const t = useTranslations("quizRunner");
  const [activeIdx, setActiveIdx] = useState(0);
  const [expanded, setExpanded] = useState(false);
  const active = annexes[activeIdx];
  if (!active) return null;

  // URL avec fragment de page (viewer PDF natif des navigateurs)
  const viewerUrl = `${active.signedUrl}#page=${active.pageNumber}&toolbar=0&navpanes=0`;

  return (
    <div className="mt-3 rounded-2xl border border-amber-200 bg-amber-50/40 overflow-hidden">
      <div className="px-3.5 py-2 flex items-center gap-2 flex-wrap border-b border-amber-200 bg-amber-50/70">
        <Paperclip className="h-3.5 w-3.5 text-amber-700 shrink-0" />
        <span className="text-[11px] font-bold uppercase tracking-[0.14em] text-amber-900">
          {annexes.length === 1
            ? t("annexToConsult")
            : t("annexesToConsult", { count: annexes.length })}
        </span>
        {annexes.length > 1 && (
          <div className="ml-1 inline-flex rounded-md border border-amber-300 bg-white p-0.5">
            {annexes.map((a, i) => (
              <button
                key={i}
                type="button"
                onClick={() => setActiveIdx(i)}
                className={cn(
                  "px-2 py-0.5 rounded text-[11px] font-semibold transition",
                  i === activeIdx
                    ? "bg-amber-500 text-night-900"
                    : "text-amber-900 hover:bg-amber-100"
                )}
              >
                {a.label.length > 24
                  ? t("shortPage", { n: a.pageNumber })
                  : a.label}
              </button>
            ))}
          </div>
        )}
        <div className="ml-auto flex items-center gap-1.5">
          <button
            type="button"
            onClick={() => setExpanded(!expanded)}
            className="inline-flex items-center gap-1 px-2 py-1 rounded-md text-[11px] font-semibold text-amber-900 hover:bg-amber-100"
            title={expanded ? t("reduce") : t("expand")}
          >
            <Maximize className="h-3 w-3" />
            {expanded ? t("reduce") : t("expand")}
          </button>
          <a
            href={active.signedUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-1 px-2 py-1 rounded-md text-[11px] font-semibold text-amber-900 hover:bg-amber-100"
            title={t("openInNewTab")}
          >
            <ExternalLink className="h-3 w-3" />
            {t("newTab")}
          </a>
        </div>
      </div>
      <div className="px-3.5 py-1.5 text-[12px] text-amber-900/90">
        <strong>{active.label}</strong>
        <span className="text-amber-800/70"> {t("pagePrefix", { n: active.pageNumber })}</span>
      </div>
      <iframe
        key={active.signedUrl + active.pageNumber}
        src={viewerUrl}
        title={active.label}
        className={cn(
          "w-full bg-white border-t border-amber-200 transition-all",
          expanded ? "h-[800px]" : "h-[440px]"
        )}
      />
    </div>
  );
}

/**
 * Panneau d'annexes attachées directement à la question (images, PDF, doc).
 * Affichage adapté au kind :
 *   - image : preview inline cliquable (ouvre l'original en nouvel onglet)
 *   - pdf   : iframe (réutilise le viewer natif du navigateur)
 *   - autre : carte avec bouton "Ouvrir"
 */
function AttachmentsPanel({ attachments }: { attachments: QuestionAttachment[] }) {
  const t = useTranslations("quizRunner");
  const images = attachments.filter((a) => a.kind === "image");
  const pdfs = attachments.filter((a) => a.kind === "pdf");
  const others = attachments.filter(
    (a) => a.kind !== "image" && a.kind !== "pdf",
  );

  return (
    <div className="mt-3 rounded-2xl border border-brand-200 bg-brand-50/30 p-3">
      <div className="flex items-center gap-2 mb-2">
        <Paperclip className="h-3.5 w-3.5 text-brand-700" />
        <span className="text-[11px] font-bold uppercase tracking-[0.14em] text-brand-800">
          {t("documentsJoint", { count: attachments.length })}
        </span>
      </div>

      {/* Images : grille de previews cliquables */}
      {images.length > 0 && (
        <div className="grid grid-cols-2 md:grid-cols-3 gap-2 mb-2">
          {images.map((img) => (
            <a
              key={img.id}
              href={img.signedUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="block rounded-lg overflow-hidden bg-white border border-brand-100 hover:border-brand-300 transition group"
              title={img.label || img.fileName}
            >
              <img
                src={img.signedUrl}
                alt={img.label || img.fileName}
                className="block w-full max-h-[180px] object-contain bg-navy-50 group-hover:scale-[1.01] transition-transform"
                loading="lazy"
              />
              {img.label && (
                <div className="px-2 py-1 text-[11px] text-slate-700 truncate">
                  {img.label}
                </div>
              )}
            </a>
          ))}
        </div>
      )}

      {/* PDF : iframe natif */}
      {pdfs.map((pdf) => (
        <div
          key={pdf.id}
          className="rounded-lg overflow-hidden bg-white border border-brand-100 mb-2"
        >
          <div className="px-2.5 py-1.5 flex items-center gap-2 bg-brand-50/70 border-b border-brand-100 text-[12px] text-brand-900">
            <FileText className="h-3.5 w-3.5" />
            <strong className="flex-1 truncate">
              {pdf.label || pdf.fileName}
            </strong>
            <a
              href={pdf.signedUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-1 px-1.5 py-0.5 rounded hover:bg-brand-100 text-[11px] font-semibold"
              title={t("openInNewTab")}
            >
              <ExternalLink className="h-3 w-3" />
              {t("open")}
            </a>
          </div>
          <iframe
            src={`${pdf.signedUrl}#toolbar=0&navpanes=0`}
            title={pdf.label || pdf.fileName}
            className="w-full h-[400px] bg-white"
          />
        </div>
      ))}

      {/* Autres documents : carte + bouton */}
      {others.length > 0 && (
        <ul className="space-y-1">
          {others.map((doc) => (
            <li
              key={doc.id}
              className="flex items-center gap-2 rounded-lg bg-white border border-brand-100 px-2.5 py-1.5"
            >
              <FileText className="h-3.5 w-3.5 text-slate-600 shrink-0" />
              <div className="flex-1 min-w-0">
                <div className="text-[13px] font-semibold text-navy-900 truncate">
                  {doc.label || doc.fileName}
                </div>
                <div className="text-[10.5px] text-slate-500 truncate">
                  {doc.mimeType}
                </div>
              </div>
              <a
                href={doc.signedUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-1 px-2 py-1 rounded-md text-[11px] font-semibold bg-brand-600 text-white hover:bg-brand-700"
              >
                <ExternalLink className="h-3 w-3" />
                {t("open")}
              </a>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
