-- =====================================================================
-- GOTRM (RNCP 40990) — BC01-10 : KPI d'exploitation
-- Tableau de bord, indicateurs opérationnels, financiers, qualité, RH.
-- =====================================================================

DO $bc01_10$
DECLARE
  v_formation uuid; v_bloc int; v_module uuid;
  v_lesson_1 uuid; v_lesson_2 uuid; v_lesson_3 uuid; v_lesson_4 uuid;
  v_quiz_1 uuid; v_quiz_2 uuid; v_quiz_3 uuid; v_quiz_4 uuid; v_quiz_eb uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc.'; END IF;

  DELETE FROM public.modules WHERE slug = 'gotrm-bc01-10-kpi-exploitation';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'BC01-10 — Piloter avec des indicateurs (KPI exploitation)',
    'gotrm-bc01-10-kpi-exploitation', v_bloc,
    'KPI opérationnels (taux remplissage, ponctualité), financiers (marge, BFR), qualité (NPS, taux litiges) et RH (turnover). Tableau de bord et reporting.',
    'intermediaire', 150, 100
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 100, true) ON CONFLICT DO NOTHING;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-10:%';

  -- =================================================================
  -- LEÇON 1 — KPI opérationnels
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'KPI opérationnels : remplissage, ponctualité, productivité',
    'gotrm-bc01-10-01-kpi-operationnels', 1, 40,
$lesson1$
# KPI opérationnels : remplissage, ponctualité, productivité

Les **KPI opérationnels** mesurent la performance quotidienne du transport : utilisation des véhicules, qualité du service, productivité humaine. Ils sont le miroir du métier d'exploitant.

> 🎯 **Objectifs de la leçon**
>
> - Maîtriser les **5 KPI opérationnels** majeurs.
> - Calculer chacun avec ses formules.
> - Interpréter les valeurs (cibles, seuils, alertes).
> - Définir des **plans d'action** sur les écarts.

---

## 1. Le taux de remplissage

### 1.1 Définition

```
Taux de remplissage = (Charge transportée) / (Capacité maximale) × 100
```

À mesurer en **poids** ET en **volume** : le véhicule est plein dès qu'une dimension atteint 100 %.

### 1.2 Cibles secteur

| Type de transport | Cible remplissage |
|---|---|
| FTL longue distance | > 85 % |
| LTL régional | > 75 % |
| Distribution urbaine | > 65 % (souvent par contrainte cubage) |

### 1.3 Levier d'action

Un taux de remplissage faible (< 70 %) est souvent dû à :
- Mauvaise consolidation des commandes
- Acceptation de petits lots à perte
- Plages horaires multiples obligeant à repartir partiellement chargé
- Nature de la marchandise (volumineuse mais légère)

> 📌 **Impact financier**
>
> 1 point de taux de remplissage = ~ 1,5 % de marge nette additionnelle (statistique secteur).

---

## 2. La ponctualité

### 2.1 Définition

```
Ponctualité = (Livraisons dans la fenêtre RDV) / (Total livraisons) × 100
```

### 2.2 Cibles secteur

| Niveau | Ponctualité |
|---|---|
| Fragile | < 90 % |
| Acceptable | 90-95 % |
| Bon | 95-98 % |
| Excellent | > 98 % |

### 2.3 Mesurer correctement

Définir avec précision :
- **Fenêtre acceptée** : 30 min, 1 h, 2 h
- **Référence** : heure prévue (CMR/devis) ou heure RDV (bon de commande client)
- **Périmètre** : toutes livraisons OU livraisons facturées seulement
- **Exclusions** : force majeure (à documenter)

### 2.4 Lien avec la fidélisation

Statistiques sectorielles : un client recevant **< 90 % de ponctualité** part dans les 12 mois (probabilité 65 %). Au-dessus de 96 %, fidélisation > 85 %.

---

## 3. La productivité

### 3.1 Productivité conducteur

```
Productivité conducteur = (CA produit / km parcourus) ou (km/jour) ou (livraisons/jour)
```

Selon le type de transport, on choisit le KPI le plus pertinent.

### 3.2 Productivité véhicule

```
Productivité véhicule = km commerciaux annuels
```

| Type | Cible km commerciaux/an |
|---|---|
| FTL longue distance | 110 000 - 130 000 km |
| Distribution urbaine | 35 000 - 50 000 km |
| Régional mixte | 80 000 - 100 000 km |

### 3.3 Productivité exploitant

```
Productivité exploitant = (Nombre de tournées planifiées) / (Heure de travail)
```

Sur une PME bien équipée TMS, un exploitant gère typiquement :
- 15-25 véhicules en distribution
- 25-40 véhicules en lignes régulières
- 8-12 véhicules en complexité élevée (ADR, ATP, exceptionnel)

---

## 4. Le taux de retour à vide

### 4.1 Définition

```
Taux de retour à vide = (km parcourus à vide) / (km totaux) × 100
```

### 4.2 Cibles secteur

| Type | Cible |
|---|---|
| FTL longue distance | < 15 % (excellent < 10 %) |
| LTL régional | < 25 % |
| Distribution urbaine | Spécifique (souvent 100 % retour à vide) |

### 4.3 Leviers

- **Bourses de fret** : Teleroute, Trans.eu, Timocom
- **Tournées en triangle** : A → B → C → A
- **Clients réciproques** : A vers B et B vers A
- **Cabotage UE** : 3 opérations en 7 jours

---

## 5. La consommation moyenne

### 5.1 Définition

```
Consommation = Litres consommés / 100 km
```

### 5.2 Cibles selon véhicule

| Type véhicule | Cible (L/100 km) |
|---|---|
| Tracteur 44 t longue distance | 28-33 |
| Porteur 19 t régional | 26-30 |
| Distribution urbaine 12 t | 22-28 |
| VUL 3,5 t | 8-12 |

### 5.3 Leviers d'amélioration

- **Éco-conduite** : -5 à -12 % via formation conducteurs
- **Régulateur de vitesse adaptatif** : -3 à -5 %
- **Pression pneumatiques** : -3 % si optimale
- **Aérodynamique** : -8 % avec déflecteurs et carénage

---

## 6. Tableau de bord type — KPI opérationnels mensuels

| KPI | Janv | Févr | Mars | Avr | Cible | Statut |
|---|---|---|---|---|---|---|
| Taux remplissage | 78 % | 81 % | 75 % | 82 % | > 80 % | 🟧 |
| Ponctualité | 94 % | 96 % | 92 % | 95 % | > 95 % | 🟧 |
| Retour à vide | 18 % | 16 % | 22 % | 17 % | < 15 % | 🟥 |
| Conso moyenne | 29,2 | 28,8 | 30,1 | 29,0 | < 29 | 🟧 |
| Productivité conducteur | 580 km/j | 590 | 545 | 595 | > 580 | 🟧 |
| Km commerciaux/véhicule annualisés | 102 k | 108 k | 96 k | 110 k | > 110 k | 🟧 |

> 📌 **Code couleur**
>
> 🟩 Vert = cible atteinte
> 🟧 Orange = entre cible et seuil critique
> 🟥 Rouge = sous seuil critique → action immédiate

---

## 7. Cas pratique : analyse mensuelle

**Contexte** : *Trans-Ouest Normand* (18 véhicules) constate en mars une dégradation simultanée de la ponctualité (passage de 95 % à 91 %) et du retour à vide (de 17 % à 24 %).

### Diagnostic croisé

Hypothèses à investiguer :
- Période d'activité atypique (fin Q1, fluctuations clients) ?
- Changement organisationnel récent ?
- Conducteur(s) absents ? Retour de pannes ?
- Dégradation de la planification ?

### Investigation sur 5 jours

1. **Pareto des retards** : sur 22 retards constatés, 14 imputables à la même tournée (livraisons RDV serrés Cherbourg-Rouen).
2. **Pareto retour à vide** : 9 véhicules sur 18 ont des retours à vide > 25 %, dont 7 sur la même ligne (Caen-Bordeaux).
3. **Ressources** : 2 conducteurs en arrêt prolongé, remplacés par intérimaires moins efficaces.

### Plan d'action

| Action | Échéance | Impact attendu |
|---|---|---|
| Ré-optimiser tournée Cherbourg-Rouen (créneaux RDV) | Sem 14 | Ponctualité +3 pts |
| Souscription Teleroute pour ligne Caen-Bordeaux | Sem 14 | Retour à vide -5 pts |
| Formation accélérée intérimaires (1 jour) | Sem 15 | Productivité +5 % |
| Audit hebdomadaire des KPI à compter de la sem 14 | Continu | Détection précoce |

### Suivi

Re-mesure des KPI à fin avril :
- Cible ponctualité : > 95 %
- Cible retour à vide : < 18 %

Si non atteint : escalade direction, plan additionnel.

---

> ✅ **À retenir**
>
> - **5 KPI opérationnels** : remplissage, ponctualité, retour à vide, conso, productivité.
> - Cibles standards : remplissage > 80 %, ponctualité > 95 %, retour à vide < 15 %.
> - **1 pt de remplissage = ~ 1,5 % de marge nette** additionnelle.
> - Tableau de bord **mensuel avec code couleur** + analyse croisée des dégradations.
$lesson1$,
'5 KPI opérationnels (remplissage, ponctualité, retour à vide, conso, productivité), cibles secteur, leviers d''action, analyse croisée et tableau de bord.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — KPI financiers
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'KPI financiers : marge, BFR, coût km, EBE',
    'gotrm-bc01-10-02-kpi-financiers', 2, 40,
$lesson2$
# KPI financiers : marge, BFR, coût km, EBE

Au-delà de l'opérationnel, l'exploitant doit comprendre les **KPI financiers** qui mesurent la rentabilité réelle de l'activité. Sans ces indicateurs, on pilote à l'aveugle.

> 🎯 **Objectifs de la leçon**
>
> - Maîtriser les **5 KPI financiers** clés en transport.
> - Calculer marge brute, marge nette, **BFR**, **EBE**.
> - Comprendre le **coût km commercial** et son interprétation.
> - Lier KPI financiers et décisions opérationnelles.

---

## 1. La marge

### 1.1 Marge brute

```
Marge brute = Prix de vente - Coûts variables directs
Taux de marge brute = Marge brute / Prix × 100
```

| Type | Cible secteur |
|---|---|
| FTL longue distance | 35-50 % |
| LTL régional | 40-55 % |
| Distribution urbaine | 45-60 % |
| Affrètement | 8-15 % (marge nette d'intermédiation) |

### 1.2 Marge nette

```
Marge nette = (Bénéfice net) / Chiffre d'affaires × 100
```

| Type | Cible secteur |
|---|---|
| FTL longue distance | 4-8 % |
| LTL régional | 6-12 % |
| Distribution urbaine | 8-15 % |
| Spécifique (ADR, ATP) | 10-18 % |

### 1.3 Seuil de fragilité

Marge nette < 4 % = entreprise fragile à tout incident.
Marge nette < 2 % = activité en danger structurel.

---

## 2. Le coût km commercial

### 2.1 Définition

```
Coût km commercial = (Coûts totaux mensuels) / (Km commerciaux mensuels)
```

C'est l'indicateur central : il permet de fixer le **prix plancher** de toute mission.

### 2.2 Cibles secteur 2026

| Type véhicule | Coût km commercial cible |
|---|---|
| Tracteur 44 t longue distance | 1,30 - 1,55 €/km |
| Porteur 19 t régional | 1,20 - 1,45 €/km |
| Distribution urbaine 12 t | 1,40 - 1,75 €/km |
| VUL 3,5 t messagerie | 1,15 - 1,40 €/km |

### 2.3 Composantes typiques (porteur 19 t)

| Poste | €/km | % |
|---|---|---|
| Carburant | 0,40 | 32 % |
| Conducteur | 0,39 | 31 % |
| Structure | 0,10 | 8 % |
| Amortissement véhicule | 0,10 | 8 % |
| Entretien et pneus | 0,10 | 8 % |
| Péages et parking | 0,07 | 5 % |
| Assurances et taxes | 0,05 | 4 % |
| Divers (Adblue, lubrifiants) | 0,04 | 3 % |
| Total | 1,25 | 100 % |

---

## 3. Le BFR (Besoin en Fonds de Roulement)

### 3.1 Définition

```
BFR = Stocks + Créances clients - Dettes fournisseurs
```

En transport (peu de stocks), c'est essentiellement :

```
BFR ≈ Créances clients - Dettes fournisseurs
```

### 3.2 Le DSO (Days Sales Outstanding)

```
DSO = Créances clients / CA × 365
```

C'est le délai moyen de paiement client.

| DSO | Performance |
|---|---|
| < 30 j | Excellent |
| 30-45 j | Bon |
| 45-60 j | Moyen |
| > 60 j | Critique (BFR explosé) |

### 3.3 Le DPO (Days Payable Outstanding)

```
DPO = Dettes fournisseurs / Achats × 365
```

| DPO | Lecture |
|---|---|
| Comparable au DSO | Équilibre |
| > DSO | Trésorerie favorable (bon levier) |
| < DSO | Trésorerie tendue |

### 3.4 Trésorerie et BFR

> 📌 **Exemple BFR**
>
> CA mensuel : 600 k€. DSO = 50 j, DPO = 30 j.
> - Créances : 600 × 50/30 = 1 000 k€ moyennes
> - Dettes : 350 × 30/30 = 350 k€ moyennes (350 k€ d''achats/mois)
> - **BFR : 1 000 - 350 = 650 k€** à financer
>
> Réduire le DSO de 50 j à 40 j libère ~ 200 k€ de trésorerie.

---

## 4. L'EBE (Excédent Brut d'Exploitation)

### 4.1 Définition

```
EBE = CA - Achats consommés - Charges externes - Charges de personnel - Impôts et taxes
```

C'est la marge dégagée par l'**activité** pure (avant amortissements et frais financiers).

### 4.2 Taux d'EBE

```
Taux d''EBE = EBE / CA × 100
```

| Type | Cible secteur |
|---|---|
| Transport routier marchandises | 8-15 % |
| PME bien gérée | 12-18 % |
| Affrètement (marges plus faibles) | 4-8 % |

### 4.3 Importance

L'EBE est le **vrai indicateur de la performance opérationnelle**, indépendant de la politique d'amortissement et de financement. Les banquiers et investisseurs le suivent en priorité.

---

## 5. La capacité d'autofinancement (CAF)

```
CAF = Bénéfice net + Amortissements + Provisions
```

Indique la capacité de l'entreprise à financer ses investissements et son développement par ses propres ressources.

| CAF / CA | Lecture |
|---|---|
| < 5 % | Faible |
| 5-10 % | Moyenne |
| > 10 % | Bonne |

---

## 6. Cas pratique : tableau de bord financier

**Contexte** : PME *Logitrans Vendée* (15 véhicules), CA annuel 4,8 M€.

| KPI | T1 | T2 | T3 | T4 | Cible 2026 |
|---|---|---|---|---|---|
| CA mensuel moyen | 380 k€ | 410 k€ | 395 k€ | 420 k€ | > 400 k€ |
| Marge brute | 41 % | 43 % | 39 % | 44 % | > 42 % |
| Marge nette | 5,2 % | 6,1 % | 4,5 % | 6,8 % | > 6 % |
| EBE | 9,5 % | 11,2 % | 8,8 % | 11,8 % | > 10 % |
| Coût km commercial moyen | 1,42 € | 1,38 € | 1,46 € | 1,35 € | < 1,40 € |
| DSO clients | 52 j | 48 j | 56 j | 45 j | < 45 j |
| DPO fournisseurs | 32 j | 35 j | 30 j | 35 j | > 35 j |
| BFR (k€) | 580 | 540 | 620 | 480 | < 500 k€ |

### Analyse

**Trim 3 dégradé** : marges en baisse (4,5 % vs 6 %), DSO étiré à 56 j, BFR à 620 k€.

Causes probables :
- Saisonnalité (vacances, chargement plus complexe)
- Carburant en hausse (impactant coûts variables)
- Quelques gros clients en retard de paiement

**Trim 4 redressement** : actions efficaces, marge nette à 6,8 %, DSO à 45 j.

### Plan 2027

| Levier | Cible |
|---|---|
| Réduction DSO via relance systématisée | < 40 j |
| Augmentation DPO par négociation fournisseurs | > 38 j |
| Optimisation conso (éco-conduite +5 %) | < 28 L/100 km |
| Augmentation taux remplissage | > 84 % |
| Réduction retour à vide via Teleroute | < 15 % |

Impact estimé : EBE de 11 % vers 13,5 % = +120 k€ annuel.

---

> ✅ **À retenir**
>
> - **5 KPI financiers** : marge brute/nette, coût km, BFR (DSO/DPO), EBE, CAF.
> - Marge nette transport B2B : **4-12 %** selon segment, < 4 % = fragilité.
> - Coût km commercial : indicateur central pour fixer les prix.
> - **DSO < 45 j**, **DPO > 35 j** = trésorerie saine.
> - **EBE > 10 % du CA** = entreprise performante.
$lesson2$,
'KPI financiers : marge brute/nette, coût km commercial, BFR (DSO/DPO), EBE, CAF, cibles secteur, lien avec décisions opérationnelles.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — KPI qualité, satisfaction et RH
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'KPI qualité, satisfaction et RH',
    'gotrm-bc01-10-03-kpi-qualite-rh', 3, 35,
$lesson3$
# KPI qualité, satisfaction et RH

Au-delà des KPI opérationnels et financiers, le pilotage doit intégrer la **qualité de service**, la **satisfaction client** et les **ressources humaines**. Ces dimensions sont les leviers de la pérennité.

> 🎯 **Objectifs de la leçon**
>
> - Maîtriser les **KPI qualité** : taux de litiges, taux d'avaries, ponctualité.
> - Calculer le **NPS** et son évolution.
> - Suivre les **KPI RH** : turnover, accidents du travail, absentéisme.
> - Construire un **tableau de bord intégré** multidimensionnel.

---

## 1. KPI qualité

### 1.1 Taux de litiges

```
Taux de litiges = (Nombre de litiges) / (Nombre de missions) × 100
```

| Niveau | Performance |
|---|---|
| > 2 % | Critique |
| 1-2 % | Acceptable |
| 0,3-1 % | Bon |
| < 0,3 % | Excellent |

### 1.2 Taux d'avaries

```
Taux d'avaries = (Missions avec avarie) / (Total missions) × 100
```

| Niveau | Performance |
|---|---|
| > 1 % | Critique |
| 0,3-1 % | Acceptable |
| < 0,3 % | Bon |

### 1.3 Coût de la non-qualité

```
Coût NQ = Indemnisations + frais procédure + temps interne + image
```

Estimation typique : **0,5 à 1,5 % du CA** pour une entreprise standard, **2 à 4 %** pour une entreprise mal gérée.

### 1.4 Conformité documentaire

```
Conformité doc = (CMR sans erreur) / (Total CMR) × 100
```

Cible : > 99 %. Une erreur documentaire bloque la facturation et expose à des contestations.

---

## 2. KPI satisfaction client

### 2.1 NPS (Net Promoter Score)

Cf. Module BC01-08. Rappel :
- Échelle 0-10
- NPS = % Promoteurs (9-10) - % Détracteurs (0-6)
- Cible secteur transport B2B : > 25, excellent > 50

### 2.2 Taux de réclamation

```
Taux de réclamation = (Réclamations reçues) / (Missions) × 100
```

| Niveau | Performance |
|---|---|
| > 3 % | Critique |
| 1-3 % | Moyen |
| < 1 % | Bon |

### 2.3 Taux de churn (perte clients)

```
Churn = (Clients perdus) / (Clients en début de période) × 100
```

| Période | Cible churn |
|---|---|
| Annuel | < 8 % |
| Trimestriel | < 2 % |
| Mensuel | < 0,7 % |

> 📌 **Coût d'un client perdu**
>
> Un client perdu = perte de la LTV restante + coût d'acquisition d'un remplaçant.
> Pour un client moyen 80 k€/an de marge : perte de 200-300 k€ sur la durée.

### 2.4 Taux de fidélisation

```
Fidélisation = 1 - Churn = clients conservés sur la période
```

Cible : > 92 % annuel.

---

## 3. KPI ressources humaines

### 3.1 Turnover conducteurs

```
Turnover = (Départs sur la période) / (Effectif moyen) × 100
```

| Niveau | Lecture |
|---|---|
| > 25 % | Critique (entreprise toxique ou sous-rémunération) |
| 15-25 % | Élevé (norme actuelle TRM) |
| 8-15 % | Bon |
| < 8 % | Excellent (rétention forte) |

> 📌 **Coût du turnover**
>
> Remplacer un conducteur PL : 8 000-15 000 € (recrutement, formation, baisse productivité initiale, FCO/permis).

### 3.2 Absentéisme

```
Absentéisme = (Heures d'absence) / (Heures théoriques) × 100
```

| Niveau | Performance |
|---|---|
| > 10 % | Critique |
| 6-10 % | Élevé |
| 3-6 % | Norme |
| < 3 % | Excellent |

### 3.3 Accidents du travail

```
Taux de fréquence (TF) = (Accidents avec arrêt × 1 000 000) / Heures travaillées
Taux de gravité (TG) = (Jours d'arrêt × 1 000) / Heures travaillées
```

| Indicateur | Cible TRM |
|---|---|
| TF | < 25 (norme secteur ~ 35) |
| TG | < 1,2 |

### 3.4 Formation continue

| KPI | Cible |
|---|---|
| Heures formation / salarié / an | > 14 h (légal 12 h, recommandé 20+) |
| Taux de FCO valides | 100 % (obligatoire) |
| Plan formation chiffré | > 1,5 % de la masse salariale |

---

## 4. Tableau de bord intégré

### 4.1 La matrice 4x4

| Axe | KPI principaux |
|---|---|
| **Opérationnel** | Remplissage, Ponctualité, Retour à vide, Conso |
| **Financier** | Marge nette, Coût km, DSO, EBE |
| **Qualité / Client** | NPS, Taux litiges, Churn, Fidélisation |
| **Humain** | Turnover, Absentéisme, TF accidents, Formation |

### 4.2 Format mensuel recommandé

```
PILOTAGE MENSUEL — [MOIS / ANNÉE]

OPÉRATIONNEL                FINANCIER
- Remplissage : 82 % 🟧     - Marge nette : 6,8 % 🟩
- Ponctualité : 96 % 🟩     - Coût km : 1,38 € 🟩
- Retour à vide : 17 % 🟧    - DSO : 45 j 🟩
- Conso : 28,5 L 🟩          - EBE : 11,2 % 🟩

CLIENT                      RH
- NPS : 32 🟩                - Turnover annuel : 18 % 🟧
- Litiges : 0,8 % 🟩         - Absentéisme : 6,2 % 🟧
- Churn : 6 % 🟩             - TF accidents : 28 🟧
- Fidélisation : 94 % 🟩     - Heures formation : 16 h 🟩

ALERTES MOIS :
- Retour à vide en hausse (+2 pts vs M-1)
- Turnover en hausse (+3 pts vs T-1)

ACTIONS DÉCIDÉES :
- Plan retour à vide (Teleroute Premium)
- Audit climat social (groupes de parole)
```

### 4.3 Fréquence

| Niveau | Fréquence |
|---|---|
| Tableau de bord opérationnel | Hebdomadaire |
| Tableau de bord direction | Mensuel |
| Conseil d'administration | Trimestriel |
| Bilan stratégique | Annuel |

---

## 5. Cas pratique : matrice de pilotage

**Contexte** : *Express Bourgogne* (22 véhicules) à fin Q1 :

| Dimension | KPI | Valeur | Cible | Statut |
|---|---|---|---|---|
| Op. | Remplissage | 79 % | 82 % | 🟧 |
| Op. | Ponctualité | 93 % | 96 % | 🟧 |
| Op. | Retour à vide | 21 % | 16 % | 🟥 |
| Fin. | Marge nette | 4,2 % | 6 % | 🟥 |
| Fin. | DSO | 58 j | 45 j | 🟥 |
| Cli. | NPS | 12 | 25 | 🟥 |
| Cli. | Churn | 11 % | 8 % | 🟥 |
| RH | Turnover | 28 % | 15 % | 🟥 |
| RH | Absentéisme | 9 % | 6 % | 🟧 |

### Diagnostic systémique

**Indicateurs convergents au rouge** : c'est le signal d'une crise systémique, pas d'un problème ponctuel.

Hypothèse : turnover élevé (départs conducteurs) → manque d'équipages stables → erreurs et retards → ponctualité dégradée → mécontentement client (NPS) → départs (churn) → perte CA → tension financière (DSO étiré).

C'est un **cercle vicieux** classique en transport.

### Plan d'action prioritaire 6 mois

| Action | Levier | Cible 6 mois |
|---|---|---|
| 1. Audit climat social conducteurs (cabinet externe) | RH | Plan de fidélisation chiffré |
| 2. Augmentation salariale ciblée (5-8 % conducteurs) | RH + Fin | Turnover < 18 % |
| 3. Plan retour à vide (Teleroute Premium + référent) | Op. + Fin | Retour à vide < 17 % |
| 4. Procédure relance clients DSO J+30 systématique | Fin | DSO < 50 j |
| 5. Gestion proactive top 10 clients (bilans trim) | Cli. | Churn < 8 % |
| 6. Communication interne hebdomadaire | RH | Engagement renforcé |
| 7. NPS trimestriel + actions ciblées détracteurs | Cli. | NPS > 18 |

### Suivi trimestriel

À M+3 et M+6, mesurer chaque KPI et ajuster. L'objectif est de **rompre le cercle vicieux** en agissant simultanément sur plusieurs dimensions.

ROI attendu :
- Stabilisation parc conducteurs : -10 départs × 12 k€ = 120 k€ économisés
- Amélioration ponctualité : +3 pts → +2 pts NPS → -2 pts churn
- Économies retour à vide : 22 véhicules × 4 pts × 0,1 €/km × 100 000 km = 88 k€
- Total bénéfices estimés : ~ 250 k€/an

---

> ✅ **À retenir**
>
> - **KPI qualité** : litiges < 1 %, conformité doc > 99 %.
> - **KPI client** : NPS > 25 (cible secteur), churn < 8 %/an, fidélisation > 92 %.
> - **KPI RH** : turnover < 15 %, absentéisme < 6 %, TF < 25.
> - **Tableau de bord intégré** : 4 dimensions (op., fin., cli., RH) à suivre simultanément.
> - **Cercle vicieux** typique : turnover → erreurs → mécontentement → churn → tension fin.
$lesson3$,
'KPI qualité (litiges, conformité), satisfaction (NPS, churn, fidélisation), RH (turnover, absentéisme, accidents), tableau de bord intégré 4x4 et matrice systémique.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Reporting et amélioration continue
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Reporting, communication et amélioration continue',
    'gotrm-bc01-10-04-reporting-amelioration', 4, 35,
$lesson4$
# Reporting, communication et amélioration continue

Mesurer ne suffit pas : il faut **communiquer**, **engager les équipes** et **boucler la boucle** avec des plans d'action concrets. C'est ce qui différencie un tableau de bord vivant d'un fichier oublié.

> 🎯 **Objectifs de la leçon**
>
> - Construire un **reporting efficace** par niveau hiérarchique.
> - Animer une **réunion de pilotage** mensuelle.
> - Mettre en place une **boucle PDCA** sur les KPI.
> - Outiller le pilotage (BI, dashboards).

---

## 1. Le reporting par niveau

### 1.1 Niveau opérationnel (exploitants, conducteurs)

| Caractéristique | Détail |
|---|---|
| Fréquence | Quotidienne / hebdomadaire |
| Contenu | Tâches du jour, alertes véhicules, retards |
| Format | Dashboard simple, app mobile |
| Durée lecture | < 5 min |

### 1.2 Niveau direction d'exploitation

| Caractéristique | Détail |
|---|---|
| Fréquence | Hebdomadaire |
| Contenu | KPI opérationnels, retards, incidents, tendances |
| Format | Dashboard détaillé, points clés en couleur |
| Durée lecture | 15-30 min |

### 1.3 Niveau direction générale

| Caractéristique | Détail |
|---|---|
| Fréquence | Mensuelle |
| Contenu | Tous KPI synthétisés, marges, cash, projets |
| Format | Synthèse 1-2 pages + fiches détaillées |
| Durée lecture | 30 min - 1 h |

### 1.4 Niveau gouvernance / actionnaires

| Caractéristique | Détail |
|---|---|
| Fréquence | Trimestrielle ou annuelle |
| Contenu | Performance globale, stratégie, risques |
| Format | Présentation orale + slides |
| Durée | 1-2 heures |

---

## 2. Animer une réunion de pilotage

### 2.1 Structure type (60 min)

| Étape | Durée | Contenu |
|---|---|---|
| 1. Revue KPI mois N-1 | 15 min | Présentation des chiffres, comparaison cibles |
| 2. Analyse des écarts | 15 min | Causes des dérives, focus 🟥 et 🟧 |
| 3. Plans d'action en cours | 10 min | Avancement, blocages |
| 4. Nouvelles décisions | 15 min | Plans pour M, M+1, M+2 |
| 5. Conclusion | 5 min | Résumé, prochaines étapes |

### 2.2 Bonnes pratiques

| Pratique | Pourquoi |
|---|---|
| Diffusion écrite **avant** la réunion | Pas de découverte en séance |
| Focus sur les **écarts**, pas le détail | Gain de temps et concentration |
| **Plans d'action concrets** avec porteur et date | Engagement |
| **Suivi** des plans précédents | Cohérence |
| **Compte rendu** sous 48 h | Mémoire institutionnelle |

### 2.3 Pièges à éviter

- Réunions trop longues (>90 min) → désengagement
- Trop de KPI (> 20) → perte de focus
- Critiques personnelles → climat dégradé
- Pas de responsable nommément désigné par action → dilution

---

## 3. La boucle d'amélioration continue (PDCA)

### 3.1 Rappel

```
PLAN ──────► DO ──────► CHECK ──────► ACT
   ▲                                     │
   └─────────────────────────────────────┘
```

| Étape | Action |
|---|---|
| **Plan** | Identifier le problème, fixer un objectif chiffré, définir les actions |
| **Do** | Mettre en œuvre sur un périmètre pilote |
| **Check** | Mesurer les résultats vs cibles |
| **Act** | Standardiser si succès, ajuster si écart |

### 3.2 Outils complémentaires

| Outil | Usage |
|---|---|
| **Diagramme de Pareto** | Identifier les 20 % de causes faisant 80 % des effets |
| **Diagramme d'Ishikawa (5M)** | Identifier toutes les causes d'un problème |
| **5 pourquoi** | Trouver la cause racine d'un problème |
| **A3 report** | Synthétiser l'analyse + plan d'action sur 1 page |
| **Kanban** | Visualiser les actions en cours |

### 3.3 Exemple PDCA — réduction du retour à vide

| Étape | Détail |
|---|---|
| Plan | Cible : retour à vide 22 % → 16 % en 6 mois. Actions : Teleroute, formation, prime conducteurs |
| Do | Mise en œuvre M+1, suivi quotidien |
| Check | À M+3 : retour à vide à 18 % (progression mais pas cible) |
| Act | Renforcement (autre bourse fret, communication client) jusqu'à atteindre 16 % à M+6 |

---

## 4. Outils BI et dashboards

### 4.1 Les solutions du marché

| Outil | Cible |
|---|---|
| **Power BI** (Microsoft) | Standard du marché, intégration Office |
| **Tableau** | Très puissant, mais coûteux |
| **Qlik** | Bon pour analyse exploratoire |
| **Looker Studio** (Google, gratuit) | Idéal PME, lien Google Workspace |
| **Module BI intégré au TMS** | Solution couplée (AlpegaTMS, Optitrans, etc.) |

### 4.2 Architecture type

```
[TMS / ERP] ──► [Datawarehouse] ──► [Power BI / Looker] ──► [Dashboard]
                       │
                  [Tableurs]
```

### 4.3 Coût indicatif

| Solution | Coût mensuel |
|---|---|
| Power BI Pro | 10 €/utilisateur/mois |
| Looker Studio | Gratuit (mais limité) |
| Module TMS BI | 50-150 €/mois selon TMS |
| Solution sur mesure | 500-2 000 €/mois (consultant) |

---

## 5. Cas pratique : déploiement d'un dashboard mensuel

**Contexte** : *Trans-Sud SAS* (28 véhicules, 5,5 M€ CA) souhaite passer de fichiers Excel disparates à un dashboard unifié. Démarche en 90 jours.

### Phase 1 — Cadrage (sem 1-2)

- Identification des **15 KPI essentiels** (4-5 par dimension : op., fin., cli., RH)
- Définition des **sources de données** (TMS, ERP, paie, NPS, ticketing)
- Validation auprès de la direction et des exploitants

### Phase 2 — Choix outil (sem 3-4)

- Démos de 3 solutions (Power BI, Looker Studio, module TMS BI)
- Critères : coût, ergonomie, intégration, support
- **Choix** : Power BI Pro (intégration Office, ~ 60 €/mois pour 6 utilisateurs)

### Phase 3 — Construction (sem 5-9)

- Connexion aux sources (TMS, ERP, fichiers Excel paie)
- Création des **dashboards** par niveau :
  - Direction : synthèse 1 page
  - Direction d'exploitation : 4 onglets (op., fin., cli., RH)
  - Exploitants : focus opérationnel quotidien

### Phase 4 — Tests et ajustements (sem 10-11)

- Période parallèle Excel + Power BI
- Vérification cohérence des chiffres
- Retours utilisateurs, ajustements visuels

### Phase 5 — Bascule et formation (sem 12)

- Formation 2h des 6 utilisateurs principaux
- Documentation accessible (FAQ, vidéos courtes)
- Lancement officiel, abandon progressif des Excel

### Phase 6 — Ancrage (M+3)

- Réunion mensuelle pilotée à partir du dashboard
- Évolutions et ajustements continus
- Mesure du gain de temps : avant 12 h/mois en consolidation, après 2 h/mois (économie 10 h × 12 = 120 h/an, soit ~ 8 000 €)

### ROI

| Élément | Coût annuel | Bénéfice annuel |
|---|---|---|
| Power BI 6 licences | 720 € | — |
| Setup interne (200 h) | 8 000 € one-shot | — |
| Gain temps consolidation | — | 8 000 €/an |
| Décisions plus rapides (estimation) | — | 25 000 €/an |
| ROI total | ~ 9 k€ | ~ 33 k€/an (x 3,7) |

---

## 6. Communication interne : engager les équipes

### 6.1 Rendre les KPI vivants

- **Affichage hebdomadaire** dans les locaux exploitation
- **Newsletter mensuelle** synthétique aux conducteurs
- **Challenges** sur 1-2 KPI clés (éco-conduite, ponctualité)
- **Récompenses** symboliques (prime mensuelle, conducteur du mois)

### 6.2 Lier individuel et collectif

- Chaque conducteur doit voir **son score personnel** (éco-conduite, ponctualité, taux d'incidents)
- **Bonus** lié à la performance équipe ou individuelle
- **Plan de progression** personnalisé pour les conducteurs en difficulté

### 6.3 Transparence avec les clients

- Communiquer trimestriellement les KPI clés (ponctualité, incidents) aux gros clients
- Démontrer **engagement** dans la qualité
- Renforce la confiance et la fidélisation

---

> ✅ **À retenir**
>
> - **Reporting** par niveau : opérationnel (J), exploitation (Sem), direction (M), gouvernance (Trim).
> - **Réunion mensuelle** : 60 min, écarts, plans d'action concrets, compte rendu sous 48 h.
> - **PDCA** + **Pareto / Ishikawa / 5 pourquoi** = boucle d'amélioration.
> - **Power BI** ou **Looker Studio** = outils BI standards (10-60 €/utilisateur/mois).
> - **Engager les équipes** : KPI affichés, individualisés, récompensés.
$lesson4$,
'Reporting par niveau hiérarchique, animation réunion mensuelle, PDCA + outils analyse, BI (Power BI, Looker Studio), engagement équipes via KPI affichés et individualisés.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- 25 QCM
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, source_ref, type, prompt, choices, correct, explanation, difficulty, tags) VALUES

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:1', 'qcm',
   'Le taux de remplissage doit être mesuré :',
   jsonb '[
     {"key":"a","label":"En poids uniquement"},
     {"key":"b","label":"En volume uniquement"},
     {"key":"c","label":"En poids ET en volume (le maximum des deux)"},
     {"key":"d","label":"En nombre de palettes"}
   ]', '["c"]'::jsonb,
   'Le véhicule est plein dès qu''une dimension (poids OU volume) atteint 100 %. Surveiller le maximum des deux : pour de la mousse, c''est le volume qui sature, pour des granulats, c''est le poids.',
   'moyenne', '{remplissage}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:2', 'qcm',
   'Une cible de remplissage standard en TRM longue distance est :',
   jsonb '[
     {"key":"a","label":"> 60 %"},
     {"key":"b","label":"> 75 %"},
     {"key":"c","label":"> 85 %"},
     {"key":"d","label":"> 95 %"}
   ]', '["c"]'::jsonb,
   'TRM longue distance : > 85 %. LTL régional : > 75 %. Distribution urbaine : > 65 % (souvent contrainte par cubage). 95 % est un objectif d''excellence rare en pratique.',
   'moyenne', '{remplissage,cible}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:3', 'qcm',
   'Une ponctualité < 90 % entraîne statistiquement :',
   jsonb '[
     {"key":"a","label":"Une augmentation de la marge"},
     {"key":"b","label":"Un risque élevé de churn (~ 65 % de départ client en 12 mois)"},
     {"key":"c","label":"Une baisse de carburant"},
     {"key":"d","label":"Aucun impact"}
   ]', '["b"]'::jsonb,
   'Statistiquement, un client recevant < 90 % de ponctualité a 65 % de probabilité de partir dans les 12 mois. Au-dessus de 96 %, fidélisation > 85 %. La ponctualité est un levier majeur de rétention.',
   'difficile', '{ponctualite,churn}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:4', 'qcm',
   'Le taux de retour à vide en TRM longue distance "bon" est :',
   jsonb '[
     {"key":"a","label":"< 5 %"},
     {"key":"b","label":"10-15 %"},
     {"key":"c","label":"25-30 %"},
     {"key":"d","label":"50 %"}
   ]', '["b"]'::jsonb,
   '10-15 % est considéré bon en TRM longue distance. < 10 % est excellent (rare en FTL pure). > 25 % critique. La distribution urbaine a souvent 100 % de retour à vide par nature.',
   'moyenne', '{retour-vide,cible}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:5', 'qcm',
   'Une consommation cible pour un porteur 19 t en cycle régional est de :',
   jsonb '[
     {"key":"a","label":"15-20 L/100 km"},
     {"key":"b","label":"26-30 L/100 km"},
     {"key":"c","label":"40-45 L/100 km"},
     {"key":"d","label":"60-70 L/100 km"}
   ]', '["b"]'::jsonb,
   'Porteur 19 t cycle régional : 26-30 L/100 km. Tracteur 44 t longue distance : 28-33 L. Distribution urbaine 12 t : 22-28 L. VUL : 8-12 L. Variations selon profil et conducteur.',
   'facile', '{conso,porteur}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:6', 'qcm',
   'L''éco-conduite peut typiquement faire baisser la consommation de :',
   jsonb '[
     {"key":"a","label":"5 à 12 %"},
     {"key":"b","label":"30 à 50 %"},
     {"key":"c","label":"75 %"},
     {"key":"d","label":"Aucune incidence"}
   ]', '["a"]'::jsonb,
   'L''éco-conduite via formation et coaching baisse de 5 à 12 % la consommation. C''est un levier majeur, à coût modéré (formation ~ 200 €/conducteur). ROI < 6 mois sur les véhicules longue distance.',
   'moyenne', '{eco-conduite}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:7', 'qcm',
   'La marge nette en transport TRM longue distance est typiquement de :',
   jsonb '[
     {"key":"a","label":"Moins de 1 %"},
     {"key":"b","label":"4-8 %"},
     {"key":"c","label":"15-25 %"},
     {"key":"d","label":"Plus de 30 %"}
   ]', '["b"]'::jsonb,
   'TRM longue distance : 4-8 % de marge nette. LTL régional : 6-12 %. Distribution urbaine : 8-15 %. Spécifique (ADR/ATP) : 10-18 %. Ces marges restent fragiles : un sinistre peut effacer plusieurs mois.',
   'moyenne', '{marge,nette}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:8', 'qcm',
   'Une marge nette < 4 % indique :',
   jsonb '[
     {"key":"a","label":"Excellente performance"},
     {"key":"b","label":"Une fragilité structurelle face à tout incident"},
     {"key":"c","label":"Une situation normale"},
     {"key":"d","label":"Un excès de rentabilité"}
   ]', '["b"]'::jsonb,
   'Une marge nette < 4 % rend l''entreprise fragile : un sinistre, une hausse carburant, un départ conducteur peut compromettre l''équilibre. < 2 % = activité en danger structurel.',
   'moyenne', '{marge,fragilite}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:9', 'qcm',
   'Le coût km commercial cible pour un tracteur 44 t en 2026 est :',
   jsonb '[
     {"key":"a","label":"0,5 - 0,8 €/km"},
     {"key":"b","label":"1,30 - 1,55 €/km"},
     {"key":"c","label":"2,5 - 3,0 €/km"},
     {"key":"d","label":"5 €/km"}
   ]', '["b"]'::jsonb,
   'Tracteur 44 t longue distance 2026 : 1,30-1,55 €/km. Porteur 19 t régional : 1,20-1,45 €. Distribution 12 t : 1,40-1,75 €. VUL 3,5 t : 1,15-1,40 €. À comparer au prix de vente.',
   'moyenne', '{cout-km,2026}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:10', 'qcm',
   'Le BFR (Besoin en Fonds de Roulement) en transport est principalement composé de :',
   jsonb '[
     {"key":"a","label":"Stocks de marchandises"},
     {"key":"b","label":"Créances clients - Dettes fournisseurs"},
     {"key":"c","label":"Capital social"},
     {"key":"d","label":"Trésorerie disponible"}
   ]', '["b"]'::jsonb,
   'En transport (peu de stocks), le BFR ≈ Créances clients - Dettes fournisseurs. Plus le DSO est élevé et le DPO faible, plus le BFR est gourmand en trésorerie.',
   'moyenne', '{bfr}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:11', 'qcm',
   'Un DSO (Days Sales Outstanding) de 50 jours signifie :',
   jsonb '[
     {"key":"a","label":"L''entreprise paie ses fournisseurs en 50 j"},
     {"key":"b","label":"Le délai moyen de paiement par les clients est de 50 jours"},
     {"key":"c","label":"Le stock dort 50 jours"},
     {"key":"d","label":"50 jours de chiffre d''affaires"}
   ]', '["b"]'::jsonb,
   'DSO = Days Sales Outstanding = délai moyen de paiement par les clients. Un DSO de 50 j signifie que les clients paient en 50 j en moyenne. Cible secteur : < 45 j.',
   'moyenne', '{dso}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:12', 'qcm',
   'L''EBE (Excédent Brut d''Exploitation) mesure :',
   jsonb '[
     {"key":"a","label":"La marge dégagée par l''activité avant amortissements et frais financiers"},
     {"key":"b","label":"Le bénéfice après impôt"},
     {"key":"c","label":"Le chiffre d''affaires brut"},
     {"key":"d","label":"Les dividendes versés"}
   ]', '["a"]'::jsonb,
   'EBE = CA - Achats consommés - Charges externes - Charges de personnel - Impôts/taxes. C''est le vrai indicateur de performance opérationnelle, indépendant de la politique d''amortissement et de financement.',
   'moyenne', '{ebe}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:13', 'qcm',
   'Un taux d''EBE en transport routier marchandises bien géré est de :',
   jsonb '[
     {"key":"a","label":"1-3 %"},
     {"key":"b","label":"8-15 %"},
     {"key":"c","label":"25-40 %"},
     {"key":"d","label":"> 50 %"}
   ]', '["b"]'::jsonb,
   'EBE / CA bien géré : 8-15 % en TRM. PME bien gérée : 12-18 %. Affrètement (marges plus faibles) : 4-8 %. Banquiers et investisseurs scrutent ce ratio en priorité.',
   'moyenne', '{ebe,cible}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:14', 'qcm',
   'La CAF (Capacité d''Autofinancement) se calcule comme :',
   jsonb '[
     {"key":"a","label":"Bénéfice net + Amortissements + Provisions"},
     {"key":"b","label":"CA - Charges variables"},
     {"key":"c","label":"Marge nette × 1,5"},
     {"key":"d","label":"EBE - Impôts"}
   ]', '["a"]'::jsonb,
   'CAF = Bénéfice net + Amortissements + Provisions. Indique la capacité de l''entreprise à financer ses investissements avec ses propres ressources. CAF/CA > 10 % = bonne santé financière.',
   'difficile', '{caf}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:15', 'qcm',
   'Un taux de litiges considéré comme "bon" en transport est :',
   jsonb '[
     {"key":"a","label":"> 5 %"},
     {"key":"b","label":"2-5 %"},
     {"key":"c","label":"0,3-1 %"},
     {"key":"d","label":"Pas de cible"}
   ]', '["c"]'::jsonb,
   'Taux de litiges bon : 0,3-1 %. Excellent : < 0,3 %. Au-delà de 2 % : critique. Le coût de la non-qualité représente typiquement 0,5-1,5 % du CA.',
   'moyenne', '{litiges,taux}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:16', 'qcm',
   'Le NPS moyen secteur transport B2B en France est de :',
   jsonb '[
     {"key":"a","label":"-20"},
     {"key":"b","label":"20-30"},
     {"key":"c","label":"60-80"},
     {"key":"d","label":"100"}
   ]', '["b"]'::jsonb,
   'NPS moyen secteur transport B2B France : 20-30. Top quartile : > 40. Excellent : > 50. Au-dessous de 0, il y a plus de détracteurs que de promoteurs.',
   'difficile', '{nps,benchmark}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:17', 'qcm',
   'Un taux de churn annuel acceptable en transport B2B est de :',
   jsonb '[
     {"key":"a","label":"< 8 %"},
     {"key":"b","label":"15-20 %"},
     {"key":"c","label":"30-40 %"},
     {"key":"d","label":"> 50 %"}
   ]', '["a"]'::jsonb,
   'Cible churn annuel : < 8 % (fidélisation > 92 %). Un churn de 15 % signale un problème structurel. > 25 % = entreprise toxique ou marché en crise.',
   'moyenne', '{churn}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:18', 'qcm',
   'Le coût typique de remplacement d''un conducteur PL est :',
   jsonb '[
     {"key":"a","label":"500 €"},
     {"key":"b","label":"8 000 - 15 000 €"},
     {"key":"c","label":"50 000 €"},
     {"key":"d","label":"100 000 €"}
   ]', '["b"]'::jsonb,
   'Remplacer un conducteur PL : 8-15 k€ (recrutement, formation, baisse productivité initiale 2-3 mois, FCO si nouveau). C''est pourquoi la fidélisation conducteur est un enjeu majeur.',
   'moyenne', '{turnover,cout}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:19', 'qcm',
   'Un turnover conducteurs > 25 % indique généralement :',
   jsonb '[
     {"key":"a","label":"Une excellente performance"},
     {"key":"b","label":"Une situation critique (entreprise toxique ou sous-rémunération)"},
     {"key":"c","label":"Un secteur en croissance"},
     {"key":"d","label":"Une politique RH normale"}
   ]', '["b"]'::jsonb,
   'Turnover > 25 % conducteurs PL = signal d''alerte rouge. Causes typiques : management, rémunération, conditions de travail, climat. À traiter d''urgence avant cercle vicieux.',
   'moyenne', '{turnover,critique}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:20', 'qcm',
   'Le taux de fréquence (TF) des accidents du travail se calcule comme :',
   jsonb '[
     {"key":"a","label":"Nombre d''accidents par an"},
     {"key":"b","label":"(Accidents avec arrêt × 1 000 000) / heures travaillées"},
     {"key":"c","label":"% d''absentéisme"},
     {"key":"d","label":"Nombre d''accidents / effectif"}
   ]', '["b"]'::jsonb,
   'TF = (Accidents avec arrêt × 1 000 000) / Heures travaillées. Cible TRM : < 25. Norme secteur : ~ 35. Un TF élevé signale problèmes de prévention, formation, équipements.',
   'difficile', '{accidents,tf}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:21', 'qcm',
   'Le tableau de bord intégré recommandé suit combien de dimensions ?',
   jsonb '[
     {"key":"a","label":"1 (financière)"},
     {"key":"b","label":"4 (opérationnel, financier, client, RH)"},
     {"key":"c","label":"10"},
     {"key":"d","label":"Aucune"}
   ]', '["b"]'::jsonb,
   'La matrice 4x4 recommandée : 4 dimensions (op., fin., cli., RH), 4-5 KPI par dimension. Évite la tunnel vision financière et permet d''anticiper les cercles vicieux multidimensionnels.',
   'moyenne', '{tableau-bord,4-dimensions}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:22', 'qcm',
   'Une réunion de pilotage mensuelle efficace dure typiquement :',
   jsonb '[
     {"key":"a","label":"15 min"},
     {"key":"b","label":"60 min"},
     {"key":"c","label":"3 heures"},
     {"key":"d","label":"Une journée entière"}
   ]', '["b"]'::jsonb,
   'Réunion de pilotage idéale : 60 min (15 min revue KPI, 15 min écarts, 10 min actions en cours, 15 min nouvelles décisions, 5 min conclusion). Au-delà de 90 min, désengagement.',
   'moyenne', '{reunion,duree}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:23', 'qcm',
   'Le PDCA (cycle d''amélioration continue) signifie :',
   jsonb '[
     {"key":"a","label":"Plan / Do / Check / Act"},
     {"key":"b","label":"Procurement / Delivery / Control / Audit"},
     {"key":"c","label":"Plan / Distribute / Calculate / Adjust"},
     {"key":"d","label":"Process / Decide / Confirm / Apply"}
   ]', '["a"]'::jsonb,
   'PDCA (W. E. Deming) : Plan (planifier le changement), Do (exécuter pilote), Check (vérifier résultats), Act (standardiser ou ajuster). Cycle universel d''amélioration continue.',
   'facile', '{pdca}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:24', 'qcm',
   'Power BI Pro coûte typiquement :',
   jsonb '[
     {"key":"a","label":"Gratuit"},
     {"key":"b","label":"Environ 10 €/utilisateur/mois"},
     {"key":"c","label":"500 €/mois"},
     {"key":"d","label":"5 000 €/an"}
   ]', '["b"]'::jsonb,
   'Power BI Pro : ~ 10 €/utilisateur/mois (Microsoft). Looker Studio (Google) : gratuit avec limites. Tableau et Qlik : plus chers (50-100 €/utilisateur/mois). Module BI TMS : 50-150 €/mois.',
   'facile', '{power-bi,cout}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qcm:25', 'qcm',
   'Pour engager les équipes autour des KPI, la pratique recommandée est :',
   jsonb '[
     {"key":"a","label":"Cacher les chiffres aux conducteurs"},
     {"key":"b","label":"Afficher les KPI, les individualiser et les récompenser"},
     {"key":"c","label":"Sanctionner uniquement les mauvais résultats"},
     {"key":"d","label":"Ne pas en parler"}
   ]', '["b"]'::jsonb,
   'Engager les équipes = afficher les KPI dans les locaux, individualiser les performances (éco-conduite, ponctualité), récompenser symboliquement (challenges, primes). La transparence + reconnaissance = motivation.',
   'moyenne', '{engagement,kpi}');

  -- =================================================================
  -- 4 QR
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, source_ref, type, prompt, choices, correct, explanation, difficulty, tags) VALUES

  (v_formation, 'mft-2026-gotrm:bc01-10:qr:1', 'qr',
   'Une PME de 20 véhicules, CA 4,5 M€, présente ces KPI au T1 :
- Marge nette 4,1 %, EBE 9,2 %, DSO 56 j, DPO 28 j
- Taux remplissage 73 %, Ponctualité 92 %, Retour à vide 23 %, Conso 30,5 L/100 km
- NPS 5, Litiges 1,8 %, Churn 14 %
- Turnover 27 %, Absentéisme 8 %

Diagnostiquez la situation, identifiez les priorités d''action et chiffrez le ROI attendu d''un plan 12 mois.',
   '[]'::jsonb, '[]'::jsonb,
   'Diagnostic systémique :

1. Indicateurs au rouge :
- Marge nette 4,1 % (< 6 % cible) → fragilité
- DSO 56 j (> 45 j) → BFR explosé
- Taux remplissage 73 % (< 80 %) → manque-à-gagner
- Retour à vide 23 % (> 15 %) → coûts excessifs
- Conso 30,5 (> 29) → carburant excessif
- NPS 5 (< 25) → insatisfaction client massive
- Litiges 1,8 % (> 1 %) → coût non-qualité élevé
- Churn 14 % (> 8 %) → érosion base clients
- Turnover 27 % (> 15 %) → instabilité conducteurs
- Absentéisme 8 % (> 6 %) → climat dégradé

2. Indicateurs orange :
- EBE 9,2 % (cible 10-15 %)
- Ponctualité 92 % (cible > 95 %)
- DPO 28 j (cible > 35 j)

3. Diagnostic global :
Cercle vicieux systémique : turnover élevé → manque conducteurs stables → erreurs et retards (ponctualité dégradée) → mécontentement client (NPS bas) → départs (churn) → tension financière (DSO étiré, marge érodée). Toutes les dimensions se contaminent.

Plan d''action prioritaire 12 mois :

PRIORITÉ 1 — RH : casser le cercle conducteurs (M+0 à M+6)

a. Audit climat social (cabinet externe) → 8 000 €
b. Augmentation salariale ciblée +6 % conducteurs → 130 000 €/an de masse salariale
c. Plan de fidélisation : prime ancienneté, formation, primes performance → 25 000 €
d. Engagement direct : conducteur du mois, communication interne hebdo
Cible 12 mois : turnover < 18 %, absentéisme < 6 %

PRIORITÉ 2 — FINANCIER : reprise contrôle BFR (M+0 à M+3)

a. Procédure relance clients J+30 systématique → temps interne 25 000 €/an
b. Négociation DPO fournisseurs (carburants, péages) → +5 j de DPO
c. Avoir-acompte clients top 10 (5-10 % CA, exigible avant chargement)
Cible 6 mois : DSO < 50 j, DPO > 33 j, BFR -100 k€

PRIORITÉ 3 — OPÉRATIONNEL : retour à vide et remplissage (M+1 à M+6)

a. Souscription Teleroute Premium (9 000 €/an) + référent dédié
b. Démarchage 20 chargeurs sur top 5 trajets retour
c. Audit consolidation : refus tournées partielles < 60 % rempl
d. Formation éco-conduite (200 €/conducteur × 25 = 5 000 €)
Cible 12 mois : retour à vide < 17 %, remplissage > 80 %, conso < 29 L

PRIORITÉ 4 — CLIENT : redresser NPS et stopper churn (M+1 à M+12)

a. NPS trimestriel (Typeform 250 €/an)
b. Plan d''action top 30 détracteurs : entretiens et actions correctrices
c. Bilan trimestriel formel top 10 clients (visites, petit-déjeuner)
d. CRM de gestion réclamations (HubSpot Service gratuit)
Cible 12 mois : NPS > 18, churn < 10 %, litiges < 1 %

PRIORITÉ 5 — PILOTAGE (M+1 à M+3)

a. Mise en place dashboard mensuel intégré (Power BI 720 €/an)
b. Réunion de pilotage mensuelle 60 min
c. Suivi hebdomadaire opérationnel
d. Compte rendu et plans d''action documentés

Chiffrage ROI 12 mois :

| Levier | Investissement | Bénéfice annualisé |
|---|---|---|
| RH (audit, augmentation, primes) | 165 000 € | 200 000 € (turnover évité 12 × 12 k€ = 144 k€ + productivité +5 % = 56 k€) |
| Financier (BFR -100 k€) | 25 000 € | 18 000 € (frais financiers économisés) + libération 100 k€ trésorerie |
| Opérationnel (Teleroute, éco-conduite) | 14 000 € | 165 000 € (retour à vide -6 pts × 88 k€/pt = 528 k€... limité à un gain modéré 12 mois 165 k€) |
| Client (NPS, CRM) | 4 000 € | 240 000 € (3 clients sauvés × 80 k€ marge) |
| Pilotage (Power BI) | 8 000 € | 35 000 € (décisions plus rapides, gain de temps) |
| TOTAL | 216 000 € | 658 000 € + libération 100 k€ trésorerie |

ROI brut : x 3,0
ROI net (sur marge nette) : x 1,5-2 sur l''année 1, x 4-5 sur 3 ans après stabilisation.

Effets bonus :
- Crédibilité commerciale renforcée
- Capacité à viser des contrats grands comptes (qui exigent indicateurs et certifications)
- Climat interne assaini, attractivité RH
- Préparation à une éventuelle valorisation ou cession à terme

Risques de l''inaction :
- Maintien marge à 4 %, fragilité face à un sinistre majeur ou crise
- Risque cessation paiements à 18-24 mois si DSO continue de s''étirer
- Perte clients en cascade (NPS bas)

Conclusion : le plan est urgent et son ROI est très favorable. La direction doit allouer un comité de pilotage dédié et un budget initial de ~ 220 k€ sur 12 mois.',
   'difficile', '{diagnostic,plan,roi}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qr:2', 'qr',
   'Vous devez construire un dashboard mensuel intégré pour la direction de votre PME (28 véhicules). Listez les 16 KPI essentiels (4 par dimension : opérationnel, financier, client, RH), avec leurs cibles, périodicité de mesure et source de données.',
   '[]'::jsonb, '[]'::jsonb,
   'Dashboard mensuel intégré — 16 KPI essentiels :

DIMENSION OPÉRATIONNEL (4 KPI)

1. Taux de remplissage (poids et volume, max des deux)
- Cible : > 80 %
- Périodicité : Hebdomadaire et mensuelle
- Source : TMS (calcul automatique mission par mission)
- Levier : sourcing commercial, consolidation

2. Ponctualité livraisons (dans fenêtre RDV)
- Cible : > 95 %
- Périodicité : Quotidienne + agrégation mensuelle
- Source : TMS + télématique (heure d''arrivée)
- Levier : planification, alertes télématique

3. Taux de retour à vide
- Cible : < 17 %
- Périodicité : Mensuelle
- Source : TMS (km à vide / km totaux)
- Levier : bourses fret, démarchage retour

4. Consommation moyenne (L/100 km)
- Cible : < 29 L (porteur 19 t)
- Périodicité : Mensuelle (par véhicule)
- Source : Télématique + tickets carburant
- Levier : éco-conduite, maintenance, pression pneus

DIMENSION FINANCIÈRE (4 KPI)

5. Marge nette
- Cible : > 6 %
- Périodicité : Mensuelle (provisoire), trimestrielle (consolidée)
- Source : Comptabilité
- Levier : prix, coûts, productivité

6. Coût km commercial
- Cible : < 1,40 €/km
- Périodicité : Mensuelle
- Source : Comptabilité analytique + TMS (km commerciaux)
- Levier : tous coûts opérationnels

7. DSO clients (Days Sales Outstanding)
- Cible : < 45 j
- Périodicité : Mensuelle
- Source : Comptabilité (créances / CA × 365)
- Levier : relance systématique, conditions paiement

8. EBE / CA
- Cible : > 11 %
- Périodicité : Trimestrielle
- Source : Compte de résultat
- Levier : marge, productivité, structure

DIMENSION CLIENT (4 KPI)

9. NPS (Net Promoter Score)
- Cible : > 25
- Périodicité : Trimestrielle (campagne) + ad hoc après moments de vérité
- Source : Outil enquête (Typeform, SurveyMonkey)
- Levier : tous les KPI opérationnels

10. Taux de litiges
- Cible : < 1 %
- Périodicité : Mensuelle
- Source : CRM / ticketing service client
- Levier : qualité chargement, conducteurs, communication

11. Churn (perte clients)
- Cible : < 8 % annuel (< 0,7 % mensuel)
- Périodicité : Mensuelle (cumul rolling 12 mois)
- Source : CRM / ERP
- Levier : satisfaction, prix, alternatives

12. Conformité documentaire (% CMR sans erreur)
- Cible : > 99 %
- Périodicité : Mensuelle
- Source : Audit qualité TMS
- Levier : formation, contrôles aléatoires

DIMENSION RH (4 KPI)

13. Turnover conducteurs
- Cible : < 15 % annuel (< 1,3 % mensuel)
- Périodicité : Mensuelle (cumul annuel)
- Source : RH / ERP paie
- Levier : management, rémunération, conditions

14. Absentéisme
- Cible : < 6 %
- Périodicité : Mensuelle
- Source : Système de paie
- Levier : ergonomie, climat, prévention santé

15. Taux de fréquence (TF) accidents du travail
- Cible : < 25
- Périodicité : Mensuelle (cumul rolling 12 mois)
- Source : Registre AT + heures travaillées
- Levier : prévention, formation sécurité, équipements

16. Heures de formation continue / salarié / an
- Cible : > 14 h
- Périodicité : Annuelle (suivi mensuel cumulé)
- Source : Registre formations + paie
- Levier : plan formation, FCO, formations spécifiques

PRÉSENTATION DASHBOARD

Format recommandé :
- 1 page synthétique avec les 16 KPI
- Code couleur : vert (cible atteinte), orange (entre cible et seuil critique), rouge (sous seuil critique)
- Évolution sur 12 mois pour chaque KPI (sparklines)
- Section "alertes du mois" en haut
- Section "actions décidées" en bas

Outil recommandé : Power BI Pro (10 €/utilisateur/mois) ou Looker Studio (gratuit) connecté aux sources (TMS, ERP, paie, CRM).

Diffusion :
- Direction générale : 1ère semaine du mois
- Direction d''exploitation : version détaillée 4 onglets (op., fin., cli., RH)
- Exploitants : version focalisée KPI opérationnels
- Réunion de pilotage mensuelle : 60 min, présentation et discussion

Animation :
- Plans d''action sur les KPI rouges et orange
- Suivi des plans précédents
- Communication interne avec les conducteurs (KPI affichés)
- Compte rendu de réunion sous 48 h, distribué à tous les participants

ROI typique d''un dashboard intégré :
- Gain de temps consolidation : 8-12 h/mois économisées
- Décisions plus rapides : effet sur ponctualité +1-2 pts, marge +0,5 pt
- Engagement équipes : +effet sur turnover et NPS
- Total estimé : 30-50 k€/an de bénéfice pour un investissement de 5-10 k€/an.',
   'difficile', '{dashboard,kpi,construction}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qr:3', 'qr',
   'Calculez le coût km commercial d''un porteur 19 t sur la base des données suivantes :
- Acquisition véhicule : 95 000 € HT, valeur résiduelle 25 % à 6 ans
- Km annuels : 110 000 km totaux, dont 88 000 commerciaux
- Carburant : 28 L/100 km à 1,42 €/L HT
- Conducteur : coût employeur annuel 47 000 €
- Entretien et pneus : 9 800 €/an
- Péages : 7 200 €/an
- Assurances et taxes : 4 800 €/an
- Frais de structure imputés : 12 800 €/an
- Lubrifiants, AdBlue : 2 200 €/an

Détaillez les calculs et concluez sur la rentabilité par rapport à un prix de vente moyen de 1,38 €/km commercial.',
   '[]'::jsonb, '[]'::jsonb,
   'Calcul détaillé du coût km commercial :

ÉTAPE 1 — Calcul des coûts annuels totaux

1. Amortissement véhicule
- Base amortissable : 95 000 - (25 % × 95 000) = 71 250 €
- Amortissement annuel : 71 250 / 6 = 11 875 €/an

2. Carburant
- Consommation : 110 000 km × 28 / 100 = 30 800 L/an
- Coût : 30 800 × 1,42 = 43 736 €/an

3. Conducteur : 47 000 €/an (donné)

4. Entretien et pneus : 9 800 €/an (donné)

5. Péages : 7 200 €/an (donné)

6. Assurances et taxes : 4 800 €/an (donné)

7. Frais de structure imputés : 12 800 €/an (donné)

8. Lubrifiants, AdBlue : 2 200 €/an (donné)

TOTAL COÛTS ANNUELS : 11 875 + 43 736 + 47 000 + 9 800 + 7 200 + 4 800 + 12 800 + 2 200 = 139 411 €/an

ÉTAPE 2 — Calcul des coûts km

a. Coût km TOTAL : 139 411 / 110 000 = 1,267 €/km total

b. Coût km COMMERCIAL : 139 411 / 88 000 = 1,584 €/km commercial

ÉTAPE 3 — Décomposition par poste (par km commercial)

| Poste | €/km commercial | % |
|---|---|---|
| Carburant | 0,497 | 31,4 % |
| Conducteur | 0,534 | 33,7 % |
| Amortissement | 0,135 | 8,5 % |
| Structure | 0,145 | 9,2 % |
| Entretien et pneus | 0,111 | 7,0 % |
| Péages | 0,082 | 5,2 % |
| Assurances et taxes | 0,055 | 3,5 % |
| Lubrifiants AdBlue | 0,025 | 1,5 % |
| Total | 1,584 | 100 % |

ÉTAPE 4 — Analyse rentabilité

Prix de vente moyen : 1,38 €/km commercial
Coût de revient : 1,584 €/km commercial
ÉCART : -0,204 €/km commercial → DÉFICIT

CONCLUSION : ce véhicule est exploité à perte de 18,4 % par rapport à son coût.

Sur l''année :
- CA estimé : 88 000 × 1,38 = 121 440 €
- Coûts : 139 411 €
- Marge : -17 971 €/an de PERTE par véhicule

ÉTAPE 5 — Diagnostic et leviers

Le retour à vide est de (110 000 - 88 000) / 110 000 = 20 % → critique.

Leviers d''amélioration prioritaires :

1. RÉDUIRE LE RETOUR À VIDE
- Cible : passer de 20 % à 14 % (gagner 6 600 km commerciaux)
- Méthode : Teleroute, partenariats, démarchage retour
- Impact : nouveaux km commerciaux à 1,38 € → +9 100 €/an

2. AUGMENTER LE PRIX DE VENTE
- Cible : passer de 1,38 € à 1,55 €/km (+12 %)
- Méthode : revue tarifs, RPC carburant active, déclassements
- Impact : 88 000 × 0,17 = +14 960 €/an

3. RÉDUIRE LA CONSOMMATION
- Cible : passer de 28 à 26 L/100 km (-7 %)
- Méthode : éco-conduite, pression pneus, maintenance
- Impact : 110 000 × 2 / 100 × 1,42 = -3 124 €/an

4. AUGMENTER LE TAUX DE REMPLISSAGE
- Si remplissage moyen passe de 75 % à 85 % → moins de tournées partielles → meilleure productivité
- Estimation : +5-8 % de chiffre d''affaires/véhicule

ÉTAPE 6 — Scenario optimisé

En combinant les 4 leviers à objectifs raisonnables :

| Action | Impact annuel |
|---|---|
| Retour à vide -4 pts (6 200 km commerciaux gagnés) | +8 600 € |
| Prix de vente +8 % | +9 700 € |
| Consommation -5 % | -2 200 € (économie) |
| Remplissage +5 % (effet productivité) | +3 800 € |
| Total amélioration annuelle | +24 300 € |

Nouvelle marge : -17 971 + 24 300 = +6 329 €/an de bénéfice par véhicule.
Soit : passer d''une perte de 14,8 % du CA à un gain de 5,2 % du CA.

Pour 28 véhicules de la PME, cela représente : 24 300 × 28 = 680 400 € d''amélioration annuelle.

Pourquoi ce coût est-il si élevé ?

L''écart principal vient du retour à vide à 20 % (contre 14 % cible secteur). Sur un véhicule à fort kilométrage et à coûts fixes élevés (amortissement, conducteur, structure), chaque pt de retour à vide vaut ~ 4 000 €/an.

En conclusion :

Ce véhicule est en LIMITE DE RENTABILITÉ. La direction doit lancer un plan d''action multi-leviers pour redresser la situation. Sans action, c''est un véhicule à céder ou repositionner sur un autre type d''activité (lignes régulières, distribution, ATP/ADR avec marge supérieure).

Recommandations :

1. Audit immédiat des 28 véhicules pour identifier ceux dans la même situation
2. Plan d''action ciblé sur le retour à vide (priorité absolue)
3. Revue commerciale des prix avec les chargeurs
4. Plan éco-conduite généralisé
5. Mesure trimestrielle des KPI véhicule par véhicule.',
   'difficile', '{cout-km,calcul,rentabilite}'),

  (v_formation, 'mft-2026-gotrm:bc01-10:qr:4', 'qr',
   'Vous animez la réunion mensuelle de pilotage. Décrivez la structure de la réunion (60 min), les documents préparés en amont, les techniques pour traiter un KPI rouge (exemple : retour à vide à 24 % au lieu de 16 %), et le format du compte rendu.',
   '[]'::jsonb, '[]'::jsonb,
   'STRUCTURE DE LA RÉUNION (60 minutes)

Étape 1 — Accueil et tour de table (5 min)
- Validation des présents
- Rappel de l''ordre du jour
- Validation du compte rendu de la réunion précédente

Étape 2 — Revue des KPI mois N-1 (15 min)
- Présentation rapide des 16 KPI sur dashboard
- Évolution graphique sur 12 mois
- Identification des écarts cibles
- Code couleur : vert (atteint), orange (entre cible et seuil), rouge (sous seuil)

Étape 3 — Analyse des écarts critiques (15 min)
- Focus sur les KPI rouges
- Pour chaque KPI : causes identifiées, données disponibles, impacts financiers
- Si possible, croiser plusieurs KPI pour détecter les cercles vicieux

Étape 4 — Suivi des plans d''action en cours (10 min)
- Pour chaque action décidée précédemment :
  - Avancement (%)
  - Résultats mesurés
  - Blocages éventuels
- Décision : continuer, intensifier, abandonner

Étape 5 — Nouvelles décisions (15 min)
- Pour chaque KPI rouge ou orange critique :
  - Définir 1-2 actions concrètes
  - Désigner un responsable
  - Fixer une date d''échéance
  - Définir un indicateur de mesure

Étape 6 — Conclusion (5 min)
- Récapitulatif des décisions
- Date de la prochaine réunion
- Engagements individuels

DOCUMENTS PRÉPARÉS EN AMONT

À diffuser 48 h avant la réunion :

1. Dashboard mensuel (1 page synthétique des 16 KPI)
2. Onglets détaillés par dimension (pour les KPI rouges)
3. Tableau de suivi des actions en cours
4. Note de synthèse des analyses (1-2 pages)
5. Proposition d''ordre du jour avec plages horaires

TECHNIQUE POUR TRAITER UN KPI ROUGE — EXEMPLE RETOUR À VIDE 24 % (cible 16 %)

Étape 1 — Quantification de l''impact (2 min)
- Coût estimé : 28 véhicules × 8 pts d''écart × 4 000 €/pt = 896 000 €/an de manque à gagner
- C''est l''écart le plus coûteux de l''entreprise → priorité 1

Étape 2 — Analyse Pareto (3 min)
- Décomposition du retour à vide par véhicule, par ligne, par mois
- Top 5 véhicules concentrant 70 % du problème ?
- Ligne(s) ou trajet(s) particulièrement affectés ?

Étape 3 — Diagnostic 5 pourquoi (3 min)
- Pourquoi 24 % de retour à vide ?
  → Manque de fret retour identifié
- Pourquoi manque de fret retour ?
  → Pas d''abonnement bourse fret active
- Pourquoi pas d''abonnement ?
  → Décision de coupe budgétaire en début d''année
- Pourquoi cette décision ?
  → Manque d''analyse coût/bénéfice à l''époque
- Cause racine : décision financière prise sans analyse opérationnelle

Étape 4 — Solutions proposées (5 min)
- Souscription Teleroute Premium : 250 €/mois × 12 = 3 000 €
- Référent dédié à la recherche de fret retour : 0,5 ETP exploitant = 22 000 €/an
- Démarchage 20 chargeurs sur top 5 trajets retour : 0
- Total investissement : 25 000 €/an
- ROI estimé : x 35 (sur les 896 000 € de manque à gagner)

Étape 5 — Décision (2 min)
- Validation par direction
- Désignation du responsable : [nom]
- Date début : J+15
- Date premier bilan : M+1
- Échéance cible 16 % : M+6

FORMAT DU COMPTE RENDU (à envoyer sous 48 h)

```
COMPTE RENDU RÉUNION DE PILOTAGE — MOIS DE [MOIS / ANNÉE]
Date : [date]
Présents : [liste]
Excusés : [liste]

1. APPROBATION CR PRÉCÉDENT
[Validé / Modifié / Rejeté]

2. SYNTHÈSE DES KPI MOIS N-1
[Tableau résumé avec code couleur]
- Vert : [liste]
- Orange : [liste]
- Rouge : [liste]

3. ANALYSE DES ÉCARTS CRITIQUES
Pour chaque KPI rouge :
- KPI : [nom]
- Valeur : [chiffre] vs cible [chiffre]
- Impact estimé : [montant]
- Causes identifiées : [liste]

4. SUIVI DES PLANS D''ACTION EN COURS
| Action | Responsable | Échéance | Avancement | Statut |
|---|---|---|---|---|
| [détail] | [nom] | [date] | [%] | [statut] |

5. NOUVELLES DÉCISIONS
| Action | Responsable | Échéance | KPI cible | Mesure |
|---|---|---|---|---|
| [détail] | [nom] | [date] | [objectif] | [indicateur] |

6. PROCHAINE RÉUNION
- Date : [date]
- Lieu / format : [détail]

7. POINTS DIVERS
[Liste]

[Signature animateur]
```

DIFFUSION
- Email à tous les participants sous 48 h
- Archive partagée (drive)
- Mention spéciale aux porteurs d''actions

BONNES PRATIQUES

a. Préparation : tous les documents diffusés 48 h avant. Pas de découverte en séance.
b. Respect du timing : 60 min strict, animateur garant.
c. Focus : pas de digressions sur des sujets non KPI.
d. Action : chaque KPI rouge sort de la réunion avec 1-2 actions concrètes.
e. Suivi : revue systématique des actions précédentes.
f. Communication : compte rendu sous 48 h, lecture obligatoire des participants.
g. Évaluation : à chaque trimestre, demander aux participants comment améliorer la réunion.

PIÈGES À ÉVITER

- Réunion qui dérape en > 90 min : désengagement garanti
- Trop de KPI ou trop de détail : perte de focus
- Critiques personnelles : climat dégradé
- Pas de plan d''action concret : réunion improductive
- Pas de suivi des actions précédentes : pas de mémoire institutionnelle
- Animateur trop directif ou trop laxiste : équilibre à trouver
- Absence de la direction : signal de désintérêt

INTÉGRATION AU SYSTÈME GLOBAL

La réunion mensuelle s''insère dans une chaîne de pilotage à 4 niveaux :
- Quotidien : exploitation (alertes opérationnelles)
- Hebdomadaire : direction d''exploitation
- Mensuel : direction générale (cette réunion)
- Trimestriel : conseil d''administration
- Annuel : bilan stratégique

L''alimentation de la réunion mensuelle vient des outils en place (TMS, BI, CRM, paie) et alimente à son tour les niveaux trimestriel et annuel par les tendances, les actions structurantes et les décisions stratégiques.',
   'difficile', '{reunion,structure,methodes}');

  -- =================================================================
  -- QUIZZES
  -- =================================================================
  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_1, 'Quiz — KPI opérationnels', 'gotrm-bc01-10-quiz-01', 'Remplissage, ponctualité, retour à vide, productivité, conso.', 70, NULL, false, 1)
  RETURNING id INTO v_quiz_1;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-10:qcm:1','mft-2026-gotrm:bc01-10:qcm:2','mft-2026-gotrm:bc01-10:qcm:3','mft-2026-gotrm:bc01-10:qcm:4','mft-2026-gotrm:bc01-10:qcm:5','mft-2026-gotrm:bc01-10:qcm:6');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_2, 'Quiz — KPI financiers', 'gotrm-bc01-10-quiz-02', 'Marge, coût km, BFR, DSO, EBE, CAF.', 70, NULL, false, 2)
  RETURNING id INTO v_quiz_2;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-10:qcm:7','mft-2026-gotrm:bc01-10:qcm:8','mft-2026-gotrm:bc01-10:qcm:9','mft-2026-gotrm:bc01-10:qcm:10','mft-2026-gotrm:bc01-10:qcm:11','mft-2026-gotrm:bc01-10:qcm:12','mft-2026-gotrm:bc01-10:qcm:13','mft-2026-gotrm:bc01-10:qcm:14');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_3, 'Quiz — KPI qualité, client et RH', 'gotrm-bc01-10-quiz-03', 'Litiges, NPS, churn, turnover, accidents, formation.', 70, NULL, false, 3)
  RETURNING id INTO v_quiz_3;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-10:qcm:15','mft-2026-gotrm:bc01-10:qcm:16','mft-2026-gotrm:bc01-10:qcm:17','mft-2026-gotrm:bc01-10:qcm:18','mft-2026-gotrm:bc01-10:qcm:19','mft-2026-gotrm:bc01-10:qcm:20');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_4, 'Quiz — Reporting et amélioration', 'gotrm-bc01-10-quiz-04', 'Tableau de bord intégré, réunion pilotage, PDCA, BI.', 70, NULL, false, 4)
  RETURNING id INTO v_quiz_4;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-10:qcm:21','mft-2026-gotrm:bc01-10:qcm:22','mft-2026-gotrm:bc01-10:qcm:23','mft-2026-gotrm:bc01-10:qcm:24','mft-2026-gotrm:bc01-10:qcm:25');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, NULL, 'Examen blanc — BC01-10 KPI exploitation', 'gotrm-bc01-10-examen-blanc', '12 QCM en 25 min, seuil 50 %.', 50, 25, true, 5)
  RETURNING id INTO v_quiz_eb;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-10:qcm:1','mft-2026-gotrm:bc01-10:qcm:2','mft-2026-gotrm:bc01-10:qcm:4','mft-2026-gotrm:bc01-10:qcm:7','mft-2026-gotrm:bc01-10:qcm:8','mft-2026-gotrm:bc01-10:qcm:11','mft-2026-gotrm:bc01-10:qcm:12','mft-2026-gotrm:bc01-10:qcm:16','mft-2026-gotrm:bc01-10:qcm:18','mft-2026-gotrm:bc01-10:qcm:21','mft-2026-gotrm:bc01-10:qcm:23','mft-2026-gotrm:bc01-10:qcm:25');

  RAISE NOTICE '✅ GOTRM BC01-10 v2 chargé : 4 leçons, 25 QCM, 4 QR, 5 quizzes (4 entraînement + 1 examen blanc).';
END
$bc01_10$;
