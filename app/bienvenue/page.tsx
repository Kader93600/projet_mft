import Link from "next/link";
import { AcceptInvitationForm } from "./accept-invitation-form";
import { Logo } from "@/components/ui/logo";
import { ShieldCheck, ArrowLeft, Sparkles, GraduationCap } from "lucide-react";
import { LEGAL } from "@/lib/legal-config";

export const dynamic = "force-dynamic";

/**
 * Page d'activation de compte après clic sur un lien d'invitation.
 * Le callback /auth/callback a déjà établi la session (verifyOtp). Ici
 * le stagiaire définit son mot de passe et active son compte.
 */
export default function BienvenuePage() {
  const year = new Date().getFullYear();

  return (
    <div className="min-h-screen grid lg:grid-cols-2 bg-night text-white">
      {/* Panneau visuel */}
      <aside className="relative hidden lg:flex flex-col justify-between p-10 overflow-hidden">
        <div className="absolute inset-0 bg-mesh-night opacity-90" />
        <div
          className="absolute inset-0 bg-grid-night opacity-30"
          style={{
            backgroundSize: "56px 56px",
            maskImage:
              "linear-gradient(to bottom, black 0%, black 60%, transparent 100%)",
          }}
        />
        <div
          aria-hidden
          className="absolute -top-32 -right-32 h-96 w-96 rounded-full bg-signal-500/15 blur-3xl pointer-events-none"
        />
        <div
          aria-hidden
          className="absolute -bottom-32 -left-32 h-96 w-96 rounded-full bg-brand-500/20 blur-3xl pointer-events-none"
        />

        <div className="relative">
          <Logo variant="light" />
        </div>

        <div className="relative space-y-8 max-w-md">
          <span className="inline-flex items-center gap-1.5 rounded-full border border-signal-500/30 bg-signal-500/10 px-3 py-1 text-xs font-medium text-signal-300">
            <Sparkles className="h-3 w-3" />
            Activation de votre compte
          </span>
          <h2 className="font-display text-4xl leading-[1.05] tracking-tight">
            Bienvenue dans votre{" "}
            <span className="italic text-signal-400">espace de formation</span>.
          </h2>
          <p className="text-white/70 text-[15px] leading-relaxed">
            Dernière étape avant d'accéder à vos modules, quiz et examens
            blancs : choisissez un mot de passe sécurisé pour protéger votre
            compte.
          </p>

          <ul className="space-y-3 text-sm">
            {[
              "Vos cours et votre progression au même endroit",
              "Examens blancs et quiz d'entraînement illimités",
              "Suivi personnalisé par votre formateur",
            ].map((item) => (
              <li key={item} className="flex items-start gap-3">
                <span className="mt-0.5 inline-flex h-6 w-6 items-center justify-center rounded-md bg-signal-500/15 border border-signal-500/30 text-signal-400">
                  <GraduationCap className="h-3.5 w-3.5" />
                </span>
                <span className="text-white/85">{item}</span>
              </li>
            ))}
          </ul>
        </div>

        <div className="relative text-xs text-white/45 tracking-wide uppercase">
          © {year} {LEGAL.brand}
        </div>
      </aside>

      {/* Formulaire */}
      <main className="flex items-center justify-center p-6 sm:p-10 bg-ivory text-ink dark:bg-[hsl(var(--bg))] dark:text-[hsl(var(--text))]">
        <div className="w-full max-w-md">
          <div className="lg:hidden mb-8 flex justify-center">
            <Logo />
          </div>

          <div className="mb-8">
            <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-700 dark:text-signal-400">
              Inscription
            </span>
            <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 dark:text-[hsl(var(--text))] tracking-tight">
              Activez votre compte
            </h1>
            <p className="mt-2 text-[15px] text-slate-600 dark:text-[hsl(var(--text-muted))]">
              Définissez votre mot de passe pour finaliser votre inscription.
            </p>
          </div>

          <div className="rounded-2xl border border-navy-100 bg-white p-8 shadow-soft dark:bg-[hsl(var(--surface))] dark:border-[hsl(var(--border))]">
            <AcceptInvitationForm />
          </div>

          <div className="mt-10 pt-6 border-t border-navy-100 dark:border-[hsl(var(--border))] flex flex-wrap justify-center gap-x-4 gap-y-1 text-xs text-slate-500 dark:text-[hsl(var(--text-muted))]">
            <Link href="/mentions-legales" className="hover:text-navy-900 dark:hover:text-[hsl(var(--text))]">
              Mentions légales
            </Link>
            <Link href="/cgu" className="hover:text-navy-900 dark:hover:text-[hsl(var(--text))]">
              CGU
            </Link>
            <Link href="/confidentialite" className="hover:text-navy-900 dark:hover:text-[hsl(var(--text))]">
              Confidentialité
            </Link>
          </div>
        </div>
      </main>
    </div>
  );
}
