"use server";
import { createClient } from "@/lib/supabase/server";
import { headers } from "next/headers";
import { revalidatePath } from "next/cache";
import { z } from "zod";

const acceptSchema = z.object({
  document_id: z.string().uuid(),
});

export async function acceptDocument(raw: unknown) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");

  const res = acceptSchema.safeParse(raw);
  if (!res.success) throw new Error("Données invalides");

  const ua = headers().get("user-agent") ?? null;
  const { error } = await supabase.rpc("accept_document", {
    p_document_id: res.data.document_id,
    p_user_agent: ua,
  });
  if (error) throw new Error(error.message);
  revalidatePath("/onboarding");
  revalidatePath("/dashboard");
  return { ok: true };
}
