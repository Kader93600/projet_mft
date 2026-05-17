// =====================================================================
// GET /api/tutor/conversations/[id]/messages  → historique de la conv
// =====================================================================

import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function GET(
  _req: Request,
  { params }: { params: { id: string } }
) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: "unauth" }, { status: 401 });
  }

  // Vérification propriétaire via la RLS (le SELECT échouera si pas autorisé)
  const { data: conv } = await supabase
    .from("tutor_conversations")
    .select("id, title, context_formation_slug")
    .eq("id", params.id)
    .maybeSingle();
  if (!conv) {
    return NextResponse.json(
      { error: "conversation_not_found" },
      { status: 404 }
    );
  }

  const { data: messages, error } = await supabase
    .from("tutor_messages")
    .select("id, role, content, citations, created_at")
    .eq("conversation_id", params.id)
    .order("created_at", { ascending: true });

  if (error) {
    return NextResponse.json(
      { error: "fetch_failed", message: error.message },
      { status: 500 }
    );
  }

  return NextResponse.json({
    conversation: conv,
    messages: messages ?? [],
  });
}
