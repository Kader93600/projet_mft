import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { z } from "zod";
import { formatZodError } from "./validations";
import { isStaff, isSuperAdmin } from "./permissions";

/**
 * Vérifie qu'un membre du staff (admin OU super_admin) est connecté.
 * Renvoie :
 *   - `supabase` : client session (RLS appliqué, à utiliser pour les
 *     lectures où l'on veut respecter les permissions)
 *   - `admin` : profil du staff connecté
 *   - `service` : client service_role (bypass RLS, à utiliser pour les
 *     mutations sensibles où RLS bloque silencieusement les staff)
 * Utilisé dans toutes les server actions sensibles côté /admin.
 *
 * NB : le miroir SQL `public.is_admin()` autorise déjà admin + super_admin
 * (cf. supabase/permissions_v2_step2.sql). On aligne le check TypeScript.
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
  if (!isStaff(profile.role)) throw new Error("Accès refusé");

  // `service` : client service_role lazy (ne se construit qu'à la
  // première lecture). Évite de jeter en environnement de test où
  // SUPABASE_SERVICE_ROLE_KEY n'est pas configuré, tout en restant
  // ergonomique pour les server actions qui font juste { service }.
  let _service: ReturnType<typeof createAdminClient> | null = null;
  const result = {
    supabase,
    admin: profile,
    profile,
    get service() {
      if (_service === null) _service = createAdminClient();
      return _service;
    },
  };
  return result;
}

/**
 * Variante stricte : super_admin uniquement (régalien — gestion des rôles,
 * configuration globale, audit sensible).
 */
export async function requireSuperAdmin() {
  const { supabase, admin } = await requireAdmin();
  if (!isSuperAdmin(admin.role)) throw new Error("Accès refusé");
  return { supabase, admin };
}

/**
 * Garde pour les actions pédagogiques scopées par formation.
 *
 *  - admin / super_admin : accès total (toutes formations).
 *  - trainer : accès uniquement aux formations sur lesquelles il est
 *    habilité (table `trainer_formations`).
 *
 * Lance "Accès refusé" sinon. Le formation_slug est passé pour vérifier
 * l'habilitation côté trainer ; pour les actions sans slug en entrée
 * (update/delete), récupérer le slug depuis l'objet ciblé d'abord.
 */
export async function requireStaffOrFormationTrainer(formation_slug: string) {
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

  if (isStaff(profile.role)) {
    return { supabase, profile, isTrainerOnly: false };
  }

  if (profile.role === "trainer") {
    if (!formation_slug) throw new Error("Formation requise");

    // Vérifier l'habilitation : la formation doit être dans
    // trainer_formations pour ce trainer.
    const { data: link } = await supabase
      .from("trainer_formations")
      .select("formation_id, formations!inner(slug)")
      .eq("trainer_id", profile.id)
      .eq("formations.slug", formation_slug)
      .maybeSingle();

    if (!link) {
      throw new Error(
        `Vous n'êtes pas habilité sur la formation "${formation_slug}"`
      );
    }
    return { supabase, profile, isTrainerOnly: true };
  }

  throw new Error("Accès refusé");
}

/**
 * Récupère la liste des slugs de formations sur lesquelles le user
 * courant est habilité (admin → toutes, trainer → ses formations).
 * Utilisé pour filtrer les listes côté pages /admin/modules, /quizzes...
 */
export async function getAuthorizedFormationSlugs(): Promise<{
  slugs: string[];
  isStaff: boolean;
  isTrainerOnly: boolean;
}> {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { slugs: [], isStaff: false, isTrainerOnly: false };

  const { data: profile } = await supabase
    .from("profiles")
    .select("id, role, disabled")
    .eq("id", user.id)
    .single();
  if (!profile || profile.disabled) {
    return { slugs: [], isStaff: false, isTrainerOnly: false };
  }

  if (isStaff(profile.role)) {
    const { data: all } = await supabase
      .from("formations")
      .select("slug")
      .eq("active", true);
    return {
      slugs: (all ?? []).map((f) => f.slug),
      isStaff: true,
      isTrainerOnly: false,
    };
  }

  if (profile.role === "trainer") {
    const { data: links } = await supabase
      .from("trainer_formations")
      .select("formation:formations(slug, active)")
      .eq("trainer_id", profile.id);
    const slugs = (links ?? [])
      .map((l: any) => l.formation?.slug)
      .filter((s: any): s is string => !!s);
    return { slugs, isStaff: false, isTrainerOnly: true };
  }

  return { slugs: [], isStaff: false, isTrainerOnly: false };
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
