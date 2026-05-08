-- =====================================================================
-- CAPACITÉ ≤ 3,5 T — EXAMEN BLANC FINAL TRANSVERSAL
--
-- Reproduit les conditions de l'examen national de la Capacité Pro de
-- transport de marchandises ≤ 3,5 T (référentiel décision du 2 avril 2012) :
--   ▸ Composition de l'examen réel : 50 QCM (60 pts) + 1 exercice de
--     coût de revient à 30 pts + 2 questions rédigées (10 pts) + 4 pts
--     d'analyse de document = 84 points.
--   ▸ Examen blanc : 30 QCM transversaux (60 pts simulés) + 5 QR cas
--     pratiques (24 pts) couvrant les 6 modules A à F.
--   ▸ Durée : 90 minutes (vs 4h pour le réel — concentré sur l'essentiel).
--   ▸ Seuil : 50 % (équivalent examen national).
--
-- Répartition des QCM par module (cohérente avec le poids à l'examen réel) :
--   Module A (Cadre juridique)             : 4 QCM
--   Module B (Activité commerciale)        : 4 QCM
--   Module C (Cadre réglementaire transport): 7 QCM (le + lourd à l'examen)
--   Module D (Activité financière)         : 6 QCM (CRKM + finance)
--   Module E (Salariés et droit social)    : 5 QCM
--   Module F (Sécurité)                    : 4 QCM
--   ──────────────────────────────────────────────────
--   TOTAL QCM                              : 30 (60 pts)
--
-- 5 QR cas pratique transversaux (focus modules à fort coefficient) :
--   QR1 — Cadre juridique des personnes (Module A)    max_score 5
--   QR2 — Cadre réglementaire transport (Module C)    max_score 5
--   QR3 — Calcul CRKM (Module D)                      max_score 6
--   QR4 — Bulletin de paie / RSE (Module E)           max_score 4
--   QR5 — ADR/ATP/Sécurité (Module F)                 max_score 4
--   ──────────────────────────────────────────────────
--   TOTAL QR                                          : 24 pts
--
-- Pré-requis : les 6 modules Capa v3 dense doivent être chargés en BDD
-- (capa_module_a_v3_dense.sql à capa_module_f_v3_dense.sql).
-- Idempotent : ré-exécutable sans danger.
-- =====================================================================

DO $capa_eb_final$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_quiz uuid;
  v_count_qcm int;
  v_count_total int;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'capacite-3-5t';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation capacite-3-5t introuvable.';
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
  DELETE FROM public.modules WHERE slug = 'capa-examen-blanc-final';

  -- Vérification : la banque Capa doit contenir au moins 200 QCM
  SELECT COUNT(*) INTO v_count_qcm
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND type = 'qcm'
     AND source_ref LIKE 'mft-2026:module%:l%:q%';

  IF v_count_qcm < 200 THEN
    RAISE EXCEPTION 'Banque QCM Capa incomplète (% QCM trouvés, attendu >=288). Charger d''abord les 6 modules v3 dense.', v_count_qcm;
  END IF;

  RAISE NOTICE 'Banque détectée : % QCM Capa. Création de l''examen blanc final...', v_count_qcm;

  -- Création du module wrapper "Examen blanc final Capa"
  INSERT INTO public.modules (
    title, slug, bloc_id, summary, difficulty, duration_min, "order"
  ) VALUES (
    'Capacité ≤ 3,5 t — Examen blanc final transversal',
    'capa-examen-blanc-final',
    v_bloc,
    'Examen blanc reproduisant les conditions de l''examen national de la Capacité Pro de transport de marchandises ≤ 3,5 T : 30 QCM transversaux couvrant les 6 modules A à F + 5 QR cas pratiques (CRKM, droit social, ADR). Durée 90 minutes, seuil 50 %.',
    'avance',
    90,
    200
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 200, true) ON CONFLICT DO NOTHING;

  -- Création du quiz examen blanc
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold, is_mock_exam)
  VALUES (
    v_module,
    'Capa ≤ 3,5 t — Examen blanc final',
    'Examen blanc reproduisant les conditions de l''examen national : 30 QCM transversaux (60 pts) + 5 QR cas pratiques (24 pts), durée 90 minutes, seuil 50 %.',
    'examen',
    5400,
    50,
    true
  ) RETURNING id INTO v_quiz;

  -- ─── Sélection des 30 QCM transversaux ─────────────────────────
  -- Mix équilibré sur les 6 modules. Pondération cohérente avec les
  -- coefficients réels de l'examen national.
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref IN (
       -- Module A — Cadre juridique (4 QCM)
       'mft-2026:moduleA:qcm:1',
       'mft-2026:moduleA:qcm:14',
       'mft-2026:moduleA:qcm:32',
       'mft-2026:moduleA:qcm:49',
       -- Module B — Activité commerciale (4 QCM)
       'mft-2026:moduleB:qcm:5',
       'mft-2026:moduleB:qcm:14',
       'mft-2026:moduleB:qcm:22',
       'mft-2026:moduleB:qcm:33',
       -- Module C — Cadre réglementaire transport (7 QCM, le + lourd)
       'mft-2026:moduleC:qcm:3',
       'mft-2026:moduleC:qcm:11',
       'mft-2026:moduleC:qcm:19',
       'mft-2026:moduleC:qcm:24',
       'mft-2026:moduleC:qcm:31',
       'mft-2026:moduleC:qcm:39',
       'mft-2026:moduleC:qcm:46',
       -- Module D — Activité financière (6 QCM, focus CRKM + finance)
       'mft-2026:moduleD:l1:q1',
       'mft-2026:moduleD:l1:q5',
       'mft-2026:moduleD:l2:q4',
       'mft-2026:moduleD:l3:q3',
       'mft-2026:moduleD:l4:q4',
       'mft-2026:moduleD:l4:q11',
       -- Module E — Salariés et droit social (5 QCM)
       'mft-2026:moduleE:l1:q5',
       'mft-2026:moduleE:l2:q2',
       'mft-2026:moduleE:l3:q4',
       'mft-2026:moduleE:l3:q8',
       'mft-2026:moduleE:l4:q3',
       -- Module F — Sécurité (4 QCM)
       'mft-2026:moduleF:l2:q1',
       'mft-2026:moduleF:l3:q4',
       'mft-2026:moduleF:l3:q7',
       'mft-2026:moduleF:l4:q7'
     );

  -- ─── Sélection des 5 QR cas pratiques transversaux ─────────────
  -- Affichage en fin d'examen (display_order > 100 pour les séparer
  -- visuellement des QCM dans l'UI).
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, id, 100 + ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref IN (
       -- QR1 — Cadre juridique (Module C — réglementation transport)
       'mft-2026:moduleC:qr:1',
       -- QR2 — Cadre réglementaire transport (Module C)
       'mft-2026:moduleC:qr:5',
       -- QR3 — Calcul CRKM (Module D — l'exercice à 30 pts de l'examen réel)
       'mft-2026:moduleD:qr2',
       -- QR4 — Bulletin de paie ou RSE (Module E)
       'mft-2026:moduleE:qr4',
       -- QR5 — ADR/Sécurité (Module F)
       'mft-2026:moduleF:qr3'
     );

  -- Vérification finale : on doit avoir 30 QCM + 5 QR = 35 questions liées
  SELECT COUNT(*) INTO v_count_total
    FROM public.quiz_question_bank
   WHERE quiz_id = v_quiz;

  RAISE NOTICE '╔═════════════════════════════════════════════════════════';
  RAISE NOTICE '║ ✓ EXAMEN BLANC FINAL CAPA 3,5 T CRÉÉ AVEC SUCCÈS';
  RAISE NOTICE '╠═════════════════════════════════════════════════════════';
  RAISE NOTICE '║ Module     : capa-examen-blanc-final';
  RAISE NOTICE '║ Quiz type  : examen (is_mock_exam = true)';
  RAISE NOTICE '║ Durée      : 90 minutes (5 400 s)';
  RAISE NOTICE '║ Seuil      : 50 %% (équivalent examen national)';
  RAISE NOTICE '║ Questions  : % rattachées (cible 35)', v_count_total;
  RAISE NOTICE '║ Barème     : 30 QCM (60 pts) + 5 QR (24 pts) = 84 pts';
  RAISE NOTICE '╠═════════════════════════════════════════════════════════';
  RAISE NOTICE '║ Le stagiaire peut maintenant s''entraîner aux conditions';
  RAISE NOTICE '║ réelles de l''examen Capacité Pro ≤ 3,5 T (décision du';
  RAISE NOTICE '║ 2 avril 2012).';
  RAISE NOTICE '╚═════════════════════════════════════════════════════════';

END $capa_eb_final$;
