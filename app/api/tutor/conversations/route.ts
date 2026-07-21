// =====================================================================
// GET  /api/tutor/conversations          → liste les convs de l'utilisateur
// POST /api/tutor/conversations          → crée une nouvelle conv vide
// =====================================================================

import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { getTutorAccess } from "@/lib/tutor/access";
import { captureException } from "@/lib/observability";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function GET() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: "unauth" }, { status: 401 });
  }

  // Gate Premium pour cacher l'existence du feature
  const access = await getTutorAccess();
  if (!access.allowed) {
    return NextResponse.json(
      { error: "forbidden", reason: access.reason, conversations: [] },
      { status: 403 }
    );
  }

  const { data, error } = await supabase
    .from("tutor_conversations")
    .select("id, title, context_formation_slug, created_at, updated_at")
    .eq("user_id", user.id)
    .order("updated_at", { ascending: false })
    .limit(30);

  if (error) {
    await captureException(error, { tags: { route: "tutor/conversations" } });
    return NextResponse.json({ error: "fetch_failed" }, { status: 500 });
  }

  return NextResponse.json({ conversations: data ?? [] });
}

export async function POST(req: NextRequest) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: "unauth" }, { status: 401 });
  }

  const access = await getTutorAccess();
  if (!access.allowed) {
    return NextResponse.json(
      { error: "forbidden", reason: access.reason },
      { status: 403 }
    );
  }

  const body = (await req.json().catch(() => ({}))) as {
    title?: string;
    formation_slug?: string;
  };

  const { data, error } = await supabase
    .from("tutor_conversations")
    .insert({
      user_id: user.id,
      title: body.title?.slice(0, 100) ?? "Nouvelle conversation",
      context_formation_slug: body.formation_slug ?? null,
    })
    .select("id, title, created_at, updated_at")
    .single();

  if (error || !data) {
    return NextResponse.json(
      { error: "create_failed", message: error?.message },
      { status: 500 }
    );
  }

  return NextResponse.json({ conversation: data });
}
