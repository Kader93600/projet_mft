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
} from "lucide-react";

export type NavItem = {
  href: string;
  label: string;
  icon: any;
  short?: string;
  exact?: boolean;
};
export type NavGroup = { label: string; items: NavItem[] };

// === Stagiaire ===
export const STUDENT_GROUPS: NavGroup[] = [
  {
    label: "Apprendre",
    items: [
      { href: "/dashboard", label: "Tableau de bord", icon: LayoutDashboard, short: "Accueil" },
      { href: "/modules", label: "Modules", icon: BookOpen, short: "Modules" },
      { href: "/quiz", label: "Quiz & Examens", icon: ClipboardCheck, short: "Quiz" },
      { href: "/glossaire", label: "Glossaire", icon: Library, short: "Gloss." },
    ],
  },
  {
    label: "Suivi",
    items: [
      { href: "/stats", label: "Mes résultats", icon: BarChart3, short: "Stats" },
      { href: "/reussites", label: "Réussites", icon: Award, short: "Badges" },
      { href: "/classement", label: "Classement", icon: Trophy, short: "Rang" },
      { href: "/certificats", label: "Certificats", icon: ScrollText, short: "Certifs" },
    ],
  },
  {
    label: "Échanger",
    items: [
      { href: "/messages", label: "Messages", icon: MessageCircle, short: "Chat" },
      { href: "/accompagnement", label: "Accompagnement", icon: HeartHandshake, short: "Suivi" },
      { href: "/emargement", label: "Émargement", icon: ScrollText, short: "Émarg." },
      { href: "/satisfaction", label: "Évaluations", icon: Award, short: "Avis" },
    ],
  },
  {
    label: "Mon compte",
    items: [
      { href: "/inscription", label: "Mon inscription", icon: Receipt, short: "Inscr." },
      { href: "/mes-documents", label: "Mes documents", icon: FileText, short: "Docs" },
      { href: "/accessibilite", label: "Accessibilité", icon: Accessibility, short: "A11y" },
      { href: "/mes-donnees", label: "Mes données", icon: ShieldCheck, short: "RGPD" },
    ],
  },
];

// === Admin ===
export const ADMIN_GROUPS: NavGroup[] = [
  {
    label: "Pilotage",
    items: [
      { href: "/admin", label: "Vue d'ensemble", icon: LayoutDashboard, exact: true },
      { href: "/admin/analytics", label: "Analytiques", icon: BarChart3 },
      { href: "/admin/reports", label: "Rapports Qualiopi", icon: FileText },
      { href: "/admin/reports/bpf", label: "BPF (DGEFP)", icon: FileText },
    ],
  },
  {
    label: "Personnes",
    items: [
      { href: "/admin/users", label: "Utilisateurs", icon: Users },
      { href: "/admin/affectations", label: "Affectations", icon: UsersRound },
      { href: "/admin/groups", label: "Classes / Groupes", icon: UsersRound },
      { href: "/admin/coaching", label: "Accompagnement", icon: HH2 },
      { href: "/admin/alerts", label: "Alertes inactivité", icon: HH2 },
      { href: "/admin/accessibilite", label: "Accessibilité", icon: Accessibility },
    ],
  },
  {
    label: "Pédagogie",
    items: [
      { href: "/admin/formations", label: "Catalogue formations", icon: BookOpen },
      { href: "/admin/banque-questions", label: "Banque de questions", icon: ClipboardList },
      { href: "/admin/modules", label: "Modules & leçons", icon: BookOpen },
      { href: "/admin/quizzes", label: "Quiz & examens", icon: ClipboardList },
      { href: "/admin/placement", label: "Positionnement", icon: Target },
      { href: "/admin/glossary", label: "Glossaire", icon: Library },
      { href: "/admin/badges", label: "Badges & certificats", icon: Award },
    ],
  },
  {
    label: "Communication",
    items: [
      { href: "/admin/announcements", label: "Annonces", icon: Megaphone },
      { href: "/admin/messages", label: "Messagerie", icon: MessageCircle },
    ],
  },
  {
    label: "Administration",
    items: [
      { href: "/admin/enrollments", label: "Inscriptions & paiements", icon: Wallet },
      { href: "/admin/settings/formation", label: "Paramètres formation", icon: Settings },
      { href: "/admin/settings/documents", label: "Documents d'accueil", icon: FileSignature },
      { href: "/admin/rgpd", label: "RGPD & confidentialité", icon: ShieldCheck },
      { href: "/admin/security", label: "Sécurité (2FA)", icon: ShieldCheck },
      { href: "/admin/audit", label: "Journal d'audit", icon: Shield },
    ],
  },
];

export function flattenGroups(groups: NavGroup[]): NavItem[] {
  return groups.flatMap((g) => g.items);
}
