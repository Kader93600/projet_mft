import { NextResponse } from "next/server";
import { cookies } from "next/headers";
import { createClient } from "@/lib/supabase/server";
import { createClient as createServiceClient } from "@supabase/supabase-js";
import { rateLimit, rateLimitHeaders, clientIp } from "@/lib/rate-limit";
import { getAcquisitionSnapshot } from "@/lib/acquisition";
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
  // Anti-spam : endpoint public non authentifié → on limite par IP
  // (un prospect légitime ne soumet pas 5 fois en 10 min).
  const ip = clientIp(req.headers);
  const rl = await rateLimit({ key: `contact:${ip}`, limit: 5, windowSec: 600 });
  if (!rl.ok) {
    return NextResponse.json(
      { ok: false, error: "rate_limited" },
      { status: 429, headers: rateLimitHeaders(rl, 5) },
    );
  }

  let body: any;
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ ok: false }, { status: 400 });
  }

  // Honeypot anti-bot : le champ caché "website" n'est jamais rempli par
  // un humain. S'il l'est, on répond 200 (succès factice) SANS rien créer
  // ni envoyer — le bot croit avoir réussi et n'adapte pas sa stratégie.
  if (String(body?.website ?? "").trim() !== "") {
    return NextResponse.json({ ok: true });
  }

  const firstName = String(body?.firstName ?? "").trim();
  const lastName = String(body?.lastName ?? "").trim();
  const email = String(body?.email ?? "").trim().toLowerCase();
  const phone = String(body?.phone ?? "").trim() || null;
  const adresse = String(body?.adresse ?? "").trim() || null;
  const codePostal = String(body?.code_postal ?? "").trim() || null;
  const ville = String(body?.ville ?? "").trim() || null;
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

  // Téléphone requis : le formulaire promet un rappel — un lead sans
  // numéro est injoignable (cohérent avec le `required` côté client).
  if (!firstName || !lastName || !email || !phone || !consent) {
    return NextResponse.json({ ok: false, error: "missing_fields" }, { status: 400 });
  }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return NextResponse.json({ ok: false, error: "bad_email" }, { status: 400 });
  }

  const supabase = createClient();

  // Snapshot d'attribution : on relie le lead à son parcours marketing via
  // le cookie visiteur (mft_vid) — même si l'URL ne porte plus les params
  // (utm/click-IDs captés à l'atterrissage, pas forcément sur /contact).
  // Best-effort : `attribution` peut être null, on n'empêche jamais la
  // création du lead pour autant.
  const visitorId = cookies().get("mft_vid")?.value ?? null;
  const attribution = await getAcquisitionSnapshot(visitorId);

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
    adresse,
    code_postal: codePostal,
    ville,
    formation_slug: formation || null,
    funding_kind: financeur ? fundingMap[financeur] ?? "autre" : "auto",
    message: [
      formation ? `Formation visée : ${formation}` : null,
      pack ? `Pack souhaité : ${PACK_LABELS[pack] ?? pack}` : null,
      message ?? null,
    ]
      .filter(Boolean)
      .join("\n\n"),
    user_id: null,
    // Snapshot d'attribution marketing (figé à la soumission)
    visitor_id: visitorId,
    utm_source: attribution?.utm_source ?? null,
    utm_medium: attribution?.utm_medium ?? null,
    utm_campaign: attribution?.utm_campaign ?? null,
    gclid: attribution?.gclid ?? null,
    gbraid: attribution?.gbraid ?? null,
    wbraid: attribution?.wbraid ?? null,
    fbclid: attribution?.fbclid ?? null,
    ttclid: attribution?.ttclid ?? null,
    msclkid: attribution?.msclkid ?? null,
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

  // Helper fire-and-forget qui catch silencieusement les erreurs
  // transient (timeout Resend, abort à la fin de la fonction Vercel).
  // Sans ce wrapper, le `void sendEmail(...)` faisait remonter à Sentry
  // chaque TypeError: fetch failed (JAVASCRIPT-NEXTJS-5) → pollution
  // d'alertes sans intérêt opérationnel (l'utilisateur ne voit pas
  // l'échec, la commande a déjà répondu 200).
  const fireEmail = (payload: Parameters<typeof sendEmail>[0]) => {
    sendEmail(payload).catch(() => {
      // L'erreur a déjà été loggée dans lib/email.ts (Sentry
      // captureException tagué service:email). Pas besoin de
      // re-propager au handler ici.
    });
  };

  // Admin : nouveau lead à traiter
  if (adminEmail) {
    fireEmail({
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
  fireEmail({
    to: email,
    ...enrollmentReceivedEmail({ fullName }),
    tags: [{ name: "kind", value: "lead_ack" }],
  });

  return NextResponse.json({ ok: true });
}
