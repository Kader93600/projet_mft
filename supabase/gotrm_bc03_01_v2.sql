-- =====================================================================
-- GOTRM (RNCP 40990) — BC03-01 : Coût de revient kilométrique et investissements
-- Décomposition coûts, calcul CRT, arbitrage achat/leasing, ROI.
-- =====================================================================

DO $bc03_01$
DECLARE
  v_formation uuid; v_bloc int; v_module uuid;
  v_lesson_1 uuid; v_lesson_2 uuid; v_lesson_3 uuid; v_lesson_4 uuid;
  v_quiz_1 uuid; v_quiz_2 uuid; v_quiz_3 uuid; v_quiz_4 uuid; v_quiz_eb uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc.'; END IF;

  DELETE FROM public.modules WHERE slug = 'gotrm-bc03-01-cout-revient-rentabilite';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'BC03-01 — Calculer un coût de revient kilométrique et arbitrer les investissements',
    'gotrm-bc03-01-cout-revient-rentabilite', v_bloc,
    'Décomposition détaillée des coûts, calcul du coût de revient kilométrique, arbitrage achat/leasing, calcul de ROI sur les investissements.',
    'avance', 220, 130
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 130, true) ON CONFLICT DO NOTHING;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc03-01:%';

  -- =================================================================
  -- LEÇON 1 — Décomposition détaillée des coûts
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Décomposition détaillée des coûts d''un véhicule',
    'gotrm-bc03-01-01-decomposition-couts', 1, 55,
$lesson1$
# Décomposition détaillée des coûts d'un véhicule

Calculer un coût de revient kilométrique exact suppose de **décomposer rigoureusement** tous les coûts d'un véhicule. Une approximation sur un poste = une marge erronée sur tous les prix.

> 🎯 **Objectifs de la leçon**
>
> - Maîtriser les **8 postes** de coût d'un véhicule.
> - Distinguer **coûts fixes** et **coûts variables**.
> - Connaître les **valeurs indicatives** marché 2026.
> - Calculer chaque poste avec précision.

---

## 1. Les 8 postes de coût

| Poste | Type | Indicatif porteur 19 t |
|---|---|---|
| 1. Amortissement véhicule | Fixe | 0,099 €/km |
| 2. Carburant | Variable | 0,398 €/km |
| 3. Conducteur | Mixte (fixe + variable) | 0,394 €/km |
| 4. Entretien et pneumatiques | Variable | 0,095 €/km |
| 5. Péages et parkings | Variable | 0,070 €/km |
| 6. Assurances et taxes | Fixe | 0,042 €/km |
| 7. Lubrifiants et fluides | Variable | 0,025 €/km |
| 8. Frais de structure | Fixe | 0,104 €/km |
| **Total** | | **1,227 €/km** |

---

## 2. Poste 1 — Amortissement véhicule

### 2.1 Méthode

```
Amortissement annuel = (Coût d'acquisition - Valeur résiduelle) / Durée d'amortissement
Amortissement km = Amortissement annuel / Km annuels
```

### 2.2 Valeurs marché 2026

| Type véhicule | Coût acquisition HT | Valeur résiduelle 6 ans | Durée amortissement |
|---|---|---|---|
| Tracteur 44 t | 130 000 € | 30-35 % | 6-8 ans |
| Porteur 19 t | 95 000 € | 25 % | 6 ans |
| Distribution 12 t | 78 000 € | 20-25 % | 6 ans |
| VUL 3,5 t | 35 000 € | 20 % | 5-7 ans |

### 2.3 Exemple de calcul

Porteur 19 t :
- Acquisition : 95 000 €, valeur résiduelle 25 % à 6 ans = 23 750 €
- Base amortissable : 95 000 − 23 750 = 71 250 €
- Amortissement annuel : 71 250 / 6 = 11 875 €
- Pour 120 000 km/an : 11 875 / 120 000 = **0,099 €/km**

### 2.4 Spécificités fiscales

| Mode | Conséquence |
|---|---|
| Amortissement linéaire | Standard |
| Amortissement dégressif | Permis pour véhicules industriels (coefficient × 1,75) |
| Suramortissement véhicules propres | +40 % d''amortissement déductible (jusqu''en 2030) |

---

## 3. Poste 2 — Carburant

### 3.1 Méthode

```
Coût carburant = Consommation × Prix gazole HT
Coût km = Consommation / 100 × Prix gazole HT
```

### 3.2 Données marché 2026

| Type véhicule | Consommation (L/100 km) | Coût km à 1,42 €/L |
|---|---|---|
| Tracteur 44 t longue distance | 28-33 | 0,40-0,47 |
| Porteur 19 t régional | 26-30 | 0,37-0,43 |
| Distribution 12 t urbaine | 22-28 | 0,31-0,40 |
| VUL 3,5 t | 8-12 | 0,11-0,17 |

### 3.3 Levier d'optimisation

L'éco-conduite peut réduire de 5-12 % la consommation = 0,02-0,05 €/km gagné.

---

## 4. Poste 3 — Conducteur

### 4.1 Méthode

```
Coût conducteur annuel = Salaire brut + Charges patronales + Frais de route + Avantages
Coût horaire = Coût annuel / Heures de service annuelles
Coût km = Coût horaire / Vitesse moyenne
```

### 4.2 Composantes (porteur 19 t, conducteur expérimenté)

| Élément | Mensuel | Annuel |
|---|---|---|
| Salaire brut de base (coefficient 138M) | 2 250 € | 27 000 € |
| Heures supplémentaires (~15 %) | 340 € | 4 080 € |
| Indemnités repas / découcher | 280 € | 3 360 € |
| Primes et avantages | 100 € | 1 200 € |
| Sous-total brut | 2 970 € | 35 640 € |
| Charges patronales (~42 %) | 1 080 € | 12 960 € |
| **Coût employeur total** | **3 950 €** | **47 400 €** |

### 4.3 Coût km

- Heures travaillées annuelles : 1 850 h
- Coût horaire : 47 400 / 1 850 = 25,6 €/h
- Vitesse moyenne (régional) : 65 km/h
- Coût km : 25,6 / 65 = **0,394 €/km**

### 4.4 Variations selon profil

| Profil conducteur | Surcoût |
|---|---|
| Apprenti / débutant | -15 % |
| Conducteur expérimenté | Référence |
| Conducteur ADR | +8 à 12 % |
| Conducteur double équipage | Coût × 2 sur les heures concernées |

---

## 5. Poste 4 — Entretien et pneumatiques

### 5.1 Entretien

| Type | Coût annuel indicatif |
|---|---|
| Vidanges et révisions périodiques | 2 800-4 000 € |
| Pièces d'usure (freinage, embrayage) | 1 500-3 000 € |
| Réparations imprévues | 1 500-3 500 € |
| Contrôle technique annuel | 80-120 € |
| Total porteur 19 t | 6 000-10 500 € |

Pour 120 000 km/an : 6 000-10 500 / 120 000 = 0,050-0,088 €/km.

### 5.2 Pneumatiques

| Type | Donnée |
|---|---|
| Pneus standard porteur 19 t | 480 €/pneu × 6 pneus = 2 880 € |
| Durée de vie typique | 110 000 km |
| Coût km | 2 880 / 110 000 = **0,026 €/km** |

### 5.3 Optimisation

| Levier | Économie |
|---|---|
| Pression pneus optimale | -3 % conso, +15 % durée |
| Géométrie réglée | +10 % durée |
| Choix marque premium | Plus cher mais durée x 1,3 |

---

## 6. Poste 5 — Péages et parkings

### 6.1 Péages

Variables selon zones et trajets :
- Péage moyen autoroute (porteur 19 t) : 0,18-0,25 €/km
- Mais autoroute = 50-60 % du parcours typique
- Coût km global : 0,06-0,08 €/km

### 6.2 Parkings et péages spécifiques

| Type | Coût |
|---|---|
| Parking sécurisé nuit | 25-50 €/nuit |
| Aires routières premium | 5-15 €/usage |
| Frais de douane occasionnels | 50-200 €/passage |

---

## 7. Poste 6 — Assurances et taxes

### 7.1 Assurances

| Type | Annuel indicatif |
|---|---|
| RC circulation obligatoire | 2 200-3 500 € |
| Tous risques (selon âge) | 1 500-3 000 € |
| RC marchandises (RC pro) | 800-1 500 € |
| Total porteur 19 t | 4 500-8 000 € |

Pour 120 000 km : 4 500-8 000 / 120 000 = 0,038-0,067 €/km.

### 7.2 Taxes véhicules

| Taxe | Annuel |
|---|---|
| Taxe à l'essieu (PTAC > 12 t) | 580-1 200 € |
| Carte grise (amortie sur 6 ans) | 80 € |
| Total | 660-1 280 € |

Pour 120 000 km : ~ 0,005-0,011 €/km.

---

## 8. Poste 7 — Lubrifiants et fluides

| Élément | Annuel |
|---|---|
| Lubrifiants (vidange, additifs) | 800-1 500 € |
| AdBlue (anti-pollution) | 1 200-2 000 € |
| Lave-glace, autres | 100-200 € |
| Total | 2 100-3 700 € |

Pour 120 000 km : ~ 0,018-0,031 €/km.

---

## 9. Poste 8 — Frais de structure

### 9.1 Composantes

| Poste | Détail |
|---|---|
| Salaires non opérationnels | Direction, exploitation, comptabilité, IT |
| Locaux | Loyer, charges, énergie |
| Outils administratifs | Logiciels, équipements |
| Frais généraux | Téléphone, fournitures, etc. |
| Communication, marketing | Brochures, salons, etc. |

### 9.2 Calcul

```
Frais de structure / véhicule = Total frais structure / Nombre de véhicules
Coût km = Frais par véhicule / Km annuels
```

### 9.3 Exemple

PME 20 véhicules, 250 000 € de frais de structure annuels :
- Par véhicule : 12 500 €/an
- Pour 120 000 km : 12 500 / 120 000 = **0,104 €/km**

### 9.4 Comparaison sectorielle

| Type d'entreprise | Frais structure / km |
|---|---|
| TPE 1-10 véhicules | 0,15-0,20 €/km (économies d''échelle limitées) |
| PME 10-50 véhicules | 0,08-0,12 €/km |
| ETI 50-500 véhicules | 0,05-0,08 €/km |
| Grandes entreprises > 500 véhicules | 0,04-0,06 €/km |

> 💡 **Observation**
>
> Plus l'entreprise grandit, plus la part fixe des frais de structure se dilue, ce qui constitue un avantage compétitif.

---

> ✅ **À retenir**
>
> - **8 postes** de coût : amortissement, carburant, conducteur, entretien/pneus, péages, assurances/taxes, lubrifiants, structure.
> - **Coûts fixes** (existent à l'arrêt) vs **variables** (proportionnels au km).
> - Pour porteur 19 t : ~ **1,22-1,30 €/km total** en 2026.
> - Top 3 postes : **carburant ~ 30 %**, **conducteur ~ 30 %**, **structure ~ 8 %**.
$lesson1$,
'8 postes de coûts (amortissement, carburant, conducteur, entretien, péages, assurances, lubrifiants, structure), fixes vs variables, valeurs marché 2026, calcul détaillé.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Calcul du coût de revient (CRT)
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Calcul du coût de revient transport (CRT)',
    'gotrm-bc03-01-02-calcul-crt', 2, 55,
$lesson2$
# Calcul du coût de revient transport (CRT)

Le **CRT** (Coût de Revient Transport) est l'outil quotidien de l'exploitant pour évaluer la rentabilité d'une mission. Une formule simple, mais des subtilités à maîtriser.

> 🎯 **Objectifs de la leçon**
>
> - Maîtriser la **formule CRT** standard.
> - Calculer un **CRT** sur des cas réels.
> - Comprendre l'écart **km commercial vs km total**.
> - Définir le **prix de vente** sur la base du CRT.

---

## 1. La formule CRT

### 1.1 Formule de base

```
CRT = (Km totaux × Coût km variable)
    + (Heures totales × Coût horaire fixe)
    + Coûts spécifiques mission
```

### 1.2 Décomposition

**Coût km variable** (€/km parcouru) :
- Carburant
- Entretien et pneumatiques
- Péages et parkings
- Lubrifiants et fluides

**Coût horaire fixe** (€/h de service) :
- Conducteur
- Amortissement véhicule
- Assurances et taxes (au prorata)
- Frais de structure (au prorata)

**Coûts spécifiques mission** :
- Frais douaniers spécifiques
- Hébergement (si nécessaire)
- Manutention spéciale

---

## 2. Calculer les coefficients

### 2.1 Coût km variable (porteur 19 t)

| Poste | €/km |
|---|---|
| Carburant | 0,398 |
| Entretien et pneumatiques | 0,095 |
| Péages et parkings | 0,070 |
| Lubrifiants et fluides | 0,025 |
| **Total coût km variable** | **0,588 €/km** |

### 2.2 Coût horaire fixe (porteur 19 t)

| Élément | Annuel | Heures annuelles | €/h |
|---|---|---|---|
| Conducteur | 47 400 € | 1 850 | 25,62 |
| Amortissement véhicule | 11 875 € | 1 850 | 6,42 |
| Assurances et taxes | 5 040 € | 1 850 | 2,72 |
| Frais de structure | 12 500 € | 1 850 | 6,76 |
| **Total coût horaire fixe** | | | **41,52 €/h** |

---

## 3. Exemple de calcul CRT

### 3.1 Cas — Mission Bordeaux → Toulouse

| Donnée | Valeur |
|---|---|
| Trajet aller | 250 km chargé |
| Retour | 250 km à vide |
| Km totaux | 500 km |
| Heures totales | 8 h (4 h conduite + 2 h chargement/déchargement + 2 h pause/attente) |

### 3.2 Calcul

```
CRT = (500 km × 0,588 €/km) + (8 h × 41,52 €/h) + 0 € spécifique
CRT = 294 € + 332,16 € + 0
CRT = 626,16 €
```

### 3.3 Coût km commercial

```
Coût km commercial = CRT / Km commerciaux
Coût km commercial = 626,16 / 250 = 2,50 €/km commercial
```

### 3.4 Prix de vente avec marge nette 10 %

```
Prix HT = CRT / (1 - taux marge nette)
Prix HT = 626,16 / (1 - 0,10) = 626,16 / 0,90 = 695,73 €
```

---

## 4. Le levier du retour à vide

### 4.1 Impact sur le coût km commercial

| Retour à vide | Km commerciaux pour 500 km totaux | Coût km commercial |
|---|---|---|
| 0 % (idéal) | 500 | 626 / 500 = **1,25 €/km** |
| 30 % | 350 | 626 / 350 = **1,79 €/km** |
| 50 % | 250 | 626 / 250 = **2,50 €/km** |
| 70 % | 150 | 626 / 150 = **4,17 €/km** |

### 4.2 Conclusion

Le **retour à vide** est le levier n°1 du coût km commercial. Réduire de 50 % à 20 % de retour à vide divise le coût km commercial par 2.

---

## 5. Cas pratiques avancés

### 5.1 Cas avec péages spécifiques

Mission Lyon → Genève (Suisse) :
- 150 km, 3 h de service
- Péage Suisse spécifique : 80 €
- CRT = (150 × 0,588) + (3 × 41,52) + 80 = 88,2 + 124,56 + 80 = **292,76 €**

### 5.2 Cas avec hébergement

Mission Paris → Marseille A/R 2 jours :
- 1 600 km totaux, 17 h de service réparties
- Hébergement intermédiaire : 75 €
- CRT = (1 600 × 0,588) + (17 × 41,52) + 75 = 940,8 + 705,84 + 75 = **1 721,64 €**

### 5.3 Cas double équipage

Mission Lyon → Hamburg en double équipage :
- 1 800 km, 24 h en continu
- 2 conducteurs : coût horaire conducteur × 2 sur les heures de présence
- CRT = (1 800 × 0,588) + (24 × 41,52 + 24 × 25,62) + 0 = 1 058,4 + 996,48 + 614,88 + 0 = **2 669,76 €**

---

## 6. CRT mensuel et annuel

### 6.1 CRT véhicule annuel

```
CRT véhicule annuel = (Km totaux annuels × Coût km variable)
                    + (Heures de service annuelles × Coût horaire fixe)
```

Pour porteur 19 t (110 000 km totaux/an, 1 850 h) :
```
CRT annuel = (110 000 × 0,588) + (1 850 × 41,52)
CRT annuel = 64 680 + 76 812
CRT annuel = 141 492 €/an
```

### 6.2 Comparaison avec le calcul direct

Dans la leçon 1, on avait calculé 1,227 €/km × 110 000 km = 134 970 €.

L'écart vient de l'ajustement du coût horaire fixe (qui suppose que le conducteur est mobilisé même hors mission). En pratique, on retient la valeur la plus proche de la réalité de l'entreprise.

---

## 7. Construire son barème interne

### 7.1 Principe

Avoir un **barème interne** permet de calculer rapidement un CRT sans tout reprendre à chaque mission.

### 7.2 Format type

```
BARÈME CRT — PORTEUR 19 T - 2026

Coût km variable : 0,588 €/km
Coût horaire fixe : 41,52 €/h

Pour mission standard :
- 200 km, 4 h : CRT = 117,6 + 166,1 = 284 €
- 300 km, 6 h : CRT = 176,4 + 249,1 = 426 €
- 500 km, 8 h : CRT = 294 + 332,2 = 626 €
- 800 km, 10 h : CRT = 470,4 + 415,2 = 886 €
- 1 200 km, 14 h : CRT = 705,6 + 581,3 = 1 287 €

Marges cibles :
- Brute (sur coût km variable) : 50 %
- Nette (sur prix de vente) : 8 %
```

### 7.3 Mise à jour

À actualiser **annuellement** au minimum (variation carburant, salaires, structure) et **immédiatement** lors d'une variation majeure (hausse soudaine carburant, augmentation conventionnelle).

---

> ✅ **À retenir**
>
> - **CRT** = (km × coût km variable) + (heures × coût horaire fixe) + coûts spécifiques
> - **Coût km variable porteur 19 t** : ~ 0,59 €/km
> - **Coût horaire fixe porteur 19 t** : ~ 41,5 €/h
> - **Retour à vide** = levier n°1 du coût km commercial.
> - **Barème interne** par type de véhicule, mis à jour annuellement.
$lesson2$,
'Formule CRT (km variable + heures fixes + spécifiques), coefficients porteur 19t (0,59 €/km, 41,5 €/h), levier retour à vide, barème interne actualisé annuellement.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Arbitrage achat / leasing
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Arbitrage achat vs leasing pour les véhicules',
    'gotrm-bc03-01-03-achat-leasing', 3, 55,
$lesson3$
# Arbitrage achat vs leasing pour les véhicules

L'acquisition d'un véhicule industriel représente 80 000 à 130 000 €. Choisir entre **achat**, **crédit-bail** et **location longue durée** a un impact majeur sur la trésorerie, le bilan et la fiscalité.

> 🎯 **Objectifs de la leçon**
>
> - Comparer **achat**, **crédit-bail** et **LLD**.
> - Calculer le **coût total** de chaque option.
> - Évaluer l'**impact fiscal et bilanciel**.
> - Choisir selon le profil de l'entreprise.

---

## 1. Les 3 options principales

### 1.1 Achat avec crédit (financement bancaire)

| Caractéristique | Détail |
|---|---|
| Propriété | L'entreprise propriétaire dès le départ |
| Acompte | 0 à 20 % typiquement |
| Financement | Crédit bancaire 5-7 ans |
| Inscription bilan | Actif (immobilisation) |
| Amortissement | Linéaire ou dégressif |
| Charge financière | Intérêts du crédit |

### 1.2 Crédit-bail (leasing financier)

| Caractéristique | Détail |
|---|---|
| Propriété | Loueur pendant la période, option d'achat à la fin |
| Acompte | 1er loyer majoré (5-15 %) |
| Durée | 4-7 ans |
| Inscription bilan | Hors bilan (mais retraitement IFRS) |
| Loyers | Charges déductibles |
| Option d'achat | 1-5 % de la valeur résiduelle |

### 1.3 Location Longue Durée (LLD)

| Caractéristique | Détail |
|---|---|
| Propriété | Loueur (jamais propriétaire) |
| Acompte | 0 à 1er loyer majoré |
| Durée | 3-5 ans |
| Inscription bilan | Hors bilan |
| Loyers | Charges déductibles |
| Restitution | À la fin, sans option d'achat |
| Service inclus | Souvent : entretien, pneus, assistance |

---

## 2. Comparaison économique

### 2.1 Cas type — Porteur 19 t

| Élément | Achat (crédit 7 ans, taux 5 %) | Crédit-bail 6 ans | LLD 4 ans |
|---|---|---|---|
| Acquisition | 95 000 € | 95 000 € (loyer total) | 95 000 € équivalent |
| Acompte / 1er loyer majoré | 19 000 € | 9 500 € | 0 € |
| Loyer mensuel / mensualité | 1 280 € (×84) | 1 350 € (×72) | 2 250 € (×48) |
| Total payé | 19 000 + 107 520 = 126 520 € | 9 500 + 97 200 = 106 700 € + option 5 % = 4 750 € = **111 450 €** | 108 000 € |
| Reste à payer après période | Véhicule possédé | Option achat 4 750 € | 0 € (restitué) |
| Valeur résiduelle | 23 750 € | 25 000 € | 0 € |

### 2.2 Coût net total (sur la durée)

| Mode | Total payé | Valeur résiduelle | Coût net |
|---|---|---|---|
| Achat | 126 520 € | -23 750 € (revente) | **102 770 €** |
| Crédit-bail | 111 450 € | -25 000 € (option d''achat 4 750 € + revente 25 000) = -20 250 | **96 200 €** |
| LLD | 108 000 € | 0 € | **108 000 €** |

À noter : le LLD inclut souvent l'entretien et les pneus, ce qui peut représenter 6 000-8 000 €/an d'économies cachées.

---

## 3. Impact fiscal

### 3.1 Achat

| Avantage | Inconvénient |
|---|---|
| Amortissement déductible (sur 6-8 ans) | Frais d'acquisition non déductibles |
| Charges financières déductibles | Mobilisation de capacité d'endettement |
| Suramortissement véhicules propres (40 %) | Trésorerie engagée |

### 3.2 Crédit-bail

| Avantage | Inconvénient |
|---|---|
| Loyers entièrement déductibles | Pas d'amortissement classique |
| Pas d'engagement bilanciel direct | Retraitement IFRS oblige |
| Préservation de la capacité d'endettement | Coût souvent plus élevé qu'achat |

### 3.3 LLD

| Avantage | Inconvénient |
|---|---|
| Loyers entièrement déductibles | Pas de propriété finale |
| Service inclus (entretien) | Plus cher au final |
| Renouvellement facile du parc | Pas de plus-value possible |

---

## 4. Impact bilanciel

### 4.1 Achat

- Véhicule à l'actif (amortissement progressif)
- Crédit au passif
- Améliore le ratio de fonds propres si bien géré
- Dégrade la capacité d'endettement future

### 4.2 Crédit-bail et LLD

- Véhicule HORS bilan (avant IFRS)
- Préservation de la capacité d'endettement
- Charges 100 % en compte de résultat
- Mais retraitement IFRS depuis 2019 réintroduit dans le bilan (sociétés cotées)

---

## 5. Choix selon profil entreprise

### 5.1 Quand acheter

- Trésorerie disponible
- Capacité d'endettement disponible
- Vision long terme du véhicule (> 8 ans)
- Volonté de propriété
- Suramortissement véhicules propres applicable

### 5.2 Quand préférer le crédit-bail

- Vision moyen terme (5-7 ans)
- Préservation de la capacité d'endettement
- Optimisation fiscale (charges déductibles)
- Possibilité d'option d'achat à la fin

### 5.3 Quand préférer la LLD

- Vision courte (3-5 ans)
- Volonté de renouvellement régulier du parc
- Recherche de simplicité (pas d'entretien à gérer)
- Pas de souhait de propriété
- Optimisation du temps interne (pas de gestion logistique)

### 5.4 Le mix optimal

Beaucoup d'entreprises adoptent un **mix** :
- Achat pour les véhicules « cœur » à fort kilométrage
- Crédit-bail pour les véhicules de complément
- LLD pour les véhicules à renouveler régulièrement (utilitaires, voitures direction)

---

## 6. Cas pratique : choix pour PME 12 véhicules

**Contexte** : *Trans-Méditerranée* (12 véhicules) renouvelle 4 véhicules cette année (3 porteurs 19 t + 1 utilitaire).

### Analyse

| Critère | Achat | Crédit-bail | LLD |
|---|---|---|---|
| Trésorerie disponible | -50 k€ acompte par véhicule | -10 k€ par véhicule | 0 |
| Capacité d''endettement | Diminue | Préservée | Préservée |
| Coût net total | 102 770 € (porteur) | 96 200 € | 108 000 € |
| Service inclus | Non | Non | Oui |
| Fiscalité | Amort. + intérêts | Loyers 100 % | Loyers 100 % |
| Vision longue (> 8 ans) | Oui | Possible | Non |

### Recommandation

| Véhicule | Mode recommandé | Raison |
|---|---|---|
| 2 porteurs « cœur » FTL longue distance | Achat | Vision 10+ ans, fort kilométrage, suramortissement |
| 1 porteur distribution régionale | Crédit-bail 6 ans | Vision moyen terme, optimisation fiscale |
| 1 utilitaire 3,5 t commercial | LLD 4 ans | Renouvellement régulier, simplicité |

### Plan financier

- Achat 2 porteurs : 2 × 19 000 € apport = 38 000 € de trésorerie
- Crédit-bail 1 porteur : 9 500 € 1er loyer majoré
- LLD 1 utilitaire : 0 €
- Total trésorerie engagée : 47 500 € (vs 76 000 € si tout en achat)

ROI sur 6 ans : -150 k€ vs achat tout, mais préservation de la capacité d'endettement pour autres investissements (TMS, télématique, formation).

---

## 7. Calcul de TCO (Total Cost of Ownership)

### 7.1 Formule étendue

```
TCO = Achat ou Loyers - Valeur résiduelle
    + Carburant + Entretien + Pneus + Assurances + Taxes
    + Coût conducteur (sur la durée)
    + Frais de structure (au prorata)
    + Coûts financiers (intérêts, frais)
```

### 7.2 Application

Pour un véhicule sur 6 ans, le coût d'acquisition représente seulement **15-25 % du TCO**. Les coûts d'exploitation (carburant, conducteur, entretien) représentent **75-85 %**.

> 💡 **Lecture professionnelle**
>
> Optimiser le TCO ne se résume pas à choisir le mode de financement. C'est l'ensemble des coûts (notamment éco-conduite, maintenance préventive, productivité) qui pèse le plus sur la facture finale.

---

> ✅ **À retenir**
>
> - **3 options** : achat, crédit-bail, LLD.
> - **Achat** : propriété, fiscalité avantageuse (suramortissement), engage trésorerie.
> - **Crédit-bail** : option d'achat finale, charges 100 % déductibles.
> - **LLD** : pas de propriété, service inclus, simplicité.
> - **Mix** est souvent optimal : achat pour cœur, crédit-bail pour complément, LLD pour utilitaires.
> - **TCO** : l'acquisition représente 15-25 % du coût total sur 6 ans.
$lesson3$,
'Achat vs crédit-bail vs LLD : caractéristiques, coût net, fiscalité, bilan. Mix optimal selon profil. TCO complet (acquisition 15-25 %, exploitation 75-85 %).'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Calcul de ROI et arbitrage investissements
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Calcul de ROI et arbitrage des investissements',
    'gotrm-bc03-01-04-roi-arbitrage', 4, 55,
$lesson4$
# Calcul de ROI et arbitrage des investissements

Toute décision d'investissement (véhicule, logiciel, équipement) doit reposer sur un **ROI** (Return On Investment) clair. Sans cela, l'entreprise navigue à l'aveugle et risque la mauvaise allocation des capitaux.

> 🎯 **Objectifs de la leçon**
>
> - Maîtriser les **3 méthodes** de calcul de ROI.
> - Comparer **plusieurs investissements** sur des bases similaires.
> - Décider entre **investir ou attendre**.
> - Présenter un **dossier d'investissement** structuré.

---

## 1. Les 3 méthodes de calcul de ROI

### 1.1 ROI simple (méthode rapide)

```
ROI = (Bénéfice annuel / Investissement initial) × 100
```

| Avantage | Inconvénient |
|---|---|
| Très rapide | Ne tient pas compte de la durée |
| Simple à comprendre | Pas de valeur temporelle de l'argent |
| Bon pour comparaisons rapides | Imprécise pour décisions critiques |

### 1.2 Période de retour sur investissement (Payback)

```
Payback = Investissement / Bénéfice annuel net
```

| Avantage | Inconvénient |
|---|---|
| Mesure simple en années | Ignore les bénéfices après payback |
| Aide à évaluer le risque | Ne tient pas compte des intérêts |
| Standard du secteur | Précision limitée |

### 1.3 Valeur Actuelle Nette (VAN) et Taux de Rentabilité Interne (TRI)

```
VAN = Σ (Cash flow année t / (1 + taux d'actualisation)^t) - Investissement initial
```

VAN > 0 = investissement créateur de valeur.

```
TRI = Taux d'actualisation pour lequel VAN = 0
```

TRI > coût du capital = investissement rentable.

| Avantage | Inconvénient |
|---|---|
| Tient compte de la valeur temporelle | Plus complexe à calculer |
| Standard d'investisseurs et financiers | Nécessite Excel ou outil financier |
| Précis | Sensibilité au taux d'actualisation |

---

## 2. Cas pratique 1 — Acquisition d'un nouveau porteur

**Contexte** : Investir 95 000 € dans un porteur 19 t neuf.

### Calculs

| Indicateur | Valeur |
|---|---|
| Investissement initial | 95 000 € |
| Bénéfice net annuel attendu | 18 500 € (CA 165 k - coûts 146,5 k) |
| Durée d'amortissement | 6 ans |
| Valeur résiduelle | 23 750 € |
| Cash flow total sur 6 ans | 18 500 × 6 + 23 750 = 134 750 € |

### ROI simple

```
ROI = 18 500 / 95 000 × 100 = 19,5 % par an
```

### Payback

```
Payback = 95 000 / 18 500 = 5,1 ans
```

### VAN (taux 5 %)

```
VAN = -95 000 + 18 500/1,05 + 18 500/1,05² + ... + (18 500 + 23 750)/1,05^6
VAN ≈ -95 000 + 17 619 + 16 780 + 15 981 + 15 220 + 14 495 + 31 627
VAN ≈ +16 722 €
```

VAN positive = investissement créateur de valeur.

### Conclusion

Investissement rentable :
- ROI annuel 19,5 %
- Payback 5,1 ans (acceptable sur durée 6 ans)
- VAN +16 722 € (création de valeur de ~ 18 % sur 6 ans)

---

## 3. Cas pratique 2 — Investissement TMS

**Contexte** : Investir 60 000 € dans un nouveau TMS (achat + intégration + formation).

### Bénéfices attendus

| Bénéfice | Annuel |
|---|---|
| Gain de productivité (3 exploitants × 10 h/sem économisées × 35 €/h × 47 sem) | 49 350 € |
| Réduction des erreurs (évitement litiges) | 12 000 € |
| Optimisation tournées (-3 % retour à vide × 22 véhicules) | 18 000 € |
| Total bénéfices annuels | 79 350 € |

### Coûts récurrents

- Abonnement TMS : 12 000 €/an
- Maintenance interne : 3 000 €/an
- Total : 15 000 €/an

### Bénéfice net annuel

```
Bénéfice net = 79 350 - 15 000 = 64 350 €/an
```

### ROI

| Indicateur | Valeur |
|---|---|
| ROI simple | 64 350 / 60 000 = 107 % par an |
| Payback | 60 000 / 64 350 = 11,2 mois |

### Conclusion

Investissement très rentable, payback < 1 an, ROI annuel > 100 %.

---

## 4. Cas pratique 3 — Comparaison de 3 projets

**Contexte** : Vous avez 200 000 € à investir et 3 projets concurrents.

| Projet | Investissement | Bénéfice annuel | ROI | Payback |
|---|---|---|---|---|
| A. Renouvellement 2 véhicules | 190 000 € | 35 000 € | 18 % | 5,4 ans |
| B. TMS + télématique | 80 000 € | 95 000 € | 119 % | 0,8 an |
| C. Atelier de maintenance interne | 150 000 € | 30 000 € | 20 % | 5,0 ans |

### Décision

| Critère | Choix |
|---|---|
| ROI le plus élevé | B (TMS) |
| Payback le plus court | B |
| Stratégique long terme | A ou C |
| Reste de budget | 200 - 80 = 120 k€ |

**Recommandation** : Faire B en priorité (rentabilité immédiate). Avec les 120 k€ restants, démarrer A (1 véhicule) ou différer C.

> 💡 **Méthode des décisions multiples**
>
> Quand plusieurs investissements sont possibles, prioriser selon :
> 1. ROI le plus élevé
> 2. Payback le plus court
> 3. Stratégie long terme
> 4. Risque associé
> 5. Effet sur les autres projets

---

## 5. Le dossier d'investissement

### 5.1 Structure type (10-15 pages)

1. Synthèse exécutive (1 page)
2. Contexte et motivation (1 page)
3. Description de l'investissement (2 pages)
4. Analyse économique (3-4 pages)
5. Analyse des risques (1-2 pages)
6. Analyse stratégique (1 page)
7. Plan de mise en œuvre (1-2 pages)
8. Conclusion et recommandation (1 page)

### 5.2 Section économique

- Investissement initial (acquisition + frais annexes)
- Coûts récurrents (maintenance, abonnement, RH)
- Bénéfices attendus chiffrés (avec justifications)
- Hypothèses (réalistes, sources)
- Scénarios (optimiste, central, pessimiste)
- Sensibilité (variation ±20 % des principaux paramètres)
- Indicateurs (ROI, Payback, VAN, TRI)

### 5.3 Analyse des risques

| Risque | Probabilité | Impact | Mitigation |
|---|---|---|---|
| Bénéfices surestimés | Moyenne | Fort | Scénario pessimiste |
| Délais de mise en œuvre | Élevée | Modéré | Buffer 20 % |
| Adhésion des équipes | Moyenne | Fort | Plan de formation |
| Évolution réglementaire | Faible | Variable | Veille + flexibilité |

---

## 6. Quand reporter un investissement

### 6.1 Signaux pour différer

- ROI < 10 % et payback > 7 ans
- Trésorerie tendue (BFR élevé, DSO étiré)
- Incertitude réglementaire majeure (transition énergétique, ZFE)
- Disponibilité d'alternatives moins coûteuses (LLD, partage)
- Manque de ressources internes pour porter le projet

### 6.2 Signaux pour accélérer

- ROI > 20 % et payback < 3 ans
- Aubaine fiscale temporaire (suramortissement)
- Risque concurrentiel sans l'investissement
- Croissance forte qui justifie la capacité supplémentaire
- Disponibilité de subventions ou aides

---

## 7. Cas pratique final — Décision d'investissement complexe

**Contexte** : *Logitrans Sud* (28 véhicules) doit décider entre :
- A. Achat de 3 nouveaux porteurs électriques (210 k€/véhicule × 3 = 630 k€) avec aide ADEME 80 k€
- B. Renouvellement de 4 porteurs diesel (95 k€ × 4 = 380 k€)
- C. Mix : 1 électrique + 2 diesel (210 + 190 = 400 k€)

### Analyse

| Critère | Option A (3 électriques) | Option B (4 diesel) | Option C (mix) |
|---|---|---|---|
| Investissement net | 630 - 80 = 550 k€ | 380 k€ | 400 - 27 (aide proratisée) = 373 k€ |
| Coût exploitation/an | -10 % vs diesel (carburant) | Standard | -3,3 % en moyenne |
| Bénéfice CA additionnel | Premium clients ZFE +15 % | Standard | +5 % en moyenne |
| Risque opérationnel | Élevé (autonomie, charge) | Faible | Modéré |
| Risque concurrentiel | Faible (avant-garde) | Moyen | Faible |

### Décision

**Option C — Mix** est recommandée :
- Investissement maîtrisé (373 k€)
- 1 véhicule électrique pour expérimenter et démarcher clients ZFE
- 2 véhicules diesel pour fiabilité et productivité
- Risque limité, apprentissage progressif

### Calcul ROI option C

| Élément | Valeur |
|---|---|
| Investissement net | 373 000 € |
| Bénéfice net annuel attendu | 65 000 € |
| ROI | 17 % |
| Payback | 5,7 ans |

### Conditions de réussite

1. Sécuriser l''aide ADEME (paperasse précise)
2. Recruter ou former 1 conducteur sur véhicule électrique
3. Prospecter 5-10 clients ZFE pour valider le marché premium
4. Évaluation à 18 mois pour décider d''accélérer (3 électriques l''an suivant) ou de revenir au diesel

---

> ✅ **À retenir**
>
> - **3 méthodes ROI** : ROI simple, Payback, VAN/TRI.
> - **Décision** quand plusieurs projets : prioriser ROI + Payback, puis stratégie long terme.
> - **Dossier d'investissement** : 10-15 pages avec analyse économique, risques, stratégie.
> - **Différer** si ROI faible, trésorerie tendue, incertitude majeure.
> - **Accélérer** si aubaine fiscale, risque concurrentiel, croissance forte.
$lesson4$,
'3 méthodes ROI (simple, payback, VAN/TRI), comparaison projets, dossier d''investissement structuré, signaux pour différer ou accélérer, exemple décision complexe.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- 28 QCM
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qcm', 'Le coût d''un porteur 19 t neuf est typiquement de :', '[{"id":"a","label":"30 000 €","is_correct":false},{"id":"b","label":"95 000 €","is_correct":true},{"id":"c","label":"250 000 €","is_correct":false},{"id":"d","label":"500 000 €","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['couts','acquisition'], 'mft-2026-gotrm:bc03-01:qcm:1', true, 'Coût acquisition porteur 19 t neuf : 95 000 € HT typiquement (variable selon options). Tracteur 44 t : ~ 130 000 €. Distribution 12 t : ~ 78 000 €. VUL 3,5 t : ~ 35 000 €.'),
  (v_formation, 'qcm', 'Le poste qui pèse le plus dans le coût de revient kilométrique d''un porteur 19 t est :', '[{"id":"a","label":"L''amortissement","is_correct":false},{"id":"b","label":"Carburant et conducteur (à parité, ~ 30 % chacun)","is_correct":true},{"id":"c","label":"Les assurances","is_correct":false},{"id":"d","label":"Les pneumatiques","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['couts','decomposition'], 'mft-2026-gotrm:bc03-01:qcm:2', true, 'Carburant ~ 30 % et conducteur ~ 30 % du coût total. Suivent : structure (~ 8 %), amortissement (~ 8 %), entretien et pneus (~ 8 %), assurances/taxes (~ 4 %), péages (~ 5 %), lubrifiants (~ 3 %).'),
  (v_formation, 'qcm', 'L''amortissement d''un porteur 19 t (acquisition 95 k€, valeur résiduelle 25 % à 6 ans, 120 000 km/an) donne :', '[{"id":"a","label":"0,066 €/km","is_correct":false},{"id":"b","label":"0,099 €/km","is_correct":true},{"id":"c","label":"0,158 €/km","is_correct":false},{"id":"d","label":"0,250 €/km","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['calcul','amortissement'], 'mft-2026-gotrm:bc03-01:qcm:3', true, 'Base amortissable = 95 000 - 23 750 = 71 250 €. Amortissement annuel = 71 250 / 6 = 11 875 €. Coût km = 11 875 / 120 000 = 0,099 €/km.'),
  (v_formation, 'qcm', 'Pour 28 L/100 km à 1,42 €/L HT, le coût carburant kilométrique est :', '[{"id":"a","label":"0,200 €/km","is_correct":false},{"id":"b","label":"0,300 €/km","is_correct":false},{"id":"c","label":"0,398 €/km","is_correct":true},{"id":"d","label":"0,500 €/km","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['calcul','carburant'], 'mft-2026-gotrm:bc03-01:qcm:4', true, '28 × 1,42 / 100 = 0,3976 €/km, arrondi 0,398 €/km. C''est le calcul standard du coût carburant : Consommation × Prix gazole HT / 100.'),
  (v_formation, 'qcm', 'Le coût employeur annuel d''un conducteur PL expérimenté (CDI, coefficient 138M) est typiquement :', '[{"id":"a","label":"15 000 €","is_correct":false},{"id":"b","label":"30 000 €","is_correct":false},{"id":"c","label":"47 000 €","is_correct":true},{"id":"d","label":"80 000 €","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['couts','conducteur'], 'mft-2026-gotrm:bc03-01:qcm:5', true, 'Coût employeur ~ 47 000 €/an : salaire brut 27 000 + heures sup 4 080 + indemnités 3 360 + primes 1 200 + charges patronales (~ 42 %) 12 960 = 47 400 €.'),
  (v_formation, 'qcm', 'Pour un conducteur à 25,6 €/h et une vitesse moyenne de 65 km/h, le coût km conducteur est :', '[{"id":"a","label":"0,256 €/km","is_correct":false},{"id":"b","label":"0,394 €/km","is_correct":true},{"id":"c","label":"0,512 €/km","is_correct":false},{"id":"d","label":"0,650 €/km","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['calcul','conducteur'], 'mft-2026-gotrm:bc03-01:qcm:6', true, '25,6 / 65 = 0,394 €/km. Coût horaire / Vitesse moyenne. Pour un porteur urbain (vitesse moyenne 30 km/h) : 25,6 / 30 = 0,853 €/km, soit beaucoup plus cher en distribution urbaine.'),
  (v_formation, 'qcm', 'Le coût km variable typique d''un porteur 19 t (carburant + entretien + péages + lubrifiants) est :', '[{"id":"a","label":"~ 0,30 €/km","is_correct":false},{"id":"b","label":"~ 0,59 €/km","is_correct":true},{"id":"c","label":"~ 1,00 €/km","is_correct":false},{"id":"d","label":"~ 1,50 €/km","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['calcul','variable'], 'mft-2026-gotrm:bc03-01:qcm:7', true, 'Coût km variable porteur 19 t = ~ 0,59 €/km. Décomposition : carburant 0,40 + entretien 0,10 + péages 0,07 + lubrifiants 0,02 = 0,59 €/km. À distinguer du coût total (incluant fixes) ~ 1,22-1,30 €/km.'),
  (v_formation, 'qcm', 'Le coût horaire fixe d''un porteur 19 t (conducteur + amortissement + assurances + structure) est typiquement :', '[{"id":"a","label":"~ 15 €/h","is_correct":false},{"id":"b","label":"~ 41,5 €/h","is_correct":true},{"id":"c","label":"~ 100 €/h","is_correct":false},{"id":"d","label":"~ 250 €/h","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['calcul','horaire'], 'mft-2026-gotrm:bc03-01:qcm:8', true, 'Coût horaire fixe ~ 41,5 €/h : conducteur 25,6 + amortissement 6,4 + assurances 2,7 + structure 6,8 = 41,5 €/h. Multiplié par les heures de service de la mission.'),
  (v_formation, 'qcm', 'La formule CRT (Coût de Revient Transport) standard est :', '[{"id":"a","label":"Coût km × Km totaux uniquement","is_correct":false},{"id":"b","label":"(Km × coût km variable) + (Heures × coût horaire fixe) + coûts spécifiques","is_correct":true},{"id":"c","label":"CA - Charges variables","is_correct":false},{"id":"d","label":"Coût total annuel / 12","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['crt','formule'], 'mft-2026-gotrm:bc03-01:qcm:9', true, 'CRT = (km × coût km variable) + (heures × coût horaire fixe) + coûts spécifiques mission. Méthode standard d''évaluation rapide d''une mission. Distinct du coût annuel global divisé par km.'),
  (v_formation, 'qcm', 'Pour une mission Bordeaux-Toulouse (250 km commerciaux + 250 km à vide, 8 h totales), CRT avec coefficients standard ~ :', '[{"id":"a","label":"200 €","is_correct":false},{"id":"b","label":"425 €","is_correct":false},{"id":"c","label":"626 €","is_correct":true},{"id":"d","label":"1 000 €","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['calcul','crt'], 'mft-2026-gotrm:bc03-01:qcm:10', true, 'CRT = (500 × 0,588) + (8 × 41,52) = 294 + 332 = 626 €. C''est le calcul standard pour une mission FTL régionale avec retour à vide.'),
  (v_formation, 'qcm', 'Si un véhicule a 50 % de retour à vide, son coût km commercial est :', '[{"id":"a","label":"Égal au coût km total","is_correct":false},{"id":"b","label":"Doublé par rapport au coût km total","is_correct":true},{"id":"c","label":"Réduit de moitié","is_correct":false},{"id":"d","label":"Identique","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['retour-vide','calcul'], 'mft-2026-gotrm:bc03-01:qcm:11', true, '50 % de retour à vide signifie que tous les coûts (sur 100 % des km) sont absorbés par seulement 50 % des km commerciaux. Coût km commercial = Coût km total × 2.'),
  (v_formation, 'qcm', 'Pour calculer le prix de vente avec marge nette 10 %, la formule est :', '[{"id":"a","label":"Prix = CRT × 1,10","is_correct":false},{"id":"b","label":"Prix = CRT / (1 - 0,10)","is_correct":true},{"id":"c","label":"Prix = CRT + 10 €","is_correct":false},{"id":"d","label":"Prix = CRT × 0,90","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['prix','marge'], 'mft-2026-gotrm:bc03-01:qcm:12', true, 'Prix = CRT / (1 - taux marge nette). Pour CRT 626 € avec marge 10 % : Prix = 626 / 0,90 = 695,56 €. CRT × 1,10 donnerait 9 % de marge réelle (erreur classique).'),
  (v_formation, 'qcm', 'L''option "achat d''un véhicule" se caractérise par :', '[{"id":"a","label":"Pas de propriété","is_correct":false},{"id":"b","label":"Propriété dès le départ + amortissement déductible","is_correct":true},{"id":"c","label":"Loyers entièrement déductibles","is_correct":false},{"id":"d","label":"Service inclus","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['achat','caracteristiques'], 'mft-2026-gotrm:bc03-01:qcm:13', true, 'Achat = propriété immédiate, financement par crédit possible, amortissement déductible (linéaire ou dégressif), inscription à l''actif. Le suramortissement véhicules propres (40 %) est un avantage majeur jusqu''en 2030.'),
  (v_formation, 'qcm', 'Le crédit-bail (leasing financier) implique :', '[{"id":"a","label":"Propriété immédiate de l''entreprise","is_correct":false},{"id":"b","label":"Loyers déductibles + option d''achat à la fin de la période","is_correct":true},{"id":"c","label":"Service entretien systématiquement inclus","is_correct":false},{"id":"d","label":"Pas de loyer pendant 6 ans","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['credit-bail'], 'mft-2026-gotrm:bc03-01:qcm:14', true, 'Crédit-bail : loueur propriétaire, l''entreprise paie des loyers (100 % déductibles), peut lever une option d''achat à la fin (1-5 % de la valeur résiduelle). Distinct de la LLD (pas d''option d''achat).'),
  (v_formation, 'qcm', 'La LLD (Location Longue Durée) se distingue par :', '[{"id":"a","label":"L''option d''achat à la fin","is_correct":false},{"id":"b","label":"Le service entretien souvent inclus + restitution sans propriété finale","is_correct":true},{"id":"c","label":"L''absence de loyers","is_correct":false},{"id":"d","label":"L''inscription au bilan","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['lld'], 'mft-2026-gotrm:bc03-01:qcm:15', true, 'LLD : pas de propriété finale, restitution à la fin, mais service entretien et pneus souvent inclus. Idéal pour renouvellement régulier du parc et simplification de la gestion.'),
  (v_formation, 'qcm', 'Le suramortissement véhicules propres (jusqu''en 2030) permet :', '[{"id":"a","label":"Aucun avantage","is_correct":false},{"id":"b","label":"+40 % d''amortissement déductible","is_correct":true},{"id":"c","label":"-50 % de TVA","is_correct":false},{"id":"d","label":"Une réduction de la prime d''assurance","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['suramortissement'], 'mft-2026-gotrm:bc03-01:qcm:16', true, 'Suramortissement véhicules propres (gaz naturel, électrique, hydrogène) : déduction supplémentaire de 40 % de la valeur d''origine, étalée sur la durée d''amortissement. Avantage fiscal majeur (jusqu''en 2030 actuellement).'),
  (v_formation, 'qcm', 'Le ROI simple d''un investissement de 60 000 € qui génère 80 000 € de bénéfice annuel est :', '[{"id":"a","label":"75 %","is_correct":false},{"id":"b","label":"107 %","is_correct":false},{"id":"c","label":"133 %","is_correct":true},{"id":"d","label":"200 %","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['roi','calcul'], 'mft-2026-gotrm:bc03-01:qcm:17', true, 'ROI = 80 000 / 60 000 × 100 = 133 % par an. Excellent ROI (payback < 1 an).'),
  (v_formation, 'qcm', 'Le payback (période de retour) d''un investissement de 95 000 € avec bénéfice annuel de 18 500 € est :', '[{"id":"a","label":"3 ans","is_correct":false},{"id":"b","label":"5,1 ans","is_correct":true},{"id":"c","label":"8 ans","is_correct":false},{"id":"d","label":"12 ans","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['payback','calcul'], 'mft-2026-gotrm:bc03-01:qcm:18', true, '95 000 / 18 500 = 5,13 ans. Pour un véhicule amorti sur 6 ans, c''est acceptable (l''investissement est récupéré avant la fin de l''amortissement).'),
  (v_formation, 'qcm', 'Une VAN positive d''un projet signifie que :', '[{"id":"a","label":"Le projet est non rentable","is_correct":false},{"id":"b","label":"Le projet crée de la valeur (au-delà du coût du capital)","is_correct":true},{"id":"c","label":"Il faut augmenter le taux d''actualisation","is_correct":false},{"id":"d","label":"L''investissement initial est insuffisant","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['van','interpretation'], 'mft-2026-gotrm:bc03-01:qcm:19', true, 'VAN positive = la somme actualisée des cash flows futurs dépasse l''investissement initial. Le projet crée donc de la valeur au-delà du coût du capital. C''est un indicateur clé pour les investisseurs.'),
  (v_formation, 'qcm', 'Le TRI (Taux de Rentabilité Interne) est :', '[{"id":"a","label":"Le taux d''intérêt bancaire","is_correct":false},{"id":"b","label":"Le taux d''actualisation pour lequel la VAN est nulle","is_correct":true},{"id":"c","label":"Le taux de marge brute","is_correct":false},{"id":"d","label":"Le taux de TVA applicable","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['tri','definition'], 'mft-2026-gotrm:bc03-01:qcm:20', true, 'TRI = taux d''actualisation pour lequel VAN = 0. C''est le rendement intrinsèque du projet. Si TRI > coût du capital (ex : 5 %), le projet est rentable.'),
  (v_formation, 'qcm', 'Sur un véhicule de 6 ans d''utilisation, l''acquisition représente typiquement quelle part du TCO ?', '[{"id":"a","label":"5 %","is_correct":false},{"id":"b","label":"15-25 %","is_correct":true},{"id":"c","label":"50 %","is_correct":false},{"id":"d","label":"80 %","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['tco','decomposition'], 'mft-2026-gotrm:bc03-01:qcm:21', true, 'Sur 6 ans, l''acquisition représente 15-25 % du TCO total. Les coûts d''exploitation (carburant, conducteur, entretien) représentent 75-85 %. Optimiser l''exploitation a un impact bien supérieur à négocier le prix d''achat.'),
  (v_formation, 'qcm', 'Pour comparer plusieurs investissements, le critère le plus complet est :', '[{"id":"a","label":"Le ROI simple","is_correct":false},{"id":"b","label":"La VAN (avec un taux d''actualisation cohérent)","is_correct":true},{"id":"c","label":"Le coût initial","is_correct":false},{"id":"d","label":"La durée d''amortissement","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['van','comparaison'], 'mft-2026-gotrm:bc03-01:qcm:22', true, 'La VAN (Valeur Actuelle Nette) est le critère le plus complet : elle prend en compte la valeur temporelle de l''argent et permet de comparer des projets de durées et profils différents sur une base homogène.'),
  (v_formation, 'qcm', 'Un dossier d''investissement structuré comprend typiquement :', '[{"id":"a","label":"1 page de synthèse uniquement","is_correct":false},{"id":"b","label":"10-15 pages avec analyse économique, risques et plan de mise en œuvre","is_correct":true},{"id":"c","label":"50 pages obligatoirement","is_correct":false},{"id":"d","label":"Aucune structure imposée","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['dossier-investissement'], 'mft-2026-gotrm:bc03-01:qcm:23', true, '10-15 pages : synthèse exécutive (1), contexte (1), description (2), analyse économique (3-4), risques (1-2), stratégie (1), plan mise en œuvre (1-2), conclusion (1). Format efficace pour décision.'),
  (v_formation, 'qcm', 'L''éco-conduite peut typiquement réduire la consommation de carburant de :', '[{"id":"a","label":"0,5 %","is_correct":false},{"id":"b","label":"5-12 %","is_correct":true},{"id":"c","label":"30-40 %","is_correct":false},{"id":"d","label":"50-60 %","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['eco-conduite'], 'mft-2026-gotrm:bc03-01:qcm:24', true, 'Éco-conduite par formation et coaching : -5 à -12 % de carburant. Sur un porteur 19 t à 28 L/100 km, c''est 1,5 à 3,5 L/100 km gagnés, soit 0,02-0,05 €/km. Pour 110 000 km/an : 2 200-5 500 € économisés/an/véhicule.'),
  (v_formation, 'qcm', 'Quelle option de financement préserve le mieux la capacité d''endettement future ?', '[{"id":"a","label":"Achat avec crédit bancaire","is_correct":false},{"id":"b","label":"LLD (Location Longue Durée)","is_correct":true},{"id":"c","label":"Achat comptant","is_correct":false},{"id":"d","label":"Achat avec apport élevé","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['lld','bilan'], 'mft-2026-gotrm:bc03-01:qcm:25', true, 'LLD préserve la capacité d''endettement car les loyers sont en compte de résultat (charges 100 % déductibles), pas de crédit au passif. Le crédit-bail aussi (mais retraitement IFRS pour sociétés cotées). L''achat avec crédit mobilise la capacité d''endettement.'),
  (v_formation, 'qcm', 'Pour les véhicules « cœur » à fort kilométrage et vision long terme (> 8 ans), le mode de financement le plus adapté est :', '[{"id":"a","label":"LLD 3 ans","is_correct":false},{"id":"b","label":"Achat (souvent avec suramortissement)","is_correct":true},{"id":"c","label":"Crédit-bail 4 ans","is_correct":false},{"id":"d","label":"Location courte durée","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['achat','strategie'], 'mft-2026-gotrm:bc03-01:qcm:26', true, 'Pour les véhicules cœur à fort kilométrage : achat préférable. Avantages : amortissement déductible, suramortissement véhicules propres, propriété, possibilité de revente avec plus-value, vision long terme.'),
  (v_formation, 'qcm', 'Pour les véhicules à renouveler régulièrement (utilitaires, voitures direction), le mode le plus adapté est :', '[{"id":"a","label":"Achat avec amortissement long","is_correct":false},{"id":"b","label":"LLD avec service inclus","is_correct":true},{"id":"c","label":"Crédit-bail 10 ans","is_correct":false},{"id":"d","label":"Location courte sur 24 ans","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['lld','strategie'], 'mft-2026-gotrm:bc03-01:qcm:27', true, 'LLD pour les véhicules à renouveler régulièrement : pas de propriété, service entretien inclus, simplicité opérationnelle, renouvellement facile (3-5 ans). Idéal pour utilitaires VUL, voitures direction.'),
  (v_formation, 'qcm', 'Le coût km global d''un porteur 19 t en 2026 (toutes charges incluses) est typiquement :', '[{"id":"a","label":"0,50 €/km","is_correct":false},{"id":"b","label":"1,22-1,30 €/km","is_correct":true},{"id":"c","label":"2,50 €/km","is_correct":false},{"id":"d","label":"5 €/km","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['cout-km','reference'], 'mft-2026-gotrm:bc03-01:qcm:28', true, 'Coût km total porteur 19 t en 2026 : ~ 1,22-1,30 €/km (variable selon profil exploitation, frais de structure, etc.). Le prix de vente cible doit être supérieur (typiquement 1,40 €/km commercial pour marge nette 8-10 %).');


  -- =================================================================
  -- 5 QR
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qr', 'Calculez le coût de revient kilométrique complet d''un porteur 19 t à partir des données suivantes :
- Acquisition 95 000 €, valeur résiduelle 25 % à 6 ans, 110 000 km totaux/an
- Carburant 28 L/100 km à 1,42 €/L
- Conducteur : coût employeur 47 400 €/an, 1 850 h travaillées
- Entretien : 7 500 €/an, pneus 2 880 €/110 000 km
- Péages 7 200 €/an, lubrifiants/AdBlue 2 200 €/an
- Assurances et taxes 5 040 €/an
- Frais de structure 12 800 €/an

Détaillez les 8 postes et concluez sur la rentabilité par rapport à un prix de vente moyen de 1,38 €/km commercial avec 22 % de retour à vide.', NULL, 1, 'difficile', ARRAY['calcul','crt','rentabilite'], 'mft-2026-gotrm:bc03-01:qr:1', true, 'CALCUL DÉTAILLÉ DU CRT KM

POSTE 1 — AMORTISSEMENT
- Base amortissable : 95 000 - (25 % × 95 000) = 71 250 €
- Amortissement annuel : 71 250 / 6 = 11 875 €
- Coût km : 11 875 / 110 000 = 0,108 €/km

POSTE 2 — CARBURANT
- Consommation : 28 × 110 000 / 100 = 30 800 L/an
- Coût : 30 800 × 1,42 = 43 736 €/an
- Coût km : 43 736 / 110 000 = 0,398 €/km

POSTE 3 — CONDUCTEUR
- Coût employeur 47 400 €/an
- Heures de service 1 850 h
- Coût horaire : 47 400 / 1 850 = 25,62 €/h
- Vitesse moyenne (régional) ~ 65 km/h
- Coût km : 25,62 / 65 = 0,394 €/km
- Vérification cohérence : 110 000 km / 65 km/h = 1 692 h de conduite + 158 h administratives = ~ 1 850 h cohérent

POSTE 4 — ENTRETIEN ET PNEUMATIQUES
- Entretien 7 500 €/an, pneus 2 880 €/110 000 km
- Pneus = 2 880 €/an (coïncidence avec les km annuels)
- Total : 7 500 + 2 880 = 10 380 €/an
- Coût km : 10 380 / 110 000 = 0,094 €/km

POSTE 5 — PÉAGES
- 7 200 €/an
- Coût km : 7 200 / 110 000 = 0,065 €/km

POSTE 6 — ASSURANCES ET TAXES
- 5 040 €/an
- Coût km : 5 040 / 110 000 = 0,046 €/km

POSTE 7 — LUBRIFIANTS / FLUIDES
- 2 200 €/an
- Coût km : 2 200 / 110 000 = 0,020 €/km

POSTE 8 — FRAIS DE STRUCTURE
- 12 800 €/an
- Coût km : 12 800 / 110 000 = 0,116 €/km

SYNTHÈSE COÛTS

| Poste | Annuel | €/km | % |
|---|---|---|---|
| Amortissement | 11 875 € | 0,108 | 9 % |
| Carburant | 43 736 € | 0,398 | 32 % |
| Conducteur | 47 400 € | 0,431 | 35 % |
| Entretien et pneus | 10 380 € | 0,094 | 8 % |
| Péages | 7 200 € | 0,065 | 5 % |
| Assurances et taxes | 5 040 € | 0,046 | 4 % |
| Lubrifiants | 2 200 € | 0,020 | 2 % |
| Structure | 12 800 € | 0,116 | 9 % |

TOTAL COÛTS ANNUELS : 140 631 €
COÛT KM TOTAL : 140 631 / 110 000 = 1,279 €/km

ATTENTION : ICI ON A UTILISÉ LES KM TOTAUX, PAS LES KM COMMERCIAUX

CALCUL COÛT KM COMMERCIAL

Avec 22 % de retour à vide :
- Km commerciaux = 110 000 × (1 - 0,22) = 85 800 km/an
- Coût km commercial = 140 631 / 85 800 = 1,639 €/km commercial

ANALYSE DE RENTABILITÉ

Prix de vente moyen : 1,38 €/km commercial
Coût km commercial : 1,639 €/km commercial
ÉCART : -0,259 €/km commercial → DÉFICIT

Sur l''année :
- CA estimé : 85 800 × 1,38 = 118 404 €
- Coûts totaux : 140 631 €
- Marge nette : -22 227 €/an de PERTE

Le véhicule est en LIMITE de rentabilité MAJEURE à -18,8 % de marge nette.

DIAGNOSTIC

Causes principales :
1. Retour à vide à 22 % (cible 15 %) → +0,32 €/km commercial de surcoût
2. Prix de vente à 1,38 € insuffisant pour couvrir les coûts

LEVIERS D''AMÉLIORATION

LEVIER 1 — RÉDUIRE LE RETOUR À VIDE
- Cible : 22 % → 14 % (gagner 9 000 km commerciaux)
- Méthode : Teleroute, démarchage retours, partenariats
- Impact : 9 000 × 1,38 € = 12 420 €/an de CA additionnel
- Coût : 9 000 × 0,59 € (variable) = 5 310 € (variables additionnels)
- Bénéfice net : 12 420 - 5 310 = 7 110 €/an

LEVIER 2 — AUGMENTER LE PRIX DE VENTE
- Cible : 1,38 € → 1,55 €/km (+12 %)
- Méthode : revue tarifs, RPC active, déclassements concurrentiels
- Impact : 85 800 × 0,17 = 14 586 €/an

LEVIER 3 — RÉDUIRE LA CONSOMMATION
- Cible : 28 → 26 L/100 km (-7 %)
- Méthode : éco-conduite, pression pneus, maintenance préventive
- Impact : 110 000 × 2 × 1,42 / 100 = 3 124 €/an

LEVIER 4 — MUTUALISER LES FRAIS DE STRUCTURE
- Si l''entreprise se développe sans alourdir la structure
- Estimation : -10 % sur la part structure / véhicule
- Impact : 1 280 €/an

SCENARIO OPTIMISÉ

| Action | Impact annuel |
|---|---|
| Retour à vide -5 pts (5 000 km commerciaux gagnés) | +4 000 € |
| Prix de vente +8 % | +9 500 € |
| Consommation -5 % | -2 200 € |
| Structure mutualisée -10 % | +1 280 € |
| Total amélioration | +12 580 €/an |

Nouvelle marge : -22 227 + 12 580 = -9 647 €/an de perte (au lieu de -22 k€)

Pour atteindre l''équilibre, il faudrait pousser plus loin :
- Retour à vide -10 pts au total
- Prix +12 %
- Conso -10 %
- Structure -15 %

Cela donnerait : +25 000 €/an, soit +3 000 € de marge nette finale.

CONCLUSION

Ce véhicule, dans sa configuration actuelle, est en perte de 22 k€/an. Pour le rendre rentable :
1. Action immédiate sur le retour à vide (priorité 1)
2. Revue tarifaire avec les chargeurs (priorité 2)
3. Plan d''économies opérationnelles (éco-conduite, structure)

Si après 6 mois d''actions correctives le véhicule reste en perte significative, envisager :
- Reposition sur ligne plus rentable
- Vente / leasing pour libérer de la trésorerie
- Remplacement par un véhicule mieux dimensionné (porteur 12 t en distribution)

Cet exercice doit être fait par véhicule pour identifier ceux qui plombent les résultats.'),
  (v_formation, 'qr', 'Comparez économiquement l''achat, le crédit-bail et la LLD pour un porteur 19 t (acquisition 95 k€, durée 6 ans). Détaillez les avantages, inconvénients, coûts totaux, impacts fiscaux et bilanciels. Recommandation pour une PME 15 véhicules.', NULL, 1, 'difficile', ARRAY['achat','credit-bail','lld','comparaison'], 'mft-2026-gotrm:bc03-01:qr:2', true, 'COMPARAISON DÉTAILLÉE — PORTEUR 19 T SUR 6 ANS

OPTION 1 — ACHAT (CRÉDIT BANCAIRE 7 ANS, TAUX 5 %)

Modalités financières :
- Prix HT : 95 000 €
- Apport : 19 000 € (20 %)
- Crédit : 76 000 € à 5 % sur 7 ans
- Mensualité : ~ 1 280 €
- Total des intérêts : ~ 11 520 €

Coût total après 6 ans :
- Apport : 19 000 €
- Mensualités payées : 1 280 × 72 = 92 160 €
- Mensualités restantes (12 mois) : 12 × 1 280 = 15 360 €
- Total payé sur 6 ans : 19 000 + 92 160 = 111 160 €
- Reste à payer après 6 ans : 15 360 €
- Valeur résiduelle (revente) : 23 750 €

Coût net après 6 ans + revente : 111 160 + 15 360 - 23 750 = 102 770 €

Avantages :
- Propriété immédiate
- Amortissement déductible (linéaire 6 ans = 11 875 €/an + intérêts)
- Suramortissement 40 % si véhicule propre
- Possibilité de revente / location à autre usage
- Bilan : actif solide, image patrimoniale

Inconvénients :
- Apport 19 000 € engagé
- Capacité d''endettement réduite (76 k€ de crédit)
- Gestion administrative complète (entretien, pannes, etc.)
- Risque sur la valeur résiduelle

OPTION 2 — CRÉDIT-BAIL 6 ANS

Modalités financières :
- 1er loyer majoré : 9 500 €
- Loyers mensuels : 1 350 € × 71 = 95 850 €
- Option d''achat : 4 750 € (5 % de la valeur résiduelle)
- Total payé : 9 500 + 95 850 + 4 750 = 110 100 €

Si exercice de l''option d''achat :
- Coût total : 110 100 €
- Valeur du véhicule en propriété : 25 000 €
- Coût net : 85 100 €

Si non exercice :
- Coût total : 105 350 € (sans option)
- Valeur récupérée : 0 €
- Coût net : 105 350 €

Avantages :
- Loyers entièrement déductibles (charges 100 %)
- Pas d''engagement de trésorerie majeur
- Capacité d''endettement préservée
- Option d''achat en fin de période
- Avantage fiscal en charges

Inconvénients :
- Pas de propriété pendant 6 ans
- Propriété loueur (procédure en cas de défaillance)
- Coût souvent légèrement supérieur à l''achat
- Engagement contractuel sur 6 ans

OPTION 3 — LLD 4 ANS (RENOUVELABLE)

Modalités financières :
- Loyer mensuel : 2 250 € × 48 = 108 000 €
- Service entretien et pneus inclus (~ 6 500 €/an = 26 000 € sur 4 ans)
- Pas d''option d''achat

Coût net sur 4 ans : 108 000 €
Mais service inclus représente ~ 26 000 € de valeur, donc coût net sur l''équivalent achat : 82 000 €

Renouvellement à 4 ans pour autres 4 ans (108 000 € additionnels)

Coût total sur 6 ans (4 + 2/4 du second contrat) : 108 000 + 54 000 = 162 000 €

Avantages :
- Loyers déductibles
- Service inclus (entretien, pneus, assistance)
- Pas de gestion administrative
- Renouvellement régulier (parc moderne)
- Image (véhicules récents)

Inconvénients :
- Coût total plus élevé
- Pas de propriété finale
- Engagement contractuel
- Restrictions sur usage (km plafond, état du véhicule)

COMPARAISON SYNTHÉTIQUE (sur 6 ans, équivalent)

| Critère | Achat | Crédit-bail | LLD (×1,5) |
|---|---|---|---|
| Apport / 1er loyer | 19 000 € | 9 500 € | 0 € |
| Coût total payé | 126 520 € | 110 100 € | 162 000 € |
| Valeur résiduelle | 23 750 € | 25 000 € | 0 € |
| Coût net 6 ans | 102 770 € | 85 100 € * | 162 000 € |
| Service entretien inclus | NON | NON | OUI (~ 39 k€) |
| Capacité endettement | Mobilisée | Préservée | Préservée |
| Propriété finale | Oui | Possible | Non |

(* Avec option d''achat exercée et revente)

CHOIX SELON PROFIL ENTREPRISE

POUR UNE PME 15 VÉHICULES, RECOMMANDATION : MIX ÉQUILIBRÉ

Recommandation détaillée :

1. ACHAT (5 véhicules cœur)
- Pour les véhicules à fort kilométrage et vision long terme
- Bénéfice : amortissement avantageux, propriété
- Profil : porteurs longue distance, tracteurs

2. CRÉDIT-BAIL (5 véhicules complément)
- Pour les véhicules de remplacement progressif
- Bénéfice : flexibilité, charges 100 % déductibles
- Profil : porteurs régionaux, distribution moyenne

3. LLD (5 véhicules à renouveler souvent)
- Pour les utilitaires, voitures direction
- Bénéfice : simplicité, service inclus
- Profil : VUL, voitures direction, véhicules pédagogie

JUSTIFICATIONS

a. Diversification : optimise les leviers fiscaux et bilanciel
b. Flexibilité : adaptation à l''évolution du parc et des besoins
c. Préservation capacité d''endettement : disponible pour autres investissements (TMS, formation, expansion)
d. Optimisation du temps : LLD sur les utilitaires libère 10-15 % du temps administratif

PLAN BUDGÉTAIRE TYPE (renouvellement annuel d''environ 2 véhicules)

Année 1 :
- 1 achat (19 k€ apport)
- 1 crédit-bail (9,5 k€ 1er loyer majoré)
- Total trésorerie : 28 500 €

Année 2 :
- 1 LLD (0 €)
- 1 crédit-bail (9,5 k€)
- Total : 9 500 €

Sur 5 ans, l''entreprise renouvelle son parc avec une trésorerie modérée engagée (~ 80-100 k€ sur 5 ans), tout en optimisant la fiscalité.

CHIFFRAGE GLOBAL DU MIX (15 véhicules)

| Poste | Coût annuel total |
|---|---|
| Achat 5 véhicules (intérêts + amortissement) | 90 000 €/an |
| Crédit-bail 5 véhicules (loyers) | 95 000 €/an |
| LLD 5 véhicules (loyers tout inclus) | 110 000 €/an |
| Total | 295 000 €/an |

À comparer à un scénario tout-achat :
- 15 × 17 000 € = 255 000 €/an
- Mais mobilisation de trésorerie + capacité d''endettement plus élevée
- Et gestion entretien plus complexe

Conclusion : le mix est légèrement plus cher (~ 15 %), mais offre flexibilité, simplicité et préservation de la capacité d''endettement, ce qui en fait le choix gagnant pour une PME en croissance.'),
  (v_formation, 'qr', 'Construisez le dossier d''investissement complet pour un projet TMS de 80 000 € (achat + intégration + formation). Détaillez bénéfices attendus, ROI, risques et plan de mise en œuvre.', NULL, 1, 'difficile', ARRAY['dossier-investissement','roi','tms'], 'mft-2026-gotrm:bc03-01:qr:3', true, 'DOSSIER D''INVESTISSEMENT — PROJET TMS

1. SYNTHÈSE EXÉCUTIVE

Le présent projet vise à investir 80 000 € dans un nouveau Transport Management System (TMS) cloud pour une PME de 22 véhicules. Le projet s''inscrit dans une démarche de modernisation et d''optimisation opérationnelle. ROI attendu de 119 % la première année avec un payback inférieur à un an.

2. CONTEXTE ET MOTIVATION

Situation actuelle :
- Pilotage manuel des tournées (Excel)
- 3 exploitants gèrent 22 véhicules
- Génération CMR/LV manuelle
- Pas de tracking temps réel
- Reporting client en différé
- Erreurs fréquentes de planification (15-20 %)

Enjeux :
- Pression concurrentielle des transporteurs équipés
- Demandes de plus en plus exigeantes des chargeurs (tracking, ETA)
- Saturation des exploitants (refus de nouveaux clients)
- Erreurs documentaires (litiges)

Opportunité :
- Maturité des solutions cloud (sécurité, simplicité)
- Délai de mise en œuvre raisonnable (3-6 mois)
- Coûts maîtrisés via modèle SaaS

3. DESCRIPTION DE L''INVESTISSEMENT

Solution choisie : TMS cloud spécialisé transport (selon AO précédent)

Périmètre fonctionnel :
- Saisie commandes
- Planification automatique des tournées (algorithme VRP)
- Affectation véhicules / conducteurs
- Tracking temps réel via télématique
- Génération automatique CMR, LV, BL
- Reporting KPI mensuel
- Module facturation intégré

Composantes du coût :
- Licence + abonnement initial : 30 000 € (an 1)
- Intégration et paramétrage : 25 000 € (one-shot)
- Formation utilisateurs : 8 000 €
- Matériel complémentaire (smartphones conducteurs) : 5 000 €
- Réserve aléas (15 %) : 12 000 €
- Total : 80 000 €

Coûts récurrents années 2+ :
- Abonnement : 14 000 €/an
- Maintenance : 2 000 €/an
- Total annuel : 16 000 €

4. ANALYSE ÉCONOMIQUE

BÉNÉFICES ATTENDUS ANNUELS

a. Gain de productivité exploitation
- 3 exploitants × 10 h/sem économisées (sur 47 sem)
- 3 × 10 × 47 = 1 410 h économisées
- Coût horaire chargé exploitant : 35 €/h
- Bénéfice : 1 410 × 35 = 49 350 €/an

b. Réduction des erreurs documentaires
- 1 % d''erreurs sur 8 000 missions/an = 80 erreurs
- Coût moyen d''une erreur (litige) : 150 €
- Bénéfice : 80 × 150 = 12 000 €/an

c. Optimisation des tournées (retour à vide)
- 22 véhicules × 110 000 km/an = 2 420 000 km/an
- Réduction du retour à vide de 18 % à 15 % (-3 pts)
- Km commerciaux additionnels : 2 420 000 × 3 % = 72 600 km/an
- Marge brute additionnelle (à 0,55 €/km variable) : 0,80 €/km × 72 600 = 58 080 €
- (Conservatisme : prendre 50 % du potentiel) : 29 040 €/an

d. Augmentation de la capacité d''accepter de nouveaux clients
- Capacité +15 % grâce au gain de temps exploitation
- Estimation : 5 nouveaux clients × 35 k€/an de marge × 50 % = 87 500 €/an

e. Réduction des litiges client
- NPS amélioré, fidélisation accrue
- Estimation : 2 clients sauvés × 80 k€ LTV × 1/6 ans = 26 700 €/an

TOTAL BÉNÉFICES ANNUELS : 204 590 €

Hypothèses conservatrices :
- Bénéfice annuel net réaliste : 95 000 € (valeur centrale)
- Scénario optimiste : 150 000 €
- Scénario pessimiste : 50 000 €

CALCUL ROI

Hypothèse centrale (95 000 €/an net) :

| Indicateur | Valeur |
|---|---|
| Investissement initial | 80 000 € |
| Coûts récurrents annuels | 16 000 € |
| Bénéfice net annuel | 95 000 - 16 000 = 79 000 € |
| ROI simple | 79 000 / 80 000 = 99 % par an |
| Payback | 80 000 / 79 000 = 1,01 an |

Sur 5 ans :

| Année | Cash flow |
|---|---|
| 0 | -80 000 € |
| 1 | +79 000 € |
| 2 | +79 000 € |
| 3 | +79 000 € |
| 4 | +79 000 € |
| 5 | +79 000 € |

VAN à 5 % d''actualisation : ~ 262 000 €
TRI : ~ 95 %

ANALYSE DE SENSIBILITÉ

Que se passe-t-il si les bénéfices sont -30 % ? (scénario pessimiste 50 k€)
- ROI : 42 %
- Payback : 2,4 ans
- VAN à 5 ans : +85 000 €
→ Reste rentable

Que se passe-t-il si les coûts dépassent +30 % (104 k€ d''investissement) ?
- ROI : 76 %
- Payback : 1,3 an
- VAN à 5 ans : +236 000 €
→ Reste rentable

Que se passe-t-il si les deux scénarios pessimistes se cumulent ?
- ROI : 33 %
- Payback : 3,1 ans
- VAN à 5 ans : +60 000 €
→ Toujours rentable, mais plus risqué

5. ANALYSE DES RISQUES

| Risque | Probabilité | Impact | Mitigation |
|---|---|---|---|
| Dépassement budget intégration | Moyenne | Modéré | Forfait avec éditeur, pénalités |
| Adhésion équipes | Élevée | Fort | Plan de formation + champion projet |
| Bénéfices surestimés | Moyenne | Fort | Scénario pessimiste validé |
| Délais de mise en œuvre | Élevée | Modéré | Buffer 20 %, planning rigoureux |
| Bug logiciel ou incompatibilité | Faible | Modéré | Période de test, clauses de sortie |
| Cyber-attaque (cloud) | Faible | Très fort | Vérifier ISO 27001, hébergement EU |

6. ANALYSE STRATÉGIQUE

Alignement stratégique :
- Croissance prévue de 15 %/an = besoin de capacité opérationnelle accrue
- Évolution clients (chargeurs grands comptes exigent intégration)
- Différentiation concurrentielle
- Préparation à long terme (transition énergétique, ZFE, RSE)

Comparaison avec alternatives :
- Statu quo (Excel) : limite la croissance, perte concurrentielle progressive
- Embaucher 2 exploitants supplémentaires (110 k€/an) : ne résout pas l''absence de tracking, des erreurs documentaires
- Solution moins chère (Excel + macros) : limite fonctionnelle

Le TMS est donc l''option la plus stratégique.

7. PLAN DE MISE EN ŒUVRE

| Phase | Durée | Action |
|---|---|---|
| 1. Cadrage | M+0 à M+1 | Validation finale, contrat éditeur |
| 2. Setup et intégration | M+1 à M+3 | Paramétrage, connexions ERP, tests |
| 3. Formation utilisateurs | M+3 à M+4 | 4 sessions de 2 jours |
| 4. Déploiement progressif | M+4 à M+6 | Vague 1 (5 véhicules), vague 2 (10), vague 3 (22) |
| 5. Stabilisation | M+6 à M+9 | Optimisations, ajustements |
| 6. Mesure ROI | M+12 | Bilan complet année 1 |

Désignation d''un chef de projet (1/4 ETP pendant 9 mois)
Comité de pilotage mensuel pendant la mise en œuvre

8. CONCLUSION ET RECOMMANDATION

RECOMMANDATION : INVESTIR

Le projet TMS présente :
- Un ROI exceptionnel (99 % an 1)
- Un payback ultra-rapide (1 an)
- Des bénéfices stratégiques majeurs (croissance, différentiation, préparation transition)
- Une rentabilité qui se maintient même dans les scénarios pessimistes

La décision d''investir doit être prise sans délai pour :
- Capter les bénéfices annuels au plus vite
- Préparer la croissance prévue
- Maintenir la compétitivité face aux concurrents équipés

Validation requise du Conseil de Direction.

9. ANNEXES (non détaillées ici)

- Détails de l''AO TMS (3 candidats comparés)
- Bilans actuels des 22 véhicules (KPI, performances)
- Témoignages d''autres PME ayant déployé un TMS
- Devis détaillés des prestataires
- Analyse SWOT du projet
- Calculs financiers détaillés (Excel)

FIN DU DOSSIER'),
  (v_formation, 'qr', 'Une PME de 25 véhicules dispose de 250 000 € à investir. 4 projets concurrents :
A. Renouvellement 2 véhicules diesel : 190 k€, bénéfice annuel 35 k€
B. TMS + télématique : 80 k€, bénéfice 95 k€/an
C. 1 véhicule électrique avec subvention : 130 k€ net, bénéfice 25 k€/an + image
D. Atelier maintenance interne : 150 k€, bénéfice 30 k€/an

Comparez par ROI/Payback/VAN, choisissez et justifiez. Que faire avec le solde ?', NULL, 1, 'difficile', ARRAY['decision','arbitrage','multi-projets'], 'mft-2026-gotrm:bc03-01:qr:4', true, 'COMPARAISON DES 4 PROJETS

CALCULS PRÉLIMINAIRES

| Projet | Investissement | Bénéfice annuel | ROI simple | Payback |
|---|---|---|---|---|
| A. Véhicules diesel | 190 000 € | 35 000 € | 18,4 % | 5,4 ans |
| B. TMS + télématique | 80 000 € | 95 000 € | 118,8 % | 0,8 an |
| C. Véhicule électrique | 130 000 € | 25 000 € | 19,2 % | 5,2 ans |
| D. Atelier maintenance | 150 000 € | 30 000 € | 20,0 % | 5,0 ans |

CALCUL VAN (taux 5 %, durée 6 ans)

VAN = -Investissement + Σ Bénéfices annuels actualisés
Pour 6 ans à 5 % : facteur d''actualisation total = 5,076 (formule annuités)

Approximations :

A. VAN = -190 000 + 35 000 × 5,076 = -190 000 + 177 660 = **-12 340 €**
B. VAN = -80 000 + 95 000 × 5,076 = -80 000 + 482 220 = **+402 220 €**
C. VAN = -130 000 + 25 000 × 5,076 = -130 000 + 126 900 = **-3 100 €** (juste négative, mais effet image)
D. VAN = -150 000 + 30 000 × 5,076 = -150 000 + 152 280 = **+2 280 €** (juste positive)

ANALYSE STRATÉGIQUE

A. Renouvellement véhicules diesel
- Pour : maintien du parc, vision pragmatique
- Contre : VAN négative, ROI moyen, risque transition énergétique
- Verdict : marginalement rentable

B. TMS + télématique
- Pour : ROI exceptionnel, payback < 1 an, levier stratégique
- Contre : adhésion équipes à anticiper
- Verdict : EXCELLENT - PRIORITÉ ABSOLUE

C. Véhicule électrique
- Pour : positionnement avant-gardiste, marché ZFE, premium clients verts
- Contre : autonomie, infrastructures
- Verdict : intéressant pour image et positionnement, mais pas immédiatement rentable

D. Atelier maintenance interne
- Pour : indépendance, contrôle des coûts long terme
- Contre : besoin de compétences, investissement humain
- Verdict : structurel et stratégique, mais ROI lent

DÉCISION RECOMMANDÉE

PRIORITÉ 1 — PROJET B (TMS) : 80 k€

Décision immédiate, déploiement à démarrer dans les 30 jours.

Justifications :
- ROI le plus élevé (118 %)
- Payback ultra-rapide (10 mois)
- Bénéfice stratégique (capacité opérationnelle, différentiation)
- VAN très positive (+402 k€)
- Préparation aux autres projets (les exploitants équipés peuvent gérer un parc plus grand)

Solde après B : 250 - 80 = 170 k€

PRIORITÉ 2 — UN MIX A+C : 170 k€

Plutôt que de tout mettre sur A (véhicules diesel) ou C (électrique), un mix optimise :

Option recommandée : 1 véhicule diesel + 1 véhicule électrique

a. 1 véhicule diesel (95 k€) - capacité immédiate
b. 1 véhicule électrique avec subvention (75 k€ net après prorata) - positionnement transition

Total : 170 k€

ROI estimé du mix :
- Diesel : 17 500 €/an (la moitié du projet A)
- Électrique : 25 000 €/an + image
- Total : 42 500 €/an + valeur image
- Payback global : 170 / 42,5 = 4 ans

POURQUOI PAS LE PROJET D (ATELIER MAINTENANCE) ?

Plusieurs raisons :
- Investissement humain important (recrutement mécaniciens)
- Risque opérationnel (continuité du service véhicules existants)
- ROI moins immédiat
- À reporter à année 2 ou 3 quand l''entreprise sera mieux structurée

À CONSIDÉRER POUR PROCHAINS BUDGETS

Année 2 :
- Compléter le renouvellement véhicules diesel (1-2 supplémentaires)
- Démarrer atelier maintenance progressivement (location locaux 6 mois pour test)

Année 3 :
- Intensifier l''électrification (2-3 véhicules électriques de plus)
- Atelier maintenance complet selon retours

Année 4-5 :
- Investissements de croissance (acquisition concurrent, ouverture site)

CONCLUSION

DÉCISION FINALE :
- 80 k€ → TMS + télématique (priorité 1, lance immédiate)
- 95 k€ → 1 véhicule diesel pour capacité (priorité 2)
- 75 k€ → 1 véhicule électrique pour image et positionnement (priorité 2 bis)
- 0 k€ pour atelier maintenance (à reporter)

Total engagé : 250 k€ (= budget disponible)

Bénéfices attendus année 1 :
- TMS : 79 k€ (net après coûts récurrents)
- Diesel : 17,5 k€
- Électrique : 25 k€
- Total : 121,5 k€/an

Payback global du portefeuille : 250 / 121,5 = 2,1 ans

Cette stratégie diversifiée :
- Capte le ROI immédiat (TMS)
- Maintient la capacité opérationnelle (diesel)
- Positionne l''entreprise sur la transition énergétique (électrique)
- Préserve la capacité d''emprunt pour les futurs investissements stratégiques (atelier)

C''est une décision équilibrée qui combine performance économique et vision stratégique, alignée avec le positionnement durable d''une PME en croissance dans le secteur transport.'),
  (v_formation, 'qr', 'Calculez le coût km commercial actuel de votre flotte et proposez 5 leviers d''amélioration concrets, chiffrés, avec actions, échéances et impact attendu sur 12 mois.', NULL, 1, 'difficile', ARRAY['plan-action','leviers','roi-global'], 'mft-2026-gotrm:bc03-01:qr:5', true, 'CALCUL DU COÛT KM COMMERCIAL ACTUEL ET LEVIERS D''AMÉLIORATION

ÉTAPE 1 — CALCUL DU COÛT KM COMMERCIAL ACTUEL

Hypothèse de la flotte (PME 20 véhicules) :
- 12 porteurs 19 t cycle régional (110 000 km totaux/an)
- 5 tracteurs 44 t longue distance (130 000 km/an)
- 3 distribution 12 t urbains (45 000 km/an)
- Retour à vide moyen : 22 %

CALCUL PAR TYPE

A) Porteur 19 t (12 véhicules)
- Coût km total : 1,28 €/km
- Coût km commercial = 1,28 / (1 - 0,22) = 1,64 €/km commercial
- Total annuel : 12 × 110 000 × 1,28 = 1 689 600 €
- Km commerciaux : 12 × 110 000 × 0,78 = 1 029 600 km/an

B) Tracteur 44 t (5 véhicules)
- Coût km total : 1,42 €/km
- Coût km commercial = 1,42 / (1 - 0,15) = 1,67 €/km commercial (retour à vide moindre 15 %)
- Total annuel : 5 × 130 000 × 1,42 = 923 000 €
- Km commerciaux : 5 × 130 000 × 0,85 = 552 500 km/an

C) Distribution 12 t (3 véhicules)
- Coût km total : 1,52 €/km
- Coût km commercial = 1,52 / (1 - 0,30) = 2,17 €/km commercial (urbain souvent 30 %+ retour vide)
- Total annuel : 3 × 45 000 × 1,52 = 205 200 €
- Km commerciaux : 3 × 45 000 × 0,70 = 94 500 km/an

GLOBAL DE LA FLOTTE

| Indicateur | Valeur |
|---|---|
| Coûts annuels totaux | 1 689 600 + 923 000 + 205 200 = 2 817 800 € |
| Km commerciaux annuels | 1 029 600 + 552 500 + 94 500 = 1 676 600 km |
| **Coût km commercial moyen** | **2 817 800 / 1 676 600 = 1,68 €/km commercial** |

À comparer au prix de vente moyen : 1,55 €/km commercial → DÉFICIT moyen de 0,13 €/km commercial.

ÉTAPE 2 — 5 LEVIERS D''AMÉLIORATION

LEVIER 1 — RÉDUCTION DU RETOUR À VIDE

Action : abonnement Teleroute Premium + référent dédié + démarchage 30 chargeurs sur les top 10 trajets retour
Échéance : déploiement complet à M+3
Cible : retour à vide global 22 % → 15 %

Impact chiffré :
- Km commerciaux additionnels : 1 676 600 × 7 / 78 = 150 376 km/an gagnés en commercial
- Marge brute additionnelle : 150 376 × (1,55 - 0,55) = 150 376 × 1,00 = 150 376 €/an
- Coûts variables additionnels : 150 376 × 0,55 = 82 707 €/an
- Bénéfice net : 67 669 €/an
- Coût investissement : Teleroute 700 €/mois × 12 = 8 400 €/an + 0,3 ETP référent = 18 000 €/an
- Net annuel : 67 669 - 26 400 = 41 269 €/an

LEVIER 2 — ÉCO-CONDUITE GÉNÉRALISÉE

Action : formation tous conducteurs + télématique avec scoring + prime éco-conduite
Échéance : déploiement complet à M+6
Cible : consommation -8 %

Impact chiffré :
- Carburant économisé : 8 % × (12 × 110 000 × 0,28 + 5 × 130 000 × 0,32 + 3 × 45 000 × 0,25) = 8 % × (369 600 + 208 000 + 33 750) = 48 908 L/an
- À 1,42 €/L : 69 449 €/an d''économies
- Coût formation : 5 000 € + télématique 25 €/véhicule/mois × 20 × 12 = 6 000 € + primes 200 €/conducteur/an × 25 = 5 000 €
- Total coût : 16 000 €/an
- Bénéfice net : 53 449 €/an

LEVIER 3 — RENÉGOCIATION TARIFAIRE

Action : revue commerciale top 30 clients, application stricte RPC, déclassements sur clients non-rentables
Échéance : actions à M+1, effets visibles à M+6
Cible : prix moyen +6 %

Impact chiffré :
- CA additionnel : 1 676 600 × 1,55 × 6 % = 155 924 €/an
- Pas de coût additionnel
- Bénéfice net : 155 924 €/an

LEVIER 4 — OPTIMISATION ENTRETIEN ET PNEUMATIQUES

Action : passage maintenance préventive (60 % préventif vs 40 % curatif), pression pneus optimale, marque premium pneus
Échéance : M+3 à M+6
Cible : -15 % entretien et pneus

Impact chiffré :
- Économies entretien et pneus : 15 % × 20 × 10 380 = 31 140 €/an
- Investissement marque premium : +20 % × 20 × 2 880 = 11 520 €/an de surcoût
- Net : 31 140 - 11 520 = 19 620 €/an d''économies

LEVIER 5 — RÉDUCTION DES FRAIS DE STRUCTURE

Action : déploiement TMS pour gain productivité exploitation, regroupement de fonctions, négociation contrats fournisseurs
Échéance : M+6 à M+12
Cible : -10 % frais de structure

Impact chiffré :
- Économies : 10 % × 12 800 × 20 = 25 600 €/an
- Investissement TMS : 80 k€ one-shot, 16 k€/an récurrents
- Bénéfice net (sur 1 an, hors récup investissement) : 25 600 - 16 000 = 9 600 €/an
- ROI complet sur 6 ans : excellent (cf. dossier TMS)

SYNTHÈSE DES 5 LEVIERS

| Levier | Bénéfice net annuel | Investissement |
|---|---|---|
| 1. Retour à vide -7 pts | 41 269 € | 26 400 €/an |
| 2. Éco-conduite -8 % | 53 449 € | 16 000 €/an |
| 3. Renégociation prix +6 % | 155 924 € | 0 |
| 4. Maintenance préventive | 19 620 € | 0 (réinvestissement) |
| 5. Structure -10 % | 9 600 € | 96 000 € (TMS amortis 6 ans) |
| **TOTAL ANNUEL** | **279 862 €** | **138 400 € (+ 80 k€ one-shot)** |

NOUVEAU COÛT KM COMMERCIAL ATTENDU

Coûts actuels : 2 817 800 €/an
Économies : 279 862 €/an
Nouveaux coûts : 2 537 938 €/an

Km commerciaux additionnels (levier 1) : +150 376 km
Km commerciaux totaux : 1 676 600 + 150 376 = 1 826 976 km

NOUVEAU COÛT KM COMMERCIAL : 2 537 938 / 1 826 976 = **1,39 €/km commercial**

Réduction : 1,68 → 1,39 = -0,29 €/km commercial (-17 %)

À prix de vente constant (1,55 €/km commercial) :
- Marge brute par km commercial : 1,55 - 1,39 = 0,16 €/km
- Sur 1,83 M km commerciaux : 292 800 €/an de marge brute additionnelle (vs marge négative actuelle)

CALENDRIER DE DÉPLOIEMENT

| Mois | Actions activées |
|---|---|
| M+1 | Lancement renégociation tarifaire |
| M+2 | Souscription Teleroute, référent retour à vide |
| M+3 | Démarrage formation éco-conduite |
| M+4 | Maintenance préventive systématique |
| M+5 | Déploiement TMS (priorité 1) |
| M+6 | Bilan intermédiaire 1 |
| M+9 | Effets visibles tous leviers |
| M+12 | Bilan complet, ajustements |

FACTEURS DE RÉUSSITE

1. ENGAGEMENT DIRECTION : tous les leviers exigent un soutien fort
2. COMMUNICATION : informer les équipes (commerciaux, exploitants, conducteurs)
3. INDICATEURS PRÉCIS : mesurer mensuellement chaque KPI
4. AGILITÉ : ajuster en cours de route si écart
5. PERSÉVÉRANCE : certains leviers prennent 6-9 mois pour se déployer pleinement

ROI GLOBAL DU PLAN

Investissement total an 1 : 138 400 € + 80 000 € (TMS) = 218 400 €
Bénéfice annuel récurrent : 279 862 €
Payback : 218 400 / 279 862 = 0,78 an (9-10 mois)
ROI an 1 : 28 % (en raison des investissements concentrés)
ROI années suivantes : 200 %+ (récurrent net des investissements amortis)

Sur 5 ans, bénéfice cumulé : ~ 1,4 M€ pour ~ 220 k€ investis. Excellent ROI.

CONCLUSION

Ce plan d''amélioration multi-leviers transforme la flotte d''une situation déficitaire à une rentabilité saine et durable. Les 5 leviers se renforcent mutuellement (synergie) et offrent une marge de sécurité face aux aléas (variation carburant, pression tarifaire client).

La direction doit valider ce plan, allouer les ressources et nommer un porteur global. Les bénéfices attendus dépassent largement les investissements et positionnent l''entreprise pour une croissance future maîtrisée.');


  -- =================================================================
  -- QUIZZES
  -- =================================================================
  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_1, 'Quiz — Décomposition des coûts', 'gotrm-bc03-01-quiz-01', '8 postes, fixes vs variables, valeurs marché.', 70, NULL, false, 1)
  RETURNING id INTO v_quiz_1;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc03-01:qcm:1','mft-2026-gotrm:bc03-01:qcm:2','mft-2026-gotrm:bc03-01:qcm:3','mft-2026-gotrm:bc03-01:qcm:4','mft-2026-gotrm:bc03-01:qcm:5','mft-2026-gotrm:bc03-01:qcm:6','mft-2026-gotrm:bc03-01:qcm:24','mft-2026-gotrm:bc03-01:qcm:28');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_2, 'Quiz — Calcul du CRT', 'gotrm-bc03-01-quiz-02', 'Formule CRT, coefficients, retour à vide, prix de vente.', 70, NULL, false, 2)
  RETURNING id INTO v_quiz_2;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc03-01:qcm:7','mft-2026-gotrm:bc03-01:qcm:8','mft-2026-gotrm:bc03-01:qcm:9','mft-2026-gotrm:bc03-01:qcm:10','mft-2026-gotrm:bc03-01:qcm:11','mft-2026-gotrm:bc03-01:qcm:12');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_3, 'Quiz — Achat / leasing', 'gotrm-bc03-01-quiz-03', 'Achat, crédit-bail, LLD, fiscalité, bilan, suramortissement.', 70, NULL, false, 3)
  RETURNING id INTO v_quiz_3;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc03-01:qcm:13','mft-2026-gotrm:bc03-01:qcm:14','mft-2026-gotrm:bc03-01:qcm:15','mft-2026-gotrm:bc03-01:qcm:16','mft-2026-gotrm:bc03-01:qcm:21','mft-2026-gotrm:bc03-01:qcm:25','mft-2026-gotrm:bc03-01:qcm:26','mft-2026-gotrm:bc03-01:qcm:27');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_4, 'Quiz — ROI et investissements', 'gotrm-bc03-01-quiz-04', 'ROI, payback, VAN, TRI, dossier d''investissement.', 70, NULL, false, 4)
  RETURNING id INTO v_quiz_4;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc03-01:qcm:17','mft-2026-gotrm:bc03-01:qcm:18','mft-2026-gotrm:bc03-01:qcm:19','mft-2026-gotrm:bc03-01:qcm:20','mft-2026-gotrm:bc03-01:qcm:22','mft-2026-gotrm:bc03-01:qcm:23');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, NULL, 'Examen blanc — BC03-01 Coût de revient', 'gotrm-bc03-01-examen-blanc', '15 QCM en 30 min, seuil 50 %.', 50, 30, true, 5)
  RETURNING id INTO v_quiz_eb;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc03-01:qcm:1','mft-2026-gotrm:bc03-01:qcm:2','mft-2026-gotrm:bc03-01:qcm:3','mft-2026-gotrm:bc03-01:qcm:5','mft-2026-gotrm:bc03-01:qcm:7','mft-2026-gotrm:bc03-01:qcm:9','mft-2026-gotrm:bc03-01:qcm:11','mft-2026-gotrm:bc03-01:qcm:12','mft-2026-gotrm:bc03-01:qcm:13','mft-2026-gotrm:bc03-01:qcm:15','mft-2026-gotrm:bc03-01:qcm:17','mft-2026-gotrm:bc03-01:qcm:18','mft-2026-gotrm:bc03-01:qcm:21','mft-2026-gotrm:bc03-01:qcm:25','mft-2026-gotrm:bc03-01:qcm:28');

  RAISE NOTICE '✅ GOTRM BC03-01 v2 chargé : 4 leçons, 28 QCM, 5 QR, 5 quizzes (4 entraînement + 1 examen blanc).';
END
$bc03_01$;
