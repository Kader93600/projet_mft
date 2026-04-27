import Link from "next/link";
import { Logo } from "@/components/ui/logo";
import { LegalFooter } from "@/components/legal/legal-footer";
import {
  Check,
  Sparkles,
  ShieldCheck,
  Clock,
  GraduationCap,
  Building2,
  Wallet,
  Users,
  ArrowRight,
} from "lucide-react";
import { PLANS, FUNDING_LABEL, fmtEuros } from "@/lib/pricing-config";
import { LEGAL } from "@/lib/legal-config";

export const metadata = {
  title: `Tarifs — ${LEGAL.brand}`,
  description: `Formules de préparation au titre ${LEGAL.rncpCode} : auto-financement, CPF, OPCO, employeur, France Travail. Tarifs nets exonérés de TVA.`,
};

export const revalidate = 300;

export default function TarifsPage() {
  return (
    <div className="min-h-screen bg-ivory">
      {/* Header */}
      <header className="border-b border-navy-100 bg-white">
        <div className="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
          <Link href="/">
            <Logo />
          </Link>
          <Link
            href="/login"
            className="text-sm font-medium text-navy-900 hover:text-gold-700"
          >
            Se connecter →
          </Link>
        </div>
      </header>

      {/* Hero */}
      <section className="max-w-5xl mx-auto px-6 pt-16 pb-10 text-center">
        <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-gold-700">
          Tarifs
        </span>
        <h1 className="mt-2 font-display text-4xl md:text-5xl font-semibold text-navy-950 tracking-tight">
          Une formation, trois rythmes.
        </h1>
        <p className="mt-4 text-lg text-slate-600 max-w-2xl mx-auto">
          Préparation au titre {LEGAL.rncpCode} —{" "}
          <em>{LEGAL.rncpTitle}</em>. Nos tarifs sont nets, sans TVA (art.
          261-4-4° CGI), et compatibles avec les principaux dispositifs de
          financement.
        </p>
      </section>

      {/* Plans */}
      <section className="max-w-7xl mx-auto px-6 pb-16">
        <div className="grid md:grid-cols-3 gap-6">
          {PLANS.map((plan) => {
            const isHighlight = !!plan.highlighted;
            return (
              <article
                key={plan.id}
                className={
                  "relative rounded-3xl p-7 border " +
                  (isHighlight
                    ? "bg-navy-950 text-white border-gold-400 shadow-float"
                    : "bg-white text-navy-900 border-navy-100 shadow-soft")
                }
              >
                {isHighlight && (
                  <div className="absolute -top-3 left-1/2 -translate-x-1/2 inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-gold-500 text-navy-900 text-[11px] font-semibold uppercase tracking-wider">
                    <Sparkles className="h-3 w-3" /> {plan.tagline}
                  </div>
                )}

                <div
                  className={
                    "text-[11px] uppercase tracking-[0.16em] font-semibold " +
                    (isHighlight ? "text-gold-300" : "text-gold-700")
                  }
                >
                  {!isHighlight && plan.tagline}
                </div>
                <h2 className="mt-2 font-display text-2xl font-semibold">
                  {plan.name}
                </h2>
                <p
                  className={
                    "mt-2 text-sm " +
                    (isHighlight ? "text-white/70" : "text-slate-600")
                  }
                >
                  {plan.description}
                </p>

                <div className="mt-6 flex items-baseline gap-2">
                  <span className="font-display text-4xl font-semibold">
                    {fmtEuros(plan.priceCents)}
                  </span>
                  {plan.comparePriceCents && (
                    <span
                      className={
                        "text-sm line-through " +
                        (isHighlight ? "text-white/50" : "text-slate-400")
                      }
                    >
                      {fmtEuros(plan.comparePriceCents)}
                    </span>
                  )}
                </div>
                <div
                  className={
                    "text-[11px] uppercase tracking-wider mt-1 " +
                    (isHighlight ? "text-white/50" : "text-slate-500")
                  }
                >
                  Net, exonéré de TVA · {plan.hours} h sur {plan.durationWeeks}{" "}
                  semaines
                </div>

                <ul className="mt-6 space-y-2.5">
                  {plan.features.map((f) => (
                    <li key={f} className="flex items-start gap-2 text-sm">
                      <Check
                        className={
                          "h-4 w-4 mt-0.5 shrink-0 " +
                          (isHighlight ? "text-gold-400" : "text-emerald-600")
                        }
                      />
                      <span>{f}</span>
                    </li>
                  ))}
                </ul>

                <div
                  className={
                    "mt-6 pt-5 border-t " +
                    (isHighlight ? "border-white/15" : "border-navy-50")
                  }
                >
                  <div
                    className={
                      "text-[10px] uppercase tracking-wider mb-2 " +
                      (isHighlight ? "text-white/50" : "text-slate-500")
                    }
                  >
                    Financements possibles
                  </div>
                  <div className="flex flex-wrap gap-1.5">
                    {plan.funding.map((f) => (
                      <span
                        key={f}
                        className={
                          "text-[11px] px-2 py-0.5 rounded-md border " +
                          (isHighlight
                            ? "border-white/20 text-white/80"
                            : "border-navy-100 text-slate-700 bg-ivory")
                        }
                      >
                        {FUNDING_LABEL[f]}
                      </span>
                    ))}
                  </div>
                </div>

                <Link
                  href={`/inscription?plan=${plan.id}`}
                  className={
                    "mt-7 inline-flex items-center justify-center gap-2 w-full px-4 py-3 rounded-xl text-sm font-semibold transition " +
                    (isHighlight
                      ? "bg-gold-500 text-navy-900 hover:bg-gold-400"
                      : "bg-navy-900 text-white hover:bg-navy-800")
                  }
                >
                  Démarrer mon dossier <ArrowRight className="h-4 w-4" />
                </Link>
              </article>
            );
          })}
        </div>

        <p className="text-xs text-slate-500 text-center mt-6">
          * Garantie réussite : si vous échouez à l'examen final malgré une
          assiduité ≥ 90 %, nous vous proposons une nouvelle session sans
          frais.
        </p>
      </section>

      {/* Modes de financement */}
      <section className="bg-white border-y border-navy-100">
        <div className="max-w-7xl mx-auto px-6 py-16">
          <div className="text-center mb-10">
            <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-gold-700">
              Financement
            </span>
            <h2 className="mt-2 font-display text-3xl font-semibold text-navy-950">
              Plusieurs façons de financer votre formation
            </h2>
            <p className="mt-2 text-slate-600 max-w-2xl mx-auto">
              {LEGAL.brand} est certifié Qualiopi, ce qui rend les formations
              éligibles à tous les dispositifs de financement professionnels.
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
            <FundingCard
              icon={Wallet}
              title="CPF / Mon Compte Formation"
              desc="Mobilisez vos droits CPF accumulés. Inscription via la plateforme officielle Mon Compte Formation."
              cta="Voir la procédure"
              href="https://www.moncompteformation.gouv.fr"
              external
            />
            <FundingCard
              icon={Building2}
              title="OPCO / Plan employeur"
              desc="Votre entreprise prend en charge tout ou partie via son OPCO. Nous gérons le dossier de A à Z."
              cta="Demander un devis OPCO"
              href="/inscription?financeur=opco"
            />
            <FundingCard
              icon={Users}
              title="France Travail (AIF)"
              desc="Aide Individuelle à la Formation pour les demandeurs d'emploi. Étude personnalisée du dossier."
              cta="Étudier mon éligibilité"
              href="/inscription?financeur=pole_emploi"
            />
            <FundingCard
              icon={GraduationCap}
              title="Auto-financement"
              desc="Paiement en ligne sécurisé (carte bancaire) en une fois ou en 3 fois sans frais."
              cta="Démarrer maintenant"
              href="/inscription?financeur=auto"
            />
            <FundingCard
              icon={ShieldCheck}
              title="Transitions Pro"
              desc="Pour les projets de reconversion. Notre équipe vous accompagne dans le montage du dossier."
              cta="Nous contacter"
              href={`mailto:${LEGAL.email}`}
              external
            />
            <FundingCard
              icon={Clock}
              title="Paiement échelonné"
              desc="Paiement en 3 ou 4 fois sans frais sur les formules Essentiel et Accompagné, sans dossier de financement."
              cta="Voir les conditions"
              href="/cgv#article-4"
            />
          </div>
        </div>
      </section>

      {/* Trust */}
      <section className="max-w-5xl mx-auto px-6 py-16 text-center">
        <h2 className="font-display text-2xl md:text-3xl font-semibold text-navy-950">
          Engagement qualité
        </h2>
        <div className="mt-8 grid sm:grid-cols-3 gap-6 text-sm">
          <Trust
            label="Certification"
            value="Qualiopi"
            sub={LEGAL.qualiopiNumber}
          />
          <Trust
            label="Référencement"
            value={LEGAL.rncpCode}
            sub="France Compétences"
          />
          <Trust
            label="Organisme déclaré"
            value={LEGAL.trainingActivityNumber}
            sub={`Préfecture ${LEGAL.address.city}`}
          />
        </div>
        <p className="mt-10 text-sm text-slate-500">
          Une question ?{" "}
          <a
            href={`mailto:${LEGAL.email}`}
            className="text-navy-900 underline hover:text-gold-700"
          >
            {LEGAL.email}
          </a>{" "}
          · réponse sous 4 h ouvrées
        </p>
      </section>

      <LegalFooter variant="dark" />
    </div>
  );
}

function FundingCard({
  icon: Icon,
  title,
  desc,
  cta,
  href,
  external,
}: {
  icon: any;
  title: string;
  desc: string;
  cta: string;
  href: string;
  external?: boolean;
}) {
  return (
    <div className="rounded-2xl border border-navy-100 bg-white p-6">
      <div className="h-10 w-10 rounded-xl bg-navy-50 text-navy-900 flex items-center justify-center">
        <Icon className="h-5 w-5" />
      </div>
      <h3 className="mt-3 font-display text-lg font-semibold text-navy-900">
        {title}
      </h3>
      <p className="mt-1.5 text-sm text-slate-600">{desc}</p>
      <Link
        href={href}
        target={external ? "_blank" : undefined}
        rel={external ? "noopener noreferrer" : undefined}
        className="mt-4 inline-flex items-center gap-1.5 text-sm font-medium text-navy-900 hover:text-gold-700"
      >
        {cta} <ArrowRight className="h-3.5 w-3.5" />
      </Link>
    </div>
  );
}

function Trust({
  label,
  value,
  sub,
}: {
  label: string;
  value: string;
  sub: string;
}) {
  return (
    <div className="rounded-2xl border border-navy-100 bg-white p-5">
      <div className="text-[11px] uppercase tracking-wider text-gold-700 font-semibold">
        {label}
      </div>
      <div className="mt-1 font-display text-xl font-semibold text-navy-900">
        {value}
      </div>
      <div className="text-xs text-slate-500 mt-1 font-mono">{sub}</div>
    </div>
  );
}
