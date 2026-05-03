import Link from "next/link";
import { ForgotPasswordForm } from "./forgot-form";
import { Logo } from "@/components/ui/logo";
import { ShieldCheck, ArrowLeft, KeyRound, Clock, Mail } from "lucide-react";
import { LEGAL } from "@/lib/legal-config";

export const dynamic = "force-dynamic";

export default function ForgotPasswordPage() {
  return (
    <div className="min-h-screen grid lg:grid-cols-2 bg-night text-white">
      {/* Left — Visual panel */}
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
          <Link
            href="/login"
            className="inline-flex items-center gap-2 text-sm text-white/70 hover:text-white transition"
          >
            <ArrowLeft className="h-4 w-4" />
            Retour à la connexion
          </Link>
        </div>

        <div className="relative space-y-8 max-w-md">
          <span className="inline-flex items-center gap-1.5 rounded-full border border-signal-500/30 bg-signal-500/10 px-3 py-1 text-xs font-medium text-signal-300">
            <KeyRound className="h-3 w-3" />
            Mot de passe oublié
          </span>
          <h2 className="font-display text-4xl leading-[1.05] tracking-tight">
            On vous renvoie{" "}
            <span className="italic text-signal-400">un lien</span>.
          </h2>
          <p className="text-white/70 text-[15px] leading-relaxed">
            Saisissez l'adresse email de votre compte stagiaire. Si elle est
            connue, vous recevrez sous une minute un lien sécurisé pour
            définir un nouveau mot de passe.
          </p>

          <ul className="space-y-3 text-sm">
            <li className="flex items-start gap-3">
              <span className="mt-0.5 inline-flex h-6 w-6 items-center justify-center rounded-md bg-signal-500/15 border border-signal-500/30 text-signal-400">
                <Mail className="h-3.5 w-3.5" />
              </span>
              <span className="text-white/85">
                Vérifiez votre boîte de réception et le dossier spam
              </span>
            </li>
            <li className="flex items-start gap-3">
              <span className="mt-0.5 inline-flex h-6 w-6 items-center justify-center rounded-md bg-signal-500/15 border border-signal-500/30 text-signal-400">
                <Clock className="h-3.5 w-3.5" />
              </span>
              <span className="text-white/85">
                Le lien est valable 1 heure, à usage unique
              </span>
            </li>
            <li className="flex items-start gap-3">
              <span className="mt-0.5 inline-flex h-6 w-6 items-center justify-center rounded-md bg-signal-500/15 border border-signal-500/30 text-signal-400">
                <ShieldCheck className="h-3.5 w-3.5" />
              </span>
              <span className="text-white/85">
                Aucune autre information n'est demandée pour la sécurité
              </span>
            </li>
          </ul>
        </div>

        <div className="relative text-xs text-white/45 tracking-wide uppercase">
          © {new Date().getFullYear()} {LEGAL.brand}
        </div>
      </aside>

      {/* Right — Form */}
      <main className="flex items-center justify-center p-6 sm:p-10 bg-ivory text-ink">
        <div className="w-full max-w-md">
          <div className="lg:hidden mb-8 flex justify-center">
            <Logo />
          </div>

          <div className="mb-8">
            <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-700">
              Récupération de compte
            </span>
            <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
              Mot de passe oublié.
            </h1>
            <p className="mt-2 text-[15px] text-slate-600">
              Entrez votre adresse email, nous vous envoyons un lien sécurisé.
            </p>
          </div>

          <div className="rounded-2xl border border-navy-100 bg-white p-8 shadow-soft">
            <ForgotPasswordForm />
          </div>

          <p className="mt-6 text-center text-sm text-slate-600">
            Vous vous souvenez de votre mot de passe ?{" "}
            <Link
              href="/login"
              className="font-semibold text-brand-700 hover:text-brand-900 underline-offset-4 hover:underline"
            >
              Se connecter
            </Link>
          </p>

          <div className="mt-10 pt-6 border-t border-navy-100 flex flex-wrap justify-center gap-x-4 gap-y-1 text-xs text-slate-500">
            <Link href="/mentions-legales" className="hover:text-navy-900">
              Mentions légales
            </Link>
            <Link href="/cgu" className="hover:text-navy-900">
              CGU
            </Link>
            <Link href="/confidentialite" className="hover:text-navy-900">
              Confidentialité
            </Link>
          </div>
        </div>
      </main>
    </div>
  );
}
