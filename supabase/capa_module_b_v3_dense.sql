-- =====================================================================
-- MODULE B — L'ENTREPRISE ET SON ACTIVITÉ COMMERCIALE (Capacité ≤ 3,5 T)
-- Version 3 (mai 2026) — REFONTE PÉDAGOGIQUE DENSIFIÉE
--
-- Diagnostic v2 corrigé :
--   ✓ Bug bloc : v_bloc résolu via slug fiable (pas ORDER BY id LIMIT 1)
--   ✓ Quiz : chaque quiz d'entraînement contient maintenant 12 QCM
--   ✓ Leçons : structure pédagogique pro (intro / dev / cas / synthèse /
--     "Ce que l'examinateur peut demander" / glossaire / mémo)
--   ✓ Banque enrichie : 36 QCM (vs 20) avec niveaux facile/moyen/difficile
--   ✓ QR : 5 (vs 4) avec barème implicite et cas réalistes
--   ✓ Examen blanc : 12 QCM + 4 QR (durée 45 min, seuil 50 %)
--
-- Référentiel décision du 2 avril 2012 :
--   ▸ savoir élaborer une étude de marché
--   ▸ savoir définir une politique commerciale (4P)
--   ▸ maîtriser les outils de prospection et de fidélisation
-- Examen national : 2 QCM (4 pts) sur ce module.
--
-- Idempotent : DELETE module ciblé puis recréation. Safe à rejouer.
-- Pré-requis : formation 'capacite-3-5t' présente.
-- =====================================================================

DO $module_b_v3$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_lesson_1 uuid;
  v_lesson_2 uuid;
  v_lesson_3 uuid;
  v_quiz_1 uuid;
  v_quiz_2 uuid;
  v_quiz_3 uuid;
  v_quiz_eb uuid;
  v_q uuid;
BEGIN
  -- ─── 1. Pré-requis : formation Capacité ≤ 3,5 t ─────────────────────
  SELECT id INTO v_formation
    FROM public.formations
   WHERE slug = 'capacite-3-5t';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation capacite-3-5t introuvable. Joue d''abord formations_v2.sql.';
  END IF;

  -- ─── 1bis. Bloc fiable (FIX du bug v2) ──────────────────────────────
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1';
  IF v_bloc IS NULL THEN
    INSERT INTO public.blocs (code, title, description, "order")
    VALUES ('BC1', 'Bloc 1 — Compétences générales',
            'Bloc générique partagé entre formations. À spécialiser par formation à terme.', 1)
    ON CONFLICT (code) DO NOTHING
    RETURNING id INTO v_bloc;
    IF v_bloc IS NULL THEN
      SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1';
    END IF;
  END IF;
  IF v_bloc IS NULL THEN
    RAISE EXCEPTION 'Bloc BC1 introuvable et impossible à créer.';
  END IF;

  -- ─── 2. Module : on supprime l'ancien et on recrée propre ─────────
  DELETE FROM public.modules WHERE slug = 'capa-entreprise-activite-commerciale';

  INSERT INTO public.modules (
    title, slug, bloc_id, summary, difficulty, duration_min, "order"
  ) VALUES (
    'Module B — L''entreprise et son activité commerciale',
    'capa-entreprise-activite-commerciale',
    v_bloc,
    'Élaborer une étude de marché, définir une politique commerciale (prix, produit, distribution, communication) et maîtriser les outils de prospection et de fidélisation pour une entreprise de transport léger.',
    'intermediaire',
    180,
    20
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 20, true)
  ON CONFLICT DO NOTHING;

  -- ─── 3. Banque : reset des questions Module B reformulées ─────────
  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026:moduleB:%';

  -- =================================================================
  -- LEÇON 1 — Comprendre son marché : l'étude de marché transport léger
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Comprendre son marché : l''étude de marché',
    'comprendre-marche-etude',
    1, 50,
$lessonB1$
# Comprendre son marché : l'étude de marché

> 🎯 **Objectifs pédagogiques**
>
> À la fin de cette leçon, vous serez capable de :
>
> - **Définir** ce qu'est un marché en transport et identifier ses composantes (offre, demande, environnement).
> - **Réaliser** une étude de marché en 4 étapes méthodiques.
> - **Segmenter** la clientèle transport (B2B, B2C, e-commerce, industriels).
> - **Analyser** la concurrence directe et indirecte.
> - **Identifier** les opportunités et menaces (modèle SWOT).
> - **Estimer** un chiffre d'affaires prévisionnel réaliste.

---

## Introduction

90 % des transporteurs débutants démarrent **sans étude de marché formalisée**. Ils choisissent leur zone et leur clientèle « au feeling », signent un crédit-bail VUL et attendent les commandes. Résultat : **30 %** d'entre eux déposent le bilan dans les 3 ans, le plus souvent par sous-charge des véhicules ou tarifs trop bas.

L'étude de marché n'est pas un exercice théorique de cabinet de conseil. C'est un **outil opérationnel** qui décide si vous allez démarrer **avec 1 véhicule ou 3**, sur **quelle zone géographique**, et avec **quels donneurs d'ordre cibles**. Bien faite, elle se rentabilise au premier mois d'activité.

Cette leçon vous donne la méthode complète, du cadrage initial au calcul du seuil de rentabilité.

---

## 1. Qu'est-ce qu'un marché en transport ?

### 1.1 Définition

> 📚 **Définition simple**
>
> Un **marché** est la rencontre entre une **offre** (les transporteurs disponibles) et une **demande** (les chargeurs qui ont besoin de déplacer des marchandises), à un **moment donné**, sur une **zone géographique précise**.

> 📜 **Définition économique**
>
> Le marché du transport routier de marchandises ≤ 3,5 t est un **marché de prestations de services** caractérisé par :
> - Une **forte atomicité** (≈ 75 000 entreprises en France, dont 60 % de très petites structures < 5 salariés).
> - Une **demande dérivée** (elle dépend de l'activité économique générale).
> - Une **forte sensibilité au prix** des donneurs d'ordre (mise en concurrence systématique).
> - Une **réglementation lourde** (DREAL, capacité, social, sécurité routière).

### 1.2 Les trois composantes du marché

| Composante | Définition | Exemple transport léger |
|---|---|---|
| **Demande** | Volume et nature des besoins de transport | E-commerce B2C, livraison du dernier km, distribution urbaine, courrier express |
| **Offre** | Capacité disponible sur la zone | Concurrents directs (autres VUL), substituts (vélos cargo, tricycles électriques, coursiers piétons) |
| **Environnement** | Cadre PESTEL : Politique, Économique, Sociologique, Technologique, Écologique, Légal | ZFE-m (zones à faibles émissions), prime véhicules propres, hausse du diesel, RGPD |

> ⚠️ **Attention examen**
>
> L'examinateur attend une **vision systémique**. Ne réduisez pas le marché à « j'ai des camions, il y a des clients ». Citez les 3 composantes (offre, demande, environnement) et au moins 2 facteurs PESTEL impactant le transport léger (ex. ZFE-m + prime véhicule électrique).

---

## 2. Réaliser une étude de marché : la méthode en 4 étapes

### 2.1 Étape 1 — Délimiter le périmètre

| Question | Choix possible |
|---|---|
| **Quoi ?** | Type de marchandises (frais, sec, palettes, courses urgentes, déménagement) |
| **Pour qui ?** | Particuliers (B2C), professionnels (B2B), administrations |
| **Où ?** | Zone géographique (rayon 50 km, département, région) |
| **Comment ?** | Mode (livraison à la commande, contrat récurrent, sous-traitance, plateforme) |

**Exemple cadrage :** « Livraison de palettes alimentaires (frigo léger), B2B, dans un rayon de 80 km autour de Meaux, sous contrats récurrents avec grossistes. »

### 2.2 Étape 2 — Étudier la demande

**Sources d'information :**

| Source | Information collectée |
|---|---|
| **INSEE** | Démographie de la zone, nombre d'entreprises, secteurs d'activité |
| **CCI** | Liste des entreprises locales, événements, mises en relation |
| **Pappers / Société.com** | Bilans des entreprises cibles (CA, effectifs, dirigeants) |
| **Enquête terrain** | Visites, entretiens téléphoniques avec 10-20 prospects |
| **Comité national routier (CNR)** | Statistiques sectorielles, indices coût |
| **Études sectorielles** | Xerfi, Kantar TNS (payantes mais détaillées) |

**Questions clés à poser à 10-15 prospects (B2B) :**

1. Qui est votre transporteur actuel ?
2. Quels sont vos volumes mensuels (palettes, colis, kg) ?
3. Quels jours / créneaux ?
4. Quel délai d'urgence ?
5. Êtes-vous satisfait du service actuel ? Sur quels critères (prix, fiabilité, délai, communication) ?
6. À quel prix payez-vous le km ou la course ?
7. Sous quel contrat (mensuel, annuel, à la course) ?
8. Quels seraient les motifs de changement de prestataire ?

### 2.3 Étape 3 — Étudier l'offre (concurrence)

| Type de concurrent | Exemple en transport léger | Comment l'analyser |
|---|---|---|
| **Concurrent direct** | Autres VUL ≤ 3,5 t sur la même zone | Lister 5-10 sociétés via Pappers, comparer flotte, ancienneté, tarifs affichés |
| **Concurrent indirect** | Plateformes (Stuart, Colissimo, Chronopost, Uber Eats) | Étudier leur grille tarifaire en ligne |
| **Substitut** | Tricycles cargo, vélos électriques, scooters 50 cm³ | Pertinent en zone urbaine dense (Paris, Lyon) |
| **Auto-production** | Le client livre lui-même avec ses propres camions | Risque de récupération en interne si volume devient régulier |

**Méthode rapide d'audit concurrence :**

1. **Téléphone mystère** : appelez 5 concurrents en vous présentant comme prospect. Notez délais, tarifs, ton commercial, créneaux disponibles.
2. **Recherche RCS** : Pappers vous donne le bilan, l'ancienneté, le nombre de salariés.
3. **Réseaux sociaux** : LinkedIn, Google Maps, avis clients (Trustpilot, Google).
4. **Visite physique** : passez devant les hangars, comptez les véhicules, regardez leur état.

### 2.4 Étape 4 — Synthétiser : le SWOT

Le **SWOT** (Strengths, Weaknesses, Opportunities, Threats) résume votre étude en 4 cases :

| Interne | Forces | Faiblesses |
|---|---|---|
| **(votre projet)** | Mes atouts : capacité pro acquise, VUL récent, contact 3 prospects, zone géographique connue | Mes lacunes : pas d'expérience commerciale, capital limité, 1 seul véhicule |

| Externe | Opportunités | Menaces |
|---|---|---|
| **(le marché)** | Croissance e-commerce +12 %/an, ZFE-m favorise petits véhicules propres, retraits de concurrents non capacitaires | Hausse du gazole, exigence ADR pour certaines marchandises, plateformes nationales pression sur les prix |

> 💡 **Astuce métier**
>
> Un SWOT honnête vaut **mille slides marketing**. Si la colonne "Faiblesses" est vide, c'est que vous n'avez pas creusé. Tout entrepreneur a des faiblesses (capital, expérience, réseau) — les **identifier permet de construire un plan d'attaque** (formation, partenariat, prêt d'honneur, etc.).

---

## 3. Estimer un CA prévisionnel

### 3.1 La méthode des 3 scénarios

Préparez **toujours** trois prévisions :

| Scénario | Hypothèses | Utilité |
|---|---|---|
| **Pessimiste** | Démarrage difficile : 50 % de la capacité utilisée pendant 6 mois | Sert au calcul du **besoin de trésorerie de démarrage** |
| **Réaliste** | Rampe de montée en charge : 70 % en 6 mois, 85 % en année 1 | Utilisé pour le **business plan banque** |
| **Optimiste** | Démarrage rapide : 90 % dès le mois 3 | Sert à dimensionner le **plan d'embauche** futur |

### 3.2 Cas pratique 1 — Calcul d'un CA prévisionnel

> 🚛 **Mise en situation**
>
> **Vous** envisagez de démarrer une activité de coursier express avec 1 VUL sur Meaux et sa banlieue. D'après votre étude :
>
> - Tarif moyen pratiqué : **45 € HT par course de 30 km** (donnée pappers + téléphone mystère).
> - Capacité réaliste : **8 courses/jour** sur 22 jours/mois ouvrés = 176 courses max.
> - Démarrage : 50 % capacité m1-m3, 70 % m4-m6, 85 % m7-m12.
>
> **Question :** calculez le CA mensuel scénario réaliste.

**Correction étape par étape :**

| Mois | Capacité | Courses | CA HT |
|---|---|---|---|
| m1-m3 | 50 % | 88 | 88 × 45 € = **3 960 €** |
| m4-m6 | 70 % | 123 | 123 × 45 € = **5 535 €** |
| m7-m12 | 85 % | 150 | 150 × 45 € = **6 750 €** |

**CA annuel total** : 3 × 3 960 € + 3 × 5 535 € + 6 × 6 750 € = **70 985 €** HT.

**Vérification de cohérence** : ce CA reste **sous le plafond auto-entrepreneur** (77 700 € pour les prestations de service). Donc la micro-entreprise reste possible la 1re année.

**Important** : ce n'est qu'un CA. Pour le **bénéfice**, soustraire les charges (carburant, leasing VUL, URSSAF, assurance, comptable, etc.).

### 3.3 Mini-exercice guidé

> ✏️ **À vous**
>
> **Karim** envisage de démarrer une activité de livraison alimentaire B2B (frais, livraisons matinales aux restaurants). Tarif négocié : **120 € HT par tournée**, capacité 1 tournée/jour, 6 jours/semaine. Démarrage à 60 % capacité m1-m6, 80 % m7-m12.
>
> Calculez le CA prévisionnel annuel scénario réaliste.

**Correction :**

| Phase | Capacité | Tournées/an | CA HT |
|---|---|---|---|
| m1-m6 | 60 % | 6 × 26 × 0,6 = 93,6 | 94 × 120 € ≈ **11 280 €** |
| m7-m12 | 80 % | 6 × 26 × 0,8 = 124,8 | 125 × 120 € = **15 000 €** |

**CA annuel** ≈ 11 280 € + 15 000 € = **26 280 €** HT.

→ CA modeste, sous-utilisation manifeste du véhicule. Karim devrait soit **élargir** sa zone (plus de tournées/jour), soit **diversifier** (ajouter du B2C en après-midi), soit **renégocier** ses tarifs à la hausse, soit **ajouter** des tournées le samedi.

---

## 4. Segmentation de la clientèle transport léger

### 4.1 Les grands segments

| Segment | Caractéristiques | Exemple | Marges |
|---|---|---|---|
| **B2B distribution** | Contrats récurrents, paiement 30-60 j, volumes constants | Grossistes alimentaires, distributeurs auto-pièces | Marges moyennes 8-15 % |
| **B2B industrie** | Tournées dédiées, volumes lourds, exigence horaire | Usines, ateliers, sous-traitants | Marges 5-12 % |
| **B2B e-commerce** | Volumes variables, pics saisonniers, exigence délai 24-48 h | Sites e-commerce locaux, dropshipping | Marges 10-18 % |
| **B2C express** | Course unitaire, paiement comptant, délai immédiat | Particuliers, déménagement express, livraison meubles | Marges 20-30 % |
| **B2A administrations** | Marchés publics, paiement 60 j, volumes stables | Mairies, hôpitaux publics, écoles | Marges 8-12 % |

### 4.2 Cas pratique 2 — Choix de segment

> 🚛 **Mise en situation**
>
> **Aïcha** dispose d'un capital de démarrage de 12 000 €, n'a pas d'expérience commerciale, mais possède un VUL de 6 m³ avec hayon. Elle hésite entre :
>
> A. Cibler les particuliers (déménagement express, livraison meubles).
> B. Cibler des grossistes alimentaires (contrats récurrents B2B).
>
> **Question :** quelle stratégie recommandez-vous ?

**Correction :**

**Recommandation : démarrer en B2C express (option A) puis basculer en B2B.**

**Justification :**

1. **Cycle de vente plus court** : un particulier décide en 1 appel, un grossiste en 3 mois (référencement, signature contrat, période d'essai).
2. **Trésorerie immédiate** : paiement comptant ou à 7 j vs 30-60 j en B2B.
3. **Marges plus élevées** : 20-30 % contre 8-15 %.
4. **Crédibilisation** : les premiers retours clients (avis Google, recommandations) servent ensuite à approcher les B2B avec des références.

**Phase 2** (mois 4-6) : une fois le carnet de commandes B2C établi, démarcher 2-3 grossistes en proposant un **tarif d'appel** sur le 1er contrat pour décrocher la signature.

---

## 5. Glossaire des notions clés

| Terme | Définition |
|---|---|
| **Étude de marché** | Recherche structurée pour caractériser offre, demande et environnement |
| **Demande dérivée** | Demande qui dépend d'une autre (le transport dépend de l'activité économique générale) |
| **PESTEL** | Politique / Économique / Sociologique / Technologique / Écologique / Légal |
| **SWOT** | Strengths / Weaknesses / Opportunities / Threats |
| **B2B** | Business to Business (entre professionnels) |
| **B2C** | Business to Consumer (vers particuliers) |
| **B2A** | Business to Administration (marchés publics) |
| **CCI** | Chambre de Commerce et d'Industrie |
| **CNR** | Comité National Routier (statistiques sectorielles transport) |
| **ZFE-m** | Zone à Faibles Émissions mobilité (interdiction des véhicules polluants en ville) |
| **Atomicité** | Marché caractérisé par un grand nombre de petits acteurs |
| **Substitut** | Solution alternative qui peut remplacer la prestation (vélo cargo vs VUL) |

---

## 🧠 Synthèse opérationnelle

> 📌 **Les 8 points à retenir**
>
> 1. **Marché** = rencontre offre / demande / environnement (3 composantes), à un moment et sur une zone donnée.
> 2. Le marché du transport léger est **fortement atomisé** (~ 75 000 entreprises) avec une **demande dérivée**.
> 3. Méthode étude de marché en **4 étapes** : délimiter / étudier la demande / étudier l'offre / synthétiser (SWOT).
> 4. Sources principales : INSEE, CCI, Pappers, enquête terrain (10-20 prospects), CNR.
> 5. Le **SWOT** structure forces/faiblesses (interne) et opportunités/menaces (externe).
> 6. Toujours préparer **3 scénarios** de CA : pessimiste, réaliste, optimiste.
> 7. **Segments transport léger** : B2B distribution / industrie / e-commerce, B2C express, B2A admin.
> 8. **B2C démarre vite** (cash, marges hautes) ; **B2B est plus stable** (contrats récurrents) → mix recommandé en démarrage.

---

## 🎓 Ce que l'examinateur peut demander

1. **« Qu'est-ce que la demande dérivée en transport ? »** → Demande qui dépend d'une autre (l'activité économique générale).
2. **« Citez les composantes d'une étude de marché. »** → Offre, demande, environnement (PESTEL).
3. **« Qu'est-ce qu'un SWOT ? »** → Forces, faiblesses (interne), opportunités, menaces (externe).
4. **« Pourquoi préparer 3 scénarios de CA ? »** → Anticiper le besoin de trésorerie (pessimiste), structurer le BP (réaliste), dimensionner les embauches (optimiste).
5. **Cas en QR** : Rédiger un mini-SWOT sur un projet de transport B2C express dans une ville moyenne avec un seul VUL.

---

## 📋 Mémo à imprimer

```
ÉTUDE DE MARCHÉ EN 4 ÉTAPES
1. Délimiter        → Quoi, pour qui, où, comment
2. Étudier demande  → INSEE, CCI, Pappers, enquête 10-20 prospects
3. Étudier offre    → 5-10 concurrents directs + substituts
4. Synthétiser      → SWOT (4 cases)

SCÉNARIOS DE CA
Pessimiste → Trésorerie de démarrage
Réaliste   → Business Plan banque
Optimiste  → Plan d'embauche futur

SEGMENTS PRIORITAIRES TRANSPORT LÉGER
B2C express      → Cash + marges 20-30 %
B2B distribution → Contrats récurrents, marges 8-15 %
B2B e-commerce   → Variable, marges 10-18 %
```
$lessonB1$,
'Réaliser une étude de marché transport en 4 étapes (délimiter, demande, offre, SWOT), segmenter la clientèle et estimer un CA prévisionnel sur 3 scénarios.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — La politique commerciale : les 4P du transporteur
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'La politique commerciale : les 4P du transporteur',
    'politique-commerciale-4p',
    2, 50,
$lessonB2$
# La politique commerciale : les 4P du transporteur

> 🎯 **Objectifs pédagogiques**
>
> À la fin de cette leçon, vous serez capable de :
>
> - **Définir** les 4P du marketing-mix (Produit, Prix, Place, Promotion).
> - **Construire** une grille tarifaire transport cohérente avec votre coût de revient.
> - **Calculer** votre coût de revient kilométrique (CRKM) et votre seuil de rentabilité.
> - **Choisir** vos canaux de distribution (direct, plateforme, sous-traitance).
> - **Communiquer** efficacement sans budget marketing surdimensionné.

---

## Introduction

La politique commerciale est ce qui transforme une **bonne étude de marché** en **carnet de commandes**. Beaucoup de transporteurs débutants confondent « politique commerciale » avec « j'ai un camion et un numéro de téléphone ». Conséquence directe : **prix au feeling**, distribution unique (le téléphone), zéro communication, et donc **stagnation au bout de 6 mois**.

Le marketing transport ne demande **ni budget important ni compétences techniques pointues**. Il demande de **structurer 4 leviers** dans un ensemble cohérent : votre offre (P-roduit), votre tarification (P-rix), vos canaux d'acquisition (P-lace) et vos messages (P-romotion). Cette leçon vous donne la grille opérationnelle.

---

## 1. Le marketing-mix : les 4P expliqués

### 1.1 Définition

> 📚 **Définition simple**
>
> Le **marketing-mix** est la combinaison de **4 leviers** (4P) que toute entreprise doit maîtriser pour réussir commercialement. Ils s'influencent mutuellement : un changement de prix impacte la promotion, un changement de canal impacte le produit, etc.

| P | Question clé | Exemple transport léger |
|---|---|---|
| **Produit** | Que vendez-vous précisément ? | Course express 30 km, contrat journalier B2B, sous-traitance |
| **Prix** | À quel tarif et selon quelle grille ? | 45 €/course, 0,90 €/km, forfait mensuel 1 500 € |
| **Place (distribution)** | Comment touchez-vous le client ? | Téléphone direct, plateforme Stuart, agence courtier |
| **Promotion (communication)** | Quel message, sur quels canaux ? | Site web, Google Maps, LinkedIn, presse locale |

### 1.2 La cohérence : la règle d'or

Les 4P doivent être **alignés** entre eux. Une incohérence majeure tue la conversion.

> ❌ **Exemple d'incohérence**
>
> Vous proposez du transport **express premium** (Produit) à des prix **30 % moins chers que la concurrence** (Prix), distribué uniquement via une **plateforme low-cost type Stuart** (Place), avec une communication **« qualité supérieure »** (Promotion) → message contradictoire = méfiance des clients haut de gamme + clients prix défilent.

---

## 2. La politique de Produit

### 2.1 Définir précisément ce que vous vendez

| Élément | Choix possibles |
|---|---|
| **Type de prestation** | Course unitaire / Tournée régulière / Mise à disposition véhicule + chauffeur |
| **Engagement** | À la commande / Contrat mensuel / Contrat annuel |
| **Promesse délai** | Express (< 2h) / Jour J / J+1 / J+2 |
| **Type de marchandise** | Sec / Frais / Hors-gabarit / Fragile / ADR |
| **Service périphérique** | Ramasse, attente sur site, hayon, prise de RDV destinataire, suivi GPS |

### 2.2 La pyramide d'offres

Construisez **3 niveaux** d'offres pour capter différents segments :

| Niveau | Promesse | Tarif relatif | Cible |
|---|---|---|---|
| **Économique** | Délai standard (J+2/J+3), pas de service périphérique | -10 à -15 % du marché | Particuliers, TPE peu pressées |
| **Standard** | Délai standard (J+1), tracking de base | Tarif marché | PME, e-commerce moyen |
| **Premium** | Délai express (< 4h), suivi temps réel, attente sur site, hayon, urgent week-end | +20 à +30 % | Industriels, retail haut de gamme |

> 💡 **Astuce métier**
>
> Le niveau **Premium** doit représenter **15-25 %** de votre CA mais générer **35-50 %** de votre **marge** (car les clients premium sont moins sensibles au prix et exigent moins de SAV chronophage). Ne le négligez jamais : il finance votre rentabilité globale.

### 2.3 Cas pratique 1 — Définir votre offre

> 🚛 **Mise en situation**
>
> **Vous** lancez votre activité avec 1 VUL frigo (3,5 t, 15 m³, hayon). Zone : agglomération lyonnaise.
>
> **Question :** définissez 3 offres cohérentes (économique / standard / premium).

**Correction proposée :**

| Niveau | Offre | Cible | Tarif HT |
|---|---|---|---|
| Éco | Livraison J+2 sur planning groupé, chargement matin par client, pas d'attente | Particuliers, petits e-commerçants | 0,75 €/km hors chargement, 35 € forfait < 30 km |
| Std | Livraison J+1, prise de RDV par vous, attente max 15 min, hayon inclus | Restaurants, distributeurs grossistes | 0,95 €/km, 50 € forfait < 30 km |
| Premium | Livraison express < 3h, tracking GPS partagé, attente jusqu'à 1h, week-end inclus, urgent ADR autorisé | Industriels frais, hôpitaux, événementiel | 1,30 €/km, 80 € forfait < 30 km |

---

## 3. La politique de Prix

### 3.1 Trois méthodes de fixation

| Méthode | Principe | Avantage | Inconvénient |
|---|---|---|---|
| **Coût plus marge** | Coût de revient + % de marge souhaité | Garantit la rentabilité | Ignore la concurrence et la valeur perçue |
| **Marché** | Tarif aligné sur la concurrence | Simple, cohérent avec le marché | Peut être au-dessous du seuil de rentabilité |
| **Valeur perçue** | Tarif basé sur ce que le client est prêt à payer | Marges optimales | Demande une étude fine, plus complexe |

### 3.2 Le coût de revient kilométrique (CRKM) : la base

> 📚 **Définition**
>
> Le **CRKM** est le coût total de votre activité divisé par le nombre de kilomètres parcourus. C'est votre **plancher absolu** de tarification : descendre en dessous = vendre à perte.

**Composition type pour 1 VUL ≤ 3,5 t roulant 30 000 km/an :**

| Poste | Coût annuel estimatif | € / km |
|---|---|---|
| Crédit-bail VUL (35 000 €, 5 ans) | 8 400 € | 0,28 |
| Carburant (8 L/100 km × 1,90 €) | 4 560 € | 0,15 |
| Entretien + pneus | 2 000 € | 0,07 |
| Assurance + AT | 1 800 € | 0,06 |
| Cotisations URSSAF (TNS sur 25 K€ revenu) | 11 250 € | 0,38 |
| Charges fixes (tél, compta, TVA) | 2 400 € | 0,08 |
| **Total** | **30 410 €** | **1,02 €/km** |

> ⚠️ **Attention examen**
>
> Le **CRKM moyen** d'un VUL ≤ 3,5 t en France est de **0,90 à 1,10 €/km tout compris**. Si vous facturez à 0,80 €/km, vous **perdez** environ 20 cts par km, soit **6 000 € par an** pour 30 000 km. Beaucoup d'auto-entrepreneurs débutants se cachent cette réalité.

### 3.3 Calcul du seuil de rentabilité

> 📚 **Définition**
>
> Le **seuil de rentabilité** est le chiffre d'affaires minimum que vous devez réaliser pour couvrir vos charges (sans encore dégager de bénéfice).

**Formule :**

```
Seuil de rentabilité = Charges fixes / Taux de marge sur coûts variables

avec  Taux de marge sur coûts variables = (CA - CV) / CA
```

### 3.4 Cas pratique 2 — Calcul de seuil

> 🚛 **Mise en situation**
>
> Vos charges annuelles :
> - **Charges fixes** (leasing, assurance, cotisations forfait, abonnements) : **18 000 €/an**.
> - **Charges variables** (carburant, entretien à l'usage, péages) : **0,40 €/km**.
> - Tarif moyen de vente : **1,00 €/km**.
>
> **Question :** calculez votre seuil de rentabilité en km et en CA.

**Correction étape par étape :**

1. **Marge unitaire sur coût variable** par km = 1,00 € - 0,40 € = **0,60 €**.
2. **Taux de marge sur CV** = 0,60 / 1,00 = **60 %**.
3. **Seuil en km** = 18 000 € / 0,60 € = **30 000 km/an**.
4. **Seuil en CA** = 30 000 km × 1,00 € = **30 000 € HT/an**.

**Interprétation :** vous devez parcourir au moins 30 000 km facturés à 1 €/km pour ne **pas** être en perte. Soit **2 500 km / mois**, ou **115 km / jour ouvré**. Au-dessus, vous gagnez 0,60 € de marge par km supplémentaire.

### 3.5 Mini-exercice guidé

> ✏️ **À vous**
>
> Vos charges fixes : **24 000 €/an**. Charges variables : **0,50 €/km**. Tarif de vente : **1,20 €/km**.
>
> 1. Calculez le seuil de rentabilité en km.
> 2. Si vous parcourez 35 000 km/an, quel est votre bénéfice annuel ?

**Correction :**

1. Marge sur CV = 1,20 - 0,50 = **0,70 €/km**. Taux = 0,70/1,20 = 58,3 %. Seuil = 24 000 / 0,70 = **34 286 km/an**.
2. À 35 000 km : CA = 35 000 × 1,20 = 42 000 € ; CV totales = 35 000 × 0,50 = 17 500 € ; Marge sur CV = 24 500 € ; Bénéfice = 24 500 - 24 000 = **500 €** (à peine positif).

→ Marge fragile. Pour améliorer : augmenter le tarif (passer à 1,30 €/km = +3 500 €/an) OU réduire les charges fixes OU augmenter le kilométrage.

---

## 4. La politique de Place (distribution)

### 4.1 Trois canaux principaux

| Canal | Avantages | Inconvénients | Marges |
|---|---|---|---|
| **Direct** (votre téléphone, votre site) | Marge maximale, relation client directe | Démarche commerciale chronophage, peu de volume au départ | 100 % du tarif |
| **Plateforme intermédiaire** (Stuart, Colis Privé, courtiers) | Volume rapide, pas de prospection | Commission 15-30 %, dépendance au planning de l'app | 70-85 % du tarif |
| **Sous-traitance** (vous travaillez sous le pavillon d'un confrère) | Volume garanti, simplicité administrative | Marge la plus faible, pas de relation client en propre | 60-80 % |

### 4.2 La stratégie multicanal

> 💡 **Astuce métier**
>
> Démarrer **mix direct + plateforme** est la stratégie idéale pour 90 % des nouveaux transporteurs :
>
> - **Plateforme** (50-70 % du temps au début) : remplit immédiatement le carnet de commandes, vous laisse votre VUL roulant pendant que vous prospectez.
> - **Direct** (30-50 % du temps) : vous démarchez 5-10 prospects par semaine en parallèle pour construire votre clientèle propre, à plus forte marge.
>
> En 12-18 mois, l'objectif est de **basculer 70 % du CA en direct** pour libérer la marge.

---

## 5. La politique de Promotion (communication)

### 5.1 Outils prioritaires pour un transporteur

| Outil | Coût | Effet | Délai |
|---|---|---|---|
| **Google Business Profile (ex. Google My Business)** | Gratuit | Présence locale, avis clients, photos VUL | Immédiat |
| **Site web vitrine simple** (1 page) | 100-500 € | Crédibilise, capte les demandes via formulaire | 1-2 semaines |
| **Profil LinkedIn personnel actif** | Gratuit | Réseau B2B, visibilité auprès de gros donneurs d'ordre | 3-6 mois |
| **Cartes de visite** | 30 € | Distribution physique en visite client | Immédiat |
| **Flocage VUL** | 200-500 € | Publicité mobile permanente, ~ 30 000 vues/jour en circulation | Immédiat |
| **Annuaires pro** (Pages Jaunes Pro, Yellow) | 100-500 €/an | Référencement standard | 1 mois |
| **Plateforme courtage** (Convoy, Quotep) | Commission 5-10 % | Mise en relation directe | Immédiat |

### 5.2 Le bouche-à-oreille structuré

Le canal **n° 1** d'acquisition transport est la recommandation. Pour la stimuler activement :

1. Demander **systématiquement** un avis Google après chaque livraison réussie (3 secondes pour le client, énorme impact référencement local).
2. Offrir un **incentive de parrainage** : -10 % sur la prochaine course pour chaque nouveau client envoyé par un client actuel.
3. **Soigner les détails** : VUL propre, ponctualité, communication amicale. Un client satisfait parle à 3 personnes ; un client mécontent à 11.

### 5.3 Cas pratique 3 — Plan de communication low-budget

> 🚛 **Mise en situation**
>
> **Vous** disposez de **400 €** pour communiquer pendant les 3 premiers mois. Comment les répartissez-vous ?

**Correction proposée :**

| Action | Coût | Justification |
|---|---|---|
| Google Business Profile + photos pro VUL | 0 € | Indispensable, prend 2 h |
| Site web 1 page (Carrd, Webflow basic) | 50 € | Crédibilise, capture les leads |
| Cartes de visite (× 250) | 30 € | Pour visites prospects et flyer |
| Flocage VUL discret (logo + N° tél + N° SIRET + site) | 250 € | Publicité mobile permanente |
| Annonces locales Le Bon Coin pro × 2 | 50 € | Test acquisition particulier |
| Parrainage clients (réserve sur les premières recommandations) | 20 € | Premier client recommandé |
| **Total** | **400 €** | |

**Effet attendu** : 5-15 prospects au mois 1, 20-30 au mois 3.

---

## 6. Glossaire des notions clés

| Terme | Définition |
|---|---|
| **Marketing-mix / 4P** | Combinaison Produit / Prix / Place / Promotion |
| **CRKM** | Coût de revient kilométrique (charges totales / km parcourus) |
| **Seuil de rentabilité** | CA minimum pour couvrir les charges |
| **Marge sur coûts variables** | Différence entre prix de vente et coût variable |
| **Charges fixes** | Charges indépendantes du volume (leasing, assurance, abonnements) |
| **Charges variables** | Charges proportionnelles au volume (carburant, entretien, péages) |
| **Pyramide d'offres** | 3 niveaux Eco / Standard / Premium |
| **Bouche-à-oreille structuré** | Recommandation activement stimulée (avis Google, parrainage) |
| **B2B / B2C / B2A** | Business to Business / Consumer / Administration |
| **Multicanal** | Combinaison de plusieurs canaux de distribution |

---

## 🧠 Synthèse opérationnelle

> 📌 **Les 8 points à retenir**
>
> 1. **Marketing-mix = 4P** : Produit, Prix, Place, Promotion. Tous doivent être **cohérents**.
> 2. Construire une **pyramide d'offres** : Eco / Standard / Premium pour capter chaque segment.
> 3. **CRKM moyen** d'un VUL ≤ 3,5 t : **0,90 à 1,10 €/km** tout compris (selon contexte).
> 4. **Seuil de rentabilité** = Charges fixes / Taux de marge sur coûts variables.
> 5. **Trois canaux** : direct (marge max, lent), plateforme (volume rapide, commission 15-30 %), sous-traitance (volume garanti, marge basse).
> 6. **Mix recommandé** : direct + plateforme au démarrage, basculer en majorité direct après 12-18 mois.
> 7. **Outils communication low-budget** : Google Business Profile (gratuit), site web 1 page, flocage VUL, cartes de visite.
> 8. **Bouche-à-oreille structuré** : demander un avis Google après chaque livraison + parrainage incentivé.

---

## 🎓 Ce que l'examinateur peut demander

1. **« Citez les 4P du marketing-mix. »** → Produit, Prix, Place (distribution), Promotion (communication).
2. **« Comment calcule-t-on un seuil de rentabilité ? »** → Charges fixes / Taux de marge sur coûts variables.
3. **« Quelle est la différence entre charges fixes et variables ? »** → Fixes = indépendantes du volume (leasing, assurance). Variables = proportionnelles (carburant, entretien).
4. **« Quels sont les avantages d'une plateforme intermédiaire ? »** → Volume rapide, pas de prospection. Inconvénient : commission 15-30 %.
5. **Cas en QR** : calculer un CRKM ou un seuil de rentabilité avec des chiffres donnés. Toujours détailler la formule.

---

## 📋 Mémo à imprimer

```
LES 4P DU MARKETING-MIX
Produit    → Quoi vendre (express, contrat, sous-traitance)
Prix       → Combien (CRKM + marge ou marché ou valeur perçue)
Place      → Où vendre (direct, plateforme, sous-traitance)
Promotion  → Comment communiquer (Google, LinkedIn, flocage VUL)

CRKM TYPIQUE VUL ≤ 3,5 t
0,90 à 1,10 €/km tout compris

SEUIL DE RENTABILITÉ
SR = Charges fixes / Taux de marge sur CV
   où Taux = (CA - CV) / CA = Marge unitaire / Prix unitaire

PYRAMIDE D'OFFRES
Eco       → -10 à -15 % du marché, marges faibles
Standard  → tarif marché, marges moyennes
Premium   → +20 à +30 %, marges hautes (15-25 % du CA, 35-50 % de la marge)
```
$lessonB2$,
'Maîtriser les 4P du marketing-mix appliqués au transport, calculer son CRKM et son seuil de rentabilité, choisir ses canaux de distribution.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Prospecter et fidéliser : la machine commerciale
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Prospecter et fidéliser : la machine commerciale',
    'prospecter-fideliser',
    3, 50,
$lessonB3$
# Prospecter et fidéliser : la machine commerciale

> 🎯 **Objectifs pédagogiques**
>
> À la fin de cette leçon, vous serez capable de :
>
> - **Construire** un fichier de prospects qualifiés.
> - **Conduire** un appel de prospection téléphonique structuré.
> - **Préparer** et **réaliser** un rendez-vous client.
> - **Rédiger** un devis qui se transforme en commande.
> - **Mesurer** la performance de votre démarche commerciale (KPIs).
> - **Fidéliser** vos clients pour transformer 1 commande en 10.

---

## Introduction

90 % des transporteurs débutants pensent : « le bouche-à-oreille suffira ». **Statistiquement faux** : sur 100 transporteurs nouvellement créés, 70 dépassent 50 K€ de CA en année 1, et seuls **15 % atteignent 100 K€**. Ce n'est pas la qualité du service qui fait la différence : c'est la **discipline commerciale**.

Cette leçon couvre le **cycle commercial complet** : prospection (acquisition de nouveaux clients) → conversion (transformer un prospect en client) → fidélisation (transformer 1 livraison en relation longue). Une machine commerciale même modeste mais régulière vous mènera bien plus loin qu'une grosse étude marketing théorique.

---

## 1. La prospection : remplir le pipe

### 1.1 Construire un fichier de prospects qualifiés

**Critères de qualification :**

| Critère | À vérifier | Outil |
|---|---|---|
| **Activité compatible** | A besoin de transport ? À quelle fréquence ? | Pappers, Société.com (chiffre d'affaires) |
| **Zone géographique** | Dans votre rayon d'action ? | Google Maps |
| **Taille adaptée** | Volume potentiel cohérent avec votre capacité ? | Effectif Pappers, étude terrain |
| **Solvabilité** | Pas de procédure collective ? Note OK ? | Pappers (procédures), Score3 (Banque de France) |
| **Décideur identifié** | Vous savez qui appeler ? | LinkedIn, accueil téléphonique |

**Volume cible** : pour un démarrage solo, viser **150-200 prospects qualifiés** dans les 3 premiers mois. C'est la base d'une prospection efficace.

### 1.2 La règle des 100 appels

Loi statistique de la prospection BtoB :

```
100 appels      →  30 conversations       (30 % décrochent)
30 conversations →   10 demandes de devis (33 % conversion)
10 devis         →    3 commandes          (30 % closing)

⇒ Taux global : 3 % d'appels donnent une commande
```

> 💡 **Astuce métier**
>
> Le 3 % global se cache derrière une moyenne. Les **bons commerciaux** sont à 5-7 %, les **mauvais** à 1-2 %. La différence : **préparation** + **persévérance** + **qualification du prospect**. Sur 100 appels mal qualifiés, vous obtenez 1 commande. Sur 100 appels qualifiés sur le bon segment, vous en obtenez 5-8.

### 1.3 La structure d'un appel de prospection (méthode AIDA)

| Phase | Durée | Objectif | Exemple |
|---|---|---|---|
| **A**ttention | 10-15 s | Capter l'intérêt, ne pas être confondu avec un démarchage |  « Bonjour, je suis [Prénom] de [Nom société], transporteur agréé sur la zone [Ville]. Avez-vous 30 secondes ? » |
| **I**ntérêt | 30-45 s | Présenter votre proposition de valeur ciblée | « Je travaille avec d'autres distributeurs alimentaires sur Reims et je propose des livraisons J+1 fiables. » |
| **D**ésir | 30-60 s | Susciter l'envie de creuser | « Mon dernier client a réduit ses ruptures de 15 % en passant chez moi. » |
| **A**ction | 15-30 s | Demander un RDV ou un devis | « Pouvez-vous m'accorder 15 minutes mardi ou jeudi prochain ? » |

### 1.4 Cas pratique 1 — Prospection téléphonique

> 🚛 **Mise en situation**
>
> Vous appelez un grossiste alimentaire local que vous ciblez depuis 2 semaines. Le standard décroche. Comment commencez-vous ?

**Correction :**

```
Standard : « Bienvenue chez Grossiste X, je vous écoute. »

Vous : « Bonjour, je suis [Prénom] de [Société]. Pourriez-vous me passer
votre responsable logistique ou la personne qui gère vos transporteurs ?
J'ai une proposition à lui faire concernant vos livraisons. »
```

→ Une fois la personne au bout du fil, démarrez avec AIDA :

```
« Bonjour [Nom], je suis [Prénom], dirigeant de [Société] basée à [Ville].
Je travaille avec d'autres distributeurs alimentaires de la zone et je
voudrais comprendre comment vous gérez aujourd'hui vos livraisons clients.
Avez-vous 2 minutes ? »
```

Notes importantes :
1. **Présentez-vous à la 1re personne** : « Je suis » plutôt que « C'est ».
2. **Donnez le nom de la société** clairement.
3. **Demandez explicitement la permission** : « avez-vous 2 minutes ? ». Cela respecte le prospect et augmente l'engagement.

---

## 2. Du devis à la commande

### 2.1 Anatomie d'un devis qui convertit

| Élément | Détail |
|---|---|
| **En-tête** | Identité société complète (Kbis, SIRET, RCS, capital, TVA) |
| **Référence** | Devis n° 2026-014, daté |
| **Période de validité** | « Valable 30 jours » |
| **Description précise** | Trajet, fréquence, type de marchandise, délai promis |
| **Tarif détaillé** | Prix HT, TVA, TTC (pas de globalisation opaque) |
| **Modalités de paiement** | Délai (30 j net en transport), mode (virement, LC) |
| **Conditions générales** | En annexe ou au verso |
| **Signature** | Vôtre + bonne pour accord client |

### 2.2 Les bonnes pratiques

> 💡 **Astuce métier**
>
> 1. **Toujours sous 24 h**. Un devis qui arrive 5 jours après l'appel = converti 3× moins.
> 2. **Préciser un service périphérique gratuit** que la concurrence fait payer (suivi GPS partagé, attente 30 min sur site).
> 3. **Préciser une date d'expiration** (« valable 30 jours ») : crée de l'urgence.
> 4. **Inclure une référence client** déjà servi (« comme [Société Y] depuis 6 mois ») : crédibilise.
> 5. **Présenter 2 ou 3 variantes** (A/B/C : éco / standard / premium) → laisser le client choisir lui-même son niveau.

### 2.3 Cas pratique 2 — Rédiger un devis

> 🚛 **Mise en situation**
>
> **Pierre Distribution** vous demande un devis pour 3 livraisons hebdomadaires de palettes alimentaires (frais) sur 50 km, à raison de 4 palettes par livraison, en moyenne 250 kg.
>
> **Question :** structurez le devis en 5 grandes lignes.

**Correction :**

```
DEVIS N° 2026-018 — VALABLE 30 JOURS
Établi le 12/03/2026 par SARL Express77 (...)

À l'attention de : Pierre Distribution (Reims)

Prestation : Livraisons hebdomadaires palettes alimentaires sec/frais
- Trajet : Meaux → Reims (≈ 50 km)
- Fréquence : 3 livraisons/semaine (lundi, mercredi, vendredi)
- Volume : 4 palettes / livraison (≈ 250 kg)
- Délai : J+1, livraison entre 6h et 10h
- Inclus : suivi GPS partagé, hayon, attente 30 min sur site

Tarif HT par livraison : 80 €
TVA 20 %                : 16 €
Tarif TTC               : 96 €

Engagement mensuel : 3 livr. × 4,3 sem. × 96 € = 1 238 € TTC/mois.

Modalités : engagement mensuel reconductible, paiement 30 j date de facture
(délai max imposé par L. 441-11 C. com. en transport routier).
Pénalités de retard : taux BCE + 10 pts + indemnité forfaitaire 40 € HT.

Référence : nous travaillons depuis 6 mois avec Distri Champagne (Épernay)
à votre satisfaction.

Bon pour accord (date + signature)              Le transporteur (signature)
```

---

## 3. Mesurer la performance commerciale

### 3.1 Les 6 KPIs essentiels

| KPI | Définition | Cible démarrage |
|---|---|---|
| **Nombre de prospects qualifiés** | Fichier prospect actif et exploitable | 150-200 en 3 mois |
| **Taux de prise de RDV** | RDV obtenus / appels passés | 8-12 % |
| **Taux de conversion devis → commande** | Commandes signées / devis envoyés | 25-40 % |
| **Délai de conversion** | Jours moyens entre 1er contact et 1re commande | 30-60 j en B2B |
| **Panier moyen** | CA / nombre de clients | À mesurer après mois 3 |
| **Taux de rétention** | Clients réguliers / clients au mois 3 | > 70 % |

### 3.2 Mini-exercice guidé

> ✏️ **À vous**
>
> Sur 3 mois, vous avez :
> - 180 appels passés
> - 25 RDV obtenus
> - 12 devis envoyés
> - 4 commandes signées
>
> Calculez vos taux et identifiez le maillon faible.

**Correction :**

| KPI | Calcul | Résultat | Cible |
|---|---|---|---|
| Taux RDV | 25/180 | **13,9 %** | 8-12 % ✅ Bon |
| Taux RDV → devis | 12/25 | **48 %** | 60-70 % ⚠️ |
| Taux devis → commande | 4/12 | **33 %** | 25-40 % ✅ |
| Taux global | 4/180 | **2,2 %** | 3 % ⚠️ |

→ **Maillon faible** : RDV → devis (48 % vs cible 60-70 %). Pendant le RDV, vous ne convertissez pas suffisamment d'intérêt en demande de devis. Travail à faire sur le **discours commercial en RDV** : besoins clients, objections, valeur ajoutée.

---

## 4. La fidélisation : transformer 1 commande en relation longue

### 4.1 Coût d'acquisition vs coût de rétention

| Type d'effort | Coût relatif |
|---|---|
| Acquérir un nouveau client | **5 à 7 fois** plus cher que retenir un actif |
| Une augmentation de **5 % du taux de rétention** = **+25 à +95 %** de profit (étude Bain & Co) |

### 4.2 Les 4 piliers de la fidélisation transport

| Pilier | Action concrète |
|---|---|
| **1. Fiabilité opérationnelle** | Ponctualité absolue (≤ 5 min de retard sur RDV livraison), zéro casse, communication proactive en cas d'imprévu |
| **2. Communication régulière** | Email mensuel avec infos sectorielles, appel trimestriel pour faire le point, carte de vœux |
| **3. Service supplémentaire offert** | Une attente exceptionnelle gratuite, un dépannage week-end, une prise en charge de matériel encombrant |
| **4. Programme de fidélité** | Remise quantitative (− 5 % au-dessus de 50 livraisons/mois), parrainage incentivé, conditions de paiement préférentielles |

### 4.3 Cas pratique 3 — Plan de fidélisation

> 🚛 **Mise en situation**
>
> Après 12 mois, vous avez 8 clients réguliers. **3** représentent 70 % de votre CA. **5** représentent 30 %. Comment construisez-vous votre plan de fidélisation ?

**Correction proposée :**

| Cluster | Action |
|---|---|
| **Top 3** (70 % CA) | Visite trimestrielle physique, dîner d'affaires annuel, dégressivité tarifaire au volume, contact direct WhatsApp avec le dirigeant |
| **Suivants 5** (30 % CA) | Email mensuel personnalisé, appel semestriel, offre parrainage |
| **Anciens clients dormants** | Appel de réactivation tous les 3 mois avec offre spéciale |
| **Tous** | Carte de vœux fin d'année, demande d'avis Google après livraisons clés |

**Risque à anticiper** : la dépendance aux 3 premiers clients (70 % CA). Si l'un part, c'est -25 % de CA. **Action de diversification** = continuer à prospecter activement même quand le carnet est plein.

---

## 5. Glossaire des notions clés

| Terme | Définition |
|---|---|
| **AIDA** | Attention / Intérêt / Désir / Action — structure d'un argumentaire commercial |
| **Prospection** | Démarche active d'acquisition de nouveaux clients |
| **Pipeline commercial** | File des opportunités à différents stades (prospect, RDV, devis, commande) |
| **Taux de conversion** | Pourcentage d'opportunités qui passent à l'étape suivante |
| **Closing** | Phase finale de signature d'un contrat |
| **Devis** | Proposition tarifée détaillée, valable un certain délai |
| **CRM** | Customer Relationship Management — outil de gestion du fichier client |
| **Fidélisation** | Action visant à maintenir un client actif dans la durée |
| **Rétention** | Pourcentage de clients qui restent actifs sur une période |
| **Parrainage** | Récompense d'un client qui amène un nouveau client |
| **KPI** | Key Performance Indicator (indicateur clé de performance) |

---

## 🧠 Synthèse opérationnelle

> 📌 **Les 8 points à retenir**
>
> 1. **Cycle commercial** = prospection → conversion → fidélisation. Les 3 phases sont indispensables.
> 2. **Règle statistique** : 100 appels donnent ~ 3 commandes (varie de 1 à 7 % selon préparation).
> 3. **Fichier prospect cible** : 150-200 contacts qualifiés au démarrage.
> 4. **Méthode AIDA** structure un appel : Attention / Intérêt / Désir / Action.
> 5. **Devis** : sous 24 h, validité 30 j, 2-3 variantes (Eco/Std/Premium), avec référence client.
> 6. **6 KPIs commerciaux** à suivre : prospects qualifiés, taux RDV, taux devis, taux conversion, panier moyen, rétention.
> 7. **Fidéliser coûte 5 à 7 fois moins cher** qu'acquérir + augmente profit jusqu'à 95 %.
> 8. **4 piliers fidélisation** : fiabilité, communication, service offert, programme structuré.

---

## 🎓 Ce que l'examinateur peut demander

1. **« Citez les phases du cycle commercial. »** → Prospection / Conversion / Fidélisation.
2. **« Qu'est-ce que la méthode AIDA ? »** → Attention / Intérêt / Désir / Action — structure d'argumentaire.
3. **« Pourquoi est-il moins cher de fidéliser qu'acquérir ? »** → Pas de coût d'acquisition, panier moyen plus élevé, parrainage gratuit, moins de SAV.
4. **« Quels sont les 6 KPIs commerciaux clés ? »** → Prospects qualifiés / Taux RDV / Taux devis / Taux conversion / Panier moyen / Rétention.
5. **Cas en QR** : Calculer un taux de conversion ou identifier un maillon faible dans un funnel commercial.

---

## 📋 Mémo à imprimer

```
CYCLE COMMERCIAL    Prospection → Conversion → Fidélisation

PROSPECTION
  Volume cible      150-200 prospects qualifiés en 3 mois
  Règle statistique 100 appels → 3 commandes
  Méthode appel     AIDA (Attention / Intérêt / Désir / Action)

DEVIS
  Délai             Sous 24 h
  Validité          30 jours
  Variantes         Eco / Standard / Premium
  Référence client  Indispensable pour crédibiliser

KPIs COMMERCIAUX (à suivre mensuellement)
  1. Prospects qualifiés
  2. Taux de RDV (cible 8-12 %)
  3. Taux RDV → devis (cible 60-70 %)
  4. Taux devis → commande (cible 25-40 %)
  5. Panier moyen
  6. Taux de rétention (cible > 70 %)

FIDÉLISATION
  Coût ÷ 5 à 7 vs acquisition
  +5 % rétention = +25 à +95 % profit
  4 piliers : fiabilité, communication, service offert, programme
```
$lessonB3$,
'Construire et exploiter un fichier de prospects, conduire un appel structuré (AIDA), rédiger un devis qui convertit, mesurer la performance commerciale et fidéliser efficacement.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- BANQUE DE QCM REFORMULÉS — Module B (36 questions, 12 par leçon)
  -- =================================================================

  -- ─── LEÇON 1 — Étude de marché (12 QCM) ───
  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qcm', 'Quelles sont les 3 composantes d''un marché en transport ?',
   '[{"id":"a","label":"Offre, demande, environnement","is_correct":true},{"id":"b","label":"Prix, produit, distribution","is_correct":false},{"id":"c","label":"Vendeur, acheteur, banque","is_correct":false},{"id":"d","label":"DREAL, URSSAF, RCS","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-b','capa-3-5t','lecon-1','marche'], 'mft-2026:moduleB:qcm:1', true,
   'Les 3 composantes : offre (transporteurs disponibles), demande (chargeurs), environnement (cadre PESTEL : politique, économique, social, technologique, écologique, légal).'),

  (v_formation, 'qcm', 'Que signifie l''acronyme SWOT ?',
   '[{"id":"a","label":"Service / Work / Organize / Time","is_correct":false},{"id":"b","label":"Strengths / Weaknesses / Opportunities / Threats","is_correct":true},{"id":"c","label":"Stratégie / Web / Outils / Tactique","is_correct":false},{"id":"d","label":"Structure / Workflow / Outcome / Timing","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-b','capa-3-5t','lecon-1','swot'], 'mft-2026:moduleB:qcm:2', true,
   'Strengths (forces), Weaknesses (faiblesses) — internes au projet ; Opportunities (opportunités), Threats (menaces) — externes au marché.'),

  (v_formation, 'qcm', 'Qu''est-ce qu''une demande dérivée en transport ?',
   '[{"id":"a","label":"Une demande temporaire qui disparaît rapidement","is_correct":false},{"id":"b","label":"Une demande qui dépend d''une autre activité économique","is_correct":true},{"id":"c","label":"Une demande imposée par la réglementation","is_correct":false},{"id":"d","label":"Une demande émise par un sous-traitant","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-b','capa-3-5t','lecon-1','marche'], 'mft-2026:moduleB:qcm:3', true,
   'La demande de transport dépend de l''activité économique générale (production, commerce, e-commerce). Si l''économie ralentit, la demande de transport diminue mécaniquement.'),

  (v_formation, 'qcm', 'Quelle source d''information donne le bilan détaillé d''une entreprise prospect ?',
   '[{"id":"a","label":"INSEE","is_correct":false},{"id":"b","label":"Pappers ou Société.com","is_correct":true},{"id":"c","label":"L''annuaire des Pages Jaunes","is_correct":false},{"id":"d","label":"Le Bon Coin","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-b','capa-3-5t','lecon-1','etude-marche'], 'mft-2026:moduleB:qcm:4', true,
   'Pappers et Société.com agrègent les bilans déposés au greffe : CA, effectif, dirigeants, procédures collectives. Outils gratuits indispensables en prospection B2B.'),

  (v_formation, 'qcm', 'PESTEL est l''acronyme de :',
   '[{"id":"a","label":"Personnel, Économique, Sécurité, Technique, Écologique, Légal","is_correct":false},{"id":"b","label":"Politique, Économique, Sociologique, Technologique, Écologique, Légal","is_correct":true},{"id":"c","label":"Production, Évaluation, Stratégie, Test, Étude, Logistique","is_correct":false},{"id":"d","label":"Marketing-mix complet","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-b','capa-3-5t','lecon-1','pestel'], 'mft-2026:moduleB:qcm:5', true,
   'PESTEL est une grille d''analyse de l''environnement : 6 facteurs externes qui impactent l''entreprise. En transport : ZFE-m (écologique), TVA (légal), prime véhicule propre (politique), e-commerce (sociologique), GPS (technologique), gazole (économique).'),

  (v_formation, 'qcm', 'Combien de scénarios de CA prévisionnel doit-on préparer ?',
   '[{"id":"a","label":"1 seul, le plus probable","is_correct":false},{"id":"b","label":"2 (optimiste et pessimiste)","is_correct":false},{"id":"c","label":"3 (pessimiste, réaliste, optimiste)","is_correct":true},{"id":"d","label":"5 ou plus pour finesse","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-b','capa-3-5t','lecon-1','ca-previsionnel'], 'mft-2026:moduleB:qcm:6', true,
   '3 scénarios : pessimiste (besoin de trésorerie), réaliste (BP banque), optimiste (plan d''embauche futur). Préparer un seul scénario expose à des surprises.'),

  (v_formation, 'qcm', 'Le marché du transport routier de marchandises ≤ 3,5 t en France est qualifié de :',
   '[{"id":"a","label":"Marché oligopolistique (peu de gros acteurs)","is_correct":false},{"id":"b","label":"Marché atomisé (très nombreuses petites entreprises)","is_correct":true},{"id":"c","label":"Monopole d''État","is_correct":false},{"id":"d","label":"Monopole privé","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-b','capa-3-5t','lecon-1','marche'], 'mft-2026:moduleB:qcm:7', true,
   'Atomisé = ≈ 75 000 entreprises en France, 60 % de TPE de moins de 5 salariés. Pas de leader dominant, forte concurrence locale.'),

  (v_formation, 'qcm', 'Parmi ces segments transport, lequel offre généralement les marges les PLUS élevées ?',
   '[{"id":"a","label":"B2B distribution récurrente","is_correct":false},{"id":"b","label":"B2A administrations","is_correct":false},{"id":"c","label":"B2C express (déménagement, livraison meubles)","is_correct":true},{"id":"d","label":"Sous-traitance pour grand opérateur","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-b','capa-3-5t','lecon-1','segments'], 'mft-2026:moduleB:qcm:8', true,
   'B2C express : marges 20-30 % (paiement comptant, urgence valorisée). B2B et B2A : marges 8-15 % (volume mais paiement long et négociation forte).'),

  (v_formation, 'qcm', 'Lors d''une étude de la concurrence, le « téléphone mystère » consiste à :',
   '[{"id":"a","label":"Appeler son banquier pour préparer son crédit","is_correct":false},{"id":"b","label":"Se présenter comme prospect auprès de concurrents pour évaluer leurs offres","is_correct":true},{"id":"c","label":"Faire écouter ses appels par un coach","is_correct":false},{"id":"d","label":"Utiliser un service de standard externalisé","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-b','capa-3-5t','lecon-1','concurrence'], 'mft-2026:moduleB:qcm:9', true,
   'Technique classique d''audit concurrentiel : appeler 5 concurrents en se présentant comme prospect, noter délais, tarifs, ton commercial. Légal et très instructif.'),

  (v_formation, 'qcm', 'Quel est le seuil de chiffre d''affaires annuel pour rester en micro-entreprise (auto-entrepreneur) en transport en 2026 ?',
   '[{"id":"a","label":"36 800 €","is_correct":false},{"id":"b","label":"77 700 €","is_correct":true},{"id":"c","label":"176 200 €","is_correct":false},{"id":"d","label":"247 100 €","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-b','capa-3-5t','lecon-1','auto-entrepreneur'], 'mft-2026:moduleB:qcm:10', true,
   'Plafond micro pour les prestations de services (transport, BTP, conseil) : 77 700 € en 2026. Au-delà, bascule en régime réel (BNC ou BIC réel).'),

  (v_formation, 'qcm', 'Quel acteur publie des indices de coût utiles à la fixation du prix transport (CRKM, gazole) ?',
   '[{"id":"a","label":"INSEE","is_correct":false},{"id":"b","label":"Le Comité National Routier (CNR)","is_correct":true},{"id":"c","label":"L''URSSAF","is_correct":false},{"id":"d","label":"La DREAL","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-b','capa-3-5t','lecon-1','cnr'], 'mft-2026:moduleB:qcm:11', true,
   'Le CNR publie chaque trimestre des indices de coûts (gazole, salaires, péages, matériel) et des grilles tarifaires sectorielles. Indispensable pour réviser ses prix.'),

  (v_formation, 'qcm', 'Combien de prospects qualifiés cible-t-on classiquement en démarrage solo en 3 mois ?',
   '[{"id":"a","label":"30","is_correct":false},{"id":"b","label":"50","is_correct":false},{"id":"c","label":"150 à 200","is_correct":true},{"id":"d","label":"1 000 ou plus","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-b','capa-3-5t','lecon-1','prospection'], 'mft-2026:moduleB:qcm:12', true,
   '150-200 prospects qualifiés sur 3 mois est la base saine pour soutenir le rythme commercial : 100 appels donnent statistiquement 3 commandes.'),

  -- ─── LEÇON 2 — Politique commerciale (12 QCM) ───
  (v_formation, 'qcm', 'Que signifie le sigle « 4P » en marketing ?',
   '[{"id":"a","label":"Politique / Production / Profit / Performance","is_correct":false},{"id":"b","label":"Produit / Prix / Place / Promotion","is_correct":true},{"id":"c","label":"Pro / Particulier / Public / Privé","is_correct":false},{"id":"d","label":"Plan / Production / Prospect / Paiement","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-b','capa-3-5t','lecon-2','marketing-mix'], 'mft-2026:moduleB:qcm:13', true,
   'Les 4P du marketing-mix : Produit (offre), Prix, Place (distribution), Promotion (communication). Tous doivent être cohérents entre eux.'),

  (v_formation, 'qcm', 'Le CRKM (coût de revient kilométrique) moyen d''un VUL ≤ 3,5 t en France est de :',
   '[{"id":"a","label":"0,40 à 0,55 €/km","is_correct":false},{"id":"b","label":"0,90 à 1,10 €/km","is_correct":true},{"id":"c","label":"1,80 à 2,00 €/km","is_correct":false},{"id":"d","label":"2,50 à 3,00 €/km","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-b','capa-3-5t','lecon-2','crkm'], 'mft-2026:moduleB:qcm:14', true,
   'CRKM tout compris : 0,90 à 1,10 €/km (leasing + carburant + URSSAF + entretien + assurance). Vendre en dessous = vente à perte.'),

  (v_formation, 'qcm', 'Le seuil de rentabilité se calcule par la formule :',
   '[{"id":"a","label":"Charges fixes / Marge sur coûts variables","is_correct":true},{"id":"b","label":"Charges totales / 12 mois","is_correct":false},{"id":"c","label":"CA × Marge nette","is_correct":false},{"id":"d","label":"Bénéfice / Capital","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-b','capa-3-5t','lecon-2','seuil-rentabilite'], 'mft-2026:moduleB:qcm:15', true,
   'SR = CF / Taux de marge sur CV. Au-dessus du SR, chaque km supplémentaire génère de la marge. En dessous, perte.'),

  (v_formation, 'qcm', 'Parmi ces postes, lequel est une CHARGE VARIABLE en transport ?',
   '[{"id":"a","label":"L''assurance du VUL","is_correct":false},{"id":"b","label":"Le crédit-bail mensuel","is_correct":false},{"id":"c","label":"Le carburant","is_correct":true},{"id":"d","label":"L''abonnement téléphonique","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-b','capa-3-5t','lecon-2','charges'], 'mft-2026:moduleB:qcm:16', true,
   'Charge variable = proportionnelle au volume d''activité. Le carburant varie avec les km parcourus. L''assurance, le leasing et l''abonnement sont fixes.'),

  (v_formation, 'qcm', 'Vendre via une plateforme intermédiaire type Stuart implique généralement :',
   '[{"id":"a","label":"Une augmentation de marge de 30 %","is_correct":false},{"id":"b","label":"Une commission de 15 à 30 % prélevée sur chaque course","is_correct":true},{"id":"c","label":"Une exonération de TVA","is_correct":false},{"id":"d","label":"Un capital minimum requis","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-b','capa-3-5t','lecon-2','plateforme'], 'mft-2026:moduleB:qcm:17', true,
   'Les plateformes prélèvent 15-30 % de commission. Avantage : volume rapide. Inconvénient : marge ÷ 1,3 et dépendance au planning de l''app.'),

  (v_formation, 'qcm', 'Quel est l''avantage principal du canal de distribution DIRECT ?',
   '[{"id":"a","label":"Volume immédiat sans prospection","is_correct":false},{"id":"b","label":"Marge maximale et relation client en propre","is_correct":true},{"id":"c","label":"Pas besoin de capacité professionnelle","is_correct":false},{"id":"d","label":"Tarif imposé par l''État","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-b','capa-3-5t','lecon-2','distribution'], 'mft-2026:moduleB:qcm:18', true,
   'Direct = 100 % du tarif pour vous. Inconvénient : prospection chronophage. Stratégie : démarrer en mix direct + plateforme, basculer en majorité direct après 12-18 mois.'),

  (v_formation, 'qcm', 'Une pyramide d''offres bien construite comporte combien de niveaux ?',
   '[{"id":"a","label":"1 seul (le standard)","is_correct":false},{"id":"b","label":"2 (économique et premium)","is_correct":false},{"id":"c","label":"3 (économique, standard, premium)","is_correct":true},{"id":"d","label":"5 minimum","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-b','capa-3-5t','lecon-2','pyramide-offres'], 'mft-2026:moduleB:qcm:19', true,
   '3 niveaux : Eco (-10/-15 %), Standard (tarif marché), Premium (+20/+30 %). Le Premium représente 15-25 % du CA mais 35-50 % de la marge.'),

  (v_formation, 'qcm', 'Le flocage de votre VUL avec votre logo et vos coordonnées coûte typiquement :',
   '[{"id":"a","label":"30-50 €","is_correct":false},{"id":"b","label":"200-500 €","is_correct":true},{"id":"c","label":"1 000-2 000 €","is_correct":false},{"id":"d","label":"5 000-10 000 €","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-b','capa-3-5t','lecon-2','communication'], 'mft-2026:moduleB:qcm:20', true,
   'Flocage VUL : 200-500 € selon complexité. Excellent rapport coût/exposition (publicité mobile permanente, 30 000 vues/jour en circulation urbaine).'),

  (v_formation, 'qcm', 'Pour un transporteur, le canal d''acquisition n° 1 reste :',
   '[{"id":"a","label":"La publicité Facebook","is_correct":false},{"id":"b","label":"Le bouche-à-oreille (recommandation client)","is_correct":true},{"id":"c","label":"Les annonces TV","is_correct":false},{"id":"d","label":"La distribution de flyers en boîtes aux lettres","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-b','capa-3-5t','lecon-2','acquisition'], 'mft-2026:moduleB:qcm:21', true,
   'Le bouche-à-oreille (recommandation, avis Google, parrainage) est l''acquisition la plus puissante en transport B2B et B2C. À structurer activement (incentive, demandes d''avis).'),

  (v_formation, 'qcm', 'Si vos charges fixes sont 18 000 €/an et votre marge unitaire 0,60 €/km, votre seuil de rentabilité en km est :',
   '[{"id":"a","label":"10 800 km","is_correct":false},{"id":"b","label":"30 000 km","is_correct":true},{"id":"c","label":"45 000 km","is_correct":false},{"id":"d","label":"60 000 km","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-b','capa-3-5t','lecon-2','seuil-rentabilite','calcul'], 'mft-2026:moduleB:qcm:22', true,
   'Seuil = 18 000 € / 0,60 €/km = 30 000 km/an, soit 2 500 km/mois ou 115 km/jour ouvré (22 j). Au-dessus de 30 000 km, chaque km supplémentaire génère 0,60 € de marge.'),

  (v_formation, 'qcm', 'En transport routier de marchandises, le délai légal max de paiement entre pros est de :',
   '[{"id":"a","label":"15 jours","is_correct":false},{"id":"b","label":"30 jours date de facture","is_correct":true},{"id":"c","label":"60 jours nets","is_correct":false},{"id":"d","label":"90 jours fin de mois","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-b','capa-3-5t','lecon-2','delai-paiement'], 'mft-2026:moduleB:qcm:23', true,
   '30 j date de facture max en transport (article L. 441-11 C. com.) — règle d''ordre public. Le client ne peut pas imposer 60 j même par contrat.'),

  (v_formation, 'qcm', 'Une augmentation de 5 % du taux de rétention client peut générer combien de profit supplémentaire selon les études ?',
   '[{"id":"a","label":"+1 à +5 %","is_correct":false},{"id":"b","label":"+10 à +15 %","is_correct":false},{"id":"c","label":"+25 à +95 %","is_correct":true},{"id":"d","label":"+200 % minimum","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-b','capa-3-5t','lecon-2','fidelisation'], 'mft-2026:moduleB:qcm:24', true,
   'Étude Bain & Co classique : +5 % de rétention = +25 à +95 % de profit, car suppression du coût d''acquisition + augmentation du panier moyen + parrainage généré.'),

  -- ─── LEÇON 3 — Prospecter et fidéliser (12 QCM) ───
  (v_formation, 'qcm', 'La méthode AIDA structure :',
   '[{"id":"a","label":"Un bilan comptable","is_correct":false},{"id":"b","label":"Un argumentaire commercial téléphonique","is_correct":true},{"id":"c","label":"Une étude de marché","is_correct":false},{"id":"d","label":"Une déclaration TVA","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-b','capa-3-5t','lecon-3','aida'], 'mft-2026:moduleB:qcm:25', true,
   'AIDA = Attention / Intérêt / Désir / Action. Structure d''argumentaire pour un appel de prospection ou une visite client.'),

  (v_formation, 'qcm', 'Statistiquement, sur 100 appels de prospection bien préparés, combien de commandes obtient-on ?',
   '[{"id":"a","label":"≈ 1","is_correct":false},{"id":"b","label":"≈ 3","is_correct":true},{"id":"c","label":"≈ 15","is_correct":false},{"id":"d","label":"≈ 50","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-b','capa-3-5t','lecon-3','prospection-stats'], 'mft-2026:moduleB:qcm:26', true,
   '100 appels → 30 conversations → 10 demandes de devis → 3 commandes. Taux de conversion global ~ 3 % avec une bonne préparation. Mauvais commerciaux : 1-2 %, bons : 5-7 %.'),

  (v_formation, 'qcm', 'La validité standard d''un devis transport est de :',
   '[{"id":"a","label":"7 jours","is_correct":false},{"id":"b","label":"30 jours","is_correct":true},{"id":"c","label":"3 mois","is_correct":false},{"id":"d","label":"À durée indéterminée","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-b','capa-3-5t','lecon-3','devis'], 'mft-2026:moduleB:qcm:27', true,
   '30 jours est la durée standard. Crée de l''urgence sans paraître pressant. Valable plus longtemps : risque de ne plus refléter vos coûts (carburant variable).'),

  (v_formation, 'qcm', 'Un devis envoyé sous 24 h convertit, par rapport à un devis envoyé sous 5 jours :',
   '[{"id":"a","label":"Au même taux","is_correct":false},{"id":"b","label":"2 fois plus","is_correct":false},{"id":"c","label":"3 fois plus","is_correct":true},{"id":"d","label":"10 fois moins","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-b','capa-3-5t','lecon-3','devis','reactivite'], 'mft-2026:moduleB:qcm:28', true,
   'La réactivité est un signal commercial puissant. Sous 24 h vs 5 jours : taux de conversion x 3 typiquement (chiffre métier). Le prospect a perdu son urgence ou choisi un concurrent au-delà de 48 h.'),

  (v_formation, 'qcm', 'Le coût d''acquisition d''un nouveau client est, en moyenne, combien de fois plus cher que la rétention d''un client existant ?',
   '[{"id":"a","label":"Identique","is_correct":false},{"id":"b","label":"2 fois plus cher","is_correct":false},{"id":"c","label":"5 à 7 fois plus cher","is_correct":true},{"id":"d","label":"100 fois plus cher","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-b','capa-3-5t','lecon-3','fidelisation'], 'mft-2026:moduleB:qcm:29', true,
   '5 à 7 fois plus coûteux : prospection, démarchage, montée en charge, période de test client. D''où l''importance d''investir dans la fidélisation des clients existants.'),

  (v_formation, 'qcm', 'Un taux de prise de RDV de 13 % sur 180 appels signifie :',
   '[{"id":"a","label":"13 RDV obtenus","is_correct":false},{"id":"b","label":"23 RDV obtenus","is_correct":true},{"id":"c","label":"100 RDV obtenus","is_correct":false},{"id":"d","label":"180 RDV obtenus","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['module-b','capa-3-5t','lecon-3','kpis','calcul'], 'mft-2026:moduleB:qcm:30', true,
   '13 % × 180 = 23,4 ≈ 23 RDV. Performance bonne (cible 8-12 % donc au-dessus). Vérifier ensuite le taux RDV → devis et devis → commande.'),

  (v_formation, 'qcm', 'Lequel de ces 6 KPIs commerciaux n''est PAS pertinent à suivre mensuellement en démarrage ?',
   '[{"id":"a","label":"Nombre de prospects qualifiés","is_correct":false},{"id":"b","label":"Taux de conversion devis → commande","is_correct":false},{"id":"c","label":"Cours de l''action de votre concurrent en bourse","is_correct":true},{"id":"d","label":"Taux de rétention client","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-b','capa-3-5t','lecon-3','kpis'], 'mft-2026:moduleB:qcm:31', true,
   'Les 6 KPIs : prospects qualifiés, taux RDV, taux RDV→devis, taux devis→commande, panier moyen, rétention. Le cours de bourse d''un concurrent n''est pas un indicateur de pilotage commercial.'),

  (v_formation, 'qcm', 'Lors d''un appel de prospection, à quelle étape demande-t-on l''autorisation de continuer (« avez-vous 2 minutes ? ») ?',
   '[{"id":"a","label":"Après s''être présenté (étape Attention)","is_correct":true},{"id":"b","label":"À la toute fin","is_correct":false},{"id":"c","label":"Jamais, on enchaîne directement","is_correct":false},{"id":"d","label":"Au moment de demander un RDV","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-b','capa-3-5t','lecon-3','aida'], 'mft-2026:moduleB:qcm:32', true,
   'Après l''étape Attention (présentation), demander la permission respecte le prospect et augmente l''engagement. « Bonjour, je suis [X] de [Y]. Avez-vous 30 secondes ? »'),

  (v_formation, 'qcm', 'Parmi ces 4 piliers de fidélisation, lequel est le plus IMPORTANT en transport ?',
   '[{"id":"a","label":"La fiabilité opérationnelle (ponctualité, zéro casse)","is_correct":true},{"id":"b","label":"Le prix le plus bas du marché","is_correct":false},{"id":"c","label":"Un cadeau de fin d''année","is_correct":false},{"id":"d","label":"Une présence sur les réseaux sociaux","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-b','capa-3-5t','lecon-3','fidelisation'], 'mft-2026:moduleB:qcm:33', true,
   'En transport, la fiabilité opérationnelle (ponctualité, intégrité de la marchandise, communication proactive) prime sur tout. Un client perdu pour casse ou retard ne revient quasi jamais.'),

  (v_formation, 'qcm', 'Si vos top 3 clients représentent 70 % de votre CA, le risque principal est :',
   '[{"id":"a","label":"Aucun, c''est une situation idéale","is_correct":false},{"id":"b","label":"Une dépendance forte ; le départ d''un seul client peut coûter -25 % de CA","is_correct":true},{"id":"c","label":"Une augmentation de l''impôt sur les sociétés","is_correct":false},{"id":"d","label":"Un blocage par l''URSSAF","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-b','capa-3-5t','lecon-3','dependance-clients'], 'mft-2026:moduleB:qcm:34', true,
   'La concentration de CA est un risque majeur. Règle de bonne gestion : aucun client ne doit représenter plus de 25-30 % du CA. Maintenir une prospection active même quand le carnet est plein.'),

  (v_formation, 'qcm', 'Le « parrainage incentivé » consiste à :',
   '[{"id":"a","label":"Embaucher des proches dans son entreprise","is_correct":false},{"id":"b","label":"Offrir une remise au client qui amène un nouveau client","is_correct":true},{"id":"c","label":"Verser un dividende aux associés","is_correct":false},{"id":"d","label":"Payer ses cotisations URSSAF en avance","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['module-b','capa-3-5t','lecon-3','fidelisation'], 'mft-2026:moduleB:qcm:35', true,
   'Parrainage : « pour chaque nouveau client recommandé, -10 % sur votre prochaine course ». Outil très puissant en transport, à coût marginal nul.'),

  (v_formation, 'qcm', 'Quel est l''outil GRATUIT n° 1 pour améliorer son référencement local en transport ?',
   '[{"id":"a","label":"Un site e-commerce","is_correct":false},{"id":"b","label":"Google Business Profile","is_correct":true},{"id":"c","label":"Un compte Twitter","is_correct":false},{"id":"d","label":"Un blog wordpress","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['module-b','capa-3-5t','lecon-3','communication'], 'mft-2026:moduleB:qcm:36', true,
   'Google Business Profile (ex Google My Business) : gratuit, présence sur Google Maps, avis clients, photos, horaires. Indispensable pour le transport local.');

  -- =================================================================
  -- BANQUE DE QR — Module B : SUPPRIMÉE selon décision client (mai 2026)
  -- Le module B se concentre uniquement sur les QCM (36 QCM, 3 leçons).
  -- Les QR ont été redistribuées vers les modules D et E.
  -- =================================================================

  -- =================================================================
  -- QUIZZES par leçon — chacun 12 QCM + lien vers la banque
  -- =================================================================

  -- Quiz Leçon 1 (12 QCM)
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Étude de marché — Quiz',
          'Quiz d''entraînement (12 questions) sur l''étude de marché transport, le SWOT, la segmentation et les scénarios de CA.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleB:qcm:1','mft-2026:moduleB:qcm:2','mft-2026:moduleB:qcm:3',
      'mft-2026:moduleB:qcm:4','mft-2026:moduleB:qcm:5','mft-2026:moduleB:qcm:6',
      'mft-2026:moduleB:qcm:7','mft-2026:moduleB:qcm:8','mft-2026:moduleB:qcm:9',
      'mft-2026:moduleB:qcm:10','mft-2026:moduleB:qcm:11','mft-2026:moduleB:qcm:12'
    );

  -- Quiz Leçon 2 (12 QCM)
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Politique commerciale — Quiz',
          'Quiz d''entraînement (12 questions) sur les 4P du marketing-mix, le CRKM, le seuil de rentabilité et les canaux de distribution.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleB:qcm:13','mft-2026:moduleB:qcm:14','mft-2026:moduleB:qcm:15',
      'mft-2026:moduleB:qcm:16','mft-2026:moduleB:qcm:17','mft-2026:moduleB:qcm:18',
      'mft-2026:moduleB:qcm:19','mft-2026:moduleB:qcm:20','mft-2026:moduleB:qcm:21',
      'mft-2026:moduleB:qcm:22','mft-2026:moduleB:qcm:23','mft-2026:moduleB:qcm:24'
    );

  -- Quiz Leçon 3 (12 QCM)
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Prospection et fidélisation — Quiz',
          'Quiz d''entraînement (12 questions) sur la prospection (AIDA), le devis, les KPIs commerciaux et la fidélisation.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleB:qcm:25','mft-2026:moduleB:qcm:26','mft-2026:moduleB:qcm:27',
      'mft-2026:moduleB:qcm:28','mft-2026:moduleB:qcm:29','mft-2026:moduleB:qcm:30',
      'mft-2026:moduleB:qcm:31','mft-2026:moduleB:qcm:32','mft-2026:moduleB:qcm:33',
      'mft-2026:moduleB:qcm:34','mft-2026:moduleB:qcm:35','mft-2026:moduleB:qcm:36'
    );

  -- =================================================================
  -- EXAMEN BLANC Module B — 12 QCM (45 min, seuil 50 %)
  -- =================================================================
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold, is_mock_exam)
  VALUES (v_module, 'Examen blanc — Module B',
          'Examen blanc reproduisant les conditions de l''examen national : 12 QCM transversaux couvrant les 3 leçons, durée 45 minutes, seuil 50 %.',
          'examen', 2700, 50, true)
  RETURNING id INTO v_quiz_eb;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleB:qcm:1','mft-2026:moduleB:qcm:5','mft-2026:moduleB:qcm:8',
      'mft-2026:moduleB:qcm:13','mft-2026:moduleB:qcm:14','mft-2026:moduleB:qcm:15',
      'mft-2026:moduleB:qcm:18','mft-2026:moduleB:qcm:22','mft-2026:moduleB:qcm:25',
      'mft-2026:moduleB:qcm:29','mft-2026:moduleB:qcm:33','mft-2026:moduleB:qcm:36'
    );

  -- QR retirées de l'examen blanc (décision client mai 2026)

  RAISE NOTICE '✅ Module B v3 chargé : 3 leçons, 36 QCM, 0 QR, 4 quizzes (3 entraînement + 1 examen blanc 12 QCM).';
END
$module_b_v3$;

