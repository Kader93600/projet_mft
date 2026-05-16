// =====================================================================
// Analytics — partie SERVEUR uniquement.
//
// ⚠️ Ne jamais importer ce fichier depuis un composant marqué "use client",
// posthog-node utilise des APIs Node (node:readline) qui ne peuvent pas
// être bundle côté navigateur.
//
// Si vous voulez tracker un event depuis le client, utilisez lib/analytics.ts
// qui expose trackEvent / identifyUser (via le SDK posthog-js).
//
// Le marker "server-only" en haut produit une erreur de build claire si
// jamais un composant client tente d'importer ce fichier — préférable
// au build cassé silencieux.
// =====================================================================

import "server-only";

import type { EventName, EventProps } from "./analytics";

const KEY = process.env.NEXT_PUBLIC_POSTHOG_KEY;
const HOST =
  process.env.NEXT_PUBLIC_POSTHOG_HOST || "https://eu.i.posthog.com";

const HAS_POSTHOG = !!KEY;

let _serverClient: import("posthog-node").PostHog | null = null;

/**
 * Récupère (lazy) une instance posthog-node pour capture serveur.
 * Important : appeler shutdownServerAnalytics() avant la fin du process
 * pour flusher les events (notamment dans les cron jobs).
 */
async function getServerClient() {
  if (!HAS_POSTHOG) return null;
  if (_serverClient) return _serverClient;
  const { PostHog } = await import("posthog-node");
  _serverClient = new PostHog(KEY!, {
    host: HOST,
    flushAt: 1, // envoie immédiat (on est en serverless, pas de batch)
    flushInterval: 0,
    // Désactive l'error tracking interne de posthog-node qui charge
    // node:readline (incompatible avec certains environnements Edge).
    disableGeoip: false,
  });
  return _serverClient;
}

/**
 * Track un event côté serveur. À utiliser dans les server actions, les
 * routes API, le webhook Stripe, les cron jobs.
 *
 * Exemple :
 *   await trackServerEvent({
 *     userId: enrollment.user_id,
 *     event: "payment_success",
 *     props: { formation_slug: "gotrm", pack: "premium", amount_cents: 99900 }
 *   });
 */
export async function trackServerEvent(args: {
  userId: string;
  event: EventName;
  props?: EventProps;
}) {
  const ph = await getServerClient();
  if (!ph) return;
  try {
    ph.capture({
      distinctId: args.userId,
      event: args.event,
      properties: args.props ?? {},
    });
    // En serverless on flushe immédiatement pour ne pas perdre l'event
    // si la lambda meurt avant le batch.
    await ph.flush();
  } catch (e) {
    // eslint-disable-next-line no-console
    console.warn("[posthog-server] capture failed", args.event, e);
  }
}

/**
 * À appeler en fin de cron job pour s'assurer que tout est envoyé.
 */
export async function shutdownServerAnalytics() {
  if (!_serverClient) return;
  try {
    await _serverClient.shutdown();
    _serverClient = null;
  } catch {}
}
