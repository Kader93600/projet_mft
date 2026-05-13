-- =====================================================================
-- MIGRATION — Pricing matrix (formation × pack) éditable par admin
-- Date : 2026-05-13
--
-- Suite Phase 2 : les prix de chaque (formation × pack) sont désormais
-- stockés en DB et modifiables par admin/super_admin depuis le panel.
--
-- Pourquoi DB plutôt que pricing-config.ts hardcodé :
--   - Admin/super_admin peuvent ajuster les prix sans deploy
--   - 22 prix à gérer (3 packs × 7 formations + 1 Initial Capacité)
--   - Permet des promotions ponctuelles (compare_at_cents pour prix barré)
--   - Audit trail (updated_by) pour traçabilité Qualiopi
--
-- Idempotent : safe à rejouer. INSERT ON CONFLICT pour les seeds.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) Table formation_pack_prices
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.formation_pack_prices (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  formation_id uuid NOT NULL REFERENCES public.formations(id) ON DELETE CASCADE,
  pack pack_slug NOT NULL,
  price_cents int NOT NULL CHECK (price_cents > 0),
  compare_at_cents int
    CHECK (compare_at_cents IS NULL OR compare_at_cents > price_cents),
  active boolean NOT NULL DEFAULT true,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  UNIQUE (formation_id, pack)
);

COMMENT ON TABLE public.formation_pack_prices IS
  'Matrice de prix (formation × pack). Éditable par admin/super_admin '
  'depuis /admin/pricing. Source de vérité pour les Stripe Checkout sessions.';

COMMENT ON COLUMN public.formation_pack_prices.compare_at_cents IS
  'Prix barré (optionnel) pour afficher une promo : "1890 € au lieu de 2190 €".';

COMMENT ON COLUMN public.formation_pack_prices.active IS
  'Désactiver pour retirer momentanément un pack de la vente '
  '(au lieu de supprimer la ligne, on garde l''historique).';

-- Index sur (formation_id) pour les queries du checkout
CREATE INDEX IF NOT EXISTS fpp_formation_idx
  ON public.formation_pack_prices(formation_id);
CREATE INDEX IF NOT EXISTS fpp_active_idx
  ON public.formation_pack_prices(active) WHERE active = true;

-- Trigger updated_at
CREATE OR REPLACE FUNCTION public.tg_fpp_touch()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at := now(); RETURN NEW; END $$;

DROP TRIGGER IF EXISTS tg_fpp_updated_at ON public.formation_pack_prices;
CREATE TRIGGER tg_fpp_updated_at
  BEFORE UPDATE ON public.formation_pack_prices
  FOR EACH ROW EXECUTE FUNCTION public.tg_fpp_touch();

-- Trigger : valide que Capacité ≤ 3,5 t a UNIQUEMENT le pack 'initial'
CREATE OR REPLACE FUNCTION public.tg_fpp_check_capacite_only_initial()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  v_formation_slug text;
BEGIN
  SELECT slug INTO v_formation_slug
    FROM public.formations WHERE id = NEW.formation_id;

  IF v_formation_slug = 'capacite-3-5t' AND NEW.pack <> 'initial' THEN
    RAISE EXCEPTION 'Pack "%" non vendable pour la formation Capacité ≤ 3,5 t (seul "initial" est autorisé)',
      NEW.pack
      USING ERRCODE = 'check_violation';
  END IF;

  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS tg_fpp_check_capacite ON public.formation_pack_prices;
CREATE TRIGGER tg_fpp_check_capacite
  BEFORE INSERT OR UPDATE OF pack, formation_id ON public.formation_pack_prices
  FOR EACH ROW EXECUTE FUNCTION public.tg_fpp_check_capacite_only_initial();

-- ---------------------------------------------------------------------
-- 2) RLS
-- ---------------------------------------------------------------------
ALTER TABLE public.formation_pack_prices ENABLE ROW LEVEL SECURITY;

-- Lecture publique : nécessaire pour afficher les prix sur landing/inscription
DROP POLICY IF EXISTS fpp_public_read ON public.formation_pack_prices;
CREATE POLICY fpp_public_read ON public.formation_pack_prices
  FOR SELECT USING (active = true);

-- Lecture COMPLÈTE (y compris inactifs) pour admin/super_admin
DROP POLICY IF EXISTS fpp_admin_read_all ON public.formation_pack_prices;
CREATE POLICY fpp_admin_read_all ON public.formation_pack_prices
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.profiles
       WHERE id = auth.uid() AND role IN ('admin', 'super_admin')
    )
  );

-- Écriture : admin/super_admin uniquement
DROP POLICY IF EXISTS fpp_admin_write ON public.formation_pack_prices;
CREATE POLICY fpp_admin_write ON public.formation_pack_prices
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.profiles
       WHERE id = auth.uid() AND role IN ('admin', 'super_admin')
    )
  ) WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles
       WHERE id = auth.uid() AND role IN ('admin', 'super_admin')
    )
  );

-- ---------------------------------------------------------------------
-- 3) RPC : récupérer le prix d'un pack pour une formation
--    (utilisé par /api/stripe/checkout côté serveur)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_pack_price(
  p_formation_slug text,
  p_pack pack_slug
) RETURNS TABLE (
  price_cents int,
  compare_at_cents int,
  active boolean,
  formation_id uuid
)
LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT fpp.price_cents, fpp.compare_at_cents, fpp.active, fpp.formation_id
    FROM public.formation_pack_prices fpp
    JOIN public.formations f ON f.id = fpp.formation_id
   WHERE f.slug = p_formation_slug
     AND fpp.pack = p_pack
     AND fpp.active = true
   LIMIT 1;
$$;

COMMENT ON FUNCTION public.get_pack_price(text, pack_slug) IS
  'Récupère le prix actif d''un pack pour une formation. NULL si la combinaison '
  'n''existe pas (ex: Medium pour Capacité ≤ 3,5 t).';

-- ---------------------------------------------------------------------
-- 4) Seed : 22 prix placeholder (validés client 2026-05)
--    Initial : 4 000 €  | Medium : 6 000 €  | Premium : 7 500 €
--    Capacité ≤ 3,5 t : Initial uniquement
-- ---------------------------------------------------------------------
DO $seed$
DECLARE
  v_formation record;
  v_inserted int := 0;
  v_skipped int := 0;
BEGIN
  FOR v_formation IN
    SELECT id, slug FROM public.formations
     WHERE slug IN (
       'gotrm', 'ertv', 'ecsr', 'fimo-fco', 'taxi-vtc',
       'commissionnaire', 'capacite-3-5t', 'capacite-plus-3-5t'
     )
  LOOP
    -- Initial (toutes formations)
    INSERT INTO public.formation_pack_prices (formation_id, pack, price_cents)
    VALUES (v_formation.id, 'initial', 400000) -- 4 000 €
    ON CONFLICT (formation_id, pack) DO NOTHING;
    GET DIAGNOSTICS v_inserted = ROW_COUNT;
    IF v_inserted > 0 THEN
      RAISE NOTICE '  + Initial à 4 000 € seedé pour %', v_formation.slug;
    ELSE
      v_skipped := v_skipped + 1;
    END IF;

    -- Medium + Premium : sauf Capacité ≤ 3,5 t
    IF v_formation.slug <> 'capacite-3-5t' THEN
      INSERT INTO public.formation_pack_prices (formation_id, pack, price_cents)
      VALUES (v_formation.id, 'medium', 600000) -- 6 000 €
      ON CONFLICT (formation_id, pack) DO NOTHING;
      GET DIAGNOSTICS v_inserted = ROW_COUNT;
      IF v_inserted > 0 THEN
        RAISE NOTICE '  + Medium à 6 000 € seedé pour %', v_formation.slug;
      END IF;

      INSERT INTO public.formation_pack_prices (formation_id, pack, price_cents)
      VALUES (v_formation.id, 'premium', 750000) -- 7 500 €
      ON CONFLICT (formation_id, pack) DO NOTHING;
      GET DIAGNOSTICS v_inserted = ROW_COUNT;
      IF v_inserted > 0 THEN
        RAISE NOTICE '  + Premium à 7 500 € seedé pour %', v_formation.slug;
      END IF;
    END IF;
  END LOOP;

  -- Compteur final
  SELECT COUNT(*) INTO v_inserted FROM public.formation_pack_prices;
  RAISE NOTICE '---';
  RAISE NOTICE 'Total prix en base : % (attendu : 22)', v_inserted;
END $seed$;

-- ---------------------------------------------------------------------
-- 5) Vérification post-migration
-- ---------------------------------------------------------------------
-- Exécuter manuellement pour visualiser la matrice :
--
--   SELECT
--     f.slug AS formation,
--     fpp.pack,
--     (fpp.price_cents / 100.0) AS price_eur,
--     fpp.active
--   FROM public.formation_pack_prices fpp
--   JOIN public.formations f ON f.id = fpp.formation_id
--   ORDER BY f.slug, fpp.pack;
--
-- Tester get_pack_price :
--
--   SELECT * FROM public.get_pack_price('gotrm', 'medium');
--   -- Renvoie price_cents = 600000
--
--   SELECT * FROM public.get_pack_price('capacite-3-5t', 'medium');
--   -- Renvoie rien (combinaison invalide)
