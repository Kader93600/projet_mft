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
  const supabase = createClient();
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

  // Vérification anti-rejeu : si la tentative existe déjà, on retourne
  // son id (l'app supprime l'entrée locale).
  const { data: existing } = await supabase
    .from("quiz_attempts")
    .select("id")
    .eq("client_attempt_id", body.client_attempt_id)
    .maybeSingle();
  if (existing?.id) {
    return NextResponse.json({ id: existing.id, deduplicated: true });
  }

  // Vérification quiz : on récupère le quiz pour s'assurer qu'il existe
  // et qu'il n'est pas un examen blanc (les is_mock_exam ne doivent pas
  // être passés offline). On ne refait pas le scoring serveur côté
  // sync — on fait confiance au scoring client pour les QCM (les
  // questions et réponses correctes sont stables).
  const { data: quiz } = await supabase
    .from("quizzes")
    .select("id, is_mock_exam, pass_threshold")
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

  const insertPayload: Record<string, unknown> = {
    user_id: user.id,
    quiz_id: body.quiz_id,
    score: body.score ?? null,
    total: body.total ?? null,
    percentage: body.percentage ?? null,
    passed: body.passed ?? null,
    duration_s: body.duration_s ?? null,
    answers: body.answers ?? {},
    started_at: body.started_at ?? null,
    finished_at: body.finished_at ?? new Date().toISOString(),
    focus_loss_count: body.focus_loss_count ?? 0,
    flagged_questions: body.flagged_questions ?? [],
    mode: body.mode,
    status: "graded",
    qcm_score: body.qcm_score ?? body.percentage ?? null,
    client_attempt_id: body.client_attempt_id,
  };
  if (body.formation_id) {
    insertPayload.formation_id = body.formation_id;
  }

  const { data: inserted, error } = await supabase
    .from("quiz_attempts")
    .insert(insertPayload)
    .select("id")
    .single();

  if (error) {
    // Race condition : un autre device a sync entre notre maybeSingle()
    // et l'insert. On retourne l'id existant.
    if (error.code === "23505") {
      const { data: e2 } = await supabase
        .from("quiz_attempts")
        .select("id")
        .eq("client_attempt_id", body.client_attempt_id)
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
