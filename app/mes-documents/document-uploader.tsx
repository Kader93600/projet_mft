"use client";

import { useRef, useState, type DragEvent } from "react";
import { useRouter } from "next/navigation";
import {
  UploadCloud,
  FileText,
  FileSpreadsheet,
  Image as ImageIcon,
  File as FileIcon,
  X,
  Loader2,
  Send,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import { cn } from "@/lib/utils";
import {
  DOC_REASONS,
  MAX_DOC_SIZE,
  ACCEPT_ATTR,
  isAcceptedFile,
  fileKind,
  formatBytes,
  type FileKind,
} from "@/lib/student-documents";
import {
  UploadToast,
  type UploadToastData,
} from "@/components/celebration/upload-toast";
import { createUploadUrl, finalizeUpload } from "./actions";

const KIND_ICON: Record<FileKind, { Icon: any; cls: string }> = {
  pdf: { Icon: FileText, cls: "bg-rose-100 text-rose-600" },
  word: { Icon: FileText, cls: "bg-sky-100 text-sky-700" },
  excel: { Icon: FileSpreadsheet, cls: "bg-emerald-100 text-emerald-700" },
  image: { Icon: ImageIcon, cls: "bg-violet-100 text-violet-700" },
  other: { Icon: FileIcon, cls: "bg-slate-100 text-slate-600" },
};

export function DocumentUploader() {
  const router = useRouter();
  const inputRef = useRef<HTMLInputElement>(null);
  const [file, setFile] = useState<File | null>(null);
  const [dragging, setDragging] = useState(false);
  const [title, setTitle] = useState("");
  const [reason, setReason] = useState("");
  const [customReason, setCustomReason] = useState("");
  const [busy, setBusy] = useState(false);
  const [progress, setProgress] = useState(0);
  const [toast, setToast] = useState<UploadToastData | null>(null);

  function pickFile(f: File | null) {
    if (!f) return;
    if (!isAcceptedFile(f.name)) {
      setToast({
        kind: "error",
        title: "Format non autorisé",
        message: "Formats acceptés : PDF, Word, Excel, JPG, PNG.",
      });
      return;
    }
    if (f.size > MAX_DOC_SIZE) {
      setToast({
        kind: "error",
        title: "Fichier trop volumineux",
        message: `${formatBytes(f.size)} — maximum 10 Mo.`,
      });
      return;
    }
    setFile(f);
    if (!title) setTitle(f.name.replace(/\.[^.]+$/, ""));
  }

  function onDrop(e: DragEvent) {
    e.preventDefault();
    setDragging(false);
    pickFile(e.dataTransfer.files?.[0] ?? null);
  }

  function reset() {
    setFile(null);
    setTitle("");
    setReason("");
    setCustomReason("");
    setProgress(0);
  }

  const canSubmit =
    !!file &&
    title.trim().length > 0 &&
    reason.length > 0 &&
    (reason !== "autres" || customReason.trim().length > 0) &&
    !busy;

  function putWithProgress(signedUrl: string, f: File): Promise<void> {
    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      xhr.open("PUT", signedUrl);
      xhr.setRequestHeader("x-upsert", "false");
      if (f.type) xhr.setRequestHeader("content-type", f.type);
      xhr.upload.onprogress = (ev) => {
        if (ev.lengthComputable) {
          setProgress(Math.round((ev.loaded / ev.total) * 100));
        }
      };
      xhr.onload = () =>
        xhr.status >= 200 && xhr.status < 300
          ? resolve()
          : reject(new Error(`HTTP ${xhr.status}`));
      xhr.onerror = () => reject(new Error("network"));
      xhr.send(f);
    });
  }

  async function submit() {
    if (!file || !canSubmit) return;
    setBusy(true);
    setProgress(0);
    setToast({ kind: "loading", title: "Import en cours…", message: file.name });
    try {
      const prep = await createUploadUrl({
        fileName: file.name,
        sizeBytes: file.size,
      });
      if (!prep.ok) throw new Error(prep.error);
      await putWithProgress(prep.signedUrl, file);
      const fin = await finalizeUpload({
        path: prep.path,
        title: title.trim(),
        reason,
        customReason: customReason.trim() || undefined,
        fileName: file.name,
        mimeType: file.type || undefined,
        sizeBytes: file.size,
      });
      if (!fin.ok) throw new Error(fin.error);
      setToast({
        kind: "success",
        title: "Document importé",
        message: "L'administration a été notifiée.",
      });
      reset();
      router.refresh();
    } catch (e: any) {
      setToast({
        kind: "error",
        title: "Échec de l'import",
        message: e?.message?.slice(0, 80) || "Réessayez dans un instant.",
      });
    } finally {
      setBusy(false);
    }
  }

  const kind = file ? fileKind(file.name) : "other";
  const KindIcon = KIND_ICON[kind];

  return (
    <div>
      <UploadToast toast={toast} onClose={() => setToast(null)} />

      {!file ? (
        <button
          type="button"
          onClick={() => inputRef.current?.click()}
          onDragOver={(e) => {
            e.preventDefault();
            setDragging(true);
          }}
          onDragLeave={() => setDragging(false)}
          onDrop={onDrop}
          className={cn(
            "group flex w-full flex-col items-center justify-center gap-3 rounded-2xl border-2 border-dashed px-6 py-10 text-center transition-[border-color,background-color,transform] duration-200 ease-premium",
            "focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-500/30",
            dragging
              ? "border-signal-500 bg-signal-50/60 scale-[1.01]"
              : "border-navy-200 bg-white hover:border-brand-300 hover:bg-brand-50/30 dark:border-[hsl(var(--border))] dark:bg-[hsl(var(--surface))]"
          )}
        >
          <span
            className={cn(
              "inline-flex h-14 w-14 items-center justify-center rounded-2xl bg-brand-50 text-brand-700 transition-transform duration-200 ease-premium group-hover:-translate-y-0.5 dark:bg-brand-500/15 dark:text-brand-300",
              dragging && "bg-signal-100 text-signal-700"
            )}
          >
            <UploadCloud className="h-7 w-7" />
          </span>
          <span className="text-sm font-semibold text-navy-900 dark:text-[hsl(var(--text))]">
            Glissez un fichier ici, ou cliquez pour parcourir
          </span>
          <span className="text-xs text-slate-500 dark:text-[hsl(var(--text-muted))]">
            PDF, Word, Excel, JPG, PNG · 10 Mo maximum
          </span>
          <input
            ref={inputRef}
            type="file"
            accept={ACCEPT_ATTR}
            className="hidden"
            onChange={(e) => pickFile(e.target.files?.[0] ?? null)}
          />
        </button>
      ) : (
        <div className="space-y-4 rounded-2xl border border-navy-100 bg-white p-5 dark:border-[hsl(var(--border))] dark:bg-[hsl(var(--surface))]">
          {/* Aperçu fichier */}
          <div className="flex items-center gap-3">
            <span
              className={cn(
                "inline-flex h-11 w-11 shrink-0 items-center justify-center rounded-xl",
                KindIcon.cls
              )}
            >
              <KindIcon.Icon className="h-5 w-5" />
            </span>
            <div className="min-w-0 flex-1">
              <p className="truncate text-sm font-semibold text-navy-900 dark:text-[hsl(var(--text))]">
                {file.name}
              </p>
              <p className="text-xs text-slate-500 dark:text-[hsl(var(--text-muted))]">
                {formatBytes(file.size)} · {kind.toUpperCase()}
              </p>
            </div>
            {!busy && (
              <button
                type="button"
                onClick={reset}
                aria-label="Retirer le fichier"
                className="inline-flex h-8 w-8 items-center justify-center rounded-lg text-slate-400 transition-colors hover:bg-navy-50 hover:text-rose-600 dark:hover:bg-white/10"
              >
                <X className="h-4 w-4" />
              </button>
            )}
          </div>

          {/* Barre de progression */}
          {busy && (
            <div>
              <div className="mb-1 flex items-center justify-between text-xs font-medium text-slate-500">
                <span>Envoi…</span>
                <span className="tabular-nums">{progress}%</span>
              </div>
              <div className="h-2 w-full overflow-hidden rounded-full bg-navy-100 dark:bg-white/10">
                <div
                  className="h-full rounded-full bg-gradient-to-r from-brand-500 to-signal-500 transition-[width] duration-200 ease-out"
                  style={{ width: `${progress}%` }}
                />
              </div>
            </div>
          )}

          {/* Métadonnées */}
          <div className="grid gap-4 sm:grid-cols-2">
            <div className={reason === "autres" ? "sm:col-span-1" : "sm:col-span-1"}>
              <Label htmlFor="doc-title">Titre du document</Label>
              <Input
                id="doc-title"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="Ex. Justificatif arrêt maladie"
                disabled={busy}
              />
            </div>
            <div>
              <Label htmlFor="doc-reason">Motif</Label>
              <select
                id="doc-reason"
                value={reason}
                onChange={(e) => setReason(e.target.value)}
                disabled={busy}
                className="h-11 w-full rounded-xl border border-navy-200 bg-white px-3.5 text-[15px] text-navy-900 transition-all duration-150 focus:border-navy-600 focus:outline-none focus:ring-2 focus:ring-navy-600/15 disabled:bg-navy-50 dark:border-[hsl(var(--border))] dark:bg-[hsl(var(--surface))] dark:text-[hsl(var(--text))]"
              >
                <option value="" disabled>
                  Sélectionnez un motif…
                </option>
                {DOC_REASONS.map((r) => (
                  <option key={r.key} value={r.key}>
                    {r.label}
                  </option>
                ))}
              </select>
            </div>
            {reason === "autres" && (
              <div className="sm:col-span-2">
                <Label htmlFor="doc-custom">Motif personnalisé</Label>
                <Input
                  id="doc-custom"
                  value={customReason}
                  onChange={(e) => setCustomReason(e.target.value)}
                  placeholder="Précisez le motif du document"
                  disabled={busy}
                />
              </div>
            )}
          </div>

          <div className="flex items-center justify-end gap-2 pt-1">
            <Button
              type="button"
              variant="secondary"
              onClick={reset}
              disabled={busy}
            >
              Annuler
            </Button>
            <Button type="button" onClick={submit} disabled={!canSubmit}>
              {busy ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                <Send className="h-4 w-4" />
              )}
              Importer le document
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}
