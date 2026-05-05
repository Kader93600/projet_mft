-- =====================================================================
-- GOTRM (RNCP 40990) — EXAMEN BLANC SYNTHÉTIQUE BC02
-- 15 QCM + 1 QR en 45 min, seuil 50 %.
-- Couvre les 2 modules du bloc « Piloter les trafics sous-traités ».
-- =====================================================================

DO $eb_bc02$
DECLARE
  v_formation uuid; v_bloc int; v_module uuid; v_quiz uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc.'; END IF;

  DELETE FROM public.modules WHERE slug = 'gotrm-bc02-examen-blanc-synthese';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'BC02 — Examen blanc synthétique',
    'gotrm-bc02-examen-blanc-synthese', v_bloc,
    'Examen blanc synthétique du bloc BC02 : 15 QCM + 1 QR, 45 minutes, seuil 50 %. Couvre les 2 modules sur la sous-traitance (appels d''offres et suivi qualité).',
    'avance', 45, 210
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 210, true) ON CONFLICT DO NOTHING;

  -- =================================================================
  -- LEÇON UNIQUE : consignes
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Consignes — Examen blanc BC02',
    'gotrm-bc02-examen-blanc-consignes', 1, 5,
$cbc02$
# Consignes — Examen blanc BC02

Cet examen blanc couvre l'ensemble du bloc BC02 — **Piloter les trafics sous-traités**.

## Format

| Élément | Détail |
|---|---|
| Durée | **45 minutes** chronométrées |
| Composition | **15 QCM** + **1 question rédigée** |
| Seuil de réussite | **50 %** |

## Couverture

- **BC02-01** : appels d'offres et sélection des sous-traitants (cadre juridique, vérifications, AO, évaluation, contrat)
- **BC02-02** : suivi qualité, conformité, audits, plans d'amélioration, désengagement

## Conseils

- Ce bloc est **fondamental** pour le métier de commissionnaire (40-60 % du CA en sous-traitance).
- Pour la QR (cas pratique), structure ta réponse en étapes claires : diagnostic → analyse → plan d'action → ROI.
- Maîtrise les références légales : **L. 8222-1** (vérifications), **L. 3221-3** (cascade), **L. 3222-3** (prix abusivement bas), **loi 1975**.

Bon courage !
$cbc02$,
'Consignes : 15 QCM + 1 QR en 45 min, seuil 50 %.'
  );

  -- =================================================================
  -- QUIZ EXAMEN BLANC BC02
  -- =================================================================
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (
    v_module,
    'Examen blanc synthétique BC02 — 15 QCM + 1 QR (45 min)',
    'Synthèse du bloc BC02 sur 45 min. 15 QCM répartis sur BC02-01 et BC02-02 + 1 QR cas pratique. Seuil 50 %.',
    'examen', 2700, 50
  ) RETURNING id INTO v_quiz;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, qb.id, ROW_NUMBER() OVER (ORDER BY qb.source_ref)
  FROM public.question_bank qb
  WHERE qb.formation_id = v_formation
    AND qb.source_ref IN (
      -- BC02-01 (8 QCM) — appels d'offres et sélection
      'mft-2026-gotrm:bc02-01:qcm:1',  -- part CA sous-traitance
      'mft-2026-gotrm:bc02-01:qcm:3',  -- L. 8222-1
      'mft-2026-gotrm:bc02-01:qcm:4',  -- complicité travail dissimulé
      'mft-2026-gotrm:bc02-01:qcm:6',  -- prix abusivement bas
      'mft-2026-gotrm:bc02-01:qcm:8',  -- cascade
      'mft-2026-gotrm:bc02-01:qcm:11', -- 8 sections cahier des charges
      'mft-2026-gotrm:bc02-01:qcm:16', -- RPC obligation
      'mft-2026-gotrm:bc02-01:qcm:19', -- responsabilité commissionnaire
      -- BC02-02 (7 QCM) — suivi et audit
      'mft-2026-gotrm:bc02-02:qcm:1',  -- scorecard 100 pts
      'mft-2026-gotrm:bc02-02:qcm:2',  -- audit semestriel
      'mft-2026-gotrm:bc02-02:qcm:4',  -- non-conformité majeure 30j
      'mft-2026-gotrm:bc02-02:qcm:7',  -- méthode 4R
      'mft-2026-gotrm:bc02-02:qcm:8',  -- L. 442-1 rupture brutale
      'mft-2026-gotrm:bc02-02:qcm:9',  -- préavis raisonnable
      'mft-2026-gotrm:bc02-02:qcm:13', -- décision désengagement
      -- 1 QR cas pratique
      'mft-2026-gotrm:bc02-01:qr:1'    -- vérification sous-traitant -22 % marché
    );

  RAISE NOTICE '✅ GOTRM examen blanc BC02 chargé : 15 QCM + 1 QR, 45 min, seuil 50 %%.';
END
$eb_bc02$;
