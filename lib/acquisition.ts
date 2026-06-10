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

// =====================================================================
// Snapshot d'attribution figé sur un lead.
//
// À la soumission d'un formulaire (contact / pré-inscription), on fige
// l'attribution marketing du visiteur sur le lead, pour pouvoir plus tard
// (Phase 3 — remontée offline) rapprocher l'inscription du BON clic.
//
//   • utm_*     : FIRST-touch (premier événement du visiteur), cohérent
//                 avec la vue acquisition_attribution → source affichable
//                 dans le CRM.
//   • click-IDs : LAST-touch (dernier clic non vide), c.-à-d. celui qui a
//                 le plus de chances d'être encore dans la fenêtre
//                 d'attribution de la régie au moment de la conversion.
// =====================================================================

export interface AcquisitionSnapshot {
  visitor_id: string;
  utm_source: string | null;
  utm_medium: string | null;
  utm_campaign: string | null;
  gclid: string | null;
  gbraid: string | null;
  wbraid: string | null;
  fbclid: string | null;
  ttclid: string | null;
  msclkid: string | null;
}

// Sous-ensemble lu sur acquisition_events. Type LOCAL (volontairement non
// dérivé de database.types.ts) : les colonnes click-IDs n'existent qu'après
// la migration 2026_06_02_acquisition_click_ids.sql, et database.types.ts est
// régénéré par introspection de la base déployée — en dépendre casserait le
// typecheck tant que la migration n'est pas appliquée.
interface AcquisitionEventCols {
  utm_source: string | null;
  utm_medium: string | null;
  utm_campaign: string | null;
  gclid: string | null;
  gbraid: string | null;
  wbraid: string | null;
  fbclid: string | null;
  ttclid: string | null;
  msclkid: string | null;
  occurred_at: string;
}

/**
 * Construit le snapshot d'attribution d'un visiteur à partir de ses
 * événements `acquisition_events`. Lecture via service_role (la table est
 * en RLS admin-only). Best-effort : retourne null en cas de souci, ne
 * casse jamais le flux appelant.
 */
export async function getAcquisitionSnapshot(
  visitorId: string | null
): Promise<AcquisitionSnapshot | null> {
  if (!visitorId) return null;

  const supaUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const supaKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!supaUrl || !supaKey) return null;

  try {
    const svc = createClient(supaUrl, supaKey, {
      auth: { persistSession: false },
    });
    const { data } = await svc
      .from("acquisition_events")
      .select(
        "utm_source, utm_medium, utm_campaign, gclid, gbraid, wbraid, fbclid, ttclid, msclkid, occurred_at"
      )
      .eq("visitor_id", visitorId)
      .order("occurred_at", { ascending: true });

    const rows = (data ?? []) as AcquisitionEventCols[];
    const first = rows[0] ?? null;

    // Dernier clic non vide pour un click-ID donné (parcours inversé).
    const lastNonNull = (key: keyof AcquisitionEventCols): string | null => {
      for (let i = rows.length - 1; i >= 0; i--) {
        const v = rows[i][key];
        if (v) return v as string;
      }
      return null;
    };

    return {
      visitor_id: visitorId,
      utm_source: first?.utm_source ?? null,
      utm_medium: first?.utm_medium ?? null,
      utm_campaign: first?.utm_campaign ?? null,
      gclid: lastNonNull("gclid"),
      gbraid: lastNonNull("gbraid"),
      wbraid: lastNonNull("wbraid"),
      fbclid: lastNonNull("fbclid"),
      ttclid: lastNonNull("ttclid"),
      msclkid: lastNonNull("msclkid"),
    };
  } catch {
    // Best-effort : pas d'attribution plutôt qu'une erreur de soumission.
    return null;
  }
}
