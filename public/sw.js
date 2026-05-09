// ============================================================
// Service Worker — MA FORMATION TRANSPORT
// ============================================================
// Gère les notifications Web Push :
//   - 'push' : reçoit le payload du serveur, affiche une notification
//              système (titre, corps, icône, action click)
//   - 'notificationclick' : ouvre/focus l'onglet sur l'URL associée
//
// Le SW n'est volontairement PAS un cache offline — il sert uniquement
// au push. On désactive donc tout install/activate spécifique pour
// rester aussi léger que possible.
// ============================================================

self.addEventListener("install", (event) => {
  // Active immédiatement le nouveau SW sans attendre la fermeture des onglets.
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  // Prend le contrôle des clients ouverts immédiatement.
  event.waitUntil(self.clients.claim());
});

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
    // Vibrations légères : motif court (mobile uniquement, ignoré desktop)
    vibrate: [80, 40, 80],
  };

  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  const targetUrl = (event.notification.data && event.notification.data.url) || "/";

  event.waitUntil(
    self.clients
      .matchAll({ type: "window", includeUncontrolled: true })
      .then((clients) => {
        // Si un onglet de l'app est déjà ouvert, on le focus + navigue
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
            // Ignore parsing errors
          }
        }
        // Sinon, ouvrir un nouvel onglet
        if (self.clients.openWindow) {
          return self.clients.openWindow(targetUrl);
        }
      })
  );
});
