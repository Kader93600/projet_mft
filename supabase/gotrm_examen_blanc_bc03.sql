-- =====================================================================
-- GOTRM (RNCP 40990) — EXAMEN BLANC SYNTHÉTIQUE BC03
-- 15 QCM + 1 QR en 45 min, seuil 50 %.
-- Couvre les 2 modules du bloc « Optimiser les moyens ».
-- =====================================================================

DO $eb_bc03$
DECLARE
  v_formation uuid; v_bloc int; v_module uuid; v_quiz uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc.'; END IF;

  DELETE FROM public.modules WHERE slug = 'gotrm-bc03-examen-blanc-synthese';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'BC03 — Examen blanc synthétique',
    'gotrm-bc03-examen-blanc-synthese', v_bloc,
    'Examen blanc synthétique du bloc BC03 : 15 QCM + 1 QR, 45 minutes, seuil 50 %. Couvre les 2 modules sur l''optimisation des moyens (coût de revient/investissements et RSE/transition énergétique).',
    'avance', 45, 220
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 220, true) ON CONFLICT DO NOTHING;

  -- =================================================================
  -- LEÇON UNIQUE : consignes
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Consignes — Examen blanc BC03',
    'gotrm-bc03-examen-blanc-consignes', 1, 5,
$cbc03$
# Consignes — Examen blanc BC03

Cet examen blanc couvre l'ensemble du bloc BC03 — **Optimiser les moyens liés à l'activité transport**.

## Format

| Élément | Détail |
|---|---|
| Durée | **45 minutes** chronométrées |
| Composition | **15 QCM** + **1 question rédigée** |
| Seuil de réussite | **50 %** |
| Calculs | Calculatrice non scientifique autorisée |

## Couverture

- **BC03-01** : décomposition coûts, calcul CRT, achat/leasing, ROI investissements
- **BC03-02** : démarche RSE, transition énergétique, ZFE, KPI rentabilité durable

## Conseils

- La **QR cas pratique** est calculatoire (calcul d'un coût km commercial, ROI, ou plan de transition). Pose les calculs étape par étape.
- Maîtrise les **valeurs marché 2026** : porteur 19 t ~ 1,22-1,30 €/km, marge nette TRM 4-12 %, retour à vide cible < 15 %.
- Pour la RSE : **3 piliers (E/S/G)**, certifications (Objectif CO2, EcoVadis, ISO 14001), suramortissement +40 %.

Bon courage !
$cbc03$,
'Consignes : 15 QCM + 1 QR en 45 min, seuil 50 %.'
  );

  -- =================================================================
  -- QUIZ EXAMEN BLANC BC03
  -- =================================================================
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (
    v_module,
    'Examen blanc synthétique BC03 — 15 QCM + 1 QR (45 min)',
    'Synthèse du bloc BC03 sur 45 min. 15 QCM répartis sur BC03-01 et BC03-02 + 1 QR cas pratique. Seuil 50 %.',
    'examen', 2700, 50
  ) RETURNING id INTO v_quiz;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, qb.id, ROW_NUMBER() OVER (ORDER BY qb.source_ref)
  FROM public.question_bank qb
  WHERE qb.formation_id = v_formation
    AND qb.source_ref IN (
      -- BC03-01 (8 QCM) — coût de revient et investissements
      'mft-2026-gotrm:bc03-01:qcm:1',  -- coût acquisition porteur
      'mft-2026-gotrm:bc03-01:qcm:2',  -- carburant + conducteur ~30 % chacun
      'mft-2026-gotrm:bc03-01:qcm:9',  -- formule CRT
      'mft-2026-gotrm:bc03-01:qcm:11', -- retour vide doublé
      'mft-2026-gotrm:bc03-01:qcm:13', -- achat propriété
      'mft-2026-gotrm:bc03-01:qcm:15', -- LLD service inclus
      'mft-2026-gotrm:bc03-01:qcm:17', -- ROI 133 %
      'mft-2026-gotrm:bc03-01:qcm:18', -- payback 5,1 ans
      -- BC03-02 (7 QCM) — RSE et transition énergétique
      'mft-2026-gotrm:bc03-02:qcm:1',  -- 3 piliers RSE
      'mft-2026-gotrm:bc03-02:qcm:2',  -- Scope 1
      'mft-2026-gotrm:bc03-02:qcm:6',  -- autonomie électrique
      'mft-2026-gotrm:bc03-02:qcm:8',  -- suramortissement +40 %
      'mft-2026-gotrm:bc03-02:qcm:11', -- ZFE définition
      'mft-2026-gotrm:bc03-02:qcm:13', -- ZFE 2030 Crit''Air E
      'mft-2026-gotrm:bc03-02:qcm:17', -- 2035 thermique interdit
      -- 1 QR cas pratique
      'mft-2026-gotrm:bc03-01:qr:1'    -- calcul CRT km porteur 19 t
    );

  RAISE NOTICE '✅ GOTRM examen blanc BC03 chargé : 15 QCM + 1 QR, 45 min, seuil 50 %%.';
END
$eb_bc03$;
