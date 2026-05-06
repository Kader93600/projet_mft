-- =====================================================================
-- Multi-formations — Sprint 2 : verrouillage RLS lecture du contenu
-- =====================================================================
-- Sprint 1 (multi_formation_sprint1.sql) avait verrouillé les ÉCRITURES
-- (un user ne peut pas écrire de progression hors formations inscrites).
--
-- Sprint 2 verrouille les LECTURES :
--   - modules / lessons / quizzes / questions / choices ne sont visibles
--     QUE si rattachés à une formation où le user a accès (inscrit, ou
--     formateur habilité, ou admin).
--   - placement_questions : filtré par formation_id du user.
--
-- Pré-requis :
--   - permissions_v2_step2.sql (helper has_formation_access)
--   - formations_v2.sql (formation_modules, formation_quizzes)
--   - multi_formation_sprint1.sql (user_has_formation, current_formation_id)
--
-- Idempotent : DROP POLICY IF EXISTS partout.
--
-- ⚠️ IMPORTANT — avant de jouer ce script :
--   1. Vérifier que tous les modules/quizzes ont bien un mapping dans
--      formation_modules / formation_quizzes (sinon le module est traité
--      comme "legacy" et reste accessible à tous).
--   2. Tester en staging avec un compte stagiaire d'une formation X et
--      tenter de lire un module d'une formation Y → devrait renvoyer 0.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) MODULES — visibles si rattachés à une formation accessible
-- ---------------------------------------------------------------------
DROP POLICY IF EXISTS "modules_read_authed" ON public.modules;
DROP POLICY IF EXISTS modules_read_scoped ON public.modules;

CREATE POLICY modules_read_scoped ON public.modules
  FOR SELECT USING (
    public.is_admin()
    OR
    -- Module non rattaché → accessible à tous les authentifiés (legacy)
    NOT EXISTS (
      SELECT 1 FROM public.formation_modules fm WHERE fm.module_id = modules.id
    )
    OR
    -- Module rattaché → user doit avoir accès à au moins une de ses formations
    EXISTS (
      SELECT 1
        FROM public.formation_modules fm
        JOIN public.formations f ON f.id = fm.formation_id
       WHERE fm.module_id = modules.id
         AND public.has_formation_access(auth.uid(), f.slug)
    )
  );

-- ---------------------------------------------------------------------
-- 2) LESSONS — héritent du module parent
-- ---------------------------------------------------------------------
DROP POLICY IF EXISTS "lessons_read_authed" ON public.lessons;
DROP POLICY IF EXISTS lessons_read_scoped ON public.lessons;

CREATE POLICY lessons_read_scoped ON public.lessons
  FOR SELECT USING (
    public.is_admin()
    OR EXISTS (
      SELECT 1 FROM public.modules m
       WHERE m.id = lessons.module_id
         AND (
           NOT EXISTS (
             SELECT 1 FROM public.formation_modules fm WHERE fm.module_id = m.id
           )
           OR EXISTS (
             SELECT 1
               FROM public.formation_modules fm
               JOIN public.formations f ON f.id = fm.formation_id
              WHERE fm.module_id = m.id
                AND public.has_formation_access(auth.uid(), f.slug)
           )
         )
    )
  );

-- ---------------------------------------------------------------------
-- 3) QUIZZES — visibles si rattachés via formation_quizzes
-- ---------------------------------------------------------------------
DROP POLICY IF EXISTS "quizzes_read_authed" ON public.quizzes;
DROP POLICY IF EXISTS quizzes_read_scoped ON public.quizzes;

CREATE POLICY quizzes_read_scoped ON public.quizzes
  FOR SELECT USING (
    public.is_admin()
    OR NOT EXISTS (
      SELECT 1 FROM public.formation_quizzes fq WHERE fq.quiz_id = quizzes.id
    )
    OR EXISTS (
      SELECT 1
        FROM public.formation_quizzes fq
        JOIN public.formations f ON f.id = fq.formation_id
       WHERE fq.quiz_id = quizzes.id
         AND public.has_formation_access(auth.uid(), f.slug)
    )
  );

-- ---------------------------------------------------------------------
-- 4) QUESTIONS (table héritée — quizzes legacy)
-- ---------------------------------------------------------------------
DROP POLICY IF EXISTS "questions_read_authed" ON public.questions;
DROP POLICY IF EXISTS questions_read_scoped ON public.questions;

CREATE POLICY questions_read_scoped ON public.questions
  FOR SELECT USING (
    public.is_admin()
    OR EXISTS (
      SELECT 1 FROM public.quizzes q
       WHERE q.id = questions.quiz_id
         AND (
           NOT EXISTS (
             SELECT 1 FROM public.formation_quizzes fq WHERE fq.quiz_id = q.id
           )
           OR EXISTS (
             SELECT 1
               FROM public.formation_quizzes fq
               JOIN public.formations f ON f.id = fq.formation_id
              WHERE fq.quiz_id = q.id
                AND public.has_formation_access(auth.uid(), f.slug)
           )
         )
    )
  );

-- ---------------------------------------------------------------------
-- 5) CHOICES — héritent de leur question (manquait dans Sprint 1.5)
-- ---------------------------------------------------------------------
DROP POLICY IF EXISTS "choices_read_authed" ON public.choices;
DROP POLICY IF EXISTS choices_read_scoped ON public.choices;

CREATE POLICY choices_read_scoped ON public.choices
  FOR SELECT USING (
    public.is_admin()
    OR EXISTS (
      SELECT 1
        FROM public.questions q
        JOIN public.quizzes qz ON qz.id = q.quiz_id
       WHERE q.id = choices.question_id
         AND (
           NOT EXISTS (
             SELECT 1 FROM public.formation_quizzes fq WHERE fq.quiz_id = qz.id
           )
           OR EXISTS (
             SELECT 1
               FROM public.formation_quizzes fq
               JOIN public.formations f ON f.id = fq.formation_id
              WHERE fq.quiz_id = qz.id
                AND public.has_formation_access(auth.uid(), f.slug)
           )
         )
    )
  );

-- ---------------------------------------------------------------------
-- 6) PLACEMENT_QUESTIONS — filtré par formation_id du user
-- ---------------------------------------------------------------------
-- Avant : tout user authentifié pouvait lire les 200 questions des 8
-- formations. Maintenant : un user ne voit que celles de sa formation.

DROP POLICY IF EXISTS placement_q_read ON public.placement_questions;
CREATE POLICY placement_q_read ON public.placement_questions
  FOR SELECT USING (
    public.is_admin()
    OR (
      formation_id IS NOT NULL
      AND public.user_has_formation(formation_id)
    )
    OR (
      -- Tolérance legacy : questions sans formation_id (avant Sprint 2)
      -- restent visibles aux authentifiés (à supprimer une fois migré).
      formation_id IS NULL AND auth.role() = 'authenticated'
    )
  );

-- ---------------------------------------------------------------------
-- 7) Vérification post-migration
-- ---------------------------------------------------------------------
-- Pour valider en staging :
--   SET LOCAL ROLE authenticated;
--   SET LOCAL request.jwt.claims = '{"sub":"<user-id-stagiaire-capa>"}';
--   SELECT count(*) FROM public.modules;       -- doit ne renvoyer que ses modules
--   SELECT count(*) FROM public.placement_questions;  -- 25 (sa formation)

DO $$
BEGIN
  RAISE NOTICE 'Sprint 2 multi-formation OK';
  RAISE NOTICE '  RLS lecture durcie sur : modules, lessons, quizzes, questions, choices';
  RAISE NOTICE '  RLS placement_questions : filtrée par formation_id';
  RAISE NOTICE '  Test staging recommandé avant push prod.';
END $$;
