-- =====================================================================
-- GOTRM — CHAPITRE 3 : Analyser une demande et vérifier la faisabilité
-- Source : LIVRET_PRO_CCP1_GOTRM V2.pdf — pages 11 à 14
-- Reproduction fidèle du livret (pas d'enrichissement externe).
-- Idempotent : DELETE ciblés puis INSERT — safe à rejouer.
-- =====================================================================

DO $ch03_v4$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_lesson uuid;
  v_quiz uuid;
BEGIN
  -- ─── 1. Pré-requis : formation GOTRM ────────────────────────────────
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation gotrm introuvable. Joue d''abord formations_v2.sql.';
  END IF;

  -- ─── 2. Bloc BC1 (création légère si absent) ────────────────────────
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1';
  IF v_bloc IS NULL THEN
    INSERT INTO public.blocs (code, title, description, "order")
    VALUES ('BC1', 'Bloc 1 — Compétences générales',
            'Bloc générique partagé entre formations.', 1)
    ON CONFLICT (code) DO NOTHING
    RETURNING id INTO v_bloc;
    IF v_bloc IS NULL THEN
      SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1';
    END IF;
  END IF;
  IF v_bloc IS NULL THEN
    RAISE EXCEPTION 'Bloc BC1 introuvable et impossible à créer.';
  END IF;

  -- ─── 3. Nettoyage idempotent ────────────────────────────────────────
  DELETE FROM public.modules WHERE slug = 'gotrm-ch03-analyser-demande';
  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch03:%';

  -- ─── 4. Module ──────────────────────────────────────────────────────
  INSERT INTO public.modules
    (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Chapitre 3 — Analyser une demande et vérifier la faisabilité',
          'gotrm-ch03-analyser-demande',
          v_bloc,
          'Lire et qualifier une demande de transport, estimer distances et temps, vérifier la faisabilité réglementaire (RSE, ZFE, ADR/ATP) et choisir la solution la plus adaptée.',
          'intermediaire', 60, 30)
  RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 30, true)
  ON CONFLICT DO NOTHING;

  -- ─── 5. Leçon unique (chapitre complet) ─────────────────────────────
  INSERT INTO public.lessons
    (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (v_module,
          'Analyser une demande et vérifier la faisabilité',
          'analyser-demande-faisabilite',
          1, 60,
$lesson$
# Analyser une demande et vérifier la faisabilité

> 🎯 **Objectifs pédagogiques**
>
> - Lire une demande de transport et identifier toutes les informations nécessaires.
> - Estimer la distance totale, le temps de conduite et le temps de service.
> - Vérifier la faisabilité réglementaire (RSE, restrictions, ZFE, marchandises spécifiques).
> - Choisir la solution de transport la plus adaptée (moyens propres, affrètement, intermodal).
> - Intégrer la dimension environnementale dans la réponse au client.

Toute opération de transport commence par une demande émanant d'un client. Que cette demande arrive par téléphone, par email ou via un TMS, le gestionnaire doit en extraire systématiquement les mêmes informations, vérifier que la prestation est réalisable sur les plans technique et réglementaire, puis choisir la solution la plus adaptée.

---

## 3.1 — Lire et comprendre une demande de transport

La première compétence du gestionnaire est de savoir lire une demande et identifier toutes les informations nécessaires. Une information manquante peut conduire à une erreur de tarification, une infraction réglementaire ou un litige commercial.

> 📋 **REGLEMENTATION — Informations obligatoires à collecter sur chaque demande**
>
> **Sur la marchandise :** nature, poids brut total, dimensions, nombre et type d'unités de charge, conditionnement, contraintes particulières (température dirigée, ADR, fragilité, valeur).
>
> **Sur l'opération :** adresses exactes de chargement et de livraison, dates et heures souhaitées, modalités de chargement et de déchargement (quai, hayon élévateur, grue, chariot), durées estimées.
>
> **Sur le cadre commercial :** identité du donneur d'ordres, port payé ou port dû, gestion des supports de charge, exigences qualité particulières.

---

## 3.2 — Estimer les distances et les temps de parcours

Le gestionnaire utilise des logiciels de calcul d'itinéraire (intégrés au TMS ou en ligne) et les cartes routières fournies à l'examen pour déterminer la distance totale en kilomètres, le temps de conduite estimé en respectant les limitations de vitesse, le temps de service total (conduite + chargement + déchargement + attentes éventuelles) et le nombre de conducteurs nécessaires selon la durée de la prestation.

> ⚠️ **À RETENIR — Temps de service ≠ temps de conduite**
>
> Le temps de SERVICE ≠ le temps de CONDUITE.
>
> Le temps de service comprend : la conduite + les autres tâches (chargement, déchargement, tâches administratives) + les disponibilités.
>
> Les pauses et les repos NE font PAS partie du temps de service.
>
> Pour une mission longue dépassant la journée : prévoir une étape avec repos ou un équipage double.

---

## 3.3 — Vérifier la faisabilité réglementaire

### La réglementation sociale européenne (RSE)

Avant d'affecter un conducteur, le gestionnaire vérifie que le temps de service de la mission est compatible avec le règlement CE 561/2006. Si la mission est trop longue pour être réalisée en une seule journée, il faut prévoir un équipage double, une étape avec repos ou recourir à la sous-traitance. La RSE est détaillée dans le chapitre 9.

### Les interdictions et restrictions de circulation

| Restriction | Conditions | Véhicules concernés |
|---|---|---|
| Interdiction week-end | Dimanche + certains jours fériés, sur routes nationales et autoroutes | Poids lourds > 7,5 t de PTAC |
| Restrictions nocturnes | Certaines agglomérations — horaires variables | Poids lourds dépassant certains seuils de PTAC |
| Zones à Faibles Émissions (ZFE) | Zones urbaines (Paris, Lyon, Marseille, Grenoble…) — selon vignette Crit'Air | Véhicules dont la vignette est interdite dans la zone |
| Limitations de gabarit | Tunnels, ponts, voies communales — signalisation locale | Véhicules dépassant les limites indiquées |
| Convoi exceptionnel | Marchandises hors gabarit légal | Tout véhicule dépassant : L > 16,50 m, l > 2,55 m, h > 4 m, P > 44 t |

### Les réglementations spécifiques aux marchandises

| Type de marchandise | Exigences réglementaires |
|---|---|
| Matières dangereuses (ADR) | Véhicule homologué ADR + conducteur certifié ADR + documents spécifiques (fiche sécurité, déclaration de chargement) |
| Denrées périssables (ATP) | Véhicule certifié ATP de la classe correspondante à la température requise |
| Transport international | Réglementations spécifiques aux pays traversés — documents douaniers selon les cas |

---

## 3.4 — Choisir la solution de transport

> 💡 **METHODE — Choisir le bon véhicule en 4 questions**
>
> **Question 1 — Quelle est la nature de la marchandise ?**
> - Produits frais ou surgelés → frigorifique certifié ATP
> - Liquides → citerne
> - Marchandises hors gabarit ou très lourdes → plateau ou PLSC
> - Marchandises sèches palettisées → fourgon ou tautliner
>
> **Question 2 — Quelles sont les conditions de chargement et de déchargement ?**
> - Déchargement latéral au chariot → PLSC ou tautliner
> - Chargement par grue ou portique → plateau
> - Quai standard → fourgon ou tautliner
>
> **Question 3 — Quel est le poids total de la marchandise ?**
> - Vérifier que le poids réel ne dépasse pas la charge utile du véhicule.
>
> **Question 4 — Quelles sont les dimensions de la marchandise ?**
> - Vérifier que la marchandise entre dans les dimensions utiles intérieures de la carrosserie.

| Option | Quand l'utiliser | Points de vigilance |
|---|---|---|
| Moyens propres | Véhicule et conducteur adaptés et disponibles | Vérifier la conformité RSE avant affectation |
| Affrètement ponctuel (spot) | Pas de véhicule ou de conducteur disponible ou adapté | Vérifier la situation administrative du sous-traitant OBLIGATOIREMENT |
| Solution intermodale | Longues distances, politique RSE de l'entreprise | Coordonner plusieurs opérateurs — cohérence des délais |

---

## 3.5 — La dimension environnementale

Intégrer la dimension environnementale dans les réponses aux clients est une compétence explicitement évaluée au CCP1. En pratique, cela signifie : vérifier la conformité des véhicules avec les normes Euro et les ZFE de l'itinéraire, favoriser les solutions réduisant les kilomètres à vide, proposer des solutions intermodales pertinentes sur les longues distances, et prendre en compte la politique RSE de l'entreprise cliente.

---

## 3.6 — Vocabulaire essentiel

| Terme | Définition |
|---|---|
| Faisabilité | Capacité à réaliser une opération dans le respect de toutes les contraintes |
| Temps de service | Conduite + autres tâches + disponibilité (hors pauses et repos) |
| Équipage double | Deux conducteurs se relayant dans le même véhicule pour les longues distances |
| ZFE | Zone à Faibles Émissions — zone urbaine restreignant les véhicules polluants |
| Crit'Air | Vignette classant les véhicules selon leurs émissions polluantes (de 0 à 5) |
| ADR | Accord pour le transport de marchandises Dangereuses par la Route |
| Convoi exceptionnel | Transport hors gabarit réglementaire — autorisation préfectorale obligatoire |
| Solution intermodale | Transport combinant plusieurs modes : route + fer, route + fleuve… |
| Norme Euro | Classification des véhicules selon leurs émissions de polluants atmosphériques |
$lesson$,
'Lecture demande, distances/temps, faisabilité RSE/ZFE/marchandises spéciales, choix solution.')
  RETURNING id INTO v_lesson;

  -- ─── 6. Banque de questions — 10 QCM ────────────────────────────────

  -- QCM 1 — facile : informations marchandise
  INSERT INTO public.question_bank
    (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, 'qcm',
    'Parmi les éléments suivants, lequel doit OBLIGATOIREMENT figurer dans les informations marchandise d''une demande de transport ?',
    '[
      {"id":"a","label":"La marque commerciale du fabricant","is_correct":false},
      {"id":"b","label":"Le poids brut total et les dimensions","is_correct":true},
      {"id":"c","label":"Le numéro SIRET du destinataire","is_correct":false},
      {"id":"d","label":"Le mode de paiement du client final","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['gotrm','ch03','demande','marchandise'],
    'mft-2026-gotrm-livret:ch03:qcm:1', true,
    'Sur la marchandise : nature, poids brut total, dimensions, nombre et type d''unités de charge, conditionnement, contraintes particulières.');

  -- QCM 2 — facile : temps de service vs temps de conduite
  INSERT INTO public.question_bank
    (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, 'qcm',
    'Le temps de service comprend :',
    '[
      {"id":"a","label":"Uniquement le temps de conduite","is_correct":false},
      {"id":"b","label":"La conduite, les autres tâches et les disponibilités, hors pauses et repos","is_correct":true},
      {"id":"c","label":"La conduite, les pauses et les repos","is_correct":false},
      {"id":"d","label":"Le temps total entre l''arrivée et le départ du dépôt, repos compris","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['gotrm','ch03','temps-service','temps-conduite'],
    'mft-2026-gotrm-livret:ch03:qcm:2', true,
    'Le temps de service = conduite + autres tâches (chargement, déchargement, administratif) + disponibilités. Les pauses et repos NE font PAS partie du temps de service.');

  -- QCM 3 — facile : interdiction week-end
  INSERT INTO public.question_bank
    (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, 'qcm',
    'L''interdiction de circulation du dimanche et de certains jours fériés sur routes nationales et autoroutes concerne :',
    '[
      {"id":"a","label":"Tous les véhicules de transport de marchandises","is_correct":false},
      {"id":"b","label":"Les poids lourds > 7,5 t de PTAC","is_correct":true},
      {"id":"c","label":"Uniquement les ensembles articulés","is_correct":false},
      {"id":"d","label":"Les véhicules ADR uniquement","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['gotrm','ch03','restrictions','week-end'],
    'mft-2026-gotrm-livret:ch03:qcm:3', true,
    'Tableau des restrictions : interdiction week-end → poids lourds > 7,5 t de PTAC.');

  -- QCM 4 — facile : ZFE
  INSERT INTO public.question_bank
    (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, 'qcm',
    'Une Zone à Faibles Émissions (ZFE) restreint la circulation selon :',
    '[
      {"id":"a","label":"Le PTAC du véhicule","is_correct":false},
      {"id":"b","label":"La vignette Crit''Air du véhicule","is_correct":true},
      {"id":"c","label":"L''ancienneté du conducteur","is_correct":false},
      {"id":"d","label":"La nature de la marchandise transportée","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['gotrm','ch03','zfe','crit-air'],
    'mft-2026-gotrm-livret:ch03:qcm:4', true,
    'ZFE : zones urbaines (Paris, Lyon, Marseille, Grenoble…) — restriction selon la vignette Crit''Air. Véhicules dont la vignette est interdite dans la zone.');

  -- QCM 5 — moyen : convoi exceptionnel
  INSERT INTO public.question_bank
    (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, 'qcm',
    'À partir de quelles dimensions un transport relève-t-il du régime du convoi exceptionnel ?',
    '[
      {"id":"a","label":"L > 12 m, l > 2,40 m, h > 3,50 m, P > 26 t","is_correct":false},
      {"id":"b","label":"L > 16,50 m, l > 2,55 m, h > 4 m, P > 44 t","is_correct":true},
      {"id":"c","label":"L > 18,75 m, l > 2,60 m, h > 4,50 m, P > 50 t","is_correct":false},
      {"id":"d","label":"Toute marchandise pesant plus de 30 tonnes","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['gotrm','ch03','convoi-exceptionnel','gabarit'],
    'mft-2026-gotrm-livret:ch03:qcm:5', true,
    'Tout véhicule dépassant L > 16,50 m, l > 2,55 m, h > 4 m, P > 44 t relève du convoi exceptionnel — autorisation préfectorale obligatoire.');

  -- QCM 6 — moyen : ADR
  INSERT INTO public.question_bank
    (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, 'qcm',
    'Pour transporter des matières dangereuses (ADR), il faut impérativement :',
    '[
      {"id":"a","label":"Un véhicule homologué ADR uniquement","is_correct":false},
      {"id":"b","label":"Un conducteur certifié ADR uniquement","is_correct":false},
      {"id":"c","label":"Un véhicule homologué ADR + un conducteur certifié ADR + des documents spécifiques","is_correct":true},
      {"id":"d","label":"Une simple attestation du donneur d''ordres","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['gotrm','ch03','adr','marchandises-speciales'],
    'mft-2026-gotrm-livret:ch03:qcm:6', true,
    'ADR : véhicule homologué ADR + conducteur certifié ADR + documents spécifiques (fiche sécurité, déclaration de chargement). Les trois conditions sont cumulatives.');

  -- QCM 7 — moyen : ATP
  INSERT INTO public.question_bank
    (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, 'qcm',
    'Pour transporter des denrées périssables sous température dirigée, le véhicule doit être :',
    '[
      {"id":"a","label":"Homologué ADR","is_correct":false},
      {"id":"b","label":"Certifié ATP de la classe correspondante à la température requise","is_correct":true},
      {"id":"c","label":"Un fourgon classique avec couverture isotherme","is_correct":false},
      {"id":"d","label":"Conforme à la norme Euro 6 uniquement","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['gotrm','ch03','atp','frigorifique'],
    'mft-2026-gotrm-livret:ch03:qcm:7', true,
    'Denrées périssables (ATP) : véhicule certifié ATP de la classe correspondante à la température requise.');

  -- QCM 8 — moyen : méthode 4 questions
  INSERT INTO public.question_bank
    (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, 'qcm',
    'Selon la méthode des 4 questions, des produits frais ou surgelés imposent :',
    '[
      {"id":"a","label":"Un fourgon ou tautliner","is_correct":false},
      {"id":"b","label":"Un plateau ou PLSC","is_correct":false},
      {"id":"c","label":"Un frigorifique certifié ATP","is_correct":true},
      {"id":"d","label":"Une citerne","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['gotrm','ch03','methode-4-questions','vehicule'],
    'mft-2026-gotrm-livret:ch03:qcm:8', true,
    'Question 1 — nature de la marchandise : produits frais ou surgelés → frigorifique certifié ATP.');

  -- QCM 9 — difficile : affrètement ponctuel
  INSERT INTO public.question_bank
    (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, 'qcm',
    'En cas d''affrètement ponctuel (spot) à un sous-traitant, le point de vigilance OBLIGATOIRE est :',
    '[
      {"id":"a","label":"Vérifier la couleur de la cabine du tracteur","is_correct":false},
      {"id":"b","label":"Vérifier la situation administrative du sous-traitant","is_correct":true},
      {"id":"c","label":"Demander une avance de 50 % au sous-traitant","is_correct":false},
      {"id":"d","label":"Faire signer une charte qualité interne","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['gotrm','ch03','affretement','sous-traitance'],
    'mft-2026-gotrm-livret:ch03:qcm:9', true,
    'Affrètement ponctuel (spot) : vérifier la situation administrative du sous-traitant OBLIGATOIREMENT.');

  -- QCM 10 — difficile : dimension environnementale
  INSERT INTO public.question_bank
    (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, 'qcm',
    'Dans le cadre de la dimension environnementale, sur les longues distances, le gestionnaire doit prioritairement :',
    '[
      {"id":"a","label":"Refuser systématiquement la mission","is_correct":false},
      {"id":"b","label":"Proposer des solutions intermodales pertinentes","is_correct":true},
      {"id":"c","label":"Doubler le tarif pour compenser les émissions","is_correct":false},
      {"id":"d","label":"Imposer un véhicule Euro 3 minimum","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['gotrm','ch03','environnement','intermodal'],
    'mft-2026-gotrm-livret:ch03:qcm:10', true,
    'La dimension environnementale impose, sur les longues distances, de proposer des solutions intermodales pertinentes, en plus de la conformité Euro/ZFE et de la réduction des kilomètres à vide.');

  -- ─── 7. Banque de questions — 3 QR (cas pratique métier) ────────────

  INSERT INTO public.question_bank
    (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES
  (v_formation, v_module, 'qr',
   'Un client vous demande un transport Marseille → Lille avec un départ le vendredi à 14 h pour une livraison le lundi matin 8 h. Marchandise : 22 palettes sèches, 18 t. Quelles informations complémentaires devez-vous collecter avant de répondre, et quels points de faisabilité réglementaire devez-vous vérifier ?',
   NULL, 5, 'moyen',
   ARRAY['gotrm','ch03','qr','demande','faisabilite'],
   'mft-2026-gotrm-livret:ch03:qr:1', true,
   'Informations à collecter : dimensions exactes des palettes, modalités de chargement/déchargement (quai, hayon, chariot), adresses précises, port payé/dû, supports de charge, exigences qualité. Faisabilité : (1) interdiction week-end PL > 7,5 t le dimanche → impossible de rouler dimanche, prévoir une étape ; (2) RSE CE 561/2006 → mission > 1 journée donc prévoir équipage double, étape avec repos ou sous-traitance ; (3) ZFE Lyon/Marseille → vérifier vignette Crit''Air du véhicule sur l''itinéraire ; (4) calcul temps de service vs temps de conduite (chargement + déchargement + attentes).'),

  (v_formation, v_module, 'qr',
   'Un transport de produits chimiques classés ADR doit être organisé entre Le Havre et Stuttgart. Détaillez les exigences réglementaires à vérifier sur le véhicule, le conducteur, les documents et la faisabilité de l''itinéraire.',
   NULL, 5, 'difficile',
   ARRAY['gotrm','ch03','qr','adr','international'],
   'mft-2026-gotrm-livret:ch03:qr:2', true,
   'Véhicule : homologué ADR. Conducteur : certifié ADR. Documents spécifiques ADR : fiche sécurité, déclaration de chargement. Transport international : réglementations spécifiques aux pays traversés (France, Allemagne) et documents douaniers selon les cas. Faisabilité itinéraire : vérifier les limitations de gabarit (tunnels, ponts), interdictions week-end PL > 7,5 t, ZFE traversées, RSE CE 561/2006 sur la durée du trajet (équipage double ou étape selon temps de service).'),

  (v_formation, v_module, 'qr',
   'Un client demande un transport longue distance et précise dans son cahier des charges qu''il souhaite une réponse intégrant sa politique RSE. Quels arguments environnementaux pouvez-vous mettre en avant et comment choisir entre moyens propres, affrètement ponctuel et solution intermodale ?',
   NULL, 5, 'moyen',
   ARRAY['gotrm','ch03','qr','rse','intermodal','choix-solution'],
   'mft-2026-gotrm-livret:ch03:qr:3', true,
   'Arguments environnementaux : conformité des véhicules aux normes Euro et ZFE de l''itinéraire, réduction des kilomètres à vide, solutions intermodales sur les longues distances, prise en compte de la politique RSE du client. Choix de solution : moyens propres si véhicule + conducteur adaptés et disponibles (vérifier conformité RSE) ; affrètement ponctuel si pas de moyens internes adaptés (vérifier OBLIGATOIREMENT la situation administrative du sous-traitant) ; solution intermodale recommandée pour les longues distances et la politique RSE de l''entreprise (point de vigilance : coordonner plusieurs opérateurs et garantir la cohérence des délais).');

  -- ─── 8. Quiz d'entraînement (10 QCM) ────────────────────────────────
  INSERT INTO public.quizzes
    (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module,
          'Analyser une demande et vérifier la faisabilité — Quiz',
          'Quiz d''entraînement (10 QCM) couvrant les sections 3.1 à 3.6 du chapitre 3 du livret CCP1 GOTRM.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch03:qcm:%';

  RAISE NOTICE '✓ Module GOTRM Ch3 importé : 1 leçon, 10 QCM + 3 QR, 1 quiz.';
END
$ch03_v4$;
