"use server";
import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import { z } from "zod";

const sendSchema = z.object({
  conversation_id: z.string().uuid(),
  body: z.string().trim().min(1, "Message vide").max(5000),
});

export async function ensureMyConversation(): Promise<string> {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");
  const { data, error } = await supabase.rpc("get_or_create_my_conversation");
  if (error) throw new Error(error.message);
  return data as string;
}

export async function sendMessage(raw: unknown) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");
  const res = sendSchema.safeParse(raw);
  if (!res.success) throw new Error(res.error.errors[0]?.message ?? "Invalide");
  const { error } = await supabase.rpc("send_message", {
    p_conversation_id: res.data.conversation_id,
    p_body: res.data.body,
  });
  if (error) throw new Error(error.message);
  revalidatePath("/messages");
  revalidatePath("/admin/messages");
  return { ok: true };
}

export async function markConversationRead(conversationId: string) {
  const supabase = createClient();
  await supabase.rpc("mark_conversation_read", {
    p_conversation_id: conversationId,
  });
  revalidatePath("/messages");
  revalidatePath("/admin/messages");
  return { ok: true };
}
