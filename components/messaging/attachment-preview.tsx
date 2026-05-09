"use client";
import { useEffect, useState } from "react";
import {
  FileText,
  FileImage,
  FileVideo,
  FileAudio,
  File as FileGeneric,
  Download,
  X,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { createClient } from "@/lib/supabase/client";
import type { MessageAttachment } from "@/lib/messaging-types";

const BUCKET = "message-attachments";

interface Props {
  attachments: MessageAttachment[];
  align: "left" | "right";
}

/**
 * Rendu des pièces jointes d'un message :
 *   - Images : grille de thumbnails (max 4 visibles, +N si plus)
 *     Click → lightbox plein écran
 *   - Autres : card compacte (icône typée + nom + taille + bouton DL)
 */
export function AttachmentPreview({ attachments, align }: Props) {
  const [lightbox, setLightbox] = useState<{
    src: string;
    name: string;
  } | null>(null);
  const [signed, setSigned] = useState<Record<string, string>>({});

  // Génère les URL signées (valides 1h) en parallèle
  useEffect(() => {
    if (attachments.length === 0) return;
    let cancelled = false;
    const supabase = createClient();
    void (async () => {
      const paths = attachments.map((a) => a.storage_path);
      const { data, error } = await supabase.storage
        .from(BUCKET)
        .createSignedUrls(paths, 60 * 60);
      if (cancelled || error || !data) return;
      const next: Record<string, string> = {};
      data.forEach((d, i) => {
        if (d.signedUrl) next[paths[i]] = d.signedUrl;
      });
      setSigned(next);
    })();
    return () => {
      cancelled = true;
    };
  }, [attachments]);

  if (attachments.length === 0) return null;

  const images = attachments.filter((a) => a.mime_type.startsWith("image/"));
  const others = attachments.filter((a) => !a.mime_type.startsWith("image/"));

  return (
    <div
      className={cn(
        "mt-1.5 flex flex-col gap-1.5",
        align === "right" ? "items-end" : "items-start"
      )}
    >
      {/* Images en grille */}
      {images.length > 0 && (
        <div
          className={cn(
            "grid gap-1.5",
            images.length === 1 && "grid-cols-1",
            images.length === 2 && "grid-cols-2",
            images.length === 3 && "grid-cols-2",
            images.length >= 4 && "grid-cols-2"
          )}
          style={{ maxWidth: "320px" }}
        >
          {images.slice(0, 4).map((img, i) => {
            const url = signed[img.storage_path];
            const isLast = i === 3 && images.length > 4;
            const overflow = images.length - 4;
            return (
              <button
                key={img.id}
                type="button"
                onClick={() =>
                  url && setLightbox({ src: url, name: img.original_name })
                }
                className={cn(
                  "relative overflow-hidden rounded-lg border border-navy-100 bg-navy-50/40",
                  "aspect-square w-full",
                  "transition-transform duration-150 ease-out hover:scale-[1.02]",
                  "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-gold-400",
                  images.length === 3 && i === 0 && "row-span-2 aspect-square"
                )}
              >
                {url ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img
                    src={url}
                    alt={img.original_name}
                    className="h-full w-full object-cover"
                    loading="lazy"
                  />
                ) : (
                  <div className="h-full w-full flex items-center justify-center text-slate-400">
                    <FileImage className="h-6 w-6" />
                  </div>
                )}
                {isLast && overflow > 0 && (
                  <div className="absolute inset-0 bg-navy-950/70 flex items-center justify-center text-white font-bold text-lg">
                    +{overflow}
                  </div>
                )}
              </button>
            );
          })}
        </div>
      )}

      {/* Autres fichiers */}
      {others.map((f) => (
        <FileCard key={f.id} attachment={f} url={signed[f.storage_path]} />
      ))}

      {/* Lightbox */}
      {lightbox && (
        <Lightbox
          src={lightbox.src}
          name={lightbox.name}
          onClose={() => setLightbox(null)}
        />
      )}
    </div>
  );
}

// ── File card ─────────────────────────────────────────────────

function FileCard({
  attachment,
  url,
}: {
  attachment: MessageAttachment;
  url: string | undefined;
}) {
  const Icon = iconForMime(attachment.mime_type);
  return (
    <a
      href={url ?? "#"}
      download={attachment.original_name}
      target="_blank"
      rel="noopener noreferrer"
      className={cn(
        "group inline-flex items-center gap-3 max-w-[320px] px-3 py-2 rounded-xl border",
        "bg-white border-navy-100 hover:bg-navy-50 hover:border-navy-200",
        "transition-colors duration-150 ease-out"
      )}
    >
      <span
        className="h-9 w-9 rounded-lg bg-navy-50 text-navy-700 flex items-center justify-center shrink-0"
        aria-hidden
      >
        <Icon className="h-4 w-4" />
      </span>
      <div className="min-w-0 flex-1">
        <div className="text-[12.5px] font-semibold text-navy-950 truncate">
          {attachment.original_name}
        </div>
        <div className="text-[10.5px] text-slate-500">
          {formatBytes(attachment.size_bytes)}
        </div>
      </div>
      <Download className="h-3.5 w-3.5 text-slate-400 group-hover:text-navy-700 transition-colors shrink-0" />
    </a>
  );
}

// ── Lightbox ──────────────────────────────────────────────────

function Lightbox({
  src,
  name,
  onClose,
}: {
  src: string;
  name: string;
  onClose: () => void;
}) {
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    document.addEventListener("keydown", onKey);
    document.body.style.overflow = "hidden";
    return () => {
      document.removeEventListener("keydown", onKey);
      document.body.style.overflow = "";
    };
  }, [onClose]);

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-label={name}
      className="fixed inset-0 z-50 bg-navy-950/90 backdrop-blur-sm flex items-center justify-center p-4 animate-notif-backdrop"
      onClick={onClose}
    >
      <button
        type="button"
        onClick={onClose}
        aria-label="Fermer"
        className="absolute top-4 right-4 h-10 w-10 rounded-xl bg-white/10 text-white hover:bg-white/20 flex items-center justify-center transition-colors"
      >
        <X className="h-5 w-5" />
      </button>
      <a
        href={src}
        download={name}
        target="_blank"
        rel="noopener noreferrer"
        className="absolute top-4 left-4 inline-flex items-center gap-1.5 h-10 px-3 rounded-xl bg-white/10 text-white text-[12px] font-semibold hover:bg-white/20 transition-colors"
        onClick={(e) => e.stopPropagation()}
      >
        <Download className="h-3.5 w-3.5" />
        Télécharger
      </a>
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img
        src={src}
        alt={name}
        className="max-w-full max-h-full object-contain rounded-lg shadow-2xl animate-notif-pop"
        onClick={(e) => e.stopPropagation()}
      />
    </div>
  );
}

// ── Helpers ───────────────────────────────────────────────────

export function iconForMime(mime: string) {
  if (mime.startsWith("image/")) return FileImage;
  if (mime.startsWith("video/")) return FileVideo;
  if (mime.startsWith("audio/")) return FileAudio;
  if (
    mime === "application/pdf" ||
    mime.startsWith("text/") ||
    mime.includes("spreadsheet") ||
    mime.includes("document") ||
    mime.includes("presentation")
  )
    return FileText;
  return FileGeneric;
}

export function formatBytes(bytes: number): string {
  if (bytes < 1024) return `${bytes} o`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} Ko`;
  if (bytes < 1024 * 1024 * 1024)
    return `${(bytes / (1024 * 1024)).toFixed(1)} Mo`;
  return `${(bytes / (1024 * 1024 * 1024)).toFixed(2)} Go`;
}
