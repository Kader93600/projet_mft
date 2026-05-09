"use client";
import { useEffect, useRef } from "react";
import { cn } from "@/lib/utils";

/** Set de réactions rapides — émotions universelles + petits feedbacks pédagos. */
export const QUICK_REACTIONS: { emoji: string; label: string }[] = [
  { emoji: "👍", label: "J'aime" },
  { emoji: "❤️", label: "Adore" },
  { emoji: "😄", label: "Rire" },
  { emoji: "🎉", label: "Bravo" },
  { emoji: "🙌", label: "Merci" },
  { emoji: "✅", label: "Validé" },
  { emoji: "🔥", label: "Excellent" },
  { emoji: "🤔", label: "Hmm…" },
];

interface Props {
  /** Position : aligné à gauche (other) ou à droite (mine) du message. */
  align: "left" | "right";
  /** Callback déclenché quand l'utilisateur choisit un emoji. */
  onPick: (emoji: string) => void;
  /** Fermeture demandée par le parent (clic outside, Escape, etc.). */
  onClose: () => void;
}

/**
 * Petit popover de quick reactions affiché au-dessus de la barre actions.
 * Auto-fermeture sur clic outside ou Escape (laissé au parent).
 */
export function EmojiPicker({ align, onPick, onClose }: Props) {
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const onDoc = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) onClose();
    };
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    document.addEventListener("mousedown", onDoc);
    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("mousedown", onDoc);
      document.removeEventListener("keydown", onKey);
    };
  }, [onClose]);

  return (
    <div
      ref={ref}
      role="menu"
      aria-label="Choisir une réaction"
      className={cn(
        "absolute -top-12 z-30 flex items-center gap-0.5 px-1.5 py-1.5",
        "rounded-xl bg-white border border-navy-100 shadow-float",
        "animate-notif-pop",
        align === "left" ? "left-0" : "right-0"
      )}
    >
      {QUICK_REACTIONS.map((r) => (
        <button
          key={r.emoji}
          type="button"
          title={r.label}
          aria-label={r.label}
          onClick={() => {
            onPick(r.emoji);
            onClose();
          }}
          className={cn(
            "h-8 w-8 rounded-lg flex items-center justify-center text-[18px] leading-none",
            "transition-transform duration-150 ease-out hover:bg-navy-50 hover:scale-125",
            "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-gold-400"
          )}
        >
          <span aria-hidden>{r.emoji}</span>
        </button>
      ))}
    </div>
  );
}
