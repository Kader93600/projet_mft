"use client";
import {
  useEffect,
  useRef,
  useState,
  useCallback,
  useMemo,
} from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { Bell, X, CheckCheck, Trash2, ArrowRight, Settings } from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import { cn } from "@/lib/utils";
import {
  NotificationItem,
  type NotificationRow,
} from "@/components/notification-item";
import {
  markOneRead,
  markManyRead,
  deleteOne,
  deleteMany,
} from "@/app/notifications/actions";
import {
  DEFAULT_PREFERENCES,
  isTypeEnabled,
  type PreferenceState,
} from "@/lib/notification-preferences";

const RECENT_LIMIT = 30;

/**
 * Centre de notifications premium :
 *   - Bouton cloche avec badge unread + ring-pulse à l'arrivée Realtime
 *   - Popover desktop ancré sous la cloche (420px × 560px max)
 *   - Drawer bottom mobile plein écran (rounded top, backdrop blur)
 *   - Mark as read au clic, delete individuel/global, navigation auto
 *
 * Source de vérité : la liste des notifs locale, alimentée par :
 *   - fetch initial (30 dernières)
 *   - subscription Supabase Realtime sur INSERT/UPDATE/DELETE
 *   - repoll au focus + filet 5 min en cas de coupure WS
 */
export function NotificationsBell() {
  const [notifs, setNotifs] = useState<NotificationRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [open, setOpen] = useState(false);
  const [pulse, setPulse] = useState(false);
  const [freshIds, setFreshIds] = useState<Set<string>>(new Set());
  const [prefs, setPrefs] = useState<PreferenceState>(DEFAULT_PREFERENCES);
  const router = useRouter();
  const containerRef = useRef<HTMLDivElement>(null);
  const triggerRef = useRef<HTMLButtonElement>(null);

  // Suffixe d'instance unique pour StrictMode safe (canal Realtime)
  const instanceIdRef = useRef<string>(
    typeof crypto !== "undefined" && "randomUUID" in crypto
      ? crypto.randomUUID()
      : Math.random().toString(36).slice(2)
  );

  // Notifs visibles : filtrées par les préférences in_app de l'utilisateur
  const visibleNotifs = useMemo(
    () => notifs.filter((n) => isTypeEnabled(prefs, n.type, "in_app")),
    [notifs, prefs]
  );

  const count = useMemo(
    () => visibleNotifs.filter((n) => !n.read_at).length,
    [visibleNotifs]
  );

  // ── Fetch + subscribe ────────────────────────────────────────
  useEffect(() => {
    let cancelled = false;
    const supabase = createClient();
    const instanceId = instanceIdRef.current;

    const refresh = async () => {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user || cancelled) return;

      // Fetch parallèle : notifs + préférences
      const [notifsRes, prefsRes] = await Promise.all([
        supabase
          .from("notifications")
          .select("id, type, title, body, link_url, read_at, created_at")
          .eq("user_id", user.id)
          .order("created_at", { ascending: false })
          .limit(RECENT_LIMIT),
        supabase
          .from("notification_preferences")
          .select("in_app_disabled, push_disabled, email_disabled")
          .eq("user_id", user.id)
          .maybeSingle(),
      ]);

      if (cancelled) return;
      if (!notifsRes.error && notifsRes.data) {
        setNotifs(notifsRes.data as NotificationRow[]);
      }
      if (!prefsRes.error) {
        setPrefs(
          prefsRes.data
            ? {
                in_app_disabled: prefsRes.data.in_app_disabled ?? [],
                push_disabled: prefsRes.data.push_disabled ?? [],
                email_disabled: prefsRes.data.email_disabled ?? [],
              }
            : DEFAULT_PREFERENCES
        );
      }
      setLoading(false);
    };

    let channel: ReturnType<typeof supabase.channel> | null = null;

    (async () => {
      await refresh();
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user || cancelled) return;

      const ch = supabase.channel(`notif-center:${user.id}:${instanceId}`);

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
            const row = payload.new as NotificationRow;
            setNotifs((prev) => {
              if (prev.some((n) => n.id === row.id)) return prev;
              return [row, ...prev].slice(0, RECENT_LIMIT);
            });
            setPulse(true);
            setFreshIds((s) => {
              const next = new Set(s);
              next.add(row.id);
              return next;
            });
            window.setTimeout(() => setPulse(false), 1100);
            window.setTimeout(() => {
              setFreshIds((s) => {
                const next = new Set(s);
                next.delete(row.id);
                return next;
              });
            }, 950);
          } else if (payload.eventType === "UPDATE") {
            const row = payload.new as NotificationRow;
            setNotifs((prev) =>
              prev.map((n) => (n.id === row.id ? row : n))
            );
          } else if (payload.eventType === "DELETE") {
            const oldId = (payload.old as { id?: string }).id;
            if (oldId) {
              setNotifs((prev) => prev.filter((n) => n.id !== oldId));
            }
          }
        }
      );

      if (cancelled) {
        supabase.removeChannel(ch);
        return;
      }
      ch.subscribe();
      channel = ch;
    })();

    const onVisibility = () => {
      if (document.visibilityState === "visible") refresh();
    };
    document.addEventListener("visibilitychange", onVisibility);
    const intervalId = window.setInterval(refresh, 5 * 60_000);

    return () => {
      cancelled = true;
      window.clearInterval(intervalId);
      document.removeEventListener("visibilitychange", onVisibility);
      if (channel) supabase.removeChannel(channel);
    };
  }, []);

  // ── Click outside / Escape pour fermer le popover ────────────
  useEffect(() => {
    if (!open) return;
    const onMouseDown = (e: MouseEvent) => {
      const target = e.target as Node;
      if (containerRef.current && !containerRef.current.contains(target)) {
        setOpen(false);
      }
    };
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        setOpen(false);
        triggerRef.current?.focus();
      }
    };
    document.addEventListener("mousedown", onMouseDown);
    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("mousedown", onMouseDown);
      document.removeEventListener("keydown", onKey);
    };
  }, [open]);

  // ── Bloc body scroll quand drawer mobile ouvert ──────────────
  useEffect(() => {
    if (!open) return;
    const isMobile =
      typeof window !== "undefined" &&
      window.matchMedia("(max-width: 767px)").matches;
    if (!isMobile) return;
    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = previousOverflow;
    };
  }, [open]);

  // ── Actions ──────────────────────────────────────────────────
  const handleSelect = useCallback(
    (n: NotificationRow) => {
      // Optimistic mark as read
      if (!n.read_at) {
        const nowIso = new Date().toISOString();
        setNotifs((prev) =>
          prev.map((x) => (x.id === n.id ? { ...x, read_at: nowIso } : x))
        );
        void markOneRead(n.id);
      }
      if (n.link_url) {
        setOpen(false);
        router.push(n.link_url);
      }
    },
    [router]
  );

  const handleDeleteOne = useCallback((id: string) => {
    setNotifs((prev) => prev.filter((n) => n.id !== id));
    void deleteOne(id);
  }, []);

  const handleMarkAll = useCallback(() => {
    const ids = visibleNotifs.filter((n) => !n.read_at).map((n) => n.id);
    if (ids.length === 0) return;
    const nowIso = new Date().toISOString();
    const idSet = new Set(ids);
    setNotifs((prev) =>
      prev.map((n) => (idSet.has(n.id) ? { ...n, read_at: nowIso } : n))
    );
    void markManyRead(ids);
  }, [visibleNotifs]);

  const handleDeleteAll = useCallback(() => {
    const ids = visibleNotifs.map((n) => n.id);
    if (ids.length === 0) return;
    const idSet = new Set(ids);
    setNotifs((prev) => prev.filter((n) => !idSet.has(n.id)));
    void deleteMany(ids);
  }, [visibleNotifs]);

  // ── Rendu ────────────────────────────────────────────────────
  const ariaLabel =
    count > 0
      ? `Notifications (${count} non lue${count > 1 ? "s" : ""})`
      : "Notifications";

  return (
    <div ref={containerRef} className="relative">
      {/* Bouton cloche */}
      <button
        ref={triggerRef}
        type="button"
        onClick={() => setOpen((o) => !o)}
        aria-label={ariaLabel}
        aria-expanded={open}
        aria-haspopup="dialog"
        className={cn(
          "relative inline-flex h-9 w-9 items-center justify-center rounded-xl",
          "text-slate-600 hover:bg-navy-50 hover:text-navy-900",
          "transition-colors duration-150 ease-out",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-navy-300",
          open && "bg-navy-50 text-navy-900"
        )}
      >
        <Bell className="h-[18px] w-[18px]" />
        {/* Ring pulse one-shot à l'arrivée Realtime */}
        {pulse && (
          <span
            aria-hidden
            className="pointer-events-none absolute inset-0 rounded-xl ring-2 ring-gold-400 animate-notif-ring"
          />
        )}
        {/* Badge unread */}
        {count > 0 && (
          <span
            className={cn(
              "absolute -top-0.5 -right-0.5 inline-flex items-center justify-center",
              "h-4 min-w-[16px] px-1 rounded-full",
              "bg-rose-500 text-white text-[9px] font-bold leading-none",
              "ring-2 ring-white"
            )}
          >
            {count > 99 ? "99+" : count}
          </span>
        )}
      </button>

      {/* Backdrop mobile + panneau */}
      {open && (
        <>
          {/* Backdrop : visible uniquement mobile */}
          <div
            className="md:hidden fixed inset-0 bg-navy-950/40 backdrop-blur-sm z-40 animate-notif-backdrop"
            onClick={() => setOpen(false)}
            aria-hidden
          />
          {/* Panneau : drawer bottom mobile / popover desktop */}
          <div
            role="dialog"
            aria-modal="false"
            aria-label="Centre de notifications"
            className={cn(
              "z-50 bg-white/95 backdrop-blur-md border border-navy-100",
              "shadow-float",
              "flex flex-col",
              // Mobile (sheet bottom)
              "fixed inset-x-0 bottom-0 max-h-[88vh] rounded-t-3xl rounded-b-none",
              "animate-notif-slide-up",
              // Desktop (popover) — réinitialise les positions mobile
              "md:fixed-none md:absolute md:inset-x-auto md:bottom-auto",
              "md:right-0 md:top-[calc(100%+8px)]",
              "md:w-[420px] md:max-h-[560px] md:rounded-2xl",
              "md:animate-notif-pop"
            )}
          >
            {/* Grab handle mobile */}
            <div className="md:hidden pt-2.5 pb-1 flex justify-center">
              <span
                className="h-1 w-10 rounded-full bg-navy-200/80"
                aria-hidden
              />
            </div>

            {/* Header */}
            <div className="flex items-center justify-between gap-2 px-4 pt-3 pb-3 border-b border-navy-100">
              <div className="flex items-center gap-2 min-w-0">
                <h2 className="font-display text-[15px] font-semibold text-navy-950 tracking-tight">
                  Notifications
                </h2>
                {count > 0 && (
                  <span className="inline-flex items-center rounded-full bg-gold-100 text-gold-800 text-[10px] font-bold px-2 py-0.5 tracking-wide uppercase">
                    {count} non lue{count > 1 ? "s" : ""}
                  </span>
                )}
              </div>
              <div className="flex items-center gap-0.5">
                {count > 0 && (
                  <button
                    type="button"
                    onClick={handleMarkAll}
                    title="Tout marquer lu"
                    className={cn(
                      "text-[11px] font-semibold text-navy-700 hover:text-navy-900",
                      "px-2 py-1 rounded-md hover:bg-navy-50",
                      "transition-colors duration-150 ease-out",
                      "flex items-center gap-1"
                    )}
                  >
                    <CheckCheck className="h-3.5 w-3.5" />
                    <span className="hidden sm:inline">Tout lu</span>
                  </button>
                )}
                {visibleNotifs.length > 0 && (
                  <button
                    type="button"
                    onClick={handleDeleteAll}
                    title="Tout supprimer"
                    className={cn(
                      "text-[11px] font-semibold text-slate-500 hover:text-rose-600",
                      "px-2 py-1 rounded-md hover:bg-rose-50",
                      "transition-colors duration-150 ease-out",
                      "flex items-center gap-1"
                    )}
                  >
                    <Trash2 className="h-3.5 w-3.5" />
                    <span className="hidden sm:inline">Vider</span>
                  </button>
                )}
                <button
                  type="button"
                  onClick={() => setOpen(false)}
                  aria-label="Fermer"
                  className="md:hidden h-8 w-8 ml-0.5 rounded-md flex items-center justify-center text-slate-500 hover:bg-navy-50"
                >
                  <X className="h-4 w-4" />
                </button>
              </div>
            </div>

            {/* Liste */}
            <div className="flex-1 overflow-y-auto overscroll-contain">
              {loading ? (
                <NotifSkeleton />
              ) : visibleNotifs.length === 0 ? (
                <EmptyState />
              ) : (
                <ul className="divide-y divide-navy-50">
                  {visibleNotifs.map((n) => (
                    <li key={n.id}>
                      <NotificationItem
                        notif={n}
                        onSelect={handleSelect}
                        onDelete={handleDeleteOne}
                        fresh={freshIds.has(n.id)}
                      />
                    </li>
                  ))}
                </ul>
              )}
            </div>

            {/* Footer */}
            <div className="border-t border-navy-100 px-3 py-2 bg-white/70 backdrop-blur-sm rounded-b-none md:rounded-b-2xl flex items-center gap-1">
              <Link
                href="/notifications"
                onClick={() => setOpen(false)}
                className={cn(
                  "flex-1 flex items-center justify-center gap-1.5 py-1.5",
                  "text-[12px] font-semibold text-navy-700 hover:text-navy-900",
                  "transition-colors duration-150 ease-out group rounded-lg hover:bg-navy-50"
                )}
              >
                Voir toutes les notifications
                <ArrowRight className="h-3.5 w-3.5 transition-transform duration-150 group-hover:translate-x-0.5" />
              </Link>
              <Link
                href="/parametres/notifications"
                onClick={() => setOpen(false)}
                title="Préférences"
                aria-label="Préférences de notifications"
                className={cn(
                  "h-7 w-7 rounded-lg flex items-center justify-center",
                  "text-slate-500 hover:text-navy-900 hover:bg-navy-50",
                  "transition-colors duration-150 ease-out"
                )}
              >
                <Settings className="h-3.5 w-3.5" />
              </Link>
            </div>
          </div>
        </>
      )}
    </div>
  );
}

// ── Empty state ────────────────────────────────────────────────
function EmptyState() {
  return (
    <div className="px-4 py-14 text-center">
      <div className="mx-auto h-14 w-14 rounded-2xl bg-gradient-to-br from-navy-50 via-white to-gold-50 border border-navy-100 flex items-center justify-center shadow-soft">
        <Bell className="h-6 w-6 text-navy-400" />
      </div>
      <p className="mt-4 text-[13.5px] font-semibold text-navy-900">
        Tout est calme par ici
      </p>
      <p className="mt-1 text-[11.5px] text-slate-500 leading-relaxed max-w-[240px] mx-auto">
        Les nouvelles notifications apparaîtront ici en temps réel.
      </p>
    </div>
  );
}

// ── Skeleton de chargement ─────────────────────────────────────
function NotifSkeleton() {
  return (
    <ul className="divide-y divide-navy-50">
      {[0, 1, 2].map((i) => (
        <li
          key={i}
          className="flex items-start gap-3 px-4 py-3.5 animate-pulse"
        >
          <div className="h-9 w-9 rounded-xl bg-navy-50 shrink-0" />
          <div className="flex-1 space-y-1.5 pt-1">
            <div className="h-3 w-3/4 rounded bg-navy-50" />
            <div className="h-2.5 w-full rounded bg-navy-50/70" />
            <div className="h-2 w-16 rounded bg-navy-50/50 mt-1" />
          </div>
        </li>
      ))}
    </ul>
  );
}
