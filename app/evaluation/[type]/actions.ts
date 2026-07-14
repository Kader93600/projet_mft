"use server";
import { createClient } from "@/lib/supabase/server";
import { surveySchema, formatZodError } from "@/lib/validations";
import { revalidatePath } from "next/cache";

export async function submitSurvey(raw: unknown) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");

  const res = surveySchema.safeParse(raw);
  if (!res.success) throw new Error(formatZodError(res.error));
  const data = res.data;

  // Une seule soumission par type (unique constraint)
  const { error } = await supabase.from("satisfaction_surveys").insert({
    user_id: user.id,
    ...data,
  });
  if (error) {
    if (error.code === "23505") {
      throw new Error("Enquête déjà soumise — merci !");
    }
    throw new Error(error.message);
  }
  revalidatePath("/dashboard");
  return { ok: true };
}
