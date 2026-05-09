"use client";
import { useEffect, useMemo, useRef, useState } from "react";
import {
  Pin,
  PinOff,
  Archive,
  ArchiveRestore,
  BellOff,
  Bell,
  CornerUpLeft,
  Edit3,
  Trash2,
  X,
  Check,
  Loader2,
  Reply,
  MoreHorizontal,
  LogOut,
  AlertTriangle,
  Pin as PinIcon,
} from "lucide-react";
import { cn } from "@/lib/utils";
import {
  bucketMessagesByDayAndSender,
  conversationTitle,
  conversationInitials,
  conversationAvatarSeed,
  conversationKindLabel,
  conversationKindTone,
  avatarTone,
  initials,
  formatHourMinute,
  relativeTimeFr,
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
import { TypingIndicator } from "@/components/messaging/typing-indicator";
import { ReadReceipts } from "@/components/messaging/read-receipts";
import { AttachmentPreview } from "@/components/messaging/attachment-preview";
import { MessageReactions } from "@/components/messaging/message-reactions";
import { EmojiPicker } from "@/components/messaging/emoji-picker";
import { PinnedMessagesPanel } from "@/components/messaging/pinned-messages-panel";
import { Smile } from "lucide-react";

interface Props {
  conversation: ConversationSummary;
  messages: MessageRow[];
  viewerId: string;
  /** Rôle du viewer — pour afficher l'option "Supprimer pour tous" si staff. */
  viewerRole: "student" | "trainer" | "admin" | "super_admin";
  /** Map id → profil pour résoudre les noms/avatars des autres expéditeurs. */
  participants: Record<string, MinimalProfile>;
  /** Liste des participants de la conv (avec last_read_at) — pour read receipts. */
  liveParticipants: ParticipantWithReadState[];
  /** Pièces jointes par message_id */
  attachmentsByMsg: Record<string, MessageAttachment[]>;
  /** Réactions par message_id */
  reactionsByMsg: Record<string, MessageReaction[]>;
  /** Toggle d'une réaction (mode optimistic dans le shell) */
  onToggleReaction: (messageId: string, emoji: string) => Promise<void>;
  /** Liste des messages épinglés de cette conversation */
  pinnedMessages: PinnedMessage[];
  /** Toggle pin sur un message */
  onTogglePinMessage: (messageId: string) => Promise<void>;
  /** Action d'envoi appelée par le composer (passé en props). */
  composer: React.ReactNode;
  /** Reply-to active (le composer la lit) */
  replyTo: MessageRow | null;
  onSetReplyTo: (msg: MessageRow | null) => void;
  // ── Actions de tête ──
  onTogglePin: () => void;
  onToggleArchive: () => void;
  onToggleMute: () => void;
  /** Quitte la conv (retire le viewer des participants). */
  onLeave: () => Promise<void>;
  /** Supprime la conv pour tous (admin / owner uniquement). */
  onDeleteForAll?: () => Promise<void>;
  // ── Actions message ──
  onEdit: (msg: MessageRow, body: string) => Promise<void>;
  onDelete: (msg: MessageRow) => Promise<void>;
  // ── Mobile back ──
  onBack?: () => void;
}

/**
 * Thread de messages v2 — bulles premium avec :
 *   - séparateurs jour
 *   - groupage messages consécutifs même auteur (avatar montré au 1er)
 *   - replies inline avec preview
 *   - hover : barre actions (répondre, éditer, supprimer)
 *   - animations entrée subtiles
 */
export function MessageThreadV2({
  conversation,
  messages,
  viewerId,
  viewerRole,
  participants,
  liveParticipants,
  attachmentsByMsg,
  reactionsByMsg,
  onToggleReaction,
  pinnedMessages,
  onTogglePinMessage,
  composer,
  replyTo,
  onSetReplyTo,
  onTogglePin,
  onToggleArchive,
  onToggleMute,
  onLeave,
  onDeleteForAll,
  onEdit,
  onDelete,
  onBack,
}: Props) {
  const buckets = useMemo(
    () => bucketMessagesByDayAndSender(messages),
    [messages]
  );
  const messagesById = useMemo(() => {
    const m: Record<string, MessageRow> = {};
    for (const msg of messages) m[msg.id] = msg;
    return m;
  }, [messages]);
  const pinnedIds = useMemo(
    () => new Set(pinnedMessages.map((p) => p.message_id)),
    [pinnedMessages]
  );
  const scrollRef = useRef<HTMLDivElement>(null);
  const lastMessageId = messages[messages.length - 1]?.id;

  // Auto-scroll vers le bas à l'arrivée d'un nouveau message
  useEffect(() => {
    const el = scrollRef.current;
    if (!el) return;
    el.scrollTo({ top: el.scrollHeight, behavior: "smooth" });
  }, [lastMessageId]);

  return (
    <div className="flex flex-col h-full bg-ivory">
      {/* En-tête conversation */}
      <ConversationHeader
        conversation={conversation}
        viewerRole={viewerRole}
        onBack={onBack}
        onTogglePin={onTogglePin}
        onToggleArchive={onToggleArchive}
        onToggleMute={onToggleMute}
        onLeave={onLeave}
        onDeleteForAll={onDeleteForAll}
      />

      {/* Panel des messages épinglés (collapsible) */}
      <PinnedMessagesPanel
        pins={pinnedMessages}
        messagesById={messagesById}
        profiles={participants}
        onUnpin={(id) => void onTogglePinMessage(id)}
      />

      {/* Flux de messages */}
      <div
        ref={scrollRef}
        className="flex-1 overflow-y-auto overscroll-contain px-3 sm:px-6 py-4 space-y-6"
      >
        {messages.length === 0 ? (
          <EmptyConversation conversation={conversation} />
        ) : (
          buckets.map((bucket) => (
            <section key={bucket.dayKey}>
              <DayDivider label={bucket.label} />
              <div className="space-y-3">
                {bucket.groups.map((g, gi) => (
                  <MessageGroupBlock
                    key={`${bucket.dayKey}-${gi}`}
                    group={g}
                    viewerId={viewerId}
                    profile={participants[g.senderId]}
                    allMessages={messages}
                    attachmentsByMsg={attachmentsByMsg}
                    reactionsByMsg={reactionsByMsg}
                    pinnedIds={pinnedIds}
                    onReply={onSetReplyTo}
                    onEdit={onEdit}
                    onDelete={onDelete}
                    onToggleReaction={onToggleReaction}
                    onTogglePinMessage={onTogglePinMessage}
                  />
                ))}
              </div>
            </section>
          ))
        )}
      </div>

      {/* Read receipts (sous le dernier message envoyé par le viewer) */}
      <ReadReceipts
        conversationKind={conversation.kind}
        messages={messages}
        participants={liveParticipants}
        viewerId={viewerId}
      />

      {/* Typing indicator (X écrit…) */}
      <TypingIndicator
        conversationId={conversation.id}
        viewerId={viewerId}
      />

      {/* Reply preview */}
      {replyTo && (
        <ReplyPreview
          message={replyTo}
          profile={participants[replyTo.sender_id]}
          onCancel={() => onSetReplyTo(null)}
        />
      )}

      {/* Composer (passé en prop pour découpler) */}
      <div className="border-t border-navy-100 bg-white">{composer}</div>
    </div>
  );
}

// ── En-tête conversation ─────────────────────────────────────

function ConversationHeader({
  conversation,
  viewerRole,
  onBack,
  onTogglePin,
  onToggleArchive,
  onToggleMute,
  onLeave,
  onDeleteForAll,
}: {
  conversation: ConversationSummary;
  viewerRole: "student" | "trainer" | "admin" | "super_admin";
  onBack?: () => void;
  onTogglePin: () => void;
  onToggleArchive: () => void;
  onToggleMute: () => void;
  onLeave: () => Promise<void>;
  onDeleteForAll?: () => Promise<void>;
}) {
  const c = conversation;
  const title = conversationTitle(c);
  const tone = avatarTone(conversationAvatarSeed(c));
  const kindLabel = conversationKindLabel(c);
  const kindTone = conversationKindTone(c);
  const [actionsOpen, setActionsOpen] = useState(false);
  const [confirmOpen, setConfirmOpen] = useState<null | "leave" | "delete">(null);
  const [actionPending, setActionPending] = useState(false);
  const isStaff = viewerRole === "admin" || viewerRole === "super_admin";

  const closeActions = () => setActionsOpen(false);

  const handleConfirm = async () => {
    if (!confirmOpen) return;
    setActionPending(true);
    try {
      if (confirmOpen === "leave") {
        await onLeave();
      } else if (confirmOpen === "delete" && onDeleteForAll) {
        await onDeleteForAll();
      }
      setConfirmOpen(null);
    } catch (err: any) {
      // L'erreur sera typiquement un toast au niveau parent ; on rouvre.
      setConfirmOpen(null);
    } finally {
      setActionPending(false);
    }
  };

  return (
    <header className="bg-white border-b border-navy-100 px-3 sm:px-5 py-3 flex items-center gap-3 backdrop-blur-md">
      {onBack && (
        <button
          type="button"
          onClick={onBack}
          aria-label="Retour"
          className="md:hidden h-9 w-9 rounded-lg flex items-center justify-center text-slate-500 hover:text-navy-900 hover:bg-navy-50 transition-colors"
        >
          <CornerUpLeft className="h-4 w-4" />
        </button>
      )}

      <span
        className={cn(
          "h-10 w-10 rounded-xl flex items-center justify-center shrink-0 font-semibold text-[12.5px]",
          tone
        )}
        aria-hidden
      >
        {c.kind === "group" && c.scope === "admin_team" ? "🛡️" : conversationInitials(c)}
      </span>

      <div className="flex-1 min-w-0">
        <h2 className="font-display text-[15px] font-semibold text-navy-950 truncate tracking-tight">
          {title}
        </h2>
        <div className="mt-0.5 flex items-center gap-1.5">
          <span
            className={cn(
              "inline-flex items-center rounded-md text-[9.5px] font-bold px-1.5 py-0.5 leading-none border tracking-wide",
              kindTone
            )}
          >
            {kindLabel}
          </span>
          {c.kind === "group" && (
            <span className="text-[10.5px] text-slate-500">
              {c.participants_count} participant{c.participants_count > 1 ? "s" : ""}
            </span>
          )}
          {c.muted && <BellOff className="h-3 w-3 text-slate-400" />}
        </div>
      </div>

      {/* Actions desktop : pin / mute / archive direct + menu pour delete */}
      <div className="hidden sm:flex items-center gap-0.5">
        <ActionButton
          onClick={onTogglePin}
          active={!!c.pinned_at}
          icon={c.pinned_at ? PinOff : Pin}
          label={c.pinned_at ? "Désépingler" : "Épingler"}
        />
        <ActionButton
          onClick={onToggleMute}
          active={c.muted}
          icon={c.muted ? Bell : BellOff}
          label={c.muted ? "Activer notifs" : "Couper notifs"}
        />
        <ActionButton
          onClick={onToggleArchive}
          active={!!c.archived_at}
          icon={c.archived_at ? ArchiveRestore : Archive}
          label={c.archived_at ? "Désarchiver" : "Archiver"}
        />
        <div className="relative">
          <button
            type="button"
            onClick={() => setActionsOpen((v) => !v)}
            aria-label="Plus d'actions"
            aria-expanded={actionsOpen}
            className="h-9 w-9 rounded-lg flex items-center justify-center text-slate-500 hover:text-navy-900 hover:bg-navy-50 transition-colors"
          >
            <MoreHorizontal className="h-4 w-4" />
          </button>
          {actionsOpen && (
            <div
              className="absolute right-0 top-full mt-1 w-56 bg-white border border-navy-100 rounded-xl shadow-float py-1 animate-notif-pop z-20"
              onClick={closeActions}
            >
              <MenuItem
                icon={LogOut}
                label="Quitter la conversation"
                onClick={() => setConfirmOpen("leave")}
              />
              {isStaff && onDeleteForAll && (
                <MenuItem
                  icon={Trash2}
                  label="Supprimer pour tous"
                  tone="danger"
                  onClick={() => setConfirmOpen("delete")}
                />
              )}
            </div>
          )}
        </div>
      </div>

      {/* Actions mobile (menu compact) */}
      <div className="sm:hidden relative">
        <button
          type="button"
          onClick={() => setActionsOpen((v) => !v)}
          aria-label="Plus d'actions"
          className="h-9 w-9 rounded-lg flex items-center justify-center text-slate-500 hover:text-navy-900 hover:bg-navy-50 transition-colors"
        >
          <MoreHorizontal className="h-4 w-4" />
        </button>
        {actionsOpen && (
          <div
            className="absolute right-0 top-full mt-1 w-56 bg-white border border-navy-100 rounded-xl shadow-float py-1 animate-notif-pop z-20"
            onClick={closeActions}
          >
            <MenuItem
              icon={c.pinned_at ? PinOff : Pin}
              label={c.pinned_at ? "Désépingler" : "Épingler"}
              onClick={onTogglePin}
            />
            <MenuItem
              icon={c.muted ? Bell : BellOff}
              label={c.muted ? "Activer notifs" : "Couper notifs"}
              onClick={onToggleMute}
            />
            <MenuItem
              icon={c.archived_at ? ArchiveRestore : Archive}
              label={c.archived_at ? "Désarchiver" : "Archiver"}
              onClick={onToggleArchive}
            />
            <div className="my-1 mx-2 h-px bg-navy-50" aria-hidden />
            <MenuItem
              icon={LogOut}
              label="Quitter la conversation"
              onClick={() => setConfirmOpen("leave")}
            />
            {isStaff && onDeleteForAll && (
              <MenuItem
                icon={Trash2}
                label="Supprimer pour tous"
                tone="danger"
                onClick={() => setConfirmOpen("delete")}
              />
            )}
          </div>
        )}
      </div>

      {/* Modal confirmation */}
      {confirmOpen && (
        <ConfirmDeleteDialog
          mode={confirmOpen}
          conversationTitle={title}
          pending={actionPending}
          onConfirm={handleConfirm}
          onCancel={() => setConfirmOpen(null)}
        />
      )}
    </header>
  );
}

// ── Dialog de confirmation ────────────────────────────────────

function ConfirmDeleteDialog({
  mode,
  conversationTitle,
  pending,
  onConfirm,
  onCancel,
}: {
  mode: "leave" | "delete";
  conversationTitle: string;
  pending: boolean;
  onConfirm: () => void;
  onCancel: () => void;
}) {
  // Fermeture sur Escape
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape" && !pending) onCancel();
    };
    document.addEventListener("keydown", onKey);
    return () => document.removeEventListener("keydown", onKey);
  }, [pending, onCancel]);

  const isDelete = mode === "delete";

  return (
    <>
      <div
        className="fixed inset-0 bg-navy-950/50 backdrop-blur-sm z-50 animate-notif-backdrop"
        onClick={() => !pending && onCancel()}
        aria-hidden
      />
      <div
        role="alertdialog"
        aria-modal="true"
        aria-labelledby="confirm-title"
        className={cn(
          "fixed z-50 left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2",
          "w-[min(92vw,440px)] bg-white rounded-2xl border border-navy-100 shadow-float",
          "animate-notif-pop p-5"
        )}
      >
        <div className="flex items-start gap-3">
          <div
            className={cn(
              "h-10 w-10 rounded-xl flex items-center justify-center shrink-0 border",
              isDelete
                ? "bg-rose-50 text-rose-700 border-rose-200"
                : "bg-amber-50 text-amber-800 border-amber-200"
            )}
            aria-hidden
          >
            <AlertTriangle className="h-4 w-4" />
          </div>
          <div className="flex-1 min-w-0">
            <h3
              id="confirm-title"
              className="font-display text-base font-semibold text-navy-950 tracking-tight"
            >
              {isDelete
                ? "Supprimer la conversation pour tous ?"
                : "Quitter cette conversation ?"}
            </h3>
            <p className="mt-1.5 text-[12.5px] text-slate-600 leading-relaxed">
              {isDelete ? (
                <>
                  La conversation{" "}
                  <span className="font-semibold text-navy-900">
                    « {conversationTitle} »
                  </span>{" "}
                  sera <strong>définitivement supprimée pour tous les
                  participants</strong>, ainsi que tout l&apos;historique des
                  messages. Cette action est irréversible.
                </>
              ) : (
                <>
                  Tu seras retiré·e de la conversation{" "}
                  <span className="font-semibold text-navy-900">
                    « {conversationTitle} »
                  </span>
                  . Les autres participants la conserveront. Tu pourras
                  toujours en démarrer une nouvelle plus tard.
                </>
              )}
            </p>
          </div>
        </div>

        <div className="mt-5 flex items-center justify-end gap-2">
          <button
            type="button"
            onClick={onCancel}
            disabled={pending}
            className={cn(
              "inline-flex items-center gap-1.5 px-3 py-2 rounded-lg text-[12.5px] font-semibold",
              "text-slate-600 bg-white border border-navy-100 hover:bg-navy-50 hover:text-navy-900",
              "transition-colors duration-150 disabled:opacity-50"
            )}
          >
            Annuler
          </button>
          <button
            type="button"
            onClick={onConfirm}
            disabled={pending}
            autoFocus
            className={cn(
              "inline-flex items-center gap-1.5 px-3 py-2 rounded-lg text-[12.5px] font-semibold text-white shadow-sm",
              "transition-colors duration-150 disabled:opacity-60",
              isDelete
                ? "bg-rose-600 hover:bg-rose-700"
                : "bg-navy-900 hover:bg-navy-950"
            )}
          >
            {pending ? (
              <Loader2 className="h-3.5 w-3.5 animate-spin" />
            ) : isDelete ? (
              <Trash2 className="h-3.5 w-3.5" />
            ) : (
              <LogOut className="h-3.5 w-3.5" />
            )}
            {isDelete ? "Supprimer pour tous" : "Quitter"}
          </button>
        </div>
      </div>
    </>
  );
}

function ActionButton({
  onClick,
  active,
  icon: Icon,
  label,
}: {
  onClick: () => void;
  active: boolean;
  icon: React.ComponentType<{ className?: string }>;
  label: string;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      title={label}
      aria-label={label}
      aria-pressed={active}
      className={cn(
        "h-9 w-9 rounded-lg flex items-center justify-center transition-colors duration-150",
        active
          ? "text-gold-700 bg-gold-50 hover:bg-gold-100"
          : "text-slate-500 hover:text-navy-900 hover:bg-navy-50"
      )}
    >
      <Icon className="h-4 w-4" />
    </button>
  );
}

function MenuItem({
  icon: Icon,
  label,
  onClick,
  tone = "neutral",
}: {
  icon: React.ComponentType<{ className?: string }>;
  label: string;
  onClick: () => void;
  tone?: "neutral" | "danger";
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={cn(
        "w-full flex items-center gap-2.5 px-3 py-2 text-[12.5px] font-medium transition-colors",
        tone === "danger"
          ? "text-rose-700 hover:bg-rose-50"
          : "text-navy-800 hover:bg-navy-50"
      )}
    >
      <Icon
        className={cn(
          "h-3.5 w-3.5",
          tone === "danger" ? "text-rose-600" : "text-slate-500"
        )}
      />
      {label}
    </button>
  );
}

// ── Séparateur de jour ───────────────────────────────────────

function DayDivider({ label }: { label: string }) {
  return (
    <div className="flex items-center gap-3 my-2">
      <span className="h-px flex-1 bg-navy-100" aria-hidden />
      <span className="text-[10.5px] font-bold uppercase tracking-[0.14em] text-slate-500">
        {label}
      </span>
      <span className="h-px flex-1 bg-navy-100" aria-hidden />
    </div>
  );
}

// ── Bloc d'un groupe de messages (même auteur) ───────────────

function MessageGroupBlock({
  group,
  viewerId,
  profile,
  allMessages,
  attachmentsByMsg,
  reactionsByMsg,
  pinnedIds,
  onReply,
  onEdit,
  onDelete,
  onToggleReaction,
  onTogglePinMessage,
}: {
  group: { senderId: string; senderRole: string; messages: MessageRow[] };
  viewerId: string;
  profile?: MinimalProfile;
  allMessages: MessageRow[];
  attachmentsByMsg: Record<string, MessageAttachment[]>;
  reactionsByMsg: Record<string, MessageReaction[]>;
  pinnedIds: Set<string>;
  onReply: (msg: MessageRow) => void;
  onEdit: (msg: MessageRow, body: string) => Promise<void>;
  onDelete: (msg: MessageRow) => Promise<void>;
  onToggleReaction: (messageId: string, emoji: string) => Promise<void>;
  onTogglePinMessage: (messageId: string) => Promise<void>;
}) {
  const mine = group.senderId === viewerId;
  const senderName = profile?.full_name || profile?.email || "Utilisateur";
  const tone = avatarTone(group.senderId);

  return (
    <div className={cn("flex gap-2", mine ? "flex-row-reverse" : "flex-row")}>
      {/* Avatar (montré une fois en haut du groupe) */}
      <div
        className={cn(
          "h-8 w-8 rounded-lg shrink-0 flex items-center justify-center text-[11px] font-semibold",
          tone,
          mine && "invisible"
        )}
        aria-hidden
      >
        {initials(senderName)}
      </div>

      <div
        className={cn(
          "flex-1 min-w-0 flex flex-col gap-1",
          mine ? "items-end" : "items-start"
        )}
      >
        {/* Nom + rôle (uniquement pour les autres + au 1er msg) */}
        {!mine && (
          <div className="flex items-center gap-1.5 text-[11px] px-1">
            <span className="font-semibold text-navy-900">{senderName}</span>
            <RoleChip role={group.senderRole} />
          </div>
        )}

        {/* Bulles successives */}
        {group.messages.map((m, i) => (
          <MessageBubble
            key={m.id}
            message={m}
            mine={mine}
            firstInGroup={i === 0}
            lastInGroup={i === group.messages.length - 1}
            replyTarget={
              m.reply_to_id
                ? allMessages.find((x) => x.id === m.reply_to_id) ?? null
                : null
            }
            attachments={attachmentsByMsg[m.id] ?? []}
            reactions={reactionsByMsg[m.id] ?? []}
            isPinned={pinnedIds.has(m.id)}
            viewerId={viewerId}
            onReply={() => onReply(m)}
            onEdit={onEdit}
            onDelete={() => onDelete(m)}
            onToggleReaction={(emoji) => onToggleReaction(m.id, emoji)}
            onTogglePin={() => onTogglePinMessage(m.id)}
          />
        ))}
      </div>
    </div>
  );
}

function RoleChip({ role }: { role: string }) {
  const map: Record<string, { label: string; tone: string }> = {
    admin: { label: "Admin", tone: "bg-rose-100 text-rose-700" },
    super_admin: { label: "Admin", tone: "bg-rose-100 text-rose-700" },
    trainer: { label: "Formateur", tone: "bg-emerald-100 text-emerald-700" },
    student: { label: "Stagiaire", tone: "bg-sky-100 text-sky-700" },
  };
  const conf = map[role] ?? { label: role, tone: "bg-slate-100 text-slate-700" };
  return (
    <span
      className={cn(
        "inline-flex items-center rounded text-[8.5px] font-bold px-1 py-0.5 leading-none uppercase tracking-wide",
        conf.tone
      )}
    >
      {conf.label}
    </span>
  );
}

// ── Bulle individuelle ───────────────────────────────────────

function MessageBubble({
  message,
  mine,
  firstInGroup,
  lastInGroup,
  replyTarget,
  attachments,
  reactions,
  isPinned,
  viewerId,
  onReply,
  onEdit,
  onDelete,
  onToggleReaction,
  onTogglePin,
}: {
  message: MessageRow;
  mine: boolean;
  firstInGroup: boolean;
  lastInGroup: boolean;
  replyTarget: MessageRow | null;
  attachments: MessageAttachment[];
  reactions: MessageReaction[];
  isPinned: boolean;
  viewerId: string;
  onReply: () => void;
  onEdit: (msg: MessageRow, body: string) => Promise<void>;
  onDelete: () => Promise<void>;
  onToggleReaction: (emoji: string) => Promise<void>;
  onTogglePin: () => Promise<void>;
}) {
  const [editing, setEditing] = useState(false);
  const [draft, setDraft] = useState(message.body);
  const [saving, setSaving] = useState(false);
  const [pickerOpen, setPickerOpen] = useState(false);
  const isDeleted = !!message.deleted_at;
  const hasBody = message.body && message.body.trim().length > 0;

  const radius = mine
    ? cn(
        "rounded-2xl",
        firstInGroup ? "rounded-tr-md" : "rounded-tr-2xl",
        lastInGroup ? "rounded-br-sm" : "rounded-br-2xl"
      )
    : cn(
        "rounded-2xl",
        firstInGroup ? "rounded-tl-md" : "rounded-tl-2xl",
        lastInGroup ? "rounded-bl-sm" : "rounded-bl-2xl"
      );

  const handleSaveEdit = async () => {
    const trimmed = draft.trim();
    if (!trimmed || trimmed === message.body) {
      setEditing(false);
      return;
    }
    setSaving(true);
    try {
      await onEdit(message, trimmed);
      setEditing(false);
    } catch {
      // garde l'édition active en cas d'échec
    } finally {
      setSaving(false);
    }
  };

  if (isDeleted) {
    return (
      <div
        className={cn(
          "max-w-[80%] sm:max-w-[70%] px-3.5 py-2 text-[12.5px] italic",
          mine ? "self-end" : "self-start",
          "text-slate-400 bg-slate-50/50 border border-slate-100 rounded-2xl"
        )}
      >
        Message supprimé
      </div>
    );
  }

  return (
    <div className={cn("group/msg relative max-w-[80%] sm:max-w-[70%]", mine ? "self-end" : "self-start")}>
      {/* Indicateur "épinglé" — petit ruban en haut */}
      {isPinned && (
        <div
          className={cn(
            "flex items-center gap-1 mb-1 text-[10px] font-bold uppercase tracking-wide text-gold-700",
            mine ? "justify-end" : "justify-start"
          )}
          aria-label="Épinglé"
        >
          <PinIcon className="h-2.5 w-2.5" />
          Épinglé
        </div>
      )}

      {/* Reply target preview */}
      {replyTarget && (
        <div
          className={cn(
            "mb-1 px-2.5 py-1.5 text-[11px] rounded-lg border-l-2 border-gold-400 bg-white/70 backdrop-blur-sm shadow-soft",
            mine ? "ml-6 text-right" : "mr-6 text-left"
          )}
        >
          <span className="block font-semibold text-navy-700 truncate">
            ↪ Réponse à
          </span>
          <span className="block text-slate-600 line-clamp-2 leading-snug">
            {replyTarget.deleted_at
              ? "Message supprimé"
              : replyTarget.body.slice(0, 200)}
          </span>
        </div>
      )}

      {/* Bulle (uniquement si body présent — attachments seuls = pas de bulle texte) */}
      {hasBody && <div
        className={cn(
          "px-3.5 py-2 text-[13px] leading-relaxed whitespace-pre-wrap break-words shadow-soft",
          radius,
          mine
            ? "bg-navy-900 text-white"
            : "bg-white text-navy-900 border border-navy-100"
        )}
        style={{
          animation: "notif-pop 200ms cubic-bezier(0.22, 1, 0.36, 1) both",
        }}
      >
        {editing ? (
          <div className="flex flex-col gap-2 min-w-[240px]">
            <textarea
              autoFocus
              value={draft}
              onChange={(e) => setDraft(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === "Enter" && !e.shiftKey) {
                  e.preventDefault();
                  handleSaveEdit();
                }
                if (e.key === "Escape") setEditing(false);
              }}
              rows={Math.min(8, draft.split("\n").length + 1)}
              className={cn(
                "rounded-md p-2 text-[13px] resize-none outline-none",
                mine
                  ? "bg-navy-950 text-white placeholder-slate-400"
                  : "bg-navy-50/40 text-navy-900 placeholder-slate-400"
              )}
            />
            <div className="flex items-center gap-1.5 justify-end">
              <button
                type="button"
                onClick={() => setEditing(false)}
                className={cn(
                  "h-7 px-2.5 rounded-md text-[11px] font-semibold",
                  mine
                    ? "text-white/70 hover:text-white hover:bg-white/10"
                    : "text-slate-500 hover:bg-navy-50"
                )}
              >
                Annuler
              </button>
              <button
                type="button"
                onClick={handleSaveEdit}
                disabled={saving}
                className={cn(
                  "h-7 px-2.5 rounded-md text-[11px] font-semibold flex items-center gap-1",
                  "bg-gold-500 text-navy-950 hover:bg-gold-600",
                  "transition-colors duration-150",
                  saving && "opacity-50"
                )}
              >
                {saving ? (
                  <Loader2 className="h-3 w-3 animate-spin" />
                ) : (
                  <Check className="h-3 w-3" />
                )}
                Enregistrer
              </button>
            </div>
          </div>
        ) : (
          message.body
        )}
      </div>}

      {/* Pièces jointes */}
      {attachments.length > 0 && (
        <AttachmentPreview
          attachments={attachments}
          align={mine ? "right" : "left"}
        />
      )}

      {/* Réactions */}
      {reactions.length > 0 && (
        <MessageReactions
          reactions={reactions}
          viewerId={viewerId}
          onToggle={(emoji) => void onToggleReaction(emoji)}
          align={mine ? "right" : "left"}
        />
      )}

      {/* Footer : timestamp + edited */}
      {lastInGroup && !editing && (
        <div
          className={cn(
            "mt-1 text-[10px] text-slate-400 font-medium tracking-wide flex items-center gap-1",
            mine ? "justify-end" : "justify-start"
          )}
        >
          <span>{formatHourMinute(new Date(message.created_at))}</span>
          {message.edited_at && (
            <span className="italic" title={`Édité ${relativeTimeFr(message.edited_at)}`}>
              · modifié
            </span>
          )}
          {mine && message.read_at && <span>· Lu</span>}
        </div>
      )}

      {/* Barre actions au hover */}
      {!editing && (
        <div
          className={cn(
            "absolute -top-3 flex items-center gap-0.5 rounded-lg bg-white border border-navy-100 shadow-soft p-0.5",
            "opacity-0 group-hover/msg:opacity-100 focus-within:opacity-100",
            (pickerOpen) && "opacity-100",
            "transition-opacity duration-150",
            mine ? "right-1" : "left-1"
          )}
        >
          <BubbleAction
            icon={Smile}
            label="Réagir"
            onClick={() => setPickerOpen((v) => !v)}
          />
          <BubbleAction icon={Reply} label="Répondre" onClick={onReply} />
          <BubbleAction
            icon={isPinned ? PinOff : PinIcon}
            label={isPinned ? "Désépingler" : "Épingler"}
            onClick={() => void onTogglePin()}
            tone={isPinned ? "active" : "neutral"}
          />
          {mine && (
            <BubbleAction
              icon={Edit3}
              label="Éditer"
              onClick={() => setEditing(true)}
            />
          )}
          {mine && (
            <BubbleAction
              icon={Trash2}
              label="Supprimer"
              onClick={onDelete}
              tone="danger"
            />
          )}
        </div>
      )}

      {/* Popover emoji picker */}
      {pickerOpen && (
        <EmojiPicker
          align={mine ? "right" : "left"}
          onPick={(emoji) => {
            void onToggleReaction(emoji);
          }}
          onClose={() => setPickerOpen(false)}
        />
      )}
    </div>
  );
}

function BubbleAction({
  icon: Icon,
  label,
  onClick,
  tone = "neutral",
}: {
  icon: React.ComponentType<{ className?: string }>;
  label: string;
  onClick: () => void;
  tone?: "neutral" | "danger" | "active";
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      title={label}
      aria-label={label}
      className={cn(
        "h-6 w-6 rounded flex items-center justify-center transition-colors",
        tone === "danger"
          ? "text-rose-500 hover:bg-rose-50"
          : tone === "active"
            ? "text-gold-700 bg-gold-50 hover:bg-gold-100"
            : "text-slate-500 hover:text-navy-900 hover:bg-navy-50"
      )}
    >
      <Icon className="h-3 w-3" />
    </button>
  );
}

// ── Reply preview au-dessus du composer ──────────────────────

function ReplyPreview({
  message,
  profile,
  onCancel,
}: {
  message: MessageRow;
  profile?: MinimalProfile;
  onCancel: () => void;
}) {
  const senderName = profile?.full_name || profile?.email || "Utilisateur";
  return (
    <div className="border-t border-navy-100 bg-gold-50/40 px-4 py-2 flex items-start gap-3 animate-notif-pop">
      <Reply className="h-3.5 w-3.5 text-gold-700 mt-0.5 shrink-0" />
      <div className="flex-1 min-w-0">
        <div className="text-[11px] font-semibold text-navy-800">
          Réponse à <span className="text-navy-950">{senderName}</span>
        </div>
        <div className="text-[12px] text-slate-600 line-clamp-1">
          {message.deleted_at ? "Message supprimé" : message.body}
        </div>
      </div>
      <button
        type="button"
        onClick={onCancel}
        aria-label="Annuler la réponse"
        className="h-6 w-6 rounded text-slate-500 hover:text-navy-900 hover:bg-white flex items-center justify-center transition-colors"
      >
        <X className="h-3.5 w-3.5" />
      </button>
    </div>
  );
}

// ── Empty conv (no messages yet) ─────────────────────────────

function EmptyConversation({ conversation }: { conversation: ConversationSummary }) {
  return (
    <div className="h-full flex items-center justify-center">
      <div className="text-center max-w-sm px-4">
        <div className="mx-auto h-14 w-14 rounded-2xl bg-gradient-to-br from-navy-50 via-white to-gold-50 border border-navy-100 flex items-center justify-center shadow-soft">
          <Reply className="h-5 w-5 text-navy-400" />
        </div>
        <h3 className="mt-4 font-display text-base font-semibold text-navy-950">
          {conversationTitle(conversation)}
        </h3>
        <p className="mt-1.5 text-[12.5px] text-slate-500 leading-relaxed">
          Aucun message pour le moment. Lance la conversation avec ton premier
          message ci-dessous.
        </p>
      </div>
    </div>
  );
}
