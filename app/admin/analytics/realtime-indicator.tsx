"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { Activity, RefreshCw } from "lucide-react";

/**
 * Indicateur "Live" qui s'abonne aux changements Supabase Realtime sur 3
 * tables critiques : quiz_attempts, enrollments, session_attendance.
 *
 * Quand un changement arrive, on debounce 2s puis on déclenche un
 * router.refresh() qui re-fetch côté serveur les KPIs et redessine la
 * page. C'est plus simple qu'un state management dédié, et ça garde
 * le code 100 % SSR / RSC sans dupliquer la logique des vues SQL.
 */
export function RealtimeIndicator() {
  const router = useRouter();
  const [pulses, setPulses] = useState(0);
  const [lastEventKind, setLastEventKind] = useState<string | null>(null);
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    const supabase = createClient();

    function handleChange(kind: string) {
      setPulses((p) => p + 1);
      setLastEventKind(kind);
      if (debounceRef.current) clearTimeout(debounceRef.current);
      // Refresh des KPIs côté serveur après 2s de calme
      debounceRef.current = setTimeout(() => {
        router.refresh();
      }, 2000);
    }

    const channel = supabase
      .channel("admin-dashboard-live")
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "quiz_attempts" },
        () => handleChange("quiz")
      )
      .on(
        "postgres_changes",
        { event: "INSERT", schema: "public", table: "enrollments" },
        () => handleChange("enrollment")
      )
      .on(
        "postgres_changes",
        { event: "INSERT", schema: "public", table: "session_attendance" },
        () => handleChange("attendance")
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
      if (debounceRef.current) clearTimeout(debounceRef.current);
    };
  }, [router]);

  return (
    <div className="inline-flex items-center gap-2 text-xs">
      <span className="relative inline-flex h-2.5 w-2.5">
        <span className="absolute inline-flex h-full w-full rounded-full bg-signal-500 opacity-75 animate-ping" />
        <span className="relative inline-flex h-2.5 w-2.5 rounded-full bg-signal-500" />
      </span>
      <span className="font-medium text-slate-700">Live</span>
      {pulses > 0 && (
        <span className="text-slate-500">
          · {pulses} event{pulses > 1 ? "s" : ""} reçu{pulses > 1 ? "s" : ""}
          {lastEventKind ? ` (${kindLabel(lastEventKind)})` : ""}
        </span>
      )}
      <button
        type="button"
        onClick={() => router.refresh()}
        className="ml-1 inline-flex items-center gap-1 text-slate-400 hover:text-navy-900 transition"
        title="Forcer le rafraîchissement"
      >
        <RefreshCw className="h-3 w-3" />
      </button>
    </div>
  );
}

function kindLabel(k: string): string {
  switch (k) {
    case "quiz": return "quiz";
    case "enrollment": return "nouvelle inscription";
    case "attendance": return "émargement";
    default: return k;
  }
}
