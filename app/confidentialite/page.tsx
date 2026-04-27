import Link from "next/link";
import { ShieldCheck, Mail, Database, Clock, Scale } from "lucide-react";

export const metadata = {
  title: "Politique de confidentialité — GOTRM Academy",
};

export default function ConfidentialitePage() {
  return (
    <div className="min-h-screen bg-ivory text-ink">
      <header className="bg-navy-950 text-white">
        <div className="max-w-3xl mx-auto px-6 py-12">
          <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-gold-300">
            RGPD
          </span>
          <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold">
            Politique de confidentialité
          </h1>
          <p className="mt-3 text-white/70 max-w-2xl">
            GOTRM Academy s'engage à protéger vos données personnelles
            conformément au Règlement (UE) 2016/679 (RGPD) et à la loi
            « Informatique et Libertés ».
          </p>
        </div>
      </header>

      <main className="max-w-3xl mx-auto px-6 py-12 space-y-10">
        <Section icon={ShieldCheck} title="Responsable de traitement">
          <p>
            GOTRM Academy, organisme de formation déclaré sous le numéro
            d'activité [à compléter], certifié Qualiopi.
          </p>
          <p className="mt-2">
            Délégué à la protection des données (DPO) :{" "}
            <a
              href="mailto:dpo@gotrm-academy.fr"
              className="text-navy-900 underline"
            >
              dpo@gotrm-academy.fr
            </a>
          </p>
        </Section>

        <Section icon={Database} title="Données collectées">
          <ul className="list-disc pl-5 space-y-1">
            <li>Identité : nom, prénom, email, téléphone</li>
            <li>Informations de formation : progression, scores, examens</li>
            <li>Données de financement : OPCO, CPF, employeur</li>
            <li>
              Préférences d'accessibilité (uniquement si vous les renseignez)
            </li>
            <li>Données techniques : journaux d'accès, adresse IP</li>
          </ul>
        </Section>

        <Section icon={Scale} title="Bases légales">
          <ul className="list-disc pl-5 space-y-1">
            <li>
              <strong>Exécution du contrat de formation</strong> (art. 6.1.b
              RGPD)
            </li>
            <li>
              <strong>Obligations légales</strong> Qualiopi, comptables et
              fiscales (art. 6.1.c)
            </li>
            <li>
              <strong>Consentement</strong> pour les communications optionnelles
              (art. 6.1.a)
            </li>
            <li>
              <strong>Intérêt légitime</strong> pour la sécurité et la mesure
              d'audience (art. 6.1.f)
            </li>
          </ul>
        </Section>

        <Section icon={Clock} title="Durées de conservation">
          <ul className="list-disc pl-5 space-y-1">
            <li>Compte stagiaire : durée de la formation + 3 ans</li>
            <li>
              Documents Qualiopi (feuilles de présence, certificats) : 4 ans
            </li>
            <li>Données comptables : 10 ans (Code de commerce)</li>
            <li>Logs techniques : 12 mois</li>
          </ul>
        </Section>

        <Section icon={ShieldCheck} title="Effacement & anonymisation">
          <p>
            En cas d'exercice de votre droit à l'effacement (article 17 RGPD),
            les données suivantes sont <strong>supprimées</strong> :
          </p>
          <ul className="list-disc pl-5 space-y-1 mt-2">
            <li>Nom, prénom, téléphone, notes pédagogiques, email remplacé</li>
            <li>Notes d'accompagnement, demandes d'accessibilité</li>
            <li>Notifications, messages personnels</li>
          </ul>
          <p className="mt-3">
            Les données suivantes sont <strong>anonymisées et conservées</strong>{" "}
            à des fins statistiques et de preuve Qualiopi (article 21 RGPD,
            opposition légitime impossible) :
          </p>
          <ul className="list-disc pl-5 space-y-1 mt-2">
            <li>Progression des leçons et tentatives de quiz (sans nom)</li>
            <li>Événements XP et badges obtenus (agrégés)</li>
            <li>
              Certificats émis et feuilles d'émargement (4 ans, obligation
              Qualiopi)
            </li>
            <li>
              Documents comptables liés à la formation (10 ans, Code de
              commerce)
            </li>
          </ul>
          <p className="mt-3 text-xs text-slate-500">
            Le compte est désactivé immédiatement après l'anonymisation.
          </p>
        </Section>

        <Section icon={ShieldCheck} title="Vos droits">
          <p>
            Vous disposez d'un droit d'accès, de rectification, d'effacement, de
            portabilité, de limitation et d'opposition. Vous pouvez les exercer
            depuis votre espace{" "}
            <Link href="/mes-donnees" className="text-navy-900 underline">
              Mes données
            </Link>
            , ou en contactant notre DPO.
          </p>
          <p className="mt-2">
            Vous pouvez également introduire une réclamation auprès de la CNIL
            (
            <a
              href="https://www.cnil.fr"
              className="text-navy-900 underline"
              target="_blank"
              rel="noopener noreferrer"
            >
              www.cnil.fr
            </a>
            ).
          </p>
        </Section>

        <Section icon={Mail} title="Sous-traitants">
          <p>
            Hébergement : Supabase (UE). Envoi d'emails : [prestataire à
            compléter]. Aucun transfert hors UE n'est effectué sans clauses
            contractuelles types.
          </p>
        </Section>

        <div className="border-t border-navy-100 pt-6 text-sm text-slate-500">
          Dernière mise à jour : {new Date().toLocaleDateString("fr-FR")}.
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
