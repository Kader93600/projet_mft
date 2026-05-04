-- =====================================================================
-- MODULE D — ACTIVITÉ FINANCIÈRE (Capacité ≤ 3,5 T)
-- Version 2 (mai 2026) — refonte complète depuis PDF officiels.
--
-- Référentiel (décision du 2 avril 2012) : 5 QCM (10 pts) + 1 coût de
-- revient (30 pts) + 2 QR (10 pts) = 50 points sur 84.
-- Le plus gros coefficient de l'examen national.
--
-- ▸ 4 leçons (coût de revient / bilan & résultat / santé financière /
--   financement & fiscalité)
-- ▸ 35 QCM reformulés (préfixe mft-2026:moduleD:qcm:N)
-- ▸ 6 QR transport (max_score 5)
-- ▸ Quizzes par leçon + 1 examen blanc Module D
-- =====================================================================

DO $module_d_v2$
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
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'capacite-3-5t';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation capacite-3-5t introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc.'; END IF;

  DELETE FROM public.modules WHERE slug = 'capa-activite-financiere';

  INSERT INTO public.modules (
    title, slug, bloc_id, summary, difficulty, duration_min, "order"
  ) VALUES (
    'Module D — Activité financière',
    'capa-activite-financiere',
    v_bloc,
    'Calculer son coût de revient kilométrique, lire un bilan et un compte de résultat, mesurer la santé financière (SIG, FRNG, BFR, TN), choisir ses financements et maîtriser la fiscalité du transporteur.',
    'avance',
    220,
    40
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 40, true)
  ON CONFLICT DO NOTHING;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026:moduleD:%';

  -- =================================================================
  -- LEÇON 1 — Calculer son coût de revient
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Calculer son coût de revient kilométrique',
    'cout-de-revient',
    1, 70,
$lesson1$
# Calculer son coût de revient kilométrique

C'est **LA** matière la plus testée de l'examen (30 points sur 84). Maîtriser le coût de revient, c'est savoir **fixer un prix viable**, **négocier avec ses clients** et **piloter sa rentabilité**. C'est le métier-cœur du transporteur indépendant.

> 🎯 **Objectifs de la leçon**
>
> - Distinguer **charges variables**, **charges de conduite**, **charges fixes**, **charges de structure**.
> - Calculer un coût de revient en formules **binôme** et **trinôme**.
> - Maîtriser les méthodes d'**amortissement** (linéaire et dégressif).
> - Calculer une **marge commerciale** et un **seuil de rentabilité**.

---

## 1. La structure du coût de revient

Le coût de revient se décompose en **4 catégories** :

| Catégorie | Définition | Exemples |
|---|---|---|
| **Charges variables** | Proportionnelles aux kilomètres | Carburant, pneus, entretien, péages |
| **Charges de conduite** | Frais du personnel roulant | Salaires, primes, charges sociales, frais de route |
| **Charges fixes** | Affectables à un véhicule donné | Amortissement, assurance, taxes |
| **Charges de structure** | Frais fixes indifférenciés de l'entreprise | Loyer locaux, comptable, secrétariat |

### 1.1 Les ratios (unités d'œuvre)

| Ratio | Calcul | Utilité |
|---|---|---|
| **Terme variable kilométrique** | Charges variables ÷ km parcourus | Coût par km roulé |
| **Terme horaire** | Charges de conduite ÷ heures travaillées | Coût horaire chauffeur |
| **Terme journalier** | Charges fixes ÷ jours ouvrés | Coût d'immobilisation par jour |
| **Terme total kilométrique** | Coût de revient ÷ km parcourus | Prix de vente plancher |

> 📌 **Formule trinôme**
>
> Le **trinôme** combine les 3 termes : kilométrique + horaire + journalier. Il permet d'établir un coût de revient pour des trajets de durée et distance variables.

> 📌 **Formule binôme**
>
> Le **binôme** combine seulement 2 termes (souvent kilométrique + journalier). Plus simple mais moins précis.

---

## 2. Les charges variables

Engagées **uniquement quand le véhicule roule**. Elles dépendent du kilométrage et de l'activité.

### 2.1 Le carburant

Variations selon :
- Type de véhicule (thermique, hybride, électrique)
- Utilisation (urbaine, longue distance, express)
- Poids transporté
- Conduite du chauffeur (éco-conduite)
- Politique d'approvisionnement (cuve interne vs station)

> 🚛 **Exemple**
>
> Un VUL diesel consomme 8,5 l/100 km en mixte. À 1,75 €/l, le coût carburant kilométrique = **0,149 €/km**. Sur 30 000 km/an = **4 463 €**.

### 2.2 Les pneumatiques

> **Coût km = (Prix d'un pneu × Nombre de pneus) ÷ Durée de vie moyenne en km**

Exemple : 4 pneus à 200 € avec une durée de vie de 60 000 km → 4 × 200 / 60 000 = **0,013 €/km**.

### 2.3 L'entretien et la réparation

| Type | Caractéristique |
|---|---|
| **Entretien systématique** | Vidanges, graissages — prévisible (périodicité constructeur) |
| **Réparations / usure** | Aléatoires — à provisionner via une moyenne historique |

### 2.4 Les péages

Dépend de l'activité (autoroute vs urbain) et de la politique de l'entreprise.

---

## 3. Les charges de conduite

Frais du personnel roulant. Composantes :

- **Salaire de base** (au moins SMIC ou conventionnel)
- **Heures supplémentaires**
- **Primes** (de panier, de route, de qualité)
- **Charges sociales** (≈ 42 % du brut côté employeur)
- **Frais de route** (repas, hébergement)
- **Remplaçant** pour le mois de congé

> ⚠️ **Important examen**
>
> Les frais de conduite sont **comptabilisés à part** des charges fixes même s'ils sont fixes. Cette distinction permet de comparer plus facilement avec une location de véhicule **avec chauffeur**.

---

## 4. Les charges fixes

Supportées **indépendamment** de l'activité du véhicule.

### 4.1 Coût de détention : l'amortissement

> **Définition** : terme comptable désignant la **dépréciation** d'un bien immobilisé due à l'usure ou à l'obsolescence.

#### Durée d'amortissement standard

| Bien | Durée standard |
|---|---|
| Immobilisations incorporelles | **5 ans** |
| Véhicules | **4 à 5 ans** |
| Mobilier et matériel de bureau | 5 à 10 ans |
| Ordinateur portable | 3 ans |
| Installation technique | 5 à 10 ans |

### 4.2 Amortissement linéaire

> Dépréciation **équivalente** chaque année.

**Formule** :
```
Taux = 1 / Durée de vie en années
Amortissement = Base × Taux
```

> 🚛 **Exemple**
>
> VUL acheté 30 000 € HT, durée 5 ans.
> - Taux = 1 / 5 = **20 %**
> - Annuité = 30 000 × 20 % = **6 000 €/an**
> - À retenir : si l'achat se fait en cours d'année, on applique un **prorata temporis** sur 360 jours (1 mois = 30 jours).

### 4.3 Amortissement dégressif

> Annuités plus **élevées en début** de vie. Avantage fiscal.

**Formule** :
```
Taux dégressif = Taux linéaire × Coefficient fiscal
Annuité = Taux dégressif × Valeur résiduelle
```

#### Coefficient fiscal selon la durée

| Durée d'amortissement | Coefficient |
|---|---|
| **3 à 4 ans** | **1,25** |
| **5 à 6 ans** | **1,75** |
| **Plus de 6 ans** | **2,25** |

#### Conditions

- Bien **neuf** (et véhicule de **plus de 2 t de charge utile**)
- Durée minimum : **3 ans**

> 📌 **Bascule au linéaire**
>
> Quand l'amortissement dégressif annuel devient inférieur à (Valeur résiduelle / Années restantes), on bascule en méthode linéaire.

### 4.4 Frais financiers

Modes de financement à rémunérer :
- Fonds propres
- Emprunt bancaire
- Crédit-bail
- Location financière

Les frais financiers sont **répartis linéairement** sur toute la période d'exploitation.

### 4.5 Assurances et taxes

| Assurance / Taxe | Détail |
|---|---|
| RC véhicule | Obligatoire (article L. 211-1 C. assur.) |
| Assurance marchandises | Souscrite par le donneur d'ordre |
| Contrôle technique | Annuel pour VUL |
| Taxe parafiscale formation pro | Spécifique aux transporteurs |
| TVS (Taxe sur véhicules de société) | Selon types de véhicules |

### 4.6 Calcul du coût journalier

> **Coût journalier = (Amortissement + Frais financiers + Taxes + Assurances) ÷ Jours d'utilisation prévus**

**Exemple** : pour un tracteur 40 t :
- Amortissement : 9 461,60 €
- Frais financiers : 1 756,52 €
- Taxes : 533,57 €
- Assurances : 2 423,94 €
- **Total : 14 175,62 €**
- Sur 230 jours d'exploitation prévue → **61,63 €/jour**

---

## 5. Les charges de structure

Frais administratifs **indifférenciés** : loyer locaux, comptabilité, secrétariat, téléphonie, carte essence flotte, frais bancaires.

### 5.1 Clés de répartition pour la flotte

- Tonne-kilométrique
- Tonnage
- Kilométrage
- Pourcentage du CA

---

## 6. Calculer un prix de vente : la marge commerciale

> **Marge commerciale = Chiffre d'affaires HT - Coût de revient HT**

### 6.1 Taux de marge vs taux de marque

| Indicateur | Formule | Sur quoi ? |
|---|---|---|
| **Taux de marge** | (Marge HT / Coût de revient HT) × 100 | Sur le **coût** |
| **Taux de marque** | (Marge HT / Prix de vente HT) × 100 | Sur le **prix de vente** |

### 6.2 Exemple

Vous facturez 120 € HT une course qui vous coûte 80 € HT.
- Marge = 120 - 80 = **40 €**
- Taux de marge = (40 / 80) × 100 = **50 %**
- Taux de marque = (40 / 120) × 100 = **33,3 %**

> 💡 **Marge nette**
>
> **Marge nette = (Bénéfice net / CA) × 100**. Tient compte de toutes les charges, y compris fiscales et financières.

---

## 7. Le seuil de rentabilité

> **Niveau de chiffre d'affaires HT à atteindre pour obtenir un résultat nul.**

### 7.1 Méthode 1 : marge sur coût variable

```
MSCV (par km) = Prix de vente / km - Coût variable / km

Seuil en km = Total des coûts fixes ÷ MSCV par km
```

### 7.2 Méthode 2 : coefficient de rentabilité

```
Coefficient = Total des coûts fixes ÷ (CA - Charges variables)

Seuil en km = km × Coefficient
Seuil en CA = CA × Coefficient
```

### 7.3 Le point mort

> **Point mort** : durée nécessaire (en jours) pour atteindre le seuil de rentabilité.

```
Point mort = (Seuil de rentabilité × 360) ÷ Chiffre d'affaires annuel
```

> 🚛 **Cas pratique**
>
> CA prévisionnel : 90 000 €. Seuil de rentabilité : 60 000 €.
> Point mort = (60 000 × 360) / 90 000 = **240 jours** → l'entreprise atteint l'équilibre vers le 240e jour de son exercice.

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| 4 catégories de charges | Variables / Conduite / Fixes / Structure |
| Formule trinôme | Terme kilométrique + horaire + journalier |
| Durée standard amortissement véhicule | **4-5 ans** |
| Taux d'amortissement linéaire 5 ans | **20 % / an** (1/5) |
| Coefficient dégressif 5-6 ans | **1,75** |
| Bien éligible au dégressif (transport) | Véhicule **neuf de + 2 t de charge utile** |
| Marge commerciale | CA HT - Coût de revient HT |
| Taux de marge | Marge / Coût de revient |
| Taux de marque | Marge / Prix de vente |
| Seuil de rentabilité | Niveau de CA où résultat = 0 |
| Point mort | Date (en jours) à laquelle on atteint le seuil |
$lesson1$,
'4 catégories de charges, formules binôme/trinôme, amortissement linéaire (taux = 1/durée) et dégressif (coefficient 1,25 / 1,75 / 2,25), marge commerciale et seuil de rentabilité.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Lire un bilan et un compte de résultat
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Lire un bilan et un compte de résultat',
    'bilan-compte-resultat',
    2, 50,
$lesson2$
# Lire un bilan et un compte de résultat

Ces deux documents sont **les "radiographies" financières de votre entreprise**. Le **bilan** photographie le patrimoine à un instant T. Le **compte de résultat** mesure la performance sur une période. Vous devez savoir les lire pour piloter, et c'est testé à l'examen.

> 🎯 **Objectifs de la leçon**
>
> - Distinguer **bilan** (patrimoine à date) et **compte de résultat** (performance sur 12 mois).
> - Identifier les composantes de l'**actif** et du **passif**.
> - Lire les **charges** et **produits** par catégorie.
> - Connaître les **documents comptables obligatoires**.

---

## 1. Les obligations comptables

### 1.1 Documents comptables obligatoires (PCG)

| Document | Rôle |
|---|---|
| **Livre-journal** | Liste **chronologique** de toutes les transactions |
| **Grand livre** | Reprend le livre-journal classé **par compte** |
| **Livre d'inventaire** | Liste actifs / passifs (non obligatoire depuis 1er janvier 2016, mais utile au bilan) |

### 1.2 Documents de synthèse (annuels)

À la clôture de l'exercice, l'entreprise produit ses **comptes annuels** :

- **Compte de résultat**
- **Bilan**
- **Annexes** (méthodes comptables, événements significatifs)

> 📌 **Exemption**
>
> Les **personnes physiques en micro-entreprise** sont exemptées de comptes annuels (juste un livre des recettes pour les BIC, journal des recettes pour les BNC).

---

## 2. Le bilan

> Photographie du **patrimoine** de l'entreprise à un instant T (généralement 31/12).

### 2.1 Structure : actif vs passif

| ACTIF (ce que possède l'entreprise) | PASSIF (comment c'est financé) |
|---|---|
| **Immobilisations** (véhicules, locaux, matériel) | **Capitaux propres** (capital, réserves, résultat) |
| **Actif circulant** (stocks, créances clients) | **Dettes financières** (emprunts bancaires) |
| **Trésorerie** (caisse, banque, placements court terme) | **Dettes d'exploitation** (fournisseurs, État, salaires) |

> ⚠️ **Règle fondamentale**
>
> **TOTAL ACTIF = TOTAL PASSIF**. Toujours, sans exception. Si ça ne tombe pas, c'est qu'il y a une erreur comptable.

### 2.2 L'actif : 3 grandes catégories

| Catégorie | Définition | Exemples transport |
|---|---|---|
| **Actif immobilisé** | Biens durables (> 1 an) | VUL, locaux, logiciels, fonds de commerce |
| **Actif circulant** | Court terme (< 1 an) | Stocks de pneus, factures clients en attente |
| **Trésorerie** | Disponibilités | Compte bancaire, caisse, livret |

### 2.3 Le passif : 3 grandes catégories

| Catégorie | Définition | Exemples |
|---|---|---|
| **Capitaux propres** | Argent des associés + résultats accumulés | Capital social, réserves, report à nouveau, bénéfice |
| **Dettes financières** | Emprunts moyen / long terme | Crédit bancaire VUL, leasing |
| **Dettes d'exploitation** | Court terme | Fournisseurs, charges sociales, TVA à payer |

> 💡 **Astuce de lecture**
>
> Plus les **capitaux propres** sont importants par rapport aux dettes, plus l'entreprise est **solide**. C'est ce qu'on appelle l'**autonomie financière**.

---

## 3. Le compte de résultat

> Mesure la **performance** de l'entreprise sur une **période** (généralement 12 mois).

### 3.1 Logique : Produits - Charges = Résultat

```
PRODUITS (ce que l'entreprise gagne)
  - CHARGES (ce qu'elle dépense)
  = RÉSULTAT NET (bénéfice ou perte)
```

### 3.2 Les 3 catégories de charges et produits

| Catégorie | Charges | Produits |
|---|---|---|
| **Exploitation** | Carburant, salaires, loyers, achats | CA, prestations, subventions |
| **Financière** | Intérêts d'emprunt, agios, escompte client | Intérêts placements, escompte fournisseur |
| **Exceptionnelle** | Pénalités, amendes, valeur nette comptable cessions | Subventions exceptionnelles, prix de cession d'immobilisations |

### 3.3 Cascade des résultats

| Niveau | Calcul |
|---|---|
| **Résultat d'exploitation** | Produits d'exploitation - Charges d'exploitation |
| **Résultat financier** | Produits financiers - Charges financières |
| **Résultat courant avant impôt** | Résultat exploitation + Résultat financier |
| **Résultat exceptionnel** | Produits exceptionnels - Charges exceptionnelles |
| **Résultat net** | Résultat courant + Résultat exceptionnel - Impôts |

> 🚛 **Cas pratique**
>
> Une SARL de transport :
> - CA : 180 000 €
> - Achats (carburant, pneus, entretien) : 60 000 €
> - Salaires + charges : 70 000 €
> - Loyers + frais administratifs : 15 000 €
> - **Résultat d'exploitation = 180 000 - 60 000 - 70 000 - 15 000 = 35 000 €**
> - Intérêts emprunt : 4 000 € → **Résultat financier = -4 000 €**
> - **Résultat courant avant impôt = 31 000 €**
> - IS (15 % jusqu'à 42 500 €) : 4 650 €
> - **Résultat net = 26 350 €**

---

## 4. Le compte de résultat différentiel (analytique)

Une approche **analytique** pour mesurer la rentabilité par activité.

| Élément | Détail |
|---|---|
| Chiffre d'affaires | Toutes les ventes / prestations |
| - **Charges variables** | Carburant, pneus, péages... |
| **= MSCV** (Marge sur coût variable) | |
| - **Charges fixes** | Loyer, salaires, amortissements |
| **= Résultat** | |

> 💡 **Utilité**
>
> Permet de calculer rapidement la **MSCV unitaire** et le **seuil de rentabilité** (cf. Leçon 1).

---

## 5. Charges calculées : amortissements et provisions

### 5.1 Amortissement (rappel Leçon 1)

L'amortissement est une **charge calculée** (pas un décaissement) qui apparaît au compte de résultat (« Dotations aux amortissements ») et qui s'accumule au bilan (« Amortissements cumulés » à l'actif, en déduction de la valeur brute).

### 5.2 Les provisions

> **Définition** : réserve financière constituée pour faire face à des **risques ou charges futurs identifiés mais non certains**.

| Type de provision | Exemple |
|---|---|
| **Provision pour clients douteux** | Risque d'impayé sur des factures spécifiques |
| **Provision pour litige** | Procès en cours dont l'issue est incertaine |
| **Provision pour gros entretien** | Révision majeure d'un véhicule à venir |
| **Provision pour retraite** | Engagements vis-à-vis des salariés |

> ⚠️ **Différence amortissement / provision**
>
> | Critère | Amortissement | Provision |
> |---|---|---|
> | Nature | Constatation d'une **perte de valeur certaine** | Constatation d'un **risque futur incertain** |
> | Bien concerné | Immobilisations (corporelles, incorporelles) | Tous types d'éléments |
> | Réversibilité | Définitif | **Réversible** : peut être reprise si le risque ne se réalise pas |

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| Bilan | **Photographie** du patrimoine à un instant T |
| Compte de résultat | **Performance** sur une période (12 mois) |
| ACTIF = | Immobilisations + Actif circulant + Trésorerie |
| PASSIF = | Capitaux propres + Dettes financières + Dettes d'exploitation |
| Règle fondamentale | TOTAL ACTIF = TOTAL PASSIF |
| 3 catégories de charges/produits | Exploitation, Financière, Exceptionnelle |
| Résultat courant avant impôt | Résultat d'exploitation + Résultat financier |
| Document chronologique | **Livre-journal** |
| Document classé par compte | **Grand livre** |
| Provision | Réserve pour risque **incertain mais probable** |
| Amortissement | Constatation d'une **perte de valeur certaine** |
$lesson2$,
'Bilan (actif/passif), compte de résultat (3 catégories de charges/produits), cascade des résultats, amortissements et provisions.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Mesurer la santé financière
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Mesurer la santé financière : SIG, FRNG, BFR, TN',
    'sante-financiere',
    3, 50,
$lesson3$
# Mesurer la santé financière : SIG, FRNG, BFR, TN

Avoir un bénéfice ne suffit pas. Il faut mesurer **comment l'entreprise crée de la valeur** (SIG) et **si elle a la trésorerie pour fonctionner** (FRNG, BFR, TN). Ce sont les indicateurs que regarde votre banquier, votre OPCO et l'examinateur.

> 🎯 **Objectifs de la leçon**
>
> - Calculer les **5 SIG** essentiels (VA, EBE, RE, RCAI, CAF).
> - Maîtriser le triangle **FRNG / BFR / TN**.
> - Comprendre la relation **TN = FRNG - BFR**.
> - Interpréter ces indicateurs pour piloter.

---

## 1. Les Soldes Intermédiaires de Gestion (SIG)

> Les SIG sont des **paliers** dans le compte de résultat qui mesurent la **création de valeur** à chaque étape de l'activité.

### 1.1 Les 5 SIG essentiels (du plus brut au plus net)

| # | SIG | Formule | Mesure |
|---|---|---|---|
| 1 | **Valeur ajoutée (VA)** | Production - Consommations externes | Richesse créée par l'entreprise |
| 2 | **Excédent brut d'exploitation (EBE)** | VA + Subventions - Impôts/Taxes - Charges de personnel | Performance avant amortissements et financement |
| 3 | **Résultat d'exploitation (RE)** | EBE - Dotations aux amortissements et provisions + Reprises | Performance opérationnelle nette |
| 4 | **Résultat courant avant impôt (RCAI)** | RE + Résultat financier | Performance avant éléments exceptionnels et IS |
| 5 | **Capacité d'autofinancement (CAF)** | EBE + autres produits encaissables - autres charges décaissables | Cash réellement généré par l'activité |

### 1.2 Détail des SIG

#### Valeur ajoutée (VA)

> Mesure la **richesse créée**. C'est ce qui sera **distribué aux parties prenantes** : salariés, État, banques, actionnaires, entreprise (autofinancement).

```
VA = Production de l'exercice
   - Achats et consommations en provenance des tiers
```

> 🚛 **Exemple transport**
>
> CA : 180 000 €. Achats carburant + entretien + péages : 50 000 €.
> **VA = 130 000 €**.

#### Excédent brut d'exploitation (EBE)

> Mesure la **performance économique pure** avant choix de financement et amortissements.

```
EBE = VA + Subventions d'exploitation
    - Impôts, taxes et versements assimilés
    - Charges de personnel
```

> 💡 **Indicateur favori des analystes**
>
> L'EBE permet de comparer des entreprises **indépendamment** de leur structure financière (peu importe qu'elles soient endettées ou pas) et de leur politique d'amortissement (méthode linéaire vs dégressive).

#### Capacité d'autofinancement (CAF)

> Mesure le **cash réel** que l'activité dégage.

```
CAF = EBE
    + Autres produits encaissables (financiers + exceptionnels)
    - Autres charges décaissables
    - Participation des salariés
    - Impôt sur les bénéfices
```

> ⚠️ **CAF ≠ Résultat net**
>
> Le résultat net inclut des **charges calculées** (amortissements, provisions) qui **ne sont pas décaissées**. La CAF les exclut → meilleur indicateur de la **vraie capacité de financement**.

---

## 2. Le triangle FRNG / BFR / TN

> Les **3 indicateurs** qui mesurent l'équilibre financier à partir du **bilan**.

### 2.1 Fonds de roulement net global (FRNG)

> **Capacité de l'entreprise à financer son cycle d'exploitation** avec ses ressources stables.

```
FRNG = Capitaux permanents - Actif immobilisé net

  où Capitaux permanents = Capitaux propres + Dettes financières long terme
```

| Cas | Lecture |
|---|---|
| **FRNG positif** | Les ressources stables financent les immobilisations + un excédent disponible pour le cycle d'exploitation. **Bon signal**. |
| **FRNG négatif** | Les ressources stables ne suffisent pas : l'entreprise utilise du court terme pour financer du long terme. **Risqué**. |

### 2.2 Besoin en fonds de roulement (BFR)

> **Besoin de financement né du décalage** entre encaissements (clients) et décaissements (fournisseurs, salaires, charges).

```
BFR = (Stocks + Créances clients + Autres créances)
    - (Dettes fournisseurs + Dettes fiscales et sociales)
```

| Cas | Lecture |
|---|---|
| **BFR positif** | Vous avancez de l'argent au quotidien : vous payez vos fournisseurs avant d'encaisser vos clients |
| **BFR négatif** | Vos clients vous paient avant que vous payiez vos fournisseurs (rare en transport, fréquent en grande distribution) |

> 🚛 **BFR typique du transport**
>
> Le transporteur paie ses charges (carburant, pneus, salaires) **immédiatement** mais encaisse ses factures clients **30-60 jours plus tard**. BFR généralement **positif**, parfois lourd.

### 2.3 Trésorerie nette (TN)

> **Cash disponible** après avoir financé immobilisations et BFR.

```
TN = FRNG - BFR

ou

TN = Disponibilités - Concours bancaires courants (découverts)
```

| Cas | Lecture |
|---|---|
| **TN positive** | Vous avez du cash en banque, l'entreprise est saine |
| **TN négative** | Vous êtes en découvert ou en facilité de caisse, situation à risque |

### 2.4 La relation fondamentale

> **TN = FRNG - BFR**

#### 4 situations classiques

| FRNG | BFR | TN | Lecture |
|---|---|---|---|
| **+** | **+** | **+** | FRNG > BFR : entreprise saine, cash disponible |
| **+** | **+** | **-** | FRNG insuffisant : besoin de renforcer le haut de bilan |
| **+** | **-** | **+** | Idéale : ressources stables ET clients qui paient avant |
| **-** | **-** | **+** | Cas particulier (grande distrib) : BFR négatif compense FRNG négatif |

> 🚛 **Exemple transport**
>
> Bilan d'une SARL :
> - Capitaux permanents : 80 000 € | Immobilisations : 50 000 € → **FRNG = 30 000 €**
> - Créances clients : 40 000 € + Dettes fournisseurs : 25 000 € → **BFR = 15 000 €**
> - **TN = 30 000 - 15 000 = 15 000 €** (positive : entreprise saine)

---

## 3. Diagnostic : que faire quand TN est négative ?

### 3.1 Augmenter le FRNG

| Levier | Action |
|---|---|
| **Augmenter capitaux propres** | Augmentation de capital, comptes courants associés bloqués |
| **Augmenter dettes long terme** | Crédit moyen / long terme bancaire |
| **Réduire immobilisations** | Cession d'actifs non productifs, leasing au lieu d'achat |

### 3.2 Réduire le BFR

| Levier | Action |
|---|---|
| **Accélérer encaissements clients** | Délais raccourcis, escompte pour paiement comptant, affacturage |
| **Allonger délais fournisseurs** | Négocier 30 → 45 → 60 jours fin de mois |
| **Réduire stocks** | Pneus, pièces : juste-à-temps |

### 3.3 Solutions de court terme (palliatives)

- Découvert autorisé (cher mais immédiat)
- Loi Dailly / cession de créances
- Affacturage
- Mobilisation de créances Bpifrance

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| Mesure la richesse créée | **Valeur ajoutée (VA)** |
| Performance avant amortissements | **EBE** |
| Cash réellement dégagé par l'activité | **CAF** |
| FRNG | Capitaux permanents - Actif immobilisé |
| BFR | (Stocks + Créances) - (Dettes fournisseurs + dettes fiscales) |
| TN | **FRNG - BFR** (ou Disponibilités - Découverts) |
| FRNG positif | Bon signal : ressources stables couvrent les emplois stables |
| BFR positif transport | Normal : on paie avant d'encaisser |
| TN négative | Découvert ou facilité de caisse |
| Solution structurelle si TN négative | Augmenter FRNG ou réduire BFR |
$lesson3$,
'5 SIG (VA, EBE, RE, RCAI, CAF), triangle FRNG/BFR/TN, diagnostic financier et leviers d''action.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Financer et fiscaliser son entreprise
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Financer et fiscaliser son entreprise',
    'financement-fiscalite',
    4, 50,
$lesson4$
# Financer et fiscaliser son entreprise

Comment financer un nouveau VUL ? Comment payer moins d'impôt légalement ? Quelle TVA appliquer en transport intracommunautaire ? Cette leçon couvre les fondamentaux **financement + fiscalité**.

> 🎯 **Objectifs de la leçon**
>
> - Construire un **plan de financement** prévisionnel.
> - Comparer les **sources de financement** (fonds propres, emprunt, leasing).
> - Distinguer **IR** et **IS**, et leurs barèmes.
> - Maîtriser le mécanisme de la **TVA**.
> - Connaître les **taxes** propres au transport.

---

## 1. Le plan de financement

> Tableau prévisionnel qui équilibre les **besoins durables** de l'entreprise avec les **ressources stables** disponibles.

### 1.1 Les besoins durables

- **Investissements** : véhicules, locaux, outillage
- **Variation du BFR** : besoin supplémentaire pour financer le cycle
- **Frais d'établissement** : création, frais de notaire, recherche

### 1.2 Les ressources stables

- **Capitaux propres** : capital, augmentation de capital, comptes courants associés
- **Emprunts moyen / long terme**
- **Capacité d'autofinancement (CAF)**
- **Subventions d'investissement**
- **Cessions d'actifs**

### 1.3 Règle d'équilibre

> **Total ressources ≥ Total besoins**

À 5 ans typiquement, sur des projections cohérentes avec votre business plan.

---

## 2. Les 5 sources de financement

| Source | Coût | Durée | Avantage | Inconvénient |
|---|---|---|---|---|
| **Fonds propres** | Coût d'opportunité | Permanent | Pas de remboursement, autonomie | Disponibilité limitée |
| **Emprunt bancaire** | Taux d'intérêt + frais | 3 à 7 ans (matériel) | Conserve la propriété | Garanties, endettement |
| **Crédit-bail (LOA)** | Loyer mensuel + option | 3 à 5 ans | Pas d'apport, levée d'option finale | Coût total élevé, pas immobilisé au bilan |
| **Location longue durée (LLD)** | Loyer mensuel | 2 à 5 ans | Aucun apport, services inclus | Pas de propriété, kilométrage capé |
| **Aides publiques** | Variable | Variable | Non remboursable parfois | Dossier lourd |

### 2.1 Crédit-bail vs LLD

| Critère | Crédit-bail (LOA) | Location longue durée (LLD) |
|---|---|---|
| Option d'achat finale | **Oui** (valeur résiduelle) | **Non** |
| Inscription au bilan | Hors bilan (loueur propriétaire) | Hors bilan |
| Services associés | Optionnels | Inclus (entretien, assurance, pneus) |
| Cible typique | TPE qui veut acquérir à terme | TPE qui veut maîtriser ses coûts |

### 2.2 Tableau d'amortissement d'emprunt

> Détaille la **répartition entre intérêts et capital** sur la durée du prêt.

#### Annuité constante (mode classique)

```
Annuité = Capital × Taux / [1 - (1 + Taux)^(-Durée)]
```

> 🚛 **Exemple**
>
> Emprunt 30 000 € sur 5 ans à 4 % annuel.
> - Annuité ≈ 30 000 × 0,04 / [1 - (1,04)^(-5)] ≈ **6 738 €/an**
> - Capital remboursé total : 30 000 €
> - Intérêts totaux : 5 × 6 738 - 30 000 ≈ **3 690 €**

---

## 3. Le plan de trésorerie prévisionnelle

> Tableau **mensuel** qui projette les **encaissements** et **décaissements** pour anticiper les tensions.

### 3.1 Construire son plan

| Mois | Janvier | Février | Mars | ... |
|---|---|---|---|---|
| **Encaissements** (clients, autres) | | | | |
| **Décaissements** (carburant, salaires, charges, TVA, IS, emprunt) | | | | |
| **Solde du mois** | | | | |
| **Solde cumulé** | | | | |

### 3.2 Décalages typiques en transport

- Clients : paiement à **30-60 jours**
- Carburant, péages : paiement **comptant** ou à 30 j
- Salaires : versés **mensuellement** (charges payées à m+1)
- TVA : **mensuelle** ou trimestrielle
- IS : **acomptes trimestriels** + solde à n+1
- Emprunts : mensualité **fixe**

> ⚠️ **Astuce pratique**
>
> Le mois où vous payez la **TVA + 13e mois + acompte IS** est souvent le plus tendu. Anticipez en gardant **3 mois de charges fixes en réserve**.

---

## 4. La fiscalité de l'entreprise

### 4.1 Imposition des bénéfices : IR vs IS

| Critère | Impôt sur le revenu (IR) | Impôt sur les sociétés (IS) |
|---|---|---|
| Qui paie | L'entrepreneur en son nom | La société elle-même |
| Sur quoi | Bénéfice intégré aux revenus du foyer | Bénéfice de la société (taxe forfaitaire) |
| Barème 2026 | Progressif : 0 / 11 / 30 / 41 / 45 % | **15 %** jusqu'à 42 500 € de bénéfice / **25 %** au-delà |
| Concerné | EI, EURL, SARL famille, SAS option IR | SARL, SAS, SASU, EURL option IS |

> 💡 **Choix stratégique**
>
> Si vos bénéfices sont **modestes** (< SMIC × 2), l'IR est souvent plus avantageux (les premières tranches sont basses). Si vos bénéfices sont **élevés** ou si vous voulez **réinvestir**, l'IS est plus avantageux car vous laissez les bénéfices dans l'entreprise au taux fixe de 15 %.

### 4.2 Les taxes spécifiques au transport

| Taxe | Cible |
|---|---|
| **TVS** (Taxe sur Véhicules de Société) | Véhicules particuliers en société (sauf VUL exonérés sous conditions) |
| **Taxe à l'essieu** | Poids-lourds ≥ 12 t (généralement hors capa ≤ 3,5 t) |
| **Taxe parafiscale formation pro** | Spécifique aux transporteurs |
| **CFE** (Cotisation Foncière des Entreprises) | Toutes entreprises, calcul sur la valeur locative |
| **CVAE** (Cotisation sur la Valeur Ajoutée) | Au-delà d'un certain CA |

---

## 5. La TVA

### 5.1 Mécanisme général

> La **TVA collectée** sur les ventes - **TVA déductible** sur les achats = **TVA à reverser à l'État** (ou crédit de TVA si négatif).

### 5.2 Taux de TVA en France (2026)

| Taux | Application |
|---|---|
| **20 %** | Taux normal — la majorité des prestations de transport |
| **10 %** | Taux intermédiaire — restauration, transport voyageurs (TER, bus...) |
| **5,5 %** | Taux réduit — produits alimentaires, livres |
| **2,1 %** | Taux super réduit — médicaments remboursés, presse |

> 📌 **Pour le transport routier de marchandises**
>
> Taux **20 %** par défaut sur la facturation au client.

### 5.3 Régime de franchise en base

> L'entreprise dont le CA HT est inférieur à un seuil **NE FACTURE PAS la TVA** et **NE LA DÉDUIT PAS** non plus.

#### Seuils 2026

| Activité | Seuil de franchise |
|---|---|
| **Prestations de service** (dont transport) | **36 800 €** de CA annuel |

Au-delà du seuil, l'entreprise sort du régime de franchise et doit collecter / déduire la TVA.

> 💡 **Avantage / inconvénient**
>
> ✅ Simplicité, pas de TVA à gérer, prix client plus bas
> ❌ Pas de déduction sur achats (carburant, pneus, entretien)
>
> Pour un transporteur avec beaucoup d'achats (carburant représentant 25-30 % du CA), le passage au **régime réel** dès le démarrage est souvent plus avantageux.

### 5.4 TVA intracommunautaire

> Pour les **transports B2B** (entreprise à entreprise) **dans l'Union européenne**, la facture est émise **HT** : c'est le **client** qui auto-liquide la TVA dans son pays (mécanisme du **reverse charge**).

#### Conditions

- L'acheteur doit fournir un **n° de TVA intracommunautaire valide** (vérifiable sur VIES)
- La facture doit mentionner « **Auto-liquidation, article 283-2 du CGI** »

### 5.5 Déclarations TVA

| Régime | Périodicité |
|---|---|
| **Normal** | Mensuelle (CA > 818 000 € HT) |
| **Simplifié** | Trimestrielle ou annuelle |
| **Franchise en base** | Pas de déclaration |

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| Plan de financement : règle | Total ressources ≥ Total besoins |
| Crédit-bail vs LLD | Crédit-bail = option d'achat finale ; LLD = pas d'option |
| IS taux jusqu'à 42 500 € | **15 %** |
| IS taux au-delà | **25 %** |
| Taux normal TVA | **20 %** |
| Seuil franchise TVA prestation | **36 800 €** de CA annuel |
| TVA intracommunautaire B2B | Auto-liquidation par l'acheteur (reverse charge) |
| Mention obligatoire facture intra-EU | « Auto-liquidation, article 283-2 du CGI » |
| Déclaration TVA si CA > 818 000 € | **Mensuelle** |
| TVA collectée vs TVA déductible | Collectée sur ventes, déductible sur achats. Différence = à reverser. |
$lesson4$,
'Plan de financement, sources (fonds propres, emprunt, crédit-bail, LLD), IR vs IS (15 %/25 %), TVA (20 %, franchise 36 800 €, intracommunautaire reverse charge).'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- BANQUE QCM REFORMULÉS — Module D (35 questions)
  -- =================================================================

  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qcm', 'Le coût de revient d''un service de transport regroupe :', '[{"id":"a","label":"Uniquement les frais de carburant","is_correct":false},{"id":"b","label":"Les charges variables, les charges de conduite, les charges fixes et les charges de structure","is_correct":true},{"id":"c","label":"Les seuls coûts directement rattachés à un client","is_correct":false},{"id":"d","label":"Le prix de vente HT au client","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['module-d','capa-3-5t','cout-revient'], 'mft-2026:moduleD:qcm:1', true, 'Le coût de revient agrège 4 catégories de charges : variables (au km), conduite (personnel roulant), fixes (par véhicule), structure (frais administratifs).'),
  (v_formation, 'qcm', 'Quel poste appartient aux CHARGES VARIABLES en transport ?', '[{"id":"a","label":"Le loyer des locaux","is_correct":false},{"id":"b","label":"Le carburant, les pneus et les péages","is_correct":true},{"id":"c","label":"Le salaire du gérant","is_correct":false},{"id":"d","label":"L''amortissement du véhicule","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['module-d','capa-3-5t','cout-revient','charges-variables'], 'mft-2026:moduleD:qcm:2', true, 'Les charges variables sont proportionnelles aux kilomètres parcourus : carburant, pneumatiques, entretien, péages.'),
  (v_formation, 'qcm', 'La formule "trinôme" du coût de revient combine :', '[{"id":"a","label":"Charges fixes + variables + structure","is_correct":false},{"id":"b","label":"Terme kilométrique + horaire + journalier","is_correct":true},{"id":"c","label":"Achats + ventes + résultat","is_correct":false},{"id":"d","label":"Trois mois consécutifs d''exercice","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-d','capa-3-5t','cout-revient','trinome'], 'mft-2026:moduleD:qcm:3', true, 'Trinôme = 3 termes : kilométrique (charges variables / km), horaire (charges conduite / h), journalier (charges fixes / jour).'),
  (v_formation, 'qcm', 'Le taux d''amortissement linéaire pour un bien dont la durée de vie est de 5 ans est de :', '[{"id":"a","label":"5 %","is_correct":false},{"id":"b","label":"10 %","is_correct":false},{"id":"c","label":"20 %","is_correct":true},{"id":"d","label":"25 %","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['module-d','capa-3-5t','amortissement','lineaire'], 'mft-2026:moduleD:qcm:4', true, 'Taux linéaire = 1 / durée de vie. 1 / 5 ans = 0,20 = 20 %/an.'),
  (v_formation, 'qcm', 'Pour un véhicule neuf amorti sur 5 ans en mode dégressif, le coefficient fiscal applicable est :', '[{"id":"a","label":"1,25","is_correct":false},{"id":"b","label":"1,75","is_correct":true},{"id":"c","label":"2,25","is_correct":false},{"id":"d","label":"3,00","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-d','capa-3-5t','amortissement','degressif'], 'mft-2026:moduleD:qcm:5', true, 'Coefficients dégressifs (article 39A CGI) : 1,25 (3-4 ans), 1,75 (5-6 ans), 2,25 (> 6 ans).'),
  (v_formation, 'qcm', 'Quelle condition est requise pour appliquer l''amortissement DÉGRESSIF à un véhicule de transport ?', '[{"id":"a","label":"Le véhicule doit être loué en LLD","is_correct":false},{"id":"b","label":"Le véhicule doit être neuf et de plus de 2 t de charge utile","is_correct":true},{"id":"c","label":"Le véhicule doit avoir moins de 5 000 km","is_correct":false},{"id":"d","label":"Aucune condition particulière","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-d','capa-3-5t','amortissement','degressif'], 'mft-2026:moduleD:qcm:6', true, 'Conditions cumulatives : bien NEUF + véhicule > 2 t de charge utile (cas de la majorité des PL et de certains VUL grand format).'),
  (v_formation, 'qcm', 'La marge commerciale d''une entreprise de transport se calcule par :', '[{"id":"a","label":"Chiffre d''affaires HT - coût de revient HT","is_correct":true},{"id":"b","label":"Chiffre d''affaires TTC - charges variables","is_correct":false},{"id":"c","label":"Bénéfice net après IS","is_correct":false},{"id":"d","label":"Coût de revient + 30 %","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['module-d','capa-3-5t','marge'], 'mft-2026:moduleD:qcm:7', true, 'Marge commerciale = CA HT - coût de revient HT. La TVA est neutralisée car elle n''est ni un produit ni une charge.'),
  (v_formation, 'qcm', 'Le taux de MARQUE est calculé en pourcentage :', '[{"id":"a","label":"Du coût de revient","is_correct":false},{"id":"b","label":"Du prix de vente","is_correct":true},{"id":"c","label":"Du chiffre d''affaires brut","is_correct":false},{"id":"d","label":"Du bénéfice net","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-d','capa-3-5t','marge','taux-marque'], 'mft-2026:moduleD:qcm:8', true, 'Taux de MARQUE = Marge / Prix de vente (sur le PV). Taux de MARGE = Marge / Coût de revient (sur le CR). À ne pas confondre.'),
  (v_formation, 'qcm', 'Le SEUIL DE RENTABILITÉ correspond à :', '[{"id":"a","label":"Le bénéfice annuel maximal possible","is_correct":false},{"id":"b","label":"Le chiffre d''affaires HT à atteindre pour obtenir un résultat NUL","is_correct":true},{"id":"c","label":"Le coût de revient minimum","is_correct":false},{"id":"d","label":"Le total des charges fixes uniquement","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-d','capa-3-5t','seuil-rentabilite'], 'mft-2026:moduleD:qcm:9', true, 'Seuil de rentabilité (SR) = niveau de CA qui couvre exactement toutes les charges. Au-dessus = bénéfice. En dessous = perte.'),
  (v_formation, 'qcm', 'Le POINT MORT exprime :', '[{"id":"a","label":"Le bénéfice annuel attendu","is_correct":false},{"id":"b","label":"La durée d''activité (en jours) nécessaire pour atteindre le seuil de rentabilité","is_correct":true},{"id":"c","label":"Le moment où l''entreprise doit fermer","is_correct":false},{"id":"d","label":"Le délai de remboursement d''un emprunt","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-d','capa-3-5t','point-mort'], 'mft-2026:moduleD:qcm:10', true, 'Point mort = (Seuil de rentabilité × 360) / CA annuel. Exprimé en jours d''activité. Ex : SR 60 000 € pour un CA 90 000 € → 240 jours.'),
  (v_formation, 'qcm', 'Le BILAN d''une entreprise se présente toujours :', '[{"id":"a","label":"Sur 12 mois glissants","is_correct":false},{"id":"b","label":"Avec un total ACTIF égal au total PASSIF","is_correct":true},{"id":"c","label":"Avec uniquement les charges et les produits","is_correct":false},{"id":"d","label":"Comme un chiffre unique","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['module-d','capa-3-5t','bilan'], 'mft-2026:moduleD:qcm:11', true, 'Le bilan est une photographie à un instant T. Règle absolue : Total actif = Total passif. À l''actif les emplois, au passif les ressources.'),
  (v_formation, 'qcm', 'Parmi ces postes, lequel figure à l''ACTIF du bilan ?', '[{"id":"a","label":"Le capital social","is_correct":false},{"id":"b","label":"Les emprunts bancaires","is_correct":false},{"id":"c","label":"Les véhicules détenus en pleine propriété","is_correct":true},{"id":"d","label":"Les dettes fournisseurs","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['module-d','capa-3-5t','bilan','actif'], 'mft-2026:moduleD:qcm:12', true, 'Actif = ce que l''entreprise possède : véhicules (immobilisations), créances clients, stocks, trésorerie. Passif = comment c''est financé (capitaux propres + dettes).'),
  (v_formation, 'qcm', 'Le COMPTE DE RÉSULTAT mesure :', '[{"id":"a","label":"Le patrimoine de l''entreprise à un instant T","is_correct":false},{"id":"b","label":"La performance de l''entreprise sur une période (12 mois)","is_correct":true},{"id":"c","label":"La trésorerie disponible en banque","is_correct":false},{"id":"d","label":"La valeur des immobilisations","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['module-d','capa-3-5t','compte-resultat'], 'mft-2026:moduleD:qcm:13', true, 'Le compte de résultat mesure la performance sur une période (Produits - Charges = Résultat). Le bilan est la photographie patrimoniale à un instant T.'),
  (v_formation, 'qcm', 'La VALEUR AJOUTÉE (VA) est calculée par :', '[{"id":"a","label":"Production de l''exercice - Consommations en provenance de tiers","is_correct":true},{"id":"b","label":"Chiffre d''affaires - Salaires","is_correct":false},{"id":"c","label":"Bénéfice net + Amortissements","is_correct":false},{"id":"d","label":"Total des actifs - Total des dettes","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-d','capa-3-5t','sig','valeur-ajoutee'], 'mft-2026:moduleD:qcm:14', true, 'VA = Production - Consommations externes. Mesure la richesse créée par l''entreprise, qui sera ensuite distribuée aux salariés, État, banques, actionnaires, et à l''autofinancement.'),
  (v_formation, 'qcm', 'L''Excédent Brut d''Exploitation (EBE) est obtenu par :', '[{"id":"a","label":"VA - Charges de personnel - Impôts et taxes (+ subventions)","is_correct":true},{"id":"b","label":"CA - Charges variables uniquement","is_correct":false},{"id":"c","label":"Résultat net + Impôts","is_correct":false},{"id":"d","label":"Total des produits","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-d','capa-3-5t','sig','ebe'], 'mft-2026:moduleD:qcm:15', true, 'EBE = VA + Subventions d''exploitation - Impôts et taxes - Charges de personnel. Indicateur de performance pure avant amortissements et politique de financement.'),
  (v_formation, 'qcm', 'La Capacité d''Autofinancement (CAF) mesure :', '[{"id":"a","label":"Le bénéfice net après impôt","is_correct":false},{"id":"b","label":"Le cash réellement dégagé par l''activité","is_correct":true},{"id":"c","label":"Le total des dettes","is_correct":false},{"id":"d","label":"La valeur du capital social","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-d','capa-3-5t','sig','caf'], 'mft-2026:moduleD:qcm:16', true, 'CAF = ressources financières dégagées par l''activité. Différence avec le résultat net : la CAF EXCLUT les charges calculées (amortissements, provisions) qui ne sont pas décaissées.'),
  (v_formation, 'qcm', 'Le Fonds de Roulement Net Global (FRNG) se calcule par :', '[{"id":"a","label":"Capitaux propres - Trésorerie","is_correct":false},{"id":"b","label":"Capitaux permanents - Actif immobilisé net","is_correct":true},{"id":"c","label":"Bénéfice / 12","is_correct":false},{"id":"d","label":"Stocks + Créances clients","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-d','capa-3-5t','frng'], 'mft-2026:moduleD:qcm:17', true, 'FRNG = (Capitaux propres + Dettes financières long terme) - Actif immobilisé net. Mesure la capacité des ressources stables à financer les emplois stables et un excédent pour le cycle d''exploitation.'),
  (v_formation, 'qcm', 'Le Besoin en Fonds de Roulement (BFR) se calcule par :', '[{"id":"a","label":"(Stocks + Créances clients) - Dettes fournisseurs et fiscales","is_correct":true},{"id":"b","label":"FRNG - Trésorerie","is_correct":false},{"id":"c","label":"Bénéfice + Amortissements","is_correct":false},{"id":"d","label":"Capital social - Réserves","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-d','capa-3-5t','bfr'], 'mft-2026:moduleD:qcm:18', true, 'BFR = besoin de financement né du décalage entre encaissements clients et décaissements (fournisseurs, salaires, charges sociales et fiscales). En transport, généralement positif.'),
  (v_formation, 'qcm', 'La relation fondamentale liant FRNG, BFR et Trésorerie nette est :', '[{"id":"a","label":"TN = FRNG + BFR","is_correct":false},{"id":"b","label":"TN = FRNG - BFR","is_correct":true},{"id":"c","label":"TN = FRNG × BFR","is_correct":false},{"id":"d","label":"TN = FRNG / BFR","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-d','capa-3-5t','tresorerie','frng','bfr'], 'mft-2026:moduleD:qcm:19', true, 'Relation fondamentale : Trésorerie nette = FRNG - BFR. Si FRNG > BFR : TN positive (cash). Si BFR > FRNG : TN négative (découvert).'),
  (v_formation, 'qcm', 'Quand le BFR est positif :', '[{"id":"a","label":"L''entreprise a un excédent de trésorerie","is_correct":false},{"id":"b","label":"L''entreprise paie ses fournisseurs avant d''encaisser ses clients","is_correct":true},{"id":"c","label":"L''entreprise est en cessation de paiement","is_correct":false},{"id":"d","label":"L''entreprise est sous-capitalisée","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-d','capa-3-5t','bfr'], 'mft-2026:moduleD:qcm:20', true, 'BFR positif = besoin de financement à court terme. L''entreprise avance de l''argent au quotidien (paiement fournisseurs, salaires) avant d''encaisser ses créances clients. Cas typique en transport.'),
  (v_formation, 'qcm', 'Une PROVISION en comptabilité est :', '[{"id":"a","label":"La constatation d''une perte de valeur certaine","is_correct":false},{"id":"b","label":"Une réserve pour faire face à un risque ou une charge future probable mais incertain","is_correct":true},{"id":"c","label":"Une avance versée à un fournisseur","is_correct":false},{"id":"d","label":"Un emprunt court terme","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-d','capa-3-5t','provision'], 'mft-2026:moduleD:qcm:21', true, 'Provision = charge calculée pour un risque incertain (clients douteux, litige, gros entretien). Réversible : peut être reprise si le risque ne se réalise pas. À distinguer de l''amortissement (perte de valeur certaine).'),
  (v_formation, 'qcm', 'Le LIVRE-JOURNAL d''une entreprise sert à :', '[{"id":"a","label":"Lister les actifs et passifs","is_correct":false},{"id":"b","label":"Enregistrer toutes les transactions par ordre chronologique","is_correct":true},{"id":"c","label":"Calculer le résultat net","is_correct":false},{"id":"d","label":"Présenter le bilan annuel","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['module-d','capa-3-5t','comptabilite'], 'mft-2026:moduleD:qcm:22', true, 'Livre-journal = enregistrement chronologique des opérations. Le grand livre reprend les mêmes informations classées par compte.'),
  (v_formation, 'qcm', 'Le taux NORMAL de TVA en France métropolitaine est de :', '[{"id":"a","label":"5,5 %","is_correct":false},{"id":"b","label":"10 %","is_correct":false},{"id":"c","label":"20 %","is_correct":true},{"id":"d","label":"25 %","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['module-d','capa-3-5t','tva'], 'mft-2026:moduleD:qcm:23', true, 'Taux normal de TVA en France métropolitaine = 20 %. Taux intermédiaire 10 % (transport voyageurs), réduit 5,5 % (alimentaire), super réduit 2,1 % (médicaments remboursés).'),
  (v_formation, 'qcm', 'Le mécanisme général de la TVA pour une entreprise de transport est :', '[{"id":"a","label":"TVA collectée + TVA déductible = TVA à payer","is_correct":false},{"id":"b","label":"TVA collectée - TVA déductible = TVA à reverser à l''État","is_correct":true},{"id":"c","label":"TVA = 20 % du bénéfice","is_correct":false},{"id":"d","label":"TVA = différence entre achats et ventes TTC","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-d','capa-3-5t','tva'], 'mft-2026:moduleD:qcm:24', true, 'TVA collectée (sur ventes) - TVA déductible (sur achats) = TVA à reverser à l''État. Si négatif : crédit de TVA reportable ou remboursable.'),
  (v_formation, 'qcm', 'Une transport B2B intra-européen entre une entreprise française et une entreprise allemande est facturé :', '[{"id":"a","label":"TTC à 20 % de TVA","is_correct":false},{"id":"b","label":"HT, l''acheteur auto-liquide la TVA dans son pays","is_correct":true},{"id":"c","label":"TTC à un taux unique européen","is_correct":false},{"id":"d","label":"Toujours hors TVA, sans déclaration","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-d','capa-3-5t','tva','intracommunautaire'], 'mft-2026:moduleD:qcm:25', true, 'TVA intracommunautaire B2B : facturation HT, l''acheteur auto-liquide la TVA chez lui (reverse charge). Mention obligatoire : "Auto-liquidation, article 283-2 du CGI". Numéro TVA de l''acheteur à valider sur VIES.'),
  (v_formation, 'qcm', 'L''Impôt sur les Sociétés (IS) en France est de combien jusqu''à 42 500 € de bénéfice ?', '[{"id":"a","label":"15 %","is_correct":true},{"id":"b","label":"20 %","is_correct":false},{"id":"c","label":"25 %","is_correct":false},{"id":"d","label":"30 %","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-d','capa-3-5t','is','fiscalite'], 'mft-2026:moduleD:qcm:26', true, 'IS taux réduit 15 % jusqu''à 42 500 € de bénéfice imposable, taux normal 25 % au-delà. Conditions : société soumise à l''IS, CA < 10 M€, capital intégralement libéré et détenu à 75 % min par des personnes physiques.'),
  (v_formation, 'qcm', 'Pour qu''une entreprise de transport bénéficie du régime de FRANCHISE EN BASE de TVA, son CA HT annuel ne doit pas dépasser :', '[{"id":"a","label":"22 800 €","is_correct":false},{"id":"b","label":"36 800 €","is_correct":true},{"id":"c","label":"77 700 €","is_correct":false},{"id":"d","label":"176 200 €","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-d','capa-3-5t','tva','franchise'], 'mft-2026:moduleD:qcm:27', true, 'Seuil franchise en base prestations de service (transport inclus) : 36 800 € de CA HT annuel. Au-delà, l''entreprise sort de la franchise. À comparer aux 91 900 € pour les activités de vente.'),
  (v_formation, 'qcm', 'Le PLAN DE FINANCEMENT prévisionnel doit respecter quel équilibre ?', '[{"id":"a","label":"Bénéfice ≥ Charges fixes","is_correct":false},{"id":"b","label":"Total ressources ≥ Total besoins","is_correct":true},{"id":"c","label":"Capitaux propres ≥ Dettes","is_correct":false},{"id":"d","label":"Trésorerie ≥ Investissements","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-d','capa-3-5t','plan-financement'], 'mft-2026:moduleD:qcm:28', true, 'Le plan de financement doit équilibrer total des ressources (capitaux propres, emprunts, CAF, subventions) et total des besoins (investissements, BFR, frais d''établissement) sur 3 à 5 ans.'),
  (v_formation, 'qcm', 'La principale différence entre crédit-bail (LOA) et location longue durée (LLD) est :', '[{"id":"a","label":"Le crédit-bail propose une option d''achat finale, pas la LLD","is_correct":true},{"id":"b","label":"La LLD est moins chère que le crédit-bail","is_correct":false},{"id":"c","label":"Le crédit-bail nécessite un apport, pas la LLD","is_correct":false},{"id":"d","label":"Aucune différence juridique","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-d','capa-3-5t','financement','leasing'], 'mft-2026:moduleD:qcm:29', true, 'Crédit-bail (LOA, leasing) = location avec option d''achat finale (valeur résiduelle). LLD = location pure sans option d''achat, mais services souvent inclus (entretien, assurance, pneus).'),
  (v_formation, 'qcm', 'Quel mode de financement IMMOBILISE le bien à l''actif du bilan ?', '[{"id":"a","label":"Le crédit-bail","is_correct":false},{"id":"b","label":"L''emprunt bancaire (achat en pleine propriété)","is_correct":true},{"id":"c","label":"La location longue durée","is_correct":false},{"id":"d","label":"Le contrat de location simple","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-d','capa-3-5t','financement','bilan'], 'mft-2026:moduleD:qcm:30', true, 'Achat avec emprunt = bien à l''actif (immobilisations) + dette au passif. LLD et crédit-bail = hors bilan (le loueur reste propriétaire). Cela impacte les ratios financiers (FRNG, endettement).'),
  (v_formation, 'qcm', 'L''Impôt sur le Revenu (IR) concerne quelle catégorie d''entreprise ?', '[{"id":"a","label":"L''Entreprise Individuelle (EI) par défaut","is_correct":true},{"id":"b","label":"La SARL classique par défaut","is_correct":false},{"id":"c","label":"La SAS par défaut","is_correct":false},{"id":"d","label":"Toutes les sociétés sans exception","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-d','capa-3-5t','ir','fiscalite'], 'mft-2026:moduleD:qcm:31', true, 'IR = par défaut pour EI et EURL (associé unique personne physique). IS = par défaut pour SARL classique, SAS, SASU. Options possibles dans certains cas (SARL famille à l''IR, EURL à l''IS).'),
  (v_formation, 'qcm', 'La TVA déductible sur les achats correspond à :', '[{"id":"a","label":"La TVA que l''entreprise reçoit de ses clients","is_correct":false},{"id":"b","label":"La TVA que l''entreprise a payée sur ses propres achats professionnels","is_correct":true},{"id":"c","label":"La TVA à payer à l''État","is_correct":false},{"id":"d","label":"Une taxe spéciale au transport","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['module-d','capa-3-5t','tva'], 'mft-2026:moduleD:qcm:32', true, 'TVA déductible = celle payée sur les achats professionnels (carburant, pneus, entretien, etc.). TVA collectée = celle facturée au client. Différence = à reverser à l''État (ou crédit reportable).'),
  (v_formation, 'qcm', 'Le RÉSULTAT D''EXPLOITATION mesure :', '[{"id":"a","label":"La performance opérationnelle de l''entreprise (avant éléments financiers et exceptionnels)","is_correct":true},{"id":"b","label":"Le bénéfice net après impôt","is_correct":false},{"id":"c","label":"Le total des produits","is_correct":false},{"id":"d","label":"Le cumul des charges fixes","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-d','capa-3-5t','sig','resultat-exploitation'], 'mft-2026:moduleD:qcm:33', true, 'Résultat d''exploitation = Produits d''exploitation - Charges d''exploitation. Mesure la performance pure du métier (avant intérêts d''emprunt, exceptionnels et IS).'),
  (v_formation, 'qcm', 'Une AUGMENTATION du capital social permet d''AMÉLIORER en priorité :', '[{"id":"a","label":"Le BFR","is_correct":false},{"id":"b","label":"Le FRNG (et donc la Trésorerie nette)","is_correct":true},{"id":"c","label":"Le compte de résultat","is_correct":false},{"id":"d","label":"Le CA prévisionnel","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-d','capa-3-5t','frng','levier'], 'mft-2026:moduleD:qcm:34', true, 'Augmenter les capitaux propres → augmente les capitaux permanents → augmente le FRNG → améliore la TN (TN = FRNG - BFR). Levier classique en cas de tension de trésorerie structurelle.'),
  (v_formation, 'qcm', 'Le compte de résultat se présente en quelle structure ?', '[{"id":"a","label":"Actif / Passif","is_correct":false},{"id":"b","label":"Charges / Produits / Résultat","is_correct":true},{"id":"c","label":"Encaissements / Décaissements","is_correct":false},{"id":"d","label":"Investissements / Financements","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['module-d','capa-3-5t','compte-resultat'], 'mft-2026:moduleD:qcm:35', true, 'Compte de résultat : à gauche les charges (par catégorie : exploitation, financière, exceptionnelle), à droite les produits (mêmes catégories). Différence = Résultat net (bénéfice ou perte).');

  -- =================================================================
  -- BANQUE QR — Module D (6 mises en situation)
  -- =================================================================

  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qr',
    'Vous achetez un VUL diesel neuf à 28 000 € HT pour votre activité de coursier. Vous prévoyez 30 000 km/an, 220 jours d''exploitation, un salaire chauffeur (vous) brut + charges de 35 000 €/an. Carburant : 8 l/100 km à 1,75 €/l. Pneus : 4 × 200 €/60 000 km. Entretien : 1 800 €/an. Péages : 1 200 €/an. Loyer locaux : 4 800 €/an. Assurance véhicule : 2 200 €/an. Frais administratifs : 3 000 €/an.

a. Calculez chaque catégorie de charges (variables, conduite, fixes véhicule, structure) en annuel.
b. Calculez le coût de revient KILOMÉTRIQUE total.
c. Quelle marge appliqueriez-vous pour viser un revenu net mensuel correct ?
d. Quel prix de vente moyen au km devez-vous facturer ?',
    NULL, 5, 'difficile',
    ARRAY['module-d','capa-3-5t','qr','cout-revient','cas-pratique'],
    'mft-2026:moduleD:qr:1', true,
    'Correction : a. Variables : carburant 30 000 × 0,08 × 1,75 = 4 200 € + pneus (4 × 200) / 60 000 × 30 000 = 400 € + entretien 1 800 € + péages 1 200 € = 7 600 €. Conduite : 35 000 €. Fixes véhicule : amortissement 28 000/5 = 5 600 € + assurance 2 200 € = 7 800 €. Structure : loyer 4 800 € + frais admin 3 000 € = 7 800 €. b. Total = 7 600 + 35 000 + 7 800 + 7 800 = 58 200 €. CR/km = 58 200 / 30 000 = 1,94 €/km. c. Marge 25-30 % pour dégager un revenu suffisant après IS, soit 0,49-0,58 €/km de marge. d. Prix de vente cible ≈ 2,45 - 2,55 €/km HT, à arbitrer selon la concurrence locale.'),

  (v_formation, 'qr',
    'Une SARL de transport présente le bilan suivant en N-1 : Actif immobilisé net 40 000 €, Stocks 5 000 €, Créances clients 25 000 €, Trésorerie 8 000 €. Capitaux propres 35 000 €, Emprunts long terme 20 000 €, Dettes fournisseurs 15 000 €, Dettes fiscales et sociales 8 000 €.

a. Calculez le FRNG.
b. Calculez le BFR.
c. Vérifiez la cohérence avec la trésorerie en banque.
d. Que proposeriez-vous si la TN devenait négative l''année suivante ?',
    NULL, 5, 'difficile',
    ARRAY['module-d','capa-3-5t','qr','frng','bfr','cas-pratique'],
    'mft-2026:moduleD:qr:2', true,
    'Correction : a. Capitaux permanents = 35 000 + 20 000 = 55 000 €. FRNG = 55 000 - 40 000 = 15 000 €. b. BFR = (5 000 + 25 000) - (15 000 + 8 000) = 7 000 €. c. TN théorique = FRNG - BFR = 15 000 - 7 000 = 8 000 €. C''est cohérent avec la trésorerie réelle (8 000 €). d. Plusieurs leviers : (1) augmenter FRNG via apport en compte courant ou augmentation de capital ou emprunt MT, (2) réduire BFR via affacturage, escompte client pour paiement comptant, négociation délais fournisseurs, (3) à court terme, ligne de découvert ou Dailly.'),

  (v_formation, 'qr',
    'Vous démarrez votre activité avec un CA prévisionnel de 65 000 € HT/an. Vous hésitez entre rester en franchise en base de TVA et opter pour le régime réel. Vos achats professionnels prévus avec TVA récupérable sont d''environ 18 000 € HT par an (carburant, entretien, location locaux, etc.).

a. Êtes-vous éligible à la franchise en base de TVA ? Justifiez.
b. Quel serait le montant de la TVA déductible si vous optiez pour le régime réel ?
c. Comparez les avantages financiers des 2 régimes.
d. Quelle est votre recommandation ?',
    NULL, 5, 'moyen',
    ARRAY['module-d','capa-3-5t','qr','tva','cas-pratique'],
    'mft-2026:moduleD:qr:3', true,
    'Correction : a. NON, vous dépassez le seuil de 36 800 € de CA HT annuel pour les prestations de service. b. TVA déductible sur achats = 18 000 × 20 % = 3 600 €/an. C''est votre ÉCONOMIE annuelle si vous facturez TTC à des clients ASSUJETTIS. c. Régime réel : (+) déduction de la TVA sur achats (3 600 €), (+) possibilité de récupérer un crédit TVA. (-) facturation TVA aux clients (peut être un frein si non assujettis). Franchise : (+) simplicité, (+) prix client plus bas si non-assujettis. (-) pas de déduction sur achats. d. Régime RÉEL recommandé car (1) vous dépassez de toute façon le seuil, (2) la TVA déductible (3 600 €) est significative, (3) en B2B la facturation TTC ne pose pas de problème (l''assujetti récupère).'),

  (v_formation, 'qr',
    'Vous êtes en SASU à l''IS. Bénéfice imposable de l''exercice : 55 000 €. Vous vous versez un salaire de 30 000 € net dans l''année (déjà déduit du résultat).

a. Calculez l''IS dû par la société.
b. Quel est le résultat net après IS ?
c. Si vous vous versez 20 000 € de dividendes en plus, quelle imposition supplémentaire ?
d. Comparez avec le scénario SARL gérant majoritaire (régime TNS).',
    NULL, 5, 'difficile',
    ARRAY['module-d','capa-3-5t','qr','is','dividendes','cas-pratique'],
    'mft-2026:moduleD:qr:4', true,
    'Correction : a. IS = (42 500 × 15 %) + ((55 000 - 42 500) × 25 %) = 6 375 + 3 125 = 9 500 €. b. Résultat net après IS = 55 000 - 9 500 = 45 500 €. c. Dividendes 20 000 € → flat tax PFU 30 % (12,8 % IR + 17,2 % CSG/CRDS) = 6 000 € de prélèvements. Dividende net perçu = 14 000 €. d. SARL gérant majoritaire (TNS) : pas d''IS sur la rémunération, mais cotisations TNS ≈ 45 % du revenu, soit ≈ 13 500 € sur 30 000 €. Bilan TNS souvent moins protecteur (pas de chômage, retraite plus faible) mais charges sociales plus basses qu''en assimilé salarié SAS (≈ 75 %). Le choix dépend du niveau de revenu, de la protection sociale recherchée et de la stratégie de dividendes.'),

  (v_formation, 'qr',
    'Calcul du seuil de rentabilité. Votre exploitation prévoit : Charges fixes véhicule + structure : 32 000 €/an. Charges variables : 0,52 €/km. Prix de vente moyen : 1,40 €/km. Vous prévoyez 25 000 km/an.

a. Calculez la MSCV par km et globale.
b. Calculez le seuil de rentabilité en kilomètres.
c. Calculez le seuil de rentabilité en CA HT.
d. Calculez le point mort (en jours d''activité).',
    NULL, 5, 'moyen',
    ARRAY['module-d','capa-3-5t','qr','seuil-rentabilite','cas-pratique'],
    'mft-2026:moduleD:qr:5', true,
    'Correction : a. MSCV / km = 1,40 - 0,52 = 0,88 €/km. MSCV globale = 25 000 × 0,88 = 22 000 €. b. Seuil km = Charges fixes / MSCV/km = 32 000 / 0,88 = 36 364 km. ATTENTION : SUPÉRIEUR aux 25 000 km prévus ! L''entreprise N''ATTEINT PAS son seuil avec ces hypothèses. c. Seuil en CA HT = 36 364 × 1,40 = 50 909 €. d. Point mort = (50 909 × 360) / (25 000 × 1,40) = 50 909 × 360 / 35 000 = 524 jours. Plus de 1 an et demi nécessaire ! Conclusion : il faut augmenter les km parcourus, augmenter le prix au km, ou réduire les charges fixes. Les hypothèses actuelles sont déficitaires.'),

  (v_formation, 'qr',
    'Vous achetez un VUL neuf à 32 000 € HT, charge utile 1,2 t. Durée d''utilisation prévue 5 ans.

a. Pouvez-vous appliquer l''amortissement dégressif ? Justifiez.
b. Calculez l''annuité d''amortissement linéaire la 1re année (achat le 1er juillet).
c. Si l''amortissement dégressif était possible, calculez les annuités sur 5 ans.
d. Quel impact sur le résultat fiscal ?',
    NULL, 5, 'difficile',
    ARRAY['module-d','capa-3-5t','qr','amortissement','cas-pratique'],
    'mft-2026:moduleD:qr:6', true,
    'Correction : a. NON. Le dégressif exige un véhicule de plus de 2 t de CHARGE UTILE. Ici 1,2 t = condition non remplie. Seul le linéaire s''applique. b. Linéaire 5 ans : taux 20 %. Achat 1er juillet → 6 mois pour année N (prorata 180/360 jours). Annuité N = 32 000 × 20 % × 180/360 = 3 200 €. Annuités N+1 à N+4 = 32 000 × 20 % = 6 400 €. Année N+5 = 32 000 × 20 % × 180/360 = 3 200 € (le solde). Total = 32 000 € sur 5 ans + 6 mois. c. (Hypothétique) Dégressif coefficient 1,75 sur 5 ans : taux dégressif 35 %. Année 1 : 32 000 × 35 % = 11 200 €. Année 2 : (32 000 - 11 200) × 35 % = 7 280 €. Année 3 : (20 800 - 7 280) × 35 % = 4 732 €. À ce stade, l''amortissement linéaire restant (13 520 / 3) = 4 507 € est inférieur au dégressif (4 732), donc on continue en dégressif. Année 4 : (8 788) × 35 % = 3 076 €, mais linéaire restant = 8 788 / 2 = 4 394 € → on bascule en linéaire. Année 4 et 5 = 4 394 € chacune. d. Le dégressif accélère la déduction fiscale les premières années → moins d''impôt à court terme, plus d''impôt à long terme. Trésorerie favorable au démarrage.');

  -- =================================================================
  -- QUIZZES par leçon + examen blanc
  -- =================================================================

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Coût de revient — Quiz', 'Quiz sur le calcul du coût de revient, l''amortissement, la marge et le seuil de rentabilité.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref BETWEEN 'mft-2026:moduleD:qcm:1' AND 'mft-2026:moduleD:qcm:10';

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Bilan et compte de résultat — Quiz', 'Quiz sur les documents comptables, le bilan et le compte de résultat.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026:moduleD:qcm:11','mft-2026:moduleD:qcm:12','mft-2026:moduleD:qcm:13','mft-2026:moduleD:qcm:21','mft-2026:moduleD:qcm:22','mft-2026:moduleD:qcm:33','mft-2026:moduleD:qcm:35');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Santé financière — Quiz', 'Quiz sur les SIG, FRNG, BFR, Trésorerie nette.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026:moduleD:qcm:14','mft-2026:moduleD:qcm:15','mft-2026:moduleD:qcm:16','mft-2026:moduleD:qcm:17','mft-2026:moduleD:qcm:18','mft-2026:moduleD:qcm:19','mft-2026:moduleD:qcm:20','mft-2026:moduleD:qcm:34');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Financement et fiscalité — Quiz', 'Quiz sur le plan de financement, les sources de financement, IR/IS, TVA.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026:moduleD:qcm:23','mft-2026:moduleD:qcm:24','mft-2026:moduleD:qcm:25','mft-2026:moduleD:qcm:26','mft-2026:moduleD:qcm:27','mft-2026:moduleD:qcm:28','mft-2026:moduleD:qcm:29','mft-2026:moduleD:qcm:30','mft-2026:moduleD:qcm:31','mft-2026:moduleD:qcm:32');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Examen blanc — Module D', 'Examen blanc Module D : 5 QCM en 12 min, seuil 50 % comme l''examen national.', 'examen', 720, 50)
  RETURNING id INTO v_quiz_eb;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026:moduleD:qcm:4','mft-2026:moduleD:qcm:9','mft-2026:moduleD:qcm:17','mft-2026:moduleD:qcm:23','mft-2026:moduleD:qcm:26');

  RAISE NOTICE '✅ Module D v2 chargé : 4 leçons, 35 QCM, 6 QR, 5 quizzes.';
END
$module_d_v2$;
