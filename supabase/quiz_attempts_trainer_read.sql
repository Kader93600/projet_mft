-- ============================================================
-- INFRA - Quiz attempts : lecture par les formateurs
-- ============================================================
-- Bug critique trouvé via les tests E2E :
--   La policy RLS `attempts_self_read` autorise uniquement le
--   propriétaire (student) et les admins à lire une tentative.
--   → Les FORMATEURS ne peuvent PAS lire les copies de leurs
--     stagiaires depuis /formateur/corrections/[attemptId],
--     la page renvoie systématiquement 404.
--
-- Fix : ajouter une policy SELECT pour les trainers, scopée par
-- formation (un trainer voit les attempts dont la formation_id
-- correspond à une de ses trainer_formations).
--
-- Idempotent : ré-exécutable sans danger.
-- ============================================================

-- Cas où is_staff() n'existe pas encore (ancienne base) : on tombe
-- sur is_admin() en fallback. La policy unique ci-dessous gère les 3
-- profils : student propriétaire · admin · trainer rattaché à la formation.

DROP POLICY IF EXISTS attempts_self_read ON public.quiz_attempts;
DROP POLICY IF EXISTS attempts_trainer_read ON public.quiz_attempts;

CREATE POLICY attempts_self_read ON public.quiz_attempts
  FOR SELECT
  USING (
    -- Le propriétaire de la tentative
    auth.uid() = user_id
    -- Ou un staff (admin / super_admin)
    OR public.is_admin()
    -- Ou un trainer rattaché à la formation de la tentative
    OR (
      public.is_trainer()
      AND formation_id IS NOT NULL
      AND formation_id IN (
        SELECT formation_id
          FROM public.trainer_formations
         WHERE trainer_id = auth.uid()
      )
    )
    -- Ou un trainer rattaché au student via partage de formation
    -- (filet de sécurité pour les anciennes attempts sans formation_id)
    OR (
      public.is_trainer()
      AND public.trainer_shares_formation_with(auth.uid(), user_id)
    )
  );

-- Vérification
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
     WHERE schemaname = 'public'
       AND tablename = 'quiz_attempts'
       AND policyname = 'attempts_self_read'
  ) THEN
    RAISE EXCEPTION 'Policy attempts_self_read non créée';
  END IF;

  RAISE NOTICE '╔════════════════════════════════════════════════════';
  RAISE NOTICE '║ ✓ Policy attempts_self_read mise à jour';
  RAISE NOTICE '╠════════════════════════════════════════════════════';
  RAISE NOTICE '║ SELECT autorisé pour :';
  RAISE NOTICE '║   - student propriétaire (auth.uid = user_id)';
  RAISE NOTICE '║   - admin / super_admin';
  RAISE NOTICE '║   - trainer rattaché à la formation (via formation_id)';
  RAISE NOTICE '║   - trainer partageant une formation avec le student';
  RAISE NOTICE '║     (fallback pour anciennes attempts sans formation_id)';
  RAISE NOTICE '╚════════════════════════════════════════════════════';
END $$;
