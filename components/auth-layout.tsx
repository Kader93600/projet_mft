import { redirect } from "next/navigation";
import { AppShell } from "@/components/app-shell";
import { createClient } from "@/lib/supabase/server";
import { SessionTracker } from "@/components/session-tracker";
import { DailyCheckin } from "@/components/gamification/daily-checkin";
import { PwaInstallPrompt } from "@/components/pwa/install-prompt";
import { OfflineIndicator } from "@/components/pwa/offline-indicator";
import { OfflineSync } from "@/components/pwa/offline-sync";
import { TutorFab } from "@/components/tutor/tutor-fab";
import { getTutorAccess } from "@/lib/tutor/access";
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

  // Feature flag global : si désactivé, le FAB tuteur n'est jamais monté.
  const tutorEnabled = process.env.FEATURE_AI_TUTOR === "true";
  // Gate Premium (côté serveur) : on calcule l'accès une fois ici pour
  // éviter un round-trip côté client. Admin/trainer = override.
  const tutorAccess = tutorEnabled ? await getTutorAccess() : null;
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
        <OfflineIndicator />
        {profile.role === "student" && (
          <>
            <DailyCheckin />
            <PwaInstallPrompt />
            <OfflineSync />
          </>
        )}
        {tutorAccess?.allowed && (
          <TutorFab
            formationSlug={profile.current_formation_slug ?? null}
          />
        )}
        {children}
      </AppShell>
    </PostHogProvider>
  );
}
