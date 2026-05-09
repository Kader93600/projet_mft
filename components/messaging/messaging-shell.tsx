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
} from "@/app/messages/actions";
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
} from "@/lib/messaging-types";

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
  const [loadingList, setLoadingList] = useState(true);
  const [newOpen, setNewOpen] = useState(false);
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
    if (!error && data) setMessages(data as MessageRow[]);

    // Charge les profils des sender uniques
    const ids = Array.from(new Set((data ?? []).map((m: any) => m.sender_id)));
    if (ids.length > 0) {
      const { data: profs } = await supabase
        .from("profiles")
        .select("id, full_name, email, role")
        .in("id", ids);
      if (profs) {
        const map: Record<string, MinimalProfile> = {};
        for (const p of profs as any[]) map[p.id] = p as MinimalProfile;
        setParticipants((prev) => ({ ...prev, ...map }));
      }
    }
  }, []);

  // ── Charge les participants (avec last_read_at) de la conv sélectionnée ──
  const loadLiveParticipants = useCallback(async (convId: string) => {
    const supabase = createClient();
    const { data: parts } = await supabase
      .from("conversation_participants")
      .select("user_id, last_read_at")
      .eq("conversation_id", convId);
    if (!parts) return;

    const ids = parts.map((p: any) => p.user_id);
    const { data: profs } = await supabase
      .from("profiles")
      .select("id, full_name, email, role")
      .in("id", ids);
    const profMap: Record<string, any> = {};
    for (const p of profs ?? []) profMap[(p as any).id] = p;

    const merged: ParticipantWithReadState[] = parts.map((p: any) => ({
      user_id: p.user_id,
      last_read_at: p.last_read_at,
      full_name: profMap[p.user_id]?.full_name ?? null,
      email: profMap[p.user_id]?.email ?? "",
      role: profMap[p.user_id]?.role ?? "",
    }));
    setLiveParticipants(merged);
  }, []);

  // Charge messages quand selectedId change + mark as read
  useEffect(() => {
    if (!selectedId) {
      setMessages([]);
      setLiveParticipants([]);
      setReplyTo(null);
      return;
    }
    void loadMessages(selectedId);
    void loadLiveParticipants(selectedId);
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
  }, [selectedId, loadMessages, loadLiveParticipants]);

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
    async (body: string) => {
      if (!selectedId) return;
      try {
        await sendMessage({
          conversation_id: selectedId,
          body,
          reply_to_id: replyTo?.id ?? null,
        });
        setReplyTo(null);
      } catch (err) {
        throw err;
      }
    },
    [selectedId, replyTo]
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
