-- =====================================================================
-- GOTRM — Chapitre 11 : Le suivi d'exploitation et la gestion des aléas
-- Source : LIVRET_PRO_CCP1_GOTRM V2.pdf (pages 42 à 46)
-- Module idempotent : ré-exécution sûre.
-- =====================================================================

DO $ch11_v4$
DECLARE
  v_formation uuid;
  v_bloc      int;
  v_module    uuid;
  v_lesson    uuid;
  v_quiz      uuid;
BEGIN
  -- 1. Formation gotrm
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation gotrm introuvable.';
  END IF;

  -- 2. Bloc BC1 (générique partagé)
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
  DELETE FROM public.modules WHERE slug = 'gotrm-ch11-suivi-aleas';
  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch11:%';

  -- 4. Module
  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Chapitre 11 — Le suivi d''exploitation et la gestion des aléas',
    'gotrm-ch11-suivi-aleas',
    v_bloc,
    'Suivre l''exécution des opérations en temps réel (TMS, GPS), identifier et traiter les aléas (retards, pannes, refus livraison) selon une méthode structurée et communiquer avec le client en situation difficile.',
    'intermediaire',
    70,
    110
  )
  RETURNING id INTO v_module;

  -- 5. Liaison formation_modules
  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 110, true)
  ON CONFLICT DO NOTHING;

  -- 6. Leçon unique
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module,
    'Le suivi d''exploitation et la gestion des aléas',
    'suivi-aleas',
    1,
    70,
$lesson$
# Chapitre 11 — Le suivi d'exploitation et la gestion des aléas

> Une fois le véhicule parti, la mission du gestionnaire ne s'arrête pas. Il doit suivre l'exécution de chaque opération en temps réel, détecter les anomalies le plus tôt possible et réagir efficacement face aux imprévus. Sa réactivité et sa capacité à communiquer conditionnent directement la satisfaction du client et la rentabilité de l'opération.

---

## 11.1 — Les outils de suivi d'exploitation

| Outil | Fonctionnalités principales | Utilité pour le gestionnaire |
|---|---|---|
| **TMS (Transport Management System)** | Affecter les opérations, suivre les statuts, transmettre les ordres, enregistrer les anomalies, tracer les échanges | Vision globale et centralisée de toute l'exploitation en temps réel |
| **Géolocalisation GPS** | Localiser le véhicule, estimer l'heure d'arrivée (ETA), identifier les arrêts prolongés | Réagir rapidement en cas d'imprévu sans attendre le contact du conducteur |
| **Tableau de suivi exploitation** | Dossier, conducteur, trajet, heures prévues/réelles, statut, observations | Contrôle visuel rapide de l'avancement de toutes les opérations en cours |

> **À RETENIR**
> - Un bon suivi d'exploitation permet d'anticiper les problèmes avant qu'ils ne deviennent des litiges.
> - Le TMS centralise toutes les informations : c'est la mémoire vivante de l'exploitation.
> - Chaque anomalie doit être saisie immédiatement pour garantir la traçabilité de l'opération.

---

## 11.2 — Les principaux aléas d'exploitation

| Aléa | Conséquences possibles | Priorité | Interlocuteurs à prévenir |
|---|---|---|---|
| **Panne véhicule** | Immobilisation du transport | Haute | Atelier, client, destinataire |
| **Accident** | Retard + risque sécurité | Très haute | Secours, hiérarchie, assurance, client |
| **Panne groupe froid (frigorifique)** | Rupture de chaîne du froid, destruction marchandise | Très haute | Client, assurance, atelier en urgence |
| **Embouteillage important** | Retard de livraison | Moyenne | Client, destinataire |
| **Marchandise non prête au chargement** | Attente conducteur — coût inutile | Moyenne | Client expéditeur |
| **Destinataire absent** | Échec de livraison | Haute | Client, destinataire |
| **Erreur de chargement** | Refus de livraison, retour marchandise | Haute | Donneur d'ordres, entrepôt |
| **Absence conducteur (maladie)** | Désorganisation du planning | Haute | RH, exploitation, client |
| **Intempéries (neige, verglas)** | Retards et interdictions de circulation | Moyenne | Client, préfecture si nécessaire |

---

## 11.3 — Méthode de traitement d'un aléa

> **METHODE**

**ÉTAPE 1 — Identifier précisément le problème**
Nature de l'aléa, lieu exact, heure, gravité estimée, impact sur la livraison.

**ÉTAPE 2 — Évaluer les conséquences**
Retard estimé, impact client, impact réglementaire (RSE), impact financier, risque sécurité.

**ÉTAPE 3 — Déterminer et mettre en œuvre une solution**
Changement d'itinéraire, remplacement du véhicule, transbordement, reprogrammation, recours à un sous-traitant, retour au dépôt, relivraison.

**ÉTAPE 4 — Informer tous les interlocuteurs concernés**
Conducteur, client, destinataire, hiérarchie, atelier, assurance selon les cas.

**ÉTAPE 5 — Assurer la traçabilité**
Enregistrement de l'événement et des décisions prises dans le TMS ou le dossier transport.

---

## 11.4 — Gestion d'un retard transport

Le retard est l'aléa le plus fréquent en exploitation. Le gestionnaire doit agir rapidement pour limiter les conséquences commerciales et préserver la relation client.

> **CAS PRATIQUE — RETARD CASCADE SUR UNE TOURNÉE MULTI-CLIENTS**

**Situation** : Le conducteur BRUN effectue une tournée de 4 livraisons en région parisienne.
Un accident sur le périphérique génère un retard initial de 1h15.

- Client A (Clichy) : 09h00
- Client B (Saint-Denis) : 10h30
- Client C (Pantin) : 12h00
- Client D (Vincennes) : 14h00

**CORRECTION — Actions prioritaires du gestionnaire :**

1. Appeler le conducteur pour confirmer la situation et l'ETA révisé.
2. Prévenir en priorité le Client A (premier livré, retard certain).
3. Prévenir le Client B avec ETA estimé.
4. Évaluer si le Client C peut être livré dans les délais tolérés.
5. Prévenir le Client D par précaution.
6. Documenter chaque appel et décision dans le TMS.
7. Proposer des solutions compensatoires si engagements contractuels non respectés.

> **À RETENIR**
> - Le client accepte généralement un retard lorsqu'il est informé rapidement et proactivement.
> - Le manque d'information est souvent plus pénalisant commercialement que le retard lui-même.
> - Un retard en cascade doit être traité par ordre chronologique de livraison.

---

## 11.5 — Gestion d'une panne véhicule

> **METHODE**

1. Localiser précisément le véhicule (GPS + appel conducteur).
2. Identifier la gravité de la panne.
3. Contacter l'assistance ou l'atelier.
4. Évaluer les délais d'intervention.
5. Déterminer si un transbordement de la marchandise est nécessaire.
6. Informer le client et le destinataire.
7. Mettre à jour le planning d'exploitation.
8. Prévenir l'assurance si nécessaire.

> **POINT DE VIGILANCE**
>
> **Cas particulier — Panne du groupe froid sur un véhicule frigorifique :**
> - Relevé immédiat et horodaté de la température dans la caisse.
> - Si la température dépasse le seuil critique (ex. −15 °C pour les surgelés) : décision de transbordement OBLIGATOIRE sur un autre véhicule ATP disponible.
> - Information immédiate du client.
> - Enregistrement de toutes les températures relevées pour traçabilité.
> - Déclaration à l'assurance marchandise selon le protocole de l'entreprise.

---

## 11.6 — Le refus de livraison

Le destinataire peut refuser la marchandise pour plusieurs raisons : avarie visible, erreur de référence, retard jugé inacceptable, quantité incomplète, emballage détérioré. Le gestionnaire doit réagir rapidement pour décider du devenir de la marchandise.

| Motif de refus | Action immédiate | Décision possible | Traçabilité à assurer |
|---|---|---|---|
| **Avarie visible** | Photos + réserves précises sur le CMR | Retour ou expertise | Fiche avarie + déclaration assurance |
| **Erreur de référence** | Vérification CMR et BL | Retour entrepôt + relivraison | Note d'anomalie TMS |
| **Quantité incomplète** | Comptage contradictoire | Livraison complémentaire | Réserve sur CMR + rapport |
| **Emballage détérioré** | Photos + constat contradictoire | Acceptation partielle ou refus total | Fiche incident + photos |

---

## 11.7 — La communication en situation difficile

| Ce qu'il faut faire | Ce qu'il faut éviter |
|---|---|
| Informer rapidement, même sans solution définitive | Attendre d'avoir résolu le problème pour appeler |
| Rester factuel et précis dans les explications | Réponses vagues ou évasives |
| Proposer une solution ou un délai de réponse précis | Rejeter la responsabilité sur le conducteur ou le trafic |
| Rassurer sans promettre l'impossible | Promettre une livraison irréaliste pour calmer le client |
| Tracer tous les échanges dans le TMS | Communication orale non enregistrée |

> **À RETENIR — Formulations professionnelles recommandées :**
> - « Nous rencontrons actuellement un retard lié à [cause précise]. »
> - « Une solution alternative est en cours de mise en place. »
> - « Nous vous tiendrons informé dans [délai précis]. »
> - « Je fais le point et vous rappelle dans 30 minutes. »

---

## 11.8 — Vocabulaire essentiel

| Terme | Définition |
|---|---|
| **Aléa d'exploitation** | Événement imprévu perturbant le déroulement normal d'une opération |
| **TMS** | Transport Management System — logiciel centralisant la gestion des opérations |
| **ETA** | Estimated Time of Arrival — heure d'arrivée estimée |
| **Traçabilité** | Suivi chronologique et documenté de toutes les étapes d'une opération |
| **Transbordement** | Transfert d'une marchandise d'un véhicule vers un autre |
| **Relivraison** | Nouvelle tentative de livraison après un premier échec |
| **Retour à vide** | Retour d'un véhicule sans marchandise — perte de rentabilité |
| **SAV** | Service Après-Vente — traitement des litiges et réclamations clients |
$lesson$,
'TMS/GPS, aléas, méthode traitement, retards, pannes, refus livraison.'
  )
  RETURNING id INTO v_lesson;

  -- 7. Banque de questions : 12 QCM + 4 QR
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  -- ============== QCM 1 — facile ==============
  (v_formation, v_module, 'qcm',
   'Que signifie l''acronyme TMS dans le contexte du transport ?',
   '[{"id":"a","label":"Truck Movement Service","is_correct":false},
     {"id":"b","label":"Transport Management System","is_correct":true},
     {"id":"c","label":"Transit Monitoring Solution","is_correct":false},
     {"id":"d","label":"Trajet Multi-Sites","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch11','livret','tms'],
   'mft-2026-gotrm-livret:ch11:qcm:1', true,
   'Le TMS (Transport Management System) est le logiciel qui centralise toute la gestion des opérations.'),

  -- ============== QCM 2 — facile ==============
  (v_formation, v_module, 'qcm',
   'Que signifie l''acronyme ETA ?',
   '[{"id":"a","label":"Estimated Truck Arrival","is_correct":false},
     {"id":"b","label":"European Transport Agreement","is_correct":false},
     {"id":"c","label":"Estimated Time of Arrival","is_correct":true},
     {"id":"d","label":"Express Transit Authority","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch11','livret','eta'],
   'mft-2026-gotrm-livret:ch11:qcm:2', true,
   'ETA = Estimated Time of Arrival, l''heure d''arrivée estimée du véhicule.'),

  -- ============== QCM 3 — facile ==============
  (v_formation, v_module, 'qcm',
   'Quel outil permet de localiser le véhicule et d''identifier les arrêts prolongés ?',
   '[{"id":"a","label":"Le tableau de suivi papier","is_correct":false},
     {"id":"b","label":"La géolocalisation GPS","is_correct":true},
     {"id":"c","label":"Le BL (bon de livraison)","is_correct":false},
     {"id":"d","label":"Le CMR","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch11','livret','gps'],
   'mft-2026-gotrm-livret:ch11:qcm:3', true,
   'La géolocalisation GPS permet de localiser le véhicule, estimer l''ETA et identifier les arrêts prolongés.'),

  -- ============== QCM 4 — facile ==============
  (v_formation, v_module, 'qcm',
   'Quel est l''aléa d''exploitation le plus fréquent ?',
   '[{"id":"a","label":"L''accident","is_correct":false},
     {"id":"b","label":"Le retard","is_correct":true},
     {"id":"c","label":"L''absence du conducteur","is_correct":false},
     {"id":"d","label":"L''erreur de chargement","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','ch11','livret','retard'],
   'mft-2026-gotrm-livret:ch11:qcm:4', true,
   'Le livret indique explicitement que le retard est l''aléa le plus fréquent en exploitation (§11.4).'),

  -- ============== QCM 5 — moyen ==============
  (v_formation, v_module, 'qcm',
   'Selon la méthode de traitement d''un aléa, quelle est la première étape à réaliser ?',
   '[{"id":"a","label":"Informer immédiatement le client","is_correct":false},
     {"id":"b","label":"Identifier précisément le problème","is_correct":true},
     {"id":"c","label":"Mettre en œuvre une solution","is_correct":false},
     {"id":"d","label":"Assurer la traçabilité dans le TMS","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch11','livret','methode'],
   'mft-2026-gotrm-livret:ch11:qcm:5', true,
   'Étape 1 de la méthode : Identifier précisément le problème (nature, lieu, heure, gravité, impact).'),

  -- ============== QCM 6 — moyen ==============
  (v_formation, v_module, 'qcm',
   'Quelle est la priorité associée à une panne du groupe froid sur un véhicule frigorifique ?',
   '[{"id":"a","label":"Moyenne","is_correct":false},
     {"id":"b","label":"Haute","is_correct":false},
     {"id":"c","label":"Très haute","is_correct":true},
     {"id":"d","label":"Faible","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch11','livret','frigo'],
   'mft-2026-gotrm-livret:ch11:qcm:6', true,
   'Une panne groupe froid entraîne une rupture de chaîne du froid et la destruction de la marchandise : priorité Très haute.'),

  -- ============== QCM 7 — moyen ==============
  (v_formation, v_module, 'qcm',
   'En cas de panne du groupe froid avec dépassement du seuil critique, quelle décision est OBLIGATOIRE ?',
   '[{"id":"a","label":"Continuer la livraison en accélérant","is_correct":false},
     {"id":"b","label":"Transbordement sur un autre véhicule ATP disponible","is_correct":true},
     {"id":"c","label":"Retour immédiat au dépôt sans avertir","is_correct":false},
     {"id":"d","label":"Attendre la baisse de la température extérieure","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch11','livret','frigo','transbordement'],
   'mft-2026-gotrm-livret:ch11:qcm:7', true,
   'Si la température dépasse le seuil critique (ex. −15 °C pour les surgelés), le transbordement sur un autre véhicule ATP est OBLIGATOIRE.'),

  -- ============== QCM 8 — moyen ==============
  (v_formation, v_module, 'qcm',
   'En cas de refus de livraison pour avarie visible, quelle action immédiate doit être effectuée ?',
   '[{"id":"a","label":"Prendre des photos + réserves précises sur le CMR","is_correct":true},
     {"id":"b","label":"Repartir immédiatement sans rien noter","is_correct":false},
     {"id":"c","label":"Faire signer un nouveau bon de livraison","is_correct":false},
     {"id":"d","label":"Demander au destinataire de garder la marchandise","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch11','livret','refus','avarie'],
   'mft-2026-gotrm-livret:ch11:qcm:8', true,
   'Avarie visible : action immédiate = photos + réserves précises sur le CMR (tableau §11.6).'),

  -- ============== QCM 9 — moyen ==============
  (v_formation, v_module, 'qcm',
   'En cas de quantité incomplète à la livraison, quelle est l''action immédiate ?',
   '[{"id":"a","label":"Refuser totalement la marchandise","is_correct":false},
     {"id":"b","label":"Effectuer un comptage contradictoire","is_correct":true},
     {"id":"c","label":"Repartir immédiatement","is_correct":false},
     {"id":"d","label":"Facturer la quantité manquante au conducteur","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','ch11','livret','refus','quantite'],
   'mft-2026-gotrm-livret:ch11:qcm:9', true,
   'Quantité incomplète : action immédiate = comptage contradictoire, puis livraison complémentaire et réserve sur CMR.'),

  -- ============== QCM 10 — difficile ==============
  (v_formation, v_module, 'qcm',
   'Selon le livret, quel est le comportement à ÉVITER en communication client en situation difficile ?',
   '[{"id":"a","label":"Informer rapidement, même sans solution définitive","is_correct":false},
     {"id":"b","label":"Rester factuel et précis","is_correct":false},
     {"id":"c","label":"Promettre une livraison irréaliste pour calmer le client","is_correct":true},
     {"id":"d","label":"Tracer tous les échanges dans le TMS","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch11','livret','communication'],
   'mft-2026-gotrm-livret:ch11:qcm:10', true,
   'Promettre l''impossible pour calmer le client est explicitement à éviter (§11.7) : il faut rassurer sans promettre l''irréaliste.'),

  -- ============== QCM 11 — difficile ==============
  (v_formation, v_module, 'qcm',
   'Dans le cas pratique du conducteur BRUN (retard 1h15), quel client doit être prévenu EN PRIORITÉ ?',
   '[{"id":"a","label":"Client A (Clichy, 09h00)","is_correct":true},
     {"id":"b","label":"Client B (Saint-Denis, 10h30)","is_correct":false},
     {"id":"c","label":"Client C (Pantin, 12h00)","is_correct":false},
     {"id":"d","label":"Client D (Vincennes, 14h00)","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch11','livret','cas-pratique','retard'],
   'mft-2026-gotrm-livret:ch11:qcm:11', true,
   'Le Client A est le premier livré et son retard est certain : il doit être prévenu en priorité (action 2 de la correction).'),

  -- ============== QCM 12 — difficile ==============
  (v_formation, v_module, 'qcm',
   'Quelle est la dernière étape de la méthode de traitement d''un aléa ?',
   '[{"id":"a","label":"Évaluer les conséquences","is_correct":false},
     {"id":"b","label":"Mettre en œuvre une solution","is_correct":false},
     {"id":"c","label":"Informer les interlocuteurs concernés","is_correct":false},
     {"id":"d","label":"Assurer la traçabilité (enregistrement TMS / dossier)","is_correct":true}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','ch11','livret','methode','tracabilite'],
   'mft-2026-gotrm-livret:ch11:qcm:12', true,
   'Étape 5 (dernière) : Assurer la traçabilité — enregistrement de l''événement et des décisions dans le TMS ou le dossier transport.'),

  -- ============== QR 1 ==============
  (v_formation, v_module, 'qr',
   'Citez les 5 étapes de la méthode de traitement d''un aléa d''exploitation.',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch11','livret','qr','methode'],
   'mft-2026-gotrm-livret:ch11:qr:1', true,
   '1) Identifier précisément le problème ; 2) Évaluer les conséquences ; 3) Déterminer et mettre en œuvre une solution ; 4) Informer tous les interlocuteurs concernés ; 5) Assurer la traçabilité (TMS / dossier transport).'),

  -- ============== QR 2 ==============
  (v_formation, v_module, 'qr',
   'Cas pratique BRUN — un retard de 1h15 frappe une tournée 4 clients (Clichy 9h00, Saint-Denis 10h30, Pantin 12h00, Vincennes 14h00). Listez au moins 5 actions prioritaires du gestionnaire.',
   NULL,
   5, 'difficile', ARRAY['gotrm','ch11','livret','qr','cas-pratique'],
   'mft-2026-gotrm-livret:ch11:qr:2', true,
   '1) Appeler le conducteur pour confirmer la situation et l''ETA révisé ; 2) Prévenir en priorité le Client A (premier livré, retard certain) ; 3) Prévenir le Client B avec ETA estimé ; 4) Évaluer si le Client C peut être livré dans les délais tolérés ; 5) Prévenir le Client D par précaution ; 6) Documenter chaque appel et décision dans le TMS ; 7) Proposer des solutions compensatoires si engagements contractuels non respectés.'),

  -- ============== QR 3 ==============
  (v_formation, v_module, 'qr',
   'Panne du groupe froid sur un véhicule frigorifique : citez au moins 4 actions du gestionnaire au titre du point de vigilance.',
   NULL,
   5, 'difficile', ARRAY['gotrm','ch11','livret','qr','frigo'],
   'mft-2026-gotrm-livret:ch11:qr:3', true,
   '1) Relevé immédiat et horodaté de la température dans la caisse ; 2) Si seuil critique dépassé (ex. −15 °C pour les surgelés) : transbordement OBLIGATOIRE sur un autre véhicule ATP disponible ; 3) Information immédiate du client ; 4) Enregistrement de toutes les températures relevées pour traçabilité ; 5) Déclaration à l''assurance marchandise selon le protocole de l''entreprise.'),

  -- ============== QR 4 ==============
  (v_formation, v_module, 'qr',
   'Citez 4 motifs de refus de livraison et, pour chacun, l''action immédiate à mener.',
   NULL,
   5, 'moyen', ARRAY['gotrm','ch11','livret','qr','refus'],
   'mft-2026-gotrm-livret:ch11:qr:4', true,
   '1) Avarie visible → photos + réserves précises sur le CMR ; 2) Erreur de référence → vérification CMR et BL ; 3) Quantité incomplète → comptage contradictoire ; 4) Emballage détérioré → photos + constat contradictoire.');

  -- 8. Quiz d'entraînement (12 QCM uniquement)
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (
    v_module,
    'Chapitre 11 — Quiz d''entraînement',
    'Quiz d''entraînement (12 questions) sur le suivi d''exploitation et la gestion des aléas.',
    'entrainement',
    NULL,
    70
  )
  RETURNING id INTO v_quiz;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm-livret:ch11:qcm:%';

  RAISE NOTICE '✓ Module Ch11 importé.';
END $ch11_v4$;
