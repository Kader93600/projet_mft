import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * Endpoint formulaire de contact (vitrine).
 * Stocke la demande dans `enrollment_requests` (table existante)
 * pour que l'admin la traite dans son flux habituel.
 *
 * NB : email transactionnel à brancher plus tard (Resend / Postmark).
 */
export async function POST(req: Request) {
  let body: any;
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ ok: false }, { status: 400 });
  }

  const firstName = String(body?.firstName ?? "").trim();
  const lastName = String(body?.lastName ?? "").trim();
  const email = String(body?.email ?? "").trim().toLowerCase();
  const phone = String(body?.phone ?? "").trim() || null;
  const formation = String(body?.formation ?? "").trim() || null;
  const financeur = String(body?.financeur ?? "").trim() || null;
  const message = String(body?.message ?? "").trim() || null;
  const consent = !!body?.consent;

  if (!firstName || !lastName || !email || !consent) {
    return NextResponse.json({ ok: false, error: "missing_fields" }, { status: 400 });
  }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return NextResponse.json({ ok: false, error: "bad_email" }, { status: 400 });
  }

  const supabase = createClient();
  const fundingMap: Record<string, string> = {
    cpf: "cpf",
    opco: "opco",
    employeur: "employeur",
    pole_emploi: "pole_emploi",
    auto: "auto",
    transitions_pro: "autre",
  };

  const { error } = await supabase.from("enrollment_requests").insert({
    full_name: `${firstName} ${lastName}`.trim(),
    email,
    phone,
    funding_kind: financeur ? fundingMap[financeur] ?? "autre" : "auto",
    message: [
      formation ? `Formation visée : ${formation}` : null,
      message ?? null,
    ]
      .filter(Boolean)
      .join("\n\n"),
    user_id: null,
  });

  if (error) {
    console.error("[contact] insert error", error);
    return NextResponse.json(
      { ok: false, error: "insert_failed" },
      { status: 500 }
    );
  }

  return NextResponse.json({ ok: true });
}
