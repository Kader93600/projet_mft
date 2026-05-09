"use client";
import { useMemo, useState } from "react";
import {
  Search,
  X,
  Pin,
  Inbox,
  MessageCircle,
  Users,
  Archive,
  SearchCheck,
} from "lucide-react";
import { cn } from "@/lib/utils";
import {
  filterConversations,
  type ConversationFilter,
  conversationTitle,
  conversationInitials,
  conversationAvatarSeed,
  conversationKindLabel,
  conversationKindTone,
  avatarTone,
  relativeTimeFr,
} from "@/lib/messaging-utils";
import type { ConversationSummary } from "@/lib/messaging-types";

interface Props {
  conversations: ConversationSummary[];
  selectedId: string | null;
  onSelect: (id: string) => void;
  onNewMessage: () => void;
  /** Ouvre la recherche globale dans tous les messages */
  onOpenGlobalSearch: () => void;
  /** Compteur affiché dans le tab "Tous" (= visibles non archivés) */
  totalCount: number;
  unreadCount: number;
  pinnedCount: number;
  archivedCount: number;
}

const TABS: {
  key: ConversationFilter;
  label: string;
  icon: React.ComponentType<{ className?: string }>;
}[] = [
  { key: "all", label: "Tous", icon: Inbox },
  { key: "unread", label: "Non lus", icon: MessageCircle },
  { key: "dm", label: "DM", icon: MessageCircle },
  { key: "groups", label: "Groupes", icon: Users },
  { key: "pinned", label: "Épinglés", icon: Pin },
  { key: "archived", label: "Archivés", icon: Archive },
];

/**
 * Sidebar des conversations : header (CTA Nouveau message) + recherche
 * + tabs filtre + liste scrollable. Animations fines, charte navy/gold.
 */
export function ConversationsList({
  conversations,
  selectedId,
  onSelect,
  onNewMessage,
  onOpenGlobalSearch,
  totalCount,
  unreadCount,
  pinnedCount,
  archivedCount,
}: Props) {
  const [filter, setFilter] = useState<ConversationFilter>("all");
  const [query, setQuery] = useState("");

  const filtered = useMemo(
    () => filterConversations(conversations, filter, query),
    [conversations, filter, query]
  );

  // Compte DM / Groupes parmi les non-archivées
  const { dmCount, groupCount } = useMemo(() => {
    let d = 0;
    let g = 0;
    for (const c of conversations) {
      if (c.archived_at) continue;
      if (c.kind === "dm") d++;
      else g++;
    }
    return { dmCount: d, groupCount: g };
  }, [conversations]);

  const counts: Record<ConversationFilter, number> = {
    all: totalCount,
    unread: unreadCount,
    pinned: pinnedCount,
    archived: archivedCount,
    dm: dmCount,
    groups: groupCount,
  };

  return (
    <div className="flex flex-col h-full bg-white border-r border-navy-100">
      {/* Header */}
      <div className="px-4 pt-5 pb-3 border-b border-navy-100">
        <div className="flex items-center justify-between gap-2">
          <h1 className="font-display text-lg font-semibold text-navy-950 tracking-tight">
            Messages
          </h1>
          <div className="flex items-center gap-1">
            <button
              type="button"
              onClick={onOpenGlobalSearch}
              aria-label="Rechercher dans tous les messages"
              title="Rechercher dans tous les messages"
              className={cn(
                "inline-flex items-center justify-center h-8 w-8 rounded-lg",
                "text-slate-500 hover:text-navy-900 hover:bg-navy-50",
                "transition-colors duration-150 ease-out",
                "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-navy-300"
              )}
            >
              <SearchCheck className="h-4 w-4" />
            </button>
            <button
              type="button"
              onClick={onNewMessage}
              className={cn(
                "inline-flex items-center gap-1.5 px-3 h-8 rounded-lg text-[12px] font-semibold",
                "bg-navy-900 text-white hover:bg-navy-950 shadow-sm",
                "transition-colors duration-150 ease-out",
                "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-gold-400"
              )}
            >
              <Users className="h-3.5 w-3.5" />
              Nouveau
            </button>
          </div>
        </div>

        {/* Recherche */}
        <div className="relative mt-3">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-400 pointer-events-none" />
          <input
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Rechercher…"
            className={cn(
              "w-full h-9 pl-9 pr-9 rounded-lg text-[13px]",
              "bg-navy-50/40 border border-navy-100",
              "placeholder:text-slate-400 text-navy-900",
              "outline-none transition-shadow duration-150",
              "focus:border-navy-300 focus:bg-white focus:shadow-ring-brand"
            )}
          />
          {query && (
            <button
              type="button"
              onClick={() => setQuery("")}
              aria-label="Effacer"
              className="absolute right-1.5 top-1/2 -translate-y-1/2 h-6 w-6 rounded-md text-slate-400 hover:text-navy-700 hover:bg-navy-50 flex items-center justify-center transition-colors"
            >
              <X className="h-3.5 w-3.5" />
            </button>
          )}
        </div>
      </div>

      {/* Tabs filtre */}
      <div className="px-2 py-2 border-b border-navy-100 flex gap-1 overflow-x-auto no-scrollbar">
        {TABS.map((t) => {
          const Icon = t.icon;
          const active = filter === t.key;
          const c = counts[t.key];
          return (
            <button
              key={t.key}
              type="button"
              onClick={() => setFilter(t.key)}
              aria-pressed={active}
              className={cn(
                "shrink-0 inline-flex items-center gap-1.5 h-7 px-2.5 rounded-full text-[11px] font-semibold",
                "transition-colors duration-150 ease-out border",
                active
                  ? "bg-navy-900 text-white border-navy-900"
                  : "bg-white text-slate-600 border-navy-100 hover:bg-navy-50 hover:text-navy-900"
              )}
            >
              <Icon className="h-3 w-3" />
              {t.label}
              {c > 0 && (
                <span
                  className={cn(
                    "inline-flex items-center justify-center min-w-[16px] h-4 px-1 rounded-full text-[9px] font-bold leading-none",
                    active
                      ? "bg-white/20 text-white"
                      : t.key === "unread"
                        ? "bg-gold-100 text-gold-800"
                        : "bg-navy-50 text-navy-700"
                  )}
                >
                  {c}
                </span>
              )}
            </button>
          );
        })}
      </div>

      {/* Liste */}
      <div className="flex-1 overflow-y-auto overscroll-contain">
        {filtered.length === 0 ? (
          <EmptyList filter={filter} hasQuery={!!query} />
        ) : (
          <ul className="divide-y divide-navy-50">
            {filtered.map((c) => (
              <li key={c.id}>
                <ConversationItem
                  c={c}
                  selected={selectedId === c.id}
                  onClick={() => onSelect(c.id)}
                />
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}

// ── Item ──────────────────────────────────────────────────────

function ConversationItem({
  c,
  selected,
  onClick,
}: {
  c: ConversationSummary;
  selected: boolean;
  onClick: () => void;
}) {
  const title = conversationTitle(c);
  const tone = avatarTone(conversationAvatarSeed(c));
  const inits = conversationInitials(c);
  const kindLabel = conversationKindLabel(c);
  const kindTone = conversationKindTone(c);
  const isUnread = c.unread_count > 0;

  return (
    <button
      type="button"
      onClick={onClick}
      className={cn(
        "group w-full text-left flex items-start gap-3 px-3 py-3",
        "transition-all duration-150 ease-out",
        "hover:bg-navy-50/50",
        selected && "bg-gold-50/40 hover:bg-gold-50/60",
        "focus-visible:outline-none focus-visible:bg-navy-50/60 focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-navy-300",
        "relative"
      )}
    >
      {/* Indicateur sélection : barre verticale gold */}
      {selected && (
        <span
          aria-hidden
          className="absolute left-0 top-1.5 bottom-1.5 w-0.5 rounded-r bg-gold-500"
        />
      )}

      {/* Avatar */}
      <span
        className={cn(
          "h-10 w-10 rounded-xl flex items-center justify-center shrink-0",
          "font-semibold text-[12.5px] tracking-wide",
          "transition-transform duration-150 ease-out group-hover:scale-105",
          tone
        )}
        aria-hidden
      >
        {c.kind === "group" && c.scope === "admin_team" ? (
          <span className="text-[16px]" aria-hidden>🛡️</span>
        ) : c.kind === "group" && c.scope === "class" ? (
          <Users className="h-4 w-4" />
        ) : (
          inits
        )}
      </span>

      {/* Contenu */}
      <div className="flex-1 min-w-0">
        <div className="flex items-center justify-between gap-2">
          <div className="min-w-0 flex items-center gap-2">
            <span
              className={cn(
                "truncate text-[13.5px] leading-snug",
                isUnread
                  ? "font-bold text-navy-950"
                  : "font-semibold text-navy-900"
              )}
            >
              {title}
            </span>
            {c.pinned_at && (
              <Pin className="h-3 w-3 text-gold-700 shrink-0" />
            )}
          </div>
          <span className="text-[10.5px] text-slate-400 font-medium tracking-wide shrink-0">
            {relativeTimeFr(c.last_message_at)}
          </span>
        </div>

        <div className="mt-0.5 flex items-center gap-1.5">
          <span
            className={cn(
              "inline-flex items-center rounded-md text-[9px] font-bold px-1.5 py-0.5 leading-none border tracking-wide",
              kindTone
            )}
          >
            {kindLabel}
          </span>
          {c.muted && (
            <span className="text-[10px] text-slate-400" title="Muet">
              🔕
            </span>
          )}
        </div>

        <p
          className={cn(
            "mt-1 text-[12px] leading-snug line-clamp-1",
            isUnread ? "text-navy-800 font-medium" : "text-slate-500"
          )}
        >
          {c.last_message_preview ?? (
            <span className="italic text-slate-400">Aucun message</span>
          )}
        </p>
      </div>

      {/* Pastille unread */}
      {isUnread && (
        <span className="shrink-0 self-center min-w-[20px] h-5 px-1.5 rounded-full bg-gold-500 text-navy-950 text-[10px] font-bold leading-none flex items-center justify-center shadow-[0_0_0_3px_rgba(159,226,32,0.20)]">
          {c.unread_count > 99 ? "99+" : c.unread_count}
        </span>
      )}
    </button>
  );
}

// ── Empty states ──────────────────────────────────────────────

function EmptyList({
  filter,
  hasQuery,
}: {
  filter: ConversationFilter;
  hasQuery: boolean;
}) {
  if (hasQuery) {
    return (
      <div className="px-4 py-12 text-center">
        <Search className="h-7 w-7 text-slate-300 mx-auto" />
        <p className="mt-3 text-[12px] text-slate-500">Aucun résultat</p>
      </div>
    );
  }
  const messages: Record<ConversationFilter, string> = {
    all: "Aucune conversation pour le moment. Démarre-en une avec « Nouveau ».",
    unread: "Toutes tes conversations sont lues.",
    pinned: "Aucune conversation épinglée.",
    archived: "Aucune conversation archivée.",
    dm: "Aucun message direct.",
    groups: "Aucun groupe.",
  };
  return (
    <div className="px-4 py-14 text-center">
      <Inbox className="h-7 w-7 text-slate-300 mx-auto" />
      <p className="mt-3 text-[12px] text-slate-500 leading-relaxed max-w-[220px] mx-auto">
        {messages[filter]}
      </p>
    </div>
  );
}
