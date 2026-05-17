"use client";
import { useState, useRef, useEffect } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { cn, initials } from "@/lib/utils";
import {
  LogOut,
  User,
  Crown,
  GraduationCap,
  Repeat,
  ChevronDown,
  Shield,
  BellRing,
  ShieldCheck,
} from "lucide-react";

/**
 * Menu profil déroulant accessible depuis l'avatar du header.
 *
 * - Clic sur l'avatar : ouvre/ferme
 * - Clic en dehors : ferme
 * - Clic sur un lien : ferme
 * - Échap : ferme
 * - Animation : fade + slide + scale (cubic-bezier ease-out-expo)
 * - Conserve la logique des rôles : super_admin voit l'entrée super-admin
 */
export function UserMenu({
  profile,
  variant = "light",
}: {
  profile: { full_name: string | null; email: string; role: string };
  /** light = avatar sombre sur fond clair (header desktop) ; dark = avatar clair (header mobile sombre) */
  variant?: "light" | "dark";
}) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  const router = useRouter();

  // Fermer au clic en dehors + Échap
  useEffect(() => {
    if (!open) return;
    function onPointer(e: MouseEvent) {
      if (ref.current && !ref.current.contains(e.target as Node)) {
        setOpen(false);
      }
    }
    function onKey(e: KeyboardEvent) {
      if (e.key === "Escape") setOpen(false);
    }
    document.addEventListener("mousedown", onPointer);
    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("mousedown", onPointer);
      document.removeEventListener("keydown", onKey);
    };
  }, [open]);

  async function logout() {
    const supabase = createClient();
    await supabase.auth.signOut();
    router.push("/");
    router.refresh();
  }

  const close = () => setOpen(false);

  const roleLabel =
    profile.role === "super_admin"
      ? "Super administrateur"
      : profile.role === "trainer"
      ? "Formateur"
      : profile.role === "admin"
      ? "Administrateur"
      : "Stagiaire";

  return (
    <div ref={ref} className="relative">
      {/* Avatar — bouton déclencheur */}
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        aria-haspopup="menu"
        aria-expanded={open}
        aria-label="Menu profil"
        className={cn(
          "group inline-flex items-center gap-1.5 rounded-full transition-all duration-200",
          "focus:outline-none focus-visible:ring-2 focus-visible:ring-gold-400 focus-visible:ring-offset-2"
        )}
      >
        <span
          className={cn(
            "h-8 w-8 rounded-full flex items-center justify-center font-semibold text-xs ring-2 transition-all",
            variant === "dark"
              ? "bg-white text-navy-900 ring-white/0 group-hover:ring-white/40"
              : "bg-navy-900 text-gold-400 ring-gold-400/0 group-hover:ring-gold-400/40",
            open && (variant === "dark" ? "ring-white/60" : "ring-gold-400/70")
          )}
        >
          {initials(profile.full_name || profile.email)}
        </span>
        <ChevronDown
          className={cn(
            "h-3.5 w-3.5 transition-transform duration-200",
            variant === "dark" ? "text-white/70" : "text-slate-500",
            open && "rotate-180"
          )}
        />
      </button>

      {/* Dropdown */}
      <div
        role="menu"
        aria-hidden={!open}
        className={cn(
          "absolute right-0 top-full mt-2 w-[18rem] origin-top-right rounded-2xl border border-navy-100 bg-white shadow-2xl shadow-navy-950/15 overflow-hidden z-50",
          "transition-[opacity,transform] duration-200 ease-[cubic-bezier(0.16,1,0.3,1)]",
          open
            ? "opacity-100 translate-y-0 scale-100 pointer-events-auto"
            : "opacity-0 -translate-y-1.5 scale-[0.96] pointer-events-none"
        )}
      >
        {/* En-tête profil */}
        <div className="px-4 py-3.5 bg-gradient-to-br from-navy-50 via-white to-brand-50/30 border-b border-navy-100 flex items-center gap-3">
          <div
            className={cn(
              "h-11 w-11 rounded-full flex items-center justify-center font-semibold text-sm shrink-0 shadow-soft",
              profile.role === "super_admin"
                ? "bg-gradient-to-br from-signal-400 via-brand-400 to-brand-600 text-white"
                : "bg-gradient-to-br from-signal-400 to-signal-600 text-night-900"
            )}
          >
            {initials(profile.full_name || profile.email)}
          </div>
          <div className="min-w-0 flex-1">
            <div className="font-semibold text-navy-900 text-sm truncate">
              {profile.full_name || profile.email}
            </div>
            <div className="text-[10px] uppercase tracking-wider font-semibold inline-flex items-center gap-1 mt-0.5">
              {profile.role === "super_admin" ? (
                <>
                  <Crown className="h-2.5 w-2.5 text-signal-500" />
                  <span className="bg-gradient-to-r from-brand-700 to-signal-600 bg-clip-text text-transparent">
                    {roleLabel}
                  </span>
                </>
              ) : profile.role === "trainer" ? (
                <span className="text-emerald-700">{roleLabel}</span>
              ) : (
                <span className="text-brand-700">{roleLabel}</span>
              )}
            </div>
          </div>
        </div>

        {/* Changer d'espace — affiché seulement si l'utilisateur a accès à plusieurs espaces */}
        {(profile.role === "super_admin" ||
          profile.role === "admin" ||
          profile.role === "trainer") && (
          <div className="px-2 pt-2.5 pb-1">
            <div className="text-[10px] font-semibold uppercase tracking-[0.14em] text-slate-400 px-2.5 mb-1 inline-flex items-center gap-1.5">
              <Repeat className="h-3 w-3" />
              Changer d'espace
            </div>
            <div className="space-y-0.5">
              {profile.role === "super_admin" && (
                <Link
                  href="/super-admin"
                  onClick={close}
                  className="flex items-center gap-2.5 px-2.5 py-2 rounded-lg text-sm font-medium text-navy-800 hover:bg-gradient-to-r hover:from-brand-50 hover:to-signal-50 hover:text-brand-900 transition-colors"
                >
                  <Crown className="w-4 h-4 text-signal-500" />
                  Espace super-admin
                </Link>
              )}
              {(profile.role === "admin" || profile.role === "super_admin") && (
                <Link
                  href="/admin"
                  onClick={close}
                  className="flex items-center gap-2.5 px-2.5 py-2 rounded-lg text-sm font-medium text-navy-800 hover:bg-brand-50 hover:text-brand-900 transition-colors"
                >
                  <Shield className="w-4 h-4 text-brand-600" />
                  Espace admin
                </Link>
              )}
              {/* Formateur ouvert à trainer / admin / super_admin */}
              <Link
                href="/formateur"
                onClick={close}
                className="flex items-center gap-2.5 px-2.5 py-2 rounded-lg text-sm font-medium text-navy-800 hover:bg-emerald-50 hover:text-emerald-900 transition-colors"
              >
                <GraduationCap className="w-4 h-4 text-emerald-600" />
                Espace formateur
              </Link>
              <Link
                href="/dashboard"
                onClick={close}
                className="flex items-center gap-2.5 px-2.5 py-2 rounded-lg text-sm font-medium text-navy-800 hover:bg-brand-50 hover:text-brand-900 transition-colors"
              >
                <User className="w-4 h-4 text-brand-600" />
                Espace stagiaire
              </Link>
            </div>
          </div>
        )}

        {/* Compte */}
        <div
          className={cn(
            "px-2 pb-2",
            profile.role === "super_admin" ||
              profile.role === "admin" ||
              profile.role === "trainer"
              ? "pt-1.5 border-t border-navy-100 mt-1"
              : "pt-2.5"
          )}
        >
          {/* Mon profil — staff uniquement (la page /admin/users/me est admin-only) */}
          {(profile.role === "admin" || profile.role === "super_admin") && (
            <Link
              href="/admin/users/me"
              onClick={close}
              className="flex items-center gap-2.5 px-2.5 py-2 rounded-lg text-sm font-medium text-navy-800 hover:bg-navy-50 transition-colors"
            >
              <User className="w-4 h-4 text-slate-500" />
              Mon profil
            </Link>
          )}
          {/* Préférences de notifications — accessible à tous */}
          <Link
            href="/parametres/notifications"
            onClick={close}
            className="flex items-center gap-2.5 px-2.5 py-2 rounded-lg text-sm font-medium text-navy-800 hover:bg-navy-50 transition-colors"
          >
            <BellRing className="w-4 h-4 text-slate-500" />
            Préférences notifications
          </Link>
          {/* Préférences de confidentialité (classement, etc.) */}
          <Link
            href="/parametres/confidentialite"
            onClick={close}
            className="flex items-center gap-2.5 px-2.5 py-2 rounded-lg text-sm font-medium text-navy-800 hover:bg-navy-50 transition-colors"
          >
            <ShieldCheck className="w-4 h-4 text-slate-500" />
            Confidentialité
          </Link>
          <button
            type="button"
            onClick={() => {
              close();
              logout();
            }}
            className="w-full flex items-center gap-2.5 px-2.5 py-2 rounded-lg text-sm font-medium text-rose-600 hover:bg-rose-50 transition-colors"
          >
            <LogOut className="w-4 h-4" />
            Se déconnecter
          </button>
        </div>
      </div>
    </div>
  );
}
