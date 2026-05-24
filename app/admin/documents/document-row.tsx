"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import {
  FileText,
  FileSpreadsheet,
  Image as ImageIcon,
  File as FileIcon,
  Eye,
  Download,
  MessageSquarePlus,
  Loader2,
  Check,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { DOC_STATUS, type FileKind } from "@/lib/student-documents";
import { setDocumentStatus, setDocumentNote } from "./actions";

const KIND_ICON: Record<FileKind, { Icon: any; cls: string }> = {
  pdf: { Icon: FileText, cls: "bg-rose-100 text-rose-600" },
  word: { Icon: FileText, cls: "bg-sky-100 text-sky-700" },
  excel: { Icon: FileSpreadsheet, cls: "bg-emerald-100 text-emerald-700" },
  image: { Icon: ImageIcon, cls: "bg-violet-100 text-violet-700" },
  other: { Icon: FileIcon, cls: "bg-slate-100 text-slate-600" },
};

export function DocumentRow({
  id,
  title,
  studentName,
  formation,
  motif,
  kind,
  meta,
  status,
  adminNote,
  url,
  fileName,
}: {
  id: string;
  title: string;
  studentName: string;
  formation: string;
  motif: string;
  kind: FileKind;
  meta: string;
  status: string;
  adminNote: string | null;
  url?: string;
  fileName: string;
}) {
  const router = useRouter();
  const [pending, start] = useTransition();
  const [noteOpen, setNoteOpen] = useState(false);
  const [note, setNote] = useState(adminNote ?? "");
  const [savedNote, setSavedNote] = useState(false);
  const KI = KIND_ICON[kind];

  function changeStatus(next: string) {
    start(async () => {
      await setDocumentStatus(id, next);
      router.refresh();
    });
  }
  function saveNote() {
    start(async () => {
      await setDocumentNote(id, note);
      setSavedNote(true);
      setTimeout(() => setSavedNote(false), 1800);
      router.refresh();
    });
  }

  return (
    <div className="rounded-xl border border-navy-100 bg-white p-4 dark:border-[hsl(var(--border))] dark:bg-[hsl(var(--surface))]">
      <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
        <div className="flex min-w-0 items-start gap-3">
          <span
            className={cn(
              "inline-flex h-10 w-10 shrink-0 items-center justify-center rounded-xl",
              KI.cls
            )}
          >
            <KI.Icon className="h-5 w-5" />
          </span>
          <div className="min-w-0">
            <div className="truncate font-semibold text-navy-900 dark:text-[hsl(var(--text))]">
              {title}
            </div>
            <div className="mt-0.5 truncate text-xs text-slate-500 dark:text-[hsl(var(--text-muted))]">
              <span className="font-medium text-navy-700 dark:text-white/80">
                {studentName}
              </span>
              {formation ? ` · ${formation}` : ""} · {motif} · {meta}
            </div>
          </div>
        </div>

        <div className="flex shrink-0 flex-wrap items-center gap-2">
          <select
            value={status}
            onChange={(e) => changeStatus(e.target.value)}
            disabled={pending}
            className="h-9 rounded-lg border border-navy-200 bg-white px-2.5 text-xs font-medium text-navy-900 focus:border-navy-600 focus:outline-none focus:ring-2 focus:ring-navy-600/15 disabled:opacity-60 dark:border-[hsl(var(--border))] dark:bg-[hsl(var(--surface))] dark:text-[hsl(var(--text))]"
          >
            {Object.entries(DOC_STATUS).map(([k, v]) => (
              <option key={k} value={k}>
                {v.label}
              </option>
            ))}
          </select>
          {url && (
            <a
              href={url}
              target="_blank"
              rel="noopener noreferrer"
              title="Voir"
              className="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-navy-200 bg-white text-navy-700 transition-colors hover:bg-navy-50 dark:border-[hsl(var(--border))] dark:bg-transparent"
            >
              <Eye className="h-4 w-4" />
            </a>
          )}
          {url && (
            <a
              href={`${url}&download=${encodeURIComponent(fileName)}`}
              title="Télécharger"
              className="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-navy-200 bg-white text-navy-700 transition-colors hover:bg-navy-50 dark:border-[hsl(var(--border))] dark:bg-transparent"
            >
              <Download className="h-4 w-4" />
            </a>
          )}
          <button
            type="button"
            onClick={() => setNoteOpen((o) => !o)}
            title="Remarque interne"
            className={cn(
              "inline-flex h-9 items-center gap-1 rounded-lg border px-2.5 text-xs font-medium transition-colors",
              adminNote
                ? "border-gold-200 bg-gold-50 text-gold-800"
                : "border-navy-200 bg-white text-navy-700 hover:bg-navy-50 dark:border-[hsl(var(--border))] dark:bg-transparent"
            )}
          >
            <MessageSquarePlus className="h-4 w-4" />
            Remarque
          </button>
        </div>
      </div>

      {noteOpen && (
        <div className="mt-3 border-t border-navy-50 pt-3 dark:border-white/10">
          <textarea
            value={note}
            onChange={(e) => setNote(e.target.value)}
            placeholder="Remarque interne (visible par l'équipe uniquement)…"
            rows={2}
            className="w-full rounded-lg border border-navy-200 bg-white px-3 py-2 text-sm text-navy-900 focus:border-navy-600 focus:outline-none focus:ring-2 focus:ring-navy-600/15 dark:border-[hsl(var(--border))] dark:bg-[hsl(var(--surface))] dark:text-[hsl(var(--text))]"
          />
          <div className="mt-2 flex items-center justify-end gap-2">
            {savedNote && (
              <span className="inline-flex items-center gap-1 text-xs font-medium text-emerald-600">
                <Check className="h-3.5 w-3.5" /> Enregistré
              </span>
            )}
            <button
              type="button"
              onClick={saveNote}
              disabled={pending || note === (adminNote ?? "")}
              className="inline-flex items-center gap-1 rounded-lg bg-navy-900 px-3 py-1.5 text-xs font-semibold text-white transition-colors hover:bg-navy-800 disabled:opacity-50"
            >
              {pending ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : null}
              Enregistrer
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
