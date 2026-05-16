// =====================================================================
// Next.js Instrumentation — chargé une fois au démarrage du serveur.
// C'est ici qu'on bootstrap Sentry pour les runtimes server et edge.
//
// Le runtime client (navigateur) est géré par sentry.client.config.ts
// qui est chargé automatiquement par Next via le wrapper withSentryConfig.
// =====================================================================

export async function register() {
  if (process.env.NEXT_RUNTIME === "nodejs") {
    await import("./sentry.server.config");
  }
  if (process.env.NEXT_RUNTIME === "edge") {
    await import("./sentry.edge.config");
  }
}

// onRequestError : capture les erreurs des Server Components et Server Actions
// qui échappent au try/catch classique (rendering errors, etc.).
export async function onRequestError(
  err: unknown,
  request: {
    path: string;
    method: string;
    headers: Record<string, string>;
  },
  context: {
    routerKind: "Pages Router" | "App Router";
    routePath: string;
    routeType: "render" | "route" | "action" | "middleware";
  }
) {
  const Sentry = await import("@sentry/nextjs");
  Sentry.captureRequestError(err, request, context);
}
