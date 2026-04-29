-- =====================================================================
-- E2E SEED — Provisionne les fixtures pour les tests Playwright
--
-- Pré-requis :
--   - Les 2 comptes auth doivent exister (à créer manuellement dans
--     Supabase Studio → Authentication → Users) :
--       * stagiaire-e2e@test.local
--       * formateur-e2e@test.local
--
-- Ce script :
--   1) Configure leurs rôles (student / trainer)
--   2) Bypass l'onboarding
--   3) Rattache le formateur à la formation capacite-3-5t
--   4) Inscrit le stagiaire à cette formation
--   5) Crée un quiz mixte QCM+QR de test si aucun n'existe
--   6) Affiche en sortie l'UUID du quiz à mettre dans E2E_QUIZ_ID
--
-- Idempotent : peut être rejoué sans casse.
-- =====================================================================

DO $e2e$
DECLARE
  v_student uuid;
  v_trainer uuid;
  v_formation_id uuid;
  v_quiz_id uuid;
  v_qcm_id uuid;
  v_qr_id uuid;
BEGIN
  -- ─── 0) Récupérer les comptes ─────────────────────────────────────
  SELECT id INTO v_student FROM public.profiles
   WHERE email = 'stagiaire-e2e@test.local';
  SELECT id INTO v_trainer FROM public.profiles
   WHERE email = 'formateur-e2e@test.local';

  IF v_student IS NULL THEN
    RAISE EXCEPTION 'Compte stagiaire-e2e@test.local introuvable. '
      'Créez-le d''abord dans Supabase Studio → Authentication → Users.';
  END IF;
  IF v_trainer IS NULL THEN
    RAISE EXCEPTION 'Compte formateur-e2e@test.local introuvable. '
      'Créez-le d''abord dans Supabase Studio → Authentication → Users.';
  END IF;

  -- ─── 1) Rôles ────────────────────────────────────────────────────
  UPDATE public.profiles SET role = 'student' WHERE id = v_student;
  UPDATE public.profiles SET role = 'trainer' WHERE id = v_trainer;

  -- ─── 2) Bypass onboarding ────────────────────────────────────────
  UPDATE public.profiles
     SET onboarding_completed_at = COALESCE(onboarding_completed_at, now())
   WHERE id IN (v_student, v_trainer);

  -- ─── 3) Récupérer la formation cible ─────────────────────────────
  SELECT id INTO v_formation_id FROM public.formations
   WHERE slug = 'capacite-3-5t';
  IF v_formation_id IS NULL THEN
    RAISE EXCEPTION 'Formation capacite-3-5t introuvable. '
      'Jouez d''abord supabase/formations_seed.sql ou similaire.';
  END IF;

  -- ─── 4) Rattacher le formateur ──────────────────────────────────
  INSERT INTO public.trainer_formations (trainer_id, formation_id)
  VALUES (v_trainer, v_formation_id)
  ON CONFLICT DO NOTHING;

  -- ─── 5) Inscrire le stagiaire ───────────────────────────────────
  IF NOT EXISTS (
    SELECT 1 FROM public.enrollments
     WHERE user_id = v_student AND formation_slug = 'capacite-3-5t'
  ) THEN
    INSERT INTO public.enrollments (
      user_id, formation_slug, formation_id, status, session_label
    ) VALUES (
      v_student, 'capacite-3-5t', v_formation_id, 'en_cours', 'e2e-session'
    );
  END IF;

  -- ─── 6) Quiz mixte de test ──────────────────────────────────────
  -- Réutilise un quiz existant marqué pour les tests, sinon en crée un
  SELECT id INTO v_quiz_id FROM public.quizzes
   WHERE title = '[E2E] Examen mixte Capacité -3,5T'
   LIMIT 1;

  IF v_quiz_id IS NULL THEN
    INSERT INTO public.quizzes (
      title, type, pass_threshold, timer_enabled, time_limit_s,
      show_explanations_mode
    ) VALUES (
      '[E2E] Examen mixte Capacité -3,5T',
      'examen',
      60,
      false,
      NULL,
      'always'
    )
    RETURNING id INTO v_quiz_id;

    -- Lier le quiz à la formation
    INSERT INTO public.formation_quizzes (formation_id, quiz_id)
    VALUES (v_formation_id, v_quiz_id)
    ON CONFLICT DO NOTHING;
  END IF;

  -- ─── 7) Garantir au moins 1 QCM + 1 QR liés au quiz ─────────────
  -- Tente d'utiliser la banque premium déjà chargée
  SELECT id INTO v_qcm_id FROM public.question_bank
   WHERE formation_id = v_formation_id
     AND type = 'qcm'
     AND active = true
   ORDER BY created_at
   LIMIT 1;

  SELECT id INTO v_qr_id FROM public.question_bank
   WHERE formation_id = v_formation_id
     AND type = 'qr'
     AND active = true
   ORDER BY created_at
   LIMIT 1;

  IF v_qcm_id IS NULL OR v_qr_id IS NULL THEN
    RAISE EXCEPTION 'Banque incomplète : il faut au moins 1 QCM et 1 QR '
      'actifs dans question_bank pour la formation capacite-3-5t. '
      'Jouez supabase/capa_questions_premium.sql d''abord.';
  END IF;

  -- Lier les questions au quiz si pas déjà fait
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  VALUES (v_quiz_id, v_qcm_id, 1)
  ON CONFLICT DO NOTHING;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  VALUES (v_quiz_id, v_qr_id, 2)
  ON CONFLICT DO NOTHING;

  -- ─── 8) Affichage final ─────────────────────────────────────────
  RAISE NOTICE '';
  RAISE NOTICE '════════════════════════════════════════════════════════';
  RAISE NOTICE 'E2E SEED OK';
  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE 'Stagiaire : % (id %)', 'stagiaire-e2e@test.local', v_student;
  RAISE NOTICE 'Formateur : % (id %)', 'formateur-e2e@test.local', v_trainer;
  RAISE NOTICE 'Formation : capacite-3-5t (id %)', v_formation_id;
  RAISE NOTICE '';
  RAISE NOTICE '>>> Mettez ceci dans .env.test :';
  RAISE NOTICE 'E2E_QUIZ_ID=%', v_quiz_id;
  RAISE NOTICE '════════════════════════════════════════════════════════';
END
$e2e$;

-- Vérification rapide
SELECT
  q.id        AS quiz_id,
  q.title,
  (SELECT count(*) FROM public.quiz_question_bank WHERE quiz_id = q.id) AS questions
FROM public.quizzes q
WHERE q.title = '[E2E] Examen mixte Capacité -3,5T';
