-- =====================================================================
-- MODULE D — ACTIVITÉ FINANCIÈRE (Capacité ≤ 3,5 T)
-- Version 3 (mai 2026) — REFONTE PÉDAGOGIQUE DENSIFIÉE
--
-- Diagnostic v2 corrigé :
--   ✓ Bug bloc : v_bloc résolu via slug fiable (pas ORDER BY id LIMIT 1)
--   ✓ Quiz : chaque quiz d'entraînement contient maintenant 12 QCM
--   ✓ Leçons : structure pédagogique pro (intro / dev / cas / synthèse /
--     "Ce que l'examinateur peut demander" / glossaire / mémo)
--   ✓ Banque enrichie : 48 QCM (vs 35) avec niveaux facile/moyen/difficile
--   ✓ QR : 7 (vs 6) avec barème implicite et cas réalistes
--   ✓ Examen blanc : 13 QCM + 5 QR (durée 60 min, seuil 50 %)
--
-- Référentiel décision du 2 avril 2012 — module à fort coefficient :
--   5 QCM (10 pts) + 1 coût de revient (30 pts) + 2 QR (10 pts) = 50 pts/84
-- ▸ 4 leçons :
--   1. Coût de revient kilométrique (CRKM) et seuil de rentabilité
--   2. Bilan et compte de résultat
--   3. Santé financière : ratios, BFR, trésorerie
--   4. Financement et fiscalité (IS, TVA, financement bancaire)
--
-- Idempotent. Pré-requis : formation 'capacite-3-5t'.
-- =====================================================================

DO $module_d_v3$
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
  v_quiz_7 uuid;
  v_quiz_8 uuid;
  v_quiz_eb uuid;
  v_q uuid;
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

  DELETE FROM public.modules WHERE slug = 'capa-activite-financiere';

  INSERT INTO public.modules (
    title, slug, bloc_id, summary, difficulty, duration_min, "order"
  ) VALUES (
    'Module D — Activité financière',
    'capa-activite-financiere',
    v_bloc,
    'Calculer son coût de revient kilométrique, lire un bilan et un compte de résultat, mesurer la santé financière (BFR, trésorerie, ratios), choisir un financement et maîtriser la fiscalité de l''entreprise de transport.',
    'avance',
    240,
    40
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 40, true) ON CONFLICT DO NOTHING;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026:moduleD:%';

  -- =================================================================
  -- LEÇON 1 — Coût de revient kilométrique (CRKM) et seuil de rentabilité
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Coût de revient kilométrique et seuil de rentabilité',
    'cout-revient-seuil-rentabilite',
    1, 60,
$lessonD1$
# Coût de revient kilométrique et seuil de rentabilité

> 🎯 **Objectifs pédagogiques**
>
> À la fin de cette leçon, vous serez capable de :
>
> - **Identifier** les charges fixes et variables d'une activité de transport.
> - **Calculer** un coût de revient kilométrique (CRKM) complet.
> - **Calculer** un seuil de rentabilité en km et en CA.
> - **Construire** un prix de vente cohérent à partir du CRKM.
> - **Anticiper** les pièges des activités déficitaires masquées.

---

## Introduction

Le coût de revient kilométrique est le **chiffre le plus important** que vous calculerez dans votre vie de transporteur. Mal le connaître = vendre à perte sans s'en rendre compte pendant 18 mois, puis déposer le bilan en s'étonnant. Le calculer précisément = savoir refuser un client mal payé, négocier des hausses tarifaires en fin d'année, dimensionner sa flotte au juste niveau.

Ce module D est aussi **le plus important de l'examen national** : 50 points sur 84, dont **30 points sur un seul exercice de coût de revient**. Maîtriser parfaitement la méthode présentée ici est non négociable. La leçon vous donne le pas-à-pas concret avec deux cas pratiques chiffrés.

---

## 1. Charges fixes vs charges variables

### 1.1 Définitions

> 📚 **Définitions**
>
> - **Charges fixes** : indépendantes du volume d'activité. Vous les payez **même si le VUL ne roule pas** (vacances, panne, COVID, faillite client). Exemples : leasing, assurance, abonnements, cotisations forfaitaires.
> - **Charges variables** : proportionnelles au volume d'activité. Vous les payez **uniquement si vous roulez**. Exemples : carburant, péages, entretien à l'usage, pneumatiques.

### 1.2 Tableau type pour 1 VUL ≤ 3,5 t

| Poste | Type | Coût annuel typique |
|---|---|---|
| Crédit-bail / leasing VUL | Fixe | 7 000 à 10 000 € |
| Assurance VUL + RC marchandises | Fixe | 2 000 à 3 500 € |
| Cotisations URSSAF (TNS, base forfait) | Mixte | 5 000 à 12 000 € |
| Frais de structure (compta, tél, abonnements) | Fixe | 2 000 à 4 000 € |
| Carburant | Variable | 0,12 à 0,18 €/km |
| Entretien (vidange, freins, pneus à l'usage) | Variable | 0,06 à 0,10 €/km |
| Péages (selon parcours) | Variable | 0,02 à 0,08 €/km |
| AdBlue (VUL Euro 6) | Variable | 0,01 €/km |

> ⚠️ **Attention examen**
>
> Le **carburant** est la charge variable n° 1. Une hausse de 10 % du gazole = +1,5 cts/km. Sur 30 000 km/an = **450 € de plus**. À surveiller via les indices CNR.

---

## 2. Calculer un CRKM complet

### 2.1 Méthode en 5 étapes

```
ÉTAPE 1 — Lister toutes les charges annuelles (fixes + variables × km prévus)
ÉTAPE 2 — Sommer le total
ÉTAPE 3 — Diviser par le kilométrage réel annuel
ÉTAPE 4 — Obtenir le CRKM (€/km)
ÉTAPE 5 — Ajouter une marge bénéficiaire pour fixer le prix de vente
```

### 2.2 Cas pratique 1 — Calcul détaillé

> 🚛 **Mise en situation**
>
> **Vous** dirigez une SARL avec 1 VUL ≤ 3,5 t. Données annuelles :
> - Leasing VUL : 8 400 €
> - Assurance + RC marchandises : 2 800 €
> - Frais de structure : 3 000 €
> - Cotisations URSSAF (gérant TNS, revenu 25 000 €) : 11 250 €
> - Carburant moyen : 8 L/100 km × 1,90 €/L
> - Entretien : 0,08 €/km
> - Péages : 0,03 €/km
> - Kilométrage annuel : **35 000 km**
>
> **Question :** calculez le CRKM complet.

**Correction étape par étape :**

| Étape | Détail | Montant |
|---|---|---|
| Charges fixes | Leasing 8 400 + Assurance 2 800 + Structure 3 000 + URSSAF 11 250 | **25 450 €/an** |
| Carburant | 8 L/100 km × 1,90 € = 0,152 €/km × 35 000 km | **5 320 €/an** |
| Entretien | 0,08 €/km × 35 000 km | **2 800 €/an** |
| Péages | 0,03 €/km × 35 000 km | **1 050 €/an** |
| **TOTAL CHARGES** | | **34 620 €/an** |
| **CRKM** | 34 620 € / 35 000 km | **0,989 €/km** |

→ Votre **plancher absolu** de tarification est **0,99 €/km**. En dessous = vente à perte.

### 2.3 De CRKM à prix de vente

Pour gagner votre vie, vous devez **ajouter une marge** au CRKM. Le taux dépend du contexte :

| Marge sur CRKM | Contexte | Prix HT pour CRKM 1 €/km |
|---|---|---|
| +5 à 10 % | Concurrence sévère, démarrage | 1,05 à 1,10 €/km |
| +15 à 25 % | Conditions de marché normales | 1,15 à 1,25 €/km |
| +30 à 50 % | Activité premium, clients haut de gamme | 1,30 à 1,50 €/km |

> 💡 **Astuce métier**
>
> Vendre à **CRKM + 5 %** est dangereux : la moindre hausse de gazole vous met en perte. Visez **CRKM + 15-25 %** au minimum. Si la concurrence vend en dessous, **ne courez pas après** : ces concurrents font faillite à 18 mois.

### 2.4 Mini-exercice guidé

> ✏️ **À vous**
>
> Charges fixes : 28 000 €/an. Charges variables : 0,40 €/km. Kilométrage prévu : 40 000 km/an.
>
> 1. Calculez le CRKM.
> 2. Quel prix de vente pour une marge de 20 % ?

**Correction :**

1. CRKM = (28 000 + 40 000 × 0,40) / 40 000 = (28 000 + 16 000) / 40 000 = 44 000 / 40 000 = **1,10 €/km**.
2. Prix de vente HT = 1,10 × 1,20 = **1,32 €/km**. Bénéfice attendu = 0,22 €/km × 40 000 = **8 800 €/an**.

---

## 3. Le seuil de rentabilité

### 3.1 Définition

> 📚 **Définition**
>
> Le **seuil de rentabilité** (ou « point mort ») est le **chiffre d'affaires minimum** que vous devez réaliser pour **couvrir l'ensemble de vos charges** (fixes + variables). Au-dessus, vous générez un bénéfice. En dessous, vous êtes en perte.

### 3.2 Formule

```
SR (en €) = Charges fixes / Taux de marge sur coûts variables
SR (en km) = Charges fixes / (Prix unitaire - Coût variable unitaire)
```

### 3.3 Cas pratique 2 — Calcul de seuil

> 🚛 **Mise en situation**
>
> Charges fixes : **24 000 €/an**. Charges variables : **0,45 €/km**. Prix de vente : **1,20 €/km**.
>
> **Question :** quel kilométrage minimum pour ne pas être en perte ?

**Correction :**

| Étape | Calcul | Résultat |
|---|---|---|
| Marge unitaire | 1,20 € - 0,45 € | **0,75 €/km** |
| Taux de marge sur CV | 0,75 / 1,20 | **62,5 %** |
| Seuil en km | 24 000 € / 0,75 € | **32 000 km/an** |
| Seuil en CA | 32 000 × 1,20 | **38 400 € HT/an** |

**Interprétation :**

- En dessous de **32 000 km/an** (≈ 2 667 km/mois ou 121 km/jour ouvré), vous êtes en perte.
- Au-dessus, chaque km supplémentaire vous rapporte **0,75 € de marge**.
- À **40 000 km/an** : marge = (40 000 - 32 000) × 0,75 = **6 000 € de bénéfice**.

### 3.4 Erreurs fréquentes à éviter

> ❌ **Erreur n° 1 — Oublier les cotisations URSSAF dans le CRKM**
>
> Beaucoup d'auto-entrepreneurs débutants calculent leur CRKM **sans** intégrer leurs cotisations sociales. Résultat : CRKM apparent 0,75 €/km, CRKM réel 1,05 €/km. Ils croient gagner 0,25 €/km en vendant à 1 €, ils perdent 0,05 €/km en réalité.

> ❌ **Erreur n° 2 — Sous-estimer le kilométrage à vide**
>
> Pour 100 km facturés, vous roulez en réalité 130-150 km (retours à vide, repositionnements). Si vous comptez le carburant uniquement sur les 100 km vendus, vous sous-évaluez de 30 % vos charges variables.

> ❌ **Erreur n° 3 — Ne pas réviser le CRKM**
>
> Le gazole varie de 20-30 % en quelques mois. Recalculez votre CRKM **tous les 6 mois** et révisez vos tarifs en conséquence (clauses d'indexation CNR dans vos contrats récurrents).

---

## 4. Glossaire des notions clés

| Terme | Définition |
|---|---|
| **CRKM** | Coût de revient kilométrique, en €/km |
| **Charges fixes** | Indépendantes du volume d'activité |
| **Charges variables** | Proportionnelles au volume d'activité |
| **Marge sur coûts variables** | Prix de vente - Coût variable unitaire |
| **Taux de marge sur CV** | Marge sur CV / Prix de vente (%) |
| **Seuil de rentabilité** | CA minimum pour couvrir toutes les charges |
| **Point mort** | Synonyme de seuil de rentabilité |
| **Indice CNR** | Indice du Comité National Routier pour réviser les prix |
| **Km à vide** | Kilomètres parcourus non facturés (retours, repositionnements) |
| **Marge bénéficiaire** | Différence entre prix de vente et CRKM |

---

## 🧠 Synthèse opérationnelle

> 📌 **Les 8 points à retenir**
>
> 1. **Charges fixes** : leasing, assurance, URSSAF (forfait), structure. **Charges variables** : carburant, entretien, péages.
> 2. **CRKM** = (Charges fixes + Charges variables × km) / km parcourus.
> 3. **CRKM moyen VUL ≤ 3,5 t** : 0,90 à 1,10 €/km tout compris.
> 4. **Prix de vente** = CRKM × (1 + taux de marge). Visez **+15 à 25 %** au minimum.
> 5. **Seuil de rentabilité** (en €) = Charges fixes / Taux de marge sur CV.
> 6. **Seuil en km** = Charges fixes / Marge unitaire.
> 7. Pièges : oublier les cotisations URSSAF, sous-estimer les km à vide, ne pas réviser le CRKM tous les 6 mois.
> 8. **Indices CNR** = outil de référence pour réviser les prix transport (gazole, salaires, péages).

---

## 🎓 Ce que l'examinateur peut demander

Module D = exercice de coût de revient à 30 points. Toujours détailler vos calculs étape par étape. Format type :

1. « Calculer le CRKM complet pour 1 VUL à partir des données suivantes (leasing, carburant, URSSAF, etc.). »
2. « Calculer le seuil de rentabilité en km et en CA. »
3. « Quel prix de vente pour atteindre 15 % de marge ? »
4. « À quel kilométrage atteint-on un bénéfice de X € ? »

**Méthode pour gagner les 30 points :**
- Lister toutes les charges en tableau.
- Distinguer FIXES et VARIABLES.
- Faire la somme intermédiaire.
- Diviser par le km.
- Conclure avec une phrase explicative.

---

## 📋 Mémo à imprimer

```
CRKM = (Charges fixes + Charges variables × km) / km parcourus

CHARGES FIXES (typiques 1 VUL)
  Leasing                : 7 000 à 10 000 €/an
  Assurance + RCM        : 2 000 à 3 500 €/an
  Frais de structure     : 2 000 à 4 000 €/an
  URSSAF (TNS forfait)   : 5 000 à 12 000 €/an

CHARGES VARIABLES
  Carburant              : 0,12 à 0,18 €/km
  Entretien              : 0,06 à 0,10 €/km
  Péages                 : 0,02 à 0,08 €/km

CRKM TYPIQUE             : 0,90 à 1,10 €/km

PRIX DE VENTE = CRKM × (1 + marge)
  Démarrage / concurrence : +5 à 10 %
  Marché normal           : +15 à 25 %  ← CIBLE
  Activité premium        : +30 à 50 %

SEUIL DE RENTABILITÉ
  En km : Charges fixes / Marge unitaire
  En €  : Charges fixes / Taux de marge sur CV
```
$lessonD1$,
'Calculer un coût de revient kilométrique (CRKM) complet, fixer un prix de vente cohérent et maîtriser la formule du seuil de rentabilité — base de l''exercice à 30 points de l''examen national.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Bilan et compte de résultat
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Bilan et compte de résultat',
    'bilan-compte-resultat',
    2, 55,
$lessonD2$
# Bilan et compte de résultat

> 🎯 **Objectifs pédagogiques**
>
> - **Distinguer** la photo (bilan) du film (compte de résultat).
> - **Lire** un actif et un passif sans paniquer.
> - **Identifier** les principaux postes du compte de résultat.
> - **Calculer** les soldes intermédiaires de gestion (SIG).
> - **Interpréter** un résultat net en lien avec la trésorerie.

---

## Introduction

Le bilan et le compte de résultat sont les **deux documents comptables fondamentaux** que tout chef d'entreprise doit savoir lire. À l'examen, on ne vous demandera pas de les construire (c'est le métier de l'expert-comptable), mais on attend que vous **compreniez** ce qu'ils racontent et que vous sachiez **réagir** quand un poste s'aggrave.

L'analogie la plus juste :

- **Bilan = photographie** prise un jour précis (le 31/12 généralement). Que possède l'entreprise ? Que doit-elle ? Où en est son patrimoine ?
- **Compte de résultat = film** d'une année. Combien a-t-elle vendu ? Dépensé ? Gagné ou perdu ?

Les deux se complètent. Sans le compte de résultat, on ne sait pas ce qui s'est passé. Sans le bilan, on ne sait pas ce qui reste.

---

## 1. Le bilan : actif = passif

### 1.1 Principe d'équilibre

Le bilan repose sur une règle d'or :

> **TOTAL ACTIF = TOTAL PASSIF**

Pourquoi ? Parce que tout ce que possède l'entreprise (actif) a forcément été **financé** par quelque chose (passif). Ce n'est pas une coïncidence comptable, c'est une identité mathématique.

### 1.2 L'actif : ce que l'entreprise possède

L'actif se lit du **moins liquide** (en haut) au **plus liquide** (en bas) :

| Poste | Nature | Exemples (transport) |
|---|---|---|
| **Actif immobilisé** | Long terme (>1 an) | Camions, VUL, hangars, logiciel TMS, dépôts garantie |
| **Actif circulant** | Court terme (<1 an) | Stocks (carburant, pneus), créances clients, effets à recevoir |
| **Trésorerie** | Disponible | Banque, caisse, valeurs mobilières placement |

**Distinction critique : immobilisations corporelles vs incorporelles.**
- Corporelles : ce qui se touche (véhicules, matériel, mobilier).
- Incorporelles : licences, fonds de commerce, logiciels, marques.

Les **amortissements** viennent en moins de l'actif immobilisé. Un camion acheté 50 000 € amorti sur 5 ans perd 10 000 € de valeur par an au bilan.

### 1.3 Le passif : comment c'est financé

Le passif se lit du **plus stable** (en haut) au **plus exigible** (en bas) :

| Poste | Nature | Exemples |
|---|---|---|
| **Capitaux propres** | Apport perso + bénéfices accumulés | Capital social, réserves, report à nouveau, résultat de l'exercice |
| **Dettes financières** | Emprunts | Emprunt bancaire véhicule, leasing à dette, découvert moyen terme |
| **Dettes d'exploitation** | Court terme | Fournisseurs, dettes fiscales (TVA, IS), dettes sociales (URSSAF) |

**Règle de prudence (cours d'analyse financière) :** les emplois longs (immobilisations) doivent être financés par des ressources longues (capitaux propres + dettes long terme). Sinon, on dit que le **fonds de roulement est négatif** — la trésorerie va se dégrader.

### 1.4 Bilan type d'un transporteur 1 véhicule

```
ACTIF                                   PASSIF
─────────────────────────────────────   ─────────────────────────────────────
Immobilisations corporelles  35 000 €   Capital social              5 000 €
  (1 VUL amorti 2/5)                    Réserves                    8 000 €
Stocks (pneus, divers)        1 000 €   Résultat de l'exercice      4 500 €
Créances clients             12 000 €   ─────                     ─────────
Trésorerie                    3 500 €   Total capitaux propres     17 500 €
                                        Emprunts bancaires LT      18 000 €
                                        Fournisseurs                4 000 €
                                        Dettes fiscales/sociales   12 000 €
                                        ─────                     ─────────
TOTAL ACTIF                  51 500 €   TOTAL PASSIF               51 500 €
```

> 💡 **Lecture rapide :** ce transporteur a 12 000 € de créances clients (3 mois de CA non encaissés) pour seulement 3 500 € en banque. Sa trésorerie est tendue. Il dépend du règlement de ses clients.

---

## 2. Le compte de résultat : produits − charges = résultat

### 2.1 Structure générale

Le compte de résultat liste tout ce que l'entreprise a **gagné** (produits) et tout ce qu'elle a **dépensé** (charges) sur l'exercice.

> **PRODUITS − CHARGES = RÉSULTAT**

Le résultat est :
- **Positif** = bénéfice → augmente les capitaux propres au bilan suivant
- **Négatif** = perte → diminue les capitaux propres

### 2.2 Trois niveaux d'activité

Le compte de résultat se découpe en trois zones :

| Zone | Produits | Charges |
|---|---|---|
| **Exploitation** | Ventes, prestations, subventions | Achats, charges externes, salaires, amortissements |
| **Financier** | Intérêts placements, gains change | Intérêts emprunts, agios |
| **Exceptionnel** | Plus-values cession véhicule | Pénalités, amendes, moins-values |

**Pourquoi cette distinction ?** Parce qu'un patron veut savoir si son **métier** est rentable, sans être pollué par une vente exceptionnelle de camion ou des intérêts d'emprunt.

### 2.3 Compte de résultat type (transport léger)

```
PRODUITS D'EXPLOITATION
  Chiffre d'affaires                                      120 000 €
  Production stockée                                            0 €
  Subventions d'exploitation                                  500 €
  Total produits d'exploitation                          120 500 €

CHARGES D'EXPLOITATION
  Achats consommés (carburant, lubrifiants)                21 000 €
  Charges externes (assurance, leasing, télécoms, péages)  18 500 €
  Impôts et taxes                                           1 200 €
  Salaires et charges sociales                             45 000 €
  Dotations amortissements                                 10 000 €
  Total charges d'exploitation                            95 700 €

RÉSULTAT D'EXPLOITATION                                   24 800 €

  Charges financières (intérêts emprunt)                   1 800 €

RÉSULTAT FINANCIER                                        − 1 800 €

RÉSULTAT COURANT AVANT IMPÔT                              23 000 €

  Résultat exceptionnel                                         0 €

RÉSULTAT AVANT IMPÔT                                      23 000 €
  Impôt sur les sociétés (15 % jusqu'à 42 500 €)            3 450 €

RÉSULTAT NET                                              19 550 €
```

---

## 3. Les soldes intermédiaires de gestion (SIG)

### 3.1 À quoi servent les SIG ?

Les SIG **décomposent** le résultat pour comprendre **d'où vient la performance**. Ils répondent à des questions précises :
- Combien je crée de valeur sur ce que j'achète ? (VA)
- Combien il me reste avant amortissements ? (EBE)
- Mon métier est-il rentable hors finance ? (Résultat d'exploitation)
- Combien je conserve vraiment ? (Résultat net)

### 3.2 Les 4 SIG essentiels

| SIG | Formule simplifiée | Ce que ça mesure |
|---|---|---|
| **Valeur Ajoutée (VA)** | CA − Achats consommés − Charges externes | Richesse créée par l'entreprise |
| **Excédent Brut d'Exploitation (EBE)** | VA − Salaires − Charges sociales − Impôts/taxes | Performance opérationnelle pure |
| **Résultat d'exploitation** | EBE − Dotations amortissements − Provisions | Performance après vieillissement matériel |
| **Résultat net** | Résultat avant impôt − IS | Ce qui revient au patron |

### 3.3 Application sur le compte ci-dessus

```
CA                                                       120 000 €
  − Achats consommés                                   −  21 000 €
  − Charges externes                                   −  18 500 €
VALEUR AJOUTÉE                                            80 500 €
  − Salaires + charges sociales                        −  45 000 €
  − Impôts et taxes                                    −   1 200 €
  + Subventions exploitation                           +     500 €
EBE                                                       34 800 €
  − Dotations amortissements                           −  10 000 €
RÉSULTAT D'EXPLOITATION                                   24 800 €
  − Charges financières                                −   1 800 €
RÉSULTAT COURANT AVANT IMPÔT                              23 000 €
  − IS (15 %)                                          −   3 450 €
RÉSULTAT NET                                              19 550 €
```

### 3.4 Lecture pour le patron

- **VA = 80 500 €** sur 120 000 € de CA → taux de VA = 67 %. Bon pour du transport (la moyenne sectorielle se situe entre 50 et 70 %).
- **EBE = 34 800 €** → 29 % du CA. Excellent pour 1 VUL.
- **Résultat net = 19 550 €** → reste ~16 % du CA. Sain.

> ⚠️ **Erreur classique :** confondre résultat net et trésorerie disponible. Un résultat de 19 550 € ne signifie PAS qu'il y a 19 550 € en banque. La différence vient des décalages (créances non encaissées, dettes non payées, amortissements qui sont des charges sans sortie de cash). Voir Leçon 3.

---

## 4. Cas pratique d'examen

**Énoncé :** Une SARL de transport présente le compte de résultat suivant pour 2026 :

```
CA                              156 000 €
Achats carburant + lubrifiants   28 000 €
Assurance + leasing + péages     22 000 €
Salaires bruts + charges         68 000 €
Impôts et taxes                   1 800 €
Dotations amortissements         12 000 €
Charges financières               2 200 €
```

**Calculez : VA, EBE, résultat d'exploitation, résultat avant impôt, résultat net (IS 15 %).**

**Correction :**

| Solde | Calcul | Valeur |
|---|---|---|
| VA | 156 000 − 28 000 − 22 000 | **106 000 €** |
| EBE | 106 000 − 68 000 − 1 800 | **36 200 €** |
| Résultat d'exploitation | 36 200 − 12 000 | **24 200 €** |
| Résultat avant impôt | 24 200 − 2 200 | **22 000 €** |
| IS (15 %) | 22 000 × 0,15 | **3 300 €** |
| **Résultat net** | 22 000 − 3 300 | **18 700 €** |

**Interprétation :** taux de VA = 68 % (bon), taux d'EBE = 23 % (correct), résultat net = 12 % du CA (sain). Entreprise saine, à condition que la trésorerie suive (voir leçon suivante).

---

## 5. Mini-exercice à faire seul

**Énoncé :** Une EI de coursier urbain présente :
- CA : 62 000 €
- Carburant : 9 500 €
- Charges externes (assurance, location véhicule) : 11 000 €
- Pas de salarié (le patron est TNS, pas de salaire au compte de résultat)
- URSSAF TNS : 7 000 €
- Dotations amortissements : 3 500 € (vélo cargo + VAE)
- Charges financières : 0 €

**Question :** calculer la VA, l'EBE, le résultat d'exploitation et le résultat net (régime micro = pas d'IS, mais on simule à 15 % pour l'exercice).

> 💡 Réponse à la fin du module (chapitre 4).

---

## 6. Glossaire

- **Actif** : tout ce que l'entreprise possède (immobilisations, stocks, créances, trésorerie).
- **Passif** : tout ce qui finance l'actif (capitaux propres + dettes).
- **Capitaux propres** : capital social + réserves + résultat. C'est la "richesse nette" de l'entreprise.
- **Amortissement** : étalement comptable de l'usure d'un bien sur sa durée d'usage.
- **Charges externes** : tout ce qui n'est ni achat de matière, ni salaire (assurance, leasing, télécoms, honoraires).
- **VA (Valeur Ajoutée)** : richesse créée par l'entreprise = CA − consommations en provenance de tiers.
- **EBE** : VA − charges de personnel − impôts/taxes + subventions. Indicateur de performance opérationnelle.
- **Dotation aux amortissements** : charge non décaissée traduisant l'usure d'un bien.

---

## 7. Synthèse opérationnelle

1. **Bilan = photo** au 31/12. Actif = ce que je possède. Passif = comment je l'ai financé.
2. **Compte de résultat = film** de l'année. Produits − Charges = Résultat.
3. **Équilibre comptable** : Total actif = Total passif. Toujours.
4. **3 zones** au compte de résultat : exploitation, financier, exceptionnel.
5. **4 SIG essentiels** : VA, EBE, résultat d'exploitation, résultat net.
6. **VA** mesure la richesse créée. **EBE** la performance opérationnelle. **Résultat d'exploitation** la performance métier.
7. **Résultat net ≠ trésorerie**. Ne pas confondre.
8. **Amortissement = charge sans sortie d'argent**. C'est une convention comptable.

---

## 🎓 Ce que l'examinateur peut demander

Au QCM (5 questions, 10 pts) :

1. Différence bilan / compte de résultat.
2. Composition de l'actif et du passif.
3. Calcul d'un SIG simple (souvent VA ou EBE).
4. Lecture d'un poste : « que signifie "dotations amortissements" ? »
5. Identifier le résultat net dans un compte de résultat fourni.

En QR ouverte :
- « Expliquez la différence entre résultat net et trésorerie. »
- « Calculer la VA et l'EBE à partir du tableau ci-dessous. »

---

## 📋 Mémo à imprimer

```
BILAN  =  PHOTO au 31/12
ACTIF                            PASSIF
  Immobilisations                  Capitaux propres
    (corp. + incorp. − amort.)       (capital + réserves + résultat)
  Actif circulant                  Dettes financières (LT)
    (stocks + créances)            Dettes d'exploitation (CT)
  Trésorerie                         (fournisseurs, fiscales, sociales)
                       TOTAL ACTIF = TOTAL PASSIF

COMPTE DE RÉSULTAT  =  FILM de l'année
  PRODUITS − CHARGES = RÉSULTAT

3 zones :  Exploitation  |  Financier  |  Exceptionnel

4 SIG :
  VA       = CA − Achats − Charges externes
  EBE      = VA − Salaires & charges − Impôts & taxes (+ Subv.)
  RE       = EBE − Dotations amortissements
  RN       = (RE + Résultat fin. + Résultat exc.) × (1 − tx IS)

⚠ Résultat net ≠ trésorerie disponible !
```
$lessonD2$,
'Distinguer le bilan (photo) du compte de résultat (film), lire un actif/passif, calculer les soldes intermédiaires de gestion (VA, EBE, résultat d''exploitation, résultat net) et interpréter la performance d''une entreprise de transport.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Santé financière : ratios, BFR, trésorerie
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Santé financière : ratios, BFR, trésorerie',
    'sante-financiere-bfr-tresorerie',
    3, 55,
$lessonD3$
# Santé financière : ratios, BFR, trésorerie

> 🎯 **Objectifs pédagogiques**
>
> - **Calculer** un fonds de roulement, un BFR et une trésorerie nette.
> - **Diagnostiquer** la solvabilité et la liquidité d'une entreprise.
> - **Identifier** les 5 ratios financiers que l'examinateur attend.
> - **Détecter** les signaux faibles avant le dépôt de bilan.
> - **Mettre en place** un plan de trésorerie mensuel.

---

## Introduction

Une entreprise peut être **bénéficiaire et faire faillite la même année**. Ce paradoxe — bien réel — vient du fait que **bénéfice ≠ trésorerie**. Vendre 100 000 € à un client qui paye à 90 jours ne vous met pas 100 000 € sur le compte le jour de la facturation. Pendant ces 90 jours, il faut payer carburant, salaires, leasing. Si la trésorerie ne suit pas, l'entreprise meurt malgré son bénéfice comptable.

C'est là toute l'importance de la santé financière : elle vérifie qu'**au-delà du résultat, l'entreprise tient debout au quotidien**.

L'examinateur vous demandera typiquement de calculer **2 ou 3 ratios** et d'interpréter. Cette leçon vous arme pour ces 5-10 points clés.

---

## 1. Fonds de roulement, BFR, trésorerie

### 1.1 Le triangle financier

Trois grandeurs liées par une équation simple :

> **Fonds de roulement (FR) − Besoin en fonds de roulement (BFR) = Trésorerie nette (TN)**

#### a) Le fonds de roulement (FR)

Le FR vérifie que les **emplois longs** (immobilisations) sont financés par des **ressources longues** (capitaux propres + dettes long terme).

> **FR = (Capitaux propres + Dettes financières LT) − Immobilisations nettes**

- **FR positif** : les ressources longues couvrent les emplois longs et il reste de la marge pour le cycle d'exploitation. Sain.
- **FR négatif** : on a financé du long terme avec du court terme. Dangereux : à la première crise, la banque coupe le découvert et l'entreprise tombe.

#### b) Le besoin en fonds de roulement (BFR)

Le BFR mesure le **décalage entre ce que vous payez et ce que vous encaissez**.

> **BFR = (Stocks + Créances clients) − Dettes fournisseurs et autres dettes d'exploitation**

- **BFR positif** = vous financez vos clients (vous payez avant d'encaisser). Cas typique du transport B2B.
- **BFR négatif** = vos fournisseurs vous financent (rare en transport, sauf grandes enseignes type GMS).

#### c) La trésorerie nette (TN)

> **TN = FR − BFR**

C'est ce qu'il reste **une fois le cycle d'exploitation financé**. Si elle est négative en permanence, l'entreprise vit à découvert (frais financiers élevés) ou ne peut plus payer.

### 1.2 Application chiffrée

Bilan d'une PME de transport (résumé) :

```
ACTIF                                 PASSIF
Immobilisations nettes  120 000 €     Capitaux propres        70 000 €
Stocks                    8 000 €     Dettes LT (emprunt)     90 000 €
Créances clients         42 000 €     Fournisseurs            22 000 €
Trésorerie                7 000 €     Dettes fisc./soc.       18 000 €
TOTAL                   177 000 €     Découvert bancaire      − 23 000 €
                                      TOTAL                  177 000 €
```

```
FR  = (70 000 + 90 000) − 120 000              = 40 000 €  (positif, sain)
BFR = (8 000 + 42 000) − (22 000 + 18 000)     = 10 000 €  (modéré)
TN  = 40 000 − 10 000                          = 30 000 €  → ATTENTION
```

> 💡 Mais le bilan affiche 7 000 € en banque et −23 000 € de découvert, soit TN réelle = −16 000 €. Si la TN calculée diverge de la TN réelle, **on a fait une erreur** ou **on lit un bilan déjà en stress**.

### 1.3 Lecture d'un BFR pour un transporteur

| Poste | Délai moyen transport | Conséquence |
|---|---|---|
| Stocks (carburant, pneus) | 5 à 15 jours | Faible impact |
| Créances clients | **45 à 90 jours** (B2B) | **Fort impact +** |
| Fournisseurs | 30 à 60 jours | Impact négatif − |
| Salaires | Mensuel (M+5 à M+10) | Pas dans BFR |
| URSSAF | Mensuel ou trimestriel | Dans dettes sociales |

**Règle métier :** le BFR d'un transporteur représente souvent **30 à 60 jours de CA**. Pour un CA annuel de 500 000 €, c'est 40 000 à 80 000 € à immobiliser en permanence.

---

## 2. Les 5 ratios essentiels

### 2.1 Ratio de solvabilité

> **Solvabilité = Capitaux propres / Total bilan**

- **> 30 %** : structure saine.
- **20-30 %** : surveillance.
- **< 20 %** : risque (la moindre perte mange les fonds propres).

### 2.2 Ratio d'autonomie financière

> **Autonomie = Capitaux propres / Dettes financières**

- **> 1** : l'entreprise est plus financée par elle-même que par les banques.
- **< 1** : dépendance bancaire forte.
- **< 0,5** : surendettement.

### 2.3 Ratio de liquidité générale

> **Liquidité = Actif circulant / Dettes court terme**

- **> 1,5** : confortable.
- **1 à 1,5** : limite.
- **< 1** : impossibilité théorique de payer ses dettes CT.

### 2.4 Délai client (DSO)

> **DSO = Créances clients / CA TTC × 365**

- **< 30 jours** : excellent.
- **30 à 60 jours** : standard.
- **> 75 jours** : alerte (faire de la relance, factoring).

**Rappel LME** : entre professionnels, le délai de paiement maximum est de 60 jours date facture (ou 45 jours fin de mois). Voir module C.

### 2.5 Délai fournisseur (DPO)

> **DPO = Dettes fournisseurs / Achats TTC × 365**

À comparer avec le DSO. Si **DPO > DSO**, vous êtes financé par vos fournisseurs (rare en transport). Si **DPO < DSO**, vous financez vos clients (cas général). L'écart × CA journalier = besoin de trésorerie.

---

## 3. Le plan de trésorerie

### 3.1 Pourquoi le faire ?

Le plan de trésorerie est l'**outil quotidien** du chef d'entreprise. Il liste mois par mois :
- les encaissements prévisionnels (clients, subventions),
- les décaissements prévisionnels (fournisseurs, salaires, URSSAF, IS, leasing),
- la position de fin de mois.

Il permet d'**anticiper** les mois rouges (URSSAF de janvier, IS d'avril, congés payés d'août) et de négocier à temps un découvert ou un crédit court terme.

### 3.2 Modèle simplifié (3 mois)

| Poste | Janv | Févr | Mars |
|---|---|---|---|
| **Solde début de mois** | 8 000 | 2 500 | 5 700 |
| Encaissements clients | 38 000 | 42 000 | 45 000 |
| **Total entrées** | **46 000** | **44 500** | **50 700** |
| Carburant | 8 500 | 9 000 | 9 500 |
| Salaires + charges | 18 000 | 18 000 | 18 000 |
| URSSAF TNS trimestrielle | 9 000 | 0 | 0 |
| Leasing véhicules | 4 500 | 4 500 | 4 500 |
| Fournisseurs divers | 3 500 | 4 800 | 5 200 |
| Impôts/taxes | 0 | 2 500 | 0 |
| **Total sorties** | **43 500** | **38 800** | **37 200** |
| **Solde fin de mois** | **2 500** | **5 700** | **13 500** |

> ⚠️ Le mois de janvier est **tendu** (URSSAF). À planifier 6 mois à l'avance.

---

## 4. Cas pratique d'examen

**Énoncé :** Bilan d'une SARL transport (en €) :

```
ACTIF                                 PASSIF
Immobilisations           160 000     Capitaux propres        65 000
Stocks                      6 000     Emprunts LT            120 000
Créances clients           58 000     Fournisseurs           28 000
Trésorerie                 12 000     Dettes fisc./soc.      23 000
                                      ─────                 ───────
TOTAL                     236 000     TOTAL                 236 000
```

CA TTC annuel : 380 000 €.

**Calculez : FR, BFR, TN, ratio de solvabilité, DSO. Concluez.**

**Correction :**

| Indicateur | Calcul | Valeur | Interprétation |
|---|---|---|---|
| FR | (65 000 + 120 000) − 160 000 | **25 000 €** | Positif mais faible |
| BFR | (6 000 + 58 000) − (28 000 + 23 000) | **13 000 €** | Modéré |
| TN | 25 000 − 13 000 | **12 000 €** | OK (cohérent avec les 12 000 € au bilan) |
| Solvabilité | 65 000 / 236 000 | **28 %** | Limite (norme 30 %) |
| DSO | 58 000 / 380 000 × 365 | **56 jours** | Standard B2B |

**Conclusion :** entreprise viable mais fragile. Solvabilité juste sous le seuil de confort. Une mauvaise année éroderait vite les capitaux propres. Recommandation : **renforcer les fonds propres** (incorporation de réserves, augmentation de capital) ou **réduire les dettes long terme** par anticipation.

---

## 5. Mini-exercice à faire seul

Vos données :
- CA TTC annuel : 240 000 €
- Créances clients : 48 000 €
- Capitaux propres : 35 000 €
- Total bilan : 145 000 €

**Calculez le DSO et le ratio de solvabilité. Concluez.**

> 💡 Correction en fin de module.

---

## 6. Glossaire

- **FR (Fonds de roulement)** : ressources stables − emplois stables.
- **BFR** : décalage net entre ce qui est dû et ce qui est exigible (côté exploitation).
- **TN (Trésorerie nette)** : FR − BFR = ce qu'il reste après cycle d'exploitation.
- **DSO (Days Sales Outstanding)** : délai moyen d'encaissement client.
- **DPO (Days Payable Outstanding)** : délai moyen de paiement fournisseur.
- **Solvabilité** : capacité à rembourser ses dettes (ratio capitaux propres / total bilan).
- **Liquidité** : capacité à payer ses dettes à court terme.
- **Plan de trésorerie** : tableau prévisionnel mois par mois des entrées/sorties d'argent.

---

## 7. Synthèse opérationnelle

1. **FR > 0** = ressources longues couvrent emplois longs. Sain.
2. **BFR > 0** = vous financez votre cycle d'exploitation (cas du transport B2B).
3. **TN = FR − BFR**. Si négative durablement, danger.
4. **5 ratios** : solvabilité, autonomie, liquidité, DSO, DPO.
5. **Solvabilité ≥ 30 %** = norme de confort.
6. **DSO ≤ 60 jours** = LME respectée.
7. **Bénéfice ≠ trésorerie**. C'est l'erreur la plus fatale.
8. **Plan de trésorerie mensuel** = outil indispensable pour anticiper.

---

## 🎓 Ce que l'examinateur peut demander

- Calcul du FR, BFR, TN à partir d'un bilan.
- Calcul d'un ratio de solvabilité ou de liquidité avec interprétation.
- Calcul d'un DSO et lien avec la LME.
- Question ouverte : « Une entreprise bénéficiaire peut-elle déposer le bilan ? Pourquoi ? »
- Question ouverte : « À quoi sert un plan de trésorerie ? »

---

## 📋 Mémo à imprimer

```
LE TRIANGLE FINANCIER

  FR = (Cap. propres + Dettes LT) − Immobilisations nettes
  BFR = (Stocks + Créances) − (Fournisseurs + Dettes exploit.)
  TN = FR − BFR

5 RATIOS À MAÎTRISER

  Solvabilité    = Capitaux propres / Total bilan          ≥ 30 %
  Autonomie fin. = Capitaux propres / Dettes financières   > 1
  Liquidité gén. = Actif circulant / Dettes CT             > 1,5
  DSO            = Créances clients / CA TTC × 365         < 60 j
  DPO            = Fournisseurs / Achats TTC × 365         à comparer DSO

⚠ Bénéfice ≠ Trésorerie
⚠ Plan de trésorerie mensuel obligatoire dès le démarrage
```
$lessonD3$,
'Calculer le fonds de roulement, le BFR et la trésorerie nette, maîtriser les 5 ratios financiers (solvabilité, autonomie, liquidité, DSO, DPO) et construire un plan de trésorerie pour anticiper les mois tendus.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Financement et fiscalité
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Financement et fiscalité',
    'financement-fiscalite',
    4, 50,
$lessonD4$
# Financement et fiscalité

> 🎯 **Objectifs pédagogiques**
>
> - **Comparer** les modes de financement véhicule (achat, crédit, leasing, LOA).
> - **Calculer** le coût total d'un financement.
> - **Identifier** les régimes d'imposition (IR / IS) et leurs conséquences.
> - **Maîtriser** la TVA en transport (taux, déductibilité, déclaration).
> - **Anticiper** les principales taxes sectorielles.

---

## Introduction

Choisir un mode de financement et un régime fiscal n'est pas un détail administratif : c'est **plusieurs milliers d'euros par an** de différence sur le résultat. À l'examen, on attend que vous sachiez :
1. Comparer un crédit-bail et un emprunt sur le coût total.
2. Distinguer IR et IS.
3. Récupérer correctement la TVA sur le carburant et les véhicules.

Cette leçon clôt le module en abordant ces choix structurants.

---

## 1. Les modes de financement

### 1.1 Achat comptant

Vous payez le véhicule en totalité à la livraison.

| Avantages | Inconvénients |
|---|---|
| Pas d'intérêts à payer | Sortie massive de trésorerie |
| Véhicule à l'actif → patrimoine | Capacité d'investissement bloquée |
| Amortissement comptable | Risque sur 1 seul actif |

**Quand le faire ?** Si trésorerie excédentaire, taux bancaires élevés, et véhicule durable (>5 ans).

### 1.2 Emprunt bancaire

Vous empruntez tout ou partie du prix, remboursable en mensualités sur 3-7 ans.

| Avantages | Inconvénients |
|---|---|
| Véhicule à l'actif (vous êtes propriétaire) | Apport souvent demandé (10-30 %) |
| Intérêts déductibles | Garanties exigées (caution perso) |
| Échéances fixes | Ratio d'endettement limité |

**Coût total = Capital + Intérêts** (souvent +15 à +25 % du prix sur 5 ans).

### 1.3 Crédit-bail (leasing)

La banque achète le véhicule et vous le **loue**. À la fin du contrat, vous pouvez **lever l'option d'achat** (souvent 1 à 5 % de la valeur d'origine).

| Avantages | Inconvénients |
|---|---|
| Pas d'apport (souvent) | Pas propriétaire avant la levée d'option |
| Loyers 100 % déductibles (charges) | Coût total > emprunt |
| Pas dans le bilan (jusqu'à IFRS 16) | Engagement long, sortie difficile |

### 1.4 LOA (Location avec Option d'Achat)

Quasi-identique au crédit-bail mais juridiquement réservée aux particuliers et petites entreprises. Plus souple, plus chère.

### 1.5 LLD (Location Longue Durée)

Vous **louez** sans option d'achat, sur 24 à 60 mois. Le véhicule **n'apparaît jamais à votre bilan**.

| Avantages | Inconvénients |
|---|---|
| Mensualités tout compris (entretien, assurance) | Pas de propriété possible |
| Trésorerie protégée | Coût total élevé |
| Renouvellement régulier facile | Pénalités de résiliation forte |

### 1.6 Tableau comparatif (camionnette 30 000 € HT)

| Mode | Mensualité estimée | Coût total 5 ans | Propriétaire à la fin ? | Bilan |
|---|---|---|---|---|
| Achat comptant | — | 30 000 € | ✅ | Au bilan |
| Emprunt 5 ans 4 % | 553 € | 33 200 € | ✅ | Au bilan |
| Crédit-bail | 580 € | 34 800 € + option 600 € | ✅ après option | Hors bilan |
| LOA | 600 € | 36 000 € + option 1 500 € | ✅ après option | Hors bilan |
| LLD | 650 € (entretien inclus) | 39 000 € | ❌ | Hors bilan |

### 1.7 Cas pratique

**Énoncé :** vous hésitez entre :
- Emprunt 5 ans à 4,5 % pour un véhicule à 28 000 € HT (apport 4 000 €).
- Crédit-bail 60 mois à 540 €/mois + option d'achat 800 €.

Sur 5 ans, lequel coûte le moins cher ?

**Calculs simplifiés :**

| Option | Coût |
|---|---|
| Emprunt : apport 4 000 + (24 000 × 1,045^5 ÷ 60) × 60 | ≈ 4 000 + 30 000 = **34 000 €** |
| Crédit-bail : (540 × 60) + 800 | = **33 200 €** |

Le crédit-bail est **800 € moins cher** mais vous êtes propriétaire un mois plus tard et l'entreprise n'a pas le véhicule en garantie au bilan.

---

## 2. Les régimes d'imposition

### 2.1 Impôt sur le Revenu (IR)

Concerne les **EI**, **EURL**, **SARL de famille ayant opté**, micro-entreprises.

- Le bénéfice s'ajoute aux autres revenus du foyer.
- Imposé au **barème progressif** (0 % / 11 % / 30 % / 41 % / 45 %).
- Pas de séparation entre patrimoine pro et perso (sauf EI depuis 2022).

**À retenir :** simple, mais attention à l'effet seuil — passer de 11 % à 30 % d'un coup.

### 2.2 Impôt sur les Sociétés (IS)

Concerne les **SARL**, **SAS**, **SASU** par défaut.

| Tranche | Taux |
|---|---|
| 0 à 42 500 € de bénéfice | **15 %** (taux réduit PME) |
| Au-delà | **25 %** |

Conditions du taux réduit : CA HT < 10 M€ et capital détenu à 75 % par des personnes physiques.

**Avantage :** faible si bénéfice modéré. Permet de **piloter sa rémunération** (salaire + dividendes) pour optimiser.

### 2.3 Tableau de choix simplifié

| Situation | Régime conseillé |
|---|---|
| Activité solo, CA < 30 k€ | Micro-EI (IR) |
| Activité solo, CA 30-80 k€ | EI (IR ou option IS) |
| Activité familiale, CA 80-200 k€ | SARL (IS) |
| Croissance, plusieurs associés | SAS / SASU (IS) |

---

## 3. La TVA

### 3.1 Principe

La TVA est **collectée** par l'entreprise sur ses ventes et **déduite** sur ses achats. La différence est reversée à l'État.

> **TVA à payer = TVA collectée − TVA déductible**

### 3.2 Taux applicables au transport (2026)

| Activité | Taux |
|---|---|
| Transport de marchandises (national) | **20 %** |
| Transport de marchandises intracom. | **0 %** (autoliquidation client) |
| Transport de personnes voyageurs | **10 %** |

### 3.3 La règle de récupération sur véhicules

C'est le **piège classique** d'examen :

| Type de véhicule | TVA récupérable ? |
|---|---|
| Voiture particulière (VP) | **NON** (sauf revente, taxis, auto-écoles, ambulances) |
| Véhicule utilitaire (VUL) — 2 places | **OUI** intégralement |
| Camion / poids lourd | **OUI** intégralement |
| Carburant gazole sur VUL | **OUI 100 %** |
| Carburant gazole sur VP | **OUI 80 %** |
| Carburant essence | **OUI 80 %** (transport) |

**Règle métier :** acheter une 5008 pour faire de la livraison ⇒ **0 € de TVA récupérée**. Acheter un Trafic 2 places ⇒ TVA pleinement récupérée. Différence : 6 000 € sur un véhicule à 30 000 € HT.

### 3.4 Régimes de déclaration

| Régime | Seuil 2026 | Périodicité |
|---|---|---|
| Franchise en base | < 91 900 € (vente) / 36 800 € (services) | Pas de TVA |
| Réel simplifié | 91 900 à 840 000 € | Annuelle + 2 acomptes |
| Réel normal | > 840 000 € | Mensuelle ou trimestrielle |

---

## 4. Les autres taxes sectorielles

### 4.1 Taxe sur les véhicules de société (TVS) — supprimée 2022, remplacée par 2 taxes

- **Taxe annuelle sur les émissions de CO₂**
- **Taxe annuelle sur l'ancienneté du véhicule** (anciens carburants polluants)

Tarifs : entre quelques dizaines et quelques milliers d'euros par véhicule et par an.

### 4.2 Contribution Économique Territoriale (CET)

Remplaçante de la taxe professionnelle. Composée de :
- **CFE** (Cotisation Foncière des Entreprises) — base : valeur locative locaux.
- **CVAE** (Cotisation sur la Valeur Ajoutée des Entreprises) — supprimée progressivement (zéro en 2027).

### 4.3 Taxe à l'essieu

Applicable aux PL > 12 t. Hors capacité 3,5 T : **non concerné** (mais à connaître).

### 4.4 Charges sociales

- **TNS (Travailleur Non Salarié)** — gérant majoritaire SARL, EI, EIRL : ~30-45 % du revenu.
- **Assimilé salarié** — gérant minoritaire SARL, président SAS/SASU : ~75-82 % du brut.

Tableau comparatif rémunération 50 000 € net :

| Statut | Revenu net | Charges sociales | Coût total entreprise |
|---|---|---|---|
| TNS (SARL maj. / EI) | 50 000 € | ~22 000 € | 72 000 € |
| Assimilé salarié (SAS) | 50 000 € | ~37 000 € | 87 000 € |

**Différence : 15 000 €/an** pour une même rémunération nette. Mais l'assimilé salarié a une meilleure couverture sociale.

---

## 5. Cas pratique d'examen

**Énoncé :** vous achetez un VUL Trafic 2 places à 28 000 € HT. Vous hésitez :
- **Option A** : SAS à l'IS, achat comptant. CA prévisionnel 200 000 € HT, marge nette avant impôt 30 000 €.
- **Option B** : EI à l'IR, achat à crédit (apport 4 000 €, mensualité 470 €/mois sur 60 mois). Même marge.

Calculez la trésorerie restante après 1 an et l'impôt à payer.

**Correction :**

| | Option A (SAS) | Option B (EI) |
|---|---|---|
| Sortie immédiate | 28 000 € HT (TVA récupérée 5 600 €) | 4 000 € |
| Mensualités an 1 | 0 € | 470 × 12 = 5 640 € |
| Total cash an 1 | 28 000 € net | 9 640 € |
| Impôt sur 30 000 € | IS 15 % = **4 500 €** | IR 30 % = **9 000 €** (tranche marg.) |
| Trésorerie 1 an | + 25 500 € | + 21 000 € |

**Lecture :** la SAS coûte plus cher en trésorerie au démarrage mais paie moins d'impôt. À long terme (5 ans), elle gagne. L'EI est moins risquée mais subit la progressivité IR.

---

## 6. Glossaire

- **Crédit-bail** : location avec option d'achat à terme, l'entreprise paie des loyers déductibles.
- **LOA** : location avec option d'achat, version "particuliers/TPE" du crédit-bail.
- **LLD** : location longue durée sans option d'achat.
- **IS** : Impôt sur les Sociétés. 15 % jusqu'à 42 500 €, puis 25 %.
- **IR** : Impôt sur le Revenu. Barème progressif.
- **TVA collectée** : TVA facturée aux clients.
- **TVA déductible** : TVA payée aux fournisseurs et récupérable.
- **CFE/CVAE** : composantes de la Contribution Économique Territoriale.
- **TNS** : Travailleur Non Salarié (gérant majoritaire SARL, EI, EIRL).

---

## 7. Synthèse opérationnelle

1. **5 modes de financement** : comptant, emprunt, crédit-bail, LOA, LLD.
2. **Crédit-bail = loyers déductibles + option d'achat** ; LLD = pas de propriété.
3. **IS** : 15 % jusqu'à 42 500 €, puis 25 %. **IR** : barème progressif 0-45 %.
4. **TVA transport marchandises = 20 %** ; **voyageurs = 10 %** ; **intracom = 0 %**.
5. **Récupération TVA véhicule** : OK pour VUL/PL, KO pour VP.
6. **Carburant gazole** récupérable 100 % sur VUL, 80 % sur VP.
7. **3 régimes TVA** : franchise / simplifié / normal selon CA.
8. **TNS vs assimilé salarié** : différence de 15 000 €/an pour 50 000 € net.

---

## 4. Corrections des mini-exercices du module

### Leçon 2 (coursier urbain)
- VA = 62 000 − 9 500 − 11 000 = **41 500 €**
- EBE = 41 500 − 7 000 = **34 500 €** (pas de salaire, TNS hors CR)
- Résultat exploitation = 34 500 − 3 500 = **31 000 €**
- Résultat avant impôt = 31 000 € (pas de charges financières)
- IS simulé 15 % = 4 650 €
- **Résultat net = 26 350 €**

### Leçon 3 (DSO + solvabilité)
- DSO = 48 000 / 240 000 × 365 = **73 jours** → trop long, hors LME, à relancer.
- Solvabilité = 35 000 / 145 000 = **24 %** → en dessous du seuil 30 %, fragile.

---

## 🎓 Ce que l'examinateur peut demander

- Calcul du coût total d'un emprunt vs crédit-bail.
- Comparaison IS (15 %) / IR sur un bénéfice donné.
- Récupération TVA selon type de véhicule (piège récurrent).
- Choix d'un régime TVA en fonction du CA.
- QR : « Pourquoi un transporteur achète plutôt en VUL qu'en VP ? »

---

## 📋 Mémo à imprimer

```
FINANCEMENT
  Achat comptant   : pas d'intérêts mais cash bloqué
  Emprunt          : intérêts déduct., garanties demandées
  Crédit-bail      : loyers déduct., option achat à terme
  LOA              : variante TPE/particulier
  LLD              : tout compris, jamais propriétaire

FISCALITÉ
  IR : barème 0/11/30/41/45 %  ─ EI, micro, EURL
  IS : 15 % ≤ 42 500 €, puis 25 %  ─ SARL, SAS, SASU

TVA TRANSPORT
  Marchandises FR   : 20 %
  Marchandises UE   : 0 % (autoliq.)
  Voyageurs FR      : 10 %

RÉCUP TVA
  VUL / PL          : 100 %
  VP                : 0 %
  Gazole VUL        : 100 %
  Gazole VP         : 80 %

CHARGES SOCIALES
  TNS               : ~30-45 % du revenu
  Assimilé salarié  : ~75-82 % du brut
```
$lessonD4$,
'Comparer les modes de financement véhicule, choisir entre IR et IS, maîtriser la TVA en transport et anticiper les taxes sectorielles — leviers d''optimisation à plusieurs milliers d''euros par an.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- BANQUE DE QUESTIONS — 48 QCM + 7 QR (schéma question_bank correct)
  -- =================================================================

  -- ===== LEÇON 1 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'Le coût de revient kilométrique (CRKM) est :',
   '[{"id":"a","label":"Le prix de vente facturé au client","is_correct":false},{"id":"b","label":"Le coût total annuel divisé par le kilométrage parcouru","is_correct":true},{"id":"c","label":"Le bénéfice par kilomètre","is_correct":false},{"id":"d","label":"Le coût de carburant uniquement","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-d','capa-3-5t','lecon-1','crkm'], 'mft-2026:moduleD:l1:q1', true,
   'Le CRKM = total des charges (fixes + variables) / km parcourus. C''est un coût, pas un prix.'),
  (v_formation, v_module, 'qcm', 'Parmi ces charges, laquelle est une charge VARIABLE ?',
   '[{"id":"a","label":"Le leasing du véhicule","is_correct":false},{"id":"b","label":"L''assurance annuelle","is_correct":false},{"id":"c","label":"Le carburant","is_correct":true},{"id":"d","label":"Les frais de comptable","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-d','capa-3-5t','lecon-1','charges'], 'mft-2026:moduleD:l1:q2', true,
   'Le carburant dépend des km parcourus → variable. Les autres sont fixes.'),
  (v_formation, v_module, 'qcm', 'Si le CRKM est de 0,90 €/km et qu''on souhaite une marge nette de 20 %, le prix de vente HT au km doit être :',
   '[{"id":"a","label":"1,08 €/km","is_correct":false},{"id":"b","label":"1,10 €/km","is_correct":false},{"id":"c","label":"1,12 €/km","is_correct":true},{"id":"d","label":"1,15 €/km","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-d','capa-3-5t','lecon-1','marge'], 'mft-2026:moduleD:l1:q3', true,
   'PV = CR / (1 − marge) = 0,90 / 0,80 = 1,125 €/km. Réponse arrondie : 1,12 €/km.'),
  (v_formation, v_module, 'qcm', 'Le seuil de rentabilité est :',
   '[{"id":"a","label":"Le CA minimum pour couvrir uniquement les charges variables","is_correct":false},{"id":"b","label":"Le CA à partir duquel l''entreprise commence à dégager du bénéfice","is_correct":true},{"id":"c","label":"Le bénéfice maximum atteignable","is_correct":false},{"id":"d","label":"Le CA équivalent à un mois de charges fixes","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-d','capa-3-5t','lecon-1','seuil'], 'mft-2026:moduleD:l1:q4', true,
   'Le seuil de rentabilité = niveau d''activité où Produits = Charges (résultat = 0).'),
  (v_formation, v_module, 'qcm', 'Charges fixes annuelles : 24 000 €. Marge sur coût variable unitaire : 0,40 €/km. Le seuil de rentabilité en km est :',
   '[{"id":"a","label":"40 000 km","is_correct":false},{"id":"b","label":"48 000 km","is_correct":false},{"id":"c","label":"60 000 km","is_correct":true},{"id":"d","label":"80 000 km","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-d','capa-3-5t','lecon-1','seuil'], 'mft-2026:moduleD:l1:q5', true,
   'Seuil km = Charges fixes / Marge unitaire = 24 000 / 0,40 = 60 000 km.'),
  (v_formation, v_module, 'qcm', 'Charges variables sur un VUL faisant 60 000 km/an : 16 800 €. Le coût variable au km est :',
   '[{"id":"a","label":"0,18 €/km","is_correct":false},{"id":"b","label":"0,22 €/km","is_correct":false},{"id":"c","label":"0,28 €/km","is_correct":true},{"id":"d","label":"0,30 €/km","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-d','capa-3-5t','lecon-1','charges'], 'mft-2026:moduleD:l1:q6', true,
   '16 800 / 60 000 = 0,28 €/km.'),
  (v_formation, v_module, 'qcm', 'Une entreprise vend à un prix INFÉRIEUR à son CRKM. Conséquence directe ?',
   '[{"id":"a","label":"Bénéfice maximisé","is_correct":false},{"id":"b","label":"Perte sur chaque kilomètre vendu","is_correct":true},{"id":"c","label":"Pas d''impact tant que la trésorerie est positive","is_correct":false},{"id":"d","label":"Augmentation du chiffre d''affaires nécessaire seulement","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-d','capa-3-5t','lecon-1','marge'], 'mft-2026:moduleD:l1:q7', true,
   'Vendre sous le coût de revient = perdre de l''argent à chaque vente.'),
  (v_formation, v_module, 'qcm', 'Les charges fixes restent constantes :',
   '[{"id":"a","label":"Quelle que soit l''activité, dans la limite d''une plage normale","is_correct":true},{"id":"b","label":"Uniquement si l''activité augmente","is_correct":false},{"id":"c","label":"Uniquement la première année","is_correct":false},{"id":"d","label":"Jamais","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-d','capa-3-5t','lecon-1','charges'], 'mft-2026:moduleD:l1:q8', true,
   'Charges fixes (loyer, leasing, assurance) indépendantes de l''activité dans une plage normale.'),
  (v_formation, v_module, 'qcm', 'Le taux de marge sur coût variable se calcule par :',
   '[{"id":"a","label":"(PV − CV) / PV","is_correct":true},{"id":"b","label":"(PV − CV) / CV","is_correct":false},{"id":"c","label":"CV / PV","is_correct":false},{"id":"d","label":"PV / CV","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-d','capa-3-5t','lecon-1','marge'], 'mft-2026:moduleD:l1:q9', true,
   'Taux de marge sur CV = (PV − CV) / PV.'),
  (v_formation, v_module, 'qcm', 'Une augmentation du carburant de 0,15 €/km à 0,18 €/km (sur 50 000 km/an) impacte le CRKM de :',
   '[{"id":"a","label":"+ 1 500 €","is_correct":false},{"id":"b","label":"+ 0,03 €/km","is_correct":false},{"id":"c","label":"Les deux propositions sont vraies","is_correct":true},{"id":"d","label":"Aucune des deux","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-d','capa-3-5t','lecon-1','carburant'], 'mft-2026:moduleD:l1:q10', true,
   '+0,03 €/km × 50 000 km = +1 500 €/an.'),
  (v_formation, v_module, 'qcm', 'Le CRKM diminue quand :',
   '[{"id":"a","label":"Le kilométrage parcouru augmente (charges fixes mieux réparties)","is_correct":true},{"id":"b","label":"Les charges variables augmentent","is_correct":false},{"id":"c","label":"On embauche un salarié","is_correct":false},{"id":"d","label":"On change de banque","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-d','capa-3-5t','lecon-1','crkm'], 'mft-2026:moduleD:l1:q11', true,
   'Effet d''échelle : si km augmente, charges fixes / km baissent.'),
  (v_formation, v_module, 'qcm', 'L''URSSAF du dirigeant TNS est typiquement classée comme :',
   '[{"id":"a","label":"Charge variable au km","is_correct":false},{"id":"b","label":"Charge fixe annuelle","is_correct":true},{"id":"c","label":"Pas une charge","is_correct":false},{"id":"d","label":"Charge exceptionnelle","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-d','capa-3-5t','lecon-1','charges'], 'mft-2026:moduleD:l1:q12', true,
   'Cotisations TNS assises sur le revenu, pas sur le kilométrage → fixe.');

  -- ===== LEÇON 2 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'Le bilan est :',
   '[{"id":"a","label":"Le film de l''année écoulée","is_correct":false},{"id":"b","label":"La photographie du patrimoine à un instant T","is_correct":true},{"id":"c","label":"Le prévisionnel des 12 prochains mois","is_correct":false},{"id":"d","label":"La déclaration d''impôt","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-d','capa-3-5t','lecon-2','bilan'], 'mft-2026:moduleD:l2:q1', true,
   'Bilan = photo. Compte de résultat = film.'),
  (v_formation, v_module, 'qcm', 'Total Actif = Total Passif. Cette égalité :',
   '[{"id":"a","label":"Est une coïncidence","is_correct":false},{"id":"b","label":"Est obligatoire (équilibre comptable)","is_correct":true},{"id":"c","label":"N''existe que dans les SARL","is_correct":false},{"id":"d","label":"Est facultative","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-d','capa-3-5t','lecon-2','bilan'], 'mft-2026:moduleD:l2:q2', true,
   'Tout actif a forcément été financé : identité comptable.'),
  (v_formation, v_module, 'qcm', 'Les capitaux propres comprennent :',
   '[{"id":"a","label":"Capital social, réserves, résultat","is_correct":true},{"id":"b","label":"Emprunts bancaires","is_correct":false},{"id":"c","label":"Dettes fournisseurs","is_correct":false},{"id":"d","label":"Stocks et créances","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-d','capa-3-5t','lecon-2','bilan'], 'mft-2026:moduleD:l2:q3', true,
   'Capitaux propres = ressources stables apportées par associés ou cumulées par l''activité.'),
  (v_formation, v_module, 'qcm', 'La VA (Valeur Ajoutée) se calcule :',
   '[{"id":"a","label":"CA − Achats consommés − Charges externes","is_correct":true},{"id":"b","label":"CA − Salaires","is_correct":false},{"id":"c","label":"CA − Total des charges","is_correct":false},{"id":"d","label":"CA × marge","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-d','capa-3-5t','lecon-2','sig'], 'mft-2026:moduleD:l2:q4', true,
   'VA = CA − consommations en provenance de tiers.'),
  (v_formation, v_module, 'qcm', 'L''EBE se calcule :',
   '[{"id":"a","label":"VA − Salaires − Charges sociales − Impôts/taxes (+ subv.)","is_correct":true},{"id":"b","label":"CA − Charges totales","is_correct":false},{"id":"c","label":"Résultat net + IS","is_correct":false},{"id":"d","label":"VA − Amortissements","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-d','capa-3-5t','lecon-2','sig'], 'mft-2026:moduleD:l2:q5', true,
   'EBE = performance opérationnelle pure.'),
  (v_formation, v_module, 'qcm', 'Une dotation aux amortissements est :',
   '[{"id":"a","label":"Une charge avec sortie d''argent","is_correct":false},{"id":"b","label":"Une charge sans sortie d''argent","is_correct":true},{"id":"c","label":"Un produit","is_correct":false},{"id":"d","label":"Une recette","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-d','capa-3-5t','lecon-2','amortissement'], 'mft-2026:moduleD:l2:q6', true,
   'L''amortissement constate l''usure comptable, mais aucun argent ne sort.'),
  (v_formation, v_module, 'qcm', 'Les créances clients figurent :',
   '[{"id":"a","label":"À l''actif circulant","is_correct":true},{"id":"b","label":"Au passif","is_correct":false},{"id":"c","label":"Aux capitaux propres","is_correct":false},{"id":"d","label":"Hors bilan","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-d','capa-3-5t','lecon-2','bilan'], 'mft-2026:moduleD:l2:q7', true,
   'Créances clients = ce que les clients vous doivent → actif circulant.'),
  (v_formation, v_module, 'qcm', 'CA = 200 000 €, achats = 30 000 €, charges externes = 25 000 €. La VA est :',
   '[{"id":"a","label":"170 000 €","is_correct":false},{"id":"b","label":"145 000 €","is_correct":true},{"id":"c","label":"155 000 €","is_correct":false},{"id":"d","label":"200 000 €","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-d','capa-3-5t','lecon-2','sig'], 'mft-2026:moduleD:l2:q8', true,
   '200 000 − 30 000 − 25 000 = 145 000 €.'),
  (v_formation, v_module, 'qcm', 'Le résultat net :',
   '[{"id":"a","label":"= Trésorerie disponible","is_correct":false},{"id":"b","label":"≠ Trésorerie disponible (différence par les décalages)","is_correct":true},{"id":"c","label":"Est toujours positif","is_correct":false},{"id":"d","label":"Est calculé avant impôt","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-d','capa-3-5t','lecon-2','tresorerie'], 'mft-2026:moduleD:l2:q9', true,
   'Bénéfice ≠ trésorerie : amortissements et créances créent les décalages.'),
  (v_formation, v_module, 'qcm', 'L''IS pour PME en France 2026 :',
   '[{"id":"a","label":"20 % sur tout","is_correct":false},{"id":"b","label":"15 % jusqu''à 42 500 € puis 25 %","is_correct":true},{"id":"c","label":"30 % uniformément","is_correct":false},{"id":"d","label":"10 % sur le CA","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-d','capa-3-5t','lecon-2','is'], 'mft-2026:moduleD:l2:q10', true,
   'Taux réduit IS PME = 15 % jusqu''à 42 500 €, puis 25 %.'),
  (v_formation, v_module, 'qcm', 'Le compte de résultat se découpe en :',
   '[{"id":"a","label":"2 zones : produits / charges","is_correct":false},{"id":"b","label":"3 zones : exploitation / financier / exceptionnel","is_correct":true},{"id":"c","label":"4 zones","is_correct":false},{"id":"d","label":"1 seule zone","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-d','capa-3-5t','lecon-2','cr'], 'mft-2026:moduleD:l2:q11', true,
   '3 zones : exploitation, financier, exceptionnel.'),
  (v_formation, v_module, 'qcm', 'SARL : capitaux propres = 8 000 €, résultat = − 12 000 €. Conséquence ?',
   '[{"id":"a","label":"Aucune, la perte est temporaire","is_correct":false},{"id":"b","label":"Capitaux propres devenus négatifs, AGE obligatoire pour régulariser","is_correct":true},{"id":"c","label":"Liquidation judiciaire automatique","is_correct":false},{"id":"d","label":"Augmentation de capital interdite","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-d','capa-3-5t','lecon-2','perte'], 'mft-2026:moduleD:l2:q12', true,
   'Capitaux propres < moitié capital social : AGE dans les 4 mois (art. L.223-42 C. com.).');

  -- ===== LEÇON 3 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'Le fonds de roulement (FR) se calcule :',
   '[{"id":"a","label":"Capitaux propres + Dettes LT − Immobilisations nettes","is_correct":true},{"id":"b","label":"CA − Charges","is_correct":false},{"id":"c","label":"Stocks + Créances − Fournisseurs","is_correct":false},{"id":"d","label":"Trésorerie de fin d''année","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-d','capa-3-5t','lecon-3','fr'], 'mft-2026:moduleD:l3:q1', true,
   'FR = Ressources stables − Emplois stables.'),
  (v_formation, v_module, 'qcm', 'Le BFR mesure :',
   '[{"id":"a","label":"Le besoin de financement du cycle d''exploitation","is_correct":true},{"id":"b","label":"Le résultat net","is_correct":false},{"id":"c","label":"Le coût total annuel","is_correct":false},{"id":"d","label":"La trésorerie disponible","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-d','capa-3-5t','lecon-3','bfr'], 'mft-2026:moduleD:l3:q2', true,
   'BFR = (Stocks + Créances) − Dettes d''exploitation.'),
  (v_formation, v_module, 'qcm', 'La trésorerie nette TN :',
   '[{"id":"a","label":"= FR + BFR","is_correct":false},{"id":"b","label":"= FR − BFR","is_correct":true},{"id":"c","label":"= Capitaux propres − Dettes","is_correct":false},{"id":"d","label":"= CA − Charges","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-d','capa-3-5t','lecon-3','tn'], 'mft-2026:moduleD:l3:q3', true,
   'TN = FR − BFR.'),
  (v_formation, v_module, 'qcm', 'Un FR négatif signifie :',
   '[{"id":"a","label":"L''entreprise est rentable","is_correct":false},{"id":"b","label":"On a financé du long terme avec du court terme (danger)","is_correct":true},{"id":"c","label":"Les capitaux propres sont supérieurs aux dettes","is_correct":false},{"id":"d","label":"Aucun impact","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-d','capa-3-5t','lecon-3','fr'], 'mft-2026:moduleD:l3:q4', true,
   'Ressources stables < emplois stables : danger structurel.'),
  (v_formation, v_module, 'qcm', 'Le DSO se calcule :',
   '[{"id":"a","label":"Créances clients / CA TTC × 365","is_correct":true},{"id":"b","label":"CA / 365","is_correct":false},{"id":"c","label":"CA TTC / Créances × 365","is_correct":false},{"id":"d","label":"Stocks / CA × 365","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-d','capa-3-5t','lecon-3','dso'], 'mft-2026:moduleD:l3:q5', true,
   'DSO = délai moyen d''encaissement.'),
  (v_formation, v_module, 'qcm', 'CA TTC = 360 000 €/an, créances clients = 60 000 €. DSO ≈ :',
   '[{"id":"a","label":"30 jours","is_correct":false},{"id":"b","label":"45 jours","is_correct":false},{"id":"c","label":"60 jours","is_correct":true},{"id":"d","label":"90 jours","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-d','capa-3-5t','lecon-3','dso'], 'mft-2026:moduleD:l3:q6', true,
   '60 000 / 360 000 × 365 ≈ 60,8 jours.'),
  (v_formation, v_module, 'qcm', 'Le ratio de solvabilité considéré comme "sain" est :',
   '[{"id":"a","label":"≥ 30 %","is_correct":true},{"id":"b","label":"≥ 10 %","is_correct":false},{"id":"c","label":"≥ 50 %","is_correct":false},{"id":"d","label":"≥ 5 %","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-d','capa-3-5t','lecon-3','solvabilite'], 'mft-2026:moduleD:l3:q7', true,
   '≥ 30 % = sain. < 20 % = risque élevé.'),
  (v_formation, v_module, 'qcm', 'La LME impose un délai client maximum entre professionnels de :',
   '[{"id":"a","label":"30 jours","is_correct":false},{"id":"b","label":"45 jours fin de mois ou 60 jours date facture","is_correct":true},{"id":"c","label":"90 jours","is_correct":false},{"id":"d","label":"Aucun","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-d','capa-3-5t','lecon-3','lme'], 'mft-2026:moduleD:l3:q8', true,
   'Loi LME : 60 jours date facture ou 45 jours fin de mois max.'),
  (v_formation, v_module, 'qcm', 'Une entreprise bénéficiaire peut-elle déposer le bilan ?',
   '[{"id":"a","label":"Non, jamais","is_correct":false},{"id":"b","label":"Oui, si la trésorerie ne suit pas (résultat ≠ cash)","is_correct":true},{"id":"c","label":"Oui mais uniquement la 1ère année","is_correct":false},{"id":"d","label":"Uniquement en cas de fraude","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-d','capa-3-5t','lecon-3','tresorerie'], 'mft-2026:moduleD:l3:q9', true,
   'Cessation de paiement = passif exigible > actif disponible. Indépendant du bénéfice.'),
  (v_formation, v_module, 'qcm', 'Le plan de trésorerie sert à :',
   '[{"id":"a","label":"Calculer l''impôt sur les sociétés","is_correct":false},{"id":"b","label":"Anticiper les mois tendus et négocier les financements","is_correct":true},{"id":"c","label":"Embaucher du personnel","is_correct":false},{"id":"d","label":"Décider du prix de vente","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-d','capa-3-5t','lecon-3','tresorerie'], 'mft-2026:moduleD:l3:q10', true,
   'Outil prévisionnel mensuel pour repérer 6 mois à l''avance les mois rouges.'),
  (v_formation, v_module, 'qcm', 'Le ratio de liquidité générale = :',
   '[{"id":"a","label":"Actif circulant / Dettes CT","is_correct":true},{"id":"b","label":"Capitaux propres / Total bilan","is_correct":false},{"id":"c","label":"CA / Dettes","is_correct":false},{"id":"d","label":"Trésorerie / CA","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-d','capa-3-5t','lecon-3','liquidite'], 'mft-2026:moduleD:l3:q11', true,
   '> 1,5 = confortable. < 1 = incapacité théorique.'),
  (v_formation, v_module, 'qcm', 'Le BFR d''un transporteur B2B représente typiquement :',
   '[{"id":"a","label":"1 jour de CA","is_correct":false},{"id":"b","label":"30 à 60 jours de CA","is_correct":true},{"id":"c","label":"1 an de CA","is_correct":false},{"id":"d","label":"0","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-d','capa-3-5t','lecon-3','bfr'], 'mft-2026:moduleD:l3:q12', true,
   'Délais clients longs − délais fournisseurs ⇒ BFR ≈ 30-60 jours de CA.');

  -- ===== LEÇON 4 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'Le crédit-bail (leasing) :',
   '[{"id":"a","label":"Vous rend immédiatement propriétaire","is_correct":false},{"id":"b","label":"Est une location avec option d''achat à terme","is_correct":true},{"id":"c","label":"N''est pas déductible","is_correct":false},{"id":"d","label":"Doit être mentionné comme dette au bilan","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-d','capa-3-5t','lecon-4','financement'], 'mft-2026:moduleD:l4:q1', true,
   'Loyers 100 % déductibles, hors bilan jusqu''à IFRS 16.'),
  (v_formation, v_module, 'qcm', 'La LLD (Location Longue Durée) :',
   '[{"id":"a","label":"Inclut une option d''achat","is_correct":false},{"id":"b","label":"Permet de devenir propriétaire à terme","is_correct":false},{"id":"c","label":"Ne donne JAMAIS la propriété","is_correct":true},{"id":"d","label":"Est interdite pour les transporteurs","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-d','capa-3-5t','lecon-4','financement'], 'mft-2026:moduleD:l4:q2', true,
   'Location pure 24-60 mois, sans option d''achat.'),
  (v_formation, v_module, 'qcm', 'Le taux de TVA en transport de marchandises national est :',
   '[{"id":"a","label":"5,5 %","is_correct":false},{"id":"b","label":"10 %","is_correct":false},{"id":"c","label":"20 %","is_correct":true},{"id":"d","label":"0 %","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-d','capa-3-5t','lecon-4','tva'], 'mft-2026:moduleD:l4:q3', true,
   'Marchandises national = 20 %. Voyageurs = 10 %. Intracom = 0 %.'),
  (v_formation, v_module, 'qcm', 'Récupération de la TVA sur l''achat d''une voiture particulière (VP) :',
   '[{"id":"a","label":"100 %","is_correct":false},{"id":"b","label":"50 %","is_correct":false},{"id":"c","label":"Pas de récupération possible","is_correct":true},{"id":"d","label":"80 %","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-d','capa-3-5t','lecon-4','tva'], 'mft-2026:moduleD:l4:q4', true,
   'TVA non récupérable sur VP. Sur VUL 2 places ou PL : 100 %.'),
  (v_formation, v_module, 'qcm', 'Récupération de la TVA sur le gazole consommé par un VUL :',
   '[{"id":"a","label":"100 %","is_correct":true},{"id":"b","label":"80 %","is_correct":false},{"id":"c","label":"50 %","is_correct":false},{"id":"d","label":"0 %","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-d','capa-3-5t','lecon-4','tva'], 'mft-2026:moduleD:l4:q5', true,
   'Gazole VUL/PL = 100 %. Gazole VP = 80 %.'),
  (v_formation, v_module, 'qcm', 'L''IS concerne par défaut :',
   '[{"id":"a","label":"Les EI","is_correct":false},{"id":"b","label":"Les SARL, SAS, SASU","is_correct":true},{"id":"c","label":"Les micro-entreprises","is_correct":false},{"id":"d","label":"Les associations","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-d','capa-3-5t','lecon-4','is'], 'mft-2026:moduleD:l4:q6', true,
   'IS par défaut : SARL, SAS, SASU, SA. IR par défaut : EI, EURL, micro.'),
  (v_formation, v_module, 'qcm', 'Régime de TVA "franchise en base" : seuil 2026 services :',
   '[{"id":"a","label":"10 000 €","is_correct":false},{"id":"b","label":"36 800 €","is_correct":true},{"id":"c","label":"91 900 €","is_correct":false},{"id":"d","label":"250 000 €","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-d','capa-3-5t','lecon-4','tva'], 'mft-2026:moduleD:l4:q7', true,
   'Franchise services = 36 800 € (vente : 91 900 €).'),
  (v_formation, v_module, 'qcm', 'TVA collectée 12 000 €. TVA déductible 4 500 €. TVA à payer :',
   '[{"id":"a","label":"7 500 €","is_correct":true},{"id":"b","label":"16 500 €","is_correct":false},{"id":"c","label":"12 000 €","is_correct":false},{"id":"d","label":"4 500 €","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-d','capa-3-5t','lecon-4','tva'], 'mft-2026:moduleD:l4:q8', true,
   '12 000 − 4 500 = 7 500 €.'),
  (v_formation, v_module, 'qcm', 'Charges sociales d''un gérant assimilé salarié vs TNS, à net égal :',
   '[{"id":"a","label":"Identiques","is_correct":false},{"id":"b","label":"Assimilé salarié coûte plus cher (~75-82 %)","is_correct":true},{"id":"c","label":"TNS coûte plus cher","is_correct":false},{"id":"d","label":"Aucune différence si SARL","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-d','capa-3-5t','lecon-4','social'], 'mft-2026:moduleD:l4:q9', true,
   'Assimilé ~75-82 % du brut. TNS ~30-45 % du revenu.'),
  (v_formation, v_module, 'qcm', 'Avantage principal du crédit-bail vs achat à crédit pour la trésorerie de démarrage :',
   '[{"id":"a","label":"Pas d''apport, pas d''hypothèque","is_correct":true},{"id":"b","label":"Coût total inférieur","is_correct":false},{"id":"c","label":"Propriété immédiate","is_correct":false},{"id":"d","label":"Aucun","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-d','capa-3-5t','lecon-4','financement'], 'mft-2026:moduleD:l4:q10', true,
   'Crédit-bail demande peu d''apport et n''entre pas dans le ratio d''endettement bancaire.'),
  (v_formation, v_module, 'qcm', 'Bénéfice imposable IS = 50 000 €. IS dû en France 2026 :',
   '[{"id":"a","label":"12 500 €","is_correct":false},{"id":"b","label":"6 375 € + 1 875 € = 8 250 €","is_correct":true},{"id":"c","label":"15 000 €","is_correct":false},{"id":"d","label":"7 500 €","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-d','capa-3-5t','lecon-4','is'], 'mft-2026:moduleD:l4:q11', true,
   '15 % × 42 500 = 6 375 €. 25 % × 7 500 = 1 875 €. Total = 8 250 €.'),
  (v_formation, v_module, 'qcm', 'Choix VUL plutôt que VP pour une PME de transport est dicté par :',
   '[{"id":"a","label":"Esthétique","is_correct":false},{"id":"b","label":"Récupération de TVA et capacité de chargement","is_correct":true},{"id":"c","label":"Aucune raison","is_correct":false},{"id":"d","label":"Rapidité","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-d','capa-3-5t','lecon-4','tva'], 'mft-2026:moduleD:l4:q12', true,
   '6 000 € de TVA récupérée + 100 % gazole sur VUL vs 0 € sur VP.');

  -- ===== 7 QR =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qr',
   'Définissez le coût de revient kilométrique (CRKM) et expliquez pourquoi un transporteur doit absolument le connaître avant de fixer ses tarifs.',
   NULL, 5, 'moyen', ARRAY['module-d','capa-3-5t','qr','crkm'], 'mft-2026:moduleD:qr1', true,
   'Réponse attendue : CRKM = (charges fixes + charges variables) / km parcourus. Sert à : (1) fixer un prix de vente supérieur, (2) refuser les clients trop mal payés, (3) anticiper l''impact d''une hausse du carburant, (4) calculer un seuil de rentabilité, (5) éviter de vendre à perte.'),
  (v_formation, v_module, 'qr',
   'Une entreprise a 30 000 € de charges fixes annuelles, 15 000 € de charges variables pour 50 000 km. Calculez le CRKM, puis le prix de vente pour une marge de 20 %.',
   NULL, 5, 'difficile', ARRAY['module-d','capa-3-5t','qr','crkm','calcul'], 'mft-2026:moduleD:qr2', true,
   'CRKM = (30 000 + 15 000) / 50 000 = 0,90 €/km. PV = CRKM / (1 − marge) = 0,90 / 0,80 = 1,125 €/km HT.'),
  (v_formation, v_module, 'qr',
   'Expliquez la différence entre le bilan et le compte de résultat, et donnez un exemple de poste typique de chacun.',
   NULL, 4, 'facile', ARRAY['module-d','capa-3-5t','qr','bilan'], 'mft-2026:moduleD:qr3', true,
   'Bilan = photographie du patrimoine à un instant T. Compte de résultat = film de l''activité. Bilan : véhicule à l''actif, emprunt au passif. CR : CA en produit, salaires en charges.'),
  (v_formation, v_module, 'qr',
   'Calculez la VA, l''EBE et le résultat d''exploitation : CA = 180 000 €, achats = 32 000 €, charges externes = 28 000 €, salaires + charges = 60 000 €, impôts/taxes = 1 500 €, dotations amortissements = 11 000 €.',
   NULL, 6, 'moyen', ARRAY['module-d','capa-3-5t','qr','sig','calcul'], 'mft-2026:moduleD:qr4', true,
   'VA = 180 000 − 32 000 − 28 000 = 120 000 €. EBE = 120 000 − 60 000 − 1 500 = 58 500 €. Résultat exploitation = 58 500 − 11 000 = 47 500 €.'),
  (v_formation, v_module, 'qr',
   'Une entreprise affiche un résultat net positif mais doit demander un délai de paiement à l''URSSAF. Comment expliquer ce paradoxe ? Citez 3 causes possibles.',
   NULL, 5, 'difficile', ARRAY['module-d','capa-3-5t','qr','tresorerie'], 'mft-2026:moduleD:qr5', true,
   'Bénéfice ≠ trésorerie. Causes : (1) DSO trop long, créances impayées, (2) BFR en hausse, (3) Investissements lourds, (4) Distributions de dividendes excessives, (5) Amortissements masquant cash positif.'),
  (v_formation, v_module, 'qr',
   'Calculez le FR, le BFR et la TN : capitaux propres 60 000, dettes LT 80 000, immobilisations nettes 110 000, stocks 5 000, créances 35 000, fournisseurs 18 000, dettes fiscales/sociales 12 000.',
   NULL, 6, 'difficile', ARRAY['module-d','capa-3-5t','qr','fr','bfr','calcul'], 'mft-2026:moduleD:qr6', true,
   'FR = (60 000 + 80 000) − 110 000 = 30 000 €. BFR = (5 000 + 35 000) − (18 000 + 12 000) = 10 000 €. TN = 30 000 − 10 000 = 20 000 €.'),
  (v_formation, v_module, 'qr',
   'Vous démarrez avec 8 000 € d''apport. Vous hésitez entre acheter un VUL 18 000 € HT comptant (puis emprunter 10 000 € de BFR), ou prendre le même VUL en crédit-bail 60 mois à 360 €/mois et garder vos 8 000 € en trésorerie. Argumentez.',
   NULL, 5, 'difficile', ARRAY['module-d','capa-3-5t','qr','financement','demarrage'], 'mft-2026:moduleD:qr7', true,
   'Crédit-bail préférable : (1) trésorerie préservée, (2) loyers déductibles, (3) pas d''apport ni hypothèque, (4) sortie possible. Inconvénient : coût total ≥ achat (3 600 € en plus sur 5 ans).'),

  -- ===== 18 QR supplémentaires (qr8 à qr25) — décision client mai 2026 =====
  -- L1 — CRKM et seuil de rentabilité (5 QR)
  (v_formation, v_module, 'qr',
   'Une entreprise a un CRKM de 0,95 €/km à 60 000 km/an. Un nouveau client lui propose 80 000 km/an à 0,88 €/km. Charges fixes 30 000 €, charges variables 0,30 €/km. Faut-il accepter ?',
   NULL, 6, 'difficile', ARRAY['module-d','capa-3-5t','qr','crkm','decision'], 'mft-2026:moduleD:qr8', true,
   'Calcul nouveau CRKM à 80 000 km : (30 000 + 0,30 × 80 000) / 80 000 = 54 000 / 80 000 = 0,675 €/km. Marge unitaire à 0,88 €/km : 0,88 - 0,675 = 0,205 €/km, soit 16 400 €/an de marge contre 0 actuellement (à 60 000 km × 0,95 = juste au seuil). DÉCISION : ACCEPTER, car la dilution des charges fixes par les volumes additionnels rend l''opération rentable. Vigilance : capacité opérationnelle (1 véhicule peut-il faire 80 000 km/an ?), conditions contractuelles (durée, indexation gazole).'),
  (v_formation, v_module, 'qr',
   'Charges fixes annuelles : 28 000 €. Charges variables : 0,32 €/km. Tarif client actuel : 0,95 €/km à 50 000 km. Le gazole augmente de 25 %, faisant passer les charges variables à 0,40 €/km. Calculez l''impact et la hausse tarifaire à demander pour conserver la même marge en €.',
   NULL, 7, 'difficile', ARRAY['module-d','capa-3-5t','qr','crkm','indexation','calcul'], 'mft-2026:moduleD:qr9', true,
   'Marge actuelle : (0,95 - 0,32) × 50 000 - 28 000 = 31 500 - 28 000 = 3 500 €. Nouvelles charges variables 0,40 €/km : pour conserver 3 500 € de marge, prix nécessaire = (28 000 + 3 500) / 50 000 + 0,40 = 0,63 + 0,40 = 1,03 €/km. Hausse tarifaire à demander : 1,03 - 0,95 = +0,08 €/km, soit +8,4 %. Mention contractuelle indispensable : clause d''indexation gazole CNR à insérer dans le contrat.'),
  (v_formation, v_module, 'qr',
   'Vous comparez 2 propositions clients : Client A — 40 000 km à 1,05 €/km en transport régulier (fidélité prévisible). Client B — 25 000 km à 1,30 €/km en transport spot (one-shot). Coût variable 0,35 €/km, charges fixes 22 000 €. Quel client choisir si vous ne pouvez en prendre qu''un ?',
   NULL, 6, 'difficile', ARRAY['module-d','capa-3-5t','qr','crkm','strategie'], 'mft-2026:moduleD:qr10', true,
   'Client A : marge unitaire 0,70 €/km × 40 000 km - 22 000 € = 28 000 - 22 000 = 6 000 € de marge. Client B : marge unitaire 0,95 €/km × 25 000 km - 22 000 € = 23 750 - 22 000 = 1 750 € de marge. CHOIX : Client A (3,4× plus rentable + récurrence + planification possible). Le tarif unitaire plus élevé de B ne compense pas le manque de volume à effet d''échelle.'),
  (v_formation, v_module, 'qr',
   'Sur un VUL faisant 60 000 km/an, vous identifiez 4 leviers d''économie potentiels. Estimez-en l''impact financier annuel : (a) écoconduite -10 % carburant ; (b) renégociation assurance -300 €/an ; (c) optimisation tournées -8 000 km/an ; (d) baisse péages via évitement.',
   NULL, 7, 'difficile', ARRAY['module-d','capa-3-5t','qr','crkm','optimisation','calcul'], 'mft-2026:moduleD:qr11', true,
   'Hypothèses : conso 8 L/100, gazole 1,80 €/L, péages 0,06 €/km. (a) Carburant initial : 60 000 × 8/100 × 1,80 = 8 640 € → -10 % = -864 €/an. (b) Assurance : -300 €/an. (c) -8 000 km : économie carburant 8 000 × 8/100 × 1,80 = 1 152 € + entretien 0,05 €/km × 8 000 = 400 € = 1 552 €/an. (d) Évitement péages 30 % × 60 000 × 0,06 = 1 080 €/an, mais -3 % vitesse moyenne = surcoût main-d''œuvre. ÉCONOMIE TOTALE : ≈ 3 700-3 900 €/an, soit environ 7 % du CRKM.'),
  (v_formation, v_module, 'qr',
   'Votre seuil de rentabilité actuel est à 38 000 km/an avec un CRKM de 0,92 €/km. Vous envisagez d''embaucher un 2e conducteur (charges fixes +35 000 €/an) pour exploiter 2 véhicules. Quel kilométrage total minimum doit-il assurer pour ne pas dégrader le résultat global ?',
   NULL, 6, 'difficile', ARRAY['module-d','capa-3-5t','qr','seuil','embauche','calcul'], 'mft-2026:moduleD:qr12', true,
   'Seuil actuel à 38 000 km × marge unitaire (par exemple 0,55 €/km à un prix de vente de 1,15 €/km vs CV 0,30 €/km, soit marge sur CV 0,85 € - non, je reprends). Marge unitaire approximée : (1,10 prix de vente - 0,30 CV) = 0,80 €/km. Pour absorber 35 000 € supplémentaires de charges fixes : 35 000 / 0,80 = 43 750 km/an supplémentaires minimum. Donc le 2e conducteur doit assurer au moins 44 000 km/an. Cible commerciale prudente : 50 000 km/an (marge de sécurité 14 %) avec engagement contractuel d''un client récurrent.'),

  -- L2 — Bilan, compte de résultat, SIG (4 QR)
  (v_formation, v_module, 'qr',
   'À partir des données suivantes, dressez un mini-bilan et concluez sur la santé financière : capital social 5 000, réserves 8 000, résultat exercice 4 500, emprunts LT 18 000, fournisseurs 4 000, dettes fisc/soc 12 000 ; immobilisations 35 000, stocks 1 000, créances clients 12 000, trésorerie 3 500.',
   NULL, 7, 'difficile', ARRAY['module-d','capa-3-5t','qr','bilan','calcul'], 'mft-2026:moduleD:qr13', true,
   'TOTAL ACTIF = 35 000 + 1 000 + 12 000 + 3 500 = 51 500 €. TOTAL PASSIF = (5 000 + 8 000 + 4 500) capitaux propres + 18 000 dettes LT + (4 000 + 12 000) dettes CT = 17 500 + 18 000 + 16 000 = 51 500 €. Équilibre OK. Analyse : capitaux propres 17 500 / total 51 500 = 34 % (sain, > 30 %). Trésorerie 3 500 € pour 12 000 € de créances en attente : tendue. Risque DSO si retard de paiement client. Vigilance recommandée.'),
  (v_formation, v_module, 'qr',
   'Un transporteur a un CA de 220 000 €, des achats consommés de 38 000 €, des charges externes de 32 000 €, des salaires + charges sociales de 78 000 €, des impôts et taxes de 2 100 €, et des dotations aux amortissements de 14 000 €. Calculez les 4 SIG principaux et donnez un diagnostic en 3 lignes.',
   NULL, 7, 'difficile', ARRAY['module-d','capa-3-5t','qr','sig','calcul','diagnostic'], 'mft-2026:moduleD:qr14', true,
   'VA = 220 000 - 38 000 - 32 000 = 150 000 €. EBE = 150 000 - 78 000 - 2 100 = 69 900 €. Résultat d''exploitation = 69 900 - 14 000 = 55 900 €. Résultat avant impôt ≈ 55 900 €. DIAGNOSTIC : taux de VA 68 % (excellent, moy. secteur 50-60 %), taux d''EBE 32 % (très bon, > 25 %), résultat exploitation 25 % du CA (excellent). Entreprise très saine. Marge confortable pour absorber un choc carburant ou une baisse de volume de -10 %.'),
  (v_formation, v_module, 'qr',
   'Une SARL transport présente : résultat net 25 000 €, dotations amortissements 18 000 €, augmentation des créances clients +12 000 €, augmentation des dettes fournisseurs +5 000 €, investissement véhicule -28 000 €, remboursement emprunt -8 000 €. Calculez la variation de trésorerie de l''exercice et expliquez.',
   NULL, 7, 'difficile', ARRAY['module-d','capa-3-5t','qr','tresorerie','flux','calcul'], 'mft-2026:moduleD:qr15', true,
   'Capacité d''autofinancement (CAF) ≈ Résultat net + Dotations = 25 000 + 18 000 = 43 000 €. Variation BFR = +12 000 (créances) - 5 000 (fournisseurs) = +7 000 € (augmentation = besoin de cash). Flux d''exploitation = 43 000 - 7 000 = 36 000 €. Flux d''investissement = -28 000 €. Flux de financement = -8 000 €. VARIATION DE TRÉSORERIE = 36 000 - 28 000 - 8 000 = 0 €. La trésorerie n''a pas bougé malgré 25 000 € de bénéfice : tout a été absorbé par l''investissement et la croissance du BFR. Cas typique de croissance auto-financée.'),
  (v_formation, v_module, 'qr',
   'Comparez 2 entreprises de transport sur ces données et identifiez la plus saine : Entreprise X — CA 300 000, EBE 45 000, résultat net 12 000, capitaux propres 60 000, total bilan 200 000. Entreprise Y — CA 280 000, EBE 70 000, résultat net 28 000, capitaux propres 25 000, total bilan 180 000.',
   NULL, 6, 'difficile', ARRAY['module-d','capa-3-5t','qr','sig','ratios','comparaison'], 'mft-2026:moduleD:qr16', true,
   'Entreprise X : taux EBE 15 % du CA, résultat net 4 % du CA, solvabilité 60/200 = 30 % (correct). Entreprise Y : taux EBE 25 % du CA (très bon), résultat net 10 % du CA (excellent), solvabilité 25/180 = 14 % (faible). VERDICT : Y est plus rentable EXPLOITATION (X gagne moins en métier) mais X est plus SOLIDE structurellement (meilleurs fonds propres, moins de risque). À court terme, Y génère plus de cash. À long terme, X résiste mieux à un choc. La meilleure entreprise dépend de l''horizon : Y pour la rentabilité immédiate, X pour la pérennité.'),

  -- L3 — Santé financière, BFR, trésorerie (5 QR)
  (v_formation, v_module, 'qr',
   'Une entreprise transport a un CA TTC de 360 000 €/an, créances clients 75 000 €, dettes fournisseurs 22 000 €, achats TTC 95 000 €. Calculez le DSO et le DPO, puis le besoin de financement induit par cet écart.',
   NULL, 7, 'difficile', ARRAY['module-d','capa-3-5t','qr','dso','dpo','calcul'], 'mft-2026:moduleD:qr17', true,
   'DSO = 75 000 / 360 000 × 365 = 76 jours. DPO = 22 000 / 95 000 × 365 = 84 jours. Écart : DPO - DSO = +8 jours. Surprenant : les fournisseurs financent l''entreprise plus que les clients ne la pénalisent. Mais le CA quotidien (360 000 / 365 = 986 €) est bien plus élevé que les achats quotidiens (95 000 / 365 = 260 €). Donc en EUROS, le besoin de financement clients (76 j × 986 €) = 75 000 € est très supérieur aux ressources fournisseurs (84 j × 260 €) = 22 000 €. NET : 53 000 € de besoin de financement à porter en trésorerie ou en concours bancaire.'),
  (v_formation, v_module, 'qr',
   'Vos chiffres de l''année : CA 250 000 €, EBE 35 000 €, charges financières 4 200 €, IS 4 000 €, dotations amortissements 12 000 €, augmentation BFR +18 000 €, investissements -22 000 €, nouvel emprunt +30 000 €, remboursements -10 000 €, dividendes -5 000 €. Construisez le tableau de flux de trésorerie et concluez.',
   NULL, 7, 'difficile', ARRAY['module-d','capa-3-5t','qr','flux','tresorerie','calcul'], 'mft-2026:moduleD:qr18', true,
   'CAF ≈ Résultat net + Dotations = (35 000 - 4 200 - 4 000) + 12 000 = 26 800 + 12 000 = 38 800 €. Flux exploitation = 38 800 - 18 000 = 20 800 €. Flux investissement = -22 000 €. Flux financement = +30 000 - 10 000 - 5 000 = +15 000 €. VARIATION TRÉSORERIE = 20 800 - 22 000 + 15 000 = +13 800 €. CONCLUSION : la trésorerie augmente de 13 800 €, mais cette progression est artificielle (financée par le nouvel emprunt). Sans cet emprunt, la trésorerie aurait baissé de 16 200 €. Vigilance : l''entreprise vit en partie sur l''endettement.'),
  (v_formation, v_module, 'qr',
   'Une entreprise affiche : capitaux propres 45 000, dettes financières 65 000, dettes exploitation 28 000, total bilan 138 000. Calculez les 3 ratios financiers clés, puis recommandez une stratégie d''amélioration sur 24 mois.',
   NULL, 7, 'difficile', ARRAY['module-d','capa-3-5t','qr','ratios','strategie','calcul'], 'mft-2026:moduleD:qr19', true,
   'Solvabilité = 45/138 = 32,6 % (correct, juste au-dessus du seuil 30 %). Autonomie financière = 45/65 = 0,69 (faible, < 1 → dépendance bancaire). Endettement net = 65/45 = 1,44 (élevé). STRATÉGIE 24 MOIS : (1) constituer une réserve via mise en réserve obligatoire de 50 % du résultat annuel pendant 2 ans ; (2) éviter de nouveaux emprunts long terme et privilégier le crédit-bail pour les véhicules ; (3) à 24 mois, viser solvabilité ≥ 40 % et autonomie financière ≥ 1. Bonus : ouvrir le capital à un investisseur transport (Bpifrance, business angels) si croissance forte envisagée.'),
  (v_formation, v_module, 'qr',
   'Construisez un plan de trésorerie prévisionnel sur 3 mois (janv-mars) à partir de : CA mensuel 22 000 € encaissé à 60 j, achats mensuels 6 500 € payés à 30 j, salaires 7 500 €/mois, URSSAF trimestrielle 9 000 € en janvier, leasing 1 800 €/mois, autres charges 2 200 €/mois. Solde initial 12 000 €.',
   NULL, 7, 'difficile', ARRAY['module-d','capa-3-5t','qr','plan-tresorerie','calcul'], 'mft-2026:moduleD:qr20', true,
   'Janvier : entrées 0 (encaissements à 60 j, donc CA novembre encaissé en janvier). Sorties : achats nov payés en janvier 6 500 + salaires 7 500 + URSSAF 9 000 + leasing 1 800 + autres 2 200 = 27 000. Solde fin janvier = 12 000 - 27 000 = -15 000 €. ALERTE découvert. Février : encaissement CA décembre 22 000, sorties 6 500 + 7 500 + 1 800 + 2 200 = 18 000. Solde = -15 000 + 22 000 - 18 000 = -11 000 €. Mars : encaissement CA janvier 22 000, sorties idem 18 000. Solde = -11 000 + 22 000 - 18 000 = -7 000 €. CONCLUSION : besoin de découvert autorisé d''au moins 18 000 € sur Q1, à négocier dès décembre avec la banque. Solution structurelle : exiger un acompte de 30 % à la commande des nouveaux clients pour limiter le DSO.'),
  (v_formation, v_module, 'qr',
   'Une entreprise transport est cliente d''un grand donneur d''ordre qui paie à 90 jours. Le DO représente 60 % du CA (180 000 € sur 300 000 € total). Vous voulez réduire ce risque sans perdre le client. Listez 4 actions concrètes avec leur impact estimé.',
   NULL, 6, 'difficile', ARRAY['module-d','capa-3-5t','qr','tresorerie','strategie'], 'mft-2026:moduleD:qr21', true,
   '(1) Affacturage sur ce client : cession des factures à un factor (Bibby, Eurofactor) → cash en 48h, coût 1,5-2 % du CA = 2 700-3 600 €/an. (2) Renégociation contractuelle : passer le DO à 60 jours (LME applicable, exiger pénalités de retard) → libère 30 j × 500 €/j = 15 000 € de BFR. (3) Diversification commerciale : viser 30 % de parts de ce client sous 18 mois en captant 3-4 nouveaux clients de taille moyenne. (4) Garantie de paiement via assurance-crédit (Coface, Atradius) : prime 0,3-0,5 % du CA assuré = 600-900 €/an. PRIORITÉ : combiner (1) court terme + (3) long terme.'),

  -- L4 — Financement et fiscalité (4 QR)
  (v_formation, v_module, 'qr',
   'Vous voulez financer un VUL neuf 28 000 € HT. Comparez l''emprunt bancaire (5 ans à 4,5 %, apport 4 000 €) et le crédit-bail (60 mois à 540 €/mois + option 800 €). Calculez le coût total HT et concluez en fonction de votre besoin.',
   NULL, 7, 'difficile', ARRAY['module-d','capa-3-5t','qr','financement','comparaison','calcul'], 'mft-2026:moduleD:qr22', true,
   'EMPRUNT : capital emprunté = 28 000 - 4 000 = 24 000 €. Mensualité ≈ 24 000 × 0,045/12 / (1 - (1+0,045/12)^-60) ≈ 447 €/mois. Coût total = 4 000 (apport) + 447 × 60 = 4 000 + 26 820 = 30 820 €. CRÉDIT-BAIL : (540 × 60) + 800 = 32 400 + 800 = 33 200 €. ÉCART : crédit-bail +2 380 € (+7,7 %). DÉCISION : si trésorerie tendue (démarrage, croissance) → CRÉDIT-BAIL (pas d''apport, loyers déductibles à 100 %). Si trésorerie confortable → EMPRUNT (moins cher, propriété immédiate, valeur à la revente). Le crédit-bail compense souvent son surcoût par la déductibilité fiscale et la flexibilité de sortie.'),
  (v_formation, v_module, 'qr',
   'Une SARL réalise 35 000 € de bénéfice. Calculez l''IS dû (régime PME). Comparez avec un même bénéfice en EI à l''IR pour un dirigeant marié sans enfant (revenu conjoint 25 000 €). Lequel est le plus avantageux fiscalement ?',
   NULL, 7, 'difficile', ARRAY['module-d','capa-3-5t','qr','is','ir','comparaison','calcul'], 'mft-2026:moduleD:qr23', true,
   'SARL à l''IS : 35 000 € < 42 500 € → taux réduit 15 % = 5 250 €. Ensuite distribution de dividendes au dirigeant : prélèvement forfaitaire unique (PFU/flat tax) 30 % sur (35 000 - 5 250) = 29 750 → 8 925 €. Total fiscalité = 14 175 €. EI à l''IR : revenu fiscal foyer = 25 000 + 35 000 = 60 000 €. Quotient familial 2 parts : 30 000 € par part. Tranche 30 % au-delà de 28 797 €. IR ≈ 0 % × 11 295 + 11 % × (28 797-11 295) + 30 % × (30 000-28 797) = 0 + 1 925 + 360 = 2 285 € × 2 parts = 4 570 €. + cotisations TNS ~ 25 % du bénéfice net (déjà payées avant IR). VERDICT : EI à l''IR plus avantageux fiscalement à ce niveau de revenu (4 570 € vs 14 175 €), MAIS la SARL permet de se rémunérer en salaire (charges déductibles, protection sociale) et de moduler la distribution.'),
  (v_formation, v_module, 'qr',
   'Vous achetez 2 véhicules : (a) une Renault Clio (VP) à 18 000 € HT pour les déplacements commerciaux ; (b) un Trafic 2 places (VUL) à 28 000 € HT pour les livraisons. Quelle TVA récupérez-vous sur chaque véhicule et sur leur gazole annuel respectif (consommation 1 800 € HT/an chaque) ? Total TVA récupérée an 1.',
   NULL, 7, 'difficile', ARRAY['module-d','capa-3-5t','qr','tva','recuperation','calcul'], 'mft-2026:moduleD:qr24', true,
   'VÉHICULE (a) Clio VP : TVA achat NON récupérable (sauf cas exceptionnels : taxis, ambulances, auto-écoles). TVA gazole VP : 80 % récupérable. TVA gazole an 1 = 1 800 × 20 % × 80 % = 288 €. VÉHICULE (b) Trafic VUL 2 places : TVA achat 100 % récupérable = 28 000 × 20 % = 5 600 €. TVA gazole VUL : 100 % récupérable = 1 800 × 20 % = 360 €. TOTAL TVA RÉCUPÉRÉE AN 1 : 0 + 288 + 5 600 + 360 = 6 248 €. LEÇON : choisir un VUL plutôt qu''une VP fait gagner 5 600 € de TVA sur l''achat + 72 €/an sur le gazole. Différence majeure pour une PME en démarrage.'),
  (v_formation, v_module, 'qr',
   'Une PME transport a un CA de 95 000 € HT services. Elle est actuellement en franchise en base de TVA (seuil services 36 800 €) — non, elle dépasse le seuil. Présentez le passage obligatoire au régime réel simplifié : démarches, périodicité de déclaration, impact sur la trésorerie.',
   NULL, 6, 'difficile', ARRAY['module-d','capa-3-5t','qr','tva','regime','strategie'], 'mft-2026:moduleD:qr25', true,
   'CONSTAT : 95 000 € > 36 800 € (seuil services) → passage AUTOMATIQUE au régime réel simplifié dès dépassement. DÉMARCHES : (1) déclaration au SIE dans le mois de dépassement, (2) facturation TVA collectée 20 % sur les nouvelles factures, (3) récupération TVA déductible sur les achats (avantage). PÉRIODICITÉ : 2 acomptes provisionnels (juillet et décembre) calculés sur base de l''année N-1, déclaration annuelle CA12 en mai. IMPACT TRÉSORERIE : (a) hausse apparente du CA TTC visible côté client (+ 20 %), (b) récupération TVA sur achats améliore le résultat de 1 500-3 000 €/an, (c) acompte de juillet = ressource à provisionner. STRATÉGIE : prévoir une augmentation tarifaire HT légère (+ 3-5 %) pour absorber psychologiquement le choc client tout en gardant la compétitivité.');

  -- =================================================================
  -- QUIZZES (4 entraînement + 1 examen blanc)
  -- =================================================================

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'CRKM et seuil de rentabilité — Quiz',
          'Quiz d''entraînement (12 questions) sur le CRKM, charges fixes/variables, seuil de rentabilité et prix de vente.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026:moduleD:l1:%';

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Bilan et compte de résultat — Quiz',
          'Quiz d''entraînement (12 questions) sur le bilan, le compte de résultat et les soldes intermédiaires de gestion (VA, EBE).',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026:moduleD:l2:%';

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Santé financière — Quiz',
          'Quiz d''entraînement (12 questions) sur fonds de roulement, BFR, trésorerie nette, ratios financiers.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026:moduleD:l3:%';

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Financement et fiscalité — Quiz',
          'Quiz d''entraînement (12 questions) sur les modes de financement (crédit-bail, LLD), IR/IS, TVA et charges sociales.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026:moduleD:l4:%';

  -- Quiz 5 — Synthèse transversale calcul (12 QCM des 4 leçons, niveau avancé)
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Synthèse calculs financiers — Quiz',
          'Quiz d''entraînement transversal (12 questions) regroupant les calculs CRKM, SIG, BFR et coûts financiers — niveau avancé pour la préparation examen.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_5;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_5, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref IN (
       'mft-2026:moduleD:l1:q3','mft-2026:moduleD:l1:q5','mft-2026:moduleD:l1:q6',
       'mft-2026:moduleD:l2:q4','mft-2026:moduleD:l2:q5','mft-2026:moduleD:l2:q8',
       'mft-2026:moduleD:l3:q3','mft-2026:moduleD:l3:q5','mft-2026:moduleD:l3:q6',
       'mft-2026:moduleD:l4:q8','mft-2026:moduleD:l4:q11','mft-2026:moduleD:l4:q5'
     );

  -- Quiz 6 — Cas pratiques CRKM (QR L1 — calculs CRKM, marge, seuil)
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Cas pratiques CRKM et seuil de rentabilité — Quiz',
          'Quiz d''entraînement spécialisé : 6 cas pratiques rédigés (QR) sur le calcul de coût de revient kilométrique, le seuil de rentabilité et l''optimisation tarifaire.',
          'entrainement', NULL, 60)
  RETURNING id INTO v_quiz_6;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_6, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref IN (
       'mft-2026:moduleD:qr1','mft-2026:moduleD:qr2',
       'mft-2026:moduleD:qr8','mft-2026:moduleD:qr9',
       'mft-2026:moduleD:qr10','mft-2026:moduleD:qr11','mft-2026:moduleD:qr12'
     );

  -- Quiz 7 — Cas pratiques bilan, compte de résultat et SIG (QR L2)
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Cas pratiques bilan, compte de résultat, SIG — Quiz',
          'Quiz d''entraînement spécialisé : 5 cas pratiques rédigés (QR) sur la lecture d''un bilan, le compte de résultat et les soldes intermédiaires de gestion.',
          'entrainement', NULL, 60)
  RETURNING id INTO v_quiz_7;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_7, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref IN (
       'mft-2026:moduleD:qr3','mft-2026:moduleD:qr4',
       'mft-2026:moduleD:qr13','mft-2026:moduleD:qr14',
       'mft-2026:moduleD:qr15','mft-2026:moduleD:qr16'
     );

  -- Quiz 8 — Cas pratiques santé financière, BFR, financement (QR L3 + L4)
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Cas pratiques BFR, trésorerie, financement et fiscalité — Quiz',
          'Quiz d''entraînement spécialisé : 12 cas pratiques rédigés (QR) sur la santé financière, le BFR, la trésorerie, le choix d''un financement et les régimes fiscaux.',
          'entrainement', NULL, 60)
  RETURNING id INTO v_quiz_8;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_8, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref IN (
       'mft-2026:moduleD:qr5','mft-2026:moduleD:qr6','mft-2026:moduleD:qr7',
       'mft-2026:moduleD:qr17','mft-2026:moduleD:qr18','mft-2026:moduleD:qr19',
       'mft-2026:moduleD:qr20','mft-2026:moduleD:qr21',
       'mft-2026:moduleD:qr22','mft-2026:moduleD:qr23',
       'mft-2026:moduleD:qr24','mft-2026:moduleD:qr25'
     );

  -- Examen blanc — 13 QCM + 5 QR
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold, is_mock_exam)
  VALUES (v_module, 'Examen blanc — Module D Activité financière',
          'Examen blanc reproduisant les conditions de l''examen national : 13 QCM représentatifs des 4 leçons + 5 QR (dont CRKM), durée 60 min, seuil 50 %.',
          'examen', 3600, 50, true)
  RETURNING id INTO v_quiz_eb;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
    FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref IN (
       'mft-2026:moduleD:l1:q1','mft-2026:moduleD:l1:q3','mft-2026:moduleD:l1:q5','mft-2026:moduleD:l1:q7',
       'mft-2026:moduleD:l2:q2','mft-2026:moduleD:l2:q4','mft-2026:moduleD:l2:q9','mft-2026:moduleD:l2:q10',
       'mft-2026:moduleD:l3:q1','mft-2026:moduleD:l3:q5','mft-2026:moduleD:l3:q9',
       'mft-2026:moduleD:l4:q4','mft-2026:moduleD:l4:q11',
       'mft-2026:moduleD:qr1','mft-2026:moduleD:qr2','mft-2026:moduleD:qr3','mft-2026:moduleD:qr5','mft-2026:moduleD:qr7'
     );

  RAISE NOTICE '✓ Module D v3 dense importé : 4 leçons (CRKM, bilan/CR, santé fin., financ./fiscal.), 48 QCM, 25 QR, 9 quiz (8 entraînement + 1 examen blanc).';

END $module_d_v3$;

