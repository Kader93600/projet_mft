import { createClient } from "@/lib/supabase/server";
import { NextResponse } from "next/server";
import { rateLimit, rateLimitHeaders, clientIp } from "@/lib/rate-limit";
import { captureException } from "@/lib/observability";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function GET(req: Request) {
  const ip = clientIp(req.headers);
  const rl = await rateLimit({ key: `search:${ip}`, limit: 60, windowSec: 60 });
  if (!rl.ok) {
    return new NextResponse("Too Many Requests", {
      status: 429,
      headers: rateLimitHeaders(rl, 60),
    });
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: "unauth" }, { status: 401 });

  const { searchParams } = new URL(req.url);
  const q = (searchParams.get("q") ?? "").trim();
  const max = Math.min(Math.max(Number(searchParams.get("max") ?? 5), 1), 15);
  // "log=1" : signal explicite envoyé par la page de résultats (vs auto-complétion).
  // Évite de polluer les logs avec chaque keystroke.
  const shouldLog = searchParams.get("log") === "1";

  if (q.length < 2) {
    return NextResponse.json({ q, results: [] });
  }
  const { data, error } = await supabase.rpc("global_search", {
    q,
    max_per_kind: max,
  });
  if (error) {
    await captureException(error, { tags: { route: "search" } });
    return NextResponse.json({ error: "search_failed" }, { status: 500 });
  }

  const results = data ?? [];

  if (shouldLog) {
    // Fire-and-forget : on n'attend pas l'insertion
    supabase
      .from("search_logs")
      .insert({
        user_id: user.id,
        query: q,
        results_count: results.length,
      })
      .then(() => undefined);
  }

  return NextResponse.json({ q, results });
}
