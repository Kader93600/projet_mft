// ============================================================
// Helpers UI partagés du système de messagerie
// ============================================================
import type {
  ConversationSummary,
  MessageRow,
} from "@/lib/messaging-types";

// ─── Formats temporels ────────────────────────────────────────

/** "À l'instant", "il y a 3 min", "Hier", "lun.", "12 mai" */
export function relativeTimeFr(iso: string | null | undefined): string {
  if (!iso) return "";
  const t = new Date(iso).getTime();
  if (Number.isNaN(t)) return "";
  const now = Date.now();
  const diff = Math.max(0, now - t);
  const sec = Math.floor(diff / 1000);
  if (sec < 45) return "À l'instant";
  const min = Math.floor(sec / 60);
  if (min < 60) return `il y a ${min} min`;
  const hr = Math.floor(min / 60);
  if (hr < 12) return `il y a ${hr} h`;

  const d = new Date(iso);
  const today = startOfDay(new Date());
  const dayDiff = Math.floor((today.getTime() - startOfDay(d).getTime()) / 86400000);
  if (dayDiff === 0) return formatHourMinute(d);
  if (dayDiff === 1) return "Hier";
  if (dayDiff < 7) {
    return d
      .toLocaleDateString("fr-FR", { weekday: "short" })
      .replace(".", "");
  }
  return d.toLocaleDateString("fr-FR", { day: "2-digit", month: "short" });
}

/** "Aujourd'hui", "Hier", "Mardi 7 mai" — utilisé pour les séparateurs de jour */
export function dayLabelFr(iso: string): string {
  const d = new Date(iso);
  const today = startOfDay(new Date());
  const dayDiff = Math.floor(
    (today.getTime() - startOfDay(d).getTime()) / 86400000
  );
  if (dayDiff === 0) return "Aujourd'hui";
  if (dayDiff === 1) return "Hier";
  return d.toLocaleDateString("fr-FR", {
    weekday: "long",
    day: "numeric",
    month: "long",
  });
}

/** "14:32" */
export function formatHourMinute(d: Date): string {
  return d.toLocaleTimeString("fr-FR", {
    hour: "2-digit",
    minute: "2-digit",
  });
}

function startOfDay(d: Date): Date {
  const x = new Date(d);
  x.setHours(0, 0, 0, 0);
  return x;
}

/** Clé de jour pour grouper (YYYY-MM-DD) */
export function dayKey(iso: string): string {
  const d = new Date(iso);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}

// ─── Avatars / initiales ─────────────────────────────────────

export function initials(name: string | null | undefined): string {
  if (!name) return "?";
  return name
    .split(" ")
    .filter(Boolean)
    .slice(0, 2)
    .map((p) => p[0]?.toUpperCase() ?? "")
    .join("") || "?";
}

/** Couleur stable d'avatar dérivée du userId (palette navy/gold/emerald/rose/sky/violet) */
const AVATAR_PALETTES = [
  "bg-navy-100 text-navy-800",
  "bg-gold-100 text-gold-900",
  "bg-emerald-100 text-emerald-800",
  "bg-rose-100 text-rose-800",
  "bg-sky-100 text-sky-800",
  "bg-amber-100 text-amber-900",
];

export function avatarTone(seed: string | null | undefined): string {
  if (!seed) return AVATAR_PALETTES[0];
  let h = 0;
  for (let i = 0; i < seed.length; i++) {
    h = (h * 31 + seed.charCodeAt(i)) >>> 0;
  }
  return AVATAR_PALETTES[h % AVATAR_PALETTES.length];
}

// ─── Conversation helpers ────────────────────────────────────

/** Titre à afficher dans la liste / l'en-tête, robuste au cas DM sans titre. */
export function conversationTitle(c: ConversationSummary): string {
  if (c.title && c.title.length > 0) return c.title;
  if (c.kind === "dm" && c.other_participant_name) {
    return c.other_participant_name;
  }
  if (c.scope === "admin_team") return "Équipe admin";
  if (c.scope === "class") return "Classe";
  return "Conversation";
}

/** Pour l'icône d'avatar : initiales du titre ou de l'autre participant. */
export function conversationInitials(c: ConversationSummary): string {
  return initials(conversationTitle(c));
}

/** Identifiant pour la couleur d'avatar (stable par conv) */
export function conversationAvatarSeed(c: ConversationSummary): string {
  return c.other_participant_id ?? c.group_id ?? c.id;
}

/** Pill court en sidebar : "Formateur", "Admin", "Classe", "Équipe" */
export function conversationKindLabel(c: ConversationSummary): string {
  if (c.kind === "dm") {
    if (c.other_participant_role === "trainer") return "Formateur";
    if (c.other_participant_role === "admin" || c.other_participant_role === "super_admin")
      return "Admin";
    if (c.other_participant_role === "student") return "Stagiaire";
    return "Direct";
  }
  if (c.scope === "admin_team") return "Équipe";
  if (c.scope === "class") return "Classe";
  return "Groupe";
}

/** Tone de couleur du pill */
export function conversationKindTone(c: ConversationSummary): string {
  if (c.kind === "dm") {
    if (c.other_participant_role === "trainer")
      return "bg-emerald-50 text-emerald-700 border-emerald-200";
    if (c.other_participant_role === "admin" || c.other_participant_role === "super_admin")
      return "bg-rose-50 text-rose-700 border-rose-200";
    if (c.other_participant_role === "student")
      return "bg-sky-50 text-sky-700 border-sky-200";
    return "bg-slate-100 text-slate-700 border-slate-200";
  }
  if (c.scope === "admin_team")
    return "bg-rose-50 text-rose-700 border-rose-200";
  if (c.scope === "class")
    return "bg-gold-50 text-gold-800 border-gold-200";
  return "bg-navy-50 text-navy-700 border-navy-100";
}

// ─── Messages : groupage par jour + auteur consécutif ───────

export interface MessageDayBucket {
  dayKey: string;
  label: string;
  groups: MessageGroup[];
}

export interface MessageGroup {
  /** Premier message du groupe — donne le sender + le timestamp d'ouverture. */
  senderId: string;
  senderRole: string;
  startsAt: string;
  messages: MessageRow[];
}

/** Empile les messages en groupes consécutifs par auteur, dans des jours. */
export function bucketMessagesByDayAndSender(
  messages: MessageRow[]
): MessageDayBucket[] {
  if (messages.length === 0) return [];
  const out: MessageDayBucket[] = [];
  let currentDayKey = "";
  let currentBucket: MessageDayBucket | null = null;
  let currentGroup: MessageGroup | null = null;
  const GROUP_MS = 5 * 60_000; // gap > 5 min → nouveau groupe

  for (const m of messages) {
    const k = dayKey(m.created_at);
    if (k !== currentDayKey) {
      currentBucket = { dayKey: k, label: dayLabelFr(m.created_at), groups: [] };
      out.push(currentBucket);
      currentDayKey = k;
      currentGroup = null;
    }
    const lastMsg = currentGroup?.messages[currentGroup.messages.length - 1];
    const sameSender = currentGroup?.senderId === m.sender_id;
    const closeInTime = lastMsg
      ? new Date(m.created_at).getTime() - new Date(lastMsg.created_at).getTime() < GROUP_MS
      : false;
    if (currentGroup && sameSender && closeInTime) {
      currentGroup.messages.push(m);
    } else {
      currentGroup = {
        senderId: m.sender_id,
        senderRole: m.sender_role,
        startsAt: m.created_at,
        messages: [m],
      };
      currentBucket!.groups.push(currentGroup);
    }
  }
  return out;
}

// ─── Tri / filtrage de la liste de conversations ─────────────

export type ConversationFilter =
  | "all"
  | "unread"
  | "pinned"
  | "archived"
  | "dm"
  | "groups";

export function filterConversations(
  list: ConversationSummary[],
  filter: ConversationFilter,
  query: string
): ConversationSummary[] {
  let out = list;

  // Archives : exclues sauf si filtre = archived
  if (filter !== "archived") {
    out = out.filter((c) => !c.archived_at);
  } else {
    out = out.filter((c) => !!c.archived_at);
  }

  if (filter === "unread") out = out.filter((c) => c.unread_count > 0);
  if (filter === "pinned") out = out.filter((c) => !!c.pinned_at);
  if (filter === "dm") out = out.filter((c) => c.kind === "dm");
  if (filter === "groups") out = out.filter((c) => c.kind === "group");

  if (query.trim()) {
    const q = query.trim().toLowerCase();
    out = out.filter((c) => {
      const title = (conversationTitle(c) || "").toLowerCase();
      const preview = (c.last_message_preview ?? "").toLowerCase();
      return title.includes(q) || preview.includes(q);
    });
  }

  return out;
}
