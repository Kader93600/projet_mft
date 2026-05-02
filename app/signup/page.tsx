import Link from "next/link";
import { Logo } from "@/components/ui/logo";
import { ArrowLeft, Phone, Mail, ShieldCheck, ArrowRight } from "lucide-react";
import { LEGAL } from "@/lib/legal-config";

export const metadata = {
  title: "Inscription — contactez-nous",
  description:
    "Les comptes stagiaires sont créés par notre équipe pédagogique après confirmation de votre dossier d'inscription.",
};

/**
 * /signup est désactivé : les inscriptions passent désormais par l'école
 * (création de compte par admin / super-admin uniquement). Cette page
 * informe les visiteurs et les redirige vers /contact.
 */
export default function SignupClosedPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-ivory px-6 py-16">
      <div className="max-w-xl w-full">
        <Link
          href="/"
          className="inline-flex items-center gap-2 text-sm text-slate-500 hover:text-navy-900 transition mb-8"
        >
          <ArrowLeft className="h-4 w-4" /> Retour au site
        </Link>

        <div
          className="rounded-3xl bg-white border border-navy-100 p-8 md:p-10 shadow-soft"
          style={{ animation: "fade-up 0.6s ease-out both" }}
        >
          <div className="flex items-center gap-3 mb-6">
            <Logo size="sm" />
          </div>

          <div
            className="h-12 w-12 rounded-2xl bg-brand-50 text-brand-700 flex items-center justify-center"
            style={{
              animation:
                "fade-up 0.6s cubic-bezier(0.34, 1.56, 0.64, 1) 0.1s both",
            }}
          >
            <ShieldCheck className="h-6 w-6" />
          </div>

          <h1
            className="mt-5 font-display text-2xl md:text-3xl font-semibold text-navy-950 tracking-tight"
            style={{ animation: "fade-up 0.5s ease-out 0.15s both" }}
          >
            Inscription accompagnée
          </h1>

          <p
            className="mt-3 text-slate-600 leading-relaxed"
            style={{ animation: "fade-up 0.5s ease-out 0.25s both" }}
          >
            Pour garantir un accompagnement personnalisé et un dossier de
            financement adapté à votre situation,{" "}
            <strong className="text-navy-900">
              les inscriptions sont gérées par notre équipe pédagogique
            </strong>
            .
          </p>

          <p
            className="mt-3 text-slate-600 leading-relaxed"
            style={{ animation: "fade-up 0.5s ease-out 0.32s both" }}
          >
            Contactez-nous, nous étudions votre projet et créons votre accès
            sous <strong>48 h ouvrées</strong>.
          </p>

          <div
            className="mt-8 grid sm:grid-cols-2 gap-3"
            style={{ animation: "fade-up 0.5s ease-out 0.4s both" }}
          >
            <Link
              href="/contact"
              className="group rounded-2xl bg-navy-900 text-white p-5 hover:bg-navy-800 transition flex items-start gap-3"
            >
              <Mail className="h-5 w-5 shrink-0 mt-0.5" />
              <div className="flex-1 min-w-0">
                <div className="font-semibold">Formulaire de contact</div>
                <div className="text-xs text-white/60 mt-0.5">
                  Réponse sous 48 h ouvrées
                </div>
              </div>
              <ArrowRight className="h-4 w-4 mt-0.5 shrink-0 transition-transform group-hover:translate-x-0.5" />
            </Link>
            <a
              href={`mailto:${LEGAL.email}`}
              className="group rounded-2xl bg-white border border-navy-100 p-5 hover:border-brand-300 hover:shadow-soft transition flex items-start gap-3"
            >
              <Mail className="h-5 w-5 text-brand-700 shrink-0 mt-0.5" />
              <div className="flex-1 min-w-0">
                <div className="font-semibold text-navy-900">Email direct</div>
                <div className="text-xs text-slate-500 mt-0.5 truncate">
                  {LEGAL.email}
                </div>
              </div>
            </a>
          </div>

          <div
            className="mt-8 pt-6 border-t border-navy-50 text-center text-sm text-slate-600"
            style={{ animation: "fade-up 0.5s ease-out 0.5s both" }}
          >
            Vous avez déjà un compte ?{" "}
            <Link
              href="/login"
              className="font-semibold text-brand-700 hover:text-brand-900 underline-offset-4 hover:underline"
            >
              Se connecter
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
