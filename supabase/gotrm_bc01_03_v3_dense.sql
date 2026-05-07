-- =====================================================================
-- GOTRM (RNCP 40990) — BC01-03 · Élaborer une cotation et une offre commerciale
-- Version 3 (mai 2026) — REFONTE PÉDAGOGIQUE PREMIUM v3_dense
--
-- Bloc 01 : Concevoir, organiser et piloter des opérations de transport.
-- Module n° 3 du BC01 (suite de BC01-01 et BC01-02).
--
-- Référentiel RNCP 40990 — compétence visée :
--   « Élaborer une cotation et formaliser une offre commerciale en intégrant
--   les coûts de revient, les marges, les contraintes du marché et les
--   conditions juridiques propres au transport routier de marchandises. »
--
-- ▸ 4 leçons (200 min total)
--   1. Décomposer les coûts — charges fixes, variables, structure (50 min)
--   2. Construire un prix de vente et une marge cible (50 min)
--   3. Méthodologie de cotation et structure du devis (50 min)
--   4. Négociation, revalorisation et indexation gazole (50 min)
--
-- Idempotent. Pré-requis : formation 'gotrm' présente.
-- =====================================================================

DO $bc01_03_v3$
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
  v_quiz_eb uuid;
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

  -- ─── Remplacement complet du module BC01-03 ─────────────────────────
  DELETE FROM public.modules WHERE slug IN (
    'gotrm-bc01-03-cotation-offre',
    'gotrm-bc01-03-cotation-offre-v3'
  );

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026-gotrm:bc01-03-v3:%';

  INSERT INTO public.modules (
    title, slug, bloc_id, summary, difficulty, duration_min, "order"
  ) VALUES (
    'BC01-03 — Élaborer une cotation et une offre commerciale',
    'gotrm-bc01-03-cotation-offre',
    v_bloc,
    'Décomposer les coûts de revient (CRKM) en charges fixes, variables et de structure, construire un prix de vente avec marge cible, élaborer un devis professionnel conforme aux mentions LME, négocier sans détruire la marge et appliquer l''indexation gazole obligatoire.',
    'intermediaire',
    200,
    30
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 30, true) ON CONFLICT DO NOTHING;

  -- =================================================================
  -- LEÇON 1 — Décomposer les coûts (charges fixes, variables, structure)
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Décomposer les coûts — charges fixes, variables, structure',
    'decomposer-couts-crkm',
    1, 50,
$lessonG1$
# Décomposer les coûts — charges fixes, variables, structure

> 🎯 **Objectifs pédagogiques**
>
> À la fin de cette leçon, vous serez capable de :
>
> - **Calculer** un Coût de Revient Kilométrique (CRKM) complet pour un véhicule donné.
> - **Distinguer** charges fixes, charges variables et charges de structure.
> - **Identifier** les 18 postes de coût d'un transporteur routier (méthode CNR).
> - **Réaliser** une décomposition chiffrée d'un VUL et d'un PL.
> - **Comprendre** les notions de pleine charge, charge partielle et retour à vide.

---

## Introduction

Le **Comité National Routier (CNR)** — organisme officiel de référence — chiffre le CRKM moyen 2026 d'un **PL longue distance 40 t** à **1,18 €/km** et d'un **VUL 3,5 t régional** à **0,72 €/km**. Mais ces moyennes cachent une réalité métier : **deux entreprises identiques peuvent avoir un écart de 25 %** sur leur CRKM réel selon la rigueur de leur comptabilité analytique.

Mal connaître son CRKM = signer des contrats à perte. **35 % des PME du transport routier français vendent en dessous de leur coût de revient** (étude FNTR 2025). Pas par incompétence : par absence de méthode pour décomposer leurs charges et les réimputer correctement par kilomètre, par voyage et par véhicule.

Cette leçon vous donne **la méthode CNR** — celle qu'utilisent Geodis, Dachser et tous les grands transporteurs — pour bâtir un CRKM béton, à actualiser tous les trimestres, et qui devient le **socle de toutes vos cotations**.

---

## 1. Les 3 catégories de coûts

### 1.1 Vue d'ensemble

Tous les coûts d'exploitation d'un véhicule se rangent dans **3 grandes catégories** :

| Catégorie | Définition | Imputation | Exemples |
|---|---|---|---|
| **Charges fixes** | Coûts qui tombent même si le véhicule ne roule pas | À l'année / au mois | Amortissement, assurance, salaire CDI conducteur |
| **Charges variables** | Coûts proportionnels au kilométrage | Au km roulé | Carburant, pneus, entretien, péages |
| **Charges de structure** | Coûts non directement liés à un véhicule | Au prorata | Loyer agence, comptabilité, commercial, télécoms |

**Règle d'or CNR** : la somme des 3 catégories ramenée au km annuel parcouru = **CRKM total**.

### 1.2 Schéma de décomposition

:::flow
1. Charges fixes véhicule | Annuelles · indépendantes du km
2. Charges variables | Proportionnelles au km · gazole, pneus, entretien
3. Charges de structure | Réparties au prorata · siège, commercial
4. Coût total annuel | Somme des 3 catégories
5. Division par km annuels | CRKM en €/km
6. Application marge | Prix de vente final
:::

### 1.3 Pourquoi distinguer les 3 catégories ?

Trois raisons opérationnelles :

1. **Réagir à la conjoncture** : si le gazole flambe (+0,10 €/L), seules les charges variables augmentent, pas les fixes. Vous adaptez la clause d'indexation gazole sans renégocier le tarif global.
2. **Simuler des scénarios** : un véhicule supplémentaire fait baisser le CRKM total grâce au lissage des charges fixes (effet d'échelle). Vous le démontrez chiffres en main au dirigeant.
3. **Négocier intelligemment** : une remise client de 5 % se prend sur la marge nette, pas sur les charges fixes incompressibles. Un acheteur GMS qui demande -10 % doit savoir qu'il vous met sous le seuil de rentabilité.

---

## 2. Charges fixes — le socle annuel

### 2.1 Liste des 7 postes fixes

| Poste | Définition | Ordre de grandeur 2026 |
|---|---|---|
| **Amortissement / leasing véhicule** | Dotation comptable annuelle ou loyer financier | 8 000 € (VUL) à 22 000 € (PL 40 t) |
| **Assurance flotte** | RC + dommages + marchandises | 2 500 € (VUL) à 6 500 € (PL) |
| **Salaire conducteur CDI** | Brut + charges patronales (URSSAF + retraite + prévoyance) | 38 000 € (VUL régional) à 52 000 € (PL longue distance) |
| **Cotisations TNS dirigeant** | Si patron-conducteur (ETI, SCN) | 12 000-18 000 €/an |
| **Visite technique + tachygraphe** | Contrôles obligatoires annuels | 500-900 €/an |
| **Taxe à l'essieu** (TSVR) | Pour véhicules > 12 t | 250-2 500 €/an selon nb essieux |
| **Cartes carburant + télépéage** | Frais fixes d'abonnement | 200-400 €/an |

### 2.2 Calcul du salaire conducteur CDI (cas concret)

**Cas : conducteur PL longue distance 2026**

- Salaire brut conventionnel CCN 3085 : 2 380 € × 13 mois = **30 940 €/an**.
- Indemnités de grand déplacement : 22 €/jour × 200 jours = **4 400 €**.
- Frais de route + repas non taxables : **2 100 €**.
- Sous-total brut chargé : **37 440 €**.
- Charges patronales (42 %) : **15 725 €**.
- **Coût total employeur : 53 165 €/an**.

**À retenir** : le coût employeur réel = **brut × 1,42** environ pour un conducteur CDI longue distance en France.

### 2.3 Cas concret : charges fixes annuelles d'un VUL Renault Trafic

Une PME a un Renault Trafic L2H1 (3,5 t PTAC) en activité régionale, faisant 60 000 km/an, conducteur CDI temps plein.

| Poste fixe | Montant annuel |
|---|---|
| Loyer LLD 60 mois | 6 800 € |
| Assurance tous risques | 2 400 € |
| Salaire conducteur CDI brut chargé | 38 200 € |
| Visite technique + tachy | 480 € |
| Taxe + cartes | 320 € |
| Provision casse / vol | 800 € |
| Téléphonie + tablette | 600 € |
| **Total charges fixes** | **49 600 €/an** |

**Imputation** : 49 600 / 60 000 km = **0,827 €/km** de charges fixes. C'est la **base incompressible** du CRKM avant même de mettre une goutte de gazole.

---

## 3. Charges variables — le coût du kilométrage

### 3.1 Liste des 5 postes variables

| Poste | Calcul | Ordre de grandeur 2026 |
|---|---|---|
| **Gazole / AdBlue** | Conso × prix gazole | 0,28 €/km (VUL 8 L/100) à 0,45 €/km (PL 32 L/100) |
| **Pneumatiques** | Coût pneus / durée de vie km | 0,02 €/km (VUL) à 0,06 €/km (PL) |
| **Entretien préventif** | Vidanges, freins, distribution | 0,03 €/km (VUL) à 0,07 €/km (PL) |
| **Réparations** | Casses imprévues amorties | 0,02 €/km (VUL) à 0,04 €/km (PL) |
| **Péages** | Sur axes longs (autoroutes) | 0,08-0,15 €/km selon itinéraire |

### 3.2 Calcul du coût gazole — méthode précise

Formule : **Coût gazole/km = Consommation (L/100 km) × Prix gazole (€/L) ÷ 100**

**Exemple** :
- VUL Renault Trafic, conso réelle 9 L/100 km, gazole pro 1,55 €/L (HT déduit TICPE) : 9 × 1,55 / 100 = **0,140 €/km**.
- PL 40 t Renault T High, conso 32 L/100 km, gazole 1,55 €/L : 32 × 1,55 / 100 = **0,496 €/km**.

⚠️ **Piège fréquent** : utiliser le prix TTC à la pompe. Les pros récupèrent la TICPE (15,9 c€/L sur le gazole pro) et la TVA. **Ne calculer qu'avec le prix HT-TICPE déduite**.

### 3.3 Cas concret : charges variables Renault Trafic

| Poste | €/km |
|---|---|
| Gazole (9 L/100, 1,55 €/L) | 0,140 |
| AdBlue (3 % conso gazole) | 0,005 |
| Pneus (4 pneus 350 € / 80 000 km) | 0,018 |
| Entretien préventif (vidanges, plaquettes) | 0,032 |
| Réparations imprévues | 0,020 |
| Péages (estimés sur 60 % parcours) | 0,065 |
| **Total charges variables** | **0,280 €/km** |

### 3.4 Le retour à vide — coût caché

⚠️ **Notion CRITIQUE** : un transporteur **roule à vide** entre deux missions. Si un VUL fait Lille-Paris chargé puis revient à vide, il paye **2 × le carburant** mais ne facture qu'**1 trajet**.

**Conséquence** : si le **taux de retour à vide** est de 30 % (moyenne FNTR), **diviser** le CRKM utile par **0,7** pour avoir le coût réel imputable au km facturé.

**Exemple** : CRKM brut 0,80 €/km, taux retour à vide 30 % ⇒ CRKM facturable = 0,80 / 0,70 = **1,143 €/km**.

---

## 4. Charges de structure — les coûts indirects

### 4.1 Liste des 6 postes de structure

| Poste | Description | Ordre de grandeur PME |
|---|---|---|
| **Loyer / amortissement agence** | Bureaux, parking, hangar | 12 000-30 000 €/an |
| **Salaire dirigeant** + admin | RH, compta, exploit | 60 000-150 000 €/an |
| **Comptabilité externe** | Cabinet expert | 4 000-8 000 €/an |
| **Frais commerciaux** | Salaire commercial + déplacements | 50 000-80 000 €/an |
| **Télécoms / IT** | TMS, GPS, téléphonie pro | 6 000-15 000 €/an |
| **Formation continue** | FCO, FIMO, CACES | 1 500 €/conducteur/an |

### 4.2 Méthode d'imputation des frais de structure

**Méthode CNR — règle des 12-18 % des coûts directs** :

Les frais de structure représentent **12-18 %** des charges fixes + variables d'un transporteur français. Les répartir au prorata du chiffre d'affaires ou des kilomètres roulés par véhicule.

**Exemple PME** : 5 véhicules, 280 000 km totaux, frais de structure annuels 65 000 €.
- Imputation : 65 000 / 280 000 = **0,232 €/km de structure**.
- Ou : 65 000 / 5 véhicules = **13 000 €/véhicule/an** de structure.

### 4.3 Cas concret : structure imputée au Renault Trafic

Le Trafic supporte sa quote-part de structure : 60 000 km × 0,232 = **13 920 €/an**, soit **0,232 €/km**.

---

## 5. Synthèse — calculer le CRKM complet d'un VUL

### 5.1 Cas pratique chiffré : VUL Renault Trafic 60 000 km/an

| Catégorie | Montant annuel | €/km |
|---|---|---|
| Charges fixes véhicule | 49 600 € | 0,827 |
| Charges variables (60 000 km) | 16 800 € | 0,280 |
| Charges de structure (quote-part) | 13 920 € | 0,232 |
| **CRKM TOTAL** | **80 320 €** | **1,339 €/km** |

**Avec retour à vide 30 %** : CRKM facturable = 1,339 / 0,70 = **1,913 €/km**.

⇒ Ce VUL ne doit **JAMAIS être facturé** en dessous de **1,91 €/km** sous peine de pertes.

### 5.2 Cas pratique chiffré : PL 40 t longue distance 110 000 km/an

| Catégorie | Montant annuel | €/km |
|---|---|---|
| Amortissement tracteur + remorque | 28 000 € | 0,255 |
| Assurance | 5 800 € | 0,053 |
| Conducteur CDI longue distance | 53 200 € | 0,484 |
| Taxe essieu + visites | 1 850 € | 0,017 |
| **Total charges fixes** | **88 850 €** | **0,808** |
| Gazole (32 L/100 × 1,55 €) | 54 560 € | 0,496 |
| Pneus + entretien + réparations | 18 700 € | 0,170 |
| Péages | 12 100 € | 0,110 |
| **Total charges variables** | **85 360 €** | **0,776** |
| Structure (16 % de 174 210) | 27 873 € | 0,253 |
| **CRKM TOTAL PL 40 t** | **202 083 €** | **1,837 €/km** |

**Avec retour à vide 18 %** (longue distance optimisée) : CRKM facturable = 1,837 / 0,82 = **2,240 €/km**.

### 5.3 Pleine charge vs charge partielle

| Configuration | Charge utile | CRKM |
|---|---|---|
| **Pleine charge** PL 40 t (24 t utiles) | 100 % | 1,84 €/km · 0,077 €/t.km |
| **Charge partielle** PL 40 t (12 t utiles) | 50 % | 1,84 €/km · **0,153 €/t.km** (× 2) |
| **Retour à vide** | 0 % | 1,84 €/km · ∞ (perte sèche) |

**Leçon** : facturer en €/km est plus simple, mais facturer en **€/tonne-kilomètre (t.km)** est plus juste pour le client en charge partielle. Un porteur 19 t à demi-rempli coûte presque autant qu'à pleine charge.

---

## 6. Cas pratique d'examen

**Énoncé** : Vous êtes gestionnaire d'une PME qui exploite un porteur 19 t (Renault D Wide) en activité régionale Hauts-de-France. Données 2026 :

- Loyer LLD : 14 400 €/an
- Assurance + visites : 4 200 €/an
- Conducteur CDI : 46 000 €/an chargé
- Carburant : 22 L/100 km à 1,55 €/L
- Pneus + entretien : 0,12 €/km
- Péages : 0,08 €/km
- Frais de structure : 15 % des coûts directs
- Kilométrage annuel : 80 000 km
- Retour à vide : 25 %

**Calculez le CRKM total et le CRKM facturable.**

**Correction** :

Charges fixes : 14 400 + 4 200 + 46 000 = **64 600 €/an** ⇒ 64 600 / 80 000 = **0,808 €/km**.

Charges variables :
- Gazole : 22 × 1,55 / 100 = 0,341 €/km
- Pneus + entretien : 0,12 €/km
- Péages : 0,08 €/km
- **Total = 0,541 €/km**.

Coûts directs : 0,808 + 0,541 = **1,349 €/km**.

Structure (15 %) : 1,349 × 0,15 = **0,202 €/km**.

**CRKM total = 1,349 + 0,202 = 1,551 €/km**.

**CRKM facturable** (retour à vide 25 %) : 1,551 / 0,75 = **2,068 €/km**.

⇒ Ce porteur ne doit jamais être vendu sous **2,07 €/km** en moyenne.

---

## 7. Mini-exercice à faire seul

**Énoncé** : Un VUL 3,5 t fait 90 000 km/an. Charges fixes 41 000 €/an. Conso 8,5 L/100 à 1,55 €/L. Pneus + entretien + péages = 0,15 €/km. Structure imputée 12 000 €/an. Retour à vide 35 %.

**Calculez le CRKM total et facturable. Quel prix minimum (sans marge) pour un trajet de 800 km ?**

> 💡 Réponse en fin de module (corrections § 4).

---

## 8. Glossaire

- **CRKM** : Coût de Revient Kilométrique. Métrique de référence du transport.
- **CNR** : Comité National Routier — organisme public publiant les indices mensuels de coûts.
- **Charge fixe** : coût indépendant du km parcouru (loyer véhicule, salaire CDI).
- **Charge variable** : coût proportionnel au km (gazole, pneus, péages).
- **Charge de structure** : coût indirect non lié à un véhicule (siège, commercial).
- **TICPE** : Taxe Intérieure de Consommation sur les Produits Énergétiques. Récupérable à 15,9 c€/L pour les pros.
- **Pleine charge / charge partielle** : taux de remplissage du véhicule.
- **Retour à vide** : trajet où le véhicule roule sans marchandise.
- **t.km** : tonne-kilomètre (1 t transportée sur 1 km). Métrique de productivité.
- **CCN 3085** : Convention Collective Nationale du transport routier.

---

## 9. Synthèse opérationnelle

1. **3 catégories** : fixes (annuelles) / variables (au km) / structure (indirectes).
2. **Coût employeur conducteur** = brut × 1,42 (charges patronales).
3. **Gazole** : conso × prix HT-TICPE / 100 = €/km. Ne pas oublier l'AdBlue (3 % gazole).
4. **Retour à vide** : diviser le CRKM par (1 - taux vide) pour CRKM facturable.
5. **Structure** = 12-18 % des coûts directs en moyenne PME.
6. **CRKM 2026 indicatifs** : VUL 0,72 €/km · porteur 1,15 €/km · PL 40 t 1,84 €/km.
7. **Mise à jour trimestrielle** obligatoire (gazole + URSSAF + CCN).
8. **Outils CNR** : indices mensuels publiés sur cnr.fr (référence professionnelle).

---

## ⚠️ Points de vigilance

- **Ne JAMAIS oublier** les charges de structure : 35 % des PME les sous-estiment.
- **Carburant à HT-TICPE** récupérée : 15,9 c€/L de TICPE pro + TVA.
- **Pleine charge ≠ retour vide** : facturer en t.km pour les courses partielles.
- **Conducteur** = 30-40 % du CRKM total. Premier poste à analyser.
- **Conso réelle** vs **conso constructeur** : écart 15-25 % en exploitation. Toujours mesurer en réel.

## 💡 Astuces pro

- **Outil CNR gratuit** : indices mensuels longue distance, régional, frigo, citerne, exceptionnel sur cnr.fr.
- **Calculateur Excel** : créer un tableur avec onglets par véhicule, mise à jour trimestrielle automatique.
- **Logiciel pro** : Akanea TMS, Mantis ou Stellium intègrent un module CRKM avec actualisation gazole.
- **Suivi conso** : carte gazole pro DKV / TotalCard / AS24 = export CSV mensuel par véhicule.

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : différence charges fixes/variables/structure, formule gazole, ordres de grandeur CRKM.
- **QR cas pratique** : « Calculez le CRKM d'un véhicule à partir des données fournies. »
- **Oral DP** : « Quel est le CRKM de votre principal véhicule ? Comment l'avez-vous établi ? »

---

## 📌 Synthèse à retenir

### Les 3 catégories de coûts

| Catégorie | Imputation | Postes types |
|---|---|---|
| **Fixes** | Annuelles · indépendantes km | Amortissement, assurance, salaire CDI, taxes |
| **Variables** | Au km roulé | Gazole, pneus, entretien, péages |
| **Structure** | Au prorata | Loyer agence, compta, commercial |

### Formule CRKM

> **CRKM total = (Σ charges fixes + Σ charges variables × km + Σ structure) ÷ km annuels**
>
> **CRKM facturable = CRKM total ÷ (1 - taux retour à vide)**

### Ordres de grandeur 2026 (référentiel CNR)

| Véhicule | CRKM total | CRKM facturable (avec vide) |
|---|---|---|
| **VUL 3,5 t régional** | 1,34 €/km | 1,91 €/km |
| **Porteur 19 t** | 1,55 €/km | 2,07 €/km |
| **PL 40 t longue distance** | 1,84 €/km | 2,24 €/km |

> ⚠️ **Les 4 règles d'or du calcul de coût**
>
> - **Coût employeur** = brut conducteur × **1,42**
> - **Gazole HT-TICPE** : récupérer la TICPE 15,9 c€/L avant calcul
> - **Retour à vide** : diviser le CRKM par **(1 − taux vide)**
> - **Structure** = **12-18 %** des coûts directs en PME
$lessonG1$,
'Décomposer un coût de revient en 3 catégories (fixes, variables, structure), maîtriser la méthode CNR, calculer le coût employeur conducteur (× 1,42), prendre en compte le retour à vide et établir un CRKM facturable fiable pour VUL, porteur et PL.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Construire un prix de vente et une marge cible
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Construire un prix de vente et une marge cible',
    'prix-vente-marge-cible',
    2, 50,
$lessonG2$
# Construire un prix de vente et une marge cible

> 🎯 **Objectifs pédagogiques**
>
> - **Distinguer** marge brute, marge nette et taux de marque.
> - **Appliquer** les 3 méthodes de tarification : km, forfait, horaire.
> - **Optimiser** le taux de remplissage et le prix en charge partielle.
> - **Définir** une marge cible par segment client (express, économique, équilibré).
> - **Construire** un prix de vente compétitif sans casser sa marge.

---

## Introduction

Connaître son CRKM, c'est nécessaire mais pas suffisant. **À CRKM identique, deux entreprises peuvent vendre 30 % plus cher** simplement parce qu'elles maîtrisent la construction du prix de vente. C'est la **différence entre le transporteur low-cost** (15 % de pertes par an) et le **transporteur premium** (15-22 % de marge nette).

Cette leçon vous donne les **3 méthodes officielles** de tarification utilisées par les transporteurs français — tarif au km, forfait par voyage, tarif horaire — avec leurs avantages, leurs pièges et **3 cas chiffrés** complets sur un Lille-Marseille en variante express, économique et équilibré.

Le pro ne « met pas un prix au pifomètre ». Il calcule, il segmente, il défend ses marges devant l'acheteur. **À la fin de cette leçon, vous saurez justifier votre prix** chiffres en main.

---

## 1. Les notions de marge

### 1.1 Marge brute vs marge nette

| Notion | Formule | Usage |
|---|---|---|
| **Marge brute** | (Prix vente − coût direct) ÷ Prix vente | Couvre charges fixes + variables |
| **Marge nette** | (Prix vente − coût total avec structure) ÷ Prix vente | Couvre tout · vrai bénéfice |
| **Taux de marque** | Marge ÷ Prix vente | Pour client (vu de l'acheteur) |
| **Coefficient multiplicateur** | Prix vente ÷ Coût | Pour atelier (1,2 = +20 %) |

### 1.2 Pourquoi distinguer brute et nette ?

**Exemple concret** :
- Coût direct (fixe + variable) : 1 000 €.
- Coût avec structure : 1 180 € (structure +18 %).
- Vous vendez 1 200 € HT.
- **Marge brute** : (1 200 − 1 000) / 1 200 = **16,7 %**.
- **Marge nette** : (1 200 − 1 180) / 1 200 = **1,7 %**.

⚠️ **Piège classique** : se croire à 17 % de marge alors qu'on est en réalité à 1,7 %. Toute petite contre-performance (panne, retard, litige) plonge dans la perte.

### 1.3 Cible de marge sectorielle

| Marge nette | Niveau | Pérennité |
|---|---|---|
| < 5 % | Précaire | Pas d'investissement, dette difficile |
| **5-10 %** | Standard | Renouvellement véhicules possible |
| **10-15 %** | Confortable | Croissance maîtrisée |
| **15-22 %** | Premium | Marge suffisante pour formation, R&D |
| > 25 % | Exceptionnel | Niche très protégée |

**Cible standard** : **15 % minimum** sur la marge brute (couvre structure + risque), **20 %** en cible.

---

## 2. Méthode 1 — Tarif au kilomètre

### 2.1 Principe

Formule : **Prix de vente HT = CRKM facturable × Distance × (1 + taux marge)**

Ou en passant par le coefficient multiplicateur : **PV = Coût × k**, avec k = 1 / (1 − marge).

| Marge cible | Coefficient k |
|---|---|
| 15 % | 1,176 |
| 18 % | 1,219 |
| 20 % | 1,250 |
| 25 % | 1,333 |
| 30 % | 1,429 |

### 2.2 Cas concret : Lille-Marseille en VUL

- Distance Lille-Marseille : **1 020 km**.
- VUL Renault Trafic, CRKM facturable : **1,91 €/km** (cf. Leçon 1).
- Marge cible : **20 %**.

**Prix de vente** = 1,91 × 1 020 × 1,25 = **2 435 € HT**.

### 2.3 Cas concret : Lille-Marseille en PL 40 t

- Distance : 1 020 km.
- PL 40 t, CRKM facturable : **2,24 €/km**.
- Marge cible : **18 %**.

**Prix de vente** = 2,24 × 1 020 × 1,219 = **2 785 € HT**.

### 2.4 Avantages et limites

| ✅ Avantages | ❌ Limites |
|---|---|
| Simple à calculer | Ne tient pas compte du volume |
| Compréhensible client | Inadapté pour multi-points |
| Bonne pour longues distances | Impossible si retours/zones difficiles |

⚠️ **Attention** : sur des **trajets courts (< 80 km)**, le tarif au km sous-évalue car les **frais fixes voyage** (chargement, déchargement, péages d'entrée) ne sont pas amortis.

---

## 3. Méthode 2 — Forfait par voyage

### 3.1 Principe

Formule : **Prix forfait HT = (CRKM × distance) + Frais fixes voyage + Marge**

Frais fixes voyage typiques :
- Péages aller-retour : 50-150 €.
- Repas conducteur (grand déplacement) : 22 €/jour.
- Découcher : 50 €/nuit.
- Pénalités créneau GMS : 100-300 € (provision).

### 3.2 Cas concret : Lille-Marseille en PL 40 t — variante express

**Données** :
- Distance : 1 020 km aller + 1 020 retour à 80 % vide = équivalent 1 836 km roulés.
- CRKM facturable : 2,24 €/km.
- Trajet en 1 jour 1 nuit (38 h amplitude réglementaire).
- Péages aller-retour : 145 €.
- 1 découcher + 1 grand déplacement : 50 + 22 = 72 €.
- Marge cible : **22 %** (express = premium).

**Calcul** :
- Coût km : 2,24 × 1 836 = **4 113 €**.
- Frais fixes voyage : 145 + 72 = **217 €**.
- Sous-total coût : **4 330 €**.
- Avec marge 22 % : 4 330 / 0,78 = **5 551 € HT**.

### 3.3 Cas concret : Lille-Marseille — variante économique

**Données** :
- Idem mais **avec retour chargé garanti** (groupage) à 50 % de remplissage.
- Distance facturée client : aller seul 1 020 km.
- CRKM utile : 1,84 €/km (sans abattement vide car retour chargé partiellement).
- Péages aller seul : 75 €.
- Pas de découcher (livraison J+2 OK).
- Marge cible : **15 %** (économique = volume).

**Calcul** :
- Coût km : 1,84 × 1 020 = **1 877 €**.
- Frais fixes voyage : 75 €.
- Sous-total : **1 952 €**.
- Avec marge 15 % : 1 952 / 0,85 = **2 296 € HT**.

### 3.4 Cas concret : Lille-Marseille — variante équilibrée

**Données** :
- Trajet J+1 sans découcher contractuel.
- Retour à vide 30 %.
- CRKM facturable : 2,24 / 0,7 × (1 - 0,30) = 2,24 €/km.
- Péages : 95 €.
- Marge : **18 %**.

**Calcul** :
- Coût km : 2,24 × 1 020 = **2 285 €**.
- Frais fixes : 95 €.
- Sous-total : **2 380 €**.
- Avec marge 18 % : 2 380 / 0,82 = **2 902 € HT**.

### 3.5 Comparatif des 3 variantes Lille-Marseille PL 40 t

| Variante | Délai | Marge | Prix HT |
|---|---|---|---|
| **Express** (J+1 8h) | 38 h amplitude | 22 % | 5 551 € |
| **Équilibrée** (J+1 fin journée) | 24 h | 18 % | 2 902 € |
| **Économique** (J+2 groupage) | 48 h | 15 % | 2 296 € |

**Écart 1 → 3** : **142 %**. Plus le délai est court, plus le prix est élevé. C'est la **logique du yield management**.

---

## 4. Méthode 3 — Tarif horaire

### 4.1 Principe

Formule : **Prix horaire HT = CRKM × Vitesse moyenne × heures + Marge**

Adapté aux **courses urbaines** (livraison express, distribution magasins, transport-déménagement) où le kilométrage est faible mais le temps est élevé.

**Vitesse moyenne urbaine** : 25 km/h (Paris, Lyon, Marseille). **Périurbain** : 50 km/h. **Autoroute** : 80 km/h.

### 4.2 Cas concret : course urbaine VUL Paris

- 1 chauffeur + 1 VUL Renault Trafic.
- Vitesse moyenne urbaine : 25 km/h.
- Mission de 4 h : 4 × 25 = **100 km**.
- CRKM facturable : 1,91 €/km ⇒ coût km : 1,91 × 100 = **191 €**.
- Coût horaire conducteur (chargé) : 18 €/h × 4 = **72 €** (déjà compris en partie dans CRKM, à ne pas double-compter).
- Marge 25 % : 191 × 1,333 = **255 € HT** soit **64 €/heure**.

### 4.3 Tarif horaire indicatif 2026 (urbain)

| Véhicule | Tarif horaire HT | Hors péage / extras |
|---|---|---|
| **2 roues / coursier** | 35-50 €/h | — |
| **VUL 3,5 t** | 55-75 €/h | + 0,50 €/km au-delà de 25 km |
| **Porteur 7,5 t avec hayon** | 85-110 €/h | + 1,20 €/km |
| **Porteur 19 t** | 130-160 €/h | + 1,80 €/km |
| **Camion-grue / spécifique** | 200-350 €/h | Surcoût ADR/exceptionnel |

---

## 5. Optimiser le chargement et le prix

### 5.1 Taux de remplissage

**Définition** : taux de remplissage = (volume / poids utilisé) ÷ (capacité véhicule).

| Niveau | Taux | Conséquence prix |
|---|---|---|
| 100 % (pleine charge) | Cible idéale | Prix au km optimal |
| 70-90 % | Bon | Prix légèrement majoré |
| 50-69 % | Moyen | Facturer en t.km ou forfait |
| < 50 % | Faible | Refus ou forfait haut |

### 5.2 Palettes au sol vs gerbées

**Cas concret** : un client veut envoyer 30 palettes EUR (1 m de hauteur, 600 kg).

- **Au sol seulement** : 33 places sur semi → 30 palettes = 1 semi presque plein.
- **Gerbées (2 niveaux)** : 33 places × 2 = 66 disponibles → 30 palettes = 45 % du semi.

**Conséquence prix** :
- Au sol : 1 semi entier facturé pleine charge.
- Gerbées : possibilité de groupage avec un autre client → **prix divisé par 2** pour le client mais **mêmes coûts** pour le transporteur (qui empoche la marge supplémentaire en facturant 2 fois 50 %).

⚠️ **Astuce pro** : **toujours demander si gerbable** lors de la qualification SACO. Une palette gerbable peut diviser le prix client par 2 et **augmenter votre marge brute**.

### 5.3 Cas pratique : 12 palettes vs 33 palettes

| Configuration | Mode | Prix client HT | Marge transporteur |
|---|---|---|---|
| 12 palettes EUR seules | Forfait LTL (groupage) | 850 € | 25 % |
| 12 palettes EUR + groupage 21 places | Mutualisé | 850 € (× 2 clients) | 35 % |
| 33 palettes EUR | Pleine charge | 2 800 € | 18 % |

**Leçon** : le LTL (Less Than Truckload) est plus rentable que la pleine charge **si** vous avez le réseau de groupage. Sinon, accepter la pleine charge mais facturer correctement.

---

## 6. Schéma de construction d'un prix

### 6.1 Méthode en 6 étapes

:::flow
1. Calcul CRKM facturable | Charges fixes + variables + structure ÷ km · diviser par (1 − taux vide)
2. Identifier distance et frais voyage | km totaux · péages · découchers · repas
3. Choisir méthode tarification | Km · forfait · horaire selon contexte
4. Définir marge cible par segment | 15 % minimum · 20 % standard · 22-25 % premium
5. Calculer prix HT | (Coût total) × coefficient marge
6. Ajouter TVA + conditions | TVA 20 % · validité 30 j · conditions paiement
:::

### 6.2 Cas pratique d'examen — Lyon-Bordeaux porteur 19 t

**Énoncé** : Un client demande un transport de 18 palettes EUR (12 t, gerbables, hauteur 1 m), Lyon-Bordeaux, livraison J+1 14h, hayon non requis. Votre porteur 19 t a un CRKM facturable de 2,07 €/km. Distance Lyon-Bordeaux : 555 km. Péages estimés : 78 €. Repas conducteur : 22 €. Marge cible : 18 %.

**Construire le prix.**

**Correction** :

- Coût km : 2,07 × 555 = **1 149 €**.
- Frais voyage (péages + repas) : **100 €**.
- Sous-total coûts : **1 249 €**.
- Marge 18 % : 1 249 / 0,82 = **1 523 € HT**.
- TVA 20 % : 305 €.
- **Prix TTC : 1 828 €**.

⇒ Devis pro : **1 523 € HT, 1 828 € TTC**, validité 30 jours, conditions paiement 30 jours fin de mois.

---

## 7. Mini-exercice à faire seul

**Énoncé** : Vous devez construire un prix pour un trajet Paris-Strasbourg en porteur 19 t. CRKM facturable : 2,15 €/km. Distance : 490 km. Péages : 65 €. Repas + grand déplacement : 50 €. Marge cible : 20 %.

**Calculez le prix HT et TTC.**

> 💡 Réponse en fin de module (corrections § 4).

---

## 8. Glossaire

- **Marge brute** : (PV − coût direct) ÷ PV. Couvre charges fixes + variables.
- **Marge nette** : (PV − coût total) ÷ PV. Vrai bénéfice après structure.
- **Coefficient multiplicateur (k)** : k = 1 / (1 − marge). 20 % = k 1,25.
- **LTL** : Less Than Truckload (chargement partiel mutualisé).
- **FTL** : Full Truckload (camion complet dédié).
- **Gerbage** : empilement vertical de palettes (gain de capacité).
- **t.km** : tonne-kilomètre (unité de productivité transport).
- **Yield management** : gestion dynamique des prix selon délai et capacité.
- **Découcher** : forfait conducteur pour nuit hors domicile (CCN 50 €/nuit).
- **Grand déplacement** : indemnité repas du conducteur (CCN 22 €/jour).

---

## 9. Synthèse opérationnelle

1. **3 méthodes** : km, forfait, horaire — à combiner selon contexte.
2. **Marge cible** : **15 % min** (couvre structure), **20 % standard**, **22-25 % premium express**.
3. **Coefficient k** : k = 1 / (1 − m). Marge 20 % = k 1,25.
4. **Frais fixes voyage** : péages, repas, découcher, pénalités.
5. **Variantes prix** : express > équilibré > économique selon yield.
6. **Gerbage** : optimise capacité et marge brute.
7. **Cible** : 15 % min sur tous segments, sinon refuser ou renégocier.
8. **Tarif horaire** pour urbain ; tarif km pour longue distance.

---

## ⚠️ Points de vigilance

- **Marge brute ≠ nette** : ne jamais s'arrêter au brut sans intégrer la structure.
- **Trajets courts** (< 80 km) : utiliser un forfait, pas le tarif km pur.
- **Retour à vide** : intégré dans le CRKM facturable, pas à recompter.
- **Marges < 10 %** : tout litige (panne, retard) plonge dans la perte sèche.

## 💡 Astuces pro

- **Calculateur Excel** : 3 onglets (km / forfait / horaire) avec CRKM véhicule en variable.
- **Veille tarifaire** : observer Trans.eu, B2P, Truckscanner pour comprendre la fourchette de marché.
- **Segmentation** : 3 grilles tarifaires par segment client (PME, grand compte, e-commerce).
- **Devis multi-options** : proposer toujours 2-3 variantes (express/équilibré/économique) augmente la conversion de 35 %.

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : différence marge brute/nette, formule du coefficient k, méthodes de tarification.
- **QR cas pratique** : « Construisez le prix de vente d'un trajet X-Y avec les données fournies. »
- **Oral DP** : « Quelle est votre marge cible standard ? Sur quels segments dépassez-vous 20 % ? »

---

## 📌 Synthèse à retenir

### Marge brute vs nette

| Notion | Calcul | Usage |
|---|---|---|
| **Marge brute** | (PV − coût direct) ÷ PV | Tableau de bord rapide |
| **Marge nette** | (PV − coût total) ÷ PV | Vrai bénéfice durable |
| **Coefficient k** | 1 ÷ (1 − marge) | Calcul rapide PV à partir du coût |

### Les 3 méthodes de tarification

| Méthode | Quand | Formule |
|---|---|---|
| **Au km** | Longue distance | CRKM × km × k |
| **Forfait** | Trajet bouclé J+1 | Coûts directs + frais voyage + marge |
| **Horaire** | Urbain / location véhicule | CRKM × vitesse × heures + marge |

### Variantes Lille-Marseille PL 40 t

| Variante | Délai | Marge | Prix HT |
|---|---|---|---|
| **Express** | J+1 8h | 22 % | 5 551 € |
| **Équilibrée** | J+1 fin journée | 18 % | 2 902 € |
| **Économique** | J+2 groupage | 15 % | 2 296 € |

> ⚠️ **Les 4 règles d'or de la construction de prix**
>
> - **Marge minimum 15 %** (sinon refuser)
> - **Toujours majorer** les trajets courts (< 80 km) en forfait
> - **Retour à vide** intégré dans le CRKM facturable (pas à compter 2 fois)
> - **3 variantes** (express / équilibré / économique) pour augmenter la conversion
$lessonG2$,
'Maîtriser les 3 méthodes de tarification (km, forfait, horaire), construire un prix de vente avec marge cible 15-22 % selon segment, optimiser le taux de remplissage, gérer les variantes express/équilibré/économique pour augmenter la conversion devis.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Méthodologie de cotation et structure du devis
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Méthodologie de cotation et structure du devis',
    'methodologie-cotation-devis',
    3, 50,
$lessonG3$
# Méthodologie de cotation et structure du devis

> 🎯 **Objectifs pédagogiques**
>
> - **Appliquer** la méthode de cotation en 6 étapes (de la qualification à la conversion).
> - **Rédiger** un devis professionnel conforme aux mentions légales LME.
> - **Choisir** le régime de TVA adapté (franchise / réel simplifié / réel normal).
> - **Définir** une stratégie tarifaire (pénétration, écrémage, alignement).
> - **Éviter** les 5 pièges classiques du devis transport.

---

## Introduction

Un devis transport mal rédigé = **30 % de litiges** + **20 % de pertes** sur les marges escomptées (FNTR 2025). À l'inverse, un devis structuré, précis et conforme = **+25 % de conversion** par rapport à un devis Excel basique.

Le devis n'est pas une feuille de prix. C'est un **document juridiquement engageant** qui, une fois signé, vaut **bon de commande**. À ce titre, il doit :
- Couvrir toutes les **mentions légales obligatoires** (art. L. 441-9 C. com.).
- Anticiper les **conditions d'exécution** (validité, paiement, indemnités).
- Verrouiller les **clauses tarifaires** (révisions gazole, surcoûts).
- Renforcer votre **image pro** face à la concurrence.

Cette leçon vous donne **la méthode complète** : du premier clic dans votre TMS à la signature du client, en passant par la structure exacte du devis et le choix du régime fiscal le plus malin.

---

## 1. La méthode de cotation en 6 étapes

### 1.1 Vue d'ensemble

:::flow
1. Qualification SACO | Recueillir les 18 informations · refuser si incomplet
2. Analyse des contraintes | Légales · opérationnelles · capacitaires
3. Calcul des coûts | CRKM × km + frais voyage + structure
4. Détermination de la marge | 15 % min · 18-22 % standard · selon segment
5. Mise en forme du devis | En-tête · prestation · prix · conditions · CGV
6. Suivi et conversion | Envoi · accusé · relances J+1/3/7/14 · signature
:::

### 1.2 Durée moyenne par étape

| Étape | Durée | Outil |
|---|---|---|
| 1. Qualification | 15-20 min | Mail / téléphone / TMS |
| 2. Contraintes | 10 min | Check-list interne |
| 3. Coûts | 10-15 min | Calculateur CRKM Excel |
| 4. Marge | 5 min | Grille tarifaire |
| 5. Devis | 10-15 min | Template PDF / TMS |
| 6. Suivi | Continu | CRM (Pipedrive, HubSpot) |

⇒ **Total** : 50-65 minutes. Avec template + CRKM préparé : **15-20 minutes**.

---

## 2. Anatomie d'un devis professionnel

### 2.1 Structure standard 1 page recto

| Section | Contenu | Importance |
|---|---|---|
| **En-tête émetteur** | Logo, raison sociale, SIRET, RCS, n° TVA, RIB | Obligatoire |
| **Référence devis** | N° devis (séquence), date émission, date validité | Obligatoire |
| **Coordonnées client** | Nom, adresse, contact, référence interne | Obligatoire |
| **Description prestation** | Origine → destination, marchandise, type véhicule, dates | Obligatoire |
| **Détail prix HT** | Transport, hayon, ADR, surcoûts | Obligatoire |
| **TVA + TTC** | Taux 20 %, total TTC | Obligatoire |
| **Conditions paiement** | 30-60 jours fin mois, pénalités, escompte | Obligatoire LME |
| **CGV transporteur** | Lien ou annexe | Recommandé |
| **Signature** | Bon pour accord, date, cachet | Pour valider |

### 2.2 Mentions obligatoires LME (art. L. 441-9 C. com.)

**Pour devis et facture B2B** :

1. **Identité émetteur** : nom, adresse, SIRET, RCS, n° TVA intracom (si > 10 k€/an).
2. **Identité client** : nom, adresse, contact, n° TVA si UE.
3. **Date émission**.
4. **Numérotation séquentielle** sans rupture.
5. **Description précise** prestation (origine, destination, marchandise, dates).
6. **Prix HT** unitaire et total.
7. **Taux et montant TVA**.
8. **Prix TTC**.
9. **Conditions paiement** : date d'échéance.
10. **Pénalités de retard** : taux BCE + 10 points obligatoire.
11. **Indemnité forfaitaire 40 €** (art. L. 441-10 C. com.).
12. **Validité du devis** (souvent 30 jours).

⚠️ **Sanction manquement** : amende **75 000 €** (PP) / **375 000 €** (PM). À ne pas négliger.

### 2.3 Cas concret : devis Lille-Marseille PL 19 t

**Données client** :
- DO : SARL Industrie XY, SIRET 123 456 789 00012.
- Adresse : 12 rue Lavoisier, 59000 Lille.
- Marchandise : 18 palettes EUR (12 t, gerbables, hauteur 1,1 m).
- Origine : usine Lille. Destination : entrepôt Marseille (8 quai Joliette).
- Dates : chargement mardi 8h, livraison mercredi 14h.
- Hayon : non requis.
- Valeur : 35 000 € (déclarée écrite).

**Calcul** :
- Distance Lille-Marseille : 1 020 km.
- CRKM facturable PL 19 t : **2,07 €/km**.
- Coût km : 2,07 × 1 020 = **2 111 €**.
- Péages aller : 95 €.
- Repas + découcher : 22 + 50 = 72 €.
- Frais voyage : **167 €**.
- Sous-total coûts : **2 278 €**.
- Marge cible 18 % : 2 278 / 0,82 = **2 778 € HT**.
- TVA 20 % : 556 €.
- **Total TTC : 3 334 €**.

**Mise en forme du devis** :

```
SARL TRANSPORTS DUPONT — Devis n° D-2026-0457
Date émission : 7 mai 2026 — Validité : 6 juin 2026 (30 jours)

Client : SARL INDUSTRIE XY
SIRET 123 456 789 00012 — 12 rue Lavoisier, 59000 Lille

PRESTATION
Transport routier de marchandises générales
Lille (59) → Marseille (13)
Marchandise : 18 palettes EUR (12 t, gerbables H 1,1 m)
Véhicule : Porteur 19 t avec bâche
Chargement : mardi 7h-9h
Livraison : mercredi 13h-15h

DÉTAIL HT
Transport routier ............................ 2 583,00 €
Péages aller ..................................   95,00 €
Indemnités conducteur (repas + découcher) .   72,00 €
Sous-total HT ................................. 2 750,00 €
Remise forfaitaire ............................   28,00 €
TOTAL HT ...................................... 2 778,00 €

TVA 20 % ......................................   555,60 €
TOTAL TTC ..................................... 3 333,60 €

CONDITIONS
- Paiement : 30 jours fin de mois date facture (LME)
- Pénalités de retard : taux BCE + 10 points (en 2026 : 14,5 %/an)
- Indemnité forfaitaire : 40 € (art. L. 441-10 C. com.)
- Validité du devis : 30 jours
- CGV transporteur : annexées et applicables
- Indexation gazole : clause CCN annexe (mouvement +/- 0,02 €/L)

Bon pour accord :
Date : ___________
Signature client + cachet : ___________
```

### 2.4 Devis multi-prestations

Si vous proposez **plusieurs variantes** (express, équilibré, économique), structurer en 3 colonnes ou en 3 sections distinctes. Augmente la conversion de **+35 %** : le client choisit, il s'engage psychologiquement.

---

## 3. Le régime de TVA

### 3.1 Choix du régime selon CA

| Régime | Seuil CA HT | Caractéristiques |
|---|---|---|
| **Franchise en base** | < 91 900 € (services) | Pas de TVA facturée ni déduite |
| **Réel simplifié** | 91 900 - 254 000 € | Déclaration annuelle CA12, acomptes semestriels |
| **Réel normal** | > 254 000 € | Déclaration mensuelle CA3 |

⚠️ **Cas du transporteur** : la franchise en base est **rare** (CA dépasse vite 91 900 €). Le **réel normal** est la norme.

### 3.2 TVA intracommunautaire

Pour transports **France → autre pays UE** :
- Si client B2B avec n° TVA intracom valide : **autoliquidation par le client** ⇒ **TVA 0 %** sur la facture transporteur.
- Mention obligatoire : « Autoliquidation — art. 196 directive 2006/112/CE ».
- Vérifier le n° TVA intracom du client sur **VIES** (site Commission européenne).

### 3.3 TVA sur récupération TICPE gazole

Le gazole pro est doublement avantagé :
- **TVA 20 %** récupérable.
- **TICPE 15,9 c€/L** récupérable (semestrielle).

**Attention** : seules les entreprises au **réel** récupèrent. La franchise en base ne récupère pas (compense le non-paiement de TVA collectée).

---

## 4. Stratégies tarifaires

### 4.1 Les 3 stratégies classiques

| Stratégie | Logique | Quand l'utiliser |
|---|---|---|
| **Pénétration** | Prix bas pour gagner part de marché | Nouveau client, segment concurrentiel |
| **Écrémage** | Prix haut sur niche premium | ADR, exceptionnel, urgence |
| **Alignement** | Prix moyen marché | Volume stable, marges normales |

### 4.2 Stratégie de pénétration

**Principe** : prix 5-10 % en dessous du marché pour gagner un client clé, **mais avec contrat annuel** (sécurise volume et marge).

**Cas concret** : un nouveau client GMS, 50 voyages/an. Vous chiffrez à 1 800 € HT/voyage (au lieu de 2 000 € marché) sous condition de 50 voyages garantis sur 12 mois. Marge brute 15 % au lieu de 22 %, mais **CA garanti 90 000 € pour 1 client unique** = visibilité pour amortir charges fixes.

⚠️ **Risque** : prix bas = client habitué = difficile à remonter ensuite. Toujours signer un **contrat annuel** avec clause de revalorisation.

### 4.3 Stratégie d'écrémage

**Principe** : prix premium 20-40 % au-dessus du marché pour des prestations à valeur ajoutée.

**Cas concret** : transport de matériel médical (vaccins, IRM) en J+1 8h avec sécurité haute. Prix 50 % au-dessus du marché transport classique. Clients : laboratoires, hôpitaux, fabricants matériel. **Marge nette 25-30 %**.

### 4.4 Stratégie d'alignement

**Principe** : prix dans la fourchette marché. Convient aux PME standards sans différenciation forte.

**Source de référence marché** :
- **Indices CNR** : longue distance, régional, frigo, citerne.
- **Bourses de fret** : Trans.eu, B2P, Truckscanner.
- **Réseau** : confrères, syndicats FNTR/OTRE.

---

## 5. Les 5 pièges du devis

### 5.1 Piège n° 1 : oublier le hayon

**Risque** : facturer 1 800 € un transport, arriver sur site sans hayon → impossible de décharger → retour avec facture impayée.

**Solution** : champ obligatoire dans le TMS « hayon nécessaire oui/non » + provision +200 € si oui.

### 5.2 Piège n° 2 : oublier l'ADR

**Risque** : transport accepté sans surcoût ADR → conducteur non formé ou véhicule non équipé → infraction administrative + amende 1 500 €.

**Solution** : check-list ADR à la qualification (n° ONU, classe, groupe emballage). Surcoût 15-30 % facturé d'office.

### 5.3 Piège n° 3 : oublier le créneau client

**Risque** : livraison hors créneau GMS → pénalité 100-300 € ⇒ marge détruite.

**Solution** : créneau **écrit** dans le devis, clause de tolérance ± 30 min négociée.

### 5.4 Piège n° 4 : oublier la surcharge gazole

**Risque** : prix signé en avril à gazole 1,55 €/L → en juillet, gazole à 1,68 €/L → vous payez la différence.

**Solution** : clause d'indexation gazole **obligatoire** dans le devis (cf. Leçon 4).

### 5.5 Piège n° 5 : oublier les conditions de paiement

**Risque** : facture impayée, action en recouvrement difficile sans clause LME explicite.

**Solution** : mentions LME complètes (taux BCE + 10, indemnité 40 €, juridiction de votre tribunal de commerce).

---

## 6. Cas pratique d'examen

**Énoncé** : Un client industriel demande un devis pour 24 palettes EUR (15 t, gerbables, hauteur 1,2 m), Lyon → Strasbourg, livraison J+1 14h, hayon non requis. Votre porteur 26 t, CRKM facturable 2,15 €/km. Distance 490 km. Péages 65 €. Repas + grand déplacement 50 €. Marge cible 20 %.

**1. Calculez le prix HT et TTC.**
**2. Listez les 8 mentions obligatoires LME.**
**3. Identifiez 3 pièges potentiels et leur traitement.**

**Correction** :

**1. Prix** :
- Coût km : 2,15 × 490 = **1 054 €**.
- Frais voyage : **115 €**.
- Sous-total : **1 169 €**.
- Marge 20 % : 1 169 / 0,80 = **1 461 € HT**.
- TVA 20 % : 292 €.
- **Total TTC : 1 753 €**.

**2. Mentions LME** :
1. SIRET émetteur.
2. Date facture/devis.
3. N° séquentiel.
4. Description prestation.
5. Prix HT + TVA + TTC.
6. Date d'échéance.
7. Pénalités BCE + 10.
8. Indemnité forfaitaire 40 €.

**3. Pièges** :
- **Hayon** : préciser explicitement « hayon non requis ».
- **Indexation gazole** : clause CCN annexe.
- **Validité 30 j** : éviter qu'un client commande 6 mois plus tard au prix d'avril.

---

## 7. Mini-exercice à faire seul

**Énoncé** : Vous devez rédiger le devis d'un transport Lille-Toulouse en VUL Renault Trafic. CRKM 1,91 €/km. Distance 880 km. Péages 65 €. Marge 18 %.

**Calculez le prix HT, TTC, et listez les 5 mentions LME minimales.**

> 💡 Réponse en fin de module (corrections § 4).

---

## 8. Glossaire

- **LME** : Loi de Modernisation de l'Économie 2008. Délais paiement B2B max 60 j.
- **Pénalité BCE + 10** : taux d'intérêt de retard (en 2026 : ≈ 14,5 %/an).
- **Indemnité forfaitaire 40 €** : indemnité de recouvrement art. L. 441-10 C. com.
- **CGV** : Conditions Générales de Vente du transporteur.
- **TICPE** : Taxe Intérieure de Consommation des Produits Énergétiques. Récupérable 15,9 c€/L.
- **VIES** : système européen de validation des n° TVA intracom.
- **Pénétration** : stratégie prix bas pour gagner part de marché.
- **Écrémage** : stratégie prix haut sur niche premium.
- **Akanea / Pipedrive** : outils TMS et CRM transport.

---

## 9. Synthèse opérationnelle

1. **Méthode 6 étapes** : qualification → contraintes → coûts → marge → devis → suivi.
2. **Devis pro 1 page** : en-tête, référence, client, prestation, prix, conditions, CGV, signature.
3. **Mentions LME 12** : SIRET, dates, n°, description, HT/TVA/TTC, échéance, BCE+10, 40 €, validité.
4. **Régime TVA** : franchise (< 91 900 €), simplifié (< 254 000 €), normal (> 254 000 €).
5. **Stratégies** : pénétration / écrémage / alignement selon segment.
6. **5 pièges** : hayon, ADR, créneau, gazole, conditions paiement.
7. **Multi-options** (express/équilibré/éco) augmente conversion +35 %.
8. **Validité 30 j** standard. Indexation gazole obligatoire.

---

## ⚠️ Points de vigilance

- **Devis sans validité écrite** : client peut commander 6 mois plus tard au prix d'avril.
- **Mentions LME** : sanction 75 000 € PP / 375 000 € PM si manquement.
- **Hayon, ADR, créneau** : 3 pièges classiques à intégrer en check-list.
- **Multi-prestations** : présenter 2-3 variantes augmente conversion mais n'oubliez pas les coûts différenciés.

## 💡 Astuces pro

- **Templates PDF** : créer 5 templates (express / équilibré / éco / ADR / international) pour gagner 70 % temps.
- **Outils** : Akanea TMS (devis automatique), Pipedrive (suivi), Yousign (signature électronique).
- **Numérotation** : préfixe année + n° séquence (D-2026-0001) pour traçabilité comptable.
- **Annexer CGV** par défaut au devis = opposabilité automatique en cas de litige.

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : mentions LME, méthode 6 étapes, choix régime TVA.
- **QR cas pratique** : « Rédigez un devis complet à partir des données client. »
- **Oral DP** : « Quelles mentions obligatoires placez-vous toujours dans vos devis ? »

---

## 📌 Synthèse à retenir

### La méthode de cotation en 6 étapes

| Étape | Durée | Outil |
|---|---|---|
| 1. Qualification SACO | 15-20 min | Mail / TMS |
| 2. Analyse contraintes | 10 min | Check-list |
| 3. Calcul coûts | 10-15 min | Calculateur CRKM |
| 4. Marge cible | 5 min | Grille tarifaire |
| 5. Devis structuré | 10-15 min | Template PDF |
| 6. Suivi conversion | Continu | CRM Pipedrive |

### Mentions LME obligatoires (art. L. 441-9 et L. 441-10)

- Identité émetteur + client (SIRET, RCS, n° TVA)
- Date + numérotation séquentielle
- Description précise prestation
- Prix HT + TVA + TTC détaillés
- **Date d'échéance** paiement
- **Pénalités de retard taux BCE + 10**
- **Indemnité forfaitaire 40 €**
- Validité du devis (30 j)

> 📌 **Sanction manquement LME : 75 000 € (PP) / 375 000 € (PM)**

### Régime TVA selon CA

| Régime | Seuil CA HT | Pour |
|---|---|---|
| Franchise base | < 91 900 € | Très petites structures |
| Réel simplifié | < 254 000 € | PME en croissance |
| Réel normal | > 254 000 € | Standard transporteur |

### Les 3 stratégies tarifaires

- **Pénétration** : -5 à -10 % marché, contrat annuel
- **Écrémage** : +20 à +40 % marché, niches ADR / express / médical
- **Alignement** : prix marché, marge 15-20 %

> ⚠️ **Les 5 pièges du devis transport**
>
> 1. **Oubli hayon** → client refuse à la livraison
> 2. **Oubli ADR** → conducteur non habilité, amende 1 500 €
> 3. **Oubli créneau** → pénalité GMS 100-300 €
> 4. **Oubli surcharge gazole** → marge mangée si gazole flambe
> 5. **Oubli conditions paiement** → recouvrement difficile
$lessonG3$,
'Maîtriser la méthode de cotation en 6 étapes (qualification → suivi), rédiger un devis professionnel conforme aux mentions obligatoires LME (art. L. 441-9), choisir le bon régime de TVA, appliquer une stratégie tarifaire (pénétration / écrémage / alignement) et éviter les 5 pièges classiques (hayon, ADR, créneau, gazole, paiement).'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Négociation, revalorisation et indexation gazole
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Négociation, revalorisation et indexation gazole',
    'negociation-revalorisation-gazole',
    4, 50,
$lessonG4$
# Négociation, revalorisation et indexation gazole

> 🎯 **Objectifs pédagogiques**
>
> - **Préparer** une négociation tarifaire avec break-even, BATNA et marge non négociable.
> - **Maîtriser** les techniques d'ancrage, contre-proposition et package multi-prestations.
> - **Appliquer** la clause d'indexation gazole obligatoire de la CCN Transport.
> - **Conduire** une revalorisation tarifaire annuelle (méthode et lettre type).
> - **Refuser** un client trop mal payé sans casser la relation.

---

## Introduction

**Selon le CNR 2025**, le gazole pèse **22-28 %** du CRKM longue distance. Une variation de **0,10 €/L** peut faire basculer un voyage rentable en perte sèche. Pourtant, **45 % des PME transport** n'appliquent **pas** la clause d'indexation gazole **obligatoire** prévue par la CCN Transport — perte estimée : **15 000 à 35 000 €/an par véhicule**.

De même, la **revalorisation tarifaire annuelle** est négligée : 38 % des transporteurs n'augmentent pas leurs tarifs en 5 ans, alors que les coûts ont grimpé de 22 % (URSSAF, gazole, salaires CCN). Résultat : **érosion de la marge nette de 7-12 points** sur la même période.

Cette leçon vous arme pour **3 actions essentielles** :
1. **Négocier** sans céder votre marge (techniques pro).
2. **Indexer** vos contrats au gazole automatiquement.
3. **Revaloriser** vos tarifs chaque année avec méthode et arguments.

À l'oral du DP RNCP 40990, ces compétences sont systématiquement testées car elles différencient le bon gestionnaire d'opérations du simple « preneur de commande ».

---

## 1. Préparer une négociation

### 1.1 Les 3 indicateurs essentiels

| Indicateur | Définition | Usage |
|---|---|---|
| **CRKM précis** | Coût de revient exact (cf. Leçon 1) | Plancher absolu de prix |
| **Break-even** | Prix minimum couvrant tous les coûts | Plancher de négociation |
| **BATNA** | Best Alternative To Negotiated Agreement | Plan B si négo échoue |

### 1.2 Calculer son break-even

**Formule** : Break-even = CRKM facturable × distance + frais voyage

**Exemple** : trajet Lille-Marseille en porteur 19 t.
- Coût km : 2,07 × 1 020 = 2 111 €.
- Frais voyage : 167 €.
- **Break-even = 2 278 €** (vente sous ce prix = perte).

⇒ Toute remise client ne peut pas faire **descendre sous 2 278 €**. Le « plancher de négo » est typiquement break-even **+ 10 % marge minimum** = **2 506 €**.

### 1.3 Définir sa BATNA

**Plan B** si la négociation échoue :
- **BATNA forte** : un autre client à qui vendre la même capacité au prix demandé. Vous pouvez refuser sans perte.
- **BATNA faible** : pas d'alternative immédiate. Vous êtes en position défavorable.

**Astuce pro** : avant chaque négociation, rappeler que vous avez **des demandes en attente** (vrai ou pseudo-vrai). Renforce votre position.

### 1.4 Cas concret : préparation d'une négo GMS

**Situation** : Client GMS Système U, 80 voyages/an Bordeaux-Paris, prix actuel 1 850 €/voyage. L'acheteur demande -8 % pour 2026 = **1 702 €/voyage**.

**Préparation** :
- CRKM facturable porteur 19 t : 2,07 €/km × 580 km = 1 201 € + 110 € frais voyage = **break-even 1 311 €**.
- Marge actuelle : (1 850 − 1 311) / 1 850 = **29 %** (très confortable).
- Marge à 1 702 € : (1 702 − 1 311) / 1 702 = **23 %** (encore confortable).
- **BATNA** : 2 demandes équivalentes en cours, possibilité d'optimiser groupage retour.
- **Décision** : accepter -8 % sous condition de **contrat 18 mois** + clause indexation gazole automatique.

---

## 2. Techniques de négociation

### 2.1 Technique 1 — L'ancrage

**Principe** : poser le **premier chiffre** comme ancre psychologique. Le client négociera autour de cette ancre.

**Exemple** :
- Mauvais : « Je peux vous faire 1 800 € HT ».
- Bon : « Le tarif marché est 2 100 € HT. Pour vous, premier client, je peux faire 1 950 € HT ».

⇒ Le client a en tête **1 950 €** comme « bon prix » et n'osera pas demander moins de 1 800 €.

### 2.2 Technique 2 — La contre-proposition systématique

**Principe** : ne **jamais** dire un « non » sec. Toujours contre-proposer.

**Exemple** :
- Client : « Pouvez-vous descendre à 1 700 € ? ».
- Mauvais : « Non, c'est impossible ».
- Bon : « À 1 700 €, je ne couvre plus mes coûts. En revanche, je peux faire **1 850 € avec retour à vide garanti** (gain pour vous : flexibilité) **ou 1 750 € avec engagement 12 mois 50 voyages**. ».

### 2.3 Technique 3 — Le package multi-prestations

**Principe** : transformer une remise prix en **gain volume ou services**.

**Exemple GMS** :
- Demande client : -10 % sur le tarif 2026.
- Contre-package : -5 % sur tarif **mais** :
  - +20 voyages de plus dans l'année (volume).
  - Service stockage 48 h offert sur 10 % des envois.
  - Échange électronique de données EDI offert (économie 1 500 €/an).
  - Reporting mensuel KPI livraison offert.

⇒ Client perçoit une **remise globale** de 12-15 %. Vous ne perdez que 5 % sur la marge unitaire mais gagnez en volume et fidélisation.

### 2.4 Technique 4 — La concession progressive

**Principe** : ne **jamais** céder une grosse concession d'un coup. Étaler.

**Mauvais** : -10 % d'un coup.
**Bon** : « -3 % aujourd'hui, -2 % de plus si vous engagez sur 12 mois, -2 % supplémentaires si paiement comptant en 15 jours, -2 % si tonnage supérieur à 100 000 t/an ». Au total -9 %, mais conditions multiples qui sécurisent.

### 2.5 Pièges de la négociation

| Piège | Risque | Parade |
|---|---|---|
| **« Tout le monde fait moins cher »** | Pression psychologique | Demander un comparatif écrit (jamais fourni) |
| **« On est en urgence »** | Forcer baisse rapide | Justifier le prix par la rareté capacité |
| **« On vous teste sur 1 voyage »** | 1 voyage à perte sans suite | Refuser ou ajouter clause volume |
| **« On paye dans 90 jours »** | Hors LME (60 j max) | Refuser ou facturer + frais financiers |

---

## 3. L'indexation gazole — clause obligatoire CCN

### 3.1 Cadre juridique

La **CCN Transport (n° 3085)**, art. 23 et **Loi n° 2006-10 du 5 janvier 2006** (loi Perben II) **rendent obligatoire** la clause d'indexation gazole pour tout contrat de transport routier.

⚠️ **L'absence de clause indexation gazole est sanctionnable** par le tribunal de commerce comme un déséquilibre significatif (art. L. 442-1 C. com.).

### 3.2 Formule officielle

**Formule de base** : Tarif révisé = Tarif initial × (1 + α × ΔGazole / GazoleRef)

Avec :
- **α** : coefficient gazole (= part du gazole dans le CRKM, typiquement **22-28 %** longue distance, **15-18 %** régional).
- **ΔGazole** : variation absolue du prix gazole (€/L) entre date contrat et date facturation.
- **GazoleRef** : prix gazole de référence (date contrat).

### 3.3 Cas concret : indexation à mi-année

**Données contrat** :
- Tarif initial signé : **2 000 €** par voyage Lyon-Bordeaux.
- Date signature : 1er janvier 2026.
- Gazole de référence : **1,55 €/L** (HT-TICPE, indice CNR janvier 2026).
- Coefficient gazole α : **0,25** (PL longue distance).

**Variation à mi-année** :
- Gazole 1er juillet 2026 : **1,68 €/L**.
- ΔGazole : 1,68 − 1,55 = **+0,13 €/L**.
- Variation relative : 0,13 / 1,55 = **+8,4 %**.

**Tarif révisé** :
- Coefficient appliqué : 0,25 × 8,4 % = **+2,1 %**.
- Tarif révisé = 2 000 × (1 + 2,1 %) = **2 042 €** par voyage.

⇒ Sur 50 voyages dans le 2e semestre : **gain 2 100 €** versus l'ancien tarif fixe (sans clause).

### 3.4 Mention type dans le devis ou contrat

**Modèle clause CCN à insérer** :

> « Conformément à l'art. 23 de la CCN 3085 et à la loi n° 2006-10 du 5 janvier 2006, le tarif appliqué est révisable mensuellement en fonction de l'évolution du prix du gazole professionnel publié par l'INSEE/CNR.
>
> Formule : Tarif révisé = Tarif initial × (1 + α × ΔG/G₀), avec α = 0,25, G₀ = prix gazole HT-TICPE à la date de signature, et ΔG = variation absolue depuis G₀.
>
> Toute variation supérieure à 0,02 €/L donne lieu à actualisation automatique du tarif sur les voyages suivants. »

### 3.5 Outils de suivi gazole

- **Indice CNR** : publié mensuellement sur cnr.fr (gazole HT-TICPE pro).
- **Cartes gazole pro** : DKV, AS24, TotalCard. Export mensuel CSV avec prix moyen.
- **TMS Akanea / Mantis** : module indexation gazole automatique avec alerte client.

---

## 4. La revalorisation tarifaire annuelle

### 4.1 Pourquoi revaloriser chaque année ?

**Coûts du transport routier 2020-2025** (CNR) : **+22 %** cumulé.

| Poste | Variation |
|---|---|
| Salaire CDI conducteur (CCN) | +14 % |
| Charges patronales URSSAF | +6 % |
| Gazole HT-TICPE | +28 % |
| Pneumatiques | +18 % |
| Assurance flotte | +12 % |
| Loyer LLD véhicules | +20 % |

⇒ Si vous n'augmentez pas vos tarifs de **+4 à 5 % par an**, votre **marge nette** s'effondre.

### 4.2 Méthodologie de revalorisation

**Calendrier** :
- **15 octobre** : compilation des indices CNR de l'année + calcul écart.
- **1er novembre** : envoi des courriers de revalorisation aux clients.
- **15 novembre - 15 décembre** : négociations clients principaux.
- **15 décembre** : confirmation finale + envoi mail de rappel.
- **1er janvier** : application des nouveaux tarifs.

### 4.3 Lettre type de revalorisation

**Modèle** :

> Madame, Monsieur,
>
> Comme chaque année, nous vous communiquons l'évolution de nos tarifs pour l'année à venir, conformément à nos conditions contractuelles.
>
> L'évolution des coûts du transport routier (indices CNR 2025) montre une progression des charges de **+5,2 %** : carburant +8 %, salaires CCN +3,5 %, pneumatiques +4 %, assurance +6 %.
>
> Pour préserver la qualité de service que vous appréciez, nos tarifs seront revalorisés de **+4,5 %** au 1er janvier 2026.
>
> Pour le segment Lyon-Bordeaux, le tarif passera de 1 850 € HT à **1 933 € HT** par voyage, soit une augmentation de 83 € par voyage.
>
> Cette revalorisation reste en deçà de la progression réelle de nos coûts. Nous absorbons une partie de l'inflation grâce à des gains de productivité internes.
>
> Restant à votre disposition pour vous présenter le détail de cette évolution, je vous prie d'agréer, Madame, Monsieur, mes salutations distinguées.
>
> [Signature]

### 4.4 Astuce timing — le 15 décembre

**Astuce pro** : envoyer la lettre **vers le 15 décembre** (pas avant le 1er novembre, pas après le 20 décembre).

- Avant le 1er novembre : le client a le temps de chercher la concurrence.
- 1-15 novembre : période propice à la négociation directe.
- **15 décembre** : le client est sous pression budget de fin d'année, n'a pas le temps de changer de fournisseur, accepte plus facilement.
- Après le 20 décembre : congés, courrier non lu, application 1er janvier brutale.

---

## 5. Refuser un client mal payé

### 5.1 Quand refuser ?

| Situation | Décision |
|---|---|
| Marge < 10 % brute | Refuser ou renégocier |
| Coface < B (risque > 50 %) | Refuser sans paiement comptant |
| Délai paiement > 60 j (LME) | Refuser ou facturer frais financiers |
| Pénalités illimitées dans bon commande | Refuser ou contre-bon |
| Volume incertain non garanti | Forfait haut, pas tarif standard |

### 5.2 Script de refus argumenté

**Modèle** :

> Cher [Prénom Nom],
>
> Je vous remercie pour votre confiance et l'opportunité de cotation.
>
> Après analyse précise de votre demande, je ne suis pas en mesure de vous proposer une cotation alignée sur votre budget cible de [montant]. Notre coût de revient sur ce trajet est de [break-even], et nous ne pouvons descendre en dessous de [prix plancher] sans compromettre la qualité de service.
>
> Plutôt que de signer un contrat dont l'exécution serait incertaine, je préfère vous le dire en toute transparence.
>
> 3 alternatives possibles :
> 1. Notre prix [prix réel] avec engagement annuel et clause indexation.
> 2. Un partenaire de confiance [nom partenaire] qui pourra peut-être répondre à votre besoin.
> 3. Une revue ensemble du périmètre (groupage, retour chargé, créneaux flexibles) pour optimiser le coût.
>
> Restant à votre disposition pour une éventuelle évolution.
>
> [Signature]

### 5.3 Effets du refus argumenté

- **80 %** des clients refusés reviennent dans les 6-12 mois.
- **Renforcement de la position** : les acheteurs respectent un transporteur qui sait dire non.
- **Conservation marge** : vendre à perte = signer sa propre disparition.

---

## 6. Cas pratique d'examen

**Énoncé** : Un client GMS demande -8 % sur votre tarif annuel actuel de 1 850 €/voyage Bordeaux-Paris (80 voyages/an). Votre break-even est de 1 311 € (porteur 19 t, 580 km, péages 110 €). Le gazole est à 1,55 €/L (référence). Le client menace de partir chez la concurrence.

**1. Quelle est votre marge actuelle et celle après remise -8 % ?**
**2. Comment structurer votre contre-proposition ?**
**3. Comment intégrer la clause indexation gazole ?**

**Correction** :

**1. Marges** :
- Actuelle : (1 850 − 1 311) / 1 850 = **29 %**.
- Après -8 % : tarif 1 702 € → (1 702 − 1 311) / 1 702 = **23 %**.

**2. Contre-proposition** :
- **-5 % seulement** au lieu de -8 % (1 758 € au lieu de 1 702 €), avec **3 conditions** :
  - Engagement contractuel **18 mois** + clause sortie 60 jours.
  - Volume garanti **80 voyages minimum**.
  - **Indexation gazole** automatique (clause CCN art. 23).
  - Paiement 30 j fin de mois (vs 45 actuels).
- Package complémentaire : reporting mensuel KPI, EDI offert, stockage 48h offert.

**3. Clause indexation** :
> « Tarif 1 758 € HT révisable selon formule : Tarif × (1 + 0,25 × ΔG/1,55) où ΔG = variation absolue gazole HT-TICPE entre janvier 2026 et date facture. Application automatique au-delà de 0,02 €/L de mouvement. Source : indice CNR mensuel. »

⇒ Marge nette préservée à **22 %**, fidélisation client, sécurité gazole, volume garanti.

---

## 7. Mini-exercice à faire seul

**Énoncé** : Vous avez signé un contrat à 1 200 € HT/voyage le 1er janvier 2026 (gazole référence 1,55 €/L). Le 1er juillet 2026, le gazole monte à 1,72 €/L. Coefficient α = 0,25. Calculez le tarif révisé.

> 💡 Réponse en fin de module (corrections § 4).

---

## 8. Corrections des mini-exercices du module

### Leçon 1 — VUL 90 000 km/an

- Charges fixes : 41 000 / 90 000 = **0,456 €/km**.
- Gazole : 8,5 × 1,55 / 100 = **0,132 €/km**.
- Pneus + entretien + péages : **0,150 €/km**.
- Total variable : **0,282 €/km**.
- Coûts directs : 0,456 + 0,282 = **0,738 €/km**.
- Structure : 12 000 / 90 000 = **0,133 €/km**.
- **CRKM total** : 0,738 + 0,133 = **0,871 €/km**.
- **CRKM facturable** (vide 35 %) : 0,871 / 0,65 = **1,340 €/km**.
- **Prix minimum 800 km** : 800 × 1,340 = **1 072 € HT** (sans marge).

### Leçon 2 — Paris-Strasbourg porteur 19 t

- Coût km : 2,15 × 490 = **1 054 €**.
- Frais voyage (péages + repas) : **115 €**.
- Sous-total : **1 169 €**.
- Marge 20 % : 1 169 / 0,80 = **1 461 € HT**.
- TVA 20 % : 292 €.
- **Total TTC : 1 753 €**.

### Leçon 3 — Devis Lille-Toulouse VUL

- Coût km : 1,91 × 880 = **1 681 €**.
- Péages : **65 €**.
- Sous-total : **1 746 €**.
- Marge 18 % : 1 746 / 0,82 = **2 129 € HT**.
- TVA 20 % : 426 €.
- **Total TTC : 2 555 €**.
- **5 mentions LME minimales** : (1) SIRET émetteur, (2) date + n° séquentiel, (3) prix HT/TVA/TTC, (4) date d'échéance, (5) pénalités BCE+10 + indemnité 40 €.

### Leçon 4 — Indexation gazole

- ΔGazole : 1,72 − 1,55 = **+0,17 €/L**.
- Variation relative : 0,17 / 1,55 = **+10,97 %**.
- Application α : 0,25 × 10,97 % = **+2,74 %**.
- Tarif révisé : 1 200 × (1 + 2,74 %) = **1 233 € HT** (au lieu de 1 200).
- **Gain par voyage** : 33 €. Sur 50 voyages 2e semestre : **1 650 €**.

---

## 9. Glossaire

- **Break-even** : prix minimum qui couvre tous les coûts (zéro marge).
- **BATNA** : Best Alternative To Negotiated Agreement (plan B).
- **Ancrage** : technique de pose du premier chiffre comme repère psychologique.
- **Package** : transformation d'une remise prix en gain volume / services.
- **Coefficient α gazole** : part du gazole dans le CRKM (22-28 % LD, 15-18 % régional).
- **CNR** : Comité National Routier — indices mensuels de référence.
- **CCN 3085** : Convention Collective Nationale du transport routier.
- **Loi Perben II** (n° 2006-10) : rend obligatoire la clause indexation gazole.
- **Revalorisation** : actualisation annuelle des tarifs (cible +4-5 %/an).

---

## 10. Synthèse opérationnelle

1. **Préparation** : break-even, BATNA, marge non négociable.
2. **Ancrage** : poser le premier chiffre haut.
3. **Contre-proposition** : jamais de « non » sec, package multi-prestations.
4. **Indexation gazole** : OBLIGATOIRE (CCN art. 23 + loi 2006-10), formule α × ΔG/G₀.
5. **Coefficient α** : 0,22-0,28 longue distance, 0,15-0,18 régional.
6. **Revalorisation annuelle** : +4-5 %/an, envoi 15 décembre.
7. **Refus argumenté** : 80 % des refus reviennent en 6-12 mois.
8. **Outils** : indices CNR, TMS avec module gazole, calculateur Excel.

---

## ⚠️ Points de vigilance

- **Indexation gazole non appliquée** = 15-35 k€/an de perte par véhicule.
- **Pas de revalorisation annuelle** = -7 à -12 points de marge nette en 5 ans.
- **Vendre sous break-even** = signer sa propre faillite à terme.
- **Concession sans contrepartie** = perte sèche. Toujours négocier en package.
- **CCN 3085 art. 23** = obligation légale d'indexation, sanctionnable.

## 💡 Astuces pro

- **Indices CNR** : abonnement gratuit newsletter mensuelle pour suivi des coûts sectoriels.
- **TMS modulé** : choisir un TMS avec module indexation gazole automatique (Akanea, Mantis).
- **Lettre revalorisation** : envoyer le 15 décembre pour pression budgétaire de fin d'année.
- **Contre-bons** : sur tout bon de commande client, joindre votre CGV en réserve écrite.
- **Calcul d'urgence** : avoir toujours en mémoire son break-even par segment (LD, régional, urbain).

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : formule indexation gazole, coefficient α, calendrier revalorisation.
- **QR cas pratique** : « Calculez le tarif révisé après variation gazole de X €/L. »
- **Oral DP** : « Comment négociez-vous une remise client sans casser votre marge ? »

---

## 📌 Synthèse à retenir

### Préparation négociation

| Indicateur | Définition |
|---|---|
| **CRKM précis** | Coût exact tous postes |
| **Break-even** | Prix zéro marge |
| **BATNA** | Plan B si échec |
| **Plancher** | Break-even + 10 % marge mini |

### Techniques de négociation

| Technique | Principe |
|---|---|
| **Ancrage** | Poser le 1er chiffre haut |
| **Contre-proposition** | Jamais de « non » sec |
| **Package** | Transformer remise prix en services |
| **Concession progressive** | Étaler les contreparties |

### Formule d'indexation gazole (CCN art. 23 + loi 2006-10)

> **Tarif révisé = Tarif initial × (1 + α × ΔG / G₀)**
>
> α = part gazole dans CRKM (0,22-0,28 LD · 0,15-0,18 régional)
>
> G₀ = gazole HT-TICPE à signature
>
> ΔG = variation absolue depuis signature

### Calendrier revalorisation annuelle

- **15 octobre** : compilation indices CNR
- **1er novembre** : envoi courriers
- **15 novembre - 15 décembre** : négociations
- **15 décembre** : confirmation finale (timing optimal)
- **1er janvier** : application

> 📌 **Cible revalorisation : +4 à +5 %/an** (sinon érosion marge)

> ⚠️ **Les 5 règles d'or de la négociation transport**
>
> 1. **Connaître son break-even** au centime près
> 2. **Indexation gazole** = obligation légale (CCN + loi 2006-10)
> 3. **Concession en package** : volume / délai / services au lieu de prix
> 4. **Refus argumenté** = 80 % de retour client en 6-12 mois
> 5. **Revalorisation annuelle** entre 15 nov et 15 déc = timing optimal
$lessonG4$,
'Préparer une négociation tarifaire (break-even, BATNA), maîtriser les techniques d''ancrage et de package multi-prestations, appliquer la clause d''indexation gazole obligatoire (CCN art. 23 + loi 2006-10), conduire une revalorisation tarifaire annuelle (+4-5 %/an, envoi 15 décembre) et refuser un client trop mal payé sans casser la relation.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- BANQUE DE QUESTIONS — 48 QCM + 8 QR
  -- =================================================================

  -- ===== LEÇON 1 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'Le CRKM signifie :',
   '[{"id":"a","label":"Coût de Roulement Kilométrique Maximum","is_correct":false},{"id":"b","label":"Coût de Revient Kilométrique","is_correct":true},{"id":"c","label":"Capacité Roulante Kilométrique Moyenne","is_correct":false},{"id":"d","label":"Charge Réelle Kilométrique Mensuelle","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-03','lecon-1','crkm'], 'mft-2026-gotrm:bc01-03-v3:l1:q1', true,
   'CRKM = Coût de Revient Kilométrique. Métrique de référence du transport, calculée selon la méthode CNR.'),
  (v_formation, v_module, 'qcm', 'Parmi ces postes, lequel est une charge FIXE ?',
   '[{"id":"a","label":"Gazole","is_correct":false},{"id":"b","label":"Pneumatiques","is_correct":false},{"id":"c","label":"Salaire conducteur CDI","is_correct":true},{"id":"d","label":"Péages","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-03','lecon-1','charges-fixes'], 'mft-2026-gotrm:bc01-03-v3:l1:q2', true,
   'Le salaire conducteur CDI tombe même si le véhicule ne roule pas (charge fixe). Gazole, pneus, péages = variables.'),
  (v_formation, v_module, 'qcm', 'Le coût employeur d''un conducteur CDI = brut × :',
   '[{"id":"a","label":"1,15","is_correct":false},{"id":"b","label":"1,25","is_correct":false},{"id":"c","label":"1,42","is_correct":true},{"id":"d","label":"1,80","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-03','lecon-1','salaire'], 'mft-2026-gotrm:bc01-03-v3:l1:q3', true,
   'Coût employeur ≈ brut × 1,42 (charges patronales URSSAF + retraite + prévoyance ≈ 42 % en transport longue distance).'),
  (v_formation, v_module, 'qcm', 'La TICPE récupérable par les pros sur le gazole est de :',
   '[{"id":"a","label":"5 c€/L","is_correct":false},{"id":"b","label":"15,9 c€/L","is_correct":true},{"id":"c","label":"25 c€/L","is_correct":false},{"id":"d","label":"40 c€/L","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-03','lecon-1','ticpe'], 'mft-2026-gotrm:bc01-03-v3:l1:q4', true,
   'TICPE pro récupérable : 15,9 c€/L (semestrielle). À déduire du prix gazole TTC pour calcul du CRKM en HT-TICPE.'),
  (v_formation, v_module, 'qcm', 'Pour un VUL faisant 8 L/100 km à 1,55 €/L, le coût gazole/km est de :',
   '[{"id":"a","label":"0,062 €/km","is_correct":false},{"id":"b","label":"0,124 €/km","is_correct":true},{"id":"c","label":"0,248 €/km","is_correct":false},{"id":"d","label":"0,496 €/km","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-03','lecon-1','calcul-gazole'], 'mft-2026-gotrm:bc01-03-v3:l1:q5', true,
   'Formule : conso × prix / 100 = 8 × 1,55 / 100 = 0,124 €/km.'),
  (v_formation, v_module, 'qcm', 'Le retour à vide moyen FNTR en France est de :',
   '[{"id":"a","label":"5 %","is_correct":false},{"id":"b","label":"10 %","is_correct":false},{"id":"c","label":"30 %","is_correct":true},{"id":"d","label":"60 %","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-03','lecon-1','retour-vide'], 'mft-2026-gotrm:bc01-03-v3:l1:q6', true,
   'Taux de retour à vide moyen sectoriel = 30 %. Diviser le CRKM par (1 − 0,30) = 0,70 pour CRKM facturable.'),
  (v_formation, v_module, 'qcm', 'Le CRKM moyen d''un PL 40 t longue distance en 2026 (référence CNR) est d''environ :',
   '[{"id":"a","label":"0,80 €/km","is_correct":false},{"id":"b","label":"1,18 €/km","is_correct":true},{"id":"c","label":"2,50 €/km","is_correct":false},{"id":"d","label":"3,50 €/km","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-03','lecon-1','cnr'], 'mft-2026-gotrm:bc01-03-v3:l1:q7', true,
   'CNR 2026 : PL 40 t longue distance ≈ 1,18 €/km de coûts directs (hors retour à vide et structure). Avec structure et vide, CRKM facturable ≈ 2,24 €/km.'),
  (v_formation, v_module, 'qcm', 'Les charges de structure représentent typiquement quel % des coûts directs ?',
   '[{"id":"a","label":"2-5 %","is_correct":false},{"id":"b","label":"6-10 %","is_correct":false},{"id":"c","label":"12-18 %","is_correct":true},{"id":"d","label":"25-35 %","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-03','lecon-1','structure'], 'mft-2026-gotrm:bc01-03-v3:l1:q8', true,
   'Méthode CNR : structure = 12-18 % des coûts directs (loyer, commercial, compta, télécoms, formation).'),
  (v_formation, v_module, 'qcm', 'Pour un VUL avec CRKM brut 0,80 €/km et retour à vide 30 %, le CRKM facturable est :',
   '[{"id":"a","label":"0,80 €/km","is_correct":false},{"id":"b","label":"1,04 €/km","is_correct":false},{"id":"c","label":"1,143 €/km","is_correct":true},{"id":"d","label":"1,60 €/km","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-03','lecon-1','calcul-vide'], 'mft-2026-gotrm:bc01-03-v3:l1:q9', true,
   'CRKM facturable = CRKM brut / (1 − taux vide) = 0,80 / 0,70 = 1,143 €/km.'),
  (v_formation, v_module, 'qcm', 'L''AdBlue représente quel % de la conso gazole ?',
   '[{"id":"a","label":"0,5 %","is_correct":false},{"id":"b","label":"3 %","is_correct":true},{"id":"c","label":"8 %","is_correct":false},{"id":"d","label":"15 %","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-03','lecon-1','adblue'], 'mft-2026-gotrm:bc01-03-v3:l1:q10', true,
   'AdBlue : ≈ 3 % de la conso gazole (norme Euro VI). Coût additionnel à intégrer dans les charges variables.'),
  (v_formation, v_module, 'qcm', 'Quelle est la métrique préférée pour facturer une charge partielle ?',
   '[{"id":"a","label":"€/voyage uniquement","is_correct":false},{"id":"b","label":"€/km uniquement","is_correct":false},{"id":"c","label":"€/tonne-kilomètre (t.km)","is_correct":true},{"id":"d","label":"€/m³","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-03','lecon-1','tkm'], 'mft-2026-gotrm:bc01-03-v3:l1:q11', true,
   'En charge partielle, le t.km est plus juste car un porteur 19 t à demi-rempli coûte presque autant qu''à pleine charge.'),
  (v_formation, v_module, 'qcm', 'Les indices CNR sont publiés à quelle fréquence ?',
   '[{"id":"a","label":"Annuelle","is_correct":false},{"id":"b","label":"Trimestrielle","is_correct":false},{"id":"c","label":"Mensuelle","is_correct":true},{"id":"d","label":"Hebdomadaire","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-03','lecon-1','cnr'], 'mft-2026-gotrm:bc01-03-v3:l1:q12', true,
   'Les indices CNR sont mensuels (longue distance, régional, frigo, citerne, exceptionnel) sur cnr.fr — référence officielle pour calculs et indexation.');

  -- ===== LEÇON 2 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'La marge brute se calcule :',
   '[{"id":"a","label":"(PV − coût direct) ÷ Coût direct","is_correct":false},{"id":"b","label":"(PV − coût direct) ÷ PV","is_correct":true},{"id":"c","label":"PV − coût total","is_correct":false},{"id":"d","label":"PV ÷ coût direct","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-03','lecon-2','marge-brute'], 'mft-2026-gotrm:bc01-03-v3:l2:q1', true,
   'Marge brute = (PV − coût direct) ÷ PV. La marge nette intègre en plus les charges de structure.'),
  (v_formation, v_module, 'qcm', 'Le coefficient multiplicateur k pour une marge de 20 % est :',
   '[{"id":"a","label":"1,20","is_correct":false},{"id":"b","label":"1,25","is_correct":true},{"id":"c","label":"1,33","is_correct":false},{"id":"d","label":"1,50","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-03','lecon-2','coefficient'], 'mft-2026-gotrm:bc01-03-v3:l2:q2', true,
   'k = 1 / (1 − marge) = 1 / 0,80 = 1,25 pour une marge de 20 %.'),
  (v_formation, v_module, 'qcm', 'La marge cible standard sectorielle pour un transport routier est de :',
   '[{"id":"a","label":"5 %","is_correct":false},{"id":"b","label":"10 %","is_correct":false},{"id":"c","label":"20 %","is_correct":true},{"id":"d","label":"35 %","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-03','lecon-2','marge-cible'], 'mft-2026-gotrm:bc01-03-v3:l2:q3', true,
   'Standard sectoriel : 20 % de marge brute (15 % minimum, 22-25 % en premium / express).'),
  (v_formation, v_module, 'qcm', 'Pour un trajet 1 020 km avec CRKM facturable 1,91 €/km et marge 20 %, le prix HT est :',
   '[{"id":"a","label":"1 800 €","is_correct":false},{"id":"b","label":"2 435 €","is_correct":true},{"id":"c","label":"2 800 €","is_correct":false},{"id":"d","label":"3 200 €","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-03','lecon-2','calcul-prix'], 'mft-2026-gotrm:bc01-03-v3:l2:q4', true,
   'PV = 1,91 × 1 020 × 1,25 = 2 435 € HT (méthode tarif km avec coefficient k = 1,25 pour marge 20 %).'),
  (v_formation, v_module, 'qcm', 'La méthode tarif horaire est adaptée pour :',
   '[{"id":"a","label":"Longue distance","is_correct":false},{"id":"b","label":"Courses urbaines / livraisons distribution","is_correct":true},{"id":"c","label":"Transport intercontinental","is_correct":false},{"id":"d","label":"Transport ferroviaire","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-03','lecon-2','tarif-horaire'], 'mft-2026-gotrm:bc01-03-v3:l2:q5', true,
   'Tarif horaire = courses urbaines (vitesse moyenne 25 km/h, kilométrage faible mais temps élevé). Long distance = tarif km.'),
  (v_formation, v_module, 'qcm', 'L''indemnité de découcher conducteur (CCN 3085) est de :',
   '[{"id":"a","label":"22 €/nuit","is_correct":false},{"id":"b","label":"35 €/nuit","is_correct":false},{"id":"c","label":"50 €/nuit","is_correct":true},{"id":"d","label":"100 €/nuit","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-03','lecon-2','decoucher'], 'mft-2026-gotrm:bc01-03-v3:l2:q6', true,
   'CCN 3085 : découcher = 50 €/nuit. Grand déplacement (repas) = 22 €/jour.'),
  (v_formation, v_module, 'qcm', 'Une marge nette inférieure à 5 % est :',
   '[{"id":"a","label":"Confortable","is_correct":false},{"id":"b","label":"Précaire","is_correct":true},{"id":"c","label":"Premium","is_correct":false},{"id":"d","label":"Standard","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-03','lecon-2','marge'], 'mft-2026-gotrm:bc01-03-v3:l2:q7', true,
   'Marge nette < 5 % = précaire (pas d''investissement possible). 5-10 % standard. 10-15 % confortable. 15-22 % premium.'),
  (v_formation, v_module, 'qcm', 'Le gerbage permet de :',
   '[{"id":"a","label":"Réduire le poids","is_correct":false},{"id":"b","label":"Doubler la capacité de chargement","is_correct":true},{"id":"c","label":"Améliorer la sécurité","is_correct":false},{"id":"d","label":"Réduire les péages","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-03','lecon-2','gerbage'], 'mft-2026-gotrm:bc01-03-v3:l2:q8', true,
   'Gerbage = empilement vertical 2 niveaux → double la capacité du semi-remorque (33 → 66 palettes EUR).'),
  (v_formation, v_module, 'qcm', 'Proposer 3 variantes (express/équilibré/économique) augmente la conversion d''environ :',
   '[{"id":"a","label":"5 %","is_correct":false},{"id":"b","label":"15 %","is_correct":false},{"id":"c","label":"35 %","is_correct":true},{"id":"d","label":"70 %","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-03','lecon-2','conversion'], 'mft-2026-gotrm:bc01-03-v3:l2:q9', true,
   'Statistiques sectorielles : devis multi-options augmente la conversion de +35 % vs devis mono-prix (effet psychologique d''engagement par choix).'),
  (v_formation, v_module, 'qcm', 'Sur un trajet court (< 80 km), il est préférable d''utiliser :',
   '[{"id":"a","label":"Le tarif au km pur","is_correct":false},{"id":"b","label":"Un forfait avec frais fixes voyage","is_correct":true},{"id":"c","label":"Le tarif horaire international","is_correct":false},{"id":"d","label":"Aucune méthode (refuser)","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-03','lecon-2','forfait'], 'mft-2026-gotrm:bc01-03-v3:l2:q10', true,
   'Trajets courts : les frais fixes voyage (chargement, péages d''entrée) ne s''amortissent pas sur le km. Forfait obligatoire.'),
  (v_formation, v_module, 'qcm', 'La vitesse moyenne urbaine pour un VUL est typiquement de :',
   '[{"id":"a","label":"15 km/h","is_correct":false},{"id":"b","label":"25 km/h","is_correct":true},{"id":"c","label":"50 km/h","is_correct":false},{"id":"d","label":"80 km/h","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-03','lecon-2','vitesse-urbaine'], 'mft-2026-gotrm:bc01-03-v3:l2:q11', true,
   'Vitesse moyenne urbaine = 25 km/h (Paris, Lyon, Marseille). Périurbain 50 km/h. Autoroute 80 km/h.'),
  (v_formation, v_module, 'qcm', 'Une stratégie d''écrémage consiste à :',
   '[{"id":"a","label":"Pratiquer un prix bas pour gagner part de marché","is_correct":false},{"id":"b","label":"Pratiquer un prix haut sur niche premium","is_correct":true},{"id":"c","label":"S''aligner sur le marché","is_correct":false},{"id":"d","label":"Casser les prix","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-03','lecon-2','strategie'], 'mft-2026-gotrm:bc01-03-v3:l2:q12', true,
   'Écrémage = prix +20 à +40 % sur niche (ADR, exceptionnel, médical). Pénétration = prix bas. Alignement = prix marché.');

  -- ===== LEÇON 3 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'La méthode de cotation comporte :',
   '[{"id":"a","label":"3 étapes","is_correct":false},{"id":"b","label":"6 étapes","is_correct":true},{"id":"c","label":"10 étapes","is_correct":false},{"id":"d","label":"Aucune étape standard","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-03','lecon-3','methode'], 'mft-2026-gotrm:bc01-03-v3:l3:q1', true,
   'Méthode 6 étapes : qualification → contraintes → coûts → marge → devis → suivi.'),
  (v_formation, v_module, 'qcm', 'L''indemnité forfaitaire de recouvrement (LME) est de :',
   '[{"id":"a","label":"15 €","is_correct":false},{"id":"b","label":"25 €","is_correct":false},{"id":"c","label":"40 €","is_correct":true},{"id":"d","label":"100 €","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-03','lecon-3','lme'], 'mft-2026-gotrm:bc01-03-v3:l3:q2', true,
   'Art. L. 441-10 C. com. : indemnité forfaitaire de recouvrement = 40 €. Mention obligatoire sur facture B2B.'),
  (v_formation, v_module, 'qcm', 'Le taux de pénalités de retard prévu par la LME est :',
   '[{"id":"a","label":"BCE + 5 points","is_correct":false},{"id":"b","label":"BCE + 10 points","is_correct":true},{"id":"c","label":"BCE × 2","is_correct":false},{"id":"d","label":"5 % fixe","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-03','lecon-3','penalites'], 'mft-2026-gotrm:bc01-03-v3:l3:q3', true,
   'Taux d''intérêt de retard = BCE + 10 points (en 2026 ≈ 14,5 %/an). Mention obligatoire sur facture.'),
  (v_formation, v_module, 'qcm', 'Le seuil pour le régime réel normal de TVA est de :',
   '[{"id":"a","label":"91 900 €","is_correct":false},{"id":"b","label":"254 000 €","is_correct":true},{"id":"c","label":"500 000 €","is_correct":false},{"id":"d","label":"1 000 000 €","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-03','lecon-3','tva'], 'mft-2026-gotrm:bc01-03-v3:l3:q4', true,
   'Seuils TVA services : franchise < 91 900 €, simplifié < 254 000 €, normal > 254 000 €. Le réel normal = standard transporteur.'),
  (v_formation, v_module, 'qcm', 'La sanction pour absence de mentions LME sur facture est de :',
   '[{"id":"a","label":"500 € PP","is_correct":false},{"id":"b","label":"15 000 € PP","is_correct":false},{"id":"c","label":"75 000 € PP / 375 000 € PM","is_correct":true},{"id":"d","label":"1 million € PM","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-03','lecon-3','sanction'], 'mft-2026-gotrm:bc01-03-v3:l3:q5', true,
   'Art. L. 441-9 C. com. : sanction 75 000 € (personne physique) / 375 000 € (personne morale) pour facture incomplète.'),
  (v_formation, v_module, 'qcm', 'La validité standard d''un devis transport est de :',
   '[{"id":"a","label":"7 jours","is_correct":false},{"id":"b","label":"30 jours","is_correct":true},{"id":"c","label":"6 mois","is_correct":false},{"id":"d","label":"1 an","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-03','lecon-3','validite'], 'mft-2026-gotrm:bc01-03-v3:l3:q6', true,
   '30 jours = standard sectoriel. À indiquer EXPRESSÉMENT sur le devis pour éviter qu''un client commande 6 mois plus tard au prix d''époque.'),
  (v_formation, v_module, 'qcm', 'Pour un transport France → Allemagne B2B avec n° TVA intracom valide, le taux TVA appliqué est :',
   '[{"id":"a","label":"20 %","is_correct":false},{"id":"b","label":"5,5 %","is_correct":false},{"id":"c","label":"0 % (autoliquidation)","is_correct":true},{"id":"d","label":"10 %","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-03','lecon-3','tva-intracom'], 'mft-2026-gotrm:bc01-03-v3:l3:q7', true,
   'TVA intracommunautaire B2B : 0 % avec autoliquidation par le client (art. 196 directive 2006/112/CE). Vérifier n° TVA sur VIES.'),
  (v_formation, v_module, 'qcm', 'Le délai maximal de paiement B2B en France (LME) est de :',
   '[{"id":"a","label":"30 jours","is_correct":false},{"id":"b","label":"45 jours","is_correct":false},{"id":"c","label":"60 jours date facture","is_correct":true},{"id":"d","label":"90 jours","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-03','lecon-3','delai-paiement'], 'mft-2026-gotrm:bc01-03-v3:l3:q8', true,
   'LME 2008 : délai maximum 60 jours date facture (ou 45 j fin de mois). Au-delà = pratique illicite sanctionnée.'),
  (v_formation, v_module, 'qcm', 'Lequel de ces pièges N''EST PAS classé parmi les 5 pièges du devis ?',
   '[{"id":"a","label":"Oubli du hayon","is_correct":false},{"id":"b","label":"Oubli ADR","is_correct":false},{"id":"c","label":"Oubli créneau client","is_correct":false},{"id":"d","label":"Oubli du logo client","is_correct":true}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-03','lecon-3','pieges'], 'mft-2026-gotrm:bc01-03-v3:l3:q9', true,
   '5 pièges : hayon, ADR, créneau, surcharge gazole, conditions paiement. Le logo client est sans importance juridique.'),
  (v_formation, v_module, 'qcm', 'Le système de validation européen des n° TVA intracom s''appelle :',
   '[{"id":"a","label":"VIES","is_correct":true},{"id":"b","label":"EUTV","is_correct":false},{"id":"c","label":"INTRA","is_correct":false},{"id":"d","label":"TAXE","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-03','lecon-3','vies'], 'mft-2026-gotrm:bc01-03-v3:l3:q10', true,
   'VIES (VAT Information Exchange System) : système Commission européenne pour vérifier validité n° TVA intracommunautaire.'),
  (v_formation, v_module, 'qcm', 'Pour un nouveau client sans solvabilité connue, la condition de paiement recommandée est :',
   '[{"id":"a","label":"60 jours fin de mois","is_correct":false},{"id":"b","label":"Acompte 30 % à la commande, solde 30 jours","is_correct":true},{"id":"c","label":"Crédit illimité","is_correct":false},{"id":"d","label":"Paiement à 12 mois","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-03','lecon-3','acompte'], 'mft-2026-gotrm:bc01-03-v3:l3:q11', true,
   'Nouveau client < 1 an d''ancienneté : exiger acompte 30 % à la commande + solde 30 j. Signal de pro et sécurise trésorerie.'),
  (v_formation, v_module, 'qcm', 'Quel outil est utilisé pour la signature électronique certifiée EIDAS ?',
   '[{"id":"a","label":"Excel","is_correct":false},{"id":"b","label":"DocuSign / Yousign","is_correct":true},{"id":"c","label":"WhatsApp","is_correct":false},{"id":"d","label":"FaceTime","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-03','lecon-3','signature'], 'mft-2026-gotrm:bc01-03-v3:l3:q12', true,
   'DocuSign et Yousign sont les solutions de signature électronique certifiées EIDAS (recommandées en B2B transport).');

  -- ===== LEÇON 4 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'Le break-even est :',
   '[{"id":"a","label":"Le prix de marché","is_correct":false},{"id":"b","label":"Le prix minimum couvrant tous les coûts","is_correct":true},{"id":"c","label":"Le prix maximum","is_correct":false},{"id":"d","label":"La marge nette","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-03','lecon-4','break-even'], 'mft-2026-gotrm:bc01-03-v3:l4:q1', true,
   'Break-even (point mort) = prix qui couvre tous les coûts mais sans marge. Vendre dessous = perte sèche.'),
  (v_formation, v_module, 'qcm', 'BATNA signifie :',
   '[{"id":"a","label":"Banque Auxiliaire des Tarifs Négociés en Asie","is_correct":false},{"id":"b","label":"Best Alternative To Negotiated Agreement","is_correct":true},{"id":"c","label":"Bilan Annuel des Transports Nationaux","is_correct":false},{"id":"d","label":"Base Annuelle Tarifs Nets Annexes","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-03','lecon-4','batna'], 'mft-2026-gotrm:bc01-03-v3:l4:q2', true,
   'BATNA = Best Alternative To Negotiated Agreement = plan B en cas d''échec de la négociation. Plus la BATNA est forte, plus la position est solide.'),
  (v_formation, v_module, 'qcm', 'L''indexation gazole est :',
   '[{"id":"a","label":"Optionnelle","is_correct":false},{"id":"b","label":"Obligatoire (CCN 3085 art. 23 + loi 2006-10)","is_correct":true},{"id":"c","label":"Interdite","is_correct":false},{"id":"d","label":"Réservée à l''international","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-03','lecon-4','indexation'], 'mft-2026-gotrm:bc01-03-v3:l4:q3', true,
   'Clause indexation gazole = obligatoire (CCN Transport art. 23 + loi Perben II n° 2006-10 du 5 janvier 2006).'),
  (v_formation, v_module, 'qcm', 'Le coefficient α (part gazole) pour un PL longue distance est de :',
   '[{"id":"a","label":"0,05-0,10","is_correct":false},{"id":"b","label":"0,15-0,18","is_correct":false},{"id":"c","label":"0,22-0,28","is_correct":true},{"id":"d","label":"0,40-0,50","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-03','lecon-4','coefficient-alpha'], 'mft-2026-gotrm:bc01-03-v3:l4:q4', true,
   'α gazole : 22-28 % du CRKM longue distance, 15-18 % régional, 8-12 % urbain (effet de la conso).'),
  (v_formation, v_module, 'qcm', 'Pour un tarif initial 2 000 €, gazole 1,55 → 1,68 €/L et α = 0,25, le tarif révisé est :',
   '[{"id":"a","label":"2 020 €","is_correct":false},{"id":"b","label":"2 042 €","is_correct":true},{"id":"c","label":"2 100 €","is_correct":false},{"id":"d","label":"2 180 €","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-03','lecon-4','calcul-indexation'], 'mft-2026-gotrm:bc01-03-v3:l4:q5', true,
   'ΔG = 0,13 €/L, soit +8,4 %. Application α 0,25 = +2,1 %. Tarif révisé = 2 000 × 1,021 = 2 042 €.'),
  (v_formation, v_module, 'qcm', 'La cible de revalorisation tarifaire annuelle est de :',
   '[{"id":"a","label":"+1 %","is_correct":false},{"id":"b","label":"+2 %","is_correct":false},{"id":"c","label":"+4 à +5 %","is_correct":true},{"id":"d","label":"+15 %","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-03','lecon-4','revalorisation'], 'mft-2026-gotrm:bc01-03-v3:l4:q6', true,
   'Coûts du transport routier 2020-2025 : +22 % cumulé. Revalorisation annuelle cible : +4-5 %/an pour préserver la marge nette.'),
  (v_formation, v_module, 'qcm', 'Le timing optimal pour envoyer une lettre de revalorisation est :',
   '[{"id":"a","label":"1er juin","is_correct":false},{"id":"b","label":"1er septembre","is_correct":false},{"id":"c","label":"15 décembre","is_correct":true},{"id":"d","label":"1er février","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-03','lecon-4','timing'], 'mft-2026-gotrm:bc01-03-v3:l4:q7', true,
   '15 décembre = optimal. Le client est sous pression budget fin d''année, n''a pas le temps de chercher un autre fournisseur. Application 1er janvier.'),
  (v_formation, v_module, 'qcm', 'Le pourcentage des PME ne pratiquant pas l''indexation gazole est d''environ :',
   '[{"id":"a","label":"5 %","is_correct":false},{"id":"b","label":"15 %","is_correct":false},{"id":"c","label":"45 %","is_correct":true},{"id":"d","label":"80 %","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-03','lecon-4','statistique'], 'mft-2026-gotrm:bc01-03-v3:l4:q8', true,
   'CNR 2025 : 45 % des PME transport ne pratiquent pas la clause indexation gazole. Perte estimée : 15-35 k€/an par véhicule.'),
  (v_formation, v_module, 'qcm', 'La technique de l''ancrage en négociation consiste à :',
   '[{"id":"a","label":"Refuser tout dialogue","is_correct":false},{"id":"b","label":"Poser le premier chiffre comme repère psychologique","is_correct":true},{"id":"c","label":"Casser les prix","is_correct":false},{"id":"d","label":"Doubler le prix initial","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-03','lecon-4','ancrage'], 'mft-2026-gotrm:bc01-03-v3:l4:q9', true,
   'Ancrage = poser un chiffre haut en premier. Le client négociera autour de cette ancre, sans oser descendre trop bas.'),
  (v_formation, v_module, 'qcm', 'Le pourcentage de clients refusés qui reviennent en 6-12 mois est de :',
   '[{"id":"a","label":"5 %","is_correct":false},{"id":"b","label":"30 %","is_correct":false},{"id":"c","label":"80 %","is_correct":true},{"id":"d","label":"100 %","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-03','lecon-4','refus'], 'mft-2026-gotrm:bc01-03-v3:l4:q10', true,
   '80 % des clients ayant reçu un refus argumenté reviennent dans les 6-12 mois. Renforce l''image de pro.'),
  (v_formation, v_module, 'qcm', 'La formule officielle d''indexation gazole est :',
   '[{"id":"a","label":"Tarif × ΔG","is_correct":false},{"id":"b","label":"Tarif initial × (1 + α × ΔG/G₀)","is_correct":true},{"id":"c","label":"Tarif × G/G₀","is_correct":false},{"id":"d","label":"Tarif − ΔG","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-03','lecon-4','formule-gazole'], 'mft-2026-gotrm:bc01-03-v3:l4:q11', true,
   'Formule officielle : Tarif révisé = Tarif initial × (1 + α × ΔG / G₀). α = part gazole, G₀ = prix référence, ΔG = variation absolue.'),
  (v_formation, v_module, 'qcm', 'La technique du "package multi-prestations" en négociation consiste à :',
   '[{"id":"a","label":"Augmenter le prix","is_correct":false},{"id":"b","label":"Transformer une remise prix en gain volume / services","is_correct":true},{"id":"c","label":"Refuser toute négociation","is_correct":false},{"id":"d","label":"Diviser le prix en plusieurs factures","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-03','lecon-4','package'], 'mft-2026-gotrm:bc01-03-v3:l4:q12', true,
   'Package = au lieu de céder -10 % sur prix, donner -5 % + volume garanti + services (EDI, stockage, reporting). Préserve la marge unitaire.');

  -- ===== 8 QR (cas pratiques métier, max_score 5-7) =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qr',
   'Calculez le CRKM total et le CRKM facturable d''un VUL Renault Trafic en activité régionale, sachant : kilométrage annuel 60 000 km, charges fixes 49 600 €/an (loyer 6 800 + assurance 2 400 + salaire CDI chargé 38 200 + visite 480 + taxe/cartes 320 + provision casse 800 + télécoms 600), conso 9 L/100 km à 1,55 €/L (HT-TICPE), AdBlue 3 % du gazole, pneus 0,018 €/km, entretien 0,032 €/km, réparations 0,020 €/km, péages 0,065 €/km, structure imputée 13 920 €/an, retour à vide 30 %.',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-03','qr','crkm','calcul'], 'mft-2026-gotrm:bc01-03-v3:qr1', true,
   'Calcul détaillé : Charges fixes 49 600 / 60 000 = 0,827 €/km. Charges variables : gazole 9 × 1,55 / 100 = 0,140 €/km + AdBlue 0,005 + pneus 0,018 + entretien 0,032 + réparations 0,020 + péages 0,065 = 0,280 €/km. Structure 13 920 / 60 000 = 0,232 €/km. CRKM total = 0,827 + 0,280 + 0,232 = 1,339 €/km. CRKM facturable = 1,339 / (1 − 0,30) = 1,339 / 0,70 = 1,913 €/km. Ce VUL ne peut donc être vendu sous 1,91 €/km sans perte.'),

  (v_formation, v_module, 'qr',
   'Un porteur 19 t fait 80 000 km/an. Loyer LLD 14 400 €, assurance + visites 4 200 €, conducteur CDI 46 000 €. Carburant 22 L/100 km à 1,55 €/L. Pneus + entretien 0,12 €/km. Péages 0,08 €/km. Structure 15 % des coûts directs. Retour à vide 25 %. Calculez le CRKM total, le CRKM facturable et le prix minimum (sans marge) pour un trajet de 580 km.',
   NULL, 6, 'difficile', ARRAY['gotrm','bc01-03','qr','crkm','calcul-pl'], 'mft-2026-gotrm:bc01-03-v3:qr2', true,
   'Charges fixes : (14 400 + 4 200 + 46 000) / 80 000 = 64 600 / 80 000 = 0,808 €/km. Charges variables : 22 × 1,55 / 100 = 0,341 + 0,12 + 0,08 = 0,541 €/km. Coûts directs 1,349 €/km. Structure (15 %) = 0,202 €/km. CRKM total = 1,551 €/km. CRKM facturable = 1,551 / 0,75 = 2,068 €/km. Prix minimum 580 km = 580 × 2,068 = 1 199 € HT (sans marge). Avec marge 18 % cible : 1 199 / 0,82 = 1 462 € HT.'),

  (v_formation, v_module, 'qr',
   'Construisez 3 variantes de prix pour un trajet Lille-Marseille en PL 40 t (CRKM facturable 2,24 €/km, distance 1 020 km). Variante A : express J+1 8h, retour 80 % vide, 1 découcher + 1 grand déplacement, péages 145 €, marge 22 %. Variante B : équilibré J+1 fin journée, retour 30 % vide, péages 95 €, sans découcher, marge 18 %. Variante C : économique J+2 groupage, retour chargé partiellement, péages 75 €, marge 15 %. Comparez les prix HT.',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-03','qr','variantes-prix'], 'mft-2026-gotrm:bc01-03-v3:qr3', true,
   'Variante A (express) : km roulés 1 020 + 1 020 × 0,8 = 1 836. Coût km : 2,24 × 1 836 = 4 113 €. Frais voyage 145 + 50 + 22 = 217 €. Sous-total 4 330 €. Marge 22 % : 4 330 / 0,78 = 5 551 € HT.\n\nVariante B (équilibré) : 2,24 × 1 020 = 2 285 €. Frais 95 €. Sous-total 2 380 €. Marge 18 % : 2 380 / 0,82 = 2 902 € HT.\n\nVariante C (éco) : CRKM 1,84 (sans abattement vide), 1,84 × 1 020 = 1 877 €. Frais 75 €. Sous-total 1 952 €. Marge 15 % : 1 952 / 0,85 = 2 296 € HT.\n\nÉcart A → C : 142 % (5 551 vs 2 296). Yield management standard.'),

  (v_formation, v_module, 'qr',
   'Un client industriel demande un devis pour 24 palettes EUR (15 t, gerbables, hauteur 1,2 m), Lyon → Strasbourg, livraison J+1 14h, hayon non requis. Votre porteur 26 t a un CRKM facturable de 2,15 €/km. Distance 490 km. Péages 65 €. Repas + grand déplacement 50 €. Marge cible 20 %. Calculez le prix HT et TTC. Listez les 8 mentions LME obligatoires sur le devis. Identifiez 3 pièges potentiels et leur traitement.',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-03','qr','devis-complet'], 'mft-2026-gotrm:bc01-03-v3:qr4', true,
   'Prix : Coût km 2,15 × 490 = 1 054 €. Frais voyage 65 + 50 = 115 €. Sous-total 1 169 €. Marge 20 % : 1 169 / 0,80 = 1 461 € HT. TVA 20 % : 292 €. TTC = 1 753 €.\n\nMentions LME (8) : (1) SIRET émetteur, (2) date émission + validité, (3) n° séquentiel, (4) description précise prestation, (5) prix HT/TVA/TTC, (6) date d''échéance paiement, (7) pénalités BCE+10, (8) indemnité forfaitaire 40 €.\n\nPièges + traitement : (a) hayon non requis : préciser explicitement dans le devis ; (b) indexation gazole : clause CCN art. 23 obligatoire ; (c) validité 30 j écrite : éviter commande au prix d''avril 6 mois plus tard ; (d) ADR : check-list à appliquer (n° ONU classe groupe).'),

  (v_formation, v_module, 'qr',
   'Un client GMS (Carrefour) demande -10 % sur votre tarif annuel actuel de 1 800 €/voyage Bordeaux-Paris (90 voyages/an). Votre break-even est 1 250 € (porteur 19 t, 580 km, péages 110 €). Le gazole est à 1,55 €/L. Le client menace de partir chez la concurrence. Détaillez votre stratégie de négociation en 5 étapes (préparation, contre-proposition, package, indexation, formalisation), avec les calculs de marge à chaque étape.',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-03','qr','negociation-gms'], 'mft-2026-gotrm:bc01-03-v3:qr5', true,
   'Étape 1 (Préparation) : marge actuelle = (1 800 − 1 250) / 1 800 = 30,6 %. Marge à -10 % (1 620 €) = (1 620 − 1 250) / 1 620 = 22,8 %. Marge à -5 % (1 710 €) = 26,9 %.\n\nÉtape 2 (Contre-proposition) : refuser -10 % sec. Proposer -5 % avec engagement 18 mois et 100 voyages garantis (au lieu de 90).\n\nÉtape 3 (Package) : ajouter EDI gratuit (économie client 1 500 €/an), reporting mensuel KPI, stockage 48 h offert sur 10 % envois. Le client perçoit -10-12 % global, vous ne perdez que -5 % unitaire.\n\nÉtape 4 (Indexation) : intégrer formule CCN art. 23 : Tarif × (1 + 0,25 × ΔG/1,55). Sécurise contre flambée gazole.\n\nÉtape 5 (Formalisation) : avenant contractuel signé 18 mois, clause de sortie 60 j. Éviter promesses orales. Contre-bon écrit avec CGV en cas de bon de commande GMS imposant pénalités.\n\nMarge finale préservée à 27 % au lieu de 23 %, fidélisation client 18 mois, sécurité gazole.'),

  (v_formation, v_module, 'qr',
   'Vous avez signé un contrat à 1 800 € HT/voyage le 1er février 2026 (gazole référence 1,55 €/L, α = 0,22). Le 1er septembre 2026, le gazole monte à 1,77 €/L. Le 1er décembre, il redescend à 1,62 €/L. Calculez les tarifs révisés à chaque date et donnez le gain/perte sur 60 voyages effectués entre septembre et décembre.',
   NULL, 6, 'difficile', ARRAY['gotrm','bc01-03','qr','indexation-gazole-evolution'], 'mft-2026-gotrm:bc01-03-v3:qr6', true,
   'Septembre 2026 : ΔG = 1,77 − 1,55 = +0,22 €/L. Variation relative = 0,22 / 1,55 = +14,2 %. Application α 0,22 : +3,12 %. Tarif révisé = 1 800 × 1,0312 = 1 856 €.\n\nDécembre 2026 : ΔG = 1,62 − 1,55 = +0,07 €/L. Variation relative = +4,5 %. Application α 0,22 : +0,99 %. Tarif révisé = 1 800 × 1,0099 = 1 818 €.\n\nGain sur 60 voyages :\n- 30 voyages sept-nov à 1 856 € (au lieu de 1 800) : 30 × 56 = +1 680 €.\n- 30 voyages déc à 1 818 € : 30 × 18 = +540 €.\n- Total clause indexation : +2 220 € de revenus en 4 mois.\n\nSans clause indexation, perte sèche 2 220 € (le transporteur aurait absorbé la hausse gazole).'),

  (v_formation, v_module, 'qr',
   'Vous êtes gestionnaire chez une PME transport (10 véhicules, CA 1,8 M€). Vos tarifs n''ont pas évolué depuis 3 ans. La CNR signale +5,2 % de coûts en 2025. Rédigez votre plan d''action complet de revalorisation tarifaire pour 2026 : calendrier, méthode, lettre type, gestion des objections clients, argumentaire chiffré.',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-03','qr','revalorisation-strategie'], 'mft-2026-gotrm:bc01-03-v3:qr7', true,
   'Plan d''action en 5 étapes :\n\n1. Calendrier : 15 octobre = compilation indices CNR + calcul écart. 1er novembre = courriers clients. 15 novembre - 15 décembre = négos avec gros clients. 15 décembre = confirmation finale. 1er janvier = application.\n\n2. Méthode : revaloriser de +4,5 à +5 % (couvre les +5,2 % de coûts). Plus si client a -3 ans de stagnation tarifaire (rattrapage). Différencier par segment : +5 % standard, +3 % volume garanti, +6 % express / niche premium.\n\n3. Lettre type : « Madame, Monsieur, suite à l''évolution des coûts du transport routier (indices CNR 2025 : +5,2 %), nos tarifs seront revalorisés de +4,5 % au 1er janvier 2026. Pour le segment X-Y, le tarif passe de 1 800 € HT à 1 881 € HT. Cette revalorisation reste en deçà de la hausse réelle de nos coûts. Restant à votre disposition. »\n\n4. Objections : (a) « C''est trop » → argumenter chiffres CNR ; (b) « Concurrence moins chère » → demander comparatif écrit ; (c) « On part » → calculer impact sur volume + offrir contre-package.\n\n5. Argumentaire chiffré : sur 1,8 M€ de CA, +4,5 % = +81 000 € de revenus. Si 3 % des clients partent (≈ 54 000 € perdus), reste +27 000 € net. ROI très positif. Coût en heures négo ≈ 40 h × 50 € = 2 000 €. ROI net 25 000 €.'),

  (v_formation, v_module, 'qr',
   'Un nouveau prospect (PME industrielle) vous demande un tarif annuel pour 50 voyages Lille-Toulouse en porteur 19 t. Distance 880 km. Votre CRKM facturable 2,07 €/km. Frais voyage moyens 145 €. Le prospect annonce un budget cible de 1 800 €/voyage. Vous calculez votre prix juste à 2 100 €. Comment menez-vous la négociation ? Détaillez votre stratégie en cas de refus du prospect.',
   NULL, 5, 'difficile', ARRAY['gotrm','bc01-03','qr','negociation-prospect'], 'mft-2026-gotrm:bc01-03-v3:qr8', true,
   'Calcul break-even : 2,07 × 880 = 1 822 € + 145 € frais = 1 967 €. Marge à 2 100 € = (2 100 − 1 967) / 2 100 = 6,3 % (très faible). Marge à 1 800 € = négatif (PERTE de 167 € par voyage × 50 = 8 350 € de perte annuelle).\n\nÉtape 1 (Ancrage) : annoncer le tarif marché 2 200 €, puis « pour vous » 2 100 €.\n\nÉtape 2 (Contre-proposition) : « À 1 800 €, je suis sous mes coûts. Mon prix est 2 100 € HT, mais avec engagement 50 voyages garantis sur 12 mois je peux faire 2 050 €. »\n\nÉtape 3 (Package) : si engagement, proposer reporting + indexation gazole + acompte 20 % à la commande.\n\nÉtape 4 (Refus) : si le prospect maintient 1 800 €, REFUSER avec script : « Je vous remercie de votre confiance. Mon coût de revient sur ce trajet est 1 967 €. Je ne peux pas signer un contrat dont l''exécution serait incertaine. Je vous propose 2 050 € avec engagement, ou je vous oriente vers [partenaire] qui pourrait accepter votre budget. Restant à votre disposition pour vos prochaines demandes. » 80 % de retour client en 6-12 mois.\n\nLeçon : un client à perte est pire qu''un client perdu.');

  -- =================================================================
  -- QUIZZES (4 entraînement + 1 examen blanc module)
  -- =================================================================

  -- Quiz 1 — Décomposer les coûts
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Décomposer les coûts (CRKM) — Quiz',
          'Quiz d''entraînement (12 questions) sur les charges fixes/variables/structure, calcul du CRKM facturable, retour à vide et indices CNR.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-03-v3:l1:%';

  -- Quiz 2 — Prix de vente et marge
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Prix de vente et marge cible — Quiz',
          'Quiz d''entraînement (12 questions) sur la marge brute/nette, coefficient k, méthodes de tarification (km, forfait, horaire) et stratégies tarifaires.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-03-v3:l2:%';

  -- Quiz 3 — Méthodologie cotation et devis
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Méthodologie de cotation et devis — Quiz',
          'Quiz d''entraînement (12 questions) sur la méthode 6 étapes, mentions LME, régimes TVA, stratégies tarifaires et 5 pièges du devis.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-03-v3:l3:%';

  -- Quiz 4 — Négociation et indexation
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Négociation et indexation gazole — Quiz',
          'Quiz d''entraînement (12 questions) sur le break-even, BATNA, techniques de négociation, indexation gazole CCN art. 23, revalorisation annuelle.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-03-v3:l4:%';

  -- Examen blanc module — 15 QCM transversaux + 5 QR cas pratique
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold, is_mock_exam)
  VALUES (v_module, 'Examen blanc — BC01-03 Élaborer une cotation et une offre commerciale',
          'Examen blanc reproduisant les conditions de l''examen RNCP : 15 QCM transversaux (4 leçons) + 5 QR cas pratiques métier, durée 60 min, seuil 50 %.',
          'examen', 3600, 50, true)
  RETURNING id INTO v_quiz_eb;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref IN (
     -- 4 QCM Leçon 1
     'mft-2026-gotrm:bc01-03-v3:l1:q1','mft-2026-gotrm:bc01-03-v3:l1:q3',
     'mft-2026-gotrm:bc01-03-v3:l1:q5','mft-2026-gotrm:bc01-03-v3:l1:q9',
     -- 4 QCM Leçon 2
     'mft-2026-gotrm:bc01-03-v3:l2:q1','mft-2026-gotrm:bc01-03-v3:l2:q2',
     'mft-2026-gotrm:bc01-03-v3:l2:q4','mft-2026-gotrm:bc01-03-v3:l2:q9',
     -- 4 QCM Leçon 3
     'mft-2026-gotrm:bc01-03-v3:l3:q1','mft-2026-gotrm:bc01-03-v3:l3:q2',
     'mft-2026-gotrm:bc01-03-v3:l3:q3','mft-2026-gotrm:bc01-03-v3:l3:q5',
     -- 3 QCM Leçon 4
     'mft-2026-gotrm:bc01-03-v3:l4:q3','mft-2026-gotrm:bc01-03-v3:l4:q5',
     'mft-2026-gotrm:bc01-03-v3:l4:q11',
     -- 5 QR (cas pratiques transversaux)
     'mft-2026-gotrm:bc01-03-v3:qr1','mft-2026-gotrm:bc01-03-v3:qr3',
     'mft-2026-gotrm:bc01-03-v3:qr4','mft-2026-gotrm:bc01-03-v3:qr5',
     'mft-2026-gotrm:bc01-03-v3:qr6'
   );

  RAISE NOTICE '✓ GOTRM BC01-03 v3 dense importé : 4 leçons (CRKM, prix de vente, méthodologie cotation, négociation/indexation), 48 QCM, 8 QR cas pratiques métier, 5 quiz (4 entraînement + 1 examen blanc 15 QCM + 5 QR / 60 min).';

END $bc01_03_v3$;





