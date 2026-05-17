// ============================================================
// Service Worker — MA FORMATION TRANSPORT
// ============================================================
// Trois responsabilités :
//   1. Web Push notifications (existant) : push, notificationclick
//   2. PWA offline-first léger (existant) :
//      - Précache la page /offline + les icônes à l'install
//      - Network first sur les navigations, fallback cache, puis /offline
//      - Ne touche PAS aux API, auth, _next/data, ingest PostHog
//   3. Cache renforcé du contenu pédagogique (Sprint 2 PWA 2026-05-18) :
//      - Stratégie stale-while-revalidate sur /modules/* et /lecons/*
//      - Cache séparé (mft-vX-content) avec pruning FIFO à 50 entrées
//      - Permet la consultation hors-ligne des leçons déjà visitées
// ============================================================

const CACHE_VERSION = "mft-v2";
const STATIC_CACHE = `${CACHE_VERSION}-static`;
const CONTENT_CACHE = `${CACHE_VERSION}-content`;
const OFFLINE_URL = "/offline";

// Limite LRU-ish (FIFO en réalité) du cache contenu : ~50 leçons
const CONTENT_MAX_ENTRIES = 50;

// Routes pédagogiques mises en cache de manière agressive
const CONTENT_PATHS = /^\/(modules|lecons|exercices)(\/|$)/;

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

// ─── Helpers cache ────────────────────────────────────────────
async function trimCache(cacheName, maxEntries) {
  const cache = await caches.open(cacheName);
  const keys = await cache.keys();
  if (keys.length <= maxEntries) return;
  // FIFO : on supprime les plus anciennes entrées (en tête de keys)
  const toDelete = keys.length - maxEntries;
  for (let i = 0; i < toDelete; i++) {
    await cache.delete(keys[i]);
  }
}

async function staleWhileRevalidate(request) {
  const cache = await caches.open(CONTENT_CACHE);
  const cached = await cache.match(request);

  const networkPromise = fetch(request)
    .then(async (response) => {
      if (
        response &&
        response.status === 200 &&
        (response.type === "basic" || response.type === "opaque")
      ) {
        await cache.put(request, response.clone());
        trimCache(CONTENT_CACHE, CONTENT_MAX_ENTRIES);
      }
      return response;
    })
    .catch(async () => {
      if (cached) return cached;
      const offline = await caches.match(OFFLINE_URL);
      if (offline) return offline;
      return new Response("Offline", { status: 408 });
    });

  // Si on a une version cachée, on la sert tout de suite, et on
  // revalide en arrière-plan. Sinon, on attend le réseau.
  return cached || networkPromise;
}

// ─── FETCH ────────────────────────────────────────────────────
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

  // Contenu pédagogique : stale-while-revalidate sur cache dédié.
  // On garde aussi les sous-routes (lecons/[id]) et les assets associés
  // (_next/static seront cachés par le réseau seul, c'est OK car
  // leur URL contient un hash → immutable).
  if (
    request.mode === "navigate" &&
    CONTENT_PATHS.test(url.pathname)
  ) {
    event.respondWith(staleWhileRevalidate(request));
    return;
  }

  // Comportement par défaut (existant) : network-first + cache fallback
  event.respondWith(
    fetch(request)
      .then((response) => {
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

// ─── MESSAGES depuis l'app ─────────────────────────────────────
// SKIP_WAITING : utilisé lors des mises à jour SW
// PRECACHE_LESSONS : la page module peut envoyer la liste des URLs
//   leçons pour les pré-cacher en arrière-plan (best-effort).
self.addEventListener("message", (event) => {
  const data = event.data || {};
  if (data.type === "SKIP_WAITING") {
    self.skipWaiting();
    return;
  }
  if (data.type === "PRECACHE_LESSONS" && Array.isArray(data.urls)) {
    event.waitUntil(
      (async () => {
        const cache = await caches.open(CONTENT_CACHE);
        await Promise.allSettled(
          data.urls
            .filter((u) => typeof u === "string")
            .slice(0, CONTENT_MAX_ENTRIES)
            .map(async (u) => {
              try {
                const req = new Request(u, { credentials: "same-origin" });
                const res = await fetch(req);
                if (res && res.status === 200) {
                  await cache.put(req, res);
                }
              } catch {
                // best-effort
              }
            })
        );
        await trimCache(CONTENT_CACHE, CONTENT_MAX_ENTRIES);
      })()
    );
  }
});
