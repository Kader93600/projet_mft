// =====================================================================
// Helper côté serveur : a-t-on accès à l'IA tuteur ?
//
// Règle métier (décision client 2026-05) :
//   • Chat IA tuteur ("ai_tutor_chat") = pack Premium uniquement
//   • Correction QR automatique ("qr_ai_grading") = tous les packs
//
// Le helper retourne :
//   - allowed: boolean      → l'utilisateur a accès au chat
//   - pack:    PackSlug|null → son pack pour la formation contextuelle
//   - reason:  string|null   → si refus, raison lisible pour l'UI
//
// Usage côté API (server) :
//   const access = await getTutorAccess(formationSlug);
//   if (!access.allowed) return NextResponse.json({error: access.reason}, {status:403});
//
// Usage côté Server Component :
//   const access = await getTutorAccess(formationSlug);
//   if (!access.allowed) return <TutorUpsell pack={access.pack} />;
// =====================================================================

import { createClient } from "@/lib/supabase/server";
import type { PackSlug } from "@/lib/packs";
import type { Tables } from "@/lib/database.types";

/** profiles(role, current_formation_slug) — `current_formation_slug` n'est pas
 *  présent dans le schéma introspecté : le type reflète le `select` tel qu'il
 *  est écrit (si la colonne manque, la requête renvoie `null`). */
type TutorProfileRow = Pick<Tables<"profiles">, "role"> & {
  current_formation_slug: string | null;
};

export interface TutorAccess {
  allowed: boolean;
  pack: PackSlug | null;
  reason: string | null;
}

/**
 * Vérifie si l'utilisateur courant a accès au chat IA tuteur.
 *
 * @param formationSlug La formation contextuelle (ex: "gotrm-rncp-40990").
 *   Si null/undefined, la vérification se fait sur l'enrollment actif du
 *   profil (current_formation_slug) si présent.
 */
export async function getTutorAccess(
  formationSlug?: string | null
): Promise<TutorAccess> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return { allowed: false, pack: null, reason: "Non authentifié" };
  }

  // Override admin/super_admin : peut accéder à l'IA pour tester ou
  // assister un stagiaire qui n'a pas le pack Premium.
  const { data: profileData } = await supabase
    .from("profiles")
    .select("role, current_formation_slug")
    .eq("id", user.id)
    .maybeSingle();
  const profile = (profileData ?? null) as TutorProfileRow | null;

  const role = profile?.role;
  if (role === "admin" || role === "super_admin" || role === "trainer") {
    return { allowed: true, pack: "premium", reason: null };
  }

  const slug = formationSlug ?? profile?.current_formation_slug;
  if (!slug) {
    return {
      allowed: false,
      pack: null,
      reason: "Aucune formation active. Le tuteur IA est rattaché à une formation.",
    };
  }

  const { data: packData } = await supabase
    .rpc("user_pack_for_formation", {
      p_user_id: user.id,
      p_formation_slug: slug,
    })
    .single();

  const pack = (packData as PackSlug | null) ?? null;

  if (pack === "premium") {
    return { allowed: true, pack, reason: null };
  }

  return {
    allowed: false,
    pack,
    reason:
      "Le tuteur IA est inclus dans le pack Premium. Mettez à niveau votre formule pour discuter avec lui 24/7.",
  };
}
