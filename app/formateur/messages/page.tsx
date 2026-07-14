import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { MessagingShell } from "@/components/messaging/messaging-shell";

export const dynamic = "force-dynamic";

/**
 * Messagerie premium multi-conversations (espace formateur).
 * Même MessagingShell que les autres rôles, avec basePath dédié pour
 * que les liens deep-link reviennent ici plutôt que sur /messages.
 */
export default async function TrainerMessagesPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: profile } = await supabase
    .from("profiles")
    .select("role, full_name")
    .eq("id", user.id)
    .maybeSingle();

  if (!profile || !["trainer", "admin", "super_admin"].includes(profile.role)) {
    redirect("/dashboard");
  }

  return (
    <MessagingShell
      viewerId={user.id}
      viewerName={profile?.full_name ?? null}
      viewerRole={profile.role as "trainer" | "admin" | "super_admin"}
      basePath="/formateur/messages"
    />
  );
}
