// =====================================================================
// Sentry — Configuration runtime Edge (middleware, edge functions)
//
// Léger : pas de replay, pas de profiling — l'edge a un budget CPU/mémoire
// très restreint.
// =====================================================================

import * as Sentry from "@sentry/nextjs";

const DSN = process.env.SENTRY_DSN || process.env.NEXT_PUBLIC_SENTRY_DSN;
const ENV = process.env.SENTRY_ENVIRONMENT || "development";

Sentry.init({
  dsn: DSN,
  environment: ENV,
  enabled: !!DSN && ENV !== "development",

  tracesSampleRate: ENV === "production" ? 0.05 : 1.0,

  ignoreErrors: ["NEXT_NOT_FOUND", "NEXT_REDIRECT"],
});
