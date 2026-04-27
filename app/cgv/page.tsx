import { LegalPage, Section } from "@/components/legal/legal-page";
import { LEGAL, LEGAL_LAST_UPDATE } from "@/lib/legal-config";

export const metadata = {
  title: `Conditions générales de vente — ${LEGAL.brand}`,
  description: `Conditions de vente des actions de formation ${LEGAL.brand}.`,
};

export default function CgvPage() {
  return (
    <LegalPage
      eyebrow="Vente"
      title="Conditions générales de vente"
      lastUpdate={LEGAL_LAST_UPDATE}
      intro={
        <>
          Les présentes CGV s'appliquent à toutes les inscriptions aux actions
          de formation proposées par {LEGAL.brand}. Elles prévalent sur tout
          autre document, sauf dérogation expresse écrite. Le client reconnaît
          en avoir pris connaissance avant toute commande.
        </>
      }
    >
      <Section number="1" title="Identification du prestataire">
        <p>
          {LEGAL.legalName} ({LEGAL.legalForm}), SIRET {LEGAL.siret}, déclaré
          en tant qu'organisme de formation sous le numéro{" "}
          {LEGAL.trainingActivityNumber}, certifié Qualiopi (
          {LEGAL.qualiopiNumber}) par {LEGAL.qualiopiBody}.
        </p>
      </Section>

      <Section number="2" title="Définitions">
        <ul>
          <li><strong>Stagiaire</strong> : personne physique inscrite à une formation.</li>
          <li><strong>Client</strong> : personne (physique ou morale) qui finance la formation.</li>
          <li><strong>Financeur</strong> : OPCO, France Travail, employeur, Caisse des Dépôts (CPF) ou auto-financement.</li>
          <li><strong>Action de formation</strong> : parcours pédagogique référencé {LEGAL.rncpCode}.</li>
        </ul>
      </Section>

      <Section number="3" title="Modalités d'inscription">
        <p>
          L'inscription s'effectue via le formulaire en ligne, par email ou
          téléphone. Toute inscription donne lieu à l'envoi d'un devis et d'un
          projet de convention de formation.
        </p>
        <p>
          La formation est confirmée à réception du dossier complet :
          convention signée, accord de prise en charge du financeur si
          applicable, et acompte le cas échéant.
        </p>
      </Section>

      <Section number="4" title="Tarifs et paiement">
        <p>
          Les tarifs sont exprimés en euros, nets de TVA (article 261-4-4° du
          CGI : exonération applicable aux organismes de formation
          professionnelle continue déclarés).
        </p>
        <p>
          Les modalités de paiement sont indiquées sur le devis :
        </p>
        <ul>
          <li><strong>Auto-financement</strong> : règlement à la commande ou échéances mensuelles.</li>
          <li><strong>OPCO / employeur</strong> : facturation directe au financeur après accord de prise en charge.</li>
          <li><strong>CPF</strong> : règlement par la Caisse des Dépôts via Mon Compte Formation.</li>
          <li><strong>France Travail</strong> : règlement selon convention spécifique.</li>
        </ul>
        <p>
          En cas de retard de paiement, des pénalités au taux d'intérêt légal
          en vigueur, ainsi qu'une indemnité forfaitaire pour frais de
          recouvrement de 40 € (article L. 441-10 du Code de commerce) seront
          dues de plein droit.
        </p>
      </Section>

      <Section number="5" title="Droit de rétractation (B2C)">
        <p>
          Conformément à l'article L. 221-18 du Code de la consommation, tout
          consommateur dispose d'un délai de <strong>14 jours</strong> à
          compter de la signature du contrat pour exercer son droit de
          rétractation, sans avoir à justifier de motifs ni à payer de
          pénalités.
        </p>
        <p>
          La rétractation peut être exercée :
        </p>
        <ul>
          <li>en utilisant le formulaire disponible sur la page <a href="/retractation">/retractation</a> ;</li>
          <li>par toute déclaration dénuée d'ambiguïté, par courrier ou email à <a href={`mailto:${LEGAL.email}`}>{LEGAL.email}</a>.</li>
        </ul>
        <p>
          Si la formation a commencé, à la demande du Stagiaire, durant la
          période de rétractation, le Stagiaire devra payer un montant
          proportionnel à ce qui lui a été fourni.
        </p>
        <p>
          Le droit de rétractation ne s'applique pas aux contrats signés dans
          le cadre d'une activité professionnelle (B2B).
        </p>
      </Section>

      <Section number="6" title="Annulation et report">
        <p>
          <strong>Par le Stagiaire / Client</strong> : toute annulation doit
          être notifiée par écrit. En cas d'annulation moins de 10 jours
          ouvrés avant le démarrage, 30 % du coût pédagogique restent dus.
          Au-delà du démarrage, l'intégralité reste due, sauf motif légitime
          (maladie sur certificat médical, force majeure).
        </p>
        <p>
          <strong>Par {LEGAL.brand}</strong> : si le nombre de Stagiaires est
          insuffisant, ou en cas de force majeure, la session pourra être
          reportée. Les sommes éventuellement versées seront remboursées
          intégralement sous 30 jours, à défaut de report accepté.
        </p>
      </Section>

      <Section number="7" title="Exécution de la formation">
        <p>
          La formation est dispensée selon les modalités précisées dans la
          convention (durée totale, dates, modalités présentiel /
          distanciel). Une convocation officielle est envoyée au moins 7 jours
          avant le démarrage.
        </p>
        <p>
          Le Stagiaire s'engage à respecter le programme et le règlement
          intérieur de l'organisme, disponible sur la page{" "}
          <a href="/reglement-interieur">/reglement-interieur</a>.
        </p>
      </Section>

      <Section number="8" title="Suivi, évaluation et certification">
        <p>
          Le suivi de l'exécution se fait par signature électronique de feuilles
          d'émargement. À l'issue, le Stagiaire reçoit :
        </p>
        <ul>
          <li>une <strong>attestation de fin de formation</strong> (article L. 6353-1 du Code du travail) ;</li>
          <li>en cas de réussite à l'examen, le titre {LEGAL.rncpCode}, délivré par l'autorité compétente ;</li>
          <li>un <strong>questionnaire de satisfaction</strong> (à chaud + à froid à 3 mois).</li>
        </ul>
      </Section>

      <Section number="9" title="Accessibilité et adaptation handicap">
        <p>
          {LEGAL.brand} est engagé en faveur de l'accessibilité. Pour toute
          situation de handicap, vous pouvez contacter notre référent
          accessibilité à{" "}
          <a href={`mailto:${LEGAL.qualiopi.accessibilityContact}`}>
            {LEGAL.qualiopi.accessibilityContact}
          </a>{" "}
          afin d'étudier ensemble les adaptations possibles.
        </p>
      </Section>

      <Section number="10" title="Responsabilité">
        <p>
          La responsabilité de {LEGAL.brand} ne saurait être engagée pour des
          dommages indirects (perte de chance, manque à gagner) liés à
          l'usage de la formation. Sa responsabilité globale est plafonnée
          au montant du coût pédagogique de la formation concernée.
        </p>
      </Section>

      <Section number="11" title="Propriété intellectuelle">
        <p>
          Tous les contenus restent la propriété exclusive de {LEGAL.legalName}.
          Le Stagiaire bénéficie d'un droit d'usage personnel, limité à la
          durée de la formation. Toute reproduction est interdite.
        </p>
      </Section>

      <Section number="12" title="Données personnelles">
        <p>
          Voir notre <a href="/confidentialite">politique de confidentialité</a>{" "}
          et nos <a href="/cgu">conditions générales d'utilisation</a>.
        </p>
      </Section>

      <Section number="13" title="Médiation et litiges">
        <p>
          En cas de litige, les parties privilégieront une résolution amiable.
          À défaut, le consommateur peut saisir gratuitement le médiateur de la
          consommation : <strong>{LEGAL.mediator.name}</strong> —{" "}
          <a href={LEGAL.mediator.website} target="_blank" rel="noreferrer">
            {LEGAL.mediator.website}
          </a>.
        </p>
        <p>
          À défaut d'accord, les tribunaux du ressort de {LEGAL.address.city}{" "}
          seront seuls compétents (B2B). Pour les litiges B2C, les règles de
          compétence du Code de la consommation s'appliquent.
        </p>
      </Section>
    </LegalPage>
  );
}
