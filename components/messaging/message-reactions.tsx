"use client";
import { useMemo } from "react";
import { cn } from "@/lib/utils";
import type { MessageReaction, ReactionAggregate } from "@/lib/messaging-types";

interface Props {
  reactions: MessageReaction[];
  viewerId: string;
  /** Toggle au clic sur un pill */
  onToggle: (emoji: string) => void;
  /** Côté du message — pour aligner correctement à gauche/droite */
  align: "left" | "right";
}

/**
 * Affiche les réactions agrégées sous un message sous forme de pills.
 * Click sur un pill = toggle de l'emoji par le viewer.
 * Si le viewer a posé l'emoji, le pill est mis en avant (fond gold-50).
 */
export function MessageReactions({
  reactions,
  viewerId,
  onToggle,
  align,
}: Props) {
  const aggregates = useMemo<ReactionAggregate[]>(() => {
    const map = new Map<string, ReactionAggregate>();
    for (const r of reactions) {
      const cur = map.get(r.emoji);
      if (cur) {
        cur.count += 1;
        cur.user_ids.push(r.user_id);
        if (r.user_id === viewerId) cur.mine = true;
      } else {
        map.set(r.emoji, {
          emoji: r.emoji,
          count: 1,
          user_ids: [r.user_id],
          mine: r.user_id === viewerId,
        });
      }
    }
    return Array.from(map.values()).sort((a, b) => b.count - a.count);
  }, [reactions, viewerId]);

  if (aggregates.length === 0) return null;

  return (
    <div
      className={cn(
        "mt-1 flex flex-wrap items-center gap-1",
        align === "right" ? "justify-end" : "justify-start"
      )}
      role="group"
      aria-label="Réactions"
    >
      {aggregates.map((agg) => (
        <button
          key={agg.emoji}
          type="button"
          onClick={() => onToggle(agg.emoji)}
          aria-pressed={agg.mine}
          aria-label={`${agg.count} réaction${agg.count > 1 ? "s" : ""} ${agg.emoji}`}
          className={cn(
            "inline-flex items-center gap-1 h-6 px-1.5 rounded-full",
            "border text-[11px] font-semibold leading-none",
            "transition-all duration-150 ease-out",
            agg.mine
              ? "bg-gold-50 border-gold-300 text-navy-900 shadow-[0_0_0_2px_rgba(159,226,32,0.15)]"
              : "bg-white border-navy-100 text-navy-700 hover:bg-navy-50 hover:border-navy-200",
            "hover:-translate-y-px"
          )}
        >
          <span className="text-[13px] leading-none" aria-hidden>
            {agg.emoji}
          </span>
          <span className="tabular-nums">{agg.count}</span>
        </button>
      ))}
    </div>
  );
}
