import { NextResponse } from "next/server";
import { cookies } from "next/headers";
import { createClient } from "@/lib/supabase/server";
import { createClient as createServiceClient } from "@supabase/supabase-js";
import {
  sendEmail,
  newLeadEmail,
  enrollmentReceivedEmail,
} from "@/lib/email";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * Endpoint formulaire de contact (vitrine).
 * Stocke la demande dans `enrollment_requests` (table existante)
 * pour que l'admin la traite dans son flux habituel.
 *
 * Notifications email (best-effort, fire-and-forget) :
 *   - admin    → nouveau lead à traiter
 *   - prospect → accusé de réception (sous 48h)
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
  const pack = String(body?.pack ?? "").trim() || null;
  const message = String(body?.message ?? "").trim() || null;
  const consent = !!body?.consent;

  const PACK_LABELS: Record<string, string> = {
    initial: "Initial (préparation autonome)",
    medium: "Medium (formateur attitré)",
    premium: "Premium (sessions présentielles)",
  };

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
      pack ? `Pack souhaité : ${PACK_LABELS[pack] ?? pack}` : null,
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

  // Tracking acquisition : émet un event "contact_form" lié au visitor_id
  // (best-effort). Permet de mesurer le funnel landing → contact par canal.
  try {
    const visitorId = cookies().get("mft_vid")?.value;
    if (visitorId) {
      const supaUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
      const supaKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
      if (supaUrl && supaKey) {
        const svc = createServiceClient(supaUrl, supaKey, {
          auth: { persistSession: false },
        });
        await svc.from("acquisition_events").insert({
          visitor_id: visitorId,
          kind: "contact_form",
          landing_page: "/contact",
          referrer: req.headers.get("referer") ?? null,
          user_agent: req.headers.get("user-agent")?.slice(0, 300) ?? null,
        });
      }
    }
  } catch (e) {
    console.warn("[contact] acquisition tracking failed (non-bloquant)", e);
  }

  // Notifications email (best-effort, ne bloque pas la réponse)
  const adminEmail = process.env.LEADS_NOTIFY_EMAIL || process.env.EMAIL_REPLY_TO;
  const fullName = `${firstName} ${lastName}`.trim();
  const appUrl =
    process.env.NEXT_PUBLIC_APP_URL ||
    new URL(req.url).origin;

  // Admin : nouveau lead à traiter
  if (adminEmail) {
    void sendEmail({
      to: adminEmail,
      ...newLeadEmail({
        fullName,
        email,
        phone,
        fundingKind: financeur,
        formation,
        message,
        adminUrl: `${appUrl}/admin/enrollments`,
      }),
      tags: [{ name: "kind", value: "lead_new" }],
    });
  }

  // Prospect : accusé de réception
  void sendEmail({
    to: email,
    ...enrollmentReceivedEmail({ fullName }),
    tags: [{ name: "kind", value: "lead_ack" }],
  });

  return NextResponse.json({ ok: true });
}
