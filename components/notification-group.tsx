"use client";
import { useState, type KeyboardEvent } from "react";
import { ChevronDown, X } from "lucide-react";
import { cn } from "@/lib/utils";
import {
  getNotificationStyle,
  relativeTimeFr,
} from "@/lib/notifications-icons";
import {
  NotificationItem,
  type NotificationRow,
} from "@/components/notification-item";
import type { NotificationGroup as Group } from "@/lib/notifications-grouping";

interface Props {
  group: Group;
  onSelectItem: (notif: NotificationRow) => void;
  onDeleteItem: (id: string) => void;
  /** Callback bulk : marquer tout le groupe comme lu (par défaut au clic). */
  onMarkGroupRead?: (ids: string[]) => void;
  /** Callback bulk : supprimer tout le groupe. */
  onDeleteGroup?: (ids: string[]) => void;
}

/**
 * Affiche un groupe de notifications proches (même type + même thread,
 * ou même type + même jour) en une seule ligne collapsable.
 * - Click sur la ligne du groupe → expand / collapse
 * - Click sur un item enfant → comportement standard (mark read + nav)
 */
export function NotificationGroupRow({
  group,
  onSelectItem,
  onDeleteItem,
  onMarkGroupRead,
  onDeleteGroup,
}: Props) {
  const [expanded, setExpanded] = useState(false);
  const style = getNotificationStyle(group.type);
  const Icon = style.icon;
  const hasUnread = group.unreadCount > 0;
  const ids = group.items.map((i) => i.id);

  const headline = (() => {
    // Sélection automatique d'une copie compacte selon le type
    const t = group.type;
    if (t === "message") return `${group.count} nouveaux messages`;
    if (t === "achievement" || t === "badge")
      return `${group.count} succès débloqués`;
    if (t === "course") return `${group.count} mises à jour de formation`;
    if (t === "quiz_result") return `${group.count} résultats de quiz`;
    if (t === "exam") return `${group.count} actualités d'examen`;
    if (t === "announcement") return `${group.count} annonces`;
    if (t === "coaching") return `${group.count} rendez-vous`;
    if (t === "certificate") return `${group.count} certificats`;
    return `${group.count} notifications ${style.label.toLowerCase()}`;
  })();

  const toggle = () => setExpanded((e) => !e);
  const onKey = (e: KeyboardEvent<HTMLDivElement>) => {
    if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      toggle();
    }
  };

  const handleDeleteAllInGroup = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (onDeleteGroup) onDeleteGroup(ids);
  };

  return (
    <div className="relative">
      {/* Tête de groupe */}
      <div
        role="button"
        tabIndex={0}
        onClick={toggle}
        onKeyDown={onKey}
        aria-expanded={expanded}
        aria-label={`${headline}${hasUnread ? `, ${group.unreadCount} non lue${group.unreadCount > 1 ? "s" : ""}` : ""}`}
        className={cn(
          "group/grouprow relative flex items-start gap-3 px-4 py-3.5 cursor-pointer outline-none",
          "transition-all duration-150 ease-out",
          "hover:bg-navy-50/50",
          "focus-visible:bg-navy-50/60 focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-navy-300",
          hasUnread && "bg-gold-50/40"
        )}
      >
        {/* Icône typée — avec stack effect (pile de cartes) */}
        <span className="relative shrink-0">
          <span
            aria-hidden
            className={cn(
              "absolute -top-1 left-1 h-9 w-9 rounded-xl border opacity-50",
              style.tone
            )}
          />
          <span
            aria-hidden
            className={cn(
              "absolute -top-0.5 left-0.5 h-9 w-9 rounded-xl border opacity-75",
              style.tone
            )}
          />
          <span
            className={cn(
              "relative h-9 w-9 rounded-xl border flex items-center justify-center",
              "transition-transform duration-150 ease-out group-hover/grouprow:scale-105",
              style.tone
            )}
          >
            <Icon className="h-4 w-4" />
          </span>
        </span>

        {/* Contenu */}
        <div className="flex-1 min-w-0 pr-7">
          <div className="flex items-start justify-between gap-2">
            <div
              className={cn(
                "text-[13.5px] leading-snug truncate flex items-center gap-2",
                hasUnread
                  ? "font-semibold text-navy-950"
                  : "font-medium text-navy-800"
              )}
            >
              {headline}
              <span className="inline-flex items-center rounded-md bg-navy-100 text-navy-700 text-[10px] font-bold px-1.5 py-0.5 leading-none tracking-wide">
                {group.count}
              </span>
            </div>
            {hasUnread && (
              <span
                className="mt-1.5 h-2 w-2 rounded-full bg-gold-500 shrink-0 shadow-[0_0_0_3px_rgba(159,226,32,0.18)] animate-glow-pulse"
                aria-hidden
              />
            )}
          </div>
          {/* Aperçu : titre du dernier item */}
          <p className="mt-0.5 text-[12.5px] text-slate-600 line-clamp-1 leading-relaxed">
            {group.items[0]?.title}
          </p>
          <div className="mt-1 flex items-center gap-2 text-[10.5px] text-slate-400 font-medium tracking-wide">
            <span>{relativeTimeFr(group.latestAt)}</span>
            <span className="h-0.5 w-0.5 rounded-full bg-slate-300" aria-hidden />
            <span className="flex items-center gap-0.5">
              <ChevronDown
                className={cn(
                  "h-3 w-3 transition-transform duration-200 ease-out",
                  expanded && "rotate-180"
                )}
              />
              {expanded ? "Réduire" : "Tout voir"}
            </span>
          </div>
        </div>

        {/* Bouton supprimer le groupe entier (hover) */}
        {onDeleteGroup && (
          <button
            type="button"
            onClick={handleDeleteAllInGroup}
            aria-label="Supprimer ce groupe"
            className={cn(
              "absolute top-3 right-2 h-6 w-6 rounded-md flex items-center justify-center",
              "text-slate-400 hover:text-rose-600 hover:bg-rose-50",
              "opacity-0 group-hover/grouprow:opacity-100 focus-visible:opacity-100",
              "transition-opacity duration-150 ease-out"
            )}
          >
            <X className="h-3.5 w-3.5" />
          </button>
        )}
      </div>

      {/* Sous-liste (expandable) */}
      {expanded && (
        <ul
          className="bg-navy-50/30 border-y border-navy-100/80 animate-notif-pop"
          role="list"
        >
          {group.items.map((n) => (
            <li key={n.id} className="pl-6">
              <NotificationItem
                notif={n}
                onSelect={onSelectItem}
                onDelete={onDeleteItem}
              />
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
