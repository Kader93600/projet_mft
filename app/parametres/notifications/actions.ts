"use server";
import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import type { NotificationChannel } from "@/lib/notification-preferences";

const VALID_TYPES = new Set<string>([
  "announcement",
  "message",
  "system",
  "quiz_result",
  "exam",
  "achievement",
  "course",
  "admin",
  "coaching",
  "badge",
  "certificate",
]);

const VALID_CHANNELS: NotificationChannel[] = ["in_app", "push", "email"];

/**
 * Active ou désactive un type de notification pour un canal donné.
 * Le RPC vérifie déjà l'authentification et les valeurs autorisées,
 * mais on revalide côté serveur pour éviter les appels malformés.
 */
export async function setNotificationPreference(
  type: string,
  channel: NotificationChannel,
  enabled: boolean
) {
  if (!VALID_TYPES.has(type)) return { ok: false, error: "Type invalide" };
  if (!VALID_CHANNELS.includes(channel))
    return { ok: false, error: "Canal invalide" };

  const supabase = createClient();
  const { error } = await supabase.rpc("set_notification_preference", {
    p_type: type,
    p_channel: channel,
    p_enabled: enabled,
  });
  if (error) {
    return { ok: false, error: error.message };
  }
  revalidatePath("/parametres/notifications");
  return { ok: true };
}

/**
 * Réinitialise toutes les préférences (revient au défaut "tout activé").
 */
export async function resetNotificationPreferences() {
  const supabase = createClient();
  const { error } = await supabase.rpc("reset_notification_preferences");
  if (error) return { ok: false, error: error.message };
  revalidatePath("/parametres/notifications");
  return { ok: true };
}
