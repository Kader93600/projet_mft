"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";
import { Logo } from "@/components/ui/logo";
import { Settings, Shield } from "lucide-react";
import { NotificationsBell } from "@/components/notifications-bell";
import { SearchPalette } from "@/components/search-palette";
import { ThemeToggle } from "@/components/theme-toggle";
import { SidebarNav } from "@/components/sidebar-nav";
import { MobileNavSheet } from "@/components/mobile-nav-sheet";
import { UserMenu } from "@/components/user-menu";
import { STUDENT_GROUPS, flattenGroups } from "@/components/nav-groups";

interface AppShellProps {
  children: React.ReactNode;
  profile: {
    full_name: string | null;
    email: string;
    role: "student" | "trainer" | "admin" | "super_admin";
    level: string;
  };
}

const FLAT = flattenGroups(STUDENT_GROUPS);
// 4 raccourcis principaux pour la barre mobile (5e = "Plus")
const MOBILE_PRIMARY = FLAT.filter((i) =>
  ["/dashboard", "/modules", "/exercices", "/examens-blancs"].includes(i.href)
);

export function AppShell({ children, profile }: AppShellProps) {
  const pathname = usePathname();

  const pageTitle =
    FLAT.find((n) => pathname === n.href || pathname.startsWith(n.href + "/"))
      ?.label ??
    (pathname.startsWith("/admin") ? "Administration" : "MA FORMATION TRANSPORT");

  return (
    <div className="min-h-screen flex bg-ivory text-ink dark:bg-[hsl(var(--bg))] dark:text-[hsl(var(--text))]">
      {/* Skip link a11y — visible au focus uniquement */}
      <a href="#main-content" className="skip-link">
        Aller au contenu principal
      </a>
      {/* Sidebar desktop */}
      <aside className="hidden md:flex w-72 flex-col border-r border-navy-100 bg-white dark:bg-[hsl(var(--surface))] dark:border-[hsl(var(--border))]">
        <div className="h-16 flex items-center px-5 border-b border-navy-100 dark:border-[hsl(var(--border))]">
          <Link href="/dashboard">
            <Logo />
          </Link>
        </div>

        <SidebarNav groups={STUDENT_GROUPS} variant="light" />

        {(profile.role === "admin" || profile.role === "super_admin") && (
          <div className="px-3 pb-2 space-y-1">
            <Link
              href="/admin"
              className={cn(
                "flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-colors",
                pathname.startsWith("/admin") && !pathname.startsWith("/admin/super")
                  ? "bg-brand-50 text-brand-900 border border-brand-200"
                  : "text-slate-600 hover:bg-brand-50 hover:text-brand-900"
              )}
            >
              <Shield className="w-4 h-4" />
              Espace admin
            </Link>
            {profile.role === "super_admin" && (
              <Link
                href="/super-admin"
                className={cn(
                  "flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-colors",
                  pathname.startsWith("/super-admin")
                    ? "bg-gradient-to-r from-brand-600/15 to-signal-500/15 text-brand-900 border border-brand-200"
                    : "text-slate-600 hover:bg-brand-50 hover:text-brand-900"
                )}
              >
                <Shield className="w-4 h-4" />
                Super-admin
              </Link>
            )}
          </div>
        )}

      </aside>

      {/* Mobile top bar */}
      <div className="md:hidden fixed top-0 left-0 right-0 h-14 bg-white border-b border-navy-100 z-20 flex items-center justify-between px-4 dark:bg-[hsl(var(--surface))] dark:border-[hsl(var(--border))]">
        <Link href="/dashboard">
          <Logo withText={false} />
        </Link>
        <div className="flex items-center gap-2">
          <NotificationsBell />
          <UserMenu profile={profile} variant="light" />
        </div>
      </div>

      {/* Main */}
      <main className="flex-1 pt-14 md:pt-0 pb-20 md:pb-0">
        {/* Topbar desktop */}
        <div className="hidden md:flex h-16 items-center justify-between px-8 border-b border-navy-100 bg-white/80 backdrop-blur sticky top-0 z-10 dark:bg-[hsl(var(--surface))]/80 dark:border-[hsl(var(--border))]">
          <div className="flex items-center gap-3">
            <span className="inline-flex items-center gap-1.5 rounded-md bg-signal-500/15 border border-signal-500/30 px-2 py-0.5 text-[10px] font-semibold uppercase tracking-[0.16em] text-signal-700 dark:text-signal-300">
              <span className="h-1.5 w-1.5 rounded-full bg-signal-500 animate-glow-pulse" />
              Stagiaire
            </span>
            <h1 className="font-display text-xl font-semibold text-navy-900 dark:text-[hsl(var(--text))] tracking-tight">
              {pageTitle}
            </h1>
          </div>
          <div className="flex items-center gap-2">
            <div className="hidden lg:block">
              <SearchPalette />
            </div>
            <ThemeToggle />
            <NotificationsBell />
            <div className="ml-2 flex items-center pl-3 border-l border-navy-100">
              <UserMenu profile={profile} variant="light" />
            </div>
          </div>
        </div>

        <div
          id="main-content"
          tabIndex={-1}
          className="max-w-7xl mx-auto px-4 md:px-8 py-6 md:py-10"
        >
          {children}
        </div>

        {/* Mobile bottom nav : 4 raccourcis + sheet "Plus" */}
        <nav className="md:hidden fixed bottom-0 left-0 right-0 bg-white/95 backdrop-blur border-t border-navy-100 flex justify-around py-2 z-20 dark:bg-[hsl(var(--surface))]/95 dark:border-[hsl(var(--border))]" aria-label="Navigation principale mobile">
          {MOBILE_PRIMARY.map((item) => {
            const active =
              pathname === item.href || pathname.startsWith(item.href + "/");
            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  "flex flex-col items-center gap-1 min-w-[60px] px-2 py-1 text-[10px] font-semibold tracking-wide",
                  active ? "text-navy-900" : "text-slate-500"
                )}
              >
                <item.icon className={cn("w-5 h-5", active && "text-gold-600")} />
                {item.short}
              </Link>
            );
          })}
          <MobileNavSheet groups={STUDENT_GROUPS} />
          {profile.role === "admin" && (
            <Link
              href="/admin"
              className={cn(
                "flex flex-col items-center gap-1 min-w-[60px] px-2 py-1 text-[10px] font-semibold tracking-wide",
                pathname.startsWith("/admin") ? "text-gold-700" : "text-slate-500"
              )}
            >
              <Settings className="w-5 h-5" />
              Admin
            </Link>
          )}
        </nav>
      </main>
    </div>
  );
}
