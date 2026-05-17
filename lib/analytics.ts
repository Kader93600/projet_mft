// =====================================================================
// Wrapper analytics — partie CLIENT uniquement.
//
// Pour le tracking côté serveur (server actions, webhooks, cron jobs),
// utilisez lib/analytics-server.ts qui charge posthog-node.
//
// La séparation client / server est CRITIQUE : posthog-node utilise des
// APIs Node (node:readline) qui ne peuvent pas être bundle côté navigateur.
// Si vous importez quoi que ce soit de posthog-node depuis un fichier
// référencé par un component "use client", le build casse.
//
// Conformité RGPD :
//   • Région EU (Francfort) — pas de transfert hors UE
//   • IP anonymisée automatiquement (option PostHog)
//   • Pas de session recording sans consentement explicite
//   • Opt-out global via flag posthog.opt_out_capturing()
//
// Si NEXT_PUBLIC_POSTHOG_KEY absent → no-op (pas d'erreur), utile en dev.
// =====================================================================

import type { PostHog } from "posthog-js";

const KEY = process.env.NEXT_PUBLIC_POSTHOG_KEY;
const HOST =
  process.env.NEXT_PUBLIC_POSTHOG_HOST || "https://eu.i.posthog.com";

const HAS_POSTHOG = !!KEY;

// ---------------------------------------------------------------------
// Liste typée des events — sert de catalogue référence.
// Toute nouvelle entrée DOIT être ajoutée ici pour passer le typecheck.
// ---------------------------------------------------------------------
export type EventName =
  // Onboarding & auth
  | "signup_completed"
  | "login_completed"
  // Pédagogie
  | "lesson_viewed"
  | "lesson_completed"
  | "module_completed"
  | "quiz_started"
  | "quiz_finished"
  | "quiz_finished_offline"
  // Examens
  | "exam_finished"
  // Business
  | "enrollment_created"
  | "payment_success"
  | "payment_failed"
  // Sessions live (Premium)
  | "session_signed";

export interface EventProps {
  // Champs métier les plus fréquents — autres props libres en plus.
  formation_slug?: string;
  module_id?: string;
  module_slug?: string;
  lesson_id?: string;
  quiz_id?: string;
  attempt_id?: string;
  session_id?: string;
  // Scores
  score?: number;
  percentage?: number;
  passed?: boolean;
  qcm_score?: number;
  qr_score?: number;
  // Durée
  duration_s?: number;
  // Pack
  pack?: "initial" | "medium" | "premium";
  // Paiement
  amount_cents?: number;
  currency?: string;
  // Tout reste (typé large, on évite `any`)
  [key: string]: string | number | boolean | null | undefined;
}

// ---------------------------------------------------------------------
// Client (navigateur)
// ---------------------------------------------------------------------

let _client: PostHog | null = null;

/**
 * Récupère l'instance posthog côté client. Renvoie null si PostHog n'est
 * pas chargé (SSR, ou opt-out, ou clé manquante).
 */
function getClient(): PostHog | null {
  if (typeof window === "undefined") return null;
  if (!HAS_POSTHOG) return null;
  if (_client) return _client;
  // posthog-js s'auto-initialise via le PostHogProvider — on récupère juste
  // la référence globale.
  // @ts-expect-error global injecté par posthog-js
  _client = window.posthog ?? null;
  return _client;
}

/**
 * Track un event côté client. Safe en SSR (no-op) ou sans PostHog (no-op).
 */
export function trackEvent(name: EventName, props: EventProps = {}) {
  const ph = getClient();
  if (!ph) return;
  try {
    ph.capture(name, props);
  } catch (e) {
    // Ne casse jamais l'UX si PostHog échoue
    // eslint-disable-next-line no-console
    console.warn("[posthog] capture failed", name, e);
  }
}

/**
 * Identifie l'utilisateur courant. À appeler après login + à chaque RSC
 * authentifié pour rester à jour si les attributs changent.
 */
export function identifyUser(
  userId: string,
  props: {
    email?: string;
    role?: string;
    full_name?: string;
    created_at?: string;
    active_formation_slug?: string;
  } = {}
) {
  const ph = getClient();
  if (!ph) return;
  try {
    ph.identify(userId, props);
  } catch (e) {
    // eslint-disable-next-line no-console
    console.warn("[posthog] identify failed", e);
  }
}

/**
 * Reset l'identité au logout (sinon PostHog continue d'attribuer à l'ancien
 * user sur le même browser).
 */
export function resetIdentity() {
  const ph = getClient();
  if (!ph) return;
  try {
    ph.reset();
  } catch {}
}

/**
 * Opt-out global pour cet utilisateur — désactive tout capture.
 * Persistant dans le localStorage côté client.
 */
export function optOutTracking() {
  const ph = getClient();
  if (!ph) return;
  try {
    ph.opt_out_capturing();
  } catch {}
}

/**
 * Réactive le tracking après opt-out.
 */
export function optInTracking() {
  const ph = getClient();
  if (!ph) return;
  try {
    ph.opt_in_capturing();
  } catch {}
}

/**
 * État du consentement (true = tracking actif, false = opt-out).
 */
export function isTrackingEnabled(): boolean {
  const ph = getClient();
  if (!ph) return false;
  try {
    return !ph.has_opted_out_capturing();
  } catch {
    return false;
  }
}

// ---------------------------------------------------------------------
// 👉 Pour le tracking SERVEUR : voir lib/analytics-server.ts
// (séparation nécessaire car posthog-node ne peut pas être bundle client)
// ---------------------------------------------------------------------
