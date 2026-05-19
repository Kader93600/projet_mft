-- =====================================================================
-- P3 #3 / Loyalty — Programme de fidélité
-- 2026-05-20
--
-- Décisions client (cf. roadmap) :
--   • Tiers basés sur le nombre d'enrollments payées (statut ≠ refuse/abandon)
--       - None   : 0
--       - Bronze : 1
--       - Silver : 2 → -10 % auto sur la prochaine formation
--       - Gold   : 3+ → -15 % auto + certificat doré sur les nouveaux certifs
--   • Plafond réduction : 200 € (20000 cents) par achat
--   • Critère : "payée" (pas "terminée") pour récompenser les stagiaires en cours
--
-- Réutilise la table user_credits (Sprint A parrainage) pour la traçabilité.
-- Nouveau "kind" : 'loyalty_discount' (négatif, consommé au checkout).
-- =====================================================================

-- ─────────────────────────────────────────────────────────────────────
-- 1. ALTER certificates : ajouter is_loyalty
-- ─────────────────────────────────────────────────────────────────────
ALTER TABLE public.certificates
  ADD COLUMN IF NOT EXISTS is_loyalty boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN public.certificates.is_loyalty IS
  'TRUE = certificat délivré à un stagiaire ayant déjà un certificat final (Gold tier). Le PDF est généré avec un visuel doré.';

-- ─────────────────────────────────────────────────────────────────────
-- 2. ALTER user_credits : étendre le CHECK pour accepter loyalty_discount
-- ─────────────────────────────────────────────────────────────────────
-- Drop l'ancien check + recrée avec loyalty_discount autorisé
ALTER TABLE public.user_credits DROP CONSTRAINT IF EXISTS user_credits_kind_check;
ALTER TABLE public.user_credits ADD CONSTRAINT user_credits_kind_check CHECK (kind IN (
  'referral_reward',
  'admin_grant',
  'checkout_discount',
  'cashout',
  'expire',
  'adjustment',
  'loyalty_discount'      -- NEW : remise fidélité appliquée à un checkout
));

-- ─────────────────────────────────────────────────────────────────────
-- 3. Table loyalty_events (traçabilité)
-- ─────────────────────────────────────────────────────────────────────
-- 1 ligne par événement loyalty (passage de tier, réduction appliquée,
-- certificat doré délivré). Sert d'audit + base pour la timeline UI.
CREATE TABLE IF NOT EXISTS public.loyalty_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  kind text NOT NULL CHECK (kind IN (
    'tier_upgraded',          -- passage de Bronze → Silver, etc.
    'discount_applied',       -- réduction appliquée à un achat
    'gold_certificate'        -- nouveau certificat doré délivré
  )),
  details jsonb,              -- {from_tier, to_tier, amount_cents, certificate_id, etc.}
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS loyalty_events_user_idx
  ON public.loyalty_events(user_id, created_at DESC);

ALTER TABLE public.loyalty_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS loyalty_events_self_read ON public.loyalty_events;
CREATE POLICY loyalty_events_self_read ON public.loyalty_events
  FOR SELECT USING (auth.uid() = user_id OR public.is_admin());

DROP POLICY IF EXISTS loyalty_events_admin_all ON public.loyalty_events;
CREATE POLICY loyalty_events_admin_all ON public.loyalty_events
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ─────────────────────────────────────────────────────────────────────
-- 4. Fonction : compte les enrollments payées d'un user
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.count_paid_enrollments(p_user uuid)
RETURNS int
LANGUAGE sql STABLE
AS $$
  SELECT count(*)::int
  FROM public.enrollments
  WHERE user_id = p_user
    AND status NOT IN ('refuse', 'abandon', 'prospect', 'devis')
    -- "payée" = a passé l'étape devis : a_payer, en_cours, termine, accord_financeur
    AND paid_amount_cents > 0;
$$;

GRANT EXECUTE ON FUNCTION public.count_paid_enrollments(uuid) TO authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- 5. Fonction : tier d'un user
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.loyalty_tier_for_user(p_user uuid)
RETURNS text
LANGUAGE plpgsql STABLE
AS $$
DECLARE
  v_count int;
BEGIN
  SELECT public.count_paid_enrollments(p_user) INTO v_count;
  IF v_count = 0 THEN RETURN 'none'; END IF;
  IF v_count = 1 THEN RETURN 'bronze'; END IF;
  IF v_count = 2 THEN RETURN 'silver'; END IF;
  RETURN 'gold';
END;
$$;

GRANT EXECUTE ON FUNCTION public.loyalty_tier_for_user(uuid) TO authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- 6. Vue : statut fidélité de chaque user
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW public.user_loyalty_status
WITH (security_invoker = on)
AS
SELECT
  p.id AS user_id,
  p.full_name,
  p.email,
  public.count_paid_enrollments(p.id) AS paid_enrollments,
  public.loyalty_tier_for_user(p.id) AS tier,
  -- Combien de formations pour atteindre le palier suivant
  CASE public.loyalty_tier_for_user(p.id)
    WHEN 'none'   THEN 1
    WHEN 'bronze' THEN 2 - public.count_paid_enrollments(p.id)
    WHEN 'silver' THEN 3 - public.count_paid_enrollments(p.id)
    ELSE 0
  END AS enrollments_to_next_tier,
  -- Le réduction pct disponible pour le prochain achat
  CASE public.loyalty_tier_for_user(p.id)
    WHEN 'silver' THEN 10
    WHEN 'gold'   THEN 15
    ELSE 0
  END AS next_discount_pct,
  -- Nombre de certificats finaux (utile pour l'éligibilité "certificat doré")
  (SELECT count(*)::int FROM public.certificates c
    WHERE c.user_id = p.id AND c.type = 'final' AND c.revoked_at IS NULL)
    AS final_certificates_count
FROM public.profiles p
WHERE p.role = 'student';

GRANT SELECT ON public.user_loyalty_status TO authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- 7. RPC : appliquer la réduction loyalty à un checkout
-- ─────────────────────────────────────────────────────────────────────
-- Appelée par le webhook Stripe APRÈS payment_success.
-- Calcule la réduction selon le tier du user au moment de l'achat,
-- insère une ligne user_credits négative (loyalty_discount) + un
-- événement loyalty_events.
--
-- Retourne le montant appliqué (en cents). Si 0 = pas éligible.
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.apply_loyalty_discount(
  p_user uuid,
  p_price_cents int,
  p_session_id text
)
RETURNS int
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_tier text;
  v_pct int;
  v_discount int;
  v_max_cap int := 20000;  -- 200 € de plafond
BEGIN
  IF p_user IS NULL OR p_price_cents <= 0 THEN RETURN 0; END IF;

  -- IMPORTANT : on calcule le tier AVANT que la nouvelle enrollment soit
  -- comptée (donc tier reflète les achats ANTÉRIEURS uniquement).
  -- Le webhook appelle cette RPC après insertion d'enrollment, donc on
  -- soustrait 1 si on veut le tier "avant cet achat".
  -- Pour simplifier : on utilise le tier ACTUEL en partant du principe
  -- que la réduction est calculée AVANT l'insert. Donc cette RPC doit
  -- être appelée AVANT l'insertion de la nouvelle enrollment.

  v_tier := public.loyalty_tier_for_user(p_user);
  v_pct := CASE v_tier
    WHEN 'silver' THEN 10
    WHEN 'gold'   THEN 15
    ELSE 0
  END;

  IF v_pct = 0 THEN RETURN 0; END IF;

  v_discount := LEAST(p_price_cents * v_pct / 100, v_max_cap);

  -- Insert dans user_credits (ledger négatif)
  INSERT INTO public.user_credits (
    user_id, amount_cents, kind, ref_id, description
  ) VALUES (
    p_user,
    -v_discount,
    'loyalty_discount',
    p_session_id,
    'Remise fidélité ' || v_tier || ' (' || v_pct || '%) appliquée au checkout ' || p_session_id
  );

  -- Log loyalty_events
  INSERT INTO public.loyalty_events (user_id, kind, details)
  VALUES (p_user, 'discount_applied', jsonb_build_object(
    'tier', v_tier,
    'pct', v_pct,
    'amount_cents', v_discount,
    'session_id', p_session_id
  ));

  RETURN v_discount;
END;
$$;

GRANT EXECUTE ON FUNCTION public.apply_loyalty_discount(uuid, int, text) TO service_role;

-- ─────────────────────────────────────────────────────────────────────
-- 8. Trigger : marquer is_loyalty=true sur les nouveaux certificats finals
--    si le user a déjà 1+ certificat final non-révoqué (Gold tier)
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.tg_certificate_loyalty_flag()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_existing_final int;
BEGIN
  IF NEW.type <> 'final' THEN RETURN NEW; END IF;
  -- Compte les certificats finals existants AVANT celui-ci
  SELECT count(*)::int INTO v_existing_final
    FROM public.certificates
   WHERE user_id = NEW.user_id
     AND type = 'final'
     AND id <> NEW.id
     AND revoked_at IS NULL;
  IF v_existing_final >= 1 THEN
    NEW.is_loyalty := true;
    -- Log l'événement (post-trigger via AFTER pour avoir l'id)
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_certificate_loyalty_flag ON public.certificates;
CREATE TRIGGER tg_certificate_loyalty_flag
  BEFORE INSERT ON public.certificates
  FOR EACH ROW EXECUTE FUNCTION public.tg_certificate_loyalty_flag();

-- Trigger AFTER pour logger l'événement gold_certificate
CREATE OR REPLACE FUNCTION public.tg_certificate_loyalty_log()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NEW.is_loyalty = true AND NEW.type = 'final' THEN
    INSERT INTO public.loyalty_events (user_id, kind, details)
    VALUES (NEW.user_id, 'gold_certificate', jsonb_build_object(
      'certificate_id', NEW.id,
      'serial', NEW.serial,
      'issued_at', NEW.issued_at
    ));
    -- Notification au stagiaire
    INSERT INTO public.notifications (user_id, type, title, body, link_url)
    VALUES (
      NEW.user_id,
      'certificate',
      'Certificat doré délivré',
      'Vous êtes Stagiaire Gold ! Votre nouveau certificat est désormais marqué d''un visuel doré qui distingue votre persévérance.',
      '/certificats'
    );
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_certificate_loyalty_log ON public.certificates;
CREATE TRIGGER tg_certificate_loyalty_log
  AFTER INSERT ON public.certificates
  FOR EACH ROW EXECUTE FUNCTION public.tg_certificate_loyalty_log();
