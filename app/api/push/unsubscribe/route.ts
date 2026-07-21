import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { captureException } from "@/lib/observability";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * POST /api/push/unsubscribe
 * Body: { endpoint: string }
 *
 * Supprime un abonnement push. RLS s'assure que l'utilisateur ne peut
 * supprimer que les siens.
 */
export async function POST(req: Request) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: "unauthorized" }, { status: 401 });
  }

  let body: { endpoint?: string };
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ error: "invalid_json" }, { status: 400 });
  }

  const endpoint = body?.endpoint;
  if (!endpoint || typeof endpoint !== "string") {
    return NextResponse.json({ error: "missing_endpoint" }, { status: 400 });
  }

  const { error } = await supabase
    .from("push_subscriptions")
    .delete()
    .eq("endpoint", endpoint)
    .eq("user_id", user.id);

  if (error) {
    await captureException(error, { tags: { route: "push/unsubscribe" } });
    return NextResponse.json({ error: "unsubscribe_failed" }, { status: 500 });
  }
  return NextResponse.json({ ok: true });
}
