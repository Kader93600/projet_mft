"use client";

import { useState, useRef, useTransition } from "react";
import {
  UploadCloud,
  Loader2,
  AlertCircle,
  Trash2,
  FileText,
  Image as ImageIcon,
  FileArchive,
  ExternalLink,
} from "lucide-react";

export interface QuestionAttachment {
  id: string;
  file_name: string;
  mime_type: string;
  kind: string;
  label: string | null;
  size_bytes: number | null;
  signedUrl: string | null;
}

const MAX_BYTES = 15 * 1024 * 1024;

/**
 * Gestionnaire d'annexes pour une question : upload (drag-drop + picker),
 * preview inline pour les images, lien iframe/download pour les autres,
 * suppression avec confirmation simple.
 *
 * Communication serveur via les API routes :
 *   - POST   /api/admin/questions/[id]/attachments
 *   - DELETE /api/admin/questions/[id]/attachments?attachmentId=...
 */
export function AttachmentManager({
  questionId,
  initial,
}: {
  questionId: string;
  initial: QuestionAttachment[];
}) {
  const [attachments, setAttachments] = useState<QuestionAttachment[]>(initial);
  const [label, setLabel] = useState("");
  const [isUploading, setIsUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [dragOver, setDragOver] = useState(false);
  const [pending, startTransition] = useTransition();
  const fileInputRef = useRef<HTMLInputElement>(null);

  async function uploadFile(file: File) {
    setError(null);
    if (file.size > MAX_BYTES) {
      setError(`Fichier trop volumineux (max 15 Mo).`);
      return;
    }
    setIsUploading(true);
    try {
      const fd = new FormData();
      fd.append("file", file);
      if (label.trim()) fd.append("label", label.trim());

      const res = await fetch(
        `/api/admin/questions/${questionId}/attachments`,
        { method: "POST", body: fd },
      );
      const json = await res.json();
      if (!res.ok) {
        setError(json.error ?? "Échec de l'upload.");
        return;
      }
      setAttachments((prev) => [...prev, json.attachment]);
      setLabel("");
    } catch (e: any) {
      setError(e?.message ?? "Erreur réseau.");
    } finally {
      setIsUploading(false);
    }
  }

  async function onPickFiles(files: FileList | null) {
    if (!files || files.length === 0) return;
    for (let i = 0; i < files.length; i++) {
      await uploadFile(files[i]);
    }
    if (fileInputRef.current) fileInputRef.current.value = "";
  }

  function onRemove(attachmentId: string) {
    if (!confirm("Supprimer cette annexe ?")) return;
    startTransition(async () => {
      setError(null);
      try {
        const res = await fetch(
          `/api/admin/questions/${questionId}/attachments?attachmentId=${attachmentId}`,
          { method: "DELETE" },
        );
        const json = await res.json();
        if (!res.ok) {
          setError(json.error ?? "Suppression échouée.");
          return;
        }
        setAttachments((prev) => prev.filter((a) => a.id !== attachmentId));
      } catch (e: any) {
        setError(e?.message ?? "Erreur réseau.");
      }
    });
  }

  function onDrop(e: React.DragEvent) {
    e.preventDefault();
    setDragOver(false);
    onPickFiles(e.dataTransfer.files);
  }

  return (
    <div className="rounded-xl border border-navy-100 bg-ivory p-3 space-y-2.5">
      <div className="flex items-center justify-between gap-2 flex-wrap">
        <div className="text-[10.5px] uppercase tracking-wider text-slate-600 font-semibold">
          Annexes attachées à la question
        </div>
        <div className="text-[10px] text-slate-500">
          {attachments.length} fichier{attachments.length > 1 ? "s" : ""}
        </div>
      </div>

      {/* Liste des annexes */}
      {attachments.length > 0 && (
        <ul className="space-y-1.5">
          {attachments.map((a) => (
            <AttachmentRow
              key={a.id}
              attachment={a}
              onRemove={() => onRemove(a.id)}
              isDeleting={pending}
            />
          ))}
        </ul>
      )}

      {/* Zone upload */}
      <div
        onDragOver={(e) => {
          e.preventDefault();
          setDragOver(true);
        }}
        onDragLeave={() => setDragOver(false)}
        onDrop={onDrop}
        className={
          "rounded-lg border-2 border-dashed transition px-3 py-3 text-center cursor-pointer " +
          (dragOver
            ? "border-signal-500 bg-signal-50"
            : "border-navy-200 bg-white hover:border-signal-400 hover:bg-signal-50/30")
        }
        onClick={() => fileInputRef.current?.click()}
      >
        <input
          ref={fileInputRef}
          type="file"
          multiple
          accept="image/*,application/pdf,.doc,.docx,.xls,.xlsx,.txt,.csv"
          className="hidden"
          onChange={(e) => onPickFiles(e.target.files)}
        />
        {isUploading ? (
          <div className="inline-flex items-center gap-1.5 text-[12px] text-slate-600">
            <Loader2 className="h-3.5 w-3.5 animate-spin" />
            Upload en cours…
          </div>
        ) : (
          <div className="inline-flex items-center gap-1.5 text-[12px] text-slate-700">
            <UploadCloud className="h-3.5 w-3.5 text-signal-700" />
            <strong>Glisser un fichier</strong> ou cliquer pour choisir
            <span className="text-slate-500">· PDF, image, doc · 15 Mo max</span>
          </div>
        )}
      </div>

      {/* Label optionnel pour le prochain upload */}
      <div className="flex items-center gap-1.5">
        <input
          type="text"
          value={label}
          onChange={(e) => setLabel(e.target.value)}
          placeholder="Libellé optionnel pour le prochain fichier (ex. Tableau coûts)"
          className="flex-1 h-7 px-2 rounded border border-navy-100 bg-white text-[11.5px] text-navy-900"
        />
      </div>

      {error && (
        <div className="rounded-lg bg-rose-50 border border-rose-200 px-2.5 py-1.5 text-[12px] text-rose-800 flex items-start gap-1.5">
          <AlertCircle className="h-3 w-3 mt-0.5 shrink-0" />
          {error}
        </div>
      )}
    </div>
  );
}

// =====================================================================
// AttachmentRow — ligne avec icône / nom / actions, preview image inline
// =====================================================================
function AttachmentRow({
  attachment: a,
  onRemove,
  isDeleting,
}: {
  attachment: QuestionAttachment;
  onRemove: () => void;
  isDeleting: boolean;
}) {
  const Icon =
    a.kind === "image" ? ImageIcon : a.kind === "pdf" ? FileText : FileArchive;
  const sizeKo = a.size_bytes
    ? a.size_bytes < 1024 * 1024
      ? `${(a.size_bytes / 1024).toFixed(0)} Ko`
      : `${(a.size_bytes / 1024 / 1024).toFixed(1)} Mo`
    : "";

  return (
    <li className="rounded-lg bg-white border border-navy-100 px-2.5 py-1.5">
      <div className="flex items-center gap-2">
        <Icon className="h-3.5 w-3.5 text-slate-600 shrink-0" />
        <div className="flex-1 min-w-0">
          <div className="text-[12.5px] font-semibold text-navy-900 truncate">
            {a.label || a.file_name}
          </div>
          <div className="text-[10.5px] text-slate-500">
            {a.file_name} {sizeKo && `· ${sizeKo}`} · {a.kind}
          </div>
        </div>
        {a.signedUrl && (
          <a
            href={a.signedUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="h-7 w-7 rounded-md border border-navy-100 hover:bg-navy-50 inline-flex items-center justify-center text-slate-600"
            title="Ouvrir dans un nouvel onglet"
          >
            <ExternalLink className="h-3 w-3" />
          </a>
        )}
        <button
          type="button"
          onClick={onRemove}
          disabled={isDeleting}
          className="h-7 w-7 rounded-md border border-rose-100 hover:bg-rose-50 inline-flex items-center justify-center text-rose-700 disabled:opacity-50"
          title="Supprimer"
        >
          <Trash2 className="h-3 w-3" />
        </button>
      </div>
      {/* Preview inline pour les images */}
      {a.kind === "image" && a.signedUrl && (
        <div className="mt-1.5 rounded-md overflow-hidden bg-navy-50 border border-navy-100">
          <img
            src={a.signedUrl}
            alt={a.label || a.file_name}
            className="block w-full max-h-[160px] object-contain"
            loading="lazy"
          />
        </div>
      )}
    </li>
  );
}
