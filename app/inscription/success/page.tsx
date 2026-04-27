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
          <div className="mx-auto h-14 w-14 rounded-2xl bg-emerald-50 text-emerald-700 flex items-center justify-center">
            <CheckCircle2 className="h-7 w-7" />
          </div>
          <span className="block mt-6 text-[11px] font-semibold uppercase tracking-[0.18em] text-gold-700">
            Paiement confirmé
          </span>
          <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
            Bienvenue à bord !
          </h1>
          <p className="mt-3 text-slate-600">
            Votre paiement est validé. Vous allez recevoir d'ici quelques
            minutes votre <strong>convention de formation</strong>, votre{" "}
            <strong>convocation officielle</strong> et vos{" "}
            <strong>identifiants de connexion</strong>.
          </p>
          <div className="mt-8 flex flex-col items-center gap-3">
            <Link
              href="/login"
              className="inline-flex items-center gap-2 px-5 py-3 rounded-xl bg-navy-900 text-white text-sm font-semibold hover:bg-navy-800"
            >
              Accéder à la plateforme <ArrowRight className="h-4 w-4" />
            </Link>
            <a
              href={`mailto:${LEGAL.email}`}
              className="inline-flex items-center gap-2 text-sm text-slate-500 hover:text-navy-900"
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
