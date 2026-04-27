// Résolveur de "formation effective" pour un enrollment.
// Si l'enrollment a un formation_slug → on injecte le titre, le code RNCP,
// les objectifs et prérequis du catalogue (sauf si l'admin a déjà saisi
// ces champs sur le dossier, auquel cas on respecte ses valeurs).

import { findFormation } from "./formations-config";
import { LEGAL } from "./legal-config";

export interface ResolvedFormation {
  /** Titre complet à afficher (jamais vide). */
  title: string;
  /** Code court — affichage compact ("GOTRM", "FIMO/FCO", …). */
  code: string;
  /** Code RNCP s'il existe (sinon undefined). */
  rncpCode?: string;
  /** Objectifs pédagogiques (paragraphe ou puces). */
  objectives: string;
  /** Prérequis. */
  prerequisites: string;
  /** Heures totales si renseignées. */
  hoursTotal: number | null;
  /** Modalité (presentiel / distanciel / mixte). */
  modality: "presentiel" | "distanciel" | "mixte";
  /** Lieu (ou "À distance — plateforme"). */
  location: string;
}

const DEFAULT_OBJECTIVES =
  "Acquérir les compétences nécessaires à l'obtention de la certification ou de l'attestation visée et à l'exercice professionnel correspondant.";
const DEFAULT_PREREQUISITES = "Aucun prérequis spécifique sauf indication contraire.";

export function resolveEnrollmentFormation(e: any): ResolvedFormation {
  const slug = e?.formation_slug ?? null;
  const fromCatalog = slug ? findFormation(slug) : undefined;

  // Priorité : champ saisi par l'admin > catalogue > défaut LEGAL (GOTRM)
  const title =
    e?.session_label?.trim() ||
    fromCatalog?.title ||
    `Préparation au titre ${LEGAL.rncpCode}`;

  const code = fromCatalog?.code ?? LEGAL.rncpCode;
  const rncpCode = fromCatalog?.rncpCode ?? LEGAL.rncpCode;

  const objectives =
    (e?.objectives && String(e.objectives).trim()) ||
    (fromCatalog ? fromCatalog.objectives.join(" ") : DEFAULT_OBJECTIVES);

  const prerequisites =
    (e?.prerequisites && String(e.prerequisites).trim()) ||
    fromCatalog?.prerequisites ||
    DEFAULT_PREREQUISITES;

  const modality =
    (e?.modality as ResolvedFormation["modality"]) ??
    fromCatalog?.modality ??
    "distanciel";

  const location =
    e?.location?.trim() ||
    (modality === "presentiel"
      ? `${LEGAL.address.street}, ${LEGAL.address.postalCode} ${LEGAL.address.city}`
      : `Plateforme ${LEGAL.brand} — ${LEGAL.website}`);

  return {
    title,
    code,
    rncpCode,
    objectives,
    prerequisites,
    hoursTotal: e?.hours_total ?? null,
    modality,
    location,
  };
}
