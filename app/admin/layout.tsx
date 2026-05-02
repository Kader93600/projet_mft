import { redirect } from "next/navigation";
import { AdminShell } from "@/components/admin-shell";
import { createClient } from "@/lib/supabase/server";
import { isStaff, isTrainer } from "@/lib/permissions";

export default async function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = createClient();
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
  return <AdminShell profile={profile}>{children}</AdminShell>;
}
