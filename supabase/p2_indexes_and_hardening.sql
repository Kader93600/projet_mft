-- =====================================================================
-- P2 — Indexes composites + durcissement formation_id
-- =====================================================================
-- Étape 1 : Indexes composites manquants pour les requêtes chaudes
-- Étape 2 : NOT NULL sur quiz_attempts.formation_id et
--           lesson_views.formation_id (après vérification du backfill)
--
-- Idempotent : peut être rejoué.
-- Si le backfill n'est pas complet (lignes orphelines), le NOT NULL est
-- skipé avec un RAISE NOTICE — le script ne plante pas.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) Indexes composites manquants
-- ---------------------------------------------------------------------

-- /stats et /dashboard : `quiz_attempts` ordered by finished_at DESC pour
-- un user donné (déjà filtré par formation_id en Sprint 1).
-- L'index existant (user_id, formation_id) ne permet pas un sort efficace.
CREATE INDEX IF NOT EXISTS quiz_attempts_user_finished_idx
  ON public.quiz_attempts(user_id, finished_at DESC)
  WHERE finished_at IS NOT NULL;

-- /stats : aggregat sur quiz_attempts par formation × passé/raté
CREATE INDEX IF NOT EXISTS quiz_attempts_user_formation_finished_idx
  ON public.quiz_attempts(user_id, formation_id, finished_at DESC)
  WHERE finished_at IS NOT NULL;

-- Activity timeline : lesson_views par user ordered by last_ping_at DESC
CREATE INDEX IF NOT EXISTS lesson_views_user_lastping_idx
  ON public.lesson_views(user_id, last_ping_at DESC);

-- /dashboard, /modules : lesson_progress filtré par user
CREATE INDEX IF NOT EXISTS lesson_progress_user_idx
  ON public.lesson_progress(user_id);

-- getActiveFormation() : enrollments du user, statut prioritaire, récent
-- (résolution de la formation courante à chaque page server-side)
CREATE INDEX IF NOT EXISTS enrollments_user_status_created_idx
  ON public.enrollments(user_id, status, created_at DESC)
  WHERE formation_id IS NOT NULL;

-- /admin/users : profiles ordered by created_at DESC pour la pagination
CREATE INDEX IF NOT EXISTS profiles_created_idx
  ON public.profiles(created_at DESC);

-- Recherche /admin/users : ILIKE email/full_name → trigram pour rapide
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX IF NOT EXISTS profiles_email_trgm
  ON public.profiles USING gin (email gin_trgm_ops);
CREATE INDEX IF NOT EXISTS profiles_fullname_trgm
  ON public.profiles USING gin (full_name gin_trgm_ops)
  WHERE full_name IS NOT NULL;


-- ---------------------------------------------------------------------
-- 2) NOT NULL sur formation_id (post Sprint 1 backfill)
-- ---------------------------------------------------------------------
-- Sécurité : on vérifie d'abord qu'il n'y a aucune ligne orpheline.
-- Si le backfill n'est pas complet, on skip le ALTER (RAISE NOTICE).

DO $$
DECLARE
  v_qa_null int;
  v_lv_null int;
BEGIN
  SELECT count(*) INTO v_qa_null
    FROM public.quiz_attempts
   WHERE formation_id IS NULL;

  SELECT count(*) INTO v_lv_null
    FROM public.lesson_views
   WHERE formation_id IS NULL;

  IF v_qa_null > 0 THEN
    RAISE NOTICE 'quiz_attempts : % lignes avec formation_id NULL — NOT NULL skipé.',
                 v_qa_null;
    RAISE NOTICE '  → relancer multi_formation_sprint1.sql pour rebackfill.';
  ELSE
    BEGIN
      ALTER TABLE public.quiz_attempts
        ALTER COLUMN formation_id SET NOT NULL;
      RAISE NOTICE 'quiz_attempts.formation_id : NOT NULL appliqué.';
    EXCEPTION WHEN others THEN
      RAISE NOTICE 'quiz_attempts NOT NULL échec : %', SQLERRM;
    END;
  END IF;

  IF v_lv_null > 0 THEN
    RAISE NOTICE 'lesson_views : % lignes avec formation_id NULL — NOT NULL skipé.',
                 v_lv_null;
    RAISE NOTICE '  → relancer multi_formation_sprint1.sql pour rebackfill.';
  ELSE
    BEGIN
      ALTER TABLE public.lesson_views
        ALTER COLUMN formation_id SET NOT NULL;
      RAISE NOTICE 'lesson_views.formation_id : NOT NULL appliqué.';
    EXCEPTION WHEN others THEN
      RAISE NOTICE 'lesson_views NOT NULL échec : %', SQLERRM;
    END;
  END IF;
END $$;


-- ---------------------------------------------------------------------
-- 3) Audit final : vérification rapide des plans
-- ---------------------------------------------------------------------
-- À jouer manuellement après migration pour valider les gains :
--
-- EXPLAIN ANALYZE SELECT * FROM quiz_attempts
--   WHERE user_id = '<uuid>' AND formation_id = '<uuid>'
--   ORDER BY finished_at DESC LIMIT 5;
--
-- EXPLAIN ANALYZE SELECT * FROM profiles
--   WHERE email ILIKE '%test%' ORDER BY created_at DESC LIMIT 50;
--
-- Le coût "Total" doit chuter d'un facteur 5-10× selon volumétrie.

DO $$
BEGIN
  RAISE NOTICE 'P2 indexes + hardening OK.';
  RAISE NOTICE '  Indexes composites créés sur quiz_attempts, lesson_views, lesson_progress, enrollments, profiles.';
  RAISE NOTICE '  Trigram sur profiles.email + profiles.full_name (recherche /admin/users).';
END $$;
