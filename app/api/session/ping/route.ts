import { createClient } from "@/lib/supabase/server";
import { NextRequest, NextResponse } from "next/server";
import { captureException } from "@/lib/observability";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function POST(req: NextRequest) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: "unauth" }, { status: 401 });

  const body = await req.json().catch(() => ({}));
  const path: string | null = typeof body.path === "string" ? body.path.slice(0, 200) : null;
  const ua: string | null = req.headers.get("user-agent")?.slice(0, 300) ?? null;

  const { data, error } = await supabase.rpc("ping_session", {
    p_path: path,
    p_user_agent: ua,
  });
  if (error) {
    await captureException(error, { tags: { route: "session/ping" } });
    return NextResponse.json({ error: "ping_failed" }, { status: 500 });
  }

  // Optionnel : si le ping concerne une leçon, on ping aussi la vue de leçon
  if (body.lesson_id && typeof body.lesson_id === "string") {
    await supabase.rpc("ping_lesson_view", {
      p_lesson_id: body.lesson_id,
      p_completed: !!body.lesson_completed,
    });
  }

  return NextResponse.json({ session_id: data });
}
