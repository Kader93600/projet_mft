-- =====================================================================
-- Restriction d'accès par formation — RLS sur modules / lessons / quizzes
--
-- Avant : tout user authentifié pouvait lire tous les modules/quiz.
-- Après : un stagiaire ne voit que ceux des formations où il est inscrit ;
--         un formateur ne voit que celles où il est habilité ;
--         le staff voit tout.
--
-- Mécanisme :
--   - Si un module/quiz est rattaché à au moins une formation via
--     formation_modules / formation_quizzes, on filtre par accès.
--   - Si un module/quiz N'EST RATTACHÉ à AUCUNE formation, il reste
--     accessible à tous les authentifiés (cas legacy / contenus communs).
--
-- ⚠️ À jouer APRÈS avoir liés les modules existants à au moins une
--    formation (sinon ils restent visibles à tous, ce qui peut être
--    voulu pendant la transition).
-- =====================================================================

-- ---------------------------------------------------------------------
-- MODULES
-- ---------------------------------------------------------------------
DROP POLICY IF EXISTS "modules_read_authed" ON public.modules;

CREATE POLICY modules_read_scoped ON public.modules
  FOR SELECT USING (
    public.is_admin()
    OR
    -- Module non rattaché → accessible à tous les authentifiés (legacy)
    NOT EXISTS (
      SELECT 1 FROM public.formation_modules fm WHERE fm.module_id = modules.id
    )
    OR
    -- Module rattaché → l'utilisateur doit avoir accès à au moins une de ses formations
    EXISTS (
      SELECT 1
      FROM public.formation_modules fm
      JOIN public.formations f ON f.id = fm.formation_id
      WHERE fm.module_id = modules.id
        AND public.has_formation_access(auth.uid(), f.slug)
    )
  );

-- ---------------------------------------------------------------------
-- LESSONS — héritent de la visibilité du module parent
-- ---------------------------------------------------------------------
DROP POLICY IF EXISTS "lessons_read_authed" ON public.lessons;

CREATE POLICY lessons_read_scoped ON public.lessons
  FOR SELECT USING (
    public.is_admin()
    OR
    EXISTS (
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
-- QUIZZES
-- ---------------------------------------------------------------------
DROP POLICY IF EXISTS "quizzes_read_authed" ON public.quizzes;

CREATE POLICY quizzes_read_scoped ON public.quizzes
  FOR SELECT USING (
    public.is_admin()
    OR
    NOT EXISTS (
      SELECT 1 FROM public.formation_quizzes fq WHERE fq.quiz_id = quizzes.id
    )
    OR
    EXISTS (
      SELECT 1
      FROM public.formation_quizzes fq
      JOIN public.formations f ON f.id = fq.formation_id
      WHERE fq.quiz_id = quizzes.id
        AND public.has_formation_access(auth.uid(), f.slug)
    )
  );

-- ---------------------------------------------------------------------
-- QUESTIONS (table héritée — les questions liées aux quiz historiques)
-- ---------------------------------------------------------------------
DROP POLICY IF EXISTS "questions_read_authed" ON public.questions;

CREATE POLICY questions_read_scoped ON public.questions
  FOR SELECT USING (
    public.is_admin()
    OR
    EXISTS (
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
