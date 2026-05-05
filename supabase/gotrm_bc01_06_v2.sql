-- =====================================================================
-- GOTRM (RNCP 40990) — BC01-06 : Planifier et optimiser les tournées
-- Méthodes, construction, outils TMS, KPI planification.
-- =====================================================================

DO $bc01_06$
DECLARE
  v_formation uuid; v_bloc int; v_module uuid;
  v_lesson_1 uuid; v_lesson_2 uuid; v_lesson_3 uuid; v_lesson_4 uuid;
  v_quiz_1 uuid; v_quiz_2 uuid; v_quiz_3 uuid; v_quiz_4 uuid; v_quiz_eb uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc.'; END IF;

  DELETE FROM public.modules WHERE slug = 'gotrm-bc01-06-planification-tournees';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'BC01-06 — Planifier et optimiser les tournées',
    'gotrm-bc01-06-planification-tournees', v_bloc,
    'Méthodes de planification, construction d''une tournée optimale, outils TMS et télématique, KPI de pilotage et amélioration continue.',
    'avance', 220, 60
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 60, true) ON CONFLICT DO NOTHING;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-06:%';

  -- =================================================================
  -- LEÇON 1 — Méthodes de planification
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Méthodes de planification : types, contraintes, modèles',
    'gotrm-bc01-06-01-methodes-planification', 1, 50,
$lesson1$
# Méthodes de planification : types, contraintes, modèles

La planification est le **cœur du métier exploitant**. Une bonne planification fait gagner 10 à 25 % de productivité sur un parc, à coût de revient identique. Une mauvaise planification fait perdre des marges, des clients et des conducteurs.

> 🎯 **Objectifs de la leçon**
>
> - Distinguer les **types de tournées** (lots complets, partiels, distribution).
> - Identifier les **contraintes** à respecter (réglementaires, commerciales, techniques).
> - Comprendre les **modèles d'optimisation** (VRP, savings, plus proche voisin).
> - Maîtriser le **vocabulaire** : tournée, ligne, navette, distribution.

---

## 1. Les types de tournées

### 1.1 Tournée « lot complet » (Full Truck Load — FTL)

| Caractéristique | Détail |
|---|---|
| Marchandise | Un seul chargement remplit le véhicule |
| Distance | Souvent longue (200 à 1 500 km) |
| Points | 1 chargement, 1 livraison |
| Optimisation | Choix de l'itinéraire, du véhicule, des relais |

> 📌 **Exemple FTL**
>
> Un porteur 19 t fait Strasbourg → Bordeaux avec 18 t de céréales pour un seul client. Le véhicule est plein, l'optimisation porte sur le retour (fret retour ou retour à vide).

### 1.2 Tournée « lot partiel » (Less Than Truckload — LTL)

| Caractéristique | Détail |
|---|---|
| Marchandise | Plusieurs lots de différents clients |
| Distance | Moyenne (50 à 500 km) |
| Points | 2 à 8 chargements/livraisons |
| Optimisation | Combinaison des flux, co-chargement |

> 📌 **Exemple LTL**
>
> Une remorque collecte 4 palettes à Toulouse, 7 à Albi et 3 à Castres pour livrer un dépôt central à Montauban. Co-chargement de 3 expéditeurs vers 1 destinataire.

### 1.3 Tournée de distribution (multi-stops)

| Caractéristique | Détail |
|---|---|
| Marchandise | Pré-conditionnée par client |
| Distance | Courte (urbain ou périurbain) |
| Points | 10 à 40 livraisons/jour |
| Optimisation | Ordre des livraisons, créneaux RDV |

> 📌 **Exemple distribution**
>
> Un porteur 12 t avec hayon livre 28 magasins de centre-ville le matin (5 h - 12 h), avec créneaux RDV de 30 minutes par point.

### 1.4 Ligne régulière (navette)

| Caractéristique | Détail |
|---|---|
| Marchandise | Volume stable, récurrent |
| Distance | Tout type, A/R quotidien |
| Points | 1 origine, 1 destination |
| Optimisation | Cadencement, optimisation parc, accord LT |

> 📌 **Exemple ligne régulière**
>
> Une navette quotidienne entre l'usine *Renault Cléon* et le port du Havre, contractualisée sur 24 mois, avec 2 départs par jour matin et après-midi.

---

## 2. Les contraintes à intégrer

### 2.1 Contraintes réglementaires

- **Temps de conduite R561** : 9 h/jour, 56 h/semaine, 90 h/2 sem (cf. BC01-04)
- **Pauses** : 45 min après 4 h 30
- **Repos** : 11 h journalier, 45 h hebdomadaire
- **ADR** : itinéraires obligatoires, parkings dédiés
- **Transport voyageurs** : règles spécifiques (hors GOTRM)

### 2.2 Contraintes commerciales

- **Créneaux RDV** : fenêtre horaire imposée par le client (ex : 8 h - 10 h)
- **Délais** : J+1, J+2, livraison express 4 h
- **Conditions de chargement/déchargement** : hayon, gerbeur, transpalette
- **Interdiction de cabotage** ou règles de cabotage UE (3 opérations en 7 jours)

### 2.3 Contraintes techniques

- **Capacité du véhicule** : poids (PTAC), volume (m³), longueur utile
- **Type de véhicule** : porteur, semi-remorque, frigo, citerne, plateau
- **Accessibilité** : centre-ville, hauteur de pont, gabarit, ZFE
- **Compatibilité marchandise** : ATP (températures), ADR (matières dangereuses)

### 2.4 Contraintes humaines

- **Qualifications conducteur** : permis CE, CQC, ADR, formation hayon
- **Domicile / base** : retour au domicile toutes les 4 sem (paquet mobilité)
- **Préférences ressources** : ancienneté, équilibre charge de travail
- **Convention collective TRM** : amplitudes, repos compensateurs

---

## 3. Les modèles d'optimisation

### 3.1 Le VRP (Vehicle Routing Problem)

Le VRP est le **modèle mathématique** qui formalise le problème de planification de tournées : trouver l'ensemble des tournées minimisant le coût total tout en respectant les contraintes.

| Variante | Spécificité |
|---|---|
| **VRP de base** | 1 dépôt, 1 type de véhicule, capacité simple |
| **CVRP** (Capacitated) | Capacité véhicule contraignante |
| **VRPTW** (Time Windows) | Créneaux horaires imposés |
| **HVRP** (Heterogeneous) | Plusieurs types de véhicules |
| **PDP** (Pickup and Delivery) | Couplage chargement/livraison |

> 💡 **Pourquoi c'est complexe**
>
> Pour 20 points à visiter, il existe 20! ≈ 2,4 × 10¹⁸ ordres possibles. Une recherche exhaustive est impossible. Les algorithmes utilisent donc des **heuristiques** (méthodes approchées) et **métaheuristiques** (recuit simulé, algorithmes génétiques, taboo search).

### 3.2 L'algorithme « plus proche voisin »

Heuristique simple : à chaque étape, aller au point le plus proche non encore visité.

| Avantage | Inconvénient |
|---|---|
| Très rapide | Solution sous-optimale (souvent 15-25 % plus longue) |
| Facile à comprendre | Ne tient pas compte des créneaux RDV |
| Bon point de départ | Risque de « repassage » sur sa route |

### 3.3 L'algorithme « savings » (Clarke-Wright)

Méthode des économies : on regroupe deux clients dans la même tournée si l'économie de distance le justifie.

```
Économie(i,j) = d(dépôt, i) + d(dépôt, j) - d(i, j)
```

On classe toutes les paires par économie décroissante et on les regroupe tant que la capacité du véhicule le permet.

| Avantage | Inconvénient |
|---|---|
| Solution proche de l'optimum (~5 %) | Algorithme plus complexe |
| Intègre la capacité véhicule | Ne gère pas les créneaux par défaut |
| Standard dans les TMS | Calculs longs sur grandes flottes |

### 3.4 Approches modernes (IA / ML)

Les TMS récents intègrent :
- **Recuit simulé** (simulated annealing) : explore l'espace des solutions avec descente progressive de la température.
- **Algorithmes génétiques** : reproduction et mutation de plannings « parents ».
- **Apprentissage par renforcement (RL)** : le système apprend des plannings réels et de leurs résultats.

---

## 4. Vocabulaire professionnel

| Terme | Définition |
|---|---|
| **Tournée** | Ensemble des points visités par un véhicule entre 2 retours au dépôt |
| **Ligne** | Trajet régulier entre 2 points fixes (A/R cadencé) |
| **Navette** | Synonyme de ligne, souvent courte distance |
| **Distribution** | Tournée de plusieurs livraisons en aval |
| **Collecte** | Tournée de plusieurs prises en charge en amont |
| **Pré-acheminement** | Trajet du chargeur vers le hub principal |
| **Post-acheminement** | Trajet du hub vers le destinataire final |
| **Hub-and-spoke** | Modèle de réseau en étoile (un hub central, des rayons) |
| **Cross-docking** | Transbordement direct sans stockage |
| **Slot RDV** | Créneau horaire imposé |
| **Cabotage** | Transport interne fait par un transporteur étranger en UE |

---

## 5. Cas pratique : choix de méthode

**Contexte** : Vous gérez une flotte de 12 véhicules. Pour chacun des cas suivants, identifiez le type de tournée et la méthode de planification adaptée.

| Cas | Type | Méthode |
|---|---|---|
| 22 livraisons en centre-ville matin | Distribution | VRPTW (créneaux RDV) |
| 1 chargement Lille → 1 livraison Marseille | Lot complet (FTL) | Choix itinéraire + fret retour |
| 5 chargements en Alsace pour 1 livraison Lyon | Lot partiel (LTL) | Algorithme « savings » |
| Navette quotidienne Paris ↔ Roissy | Ligne | Cadencement, optimisation horaire |
| Collecte de 8 fournisseurs vers entrepôt | Collecte | VRP + créneaux fournisseurs |

---

> ✅ **À retenir**
>
> - 4 types de tournées : **FTL, LTL, distribution, ligne régulière**.
> - Les contraintes sont **réglementaires + commerciales + techniques + humaines**.
> - Les modèles d'optimisation reposent sur des **heuristiques** (savings, plus proche voisin) et **métaheuristiques** (recuit, génétique).
> - Le VRP avec créneaux (**VRPTW**) est le modèle dominant en distribution.
$lesson1$,
'Types de tournées (FTL, LTL, distribution, ligne), contraintes réglementaires/commerciales/techniques/humaines, modèles VRP/savings/plus proche voisin.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Construction d'une tournée optimale
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Construire une tournée optimale étape par étape',
    'gotrm-bc01-06-02-construction-tournee', 2, 60,
$lesson2$
# Construire une tournée optimale étape par étape

Au-delà des modèles théoriques, il faut **savoir faire** : prendre une demande, allouer un véhicule, ordonner les points, vérifier la conformité. Voici la méthode pas à pas qu'utilise un exploitant performant.

> 🎯 **Objectifs de la leçon**
>
> - Maîtriser les **6 étapes** de construction d'une tournée.
> - Calculer un **temps de tournée** (conduite + arrêts + retour).
> - Vérifier la **conformité R561** d'un planning.
> - Identifier les **leviers d'optimisation** courants.

---

## 1. Les 6 étapes de construction

### Étape 1 — Recueillir et qualifier les commandes

Pour chaque commande, identifier :
- **Origine** et **destination** précises (avec adresse complète et zone)
- **Marchandise** : poids, volume, conditionnement, spécificités (ADR, ATP, hayon)
- **Délai** : date de chargement et de livraison souhaitées
- **Créneaux** : fenêtres RDV imposées (souvent 30 min ou 2 h)
- **Conditions de paiement** : pour les coûts d'attente éventuels

### Étape 2 — Identifier les véhicules disponibles

Lister :
- Véhicules en service (PTAC, type, équipements)
- Conducteurs disponibles (qualifications, temps réglementaire restant)
- Plages horaires libres (compteurs R561)
- Localisation actuelle des véhicules

### Étape 3 — Affecter les commandes aux véhicules

Critères :
- **Compatibilité technique** (capacité, type)
- **Géographie** (commandes proches → même véhicule)
- **Délais compatibles** (créneaux qui s'enchaînent)
- **Équilibrage charge** (éviter qu'un conducteur ait 7 livraisons et un autre 25)

### Étape 4 — Ordonner les points dans la tournée

Méthode pratique :
1. Tracer les points sur une carte (mental ou logiciel).
2. Appliquer le **plus proche voisin** comme premier jet.
3. Identifier les **créneaux RDV** stricts (« je dois être chez X à 9 h »).
4. Réordonner pour respecter les RDV.
5. Vérifier les détours (un point isolé peut justifier un véhicule dédié).

### Étape 5 — Calculer les temps

Pour chaque tronçon :
- **Distance** réelle (Mappy, Waze, TMS)
- **Vitesse moyenne** : 65 km/h autoroute, 50 km/h national, 25 km/h urbain
- **Temps de conduite** par tronçon
- **Temps d'arrêt** : 30 min déchargement standard, 1 h chargement complexe, 15 min livraison express
- **Pauses** : 45 min toutes les 4 h 30

> 📌 **Exemple de calcul**
>
> Tournée Lyon → 4 livraisons en agglo lyonnaise → retour
> - Lyon dépôt → Pt 1 (Villeurbanne) : 8 km, 25 min
> - Déchargement Pt 1 : 30 min
> - Pt 1 → Pt 2 (Bron) : 6 km, 20 min
> - Déchargement Pt 2 : 30 min
> - Pt 2 → Pt 3 (Décines) : 5 km, 15 min
> - Déchargement Pt 3 : 30 min
> - Pt 3 → Pt 4 (Vénissieux) : 7 km, 20 min
> - Déchargement Pt 4 : 30 min
> - Retour dépôt : 12 km, 30 min
>
> Total conduite : 25+20+15+20+30 = 110 min ≈ 1 h 50
> Total arrêts : 30 × 4 = 120 min = 2 h
> Pause R561 ? Non (1 h 50 conduite cumulée < 4 h 30)
> **Temps total tournée : ~ 3 h 50**

### Étape 6 — Vérifier la conformité et publier

Checklist avant validation :

- [ ] Conduite quotidienne ≤ 9 h (10 h si dépassement planifié)
- [ ] Pauses programmées si conduite cumulée > 4 h 30
- [ ] Repos journalier 11 h respecté avant prise de service
- [ ] Capacité véhicule respectée (poids ET volume)
- [ ] Créneaux RDV respectés
- [ ] Marchandises compatibles entre elles (ADR, ATP)
- [ ] Conducteur qualifié (permis, CQC, ADR si nécessaire)

---

## 2. Méthode des « clusters » géographiques

Pour optimiser une distribution multi-stops, on regroupe les points par zones :

| Étape | Action |
|---|---|
| 1 | Découper la zone de livraison en **clusters** (quartiers, communes) |
| 2 | Affecter chaque cluster à un véhicule |
| 3 | À l'intérieur d'un cluster, optimiser l'ordre (plus proche voisin) |
| 4 | Vérifier les créneaux RDV inter-clusters |

> 💡 **Avantage clusters**
>
> Réduit la complexité combinatoire (au lieu de 28 points en VRP : 4 clusters de 7 points). Solution rapidement obtenue, proche de l'optimum.

---

## 3. Le retour à vide : levier majeur

Un véhicule qui rentre à vide après livraison consomme **toute son énergie**, ses pneus, son carburant — pour zéro chiffre d'affaires.

### 3.1 Stratégies pour réduire le retour à vide

| Stratégie | Bénéfice |
|---|---|
| **Fret retour** négocié dès la commande aller | Doublement du CA km |
| **Bourses de fret** (Teleroute, Trans.eu, Timocom) | Trouve des chargements ad-hoc |
| **Tournées en triangle** A → B → C → A | Plus de chargement à chaque étape |
| **Clients réciproques** | A envoie à B et B envoie à A |
| **Cabotage UE** (3 opérations en 7 jours) | Permet flexibilité dans pays UE |

### 3.2 Indicateurs

| Indicateur | Cible |
|---|---|
| **Taux de retour à vide** | < 15 % en TRM longue distance |
| **Ratio km commerciaux / km totaux** | > 85 % |

---

## 4. Cas pratique : optimisation d'une tournée distribution

**Contexte** : *Distrib Express* doit livrer 12 colis en agglomération bordelaise le mardi matin. Véhicule porteur 12 t avec hayon. Conducteur disponible 6 h - 14 h. Dépôt à Mérignac.

### Données

| Pt | Adresse | Créneau | Poids |
|---|---|---|---|
| 1 | Bordeaux centre | 8h-10h | 80 kg |
| 2 | Pessac | 9h-11h | 120 kg |
| 3 | Talence | 9h-12h | 60 kg |
| 4 | Bègles | 10h-12h | 200 kg |
| 5 | Floirac | 8h-12h | 90 kg |
| 6 | Lormont | 10h-14h | 150 kg |
| 7 | Cenon | 9h-12h | 70 kg |
| 8 | Bordeaux Bastide | 10h-13h | 110 kg |
| 9 | Bordeaux Saint-Michel | 9h-11h | 50 kg |
| 10 | Bordeaux Chartrons | 8h-11h | 95 kg |
| 11 | Le Bouscat | 8h-10h | 80 kg |
| 12 | Caudéran | 9h-12h | 105 kg |

### Étapes de planification

1. **Cluster Ouest** (Mérignac → Bouscat → Caudéran → Pessac → Talence)
   - Pt 11 (Le Bouscat 8 h-10 h) → Pt 12 (Caudéran 9 h-12 h) → Pt 2 (Pessac 9 h-11 h) → Pt 3 (Talence 9 h-12 h)

2. **Cluster Centre** (Bordeaux quartiers)
   - Pt 10 (Chartrons 8 h-11 h) → Pt 1 (Centre 8 h-10 h) → Pt 9 (Saint-Michel 9 h-11 h)

3. **Cluster Est rive droite**
   - Pt 8 (Bastide 10 h-13 h) → Pt 7 (Cenon 9 h-12 h) → Pt 6 (Lormont 10 h-14 h) → Pt 5 (Floirac 8 h-12 h) → Pt 4 (Bègles 10 h-12 h)

### Ordre proposé

Mérignac (6 h) → 11 → 12 → 2 → 3 → pause 45 min → 10 → 1 → 9 → 8 → 7 → 6 → 5 → 4 → retour Mérignac (~14 h)

Vérification :
- Conduite cumulée estimée : 4 h
- Arrêts : 12 × 15 min = 3 h
- Pause : 45 min
- **Total : ~ 7 h 45** (faisable dans la fenêtre 6 h - 14 h)

> 💡 **Optimisation possible**
>
> Si on dispose de **deux véhicules**, on peut diviser la tournée en deux (cluster Ouest + cluster Centre/Est), terminer en 4 h chacun, libérer les conducteurs pour une autre tournée l'après-midi. **Productivité doublée** sur le créneau du matin.

---

## 5. Erreurs fréquentes à éviter

| Erreur | Conséquence |
|---|---|
| Oublier la pause R561 dans le calcul | Infraction réglementaire à la prochaine inspection |
| Ne pas réserver une marge de 15 % pour les aléas | Tournée en retard dès le 2e imprévu |
| Négliger les créneaux RDV | Refus de livraison, retours coûteux |
| Surcharger les véhicules en poids ou volume | Amende, refus à la pesée |
| Affecter une marchandise ADR à un conducteur non formé | Infraction grave + immobilisation |

---

> ✅ **À retenir**
>
> - **6 étapes** : recueillir → identifier véhicules → affecter → ordonner → calculer → vérifier.
> - Méthode des **clusters** pour la distribution multi-stops.
> - **Retour à vide < 15 %** est l'objectif d'un exploitant performant.
> - Toujours prévoir une **marge de 15 %** pour les aléas.
> - Vérifier la **conformité R561** avant de publier la tournée.
$lesson2$,
'6 étapes de construction d''une tournée, méthode des clusters, calcul des temps, leviers de réduction du retour à vide et erreurs à éviter.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Outils TMS et télématique
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Outils TMS, télématique et bourses de fret',
    'gotrm-bc01-06-03-tms-telematique', 3, 60,
$lesson3$
# Outils TMS, télématique et bourses de fret

Le métier d'exploitant s'est radicalement transformé en 15 ans avec l'arrivée des **TMS** (Transport Management System), de la **télématique embarquée** et des **bourses de fret en temps réel**. Maîtriser ces outils est aujourd'hui une compétence indispensable.

> 🎯 **Objectifs de la leçon**
>
> - Identifier les **fonctions clés** d'un TMS.
> - Connaître les principaux **logiciels** du marché.
> - Maîtriser les apports de la **télématique embarquée**.
> - Comprendre l'usage des **bourses de fret**.

---

## 1. Le TMS (Transport Management System)

### 1.1 Définition

Un TMS est un logiciel qui couvre tout le cycle de vie d'un transport :
- Saisie des commandes
- Planification des tournées
- Affectation véhicules / conducteurs
- Suivi en temps réel
- Facturation et reporting

### 1.2 Les 6 fonctions principales

| Fonction | Description |
|---|---|
| **Order management** | Saisie commandes, devis, contrats |
| **Planning** | Optimisation tournées (VRP intégré) |
| **Dispatching** | Affectation véhicules + conducteurs |
| **Tracking** | Suivi GPS temps réel + alertes |
| **Documents** | Génération CMR/LV/BL automatique |
| **Reporting** | KPI, facturation, analytique |

### 1.3 Principaux TMS du marché

| Logiciel | Caractéristiques | Cible |
|---|---|---|
| **AlpegaTMS** (ex Wolters Kluwer) | Très complet, modulaire | Moyennes et grandes flottes |
| **Optitrans** | Spécialisé TRM, interface intuitive | PME 5-100 véhicules |
| **Mapotempo** | Open source + cloud, optimisation forte | Distribution urbaine |
| **PTV Map&Guide** | Calcul d'itinéraires PL référence | Toutes tailles |
| **Astre TMS** (Akanea) | TMS coopératif réseau Astre | Adhérents Astre |
| **Dispatcher Pro** | TMS cloud SaaS | PME 10-50 véhicules |
| **Ortec** | TMS ETI/grande entreprise | 50+ véhicules |
| **Transwide / Transporeon** | Plateforme collaborative | Donneurs d'ordre + transporteurs |

### 1.4 Architecture type

```
[Commande client] ──> [Module Orders TMS]
                         │
                         ▼
[Module Planning] ──> [Algorithme VRP]
                         │
                         ▼
[Dispatching] ──> [App conducteur smartphone]
                    │
                    ▼
[Télématique] <──> [Tracking serveur]
                    │
                    ▼
[Facturation] ──> [Comptabilité ERP]
```

---

## 2. La télématique embarquée

### 2.1 Principe

Boîtier installé dans le véhicule qui collecte et transmet en temps réel :
- Position GPS
- Vitesse, accélération, freinage
- Consommation carburant
- Température (frigo)
- Données moteur (CAN bus)
- Données tachygraphe (téléchargement à distance)

### 2.2 Apports métier

| Apport | Bénéfice |
|---|---|
| Tracking client temps réel | Réduit les appels « où en est ma livraison ? » |
| ETA calculé automatiquement | Anticipation des retards |
| Téléchargement tachygraphe à distance | Plus de retour à la base nécessaire |
| Eco-conduite (score conducteur) | Réduction conso 5-12 % |
| Alertes vol / hors zone | Sécurité et récupération |
| Géofencing | Notifications automatiques arrivée/départ |

### 2.3 Principaux fournisseurs

| Solution | Particularité |
|---|---|
| **FleetBoard** (Daimler/Mercedes) | Intégré aux camions Mercedes |
| **Volvo Dynafleet** | Intégré camions Volvo |
| **Scania Connected Services** | Intégré camions Scania |
| **Continental VDO** | Compatible toutes marques (boîtier additionnel) |
| **Frotcom** | Solution cloud multimarque |
| **Geotab** | Leader mondial, open platform |
| **Microlise** | UK + France |

### 2.4 Coût typique

| Poste | Coût indicatif |
|---|---|
| Boîtier (acquisition) | 200 - 500 € HT |
| Installation | 100 - 200 € HT |
| Abonnement mensuel | 15 - 35 € HT/véhicule |
| ROI moyen | 6 à 12 mois |

---

## 3. Les bourses de fret

### 3.1 Principe

Plateforme en ligne où :
- **Chargeurs / commissionnaires** publient des **fret disponibles** (offres)
- **Transporteurs** publient leurs **véhicules disponibles** (capacités)

Les deux parties se rencontrent en temps réel pour combler les retours à vide ou réagir à des urgences.

### 3.2 Principales bourses européennes

| Plateforme | Implantation |
|---|---|
| **Teleroute** (groupe Wolters Kluwer) | UE étendue, historique 1985 |
| **Trans.eu** | Pologne, Europe centrale et UE |
| **Timocom** | Allemagne, leader DACH |
| **B2Pweb** | Spécialisé France TRM |
| **Wtransnet** | Espagne et Sud Europe |
| **Convargo / Shippeo** | Plus orienté visibilité |

### 3.3 Bonnes pratiques d'utilisation

| Bonne pratique | Pourquoi |
|---|---|
| Vérifier la **fiche entreprise** (KBIS, licence, ancienneté, notes) | Éviter les fraudeurs |
| Demander **assurance et licence transport** par mail avant chargement | Conformité et protection juridique |
| Privilégier les **abonnements payants** (qualité ↑) aux modèles gratuits | Plus de garanties, moins de fraudes |
| **Négocier le prix au km** plutôt qu'au forfait | Plus de transparence |
| Documenter chaque mission (photos, CMR signée, RIB vérifié) | Traçabilité, recours possible |

> ⚠️ **Fraudes sur bourses de fret**
>
> Le secteur connaît des **fraudes récurrentes** : faux transporteurs, vol de cargaison, sous-traitance en cascade. Chaque année, plusieurs millions d'euros de marchandises disparaissent. Vérification systématique recommandée.

---

## 4. Géolocalisation et confidentialité (RGPD)

### 4.1 Données traitées

La télématique collecte des **données personnelles du conducteur** : géolocalisation, heures de conduite, comportements. C'est soumis au **RGPD** (Règlement UE 2016/679).

### 4.2 Obligations employeur

| Obligation | Détail |
|---|---|
| **Information préalable** | Notice claire remise au conducteur avant installation |
| **Consultation CSE** | Obligatoire si entreprise > 11 salariés |
| **Déclaration CNIL** | Plus nécessaire mais inscription au registre des traitements |
| **DPO** (Délégué à la Protection des Données) | Recommandé si > 50 salariés ou traitements à grande échelle |
| **Finalité légitime** | Sécurité, optimisation, paie — pas surveillance générale |
| **Durée de conservation** | Limitée (1 mois standard pour la position, sauf incident) |

### 4.3 Limites

- **Pas de surveillance permanente** : la position en temps réel n'est consultable que pour les besoins métier.
- **Pas d'utilisation à des fins disciplinaires** sans information préalable et procédure contradictoire.
- **Vie privée** : pas de tracking pendant les pauses et repos personnels (hors véhicule).

> 💡 **Bonne pratique**
>
> Faire signer au conducteur une **charte télématique** dès l'embauche, expliquant : ce qui est collecté, à quelles fins, qui peut consulter, combien de temps c'est conservé, comment exercer ses droits (accès, rectification, opposition).

---

## 5. Cas pratique : déploiement d'un TMS

**Contexte** : *Trans-Sud Toulouse* (35 véhicules, 28 conducteurs, 4,2 M€ CA) souhaite passer d'un planning Excel manuel à un TMS cloud. Démarche.

### Étape 1 — Cahier des charges (semaine 1-3)

- Volumes : 250 commandes/semaine, 80 % distribution, 20 % FTL
- Besoins clés : optimisation tournées, app conducteur, intégration ERP comptable
- Budget : 15 - 25 k€/an SaaS
- Critères : interface FR, support 7j/7, hébergement EU (RGPD)

### Étape 2 — Présélection (semaine 4-6)

Démos chez 4 éditeurs (Optitrans, AlpegaTMS, Dispatcher Pro, Mapotempo) sur les **3 cas d'usage** prioritaires :
1. Planification d'une tournée distribution 25 points
2. Suivi temps réel d'une tournée FTL avec retard
3. Génération automatique CMR + facture

### Étape 3 — Pilote (semaine 7-12)

- 5 véhicules en test sur 2 mois
- Mesure des KPI avant/après (productivité conducteur, taux remplissage, % livraisons à l'heure)
- Retours utilisateurs (exploitants, conducteurs)

### Étape 4 — Déploiement (semaine 13-20)

- Vague 1 : conducteurs longue distance (10 véhicules)
- Vague 2 : distribution urbaine (15 véhicules)
- Vague 3 : ligne régulière (10 véhicules)
- Formations 2 jours par groupe

### Étape 5 — Stabilisation (semaine 21-26)

- Suivi quotidien adoption
- Hotline interne dédiée
- Adaptations paramétrage selon retours
- Mesure ROI à 6 mois

### ROI attendu

| Indicateur | Avant | Après pilote |
|---|---|---|
| Productivité (commandes/exploitant) | 60/jour | 95/jour (+58 %) |
| Taux remplissage moyen | 78 % | 86 % (+8 pts) |
| % livraisons à l'heure | 88 % | 96 % (+8 pts) |
| Heures planning hebdo (exploitation) | 65 h | 38 h (-27 h) |
| Économies estimées an 1 | — | 75 k€ (carburant, productivité, qualité) |

---

> ✅ **À retenir**
>
> - Un **TMS** couvre 6 fonctions : orders, planning, dispatching, tracking, documents, reporting.
> - La **télématique** apporte traçabilité, éco-conduite et téléchargement tachygraphe à distance (ROI 6-12 mois).
> - **Bourses de fret** : Teleroute, Trans.eu, Timocom, B2Pweb — utiles mais vigilance fraudes.
> - **RGPD** s'applique à la télématique : information conducteur, consultation CSE, finalité légitime.
$lesson3$,
'TMS (6 fonctions, principaux éditeurs), télématique embarquée (apports, fournisseurs, coûts), bourses de fret (Teleroute, Trans.eu, Timocom, B2Pweb), RGPD et déploiement.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — KPI de planification et amélioration continue
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'KPI de planification et amélioration continue',
    'gotrm-bc01-06-04-kpi-amelioration', 4, 50,
$lesson4$
# KPI de planification et amélioration continue

Sans mesure, pas d'amélioration. L'exploitant performant pilote sa planification avec des **KPI précis**, les analyse régulièrement et met en place des **plans d'action** pour progresser.

> 🎯 **Objectifs de la leçon**
>
> - Connaître les **KPI clés** de la planification.
> - Calculer le **taux de remplissage**, le **taux de retour à vide**, la **ponctualité**.
> - Construire un **tableau de bord** exploitant.
> - Lancer une **boucle d'amélioration** PDCA.

---

## 1. Les KPI essentiels

### 1.1 Taux de remplissage

```
Taux de remplissage poids = Poids transporté / PTAC × 100
Taux de remplissage volume = Volume transporté / Volume utile × 100
```

| Niveau | Performance |
|---|---|
| < 70 % | Critique — revoir le sourcing |
| 70 - 80 % | Acceptable — marges à conquérir |
| 80 - 90 % | Bon |
| > 90 % | Excellent (attention aux dépassements ponctuels) |

> ⚠️ **Attention**
>
> Surveiller le **maximum** des deux indicateurs (poids OU volume). Un véhicule de mousse peut être plein en volume à 65 % du poids — c'est le volume qui sature.

### 1.2 Taux de retour à vide

```
Taux de retour à vide = Km à vide / Km totaux × 100
```

| Niveau | Performance TRM longue distance |
|---|---|
| > 25 % | Critique |
| 15 - 25 % | Acceptable |
| 10 - 15 % | Bon |
| < 10 % | Excellent (rare en FTL pure) |

### 1.3 Ponctualité (livraisons à l'heure)

```
Ponctualité = Livraisons dans la fenêtre RDV / Livraisons totales × 100
```

| Niveau | Performance |
|---|---|
| < 90 % | Critique — risque perte client |
| 90 - 95 % | Acceptable |
| 95 - 98 % | Bon |
| > 98 % | Excellent |

> 💡 **Pourquoi c'est crucial**
>
> 1 % de ponctualité supplémentaire vaut souvent **plus** qu'1 % de marge brute pour un client. La ponctualité conditionne la **fidélisation** et limite les **pénalités** contractuelles.

### 1.4 Productivité tournée

```
Productivité = Nombre de points livrés / Heure de service
```

| Type | Cible |
|---|---|
| Distribution urbaine | 4 - 6 points/h |
| Distribution périurbaine | 2,5 - 4 points/h |
| Distribution régionale | 1 - 2 points/h |

### 1.5 Ratio km commercial / km total

```
Ratio km commercial = Km chargés / Km totaux × 100
```

Cible : **> 85 %** en TRM longue distance, **> 70 %** en distribution.

### 1.6 Consommation moyenne

```
Conso moyenne = Litres consommés / 100 km
```

| Type véhicule | Cible |
|---|---|
| Porteur 19 t cycle régional | 26 - 30 L/100 km |
| Tracteur + remorque longue distance | 28 - 33 L/100 km |
| Distribution urbaine 12 t | 22 - 28 L/100 km |

### 1.7 Coût km commercial

```
Coût km commercial = Coût total mensuel / Km commerciaux mensuels
```

À comparer au prix moyen de vente. La marge se trouve dans l'écart.

---

## 2. Tableau de bord exploitation

Un **tableau de bord type** d'exploitant regroupe les KPI sur un format visuel hebdomadaire ou mensuel :

| KPI | Sem 1 | Sem 2 | Sem 3 | Sem 4 | Cible | Statut |
|---|---|---|---|---|---|---|
| Taux remplissage poids | 82 % | 85 % | 79 % | 83 % | > 85 % | 🟧 |
| Taux retour à vide | 18 % | 16 % | 22 % | 17 % | < 15 % | 🟧 |
| Ponctualité livraison | 95 % | 96 % | 92 % | 97 % | > 95 % | 🟩 |
| Conso moyenne | 28,5 | 29,1 | 30,2 | 28,9 | < 29 | 🟧 |
| Coût km commercial | 1,38 | 1,35 | 1,42 | 1,36 | < 1,40 | 🟩 |
| Productivité (points/h) | 3,8 | 4,1 | 3,6 | 4,0 | > 4,0 | 🟧 |

> 📌 **Code couleur**
>
> 🟩 Vert = cible atteinte
> 🟧 Orange = entre cible et seuil critique
> 🟥 Rouge = sous seuil critique, action immédiate

---

## 3. La boucle d'amélioration PDCA

### 3.1 Le cycle Plan-Do-Check-Act

| Étape | Action |
|---|---|
| **Plan** | Identifier un problème, fixer un objectif, définir un plan d'action |
| **Do** | Mettre en œuvre le plan sur un périmètre pilote |
| **Check** | Mesurer les résultats, comparer aux attendus |
| **Act** | Standardiser si succès, ajuster si écart |

### 3.2 Exemple PDCA — réduction du retour à vide

**Plan** : Le taux de retour à vide est à 22 %, cible 15 %. Plan : abonnement Teleroute + formation des 4 exploitants à la recherche de fret retour.

**Do** : Démarrage le 1er du mois suivant. Tableau de suivi quotidien des fret retour trouvés.

**Check** : Au bout de 8 semaines, le retour à vide est passé à **17 %** (gain 5 pts). Le coût de l'abonnement (550 €/mois) est largement compensé par les fret additionnels (~12 000 €/mois).

**Act** : Standardiser la pratique. Étendre aux 8 autres conducteurs. Former une 5e personne.

---

## 4. Outils d'analyse

### 4.1 Diagramme de Pareto

Identifier les **20 % de causes** qui expliquent **80 % des problèmes**.

> 📌 **Exemple Pareto sur les retards**
>
> Sur 240 retards constatés en 6 mois :
> - 95 retards (40 %) : trafic urbain Paris
> - 58 retards (24 %) : attente déchargement client X (problème de quai)
> - 32 retards (13 %) : pannes mécaniques véhicules > 8 ans
> - 22 retards (9 %) : douanes Brexit
> - 33 retards (14 %) : autres causes diverses
>
> **Action prioritaire** : revoir tournée Paris + négocier quai dédié client X = **64 % des retards éliminés**.

### 4.2 Diagramme d'Ishikawa (causes-effet)

Outil visuel pour identifier toutes les causes d'un problème, classées en **5M** :
- **Main d'œuvre** (compétences, formation)
- **Matériel** (véhicules, équipements)
- **Méthode** (procédures, planification)
- **Milieu** (trafic, météo, infra)
- **Mesure** (fiabilité des données)

### 4.3 5 pourquoi (5 Why)

Méthode d'**analyse de cause racine** : on demande « pourquoi ? » 5 fois jusqu'à arriver à la cause profonde.

> 📌 **Exemple 5 pourquoi**
>
> **Problème** : 12 % des livraisons distribution sont en retard.
> 1. Pourquoi ? → Les conducteurs partent en retard.
> 2. Pourquoi ? → Les chargements prennent trop de temps le matin.
> 3. Pourquoi ? → Les caristes n'ont pas tout préparé la veille.
> 4. Pourquoi ? → Les ordres de tournée arrivent à 17 h, le quai ferme à 17 h 30.
> 5. Pourquoi ? → Les commandes clients du jour J pour J+1 sont validées tard par les commerciaux.
>
> **Cause racine** : flux de validation commerciale tardif.
> **Action** : avancer le cut-off à 15 h.

---

## 5. Cas pratique : plan d'amélioration tournée

**Contexte** : Vous gérez la flotte d'*Express Atlantique* (22 véhicules). Les chiffres T1 sont mauvais :
- Taux retour à vide : 24 %
- Ponctualité : 89 %
- Coût km commercial : 1,52 € (cible 1,40 €)
- Plaintes client : 18 réclamations en 3 mois

### Diagnostic Pareto

| Cause de coût élevé | Poids |
|---|---|
| Retour à vide important | 40 % |
| Sur-utilisation conducteur senior coûteux sur tournées simples | 25 % |
| Maintenance corrective non programmée | 18 % |
| Pénalités retard | 9 % |
| Frais structure | 8 % |

### Plan d'action 6 mois

| # | Action | Cible | Échéance |
|---|---|---|---|
| 1 | Souscription bourse de fret + formation | Retour à vide < 17 % | M+2 |
| 2 | Réaffectation conducteurs senior aux longue distance, juniors en distribution | Coût horaire optimisé | M+1 |
| 3 | Plan maintenance préventive (60 % préventif vs 40 % aujourd'hui) | Pannes -50 % | M+3 |
| 4 | Sécurisation 5 plus gros clients (avenants, RDV fixes) | Pénalités -70 % | M+2 |
| 5 | TMS de planification (Optitrans pilote) | Productivité +20 % | M+6 |

### Suivi mensuel

Tableau de bord avec les 6 KPI principaux, revue mensuelle direction, ajustements trimestriels.

### Résultat attendu (M+6)

- Taux retour à vide : **15 %** (vs 24 %) → +180 k€/an
- Coût km commercial : **1,38 €** (vs 1,52 €) → +120 k€/an
- Ponctualité : **96 %** → réduction réclamations & pénalités
- Marge nette : **9,5 %** (vs 5 %)

---

> ✅ **À retenir**
>
> - 6 KPI essentiels : remplissage, retour à vide, ponctualité, productivité, conso, coût km.
> - **Tableau de bord** hebdomadaire ou mensuel avec **code couleur** (vert/orange/rouge).
> - **PDCA** : Plan-Do-Check-Act pour toute amélioration.
> - **Pareto, Ishikawa, 5 pourquoi** : outils d'analyse de cause racine.
> - **Cible TRM longue distance** : remplissage > 85 %, retour à vide < 15 %, ponctualité > 95 %.
$lesson4$,
'KPI essentiels (remplissage, retour à vide, ponctualité, productivité, coût km), tableau de bord, boucle PDCA, outils d''analyse Pareto/Ishikawa/5 pourquoi.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- 28 QCM REFORMULÉS
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qcm', 'Une tournée FTL (Full Truck Load) se caractérise par :', '[{"id":"a","label":"Plusieurs petits chargements regroupés","is_correct":false},{"id":"b","label":"Un seul chargement remplissant le véhicule, 1 origine 1 destination","is_correct":true},{"id":"c","label":"Une distribution multi-points en centre-ville","is_correct":false},{"id":"d","label":"Une navette quotidienne sur trajet fixe","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['ftl','types-tournees'], 'mft-2026-gotrm:bc01-06:qcm:1', true, 'Le FTL (Full Truck Load) est un lot complet : un seul chargement remplit le véhicule, généralement entre une origine unique et une destination unique sur longue distance. Distinct du LTL (lot partiel) et de la distribution.'),
  (v_formation, 'qcm', 'Le sigle VRP en planification de tournées signifie :', '[{"id":"a","label":"Vehicle Routing Problem","is_correct":true},{"id":"b","label":"Vehicle Resource Planning","is_correct":false},{"id":"c","label":"Visite Régionale Prévisionnelle","is_correct":false},{"id":"d","label":"Variable Routing Procedure","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['vrp','vocabulaire'], 'mft-2026-gotrm:bc01-06:qcm:2', true, 'VRP = Vehicle Routing Problem. C''est le modèle mathématique qui formalise le problème de planification de tournées. Le VRPTW (Time Windows) ajoute les créneaux horaires.'),
  (v_formation, 'qcm', 'Pour un retour à vide en TRM longue distance, le taux considéré comme "bon" est :', '[{"id":"a","label":"Inférieur à 5 %","is_correct":false},{"id":"b","label":"Entre 10 % et 15 %","is_correct":true},{"id":"c","label":"Entre 25 % et 35 %","is_correct":false},{"id":"d","label":"Entre 40 % et 50 %","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['kpi','retour-vide'], 'mft-2026-gotrm:bc01-06:qcm:3', true, 'En TRM longue distance, un taux de retour à vide entre 10 et 15 % est considéré comme bon. Au-delà de 25 %, la rentabilité est compromise. Sous 10 %, c''est excellent (rare en FTL pure).'),
  (v_formation, 'qcm', 'L''algorithme du "plus proche voisin" en planification consiste à :', '[{"id":"a","label":"Affecter chaque tournée au véhicule le plus proche","is_correct":false},{"id":"b","label":"À chaque étape, aller au point non visité le plus proche du dernier point","is_correct":true},{"id":"c","label":"Affecter les commandes par ordre chronologique","is_correct":false},{"id":"d","label":"Minimiser le poids transporté par véhicule","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['algorithme','plus-proche-voisin'], 'mft-2026-gotrm:bc01-06:qcm:4', true, 'Le plus proche voisin (nearest neighbor) est une heuristique simple : à chaque étape, on choisit le point non visité le plus proche du dernier point parcouru. Rapide mais sous-optimal (15-25 % d''écart à l''optimum).'),
  (v_formation, 'qcm', 'L''algorithme "savings" de Clarke-Wright consiste à :', '[{"id":"a","label":"Économiser du carburant en limitant la vitesse","is_correct":false},{"id":"b","label":"Regrouper deux clients dans une tournée si l''économie de distance le justifie","is_correct":true},{"id":"c","label":"Diminuer les coûts de structure","is_correct":false},{"id":"d","label":"Choisir des transporteurs moins chers","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['algorithme','savings'], 'mft-2026-gotrm:bc01-06:qcm:5', true, 'Savings = méthode des économies. On calcule pour chaque paire (i,j) : Économie = d(dépôt,i) + d(dépôt,j) - d(i,j). On regroupe les paires par économie décroissante tant que la capacité véhicule le permet. Standard dans les TMS.'),
  (v_formation, 'qcm', 'La méthode des "clusters" en distribution multi-stops consiste à :', '[{"id":"a","label":"Regrouper les véhicules sur le parking dépôt","is_correct":false},{"id":"b","label":"Découper la zone en sous-zones et affecter chaque sous-zone à un véhicule","is_correct":true},{"id":"c","label":"Augmenter le nombre de véhicules","is_correct":false},{"id":"d","label":"Doubler les conducteurs","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['clusters','distribution'], 'mft-2026-gotrm:bc01-06:qcm:6', true, 'La méthode des clusters découpe géographiquement la zone à couvrir en sous-ensembles, chaque cluster étant traité par un véhicule. Réduit la complexité combinatoire et donne rapidement des solutions proches de l''optimum.'),
  (v_formation, 'qcm', 'Une marge de sécurité standard à intégrer dans une planification pour absorber les aléas est de :', '[{"id":"a","label":"5 %","is_correct":false},{"id":"b","label":"15 %","is_correct":true},{"id":"c","label":"30 %","is_correct":false},{"id":"d","label":"50 %","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['planification','marge'], 'mft-2026-gotrm:bc01-06:qcm:7', true, 'Une marge de 15 % du temps total est généralement recommandée pour absorber les aléas (trafic, attente, formalités). Trop faible, le planning explose au moindre incident ; trop élevée, on sous-utilise les ressources.'),
  (v_formation, 'qcm', 'Un TMS (Transport Management System) couvre principalement :', '[{"id":"a","label":"Uniquement la facturation","is_correct":false},{"id":"b","label":"6 fonctions : orders, planning, dispatching, tracking, documents, reporting","is_correct":true},{"id":"c","label":"La gestion RH des conducteurs","is_correct":false},{"id":"d","label":"Uniquement la planification","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['tms','fonctions'], 'mft-2026-gotrm:bc01-06:qcm:8', true, 'Un TMS complet couvre les 6 fonctions clés du transport : saisie commandes, planning des tournées, dispatching véhicules/conducteurs, tracking GPS, génération documents (CMR/LV/BL), reporting et facturation.'),
  (v_formation, 'qcm', 'La télématique embarquée permet typiquement :', '[{"id":"a","label":"De remplacer le tachygraphe officiel","is_correct":false},{"id":"b","label":"De géolocaliser, mesurer la conduite, télécharger le tachygraphe à distance","is_correct":true},{"id":"c","label":"D''augmenter la vitesse maximale du véhicule","is_correct":false},{"id":"d","label":"De supprimer la carte conducteur","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['telematique','fonctions'], 'mft-2026-gotrm:bc01-06:qcm:9', true, 'La télématique apporte : géolocalisation temps réel, mesure de la conduite (éco-conduite), téléchargement tachygraphe à distance (gain de temps), alertes sécurité, données moteur. Elle ne remplace ni le tachygraphe ni la carte, qui restent obligatoires.'),
  (v_formation, 'qcm', 'Parmi ces plateformes, laquelle est une bourse de fret ?', '[{"id":"a","label":"FleetBoard","is_correct":false},{"id":"b","label":"Teleroute","is_correct":true},{"id":"c","label":"Optitrans","is_correct":false},{"id":"d","label":"PTV Map&Guide","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['bourses-fret'], 'mft-2026-gotrm:bc01-06:qcm:10', true, 'Teleroute est une bourse de fret européenne historique (1985, groupe Wolters Kluwer). FleetBoard est une télématique Mercedes, Optitrans un TMS, PTV Map&Guide un calculateur d''itinéraires PL.'),
  (v_formation, 'qcm', 'Pour un porteur 19 t en cycle régional, la consommation moyenne attendue est de :', '[{"id":"a","label":"15 - 20 L/100 km","is_correct":false},{"id":"b","label":"26 - 30 L/100 km","is_correct":true},{"id":"c","label":"40 - 45 L/100 km","is_correct":false},{"id":"d","label":"55 - 60 L/100 km","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['conso','porteur'], 'mft-2026-gotrm:bc01-06:qcm:11', true, 'Un porteur 19 t en cycle régional consomme typiquement 26-30 L/100 km. Un tracteur+remorque longue distance : 28-33 L. Une distribution urbaine 12 t : 22-28 L. Variation selon profil de route, charge, conducteur.'),
  (v_formation, 'qcm', 'Une fenêtre RDV stricte signifie :', '[{"id":"a","label":"Un horaire indicatif modifiable librement","is_correct":false},{"id":"b","label":"Un créneau horaire imposé par le client (ex : 8h-10h)","is_correct":true},{"id":"c","label":"Le repos journalier du conducteur","is_correct":false},{"id":"d","label":"Une réunion d''exploitation hebdomadaire","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['rdv','creneau'], 'mft-2026-gotrm:bc01-06:qcm:12', true, 'Un slot ou créneau RDV est une fenêtre horaire imposée par le client (typiquement 30 min à 4 h). Le respecter est essentiel : un retard peut entraîner refus de livraison, retour, et pénalités contractuelles.'),
  (v_formation, 'qcm', 'Le taux de remplissage en volume d''un véhicule se calcule comme :', '[{"id":"a","label":"Volume transporté / PTAC × 100","is_correct":false},{"id":"b","label":"Volume transporté / Volume utile × 100","is_correct":true},{"id":"c","label":"Poids transporté / Volume utile × 100","is_correct":false},{"id":"d","label":"Nombre de palettes / Surface au sol","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['kpi','remplissage'], 'mft-2026-gotrm:bc01-06:qcm:13', true, 'Taux de remplissage volume = Volume transporté / Volume utile × 100. À ne pas confondre avec le taux de remplissage poids (qui rapporte au PTAC). Le KPI réel est le maximum des deux : le véhicule est plein dès qu''une dimension atteint 100 %.'),
  (v_formation, 'qcm', 'En ponctualité de livraison, un seuil considéré comme "critique" et risque pour la fidélisation client est :', '[{"id":"a","label":"Inférieur à 99 %","is_correct":false},{"id":"b","label":"Inférieur à 90 %","is_correct":true},{"id":"c","label":"Inférieur à 80 %","is_correct":false},{"id":"d","label":"Inférieur à 50 %","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['kpi','ponctualite'], 'mft-2026-gotrm:bc01-06:qcm:14', true, 'Un taux de ponctualité < 90 % met sérieusement en péril la relation client : pénalités contractuelles, refus de livraisons, perte d''appels d''offres. Cible standard : > 95 %, excellent : > 98 %.'),
  (v_formation, 'qcm', 'Le cycle PDCA en amélioration continue désigne :', '[{"id":"a","label":"Plan / Do / Check / Act","is_correct":true},{"id":"b","label":"Procurement / Delivery / Control / Audit","is_correct":false},{"id":"c","label":"Plan / Distribute / Calculate / Adjust","is_correct":false},{"id":"d","label":"Process / Decide / Confirm / Apply","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['pdca','amelioration'], 'mft-2026-gotrm:bc01-06:qcm:15', true, 'PDCA = Plan (planifier le changement), Do (exécuter sur un pilote), Check (vérifier les résultats), Act (standardiser ou ajuster). Méthode universelle d''amélioration continue (W. E. Deming).'),
  (v_formation, 'qcm', 'Le diagramme de Pareto repose sur l''idée que :', '[{"id":"a","label":"Toutes les causes ont le même poids","is_correct":false},{"id":"b","label":"20 % des causes expliquent 80 % des effets","is_correct":true},{"id":"c","label":"Les problèmes sont aléatoires","is_correct":false},{"id":"d","label":"Il faut tout traiter en même temps","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['pareto','80-20'], 'mft-2026-gotrm:bc01-06:qcm:16', true, 'Le principe de Pareto (loi 80/20) postule que 20 % des causes produisent 80 % des effets. En planification : 20 % des clients génèrent 80 % du CA, 20 % des problèmes causent 80 % des retards.'),
  (v_formation, 'qcm', 'Le diagramme d''Ishikawa classe les causes selon les "5M". Lequel n''en fait PAS partie ?', '[{"id":"a","label":"Main d''œuvre","is_correct":false},{"id":"b","label":"Méthode","is_correct":false},{"id":"c","label":"Marketing","is_correct":true},{"id":"d","label":"Milieu","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['ishikawa','5m'], 'mft-2026-gotrm:bc01-06:qcm:17', true, 'Les 5M sont : Main d''œuvre, Matériel, Méthode, Milieu, Mesure. Marketing n''en fait pas partie. Ishikawa (arête de poisson) sert à identifier toutes les causes possibles d''un problème.'),
  (v_formation, 'qcm', 'La méthode des "5 pourquoi" sert à :', '[{"id":"a","label":"Lister 5 problèmes prioritaires","is_correct":false},{"id":"b","label":"Trouver la cause racine d''un problème en posant 5 fois la question pourquoi","is_correct":true},{"id":"c","label":"Faire 5 réunions de débrief","is_correct":false},{"id":"d","label":"Demander 5 devis avant achat","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['5-pourquoi','cause-racine'], 'mft-2026-gotrm:bc01-06:qcm:18', true, 'Les 5 pourquoi (Toyota) consistent à demander itérativement « pourquoi ? » jusqu''à atteindre la cause racine. Souvent 5 itérations suffisent pour passer du symptôme à la cause profonde.'),
  (v_formation, 'qcm', 'En cabotage UE, un transporteur étranger peut effectuer dans un pays UE :', '[{"id":"a","label":"Un nombre illimité d''opérations","is_correct":false},{"id":"b","label":"Maximum 3 opérations dans les 7 jours suivant le déchargement international","is_correct":true},{"id":"c","label":"Une seule opération par mois","is_correct":false},{"id":"d","label":"Aucune opération autorisée","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['cabotage','reglementation'], 'mft-2026-gotrm:bc01-06:qcm:19', true, 'Le cabotage en UE est limité à 3 opérations dans les 7 jours suivant un transport international (règlement 1072/2009). Au-delà, c''est du transport intérieur soumis à licence locale.'),
  (v_formation, 'qcm', 'Le RGPD s''applique-t-il à la télématique embarquée des véhicules ?', '[{"id":"a","label":"Non, c''est de la simple gestion de flotte","is_correct":false},{"id":"b","label":"Oui, car des données personnelles du conducteur sont collectées (géolocalisation, conduite)","is_correct":true},{"id":"c","label":"Uniquement si l''entreprise dépasse 250 salariés","is_correct":false},{"id":"d","label":"Uniquement à l''export hors UE","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['rgpd','telematique'], 'mft-2026-gotrm:bc01-06:qcm:20', true, 'La télématique collecte des données personnelles du conducteur (géolocalisation, comportement, temps). Le RGPD s''applique : information préalable, consultation CSE, registre des traitements, finalité légitime, durée conservation limitée.'),
  (v_formation, 'qcm', 'En distribution urbaine, une productivité standard attendue est de :', '[{"id":"a","label":"0,5 - 1 point/heure","is_correct":false},{"id":"b","label":"1 - 2 points/heure","is_correct":false},{"id":"c","label":"4 - 6 points/heure","is_correct":true},{"id":"d","label":"15 - 20 points/heure","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['kpi','productivite'], 'mft-2026-gotrm:bc01-06:qcm:21', true, 'En distribution urbaine, on attend 4 à 6 points livrés par heure de service. En périurbain : 2,5-4. En régional : 1-2. La densité urbaine compense les distances courtes par la difficulté de stationnement et de circulation.'),
  (v_formation, 'qcm', 'L''avantage principal du modèle "hub-and-spoke" est :', '[{"id":"a","label":"Éliminer le besoin de véhicules","is_correct":false},{"id":"b","label":"Mutualiser les flux par un hub central pour optimiser la consolidation","is_correct":true},{"id":"c","label":"Supprimer les conducteurs","is_correct":false},{"id":"d","label":"Faire baisser le carburant à la pompe","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['hub-spoke','reseau'], 'mft-2026-gotrm:bc01-06:qcm:22', true, 'Le modèle hub-and-spoke (étoile) consolide les flux de plusieurs origines vers un hub central, puis redistribue depuis ce hub vers les destinations finales. Optimise le remplissage, mutualise les ressources, baisse les coûts unitaires.'),
  (v_formation, 'qcm', 'Le cross-docking se définit comme :', '[{"id":"a","label":"Un croisement de deux véhicules sur une voie étroite","is_correct":false},{"id":"b","label":"Un transbordement direct au quai sans stockage intermédiaire","is_correct":true},{"id":"c","label":"Un passage de douanes accéléré","is_correct":false},{"id":"d","label":"Une procédure d''embarquement maritime","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['cross-docking'], 'mft-2026-gotrm:bc01-06:qcm:23', true, 'Cross-docking = transbordement direct quai à quai sans passer par un stock. La marchandise arrive d''un côté, est triée, et repart de l''autre côté sous quelques heures. Optimise le BFR et accélère la chaîne logistique.'),
  (v_formation, 'qcm', 'Pour 22 livraisons en zone urbaine avec créneaux RDV stricts, le modèle de planification le plus adapté est :', '[{"id":"a","label":"Plus proche voisin simple","is_correct":false},{"id":"b","label":"VRPTW (Vehicle Routing Problem with Time Windows)","is_correct":true},{"id":"c","label":"FTL (Full Truck Load)","is_correct":false},{"id":"d","label":"Hub-and-spoke","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['vrptw','distribution'], 'mft-2026-gotrm:bc01-06:qcm:24', true, 'Le VRPTW intègre les créneaux horaires comme contrainte forte. C''est le modèle dominant en distribution multi-stops avec RDV. Le plus proche voisin seul ignorerait les fenêtres et générerait des retards.'),
  (v_formation, 'qcm', 'Le ratio km commercial / km total cible en TRM longue distance est :', '[{"id":"a","label":"> 50 %","is_correct":false},{"id":"b","label":"> 70 %","is_correct":false},{"id":"c","label":"> 85 %","is_correct":true},{"id":"d","label":"> 99 %","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['kpi','ratio'], 'mft-2026-gotrm:bc01-06:qcm:25', true, 'En TRM longue distance, on vise un ratio km commercial / km total > 85 %. En distribution, > 70 % est un bon objectif. Plus le ratio est élevé, moins de km sont à vide ou de repositionnement.'),
  (v_formation, 'qcm', 'Quel outil n''est PAS un TMS ?', '[{"id":"a","label":"Optitrans","is_correct":false},{"id":"b","label":"AlpegaTMS","is_correct":false},{"id":"c","label":"Mapotempo","is_correct":false},{"id":"d","label":"Trans.eu","is_correct":true}]'::jsonb, 1, 'moyen', ARRAY['tms','distinction'], 'mft-2026-gotrm:bc01-06:qcm:26', true, 'Trans.eu est une bourse de fret (Pologne / UE), pas un TMS. Optitrans, AlpegaTMS et Mapotempo sont des TMS. Le TMS gère le cycle complet du transport, la bourse de fret met en relation chargeurs et transporteurs.'),
  (v_formation, 'qcm', 'Le ROI moyen d''une solution de télématique embarquée est de :', '[{"id":"a","label":"1 mois","is_correct":false},{"id":"b","label":"6 à 12 mois","is_correct":true},{"id":"c","label":"3 à 5 ans","is_correct":false},{"id":"d","label":"Plus de 10 ans","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['telematique','roi'], 'mft-2026-gotrm:bc01-06:qcm:27', true, 'Le ROI typique d''une solution télématique est de 6 à 12 mois grâce aux gains : éco-conduite (-5 à -12 % carburant), productivité, prévention vols, baisse maintenance, gain de temps administratif (téléchargement à distance).'),
  (v_formation, 'qcm', 'Lors d''une utilisation de bourse de fret, la pratique LA MOINS recommandée est :', '[{"id":"a","label":"Vérifier KBIS et licence du transporteur","is_correct":false},{"id":"b","label":"Charger sans demander l''attestation d''assurance RC","is_correct":true},{"id":"c","label":"Conserver photos et CMR signée","is_correct":false},{"id":"d","label":"Privilégier les abonnements payants","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['bourses-fret','vigilance'], 'mft-2026-gotrm:bc01-06:qcm:28', true, 'Charger sans vérifier l''attestation d''assurance RC est une faute lourde de gestion : en cas de sinistre, l''entreprise peut être tenue responsable et privée d''indemnisation. Toujours demander assurance, licence transport et KBIS avant de confier une marchandise.');


  -- =================================================================
  -- 5 QR
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qr', 'Vous gérez un parc de 18 porteurs 19 t en TRM longue distance. Le taux de retour à vide actuel est de 26 %. Décrivez un plan d''action sur 6 mois pour le ramener à 15 %, en précisant les actions, les ressources, les indicateurs de suivi et le ROI attendu.', NULL, 1, 'difficile', ARRAY['plan-action','roi','retour-vide'], 'mft-2026-gotrm:bc01-06:qr:1', true, 'Plan d''action proposé :

1. Mois 1 — Diagnostic et choix d''outil
- Analyse Pareto des trajets retour à vide (top 10 lignes)
- Identification des zones avec faible offre de fret retour
- Souscription à 2 bourses de fret complémentaires (Teleroute + B2Pweb) — coût ~700 €/mois
- Désignation d''un référent fret retour (1 exploitant à 50 % de son temps)

2. Mois 2 — Formation et mise en place
- Formation des 4 exploitants à la recherche active de fret retour (1 jour/personne)
- Création d''une procédure interne « anticipation fret retour J-1 »
- Mise en place tableau de suivi quotidien (taux retour à vide par véhicule)

3. Mois 3-4 — Action commerciale
- Démarchage des 30 plus gros chargeurs sur les zones de retour fréquentes
- Proposition de tarif préférentiel sur les flux retour
- Partenariats avec 3 grossistes nationaux pour fret retour récurrent

4. Mois 5-6 — Optimisation TMS
- Déploiement d''un module de matching automatique fret retour dans le TMS existant
- Alertes en temps réel quand un véhicule s''approche de la fin de mission
- Reporting hebdomadaire sur les opportunités saisies vs ratées

Indicateurs de suivi (mensuels) :
- Taux retour à vide global (cible : 26 % → 22 % → 19 % → 17 % → 16 % → 15 %)
- Nombre de fret retour saisis par bourse
- Marge nette par mission retour
- Taux de fidélisation chargeurs retour

Ressources mobilisées :
- 1 exploitant référent à 50 % (coût ~ 1 500 €/mois)
- Abonnements bourses : 700 €/mois
- Module TMS : 4 500 € one-shot
- Formation : 2 800 € (4 personnes)
- Total investissement an 1 : ~ 35 k€

ROI attendu :
- 18 véhicules × 120 000 km/an × 11 % de retour vide en moins = 237 600 km commerciaux additionnels
- À 1,40 €/km marge brute : ~ 333 k€/an de revenus additionnels
- Marge nette additionnelle : ~ 165 k€/an (après coûts variables)
- ROI : 35 k€ investis pour 165 k€ de marge, soit ~ 470 % la 1ère année
- Période de retour : 2,5 mois'),
  (v_formation, 'qr', 'Construisez la tournée optimale pour un porteur 12 t avec hayon devant livrer ces 8 points en agglomération nantaise (départ dépôt 6 h, retour 14 h max). Justifiez l''ordre choisi.

Points :
- A. Saint-Herblain (créneau 7 h-9 h, 90 kg)
- B. Rezé (créneau 9 h-11 h, 110 kg)
- C. Nantes Centre (créneau 8 h-10 h, 60 kg)
- D. Carquefou (créneau 10 h-12 h, 75 kg)
- E. Bouguenais (créneau 7 h-9 h, 130 kg)
- F. Orvault (créneau 8 h-11 h, 80 kg)
- G. Saint-Sébastien (créneau 9 h-12 h, 95 kg)
- H. La Chapelle-sur-Erdre (créneau 10 h-13 h, 100 kg)', NULL, 1, 'difficile', ARRAY['tournee','construction','cas-pratique'], 'mft-2026-gotrm:bc01-06:qr:2', true, 'Méthode :

1. Analyse géographique :
- Ouest agglo : Saint-Herblain (A), Bouguenais (E), Orvault (F)
- Centre : Nantes Centre (C)
- Sud : Rezé (B), Saint-Sébastien (G)
- Nord : Carquefou (D), La Chapelle-sur-Erdre (H)

2. Analyse créneaux :
- Créneaux étroits 2 h : A (7-9), C (8-10), D (10-12), E (7-9), B (9-11)
- Créneaux 3 h : F (8-11), G (9-12)
- Créneau 3 h : H (10-13)

3. Points 7-9 h prioritaires : A et E (deux points, deux créneaux étroits, ouest)

Tournée proposée :

Dépôt 6 h → E Bouguenais (arrivée 6 h 40, livraison 7 h-7 h 15) → A Saint-Herblain (7 h 45-8 h) → F Orvault (8 h 30-8 h 45) → C Nantes Centre (9 h 15-9 h 30) → B Rezé (10 h-10 h 15) → G Saint-Sébastien (10 h 45-11 h) → pause 45 min (11 h-11 h 45) → D Carquefou (12 h 15-12 h 30) → H La Chapelle-sur-Erdre (13 h-13 h 15) → retour dépôt (14 h)

Justification de l''ordre :

- E avant A : sud-ouest avant ouest, mais surtout E a un poids de 130 kg (le plus lourd) — on commence par l''alléger.
- F (Orvault, nord-ouest) après A pour suivre une logique géographique cohérente.
- C (Centre) entre Orvault et Rezé, sur la trajectoire descendante.
- B (Rezé, sud) puis G (Saint-Sébastien, sud-est) restent groupés.
- Pause 45 min après 4 h 30 cumulées de service.
- D (Carquefou, est) puis H (La Chapelle, nord) groupent les points nord et nord-est, fin de matinée.

Vérifications :

- Conduite cumulée estimée : ~3 h 30
- Temps d''arrêt : 8 × 15 min = 2 h
- Pause R561 : 45 min
- Total : ~ 6 h 15 → respecte la fenêtre 6 h - 14 h
- Poids total : 740 kg (largement < 12 t PTAC)
- Tous les créneaux RDV respectés
- 1 conducteur, 1 véhicule, conformité R561 OK'),
  (v_formation, 'qr', 'Une PME de transport de 22 véhicules a les KPI suivants au T1 :
- Taux remplissage poids : 76 %
- Taux retour à vide : 21 %
- Ponctualité : 91 %
- Coût km commercial : 1,48 € (cible 1,40 €)

Identifiez les 3 priorités d''action en utilisant Pareto, et bâtissez le plan trimestriel.', NULL, 1, 'difficile', ARRAY['kpi','plan-action','pareto'], 'mft-2026-gotrm:bc01-06:qr:3', true, 'Analyse Pareto des écarts à la cible :

1. Retour à vide 21 % vs cible 15 % : écart 6 pts → impact estimé sur coût km : +0,06 €/km commercial
2. Remplissage 76 % vs cible 85 % : écart 9 pts → impact sur prix de vente moyen : -7 % de marge
3. Ponctualité 91 % vs cible 95 % : écart 4 pts → impact pénalités contractuelles ~12 k€/T1

Hiérarchisation par impact financier :

- Priorité 1 : retour à vide (estimation +160 k€/an de revenus si ramené à 15 %)
- Priorité 2 : taux de remplissage (estimation +80 k€/an de marge si remonté à 85 %)
- Priorité 3 : ponctualité (réduction directe pénalités ~40 k€/an si remontée à 96 %)

Plan d''action trimestriel (T2) :

Action 1 — Retour à vide (responsable : exploitation)
- Souscription bourse Teleroute Premium (250 €/mois)
- Identification top 5 trajets à fort retour vide (analyse données TMS)
- Démarchage 15 chargeurs sur ces 5 trajets retour
- KPI : taux retour vide hebdomadaire, objectif fin T2 : 18 %

Action 2 — Taux de remplissage (responsable : commercial + exploitation)
- Audit du sourcing actuel : pourquoi 24 % de vide ?
- Réduction du nombre de tournées partielles → consolidation par cluster géographique
- Ajustement contractuel client : forfait minimum si lot < 2 t
- KPI : taux remplissage poids hebdo, objectif fin T2 : 81 %

Action 3 — Ponctualité (responsable : exploitation)
- Analyse Pareto des retards : top 10 causes sur 3 mois
- Action sur la cause 1 (probablement trafic urbain ou attente client)
- Mise en place alertes en temps réel via télématique
- KPI : taux ponctualité hebdo, objectif fin T2 : 94 %

Suivi :
- Tableau de bord hebdomadaire (vert/orange/rouge)
- Réunion d''exploitation toutes les 2 semaines
- Reporting mensuel direction
- Bilan T2 → ajustement plan T3

Investissement T2 :
- Bourses : 750 € × 3 mois = 2 250 €
- Module télématique additionnel : 1 800 € one-shot
- Temps exploitation supplémentaire : ~ 2 800 €
- Total : ~ 6 850 €

Gains attendus T2 (1 trimestre) :
- Retour à vide -3 pts → ~ 18 k€
- Remplissage +5 pts → ~ 14 k€
- Ponctualité +3 pts → ~ 7 k€ pénalités évitées
- Total trimestre : ~ 39 k€ pour 6,8 k€ d''investissement (ROI x 5,7)'),
  (v_formation, 'qr', 'Comparez le déploiement d''un TMS interne (on-premise) versus un TMS cloud (SaaS) pour une PME de 35 véhicules. Coûts, avantages, inconvénients et recommandation.', NULL, 1, 'difficile', ARRAY['tms','comparaison','recommandation'], 'mft-2026-gotrm:bc01-06:qr:4', true, 'Comparaison détaillée :

1. TMS On-premise (installé sur serveur de l''entreprise)

Coûts :
- Licences logicielles : 25 - 80 k€ one-shot
- Serveurs et infrastructure : 8 - 20 k€
- Installation et paramétrage : 15 - 40 k€
- Maintenance annuelle : 18 - 25 % du coût licences
- Total an 1 : ~ 60 - 140 k€
- Coût récurrent annuel ans 2+ : ~ 15 - 30 k€

Avantages :
- Contrôle complet des données (sensibilité élevée pour certains secteurs)
- Performance ne dépend pas de la connexion internet
- Personnalisation poussée possible
- Pas de coût récurrent élevé après amortissement

Inconvénients :
- Investissement initial lourd
- Nécessite équipe ou prestataire IT en interne
- Mises à jour à gérer manuellement
- Risque obsolescence si pas de maintenance suivie
- Pas de mobilité naturelle (accès distant à configurer)

2. TMS Cloud / SaaS (Optitrans, Dispatcher Pro, AlpegaTMS Cloud)

Coûts :
- Setup initial : 3 - 10 k€
- Abonnement mensuel : ~ 30 - 100 €/véhicule selon richesse fonctionnelle
- Pour 35 véhicules : ~ 1 000 - 3 500 €/mois soit 12 - 42 k€/an
- Formation utilisateurs : 4 - 8 k€ one-shot

Avantages :
- Investissement initial faible
- Mises à jour incluses, toujours à la dernière version
- Pas d''infrastructure IT à gérer
- Accessible partout (web + app mobile)
- Scalabilité immédiate (ajout véhicules sans investissement matériel)
- Sauvegarde et redondance gérées par l''éditeur

Inconvénients :
- Dépendance à la connexion internet
- Données hébergées chez l''éditeur (vérifier RGPD, hébergement UE)
- Coût récurrent qui peut s''accumuler sur 5-10 ans
- Personnalisation plus limitée
- Risque verrouillage éditeur (lock-in) en cas de migration

Comparaison sur 5 ans (35 véhicules) :

| Coût total 5 ans | On-premise | Cloud |
|---|---|---|
| Setup et licences | 100 k€ | 7 k€ |
| Hébergement / abonnement | 0 | 150 k€ (30 k€/an × 5) |
| Maintenance | 100 k€ | 0 (inclus) |
| Personnel IT dédié | 30 k€ | 0 |
| Total 5 ans | ~ 230 k€ | ~ 157 k€ |

Recommandation pour PME 35 véhicules :

CLOUD/SaaS clairement recommandé. Justifications :

a. Coût total 5 ans inférieur (~ 30 % d''économie).
b. Pas d''équipe IT à dédier — la PME peut se concentrer sur son métier.
c. Évolutivité immédiate (croissance, baisse, saisonnalité).
d. Mises à jour automatiques permettent de bénéficier des nouveautés (IA, IoT) sans projet lourd.
e. RGPD : choisir un éditeur avec hébergement UE et certifications (ISO 27001, SecNumCloud).

Critères de choix concrets :
- Hébergement UE confirmé (RGPD)
- Certifications de sécurité (ISO 27001 minimum)
- Existence d''API ouvertes pour interconnexion ERP/comptabilité
- Support en français, hotline 7 j/7
- Référence clients PME similaires dans le secteur
- Période de pilote possible (2-3 mois)
- Contrat de réversibilité (export des données en cas de fin de contrat)'),
  (v_formation, 'qr', 'L''entreprise *Trans-Express Loire* a déployé une télématique sur ses 28 véhicules il y a 3 mois. Aujourd''hui, deux conducteurs ont saisi les délégués du personnel pour « surveillance abusive ». Analysez la situation au regard du RGPD et listez 6 mesures correctives.', NULL, 1, 'difficile', ARRAY['rgpd','telematique','plan-action'], 'mft-2026-gotrm:bc01-06:qr:5', true, 'Analyse RGPD :

Cadre légal applicable :
- RGPD (UE 2016/679)
- Loi Informatique et Libertés (LIL)
- Code du travail (information consultation CSE)
- Jurisprudence Cour de cassation : la géolocalisation des salariés est licite si elle a une finalité légitime, est proportionnée et que les salariés ont été informés.

Risques pour l''entreprise :
- Saisine CNIL → contrôle, mise en demeure, sanction (jusqu''à 4 % du CA mondial)
- Saisine Conseil de prud''hommes → reconnaissance harcèlement, dommages-intérêts
- Contrôle inspection du travail
- Perte de confiance interne, climat social dégradé
- Exposition médiatique négative

Diagnostic probable des manquements :

a. Information préalable insuffisante : pas de notice écrite remise aux conducteurs avant le déploiement.
b. CSE non consulté : obligation pour entreprise > 11 salariés (28 véhicules → forcément au-dessus du seuil).
c. Finalité non clarifiée : surveillance permanente vs optimisation/sécurité.
d. Durée de conservation excessive : si données conservées > 1 mois sans justification.
e. Pas de DPO ou de registre des traitements à jour.
f. Accès aux données mal cloisonné (qui consulte quoi).

6 mesures correctives prioritaires :

1. Suspendre la collecte temps réel non métier
- Limiter l''accès à la position en direct uniquement aux exploitants en mission active
- Désactiver toute consultation pendant les pauses et repos déclarés
- Plus de consultation systématique le matin pour la direction RH

2. Rédiger et diffuser une charte télématique claire
- Définir les finalités précises : sécurité, optimisation tournées, retour à vide, paie
- Lister les données collectées et leur durée de conservation
- Préciser qui accède à quoi (matrice habilitations)
- Faire signer la charte par chaque conducteur (avenant contrat de travail)

3. Consultation formelle du CSE
- Convoquer une réunion extraordinaire CSE (sous 30 jours)
- Présenter le dispositif, les finalités, les données traitées
- Recueillir l''avis du CSE (consultatif mais obligatoire)
- Procès-verbal joint au registre des traitements

4. Réduire la durée de conservation
- Position GPS : 1 mois maximum (sauf incident en cours de traitement)
- Données conduite : 12 mois (lié à la paie et CCN TRM)
- Anonymisation après 12 mois pour les analyses statistiques

5. Désigner un DPO ou référent CNIL
- Identifier un DPO interne ou externalisé (mutualisé pour PME)
- Mettre à jour le registre des traitements
- Réaliser une analyse d''impact (AIPD) puisque géolocalisation = traitement à risque

6. Communication transparente avec les conducteurs
- Réunion d''équipe (présence direction + DRH + DPO)
- Présentation des correctifs apportés
- Ouverture d''un canal de remontée des préoccupations
- Engagement écrit : aucune sanction disciplinaire fondée sur la télématique sans procédure contradictoire et information préalable

Bonus — Mesures structurelles :
- Audit RGPD annuel par cabinet externe
- Formation RGPD obligatoire pour exploitants
- Politique de sanction interne en cas d''accès non justifié aux données
- Rétroplanning de mise en conformité communiqué à la CNIL si saisine

Conclusion :
La télématique reste licite et utile, mais son déploiement doit respecter strictement le RGPD : information préalable, finalité légitime, proportionnalité, durée limitée. La crise actuelle est l''occasion de remettre le cadre à plat pour pérenniser l''outil.');


  -- =================================================================
  -- QUIZZES (4 entraînement + 1 examen blanc)
  -- =================================================================
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — Méthodes de planification', 'Types de tournées (FTL/LTL/distribution), VRP, savings, plus proche voisin.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-06:qcm:1','mft-2026-gotrm:bc01-06:qcm:2','mft-2026-gotrm:bc01-06:qcm:4','mft-2026-gotrm:bc01-06:qcm:5','mft-2026-gotrm:bc01-06:qcm:19','mft-2026-gotrm:bc01-06:qcm:22','mft-2026-gotrm:bc01-06:qcm:23');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — Construction d''une tournée', '6 étapes, clusters, marge sécurité, calcul des temps.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-06:qcm:6','mft-2026-gotrm:bc01-06:qcm:7','mft-2026-gotrm:bc01-06:qcm:12','mft-2026-gotrm:bc01-06:qcm:24');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — TMS, télématique et bourses', 'TMS (6 fonctions), télématique, bourses de fret, RGPD.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-06:qcm:8','mft-2026-gotrm:bc01-06:qcm:9','mft-2026-gotrm:bc01-06:qcm:10','mft-2026-gotrm:bc01-06:qcm:20','mft-2026-gotrm:bc01-06:qcm:26','mft-2026-gotrm:bc01-06:qcm:27','mft-2026-gotrm:bc01-06:qcm:28');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — KPI et amélioration continue', 'KPI remplissage, retour à vide, ponctualité, PDCA, Pareto, Ishikawa.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-06:qcm:3','mft-2026-gotrm:bc01-06:qcm:11','mft-2026-gotrm:bc01-06:qcm:13','mft-2026-gotrm:bc01-06:qcm:14','mft-2026-gotrm:bc01-06:qcm:15','mft-2026-gotrm:bc01-06:qcm:16','mft-2026-gotrm:bc01-06:qcm:17','mft-2026-gotrm:bc01-06:qcm:18','mft-2026-gotrm:bc01-06:qcm:21','mft-2026-gotrm:bc01-06:qcm:25');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Examen blanc — BC01-06 Planification tournées', '15 QCM en 30 min, seuil 50 %.', 'examen_blanc', 1800, 50)
  RETURNING id INTO v_quiz_eb;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-06:qcm:1','mft-2026-gotrm:bc01-06:qcm:2','mft-2026-gotrm:bc01-06:qcm:3','mft-2026-gotrm:bc01-06:qcm:5','mft-2026-gotrm:bc01-06:qcm:8','mft-2026-gotrm:bc01-06:qcm:9','mft-2026-gotrm:bc01-06:qcm:11','mft-2026-gotrm:bc01-06:qcm:13','mft-2026-gotrm:bc01-06:qcm:14','mft-2026-gotrm:bc01-06:qcm:16','mft-2026-gotrm:bc01-06:qcm:18','mft-2026-gotrm:bc01-06:qcm:20','mft-2026-gotrm:bc01-06:qcm:24','mft-2026-gotrm:bc01-06:qcm:27','mft-2026-gotrm:bc01-06:qcm:28');

  RAISE NOTICE '✅ GOTRM BC01-06 v2 chargé : 4 leçons, 28 QCM, 5 QR, 5 quizzes (4 entraînement + 1 examen blanc).';
END
$bc01_06$;
