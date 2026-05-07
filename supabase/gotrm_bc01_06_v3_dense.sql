-- =====================================================================
-- GOTRM (RNCP 40990) — BC01-06 · Planifier et optimiser les tournées
-- Version 3 (mai 2026) — REFONTE PÉDAGOGIQUE PREMIUM v3_dense
--
-- Bloc 01 : Concevoir, organiser et piloter des opérations de transport.
-- Module n° 6 sur 10 du BC01.
--
-- Référentiel RNCP 40990 — compétence visée :
--   « Planifier et optimiser les tournées de transport en intégrant les
--   contraintes légales (RSE), opérationnelles (capacité, créneaux),
--   économiques (km, marge) et qualitatives (ponctualité, satisfaction). »
--
-- ▸ 4 leçons (220 min total)
--   1. Méthodologie de planification — étapes et outils (55 min)
--   2. Optimisation des tournées — algorithmes et contraintes (55 min)
--   3. TMS et télématique — outils du marché (55 min)
--   4. KPIs, tableau de bord et amélioration continue (55 min)
--
-- Standard pédagogique v3_dense :
--   ✓ Leçons denses (2 000-2 500 mots chacune)
--   ✓ 4 cas pratiques chiffrés
--   ✓ Mini-exercices à faire seul + corrections en fin de module
--   ✓ Astuces pro + Points de vigilance + Schémas :::flow / :::timeline
--   ✓ Banque enrichie : 48 QCM (12/leçon) + 8 QR métier (cas pratiques)
--   ✓ Quizzes : 4 entraînement (12 QCM/quiz) + 1 examen blanc module
--     (15 QCM + 5 QR cas pratique long, 60 min, seuil 50 %)
--
-- Idempotent. Pré-requis : formation 'gotrm' présente.
-- =====================================================================

DO $bc01_06_v3$
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

  -- ─── Remplacement complet du module BC01-06 (idempotent) ─────────
  -- DELETE module cascade : lessons, formation_modules, quizzes, quiz_question_bank.
  DELETE FROM public.modules WHERE slug IN (
    'gotrm-bc01-06-planification-tournees',
    'gotrm-bc01-06-planification-tournees-v3'
  );

  -- Nettoyage de la banque de questions liées (v2 + v3) pour éviter les doublons
  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND (source_ref LIKE 'mft-2026-gotrm:bc01-06:%'
       OR source_ref LIKE 'mft-2026-gotrm:bc01-06-v3:%');

  INSERT INTO public.modules (
    title, slug, bloc_id, summary, difficulty, duration_min, "order"
  ) VALUES (
    'BC01-06 — Planifier et optimiser les tournées',
    'gotrm-bc01-06-planification-tournees',
    v_bloc,
    'Maîtriser la méthodologie de planification (5 étapes, géocodage, contraintes RSE), les algorithmes d''optimisation (TSP/VRP, sweep, plus proche voisin, Clarke & Wright, méta-heuristiques), les TMS et la télématique du marché (Akanea, Mantis, Trimble, Webfleet) et piloter via un tableau de bord KPIs (ponctualité, OTIF, remplissage) avec PDCA.',
    'avance',
    220,
    60
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 60, true) ON CONFLICT DO NOTHING;

  -- =================================================================
  -- LEÇON 1 — Méthodologie de planification : étapes et outils
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Méthodologie de planification — étapes et outils',
    'methodologie-planification-tournees',
    1, 55,
$lessonG1$
# Méthodologie de planification — étapes et outils

> 🎯 **Objectifs pédagogiques**
>
> À la fin de cette leçon, vous serez capable de :
>
> - **Appliquer** les 5 étapes de la planification opérationnelle.
> - **Recueillir** les données d'entrée nécessaires (commandes, véhicules, conducteurs, contraintes externes).
> - **Intégrer** les contraintes RSE (Règlement Social Européen) dans la construction des tournées.
> - **Géocoder** les adresses pour fiabiliser le calcul d'itinéraires.
> - **Construire** une feuille de tournée exploitable par le conducteur.

---

## Introduction

La **planification des tournées** est le **cœur métier** d'un GOTRM. Une planification bâclée = 15-25 % de km perdus, conducteurs en infraction RSE, livraisons hors créneaux, clients mécontents, marges rongées. Une planification professionnelle = **gain immédiat de 8 à 12 % sur les coûts kilométriques** et **+5 points de ponctualité**.

Le pro de la planification ne « place » pas des arrêts au hasard sur une carte. Il suit une **méthode rigoureuse en 5 étapes**, recueille des données structurées, et **valide** chaque tournée avant publication. Cette leçon vous donne le **process de référence** appliqué dans les grandes maisons (Geodis, Kuehne+Nagel, ID Logistics, Stef) et adapté aux PME du transport.

À l'oral du DP RNCP 40990, le jury teste systématiquement votre maîtrise de cette méthode : « Décrivez le process de planification d'une journée type dans votre entreprise. »

---

## 1. Les 5 étapes de la planification

### 1.1 Vue d'ensemble

:::flow
1. Recueil des données | Commandes, véhicules, conducteurs, contraintes
2. Analyse des contraintes | Légales (RSE, ZFE), opérationnelles, capacitaires
3. Géocodage et calcul d'itinéraire | Adresses → coordonnées GPS, distances, durées
4. Construction des tournées | Affectation arrêts, ordre, conducteurs, véhicules
5. Validation et publication | Vérification RSE + équilibrage + diffusion conducteurs
:::

**Durée totale** d'une planification J pour 30-50 livraisons : **2 à 3 heures** en mode manuel (Excel + Google Maps), **30-45 minutes** avec un TMS automatisé. Le ROI d'un TMS est donc rapide dès 5 véhicules.

### 1.2 Quand planifier ?

| Échéance | Activité | Outils |
|---|---|---|
| **J-7 à J-3** | Préparation hebdomadaire (effectifs, congés, maintenance) | RH + atelier |
| **J-1 16h-18h** | Planification quotidienne définitive (commandes du jour) | TMS + cartographie |
| **J 6h-7h** | Brief conducteurs + ajustements de dernière minute | Mail / WhatsApp Pro |
| **J jour J** | Suivi temps réel + repositionnement si imprévu | TMS + télématique |

**Règle d'or** : **planifier la veille** pour 80 % des tournées. Les tournées « jour pour jour » sont sources d'erreurs et de coûts cachés.

---

## 2. Étape 1 — Recueil des données d'entrée

### 2.1 Les commandes à planifier

Chaque commande à intégrer dans une tournée doit comporter **9 informations minimum** :

| Donnée | Détail | Source |
|---|---|---|
| **Référence** | N° commande client | TMS / portail B2B |
| **Origine** | Adresse complète + accès (quai/sol/hayon) | Bon de commande |
| **Destination** | Adresse complète + accès + créneau | Bon de commande |
| **Marchandise** | Nature + poids + nb palettes + gerbable | Fiche SACO |
| **Volume** | m³ ou ml de plancher | Calcul automatique |
| **Créneau livraison** | Date + heure début/fin | Client |
| **Contraintes** | ADR, ATP, hayon, accessibilité PL | Fiche SACO |
| **Valeur déclarée** | € (couverture) | Client |
| **Statut paiement** | Avant départ ? À la livraison ? | Comptabilité |

⚠️ **Piège fréquent** : commandes incomplètes au moment de la planification = soit retard de planif, soit tournées à reprendre. **Ne JAMAIS** intégrer une commande sans qualification complète SACO (cf. BC01-01).

### 2.2 Les véhicules disponibles

Pour chaque véhicule du parc :

- **Type** : VUL ≤ 3,5 T / Porteur 12 T / Porteur 19 T / Semi 40 T.
- **Équipements** : hayon, frigo, FRC, ADR, gerbeur embarqué.
- **Capacité utile** : poids (kg) + volume (m³) + ml palettes.
- **Localisation** : dépôt principal ou décentralisé.
- **Disponibilité** : entretien programmé, contrôle technique, immobilisation.
- **Coût d'exploitation** (CRKM) : €/km calculé (cf. BC02 capa).

### 2.3 Les conducteurs disponibles

Pour chaque conducteur :

- **Permis** : B / C / CE.
- **FIMO/FCO** : à jour ?
- **Habilitations** : ADR, ATP, manutention, hayon, ABE.
- **RSE** : compteur conduite hebdo, jours de repos restants.
- **Heures planifiées** : à équilibrer pour ne pas dépasser **56 h/semaine**.
- **Ancienneté zones** : connaissance terrain (gain 5-10 % de temps).

### 2.4 Contraintes externes

- **Péages** : itinéraires payants, pesage (autoroute A26 vs A1).
- **ZFE** (Zones à Faibles Émissions) : Crit'Air véhicules autorisés.
- **Accessibilité PL** : interdictions véhicules > 3,5 T, > 19 T, > 40 T.
- **Travaux** : déviations Sytadin, Bison Futé.
- **Météo** : neige, verglas (+30 % de temps en hiver montagne).
- **Périodes interdites** : dimanches/jours fériés pour les > 7,5 T en France.

---

## 3. Étape 2 — Analyse des contraintes RSE

### 3.1 Le Règlement Social Européen (RSE)

Le **RSE** (règlement CE 561/2006) impose :

| Contrainte | Limite | Sanction |
|---|---|---|
| **Conduite continue** | 4 h 30 max → pause **45 min** | 100-1 500 € |
| **Conduite quotidienne** | **9 h** (10 h × 2/sem.) | 100-1 500 € |
| **Conduite hebdomadaire** | **56 h** (90 h sur 2 sem.) | 750-2 700 € |
| **Repos quotidien** | **11 h** consécutives (ou 9 h × 3/sem.) | 100-1 500 € |
| **Repos hebdomadaire** | **45 h** (réduit à 24 h × 1/2 sem.) | 750-2 700 € |
| **Amplitude** | **15 h max** entre 2 repos | — |

### 3.2 Calcul concret pour une tournée J

**Exemple** : un conducteur démarre à **6h00**, doit livrer 12 clients en région parisienne, total 280 km + chargement 30 min + 12 × 20 min livraison + retour dépôt.

- **Conduite estimée** : 280 km / 50 km/h moyenne = **5 h 36**.
- **Manutention** : 30 + 12 × 20 = **4 h 30** (compté en travail, pas en conduite).
- **Pause obligatoire** : 45 min (après 4 h 30 conduite continue).
- **Total amplitude** : 5 h 36 + 4 h 30 + 0 h 45 = **10 h 51** ⇒ OK (< 15 h amplitude).
- **Conduite** 5 h 36 ⇒ OK (< 9 h).
- **Repos quotidien J → J+1** : ≥ 11 h consécutives à programmer.

⚠️ **Piège fréquent** : oublier la **pause 45 min** dans les tournées denses. Les pénalités sont lourdes (sanction conducteur ET entreprise).

### 3.3 Les compétences requises

Avant d'affecter un conducteur à une tournée, vérifier :

- **ADR** si matières dangereuses : conducteur formé (recyclage 5 ans).
- **ATP** si température dirigée : connaissance du véhicule frigorifique.
- **Hayon** : habilitation manutention + formation gestes/postures.
- **CACES R489 catégorie 1** si gerbeur embarqué.
- **CAPATAV** si transport animaux vivants.

### 3.4 Cas pratique : affectation conducteur

**Énoncé** : Vous avez 3 conducteurs disponibles lundi. Tournée du jour : 6 livraisons GMS (créneaux 8h-12h) + 4 livraisons industrielles (12h-17h), dont 1 livraison ADR classe 3 (peintures) chez le 4ᵉ client industriel.

| Conducteur | Permis | FCO | ADR | Heures sem. en cours |
|---|---|---|---|---|
| Pierre | CE | 2024 | Non | 38 h |
| Marie | CE | 2025 | Oui (à jour) | 42 h |
| Karim | C | 2024 | Oui (à jour) | 50 h |

**Décision** :
- **Marie** = bon candidat (ADR + 42 h en cours, peut faire 14 h sup).
- **Pierre** = NON sans réorganisation (pas ADR pour le client industriel).
- **Karim** = NON (50 h + tournée 9 h = 59 h ⇒ dépassement 56 h hebdo).

⇒ **Marie** prend la tournée complète, **Pierre** assure une autre tournée sans ADR.

---

## 4. Étape 3 — Géocodage et calcul d'itinéraire

### 4.1 Qu'est-ce que le géocodage ?

Le **géocodage** consiste à convertir une adresse postale en **coordonnées GPS** (latitude/longitude) :

```
"12 rue de la Paix, 75002 Paris" → 48.8696, 2.3308
```

Sans géocodage propre, le calcul d'itinéraire est imprécis (±10-30 % d'erreur sur les distances).

### 4.2 APIs et services de géocodage

| Service | Tarif | Précision | Usage |
|---|---|---|---|
| **Google Maps API** | 5 $ pour 1 000 requêtes | Très haute | Standard mondial |
| **OpenStreetMap (OSM)** | Gratuit (rate limit) | Bonne | Alternative open-source |
| **Bing Maps API** | 1-3 $ pour 1 000 requêtes | Haute | Microsoft, B2B |
| **Here Maps** | 0,75 $ pour 1 000 requêtes | Haute | Pro transport |
| **Mapbox** | Gratuit < 100k/mois | Bonne | Apps mobiles |

**Coût mensuel** typique pour 5 véhicules / 200 commandes : 50-100 €/mois (Google Maps API standard) — négligeable face au gain de précision.

### 4.3 Calcul d'itinéraire

Une fois les adresses géocodées, le calcul d'itinéraire produit pour chaque trajet :

- **Distance** (km) — à comparer au km direct (à vol d'oiseau × 1,3 = bonne approximation pour la France).
- **Durée prévisionnelle** (min) — selon la vitesse moyenne et le trafic.
- **Itinéraire détaillé** (segments routiers).
- **Péages** estimés (pour autoroutes).
- **Émissions CO₂** estimées (pour rapports RSE).

### 4.4 Mode camion (PL)

⚠️ **Erreur fréquente** : utiliser un calcul d'itinéraire « mode voiture » par défaut. Pour un PL :

- Hauteur véhicule (4 m, ponts/tunnels).
- Largeur (2,55 m).
- Poids (44 t, ponts limités).
- **Interdictions PL** (centres-villes, axes étroits).
- **Périodes interdites** dimanches/jours fériés.

**Solutions PL spécialisées** : **PTV Map&Guide**, **Truck Maps Trimble**, **Sygic Truck Navigation**. Coût 5-15 €/mois/véhicule mais évitent 80 % des erreurs.

---

## 5. Étape 4 — Construction des tournées

### 5.1 Construction manuelle (Excel + cartographie)

Pour ≤ 5 véhicules, mode manuel acceptable :

1. **Tableau Excel** : 1 ligne par commande, colonnes (origine, destination, créneau, poids, volume).
2. **Tri** par zone géographique (groupement spatial) ou par créneau (groupement temporel).
3. **Cartographie** Google My Maps : importer les coordonnées GPS, visualiser.
4. **Affectation** manuelle des arrêts à un véhicule selon capacité et tournée géographique.
5. **Calcul** distance totale + durée + vérification capacité véhicule + RSE.

**Gain de temps** : 2-3 h pour 30 commandes vs 5-6 h sans cartographie.

### 5.2 Construction automatisée (TMS)

Un TMS (cf. Leçon 3) propose des algorithmes (cf. Leçon 2) qui construisent automatiquement les tournées en optimisant un critère cible (km min, coût min, ponctualité max).

L'opérateur ne fait que **valider** ou **ajuster** les tournées proposées.

### 5.3 Anatomie d'une feuille de tournée

| Section | Contenu |
|---|---|
| **En-tête** | Date, conducteur, véhicule (immat.), tournée n° |
| **Liste arrêts** | Ordre numéroté + adresse + créneau + contact |
| **Distances/durées** | Km cumulé + temps cumulé |
| **Marchandise** | Référence, poids, nb palettes par arrêt |
| **Contraintes** | ADR, hayon, manutention spécifique |
| **Documents** | LV, CMR, fiche sécurité ADR |
| **Contacts** | Numéro chef d'équipe, dispatch |
| **RSE** | Heure démarrage, conduite estimée, pause, fin |

### 5.4 Cas pratique — Planifier 12 livraisons Paris-Lille

**Énoncé** : Vendredi vous devez planifier 12 livraisons :
- 8 GMS dans la région parisienne (créneau 8h-12h, hayon obligatoire).
- 4 industriels en région lilloise (créneau 14h-17h).
- Marchandise : 30 palettes EUR (poids unitaire 600 kg) + accessibilité PL OK partout.

**Véhicule disponible** : 1 PL 19 t (capacité 33 palettes) avec hayon, ATP NON, ADR NON.

**Conducteur** : Pierre, CE permis, 38 h en cours, FCO 2024.

**Tournée construite** :

:::flow
1. Dépôt 6h00 | Départ Paris dépôt — chargement 30 palettes
2. Paris GMS A 8h00 | Livraison 4 palettes — hayon, 25 min
3. Paris GMS B 8h45 | Livraison 4 palettes — hayon, 25 min
4. Paris GMS C 9h30 | Livraison 4 palettes — hayon, 25 min
5. Paris GMS D 10h15 | Livraison 4 palettes — hayon, 25 min
6. Paris GMS E 11h00 | Livraison 4 palettes — hayon, 25 min
7. Paris GMS F 11h45 | Livraison 4 palettes — hayon, 25 min
8. Pause RSE 45 min 12h30 | Pause obligatoire conduite
9. Lille A 14h30 | Livraison 1 palette — quai, 15 min
10. Lille B 15h15 | Livraison 1 palette — quai, 15 min
11. Lille C 16h00 | Livraison 2 palettes — quai, 15 min
12. Lille D 16h45 | Livraison 2 palettes — quai, 15 min
13. Retour Lille dépôt 18h00 | Fin tournée
:::

**Vérifications** :
- Distance : ~ 280 km — OK.
- Conduite : ~ 5 h 30 — OK (< 9 h).
- Amplitude : 12 h — OK (< 15 h).
- Pause 45 min entre 12h30 et 13h15 — OK.
- Capacité véhicule : 30 palettes ≤ 33 — OK.
- Tonnage : 30 × 600 = 18 t ≤ 19 t — OK (au plafond, attention).

---

## 6. Étape 5 — Validation et publication

### 6.1 Checklist avant publication

| Critère | Valid. |
|---|---|
| Toutes les commandes affectées ? | ✅ |
| Aucune fenêtre de livraison violée ? | ✅ |
| Conduite max 9 h respectée ? | ✅ |
| Pause 45 min programmée ? | ✅ |
| Capacité véhicule (poids + volume) OK ? | ✅ |
| Compétences conducteur (ADR/ATP) OK ? | ✅ |
| Documents prévus (LV, CMR) ? | ✅ |
| Numéros contacts conducteurs/clients à jour ? | ✅ |

### 6.2 Diffusion conducteurs

**Canaux** :
- **Application mobile TMS** (idéal) : feuille tournée + suivi temps réel.
- **Mail/PDF** : feuille de route en pièce jointe.
- **WhatsApp Pro** : pour ajustements de dernière minute (PROSCRIRE en B2B initial mais utile pour communication opérationnelle interne).
- **Imprimé papier** : peu écologique, encore utilisé en PME.

**Norme pro** : feuille de tournée disponible **la veille à 18h** au plus tard pour le conducteur.

---

## 7. Outils manuels vs TMS — comparatif

### 7.1 Outils manuels (TPE 1-3 véhicules)

| Outil | Coût | Limites |
|---|---|---|
| Excel + Google Maps | 0 € | Manuel, pas d'optimisation auto |
| Google My Maps | 0 € | Cartographie partage, pas calcul itinéraire |
| Pizzaplan / Trafineo Lite | 50-150 €/mois | Petite optimisation ≤ 5 véhicules |

### 7.2 TMS standards (PME 5-30 véhicules)

| TMS | Tarif indicatif | Atouts |
|---|---|---|
| **Akanea TMS** | 80-150 €/véh./mois | Référent France, intégration douanes |
| **Mantis Logistics** | 60-120 €/véh./mois | TPE/PME, prise en main rapide |
| **Stellium** | 70-130 €/véh./mois | Modulaire, web SaaS |
| **Datafret** | 50-100 €/véh./mois | Léger, pas de planif auto |

### 7.3 TMS premium (PME+ et ETI)

| TMS | Tarif indicatif | Atouts |
|---|---|---|
| **PTV / Trimble TMS** | 200-400 €/véh./mois | Optimisation poussée, multi-pays |
| **Manhattan TMS** | Sur devis | Cœur ERP, multi-tenant |
| **Kuebix / Trimble** | Sur devis | Standard US/EU |

---

## 8. Cas pratique d'examen

**Énoncé** : Vous gérez 8 véhicules PL en PME transport généraliste. Vous prévoyez 50 commandes/jour à planifier la veille à 17h. Aujourd'hui, vous mettez 4 h à le faire en mode Excel + Google Maps. Le directeur veut diviser ce temps par 2.

**Question** : Proposez une démarche complète (méthode + outils + ROI) pour passer de 4 h à 2 h en gardant la qualité.

**Correction proposée** :

1. **Standardiser les commandes en entrée** : tous les bons de commande passent par un portail B2B unique (ex : Transporeon ou portail propre) avec champs SACO obligatoires. Gain : 30 % de temps de re-saisie.

2. **Acquérir un TMS** : Mantis ou Akanea. Coût ≈ 8 véh. × 100 €/mois × 12 mois = **9 600 €/an**. ROI :
   - Gain temps planif : 2 h/jour × 220 jours × 35 €/h = **15 400 €/an**.
   - Optimisation km : -8 % × 200 000 km/an × 0,18 €/km coût km = **-2 880 €/an**.
   - **ROI = +18 280 €/an net de coût TMS** (≈ 200 % retour sur investissement).

3. **Géocoder les adresses clients** : au moment de la création de la fiche client. Gain : pas de recalcul à chaque planification.

4. **Définir des tournées-types** : 80 % des commandes sont sur des zones récurrentes ⇒ créer 8-10 tournées-types pré-construites, à compléter le jour J.

5. **Former l'opérateur** : 2 jours de formation TMS (1 500-2 500 €) pour exploiter à fond les fonctions automatisées.

6. **Mesurer** : KPI lead-time-planning < 2 h cible, taux de respect créneaux ≥ 95 %, km/commande, marge brute par tournée.

---

## 9. Mini-exercice à faire seul

**Énoncé** : Une tournée prévoit 8 livraisons sur 350 km, démarrage 7h, vitesse moyenne 50 km/h, 20 min par livraison. Un conducteur doit-il prendre une pause RSE ? À quel moment ?

> 💡 Réponse en fin de module (corrections § 4).

---

## 10. Glossaire

- **RSE** : Règlement Social Européen (CE 561/2006) — temps de conduite et repos.
- **ZFE** : Zone à Faibles Émissions — restrictions Crit'Air (Paris, Lyon, etc.).
- **Géocodage** : conversion adresse → coordonnées GPS.
- **TMS** : Transport Management System (logiciel d'exploitation).
- **CRKM** : Coût de Revient Kilométrique (€/km).
- **VRP** : Vehicle Routing Problem (problème d'optimisation).
- **TSP** : Travelling Salesman Problem (voyageur de commerce).
- **Feuille de tournée** : document opérationnel remis au conducteur.
- **Amplitude** : durée totale du service (conduite + manutention + pauses).
- **Compétence ADR** : qualification matières dangereuses du conducteur.

---

## 11. Synthèse opérationnelle

1. **5 étapes** de planification : recueil → analyse contraintes → géocodage → construction → validation.
2. **Données d'entrée** : commandes (9 infos), véhicules, conducteurs, contraintes externes.
3. **RSE** : 9 h conduite/jour, 4 h 30 → 45 min pause, 11 h repos quotidien, 45 h hebdo.
4. **Géocodage** systématique au moment de la création client (Google Maps API ou OSM).
5. **Mode camion** indispensable (PTV, Trimble) pour PL > 12 m, > 19 t.
6. **Construction manuelle** OK ≤ 5 véh., **TMS obligatoire** au-delà.
7. **Validation** systématique avec checklist 8 points avant publication.
8. **Diffusion** conducteurs la veille 18h max.

---

## ⚠️ Points de vigilance

- **Ne JAMAIS** planifier sans avoir vérifié la **pause 45 min après 4 h 30 conduite**. Sanction RSE lourde.
- **Mode camion** vs voiture : 80 % des erreurs viennent du mauvais profil itinéraire.
- **Capacité tonnage** : un PL 19 t à 100 % de charge est en surcharge potentielle. Cible 90 %.
- **Géocodage défaillant** : adresse mal saisie → +10-30 % d'erreur sur la distance.

## 💡 Astuces pro

- **Tournées-types** : 80 % des commandes étant récurrentes, créer 8-12 tournées-types pré-construites par zone. Gain de 60 % du temps de planif.
- **Outil terrain gratuit** : *Google My Maps* pour visualiser une tournée avant publication. Gain : détection visuelle des zones non couvertes.
- **Coup malin** : pré-charger un véhicule la veille au soir avec les commandes du lendemain. Gain : départ 6h au lieu de 7h, +1h utile.

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : étapes de planification, contraintes RSE, géocodage, mode camion.
- **QR cas pratique** : « Planifiez la tournée suivante avec 8 livraisons et 1 véhicule, en respectant le RSE. »
- **Oral DP** : « Décrivez votre process de planification quotidienne dans votre entreprise actuelle. »

---

## 📌 Synthèse à retenir

### Les 5 étapes en un coup d'œil

| Étape | Activité |
|---|---|
| **1. Recueil** | Commandes, véhicules, conducteurs, contraintes |
| **2. Analyse** | Légales (RSE), opérationnelles, capacitaires |
| **3. Géocodage** | Adresses → GPS, calcul itinéraire mode camion |
| **4. Construction** | Affectation arrêts, ordre, équilibrage tournées |
| **5. Validation** | Checklist 8 points + diffusion conducteurs |

### Contraintes RSE à connaître par cœur

- **9 h** conduite/jour (10 h × 2/sem max)
- **56 h** conduite/semaine
- **4 h 30** conduite continue → pause **45 min**
- **11 h** repos quotidien (consécutives)
- **45 h** repos hebdomadaire
- **15 h** amplitude maximale

### Outils selon la taille

| Taille | Outils recommandés |
|---|---|
| TPE 1-3 véh. | Excel + Google Maps (manuel) |
| PME 5-30 véh. | Akanea / Mantis / Stellium |
| ETI 30+ véh. | PTV / Trimble / Manhattan |

> ⚠️ **Les 4 règles d'or à ne jamais oublier**
>
> - **Pause 45 min** obligatoire après 4 h 30 de conduite continue
> - **Mode camion** dans le calcul d'itinéraire (jamais voiture pour PL)
> - **Géocodage** systématique des adresses clients à la création
> - **Validation** par checklist 8 points avant diffusion conducteurs
$lessonG1$,
'Maîtriser les 5 étapes de planification (recueil → analyse → géocodage → construction → validation), les contraintes RSE (9 h conduite, 4 h 30 → pause 45 min, 11 h repos), le géocodage et le calcul d''itinéraire mode camion, puis construire une feuille de tournée valide.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Optimisation des tournées : algorithmes et contraintes
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Optimisation des tournées — algorithmes et contraintes',
    'optimisation-tournees-algorithmes',
    2, 55,
$lessonG2$
# Optimisation des tournées — algorithmes et contraintes

> 🎯 **Objectifs pédagogiques**
>
> - **Comprendre** les problèmes classiques TSP et VRP.
> - **Appliquer** la méthode du sweep (balayage) et du plus proche voisin.
> - **Utiliser** la méthode des économies de Clarke & Wright.
> - **Identifier** les algorithmes méta-heuristiques (recuit simulé, tabou, génétique).
> - **Intégrer** les contraintes (fenêtres, capacité, compétences) et arbitrer entre indicateurs.

---

## Introduction

Optimiser une tournée, c'est **résoudre un problème mathématique** : quelle séquence d'arrêts minimise les km, le temps, ou le coût, **tout en respectant** les contraintes (créneaux, capacité, conducteur) ?

Les **TMS** automatisent ces calculs avec des algorithmes éprouvés. Le **GOTRM** doit comprendre **comment ils fonctionnent** pour les paramétrer correctement, valider les propositions et arbitrer en cas de conflit. Une optimisation mal paramétrée = -2 % à -5 % au lieu des -10 % espérés.

À l'oral du DP RNCP 40990, le jury teste votre **culture algorithmique** : « Comment fonctionne l'optimisation de votre TMS ? Citez 2 méthodes que vous connaissez. »

---

## 1. Les problèmes classiques

### 1.1 TSP — Travelling Salesman Problem

Le **problème du voyageur de commerce** : étant donné N villes à visiter une seule fois, quel est le **chemin le plus court** qui revient au point de départ ?

- **Complexité** : N! (factorielle). 10 villes = 3,6 millions de combinaisons.
- **Solution exacte** impossible au-delà de 15-20 villes.
- **Heuristiques** indispensables (cf. § 2-4).

**Application transport** : 1 conducteur, 1 véhicule, plusieurs livraisons à enchaîner.

### 1.2 VRP — Vehicle Routing Problem

Le **VRP** étend le TSP avec **plusieurs véhicules** et plusieurs **dépôts** possibles. Variantes courantes :

| Variante | Particularité |
|---|---|
| **CVRP** | Capacité véhicule limitée |
| **VRPTW** | Time Windows (fenêtres de livraison) |
| **MDVRP** | Multi-dépôts |
| **VRPPD** | Pickup & Delivery (collectes et livraisons) |
| **HVRP** | Hétérogène (flotte mixte) |

**Application transport** : 1 dépôt + 4-8 véhicules + 50-200 livraisons + créneaux + capacités diverses. C'est le **problème quotidien** d'un GOTRM.

### 1.3 Pourquoi optimiser ?

| Levier | Gain potentiel |
|---|---|
| **Km totaux** | -8 % à -12 % |
| **Heures conducteurs** | -5 % à -10 % |
| **Tonnes véhicules** | +3 % à +5 % de remplissage |
| **Ponctualité** | +5 à +8 points |
| **CO₂** | -8 % à -12 % (proportionnel aux km) |

---

## 2. Méthode du Sweep (balayage)

### 2.1 Principe

Le **Sweep** est la **méthode constructive la plus simple** :

1. Calculer les **coordonnées polaires** de chaque arrêt par rapport au dépôt.
2. **Trier** les arrêts par **angle polaire croissant** (sens trigonométrique).
3. **Affecter** les arrêts à un véhicule jusqu'à saturation (capacité).
4. Passer au véhicule suivant.

### 2.2 Schéma conceptuel

:::flow
1. Dépôt = origine | Centre du repère polaire
2. Calculer angles | atan2(y - y0, x - x0) pour chaque arrêt
3. Trier par angle | Ordre trigonométrique (0° → 360°)
4. Saturation véhicule 1 | Affecter jusqu'à capacité atteinte
5. Saturation véhicule 2 | Continuer le balayage
:::

### 2.3 Avantages et limites

✅ **Avantages** : simple à comprendre et calculer (Excel suffit), bonne intuition géographique.

❌ **Limites** : ne tient pas compte des fenêtres de livraison, peut produire des tournées non optimales en zone très dense ou très étalée.

### 2.4 Cas pratique sweep

**Énoncé** : 8 clients en banlieue parisienne, dépôt à Saint-Denis. Capacité véhicule = 4 clients max.

**Calcul** : on calcule les angles polaires des 8 clients depuis Saint-Denis, on les trie de 0° à 360°.

| Client | Angle | Cumul cap. |
|---|---|---|
| C1 | 25° | 1/4 |
| C2 | 45° | 2/4 |
| C3 | 80° | 3/4 |
| C4 | 110° | 4/4 (saturé) |
| C5 | 145° | 1/4 (véh. 2) |
| C6 | 180° | 2/4 |
| C7 | 230° | 3/4 |
| C8 | 290° | 4/4 |

⇒ **Tournée 1** = C1-C2-C3-C4 (véhicule A), **Tournée 2** = C5-C6-C7-C8 (véhicule B).

---

## 3. Méthode du plus proche voisin (Nearest Neighbour)

### 3.1 Principe

Le **plus proche voisin** est la méthode itérative la plus intuitive :

1. Démarrer du **dépôt**.
2. Aller au **client le plus proche** (km).
3. Depuis ce client, aller au **client le plus proche non encore visité**.
4. Répéter jusqu'à épuisement des clients.
5. Retour au dépôt.

### 3.2 Avantages et limites

✅ **Avantages** : ultra-simple, calcul rapide.

❌ **Limites** : **myope** — l'algorithme ne voit pas le tableau d'ensemble. Peut générer 10-30 % de km en plus que l'optimum.

### 3.3 Exemple chiffré

**5 clients** + dépôt. Distances en km :

```
       D    C1   C2   C3   C4   C5
D    [  0,  10,  20,  15,  12,  18 ]
C1   [ 10,   0,   8,  12,   6,  14 ]
C2   [ 20,   8,   0,   5,  10,   7 ]
C3   [ 15,  12,   5,   0,   4,   9 ]
C4   [ 12,   6,  10,   4,   0,  11 ]
C5   [ 18,  14,   7,   9,  11,   0 ]
```

**Plus proche voisin** : D → C1 (10) → C4 (6) → C3 (4) → C2 (5) → C5 (7) → D (18) = **50 km**.

**Optimum réel** (calcul exhaustif) ≈ 47 km (ordre D→C4→C1→C2→C3→C5→D).

⇒ **Différence 6 %** sur 5 clients. Sur 50 clients, peut atteindre 25 %.

---

## 4. Méthode des économies (Clarke & Wright)

### 4.1 Principe

Méthode publiée en **1964**, encore **standard** dans les TMS modernes. Elle combine progressivement des tournées simples (1 client) en tournées multi-clients en **mesurant l'économie** réalisée.

### 4.2 Calcul de l'économie

Pour 2 clients i et j, l'**économie** réalisée à les regrouper dans la même tournée :

```
S(i,j) = D(0,i) + D(0,j) - D(i,j)
```

où :
- D(0,i) = distance dépôt → client i
- D(0,j) = distance dépôt → client j
- D(i,j) = distance entre i et j

**Plus S(i,j) est élevé, plus regrouper i et j est intéressant.**

### 4.3 Algorithme

1. Démarrer avec **N tournées** (1 par client).
2. Calculer toutes les économies S(i,j).
3. **Trier** les économies par ordre **décroissant**.
4. **Fusionner** les tournées dans cet ordre, **si** la capacité du véhicule le permet.
5. Continuer jusqu'à épuisement ou saturation.

### 4.4 Exemple chiffré

5 clients. Distances depuis dépôt : C1=10, C2=20, C3=15, C4=12, C5=18.

Distances inter-clients (extrait) :
- D(C1,C4) = 6 ⇒ S(C1,C4) = 10 + 12 - 6 = **16** ← gros gain
- D(C2,C3) = 5 ⇒ S(C2,C3) = 20 + 15 - 5 = **30** ← énorme gain
- D(C2,C5) = 7 ⇒ S(C2,C5) = 20 + 18 - 7 = **31** ← top gain

⇒ Fusion C2-C3-C5 puis C1-C4 si capacité permet. Tournée optimisée.

### 4.5 Avantages

✅ Excellent compromis simplicité/qualité, **utilisé dans 70 % des TMS**.

❌ Tient mal compte des fenêtres de livraison strictes (à compléter avec heuristiques temporelles).

---

## 5. Algorithmes méta-heuristiques

### 5.1 Recuit simulé (Simulated Annealing)

**Principe** : démarrer d'une solution initiale (ex : Clarke & Wright), faire des **petites modifications aléatoires** (échange de 2 arrêts), accepter les améliorations + parfois aussi les dégradations (selon une « température » qui diminue dans le temps). Cela permet de **sortir des optimums locaux**.

**Performance** : -3 à -5 % sur Clarke & Wright en 30 secondes de calcul.

### 5.2 Recherche tabou (Tabu Search)

**Principe** : explorer le voisinage d'une solution, **mémoriser les solutions visitées récemment** (« liste tabou ») pour ne pas revenir en arrière. Continuer même si dégradation locale.

**Performance** : qualité équivalente recuit simulé, plus efficace sur certains VRP.

### 5.3 Algorithmes génétiques

**Principe** : maintenir une **population de solutions** (50-100 tournées différentes), les **croiser** (combiner des morceaux de 2 solutions), **muter** (modifications aléatoires), **sélectionner** les meilleures. Inspiré de l'évolution darwinienne.

**Performance** : très performant sur problèmes complexes (multi-dépôts, contraintes multiples), nécessite plus de calcul.

### 5.4 Quand utiliser ces algorithmes ?

| Situation | Algorithme recommandé |
|---|---|
| Problème simple < 20 arrêts | Plus proche voisin / Sweep |
| Standard 20-100 arrêts | Clarke & Wright |
| Contraintes fortes (fenêtres, capacité) | Recuit simulé / Tabou |
| Multi-dépôts complexe | Génétique |
| Optimisation continue (TMS) | Hybride C&W + recuit |

⚠️ **Le GOTRM n'a pas besoin de coder ces algorithmes** : ils sont dans les TMS du marché. Mais il doit les **comprendre** pour paramétrer correctement (poids des critères, contraintes dures vs souples).

---

## 6. Intégrer les contraintes

### 6.1 Fenêtres de livraison (time windows)

**Time window** = intervalle horaire pendant lequel la livraison est autorisée. Exemples :

- **GMS** : 30 min strictes (8h00-8h30).
- **Industriel** : 1-2 h (14h-16h).
- **Particulier** : 4 h (8h-12h ou 14h-18h).

Pour intégrer ces fenêtres, le TMS doit :
1. **Pénaliser** une livraison hors fenêtre (coût élevé en optimisation).
2. **Calculer le temps d'arrivée** à chaque arrêt.
3. **Gérer les attentes** (arriver avant la fenêtre = attente sur place).

### 6.2 Capacité véhicule

Contraintes dures :
- **Tonnage** ≤ PTAC.
- **Volume** ≤ capacité utile.
- **Mètres linéaires** ≤ longueur plancher.
- **Compatibilité** : ATP ≠ ADR sur le même chargement.

### 6.3 Compétences conducteur

Avant d'affecter un arrêt à un véhicule :
- Conducteur ADR si ADR.
- Conducteur ATP si frigorifique.
- Conducteur formé manutention si hayon manuel.

### 6.4 Cas pratique : optimiser 8 livraisons avec contraintes

**Énoncé** : 8 livraisons à optimiser. Contraintes :
- Client A : créneau strict 9h00-9h30 (GMS).
- Client B : hayon obligatoire (chez particulier).
- Capacité véhicule : 12 palettes EUR.
- Total marchandise : 10 palettes (OK capacité).

**Question** : Quelle séquence privilégier ?

**Réponse** :

1. **Contrainte dure A** : positionner Client A à **8h45 ou 9h00** dans la tournée (compte tenu du temps de trajet depuis le dépôt). Cela impose son **rang** dans la tournée.

2. **Contrainte dure B** : véhicule équipé hayon obligatoire ⇒ choix du véhicule.

3. **Optimisation** : pour les 6 autres clients sans contrainte forte, appliquer Clarke & Wright + recuit simulé.

⇒ Résultat type : **A en 1er** (créneau strict), **B en 2-4ème** (hayon, donc véhicule particulier), **autres clients** dans l'ordre optimal géographiquement.

---

## 7. Indicateurs et arbitrages

### 7.1 Les 4 indicateurs clés

| Indicateur | Mesure | Objectif typique |
|---|---|---|
| **Km totaux/jour** | Somme des km de la tournée | -10 % vs base manuelle |
| **Ponctualité** | % livraisons dans la fenêtre | ≥ 95 % |
| **Taux remplissage** | Poids ou volume utilisé / capacité max | ≥ 80 % |
| **Charge horaire conducteur** | Heures effectives / théoriques | 95-105 % (équilibré) |

### 7.2 Trade-offs

L'optimisation parfaite **n'existe pas**. Il y a toujours des arbitrages :

- **-Km vs +Ponctualité** : minimiser les km peut violer des fenêtres ⇒ optimiser sur **coût total = km × CRKM + pénalités créneaux**.
- **-Km vs équilibrage conducteurs** : la tournée la plus courte peut surcharger un conducteur ⇒ équilibrer les heures.
- **-Km vs capacité 100 %** : un véhicule plein = + lourd = + de carburant. Cible 80-90 % en pratique.

### 7.3 Le coût total comme critère

**Coût total tournée** = Σ km × CRKM + Σ heures × coût horaire + pénalités créneaux + amortissement véhicule.

C'est ce **coût total** que l'optimisation TMS minimise (et pas les km purs).

---

## 8. Cas pratique d'examen

**Énoncé** : Vous avez 1 dépôt + 2 véhicules PL identiques (capacité 12 palettes chacun). Vous devez livrer 18 palettes réparties sur 8 clients dans un rayon de 50 km. 1 client (C5) a un créneau strict 9h-9h30, vous démarrez à 7h30. CRKM = 1,2 €/km. Coût horaire conducteur (charges incluses) = 25 €/h. Vitesse moyenne 50 km/h.

Distances (km) entre dépôt et clients :
- D-C1: 12, D-C2: 25, D-C3: 18, D-C4: 30, D-C5: 22, D-C6: 15, D-C7: 28, D-C8: 20.
- C5-C2 = 5 km, C5-C7 = 8 km, C5-C8 = 12 km.

Marchandise : C1=2p, C2=3p, C3=2p, C4=2p, C5=3p, C6=1p, C7=3p, C8=2p (total 18p).

**Question** : Construisez 2 tournées optimisées en respectant la contrainte horaire C5 9h.

**Correction proposée** :

**Tournée 1 (véhicule A)** = C5 + C2 + C7 + C1 + C6 (12 palettes).
- 7h30 dépôt → 7h54 C5 (22 km, attente 6 min jusqu'à 9h00).
- 9h00-9h25 livraison C5 (3p).
- 9h25-9h30 trajet C5→C2 (5 km).
- Suivi des autres arrêts.

**Tournée 2 (véhicule B)** = C4 + C8 + C3 + ... (autres clients) (6 palettes).

**Calcul coût** :
- Km tournée 1 ≈ 80 km × 1,20 = **96 €**.
- Km tournée 2 ≈ 90 km × 1,20 = **108 €**.
- Heures total ≈ 14 h × 25 = **350 €**.
- **Coût total ≈ 554 €** pour 18 palettes livrées.

⇒ Coût/palette ≈ **30,80 €**. À comparer avec la marge cible (cf. BC02 capa).

---

## 9. Mini-exercice à faire seul

**Énoncé** : Un dépôt et 4 clients. Distances : D-C1 = 8 km, D-C2 = 12 km, D-C3 = 15 km, D-C4 = 20 km. Distances inter-clients : C1-C2 = 6 km, C1-C3 = 10 km, C2-C3 = 5 km, C3-C4 = 7 km. Calculez l'économie S(C2, C3) selon Clarke & Wright. Quels 2 clients regrouper en priorité ?

> 💡 Réponse en fin de module (corrections § 4).

---

## 10. Glossaire

- **TSP** : Travelling Salesman Problem (voyageur de commerce).
- **VRP** : Vehicle Routing Problem (problème de tournées de véhicules).
- **VRPTW** : VRP avec time windows (fenêtres horaires).
- **Sweep** : méthode du balayage (tri par angle polaire).
- **Clarke & Wright** : méthode des économies (1964).
- **Recuit simulé** : méta-heuristique inspirée de la métallurgie.
- **Recherche tabou** : méta-heuristique avec liste de mémoire.
- **Algorithmes génétiques** : méta-heuristique inspirée de l'évolution.
- **Time window** : fenêtre horaire de livraison autorisée.
- **Optimum local / global** : minimum atteignable (local = piège, global = vrai minimum).

---

## 11. Synthèse opérationnelle

1. **TSP** = 1 véhicule, ordre optimal d'arrêts. **VRP** = N véhicules, capacités, fenêtres.
2. **Sweep** = tri angle polaire. Simple, OK petits problèmes.
3. **Plus proche voisin** = itératif. Très rapide mais myope (10-30 % pire que l'optimum).
4. **Clarke & Wright** = méthode des économies. Standard, utilisée dans 70 % des TMS.
5. **Méta-heuristiques** (recuit simulé, tabou, génétique) = pour problèmes complexes.
6. **Contraintes** : fenêtres, capacité, compétences, hayon, ADR/ATP.
7. **Indicateurs** : km totaux, ponctualité, taux remplissage, charge horaire.
8. **Arbitrer** sur le **coût total** plutôt que les km purs.

---

## ⚠️ Points de vigilance

- **Plus proche voisin** seul = +20 % de km vs l'optimum. À éviter pour > 10 arrêts.
- **Optimum global** rarement atteignable. Cible : -10 % vs base manuelle, suffisant.
- **Fenêtres de livraison strictes** : à intégrer comme contrainte dure (et pas comme pénalité molle).
- **Capacité 100 %** : à éviter (risque surcharge ou marchandise non chargée si imprévu).

## 💡 Astuces pro

- **Tournées-types récurrentes** : générer 1 fois avec recuit simulé, réutiliser quotidiennement.
- **Outil gratuit** : *Google OR-Tools* (open-source) pour les développeurs souhaitant prototyper. CSV en entrée, tournée optimisée en sortie.
- **Coup malin** : laisser **5-10 % de marge** sur les fenêtres de livraison (arrivée 5 min avant). Gain : robustesse face aux aléas.

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : différence TSP/VRP ; principes Sweep/PPV/Clarke ; méta-heuristiques.
- **QR cas pratique** : « Calculez l'économie de Clarke & Wright pour 2 clients donnés. »
- **Oral DP** : « Comment fonctionne l'optimisation de votre TMS ? »

---

## 📌 Synthèse à retenir

### Algorithmes selon la complexité

| Problème | Algorithme |
|---|---|
| **TSP simple** (< 15 arrêts) | Calcul exhaustif possible |
| **VRP standard** (20-100) | Clarke & Wright |
| **VRP avec contraintes** | Recuit simulé / Tabou |
| **Multi-dépôts complexe** | Algorithmes génétiques |

### Méthode des économies — formule

> **S(i,j) = D(0,i) + D(0,j) − D(i,j)**
>
> Plus S est élevé, plus regrouper i et j est intéressant.

### Indicateurs à arbitrer

| Indicateur | Cible |
|---|---|
| Km totaux | -10 % vs base manuelle |
| Ponctualité | ≥ 95 % |
| Remplissage | ≥ 80 % |
| Équilibrage conducteurs | 95-105 % |

> ⚠️ **Optimisation = minimiser le COÛT TOTAL**
>
> = Km × CRKM + Heures × coût horaire + Pénalités créneaux + Amortissement
>
> ≠ minimiser les km purs (peut violer fenêtres ou surcharger conducteurs)
$lessonG2$,
'Maîtriser TSP/VRP et les algorithmes d''optimisation (Sweep, plus proche voisin, Clarke & Wright, méta-heuristiques recuit simulé/tabou/génétique), intégrer les contraintes (fenêtres, capacité, compétences) et arbitrer sur le coût total et non les km purs.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — TMS et télématique : outils du marché
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'TMS et télématique — outils du marché',
    'tms-telematique-outils',
    3, 55,
$lessonG3$
# TMS et télématique — outils du marché

> 🎯 **Objectifs pédagogiques**
>
> - **Cartographier** le périmètre fonctionnel d'un TMS.
> - **Identifier** les principaux acteurs du marché français.
> - **Maîtriser** les apports de la télématique embarquée.
> - **Intégrer** TMS, télématique et chronotachygraphe.
> - **Choisir** une solution adaptée à la taille et aux besoins de l'entreprise.

---

## Introduction

Le TMS et la télématique sont **les 2 outils technologiques** qui transforment radicalement la performance d'un service exploitation transport. Investir dans ces outils, c'est passer de **l'artisanat à l'industrie** : standardisation des process, traçabilité, optimisation, KPIs en temps réel.

Une PME 8 véhicules sans TMS perd typiquement **15-25 % de productivité** par rapport à une PME équipée. Une ETI sans télématique embarquée perd **8-12 %** sur les coûts d'exploitation (carburant, maintenance, sinistres) et a **30-50 %** de difficultés supplémentaires en cas de litige client.

Cette leçon vous donne les **clés du choix d'un TMS** et la **vision d'ensemble** de l'écosystème télématique français/européen.

---

## 1. Le TMS : périmètre fonctionnel

### 1.1 Définition et historique

**TMS** = **Transport Management System**. Logiciel d'exploitation **multi-modules** qui couvre l'ensemble du cycle de vie d'une opération de transport :

:::flow
1. Prise de commande | Saisie ou import EDI/portail B2B
2. Planification | Construction des tournées (manuelle/auto)
3. Exécution | Suivi temps réel + interface conducteurs
4. Facturation | Génération automatique des factures
5. Pilotage | KPIs et reporting direction
:::

Origine années 1990, généralisation 2000-2010 en France, montée en puissance SaaS / cloud depuis 2015.

### 1.2 Les 5 modules clés d'un TMS

| Module | Fonctions principales |
|---|---|
| **CRM/commandes** | Fiches clients, devis, contrats, prise de commande, EDI |
| **Planification** | Construction tournées, optimisation, affectation conducteurs |
| **Exécution** | Suivi GPS, dématérialisation LV, signature électronique |
| **Facturation** | Génération factures, intégration comptabilité (Sage, Cegid) |
| **Reporting** | Tableaux de bord KPIs, exports Excel/PDF |

### 1.3 Architecture moderne (SaaS)

Les TMS modernes sont en **SaaS web** (accessibles depuis n'importe quel navigateur), avec :
- **Application mobile conducteurs** (iOS/Android) pour exécution + signature.
- **API ouvertes** pour intégration ERP, comptabilité, télématique.
- **Cloud** : accès multi-sites, multi-utilisateurs, sauvegarde automatique.
- **Mises à jour continues** (vs versions on-premise tous les 2-3 ans).

---

## 2. Acteurs du marché français

### 2.1 Top 5 TMS pour PME/ETI

| TMS | Fournisseur | Tarif/véh./mois | Forces |
|---|---|---|---|
| **Akanea TMS** | Akanea | 80-150 € | Référent, douanes, intl. |
| **Mantis Logistics** | Mantis | 60-120 € | TPE/PME, simple, rapide |
| **Stellium** | Generix | 70-130 € | Modulaire, web/SaaS |
| **Datafret** | DDS Logistics | 50-100 € | Pas optim auto, léger |
| **EVALI / AS400** | Acteon | Sur devis | Industriel, transitaires |

### 2.2 TMS premium ETI/grands comptes

| TMS | Fournisseur | Forces |
|---|---|---|
| **PTV TMS / Trimble** | Trimble | Optimisation poussée, multi-pays |
| **Manhattan TMS** | Manhattan Associates | Cœur ERP, gros volumes |
| **Kuebix / Trimble Transportation** | Trimble | Standard US/EU |
| **C.H. Robinson Navisphere** | CH Robinson | Réseau commissionnaire mondial |
| **Project44** | Project44 | Visibility & tracking premium |

### 2.3 Solutions TPE / VUL

| Solution | Approche | Tarif |
|---|---|---|
| **Plan-de-tournée Excel** | DIY, gratuit | 0 € |
| **Pizzaplan** | Tournée légère | 30-80 €/mois |
| **Trafineo Lite** | TMS minimaliste cloud | 50-150 €/mois |
| **Track-POD** | Mobile-first conducteurs | 25-80 €/véh./mois |

### 2.4 Critères de choix

| Critère | Question à se poser |
|---|---|
| **Taille flotte** | TPE (< 5) → léger / PME (5-30) → standard / ETI (30+) → premium |
| **Activité** | Généraliste / spécialiste (frigo, chimie) / commission |
| **Intégration** | Comptabilité (Sage, Cegid) ? ERP ? Télématique ? |
| **Mobilité** | Application mobile conducteurs indispensable ? |
| **International** | Documents CMR, douane, multi-langue ? |
| **Support** | Hotline FR ouverte, formation, communauté ? |
| **Tarif** | Coût/véh./mois × nb véh. + setup + formation |

---

## 3. La télématique embarquée

### 3.1 Définition

**Télématique** = combinaison **télécom + informatique** pour collecter et transmettre les données du véhicule en temps réel : position GPS, vitesse, consommation, état moteur, comportement de conduite, températures.

### 3.2 Capteurs et données collectées

| Donnée | Capteur | Usage |
|---|---|---|
| **Position GPS** | Récepteur GNSS | Tracking, ETA dynamique |
| **Vitesse** | Tachymètre + GPS | Conformité, écoconduite |
| **Consommation** | CAN bus moteur | Optimisation conso, coût |
| **Régime moteur** | CAN bus | Maintenance prédictive |
| **Freinage brusque** | Accéléromètre | Risque accident, formation |
| **Température cargaison** | Sondes ATP | Chaîne du froid (régl.) |
| **Pression pneus** | TPMS | Sécurité + conso |
| **Ouverture portes** | Capteur magnétique | Sécurité (vol) |
| **Identifiant conducteur** | Carte tachy | Traçabilité 100 % |

### 3.3 Acteurs majeurs télématique

| Solution | Fournisseur | Tarif/véh./mois | Forces |
|---|---|---|---|
| **Trimble** | Trimble | 30-60 € | Référent PL, trans-européen |
| **Webfleet** | Bridgestone | 25-50 € | Solution complète, intégration TMS |
| **Verizon Connect** | Verizon | 30-55 € | Premium US/EU, scalable |
| **Geotab** | Geotab | 20-45 € | Open platform, API riche |
| **Continental VDO** | Continental | 25-50 € | Lié au tachy, OEM camions |
| **Frotcom** | Frotcom | 20-40 € | PME, simple à déployer |

### 3.4 Bénéfices mesurés (par étude TLF/FNTR)

| Bénéfice | Gain typique |
|---|---|
| Carburant | -8 à -12 % (écoconduite) |
| Sinistres | -25 à -35 % (formation comportement) |
| Maintenance | -10 à -15 % (prédictif) |
| Productivité conducteur | +5 à +8 % |
| Litiges client | -30 à -50 % (preuves GPS, signatures) |

**ROI** : amortissement de la solution en **6-12 mois** typiquement, sur un véhicule annuel à 100 000 km.

---

## 4. Intégration TMS ↔ Télématique ↔ Chronotachygraphe

### 4.1 Le triangle d'or

L'intégration des **3 systèmes** crée un cercle vertueux :

:::flow
1. TMS planifie | Tournée optimisée envoyée à l'application conducteur
2. Conducteur exécute | App mobile reçoit la tournée + signe les LV
3. Télématique trace | GPS + capteurs remontent en temps réel
4. Chronotachygraphe | Téléchargement automatique données conducteur
5. TMS recoupe | KPIs, anomalies, reporting direction
:::

### 4.2 Téléchargement automatique du chronotachygraphe

Le **chronotachygraphe numérique** (obligatoire depuis 2006) enregistre :
- Conduite, repos, pauses, autres tâches.
- Identifiant conducteur (carte personnelle).
- Identifiant véhicule.

**Téléchargement obligatoire** : tous les **28 jours** (carte conducteur), **90 jours** (mémoire véhicule).

**Solutions** :
- **Manuel** : carte tachy → PC → logiciel (TIS-Web Continental, etc.).
- **Auto** : box télématique (Webfleet, Trimble) qui télécharge à distance, en arrière-plan.
- **Cloud** : remontée automatique vers TMS qui calcule le RSE en temps réel.

⚠️ **Sanction** non-téléchargement : **750 € par carte/par mois** non téléchargée. À ne JAMAIS oublier !

### 4.3 La signature électronique

Sur application mobile conducteur :
- Le destinataire **signe** la livraison sur l'écran (« doigt ou stylet »).
- La signature est **horodatée** + **géolocalisée**.
- La preuve est **archivée** sur le TMS (valeur juridique EIDAS si certifié DocuSign / Yousign).

**Bénéfice** : 80 % de litiges en moins sur les contestations de livraison.

---

## 5. Cas pratique : choix d'un TMS pour PME 8 véhicules

### 5.1 Contexte

Une PME du transport généraliste (national + frontalier) :
- 8 véhicules PL (5 porteurs 19 t, 3 semis 40 t).
- 12 conducteurs.
- 200 commandes/mois.
- CA 1,8 M€.
- Pas de TMS actuel — Excel + Google Maps.

### 5.2 Cahier des charges

| Besoin | Priorité |
|---|---|
| Optimisation tournées auto | **Haute** |
| Application mobile conducteurs | **Haute** |
| Intégration comptabilité Sage | **Haute** |
| Documents CMR + douane | **Moyenne** |
| Multi-utilisateurs (3-4 commerciaux) | **Haute** |
| Reporting KPIs | **Moyenne** |
| Tarif < 1 200 €/mois total | **Haute** |

### 5.3 Comparaison 3 solutions

| TMS | Tarif total | Avantages | Inconvénients |
|---|---|---|---|
| **Akanea** | 8 × 130 = 1 040 €/mois | Standard, intégration douane | Setup long (3-4 mois) |
| **Mantis** | 8 × 90 = 720 €/mois | Rapide à déployer (4-6 sem), TPE/PME | Moins riche en options |
| **Stellium** | 8 × 100 = 800 €/mois | Modulaire web, API ouvertes | Optimisation moyenne |

### 5.4 Décision recommandée

**Mantis** pour cette PME :
- Tarif total **720 €/mois** (en cible budget).
- Setup rapide (gain de mise en route).
- Couverture standards : optimisation, app mobile, Sage.
- À l'usage, possibilité de migration Akanea ou Stellium dans 2-3 ans si besoin de fonctions avancées.

**Coût total an 1** :
- TMS : 720 × 12 = **8 640 €**.
- Setup + formation : **2 000 €**.
- **Total : 10 640 €**.

**ROI estimé** :
- Gain optimisation tournées : -8 % km × 400 000 km/an × 1,2 €/km = **-3 840 €/an**.
- Gain temps planif : 2 h/jour × 220 jours × 35 €/h = **15 400 €/an**.
- Gain facturation auto : 50 % temps admin = **7 000 €/an** estimé.
- **Total gain : 26 240 €/an** ⇒ ROI = **+15 600 € net** an 1, **+17 600 € net** dès an 2.

---

## 6. Ajout de la télématique

### 6.1 Cahier des charges complémentaire

- Tracking GPS temps réel sur les 8 PL.
- Téléchargement auto chronotachygraphes.
- Capteurs température sur les 2 frigorifiques.
- Tableau de bord conducteurs (écoconduite).
- Intégration TMS (échange de données).

### 6.2 Solution recommandée

**Webfleet** + intégration Mantis :
- **Tarif** : 8 × 40 = **320 €/mois** + **1 200 €** matériel (boîtiers).
- **Coût an 1** : 320 × 12 + 1 200 + 1 000 (formation) = **6 040 €**.
- **Gains an 1** :
  - Carburant : -8 % × 400 000 km × 0,30 €/L (8 L/100 km) = **-3 840 €**.
  - Litiges : -40 % × 5 000 € (estim.) = **-2 000 €**.
  - Maintenance : -10 % × 32 000 €/an = **-3 200 €**.
  - **Total gain télématique : 9 040 €/an** ⇒ ROI = **+3 000 € net** an 1.

### 6.3 Bilan TMS + télématique

| Investissement an 1 | 16 680 € |
| Gains an 1 | 35 280 € |
| **ROI net an 1** | **+18 600 €** (≈ 110 % retour) |
| **ROI net an 2+** | **+22 600 €/an** |

⇒ Investissement **incontournable** dès la PME 5+ véhicules.

---

## 7. Cas pratique d'examen

**Énoncé** : Une TPE de 3 fourgonnettes (CA 350 k€) hésite à investir dans un TMS. Le dirigeant pense que c'est « trop cher pour notre taille ». Argumentez votre position en chiffrant.

**Correction proposée** :

**Coûts** :
- TMS léger (Mantis ou Track-POD) : 3 × 60 €/mois = **180 €/mois** = 2 160 €/an.
- Setup + formation (1 jour) : **600 €** an 1.
- Smartphone conducteurs : à fournir (souvent personnel utilisé).
- **Coût total an 1 : 2 760 €** (≈ 0,8 % du CA).

**Gains** :
- Gain temps planif : 1 h/jour × 220 jours × 25 €/h = **5 500 €/an**.
- Gain optimisation tournées : -10 % × 80 000 km × 0,4 €/km = **3 200 €/an**.
- Réduction litiges : -50 % × 1 000 € (estim.) = **500 €/an**.
- **Total gains : 9 200 €/an**.

**ROI** = +6 440 €/an (≈ 230 % retour) **dès l'an 1**.

**Conclusion** : un TMS léger est rentable même en TPE. L'objection « trop cher » ne tient pas face aux chiffres. À comparer au coût de l'**inaction** : -10 % de productivité = -35 000 €/an de manque à gagner pour cette TPE.

**Recommandation** : démarrer avec une solution légère (Mantis ou Track-POD), monter en gamme si la flotte grandit.

---

## 8. Mini-exercice à faire seul

**Énoncé** : Vous gérez 5 PL avec une consommation moyenne de 35 L/100 km, 200 000 km/an. Vous installez la télématique Webfleet à 40 €/véh./mois + 1 000 € matériel. Carburant à 1,80 €/L. Quel est le ROI an 1 si la télématique permet -10 % de carburant ?

> 💡 Réponse en fin de module (corrections § 4).

---

## 9. Glossaire

- **TMS** : Transport Management System.
- **Télématique** : combinaison télécom + informatique embarqués.
- **CAN bus** : bus de communication interne véhicule (capteurs moteur).
- **GNSS** : Global Navigation Satellite System (GPS, Galileo, GLONASS, BeiDou).
- **Chronotachygraphe** : enregistreur de conduite/repos obligatoire (CE 561/2006).
- **TPMS** : Tire Pressure Monitoring System (pression pneus).
- **Écoconduite** : techniques pour réduire la consommation (anticipation, vitesse, régime moteur).
- **EDI** : Échange de Données Informatisées.
- **OEM** : Original Equipment Manufacturer (constructeur véhicule).
- **EIDAS** : règlement européen 2014 sur la signature électronique.

---

## 10. Synthèse opérationnelle

1. **TMS** = 5 modules : CRM/commandes, planification, exécution, facturation, reporting.
2. **Acteurs France** : Akanea, Mantis, Stellium, Datafret pour PME ; PTV/Trimble, Manhattan pour ETI.
3. **Tarif TMS** : 50-150 €/véh./mois selon richesse fonctionnelle.
4. **Télématique** : Trimble, Webfleet, Verizon Connect, Geotab, Frotcom. 20-60 €/véh./mois.
5. **Bénéfices télématique** : -8 à -12 % carburant, -25 % sinistres, -10 % maintenance.
6. **Téléchargement chronotachygraphe** obligatoire (28 j/90 j) — sanction 750 €/carte/mois oubliée.
7. **Intégration TMS + télématique + tachy** = cercle vertueux performance.
8. **ROI** : 6-12 mois sur les gains opérationnels mesurables.

---

## ⚠️ Points de vigilance

- **Ne JAMAIS** oublier le téléchargement chronotachygraphe (sanction lourde).
- **TMS sans application mobile** = obsolète en 2026 (saisie manuelle = perte productivité).
- **Données télématique RGPD** : conducteur informé, accord collectif, finalité explicite.
- **Choix d'un TMS** : pas le moins cher, mais le **plus adapté** à votre activité spécifique.

## 💡 Astuces pro

- **Tester en mode pilote** : 1 véhicule pendant 2-3 mois avant de déployer toute la flotte. Détecter les problèmes tôt.
- **Outil terrain** : application *Routyn* (gratuite) pour visualiser une tournée avant une journée test TMS.
- **Coup malin** : intégration TMS ↔ comptabilité (Sage, Cegid) automatise la facturation (gain 50 % du temps admin).

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : modules d'un TMS, acteurs majeurs, périmètre télématique.
- **QR cas pratique** : « Calculez le ROI d'un TMS pour une PME 6 véhicules. »
- **Oral DP** : « Quel TMS utilisez-vous ? Quelles fonctionnalités exploitez-vous ? Quels gains mesurés ? »

---

## 📌 Synthèse à retenir

### Les 5 modules d'un TMS

| Module | Fonctions |
|---|---|
| **Commandes** | Saisie, devis, EDI, B2B |
| **Planification** | Tournées, optimisation |
| **Exécution** | App conducteurs, signature |
| **Facturation** | Auto, intégration Sage |
| **Reporting** | KPIs, exports |

### Tarifs indicatifs

| Catégorie | Solutions | Tarif/véh./mois |
|---|---|---|
| **TPE** | Mantis, Track-POD | 25-80 € |
| **PME** | Akanea, Mantis, Stellium | 60-150 € |
| **ETI** | PTV, Trimble, Manhattan | 200-400 € |

### Bénéfices télématique mesurés

- **-8 à -12 %** carburant
- **-25 à -35 %** sinistres
- **-10 à -15 %** maintenance
- **+5 à +8 %** productivité conducteur

> ⚠️ **Téléchargement chronotachygraphe**
>
> - Carte conducteur : tous les **28 jours**
> - Mémoire véhicule : tous les **90 jours**
> - Sanction oubli : **750 €/carte/mois**

### ROI typique combiné TMS + télématique

> Investissement : **15-20 000 €/an**
>
> Gains : **30-40 000 €/an**
>
> **ROI net : +15-25 000 €/an** dès l'an 1
$lessonG3$,
'Cartographier les 5 modules d''un TMS, identifier les principaux acteurs (Akanea, Mantis, Stellium, PTV, Trimble), comprendre la télématique embarquée (Webfleet, Trimble, Geotab) et chiffrer un ROI typique : -8/-12 % carburant, -25 % sinistres, -10 % maintenance, retour 6-12 mois.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — KPIs, tableau de bord et amélioration continue
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'KPIs, tableau de bord et amélioration continue',
    'kpis-tableau-bord-amelioration',
    4, 55,
$lessonG4$
# KPIs, tableau de bord et amélioration continue

> 🎯 **Objectifs pédagogiques**
>
> - **Définir** et calculer les KPIs opérationnels, financiers, qualité et sécurité.
> - **Construire** un tableau de bord exploitation 1 page A4.
> - **Diagnostiquer** une déviation négative et établir un plan d'action.
> - **Maîtriser** le PDCA, les 5 pourquoi et le diagramme d'Ishikawa.
> - **Inscrire** l'exploitation dans une démarche qualité (OEA, ISO 9001).

---

## Introduction

**Ce qui ne se mesure pas ne s'améliore pas.** Le service exploitation transport produit chaque jour des centaines de données — km, tonnages, retards, consommation, infractions, satisfaction client. **Sans KPIs**, ces données restent inertes. **Avec KPIs**, elles deviennent un levier de pilotage stratégique.

Le **tableau de bord** est l'outil de référence du chef d'exploitation et du gestionnaire de tournées : 1 page A4, 8-12 indicateurs clés, mise à jour hebdomadaire, distribution direction + chefs d'équipe. Sans tableau de bord, l'amélioration continue est impossible.

À l'oral du DP RNCP 40990, le jury teste **systématiquement** votre culture pilotage : « Citez 3 KPIs que vous suivez chaque semaine et expliquez leur intérêt. »

---

## 1. Cartographier les KPIs

### 1.1 Les 4 familles d'indicateurs

| Famille | Sujet | Exemples |
|---|---|---|
| **Opérationnels** | Performance d'exécution | Ponctualité, OTIF, remplissage |
| **Financiers** | Marges et productivité | €/km, marge brute, productivité conducteur |
| **Qualité** | Satisfaction et conformité | Taux réclamations, NPS |
| **Sécurité** | Risques humains et matériels | Accidents, infractions RSE |

### 1.2 Vue d'ensemble (12 KPIs essentiels)

| KPI | Famille | Cible typique |
|---|---|---|
| Taux de ponctualité | Opér. | ≥ 95 % |
| OTIF (On Time In Full) | Opér. | ≥ 90 % |
| Taux remplissage | Opér. | ≥ 80 % |
| Taux retours à vide | Opér. | < 15 % |
| Coût/km | Fin. | -5 % YoY |
| Marge brute par tournée | Fin. | ≥ 18 % |
| Productivité conducteur | Fin. | ≥ 35 €/h CA |
| Taux réclamations | Qualité | < 1 % |
| Satisfaction client (NPS) | Qualité | ≥ +50 |
| Taux d'accidents | Sécurité | < 1/100 000 km |
| Infractions RSE | Sécurité | < 1/100 conducteur/an |
| Conducteurs au DUER | Sécurité | 100 % |

---

## 2. KPIs opérationnels

### 2.1 Taux de ponctualité

**Définition** : pourcentage de livraisons dans la fenêtre horaire convenue avec le client.

**Formule** :
```
Ponctualité (%) = (Livraisons dans fenêtre / Livraisons totales) × 100
```

**Cibles** :
- **≥ 98 %** : best-in-class.
- **≥ 95 %** : standard pro.
- **< 90 %** : zone rouge — perte de clients.

**Mesure** : automatique via TMS / signature électronique horodatée.

### 2.2 OTIF — On Time In Full

**Définition** : pourcentage de livraisons **à l'heure ET complètes** (sans manquant ni avarie).

**Formule** :
```
OTIF (%) = (Livraisons OTIF / Livraisons totales) × 100
```

**Cibles** :
- **≥ 95 %** : best-in-class.
- **≥ 90 %** : standard pro.
- **< 85 %** : zone rouge.

OTIF est plus exigeant que la ponctualité : un retard ou une marchandise manquante ⇒ KO.

### 2.3 Taux de remplissage

**Définition** : utilisation effective de la capacité véhicule, en poids ou volume.

**Formule** (en poids) :
```
Remplissage (%) = (Poids transporté / PTAC utile) × 100
```

**Cibles** :
- **≥ 85 %** : excellent.
- **70-85 %** : standard.
- **< 70 %** : zone à améliorer (groupage ?, restructurer tournées).

### 2.4 Taux de retours à vide

**Définition** : pourcentage de km parcourus sans marchandise (retour dépôt).

**Formule** :
```
Retours à vide (%) = (Km à vide / Km totaux) × 100
```

**Cibles** :
- **< 10 %** : best-in-class (groupage parfait).
- **< 15 %** : standard.
- **> 25 %** : zone rouge (revoir tournées).

**Levier** : développer le commercial **fret retour** (bourse de fret, partenariats).

---

## 3. KPIs financiers

### 3.1 Coût/km

**Définition** : coût d'exploitation par kilomètre parcouru.

**Formule** :
```
Coût/km = Coûts totaux / Km totaux
```

Coûts totaux = carburant + amortissement véhicule + entretien + assurance + péages + salaires conducteurs + structure.

**Cibles** : **1,15-1,40 €/km** pour PL standard en France 2026. À benchmarker contre la moyenne sectorielle (TLF/FNTR).

### 3.2 Marge brute par tournée

**Définition** : marge entre le prix facturé et le coût direct de la tournée.

**Formule** :
```
Marge brute (%) = ((CA tournée − Coût direct) / CA tournée) × 100
```

**Cibles** :
- **≥ 20 %** : standard.
- **≥ 25 %** : excellent.
- **< 15 %** : zone rouge — pas rentable structurellement.

### 3.3 Productivité conducteur

**Définition** : CA généré par heure travaillée.

**Formule** :
```
Productivité = CA tournée / Heures travaillées
```

**Cibles** :
- **≥ 40 €/h** : best-in-class.
- **30-40 €/h** : standard.
- **< 25 €/h** : à diagnostiquer.

---

## 4. KPIs qualité

### 4.1 Taux de réclamations

**Définition** : pourcentage de livraisons donnant lieu à une réclamation client.

**Formule** :
```
Réclamations (%) = (Réclamations / Livraisons totales) × 100
```

**Cibles** :
- **< 0,5 %** : excellent.
- **< 1 %** : standard.
- **> 2 %** : zone rouge — diagnostic urgent.

**Catégoriser** : avarie / retard / manquant / facture / SAV.

### 4.2 NPS (Net Promoter Score)

**Définition** : indicateur de satisfaction client.

**Formule** : enquête « Recommanderiez-vous nos services ? Note 0-10 ».
- Note 9-10 = Promoteurs (P).
- Note 7-8 = Passifs.
- Note 0-6 = Détracteurs (D).
```
NPS = % Promoteurs − % Détracteurs
```

**Cibles** :
- **≥ +50** : excellent.
- **+30 à +50** : bon.
- **< +20** : à améliorer.

---

## 5. KPIs sécurité

### 5.1 Taux d'accidents

**Définition** : nombre d'accidents responsables ramené à un volume kilométrique.

**Formule** :
```
Taux accidents = (Nb accidents responsables / Km totaux) × 100 000
```

**Cibles** :
- **< 0,5/100 000 km** : excellent.
- **< 1/100 000 km** : standard.
- **> 2/100 000 km** : zone rouge.

### 5.2 Infractions RSE

**Définition** : nombre d'infractions au Règlement Social Européen détectées via chronotachygraphe.

**Formule** :
```
Infractions RSE = Nb infractions / Conducteurs × 12 (mensuel)
```

**Cibles** :
- **< 1/conducteur/an** : conformité standard.
- **0** : objectif zéro tolérance.

### 5.3 Conducteurs au DUER

**Définition** : pourcentage de conducteurs disposant d'un Document Unique d'Évaluation des Risques à jour (obligatoire).

**Cible** : **100 %** systématiquement.

---

## 6. Construire un tableau de bord 1 page A4

### 6.1 Structure recommandée

Le tableau de bord doit tenir sur **1 page A4** lisible en 30 secondes :

| Section | Contenu |
|---|---|
| **En-tête** | Période, distributeur, date de mise à jour |
| **KPIs clés** (8-12) | Indicateurs avec valeur + cible + tendance |
| **Graphiques** | 2-3 graphiques évolution (12 derniers mois) |
| **Faits marquants** | 3 faits importants de la semaine |
| **Plan d'action** | 2-3 actions correctives en cours |

### 6.2 Codes visuels

- 🟢 Vert : KPI ≥ cible.
- 🟡 Jaune : KPI 80-100 % de la cible.
- 🔴 Rouge : KPI < 80 % de la cible.
- ↑ Tendance positive vs mois précédent.
- ↓ Tendance négative.

### 6.3 Exemple synthétique

**Semaine 19 — Tableau de bord exploitation**

| KPI | Valeur | Cible | Tendance |
|---|---|---|---|
| Ponctualité | 87 % 🔴 | 95 % | ↓ |
| OTIF | 82 % 🔴 | 90 % | ↓ |
| Remplissage | 78 % 🟡 | 80 % | → |
| Retours vide | 18 % 🟡 | 15 % | ↑ |
| Coût/km | 1,28 € 🟢 | 1,30 € | → |
| Marge brute | 19 % 🟢 | 18 % | ↑ |
| Réclamations | 1,8 % 🔴 | 1,0 % | ↑ |
| Accidents | 0/100k km 🟢 | < 1 | → |

**Faits marquants** : (1) panne semi-remorque mardi → 6 retards. (2) absent chauffeur jeudi → tournée reprogrammée. (3) gain commande Carrefour 50 k€/mois.

**Plan d'action** : (1) audit pannes mécaniques → maintenance préventive. (2) plan B chauffeurs intérim. (3) revoir tarifs nouvelles commandes.

### 6.4 Diffusion

- **Direction** : 1 fois par mois (synthèse).
- **Chefs d'équipe** : 1 fois par semaine.
- **Conducteurs** : focus 3 KPIs (ponctualité, écoconduite, réclamations) en réunion mensuelle.

---

## 7. Cas pratique : diagnostic d'une dérive

### 7.1 Énoncé

Au tableau de bord ci-dessus, la **ponctualité** est passée de 96 % à 87 % en 4 semaines. Le directeur demande un diagnostic et un plan d'action sous 7 jours.

### 7.2 Méthode des 5 pourquoi

1. **Pourquoi** la ponctualité est à 87 % ?
   → Parce que 13 % des livraisons sont en retard.
2. **Pourquoi** ces livraisons sont en retard ?
   → Parce que les tournées dépassent l'amplitude prévue.
3. **Pourquoi** les tournées dépassent l'amplitude ?
   → Parce que les temps de manutention sont sous-estimés (15 min au lieu de 25 min réels).
4. **Pourquoi** les temps de manutention sont sous-estimés ?
   → Parce que la base de données du TMS n'a pas été mise à jour depuis 2 ans, et 5 nouveaux clients GMS ont été ajoutés sans mesure terrain.
5. **Pourquoi** la base de données n'a pas été mise à jour ?
   → Parce qu'aucun process formalisé n'existe pour réaudit annuel.

⇒ **Cause racine** : absence de process de réaudit annuel des temps de manutention.

### 7.3 Diagramme d'Ishikawa

Causes possibles classées en **6M** :

| Catégorie | Causes potentielles |
|---|---|
| **Main d'œuvre** | Manque formation conducteurs nouveaux clients |
| **Matériel** | Pannes véhicules récurrentes |
| **Méthode** | Pas de réaudit temps manutention |
| **Milieu** | Travaux périphérie urbaine, ZFE |
| **Mesure** | TMS pas à jour |
| **Matière** | Marchandises plus difficiles à manuter |

### 7.4 Plan d'action en PDCA

| Phase | Action | Responsable | Délai |
|---|---|---|---|
| **Plan** | Audit terrain 5 nouveaux clients GMS | Chef expl. | J+5 |
| **Plan** | Mise à jour TMS temps manut. | Resp. TMS | J+10 |
| **Do** | Application des nouveaux temps | Tournées J+11 | J+11 |
| **Check** | Mesure ponctualité S+2 | Chef expl. | J+25 |
| **Act** | Process réaudit annuel formalisé | Direction | J+30 |

⇒ Cible : ponctualité retour à 95 % d'ici 4 semaines.

---

## 8. Méthode PDCA et amélioration continue

### 8.1 Le cycle PDCA (Deming)

:::flow
1. Plan | Identifier le problème, analyser, planifier une action
2. Do | Mettre en œuvre l'action (pilote ou général)
3. Check | Mesurer les résultats vs objectifs
4. Act | Standardiser si succès, corriger si échec
:::

**Force** : itératif, scientifique, applicable à tout problème opérationnel.

### 8.2 Outils complémentaires

| Outil | Usage |
|---|---|
| **5 pourquoi** | Trouver la cause racine |
| **Ishikawa (6M)** | Cartographier toutes les causes possibles |
| **Pareto (80/20)** | Hiérarchiser les problèmes prioritaires |
| **SWOT** | Audit stratégique global |
| **5S** | Organisation poste de travail (atelier, dépôt) |

### 8.3 Routine professionnelle

| Fréquence | Activité |
|---|---|
| Quotidien | Suivi KPIs temps réel sur TMS |
| Hebdo | Tableau de bord 1 page A4 + revue chef d'équipe |
| Mensuel | Revue directeur + plan d'action |
| Trimestriel | Bilan + ajustement objectifs annuels |
| Annuel | Réaudit complet + bilan RSE/qualité |

---

## 9. Référentiels qualité et certifications

### 9.1 OEA — Opérateur Économique Agréé

**Statut douanier** européen pour transporteurs internationaux. Bénéfices :
- Procédures douanières simplifiées.
- Délais de dédouanement réduits.
- Image et confiance vis-à-vis des partenaires UE.

**Conditions** :
- Honorabilité (casier judiciaire des dirigeants).
- Solvabilité financière.
- Conformité douanière (3 ans audits).
- Sûreté/sécurité (procédures internes).

### 9.2 ISO 9001 — Management de la qualité

Certification généraliste applicable au transport : process documentés, mesures, amélioration continue. Coût : 5 000-15 000 € certification + 2 000-5 000 €/an audits.

### 9.3 Certifications transport spécifiques

| Certification | Domaine | Audit |
|---|---|---|
| **OEA-S** (Sûreté) | Douanes intl. | Bureau Veritas |
| **AEO** (UE) | Douanes intl. | Douanes |
| **TAPA-FSR** | Sûreté fret | TAPA Association |
| **SQAS** | Chimie | Cefic |
| **GDP** | Pharmaceutique | Bureau Veritas |
| **IFS Logistic** | Agroalimentaire | IFS |

### 9.4 Cas pratique : ROI d'une certification

**ISO 9001** pour PME 8 véhicules :
- Coût mise en place : 8 000 €.
- Audits annuels : 2 500 €/an.
- Gains :
  - Accès marchés exigeants (grands comptes, gros DO) : +5-10 % CA potentiel.
  - Réduction réclamations : -30 % grâce à process documentés.
  - Image marketing : différenciation.
- ROI : +15 000 €/an estimé pour PME 1,8 M€ CA.

---

## 10. Cas pratique d'examen

**Énoncé** : Vous prenez les commandes d'un service exploitation 6 véhicules avec ces indicateurs : ponctualité 88 %, OTIF 81 %, marge brute 14 %, taux réclamations 2,3 %. La direction veut une amélioration mesurable en 3 mois.

**Question** : Construisez le plan d'action complet (diagnostic + 5 leviers + KPIs de pilotage + ROI estimé).

**Correction proposée** :

**Diagnostic** :
- Ponctualité 88 % et OTIF 81 % = problème opérationnel (planif ou exécution).
- Marge 14 % = sous le standard 18-20 %.
- Réclamations 2,3 % = au-dessus du seuil 1 %.

**Leviers** :

1. **Audit qualité données TMS** (J+30) : remettre à jour temps manut., adresses, créneaux. Coût : 30 h × 35 €/h = 1 050 €. Gain ponctualité estimé +5 pts.

2. **Optimisation tournées** (J+45) : passer de manuel à automatique TMS. Gain km : -8 %. -8 % × 250 000 km × 1,2 €/km = -2 400 €/mois.

3. **Formation conducteurs** (J+60) : 1 jour écoconduite + manutention. Coût : 6 × 250 € = 1 500 €. Gain réclamations -40 %, conso -8 %.

4. **Standardisation refus livraison** (J+30) : check-list au chargement, refus argumenté si conditionnement non conforme. Gain : -50 % réclamations type avarie.

5. **Tableau de bord hebdo** (J+15) : revue 1 page avec chef d'équipe. Gain : visibilité et engagement.

**KPIs de pilotage** :
- Ponctualité S+1, S+2, S+4, S+8, S+12.
- Marge brute mensuelle.
- Réclamations hebdomadaires.

**ROI estimé sur 3 mois** :
- Coûts : 5 000 € total.
- Gains : ponctualité +5 pts → +2 % CA conservé (estim.) = +12 000 €. Marge +3 pts = +9 000 €. Réclamations -50 % = -3 000 € indemnités.
- **ROI total +19 000 € en 3 mois** ⇒ extension de la démarche an 1.

---

## 11. Mini-exercice à faire seul

**Énoncé** : Calculez le NPS d'une enquête : 100 répondants, 60 promoteurs (notes 9-10), 25 passifs (7-8), 15 détracteurs (0-6).

> 💡 Réponse en fin de module (corrections § 4).

---

## 12. Corrections des mini-exercices du module

### Leçon 1 — Pause RSE pour 8 livraisons sur 350 km
- Conduite estimée : 350 km / 50 km/h = **7 h**.
- Manutention : 8 × 20 min = **2 h 40**.
- **Pause obligatoire** après 4 h 30 de conduite continue ⇒ vers 11h30 (démarrage 7h + 4 h 30 conduite).
- **Réponse** : pause 45 min OBLIGATOIRE vers 11h30, à programmer après le 4-5ᵉ arrêt typiquement.

### Leçon 2 — Économie Clarke & Wright
- Données : D-C2 = 12, D-C3 = 15, C2-C3 = 5.
- **S(C2,C3) = 12 + 15 − 5 = 22**.
- Comparaison : S(C1,C2) = 8 + 12 − 6 = 14, S(C3,C4) = 15 + 20 − 7 = 28.
- ⇒ **Regroupement prioritaire C3 + C4** (économie 28 km), puis C2 + C3 (22 km), puis C1 + C2 (14 km).

### Leçon 3 — ROI télématique 5 PL
- **Coût an 1** : 5 × 40 €/mois × 12 + 5 × 1 000 € matériel = 2 400 + 5 000 = **7 400 €**.
- **Gain carburant** : 5 × 200 000 km × 35 L/100 km × 1,80 €/L × 10 % = **6 300 €**.
- **Gains autres** (sinistres, maintenance, productivité, estimation) : **+5 000 €**.
- **Total gains an 1** : **11 300 €**.
- **ROI net an 1** = 11 300 − 7 400 = **+3 900 €** (≈ 53 % retour). Amortissement matériel intégré an 1.

### Leçon 4 — Calcul NPS
- **Promoteurs** : 60 / 100 = **60 %**.
- **Détracteurs** : 15 / 100 = **15 %**.
- **NPS = 60 − 15 = +45**.
- Interprétation : bon score (cible ≥ +50). Marge de progression sur les passifs (à transformer en promoteurs).

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : formules KPIs, cibles, méthode PDCA, certifications.
- **QR cas pratique** : « Diagnostiquez la dérive du tableau de bord suivant et proposez un plan d'action. »
- **Oral DP** : « Citez 3 KPIs que vous suivez chaque semaine et expliquez leur intérêt. »

---

## 📌 Synthèse à retenir

### Les 12 KPIs essentiels

**Opérationnels** (4) : ponctualité, OTIF, remplissage, retours à vide.
**Financiers** (3) : coût/km, marge brute, productivité conducteur.
**Qualité** (2) : taux réclamations, NPS.
**Sécurité** (3) : accidents, infractions RSE, DUER.

### Cibles standards

| KPI | Cible |
|---|---|
| Ponctualité | ≥ **95 %** |
| OTIF | ≥ **90 %** |
| Remplissage | ≥ **80 %** |
| Retours à vide | < **15 %** |
| Marge brute | ≥ **18 %** |
| Réclamations | < **1 %** |
| NPS | ≥ **+50** |
| Accidents | < **1/100 000 km** |

### Méthode PDCA

> **Plan** : identifier, analyser, planifier
>
> **Do** : mettre en œuvre
>
> **Check** : mesurer
>
> **Act** : standardiser ou corriger

### Outils diagnostic

- **5 pourquoi** : trouver la cause racine
- **Ishikawa (6M)** : cartographier toutes les causes
- **Pareto (80/20)** : prioriser
- **SWOT** : audit stratégique

### Tableau de bord 1 page A4

- En-tête (période, distribution)
- 8-12 KPIs avec valeur + cible + tendance
- Codes visuels (vert / jaune / rouge)
- 3 faits marquants
- 2-3 actions correctives en cours

> ⚠️ **Routine professionnelle**
>
> - **Quotidien** : suivi KPIs sur TMS
> - **Hebdo** : tableau de bord + revue chef d'équipe
> - **Mensuel** : revue directeur + plan d'action
> - **Trimestriel** : bilan + ajustement objectifs
> - **Annuel** : réaudit complet + RSE/qualité

### Certifications utiles

- **OEA** : statut douanier européen
- **ISO 9001** : management qualité (5-15 k€)
- **GDP** : pharmaceutique
- **IFS Logistic** : agroalimentaire
$lessonG4$,
'Maîtriser les 12 KPIs essentiels (ponctualité ≥ 95 %, OTIF ≥ 90 %, marge brute ≥ 18 %, réclamations < 1 %), construire un tableau de bord 1 page A4, diagnostiquer via PDCA / 5 pourquoi / Ishikawa, inscrire l''exploitation dans une démarche qualité (OEA, ISO 9001).'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- BANQUE DE QUESTIONS — 48 QCM + 8 QR
  -- =================================================================

  -- ===== LEÇON 1 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'Combien d''étapes contient la méthodologie de planification professionnelle ?',
   '[{"id":"a","label":"3","is_correct":false},{"id":"b","label":"5","is_correct":true},{"id":"c","label":"7","is_correct":false},{"id":"d","label":"10","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-06','lecon-1','methodologie'], 'mft-2026-gotrm:bc01-06-v3:l1:q1', true,
   '5 étapes : recueil données → analyse contraintes → géocodage → construction → validation.'),
  (v_formation, v_module, 'qcm', 'Le RSE (Règlement Social Européen) limite la conduite continue à :',
   '[{"id":"a","label":"3 h avant pause 30 min","is_correct":false},{"id":"b","label":"4 h 30 avant pause 45 min","is_correct":true},{"id":"c","label":"6 h avant pause 60 min","is_correct":false},{"id":"d","label":"8 h sans pause","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-06','lecon-1','rse'], 'mft-2026-gotrm:bc01-06-v3:l1:q2', true,
   'CE 561/2006 : 4 h 30 conduite continue → pause 45 min obligatoire (peut être fractionnée 15 min + 30 min).'),
  (v_formation, v_module, 'qcm', 'La conduite quotidienne maximale est de :',
   '[{"id":"a","label":"6 h","is_correct":false},{"id":"b","label":"8 h","is_correct":false},{"id":"c","label":"9 h (10 h × 2/sem.)","is_correct":true},{"id":"d","label":"12 h","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-06','lecon-1','rse'], 'mft-2026-gotrm:bc01-06-v3:l1:q3', true,
   '9 h conduite/jour, possibilité de 10 h × 2 fois/semaine. Hebdomadaire 56 h max, 90 h sur 2 semaines glissantes.'),
  (v_formation, v_module, 'qcm', 'Le repos quotidien obligatoire est de :',
   '[{"id":"a","label":"8 h","is_correct":false},{"id":"b","label":"11 h consécutives","is_correct":true},{"id":"c","label":"15 h","is_correct":false},{"id":"d","label":"24 h","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-06','lecon-1','rse'], 'mft-2026-gotrm:bc01-06-v3:l1:q4', true,
   '11 h consécutives (réduit à 9 h × 3 fois/semaine). Repos hebdomadaire 45 h, réduit à 24 h × 1 fois/2 sem.'),
  (v_formation, v_module, 'qcm', 'Le géocodage consiste à :',
   '[{"id":"a","label":"Coder un mot de passe","is_correct":false},{"id":"b","label":"Convertir une adresse en coordonnées GPS (latitude/longitude)","is_correct":true},{"id":"c","label":"Crypter un mail","is_correct":false},{"id":"d","label":"Mesurer le poids d''un colis","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-06','lecon-1','geocodage'], 'mft-2026-gotrm:bc01-06-v3:l1:q5', true,
   'Géocodage = adresse postale → coordonnées GPS. Indispensable pour fiabiliser le calcul d''itinéraire (Google Maps API, OpenStreetMap, Bing Maps).'),
  (v_formation, v_module, 'qcm', 'Quel service N''EST PAS un fournisseur de géocodage ?',
   '[{"id":"a","label":"Google Maps API","is_correct":false},{"id":"b","label":"OpenStreetMap","is_correct":false},{"id":"c","label":"Bing Maps","is_correct":false},{"id":"d","label":"AutoCAD","is_correct":true}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-06','lecon-1','geocodage'], 'mft-2026-gotrm:bc01-06-v3:l1:q6', true,
   'AutoCAD = logiciel CAO. Les services de géocodage : Google Maps API, OpenStreetMap, Bing Maps, Here Maps, Mapbox.'),
  (v_formation, v_module, 'qcm', 'Pour planifier une tournée PL, le calcul d''itinéraire doit être en :',
   '[{"id":"a","label":"Mode voiture (par défaut)","is_correct":false},{"id":"b","label":"Mode camion (PL) avec hauteur, largeur, poids","is_correct":true},{"id":"c","label":"Mode piéton","is_correct":false},{"id":"d","label":"Mode vélo","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-06','lecon-1','itineraire'], 'mft-2026-gotrm:bc01-06-v3:l1:q7', true,
   'Mode camion indispensable : prend en compte hauteur (4 m), largeur (2,55 m), poids (44 t), interdictions PL et périodes interdites. Solutions : PTV Map&Guide, Trimble, Sygic Truck.'),
  (v_formation, v_module, 'qcm', 'Quand publier idéalement la feuille de tournée au conducteur ?',
   '[{"id":"a","label":"Le matin même 7h","is_correct":false},{"id":"b","label":"La veille à 18h max","is_correct":true},{"id":"c","label":"3 jours avant","is_correct":false},{"id":"d","label":"Au démarrage du véhicule","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-06','lecon-1','publication'], 'mft-2026-gotrm:bc01-06-v3:l1:q8', true,
   'Norme pro : feuille de tournée disponible la veille 18h max. Permet préparation, vérification documents, planification personnelle.'),
  (v_formation, v_module, 'qcm', 'L''amplitude maximale d''une journée conducteur PL est de :',
   '[{"id":"a","label":"10 h","is_correct":false},{"id":"b","label":"12 h","is_correct":false},{"id":"c","label":"15 h","is_correct":true},{"id":"d","label":"24 h","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-06','lecon-1','amplitude'], 'mft-2026-gotrm:bc01-06-v3:l1:q9', true,
   '15 h amplitude maximale (entre 2 repos quotidiens). Comprend conduite + manutention + pauses + autres tâches.'),
  (v_formation, v_module, 'qcm', 'Une ZFE (Zone à Faibles Émissions) impose des restrictions selon :',
   '[{"id":"a","label":"Le poids du véhicule","is_correct":false},{"id":"b","label":"La vignette Crit''Air","is_correct":true},{"id":"c","label":"L''ancienneté du conducteur","is_correct":false},{"id":"d","label":"Le département d''immatriculation","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-06','lecon-1','zfe'], 'mft-2026-gotrm:bc01-06-v3:l1:q10', true,
   'ZFE (Paris, Lyon, Grenoble, etc.) : restrictions selon vignette Crit''Air (0 à 5). Crit''Air 5 et 4 souvent interdits, 3 progressivement.'),
  (v_formation, v_module, 'qcm', 'Pour une PME de 5-30 véhicules, le mode de planification recommandé est :',
   '[{"id":"a","label":"Excel manuel exclusivement","is_correct":false},{"id":"b","label":"TMS standard (Akanea, Mantis, Stellium)","is_correct":true},{"id":"c","label":"Tableau papier","is_correct":false},{"id":"d","label":"Pas de planification","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-06','lecon-1','tms'], 'mft-2026-gotrm:bc01-06-v3:l1:q11', true,
   'TPE 1-3 véh. : Excel + Google Maps. PME 5-30 véh. : TMS standard (Akanea, Mantis, Stellium). ETI 30+ : TMS premium (PTV, Trimble, Manhattan).'),
  (v_formation, v_module, 'qcm', 'Combien de pauses RSE sont obligatoires sur une journée 8 h conduite ?',
   '[{"id":"a","label":"0","is_correct":false},{"id":"b","label":"1 pause de 45 min après 4 h 30","is_correct":true},{"id":"c","label":"2 pauses de 30 min","is_correct":false},{"id":"d","label":"4 pauses de 15 min","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-06','lecon-1','pauses'], 'mft-2026-gotrm:bc01-06-v3:l1:q12', true,
   'Sur 8 h conduite, 1 pause de 45 min obligatoire après 4 h 30 continues. La pause peut être fractionnée 15 min + 30 min, mais cette dernière doit toujours être ≥ 30 min.');

  -- ===== LEÇON 2 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'TSP signifie :',
   '[{"id":"a","label":"Transport System Plan","is_correct":false},{"id":"b","label":"Travelling Salesman Problem (voyageur de commerce)","is_correct":true},{"id":"c","label":"Total Storage Process","is_correct":false},{"id":"d","label":"Truck Speed Pattern","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-06','lecon-2','tsp'], 'mft-2026-gotrm:bc01-06-v3:l2:q1', true,
   'TSP = Travelling Salesman Problem. Problème classique : N villes à visiter une fois, chemin le plus court qui revient au départ. Complexité N!.'),
  (v_formation, v_module, 'qcm', 'VRP signifie :',
   '[{"id":"a","label":"Vehicle Reduction Programme","is_correct":false},{"id":"b","label":"Vehicle Routing Problem","is_correct":true},{"id":"c","label":"Volume Recovery Process","is_correct":false},{"id":"d","label":"Variable Route Planning","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-06','lecon-2','vrp'], 'mft-2026-gotrm:bc01-06-v3:l2:q2', true,
   'VRP = Vehicle Routing Problem. Extension du TSP avec plusieurs véhicules + dépôts. C''est le problème quotidien d''un GOTRM.'),
  (v_formation, v_module, 'qcm', 'La méthode du Sweep utilise un tri par :',
   '[{"id":"a","label":"Ordre alphabétique","is_correct":false},{"id":"b","label":"Angle polaire depuis le dépôt","is_correct":true},{"id":"c","label":"Poids décroissant","is_correct":false},{"id":"d","label":"Distance au hasard","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-06','lecon-2','sweep'], 'mft-2026-gotrm:bc01-06-v3:l2:q3', true,
   'Sweep = balayage. Tri par angle polaire (atan2) depuis le dépôt, affectation aux véhicules par capacité. Simple, intuitif géographiquement.'),
  (v_formation, v_module, 'qcm', 'La méthode du plus proche voisin est :',
   '[{"id":"a","label":"Optimale","is_correct":false},{"id":"b","label":"Itérative et myope (peut être 10-30 % pire que l''optimum)","is_correct":true},{"id":"c","label":"Aléatoire","is_correct":false},{"id":"d","label":"Réservée aux GMS","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-06','lecon-2','ppv'], 'mft-2026-gotrm:bc01-06-v3:l2:q4', true,
   'Plus proche voisin (Nearest Neighbour) : depuis le point courant, aller au plus proche non visité. Très simple mais myope (vision locale uniquement).'),
  (v_formation, v_module, 'qcm', 'La méthode des économies de Clarke & Wright a été publiée en :',
   '[{"id":"a","label":"1924","is_correct":false},{"id":"b","label":"1964","is_correct":true},{"id":"c","label":"1984","is_correct":false},{"id":"d","label":"2004","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-06','lecon-2','clarke'], 'mft-2026-gotrm:bc01-06-v3:l2:q5', true,
   'Clarke & Wright 1964. Méthode standard, encore utilisée dans 70 % des TMS modernes. Très bon compromis simplicité/qualité.'),
  (v_formation, v_module, 'qcm', 'La formule de l''économie de Clarke & Wright est :',
   '[{"id":"a","label":"S(i,j) = D(i,j)","is_correct":false},{"id":"b","label":"S(i,j) = D(0,i) + D(0,j) − D(i,j)","is_correct":true},{"id":"c","label":"S(i,j) = D(0,i) × D(0,j)","is_correct":false},{"id":"d","label":"S(i,j) = max(D(0,i), D(0,j))","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-06','lecon-2','formule'], 'mft-2026-gotrm:bc01-06-v3:l2:q6', true,
   'Économie = somme des allers-retours dépôt évités − distance directe entre i et j. Plus S est élevé, plus regrouper i et j est intéressant.'),
  (v_formation, v_module, 'qcm', 'Le recuit simulé est inspiré de :',
   '[{"id":"a","label":"L''évolution darwinienne","is_correct":false},{"id":"b","label":"Le refroidissement progressif des métaux","is_correct":true},{"id":"c","label":"La théorie des graphes","is_correct":false},{"id":"d","label":"La physique quantique","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-06','lecon-2','recuit'], 'mft-2026-gotrm:bc01-06-v3:l2:q7', true,
   'Recuit simulé (Simulated Annealing) inspiré de la métallurgie : la « température » diminue, on accepte parfois des dégradations locales pour sortir des optimums locaux.'),
  (v_formation, v_module, 'qcm', 'Une time window est :',
   '[{"id":"a","label":"Une horloge dans le véhicule","is_correct":false},{"id":"b","label":"Une fenêtre horaire de livraison autorisée","is_correct":true},{"id":"c","label":"Le temps de pause RSE","is_correct":false},{"id":"d","label":"L''heure de fermeture du dépôt","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-06','lecon-2','timewindow'], 'mft-2026-gotrm:bc01-06-v3:l2:q8', true,
   'Time window = fenêtre horaire pendant laquelle la livraison est autorisée (ex : GMS 30 min strictes, industriel 1-2 h).'),
  (v_formation, v_module, 'qcm', 'Le gain typique d''optimisation des tournées sur les km totaux est de :',
   '[{"id":"a","label":"-1 à -2 %","is_correct":false},{"id":"b","label":"-8 à -12 %","is_correct":true},{"id":"c","label":"-30 à -40 %","is_correct":false},{"id":"d","label":"-50 à -60 %","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-06','lecon-2','gains'], 'mft-2026-gotrm:bc01-06-v3:l2:q9', true,
   'Optimisation TMS bien paramétrée : -8 à -12 % km vs base manuelle. Au-delà = exagéré ou base non comparable.'),
  (v_formation, v_module, 'qcm', 'Pour minimiser une tournée, le critère cible recommandé est :',
   '[{"id":"a","label":"Les km purs uniquement","is_correct":false},{"id":"b","label":"Le coût total (km + heures + pénalités créneaux)","is_correct":true},{"id":"c","label":"Le poids transporté","is_correct":false},{"id":"d","label":"Le nombre d''arrêts","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-06','lecon-2','optimisation'], 'mft-2026-gotrm:bc01-06-v3:l2:q10', true,
   'Coût total = km × CRKM + heures × coût horaire + pénalités créneaux + amortissement. Optimisation pure km peut violer fenêtres ou surcharger conducteurs.'),
  (v_formation, v_module, 'qcm', 'Quel taux de remplissage cible viser ?',
   '[{"id":"a","label":"50 %","is_correct":false},{"id":"b","label":"≥ 80 %","is_correct":true},{"id":"c","label":"100 % systématique","is_correct":false},{"id":"d","label":"Aucune cible","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-06','lecon-2','remplissage'], 'mft-2026-gotrm:bc01-06-v3:l2:q11', true,
   'Cible ≥ 80 % en poids ou volume. 100 % systématique = surcharge ou pas de marge pour imprévu. < 70 % = à améliorer (groupage, restructuration).'),
  (v_formation, v_module, 'qcm', 'Un algorithme génétique fait évoluer :',
   '[{"id":"a","label":"Une seule solution à la fois","is_correct":false},{"id":"b","label":"Une population de solutions par croisements et mutations","is_correct":true},{"id":"c","label":"L''ADN du conducteur","is_correct":false},{"id":"d","label":"La carte routière","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-06','lecon-2','genetique'], 'mft-2026-gotrm:bc01-06-v3:l2:q12', true,
   'Algorithmes génétiques : population de 50-100 solutions, croisements (combinaisons de 2 parents), mutations (modifications aléatoires), sélection des meilleures. Inspiré de l''évolution.');

  -- ===== LEÇON 3 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'Un TMS comporte typiquement combien de modules clés ?',
   '[{"id":"a","label":"2","is_correct":false},{"id":"b","label":"5 (commandes, planif, exécution, factu, reporting)","is_correct":true},{"id":"c","label":"15","is_correct":false},{"id":"d","label":"50","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-06','lecon-3','tms'], 'mft-2026-gotrm:bc01-06-v3:l3:q1', true,
   'TMS = 5 modules : CRM/commandes (saisie, EDI), planification (tournées, optim.), exécution (app conducteurs, signature), facturation (auto, intégration), reporting (KPIs).'),
  (v_formation, v_module, 'qcm', 'Quel est un éditeur français majeur de TMS ?',
   '[{"id":"a","label":"Microsoft","is_correct":false},{"id":"b","label":"Akanea","is_correct":true},{"id":"c","label":"Apple","is_correct":false},{"id":"d","label":"Google","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-06','lecon-3','akanea'], 'mft-2026-gotrm:bc01-06-v3:l3:q2', true,
   'Akanea = référent français en TMS (douane, transport intl., commission). Autres acteurs : Mantis, Stellium, Datafret, EVALI/AS400.'),
  (v_formation, v_module, 'qcm', 'Le tarif typique d''un TMS standard PME est de :',
   '[{"id":"a","label":"5 €/véh./mois","is_correct":false},{"id":"b","label":"60-150 €/véh./mois","is_correct":true},{"id":"c","label":"500-1000 €/véh./mois","is_correct":false},{"id":"d","label":"Gratuit","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-06','lecon-3','tarif'], 'mft-2026-gotrm:bc01-06-v3:l3:q3', true,
   'TMS standard PME : 60-150 €/véhicule/mois. TPE : 25-80 €. ETI premium : 200-400 €/véh./mois.'),
  (v_formation, v_module, 'qcm', 'La télématique embarquée permet de mesurer :',
   '[{"id":"a","label":"Uniquement la position GPS","is_correct":false},{"id":"b","label":"Position, vitesse, conso, comportement, températures, pression pneus","is_correct":true},{"id":"c","label":"Le poids du conducteur","is_correct":false},{"id":"d","label":"La couleur du véhicule","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-06','lecon-3','telematique'], 'mft-2026-gotrm:bc01-06-v3:l3:q4', true,
   'Télématique = GPS + capteurs CAN bus + accéléromètres + sondes ATP + TPMS. Mesure : position, vitesse, conso, freinage, températures, pression pneus.'),
  (v_formation, v_module, 'qcm', 'Quel est un fournisseur majeur de télématique ?',
   '[{"id":"a","label":"Adobe","is_correct":false},{"id":"b","label":"Trimble / Webfleet / Geotab","is_correct":true},{"id":"c","label":"Spotify","is_correct":false},{"id":"d","label":"Intel","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-06','lecon-3','telematique'], 'mft-2026-gotrm:bc01-06-v3:l3:q5', true,
   'Acteurs majeurs : Trimble (PL trans-européen), Webfleet (Bridgestone), Geotab, Verizon Connect, Continental VDO, Frotcom.'),
  (v_formation, v_module, 'qcm', 'Le téléchargement obligatoire de la carte conducteur du chronotachygraphe est :',
   '[{"id":"a","label":"Tous les 7 jours","is_correct":false},{"id":"b","label":"Tous les 28 jours","is_correct":true},{"id":"c","label":"Tous les 6 mois","is_correct":false},{"id":"d","label":"Tous les 5 ans","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-06','lecon-3','tachygraphe'], 'mft-2026-gotrm:bc01-06-v3:l3:q6', true,
   'Carte conducteur : tous les 28 jours. Mémoire véhicule : tous les 90 jours. Sanction non-téléchargement : 750 €/carte/mois.'),
  (v_formation, v_module, 'qcm', 'Le bénéfice typique de la télématique sur le carburant est :',
   '[{"id":"a","label":"-1 à -2 %","is_correct":false},{"id":"b","label":"-8 à -12 %","is_correct":true},{"id":"c","label":"-50 %","is_correct":false},{"id":"d","label":"+10 %","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-06','lecon-3','benefices'], 'mft-2026-gotrm:bc01-06-v3:l3:q7', true,
   'Télématique avec écoconduite + maintenance prédictive : -8 à -12 % carburant. Étude TLF/FNTR. Autres gains : -25/-35 % sinistres, -10/-15 % maintenance.'),
  (v_formation, v_module, 'qcm', 'Le ROI typique TMS + télématique combinés s''amortit en :',
   '[{"id":"a","label":"1 mois","is_correct":false},{"id":"b","label":"6-12 mois","is_correct":true},{"id":"c","label":"5 ans","is_correct":false},{"id":"d","label":"Jamais","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-06','lecon-3','roi'], 'mft-2026-gotrm:bc01-06-v3:l3:q8', true,
   'Amortissement 6-12 mois sur les gains opérationnels (carburant, sinistres, maintenance, productivité, litiges). ROI net positif dès an 1 typiquement.'),
  (v_formation, v_module, 'qcm', 'La signature électronique sur application mobile conducteur :',
   '[{"id":"a","label":"N''a pas de valeur juridique","is_correct":false},{"id":"b","label":"Est horodatée + géolocalisée + valeur juridique EIDAS","is_correct":true},{"id":"c","label":"Sert uniquement à l''interne","is_correct":false},{"id":"d","label":"Doit toujours être imprimée","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-06','lecon-3','signature'], 'mft-2026-gotrm:bc01-06-v3:l3:q9', true,
   'Signature électronique horodatée + géolocalisée + valeur juridique EIDAS si certifiée (DocuSign, Yousign). Réduit -80 % les litiges sur contestations livraison.'),
  (v_formation, v_module, 'qcm', 'L''intégration TMS-comptabilité automatise :',
   '[{"id":"a","label":"La paye conducteurs","is_correct":false},{"id":"b","label":"La facturation client (gain ~50 % temps admin)","is_correct":true},{"id":"c","label":"Le contrôle technique","is_correct":false},{"id":"d","label":"Le casier judiciaire","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-06','lecon-3','integration'], 'mft-2026-gotrm:bc01-06-v3:l3:q10', true,
   'TMS ↔ Sage / Cegid : génération auto factures depuis tournées exécutées. Gain ~50 % temps admin. Suppression erreurs de saisie.'),
  (v_formation, v_module, 'qcm', 'Un TMS premium pour ETI/grands comptes coûte typiquement :',
   '[{"id":"a","label":"Gratuit","is_correct":false},{"id":"b","label":"5-10 €/véh./mois","is_correct":false},{"id":"c","label":"200-400 €/véh./mois","is_correct":true},{"id":"d","label":"10 000 €/véh./mois","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-06','lecon-3','tarif'], 'mft-2026-gotrm:bc01-06-v3:l3:q11', true,
   'TMS premium (PTV/Trimble, Manhattan, Kuebix) : 200-400 €/véh./mois. Justifié par fonctions avancées (multi-pays, optim. poussée, ERP, gros volumes).'),
  (v_formation, v_module, 'qcm', 'La sanction d''un oubli de téléchargement chronotachygraphe est de :',
   '[{"id":"a","label":"35 € par mois","is_correct":false},{"id":"b","label":"750 € par carte par mois","is_correct":true},{"id":"c","label":"7 500 € par an","is_correct":false},{"id":"d","label":"Aucune","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-06','lecon-3','sanction'], 'mft-2026-gotrm:bc01-06-v3:l3:q12', true,
   '750 € par carte conducteur par mois non téléchargée. À ne jamais oublier ! La télématique avec téléchargement automatique élimine totalement ce risque.');

  -- ===== LEÇON 4 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'OTIF signifie :',
   '[{"id":"a","label":"Optimal Transport Index Factor","is_correct":false},{"id":"b","label":"On Time In Full (à l''heure et complet)","is_correct":true},{"id":"c","label":"Operating Time Internal Flow","is_correct":false},{"id":"d","label":"Out of Time Inflated Forecast","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-06','lecon-4','otif'], 'mft-2026-gotrm:bc01-06-v3:l4:q1', true,
   'OTIF = On Time In Full. Pourcentage de livraisons à l''heure ET complètes (sans manquant ni avarie). Plus exigeant que la ponctualité simple.'),
  (v_formation, v_module, 'qcm', 'La cible standard de ponctualité est de :',
   '[{"id":"a","label":"60 %","is_correct":false},{"id":"b","label":"≥ 95 %","is_correct":true},{"id":"c","label":"100 % obligatoire","is_correct":false},{"id":"d","label":"Aucune","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-06','lecon-4','ponctualite'], 'mft-2026-gotrm:bc01-06-v3:l4:q2', true,
   'Ponctualité ≥ 95 % standard pro. ≥ 98 % best-in-class. < 90 % zone rouge. OTIF cible ≥ 90 % standard, ≥ 95 % excellent.'),
  (v_formation, v_module, 'qcm', 'La marge brute par tournée recommandée est de :',
   '[{"id":"a","label":"5 %","is_correct":false},{"id":"b","label":"≥ 18 %","is_correct":true},{"id":"c","label":"50 %","is_correct":false},{"id":"d","label":"100 %","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-06','lecon-4','marge'], 'mft-2026-gotrm:bc01-06-v3:l4:q3', true,
   'Marge brute ≥ 18 % standard, ≥ 25 % excellent. < 15 % zone rouge (pas rentable structurellement). Calcul : (CA − coût direct) / CA.'),
  (v_formation, v_module, 'qcm', 'PDCA signifie :',
   '[{"id":"a","label":"Plan Direct Calcul Auto","is_correct":false},{"id":"b","label":"Plan-Do-Check-Act (Deming)","is_correct":true},{"id":"c","label":"Process Détaillé Compté Annuel","is_correct":false},{"id":"d","label":"Pareto Direct Critique Action","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-06','lecon-4','pdca'], 'mft-2026-gotrm:bc01-06-v3:l4:q4', true,
   'PDCA = Plan-Do-Check-Act. Cycle d''amélioration continue de Deming. Itératif, scientifique, applicable à tout problème opérationnel.'),
  (v_formation, v_module, 'qcm', 'Le diagramme d''Ishikawa classe les causes en :',
   '[{"id":"a","label":"4P (produit, prix, place, promotion)","is_correct":false},{"id":"b","label":"6M (Main d''œuvre, Matériel, Méthode, Milieu, Mesure, Matière)","is_correct":true},{"id":"c","label":"3 V (volume, vitesse, variété)","is_correct":false},{"id":"d","label":"5 forces de Porter","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-06','lecon-4','ishikawa'], 'mft-2026-gotrm:bc01-06-v3:l4:q5', true,
   'Ishikawa = diagramme cause-effet en arête de poisson. 6M : Main d''œuvre, Matériel, Méthode, Milieu, Mesure, Matière. Permet de cartographier toutes les causes possibles.'),
  (v_formation, v_module, 'qcm', 'Le NPS Net Promoter Score se calcule :',
   '[{"id":"a","label":"% Promoteurs uniquement","is_correct":false},{"id":"b","label":"% Promoteurs (9-10) − % Détracteurs (0-6)","is_correct":true},{"id":"c","label":"Moyenne arithmétique des notes","is_correct":false},{"id":"d","label":"Note médiane","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-06','lecon-4','nps'], 'mft-2026-gotrm:bc01-06-v3:l4:q6', true,
   'NPS = % Promoteurs (notes 9-10) − % Détracteurs (notes 0-6). Les Passifs (7-8) sont ignorés. Cible ≥ +50 excellent, +30 à +50 bon, < +20 à améliorer.'),
  (v_formation, v_module, 'qcm', 'Le taux de réclamations cible est :',
   '[{"id":"a","label":"< 1 %","is_correct":true},{"id":"b","label":"< 10 %","is_correct":false},{"id":"c","label":"< 25 %","is_correct":false},{"id":"d","label":"Pas de cible","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-06','lecon-4','reclamations'], 'mft-2026-gotrm:bc01-06-v3:l4:q7', true,
   'Réclamations < 1 % standard, < 0,5 % excellent, > 2 % zone rouge. Catégoriser : avarie / retard / manquant / facture / SAV.'),
  (v_formation, v_module, 'qcm', 'OEA signifie :',
   '[{"id":"a","label":"Ouvrier Européen Agréé","is_correct":false},{"id":"b","label":"Opérateur Économique Agréé (statut douanier UE)","is_correct":true},{"id":"c","label":"Organisation des Entreprises d''Affaires","is_correct":false},{"id":"d","label":"Office d''Évaluation Annuelle","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-06','lecon-4','oea'], 'mft-2026-gotrm:bc01-06-v3:l4:q8', true,
   'OEA = Opérateur Économique Agréé. Statut douanier européen. Bénéfices : procédures simplifiées, dédouanement rapide. Conditions : honorabilité, solvabilité, conformité douanière, sûreté.'),
  (v_formation, v_module, 'qcm', 'La méthode des 5 pourquoi vise à :',
   '[{"id":"a","label":"Faire 5 plans en parallèle","is_correct":false},{"id":"b","label":"Trouver la cause racine d''un problème","is_correct":true},{"id":"c","label":"Tester 5 hypothèses statistiques","is_correct":false},{"id":"d","label":"Calculer 5 KPIs","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-06','lecon-4','5pourquoi'], 'mft-2026-gotrm:bc01-06-v3:l4:q9', true,
   '5 pourquoi : poser 5 fois « pourquoi ? » à chaque réponse pour remonter à la cause racine (et pas à un symptôme). Outil simple d''analyse, intégré au PDCA.'),
  (v_formation, v_module, 'qcm', 'Le tableau de bord exploitation tient idéalement sur :',
   '[{"id":"a","label":"1 page A4","is_correct":true},{"id":"b","label":"10 pages","is_correct":false},{"id":"c","label":"Un classeur entier","is_correct":false},{"id":"d","label":"Aucune limite","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-06','lecon-4','tableau-bord'], 'mft-2026-gotrm:bc01-06-v3:l4:q10', true,
   'Tableau de bord 1 page A4, lisible en 30 secondes : en-tête, 8-12 KPIs (valeur + cible + tendance), 2-3 graphiques, faits marquants, plan d''action. Codes vert/jaune/rouge.'),
  (v_formation, v_module, 'qcm', 'Le taux de retours à vide cible est de :',
   '[{"id":"a","label":"< 15 %","is_correct":true},{"id":"b","label":"50 %","is_correct":false},{"id":"c","label":"75 %","is_correct":false},{"id":"d","label":"Aucune cible","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-06','lecon-4','retours-vide'], 'mft-2026-gotrm:bc01-06-v3:l4:q11', true,
   'Retours à vide < 15 % standard, < 10 % best-in-class, > 25 % zone rouge. Levier : développer fret retour (bourse, partenariats).'),
  (v_formation, v_module, 'qcm', 'Le taux d''accidents cible est de :',
   '[{"id":"a","label":"< 1/100 000 km","is_correct":true},{"id":"b","label":"5/100 000 km","is_correct":false},{"id":"c","label":"50/100 000 km","is_correct":false},{"id":"d","label":"Aucune cible","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-06','lecon-4','accidents'], 'mft-2026-gotrm:bc01-06-v3:l4:q12', true,
   'Accidents responsables < 1/100 000 km standard, < 0,5 best-in-class, > 2 zone rouge. Telematique permet -25/-35 % via formation comportement.');

  -- ===== 8 QR (cas pratiques métier, max_score 5-7) =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qr',
   'Vous devez planifier une tournée de 12 livraisons (Paris-Lille) avec 1 PL 19 t (capacité 33 palettes EUR, équipé hayon). Marchandise : 30 palettes EUR de 600 kg unitaire (poids total 18 t). Contraintes : 8 GMS région parisienne créneau 8h-12h hayon obligatoire, 4 industriels région lilloise créneau 14h-17h. Conducteur Pierre, CE permis, 38 h en cours hebdo. Construisez la feuille de tournée détaillée et vérifiez sa conformité RSE.',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-06','qr','planification','rse'], 'mft-2026-gotrm:bc01-06-v3:qr1', true,
   'Feuille de tournée :\n6h00 Dépôt Paris — chargement 30 palettes (30 min)\n8h00 Paris GMS A (4p, hayon, 25 min)\n8h45 Paris GMS B (4p, hayon, 25 min)\n9h30 Paris GMS C (4p, hayon, 25 min)\n10h15 Paris GMS D (4p, hayon, 25 min)\n11h00 Paris GMS E (4p, hayon, 25 min)\n11h45 Paris GMS F (4p, hayon, 25 min)\n12h30 Pause RSE 45 min (obligatoire après 4 h 30 conduite continue)\n14h30 Lille A (1p, quai, 15 min)\n15h15 Lille B (1p, quai, 15 min)\n16h00 Lille C (2p, quai, 15 min)\n16h45 Lille D (2p, quai, 15 min)\n18h00 Retour Lille dépôt\n\nVérifications RSE :\n• Distance ≈ 280 km — OK\n• Conduite ≈ 5 h 30 < 9 h max — OK\n• Amplitude 12 h < 15 h max — OK\n• Pause 45 min programmée à 12h30-13h15 après 6h30 démarrage — OK\n• Capacité 30/33 palettes — OK\n• Tonnage 18/19 t — OK (limite haute, prudence pesée)\n• Conducteur Pierre 38 h + 12 h tournée = 50 h sem. < 56 h max — OK\n• Permis CE adapté PL 19 t — OK\n\nPublication conducteur : feuille tournée envoyée la veille 18h via app TMS mobile.'),

  (v_formation, v_module, 'qr',
   'Calculez l''économie de Clarke & Wright pour 4 clients depuis un dépôt D : D-C1 = 10 km, D-C2 = 18 km, D-C3 = 22 km, D-C4 = 14 km. Distances inter-clients : C1-C2 = 8 km, C1-C3 = 15 km, C1-C4 = 6 km, C2-C3 = 5 km, C2-C4 = 12 km, C3-C4 = 10 km. Donnez l''ordre de fusion prioritaire si la capacité véhicule = 2 clients max.',
   NULL, 6, 'difficile', ARRAY['gotrm','bc01-06','qr','clarke','calcul'], 'mft-2026-gotrm:bc01-06-v3:qr2', true,
   'Calcul des économies S(i,j) = D(0,i) + D(0,j) − D(i,j) :\n• S(C1,C2) = 10 + 18 − 8 = **20 km**\n• S(C1,C3) = 10 + 22 − 15 = **17 km**\n• S(C1,C4) = 10 + 14 − 6 = **18 km**\n• S(C2,C3) = 18 + 22 − 5 = **35 km**\n• S(C2,C4) = 18 + 14 − 12 = **20 km**\n• S(C3,C4) = 22 + 14 − 10 = **26 km**\n\nClassement décroissant : S(C2,C3) = 35 > S(C3,C4) = 26 > S(C1,C2) = 20 = S(C2,C4) = 20 > S(C1,C4) = 18 > S(C1,C3) = 17.\n\nFusion prioritaire (capacité 2 clients max) :\n1. **Tournée 1 = C2 + C3** (économie 35 km, 2 clients = capacité max).\n2. **Tournée 2 = C1 + C4** (économie 18 km, 2 clients = capacité max).\n\nKilométrage total optimisé : tournée 1 : D→C2→C3→D = 18 + 5 + 22 = 45 km ; tournée 2 : D→C1→C4→D = 10 + 6 + 14 = 30 km. **Total = 75 km**.\n\nVs solo : 4 × (10+18+22+14) × 2 / 4 = 128 km. **Économie réelle = 53 km (-41 %)**.'),

  (v_formation, v_module, 'qr',
   'Un client GMS impose un créneau strict 9h-9h30 sur 1 livraison (C5). Les 7 autres clients ont des créneaux flexibles 8h-17h. Le démarrage est à 7h30 depuis le dépôt. Distance dépôt-C5 = 22 km. Comment intégrez-vous cette contrainte dans l''optimisation et quelles précautions prendre ?',
   NULL, 5, 'moyen', ARRAY['gotrm','bc01-06','qr','timewindow','optimisation'], 'mft-2026-gotrm:bc01-06-v3:qr3', true,
   'Intégration de la contrainte :\n\n1. **Contrainte dure** : C5 doit être livré entre 9h00 et 9h30, **non négociable** (pénalité GMS 100-300 €).\n\n2. **Calcul d''arrivée C5** : départ 7h30 + trajet 22 km × (1/50 km/h) = 26 min ⇒ arrivée ≈ 7h56. Marge de **64 min** avant 9h00 ⇒ possibilité de passer **1 client intermédiaire** entre dépôt et C5.\n\n3. **Optimisation** : positionner C5 en **rang 2 ou 3** (un client proche dépôt avant, puis C5 à l''heure pile, puis les 6 autres clients en optimisation Clarke & Wright).\n\n4. **Précautions opérationnelles** :\n  • **Marge sécurité** 5-10 min : viser arrivée 8h55 plutôt que 9h00 pile (aléa trafic).\n  • **Vérification veille** : confirmer le créneau auprès du chef de quai GMS (numéro direct).\n  • **Plan B** : si retard fortuit, appeler le client GMS dès 8h45 pour anticipation et négociation report (à défaut de pénalité).\n  • **Conducteur briefé** : importance de ce créneau, contact GMS dans la feuille tournée.\n  • **Retour TMS** : signature électronique horodatée à l''arrivée pour preuve de conformité.\n\n5. **En cas de pluralité de créneaux stricts** dans une journée : recourir à un algorithme avec time windows dur (recuit simulé / tabou plutôt que Clarke & Wright pur).'),

  (v_formation, v_module, 'qr',
   'Vous gérez une PME 8 véhicules PL en transport généraliste France. Vous mettez 4 h/jour à planifier en mode Excel + Google Maps. Le directeur veut diviser ce temps par 2. Proposez une démarche complète (diagnostic, outils, ROI chiffré sur an 1 et an 2).',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-06','qr','tms','roi'], 'mft-2026-gotrm:bc01-06-v3:qr4', true,
   'Diagnostic :\n• Volume : 50 commandes/jour × 8 véhicules.\n• Outil actuel : Excel + Google Maps en mode manuel = 4 h/jour de planif.\n• Inefficacité estimée : 30-40 % de re-saisie + erreurs + km mal optimisés.\n\nPlan d''action 5 leviers :\n\n1. **Acquisition TMS Mantis** (8 véh. × 100 €/mois × 12 = 9 600 €/an + setup 2 000 €).\n   • Optimisation auto (gain -8 % km).\n   • App mobile conducteurs.\n   • Intégration Sage comptabilité.\n   • Setup 4-6 semaines (formation incluse).\n\n2. **Géocodage adresses clients** (à la création fiche, gratuit avec Google Maps API API ≈ 80 €/mois).\n\n3. **Tournées-types** (pré-construites par zone, à compléter le jour J) — gain 60 % temps planif récurrente.\n\n4. **Standardisation commandes en entrée** : portail B2B unique, champs SACO obligatoires.\n\n5. **Formation opérateur planif** : 2 jours TMS (1 500-2 500 € externe).\n\nROI chiffré an 1 :\n• Investissement : TMS 9 600 € + setup 2 000 € + formation 2 000 € + Google Maps 960 € = **14 560 €**.\n• Gain temps planif : 2 h/jour × 220 jours × 35 €/h = **15 400 €**.\n• Gain optim. km : -8 % × 200 000 km × 1,2 €/km = **19 200 €**.\n• Gain facturation auto (50 % temps admin × 600 € coût mensuel) = **3 600 €**.\n• Total gains an 1 : **38 200 €**.\n• **ROI net an 1 = +23 640 €** (≈ 165 % retour).\n\nAn 2 (sans setup ni formation) :\n• Investissement : 9 600 + 960 = 10 560 €.\n• Gains : 38 200 €.\n• **ROI net an 2+ = +27 640 €/an**.\n\nKPIs de suivi : lead-time-planning < 2h, taux respect créneaux ≥ 95 %, km/commande, marge brute par tournée.'),

  (v_formation, v_module, 'qr',
   'Une TPE 3 fourgonnettes (CA 350 k€) hésite à investir dans un TMS. Le dirigeant pense que c''est trop cher pour sa taille. Argumentez votre position en chiffrant le ROI an 1 et proposez la solution la mieux adaptée.',
   NULL, 5, 'moyen', ARRAY['gotrm','bc01-06','qr','tpe','roi'], 'mft-2026-gotrm:bc01-06-v3:qr5', true,
   'Argumentaire chiffré :\n\nCoûts an 1 (solution Mantis ou Track-POD) :\n• 3 véh. × 60 €/mois × 12 = **2 160 €**.\n• Setup + formation 1 jour = **600 €**.\n• Total : **2 760 €** (≈ 0,8 % du CA).\n\nGains an 1 :\n• Gain temps planif (1 h/jour × 220 j × 25 €/h) = **5 500 €**.\n• Gain optimisation km (-10 % × 80 000 km × 0,4 €/km) = **3 200 €**.\n• Réduction litiges (-50 % × 1 000 € estim.) = **500 €**.\n• Total : **9 200 €**.\n\n**ROI an 1 = +6 440 €** (≈ 230 % retour) **dès l''an 1**.\n\nCoût de l''inaction :\n• -10 % productivité estim. = -35 000 €/an manque à gagner.\n• Litiges non couverts : -2 000 €/an estim.\n• Image moins pro vs concurrents équipés : perte commerciale long terme.\n\nSolution recommandée : démarrer avec une **solution légère** (Mantis ou Track-POD), monter en gamme si la flotte grandit. L''objection « trop cher » ne tient pas face aux chiffres ROI.\n\nPlan de déploiement :\n1. Test pilote 1 véhicule pendant 2-3 mois (gratuit ou 60 €).\n2. Si gains validés, déploiement complet (3 véhicules) sur 4-6 semaines.\n3. Mesure mensuelle : temps planif, km, litiges, satisfaction conducteurs.\n4. Revue 6 mois pour ajustements.'),

  (v_formation, v_module, 'qr',
   'Vous installez la télématique Webfleet sur 5 PL avec consommation moyenne 35 L/100 km, parcourant 200 000 km/an chacun. Coût : 40 €/véh./mois + 1 000 € matériel par véhicule. Carburant à 1,80 €/L. La télématique permet -10 % carburant, -25 % sinistres (5 000 €/an estim.), -10 % maintenance (32 000 €/an estim. par véh.). Calculez le ROI an 1 détaillé.',
   NULL, 6, 'difficile', ARRAY['gotrm','bc01-06','qr','telematique','roi'], 'mft-2026-gotrm:bc01-06-v3:qr6', true,
   'Calcul investissement an 1 :\n• 5 véh. × 40 €/mois × 12 = **2 400 €/an** (abonnement).\n• 5 × 1 000 € matériel = **5 000 €** an 1 unique.\n• **Total investissement an 1 = 7 400 €**.\n\nGains an 1 :\n\n1. **Carburant (-10 %)** :\n   • Conso totale 5 véh. × 200 000 km × 35 L/100 km = 350 000 L/an.\n   • Économie : 350 000 × 10 % × 1,80 €/L = **63 000 €/an** (sur les 5 véh. au total).\n   • Note : si on parle de la conso totale flotte 5 véh., l''économie est de 63 000 €. Si on parle d''un seul véhicule à 200 000 km, on aurait 12 600 € × 5 = 63 000 €. **Total = 63 000 €/an**.\n\n2. **Sinistres (-25 %)** : 5 000 € × 25 % = **1 250 €/an** (par véhicule estim. moyen).\n\n3. **Maintenance (-10 %)** : 32 000 €/an × 10 % = **3 200 €/an** (estim. flotte ou par véhicule).\n\n4. **Productivité conducteurs (+5 %)** estim. : 5 véh. × 4 conducteurs × 35 €/h × 5 % × 1 800 h/an = **63 000 € marginal** (théorique, retenons 50 % = 31 500 € réaliste).\n\n5. **Litiges** : -40 % de litiges chronométrés ≈ -2 000 €/an estim.\n\n**Total gains an 1 (conservateur, sans productivité)** : 63 000 + 1 250 + 3 200 + 2 000 = **69 450 €**.\n\n**ROI net an 1 = 69 450 − 7 400 = +62 050 €** (≈ 838 % retour).\n\nROI net an 2+ (sans matériel à 5 000 €) : ≈ **+67 050 €/an**.\n\nAmortissement matériel : ~ 2 mois sur le carburant seul. La télématique est ici très clairement rentable, l''investissement s''amortit avant la fin du 1ᵉʳ trimestre. À déployer rapidement.'),

  (v_formation, v_module, 'qr',
   'Au tableau de bord exploitation, la ponctualité est passée de 96 % à 87 % en 4 semaines. Le directeur demande un diagnostic et un plan d''action sous 7 jours. Conduisez l''analyse des causes (5 pourquoi + Ishikawa) et proposez un plan PDCA détaillé sur 30 jours.',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-06','qr','pdca','diagnostic'], 'mft-2026-gotrm:bc01-06-v3:qr7', true,
   'Analyse 5 pourquoi :\n\n1. **Pourquoi** ponctualité à 87 % ?\n   → 13 % des livraisons sont en retard.\n2. **Pourquoi** ces livraisons sont en retard ?\n   → Les tournées dépassent l''amplitude prévue.\n3. **Pourquoi** les tournées dépassent ?\n   → Temps de manutention sous-estimés (15 min au lieu de 25 min réels).\n4. **Pourquoi** les temps sont sous-estimés ?\n   → Base de données TMS non mise à jour depuis 2 ans, 5 nouveaux clients GMS ajoutés sans mesure terrain.\n5. **Pourquoi** la base n''est pas à jour ?\n   → Aucun process formalisé de réaudit annuel.\n\n**Cause racine** : absence de process de réaudit annuel des temps de manutention.\n\nIshikawa (6M) — autres causes possibles :\n• **Main d''œuvre** : nouveaux conducteurs non formés sur clients GMS.\n• **Matériel** : pannes véhicules récurrentes ?\n• **Méthode** : pas de réaudit temps manutention (CAUSE PRINCIPALE).\n• **Milieu** : travaux périphérie urbaine, ZFE.\n• **Mesure** : TMS pas à jour (lié à Méthode).\n• **Matière** : marchandises plus difficiles ?\n\nPlan PDCA 30 jours :\n\n**PLAN (J+1 à J+10)** :\n• Audit terrain 5 nouveaux clients GMS (chronomètre, photo, fiche) — Chef expl. — J+5.\n• Mise à jour TMS temps manutention — Resp. TMS — J+10.\n• Formalisation process réaudit annuel — Direction — J+10.\n\n**DO (J+11 à J+20)** :\n• Application des nouveaux temps en planif — opérateurs.\n• Communication conducteurs sur changements.\n• Brief clients GMS si retard < 30 min toléré.\n\n**CHECK (J+21 à J+25)** :\n• Mesure ponctualité hebdo : S+1, S+2.\n• Cible : retour à 92 % à J+21, 95 % à J+30.\n\n**ACT (J+26 à J+30)** :\n• Si succès : standardiser le process annuel (calendrier réaudit chaque mai).\n• Si échec partiel : identifier autres causes Ishikawa, second cycle PDCA.\n\nKPI suivis : ponctualité hebdo, OTIF hebdo, écart temps planifié vs réel par client, satisfaction GMS.\n\nROI estimé : +5 pts ponctualité = +2 % CA conservé = +30 000 €/an pour PME 1,5 M€ CA.'),

  (v_formation, v_module, 'qr',
   'Vous prenez les commandes d''un service exploitation 6 véhicules avec ces indicateurs : ponctualité 88 %, OTIF 81 %, marge brute 14 %, taux réclamations 2,3 %. La direction veut une amélioration mesurable en 3 mois. Construisez le plan d''action complet (diagnostic + 5 leviers + KPIs de pilotage + ROI estimé).',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-06','qr','kpi','plan-action'], 'mft-2026-gotrm:bc01-06-v3:qr8', true,
   'Diagnostic :\n• Ponctualité 88 % et OTIF 81 % = problème opérationnel (planif ou exécution).\n• Marge 14 % = sous le standard 18-20 % (risque rentabilité).\n• Réclamations 2,3 % = au-dessus du seuil 1 % (image client).\n\nPlan d''action 5 leviers :\n\n1. **Audit qualité données TMS** (J+30) :\n   • Remettre à jour temps manut., adresses, créneaux clients.\n   • Coût : 30 h × 35 €/h = **1 050 €**.\n   • Gain ponctualité estimé +5 pts.\n\n2. **Optimisation tournées** (J+45) :\n   • Passer de planification manuelle à automatique TMS (Mantis/Stellium).\n   • Coût : déjà acquis ou +6 × 100 €/mois = +600 €/mois.\n   • Gain km : -8 % × 250 000 km × 1,2 €/km = **-2 400 €/mois** = -28 800 €/an.\n\n3. **Formation conducteurs** (J+60) :\n   • 1 jour écoconduite + manutention.\n   • Coût : 6 × 250 € = **1 500 €**.\n   • Gain : -8 % conso, -40 % réclamations type comportement.\n\n4. **Standardisation refus livraison** (J+30) :\n   • Check-list au chargement, refus argumenté si conditionnement non conforme.\n   • Coût : 0 € (process).\n   • Gain : -50 % réclamations type avarie.\n\n5. **Tableau de bord hebdo** (J+15) :\n   • Revue 1 page A4 avec chef d''équipe chaque vendredi.\n   • Coût : 0 € (1 h/sem du chef expl.).\n   • Gain : visibilité, engagement, détection précoce dérives.\n\nKPIs de pilotage :\n• Ponctualité S+1, S+2, S+4, S+8, S+12 (cible 95 % à 3 mois).\n• OTIF mensuel (cible 90 % à 3 mois).\n• Marge brute mensuelle (cible 18 % à 3 mois).\n• Réclamations hebdomadaires (cible 1 % à 3 mois).\n• Satisfaction client NPS trimestriel.\n\nROI estimé sur 3 mois :\n• **Coûts** : 5 000 € total (audit + formation + TMS si nouveau).\n• **Gains** :\n  ◦ Ponctualité +5 pts → +2 % CA conservé = +12 000 €.\n  ◦ Marge +3 pts → +9 000 €.\n  ◦ Réclamations -50 % → -3 000 € indemnités évitées.\n• **ROI total +19 000 € en 3 mois** (≈ 280 % retour).\n\nExtension : si succès, déploiement de la démarche an 1 = ROI estimé +60 000 €/an.\n\nFacteurs critiques de succès : engagement direction, communication conducteurs (changement comportement), discipline tableau de bord hebdo, mesure objective (pas anecdotique).');

  -- =================================================================
  -- QUIZZES (4 entraînement + 1 examen blanc module)
  -- =================================================================

  -- Quiz 1 — Méthodologie planification
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Méthodologie de planification — Quiz',
          'Quiz d''entraînement (12 questions) sur les 5 étapes de planification, contraintes RSE (9 h conduite, 4 h 30 → 45 min pause), géocodage et calcul d''itinéraire mode camion.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-06-v3:l1:%';

  -- Quiz 2 — Optimisation et algorithmes
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Optimisation et algorithmes — Quiz',
          'Quiz d''entraînement (12 questions) sur TSP/VRP, algorithmes Sweep, plus proche voisin, Clarke & Wright, méta-heuristiques (recuit simulé, tabou, génétique), contraintes et indicateurs.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-06-v3:l2:%';

  -- Quiz 3 — TMS et télématique
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'TMS et télématique — Quiz',
          'Quiz d''entraînement (12 questions) sur les 5 modules d''un TMS, acteurs du marché (Akanea, Mantis, Stellium, PTV, Trimble, Webfleet), chronotachygraphe et ROI typique.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-06-v3:l3:%';

  -- Quiz 4 — KPIs et tableau de bord
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'KPIs et tableau de bord — Quiz',
          'Quiz d''entraînement (12 questions) sur les 12 KPIs essentiels (ponctualité, OTIF, marge, NPS, accidents), méthode PDCA, 5 pourquoi, Ishikawa et certifications (OEA, ISO 9001).',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-06-v3:l4:%';

  -- Examen blanc module — 15 QCM transversaux + 5 QR cas pratique
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold, is_mock_exam)
  VALUES (v_module, 'Examen blanc — BC01-06 Planification et optimisation des tournées',
          'Examen blanc reproduisant les conditions de l''examen RNCP : 15 QCM transversaux (4 leçons) + 5 QR cas pratiques métier, durée 60 min, seuil 50 %.',
          'examen', 3600, 50, true)
  RETURNING id INTO v_quiz_eb;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref IN (
     -- 4 QCM Leçon 1
     'mft-2026-gotrm:bc01-06-v3:l1:q1','mft-2026-gotrm:bc01-06-v3:l1:q2',
     'mft-2026-gotrm:bc01-06-v3:l1:q5','mft-2026-gotrm:bc01-06-v3:l1:q12',
     -- 4 QCM Leçon 2
     'mft-2026-gotrm:bc01-06-v3:l2:q1','mft-2026-gotrm:bc01-06-v3:l2:q2',
     'mft-2026-gotrm:bc01-06-v3:l2:q5','mft-2026-gotrm:bc01-06-v3:l2:q6',
     -- 4 QCM Leçon 3
     'mft-2026-gotrm:bc01-06-v3:l3:q1','mft-2026-gotrm:bc01-06-v3:l3:q4',
     'mft-2026-gotrm:bc01-06-v3:l3:q6','mft-2026-gotrm:bc01-06-v3:l3:q7',
     -- 3 QCM Leçon 4
     'mft-2026-gotrm:bc01-06-v3:l4:q1','mft-2026-gotrm:bc01-06-v3:l4:q2',
     'mft-2026-gotrm:bc01-06-v3:l4:q4',
     -- 5 QR (cas pratiques transversaux)
     'mft-2026-gotrm:bc01-06-v3:qr1','mft-2026-gotrm:bc01-06-v3:qr2',
     'mft-2026-gotrm:bc01-06-v3:qr4','mft-2026-gotrm:bc01-06-v3:qr7',
     'mft-2026-gotrm:bc01-06-v3:qr8'
   );

  RAISE NOTICE '✓ GOTRM BC01-06 v3 dense importé : 4 leçons (planif méthodologie, optimisation algorithmes, TMS télématique, KPIs PDCA), 48 QCM, 8 QR cas pratiques métier, 5 quiz (4 entraînement + 1 examen blanc 15 QCM + 5 QR / 60 min).';

END $bc01_06_v3$;
