"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

/**
 * Retire un membre de l'organisation. Sécurisé côté RPC :
 * la fonction set_organization_member vérifie que l'utilisateur courant
 * est org_admin de la même orga ou admin MFT.
 */
export async function removeMember(memberId: string) {
  const supabase = createClient();
  const { error } = await supabase.rpc("remove_organization_member", {
    p_member_id: memberId,
  });
  if (error) return { ok: false, error: error.message };
  revalidatePath("/organisation/parametres/equipe");
  revalidatePath("/organisation");
  return { ok: true };
}
