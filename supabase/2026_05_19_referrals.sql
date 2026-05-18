-- =====================================================================
-- P3 #2 / Sprint A — Programme de parrainage
-- 2026-05-19
--
-- Décisions client (cf. docs/p3-2-business.md) :
--   • Récompense parrain  : 50 € de crédit (ou cashback si rien à acheter)
--   • Récompense filleul  : −10 % sur la 1re inscription
--   • Déclenchement       : à la 1re inscription PAYÉE du filleul
--   • Plafond             : 10 parrainages/parrain/an
--   • Validation admin    : systématique en v1 (anti-fraude manuel)
--
-- 3 tables :
--   • referral_codes      : 1 code par stagiaire (généré à la demande)
--   • referrals           : 1 ligne par filleul inscrit
--   • user_credits        : portefeuille crédit (débit/crédit, historique)
-- =====================================================================

-- ─────────────────────────────────────────────────────────────────────
-- 1. referral_codes : 1 code unique par utilisateur
-- ─────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.referral_codes (
  user_id uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  code text UNIQUE NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  active boolean NOT NULL DEFAULT true
);

ALTER TABLE public.referral_codes ENABLE ROW LEVEL SECURITY;

-- Lecture : tous les authentifiés peuvent lire un code (pour valider à la saisie),
-- MAIS uniquement le propriétaire voit le sien dans /parrainage.
-- → policy lecture publique sur la table mais code utilisé via RPC sécurisée.
DROP POLICY IF EXISTS referral_codes_self ON public.referral_codes;
CREATE POLICY referral_codes_self ON public.referral_codes
  FOR SELECT USING (auth.uid() = user_id OR public.is_admin());

DROP POLICY IF EXISTS referral_codes_admin ON public.referral_codes;
CREATE POLICY referral_codes_admin ON public.referral_codes
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ─────────────────────────────────────────────────────────────────────
-- 2. referrals : 1 ligne par filleul rattaché à un parrain
-- ─────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.referrals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  referred_user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  code_used text NOT NULL,
  status text NOT NULL CHECK (status IN ('pending', 'qualified', 'rewarded', 'rejected')),
  -- pending     : filleul a saisi le code mais n'a pas encore payé
  -- qualified   : filleul a payé → parrain peut être récompensé (en attente admin)
  -- rewarded    : admin a validé, le crédit 50 € est attribué au parrain
  -- rejected    : admin a refusé (fraude, doublon, etc.)
  enrollment_id uuid REFERENCES public.enrollments(id) ON DELETE SET NULL,
  reward_cents int,                                    -- 5000 = 50€ par défaut
  rewarded_at timestamptz,
  rewarded_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  rejection_reason text,
  created_at timestamptz NOT NULL DEFAULT now(),
  -- Garde-fou : 1 stagiaire ne peut être référé qu'une seule fois
  UNIQUE (referred_user_id)
);

CREATE INDEX IF NOT EXISTS referrals_referrer_idx
  ON public.referrals(referrer_id, status);
CREATE INDEX IF NOT EXISTS referrals_pending_idx
  ON public.referrals(status, created_at)
  WHERE status = 'qualified';

-- Anti-self-referral : trigger qui bloque referrer_id = referred_user_id
CREATE OR REPLACE FUNCTION public.tg_referrals_block_self()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.referrer_id = NEW.referred_user_id THEN
    RAISE EXCEPTION 'self_referral_forbidden';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_referrals_block_self ON public.referrals;
CREATE TRIGGER tg_referrals_block_self
  BEFORE INSERT OR UPDATE ON public.referrals
  FOR EACH ROW EXECUTE FUNCTION public.tg_referrals_block_self();

ALTER TABLE public.referrals ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS referrals_self_read ON public.referrals;
CREATE POLICY referrals_self_read ON public.referrals
  FOR SELECT USING (
    auth.uid() = referrer_id
    OR auth.uid() = referred_user_id
    OR public.is_admin()
  );

DROP POLICY IF EXISTS referrals_admin_all ON public.referrals;
CREATE POLICY referrals_admin_all ON public.referrals
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ─────────────────────────────────────────────────────────────────────
-- 3. user_credits : portefeuille crédit (ledger débit/crédit)
-- ─────────────────────────────────────────────────────────────────────
-- Modèle event-sourced : on ne stocke pas un solde calculé mais
-- l'historique complet des opérations. Le solde est dérivé de la somme.
-- Avantage : auditabilité, anti-fraude facile, RGPD propre.
CREATE TABLE IF NOT EXISTS public.user_credits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  amount_cents int NOT NULL,
  -- > 0 = crédit ajouté (récompense parrainage, geste commercial)
  -- < 0 = crédit consommé (réduction sur un checkout)
  kind text NOT NULL CHECK (kind IN (
    'referral_reward',  -- crédit gagné via parrainage (50€)
    'admin_grant',      -- crédit accordé manuellement par admin
    'checkout_discount',-- débit lors d'un achat
    'cashout',          -- débit lors d'un virement cashback
    'expire',           -- crédit expiré (jamais utilisé)
    'adjustment'        -- correction comptable manuelle
  )),
  ref_id text,          -- ex: referral.id, enrollment.id, stripe_session.id
  description text,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS user_credits_user_idx
  ON public.user_credits(user_id, created_at DESC);

ALTER TABLE public.user_credits ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS user_credits_self_read ON public.user_credits;
CREATE POLICY user_credits_self_read ON public.user_credits
  FOR SELECT USING (auth.uid() = user_id OR public.is_admin());

DROP POLICY IF EXISTS user_credits_admin_all ON public.user_credits;
CREATE POLICY user_credits_admin_all ON public.user_credits
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- Vue agrégée : solde de chaque user (en cents)
CREATE OR REPLACE VIEW public.user_credit_balance AS
SELECT
  p.id AS user_id,
  COALESCE(SUM(c.amount_cents), 0)::int AS balance_cents
FROM public.profiles p
LEFT JOIN public.user_credits c ON c.user_id = p.id
GROUP BY p.id;

GRANT SELECT ON public.user_credit_balance TO authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- 4. RPC : get_or_create_referral_code
-- ─────────────────────────────────────────────────────────────────────
-- Retourne le code de parrainage de l'utilisateur courant. Le crée
-- (idempotent) s'il n'existe pas. Format : MFT-{HASH8} où HASH8 est
-- un hash court basé sur user_id pour être lisible mais imprévisible.
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.get_or_create_referral_code(p_user uuid DEFAULT NULL)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user uuid := COALESCE(p_user, auth.uid());
  v_code text;
  v_hash text;
BEGIN
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'unauthenticated';
  END IF;
  -- Seul l'utilisateur courant ou un admin peut générer un code
  IF v_user <> auth.uid() AND NOT public.is_admin() THEN
    RAISE EXCEPTION 'forbidden';
  END IF;

  SELECT code INTO v_code
    FROM public.referral_codes
   WHERE user_id = v_user;

  IF v_code IS NOT NULL THEN
    RETURN v_code;
  END IF;

  -- Génération d'un code court lisible : MFT-{8 caractères}
  -- On utilise md5(user_id || random) et on garde 8 chars [A-Z0-9].
  v_hash := upper(substring(
    encode(digest(v_user::text || gen_random_uuid()::text, 'sha256'), 'hex')
    from 1 for 8
  ));
  v_code := 'MFT-' || v_hash;

  INSERT INTO public.referral_codes (user_id, code)
  VALUES (v_user, v_code)
  ON CONFLICT (user_id) DO NOTHING
  RETURNING code INTO v_code;

  -- Race condition possible : si on a perdu la course, on relit
  IF v_code IS NULL THEN
    SELECT code INTO v_code FROM public.referral_codes WHERE user_id = v_user;
  END IF;

  RETURN v_code;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_or_create_referral_code(uuid) TO authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- 5. RPC : validate_referral_code (appelée au checkout)
-- ─────────────────────────────────────────────────────────────────────
-- Reçoit le code saisi par le filleul + son user_id. Retourne :
--   - valid    : booléen
--   - referrer : uuid du parrain (si valide)
--   - reason   : raison du refus (si invalide)
-- Conditions de refus :
--   - code inexistant ou désactivé
--   - parrain = filleul
--   - filleul a déjà un parrainage en cours
--   - parrain a déjà atteint son plafond (10/an)
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.validate_referral_code(
  p_code text,
  p_new_user uuid DEFAULT NULL
)
RETURNS TABLE (valid boolean, referrer_id uuid, reason text)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
  v_new_user uuid := COALESCE(p_new_user, auth.uid());
  v_referrer uuid;
  v_referrals_this_year int;
  v_existing uuid;
BEGIN
  IF v_new_user IS NULL THEN
    RETURN QUERY SELECT false, NULL::uuid, 'unauthenticated';
    RETURN;
  END IF;

  -- 1. Le code existe et est actif ?
  SELECT user_id INTO v_referrer
    FROM public.referral_codes
   WHERE code = upper(trim(p_code)) AND active = true;

  IF v_referrer IS NULL THEN
    RETURN QUERY SELECT false, NULL::uuid, 'code_unknown';
    RETURN;
  END IF;

  -- 2. Anti-self-referral
  IF v_referrer = v_new_user THEN
    RETURN QUERY SELECT false, NULL::uuid, 'self_referral';
    RETURN;
  END IF;

  -- 3. Filleul déjà parrainé ?
  SELECT id INTO v_existing FROM public.referrals WHERE referred_user_id = v_new_user;
  IF v_existing IS NOT NULL THEN
    RETURN QUERY SELECT false, NULL::uuid, 'already_referred';
    RETURN;
  END IF;

  -- 4. Plafond parrain (10 parrainages 'qualified' ou 'rewarded' sur 365 jours)
  SELECT count(*) INTO v_referrals_this_year
    FROM public.referrals
   WHERE referrer_id = v_referrer
     AND status IN ('qualified', 'rewarded')
     AND created_at >= now() - INTERVAL '365 days';
  IF v_referrals_this_year >= 10 THEN
    RETURN QUERY SELECT false, NULL::uuid, 'referrer_quota_exceeded';
    RETURN;
  END IF;

  -- OK
  RETURN QUERY SELECT true, v_referrer, NULL::text;
END;
$$;

GRANT EXECUTE ON FUNCTION public.validate_referral_code(text, uuid) TO authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- 6. RPC : create_pending_referral
-- ─────────────────────────────────────────────────────────────────────
-- Crée la ligne 'pending' dans referrals quand un user s'inscrit avec
-- un code (avant d'avoir payé). Appelé depuis le webhook checkout.session.completed
-- ou depuis /api/referrals/validate avant Stripe (sécurité belt + suspenders).
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.create_pending_referral(
  p_code text,
  p_referred_user uuid
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_validation record;
  v_referral_id uuid;
BEGIN
  SELECT * INTO v_validation FROM public.validate_referral_code(p_code, p_referred_user);
  IF NOT v_validation.valid THEN
    RAISE EXCEPTION 'referral_invalid: %', v_validation.reason;
  END IF;

  INSERT INTO public.referrals (referrer_id, referred_user_id, code_used, status)
  VALUES (v_validation.referrer_id, p_referred_user, upper(trim(p_code)), 'pending')
  ON CONFLICT (referred_user_id) DO NOTHING
  RETURNING id INTO v_referral_id;

  RETURN v_referral_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_pending_referral(text, uuid) TO authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- 7. RPC : qualify_referral (appelée par webhook Stripe après paiement)
-- ─────────────────────────────────────────────────────────────────────
-- Passe le referral du filleul de 'pending' à 'qualified' lorsqu'il
-- a payé sa 1re inscription. À ce stade le parrain n'a pas encore son
-- crédit — l'admin doit le valider via /admin/referrals.
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.qualify_referral(
  p_referred_user uuid,
  p_enrollment_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.referrals
     SET status = 'qualified',
         enrollment_id = p_enrollment_id
   WHERE referred_user_id = p_referred_user
     AND status = 'pending';

  -- Notifie l'admin via la table notifications (visible dans /admin/referrals)
  -- (pas nécessaire : la liste est triable par status='qualified' directement)
END;
$$;

GRANT EXECUTE ON FUNCTION public.qualify_referral(uuid, uuid) TO authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- 8. RPC : reward_referral (appelée par admin depuis /admin/referrals)
-- ─────────────────────────────────────────────────────────────────────
-- L'admin valide le parrainage : on insère un crédit 50€ pour le parrain
-- et on passe le referral en 'rewarded'. Atomique.
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.reward_referral(
  p_referral_id uuid,
  p_amount_cents int DEFAULT 5000
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_referral record;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'forbidden';
  END IF;

  SELECT * INTO v_referral FROM public.referrals WHERE id = p_referral_id;
  IF v_referral IS NULL THEN
    RAISE EXCEPTION 'referral_not_found';
  END IF;
  IF v_referral.status <> 'qualified' THEN
    RAISE EXCEPTION 'referral_not_qualified: status=%', v_referral.status;
  END IF;

  -- 1. Crédit au parrain
  INSERT INTO public.user_credits (
    user_id, amount_cents, kind, ref_id, description, created_by
  ) VALUES (
    v_referral.referrer_id,
    p_amount_cents,
    'referral_reward',
    v_referral.id::text,
    'Récompense parrainage — filleul ' || v_referral.referred_user_id::text,
    auth.uid()
  );

  -- 2. Met à jour la ligne referrals
  UPDATE public.referrals
     SET status = 'rewarded',
         reward_cents = p_amount_cents,
         rewarded_at = now(),
         rewarded_by = auth.uid()
   WHERE id = p_referral_id;

  -- 3. Notification au parrain
  INSERT INTO public.notifications (user_id, type, title, body, link_url)
  VALUES (
    v_referral.referrer_id,
    'announcement',
    'Récompense parrainage : +50 €',
    'Votre filleul a démarré sa formation. Vous gagnez 50 € de crédit applicable sur votre prochaine inscription.',
    '/parrainage'
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.reward_referral(uuid, int) TO authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- 9. RPC : reject_referral (admin refuse)
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.reject_referral(
  p_referral_id uuid,
  p_reason text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'forbidden';
  END IF;
  IF coalesce(trim(p_reason), '') = '' THEN
    RAISE EXCEPTION 'reason_required';
  END IF;

  UPDATE public.referrals
     SET status = 'rejected',
         rejection_reason = p_reason,
         rewarded_at = now(),
         rewarded_by = auth.uid()
   WHERE id = p_referral_id AND status = 'qualified';
END;
$$;

GRANT EXECUTE ON FUNCTION public.reject_referral(uuid, text) TO authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- 10. RPC : apply_credit_to_checkout
-- ─────────────────────────────────────────────────────────────────────
-- Appelée par le serveur lors du checkout. Calcule combien de crédit
-- on peut appliquer à un montant donné (sans dépasser le prix), insère
-- une ligne 'checkout_discount' (négative) et retourne le montant appliqué.
-- Atomique pour éviter les doubles consommations.
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.apply_credit_to_checkout(
  p_user uuid,
  p_price_cents int,
  p_session_id text
)
RETURNS int
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_balance int;
  v_applied int;
BEGIN
  IF p_user IS NULL OR p_price_cents <= 0 THEN
    RETURN 0;
  END IF;

  -- Lecture atomique avec lock
  PERFORM 1 FROM public.profiles WHERE id = p_user FOR UPDATE;

  SELECT balance_cents INTO v_balance FROM public.user_credit_balance WHERE user_id = p_user;
  v_balance := COALESCE(v_balance, 0);
  IF v_balance <= 0 THEN
    RETURN 0;
  END IF;

  v_applied := LEAST(v_balance, p_price_cents);

  INSERT INTO public.user_credits (user_id, amount_cents, kind, ref_id, description)
  VALUES (p_user, -v_applied, 'checkout_discount', p_session_id,
          'Crédit appliqué au checkout Stripe ' || p_session_id);

  RETURN v_applied;
END;
$$;

GRANT EXECUTE ON FUNCTION public.apply_credit_to_checkout(uuid, int, text) TO service_role;
-- Note : appelée côté serveur (service_role) UNIQUEMENT pour éviter qu'un
-- user appelle cette RPC en boucle. Le checkout serveur l'invoque.
