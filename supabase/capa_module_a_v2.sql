-- =====================================================================
-- MODULE A — DROIT CIVIL ET COMMERCIAL (Capacité de transport ≤ 3,5 T)
-- Version 2 (mai 2026) — refonte complète à partir des PDF officiels :
--   - COURS.pdf (Activ-Avenir / MFT, 230 p.)
--   - BASE DE DONNÉES 2026.pdf (694 QCM + 155 QR)
--   - LIVRE DES EXERCICES CAPA LEGERE.pdf
--
-- Référentiel : décision du 2 avril 2012, examen national QCM 14 questions
-- (2 pts/question = 28 pts sur 84 total, seuil 50 % global).
--
-- ▸ 5 leçons rédigées en markdown enrichi (tableaux, callouts, schémas)
-- ▸ ~30 QCM **reformulés** (préfixe source_ref mft-2026:moduleA:qcm:N
--   pour distinguer de l'import brut base-2026:qcm:N)
-- ▸ 6 QR (mises en situation transport, max_score 5)
-- ▸ Quizzes par leçon + quiz d'examen blanc Module A
--
-- Idempotent : DELETE ciblés par module/slug puis INSERT — safe à rejouer.
-- Pré-requis : formation 'capacite-3-5t' présente dans public.formations.
-- =====================================================================

DO $module_a_v2$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_lesson_1 uuid;
  v_lesson_2 uuid;
  v_lesson_3 uuid;
  v_lesson_4 uuid;
  v_lesson_5 uuid;
  v_quiz_1 uuid;
  v_quiz_2 uuid;
  v_quiz_3 uuid;
  v_quiz_4 uuid;
  v_quiz_5 uuid;
  v_quiz_eb uuid;
  v_q uuid;
BEGIN
  -- ─── 1. Pré-requis ─────────────────────────────────────────────────
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'capacite-3-5t';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation capacite-3-5t introuvable. Joue d''abord formations_v2.sql.';
  END IF;

  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN
    RAISE EXCEPTION 'Aucun bloc défini.';
  END IF;

  -- ─── 2. Module : on supprime l'ancien et on recrée propre ─────────
  -- Cascade : supprime aussi lessons, quizzes, formation_modules.
  DELETE FROM public.modules WHERE slug = 'capa-droit-civil-commercial';

  INSERT INTO public.modules (
    title, slug, bloc_id, summary, difficulty, duration_min, "order"
  ) VALUES (
    'Module A — Droit civil et commercial',
    'capa-droit-civil-commercial',
    v_bloc,
    'Les fondamentaux juridiques pour créer et faire vivre une entreprise de transport léger : personnalité juridique, formes de société, facturation, effets de commerce, garanties, recouvrement, procédures collectives.',
    'intermediaire',
    180,
    10
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 10, true)
  ON CONFLICT DO NOTHING;

  -- ─── 3. Banque : reset des questions Module A reformulées ─────────
  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026:moduleA:%';

  -- =================================================================
  -- LEÇON 1 — Le cadre juridique des personnes
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Le cadre juridique des personnes',
    'cadre-juridique-personnes',
    1, 30,
$lesson1$
# Le cadre juridique des personnes

Avant de parler **société**, **facturation** ou **transport**, il faut comprendre une notion fondamentale : qui peut agir en droit, sous quelles conditions, et avec quelles conséquences sur son patrimoine. C'est le **socle** sur lequel reposera toute votre activité de transporteur.

> 🎯 **Objectifs de la leçon**
>
> - Distinguer **personne physique** et **personne morale** dans le contexte transport.
> - Identifier les **4 régimes matrimoniaux** et leur impact sur l'entreprise.
> - Connaître les **conditions d'exercice** d'une activité commerciale (capacité, incompatibilités, interdictions).

---

## 1. La personnalité juridique

La **personnalité juridique** est l'aptitude à être titulaire de droits et d'obligations. C'est elle qui permet à un individu (ou à une société) de **signer un contrat de transport**, **embaucher un chauffeur**, **acheter un véhicule** ou **encaisser une facture**.

Le droit français distingue deux grandes familles de personnes :

| Type | Définition | Exemple transport |
|---|---|---|
| **Personne physique** | Être humain vivant, doté de la personnalité juridique de la naissance au décès | Un coursier auto-entrepreneur |
| **Personne morale** | Groupement reconnu par la loi, doté d'une existence juridique propre | Une SARL de transport régional |

> 💡 **À retenir**
>
> La personnalité juridique d'une **personne physique** est reconnue automatiquement à la naissance (article 6 de la Déclaration universelle des droits de l'homme). Celle d'une **personne morale** s'acquiert le jour de son **immatriculation au RCS** (et **non** à la signature des statuts ou à la publication de l'annonce légale).

### 1.1 Les personnes morales se subdivisent en deux catégories

```
┌──────────────────────────┐
│   PERSONNES MORALES      │
├──────────────────────────┤
│                          │
│  ▸ Droit public          │   → État, communes, hôpitaux
│  ▸ Droit privé           │   → SARL, SAS, EURL, associations…
│                          │
└──────────────────────────┘
```

Une entreprise de transport sera **toujours** une personne morale de **droit privé**.

### 1.2 Les branches du droit qui vous concerneront

| Branche | Champ d'application | Tribunal compétent |
|---|---|---|
| Droit civil | Tous les individus | Tribunal judiciaire |
| Droit commercial | Commerçants et actes de commerce | Tribunal de commerce |
| Droit social | Salariés et employeurs | Conseil de prud'hommes |
| Droit pénal | Infractions et sanctions | Police / correctionnel / assises |

---

## 2. La capacité juridique

Toute personne physique n'a pas automatiquement le droit d'agir librement. On distingue :

- **Personnes capables** : majeurs sains d'esprit, mineurs émancipés autorisés.
- **Personnes incapables** : mineurs non émancipés, majeurs sous tutelle ou curatelle.

Les personnes incapables ont la **capacité de jouissance** (elles possèdent des droits) mais pas la **capacité d'exercice** (elles ne peuvent pas exercer ces droits sans représentant légal).

> 🚛 **Cas transport**
>
> Vous avez 17 ans et vous voulez créer votre entreprise de coursier vélo. **Impossible** sans **émancipation prononcée par le juge des tutelles**. Une fois émancipé, vous pouvez vous immatriculer et conduire votre activité.

---

## 3. Les régimes matrimoniaux

C'est le chapitre que les futurs transporteurs **négligent toujours**, jusqu'au jour où une saisie sur le compte joint leur prouve qu'ils auraient dû y réfléchir avant. Le régime matrimonial détermine **comment vos biens et vos dettes circulent entre vous et votre conjoint** pendant le mariage et lors de sa dissolution.

| Régime | Choix | Biens propres | Biens communs | Dettes |
|---|---|---|---|---|
| **Communauté réduite aux acquêts** | Par défaut (sans contrat) | Avant mariage + dons/successions | Acquis pendant mariage à titre onéreux | Communes |
| **Communauté universelle** | Contrat | Aucun (tout est commun) | Tout, présent et à venir | Toutes communes |
| **Séparation de biens** | Contrat | Tout reste propre | Aucun | Personnelles (sauf ménage / enfants) |
| **Participation aux acquêts** | Contrat | Comme séparation | Aucun pendant le mariage, partage à la dissolution | Personnelles |

### 3.1 Quel régime pour un futur transporteur ?

> ⚠️ **Conseil pratique**
>
> Si vous comptez créer une **entreprise individuelle** (EI) ou une **SARL avec apports personnels importants**, le régime de la **séparation de biens** protège votre conjoint des dettes professionnelles. Sans ce contrat, en cas de défaillance et de communauté légale par défaut, le créancier peut saisir les biens communs (compte joint, voiture du couple, résidence secondaire).

Il existe une exception majeure : avec la **création depuis 2022 du statut unique de l'entrepreneur individuel**, le patrimoine personnel est désormais **automatiquement** séparé du patrimoine professionnel, même sans déclaration EIRL. Cette protection limite les saisies aux seuls biens utilisés pour l'activité.

---

## 4. La capacité de commerçant

Avoir la capacité juridique ne suffit pas pour devenir commerçant. Il faut en plus **ne tomber sous aucune incompatibilité ni interdiction**.

### 4.1 Les incompatibilités : 6 professions exclues

```
                  ┌─────────────────────────┐
                  │  ACTIVITÉ COMMERCIALE   │
                  │      INTERDITE          │
                  └────────────┬────────────┘
                               │
        ┌──────────────────────┼──────────────────────┐
        │                      │                      │
   Fonctionnaire         Officier ministériel      Avocat
   (statut)              (notaire, huissier)
        │                      │                      │
   ────┴──────────────────┴──────────────────┴────
        │                      │                      │
   Commissaire           Architecte            Mineur émancipé
   aux comptes           (en exercice)         sans autorisation
   et expert-comptable
```

### 4.2 Les interdictions : faillite personnelle

Lors d'un **redressement** ou d'une **liquidation judiciaire**, le tribunal peut prononcer une **faillite personnelle** contre le dirigeant, en complément d'une **interdiction de gérer**.

| Élément | Détail |
|---|---|
| Durée maximale faillite personnelle | **15 ans** |
| Durée maximale interdiction de gérer (par procédure) | **5 ans** |
| Inscription | Fichier national des interdits de gérer (depuis 2016, géré par le **CNGTC**) |

Une personne sous interdiction **ne peut ni** créer une entreprise individuelle, **ni** diriger / administrer / gérer / contrôler une société commerciale (SARL, SA, SAS, SNC…).

> 📌 **À retenir**
>
> Le **Fichier national des interdits de gérer** est consultable par les greffes lors de toute demande d'immatriculation. Une fausse déclaration à ce sujet est un **délit pénal**.

---

## 🧠 Synthèse de la leçon

| Notion | À mémoriser |
|---|---|
| Personnalité juridique | Tous les humains ; les sociétés à compter de l'**immatriculation au RCS** |
| Personnes morales | Droit public (État, communes) ou droit privé (SARL, SAS…) |
| Capacité juridique | Capacité de jouissance ≠ Capacité d'exercice |
| Régime matrimonial par défaut | **Communauté réduite aux acquêts** |
| Régime protecteur pour entrepreneur | **Séparation de biens** |
| Activité commerciale | Interdite à 6 professions et aux interdits de gérer |
| Faillite personnelle | Jusqu'à **15 ans**, inscription Fichier national CNGTC |
$lesson1$,
'Comprendre qui peut exercer une activité commerciale, sous quel régime juridique et matrimonial, et comment éviter les pièges de la confusion patrimoniale.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Créer son entreprise de transport
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Créer son entreprise de transport',
    'creation-entreprise-transport',
    2, 50,
$lesson2$
# Créer son entreprise de transport

C'est **le** chapitre le plus structurant de votre parcours. Le choix de la forme juridique conditionne votre **fiscalité**, votre **protection sociale**, votre **responsabilité** sur les dettes et votre **capacité à investir**. On va voir comment ne pas se tromper.

> 🎯 **Objectifs de la leçon**
>
> - Maîtriser les **8 étapes** de la création d'entreprise.
> - Comparer les **5 formes juridiques** adaptées au transport léger : EI, EURL, SARL, SASU, SAS.
> - Choisir la bonne forme selon : nombre d'associés, capital, régime fiscal, régime social, responsabilité.

---

## 1. Les 8 étapes incontournables

```
   1. L'IDÉE                    (intuition, expérience terrain)
        ↓
   2. LE PROJET PERSONNEL       (cohérence avec votre vie)
        ↓
   3. L'ÉTUDE DE MARCHÉ         (clients, concurrents, prix)
        ↓
   4. LES PRÉVISIONS FINANCIÈRES (chiffrage de la viabilité)
        ↓
   5. TROUVER DES FINANCEMENTS  (apports, prêts, aides)
        ↓
   6. LES AIDES À LA CRÉATION   (ACRE, NACRE, prêts d'honneur)
        ↓
   7. CHOISIR UN STATUT JURIDIQUE  ← La pierre angulaire
        ↓
   8. LES FORMALITÉS             (INPI, banque, KBIS, licence)
```

### 1.1 Les formalités côté transporteur (focus terrain)

Pour le transporteur léger ≤ 3,5 T, les formalités vont au-delà du simple INPI. Voici l'ordre **réel** :

```
┌─ Établir un business plan
├─ Choisir un statut juridique
├─ Rédiger un projet de statuts
├─ Rendez-vous banque pour DÉPÔT DE CAPITAL
├─ Attendre l'attestation de dépôt de capital
├─ Demande d'autorisation d'exercer la profession
│  (avec un expert-comptable ou centre de gestion agréé)
├─ Attendre l'accusé réception de la DREAL/DRIEAT
├─ Faire paraître une ANNONCE LÉGALE
├─ Enregistrer la société sur le PORTAIL INPI (e-procédures.inpi.fr)
├─ Attendre le KBIS (extrait d'immatriculation au RCS)
├─ Envoyer le KBIS à la DREAL/DRIEAT
└─ Attendre les LICENCES de transport
```

> ⚠️ **Important depuis 2023**
>
> Les **CFE (Centres de formalités des entreprises) sont supprimés**. Toutes les démarches se font désormais sur le **portail e-procédures de l'INPI** (`procedures.inpi.fr`).

---

## 2. Les 5 formes juridiques adaptées au transport léger

| Forme | Associés | Capital min. | Responsabilité | Fiscalité par défaut | Régime social dirigeant |
|---|---|---|---|---|---|
| **EI** (Entrepreneur Individuel) | 1 | 0 € | Limitée au patrimoine pro depuis 2022 | IR | TNS (≈45 % du revenu) |
| **EURL** | 1 | 1 € libre | Limitée aux apports | IR (option IS) | TNS si associé unique gérant |
| **SARL** | 2 à 100 | 1 € libre | Limitée aux apports | IS (option IR sous conditions) | TNS si gérant majoritaire / Assimilé salarié sinon |
| **SASU** | 1 | 1 € libre | Limitée aux apports | IS (option IR 5 ans max) | Assimilé salarié |
| **SAS** | 1 et + | 1 € libre | Limitée aux apports | IS (option IR 5 ans max) | Assimilé salarié |

### 2.1 EI — Entrepreneur Individuel

**Pour qui ?** Le coursier solo qui démarre, l'artisan-livreur qui veut tester son marché.

| Caractéristique | Détail |
|---|---|
| Création | Aucun statuts à rédiger, aucun capital |
| Responsabilité | Patrimoine professionnel **séparé automatiquement** du personnel (loi du 14 février 2022) |
| Fiscalité | Bénéfices imposés à l'**IR** dans la catégorie BIC. Option IS possible (assimilation EURL). |
| Social | TNS (Travailleur Non Salarié) — cotisations ≈ 45 % du revenu |

> 💡 **Avantage** : simplicité maximale, pas de statuts, pas d'AG.
> ⚠️ **Limite** : si vous voulez accueillir un associé, il faudra basculer vers EURL/SARL.

### 2.2 EURL — Société Unipersonnelle à Responsabilité Limitée

**Pour qui ?** Le créateur seul qui veut une **vraie société** mais sans associé.

| Caractéristique | Détail |
|---|---|
| Associés | **1 seul** (personne physique ou morale) |
| Capital | Libre, **20 % minimum** libérés à la création, solde sur 5 ans |
| Apports | Numéraire, nature, industrie (industrie hors capital) |
| Responsabilité | Limitée aux apports (sauf faute de gestion / caution perso) |
| Fiscalité | **IR par défaut** — option IS possible |
| Régime social | TNS si gérant associé unique ; Assimilé salarié si gérant tiers |

### 2.3 SARL — Société à Responsabilité Limitée

**Pour qui ?** Plusieurs associés (2 à 100), modèle classique du transport familial.

| Caractéristique | Détail |
|---|---|
| Associés | **2 à 100** |
| Capital | Libre, **20 % minimum** libérés, solde sur 5 ans |
| Responsabilité | Limitée aux apports (sauf faute de gestion / caution) |
| Fiscalité | **IS par défaut** — option IR possible : SARL de famille OU SARL de moins de 5 ans (4 conditions) |
| Régime social du gérant | Dépend du % de parts détenues |

#### Les 3 statuts du gérant de SARL

| Statut | Parts détenues | Régime social |
|---|---|---|
| **Minoritaire** | < 50 % | Régime général Sécurité sociale (assimilé salarié) |
| **Égalitaire** | 50 % | Régime général Sécurité sociale |
| **Majoritaire** | > 50 % (50 % + 1 part) | Régime des indépendants (TNS) |

> 🚛 **Cas pratique transport**
>
> Trois associés X, Y, Z créent une SARL.
> - X apporte 4 500 € en espèces
> - Y apporte un terrain évalué à 10 000 €
> - Z apporte 3 100 € + un véhicule évalué à 9 000 €
>
> Total des apports : 26 600 €. Z détient 12 100 / 26 600 = **45,5 %** → gérant **minoritaire** s'il est nommé seul gérant. Donc régime **assimilé salarié**.

### 2.4 SASU et SAS — Sociétés par Actions Simplifiées

**Pour qui ?** Créateurs cherchant **flexibilité statutaire** + **régime salarié** + **levée de fonds future**.

| Critère | SASU | SAS |
|---|---|---|
| Associés | 1 unique | 1 minimum, pas de max |
| Capital | 1 € minimum | 1 € minimum |
| Libération du capital | **50 % à la création**, solde sous 5 ans | **50 % à la création**, solde sous 5 ans |
| Responsabilité | Limitée aux apports | Limitée aux apports |
| Fiscalité | IS par défaut, option IR 5 ans max | IS par défaut, option IR 5 ans max |
| Statut social du président | Assimilé salarié (régime général) | Assimilé salarié |
| Avantage clé | **Flexibilité statutaire totale** | **Idéale pour ouvrir le capital** |

> ⚠️ **Apports en nature en SAS/SASU**
>
> Évaluation par un **commissaire aux apports** obligatoire si **2 conditions cumulées** :
> - un apport en nature > 30 000 € **ET**
> - les apports en nature > 50 % du capital social total

---

## 3. Comment trancher ? L'arbre de décision

```
                    ┌────────────────────────┐
                    │  Combien d'associés ?  │
                    └──────────┬─────────────┘
                               │
                  ┌────────────┴────────────┐
                  │                         │
              1 SEUL                   2 ou +
                  │                         │
        ┌─────────┴─────────┐               │
        │                   │               │
   Simplicité ?       Flexibilité ?    Plusieurs ?
        │                   │               │
        ▼                   ▼               ▼
       EI                 SASU       ┌──────┴──────┐
       ou                 ou         │             │
      EURL                EURL     SARL          SAS
                          (TNS)   (familial)  (flexible)
```

> 📌 **Les 3 critères clés**
>
> 1. **Régime social** : TNS (45 %, moins de protection) vs assimilé salarié (75 %, mieux couvert)
> 2. **Fiscalité** : IR (transparent, plafonné en cas de bénéfices élevés) vs IS (taux fixe 15-25 %)
> 3. **Responsabilité** : illimitée historique de l'EI **vs** limitée aux apports (sociétés)

---

## 🧠 Synthèse de la leçon

| Question | Réponse rapide |
|---|---|
| Capital minimum SAS/SASU | **1 €** |
| Libération du capital SAS/SASU à la création | **50 %** |
| Libération du capital SARL/EURL à la création | **20 %** |
| Délai pour libérer le solde | **5 ans** après immatriculation |
| Forme juridique sans personnalité morale | **EI** (rattachée à la personne physique) |
| Régime social par défaut du gérant majoritaire de SARL | **TNS** |
| Régime social par défaut du président de SAS | **Assimilé salarié** |
| Fiscalité par défaut SARL / SAS / SASU | **IS** |
| Fiscalité par défaut EI / EURL | **IR** |
| Portail unique pour les formalités | **e-procédures.inpi.fr** |
$lesson2$,
'Comparer les 5 formes juridiques (EI, EURL, SARL, SASU, SAS) selon associés, capital, fiscalité, social, responsabilité — et savoir choisir.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Vendre, facturer, sécuriser ses encaissements
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Vendre, facturer, sécuriser ses encaissements',
    'facturation-effets-commerce',
    3, 35,
$lesson3$
# Vendre, facturer, sécuriser ses encaissements

Dans le transport, la facture n'est pas un simple papier : c'est une **preuve juridique**, un **support comptable**, et la base de votre **TVA**. Une facture mal rédigée, c'est une créance fragile devant le tribunal. Et si le client traîne pour payer, vous avez d'autres outils que la simple relance : les **effets de commerce**.

> 🎯 **Objectifs de la leçon**
>
> - Connaître les **17 mentions obligatoires** d'une facture (et les **4 ajouts depuis juillet 2024**).
> - Maîtriser les délais de paiement légaux et l'indemnité forfaitaire.
> - Distinguer la **lettre de change** du **billet à ordre**.
> - Comprendre l'intérêt de **l'escompte** pour la trésorerie.

---

## 1. La facture : 17 mentions obligatoires

La facture remplit **3 rôles** :

```
┌─────────────────────┐    ┌──────────────────────┐    ┌──────────────────────┐
│  PREUVE JURIDIQUE   │    │  JUSTIFICATIF        │    │  SUPPORT TVA         │
│  (litige, contrat)  │ +  │  COMPTABLE           │ +  │  (collecte/déduct.)  │
└─────────────────────┘    └──────────────────────┘    └──────────────────────┘
```

### 1.1 Les 17 mentions imposées par le Code de commerce

| # | Mention | Détail |
|---|---|---|
| 1 | Date d'émission | |
| 2 | Numéro de facture | Séquence chronologique unique |
| 3 | Date de la vente / prestation | |
| 4 | Identité du vendeur | Raison sociale, forme, capital |
| 5 | Identité du client | Nom / société |
| 6 | Adresse vendeur | Siège social |
| 7 | Adresse client | |
| 8 | Adresse de livraison | |
| 9 | Adresse de facturation | Si différente de livraison |
| 10 | Numéro du bon de commande | Le cas échéant |
| 11 | Description et prix des produits/services | |
| 12 | Mode et date de paiement | |
| 13 | Taux de TVA | Et montant |
| 14 | Total à payer | TTC |
| 15 | Conditions d'escompte | Pour paiement anticipé |
| 16 | Taux des pénalités de retard | Échéance par défaut **30 jours** |
| 17 | Indemnité forfaitaire de **40 €** | Pour frais de recouvrement |

### 1.2 Les 4 ajouts du décret n° 2022-1299 (depuis 1er juillet 2024)

> 📌 **Nouveautés à intégrer**
>
> 1. Numéro **SIREN/SIRET** du client
> 2. Adresse de livraison si différente de l'adresse de facturation
> 3. Type d'opération : **livraison de biens / prestation de services / mixte**
> 4. Option de paiement de la TVA d'après les débits

### 1.3 Délai de paiement par défaut

| Situation | Délai |
|---|---|
| Aucune mention au contrat | **30 jours** à réception |
| Convention entre parties | Maximum **60 jours** date d'émission ou **45 jours fin de mois** |
| Transport routier de marchandises | **30 jours fin de décade** (article L. 441-11 Code de commerce) |

---

## 2. Les effets de commerce

Un **effet de commerce** est un titre par lequel un créancier (le **tireur**) ordonne à un débiteur (le **tiré**) de payer une somme à une **échéance précise** (généralement < 90 jours).

```
┌──────────────┐                         ┌──────────────┐
│   TIREUR     │ ─── ordre de payer ──→  │     TIRÉ     │
│  (créancier) │                         │  (débiteur)  │
└──────────────┘                         └──────────────┘
        ↑                                        │
        │                                        │
        └─────── paiement à échéance ────────────┘
```

### 2.1 Les 6 mentions obligatoires sur un effet de commerce

1. Lieu et date de réalisation
2. Désignation du **tireur**
3. Désignation du **tiré**
4. Montant de la créance
5. Échéance du paiement
6. Lieu où le paiement doit être effectué
7. Signature du créancier (tireur) et du débiteur (tiré)

### 2.2 Les deux types d'effets

| Effet | Qui rédige ? | Qui paie ? | Signe d'acceptation |
|---|---|---|---|
| **Lettre de change (traite)** | Le **tireur** (créancier) | Le **tiré** (débiteur) | Le tiré accepte par signature |
| **Billet à ordre** | Le **souscripteur** (= acheteur / débiteur) | Lui-même au porteur | Engagement direct du débiteur |

> 💡 **Mémo facile**
>
> - **Lettre de change** : c'est **moi (vendeur) qui écris** au client pour lui dire « payez X € le Y ».
> - **Billet à ordre** : c'est **le client qui écrit** au vendeur pour s'engager à payer.

### 2.3 L'escompte : convertir un effet en cash immédiat

L'**escompte** consiste à vendre l'effet à votre **banque** avant l'échéance. Vous récupérez la somme **immédiatement**, moins les agios (frais bancaires).

```
   J0          J+30                 J+60
   │            │                    │
   │ Vente      │ Escompte           │ Échéance
   │ + traite   │ banque             │ initiale
   │ 60j        │ → cash − agios     │
   │            │                    │
   ▼            ▼                    ▼
  Facture   Trésorerie immédiate  Encaissement
                                  par la banque
```

| Avantage | Inconvénient |
|---|---|
| Cash immédiat | Frais d'agio |
| Garantie de paiement à échéance | Si le tiré ne paie pas, la banque vous redemande la somme |
| Outil de gestion de trésorerie pour le tiré aussi | Lourdeur administrative |

### 2.4 L'endossement

**Endosser** un effet, c'est **transmettre le bénéfice** de l'effet à un tiers (par signature au dos). Très pratique pour payer un fournisseur sans sortir de cash.

---

## 🧠 Synthèse de la leçon

| Question | Réponse rapide |
|---|---|
| Délai de paiement par défaut | **30 jours** à réception |
| Indemnité forfaitaire frais de recouvrement | **40 €** |
| Mentions sur facture (avant juillet 2024) | **17** |
| Nouveautés depuis juillet 2024 | SIREN client, type d'opération, etc. |
| Lettre de change : qui la rédige ? | Le **tireur** (créancier) |
| Billet à ordre : qui s'engage ? | Le **souscripteur** (acheteur) |
| Durée typique d'un effet de commerce | **< 90 jours** |
| Vendre une traite à sa banque = | **Escompte** |
| Transmettre une traite à un tiers = | **Endossement** |
$lesson3$,
'Maîtriser les mentions obligatoires de la facture, les délais légaux, et les outils de paiement (lettre de change, billet à ordre, escompte).'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Garantir et recouvrer ses créances
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Garantir et recouvrer ses créances',
    'garanties-recouvrement',
    4, 35,
$lesson4$
# Garantir et recouvrer ses créances

Quand on prête de l'argent à un client (ce que vous faites à chaque facture émise sans paiement comptant), il faut **se protéger contre l'insolvabilité**. Et quand le client ne paie pas, il faut savoir **récupérer son dû** sans y laisser plus que la créance.

> 🎯 **Objectifs de la leçon**
>
> - Différencier **sûretés personnelles** et **sûretés réelles**.
> - Maîtriser **caution**, **gage**, **nantissement**, **hypothèque**.
> - Connaître les étapes du **recouvrement amiable** et **judiciaire**.
> - Savoir quand faire appel à une **agence de recouvrement** ou à l'**affacturage**.

---

## 1. Les sûretés (garanties)

Une **sûreté** est un mécanisme juridique qui permet au créancier d'être payé **par préférence** en cas de défaillance du débiteur. Il existe deux grandes familles :

```
                    ┌─────────────────┐
                    │     SÛRETÉS     │
                    └────────┬────────┘
                             │
                ┌────────────┴────────────┐
                │                         │
       SÛRETÉS PERSONNELLES        SÛRETÉS RÉELLES
       (engagement d'un tiers)     (un bien sert de gage)
                │                         │
       ┌────────┴────────┐    ┌───────────┼─────────────┐
       │                 │    │           │             │
    Caution       Caution      Gage    Nantissement   Hypothèque
    (personne)    bancaire    (bien    (valeurs        (immeuble)
                              meuble)   mobilières /
                                        incorporelles)
```

### 1.1 Sûretés personnelles : caution et caution bancaire

| Type | Qui se porte garant ? | Cas typique |
|---|---|---|
| **Caution simple** | Personne physique (vous-même, conjoint, parent) ou morale | Banquier exige une caution perso pour un prêt pro |
| **Caution bancaire** | Une banque ou un organisme spécialisé | Bailleur commercial exige une caution bancaire pour un loyer |

> ⚠️ **Le piège classique du transporteur**
>
> Vous créez une SARL avec une responsabilité limitée aux apports. Mais à l'ouverture du prêt bancaire, le banquier vous demande de vous porter **caution personnelle**. Vous signez. Bingo : votre patrimoine personnel redevient engagé pour la totalité du prêt. **Lisez ce que vous signez avant.**

### 1.2 Sûretés réelles : gage, nantissement, hypothèque

| Sûreté | Type de bien | Spécificité |
|---|---|---|
| **Gage** | Bien **mobilier corporel** (véhicule, stock, matériel) | Avec ou sans dépossession du débiteur |
| **Nantissement** | Bien **mobilier incorporel** (parts sociales, fonds de commerce, créances) | Aussi appelé "gage de valeurs mobilières" |
| **Hypothèque** | Bien **immobilier** | Acte **notarié obligatoire** sous peine de nullité |

#### Le gage en détail

```
   ┌─────────────────────────────────┐
   │           LE GAGE               │
   ├─────────────────────────────────┤
   │                                 │
   │  AVEC dépossession              │
   │   ▸ Le bien va chez un tiers    │
   │     "tiers gagiste"             │
   │   ▸ Publicité sur le site       │
   │                                 │
   │  SANS dépossession              │
   │   ▸ Le débiteur garde le bien   │
   │   ▸ Publicité au greffe         │
   │     du tribunal de commerce     │
   │                                 │
   │  Dans les 2 cas :               │
   │   ✓ Pas de transfert de prop.   │
   │   ✓ Le créancier peut devenir   │
   │     propriétaire si défaillance │
   │                                 │
   └─────────────────────────────────┘
```

> 🚛 **Cas transport**
>
> Vous achetez un VUL (véhicule utilitaire léger) à crédit. La banque inscrit un **gage automobile** sans dépossession au greffe du tribunal de commerce. Vous gardez le véhicule, vous l'utilisez normalement. Mais si vous arrêtez de rembourser, la banque peut le récupérer et le revendre.

#### L'hypothèque

L'**acte de constitution doit être notarié** sous peine de nullité. Confère deux droits au créancier :

- **Droit de préférence** : être payé avant les créanciers chirographaires.
- **Droit de suite** : poursuivre la vente du bien même s'il a été revendu.

---

## 2. Le recouvrement de créances

Quand un client ne paie pas, vous avez **deux voies** :

```
                  ┌─────────────────────┐
                  │   RECOUVREMENT      │
                  └──────────┬──────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
       RECOUVREMENT INTERNE         RECOUVREMENT EXTERNE
       (Service contentieux)        (Société de recouvrement,
                                     huissiers, avocats)
                │                             │
                ├─ Lettre de relance          ├─ Phoning
                ├─ Mise en demeure            ├─ Courriers AR
                ├─ Injonction de payer        ├─ Visite sur site
                └─ Action en paiement         └─ Action judiciaire
```

### 2.1 Les 3 étapes amiables

| Étape | Outil | Effet |
|---|---|---|
| 1️⃣ | **Lettre de relance** simple, ton courtois | Rappelle l'oubli, identifie le motif du retard |
| 2️⃣ | **Mise en demeure** par LRAR | Sommation formelle, déclenche les pénalités |
| 3️⃣ | **Cabinet de recouvrement** (FIGEC) | Externalise la pression amiable |

### 2.2 Le recouvrement judiciaire : l'injonction de payer

Procédure **non contradictoire** (le débiteur n'est pas convoqué), **rapide** et **peu onéreuse** (≈ 40 €), qui permet d'obtenir un **titre exécutoire** sans avocat.

| Caractéristique | Détail |
|---|---|
| Tribunal compétent | Tribunal de commerce du **domicile du débiteur** (créance commerciale) |
| Coût | ≈ 40 € |
| Avocat obligatoire ? | **Non** |
| Durée | Quelques semaines en général |

> 🚛 **Cas transport**
>
> Une entreprise lilloise (vous) doit recouvrer une créance auprès d'un commerçant brestois. La requête en injonction de payer doit être adressée au **Tribunal de commerce de Brest** (domicile du débiteur), pas Lille (votre siège).

### 2.3 L'agence de recouvrement : 3 étapes structurées

```
┌───────────────────────────────────────────────────┐
│  ÉTAPE 1 — RECUEIL D'INFORMATIONS                 │
│  Enquête sur historique, solvabilité, raison du   │
│  non-paiement                                     │
├───────────────────────────────────────────────────┤
│  ÉTAPE 2 — RELANCE AMIABLE                        │
│  Courriers / phoning / visite (selon montant)     │
├───────────────────────────────────────────────────┤
│  ÉTAPE 3 — DÉCISION                               │
│  • Règlement total/partiel  • Rééchelonnement     │
│  • Procédure judiciaire     • Irrécouvrable       │
└───────────────────────────────────────────────────┘
```

### 2.4 L'affacturage : externaliser ET financer

L'**affacturage** = vous cédez vos créances clients à un **factor**. Il vous **avance** la somme (souvent 90 %) immédiatement, gère le recouvrement, et vous garantit contre l'impayé. Particulièrement utile dans le transport où les délais clients sont souvent longs.

| Avantage | Inconvénient |
|---|---|
| Trésorerie immédiate | Coût (commission 1 à 3 % du CA cédé) |
| Externalisation totale du recouvrement | Engagement de durée |
| Assurance contre les impayés | Dépendance financière |
| Outil de financement court terme | Le client sait que vous êtes affacturé |

---

## 🧠 Synthèse de la leçon

| Question | Réponse rapide |
|---|---|
| Sûreté basée sur l'engagement d'une personne | **Sûreté personnelle** (caution) |
| Sûreté basée sur un bien | **Sûreté réelle** (gage, nantissement, hypothèque) |
| Garantie sur un bien meuble corporel | **Gage** |
| Garantie sur un bien meuble incorporel | **Nantissement** |
| Garantie sur un immeuble | **Hypothèque** (acte notarié obligatoire) |
| Procédure judiciaire rapide et peu chère | **Injonction de payer** (≈ 40 €) |
| Tribunal compétent pour injonction commerciale | Tribunal de commerce du **domicile du débiteur** |
| Externalisation + financement des créances | **Affacturage** |
$lesson4$,
'Connaître les sûretés (caution, gage, nantissement, hypothèque) et les procédures de recouvrement amiable et judiciaire.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- LEÇON 5 — Difficultés et juridictions
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Difficultés de l''entreprise et juridictions',
    'procedures-collectives-tribunaux',
    5, 30,
$lesson5$
# Difficultés de l'entreprise et juridictions

Les premières années d'une entreprise de transport sont **statistiquement les plus risquées**. Connaître les procédures de prévention et de traitement des difficultés peut **sauver votre activité** — ou au minimum vous éviter des sanctions personnelles graves.

> 🎯 **Objectifs de la leçon**
>
> - Identifier le seuil d'alerte des **capitaux propres < 50 % du capital**.
> - Distinguer **sauvegarde**, **redressement** et **liquidation judiciaire**.
> - Connaître la composition et les compétences du **tribunal de commerce**.

---

## 1. Le seuil critique : capitaux propres < 50 % du capital

C'est l'**indicateur d'alerte** du Code de commerce. Quand il se déclenche, une procédure spécifique s'enclenche.

### 1.1 Calcul des capitaux propres

```
   Capitaux propres = Capital social
                    + Réserves
                    + Bénéfices non distribués (exercices antérieurs)
                    + Bénéfice de l'exercice
                    + Provisions réglementées
                    − Pertes (cumulées)
```

### 1.2 La procédure de l'article L. 223-42 (SARL) / L. 225-248 (SA)

```
   Constat des pertes : Capitaux propres < 50 % du capital social
        │
        ▼
   AGE (Assemblée Générale Extraordinaire) dans les 4 mois suivant l'AG
   d'approbation des comptes de l'exercice déficitaire
        │
        ▼
   ┌────────────────┬──────────────────┐
   │                │                  │
 DISSOUDRE     POURSUIVRE        Régulariser dans les 2 ans
 immédiatement  malgré pertes    suivant la clôture du 2e exercice
```

> 📌 **Entreprises concernées**
>
> SARL, EURL, SA, SAS, SCA. (L'EI n'est pas concernée car elle n'a pas de capital social.)

---

## 2. Les 3 procédures collectives

| Procédure | État de l'entreprise | Initiative | Objectif |
|---|---|---|---|
| **Sauvegarde** | Difficultés sans cessation de paiement | Le débiteur uniquement | Réorganiser et payer les créanciers |
| **Redressement judiciaire** | Cessation de paiement, mais redressement possible | Débiteur, créanciers, procureur, tribunal d'office | Sauver l'entreprise |
| **Liquidation judiciaire** | Cessation de paiement + redressement impossible | Débiteur, créanciers, procureur, tribunal d'office | Vendre les actifs et désintéresser les créanciers |

### 2.1 La cessation de paiement

> 💡 **Définition légale**
>
> L'**impossibilité de faire face au passif exigible avec son actif disponible**.
>
> Ce n'est **pas** : la perte de la moitié du capital, une mauvaise comptabilité, une pénurie ponctuelle de cash.

Une fois en cessation de paiement, le dirigeant a **45 jours** pour déclarer la cessation au tribunal (sous peine de **sanctions personnelles**).

### 2.2 La sauvegarde : prévention

```
┌─────────────────────────────────────────────────────────┐
│  PROCÉDURE DE SAUVEGARDE                                │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Conditions cumulées :                                  │
│   ✓ Difficultés que l'entreprise ne peut surmonter      │
│   ✓ PAS encore en cessation de paiement                 │
│                                                         │
│  Effet : suspension des poursuites, période             │
│  d'observation pour bâtir un plan de sauvegarde         │
│                                                         │
│  Avantage : maintien de l'activité ET de l'emploi       │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 2.3 La conciliation : avant la procédure

Démarche **amiable** où un conciliateur (désigné par le tribunal) cherche un **accord** entre l'entreprise et ses principaux créanciers : délais de paiement, remises de dettes…

---

## 3. Le tribunal de commerce

### 3.1 Composition particulière

Contrairement aux autres tribunaux, le tribunal de commerce est composé de **juges non professionnels** appelés **juges consulaires** :

| Caractéristique | Détail |
|---|---|
| Statut | **Bénévoles** |
| Recrutement | Choisis parmi commerçants ou dirigeants d'entreprises |
| Désignation | **Élus** par leurs pairs (commerçants) |
| Effectif minimum par jugement | **3 juges** |
| Ministère public | Représente la société, **obligatoirement présent** dans les dossiers d'entreprises en difficulté |

### 3.2 Compétences du tribunal de commerce

Il juge :

1. Les **litiges entre entreprises** (commerce, concurrence, droit communautaire)
2. Les **actes de commerce** entre toutes personnes
3. Les **lettres de change**
4. Les **litiges particuliers vs commerçants** dans l'exercice du commerce
5. Les **contestations entre associés** d'une société commerciale
6. Les **procédures collectives** (sauvegarde, redressement, liquidation)

### 3.3 Voies de recours

```
   Tribunal de commerce
        │
        ├──→ Cour d'appel (litige > 5 000 €)
        │       │
        │       └──→ Cour de cassation (en droit, pas en fait)
        │
        └──→ Pas d'appel possible si litige ≤ 5 000 €
            (jugement en dernier ressort)
```

---

## 🧠 Synthèse de la leçon

| Question | Réponse rapide |
|---|---|
| Seuil critique des capitaux propres | < **50 %** du capital social |
| Délai pour réunir l'AGE après constat | **4 mois** suivant l'AG d'approbation |
| Délai pour régulariser | **2 exercices** après celui de la perte |
| Procédure préventive sans cessation de paiement | **Sauvegarde** |
| Procédure quand l'entreprise est en cessation mais peut être sauvée | **Redressement judiciaire** |
| Procédure quand l'entreprise est en cessation et non redressable | **Liquidation judiciaire** |
| Définition de la cessation de paiement | Passif exigible > Actif disponible |
| Délai de déclaration de cessation | **45 jours** |
| Composition du tribunal de commerce | Juges **consulaires** (commerçants élus) |
| Effectif minimum par jugement | **3 juges** |
| Compétence territoriale en transport | Tribunal du **domicile du débiteur** |
$lesson5$,
'Identifier le seuil d''alerte des capitaux propres, distinguer sauvegarde / redressement / liquidation, et connaître le tribunal de commerce.'
  ) RETURNING id INTO v_lesson_5;

  -- =================================================================
  -- BANQUE DE QCM REFORMULÉS — Module A (30 questions)
  -- source_ref : mft-2026:moduleA:qcm:N
  -- =================================================================

  -- QCM 1 — Personnalité juridique (LEÇON 1) — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'À partir de quel moment une société (SAS, SARL, EURL...) acquiert-elle la personnalité morale ?',
    '[
      {"id":"a","label":"À la signature des statuts par les associés","is_correct":false},
      {"id":"b","label":"À la publication de l''annonce légale","is_correct":false},
      {"id":"c","label":"À l''immatriculation au Registre du commerce et des sociétés (RCS)","is_correct":true},
      {"id":"d","label":"Au démarrage effectif de l''activité commerciale","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','droit','personnalite-juridique'],
    'mft-2026:moduleA:qcm:1', true,
    'C''est l''immatriculation au RCS qui crée juridiquement la société. Avant, elle existe en formation mais n''a pas de personnalité morale.')
  RETURNING id INTO v_q;

  -- QCM 2 — Régime matrimonial par défaut — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'En l''absence de contrat de mariage, à quel régime matrimonial les époux sont-ils automatiquement soumis en France ?',
    '[
      {"id":"a","label":"La séparation de biens","is_correct":false},
      {"id":"b","label":"La communauté universelle","is_correct":false},
      {"id":"c","label":"La communauté réduite aux acquêts","is_correct":true},
      {"id":"d","label":"La participation aux acquêts","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','droit','regime-matrimonial'],
    'mft-2026:moduleA:qcm:2', true,
    'Sans contrat de mariage, c''est la communauté réduite aux acquêts qui s''applique de plein droit (régime légal).');

  -- QCM 3 — Faillite personnelle — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Une faillite personnelle prononcée par le tribunal peut être assortie d''une interdiction de gérer pour une durée maximale de :',
    '[
      {"id":"a","label":"3 ans","is_correct":false},
      {"id":"b","label":"5 ans","is_correct":true},
      {"id":"c","label":"10 ans","is_correct":false},
      {"id":"d","label":"15 ans","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','droit','faillite'],
    'mft-2026:moduleA:qcm:3', true,
    'L''interdiction de gérer suite à faillite personnelle est limitée à 5 ans. La faillite personnelle elle-même peut durer jusqu''à 15 ans.');

  -- QCM 4 — Cessation de paiement — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Comment se définit juridiquement la cessation de paiement d''une société commerciale ?',
    '[
      {"id":"a","label":"L''impossibilité de faire face au passif exigible avec son actif disponible","is_correct":true},
      {"id":"b","label":"La perte de la moitié du capital social","is_correct":false},
      {"id":"c","label":"Une infraction pénale imputable au dirigeant","is_correct":false},
      {"id":"d","label":"Une comptabilité non conforme aux obligations légales","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','droit','procedures-collectives'],
    'mft-2026:moduleA:qcm:4', true,
    'C''est la définition légale de l''article L. 631-1 du Code de commerce. Le dirigeant doit déclarer cette cessation au tribunal dans les 45 jours.');

  -- QCM 5 — Personnalité morale — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Parmi ces structures, laquelle ne possède PAS la personnalité morale ?',
    '[
      {"id":"a","label":"La SARL","is_correct":false},
      {"id":"b","label":"L''entreprise individuelle (EI)","is_correct":true},
      {"id":"c","label":"La SAS","is_correct":false},
      {"id":"d","label":"La SARL familiale","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','droit','formes-juridiques'],
    'mft-2026:moduleA:qcm:5', true,
    'L''EI est rattachée directement à la personne physique du créateur. Elle ne crée pas de personne morale distincte.');

  -- QCM 6 — Gérant SARL — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Dans une SARL, le gérant est nommé à la majorité représentant :',
    '[
      {"id":"a","label":"L''unanimité des associés","is_correct":false},
      {"id":"b","label":"Au moins un quart des parts sociales","is_correct":false},
      {"id":"c","label":"Plus des trois quarts des parts sociales","is_correct":false},
      {"id":"d","label":"Plus de la moitié des parts sociales","is_correct":true}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','droit','sarl'],
    'mft-2026:moduleA:qcm:6', true,
    'C''est la majorité simple en parts sociales (50 % + 1 voix) qui désigne le gérant de SARL.');

  -- QCM 7 — Gérant majoritaire de SARL — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Quel régime social s''applique au gérant majoritaire d''une SARL ?',
    '[
      {"id":"a","label":"Le régime général de la Sécurité sociale (assimilé salarié)","is_correct":false},
      {"id":"b","label":"Le régime des travailleurs non-salariés (TNS / indépendants)","is_correct":true},
      {"id":"c","label":"Le régime des cadres uniquement","is_correct":false},
      {"id":"d","label":"Le régime spécifique des dirigeants de SAS","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','droit','sarl','regime-social'],
    'mft-2026:moduleA:qcm:7', true,
    'Dès que le gérant détient plus de 50 % des parts (50 % + 1 part), il bascule sous le régime des indépendants (cotisations ≈ 45 % du revenu).');

  -- QCM 8 — Capital SAS — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Quel est le capital social minimum exigé pour créer une SASU ?',
    '[
      {"id":"a","label":"1 €","is_correct":true},
      {"id":"b","label":"500 €","is_correct":false},
      {"id":"c","label":"1 000 €","is_correct":false},
      {"id":"d","label":"7 500 €","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','droit','sasu'],
    'mft-2026:moduleA:qcm:8', true,
    'Le capital de SAS et SASU est librement fixé par les actionnaires, avec un minimum symbolique de 1 €. 50 % doivent être libérés à la constitution.');

  -- QCM 9 — Régime fiscal SARL par défaut — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Quel est le régime fiscal qui s''applique par défaut à une SARL classique ?',
    '[
      {"id":"a","label":"L''impôt sur le revenu (IR)","is_correct":false},
      {"id":"b","label":"L''impôt sur les sociétés (IS)","is_correct":true},
      {"id":"c","label":"La franchise en base de TVA","is_correct":false},
      {"id":"d","label":"L''auto-liquidation","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','droit','sarl','fiscalite'],
    'mft-2026:moduleA:qcm:9', true,
    'La SARL classique est soumise à l''IS de plein droit. Une option pour l''IR est possible uniquement pour les SARL de famille ou les SARL de moins de 5 ans (sous conditions).');

  -- QCM 10 — Personne morale de droit privé — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Une société de transport routier est juridiquement :',
    '[
      {"id":"a","label":"Une personne physique","is_correct":false},
      {"id":"b","label":"Une personne morale de droit public","is_correct":false},
      {"id":"c","label":"Une personne morale de droit privé","is_correct":true},
      {"id":"d","label":"Une administration commerciale","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','droit','personnalite-juridique'],
    'mft-2026:moduleA:qcm:10', true,
    'Toute société commerciale (SARL, SAS, EURL...) est une personne morale de droit privé.');

  -- QCM 11 — Mention obligatoire des statuts — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Parmi ces mentions, laquelle est obligatoire dans les statuts d''une société ?',
    '[
      {"id":"a","label":"L''objet social","is_correct":true},
      {"id":"b","label":"Le régime fiscal opté","is_correct":false},
      {"id":"c","label":"Le nombre de salariés prévus","is_correct":false},
      {"id":"d","label":"Le nom du futur expert-comptable","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','droit','statuts'],
    'mft-2026:moduleA:qcm:11', true,
    'L''objet social (description de l''activité) est une mention obligatoire car il détermine la capacité juridique de la société.');

  -- QCM 12 — Délai paiement facture — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'En l''absence de mention contractuelle, quel est le délai légal de paiement d''une facture ?',
    '[
      {"id":"a","label":"15 jours date de facture","is_correct":false},
      {"id":"b","label":"30 jours date de réception","is_correct":true},
      {"id":"c","label":"45 jours fin de mois","is_correct":false},
      {"id":"d","label":"60 jours date de facture","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','facturation','delais'],
    'mft-2026:moduleA:qcm:12', true,
    'Délai légal par défaut : 30 jours à compter de la réception des marchandises ou de l''exécution de la prestation.');

  -- QCM 13 — Indemnité forfaitaire — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'En cas de retard de paiement, le créancier peut réclamer une indemnité forfaitaire pour frais de recouvrement de :',
    '[
      {"id":"a","label":"15 €","is_correct":false},
      {"id":"b","label":"40 €","is_correct":true},
      {"id":"c","label":"75 €","is_correct":false},
      {"id":"d","label":"100 €","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','facturation','retard'],
    'mft-2026:moduleA:qcm:13', true,
    'Indemnité forfaitaire de 40 € fixée par le décret du 2 octobre 2012, due de plein droit en cas de retard de paiement entre professionnels.');

  -- QCM 14 — Lettre de change : qui rédige ? — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Une lettre de change (traite) est rédigée par :',
    '[
      {"id":"a","label":"Le tiré (débiteur), pour acceptation par le tireur","is_correct":false},
      {"id":"b","label":"Le tireur (créancier), pour acceptation par le tiré","is_correct":true},
      {"id":"c","label":"La banque du créancier","is_correct":false},
      {"id":"d","label":"Le tribunal de commerce","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','effets-de-commerce','lettre-de-change'],
    'mft-2026:moduleA:qcm:14', true,
    'Le tireur (le vendeur, créancier) émet la lettre de change et l''envoie au tiré (acheteur, débiteur) qui l''accepte par sa signature.');

  -- QCM 15 — Billet à ordre : qui s'engage ? — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Sur un billet à ordre, qui prend l''engagement de payer la somme due ?',
    '[
      {"id":"a","label":"Le vendeur","is_correct":false},
      {"id":"b","label":"L''acheteur (souscripteur)","is_correct":true},
      {"id":"c","label":"La banque du vendeur","is_correct":false},
      {"id":"d","label":"La banque de l''acheteur","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','effets-de-commerce','billet-a-ordre'],
    'mft-2026:moduleA:qcm:15', true,
    'Contrairement à la lettre de change, c''est l''acheteur (le souscripteur) qui rédige et s''engage directement par le billet à ordre.');

  -- QCM 16 — Escompter une traite — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Escompter une lettre de change consiste à :',
    '[
      {"id":"a","label":"Augmenter le montant de l''effet de commerce","is_correct":false},
      {"id":"b","label":"Obtenir de sa banque une avance immédiate sur le montant de la traite, contre frais","is_correct":true},
      {"id":"c","label":"Annuler la créance auprès du tiré","is_correct":false},
      {"id":"d","label":"Transférer la traite à un autre fournisseur","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','effets-de-commerce','escompte'],
    'mft-2026:moduleA:qcm:16', true,
    'L''escompte est une opération bancaire : la banque achète l''effet à un prix décoté (le montant moins les agios) et se charge de l''encaissement à l''échéance.');

  -- QCM 17 — Endossement — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Endosser un effet de commerce signifie :',
    '[
      {"id":"a","label":"Garantir personnellement le paiement","is_correct":false},
      {"id":"b","label":"Désigner sa banque comme bénéficiaire","is_correct":false},
      {"id":"c","label":"Transmettre le bénéfice de l''effet à un tiers par signature au dos","is_correct":true},
      {"id":"d","label":"Demander une prolongation au tiré","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','effets-de-commerce','endossement'],
    'mft-2026:moduleA:qcm:17', true,
    'L''endossement consiste à signer au dos de l''effet pour transférer le droit de paiement à un nouveau bénéficiaire (souvent un fournisseur).');

  -- QCM 18 — Sûretés réelles vs personnelles — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Une caution bancaire est qualifiée de :',
    '[
      {"id":"a","label":"Sûreté réelle","is_correct":false},
      {"id":"b","label":"Sûreté personnelle","is_correct":true},
      {"id":"c","label":"Effet de commerce","is_correct":false},
      {"id":"d","label":"Garantie réelle hypothécaire","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','garanties','caution'],
    'mft-2026:moduleA:qcm:18', true,
    'Toute caution (personnelle ou bancaire) est une sûreté personnelle car elle repose sur l''engagement d''une personne (physique ou morale) à payer en cas de défaillance du débiteur.');

  -- QCM 19 — Hypothèque acte notarié — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'L''acte constitutif d''une hypothèque doit obligatoirement, sous peine de nullité, être :',
    '[
      {"id":"a","label":"Sous seing privé enregistré au greffe","is_correct":false},
      {"id":"b","label":"Notarié","is_correct":true},
      {"id":"c","label":"Validé par le tribunal de commerce","is_correct":false},
      {"id":"d","label":"Visé par le maire de la commune","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','garanties','hypotheque'],
    'mft-2026:moduleA:qcm:19', true,
    'L''hypothèque est une sûreté solennelle : l''acte notarié est exigé sous peine de nullité absolue (article 2416 du Code civil).');

  -- QCM 20 — Gage avec / sans dépossession — difficile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Lorsqu''un véhicule utilitaire est acheté à crédit avec inscription d''un gage automobile au greffe du tribunal de commerce, il s''agit d''un gage :',
    '[
      {"id":"a","label":"Avec dépossession, le véhicule étant remis au créancier","is_correct":false},
      {"id":"b","label":"Sans dépossession, le débiteur conservant l''usage du bien","is_correct":true},
      {"id":"c","label":"Sans publicité légale","is_correct":false},
      {"id":"d","label":"Sans valeur juridique","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-a','capa-3-5t','garanties','gage'],
    'mft-2026:moduleA:qcm:20', true,
    'Le gage automobile est un gage SANS dépossession : l''emprunteur conserve l''usage de son véhicule pendant que la banque détient le droit de saisir et vendre en cas d''impayé.');

  -- QCM 21 — Injonction de payer — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'L''injonction de payer permet :',
    '[
      {"id":"a","label":"De demander par voie de justice le recouvrement d''une créance","is_correct":true},
      {"id":"b","label":"De suspendre les poursuites judiciaires","is_correct":false},
      {"id":"c","label":"D''obtenir la liquidation judiciaire immédiate du débiteur","is_correct":false},
      {"id":"d","label":"De régler la créance hors voie judiciaire","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','recouvrement'],
    'mft-2026:moduleA:qcm:21', true,
    'Procédure judiciaire simplifiée (≈ 40 €) qui permet d''obtenir un titre exécutoire sans audience contradictoire ni avocat.');

  -- QCM 22 — Tribunal compétent injonction — difficile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Une entreprise lyonnaise souhaite engager une procédure d''injonction de payer contre un client commerçant lillois pour une facture impayée. Quelle juridiction est compétente ?',
    '[
      {"id":"a","label":"Le tribunal de commerce de Lyon","is_correct":false},
      {"id":"b","label":"Le tribunal de commerce de Lille","is_correct":true},
      {"id":"c","label":"Le tribunal judiciaire de Lyon","is_correct":false},
      {"id":"d","label":"La cour d''appel de Lyon","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-a','capa-3-5t','recouvrement','tribunal-competent'],
    'mft-2026:moduleA:qcm:22', true,
    'En matière d''injonction de payer commerciale, le tribunal compétent est celui du DOMICILE DU DÉBITEUR (article 1406 du CPC). Donc Lille ici.');

  -- QCM 23 — Capitaux propres — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Une procédure d''alerte spécifique se déclenche lorsque les capitaux propres deviennent inférieurs à :',
    '[
      {"id":"a","label":"Un quart du capital social","is_correct":false},
      {"id":"b","label":"La moitié du capital social","is_correct":true},
      {"id":"c","label":"75 % du capital social","is_correct":false},
      {"id":"d","label":"L''intégralité du capital social","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','procedures-collectives','alerte'],
    'mft-2026:moduleA:qcm:23', true,
    'Articles L. 223-42 (SARL) et L. 225-248 (SA). Quand les capitaux propres tombent sous 50 % du capital, une AGE doit être réunie sous 4 mois.');

  -- QCM 24 — Sauvegarde vs redressement — difficile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'La principale différence entre une procédure de SAUVEGARDE et un REDRESSEMENT JUDICIAIRE est :',
    '[
      {"id":"a","label":"La sauvegarde concerne les commerçants, le redressement les artisans","is_correct":false},
      {"id":"b","label":"La sauvegarde intervient avant cessation de paiement, le redressement après","is_correct":true},
      {"id":"c","label":"La sauvegarde dure 6 mois, le redressement 18 mois","is_correct":false},
      {"id":"d","label":"La sauvegarde est gratuite, le redressement payant","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-a','capa-3-5t','procedures-collectives'],
    'mft-2026:moduleA:qcm:24', true,
    'La sauvegarde est ouverte SEULEMENT à une entreprise qui n''est PAS encore en cessation de paiement. Dès qu''il y a cessation, c''est redressement (si redressement possible) ou liquidation (sinon).');

  -- QCM 25 — Tribunal de commerce composition — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Les juges du tribunal de commerce, dits "juges consulaires", sont :',
    '[
      {"id":"a","label":"Des magistrats professionnels formés à l''ENM","is_correct":false},
      {"id":"b","label":"Des commerçants élus par leurs pairs (bénévoles)","is_correct":true},
      {"id":"c","label":"Des fonctionnaires nommés par le Ministère de la Justice","is_correct":false},
      {"id":"d","label":"Des avocats désignés par leur ordre","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','tribunal-commerce'],
    'mft-2026:moduleA:qcm:25', true,
    'Les juges consulaires sont élus par les commerçants et chefs d''entreprise. Ils siègent bénévolement, à minimum 3 par jugement.');

  -- QCM 26 — EI patrimoine — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Depuis la loi du 14 février 2022, le patrimoine personnel d''un Entrepreneur Individuel (EI) est :',
    '[
      {"id":"a","label":"Toujours engagé pour les dettes professionnelles","is_correct":false},
      {"id":"b","label":"Automatiquement séparé du patrimoine professionnel","is_correct":true},
      {"id":"c","label":"Engagé uniquement à hauteur de 30 %","is_correct":false},
      {"id":"d","label":"Protégé seulement si déclaration EIRL antérieure","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','ei','patrimoine'],
    'mft-2026:moduleA:qcm:26', true,
    'La loi du 14 février 2022 a unifié le statut de l''EI et créé une séparation automatique des patrimoines, sans formalité préalable. Cela remplace l''ancienne EIRL.');

  -- QCM 27 — Apports en nature SAS — difficile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Dans une SAS, l''évaluation des apports en nature par un commissaire aux apports est obligatoire si :',
    '[
      {"id":"a","label":"Il y a au moins un apport en nature, peu importe le montant","is_correct":false},
      {"id":"b","label":"Un apport en nature dépasse 30 000 € ET les apports en nature représentent plus de 50 % du capital","is_correct":true},
      {"id":"c","label":"Le capital social total dépasse 100 000 €","is_correct":false},
      {"id":"d","label":"L''apporteur est une personne morale","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-a','capa-3-5t','sas','apports'],
    'mft-2026:moduleA:qcm:27', true,
    'Les 2 conditions sont CUMULATIVES : un apport > 30 000 € ET la majorité du capital constituée d''apports en nature. Sinon, dispense possible.');

  -- QCM 28 — Voies de recours appel — difficile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'En cas de désaccord avec une décision du tribunal de commerce portant sur un litige de 7 500 €, vous pouvez faire appel devant :',
    '[
      {"id":"a","label":"Directement la Cour de cassation","is_correct":false},
      {"id":"b","label":"La Cour d''appel","is_correct":true},
      {"id":"c","label":"Le tribunal judiciaire","is_correct":false},
      {"id":"d","label":"Aucun recours possible","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-a','capa-3-5t','tribunal-commerce','voies-recours'],
    'mft-2026:moduleA:qcm:28', true,
    'L''appel est possible devant la Cour d''appel pour tout litige > 5 000 €. La Cour de cassation n''intervient qu''ensuite, et uniquement sur les questions de droit (pas le fond).');

  -- QCM 29 — Nantissement — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Le nantissement est une sûreté qui porte sur :',
    '[
      {"id":"a","label":"Un bien immobilier","is_correct":false},
      {"id":"b","label":"Un bien mobilier corporel (véhicule, stock)","is_correct":false},
      {"id":"c","label":"Un bien mobilier incorporel (parts sociales, fonds de commerce, créances)","is_correct":true},
      {"id":"d","label":"Des actes de commerce uniquement","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','garanties','nantissement'],
    'mft-2026:moduleA:qcm:29', true,
    'Le nantissement vise les biens incorporels (parts, créances, fonds de commerce). Pour un bien corporel, on parle de gage. Pour l''immobilier, d''hypothèque.');

  -- QCM 30 — Fichier national interdits de gérer — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Depuis 2016, le Fichier national des interdits de gérer est tenu par :',
    '[
      {"id":"a","label":"L''INSEE","is_correct":false},
      {"id":"b","label":"L''URSSAF","is_correct":false},
      {"id":"c","label":"Le Conseil National des Greffiers des Tribunaux de Commerce (CNGTC)","is_correct":true},
      {"id":"d","label":"La Banque de France","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','interdits-gerer'],
    'mft-2026:moduleA:qcm:30', true,
    'Le CNGTC centralise depuis 2016 toutes les interdictions de gérer et faillites personnelles. Consultable par les greffes lors des immatriculations.');

  -- =================================================================
  -- BANQUE DE QR — Module A (6 mises en situation)
  -- source_ref : mft-2026:moduleA:qr:N
  -- =================================================================

  -- QR 1 — Choix de la forme juridique
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qr',
    'Aïcha souhaite lancer son activité de coursier urbain à Meaux avec un seul VUL (PTAC 3 t). Elle est seule, dispose de 8 000 € d''économies, et veut démarrer rapidement avec un minimum de formalités. Son conjoint est salarié et craint d''être engagé en cas de difficultés.

a. Recommandez la forme juridique la plus adaptée et justifiez votre choix.
b. Quel régime fiscal s''appliquera par défaut ?
c. Quel régime social Aïcha aura-t-elle, et quel taux de cotisations ?
d. Faut-il qu''elle adopte un contrat de mariage particulier ? Pourquoi ?',
    NULL, 5, 'moyen',
    ARRAY['module-a','capa-3-5t','qr','formes-juridiques','cas-pratique'],
    'mft-2026:moduleA:qr:1', true,
    'Correction attendue : a. EI (entrepreneur individuel) ou EURL — EI préférable pour la simplicité (pas de statuts, pas de capital). Depuis 2022, le patrimoine pro est automatiquement séparé du perso. b. IR par défaut (BIC). c. TNS, ≈ 45 % du revenu d''activité. d. Pas obligatoire grâce à la séparation automatique des patrimoines, mais la séparation de biens reste un confort supplémentaire si gros emprunt.');

  -- QR 2 — Conséquence d'une caution personnelle
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qr',
    'Vous gérez une SARL de transport. Pour acheter 2 véhicules supplémentaires, votre banque accepte un prêt de 60 000 € à condition que vous vous portiez caution personnelle solidaire à hauteur de 100 % du capital prêté.

a. Quel est l''effet juridique sur votre patrimoine personnel ?
b. La SARL avait-elle pour but principal de vous protéger : que devient cette protection ?
c. Quelles précautions concrètes pouvez-vous prendre avant de signer ?
d. Quelle alternative pourrait remplacer la caution personnelle ?',
    NULL, 5, 'difficile',
    ARRAY['module-a','capa-3-5t','qr','garanties','caution','cas-pratique'],
    'mft-2026:moduleA:qr:2', true,
    'Correction attendue : a. Votre patrimoine personnel devient engagé pour la totalité du prêt si la SARL fait défaut. b. La responsabilité limitée aux apports devient FICTIVE pour cette dette : la caution court-circuite cette protection. c. Limiter la caution dans le temps et le montant, exiger qu''elle soit dégressive avec les remboursements, faire intervenir un avocat sur la rédaction. d. Caution bancaire d''un organisme spécialisé (BPI, SIAGI) qui se substitue à votre engagement personnel.');

  -- QR 3 — Procédure d'injonction de payer
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qr',
    'Votre SARL de transport (siège à Meaux, 77) a effectué une livraison pour un commerçant à Reims (51) facturée 4 200 € le 10 janvier. Le client n''a toujours pas payé au 15 mars malgré 2 relances et une mise en demeure recommandée.

a. Quelle procédure judiciaire rapide pouvez-vous engager ?
b. Devant quel tribunal et pourquoi ?
c. Coût approximatif et avocat obligatoire ?
d. Que se passe-t-il si le client ne conteste pas l''ordonnance ?',
    NULL, 5, 'moyen',
    ARRAY['module-a','capa-3-5t','qr','recouvrement','cas-pratique'],
    'mft-2026:moduleA:qr:3', true,
    'Correction attendue : a. L''injonction de payer (article 1405 CPC). b. Tribunal de commerce de Reims (domicile du débiteur — règle pour créances commerciales). c. Environ 40 € de frais de greffe, AVOCAT NON OBLIGATOIRE. d. À défaut d''opposition dans le mois suivant la signification, l''ordonnance devient titre exécutoire et permet la saisie.');

  -- QR 4 — Cessation de paiement
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qr',
    'Votre SARL de transport est confrontée à une dégradation continue depuis 6 mois. À ce jour : 18 000 € de factures fournisseurs impayées, 12 000 € de cotisations URSSAF en retard, 2 200 € sur le compte bancaire, et plus de découvert autorisé.

a. Êtes-vous en cessation de paiement ? Justifiez juridiquement.
b. Quelle est votre obligation et son délai ?
c. Quelles sont les 2 procédures possibles à ce stade ?
d. Quels risques personnels en cas d''inaction ?',
    NULL, 5, 'difficile',
    ARRAY['module-a','capa-3-5t','qr','procedures-collectives','cas-pratique'],
    'mft-2026:moduleA:qr:4', true,
    'Correction attendue : a. Oui : passif exigible (30 000 €) > actif disponible (2 200 €). b. Déclaration de cessation de paiement au tribunal de commerce sous 45 JOURS. c. Redressement judiciaire (si redressement possible) OU liquidation judiciaire (sinon). d. Faillite personnelle, interdiction de gérer (jusqu''à 5 ans), responsabilité civile pour insuffisance d''actif, voire poursuites pénales pour banqueroute.');

  -- QR 5 — Effets de commerce trésorerie
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qr',
    'Vous avez livré pour 15 000 € HT à un client industriel qui paie habituellement à 60 jours. Vous avez besoin de trésorerie sous 15 jours pour payer votre prochain plein de carburant et l''échéance crédit-bail VUL.

a. Quel outil de paiement pouvez-vous proposer au client pour sécuriser la créance ?
b. Comment transformer cette créance en cash immédiat ?
c. Quel coût faut-il anticiper et quel risque résiduel ?
d. Quelle alternative globale et structurante existe pour systématiser cette mécanique ?',
    NULL, 5, 'moyen',
    ARRAY['module-a','capa-3-5t','qr','effets-commerce','tresorerie','cas-pratique'],
    'mft-2026:moduleA:qr:5', true,
    'Correction attendue : a. Une lettre de change (traite) à 60 jours, acceptée et signée par le client. b. Escompte bancaire : la banque vous verse le montant moins les agios immédiatement. c. Coût = agios + commissions (≈ 1-3 % du montant). Risque résiduel : si le tiré ne paie pas à l''échéance, la banque vous redemande la somme (recours contre le tireur). d. L''affacturage : cession régulière de l''ensemble des factures à un factor avec assurance contre l''impayé et financement immédiat.');

  -- QR 6 — Régime matrimonial et création
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qr',
    'Marc, marié sans contrat depuis 12 ans (régime de la communauté réduite aux acquêts), souhaite créer une SARL de transport en apportant 30 000 € prélevés sur le compte joint des époux. Sa femme est cadre dans une autre entreprise.

a. Quel est l''accord nécessaire de la conjointe ?
b. Quels biens du couple sont engagés en cas de défaillance future de la SARL ?
c. Quelles options de protection peut-on lui suggérer ?
d. Si Marc se porte ultérieurement caution personnelle pour un prêt SARL, quelle formalité concerne sa femme ?',
    NULL, 5, 'difficile',
    ARRAY['module-a','capa-3-5t','qr','regime-matrimonial','cas-pratique'],
    'mft-2026:moduleA:qr:6', true,
    'Correction attendue : a. L''accord exprès de la conjointe sur l''apport est requis car le compte joint est un bien commun. b. Les biens communs (compte joint, voiture, résidence secondaire), sauf à se porter caution. Les parts SARL sont des biens communs. c. Changer pour un régime de séparation de biens (procédure judiciaire après 2 ans), ou souscrire une assurance dirigeant. Faire renoncer la conjointe à la qualité de conjoint commun en biens. d. La conjointe doit signer un consentement exprès à la caution (article 1415 du Code civil) pour que les biens communs soient engagés.');

  -- =================================================================
  -- QUIZZES par leçon + lien vers la banque
  -- =================================================================

  -- Quiz Leçon 1
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Cadre juridique des personnes — Quiz', 'Quiz d''entraînement sur la personnalité juridique, les régimes matrimoniaux et la capacité commerciale.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleA:qcm:1', 'mft-2026:moduleA:qcm:2', 'mft-2026:moduleA:qcm:3',
      'mft-2026:moduleA:qcm:10', 'mft-2026:moduleA:qcm:30'
    );

  -- Quiz Leçon 2
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Création d''entreprise et formes juridiques — Quiz', 'Quiz d''entraînement sur les 5 formes juridiques (EI, EURL, SARL, SASU, SAS).', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleA:qcm:5', 'mft-2026:moduleA:qcm:6', 'mft-2026:moduleA:qcm:7',
      'mft-2026:moduleA:qcm:8', 'mft-2026:moduleA:qcm:9', 'mft-2026:moduleA:qcm:11',
      'mft-2026:moduleA:qcm:26', 'mft-2026:moduleA:qcm:27'
    );

  -- Quiz Leçon 3
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Facturation et effets de commerce — Quiz', 'Quiz d''entraînement sur les mentions de facture, lettre de change, billet à ordre, escompte.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleA:qcm:12', 'mft-2026:moduleA:qcm:13', 'mft-2026:moduleA:qcm:14',
      'mft-2026:moduleA:qcm:15', 'mft-2026:moduleA:qcm:16', 'mft-2026:moduleA:qcm:17'
    );

  -- Quiz Leçon 4
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Garanties et recouvrement — Quiz', 'Quiz d''entraînement sur les sûretés (caution, gage, nantissement, hypothèque) et le recouvrement.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleA:qcm:18', 'mft-2026:moduleA:qcm:19', 'mft-2026:moduleA:qcm:20',
      'mft-2026:moduleA:qcm:21', 'mft-2026:moduleA:qcm:22', 'mft-2026:moduleA:qcm:29'
    );

  -- Quiz Leçon 5
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Procédures collectives et tribunaux — Quiz', 'Quiz d''entraînement sur les procédures de sauvegarde, redressement, liquidation et le tribunal de commerce.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_5;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_5, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleA:qcm:4', 'mft-2026:moduleA:qcm:23', 'mft-2026:moduleA:qcm:24',
      'mft-2026:moduleA:qcm:25', 'mft-2026:moduleA:qcm:28'
    );

  -- Quiz Examen blanc Module A — 14 QCM tirés de l'ensemble (durée limitée)
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Examen blanc — Module A', 'Examen blanc reproduisant les conditions de l''examen national : 14 QCM en 30 min, seuil 50 %.', 'examen', 1800, 50)
  RETURNING id INTO v_quiz_eb;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleA:qcm:1',  'mft-2026:moduleA:qcm:4',  'mft-2026:moduleA:qcm:6',
      'mft-2026:moduleA:qcm:7',  'mft-2026:moduleA:qcm:9',  'mft-2026:moduleA:qcm:13',
      'mft-2026:moduleA:qcm:14', 'mft-2026:moduleA:qcm:18', 'mft-2026:moduleA:qcm:20',
      'mft-2026:moduleA:qcm:22', 'mft-2026:moduleA:qcm:23', 'mft-2026:moduleA:qcm:24',
      'mft-2026:moduleA:qcm:27', 'mft-2026:moduleA:qcm:28'
    );

  RAISE NOTICE '✅ Module A v2 chargé : 5 leçons, 30 QCM reformulés, 6 QR, 6 quizzes (5 entraînement + 1 examen blanc).';
END
$module_a_v2$;
