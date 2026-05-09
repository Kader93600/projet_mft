// ============================================================
// Groupement intelligent des notifications
//
// Deux fonctions principales :
//   - groupNotifications(list, { minGroupSize })
//       Regroupe les notifs sémantiquement proches en "Groupes".
//       Règles :
//         · même type ET même link_url → même thread (ex: 3 messages
//           dans la même conversation Marc)
//         · sinon, même type ET même jour calendaire (ex: 3 badges
//           débloqués aujourd'hui)
//       Si la taille du groupe < minGroupSize, chaque item est rendu
//       individuellement.
//
//   - splitByDateSection(list)
//       Découpe une liste (de notifs ou de groupes) en sections
//       chronologiques : Aujourd'hui, Hier, Cette semaine, Plus ancien.
// ============================================================
import type { NotificationRow } from "@/components/notification-item";

export interface NotificationGroup {
  /** Clé stable du groupe (type:linkUrl ou type:YYYY-MM-DD). */
  key: string;
  type: string;
  count: number;
  /** Items du groupe, triés du plus récent au plus ancien. */
  items: NotificationRow[];
  /** Date ISO du dernier item du groupe (utilisée pour le tri). */
  latestAt: string;
  /** link_url commun (si tous partagent le même), sinon null. */
  linkUrl: string | null;
  /** Nombre de non-lus dans le groupe. */
  unreadCount: number;
}

export type GroupedItem =
  | { kind: "single"; notif: NotificationRow }
  | { kind: "group"; group: NotificationGroup };

function dayKey(iso: string): string {
  const d = new Date(iso);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}

function computeGroupKey(n: NotificationRow): string {
  const type = n.type ?? "system";
  // Si on a un link_url → groupe par thread (ex: messages d'une conv)
  if (n.link_url && n.link_url.length > 0) {
    return `${type}::url::${n.link_url}`;
  }
  // Sinon → groupe par jour
  return `${type}::day::${dayKey(n.created_at)}`;
}

/**
 * Regroupe une liste triée DESC par created_at en items individuels
 * et groupes selon les règles ci-dessus.
 */
export function groupNotifications(
  notifs: NotificationRow[],
  opts: { minGroupSize: number } = { minGroupSize: 3 }
): GroupedItem[] {
  if (notifs.length === 0) return [];

  // Phase 1 : bucket par clé
  const buckets = new Map<string, NotificationRow[]>();
  for (const n of notifs) {
    const key = computeGroupKey(n);
    const arr = buckets.get(key);
    if (arr) arr.push(n);
    else buckets.set(key, [n]);
  }

  // Phase 2 : émission ordonnée — un groupe apparaît à la position
  // de son item le plus récent (premier rencontré dans la liste DESC)
  const seen = new Set<string>();
  const out: GroupedItem[] = [];
  for (const n of notifs) {
    const key = computeGroupKey(n);
    const bucket = buckets.get(key)!;
    if (bucket.length >= opts.minGroupSize) {
      if (seen.has(key)) continue;
      seen.add(key);
      out.push({
        kind: "group",
        group: {
          key,
          type: bucket[0].type ?? "system",
          count: bucket.length,
          items: bucket,
          latestAt: bucket[0].created_at,
          linkUrl: bucket[0].link_url ?? null,
          unreadCount: bucket.filter((b) => !b.read_at).length,
        },
      });
    } else {
      out.push({ kind: "single", notif: n });
    }
  }

  return out;
}

// ============================================================
// Sections par date (Aujourd'hui / Hier / Cette semaine / Plus ancien)
// ============================================================

export type DateSectionKey = "today" | "yesterday" | "this_week" | "older";

export const DATE_SECTION_LABEL: Record<DateSectionKey, string> = {
  today: "Aujourd'hui",
  yesterday: "Hier",
  this_week: "Cette semaine",
  older: "Plus ancien",
};

export interface DateSection {
  key: DateSectionKey;
  label: string;
  items: GroupedItem[];
}

function startOfDay(d: Date): number {
  const x = new Date(d);
  x.setHours(0, 0, 0, 0);
  return x.getTime();
}

function getSectionKey(iso: string, now: Date = new Date()): DateSectionKey {
  const t = new Date(iso).getTime();
  const todayStart = startOfDay(now);
  const yesterdayStart = todayStart - 24 * 3600 * 1000;
  // Début de semaine = lundi de la semaine en cours
  const dow = (now.getDay() + 6) % 7; // 0 = lundi
  const weekStart = todayStart - dow * 24 * 3600 * 1000;

  if (t >= todayStart) return "today";
  if (t >= yesterdayStart) return "yesterday";
  if (t >= weekStart) return "this_week";
  return "older";
}

function itemDateIso(item: GroupedItem): string {
  return item.kind === "single" ? item.notif.created_at : item.group.latestAt;
}

/**
 * Découpe une liste de GroupedItem en sections chronologiques.
 * L'ordre des items dans chaque section est préservé.
 */
export function splitByDateSection(items: GroupedItem[]): DateSection[] {
  const map = new Map<DateSectionKey, GroupedItem[]>();
  const order: DateSectionKey[] = ["today", "yesterday", "this_week", "older"];
  const now = new Date();

  for (const item of items) {
    const key = getSectionKey(itemDateIso(item), now);
    const arr = map.get(key);
    if (arr) arr.push(item);
    else map.set(key, [item]);
  }

  return order
    .filter((k) => map.has(k))
    .map((k) => ({ key: k, label: DATE_SECTION_LABEL[k], items: map.get(k)! }));
}

/**
 * Filtre une liste par lecture / non-lecture. Pratique côté UI.
 */
export function filterUnread(notifs: NotificationRow[]): NotificationRow[] {
  return notifs.filter((n) => !n.read_at);
}
