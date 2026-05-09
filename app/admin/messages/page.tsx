import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { MessagingShell } from "@/components/messaging/messaging-shell";

export const dynamic = "force-dynamic";

/**
 * Messagerie premium multi-conversations (espace admin).
 * Réutilise le même MessagingShell — les admins voient en plus toutes
 * les conversations grâce à la RLS spéciale `is_staff()`.
 */
export default async function AdminMessagesPage() {
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

  if (!profile || !["admin", "super_admin"].includes(profile.role)) {
    redirect("/dashboard");
  }

  return (
    <MessagingShell
      viewerId={user.id}
      viewerName={profile?.full_name ?? null}
      viewerRole={profile.role as "admin" | "super_admin"}
      basePath="/admin/messages"
    />
  );
}
