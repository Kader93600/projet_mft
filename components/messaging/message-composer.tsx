"use client";
import {
  useEffect,
  useRef,
  useState,
  useCallback,
  type KeyboardEvent,
  type ChangeEvent,
} from "react";
import { Send, Loader2 } from "lucide-react";
import { cn } from "@/lib/utils";
import { createClient } from "@/lib/supabase/client";

interface Props {
  /** Désactive l'envoi (ex: classe en lecture seule pour stagiaire) */
  disabled?: boolean;
  /** Texte d'aide quand disabled */
  disabledReason?: string;
  /** Placeholder de l'input */
  placeholder?: string;
  /** Callback d'envoi : retourne quand l'envoi est confirmé */
  onSend: (body: string) => Promise<void>;
  /** Conv id : si présent, broadcast typing events sur le canal `typing:<id>` */
  conversationId?: string | null;
  /** Identité du viewer : nécessaire pour broadcast typing */
  viewerId?: string;
  viewerName?: string | null;
}

/** Throttle : envoie au plus un événement toutes les N ms. */
const TYPING_THROTTLE_MS = 2_500;

/**
 * Composer minimaliste avec :
 *   - textarea auto-resize (max 6 lignes)
 *   - Enter envoie · Shift+Enter newline
 *   - Bouton Send animé (rotation flèche en envoi)
 *   - État disabled (ex: classe annonce, pas autorisé)
 */
export function MessageComposer({
  disabled = false,
  disabledReason,
  placeholder = "Écrivez votre message…",
  onSend,
  conversationId,
  viewerId,
  viewerName,
}: Props) {
  const [body, setBody] = useState("");
  const [pending, setPending] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  // ── Realtime typing channel ──────────────────────────────────
  const typingChannelRef = useRef<ReturnType<
    ReturnType<typeof createClient>["channel"]
  > | null>(null);
  const lastTypingSentRef = useRef<number>(0);

  useEffect(() => {
    if (!conversationId) return;
    const supabase = createClient();
    const ch = supabase.channel(`typing:${conversationId}`, {
      config: { broadcast: { self: false } },
    });
    ch.subscribe();
    typingChannelRef.current = ch;
    return () => {
      void supabase.removeChannel(ch);
      typingChannelRef.current = null;
    };
  }, [conversationId]);

  const broadcastTyping = useCallback(() => {
    const ch = typingChannelRef.current;
    if (!ch || !viewerId) return;
    const now = Date.now();
    if (now - lastTypingSentRef.current < TYPING_THROTTLE_MS) return;
    lastTypingSentRef.current = now;
    void ch.send({
      type: "broadcast",
      event: "typing",
      payload: { user_id: viewerId, name: viewerName ?? "" },
    });
  }, [viewerId, viewerName]);

  const broadcastStop = useCallback(() => {
    const ch = typingChannelRef.current;
    if (!ch || !viewerId) return;
    lastTypingSentRef.current = 0;
    void ch.send({
      type: "broadcast",
      event: "stop",
      payload: { user_id: viewerId },
    });
  }, [viewerId]);

  // Auto-resize
  const resize = useCallback(() => {
    const el = textareaRef.current;
    if (!el) return;
    el.style.height = "auto";
    const max = 6 * 22; // ~6 lignes (line-height ≈ 22px)
    const next = Math.min(max, el.scrollHeight);
    el.style.height = next + "px";
  }, []);

  useEffect(() => {
    resize();
  }, [body, resize]);

  const submit = useCallback(async () => {
    if (disabled || pending) return;
    const trimmed = body.trim();
    if (!trimmed) return;
    setError(null);
    setPending(true);
    try {
      await onSend(trimmed);
      setBody("");
      broadcastStop();
    } catch (err: any) {
      setError(err?.message ?? "Échec de l'envoi");
    } finally {
      setPending(false);
    }
  }, [body, disabled, onSend, pending, broadcastStop]);

  const handleKey = (e: KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      submit();
    }
  };

  const handleChange = (e: ChangeEvent<HTMLTextAreaElement>) => {
    const next = e.target.value;
    setBody(next);
    if (next.trim().length > 0) {
      broadcastTyping();
    } else {
      // Champ vide → arrêt immédiat de l'indicateur
      broadcastStop();
    }
  };

  if (disabled) {
    return (
      <div className="px-4 py-3 text-center text-[12px] text-slate-500 bg-navy-50/30">
        {disabledReason ?? "Cette conversation est en lecture seule."}
      </div>
    );
  }

  return (
    <div className="px-3 sm:px-4 py-3">
      {error && (
        <div className="mb-2 text-[11.5px] text-rose-700 bg-rose-50 border border-rose-200 rounded-md px-2 py-1.5 flex items-start gap-1.5">
          <span aria-hidden>⚠️</span>
          <span className="flex-1">{error}</span>
        </div>
      )}
      <div className="flex items-end gap-2">
        <div className="flex-1 min-w-0 rounded-xl border border-navy-100 bg-white focus-within:border-navy-300 focus-within:shadow-ring-brand transition-shadow">
          <textarea
            ref={textareaRef}
            value={body}
            onChange={handleChange}
            onBlur={() => {
              if (!body.trim()) broadcastStop();
            }}
            onKeyDown={handleKey}
            placeholder={placeholder}
            rows={1}
            className={cn(
              "block w-full resize-none bg-transparent",
              "px-3 py-2.5 text-[13px] leading-[22px]",
              "placeholder:text-slate-400 text-navy-950",
              "outline-none"
            )}
          />
        </div>
        <button
          type="button"
          onClick={submit}
          disabled={pending || !body.trim()}
          aria-label="Envoyer"
          className={cn(
            "h-10 w-10 rounded-xl flex items-center justify-center shrink-0 shadow-sm",
            "bg-gradient-to-br from-gold-500 to-gold-600 text-navy-950",
            "hover:from-gold-600 hover:to-gold-700",
            "transition-all duration-150 ease-out",
            "disabled:opacity-40 disabled:cursor-not-allowed disabled:hover:from-gold-500 disabled:hover:to-gold-600",
            "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-gold-400 focus-visible:ring-offset-2"
          )}
        >
          {pending ? (
            <Loader2 className="h-4 w-4 animate-spin" />
          ) : (
            <Send className="h-4 w-4 -translate-x-px translate-y-px" />
          )}
        </button>
      </div>
      <p className="mt-1.5 text-[10.5px] text-slate-400 px-1">
        Entrée pour envoyer · Maj+Entrée pour un retour à la ligne
      </p>
    </div>
  );
}
