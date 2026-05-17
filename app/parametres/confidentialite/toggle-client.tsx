"use client";

import { useState, useTransition } from "react";
import { setLeaderboardOptOut } from "./actions";
import { CheckCircle2, Loader2 } from "lucide-react";

export function LeaderboardOptOutToggle({
  initialOptOut,
}: {
  initialOptOut: boolean;
}) {
  const [optOut, setOptOut] = useState(initialOptOut);
  const [pending, startTransition] = useTransition();
  const [saved, setSaved] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const onChange = (next: boolean) => {
    setOptOut(next);
    setSaved(false);
    setError(null);
    startTransition(async () => {
      const res = await setLeaderboardOptOut(next);
      if (!res.ok) {
        setError(res.error ?? "Erreur");
        setOptOut(!next); // rollback
        return;
      }
      setSaved(true);
      setTimeout(() => setSaved(false), 2200);
    });
  };

  return (
    <div className="flex items-start justify-between gap-4 py-4">
      <div className="min-w-0 flex-1">
        <div className="font-medium text-navy-900">
          Apparaître dans le classement public
        </div>
        <p className="text-sm text-slate-600 mt-1">
          Si vous décochez, votre nom et vos points sont retirés de la page
          /classement. Votre progression individuelle reste visible pour vous
          (XP, niveau, série, badges).
        </p>
      </div>

      <div className="flex items-center gap-3 shrink-0">
        {pending && (
          <Loader2 className="h-4 w-4 text-slate-400 animate-spin" aria-hidden />
        )}
        {saved && !pending && (
          <span className="inline-flex items-center gap-1 text-xs text-emerald-700">
            <CheckCircle2 className="h-3.5 w-3.5" />
            Enregistré
          </span>
        )}

        <button
          type="button"
          role="switch"
          aria-checked={!optOut}
          onClick={() => onChange(!optOut)}
          disabled={pending}
          className={[
            "relative inline-flex h-6 w-11 items-center rounded-full transition-colors",
            "focus:outline-none focus:ring-2 focus:ring-gold-400 focus:ring-offset-2",
            !optOut ? "bg-gold-500" : "bg-slate-300",
            pending && "opacity-60",
          ].join(" ")}
        >
          <span
            className={[
              "inline-block h-5 w-5 transform rounded-full bg-white shadow transition-transform",
              !optOut ? "translate-x-5" : "translate-x-0.5",
            ].join(" ")}
          />
        </button>
      </div>

      {error && (
        <p className="text-xs text-rose-600 mt-1 w-full" role="alert">
          {error}
        </p>
      )}
    </div>
  );
}
