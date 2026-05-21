// =====================================================================
// Machine à états du cycle de vie d'un dossier EDOF + mapping vers les
// statuts d'inscription MFT. 100% PUR (testable, sans I/O).
//
// C'est le "cerveau" de l'intégration : il sera réutilisé tel quel quand
// l'adapter HTTP réel sera branché. Seuls les libellés EDOF bruts
// (côté adapter) restent à confirmer avec les specs CDC.
// =====================================================================

import type { EdofDossierStatus, MftEnrollmentStatus } from "./types";

/** Transitions autorisées du cycle de vie EDOF. */
const TRANSITIONS: Record<EdofDossierStatus, EdofDossierStatus[]> = {
  recu: ["accepte", "refuse", "annule"],
  accepte: ["entree_declaree", "annule"],
  entree_declaree: ["en_cours", "annule"],
  en_cours: ["service_fait", "annule"],
  service_fait: ["solde"],
  // États terminaux
  refuse: [],
  annule: [],
  solde: [],
};

/** Vrai si la transition `from → to` est permise. */
export function canTransition(
  from: EdofDossierStatus,
  to: EdofDossierStatus,
): boolean {
  return TRANSITIONS[from]?.includes(to) ?? false;
}

/** États terminaux (plus aucune action possible). */
export function isTerminal(status: EdofDossierStatus): boolean {
  return TRANSITIONS[status]?.length === 0;
}

// ── Actions métier disponibles selon l'état courant ──────────────────
export function canAccept(status: EdofDossierStatus): boolean {
  return canTransition(status, "accepte");
}
export function canRefuse(status: EdofDossierStatus): boolean {
  return canTransition(status, "refuse");
}
export function canDeclareEntry(status: EdofDossierStatus): boolean {
  return canTransition(status, "entree_declaree");
}
export function canDeclareServiceFait(status: EdofDossierStatus): boolean {
  return canTransition(status, "service_fait");
}

/**
 * Mappe un statut EDOF vers le statut d'inscription MFT correspondant.
 * Conservateur : on ne "termine" qu'au service fait / soldé.
 */
export function edofStatusToMft(
  status: EdofDossierStatus,
): MftEnrollmentStatus {
  switch (status) {
    case "recu":
      return "prospect";
    case "accepte":
    case "entree_declaree":
    case "en_cours":
      return "en_cours";
    case "service_fait":
    case "solde":
      return "termine";
    case "refuse":
      return "refuse";
    case "annule":
      return "abandon";
  }
}

/**
 * Prochaine(s) action(s) suggérée(s) à l'OF pour faire avancer le dossier
 * (pour l'UI : "à traiter", "déclarer l'entrée", etc.).
 */
export function nextActionLabel(status: EdofDossierStatus): string | null {
  switch (status) {
    case "recu":
      return "À traiter (accepter ou refuser)";
    case "accepte":
      return "Déclarer l'entrée en formation";
    case "entree_declaree":
    case "en_cours":
      return "Déclarer le service fait à la fin";
    case "service_fait":
      return "En attente de paiement (soldé)";
    default:
      return null; // terminal
  }
}
