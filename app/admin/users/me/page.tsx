import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

/**
 * /admin/users/me → redirige vers la fiche utilisateur du user connecté.
 * Permet d'avoir un lien "Mon profil" universel dans le menu.
 */
export default async function MyAdminProfilePage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  redirect(`/admin/users/${user.id}`);
}
