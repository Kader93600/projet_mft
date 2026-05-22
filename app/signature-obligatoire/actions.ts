"use server";

import { createClient } from "@/lib/supabase/server";
import { headers } from "next/headers";
import { revalidatePath } from "next/cache";
import { createHash } from "crypto";

/**
 * Enregistre la signature de référence du stagiaire, accepte tous les
 * documents publiés (horodatage + IP + nom) et notifie les admins — le tout
 * via la RPC atomique complete_mandatory_signature (SECURITY DEFINER).
 */
export async function submitMandatorySignature(signatureDataUrl: string) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: "Non authentifié" };

  // Validation basique de la signature (PNG data URL, taille raisonnable).
  if (
    typeof signatureDataUrl !== "string" ||
    !signatureDataUrl.startsWith("data:image/png;base64,") ||
    signatureDataUrl.length < 200 ||
    signatureDataUrl.length > 1_500_000
  ) {
    return { ok: false, error: "Signature invalide ou vide." };
  }

  const h = headers();
  const ua = h.get("user-agent") ?? null;
  const ip =
    h.get("x-forwarded-for")?.split(",")[0]?.trim() ||
    h.get("x-real-ip") ||
    null;

  // Empreinte : lie la signature à l'utilisateur + l'instant (anti-rejeu simple).
  const hash = createHash("sha256")
    .update(`${user.id}|${Date.now()}|${signatureDataUrl}`)
    .digest("hex");

  const { data: profile } = await supabase
    .from("profiles")
    .select("full_name")
    .eq("id", user.id)
    .maybeSingle();

  const { error } = await supabase.rpc("complete_mandatory_signature", {
    p_signature_data: signatureDataUrl,
    p_hash: hash,
    p_ip: ip,
    p_user_agent: ua,
    p_signature_name: profile?.full_name ?? null,
  });
  if (error) return { ok: false, error: error.message };

  revalidatePath("/signature-obligatoire");
  revalidatePath("/dashboard");
  revalidatePath("/mes-documents");
  return { ok: true };
}
