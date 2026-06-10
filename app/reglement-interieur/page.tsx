import { LegalPage, Section } from "@/components/legal/legal-page";
import { LEGAL, LEGAL_LAST_UPDATE } from "@/lib/legal-config";

export const metadata = {
  title: "Règlement intérieur",
  alternates: { canonical: "/reglement-interieur" },
  description: `Règlement intérieur de l'organisme de formation ${LEGAL.brand}.`,
};

export default function ReglementPage() {
  return (
    <LegalPage
      eyebrow="Organisme de formation"
      title="Règlement intérieur"
      lastUpdate={LEGAL_LAST_UPDATE}
      intro={
        <>
          Conformément aux articles L. 6352-3 à L. 6352-5 et R. 6352-1 à R.
          6352-15 du Code du travail, le présent règlement intérieur s'applique
          à tous les Stagiaires de {LEGAL.brand}, pour la durée de leur action
          de formation.
        </>
      }
    >
      <Section number="1" title="Objet et champ d'application">
        <p>
          Le présent règlement détermine les principales mesures relatives
          à&nbsp;:
        </p>
        <ul>
          <li>l'hygiène et la sécurité ;</li>
          <li>les règles applicables en matière de discipline ;</li>
          <li>la nature et l'échelle des sanctions ;</li>
          <li>les droits de la défense des Stagiaires.</li>
        </ul>
        <p>
          Il est applicable à toute personne suivant une formation organisée
          par {LEGAL.brand}, en présentiel ou à distance.
        </p>
      </Section>

      <Section number="2" title="Hygiène et sécurité">
        <p>
          La prévention des risques d'accident et de maladie est impérative et
          exige de chacun le respect total de toutes les prescriptions
          applicables en matière d'hygiène et de sécurité (article R. 6352-1).
        </p>
        <p>
          Pour les formations à distance, le Stagiaire est responsable de son
          environnement de travail (poste, écran, posture, pauses régulières).
          Il est invité à appliquer les recommandations ANSES en matière de
          prévention des troubles musculo-squelettiques.
        </p>
        <h3>2.1. Consignes en cas d'incendie (formations en présentiel)</h3>
        <p>
          Le Stagiaire doit prendre connaissance du plan d'évacuation affiché
          dans les locaux et respecter les consignes données par les agents de
          {" "}{LEGAL.brand} ou les agents de sécurité du site d'accueil.
        </p>
        <h3>2.2. Interdiction de fumer / vapoter</h3>
        <p>
          Conformément à l'article L. 3512-8 du Code de la santé publique, il
          est interdit de fumer et de vapoter dans les locaux de formation.
        </p>
        <h3>2.3. Boissons alcoolisées et substances illicites</h3>
        <p>
          Il est interdit d'introduire ou de consommer des boissons alcoolisées
          ou des substances illicites dans les locaux et durant la formation.
        </p>
      </Section>

      <Section number="3" title="Discipline">
        <h3>3.1. Tenue et comportement</h3>
        <p>
          Le Stagiaire est tenu d'avoir un comportement respectueux à l'égard
          du personnel et des autres Stagiaires. Le langage et la tenue doivent
          être convenables.
        </p>
        <h3>3.2. Horaires et assiduité</h3>
        <p>
          Le Stagiaire est tenu de respecter les horaires fixés et d'être
          présent à l'ensemble des sessions, en présentiel comme à distance.
          Les feuilles d'émargement (signature électronique pour les sessions
          synchrones, traces d'activité pour les sessions asynchrones) font
          foi.
        </p>
        <p>
          En cas d'absence ou de retard, le Stagiaire prévient {LEGAL.brand}
          dans les meilleurs délais et fournit un justificatif. L'absence
          injustifiée peut donner lieu à une retenue financière auprès du
          financeur, conformément aux dispositions légales.
        </p>
        <h3>3.3. Usage du matériel</h3>
        <p>
          Le Stagiaire conserve les supports pédagogiques mis à sa disposition
          dans le cadre exclusif de sa formation. Il est interdit d'enregistrer,
          de filmer, de photographier ou de capturer tout ou partie du contenu
          sans autorisation écrite préalable.
        </p>
        <h3>3.4. Confidentialité et propriété intellectuelle</h3>
        <p>
          Le Stagiaire s'engage à ne pas divulguer, reproduire ou diffuser
          les contenus pédagogiques. Toute violation expose à des poursuites
          civiles et pénales (articles L. 335-2 et suivants du Code de la
          propriété intellectuelle).
        </p>
      </Section>

      <Section number="4" title="Sanctions disciplinaires">
        <p>
          Tout manquement du Stagiaire aux obligations du présent règlement,
          ou aux consignes de sécurité, peut faire l'objet d'une sanction.
        </p>
        <p>Les sanctions, par ordre de gravité, sont :</p>
        <ul>
          <li><strong>l'avertissement écrit</strong> ;</li>
          <li>
            <strong>le blâme</strong> ou rappel à l'ordre formel par le
            responsable pédagogique ;
          </li>
          <li>
            <strong>l'exclusion temporaire</strong> de la formation (suspension
            de l'accès à la plateforme et aux sessions) ;
          </li>
          <li>
            <strong>l'exclusion définitive</strong> entraînant la résiliation
            de la convention et la perte du bénéfice de la formation.
          </li>
        </ul>
        <p>
          Aucune sanction ne peut être infligée sans information préalable du
          Stagiaire des griefs retenus contre lui (article R. 6352-4).
        </p>
      </Section>

      <Section number="5" title="Procédure disciplinaire">
        <p>
          Le Stagiaire est convoqué par lettre recommandée avec accusé de
          réception, ou remise en main propre contre décharge, en lui précisant
          l'objet de la convocation, la date, l'heure et le lieu de l'entretien.
        </p>
        <p>
          Lors de l'entretien, le Stagiaire peut se faire assister par la
          personne de son choix, Stagiaire ou salarié de l'organisme.
        </p>
        <p>
          La sanction ne peut intervenir moins d'un jour franc ni plus de
          quinze jours après l'entretien, et fait l'objet d'une décision écrite
          et motivée notifiée au Stagiaire (article R. 6352-7).
        </p>
        <p>
          Lorsque l'agissement a rendu indispensable une mesure conservatoire
          d'exclusion temporaire à effet immédiat, aucune sanction définitive
          ne peut être prise sans la procédure ci-dessus (article R. 6352-6).
        </p>
        <p>
          {LEGAL.brand} informe simultanément l'employeur, lorsque le
          Stagiaire est un salarié bénéficiant d'une formation prise en
          charge dans le cadre d'un dispositif employeur, ainsi que le cas
          échéant le financeur (OPCO, France Travail) de la sanction prise.
        </p>
      </Section>

      <Section number="6" title="Représentation des stagiaires">
        <p>
          Conformément aux articles R. 6352-9 à R. 6352-12 du Code du travail,
          des délégués des Stagiaires sont élus pour les formations d'une
          durée totale supérieure à 500 heures. {LEGAL.brand} organise alors
          ces élections au plus tard 20 heures après le début de la formation.
        </p>
      </Section>

      <Section number="7" title="Entrée en vigueur">
        <p>
          Le présent règlement entre en vigueur à la date de sa publication.
          Il est remis à chaque Stagiaire avec sa convocation et reste
          consultable à tout moment sur cette page.
        </p>
        <p>
          Tout Stagiaire reconnaît en avoir pris connaissance et l'avoir
          accepté lors de la signature du contrat ou de la convention de
          formation.
        </p>
      </Section>
    </LegalPage>
  );
}
