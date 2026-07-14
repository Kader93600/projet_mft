// =====================================================================
// GET /api/funder/dashboard
//
// Récap temps réel pour le portail financeur (page d'accueil).
// =====================================================================

import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { getFunderAccess } from "@/lib/funder/access";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function GET() {
  const access = await getFunderAccess();
  if (!access.allowed) {
    return NextResponse.json(
      { error: "forbidden", reason: access.reason },
      { status: 403 }
    );
  }

  const supabase = await createClient();

  // KPIs agrégés via RPC SECURITY DEFINER
  const { data: kpis, error: kpisErr } = await supabase
    .rpc("funder_dashboard_kpis", {
      p_funder_id: access.funder_id,
    })
    .single();

  if (kpisErr) {
    return NextResponse.json(
      { error: "fetch_failed", message: kpisErr.message },
      { status: 500 }
    );
  }

  // Événements récents (90 jours)
  const eventsQuery = supabase
    .from("funder_recent_events")
    .select("*")
    .order("occurred_at", { ascending: false })
    .limit(20);

  if (access.funder_id) {
    eventsQuery.eq("funder_id", access.funder_id);
  }

  const { data: events } = await eventsQuery;

  return NextResponse.json({
    funder: {
      id: access.funder_id,
      name: access.funder_name,
      kind: access.funder_kind,
      is_admin: access.is_admin,
    },
    kpis,
    events: events ?? [],
  });
}
