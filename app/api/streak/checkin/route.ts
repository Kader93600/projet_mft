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
import { captureException } from "@/lib/observability";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * Ligne unique renvoyée par la RPC `award_daily_login_xp(p_user uuid)`
 * (TABLE(awarded_login int, awarded_streak int, current_streak int,
 * longest_streak int)).
 */
type DailyLoginXp = {
  awarded_login: number;
  awarded_streak: number;
  current_streak: number;
  longest_streak: number;
};

export async function POST() {
  const supabase = await createClient();
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
    await captureException(error, {
      tags: { route: "streak/checkin" },
      extra: { code: error.code, details: error.details },
    });
    return NextResponse.json(
      { awarded_login: 0, awarded_streak: 0, current_streak: 0, longest_streak: 0 },
      { status: 200 }
    );
  }

  const row = data as DailyLoginXp | null;

  return NextResponse.json({
    awarded_login: row?.awarded_login ?? 0,
    awarded_streak: row?.awarded_streak ?? 0,
    current_streak: row?.current_streak ?? 0,
    longest_streak: row?.longest_streak ?? 0,
  });
}
