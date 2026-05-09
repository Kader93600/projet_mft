import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * POST /api/push/subscribe
 * Body: { endpoint: string, p256dh: string, auth: string }
 *
 * Enregistre (upsert sur endpoint) un abonnement push pour l'utilisateur
 * courant. Renvoie 401 si non authentifié, 400 si payload invalide.
 */
export async function POST(req: Request) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: "unauthorized" }, { status: 401 });
  }

  let body: { endpoint?: string; p256dh?: string; auth?: string };
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ error: "invalid_json" }, { status: 400 });
  }

  const { endpoint, p256dh, auth } = body;
  if (
    !endpoint ||
    typeof endpoint !== "string" ||
    !p256dh ||
    typeof p256dh !== "string" ||
    !auth ||
    typeof auth !== "string"
  ) {
    return NextResponse.json(
      { error: "missing_fields", needs: ["endpoint", "p256dh", "auth"] },
      { status: 400 }
    );
  }

  const userAgent = req.headers.get("user-agent") ?? null;

  const { error } = await supabase
    .from("push_subscriptions")
    .upsert(
      {
        user_id: user.id,
        endpoint,
        p256dh,
        auth,
        user_agent: userAgent,
        last_used_at: new Date().toISOString(),
      },
      { onConflict: "endpoint" }
    );

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
  return NextResponse.json({ ok: true });
}
