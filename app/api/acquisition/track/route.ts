// =====================================================================
// POST /api/acquisition/track
//
// Endpoint UTM tracking pour les pages publiques. Fonctionne sans auth.
//
// Décisions client (cf. docs/p3-3-marketing-data.md) :
//   • Attribution : first-touch (calculée par la vue acquisition_attribution)
//   • Cookie : `mft_vid` httpOnly 90j, traité comme essentiel au service
//   • Périmètre : pages publiques uniquement (pas d'auth requise)
//
// Body : { kind, landing_page, referrer?, utm_source?, utm_medium?,
//          utm_campaign?, utm_content?, utm_term?,
//          gclid?, gbraid?, wbraid?, fbclid?, ttclid?, msclkid? }
//
// Comportement :
//   1. Lit ou génère le cookie `mft_vid` (UUID v4)
//   2. Si user déjà connecté : récupère son user_id
//   3. Insère ligne dans acquisition_events (service_role bypass RLS)
//   4. Retourne 204 No Content (fire-and-forget côté client)
//
// Anti-bot léger : on filtre les UA évidents (Googlebot, Bingbot, etc.)
// =====================================================================

import { NextRequest, NextResponse } from "next/server";
import { createClient as createBrowserClient } from "@/lib/supabase/server";
import { createClient as createServiceClient } from "@supabase/supabase-js";
import { rateLimit, clientIp } from "@/lib/rate-limit";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

const COOKIE_NAME = "mft_vid";
const COOKIE_MAX_AGE = 60 * 60 * 24 * 90; // 90 jours

const BOT_UA_PATTERN =
  /bot|crawler|spider|preview|fetch|monitor|uptimerobot|headlesschrome/i;

type TrackBody = {
  kind?: "landing" | "contact_form" | "signup" | "enrollment";
  landing_page?: string;
  referrer?: string;
  utm_source?: string;
  utm_medium?: string;
  utm_campaign?: string;
  utm_content?: string;
  utm_term?: string;
  // Click-IDs régies publicitaires
  gclid?: string;
  gbraid?: string;
  wbraid?: string;
  fbclid?: string;
  ttclid?: string;
  msclkid?: string;
};

function generateVisitorId(): string {
  return (globalThis as any).crypto?.randomUUID?.() ??
    `v_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 10)}`;
}

function clean(v: any, maxLen = 200): string | null {
  if (typeof v !== "string") return null;
  const trimmed = v.trim();
  if (!trimmed) return null;
  return trimmed.slice(0, maxLen);
}

export async function POST(req: NextRequest) {
  // Anti-bot : refuse les requêtes des crawlers (pas d'erreur, juste no-op)
  const ua = req.headers.get("user-agent") ?? "";
  if (BOT_UA_PATTERN.test(ua)) {
    return new NextResponse(null, { status: 204 });
  }

  // Anti-flood : beacon public → on plafonne par IP et on droppe
  // silencieusement (204) au-delà, pour ne pas polluer acquisition_events.
  const rl = await rateLimit({
    key: `track:${clientIp(req.headers)}`,
    limit: 100,
    windowSec: 60,
  });
  if (!rl.ok) {
    return new NextResponse(null, { status: 204 });
  }

  let body: TrackBody;
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ error: "invalid_json" }, { status: 400 });
  }

  const kind = body.kind ?? "landing";
  if (!["landing", "contact_form", "signup", "enrollment"].includes(kind)) {
    return NextResponse.json({ error: "invalid_kind" }, { status: 400 });
  }

  // 1. Visitor ID : cookie existant ou nouveau
  let visitorId = req.cookies.get(COOKIE_NAME)?.value ?? null;
  const isNewVisitor = !visitorId;
  if (!visitorId) {
    visitorId = generateVisitorId();
  }

  // 2. User ID si déjà connecté
  let userId: string | null = null;
  try {
    const supabase = createBrowserClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();
    userId = user?.id ?? null;
  } catch {
    // L'utilisateur n'est pas connecté → OK
  }

  // 3. Géo via Vercel (sans IP brute)
  const country =
    req.headers.get("x-vercel-ip-country") ||
    req.headers.get("cf-ipcountry") ||
    null;

  // 4. Insert dans acquisition_events (service role pour bypass RLS)
  const supaUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const supaKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (supaUrl && supaKey) {
    const svc = createServiceClient(supaUrl, supaKey, {
      auth: { persistSession: false },
    });
    await svc.from("acquisition_events").insert({
      visitor_id: visitorId,
      user_id: userId,
      kind,
      landing_page: clean(body.landing_page, 500) ?? "/",
      referrer: clean(body.referrer, 500),
      utm_source: clean(body.utm_source, 100),
      utm_medium: clean(body.utm_medium, 100),
      utm_campaign: clean(body.utm_campaign, 200),
      utm_content: clean(body.utm_content, 200),
      utm_term: clean(body.utm_term, 200),
      // Click-IDs régies (fbclid/ttclid peuvent être longs → 400)
      gclid: clean(body.gclid, 200),
      gbraid: clean(body.gbraid, 200),
      wbraid: clean(body.wbraid, 200),
      fbclid: clean(body.fbclid, 400),
      ttclid: clean(body.ttclid, 400),
      msclkid: clean(body.msclkid, 200),
      user_agent: ua.slice(0, 300),
      ip_country: country ? country.slice(0, 4) : null,
    });
  }

  // 5. Pose le cookie si nouveau visiteur
  const res = new NextResponse(null, { status: 204 });
  if (isNewVisitor) {
    res.cookies.set({
      name: COOKIE_NAME,
      value: visitorId,
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "lax",
      maxAge: COOKIE_MAX_AGE,
      path: "/",
    });
  }
  return res;
}
