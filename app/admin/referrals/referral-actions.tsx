"use client";

import { useState, useTransition } from "react";
import { CheckCircle2, X, Loader2 } from "lucide-react";
import { approveReferral, rejectReferral } from "./actions";

export function ReferralActions({ referralId }: { referralId: string }) {
  const [pending, startTransition] = useTransition();
  const [showReject, setShowReject] = useState(false);
  const [reason, setReason] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [done, setDone] = useState<"approved" | "rejected" | null>(null);

  const onApprove = () => {
    setError(null);
    startTransition(async () => {
      const res = await approveReferral(referralId);
      if (!res.ok) {
        setError(res.error ?? "Erreur");
        return;
      }
      setDone("approved");
    });
  };

  const onReject = () => {
    setError(null);
    if (!reason.trim()) {
      setError("Indiquez un motif de refus");
      return;
    }
    startTransition(async () => {
      const res = await rejectReferral(referralId, reason);
      if (!res.ok) {
        setError(res.error ?? "Erreur");
        return;
      }
      setDone("rejected");
    });
  };

  if (done) {
    return (
      <div
        className={
          done === "approved"
            ? "inline-flex items-center gap-1.5 text-sm font-medium text-emerald-700"
            : "inline-flex items-center gap-1.5 text-sm font-medium text-rose-700"
        }
      >
        {done === "approved" ? (
          <>
            <CheckCircle2 className="h-4 w-4" />
            Validé — 50 € crédités
          </>
        ) : (
          <>
            <X className="h-4 w-4" />
            Refusé
          </>
        )}
      </div>
    );
  }

  if (showReject) {
    return (
      <div className="flex flex-col gap-2 md:min-w-[260px]">
        <input
          type="text"
          value={reason}
          onChange={(e) => setReason(e.target.value)}
          placeholder="Motif (fraude, doublon...)"
          disabled={pending}
          className="rounded-lg border border-rose-300 bg-white px-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-rose-400"
        />
        <div className="flex gap-2">
          <button
            type="button"
            onClick={onReject}
            disabled={pending || !reason.trim()}
            className="inline-flex items-center gap-1.5 rounded-lg bg-rose-600 hover:bg-rose-500 text-white px-3 py-1.5 text-sm font-medium transition-colors disabled:opacity-60"
          >
            {pending ? (
              <Loader2 className="h-3.5 w-3.5 animate-spin" />
            ) : (
              <X className="h-3.5 w-3.5" />
            )}
            Confirmer refus
          </button>
          <button
            type="button"
            onClick={() => {
              setShowReject(false);
              setReason("");
              setError(null);
            }}
            disabled={pending}
            className="text-sm font-medium text-slate-600 hover:text-navy-900"
          >
            Annuler
          </button>
        </div>
        {error && (
          <div className="text-xs text-rose-700">{error}</div>
        )}
      </div>
    );
  }

  return (
    <div className="flex items-center gap-2 shrink-0">
      <button
        type="button"
        onClick={onApprove}
        disabled={pending}
        className="inline-flex items-center gap-1.5 rounded-lg bg-emerald-600 hover:bg-emerald-500 text-white px-3 py-1.5 text-sm font-medium transition-colors disabled:opacity-60"
      >
        {pending ? (
          <Loader2 className="h-3.5 w-3.5 animate-spin" />
        ) : (
          <CheckCircle2 className="h-3.5 w-3.5" />
        )}
        Valider 50 €
      </button>
      <button
        type="button"
        onClick={() => setShowReject(true)}
        disabled={pending}
        className="inline-flex items-center gap-1.5 rounded-lg bg-white border border-rose-300 hover:bg-rose-50 text-rose-700 px-3 py-1.5 text-sm font-medium transition-colors"
      >
        <X className="h-3.5 w-3.5" />
        Refuser
      </button>
      {error && (
        <div className="text-xs text-rose-700 ml-2">{error}</div>
      )}
    </div>
  );
}
