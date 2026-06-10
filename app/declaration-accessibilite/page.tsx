import Link from "next/link";
import { Accessibility, Mail, Wrench, Scale } from "lucide-react";
import { LEGAL } from "@/lib/legal-config";

export const metadata = {
  title: "Déclaration d'accessibilité",
  alternates: { canonical: "/declaration-accessibilite" },
  description: `Engagements et état d'accessibilité numérique du site ${LEGAL.brand} (RGAA).`,
};

/**
 * Déclaration d'accessibilité PUBLIQUE (le footer légal pointe ici).
 * À ne pas confondre avec /accessibilite (page protégée : préférences
 * d'affichage des stagiaires connectés).
 */
export default function DeclarationAccessibilitePage() {
  return (
    <div className="min-h-screen bg-ivory text-ink">
      <header className="bg-navy-950 text-white">
        <div className="max-w-3xl mx-auto px-6 py-12">
          <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-gold-300">
            Accessibilité
          </span>
          <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold">
            Déclaration d'accessibilité
          </h1>
          <p className="mt-3 text-white/70 max-w-2xl">
            {LEGAL.brand} s'engage à rendre son site internet et sa plateforme
            de formation accessibles à toutes et tous, y compris aux personnes
            en situation de handicap.
          </p>
        </div>
      </header>

      <main className="max-w-3xl mx-auto px-6 py-12 space-y-10">
        <Section icon={Accessibility} title="État de conformité">
          <p>
            Le site {LEGAL.brand} est en cours d'évaluation au regard du
            Référentiel Général d'Amélioration de l'Accessibilité (RGAA
            version 4). En l'absence d'audit complet réalisé à ce jour, le
            site est réputé <strong>non conforme</strong> au RGAA — ce statut
            sera mis à jour à l'issue de l'audit.
          </p>
          <p className="mt-2">
            Des mesures concrètes sont déjà en place : navigation entièrement
            au clavier, liens d'évitement, contrastes renforcés, libellés de
            formulaires explicites, alternatives textuelles, respect de la
            préférence « réduire les animations », et options d'affichage
            dédiées dans l'espace stagiaire (taille de police, police adaptée
            à la dyslexie, contraste élevé).
          </p>
        </Section>

        <Section icon={Wrench} title="Adaptation de votre formation">
          <p>
            Au-delà du site, nous adaptons les parcours de formation aux
            situations de handicap (rythme, supports, modalités d'examen).
            Contactez notre référent handicap dès votre inscription pour
            étudier ensemble les aménagements possibles :
          </p>
          <p className="mt-2">
            <a
              href={`mailto:${LEGAL.qualiopi.accessibilityContact}`}
              className="text-navy-900 underline font-medium"
            >
              {LEGAL.qualiopi.accessibilityContact}
            </a>{" "}
            · {LEGAL.phone}
          </p>
        </Section>

        <Section icon={Mail} title="Signaler un problème d'accessibilité">
          <p>
            Si vous rencontrez un défaut d'accessibilité vous empêchant
            d'accéder à un contenu ou à une fonctionnalité, écrivez-nous à{" "}
            <a
              href={`mailto:${LEGAL.qualiopi.accessibilityContact}`}
              className="text-navy-900 underline"
            >
              {LEGAL.qualiopi.accessibilityContact}
            </a>
            . Nous nous engageons à vous répondre sous 5 jours ouvrés et à
            corriger le défaut dans les meilleurs délais.
          </p>
        </Section>

        <Section icon={Scale} title="Voies de recours">
          <p>
            Si vous avez signalé un défaut d'accessibilité et que vous n'avez
            pas obtenu de réponse satisfaisante, vous pouvez :
          </p>
          <ul className="list-disc pl-5 space-y-1 mt-2">
            <li>
              écrire au{" "}
              <a
                href="https://formulaire.defenseurdesdroits.fr"
                target="_blank"
                rel="noopener noreferrer"
                className="text-navy-900 underline"
              >
                Défenseur des droits
              </a>{" "}
              ;
            </li>
            <li>
              contacter le délégué du Défenseur des droits de votre région ;
            </li>
            <li>
              envoyer un courrier postal (gratuit, sans affranchissement) :
              Défenseur des droits, Libre réponse 71120, 75342 Paris CEDEX 07.
            </li>
          </ul>
        </Section>

        <div className="border-t border-navy-100 pt-6 text-sm text-slate-500">
          Cette déclaration sera actualisée après chaque audit d'accessibilité.{" "}
          <Link href="/contact" className="underline">
            Nous contacter
          </Link>
          .
        </div>
      </main>
    </div>
  );
}

function Section({
  icon: Icon,
  title,
  children,
}: {
  icon: any;
  title: string;
  children: React.ReactNode;
}) {
  return (
    <section>
      <div className="flex items-center gap-2 mb-3">
        <div className="h-9 w-9 rounded-xl bg-navy-50 text-navy-900 flex items-center justify-center">
          <Icon className="h-4 w-4" />
        </div>
        <h2 className="font-display text-xl font-semibold text-navy-950">
          {title}
        </h2>
      </div>
      <div className="text-slate-700 leading-relaxed">{children}</div>
    </section>
  );
}
