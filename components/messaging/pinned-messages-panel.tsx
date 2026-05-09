"use client";
import { useState } from "react";
import { Pin, ChevronDown, X } from "lucide-react";
import { cn } from "@/lib/utils";
import {
  avatarTone,
  initials,
  relativeTimeFr,
} from "@/lib/messaging-utils";
import type {
  MessageRow,
  MinimalProfile,
  PinnedMessage,
} from "@/lib/messaging-types";

interface Props {
  pins: PinnedMessage[];
  /** Map id → message complet (depuis le thread) */
  messagesById: Record<string, MessageRow>;
  /** Map id → profil pour résoudre les noms */
  profiles: Record<string, MinimalProfile>;
  /** Callback retire l'épingle */
  onUnpin: (messageId: string) => void;
}

/**
 * Panel collapsible affiché en haut du thread quand au moins 1 message
 * est épinglé. Ferme par défaut (juste un sticky bandeau) ; cliquer
 * dessus l'expand et montre la liste compacte des messages épinglés.
 */
export function PinnedMessagesPanel({
  pins,
  messagesById,
  profiles,
  onUnpin,
}: Props) {
  const [open, setOpen] = useState(false);

  if (pins.length === 0) return null;

  // Tri du plus récent au plus ancien
  const ordered = [...pins].sort(
    (a, b) => new Date(b.pinned_at).getTime() - new Date(a.pinned_at).getTime()
  );

  return (
    <div className="border-b border-navy-100 bg-gold-50/40">
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        aria-expanded={open}
        className={cn(
          "w-full flex items-center gap-2 px-4 sm:px-5 py-2",
          "text-[12px] font-semibold text-navy-900",
          "transition-colors duration-150",
          "hover:bg-gold-100/50"
        )}
      >
        <Pin className="h-3.5 w-3.5 text-gold-700" />
        <span>
          {pins.length} message{pins.length > 1 ? "s" : ""} épinglé
          {pins.length > 1 ? "s" : ""}
        </span>
        <ChevronDown
          className={cn(
            "h-3.5 w-3.5 text-slate-500 transition-transform duration-200",
            open && "rotate-180"
          )}
        />
      </button>

      {open && (
        <ul className="px-2 pb-2 space-y-1 animate-notif-pop">
          {ordered.map((p) => {
            const msg = messagesById[p.message_id];
            if (!msg) return null;
            const prof = profiles[msg.sender_id];
            const senderName = prof?.full_name ?? prof?.email ?? "Utilisateur";
            const tone = avatarTone(msg.sender_id);
            return (
              <li
                key={p.message_id}
                className={cn(
                  "group/pin flex items-start gap-2.5 px-3 py-2 rounded-lg",
                  "bg-white border border-navy-100/60 hover:border-gold-200 hover:bg-gold-50/60",
                  "transition-colors duration-150"
                )}
              >
                <span
                  className={cn(
                    "h-7 w-7 rounded-md flex items-center justify-center shrink-0 font-semibold text-[10px]",
                    tone
                  )}
                  aria-hidden
                >
                  {initials(senderName)}
                </span>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-1.5 text-[10.5px]">
                    <span className="font-semibold text-navy-900 truncate">
                      {senderName}
                    </span>
                    <span className="text-slate-400">
                      · {relativeTimeFr(msg.created_at)}
                    </span>
                  </div>
                  <p className="mt-0.5 text-[12px] text-navy-800 line-clamp-2 leading-snug">
                    {msg.deleted_at ? (
                      <em className="text-slate-400">Message supprimé</em>
                    ) : (
                      msg.body
                    )}
                  </p>
                </div>
                <button
                  type="button"
                  onClick={() => onUnpin(p.message_id)}
                  aria-label="Désépingler"
                  className={cn(
                    "h-6 w-6 rounded flex items-center justify-center shrink-0",
                    "text-slate-400 hover:text-rose-600 hover:bg-rose-50",
                    "opacity-0 group-hover/pin:opacity-100 focus-visible:opacity-100",
                    "transition-opacity duration-150"
                  )}
                >
                  <X className="h-3 w-3" />
                </button>
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}
