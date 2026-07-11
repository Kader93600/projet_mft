"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useTranslations } from "next-intl";
import { cn } from "@/lib/utils";
import { ToastProvider } from "@/components/ui/toast";
import { EmailComposerProvider } from "@/components/email/email-composer-provider";
import { SessionTracker } from "@/components/session-tracker";
import { ChevronRight } from "lucide-react";
import { NotificationsBell } from "@/components/notifications-bell";
import { SearchPalette } from "@/components/search-palette";
import { ThemeToggle } from "@/components/theme-toggle";
import { LocaleToggle } from "@/components/locale-toggle";
import { SidebarNav } from "@/components/sidebar-nav";
import { MobileNavSheet } from "@/components/mobile-nav-sheet";
import { UserMenu } from "@/components/user-menu";
import { ADMIN_GROUPS, flattenGroups } from "@/components/nav-groups";
import { LogoMark } from "@/components/ui/logo";
import {
  TRAINER_ALLOWED_ADMIN_PREFIXES,
  isTrainer as roleIsTrainer,
} from "@/lib/permissions";

interface Props {
  children: React.ReactNode;
  profile: { full_name: string | null; email: string; role: string };
  /** Pastilles de notification par href (ex. { "/admin/emails": 3 }). */
  badges?: Record<string, number>;
}

const FLAT = flattenGroups(ADMIN_GROUPS);

/**
 * Filtre la nav admin selon le rôle :
 * - admin / super_admin : tout
 * - trainer : seulement les items pédagogiques autorisés
 */
function filterGroupsForRole(role: string) {
  if (!roleIsTrainer(role)) return ADMIN_GROUPS;
  return ADMIN_GROUPS.map((g) => ({
    ...g,
    items: g.items.filter((it) =>
      TRAINER_ALLOWED_ADMIN_PREFIXES.some((p) =>
        (it.href as string).startsWith(p)
      )
    ),
  })).filter((g) => g.items.length > 0);
}
const MOBILE_PRIMARY = FLAT.filter((i) =>
  ["/admin", "/admin/users", "/admin/modules", "/admin/quizzes"].includes(i.href)
);

/**
 * Construit le fil d'Ariane à partir du pathname.
 * Pour chaque segment, soit on trouve un NavItem connu (→ `labelKey` traduit),
 * soit on retombe sur le segment URL décodé comme libellé brut.
 */
function crumbsFromPath(p: string): { labelKey?: string; rawLabel?: string; href: string }[] {
  const parts = p.split("/").filter(Boolean);
  const crumbs: { labelKey?: string; rawLabel?: string; href: string }[] = [];
  let acc = "";
  for (const part of parts) {
    acc += "/" + part;
    const item = FLAT.find((n) => n.href === acc);
    crumbs.push(
      item
        ? { labelKey: item.labelKey, href: acc }
        : { rawLabel: decodeURIComponent(part), href: acc }
    );
  }
  return crumbs;
}

export function AdminShell({ children, profile, badges }: Props) {
  const pathname = usePathname();
  const t = useTranslations();
  const tA11y = useTranslations("a11y");
  const tShell = useTranslations("shell");
  const crumbs = crumbsFromPath(pathname);

  return (
    <ToastProvider>
      <EmailComposerProvider>
      <SessionTracker />
      <div className="min-h-screen flex bg-ivory text-ink dark:bg-[hsl(var(--bg))] dark:text-[hsl(var(--text))]">
        {/* Skip link a11y */}
        <a href="#admin-content" className="skip-link">
          {tA11y("skipToContent")}
        </a>
        {/* Sidebar admin */}
        <aside className="hidden md:flex w-72 flex-col border-r border-navy-100 bg-navy-950 text-white dark:bg-[hsl(var(--surface-2))] dark:border-[hsl(var(--border))]">
          <div className="h-16 flex items-center px-5 border-b border-white/10">
            <Link href="/admin" className="flex items-center gap-2.5 min-w-0">
              <LogoMark className="h-9 w-9 shrink-0" variant="light" />
              <div className="min-w-0">
                <div className="font-sans font-bold text-[13px] leading-tight tracking-tight truncate">
                  MA FORMATION
                </div>
                <div className="font-sans font-extrabold text-[13px] leading-tight tracking-tight text-signal-400 -mt-0.5">
                  TRANSPORT
                </div>
              </div>
            </Link>
          </div>

          <SidebarNav
            groups={filterGroupsForRole(profile.role)}
            variant="dark"
            badges={badges}
          />
        </aside>

        {/* Mobile top bar */}
        <div className="md:hidden fixed top-0 left-0 right-0 h-14 bg-navy-950 text-white z-20 flex items-center justify-between px-4">
          <Link href="/admin" className="flex items-center gap-2">
            <LogoMark className="h-7 w-7" variant="light" />
            <span className="font-sans font-bold text-[12px] leading-none">
              MA FORMATION
              <span className="block text-signal-400 font-extrabold">TRANSPORT</span>
            </span>
          </Link>
          <UserMenu profile={profile} variant="dark" />
        </div>

        {/* Main */}
        <main className="flex-1 pt-14 md:pt-0 pb-20 md:pb-0">
          <div className="hidden md:flex h-16 items-center justify-between px-8 border-b border-navy-100 bg-white sticky top-0 z-10 dark:bg-[hsl(var(--surface))] dark:border-[hsl(var(--border))]">
            <nav className="flex items-center gap-1.5 text-sm">
              {crumbs.map((c, i) => {
                const label = c.labelKey ? t(c.labelKey) : c.rawLabel ?? "";
                return (
                  <span key={c.href} className="flex items-center gap-1.5">
                    {i > 0 && <ChevronRight className="h-3.5 w-3.5 text-slate-300" />}
                    {i === crumbs.length - 1 ? (
                      <span className="font-semibold text-navy-900 dark:text-[hsl(var(--text))]">{label}</span>
                    ) : (
                      <Link
                        href={c.href}
                        className="text-slate-500 dark:text-[hsl(var(--text-muted))] hover:text-navy-900 dark:hover:text-[hsl(var(--text))]"
                      >
                        {label}
                      </Link>
                    )}
                  </span>
                );
              })}
            </nav>
            <div className="flex items-center gap-3">
              <div className="hidden lg:block">
                <SearchPalette />
              </div>
              <ThemeToggle />
              <LocaleToggle />
              <NotificationsBell />
              {profile.role === "super_admin" ? (
                <span className="px-2.5 py-1 rounded-lg bg-gradient-to-r from-brand-600/15 to-signal-500/20 text-brand-900 text-[11px] font-semibold uppercase tracking-wide border border-signal-500/40 inline-flex items-center gap-1.5">
                  <span className="h-1.5 w-1.5 rounded-full bg-signal-500 animate-glow-pulse" />
                  {tShell("superAdminBadge")}
                </span>
              ) : profile.role === "trainer" ? (
                <span className="px-2.5 py-1 rounded-lg bg-emerald-100 text-emerald-800 text-[11px] font-semibold uppercase tracking-wide border border-emerald-200 inline-flex items-center gap-1.5">
                  <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
                  {tShell("trainerBadge")}
                </span>
              ) : (
                <span className="px-2.5 py-1 rounded-lg bg-brand-100 text-brand-800 text-[11px] font-semibold uppercase tracking-wide border border-brand-200">
                  {tShell("adminBadge")}
                </span>
              )}
              <UserMenu profile={profile} variant="light" />
            </div>
          </div>

          {/* max-w-screen-2xl (1536px) : le back-office est dense en données
              (tableaux 8-9 colonnes) — 7xl (1280px) forçait un scroll
              horizontal permanent sur les tables une fois la sidebar déduite. */}
          <div
            id="main-content"
            tabIndex={-1}
            className="max-w-screen-2xl mx-auto px-4 md:px-8 py-6 md:py-10"
          >
            {children}
          </div>

          <nav className="md:hidden fixed bottom-0 left-0 right-0 bg-white/95 backdrop-blur border-t border-navy-100 flex justify-around py-2 z-20 dark:bg-[hsl(var(--surface))]/95 dark:border-[hsl(var(--border))]" aria-label={tA11y("openMenu")}>
            {MOBILE_PRIMARY.map((item) => {
              const active = item.exact
                ? pathname === item.href
                : pathname.startsWith(item.href);
              // Mobile : on garde le premier mot du label traduit pour rester compact
              const fullLabel = t(item.labelKey);
              const shortLabel = fullLabel.split(" ")[0];
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className={cn(
                    "flex flex-col items-center gap-1 px-2 py-1 text-[10px] font-semibold tracking-wide",
                    active ? "text-navy-900 dark:text-[hsl(var(--text))]" : "text-slate-500 dark:text-[hsl(var(--text-muted))]"
                  )}
                >
                  <item.icon className={cn("w-5 h-5", active && "text-gold-600")} />
                  <span className="truncate max-w-[60px]">
                    {shortLabel}
                  </span>
                </Link>
              );
            })}
            <MobileNavSheet
              groups={filterGroupsForRole(profile.role)}
              badges={badges}
            />
          </nav>
        </main>
      </div>
      </EmailComposerProvider>
    </ToastProvider>
  );
}
