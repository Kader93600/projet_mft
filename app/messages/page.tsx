import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { MessagingShell } from "@/components/messaging/messaging-shell";

export const dynamic = "force-dynamic";

/**
 * Messagerie premium multi-conversations (espace stagiaire).
 * La logique d'affichage est entièrement gérée par <MessagingShell />.
 */
export default async function MessagesPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: profile } = await supabase
    .from("profiles")
    .select("role, full_name")
    .eq("id", user.id)
    .maybeSingle();

  const role = (profile?.role ?? "student") as
    | "student"
    | "trainer"
    | "admin"
    | "super_admin";

  return (
    <MessagingShell
      viewerId={user.id}
      viewerName={profile?.full_name ?? null}
      viewerRole={role}
      basePath="/messages"
    />
  );
}
