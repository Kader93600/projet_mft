"use client";

// =====================================================================
// Composant client invisible monté dans AuthLayout.
//
// Au montage + à chaque retour en ligne, draine la file IndexedDB
// `mft-sync.quiz-attempts` en POSTant chaque entrée à
// `/api/quiz/sync-offline`. Affiche un toast vert "N tentative(s)
// synchronisée(s)" quand quelque chose a été remonté.
//
// Le serveur dédupe sur `client_attempt_id` — donc même si on essaie
// 2 fois par erreur, pas de doublon en BD.
//
// Anti-spam :
//   - Si la file contient des entrées qui ont déjà échoué ≥ 5 fois,
//     on les laisse en attente (probablement un payload malformé) ;
//     elles seront visibles dans /parametres → "Tentatives en attente"
//     pour debug si on l'ajoute plus tard.
// =====================================================================

import { useEffect, useState, useRef } from "react";
import {
  listPendingAttempts,
  markAttemptFailed,
  removeAttempt,
  type PendingAttempt,
} from "@/lib/pwa/sync-queue";
import { CheckCircle2, RefreshCw, X } from "lucide-react";

const MAX_RETRIES = 5;

async function syncOne(item: PendingAttempt): Promise<"ok" | "dedup" | "fail"> {
  try {
    const res = await fetch("/api/quiz/sync-offline", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(item.payload),
    });
    if (!res.ok) return "fail";
    const json = await res.json().catch(() => ({}));
    return json.deduplicated ? "dedup" : "ok";
  } catch {
    return "fail";
  }
}

export function OfflineSync() {
  const [synced, setSynced] = useState<number | null>(null);
  const [closing, setClosing] = useState(false);
  const draining = useRef(false);

  async function drain() {
    if (draining.current) return;
    if (typeof navigator !== "undefined" && !navigator.onLine) return;
    draining.current = true;
    try {
      const items = await listPendingAttempts();
      if (items.length === 0) {
        draining.current = false;
        return;
      }
      let synced_ok = 0;
      for (const item of items) {
        if ((item.attempts ?? 0) >= MAX_RETRIES) continue;
        const r = await syncOne(item);
        if (r === "ok" || r === "dedup") {
          await removeAttempt(item.client_id);
          if (r === "ok") synced_ok++;
        } else {
          await markAttemptFailed(item.client_id);
        }
      }
      if (synced_ok > 0) {
        setSynced(synced_ok);
        setTimeout(() => setClosing(true), 4500);
        setTimeout(() => setSynced(null), 4900);
      }
    } finally {
      draining.current = false;
    }
  }

  useEffect(() => {
    // Premier essai au montage (au cas où des entrées seraient en
    // attente depuis une session précédente)
    drain();

    const onOnline = () => drain();
    window.addEventListener("online", onOnline);
    return () => {
      window.removeEventListener("online", onOnline);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  if (synced == null) return null;

  return (
    <div
      role="status"
      aria-live="polite"
      className={[
        "fixed bottom-6 right-6 z-[100]",
        "flex items-start gap-3 rounded-2xl border border-emerald-200 bg-emerald-50",
        "shadow-raised px-4 py-3 pr-10 min-w-[280px] max-w-sm",
        "transition-all duration-400",
        closing ? "translate-y-2 opacity-0" : "translate-y-0 opacity-100",
      ].join(" ")}
      style={{ transitionTimingFunction: "cubic-bezier(0.19, 1, 0.22, 1)" }}
    >
      <div className="h-9 w-9 rounded-xl bg-emerald-500 text-white flex items-center justify-center shrink-0">
        <CheckCircle2 className="h-4 w-4" />
      </div>

      <div className="flex-1 min-w-0">
        <div className="font-display text-sm font-semibold text-emerald-900">
          Tentative{synced > 1 ? "s" : ""} synchronisée{synced > 1 ? "s" : ""}
        </div>
        <div className="text-xs text-emerald-800 mt-0.5 inline-flex items-center gap-1.5">
          <RefreshCw className="h-3 w-3" />
          {synced} quiz envoyé{synced > 1 ? "s" : ""} au serveur
        </div>
      </div>

      <button
        onClick={() => {
          setClosing(true);
          setTimeout(() => setSynced(null), 400);
        }}
        aria-label="Fermer"
        className="absolute right-2 top-2 text-slate-500 hover:text-navy-900 transition-colors"
      >
        <X className="h-3.5 w-3.5" />
      </button>
    </div>
  );
}
