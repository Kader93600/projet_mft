import { NextRequest, NextResponse } from "next/server";
import { renderToBuffer } from "@react-pdf/renderer";
import { createClient } from "@/lib/supabase/server";
import {
  ConversationPDF,
  type PdfConversation,
  type PdfData,
  type PdfMessage,
  type PdfParticipant,
} from "@/lib/pdf/conversation-pdf";
import type { Tables } from "@/lib/database.types";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/** Limite haute pour éviter les PDF démesurés. */
const MESSAGE_HARD_LIMIT = 1000;

// ── Types des lignes lues (dérivés des `select` réels ci-dessous) ────
// Le client Supabase n'est pas câblé sur `Database` (cf. CLAUDE.md) :
// les `data` sont donc `any` et on les annote explicitement ici.
// `kind`, `scope` et `sender_role` sont des `text` en base, contraints aux
// mêmes valeurs que celles attendues par le composant PDF.
type ConversationRow = Pick<Tables<"conversations">, "id" | "title" | "created_at"> &
  Pick<PdfConversation, "kind" | "scope">;
type ParticipantRow = Pick<Tables<"conversation_participants">, "user_id">;
type ProfileRow = Pick<Tables<"profiles">, "id" | "full_name" | "email" | "role">;
type MessageRow = Pick<
  Tables<"messages">,
  | "id"
  | "sender_id"
  | "body"
  | "reply_to_id"
  | "edited_at"
  | "deleted_at"
  | "created_at"
> &
  Pick<PdfMessage, "sender_role">;
type AttachmentRow = Pick<
  Tables<"message_attachments">,
  "message_id" | "mime_type" | "size_bytes" | "original_name"
>;
type ReactionRow = Pick<Tables<"message_reactions">, "message_id" | "emoji">;
type PinnedRow = Pick<Tables<"pinned_messages">, "message_id">;

/**
 * GET /api/messages/export?c=<conversation_id>
 *
 * Génère un PDF "Export de conversation" — preuve de communication.
 * Restreint au participant de la conv ou au staff (RLS gère ; on
 * vérifie aussi côté code pour des erreurs propres).
 *
 * Réponse :
 *   200 + application/pdf + Content-Disposition: attachment
 *   401 si non auth
 *   403 si non participant
 *   404 si conv introuvable
 */
export async function GET(req: NextRequest) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: "unauthorized" }, { status: 401 });
  }

  const url = new URL(req.url);
  const conversationId = url.searchParams.get("c");
  if (!conversationId) {
    return NextResponse.json(
      { error: "missing_conversation_id" },
      { status: 400 }
    );
  }

  // ── 1) Conv (RLS = participant ou staff) ─────────────────────
  const { data: convRow, error: convErr } = await supabase
    .from("conversations")
    .select("id, kind, scope, title, created_at")
    .eq("id", conversationId)
    .maybeSingle();
  const conv: ConversationRow | null = convRow;

  if (convErr) {
    return NextResponse.json({ error: convErr.message }, { status: 500 });
  }
  if (!conv) {
    return NextResponse.json(
      { error: "conversation_not_found" },
      { status: 404 }
    );
  }

  // ── 2) Participants + profils ────────────────────────────────
  const { data: parts } = await supabase
    .from("conversation_participants")
    .select("user_id")
    .eq("conversation_id", conversationId);

  const participantRows: ParticipantRow[] = parts ?? [];
  const participantIds = participantRows.map((p) => p.user_id);
  if (!participantIds.includes(user.id)) {
    // Le caller n'est pas participant : staff via is_staff peut tout de même
    // accéder grâce à la RLS plus haut, mais on bloque pour les autres rôles.
    const { data: prof } = await supabase
      .from("profiles")
      .select("role")
      .eq("id", user.id)
      .maybeSingle();
    const isStaff =
      prof?.role === "admin" || prof?.role === "super_admin";
    if (!isStaff) {
      return NextResponse.json({ error: "forbidden" }, { status: 403 });
    }
  }

  const { data: profs } = await supabase
    .from("profiles")
    .select("id, full_name, email, role")
    .in("id", participantIds.length > 0 ? participantIds : [user.id]);

  const profileRows: ProfileRow[] = profs ?? [];
  const profMap = new Map<string, PdfParticipant>();
  for (const p of profileRows) {
    profMap.set(p.id, {
      user_id: p.id,
      full_name: p.full_name ?? null,
      email: p.email,
      role: p.role,
    });
  }

  // ── 3) Compte total des messages (sans limite) ───────────────
  const { count: totalCount } = await supabase
    .from("messages")
    .select("*", { count: "exact", head: true })
    .eq("conversation_id", conversationId);
  const totalMessageCount = totalCount ?? 0;

  // ── 4) Messages (limite haute pour PDF raisonnable) ──────────
  const { data: msgs } = await supabase
    .from("messages")
    .select(
      "id, sender_id, sender_role, body, reply_to_id, edited_at, deleted_at, created_at"
    )
    .eq("conversation_id", conversationId)
    .order("created_at", { ascending: true })
    .limit(MESSAGE_HARD_LIMIT);
  const messages: MessageRow[] = msgs ?? [];

  // ── 5) Attachments + reactions + pinned (en parallèle) ───────
  const messageIds = messages.map((m) => m.id);
  let attsByMsg: Record<string, PdfMessage["attachments"]> = {};
  let reactsByMsg: Record<string, PdfMessage["reactions"]> = {};
  const pinnedSet = new Set<string>();

  if (messageIds.length > 0) {
    const [attsRes, reactsRes, pinnedRes] = await Promise.all([
      supabase
        .from("message_attachments")
        .select("message_id, mime_type, size_bytes, original_name")
        .in("message_id", messageIds),
      supabase
        .from("message_reactions")
        .select("message_id, emoji")
        .in("message_id", messageIds),
      supabase
        .from("pinned_messages")
        .select("message_id")
        .eq("conversation_id", conversationId),
    ]);

    const attachmentRows: AttachmentRow[] = attsRes.data ?? [];
    const reactionRows: ReactionRow[] = reactsRes.data ?? [];
    const pinnedRows: PinnedRow[] = pinnedRes.data ?? [];

    for (const a of attachmentRows) {
      (attsByMsg[a.message_id] ??= []).push({
        mime_type: a.mime_type,
        original_name: a.original_name,
        size_bytes: a.size_bytes,
      });
    }

    // Aggrégation des réactions par emoji
    const reactCount = new Map<string, Map<string, number>>();
    for (const r of reactionRows) {
      let perMsg = reactCount.get(r.message_id);
      if (!perMsg) {
        perMsg = new Map();
        reactCount.set(r.message_id, perMsg);
      }
      perMsg.set(r.emoji, (perMsg.get(r.emoji) ?? 0) + 1);
    }
    for (const [mid, perMsg] of reactCount) {
      reactsByMsg[mid] = Array.from(perMsg.entries()).map(([emoji, count]) => ({
        emoji,
        count,
      }));
    }

    for (const p of pinnedRows) {
      pinnedSet.add(p.message_id);
    }
  }

  // ── 6) Construit les PdfMessage finaux ───────────────────────
  const pdfMessages: PdfMessage[] = messages.map((m) => ({
    id: m.id,
    sender_id: m.sender_id,
    sender_role: m.sender_role,
    body: m.body ?? "",
    reply_to_id: m.reply_to_id ?? null,
    edited_at: m.edited_at ?? null,
    deleted_at: m.deleted_at ?? null,
    created_at: m.created_at,
    is_pinned: pinnedSet.has(m.id),
    attachments: attsByMsg[m.id] ?? [],
    reactions: reactsByMsg[m.id] ?? [],
  }));

  // ── 7) Title fallback côté serveur (RPC list_my_conversations
  //      résoudrait le titre DM côté client, mais on n'y a pas
  //      accès ici — on utilise le title de la conv ou un fallback) ─
  let title = conv.title ?? "";
  if (!title) {
    if (conv.kind === "dm") {
      const otherId = participantIds.find((id) => id !== user.id);
      const other = otherId ? profMap.get(otherId) : null;
      title = other?.full_name ?? other?.email ?? "Message direct";
    } else if (conv.scope === "admin_team") {
      title = "Équipe admin";
    } else if (conv.scope === "class") {
      title = "Conversation de classe";
    } else {
      title = "Conversation de groupe";
    }
  }

  // ── 8) Generated by ─────────────────────────────────────────
  const me = profMap.get(user.id);
  const generatedBy = me
    ? `${me.full_name ?? me.email} (${me.role})`
    : user.email ?? user.id;

  // ── 9) Render PDF ───────────────────────────────────────────
  const data: PdfData = {
    conversation: {
      id: conv.id,
      kind: conv.kind,
      scope: conv.scope,
      title,
      created_at: conv.created_at,
    },
    participants: Array.from(profMap.values()),
    messages: pdfMessages,
    generatedAt: new Date().toISOString(),
    generatedBy,
    truncated: totalMessageCount > messages.length,
    totalMessageCount,
  };

  let buffer: Buffer;
  try {
    buffer = await renderToBuffer(<ConversationPDF data={data} />);
  } catch (err) {
    const detail = err instanceof Error ? err.message : String(err);
    return NextResponse.json(
      { error: "pdf_render_failed", detail },
      { status: 500 }
    );
  }

  // ── 10) Filename safe ─────────────────────────────────────
  const safeTitle = title
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "")
    .slice(0, 60);
  const dateTag = new Date().toISOString().slice(0, 10);
  const filename = `conversation-${safeTitle || "export"}-${dateTag}.pdf`;

  return new NextResponse(new Uint8Array(buffer), {
    status: 200,
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `attachment; filename="${filename}"`,
      "Cache-Control": "private, no-cache, no-store, must-revalidate",
    },
  });
}
