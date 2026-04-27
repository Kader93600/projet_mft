"use client";
import Link from "next/link";
import { useEffect, useRef, useState } from "react";
import { Bell } from "lucide-react";
import { createClient } from "@/lib/supabase/client";

// Cloche avec badge de non-lus.
// 1) Fetch initial via /api/notifications/unread
// 2) Souscription Supabase Realtime sur public.notifications (INSERT/UPDATE)
// 3) Fallback polling 5 min en cas de coupure WS
//
// NB : on utilise un suffixe d'instance unique pour éviter les collisions
// Supabase Realtime en React 18 StrictMode (le useEffect est exécuté 2× en dev,
// et un canal du même nom déjà `subscribe()` rejette les `on()` ultérieurs).
export function NotificationsBell({ href = "/notifications" }: { href?: string }) {
  const [count, setCount] = useState<number>(0);
  const [pulse, setPulse] = useState(false);
  // Suffixe unique par instance React (stable entre rerenders)
  const instanceIdRef = useRef<string>(
    typeof crypto !== "undefined" && "randomUUID" in crypto
      ? crypto.randomUUID()
      : Math.random().toString(36).slice(2)
  );

  useEffect(() => {
    let cancelled = false;
    const supabase = createClient();
    const instanceId = instanceIdRef.current;

    const refresh = async () => {
      try {
        const res = await fetch("/api/notifications/unread", { cache: "no-store" });
        if (!res.ok) return;
        const { count } = await res.json();
        if (!cancelled) setCount(count ?? 0);
      } catch {}
    };

    let channel: ReturnType<typeof supabase.channel> | null = null;

    (async () => {
      await refresh();
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user || cancelled) return;

      // 1) Créer le canal avec un nom unique par instance (StrictMode safe)
      const ch = supabase.channel(`notifications:${user.id}:${instanceId}`);

      // 2) Enregistrer les callbacks AVANT subscribe()
      ch.on(
        "postgres_changes",
        {
          event: "*",
          schema: "public",
          table: "notifications",
          filter: `user_id=eq.${user.id}`,
        },
        (payload) => {
          if (payload.eventType === "INSERT") {
            setCount((c) => c + 1);
            setPulse(true);
            setTimeout(() => setPulse(false), 1500);
          } else {
            refresh();
          }
        }
      );

      // 3) Si le composant a été démonté pendant l'await, ne pas subscribe
      if (cancelled) {
        supabase.removeChannel(ch);
        return;
      }

      ch.subscribe();
      channel = ch;
    })();

    // Fallback : repoll quand la fenêtre redevient visible + filet de sécurité 5 min
    const onVis = () => {
      if (document.visibilityState === "visible") refresh();
    };
    document.addEventListener("visibilitychange", onVis);
    const id = setInterval(refresh, 5 * 60_000);

    return () => {
      cancelled = true;
      clearInterval(id);
      document.removeEventListener("visibilitychange", onVis);
      if (channel) supabase.removeChannel(channel);
    };
  }, []);

  return (
    <Link
      href={href}
      className="relative inline-flex h-9 w-9 items-center justify-center rounded-xl text-slate-600 hover:bg-navy-50 hover:text-navy-900 transition"
      aria-label={
        count > 0
          ? `Notifications (${count} non lue${count > 1 ? "s" : ""})`
          : "Notifications"
      }
    >
      <Bell className={"h-4.5 w-4.5 " + (pulse ? "animate-bounce" : "")} />
      {count > 0 && (
        <span className="absolute -top-0.5 -right-0.5 inline-flex items-center justify-center h-4 min-w-[16px] px-1 rounded-full bg-rose-500 text-white text-[9px] font-bold leading-none">
          {count > 99 ? "99+" : count}
        </span>
      )}
    </Link>
  );
}
