import Link from "next/link";
import { ArrowRight, HelpCircle } from "lucide-react";

const FAQ_ITEMS = [
  {
    q: "Vos formations sont-elles reconnues par l'État ?",
    a: "Oui. Nos parcours préparent à des titres ou attestations officielles : titres professionnels inscrits au RNCP (GOTRM, ECSR), attestations de capacité de transport, FIMO/FCO réglementaires. Nous sommes certifiés Qualiopi, ce qui conditionne l'accès aux financements publics.",
  },
  {
    q: "Combien de temps dure une formation ?",
    a: "De 35 heures (FCO) à plusieurs mois (ECSR). Chaque fiche formation détaille la durée, le rythme (intensif ou aménagé), et les modalités présentiel/distanciel.",
  },
  {
    q: "Puis-je payer avec mon CPF ?",
    a: "Oui pour la plupart de nos formations (GOTRM, ECSR, Taxi/VTC, capacités de transport, ERTV…). Vous mobilisez vos droits acquis directement depuis Mon Compte Formation. Nos équipes vous guident dans la procédure.",
  },
  {
    q: "Mon employeur peut-il financer ma formation ?",
    a: "Oui via votre OPCO de branche (OPCO Mobilités, OPCO 2I…) ou directement via le plan de développement des compétences. Nous montons le dossier avec votre RH et envoyons la convention pour signature.",
  },
  {
    q: "Je suis demandeur d'emploi, que puis-je financer ?",
    a: "France Travail propose l'AIF (Aide Individuelle à la Formation) sur étude de votre projet de retour à l'emploi. Notre équipe prépare un devis adapté pour validation par votre conseiller.",
  },
  {
    q: "Et si j'échoue à l'examen final ?",
    a: "Nous proposons une garantie re-formation : si vous échouez à l'examen final malgré une assiduité ≥ 90 %, vous bénéficiez d'une nouvelle session sans frais. Les conditions sont détaillées dans nos CGV.",
  },
  {
    q: "Puis-je essayer la plateforme avant de m'engager ?",
    a: "Oui, sur demande. Un conseiller vous offre un accès découverte de 7 jours sur un module-vitrine pour vérifier que la pédagogie vous convient.",
  },
  {
    q: "Comment se déroule l'examen blanc ?",
    a: "En conditions réelles : plein écran obligatoire, chrono visible, détection des sorties d'onglet, navigation entre questions avec drapeau « à revoir ». Les corrections détaillées sont accessibles après l'examen pour les packs Medium et Premium.",
  },
];

export function FaqSection() {
  return (
    <section className="py-20 md:py-28 bg-white/[0.02] border-y border-white/5">
      <div className="max-w-4xl mx-auto px-6">
        <div className="text-center max-w-2xl mx-auto mb-12">
          <span className="inline-flex items-center gap-1.5 text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-400">
            <HelpCircle className="w-3.5 h-3.5" />
            Questions fréquentes
          </span>
          <h2 className="mt-3 font-display text-3xl md:text-5xl font-semibold tracking-tight">
            On répond à vos{" "}
            <span className="italic text-signal-400">interrogations</span>.
          </h2>
        </div>

        <div className="space-y-3">
          {FAQ_ITEMS.map((it, i) => (
            <details
              key={it.q}
              className="group rounded-2xl border border-white/10 bg-night-100 overflow-hidden"
              open={i === 0}
            >
              <summary className="cursor-pointer list-none px-6 py-5 flex items-center justify-between gap-3 hover:bg-white/[0.03] transition-colors duration-200 rounded-2xl focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-white/30">
                <span className="font-medium text-white pr-4">{it.q}</span>
                <span className="text-signal-400 shrink-0 transition-transform group-open:rotate-90">
                  <ArrowRight className="h-4 w-4" />
                </span>
              </summary>
              <div className="px-6 pb-6 text-white/70 leading-relaxed">
                {it.a}
              </div>
            </details>
          ))}
        </div>

        <div className="mt-10 text-center">
          <Link
            href="/contact"
            className="inline-flex items-center gap-1.5 text-sm font-medium text-signal-400 hover:text-signal-300"
          >
            Une autre question ? Contactez-nous
            <ArrowRight className="h-3.5 w-3.5" />
          </Link>
        </div>
      </div>
    </section>
  );
}
