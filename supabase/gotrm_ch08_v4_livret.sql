-- =====================================================================
-- GOTRM — Chapitre 8 : Planifier et optimiser les opérations
-- Source : LIVRET_PRO_CCP1_GOTRM V2.pdf (pages 29-31)
-- Idempotent : suppression du module + des questions liées avant insertion
-- =====================================================================

DO $ch08_v4$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_lesson uuid;
  v_quiz uuid;
BEGIN
  -- 1. Formation GOTRM
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation gotrm introuvable.';
  END IF;

  -- 2. Bloc BC1
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

  -- 3. Nettoyage idempotent
  DELETE FROM public.modules WHERE slug = 'gotrm-ch08-planifier-operations';
  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch08:%';

  -- 4. Module
  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Chapitre 8 — Planifier et optimiser les opérations',
    'gotrm-ch08-planifier-operations',
    v_bloc,
    'Maîtriser le planning d''exploitation, les principes d''optimisation des tournées (méthode 6 étapes), le groupage / dégroupage en messagerie et la réduction des kilomètres à vide.',
    'intermediaire',
    65,
    80
  )
  RETURNING id INTO v_module;

  -- 5. Liaison formation_modules
  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 80, true)
  ON CONFLICT DO NOTHING;

  -- 6. Leçon (markdown)
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (v_module, 'Planifier et optimiser les opérations', 'planifier-operations', 1, 65,
$lesson$
# Planifier et optimiser les opérations

> 🎯 **Objectifs pédagogiques**
> - Comprendre le rôle central du planning d'exploitation dans le service exploitation.
> - Identifier les contraintes à intégrer dans une tournée de livraison.
> - Construire une tournée optimisée à l'aide de la méthode en 6 étapes.
> - Distinguer les opérations de groupage et de dégroupage en messagerie.
> - Mettre en œuvre les leviers permettant de réduire les kilomètres à vide.

La planification est la pierre angulaire du service exploitation. Un bon gestionnaire ne se contente pas de répondre aux commandes au fil de l'eau : il anticipe, organise et optimise l'ensemble des opérations pour maximiser la rentabilité et la qualité de service. Ce chapitre présente les outils et méthodes de planification.

---

## 8.1 — Le planning d'exploitation

Le planning d'exploitation est l'outil central du service exploitation. Il récapitule en temps réel l'ensemble des affectations de la semaine : véhicules, conducteurs, trajets, clients, statuts. Un bon gestionnaire l'utilise pour optimiser les chargements, prévoir les rechargements et minimiser les kilomètres à vide.

Pour chaque opération, le planning renseigne : numéro de dossier, client, lieux et dates/heures de chargement et de livraison, véhicule affecté, conducteur, sous-traitant si affrètement, statut de l'opération.

> 📌 **Exemple — Lyon → Bordeaux et recharge retour**
>
> - **Lundi matin** : Véhicule 07 — **Opération A** : Lyon → Bordeaux (chargement 07h, livraison 14h30).
> - Véhicule disponible à Bordeaux pour rechargement.
> - Le gestionnaire publie la disponibilité sur la bourse de fret.
> - **Opération B** trouvée : Bordeaux → Lyon — 8 palettes ISO — départ 16h30 — livraison lundi soir.
> - **Résultat** : véhicule non revenu à vide — **économie de 580 km à vide**.

---

## 8.2 — Principes d'optimisation d'une tournée de livraison

Une tournée est un ensemble de livraisons et/ou de ramasses réalisées par un même véhicule au cours d'une journée. Elle est fréquente en messagerie et en distribution régionale. Son optimisation vise à servir tous les clients dans les délais convenus tout en parcourant le minimum de kilomètres.

### Contraintes à intégrer

| Contrainte à intégrer | Description |
|---|---|
| Créneau horaire client | Heure d'ouverture ou de fermeture imposée par le destinataire |
| Capacité du véhicule | Charge utile, volume disponible et mètres linéaires — limites à ne pas dépasser |
| RSE conducteur | Temps de conduite maximum, pauses obligatoires, temps de service total ≤ 12h |
| Accessibilité du site | Gabarit du site, tonnage limité, zone piétonne, ZFE — impose un type de véhicule |
| Priorité de livraison | Certains clients ont une heure de livraison impérative inscrite au contrat |
| Géographie et trafic | Distance, temps de trajet, embouteillages prévisibles — conditionne l'ordre des passages |

> 💡 **Méthode — Construire une tournée en 6 étapes**
>
> - **Étape 1** : Recenser tous les points à servir (adresses, volumes, créneaux, instructions).
> - **Étape 2** : Identifier les contraintes prioritaires (livraisons impératives en premier).
> - **Étape 3** : Séquencer les points géographiquement (méthode du plus proche voisin).
>     - → Partir du dépôt, aller au point le plus proche, puis au suivant.
>     - → Éviter les croisements de trajet inutiles.
> - **Étape 4** : Vérifier la faisabilité RSE (temps de service ≤ 12h, conduite ≤ 9h, pause 45 min).
> - **Étape 5** : Optimiser le retour (chercher des ramasses sur le trajet retour).
> - **Étape 6** : Formaliser et transmettre l'ordre de mission avec séquence et contacts.

---

## 8.3 — Le groupage et le dégroupage en messagerie

Le groupage consiste à regrouper sur un même véhicule les envois de plusieurs expéditeurs différents à destination d'une même zone géographique. L'objectif est d'optimiser le taux de remplissage et de partager les coûts entre plusieurs clients. Le dégroupage est l'opération inverse : sur la plateforme de destination, les envois sont triés et répartis pour les tournées de livraison locales.

| Étape | Lieu | Opération |
|---|---|---|
| Collecte / Ramasse | Site des expéditeurs | Enlèvement des envois chez les clients |
| Groupage | Plateforme départ | Tri et consolidation des envois par zone de destination |
| Acheminement (ligne) | Route | Transport du lot groupé vers la plateforme de destination |
| Dégroupage | Plateforme arrivée | Tri par destinataire et préparation des tournées locales |
| Distribution | Zone de livraison | Livraison à chaque destinataire dans sa tournée |

---

## 8.4 — Réduire les kilomètres à vide

Un véhicule qui rentre à vide représente une perte sèche de rentabilité : le carburant, le conducteur et le temps sont payés sans générer de recettes. Le gestionnaire doit systématiquement chercher à occuper le véhicule sur le trajet retour.

> ⚠️ **Réglementation**
>
> Le rechargement doit impérativement respecter la **RSE** : les temps de service restants du conducteur doivent permettre d'effectuer le rechargement sans infraction.
>
> **Moyens de trouver un fret de retour :**
> - → Commandes clients dont la direction correspond au retour du véhicule
> - → Bourse de fret : publication de la disponibilité du véhicule en retour
> - → Réseau de partenaires et de confrères

---

## 8.5 — Vocabulaire essentiel

| Terme | Définition |
|---|---|
| Planning d'exploitation | Outil récapitulant en temps réel toutes les affectations de véhicules et conducteurs |
| Tournée | Ensemble de livraisons et/ou ramasses réalisées par un véhicule en une journée |
| Séquencement | Détermination de l'ordre optimal des points de livraison dans une tournée |
| Groupage | Regroupement d'envois de plusieurs expéditeurs sur un même véhicule |
| Dégroupage | Tri des envois à l'arrivée sur une plateforme pour la distribution locale |
| Créneau horaire | Plage de temps imposée par le client pour la livraison |
| Rechargement / Fret retour | Chargement d'une nouvelle marchandise sur le trajet de retour du véhicule |
| Km à vide | Kilomètres parcourus sans marchandise — indicateur de rentabilité à minimiser |
| Lignier | Conducteur assurant les trajets entre plateformes de messagerie |
| Livreur | Conducteur assurant la distribution locale des envois en tournée |
$lesson$,
'Planning d''exploitation, optimisation de tournées (méthode 6 étapes), groupage / dégroupage en messagerie et réduction des kilomètres à vide.')
  RETURNING id INTO v_lesson;

  -- 7. Banque de questions : 10 QCM + 3 QR
  INSERT INTO public.question_bank (
    formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation
  ) VALUES
  -- ============= QCM 1 (facile) =============
  (v_formation, v_module, 'qcm',
   'Qu''est-ce que le planning d''exploitation ?',
   '[
     {"id":"a","label":"Un document comptable récapitulant les factures de la semaine","is_correct":false},
     {"id":"b","label":"L''outil central du service exploitation qui récapitule en temps réel les affectations (véhicules, conducteurs, trajets, clients, statuts)","is_correct":true},
     {"id":"c","label":"Le planning des congés des conducteurs","is_correct":false},
     {"id":"d","label":"Un registre légal obligatoire imposé par la DREAL","is_correct":false}
   ]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch08','livret','planning'],
   'mft-2026-gotrm-livret:ch08:qcm:1', true,
   'Le planning d''exploitation est l''outil central du service exploitation : il récapitule en temps réel l''ensemble des affectations de la semaine et permet d''optimiser chargements et rechargements.'),

  -- ============= QCM 2 (facile) =============
  (v_formation, v_module, 'qcm',
   'Dans l''exemple du livret (Lyon → Bordeaux puis Bordeaux → Lyon avec 8 palettes ISO), quelle économie a permis le rechargement retour ?',
   '[
     {"id":"a","label":"58 km à vide","is_correct":false},
     {"id":"b","label":"180 km à vide","is_correct":false},
     {"id":"c","label":"580 km à vide","is_correct":true},
     {"id":"d","label":"5 800 km à vide","is_correct":false}
   ]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch08','livret','exemple'],
   'mft-2026-gotrm-livret:ch08:qcm:2', true,
   'Le livret indique explicitement que le rechargement Bordeaux → Lyon a permis une économie de 580 km à vide.'),

  -- ============= QCM 3 (facile) =============
  (v_formation, v_module, 'qcm',
   'Qu''est-ce qu''une tournée de livraison ?',
   '[
     {"id":"a","label":"Un voyage longue distance entre deux plateformes éloignées","is_correct":false},
     {"id":"b","label":"Un ensemble de livraisons et/ou de ramasses réalisées par un même véhicule au cours d''une journée","is_correct":true},
     {"id":"c","label":"Une mission ponctuelle confiée à un sous-traitant","is_correct":false},
     {"id":"d","label":"Le retour à vide d''un véhicule vers son dépôt","is_correct":false}
   ]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch08','livret','tournee'],
   'mft-2026-gotrm-livret:ch08:qcm:3', true,
   'Une tournée est un ensemble de livraisons et/ou de ramasses réalisées par un même véhicule au cours d''une journée. Elle est fréquente en messagerie et en distribution régionale.'),

  -- ============= QCM 4 (facile) =============
  (v_formation, v_module, 'qcm',
   'Que désignent les "km à vide" et pourquoi sont-ils un indicateur clé ?',
   '[
     {"id":"a","label":"Les kilomètres parcourus à charge partielle, indicateur de qualité","is_correct":false},
     {"id":"b","label":"Les kilomètres parcourus sans marchandise — indicateur de rentabilité à minimiser","is_correct":true},
     {"id":"c","label":"Les kilomètres effectués hors du territoire national","is_correct":false},
     {"id":"d","label":"Les kilomètres parcourus pendant les pauses obligatoires du conducteur","is_correct":false}
   ]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch08','livret','vocabulaire'],
   'mft-2026-gotrm-livret:ch08:qcm:4', true,
   'Les km à vide sont les kilomètres parcourus sans marchandise. C''est un indicateur de rentabilité à minimiser car le carburant, le conducteur et le temps sont payés sans générer de recettes.'),

  -- ============= QCM 5 (moyen) =============
  (v_formation, v_module, 'qcm',
   'Parmi les contraintes à intégrer dans la construction d''une tournée, laquelle correspond à la RSE conducteur ?',
   '[
     {"id":"a","label":"Charge utile, volume disponible et mètres linéaires","is_correct":false},
     {"id":"b","label":"Heure d''ouverture ou de fermeture imposée par le destinataire","is_correct":false},
     {"id":"c","label":"Temps de conduite maximum, pauses obligatoires, temps de service total ≤ 12h","is_correct":true},
     {"id":"d","label":"Gabarit du site, tonnage limité, ZFE","is_correct":false}
   ]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch08','livret','rse','tournee'],
   'mft-2026-gotrm-livret:ch08:qcm:5', true,
   'La contrainte RSE conducteur recouvre le temps de conduite maximum, les pauses obligatoires et un temps de service total ≤ 12h.'),

  -- ============= QCM 6 (moyen) =============
  (v_formation, v_module, 'qcm',
   'Dans la méthode de construction d''une tournée en 6 étapes, à quoi correspond l''étape 3 ?',
   '[
     {"id":"a","label":"Recenser tous les points à servir","is_correct":false},
     {"id":"b","label":"Séquencer les points géographiquement (méthode du plus proche voisin)","is_correct":true},
     {"id":"c","label":"Vérifier la faisabilité RSE","is_correct":false},
     {"id":"d","label":"Formaliser et transmettre l''ordre de mission","is_correct":false}
   ]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch08','livret','methode'],
   'mft-2026-gotrm-livret:ch08:qcm:6', true,
   'Étape 3 = séquencer les points géographiquement, par la méthode du plus proche voisin (partir du dépôt, aller au point le plus proche, puis au suivant), en évitant les croisements inutiles.'),

  -- ============= QCM 7 (moyen) =============
  (v_formation, v_module, 'qcm',
   'En messagerie, comment se définit l''opération de groupage ?',
   '[
     {"id":"a","label":"Le tri des envois à l''arrivée sur une plateforme pour la distribution locale","is_correct":false},
     {"id":"b","label":"Le regroupement, sur un même véhicule, des envois de plusieurs expéditeurs différents à destination d''une même zone géographique","is_correct":true},
     {"id":"c","label":"L''affectation d''un conducteur à plusieurs véhicules en alternance","is_correct":false},
     {"id":"d","label":"La fusion de plusieurs commandes d''un même client en un seul dossier","is_correct":false}
   ]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch08','livret','messagerie'],
   'mft-2026-gotrm-livret:ch08:qcm:7', true,
   'Le groupage consiste à regrouper sur un même véhicule les envois de plusieurs expéditeurs différents à destination d''une même zone géographique, afin d''optimiser le taux de remplissage et de partager les coûts.'),

  -- ============= QCM 8 (moyen) =============
  (v_formation, v_module, 'qcm',
   'Dans la chaîne messagerie, à quelle étape correspond l''opération réalisée sur la plateforme d''arrivée ?',
   '[
     {"id":"a","label":"Collecte / Ramasse — enlèvement chez les expéditeurs","is_correct":false},
     {"id":"b","label":"Groupage — tri et consolidation par zone de destination","is_correct":false},
     {"id":"c","label":"Dégroupage — tri par destinataire et préparation des tournées locales","is_correct":true},
     {"id":"d","label":"Distribution — livraison à chaque destinataire","is_correct":false}
   ]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch08','livret','messagerie'],
   'mft-2026-gotrm-livret:ch08:qcm:8', true,
   'Le dégroupage a lieu sur la plateforme d''arrivée : les envois sont triés par destinataire et les tournées locales de distribution sont préparées.'),

  -- ============= QCM 9 (difficile) =============
  (v_formation, v_module, 'qcm',
   'Pour réduire les km à vide, le rechargement doit impérativement respecter la RSE. Cela signifie que :',
   '[
     {"id":"a","label":"Le conducteur peut dépasser ses temps de conduite à condition de prévenir l''exploitant","is_correct":false},
     {"id":"b","label":"Les temps de service restants du conducteur doivent permettre d''effectuer le rechargement sans infraction","is_correct":true},
     {"id":"c","label":"Le rechargement n''est autorisé qu''avec un second conducteur","is_correct":false},
     {"id":"d","label":"La RSE ne s''applique pas aux trajets de retour à vide","is_correct":false}
   ]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch08','livret','rse','reglementation'],
   'mft-2026-gotrm-livret:ch08:qcm:9', true,
   'Le livret précise que le rechargement doit impérativement respecter la RSE : les temps de service restants du conducteur doivent permettre d''effectuer le rechargement sans infraction.'),

  -- ============= QCM 10 (difficile) =============
  (v_formation, v_module, 'qcm',
   'Parmi les propositions suivantes, laquelle ne figure PAS dans les moyens cités par le livret pour trouver un fret de retour ?',
   '[
     {"id":"a","label":"Commandes clients dont la direction correspond au retour du véhicule","is_correct":false},
     {"id":"b","label":"Bourse de fret : publication de la disponibilité du véhicule en retour","is_correct":false},
     {"id":"c","label":"Réseau de partenaires et de confrères","is_correct":false},
     {"id":"d","label":"Mise en location du véhicule à un particulier sur une plateforme tierce","is_correct":true}
   ]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch08','livret','fret-retour'],
   'mft-2026-gotrm-livret:ch08:qcm:10', true,
   'Le livret cite trois moyens pour trouver un fret de retour : commandes clients dans la direction du retour, bourse de fret et réseau de partenaires / confrères. La location à un particulier n''en fait pas partie.'),

  -- ============= QR 1 (5 pts) =============
  (v_formation, v_module, 'qr',
   'Citez et décrivez brièvement les six étapes de la méthode de construction d''une tournée présentée dans le livret.',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch08','livret','methode','qr'],
   'mft-2026-gotrm-livret:ch08:qr:1', true,
   'Étape 1 : recenser tous les points à servir (adresses, volumes, créneaux, instructions). Étape 2 : identifier les contraintes prioritaires (livraisons impératives en premier). Étape 3 : séquencer les points géographiquement (méthode du plus proche voisin, en évitant les croisements). Étape 4 : vérifier la faisabilité RSE (temps de service ≤ 12h, conduite ≤ 9h, pause 45 min). Étape 5 : optimiser le retour (chercher des ramasses). Étape 6 : formaliser et transmettre l''ordre de mission avec séquence et contacts.'),

  -- ============= QR 2 (5 pts) =============
  (v_formation, v_module, 'qr',
   'Décrivez la chaîne complète d''une opération de messagerie : citez les cinq étapes (étape, lieu, opération) telles que présentées dans le livret.',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch08','livret','messagerie','qr'],
   'mft-2026-gotrm-livret:ch08:qr:2', true,
   '1) Collecte / Ramasse — site des expéditeurs — enlèvement des envois chez les clients. 2) Groupage — plateforme de départ — tri et consolidation des envois par zone de destination. 3) Acheminement (ligne) — route — transport du lot groupé vers la plateforme de destination. 4) Dégroupage — plateforme d''arrivée — tri par destinataire et préparation des tournées locales. 5) Distribution — zone de livraison — livraison à chaque destinataire dans sa tournée.'),

  -- ============= QR 3 (5 pts) =============
  (v_formation, v_module, 'qr',
   'Pourquoi un véhicule qui rentre à vide représente-t-il une perte sèche de rentabilité ? Citez trois moyens permettant au gestionnaire de trouver un fret de retour.',
   NULL,
   5, 'difficile', ARRAY['gotrm','ch08','livret','fret-retour','qr'],
   'mft-2026-gotrm-livret:ch08:qr:3', true,
   'Un véhicule qui rentre à vide représente une perte sèche car le carburant, le conducteur et le temps sont payés sans générer de recettes. Les trois moyens cités par le livret pour trouver un fret de retour sont : (1) les commandes clients dont la direction correspond au retour du véhicule ; (2) la bourse de fret, en publiant la disponibilité du véhicule en retour ; (3) le réseau de partenaires et de confrères. Le rechargement doit impérativement respecter la RSE.');

  -- 8. Quiz d'entraînement
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (
    v_module,
    'Chapitre 8 — Quiz d''entraînement',
    'Quiz d''entraînement (10 questions) sur la planification et l''optimisation des opérations.',
    'entrainement',
    NULL,
    70
  )
  RETURNING id INTO v_quiz;

  -- 9. Liaison quiz <-> questions QCM
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch08:qcm:%';

  RAISE NOTICE '✓ Module Ch8 (Planifier et optimiser les opérations) importé.';
END $ch08_v4$;
