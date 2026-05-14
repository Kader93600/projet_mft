"use client";

import { useState, useTransition } from "react";
import { Button } from "@/components/ui/button";
import {
  Play,
  Square,
  Trash2,
  XCircle,
  Loader2,
  MoreHorizontal,
  AlertCircle,
} from "lucide-react";
import {
  setSessionStatus,
  cancelSession,
  deleteSession,
} from "../actions";

export function SessionActions({
  sessionId,
  status,
  basePath = "/admin/sessions",
}: {
  sessionId: string;
  status: string;
  basePath?: string;
}) {
  const [pending, startTransition] = useTransition();
  const [error, setError] = useState<string | null>(null);
  const [open, setOpen] = useState(false);

  function run(fn: () => Promise<void>) {
    setError(null);
    startTransition(async () => {
      try {
        await fn();
        setOpen(false);
      } catch (e: any) {
        setError(e.message ?? "Erreur");
      }
    });
  }

  return (
    <div className="relative inline-flex items-center gap-2">
      {status === "scheduled" && (
        <Button
          variant="gold"
          size="sm"
          disabled={pending}
          onClick={() => run(() => setSessionStatus(sessionId, "in_progress"))}
        >
          {pending ? (
            <Loader2 className="h-4 w-4 animate-spin" />
          ) : (
            <Play className="h-4 w-4" />
          )}
          Démarrer
        </Button>
      )}
      {status === "in_progress" && (
        <Button
          variant="secondary"
          size="sm"
          disabled={pending}
          onClick={() => run(() => setSessionStatus(sessionId, "completed"))}
        >
          {pending ? (
            <Loader2 className="h-4 w-4 animate-spin" />
          ) : (
            <Square className="h-4 w-4" />
          )}
          Clôturer
        </Button>
      )}

      <div className="relative">
        <Button
          variant="ghost"
          size="sm"
          onClick={() => setOpen((v) => !v)}
          aria-label="Plus d'actions"
        >
          <MoreHorizontal className="h-4 w-4" />
        </Button>
        {open && (
          <div className="absolute right-0 top-full mt-1 w-56 rounded-xl border border-navy-100 bg-white shadow-raised z-20 overflow-hidden">
            {status !== "cancelled" && status !== "completed" && (
              <button
                type="button"
                disabled={pending}
                onClick={() => {
                  if (!confirm("Annuler cette session ?")) return;
                  run(() => cancelSession(sessionId));
                }}
                className="w-full text-left px-4 py-2.5 text-sm text-navy-900 hover:bg-rose-50 hover:text-rose-700 inline-flex items-center gap-2"
              >
                <XCircle className="h-4 w-4" />
                Annuler la session
              </button>
            )}
            <button
              type="button"
              disabled={pending}
              onClick={() => {
                if (
                  !confirm(
                    "Supprimer définitivement cette session ?\nLes émargements seront perdus."
                  )
                )
                  return;
                run(() => deleteSession(sessionId, basePath));
              }}
              className="w-full text-left px-4 py-2.5 text-sm text-rose-700 hover:bg-rose-50 inline-flex items-center gap-2 border-t border-navy-100"
            >
              <Trash2 className="h-4 w-4" />
              Supprimer
            </button>
          </div>
        )}
      </div>
      {error && (
        <div className="absolute right-0 top-full mt-12 w-72 rounded-lg bg-rose-50 border border-rose-200 px-3 py-2 text-xs text-rose-800 flex items-center gap-2 shadow-soft z-30">
          <AlertCircle className="h-4 w-4 shrink-0" />
          {error}
        </div>
      )}
    </div>
  );
}
