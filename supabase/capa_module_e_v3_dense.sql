-- =====================================================================
-- MODULE E — SALARIÉS ET DROIT SOCIAL (Capacité ≤ 3,5 T)
-- Version 3 (mai 2026) — REFONTE PÉDAGOGIQUE DENSIFIÉE
--
-- Diagnostic v2 corrigé :
--   ✓ Bug bloc : v_bloc résolu via slug fiable
--   ✓ Quiz : chaque quiz d'entraînement contient 12 QCM
--   ✓ Leçons : structure pédagogique pro (intro / dev / cas / synthèse /
--     "Ce que l'examinateur peut demander" / glossaire / mémo)
--   ✓ Banque enrichie : 48 QCM (vs 28) + 6 QR
--   ✓ Examen blanc : 13 QCM + 5 QR (durée 60 min, seuil 50 %)
--
-- Référentiel décision du 2 avril 2012 :
--   Module droit social : QCM (~5) + QR (~2) ≈ 14-18 pts/84
-- ▸ 4 leçons :
--   1. Sources du droit social et conventions collectives transport
--   2. Le contrat de travail (CDI, CDD, période d'essai, rupture)
--   3. Durée du travail, rémunération et bulletin de paie
--   4. Représentation du personnel et conditions de travail
--
-- Idempotent. Pré-requis : formation 'capacite-3-5t'.
-- =====================================================================

DO $module_e_v3$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_lesson_1 uuid;
  v_lesson_2 uuid;
  v_lesson_3 uuid;
  v_lesson_4 uuid;
  v_quiz_1 uuid;
  v_quiz_2 uuid;
  v_quiz_3 uuid;
  v_quiz_4 uuid;
  v_quiz_5 uuid;
  v_quiz_6 uuid;
  v_quiz_eb uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'capacite-3-5t';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation capacite-3-5t introuvable.'; END IF;

  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1';
  IF v_bloc IS NULL THEN
    INSERT INTO public.blocs (code, title, description, "order")
    VALUES ('BC1', 'Bloc 1 — Compétences générales', 'Bloc générique partagé.', 1)
    ON CONFLICT (code) DO NOTHING RETURNING id INTO v_bloc;
    IF v_bloc IS NULL THEN SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1'; END IF;
  END IF;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Bloc BC1 introuvable.'; END IF;

  DELETE FROM public.modules WHERE slug = 'capa-salaries-droit-social';

  INSERT INTO public.modules (
    title, slug, bloc_id, summary, difficulty, duration_min, "order"
  ) VALUES (
    'Module E — Salariés et droit social',
    'capa-salaries-droit-social',
    v_bloc,
    'Maîtriser les sources du droit social, embaucher, gérer et licencier en sécurité juridique. Convention collective transport, durée du travail des conducteurs, rémunération et bulletin de paie, représentation du personnel et conditions de travail.',
    'intermediaire',
    210,
    50
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 50, true) ON CONFLICT DO NOTHING;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026:moduleE:%';

  -- =================================================================
  -- LEÇON 1 — Sources du droit social et convention collective transport
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Sources du droit social et convention collective transport',
    'sources-droit-social-convention',
    1, 50,
$lessonE1$
# Sources du droit social et convention collective transport

> 🎯 **Objectifs pédagogiques**
>
> - **Identifier** la hiérarchie des normes en droit du travail.
> - **Localiser** la convention collective applicable à votre entreprise.
> - **Comprendre** les apports de la CCN Transport routier.
> - **Distinguer** ordre public, négociation et accord d'entreprise.
> - **Réagir** à un conflit entre Code du travail et convention collective.

---

## Introduction

Le droit social est un **empilement de normes** : Code du travail, convention collective, accord d'entreprise, contrat de travail. À chaque niveau, des règles différentes peuvent s'appliquer. **Connaître la hiérarchie est vital** : un patron qui s'appuie sur le Code du travail seul, en oubliant qu'une convention collective transport prévoit mieux, prend un risque prud'homal majeur.

Pour le transport, la convention collective de référence (CCN) est celle des **Transports routiers et activités auxiliaires de transport** (IDCC 16). Elle s'impose à toute entreprise dont l'activité principale est le transport routier, quel que soit son statut juridique.

Cette leçon vous arme pour **5 à 8 points** d'examen sur la hiérarchie des normes et les spécificités sociales du transport.

---

## 1. La hiérarchie des sources

### 1.1 Vue d'ensemble : 6 niveaux

Du plus général au plus particulier :

| Niveau | Source | Exemple |
|---|---|---|
| 1 | **Constitution** | Droit de grève, droit syndical |
| 2 | **Lois et règlements** | Code du travail (lois L. 1111-1, etc., et R. 1111-1, etc.) |
| 3 | **Conventions et accords collectifs** | CCN Transport routier (IDCC 16) |
| 4 | **Accords d'entreprise** | Accord temps de travail signé en interne |
| 5 | **Usages et engagements unilatéraux** | Prime de fin d'année versée depuis 5 ans |
| 6 | **Contrat de travail** | Mention salaire, fonction, lieu de travail |

### 1.2 Le principe de faveur (et ses exceptions)

**Principe de base :** quand deux normes s'opposent, on applique **la plus favorable au salarié**.

**Exemple :** le Code du travail fixe la durée légale à 35 h. La CCN Transport prévoit 39 h hebdomadaires pour les conducteurs (avec heures structurelles). Comme le Code permet d'aller jusqu'à 48 h sous conditions, la CCN n'est pas moins favorable, elle est conforme.

**Exceptions depuis 2017 (Ord. Macron) :** dans certains domaines, l'accord d'entreprise peut être **moins favorable** que la convention collective de branche (ex. primes, déplacements). C'est le « bloc 3 » du Code du travail.

### 1.3 Tableau des « blocs » Macron

| Bloc | Domaines | Qui décide ? |
|---|---|---|
| **Bloc 1** | Salaires minima, classifications, prévoyance, mutuelle, formation | **Branche prime** (la branche écrase l'entreprise) |
| **Bloc 2** | Pénibilité, handicap, IRP | Branche peut verrouiller |
| **Bloc 3** | Tous les autres sujets (primes, congés, temps de travail) | **Entreprise prime** sur la branche |

**Conséquence pratique :** depuis 2017, un accord d'entreprise transport peut prévoir des primes différentes de la CCN si négociées avec un délégué.

---

## 2. La convention collective Transport routier (IDCC 16)

### 2.1 Champ d'application

S'applique à toute entreprise :
- dont le **code APE** commence par 49 (transport terrestre) ou activité auxiliaire de transport,
- dont l'**activité principale** est le transport routier,
- quel que soit le statut juridique (SARL, SAS, EI…).

**Qu'on adhère ou non au syndicat** : la CCN est étendue par arrêté ministériel, donc applicable obligatoirement à tous.

### 2.2 Les apports majeurs de la CCN Transport

#### Classification des emplois

Grille en groupes (1 à 8) selon la complexité :
- **Groupes 1-3** : ouvriers (manutentionnaires, conducteurs livreurs).
- **Groupes 4-6** : techniciens (conducteurs longue distance, exploitants).
- **Groupes 7-8** : cadres (responsable d'agence, directeur).

Chaque groupe a un **salaire minimum conventionnel** (SMC), qui doit toujours être ≥ SMIC.

#### Temps de travail des conducteurs marchandises

| Catégorie | Durée hebdo de référence | Maxi |
|---|---|---|
| Conducteurs courte distance (≤ 3,5 T) | **35 h** | 48 h sous conditions |
| Conducteurs longue distance | **43 h** (avec heures struc.) | 56 h |
| Personnel sédentaire | 35 h | 48 h |

**Heures structurelles** = heures supplémentaires forfaitaires intégrées au temps de travail conventionnel, payées avec une majoration de 25 % les 4 premières puis 50 %.

#### Indemnités spécifiques

- **Indemnités de repas** : 16 € à 21 € selon longueur du déplacement (2026).
- **Indemnités de découcher** : ~50 € par nuit hors domicile.
- **Prime de transport** : versée mensuellement (transport domicile-travail).

#### Garanties : maladie, prévoyance

- Maintien de salaire en cas de maladie au-delà de 1 an d'ancienneté.
- Régime de prévoyance obligatoire (incapacité, invalidité, décès).
- Mutuelle santé obligatoire (prise en charge à 50 % par l'employeur).

### 2.3 Annexes par catégorie

La CCN se décompose en annexes :
- **Annexe I** : Ouvriers
- **Annexe II** : Employés
- **Annexe III** : Techniciens et agents de maîtrise (TAM)
- **Annexe IV** : Ingénieurs et cadres

Chaque annexe précise classification, salaires, durée du préavis, primes spécifiques.

---

## 3. Le contrat de travail dans cette hiérarchie

Le contrat de travail vient en **dernier** dans la hiérarchie, mais ne peut **jamais être moins favorable** que :
1. La loi.
2. La convention collective.
3. L'accord d'entreprise (si applicable).

**Exemple concret :** vous écrivez « 32 h/semaine » dans un contrat alors que la CCN prévoit 35 h. Vous ne pouvez pas imposer 32 h sans contrepartie. Soit le salarié signe librement (temps partiel négocié), soit le contrat est requalifié à 35 h en cas de litige.

---

## 4. Cas pratique d'examen

**Énoncé :** un employeur veut payer ses conducteurs courte distance 11 €/heure brut. Le SMIC 2026 est de 11,88 €/h. La CCN groupe 3 prévoit un SMC à 12,30 €/h.

**Quel salaire horaire devra-t-il appliquer ? Pourquoi ?**

**Correction :**

Hiérarchie + principe de faveur :
- 11 €/h (contrat) < SMIC 11,88 €/h → contrat illégal (salaire minimum violé).
- 11,88 €/h (SMIC) < 12,30 €/h (CCN groupe 3) → la CCN écrase le SMIC.
- Salaire applicable : **12,30 €/h minimum**.

Conséquence : si le contrat est signé à 11 €/h, le salarié peut réclamer rétroactivement le différentiel (prescription 3 ans). Risque prud'homal direct + redressement URSSAF.

---

## 5. Mini-exercice à faire seul

Un salarié vous dit : « Mon contrat prévoit 25 jours de congés payés. Je veux exercer mon droit ! »

La CCN Transport prévoit 25 jours **+ 2 jours d'ancienneté après 5 ans dans la branche**. Votre salarié a 6 ans d'ancienneté. Combien de jours doit-il avoir ?

> 💡 Réponse à la fin du module.

---

## 6. Glossaire

- **CCN** : Convention Collective Nationale. Accord négocié au niveau de la branche (transport, chimie, BTP…).
- **IDCC** : Identifiant De la Convention Collective. La CCN Transport routier = IDCC 16.
- **SMC** : Salaire Minimum Conventionnel. Plancher de la branche, ≥ SMIC.
- **Branche** : ensemble des entreprises d'un même secteur économique.
- **Accord d'entreprise** : convention négociée entre l'employeur et les représentants du personnel d'une entreprise.
- **Bloc 1/2/3** : classification des sujets par hiérarchie des normes (Ord. 2017).
- **Heures structurelles** : heures supplémentaires forfaitaires intégrées au temps de travail conventionnel.

---

## 7. Synthèse opérationnelle

1. **Hiérarchie** : Constitution > Loi > CCN > Accord entreprise > Usage > Contrat.
2. **Principe de faveur** : on applique la norme la plus favorable au salarié.
3. **Depuis 2017** : sur certains sujets (« bloc 3 »), l'accord d'entreprise écrase la CCN.
4. **CCN Transport routier (IDCC 16)** s'applique à toutes les entreprises de transport.
5. **Classification** par groupes 1 à 8, chacun avec un SMC.
6. **Conducteurs ≤ 3,5 T** : 35 h hebdo de référence (longue distance : 43 h).
7. **Indemnités spécifiques** : repas, découcher, transport.
8. **Le contrat de travail** ne peut jamais être moins favorable que la CCN.

---

## 🎓 Ce que l'examinateur peut demander

- Hiérarchie des normes en droit du travail.
- Identifier la convention collective applicable au transport (IDCC 16).
- Conséquence d'un conflit entre contrat et convention collective.
- Spécificités CCN Transport (heures structurelles, indemnités, classifications).
- QR : « Pourquoi la CCN s'impose-t-elle même si l'employeur n'adhère pas ? »

---

## 📋 Mémo à imprimer

```
HIÉRARCHIE DES NORMES (du plus fort au plus faible)

  1. Constitution
  2. Lois et règlements (Code du travail)
  3. Conventions collectives (CCN Transport = IDCC 16)
  4. Accords d'entreprise
  5. Usages et engagements unilatéraux
  6. Contrat de travail

PRINCIPE DE FAVEUR
  En cas de conflit, la norme la plus favorable au salarié s'applique.
  Sauf "bloc 3" (Ord. 2017) : l'accord d'entreprise peut être moins
  favorable que la CCN sur primes, congés, temps de travail.

CCN TRANSPORT ROUTIER (IDCC 16)
  Champ : code APE 49xx, activité principale transport
  Classification : groupes 1 à 8 + SMC
  Conducteurs ≤ 3,5 T  : 35 h/semaine
  Conducteurs longue   : 43 h/semaine (heures structurelles)
  Indemnité repas      : 16-21 €
  Indemnité découcher  : ~50 €/nuit
  Prévoyance + mutuelle obligatoires
```
$lessonE1$,
'Maîtriser la hiérarchie des sources du droit du travail, identifier la convention collective applicable et comprendre les spécificités de la CCN Transport routier (IDCC 16) — fondement juridique de toute embauche.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Le contrat de travail
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Le contrat de travail : embauche, types, rupture',
    'contrat-travail-embauche-rupture',
    2, 55,
$lessonE2$
# Le contrat de travail : embauche, types, rupture

> 🎯 **Objectifs pédagogiques**
>
> - **Choisir** le bon type de contrat (CDI, CDD, intérim, alternance).
> - **Rédiger** ou contrôler les mentions obligatoires d'un contrat.
> - **Calibrer** la période d'essai et la durée du préavis.
> - **Identifier** les modes de rupture et leurs conséquences.
> - **Anticiper** les pièges juridiques (requalification, prud'homal).

---

## Introduction

L'embauche est un acte **fondateur** : un mauvais contrat peut coûter à l'entreprise plusieurs milliers d'euros (requalification CDD en CDI, rappel de salaires, indemnités prud'homales). À l'inverse, un bon contrat **protège l'employeur** dans la durée. Cette leçon couvre la naissance, la vie et la mort du contrat de travail.

À l'examen, le QCM porte souvent sur :
1. La distinction CDD / CDI / intérim.
2. La durée maximale d'un CDD.
3. Les modes de rupture et leurs indemnités.

---

## 1. Les principaux types de contrat

### 1.1 Le CDI : Contrat à Durée Indéterminée

**Norme légale** (art. L. 1221-2 C. trav.) : « Le contrat de travail à durée indéterminée est la forme normale et générale de la relation de travail ».

| Caractéristique | Valeur |
|---|---|
| Durée | Indéterminée |
| Forme | Écrit non obligatoire (mais fortement recommandé) |
| Période d'essai | Jusqu'à 2 mois (ouvrier), 3 mois (employé), 4 mois (cadre) |
| Rupture | Démission, licenciement, rupture conventionnelle |

**Sans écrit**, le CDI est présumé conclu — mais sans écrit, l'employeur ne peut pas se prévaloir d'une période d'essai.

### 1.2 Le CDD : Contrat à Durée Déterminée

Encadré strictement (art. L. 1242-1 et suivants).

**Cas légaux exclusifs :**
1. Remplacement d'un salarié absent.
2. Accroissement temporaire d'activité.
3. Emploi saisonnier.
4. CDD d'usage dans certains secteurs.

**Mentions obligatoires :**
- Cas de recours précis.
- Identité du salarié remplacé (le cas échéant).
- Date de début et terme (date ou événement).
- Poste, classification, salaire.
- Durée période d'essai.
- Convention collective.

⚠️ **Toute mention manquante = requalification en CDI**.

| Durée | Maxi |
|---|---|
| Renouvellement | 2 fois maximum |
| Durée totale | **18 mois** (incluant renouvellements) |
| Cas spécifiques | 24 mois (commande exceptionnelle export) ou 9 mois (attente embauche CDI) |

À la fin : **prime de précarité 10 %** du salaire brut total versé.

### 1.3 L'intérim : contrat de mission

Triangle :
- **Salarié** ↔ **Entreprise de Travail Temporaire (ETT)** : contrat de mission.
- **ETT** ↔ **Entreprise utilisatrice (EU)** : contrat de mise à disposition.

Mêmes cas de recours et durées que le CDD. Prime de précarité 10 % en fin de mission.

**Avantage** : flexibilité maximale. **Inconvénient** : coût (~80 € HT/h pour un conducteur, vs ~25 €/h en direct).

### 1.4 L'alternance

Deux dispositifs :
- **Apprentissage** : pour les 16-29 ans, contrat alternant école et entreprise. Salaire selon âge et année (entre 27 % et 100 % du SMIC).
- **Professionnalisation** : pour adultes en reconversion ou jeunes. Salaire selon qualification.

**Aides employeur substantielles** : exonérations charges + prime à l'embauche jusqu'à 6 000 € (selon dispositif et période).

### 1.5 Tableau récapitulatif

| Critère | CDI | CDD | Intérim | Alternance |
|---|---|---|---|---|
| Écrit obligatoire | Non | Oui | Oui | Oui |
| Durée max | ∞ | 18 mois | 18 mois | 6 à 36 mois |
| Période d'essai | 2-4 mois | 1 jour/sem (max 1 mois) | 1 j/sem (max 5 j) | 45 jours travaillés |
| Prime précarité | Non | Oui (10 %) | Oui (10 %) | Non |
| Aides employeur | Non | Non | Non | Oui (~6 000 €) |

---

## 2. Les mentions obligatoires du contrat

Un contrat de travail doit comporter au minimum :

1. **Identité des parties** (employeur, salarié).
2. **Date de prise d'effet**.
3. **Lieu de travail**.
4. **Fonction et qualification** (avec coefficient CCN).
5. **Salaire brut** (et primes éventuelles).
6. **Durée du travail**.
7. **Convention collective** applicable.
8. **Période d'essai** (durée, modalités de rupture).
9. **Nom et adresse de la caisse de retraite complémentaire**.
10. **Mentions spécifiques** (clause de non-concurrence, clause de mobilité, etc., si applicables).

**Pour un conducteur**, ajouter :
- Type de permis et autorisations (FCO/FIMO si transport rémunéré professionnel).
- Catégorie de véhicules conduits.
- Zone géographique d'intervention.

---

## 3. La période d'essai

### 3.1 Durées maxi (Code du travail, art. L. 1221-19)

| Catégorie | CDI | Renouvellement |
|---|---|---|
| Ouvriers, employés | 2 mois | + 2 mois (donc 4 max) |
| Techniciens, agents de maîtrise | 3 mois | + 3 mois (6 max) |
| Cadres | 4 mois | + 4 mois (8 max) |

**Renouvellement** = possible une seule fois, et seulement si la CCN ou un accord de branche le prévoit.

### 3.2 Rupture pendant la période d'essai

- **Salarié** : préavis 24 h ou 48 h selon ancienneté dans l'entreprise.
- **Employeur** : préavis croissant selon la durée déjà effectuée :
  - 24 h si présence < 8 jours.
  - 48 h entre 8 jours et 1 mois.
  - 2 semaines après 1 mois.
  - 1 mois après 3 mois.

**Pas de motivation requise**, mais attention au licenciement camouflé en fin d'essai (jurisprudence : si motif discriminatoire, requalification possible).

---

## 4. La rupture du contrat

### 4.1 Les modes de rupture

| Mode | Initiative | Indemnité légale | Allocations chômage |
|---|---|---|---|
| **Démission** | Salarié | Aucune (sauf prime CCN) | Non (sauf cas légitime) |
| **Licenciement personnel** | Employeur (faute) | Variable | Oui |
| **Licenciement économique** | Employeur | Légale + CSP | Oui |
| **Rupture conventionnelle** | Accord mutuel | ≥ indemnité légale | Oui |
| **Fin de CDD** | Naturelle | Prime précarité 10 % | Oui |
| **Retraite** | Salarié | Indemnité de départ | Oui (si âge ouvre droit) |

### 4.2 L'indemnité légale de licenciement

Pour CDI, hors faute grave / lourde :

> **1/4 mois de salaire / année d'ancienneté** pour les 10 premières années, puis **1/3 mois / année** au-delà.

**Exemple** : conducteur licencié après 12 ans d'ancienneté, salaire 2 400 € brut.
- 10 × 0,25 × 2 400 = **6 000 €**
- 2 × 0,33 × 2 400 = **1 600 €** (arrondi)
- **Total : 7 600 €**

La CCN Transport peut prévoir mieux (à vérifier).

### 4.3 La rupture conventionnelle

Accord écrit signé entre employeur et salarié. Procédure :
1. Entretien(s) préalable(s).
2. Signature de la convention de rupture (formulaire CERFA).
3. Délai de rétractation 15 jours calendaires.
4. Homologation par la DDETS (anciennement Direccte) sous 15 jours.
5. Date effective de la rupture.

**Indemnité minimum** = indemnité légale de licenciement.

**Avantage employeur** : sécurise la sortie (pas de prud'homal). **Avantage salarié** : ouvre droit chômage.

### 4.4 Le préavis

Durée selon ancienneté et statut, prévue par la CCN Transport :

| Statut | Préavis |
|---|---|
| Ouvrier (< 6 mois ancienneté) | 1 semaine |
| Ouvrier (6 mois à 2 ans) | 1 mois |
| Ouvrier (> 2 ans) | 2 mois |
| Employé | 1 à 2 mois selon ancienneté |
| Cadre | 3 mois |

Pendant le préavis : salaire normal, et possibilité de **dispense de préavis** (l'employeur paie le préavis sans exiger la présence).

---

## 5. Cas pratique d'examen

**Énoncé :** Une SARL de transport embauche un conducteur en CDD pour remplacer un salarié en arrêt maladie. Le conducteur travaille 4 mois, le salarié titulaire revient.

**Questions :**
1. Le motif est-il valide ?
2. Quelle indemnité doit lui verser l'employeur ?
3. Si le contrat est mal rédigé (pas de mention du salarié remplacé), quel risque ?

**Correction :**
1. **Oui**, remplacement de salarié absent = cas légal de CDD (art. L. 1242-2).
2. **Prime de précarité 10 %** sur la totalité du brut versé. Pour 4 mois × 2 200 € brut = 8 800 € → indemnité de **880 €**.
3. **Requalification en CDI**. Le salarié peut alors saisir le conseil de prud'hommes pour faire constater le CDI, percevoir un rappel de préavis (2 mois), une indemnité de licenciement, des dommages et intérêts. Coût total potentiel : 6 à 12 mois de salaire.

---

## 6. Mini-exercice à faire seul

Un employeur souhaite licencier un conducteur en CDI pour absences répétées injustifiées. Salaire : 2 600 € brut. Ancienneté : 4 ans.

**Calculez l'indemnité légale de licenciement.**

> 💡 Réponse à la fin du module.

---

## 7. Glossaire

- **CDI** : Contrat à Durée Indéterminée. Forme normale.
- **CDD** : Contrat à Durée Déterminée. 4 cas de recours seulement, max 18 mois.
- **Intérim** : mise à disposition triangulaire (ETT / EU / salarié).
- **Apprentissage** : contrat en alternance pour 16-29 ans.
- **Période d'essai** : durée pendant laquelle l'employeur ou le salarié peut rompre librement.
- **Préavis** : délai entre l'annonce de la rupture et la sortie effective.
- **Rupture conventionnelle** : sortie négociée avec homologation administrative.
- **Indemnité de précarité** : 10 % du brut total versé en CDD ou intérim.

---

## 8. Synthèse opérationnelle

1. **CDI = forme normale**. CDD = exception, encadré strictement.
2. **CDD : 4 cas de recours**, durée 18 mois max, prime 10 %.
3. **Mentions obligatoires** : identité, fonction, salaire, durée, CCN, période d'essai, retraite.
4. **Période d'essai** : 2/3/4 mois selon catégorie, renouvelable une fois si CCN.
5. **6 modes de rupture** : démission, licenciements, rupture conventionnelle, fin de CDD, retraite.
6. **Indemnité légale licenciement** : 1/4 mois / année (puis 1/3 au-delà de 10 ans).
7. **Rupture conventionnelle** : sécurise la sortie + ouvre chômage.
8. **Préavis** selon CCN, dispensable contre paiement.

---

## 🎓 Ce que l'examinateur peut demander

- Distinction CDI / CDD / intérim et durées max.
- Cas légaux de CDD.
- Calcul d'une indemnité légale de licenciement.
- Conséquence d'un CDD irrégulier (requalification en CDI).
- QR : « Comparez les avantages du CDI et du CDD pour l'employeur. »

---

## 📋 Mémo à imprimer

```
TYPES DE CONTRAT

  CDI       : indéterminée   - écrit non obligatoire - essai 2-4 mois
  CDD       : 18 mois max    - 4 cas légaux         - prime précarité 10 %
  Intérim   : 18 mois max    - triangulaire ETT/EU  - prime 10 %
  Apprent.  : 6-36 mois      - jeunes 16-29 ans     - aides ~6 000 €

PÉRIODE D'ESSAI MAXI (CDI)
  Ouvriers/Employés     : 2 mois (+ 2 max)
  TAM                   : 3 mois (+ 3 max)
  Cadres                : 4 mois (+ 4 max)

INDEMNITÉ LÉGALE LICENCIEMENT
  ¼ mois × année (jusqu'à 10 ans)
  + ⅓ mois × année (au-delà)

MODES DE RUPTURE
  Démission              : pas d'indem., pas de chômage
  Licenciement perso     : indem. légale, chômage
  Licenciement éco       : indem. + CSP, chômage
  Rupture convention.    : indem. ≥ légale, chômage
  Fin CDD                : prime 10 %, chômage
  Retraite               : indem. départ, chômage si âge

PRÉAVIS CCN TRANSPORT
  Ouvrier  : 1 sem (≤ 6 mois) / 1 mois (6-24 m) / 2 mois (> 2 ans)
  Cadre    : 3 mois
```
$lessonE2$,
'Choisir le bon type de contrat, rédiger des mentions obligatoires conformes, calibrer la période d''essai et maîtriser les 6 modes de rupture du contrat de travail — sécurité juridique de l''employeur.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Durée du travail, rémunération, bulletin de paie
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Durée du travail, rémunération et bulletin de paie',
    'duree-travail-remuneration-bulletin',
    3, 55,
$lessonE3$
# Durée du travail, rémunération et bulletin de paie

> 🎯 **Objectifs pédagogiques**
>
> - **Distinguer** temps de travail effectif et temps de présence.
> - **Calculer** des heures supplémentaires et une rémunération mensuelle.
> - **Maîtriser** les règles spécifiques aux conducteurs (amplitude, repos).
> - **Lire** un bulletin de paie ligne par ligne.
> - **Anticiper** les contrôles (URSSAF, Inspection du travail).

---

## Introduction

Le temps de travail des conducteurs est un **terrain miné juridiquement**. Le régime cumule deux corps de règles :
- **Code du travail** (durée, repos, congés).
- **Réglementation sociale européenne** (règlement CE 561/2006 sur les temps de conduite et repos).

Une heure supplémentaire mal payée peut être réclamée 3 ans en arrière. Un conducteur qui dépasse l'amplitude maximale = sanction administrative (3 750 € par infraction). Cette leçon outille pour 7-10 points d'examen.

---

## 1. La durée du travail

### 1.1 Durée légale et heures supplémentaires

- **Durée légale** : 35 h/semaine ou 1 607 h/an.
- **Heures supplémentaires** : déclenchées au-delà de 35 h.

| Heures sup | Majoration |
|---|---|
| 36e à 43e h | **+ 25 %** |
| 44e h et + | **+ 50 %** |

**Contingent annuel** : 220 h/an (par défaut). Au-delà : repos compensateur obligatoire.

### 1.2 Spécificités conducteurs

La durée hebdomadaire de référence est portée à **43 h** par la CCN Transport (avec heures structurelles incluses).

Pour les conducteurs longue distance :
- **Amplitude maximale** : 12 h (ou 13 h si pause récupérée).
- **Conduite continue maxi** : 4 h 30, suivie de 45 min de pause.
- **Conduite quotidienne** : 9 h (extension à 10 h, 2 fois par semaine).
- **Conduite hebdomadaire** : 56 h max.
- **Conduite bi-hebdomadaire** : 90 h sur 2 semaines.
- **Repos quotidien** : 11 h consécutives (réductible à 9 h, 3 fois/semaine).
- **Repos hebdomadaire** : 45 h consécutives (réductible à 24 h sous compensation).

⚠️ **Le contrôle** s'effectue par chronotachygraphe (obligatoire > 3,5 T) et par carte conducteur. **Pour les ≤ 3,5 T**, le contrôle de l'amplitude se fait par le contrat et les fiches horaires.

### 1.3 Le temps de travail effectif

Le temps de travail effectif (TTE) = temps pendant lequel le salarié est **à disposition de l'employeur** sans pouvoir vaquer librement à des occupations personnelles.

**Inclus dans le TTE** :
- Conduite proprement dite.
- Chargement / déchargement.
- Attente à un quai si conducteur ne peut quitter le véhicule.
- Formation professionnelle obligatoire.

**Exclus** :
- Pauses repas où le conducteur peut sortir.
- Trajet domicile-travail (en règle générale).
- Coupures de >1 h en gare routière.

### 1.4 Les congés

| Type | Durée | Conditions |
|---|---|---|
| Congés payés | 2,5 jours ouvrables / mois travaillé | 30 jours = 5 semaines |
| Ancienneté CCN | + 1 jour à 5 ans / + 2 jours à 10 ans / + 3 jours à 15 ans | Branche transport |
| Maladie | Selon couverture | Ne consomme pas les congés |
| Maternité | 16 semaines minimum | + 8 sem. paternité |

---

## 2. La rémunération

### 2.1 Le SMIC et le SMC

- **SMIC 2026** : 11,88 €/h brut (revalorisation indexée). Soit ~ 1 802 € brut mensuel pour 35 h.
- **SMC** : Salaire Minimum Conventionnel par groupe (CCN Transport). Toujours ≥ SMIC.

**Conducteur courte distance groupe 5** ≈ 12,40 €/h en 2026 → ~1 880 € brut/mois pour 35 h.

### 2.2 Le salaire brut total

Composantes typiques :
- **Salaire de base** : taux × heures.
- **Heures supplémentaires** : avec majoration.
- **Primes** : ancienneté, performance, panier repas.
- **Indemnités** : repas, découcher, transport, mais **non soumises aux cotisations** (dans la limite des seuils URSSAF).

### 2.3 Les charges sociales

Le brut se transforme en net après prélèvement de **22 à 25 % de cotisations salariales**.
L'employeur paie en plus **40 à 45 % de cotisations patronales**.

**Exemple :** 2 000 € brut → ~1 530 € net pour le salarié, et coût total entreprise ~2 850 €.

| Type | Salarié | Employeur |
|---|---|---|
| Sécurité sociale (santé, retraite, allocations) | ~22 % | ~30 % |
| Chômage | 0 % (exonéré depuis 2019) | ~4 % |
| Retraite complémentaire (Agirc-Arrco) | ~3 % | ~5 % |
| Prévoyance (CCN Transport) | ~0,5 % | ~1 % |
| Mutuelle (CCN Transport) | ~0,5 % | ~0,5 % |

### 2.4 Calcul des heures supplémentaires (cas pratique)

**Énoncé** : conducteur courte distance, 35 h base, taux horaire 12,40 €.
Sur une semaine, il a effectué **45 h**.

```
Heures normales (35 h)            : 35 × 12,40 €                  = 434,00 €
Heures sup 36e à 43e (8 h × 25 %) : 8 × 12,40 × 1,25 =             123,80 €  → 124,00 €
Heures sup 44e à 45e (2 h × 50 %) : 2 × 12,40 × 1,50 =              37,20 €
                                                                 ─────────
Salaire brut hebdomadaire                                          595,20 €
```

Sur le mois (4,33 sem) : ~ 2 580 € brut.

---

## 3. Le bulletin de paie

### 3.1 Mentions obligatoires (art. R. 3243-1 C. trav.)

- Identification employeur (raison sociale, SIRET, code NAF, adresse, organisme retraite).
- Identification salarié (nom, classification, coefficient, fonction).
- Période d'emploi.
- Nature et volume du forfait (le cas échéant).
- Heures normales, heures sup, taux horaire.
- Primes et indemnités.
- Charges salariales (détaillées).
- Salaire brut, salaire net imposable, **salaire net à payer**.
- Cumul annuel.
- Mention « à conserver sans limitation de durée ».

### 3.2 Lecture d'un bulletin (extrait)

```
Période : du 01/05/2026 au 31/05/2026

ÉLÉMENTS DE BRUT                          Base       Taux       Montant
─────────────────────────────────────────────────────────────────────────
Salaire de base                          151,67 h   12,40       1 880,71 €
Heures supplémentaires 25 %                8,00     15,50         124,00 €
Indemnité repas (non soumise)              22 j     16,00         352,00 €
                                                              ─────────
SALAIRE BRUT                                                    2 004,71 €
Indemnités non soumises                                           352,00 €
                                                              ─────────
TOTAL BRUT                                                      2 356,71 €

COTISATIONS SALARIALES                                            Montant
─────────────────────────────────────────────────────────────────────────
Sécu sociale (maladie, vieillesse, etc.)                          440,00 €
Retraite complémentaire                                            60,00 €
Mutuelle (50 % salarié)                                            10,00 €
                                                              ─────────
TOTAL COTISATIONS SALARIALES                                      510,00 €

NET À PAYER AVANT IMPÔT                                         1 846,71 €
Prélèvement à la source (~5 %)                                     92,00 €
NET À PAYER                                                     1 754,71 €
```

### 3.3 Les pièges classiques

1. **Oubli de la prime ancienneté CCN** (3 à 12 % du brut selon ancienneté).
2. **Mauvaise classification** : salarié au coefficient 110 alors que poste = coef 130.
3. **Heures structurelles non payées** pour les conducteurs longue distance.
4. **Non-respect du SMC** (CCN > SMIC).
5. **Indemnités repas non versées** ou versées au mauvais barème.

Chacune de ces erreurs peut donner lieu à un rappel sur 3 ans + intérêts.

---

## 4. Cas pratique d'examen

**Énoncé :** un conducteur courte distance fait 39 h/semaine, taux horaire 12,80 € brut. Il a 5 ans d'ancienneté. La CCN prévoit + 3 % de prime d'ancienneté. Calculez le salaire mensuel brut.

**Correction :**

| Élément | Calcul | Montant |
|---|---|---|
| Salaire base 35 h × 4,33 sem | 35 × 4,33 × 12,80 | 1 939,84 € |
| Heures sup 4 h × 4,33 sem × 25 % | 4 × 4,33 × 12,80 × 1,25 | 277,12 € |
| Sous-total | | 2 216,96 € |
| Prime ancienneté 3 % | 2 216,96 × 0,03 | 66,51 € |
| **SALAIRE BRUT MENSUEL** | | **2 283,47 €** |

---

## 5. Mini-exercice à faire seul

Sur une semaine, un conducteur a fait : 8 h lundi, 9 h mardi, 10 h mercredi, 9 h jeudi, 8 h vendredi, 4 h samedi. Soit 48 h.

**Calculez :**
- Le nombre d'heures normales.
- Le nombre d'heures sup à 25 %.
- Le nombre d'heures sup à 50 %.

> 💡 Réponse à la fin du module.

---

## 6. Glossaire

- **TTE** : Temps de Travail Effectif. Temps à disposition de l'employeur.
- **Heures supplémentaires** : heures au-delà de 35 h, majorées de 25 % ou 50 %.
- **Heures structurelles** : heures sup intégrées au forfait conventionnel des conducteurs longue distance.
- **SMC** : Salaire Minimum Conventionnel.
- **Brut** : avant prélèvement des cotisations salariales.
- **Net imposable** : sert de base au prélèvement à la source.
- **Net à payer** : ce qui est versé sur le compte du salarié.
- **Chronotachygraphe** : appareil obligatoire >3,5 T pour mesurer temps de conduite et de repos.

---

## 7. Synthèse opérationnelle

1. **Durée légale** : 35 h/semaine, 1 607 h/an.
2. **Conducteurs ≤ 3,5 T** : 35 h hebdomadaires (CCN). Longue distance : 43 h.
3. **Heures sup** : +25 % (36-43e), +50 % (44e+).
4. **Amplitude maxi** conducteur : 12 h (13 h pause récup.).
5. **Repos quotidien** : 11 h conséc. (réductible à 9 h, 3 fois/sem.).
6. **Repos hebdomadaire** : 45 h conséc. (réductible à 24 h).
7. **Bulletin de paie** : mentions obligatoires + 3 ans de prescription pour rappels.
8. **SMC > SMIC** : toujours appliquer le plus favorable.

---

## 🎓 Ce que l'examinateur peut demander

- Calcul d'heures supplémentaires et de salaire mensuel.
- Distinction temps de travail effectif vs temps de présence.
- Repos quotidien et hebdomadaire.
- Mentions obligatoires d'un bulletin de paie.
- Conséquence d'un non-paiement d'heures sup (rappel 3 ans + dommages-intérêts).
- QR : « Pourquoi distinguer temps de conduite et temps de travail effectif ? »

---

## 📋 Mémo à imprimer

```
DURÉE DU TRAVAIL CONDUCTEUR ≤ 3,5 T

  Hebdomadaire référence : 35 h
  Heures sup 25 %        : 36e à 43e h
  Heures sup 50 %        : 44e h et +
  Contingent annuel      : 220 h

CONDUITE / REPOS (règlement européen)

  Conduite continue maxi : 4 h 30 → 45 min pause
  Conduite quotidienne   : 9 h (10 h 2 fois/sem)
  Conduite hebdo         : 56 h max
  Repos quotidien        : 11 h conséc. (9 h × 3/sem max)
  Repos hebdo            : 45 h (24 h conséc. min, sous compens.)
  Amplitude maxi         : 12 h (13 h si pause récupérée)

CONGÉS
  CP base                : 2,5 j ouvrables × mois (30 j/an = 5 sem)
  Ancienneté CCN         : +1 (5 ans) / +2 (10 ans) / +3 (15 ans)

CHARGES SOCIALES
  Brut → Net salarié     : −22 à −25 %
  Coût total employeur   : Brut × 1,40 à 1,45

BULLETIN DE PAIE — mentions obligatoires
  Employeur (SIRET, NAF, adresse, retraite)
  Salarié (classification, coef., fonction)
  Heures normales + sup détaillées
  Cotisations salariales (par poste)
  BRUT → NET imposable → NET à payer
  Cumul annuel
```
$lessonE3$,
'Maîtriser le calcul du temps de travail et des heures supplémentaires des conducteurs, lire un bulletin de paie et anticiper les rappels prud''homaux — un mauvais calcul = 3 ans de rétroactif.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Représentation du personnel et conditions de travail
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Représentation du personnel et conditions de travail',
    'irp-conditions-travail',
    4, 50,
$lessonE4$
# Représentation du personnel et conditions de travail

> 🎯 **Objectifs pédagogiques**
>
> - **Identifier** les seuils de représentation (CSE, délégués syndicaux).
> - **Connaître** les obligations en matière de santé / sécurité.
> - **Réagir** à un accident du travail ou maladie professionnelle.
> - **Mettre en place** un document unique d'évaluation des risques (DUER).
> - **Prévenir** harcèlement moral et sexuel.

---

## Introduction

Au-delà de l'embauche et de la paie, l'employeur a une **obligation de sécurité de résultat** vis-à-vis de ses salariés (Cour de cassation 2002). Tout manquement (accident, maladie professionnelle, harcèlement) peut engager sa responsabilité civile et pénale. Cette leçon vise à connaître les obligations institutionnelles (CSE, médecine du travail) et à anticiper les risques (DUER, EPI, accidents).

---

## 1. La représentation du personnel

### 1.1 Le CSE : Comité Social et Économique

Depuis 2018, l'instance unique de représentation = **CSE**. Il fusionne les anciens DP, CE et CHSCT.

**Seuils d'obligation :**

| Effectif | Obligation |
|---|---|
| < 11 salariés | Aucune représentation obligatoire |
| 11 à 49 | CSE simple (élu, missions limitées) |
| ≥ 50 | CSE étendu (avec budget, commissions, formation) |

**Effectif** = ETP sur 12 mois consécutifs ou non sur les 3 dernières années.

### 1.2 Élections du CSE

- Premier tour : organisations syndicales représentatives uniquement.
- Second tour (si quorum non atteint) : tous candidats.
- Durée du mandat : 4 ans.

L'employeur prend en charge l'organisation et finance le fonctionnement.

### 1.3 Le délégué syndical

À partir de **50 salariés**, les organisations syndicales représentatives peuvent désigner un délégué syndical (DS) chargé de négocier les accords d'entreprise.

### 1.4 Heures de délégation

| Effectif | Heures CSE / mois |
|---|---|
| 11-49 | 10 h |
| 50-74 | 18 h |
| 75-99 | 19 h |
| 100-199 | 21 h |
| 200-499 | 22 h |
| ≥ 500 | 24 h |

Les heures de délégation sont **payées comme du temps de travail effectif**.

---

## 2. La santé et sécurité au travail

### 2.1 L'obligation de sécurité de résultat

Articles L. 4121-1 et suivants C. trav. : l'employeur doit prendre les mesures nécessaires pour assurer la **sécurité physique et mentale** des salariés. Ce n'est pas une obligation de moyen mais de **résultat**.

**Principes généraux de prévention** (9 principes) :
1. Éviter les risques.
2. Évaluer ceux qui ne peuvent l'être.
3. Combattre à la source.
4. Adapter le travail à l'homme.
5. Tenir compte de l'évolution technique.
6. Remplacer ce qui est dangereux par ce qui l'est moins.
7. Planifier la prévention.
8. Préférer protection collective à individuelle.
9. Informer et former les salariés.

### 2.2 Le DUER : Document Unique d'Évaluation des Risques

**Obligatoire dès le premier salarié**.

Contenu :
- Inventaire des risques par unité de travail.
- Évaluation (gravité × fréquence).
- Plan d'actions (mesures prises, responsable, échéance).
- Mise à jour **annuelle minimum**.

**Sanctions** : 1 500 € amende contravention (3 750 € en récidive). Et surtout : si accident, l'absence de DUER aggrave la responsabilité pénale.

### 2.3 Risques spécifiques au transport

| Risque | Prévention |
|---|---|
| Accident de la route | Formation conduite, écoconduite, état véhicule |
| Manutention manuelle (port de charges) | Limites légales (35 kg homme, 25 kg femme), aides mécaniques |
| Chutes (montée/descente cabine) | Entretien marchepieds, signalisation, EPI antidérapants |
| Stress, fatigue, dépression | Respect repos, rotation, suivi médical |
| Agression (zones sensibles) | Procédures, alertes, formation |
| Exposition produits dangereux (ADR) | Formation ADR spécifique, EPI |
| TMS (troubles musculo-squelettiques) | Sièges réglables, alternance tâches |

### 2.4 Les EPI : Équipements de Protection Individuelle

- **Chaussures de sécurité** : obligatoires en zone de manutention.
- **Gilet haute visibilité** : obligatoire à bord, port en cas d'arrêt sur autoroute.
- **Gants** : obligatoires pour manutention.
- **Casque** : si chargement avec engin ou en site BTP.

L'employeur les fournit gratuitement et les renouvelle. Le salarié est tenu de les porter.

### 2.5 La médecine du travail

Visites obligatoires :
- **Visite d'information et de prévention (VIP)** : à l'embauche, puis tous les 5 ans (3 ans pour conducteurs ≤ 3,5 T en transport rémunéré).
- **Suivi médical renforcé** pour postes à risques.
- **Visite de reprise** après 60 jours d'absence ou 30 jours pour AT/MP.

---

## 3. Les accidents du travail et maladies professionnelles (AT/MP)

### 3.1 Définition

- **Accident du travail (AT)** : accident survenu par le fait ou à l'occasion du travail. Présomption d'imputabilité si survenu sur le lieu et au temps de travail.
- **Maladie professionnelle (MP)** : maladie causée par l'activité, listée aux tableaux de la Sécurité sociale (ex. tableau 57 : TMS, tableau 42 : surdité).

### 3.2 Procédure

1. **Soins immédiats** + arrêt de travail si nécessaire.
2. **Déclaration de l'employeur** dans les 48 h à la CPAM (CERFA).
3. **Réserves possibles** par l'employeur (s'il conteste).
4. **Indemnisation salarié** : 100 % du salaire (Sécu + complément employeur sous CCN).
5. **Visite de reprise** obligatoire si arrêt > 30 jours.

### 3.3 Conséquences pour l'employeur

- **Cotisation AT/MP** : taux variable selon historique de l'entreprise (de 1 % à 5 % du brut).
- **Faute inexcusable** : si l'employeur avait conscience du danger sans agir, il indemnise intégralement (sans plafond).
- **Risque pénal** : homicide involontaire ou blessures involontaires (jusqu'à 5 ans prison + 75 000 € pour homicide).

---

## 4. Le harcèlement moral et sexuel

### 4.1 Définitions

- **Harcèlement moral** (art. L. 1152-1 C. trav.) : agissements répétés ayant pour effet une dégradation des conditions de travail, de la dignité, de la santé, de l'avenir professionnel.
- **Harcèlement sexuel** (art. L. 1153-1) : propos ou comportements à connotation sexuelle non désirés répétés OU une seule fois si pression grave dans le but réel ou apparent d'obtenir un acte de nature sexuelle.

### 4.2 Obligations employeur

- **Affichage obligatoire** des dispositions du Code pénal sur le harcèlement.
- **Désignation d'un référent harcèlement sexuel** dans le CSE (à partir 11 salariés).
- **Procédure interne** d'alerte et d'enquête.
- **Sanctions internes** rapides en cas de constat.

### 4.3 Sanctions

- **Pénales** : 2 ans prison + 30 000 € (harcèlement moral). 3 ans + 45 000 € (harcèlement sexuel).
- **Civiles** : indemnisation préjudice + dommages-intérêts.
- **Pour l'employeur** : co-responsabilité s'il n'a pas pris les mesures préventives.

---

## 5. Cas pratique d'examen

**Énoncé :** un conducteur de votre entreprise glisse en descendant de cabine et se blesse au genou (3 mois d'arrêt). Vous n'avez pas de DUER à jour, et il manque des chaussures de sécurité au stock fournisseur depuis 1 mois.

**Questions :**
1. Quelle qualification juridique de l'accident ?
2. Quelles obligations immédiates ?
3. Quels risques pour l'entreprise ?

**Correction :**

1. **Accident du travail** (présomption d'imputabilité, sur le lieu et au temps de travail).
2. **Déclaration CPAM dans les 48 h** + arrêt + visite de reprise après retour.
3. Risques :
   - **Cotisation AT/MP majorée** sur les 2 prochaines années.
   - **Faute inexcusable possible** si la victime démontre que l'employeur connaissait le risque (DUER absent + EPI manquants = preuves accablantes).
   - **Risque pénal** : blessures involontaires (jusqu'à 3 ans prison + 45 000 €).
   - **Indemnisation intégrale** du salarié sans plafond.

**Mesures correctives** : mettre à jour le DUER immédiatement, fournir les EPI, former l'équipe à la descente sécurisée de cabine.

---

## 6. Mini-exercice à faire seul

Une entreprise atteint 50 salariés au 1er janvier 2026 (consécutivement sur 12 mois).

**Quelles obligations apparaissent à ce seuil ?**

> 💡 Réponse à la fin du module.

---

## 7. Glossaire

- **CSE** : Comité Social et Économique. Instance unique de représentation des salariés.
- **DS** : Délégué Syndical. Désigné par un syndicat représentatif, négocie les accords (≥ 50 salariés).
- **DUER** : Document Unique d'Évaluation des Risques. Obligatoire dès 1 salarié.
- **AT** : Accident du Travail.
- **MP** : Maladie Professionnelle.
- **EPI** : Équipement de Protection Individuelle.
- **VIP** : Visite d'Information et de Prévention (médecine du travail).
- **TMS** : Troubles Musculo-Squelettiques.

---

## 8. Synthèse opérationnelle

1. **CSE** obligatoire ≥ 11 salariés. CSE étendu ≥ 50.
2. **Délégué syndical** ≥ 50 salariés.
3. **Obligation de sécurité de résultat** dès le 1er salarié.
4. **DUER** obligatoire dès le 1er salarié, mise à jour annuelle.
5. **EPI fournis gratuitement** par l'employeur.
6. **Visite médicale d'embauche** + tous les 3-5 ans.
7. **AT** : déclaration sous 48 h, indemnisation 100 %.
8. **Harcèlement** : référent CSE + procédure interne obligatoires.

---

## 4. Corrections des mini-exercices du module

### Leçon 1 (jours de congés)
- Base légale : 25 jours
- + 2 jours d'ancienneté CCN à 5 ans (le seuil est dépassé : 6 ans)
- **Total : 27 jours**

### Leçon 2 (indemnité de licenciement)
- Salaire 2 600 € × 0,25 × 4 ans = **2 600 €**.

### Leçon 3 (heures sup)
- 35 h normales
- 13 heures supplémentaires (48 − 35)
- 36e à 43e h = 8 h à +25 %
- 44e à 48e h = 5 h à +50 %

### Leçon 4 (50 salariés)
- CSE étendu (commissions obligatoires).
- Délégué syndical possible.
- Plan d'épargne entreprise possible.
- Règlement intérieur obligatoire.
- BDESE (base de données économiques, sociales et environnementales).
- Référent harcèlement sexuel obligatoire.

---

## 🎓 Ce que l'examinateur peut demander

- Seuils d'effectif et obligations correspondantes.
- Définition du DUER et conséquence de son absence.
- Procédure en cas d'accident du travail.
- Distinction harcèlement moral / sexuel.
- QR : « Quelles sont les obligations de l'employeur en matière de sécurité ? »

---

## 📋 Mémo à imprimer

```
SEUILS D'EFFECTIF
  ≥ 11   : CSE simple
  ≥ 20   : règlement intérieur conseillé
  ≥ 50   : CSE étendu, DS, BDESE, RI obligatoire,
           référent harcèlement sexuel

OBLIGATIONS DÈS LE 1er SALARIÉ
  DUER (mis à jour 1/an)
  Affichage légal (CCN, horaires, sécurité)
  Médecine du travail (adhésion + VIP embauche)
  EPI fournis gratuitement
  Sécurité de résultat (9 principes)

ACCIDENT DU TRAVAIL — procédure
  1. Soins immédiats + arrêt
  2. Déclaration CPAM sous 48 h (CERFA)
  3. Indemnisation 100 % du salaire
  4. Visite reprise si arrêt > 30 j

HARCÈLEMENT
  Affichage obligatoire (Code pénal)
  Référent CSE (≥ 11 salariés)
  Procédure interne d'alerte
  Sanctions pénales : 2 ans + 30 k€ (moral)
                    : 3 ans + 45 k€ (sexuel)
```
$lessonE4$,
'Maîtriser les seuils d''effectif (CSE 11+, DS 50+), tenir un DUER, prévenir les accidents du travail et le harcèlement — l''obligation de sécurité de résultat engage la responsabilité civile et pénale de l''employeur.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- BANQUE DE QUESTIONS — 48 QCM + 6 QR (schéma question_bank correct)
  -- =================================================================

  -- ===== LEÇON 1 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'Dans la hiérarchie des sources du droit du travail, la convention collective :',
   '[{"id":"a","label":"Est au-dessus du Code du travail","is_correct":false},{"id":"b","label":"Est au-dessus du contrat de travail mais sous le Code du travail","is_correct":true},{"id":"c","label":"Prime sur la Constitution","is_correct":false},{"id":"d","label":"N''a aucune valeur juridique","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-e','capa-3-5t','lecon-1','hierarchie'], 'mft-2026:moduleE:l1:q1', true,
   'Hiérarchie : Constitution > Lois > CCN > Accords entreprise > Usages > Contrat.'),
  (v_formation, v_module, 'qcm', 'L''IDCC de la convention collective Transport routier est :',
   '[{"id":"a","label":"IDCC 1","is_correct":false},{"id":"b","label":"IDCC 16","is_correct":true},{"id":"c","label":"IDCC 100","is_correct":false},{"id":"d","label":"IDCC 999","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-e','capa-3-5t','lecon-1','ccn'], 'mft-2026:moduleE:l1:q2', true,
   'IDCC 16 = CCN Transports routiers et activités auxiliaires de transport.'),
  (v_formation, v_module, 'qcm', 'Le principe de faveur signifie :',
   '[{"id":"a","label":"Le contrat prime toujours","is_correct":false},{"id":"b","label":"La règle la plus favorable au salarié s''applique","is_correct":true},{"id":"c","label":"La règle la plus favorable à l''employeur s''applique","is_correct":false},{"id":"d","label":"Le Code du travail prime toujours","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-e','capa-3-5t','lecon-1','faveur'], 'mft-2026:moduleE:l1:q3', true,
   'En cas de conflit entre normes, on applique la plus favorable au salarié — sauf exceptions « bloc 3 » depuis 2017.'),
  (v_formation, v_module, 'qcm', 'La CCN Transport routier s''applique :',
   '[{"id":"a","label":"Uniquement aux entreprises adhérentes à un syndicat patronal","is_correct":false},{"id":"b","label":"À toutes les entreprises dont l''activité principale est le transport routier","is_correct":true},{"id":"c","label":"Uniquement aux entreprises de plus de 50 salariés","is_correct":false},{"id":"d","label":"Sur option de l''employeur","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-1','ccn'], 'mft-2026:moduleE:l1:q4', true,
   'CCN étendue par arrêté ministériel = applicable à toutes les entreprises de la branche.'),
  (v_formation, v_module, 'qcm', 'Durée hebdomadaire de référence pour un conducteur courte distance ≤ 3,5 T :',
   '[{"id":"a","label":"32 h","is_correct":false},{"id":"b","label":"35 h","is_correct":true},{"id":"c","label":"43 h","is_correct":false},{"id":"d","label":"48 h","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-1','duree'], 'mft-2026:moduleE:l1:q5', true,
   'Conducteur courte distance ≤ 3,5 T : 35 h. Longue distance : 43 h (heures structurelles).'),
  (v_formation, v_module, 'qcm', 'Le Salaire Minimum Conventionnel (SMC) est :',
   '[{"id":"a","label":"Égal au SMIC","is_correct":false},{"id":"b","label":"Toujours supérieur ou égal au SMIC","is_correct":true},{"id":"c","label":"Toujours inférieur au SMIC","is_correct":false},{"id":"d","label":"Indépendant du SMIC","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-1','smc'], 'mft-2026:moduleE:l1:q6', true,
   'Le SMC ne peut pas être inférieur au SMIC.'),
  (v_formation, v_module, 'qcm', 'Les heures structurelles (CCN Transport longue distance) :',
   '[{"id":"a","label":"Sont des heures normales sans majoration","is_correct":false},{"id":"b","label":"Sont des heures supplémentaires forfaitaires intégrées au temps conventionnel","is_correct":true},{"id":"c","label":"Sont des heures interdites","is_correct":false},{"id":"d","label":"N''existent pas","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-e','capa-3-5t','lecon-1','heures'], 'mft-2026:moduleE:l1:q7', true,
   'Pour les conducteurs longue distance, la CCN intègre des heures sup forfaitaires payées à 25 % puis 50 %.'),
  (v_formation, v_module, 'qcm', 'La CCN Transport prévoit pour le repas en déplacement une indemnité d''environ :',
   '[{"id":"a","label":"1 €","is_correct":false},{"id":"b","label":"16 à 21 €","is_correct":true},{"id":"c","label":"100 €","is_correct":false},{"id":"d","label":"Aucune","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-1','indemnites'], 'mft-2026:moduleE:l1:q8', true,
   'Indemnité repas CCN Transport : 16 à 21 € selon longueur du déplacement (2026).'),
  (v_formation, v_module, 'qcm', 'Depuis l''ordonnance Macron 2017, sur le « bloc 3 » :',
   '[{"id":"a","label":"L''accord d''entreprise prime sur la CCN","is_correct":true},{"id":"b","label":"La CCN prime toujours","is_correct":false},{"id":"c","label":"Le contrat prime sur la CCN","is_correct":false},{"id":"d","label":"Aucun changement","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-e','capa-3-5t','lecon-1','bloc'], 'mft-2026:moduleE:l1:q9', true,
   'Bloc 3 (primes, congés non légaux, temps de travail) : accord d''entreprise peut être moins favorable que la CCN.'),
  (v_formation, v_module, 'qcm', 'Les annexes de la CCN Transport :',
   '[{"id":"a","label":"N''existent pas","is_correct":false},{"id":"b","label":"Distinguent ouvriers, employés, TAM, cadres","is_correct":true},{"id":"c","label":"Concernent uniquement les apprentis","is_correct":false},{"id":"d","label":"Sont facultatives","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-1','ccn'], 'mft-2026:moduleE:l1:q10', true,
   'Annexes I-IV : ouvriers / employés / TAM / cadres. Chacune avec classifications et préavis spécifiques.'),
  (v_formation, v_module, 'qcm', 'Le contrat de travail peut prévoir :',
   '[{"id":"a","label":"Moins favorable que la CCN","is_correct":false},{"id":"b","label":"Plus favorable que la CCN","is_correct":false},{"id":"c","label":"La même chose ou plus favorable que la CCN","is_correct":true},{"id":"d","label":"Inférieur au SMIC","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-1','contrat'], 'mft-2026:moduleE:l1:q11', true,
   'Le contrat ne peut jamais être moins favorable que la CCN.'),
  (v_formation, v_module, 'qcm', 'En cas de conflit Code du travail vs CCN, sur un sujet de bloc 1 (salaires minima) :',
   '[{"id":"a","label":"Le Code du travail prime","is_correct":false},{"id":"b","label":"La CCN prime","is_correct":true},{"id":"c","label":"Le contrat prime","is_correct":false},{"id":"d","label":"Aucun","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-e','capa-3-5t','lecon-1','bloc'], 'mft-2026:moduleE:l1:q12', true,
   'Bloc 1 : la branche prime, l''accord d''entreprise ne peut pas y déroger.');

  -- ===== LEÇON 2 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'Le contrat à durée indéterminée (CDI) :',
   '[{"id":"a","label":"Doit toujours être écrit","is_correct":false},{"id":"b","label":"Est la forme normale du contrat de travail","is_correct":true},{"id":"c","label":"Ne peut être rompu","is_correct":false},{"id":"d","label":"N''existe plus depuis 2017","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-e','capa-3-5t','lecon-2','cdi'], 'mft-2026:moduleE:l2:q1', true,
   'Art. L. 1221-2 C. trav. : « Le CDI est la forme normale et générale de la relation de travail. »'),
  (v_formation, v_module, 'qcm', 'La durée maximale d''un CDD (renouvellements compris) est généralement de :',
   '[{"id":"a","label":"6 mois","is_correct":false},{"id":"b","label":"12 mois","is_correct":false},{"id":"c","label":"18 mois","is_correct":true},{"id":"d","label":"24 mois","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-2','cdd'], 'mft-2026:moduleE:l2:q2', true,
   '18 mois maximum, hors cas spécifiques (24 mois export, 9 mois en attente CDI).'),
  (v_formation, v_module, 'qcm', 'La prime de précarité versée en fin de CDD est de :',
   '[{"id":"a","label":"5 %","is_correct":false},{"id":"b","label":"10 % du brut total","is_correct":true},{"id":"c","label":"15 %","is_correct":false},{"id":"d","label":"20 %","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-e','capa-3-5t','lecon-2','precarite'], 'mft-2026:moduleE:l2:q3', true,
   'Indemnité de précarité = 10 % du brut total versé pendant le CDD.'),
  (v_formation, v_module, 'qcm', 'Combien de cas légaux permettent de recourir au CDD ?',
   '[{"id":"a","label":"1","is_correct":false},{"id":"b","label":"4","is_correct":true},{"id":"c","label":"7","is_correct":false},{"id":"d","label":"Illimité","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-2','cdd'], 'mft-2026:moduleE:l2:q4', true,
   '4 cas : remplacement, accroissement temporaire, saisonnier, CDD d''usage.'),
  (v_formation, v_module, 'qcm', 'La période d''essai maximale d''un CDI pour un ouvrier est de :',
   '[{"id":"a","label":"1 mois","is_correct":false},{"id":"b","label":"2 mois (renouvelable 1 fois si CCN)","is_correct":true},{"id":"c","label":"6 mois","is_correct":false},{"id":"d","label":"Aucune","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-2','essai'], 'mft-2026:moduleE:l2:q5', true,
   '2 mois ouvriers/employés, renouvelable 2 mois si CCN ou accord de branche.'),
  (v_formation, v_module, 'qcm', 'L''indemnité légale de licenciement est de :',
   '[{"id":"a","label":"1/4 mois par année (jusqu''à 10 ans), puis 1/3 au-delà","is_correct":true},{"id":"b","label":"1 mois par année","is_correct":false},{"id":"c","label":"2 mois fixes","is_correct":false},{"id":"d","label":"Aucune","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-e','capa-3-5t','lecon-2','licenciement'], 'mft-2026:moduleE:l2:q6', true,
   '1/4 mois × année pour les 10 premières, puis 1/3 mois × année au-delà.'),
  (v_formation, v_module, 'qcm', 'La rupture conventionnelle :',
   '[{"id":"a","label":"N''ouvre pas droit aux allocations chômage","is_correct":false},{"id":"b","label":"Ouvre droit aux allocations chômage","is_correct":true},{"id":"c","label":"Est interdite en CDD","is_correct":false},{"id":"d","label":"Ne nécessite pas d''écrit","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-2','rupture'], 'mft-2026:moduleE:l2:q7', true,
   'Sortie négociée avec homologation administrative. Ouvre droit chômage et garantit indemnité ≥ légale.'),
  (v_formation, v_module, 'qcm', 'Si un CDD est mal rédigé (mention manquante du salarié remplacé) :',
   '[{"id":"a","label":"Pas de conséquence","is_correct":false},{"id":"b","label":"Le contrat est requalifié en CDI","is_correct":true},{"id":"c","label":"L''employeur paie 1 €","is_correct":false},{"id":"d","label":"Le contrat est nul","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-2','cdd'], 'mft-2026:moduleE:l2:q8', true,
   'Toute mention obligatoire manquante = requalification en CDI + dommages-intérêts.'),
  (v_formation, v_module, 'qcm', 'Indemnité légale de licenciement : 6 ans ancienneté, salaire 2 400 €.',
   '[{"id":"a","label":"1 200 €","is_correct":false},{"id":"b","label":"2 400 €","is_correct":false},{"id":"c","label":"3 600 €","is_correct":true},{"id":"d","label":"6 000 €","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-e','capa-3-5t','lecon-2','calcul'], 'mft-2026:moduleE:l2:q9', true,
   '6 × 1/4 × 2 400 = 6 × 600 = 3 600 €.'),
  (v_formation, v_module, 'qcm', 'L''intérim est un contrat :',
   '[{"id":"a","label":"Direct entre salarié et entreprise utilisatrice","is_correct":false},{"id":"b","label":"Triangulaire ETT / EU / salarié","is_correct":true},{"id":"c","label":"Sans prime de précarité","is_correct":false},{"id":"d","label":"Forcément CDI","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-2','interim'], 'mft-2026:moduleE:l2:q10', true,
   'Triangulaire : contrat de mission salarié-ETT + mise à disposition ETT-Entreprise utilisatrice.'),
  (v_formation, v_module, 'qcm', 'Le préavis CCN Transport pour un ouvrier de 3 ans d''ancienneté est de :',
   '[{"id":"a","label":"1 semaine","is_correct":false},{"id":"b","label":"1 mois","is_correct":false},{"id":"c","label":"2 mois","is_correct":true},{"id":"d","label":"3 mois","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-2','preavis'], 'mft-2026:moduleE:l2:q11', true,
   'CCN Transport : ouvrier > 2 ans = 2 mois.'),
  (v_formation, v_module, 'qcm', 'Pendant la période d''essai, l''employeur peut rompre :',
   '[{"id":"a","label":"Sans aucun délai","is_correct":false},{"id":"b","label":"Avec un préavis croissant selon la durée déjà effectuée","is_correct":true},{"id":"c","label":"Uniquement pour faute grave","is_correct":false},{"id":"d","label":"Jamais","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-e','capa-3-5t','lecon-2','essai'], 'mft-2026:moduleE:l2:q12', true,
   'Préavis employeur : 24 h (<8 j), 48 h (8 j-1 mois), 2 sem. (1-3 mois), 1 mois (>3 mois).');

  -- ===== LEÇON 3 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'La durée légale du travail en France est de :',
   '[{"id":"a","label":"32 h/semaine","is_correct":false},{"id":"b","label":"35 h/semaine","is_correct":true},{"id":"c","label":"39 h/semaine","is_correct":false},{"id":"d","label":"48 h/semaine","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-e','capa-3-5t','lecon-3','duree'], 'mft-2026:moduleE:l3:q1', true,
   'Art. L. 3121-27 C. trav. : durée légale = 35 h hebdomadaires ou 1 607 h/an.'),
  (v_formation, v_module, 'qcm', 'La majoration des 8 premières heures supplémentaires est de :',
   '[{"id":"a","label":"10 %","is_correct":false},{"id":"b","label":"25 %","is_correct":true},{"id":"c","label":"50 %","is_correct":false},{"id":"d","label":"100 %","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-e','capa-3-5t','lecon-3','heures-sup'], 'mft-2026:moduleE:l3:q2', true,
   'Heures sup 36e à 43e h : +25 %. 44e h et au-delà : +50 %.'),
  (v_formation, v_module, 'qcm', 'Le contingent annuel d''heures supplémentaires (par défaut) est de :',
   '[{"id":"a","label":"50 h","is_correct":false},{"id":"b","label":"100 h","is_correct":false},{"id":"c","label":"220 h","is_correct":true},{"id":"d","label":"400 h","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-3','contingent'], 'mft-2026:moduleE:l3:q3', true,
   'Contingent légal = 220 h/an. Au-delà : repos compensateur obligatoire.'),
  (v_formation, v_module, 'qcm', 'L''amplitude maximale quotidienne d''un conducteur est de :',
   '[{"id":"a","label":"8 h","is_correct":false},{"id":"b","label":"12 h (13 h si pause récupérée)","is_correct":true},{"id":"c","label":"24 h","is_correct":false},{"id":"d","label":"Aucune limite","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-3','amplitude'], 'mft-2026:moduleE:l3:q4', true,
   'Amplitude maxi = 12 h, extensible à 13 h si la pause peut être récupérée.'),
  (v_formation, v_module, 'qcm', 'Le repos quotidien minimum d''un conducteur est de :',
   '[{"id":"a","label":"8 h","is_correct":false},{"id":"b","label":"11 h consécutives (réductible à 9 h, 3 fois/sem)","is_correct":true},{"id":"c","label":"24 h","is_correct":false},{"id":"d","label":"48 h","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-3','repos'], 'mft-2026:moduleE:l3:q5', true,
   'Règlement européen 561/2006 : 11 h continu, réductible à 9 h trois fois par semaine.'),
  (v_formation, v_module, 'qcm', 'Le SMIC horaire 2026 est d''environ :',
   '[{"id":"a","label":"8 €","is_correct":false},{"id":"b","label":"11,88 €","is_correct":true},{"id":"c","label":"15 €","is_correct":false},{"id":"d","label":"20 €","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-e','capa-3-5t','lecon-3','smic'], 'mft-2026:moduleE:l3:q6', true,
   'SMIC 2026 ≈ 11,88 €/h brut, soit ~1 802 € brut mensuel pour 35 h.'),
  (v_formation, v_module, 'qcm', 'Le ratio approximatif Brut → Net salarié pour un non-cadre :',
   '[{"id":"a","label":"−10 %","is_correct":false},{"id":"b","label":"−22 à −25 %","is_correct":true},{"id":"c","label":"−40 %","is_correct":false},{"id":"d","label":"−50 %","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-3','net'], 'mft-2026:moduleE:l3:q7', true,
   'Cotisations salariales = ~22-25 % du brut. Coût total employeur = brut × 1,40 à 1,45.'),
  (v_formation, v_module, 'qcm', '35 h base, 12 € brut/h, 8 h sup à 25 %. Salaire brut hebdomadaire :',
   '[{"id":"a","label":"540 €","is_correct":true},{"id":"b","label":"660 €","is_correct":false},{"id":"c","label":"636 €","is_correct":false},{"id":"d","label":"420 €","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-e','capa-3-5t','lecon-3','calcul'], 'mft-2026:moduleE:l3:q8', true,
   'Base : 35 × 12 = 420 €. Sup : 8 × 12 × 1,25 = 120 €. Total : 540 €.'),
  (v_formation, v_module, 'qcm', 'Le bulletin de paie doit comporter :',
   '[{"id":"a","label":"Uniquement le net à payer","is_correct":false},{"id":"b","label":"Heures normales, sup, brut, cotisations détaillées, net","is_correct":true},{"id":"c","label":"Une seule ligne globale","is_correct":false},{"id":"d","label":"Le RIB du salarié","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-3','bulletin'], 'mft-2026:moduleE:l3:q9', true,
   'Mentions obligatoires : employeur, salarié, période, heures, cotisations, brut, net imposable, net.'),
  (v_formation, v_module, 'qcm', 'La prescription pour réclamer un rappel de salaire est de :',
   '[{"id":"a","label":"1 an","is_correct":false},{"id":"b","label":"3 ans","is_correct":true},{"id":"c","label":"5 ans","is_correct":false},{"id":"d","label":"10 ans","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-3','prescription'], 'mft-2026:moduleE:l3:q10', true,
   'Art. L. 3245-1 : 3 ans pour les rappels de salaire.'),
  (v_formation, v_module, 'qcm', 'Le temps de travail effectif (TTE) :',
   '[{"id":"a","label":"Inclut les pauses repas","is_correct":false},{"id":"b","label":"Exclut le chargement/déchargement","is_correct":false},{"id":"c","label":"Inclut conduite + chargement + attente subie","is_correct":true},{"id":"d","label":"Est égal au temps de présence","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-e','capa-3-5t','lecon-3','tte'], 'mft-2026:moduleE:l3:q11', true,
   'TTE = temps à disposition de l''employeur. Exclut pauses où le salarié peut vaquer librement.'),
  (v_formation, v_module, 'qcm', 'Les indemnités de repas et de découcher sont :',
   '[{"id":"a","label":"Soumises aux cotisations comme un salaire","is_correct":false},{"id":"b","label":"Exonérées dans les limites des barèmes URSSAF","is_correct":true},{"id":"c","label":"Toujours imposables","is_correct":false},{"id":"d","label":"Interdites","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-e','capa-3-5t','lecon-3','indemnites'], 'mft-2026:moduleE:l3:q12', true,
   'Remboursements de frais pro, exonérées dans les limites URSSAF (16-21 € repas, ~50 € découcher).');

  -- ===== LEÇON 4 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'Le CSE devient obligatoire à partir de :',
   '[{"id":"a","label":"1 salarié","is_correct":false},{"id":"b","label":"11 salariés","is_correct":true},{"id":"c","label":"50 salariés","is_correct":false},{"id":"d","label":"100 salariés","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-e','capa-3-5t','lecon-4','cse'], 'mft-2026:moduleE:l4:q1', true,
   'CSE simple à 11 salariés. CSE étendu à 50 salariés.'),
  (v_formation, v_module, 'qcm', 'Le DUER est obligatoire :',
   '[{"id":"a","label":"À partir de 50 salariés","is_correct":false},{"id":"b","label":"Dès le 1er salarié","is_correct":true},{"id":"c","label":"Uniquement transport","is_correct":false},{"id":"d","label":"Jamais obligatoire","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-e','capa-3-5t','lecon-4','duer'], 'mft-2026:moduleE:l4:q2', true,
   'DUER obligatoire dès le 1er salarié, mise à jour minimum annuelle.'),
  (v_formation, v_module, 'qcm', 'L''employeur doit déclarer un accident du travail à la CPAM dans :',
   '[{"id":"a","label":"24 h","is_correct":false},{"id":"b","label":"48 h","is_correct":true},{"id":"c","label":"8 jours","is_correct":false},{"id":"d","label":"30 jours","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-e','capa-3-5t','lecon-4','at'], 'mft-2026:moduleE:l4:q3', true,
   'Déclaration AT par CERFA dans les 48 h ouvrables.'),
  (v_formation, v_module, 'qcm', 'L''obligation de sécurité de l''employeur est :',
   '[{"id":"a","label":"De moyens","is_correct":false},{"id":"b","label":"De résultat","is_correct":true},{"id":"c","label":"Inexistante","is_correct":false},{"id":"d","label":"Limitée à fournir des EPI","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-4','securite'], 'mft-2026:moduleE:l4:q4', true,
   'Cass. soc. 2002 + art. L. 4121-1 : obligation de sécurité de RÉSULTAT.'),
  (v_formation, v_module, 'qcm', 'Le délégué syndical (DS) peut être désigné à partir de :',
   '[{"id":"a","label":"11 salariés","is_correct":false},{"id":"b","label":"50 salariés","is_correct":true},{"id":"c","label":"100 salariés","is_correct":false},{"id":"d","label":"200 salariés","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-4','ds'], 'mft-2026:moduleE:l4:q5', true,
   'DS désigné par syndicat représentatif à partir de 50 salariés.'),
  (v_formation, v_module, 'qcm', 'Les EPI sont :',
   '[{"id":"a","label":"À la charge du salarié","is_correct":false},{"id":"b","label":"Fournis gratuitement par l''employeur","is_correct":true},{"id":"c","label":"Facultatifs","is_correct":false},{"id":"d","label":"Ne concernent pas le transport","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-e','capa-3-5t','lecon-4','epi'], 'mft-2026:moduleE:l4:q6', true,
   'Employeur fournit gratuitement les EPI et les renouvelle. Salarié doit les porter.'),
  (v_formation, v_module, 'qcm', 'Le harcèlement moral est défini comme :',
   '[{"id":"a","label":"Un acte unique","is_correct":false},{"id":"b","label":"Des agissements répétés ayant pour effet une dégradation des conditions de travail","is_correct":true},{"id":"c","label":"Une plaisanterie","is_correct":false},{"id":"d","label":"Une critique","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-4','harcelement'], 'mft-2026:moduleE:l4:q7', true,
   'Art. L. 1152-1 C. trav. : agissements RÉPÉTÉS dégradant conditions de travail, dignité, santé.'),
  (v_formation, v_module, 'qcm', 'La cotisation AT/MP est :',
   '[{"id":"a","label":"Fixe (3 %)","is_correct":false},{"id":"b","label":"Variable selon historique de l''entreprise","is_correct":true},{"id":"c","label":"Inexistante","is_correct":false},{"id":"d","label":"Payée par le salarié","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-e','capa-3-5t','lecon-4','atmp'], 'mft-2026:moduleE:l4:q8', true,
   'Taux variable 1-5 % selon historique d''accidents. Plus d''accidents → plus on paie.'),
  (v_formation, v_module, 'qcm', 'La faute inexcusable de l''employeur :',
   '[{"id":"a","label":"N''existe pas","is_correct":false},{"id":"b","label":"Engage l''indemnisation intégrale du salarié, sans plafond","is_correct":true},{"id":"c","label":"Est limitée à 1 000 €","is_correct":false},{"id":"d","label":"Concerne uniquement les CDD","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-e','capa-3-5t','lecon-4','faute'], 'mft-2026:moduleE:l4:q9', true,
   'Conscience du danger sans agir : indemnisation intégrale + risque pénal.'),
  (v_formation, v_module, 'qcm', 'Combien de principes généraux de prévention l''employeur doit-il appliquer ?',
   '[{"id":"a","label":"3","is_correct":false},{"id":"b","label":"9","is_correct":true},{"id":"c","label":"20","is_correct":false},{"id":"d","label":"Aucun","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-e','capa-3-5t','lecon-4','prevention'], 'mft-2026:moduleE:l4:q10', true,
   'Art. L. 4121-2 : 9 principes (éviter, évaluer, combattre source, adapter, etc.).'),
  (v_formation, v_module, 'qcm', 'Une visite médicale d''embauche (VIP) :',
   '[{"id":"a","label":"N''existe plus","is_correct":false},{"id":"b","label":"Est obligatoire dans les 3 mois suivant l''embauche","is_correct":true},{"id":"c","label":"Est facultative","is_correct":false},{"id":"d","label":"Coûte 500 € au salarié","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-4','medecine'], 'mft-2026:moduleE:l4:q11', true,
   'VIP à l''embauche, puis tous les 5 ans (3 ans pour conducteurs ≤ 3,5 T).'),
  (v_formation, v_module, 'qcm', 'Les heures de délégation des élus CSE :',
   '[{"id":"a","label":"Ne sont pas payées","is_correct":false},{"id":"b","label":"Sont payées comme du temps de travail effectif","is_correct":true},{"id":"c","label":"Doivent être rattrapées","is_correct":false},{"id":"d","label":"Sont à charge du syndicat","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-e','capa-3-5t','lecon-4','delegation'], 'mft-2026:moduleE:l4:q12', true,
   'Heures de délégation = TTE, payées normalement.');

  -- ===== 6 QR =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qr',
   'Expliquez la hiérarchie des sources du droit du travail et le principe de faveur. Donnez un exemple.',
   NULL, 5, 'moyen', ARRAY['module-e','capa-3-5t','qr','hierarchie'], 'mft-2026:moduleE:qr1', true,
   'Hiérarchie : Constitution > Lois > CCN > Accords entreprise > Usages > Contrat. Principe de faveur = norme la plus favorable au salarié. Exemple : SMIC 11,88 € vs SMC CCN 12,30 € → on applique 12,30 €. Exception « bloc 3 » Macron 2017.'),
  (v_formation, v_module, 'qr',
   'Une SARL embauche un conducteur en CDD pour remplacer un congé maternité. Le contrat ne mentionne pas le nom de la salariée remplacée. Risques juridiques ?',
   NULL, 5, 'difficile', ARRAY['module-e','capa-3-5t','qr','cdd'], 'mft-2026:moduleE:qr2', true,
   'Mention obligatoire manquante → requalification en CDI. Conséquences : rappel préavis 2 mois, indemnité de licenciement, dommages-intérêts, prime de précarité due. Coût total : 6 à 12 mois de salaire.'),
  (v_formation, v_module, 'qr',
   'Comparez les avantages du CDI et du CDD pour l''employeur. Dans quel cas utiliser chacun ?',
   NULL, 5, 'moyen', ARRAY['module-e','capa-3-5t','qr','contrat'], 'mft-2026:moduleE:qr3', true,
   'CDI : forme normale, période d''essai 2-4 mois, pas de prime, fidélisation. CDD : 4 cas légaux, max 18 mois, prime 10 %, écrit obligatoire. Risque CDD = requalification en CDI si motif non valide.'),
  (v_formation, v_module, 'qr',
   'Calculez le salaire brut mensuel d''un conducteur courte distance qui travaille 40 h/semaine, taux horaire 12,40 € brut, 2 ans d''ancienneté (prime CCN 1 %).',
   NULL, 6, 'difficile', ARRAY['module-e','capa-3-5t','qr','calcul'], 'mft-2026:moduleE:qr4', true,
   'Base : 35 × 4,33 × 12,40 = 1 880,72 €. Sup 5 h × 4,33 × 12,40 × 1,25 = 335,82 €. Sous-total : 2 216,54 €. Prime 1 % : 22,17 €. SALAIRE BRUT : ~ 2 238,71 €.'),
  (v_formation, v_module, 'qr',
   'Pourquoi distinguer temps de conduite et temps de travail effectif ?',
   NULL, 4, 'moyen', ARRAY['module-e','capa-3-5t','qr','tte'], 'mft-2026:moduleE:qr5', true,
   'Temps de CONDUITE encadré par règlement européen 561/2006 (sécurité routière). TTE inclut conduite + chargement + attentes + formation, sert au calcul du SALAIRE et heures sup (Code du travail). Les deux maxima doivent être respectés simultanément.'),
  (v_formation, v_module, 'qr',
   'Un conducteur glisse en descendant de cabine et se blesse au genou. Pas de DUER à jour, EPI manquants. Risques pour l''entreprise ?',
   NULL, 6, 'difficile', ARRAY['module-e','capa-3-5t','qr','at'], 'mft-2026:moduleE:qr6', true,
   'AT (présomption d''imputabilité). Déclaration CPAM 48 h. Risques : (1) cotisation AT/MP majorée, (2) faute inexcusable possible (DUER absent + EPI manquants = preuves) → indemnisation intégrale sans plafond, (3) risque pénal blessures involontaires (3 ans + 45 000 €).'),

  -- ===== 9 QR supplémentaires (qr7 à qr15) — décision client mai 2026 =====
  (v_formation, v_module, 'qr',
   'Un conducteur courte distance signé en CDD de 6 mois pour accroissement temporaire d''activité (factures Noël) effectue 2 mois supplémentaires de mission après la fin du contrat sans avenant écrit. Vous le licenciez 3 semaines après cette poursuite. Quels sont les risques juridiques et financiers ?',
   NULL, 7, 'difficile', ARRAY['module-e','capa-3-5t','qr','cdd','requalification','cas-pratique'], 'mft-2026:moduleE:qr7', true,
   'POURSUITE DE FAIT après échéance d''un CDD = REQUALIFICATION AUTOMATIQUE EN CDI (art. L. 1243-11 C. trav.). Le conducteur est désormais en CDI à compter de la fin du CDD initial. Le « licenciement » 3 semaines après est donc un licenciement de CDI, qui exige : motif réel et sérieux + procédure (convocation, entretien, notification recommandée), à défaut = licenciement sans cause réelle et sérieuse. CONSÉQUENCES : (1) indemnité légale de licenciement (1/4 mois × ancienneté), (2) dommages-intérêts pour licenciement abusif (barème Macron 1-3 mois selon ancienneté), (3) rappel d''indemnité de précarité 10 % sur la période de poursuite, (4) prud''hommes probables. COÛT total : 4 à 8 mois de salaire. SOLUTION : signer un avenant ou un nouveau contrat avant la fin du CDD initial.'),
  (v_formation, v_module, 'qr',
   'Un conducteur effectue cette semaine : lundi 9 h, mardi 10 h, mercredi 9 h 30, jeudi 8 h 30, vendredi 7 h, samedi 4 h. Son taux horaire est de 13 € brut. La CCN ne prévoit pas d''heures structurelles pour cette catégorie. Calculez son salaire brut hebdomadaire avec le détail des majorations.',
   NULL, 7, 'difficile', ARRAY['module-e','capa-3-5t','qr','heures-sup','calcul'], 'mft-2026:moduleE:qr8', true,
   'Total semaine = 9 + 10 + 9,5 + 8,5 + 7 + 4 = 48 heures. Heures normales : 35 × 13 = 455 €. Heures sup 36e à 43e (8 h × 25 %) : 8 × 13 × 1,25 = 130 €. Heures sup 44e à 48e (5 h × 50 %) : 5 × 13 × 1,5 = 97,50 €. SALAIRE BRUT HEBDOMADAIRE = 455 + 130 + 97,50 = 682,50 €. Vérification : 48 h × 13 ≈ 624 € si pas de majoration → écart 58,50 € lié aux majorations.'),
  (v_formation, v_module, 'qr',
   'Vous voulez licencier un conducteur en CDI pour cause économique (perte d''un client représentant 60 % du CA). Ancienneté 7 ans, salaire 2 600 € brut. Détaillez la procédure et calculez l''indemnité de licenciement légale + le préavis CCN Transport.',
   NULL, 7, 'difficile', ARRAY['module-e','capa-3-5t','qr','licenciement','procedure','calcul'], 'mft-2026:moduleE:qr9', true,
   'PROCÉDURE LICENCIEMENT ÉCONOMIQUE : (1) information CSE si > 11 salariés, (2) convocation entretien préalable (5 jours min entre convocation et entretien), (3) entretien préalable + proposition de CSP (Contrat de Sécurisation Professionnelle), (4) notification recommandée AR avec motif économique précis (perte client documentée), (5) recherche reclassement préalable obligatoire (interne ou externe). INDEMNITÉ LÉGALE : 7 ans × 1/4 mois × 2 600 = 4 550 €. PRÉAVIS CCN Transport ouvrier > 2 ans = 2 mois soit 5 200 € (à payer même si dispense de présence). TOTAL coût licenciement = 4 550 + 5 200 = 9 750 €, hors CSP éventuel pris en charge par Pôle emploi.'),
  (v_formation, v_module, 'qr',
   'Vous embauchez votre premier salarié. Listez les 7 obligations administratives à accomplir avant et lors de l''embauche, avec les délais et les organismes concernés.',
   NULL, 6, 'moyen', ARRAY['module-e','capa-3-5t','qr','embauche','procedure'], 'mft-2026:moduleE:qr10', true,
   '(1) Déclaration Préalable À l''Embauche (DPAE) sur urssaf.fr — au plus tôt 8 jours avant l''embauche, au plus tard 1 jour avant. (2) Adhésion à un service de santé au travail (SST) — avant l''embauche. (3) Visite d''Information et Prévention (VIP) avant la prise de poste ou dans les 3 mois pour postes non à risque. (4) Affichage légal obligatoire (CCN, horaires, sécurité, harcèlement) — dès embauche. (5) Inscription au registre du personnel — jour de l''embauche. (6) Souscription assurance prévoyance + mutuelle obligatoire (CCN Transport) — au plus tard 1 mois après l''embauche. (7) Établissement et remise du contrat de travail — 1er jour, signé en 2 exemplaires. SANCTIONS si manquement DPAE : 1 100 € amende + travail dissimulé possible.'),
  (v_formation, v_module, 'qr',
   'Une salariée vient se plaindre auprès de vous (employeur) d''agissements répétés d''un autre salarié à connotation sexuelle (regards insistants, propos déplacés, contacts physiques non sollicités) sur les 3 derniers mois. Décrivez votre obligation et la procédure exacte à suivre, étape par étape.',
   NULL, 7, 'difficile', ARRAY['module-e','capa-3-5t','qr','harcelement','procedure','cas-pratique'], 'mft-2026:moduleE:qr11', true,
   'OBLIGATION : sécurité de RÉSULTAT (art. L. 4121-1) + obligation spécifique de prévenir le harcèlement (art. L. 1152-4). Inaction = co-responsabilité civile et pénale. PROCÉDURE : (1) Recevoir la salariée immédiatement, prendre note précise des faits (date, lieu, témoins) — confidentialité absolue. (2) Informer le référent harcèlement CSE (obligatoire ≥ 11 salariés). (3) Lancer une ENQUÊTE INTERNE rapide : auditionner la salariée, le mis en cause, les témoins éventuels, conserver les preuves (mails, SMS). (4) Pendant l''enquête : MESURE CONSERVATOIRE (changement d''équipe ou télétravail) pour protéger la victime. (5) Si harcèlement confirmé : sanction disciplinaire pouvant aller jusqu''au licenciement pour faute grave (sans préavis ni indemnité) du harceleur. (6) Soutien psychologique à la victime (médecine du travail). (7) Communication interne sur la politique anti-harcèlement. SANCTIONS PÉNALES harceleur : 3 ans + 45 000 € (art. 222-33 C. pénal). À défaut d''agir : indemnisation intégrale + prud''hommes + risque pénal employeur.'),
  (v_formation, v_module, 'qr',
   'Un conducteur en CDI demande une rupture conventionnelle après 4 ans dans l''entreprise (salaire 2 400 € brut). Vous acceptez. Décrivez la procédure et calculez l''indemnité minimale due.',
   NULL, 6, 'moyen', ARRAY['module-e','capa-3-5t','qr','rupture-conventionnelle','procedure','calcul'], 'mft-2026:moduleE:qr12', true,
   'PROCÉDURE : (1) Échange initial puis 1 ou 2 entretiens préalables (assistance possible : DP, CSE, conseiller du salarié pour le salarié, et conseil du syndicat ou autre salarié pour l''employeur). (2) Signature de la convention de rupture (formulaire CERFA) en 2 exemplaires. (3) Délai de rétractation 15 jours calendaires (à compter du lendemain de la signature) pour les 2 parties. (4) Demande d''homologation à la DDETS (ex-Direccte) après le délai de rétractation. (5) Délai d''instruction 15 jours ouvrés. Sans réponse = homologation tacite. (6) Date effective de rupture fixée dans la convention. INDEMNITÉ MINIMALE = indemnité légale de licenciement = 4 ans × 1/4 mois × 2 400 € = 2 400 €. Possibilité de négocier au-delà. AVANTAGES : ouvre droit chômage pour le salarié, sécurise l''employeur (pas de prud''hommes possibles).'),
  (v_formation, v_module, 'qr',
   'L''entreprise atteint 50 salariés au 1er janvier 2026 (sur 12 mois consécutifs). Listez les 6 nouvelles obligations qui en découlent et leur calendrier de mise en œuvre, ainsi que les sanctions en cas de non-respect.',
   NULL, 7, 'difficile', ARRAY['module-e','capa-3-5t','qr','seuils','obligations','irp'], 'mft-2026:moduleE:qr13', true,
   '(1) CSE étendu (avec budget 0,2 % de la masse salariale, commissions économique et formation) — élections sous 90 jours. Sanction : délit d''entrave 7 500 € + 1 an prison. (2) Délégué syndical (DS) désigné par syndicat représentatif. (3) Règlement intérieur OBLIGATOIRE (à transmettre Inspection du travail + CSE consultation) — 3 mois max. (4) BDESE (Base de Données Économiques, Sociales et Environnementales) tenue à disposition CSE. (5) Référent harcèlement sexuel CSE. (6) Plan de développement des compétences enrichi + Plan d''Épargne Entreprise possible. SANCTION GLOBALE non-conformité : entrave (7 500 € + 1 an), absence de RI (1 500 €), absence d''accord/plan formation (1 500 €/salarié). DÉLAI MISE EN ŒUVRE : 90 jours pour CSE étendu, 3 mois pour le RI.'),
  (v_formation, v_module, 'qr',
   'Vous comparez 2 contrats de travail pour un poste de chauffeur : (a) CDI à temps plein, salaire 2 200 € brut/mois ; (b) CDD 12 mois renouvelable 1 fois, salaire 2 200 € brut + prime de précarité 10 %. Quel coût total pour l''employeur sur 12 mois pour chaque option ? Quel choix recommander selon le contexte ?',
   NULL, 6, 'difficile', ARRAY['module-e','capa-3-5t','qr','contrat','cout','strategie'], 'mft-2026:moduleE:qr14', true,
   'Coût employeur ≈ Brut × 1,42 (charges patronales transport ≈ 42 %). CDI : 2 200 × 12 × 1,42 = 37 488 €. CDD : 2 200 × 12 × 1,42 + (2 200 × 12 × 0,10) = 37 488 + 2 640 = 40 128 €. ÉCART : CDD coûte +2 640 € (+ 7 %) sur l''année. CHOIX : CDI si besoin durable (le surcoût CDD ne se justifie pas + risque requalification + pas de fidélisation). CDD si besoin réellement temporaire (pic saisonnier, remplacement) — légalement obligatoire d''avoir un motif valable (4 cas légaux). RECOMMANDATION : démarrer en CDI avec période d''essai 2 mois renouvelable une fois, ce qui offre la même flexibilité de sortie qu''un CDD à coût moindre.'),
  (v_formation, v_module, 'qr',
   'Bulletin de paie mensuel d''un conducteur : salaire brut 2 350 €, dont 80 € de prime de panier non soumise. Calculez le net imposable, le net à payer (cotisations salariales 22 %, prélèvement à la source 5 %), et le coût total entreprise (charges patronales 42 % sur le brut soumis).',
   NULL, 7, 'difficile', ARRAY['module-e','capa-3-5t','qr','bulletin','calcul'], 'mft-2026:moduleE:qr15', true,
   'Brut soumis = 2 350 - 80 (prime panier non soumise) = 2 270 €. Cotisations salariales = 2 270 × 22 % = 499,40 €. Net avant impôt = 2 270 - 499,40 + 80 = 1 850,60 €. Net imposable ≈ 1 850,60 € + part CSG non déductible (≈ 2,4 % du brut soumis = 54,48 €) = 1 905,08 €. Prélèvement à la source = 1 905,08 × 5 % = 95,25 €. NET À PAYER = 1 850,60 - 95,25 = 1 755,35 €. CHARGES PATRONALES = 2 270 × 42 % = 953,40 €. COÛT TOTAL ENTREPRISE = 2 350 (brut total) + 953,40 = 3 303,40 € pour le mois.');

  -- =================================================================
  -- QUIZZES (4 entraînement + 1 examen blanc)
  -- =================================================================

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Sources du droit social — Quiz',
          'Quiz d''entraînement (12 questions) sur la hiérarchie des normes, la CCN Transport routier (IDCC 16) et le principe de faveur.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026:moduleE:l1:%';

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Contrat de travail — Quiz',
          'Quiz d''entraînement (12 questions) sur CDI, CDD, intérim, période d''essai et modes de rupture.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026:moduleE:l2:%';

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Durée du travail et paie — Quiz',
          'Quiz d''entraînement (12 questions) sur durée légale, heures sup, amplitude conducteurs, salaire et bulletin de paie.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026:moduleE:l3:%';

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'IRP et conditions de travail — Quiz',
          'Quiz d''entraînement (12 questions) sur CSE, DS, DUER, EPI, accidents du travail et harcèlement.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026:moduleE:l4:%';

  -- Quiz 5 — Cas pratiques contrats, paie et procédures (QR L1 + L2 + L3)
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Cas pratiques contrat de travail et paie — Quiz',
          'Quiz d''entraînement spécialisé : 9 cas pratiques rédigés (QR) sur la requalification CDD, le calcul du brut/net, les procédures de licenciement et de rupture conventionnelle.',
          'entrainement', NULL, 60)
  RETURNING id INTO v_quiz_5;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_5, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref IN (
       'mft-2026:moduleE:qr2','mft-2026:moduleE:qr3','mft-2026:moduleE:qr4',
       'mft-2026:moduleE:qr7','mft-2026:moduleE:qr8','mft-2026:moduleE:qr9',
       'mft-2026:moduleE:qr12','mft-2026:moduleE:qr14','mft-2026:moduleE:qr15'
     );

  -- Quiz 6 — Cas pratiques IRP, harcèlement, AT/MP et seuils d'effectif (QR L4)
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Cas pratiques IRP, sécurité et obligations RH — Quiz',
          'Quiz d''entraînement spécialisé : 6 cas pratiques rédigés (QR) sur l''embauche, le harcèlement, les accidents du travail et les obligations liées aux seuils d''effectif.',
          'entrainement', NULL, 60)
  RETURNING id INTO v_quiz_6;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_6, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref IN (
       'mft-2026:moduleE:qr1','mft-2026:moduleE:qr5','mft-2026:moduleE:qr6',
       'mft-2026:moduleE:qr10','mft-2026:moduleE:qr11','mft-2026:moduleE:qr13'
     );

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold, is_mock_exam)
  VALUES (v_module, 'Examen blanc — Module E Salariés et droit social',
          'Examen blanc reproduisant les conditions de l''examen national : 13 QCM représentatifs des 4 leçons + 5 QR, durée 60 min, seuil 50 %.',
          'examen', 3600, 50, true)
  RETURNING id INTO v_quiz_eb;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref IN (
     'mft-2026:moduleE:l1:q2','mft-2026:moduleE:l1:q3','mft-2026:moduleE:l1:q5','mft-2026:moduleE:l1:q6',
     'mft-2026:moduleE:l2:q2','mft-2026:moduleE:l2:q3','mft-2026:moduleE:l2:q6','mft-2026:moduleE:l2:q9',
     'mft-2026:moduleE:l3:q1','mft-2026:moduleE:l3:q4','mft-2026:moduleE:l3:q5',
     'mft-2026:moduleE:l4:q1','mft-2026:moduleE:l4:q4',
     'mft-2026:moduleE:qr1','mft-2026:moduleE:qr2','mft-2026:moduleE:qr4','mft-2026:moduleE:qr5','mft-2026:moduleE:qr6'
   );

  RAISE NOTICE '✓ Module E v3 dense importé : 4 leçons (sources droit social, contrat, paie, IRP), 48 QCM, 15 QR, 7 quiz (6 entraînement + 1 examen blanc).';

END $module_e_v3$;
