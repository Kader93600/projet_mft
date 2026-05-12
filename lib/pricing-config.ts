// =====================================================================
// Catalogue & tarifs — source unique pour /tarifs, devis, Stripe, etc.
// Modifier ici → met à jour landing + page tarifs + checkout.
// =====================================================================

export type FundingKind = "auto" | "cpf" | "opco" | "employeur" | "pole_emploi";

export interface Plan {
  id: string;
  name: string;
  tagline: string;
  description: string;
  /** Prix net en centimes, exonéré de TVA (art. 261-4-4° CGI). */
  priceCents: number;
  /** Prix barré (offre promo) en centimes — optionnel. */
  comparePriceCents?: number;
  hours: number;
  durationWeeks: number;
  modality: "presentiel" | "distanciel" | "mixte";
  features: string[];
  /** Mis en avant sur la landing (max 1). */
  highlighted?: boolean;
  /** Modes de financement possibles pour ce plan. */
  funding: FundingKind[];
  /** ID Stripe si configuré (sinon on crée à la volée). Optionnel. */
  stripePriceId?: string;
}

export const PLANS: Plan[] = [
  {
    // ⚠️ PLAN TEMPORAIRE — uniquement pour valider le tunnel Stripe end-to-end
    // À SUPPRIMER après le test (revert du commit qui l'a ajouté).
    id: "test-1e",
    name: "TEST 1€ — Ne pas commander",
    tagline: "Plan de test interne",
    description:
      "Plan technique temporaire pour valider l'intégration Stripe en production. À supprimer après le test.",
    priceCents: 100, // 1 €
    hours: 0,
    durationWeeks: 0,
    modality: "distanciel",
    features: ["Plan technique de test — ne pas commander"],
    funding: ["auto"],
  },
  {
    id: "essentiel",
    name: "Essentiel",
    tagline: "Préparation autonome",
    description:
      "Tous les modules en ligne, fiches de synthèse, quiz, examens blancs.",
    priceCents: 99000, // 990 €
    hours: 80,
    durationWeeks: 12,
    modality: "distanciel",
    features: [
      "Tous les modules RNCP 40990",
      "Fiches de synthèse imprimables",
      "Quiz illimités + examens blancs",
      "Suivi de progression",
      "Certificat de fin de formation",
    ],
    funding: ["auto", "cpf"],
  },
  {
    id: "accompagnement",
    name: "Accompagné",
    tagline: "Le plus choisi",
    description:
      "L'Essentiel + coaching individuel et sessions live mensuelles.",
    priceCents: 189000, // 1 890 €
    comparePriceCents: 219000,
    hours: 120,
    durationWeeks: 16,
    modality: "mixte",
    highlighted: true,
    features: [
      "Tout l'Essentiel",
      "3 sessions de coaching individuel (1 h)",
      "Sessions live mensuelles avec un formateur",
      "Corrections personnalisées des examens blancs",
      "Hotline pédagogique sous 24 h ouvrées",
    ],
    funding: ["auto", "cpf", "opco", "employeur", "pole_emploi"],
  },
  {
    id: "intensif",
    name: "Intensif",
    tagline: "Préparation rapide",
    description:
      "Bootcamp 8 semaines avec mentor dédié et examens hebdomadaires.",
    priceCents: 290000, // 2 900 €
    hours: 160,
    durationWeeks: 8,
    modality: "mixte",
    features: [
      "Tout l'Accompagné",
      "Mentor dédié sur toute la durée",
      "Examen blanc hebdomadaire corrigé",
      "Préparation à l'oral du jury",
      "Garantie réussite ou re-formation offerte*",
    ],
    funding: ["auto", "opco", "employeur"],
  },
];

export const FUNDING_LABEL: Record<FundingKind, string> = {
  auto: "Auto-financement",
  cpf: "CPF / Mon Compte Formation",
  opco: "OPCO (entreprise)",
  employeur: "Plan employeur",
  pole_emploi: "France Travail (AIF)",
};

export function fmtEuros(cents: number): string {
  return new Intl.NumberFormat("fr-FR", {
    style: "currency",
    currency: "EUR",
    maximumFractionDigits: 0,
  }).format(cents / 100);
}

export function findPlan(id: string): Plan | undefined {
  return PLANS.find((p) => p.id === id);
}
