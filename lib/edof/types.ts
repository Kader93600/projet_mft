// =====================================================================
// Types du domaine EDOF.
//
// ⚠️ Le cycle de vie ci-dessous est notre MODÈLE de travail, à CONFIRMER
// avec les specs officielles de la CDC une fois l'accès obtenu. Les
// libellés EDOF réels seront mappés ici (adapter HTTP).
// =====================================================================

/**
 * Cycle de vie d'un dossier de formation CPF côté EDOF.
 *   recu            → dossier reçu (titulaire a demandé l'inscription)
 *   accepte         → accepté par l'OF
 *   refuse          → refusé par l'OF
 *   annule          → annulé (titulaire / CDC / délai dépassé)
 *   entree_declaree → entrée en formation déclarée
 *   en_cours        → formation en cours
 *   service_fait    → service fait déclaré (déclenche le paiement)
 *   solde           → payé / clôturé
 */
export type EdofDossierStatus =
  | "recu"
  | "accepte"
  | "refuse"
  | "annule"
  | "entree_declaree"
  | "en_cours"
  | "service_fait"
  | "solde";

export const EDOF_STATUSES: EdofDossierStatus[] = [
  "recu",
  "accepte",
  "refuse",
  "annule",
  "entree_declaree",
  "en_cours",
  "service_fait",
  "solde",
];

export const EDOF_STATUS_LABEL: Record<EdofDossierStatus, string> = {
  recu: "Reçu",
  accepte: "Accepté",
  refuse: "Refusé",
  annule: "Annulé",
  entree_declaree: "Entrée déclarée",
  en_cours: "En cours",
  service_fait: "Service fait",
  solde: "Soldé",
};

/** Dossier EDOF normalisé (sortie de l'adapter, indépendant du format brut). */
export interface EdofDossier {
  /** Identifiant du dossier côté EDOF. */
  edofId: string;
  status: EdofDossierStatus;
  learnerFullName: string | null;
  learnerEmail: string | null;
  formationLabel: string | null;
  amountCents: number | null;
  /** Date de réception/maj côté EDOF (ISO). */
  updatedAt: string | null;
  /** Payload brut conservé pour audit/debug. */
  raw?: unknown;
}

/** Statuts MFT d'une inscription (sous-ensemble utilisé pour le mapping). */
export type MftEnrollmentStatus =
  | "prospect"
  | "en_cours"
  | "refuse"
  | "abandon"
  | "termine";
