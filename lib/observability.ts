// =====================================================================
// Wrapper d'observabilité — interface stable au-dessus de Sentry.
//
// API : captureException, captureMessage, setSentryUser, addBreadcrumb.
// Compatible client et server (le SDK @sentry/nextjs s'adapte au runtime).
//
// Si SENTRY_DSN n'est pas défini → fallback console.log (pas de no-op silencieux,
// on veut voir les erreurs en dev local).
// =====================================================================

import * as Sentry from "@sentry/nextjs";

type Sev = "fatal" | "error" | "warning" | "info" | "debug";

interface CaptureOptions {
  level?: Sev;
  user?: { id?: string; email?: string; role?: string };
  tags?: Record<string, string | number | boolean>;
  extra?: Record<string, unknown>;
}

const DSN =
  process.env.NEXT_PUBLIC_SENTRY_DSN || process.env.SENTRY_DSN;

const HAS_SENTRY = !!DSN;

/**
 * Capture une exception. Acceptable depuis n'importe quel runtime
 * (client, server action, route handler, edge).
 */
export async function captureException(
  err: unknown,
  opts: CaptureOptions = {}
) {
  const e = err instanceof Error ? err : new Error(String(err));

  if (HAS_SENTRY) {
    Sentry.withScope((scope) => {
      if (opts.level) scope.setLevel(opts.level);
      if (opts.user) {
        scope.setUser({
          id: opts.user.id,
          email: opts.user.email,
          // role n'est pas un champ standard Sentry, on le passe en tag.
        });
        if (opts.user.role) scope.setTag("user_role", opts.user.role);
      }
      if (opts.tags) {
        for (const [k, v] of Object.entries(opts.tags)) {
          scope.setTag(k, String(v));
        }
      }
      if (opts.extra) {
        for (const [k, v] of Object.entries(opts.extra)) {
          scope.setExtra(k, v);
        }
      }
      Sentry.captureException(e);
    });
    return;
  }

  // Fallback dev / DSN absent
  // eslint-disable-next-line no-console
  console.error(`[${opts.level ?? "error"}]`, e, opts);
}

/**
 * Capture un message (sans stack trace). Utile pour les warnings métier
 * (paiement échoué, RLS bypass tenté, etc.).
 */
export async function captureMessage(
  message: string,
  opts: CaptureOptions = {}
) {
  if (HAS_SENTRY) {
    Sentry.withScope((scope) => {
      if (opts.level) scope.setLevel(opts.level);
      if (opts.user) {
        scope.setUser({
          id: opts.user.id,
          email: opts.user.email,
        });
        if (opts.user.role) scope.setTag("user_role", opts.user.role);
      }
      if (opts.tags) {
        for (const [k, v] of Object.entries(opts.tags)) {
          scope.setTag(k, String(v));
        }
      }
      if (opts.extra) {
        for (const [k, v] of Object.entries(opts.extra)) {
          scope.setExtra(k, v);
        }
      }
      Sentry.captureMessage(message);
    });
    return;
  }

  // eslint-disable-next-line no-console
  console.log(`[${opts.level ?? "info"}]`, message, opts);
}

/**
 * Définit l'utilisateur courant sur le scope Sentry (persiste pour les
 * captures suivantes). À appeler dans les server actions ou les RSC qui
 * connaissent le user authentifié.
 */
export function setSentryUser(user: {
  id: string;
  email?: string;
  role?: string;
} | null) {
  if (!HAS_SENTRY) return;
  if (user) {
    Sentry.setUser({ id: user.id, email: user.email });
    if (user.role) Sentry.setTag("user_role", user.role);
  } else {
    Sentry.setUser(null);
  }
}

/**
 * Ajoute un breadcrumb (point de contexte qui sera attaché à la prochaine
 * exception capturée). Utile pour tracer "ce qui s'est passé avant" sans
 * envoyer un event complet à chaque action.
 */
export function addBreadcrumb(crumb: {
  category: string;
  message: string;
  level?: Sev;
  data?: Record<string, unknown>;
}) {
  if (!HAS_SENTRY) return;
  Sentry.addBreadcrumb({
    category: crumb.category,
    message: crumb.message,
    level: crumb.level ?? "info",
    data: crumb.data,
  });
}

/**
 * Force le flush des events Sentry — à utiliser avant un process.exit ou
 * une fin de cron job pour s'assurer que tout est envoyé.
 */
export async function flushSentry(timeoutMs: number = 2000) {
  if (!HAS_SENTRY) return;
  await Sentry.flush(timeoutMs);
}
