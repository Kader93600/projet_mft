import { createClient } from "@/lib/supabase/server";
import { z } from "zod";
import { formatZodError } from "./validations";

/**
 * Vérifie qu'un admin est connecté. Renvoie le client Supabase + l'admin.
 * Utilisé dans toutes les server actions sensibles.
 */
export async function requireAdmin() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");
  const { data: profile } = await supabase
    .from("profiles")
    .select("id, role, email, disabled")
    .eq("id", user.id)
    .single();
  if (!profile) throw new Error("Profil introuvable");
  if (profile.disabled) throw new Error("Compte désactivé");
  if (profile.role !== "admin") throw new Error("Accès refusé");
  return { supabase, admin: profile };
}

/**
 * Valide un payload avec un schéma Zod et retourne les données typées.
 * Lève une erreur formatée en cas d'échec.
 */
export function validate<T extends z.ZodTypeAny>(
  schema: T,
  data: unknown
): z.infer<T> {
  const res = schema.safeParse(data);
  if (!res.success) throw new Error(formatZodError(res.error));
  return res.data;
}

/**
 * Enregistre une action admin dans audit_log.
 * Ne lève jamais d'erreur (best-effort).
 */
export async function auditLog(
  action: string,
  targetType: string,
  targetId: string,
  metadata?: Record<string, any>
) {
  try {
    const supabase = createClient();
    await supabase.rpc("log_admin_action", {
      p_action: action,
      p_target_type: targetType,
      p_target_id: targetId,
      p_metadata: metadata ?? null,
    });
  } catch (e) {
    // best-effort : on log mais on ne casse pas l'action
    console.error("[audit] failed", e);
  }
}

/**
 * Rate limit naïf en mémoire (par instance Next).
 * Suffisant pour un usage admin. Pour la prod, utiliser Upstash/Redis.
 */
const hits = new Map<string, { count: number; resetAt: number }>();

export function rateLimit(
  key: string,
  max: number,
  windowMs: number
): { allowed: boolean; retryInMs: number } {
  const now = Date.now();
  const entry = hits.get(key);
  if (!entry || entry.resetAt < now) {
    hits.set(key, { count: 1, resetAt: now + windowMs });
    return { allowed: true, retryInMs: 0 };
  }
  if (entry.count >= max) {
    return { allowed: false, retryInMs: entry.resetAt - now };
  }
  entry.count++;
  return { allowed: true, retryInMs: 0 };
}
