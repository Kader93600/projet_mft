import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { PreferencesClient } from "./preferences-client";
import {
  DEFAULT_PREFERENCES,
  type PreferenceState,
} from "@/lib/notification-preferences";

export const dynamic = "force-dynamic";

export default async function NotificationsPreferencesPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data } = await supabase
    .from("notification_preferences")
    .select("in_app_disabled, push_disabled, email_disabled")
    .eq("user_id", user.id)
    .maybeSingle();

  const initial: PreferenceState = data
    ? {
        in_app_disabled: data.in_app_disabled ?? [],
        push_disabled: data.push_disabled ?? [],
        email_disabled: data.email_disabled ?? [],
      }
    : DEFAULT_PREFERENCES;

  return <PreferencesClient initial={initial} />;
}
