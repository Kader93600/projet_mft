"use server";
import { createClient } from "@/lib/supabase/server";
import { headers } from "next/headers";
import { revalidatePath } from "next/cache";

export async function signAttendance(sessionId: string, formData: FormData) {
  const name = String(formData.get("name") ?? "").trim();
  const ack = formData.get("ack") === "on";
  if (!ack) throw new Error("Vous devez confirmer votre présence.");
  if (name.length < 2) throw new Error("Veuillez saisir votre nom complet.");

  const h = headers();
  const ip = (h.get("x-forwarded-for") ?? "").split(",")[0]?.trim() || null;
  const ua = h.get("user-agent") ?? null;

  const supabase = createClient();
  const { error } = await supabase.rpc("attendance_sign", {
    p_session: sessionId,
    p_name: name,
    p_ip: ip,
    p_ua: ua,
  });
  if (error) throw new Error(error.message);

  revalidatePath("/emargement");
}
