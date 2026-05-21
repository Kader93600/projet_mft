import Link from "next/link";
import { SiteShell, PageHero } from "@/components/site/site-shell";
import { LEGAL } from "@/lib/legal-config";
import {
  Wallet,
  Building2,
  Users,
  GraduationCap,
  ShieldCheck,
  Clock,
  ArrowRight,
} from "lucide-react";

export const metadata = {
  title: `Financements — ${LEGAL.brand}`,
  description: `CPF, OPCO, France Travail, employeur, Transitions Pro : tous les modes de financement de nos formations transport.`,
};

export const revalidate = 3600;

const FUNDING = [
  {
    icon: Wallet,
    title: "CPF / Mon Compte Formation",
    audience: "Toute personne active",
    desc: "Mobilisez vos droits à la formation accumulés. Inscription via la plateforme officielle Mon Compte Formation. Aucun reste à charge dans la plupart des cas.",
    how: "Connexion à moncompteformation.gouv.fr → recherche de votre formation → inscription en quelques clics. Notre équipe vous guide.",
    href: "https://www.moncompteformation.gouv.fr",
    external: true,
    cta: "Accéder à Mon Compte Formation",
  },
  {
    icon: Building2,
    title: "OPCO (employeurs)",
    audience: "Salariés via leur entreprise",
    desc: "Votre employeur prend en charge la formation via son OPCO de branche (Mobilités, OPCO 2I…). Idéal pour le transport.",
    how: "Notre équipe monte le dossier de financement avec votre OPCO et envoie la convention pour signature. Vous n'avez rien à faire.",
    href: "/contact?financeur=opco",
    cta: "Demander un devis OPCO",
  },
  {
    icon: Users,
    title: "France Travail",
    audience: "Demandeurs d'emploi",
    desc: "Aide Individuelle à la Formation (AIF) ou financement direct dans le cadre d'un parcours de retour à l'emploi.",
    how: "Validation préalable avec votre conseiller France Travail. Nous établissons un devis détaillé adapté au dispositif.",
    href: "/contact?financeur=pole_emploi",
    cta: "Étudier mon éligibilité",
  },
  {
    icon: GraduationCap,
    title: "Transitions Pro",
    audience: "Salariés en reconversion",
    desc: "Pour les projets de transition professionnelle (PTP, ex-CIF). Maintien de salaire pendant la formation.",
    how: "Constitution d'un dossier solide avec accompagnement par notre équipe. Délai d'instruction de 2 à 3 mois.",
    href: "/contact?financeur=transitions_pro",
    cta: "Préparer mon dossier",
  },
  {
    icon: ShieldCheck,
    title: "Plan de développement employeur",
    audience: "Salariés via plan interne",
    desc: "Financement direct par l'entreprise dans le cadre de son plan de développement des compétences.",
    how: "Convention bipartite (entreprise / OF) ou tripartite (entreprise / OF / stagiaire) selon le cas.",
    href: "/contact?financeur=employeur",
    cta: "Nous contacter",
  },
  {
    icon: Clock,
    title: "Auto-financement",
    audience: "Particuliers, indépendants",
    desc: "Paiement direct, en une fois ou en 3-4 fois sans frais (plateforme Stripe sécurisée).",
    how: "Signature en ligne du contrat de formation, paiement par carte bancaire. Délai de rétractation 14 j.",
    href: "/contact?financeur=auto",
    cta: "Voir les modalités",
  },
];

export default function FinancementsPage() {
  return (
    <SiteShell>
      <PageHero
        eyebrow="Financements"
        title={
          <>
            Tous les{" "}
            <span className="italic text-signal-400">dispositifs</span> acceptés.
          </>
        }
        description={
          <>
            Toutes nos formations sont éligibles aux principaux dispositifs de
            financement professionnels grâce à notre certification Qualiopi.
            Notre équipe vous accompagne dans le montage du dossier.
          </>
        }
      />

      <main className="max-w-6xl mx-auto px-6 py-16 md:py-20 space-y-10">
        <div className="grid md:grid-cols-2 gap-5">
          {FUNDING.map((f) => (
            <article
              key={f.title}
              className="rounded-2xl border border-white/10 bg-night-100 p-6 hover:border-signal-500/40 transition group"
            >
              <div className="flex items-start gap-4">
                <div className="h-11 w-11 rounded-xl bg-signal-500/15 border border-signal-500/30 text-signal-400 flex items-center justify-center shrink-0">
                  <f.icon className="h-5 w-5" />
                </div>
                <div className="flex-1">
                  <div className="text-[10px] font-semibold uppercase tracking-[0.16em] text-white/40">
                    {f.audience}
                  </div>
                  <h3 className="mt-1 font-display text-xl font-semibold">
                    {f.title}
                  </h3>
                </div>
              </div>
              <p className="mt-4 text-sm text-white/70 leading-relaxed">
                {f.desc}
              </p>
              <div className="mt-4 rounded-xl bg-white/[0.03] border border-white/5 p-4">
                <div className="text-[11px] font-semibold uppercase tracking-[0.16em] text-signal-400 mb-1.5">
                  Comment ça marche
                </div>
                <p className="text-sm text-white/70 leading-relaxed">{f.how}</p>
              </div>
              <Link
                href={f.href}
                target={f.external ? "_blank" : undefined}
                rel={f.external ? "noopener noreferrer" : undefined}
                className="mt-5 inline-flex items-center gap-1.5 text-sm font-medium text-signal-400 hover:text-signal-300 transition-colors duration-200"
              >
                {f.cta}
                <ArrowRight className="h-3.5 w-3.5" />
              </Link>
            </article>
          ))}
        </div>

        {/* CTA */}
        <section className="mt-16 rounded-3xl bg-gradient-to-br from-brand-700 to-brand-900 p-10 md:p-14 relative overflow-hidden">
          <div
            aria-hidden="true"
            className="absolute -top-16 -right-16 h-60 w-60 rounded-full bg-signal-500/20 blur-3xl"
          />
          <div className="relative max-w-2xl">
            <div className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-300">
              Pas sûr(e) de votre éligibilité ?
            </div>
            <h2 className="mt-3 font-display text-3xl md:text-4xl font-semibold">
              Notre équipe étudie votre dossier{" "}
              <span className="italic text-signal-400">gratuitement</span>.
            </h2>
            <p className="mt-4 text-white/80 leading-relaxed">
              Un conseiller vous rappelle sous 24 h pour identifier le
              dispositif le mieux adapté à votre situation et monter le dossier
              avec vous.
            </p>
            <Link
              href="/contact"
              className="mt-6 inline-flex items-center gap-2 rounded-2xl bg-signal-500 text-night px-6 py-3 text-sm font-semibold hover:bg-signal-400 transition shadow-glow-signal"
            >
              Être rappelé(e)
              <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
        </section>
      </main>
    </SiteShell>
  );
}
