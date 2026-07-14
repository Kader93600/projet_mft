"use server";
import { createClient } from "@/lib/supabase/server";
import { headers } from "next/headers";
import { revalidatePath } from "next/cache";

export async function signAttendance(sessionId: string, formData: FormData) {
  const ack = formData.get("ack") === "on";
  if (!ack) throw new Error("Vous devez confirmer votre présence.");

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");

  // Le nom vient du profil : la signature de référence (dessinée) fait foi.
  const { data: profile } = await supabase
    .from("profiles")
    .select("full_name")
    .eq("id", user.id)
    .maybeSingle();
  const name = (profile?.full_name ?? "").trim();
  if (name.length < 2) throw new Error("Profil incomplet : nom manquant.");

  const h = await headers();
  const ip = (h.get("x-forwarded-for") ?? "").split(",")[0]?.trim() || null;
  const ua = h.get("user-agent") ?? null;

  const { error } = await supabase.rpc("attendance_sign", {
    p_session: sessionId,
    p_name: name,
    p_ip: ip,
    p_ua: ua,
  });
  if (error) throw new Error(error.message);

  revalidatePath("/emargement");
}
