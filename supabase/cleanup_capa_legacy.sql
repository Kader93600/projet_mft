-- =====================================================================
-- NETTOYAGE — Suppression des modules / questions LEGACY de la formation
-- Capacité ≤ 3,5 T qui ont été remplacés par les versions v2.
--
-- À jouer UNE FOIS dans Supabase Studio → SQL Editor APRÈS avoir joué
-- les 6 fichiers capa_module_X_v2.sql.
--
-- Conserve uniquement les 6 modules v2 :
--   - capa-droit-civil-commercial (Module A)
--   - capa-activite-commerciale   (Module B)
--   - capa-cadre-reglementaire    (Module C)
--   - capa-activite-financiere    (Module D)
--   - capa-salaries-droit-social  (Module E)
--   - capa-securite               (Module F)
--
-- Idempotent : safe à rejouer.
-- =====================================================================

DO $cleanup$
DECLARE
  v_formation uuid;
  v_deleted_modules int;
  v_deleted_questions int;
  v_kept_modules int;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'capacite-3-5t';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation capacite-3-5t introuvable.';
  END IF;

  -- ─── 1. Suppression des modules legacy ──────────────────────────────
  -- Cascade sur lessons, quizzes, formation_modules, lesson_progress,
  -- quiz_attempts, quiz_question_bank.
  --
  -- On supprime tous les modules rattachés à la formation capa-3-5t qui
  -- ne sont PAS dans la liste blanche v2.
  WITH deleted AS (
    DELETE FROM public.modules m
    USING public.formation_modules fm
    WHERE fm.module_id = m.id
      AND fm.formation_id = v_formation
      AND m.slug NOT IN (
        'capa-droit-civil-commercial',
        'capa-activite-commerciale',
        'capa-cadre-reglementaire',
        'capa-activite-financiere',
        'capa-salaries-droit-social',
        'capa-securite'
      )
    RETURNING m.id
  )
  SELECT count(*) INTO v_deleted_modules FROM deleted;

  -- ─── 2. Suppression des questions legacy de la banque ───────────────
  -- On supprime toutes les question_bank de la formation capa-3-5t qui
  -- n'ont PAS le préfixe v2 'mft-2026:'.
  -- Les liens quiz_question_bank seront supprimés en cascade.
  WITH deleted AS (
    DELETE FROM public.question_bank
    WHERE formation_id = v_formation
      AND (source_ref IS NULL OR source_ref NOT LIKE 'mft-2026:%')
    RETURNING id
  )
  SELECT count(*) INTO v_deleted_questions FROM deleted;

  -- ─── 3. Vérification finale ─────────────────────────────────────────
  SELECT count(*) INTO v_kept_modules
  FROM public.modules m
  JOIN public.formation_modules fm ON fm.module_id = m.id
  WHERE fm.formation_id = v_formation;

  RAISE NOTICE '🧹 Cleanup Capa ≤ 3,5 T terminé.';
  RAISE NOTICE '   ▸ Modules legacy supprimés : %', v_deleted_modules;
  RAISE NOTICE '   ▸ Questions legacy supprimées : %', v_deleted_questions;
  RAISE NOTICE '   ▸ Modules v2 conservés : %', v_kept_modules;

  IF v_kept_modules <> 6 THEN
    RAISE WARNING 'Attention : nombre de modules conservés = % (attendu : 6)', v_kept_modules;
  END IF;
END
$cleanup$;
