// =====================================================================
// Sentry — Configuration côté client (navigateur)
//
// Captures les erreurs JS frontend (React render, event handlers, etc.).
// Tags : route active, formation active, user.
// =====================================================================

import * as Sentry from "@sentry/nextjs";

const DSN = process.env.NEXT_PUBLIC_SENTRY_DSN;
const ENV = process.env.NEXT_PUBLIC_SENTRY_ENVIRONMENT || "development";

Sentry.init({
  dsn: DSN,
  environment: ENV,

  // Désactiver complètement en dev sauf si DSN explicite — évite de polluer
  // les quotas Sentry pendant le développement local.
  enabled: !!DSN && ENV !== "development",

  // Taux d'échantillonnage des transactions de performance.
  // 10 % en prod = on capture 1 transaction sur 10 (suffisant pour détecter
  // les lenteurs sans cramer le quota Sentry).
  tracesSampleRate: ENV === "production" ? 0.1 : 1.0,

  // Replays vidéo des sessions où une erreur survient.
  // 0 % par défaut (les replays consomment 10× plus de quota que les events)
  // → on n'active que sur les sessions avec erreur.
  replaysSessionSampleRate: 0,
  replaysOnErrorSampleRate: 0.5,

  // Perf : PAS de replayIntegration statique ici — elle embarquait ~37 KB gz
  // (rrweb) dans le First Load JS de TOUTES les pages, vitrine comprise.
  // Elle est chargée en différé ci-dessous (lazyLoadIntegration télécharge
  // le module depuis le CDN Sentry uniquement quand le SDK est actif).
  integrations: [],

  // Ignore certaines erreurs non actionnables.
  ignoreErrors: [
    // Erreurs de navigateurs anciens / extensions
    "ResizeObserver loop limit exceeded",
    "ResizeObserver loop completed with undelivered notifications",
    "Non-Error promise rejection captured",
    // Erreurs de réseau "normales" (utilisateur a fermé l'onglet)
    "Network request failed",
    "Failed to fetch",
    "Load failed",
    "AbortError",
    // Erreurs liées à des extensions Chrome / scripts injectés
    /Extension context invalidated/,
    /chrome-extension/,
    // Erreurs Next.js attendues
    "NEXT_NOT_FOUND",
    "NEXT_REDIRECT",
  ],

  // Filtre additionnel : on ne capture pas si l'erreur vient d'un script
  // externe (publicité, tracker) chargé hors de notre domaine.
  beforeSend(event, hint) {
    // En prod uniquement — en preview/dev on garde tout pour debug.
    if (ENV === "production") {
      const frames = event.exception?.values?.[0]?.stacktrace?.frames ?? [];
      const ourFrame = frames.find((f) =>
        f.filename?.includes("maformationtransport.fr")
      );
      if (!ourFrame && frames.length > 0) {
        // Aucune frame ne vient de notre code → probablement une extension.
        return null;
      }
    }
    return event;
  },
});

// Chargement DIFFÉRÉ du Session Replay : le bundle rrweb est téléchargé
// depuis le CDN Sentry après l'init, hors du First Load JS des pages.
if (DSN && ENV !== "development") {
  Sentry.lazyLoadIntegration("replayIntegration")
    .then((replayIntegration) => {
      Sentry.addIntegration(
        replayIntegration({
          // Masque les inputs sensibles (mot de passe, CB) et les emails.
          maskAllInputs: true,
          maskAllText: false, // on garde le texte visible pour le contexte
          blockAllMedia: false,
        })
      );
    })
    .catch(() => {
      // Réseau indisponible / bloqueur : on continue sans replay.
    });
}
