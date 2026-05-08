import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Logo } from "@/components/ui/logo";
import { initials } from "@/lib/utils";
import { LogoutButton } from "./logout-button";
import {
  LayoutDashboard,
  ShieldCheck,
  UserCog,
  Activity,
  Settings,
  ArrowLeft,
  Crown,
  GraduationCap,
} from "lucide-react";

export default async function SuperAdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: profile } = await supabase
    .from("profiles")
    .select("full_name, email, role")
    .eq("id", user.id)
    .single();

  if (profile?.role !== "super_admin") redirect("/dashboard");

  return (
    <div className="min-h-screen bg-ivory text-ink flex">
      {/* Sidebar — gradient brand → signal pour signaler le pouvoir */}
      <aside className="hidden md:flex w-72 flex-col border-r border-white/10 relative overflow-hidden">
        <div
          aria-hidden="true"
          className="absolute inset-0 bg-gradient-to-b from-brand-950 via-night to-night-200"
        />
        <div
          aria-hidden="true"
          className="absolute inset-0 opacity-30"
          style={{
            background:
              "radial-gradient(ellipse at 0% 0%, rgba(159,226,32,0.12) 0%, transparent 50%), radial-gradient(ellipse at 100% 100%, rgba(37,48,217,0.20) 0%, transparent 50%)",
          }}
        />

        <div className="relative h-16 flex items-center px-5 border-b border-white/10">
          <Link
            href="/super-admin"
            className="flex items-center gap-2.5 text-white"
          >
            <div className="h-8 w-8 rounded-lg bg-gradient-to-br from-signal-400 to-signal-500 flex items-center justify-center">
              <Crown className="h-4 w-4 text-night" />
            </div>
            <div>
              <div className="font-display font-semibold text-sm leading-tight">
                MA FORMATION
              </div>
              <div className="text-[10px] text-signal-300 uppercase tracking-[0.18em] font-bold">
                Super Admin
              </div>
            </div>
          </Link>
        </div>

        <nav className="relative flex-1 px-3 py-5 space-y-1 overflow-y-auto">
          <div className="text-[10px] font-semibold uppercase tracking-[0.14em] text-white/45 px-3 mb-2">
            Pilotage régalien
          </div>
          <NavLink href="/super-admin" icon={LayoutDashboard} label="Vue d'ensemble" />
          <NavLink href="/super-admin/roles" icon={UserCog} label="Gestion des rôles" />
          <NavLink href="/super-admin/permissions" icon={ShieldCheck} label="Permissions" />
          <NavLink href="/super-admin/audit" icon={Activity} label="Journal d'audit" />
          <NavLink href="/super-admin/settings" icon={Settings} label="Configuration" />

          <div className="text-[10px] font-semibold uppercase tracking-[0.14em] text-white/45 px-3 mt-5 mb-2">
            Pilotage admin (raccourcis)
          </div>
          <NavLink href="/admin" icon={LayoutDashboard} label="Tableau admin" />
          <NavLink href="/admin/users" icon={UserCog} label="Utilisateurs" />
          <NavLink href="/admin/formations" icon={ShieldCheck} label="Catalogue formations" />
          <NavLink href="/admin/modules" icon={Settings} label="Cours & leçons" />
          <NavLink href="/admin/quizzes" icon={Activity} label="Exercices & examens" />
          <NavLink href="/admin/enrollments" icon={Settings} label="Inscriptions" />
          <NavLink href="/admin/announcements" icon={Activity} label="Annonces" />
        </nav>

        <div className="relative px-3 pb-2 border-t border-white/10 pt-3 space-y-1">
          <div className="text-[10px] font-semibold uppercase tracking-[0.14em] text-white/45 px-3 mb-1">
            Naviguer entre les espaces
          </div>
          <Link
            href="/admin"
            className="flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium text-white/65 hover:bg-white/5 hover:text-white transition"
          >
            <ArrowLeft className="w-4 h-4" /> Espace admin
          </Link>
          <Link
            href="/formateur"
            className="flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium text-white/65 hover:bg-white/5 hover:text-white transition"
          >
            <GraduationCap className="w-4 h-4" /> Espace formateur
          </Link>
          <Link
            href="/dashboard"
            className="flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium text-white/65 hover:bg-white/5 hover:text-white transition"
          >
            <ArrowLeft className="w-4 h-4" /> Espace stagiaire
          </Link>
          <LogoutButton />
        </div>

        <div className="relative border-t border-white/10 p-3">
          <div className="flex items-center gap-3 px-2 py-2">
            <div className="h-9 w-9 rounded-full bg-gradient-to-br from-signal-400 via-brand-400 to-brand-600 text-white flex items-center justify-center font-semibold text-sm shadow-glow-signal">
              {initials(profile?.full_name ?? user.email ?? "?")}
            </div>
            <div className="flex-1 min-w-0">
              <div className="font-semibold text-white text-sm truncate">
                {profile?.full_name ?? user.email}
              </div>
              <div className="text-[10px] uppercase tracking-wider font-semibold inline-flex items-center gap-1">
                <Crown className="h-2.5 w-2.5 text-signal-400" />
                <span className="bg-gradient-to-r from-signal-300 to-brand-300 bg-clip-text text-transparent">
                  Super administrateur
                </span>
              </div>
            </div>
          </div>
        </div>
      </aside>

      {/* Mobile top bar */}
      <div className="md:hidden fixed top-0 left-0 right-0 h-14 bg-night text-white border-b border-white/10 z-20 flex items-center justify-between px-4">
        <Link href="/super-admin" className="flex items-center gap-2">
          <Crown className="h-5 w-5 text-signal-400" />
          <span className="font-semibold text-sm">Super-admin</span>
        </Link>
      </div>

      <main className="flex-1 pt-14 md:pt-0">
        <div className="hidden md:flex h-16 items-center justify-between px-8 border-b border-navy-100 bg-white/80 backdrop-blur sticky top-0 z-10">
          <span className="inline-flex items-center gap-1.5 rounded-lg bg-gradient-to-r from-brand-600/15 to-signal-500/20 border border-signal-500/40 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wide text-brand-900">
            <Crown className="h-3.5 w-3.5 text-signal-600" />
            Mode super-admin
          </span>
        </div>

        <div className="max-w-7xl mx-auto px-4 md:px-8 py-6 md:py-10">
          {children}
        </div>
      </main>
    </div>
  );
}

function NavLink({
  href,
  icon: Icon,
  label,
}: {
  href: string;
  icon: any;
  label: string;
}) {
  return (
    <Link
      href={href}
      className="flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium text-white/70 hover:bg-white/5 hover:text-white transition"
    >
      <Icon className="w-4 h-4" />
      {label}
    </Link>
  );
}
