import { NextRequest, NextResponse } from "next/server";
import { renderToBuffer } from "@react-pdf/renderer";
import { createClient } from "@/lib/supabase/server";
import {
  MultiConversationPDF,
  type MultiPdfData,
} from "@/lib/pdf/multi-conversation-pdf";
import type {
  PdfConversation,
  PdfData,
  PdfMessage,
  PdfParticipant,
} from "@/lib/pdf/conversation-pdf";
import type { Tables } from "@/lib/database.types";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

// ── Formes exactes des lignes lues (miroir des `.select(...)` ci-dessous) ──
type ConvLinkRow = Pick<Tables<"conversation_participants">, "conversation_id">;
type ParticipantLinkRow = Pick<Tables<"conversation_participants">, "user_id">;
type ConvRow = Pick<
  Tables<"conversations">,
  "id" | "kind" | "scope" | "title" | "created_at" | "last_message_at"
>;
type MessageRow = Pick<
  Tables<"messages">,
  | "id"
  | "sender_id"
  | "sender_role"
  | "body"
  | "reply_to_id"
  | "edited_at"
  | "deleted_at"
  | "created_at"
>;
type ProfileRow = Pick<
  Tables<"profiles">,
  "id" | "full_name" | "email" | "role"
>;
type AttachmentRow = Pick<
  Tables<"message_attachments">,
  "message_id" | "mime_type" | "size_bytes" | "original_name"
>;
type ReactionRow = Pick<Tables<"message_reactions">, "message_id" | "emoji">;
type PinnedRow = Pick<Tables<"pinned_messages">, "message_id">;

/** Limite par conv pour éviter un PDF démesuré. */
const MESSAGES_PER_CONV_LIMIT = 500;
/** Limite globale de conversations (au-delà, on tronque + warn). */
const CONV_HARD_LIMIT = 50;

/**
 * GET /api/admin/messages/export-by-user?userId=<uuid>
 *
 * Génère un PDF "Preuves de communication" reprenant TOUTES les
 * conversations dont l'utilisateur cible est participant.
 * Réservé aux admins / super_admins.
 */
export async function GET(req: NextRequest) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: "unauthorized" }, { status: 401 });
  }

  // Staff only
  const { data: meProfile } = await supabase
    .from("profiles")
    .select("role, full_name, email")
    .eq("id", user.id)
    .maybeSingle();
  const isStaff =
    meProfile?.role === "admin" || meProfile?.role === "super_admin";
  if (!isStaff) {
    return NextResponse.json({ error: "forbidden" }, { status: 403 });
  }

  const url = new URL(req.url);
  const targetUserId = url.searchParams.get("userId");
  if (!targetUserId) {
    return NextResponse.json({ error: "missing_user_id" }, { status: 400 });
  }

  // Profil cible
  const { data: target } = await supabase
    .from("profiles")
    .select("id, full_name, email, role")
    .eq("id", targetUserId)
    .maybeSingle();
  if (!target) {
    return NextResponse.json({ error: "user_not_found" }, { status: 404 });
  }

  const targetUser: PdfParticipant = {
    user_id: target.id,
    full_name: target.full_name ?? null,
    email: target.email,
    role: target.role,
  };

  // ── Liste des conversations dont la cible est participante ────
  const { data: convLinks } = await supabase
    .from("conversation_participants")
    .select("conversation_id")
    .eq("user_id", targetUserId);

  const convIds = ((convLinks ?? []) as ConvLinkRow[]).map(
    (c) => c.conversation_id
  );
  if (convIds.length === 0) {
    return NextResponse.json(
      { error: "no_conversations_for_user" },
      { status: 404 }
    );
  }

  // Fetch convs metadata, ordered by last_message_at DESC, capped
  const { data: convs } = await supabase
    .from("conversations")
    .select("id, kind, scope, title, created_at, last_message_at")
    .in("id", convIds)
    .order("last_message_at", { ascending: false })
    .limit(CONV_HARD_LIMIT);

  if (!convs || convs.length === 0) {
    return NextResponse.json(
      { error: "no_conversations_accessible" },
      { status: 404 }
    );
  }

  // ── Pour chaque conv : participants + messages + attachments + reactions + pinned ──
  const conversations: PdfData[] = [];
  for (const conv of convs as ConvRow[]) {
    const [partsRes, msgsRes, totalCountRes] = await Promise.all([
      supabase
        .from("conversation_participants")
        .select("user_id")
        .eq("conversation_id", conv.id),
      supabase
        .from("messages")
        .select(
          "id, sender_id, sender_role, body, reply_to_id, edited_at, deleted_at, created_at"
        )
        .eq("conversation_id", conv.id)
        .order("created_at", { ascending: true })
        .limit(MESSAGES_PER_CONV_LIMIT),
      supabase
        .from("messages")
        .select("*", { count: "exact", head: true })
        .eq("conversation_id", conv.id),
    ]);

    const partIds = ((partsRes.data ?? []) as ParticipantLinkRow[]).map(
      (p) => p.user_id
    );
    const messages = (msgsRes.data ?? []) as MessageRow[];
    const totalMessageCount = totalCountRes.count ?? messages.length;

    // Profils des participants
    let participants: PdfParticipant[] = [];
    if (partIds.length > 0) {
      const { data: profs } = await supabase
        .from("profiles")
        .select("id, full_name, email, role")
        .in("id", partIds);
      participants = ((profs ?? []) as ProfileRow[]).map((p) => ({
        user_id: p.id,
        full_name: p.full_name ?? null,
        email: p.email,
        role: p.role,
      }));
    }

    // Charge attachments + reactions + pinned en parallèle
    const messageIds = messages.map((m) => m.id);
    const attsByMsg: Record<string, PdfMessage["attachments"]> = {};
    const reactsByMsg: Record<string, PdfMessage["reactions"]> = {};
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
          .eq("conversation_id", conv.id),
      ]);

      for (const a of (attsRes.data ?? []) as AttachmentRow[]) {
        (attsByMsg[a.message_id] ??= []).push({
          mime_type: a.mime_type,
          original_name: a.original_name,
          size_bytes: a.size_bytes,
        });
      }
      const reactCount = new Map<string, Map<string, number>>();
      for (const r of (reactsRes.data ?? []) as ReactionRow[]) {
        let perMsg = reactCount.get(r.message_id);
        if (!perMsg) {
          perMsg = new Map();
          reactCount.set(r.message_id, perMsg);
        }
        perMsg.set(r.emoji, (perMsg.get(r.emoji) ?? 0) + 1);
      }
      for (const [mid, perMsg] of reactCount) {
        reactsByMsg[mid] = Array.from(perMsg.entries()).map(
          ([emoji, count]) => ({ emoji, count })
        );
      }
      for (const p of (pinnedRes.data ?? []) as PinnedRow[]) {
        pinnedSet.add(p.message_id);
      }
    }

    const pdfMessages: PdfMessage[] = messages.map((m) => ({
      id: m.id,
      sender_id: m.sender_id,
      // `messages.sender_role` est un `text` en base (contraint côté métier) :
      // on le restreint ici à l'union attendue par le PDF.
      sender_role: m.sender_role as PdfMessage["sender_role"],
      body: m.body ?? "",
      reply_to_id: m.reply_to_id ?? null,
      edited_at: m.edited_at ?? null,
      deleted_at: m.deleted_at ?? null,
      created_at: m.created_at,
      is_pinned: pinnedSet.has(m.id),
      attachments: attsByMsg[m.id] ?? [],
      reactions: reactsByMsg[m.id] ?? [],
    }));

    // Title fallback
    let title = conv.title ?? "";
    if (!title) {
      if (conv.kind === "dm") {
        const otherId = partIds.find((id) => id !== targetUserId);
        const other = participants.find((p) => p.user_id === otherId);
        title =
          other?.full_name ??
          other?.email ??
          "Message direct";
      } else if (conv.scope === "admin_team") {
        title = "Équipe admin";
      } else if (conv.scope === "class") {
        title = "Conversation de classe";
      } else {
        title = "Conversation de groupe";
      }
    }

    conversations.push({
      conversation: {
        id: conv.id,
        // `conversations.kind` / `.scope` sont des `text` en base : on les
        // restreint aux unions attendues par le PDF.
        kind: conv.kind as PdfConversation["kind"],
        scope: conv.scope as PdfConversation["scope"],
        title,
        created_at: conv.created_at,
      },
      participants,
      messages: pdfMessages,
      generatedAt: new Date().toISOString(),
      generatedBy: "",
      truncated: totalMessageCount > messages.length,
      totalMessageCount,
    });
  }

  const generatedBy = meProfile
    ? `${meProfile.full_name ?? meProfile.email} (${meProfile.role})`
    : user.email ?? user.id;

  const data: MultiPdfData = {
    targetUser,
    conversations,
    generatedAt: new Date().toISOString(),
    generatedBy,
  };

  let buffer: Buffer;
  try {
    buffer = await renderToBuffer(<MultiConversationPDF data={data} />);
  } catch (err) {
    return NextResponse.json(
      {
        error: "pdf_render_failed",
        detail: err instanceof Error ? err.message : String(err),
      },
      { status: 500 }
    );
  }

  // Filename
  const baseName = (targetUser.full_name ?? targetUser.email)
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "")
    .slice(0, 60);
  const dateTag = new Date().toISOString().slice(0, 10);
  const filename = `preuves-comm-${baseName}-${dateTag}.pdf`;

  return new NextResponse(new Uint8Array(buffer), {
    status: 200,
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `attachment; filename="${filename}"`,
      "Cache-Control": "private, no-cache, no-store, must-revalidate",
    },
  });
}
