"use client";
import { useRef, useState, useTransition } from "react";
import { uploadMedia, deleteMedia } from "@/app/admin/modules/actions";
import {
  ImagePlus,
  Loader2,
  X,
  ImageIcon,
  AlertCircle,
  CheckCircle2,
} from "lucide-react";

/**
 * Composant d'upload d'image avec :
 *  - drag & drop
 *  - preview live
 *  - bouton supprimer / remplacer
 *  - feedback erreur / succès
 *  - rate limit géré côté serveur
 *
 * Usage :
 *   <ImageUploader
 *     value={url}
 *     onChange={(url) => setUrl(url)}
 *     prefix="modules/cover"
 *     label="Image de couverture"
 *   />
 */
export function ImageUploader({
  value,
  onChange,
  prefix,
  label = "Image",
  hint,
  maxSizeMB = 5,
  accept = "image/png,image/jpeg,image/webp,image/gif,image/svg+xml",
  ratio,
  className,
}: {
  /** URL publique de l'image actuelle (ou null) */
  value: string | null | undefined;
  /** Callback à chaque changement (upload ou suppression) */
  onChange: (url: string | null) => void;
  /** Préfixe stockage (ex: 'modules/cover'). Défault: 'content' */
  prefix?: string;
  /** Label affiché au-dessus de la zone */
  label?: string;
  /** Hint sous la zone */
  hint?: string;
  /** Limite côté UI (le serveur valide aussi) */
  maxSizeMB?: number;
  /** Types MIME acceptés */
  accept?: string;
  /** Ratio d'aperçu : 'square' | 'video' | 'wide' | undefined */
  ratio?: "square" | "video" | "wide";
  className?: string;
}) {
  const inputRef = useRef<HTMLInputElement>(null);
  const [pending, start] = useTransition();
  const [dragOver, setDragOver] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [progress, setProgress] = useState<"idle" | "ok">("idle");

  function handleFile(file: File) {
    setError(null);
    if (!file.type.startsWith("image/") && !accept.includes(file.type)) {
      setError("Format non supporté");
      return;
    }
    if (file.size > maxSizeMB * 1024 * 1024) {
      setError(`Image trop lourde (max ${maxSizeMB} Mo)`);
      return;
    }
    start(async () => {
      try {
        const fd = new FormData();
        fd.append("file", file);
        if (prefix) fd.append("prefix", prefix);
        const res = await uploadMedia(fd);
        onChange(res.url);
        setProgress("ok");
        window.setTimeout(() => setProgress("idle"), 1800);
      } catch (e: any) {
        setError(e.message || "Erreur d'upload");
      }
    });
  }

  function onPick(e: React.ChangeEvent<HTMLInputElement>) {
    const f = e.target.files?.[0];
    if (f) handleFile(f);
  }

  function onDrop(e: React.DragEvent) {
    e.preventDefault();
    setDragOver(false);
    const f = e.dataTransfer.files?.[0];
    if (f) handleFile(f);
  }

  function clear() {
    onChange(null);
    setError(null);
    if (inputRef.current) inputRef.current.value = "";
  }

  const aspectClass =
    ratio === "square"
      ? "aspect-square"
      : ratio === "video"
      ? "aspect-video"
      : ratio === "wide"
      ? "aspect-[16/6]"
      : "min-h-[160px]";

  return (
    <div className={className}>
      <div className="text-sm font-medium text-navy-900 mb-1.5">{label}</div>

      {value ? (
        // ─── Preview avec actions ────────────────────────────────────
        <div className="relative group">
          <div
            className={
              "relative overflow-hidden rounded-xl border border-navy-100 bg-navy-50/30 " +
              aspectClass
            }
          >
            <img
              src={value}
              alt={label}
              className="w-full h-full object-cover"
            />
            <div className="absolute inset-0 bg-black/0 group-hover:bg-black/30 transition-colors flex items-center justify-center gap-2 opacity-0 group-hover:opacity-100">
              <button
                type="button"
                onClick={() => inputRef.current?.click()}
                disabled={pending}
                className="px-3 py-2 rounded-lg bg-white text-navy-900 text-xs font-medium shadow-soft hover:bg-navy-50 disabled:opacity-60"
              >
                Remplacer
              </button>
              <button
                type="button"
                onClick={clear}
                disabled={pending}
                className="px-3 py-2 rounded-lg bg-rose-600 text-white text-xs font-medium hover:bg-rose-700 disabled:opacity-60 inline-flex items-center gap-1"
              >
                <X className="h-3 w-3" />
                Retirer
              </button>
            </div>
            {progress === "ok" && (
              <div className="absolute top-2 right-2 inline-flex items-center gap-1 rounded-full bg-emerald-500 text-white px-2 py-1 text-[10px] font-semibold animate-[fade-up_0.3s_ease-out]">
                <CheckCircle2 className="h-3 w-3" />
                Téléversée
              </div>
            )}
          </div>
        </div>
      ) : (
        // ─── Drop zone vide ──────────────────────────────────────────
        <button
          type="button"
          onClick={() => inputRef.current?.click()}
          onDragOver={(e) => {
            e.preventDefault();
            setDragOver(true);
          }}
          onDragLeave={() => setDragOver(false)}
          onDrop={onDrop}
          disabled={pending}
          className={
            "w-full rounded-xl border-2 border-dashed transition-colors flex flex-col items-center justify-center gap-2 py-8 px-4 " +
            aspectClass +
            " " +
            (dragOver
              ? "border-brand-500 bg-brand-50/40"
              : "border-navy-200 bg-navy-50/30 hover:border-brand-400 hover:bg-brand-50/30") +
            (pending ? " opacity-60 cursor-wait" : " cursor-pointer")
          }
        >
          {pending ? (
            <>
              <Loader2 className="h-6 w-6 text-brand-600 animate-spin motion-reduce:animate-none" />
              <span className="text-sm text-slate-600">Téléversement…</span>
            </>
          ) : (
            <>
              <div className="h-12 w-12 rounded-2xl bg-brand-50 text-brand-700 flex items-center justify-center">
                <ImagePlus className="h-6 w-6" />
              </div>
              <div className="text-sm font-medium text-navy-900">
                Glissez une image ici
              </div>
              <div className="text-xs text-slate-500">
                ou cliquez pour parcourir · {maxSizeMB} Mo max
              </div>
            </>
          )}
        </button>
      )}

      {/* Input caché (toujours présent pour le bouton "Remplacer") */}
      <input
        ref={inputRef}
        type="file"
        accept={accept}
        onChange={onPick}
        className="hidden"
      />

      {error && (
        <div className="mt-2 inline-flex items-start gap-1.5 rounded-lg bg-rose-50 border border-rose-200 px-2.5 py-1.5 text-xs text-rose-700">
          <AlertCircle className="h-3.5 w-3.5 mt-0.5 shrink-0" />
          <span>{error}</span>
        </div>
      )}

      {hint && !error && (
        <p className="mt-1.5 text-[11px] text-slate-500">{hint}</p>
      )}
    </div>
  );
}
