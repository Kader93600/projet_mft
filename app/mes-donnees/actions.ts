"use server";
import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

export async function requestDeletion(formData: FormData) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");

  const reason = (formData.get("reason") as string) || null;

  const { error } = await supabase.from("deletion_requests").insert({
    user_id: user.id,
    reason,
  });
  if (error) throw new Error(error.message);
  revalidatePath("/mes-donnees");
}

export async function cancelDeletion(id: string) {
  const supabase = createClient();
  const { error } = await supabase
    .from("deletion_requests")
    .update({ status: "cancelled", resolved_at: new Date().toISOString() })
    .eq("id", id);
  if (error) throw new Error(error.message);
  revalidatePath("/mes-donnees");
}

export async function setConsent(kind: string, granted: boolean) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");

  const { error } = await supabase.from("user_consents").upsert(
    {
      user_id: user.id,
      kind,
      granted,
      granted_at: new Date().toISOString(),
    },
    { onConflict: "user_id,kind" }
  );
  if (error) throw new Error(error.message);
  revalidatePath("/mes-donnees");
}

// setLocale retiré : EN n'est pas encore traduit côté UI.
// La colonne profiles.locale est conservée pour usage futur.
