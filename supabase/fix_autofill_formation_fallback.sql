-- =====================================================================
-- Fix : trigger autofill formation_id avec fallback fiable
-- =====================================================================
-- Symptôme : INSERT quiz_attempts échoue avec
--   "null value in column formation_id violates not-null constraint"
--
-- Cause : le trigger d'origine lit profiles.current_formation_id. Si ce
-- champ est NULL pour un user (cas typique d'un compte créé avant Sprint 1
-- ou dont le backfill n'a pas posé current_formation_id), le trigger
-- copie NULL → la contrainte NOT NULL bloque l'INSERT.
--
-- Fix : trigger en 3 paliers, le 1er qui retourne une valeur gagne :
--   1. profiles.current_formation_id (rapide, 1 lookup)
--   2. enrollments du user (en_cours prioritaire, sinon plus récent)
--   3. formation_modules → quiz.module_id (dernier recours, marche tjs
--      tant que le quiz est rattaché à une formation valide)
--
-- Sur lesson_views : on garde le même 3-palier sauf qu'au lieu du quiz
-- on remonte via lessons → module → formation_modules.
--
-- Idempotent : CREATE OR REPLACE FUNCTION + DROP/CREATE TRIGGER.
-- =====================================================================

-- ------------------------------------------------------------------
-- 1) Helper : résout la formation à partir d'un module_id.
-- ------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.resolve_formation_from_module(
  p_module_id uuid
) RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT formation_id
    FROM public.formation_modules
   WHERE module_id = p_module_id
   ORDER BY display_order
   LIMIT 1;
$$;

-- ------------------------------------------------------------------
-- 2) Helper : résout la formation à partir d'un user_id.
-- ------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.resolve_user_active_formation(
  p_user_id uuid
) RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(
    -- Palier 1 : profil (lookup direct, rapide)
    (
      SELECT current_formation_id
        FROM public.profiles
       WHERE id = p_user_id
         AND current_formation_id IS NOT NULL
    ),
    -- Palier 2 : enrollment actif le plus récent
    (
      SELECT e.formation_id
        FROM public.enrollments e
       WHERE e.user_id = p_user_id
         AND e.formation_id IS NOT NULL
         AND e.status NOT IN ('refuse', 'abandon')
       ORDER BY
         CASE WHEN e.status = 'en_cours' THEN 0 ELSE 1 END,
         e.created_at DESC
       LIMIT 1
    )
  );
$$;

-- ------------------------------------------------------------------
-- 3) Trigger quiz_attempts : 3 paliers
-- ------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tg_qa_autofill_formation_id_v2()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  v_module_id uuid;
BEGIN
  IF NEW.formation_id IS NOT NULL THEN
    RETURN NEW;
  END IF;

  -- Palier 1 + 2 : depuis le user (current ou enrollment)
  NEW.formation_id := public.resolve_user_active_formation(NEW.user_id);
  IF NEW.formation_id IS NOT NULL THEN
    RETURN NEW;
  END IF;

  -- Palier 3 : depuis le module du quiz
  SELECT module_id INTO v_module_id
    FROM public.quizzes WHERE id = NEW.quiz_id;
  IF v_module_id IS NOT NULL THEN
    NEW.formation_id := public.resolve_formation_from_module(v_module_id);
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_qa_autofill_formation_id ON public.quiz_attempts;
CREATE TRIGGER tg_qa_autofill_formation_id
  BEFORE INSERT ON public.quiz_attempts
  FOR EACH ROW EXECUTE FUNCTION public.tg_qa_autofill_formation_id_v2();

-- ------------------------------------------------------------------
-- 4) Trigger lesson_views : même 3 paliers (via lessons → module)
-- ------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tg_lv_autofill_formation_id_v2()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  v_module_id uuid;
BEGIN
  IF NEW.formation_id IS NOT NULL THEN
    RETURN NEW;
  END IF;

  NEW.formation_id := public.resolve_user_active_formation(NEW.user_id);
  IF NEW.formation_id IS NOT NULL THEN
    RETURN NEW;
  END IF;

  SELECT module_id INTO v_module_id
    FROM public.lessons WHERE id = NEW.lesson_id;
  IF v_module_id IS NOT NULL THEN
    NEW.formation_id := public.resolve_formation_from_module(v_module_id);
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_lv_autofill_formation_id ON public.lesson_views;
CREATE TRIGGER tg_lv_autofill_formation_id
  BEFORE INSERT ON public.lesson_views
  FOR EACH ROW EXECUTE FUNCTION public.tg_lv_autofill_formation_id_v2();

-- ------------------------------------------------------------------
-- 5) Backfill correctif : current_formation_id sur profils orphelins
-- ------------------------------------------------------------------
-- Pour les users qui ont une inscription mais profiles.current_formation_id
-- vide (le cas du bug). Sans ça, ils retomberont dans le palier 2 à chaque
-- INSERT, ce qui marche mais coûte 1 lookup en plus.

WITH candidate AS (
  SELECT DISTINCT ON (e.user_id)
         e.user_id,
         e.formation_id
    FROM public.enrollments e
   WHERE e.formation_id IS NOT NULL
     AND e.status NOT IN ('refuse', 'abandon')
   ORDER BY e.user_id,
            CASE WHEN e.status = 'en_cours' THEN 0 ELSE 1 END,
            e.created_at DESC
)
UPDATE public.profiles p
   SET current_formation_id = c.formation_id
  FROM candidate c
 WHERE p.id = c.user_id
   AND p.current_formation_id IS NULL;

DO $$
BEGIN
  RAISE NOTICE 'Trigger autofill formation_id mis à jour (3 paliers).';
  RAISE NOTICE 'Backfill profiles.current_formation_id rejoué.';
END $$;
