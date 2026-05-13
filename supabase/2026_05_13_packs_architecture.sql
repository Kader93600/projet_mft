-- =====================================================================
-- MIGRATION — Architecture des 3 packs (Initial / Medium / Premium)
-- Date : 2026-05-13
--
-- Suite à validation client (cf. PDF "Modif MFT_v1") :
--
--   3 niveaux de pack par enrollment :
--     - 'initial'  : cours + exercices + corrigés + QR IA + examens blancs IA
--     - 'medium'   : Initial + messagerie avec formateur dédié
--     - 'premium'  : Medium + sessions présentielles + lien Zoom
--
--   Contrainte métier :
--     - Capacité ≤ 3,5 t : SEUL le pack 'initial' est disponible.
--     - Toutes les autres formations (GOTRM, FIMO/FCO, VTC/Taxi, …) :
--       les 3 packs sont disponibles.
--
--   Stripe : 22 produits (3 packs × 7 formations + 1 Initial Capacité-3,5t).
--   Upgrade en cours de parcours autorisé (paye la différence).
--   Admin peut modifier le pack d'un stagiaire depuis son profil.
--
-- Idempotent : safe à rejouer.
-- Ne modifie que la table enrollments (colonne `pack` + index + trigger
-- de validation + 2 helpers RPC pour les RLS et le code applicatif).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) ENUM type pour les packs
-- ---------------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'pack_slug') THEN
    CREATE TYPE pack_slug AS ENUM ('initial', 'medium', 'premium');
    RAISE NOTICE 'Type pack_slug créé';
  ELSE
    RAISE NOTICE 'Type pack_slug déjà présent — skip';
  END IF;
END $$;

-- ---------------------------------------------------------------------
-- 2) Colonne pack sur enrollments
-- ---------------------------------------------------------------------
ALTER TABLE public.enrollments
  ADD COLUMN IF NOT EXISTS pack pack_slug NOT NULL DEFAULT 'initial';

-- Backfill des inscriptions existantes (déjà à 'initial' grâce au DEFAULT,
-- mais on s'assure que rien n'est NULL au cas où des migrations précédentes
-- auraient touché la colonne).
UPDATE public.enrollments
   SET pack = 'initial'
 WHERE pack IS NULL;

COMMENT ON COLUMN public.enrollments.pack IS
  'Pack acheté pour cette inscription : initial | medium | premium. '
  'Capacité ≤ 3,5 t : seul initial est autorisé (cf. trigger). '
  'Admin peut modifier ce champ depuis le profil stagiaire.';

-- ---------------------------------------------------------------------
-- 3) Index pour les queries fréquentes
--    (user, formation) → pack ; utilisé par RLS et UI dashboard.
-- ---------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS enrollments_user_formation_pack_idx
  ON public.enrollments (user_id, formation_id, pack);

-- ---------------------------------------------------------------------
-- 4) Trigger : valide que le pack est compatible avec la formation
--    (Capacité ≤ 3,5 t ne peut avoir que 'initial')
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tg_check_pack_formation_validity()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  v_formation_slug text;
BEGIN
  -- Si pas de formation_id (cas legacy), on laisse passer.
  IF NEW.formation_id IS NULL OR NEW.pack IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT slug INTO v_formation_slug
    FROM public.formations
   WHERE id = NEW.formation_id;

  -- Capacité ≤ 3,5 t : seulement initial
  IF v_formation_slug = 'capacite-3-5t' AND NEW.pack <> 'initial' THEN
    RAISE EXCEPTION 'Pack "%" non disponible pour la formation Capacité ≤ 3,5 t (seul "initial" est autorisé)',
      NEW.pack
      USING ERRCODE = 'check_violation';
  END IF;

  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS tg_enrollments_check_pack_formation ON public.enrollments;
CREATE TRIGGER tg_enrollments_check_pack_formation
  BEFORE INSERT OR UPDATE OF pack, formation_id ON public.enrollments
  FOR EACH ROW EXECUTE FUNCTION public.tg_check_pack_formation_validity();

-- ---------------------------------------------------------------------
-- 5) RPC : récupérer le pack le plus élevé du user pour une formation
--    (utilisé par RLS et le code TypeScript pour le feature-gating)
--
--    Si plusieurs enrollments coexistent pour (user, formation) — ce qui
--    peut arriver en cas d'upgrade en cours — on prend le pack le plus
--    élevé pour octroyer les features.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.user_pack_for_formation(
  p_user_id uuid,
  p_formation_slug text
) RETURNS pack_slug
LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT e.pack
    FROM public.enrollments e
    JOIN public.formations f ON f.id = e.formation_id
   WHERE e.user_id = p_user_id
     AND f.slug = p_formation_slug
     AND e.status NOT IN ('refuse', 'abandon')
   ORDER BY
     CASE e.pack
       WHEN 'premium' THEN 1
       WHEN 'medium' THEN 2
       WHEN 'initial' THEN 3
     END
   LIMIT 1;
$$;

COMMENT ON FUNCTION public.user_pack_for_formation(uuid, text) IS
  'Retourne le pack le plus élevé acheté par un user pour une formation donnée. '
  'NULL si pas d''enrollment valide (ou tous abandonnés/refusés).';

-- ---------------------------------------------------------------------
-- 6) RPC : vérifier qu'un user a AU MOINS un pack donné pour une formation
--    Utile pour RLS sur les tables features (messages, sessions, …).
--
--    Exemple d'utilisation dans une RLS policy :
--      CREATE POLICY messages_medium_or_plus ON public.messages
--        FOR SELECT USING (
--          public.user_has_min_pack(auth.uid(), 'gotrm-rncp-40990', 'medium')
--        );
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.user_has_min_pack(
  p_user_id uuid,
  p_formation_slug text,
  p_min_pack pack_slug
) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER AS $$
  WITH user_pack AS (
    SELECT public.user_pack_for_formation(p_user_id, p_formation_slug) AS p
  )
  SELECT CASE
    WHEN (SELECT p FROM user_pack) IS NULL THEN FALSE
    WHEN p_min_pack = 'initial' THEN TRUE
    WHEN p_min_pack = 'medium'  THEN (SELECT p FROM user_pack) IN ('medium', 'premium')
    WHEN p_min_pack = 'premium' THEN (SELECT p FROM user_pack) = 'premium'
    ELSE FALSE
  END;
$$;

COMMENT ON FUNCTION public.user_has_min_pack(uuid, text, pack_slug) IS
  'Renvoie TRUE si le user a AU MOINS le pack demandé pour la formation. '
  'Hiérarchie : initial < medium < premium. Utilisé par RLS pour gate les features.';

-- ---------------------------------------------------------------------
-- 7) Vérification post-migration
-- ---------------------------------------------------------------------
DO $$
DECLARE
  v_count int;
  v_capa_violations int;
BEGIN
  -- Compteur total inscriptions
  SELECT COUNT(*) INTO v_count FROM public.enrollments;
  RAISE NOTICE 'Total enrollments : % (toutes initialisées à ''initial'' par défaut)', v_count;

  -- Vérif : aucune inscription Capacité ≤ 3,5 t n'a un pack > initial
  SELECT COUNT(*) INTO v_capa_violations
    FROM public.enrollments e
    JOIN public.formations f ON f.id = e.formation_id
   WHERE f.slug = 'capacite-3-5t' AND e.pack <> 'initial';

  IF v_capa_violations > 0 THEN
    RAISE WARNING 'Capacité ≤ 3,5 t : % inscription(s) avec pack > initial (à corriger manuellement)',
      v_capa_violations;
  ELSE
    RAISE NOTICE 'Capacité ≤ 3,5 t : aucune violation pack > initial ✅';
  END IF;
END $$;

-- ---------------------------------------------------------------------
-- Vérification post-migration (à exécuter manuellement) :
-- ---------------------------------------------------------------------
-- Voir la répartition des packs par formation :
--
--   SELECT
--     f.slug AS formation,
--     e.pack,
--     COUNT(*) AS nb_enrollments
--   FROM public.enrollments e
--   JOIN public.formations f ON f.id = e.formation_id
--   GROUP BY f.slug, e.pack
--   ORDER BY f.slug, e.pack;
--
-- Tester user_pack_for_formation :
--
--   SELECT public.user_pack_for_formation(
--     '<UUID_USER>',
--     'gotrm-rncp-40990'
--   );
--
-- Tester user_has_min_pack :
--
--   SELECT public.user_has_min_pack(
--     '<UUID_USER>',
--     'gotrm-rncp-40990',
--     'medium'
--   );  -- TRUE si user a au moins medium pour gotrm
