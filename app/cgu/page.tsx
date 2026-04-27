import { LegalPage, Section } from "@/components/legal/legal-page";
import { LEGAL, LEGAL_LAST_UPDATE } from "@/lib/legal-config";

export const metadata = {
  title: `Conditions générales d'utilisation — ${LEGAL.brand}`,
  description: `Règles d'utilisation de la plateforme ${LEGAL.brand}.`,
};

export default function CguPage() {
  return (
    <LegalPage
      eyebrow="Plateforme"
      title="Conditions générales d'utilisation"
      lastUpdate={LEGAL_LAST_UPDATE}
      intro={
        <>
          Les présentes conditions régissent l'accès et l'usage de la
          plateforme {LEGAL.brand}. Toute connexion vaut acceptation pleine
          et entière de ces conditions.
        </>
      }
    >
      <Section number="1" title="Objet">
        <p>
          {LEGAL.brand} (« la Plateforme ») est un service en ligne édité par{" "}
          {LEGAL.legalName} permettant à ses utilisateurs (« le Stagiaire ») de
          suivre des modules de formation, de réaliser des quiz, des examens
          blancs, et d'accéder à un suivi pédagogique en vue de la préparation
          du titre professionnel {LEGAL.rncpCode} —{" "}
          <em>{LEGAL.rncpTitle}</em>.
        </p>
      </Section>

      <Section number="2" title="Accès au service">
        <p>
          L'accès à la Plateforme est strictement réservé aux Stagiaires
          inscrits ayant validé une convention ou un contrat de formation. Un
          identifiant et un mot de passe personnels sont remis à chaque
          Stagiaire.
        </p>
        <p>
          Le Stagiaire s'engage à conserver ses identifiants confidentiels et à
          ne pas les communiquer à un tiers. Toute connexion ou action
          effectuée à l'aide de ses identifiants est réputée avoir été
          effectuée par lui.
        </p>
        <p>
          {LEGAL.brand} se réserve le droit de suspendre ou résilier l'accès
          d'un Stagiaire en cas de manquement aux présentes ou au règlement
          intérieur de l'organisme de formation.
        </p>
      </Section>

      <Section number="3" title="Disponibilité du service">
        <p>
          La Plateforme est accessible 24 h/24, 7 j/7, sauf cas de force
          majeure, opérations de maintenance programmées ou interruptions liées
          à l'hébergeur. {LEGAL.brand} fait ses meilleurs efforts pour assurer
          un taux de disponibilité supérieur à 99 % sur l'année.
        </p>
        <p>
          {LEGAL.brand} ne saurait être tenu responsable des dysfonctionnements
          liés au matériel, au logiciel ou à la connexion internet du
          Stagiaire.
        </p>
      </Section>

      <Section number="4" title="Comportements interdits">
        <p>L'utilisateur s'interdit notamment :</p>
        <ul>
          <li>de copier, télécharger, redistribuer ou diffuser tout ou partie des contenus pédagogiques ;</li>
          <li>de partager ses identifiants avec un tiers ;</li>
          <li>d'utiliser des moyens automatisés (robots, scripts) pour collecter des données ;</li>
          <li>de tenter de contourner les mécanismes de sécurité ou de détection de fraude (anti-copie, plein écran, détection de sortie d'examen) ;</li>
          <li>de tenir des propos contraires à la loi, diffamatoires, injurieux ou discriminatoires sur la messagerie ou les espaces d'échange.</li>
        </ul>
        <p>
          Tout manquement constaté pourra entraîner la suspension du compte,
          l'invalidation des résultats obtenus, et selon la gravité, des
          poursuites judiciaires.
        </p>
      </Section>

      <Section number="5" title="Propriété intellectuelle">
        <p>
          L'ensemble des contenus pédagogiques (cours, vidéos, quiz, fiches de
          synthèse, schémas) sont la propriété exclusive de {LEGAL.legalName}.
          Ils sont protégés par le Code de la propriété intellectuelle.
        </p>
        <p>
          {LEGAL.brand} concède au Stagiaire une licence personnelle, non
          exclusive, non transmissible et limitée à la durée de sa formation,
          dans le seul but de suivre celle-ci. Toute autre exploitation est
          interdite.
        </p>
      </Section>

      <Section number="6" title="Données personnelles">
        <p>
          Le traitement des données est régi par notre{" "}
          <a href="/confidentialite">politique de confidentialité</a> et le
          Règlement (UE) 2016/679 (RGPD).
        </p>
      </Section>

      <Section number="7" title="Cookies">
        <p>
          La Plateforme utilise des cookies essentiels au fonctionnement et,
          avec votre consentement, des cookies de mesure d'audience et de
          communication. Vous pouvez à tout moment modifier vos préférences
          depuis votre espace <a href="/mes-donnees">Mes données</a>.
        </p>
      </Section>

      <Section number="8" title="Évolution des présentes">
        <p>
          {LEGAL.brand} se réserve la possibilité de modifier les CGU à tout
          moment. Les modifications prennent effet dès leur publication sur la
          Plateforme. Le Stagiaire est informé par email et par notification
          interne. La poursuite de l'usage vaut acceptation.
        </p>
      </Section>

      <Section number="9" title="Droit applicable et juridiction">
        <p>
          Les présentes CGU sont régies par le droit français. Tout litige
          fera l'objet d'une tentative de résolution amiable. À défaut, les
          tribunaux français seront compétents.
        </p>
      </Section>
    </LegalPage>
  );
}
