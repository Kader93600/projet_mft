-- =====================================================================
-- GOTRM — Chapitre 5 : Rédiger une offre commerciale
-- Source : Livret CCP1 GOTRM V2 (A. SFAXI), pages 19-21
-- Version v4 — schéma question_bank corrigé (statement / choices avec is_correct)
-- =====================================================================

DO $ch05_v4$
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

  -- Nettoyage idempotent
  DELETE FROM public.modules WHERE slug = 'gotrm-ch05-offre-commerciale';
  DELETE FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref LIKE 'mft-2026-gotrm-livret:ch05:%';

  -- Module
  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Chapitre 5 — Rédiger une offre commerciale',
          'gotrm-ch05-offre-commerciale', v_bloc,
          'Rédiger une offre commerciale conforme : contenu obligatoire, réponse positive ou négative argumentée, confirmation d''affrètement avec mentions légales, communication professionnelle avec le client.',
          'intermediaire', 50, 50)
  RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 50, true) ON CONFLICT DO NOTHING;

  -- Leçon
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (v_module, 'Rédiger une offre commerciale',
          'rediger-offre-commerciale', 1, 50,
$lesson$
# Rédiger une offre commerciale

Une fois la demande analysée et le prix calculé, le gestionnaire doit formaliser sa réponse par écrit. L'offre commerciale est un document qui engage l'entreprise vis-à-vis du client. Elle doit être précise, complète et rédigée de manière professionnelle.

> 🎯 **Objectifs pédagogiques**
>
> - Distinguer le régime de TVA applicable (national vs international).
> - Connaître le contenu obligatoire d'une offre commerciale.
> - Rédiger une réponse positive ou négative professionnelle.
> - Établir une confirmation d'affrètement conforme.
> - Adopter une communication écrite professionnelle avec le client.

---

## 5.1 — De la demande à l'offre commerciale

> ⚠️ **Réglementation**
>
> **Transport national (France)** : offre et facture exprimées HT + TVA 20 % sur la facture finale.
>
> **Transport international (hors France)** : exonération de TVA — règle de territorialité (CGI art. 262). L'offre et la facture sont alors établies HT sans TVA applicable.
>
> Une offre qui mentionne uniquement un prix sans détailler l'organisation de la prestation n'est PAS conforme aux critères d'évaluation de l'examen.

---

## 5.2 — Contenu obligatoire d'une offre commerciale

| Rubrique | Contenu attendu |
|---|---|
| Identification des parties | Raison sociale, adresse, SIRET du transporteur et du donneur d'ordres — date — référence dossier |
| Description de la marchandise | Nature, poids brut, dimensions, nombre et type d'unités de charge, contraintes particulières |
| Conditions de réalisation | Adresses exactes, dates et heures, modalités de chargement/déchargement, consignes de sécurité |
| Moyens techniques mis en œuvre | Type de véhicule et carrosserie, équipements spéciaux, organisation (direct/étapes), sous-traitance éventuelle |
| Conditions commerciales | Port payé ou port dû — prix HT détaillé — prestations annexes — total HT — TVA — conditions de paiement — validité de l'offre |

---

## 5.3 — Rédiger une réponse positive

Une offre positive suit toujours la même structure : accusé de réception de la demande, confirmation de la prise en charge, rappel des caractéristiques de l'envoi, description de la solution technique retenue, calendrier confirmé, prix HT détaillé, conditions de paiement, coordonnées du contact exploitation.

---

## 5.4 — Rédiger une réponse négative

Un refus bien rédigé vaut autant qu'une acceptation pour préserver la relation commerciale. Les motifs courants de refus sont : véhicule inadapté, conducteur indisponible, délais impossibles au regard de la RSE, prix client insuffisant.

> 💡 **Méthode**
>
> **Structure d'une réponse négative professionnelle :**
>
> 1. Remerciement pour la demande et accusé de réception
> 2. Annonce du refus avec ton professionnel et respectueux
> 3. Explication claire du motif (sans exposer les problèmes internes de l'entreprise)
> 4. Proposition d'alternative si possible (autre date, autre solution)
> 5. Expression de la disponibilité pour de futures demandes
> 6. Formule de clôture professionnelle
>
> **Formules utiles :**
> « Nous sommes au regret de vous informer que… »
> « Nous vous proposons toutefois… »
> « Restant à votre disposition pour toute demande future… »

---

## 5.5 — La confirmation d'affrètement

Lorsque le gestionnaire recourt à un sous-traitant ponctuel, il formalise cet accord par une confirmation d'affrètement. Ce document est obligatoire et doit être transmis avant le chargement.

> ⚠️ **Réglementation**
>
> **La confirmation d'affrètement doit obligatoirement mentionner :**
>
> - Identification des deux parties (donneur d'ordres et transporteur affrété)
> - Description complète de l'opération (marchandise, adresses, dates/heures, type de véhicule)
> - Conditions financières (prix HT convenu, conditions de paiement)
> - Identification du véhicule et du conducteur (immatriculations, nom conducteur)
>
> **Points de vigilance :**
>
> - Vérifier la situation administrative du sous-traitant AVANT d'émettre la confirmation.
> - La confirmation ne dispense pas d'établir une lettre de voiture.
> - Le prix doit couvrir l'ensemble des prestations confiées.

---

## 5.6 — Communication professionnelle avec le client

| Ce qu'il faut faire | Ce qu'il faut éviter |
|---|---|
| Ton professionnel et courtois en toutes circonstances | Ton familier ou agressif, même si le client est en tort |
| Phrases courtes, bien structurées, claires et précises | Formulations vagues ou ambiguës |
| Orthographe irréprochable | Fautes d'orthographe — dégradent l'image de l'entreprise |
| Référence systématique au numéro de dossier | Correspondances sans référence — impossibles à classer |
| Proposer une alternative en cas de refus | Refus sec sans explication ni alternative proposée |

---

## 5.7 — Vocabulaire essentiel

| Terme | Définition |
|---|---|
| Offre commerciale | Proposition technique et tarifaire formalisée par écrit qui engage l'entreprise |
| Confirmation d'affrètement | Document contractuel obligatoire liant le donneur d'ordres et le sous-traitant |
| Exonération TVA | Absence de TVA sur les transports internationaux — art. 262 CGI |
| Port payé | Frais de transport à la charge de l'expéditeur |
| Port dû | Frais de transport à la charge du destinataire |
| Valeur déclarée | Déclaration de la valeur réelle — modifie les limites d'indemnisation |
$lesson$,
'Demande à offre, contenu obligatoire, réponse positive/négative, confirmation affrètement.')
  RETURNING id INTO v_lesson;

  -- =====================================================================
  -- BANQUE DE QUESTIONS — 10 QCM + 3 QR
  -- =====================================================================
  INSERT INTO public.question_bank
    (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES
  -- ===== QCM 1 — facile =====
  (v_formation, v_module, 'qcm',
   'Quel taux de TVA s''applique à une offre de transport national en France ?',
   '[{"id":"a","label":"0 %","is_correct":false},{"id":"b","label":"5,5 %","is_correct":false},{"id":"c","label":"10 %","is_correct":false},{"id":"d","label":"20 %","is_correct":true}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch05','livret','tva'],
   'mft-2026-gotrm-livret:ch05:qcm:1', true,
   'Le transport national (France) est facturé HT + TVA 20 % sur la facture finale (section 5.1).'),

  -- ===== QCM 2 — facile =====
  (v_formation, v_module, 'qcm',
   'Quel article du CGI fonde l''exonération de TVA pour le transport international ?',
   '[{"id":"a","label":"Article 256 CGI","is_correct":false},{"id":"b","label":"Article 262 CGI","is_correct":true},{"id":"c","label":"Article 271 CGI","is_correct":false},{"id":"d","label":"Article 283 CGI","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch05','livret','tva','international'],
   'mft-2026-gotrm-livret:ch05:qcm:2', true,
   'L''exonération de TVA pour le transport international relève de la règle de territorialité — CGI art. 262 (section 5.1).'),

  -- ===== QCM 3 — facile =====
  (v_formation, v_module, 'qcm',
   'Que signifie « port payé » dans une offre commerciale ?',
   '[{"id":"a","label":"Frais de transport à la charge de l''expéditeur","is_correct":true},{"id":"b","label":"Frais de transport à la charge du destinataire","is_correct":false},{"id":"c","label":"Frais payés par le transporteur","is_correct":false},{"id":"d","label":"Frais réglés par avance par la banque","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch05','livret','vocabulaire'],
   'mft-2026-gotrm-livret:ch05:qcm:3', true,
   'Port payé : frais de transport à la charge de l''expéditeur (section 5.7 — Vocabulaire).'),

  -- ===== QCM 4 — facile =====
  (v_formation, v_module, 'qcm',
   'Quand la confirmation d''affrètement doit-elle être transmise au sous-traitant ?',
   '[{"id":"a","label":"Après le chargement","is_correct":false},{"id":"b","label":"Avant le chargement","is_correct":true},{"id":"c","label":"À la livraison","is_correct":false},{"id":"d","label":"À la facturation","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch05','livret','affretement'],
   'mft-2026-gotrm-livret:ch05:qcm:4', true,
   'La confirmation d''affrètement est obligatoire et doit être transmise AVANT le chargement (section 5.5).'),

  -- ===== QCM 5 — moyen =====
  (v_formation, v_module, 'qcm',
   'Parmi ces rubriques, laquelle relève des « conditions commerciales » d''une offre ?',
   '[{"id":"a","label":"SIRET du transporteur","is_correct":false},{"id":"b","label":"Type de carrosserie","is_correct":false},{"id":"c","label":"Validité de l''offre","is_correct":true},{"id":"d","label":"Consignes de sécurité au chargement","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch05','livret','contenu'],
   'mft-2026-gotrm-livret:ch05:qcm:5', true,
   'Les conditions commerciales incluent : port payé/dû, prix HT détaillé, prestations annexes, total HT, TVA, conditions de paiement et validité de l''offre (section 5.2).'),

  -- ===== QCM 6 — moyen =====
  (v_formation, v_module, 'qcm',
   'Que doit OBLIGATOIREMENT mentionner une confirmation d''affrètement ?',
   '[{"id":"a","label":"Uniquement le prix HT convenu","is_correct":false},{"id":"b","label":"Identification des deux parties, description de l''opération, conditions financières, identification véhicule et conducteur","is_correct":true},{"id":"c","label":"Seulement les coordonnées du conducteur","is_correct":false},{"id":"d","label":"Le numéro de la lettre de voiture uniquement","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch05','livret','affretement'],
   'mft-2026-gotrm-livret:ch05:qcm:6', true,
   'La confirmation d''affrètement doit obligatoirement mentionner les deux parties, la description complète de l''opération, les conditions financières et l''identification véhicule + conducteur (section 5.5).'),

  -- ===== QCM 7 — moyen =====
  (v_formation, v_module, 'qcm',
   'Une offre commerciale qui mentionne uniquement un prix sans détailler l''organisation de la prestation est-elle conforme aux critères d''évaluation de l''examen ?',
   '[{"id":"a","label":"Oui, le prix suffit","is_correct":false},{"id":"b","label":"Non, elle n''est pas conforme","is_correct":true},{"id":"c","label":"Oui, si la TVA est mentionnée","is_correct":false},{"id":"d","label":"Oui, si l''offre est en transport international","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch05','livret','examen'],
   'mft-2026-gotrm-livret:ch05:qcm:7', true,
   'Une offre qui mentionne uniquement un prix sans détailler l''organisation de la prestation N''EST PAS conforme aux critères d''évaluation de l''examen (section 5.1).'),

  -- ===== QCM 8 — moyen =====
  (v_formation, v_module, 'qcm',
   'Selon la méthode du livret, quelle est la 4ᵉ étape d''une réponse négative professionnelle ?',
   '[{"id":"a","label":"Remerciement et accusé de réception","is_correct":false},{"id":"b","label":"Annonce du refus","is_correct":false},{"id":"c","label":"Proposition d''alternative si possible","is_correct":true},{"id":"d","label":"Formule de clôture","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch05','livret','reponse-negative'],
   'mft-2026-gotrm-livret:ch05:qcm:8', true,
   'La structure en 6 étapes : 1) remerciement, 2) annonce du refus, 3) explication du motif, 4) proposition d''alternative, 5) disponibilité future, 6) formule de clôture (section 5.4).'),

  -- ===== QCM 9 — difficile =====
  (v_formation, v_module, 'qcm',
   'La confirmation d''affrètement dispense-t-elle d''établir une lettre de voiture ?',
   '[{"id":"a","label":"Oui, elle remplace la lettre de voiture","is_correct":false},{"id":"b","label":"Non, elle ne dispense pas d''établir une lettre de voiture","is_correct":true},{"id":"c","label":"Oui, en transport national uniquement","is_correct":false},{"id":"d","label":"Oui, si le conducteur est identifié","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch05','livret','affretement','vigilance'],
   'mft-2026-gotrm-livret:ch05:qcm:9', true,
   'Point de vigilance explicite : la confirmation d''affrètement NE DISPENSE PAS d''établir une lettre de voiture (section 5.5).'),

  -- ===== QCM 10 — difficile =====
  (v_formation, v_module, 'qcm',
   'Avant d''émettre une confirmation d''affrètement à un sous-traitant, quel contrôle est OBLIGATOIRE ?',
   '[{"id":"a","label":"Vérifier la situation administrative du sous-traitant","is_correct":true},{"id":"b","label":"Vérifier uniquement le prix","is_correct":false},{"id":"c","label":"Vérifier la couleur du véhicule","is_correct":false},{"id":"d","label":"Aucun contrôle n''est exigé","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch05','livret','affretement','sous-traitance'],
   'mft-2026-gotrm-livret:ch05:qcm:10', true,
   'Point de vigilance : vérifier la situation administrative du sous-traitant AVANT d''émettre la confirmation (section 5.5).'),

  -- ===== QR 1 — moyen =====
  (v_formation, v_module, 'qr',
   'Citez les 5 grandes rubriques du contenu obligatoire d''une offre commerciale et donnez un exemple d''élément attendu pour chacune.',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch05','livret','contenu','qr'],
   'mft-2026-gotrm-livret:ch05:qr:1', true,
   'Attendus (section 5.2) : 1) Identification des parties (raison sociale, SIRET, date, référence dossier) ; 2) Description marchandise (nature, poids brut, dimensions, unités de charge) ; 3) Conditions de réalisation (adresses, dates/heures, chargement/déchargement, consignes) ; 4) Moyens techniques (type véhicule/carrosserie, équipements spéciaux, sous-traitance) ; 5) Conditions commerciales (port payé/dû, prix HT, total HT, TVA, paiement, validité).'),

  -- ===== QR 2 — moyen =====
  (v_formation, v_module, 'qr',
   'Décrivez les 6 étapes de la méthode de rédaction d''une réponse négative professionnelle, telle que présentée dans le livret.',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch05','livret','reponse-negative','qr'],
   'mft-2026-gotrm-livret:ch05:qr:2', true,
   'Attendus (section 5.4) : 1) Remerciement pour la demande et accusé de réception ; 2) Annonce du refus avec ton professionnel et respectueux ; 3) Explication claire du motif (sans exposer les problèmes internes) ; 4) Proposition d''alternative si possible (autre date, autre solution) ; 5) Expression de la disponibilité pour de futures demandes ; 6) Formule de clôture professionnelle.'),

  -- ===== QR 3 — difficile =====
  (v_formation, v_module, 'qr',
   'Indiquez les 4 mentions obligatoires d''une confirmation d''affrètement et les 3 points de vigilance associés.',
   NULL,
   5, 'difficile', ARRAY['gotrm','ch05','livret','affretement','qr'],
   'mft-2026-gotrm-livret:ch05:qr:3', true,
   'Mentions obligatoires (section 5.5) : 1) Identification des deux parties (donneur d''ordres + transporteur affrété) ; 2) Description complète de l''opération (marchandise, adresses, dates/heures, type véhicule) ; 3) Conditions financières (prix HT convenu, conditions de paiement) ; 4) Identification du véhicule et du conducteur (immatriculations, nom conducteur). Points de vigilance : a) Vérifier la situation administrative du sous-traitant AVANT d''émettre la confirmation ; b) La confirmation ne dispense pas d''établir une lettre de voiture ; c) Le prix doit couvrir l''ensemble des prestations confiées.');

  -- =====================================================================
  -- QUIZ d'entraînement (10 QCM)
  -- =====================================================================
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Chapitre 5 — Quiz d''entraînement',
          'Quiz d''entraînement (10 questions) sur la rédaction d''une offre commerciale.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch05:qcm:%';

  RAISE NOTICE '✓ Module Ch5 importé : 1 leçon, 10 QCM, 3 QR, 1 quiz d''entraînement.';
END $ch05_v4$;
