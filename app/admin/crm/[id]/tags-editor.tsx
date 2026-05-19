"use client";

import { useState, useTransition } from "react";
import { Plus, X, Loader2 } from "lucide-react";
import { addTag, removeTag } from "../actions";

export function TagsEditor({
  leadId,
  tags,
  canEdit,
}: {
  leadId: string;
  tags: string[];
  canEdit: boolean;
}) {
  const [pending, startTransition] = useTransition();
  const [newTag, setNewTag] = useState("");
  const [error, setError] = useState<string | null>(null);

  const add = () => {
    const v = newTag.trim().toLowerCase();
    if (!v) return;
    if (v.length > 30) {
      setError("30 caractères max");
      return;
    }
    setError(null);
    startTransition(async () => {
      const res = await addTag(leadId, v);
      if (!res.ok) {
        setError(res.error ?? "Erreur");
        return;
      }
      setNewTag("");
    });
  };

  const remove = (tag: string) => {
    setError(null);
    startTransition(async () => {
      const res = await removeTag(leadId, tag);
      if (!res.ok) setError(res.error ?? "Erreur");
    });
  };

  return (
    <div className="space-y-2">
      <div className="flex flex-wrap gap-1.5">
        {tags.length === 0 && !canEdit && (
          <span className="text-xs text-slate-500 italic">Aucun tag</span>
        )}
        {tags.map((t) => (
          <span
            key={t}
            className="inline-flex items-center gap-1 text-xs uppercase tracking-wider text-slate-700 bg-slate-100 border border-slate-200 rounded px-2 py-0.5"
          >
            #{t}
            {canEdit && (
              <button
                type="button"
                onClick={() => remove(t)}
                disabled={pending}
                aria-label={`Retirer le tag ${t}`}
                className="text-slate-400 hover:text-rose-600"
              >
                <X className="h-2.5 w-2.5" />
              </button>
            )}
          </span>
        ))}
      </div>

      {canEdit && (
        <div className="flex items-center gap-1.5">
          <input
            type="text"
            value={newTag}
            onChange={(e) => setNewTag(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter") {
                e.preventDefault();
                add();
              }
            }}
            placeholder="Ajouter un tag…"
            maxLength={30}
            className="flex-1 min-w-0 rounded-md border border-navy-100 bg-white px-2 py-1 text-xs focus:outline-none focus:ring-2 focus:ring-gold-400"
          />
          <button
            type="button"
            onClick={add}
            disabled={pending || !newTag.trim()}
            className="inline-flex items-center justify-center h-7 w-7 rounded-md bg-navy-900 text-white disabled:opacity-50 hover:bg-navy-800 transition-colors"
          >
            {pending ? (
              <Loader2 className="h-3.5 w-3.5 animate-spin" />
            ) : (
              <Plus className="h-3.5 w-3.5" />
            )}
          </button>
        </div>
      )}

      {error && <p className="text-xs text-rose-700">{error}</p>}
    </div>
  );
}
