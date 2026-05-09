import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { NotificationsArchive } from "@/components/notifications-archive";
import type { NotificationRow } from "@/components/notification-item";

export const dynamic = "force-dynamic";

/**
 * Page archive des notifications : wrapper server qui charge le dataset
 * initial (200 dernières) et délègue toute l'interactivité au composant
 * client `NotificationsArchive`.
 */
export default async function NotificationsPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data } = await supabase
    .from("notifications")
    .select("id, type, title, body, link_url, read_at, created_at")
    .eq("user_id", user.id)
    .order("created_at", { ascending: false })
    .limit(200);

  const initialNotifs = (data ?? []) as NotificationRow[];

  return (
    <NotificationsArchive
      initialNotifs={initialNotifs}
      userId={user.id}
    />
  );
}
