import { NextResponse } from "next/server";
import webpush from "web-push";
import { createAdminClient } from "@/lib/supabase/admin";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * POST /api/push/send
 *
 * Endpoint déclenché par la Database Webhook Supabase configurée sur
 * INSERT public.notifications.
 *
 * Sécurité : header `X-Webhook-Secret` doit matcher PUSH_WEBHOOK_SECRET.
 *
 * Payload Supabase Database Webhook (INSERT) :
 *   {
 *     type: "INSERT",
 *     table: "notifications",
 *     record: { id, user_id, type, title, body, link_url, ... },
 *     ...
 *   }
 *
 * Logique :
 *   1) Vérifie le secret
 *   2) Charge les préférences push du destinataire (skip si type désactivé)
 *   3) Charge les abonnements actifs du destinataire
 *   4) Envoie un push à chacun via web-push (VAPID)
 *   5) Si le push service répond 410 Gone → supprime l'abonnement périmé
 */
export async function POST(req: Request) {
  // ── 1) Authentification du webhook ──────────────────────────
  const expectedSecret = process.env.PUSH_WEBHOOK_SECRET;
  if (!expectedSecret) {
    return NextResponse.json(
      { error: "server_misconfigured" },
      { status: 500 }
    );
  }
  const provided =
    req.headers.get("x-webhook-secret") ??
    req.headers.get("authorization")?.replace(/^Bearer\s+/i, "");
  if (provided !== expectedSecret) {
    return NextResponse.json({ error: "forbidden" }, { status: 403 });
  }

  // ── 2) Parse payload ─────────────────────────────────────────
  let payload: any;
  try {
    payload = await req.json();
  } catch {
    return NextResponse.json({ error: "invalid_json" }, { status: 400 });
  }

  const record = payload?.record ?? payload;
  const userId: string | undefined = record?.user_id;
  const notifId: string | undefined = record?.id;
  const type: string = record?.type ?? "system";
  const title: string = record?.title ?? "Nouvelle notification";
  const body: string = record?.body ?? "";
  const linkUrl: string | null = record?.link_url ?? null;

  if (!userId) {
    return NextResponse.json({ error: "missing_user_id" }, { status: 400 });
  }

  // ── 3) VAPID config ──────────────────────────────────────────
  const vapidPublic = process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY;
  const vapidPrivate = process.env.VAPID_PRIVATE_KEY;
  const vapidSubject = process.env.VAPID_SUBJECT;
  if (!vapidPublic || !vapidPrivate || !vapidSubject) {
    return NextResponse.json(
      { error: "vapid_not_configured" },
      { status: 500 }
    );
  }
  webpush.setVapidDetails(vapidSubject, vapidPublic, vapidPrivate);

  const admin = createAdminClient();

  // ── 4) Vérifier les préférences push de l'utilisateur ─────────
  const { data: prefs } = await admin
    .from("notification_preferences")
    .select("push_disabled")
    .eq("user_id", userId)
    .maybeSingle();
  const disabled: string[] = prefs?.push_disabled ?? [];
  if (disabled.includes(type)) {
    return NextResponse.json({ ok: true, skipped: "type_disabled_by_user" });
  }

  // ── 5) Charger les abonnements de l'utilisateur ──────────────
  const { data: subs, error: subsErr } = await admin
    .from("push_subscriptions")
    .select("endpoint, p256dh, auth")
    .eq("user_id", userId);

  if (subsErr) {
    return NextResponse.json({ error: subsErr.message }, { status: 500 });
  }
  if (!subs || subs.length === 0) {
    return NextResponse.json({ ok: true, skipped: "no_subscriptions" });
  }

  // ── 6) Construire le payload push ────────────────────────────
  const pushPayload = JSON.stringify({
    title,
    body,
    url: linkUrl ?? "/notifications",
    tag: notifId ? `notif-${notifId}` : undefined,
    notifId: notifId ?? null,
    icon: "/icon-192.png",
    badge: "/icon-72.png",
  });

  // ── 7) Envoyer en parallèle ──────────────────────────────────
  const nowIso = new Date().toISOString();
  const results = await Promise.all(
    subs.map(async (sub) => {
      try {
        await webpush.sendNotification(
          {
            endpoint: sub.endpoint,
            keys: { p256dh: sub.p256dh, auth: sub.auth },
          },
          pushPayload
        );
        // Touch last_used_at (best-effort, n'échoue pas la réponse globale)
        await admin
          .from("push_subscriptions")
          .update({ last_used_at: nowIso })
          .eq("endpoint", sub.endpoint);
        return { endpoint: sub.endpoint, ok: true };
      } catch (err: any) {
        const status: number | undefined = err?.statusCode;
        // 404/410 : abonnement périmé → on le supprime
        if (status === 404 || status === 410) {
          await admin
            .from("push_subscriptions")
            .delete()
            .eq("endpoint", sub.endpoint);
        }
        return { endpoint: sub.endpoint, ok: false, status };
      }
    })
  );

  const sent = results.filter((r) => r.ok).length;
  return NextResponse.json({ ok: true, sent, total: results.length, results });
}
