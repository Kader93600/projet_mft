"use client";

// =====================================================================
// AcquisitionTracker — composant invisible monté sur les layouts publics.
//
// RGPD (CNIL) : le tracking d'acquisition (click-IDs Google/Meta/TikTok,
// UTM, cookie identifiant mft_vid 90 j à finalité publicitaire) est un
// traceur NON essentiel → il n'est déclenché QUE si le visiteur a donné
// son consentement « marketing » via la bannière cookies.
//
// Sans consentement : le payload est bufferisé en sessionStorage (les
// UTM du clic d'origine disparaissent de l'URL à la navigation). Si le
// visiteur accepte ensuite (événement CONSENT_CHANGED_EVENT), le payload
// en attente est envoyé — l'attribution de la visite est préservée sans
// jamais traquer avant consentement.
//
// Anti-spam : 1 seul ping par page navigateur (sessionStorage).
// =====================================================================

import { useEffect } from "react";
import { usePathname } from "next/navigation";
import { buildTrackingPayloadFromBrowser } from "@/lib/acquisition-client";
import { hasMarketingConsent } from "@/lib/marketing/consent";
import { CONSENT_CHANGED_EVENT } from "@/components/cookie-banner";

const SESSION_KEY_PREFIX = "mft.acquisition.tracked.";
const PENDING_KEY = "mft.acquisition.pending";

// Routes EXCLUES du tracking (espaces auth — décision client "pages publiques
// uniquement"). On filtre côté client pour éviter d'envoyer des pings inutiles.
const AUTH_ROUTE_PREFIXES = [
  "/dashboard",
  "/admin",
  "/formateur",
  "/financeur",
  "/organisation",
  "/modules",
  "/exercices",
  "/examens-blancs",
  "/quiz",
  "/stats",
  "/reussites",
  "/classement",
  "/certificats",
  "/messages",
  "/accompagnement",
  "/sessions",
  "/emargement",
  "/satisfaction",
  "/notifications",
  "/parametres",
  "/parrainage",
  "/tuteur",
  "/mes-documents",
  "/mes-donnees",
  "/accessibilite",
  "/onboarding",
  "/login",
  "/auth",
  "/glossaire",
  "/evaluation",
];

function isPublicRoute(pathname: string): boolean {
  return !AUTH_ROUTE_PREFIXES.some(
    (p) => pathname === p || pathname.startsWith(p + "/")
  );
}

/** Envoi effectif (fire-and-forget) — uniquement appelé après consentement. */
function send(payload: unknown) {
  fetch("/api/acquisition/track", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
    credentials: "include",
    keepalive: true,
  }).catch(() => {
    // silencieux : le tracking ne doit JAMAIS casser l'UX
  });
}

/** Envoie le payload bufferisé avant consentement, s'il existe. */
function flushPending() {
  try {
    const raw = sessionStorage.getItem(PENDING_KEY);
    if (!raw) return;
    sessionStorage.removeItem(PENDING_KEY);
    send(JSON.parse(raw));
  } catch {}
}

export function AcquisitionTracker({ kind = "landing" }: { kind?: string }) {
  const pathname = usePathname();

  useEffect(() => {
    if (typeof window === "undefined") return;
    if (!isPublicRoute(pathname)) return;

    // 1 ping par chemin + UTM combo (évite spam si UTM change)
    const sp = new URLSearchParams(window.location.search);
    const utmKey = ["utm_source", "utm_medium", "utm_campaign"]
      .map((k) => sp.get(k) ?? "")
      .join("|");
    const sessionKey = `${SESSION_KEY_PREFIX}${pathname}#${utmKey}`;
    if (sessionStorage.getItem(sessionKey)) return;
    sessionStorage.setItem(sessionKey, "1");

    const payload = buildTrackingPayloadFromBrowser(kind);
    if (!payload) return;

    if (hasMarketingConsent()) {
      flushPending();
      send(payload);
    } else {
      // Pas de consentement (ou pas encore de choix) : AUCUN appel réseau,
      // aucun cookie. On garde le payload de la 1ʳᵉ page (celle qui porte
      // les UTM / click-IDs) pour l'envoyer si le visiteur accepte.
      try {
        if (!sessionStorage.getItem(PENDING_KEY)) {
          sessionStorage.setItem(PENDING_KEY, JSON.stringify(payload));
        }
      } catch {}
    }
  }, [pathname, kind]);

  // Activation à chaud : le visiteur accepte « marketing » dans la
  // bannière → on envoie le payload en attente immédiatement.
  useEffect(() => {
    const onConsent = (e: Event) => {
      const detail = (e as CustomEvent).detail as
        | { marketing?: boolean }
        | undefined;
      if (detail?.marketing === true) flushPending();
    };
    window.addEventListener(CONSENT_CHANGED_EVENT, onConsent);
    return () => window.removeEventListener(CONSENT_CHANGED_EVENT, onConsent);
  }, []);

  return null;
}
