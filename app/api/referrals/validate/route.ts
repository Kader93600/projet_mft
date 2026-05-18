// =====================================================================
// POST /api/referrals/validate
//
// Valide un code de parrainage saisi par un utilisateur courant.
// Utilisé par l'UI /inscription pour donner un feedback immédiat
// avant de partir sur le checkout Stripe (verts/rouges en temps réel).
//
// Body : { code: string }
// Retour 200 : { valid: true,  reduction_percent: 10 }
// Retour 200 : { valid: false, reason: "code_unknown" | "self_referral" | "already_referred" | "referrer_quota_exceeded" }
// =====================================================================

import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

const REASON_LABELS: Record<string, string> = {
  unauthenticated: "Connectez-vous pour utiliser un code de parrainage.",
  code_unknown: "Ce code de parrainage n'existe pas.",
  self_referral: "Vous ne pouvez pas utiliser votre propre code.",
  already_referred: "Un parrainage est déjà rattaché à votre compte.",
  referrer_quota_exceeded:
    "Ce parrain a atteint son plafond annuel — il ne peut pas vous parrainer cette année.",
};

export async function POST(req: NextRequest) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json(
      { valid: false, reason: "unauthenticated", message: REASON_LABELS.unauthenticated },
      { status: 401 }
    );
  }

  let body: { code?: string };
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ error: "invalid_json" }, { status: 400 });
  }

  const code = (body.code ?? "").trim();
  if (!code) {
    return NextResponse.json(
      { valid: false, reason: "code_unknown", message: REASON_LABELS.code_unknown },
      { status: 400 }
    );
  }

  const { data, error } = await supabase
    .rpc("validate_referral_code", { p_code: code, p_new_user: user.id })
    .single();

  if (error || !data) {
    console.error("[referrals/validate] RPC error", error);
    return NextResponse.json(
      { valid: false, reason: "server_error" },
      { status: 500 }
    );
  }

  const row = data as {
    valid: boolean;
    referrer_id: string | null;
    reason: string | null;
  };

  if (row.valid) {
    return NextResponse.json({
      valid: true,
      reduction_percent: 10,
    });
  }

  const reason = row.reason ?? "code_unknown";
  return NextResponse.json({
    valid: false,
    reason,
    message: REASON_LABELS[reason] ?? "Code invalide.",
  });
}
