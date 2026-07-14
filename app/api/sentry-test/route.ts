// =====================================================================
// /api/sentry-test — Endpoint de validation du wiring Sentry
//
// Génère volontairement une erreur server pour vérifier qu'elle remonte
// bien dans le dashboard Sentry. À utiliser une seule fois après le
// déploiement, puis à laisser en place (utile pour les re-tests).
//
// Sécurité : seul un admin authentifié peut déclencher le test (sinon
// n'importe qui pourrait spammer le compteur d'événements Sentry).
// =====================================================================

import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { isStaff } from "@/lib/permissions";
import { captureMessage } from "@/lib/observability";

export const dynamic = "force-dynamic";

export async function GET(request: Request) {
  // Garde admin
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: "Non authentifié" }, { status: 401 });
  }
  const { data: profile } = await supabase
    .from("profiles")
    .select("role, email")
    .eq("id", user.id)
    .single();
  if (!isStaff(profile?.role)) {
    return NextResponse.json({ error: "Accès refusé" }, { status: 403 });
  }

  // Type de test demandé via ?kind=
  const kind = new URL(request.url).searchParams.get("kind") ?? "error";

  if (kind === "message") {
    // Test soft : envoie un message (level=info) — ne déclenche pas d'alerte.
    await captureMessage("🧪 Test Sentry — message info", {
      level: "info",
      user: { id: user.id, email: profile?.email ?? undefined, role: profile?.role },
      tags: { test: "true", source: "sentry-test-endpoint" },
    });
    return NextResponse.json({
      ok: true,
      kind: "message",
      sent: "info",
      note: "Vérifiez sentry.io > Issues → vous devez voir un nouvel event 'Test Sentry — message info' dans les 30 secondes.",
    });
  }

  if (kind === "warning") {
    // Test warning : déclenche une alerte légère.
    await captureMessage("🧪 Test Sentry — warning", {
      level: "warning",
      user: { id: user.id, email: profile?.email ?? undefined, role: profile?.role },
      tags: { test: "true", source: "sentry-test-endpoint" },
    });
    return NextResponse.json({
      ok: true,
      kind: "warning",
      sent: "warning",
    });
  }

  // Test par défaut : throw une vraie exception (level=error → alerte stricte).
  // C'est ce test qui doit déclencher la notification Email configurée
  // dans Sentry > Alerts.
  throw new Error(
    `🧪 Test Sentry — erreur volontaire déclenchée par ${profile?.email ?? user.id} le ${new Date().toISOString()}`
  );
}
