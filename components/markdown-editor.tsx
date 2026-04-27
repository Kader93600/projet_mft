"use client";
import { useState, useRef, useTransition } from "react";
import { Button } from "@/components/ui/button";
import { renderMarkdown } from "@/lib/markdown";
import {
  Bold,
  Italic,
  Heading1,
  Heading2,
  List,
  ListOrdered,
  Link2,
  Image as ImageIcon,
  Eye,
  Edit3,
  Quote,
  Code,
} from "lucide-react";
import { uploadMedia } from "@/app/admin/modules/actions";
import { useToast } from "@/components/ui/toast";

export function MarkdownEditor({
  value,
  onChange,
  rows = 18,
  placeholder,
}: {
  value: string;
  onChange: (v: string) => void;
  rows?: number;
  placeholder?: string;
}) {
  const [tab, setTab] = useState<"edit" | "preview">("edit");
  const [isPending, startTransition] = useTransition();
  const ref = useRef<HTMLTextAreaElement>(null);
  const fileRef = useRef<HTMLInputElement>(null);
  const { toast } = useToast();

  function wrap(prefix: string, suffix = prefix) {
    const el = ref.current;
    if (!el) return;
    const start = el.selectionStart;
    const end = el.selectionEnd;
    const selected = value.slice(start, end) || "texte";
    const before = value.slice(0, start);
    const after = value.slice(end);
    const next = `${before}${prefix}${selected}${suffix}${after}`;
    onChange(next);
    requestAnimationFrame(() => {
      el.focus();
      el.setSelectionRange(start + prefix.length, start + prefix.length + selected.length);
    });
  }

  function prepend(token: string) {
    const el = ref.current;
    if (!el) return;
    const start = el.selectionStart;
    const lineStart = value.lastIndexOf("\n", start - 1) + 1;
    const before = value.slice(0, lineStart);
    const after = value.slice(lineStart);
    onChange(`${before}${token}${after}`);
    requestAnimationFrame(() => {
      el.focus();
      el.setSelectionRange(start + token.length, start + token.length);
    });
  }

  function insertImage(url: string) {
    const el = ref.current;
    if (!el) return;
    const pos = el.selectionStart;
    const snippet = `\n\n![image](${url})\n\n`;
    onChange(value.slice(0, pos) + snippet + value.slice(pos));
  }

  async function onFileChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    if (file.size > 5 * 1024 * 1024) {
      toast("Image > 5 MB", "error");
      return;
    }
    startTransition(async () => {
      try {
        const fd = new FormData();
        fd.append("file", file);
        const { url } = await uploadMedia(fd);
        insertImage(url);
        toast("Image insérée", "success");
      } catch (err: any) {
        toast(err.message, "error");
      }
    });
    e.target.value = "";
  }

  return (
    <div className="rounded-xl border border-navy-100 overflow-hidden bg-white">
      {/* Toolbar */}
      <div className="flex items-center justify-between px-2 py-1.5 border-b border-navy-100 bg-navy-50/40">
        <div className="flex items-center gap-0.5 flex-wrap">
          <ToolBtn onClick={() => prepend("# ")} title="Titre 1"><Heading1 className="h-4 w-4" /></ToolBtn>
          <ToolBtn onClick={() => prepend("## ")} title="Titre 2"><Heading2 className="h-4 w-4" /></ToolBtn>
          <Sep />
          <ToolBtn onClick={() => wrap("**")} title="Gras"><Bold className="h-4 w-4" /></ToolBtn>
          <ToolBtn onClick={() => wrap("*")} title="Italique"><Italic className="h-4 w-4" /></ToolBtn>
          <ToolBtn onClick={() => wrap("`")} title="Code"><Code className="h-4 w-4" /></ToolBtn>
          <Sep />
          <ToolBtn onClick={() => prepend("- ")} title="Liste"><List className="h-4 w-4" /></ToolBtn>
          <ToolBtn onClick={() => prepend("1. ")} title="Liste numérotée"><ListOrdered className="h-4 w-4" /></ToolBtn>
          <ToolBtn onClick={() => prepend("> ")} title="Citation"><Quote className="h-4 w-4" /></ToolBtn>
          <Sep />
          <ToolBtn onClick={() => wrap("[", "](https://)")} title="Lien"><Link2 className="h-4 w-4" /></ToolBtn>
          <ToolBtn
            onClick={() => fileRef.current?.click()}
            title="Image"
            disabled={isPending}
          >
            <ImageIcon className="h-4 w-4" />
          </ToolBtn>
          <input
            ref={fileRef}
            type="file"
            accept="image/*"
            className="hidden"
            onChange={onFileChange}
          />
        </div>
        <div className="flex items-center gap-0.5 bg-white rounded-lg p-0.5 border border-navy-100">
          <button
            type="button"
            onClick={() => setTab("edit")}
            className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-md text-xs font-medium transition ${
              tab === "edit" ? "bg-navy-900 text-white" : "text-slate-600 hover:text-navy-900"
            }`}
          >
            <Edit3 className="h-3.5 w-3.5" /> Édition
          </button>
          <button
            type="button"
            onClick={() => setTab("preview")}
            className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-md text-xs font-medium transition ${
              tab === "preview" ? "bg-navy-900 text-white" : "text-slate-600 hover:text-navy-900"
            }`}
          >
            <Eye className="h-3.5 w-3.5" /> Aperçu
          </button>
        </div>
      </div>

      {/* Body */}
      {tab === "edit" ? (
        <textarea
          ref={ref}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          rows={rows}
          placeholder={placeholder}
          className="w-full p-4 text-sm font-mono leading-relaxed outline-none resize-y min-h-[240px] bg-white text-navy-900"
        />
      ) : (
        <div
          className="prose prose-slate max-w-none p-5 min-h-[240px]"
          dangerouslySetInnerHTML={{ __html: renderMarkdown(value || "*Rien à afficher*") }}
        />
      )}
      {isPending && (
        <div className="px-4 py-2 text-xs text-slate-500 bg-navy-50/40 border-t border-navy-100">
          Upload en cours…
        </div>
      )}
    </div>
  );
}

function ToolBtn({
  children,
  title,
  onClick,
  disabled,
}: {
  children: React.ReactNode;
  title: string;
  onClick: () => void;
  disabled?: boolean;
}) {
  return (
    <button
      type="button"
      title={title}
      onClick={onClick}
      disabled={disabled}
      className="h-8 w-8 inline-flex items-center justify-center rounded-md text-slate-600 hover:bg-white hover:text-navy-900 disabled:opacity-40"
    >
      {children}
    </button>
  );
}

function Sep() {
  return <span className="w-px h-5 bg-navy-100 mx-1" />;
}
