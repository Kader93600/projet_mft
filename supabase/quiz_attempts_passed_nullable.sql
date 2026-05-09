-- ============================================================
-- INFRA - Quiz attempts passed nullable (fix mixte)
-- ============================================================
-- Bug critique trouvé via les tests E2E :
--   La colonne quiz_attempts.passed est NOT NULL, mais lors de la
--   soumission d'un quiz MIXTE (QCM + QR), submit() met passed=NULL
--   parce qu'on ne peut PAS encore décider si l'utilisateur a réussi
--   tant que les QR ne sont pas corrigées par le formateur.
--
--   → Aucun quiz mixte ne peut être soumis en production.
--
-- Sémantique post-fix :
--   passed = NULL    → tentative en attente de correction QR
--   passed = TRUE    → tentative validée (qcm_score >= pass_threshold
--                      après correction des QR)
--   passed = FALSE   → tentative non validée (idem en bas du seuil)
--
-- Idempotent : ré-exécutable sans danger.
-- ============================================================

ALTER TABLE public.quiz_attempts
  ALTER COLUMN passed DROP NOT NULL;

-- Vérification
DO $$
DECLARE
  v_nullable text;
BEGIN
  SELECT is_nullable INTO v_nullable
    FROM information_schema.columns
   WHERE table_schema = 'public'
     AND table_name = 'quiz_attempts'
     AND column_name = 'passed';

  IF v_nullable = 'YES' THEN
    RAISE NOTICE '╔════════════════════════════════════════════════════';
    RAISE NOTICE '║ ✓ quiz_attempts.passed est maintenant NULLABLE';
    RAISE NOTICE '╠════════════════════════════════════════════════════';
    RAISE NOTICE '║ Sémantique :';
    RAISE NOTICE '║   NULL  → en attente de correction QR';
    RAISE NOTICE '║   TRUE  → validé (qcm_score >= pass_threshold)';
    RAISE NOTICE '║   FALSE → non validé';
    RAISE NOTICE '║ Les quiz mixtes peuvent maintenant être soumis.';
    RAISE NOTICE '╚════════════════════════════════════════════════════';
  ELSE
    RAISE EXCEPTION 'Échec : passed est toujours NOT NULL (état: %)', v_nullable;
  END IF;
END $$;
