-- =====================================================================
-- P3 #2 / Sprint D — Marketplace formateurs externes (SCAFFOLDING v1)
-- 2026-05-19
--
-- ⚠️ SCAFFOLDING UNIQUEMENT. Cette migration pose les fondations mais
-- LA FEATURE COMPLETE NÉCESSITE encore :
--   1. Compte Stripe Connect activé (KYC obligatoire par formateur)
--   2. Configuration legal/CGU "formateurs externes" (droits d'auteur,
--      responsabilité, fiscalité)
--   3. Workflow de modération admin (validation contenu avant publication)
--   4. UI de création de modules par trainer (forms WYSIWYG)
--   5. Marketplace front (vitrine, recherche, achat à l'unité)
--
-- Plan détaillé : docs/p3-2-marketplace-roadmap.md
--
-- En l'état, cette migration permet :
--   • De stocker la PROPRIÉTÉ d'un module (créateur = trainer)
--   • De définir un split de revenu théorique
--   • D'avoir la table pour stocker plus tard les comptes Stripe Connect
--
-- Aucun impact sur les flux existants (toutes les colonnes sont nullable
-- et optionnelles).
-- =====================================================================

-- ─────────────────────────────────────────────────────────────────────
-- 1. Propriété de module : qui l'a créé ?
-- ─────────────────────────────────────────────────────────────────────
-- Un module peut être :
--   • created_by IS NULL  : module officiel MFT (cas actuel pour tous)
--   • created_by = uuid   : module créé par un trainer externe
ALTER TABLE public.modules
  ADD COLUMN IF NOT EXISTS created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS marketplace_status text DEFAULT NULL
    CHECK (marketplace_status IS NULL OR marketplace_status IN (
      'draft',          -- en cours de création par le trainer
      'pending_review', -- soumis à l'équipe MFT pour validation
      'approved',       -- visible dans la marketplace
      'rejected'        -- refusé par MFT (raison stockée ailleurs)
    )),
  ADD COLUMN IF NOT EXISTS marketplace_price_cents int,
  ADD COLUMN IF NOT EXISTS marketplace_published_at timestamptz,
  ADD COLUMN IF NOT EXISTS marketplace_reviewer_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS marketplace_review_notes text;

CREATE INDEX IF NOT EXISTS modules_created_by_idx
  ON public.modules(created_by)
  WHERE created_by IS NOT NULL;
CREATE INDEX IF NOT EXISTS modules_marketplace_idx
  ON public.modules(marketplace_status)
  WHERE marketplace_status IS NOT NULL;

COMMENT ON COLUMN public.modules.created_by IS
  'NULL = module officiel MFT. UUID = module créé par un trainer externe (marketplace).';

-- ─────────────────────────────────────────────────────────────────────
-- 2. Comptes Stripe Connect des formateurs
-- ─────────────────────────────────────────────────────────────────────
-- Stockage des Connect Account IDs Stripe + statut KYC.
-- Nécessaire AVANT de pouvoir verser des paiements à un trainer externe.
CREATE TABLE IF NOT EXISTS public.trainer_payouts (
  user_id uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  -- Stripe Connect
  stripe_connect_account_id text UNIQUE,    -- "acct_..."
  stripe_onboarding_complete boolean DEFAULT false,
  stripe_charges_enabled boolean DEFAULT false,
  stripe_payouts_enabled boolean DEFAULT false,
  -- KYC / conformité
  kyc_status text DEFAULT 'not_started'
    CHECK (kyc_status IN ('not_started', 'pending', 'verified', 'rejected')),
  kyc_updated_at timestamptz,
  -- Revenue split (négocié par contrat)
  revenue_share_pct numeric(5,2) DEFAULT 70.00,  -- % qui revient au trainer
  -- Métadonnées
  contract_signed_at timestamptz,
  contract_url text,
  notes text,                                -- admin only
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.trainer_payouts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS trainer_payouts_admin ON public.trainer_payouts;
CREATE POLICY trainer_payouts_admin ON public.trainer_payouts
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS trainer_payouts_self_read ON public.trainer_payouts;
CREATE POLICY trainer_payouts_self_read ON public.trainer_payouts
  FOR SELECT USING (auth.uid() = user_id);

-- ─────────────────────────────────────────────────────────────────────
-- 3. Historique des reversements (revenue splits effectifs)
-- ─────────────────────────────────────────────────────────────────────
-- Une ligne par paiement entrant sur un module marketplace, on garde
-- la trace du split appliqué pour audit comptable.
CREATE TABLE IF NOT EXISTS public.trainer_revenue_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  trainer_user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  module_id uuid REFERENCES public.modules(id) ON DELETE SET NULL,
  enrollment_id uuid REFERENCES public.enrollments(id) ON DELETE SET NULL,
  -- Montants
  gross_amount_cents int NOT NULL,           -- montant total payé par le stagiaire
  platform_fee_cents int NOT NULL,           -- part MFT
  trainer_share_cents int NOT NULL,          -- part trainer (= gross - platform_fee)
  -- Stripe
  stripe_session_id text,
  stripe_transfer_id text UNIQUE,            -- l'ID du Stripe Transfer (quand effectué)
  status text NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'transferred', 'failed', 'reversed')),
  transferred_at timestamptz,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS trainer_revenue_events_trainer_idx
  ON public.trainer_revenue_events(trainer_user_id, created_at DESC);

ALTER TABLE public.trainer_revenue_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS trainer_revenue_events_admin ON public.trainer_revenue_events;
CREATE POLICY trainer_revenue_events_admin ON public.trainer_revenue_events
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS trainer_revenue_events_self_read ON public.trainer_revenue_events;
CREATE POLICY trainer_revenue_events_self_read ON public.trainer_revenue_events
  FOR SELECT USING (auth.uid() = trainer_user_id);

-- ─────────────────────────────────────────────────────────────────────
-- 4. Vue agrégée : revenus par trainer
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW public.trainer_revenue_summary
WITH (security_invoker = on)
AS
SELECT
  tre.trainer_user_id,
  p.full_name AS trainer_name,
  count(*)::int AS events_count,
  SUM(tre.gross_amount_cents)::int AS gross_total_cents,
  SUM(tre.platform_fee_cents)::int AS platform_fee_total_cents,
  SUM(tre.trainer_share_cents)::int AS trainer_share_total_cents,
  SUM(tre.trainer_share_cents) FILTER (WHERE tre.status = 'transferred')::int AS paid_to_trainer_cents,
  SUM(tre.trainer_share_cents) FILTER (WHERE tre.status = 'pending')::int AS pending_to_trainer_cents
FROM public.trainer_revenue_events tre
JOIN public.profiles p ON p.id = tre.trainer_user_id
GROUP BY tre.trainer_user_id, p.full_name;

GRANT SELECT ON public.trainer_revenue_summary TO authenticated;
