import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { PreuvesClient } from "./preuves-client";

export const dynamic = "force-dynamic";

/**
 * Page admin "Preuves de communication" :
 * - Sélectionne un stagiaire ou formateur
 * - Exporte en 1 PDF toutes ses conversations (audit Qualiopi)
 */
export default async function PreuvesPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();
  if (!profile || !["admin", "super_admin"].includes(profile.role)) {
    redirect("/dashboard");
  }

  // Liste des candidats : tous les profils sauf moi
  const { data: candidates } = await supabase
    .from("profiles")
    .select("id, full_name, email, role")
    .neq("id", user.id)
    .order("full_name", { ascending: true })
    .limit(500);

  return <PreuvesClient candidates={(candidates ?? []) as any[]} />;
}
