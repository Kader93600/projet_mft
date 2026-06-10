import { LegalPage, Section } from "@/components/legal/legal-page";
import { LEGAL, LEGAL_LAST_UPDATE } from "@/lib/legal-config";
import { Download, FileText } from "lucide-react";

export const metadata = {
  title: "Droit de rétractation",
  alternates: { canonical: "/retractation" },
  description: `Modalités d'exercice du droit de rétractation de 14 jours.`,
};

export default function RetractationPage() {
  return (
    <LegalPage
      eyebrow="Vos droits"
      title="Droit de rétractation"
      lastUpdate={LEGAL_LAST_UPDATE}
      intro={
        <>
          Conformément aux articles L. 221-18 et suivants du Code de la
          consommation, vous disposez d'un délai de <strong>14 jours</strong>{" "}
          pour vous rétracter du contrat de formation, sans avoir à motiver
          votre décision ni à supporter de frais autres que ceux prévus par la
          loi.
        </>
      }
    >
      <Section number="1" title="Bénéficiaires">
        <p>
          Le droit de rétractation s'applique aux Stagiaires personnes
          physiques agissant à des fins n'entrant pas dans le cadre d'une
          activité professionnelle (B2C).
        </p>
        <p>
          Il ne s'applique pas aux contrats conclus dans le cadre d'une
          activité professionnelle (B2B), même par une personne physique
          agissant pour le compte d'une entreprise.
        </p>
      </Section>

      <Section number="2" title="Délai">
        <p>
          Le délai est de <strong>14 jours calendaires</strong> à compter du
          lendemain de la signature du contrat ou de la convention de
          formation.
        </p>
        <p>
          Si ce délai expire un samedi, dimanche ou jour férié, il est prolongé
          jusqu'au premier jour ouvrable suivant.
        </p>
      </Section>

      <Section number="3" title="Comment exercer votre droit ?">
        <p>Vous pouvez nous notifier votre décision par&nbsp;:</p>
        <ul>
          <li>
            <strong>Le formulaire ci-dessous</strong>, à imprimer, signer et
            renvoyer.
          </li>
          <li>
            <strong>Email</strong> à{" "}
            <a href={`mailto:${LEGAL.email}`}>{LEGAL.email}</a> avec votre
            décision exprimée sans ambiguïté.
          </li>
          <li>
            <strong>Courrier postal</strong> à : {LEGAL.legalName},{" "}
            {LEGAL.address.street}, {LEGAL.address.postalCode}{" "}
            {LEGAL.address.city}.
          </li>
        </ul>
        <p>
          Pour respecter le délai, il suffit que votre communication soit{" "}
          <em>envoyée</em> avant l'expiration des 14 jours.
        </p>

        <div className="not-prose">
          <a
            href="/api/legal/retractation.pdf"
            className="inline-flex items-center gap-2 mt-4 px-4 py-2.5 rounded-xl bg-navy-900 text-white text-sm font-medium hover:bg-navy-800"
          >
            <Download className="h-4 w-4" />
            Télécharger le formulaire (PDF)
          </a>
        </div>
      </Section>

      <Section number="4" title="Effets de la rétractation">
        <p>
          En cas de rétractation, nous vous remboursons l'intégralité des
          sommes versées, sans retard injustifié et au plus tard{" "}
          <strong>14 jours</strong> à compter du jour où nous sommes informés
          de votre décision.
        </p>
        <p>
          Le remboursement est effectué en utilisant le même moyen de paiement
          que celui utilisé pour la transaction initiale, sauf accord exprès
          pour un autre moyen.
        </p>
      </Section>

      <Section number="5" title="Si la formation a démarré pendant la période de rétractation">
        <p>
          Si vous avez expressément demandé que la formation commence avant
          l'expiration du délai de 14 jours, vous restez redevable d'un montant
          proportionnel aux services fournis jusqu'au jour de votre
          rétractation (article L. 221-25 du Code de la consommation).
        </p>
      </Section>

      <Section number="6" title="Modèle de formulaire">
        <div className="not-prose rounded-xl border border-navy-200 bg-white p-6 my-4">
          <div className="flex items-center gap-2 mb-4 text-navy-900">
            <FileText className="h-4 w-4" />
            <span className="font-semibold text-sm uppercase tracking-wider">
              Formulaire de rétractation
            </span>
          </div>
          <div className="text-[13px] text-slate-700 leading-relaxed space-y-2 font-mono">
            <p>À : {LEGAL.legalName}</p>
            <p>
              {LEGAL.address.street}
              <br />
              {LEGAL.address.postalCode} {LEGAL.address.city}
              <br />
              {LEGAL.email}
            </p>
            <p className="pt-3">
              Je / Nous (*) vous notifie / notifions (*) par la présente ma /
              notre (*) rétractation du contrat portant sur la prestation de
              services ci-dessous :
            </p>
            <p>
              ─ Action de formation : ___________________________________
              <br />
              ─ Commandée le : ____ / ____ / ________
              <br />
              ─ Signée le : ____ / ____ / ________
              <br />
              ─ Nom du / des Stagiaire(s) : ________________________________
              <br />
              ─ Adresse du / des Stagiaire(s) : ____________________________
              <br />
              ─ Date : ____ / ____ / ________
              <br />
              ─ Signature(s) :
            </p>
            <p className="text-xs text-slate-500 pt-2">
              (*) Rayer la mention inutile.
            </p>
          </div>
        </div>
      </Section>
    </LegalPage>
  );
}
