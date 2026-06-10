// =====================================================================
// Helpers acquisition (UTM + click-IDs) — CLIENT ONLY.
//
// Aucune dépendance Next.js (pas d'import next/headers) pour pouvoir
// être bundlé sans souci dans un composant 'use client'.
//
// Le cookie mft_vid est httpOnly côté serveur, donc inaccessible ici.
// Ce module construit juste le payload de tracking à POSTer.
// =====================================================================

export interface TrackingPayload {
  kind: string;
  landing_page: string;
  referrer: string | null;
  utm_source: string | null;
  utm_medium: string | null;
  utm_campaign: string | null;
  utm_content: string | null;
  utm_term: string | null;
  // Click-IDs des régies publicitaires (acquisition payante). Présents
  // dans l'URL d'atterrissage quand le clic provient d'une annonce.
  gclid: string | null; // Google Ads
  gbraid: string | null; // Google (app→web, iOS)
  wbraid: string | null; // Google (web, iOS)
  fbclid: string | null; // Meta (Facebook/Instagram)
  ttclid: string | null; // TikTok
  msclkid: string | null; // Microsoft Advertising (Bing)
}

/**
 * Construit le payload de tracking depuis window.location et
 * document.referrer. Retourne null en SSR (pas de window).
 */
export function buildTrackingPayloadFromBrowser(
  kind: string = "landing"
): TrackingPayload | null {
  if (typeof window === "undefined") return null;
  const url = new URL(window.location.href);
  const sp = url.searchParams;

  const utm_source = sp.get("utm_source") ?? sp.get("ref") ?? null;
  const utm_medium = sp.get("utm_medium") ?? null;
  const utm_campaign = sp.get("utm_campaign") ?? null;
  const utm_content = sp.get("utm_content") ?? null;
  const utm_term = sp.get("utm_term") ?? null;

  // Click-IDs : simple lecture de query param (null si absent ou vide).
  const clickId = (k: string) => sp.get(k) || null;

  // Referrer : uniquement si différent du même domaine (pour mesurer
  // les vrais entrants externes — pas les navigations internes).
  let referrer: string | null = null;
  try {
    if (document.referrer) {
      const r = new URL(document.referrer);
      if (r.origin !== url.origin) referrer = document.referrer;
    }
  } catch {
    // ignore
  }

  return {
    kind,
    landing_page: url.pathname + (url.search || ""),
    referrer,
    utm_source,
    utm_medium,
    utm_campaign,
    utm_content,
    utm_term,
    gclid: clickId("gclid"),
    gbraid: clickId("gbraid"),
    wbraid: clickId("wbraid"),
    fbclid: clickId("fbclid"),
    ttclid: clickId("ttclid"),
    msclkid: clickId("msclkid"),
  };
}
