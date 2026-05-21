// =====================================================================
// Configuration EDOF (Espace Des Organismes De Formation — Caisse des
// Dépôts / Mon Compte Formation).
//
// L'accès API EDOF dépend d'une habilitation CDC (en cours côté client).
// Tant que les variables ne sont pas définies, l'intégration reste
// INERTE (aucun appel réseau) — l'app fonctionne normalement.
//
// Variables attendues (à renseigner quand la CDC a délivré l'accès) :
//   EDOF_API_BASE_URL   base de l'API EDOF (fournie par la CDC)
//   EDOF_CLIENT_ID      identifiant OAuth2 client_credentials
//   EDOF_CLIENT_SECRET  secret OAuth2
//   EDOF_OF_SIRET       SIRET de l'organisme de formation
//   FEATURE_EDOF=true   active l'UI/cron EDOF côté app
// =====================================================================

export interface EdofConfig {
  baseUrl: string;
  clientId: string;
  clientSecret: string;
  ofSiret: string;
}

/** Lit la config EDOF depuis l'environnement (jamais exposée au client). */
export function getEdofConfig(): EdofConfig | null {
  const baseUrl = process.env.EDOF_API_BASE_URL;
  const clientId = process.env.EDOF_CLIENT_ID;
  const clientSecret = process.env.EDOF_CLIENT_SECRET;
  const ofSiret = process.env.EDOF_OF_SIRET;
  if (!baseUrl || !clientId || !clientSecret || !ofSiret) return null;
  return { baseUrl, clientId, clientSecret, ofSiret };
}

/** Vrai si toutes les variables EDOF sont présentes. */
export function isEdofConfigured(): boolean {
  return getEdofConfig() !== null;
}

/** Feature flag UI/cron (indépendant de la présence des credentials). */
export function isEdofFeatureEnabled(): boolean {
  return process.env.FEATURE_EDOF === "true";
}
