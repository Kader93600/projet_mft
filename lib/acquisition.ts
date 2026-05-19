// =====================================================================
// Helpers acquisition (UTM tracking) — SERVER ONLY.
//
// ⚠️ Ce fichier importe `next/headers` (cookies()) qui est strictement
// server-side. Ne JAMAIS l'importer depuis un composant 'use client' —
// sinon Next refuse de builder.
//
// Pour les helpers côté client (browser), voir lib/acquisition-client.ts
// (sans dépendance Next.js).
//
// Le visitor_id vit dans un cookie httpOnly posé par /api/acquisition/track.
// =====================================================================

import "server-only";
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
