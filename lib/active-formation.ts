// =====================================================================
// Helper : résoudre la "formation active" du stagiaire connecté
// =====================================================================
// Usage côté Server Component :
//   import { getActiveFormation } from "@/lib/active-formation";
//   const f = await getActiveFormation(supabase, user.id);
//   if (!f) return <NoEnrollmentState />;
//   const modules = await supabase.from("modules")
//     .select("*, formation_modules!inner(formation_id)")
//     .eq("formation_modules.formation_id", f.id);
//
// Logique :
//   1. Lecture de profiles.current_formation_id (si posée)
//   2. Vérification que cette formation est toujours valide pour l'user
//      (sinon on l'ignore — l'user a pu être désinscrit)
//   3. Fallback : enrollment status='en_cours' prioritaire, sinon le
//      plus récent non-refusé/abandonné
//   4. Si l'user n'a aucune inscription valide → renvoie null
//
// La fonction met à jour profiles.current_formation_id quand le
// fallback est utilisé pour la première fois (1 seul UPDATE).
// =====================================================================

import type { SupabaseClient } from "@supabase/supabase-js";

export type ActiveFormation = {
  id: string;
  slug: string;
  code: string;
  title: string;
};

export async function getActiveFormation(
  supabase: SupabaseClient,
  userId: string
): Promise<ActiveFormation | null> {
  // 1) Lecture du profil + enrollments en parallèle
  const [{ data: profile }, { data: enrollments }] = await Promise.all([
    supabase
      .from("profiles")
      .select("current_formation_id")
      .eq("id", userId)
      .maybeSingle(),
    supabase
      .from("enrollments")
      .select("formation_id, status, created_at")
      .eq("user_id", userId)
      .not("formation_id", "is", null)
      .not("status", "in", "(refuse,abandon)")
      .order("created_at", { ascending: false }),
  ]);

  const validIds = new Set(
    (enrollments ?? []).map((e: any) => e.formation_id as string)
  );

  // Pas d'inscription valide → null (l'UI doit afficher un état
  // "aucune formation active")
  if (validIds.size === 0) return null;

  // 2) Le current_formation_id du profil est-il toujours valide ?
  const profileFid = (profile as any)?.current_formation_id as string | null;
  let chosenId: string | null =
    profileFid && validIds.has(profileFid) ? profileFid : null;

  // 3) Fallback : en_cours en priorité, sinon le plus récent
  if (!chosenId) {
    const sorted = [...(enrollments ?? [])].sort((a: any, b: any) => {
      const ar = a.status === "en_cours" ? 0 : 1;
      const br = b.status === "en_cours" ? 0 : 1;
      if (ar !== br) return ar - br;
      return (
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
      );
    });
    chosenId = sorted[0]?.formation_id ?? null;
  }

  if (!chosenId) return null;

  // 4) Récupère les métadonnées (slug, code, title)
  const { data: f } = await supabase
    .from("formations")
    .select("id, slug, code, title")
    .eq("id", chosenId)
    .maybeSingle();

  if (!f) return null;

  // 5) Si current_formation_id n'était pas défini (ou plus valide),
  //    on persiste le fallback. Best-effort : on n'attend pas l'erreur.
  if (profileFid !== chosenId) {
    await supabase.rpc("set_current_formation", { p_formation: chosenId });
  }

  return f as ActiveFormation;
}

/**
 * Version "lite" — ne renvoie que l'id sans aller chercher les métadonnées.
 * Utile pour les pages qui n'ont pas besoin d'afficher le nom de la
 * formation (ex: stats, exports). Pas d'effet de bord (pas de SET).
 */
export async function getActiveFormationId(
  supabase: SupabaseClient,
  userId: string
): Promise<string | null> {
  const f = await getActiveFormation(supabase, userId);
  return f?.id ?? null;
}
