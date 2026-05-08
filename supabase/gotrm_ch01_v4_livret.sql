-- =====================================================================
-- GOTRM — Chapitre 1 : L'environnement du transport routier de marchandises
-- Source : Livret Pro CCP1 GOTRM V2 (A. SFAXI), pages 2 à 5
-- Idempotent : peut être rejoué sans effet de bord
-- =====================================================================

DO $ch01_v4$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_lesson uuid;
  v_quiz uuid;
BEGIN
  -- Formation GOTRM
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable.'; END IF;

  -- Bloc BC1
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1';
  IF v_bloc IS NULL THEN
    INSERT INTO public.blocs (code, title, description, "order")
    VALUES ('BC1', 'Bloc 1 — Compétences générales', 'Bloc générique partagé.', 1)
    ON CONFLICT (code) DO NOTHING RETURNING id INTO v_bloc;
    IF v_bloc IS NULL THEN SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1'; END IF;
  END IF;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Bloc BC1 introuvable.'; END IF;

  -- Idempotence : suppression de l'ancien module v4 si re-run
  DELETE FROM public.modules WHERE slug = 'gotrm-ch01-environnement-trm';

  -- Nettoyage banque par source_ref
  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch01:%';

  -- =====================================================================
  -- MODULE
  -- =====================================================================
  INSERT INTO public.modules (
    title, slug, bloc_id, summary, difficulty, duration_min, "order"
  ) VALUES (
    'Chapitre 1 — L''environnement du transport routier de marchandises',
    'gotrm-ch01-environnement-trm',
    v_bloc,
    'Comprendre les acteurs, les types de transport, le cadre réglementaire et le rôle du gestionnaire dans une opération de transport routier de marchandises.',
    'debutant',
    60,
    10
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 10, true) ON CONFLICT DO NOTHING;

  -- =====================================================================
  -- LEÇON UNIQUE — chapitre complet
  -- =====================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'L''environnement du transport routier de marchandises',
    'environnement-trm',
    1, 60,
$lesson$
# L'environnement du transport routier de marchandises

> 🎯 **Objectifs pédagogiques**
>
> - Situer le poids du transport routier de marchandises dans l'économie française.
> - Identifier les acteurs d'une opération de transport et leurs rôles respectifs.
> - Distinguer les principaux types de transport routier.
> - Connaître les textes qui encadrent la profession.
> - Cerner le rôle et les responsabilités du gestionnaire de transport sur les trois phases d'une opération.

Avant d'organiser une opération de transport, le gestionnaire doit connaître le secteur dans lequel il évolue : qui sont les acteurs, quels types de transport existent, quelles règles s'appliquent et quel est son propre rôle. Ce chapitre pose les bases indispensables à toute la suite du livret.

## 1.1 — Le transport routier de marchandises dans l'économie

Le transport routier de marchandises (TRM) est le mode de transport dominant en France : il assure plus de 85 % des échanges intérieurs de marchandises. Sans lui, aucune usine ne peut s'approvisionner en matières premières, aucun supermarché ne peut être réapprovisionné, aucun chantier ne peut recevoir ses matériaux. C'est une activité économique fondamentale, souvent invisible mais absolument indispensable au fonctionnement de la société.

Le secteur emploie plus de 600 000 salariés en France, dont environ 400 000 conducteurs. Les entreprises de transport vont de l'artisan-chauffeur indépendant aux grands groupes internationaux. Elles exercent dans des segments variés : messagerie, lots complets, température dirigée, matières dangereuses, transport international.

## 1.2 — Les acteurs d'une opération de transport

Dans une opération de transport, plusieurs personnes ou entreprises interviennent avec des rôles distincts. Le gestionnaire est en contact avec tous ces interlocuteurs au cours d'une même journée de travail.

| Acteur | Rôle | Point clé |
|---|---|---|
| Expéditeur (chargeur) | Entreprise ou personne qui remet la marchandise au transporteur | C'est chez lui que se fait le chargement du véhicule |
| Destinataire | Entreprise ou personne qui doit recevoir la marchandise | C'est chez lui que se fait le déchargement |
| Donneur d'ordres | Celui qui passe commande du transport et qui sera facturé | Peut être l'expéditeur, le destinataire ou un tiers |
| Transporteur | Entreprise qui réalise physiquement l'acheminement avec ses véhicules | Responsable de la marchandise de la prise en charge à la livraison |
| Commissionnaire | Organise le transport pour le compte d'autrui sans posséder ses propres véhicules | Responsable comme s'il effectuait lui-même le transport |
| Sous-traitant | Transporteur auquel on confie tout ou partie d'une opération | Sa situation administrative doit être vérifiée avant toute affectation |
| Affréteur | Met en relation un chargeur et un transporteur disponible | Intervient notamment sur les bourses de fret numériques |

**Port payé** : les frais de transport sont à la charge de l'expéditeur.

**Port dû** : les frais de transport sont à la charge du destinataire.

> 📌 **Exemple**
>
> La société MARTIN PIÈCES (Lyon) envoie des composants à DURAND AUTO (Bordeaux).
>
> Le transport est facturé à MARTIN PIÈCES (port payé). L'entreprise RHÔNE FRET effectue le transport.
>
> RHÔNE FRET n'ayant pas de véhicule disponible, elle confie l'opération à un sous-traitant, OUEST TRANSIT.
>
> → Expéditeur : MARTIN PIÈCES — Destinataire : DURAND AUTO
>
> → Donneur d'ordres : MARTIN PIÈCES — Transporteur principal : RHÔNE FRET
>
> → Sous-traitant : OUEST TRANSIT

## 1.3 — Les types de transport routier

| Type de transport | Description | Caractéristiques |
|---|---|---|
| Lots complets (LC) | Un véhicule entier pour un seul expéditeur et un seul destinataire | Chargement maximal — un client — une livraison directe |
| Lots partiels (½ lots) | La marchandise d'un client ne remplit pas un véhicule complet — plusieurs clients partagent | Regroupement de clients — économique — plusieurs arrêts |
| Messagerie | Transport de colis légers et en faible volume — nombreux destinataires | Réseau d'agences — plateformes de tri — délais J+1/J+2 |
| Express / livraison rapide | Délais très courts — garantie d'heure de livraison | Prix élevé — chaîne d'acheminement dédiée |
| Livraison urbaine | Distribution dans les centres-villes | Contraintes de gabarit et de ZFE importantes |

## 1.4 — Le cadre réglementaire général

> ⚠️ **Réglementation**
>
> **Le Code des transports** : texte de référence régissant l'ensemble de l'activité de transport en France.
>
> **Les contrats types** : s'appliquent automatiquement en l'absence de contrat particulier entre les parties.
> Il en existe plusieurs : contrat type général, messagerie, sous-traitance, déménagement, température dirigée.
>
> **Le règlement européen CE 561/2006 (RSE)** : fixe les durées maximales de conduite et les temps de repos obligatoires pour tous les conducteurs de poids lourds dans l'Union Européenne.
>
> **Le Code du travail et la Convention Collective Nationale des Transports Routiers (CCNTR)** : encadrent les conditions de travail et de rémunération des salariés du secteur.
>
> **L'accès à la profession de transporteur est conditionné à 4 critères cumulatifs** :
> honorabilité professionnelle — capacité financière — capacité professionnelle — établissement stable.

## 1.5 — Le gestionnaire de transport : rôle et responsabilités

Le gestionnaire de transport est l'interface permanente entre les clients, les conducteurs, les sous-traitants et la direction de l'entreprise. Son rôle évolue selon les trois phases d'une opération de transport.

| Phase | Missions du gestionnaire |
|---|---|
| Avant le transport | Analyser les demandes, calculer les prix, rédiger les offres, affecter les conducteurs et véhicules, planifier, constituer les dossiers documents |
| Pendant le transport | Transmettre les instructions, suivre l'exécution en temps réel, gérer les aléas, informer les clients |
| Après le transport | Contrôler les documents retournés, analyser les temps de service, renseigner les tableaux de bord, traiter les litiges, facturer |

> ⚠️ **Réglementation**
>
> Le gestionnaire engage sa responsabilité pénale lorsqu'il donne des instructions qui conduisent un conducteur à commettre des infractions à la réglementation sociale européenne.
> Il a également le devoir d'alerter sa hiérarchie en cas d'anomalie grave constatée.

## 1.6 — Vocabulaire essentiel

| Terme | Définition |
|---|---|
| TRM | Transport Routier de Marchandises |
| Chargeur / Expéditeur | Celui qui remet la marchandise au transporteur |
| Destinataire | Celui qui reçoit la marchandise à l'arrivée |
| Donneur d'ordres | Celui qui commande et paie le transport |
| Port payé | Frais de transport à la charge de l'expéditeur |
| Port dû | Frais de transport à la charge du destinataire |
| Commissionnaire de transport | Organise le transport pour le compte d'autrui |
| Contrat type | Contrat s'appliquant automatiquement en l'absence de contrat particulier |
| RSE | Réglementation Sociale Européenne — règles de conduite et de repos |
| CCNTR | Convention Collective Nationale des Transports Routiers |
| TMS | Transport Management System — logiciel de gestion du transport |
| Bourse de fret | Plateforme numérique de mise en relation chargeurs et transporteurs |
$lesson$,
'Acteurs, types de transport, cadre réglementaire, rôle du gestionnaire.'
  ) RETURNING id INTO v_lesson;

  -- =====================================================================
  -- BANQUE DE QUESTIONS — 10 QCM + 3 QR
  -- =====================================================================
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES

  -- QCM 1 — facile — part TRM
  (v_formation, v_module, 'qcm',
   'Quelle part des échanges intérieurs de marchandises est assurée par le transport routier en France ?',
   '[{"id":"a","label":"Environ 50 %","is_correct":false},{"id":"b","label":"Environ 70 %","is_correct":false},{"id":"c","label":"Plus de 85 %","is_correct":true},{"id":"d","label":"100 %","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch01','livret'], 'mft-2026-gotrm-livret:ch01:qcm:1', true,
   'Le TRM assure plus de 85 % des échanges intérieurs de marchandises en France (1.1).'),

  -- QCM 2 — facile — expéditeur
  (v_formation, v_module, 'qcm',
   'L''expéditeur (chargeur) est :',
   '[{"id":"a","label":"Celui qui reçoit la marchandise","is_correct":false},{"id":"b","label":"Celui qui remet la marchandise au transporteur","is_correct":true},{"id":"c","label":"Celui qui paie systématiquement la facture","is_correct":false},{"id":"d","label":"Le conducteur du véhicule","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch01','livret'], 'mft-2026-gotrm-livret:ch01:qcm:2', true,
   'L''expéditeur remet la marchandise au transporteur ; c''est chez lui que se fait le chargement (1.2).'),

  -- QCM 3 — facile — port dû
  (v_formation, v_module, 'qcm',
   'Un envoi expédié en "port dû" signifie que :',
   '[{"id":"a","label":"Les frais de transport sont à la charge de l''expéditeur","is_correct":false},{"id":"b","label":"Les frais de transport sont à la charge du destinataire","is_correct":true},{"id":"c","label":"Le transport est gratuit","is_correct":false},{"id":"d","label":"Le transport est payé à 50/50","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch01','livret'], 'mft-2026-gotrm-livret:ch01:qcm:3', true,
   'En port dû, les frais sont à la charge du destinataire (1.2).'),

  -- QCM 4 — facile — RSE
  (v_formation, v_module, 'qcm',
   'Le règlement européen CE 561/2006 (RSE) fixe :',
   '[{"id":"a","label":"Les règles fiscales applicables aux transporteurs","is_correct":false},{"id":"b","label":"Les durées maximales de conduite et les temps de repos des conducteurs","is_correct":true},{"id":"c","label":"Les tarifs minimums du transport","is_correct":false},{"id":"d","label":"Les règles de circulation en ville","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch01','livret'], 'mft-2026-gotrm-livret:ch01:qcm:4', true,
   'Le RSE fixe les durées maximales de conduite et les temps de repos obligatoires pour les conducteurs de poids lourds dans l''UE (1.4).'),

  -- QCM 5 — moyen — commissionnaire
  (v_formation, v_module, 'qcm',
   'Quelle est la spécificité du commissionnaire de transport ?',
   '[{"id":"a","label":"Il possède toujours sa propre flotte de véhicules","is_correct":false},{"id":"b","label":"Il organise le transport pour le compte d''autrui sans posséder ses propres véhicules","is_correct":true},{"id":"c","label":"Il ne peut intervenir qu''en transport international","is_correct":false},{"id":"d","label":"Il n''engage aucune responsabilité","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch01','livret'], 'mft-2026-gotrm-livret:ch01:qcm:5', true,
   'Le commissionnaire organise le transport sans posséder ses véhicules et est responsable comme s''il effectuait lui-même le transport (1.2).'),

  -- QCM 6 — moyen — messagerie
  (v_formation, v_module, 'qcm',
   'Quel type de transport correspond à des colis légers, en faible volume, avec de nombreux destinataires et des délais J+1/J+2 ?',
   '[{"id":"a","label":"Lots complets","is_correct":false},{"id":"b","label":"Lots partiels","is_correct":false},{"id":"c","label":"Messagerie","is_correct":true},{"id":"d","label":"Livraison urbaine","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch01','livret'], 'mft-2026-gotrm-livret:ch01:qcm:6', true,
   'La messagerie repose sur un réseau d''agences et plateformes de tri, avec des délais J+1/J+2 (1.3).'),

  -- QCM 7 — moyen — accès profession
  (v_formation, v_module, 'qcm',
   'Combien de critères cumulatifs conditionnent l''accès à la profession de transporteur ?',
   '[{"id":"a","label":"2","is_correct":false},{"id":"b","label":"3","is_correct":false},{"id":"c","label":"4","is_correct":true},{"id":"d","label":"5","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch01','livret'], 'mft-2026-gotrm-livret:ch01:qcm:7', true,
   '4 critères cumulatifs : honorabilité professionnelle, capacité financière, capacité professionnelle, établissement stable (1.4).'),

  -- QCM 8 — moyen — phases du gestionnaire
  (v_formation, v_module, 'qcm',
   'Quelle mission relève de la phase "Après le transport" pour le gestionnaire ?',
   '[{"id":"a","label":"Calculer les prix et rédiger les offres","is_correct":false},{"id":"b","label":"Transmettre les instructions au conducteur","is_correct":false},{"id":"c","label":"Contrôler les documents retournés et facturer","is_correct":true},{"id":"d","label":"Affecter les conducteurs et véhicules","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch01','livret'], 'mft-2026-gotrm-livret:ch01:qcm:8', true,
   'Après le transport : contrôle des documents, analyse des temps, tableaux de bord, litiges, facturation (1.5).'),

  -- QCM 9 — difficile — contrat type
  (v_formation, v_module, 'qcm',
   'Quand un contrat type s''applique-t-il dans une relation de transport ?',
   '[{"id":"a","label":"Toujours, même en présence d''un contrat particulier","is_correct":false},{"id":"b","label":"Automatiquement, en l''absence de contrat particulier entre les parties","is_correct":true},{"id":"c","label":"Uniquement sur demande écrite du transporteur","is_correct":false},{"id":"d","label":"Seulement pour les transports internationaux","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch01','livret'], 'mft-2026-gotrm-livret:ch01:qcm:9', true,
   'Les contrats types s''appliquent automatiquement en l''absence de contrat particulier entre les parties (1.4).'),

  -- QCM 10 — difficile — responsabilité pénale gestionnaire
  (v_formation, v_module, 'qcm',
   'Dans quel cas le gestionnaire de transport engage-t-il sa responsabilité pénale ?',
   '[{"id":"a","label":"Quand un client refuse de payer une facture","is_correct":false},{"id":"b","label":"Quand un véhicule tombe en panne sur la route","is_correct":false},{"id":"c","label":"Lorsqu''il donne des instructions qui conduisent un conducteur à enfreindre la RSE","is_correct":true},{"id":"d","label":"Quand un colis est livré en retard","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch01','livret'], 'mft-2026-gotrm-livret:ch01:qcm:10', true,
   'Le gestionnaire engage sa responsabilité pénale s''il donne des instructions qui conduisent un conducteur à commettre des infractions à la RSE (1.5).'),

  -- QR 1 — cas pratique acteurs
  (v_formation, v_module, 'qr',
   'La société MARTIN PIÈCES (Lyon) envoie des composants à DURAND AUTO (Bordeaux). Le transport est facturé à MARTIN PIÈCES. RHÔNE FRET, sans véhicule disponible, confie l''opération à OUEST TRANSIT. Identifiez : expéditeur, destinataire, donneur d''ordres, transporteur principal, sous-traitant, et précisez le mode de paiement.',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch01','livret','qr'], 'mft-2026-gotrm-livret:ch01:qr:1', true,
   'Expéditeur : MARTIN PIÈCES. Destinataire : DURAND AUTO. Donneur d''ordres : MARTIN PIÈCES (qui paie). Transporteur principal : RHÔNE FRET. Sous-traitant : OUEST TRANSIT. Mode de paiement : port payé (frais à la charge de l''expéditeur).'),

  -- QR 2 — cas pratique types de transport
  (v_formation, v_module, 'qr',
   'Un client souhaite acheminer 24 palettes (un camion complet) d''un seul site vers un seul destinataire, en livraison directe. Quel type de transport routier est le plus adapté et pourquoi ?',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch01','livret','qr'], 'mft-2026-gotrm-livret:ch01:qr:2', true,
   'Le lot complet (LC) : un véhicule entier pour un seul expéditeur et un seul destinataire, avec chargement maximal et livraison directe. C''est le format adapté lorsque la marchandise remplit un véhicule entier sans regroupement avec d''autres clients.'),

  -- QR 3 — cas pratique missions gestionnaire
  (v_formation, v_module, 'qr',
   'Citez au moins quatre missions du gestionnaire de transport sur la phase "Avant le transport" et expliquez pourquoi cette phase de préparation est déterminante.',
   NULL,
   5, 'difficile', ARRAY['gotrm','ch01','livret','qr'], 'mft-2026-gotrm-livret:ch01:qr:3', true,
   'Missions Avant le transport : analyser les demandes, calculer les prix, rédiger les offres, affecter les conducteurs et véhicules, planifier, constituer les dossiers documents. Cette phase est déterminante car elle conditionne la rentabilité (prix), la conformité réglementaire (dossiers documents, RSE), la qualité d''exécution (planification, affectation) et la satisfaction client (offre adaptée).');

  -- =====================================================================
  -- QUIZ ENTRAÎNEMENT — alimenté par les 10 QCM
  -- =====================================================================
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Chapitre 1 — Quiz d''entraînement',
          'Quiz d''entraînement (10 questions) sur l''environnement du transport routier.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch01:qcm:%';

  RAISE NOTICE '✓ Module Ch1 importé : 1 leçon, 10 QCM, 3 QR, 1 quiz d''entraînement.';

END $ch01_v4$;
