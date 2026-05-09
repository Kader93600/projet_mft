"use client";
import { useState, type KeyboardEvent } from "react";
import { X } from "lucide-react";
import { cn } from "@/lib/utils";
import {
  getNotificationStyle,
  relativeTimeFr,
} from "@/lib/notifications-icons";

export type NotificationRow = {
  id: string;
  type: string | null;
  title: string;
  body: string | null;
  link_url: string | null;
  read_at: string | null;
  created_at: string;
};

interface Props {
  notif: NotificationRow;
  /** Action principale (mark as read + navigate si link_url). */
  onSelect: (notif: NotificationRow) => void;
  /** Suppression individuelle. */
  onDelete: (id: string) => void;
  /** Effet flash gold à l'arrivée via Realtime. */
  fresh?: boolean;
}

/**
 * Une ligne de notification dans le centre.
 * - Hover : translate-x léger + bg navy, icône scale 1.05
 * - Bouton ✕ apparaît au hover en haut à droite
 * - Pastille gold (vert lime signal) à droite si non lue
 * - Animation "removing" au clic supprimer (slide + fade)
 */
export function NotificationItem({
  notif,
  onSelect,
  onDelete,
  fresh = false,
}: Props) {
  const style = getNotificationStyle(notif.type);
  const Icon = style.icon;
  const unread = !notif.read_at;
  const [removing, setRemoving] = useState(false);

  const handleSelect = () => {
    if (removing) return;
    onSelect(notif);
  };

  const handleKey = (e: KeyboardEvent<HTMLDivElement>) => {
    if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      handleSelect();
    }
  };

  const handleDelete = (e: React.MouseEvent) => {
    e.stopPropagation();
    setRemoving(true);
    // L'animation dure 220ms ; on retire la donnée juste après.
    window.setTimeout(() => onDelete(notif.id), 220);
  };

  return (
    <div
      role="button"
      tabIndex={0}
      onClick={handleSelect}
      onKeyDown={handleKey}
      aria-label={`${style.label} : ${notif.title}${unread ? " (non lue)" : ""}`}
      className={cn(
        "group relative flex items-start gap-3 px-4 py-3.5 cursor-pointer outline-none",
        "transition-all duration-150 ease-out",
        "hover:bg-navy-50/50 hover:translate-x-[1.5px]",
        "focus-visible:bg-navy-50/60 focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-navy-300",
        unread && "bg-gold-50/40",
        fresh && "animate-notif-flash",
        removing &&
          "opacity-0 -translate-x-4 max-h-0 !py-0 overflow-hidden duration-[220ms]"
      )}
    >
      {/* Icône typée */}
      <span
        className={cn(
          "h-9 w-9 rounded-xl border flex items-center justify-center shrink-0",
          "transition-transform duration-150 ease-out group-hover:scale-105",
          style.tone
        )}
        aria-hidden
      >
        <Icon className="h-4 w-4" />
      </span>

      {/* Contenu */}
      <div className="flex-1 min-w-0 pr-7">
        <div className="flex items-start justify-between gap-2">
          <div
            className={cn(
              "text-[13.5px] leading-snug truncate",
              unread
                ? "font-semibold text-navy-950"
                : "font-medium text-navy-800"
            )}
          >
            {notif.title}
          </div>
          {unread && (
            <span
              className="mt-1.5 h-2 w-2 rounded-full bg-gold-500 shrink-0 shadow-[0_0_0_3px_rgba(159,226,32,0.18)] animate-glow-pulse"
              aria-hidden
            />
          )}
        </div>
        {notif.body && (
          <p className="mt-0.5 text-[12.5px] text-slate-600 line-clamp-2 leading-relaxed">
            {notif.body}
          </p>
        )}
        <div className="mt-1 text-[10.5px] text-slate-400 font-medium tracking-wide">
          {relativeTimeFr(notif.created_at)}
        </div>
      </div>

      {/* Bouton supprimer (apparaît au hover, focusable indépendamment) */}
      <button
        type="button"
        onClick={handleDelete}
        aria-label="Supprimer la notification"
        className={cn(
          "absolute top-3 right-2 h-6 w-6 rounded-md flex items-center justify-center",
          "text-slate-400 hover:text-rose-600 hover:bg-rose-50",
          "opacity-0 group-hover:opacity-100 focus-visible:opacity-100",
          "transition-opacity duration-150 ease-out"
        )}
      >
        <X className="h-3.5 w-3.5" />
      </button>
    </div>
  );
}
