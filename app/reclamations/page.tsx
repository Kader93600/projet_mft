import type { Metadata } from "next";
import { SiteShell, PageHero } from "@/components/site/site-shell";
import { LEGAL } from "@/lib/legal-config";
import { Phone, Mail, Scale, Accessibility, ShieldCheck } from "lucide-react";

export const metadata: Metadata = {
  title: "Réclamations & médiation",
  alternates: { canonical: "/reclamations" },
  description:
    "Comment nous faire part d'un différend ou d'une réclamation : interlocuteurs, délais de réponse et voies de médiation.",
};

const STEPS = [
  {
    n: "1",
    title: "Échange direct avec votre interlocuteur",
    body: "La plupart des situations se résolvent par le dialogue. Contactez d'abord votre formateur référent ou notre équipe pédagogique, par téléphone ou par e-mail. Cette première étape est souvent la plus rapide.",
  },
  {
    n: "2",
    title: "Réclamation écrite formelle",
    body: "Si l'échange n'a pas suffi, adressez une réclamation écrite à notre service. Précisez vos coordonnées, la formation concernée et l'objet de votre demande. Nous accusons réception sous 8 jours ouvrés et apportons une réponse motivée sous 15 jours ouvrés.",
  },
  {
    n: "3",
    title: "Médiation de la consommation",
    body: "En cas de désaccord persistant et si vous êtes un particulier, vous pouvez saisir gratuitement le médiateur de la consommation dont nous relevons, dans un délai d'un an à compter de votre réclamation écrite.",
  },
];

export default function ReclamationsPage() {
  // Tant que le médiateur n'est pas renseigné dans la config, on évite
  // d'afficher le placeholder "[À COMPLÉTER]" en public.
  const mediatorReady = !LEGAL.mediator.name.includes("COMPLÉTER");

  return (
    <SiteShell>
      <PageHero
        eyebrow="Qualité & écoute"
        title={
          <>
            Réclamations <span className="text-signal-400">&amp; médiation</span>
          </>
        }
        description="Votre satisfaction est au cœur de notre démarche qualité. Voici comment nous faire part d'un différend et les délais dans lesquels nous nous engageons à vous répondre."
      />

      <section className="max-w-5xl mx-auto px-6 py-16 md:py-20">
        {/* Étapes */}
        <div className="space-y-4">
          {STEPS.map((s) => (
            <div
              key={s.n}
              className="flex gap-5 rounded-2xl border border-white/10 bg-white/[0.04] p-6"
            >
              <span className="flex-none h-10 w-10 rounded-xl bg-signal-500/15 border border-signal-500/30 text-signal-300 font-display text-lg font-semibold flex items-center justify-center">
                {s.n}
              </span>
              <div>
                <h2 className="font-display text-xl font-semibold">{s.title}</h2>
                <p className="mt-2 text-white/70 leading-relaxed text-[15px]">
                  {s.body}
                </p>
              </div>
            </div>
          ))}
        </div>

        {/* Coordonnées */}
        <div className="mt-10 grid sm:grid-cols-2 gap-4">
          <div className="rounded-2xl border border-white/10 bg-white/[0.04] p-6">
            <div className="text-[11px] font-semibold uppercase tracking-[0.16em] text-white/45 mb-3">
              Nous écrire
            </div>
            <a
              href={`mailto:${LEGAL.supportEmail}`}
              className="flex items-center gap-2.5 text-white/85 hover:text-white transition-colors"
            >
              <Mail className="h-4 w-4 text-signal-400" />
              {LEGAL.supportEmail}
            </a>
            <a
              href={`tel:${LEGAL.phone.replace(/\s/g, "")}`}
              className="mt-2 flex items-center gap-2.5 text-white/85 hover:text-white transition-colors"
            >
              <Phone className="h-4 w-4 text-signal-400" />
              {LEGAL.phone}
            </a>
            <p className="mt-3 text-xs text-white/50 leading-relaxed">
              {LEGAL.legalName} — {LEGAL.address.street},{" "}
              {LEGAL.address.postalCode} {LEGAL.address.city}
            </p>
          </div>

          <div className="rounded-2xl border border-white/10 bg-white/[0.04] p-6">
            <div className="text-[11px] font-semibold uppercase tracking-[0.16em] text-white/45 mb-3">
              Médiateur de la consommation
            </div>
            <div className="flex items-start gap-2.5 text-white/85">
              <Scale className="h-4 w-4 text-signal-400 mt-0.5 shrink-0" />
              {mediatorReady ? (
                <div>
                  <div className="font-medium">{LEGAL.mediator.name}</div>
                  <div className="text-sm text-white/55 break-all">
                    {LEGAL.mediator.website}
                  </div>
                </div>
              ) : (
                <p className="text-[15px] text-white/75 leading-relaxed">
                  Les coordonnées du médiateur de la consommation dont nous
                  relevons vous sont communiquées sur simple demande, par e-mail
                  ou par téléphone.
                </p>
              )}
            </div>
            <p className="mt-3 text-xs text-white/50 leading-relaxed">
              Saisine gratuite, dans un délai d'un an après votre réclamation
              écrite (clients particuliers).
            </p>
          </div>
        </div>

        {/* Handicap */}
        <div className="mt-4 flex items-start gap-3 rounded-2xl border border-signal-500/25 bg-signal-500/[0.07] p-6">
          <Accessibility className="h-5 w-5 text-signal-300 shrink-0 mt-0.5" />
          <div>
            <h2 className="font-display text-lg font-semibold">
              Situation de handicap
            </h2>
            <p className="mt-1.5 text-white/70 text-[15px] leading-relaxed">
              Notre référent handicap étudie chaque besoin d'adaptation et reste
              à votre écoute pour toute difficulté d'accessibilité :{" "}
              <a
                href={`mailto:${LEGAL.qualiopi.accessibilityContact}`}
                className="underline hover:text-white"
              >
                {LEGAL.qualiopi.accessibilityContact}
              </a>
              .
            </p>
          </div>
        </div>

        {/* Données personnelles */}
        <p className="mt-6 flex items-center gap-2 text-xs text-white/45">
          <ShieldCheck className="h-3.5 w-3.5 text-white/40" />
          Pour une réclamation relative à vos données personnelles, consultez
          notre{" "}
          <a href="/confidentialite" className="underline hover:text-white/70">
            politique de confidentialité
          </a>
          .
        </p>
      </section>
    </SiteShell>
  );
}
