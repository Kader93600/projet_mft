import { createClient } from "@/lib/supabase/server";
import { NextResponse } from "next/server";
import { rateLimit, rateLimitHeaders, clientIp } from "@/lib/rate-limit";

export const dynamic = "force-dynamic";

const ALLOWED = new Set([
  "essential",
  "analytics",
  "marketing",
  "communications",
  "newsletter",
]);

export async function POST(req: Request) {
  const ip = clientIp(req.headers);
  const rl = await rateLimit({ key: `consent:${ip}`, limit: 30, windowSec: 60 });
  if (!rl.ok) {
    return new NextResponse("Too Many Requests", {
      status: 429,
      headers: rateLimitHeaders(rl, 30),
    });
  }
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ ok: false }, { status: 401 });
  }
  let body: any;
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ ok: false }, { status: 400 });
  }
  const kind = String(body?.kind ?? "");
  if (!ALLOWED.has(kind)) {
    return NextResponse.json({ ok: false }, { status: 400 });
  }
  const granted = !!body?.granted;

  const ipAddr = ip || null;
  const ua = req.headers.get("user-agent") ?? null;

  const { error } = await supabase.from("user_consents").upsert(
    {
      user_id: user.id,
      kind,
      granted,
      granted_at: new Date().toISOString(),
      ip_address: ipAddr,
      user_agent: ua,
    },
    { onConflict: "user_id,kind" }
  );
  if (error) {
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
  return NextResponse.json({ ok: true });
}
