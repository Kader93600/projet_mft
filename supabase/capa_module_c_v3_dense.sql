-- =====================================================================
-- MODULE C — CADRE RÉGLEMENTAIRE DU TRANSPORT (Capacité ≤ 3,5 T)
-- Version 3 (mai 2026) — REFONTE PÉDAGOGIQUE DENSIFIÉE
--
-- Diagnostic v2 corrigé :
--   ✓ Bug bloc : v_bloc résolu via slug fiable (pas ORDER BY id LIMIT 1)
--   ✓ Quiz : chaque quiz d'entraînement contient maintenant 12 QCM
--   ✓ Leçons : structure pédagogique pro complète
--   ✓ Banque enrichie : 48 QCM (vs 35) avec niveaux facile/moyen/difficile
--   ✓ QR : 7 (vs 6) avec barème implicite et cas réalistes
--   ✓ Examen blanc : 13 QCM + 5 QR (durée 60 min, seuil 50 %)
--
-- Référentiel décision du 2 avril 2012 — module le PLUS important :
--   13 QCM (26 pts) + 1 QR (10 pts) = 36 points sur 84
-- ▸ 4 leçons :
--   1. Organisation administrative de la profession (DREAL, CRSR, CCT)
--   2. Conditions d'accès à la profession (capacité, honorabilité, financière)
--   3. Contrat de transport et lettre de voiture
--   4. Contrats spéciaux et assurances
--
-- Idempotent. Pré-requis : formation 'capacite-3-5t'.
-- =====================================================================

DO $module_c_v3$
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
  v_quiz_eb uuid;
  v_q uuid;
BEGIN
  -- ─── 1. Pré-requis ──────────────────────────────────────────────────
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'capacite-3-5t';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation capacite-3-5t introuvable.';
  END IF;

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
    RAISE EXCEPTION 'Bloc BC1 introuvable.';
  END IF;

  -- ─── 2. Module ──────────────────────────────────────────────────────
  DELETE FROM public.modules WHERE slug = 'capa-cadre-reglementaire-transport';

  INSERT INTO public.modules (
    title, slug, bloc_id, summary, difficulty, duration_min, "order"
  ) VALUES (
    'Module C — Cadre réglementaire du transport',
    'capa-cadre-reglementaire-transport',
    v_bloc,
    'Maîtriser l''organisation de la profession (DREAL, CRSR, CCT), les conditions d''accès (capacité, honorabilité, capacité financière), le contrat de transport, la lettre de voiture, les contrats spéciaux et les assurances.',
    'avance',
    630, -- durée officielle Capacité ≤ 3,5 t (révision client 2026-05)
    30
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 30, true) ON CONFLICT DO NOTHING;

  -- ─── 3. Reset banque ────────────────────────────────────────────────
  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026:moduleC:%';

  -- =================================================================
  -- LEÇON 1 — Organisation administrative de la profession
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Organisation administrative de la profession',
    'organisation-administrative-profession',
    1, 60,
$lessonC1$
# Organisation administrative de la profession

> 🎯 **Objectifs pédagogiques**
>
> À la fin de cette leçon, vous serez capable de :
>
> - **Identifier** les acteurs administratifs qui régulent le transport routier en France.
> - **Distinguer** les rôles de la DREAL, de la DGITM, des CCT et des CRSR.
> - **Connaître** les principales organisations professionnelles (FNTR, OTRE, TLF) et leur utilité.
> - **Comprendre** les conventions collectives applicables (CCNTR, accord ACT 8).
> - **Naviguer** dans la documentation officielle (BOTRA, JO, code des transports).

---

## Introduction

Le transport routier de marchandises est l'une des **activités les plus réglementées** de France. Comprendre **qui fait quoi** dans cette pyramide administrative n'est pas un luxe pédagogique : c'est le moyen de :

- Savoir **où déposer** vos demandes de licence et d'attestation.
- Connaître les **autorités de contrôle** que vous croiserez sur la route ou dans vos locaux.
- Identifier les **organisations professionnelles** qui défendent vos intérêts.
- Trouver les **textes officiels** quand vous avez un doute juridique.

Cette leçon est **structurellement importante pour l'examen** : 4 à 5 questions du QCM national portent typiquement sur l'organisation administrative et les sigles. Apprenez les acronymes par cœur.

---

## 1. Le ministère de tutelle et la DGITM

### 1.1 Le ministère

Le transport routier est rattaché au **ministère chargé des Transports** (parfois fusionné avec l'Écologie : « ministère de la Transition écologique et solidaire » ou variantes). Il fixe la politique nationale, prépare les textes législatifs et négocie les directives européennes.

### 1.2 La DGITM

> 📚 **Définition**
>
> La **DGITM** (Direction Générale des Infrastructures, des Transports et des Mobilités) est l'administration centrale du ministère qui pilote l'ensemble des transports terrestres, maritimes et fluviaux en France.

**Compétences de la DGITM en transport routier :**

- Élaboration des textes réglementaires.
- Tutelle sur les DREAL.
- Suivi des conventions collectives.
- Statistiques sectorielles.

> 💡 **Astuce métier**
>
> La DGITM ne traite **jamais** un dossier individuel d'entreprise. Tous les dossiers (licence, capacité, sanctions) passent par les **DREAL régionales**.

---

## 2. La DREAL : votre interlocuteur principal

### 2.1 Définition et compétences

> 📚 **Définition**
>
> Les **DREAL** (Directions Régionales de l'Environnement, de l'Aménagement et du Logement) sont les services déconcentrés de l'État au niveau régional. En transport, le **service Transports / Contrôles transports terrestres** gère :

| Mission | Détail |
|---|---|
| **Inscription au registre des transporteurs** | Procédure obligatoire avant immatriculation au RCS pour activité transport |
| **Délivrance de la Licence de transport intérieur (LTI)** | Pour ≤ 3,5 t ou pour transport pour compte propre |
| **Délivrance de la Licence communautaire** | Pour > 3,5 t et transport européen |
| **Suivi de la capacité financière** | Vérification annuelle |
| **Suivi de l'honorabilité professionnelle** | Casier judiciaire B2 |
| **Sanctions administratives** | Avertissement, suspension, retrait de licence |

### 2.2 Cas pratique 1 — Démarches DREAL

> 🚛 **Mise en situation**
>
> Vous avez obtenu votre attestation de capacité et créé votre SARL. Vous souhaitez démarrer immédiatement votre activité avec 1 VUL ≤ 3,5 t.
>
> **Question :** dans quel ordre faire vos démarches ?

**Correction étape par étape :**

1. **Inscription au registre des transporteurs auprès de la DREAL** (formulaire dédié, copie attestation de capacité, justificatif capacité financière, casier judiciaire B2).
2. **Délivrance de la LTI** par la DREAL (4 à 8 semaines).
3. **Apposition du copie certifiée** de la LTI sur le pare-brise du VUL.
4. **Démarrage des transports**.

**Avant la LTI, vous ne pouvez pas légalement transporter pour compte d'autrui** (≥ 0,5 t en VUL). Sanction : amende administrative + immobilisation du véhicule.

---

## 3. Le CRSR et les CCT

### 3.1 Le CRSR

> 📚 **Définition**
>
> Le **CRSR** (Conseil Régional Supérieur de la Réglementation des Transports) — parfois orthographié « Comité » — est une instance consultative régionale présidée par le préfet de région. Il regroupe :
>
> - Représentants de l'administration (DREAL, douanes, gendarmerie).
> - Représentants des organisations professionnelles (FNTR, OTRE, TLF).
> - Représentants des syndicats de salariés.
> - Représentants des chargeurs.

**Mission du CRSR :**

- Émettre un **avis** sur les sanctions administratives importantes (suspension > 3 mois, retrait de capacité).
- Examiner les dossiers de **dérogation**.
- Donner un **avis général** sur l'évolution de la profession dans la région.

### 3.2 La CCT

> 📚 **Définition**
>
> La **CCT** (Commission des Sanctions Administratives) est compétente au niveau régional pour examiner les dossiers de sanctions disciplinaires (suspension de capacité, interdiction temporaire d'exercice).

**Composition :** présidée par un magistrat administratif, elle comprend des représentants administration + profession + syndicats.

**Procédure :**

1. La DREAL constate un manquement (infraction grave, perte de l'honorabilité).
2. Saisine de la CCT.
3. Convocation du transporteur, présentation de ses arguments (avocat possible).
4. Avis motivé de la CCT.
5. Décision finale du préfet ou du ministre selon la gravité.

---

## 4. Les organisations professionnelles

### 4.1 Les 3 fédérations principales

| Organisation | Profil | Spécificités |
|---|---|---|
| **FNTR** (Fédération Nationale des Transports Routiers) | La plus ancienne et la plus large | Représente surtout les PME/ETI tous types de transport |
| **OTRE** (Organisation des Transporteurs Routiers Européens) | Plus jeune, plus militante | Centrée sur les TPE/PME indépendantes, défense des « petits » transporteurs |
| **TLF** (Union des entreprises de Transport et de Logistique de France) | Logistique + transport | Profil plus international, gros opérateurs et commissionnaires |

### 4.2 Pourquoi adhérer ?

| Bénéfice | Détail |
|---|---|
| **Veille réglementaire** | Newsletters, alertes texte, formations CACES, FCO |
| **Conseil juridique et social** | Hotline, modèles de contrat, défense individuelle |
| **Représentation collective** | Lobbying CRSR, négociations conventions collectives |
| **Mutualisation** | Achats groupés (carburant, assurance), GPS flotte |

**Coût adhésion** : ~ 300 à 1 500 €/an selon la taille de l'entreprise.

---

## 5. Les conventions collectives applicables

### 5.1 La CCNTR

La **Convention Collective Nationale des Transports Routiers et activités auxiliaires (CCNTR)** est le texte de référence pour le transport routier de marchandises.

**Couverture :**

- Tous les salariés des entreprises de transport routier de marchandises (TRM), de transport routier de voyageurs (TRV), de location, de logistique.
- Définit les **classifications** (coefficients de salaire), la **durée du travail**, les **congés**, les **primes**, le **régime des frais de déplacement**.

### 5.2 L'accord ACT 8 (« CET 8 »)

> 📚 **Définition**
>
> L'**accord du 8 février 2008** (souvent abrégé « ACT 8 » ou « accord CET 8 ») modernise le temps de travail dans le transport routier. Il définit :
>
> - Le décompte hebdomadaire / mensuel / annuel.
> - Les **équivalences** (heures de présence comptées différemment des heures effectives).
> - Les **majorations** (heures supplémentaires, dimanches, jours fériés).
> - Les **frais de déplacement** (indemnité forfaitaire, repas).

> ⚠️ **Attention examen**
>
> L'accord ACT 8 est **fréquemment cité** en QCM. Retenez : **8 février 2008**, modernise la durée du travail dans le TRM.

---

## 6. La documentation officielle

### 6.1 Les principaux textes

| Texte | Contenu |
|---|---|
| **Code des transports** | Texte législatif principal pour le transport routier (livres I à VIII) |
| **Code de la route** | Règles de circulation, vitesses, alcoolémie, points |
| **Code de commerce** | Délais de paiement, factures, contrats commerciaux |
| **Code du travail** | Droit du travail, protection des salariés |
| **BOTRA** (Bulletin Officiel des Transports) | Publications hebdomadaires des décisions ministérielles |
| **Décret du 30 août 1999** | Contrats-types transport (révisé périodiquement) |
| **Décision du 2 avril 2012** | Référentiel de l'examen national capacité ≤ 3,5 t |

### 6.2 Cas pratique 2 — Trouver un texte

> 🚛 **Mise en situation**
>
> Vous voulez vérifier si vous pouvez transporter pour un client à compte propre. Quel texte consulter ?

**Correction :**

1. **Code des transports**, partie législative, livre I.
2. **Article L. 1411-1 et suivants** définissent transport public vs transport privé (compte propre).
3. **Décret n° 99-752** précise les conditions du compte propre.

**Source pratique :** site **legifrance.gouv.fr** (gratuit) — recherche par code, article ou mots-clés.

---

## 7. Mini-exercice guidé

> ✏️ **À vous**
>
> Pour chacun des sigles suivants, indiquez à quoi il correspond et son rôle principal :
>
> 1. DREAL
> 2. DGITM
> 3. CRSR
> 4. CCT
> 5. FNTR
> 6. OTRE

**Correction :**

| Sigle | Signification | Rôle |
|---|---|---|
| DREAL | Direction Régionale de l'Environnement, de l'Aménagement et du Logement | Service déconcentré de l'État, gère licences, capacité, contrôles |
| DGITM | Direction Générale des Infrastructures, des Transports et des Mobilités | Administration centrale (ministère) |
| CRSR | Conseil Régional Supérieur de la Réglementation des Transports | Instance consultative régionale, avis sur sanctions |
| CCT | Commission des Sanctions Administratives | Examine les sanctions disciplinaires |
| FNTR | Fédération Nationale des Transports Routiers | Organisation patronale historique |
| OTRE | Organisation des Transporteurs Routiers Européens | Organisation patronale plus militante TPE/PME |

---

## 8. Glossaire des notions clés

| Terme | Définition |
|---|---|
| **DGITM** | Administration centrale du ministère des Transports |
| **DREAL** | Service régional de l'État, gère licences et contrôles |
| **CRSR** | Conseil consultatif régional sur les sanctions et la profession |
| **CCT** | Commission des sanctions administratives |
| **CCNTR** | Convention collective nationale des transports routiers |
| **ACT 8** | Accord du 8 février 2008 sur la durée du travail TRM |
| **BOTRA** | Bulletin Officiel des Transports |
| **LTI** | Licence de transport intérieur (≤ 3,5 t et compte propre) |
| **Licence communautaire** | Licence pour > 3,5 t et transport intra-UE |
| **FNTR / OTRE / TLF** | 3 principales organisations patronales du transport routier |

---

## 🧠 Synthèse opérationnelle

> 📌 **Les 8 points à retenir**
>
> 1. **DGITM** = administration centrale (Paris). **DREAL** = services régionaux (votre interlocuteur principal).
> 2. **DREAL** délivre LTI et licence communautaire, gère la capacité financière, l'honorabilité, les sanctions.
> 3. **CRSR** = instance consultative régionale présidée par le préfet, avis sur sanctions importantes.
> 4. **CCT** = commission des sanctions administratives, examen disciplinaire.
> 5. **3 organisations patronales** : FNTR (historique), OTRE (TPE/PME militante), TLF (logistique/international).
> 6. **CCNTR** = convention collective de référence pour le TRM.
> 7. **ACT 8** (8 février 2008) = accord sur le temps de travail.
> 8. **Sources** : Code des transports + Code de la route + Code de commerce + BOTRA + legifrance.gouv.fr.

---

## 🎓 Ce que l'examinateur peut demander

1. **« Que signifie DREAL ? »** → Direction Régionale de l'Environnement, de l'Aménagement et du Logement. Service déconcentré de l'État.
2. **« Qui délivre la LTI ? »** → La DREAL.
3. **« Quel est le rôle du CRSR ? »** → Conseil consultatif régional, donne un avis sur les sanctions administratives.
4. **« Citez 2 organisations patronales du transport routier. »** → FNTR, OTRE, TLF.
5. **Cas en QR** : Décrire la procédure d'inscription au registre des transporteurs auprès de la DREAL.

---

## 📋 Mémo à imprimer

```
PYRAMIDE ADMINISTRATIVE TRANSPORT
Ministère Transports
   │
   DGITM (administration centrale)
   │
   DREAL (services régionaux) ← votre interlocuteur principal

INSTANCES CONSULTATIVES / DISCIPLINAIRES
CRSR  → Conseil consultatif régional (avis sur sanctions)
CCT   → Commission Sanctions Administratives (examen disciplinaire)

ORGANISATIONS PATRONALES
FNTR  → Fédération Nationale des Transports Routiers (historique)
OTRE  → Organisation des Transporteurs Routiers Européens (TPE/PME)
TLF   → Union Transport et Logistique de France (logistique/international)

TEXTES DE RÉFÉRENCE
CCNTR → Convention collective nationale TRM
ACT 8 → Accord temps de travail (8 février 2008)
BOTRA → Bulletin Officiel des Transports

LICENCES (DREAL)
LTI               → ≤ 3,5 t et compte propre
Licence commun.   → > 3,5 t et transport intra-UE
```
$lessonC1$,
'Connaître les acteurs administratifs (DGITM, DREAL, CRSR, CCT), les organisations patronales (FNTR, OTRE, TLF), les conventions collectives (CCNTR, ACT 8) et la documentation officielle.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Conditions d'accès à la profession
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Conditions d''accès à la profession de transporteur',
    'conditions-acces-profession',
    2, 60,
$lessonC2$
# Conditions d'accès à la profession de transporteur

> 🎯 **Objectifs pédagogiques**
>
> À la fin de cette leçon, vous serez capable de :
>
> - **Énumérer** les 4 conditions d'accès à la profession (établissement, honorabilité, capacité financière, capacité professionnelle).
> - **Calculer** la capacité financière requise selon le nombre de véhicules.
> - **Identifier** les infractions qui font perdre l'honorabilité professionnelle.
> - **Comprendre** la procédure d'inscription au registre des transporteurs.
> - **Anticiper** les sanctions en cas de manquement.

---

## Introduction

Le règlement européen **CE n° 1071/2009** (transposé en droit français en 2011) a harmonisé les conditions d'accès à la profession de transporteur dans toute l'Union européenne. Il impose **4 exigences cumulatives** que vous devez **toutes** respecter pour exercer légalement.

Le contrôle de ces 4 conditions est **continu** : la DREAL ne se contente pas de les vérifier à la création. Elle les **revoit chaque année** (capacité financière) et lors de tout signalement (honorabilité). Si une condition n'est plus remplie, vous risquez la **suspension** voire le **retrait définitif** de votre licence.

Cette leçon est **la plus testée à l'examen** : 3-4 questions portent directement sur les seuils chiffrés (capacité financière, durée d'incompatibilité, etc.). À mémoriser absolument.

---

## 1. Les 4 conditions cumulatives

### 1.1 Vue d'ensemble

| Condition | Exigence | Article |
|---|---|---|
| **1. Établissement réel et stable** | Locaux pro en France, parc de véhicules, documents conservés | Art. 5 du règl. 1071/2009 |
| **2. Honorabilité professionnelle** | Casier compatible (B2), pas de condamnation lourde liée à la profession | Art. 6 |
| **3. Capacité financière** | Capitaux propres ou cautionnement min : 1 800 € pour 1er VUL ≤ 3,5 t | Art. 7 |
| **4. Capacité professionnelle** | Attestation après examen (notre objet) | Art. 8 |

### 1.2 Leur caractère cumulatif

> ⚠️ **Attention examen**
>
> Les 4 conditions sont **cumulatives** : il faut **toutes** les remplir simultanément. Si une seule fait défaut (ex. perte d'honorabilité), la DREAL peut suspendre votre LTI quelles que soient les 3 autres.

---

## 2. Condition 1 — Établissement réel et stable

### 2.1 Définition

> 📚 **Définition**
>
> L'**établissement réel et stable** est le siège effectif de l'entreprise sur le territoire français, où :
>
> - Sont **conservés** les documents principaux (livre de paie, contrats, états financiers, livret personnel, données du tachygraphe).
> - Se trouvent les **véhicules** habituellement utilisés (parking, hangar).
> - **Vit** ou **travaille effectivement** au moins une partie du temps le **gestionnaire de transport** (titulaire de la capacité).

### 2.2 Cas pratique 1 — Établissement fictif

> 🚛 **Mise en situation**
>
> **Karim** habite Bruxelles mais souhaite immatriculer une SARL de transport à Paris (siège social = boîte postale dans une domiciliation administrative). Il prévoit que toutes les opérations se feront à distance, et que les VUL stationneront dans des parkings publics parisiens.
>
> **Question :** ce montage est-il valide ?

**Correction :**

**NON.** Plusieurs problèmes :

1. **Pas d'établissement réel** : une domiciliation seule n'est pas suffisante. La DREAL exige des locaux où sont conservés les documents et où se trouvent les véhicules.
2. **Gestionnaire de transport non présent** : Karim devrait habiter ou travailler effectivement en France pour exercer le rôle de gestionnaire.
3. **Risque de retrait** : si la DREAL constate l'absence d'établissement réel, elle peut refuser l'inscription au registre, ou retirer la LTI déjà délivrée.

**Solution alternative** : Karim peut immatriculer en Belgique (où il réside), avec la licence communautaire belge, et opérer en France via le mécanisme du **cabotage** (limité à 3 opérations en 7 jours en transport intra-UE).

---

## 3. Condition 2 — Honorabilité professionnelle

### 3.1 Définition

> 📚 **Définition**
>
> L'**honorabilité professionnelle** signifie l'absence de condamnations pénales graves liées à l'exercice de la profession ou à des manquements financiers.

**Pièce justificative** : extrait du **casier judiciaire B2** demandé par la DREAL au Casier judiciaire national de Nantes.

### 3.2 Les condamnations qui font perdre l'honorabilité

| Type de condamnation | Conséquence |
|---|---|
| Crime ou délit grave (atteinte à l'intégrité physique, vol qualifié, escroquerie en bande) | Perte automatique |
| Trafic de stupéfiants, traite d'êtres humains | Perte automatique |
| Fraude fiscale grave, banqueroute | Perte automatique |
| Manquement répété aux règles : durée du travail, ADR, cabotage | Perte sur appréciation |
| Non-paiement des cotisations sociales (URSSAF) | Perte sur appréciation |
| Conduite sous emprise (alcool, stups) avec récidive | Perte sur appréciation |

### 3.3 Durées et procédure de réhabilitation

| Étape | Délai |
|---|---|
| Perte de l'honorabilité | À la condamnation devenue définitive |
| Délai de réhabilitation possible | Variable selon la peine, généralement **3 à 5 ans** après exécution |
| Réintégration au registre | Demande motivée à la DREAL + casier B2 vierge |

### 3.4 Cas pratique 2 — Réhabilitation

> 🚛 **Mise en situation**
>
> **Léa**, gérante d'une SARL de transport, a été condamnée en 2022 à 6 mois de prison avec sursis pour **non-paiement de cotisations URSSAF** (montant 45 000 €). La SARL a ensuite été liquidée. Sa LTI lui a été retirée pour perte d'honorabilité. En 2026, elle souhaite redémarrer.
>
> **Question :** quelles démarches doit-elle entreprendre ?

**Correction :**

1. **Régulariser la dette URSSAF** (sinon pas de dossier valable).
2. **Demander un extrait de casier B2** à jour (vérifier que la condamnation est purgée et qu'aucune nouvelle n'a été ajoutée).
3. **Adresser une demande motivée de réhabilitation** à la DREAL régionale, accompagnée :
   - du jugement de réhabilitation pénale (le cas échéant),
   - de l'attestation URSSAF de paiement,
   - d'une lettre exposant son projet et les garanties de bonne gestion futures.
4. **Repasser l'attestation de capacité** si la sienne a été retirée.
5. La DREAL **statue** sous quelques mois après éventuel passage devant la **CCT**.

---

## 4. Condition 3 — Capacité financière

### 4.1 Les seuils chiffrés

| Type de véhicule | Capacité financière exigée |
|---|---|
| **1er VUL ≤ 3,5 t** | **1 800 €** |
| **Chaque VUL supplémentaire ≤ 3,5 t** | **+ 900 €** |
| **1er véhicule > 3,5 t** | **9 000 €** |
| **Chaque véhicule supplémentaire > 3,5 t** | **+ 5 000 €** |

> ⚠️ **Attention examen**
>
> Les 4 chiffres ci-dessus sont **systématiquement testés** à l'examen national. Apprenez-les par cœur : **1 800 / 900 / 9 000 / 5 000**.

### 4.2 Comment justifier la capacité financière

**3 modes possibles** au choix :

| Mode | Justificatif |
|---|---|
| **Capitaux propres** | Bilan certifié (commissaire aux comptes ou expert-comptable) |
| **Caution bancaire** | Lettre d'engagement d'une banque ou compagnie d'assurance |
| **Cautionnement personnel** | Engagement de la BPI ou d'un organisme spécialisé (SIAGI) |

### 4.3 Cas pratique 3 — Calcul

> 🚛 **Mise en situation**
>
> **Yacine** veut créer sa SARL avec **3 VUL ≤ 3,5 t** dès le démarrage.
>
> **Question :** quel montant de capacité financière doit-il justifier ?

**Correction :**

```
1er VUL              : 1 800 €
2e VUL  (+ 900 €)    :   900 €
3e VUL  (+ 900 €)    :   900 €
                     ────────
Capacité financière  : 3 600 €
```

Yacine doit donc présenter à la DREAL **3 600 €** de capitaux propres au bilan, OU une caution bancaire de 3 600 €, OU un engagement BPI/SIAGI de ce montant.

### 4.4 Mini-exercice guidé

> ✏️ **À vous**
>
> Pour chacun des cas, calculez la capacité financière exigée :
>
> 1. 1 VUL ≤ 3,5 t.
> 2. 5 VUL ≤ 3,5 t.
> 3. 1 véhicule > 3,5 t.
> 4. 2 véhicules > 3,5 t + 1 VUL ≤ 3,5 t.

**Correction :**

1. **1 800 €** (1er VUL).
2. **1 800 + 4 × 900 = 5 400 €** (1er VUL + 4 supplémentaires).
3. **9 000 €** (1er > 3,5 t).
4. Pour les > 3,5 t : 9 000 + 5 000 = 14 000 €. Pour le VUL : on **n'additionne pas** les flottes — on prend le règle propre à chaque catégorie. Donc 14 000 € + 1 800 € = **15 800 €** au total.

---

## 5. Condition 4 — Capacité professionnelle

### 5.1 Comment l'obtenir

**3 voies possibles** :

| Voie | Conditions | Remarque |
|---|---|---|
| **Examen national** | Réussir le QCM de capacité ≤ 3,5 t (ou > 3,5 t selon projet) | Voie principale, c'est l'objet de cette formation |
| **Diplôme équivalent** | Bac+2 transport (DUT GLT, BTS transport-logistique, etc.) | Reconnaissance automatique |
| **Expérience professionnelle** | Au moins **10 ans** comme dirigeant ou cadre transport | Validation par dossier à la DREAL |

### 5.2 Caractéristiques de l'attestation

| Caractéristique | Détail |
|---|---|
| **Délivrance** | Préfecture de région après réussite à l'examen |
| **Validité** | À vie (sauf retrait disciplinaire) |
| **Caractère** | **Personnelle** (≠ licence qui est attachée à l'entreprise) |
| **Multiple gérants** | Au moins **un** gestionnaire de transport doit être titulaire dans chaque entreprise inscrite |

> 💡 **Astuce métier**
>
> L'attestation de capacité étant personnelle et à vie, vous pouvez :
>
> - **Quitter une entreprise** pour en créer une autre, votre attestation vous suit.
> - **Devenir gestionnaire externe** (autoentrepreneur ou contrat) pour une entreprise qui n'a pas de capacitaire interne (cas fréquent dans les petites SARL où le dirigeant délègue cette fonction).

### 5.3 Le rôle du gestionnaire de transport

> 📚 **Définition**
>
> Le **gestionnaire de transport** est la personne désignée dans l'entreprise comme **responsable de la conformité réglementaire**. Il **doit** être titulaire de l'attestation de capacité.

| Mission | Détail |
|---|---|
| Garantir le respect des règles européennes et nationales | Temps de conduite, repos, ADR, cabotage |
| Conserver les documents | Tachygraphe, lettres de voiture, contrats, factures |
| Assurer le contrôle interne | Audits réguliers, formation des chauffeurs |
| Représenter l'entreprise lors des contrôles | DREAL, gendarmerie, douanes |

> ⚠️ **Attention examen**
>
> Une entreprise **sans gestionnaire de transport** valide ne peut **pas** opérer. Si le seul capacitaire de l'entreprise quitte l'effectif (départ, décès, démission, retrait), l'entreprise dispose de **6 mois maximum** pour désigner un remplaçant valide. Au-delà, suspension de la licence.

---

## 6. La procédure d'inscription au registre des transporteurs

### 6.1 Les étapes

| Étape | Délai indicatif | Document |
|---|---|---|
| 1. Constitution de la société (Kbis) | 2 semaines | Statuts, immatriculation RCS |
| 2. Demande d'inscription au registre des transporteurs (DREAL) | 1 jour de dépôt | Formulaire dédié + pièces justificatives |
| 3. Vérification par DREAL des 4 conditions | 4-8 semaines | Audit dossier, parfois visite locaux |
| 4. Délivrance de la LTI | Quelques jours après validation | Document à apposer sur pare-brise |
| 5. Démarrage des transports | Immédiat après LTI | — |

### 6.2 Pièces justificatives types

- Kbis < 3 mois.
- Statuts à jour.
- Attestation de capacité du gestionnaire de transport.
- Casier B2 du dirigeant et du gestionnaire de transport.
- Justificatif de capacité financière (bilan, caution, cautionnement BPI).
- Justificatif des locaux (bail commercial ou titre de propriété).
- Justificatif de l'immatriculation des véhicules.

---

## 7. Glossaire des notions clés

| Terme | Définition |
|---|---|
| **Règl. 1071/2009** | Règlement européen sur l'accès à la profession de transporteur |
| **4 conditions cumulatives** | Établissement / Honorabilité / Capacité financière / Capacité professionnelle |
| **Établissement réel et stable** | Siège effectif avec locaux, véhicules et gestionnaire présents |
| **Honorabilité professionnelle** | Absence de condamnations graves (casier B2) |
| **Casier B2** | Extrait de casier judiciaire spécifique destiné aux administrations |
| **Capacité financière** | Garantie financière calculée selon le nombre de véhicules |
| **Cautionnement BPI / SIAGI** | Mécanisme alternatif aux capitaux propres pour la capacité financière |
| **Capacité professionnelle** | Attestation personnelle obtenue par examen, diplôme ou expérience |
| **Gestionnaire de transport** | Personne titulaire de la capacité responsable de la conformité dans l'entreprise |
| **Délai 6 mois** | Maximum pour remplacer un gestionnaire qui quitte l'entreprise |

---

## 🧠 Synthèse opérationnelle

> 📌 **Les 8 points à retenir**
>
> 1. **4 conditions cumulatives** : établissement, honorabilité, capacité financière, capacité professionnelle.
> 2. Capacité financière : **1 800 € (1er VUL) + 900 € (par VUL suppl.)** en transport ≤ 3,5 t.
> 3. Pour > 3,5 t : **9 000 € (1er) + 5 000 € (par véhicule suppl.)**.
> 4. **Attestation de capacité** = personnelle et à vie. **Licence** (LTI) = liée à l'entreprise, renouvelée 10 ans.
> 5. **Gestionnaire de transport** = personne titulaire de la capacité, responsable conformité. Obligatoire dans chaque entreprise transport.
> 6. Si le gestionnaire de transport quitte l'entreprise : **6 mois** pour le remplacer, sinon suspension licence.
> 7. **Honorabilité** vérifiée via casier B2. Pertes possibles pour condamnations graves liées au transport, à la finance ou aux mœurs.
> 8. **3 voies** pour obtenir la capacité : examen national, diplôme équivalent (Bac+2 transport), expérience (10 ans).

---

## 🎓 Ce que l'examinateur peut demander

1. **« Citez les 4 conditions d'accès à la profession. »** → Établissement, honorabilité, capacité financière, capacité professionnelle.
2. **« Quelle est la capacité financière pour 3 VUL ≤ 3,5 t ? »** → 1 800 + 2 × 900 = 3 600 €.
3. **« Combien de temps pour remplacer un gestionnaire qui démissionne ? »** → 6 mois maximum.
4. **« Quel document justifie l'honorabilité ? »** → Casier judiciaire B2.
5. **Cas en QR** : Décrire les démarches à effectuer pour s'inscrire au registre des transporteurs (4 conditions, pièces à fournir, ordre des étapes).

---

## 📋 Mémo à imprimer

```
4 CONDITIONS CUMULATIVES (règl. CE 1071/2009)
  1. Établissement réel et stable (locaux, véhicules, gestionnaire en France)
  2. Honorabilité professionnelle (casier B2 vierge)
  3. Capacité financière (voir tableau)
  4. Capacité professionnelle (attestation)

CAPACITÉ FINANCIÈRE
  ≤ 3,5 t : 1 800 € (1er) + 900 € par VUL suppl.
  > 3,5 t : 9 000 € (1er) + 5 000 € par véhicule suppl.

ATTESTATION DE CAPACITÉ
  Délivrance        Préfecture de région
  Validité          À vie (sauf retrait)
  Caractère         Personnelle (suit la personne)
  Voies d'accès     Examen / Diplôme Bac+2 transport / 10 ans expérience

GESTIONNAIRE DE TRANSPORT
  Titulaire de la capacité
  Responsable conformité
  1 obligatoire par entreprise
  Remplacement sous 6 mois max si départ
```
$lessonC2$,
'Maîtriser les 4 conditions cumulatives d''accès à la profession (règl. CE 1071/2009) : établissement, honorabilité, capacité financière (1800/900/9000/5000), capacité professionnelle.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Le contrat de transport et la lettre de voiture
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Le contrat de transport et la lettre de voiture',
    'contrat-transport-lettre-voiture',
    3, 60,
$lessonC3$
# Le contrat de transport et la lettre de voiture

> 🎯 **Objectifs pédagogiques**
>
> À la fin de cette leçon, vous serez capable de :
>
> - **Définir** le contrat de transport et identifier les 3 parties (expéditeur, transporteur, destinataire).
> - **Distinguer** contrat-type général et contrats-types spéciaux.
> - **Rédiger** une lettre de voiture conforme aux mentions obligatoires.
> - **Connaître** les règles de prise en charge, livraison et réserves.
> - **Comprendre** les responsabilités du transporteur et les limitations d'indemnisation.

---

## Introduction

Le contrat de transport est l'**acte juridique central** de votre activité quotidienne. À chaque livraison, vous signez (parfois implicitement) un contrat qui définit :

- Qui paie quoi.
- Quel est le délai promis.
- Qui est responsable en cas de perte ou avarie.
- Combien vous serez indemnisé en cas de litige.

Méconnaître ces règles, c'est s'exposer à des litiges où vous serez **systématiquement perdant**, soit parce que vous n'aurez pas posé les **réserves** au bon moment, soit parce que vous **dépasserez** les délais de prescription.

Cette leçon est très technique. Elle est essentielle pour répondre aux QR de l'examen national.

---

## 1. Le contrat de transport : définition et acteurs

### 1.1 Définition

> 📚 **Définition juridique**
>
> Le **contrat de transport** est la convention par laquelle un transporteur s'engage à déplacer une marchandise d'un lieu à un autre, en contrepartie d'un prix, dans un délai convenu.
>
> Il est régi par les articles **L. 132-1 à L. 133-9 du Code de commerce** (transports terrestres) et par les contrats-types prévus par décret.

### 1.2 Les 3 parties au contrat

| Partie | Rôle | Obligations principales |
|---|---|---|
| **Expéditeur** | Confie la marchandise au transporteur, paie ou fait payer le prix | Bien emballer, fournir lettre de voiture, payer si « port payé » |
| **Transporteur** | Effectue le transport | Prendre en charge dans l'état déclaré, livrer dans les délais, conserver l'intégrité |
| **Destinataire** | Reçoit la marchandise | Signer la lettre de voiture, poser des réserves, payer si « port dû » |

> ⚠️ **Attention examen**
>
> Le **destinataire** n'est **pas** partie au contrat à l'origine, mais il **devient partie** par un effet du contrat de transport en signant la lettre de voiture (mécanisme de la « **stipulation pour autrui** »).

### 1.3 Compte propre vs compte d'autrui

| Type | Définition | Réglementation |
|---|---|---|
| **Compte propre** | Une entreprise transporte sa propre marchandise (ex. boulanger qui livre ses pains) | Ni licence ni inscription registre transporteurs si véhicule de l'entreprise et marchandise lui appartenant |
| **Compte d'autrui** | Le transport est réalisé pour le compte d'un tiers, contre paiement | Inscription registre + licence DREAL OBLIGATOIRE dès 0,5 t |

---

## 2. Les contrats-types

### 2.1 Le contrat-type général

> 📚 **Définition**
>
> Le **contrat-type général** est un texte réglementaire (décret) qui s'applique automatiquement à tout transport routier de marchandises **lorsque les parties n'ont pas conclu de contrat écrit spécifique**.

| Caractéristique | Détail |
|---|---|
| Texte de référence | Décret n° 99-269 du 6 avril 1999 modifié |
| Principe | Application supplétive (en l'absence de contrat écrit) |
| Couvre | Conditions générales, prix, délais, responsabilité, indemnisation |

### 2.2 Les contrats-types spéciaux

D'autres contrats-types existent pour des activités spécifiques :

| Contrat-type | Couvre |
|---|---|
| **Messagerie / Express** | Envois ≤ 3 t, distribution rapide |
| **Location de véhicule avec conducteur** | Mise à disposition VUL + chauffeur |
| **Marchandises périssables** | Frigorifique, transport sous température dirigée |
| **Animaux vivants** | Transport spécifique |
| **Déménagement** | Particuliers et professionnels |
| **Sous-traitance** | Relations entre transporteurs principaux et sous-traitants |
| **Fonds et valeurs** | Convoyage de fonds |

> 💡 **Astuce métier**
>
> Si votre activité correspond à un **contrat-type spécial** (ex. messagerie pour un coursier express), c'est ce contrat qui s'applique en priorité, **avant** le contrat-type général. Vérifiez toujours quel est le texte applicable à votre cas.

---

## 3. La lettre de voiture

### 3.1 Définition et fonction

> 📚 **Définition**
>
> La **lettre de voiture** est le document qui matérialise le contrat de transport. Elle accompagne la marchandise pendant tout le trajet et est signée à la prise en charge (par le transporteur) puis à la livraison (par le destinataire).

**Trois fonctions principales :**

1. **Pièce justificative** du contrat de transport.
2. **Document de bord** obligatoire (en cas de contrôle).
3. **Pièce de réserve** : c'est sur la lettre de voiture que le destinataire pose ses réserves en cas d'avarie ou de manquant.

### 3.2 Mentions obligatoires (art. L. 132-9 C. com. et arrêté)

| # | Mention | Précision |
|---|---|---|
| 1 | Date et lieu d'établissement | Format jj/mm/aaaa |
| 2 | Nom et adresse de l'expéditeur | Identité complète |
| 3 | Nom et adresse du transporteur | Identité complète, mention SIRET |
| 4 | Nom et adresse du destinataire | Identité complète |
| 5 | Date et lieu de prise en charge | Au moment du chargement |
| 6 | Lieu prévu pour la livraison | Adresse précise |
| 7 | Désignation de la marchandise | Nature, conditionnement |
| 8 | Quantité, poids brut | Pour vérification |
| 9 | Prix du transport | HT et qui paie (« port payé » ou « port dû ») |
| 10 | Référence du contrat-type applicable | Si différent du contrat-type général |
| 11 | Mention « Port payé » ou « Port dû » | Désigne qui paie |

### 3.3 Cas pratique 1 — Document conforme

> 🚛 **Mise en situation**
>
> Vous transportez 4 palettes de fournitures de bureau de **Bureau-Plus SARL (Meaux)** vers **Reims-Distribution SAS (Reims)**. Total : 800 kg, prix 280 € HT, port payé par l'expéditeur.
>
> **Question :** quelles mentions impératives sur la lettre de voiture ?

**Correction (extrait essentiel) :**

```
LETTRE DE VOITURE n° 2026-018
Établie le 12/03/2026 à Meaux (77)

Expéditeur :
  Bureau-Plus SARL
  12 rue Pasteur, 77100 Meaux
  SIRET 893 456 789 00012

Transporteur :
  SARL Express77 (Capa SARL)
  8 av. de la Gare, 77100 Meaux
  SIRET 542 109 876 00021
  LTI n° xxx-xxxx

Destinataire :
  Reims-Distribution SAS
  3 rue du Commerce, 51100 Reims

Marchandise :
  4 palettes de fournitures de bureau (papier, classeurs)
  Poids brut : 800 kg
  Conditionnement : palettes EUR filmées

Prise en charge : 12/03/2026 à 8h30, locaux Bureau-Plus
Livraison prévue : 12/03/2026 entre 11h00 et 14h00, Reims

Prix HT : 280 €
TVA 20 % : 56 €
TTC : 336 €
PORT PAYÉ par l'expéditeur

Contrat-type général applicable (décret n° 99-269)

Émetteur (transporteur) : ___________________ (signature)
Réceptionné (expéditeur) : __________________ (signature, date, heure)
Livré (destinataire)     : __________________ (signature, date, heure, réserves)
```

### 3.4 Le triple original

La lettre de voiture est établie en **3 exemplaires** identiques :

| Exemplaire | Couleur (par convention) | Pour qui |
|---|---|---|
| 1er | Rouge | Expéditeur |
| 2e | Bleu | Destinataire (accompagne la marchandise) |
| 3e | Vert | Transporteur (conservé 5 ans pour archivage) |

> ⚠️ **Attention examen**
>
> Les couleurs (rouge / bleu / vert) sont des **conventions traditionnelles**, pas obligatoires juridiquement. Mais elles sont systématiquement testées en QCM. Mémorisez : Rouge = Expéditeur / Bleu = Destinataire / Vert = Transporteur.

---

## 4. Prise en charge, livraison, réserves

### 4.1 La prise en charge

Au chargement, le transporteur **doit** :

1. **Vérifier visuellement** l'état de la marchandise et l'emballage.
2. **Compter** les colis ou palettes.
3. **Si défaut visible** (emballage déchiré, palette de travers, marchandise tachée) : poser des **réserves écrites** sur la lettre de voiture.

**Sans réserves**, la marchandise est présumée prise en charge **en bon état**. Le transporteur sera **responsable** de tout dommage à la livraison.

### 4.2 La livraison

À la livraison, le destinataire **doit** :

1. **Vérifier** la marchandise au déchargement.
2. **Si avarie ou manquant visible** : poser des **réserves précises et motivées** sur la lettre de voiture.
3. **Signer** la lettre de voiture.

### 4.3 Les réserves : la pièce centrale du litige

> ⚠️ **Attention examen**
>
> Les réserves sont **vitales**. Sans réserves au moment de la livraison, ou sans confirmation par LRAR sous 3 jours pour les avaries non apparentes, **vous perdez tout recours** contre le transporteur (article L. 133-3 C. com.).

**Caractéristiques d'une réserve valable :**

| Caractère | Détail |
|---|---|
| **Précise** | « 2 cartons éventrés, contenu cassé » et non « marchandise abîmée » |
| **Motivée** | Décrire la cause apparente (chute, choc, mouille) |
| **Datée et signée** | Sur la lettre de voiture lors de la livraison |
| **Confirmée par LRAR** | Pour les **avaries non apparentes** (qui se révèlent après ouverture des colis), envoi sous **3 jours** |

### 4.4 Cas pratique 2 — Réserves

> 🚛 **Mise en situation**
>
> Vous livrez 12 cartons. Le destinataire signe la lettre de voiture **sans observations**. Le lendemain, en ouvrant les cartons en magasin, il découvre que **2 cartons** contiennent de la marchandise endommagée par humidité.
>
> **Question :** peut-il vous attaquer en responsabilité ?

**Correction :**

**Cela dépend de sa réactivité :**

- S'il **adresse une LRAR sous 3 jours** ouvrés à compter de la livraison, en motivant l'avarie non apparente (« humidité dans les cartons fermés »), il **conserve son recours**.
- S'il **dépasse le délai de 3 jours**, il **perd tout recours** (article L. 133-3 C. com.). La marchandise est réputée acceptée sans réserves.

**Votre intérêt en tant que transporteur** : tenir à jour vos lettres de voiture, archiver 5 ans, et opposer le délai de 3 jours en cas de litige tardif.

---

## 5. Responsabilité et indemnisation

### 5.1 Le principe : responsabilité de plein droit

> 📚 **Définition**
>
> Le transporteur est **responsable de plein droit** des avaries, manquants ou pertes survenus entre la prise en charge et la livraison (article L. 133-1 C. com.). Il est dispensé de toute faute à prouver par le créancier.

**Causes d'exonération :**

| Cause | Détail |
|---|---|
| **Force majeure** | Événement extérieur, imprévisible, irrésistible (tempête centennale, terrorisme) |
| **Vice propre** | Défaut intrinsèque de la marchandise (fruits qui pourrissent rapidement) |
| **Faute de l'expéditeur** | Mauvais emballage, étiquetage défectueux |
| **Faute du destinataire** | Refus de prise en charge, retard volontaire |

### 5.2 La limite d'indemnisation

| Type de transport | Limite (par kg de marchandise endommagée) |
|---|---|
| **Marchandises générales (national)** | **23 € / kg** (contrat-type général) |
| **Marchandises générales (international CMR)** | **8,33 DTS / kg** (≈ 10 € / kg) |
| **Messagerie express** | Plafond par envoi (~ 750 € selon contrat-type) |
| **Déménagement** | Limites spécifiques par contrat-type |

> ⚠️ **Attention examen**
>
> Le seuil de **23 €/kg** en transport national est **typique du contrat-type général**. Vous pouvez augmenter cette limite par contrat écrit avec déclaration de valeur (l'expéditeur paie alors une **prime ad valorem** pour cette extension).

### 5.3 Mini-exercice guidé

> ✏️ **À vous**
>
> Vous transportez 1 palette de 350 kg de pièces auto valant **8 000 €**. Pendant le transport, la palette tombe et la moitié est détruite. Le destinataire pose des réserves à temps.
>
> Quel est le montant maximum d'indemnisation que vous (en tant que transporteur) devrez payer, sous le contrat-type général ?

**Correction :**

- Marchandise endommagée : 350 kg × 50 % = **175 kg**.
- Limite contractuelle : 175 × 23 € = **4 025 €** maximum d'indemnisation.
- Valeur réelle perdue : 8 000 × 50 % = 4 000 €.

→ Dans ce cas, la limite de 4 025 € **couvre quasiment** la perte. Mais sur une marchandise plus chère (matériel électronique, bijoux), la limite serait largement dépassée. **Conseil au client** : déclaration de valeur écrite + prime ad valorem.

---

## 6. Glossaire des notions clés

| Terme | Définition |
|---|---|
| **Contrat de transport** | Convention par laquelle un transporteur s'engage à déplacer une marchandise contre paiement |
| **Expéditeur** | Personne qui remet la marchandise au transporteur |
| **Destinataire** | Personne qui reçoit la marchandise à la livraison |
| **Compte propre** | Transport pour soi-même (pas de licence DREAL) |
| **Compte d'autrui** | Transport pour un tiers contre paiement (licence obligatoire) |
| **Contrat-type général** | Décret 99-269, applicable en l'absence de contrat écrit |
| **Lettre de voiture** | Document matérialisant le contrat de transport |
| **Triple original** | Lettre de voiture en 3 exemplaires (rouge / bleu / vert) |
| **Réserves** | Mention écrite des avaries lors de la livraison |
| **LRAR sous 3 jours** | Délai pour confirmer des avaries non apparentes |
| **23 €/kg** | Limite d'indemnisation contrat-type général transport national |
| **Force majeure** | Cause d'exonération de la responsabilité |

---

## 🧠 Synthèse opérationnelle

> 📌 **Les 8 points à retenir**
>
> 1. **3 parties** au contrat de transport : expéditeur, transporteur, destinataire (qui devient partie en signant).
> 2. **Compte propre** = pas de licence ; **compte d'autrui** = licence DREAL obligatoire dès 0,5 t.
> 3. **Contrat-type général** (décret 99-269) s'applique en l'absence de contrat écrit.
> 4. **Lettre de voiture** = document obligatoire en 3 exemplaires : Rouge expéditeur / Bleu destinataire / Vert transporteur.
> 5. **Réserves** au moment de la livraison + **LRAR sous 3 jours** pour les avaries non apparentes — sinon perte de recours.
> 6. Transporteur **responsable de plein droit** des avaries entre prise en charge et livraison (art. L. 133-1).
> 7. **Causes d'exonération** : force majeure, vice propre, faute expéditeur, faute destinataire.
> 8. **Limite d'indemnisation** contrat-type général : **23 €/kg** en transport national, 8,33 DTS/kg en international (CMR).

---

## 🎓 Ce que l'examinateur peut demander

1. **« Citez les 3 parties au contrat de transport. »** → Expéditeur, transporteur, destinataire.
2. **« Quelle est la limite d'indemnisation par kg dans le contrat-type général ? »** → 23 €/kg en national.
3. **« Délai pour confirmer une avarie non apparente ? »** → 3 jours par LRAR.
4. **« Quelles sont les couleurs des 3 exemplaires de la lettre de voiture ? »** → Rouge expéditeur, bleu destinataire, vert transporteur.
5. **Cas en QR** : Calculer une indemnité (kg × 23 €), ou décrire la procédure de réserve en cas d'avarie partielle.

---

## 📋 Mémo à imprimer

```
3 PARTIES AU CONTRAT
  Expéditeur ─→ Transporteur ─→ Destinataire

LETTRE DE VOITURE (triple original)
  Rouge    → Expéditeur
  Bleu     → Destinataire (accompagne la marchandise)
  Vert     → Transporteur (conservation 5 ans)

RÉSERVES
  À la livraison        → écrites, précises, motivées sur lettre de voiture
  Avaries non apparentes → LRAR sous 3 JOURS

INDEMNISATION (contrat-type général)
  National        → 23 €/kg
  International   → 8,33 DTS/kg (≈ 10 €/kg) — CMR

EXONÉRATIONS
  Force majeure / Vice propre / Faute expéditeur / Faute destinataire

PRESCRIPTION ACTION TRANSPORT
  1 an à compter de la livraison (art. L. 133-6 C. com.)
```
$lessonC3$,
'Comprendre le contrat de transport (3 parties), maîtriser la lettre de voiture (triple original), poser les réserves dans les délais, connaître la responsabilité de plein droit et la limite 23 €/kg.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Contrats spéciaux et assurances
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Contrats spéciaux et assurances',
    'contrats-speciaux-assurances',
    4, 60,
$lessonC4$
# Contrats spéciaux et assurances

> 🎯 **Objectifs pédagogiques**
>
> À la fin de cette leçon, vous serez capable de :
>
> - **Choisir** le bon contrat-type selon votre activité (général, messagerie, sous-traitance, location, déménagement).
> - **Distinguer** sous-traitance et location de véhicule avec conducteur.
> - **Identifier** les assurances obligatoires en transport (RC circulation, RC contractuelle).
> - **Comparer** les assurances marchandises ad valorem et de chose.
> - **Souscrire** une protection juridique adaptée.

---

## Introduction

Au-delà du contrat-type général vu à la leçon précédente, le transport routier comporte **plusieurs contrats spéciaux** que vous devrez identifier selon votre activité concrète. Le bon choix conditionne :

- Vos **obligations** (responsabilité, délai, indemnisation).
- Le **prix** que vous pouvez facturer.
- Le **niveau de risque** que vous acceptez.

Parallèlement, les **assurances** sont à la fois une obligation légale (RC circulation) et un levier commercial (sécurité offerte au client). Cette leçon vous donne les clés pour **structurer** votre couverture.

---

## 1. Le contrat de location avec conducteur

### 1.1 Définition

> 📚 **Définition**
>
> Le **contrat de location avec conducteur** consiste à mettre à disposition d'un client un **véhicule + un chauffeur** pour une durée déterminée ou indéterminée, sans que le transporteur ait à exécuter une prestation de transport spécifique.

**Différence avec le contrat de transport :**

| Critère | Contrat de transport | Location avec conducteur |
|---|---|---|
| **Objet** | Déplacement d'une marchandise d'un point A à un point B | Mise à disposition d'un VUL + chauffeur |
| **Tarification** | Au km, à la tonne, à la palette, forfait | À l'heure, à la demi-journée, à la journée |
| **Donneur d'ordre** | Définit l'origine et la destination | Dirige les opérations en temps réel |
| **Responsabilité avarie** | Transporteur responsable de plein droit | Souvent partagée selon directives client |

### 1.2 Cas d'usage

| Cas | Contrat-type adapté |
|---|---|
| Coursier express ponctuel | Contrat de transport (messagerie) |
| Mise à disposition d'un VUL + chauffeur pour une journée pour un déménagement particulier | Location avec conducteur |
| Tournées B2B récurrentes mensuelles | Contrat de transport sur abonnement |

### 1.3 Cas pratique 1 — Choisir le bon contrat

> 🚛 **Mise en situation**
>
> Une boutique de meubles vous demande de fournir un VUL + chauffeur tous les samedis matin (8h-13h) pour effectuer les livraisons aux particuliers. Vous suivez les indications du gérant en magasin, qui vous donne la liste des adresses et l'ordre de tournée le matin même.
>
> **Question :** quel contrat est applicable ?

**Correction :**

**Location avec conducteur**, parce que :

1. Le client définit en temps réel les opérations.
2. Vous facturez à la **demi-journée** (5 heures) et non à la palette/tonne.
3. Le donneur d'ordre supervise directement votre activité.

**Conséquences :**

- La responsabilité avarie peut être partiellement transférée au donneur d'ordre s'il est démontré que ses directives ont causé le dommage.
- Vous facturez avec un **tarif horaire** (~ 35-50 €/h en VUL + chauffeur en province).
- Le contrat-type spécifique « location de véhicule industriel avec conducteur » s'applique.

---

## 2. Le contrat de sous-traitance

### 2.1 Définition

> 📚 **Définition**
>
> La **sous-traitance** est l'opération par laquelle un transporteur principal confie tout ou partie d'un transport à un autre transporteur (sous-traitant), tout en conservant la responsabilité contractuelle vis-à-vis du donneur d'ordre.

**Schéma simplifié :**

```
Donneur d'ordre  ←→  Transporteur principal  ←→  Sous-traitant
  (Client)            (= Commissionnaire)        (= Vous, parfois)
```

### 2.2 Le contrat-type sous-traitance

Le décret n° 2003-1295 du 26 décembre 2003 fixe les règles. Points-clés :

| Règle | Contenu |
|---|---|
| **Identification du sous-traitant** | Le transporteur principal **doit** vérifier la licence du sous-traitant et la conserver |
| **Délai de paiement** | 30 jours date de facture maximum (LME) |
| **Pas de cascade illimitée** | La sous-traitance « rang 2 » est encadrée ; au-delà rare et soumise à information du donneur d'ordre |
| **Indices CNR** | Révision du prix possible si hausse > 5 % du gazole sur la période |

### 2.3 Cas pratique 2 — Sous-traitance

> 🚛 **Mise en situation**
>
> Vous (SARL Express77) êtes contacté par **Logistique Plus**, un commissionnaire qui vous propose 3 livraisons hebdomadaires sur Reims pour un client final que vous ne connaîtrez jamais. Tarif : 90 €/livraison, paiement à 45 jours.
>
> **Question :** que vérifier avant de signer ?

**Correction :**

1. **Licence de Logistique Plus** : commissionnaire valide ? Capacité financière à jour ? (Pappers, vérification DREAL)
2. **Solvabilité** : combien de salariés ? Quel CA ? Procédure collective éventuelle ?
3. **Délai de paiement** : 45 jours = **illégal en transport** (max 30 j date de facture art. L. 441-11). À renégocier obligatoirement.
4. **Clause de révision** : Si le gazole augmente, la grille tarifaire est-elle indexée sur le CNR ?
5. **Préavis de rupture** : si Logistique Plus rompt brutalement le contrat après 6 mois, quelle indemnité ?
6. **Vérifier régulièrement** : conserver les preuves de bon exécution (lettres de voiture signées) pour faire face à un éventuel litige.

---

## 3. Le contrat-type messagerie / express

### 3.1 Spécificité

Le contrat-type messagerie s'applique aux envois ≤ 3 t avec une promesse de **délai court** (24 à 72 h selon les sociétés).

| Caractéristique | Détail |
|---|---|
| Volumétrie | Envois ≤ 3 t par expédition |
| Délai standard | J+1 ou J+2 généralement |
| Limite d'indemnisation | Plafond par envoi : ~ 750 € (à confirmer selon édition récente) |
| Marquage | Étiquetage spécifique avec code-barres |
| Suivi | Tracking numérique requis |

### 3.2 Variantes

- **Express** : J+1 garanti, parfois avant-midi.
- **Économique** : J+3 à J+5, prix réduit.
- **International / monocolis** : règles UPS-style.

---

## 4. Le contrat-type déménagement

Réservé au transport de mobilier et effets personnels (B2C principalement). Encadre :

| Aspect | Règle |
|---|---|
| Devis | Obligatoire avant prestation |
| Lettre de voiture | « **Lettre de voiture déménagement** » spécifique (avec inventaire détaillé) |
| Indemnisation | Selon valeur déclarée par le client (déclaration de valeur sur l'inventaire) |
| Réserves | Vérification contradictoire à la livraison, signature de la « **fiche réception** » |

> 💡 **Astuce métier**
>
> Le déménagement de particuliers (B2C) est **très rentable** mais **réglementairement risqué** (très nombreux litiges sur les avaries). Une assurance ad valorem dédiée est quasi indispensable.

---

## 5. Les assurances en transport routier

### 5.1 Tableau synthétique

| Assurance | Caractère | Couverture | Prime annuelle indicative |
|---|---|---|---|
| **RC circulation** | OBLIGATOIRE | Dommages causés à des tiers (autre véhicule, piéton, biens) lors de la circulation | 1 200 à 2 500 €/véhicule |
| **RC contractuelle (RCM)** | Obligatoire en pratique pour exercer | Responsabilité du transporteur sur les marchandises pendant le transport | 800 à 1 500 €/an pour 1 VUL |
| **Marchandises ad valorem** | Optionnelle | Couvre la valeur réelle de la marchandise transportée (dépasse les 23 €/kg) | Variable, % de la valeur |
| **Marchandises de chose** | Optionnelle | Forfait par sinistre | Variable |
| **Protection juridique** | Recommandée | Frais d'avocat en cas de litige (recouvrement, sanctions DREAL) | 200 à 500 €/an |
| **Vol / incendie / bris de glace VUL** | Recommandée | Protection du véhicule | Comprise dans la RC tous risques |
| **Multirisque pro** | Recommandée | Protection des locaux, matériel, marchandise stockée | 600 à 1 200 €/an selon volume |

### 5.2 La RC circulation : seul fait obligatoire

Tout véhicule à moteur en France **doit** être couvert par une **assurance responsabilité civile circulation** (article L. 211-1 du Code des assurances). Elle couvre :

- Les dommages corporels causés à des tiers.
- Les dommages matériels (autres véhicules, biens).

**Sanctions** en l'absence de RC circulation :

- 3 750 € d'amende.
- Suspension de permis.
- Confiscation possible du véhicule.
- Aucune indemnisation pour les dommages causés.

### 5.3 La RC contractuelle (RC marchandises)

Couvre la responsabilité du transporteur **vis-à-vis du donneur d'ordre** pour les avaries, manquants, retards survenus entre la prise en charge et la livraison.

**Sans RCM**, vous restez **personnellement** responsable de l'indemnisation : un seul sinistre lourd peut vous mettre en faillite.

> ⚠️ **Attention examen**
>
> La **RC circulation** couvre les **tiers** (piéton, autre véhicule). La **RC contractuelle / marchandises** couvre la **marchandise transportée**. Ce sont **deux contrats distincts** : ne les confondez pas en QCM.

### 5.4 L'assurance ad valorem

L'**ad valorem** (latin : « selon la valeur ») couvre la valeur réelle déclarée de la marchandise, **au-delà** de la limite de 23 €/kg du contrat-type général.

**Mécanisme :**

1. Le client déclare la valeur de la marchandise (ex. 50 000 €).
2. Vous payez une **prime ad valorem** à votre assureur (typiquement 0,1 à 0,3 % de la valeur).
3. Vous facturez cette prime au client (avec une marge éventuelle).
4. En cas de sinistre, l'indemnisation peut atteindre **la valeur déclarée**.

### 5.5 Cas pratique 3 — Choisir une couverture

> 🚛 **Mise en situation**
>
> Vous démarrez une activité de coursier urbain à Lyon avec **1 VUL ≤ 3,5 t**. Vous prévoyez de transporter régulièrement du **matériel électronique** valant entre **5 000 et 30 000 €** par envoi.
>
> **Question :** quelles assurances souscrire en priorité ?

**Correction proposée :**

| Assurance | Recommandation | Justification |
|---|---|---|
| RC circulation | OBLIGATOIRE | Sans elle, vous ne pouvez même pas circuler |
| RC contractuelle (RCM) | OBLIGATOIRE en pratique | Couverture des avaries / vols / pertes pendant le transport. Sinon, vous payez de votre poche en cas de sinistre |
| Marchandises ad valorem | RECOMMANDÉE | Vos colis dépassent la limite 23 €/kg. Pour 30 000 € sur 50 kg : limite contrat-type = 1 150 € seulement, donc 28 850 € à votre charge sans ad valorem |
| Vol VUL + tous risques | OBLIGATOIRE en pratique | Protection du véhicule et anti-vol marchandise stationnée |
| Protection juridique | RECOMMANDÉE | Pour gérer les litiges avec clients |

**Coût total estimatif** : 3 000 à 5 000 €/an pour 1 VUL avec activité haut de gamme.

---

## 6. Glossaire des notions clés

| Terme | Définition |
|---|---|
| **Location avec conducteur** | Mise à disposition VUL + chauffeur, tarif horaire/journalier |
| **Sous-traitance** | Confier un transport à un autre transporteur tout en restant responsable |
| **Commissionnaire de transport** | Organise le transport pour le compte d'autrui en faisant appel à des transporteurs (rang 1, rang 2) |
| **Contrat-type messagerie** | Pour envois ≤ 3 t avec délai court |
| **Contrat-type déménagement** | Pour mobilier et effets personnels |
| **RC circulation** | Assurance OBLIGATOIRE véhicule, couvre les tiers |
| **RC contractuelle (RCM)** | Assurance des marchandises transportées vis-à-vis du donneur d'ordre |
| **Ad valorem** | Assurance selon la valeur déclarée de la marchandise |
| **Multirisque pro** | Couverture locaux + matériel + marchandise stockée |
| **Protection juridique** | Couverture des frais d'avocat en cas de litige |

---

## 🧠 Synthèse opérationnelle

> 📌 **Les 8 points à retenir**
>
> 1. **Location avec conducteur** ≠ contrat de transport : pas de marchandise spécifique, mise à disposition VUL + chauffeur, tarif horaire.
> 2. **Sous-traitance** : transporteur principal reste responsable vis-à-vis du donneur d'ordre. Vérifier la licence du sous-traitant.
> 3. **Délai paiement transport** : **30 jours date de facture** max (art. L. 441-11), même en sous-traitance.
> 4. **RC circulation** = OBLIGATOIRE (tout véhicule). Couvre les **tiers**.
> 5. **RC contractuelle (RCM)** = obligatoire en pratique pour exercer. Couvre les **marchandises transportées**.
> 6. **Ad valorem** = optionnelle, couvre la valeur réelle déclarée. Indispensable pour matériel cher.
> 7. **Limite contrat-type général** : **23 €/kg** national. Au-delà : ad valorem.
> 8. **Protection juridique** : recommandée pour gérer les litiges (recouvrement, sanctions).

---

## 🎓 Ce que l'examinateur peut demander

1. **« Différence entre RC circulation et RC marchandises ? »** → RC circulation = tiers. RC marchandises = marchandise transportée.
2. **« Quelle assurance est obligatoire en transport ? »** → RC circulation seule est obligatoire au sens strict. La RCM est obligatoire en pratique pour exercer.
3. **« Qu'est-ce que l'ad valorem ? »** → Assurance selon la valeur déclarée, au-delà du forfait du contrat-type.
4. **« Différence sous-traitance / location avec conducteur ? »** → Sous-traitance = je confie un transport à un autre transporteur. Location = je mets à disposition mon VUL + chauffeur sous direction du client.
5. **Cas en QR** : Décrire une couverture d'assurances complète pour un projet de transport spécifique.

---

## 📋 Mémo à imprimer

```
CONTRATS-TYPES À CONNAÎTRE
  Contrat-type général         → décret 99-269, applicable par défaut
  Contrat-type messagerie      → envois ≤ 3 t, délai court
  Contrat-type déménagement    → mobilier B2C
  Contrat-type location        → VUL + chauffeur à l'heure/jour
  Contrat-type sous-traitance  → décret 2003-1295

ASSURANCES
  RC circulation       → OBLIGATOIRE, couvre les TIERS
  RC contractuelle     → couvre la MARCHANDISE TRANSPORTÉE
                        (obligatoire en pratique pour exercer)
  Ad valorem           → selon valeur déclarée (au-delà de 23 €/kg)
  Multirisque pro      → locaux + matériel + stock
  Protection juridique → recommandée

PRIME INDICATIVE
  RC circulation 1 VUL : 1 200 à 2 500 €/an
  RCM 1 VUL            : 800 à 1 500 €/an
  Total assurances 1 VUL : 3 000 à 5 000 €/an
```
$lessonC4$,
'Maîtriser les contrats-types spéciaux (messagerie, location, sous-traitance, déménagement) et les assurances (RC circulation, RC contractuelle, ad valorem, protection juridique).'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- BANQUE DE QCM REFORMULÉS — Module C (48 questions, 12 par leçon)
  -- =================================================================

  -- ─── LEÇON 1 — Organisation profession (12 QCM) ───
  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qcm', 'Que signifie l''acronyme DREAL ?',
   '[{"id":"a","label":"Direction Régionale de l''Environnement, de l''Aménagement et du Logement","is_correct":true},{"id":"b","label":"Direction Régionale des Études et de l''Aménagement Local","is_correct":false},{"id":"c","label":"Délégation Régionale aux Entreprises et à l''Administration Locale","is_correct":false},{"id":"d","label":"Direction Régionale des Examens et de l''Apprentissage Logistique","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-c','capa-3-5t','lecon-1','dreal'], 'mft-2026:moduleC:qcm:1', true,
   'DREAL = Direction Régionale de l''Environnement, de l''Aménagement et du Logement. Service déconcentré de l''État, votre interlocuteur principal pour licences, capacité, contrôles.'),

  (v_formation, 'qcm', 'Qui délivre la Licence de Transport Intérieur (LTI) ?',
   '[{"id":"a","label":"Le ministère des Transports à Paris","is_correct":false},{"id":"b","label":"La DREAL régionale","is_correct":true},{"id":"c","label":"La préfecture du département","is_correct":false},{"id":"d","label":"Le greffe du tribunal de commerce","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-c','capa-3-5t','lecon-1','lti'], 'mft-2026:moduleC:qcm:2', true,
   'La LTI est délivrée par la DREAL régionale après vérification des 4 conditions d''accès à la profession.'),

  (v_formation, 'qcm', 'Que signifie l''acronyme DGITM ?',
   '[{"id":"a","label":"Direction Générale des Impôts et des Taxes Maritimes","is_correct":false},{"id":"b","label":"Direction Générale des Infrastructures, des Transports et des Mobilités","is_correct":true},{"id":"c","label":"Délégation Générale à l''Information sur le Transport Multimodal","is_correct":false},{"id":"d","label":"Direction de Gestion des Inspections du Transport et des Marchandises","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-c','capa-3-5t','lecon-1','dgitm'], 'mft-2026:moduleC:qcm:3', true,
   'DGITM = administration centrale du ministère des Transports. Pilote la politique nationale, élabore les textes réglementaires.'),

  (v_formation, 'qcm', 'Le CRSR (Conseil Régional Supérieur de la Réglementation des Transports) est :',
   '[{"id":"a","label":"Une juridiction qui rend des jugements définitifs","is_correct":false},{"id":"b","label":"Une instance consultative régionale présidée par le préfet","is_correct":true},{"id":"c","label":"Un syndicat de salariés","is_correct":false},{"id":"d","label":"Une assurance obligatoire","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-c','capa-3-5t','lecon-1','crsr'], 'mft-2026:moduleC:qcm:4', true,
   'Le CRSR est un conseil consultatif présidé par le préfet de région. Il regroupe administration, profession, syndicats. Il émet un avis sur les sanctions importantes.'),

  (v_formation, 'qcm', 'Parmi ces organisations, laquelle est une fédération PATRONALE du transport routier en France ?',
   '[{"id":"a","label":"FNTR","is_correct":true},{"id":"b","label":"CGT-Transport","is_correct":false},{"id":"c","label":"Force Ouvrière","is_correct":false},{"id":"d","label":"CFDT","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-c','capa-3-5t','lecon-1','fntr'], 'mft-2026:moduleC:qcm:5', true,
   'FNTR = Fédération Nationale des Transports Routiers. Organisation patronale historique, la plus large. CGT-Transport, FO, CFDT sont des syndicats de salariés.'),

  (v_formation, 'qcm', 'L''accord du 8 février 2008 (« ACT 8 ») porte sur :',
   '[{"id":"a","label":"La fixation du prix du transport","is_correct":false},{"id":"b","label":"La modernisation du temps de travail dans le TRM","is_correct":true},{"id":"c","label":"Les seuils de capacité financière","is_correct":false},{"id":"d","label":"Les couleurs de la lettre de voiture","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-c','capa-3-5t','lecon-1','act-8'], 'mft-2026:moduleC:qcm:6', true,
   'L''accord du 8 février 2008 modernise la durée du travail dans le transport routier de marchandises (équivalences, majorations, frais de déplacement).'),

  (v_formation, 'qcm', 'La convention collective applicable au TRM est :',
   '[{"id":"a","label":"La CCN du commerce","is_correct":false},{"id":"b","label":"La CCN des transports routiers (CCNTR)","is_correct":true},{"id":"c","label":"La CCN de la métallurgie","is_correct":false},{"id":"d","label":"Aucune, il n''y en a pas","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-c','capa-3-5t','lecon-1','ccntr'], 'mft-2026:moduleC:qcm:7', true,
   'CCNTR = Convention Collective Nationale des Transports Routiers et activités auxiliaires. Couvre TRM, TRV, location, logistique.'),

  (v_formation, 'qcm', 'Le BOTRA est :',
   '[{"id":"a","label":"Un syndicat patronal","is_correct":false},{"id":"b","label":"Le Bulletin Officiel des Transports","is_correct":true},{"id":"c","label":"Un site de comparaison de prix","is_correct":false},{"id":"d","label":"Une formation continue obligatoire","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-c','capa-3-5t','lecon-1','botra'], 'mft-2026:moduleC:qcm:8', true,
   'BOTRA = Bulletin Officiel des Transports. Publication hebdomadaire des décisions ministérielles, arrêtés et circulaires liés au secteur.'),

  (v_formation, 'qcm', 'Pour trouver le texte officiel d''un décret transport, le site de référence est :',
   '[{"id":"a","label":"Wikipedia","is_correct":false},{"id":"b","label":"Legifrance.gouv.fr","is_correct":true},{"id":"c","label":"Le Bon Coin","is_correct":false},{"id":"d","label":"Le site de la SNCF","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-c','capa-3-5t','lecon-1','sources'], 'mft-2026:moduleC:qcm:9', true,
   'Legifrance.gouv.fr = base officielle (et gratuite) des textes français : codes, lois, décrets, circulaires.'),

  (v_formation, 'qcm', 'Que signifie OTRE ?',
   '[{"id":"a","label":"Office de la Transition Routière Européenne","is_correct":false},{"id":"b","label":"Organisation des Transporteurs Routiers Européens","is_correct":true},{"id":"c","label":"Outils Techniques pour Routiers Expérimentés","is_correct":false},{"id":"d","label":"Observatoire du Transport Routier en Europe","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-c','capa-3-5t','lecon-1','otre'], 'mft-2026:moduleC:qcm:10', true,
   'OTRE = Organisation des Transporteurs Routiers Européens. Fédération patronale plus jeune que la FNTR, plus militante, ciblée TPE/PME indépendantes.'),

  (v_formation, 'qcm', 'La CCT (Commission des Sanctions Administratives) :',
   '[{"id":"a","label":"Examine les sanctions disciplinaires des transporteurs","is_correct":true},{"id":"b","label":"Vend des cartes de tachygraphe","is_correct":false},{"id":"c","label":"Recrute les chauffeurs en CDI","is_correct":false},{"id":"d","label":"Fixe le prix du gazole","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-c','capa-3-5t','lecon-1','cct'], 'mft-2026:moduleC:qcm:11', true,
   'La CCT examine les dossiers de sanctions disciplinaires (suspension, retrait de capacité, interdiction temporaire). Présidée par un magistrat administratif.'),

  (v_formation, 'qcm', 'Quel est le code juridique principal qui régit le transport routier en France ?',
   '[{"id":"a","label":"Le Code civil","is_correct":false},{"id":"b","label":"Le Code des transports","is_correct":true},{"id":"c","label":"Le Code rural","is_correct":false},{"id":"d","label":"Le Code de la défense","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-c','capa-3-5t','lecon-1','code-transports'], 'mft-2026:moduleC:qcm:12', true,
   'Le Code des transports rassemble en 8 livres l''ensemble des règles applicables au transport (terrestre, maritime, aérien, fluvial). Pour le routier, voir notamment le livre I.'),

  -- ─── LEÇON 2 — Conditions d'accès (12 QCM) ───
  (v_formation, 'qcm', 'Combien de conditions cumulatives doit remplir un transporteur pour exercer ?',
   '[{"id":"a","label":"2","is_correct":false},{"id":"b","label":"3","is_correct":false},{"id":"c","label":"4","is_correct":true},{"id":"d","label":"6","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-c','capa-3-5t','lecon-2','conditions-acces'], 'mft-2026:moduleC:qcm:13', true,
   '4 conditions cumulatives (règl. CE 1071/2009) : établissement réel et stable, honorabilité professionnelle, capacité financière, capacité professionnelle. Toutes doivent être remplies SIMULTANÉMENT.'),

  (v_formation, 'qcm', 'La capacité financière exigée pour le 1er VUL ≤ 3,5 t est de :',
   '[{"id":"a","label":"900 €","is_correct":false},{"id":"b","label":"1 800 €","is_correct":true},{"id":"c","label":"5 400 €","is_correct":false},{"id":"d","label":"9 000 €","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-c','capa-3-5t','lecon-2','capacite-financiere'], 'mft-2026:moduleC:qcm:14', true,
   '1 800 € pour le 1er VUL ≤ 3,5 t. Puis 900 € par VUL supplémentaire de la même catégorie. À comparer avec 9 000 € pour le 1er > 3,5 t.'),

  (v_formation, 'qcm', 'Pour 4 VUL ≤ 3,5 t, la capacité financière totale exigée est de :',
   '[{"id":"a","label":"1 800 €","is_correct":false},{"id":"b","label":"3 600 €","is_correct":false},{"id":"c","label":"4 500 €","is_correct":true},{"id":"d","label":"7 200 €","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-c','capa-3-5t','lecon-2','capacite-financiere','calcul'], 'mft-2026:moduleC:qcm:15', true,
   '1 800 € (1er) + 3 × 900 € (suppl.) = 1 800 + 2 700 = 4 500 €.'),

  (v_formation, 'qcm', 'L''honorabilité professionnelle est vérifiée par la DREAL via :',
   '[{"id":"a","label":"Un test d''aptitude physique","is_correct":false},{"id":"b","label":"L''extrait de casier judiciaire B2","is_correct":true},{"id":"c","label":"Un examen de conduite","is_correct":false},{"id":"d","label":"Un audit comptable","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-c','capa-3-5t','lecon-2','honorabilite'], 'mft-2026:moduleC:qcm:16', true,
   'Casier B2 = extrait spécifique destiné aux administrations. Demandé par la DREAL au Casier judiciaire national de Nantes.'),

  (v_formation, 'qcm', 'Combien de temps une entreprise dispose-t-elle pour remplacer son gestionnaire de transport en cas de départ ?',
   '[{"id":"a","label":"1 mois","is_correct":false},{"id":"b","label":"3 mois","is_correct":false},{"id":"c","label":"6 mois","is_correct":true},{"id":"d","label":"12 mois","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-c','capa-3-5t','lecon-2','gestionnaire-transport'], 'mft-2026:moduleC:qcm:17', true,
   '6 mois maximum. Au-delà, suspension automatique de la licence. À anticiper par recrutement ou désignation d''un capacitaire externe.'),

  (v_formation, 'qcm', 'L''attestation de capacité professionnelle est :',
   '[{"id":"a","label":"Personnelle et valide à vie","is_correct":true},{"id":"b","label":"Liée à l''entreprise et renouvelée tous les 10 ans","is_correct":false},{"id":"c","label":"Délivrée par le maire","is_correct":false},{"id":"d","label":"Achetable contre 500 €","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-c','capa-3-5t','lecon-2','attestation-capacite'], 'mft-2026:moduleC:qcm:18', true,
   'Personnelle (suit la personne, pas l''entreprise) et à vie sauf retrait disciplinaire. La licence (LTI) en revanche est liée à l''entreprise et renouvelée tous les 10 ans.'),

  (v_formation, 'qcm', 'Quel établissement est exigé pour exercer en France ?',
   '[{"id":"a","label":"Une simple boîte postale","is_correct":false},{"id":"b","label":"Un établissement réel et stable avec locaux, véhicules, gestionnaire","is_correct":true},{"id":"c","label":"Un domicile à l''étranger","is_correct":false},{"id":"d","label":"Aucune obligation territoriale","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-c','capa-3-5t','lecon-2','etablissement'], 'mft-2026:moduleC:qcm:19', true,
   'Établissement réel et stable (article 5 règl. 1071/2009) : locaux où sont conservés les documents pro, parc de véhicules, présence du gestionnaire. Une boîte postale ne suffit pas.'),

  (v_formation, 'qcm', 'Un Bac+2 transport (DUT GLT, BTS transport-logistique) permet :',
   '[{"id":"a","label":"D''obtenir l''attestation de capacité professionnelle directement","is_correct":true},{"id":"b","label":"De devenir transporteur sans formation","is_correct":false},{"id":"c","label":"D''être exempté des obligations DREAL","is_correct":false},{"id":"d","label":"De réduire les cotisations URSSAF","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-c','capa-3-5t','lecon-2','attestation-capacite','equivalence'], 'mft-2026:moduleC:qcm:20', true,
   'Un diplôme Bac+2 transport vaut équivalence à l''attestation de capacité (3 voies d''accès : examen, diplôme équivalent, expérience 10 ans).'),

  (v_formation, 'qcm', 'Pour > 3,5 t, la capacité financière du 1er véhicule est de :',
   '[{"id":"a","label":"1 800 €","is_correct":false},{"id":"b","label":"5 000 €","is_correct":false},{"id":"c","label":"9 000 €","is_correct":true},{"id":"d","label":"15 000 €","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-c','capa-3-5t','lecon-2','capacite-financiere'], 'mft-2026:moduleC:qcm:21', true,
   '9 000 € pour le 1er véhicule > 3,5 t, puis 5 000 € par véhicule supplémentaire de la même catégorie.'),

  (v_formation, 'qcm', 'Le règlement européen qui fixe les conditions d''accès à la profession est :',
   '[{"id":"a","label":"CE 561/2006","is_correct":false},{"id":"b","label":"CE 1071/2009","is_correct":true},{"id":"c","label":"UE 2018/858","is_correct":false},{"id":"d","label":"CE 1031/2019","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-c','capa-3-5t','lecon-2','reglementation'], 'mft-2026:moduleC:qcm:22', true,
   'Le règl. CE 1071/2009 (transposé en France en 2011) harmonise les 4 conditions d''accès dans toute l''UE. CE 561/2006 concerne les temps de conduite.'),

  (v_formation, 'qcm', 'Le gestionnaire de transport est :',
   '[{"id":"a","label":"Un salarié obligatoirement recruté en CDI","is_correct":false},{"id":"b","label":"La personne titulaire de la capacité, responsable de la conformité","is_correct":true},{"id":"c","label":"Un agent de la DREAL en interne","is_correct":false},{"id":"d","label":"Un avocat spécialisé","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-c','capa-3-5t','lecon-2','gestionnaire-transport'], 'mft-2026:moduleC:qcm:23', true,
   'Le gestionnaire de transport est la personne titulaire de la capacité, désignée comme responsable réglementaire dans l''entreprise. Peut être interne (gérant) ou externe (consultant).'),

  (v_formation, 'qcm', 'Combien de capitaux propres faut-il justifier pour 2 véhicules > 3,5 t ?',
   '[{"id":"a","label":"9 000 €","is_correct":false},{"id":"b","label":"14 000 €","is_correct":true},{"id":"c","label":"18 000 €","is_correct":false},{"id":"d","label":"45 000 €","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-c','capa-3-5t','lecon-2','capacite-financiere','calcul'], 'mft-2026:moduleC:qcm:24', true,
   '9 000 € (1er) + 5 000 € (2e suppl.) = 14 000 €.'),

  -- ─── LEÇON 3 — Contrat de transport (12 QCM) ───
  (v_formation, 'qcm', 'Combien de parties au contrat de transport ?',
   '[{"id":"a","label":"2","is_correct":false},{"id":"b","label":"3","is_correct":true},{"id":"c","label":"4","is_correct":false},{"id":"d","label":"5","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-c','capa-3-5t','lecon-3','contrat-transport'], 'mft-2026:moduleC:qcm:25', true,
   '3 parties : expéditeur (remet la marchandise), transporteur (l''achemine), destinataire (la reçoit). Le destinataire devient partie en signant la lettre de voiture.'),

  (v_formation, 'qcm', 'La lettre de voiture est établie en :',
   '[{"id":"a","label":"1 exemplaire","is_correct":false},{"id":"b","label":"3 exemplaires","is_correct":true},{"id":"c","label":"5 exemplaires","is_correct":false},{"id":"d","label":"10 exemplaires","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-c','capa-3-5t','lecon-3','lettre-voiture'], 'mft-2026:moduleC:qcm:26', true,
   '3 exemplaires (« triple original ») : un pour chaque partie. Couleurs traditionnelles : rouge expéditeur, bleu destinataire, vert transporteur.'),

  (v_formation, 'qcm', 'L''exemplaire ROUGE de la lettre de voiture est destiné à :',
   '[{"id":"a","label":"L''expéditeur","is_correct":true},{"id":"b","label":"Le destinataire","is_correct":false},{"id":"c","label":"Le transporteur","is_correct":false},{"id":"d","label":"L''administration","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-c','capa-3-5t','lecon-3','lettre-voiture'], 'mft-2026:moduleC:qcm:27', true,
   'Convention : Rouge = Expéditeur. Bleu = Destinataire (accompagne la marchandise). Vert = Transporteur (à conserver 5 ans).'),

  (v_formation, 'qcm', 'Pour confirmer une avarie non apparente après livraison, le destinataire doit envoyer une LRAR sous :',
   '[{"id":"a","label":"24 heures","is_correct":false},{"id":"b","label":"3 jours","is_correct":true},{"id":"c","label":"15 jours","is_correct":false},{"id":"d","label":"1 mois","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-c','capa-3-5t','lecon-3','reserves'], 'mft-2026:moduleC:qcm:28', true,
   '3 jours par LRAR pour les avaries non apparentes (qui se révèlent après ouverture des colis). Au-delà, perte de tout recours (art. L. 133-3 C. com.).'),

  (v_formation, 'qcm', 'La limite d''indemnisation par kg de marchandise endommagée dans le contrat-type général est de :',
   '[{"id":"a","label":"5 €/kg","is_correct":false},{"id":"b","label":"10 €/kg","is_correct":false},{"id":"c","label":"23 €/kg","is_correct":true},{"id":"d","label":"100 €/kg","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-c','capa-3-5t','lecon-3','indemnisation'], 'mft-2026:moduleC:qcm:29', true,
   '23 €/kg en transport national (contrat-type général). 8,33 DTS/kg (≈ 10 €/kg) en CMR international.'),

  (v_formation, 'qcm', 'Le décret qui fixe le contrat-type général transport routier est :',
   '[{"id":"a","label":"Décret 2012-345","is_correct":false},{"id":"b","label":"Décret 99-269 du 6 avril 1999","is_correct":true},{"id":"c","label":"Décret 2008-1245","is_correct":false},{"id":"d","label":"Décret 2018-1091","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-c','capa-3-5t','lecon-3','contrat-type'], 'mft-2026:moduleC:qcm:30', true,
   'Décret n° 99-269 du 6 avril 1999 modifié. Il s''applique automatiquement en l''absence de contrat écrit spécifique entre les parties.'),

  (v_formation, 'qcm', 'Le transporteur est responsable de plein droit des avaries entre :',
   '[{"id":"a","label":"L''appel et la confirmation de commande","is_correct":false},{"id":"b","label":"La prise en charge et la livraison","is_correct":true},{"id":"c","label":"La signature du contrat et le paiement","is_correct":false},{"id":"d","label":"L''émission de la facture et son paiement","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-c','capa-3-5t','lecon-3','responsabilite'], 'mft-2026:moduleC:qcm:31', true,
   'Article L. 133-1 C. com. : responsabilité de plein droit du transporteur pour pertes, manquants, avaries entre la prise en charge et la livraison.'),

  (v_formation, 'qcm', 'Parmi ces causes, laquelle exonère le transporteur de sa responsabilité ?',
   '[{"id":"a","label":"Une grève des chauffeurs","is_correct":false},{"id":"b","label":"Le mauvais emballage de l''expéditeur","is_correct":true},{"id":"c","label":"Une panne mécanique du VUL","is_correct":false},{"id":"d","label":"Un retard de livraison","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-c','capa-3-5t','lecon-3','exoneration'], 'mft-2026:moduleC:qcm:32', true,
   'Causes d''exonération : force majeure, vice propre de la marchandise, faute de l''expéditeur (mauvais emballage), faute du destinataire. La panne mécanique reste à la charge du transporteur.'),

  (v_formation, 'qcm', 'Le compte propre concerne :',
   '[{"id":"a","label":"Une entreprise qui transporte sa propre marchandise","is_correct":true},{"id":"b","label":"Un sous-traitant agréé","is_correct":false},{"id":"c","label":"Un coursier indépendant","is_correct":false},{"id":"d","label":"Une coopérative","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-c','capa-3-5t','lecon-3','compte-propre'], 'mft-2026:moduleC:qcm:33', true,
   'Compte propre = transport de SA propre marchandise (ex. boulanger qui livre ses pains). Pas besoin de licence DREAL ni d''attestation de capacité.'),

  (v_formation, 'qcm', 'Combien de temps doit-on conserver les lettres de voiture ?',
   '[{"id":"a","label":"1 an","is_correct":false},{"id":"b","label":"3 ans","is_correct":false},{"id":"c","label":"5 ans","is_correct":true},{"id":"d","label":"10 ans","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-c','capa-3-5t','lecon-3','conservation-documents'], 'mft-2026:moduleC:qcm:34', true,
   '5 ans : c''est aussi la prescription en matière commerciale ordinaire et la durée de conservation des pièces comptables. Indispensable en cas de litige tardif.'),

  (v_formation, 'qcm', 'Sans réserves à la livraison, et sans LRAR sous 3 jours pour les avaries non apparentes, le destinataire :',
   '[{"id":"a","label":"Peut quand même attaquer le transporteur sous 6 mois","is_correct":false},{"id":"b","label":"Perd tout recours contre le transporteur","is_correct":true},{"id":"c","label":"Doit attendre 1 an avant d''agir","is_correct":false},{"id":"d","label":"Peut demander une indemnisation forfaitaire automatique","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-c','capa-3-5t','lecon-3','reserves','recours'], 'mft-2026:moduleC:qcm:35', true,
   'Article L. 133-3 C. com. : sans réserves à la livraison ou sans confirmation par LRAR sous 3 jours pour les avaries non apparentes, le destinataire perd tout recours.'),

  (v_formation, 'qcm', 'Le contrat de transport est régi par les articles :',
   '[{"id":"a","label":"L. 132-1 à L. 133-9 du Code de commerce","is_correct":true},{"id":"b","label":"L. 211-1 à L. 211-25 du Code des assurances","is_correct":false},{"id":"c","label":"L. 1411-1 à L. 1411-30 du Code des transports","is_correct":false},{"id":"d","label":"Aucun texte spécifique","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-c','capa-3-5t','lecon-3','code-commerce'], 'mft-2026:moduleC:qcm:36', true,
   'Articles L. 132-1 à L. 133-9 du Code de commerce. Plus le règlement général du transport (décret 99-269) et les contrats-types spéciaux.'),

  -- ─── LEÇON 4 — Contrats spéciaux et assurances (12 QCM) ───
  (v_formation, 'qcm', 'Quelle assurance est OBLIGATOIRE pour tout véhicule à moteur ?',
   '[{"id":"a","label":"L''assurance ad valorem","is_correct":false},{"id":"b","label":"La responsabilité civile circulation","is_correct":true},{"id":"c","label":"La protection juridique","is_correct":false},{"id":"d","label":"La multirisque pro","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-c','capa-3-5t','lecon-4','rc-circulation'], 'mft-2026:moduleC:qcm:37', true,
   'RC circulation : seule assurance OBLIGATOIRE au sens strict (art. L. 211-1 C. assurances). Couvre les dommages causés à des TIERS (autre véhicule, piéton).'),

  (v_formation, 'qcm', 'La RC contractuelle (RCM) couvre :',
   '[{"id":"a","label":"Les piétons heurtés par le VUL","is_correct":false},{"id":"b","label":"La marchandise transportée","is_correct":true},{"id":"c","label":"Les locaux de l''entreprise","is_correct":false},{"id":"d","label":"Les frais d''avocat en cas de litige","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-c','capa-3-5t','lecon-4','rcm'], 'mft-2026:moduleC:qcm:38', true,
   'RC contractuelle / RC marchandises = couvre la responsabilité du transporteur sur les marchandises pendant le transport (avaries, manquants, retards).'),

  (v_formation, 'qcm', 'L''assurance « ad valorem » sert à :',
   '[{"id":"a","label":"Couvrir la valeur déclarée de la marchandise au-delà de 23 €/kg","is_correct":true},{"id":"b","label":"Réduire les cotisations URSSAF","is_correct":false},{"id":"c","label":"Couvrir les amendes routières","is_correct":false},{"id":"d","label":"Garantir le paiement des factures clients","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-c','capa-3-5t','lecon-4','ad-valorem'], 'mft-2026:moduleC:qcm:39', true,
   'Ad valorem (« selon la valeur ») = assurance optionnelle qui couvre la valeur réelle déclarée par le client, au-delà de la limite contractuelle de 23 €/kg.'),

  (v_formation, 'qcm', 'La sous-traitance impose au transporteur principal :',
   '[{"id":"a","label":"De rester responsable contractuellement vis-à-vis du donneur d''ordre","is_correct":true},{"id":"b","label":"D''abandonner toute responsabilité","is_correct":false},{"id":"c","label":"De doubler son tarif","is_correct":false},{"id":"d","label":"De réduire ses prix de 50 %","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-c','capa-3-5t','lecon-4','sous-traitance'], 'mft-2026:moduleC:qcm:40', true,
   'Le transporteur principal reste responsable contractuellement, même s''il a sous-traité. Il doit vérifier la licence du sous-traitant et respecter les délais de paiement.'),

  (v_formation, 'qcm', 'Un coursier urbain qui livre fait du transport :',
   '[{"id":"a","label":"De déménagement","is_correct":false},{"id":"b","label":"De messagerie / express","is_correct":true},{"id":"c","label":"D''animaux vivants","is_correct":false},{"id":"d","label":"De fonds et valeurs","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-c','capa-3-5t','lecon-4','messagerie'], 'mft-2026:moduleC:qcm:41', true,
   'Messagerie / express = envois ≤ 3 t, distribution rapide. Le coursier urbain rentre dans cette catégorie. Contrat-type messagerie applicable.'),

  (v_formation, 'qcm', 'Le contrat-type SOUS-TRAITANCE est fixé par :',
   '[{"id":"a","label":"Décret 99-269","is_correct":false},{"id":"b","label":"Décret 2003-1295","is_correct":true},{"id":"c","label":"Loi LME 2008","is_correct":false},{"id":"d","label":"Code des assurances","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-c','capa-3-5t','lecon-4','sous-traitance'], 'mft-2026:moduleC:qcm:42', true,
   'Décret n° 2003-1295 du 26 décembre 2003. Pose les règles spécifiques de la sous-traitance dans le transport routier.'),

  (v_formation, 'qcm', 'En location avec conducteur, la facturation se fait :',
   '[{"id":"a","label":"À la palette","is_correct":false},{"id":"b","label":"À la tonne","is_correct":false},{"id":"c","label":"À l''heure ou à la demi-journée","is_correct":true},{"id":"d","label":"Au km uniquement","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-c','capa-3-5t','lecon-4','location'], 'mft-2026:moduleC:qcm:43', true,
   'Location avec conducteur : tarif horaire ou par demi-journée/journée. Le client supervise les opérations en temps réel. Différent du transport facturé au km/palette/tonne.'),

  (v_formation, 'qcm', 'Les sanctions financières en cas de défaut d''assurance circulation peuvent atteindre :',
   '[{"id":"a","label":"100 € d''amende","is_correct":false},{"id":"b","label":"3 750 € d''amende + suspension permis","is_correct":true},{"id":"c","label":"Aucune sanction","is_correct":false},{"id":"d","label":"Confiscation du domicile","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-c','capa-3-5t','lecon-4','sanctions-assurance'], 'mft-2026:moduleC:qcm:44', true,
   'Défaut de RC circulation : 3 750 € d''amende + suspension permis + confiscation possible du véhicule. Aucune indemnisation des dommages causés.'),

  (v_formation, 'qcm', 'Pour un envoi de marchandise valant 50 000 € sur 50 kg, l''indemnisation max sous contrat-type général est de :',
   '[{"id":"a","label":"50 000 €","is_correct":false},{"id":"b","label":"23 €","is_correct":false},{"id":"c","label":"1 150 €","is_correct":true},{"id":"d","label":"100 €","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-c','capa-3-5t','lecon-4','indemnisation','calcul'], 'mft-2026:moduleC:qcm:45', true,
   'Limite contrat-type général = 23 €/kg. 50 kg × 23 € = 1 150 € maximum. Pour couvrir 50 000 €, il faut une assurance ad valorem distincte.'),

  (v_formation, 'qcm', 'Quel contrat est adapté au déménagement de particuliers ?',
   '[{"id":"a","label":"Contrat-type général","is_correct":false},{"id":"b","label":"Contrat-type déménagement (avec inventaire et fiche réception)","is_correct":true},{"id":"c","label":"Contrat de location simple","is_correct":false},{"id":"d","label":"Contrat de cabotage","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-c','capa-3-5t','lecon-4','demenagement'], 'mft-2026:moduleC:qcm:46', true,
   'Contrat-type déménagement spécifique : inventaire détaillé, lettre de voiture déménagement, fiche réception, indemnisation selon valeur déclarée.'),

  (v_formation, 'qcm', 'La protection juridique professionnelle couvre :',
   '[{"id":"a","label":"Les frais d''avocat en cas de litige","is_correct":true},{"id":"b","label":"Les coûts de réparation des véhicules","is_correct":false},{"id":"c","label":"Les salaires en cas d''arrêt maladie","is_correct":false},{"id":"d","label":"Les pertes d''exploitation","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-c','capa-3-5t','lecon-4','protection-juridique'], 'mft-2026:moduleC:qcm:47', true,
   'Protection juridique = couvre les frais d''avocat et de procédure en cas de litige (recouvrement, sanctions DREAL, contentieux client). Recommandée pour 200-500 €/an.'),

  (v_formation, 'qcm', 'Pour 1 VUL ≤ 3,5 t avec activité haut de gamme, le coût total annuel d''assurances est typiquement de :',
   '[{"id":"a","label":"200 à 500 €","is_correct":false},{"id":"b","label":"3 000 à 5 000 €","is_correct":true},{"id":"c","label":"15 000 à 20 000 €","is_correct":false},{"id":"d","label":"Plus de 50 000 €","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-c','capa-3-5t','lecon-4','cout-assurances'], 'mft-2026:moduleC:qcm:48', true,
   '3 000 à 5 000 €/an pour 1 VUL avec activité haut de gamme : RC circulation (1 200-2 500 €) + RCM (800-1 500 €) + ad valorem variable + multirisque pro (600-1 200 €) + protection juridique (200-500 €).');

  -- =================================================================
  -- BANQUE DE QR — Module C (7 mises en situation)
  -- =================================================================

  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qr',
    'Vous venez d''immatriculer votre SARL de transport au RCS et possédez votre attestation de capacité ≤ 3,5 t. Vous voulez démarrer immédiatement avec 2 VUL.

a. Quelles sont les 4 conditions cumulatives que vous devez remplir pour exercer ?
b. Calculez la capacité financière exigée.
c. Décrivez les démarches à effectuer auprès de la DREAL et l''ordre dans lequel les faire.
d. Combien de temps faut-il prévoir entre l''inscription au registre et la délivrance de la LTI ?',
   NULL, 5, 'moyen',
   ARRAY['module-c','capa-3-5t','qr','conditions-acces','dreal','cas-pratique'],
   'mft-2026:moduleC:qr:1', true,
   'Correction attendue : a. (1) Établissement réel et stable en France (locaux, véhicules, gestionnaire). (2) Honorabilité professionnelle (casier B2 vierge). (3) Capacité financière (1 800 + 900 = 2 700 €). (4) Capacité professionnelle (attestation, déjà obtenue). b. 1 800 € (1er VUL) + 900 € (2e VUL) = 2 700 € à justifier (capitaux propres, caution bancaire ou cautionnement BPI/SIAGI). c. (1) Constituer le dossier (Kbis, attestation, casier B2, justificatif financier, justificatif locaux). (2) Déposer auprès de la DREAL régionale. (3) DREAL vérifie sous 4-8 semaines. (4) Délivrance LTI (à apposer sur pare-brise). d. 4-8 semaines en moyenne, à anticiper dans le calendrier de démarrage.'),

  (v_formation, 'qr',
    'Vous transportez 4 palettes de matériel électronique valant 25 000 € au total. À la livraison, le destinataire ouvre les cartons et constate qu''une palette (poids 80 kg, valeur 6 000 €) est endommagée par humidité. Il vous appelle 2 jours après la livraison pour vous prévenir.

a. À combien d''indemnisation sous contrat-type général le destinataire peut-il prétendre ?
b. Que doit-il avoir fait pour préserver son recours ?
c. Quelle aurait été votre couverture optimale en tant que transporteur ?
d. Le destinataire a-t-il encore un recours s''il vous appelle 5 jours après la livraison ?',
   NULL, 5, 'difficile',
   ARRAY['module-c','capa-3-5t','qr','indemnisation','reserves','assurance','cas-pratique'],
   'mft-2026:moduleC:qr:2', true,
   'Correction attendue : a. Limite contrat-type général = 23 €/kg × 80 kg = 1 840 €. Le destinataire perd 6 000 - 1 840 = 4 160 € s''il n''a pas d''assurance ad valorem. b. Poser des réserves au moment de la livraison sur la lettre de voiture pour les avaries apparentes. Pour les avaries non apparentes (humidité dans cartons fermés), envoyer une LRAR au transporteur sous 3 jours à compter de la livraison (art. L. 133-3 C. com.). Sans cela, perte de tout recours. c. Souscrire une assurance ad valorem couvrant la valeur déclarée par le client (~ 0,1-0,3 % de la valeur). Vous facturez la prime au client avec marge, lui sécurisez ses 25 000 €. d. NON. Délai de 3 jours dépassé = perte de tout recours. La marchandise est réputée acceptée sans réserves.'),

  (v_formation, 'qr',
    'Yacine vient d''obtenir son attestation de capacité. Il a 30 ans, est marié sous communauté légale avec une cadre, dispose de 18 000 € d''épargne, et veut créer une SARL de transport avec 3 VUL ≤ 3,5 t dès l''ouverture.

a. Quelle capacité financière doit-il justifier ?
b. Comment peut-il la justifier (3 modes possibles) ?
c. Quels sont les risques pour son patrimoine personnel et celui de sa femme ?
d. Quelles 3 actions concrètes recommandez-vous AVANT d''immatriculer la SARL ?',
   NULL, 5, 'difficile',
   ARRAY['module-c','capa-3-5t','qr','capacite-financiere','patrimoine','cas-pratique'],
   'mft-2026:moduleC:qr:3', true,
   'Correction attendue : a. 1 800 € (1er VUL) + 2 × 900 € = 3 600 €. b. (1) Capitaux propres certifiés (bilan visé par expert-comptable). (2) Caution bancaire (banque ou compagnie d''assurance). (3) Cautionnement BPI ou SIAGI (organismes spécialisés, ~ 1-2 % de commission par an). c. Sous communauté légale, les biens communs (compte joint, voiture, résidence secondaire) sont engageables pour les dettes de la SARL si Yacine se porte caution personnelle. Sans caution, la SARL protège les biens. d. (1) Passer en séparation de biens (notaire, protège la femme cadre). (2) Capitaliser la SARL avec un capital significatif (5 000-10 000 €) plutôt que 1 € symbolique pour crédibiliser auprès des banques. (3) Si caution personnelle exigée par la banque, demander un consentement exprès écrit de la femme (art. 1415 C. civ.) et limiter la caution dans le temps et le montant.'),

  (v_formation, 'qr',
    'Un commissionnaire de transport vous propose une mission de sous-traitance régulière : 5 livraisons hebdomadaires de palettes alimentaires sur 80 km. Tarif proposé : 75 €/livraison HT. Paiement à 60 jours. Vous avez 1 VUL ≤ 3,5 t et la capacité.

a. Identifiez les 3 points juridiques à vérifier avant de signer.
b. Le délai de paiement de 60 jours est-il légal en transport ? Justifiez en citant l''article.
c. Quelles 2 clauses essentielles doivent figurer dans le contrat de sous-traitance ?
d. Que faire si le commissionnaire fait faillite après 6 mois de relation ?',
   NULL, 5, 'difficile',
   ARRAY['module-c','capa-3-5t','qr','sous-traitance','delais-paiement','cas-pratique'],
   'mft-2026:moduleC:qr:4', true,
   'Correction attendue : a. (1) Vérifier la licence du commissionnaire (Pappers, capacité financière) et sa solvabilité (bilan, procédures collectives). (2) Confirmer que vous avez bien votre LTI à jour pour ce type de marchandise (alimentaire éventuellement frais). (3) Vérifier la cohérence du prix avec votre CRKM (75 € sur 80 km = 0,94 €/km — limite de rentabilité, attention aux retours à vide). b. NON. Article L. 441-11 du Code de commerce : 30 jours date de facture max en transport routier (règle d''ordre public, non négociable même par contrat). À renégocier obligatoirement. c. (1) Clause d''indexation sur l''indice CNR carburant (révision si hausse > 5 % du gazole). (2) Clause de préavis de rupture (3 mois minimum, indemnité de rupture brutale au-delà de la jurisprudence article L. 442-1 C. com.). d. Engager une procédure de déclaration de créance dans le délai imparti par le mandataire judiciaire (généralement 2 mois après publication BODACC). Vous figurerez parmi les créanciers chirographaires (sans privilège) et récupérerez en moyenne 3-8 % de la créance dans une liquidation. Toujours diversifier ses clients pour ne pas dépendre d''un seul commissionnaire.'),

  (v_formation, 'qr',
    'Vous démarrez une activité de coursier express avec 1 VUL ≤ 3,5 t. Vous estimez transporter régulièrement du matériel haute valeur (jusqu''à 30 000 € par envoi). Votre budget annuel d''assurances est de 4 500 €.

a. Quelles sont les assurances OBLIGATOIRES ?
b. Quelles assurances RECOMMANDÉES vu votre activité ?
c. Quelle est la différence entre RC circulation et RC contractuelle ?
d. Comment fonctionne l''ad valorem et pourquoi est-elle indispensable dans votre cas ?',
   NULL, 5, 'moyen',
   ARRAY['module-c','capa-3-5t','qr','assurances','ad-valorem','cas-pratique'],
   'mft-2026:moduleC:qr:5', true,
   'Correction attendue : a. RC circulation OBLIGATOIRE (art. L. 211-1 C. assurances), tout véhicule à moteur. Sans elle : 3 750 € amende + suspension permis + confiscation possible du véhicule. b. RC contractuelle / RCM (~ 800-1 500 €/an), assurance ad valorem (selon valeur déclarée), multirisque pro (locaux/matériel/stock 600-1 200 €), protection juridique (200-500 €). Total raisonnable : 3 000-5 000 €/an. c. RC circulation = couvre les TIERS (autre véhicule, piéton). RC contractuelle = couvre la MARCHANDISE TRANSPORTÉE. Deux contrats DISTINCTS, ne pas confondre. d. Ad valorem = assurance optionnelle qui couvre la valeur réelle déclarée par le client, AU-DELÀ de la limite contractuelle de 23 €/kg. Pour un envoi de 30 000 € sur 50 kg, la limite contrat-type ne couvre que 1 150 €. Sans ad valorem, vous restez personnellement responsable des 28 850 € manquants en cas de sinistre. Avec ad valorem (~ 0,1-0,3 % de la valeur, refacturable au client), vous êtes couvert intégralement.'),

  (v_formation, 'qr',
    'Vous transportez 6 palettes pour un client industriel. À la livraison, le destinataire signe la lettre de voiture sans observations. Le lendemain, il vous appelle pour signaler que 2 palettes sont endommagées. Le surlendemain, il vous adresse une LRAR détaillée.

a. La signature « sans observations » de la lettre de voiture est-elle un obstacle au recours ?
b. Pour quel type d''avaries la LRAR est-elle valable, et sous quel délai ?
c. La LRAR du destinataire est-elle valide dans ce cas ?
d. Que conservez-vous comme document pour vous défendre ?',
   NULL, 5, 'moyen',
   ARRAY['module-c','capa-3-5t','qr','reserves','lrar','cas-pratique'],
   'mft-2026:moduleC:qr:6', true,
   'Correction attendue : a. La signature sans réserves ne ferme pas définitivement le recours UNIQUEMENT pour les avaries NON APPARENTES (qui se révèlent après ouverture des cartons / palettes). Pour les avaries apparentes, le recours est perdu. b. La LRAR sous 3 JOURS à compter de la livraison est valable uniquement pour les AVARIES NON APPARENTES (humidité interne, casse non visible extérieurement, défaut de fonctionnement détecté à l''utilisation). Pour les avaries visibles à la livraison (carton éventré, palette de travers), il aurait fallu poser les réserves IMMÉDIATEMENT sur la lettre de voiture. c. Le délai de 3 jours est respecté (LRAR le surlendemain de l''appel, donc 2 ou 3 jours après livraison). Si les avaries sont effectivement non apparentes, la LRAR est VALABLE. Si elles étaient visibles à la livraison, elle est tardive. d. Conserver la lettre de voiture signée sans réserves (= preuve de l''absence d''avarie apparente), photos prises au chargement (preuve de l''emballage et de l''état initial), bons de livraison signés, copies des SMS/emails échangés. Conserver 5 ans minimum.'),

  (v_formation, 'qr',
    'Un client vous demande de mettre à disposition votre VUL et un chauffeur tous les samedis matin (8h-13h) pour effectuer ses livraisons à des particuliers. Le client vous donne le matin la liste des adresses et l''ordre de tournée.

a. Quel type de contrat est applicable : transport ou location avec conducteur ? Justifiez.
b. Comment facturez-vous habituellement ce type de prestation ?
c. Qui est responsable des avaries éventuelles ?
d. Quelles 2 précautions juridiques prendre dans le contrat écrit ?',
   NULL, 5, 'difficile',
   ARRAY['module-c','capa-3-5t','qr','location-conducteur','responsabilite','cas-pratique'],
   'mft-2026:moduleC:qr:7', true,
   'Correction attendue : a. LOCATION AVEC CONDUCTEUR (et non contrat de transport). 3 indices : (1) le client définit en temps réel les opérations, (2) la prestation est une mise à disposition VUL + chauffeur sans marchandise spécifique préalablement définie, (3) la facturation se fera à la demi-journée et non au km/palette. Contrat-type spécifique « location de véhicule industriel avec conducteur » applicable. b. Tarif horaire ou par demi-journée (35-50 €/h en VUL + chauffeur en province, soit 175-250 € pour 5 heures). c. La responsabilité avarie peut être PARTAGÉE selon les directives du donneur d''ordre. Si le dommage résulte d''une consigne explicite du client (« stockez ces meubles dehors sous la pluie »), il porte la responsabilité. Si le chauffeur a une faute de manipulation, c''est vous. À sécuriser par un contrat écrit. d. (1) Clause de responsabilité claire : qui assume quoi (avaries, casse, retard). (2) Clause d''assurance : qui souscrit la RC marchandises pendant la location, qui paie la franchise en cas de sinistre. Recommander que le client ait sa propre assurance pour la marchandise transportée car elle ne lui appartient pas (transport B2C de meubles).');

  -- =================================================================
  -- QUIZZES par leçon — chacun 12 QCM
  -- =================================================================

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Organisation administrative — Quiz',
          'Quiz d''entraînement (12 questions) sur la DREAL, la DGITM, le CRSR, la CCT, les organisations patronales et les conventions collectives.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleC:qcm:1','mft-2026:moduleC:qcm:2','mft-2026:moduleC:qcm:3',
      'mft-2026:moduleC:qcm:4','mft-2026:moduleC:qcm:5','mft-2026:moduleC:qcm:6',
      'mft-2026:moduleC:qcm:7','mft-2026:moduleC:qcm:8','mft-2026:moduleC:qcm:9',
      'mft-2026:moduleC:qcm:10','mft-2026:moduleC:qcm:11','mft-2026:moduleC:qcm:12'
    );

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Conditions d''accès à la profession — Quiz',
          'Quiz d''entraînement (12 questions) sur les 4 conditions cumulatives, la capacité financière, l''honorabilité et l''attestation de capacité.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleC:qcm:13','mft-2026:moduleC:qcm:14','mft-2026:moduleC:qcm:15',
      'mft-2026:moduleC:qcm:16','mft-2026:moduleC:qcm:17','mft-2026:moduleC:qcm:18',
      'mft-2026:moduleC:qcm:19','mft-2026:moduleC:qcm:20','mft-2026:moduleC:qcm:21',
      'mft-2026:moduleC:qcm:22','mft-2026:moduleC:qcm:23','mft-2026:moduleC:qcm:24'
    );

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Contrat de transport et lettre de voiture — Quiz',
          'Quiz d''entraînement (12 questions) sur les 3 parties au contrat, le contrat-type général, la lettre de voiture, les réserves et l''indemnisation.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleC:qcm:25','mft-2026:moduleC:qcm:26','mft-2026:moduleC:qcm:27',
      'mft-2026:moduleC:qcm:28','mft-2026:moduleC:qcm:29','mft-2026:moduleC:qcm:30',
      'mft-2026:moduleC:qcm:31','mft-2026:moduleC:qcm:32','mft-2026:moduleC:qcm:33',
      'mft-2026:moduleC:qcm:34','mft-2026:moduleC:qcm:35','mft-2026:moduleC:qcm:36'
    );

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Contrats spéciaux et assurances — Quiz',
          'Quiz d''entraînement (12 questions) sur la sous-traitance, la location avec conducteur, la messagerie, le déménagement et les assurances.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleC:qcm:37','mft-2026:moduleC:qcm:38','mft-2026:moduleC:qcm:39',
      'mft-2026:moduleC:qcm:40','mft-2026:moduleC:qcm:41','mft-2026:moduleC:qcm:42',
      'mft-2026:moduleC:qcm:43','mft-2026:moduleC:qcm:44','mft-2026:moduleC:qcm:45',
      'mft-2026:moduleC:qcm:46','mft-2026:moduleC:qcm:47','mft-2026:moduleC:qcm:48'
    );

  -- Quiz 5 — Synthèse transversale réglementaire (12 QCM des 4 leçons,
  -- niveau avancé, ajouté selon décision client mai 2026)
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Synthèse transversale réglementaire — Quiz',
          'Quiz d''entraînement transversal (12 questions de niveau avancé) couvrant les 4 leçons du Module C : organisation profession, accès, contrat-type, contrats spéciaux et assurances.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_5;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_5, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleC:qcm:6','mft-2026:moduleC:qcm:11','mft-2026:moduleC:qcm:12',
      'mft-2026:moduleC:qcm:17','mft-2026:moduleC:qcm:23','mft-2026:moduleC:qcm:24',
      'mft-2026:moduleC:qcm:29','mft-2026:moduleC:qcm:35','mft-2026:moduleC:qcm:36',
      'mft-2026:moduleC:qcm:41','mft-2026:moduleC:qcm:47','mft-2026:moduleC:qcm:48'
    );

  -- =================================================================
  -- EXAMEN BLANC Module C — 13 QCM + 5 QR (60 min, seuil 50 %)
  -- (Module C = le plus important : 36 pts / 84 à l'examen national)
  -- =================================================================
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold, is_mock_exam)
  VALUES (v_module, 'Examen blanc — Module C',
          'Examen blanc reproduisant les conditions de l''examen national : 13 QCM (26 pts) + 5 QR (25 pts), durée 60 min, seuil 50 %.',
          'examen', 3600, 50, true)
  RETURNING id INTO v_quiz_eb;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleC:qcm:1','mft-2026:moduleC:qcm:7','mft-2026:moduleC:qcm:13',
      'mft-2026:moduleC:qcm:14','mft-2026:moduleC:qcm:17','mft-2026:moduleC:qcm:18',
      'mft-2026:moduleC:qcm:25','mft-2026:moduleC:qcm:27','mft-2026:moduleC:qcm:28',
      'mft-2026:moduleC:qcm:29','mft-2026:moduleC:qcm:37','mft-2026:moduleC:qcm:39',
      'mft-2026:moduleC:qcm:45'
    );

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, 100 + ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleC:qr:1','mft-2026:moduleC:qr:2',
      'mft-2026:moduleC:qr:3','mft-2026:moduleC:qr:5',
      'mft-2026:moduleC:qr:6'
    );

  RAISE NOTICE '✅ Module C v3 chargé (densifié) : 4 leçons riches, 48 QCM (12 par leçon), 7 QR, 6 quizzes (5 entraînement dont un transversal + 1 examen blanc 13 QCM + 5 QR).';
END
$module_c_v3$;

