-- ============================================================================
-- GOTRM — Chapitre 14 : Obligations environnementales et RSE entreprise
-- Source : LIVRET_PRO_CCP1_GOTRM V2.pdf — pages 55 à 58
-- Idempotent : DELETE puis INSERT
-- ============================================================================

DO $ch14_v4$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_lesson uuid;
  v_quiz uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation gotrm introuvable.';
  END IF;

  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1';
  IF v_bloc IS NULL THEN
    INSERT INTO public.blocs (code, title, description, "order")
    VALUES ('BC1', 'Bloc 1 — Compétences générales', 'Bloc générique partagé.', 1)
    ON CONFLICT (code) DO NOTHING
    RETURNING id INTO v_bloc;
    IF v_bloc IS NULL THEN
      SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1';
    END IF;
  END IF;
  IF v_bloc IS NULL THEN
    RAISE EXCEPTION 'Bloc BC1 introuvable.';
  END IF;

  -- Nettoyage idempotent
  DELETE FROM public.modules WHERE slug = 'gotrm-ch14-environnement-rse';
  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch14:%';

  -- Module
  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Chapitre 14 — Obligations environnementales et RSE entreprise',
    'gotrm-ch14-environnement-rse',
    v_bloc,
    'Maîtriser l''information CO2 obligatoire (décret 2011-1336), les Zones à Faibles Émissions et vignettes Crit''Air, l''éco-conduite et les autres obligations environnementales du transporteur.',
    'intermediaire',
    65,
    140
  )
  RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 140, true)
  ON CONFLICT DO NOTHING;

  -- Leçon
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module,
    'Obligations environnementales et RSE entreprise',
    'environnement-rse',
    1,
    65,
$lesson$
# Chapitre 14 — Obligations environnementales et RSE entreprise

L'intégration des enjeux environnementaux dans l'activité transport est aujourd'hui une obligation légale et une compétence explicitement évaluée au CCP1. Ce chapitre présente les principales obligations réglementaires et les bonnes pratiques que le gestionnaire doit maîtriser.

---

## 14.1 — L'information CO₂ obligatoire

**RÉGLEMENTATION**

**Décret n°2011-1336 du 24 octobre 2011** (dit « Décret CO₂ ») — en vigueur depuis le **1er octobre 2013** :

Tout transporteur doit informer le donneur d'ordres de la quantité de CO₂ émise par chaque prestation de transport réalisée.

- Cette obligation s'applique **à tous les modes de transport**.
- L'information peut être communiquée **sur la facture** ou dans **un document séparé**, de façon **individuelle (par opération)** ou **périodique (mensuelle ou annuelle)**.

---

## 14.2 — Méthode de calcul de l'information CO₂

La méthode officielle française (ADEME) repose sur un calcul en **deux étapes**.

**À RETENIR**

**FORMULE DE BASE :**

> Émissions CO₂ totales véhicule (kg) = Distance (km) × Facteur d'émission (kgCO₂e/km)

**POUR UN ENVOI PARTAGÉ (lots partiels, tournée) :**

> CO₂ envoi (kg) = Émission totale véhicule × (Poids de l'envoi / Poids total chargé)

**Facteurs d'émission indicatifs (ADEME) :**

| Type de véhicule | Facteur d'émission |
|---|---|
| Fourgon < 3,5 t | **0,200 kgCO₂e/km** |
| Porteur 26 t | **0,550 kgCO₂e/km** |
| Ensemble articulé 44 t | **0,820 kgCO₂e/km** |
| Véhicule électrique | **0,030 à 0,060 kgCO₂e/km** |

### Exemple intégral — Mission Paris → Lyon

**Mission :** Paris → Lyon (465 km) — Ensemble articulé 44 t — Chargement total 18 t
**Dont envoi client DURAND = 6 t** — Facteur : 0,820 kgCO₂e/km

**Calcul :**

- Émission totale véhicule : 0,820 × 465 = **381,3 kgCO₂e**
- Part de l'envoi DURAND : 6 t / 18 t = **33,3 %**
- CO₂ imputable à DURAND : 381,3 × 33,3 % = **127,0 kgCO₂e**

**Mention à indiquer sur la facture :**

> « Émissions CO₂ de ce transport : 127 kgCO₂e »

---

## 14.3 — Les Zones à Faibles Émissions (ZFE) et les vignettes Crit'Air

Les **ZFE** sont des zones urbaines qui restreignent la circulation des véhicules les plus polluants selon leur **vignette Crit'Air**. En **2025, toutes les agglomérations de plus de 150 000 habitants** doivent en être dotées.

Le gestionnaire **DOIT** vérifier la compatibilité du véhicule avec les ZFE traversées **avant toute affectation**.

| Vignette Crit'Air | Motorisation / Norme Euro | Statut en ZFE |
|---|---|---|
| **Crit'Air 0** | 100 % électrique ou hydrogène | Autorisé partout |
| **Crit'Air 1** | Essence Euro 5-6 / Diesel Euro 6 | Autorisé |
| **Crit'Air 2** | Essence Euro 4 / Diesel Euro 5 | Autorisé avec restrictions possibles |
| **Crit'Air 3** | Essence Euro 2-3 / Diesel Euro 4 | Interdit dans la plupart des ZFE |
| **Crit'Air 4 et 5** | Diesel Euro 2 et 3 | Interdit |
| **Non classé** | Avant Euro 1 | Interdit |

---

## 14.4 — La RSE entreprise et l'éco-conduite

La **Responsabilité Sociétale des Entreprises (RSE)** désigne l'engagement d'une entreprise à intégrer des préoccupations sociales, environnementales et économiques dans ses activités.

Dans le transport, cela se traduit notamment par :

- la **réduction des émissions de CO₂**,
- la **formation à l'éco-conduite**,
- le respect de la **QVCT** (Qualité de Vie et des Conditions de Travail),
- la **vérification des pratiques sociales et environnementales des sous-traitants**.

### Tableau des comportements éco-conduite

| Comportement éco-conduite | Impact | Gain estimé |
|---|---|---|
| Anticiper les décélérations (lever le pied tôt) | Évite les freinages à perte d'énergie | **5 à 8 %** |
| Maintenir une vitesse constante (régulateur) | Évite les à-coups moteur | **5 à 10 %** |
| Utiliser le rapport le plus élevé possible | Réduction des tours moteur | **3 à 7 %** |
| Vérifier la pression des pneumatiques | Réduit la résistance au roulement | **2 à 4 %** |
| Éteindre le moteur à l'arrêt (> 3 min) | Supprime la consommation au ralenti | **2 à 5 %** |

---

## 14.5 — Autres obligations environnementales

| Obligation | Contenu | Base légale |
|---|---|---|
| **Information CO₂** | Communiquer l'empreinte carbone de chaque prestation au client | Décret 2011-1336 |
| **Vignette Crit'Air** | Vérifier la compatibilité du véhicule avec les ZFE traversées | Arrêtés ZFE |
| **Taxe à l'essieu** | Due pour les véhicules ≥ 12 t — à intégrer dans le coût de revient | CGI |
| **TIPCE** | Taxe sur le gazole — partiellement remboursable aux transporteurs | CGI art. 265 |
| **Entretien ATP** | Contrôle obligatoire tous les 3 ans pour les véhicules frigorifiques | Accord ATP |

---

## 14.6 — Vocabulaire essentiel

| Terme | Définition |
|---|---|
| **kgCO₂e** | Kilogramme équivalent CO₂ — unité de mesure des gaz à effet de serre |
| **ADEME** | Agence de la Transition Écologique — publie les facteurs d'émission officiels |
| **Facteur d'émission** | Valeur en kgCO₂e/km utilisée pour calculer l'empreinte carbone d'un trajet |
| **Crit'Air** | Vignette classant les véhicules selon leurs émissions polluantes (0 à 5) |
| **ZFE** | Zone à Faibles Émissions — zone urbaine restreignant les véhicules polluants |
| **Éco-conduite** | Pratiques de conduite réduisant la consommation de carburant et les émissions |
| **RSE entreprise** | Responsabilité Sociétale des Entreprises — engagement environnemental et social |
| **QVCT** | Qualité de Vie et des Conditions de Travail |
| **TIPCE** | Taxe Intérieure de Consommation sur les Produits Énergétiques — remboursable en partie |
| **GNV** | Gaz Naturel Véhicule — carburant alternatif moins émetteur de CO₂ |
$lesson$,
    'Information CO2 obligatoire (décret 2011-1336), méthode de calcul ADEME, ZFE/Crit''Air, éco-conduite et autres obligations environnementales.'
  )
  RETURNING id INTO v_lesson;

  -- ===========================================================================
  -- BANQUE DE QUESTIONS — 10 QCM + 3 QR
  -- ===========================================================================
  INSERT INTO public.question_bank (
    formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation
  ) VALUES

  -- QCM 1 — facile — Décret CO2
  (v_formation, v_module, 'qcm',
   'Quel décret impose à tout transporteur d''informer le donneur d''ordres de la quantité de CO₂ émise par chaque prestation ?',
   '[
     {"id":"a","label":"Décret n°2008-1009 du 1er avril 2009","is_correct":false},
     {"id":"b","label":"Décret n°2011-1336 du 24 octobre 2011 (dit Décret CO₂)","is_correct":true},
     {"id":"c","label":"Décret n°2015-1085 du 28 août 2015","is_correct":false},
     {"id":"d","label":"Décret n°2019-771 du 24 juillet 2019","is_correct":false}
   ]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch14','livret','co2','reglementation'],
   'mft-2026-gotrm-livret:ch14:qcm:1', true,
   'Le décret n°2011-1336 du 24 octobre 2011, dit Décret CO₂, est en vigueur depuis le 1er octobre 2013 et s''applique à tous les modes de transport.'),

  -- QCM 2 — facile — Date d'entrée en vigueur
  (v_formation, v_module, 'qcm',
   'Depuis quelle date l''information CO₂ obligatoire est-elle entrée en vigueur ?',
   '[
     {"id":"a","label":"1er janvier 2011","is_correct":false},
     {"id":"b","label":"24 octobre 2011","is_correct":false},
     {"id":"c","label":"1er octobre 2013","is_correct":true},
     {"id":"d","label":"1er janvier 2015","is_correct":false}
   ]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch14','livret','co2','date'],
   'mft-2026-gotrm-livret:ch14:qcm:2', true,
   'Le Décret CO₂ a été publié le 24 octobre 2011, mais son entrée en vigueur effective est le 1er octobre 2013.'),

  -- QCM 3 — facile — Facteur ensemble articulé 44 t
  (v_formation, v_module, 'qcm',
   'Quel est le facteur d''émission ADEME indicatif pour un ensemble articulé 44 t ?',
   '[
     {"id":"a","label":"0,200 kgCO₂e/km","is_correct":false},
     {"id":"b","label":"0,550 kgCO₂e/km","is_correct":false},
     {"id":"c","label":"0,820 kgCO₂e/km","is_correct":true},
     {"id":"d","label":"1,200 kgCO₂e/km","is_correct":false}
   ]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch14','livret','ademe','facteur-emission'],
   'mft-2026-gotrm-livret:ch14:qcm:3', true,
   'Selon les facteurs ADEME indicatifs : fourgon < 3,5 t = 0,200 ; porteur 26 t = 0,550 ; ensemble articulé 44 t = 0,820 ; véhicule électrique = 0,030 à 0,060 kgCO₂e/km.'),

  -- QCM 4 — facile — Crit'Air 0
  (v_formation, v_module, 'qcm',
   'Quels véhicules portent la vignette Crit''Air 0 ?',
   '[
     {"id":"a","label":"Les véhicules essence Euro 5-6 / diesel Euro 6","is_correct":false},
     {"id":"b","label":"Les véhicules 100 % électriques ou hydrogène","is_correct":true},
     {"id":"c","label":"Les véhicules essence Euro 4 / diesel Euro 5","is_correct":false},
     {"id":"d","label":"Les véhicules antérieurs à Euro 1","is_correct":false}
   ]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch14','livret','critair','zfe'],
   'mft-2026-gotrm-livret:ch14:qcm:4', true,
   'La vignette Crit''Air 0 est réservée aux véhicules 100 % électriques ou hydrogène : ils sont autorisés partout en ZFE.'),

  -- QCM 5 — moyen — Formule de base
  (v_formation, v_module, 'qcm',
   'Quelle est la formule de base ADEME pour calculer les émissions CO₂ totales d''un véhicule ?',
   '[
     {"id":"a","label":"Émissions = Poids × Distance","is_correct":false},
     {"id":"b","label":"Émissions = Distance (km) × Facteur d''émission (kgCO₂e/km)","is_correct":true},
     {"id":"c","label":"Émissions = Consommation (L) × Prix du gazole","is_correct":false},
     {"id":"d","label":"Émissions = Distance × Poids × Vitesse moyenne","is_correct":false}
   ]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch14','livret','calcul','formule'],
   'mft-2026-gotrm-livret:ch14:qcm:5', true,
   'La formule officielle ADEME est : Émissions CO₂ totales véhicule (kg) = Distance (km) × Facteur d''émission (kgCO₂e/km).'),

  -- QCM 6 — moyen — Calcul exemple Paris-Lyon (étape 1)
  (v_formation, v_module, 'qcm',
   'Pour un ensemble articulé 44 t parcourant 465 km de Paris à Lyon, quelle est l''émission totale du véhicule (facteur 0,820 kgCO₂e/km) ?',
   '[
     {"id":"a","label":"127,0 kgCO₂e","is_correct":false},
     {"id":"b","label":"255,8 kgCO₂e","is_correct":false},
     {"id":"c","label":"381,3 kgCO₂e","is_correct":true},
     {"id":"d","label":"465,0 kgCO₂e","is_correct":false}
   ]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch14','livret','calcul','exemple'],
   'mft-2026-gotrm-livret:ch14:qcm:6', true,
   'Calcul : 0,820 × 465 = 381,3 kgCO₂e pour la totalité du véhicule.'),

  -- QCM 7 — moyen — Calcul envoi partagé DURAND
  (v_formation, v_module, 'qcm',
   'Sur la mission Paris-Lyon (381,3 kgCO₂e véhicule, chargement total 18 t), l''envoi du client DURAND fait 6 t. Quelle quantité de CO₂ doit être indiquée sur sa facture ?',
   '[
     {"id":"a","label":"63,5 kgCO₂e","is_correct":false},
     {"id":"b","label":"127 kgCO₂e","is_correct":true},
     {"id":"c","label":"190 kgCO₂e","is_correct":false},
     {"id":"d","label":"381 kgCO₂e","is_correct":false}
   ]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch14','livret','calcul','envoi-partage'],
   'mft-2026-gotrm-livret:ch14:qcm:7', true,
   'Part de l''envoi DURAND : 6 / 18 = 33,3 %. CO₂ imputable : 381,3 × 33,3 % = 127,0 kgCO₂e. Mention sur facture : « Émissions CO₂ de ce transport : 127 kgCO₂e ».'),

  -- QCM 8 — moyen — Statut Crit'Air 3
  (v_formation, v_module, 'qcm',
   'Quel est le statut de la vignette Crit''Air 3 (essence Euro 2-3 / diesel Euro 4) en ZFE ?',
   '[
     {"id":"a","label":"Autorisé partout","is_correct":false},
     {"id":"b","label":"Autorisé avec restrictions possibles","is_correct":false},
     {"id":"c","label":"Interdit dans la plupart des ZFE","is_correct":true},
     {"id":"d","label":"Autorisé uniquement la nuit","is_correct":false}
   ]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch14','livret','critair','zfe'],
   'mft-2026-gotrm-livret:ch14:qcm:8', true,
   'La vignette Crit''Air 3 (essence Euro 2-3 / diesel Euro 4) est interdite dans la plupart des ZFE. Crit''Air 4, 5 et non classé sont totalement interdits.'),

  -- QCM 9 — difficile — Gain régulateur
  (v_formation, v_module, 'qcm',
   'Selon le tableau éco-conduite, quel est le gain estimé en maintenant une vitesse constante (régulateur) ?',
   '[
     {"id":"a","label":"2 à 4 %","is_correct":false},
     {"id":"b","label":"3 à 7 %","is_correct":false},
     {"id":"c","label":"5 à 10 %","is_correct":true},
     {"id":"d","label":"10 à 15 %","is_correct":false}
   ]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch14','livret','eco-conduite','gain'],
   'mft-2026-gotrm-livret:ch14:qcm:9', true,
   'Maintenir une vitesse constante (régulateur) évite les à-coups moteur et procure un gain estimé de 5 à 10 %. C''est le levier d''éco-conduite le plus efficace du tableau.'),

  -- QCM 10 — difficile — Taxe à l'essieu
  (v_formation, v_module, 'qcm',
   'Pour quels véhicules la taxe à l''essieu est-elle due ?',
   '[
     {"id":"a","label":"Tous les véhicules de transport routier","is_correct":false},
     {"id":"b","label":"Les véhicules ≥ 3,5 t","is_correct":false},
     {"id":"c","label":"Les véhicules ≥ 12 t","is_correct":true},
     {"id":"d","label":"Uniquement les ensembles articulés 44 t","is_correct":false}
   ]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch14','livret','taxe-essieu','cgi'],
   'mft-2026-gotrm-livret:ch14:qcm:10', true,
   'La taxe à l''essieu (CGI) est due pour les véhicules ≥ 12 t et doit être intégrée dans le coût de revient.'),

  -- QR 1 — Méthode de calcul envoi partagé
  (v_formation, v_module, 'qr',
   'Expliquez la méthode officielle ADEME en deux étapes pour calculer l''information CO₂ d''un envoi partagé (lot partiel ou tournée). Donnez les deux formules.',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch14','livret','calcul','ademe','envoi-partage'],
   'mft-2026-gotrm-livret:ch14:qr:1', true,
   'La méthode ADEME repose sur deux étapes : (1) Émissions CO₂ totales véhicule (kg) = Distance (km) × Facteur d''émission (kgCO₂e/km) ; (2) Pour un envoi partagé : CO₂ envoi (kg) = Émission totale véhicule × (Poids de l''envoi / Poids total chargé). Les facteurs ADEME indicatifs sont : fourgon < 3,5 t = 0,200 ; porteur 26 t = 0,550 ; ensemble articulé 44 t = 0,820 ; véhicule électrique = 0,030 à 0,060 kgCO₂e/km.'),

  -- QR 2 — ZFE et Crit'Air
  (v_formation, v_module, 'qr',
   'Qu''est-ce qu''une ZFE ? Quelles sont les obligations du gestionnaire avant d''affecter un véhicule à une mission traversant une ZFE ? Citez deux catégories Crit''Air interdites.',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch14','livret','zfe','critair'],
   'mft-2026-gotrm-livret:ch14:qr:2', true,
   'Les ZFE (Zones à Faibles Émissions) sont des zones urbaines qui restreignent la circulation des véhicules les plus polluants selon leur vignette Crit''Air. En 2025, toutes les agglomérations de plus de 150 000 habitants doivent en être dotées. Le gestionnaire DOIT vérifier la compatibilité du véhicule avec les ZFE traversées avant toute affectation. Catégories interdites : Crit''Air 4 et 5 (Diesel Euro 2 et 3) et Non classé (avant Euro 1) sont totalement interdits ; Crit''Air 3 est interdit dans la plupart des ZFE.'),

  -- QR 3 — RSE et éco-conduite
  (v_formation, v_module, 'qr',
   'Définissez la RSE entreprise dans le secteur transport et citez au moins trois comportements d''éco-conduite avec leurs gains estimés.',
   NULL,
   5, 'difficile', ARRAY['gotrm','ch14','livret','rse','eco-conduite'],
   'mft-2026-gotrm-livret:ch14:qr:3', true,
   'La RSE (Responsabilité Sociétale des Entreprises) désigne l''engagement d''une entreprise à intégrer des préoccupations sociales, environnementales et économiques dans ses activités. Dans le transport : réduction des émissions de CO₂, formation à l''éco-conduite, respect de la QVCT, vérification des pratiques des sous-traitants. Comportements éco-conduite (avec gains) : anticiper les décélérations 5 à 8 % ; vitesse constante au régulateur 5 à 10 % ; rapport le plus élevé 3 à 7 % ; pression des pneumatiques 2 à 4 % ; couper le moteur à l''arrêt > 3 min 2 à 5 %.');

  -- ===========================================================================
  -- QUIZ d'entraînement
  -- ===========================================================================
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (
    v_module,
    'Chapitre 14 — Quiz d''entraînement',
    'Quiz d''entraînement (10 questions) sur les obligations environnementales et la RSE entreprise : information CO₂, ZFE/Crit''Air, éco-conduite et autres obligations.',
    'entrainement',
    NULL,
    70
  )
  RETURNING id INTO v_quiz;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch14:qcm:%';

  RAISE NOTICE '✓ Module Chapitre 14 importé avec 10 QCM + 3 QR (livret pages 55-58).';
END $ch14_v4$;
