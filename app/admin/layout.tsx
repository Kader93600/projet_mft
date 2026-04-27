import { redirect } from "next/navigation";
import { AdminShell } from "@/components/admin-shell";
import { createClient } from "@/lib/supabase/server";
import { isStaff } from "@/lib/permissions";

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
  // Admin ET super_admin ont accès à l'espace admin
  if (!isStaff(profile.role)) redirect("/dashboard");
  return <AdminShell profile={profile}>{children}</AdminShell>;
}
