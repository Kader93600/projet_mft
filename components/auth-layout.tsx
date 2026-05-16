import { redirect } from "next/navigation";
import { AppShell } from "@/components/app-shell";
import { createClient } from "@/lib/supabase/server";
import { SessionTracker } from "@/components/session-tracker";
import { isStaff } from "@/lib/permissions";
import { PostHogProvider } from "@/components/posthog-provider";

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
  // requireAdmin autorise admin ET super_admin (cohérent avec requireAdmin() côté actions).
  if (requireAdmin && !isStaff(profile.role)) redirect("/dashboard");
  return (
    <PostHogProvider
      profile={{
        id: profile.id,
        email: profile.email,
        role: profile.role,
        full_name: profile.full_name,
        active_formation_slug: profile.current_formation_slug ?? null,
      }}
    >
      <AppShell profile={profile}>
        <SessionTracker />
        {children}
      </AppShell>
    </PostHogProvider>
  );
}
