// =====================================================================
// POST /api/tutor/grade-qr
//
// Lance la correction IA d'UNE qr_response. Réservé formateur/admin.
// La proposition est stockée dans qr_responses.ai_* via la RPC
// set_qr_ai_grading. Le formateur la valide ensuite via la RPC
// existante grade_qr_response (UPDATE trainer_score).
//
// Body : { response_id: uuid }
//
// Retour :
//   200 → { ai_score, ai_feedback_md, ai_criteria, ai_confidence, ... }
//   403 → utilisateur n'est pas formateur/admin
//   404 → qr_response introuvable
//   409 → déjà corrigée par un formateur (trainer_score IS NOT NULL)
//   503 → feature flag FEATURE_AI_TUTOR off
// =====================================================================

import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { gradeQrWithClaude } from "@/lib/tutor/qr-grading";
import type { Tables } from "@/lib/database.types";

/**
 * `qr_responses` + embed `question_bank!inner(...)` (jointure inner →
 * l'objet question est garanti non-null).
 */
type QrResponseWithQuestion = Pick<
  Tables<"qr_responses">,
  | "id"
  | "attempt_id"
  | "question_id"
  | "student_answer"
  | "max_score"
  | "trainer_score"
  | "ai_score"
> & {
  question_bank: Pick<
    Tables<"question_bank">,
    "id" | "statement" | "expected_answer" | "scoring_grid"
  >;
};

export const runtime = "nodejs";
export const dynamic = "force-dynamic";
// Claude peut prendre 10-30 s pour générer la note → on bump le timeout
export const maxDuration = 60;

export async function POST(req: NextRequest) {
  if (process.env.FEATURE_AI_TUTOR !== "true") {
    return NextResponse.json({ error: "feature_disabled" }, { status: 503 });
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: "unauth" }, { status: 401 });
  }

  // Vérifie rôle formateur/admin
  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();
  const role = profile?.role;
  if (role !== "trainer" && role !== "admin" && role !== "super_admin") {
    return NextResponse.json({ error: "forbidden" }, { status: 403 });
  }

  // Body
  let body: { response_id?: string };
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ error: "invalid_json" }, { status: 400 });
  }
  const responseId = body.response_id;
  if (!responseId || typeof responseId !== "string") {
    return NextResponse.json(
      { error: "missing_response_id" },
      { status: 400 }
    );
  }

  // Récupération qr_response + question (les RLS trainer/admin
  // autorisent la lecture)
  const { data: resp, error: respErr } = await supabase
    .from("qr_responses")
    .select(`
      id,
      attempt_id,
      question_id,
      student_answer,
      max_score,
      trainer_score,
      ai_score,
      question_bank!inner (
        id,
        statement,
        expected_answer,
        scoring_grid
      )
    `)
    .eq("id", responseId)
    .maybeSingle()
    // Embed many-to-one (`!inner`) : PostgREST renvoie un objet, mais sans
    // schéma typé supabase-js infère un tableau → on rétablit la cardinalité.
    .overrideTypes<QrResponseWithQuestion, { merge: false }>();

  if (respErr || !resp) {
    return NextResponse.json(
      { error: "response_not_found", details: respErr?.message },
      { status: 404 }
    );
  }
  const row: QrResponseWithQuestion = resp;
  if (row.trainer_score != null) {
    return NextResponse.json(
      { error: "already_graded_by_trainer" },
      { status: 409 }
    );
  }

  const question = row.question_bank;
  const studentAnswer = row.student_answer ?? "";

  // Appel Claude
  let result;
  try {
    result = await gradeQrWithClaude({
      questionStatement: question.statement,
      expectedAnswer: question.expected_answer ?? null,
      scoringGrid: question.scoring_grid ?? null,
      maxScore: Number(row.max_score ?? 1),
      studentAnswer,
    });
  } catch (e) {
    console.error("[tutor/grade-qr] Claude error", e);
    return NextResponse.json(
      {
        error: "ai_grading_failed",
        message: e instanceof Error ? e.message : "unknown",
      },
      { status: 500 }
    );
  }

  // Persistance via RPC SECURITY DEFINER
  const { error: rpcErr } = await supabase.rpc("set_qr_ai_grading", {
    p_response: responseId,
    p_score: result.score,
    p_feedback_md: result.feedback_md,
    p_criteria: result.criteria,
    p_confidence: result.confidence,
    p_concerns: result.concerns,
    p_model: result.model,
    p_tokens_in: result.tokens_in,
    p_tokens_out: result.tokens_out,
    p_cost_cents: result.cost_cents,
  });

  if (rpcErr) {
    console.error("[tutor/grade-qr] set_qr_ai_grading error", rpcErr);
    return NextResponse.json(
      { error: "persist_failed", message: rpcErr.message },
      { status: 500 }
    );
  }

  return NextResponse.json({
    ok: true,
    response_id: responseId,
    ai_score: result.score,
    ai_max_score: result.max_score,
    ai_feedback_md: result.feedback_md,
    ai_criteria: result.criteria,
    ai_confidence: result.confidence,
    ai_concerns: result.concerns,
    ai_cost_cents: result.cost_cents,
  });
}
