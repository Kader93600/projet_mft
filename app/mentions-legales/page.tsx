import { LegalPage, Section, DataRow } from "@/components/legal/legal-page";
import { LEGAL, LEGAL_LAST_UPDATE } from "@/lib/legal-config";

export const metadata = {
  title: `Mentions légales — ${LEGAL.brand}`,
  description: `Mentions légales du site ${LEGAL.brand}, organisme de formation préparant au titre RNCP 40990.`,
};

export default function MentionsLegalesPage() {
  return (
    <LegalPage
      eyebrow="Informations légales"
      title="Mentions légales"
      lastUpdate={LEGAL_LAST_UPDATE}
      intro={
        <>
          Conformément à la loi n° 2004-575 du 21 juin 2004 pour la confiance
          dans l'économie numérique (LCEN), vous trouverez ci-dessous les
          informations relatives à l'éditeur du site{" "}
          <a href={LEGAL.website} className="underline">
            {LEGAL.brand}
          </a>
          .
        </>
      }
    >
      <Section number="1" title="Éditeur du site">
        <dl className="rounded-xl border border-navy-100 bg-white p-5 not-prose">
          <DataRow label="Raison sociale" value={LEGAL.legalName} />
          <DataRow label="Forme juridique" value={LEGAL.legalForm} />
          <DataRow label="Capital social" value={LEGAL.shareCapital} />
          <DataRow
            label="Adresse"
            value={
              <>
                {LEGAL.address.street}
                <br />
                {LEGAL.address.postalCode} {LEGAL.address.city},{" "}
                {LEGAL.address.country}
              </>
            }
          />
          <DataRow label="SIRET" value={LEGAL.siret} />
          <DataRow label="RCS" value={LEGAL.rcs} />
          <DataRow label="N° de TVA intracommunautaire" value={LEGAL.vatNumber} />
          <DataRow label="Représentant légal" value={LEGAL.director} />
          <DataRow label="Directeur de publication" value={LEGAL.publicationDirector} />
          <DataRow
            label="Téléphone"
            value={
              <a href={`tel:${LEGAL.phone.replace(/\s/g, "")}`}>{LEGAL.phone}</a>
            }
          />
          <DataRow
            label="Email"
            value={<a href={`mailto:${LEGAL.email}`}>{LEGAL.email}</a>}
          />
        </dl>
      </Section>

      <Section number="2" title="Organisme de formation">
        <p>
          {LEGAL.brand} est un organisme de formation déclaré auprès de la
          Préfecture de la région compétente.
        </p>
        <dl className="rounded-xl border border-navy-100 bg-white p-5 not-prose">
          <DataRow
            label="Numéro de déclaration d'activité"
            value={LEGAL.trainingActivityNumber}
          />
          <DataRow label="Certification Qualiopi" value={LEGAL.qualiopiNumber} />
          <DataRow label="Organisme certificateur" value={LEGAL.qualiopiBody} />
          <DataRow
            label="Action de formation préparée"
            value={`${LEGAL.rncpCode} — ${LEGAL.rncpTitle}`}
          />
        </dl>
        <p className="text-sm text-slate-500">
          Cet enregistrement ne vaut pas agrément de l'État (article L. 6352-12
          du Code du travail).
        </p>
      </Section>

      <Section number="3" title="Hébergement">
        <dl className="rounded-xl border border-navy-100 bg-white p-5 not-prose">
          <DataRow label="Hébergeur" value={LEGAL.hosting.company} />
          <DataRow label="Adresse" value={LEGAL.hosting.address} />
          <DataRow label="Centre de données" value={LEGAL.hosting.euDataCenter} />
          <DataRow
            label="Site"
            value={
              <a href={LEGAL.hosting.website} target="_blank" rel="noreferrer">
                {LEGAL.hosting.website}
              </a>
            }
          />
        </dl>
        <p>
          Les données personnelles sont hébergées exclusivement dans des centres
          de données situés au sein de l'Union européenne. Aucun transfert hors
          UE n'est effectué sans clauses contractuelles types.
        </p>
      </Section>

      <Section number="4" title="Propriété intellectuelle">
        <p>
          L'ensemble des contenus présents sur le site (textes, images, vidéos,
          fiches pédagogiques, quiz, schémas, logos, marques) est la propriété
          exclusive de {LEGAL.legalName} ou fait l'objet d'une autorisation
          d'usage.
        </p>
        <p>
          Toute reproduction, représentation, modification, publication,
          adaptation, totale ou partielle, est strictement interdite sans
          autorisation écrite préalable, sous peine de constituer un délit de
          contrefaçon (articles L. 335-2 et suivants du Code de la propriété
          intellectuelle).
        </p>
        <p>
          Les contenus sont mis à disposition des stagiaires inscrits dans le
          cadre exclusif de leur formation. Ils ne peuvent être copiés,
          partagés, redistribués ou utilisés à des fins commerciales.
        </p>
      </Section>

      <Section number="5" title="Liens hypertextes">
        <p>
          Le site peut contenir des liens vers des sites tiers (Légifrance,
          France Compétences, etc.). {LEGAL.brand} n'exerce aucun contrôle sur
          ces sites et décline toute responsabilité quant à leur contenu.
        </p>
      </Section>

      <Section number="6" title="Données personnelles">
        <p>
          Le traitement des données personnelles est détaillé dans notre{" "}
          <a href="/confidentialite">politique de confidentialité</a>.
        </p>
        <p>
          Délégué à la protection des données : {LEGAL.dpoName} —{" "}
          <a href={`mailto:${LEGAL.dpoEmail}`}>{LEGAL.dpoEmail}</a>.
        </p>
      </Section>

      <Section number="7" title="Médiation de la consommation">
        <p>
          Conformément à l'article L. 612-1 du Code de la consommation,
          tout consommateur a le droit de recourir gratuitement à un
          médiateur de la consommation en vue de la résolution amiable d'un
          litige.
        </p>
        <dl className="rounded-xl border border-navy-100 bg-white p-5 not-prose">
          <DataRow label="Médiateur" value={LEGAL.mediator.name} />
          <DataRow
            label="Site"
            value={
              <a href={LEGAL.mediator.website} target="_blank" rel="noreferrer">
                {LEGAL.mediator.website}
              </a>
            }
          />
        </dl>
      </Section>

      <Section number="8" title="Droit applicable">
        <p>
          Les présentes mentions légales sont soumises au droit français. En cas
          de litige, et après tentative de résolution amiable, les tribunaux
          français seront seuls compétents.
        </p>
      </Section>
    </LegalPage>
  );
}
