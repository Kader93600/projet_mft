import {
  BarChart3,
  BookOpen,
  ClipboardCheck,
  FileText,
  LayoutDashboard,
  MessageCircle,
  Library,
  Award,
  ScrollText,
  HeartHandshake,
  Accessibility,
  Trophy,
  Receipt,
  ShieldCheck,
  Users,
  UsersRound,
  ClipboardList,
  Megaphone,
  Settings,
  FileSignature,
  Target,
  HeartHandshake as HH2,
  Wallet,
  Shield,
  Tags,
  Dumbbell,
  GraduationCap,
  Video,
  CalendarDays,
  Sparkles,
  Gift,
  Briefcase,
  Inbox,
  Crown,
  Landmark,
  FolderOpen,
} from "lucide-react";

/**
 * Items et groupes de navigation.
 *
 * Les libellés sont stockés sous forme de clés i18n (`labelKey`, `shortKey`)
 * que les consommateurs (sidebar, mobile-nav, app-shell, admin-shell)
 * passent à `t()` (next-intl) au moment du rendu. La clé est complète,
 * incluant son namespace ("nav.dashboard", "navGroups.learn", etc.).
 */
export type NavItem = {
  href: string;
  labelKey: string;
  icon: any;
  shortKey?: string;
  exact?: boolean;
};
export type NavGroup = { labelKey: string; items: NavItem[] };

// === Stagiaire ===
export const STUDENT_GROUPS: NavGroup[] = [
  {
    labelKey: "navGroups.learn",
    items: [
      { href: "/dashboard", labelKey: "nav.dashboard", icon: LayoutDashboard, shortKey: "navShort.home" },
      { href: "/modules", labelKey: "nav.modules", icon: BookOpen, shortKey: "navShort.modules" },
      { href: "/exercices", labelKey: "nav.exercises", icon: Dumbbell, shortKey: "navShort.exercises" },
      { href: "/examens-blancs", labelKey: "nav.mockExams", icon: GraduationCap, shortKey: "navShort.mockExams" },
      { href: "/glossaire", labelKey: "nav.glossary", icon: Library, shortKey: "navShort.glossary" },
    ],
  },
  {
    labelKey: "navGroups.track",
    items: [
      { href: "/stats", labelKey: "nav.stats", icon: BarChart3, shortKey: "navShort.stats" },
      { href: "/reussites", labelKey: "nav.achievements", icon: Award, shortKey: "navShort.achievements" },
      { href: "/classement", labelKey: "nav.ranking", icon: Trophy, shortKey: "navShort.ranking" },
      { href: "/certificats", labelKey: "nav.certificates", icon: ScrollText, shortKey: "navShort.certificates" },
    ],
  },
  {
    labelKey: "navGroups.exchange",
    items: [
      { href: "/messages", labelKey: "nav.messages", icon: MessageCircle, shortKey: "navShort.messages" },
      { href: "/accompagnement", labelKey: "nav.coaching" /* fallback nav.* */, icon: HeartHandshake, shortKey: "navShort.coaching" },
      { href: "/sessions", labelKey: "nav.sessions", icon: Video, shortKey: "navShort.sessions" },
      { href: "/emargement", labelKey: "nav.attendance", icon: ScrollText, shortKey: "navShort.attendance" },
      { href: "/satisfaction", labelKey: "nav.satisfaction", icon: Award, shortKey: "navShort.satisfaction" },
    ],
  },
  {
    labelKey: "navGroups.account",
    items: [
      { href: "/inscription", labelKey: "nav.enrollment", icon: Receipt, shortKey: "navShort.enrollment" },
      { href: "/parrainage", labelKey: "nav.referral", icon: Gift, shortKey: "navShort.referral" },
      { href: "/fidelite", labelKey: "nav.loyalty", icon: Crown, shortKey: "navShort.loyalty" },
      { href: "/mes-documents", labelKey: "nav.documents", icon: FileText, shortKey: "navShort.documents" },
      { href: "/accessibilite", labelKey: "nav.accessibility", icon: Accessibility, shortKey: "navShort.accessibility" },
      { href: "/mes-donnees", labelKey: "nav.personalData", icon: ShieldCheck, shortKey: "navShort.personalData" },
    ],
  },
];

// === Admin ===
export const ADMIN_GROUPS: NavGroup[] = [
  {
    labelKey: "navGroups.pilotage",
    items: [
      { href: "/admin", labelKey: "nav.adminOverview", icon: LayoutDashboard, exact: true },
      { href: "/admin/analytics", labelKey: "nav.adminAnalytics", icon: BarChart3 },
      { href: "/admin/reports", labelKey: "nav.adminReports", icon: FileText },
      { href: "/admin/reports/bpf", labelKey: "nav.adminBpf", icon: FileText },
    ],
  },
  {
    labelKey: "navGroups.people",
    items: [
      { href: "/admin/users", labelKey: "nav.adminUsers", icon: Users },
      { href: "/admin/affectations", labelKey: "nav.adminAssignments", icon: UsersRound },
      { href: "/admin/groups", labelKey: "nav.adminGroups", icon: UsersRound },
      { href: "/admin/coaching", labelKey: "nav.adminCoaching", icon: HH2 },
      { href: "/admin/alerts", labelKey: "nav.adminAlerts", icon: HH2 },
      { href: "/admin/documents", labelKey: "nav.adminDocuments", icon: FolderOpen },
      { href: "/admin/accessibilite", labelKey: "nav.adminAccessibility", icon: Accessibility },
    ],
  },
  {
    labelKey: "navGroups.pedagogy",
    items: [
      { href: "/admin/formations", labelKey: "nav.adminFormations", icon: BookOpen },
      { href: "/admin/banque-questions", labelKey: "nav.adminQuestionBank", icon: ClipboardList },
      { href: "/admin/modules", labelKey: "nav.adminModules", icon: BookOpen },
      { href: "/admin/quizzes", labelKey: "nav.adminQuizzes", icon: ClipboardList },
      { href: "/admin/sessions", labelKey: "nav.adminSessions", icon: Video },
      { href: "/admin/emargement", labelKey: "nav.adminAttendance", icon: ScrollText },
      { href: "/admin/placement", labelKey: "nav.adminPlacement", icon: Target },
      { href: "/admin/glossary", labelKey: "nav.adminGlossary", icon: Library },
      { href: "/admin/badges", labelKey: "nav.adminBadges", icon: Award },
    ],
  },
  {
    labelKey: "navGroups.communication",
    items: [
      { href: "/admin/announcements", labelKey: "nav.adminAnnouncements", icon: Megaphone },
      { href: "/admin/messages", labelKey: "nav.adminMessages", icon: MessageCircle },
    ],
  },
  {
    labelKey: "navGroups.administration",
    items: [
      { href: "/admin/crm", labelKey: "nav.adminCrm", icon: Inbox },
      { href: "/admin/enrollments", labelKey: "nav.adminEnrollments", icon: Wallet },
      { href: "/admin/organizations", labelKey: "nav.adminOrganizations", icon: Briefcase },
      { href: "/admin/pricing", labelKey: "nav.adminPricing", icon: Tags },
      { href: "/admin/edof", labelKey: "nav.adminEdof", icon: Landmark },
      { href: "/admin/settings", labelKey: "nav.adminSettingsIndex", icon: Settings, exact: true },
      { href: "/admin/settings/formation", labelKey: "nav.adminSettingsFormation", icon: Settings },
      { href: "/admin/settings/documents", labelKey: "nav.adminSettingsDocuments", icon: FileSignature },
      { href: "/admin/rgpd", labelKey: "nav.adminRgpd", icon: ShieldCheck },
      { href: "/admin/security", labelKey: "nav.adminSecurity", icon: ShieldCheck },
      { href: "/admin/audit", labelKey: "nav.adminAudit", icon: Shield },
      { href: "/admin/tutor", labelKey: "nav.adminTutor", icon: Sparkles },
      { href: "/admin/referrals", labelKey: "nav.adminReferrals", icon: Gift },
    ],
  },
];

export function flattenGroups(groups: NavGroup[]): NavItem[] {
  return groups.flatMap((g) => g.items);
}
