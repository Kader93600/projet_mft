"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { Trash2, Loader2 } from "lucide-react";
import { deleteStudentDocument } from "./actions";

export function DeleteDocButton({ id }: { id: string }) {
  const router = useRouter();
  const [pending, start] = useTransition();
  const [confirm, setConfirm] = useState(false);

  function onDelete() {
    start(async () => {
      await deleteStudentDocument(id);
      setConfirm(false);
      router.refresh();
    });
  }

  if (confirm) {
    return (
      <span className="inline-flex items-center gap-1.5">
        <button
          type="button"
          onClick={onDelete}
          disabled={pending}
          className="inline-flex items-center gap-1 rounded-lg bg-rose-600 px-2.5 py-1.5 text-xs font-semibold text-white transition-colors hover:bg-rose-700 disabled:opacity-60"
        >
          {pending ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : null}
          Confirmer
        </button>
        <button
          type="button"
          onClick={() => setConfirm(false)}
          disabled={pending}
          className="rounded-lg px-2 py-1.5 text-xs font-medium text-slate-500 transition-colors hover:text-navy-900"
        >
          Annuler
        </button>
      </span>
    );
  }

  return (
    <button
      type="button"
      onClick={() => setConfirm(true)}
      title="Supprimer"
      className="inline-flex items-center gap-1 rounded-lg border border-navy-200 bg-white px-2.5 py-1.5 text-xs font-medium text-slate-600 transition-colors hover:border-rose-300 hover:bg-rose-50 hover:text-rose-700 dark:border-[hsl(var(--border))] dark:bg-transparent"
    >
      <Trash2 className="h-3.5 w-3.5" />
      Supprimer
    </button>
  );
}
