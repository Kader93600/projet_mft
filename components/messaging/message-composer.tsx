"use client";
import {
  useEffect,
  useRef,
  useState,
  useCallback,
  type KeyboardEvent,
  type ChangeEvent,
  type DragEvent,
} from "react";
import { Send, Loader2, Paperclip, X, FileImage } from "lucide-react";
import { cn } from "@/lib/utils";
import { createClient } from "@/lib/supabase/client";
import {
  iconForMime,
  formatBytes,
} from "@/components/messaging/attachment-preview";

interface Props {
  /** Désactive l'envoi (ex: classe en lecture seule pour stagiaire) */
  disabled?: boolean;
  /** Texte d'aide quand disabled */
  disabledReason?: string;
  /** Placeholder de l'input */
  placeholder?: string;
  /** Callback d'envoi : retourne quand l'envoi est confirmé */
  onSend: (body: string, files: File[]) => Promise<void>;
  /** Conv id : si présent, broadcast typing events sur le canal `typing:<id>` */
  conversationId?: string | null;
  /** Identité du viewer : nécessaire pour broadcast typing */
  viewerId?: string;
  viewerName?: string | null;
}

const TYPING_THROTTLE_MS = 2_500;
const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10 MB
const MAX_FILES = 5;

/**
 * Composer multi-modal :
 *   - Texte : auto-resize 1→6 lignes, Enter envoie, Shift+Enter newline
 *   - Pièces jointes : paperclip OU drag/drop, max 5 fichiers, 10 Mo chacun
 *   - Realtime typing broadcast (throttlé)
 *   - Disabled state (ex: classe annonce + stagiaire)
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
  const [files, setFiles] = useState<File[]>([]);
  const [pending, setPending] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [dragActive, setDragActive] = useState(false);
  const textareaRef = useRef<HTMLTextAreaElement>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

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

  // ── Auto-resize textarea ─────────────────────────────────────
  const resize = useCallback(() => {
    const el = textareaRef.current;
    if (!el) return;
    el.style.height = "auto";
    const max = 6 * 22;
    const next = Math.min(max, el.scrollHeight);
    el.style.height = next + "px";
  }, []);

  useEffect(() => {
    resize();
  }, [body, resize]);

  // ── Pièces jointes : ajout / suppression ─────────────────────
  const addFiles = useCallback(
    (incoming: FileList | File[]) => {
      setError(null);
      const arr = Array.from(incoming);
      const next: File[] = [...files];
      for (const f of arr) {
        if (next.length >= MAX_FILES) {
          setError(`Maximum ${MAX_FILES} fichiers par message.`);
          break;
        }
        if (f.size > MAX_FILE_SIZE) {
          setError(`« ${f.name} » dépasse 10 Mo.`);
          continue;
        }
        // Évite doublons exacts
        if (
          next.some((x) => x.name === f.name && x.size === f.size)
        )
          continue;
        next.push(f);
      }
      setFiles(next);
    },
    [files]
  );

  const removeFile = useCallback((index: number) => {
    setFiles((prev) => prev.filter((_, i) => i !== index));
  }, []);

  const onPickFiles = (e: ChangeEvent<HTMLInputElement>) => {
    if (!e.target.files) return;
    addFiles(e.target.files);
    e.target.value = ""; // permet re-pick du même fichier
  };

  // ── Drag / drop ──────────────────────────────────────────────
  const onDragOver = (e: DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    e.stopPropagation();
    if (!dragActive) setDragActive(true);
  };
  const onDragLeave = (e: DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    e.stopPropagation();
    setDragActive(false);
  };
  const onDrop = (e: DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    e.stopPropagation();
    setDragActive(false);
    if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
      addFiles(e.dataTransfer.files);
    }
  };

  // ── Submit ───────────────────────────────────────────────────
  const canSend = (body.trim().length > 0 || files.length > 0) && !disabled;

  const submit = useCallback(async () => {
    if (!canSend || pending) return;
    setError(null);
    setPending(true);
    try {
      await onSend(body.trim(), files);
      setBody("");
      setFiles([]);
      broadcastStop();
    } catch (err: any) {
      setError(err?.message ?? "Échec de l'envoi");
    } finally {
      setPending(false);
    }
  }, [body, files, canSend, onSend, pending, broadcastStop]);

  const handleKey = (e: KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      submit();
    }
  };

  const handleChange = (e: ChangeEvent<HTMLTextAreaElement>) => {
    const next = e.target.value;
    setBody(next);
    if (next.trim().length > 0) broadcastTyping();
    else broadcastStop();
  };

  // ── Disabled state ───────────────────────────────────────────
  if (disabled) {
    return (
      <div className="px-4 py-3 text-center text-[12px] text-slate-500 bg-navy-50/30">
        {disabledReason ?? "Cette conversation est en lecture seule."}
      </div>
    );
  }

  return (
    <div
      className={cn(
        "relative px-3 sm:px-4 py-3",
        "transition-colors duration-150",
        dragActive && "bg-gold-50/50"
      )}
      onDragOver={onDragOver}
      onDragLeave={onDragLeave}
      onDrop={onDrop}
    >
      {/* Drag overlay */}
      {dragActive && (
        <div
          className="absolute inset-2 rounded-xl border-2 border-dashed border-gold-500 bg-gold-50/80 flex items-center justify-center text-[13px] font-semibold text-gold-800 z-10 pointer-events-none animate-notif-pop"
          aria-hidden
        >
          <FileImage className="h-4 w-4 mr-2" />
          Déposer pour joindre
        </div>
      )}

      {/* Erreur */}
      {error && (
        <div className="mb-2 text-[11.5px] text-rose-700 bg-rose-50 border border-rose-200 rounded-md px-2 py-1.5 flex items-start gap-1.5">
          <span aria-hidden>⚠️</span>
          <span className="flex-1">{error}</span>
        </div>
      )}

      {/* Files preview */}
      {files.length > 0 && (
        <div className="mb-2 flex flex-wrap gap-1.5">
          {files.map((f, i) => (
            <FileChip
              key={`${f.name}-${i}`}
              file={f}
              onRemove={() => removeFile(i)}
              disabled={pending}
            />
          ))}
        </div>
      )}

      {/* Composer row */}
      <div className="flex items-end gap-2">
        {/* Paperclip */}
        <button
          type="button"
          onClick={() => fileInputRef.current?.click()}
          disabled={pending || files.length >= MAX_FILES}
          aria-label="Ajouter une pièce jointe"
          title="Ajouter une pièce jointe"
          className={cn(
            "h-10 w-10 rounded-xl flex items-center justify-center shrink-0",
            "text-slate-500 hover:text-navy-900 hover:bg-navy-50",
            "transition-colors duration-150",
            "disabled:opacity-40 disabled:cursor-not-allowed",
            "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-navy-300"
          )}
        >
          <Paperclip className="h-4 w-4" />
        </button>
        <input
          ref={fileInputRef}
          type="file"
          multiple
          onChange={onPickFiles}
          className="sr-only"
          accept="image/*,application/pdf,text/*,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document,application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,application/zip"
        />

        {/* Textarea */}
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

        {/* Send */}
        <button
          type="button"
          onClick={submit}
          disabled={!canSend || pending}
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
        Entrée pour envoyer · Maj+Entrée pour un retour à la ligne · Glisse un
        fichier pour le joindre
      </p>
    </div>
  );
}

// ── File chip ──────────────────────────────────────────────────

function FileChip({
  file,
  onRemove,
  disabled,
}: {
  file: File;
  onRemove: () => void;
  disabled: boolean;
}) {
  const [thumb, setThumb] = useState<string | null>(null);
  const isImage = file.type.startsWith("image/");
  const Icon = iconForMime(file.type);

  useEffect(() => {
    if (!isImage) return;
    const url = URL.createObjectURL(file);
    setThumb(url);
    return () => URL.revokeObjectURL(url);
  }, [file, isImage]);

  return (
    <div
      className={cn(
        "group/chip relative flex items-center gap-2 max-w-[260px] pl-1.5 pr-1 py-1 rounded-lg",
        "bg-white border border-navy-100 shadow-soft animate-notif-pop"
      )}
    >
      {isImage && thumb ? (
        <span
          className="h-8 w-8 rounded-md overflow-hidden bg-navy-50 shrink-0"
          aria-hidden
        >
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src={thumb}
            alt=""
            className="h-full w-full object-cover"
          />
        </span>
      ) : (
        <span
          className="h-8 w-8 rounded-md bg-navy-50 text-navy-700 flex items-center justify-center shrink-0"
          aria-hidden
        >
          <Icon className="h-4 w-4" />
        </span>
      )}
      <div className="min-w-0 flex-1 pr-1">
        <div className="text-[11.5px] font-semibold text-navy-950 truncate">
          {file.name}
        </div>
        <div className="text-[10px] text-slate-500">
          {formatBytes(file.size)}
        </div>
      </div>
      <button
        type="button"
        onClick={onRemove}
        disabled={disabled}
        aria-label="Retirer"
        className={cn(
          "h-6 w-6 rounded flex items-center justify-center shrink-0",
          "text-slate-400 hover:text-rose-600 hover:bg-rose-50",
          "transition-colors duration-150 disabled:opacity-50"
        )}
      >
        <X className="h-3 w-3" />
      </button>
    </div>
  );
}
