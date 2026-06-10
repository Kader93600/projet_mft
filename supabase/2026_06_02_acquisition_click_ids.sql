-- =====================================================================
-- Marketing acquisition — Phase 0 : capture des click-IDs publicitaires
-- 2026-06-02
--
-- Contexte (cf. docs/marketing-tracking.md) :
--   Lancement de l'acquisition payante (Meta / Google / TikTok). Le modèle
--   est à conversion DIFFÉRÉE : le form-fill est un « Lead », la vraie
--   conversion (inscription financée) tombe plus tard dans le CRM. Pour
--   remonter cette conversion offline au BON clic, il faut stocker les
--   identifiants de clic (click-IDs) émis par les régies.
--
--   • Aucune régie n'est encore branchée : ces colonnes se rempliront dès
--     qu'une campagne enverra du trafic avec ?gclid=… / ?fbclid=… etc.
--   • Capture : sur acquisition_events (à chaque visite publique).
--   • Snapshot : figé sur enrollment_requests à la soumission du lead
--     (auto-suffisant pour la future remontée offline — Phase 3).
--
-- Click-IDs couverts :
--   gclid / gbraid / wbraid  → Google Ads
--   fbclid                   → Meta (Facebook / Instagram)
--   ttclid                   → TikTok
--   msclkid                  → Microsoft Advertising (Bing)
--
-- Ajout de colonnes NULLABLE uniquement → aucune vue ni policy impactée
-- (les vues d'attribution listent des colonnes explicites, pas SELECT *).
-- =====================================================================

-- ─────────────────────────────────────────────────────────────────────
-- 1. acquisition_events — click-IDs captés à la visite
-- ─────────────────────────────────────────────────────────────────────
ALTER TABLE public.acquisition_events
  ADD COLUMN IF NOT EXISTS gclid   text,   -- Google Ads click id
  ADD COLUMN IF NOT EXISTS gbraid  text,   -- Google click id (app→web, iOS)
  ADD COLUMN IF NOT EXISTS wbraid  text,   -- Google click id (web, iOS)
  ADD COLUMN IF NOT EXISTS fbclid  text,   -- Meta click id
  ADD COLUMN IF NOT EXISTS ttclid  text,   -- TikTok click id
  ADD COLUMN IF NOT EXISTS msclkid text;   -- Microsoft Ads click id

-- ─────────────────────────────────────────────────────────────────────
-- 2. enrollment_requests — snapshot d'attribution figé sur le lead
-- ─────────────────────────────────────────────────────────────────────
-- visitor_id : relie le lead à son parcours dans acquisition_events
--              (le cookie mft_vid n'était pas stocké sur le lead jusqu'ici).
-- click-IDs  : figés à la soumission, pour la remontée offline (Phase 3).
-- utm_*      : first-touch, pour afficher la source du lead dans le CRM.
-- ─────────────────────────────────────────────────────────────────────
ALTER TABLE public.enrollment_requests
  ADD COLUMN IF NOT EXISTS visitor_id   text,
  ADD COLUMN IF NOT EXISTS gclid        text,
  ADD COLUMN IF NOT EXISTS gbraid       text,
  ADD COLUMN IF NOT EXISTS wbraid       text,
  ADD COLUMN IF NOT EXISTS fbclid       text,
  ADD COLUMN IF NOT EXISTS ttclid       text,
  ADD COLUMN IF NOT EXISTS msclkid      text,
  ADD COLUMN IF NOT EXISTS utm_source   text,
  ADD COLUMN IF NOT EXISTS utm_medium   text,
  ADD COLUMN IF NOT EXISTS utm_campaign text;

-- Index partiel : retrouver les leads rattachés à un visiteur
-- (dédup, debug d'attribution, futur rapprochement offline).
CREATE INDEX IF NOT EXISTS enrollment_requests_visitor_idx
  ON public.enrollment_requests(visitor_id)
  WHERE visitor_id IS NOT NULL;
