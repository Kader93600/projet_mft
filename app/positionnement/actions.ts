"use server";
import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import { placementSubmitSchema, formatZodError } from "@/lib/validations";

export async function submitPlacement(raw: unknown) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");

  const parsed = placementSubmitSchema.safeParse(raw);
  if (!parsed.success) throw new Error(formatZodError(parsed.error));

  const { data, error } = await supabase.rpc("submit_placement", {
    p_answers: parsed.data.answers,
    p_duration_s: parsed.data.duration_s ?? null,
  });
  if (error) throw new Error(error.message);

  revalidatePath("/positionnement");
  revalidatePath("/dashboard");
  return { ok: true, result: data };
}
