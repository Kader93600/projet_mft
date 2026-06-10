// =====================================================================
// Configuration des régies publicitaires (acquisition payante).
//
// DORMANT tant que les IDs ne sont pas renseignés en variables d'env :
// chaque future intégration (pixel navigateur + Conversions API
// server-side) se contente d'un no-op si son ID / token est absent. Le
// code peut donc être livré AVANT l'ouverture des comptes Ads ;
// l'activation se fera uniquement en posant les variables d'environnement
// (cf. docs/marketing-tracking.md), sans changement de logique.
//
// ⚠️ Aucun secret ici : seuls les IDs `NEXT_PUBLIC_*` sont exposables au
// navigateur. Les tokens server-side (CAPI) restent server-only et ne
// doivent JAMAIS être préfixés `NEXT_PUBLIC_`.
// =====================================================================

/** IDs publics (pixels navigateur). null tant que non configurés. */
export const META_PIXEL_ID = process.env.NEXT_PUBLIC_META_PIXEL_ID || null;
export const GA4_MEASUREMENT_ID = process.env.NEXT_PUBLIC_GA4_ID || null;
export const GOOGLE_ADS_ID = process.env.NEXT_PUBLIC_GOOGLE_ADS_ID || null;
export const TIKTOK_PIXEL_ID = process.env.NEXT_PUBLIC_TIKTOK_PIXEL_ID || null;

/** Une régie est-elle activable côté navigateur ? (ID public présent). */
export const metaPixelEnabled = !!META_PIXEL_ID;
export const googleEnabled = !!(GA4_MEASUREMENT_ID || GOOGLE_ADS_ID);
export const tiktokPixelEnabled = !!TIKTOK_PIXEL_ID;

/**
 * Secrets server-only (Conversions API). Ne JAMAIS importer depuis un
 * composant client : lit des variables sans préfixe public.
 */
export function getServerAdsConfig() {
  const metaPixelId = META_PIXEL_ID;
  const metaAccessToken = process.env.META_CAPI_ACCESS_TOKEN || null;
  return {
    metaCapi: {
      pixelId: metaPixelId,
      accessToken: metaAccessToken,
      // Optionnel : Events Manager → Test Events.
      testEventCode: process.env.META_CAPI_TEST_EVENT_CODE || null,
      enabled: !!(metaPixelId && metaAccessToken),
    },
    // Google (Enhanced Conversions / Offline Conversion Import) et
    // TikTok Events API seront ajoutés en Phase 2/3.
  };
}
