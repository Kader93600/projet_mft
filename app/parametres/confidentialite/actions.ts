"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

/**
 * Active ou désactive l'apparition du stagiaire dans le classement public.
 * Le RPC SQL vérifie l'authentification.
 */
export async function setLeaderboardOptOut(optOut: boolean) {
  const supabase = await createClient();
  const { error } = await supabase.rpc("set_leaderboard_opt_out", {
    p_opt_out: optOut,
  });
  if (error) {
    return { ok: false, error: error.message };
  }
  revalidatePath("/parametres/confidentialite");
  revalidatePath("/classement");
  return { ok: true };
}
