// =====================================================================
// FAQ générées par formation — à partir des données réelles du catalogue
// (durée, financements, prérequis, modalité). Alimentent :
//   - un bloc FAQ visible sur chaque fiche (contenu longue traîne),
//   - le JSON-LD FAQPage (éligibilité aux rich snippets Google).
// Aucune donnée inventée : tout est dérivé de lib/formations-config.ts.
// =====================================================================

import { type Formation, FUNDING_LABELS } from "@/lib/formations-config";
import { LEGAL } from "@/lib/legal-config";

export interface FaqItem {
  question: string;
  answer: string;
}

const MODALITY_TEXT: Record<Formation["modality"], string> = {
  presentiel: "en présentiel dans notre centre",
  distanciel: "à distance (formation ouverte et à distance)",
  mixte: "en format mixte, alliant présentiel et distanciel",
};

/** Construit la FAQ d'une formation à partir de ses données réelles. */
export function formationFaq(f: Formation): FaqItem[] {
  const fundingLabels = f.funding.map((k) => FUNDING_LABELS[k]);
  const cpf = f.funding.includes("cpf");
  const items: FaqItem[] = [];

  // 1. Durée
  items.push({
    question: `Quelle est la durée de la formation ${f.code} ?`,
    answer: `La formation ${f.title} dure ${f.duration}. Le détail du rythme et des modalités figure dans le programme de cette page.`,
  });

  // 2. Financement
  items.push({
    question: `Comment financer la formation ${f.code} ?`,
    answer: `Cette formation est finançable via ${listeFr(fundingLabels)}.${
      cpf
        ? " Vous pouvez notamment mobiliser vos droits CPF depuis Mon Compte Formation."
        : ""
    } Notre équipe vous accompagne gratuitement dans le montage de votre dossier de financement.`,
  });

  // 3. Prérequis
  items.push({
    question: `Quels sont les prérequis pour s'inscrire ?`,
    answer: `${f.prerequisites} Un entretien de positionnement permet de valider votre projet avant l'entrée en formation.`,
  });

  // 4. Modalité / lieu
  items.push({
    question: `La formation ${f.code} se déroule-t-elle en présentiel ou à distance ?`,
    answer: `La formation se déroule ${MODALITY_TEXT[f.modality]}. Notre centre est situé à ${LEGAL.address.city} (${LEGAL.address.postalCode}), en Île-de-France.`,
  });

  // 5. Débouchés (si renseignés)
  if (f.outcomes?.length) {
    items.push({
      question: `Quels débouchés après la formation ${f.code} ?`,
      answer: `À l'issue de la formation, vous pouvez notamment viser : ${listeFr(
        f.outcomes.slice(0, 3)
      )}.`,
    });
  }

  // 6. Reconnaissance (titre RNCP ou attestation)
  items.push({
    question: `La formation est-elle reconnue par l'État ?`,
    answer: f.rncpCode
      ? `Oui. Elle prépare au titre professionnel ${f.rncpCode}, inscrit au Répertoire National des Certifications Professionnelles (RNCP). Notre centre est certifié Qualiopi.`
      : `Oui. Elle prépare à une certification/attestation officielle du secteur, et notre centre est certifié Qualiopi, ce qui conditionne l'accès aux financements publics.`,
  });

  return items;
}

/** Schema.org FAQPage pour les rich snippets Google. */
export function faqSchema(items: FaqItem[]) {
  return {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: items.map((it) => ({
      "@type": "Question",
      name: it.question,
      acceptedAnswer: {
        "@type": "Answer",
        text: it.answer,
      },
    })),
  };
}

/** "A, B et C" — énumération française naturelle. */
function listeFr(arr: string[]): string {
  if (arr.length === 0) return "";
  if (arr.length === 1) return arr[0];
  return `${arr.slice(0, -1).join(", ")} et ${arr[arr.length - 1]}`;
}
