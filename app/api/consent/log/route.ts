import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { rateLimit, rateLimitHeaders, clientIp } from "@/lib/rate-limit";

export const dynamic = "force-dynamic";

// Journal de PREUVE de consentement (CNIL) — fonctionne pour TOUS les
// visiteurs, anonymes inclus (contrairement à /api/me/consent qui exige une
// session et pilote les préférences de l'utilisateur connecté).
//
// L'écriture passe par le client service_role : anon/authenticated n'ont
// aucun droit d'insertion direct sur consent_events (append-only côté serveur).

const KINDS = ["analytics", "marketing", "communications", "newsletter"] as const;

export async function POST(req: Request) {
  const ip = clientIp(req.headers);
  const rl = await rateLimit({ key: `consentlog:${ip}`, limit: 30, windowSec: 60 });
  if (!rl.ok) {
    return new NextResponse("Too Many Requests", {
      status: 429,
      headers: rateLimitHeaders(rl, 30),
    });
  }

  let body: any;
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ ok: false }, { status: 400 });
  }

  // Normalise les choix (jamais de champ inattendu ; essential toujours vrai).
  const raw = body?.choices ?? {};
  const choices: Record<string, boolean> = { essential: true };
  for (const k of KINDS) choices[k] = raw[k] === true;

  const visitorId =
    typeof body?.visitorId === "string" ? body.visitorId.slice(0, 64) : null;
  const version =
    typeof body?.version === "string" ? body.version.slice(0, 32) : "v1";

  // Rattache à la session si elle existe (facultatif — anon accepté).
  let userId: string | null = null;
  try {
    const supabase = createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();
    userId = user?.id ?? null;
  } catch {
    // pas de session : consentement anonyme, on continue
  }

  const admin = createAdminClient();
  const { error } = await admin.from("consent_events").insert({
    visitor_id: visitorId,
    user_id: userId,
    choices,
    policy_version: version,
    ip_address: ip || null,
    user_agent: req.headers.get("user-agent") ?? null,
  });
  if (error) {
    return NextResponse.json({ ok: false }, { status: 500 });
  }
  return NextResponse.json({ ok: true });
}
