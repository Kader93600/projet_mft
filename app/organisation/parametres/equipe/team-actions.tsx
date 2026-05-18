"use client";

import { useState, useTransition } from "react";
import { Trash2, Loader2 } from "lucide-react";
import { removeMember } from "./actions";

export function TeamMemberActions({ memberId }: { memberId: string }) {
  const [pending, startTransition] = useTransition();
  const [confirm, setConfirm] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [done, setDone] = useState(false);

  if (done) {
    return <span className="text-xs text-slate-500">Retiré</span>;
  }

  if (confirm) {
    return (
      <div className="flex items-center gap-2">
        <button
          type="button"
          onClick={() => {
            setError(null);
            startTransition(async () => {
              const res = await removeMember(memberId);
              if (!res.ok) {
                setError(res.error ?? "Erreur");
                return;
              }
              setDone(true);
            });
          }}
          disabled={pending}
          className="inline-flex items-center gap-1 rounded-lg bg-rose-600 hover:bg-rose-500 text-white text-xs font-medium px-2 py-1 transition-colors disabled:opacity-60"
        >
          {pending ? (
            <Loader2 className="h-3 w-3 animate-spin" />
          ) : (
            <Trash2 className="h-3 w-3" />
          )}
          Confirmer
        </button>
        <button
          type="button"
          onClick={() => {
            setConfirm(false);
            setError(null);
          }}
          disabled={pending}
          className="text-xs text-slate-600 hover:text-navy-900"
        >
          Annuler
        </button>
        {error && <span className="text-xs text-rose-700">{error}</span>}
      </div>
    );
  }

  return (
    <button
      type="button"
      onClick={() => setConfirm(true)}
      aria-label="Retirer ce membre"
      title="Retirer ce membre de l'organisation"
      className="h-7 w-7 rounded-md text-slate-400 hover:text-rose-700 hover:bg-rose-50 transition-colors flex items-center justify-center"
    >
      <Trash2 className="h-3.5 w-3.5" />
    </button>
  );
}
