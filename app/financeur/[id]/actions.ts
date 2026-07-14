"use server";
import { createClient } from "@/lib/supabase/server";
import { headers } from "next/headers";
import { revalidatePath } from "next/cache";

export async function signEnrollment(id: string, formData: FormData) {
  const supabase = await createClient();
  const name = String(formData.get("name") ?? "").trim();
  const email = String(formData.get("email") ?? "").trim() || null;
  const ack = formData.get("ack") === "on";

  if (!ack) throw new Error("Vous devez confirmer la lecture.");
  if (!name) throw new Error("Nom obligatoire.");

  const fwd = (await headers()).get("x-forwarded-for") ?? "";
  const ip = fwd.split(",")[0]?.trim() || null;

  const { error } = await supabase.rpc("funder_sign_enrollment", {
    p_enrollment: id,
    p_name: name,
    p_email: email,
    p_ip: ip,
  });
  if (error) throw new Error(error.message);

  revalidatePath("/financeur");
  revalidatePath(`/financeur/${id}`);
}
