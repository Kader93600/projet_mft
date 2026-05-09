"use client";
import { useMemo } from "react";
import { CheckCheck } from "lucide-react";
import { cn } from "@/lib/utils";
import { avatarTone, initials, relativeTimeFr } from "@/lib/messaging-utils";
import type {
  MessageRow,
  ParticipantWithReadState,
} from "@/lib/messaging-types";

interface Props {
  conversationKind: "dm" | "group";
  /** Tous les messages du thread (ordonnés ASC) */
  messages: MessageRow[];
  /** Tous les participants de la conv avec leur last_read_at */
  participants: ParticipantWithReadState[];
  viewerId: string;
}

/**
 * Affiche un indicateur de lecture sous le dernier message envoyé par
 * le viewer.
 *
 * - DM : "✓✓ Vu" ou "✓✓ Vu il y a X min"
 * - Groupe : avatars empilés des lecteurs + "Lu par N"
 *
 * Calcul : un participant P (autre que le viewer) a lu le message M si
 * P.last_read_at >= M.created_at.
 */
export function ReadReceipts({
  conversationKind,
  messages,
  participants,
  viewerId,
}: Props) {
  const data = useMemo(() => {
    // Dernier message du viewer non supprimé
    const lastMine = [...messages]
      .reverse()
      .find((m) => m.sender_id === viewerId && !m.deleted_at);
    if (!lastMine) return null;

    const created = new Date(lastMine.created_at).getTime();
    const readers = participants.filter((p) => {
      if (p.user_id === viewerId) return false;
      if (!p.last_read_at) return false;
      return new Date(p.last_read_at).getTime() >= created;
    });

    // Plus récent last_read_at parmi les lecteurs (pour le timestamp en DM)
    const latestReadAt = readers
      .map((r) => new Date(r.last_read_at!).getTime())
      .reduce((acc, t) => Math.max(acc, t), 0);

    return {
      lastMine,
      readers,
      otherParticipantsCount: participants.filter((p) => p.user_id !== viewerId)
        .length,
      latestReadAt: latestReadAt ? new Date(latestReadAt).toISOString() : null,
    };
  }, [messages, participants, viewerId]);

  if (!data) return null;
  if (data.readers.length === 0) return null;

  // ── DM : 1 seul autre participant ─────────────────────────────
  if (conversationKind === "dm") {
    return (
      <div
        className={cn(
          "px-4 sm:px-6 pb-1.5 pt-0.5 flex items-center gap-1.5 justify-end",
          "text-[10.5px] font-medium text-gold-700"
        )}
        aria-label="Lu"
      >
        <CheckCheck className="h-3 w-3" />
        <span>
          Vu
          {data.latestReadAt && (
            <span className="ml-1 text-slate-400 font-normal">
              · {relativeTimeFr(data.latestReadAt)}
            </span>
          )}
        </span>
      </div>
    );
  }

  // ── Groupe : avatars empilés + count ──────────────────────────
  const visibleAvatars = data.readers.slice(0, 3);
  const overflow = data.readers.length - visibleAvatars.length;
  const allRead = data.readers.length === data.otherParticipantsCount;

  return (
    <div
      className={cn(
        "px-4 sm:px-6 pb-1.5 pt-0.5 flex items-center gap-1.5 justify-end",
        "text-[10.5px] font-medium text-slate-500"
      )}
      aria-label={`Lu par ${data.readers.length} participant${
        data.readers.length > 1 ? "s" : ""
      }`}
    >
      <div className="flex -space-x-1.5">
        {visibleAvatars.map((r) => (
          <span
            key={r.user_id}
            title={r.full_name ?? r.email}
            className={cn(
              "h-4 w-4 rounded-full ring-1 ring-white flex items-center justify-center text-[8px] font-bold leading-none",
              avatarTone(r.user_id)
            )}
            aria-hidden
          >
            {initials(r.full_name ?? r.email)}
          </span>
        ))}
        {overflow > 0 && (
          <span
            className="h-4 min-w-[16px] px-1 rounded-full ring-1 ring-white bg-navy-100 text-navy-700 flex items-center justify-center text-[8px] font-bold leading-none"
            aria-hidden
          >
            +{overflow}
          </span>
        )}
      </div>
      <span>
        {allRead ? (
          <>
            <CheckCheck className="h-3 w-3 inline-block -mt-0.5 mr-1 text-gold-700" />
            Lu par tous
          </>
        ) : (
          `Lu par ${data.readers.length}`
        )}
      </span>
    </div>
  );
}
