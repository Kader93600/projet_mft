import Link from "next/link";
import { CheckCircle2, Mail, ArrowRight } from "lucide-react";
import { LegalFooter } from "@/components/legal/legal-footer";
import { LEGAL } from "@/lib/legal-config";

export const dynamic = "force-dynamic";

export const metadata = {
  title: `Paiement confirmé — ${LEGAL.brand}`,
};

export default function CheckoutSuccessPage() {
  return (
    <div className="min-h-screen bg-ivory flex flex-col">
      <main className="flex-1 flex items-center justify-center px-6 py-16">
        <div className="max-w-md text-center">
          <div
            className="mx-auto h-16 w-16 rounded-3xl bg-emerald-50 text-emerald-700 flex items-center justify-center shadow-soft"
            style={{
              animation:
                "fade-up 0.7s cubic-bezier(0.34, 1.56, 0.64, 1) both",
            }}
          >
            <CheckCircle2 className="h-8 w-8" />
          </div>
          <span
            className="block mt-6 text-[11px] font-semibold uppercase tracking-[0.18em] text-emerald-700"
            style={{ animation: "fade-up 0.5s ease-out 0.15s both" }}
          >
            Paiement confirmé
          </span>
          <h1
            className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight"
            style={{ animation: "fade-up 0.6s ease-out 0.25s both" }}
          >
            C'est validé.{" "}
            <span className="block sm:inline">Bienvenue à bord.</span>
          </h1>
          <p
            className="mt-4 text-slate-600 leading-relaxed"
            style={{ animation: "fade-up 0.5s ease-out 0.35s both" }}
          >
            Vous recevez d'ici quelques minutes par email&nbsp;:
          </p>
          <ul
            className="mt-3 space-y-2 text-sm text-slate-700 inline-block text-left"
            style={{ animation: "fade-up 0.5s ease-out 0.4s both" }}
          >
            <li className="flex items-start gap-2.5">
              <CheckCircle2 className="h-4 w-4 text-emerald-600 mt-0.5 shrink-0" />
              <span>Votre <strong>convention de formation</strong> signée</span>
            </li>
            <li className="flex items-start gap-2.5">
              <CheckCircle2 className="h-4 w-4 text-emerald-600 mt-0.5 shrink-0" />
              <span>Votre <strong>convocation officielle</strong></span>
            </li>
            <li className="flex items-start gap-2.5">
              <CheckCircle2 className="h-4 w-4 text-emerald-600 mt-0.5 shrink-0" />
              <span>Vos <strong>identifiants de connexion</strong></span>
            </li>
          </ul>
          <div
            className="mt-8 flex flex-col items-center gap-3"
            style={{ animation: "fade-up 0.5s ease-out 0.5s both" }}
          >
            <Link
              href="/login"
              className="inline-flex items-center gap-2 px-6 py-3 rounded-xl bg-navy-900 text-white text-sm font-semibold hover:bg-navy-800 hover:-translate-y-0.5 transition motion-reduce:hover:translate-y-0"
            >
              Accéder à la plateforme <ArrowRight className="h-4 w-4" />
            </Link>
            <p className="text-xs text-slate-500 mt-1">
              Une question&nbsp;? Notre équipe répond sous 24&nbsp;h ouvrées.
            </p>
            <a
              href={`mailto:${LEGAL.email}`}
              className="inline-flex items-center gap-2 text-sm text-slate-500 hover:text-navy-900 transition"
            >
              <Mail className="h-4 w-4" /> {LEGAL.email}
            </a>
          </div>
        </div>
      </main>
      <LegalFooter variant="dark" />
    </div>
  );
}
