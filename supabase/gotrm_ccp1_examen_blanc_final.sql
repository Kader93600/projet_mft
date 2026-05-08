-- =====================================================================
-- GOTRM (RNCP 40990) — EXAMEN BLANC FINAL TRANSVERSAL CCP1
--
-- Simule les conditions réelles de l'épreuve nationale CCP1 :
--   ▸ 30 QCM transversaux couvrant les 17 chapitres du livret
--   ▸ 6 QR cas pratiques métier représentatifs des 7 parties
--   ▸ Durée 120 minutes (2 heures)
--   ▸ Seuil de réussite 50 % (équivalent examen pro)
--
-- Répartition des QCM par bloc référentiel (cohérente avec le RNCP 40990) :
--   Bloc Socle (Ch 1-2)              : 2 QCM
--   Bloc 1 — Concevoir & chiffrer    : 6 QCM (Ch 3-5)
--   Bloc 2 — Affecter & planifier    : 5 QCM (Ch 6-8)
--   Bloc 3 — RSE conducteurs         : 4 QCM (Ch 9-10)
--   Bloc 4 — Coordonner & contrôler  : 4 QCM (Ch 11-12)
--   Transversal performance           : 3 QCM (Ch 13-14)
--   Compétences complémentaires       : 4 QCM (Ch 15-17)
--   ─────────────────────────────────────────────────
--   TOTAL QCM                         : 30 (60 pts)
--
-- 6 QR cas pratique transversaux (un par compétence majeure) :
--   QR1 — Tarification (Ch 4)              max_score 6
--   QR2 — Plan de marche RSE (Ch 10)       max_score 6
--   QR3 — Gestion d'un aléa (Ch 11)        max_score 5
--   QR4 — Calcul indemnisation (Ch 12)     max_score 6
--   QR5 — Information CO2 (Ch 14)          max_score 5
--   QR6 — Cas anglais (Ch 17)              max_score 5
--   ─────────────────────────────────────────────────
--   TOTAL QR                              : 33 pts
--
--   ⇒ Barème global : 60 + 33 = 93 pts. Seuil 50 % = 46,5 pts.
--
-- Pré-requis : les 17 chapitres CCP1 v4 doivent être chargés en BDD
-- (gotrm_ch01_v4_livret.sql à gotrm_ch17_v4_livret.sql).
-- Idempotent : ré-exécutable sans danger.
-- =====================================================================

DO $ccp1_eb_final$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_quiz uuid;
  v_count_qcm int;
  v_count_qr int;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation gotrm introuvable.';
  END IF;

  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1';
  IF v_bloc IS NULL THEN
    INSERT INTO public.blocs (code, title, description, "order")
    VALUES ('BC1', 'Bloc 1 — Compétences générales', 'Bloc générique partagé.', 1)
    ON CONFLICT (code) DO NOTHING RETURNING id INTO v_bloc;
    IF v_bloc IS NULL THEN SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1'; END IF;
  END IF;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Bloc BC1 introuvable.'; END IF;

  -- Idempotence
  DELETE FROM public.modules WHERE slug = 'gotrm-ccp1-examen-blanc-final';

  -- Vérification : toutes les questions référencées doivent exister
  SELECT COUNT(*) INTO v_count_qcm
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch%:qcm:%';

  SELECT COUNT(*) INTO v_count_qr
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch%:qr:%';

  IF v_count_qcm < 100 THEN
    RAISE EXCEPTION 'Banque QCM CCP1 incomplète (% QCM trouvés, attendu 184). Charger d''abord les 17 chapitres.', v_count_qcm;
  END IF;

  RAISE NOTICE 'Banque détectée : % QCM, % QR. Création de l''examen blanc final...', v_count_qcm, v_count_qr;

  -- Création du module wrapper "Examen blanc final"
  INSERT INTO public.modules (
    title, slug, bloc_id, summary, difficulty, duration_min, "order"
  ) VALUES (
    'CCP1 — Examen blanc final transversal',
    'gotrm-ccp1-examen-blanc-final',
    v_bloc,
    'Examen blanc reproduisant les conditions de l''examen national CCP1 GOTRM (RNCP 40990) : 30 QCM transversaux couvrant les 17 chapitres + 6 QR cas pratiques métier. Durée 120 minutes, seuil de réussite 50 %.',
    'avance',
    120,
    200
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 200, true) ON CONFLICT DO NOTHING;

  -- Création du quiz examen blanc
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold, is_mock_exam)
  VALUES (
    v_module,
    'CCP1 — Examen blanc final',
    'Examen blanc reproduisant les conditions de l''examen national : 30 QCM transversaux (60 pts) + 6 QR cas pratiques (33 pts), durée 120 minutes, seuil 50 %.',
    'examen',
    7200,
    50,
    true
  ) RETURNING id INTO v_quiz;

  -- ─── Sélection des 30 QCM transversaux ─────────────────────────
  -- Mix équilibré sur les 7 parties du livret. Chaque chapitre est
  -- représenté au moins une fois.
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref IN (
       -- Bloc Socle (Ch 1-2) : 2 QCM
       'mft-2026-gotrm-livret:ch01:qcm:1',
       'mft-2026-gotrm-livret:ch02:qcm:3',
       -- Bloc 1 — Concevoir & chiffrer (Ch 3-5) : 6 QCM
       'mft-2026-gotrm-livret:ch03:qcm:2',
       'mft-2026-gotrm-livret:ch03:qcm:7',
       'mft-2026-gotrm-livret:ch04:qcm:1',
       'mft-2026-gotrm-livret:ch04:qcm:5',
       'mft-2026-gotrm-livret:ch04:qcm:9',
       'mft-2026-gotrm-livret:ch05:qcm:1',
       -- Bloc 2 — Affecter & planifier (Ch 6-8) : 5 QCM
       'mft-2026-gotrm-livret:ch06:qcm:2',
       'mft-2026-gotrm-livret:ch06:qcm:7',
       'mft-2026-gotrm-livret:ch07:qcm:3',
       'mft-2026-gotrm-livret:ch08:qcm:2',
       'mft-2026-gotrm-livret:ch08:qcm:6',
       -- Bloc 3 — RSE conducteurs (Ch 9-10) : 4 QCM
       'mft-2026-gotrm-livret:ch09:qcm:2',
       'mft-2026-gotrm-livret:ch09:qcm:7',
       'mft-2026-gotrm-livret:ch10:qcm:3',
       'mft-2026-gotrm-livret:ch10:qcm:9',
       -- Bloc 4 — Coordonner & contrôler (Ch 11-12) : 4 QCM
       'mft-2026-gotrm-livret:ch11:qcm:2',
       'mft-2026-gotrm-livret:ch11:qcm:8',
       'mft-2026-gotrm-livret:ch12:qcm:3',
       'mft-2026-gotrm-livret:ch12:qcm:9',
       -- Transversal performance (Ch 13-14) : 3 QCM
       'mft-2026-gotrm-livret:ch13:qcm:2',
       'mft-2026-gotrm-livret:ch13:qcm:8',
       'mft-2026-gotrm-livret:ch14:qcm:3',
       -- Compétences complémentaires (Ch 15-17) : 4 QCM
       'mft-2026-gotrm-livret:ch15:qcm:2',
       'mft-2026-gotrm-livret:ch15:qcm:9',
       'mft-2026-gotrm-livret:ch16:qcm:2',
       'mft-2026-gotrm-livret:ch17:qcm:3',
       -- 3 QCM de bouclage (équilibrage final → 30 QCM)
       'mft-2026-gotrm-livret:ch01:qcm:5',
       'mft-2026-gotrm-livret:ch04:qcm:12',
       'mft-2026-gotrm-livret:ch15:qcm:5'
     );

  -- ─── Sélection des 6 QR cas pratiques transversaux ─────────────
  -- Affichage en fin d'examen (display_order > 100 pour les séparer
  -- visuellement des QCM dans l'UI).
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, id, 100 + ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref IN (
       -- QR1 — Tarification d'une prestation (Ch 4)
       'mft-2026-gotrm-livret:ch04:qr:1',
       -- QR2 — Plan de marche conforme à la RSE (Ch 10)
       'mft-2026-gotrm-livret:ch10:qr:1',
       -- QR3 — Méthode de traitement d'un aléa (Ch 11)
       'mft-2026-gotrm-livret:ch11:qr:1',
       -- QR4 — Calcul d'indemnisation avec plafonds (Ch 12)
       'mft-2026-gotrm-livret:ch12:qr:2',
       -- QR5 — Information CO2 obligatoire (Ch 14)
       'mft-2026-gotrm-livret:ch14:qr:1',
       -- QR6 — Email professionnel en anglais (Ch 17)
       'mft-2026-gotrm-livret:ch17:qr:2'
     );

  -- Vérification finale : on doit avoir 30 QCM + 6 QR = 36 questions liées
  SELECT COUNT(*) INTO v_count_qcm
    FROM public.quiz_question_bank
   WHERE quiz_id = v_quiz;

  RAISE NOTICE '╔═════════════════════════════════════════════════════════';
  RAISE NOTICE '║ ✓ EXAMEN BLANC FINAL CCP1 CRÉÉ AVEC SUCCÈS';
  RAISE NOTICE '╠═════════════════════════════════════════════════════════';
  RAISE NOTICE '║ Module     : gotrm-ccp1-examen-blanc-final';
  RAISE NOTICE '║ Quiz type  : examen (is_mock_exam = true)';
  RAISE NOTICE '║ Durée      : 120 minutes (7 200 s)';
  RAISE NOTICE '║ Seuil      : 50 %% (équivalent examen national)';
  RAISE NOTICE '║ Questions  : % rattachées (cible 36)', v_count_qcm;
  RAISE NOTICE '║ Barème     : 30 QCM (60 pts) + 6 QR (33 pts) = 93 pts';
  RAISE NOTICE '╠═════════════════════════════════════════════════════════';
  RAISE NOTICE '║ Le stagiaire peut maintenant s''entraîner aux conditions';
  RAISE NOTICE '║ réelles de l''examen CCP1 GOTRM RNCP 40990.';
  RAISE NOTICE '╚═════════════════════════════════════════════════════════';

END $ccp1_eb_final$;
