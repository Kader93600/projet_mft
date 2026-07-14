import { redirect } from "next/navigation";
import { AdminShell } from "@/components/admin-shell";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { isStaff, isTrainer } from "@/lib/permissions";

export default async function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: profile } = await supabase
    .from("profiles")
    .select("*")
    .eq("id", user.id)
    .single();
  if (!profile) redirect("/login");
  // Admin / super_admin : tout l'admin.
  // Trainer : seulement les routes pédagogiques (gating fin par middleware
  // + per-action via requireStaffOrFormationTrainer).
  if (!isStaff(profile.role) && !isTrainer(profile.role)) {
    redirect("/dashboard");
  }

  // Pastilles : compteur d'emails reçus non lus pour le staff (admin /
  // super_admin uniquement ; les formateurs n'ont pas accès à /admin/emails).
  // Silencieux si la table / colonnes ne sont pas encore migrées.
  let unreadInbox = 0;
  if (isStaff(profile.role)) {
    try {
      const admin = createAdminClient();
      const { count } = await admin
        .from("email_log")
        .select("*", { count: "exact", head: true })
        .eq("direction", "inbound")
        .is("read_at", null);
      unreadInbox = count ?? 0;
    } catch {
      /* migration non appliquée — on n'affiche aucune pastille */
    }
  }
  const badges = unreadInbox > 0 ? { "/admin/emails": unreadInbox } : undefined;

  return (
    <AdminShell profile={profile} badges={badges}>
      {children}
    </AdminShell>
  );
}
