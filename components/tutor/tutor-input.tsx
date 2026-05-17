"use client";

import { useEffect, useRef, useState } from "react";
import { Send, Square } from "lucide-react";
import { cn } from "@/lib/utils";

export function TutorInput({
  onSend,
  onStop,
  streaming,
  placeholder = "Posez votre question sur le cours…",
}: {
  onSend: (text: string) => void;
  onStop?: () => void;
  streaming: boolean;
  placeholder?: string;
}) {
  const [value, setValue] = useState("");
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  // Auto-grow textarea
  useEffect(() => {
    const el = textareaRef.current;
    if (!el) return;
    el.style.height = "auto";
    el.style.height = Math.min(el.scrollHeight, 160) + "px";
  }, [value]);

  const canSend = value.trim().length >= 3 && !streaming;

  const submit = () => {
    if (!canSend) return;
    onSend(value);
    setValue("");
  };

  return (
    <form
      onSubmit={(e) => {
        e.preventDefault();
        submit();
      }}
      className="border-t border-navy-100 bg-white p-3 flex items-end gap-2"
    >
      <textarea
        ref={textareaRef}
        rows={1}
        value={value}
        onChange={(e) => setValue(e.target.value)}
        onKeyDown={(e) => {
          if (e.key === "Enter" && !e.shiftKey) {
            e.preventDefault();
            submit();
          }
        }}
        disabled={streaming}
        placeholder={placeholder}
        aria-label="Question pour le tuteur"
        className={cn(
          "flex-1 resize-none rounded-xl border border-navy-100 bg-white",
          "px-3 py-2 text-sm leading-relaxed text-navy-900",
          "focus:outline-none focus:ring-2 focus:ring-gold-400 focus:border-transparent",
          "disabled:opacity-60 disabled:cursor-not-allowed",
          "min-h-[40px] max-h-40"
        )}
      />

      {streaming && onStop ? (
        <button
          type="button"
          onClick={onStop}
          aria-label="Arrêter la réponse"
          className={cn(
            "h-10 w-10 rounded-xl bg-rose-500 hover:bg-rose-600 text-white",
            "flex items-center justify-center transition-colors shrink-0",
            "focus:outline-none focus:ring-2 focus:ring-rose-300 focus:ring-offset-2"
          )}
        >
          <Square className="h-4 w-4" />
        </button>
      ) : (
        <button
          type="submit"
          disabled={!canSend}
          aria-label="Envoyer"
          className={cn(
            "h-10 w-10 rounded-xl flex items-center justify-center transition-all shrink-0",
            "focus:outline-none focus:ring-2 focus:ring-gold-400 focus:ring-offset-2",
            canSend
              ? "bg-navy-900 hover:bg-navy-800 text-white"
              : "bg-slate-100 text-slate-400 cursor-not-allowed"
          )}
        >
          <Send className="h-4 w-4" />
        </button>
      )}
    </form>
  );
}
