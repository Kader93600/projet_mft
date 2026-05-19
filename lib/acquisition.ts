// =====================================================================
// Helpers acquisition (UTM tracking) — côté client + côté serveur.
//
// Le visitor_id vit dans un cookie httpOnly posé par /api/acquisition/track.
// Côté client on ne sait pas lire ce cookie (httpOnly), c'est volontaire :
// l'identité visiteur n'est jamais accessible au JS exécuté dans le navigateur,
// elle ne sert qu'à l'attribution serveur.
//
// Côté serveur, on peut lire le cookie pour faire le link visitor_id → user_id
// au moment du signup (cf. helper linkVisitorToUser).
// =====================================================================

import { cookies } from "next/headers";
import { createClient } from "@supabase/supabase-js";

const COOKIE_NAME = "mft_vid";

/**
 * Lit le visitor_id du cookie HttpOnly. Disponible uniquement côté serveur.
 */
export function getVisitorIdFromCookies(): string | null {
  try {
    return cookies().get(COOKIE_NAME)?.value ?? null;
  } catch {
    // Le helper `cookies()` est sync mais throws s'il n'est pas appelé
    // dans un Server Component / Route Handler. Fallback prudent.
    return null;
  }
}

/**
 * Lie le visitor_id du cookie courant au user_id qui vient de s'inscrire.
 * À appeler dans le flux de signup / création de compte / contact form.
 *
 * Best-effort : si pas de cookie ou erreur, ne casse pas le flux principal.
 */
export async function linkVisitorToUser(userId: string): Promise<void> {
  const visitorId = getVisitorIdFromCookies();
  if (!visitorId || !userId) return;

  const supaUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const supaKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!supaUrl || !supaKey) return;

  try {
    const svc = createClient(supaUrl, supaKey, {
      auth: { persistSession: false },
    });
    await svc.rpc("link_visitor_to_user", {
      p_visitor_id: visitorId,
      p_user_id: userId,
    });
  } catch {
    // Best-effort
  }
}

/**
 * Construit le payload de tracking depuis une window publique.
 * À utiliser côté client uniquement (window.location et document.referrer).
 */
export function buildTrackingPayloadFromBrowser(kind: string = "landing") {
  if (typeof window === "undefined") return null;
  const url = new URL(window.location.href);
  const sp = url.searchParams;

  // Filtres : utm_* + autres params marketing courants
  const utm_source = sp.get("utm_source") ?? sp.get("ref") ?? null;
  const utm_medium = sp.get("utm_medium") ?? null;
  const utm_campaign = sp.get("utm_campaign") ?? null;
  const utm_content = sp.get("utm_content") ?? null;
  const utm_term = sp.get("utm_term") ?? null;

  // Le referrer (URL d'origine si différente du même domaine)
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
  };
}
