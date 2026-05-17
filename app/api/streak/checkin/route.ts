// =====================================================================
// POST /api/streak/checkin
//
// Appelé une fois par chargement de la session par <DailyCheckin />
// (composant client monté dans AuthLayout). Idempotent par jour grâce
// à la déduplication sur xp_events.ref_id = current_date dans la RPC
// `award_daily_login_xp`.
//
// Retourne le détail de l'XP octroyé du jour pour pouvoir afficher
// un toast côté client si le stagiaire vient de gagner du XP.
// =====================================================================

import { createClient } from "@/lib/supabase/server";
import { NextResponse } from "next/server";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function POST() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: "unauth" }, { status: 401 });
  }

  const { data, error } = await supabase
    .rpc("award_daily_login_xp", { p_user: user.id })
    .single();

  if (error) {
    // On évite de remonter une erreur 500 pour ne pas casser le rendu
    // du dashboard côté client : la RPC est best-effort.
    console.error("[streak/checkin] RPC error", {
      message: error.message,
      code: error.code,
      details: error.details,
    });
    return NextResponse.json(
      { awarded_login: 0, awarded_streak: 0, current_streak: 0, longest_streak: 0 },
      { status: 200 }
    );
  }

  return NextResponse.json({
    awarded_login: (data as any)?.awarded_login ?? 0,
    awarded_streak: (data as any)?.awarded_streak ?? 0,
    current_streak: (data as any)?.current_streak ?? 0,
    longest_streak: (data as any)?.longest_streak ?? 0,
  });
}
