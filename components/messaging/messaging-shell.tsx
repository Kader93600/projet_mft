"use client";
import {
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
  useTransition,
} from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { MessageCircle } from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import { cn } from "@/lib/utils";
import {
  sendMessage,
  markConversationRead,
  setConversationPinned,
  setConversationArchived,
  setConversationMuted,
  editMessage,
  deleteMessage,
  leaveConversation,
  deleteConversation,
  toggleReaction,
  insertAttachments,
  togglePinnedMessage,
} from "@/app/messages/actions";
import { MessageSearchModal } from "@/components/messaging/message-search-modal";
import { ConversationsList } from "@/components/messaging/conversations-list";
import { MessageThreadV2 } from "@/components/messaging/message-thread-v2";
import { MessageComposer } from "@/components/messaging/message-composer";
import { NewMessageModal } from "@/components/messaging/new-message-modal";
import {
  conversationTitle,
} from "@/lib/messaging-utils";
import type {
  ConversationSummary,
  MessageRow,
  MinimalProfile,
  ParticipantWithReadState,
  MessageAttachment,
  MessageReaction,
  PinnedMessage,
} from "@/lib/messaging-types";
import type { Tables } from "@/lib/database.types";

const ATTACH_BUCKET = "message-attachments";

/** `conversation_participants` — select("user_id, last_read_at") */
type ParticipantRow = Pick<
  Tables<"conversation_participants">,
  "user_id" | "last_read_at"
>;
/** `messages` — select("id") */
type MessageIdRow = Pick<Tables<"messages">, "id">;

/** Lit width/height d'une image en mémoire (pour stocker en BDD). */
function readImageDimensions(
  file: File
): Promise<{ width: number; height: number }> {
  return new Promise((resolve, reject) => {
    const url = URL.createObjectURL(file);
    const img = new Image();
    img.onload = () => {
      const dim = { width: img.naturalWidth, height: img.naturalHeight };
      URL.revokeObjectURL(url);
      resolve(dim);
    };
    img.onerror = () => {
      URL.revokeObjectURL(url);
      reject(new Error("Image invalide"));
    };
    img.src = url;
  });
}

interface Props {
  viewerId: string;
  viewerName: string | null;
  viewerRole: "student" | "trainer" | "admin" | "super_admin";
  /** URL de base (ex: /messages, /formateur/messages, /admin/messages) — pour la query string `?c=` */
  basePath: string;
}

/**
 * Orchestrateur de la messagerie premium :
 *   - Liste des conversations (sidebar)
 *   - Thread sélectionné (zone droite)
 *   - Modal "Nouveau message"
 *   - Realtime sur conversations + messages + participants
 *   - URL state ?c=<conv_id> pour deep-linking
 *   - Mobile : 2 niveaux (liste / thread) avec retour
 */
export function MessagingShell({
  viewerId,
  viewerName,
  viewerRole,
  basePath,
}: Props) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const selectedId = searchParams.get("c");

  const [conversations, setConversations] = useState<ConversationSummary[]>([]);
  const [messages, setMessages] = useState<MessageRow[]>([]);
  const [participants, setParticipants] = useState<Record<string, MinimalProfile>>({});
  const [liveParticipants, setLiveParticipants] = useState<ParticipantWithReadState[]>([]);
  const [attachmentsByMsg, setAttachmentsByMsg] = useState<
    Record<string, MessageAttachment[]>
  >({});
  const [reactionsByMsg, setReactionsByMsg] = useState<
    Record<string, MessageReaction[]>
  >({});
  const [pinnedMessages, setPinnedMessages] = useState<PinnedMessage[]>([]);
  const [loadingList, setLoadingList] = useState(true);
  const [newOpen, setNewOpen] = useState(false);
  const [searchOpen, setSearchOpen] = useState(false);
  const [replyTo, setReplyTo] = useState<MessageRow | null>(null);
  const [, startTransition] = useTransition();

  const instanceIdRef = useRef<string>(
    typeof crypto !== "undefined" && "randomUUID" in crypto
      ? crypto.randomUUID()
      : Math.random().toString(36).slice(2)
  );

  const selected = useMemo(
    () => conversations.find((c) => c.id === selectedId) ?? null,
    [conversations, selectedId]
  );

  // ── Charge la liste de conversations ─────────────────────────
  const refreshConversations = useCallback(async () => {
    const supabase = createClient();
    const { data, error } = await supabase.rpc("list_my_conversations");
    if (!error && data) {
      setConversations(data as ConversationSummary[]);
    }
    setLoadingList(false);
  }, []);

  useEffect(() => {
    void refreshConversations();
  }, [refreshConversations]);

  // ── Charge les messages de la conversation sélectionnée ──────
  const loadMessages = useCallback(async (convId: string) => {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("messages")
      .select("id, conversation_id, sender_id, sender_role, body, reply_to_id, edited_at, deleted_at, created_at, read_at")
      .eq("conversation_id", convId)
      .order("created_at", { ascending: true })
      .limit(500);
    const rows = (data ?? []) as MessageRow[];
    if (!error && data) setMessages(rows);

    // Charge les profils des sender uniques
    const ids = Array.from(new Set(rows.map((m) => m.sender_id)));
    if (ids.length > 0) {
      const { data: profs } = await supabase
        .from("profiles")
        .select("id, full_name, email, role")
        .in("id", ids);
      if (profs) {
        const map: Record<string, MinimalProfile> = {};
        for (const p of profs as MinimalProfile[]) map[p.id] = p;
        setParticipants((prev) => ({ ...prev, ...map }));
      }
    }
  }, []);

  // ── Charge les participants (avec last_read_at) de la conv sélectionnée ──
  const loadLiveParticipants = useCallback(async (convId: string) => {
    const supabase = createClient();
    const { data: partsData } = await supabase
      .from("conversation_participants")
      .select("user_id, last_read_at")
      .eq("conversation_id", convId);
    if (!partsData) return;
    const parts = partsData as ParticipantRow[];

    const ids = parts.map((p) => p.user_id);
    const { data: profs } = await supabase
      .from("profiles")
      .select("id, full_name, email, role")
      .in("id", ids);
    const profMap: Record<string, MinimalProfile> = {};
    for (const p of (profs ?? []) as MinimalProfile[]) profMap[p.id] = p;

    const merged: ParticipantWithReadState[] = parts.map((p) => ({
      user_id: p.user_id,
      last_read_at: p.last_read_at,
      full_name: profMap[p.user_id]?.full_name ?? null,
      email: profMap[p.user_id]?.email ?? "",
      role: profMap[p.user_id]?.role ?? "",
    }));
    setLiveParticipants(merged);
  }, []);

  // ── Charge les messages épinglés de la conv ──────────────────
  const loadPinnedMessages = useCallback(async (convId: string) => {
    const supabase = createClient();
    const { data } = await supabase
      .from("pinned_messages")
      .select("conversation_id, message_id, pinned_by, pinned_at")
      .eq("conversation_id", convId)
      .order("pinned_at", { ascending: false });
    if (data) setPinnedMessages(data as PinnedMessage[]);
  }, []);

  // ── Charge attachments + reactions de la conv ────────────────
  const loadAttachmentsAndReactions = useCallback(async (convId: string) => {
    const supabase = createClient();
    const { data: msgs } = await supabase
      .from("messages")
      .select("id")
      .eq("conversation_id", convId)
      .limit(500);
    const ids = ((msgs ?? []) as MessageIdRow[]).map((m) => m.id);
    if (ids.length === 0) {
      setAttachmentsByMsg({});
      setReactionsByMsg({});
      return;
    }
    const [attsRes, reactsRes] = await Promise.all([
      supabase
        .from("message_attachments")
        .select("id, message_id, storage_path, mime_type, size_bytes, original_name, width, height, created_at")
        .in("message_id", ids),
      supabase
        .from("message_reactions")
        .select("message_id, user_id, emoji, created_at")
        .in("message_id", ids),
    ]);
    const aMap: Record<string, MessageAttachment[]> = {};
    for (const a of (attsRes.data ?? []) as MessageAttachment[]) {
      (aMap[a.message_id] ??= []).push(a);
    }
    const rMap: Record<string, MessageReaction[]> = {};
    for (const r of (reactsRes.data ?? []) as MessageReaction[]) {
      (rMap[r.message_id] ??= []).push(r);
    }
    setAttachmentsByMsg(aMap);
    setReactionsByMsg(rMap);
  }, []);

  // Charge messages quand selectedId change + mark as read
  useEffect(() => {
    if (!selectedId) {
      setMessages([]);
      setLiveParticipants([]);
      setAttachmentsByMsg({});
      setReactionsByMsg({});
      setPinnedMessages([]);
      setReplyTo(null);
      return;
    }
    void loadMessages(selectedId);
    void loadLiveParticipants(selectedId);
    void loadAttachmentsAndReactions(selectedId);
    void loadPinnedMessages(selectedId);
    setReplyTo(null);
    void markConversationRead(selectedId);
    // Optimistic : reset unread localement
    setConversations((prev) =>
      prev.map((c) =>
        c.id === selectedId
          ? { ...c, unread_count: 0, last_read_at: new Date().toISOString() }
          : c
      )
    );
  }, [selectedId, loadMessages, loadLiveParticipants, loadAttachmentsAndReactions, loadPinnedMessages]);

  // ── Realtime : reactions + attachments de la conv sélectionnée ──
  useEffect(() => {
    if (!selectedId) return;
    const supabase = createClient();
    const id = instanceIdRef.current;

    const reactCh = supabase.channel(`live-react:${selectedId}:${id}`);
    reactCh.on(
      "postgres_changes",
      { event: "*", schema: "public", table: "message_reactions" },
      (payload) => {
        if (payload.eventType === "INSERT") {
          const r = payload.new as MessageReaction;
          setReactionsByMsg((prev) => {
            const cur = prev[r.message_id] ?? [];
            if (cur.some((x) => x.user_id === r.user_id && x.emoji === r.emoji))
              return prev;
            return { ...prev, [r.message_id]: [...cur, r] };
          });
        } else if (payload.eventType === "DELETE") {
          const old = payload.old as Partial<MessageReaction>;
          if (!old.message_id) return;
          setReactionsByMsg((prev) => {
            const cur = prev[old.message_id!] ?? [];
            const next = cur.filter(
              (x) => !(x.user_id === old.user_id && x.emoji === old.emoji)
            );
            return { ...prev, [old.message_id!]: next };
          });
        }
      }
    );
    reactCh.subscribe();

    const attCh = supabase.channel(`live-att:${selectedId}:${id}`);
    attCh.on(
      "postgres_changes",
      { event: "*", schema: "public", table: "message_attachments" },
      (payload) => {
        if (payload.eventType === "INSERT") {
          const a = payload.new as MessageAttachment;
          setAttachmentsByMsg((prev) => {
            const cur = prev[a.message_id] ?? [];
            if (cur.some((x) => x.id === a.id)) return prev;
            return { ...prev, [a.message_id]: [...cur, a] };
          });
        } else if (payload.eventType === "DELETE") {
          const old = payload.old as Partial<MessageAttachment>;
          if (!old.id || !old.message_id) return;
          setAttachmentsByMsg((prev) => {
            const cur = prev[old.message_id!] ?? [];
            return {
              ...prev,
              [old.message_id!]: cur.filter((x) => x.id !== old.id),
            };
          });
        }
      }
    );
    attCh.subscribe();

    const pinCh = supabase.channel(`live-pin:${selectedId}:${id}`);
    pinCh.on(
      "postgres_changes",
      {
        event: "*",
        schema: "public",
        table: "pinned_messages",
        filter: `conversation_id=eq.${selectedId}`,
      },
      (payload) => {
        if (payload.eventType === "INSERT") {
          const p = payload.new as PinnedMessage;
          setPinnedMessages((prev) => {
            if (prev.some((x) => x.message_id === p.message_id)) return prev;
            return [p, ...prev];
          });
        } else if (payload.eventType === "DELETE") {
          const old = payload.old as Partial<PinnedMessage>;
          if (!old.message_id) return;
          setPinnedMessages((prev) =>
            prev.filter((x) => x.message_id !== old.message_id)
          );
        }
      }
    );
    pinCh.subscribe();

    return () => {
      void supabase.removeChannel(reactCh);
      void supabase.removeChannel(attCh);
      void supabase.removeChannel(pinCh);
    };
  }, [selectedId]);

  // ── Realtime : participants de la conv sélectionnée (read receipts live) ──
  useEffect(() => {
    if (!selectedId) return;
    const supabase = createClient();
    const ch = supabase.channel(`live-parts:${selectedId}:${instanceIdRef.current}`);
    ch.on(
      "postgres_changes",
      {
        event: "*",
        schema: "public",
        table: "conversation_participants",
        filter: `conversation_id=eq.${selectedId}`,
      },
      (payload) => {
        if (payload.eventType === "UPDATE" || payload.eventType === "INSERT") {
          const row = payload.new as { user_id: string; last_read_at: string | null };
          setLiveParticipants((prev) => {
            const idx = prev.findIndex((p) => p.user_id === row.user_id);
            if (idx === -1) {
              // Nouveau participant : recharge tout (pour récupérer profil)
              void loadLiveParticipants(selectedId);
              return prev;
            }
            const next = [...prev];
            next[idx] = { ...next[idx], last_read_at: row.last_read_at };
            return next;
          });
        } else if (payload.eventType === "DELETE") {
          const old = payload.old as { user_id?: string };
          if (old.user_id) {
            setLiveParticipants((prev) =>
              prev.filter((p) => p.user_id !== old.user_id)
            );
          }
        }
      }
    );
    ch.subscribe();
    return () => {
      void supabase.removeChannel(ch);
    };
  }, [selectedId, loadLiveParticipants]);

  // ── Realtime : conversations + messages ──────────────────────
  useEffect(() => {
    const supabase = createClient();
    const id = instanceIdRef.current;

    // Channel messages : on filtre côté handler (impossible de joindre conversations en filter)
    const msgCh = supabase.channel(`msg-shell:${viewerId}:${id}`);
    msgCh.on(
      "postgres_changes",
      { event: "*", schema: "public", table: "messages" },
      (payload) => {
        if (payload.eventType === "INSERT") {
          const m = payload.new as MessageRow;
          // Si la conv est dans ma liste, j'affiche
          setConversations((prev) =>
            prev.map((c) =>
              c.id === m.conversation_id
                ? {
                    ...c,
                    last_message_at: m.created_at,
                    last_message_preview: m.body.slice(0, 200),
                    last_message_sender_id: m.sender_id,
                    unread_count:
                      m.sender_id !== viewerId && c.id !== selectedId
                        ? c.unread_count + 1
                        : c.unread_count,
                  }
                : c
            )
          );
          if (m.conversation_id === selectedId) {
            setMessages((prev) => {
              if (prev.some((x) => x.id === m.id)) return prev;
              return [...prev, m];
            });
            // Auto-mark read si la conv est ouverte et le sender n'est pas moi
            if (m.sender_id !== viewerId) {
              void markConversationRead(selectedId);
            }
          }
        } else if (payload.eventType === "UPDATE") {
          const m = payload.new as MessageRow;
          if (m.conversation_id === selectedId) {
            setMessages((prev) => prev.map((x) => (x.id === m.id ? m : x)));
          }
        } else if (payload.eventType === "DELETE") {
          const old = payload.old as { id?: string; conversation_id?: string };
          if (old.conversation_id === selectedId && old.id) {
            setMessages((prev) => prev.filter((x) => x.id !== old.id));
          }
        }
      }
    );
    msgCh.subscribe();

    // Channel conversations : refresh sur insert/update
    const convCh = supabase.channel(`conv-shell:${viewerId}:${id}`);
    convCh.on(
      "postgres_changes",
      { event: "*", schema: "public", table: "conversations" },
      () => {
        void refreshConversations();
      }
    );
    convCh.subscribe();

    // Channel participants : si je suis ajouté à une conv, refresh
    const partCh = supabase.channel(`part-shell:${viewerId}:${id}`);
    partCh.on(
      "postgres_changes",
      {
        event: "*",
        schema: "public",
        table: "conversation_participants",
        filter: `user_id=eq.${viewerId}`,
      },
      () => {
        void refreshConversations();
      }
    );
    partCh.subscribe();

    return () => {
      supabase.removeChannel(msgCh);
      supabase.removeChannel(convCh);
      supabase.removeChannel(partCh);
    };
  }, [viewerId, selectedId, refreshConversations]);

  // ── Counts pour les tabs ─────────────────────────────────────
  const counts = useMemo(() => {
    let total = 0;
    let unread = 0;
    let pinned = 0;
    let archived = 0;
    for (const c of conversations) {
      if (c.archived_at) {
        archived++;
        continue;
      }
      total++;
      if (c.unread_count > 0) unread++;
      if (c.pinned_at) pinned++;
    }
    return { total, unread, pinned, archived };
  }, [conversations]);

  // ── Actions de conversation ──────────────────────────────────
  // ── Raccourci global Cmd/Ctrl+K → ouvre la recherche ──────────
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === "k") {
        e.preventDefault();
        setSearchOpen(true);
      }
    };
    document.addEventListener("keydown", onKey);
    return () => document.removeEventListener("keydown", onKey);
  }, []);

  const handleSelect = useCallback(
    (id: string) => {
      const sp = new URLSearchParams(searchParams.toString());
      sp.set("c", id);
      router.replace(`${basePath}?${sp.toString()}`);
    },
    [router, basePath, searchParams]
  );

  const handleBack = useCallback(() => {
    const sp = new URLSearchParams(searchParams.toString());
    sp.delete("c");
    const qs = sp.toString();
    router.replace(qs ? `${basePath}?${qs}` : basePath);
  }, [router, basePath, searchParams]);

  const handleSend = useCallback(
    async (body: string, files: File[]) => {
      if (!selectedId) return;
      const supabase = createClient();
      const hasFiles = files.length > 0;

      // 1) Upload des fichiers (si présents) AVANT le message, dans
      //    {conv_id}/{batch_id}/{filename}
      const batchId =
        typeof crypto !== "undefined" && "randomUUID" in crypto
          ? crypto.randomUUID()
          : Math.random().toString(36).slice(2);
      const uploaded: {
        path: string;
        file: File;
        width?: number;
        height?: number;
      }[] = [];

      if (hasFiles) {
        for (const f of files) {
          const safeName = f.name.replace(/[^\w.\-]/g, "_");
          const path = `${selectedId}/${batchId}/${safeName}`;
          const { error: upErr } = await supabase.storage
            .from(ATTACH_BUCKET)
            .upload(path, f, {
              cacheControl: "3600",
              upsert: false,
              contentType: f.type || undefined,
            });
          if (upErr) {
            // Cleanup partiel et on remonte l'erreur
            for (const u of uploaded) {
              await supabase.storage.from(ATTACH_BUCKET).remove([u.path]);
            }
            throw new Error(`Upload échoué : ${upErr.message}`);
          }

          // Calcule width/height pour images via FileReader + Image
          let width: number | undefined;
          let height: number | undefined;
          if (f.type.startsWith("image/")) {
            try {
              const dim = await readImageDimensions(f);
              width = dim.width;
              height = dim.height;
            } catch {
              /* ignore */
            }
          }
          uploaded.push({ path, file: f, width, height });
        }
      }

      // 2) Envoi du message texte (peut être vide si attachments seuls)
      const placeholderBody = body.length > 0 ? body : "📎";
      let createdMessageId: string | null = null;
      try {
        // sendMessage RPC retourne l'id via le RPC (mais notre wrapper ne le
        // retourne pas). On a besoin de l'id pour lier les attachments.
        // Utilisation directe du RPC ici pour récupérer l'id.
        const { data: msgId, error: rpcErr } = await supabase.rpc(
          "send_message",
          {
            p_conversation_id: selectedId,
            p_body: placeholderBody,
            p_reply_to: replyTo?.id ?? null,
          }
        );
        if (rpcErr) throw new Error(rpcErr.message);
        createdMessageId = msgId as string;
      } catch (err) {
        // Cleanup uploads en cas d'échec
        for (const u of uploaded) {
          await supabase.storage.from(ATTACH_BUCKET).remove([u.path]);
        }
        throw err;
      }

      // 3) Insert des lignes attachments
      if (createdMessageId && uploaded.length > 0) {
        try {
          await insertAttachments(
            uploaded.map((u) => ({
              message_id: createdMessageId!,
              storage_path: u.path,
              mime_type: u.file.type || "application/octet-stream",
              size_bytes: u.file.size,
              original_name: u.file.name,
              width: u.width ?? null,
              height: u.height ?? null,
            }))
          );
        } catch (err) {
          // Le message est envoyé mais pas les attachments — on log seulement
          console.warn("Échec insert attachments:", err);
        }
      }

      setReplyTo(null);
    },
    [selectedId, replyTo]
  );

  const handleTogglePinMessage = useCallback(
    async (messageId: string) => {
      if (!selectedId) return;
      // Optimistic
      const wasPinned = pinnedMessages.some(
        (p) => p.message_id === messageId
      );
      if (wasPinned) {
        setPinnedMessages((prev) =>
          prev.filter((p) => p.message_id !== messageId)
        );
      } else {
        setPinnedMessages((prev) => [
          {
            conversation_id: selectedId,
            message_id: messageId,
            pinned_by: viewerId,
            pinned_at: new Date().toISOString(),
          },
          ...prev,
        ]);
      }
      try {
        await togglePinnedMessage({
          conversation_id: selectedId,
          message_id: messageId,
        });
      } catch (err) {
        // Rollback
        if (wasPinned) {
          setPinnedMessages((prev) => [
            {
              conversation_id: selectedId,
              message_id: messageId,
              pinned_by: viewerId,
              pinned_at: new Date().toISOString(),
            },
            ...prev,
          ]);
        } else {
          setPinnedMessages((prev) =>
            prev.filter((p) => p.message_id !== messageId)
          );
        }
      }
    },
    [selectedId, pinnedMessages, viewerId]
  );

  const handleToggleReaction = useCallback(
    async (messageId: string, emoji: string) => {
      // Optimistic
      const existed = (reactionsByMsg[messageId] ?? []).some(
        (r) => r.user_id === viewerId && r.emoji === emoji
      );
      setReactionsByMsg((prev) => {
        const cur = prev[messageId] ?? [];
        if (existed) {
          return {
            ...prev,
            [messageId]: cur.filter(
              (r) => !(r.user_id === viewerId && r.emoji === emoji)
            ),
          };
        }
        return {
          ...prev,
          [messageId]: [
            ...cur,
            {
              message_id: messageId,
              user_id: viewerId,
              emoji,
              created_at: new Date().toISOString(),
            },
          ],
        };
      });
      try {
        await toggleReaction({ message_id: messageId, emoji });
      } catch (err) {
        // Rollback en cas d'erreur
        setReactionsByMsg((prev) => {
          const cur = prev[messageId] ?? [];
          if (!existed) {
            return {
              ...prev,
              [messageId]: cur.filter(
                (r) => !(r.user_id === viewerId && r.emoji === emoji)
              ),
            };
          }
          return {
            ...prev,
            [messageId]: [
              ...cur,
              {
                message_id: messageId,
                user_id: viewerId,
                emoji,
                created_at: new Date().toISOString(),
              },
            ],
          };
        });
      }
    },
    [reactionsByMsg, viewerId]
  );

  const handleTogglePin = useCallback(() => {
    if (!selected) return;
    const next = !selected.pinned_at;
    setConversations((prev) =>
      prev.map((c) =>
        c.id === selected.id
          ? { ...c, pinned_at: next ? new Date().toISOString() : null }
          : c
      )
    );
    startTransition(() => {
      void setConversationPinned(selected.id, next);
    });
  }, [selected]);

  const handleToggleArchive = useCallback(() => {
    if (!selected) return;
    const next = !selected.archived_at;
    setConversations((prev) =>
      prev.map((c) =>
        c.id === selected.id
          ? { ...c, archived_at: next ? new Date().toISOString() : null }
          : c
      )
    );
    startTransition(() => {
      void setConversationArchived(selected.id, next);
    });
    if (next) handleBack();
  }, [selected, handleBack]);

  const handleToggleMute = useCallback(() => {
    if (!selected) return;
    const next = !selected.muted;
    setConversations((prev) =>
      prev.map((c) => (c.id === selected.id ? { ...c, muted: next } : c))
    );
    startTransition(() => {
      void setConversationMuted(selected.id, next);
    });
  }, [selected]);

  const handleLeave = useCallback(async () => {
    if (!selected) return;
    const id = selected.id;
    // Optimistic : retire de la liste + désélectionne
    setConversations((prev) => prev.filter((c) => c.id !== id));
    handleBack();
    try {
      await leaveConversation(id);
    } catch (err) {
      // En cas d'erreur, on resync depuis la BDD
      void refreshConversations();
      throw err;
    }
  }, [selected, handleBack, refreshConversations]);

  const handleDeleteForAll = useCallback(async () => {
    if (!selected) return;
    const id = selected.id;
    setConversations((prev) => prev.filter((c) => c.id !== id));
    handleBack();
    try {
      await deleteConversation(id);
    } catch (err) {
      void refreshConversations();
      throw err;
    }
  }, [selected, handleBack, refreshConversations]);

  const handleEdit = useCallback(async (msg: MessageRow, body: string) => {
    setMessages((prev) =>
      prev.map((m) =>
        m.id === msg.id ? { ...m, body, edited_at: new Date().toISOString() } : m
      )
    );
    await editMessage({ message_id: msg.id, body });
  }, []);

  const handleDelete = useCallback(async (msg: MessageRow) => {
    setMessages((prev) =>
      prev.map((m) =>
        m.id === msg.id
          ? { ...m, deleted_at: new Date().toISOString(), body: "" }
          : m
      )
    );
    await deleteMessage(msg.id);
  }, []);

  // ── Disabled composer ? (classe annonce non writable + stagiaire) ─
  const composerDisabled = useMemo(() => {
    if (!selected) return false;
    if (
      selected.kind === "group" &&
      selected.scope === "class" &&
      !selected.class_writable &&
      viewerRole === "student"
    ) {
      return true;
    }
    return false;
  }, [selected, viewerRole]);

  // ── Rendu ────────────────────────────────────────────────────
  return (
    <div className="h-[calc(100vh-8rem)] md:h-[calc(100vh-9rem)] -mx-4 md:-mx-8 -my-6 md:-my-10 grid md:grid-cols-[320px_1fr] bg-white border-y md:border border-navy-100 md:rounded-2xl md:overflow-hidden md:shadow-soft">
      {/* Sidebar */}
      <div
        className={cn(
          "h-full overflow-hidden",
          selectedId && "hidden md:block"
        )}
      >
        {loadingList ? (
          <ListSkeleton />
        ) : (
          <ConversationsList
            conversations={conversations}
            selectedId={selectedId}
            onSelect={handleSelect}
            onNewMessage={() => setNewOpen(true)}
            onOpenGlobalSearch={() => setSearchOpen(true)}
            totalCount={counts.total}
            unreadCount={counts.unread}
            pinnedCount={counts.pinned}
            archivedCount={counts.archived}
          />
        )}
      </div>

      {/* Thread */}
      <div
        className={cn(
          "h-full overflow-hidden",
          !selectedId && "hidden md:flex md:items-center md:justify-center"
        )}
      >
        {selected ? (
          <MessageThreadV2
            conversation={selected}
            messages={messages}
            viewerId={viewerId}
            viewerRole={viewerRole}
            participants={participants}
            liveParticipants={liveParticipants}
            attachmentsByMsg={attachmentsByMsg}
            reactionsByMsg={reactionsByMsg}
            onToggleReaction={handleToggleReaction}
            pinnedMessages={pinnedMessages}
            onTogglePinMessage={handleTogglePinMessage}
            replyTo={replyTo}
            onSetReplyTo={setReplyTo}
            onTogglePin={handleTogglePin}
            onToggleArchive={handleToggleArchive}
            onToggleMute={handleToggleMute}
            onLeave={handleLeave}
            onDeleteForAll={
              viewerRole === "admin" || viewerRole === "super_admin"
                ? handleDeleteForAll
                : undefined
            }
            onEdit={handleEdit}
            onDelete={handleDelete}
            onBack={handleBack}
            composer={
              <MessageComposer
                disabled={composerDisabled}
                disabledReason="Cette classe est en mode annonce. Seuls les formateurs et admins peuvent écrire."
                placeholder={
                  replyTo
                    ? "Répondre…"
                    : selected.kind === "dm"
                      ? `Écrire à ${conversationTitle(selected)}…`
                      : selected.scope === "class"
                        ? "Écrire à la classe…"
                        : selected.scope === "admin_team"
                          ? "Écrire à l'équipe admin…"
                          : "Écrire…"
                }
                onSend={handleSend}
                conversationId={selected.id}
                viewerId={viewerId}
                viewerName={viewerName}
              />
            }
          />
        ) : (
          <ThreadEmptyState onNew={() => setNewOpen(true)} />
        )}
      </div>

      {/* Modal Nouveau message */}
      <NewMessageModal
        open={newOpen}
        onClose={() => setNewOpen(false)}
        onCreated={(id) => {
          handleSelect(id);
          // Refresh la liste car on vient d'ajouter une conv
          void refreshConversations();
        }}
      />

      {/* Modal recherche globale */}
      <MessageSearchModal
        open={searchOpen}
        onClose={() => setSearchOpen(false)}
        onPickConversation={(id) => handleSelect(id)}
        viewerId={viewerId}
      />
    </div>
  );
}

// ── States ────────────────────────────────────────────────────

function ListSkeleton() {
  return (
    <div className="bg-white border-r border-navy-100 h-full p-4 space-y-3 animate-pulse">
      <div className="h-6 w-1/2 rounded bg-navy-50" />
      <div className="h-9 rounded-lg bg-navy-50" />
      <div className="h-7 w-2/3 rounded bg-navy-50" />
      <div className="space-y-2 mt-4">
        {[0, 1, 2, 3].map((i) => (
          <div key={i} className="flex items-start gap-3 py-2">
            <div className="h-10 w-10 rounded-xl bg-navy-50" />
            <div className="flex-1 space-y-1.5 pt-1">
              <div className="h-3 w-3/4 rounded bg-navy-50" />
              <div className="h-2.5 w-full rounded bg-navy-50/70" />
              <div className="h-2 w-16 rounded bg-navy-50/50 mt-1" />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function ThreadEmptyState({ onNew }: { onNew: () => void }) {
  return (
    <div className="text-center max-w-md px-6">
      <div className="mx-auto h-16 w-16 rounded-2xl bg-gradient-to-br from-navy-50 via-white to-gold-50 border border-navy-100 flex items-center justify-center shadow-soft">
        <MessageCircle className="h-7 w-7 text-navy-400" />
      </div>
      <h3 className="mt-5 font-display text-lg font-semibold text-navy-950">
        Choisissez une conversation
      </h3>
      <p className="mt-2 text-[13px] text-slate-500 leading-relaxed">
        Sélectionnez un échange dans la colonne de gauche, ou démarrez-en un
        nouveau pour contacter un formateur, l&apos;équipe admin ou une classe.
      </p>
      <button
        type="button"
        onClick={onNew}
        className={cn(
          "mt-5 inline-flex items-center gap-1.5 px-4 py-2 rounded-lg text-[13px] font-semibold",
          "bg-navy-900 text-white hover:bg-navy-950 shadow-sm",
          "transition-colors duration-150"
        )}
      >
        Nouveau message
      </button>
    </div>
  );
}
