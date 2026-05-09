"use client";
import {
  useEffect,
  useMemo,
  useRef,
  useState,
  useCallback,
  useTransition,
} from "react";
import { useRouter } from "next/navigation";
import {
  Bell,
  Search,
  Inbox,
  CheckCheck,
  Trash2,
  X,
  SlidersHorizontal,
} from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import { cn } from "@/lib/utils";
import {
  NotificationItem,
  type NotificationRow,
} from "@/components/notification-item";
import { NotificationGroupRow } from "@/components/notification-group";
import {
  NOTIFICATION_STYLES,
  type NotificationType,
} from "@/lib/notifications-icons";
import {
  groupNotifications,
  splitByDateSection,
} from "@/lib/notifications-grouping";
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

const FETCH_LIMIT = 200;

type FilterValue = "all" | "unread" | NotificationType;

interface Props {
  initialNotifs: NotificationRow[];
  userId: string;
}

/**
 * Page archive premium : filtres, recherche, sections par date,
 * groupement intelligent, bulk actions, Realtime.
 *
 * Cohabite avec le centre de notifications (dropdown topbar) :
 *   - Le dropdown reste la vue rapide (30 derniers)
 *   - Cette archive est la vue exhaustive avec outils de gestion
 */
export function NotificationsArchive({ initialNotifs, userId }: Props) {
  const [allNotifs, setAllNotifs] = useState<NotificationRow[]>(initialNotifs);
  const [filter, setFilter] = useState<FilterValue>("all");
  const [query, setQuery] = useState("");
  const [selected, setSelected] = useState<Set<string>>(new Set());
  const [showFilters, setShowFilters] = useState(false);
  const [prefs, setPrefs] = useState<PreferenceState>(DEFAULT_PREFERENCES);
  const [, startTransition] = useTransition();
  const router = useRouter();
  const instanceIdRef = useRef<string>(
    typeof crypto !== "undefined" && "randomUUID" in crypto
      ? crypto.randomUUID()
      : Math.random().toString(36).slice(2)
  );

  // Notifs visibles : filtrées par les préférences in_app
  const notifs = useMemo(
    () => allNotifs.filter((n) => isTypeEnabled(prefs, n.type, "in_app")),
    [allNotifs, prefs]
  );

  // Setter wrapper pour conserver la cohérence avec la liste complète
  const setNotifs = useCallback(
    (
      updater:
        | NotificationRow[]
        | ((prev: NotificationRow[]) => NotificationRow[])
    ) => {
      setAllNotifs((prev) =>
        typeof updater === "function" ? updater(prev) : updater
      );
    },
    []
  );

  // ── Charge les préférences ───────────────────────────────────
  useEffect(() => {
    const supabase = createClient();
    let cancelled = false;
    void (async () => {
      const { data } = await supabase
        .from("notification_preferences")
        .select("in_app_disabled, push_disabled, email_disabled")
        .eq("user_id", userId)
        .maybeSingle();
      if (cancelled) return;
      setPrefs(
        data
          ? {
              in_app_disabled: data.in_app_disabled ?? [],
              push_disabled: data.push_disabled ?? [],
              email_disabled: data.email_disabled ?? [],
            }
          : DEFAULT_PREFERENCES
      );
    })();
    return () => {
      cancelled = true;
    };
  }, [userId]);

  // ── Realtime subscribe ───────────────────────────────────────
  useEffect(() => {
    const supabase = createClient();
    const ch = supabase.channel(
      `notif-archive:${userId}:${instanceIdRef.current}`
    );
    ch.on(
      "postgres_changes",
      {
        event: "*",
        schema: "public",
        table: "notifications",
        filter: `user_id=eq.${userId}`,
      },
      (payload) => {
        if (payload.eventType === "INSERT") {
          const row = payload.new as NotificationRow;
          setNotifs((prev) => {
            if (prev.some((n) => n.id === row.id)) return prev;
            return [row, ...prev];
          });
        } else if (payload.eventType === "UPDATE") {
          const row = payload.new as NotificationRow;
          setNotifs((prev) => prev.map((n) => (n.id === row.id ? row : n)));
        } else if (payload.eventType === "DELETE") {
          const oldId = (payload.old as { id?: string }).id;
          if (oldId) {
            setNotifs((prev) => prev.filter((n) => n.id !== oldId));
            setSelected((s) => {
              if (!s.has(oldId)) return s;
              const next = new Set(s);
              next.delete(oldId);
              return next;
            });
          }
        }
      }
    );
    ch.subscribe();
    return () => {
      supabase.removeChannel(ch);
    };
  }, [userId]);

  // ── Filtrage + recherche (client-side, le dataset reste petit) ──
  const filtered = useMemo(() => {
    let list = notifs;
    if (filter === "unread") list = list.filter((n) => !n.read_at);
    else if (filter !== "all")
      list = list.filter((n) => (n.type ?? "system") === filter);
    if (query.trim().length > 0) {
      const q = query.trim().toLowerCase();
      list = list.filter(
        (n) =>
          n.title.toLowerCase().includes(q) ||
          (n.body ?? "").toLowerCase().includes(q)
      );
    }
    return list;
  }, [notifs, filter, query]);

  // ── Groupement + sections par date ───────────────────────────
  const sections = useMemo(() => {
    const grouped = groupNotifications(filtered, { minGroupSize: 3 });
    return splitByDateSection(grouped);
  }, [filtered]);

  // ── Compteurs pour les chips de filtre ────────────────────────
  const counts = useMemo(() => {
    const c: Record<string, number> = { all: notifs.length, unread: 0 };
    for (const n of notifs) {
      if (!n.read_at) c.unread = (c.unread ?? 0) + 1;
      const t = n.type ?? "system";
      c[t] = (c[t] ?? 0) + 1;
    }
    return c;
  }, [notifs]);

  // Types présents dans les données (chips dynamiques)
  const presentTypes = useMemo(() => {
    const set = new Set<string>();
    for (const n of notifs) set.add(n.type ?? "system");
    return Array.from(set);
  }, [notifs]);

  // ── Bulk selection helpers ────────────────────────────────────
  const visibleIds = useMemo(() => filtered.map((n) => n.id), [filtered]);
  const allVisibleSelected =
    visibleIds.length > 0 && visibleIds.every((id) => selected.has(id));

  const toggleSelect = useCallback((id: string) => {
    setSelected((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  }, []);

  const selectAllVisible = useCallback(() => {
    setSelected((prev) => {
      const next = new Set(prev);
      if (allVisibleSelected) {
        for (const id of visibleIds) next.delete(id);
      } else {
        for (const id of visibleIds) next.add(id);
      }
      return next;
    });
  }, [allVisibleSelected, visibleIds]);

  const clearSelection = useCallback(() => setSelected(new Set()), []);

  // ── Actions ──────────────────────────────────────────────────
  const handleSelect = useCallback(
    (n: NotificationRow) => {
      if (!n.read_at) {
        const nowIso = new Date().toISOString();
        setNotifs((prev) =>
          prev.map((x) => (x.id === n.id ? { ...x, read_at: nowIso } : x))
        );
        startTransition(() => {
          void markOneRead(n.id);
        });
      }
      if (n.link_url) router.push(n.link_url);
    },
    [router]
  );

  const handleDeleteOne = useCallback((id: string) => {
    setNotifs((prev) => prev.filter((n) => n.id !== id));
    startTransition(() => {
      void deleteOne(id);
    });
  }, []);

  const handleMarkAll = useCallback(() => {
    if (counts.unread === 0) return;
    const ids = notifs.filter((n) => !n.read_at).map((n) => n.id);
    if (ids.length === 0) return;
    const idSet = new Set(ids);
    const nowIso = new Date().toISOString();
    setNotifs((prev) =>
      prev.map((n) => (idSet.has(n.id) ? { ...n, read_at: nowIso } : n))
    );
    startTransition(() => {
      void markManyRead(ids);
    });
  }, [counts.unread, notifs, setNotifs]);

  const handleDeleteAll = useCallback(() => {
    const ids = notifs.map((n) => n.id);
    if (ids.length === 0) return;
    if (
      typeof window !== "undefined" &&
      !window.confirm(
        "Supprimer toutes les notifications visibles ? Cette action est irréversible."
      )
    )
      return;
    const idSet = new Set(ids);
    setNotifs((prev) => prev.filter((n) => !idSet.has(n.id)));
    setSelected(new Set());
    startTransition(() => {
      void deleteMany(ids);
    });
  }, [notifs, setNotifs]);

  const handleBulkMarkRead = useCallback(() => {
    const ids = Array.from(selected);
    if (ids.length === 0) return;
    const nowIso = new Date().toISOString();
    setNotifs((prev) =>
      prev.map((n) =>
        ids.includes(n.id) && !n.read_at ? { ...n, read_at: nowIso } : n
      )
    );
    startTransition(() => {
      void markManyRead(ids);
    });
    clearSelection();
  }, [selected, clearSelection]);

  const handleBulkDelete = useCallback(() => {
    const ids = Array.from(selected);
    if (ids.length === 0) return;
    setNotifs((prev) => prev.filter((n) => !ids.includes(n.id)));
    startTransition(() => {
      void deleteMany(ids);
    });
    clearSelection();
  }, [selected, clearSelection]);

  const handleGroupMarkRead = useCallback((ids: string[]) => {
    const nowIso = new Date().toISOString();
    setNotifs((prev) =>
      prev.map((n) =>
        ids.includes(n.id) && !n.read_at ? { ...n, read_at: nowIso } : n
      )
    );
    startTransition(() => {
      void markManyRead(ids);
    });
  }, []);

  const handleGroupDelete = useCallback((ids: string[]) => {
    setNotifs((prev) => prev.filter((n) => !ids.includes(n.id)));
    startTransition(() => {
      void deleteMany(ids);
    });
  }, []);

  // ── Rendu ────────────────────────────────────────────────────
  const selectionCount = selected.size;
  const isEmpty = notifs.length === 0;
  const isFilteredEmpty = !isEmpty && filtered.length === 0;

  return (
    <div className="max-w-3xl mx-auto space-y-5">
      {/* Header */}
      <header className="flex items-start justify-between gap-4">
        <div className="min-w-0">
          <div className="flex items-center gap-2">
            <Bell className="h-4 w-4 text-gold-700" />
            <span className="eyebrow text-gold-700">Boîte de réception</span>
          </div>
          <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
            Notifications
          </h1>
          <p className="mt-2 text-slate-600 text-sm">
            {counts.unread > 0
              ? `${counts.unread} non lue${counts.unread > 1 ? "s" : ""} sur ${counts.all} au total`
              : isEmpty
                ? "Tout est calme par ici."
                : "Tout est à jour."}
          </p>
        </div>

        {!isEmpty && (
          <div className="flex items-center gap-2 shrink-0">
            {counts.unread > 0 && (
              <button
                type="button"
                onClick={handleMarkAll}
                className={cn(
                  "inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-[12px] font-semibold",
                  "text-navy-700 bg-white border border-navy-100 hover:bg-navy-50 hover:text-navy-900",
                  "transition-colors duration-150 ease-out"
                )}
              >
                <CheckCheck className="h-3.5 w-3.5" />
                Tout marquer lu
              </button>
            )}
            <button
              type="button"
              onClick={handleDeleteAll}
              title="Vider la boîte"
              className={cn(
                "inline-flex items-center justify-center h-8 w-8 rounded-lg text-[12px] font-semibold",
                "text-slate-500 bg-white border border-navy-100 hover:bg-rose-50 hover:text-rose-600 hover:border-rose-200",
                "transition-colors duration-150 ease-out"
              )}
            >
              <Trash2 className="h-3.5 w-3.5" />
            </button>
          </div>
        )}
      </header>

      {/* Toolbar : recherche + filtres */}
      {!isEmpty && (
        <div className="space-y-3">
          {/* Search */}
          <div className="relative">
            <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400 pointer-events-none" />
            <input
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Rechercher dans les notifications…"
              className={cn(
                "w-full h-10 pl-10 pr-10 rounded-xl text-[13px]",
                "bg-white border border-navy-100",
                "placeholder:text-slate-400 text-navy-900",
                "outline-none transition-shadow duration-150",
                "focus:border-navy-300 focus:shadow-ring-brand"
              )}
            />
            {query && (
              <button
                type="button"
                onClick={() => setQuery("")}
                aria-label="Effacer la recherche"
                className="absolute right-2 top-1/2 -translate-y-1/2 h-6 w-6 rounded-md text-slate-400 hover:text-navy-700 hover:bg-navy-50 flex items-center justify-center transition-colors"
              >
                <X className="h-3.5 w-3.5" />
              </button>
            )}
          </div>

          {/* Filter chips */}
          <div className="flex items-center gap-2 flex-wrap">
            <FilterChip
              active={filter === "all"}
              onClick={() => setFilter("all")}
              label="Tous"
              count={counts.all}
            />
            <FilterChip
              active={filter === "unread"}
              onClick={() => setFilter("unread")}
              label="Non lus"
              count={counts.unread}
              accent={counts.unread > 0}
            />
            <span
              className="hidden sm:inline-block h-5 w-px bg-navy-100 mx-1"
              aria-hidden
            />
            <button
              type="button"
              onClick={() => setShowFilters((s) => !s)}
              className={cn(
                "sm:hidden inline-flex items-center gap-1.5 px-3 h-7 rounded-full text-[11.5px] font-semibold",
                "text-slate-600 bg-white border border-navy-100",
                "transition-colors hover:bg-navy-50"
              )}
            >
              <SlidersHorizontal className="h-3 w-3" />
              Par type
            </button>
            <div
              className={cn(
                "flex items-center gap-2 flex-wrap",
                !showFilters && "max-sm:hidden"
              )}
            >
              {presentTypes.map((t) => {
                const style =
                  NOTIFICATION_STYLES[t as NotificationType] ??
                  NOTIFICATION_STYLES.system;
                return (
                  <FilterChip
                    key={t}
                    active={filter === t}
                    onClick={() => setFilter(t as FilterValue)}
                    label={style.label}
                    count={counts[t] ?? 0}
                    icon={<style.icon className="h-3 w-3" />}
                  />
                );
              })}
            </div>
          </div>
        </div>
      )}

      {/* Bulk actions bar */}
      {selectionCount > 0 && (
        <div
          className={cn(
            "sticky top-2 z-10",
            "flex items-center justify-between gap-3 px-4 py-2.5 rounded-xl",
            "bg-navy-900 text-white shadow-float",
            "animate-notif-pop"
          )}
          role="toolbar"
          aria-label="Actions sur la sélection"
        >
          <div className="flex items-center gap-3 min-w-0">
            <button
              type="button"
              onClick={clearSelection}
              aria-label="Désélectionner"
              className="h-7 w-7 rounded-md flex items-center justify-center bg-white/10 hover:bg-white/20 transition-colors"
            >
              <X className="h-3.5 w-3.5" />
            </button>
            <span className="text-[12.5px] font-semibold">
              {selectionCount} sélectionnée{selectionCount > 1 ? "s" : ""}
            </span>
            <button
              type="button"
              onClick={selectAllVisible}
              className="text-[11px] font-medium text-white/70 hover:text-white transition-colors hidden sm:inline-block"
            >
              {allVisibleSelected
                ? "Tout désélectionner"
                : "Tout sélectionner"}
            </button>
          </div>
          <div className="flex items-center gap-1">
            <button
              type="button"
              onClick={handleBulkMarkRead}
              className="inline-flex items-center gap-1.5 px-3 h-7 rounded-md text-[11.5px] font-semibold bg-white/10 hover:bg-white/20 transition-colors"
            >
              <CheckCheck className="h-3.5 w-3.5" />
              <span className="hidden sm:inline">Marquer lu</span>
            </button>
            <button
              type="button"
              onClick={handleBulkDelete}
              className="inline-flex items-center gap-1.5 px-3 h-7 rounded-md text-[11.5px] font-semibold bg-rose-500/90 hover:bg-rose-500 transition-colors"
            >
              <Trash2 className="h-3.5 w-3.5" />
              <span className="hidden sm:inline">Supprimer</span>
            </button>
          </div>
        </div>
      )}

      {/* Liste / états vides */}
      {isEmpty ? (
        <EmptyInbox />
      ) : isFilteredEmpty ? (
        <EmptyFiltered onReset={() => { setFilter("all"); setQuery(""); }} />
      ) : (
        <div className="space-y-6">
          {sections.map((section) => (
            <section key={section.key}>
              <div className="flex items-center gap-3 mb-2 px-1">
                <h2 className="text-[11px] font-bold uppercase tracking-[0.14em] text-slate-500">
                  {section.label}
                </h2>
                <span className="h-px flex-1 bg-navy-100" aria-hidden />
                <span className="text-[10.5px] text-slate-400 font-medium">
                  {section.items.length}
                </span>
              </div>
              <div className="bg-white border border-navy-100 rounded-2xl shadow-soft overflow-hidden">
                <ul className="divide-y divide-navy-50">
                  {section.items.map((item) =>
                    item.kind === "single" ? (
                      <li key={item.notif.id} className="relative">
                        <SelectableRow
                          selected={selected.has(item.notif.id)}
                          onToggle={() => toggleSelect(item.notif.id)}
                        >
                          <NotificationItem
                            notif={item.notif}
                            onSelect={handleSelect}
                            onDelete={handleDeleteOne}
                          />
                        </SelectableRow>
                      </li>
                    ) : (
                      <li key={item.group.key}>
                        <NotificationGroupRow
                          group={item.group}
                          onSelectItem={handleSelect}
                          onDeleteItem={handleDeleteOne}
                          onMarkGroupRead={handleGroupMarkRead}
                          onDeleteGroup={handleGroupDelete}
                        />
                      </li>
                    )
                  )}
                </ul>
              </div>
            </section>
          ))}
        </div>
      )}
    </div>
  );
}

// ── Sub-components ─────────────────────────────────────────────

function FilterChip({
  active,
  onClick,
  label,
  count,
  accent = false,
  icon,
}: {
  active: boolean;
  onClick: () => void;
  label: string;
  count: number;
  accent?: boolean;
  icon?: React.ReactNode;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-pressed={active}
      className={cn(
        "inline-flex items-center gap-1.5 h-7 px-3 rounded-full text-[11.5px] font-semibold",
        "transition-colors duration-150 ease-out border",
        active
          ? "bg-navy-900 text-white border-navy-900 shadow-sm"
          : "bg-white text-slate-600 border-navy-100 hover:bg-navy-50 hover:text-navy-900"
      )}
    >
      {icon && <span className="opacity-80">{icon}</span>}
      {label}
      <span
        className={cn(
          "inline-flex items-center justify-center min-w-[18px] px-1 h-4 rounded-full text-[9.5px] font-bold leading-none",
          active
            ? "bg-white/20 text-white"
            : accent
              ? "bg-gold-100 text-gold-800"
              : "bg-navy-50 text-navy-700"
        )}
      >
        {count}
      </span>
    </button>
  );
}

/**
 * Wrapper qui injecte une checkbox de sélection à gauche de chaque
 * NotificationItem au survol (ou si déjà sélectionné).
 */
function SelectableRow({
  children,
  selected,
  onToggle,
}: {
  children: React.ReactNode;
  selected: boolean;
  onToggle: () => void;
}) {
  return (
    <div className="group/select relative">
      <button
        type="button"
        onClick={onToggle}
        aria-label={selected ? "Désélectionner" : "Sélectionner"}
        aria-pressed={selected}
        className={cn(
          "absolute top-1/2 -translate-y-1/2 left-2 h-5 w-5 rounded-md border z-10",
          "flex items-center justify-center",
          "transition-all duration-150 ease-out",
          selected
            ? "bg-navy-900 border-navy-900 opacity-100"
            : "bg-white border-navy-200 opacity-0 group-hover/select:opacity-100 hover:border-navy-400"
        )}
      >
        {selected && (
          <svg
            viewBox="0 0 12 12"
            className="h-3 w-3 text-white"
            fill="none"
            strokeWidth="2.5"
            stroke="currentColor"
            strokeLinecap="round"
            strokeLinejoin="round"
            aria-hidden
          >
            <path d="M2.5 6L5 8.5L9.5 4" />
          </svg>
        )}
      </button>
      <div
        className={cn(
          "transition-all duration-150",
          selected && "bg-navy-50/40"
        )}
      >
        {children}
      </div>
    </div>
  );
}

function EmptyInbox() {
  return (
    <div className="bg-white border border-navy-100 rounded-2xl shadow-soft py-20 px-6 text-center">
      <div className="mx-auto h-16 w-16 rounded-2xl bg-gradient-to-br from-navy-50 via-white to-gold-50 border border-navy-100 flex items-center justify-center shadow-soft">
        <Inbox className="h-7 w-7 text-navy-400" />
      </div>
      <h3 className="mt-5 font-display text-lg font-semibold text-navy-950">
        Boîte vide
      </h3>
      <p className="mt-2 text-sm text-slate-500 max-w-sm mx-auto leading-relaxed">
        Tu n&apos;as encore reçu aucune notification. Quand un examen, un
        message ou un succès arrivera, il s&apos;affichera ici.
      </p>
    </div>
  );
}

function EmptyFiltered({ onReset }: { onReset: () => void }) {
  return (
    <div className="bg-white border border-navy-100 rounded-2xl shadow-soft py-16 px-6 text-center">
      <div className="mx-auto h-12 w-12 rounded-2xl bg-navy-50 border border-navy-100 flex items-center justify-center">
        <Search className="h-5 w-5 text-navy-400" />
      </div>
      <h3 className="mt-4 font-display text-base font-semibold text-navy-950">
        Aucun résultat
      </h3>
      <p className="mt-1.5 text-[13px] text-slate-500">
        Aucune notification ne correspond à ces filtres.
      </p>
      <button
        type="button"
        onClick={onReset}
        className="mt-4 inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-[12px] font-semibold text-navy-700 bg-white border border-navy-100 hover:bg-navy-50 transition-colors"
      >
        <X className="h-3.5 w-3.5" />
        Réinitialiser
      </button>
    </div>
  );
}
