import { Suspense } from "react";
import Link from "next/link";
import { Logo } from "@/components/ui/logo";
import { Loader2, ShieldCheck, Sparkles } from "lucide-react";
import { LEGAL } from "@/lib/legal-config";
import { ActivateClient } from "./activate-client";

export const dynamic = "force-dynamic";

/**
 * Étape de vérification du lien d'invitation — pensée ANTI-PREFETCH.
 *
 * Les scanners de liens (Outlook « Safe Links », antivirus, aperçus de
 * messagerie) font un simple GET sans exécuter le JavaScript. La
 * vérification du jeton (verifyOtp) se fait donc UNIQUEMENT côté client,
 * au montage du composant, ce qui empêche un scanner de « consommer » le
 * lien à usage unique avant le vrai clic de l'utilisateur.
 *
 * L'email d'invitation doit pointer ici avec :
 *   /activer?token_hash={{ .TokenHash }}&type=invite&next=/bienvenue
 */
export default function ActiverPage() {
  const year = new Date().getFullYear();

  return (
    <div className="min-h-screen grid lg:grid-cols-2 bg-night text-white">
      <aside className="relative hidden lg:flex flex-col justify-between p-10 overflow-hidden">
        <div className="absolute inset-0 bg-mesh-night opacity-90" />
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
        <div className="relative space-y-6 max-w-md">
          <span className="inline-flex items-center gap-1.5 rounded-full border border-signal-500/30 bg-signal-500/10 px-3 py-1 text-xs font-medium text-signal-300">
            <Sparkles className="h-3 w-3" />
            Activation sécurisée
          </span>
          <h2 className="font-display text-4xl leading-[1.05] tracking-tight">
            Vérification de votre{" "}
            <span className="italic text-signal-400">invitation</span>.
          </h2>
          <p className="text-white/70 text-[15px] leading-relaxed">
            Nous validons votre lien en toute sécurité. Vous allez pouvoir
            choisir votre mot de passe dans un instant.
          </p>
          <ul className="space-y-3 text-sm">
            <li className="flex items-start gap-3">
              <span className="mt-0.5 inline-flex h-6 w-6 items-center justify-center rounded-md bg-signal-500/15 border border-signal-500/30 text-signal-400">
                <ShieldCheck className="h-3.5 w-3.5" />
              </span>
              <span className="text-white/85">
                Lien chiffré, valable une seule fois
              </span>
            </li>
          </ul>
        </div>
        <div className="relative text-xs text-white/45 tracking-wide uppercase">
          © {year} {LEGAL.brand}
        </div>
      </aside>

      <main className="flex items-center justify-center p-6 sm:p-10 bg-ivory text-ink dark:bg-[hsl(var(--bg))] dark:text-[hsl(var(--text))]">
        <div className="w-full max-w-md">
          <div className="lg:hidden mb-8 flex justify-center">
            <Logo />
          </div>
          <div className="rounded-2xl border border-navy-100 bg-white p-8 shadow-soft dark:bg-[hsl(var(--surface))] dark:border-[hsl(var(--border))]">
            <Suspense
              fallback={
                <div className="flex flex-col items-center gap-3 py-10 text-slate-600">
                  <Loader2 className="h-6 w-6 animate-spin text-brand-600" />
                  <span className="text-sm">Chargement…</span>
                </div>
              }
            >
              <ActivateClient />
            </Suspense>
          </div>

          <div className="mt-8 flex justify-center">
            <Link
              href="/login"
              className="text-xs text-slate-500 dark:text-[hsl(var(--text-muted))] hover:text-navy-900 dark:hover:text-[hsl(var(--text))] transition-colors"
            >
              Retour à la connexion
            </Link>
          </div>
        </div>
      </main>
    </div>
  );
}
