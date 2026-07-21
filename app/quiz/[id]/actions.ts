"use server";

// =====================================================================
// Soumission d'une tentative de quiz — scoring 100 % serveur (QUIZ-03).
//
// Avant ce correctif, le runner client calculait score/percentage/passed
// et les insérait lui-même dans `quiz_attempts` : un stagiaire pouvait
// falsifier son résultat (y compris en mode examen). Désormais :
//   - le client n'envoie QUE ses réponses brutes ;
//   - le serveur re-vérifie le droit de passage (quiz_attempt_state),
//     recharge les bonnes réponses et recalcule tout ;
//   - l'insertion passe par le client service-role (les policies RLS
//     d'écriture directes sont supprimées par
//     supabase/2026_07_21_quiz_scoring_server.sql).
//
// Idempotence : `clientAttemptId` (uuid généré par le runner) est stocké
// dans `quiz_attempts.client_attempt_id` (index UNIQUE). Un retry après
// échec partiel (réponses QR) réutilise la MÊME tentative.
// =====================================================================

import { z } from "zod";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { loadQuizScoringData, computeQcmScore } from "@/lib/quiz-scoring";
import { captureException } from "@/lib/observability";
import type { Tables } from "@/lib/database.types";

/** `quizzes.select(...)` — champs nécessaires au scoring/gate. */
type QuizScoringRow = Pick<
  Tables<"quizzes">,
  | "id"
  | "type"
  | "is_mock_exam"
  | "pass_threshold"
  | "module_id"
  | "generation_mode"
  | "bank_filters"
>;

/** Retour de l'RPC `quiz_attempt_state`. */
type AttemptStateRow = { allowed: boolean; reason: string | null };

const SubmitInput = z.object({
  quizId: z.string().uuid(),
  /** uuid client pour l'idempotence (retry sans double tentative). */
  clientAttemptId: z.string().min(8).max(64),
  /** QCM : question_id → choice_id sélectionné. */
  answers: z.record(z.string().max(64), z.string().max(64)).default({}),
  /** QR : question_id → texte rédigé (max 20000 caractères). */
  qrAnswers: z.record(z.string().max(64), z.string().max(20000)).default({}),
  startedAt: z.string().datetime().nullable().optional(),
  focusLossCount: z.number().int().min(0).max(10000).default(0),
  flaggedQuestions: z.array(z.string().max(64)).max(500).default([]),
  formationId: z.string().uuid().nullable().optional(),
});

export type SubmitQuizAttemptInput = z.input<typeof SubmitInput>;

export type SubmitQuizAttemptResult =
  | { ok: true; attemptId: string; qcmPercentage: number | null; hasQr: boolean }
  | {
      ok: false;
      error:
        | "invalid_input"
        | "session_expired"
        | "quiz_not_found"
        | "forbidden"
        | "not_allowed"
        | "insert_failed"
        | "qr_failed";
      /** Présent si la tentative existe déjà (retry possible côté client). */
      attemptId?: string;
      failedQrCount?: number;
    };

/** Retry léger (2 essais, 600 ms) pour les RPC QR — même politique que
 *  l'ancien runner client. */
async function rpcWithRetry(
  session: Awaited<ReturnType<typeof createClient>>,
  fn: "submit_qr_response" | "mark_attempt_awaiting_review",
  args: Record<string, unknown>,
): Promise<boolean> {
  for (let attempt = 0; attempt < 2; attempt++) {
    const { error } = await session.rpc(fn, args);
    if (!error) return true;
    if (attempt === 0) await new Promise((r) => setTimeout(r, 600));
    else await captureException(error, { tags: { task: "quiz-submit", rpc: fn } });
  }
  return false;
}

export async function submitQuizAttempt(
  raw: SubmitQuizAttemptInput,
): Promise<SubmitQuizAttemptResult> {
  const parsed = SubmitInput.safeParse(raw);
  if (!parsed.success) return { ok: false, error: "invalid_input" };
  const input = parsed.data;

  const session = await createClient();
  const {
    data: { user },
  } = await session.auth.getUser();
  if (!user) return { ok: false, error: "session_expired" };

  const admin = createAdminClient();

  // ── Quiz ───────────────────────────────────────────────────────────
  const { data: quizData } = await admin
    .from("quizzes")
    .select(
      "id, type, is_mock_exam, pass_threshold, module_id, generation_mode, bank_filters",
    )
    .eq("id", input.quizId)
    .maybeSingle();
  const quiz = quizData as QuizScoringRow | null;
  if (!quiz) return { ok: false, error: "quiz_not_found" };

  // ── Idempotence : tentative déjà créée par un submit précédent ? ───
  const { data: existingData } = await admin
    .from("quiz_attempts")
    .select("id")
    .eq("client_attempt_id", input.clientAttemptId)
    .eq("user_id", user.id)
    .maybeSingle();
  let attemptId: string | null =
    (existingData as Pick<Tables<"quiz_attempts">, "id"> | null)?.id ?? null;

  // ── Gate d'accès (mêmes règles que la page quiz) ───────────────────
  // Staff = accès libre ; sinon le quiz doit appartenir à une formation
  // où le stagiaire est inscrit (module OU rattachement global).
  // formationId : l'ancienne policy RLS vérifiait user_has_formation au
  // moment de l'INSERT ; l'insert passant désormais en service-role, on
  // re-valide ici (un id forgé est simplement ignoré).
  let validatedFormationId: string | null = null;
  if (!attemptId) {
    const { data: meRole } = await session
      .from("profiles")
      .select("role")
      .eq("id", user.id)
      .single();
    const isStaff =
      meRole?.role === "admin" ||
      meRole?.role === "super_admin" ||
      meRole?.role === "trainer";

    if (isStaff) {
      validatedFormationId = input.formationId ?? null;
    } else {
      const { data: enrollments } = await session
        .from("enrollments")
        .select("formation_id")
        .eq("user_id", user.id)
        .not("formation_id", "is", null)
        .neq("status", "refuse")
        .neq("status", "abandon");
      const enrolledIds = ((enrollments ?? []) as Pick<
        Tables<"enrollments">,
        "formation_id"
      >[])
        .map((e) => e.formation_id)
        .filter((id): id is string => !!id);
      if (enrolledIds.length === 0) return { ok: false, error: "forbidden" };

      validatedFormationId =
        input.formationId && enrolledIds.includes(input.formationId)
          ? input.formationId
          : null;

      if (quiz.module_id) {
        const { count } = await session
          .from("formation_modules")
          .select("module_id", { count: "exact", head: true })
          .eq("module_id", quiz.module_id)
          .in("formation_id", enrolledIds);
        if (!count) return { ok: false, error: "forbidden" };
      } else {
        const { count } = await session
          .from("formation_quizzes")
          .select("quiz_id", { count: "exact", head: true })
          .eq("quiz_id", quiz.id)
          .in("formation_id", enrolledIds);
        if (!count) return { ok: false, error: "forbidden" };
      }
    }

    // Droit de passage (max_attempts / retake_delay) re-vérifié SERVEUR :
    // avant ce correctif, seule l'UI l'appliquait.
    const { data: stateData } = await session.rpc("quiz_attempt_state", {
      p_quiz_id: quiz.id,
    });
    const state = stateData as AttemptStateRow | null;
    if (state && state.allowed === false) {
      return { ok: false, error: "not_allowed" };
    }
  }

  // ── Scoring serveur ────────────────────────────────────────────────
  const scoring = await loadQuizScoringData({
    admin,
    session,
    quizId: quiz.id,
    userId: user.id,
    generationMode: quiz.generation_mode,
    bankFilters: quiz.bank_filters,
  });
  const { score, totalQcm, qcmPercentage } = computeQcmScore(
    input.answers,
    scoring,
  );
  const hasQr = scoring.qrIds.size > 0;

  // Mode dérivé serveur (mêmes valeurs que l'ancien runner : tout examen
  // est historisé "blanc", l'entraînement reste "entrainement").
  const isExam = quiz.type === "examen" || !!quiz.is_mock_exam;
  const mode = isExam ? "blanc" : "entrainement";

  // ── Insertion (service-role) ───────────────────────────────────────
  if (!attemptId) {
    const startedAtDate = input.startedAt ? new Date(input.startedAt) : null;
    const now = new Date();
    const durationS =
      startedAtDate && startedAtDate.getTime() <= now.getTime()
        ? Math.min(
            Math.round((now.getTime() - startedAtDate.getTime()) / 1000),
            24 * 3600,
          )
        : null;

    const insertPayload: Record<string, unknown> = {
      user_id: user.id,
      quiz_id: quiz.id,
      score,
      total: totalQcm,
      percentage: qcmPercentage,
      passed:
        hasQr || qcmPercentage === null
          ? null
          : qcmPercentage >= quiz.pass_threshold,
      duration_s: durationS,
      answers: input.answers,
      started_at: startedAtDate?.toISOString() ?? null,
      finished_at: now.toISOString(),
      focus_loss_count: input.focusLossCount,
      // Filtrées sur les questions réelles du quiz (pas d'ids forgés).
      flagged_questions: input.flaggedQuestions.filter(
        (id) => scoring.correctByQuestion.has(id) || scoring.qrIds.has(id),
      ),
      mode,
      status: hasQr ? "awaiting_review" : "graded",
      qcm_score: qcmPercentage,
      client_attempt_id: input.clientAttemptId,
    };
    if (validatedFormationId) insertPayload.formation_id = validatedFormationId;

    const { data: inserted, error: insertErr } = await admin
      .from("quiz_attempts")
      .insert(insertPayload)
      .select("id")
      .single();

    if (insertErr || !inserted) {
      // Course entre deux submits : la tentative existe déjà → réutilise.
      if (insertErr?.code === "23505") {
        const { data: dup } = await admin
          .from("quiz_attempts")
          .select("id")
          .eq("client_attempt_id", input.clientAttemptId)
          .eq("user_id", user.id)
          .maybeSingle();
        attemptId =
          (dup as Pick<Tables<"quiz_attempts">, "id"> | null)?.id ?? null;
      }
      if (!attemptId) {
        await captureException(insertErr ?? new Error("insert_failed"), {
          tags: { task: "quiz-submit", quiz: quiz.id },
        });
        return { ok: false, error: "insert_failed" };
      }
    } else {
      attemptId = inserted.id as string;
    }
  }

  // ── Réponses rédigées (QR) ─────────────────────────────────────────
  // RPC SECURITY DEFINER côté session (elles vérifient auth.uid() =
  // propriétaire de la tentative). Upsert : un retry ré-envoie sans doublon.
  if (hasQr) {
    let failedQr = 0;
    for (const questionId of scoring.qrIds) {
      const text = (input.qrAnswers[questionId] ?? "").trim();
      const ok = await rpcWithRetry(session, "submit_qr_response", {
        p_attempt: attemptId,
        p_question: questionId,
        p_answer: text,
      });
      if (!ok) failedQr++;
    }

    const markOk = await rpcWithRetry(session, "mark_attempt_awaiting_review", {
      p_attempt: attemptId,
      p_qcm_score: qcmPercentage,
    });

    if (failedQr > 0 || !markOk) {
      return {
        ok: false,
        error: "qr_failed",
        attemptId: attemptId ?? undefined,
        failedQrCount: failedQr,
      };
    }
  }

  return { ok: true, attemptId: attemptId as string, qcmPercentage, hasQr };
}
