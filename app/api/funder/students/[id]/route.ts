// =====================================================================
// GET /api/funder/students/[id]
//
// Drill-down complet d'un stagiaire du portfolio financeur.
// id = user_id (profiles.id).
// =====================================================================

import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { getFunderAccess } from "@/lib/funder/access";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function GET(_req: Request, props: { params: Promise<{ id: string }> }) {
  const params = await props.params;
  const access = await getFunderAccess();
  if (!access.allowed) {
    return NextResponse.json(
      { error: "forbidden", reason: access.reason },
      { status: 403 }
    );
  }

  const supabase = await createClient();

  // Détails depuis la vue (RLS vérifie funder_id == funders.portal_user_id)
  let detailsQuery = supabase
    .from("funder_student_details")
    .select("*")
    .eq("user_id", params.id);

  if (access.funder_id) {
    detailsQuery = detailsQuery.eq("funder_id", access.funder_id);
  }

  const { data: details, error } = await detailsQuery.maybeSingle();

  if (error || !details) {
    return NextResponse.json(
      { error: "not_found", message: error?.message },
      { status: 404 }
    );
  }

  // Échéances de paiement
  const { data: schedule } = await supabase
    .from("payment_schedule")
    .select("id, due_date, amount_cents, paid_at, paid_amount_cents, method, reference")
    .eq("enrollment_id", (details as any).enrollment_id)
    .order("due_date");

  // Tentatives quiz (sans contenu sensible — score seul)
  const { data: attempts } = await supabase
    .from("quiz_attempts")
    .select(`
      id, percentage, passed, finished_at, qcm_score, qr_score, status,
      quizzes ( title, is_mock_exam )
    `)
    .eq("user_id", params.id)
    .order("finished_at", { ascending: false })
    .limit(20);

  // Certificats
  const { data: certificates } = await supabase
    .from("certificates")
    .select("id, type, issued_at, serial")
    .eq("user_id", params.id)
    .is("revoked_at", null)
    .order("issued_at", { ascending: false });

  return NextResponse.json({
    student: details,
    payment_schedule: schedule ?? [],
    quiz_attempts: attempts ?? [],
    certificates: certificates ?? [],
  });
}
