# Marketing & tracking acquisition — runbook

> Volet acquisition payante (Meta / Google / TikTok) de MA FORMATION TRANSPORT.
> Cadrage : `2026-06-02`. Voir aussi `docs/p3-3-marketing-data.md` (tracking 1ʳᵉ partie historique).

## Modèle : conversion différée

Le formulaire `/contact` produit un **Lead** (`enrollment_requests`). La vraie
conversion — une **inscription financée** (~2 000–4 000 €) — tombe plus tard
dans le CRM, après qualification + accord de financement.

➡️ **On optimise les campagnes sur l'inscription, pas sur le form-fill.** Sinon
les algos vont chercher les leads les moins chers (donc les moins qualifiés).
C'est tout l'enjeu de la « boucle offline » (Phase 3).

## Architecture en 5 couches

| # | Couche | État |
|---|--------|------|
| 0 | **Capture click-IDs** (gclid/gbraid/wbraid, fbclid, ttclid, msclkid) bout-en-bout + snapshot sur le lead | ✅ livré |
| 1 | **Pixels navigateur** (Meta/Google/TikTok), gated par consentement, event `Lead` au submit, dédup `event_id` | ⏳ à faire |
| 2 | **Conversions API server-side** depuis `/api/contact` (event `Lead`, PII hashée, fbc/fbp, dédup) | ⏳ à faire |
| 3 | **Conversion offline** : au passage d'un lead en « gagné/inscrit » → upload Meta CAPI + Google Offline Import (via click-ID) + valeur € | ⏳ à faire |
| 4 | **Consent Mode v2 (Google) + gating Meta** sur la catégorie `marketing` | ⏳ Phase 1 |
| 5 | **Restitution** CPA & lead→inscription par canal dans `/admin/analytics/acquisition` | ⏳ à faire |

## Phase 0 — livré (sans compte Ads)

- **Capture** : `lib/acquisition-client.ts` lit les click-IDs de l'URL →
  `POST /api/acquisition/track` → colonnes `acquisition_events.{gclid,gbraid,wbraid,fbclid,ttclid,msclkid}`.
- **Snapshot lead** : à la soumission du contact, `getAcquisitionSnapshot()`
  (`lib/acquisition.ts`) fige sur `enrollment_requests` le `visitor_id`, les
  click-IDs (last-touch) et les UTM (first-touch). Récupéré **côté serveur via
  le cookie `mft_vid`**, donc robuste même si l'URL a perdu les params.
- **Consentement** : nouvelle catégorie **« Publicité » (`marketing`)** dans la
  bannière cookies (décochée par défaut, opt-in). Helper de gating :
  `hasMarketingConsent()` (`lib/marketing/consent.ts`).
- **Migration** : `supabase/2026_06_02_acquisition_click_ids.sql`.

> ⚠️ Après application en base : régénérer les types via
> `node scripts/introspect-schema.mjs` (nécessite `.env.local`). Le baseline
> `supabase/schema.sql` et `lib/database.types.ts` ont déjà été mis à jour à la
> main pour rester cohérents en attendant.

## Activation (quand les comptes Ads sont ouverts)

Tout est piloté par variables d'environnement (`lib/marketing/ads-config.ts`) :
aucune régie ne s'initialise tant que son ID est absent.

| Variable | Type | Régie |
|----------|------|-------|
| `NEXT_PUBLIC_META_PIXEL_ID` | public | Meta Pixel (navigateur) |
| `META_CAPI_ACCESS_TOKEN` | **secret server-only** | Meta Conversions API |
| `META_CAPI_TEST_EVENT_CODE` | secret (optionnel) | Meta — Test Events |
| `NEXT_PUBLIC_GA4_ID` | public | Google Analytics 4 |
| `NEXT_PUBLIC_GOOGLE_ADS_ID` | public | Google Ads (gtag) |
| `NEXT_PUBLIC_TIKTOK_PIXEL_ID` | public | TikTok Pixel |

> 🔒 Ne JAMAIS préfixer un token `NEXT_PUBLIC_` (exposé au navigateur).

## Conformité (CNIL / RGPD)

- **Démarchage CPF interdit** (loi déc. 2022) → funnel 100 % inbound : l'Ads
  amène vers un formulaire rempli par le prospect, jamais d'appel à froid.
- **Reste à charge ~100 €** sur le CPF depuis mai 2024 (sauf demandeurs
  d'emploi / abondement) → pas de promesse « 0 € » non nuancée dans les créas.
- **Consentement préalable** obligatoire pour les pixels publicitaires : les
  intégrations Phase 1 doivent gater sur `hasMarketingConsent()` (+ Consent
  Mode v2 côté Google).
- **Remontée offline** : ne remonter que les leads ayant consenti, et vérifier
  que le wording du consentement du formulaire couvre l'usage publicitaire.
