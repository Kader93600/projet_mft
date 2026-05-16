// =====================================================================
// Sentry — Configuration côté serveur (API routes, Server Actions, RSC)
//
// Captures les erreurs Node : DB, RLS, validation Zod, etc.
// Tags : route, user_id (via cookie), env.
// =====================================================================

import * as Sentry from "@sentry/nextjs";

const DSN = process.env.SENTRY_DSN || process.env.NEXT_PUBLIC_SENTRY_DSN;
const ENV = process.env.SENTRY_ENVIRONMENT || "development";

Sentry.init({
  dsn: DSN,
  environment: ENV,
  enabled: !!DSN && ENV !== "development",

  // Plus généreux côté serveur : on échantillonne moins agressivement
  // car les erreurs serveur sont plus rares et plus critiques.
  tracesSampleRate: ENV === "production" ? 0.2 : 1.0,

  // Limite la taille des request body capturés (RGPD : pas de leak de PII).
  maxValueLength: 1000,

  ignoreErrors: [
    // Erreurs Next.js attendues (redirect, notFound)
    "NEXT_NOT_FOUND",
    "NEXT_REDIRECT",
    // Erreurs auth attendues
    "Unauthorized",
    "Non authentifié",
    "Accès refusé",
    // Erreurs RLS attendues (l'user n'a pas les droits)
    /JWT expired/,
    /JWT.*invalid/,
  ],

  beforeSend(event) {
    // RGPD : on retire les données sensibles éventuelles avant envoi.
    if (event.request) {
      // Supprime les headers sensibles
      if (event.request.headers) {
        delete event.request.headers["authorization"];
        delete event.request.headers["cookie"];
        delete event.request.headers["x-supabase-auth"];
      }
      // Supprime le body s'il contient un champ "password" ou "token"
      if (event.request.data && typeof event.request.data === "object") {
        const data = event.request.data as Record<string, unknown>;
        for (const key of Object.keys(data)) {
          if (/password|token|secret|api[_-]?key/i.test(key)) {
            data[key] = "[REDACTED]";
          }
        }
      }
    }
    return event;
  },
});
