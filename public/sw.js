// ============================================================
// Service Worker — MA FORMATION TRANSPORT
// ============================================================
// Deux responsabilités :
//   1. Web Push notifications (existant) : push, notificationclick
//   2. PWA offline-first léger (nouveau) :
//      - Précache la page /offline + les icônes à l'install
//      - Network first sur les navigations, fallback cache, puis /offline
//      - Ne touche PAS aux API, auth, _next/data, ingest PostHog
// ============================================================

const CACHE_VERSION = "mft-v1";
const STATIC_CACHE = `${CACHE_VERSION}-static`;
const OFFLINE_URL = "/offline";

const PRECACHE_URLS = [
  OFFLINE_URL,
  "/icon.svg",
  "/apple-icon.svg",
  "/manifest.webmanifest",
];

// ─── INSTALL ──────────────────────────────────────────────────
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches
      .open(STATIC_CACHE)
      .then((cache) =>
        Promise.allSettled(PRECACHE_URLS.map((url) => cache.add(url)))
      )
  );
  // Active immédiatement le nouveau SW sans attendre la fermeture des onglets.
  self.skipWaiting();
});

// ─── ACTIVATE ─────────────────────────────────────────────────
self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys
          .filter((k) => k.startsWith("mft-") && !k.startsWith(CACHE_VERSION))
          .map((k) => caches.delete(k))
      )
    )
  );
  // Prend le contrôle des clients ouverts immédiatement.
  event.waitUntil(self.clients.claim());
});

// ─── FETCH (offline-first) ────────────────────────────────────
self.addEventListener("fetch", (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Ne pas intercepter :
  if (
    request.method !== "GET" ||
    url.origin !== self.location.origin ||
    url.pathname.startsWith("/api/") ||
    url.pathname.startsWith("/auth/") ||
    url.pathname.startsWith("/_next/data/") ||
    url.pathname.startsWith("/ingest/") || // PostHog tunnel
    url.pathname === "/sw.js"
  ) {
    return;
  }

  event.respondWith(
    fetch(request)
      .then((response) => {
        // Met en cache uniquement les réponses 200 basic/opaque
        if (
          response &&
          response.status === 200 &&
          (response.type === "basic" || response.type === "opaque")
        ) {
          const copy = response.clone();
          caches.open(STATIC_CACHE).then((cache) => cache.put(request, copy));
        }
        return response;
      })
      .catch(async () => {
        // Plus de réseau : cache, puis page offline en dernier recours
        const cached = await caches.match(request);
        if (cached) return cached;
        if (request.mode === "navigate") {
          const offline = await caches.match(OFFLINE_URL);
          if (offline) return offline;
        }
        return new Response("Network error", {
          status: 408,
          statusText: "Request Timeout",
        });
      })
  );
});

// ─── PUSH (Web Push existant — inchangé) ──────────────────────
self.addEventListener("push", (event) => {
  if (!event.data) return;

  let payload;
  try {
    payload = event.data.json();
  } catch (_err) {
    payload = { title: "Notification", body: event.data.text() };
  }

  const title = payload.title || "MA FORMATION TRANSPORT";
  const options = {
    body: payload.body || "",
    icon: payload.icon || "/icon-192.png",
    badge: payload.badge || "/icon-72.png",
    tag: payload.tag || undefined,
    renotify: false,
    requireInteraction: false,
    data: {
      url: payload.url || "/notifications",
      notifId: payload.notifId || null,
    },
    vibrate: [80, 40, 80],
  };

  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  const targetUrl =
    (event.notification.data && event.notification.data.url) || "/";

  event.waitUntil(
    self.clients
      .matchAll({ type: "window", includeUncontrolled: true })
      .then((clients) => {
        for (const client of clients) {
          try {
            const url = new URL(client.url);
            if (
              url.origin === self.location.origin &&
              "focus" in client &&
              "navigate" in client
            ) {
              client.navigate(targetUrl);
              return client.focus();
            }
          } catch (_err) {
            // ignore
          }
        }
        if (self.clients.openWindow) {
          return self.clients.openWindow(targetUrl);
        }
      })
  );
});

// Skip waiting on demande (utilisé lors des mises à jour SW)
self.addEventListener("message", (event) => {
  if (event.data && event.data.type === "SKIP_WAITING") {
    self.skipWaiting();
  }
});
