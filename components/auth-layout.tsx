import { redirect } from "next/navigation";
import { AppShell } from "@/components/app-shell";
import { createClient } from "@/lib/supabase/server";
import { SessionTracker } from "@/components/session-tracker";

export async function AuthLayout({
  children,
  requireAdmin = false,
}: {
  children: React.ReactNode;
  requireAdmin?: boolean;
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
  if (requireAdmin && profile.role !== "admin") redirect("/dashboard");
  return (
    <AppShell profile={profile}>
      <SessionTracker />
      {children}
    </AppShell>
  );
}
