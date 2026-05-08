-- =====================================================================
-- GOTRM — Chapitre 6 : Choisir et affecter les moyens matériels et humains
-- Source : Livret PRO CCP1 GOTRM V2 (pages 22 à 25)
-- Idempotent — réécrit le module et ses questions sur chaque exécution.
-- =====================================================================

DO $ch06_v4$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_lesson uuid;
  v_quiz uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable.'; END IF;

  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1';
  IF v_bloc IS NULL THEN
    INSERT INTO public.blocs (code, title, description, "order")
    VALUES ('BC1', 'Bloc 1 — Compétences générales', 'Bloc générique partagé.', 1)
    ON CONFLICT (code) DO NOTHING RETURNING id INTO v_bloc;
    IF v_bloc IS NULL THEN SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1'; END IF;
  END IF;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Bloc BC1 introuvable.'; END IF;

  DELETE FROM public.modules WHERE slug = 'gotrm-ch06-affecter-moyens';
  DELETE FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref LIKE 'mft-2026-gotrm-livret:ch06:%';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Chapitre 6 — Choisir et affecter les moyens matériels et humains',
          'gotrm-ch06-affecter-moyens', v_bloc,
          'Affecter véhicules et conducteurs en respectant la logique de priorité (moyens propres puis affrètement), critères matériels et humains, vérification administrative des sous-traitants et procédure d''affrètement ponctuel.',
          'intermediaire', 60, 60)
  RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 60, true) ON CONFLICT DO NOTHING;

  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (v_module, 'Choisir et affecter les moyens matériels et humains',
          'choisir-affecter-moyens', 1, 60,
$lesson$
# Choisir et affecter les moyens matériels et humains

Une fois la commande acceptée et l'offre validée par le client, le gestionnaire organise concrètement la réalisation de la prestation. Il choisit le véhicule, sélectionne le conducteur, et vérifie que tous les acteurs impliqués sont en règle sur le plan administratif. Cette phase s'appelle l'affectation.

> 🎯 **Objectifs pédagogiques**
> - Maîtriser la logique de priorité d'affectation (moyens propres → affrètement).
> - Vérifier les critères matériels d'un véhicule (carrosserie, charge, volume, disponibilité, conformité).
> - Vérifier les critères humains d'un conducteur (disponibilité, permis, FIMO/FCO, carte, ADR, RSE).
> - Contrôler la situation administrative d'un sous-traitant avant toute affectation.
> - Appliquer la procédure d'affrètement ponctuel en 7 étapes.

## 6.1 — La logique d'affectation

> 💡 **Méthode — PRIORITÉS D'AFFECTATION (dans l'ordre)**
>
> **1. Vérifier la faisabilité en MOYENS PROPRES**
> → Véhicule adapté et disponible + conducteur qualifié et disponible ?
>
> **2. Si non disponible → AFFRÈTEMENT PONCTUEL**
> → Rechercher un sous-traitant adapté et disponible
>
> **3. Dans tous les cas → RESPECTER LA RÉGLEMENTATION**
> → RSE pour les conducteurs / vérification administrative pour les sous-traitants
>
> **4. REPORTER SUR LE PLANNING**
> → Toute opération affectée doit apparaître sur le planning d'exploitation

## 6.2 — Choisir les moyens matériels

Le véhicule sélectionné doit répondre simultanément à toutes les contraintes de la mission. Un seul critère non respecté peut rendre l'affectation impossible ou illégale.

| Critère | Ce qu'il faut vérifier |
|---|---|
| Type de carrosserie | Adapté à la nature de la marchandise et aux conditions de chargement/déchargement |
| Charge utile | Le poids réel total ne dépasse pas la CU du véhicule |
| Volume et linéaire | La marchandise tient physiquement dans les dimensions intérieures |
| Disponibilité | Pas déjà affecté, pas en maintenance ou en visite technique |
| Conformité réglementaire | Crit'Air compatible avec les ZFE traversées, ATP si frigorifique, homologation ADR si matières dangereuses |

## 6.3 — Choisir les moyens humains

| Critère | Ce qu'il faut vérifier |
|---|---|
| Disponibilité | Pas en mission, repos RSE respectés avant prise de service, pas en congés/arrêt/formation |
| Permis de conduire | Valide et adapté à la catégorie du véhicule (C, CE, C1, C1E…) |
| FIMO / FCO | Qualification professionnelle à jour — obligatoire pour tout conducteur PL |
| Carte conducteur | Valide pour le tachygraphe numérique |
| Certificat ADR | Si le transport concerne des matières dangereuses — classe adaptée |
| Compatibilité RSE | Solde de temps de conduite disponible suffisant pour réaliser la mission |

> ⚠️ **Réglementation**
>
> Le gestionnaire a l'obligation légale de prendre en compte les situations de handicap lors des affectations.
>
> En pratique : ne pas affecter un conducteur à un véhicule non adapté à sa situation médicale, tenir compte des restrictions figurant sur le permis ou signalées par la médecine du travail, appliquer le principe d'aménagement raisonnable (Défenseur des droits).
>
> En cas de nécessité, redéfinir l'organisation du travail en accord avec la hiérarchie.

## 6.4 — Vérification administrative des sous-traitants

Avant toute affectation d'un sous-traitant, le gestionnaire a une obligation légale de vérifier sa situation administrative. Cette compétence est directement évaluée à l'examen.

| Document | Objet | Validité requise |
|---|---|---|
| Extrait Kbis | Preuve d'immatriculation au registre du commerce | Moins de 3 mois |
| Licence de transport intérieur ou communautaire | Autorisation d'exercer la profession de transporteur | En cours de validité |
| Attestation d'assurance RC | Couverture des dommages causés aux tiers | En cours de validité |
| Attestation URSSAF | Régularité des cotisations sociales | Moins de 6 mois |
| Attestation de vigilance fiscale | Régularité fiscale | Moins de 6 mois |

> ⚠️ **Réglementation**
>
> **Licence communautaire** : autorise les transports en France et dans toute l'Union Européenne — validité 10 ans.
>
> **Licence de transport intérieur** : autorise les transports uniquement sur le territoire national — validité 10 ans.
>
> En cas de non-conformité constatée (licence expirée, assurance non à jour…) :
> → Alerter IMPÉRATIVEMENT la hiérarchie AVANT toute affectation.
>
> Confier une opération à un sous-traitant irrégulier engage la responsabilité juridique et financière de l'entreprise donneur d'ordres.

## 6.5 — L'affrètement ponctuel et la bourse de fret

La bourse de fret est une plateforme numérique mettant en relation des chargeurs ayant de la marchandise à expédier et des transporteurs disposant de capacité disponible. Elle fonctionne selon deux modes : l'offre à prix fixe (le premier transporteur intéressé prend l'opération) et les enchères inversées (plusieurs transporteurs soumettent des prix, le moins-disant remporte l'opération).

> 💡 **Méthode — PROCÉDURE D'AFFRÈTEMENT PONCTUEL en 7 étapes**
>
> 1. Identifier précisément les caractéristiques de l'opération à sous-traiter
> 2. Rechercher un sous-traitant (bourse de fret ou liste de sous-traitants référencés)
> 3. Vérifier la situation administrative du sous-traitant sélectionné (OBLIGATOIRE)
> 4. Négocier et convenir du prix de l'affrètement
> 5. Émettre et transmettre la CONFIRMATION D'AFFRÈTEMENT (avant le chargement)
> 6. Reporter l'opération sur le planning
> 7. Transmettre toutes les instructions nécessaires au sous-traitant

## 6.6 — Vocabulaire essentiel

| Terme | Définition |
|---|---|
| Affectation | Attribution d'une opération à un conducteur, un véhicule ou un sous-traitant |
| Affrètement ponctuel (spot) | Recours à un sous-traitant pour une opération unique non contractualisée |
| Bourse de fret | Plateforme numérique de mise en relation chargeurs et transporteurs |
| FIMO | Formation Initiale Minimale Obligatoire — 140 heures — obtenue une seule fois |
| FCO | Formation Continue Obligatoire — 35 heures tous les 5 ans |
| CQC | Carte de Qualification Conducteur — renouvellement tous les 5 ans |
| Carte conducteur | Carte à puce personnelle et nominative pour le tachygraphe numérique |
| Aménagement raisonnable | Adaptation des conditions de travail aux besoins d'une personne handicapée |
| Km à vide | Kilomètres parcourus sans marchandise — à minimiser pour la rentabilité |
$lesson$,
'Logique d''affectation, critères véhicule/conducteur, vérification sous-traitants, affrètement ponctuel.')
  RETURNING id INTO v_lesson;

  -- ===================================================================
  -- BANQUE DE QUESTIONS — 10 QCM + 3 QR
  -- ===================================================================

  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES

  -- QCM 1 (facile)
  (v_formation, v_module, 'qcm',
   'Dans la logique d''affectation, quelle est la PREMIÈRE priorité du gestionnaire ?',
   '[{"id":"a","label":"Lancer un appel d''offres sur la bourse de fret","is_correct":false},{"id":"b","label":"Vérifier la faisabilité en moyens propres (véhicule + conducteur)","is_correct":true},{"id":"c","label":"Rechercher un sous-traitant référencé","is_correct":false},{"id":"d","label":"Reporter l''opération sur le planning","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch06','livret','affectation'], 'mft-2026-gotrm-livret:ch06:qcm:1', true,
   'La priorité 1 est toujours de vérifier la faisabilité en moyens propres avant tout recours à l''affrètement.'),

  -- QCM 2 (facile)
  (v_formation, v_module, 'qcm',
   'Que doit-on faire si les moyens propres ne sont pas disponibles ?',
   '[{"id":"a","label":"Refuser la commande","is_correct":false},{"id":"b","label":"Reporter l''opération à plus tard","is_correct":false},{"id":"c","label":"Recourir à un affrètement ponctuel auprès d''un sous-traitant","is_correct":true},{"id":"d","label":"Embaucher un nouveau conducteur","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch06','livret','affretement'], 'mft-2026-gotrm-livret:ch06:qcm:2', true,
   'Priorité 2 : si les moyens propres ne suffisent pas, on recherche un sous-traitant adapté et disponible.'),

  -- QCM 3 (facile)
  (v_formation, v_module, 'qcm',
   'Quelle qualification professionnelle est obligatoire pour tout conducteur PL ?',
   '[{"id":"a","label":"Le permis B uniquement","is_correct":false},{"id":"b","label":"La FIMO et la FCO","is_correct":true},{"id":"c","label":"Le certificat ADR","is_correct":false},{"id":"d","label":"L''attestation URSSAF","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch06','livret','conducteur','fimo'], 'mft-2026-gotrm-livret:ch06:qcm:3', true,
   'La FIMO (formation initiale, 140 h, une seule fois) et la FCO (formation continue, 35 h tous les 5 ans) sont obligatoires pour tout conducteur PL.'),

  -- QCM 4 (facile)
  (v_formation, v_module, 'qcm',
   'Quelle est la validité requise pour un extrait Kbis lors de la vérification d''un sous-traitant ?',
   '[{"id":"a","label":"Moins de 3 mois","is_correct":true},{"id":"b","label":"Moins de 6 mois","is_correct":false},{"id":"c","label":"Moins de 12 mois","is_correct":false},{"id":"d","label":"En cours de validité, sans limite d''ancienneté","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch06','livret','sous-traitant','kbis'], 'mft-2026-gotrm-livret:ch06:qcm:4', true,
   'L''extrait Kbis doit dater de moins de 3 mois pour être recevable.'),

  -- QCM 5 (moyen)
  (v_formation, v_module, 'qcm',
   'Concernant le véhicule, quel critère doit être vérifié pour traverser une ZFE (Zone à Faibles Émissions) ?',
   '[{"id":"a","label":"L''homologation ADR","is_correct":false},{"id":"b","label":"La compatibilité Crit''Air","is_correct":true},{"id":"c","label":"Le certificat ATP","is_correct":false},{"id":"d","label":"La charge utile","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch06','livret','vehicule','zfe'], 'mft-2026-gotrm-livret:ch06:qcm:5', true,
   'Pour les ZFE, on vérifie que la vignette Crit''Air du véhicule est compatible avec les zones traversées.'),

  -- QCM 6 (moyen)
  (v_formation, v_module, 'qcm',
   'Quelles sont les durées de validité respectives des attestations URSSAF et de vigilance fiscale ?',
   '[{"id":"a","label":"Moins de 3 mois pour les deux","is_correct":false},{"id":"b","label":"Moins de 6 mois pour les deux","is_correct":true},{"id":"c","label":"En cours de validité, sans limite","is_correct":false},{"id":"d","label":"Moins de 12 mois pour les deux","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch06','livret','sous-traitant','urssaf'], 'mft-2026-gotrm-livret:ch06:qcm:6', true,
   'Les attestations URSSAF (cotisations sociales) et de vigilance fiscale doivent dater de moins de 6 mois.'),

  -- QCM 7 (moyen)
  (v_formation, v_module, 'qcm',
   'Quelle est la différence entre licence communautaire et licence de transport intérieur ?',
   '[{"id":"a","label":"La communautaire est valable 5 ans, l''intérieure 10 ans","is_correct":false},{"id":"b","label":"La communautaire autorise les transports en France et dans l''UE, l''intérieure uniquement sur le territoire national","is_correct":true},{"id":"c","label":"La communautaire est délivrée par la mairie, l''intérieure par la préfecture","is_correct":false},{"id":"d","label":"La communautaire ne couvre que la France, l''intérieure couvre l''UE","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch06','livret','licence'], 'mft-2026-gotrm-livret:ch06:qcm:7', true,
   'Les deux licences sont valables 10 ans. La communautaire couvre France + UE, l''intérieure uniquement le territoire national.'),

  -- QCM 8 (moyen)
  (v_formation, v_module, 'qcm',
   'Combien d''étapes comporte la procédure d''affrètement ponctuel ?',
   '[{"id":"a","label":"5 étapes","is_correct":false},{"id":"b","label":"6 étapes","is_correct":false},{"id":"c","label":"7 étapes","is_correct":true},{"id":"d","label":"10 étapes","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch06','livret','affretement','procedure'], 'mft-2026-gotrm-livret:ch06:qcm:8', true,
   'La procédure d''affrètement ponctuel comporte 7 étapes : identifier, rechercher, vérifier, négocier, confirmer, planifier, transmettre les instructions.'),

  -- QCM 9 (difficile)
  (v_formation, v_module, 'qcm',
   'En cas de non-conformité administrative constatée chez un sous-traitant (licence expirée, assurance non à jour…), quelle est la conduite à tenir ?',
   '[{"id":"a","label":"Procéder à l''affectation puis régulariser ensuite","is_correct":false},{"id":"b","label":"Alerter impérativement la hiérarchie AVANT toute affectation","is_correct":true},{"id":"c","label":"Demander une remise commerciale au sous-traitant","is_correct":false},{"id":"d","label":"Confier l''opération à condition que le sous-traitant signe une décharge","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch06','livret','sous-traitant','responsabilite'], 'mft-2026-gotrm-livret:ch06:qcm:9', true,
   'Confier une opération à un sous-traitant irrégulier engage la responsabilité juridique et financière de l''entreprise donneur d''ordres : il faut alerter la hiérarchie AVANT toute affectation.'),

  -- QCM 10 (difficile)
  (v_formation, v_module, 'qcm',
   'Concernant l''obligation de prise en compte des situations de handicap, quel principe le gestionnaire doit-il appliquer ?',
   '[{"id":"a","label":"Le principe d''égalité de traitement strict (mêmes règles pour tous)","is_correct":false},{"id":"b","label":"Le principe d''aménagement raisonnable (Défenseur des droits)","is_correct":true},{"id":"c","label":"Le principe de précaution","is_correct":false},{"id":"d","label":"Le principe de subsidiarité","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch06','livret','handicap','reglementation'], 'mft-2026-gotrm-livret:ch06:qcm:10', true,
   'Le gestionnaire applique le principe d''aménagement raisonnable issu du Défenseur des droits : adaptation des conditions de travail aux besoins d''une personne handicapée.'),

  -- QR 1 (max_score 5)
  (v_formation, v_module, 'qr',
   'Énumérez les 5 critères matériels à vérifier pour choisir un véhicule lors d''une affectation.',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch06','livret','vehicule','criteres'], 'mft-2026-gotrm-livret:ch06:qr:1', true,
   'Les 5 critères : (1) Type de carrosserie adapté à la marchandise et aux conditions de chargement/déchargement ; (2) Charge utile (le poids réel ne dépasse pas la CU) ; (3) Volume et linéaire (la marchandise tient dans les dimensions intérieures) ; (4) Disponibilité (pas affecté, pas en maintenance/visite technique) ; (5) Conformité réglementaire (Crit''Air, ATP, ADR selon la mission).'),

  -- QR 2 (max_score 5)
  (v_formation, v_module, 'qr',
   'Citez les 5 documents administratifs à vérifier obligatoirement avant d''affecter un sous-traitant, en précisant la validité requise pour chacun.',
   NULL,
   5, 'difficile', ARRAY['gotrm','ch06','livret','sous-traitant','documents'], 'mft-2026-gotrm-livret:ch06:qr:2', true,
   'Les 5 documents : (1) Extrait Kbis — moins de 3 mois ; (2) Licence de transport intérieur ou communautaire — en cours de validité ; (3) Attestation d''assurance RC — en cours de validité ; (4) Attestation URSSAF — moins de 6 mois ; (5) Attestation de vigilance fiscale — moins de 6 mois.'),

  -- QR 3 (max_score 5)
  (v_formation, v_module, 'qr',
   'Décrivez les 7 étapes de la procédure d''affrètement ponctuel.',
   NULL,
   5, 'difficile', ARRAY['gotrm','ch06','livret','affretement','procedure'], 'mft-2026-gotrm-livret:ch06:qr:3', true,
   'Les 7 étapes : (1) Identifier précisément les caractéristiques de l''opération à sous-traiter ; (2) Rechercher un sous-traitant (bourse de fret ou liste de référencés) ; (3) Vérifier la situation administrative du sous-traitant sélectionné (OBLIGATOIRE) ; (4) Négocier et convenir du prix de l''affrètement ; (5) Émettre et transmettre la confirmation d''affrètement avant le chargement ; (6) Reporter l''opération sur le planning ; (7) Transmettre toutes les instructions nécessaires au sous-traitant.');

  -- ===================================================================
  -- QUIZ D'ENTRAÎNEMENT (10 QCM)
  -- ===================================================================

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Chapitre 6 — Quiz d''entraînement',
          'Quiz d''entraînement (10 questions) sur l''affectation des moyens matériels et humains.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch06:qcm:%';

  RAISE NOTICE '✓ Module Ch6 importé : 1 leçon, 10 QCM, 3 QR, 1 quiz d''entraînement.';
END $ch06_v4$;
