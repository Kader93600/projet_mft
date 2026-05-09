// ============================================================
// Mapping type de notification → icône + tonalité visuelle
// Utilisé par le centre de notifications (dropdown topbar) et la
// page archive /notifications.
// ============================================================
import type { LucideIcon } from "lucide-react";
import {
  Megaphone,
  MessageCircle,
  Info,
  ClipboardCheck,
  GraduationCap,
  Trophy,
  BookOpen,
  Shield,
  CalendarCheck,
  Award,
  BadgeCheck,
} from "lucide-react";

export type NotificationType =
  // Catégories du centre premium
  | "announcement"
  | "message"
  | "system"
  | "quiz_result"
  | "exam"
  | "achievement"
  | "course"
  | "admin"
  // Types legacy émis par d'autres modules (mappés visuellement)
  | "coaching"
  | "badge"
  | "certificate";

export interface NotificationStyle {
  icon: LucideIcon;
  /** Classes pour le carré rond qui contient l'icône (fond + texte + bord) */
  tone: string;
  /** Libellé court pour aria-label / écran-lecteur */
  label: string;
}

// Note : "gold" et "navy" sont des aliases vers la palette de marque
// MA FORMATION TRANSPORT (vert lime signal + bleu royal).
// Voir tailwind.config.ts pour la palette complète.
export const NOTIFICATION_STYLES: Record<NotificationType, NotificationStyle> = {
  announcement: {
    icon: Megaphone,
    tone: "bg-gold-50 text-gold-800 border-gold-200",
    label: "Annonce",
  },
  message: {
    icon: MessageCircle,
    tone: "bg-navy-50 text-navy-700 border-navy-100",
    label: "Message",
  },
  system: {
    icon: Info,
    tone: "bg-slate-100 text-slate-700 border-slate-200",
    label: "Système",
  },
  quiz_result: {
    icon: ClipboardCheck,
    tone: "bg-emerald-50 text-emerald-700 border-emerald-200",
    label: "Résultat de quiz",
  },
  exam: {
    icon: GraduationCap,
    tone: "bg-amber-50 text-amber-800 border-amber-200",
    label: "Examen",
  },
  achievement: {
    icon: Trophy,
    tone: "bg-gold-50 text-gold-800 border-gold-200",
    label: "Réussite",
  },
  course: {
    icon: BookOpen,
    tone: "bg-sky-50 text-sky-700 border-sky-200",
    label: "Formation",
  },
  admin: {
    icon: Shield,
    tone: "bg-rose-50 text-rose-700 border-rose-200",
    label: "Administration",
  },
  // ── Types legacy ─────────────────────────────────────────────
  coaching: {
    icon: CalendarCheck,
    tone: "bg-navy-50 text-navy-700 border-navy-100",
    label: "Accompagnement",
  },
  badge: {
    icon: BadgeCheck,
    tone: "bg-gold-50 text-gold-800 border-gold-200",
    label: "Badge",
  },
  certificate: {
    icon: Award,
    tone: "bg-amber-50 text-amber-800 border-amber-200",
    label: "Certificat",
  },
};

export function getNotificationStyle(
  type: string | null | undefined
): NotificationStyle {
  if (type && type in NOTIFICATION_STYLES) {
    return NOTIFICATION_STYLES[type as NotificationType];
  }
  return NOTIFICATION_STYLES.system;
}

/**
 * Format relatif compact en français : "à l'instant", "il y a 5 min",
 * "il y a 3 h", "Hier", "il y a 4 j", puis date courte ("12 mai").
 */
export function relativeTimeFr(iso: string): string {
  const now = Date.now();
  const t = new Date(iso).getTime();
  if (Number.isNaN(t)) return "";
  const diff = Math.max(0, now - t);
  const sec = Math.floor(diff / 1000);
  if (sec < 45) return "À l'instant";
  const min = Math.floor(sec / 60);
  if (min < 60) return `il y a ${min} min`;
  const hr = Math.floor(min / 60);
  if (hr < 24) return `il y a ${hr} h`;
  const day = Math.floor(hr / 24);
  if (day === 1) return "Hier";
  if (day < 7) return `il y a ${day} j`;
  return new Date(iso).toLocaleDateString("fr-FR", {
    day: "2-digit",
    month: "short",
  });
}
