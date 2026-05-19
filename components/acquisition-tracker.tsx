"use client";

// =====================================================================
// AcquisitionTracker — composant invisible monté sur les layouts publics.
//
// Au premier mount d'une page publique :
//   • Lit window.location pour les utm_* et autres params marketing
//   • Lit document.referrer
//   • POST /api/acquisition/track (fire-and-forget)
//
// Le serveur pose un cookie httpOnly `mft_vid` (90j) pour identifier
// le visiteur sur les visites ultérieures.
//
// Anti-spam : 1 seul ping par page navigateur (sessionStorage), pour
// éviter de pinger 5x lors d'un changement de query string.
// =====================================================================

import { useEffect } from "react";
import { usePathname } from "next/navigation";
import { buildTrackingPayloadFromBrowser } from "@/lib/acquisition-client";

const SESSION_KEY_PREFIX = "mft.acquisition.tracked.";

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

    // Fire-and-forget — pas de await, pas de retry. C'est de la télémétrie.
    fetch("/api/acquisition/track", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
      credentials: "include",
      keepalive: true,
    }).catch(() => {
      // silencieux : le tracking ne doit JAMAIS casser l'UX
    });
  }, [pathname, kind]);

  return null;
}
