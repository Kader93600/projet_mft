"use server";
import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import { z } from "zod";

const UUID = z.string().uuid();

const sendSchema = z.object({
  conversation_id: UUID,
  body: z.string().trim().min(1, "Message vide").max(5000),
  reply_to_id: UUID.nullable().optional(),
});

const ALL_PATHS = ["/messages", "/formateur/messages", "/admin/messages"];
const revalidateAll = () => {
  for (const p of ALL_PATHS) revalidatePath(p);
};

// ─── Envoi ────────────────────────────────────────────────────

export async function sendMessage(raw: unknown) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");

  const parsed = sendSchema.safeParse(raw);
  if (!parsed.success) {
    throw new Error(parsed.error.errors[0]?.message ?? "Invalide");
  }

  const { error } = await supabase.rpc("send_message", {
    p_conversation_id: parsed.data.conversation_id,
    p_body: parsed.data.body,
    p_reply_to: parsed.data.reply_to_id ?? null,
  });
  if (error) throw new Error(error.message);
  revalidateAll();
  return { ok: true };
}

// ─── Création / récupération de conversations ─────────────────

export async function createOrGetDM(targetUserId: string): Promise<string> {
  const supabase = createClient();
  const id = UUID.parse(targetUserId);
  const { data, error } = await supabase.rpc("create_or_get_dm", {
    p_target_user_id: id,
  });
  if (error) throw new Error(error.message);
  revalidateAll();
  return data as string;
}

export async function createOrGetAdminTeamConversation(): Promise<string> {
  const supabase = createClient();
  const { data, error } = await supabase.rpc("create_or_get_admin_team_conv");
  if (error) throw new Error(error.message);
  revalidateAll();
  return data as string;
}

export async function createOrGetClassConversation(
  groupId: string,
  writable = false
): Promise<string> {
  const supabase = createClient();
  const id = UUID.parse(groupId);
  const { data, error } = await supabase.rpc("create_or_get_class_conv", {
    p_group_id: id,
    p_writable: writable,
  });
  if (error) throw new Error(error.message);
  revalidateAll();
  return data as string;
}

// ─── Lecture / état ───────────────────────────────────────────

export async function markConversationRead(conversationId: string) {
  const supabase = createClient();
  const id = UUID.parse(conversationId);
  await supabase.rpc("mark_conversation_read", { p_conversation_id: id });
  revalidateAll();
  return { ok: true };
}

export async function setConversationPinned(
  conversationId: string,
  pinned: boolean
) {
  const supabase = createClient();
  const id = UUID.parse(conversationId);
  const { error } = await supabase.rpc("set_conversation_pinned", {
    p_conversation_id: id,
    p_pinned: pinned,
  });
  if (error) throw new Error(error.message);
  revalidateAll();
  return { ok: true };
}

export async function setConversationArchived(
  conversationId: string,
  archived: boolean
) {
  const supabase = createClient();
  const id = UUID.parse(conversationId);
  const { error } = await supabase.rpc("set_conversation_archived", {
    p_conversation_id: id,
    p_archived: archived,
  });
  if (error) throw new Error(error.message);
  revalidateAll();
  return { ok: true };
}

export async function setConversationMuted(
  conversationId: string,
  muted: boolean
) {
  const supabase = createClient();
  const id = UUID.parse(conversationId);
  const { error } = await supabase.rpc("set_conversation_muted", {
    p_conversation_id: id,
    p_muted: muted,
  });
  if (error) throw new Error(error.message);
  revalidateAll();
  return { ok: true };
}

// ─── Édition / suppression de message ────────────────────────

const editSchema = z.object({
  message_id: UUID,
  body: z.string().trim().min(1, "Message vide").max(5000),
});

export async function editMessage(raw: unknown) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");
  const parsed = editSchema.safeParse(raw);
  if (!parsed.success) {
    throw new Error(parsed.error.errors[0]?.message ?? "Invalide");
  }
  const { error } = await supabase
    .from("messages")
    .update({ body: parsed.data.body, edited_at: new Date().toISOString() })
    .eq("id", parsed.data.message_id)
    .eq("sender_id", user.id);
  if (error) throw new Error(error.message);
  revalidateAll();
  return { ok: true };
}

export async function deleteMessage(messageId: string) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");
  const id = UUID.parse(messageId);
  // Soft delete : seul l'auteur peut le faire
  const { error } = await supabase
    .from("messages")
    .update({ deleted_at: new Date().toISOString(), body: "" })
    .eq("id", id)
    .eq("sender_id", user.id);
  if (error) throw new Error(error.message);
  revalidateAll();
  return { ok: true };
}

// ─── Réactions emoji ──────────────────────────────────────────

const reactionSchema = z.object({
  message_id: UUID,
  emoji: z.string().trim().min(1).max(16),
});

/**
 * Toggle d'une réaction emoji sur un message. Le RPC vérifie que
 * l'utilisateur est bien participant de la conversation parente.
 * Retourne `added: true` si la réaction vient d'être ajoutée,
 * `added: false` si elle vient d'être retirée.
 */
export async function toggleReaction(raw: unknown) {
  const supabase = createClient();
  const parsed = reactionSchema.safeParse(raw);
  if (!parsed.success) {
    throw new Error(parsed.error.errors[0]?.message ?? "Invalide");
  }
  const { data, error } = await supabase.rpc("toggle_reaction", {
    p_message_id: parsed.data.message_id,
    p_emoji: parsed.data.emoji,
  });
  if (error) throw new Error(error.message);
  return { ok: true, added: !!data };
}

// ─── Pièces jointes ───────────────────────────────────────────

const ATTACH_BUCKET = "message-attachments";

/**
 * Insère les lignes message_attachments après un upload réussi côté client.
 * Le client reçoit en retour la liste avec leurs ids générés en base.
 */
const attachmentRowSchema = z.object({
  message_id: UUID,
  storage_path: z.string().min(1).max(2048),
  mime_type: z.string().min(1).max(255),
  size_bytes: z.number().int().min(0).max(50 * 1024 * 1024), // 50 MB max
  original_name: z.string().min(1).max(512),
  width: z.number().int().nullable().optional(),
  height: z.number().int().nullable().optional(),
});

export async function insertAttachments(raw: unknown[]) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");

  const items = z.array(attachmentRowSchema).parse(raw);
  if (items.length === 0) return { ok: true, ids: [] };

  const { data, error } = await supabase
    .from("message_attachments")
    .insert(
      items.map((it) => ({
        message_id: it.message_id,
        storage_path: it.storage_path,
        mime_type: it.mime_type,
        size_bytes: it.size_bytes,
        original_name: it.original_name,
        width: it.width ?? null,
        height: it.height ?? null,
      }))
    )
    .select("id");
  if (error) throw new Error(error.message);
  revalidateAll();
  return { ok: true, ids: (data ?? []).map((d: any) => d.id as string) };
}

/**
 * Supprime une pièce jointe : ligne en base + fichier dans Storage.
 * Restreint à l'auteur du message ou au staff (RLS).
 */
export async function deleteAttachment(attachmentId: string) {
  const supabase = createClient();
  const id = UUID.parse(attachmentId);

  const { data: att } = await supabase
    .from("message_attachments")
    .select("storage_path")
    .eq("id", id)
    .maybeSingle();

  const { error: dbErr } = await supabase
    .from("message_attachments")
    .delete()
    .eq("id", id);
  if (dbErr) throw new Error(dbErr.message);

  if (att?.storage_path) {
    await supabase.storage.from(ATTACH_BUCKET).remove([att.storage_path]);
  }
  revalidateAll();
  return { ok: true };
}

// ─── Suppression de conversation ──────────────────────────────

/**
 * Quitte une conversation : retire le participant courant.
 * Si plus personne ne reste, la conv est nettoyée automatiquement
 * (cascade messages). Les autres participants la conservent.
 */
export async function leaveConversation(conversationId: string) {
  const supabase = createClient();
  const id = UUID.parse(conversationId);
  const { error } = await supabase.rpc("leave_conversation", {
    p_conversation_id: id,
  });
  if (error) throw new Error(error.message);
  revalidateAll();
  return { ok: true };
}

/**
 * Supprime une conversation pour tout le monde (cascade messages).
 * Admin/super_admin OU owner de la conv uniquement.
 */
export async function deleteConversation(conversationId: string) {
  const supabase = createClient();
  const id = UUID.parse(conversationId);
  const { error } = await supabase.rpc("delete_conversation", {
    p_conversation_id: id,
  });
  if (error) throw new Error(error.message);
  revalidateAll();
  return { ok: true };
}

// ─── Compat legacy : ensureMyConversation ────────────────────
// Conservé temporairement pour ne pas casser les anciens appels.
// En interne, redirige vers la nouvelle conv "Équipe admin".

export async function ensureMyConversation(): Promise<string> {
  return createOrGetAdminTeamConversation();
}
