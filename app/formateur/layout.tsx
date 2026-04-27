import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Logo } from "@/components/ui/logo";
import { initials } from "@/lib/utils";
import {
  LayoutDashboard,
  Users,
  GraduationCap,
  MessageCircle,
  ArrowLeft,
  Award,
  ClipboardCheck,
} from "lucide-react";

export default async function FormateurLayout({
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

  if (
    profile?.role !== "trainer" &&
    profile?.role !== "admin" &&
    profile?.role !== "super_admin"
  ) {
    redirect("/dashboard");
  }

  return (
    <div className="min-h-screen bg-ivory text-ink flex">
      <aside className="hidden md:flex w-72 flex-col border-r border-navy-100 bg-white">
        <div className="h-16 flex items-center px-5 border-b border-navy-100">
          <Link href="/formateur">
            <Logo />
          </Link>
        </div>

        <nav className="flex-1 px-3 py-5 space-y-1">
          <div className="text-[10px] font-semibold uppercase tracking-[0.14em] text-slate-400 px-3 mb-2">
            Espace formateur
          </div>
          <NavLink
            href="/formateur"
            icon={LayoutDashboard}
            label="Tableau de bord"
          />
          <NavLink
            href="/formateur/stagiaires"
            icon={Users}
            label="Mes stagiaires"
          />
          <NavLink
            href="/formateur/corrections"
            icon={ClipboardCheck}
            label="Copies à corriger"
          />
          <NavLink
            href="/formateur/sessions"
            icon={GraduationCap}
            label="Sessions live"
          />
          <NavLink
            href="/formateur/messages"
            icon={MessageCircle}
            label="Messages"
          />
        </nav>

        <div className="border-t border-navy-100 p-3">
          <div className="flex items-center gap-3 px-2 py-2">
            <div className="h-9 w-9 rounded-full bg-gradient-to-br from-brand-500 to-brand-700 text-white flex items-center justify-center font-semibold text-sm">
              {initials(profile?.full_name ?? user.email ?? "??")}
            </div>
            <div className="flex-1 min-w-0">
              <div className="font-semibold text-navy-900 text-sm truncate">
                {profile?.full_name ?? user.email}
              </div>
              <div className="text-[11px] uppercase tracking-wider text-brand-700 font-semibold mt-0.5">
                Formateur
              </div>
            </div>
          </div>
          <Link
            href="/dashboard"
            className="mt-2 flex items-center gap-2 px-3 py-2 rounded-xl text-sm text-slate-600 hover:bg-brand-50 hover:text-brand-900 transition"
          >
            <ArrowLeft className="h-4 w-4" /> Retour mode stagiaire
          </Link>
        </div>
      </aside>

      {/* Mobile top bar */}
      <div className="md:hidden fixed top-0 left-0 right-0 h-14 bg-white border-b border-navy-100 z-20 flex items-center justify-between px-4">
        <Link href="/formateur">
          <Logo withText={false} />
        </Link>
        <span className="inline-flex items-center gap-1.5 rounded-md bg-brand-600/15 border border-brand-600/30 px-2 py-0.5 text-[10px] font-semibold uppercase tracking-[0.16em] text-brand-700">
          <Award className="h-3 w-3" />
          Formateur
        </span>
      </div>

      <main className="flex-1 pt-14 md:pt-0">
        {/* Topbar desktop */}
        <div className="hidden md:flex h-16 items-center justify-between px-8 border-b border-navy-100 bg-white/80 backdrop-blur sticky top-0 z-10">
          <span className="inline-flex items-center gap-1.5 rounded-md bg-brand-600/15 border border-brand-600/30 px-2 py-0.5 text-[10px] font-semibold uppercase tracking-[0.16em] text-brand-700">
            <Award className="h-3 w-3" />
            Formateur
          </span>
        </div>

        <div className="px-4 md:px-8 py-6 md:py-10 max-w-7xl mx-auto w-full">
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
      className="flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium text-slate-600 hover:bg-brand-50 hover:text-brand-900 transition"
    >
      <Icon className="w-4 h-4" />
      {label}
    </Link>
  );
}
