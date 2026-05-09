"use client";
import { useEffect, useRef, useState } from "react";
import { cn } from "@/lib/utils";
import { createClient } from "@/lib/supabase/client";
import type { TypingUser } from "@/lib/messaging-types";

interface Props {
  /** Identifiant de la conversation actuellement ouverte. */
  conversationId: string;
  /** Identifiant du viewer (pour ignorer ses propres broadcasts). */
  viewerId: string;
}

const EVENT_NAME = "typing";
/** Combien de temps un broadcast "typing" reste affiché (auto-clear). */
const TTL_MS = 5_000;

/**
 * Affiche "X écrit…" en bas du thread quand un autre participant
 * envoie un broadcast typing sur le canal de la conversation.
 *
 * - Pure broadcast Realtime : aucune écriture en BDD
 * - Auto-clear après 5s sans nouvel événement de cet utilisateur
 * - Compose joliment plusieurs noms : "Marc écrit…", "Marc et Sophie écrivent…",
 *   "Marc, Sophie et 3 autres écrivent…"
 */
export function TypingIndicator({ conversationId, viewerId }: Props) {
  const [typingUsers, setTypingUsers] = useState<Map<string, TypingUser>>(
    new Map()
  );

  // Nettoyage périodique des entrées expirées
  useEffect(() => {
    const id = window.setInterval(() => {
      const now = Date.now();
      setTypingUsers((prev) => {
        let changed = false;
        const next = new Map(prev);
        for (const [uid, t] of next) {
          if (t.expires_at <= now) {
            next.delete(uid);
            changed = true;
          }
        }
        return changed ? next : prev;
      });
    }, 1_000);
    return () => window.clearInterval(id);
  }, []);

  // Souscription au canal de typing de la conversation
  useEffect(() => {
    if (!conversationId) return;
    const supabase = createClient();
    const ch = supabase.channel(`typing:${conversationId}`, {
      config: { broadcast: { self: false } },
    });

    ch.on("broadcast", { event: EVENT_NAME }, ({ payload }) => {
      const p = payload as { user_id?: string; name?: string };
      if (!p.user_id || p.user_id === viewerId) return;
      const name = (p.name && p.name.trim()) || "Quelqu'un";
      setTypingUsers((prev) => {
        const next = new Map(prev);
        next.set(p.user_id!, {
          user_id: p.user_id!,
          name,
          expires_at: Date.now() + TTL_MS,
        });
        return next;
      });
    });

    // Clear immédiat sur "stop" (envoyé quand le composer se vide / blur)
    ch.on("broadcast", { event: "stop" }, ({ payload }) => {
      const p = payload as { user_id?: string };
      if (!p.user_id || p.user_id === viewerId) return;
      setTypingUsers((prev) => {
        if (!prev.has(p.user_id!)) return prev;
        const next = new Map(prev);
        next.delete(p.user_id!);
        return next;
      });
    });

    ch.subscribe();
    return () => {
      void supabase.removeChannel(ch);
    };
  }, [conversationId, viewerId]);

  const list = Array.from(typingUsers.values());
  if (list.length === 0) {
    return <div className="h-5" aria-hidden />;
  }

  return (
    <div
      className="px-4 sm:px-6 pb-1 pt-0.5 flex items-center gap-2 text-[11.5px] text-slate-500 animate-notif-pop"
      role="status"
      aria-live="polite"
    >
      <Dots />
      <span className="font-medium">
        {formatTypingNames(list)}
      </span>
    </div>
  );
}

// ── Pieces ────────────────────────────────────────────────────

function Dots() {
  return (
    <span
      aria-hidden
      className="inline-flex items-end gap-0.5 h-3"
    >
      <Dot delay={0} />
      <Dot delay={150} />
      <Dot delay={300} />
    </span>
  );
}

function Dot({ delay }: { delay: number }) {
  return (
    <span
      className={cn(
        "block h-1 w-1 rounded-full bg-slate-400",
        "animate-typing-bounce"
      )}
      style={{ animationDelay: `${delay}ms` }}
    />
  );
}

function formatTypingNames(list: TypingUser[]): string {
  if (list.length === 1) return `${list[0].name} écrit…`;
  if (list.length === 2)
    return `${list[0].name} et ${list[1].name} écrivent…`;
  const head = list.slice(0, 2).map((u) => u.name).join(", ");
  const rest = list.length - 2;
  return `${head} et ${rest} autre${rest > 1 ? "s" : ""} écrivent…`;
}
