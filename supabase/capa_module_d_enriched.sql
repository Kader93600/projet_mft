-- =====================================================================
-- MODULE D — ACTIVITÉ FINANCIÈRE DE L'ENTREPRISE (Capa -3,5T)
-- 5 leçons premium ~ 175 min.
-- =====================================================================

DO $mod_d$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'capacite-3-5t';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation capacite-3-5t introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc défini.'; END IF;

  SELECT id INTO v_module FROM public.modules WHERE slug = 'capa-activite-financiere' LIMIT 1;
  IF v_module IS NULL THEN
    INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
    VALUES (
      'Activité financière de l''entreprise',
      'capa-activite-financiere',
      v_bloc,
      'Lire un bilan, comprendre un compte de résultat, calculer son coût de revient et sa rentabilité. Les fondamentaux financiers indispensables au transporteur.',
      'avance', 175, 40
    ) RETURNING id INTO v_module;
    INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
    VALUES (v_formation, v_module, 40, true) ON CONFLICT DO NOTHING;
  END IF;

  -- LEÇON 1 — Lire un bilan
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'lire-bilan') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (v_module, 'Lire un bilan : photographie du patrimoine', 'lire-bilan', 1, 35,
$l$
Le bilan est la **photographie** financière de l'entreprise à une date donnée. Apprendre à le lire, c'est savoir si vous êtes solide, fragile, sur-endetté ou sous-investi. Une compétence vitale.

:::objectifs
- Comprendre la structure **Actif / Passif** d'un bilan.
- Identifier les **postes-clés** d'un bilan transport.
- Calculer **3 ratios** simples pour un diagnostic rapide.
:::

## La structure du bilan

Le bilan se présente toujours en **2 colonnes** équilibrées :

| ACTIF (ce qu'on possède) | PASSIF (ce qu'on doit) |
|---|---|
| Immobilisations (long terme) | Capitaux propres (apports + résultats) |
| Stocks | Dettes long terme (emprunts) |
| Créances clients | Dettes court terme (fournisseurs, fiscales) |
| Trésorerie | Découvert bancaire |

**Règle d'or** : Actif total = Passif total. **Toujours**.

### Les postes typiques d'un transporteur

**Actif** :
- **Immobilisations corporelles** : véhicules (poste majeur en transport).
- **Créances clients** : factures émises non encore payées (souvent 30-60 j de CA).
- **Disponibilités** : compte bancaire et caisse.

**Passif** :
- **Capitaux propres** : capital social + réserves + résultat de l'exercice.
- **Dettes financières** : emprunts pour les véhicules.
- **Dettes fournisseurs** : carburant, péages, entretien à payer.
- **Dettes fiscales et sociales** : TVA à reverser, URSSAF, IS.

## Les 3 ratios essentiels

### 1. Ratio d'endettement

$$\\text{Endettement} = \\frac{\\text{Dettes financières}}{\\text{Capitaux propres}}$$

| Valeur | Interprétation |
|---|---|
| < 1 | Faiblement endetté (sain) |
| 1 à 2 | Endettement modéré (acceptable) |
| > 2 | Sur-endettement (risqué) |

### 2. Fonds de roulement (FR)

$$\\text{FR} = \\text{Capitaux permanents} - \\text{Actif immobilisé}$$

**Doit être positif** : sinon, vous financez vos investissements long terme avec des dettes courtes (très dangereux).

### 3. Trésorerie nette

$$\\text{Trésorerie} = \\text{FR} - \\text{BFR}$$

**Si négative** : vous êtes en découvert structurel — alarme rouge.

:::caspratique
**Bilan TRANSEXPRESS au 31/12** :
- Immobilisations : 80 000 € (3 véhicules)
- Créances clients : 35 000 €
- Trésorerie : 8 000 €
- **Actif total : 123 000 €**
- Capital social : 20 000 €
- Réserves + résultat : 15 000 €
- Emprunts (LT) : 60 000 €
- Fournisseurs : 18 000 €
- Dettes sociales : 10 000 €
- **Passif total : 123 000 €**

**Diagnostic** :
- Endettement : 60 000 / 35 000 = **1,71** → modéré, acceptable.
- FR : (35 000 + 60 000) – 80 000 = **15 000 €** → positif, OK.
- BFR : 35 000 – (18 000 + 10 000) = **7 000 €**.
- Trésorerie nette : 15 000 – 7 000 = **8 000 €** → positive (cohérent avec la disponibilité).

**Verdict** : entreprise saine, légèrement endettée, capable d'absorber un coup dur grâce à sa trésorerie positive.
:::

:::piege
**Erreur fréquente** : confondre **trésorerie** (ce qu'il y a en banque) et **résultat** (bénéfice de l'année). Une entreprise rentable peut être en cessation de paiements si elle n'encaisse pas à temps.
:::

## La lecture pratique en 5 minutes

Quand vous recevez votre bilan, posez-vous **5 questions** dans l'ordre :

1. **Capitaux propres > 0 ?** Si non : **alerte rouge**, vous êtes en faillite technique.
2. **Trésorerie nette > 0 ?** Si non : **alerte orange**, vérifier la dynamique.
3. **Ratio d'endettement < 2 ?** Si non : prudence sur les nouveaux emprunts.
4. **Créances clients < 90 jours de CA ?** Si non : problème de recouvrement.
5. **Fournisseurs cohérents avec votre activité ?** Si gonflement anormal : alerte sur la chaîne paiement.

:::conseil
**Demandez à votre expert-comptable un bilan intermédiaire à 6 mois** (souvent inclus dans la mission). Ne pas attendre le bilan annuel pour détecter des dérives.
:::
$l$,
$s$
**À retenir**
- Bilan = photographie patrimoniale, équilibre Actif = Passif.
- 3 ratios essentiels : endettement, fonds de roulement, trésorerie nette.
- Trésorerie ≠ résultat : on peut être rentable et en cessation.
- 5 questions à se poser à chaque bilan.
- Bilan intermédiaire à 6 mois = anticipation.
$s$);
  END IF;

  -- LEÇON 2 — Compte de résultat & EBE/CAF
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'compte-resultat') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (v_module, 'Le compte de résultat : EBE et CAF', 'compte-resultat', 2, 35,
$l$
Le compte de résultat retrace l'**activité** sur la période (l'exercice), à la différence du bilan qui photographie un instant. Il révèle **comment** vous gagnez (ou perdez) de l'argent.

:::objectifs
- Comprendre la cascade des soldes : VA, EBE, RE, RN.
- Calculer la **CAF** (capacité d'autofinancement).
- Identifier vos **leviers d'amélioration** de marge.
:::

## La cascade des soldes intermédiaires

Voici comment le résultat se construit, **étape par étape** :

```
   Chiffre d'affaires HT
 - Charges externes (carburant, péages, sous-traitance)
 = MARGE BRUTE D'EXPLOITATION
 - Charges de personnel
 - Impôts et taxes
 = EBE (Excédent Brut d'Exploitation)
 - Amortissements
 - Provisions
 = RÉSULTAT D'EXPLOITATION
 - Charges financières (intérêts emprunts)
 + Produits financiers
 = RÉSULTAT COURANT
 + Résultat exceptionnel
 - IS (Impôt sur les Sociétés)
 = RÉSULTAT NET
```

### EBE — Excédent Brut d'Exploitation

**Indicateur clé** : mesure la rentabilité de votre activité sans biais comptables (avant amortissements).

**Cible transport léger** : EBE / CA entre **8 % et 15 %**.
- < 5 % : rentabilité fragile.
- > 15 % : excellent, mais vérifier la durabilité.

### CAF — Capacité d'Autofinancement

$$\\text{CAF} = \\text{Résultat net} + \\text{Amortissements et provisions}$$

C'est l'**argent réel** dégagé par l'activité, disponible pour :
- Rembourser les emprunts.
- Investir dans de nouveaux véhicules.
- Distribuer aux associés.

**Cible** : CAF doit couvrir **les remboursements d'emprunts annuels** + permettre des investissements.

:::caspratique
**TRANSEXPRESS — exercice 2025** :
- CA : 280 000 €
- Charges externes (carburant, entretien) : 95 000 €
- Personnel : 125 000 €
- Impôts/taxes : 8 000 €
- → **EBE = 52 000 €** (18,6 % du CA — excellent)
- Amortissements : 22 000 €
- → Résultat d'exploitation = 30 000 €
- Charges financières (emprunts) : 6 000 €
- → Résultat courant = 24 000 €
- IS (15 % petite entreprise) : 3 600 €
- → **Résultat net = 20 400 €**
- **CAF = 20 400 + 22 000 = 42 400 €**

**Lecture** :
- L'entreprise dégage 42 400 € de CAF.
- Si remboursement emprunts annuels = 18 000 €, il reste **24 400 € pour investir**.
- Ratio EBE/CA = 18,6 % → très bonne santé opérationnelle.
:::

## Améliorer sa marge : 5 leviers

### 1. Augmenter les prix

Le levier le plus rapide. Possible si :
- Votre positionnement le permet.
- Vous avez peu de concurrence directe.
- Vos clients sont fidèles.

**Risque** : perte de quelques clients prix-sensibles. Acceptable si la marge gagnée compense.

### 2. Optimiser les tournées

Réduire les **kilomètres à vide**, mutualiser les courses, optimiser les ordres.

**Impact** : 10-20 % de productivité. Équivalent à augmenter les prix sans rien changer pour le client.

### 3. Renégocier les charges externes

- Carburant : passer en carte pro avec remise.
- Assurances : mise en concurrence tous les 2 ans.
- Téléphonie : forfaits pro mutualisés.
- Maintenance : contrat global moins cher que les interventions ponctuelles.

**Impact** : 5-10 % sur les charges externes. Effort 1-2 jours/an.

### 4. Lutter contre les heures perdues

Mesurer le **temps réellement productif** vs temps total de service.
- Attentes au chargement/déchargement → facturer.
- Trajets à vide → optimiser ou facturer une part.
- Pannes → maintenance préventive.

### 5. Maîtriser les amortissements

Choisir entre :
- **Amortissement linéaire** : étalement régulier sur la durée d'utilisation.
- **Amortissement dégressif** : plus important au début (avantage fiscal).

L'amortissement dégressif **diminue le résultat** des 1ères années → moins d'IS à payer.

:::piege
**Confusion classique** : penser qu'amortir est une charge "vide". Faux. C'est la constatation d'un coût réel : votre véhicule perd de la valeur. Ne pas amortir = se mentir à soi-même.
:::

## En synthèse

| Indicateur | Cible transport léger |
|---|---|
| EBE / CA | 8-15 % |
| CAF | > Remboursements annuels |
| Résultat net / CA | 3-8 % |
:::conseil
Comparez votre EBE/CA aux **moyennes du secteur** (publiées par le CNR). Si vous êtes à 5 % et que la moyenne est à 12 %, vous avez un **vrai potentiel d'amélioration**.
:::
$l$,
$s$
**À retenir**
- Cascade : CA → EBE → Résultat exploitation → Résultat net.
- EBE/CA cible : 8-15 % en transport léger.
- CAF = ressource réelle pour rembourser et investir.
- 5 leviers d'amélioration : prix, tournées, charges, productivité, amortissements.
- Comparer aux moyennes CNR pour identifier les écarts.
$s$);
  END IF;

  -- LEÇON 3 — Coût de revient kilométrique
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'cout-revient-kilometrique') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (v_module, 'Calculer son coût de revient kilométrique (CRK)', 'cout-revient-kilometrique', 3, 35,
$l$
Sans connaître votre **CRK**, vous tarifez à l'aveugle. Vous risquez de perdre de l'argent à chaque course sans le savoir, ou inversement de refuser des contrats rentables. Le CRK est l'**outil de pilotage** numéro 1 du transporteur.

:::objectifs
- Distinguer **charges fixes** vs **charges variables**.
- Calculer son CRK selon **3 méthodes**.
- Utiliser le CRK pour **tarifer** et **arbitrer** ses missions.
:::

## Charges fixes vs charges variables

### Charges fixes — indépendantes du km parcouru

- **Amortissement** du véhicule (mensualités fictives ou réelles).
- **Assurance** auto et RC pro.
- **Loyer** des locaux.
- **Salaires** fixes (chauffeur, gestion).
- **Téléphonie**, comptabilité, expert-comptable.
- **Taxes** (CFE, taxe à l'essieu pour > 3,5 T).
- **Capacité financière** (caution, intérêts).

### Charges variables — proportionnelles au km

- **Carburant** (poste majeur — 30 à 40 % du total).
- **Péages**.
- **Entretien** (vidange, pneus, freins).
- **Pénalités** kilométriques sur leasing.

## Méthode 1 : CRK simplifié

$$\\text{CRK} = \\frac{\\text{Total charges annuelles}}{\\text{Kilomètres parcourus annuels}}$$

**Exemple** :
- Charges totales : 65 000 €/an.
- Km parcourus : 80 000 km.
- **CRK = 0,81 €/km.**

**Limite** : la moyenne masque les écarts (urbain vs longue distance).

## Méthode 2 : CRK ventilé fixe + variable

$$\\text{CRK} = \\frac{\\text{Charges fixes}}{\\text{Km}} + \\text{Charges variables / km}$$

**Exemple** :
- Charges fixes : 35 000 €/an.
- Charges variables : 0,30 €/km (carburant + entretien).
- Si 80 000 km : CRK = (35 000 / 80 000) + 0,30 = **0,74 €/km**.
- Si 50 000 km : CRK = (35 000 / 50 000) + 0,30 = **1,00 €/km**.

**Important** : plus vous roulez, plus le CRK baisse (les charges fixes se répartissent sur plus de km).

## Méthode 3 : CRK CNR (référence sectorielle)

Le **Comité National Routier** publie des **indices** de référence pour le secteur :
- CRK type véhicule utilitaire.
- Évolution mensuelle (gazole, salaires, péages).
- Répartition des postes.

**Avantage** : comparer votre CRK personnel avec la **moyenne du secteur**.

:::caspratique
**Karim — coursier-livraison à Meaux** :

**Charges fixes annuelles** :
- Amortissement véhicule (24 000 € / 5 ans) : 4 800 €
- Assurance + RC : 1 800 €
- Capacité financière + caution : 600 €
- Téléphonie + outils : 600 €
- Taxe CFE : 600 €
- Comptable : 1 800 €
- **Total fixes : 10 200 €**

**Charges variables** :
- Carburant : 0,18 €/km (pour véhicule diesel récent)
- Entretien : 0,06 €/km
- **Total variables : 0,24 €/km**

**Si Karim parcourt 60 000 km/an** :
- CRK fixe : 10 200 / 60 000 = 0,17 €/km
- CRK variable : 0,24 €/km
- **CRK total : 0,41 €/km**

**Si Karim ne parcourt que 30 000 km/an** :
- CRK fixe : 10 200 / 30 000 = 0,34 €/km
- CRK variable : 0,24 €/km
- **CRK total : 0,58 €/km**

**Conclusion** : pour atteindre 60 000 km, Karim DOIT remplir son carnet de commandes. Sinon il vend en perte.
:::

## Utiliser son CRK pour tarifer

### Règle simple

$$\\text{Prix de vente} = \\text{CRK} \\times \\text{Distance} \\times (1 + \\text{Marge})$$

**Marge cible transport léger** : 25 à 40 % selon la concurrence.

### Tarifer un trajet

**Exemple** : course 50 km, CRK = 0,75 €/km, marge cible 30 %.
- Coût : 50 × 0,75 = 37,50 €.
- Marge : 37,50 × 30 % = 11,25 €.
- **Prix de vente : 48,75 € HT** → arrondi 49 € HT.

### Arbitrer une mission

**Question fréquente** : "On me propose une course à 0,55 €/km. J'accepte ?"

**Si CRK = 0,75 €/km** : non, vous perdez 0,20 €/km.
**Si CRK = 0,50 €/km** (forte activité) : oui, marge faible mais positive.

:::piege
**Erreur fatale** : tarifer au "ressenti" sans connaître son CRK. Vous pouvez accepter pendant des mois des missions peu rentables, masquées par la trésorerie courante. Quand le bilan annuel arrive, c'est trop tard : la perte est constatée.
:::

## En synthèse : le tableau de bord

Tenez un **tableau mensuel** avec :

| Mois | Km parcourus | CA | Charges fixes | Charges variables | EBE | CRK calculé |
|---|---|---|---|---|---|---|
| Jan | 5 200 | 6 800 € | 850 € | 1 250 € | 4 700 € | 0,40 € |
| Fév | 4 800 | 5 950 € | 850 € | 1 150 € | 3 950 € | 0,42 € |
| Mar | 6 100 | 7 950 € | 850 € | 1 470 € | 5 630 € | 0,38 € |

**Avantage** : voir vos écarts mensuels et corriger en temps réel.

:::conseil
Recalculez votre CRK **chaque trimestre**. Le carburant, les péages, les salaires évoluent. Un CRK figé = des décisions périmées.
:::
$l$,
$s$
**À retenir**
- CRK = outil de pilotage numéro 1.
- Distinguer charges fixes (constantes) et variables (au km).
- Plus on roule, plus le CRK baisse.
- Comparer avec les indices CNR.
- Tarifer = CRK × distance × (1 + marge cible).
- Recalcul trimestriel obligatoire.
$s$);
  END IF;

  -- LEÇON 4 — Gestion fiscale & TVA
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'gestion-fiscale-tva') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (v_module, 'Gestion fiscale et TVA', 'gestion-fiscale-tva', 4, 35,
$l$
La fiscalité représente typiquement **30 à 40 % du résultat brut**. Bien la maîtriser, c'est légalement optimiser ce qui vous reste. Mal la maîtriser, c'est s'exposer à des **redressements** parfois fatals à l'entreprise.

:::objectifs
- Maîtriser la **TVA** (collectée, déductible, déclarations).
- Comprendre l'**IS** (Impôt sur les Sociétés) et l'IR.
- Identifier les **dispositifs d'optimisation** légaux.
:::

## La TVA : mécanisme

La TVA est un **impôt sur la consommation**, payé in fine par le client final, mais **collecté par l'entreprise**.

### Le calcul de base

```
TVA collectée (sur ventes)
- TVA déductible (sur achats)
= TVA à reverser à l'État
```

### Les taux de TVA

| Taux | Cas |
|---|---|
| **20 %** | Standard (transport, services courants) |
| **10 %** | Restauration, certaines prestations |
| **5,5 %** | Produits alimentaires de base, livres |
| **2,1 %** | Médicaments, presse |

**Pour un transporteur** : taux normal 20 % sur quasi toutes les prestations.

### Périodicité des déclarations

| CA HT annuel | Régime | Périodicité |
|---|---|---|
| < 91 900 € (services) | Franchise en base | Pas de TVA |
| 91 900 - 250 000 € | Réel simplifié | **Annuelle** + acomptes |
| > 250 000 € | Réel normal | **Mensuelle** |

:::piege
**Auto-entrepreneur** sous franchise en base : **vous ne facturez PAS de TVA** au client mais **vous ne récupérez PAS** non plus celle de vos achats. C'est viable seulement si vous avez peu de charges.
:::

### Cas pratique TVA

**TRANSEXPRESS — janvier 2025** :
- Ventes HT : 18 000 €
- TVA collectée 20 % : 3 600 €
- Achats HT : 9 000 € (carburant 5 000 + péages 1 200 + entretien 800 + autres 2 000)
- TVA déductible : 1 800 €
- **TVA à reverser : 3 600 - 1 800 = 1 800 €**

À déclarer et payer avant le 15 du mois suivant.

## L'Impôt sur les Sociétés (IS)

### Taux applicables

| Bénéfice annuel | Taux IS |
|---|---|
| 0 - 42 500 € | **15 %** (taux réduit PME) |
| > 42 500 € | **25 %** (taux normal) |

**Conditions taux réduit** : CA HT < 10 M€ et capital social entièrement libéré.

### Calcul de l'IS

```
Résultat comptable
+ Réintégrations fiscales (charges non déductibles)
- Déductions fiscales (avantages fiscaux)
= Résultat fiscal
× Taux IS
= Impôt dû
```

### Charges non déductibles fiscalement

- Amende et pénalités routières (radar, etc.).
- TVA non récupérée par négligence.
- Cadeaux clients > 73 € TTC/personne/an.
- Repas individuels > 20 € pour le dirigeant.

### Charges déductibles à optimiser

- **Frais de déplacement** réels (notes de frais).
- **Formation continue** des dirigeants et salariés.
- **Cotisations** prévoyance et retraite supplémentaire.
- **Investissements** : amortissements (véhicules, matériel).

:::caspratique
**TRANSEXPRESS — exercice 2025** :
- Résultat comptable : 28 000 €
- Réintégration : 200 € (amende radar) + 350 € (TVA non récupérée)
- Résultat fiscal : 28 550 €
- IS au taux réduit (CA < 10 M, capital libéré) : 28 550 × 15 % = **4 282 €**
:::

## Optimisations légales

### 1. La rémunération du dirigeant

Choisir entre **salaire** et **dividendes** selon votre forme juridique :

**SASU** (assimilé-salarié) :
- Salaire : charges 65-80 %, déductible IS, droits sociaux.
- Dividendes : pas déductibles, 30 % flat tax (PFU).

**EURL/SARL** (TNS) :
- Rémunération : 45 % charges, déductible IS.
- Dividendes : flat tax 30 %, mais cotisations TNS sur la fraction > 10 % du capital.

### 2. Le Plan Épargne Entreprise (PEE)

- Versements de l'entreprise : déductibles IS.
- Pour le bénéficiaire : exonérés d'IR à la sortie (5 ans).

**Conditions** : entreprise ≥ 1 salarié.

### 3. Le PER (Plan Épargne Retraite)

- Versements déductibles IS pour l'entreprise.
- Versements personnels déductibles du revenu imposable (plafond annuel).

### 4. L'amortissement dégressif

Pour les véhicules neufs > 2 T :
- Coefficient 1,75 sur 5 ans → plus d'amortissement les 1ères années.
- Réduit l'IS des 2-3 premiers exercices.

### 5. Le Crédit d'Impôt Formation Dirigeant

10 € × heures de formation dirigeant × SMIC horaire. Cumulable avec les déductions classiques.

:::piege
**Optimisation vs fraude** : la frontière est claire. Vous pouvez **choisir** la voie la moins imposée, mais vous ne pouvez pas **dissimuler** des recettes ou créer des charges fictives. La fraude = délit pénal + redressement + intérêts (~30 % de pénalité).
:::

## Le contrôle fiscal

### Modalités

- Vérification sur pièces (envoi de documents).
- Vérification sur place (présence d'un inspecteur dans l'entreprise).

### Délais de prescription

| Impôt | Prescription |
|---|---|
| TVA | 3 ans |
| IS | 3 ans |
| Fraude grave | 10 ans |

### Préparation

- **Comptabilité tenue à jour** et numérisée.
- **Justificatifs** conservés 6 ans.
- **Lettres de mission** de l'expert-comptable archivées.
- **Procès-verbaux d'AG** signés.

:::conseil
Travaillez avec un **expert-comptable** dès la création. Coût : 1 500-3 000 €/an. Bénéfice : optimisation correcte, sécurisation en cas de contrôle, conseil stratégique. Faire sa compta soi-même est un faux calcul.
:::

## En synthèse

| Sujet | Point-clé |
|---|---|
| TVA | Mensuelle si > 250 k€, annuelle sinon, 20 % standard |
| IS | 15 % jusqu'à 42 500 € (sous conditions), 25 % au-delà |
| Optimisation | Rémunération, PEE, PER, amortissement dégressif, CIF |
| Fraude | Risque = délit pénal + 30 % pénalités |
$l$,
$s$
**À retenir**
- TVA : taux 20 %, déclaration mensuelle si > 250 k€ HT/an.
- IS : 15 % réduit (≤ 42 500 € de bénéfice), 25 % au-delà.
- Optimisations légales : rémunération, PEE/PER, amortissement dégressif, CIF.
- Charges non déductibles : amendes, cadeaux > 73 €.
- Comptabilité à jour + expert-comptable = bouclier en cas de contrôle.
$s$);
  END IF;

  -- LEÇON 5 — Cas pratiques financier
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'cas-pratiques-financier') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (v_module, 'Cas pratiques de synthèse — Financier', 'cas-pratiques-financier', 5, 35,
$l$
4 cas pratiques financiers réalistes.

## Cas n° 1 — L'achat d'un nouveau véhicule

**Situation** : votre entreprise (5 ans d'activité, CRK actuel 0,82 €/km) envisage l'achat d'un VU à 26 000 € HT. Vous parcourez 70 000 km/an. CAF actuelle : 18 000 €/an.

**Question** : auto-financement, emprunt ou leasing ?

:::caspratique
**Analyse** :

**1. Auto-financement (achat cash)** :
- Sortie de trésorerie immédiate : 26 000 €.
- Plus de charges fixes mensuelles.
- Amortissement linéaire 5 ans : 5 200 €/an déductibles IS.
- **Coût annuel comptable : 5 200 €.**
- ⚠️ Réduit fortement votre trésorerie de sécurité.

**2. Emprunt bancaire (5 ans à 4,5 %)** :
- Mensualité ~ 484 € soit 5 808 €/an.
- Coût total : 29 040 € sur 5 ans (3 040 € intérêts).
- Amortissement 5 200 €/an + intérêts 600 €/an déductibles IS.
- **Coût annuel comptable : ~ 5 800 €.**
- ✅ Préserve la trésorerie. Recommandé si CAF couvre les annuités.

**3. Leasing (LOA 5 ans, option d'achat)** :
- Loyer mensuel ~ 520 € soit 6 240 €/an, 100 % déductible.
- Option d'achat finale : 4 000 € (parfois rachat anticipé possible).
- **Coût annuel comptable : 6 240 €.**
- ✅ Prévisible, simplifie la comptabilité.
- ⚠️ Coût total plus élevé sur la durée.

**Recommandation** : si CAF (18 000 €) couvre largement la mensualité (5 800 €), **emprunt bancaire**. Si tendance à manquer de trésorerie : **leasing**. Si capital largement disponible et trésorerie de sécurité après opération : **auto-financement**.
:::

## Cas n° 2 — Le client qui paie à 90 jours

**Situation** : votre principal client (40 % du CA = 90 000 €) paie systématiquement à 90 jours au lieu de 30. Effet sur votre trésorerie ?

:::caspratique
**Calcul de l'impact** :
- 90 000 € × (90/365) = **22 192 €** immobilisés en permanence dans les créances.
- Cette somme est financée par votre BFR (donc par découvert ou par votre fonds de roulement).

**Solutions** :

**1. Renégocier les délais** :
- Légal : délai max B2B = 60 jours (art. L. 441-10 C. commerce).
- Lui rappeler la loi par LRAR pour formaliser la position.
- Proposer un **escompte** (1-2 %) pour paiement à 30 jours.

**2. Affacturage** :
- Vendre les créances à un factor : encaissement immédiat (~ 96 % du montant).
- Coût : 4 % × 90 000 = 3 600 €/an.
- Avantage : zéro problème de trésorerie sur ce client.

**3. Mise en demeure** :
- Si le client est en infraction (> 60 jours), la **DGCCRF** peut sanctionner.
- Risque pour vous : perdre le client. À utiliser en dernier recours.

**Recommandation** : commencer par **escompte 2 % pour paiement à 30 j**. Beaucoup de clients acceptent cette incitation positive.
:::

## Cas n° 3 — La CAF qui s'effondre

**Situation** : votre CAF passe de 35 000 € en 2024 à 8 000 € en 2025. CA stable, mais charges en hausse.

**Question** : que faites-vous ?

:::caspratique
**Diagnostic** :

**Analyser poste par poste** :
- Carburant : +X % vs 2024 ?
- Salaires : nouvelles embauches ou augmentations ?
- Maintenance : véhicule plus vieux qui tombe en panne ?
- Assurance : sinistralité dégradée ?
- Imposition : perte du taux réduit IS ?

**Actions correctives** :

**1. Court terme (3 mois)** :
- Renégocier carburant (carte pro flotte).
- Mise en concurrence assurances.
- Revue des contrats fournisseurs.

**2. Moyen terme (6-12 mois)** :
- Si CAF insuffisante pour rembourser les annuités : **renégocier les emprunts** (étalement, taux).
- Augmenter les prix de 3-5 % sur la prochaine grille tarifaire.
- Réduire les heures perdues (maintenance préventive).

**3. Si la CAF reste insuffisante** :
- Consulter **mandataire ad hoc** (procédure préventive).
- Renégocier l'étalement des dettes URSSAF/fiscales.
- Anticiper avant la cessation des paiements.

**Anticipation** : tenir un **tableau de bord mensuel** EBE/CAF. Détecter les baisses dès le 2ème mois consécutif.
:::

## Cas n° 4 — Le contrôle fiscal sur la TVA

**Situation** : vous recevez une **proposition de rectification** de l'administration fiscale : 12 000 € de TVA non déclarée sur 2 ans + 30 % de pénalités = **15 600 €**.

**Question** : que faites-vous ?

:::caspratique
**Étapes** :

**1. Lecture attentive de la proposition** :
- Quels exercices ?
- Sur quel motif (omission, erreur de taux, ventilation) ?
- Quels sont les droits exigibles + pénalités + intérêts ?

**2. Délai de réponse** : 30 jours pour formuler des observations écrites.

**3. Faire appel** à un **avocat fiscaliste** ou expert-comptable :
- Souvent, des erreurs sont commises par l'administration.
- Une bonne défense réduit de 30-50 % le montant final.

**4. 4 issues possibles** :
- **Acceptation** : vous payez et clôturez.
- **Contestation amiable** : la commission départementale peut médier.
- **Recours hiérarchique** : auprès du chef de service.
- **Recours juridictionnel** : tribunal administratif si désaccord persistant.

**5. Échelonnement** : possible auprès de la trésorerie. Demander un **plan d'apurement** sur 12-24 mois.

**Leçon** : un contrôle, c'est désagréable mais **gérable** avec accompagnement. Ne jamais paniquer ni accepter immédiatement sans relecture.

**Préventif** : tenue rigoureuse de la comptabilité, expert-comptable régulier, déclarations dans les délais. Le contrôle "punit" la négligence, pas l'erreur honnête.
:::

## En synthèse module D

Vous avez maintenant les **4 piliers financiers** :

1. **Lire** un bilan et un compte de résultat.
2. **Calculer** votre CRK et votre EBE/CAF.
3. **Optimiser** légalement votre fiscalité (TVA, IS).
4. **Réagir** aux situations critiques (impayés, baisse CAF, contrôle).

:::conseil
Réservez **1 heure par mois** au pilotage financier (lecture des indicateurs, ajustements). Cette discipline vous évitera la plupart des accidents financiers.
:::
$l$,
$s$
**À retenir — Synthèse module D**
- Achat véhicule : auto-financement / emprunt / leasing selon votre profil.
- Délais clients > 60 jours = illégal en B2B (art. L. 441-10).
- CAF qui baisse = signal d'alerte. Diagnostic mensuel obligatoire.
- Contrôle fiscal : avocat fiscaliste, échelonnement possible.
- 1 heure de pilotage financier par mois = pas d'accident grave.
$s$);
  END IF;

  RAISE NOTICE 'Module D (Capa - Financier) : 5 leçons premium créées.';
END $mod_d$;
