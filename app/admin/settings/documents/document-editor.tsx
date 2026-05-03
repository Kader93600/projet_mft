"use client";
import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { MarkdownEditor } from "@/components/markdown-editor";
import { updateDocument } from "./actions";
import { Save, Loader2, AlertTriangle, Download } from "lucide-react";

export function DocumentEditor({ doc }: { doc: any }) {
  const router = useRouter();
  const [pending, start] = useTransition();
  const [title, setTitle] = useState(doc.title);
  const [content, setContent] = useState(doc.content_md);
  const [published, setPublished] = useState(doc.published);
  const [bump, setBump] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [ok, setOk] = useState(false);

  const contentChanged = content !== doc.content_md;
  const hadAcceptances = doc.published; // conservative

  const submit = () => {
    setErr(null);
    setOk(false);
    start(async () => {
      try {
        await updateDocument({
          id: doc.id,
          title,
          content_md: content,
          published,
          bump_version: bump,
        });
        setOk(true);
        setBump(false);
        router.refresh();
      } catch (e: any) {
        setErr(e.message);
      }
    });
  };

  return (
    <div className="space-y-4">
      <label className="block">
        <span className="block text-sm font-medium text-navy-900 mb-1">
          Titre
        </span>
        <Input value={title} onChange={(e) => setTitle(e.target.value)} />
      </label>

      <div>
        <div className="block text-sm font-medium text-navy-900 mb-1">
          Contenu (Markdown)
        </div>
        <MarkdownEditor value={content} onChange={setContent} rows={14} />
      </div>

      {contentChanged && hadAcceptances && (
        <div className="flex items-start gap-3 rounded-xl bg-amber-50 border border-amber-200 px-4 py-3 text-sm text-amber-900">
          <AlertTriangle className="h-4 w-4 mt-0.5 shrink-0" />
          <div>
            <div className="font-semibold mb-1">
              Ce document a déjà été accepté par des stagiaires.
            </div>
            <p className="text-xs text-amber-800/80 mb-2">
              Pour qu'ils ré-acceptent la nouvelle version, cochez ci-dessous —
              la version sera incrémentée et les acceptations précédentes
              resteront historiques.
            </p>
            <label className="inline-flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={bump}
                onChange={(e) => setBump(e.target.checked)}
                className="accent-gold-500"
              />
              <span className="text-sm font-medium">
                Publier comme nouvelle version (v{doc.version + 1})
              </span>
            </label>
          </div>
        </div>
      )}

      <div className="flex items-center justify-between pt-4 border-t border-navy-50">
        <label className="inline-flex items-center gap-2 cursor-pointer">
          <input
            type="checkbox"
            checked={published}
            onChange={(e) => setPublished(e.target.checked)}
            className="accent-gold-500"
          />
          <span className="text-sm font-medium text-navy-900">
            Publié (présenté aux stagiaires)
          </span>
        </label>

        <div className="flex items-center gap-3">
          {err && <span className="text-sm text-rose-700">{err}</span>}
          {ok && <span className="text-sm text-emerald-700">Enregistré.</span>}
          {contentChanged && (
            <span className="text-xs text-slate-500 italic">
              Enregistre avant d'exporter
            </span>
          )}
          <a
            href={`/admin/settings/documents/export/${doc.id}`}
            target="_blank"
            rel="noopener"
            aria-disabled={contentChanged}
            onClick={(e) => {
              if (contentChanged) {
                e.preventDefault();
                setErr(
                  "Modifications non enregistrées : enregistre d'abord pour les inclure dans le PDF."
                );
              }
            }}
            className={
              "inline-flex items-center gap-2 rounded-xl border border-navy-200 bg-white px-3 py-2 text-sm font-medium text-navy-900 hover:bg-navy-50 hover:border-navy-300 transition-colors " +
              (contentChanged ? "opacity-60 cursor-not-allowed" : "")
            }
          >
            <Download className="h-4 w-4" />
            Exporter PDF
          </a>
          <Button onClick={submit} disabled={pending} variant="gold">
            {pending ? (
              <>
                <Loader2 className="h-4 w-4 animate-spin" /> Enregistrement…
              </>
            ) : (
              <>
                <Save className="h-4 w-4" /> Enregistrer
              </>
            )}
          </Button>
        </div>
      </div>
    </div>
  );
}
