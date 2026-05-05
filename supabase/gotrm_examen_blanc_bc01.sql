-- =====================================================================
-- GOTRM (RNCP 40990) — EXAMEN BLANC SYNTHÉTIQUE BC01
-- 30 QCM + 2 QR en 90 min, seuil 50 %.
-- Couvre les 10 modules du bloc « Concevoir, organiser et piloter ».
-- =====================================================================

DO $eb_bc01$
DECLARE
  v_formation uuid; v_bloc int; v_module uuid; v_quiz uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc.'; END IF;

  DELETE FROM public.modules WHERE slug = 'gotrm-bc01-examen-blanc-synthese';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'BC01 — Examen blanc synthétique',
    'gotrm-bc01-examen-blanc-synthese', v_bloc,
    'Examen blanc synthétique du bloc BC01 : 30 QCM + 2 QR, 90 minutes, seuil 50 %. Couvre les 10 modules du cœur métier (demande, contrat, cotation, R561, douane, planification, ADR/ATP, relation client, litiges, KPI).',
    'avance', 90, 200
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 200, true) ON CONFLICT DO NOTHING;

  -- =================================================================
  -- LEÇON UNIQUE : consignes de l'examen blanc
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Consignes — Examen blanc BC01',
    'gotrm-bc01-examen-blanc-consignes', 1, 5,
$cbc01$
# Consignes — Examen blanc BC01

Cet examen blanc couvre l'ensemble du bloc BC01 — **Concevoir, organiser et piloter des opérations de transport routier de marchandises**.

## Format

| Élément | Détail |
|---|---|
| Durée | **90 minutes** chronométrées |
| Composition | **30 QCM** + **2 questions rédigées** |
| Seuil de réussite | **50 %** (équivalent du seuil examen réel) |
| Calculs | Calculatrice non scientifique autorisée |
| Documents | Aucun document autorisé |

## Conseils

- Lis chaque QCM en entier avant de répondre — ne te précipite pas sur la première option vraisemblable.
- Pour les calculs : pose le calcul, ne tente pas de tout faire de tête.
- Pour les QR : structure ta réponse (paragraphes, listes, tableaux). Un correcteur valorise la **clarté de la démarche**, pas seulement le résultat.
- Si tu bloques sur une question, **passe** et reviens-y à la fin.

## Couverture pédagogique

Les 30 QCM sont distribués sur les 10 modules à raison de 3 questions par module. Les 2 QR portent sur :
- Cas pratique de **calcul CRT et tarification** (modules cotation + R561)
- Cas pratique de **gestion d'un litige** (modules contrat + litiges)

Bon courage !
$cbc01$,
'Consignes : 30 QCM + 2 QR en 90 min, seuil 50 %, calculatrice non scientifique autorisée.'
  );

  -- =================================================================
  -- QUIZ EXAMEN BLANC BC01
  -- =================================================================
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (
    v_module,
    'Examen blanc synthétique BC01 — 30 QCM + 2 QR (90 min)',
    'Synthèse du bloc BC01 sur 90 min. 30 QCM répartis sur les 10 modules + 2 QR cas pratiques. Seuil 50 %.',
    'examen', 5400, 50
  ) RETURNING id INTO v_quiz;

  -- 30 QCM (3 par module BC01-01 à BC01-10) + 2 QR
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, qb.id, ROW_NUMBER() OVER (ORDER BY qb.source_ref)
  FROM public.question_bank qb
  WHERE qb.formation_id = v_formation
    AND qb.source_ref IN (
      -- BC01-01 (3 QCM)
      'mft-2026-gotrm:bc01-01:qcm:1', 'mft-2026-gotrm:bc01-01:qcm:5', 'mft-2026-gotrm:bc01-01:qcm:10',
      -- BC01-02 (3 QCM)
      'mft-2026-gotrm:bc01-02:qcm:1', 'mft-2026-gotrm:bc01-02:qcm:5', 'mft-2026-gotrm:bc01-02:qcm:8',
      -- BC01-03 (3 QCM)
      'mft-2026-gotrm:bc01-03:qcm:5', 'mft-2026-gotrm:bc01-03:qcm:12', 'mft-2026-gotrm:bc01-03:qcm:18',
      -- BC01-04 (3 QCM)
      'mft-2026-gotrm:bc01-04:qcm:3', 'mft-2026-gotrm:bc01-04:qcm:6', 'mft-2026-gotrm:bc01-04:qcm:11',
      -- BC01-05 (3 QCM)
      'mft-2026-gotrm:bc01-05:qcm:1', 'mft-2026-gotrm:bc01-05:qcm:6', 'mft-2026-gotrm:bc01-05:qcm:15',
      -- BC01-06 (3 QCM)
      'mft-2026-gotrm:bc01-06:qcm:1', 'mft-2026-gotrm:bc01-06:qcm:8', 'mft-2026-gotrm:bc01-06:qcm:15',
      -- BC01-07 (3 QCM)
      'mft-2026-gotrm:bc01-07:qcm:2', 'mft-2026-gotrm:bc01-07:qcm:6', 'mft-2026-gotrm:bc01-07:qcm:14',
      -- BC01-08 (3 QCM)
      'mft-2026-gotrm:bc01-08:qcm:5', 'mft-2026-gotrm:bc01-08:qcm:11', 'mft-2026-gotrm:bc01-08:qcm:17',
      -- BC01-09 (3 QCM)
      'mft-2026-gotrm:bc01-09:qcm:4', 'mft-2026-gotrm:bc01-09:qcm:5', 'mft-2026-gotrm:bc01-09:qcm:8',
      -- BC01-10 (3 QCM)
      'mft-2026-gotrm:bc01-10:qcm:2', 'mft-2026-gotrm:bc01-10:qcm:7', 'mft-2026-gotrm:bc01-10:qcm:11',
      -- 2 QR cas pratiques
      'mft-2026-gotrm:bc01-03:qr:1', 'mft-2026-gotrm:bc01-04:qr:1'
    );

  RAISE NOTICE '✅ GOTRM examen blanc BC01 chargé : 30 QCM + 2 QR, 90 min, seuil 50 %%.';
END
$eb_bc01$;
