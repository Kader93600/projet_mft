// =====================================================================
// Consentement marketing/publicité — helper CLIENT.
//
// Source de vérité côté navigateur : le choix stocké par la bannière
// cookies dans localStorage (clé gotrm.cookie.consent.v1). Les pixels
// publicitaires (Meta / Google / TikTok) NE DOIVENT s'initialiser que si
// hasMarketingConsent() renvoie true — exigence CNIL : consentement
// préalable pour les traceurs publicitaires.
//
// Défaut prudent : false (aucun choix enregistré ⇒ pas de pixel).
// =====================================================================

const STORAGE_KEY = "gotrm.cookie.consent.v1";

export type ConsentChoice = {
  essential: boolean;
  analytics: boolean;
  marketing: boolean;
  communications: boolean;
  newsletter: boolean;
};

/** Lit le choix de consentement stocké par la bannière (ou null). */
export function readConsent(): Partial<ConsentChoice> | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    return JSON.parse(raw) as Partial<ConsentChoice>;
  } catch {
    return null;
  }
}

/** Consentement publicitaire accordé ? (défaut : false). */
export function hasMarketingConsent(): boolean {
  return readConsent()?.marketing === true;
}

/** Consentement mesure d'audience accordé ? (défaut : false). */
export function hasAnalyticsConsent(): boolean {
  return readConsent()?.analytics === true;
}
