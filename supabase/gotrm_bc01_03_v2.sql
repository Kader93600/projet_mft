-- =====================================================================
-- GOTRM (RNCP 40990) — BC01-03 : Cotation et offre commerciale
-- Composantes du prix, coût de revient, devis, indexation carburant.
-- =====================================================================

DO $bc01_03$
DECLARE
  v_formation uuid; v_bloc int; v_module uuid;
  v_lesson_1 uuid; v_lesson_2 uuid; v_lesson_3 uuid; v_lesson_4 uuid;
  v_quiz_1 uuid; v_quiz_2 uuid; v_quiz_3 uuid; v_quiz_4 uuid; v_quiz_eb uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc.'; END IF;

  DELETE FROM public.modules WHERE slug = 'gotrm-bc01-03-cotation-offre';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'BC01-03 — Élaborer une cotation et une offre commerciale',
    'gotrm-bc01-03-cotation-offre', v_bloc,
    'Construire un prix de transport rentable : décomposer les coûts (fixes/variables/structure), calculer un coût de revient kilométrique, structurer un devis, indexer le carburant et négocier sans perdre la marge.',
    'intermediaire', 200, 30
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 30, true) ON CONFLICT DO NOTHING;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-03:%';

  -- =================================================================
  -- LEÇON 1 — Composantes du prix de transport
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Les composantes du prix de transport',
    'gotrm-bc01-03-01-composantes-prix', 1, 50,
$lesson1$
# Les composantes du prix de transport

Un prix de transport bien construit repose sur une **décomposition rigoureuse** des coûts. Trop d'exploitants improvisent à partir d'un « prix marché » sans connaître leur seuil de rentabilité — résultat : ils livrent à perte sans le savoir.

> 🎯 **Objectifs de la leçon**
>
> - Distinguer **coûts fixes**, **coûts variables**, **coûts de structure**.
> - Identifier les principaux **postes de coût** d'un véhicule industriel.
> - Comprendre la notion de **kilomètre commercial vs kilomètre total**.
> - Appréhender l'impact des **taux de remplissage** sur le prix.

---

## 1. Les trois grandes familles de coûts

| Famille | Définition | Exemples |
|---|---|---|
| **Coûts fixes véhicule** | Existent même véhicule à l'arrêt | Amortissement, assurance, taxe à l'essieu, parking |
| **Coûts variables** | Proportionnels aux kilomètres parcourus | Carburant, pneumatiques, entretien, péages |
| **Coûts de structure** | Frais généraux de l'entreprise | Direction, exploitation, comptabilité, locaux, IT |
| **Coûts personnel** | Salaire conducteur + charges | Salaire brut, cotisations, frais de route |

> 📌 **Règle d'or**
>
> Un prix qui ne couvre que les coûts variables est **toxique à terme** : l'entreprise consomme sa structure et son capital. Le prix plancher doit couvrir **fixes + variables + structure + une marge**.

---

## 2. Les postes de coût détaillés

### 2.1 Amortissement du véhicule

Un porteur 19 t neuf coûte environ **95 000 € HT**. Sur **6 ans** d'amortissement linéaire à **120 000 km/an** :

| Élément | Calcul | Montant |
|---|---|---|
| Coût d'achat | — | 95 000 € |
| Valeur résiduelle | 25 % | 23 750 € |
| Base amortissable | 95 000 − 23 750 | 71 250 € |
| Amortissement annuel | 71 250 / 6 | 11 875 €/an |
| Coût kilométrique | 11 875 / 120 000 | **0,099 €/km** |

### 2.2 Carburant

Pour un porteur 19 t en cycle régional :

| Donnée | Valeur |
|---|---|
| Consommation moyenne | 28 L / 100 km |
| Prix gazole HT (moyenne 2026) | 1,42 €/L |
| Coût carburant | 28 × 1,42 / 100 = **0,398 €/km** |

> ⚠️ Le carburant représente **25 à 35 %** du coût total kilométrique. C'est le poste le plus volatil — d'où l'importance de l'**indexation carburant** (vue en leçon 4).

### 2.3 Conducteur

Pour un conducteur PL en CDI, coefficient 138M :

| Élément | Mensuel | Annuel |
|---|---|---|
| Salaire brut de base | 2 250 € | 27 000 € |
| Heures supplémentaires (15 %) | 340 € | 4 080 € |
| Indemnités de repas | 280 € | 3 360 € |
| Charges patronales (~42 %) | 1 080 € | 12 960 € |
| **Total coût employeur** | **3 950 €** | **47 400 €** |

Pour 1 850 heures de conduite annuelles à 65 km/h moyen :
- Coût horaire : 47 400 / 1 850 = **25,6 €/h**
- Coût kilométrique : 25,6 / 65 = **0,394 €/km**

### 2.4 Entretien, pneumatiques, péages

| Poste | Coût kilométrique indicatif (porteur 19 t) |
|---|---|
| Entretien et réparations | 0,065 €/km |
| Pneumatiques (durée 110 000 km) | 0,030 €/km |
| Péages (selon zones) | 0,070 €/km |
| Lubrifiants, AdBlue | 0,020 €/km |

### 2.5 Coûts fixes véhicule (hors amortissement)

| Poste | Annuel | Coût km (120 000 km) |
|---|---|---|
| Assurance véhicule | 4 200 € | 0,035 €/km |
| Taxe à l'essieu | 580 € | 0,005 €/km |
| Visite technique, divers | 220 € | 0,002 €/km |
| **Total** | **5 000 €** | **0,042 €/km** |

### 2.6 Frais de structure

Sur une PME de 20 véhicules avec 250 000 € de frais de structure annuels :
- Par véhicule : 12 500 € / an
- Coût kilométrique : 12 500 / 120 000 = **0,104 €/km**

---

## 3. Synthèse — coût de revient kilométrique

Pour un porteur 19 t en exploitation régionale :

| Poste | €/km |
|---|---|
| Amortissement | 0,099 |
| Carburant | 0,398 |
| Conducteur | 0,394 |
| Entretien + pneus + péages + AdBlue | 0,185 |
| Coûts fixes véhicule | 0,042 |
| Structure | 0,104 |
| **Coût de revient total** | **1,222 €/km** |

> 💡 **Lecture professionnelle**
>
> Pour ce véhicule, **toute mission tarifée en dessous de 1,22 €/km commerciaux est déficitaire**. L'objectif d'un exploitant performant est de viser **1,40 à 1,55 €/km** selon le marché, soit une **marge brute de 15 à 25 %**.

---

## 4. Kilomètre commercial vs kilomètre total

C'est une distinction **fondamentale** souvent ignorée par les débutants.

| Notion | Définition |
|---|---|
| **Kilomètre total** | Tous les km parcourus (chargé + à vide + repositionnement) |
| **Kilomètre commercial** | Km parcourus chargé OU facturés au client |

> 📌 **Exemple chiffré**
>
> Un véhicule fait Lyon → Marseille (320 km chargés) puis Marseille → Lyon à vide (320 km).
> - Km totaux : 640 km
> - Km commerciaux (facturés) : 320 km
> - **Tous les coûts des 640 km doivent être absorbés par le prix des 320 km commerciaux.**

**Conséquence directe** : si votre coût km total est 1,22 €/km mais que votre **taux de retour à vide** est de 50 %, votre coût km commercial est **2,44 €/km** !

---

> ✅ **À retenir**
>
> - Les coûts se décomposent en **fixes**, **variables**, **structure** et **personnel**.
> - Un prix qui ne couvre pas la structure est **mortel à terme**.
> - Le poste **carburant** est le plus volatil et exige une **indexation contractuelle**.
> - Le **taux de retour à vide** double mécaniquement le coût km commercial.
$lesson1$,
'Décomposer les coûts (fixes, variables, structure, personnel) et comprendre l''écart entre kilomètre total et kilomètre commercial.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Calcul coût de revient et marge
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Calculer un coût de revient et fixer une marge',
    'gotrm-bc01-03-02-cout-revient-marge', 2, 50,
$lesson2$
# Calculer un coût de revient et fixer une marge

Savoir **calculer rapidement** un coût de revient sur un transport donné, puis **ajouter la marge commerciale** : c'est le geste quotidien de l'exploitant qui prend une demande au téléphone.

> 🎯 **Objectifs de la leçon**
>
> - Calculer un **coût de revient au transport** (CRT).
> - Maîtriser la formule du **coût km commercial**.
> - Ajouter une **marge commerciale** cohérente avec le marché.
> - Construire un **prix au km, à la palette, au m³ ou à la tonne**.

---

## 1. La méthode CRT (Coût de Revient Transport)

Pour un trajet donné, on calcule :

```
CRT = (Km totaux × Coût km variable)
    + (Heures totales × Coût horaire fixe)
    + Coût des opérations annexes (chargement, péages spécifiques…)
```

> 📌 **Exemple — Mission Bordeaux → Toulouse (porteur 19 t)**
>
> | Élément | Détail | Calcul |
> |---|---|---|
> | Trajet aller | 250 km chargés | — |
> | Retour | 250 km à vide | — |
> | Km totaux | 500 km | — |
> | Heures totales | 8 h (4 h conduite + 2 h chargement/déchargement + 2 h pause/attente) | — |
> | Coût km variable (carburant + entretien + pneus + péages) | 0,58 €/km | 500 × 0,58 = 290 € |
> | Coût horaire fixe (conducteur + amortissement + structure) | 32 €/h | 8 × 32 = 256 € |
> | **Coût de revient total** | — | **546 €** |
> | Coût €/km commercial | 546 / 250 | **2,18 €/km commercial** |

---

## 2. La marge commerciale

### 2.1 Marge brute vs marge nette

| Notion | Formule | Exemple à 600 € |
|---|---|---|
| **Marge brute** | (Prix − Coûts variables) / Prix | (600 − 290) / 600 = 51,7 % |
| **Marge nette** | (Prix − Coût total) / Prix | (600 − 546) / 600 = 9 % |

### 2.2 Taux de marge usuels

| Type d'opérateur | Marge nette cible |
|---|---|
| Lot complet (TRM longue distance) | 4 à 8 % |
| Messagerie / express | 8 à 15 % |
| Distribution urbaine | 10 à 18 % |
| Transport spécifique (ADR, ATP, frigo) | 12 à 22 % |
| Affrètement (commissionnaire) | 4 à 7 % sur volume |

> ⚠️ Une **marge nette inférieure à 4 %** rend l'entreprise **fragile à tout incident** (panne, sinistre, hausse carburant). En dessous de 2 %, l'activité est en danger structurel.

---

## 3. Fixer un prix : la méthode commerciale

Trois approches coexistent :

### 3.1 Méthode coûts + marge (cost plus)

Prix = Coût de revient × (1 + taux de marge cible)

Pour la mission Bordeaux → Toulouse à 546 € de CRT, marge nette 10 % :
- Prix HT = 546 / (1 − 0,10) = **607 € HT**

### 3.2 Méthode prix marché

On observe le prix moyen sur la relation et on s'aligne :
- Bordeaux → Toulouse, porteur 19 t, marché 2026 : **580 à 620 €**.
- On positionne à 599 € HT (sous le seuil psychologique de 600 €).

### 3.3 Méthode valeur perçue

On facture le service rendu plutôt que le coût :
- Livraison J+1 garantie 8 h → +20 % vs prix marché
- Spécifique (rendez-vous obligatoire, hayon, gerbage interdit) → +10 à 15 %

---

## 4. Tarification au-delà du km : palette, m³, tonne

Selon le segment, on tarife différemment.

| Unité de tarification | Quand l'utiliser | Exemple |
|---|---|---|
| **Au km** | Lot complet, courtes/moyennes distances | 1,40 €/km |
| **Au forfait** | Mission ponctuelle ou affrètement | 599 € pour Bordeaux → Toulouse |
| **À la palette EUR (80×120)** | Messagerie, palettes complètes | 45 € la palette de 100 à 250 km |
| **Au m³** | Volumineux léger (mousse, isolant, mobilier) | 25 €/m³ |
| **À la tonne** | Denses (acier, ciment, granulats) | 35 €/t pour 50–150 km |
| **Au point de livraison** | Distribution multi-clients | 18 € le point en plus du km |

> 💡 **Règle pratique**
>
> Lorsqu'un client compare deux devis « 580 € » et « 47 €/palette × 12 = 564 € », l'unité de tarification **influence directement la perception** du prix. Un bon commercial choisit l'unité la plus avantageuse pour son entreprise compte tenu du chargement réel.

---

## 5. Le seuil de profitabilité (break-even)

C'est le **prix plancher** en dessous duquel l'entreprise perd de l'argent **sur cette mission**.

```
Seuil de profitabilité = Coût de revient total / Km commerciaux
```

Pour notre exemple : 546 / 250 = **2,18 €/km commercial**.

Mais attention : ce seuil suppose qu'on **récupère** tous les coûts fixes sur ce voyage. En pratique, on **lisse** sur l'année :

> 📌 **Lissage annuel**
>
> Si le véhicule fait 100 000 km commerciaux/an et que les coûts fixes annuels sont 80 000 €, la **part fixe par km commercial** est de 0,80 €. À cela on ajoute les coûts variables (~0,60 €/km) → **seuil de 1,40 €/km commercial**.

---

> ✅ **À retenir**
>
> - **CRT** = (km × coût variable) + (heures × coût horaire fixe) + opérations annexes.
> - Une **marge nette de 4 à 10 %** est nécessaire pour pérenniser l'entreprise.
> - L'**unité de tarification** (km, palette, tonne, point) influence la perception du prix.
> - Le **lissage annuel** des coûts fixes donne le seuil de profitabilité réaliste.
$lesson2$,
'Méthode CRT, marge brute/nette, prix au km/palette/tonne et calcul du seuil de profitabilité.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Structure du devis et CGT
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Rédiger un devis professionnel et opposer ses CGT',
    'gotrm-bc01-03-03-devis-cgt', 3, 40,
$lesson3$
# Rédiger un devis professionnel et opposer ses CGT

Un devis transport n'est pas une simple ligne de prix : c'est un **document juridique** qui engage les deux parties dès acceptation. Mal rédigé, il vous expose à des contestations et des pertes de marge.

> 🎯 **Objectifs de la leçon**
>
> - Identifier les **mentions obligatoires** d'un devis transport.
> - Comprendre l'opposabilité des **CGT** (Conditions Générales de Transport).
> - Rédiger un devis **clair, complet et défendable**.
> - Anticiper les **pièges** (forfait illimité, exclusions absentes…).

---

## 1. Statut juridique du devis

| Avant signature | Après signature |
|---|---|
| Offre commerciale, sans engagement | Contrat ferme, opposable aux deux parties |
| Modifiable à volonté | Modification = avenant écrit |
| Responsabilité limitée | Responsabilité contractuelle pleine |

Un devis accepté par écrit (signature, mail de validation, bon de commande) **vaut contrat** et fait courir tous les délais et obligations.

---

## 2. Les mentions obligatoires

### 2.1 Identification des parties

- Raison sociale, SIREN, adresse, RCS du transporteur
- Identité complète du donneur d'ordre
- Numéro de licence de transport (LTI ou LTM)

### 2.2 Description du transport

- Nature de la marchandise, conditionnement, poids, volume
- Lieux et dates de chargement / livraison
- Type de véhicule mobilisé
- Conditions particulières (ADR, ATP, hayon, rendez-vous…)

### 2.3 Prix et conditions financières

- **Prix HT** ferme et détaillé
- TVA applicable (10 % en France pour le TRM)
- **Conditions de paiement** (délais, mode)
- Pénalités en cas de retard de paiement (taux légal × 3 minimum)
- Indemnité forfaitaire de recouvrement (40 € obligatoire depuis 2013)

### 2.4 Mentions légales obligatoires

- Référence au **contrat-type général** (décret 99-269) si le contrat ne déroge pas
- Plafonds d'indemnisation en cas d'avarie/perte
- Renvoi explicite aux **CGT** annexées

---

## 3. Les CGT : votre bouclier

Les **Conditions Générales de Transport** sont le document qui détaille tous les aspects que le devis n'a pas pu couvrir : responsabilités, exclusions, procédures de réserves, juridiction compétente.

### 3.1 Pour qu'elles soient opposables

| Condition | Détail |
|---|---|
| **Communication préalable** | Remises avant ou avec le devis (jamais après acceptation) |
| **Acceptation expresse** | Signature, case cochée, mention « lu et approuvé » |
| **Lisibilité** | Police lisible, pas de clauses noyées |
| **Cohérence** | Pas de contradiction avec le devis (le devis prime) |

> ⚠️ **Pièges fréquents**
>
> - CGT envoyées **après** acceptation du devis : **inopposables**.
> - Clauses limitatives de responsabilité **non visibles** ou **en très petit caractère** : annulables.
> - Renvoi vague (« voir nos CGT sur notre site ») : risque de nullité.

### 3.2 Clauses essentielles à intégrer

- Définition du **transport** (porte à porte, prise en charge, livraison)
- **Plafonds d'indemnisation** (rappel des limites légales)
- **Exonérations** (force majeure, vice propre, faute du chargeur…)
- **Réserves** : modalités et délais (3 jours pour les avaries non apparentes)
- **Prescription** des actions (1 an national, 1 an CMR)
- **Juridiction compétente** et droit applicable

---

## 4. Anatomie d'un devis professionnel

```
DEVIS N° 2026-2841
Émis le : 12 mai 2026
Validité : 30 jours

ÉMETTEUR
Logistique Garonne SAS
SIREN 838 521 472 — RCS Toulouse
LTI n° 31-2019-FR-00284

DESTINATAIRE
Métallerie Pyrénées
SIREN 421 998 332 — Lourdes (65)

OBJET
Transport de structures métalliques
Toulouse → Bayonne (livraison J+1)
Marchandise : 5 cadres acier galvanisé, 2,8 t, 8 ml chacun
Véhicule : porteur plateau 19 t avec arrimage chaînes

CONDITIONS
Prise en charge : 13/05/2026 entre 7 h et 10 h
Livraison : 14/05/2026 avant 14 h
Rendez-vous obligatoire (+ 25 € forfait)

PRIX
Transport (255 km commerciaux)               530,00 € HT
Forfait rendez-vous strict                     25,00 € HT
Indexation gazole (clause RPC art. L. 3222-1) Variable
                                       ─────────────
TOTAL HT                                      555,00 € HT
TVA 10 %                                       55,50 €
TOTAL TTC                                     610,50 € TTC

CONDITIONS DE PAIEMENT
30 jours fin de mois, par virement
Pénalités de retard : 3 fois le taux légal
Indemnité forfaitaire de recouvrement : 40 €

CONDITIONS GÉNÉRALES
Application du contrat-type général (décret 99-269 modifié)
CGT remises en annexe — opposables après acceptation
Plafond d'indemnisation : 33 € / kg ou 1 000 € / colis
Réserves à formuler : 3 jours pour avaries non apparentes

Signature précédée de la mention « bon pour accord »
```

---

## 5. Erreurs fréquentes à éviter

| Erreur | Conséquence |
|---|---|
| Forfait sans **plafond horaire** au chargement | Attente de 6 h non facturable |
| Pas de **clause carburant** | Hausse gazole subie sans recours |
| Validité du devis non précisée | Obligation de tenir le prix indéfiniment |
| « TVA en sus » sans **taux explicite** | Conflit sur le taux applicable |
| CGT non annexées | Plafonds légaux par défaut, exclusions inopposables |

---

> ✅ **À retenir**
>
> - Le devis accepté **vaut contrat** : engagement ferme des deux parties.
> - Mentions obligatoires : parties, marchandise, prix, paiement, plafonds.
> - Les **CGT** doivent être communiquées **avant** acceptation pour être opposables.
> - Toujours intégrer une **clause d'indexation gazole** (RPC art. L. 3222-1).
$lesson3$,
'Mentions obligatoires d''un devis transport, opposabilité des CGT, anatomie d''un devis professionnel et pièges à éviter.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Indexation carburant et négociation
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Indexation gazole (clause RPC) et négociation commerciale',
    'gotrm-bc01-03-04-rpc-negociation', 4, 60,
$lesson4$
# Indexation gazole (clause RPC) et négociation commerciale

Le carburant pèse **25 à 35 %** du coût de revient. Sans indexation contractuelle, une hausse brutale du gazole grignote toute votre marge. La loi française vous **donne un droit** : la **Répercussion du Prix du Carburant** (RPC).

> 🎯 **Objectifs de la leçon**
>
> - Comprendre le **mécanisme légal de la RPC** (article L. 3222-1 et L. 3222-2 du Code des transports).
> - Calculer une **indexation gazole** mensuelle.
> - Maîtriser la **négociation commerciale** sans casser sa marge.
> - Identifier les **leviers** non-prix (volume, délais, services).

---

## 1. Le cadre légal de la RPC

### 1.1 Le principe (L. 3222-1)

Le contrat de transport doit **prévoir une indexation du prix** sur la variation des coûts du carburant. À défaut de clause, la **répercussion automatique** s'applique de plein droit.

| Source | Disposition |
|---|---|
| **L. 3222-1 al. 1** | Toute opération de transport routier de marchandises doit faire l'objet d'une indexation gazole |
| **L. 3222-1 al. 2** | À défaut de clause, indexation automatique sur l'indice CNR mensuel |
| **L. 3222-2** | Le donneur d'ordre **ne peut s'opposer** à la répercussion |
| **L. 3242-3** | Sanctions pénales (15 000 € amende) en cas de refus du donneur d'ordre |

> 📌 **C'est un droit d'ordre public**
>
> Aucune clause contractuelle ne peut **renoncer** à la RPC ou la **plafonner artificiellement**. Toute clause contraire est réputée non écrite.

---

### 1.2 La méthode CNR (Comité National Routier)

Le CNR publie chaque mois des indices officiels de variation du gazole. La formule standard :

```
Prix indexé = Prix initial × [1 + (Var. gazole × Part carburant)]
```

| Élément | Valeur indicative |
|---|---|
| **Part carburant** dans le coût | 30 % (porteur), 35 % (TRR), 25 % (distribution urbaine) |
| **Indice de référence** | CNR — gazole national mensuel |
| **Périodicité** | Mensuelle ou trimestrielle |

> 📌 **Exemple chiffré**
>
> Contrat signé en mars 2026 à **2 800 € HT** par tournée hebdomadaire (porteur 19 t).
>
> | Mois | Indice CNR gazole | Variation | Part carburant | Coefficient | Prix indexé |
> |---|---|---|---|---|---|
> | Mars (référence) | 142,3 | — | 30 % | 1,000 | 2 800 € |
> | Avril | 148,7 | +4,5 % | 30 % | 1,0135 | **2 838 €** |
> | Mai | 145,1 | +1,97 % | 30 % | 1,0059 | **2 817 €** |
> | Juin | 152,4 | +7,1 % | 30 % | 1,0213 | **2 860 €** |

---

## 2. Rédiger une clause RPC efficace

### 2.1 Clause modèle

> *« Conformément à l'article L. 3222-1 du Code des transports, le prix mentionné au présent contrat est indexé chaque mois sur la variation du Comité National Routier (CNR) — indice gazole national, base mensuelle. La part carburant est fixée à 30 % du prix de transport. La répercussion s'applique de plein droit sur toutes les factures émises au cours du mois suivant la publication de l'indice. »*

### 2.2 Variantes courantes

| Variante | Usage |
|---|---|
| **Clause CNR mensuelle** | Standard, conseillée pour les contrats >3 mois |
| **Clause CNR trimestrielle** | Lisse les variations courtes, moins réactive |
| **Clause TLF / Comité régional** | Indices alternatifs reconnus |
| **Clause prix gazole gare** | Référence au prix moyen Total/Esso, plus simple mais moins protecteur |

> ⚠️ **À proscrire**
>
> - **Clause à la baisse uniquement** (le client veut bénéficier des baisses sans subir les hausses) : illégale.
> - **Plafond unilatéral** (« indexation limitée à 5 % »).
> - **Renoncer à la RPC** dans les CGT du donneur d'ordre.

---

## 3. La négociation commerciale

### 3.1 Préparer la négociation

Avant tout rendez-vous client, l'exploitant doit avoir en tête :

| Donnée | Pourquoi |
|---|---|
| Coût de revient km de la mission | Connaître le seuil de profitabilité |
| Marge nette cible | Savoir jusqu'où descendre |
| Prix marché de référence | Se positionner sans être hors-jeu |
| Valeur ajoutée différenciante | Justifier un écart |

### 3.2 Les leviers non-prix

Quand le client pousse sur le prix, **changer de variable** :

| Levier | Effet sur la marge |
|---|---|
| Augmenter le volume engagé (lots complets vs partiels) | Mutualisation, meilleur taux |
| Allonger les délais de livraison (J+2 au lieu de J+1) | Mutualisation des tournées |
| Standardiser les rendez-vous (créneaux 4 h au lieu de heures fixes) | Réduit l'attente |
| Engager sur 12 mois plutôt que 3 | Permet d'amortir équipement spécifique |
| Accepter le retour à vide vs exiger un fret retour | Différentiel de 15-20 % |

### 3.3 Les concessions à éviter

- **Casser le prix de plus de 5 à 8 %** : signal de faiblesse, attire la prochaine baisse.
- **Renoncer à la RPC** : suicide à 6 mois.
- **Accepter des plafonds d'indemnisation supérieurs aux limites légales** sans contrepartie financière.
- **Engagement ferme de capacité** sans clause de réajustement.

---

## 4. La règle des 3 leviers

Pour préserver la rentabilité face à une demande de baisse de prix :

```
1. Volume — Si le client demande -5 %, exiger +20 % de volume.
2. Délai — Élargir le délai de livraison ou la fenêtre RDV.
3. Service — Réduire un service annexe (rendez-vous strict, hayon, gerbage…).
```

> 💡 **Mantra du commercial transport**
>
> *« Je ne baisse jamais un prix sans une contrepartie qui me redonne au moins l'équivalent en marge. »*

---

## 5. Cas pratique de négociation

**Contexte** : Le client *Ferronnerie d'Arles* demande une baisse de 8 % sur un contrat existant à **1,42 €/km commercial**.

| Étape | Action exploitant |
|---|---|
| 1. Calculer l'impact | -8 % = -0,114 €/km. Marge actuelle 12 %, projetée 4 % → zone rouge |
| 2. Refuser la baisse sèche | « Je ne peux pas descendre à ce niveau sans contrepartie » |
| 3. Proposer 3 leviers | A. Volume +25 % → -4 % ; B. Délai J+2 → -3 % ; C. Suppression RDV strict → -2 % |
| 4. Conclure | Mix volume +15 % et délai J+2 → -5 % (au lieu des -8 % demandés) |
| 5. Sécuriser | Avenant écrit avec nouvelle clause volume minimum |

---

> ✅ **À retenir**
>
> - La **RPC est d'ordre public** : aucune clause ne peut y renoncer.
> - Indexation mensuelle CNR avec **part carburant 30 % (porteur)** ou 35 % (TRR).
> - Une clause RPC bien rédigée protège votre marge sur la durée.
> - En négociation : **3 leviers — volume, délai, service** — avant de toucher au prix.
> - **Jamais de baisse > 5 %** sans contrepartie chiffrée.
$lesson4$,
'Mécanisme légal de la RPC (L. 3222-1), clause CNR mensuelle, négociation par leviers (volume, délai, service) et cas pratique.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- 28 QCM REFORMULÉS
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qcm', 'Parmi ces postes, lequel est un coût VARIABLE pour un véhicule industriel ?', '[{"id":"a","label":"L''amortissement","is_correct":false},{"id":"b","label":"L''assurance véhicule","is_correct":false},{"id":"c","label":"Le carburant","is_correct":true},{"id":"d","label":"La taxe à l''essieu","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['couts','variables'], 'mft-2026-gotrm:bc01-03:qcm:1', true, 'Le carburant est proportionnel aux kilomètres parcourus, donc variable. Amortissement, assurance et taxe à l''essieu sont fixes (existent même véhicule à l''arrêt).'),
  (v_formation, 'qcm', 'Un porteur 19 t neuf coûte 95 000 € HT, valeur résiduelle 25 % après 6 ans, parcourt 120 000 km/an. Coût d''amortissement kilométrique ?', '[{"id":"a","label":"Environ 0,066 €/km","is_correct":false},{"id":"b","label":"Environ 0,099 €/km","is_correct":true},{"id":"c","label":"Environ 0,132 €/km","is_correct":false},{"id":"d","label":"Environ 0,158 €/km","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['calcul','amortissement'], 'mft-2026-gotrm:bc01-03:qcm:2', true, 'Base = 95 000 − 23 750 = 71 250 €. Amortissement annuel = 71 250 / 6 = 11 875 €. Coût km = 11 875 / 120 000 ≈ 0,099 €/km.'),
  (v_formation, 'qcm', 'Le carburant représente quelle part typique du coût de revient kilométrique d''un porteur ?', '[{"id":"a","label":"5 à 10 %","is_correct":false},{"id":"b","label":"15 à 20 %","is_correct":false},{"id":"c","label":"25 à 35 %","is_correct":true},{"id":"d","label":"45 à 55 %","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['couts','carburant'], 'mft-2026-gotrm:bc01-03:qcm:3', true, 'Le carburant pèse 25 à 35 % du coût total selon le profil d''exploitation. C''est aussi le poste le plus volatil, d''où l''importance de l''indexation contractuelle.'),
  (v_formation, 'qcm', 'Un véhicule fait Lyon → Marseille (320 km chargés) puis retour à vide (320 km). Quel est le coût km commercial si le coût km total est 1,22 € ?', '[{"id":"a","label":"1,22 €/km","is_correct":false},{"id":"b","label":"1,83 €/km","is_correct":false},{"id":"c","label":"2,44 €/km","is_correct":true},{"id":"d","label":"3,05 €/km","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['km-commercial','calcul'], 'mft-2026-gotrm:bc01-03:qcm:4', true, 'Tous les coûts des 640 km totaux doivent être absorbés sur 320 km commerciaux (chargés). Coût km commercial = 1,22 × 640 / 320 = 2,44 €/km. Le retour à vide double mécaniquement le coût km commercial.'),
  (v_formation, 'qcm', 'Un transport a un coût de revient total de 546 €. Si je vise une marge nette de 10 %, quel prix HT minimal proposer ?', '[{"id":"a","label":"546 € HT","is_correct":false},{"id":"b","label":"600 € HT","is_correct":false},{"id":"c","label":"607 € HT","is_correct":true},{"id":"d","label":"655 € HT","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['calcul','marge'], 'mft-2026-gotrm:bc01-03:qcm:5', true, 'Prix = Coût / (1 − marge) = 546 / (1 − 0,10) = 546 / 0,90 = 607 € HT. Une simple addition « coût + 10 % » donnerait 600 € mais ne représenterait que 9 % de marge sur le prix.'),
  (v_formation, 'qcm', 'Quelle marge nette est considérée comme un seuil de fragilité structurelle dans le TRM ?', '[{"id":"a","label":"Inférieure à 1 %","is_correct":false},{"id":"b","label":"Inférieure à 4 %","is_correct":true},{"id":"c","label":"Inférieure à 8 %","is_correct":false},{"id":"d","label":"Inférieure à 12 %","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['marge','rentabilite'], 'mft-2026-gotrm:bc01-03:qcm:6', true, 'Une marge nette inférieure à 4 % rend l''entreprise fragile à tout incident (panne, sinistre, hausse carburant). En dessous de 2 %, l''activité est structurellement en danger.'),
  (v_formation, 'qcm', 'La méthode CRT (Coût de Revient Transport) repose principalement sur :', '[{"id":"a","label":"Le prix marché × 0,9","is_correct":false},{"id":"b","label":"(Km × coût km variable) + (heures × coût horaire fixe) + opérations annexes","is_correct":true},{"id":"c","label":"Le coût des concurrents directement","is_correct":false},{"id":"d","label":"Le forfait journalier conducteur uniquement","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['methode','crt'], 'mft-2026-gotrm:bc01-03:qcm:7', true, 'Le CRT additionne les coûts variables (au km) et les coûts fixes (à l''heure pour le conducteur, l''amortissement et la structure), plus les opérations annexes spécifiques à la mission.'),
  (v_formation, 'qcm', 'Pour un transport de mobilier volumineux et léger, l''unité de tarification la plus pertinente est :', '[{"id":"a","label":"À la tonne","is_correct":false},{"id":"b","label":"Au km","is_correct":false},{"id":"c","label":"Au m³","is_correct":true},{"id":"d","label":"Au point de livraison","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['tarification','volume'], 'mft-2026-gotrm:bc01-03:qcm:8', true, 'Le mobilier est volumineux mais léger : la tarification au m³ reflète mieux la capacité utilisée du véhicule (ce sont les volumes qui saturent le camion avant le poids).'),
  (v_formation, 'qcm', 'Un devis transport accepté par signature du client :', '[{"id":"a","label":"Reste révocable pendant 7 jours","is_correct":false},{"id":"b","label":"Vaut contrat ferme opposable aux deux parties","is_correct":true},{"id":"c","label":"N''engage que le transporteur","is_correct":false},{"id":"d","label":"Doit être confirmé par bon de commande pour être valable","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['devis','contrat'], 'mft-2026-gotrm:bc01-03:qcm:9', true, 'L''acceptation écrite (signature, mail, bon de commande) transforme le devis en contrat ferme. Toute modification ultérieure exige un avenant écrit.'),
  (v_formation, 'qcm', 'Pour qu''une CGT (Conditions Générales de Transport) soit opposable, elle doit être :', '[{"id":"a","label":"Communiquée après acceptation du devis","is_correct":false},{"id":"b","label":"Disponible uniquement sur le site internet du transporteur","is_correct":false},{"id":"c","label":"Communiquée avant ou avec le devis et acceptée expressément","is_correct":true},{"id":"d","label":"Signée par un huissier de justice","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['cgt','opposabilite'], 'mft-2026-gotrm:bc01-03:qcm:10', true, 'Les CGT doivent être remises avant ou avec le devis (jamais après acceptation), être lisibles, et faire l''objet d''une acceptation expresse pour être opposables. Un simple lien vers le site est insuffisant.'),
  (v_formation, 'qcm', 'L''indemnité forfaitaire de recouvrement obligatoire en cas de retard de paiement B2B est de :', '[{"id":"a","label":"20 €","is_correct":false},{"id":"b","label":"40 €","is_correct":true},{"id":"c","label":"75 €","is_correct":false},{"id":"d","label":"100 €","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['paiement','recouvrement'], 'mft-2026-gotrm:bc01-03:qcm:11', true, 'Depuis la loi du 22 mars 2012 (transposition directive 2011/7/UE), toute facture impayée à échéance entraîne automatiquement une indemnité forfaitaire de 40 € pour frais de recouvrement, en plus des pénalités de retard.'),
  (v_formation, 'qcm', 'La RPC (Répercussion du Prix du Carburant) est :', '[{"id":"a","label":"Une option commerciale facultative","is_correct":false},{"id":"b","label":"Une obligation légale d''ordre public (L. 3222-1 Code des transports)","is_correct":true},{"id":"c","label":"Un dispositif réservé aux PME du transport","is_correct":false},{"id":"d","label":"Une recommandation syndicale non contraignante","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['rpc','legal'], 'mft-2026-gotrm:bc01-03:qcm:12', true, 'L''article L. 3222-1 du Code des transports impose la répercussion du carburant et la rend d''ordre public : aucune clause ne peut y renoncer. Sanctions pénales (15 000 €) en cas de refus du donneur d''ordre.'),
  (v_formation, 'qcm', 'L''indice de référence le plus utilisé pour la clause d''indexation gazole est :', '[{"id":"a","label":"L''INSEE des prix à la consommation","is_correct":false},{"id":"b","label":"L''indice CNR (Comité National Routier) gazole national","is_correct":true},{"id":"c","label":"Le cours du Brent à Londres","is_correct":false},{"id":"d","label":"L''indice DGCCRF des produits pétroliers","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['rpc','cnr'], 'mft-2026-gotrm:bc01-03:qcm:13', true, 'Le CNR (Comité National Routier) publie chaque mois des indices officiels reconnus par la profession et opposables. L''indice gazole national est la référence standard pour la clause RPC.'),
  (v_formation, 'qcm', 'Dans une formule d''indexation gazole, la part carburant typique pour un porteur 19 t en régional est de :', '[{"id":"a","label":"15 %","is_correct":false},{"id":"b","label":"30 %","is_correct":true},{"id":"c","label":"50 %","is_correct":false},{"id":"d","label":"75 %","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['rpc','coefficient'], 'mft-2026-gotrm:bc01-03:qcm:14', true, 'La part carburant standard est 30 % pour un porteur, 35 % pour un TRR (transport routier régional longue distance), et 25 % pour la distribution urbaine. C''est ce coefficient qui est appliqué à la variation d''indice CNR.'),
  (v_formation, 'qcm', 'Contrat à 2 800 € avec part carburant 30 %. L''indice CNR varie de +5 %. Quel est le nouveau prix ?', '[{"id":"a","label":"2 814 €","is_correct":false},{"id":"b","label":"2 828 €","is_correct":false},{"id":"c","label":"2 842 €","is_correct":true},{"id":"d","label":"2 940 €","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['rpc','calcul'], 'mft-2026-gotrm:bc01-03:qcm:15', true, 'Coefficient = 1 + (5 % × 30 %) = 1 + 0,015 = 1,015. Prix indexé = 2 800 × 1,015 = 2 842 €. La hausse n''impacte que la part carburant du prix, pas les autres postes.'),
  (v_formation, 'qcm', 'Une clause prévoyant une indexation gazole « uniquement à la baisse » est :', '[{"id":"a","label":"Légale si négociée librement","is_correct":false},{"id":"b","label":"Illégale et réputée non écrite","is_correct":true},{"id":"c","label":"Légale uniquement pour les contrats inférieurs à 6 mois","is_correct":false},{"id":"d","label":"Légale si compensée par un autre avantage","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['rpc','illegal'], 'mft-2026-gotrm:bc01-03:qcm:16', true, 'L''article L. 3222-1 impose une indexation symétrique (hausses ET baisses). Une clause asymétrique est illégale et réputée non écrite, indépendamment de toute négociation. Le donneur d''ordre commet une infraction (15 000 € amende).'),
  (v_formation, 'qcm', 'Lors d''une négociation, un client demande -8 % sur le prix. La meilleure approche est :', '[{"id":"a","label":"Accepter immédiatement pour préserver la relation","is_correct":false},{"id":"b","label":"Refuser sèchement sans alternative","is_correct":false},{"id":"c","label":"Proposer des contreparties (volume, délai, service) pour réduire l''impact","is_correct":true},{"id":"d","label":"Renvoyer à la concurrence","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['negociation','leviers'], 'mft-2026-gotrm:bc01-03:qcm:17', true, 'La règle des 3 leviers (volume, délai, service) permet de préserver la marge tout en répondant au besoin du client. Une baisse sèche supérieure à 5 % sans contrepartie signale de la faiblesse et appelle la baisse suivante.'),
  (v_formation, 'qcm', 'Le contrat-type général applicable à défaut d''écrit en transport national est défini par :', '[{"id":"a","label":"Le décret 99-269 du 6 avril 1999 (modifié)","is_correct":true},{"id":"b","label":"La loi LOTI de 1982","is_correct":false},{"id":"c","label":"L''accord de Genève de 1956","is_correct":false},{"id":"d","label":"La directive européenne 96/53/CE","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['contrat-type','decret'], 'mft-2026-gotrm:bc01-03:qcm:18', true, 'Le décret 99-269 du 6 avril 1999 (modifié par décrets postérieurs) fixe le contrat-type général applicable à tout transport national en l''absence de convention écrite particulière entre les parties.'),
  (v_formation, 'qcm', 'Le taux de TVA applicable au transport routier de marchandises en France est :', '[{"id":"a","label":"5,5 %","is_correct":false},{"id":"b","label":"10 %","is_correct":false},{"id":"c","label":"20 %","is_correct":true},{"id":"d","label":"Le TRM est exonéré de TVA","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['tva','prix'], 'mft-2026-gotrm:bc01-03:qcm:19', true, 'Le transport routier de marchandises est soumis au taux normal de TVA de 20 % en France métropolitaine. Le taux réduit de 10 % concerne le transport de voyageurs, pas les marchandises.'),
  (v_formation, 'qcm', 'Une marge brute de 50 % sur un transport signifie :', '[{"id":"a","label":"Que l''entreprise gagne 50 % de bénéfice net","is_correct":false},{"id":"b","label":"Que (Prix − Coûts variables) / Prix = 50 %","is_correct":true},{"id":"c","label":"Que le coût de revient est doublé pour fixer le prix","is_correct":false},{"id":"d","label":"Que la TVA représente 50 %","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['marge','calcul'], 'mft-2026-gotrm:bc01-03:qcm:20', true, 'La marge brute est (Prix − Coûts variables directs) / Prix. Elle ne tient pas compte des coûts fixes ou de structure. C''est un indicateur de couverture des frais variables, pas de rentabilité finale.'),
  (v_formation, 'qcm', 'Un coût horaire conducteur de 25,6 €/h et une vitesse moyenne de 65 km/h donnent un coût km de :', '[{"id":"a","label":"0,256 €/km","is_correct":false},{"id":"b","label":"0,394 €/km","is_correct":true},{"id":"c","label":"0,512 €/km","is_correct":false},{"id":"d","label":"0,650 €/km","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['calcul','conducteur'], 'mft-2026-gotrm:bc01-03:qcm:21', true, '25,6 / 65 = 0,394 €/km. Le coût km conducteur représente environ un tiers du coût de revient total d''un porteur, à parité avec le carburant.'),
  (v_formation, 'qcm', 'L''« indemnité forfaitaire de recouvrement » de 40 € s''applique :', '[{"id":"a","label":"Sur demande écrite uniquement","is_correct":false},{"id":"b","label":"Automatiquement, à chaque facture impayée à échéance","is_correct":true},{"id":"c","label":"Une fois par an au total","is_correct":false},{"id":"d","label":"Uniquement si le client est mis en demeure par huissier","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['paiement','legal'], 'mft-2026-gotrm:bc01-03:qcm:22', true, 'L''indemnité de 40 € s''applique automatiquement à chaque facture impayée à échéance, sans formalité ni mise en demeure. Elle s''ajoute aux pénalités de retard et peut être complétée par la facturation des frais réels au-delà de 40 €.'),
  (v_formation, 'qcm', 'Le « lissage annuel » des coûts fixes consiste à :', '[{"id":"a","label":"Faire varier le prix toutes les semaines","is_correct":false},{"id":"b","label":"Répartir les coûts fixes sur le volume km commercial annuel prévu","is_correct":true},{"id":"c","label":"Reporter les coûts fixes à l''année suivante","is_correct":false},{"id":"d","label":"Augmenter les coûts fixes de 5 % chaque année","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['couts','lissage'], 'mft-2026-gotrm:bc01-03:qcm:23', true, 'Le lissage répartit les coûts fixes (amortissement, assurance, structure) sur le total des km commerciaux prévus dans l''année, ce qui donne un seuil de profitabilité réaliste plutôt qu''une vision mission par mission.'),
  (v_formation, 'qcm', 'Pour un transport de granulats (matériau dense), l''unité de tarification la plus adaptée est :', '[{"id":"a","label":"Au m³","is_correct":false},{"id":"b","label":"À la palette EUR","is_correct":false},{"id":"c","label":"À la tonne","is_correct":true},{"id":"d","label":"Au point de livraison","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['tarification','densite'], 'mft-2026-gotrm:bc01-03:qcm:24', true, 'Les granulats sont denses : c''est le poids qui sature le camion avant le volume. La tarification à la tonne est donc la plus pertinente pour ce type de marchandise.'),
  (v_formation, 'qcm', 'En cas de hausse soudaine du gazole de 10 % en cours de contrat sans clause RPC explicite :', '[{"id":"a","label":"Le transporteur doit absorber la hausse intégralement","is_correct":false},{"id":"b","label":"L''indexation s''applique automatiquement par la loi (L. 3222-1 al. 2)","is_correct":true},{"id":"c","label":"Il faut résilier le contrat puis le renégocier","is_correct":false},{"id":"d","label":"Seul le client peut décider d''accorder une hausse","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['rpc','defaut-clause'], 'mft-2026-gotrm:bc01-03:qcm:25', true, 'L''article L. 3222-1 al. 2 prévoit qu''à défaut de clause contractuelle, la répercussion s''applique automatiquement de plein droit, sur la base de l''indice CNR mensuel. Le transporteur a le droit de facturer la hausse même sans clause écrite.'),
  (v_formation, 'qcm', 'Une PME de transport de 20 véhicules a 250 000 € de frais de structure annuels. Coût structure km par véhicule pour 120 000 km/an ?', '[{"id":"a","label":"0,052 €/km","is_correct":false},{"id":"b","label":"0,104 €/km","is_correct":true},{"id":"c","label":"0,156 €/km","is_correct":false},{"id":"d","label":"0,208 €/km","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['calcul','structure'], 'mft-2026-gotrm:bc01-03:qcm:26', true, 'Frais par véhicule = 250 000 / 20 = 12 500 €/an. Coût km = 12 500 / 120 000 = 0,104 €/km. La structure pèse environ 8 à 10 % du coût total dans une PME bien dimensionnée.'),
  (v_formation, 'qcm', 'Quel élément n''est PAS une mention obligatoire d''un devis transport ?', '[{"id":"a","label":"SIREN du transporteur","is_correct":false},{"id":"b","label":"Numéro de licence de transport (LTI/LTM)","is_correct":false},{"id":"c","label":"Le nom du conducteur affecté","is_correct":true},{"id":"d","label":"Les conditions de paiement","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['devis','mentions'], 'mft-2026-gotrm:bc01-03:qcm:27', true, 'Le nom du conducteur n''est pas une mention obligatoire — c''est une donnée d''affectation interne, qui peut changer. Les éléments obligatoires sont l''identification des parties (SIREN, licence), la marchandise, le prix, les conditions de paiement et le renvoi aux CGT.'),
  (v_formation, 'qcm', 'En négociation, le levier le plus efficace pour préserver la marge face à une demande de baisse est :', '[{"id":"a","label":"Réduire la qualité du service en silence","is_correct":false},{"id":"b","label":"Augmenter le volume engagé pour mutualiser","is_correct":true},{"id":"c","label":"Promettre une compensation l''année suivante","is_correct":false},{"id":"d","label":"Ajouter des frais cachés sur les factures","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['negociation','volume'], 'mft-2026-gotrm:bc01-03:qcm:28', true, 'Augmenter le volume engagé est le levier n°1 : il permet d''amortir les coûts fixes et d''optimiser les tournées. Les autres options sont soit illégales, soit toxiques pour la relation commerciale à long terme.');


  -- =================================================================
  -- 5 QR (questions rédigées)
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qr', 'Un client vous demande un devis pour un porteur 19 t entre Bordeaux (33) et Toulouse (31). Trajet 245 km commerciaux, 250 km retour à vide. Coût km variable 0,60 € et coût horaire 33 €/h pour 8 h totales (4 h conduite + 4 h chargement/déchargement/pause). Marge nette cible 12 %. Calculez le coût de revient transport (CRT) et le prix HT minimal à proposer.', NULL, 1, 'moyen', ARRAY['cas-pratique','calcul'], 'mft-2026-gotrm:bc01-03:qr:1', true, 'Calcul attendu :
1. Km totaux = 245 + 250 = 495 km
2. Coûts variables = 495 × 0,60 = 297 €
3. Coûts horaires = 8 × 33 = 264 €
4. CRT = 297 + 264 = 561 € (sans opérations annexes spécifiques)
5. Prix HT = 561 / (1 − 0,12) = 561 / 0,88 = 637,50 € HT
6. Coût km commercial = 561 / 245 = 2,29 €/km — à comparer avec le prix marché.

Réponse à formuler au client : 638 € HT (arrondi commercial), avec clause d''indexation gazole CNR mensuelle.'),
  (v_formation, 'qr', 'Vous gérez un contrat annuel à 1 850 €/tournée hebdomadaire avec une clause RPC standard (CNR mensuel, part carburant 30 %). L''indice CNR est passé de 138,5 (référence janvier) à 147,2 en mars. Calculez le prix indexé applicable aux tournées de mars et expliquez la mécanique au client.', NULL, 1, 'difficile', ARRAY['rpc','calcul','argumentaire'], 'mft-2026-gotrm:bc01-03:qr:2', true, 'Calcul attendu :
1. Variation indice = (147,2 − 138,5) / 138,5 = 6,28 %
2. Coefficient = 1 + (6,28 % × 30 %) = 1 + 0,01884 = 1,01884
3. Prix indexé = 1 850 × 1,01884 = 1 884,85 € HT, arrondi à 1 885 € HT
4. Hausse répercutée : 35 € par tournée (uniquement la part carburant subit la variation)

Argumentaire client : « Conformément à l''article L. 3222-1 du Code des transports et à la clause d''indexation prévue à notre contrat, le carburant ayant augmenté de 6,28 % depuis janvier, et représentant 30 % du prix de transport, j''applique la répercussion de 35 € par tournée à partir des factures de mars. Vous trouverez ci-joint la note de calcul détaillée avec la référence CNR. »'),
  (v_formation, 'qr', 'Un nouveau client vous transmet ses « Conditions Générales d''Achat » qui contiennent : « Le prestataire renonce expressément à toute clause d''indexation gazole, le prix étant ferme sur la durée du contrat ». Comment réagissez-vous ? Argumentez votre réponse en citant les textes.', NULL, 1, 'difficile', ARRAY['rpc','negociation','droit'], 'mft-2026-gotrm:bc01-03:qr:3', true, 'Réponse type :

a. Refus catégorique de la clause :
Je refuse cette clause car elle contrevient à l''article L. 3222-1 du Code des transports, qui rend la répercussion du prix du carburant d''ordre public. Toute clause y dérogeant est réputée non écrite.

b. Risque pour le donneur d''ordre :
L''article L. 3242-3 prévoit une amende de 15 000 € pour le donneur d''ordre qui s''oppose à la répercussion. La clause expose le client à un risque pénal.

c. Proposition alternative :
Je propose à la place une clause d''indexation CNR mensuelle classique (part carburant 30 %), qui assure la transparence et la prévisibilité tout en respectant la loi. Je peux également proposer une clause trimestrielle plus stable si le client recherche une meilleure prévisibilité budgétaire.

d. Documentation :
Je joins à ma réponse une copie des articles L. 3222-1, L. 3222-2 et L. 3242-3 ainsi qu''un avis du CNR sur la pratique standard.'),
  (v_formation, 'qr', 'Un client annuel vous demande -8 % sur le prix unitaire de la tournée (actuellement 1,42 €/km commercial, marge nette 11 %). Décrivez votre stratégie de négociation en utilisant la règle des 3 leviers et calculez l''impact sur la marge.', NULL, 1, 'difficile', ARRAY['negociation','strategie'], 'mft-2026-gotrm:bc01-03:qr:4', true, 'Stratégie attendue :

1. Calcul de l''impact d''une baisse sèche :
- Nouvelle marge = 11 % − 8 % ≈ 3 % → zone de fragilité structurelle (sous le seuil des 4 %).
- Refus de la baisse sèche.

2. Application des 3 leviers :
- Levier VOLUME : augmenter le volume engagé annuel de 25 % (par exemple, ajouter une tournée hebdomadaire). Mutualisation → permet une baisse de 4 %.
- Levier DÉLAI : passer la fenêtre de livraison de J+1 à J+2. Cela donne de la flexibilité de planification → −2 %.
- Levier SERVICE : supprimer le rendez-vous strict en livraison (créneau 4 h au lieu d''heure précise) → −1 %.

3. Synthèse de la contre-proposition :
- Baisse totale possible : 4 + 2 + 1 = 7 % (au lieu des 8 % demandés).
- Marge préservée à environ 8 % (vs 3 % en baisse sèche).

4. Sécurisation contractuelle :
- Avenant écrit fixant le volume minimal annuel garanti, les nouvelles conditions de RDV et les délais.
- Clause de revoyure à 6 mois pour ajuster si le volume n''est pas tenu.

Mantra : « Je ne baisse jamais un prix sans contrepartie qui me redonne au moins l''équivalent en marge. »'),
  (v_formation, 'qr', 'Listez et expliquez 5 erreurs fréquentes dans la rédaction d''un devis transport, en précisant pour chacune la conséquence opérationnelle ou juridique.', NULL, 1, 'moyen', ARRAY['devis','erreurs'], 'mft-2026-gotrm:bc01-03:qr:5', true, 'Erreurs attendues (au moins 5 sur les 7 ci-dessous) :

1. Forfait sans plafond horaire au chargement/déchargement : le transporteur peut subir 6 h d''attente non facturable. Conséquence : marge anéantie sur la mission.

2. Absence de clause d''indexation gazole : la hausse du carburant est subie sans recours immédiat (même si la loi protège, la facturation est plus complexe).

3. Validité du devis non précisée : obligation de tenir le prix indéfiniment, exposition à un retournement de marché.

4. « TVA en sus » sans taux explicite : conflit possible entre 10 % (transport voyageurs) et 20 % (TRM applicable). Risque de redressement TVA.

5. CGT non annexées au devis : les plafonds légaux par défaut s''appliquent (33 €/kg ou 1 000 €/colis), les exclusions ne sont pas opposables, et les délais de réserve standard prévalent.

6. Absence de mention des plafonds d''indemnisation : difficulté à opposer les limites légales en cas de litige (charge de la preuve plus lourde).

7. Absence du numéro de licence transport (LTI/LTM) : irrégularité formelle pouvant entraîner la nullité du contrat ou le rejet par le donneur d''ordre.');


  -- =================================================================
  -- QUIZZES (4 entraînement + 1 examen blanc)
  -- =================================================================
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — Composantes du prix de transport', 'Coûts fixes/variables, postes principaux, km commercial vs total.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-03:qcm:1','mft-2026-gotrm:bc01-03:qcm:2','mft-2026-gotrm:bc01-03:qcm:3','mft-2026-gotrm:bc01-03:qcm:4','mft-2026-gotrm:bc01-03:qcm:21','mft-2026-gotrm:bc01-03:qcm:23','mft-2026-gotrm:bc01-03:qcm:26');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — Coût de revient et marge', 'CRT, marge brute/nette, tarification au km/palette/tonne.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-03:qcm:5','mft-2026-gotrm:bc01-03:qcm:6','mft-2026-gotrm:bc01-03:qcm:7','mft-2026-gotrm:bc01-03:qcm:8','mft-2026-gotrm:bc01-03:qcm:20','mft-2026-gotrm:bc01-03:qcm:24');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — Devis et CGT', 'Mentions obligatoires, opposabilité des CGT, contrat-type.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-03:qcm:9','mft-2026-gotrm:bc01-03:qcm:10','mft-2026-gotrm:bc01-03:qcm:11','mft-2026-gotrm:bc01-03:qcm:18','mft-2026-gotrm:bc01-03:qcm:19','mft-2026-gotrm:bc01-03:qcm:22','mft-2026-gotrm:bc01-03:qcm:27');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — Indexation gazole et négociation', 'RPC, indice CNR, calcul d''indexation, leviers de négociation.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-03:qcm:12','mft-2026-gotrm:bc01-03:qcm:13','mft-2026-gotrm:bc01-03:qcm:14','mft-2026-gotrm:bc01-03:qcm:15','mft-2026-gotrm:bc01-03:qcm:16','mft-2026-gotrm:bc01-03:qcm:17','mft-2026-gotrm:bc01-03:qcm:25','mft-2026-gotrm:bc01-03:qcm:28');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Examen blanc — BC01-03 Cotation et offre', '12 QCM en 25 min, seuil 50 %. Synthèse du module.', 'examen', 1500, 50)
  RETURNING id INTO v_quiz_eb;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-03:qcm:2','mft-2026-gotrm:bc01-03:qcm:4','mft-2026-gotrm:bc01-03:qcm:5','mft-2026-gotrm:bc01-03:qcm:7','mft-2026-gotrm:bc01-03:qcm:10','mft-2026-gotrm:bc01-03:qcm:12','mft-2026-gotrm:bc01-03:qcm:14','mft-2026-gotrm:bc01-03:qcm:15','mft-2026-gotrm:bc01-03:qcm:18','mft-2026-gotrm:bc01-03:qcm:25','mft-2026-gotrm:bc01-03:qcm:27','mft-2026-gotrm:bc01-03:qcm:28');

  RAISE NOTICE '✅ GOTRM BC01-03 v2 chargé : 4 leçons, 28 QCM, 5 QR, 5 quizzes (4 entraînement + 1 examen blanc).';
END
$bc01_03$;
