// ============================================================
// Helpers Web Push côté client
// ============================================================
// Gère l'enregistrement du Service Worker, la souscription au
// PushManager, le mappage des permissions navigateur et la
// communication avec les routes /api/push/*.
// ============================================================

export type PushStatus =
  | "unsupported"   // navigateur sans Service Worker / PushManager
  | "default"       // permission jamais demandée
  | "granted"       // permission accordée + abonnement actif
  | "granted_unsubscribed" // permission OK mais pas abonné (rare)
  | "denied";       // permission bloquée par l'utilisateur

/**
 * Détecte le support et l'état actuel des notifications push.
 * Côté serveur : retourne toujours "unsupported".
 */
export async function getPushStatus(): Promise<PushStatus> {
  if (typeof window === "undefined") return "unsupported";
  if (!("serviceWorker" in navigator) || !("PushManager" in window)) {
    return "unsupported";
  }
  if (typeof Notification === "undefined") return "unsupported";

  if (Notification.permission === "denied") return "denied";
  if (Notification.permission === "default") return "default";

  // Permission accordée → vérifier l'abonnement actif
  try {
    const reg = await navigator.serviceWorker.getRegistration("/sw.js");
    if (!reg) return "granted_unsubscribed";
    const sub = await reg.pushManager.getSubscription();
    return sub ? "granted" : "granted_unsubscribed";
  } catch {
    return "granted_unsubscribed";
  }
}

/**
 * Demande la permission, enregistre le Service Worker, souscrit
 * au PushManager et envoie l'abonnement à l'API.
 * Throw si VAPID public key absente ou permission refusée.
 */
export async function subscribeToPush(): Promise<void> {
  if (typeof window === "undefined") return;
  if (!("serviceWorker" in navigator) || !("PushManager" in window)) {
    throw new Error("Notifications push non supportées par ce navigateur.");
  }

  const vapidKey = process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY;
  if (!vapidKey) {
    throw new Error(
      "Configuration manquante : NEXT_PUBLIC_VAPID_PUBLIC_KEY non définie."
    );
  }

  // 1) Permission
  const permission = await Notification.requestPermission();
  if (permission !== "granted") {
    throw new Error(
      permission === "denied"
        ? "Permission refusée. Autorise les notifications dans les réglages du navigateur."
        : "Permission non accordée."
    );
  }

  // 2) Service Worker
  const reg = await navigator.serviceWorker.register("/sw.js", {
    scope: "/",
  });
  await navigator.serviceWorker.ready;

  // 3) Souscription
  const existing = await reg.pushManager.getSubscription();
  const sub =
    existing ??
    (await reg.pushManager.subscribe({
      userVisibleOnly: true,
      // Cast nécessaire : l'API attend BufferSource ; lib.dom.d.ts récents
      // sont stricts sur Uint8Array<ArrayBufferLike> vs ArrayBuffer.
      applicationServerKey: urlBase64ToUint8Array(vapidKey) as BufferSource,
    }));

  // 4) Sauvegarde côté serveur
  const json = sub.toJSON();
  const res = await fetch("/api/push/subscribe", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      endpoint: json.endpoint,
      p256dh: json.keys?.p256dh,
      auth: json.keys?.auth,
    }),
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err.error || "Échec d'enregistrement de l'abonnement.");
  }
}

/**
 * Désabonne le device courant (côté navigateur + côté serveur).
 */
export async function unsubscribeFromPush(): Promise<void> {
  if (typeof window === "undefined") return;
  if (!("serviceWorker" in navigator)) return;

  const reg = await navigator.serviceWorker.getRegistration("/sw.js");
  if (!reg) return;
  const sub = await reg.pushManager.getSubscription();
  if (!sub) return;

  const endpoint = sub.endpoint;
  await sub.unsubscribe();

  await fetch("/api/push/unsubscribe", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ endpoint }),
  }).catch(() => {});
}

/**
 * Envoie un push de test à l'utilisateur courant (sur tous ses devices).
 * Utile pour vérifier la chaîne complète depuis la page Préférences.
 */
export async function sendTestPush(): Promise<{ ok: boolean; sent?: number; error?: string }> {
  const res = await fetch("/api/push/test", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
  });
  const body = await res.json().catch(() => ({}));
  if (!res.ok) return { ok: false, error: body.error || `HTTP ${res.status}` };
  return { ok: true, sent: body.sent ?? 0 };
}

// ── Helpers ────────────────────────────────────────────────────

function urlBase64ToUint8Array(base64String: string): Uint8Array {
  const padding = "=".repeat((4 - (base64String.length % 4)) % 4);
  const base64 = (base64String + padding)
    .replace(/-/g, "+")
    .replace(/_/g, "/");
  const raw = typeof atob === "function" ? atob(base64) : "";
  const out = new Uint8Array(raw.length);
  for (let i = 0; i < raw.length; ++i) out[i] = raw.charCodeAt(i);
  return out;
}
