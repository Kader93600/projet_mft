// =====================================================================
// POST /api/quiz/sync-offline
//
// Reçoit le payload d'une tentative QCM réalisée hors-ligne et l'insère
// dans `quiz_attempts`. Idempotent grâce à l'index UNIQUE sur
// `client_attempt_id` (cf. migration 2026_05_18_quiz_offline_sync.sql).
//
// Garde-fous :
//   - Authentification obligatoire (le user_id du payload est ignoré)
//   - Refus si `mode !== "entrainement"` (sync offline limitée aux
//     quiz d'entraînement — cf. décision client 2026-05).
//   - Refus si le payload contient des réponses QR (non géré offline)
//   - `client_attempt_id` doit être présent (sinon dédupe impossible)
//   - Si une ligne existe déjà avec ce client_attempt_id : on retourne
//     200 avec l'id existant (l'app considère la sync réussie et
//     supprime l'entrée locale).
// =====================================================================

import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { loadQuizScoringData, computeQcmScore } from "@/lib/quiz-scoring";
import { NextRequest, NextResponse } from "next/server";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

type SyncBody = {
  client_attempt_id?: string;
  quiz_id?: string;
  formation_id?: string | null;
  score?: number;
  total?: number;
  percentage?: number;
  passed?: boolean | null;
  duration_s?: number | null;
  answers?: Record<string, unknown>;
  started_at?: string;
  finished_at?: string;
  focus_loss_count?: number;
  flagged_questions?: string[];
  mode?: string;
  qcm_score?: number | null;
};

export async function POST(req: NextRequest) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: "unauth" }, { status: 401 });
  }

  let body: SyncBody;
  try {
    body = (await req.json()) as SyncBody;
  } catch {
    return NextResponse.json({ error: "invalid_json" }, { status: 400 });
  }

  // Validations métier
  if (!body.client_attempt_id || typeof body.client_attempt_id !== "string") {
    return NextResponse.json(
      { error: "missing_client_attempt_id" },
      { status: 400 }
    );
  }
  if (!body.quiz_id || typeof body.quiz_id !== "string") {
    return NextResponse.json({ error: "missing_quiz_id" }, { status: 400 });
  }
  if (body.mode !== "entrainement") {
    return NextResponse.json(
      { error: "mode_not_allowed_offline" },
      { status: 400 }
    );
  }

  // Client service-role : les policies RLS d'écriture directe sur
  // quiz_attempts sont supprimées (QUIZ-03, cf.
  // supabase/2026_07_21_quiz_scoring_server.sql) — l'insertion passe
  // désormais par le serveur après authentification.
  const admin = createAdminClient();

  // Vérification anti-rejeu : si la tentative existe déjà, on retourne
  // son id (l'app supprime l'entrée locale).
  const { data: existing } = await admin
    .from("quiz_attempts")
    .select("id")
    .eq("client_attempt_id", body.client_attempt_id)
    .eq("user_id", user.id)
    .maybeSingle();
  if (existing?.id) {
    return NextResponse.json({ id: existing.id, deduplicated: true });
  }

  // Vérification quiz : on récupère le quiz pour s'assurer qu'il existe
  // et qu'il n'est pas un examen blanc (les is_mock_exam ne doivent pas
  // être passés offline).
  const { data: quiz } = await supabase
    .from("quizzes")
    .select("id, is_mock_exam, pass_threshold, generation_mode, bank_filters")
    .eq("id", body.quiz_id)
    .maybeSingle();

  if (!quiz) {
    return NextResponse.json({ error: "quiz_not_found" }, { status: 404 });
  }
  if (quiz.is_mock_exam) {
    return NextResponse.json(
      { error: "mock_exam_not_allowed_offline" },
      { status: 400 }
    );
  }

  // ── Scoring serveur (QUIZ-03) ────────────────────────────────────
  // Avant : on faisait confiance au score calculé par le client. Un
  // payload forgé pouvait donc écrire n'importe quel score dans les
  // stats. Désormais on recalcule tout à partir des réponses brutes.
  const rawAnswers = (body.answers ?? {}) as Record<string, unknown>;
  const answers: Record<string, string> = {};
  for (const [k, v] of Object.entries(rawAnswers)) {
    if (typeof v === "string" && k.length <= 64 && v.length <= 64) {
      answers[k] = v;
    }
  }
  const scoring = await loadQuizScoringData({
    admin,
    session: supabase,
    quizId: quiz.id,
    userId: user.id,
    generationMode: quiz.generation_mode,
    bankFilters: quiz.bank_filters,
  });
  // La sync offline est réservée aux quiz QCM purs : un quiz contenant
  // des questions rédigées (correction formateur) ne peut pas être
  // "graded" sans ses réponses QR.
  if (scoring.qrIds.size > 0) {
    return NextResponse.json(
      { error: "qr_quiz_not_allowed_offline" },
      { status: 400 }
    );
  }
  const { score, totalQcm, qcmPercentage } = computeQcmScore(answers, scoring);

  // formation_id : l'ancienne policy RLS validait user_has_formation à
  // l'INSERT ; l'insert passe désormais en service-role, on re-valide
  // donc l'inscription ici (id forgé → simplement ignoré).
  let validatedFormationId: string | null = null;
  if (body.formation_id) {
    const { count } = await supabase
      .from("enrollments")
      .select("id", { count: "exact", head: true })
      .eq("user_id", user.id)
      .eq("formation_id", body.formation_id)
      .neq("status", "refuse")
      .neq("status", "abandon");
    if (count) validatedFormationId = body.formation_id;
  }

  const insertPayload: Record<string, unknown> = {
    user_id: user.id,
    quiz_id: body.quiz_id,
    score,
    total: totalQcm,
    percentage: qcmPercentage,
    passed:
      qcmPercentage === null ? null : qcmPercentage >= quiz.pass_threshold,
    duration_s: body.duration_s ?? null,
    answers,
    started_at: body.started_at ?? null,
    finished_at: body.finished_at ?? new Date().toISOString(),
    focus_loss_count: body.focus_loss_count ?? 0,
    flagged_questions: body.flagged_questions ?? [],
    mode: body.mode,
    status: "graded",
    qcm_score: qcmPercentage,
    client_attempt_id: body.client_attempt_id,
  };
  if (validatedFormationId) {
    insertPayload.formation_id = validatedFormationId;
  }

  const { data: inserted, error } = await admin
    .from("quiz_attempts")
    .insert(insertPayload)
    .select("id")
    .single();

  if (error) {
    // Race condition : un autre device a sync entre notre maybeSingle()
    // et l'insert. On retourne l'id existant.
    if (error.code === "23505") {
      const { data: e2 } = await admin
        .from("quiz_attempts")
        .select("id")
        .eq("client_attempt_id", body.client_attempt_id)
        .eq("user_id", user.id)
        .maybeSingle();
      if (e2?.id) {
        return NextResponse.json({ id: e2.id, deduplicated: true });
      }
    }
    console.error("[quiz/sync-offline] insert error", {
      message: error.message,
      code: error.code,
      details: error.details,
      hint: error.hint,
    });
    return NextResponse.json(
      { error: "insert_failed", message: error.message },
      { status: 500 }
    );
  }

  return NextResponse.json({ id: inserted.id, deduplicated: false });
}
