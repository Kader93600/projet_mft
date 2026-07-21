-- =====================================================================
-- 2026-07-21 — PAY-01 : idempotence du webhook Stripe
-- =====================================================================
-- Peut être appliqué AVANT ou APRÈS le déploiement du code : le webhook
-- fonctionne sans la table (repli gracieux) mais n'est protégé contre
-- les rejeux qu'une fois ce script exécuté.
--
-- Deux protections :
--   - PK event_id : rejeu du même événement (retry Stripe)
--   - index UNIQUE session_id : le même paiement livré via DEUX types
--     d'événements (checkout.session.completed + async_payment_succeeded)
--     ne crée qu'UNE inscription / ligne de crédit.
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.stripe_events (
  event_id    text PRIMARY KEY,
  session_id  text,
  type        text NOT NULL,
  received_at timestamptz NOT NULL DEFAULT now()
);

-- Unicité par session UNIQUEMENT pour les événements "payés" (le code ne
-- renseigne session_id que pour ceux-là ; NULL = pas de contrainte).
CREATE UNIQUE INDEX IF NOT EXISTS stripe_events_session_uniq
  ON public.stripe_events (session_id)
  WHERE session_id IS NOT NULL;

-- Service-role uniquement : RLS activée sans policy → aucun accès
-- anon / authenticated.
ALTER TABLE public.stripe_events ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON public.stripe_events FROM anon, authenticated;

-- ── Vérifications post-application ───────────────────────────────────
-- SELECT COUNT(*) FROM public.stripe_events;               → 0 (table neuve)
-- Après un paiement test : 1 ligne par événement Stripe, une seule
-- inscription créée même si l'événement est rejoué depuis le dashboard
-- Stripe (Webhooks → Resend).
