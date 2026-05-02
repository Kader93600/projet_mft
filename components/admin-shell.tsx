"use client";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { cn, initials } from "@/lib/utils";
import { ToastProvider } from "@/components/ui/toast";
import { SessionTracker } from "@/components/session-tracker";
import {
  LogOut,
  Shield,
  ArrowLeft,
  ChevronRight,
  LayoutDashboard,
  GraduationCap,
  User,
  Crown,
  Repeat,
} from "lucide-react";
import { NotificationsBell } from "@/components/notifications-bell";
import { SearchPalette } from "@/components/search-palette";
import { ThemeToggle } from "@/components/theme-toggle";
import { SidebarNav } from "@/components/sidebar-nav";
import { MobileNavSheet } from "@/components/mobile-nav-sheet";
import { ADMIN_GROUPS, flattenGroups } from "@/components/nav-groups";
import { LogoMark } from "@/components/ui/logo";

interface Props {
  children: React.ReactNode;
  profile: { full_name: string | null; email: string; role: string };
}

const FLAT = flattenGroups(ADMIN_GROUPS);
const MOBILE_PRIMARY = FLAT.filter((i) =>
  ["/admin", "/admin/users", "/admin/modules", "/admin/quizzes"].includes(i.href)
);

function crumbsFromPath(p: string): { label: string; href: string }[] {
  const parts = p.split("/").filter(Boolean);
  const crumbs: { label: string; href: string }[] = [];
  let acc = "";
  for (const part of parts) {
    acc += "/" + part;
    const item = FLAT.find((n) => n.href === acc);
    crumbs.push({
      label: item?.label ?? decodeURIComponent(part),
      href: acc,
    });
  }
  return crumbs;
}

export function AdminShell({ children, profile }: Props) {
  const pathname = usePathname();
  const router = useRouter();

  async function logout() {
    const supabase = createClient();
    await supabase.auth.signOut();
    router.push("/");
    router.refresh();
  }

  const crumbs = crumbsFromPath(pathname);

  return (
    <ToastProvider>
      <SessionTracker />
      <div className="min-h-screen flex bg-ivory text-ink">
        {/* Sidebar admin */}
        <aside className="hidden md:flex w-72 flex-col border-r border-navy-100 bg-navy-950 text-white">
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

          <SidebarNav groups={ADMIN_GROUPS} variant="dark" />

          {/* Bloc utilisateur consolidé : carte profil + actions claires */}
          <div className="border-t border-white/10 p-3 space-y-3">
            {/* Carte profil */}
            <div className="flex items-center gap-3 px-2 py-2 rounded-xl bg-white/[0.04]">
              <div
                className={cn(
                  "h-10 w-10 rounded-full flex items-center justify-center font-semibold text-sm shrink-0",
                  profile.role === "super_admin"
                    ? "bg-gradient-to-br from-signal-400 via-brand-400 to-brand-600 text-white shadow-glow-signal"
                    : "bg-gradient-to-br from-signal-400 to-signal-600 text-night-900"
                )}
              >
                {initials(profile.full_name || profile.email)}
              </div>
              <div className="flex-1 min-w-0">
                <div className="font-semibold text-white text-sm truncate">
                  {profile.full_name || profile.email}
                </div>
                <div className="text-[10px] uppercase tracking-wider font-semibold inline-flex items-center gap-1">
                  {profile.role === "super_admin" ? (
                    <>
                      <Crown className="h-2.5 w-2.5 text-signal-400" />
                      <span className="bg-gradient-to-r from-signal-300 to-brand-300 bg-clip-text text-transparent">
                        Super administrateur
                      </span>
                    </>
                  ) : (
                    <span className="text-signal-300">Administrateur</span>
                  )}
                </div>
              </div>
            </div>

            {/* Changer d'espace — section dédiée et claire */}
            <div>
              <div className="text-[10px] font-semibold uppercase tracking-[0.14em] text-white/40 px-2 mb-1.5 inline-flex items-center gap-1.5">
                <Repeat className="h-3 w-3" />
                Changer d'espace
              </div>
              <div className="space-y-0.5">
                {profile.role === "super_admin" && (
                  <Link
                    href="/super-admin"
                    className="flex items-center gap-3 px-3 py-2 rounded-lg text-xs font-medium text-white/80 hover:bg-gradient-to-r hover:from-brand-600/20 hover:to-signal-500/20 hover:text-white transition border border-transparent hover:border-signal-500/30"
                  >
                    <Crown className="w-3.5 h-3.5 text-signal-400" />
                    Espace super-admin
                  </Link>
                )}
                <Link
                  href="/formateur"
                  className="flex items-center gap-3 px-3 py-2 rounded-lg text-xs font-medium text-white/70 hover:bg-white/5 hover:text-white transition"
                >
                  <GraduationCap className="w-3.5 h-3.5" />
                  Espace formateur
                </Link>
                <Link
                  href="/dashboard"
                  className="flex items-center gap-3 px-3 py-2 rounded-lg text-xs font-medium text-white/70 hover:bg-white/5 hover:text-white transition"
                >
                  <User className="w-3.5 h-3.5" />
                  Espace stagiaire
                </Link>
              </div>
            </div>

            {/* Actions compte — séparées visuellement */}
            <div className="border-t border-white/10 pt-3 space-y-0.5">
              <Link
                href="/admin/users/me"
                className="flex items-center gap-3 px-3 py-2 rounded-lg text-xs font-medium text-white/70 hover:bg-white/5 hover:text-white transition"
              >
                <User className="w-3.5 h-3.5" />
                Mon profil
              </Link>
              <button
                onClick={logout}
                className="w-full flex items-center gap-3 px-3 py-2 rounded-lg text-xs font-medium text-rose-300 hover:bg-rose-500/10 hover:text-rose-100 transition"
              >
                <LogOut className="w-3.5 h-3.5" />
                Se déconnecter
              </button>
            </div>
          </div>
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
          <button
            onClick={logout}
            className="h-9 w-9 rounded-lg hover:bg-white/10 flex items-center justify-center"
          >
            <LogOut className="h-4 w-4" />
          </button>
        </div>

        {/* Main */}
        <main className="flex-1 pt-14 md:pt-0 pb-20 md:pb-0">
          <div className="hidden md:flex h-16 items-center justify-between px-8 border-b border-navy-100 bg-white sticky top-0 z-10">
            <nav className="flex items-center gap-1.5 text-sm">
              {crumbs.map((c, i) => (
                <span key={c.href} className="flex items-center gap-1.5">
                  {i > 0 && <ChevronRight className="h-3.5 w-3.5 text-slate-300" />}
                  {i === crumbs.length - 1 ? (
                    <span className="font-semibold text-navy-900">{c.label}</span>
                  ) : (
                    <Link
                      href={c.href}
                      className="text-slate-500 hover:text-navy-900"
                    >
                      {c.label}
                    </Link>
                  )}
                </span>
              ))}
            </nav>
            <div className="flex items-center gap-3">
              <div className="hidden lg:block">
                <SearchPalette />
              </div>
              <ThemeToggle />
              <NotificationsBell />
              {profile.role === "super_admin" ? (
                <span className="px-2.5 py-1 rounded-lg bg-gradient-to-r from-brand-600/15 to-signal-500/20 text-brand-900 text-[11px] font-semibold uppercase tracking-wide border border-signal-500/40 inline-flex items-center gap-1.5">
                  <span className="h-1.5 w-1.5 rounded-full bg-signal-500 animate-glow-pulse" />
                  Super-admin
                </span>
              ) : (
                <span className="px-2.5 py-1 rounded-lg bg-brand-100 text-brand-800 text-[11px] font-semibold uppercase tracking-wide border border-brand-200">
                  Mode admin
                </span>
              )}
              <div className="h-8 w-8 rounded-full bg-navy-900 text-gold-400 flex items-center justify-center font-semibold text-xs">
                {initials(profile.full_name || profile.email)}
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

          <nav className="md:hidden fixed bottom-0 left-0 right-0 bg-white/95 backdrop-blur border-t border-navy-100 flex justify-around py-2 z-20">
            {MOBILE_PRIMARY.map((item) => {
              const active = item.exact
                ? pathname === item.href
                : pathname.startsWith(item.href);
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className={cn(
                    "flex flex-col items-center gap-1 px-2 py-1 text-[10px] font-semibold tracking-wide",
                    active ? "text-navy-900" : "text-slate-500"
                  )}
                >
                  <item.icon className={cn("w-5 h-5", active && "text-gold-600")} />
                  <span className="truncate max-w-[60px]">
                    {item.label.split(" ")[0]}
                  </span>
                </Link>
              );
            })}
            <MobileNavSheet groups={ADMIN_GROUPS} />
          </nav>
        </main>
      </div>
    </ToastProvider>
  );
}
