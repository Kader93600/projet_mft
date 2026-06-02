import Link from "next/link";
import { Logo } from "@/components/ui/logo";
import { Clock, ArrowLeft } from "lucide-react";
import { LEGAL } from "@/lib/legal-config";
import { ResendInvitationForm } from "./resend-form";

export const dynamic = "force-dynamic";

export default function InvitationExpireePage({
  searchParams,
}: {
  searchParams?: { reason?: string };
}) {
  const year = new Date().getFullYear();

  return (
    <div className="min-h-screen grid lg:grid-cols-2 bg-night text-white">
      <aside className="relative hidden lg:flex flex-col justify-between p-10 overflow-hidden">
        <div className="absolute inset-0 bg-mesh-night opacity-90" />
        <div
          aria-hidden
          className="absolute -top-32 -right-32 h-96 w-96 rounded-full bg-amber-500/15 blur-3xl pointer-events-none"
        />
        <div
          aria-hidden
          className="absolute -bottom-32 -left-32 h-96 w-96 rounded-full bg-brand-500/20 blur-3xl pointer-events-none"
        />
        <div className="relative">
          <Logo variant="light" />
        </div>
        <div className="relative space-y-6 max-w-md">
          <span className="inline-flex items-center gap-1.5 rounded-full border border-amber-500/30 bg-amber-500/10 px-3 py-1 text-xs font-medium text-amber-300">
            <Clock className="h-3 w-3" />
            Lien expiré
          </span>
          <h2 className="font-display text-4xl leading-[1.05] tracking-tight">
            Ce lien n'est plus{" "}
            <span className="italic text-amber-300">valide</span>.
          </h2>
          <p className="text-white/70 text-[15px] leading-relaxed">
            Pour votre sécurité, les liens d'invitation expirent après un
            délai limité et ne peuvent servir qu'une seule fois. Demandez un
            nouveau lien ci-contre, nous vous l'envoyons aussitôt.
          </p>
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

          <div className="mb-8">
            <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-amber-700 dark:text-amber-400">
              Invitation
            </span>
            <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 dark:text-[hsl(var(--text))] tracking-tight">
              Lien expiré ou déjà utilisé
            </h1>
            <p className="mt-2 text-[15px] text-slate-600 dark:text-[hsl(var(--text-muted))]">
              Saisissez votre adresse email pour recevoir une nouvelle
              invitation.
            </p>
          </div>

          <div className="rounded-2xl border border-navy-100 bg-white p-8 shadow-soft dark:bg-[hsl(var(--surface))] dark:border-[hsl(var(--border))]">
            <ResendInvitationForm />
          </div>

          <Link
            href="/login"
            className="mt-6 inline-flex items-center gap-1.5 text-sm text-slate-500 dark:text-[hsl(var(--text-muted))] hover:text-navy-900 dark:hover:text-[hsl(var(--text))] transition-colors"
          >
            <ArrowLeft className="h-4 w-4" />
            Retour à la connexion
          </Link>
        </div>
      </main>
    </div>
  );
}
