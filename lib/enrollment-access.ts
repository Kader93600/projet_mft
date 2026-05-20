import "server-only";
import { createClient } from "@/lib/supabase/server";

/**
 * Défense en profondeur pour les routes qui génèrent un document lié à
 * un enrollment (devis, convention, attestation, convocation).
 *
 * La RLS `enrollments_self` protège déjà la LECTURE (un stagiaire ne lit
 * que son propre enrollment via le client session). Mais si une route
 * passait un jour en service_role (comme d'autres l'ont fait), l'isolation
 * sauterait. Ce helper ajoute un contrôle EXPLICITE côté code :
 *   - le propriétaire de l'enrollment, OU
 *   - un membre du staff (admin / super_admin / trainer)
 *
 * Retourne true si l'accès est autorisé.
 */
export async function canAccessEnrollment(
  currentUserId: string,
  enrollmentUserId: string | null | undefined,
): Promise<boolean> {
  if (enrollmentUserId && currentUserId === enrollmentUserId) return true;
  const supabase = createClient();
  const { data } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", currentUserId)
    .maybeSingle();
  const role = data?.role;
  return role === "admin" || role === "super_admin" || role === "trainer";
}
