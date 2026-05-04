-- =====================================================================
-- MODULE B — L'ENTREPRISE ET SON ACTIVITÉ COMMERCIALE (Capacité ≤ 3,5 T)
-- Version 2 (mai 2026) — refonte complète depuis PDF officiels.
--
-- Référentiel (décision du 2 avril 2012) :
--   ▸ savoir élaborer une étude de marché
--   ▸ savoir définir une politique de prix, produit, distribution
--   ▸ maîtriser les outils de prospection commerciale
-- Examen national : QCM de 2 questions (2 pts/question = 4 pts).
--
-- ▸ 3 leçons rédigées en markdown (tableaux, listes, callouts — pas
--   de schémas ASCII, retour utilisateur)
-- ▸ 20 QCM reformulés (préfixe source_ref mft-2026:moduleB:qcm:N)
-- ▸ 4 QR transport (max_score 5)
-- ▸ Quizzes par leçon + 1 examen blanc Module B
--
-- Idempotent : DELETE module ciblé puis recréation. Safe à rejouer.
-- Pré-requis : formation 'capacite-3-5t' présente.
-- =====================================================================

DO $module_b_v2$
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
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'capacite-3-5t';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation capacite-3-5t introuvable.';
  END IF;

  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN
    RAISE EXCEPTION 'Aucun bloc défini.';
  END IF;

  -- Reset propre du module
  DELETE FROM public.modules WHERE slug = 'capa-activite-commerciale';

  INSERT INTO public.modules (
    title, slug, bloc_id, summary, difficulty, duration_min, "order"
  ) VALUES (
    'Module B — L''entreprise et son activité commerciale',
    'capa-activite-commerciale',
    v_bloc,
    'Élaborer une étude de marché, définir une politique commerciale (prix, produit, distribution) et maîtriser la prospection : les fondamentaux du marketing pour le transporteur léger.',
    'intermediaire',
    100,
    20
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 20, true)
  ON CONFLICT DO NOTHING;

  -- Reset banque Module B
  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026:moduleB:%';

  -- =================================================================
  -- LEÇON 1 — Comprendre son marché : l'étude de marché
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Comprendre son marché : l''étude de marché',
    'etude-de-marche',
    1, 30,
$lesson1$
# Comprendre son marché : l'étude de marché

Avant de lancer son activité de transporteur, ou avant d'investir dans un nouveau service (livraison express, transport de matières dangereuses, etc.), il faut **mesurer le terrain**. C'est l'objet de l'étude de marché : un travail méthodique qui répond à une question simple : *« y a-t-il assez de clients pour que mon offre soit rentable ?»*

> 🎯 **Objectifs de la leçon**
>
> - Connaître la définition légale et opérationnelle de l'**étude de marché**.
> - Maîtriser les **4 étapes** de la méthodologie.
> - Distinguer **données primaires** et **données secondaires**.
> - Choisir entre une étude **qualitative** et **quantitative**.

---

## 1. Définition

> **Étude de marché** : une enquête structurée visant à identifier, analyser et mesurer les caractéristiques d'un marché.

C'est un **outil de décision**, pas un exercice théorique. Elle permet d'évaluer :

| Dimension | Question typique |
|---|---|
| **Concurrents** | Combien d'acteurs ? Quels sont leurs prix ? Leurs forces ? |
| **Demande** | Combien de clients potentiels ? Quels besoins non couverts ? |
| **Comportements** | Comment les clients choisissent-ils leur transporteur ? |
| **Potentiel d'évolution** | Le marché est-il en croissance, stable ou en déclin ? |
| **Investissement requis** | Combien faut-il pour entrer sur ce marché ? |

> 🚛 **Cas transport**
>
> Vous voulez vous lancer comme **coursier dernier kilomètre** à Meaux. L'étude de marché vous dira combien de TPE / PME y sont implantées, combien expédient déjà, à quel prix, avec quel concurrent, et si votre service serait préféré pour quelle raison (rapidité, prix, fiabilité ?).

---

## 2. Les 4 étapes de la méthode

### 2.1 Définir un objectif précis

Une étude **exhaustive** n'existe pas, et coûte trop cher. **Cadrez** votre objectif pour économiser temps et budget. Exemples d'objectifs précis :

- *« Estimer la demande mensuelle pour des courses < 5 kg en Seine-et-Marne »*
- *« Mesurer le prix moyen pratiqué par les transporteurs locaux pour un colis 30 kg en zone urbaine »*

### 2.2 Construire le plan

Divisez votre étude en **deux types de données** :

| Type | Définition | Exemple |
|---|---|---|
| **Données primaires** | Données que vous collectez vous-même | Sondage en ligne, entretiens avec 20 prospects, observation terrain |
| **Données secondaires** | Données existantes ailleurs | INSEE, études de la FNTR, presse spécialisée, rapports OPCO |

> 💡 **Conseil pratique**
>
> Commencez **toujours** par les données secondaires (gratuites ou peu chères). Elles dégrossissent le travail. Les données primaires viennent ensuite, ciblées sur ce qu'il vous reste à valider.

### 2.3 Organiser la collecte

Selon le type d'étude visée :

| Approche | Outils | Quand l'utiliser |
|---|---|---|
| **Quantitative** | Questionnaire, sondage | Mesurer des fréquences, comparer des chiffres, calculer des taux |
| **Qualitative** | Entretien individuel, focus group | Comprendre des comportements, des motivations, tester un nouveau service |

L'étude **quantitative** s'appuie sur un **échantillon représentatif** (panel) ; l'étude **qualitative** privilégie la profondeur des entretiens, sur un nombre plus limité.

### 2.4 Analyser et restituer

L'analyse consiste à **croiser les données**. Outils classiques :

- **Tableaux croisés** (Excel, Google Sheets) — premier niveau de lecture
- **Analyse des corrélations** — quel critère explique mieux la décision ?
- **Cartographie concurrentielle** — visualiser les positions

L'étude se conclut par un **rapport** structuré : objectif, méthode, résultats, recommandations opérationnelles.

---

## 3. Les éléments à évaluer dans l'étude

L'examen national porte régulièrement sur ces composantes :

| Composante | Ce qu'on cherche |
|---|---|
| **Comportement** ou attitude des clients potentiels | Motivations, freins, critères de choix |
| **Notoriété** de la marque ou du concurrent | % de clients qui connaissent l'offre |
| **Quantités** produites / commercialisées | Volumes du marché total |
| **Chiffre d'affaires prévisionnel** | Projection des recettes |
| **Analyse concurrentielle** | Forces / faiblesses / parts de marché |

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| À quoi sert l'étude de marché ? | À analyser l'offre et la demande pour décider |
| Données primaires | Collectées directement auprès des clients (sondage, entretien) |
| Données secondaires | Issues de sources existantes (INSEE, rapports) |
| Étude quantitative | Pour mesurer (questionnaire, sondage, panel) |
| Étude qualitative | Pour comprendre (entretien, focus group) |
| Échantillon représentatif | Sous-ensemble qui reflète les caractéristiques de la population cible |
$lesson1$,
'Méthodologie en 4 étapes pour analyser son marché : objectif, plan (données primaires/secondaires), collecte (quanti/quali), analyse.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Définir une politique commerciale
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Définir une politique commerciale',
    'politique-commerciale',
    2, 40,
$lesson2$
# Définir une politique commerciale

Une politique commerciale, c'est l'ensemble des choix qu'une entreprise fait pour **vendre**. On parle classiquement de **marketing mix** ou « 4P » : Prix, Produit, Place (distribution), Promotion. Ce module se concentre sur les **3 leviers principaux** demandés par le référentiel : **prix**, **produit**, **distribution**.

> 🎯 **Objectifs de la leçon**
>
> - Définir la **politique de prix** et ses 4 stratégies (écrémage, pénétration, alignement, différenciation).
> - Maîtriser le **cycle de vie d'un produit** et le portefeuille produits.
> - Distinguer **canal**, **circuit** et **réseau** de distribution.
> - Choisir entre distribution **intensive**, **sélective** ou **exclusive**.

---

## 1. La politique de prix

### 1.1 Définition

> **Politique de prix** : ensemble des décisions et actions menées pour fixer le tarif des biens et services. Élément du marketing mix, elle évolue selon le cycle de vie du produit et l'environnement concurrentiel.

Tout commerce est **libre** de fixer ses prix. Mais 4 contraintes pèsent sur ce choix :

| Élément | Question à se poser |
|---|---|
| **Coût d'achat** | Quel est mon coût de revient + marge minimale viable ? |
| **Demande** | Combien le client est-il prêt à payer ? |
| **Concurrence** | Quels sont les prix pratiqués par mes concurrents ? |
| **Lois et règlements** | Suis-je au-dessus du seuil de revente à perte ? |

> ⚠️ **Interdictions majeures**
>
> - **Revente à perte** (prix < coût d'achat HT effectif) — interdite (article L. 442-2 Code de commerce).
> - **Prix abusivement bas** dans le but d'éliminer un concurrent — pratique anticoncurrentielle.

### 1.2 Les 4 objectifs d'une politique de prix

| Objectif | Détail | Exemple transport |
|---|---|---|
| **Rentabilité** | Maximiser la marge sur chaque vente | Prix premium pour un service haut de gamme |
| **Volume** | Maximiser les quantités vendues | Tarif bas pour gagner des courses |
| **Concurrence** | S'aligner sur le marché | Tarif identique aux 3 principaux concurrents |
| **Image de marque** | Construire une perception qualité | Prix élevé pour positionner l'offre |

### 1.3 Les 4 stratégies de prix

| Stratégie | Principe | Cible | Cas typique |
|---|---|---|---|
| **Écrémage** | Prix élevé, segment étroit | Clientèle premium | Lancement d'un produit breveté ou de luxe |
| **Pénétration** | Prix bas, conquête massive | Volume rapide | Établir une norme, dissuader les nouveaux entrants |
| **Alignement** | Prix au niveau des concurrents | Marché stable | Éviter une guerre des prix, asseoir sa crédibilité |
| **Différenciation** | Prix variable selon le segment / contexte | Multi-cibles | Yield management (transport, hôtellerie) |

#### Avantages et inconvénients de chaque stratégie

**Écrémage** :
- ✅ Image haut de gamme renforcée
- ❌ Attire la concurrence (marges visibles)

**Pénétration** :
- ✅ Conquête rapide de parts de marché
- ❌ Marges faibles, nécessite des volumes massifs

**Alignement** :
- ✅ Évite la guerre des prix, génère des revenus stables
- ❌ Perte de différenciation, course vers le bas si tous s'alignent

**Différenciation** (yield management, tarif multidimensionnel) :
- ✅ Optimise le taux de remplissage / d'occupation
- ❌ Complexité de gestion, coûts de mise en place

> 🚛 **Cas transport**
>
> Une entreprise de **navettes aéroport** utilise du **yield management** : le prix d'un trajet Paris-Roissy varie selon la demande (15 € en heure creuse, 35 € le vendredi soir). Elle pratique aussi une **différenciation** : tarif réduit pour étudiants, tarif corporate pour entreprises.

---

## 2. La politique de produit

### 2.1 Les 3 dimensions d'un produit

Un produit n'est jamais qu'un objet matériel. Il a **3 dimensions** :

| Dimension | Définition | Exemple transport |
|---|---|---|
| **Matérielle** | Composition, matériaux, poids, forme | Le VUL : moteur, dimension, charge utile |
| **Fonctionnelle** | À quoi sert le produit, comment l'utilise-t-on | Service de livraison J+1 sécurisée |
| **Psychologique / sociologique** | L'image perçue par le consommateur | « Mon transporteur est fiable et professionnel » |

### 2.2 Le cycle de vie d'un produit

Un produit (ou un service) traverse **4 phases** :

| Phase | Caractéristiques | Stratégie marketing |
|---|---|---|
| **Lancement** | CA décolle, rentabilité négative | Forte communication, offres de lancement |
| **Croissance** | CA croît rapidement, rentabilité positive | Prix plus élevé, intensification distribution |
| **Maturité** | Ventes stabilisées, rentabilité maximale | Baisser les prix, publicité d'entretien |
| **Déclin** | Ventes en baisse, rentabilité diminue | Abandon, relance, ou nouveau produit |

### 2.3 Le portefeuille de produits

L'entreprise gère plusieurs produits dont les rôles diffèrent :

| Type | Rôle |
|---|---|
| **Produit principal** | Cœur de gamme, génère la rentabilité (« vache à lait ») |
| **Produit d'appel** | Premier prix, attire le client en magasin |
| **Produit premium** | Haut de gamme, valorise l'image |
| **Produit tactique** | Capter la clientèle d'un concurrent ou bloquer son offre |
| **Produit de remplacement** | Le futur produit principal, en attente de prendre le relais |
| **Produit complémentaire** | Service ou bien vendu en plus du produit principal |

> ⚠️ **Risque de cannibalisation** : deux produits du même portefeuille peuvent se faire concurrence en interne. Il faut équilibrer la **gamme** (produits par type, ex : VUL léger / VUL lourd) et l'**assortiment** (produits diversifiés, ex : transport + déménagement + stockage).

---

## 3. La politique de distribution

### 3.1 Trois notions à distinguer

| Notion | Définition |
|---|---|
| **Canal de distribution** | Le **chemin** spécifique d'un produit, du fabricant au consommateur final |
| **Circuit de distribution** | L'**ensemble des canaux** utilisés par une entreprise |
| **Réseau de distribution** | Vue globale incluant tous les intermédiaires et points de vente nommés |

### 3.2 La longueur du circuit

Trois niveaux selon le nombre d'intermédiaires :

| Circuit | Intermédiaires | Exemple |
|---|---|---|
| **Ultra court** (vente directe) | Aucun | Producteur de fruits qui vend directement à la ferme |
| **Court** | 1 seul intermédiaire | Producteur → détaillant → consommateur |
| **Long** | Plusieurs intermédiaires | Producteur → grossiste → détaillant → consommateur |

### 3.3 Les 5 acteurs du canal

| Acteur | Rôle |
|---|---|
| **Fabricant / Producteur** | Conçoit et produit |
| **Grossiste** | Achète en gros pour revendre aux détaillants |
| **Détaillant** | Point de vente final |
| **Distributeur** | Logistique et livraison entre fabricant et points de vente |
| **Franchiseur** | Propriétaire d'une marque, accorde des licences à des franchisés |

À noter : les **marketplaces** (Amazon, Cdiscount, eBay) ont émergé comme nouveaux acteurs.

### 3.4 Les 3 stratégies de distribution

| Stratégie | Principe | Quand l'utiliser |
|---|---|---|
| **Intensive** | Produit disponible dans un maximum de points de vente | Produits de grande consommation (sodas, pain) |
| **Sélective** | Nombre limité de points de vente selon des critères qualité | Cosmétiques, électroménager spécialisé |
| **Exclusive** | Très peu de points de vente, souvent avec contrat d'exclusivité | Luxe, automobile haut de gamme, contrats de franchise |

> 🚛 **Cas transport**
>
> Un fabricant de vêtements de luxe choisit la **distribution exclusive** pour le contrôle de l'image. Il signe un **contrat de transport sécurisé** avec votre entreprise (un seul transporteur agréé, traçabilité GPS, livraison rendez-vous). Vous bénéficiez d'un partenariat exclusif, en contrepartie d'un cahier des charges strict.

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| Composantes du marketing mix | Prix, Produit, Place (distribution), Promotion |
| Stratégie de prix élevé pour clientèle premium | Écrémage |
| Stratégie de prix bas pour gagner des parts | Pénétration |
| Cycle de vie d'un produit (4 phases) | Lancement → Croissance → Maturité → Déclin |
| Cœur de gamme générant la rentabilité | Produit principal (vache à lait) |
| Distribution dans un maximum de points de vente | Intensive |
| Distribution dans un nombre limité de points sélectionnés | Sélective |
| Distribution avec contrat d'exclusivité | Exclusive |
| Vente directe = | Circuit ultra court (zéro intermédiaire) |
$lesson2$,
'Politique de prix (écrémage, pénétration, alignement, différenciation), cycle de vie produit, stratégies de distribution.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — La prospection commerciale
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'La prospection commerciale',
    'prospection-commerciale',
    3, 30,
$lesson3$
# La prospection commerciale

Une fois votre entreprise lancée et votre offre définie, il faut **trouver des clients**. La prospection commerciale est le moteur du développement : sans elle, votre carnet de commandes s'érode, et votre activité aussi. Pour un transporteur léger, c'est souvent l'activité la plus chronophage, mais aussi la plus rentable à terme.

> 🎯 **Objectifs de la leçon**
>
> - Définir la **prospection commerciale** et son objectif.
> - Connaître les **7 méthodes** de prospection.
> - Maîtriser les **8 étapes** d'une prospection structurée.

---

## 1. Définition et objectif

> **Prospection commerciale** : stratégie par laquelle une entreprise identifie, recherche et cible de **nouveaux clients potentiels** pour ses produits ou services.

C'est une étape essentielle du **cycle de vente**. Son objectif principal :

> Générer des **opportunités de vente** et bâtir des relations solides avec les prospects pour les convertir en **clients fidèles**.

> 💡 **Différence prospection vs fidélisation**
>
> - **Prospection** : aller chercher de **nouveaux** clients (acquisition).
> - **Fidélisation** : retenir et développer les **clients existants** (rétention).
>
> Les deux sont complémentaires. Coût d'acquisition typique : 5 à 7 fois plus élevé que le coût de fidélisation.

---

## 2. Les 7 méthodes de prospection

| Méthode | Outil | Avantage | Quand l'utiliser |
|---|---|---|---|
| **Téléphonique** | Appel direct | Rapide, conversation directe | B2B, réveil d'un prospect identifié |
| **E-mailing** | Newsletter, offres ciblées | Volume, automation | Notoriété et lead nurturing |
| **Réseaux sociaux** | LinkedIn, Facebook | Cible précise, conversation | B2B (LinkedIn), B2C (Facebook, Instagram) |
| **Terrain / en personne** | Visite, salon, événement | Relationnel fort | Marchés où la confiance prime |
| **Marketing de contenu** | Blog, vidéo, livre blanc | Attire au lieu de chasser | Construire l'expertise et la notoriété |
| **Publicité en ligne** | Google Ads, Facebook Ads | Cible payante, mesurable | Acquisition rapide avec budget |
| **Recommandations** | Bouche-à-oreille | Confiance maximale, gratuit | Quand vos clients sont satisfaits |

### 2.1 Prospection inbound vs outbound

| Approche | Logique | Exemples |
|---|---|---|
| **Inbound** | Le prospect vient à vous (attiré par votre contenu) | Marketing de contenu, SEO, recommandations |
| **Outbound** | Vous allez chercher le prospect | Téléphonique, e-mailing, terrain |

> 🚛 **Cas transport**
>
> Un coursier indépendant à Meaux combine **3 méthodes** :
> - **Outbound** : 5 appels par jour à des TPE locales (artisans, TPE de e-commerce)
> - **Inbound** : un blog avec 2 articles par mois (« comment expédier rapidement en région parisienne »)
> - **Recommandations** : 10 € de remise sur la prochaine course pour chaque client qui en parraine un autre

---

## 3. Les 8 étapes d'une prospection structurée

| Étape | Description |
|---|---|
| **1. Définir son public cible** | Démographie, besoins, défis, préférences |
| **2. Établir des objectifs clairs** | Mesurables : combien de prospects, combien de RDV, combien de ventes |
| **3. Préparer son discours et ses outils** | Pitch personnalisé, présentation, brochure, démo |
| **4. Identifier les prospects** | LinkedIn, annuaires, événements, bases de données |
| **5. Établir le premier contact** | Téléphone, e-mail, réseau social, en personne — ton poli, message personnalisé |
| **6. Entretenir la relation** | Contact régulier, réponses aux questions, valeur ajoutée |
| **7. Suivre et convertir** | Identifier les signaux d'intérêt, adapter, persévérer |
| **8. Évaluer et ajuster** | Quels canaux ont marché ? Quel discours convertit ? |

### 3.1 Indicateurs clés de la prospection

| Indicateur | Définition |
|---|---|
| **Taux de réponse** | % de prospects qui répondent à une sollicitation |
| **Taux de transformation** | % de prospects qui deviennent clients |
| **Coût d'acquisition (CAC)** | Coût moyen pour obtenir un nouveau client |
| **Cycle de vente moyen** | Délai entre premier contact et signature |

> 📌 **Astuce pratique**
>
> Pour le transport B2B, le **cycle de vente** moyen est de **4 à 8 semaines** (le temps que le prospect ait un besoin concret + valide votre offre + signe un contrat-cadre). Inutile de relancer chaque jour : un suivi tous les 7 à 10 jours est plus efficace et moins agaçant.

---

## 4. Aller plus loin : les outils du commercial moderne

### 4.1 Les CRM (Customer Relationship Management)

Logiciel de gestion de la relation client. Centralise contacts, historique, opportunités, échéances. Exemples : HubSpot (gratuit jusqu'à 1 000 contacts), Pipedrive, Sellsy.

### 4.2 L'automatisation marketing

Permet de **personnaliser à grande échelle** les campagnes : envois différés selon le comportement, scoring des prospects, déclenchement d'actions. **Ne remplace pas le commercial**, mais lui fait gagner du temps sur les tâches répétitives.

### 4.3 L'analyse PESTEL et SWOT

| Outil | Sert à analyser |
|---|---|
| **PESTEL** | Facteurs **P**olitiques, **É**conomiques, **S**ociaux, **T**echnologiques, **E**nvironnementaux, **L**égaux affectant l'entreprise |
| **SWOT** | **S**trengths (forces), **W**eaknesses (faiblesses), **O**pportunities (opportunités), **T**hreats (menaces) |

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| Objectif principal de la prospection | Acquérir de nouveaux clients |
| Coût d'acquisition vs coût de fidélisation | 5 à 7 fois plus cher pour acquérir |
| Inbound | Le prospect vient à vous |
| Outbound | Vous allez chercher le prospect |
| Pitch commercial efficace | Court, percutant, focalisé sur la proposition de valeur unique |
| Étape 1 d'une prospection | Définir son public cible |
| Indicateur de transformation | % de prospects devenus clients |
| Analyse environnement | PESTEL |
| Analyse interne / concurrentielle | SWOT |
| Marché de niche | Segment très spécifique avec besoins particuliers |
$lesson3$,
'7 méthodes (téléphone, e-mailing, social, terrain, contenu, ads, recommandation) et 8 étapes d''une prospection structurée.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- BANQUE QCM REFORMULÉS — Module B (20 questions)
  -- =================================================================

  -- QCM 1 — Étude de marché : finalité (facile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Quelle est la finalité principale d''une étude de marché ?',
    '[
      {"id":"a","label":"Définir la stratégie de communication interne","is_correct":false},
      {"id":"b","label":"Analyser l''offre et la demande sur un marché donné pour décider","is_correct":true},
      {"id":"c","label":"Calculer la rentabilité comptable de l''entreprise","is_correct":false},
      {"id":"d","label":"Évaluer la performance individuelle des salariés","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-b','capa-3-5t','etude-de-marche'],
    'mft-2026:moduleB:qcm:1', true,
    'L''étude de marché est un outil de décision qui mesure offre, demande, concurrence et potentiel pour valider ou ajuster une stratégie.');

  -- QCM 2 — Segment de marché (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Comment définit-on un "segment de marché" en marketing ?',
    '[
      {"id":"a","label":"Le prix moyen pratiqué sur un marché donné","is_correct":false},
      {"id":"b","label":"Un groupe homogène de consommateurs partageant des caractéristiques communes","is_correct":true},
      {"id":"c","label":"La somme des concurrents présents sur ce marché","is_correct":false},
      {"id":"d","label":"La part de marché détenue par l''entreprise","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-b','capa-3-5t','segmentation'],
    'mft-2026:moduleB:qcm:2', true,
    'La segmentation consiste à découper un marché en sous-ensembles homogènes pour mieux cibler. Un segment regroupe des clients aux profils, besoins ou comportements similaires.');

  -- QCM 3 — Données primaires vs secondaires (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Que sont des données dites "primaires" dans une étude de marché ?',
    '[
      {"id":"a","label":"Des données issues de rapports et études antérieurs","is_correct":false},
      {"id":"b","label":"Des données financières internes à l''entreprise","is_correct":false},
      {"id":"c","label":"Des données collectées directement auprès des clients (sondages, entretiens)","is_correct":true},
      {"id":"d","label":"Des données macro-économiques fournies par l''INSEE","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-b','capa-3-5t','etude-de-marche','donnees'],
    'mft-2026:moduleB:qcm:3', true,
    'Données PRIMAIRES = vous les collectez vous-même. Données SECONDAIRES = elles existent déjà ailleurs (INSEE, presse, études).');

  -- QCM 4 — Étude qualitative (facile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Quel outil est privilégié pour une étude qualitative ?',
    '[
      {"id":"a","label":"Le sondage en ligne","is_correct":false},
      {"id":"b","label":"L''entretien individuel ou en groupe (focus group)","is_correct":true},
      {"id":"c","label":"Le panel quantitatif large","is_correct":false},
      {"id":"d","label":"Le tableau croisé dynamique","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-b','capa-3-5t','etude-de-marche','qualitatif'],
    'mft-2026:moduleB:qcm:4', true,
    'Qualitatif = comprendre des comportements en profondeur → entretien (face-à-face ou focus group). Quantitatif = mesurer → questionnaire / sondage.');

  -- QCM 5 — Échantillon représentatif (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Qu''est-ce qu''un "échantillon représentatif" ?',
    '[
      {"id":"a","label":"Un sous-ensemble de la population cible reflétant ses caractéristiques","is_correct":true},
      {"id":"b","label":"Un groupe choisi au hasard sans aucun critère","is_correct":false},
      {"id":"c","label":"L''ensemble des clients déjà acquis","is_correct":false},
      {"id":"d","label":"Une analyse comptable des ventes existantes","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-b','capa-3-5t','etude-de-marche','echantillon'],
    'mft-2026:moduleB:qcm:5', true,
    'L''échantillon représentatif (ou panel) doit refléter fidèlement la population cible (âge, sexe, CSP...) pour que les résultats soient extrapolables.');

  -- QCM 6 — Stratégie de prix (facile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'À quoi correspond la stratégie de "pénétration des prix" ?',
    '[
      {"id":"a","label":"Maximiser la marge à court terme avec un prix élevé","is_correct":false},
      {"id":"b","label":"Conquérir rapidement une part de marché en pratiquant un prix bas","is_correct":true},
      {"id":"c","label":"Éliminer la concurrence par une guerre des prix","is_correct":false},
      {"id":"d","label":"Segmenter le marché en plusieurs niveaux de prix","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-b','capa-3-5t','prix','strategie'],
    'mft-2026:moduleB:qcm:6', true,
    'Pénétration = prix bas + volume rapide pour s''imposer sur le marché et dissuader les nouveaux entrants. À distinguer de l''écrémage (prix élevé, marge forte).');

  -- QCM 7 — Stratégie d'écrémage (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'La stratégie d''écrémage consiste à :',
    '[
      {"id":"a","label":"Aligner ses prix sur ceux du marché","is_correct":false},
      {"id":"b","label":"Pratiquer un prix élevé pour cibler un segment de clientèle premium","is_correct":true},
      {"id":"c","label":"Multiplier les remises promotionnelles","is_correct":false},
      {"id":"d","label":"Vendre à perte pour gagner des parts","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-b','capa-3-5t','prix','strategie'],
    'mft-2026:moduleB:qcm:7', true,
    'Écrémage : prix élevé, segment étroit. Adaptée au lancement de produits brevetés, de luxe ou très innovants. Image haut de gamme mais attire la concurrence.');

  -- QCM 8 — Politique de prix : interdictions (difficile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'En matière de politique de prix, qu''est-ce qui est strictement interdit ?',
    '[
      {"id":"a","label":"Pratiquer un prix supérieur à celui des concurrents","is_correct":false},
      {"id":"b","label":"Pratiquer un prix inférieur à celui des concurrents","is_correct":false},
      {"id":"c","label":"Revendre à perte ou pratiquer un prix abusivement bas pour éliminer la concurrence","is_correct":true},
      {"id":"d","label":"Modifier ses prix plusieurs fois par an","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-b','capa-3-5t','prix','reglementation'],
    'mft-2026:moduleB:qcm:8', true,
    'Article L. 442-2 du Code de commerce : la revente à perte est interdite, ainsi que les prix abusivement bas dans le but d''éliminer un concurrent (pratique anticoncurrentielle).');

  -- QCM 9 — Cycle de vie produit (facile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Quelles sont les 4 phases successives du cycle de vie d''un produit ?',
    '[
      {"id":"a","label":"Lancement, croissance, maturité, déclin","is_correct":true},
      {"id":"b","label":"Conception, production, distribution, fin de vie","is_correct":false},
      {"id":"c","label":"Innovation, développement, saturation, remplacement","is_correct":false},
      {"id":"d","label":"Introduction, expansion, stabilisation, abandon","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-b','capa-3-5t','produit','cycle-de-vie'],
    'mft-2026:moduleB:qcm:9', true,
    'Cycle classique en 4 phases. Au déclin, 3 stratégies : abandon, relance, ou lancement d''un nouveau produit.');

  -- QCM 10 — Positionnement (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Le positionnement d''un produit correspond à :',
    '[
      {"id":"a","label":"Sa stratégie de distribution","is_correct":false},
      {"id":"b","label":"La place qu''il occupe dans l''esprit du consommateur par rapport aux concurrents","is_correct":true},
      {"id":"c","label":"Son prix de vente","is_correct":false},
      {"id":"d","label":"Le canal de distribution choisi","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-b','capa-3-5t','produit','positionnement'],
    'mft-2026:moduleB:qcm:10', true,
    'Le positionnement = perception. Il découle du triangle d''or : attractivité (réponse aux attentes) + avantage (vs concurrents) + crédibilité.');

  -- QCM 11 — Politique produit & mix-marketing (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Dans le mix-marketing, la politique de produit comprend :',
    '[
      {"id":"a","label":"Le choix du canal de distribution","is_correct":false},
      {"id":"b","label":"La définition des caractéristiques du produit et la gestion de son cycle de vie","is_correct":true},
      {"id":"c","label":"La fixation du prix de vente","is_correct":false},
      {"id":"d","label":"La conception des campagnes publicitaires","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-b','capa-3-5t','produit','mix-marketing'],
    'mft-2026:moduleB:qcm:11', true,
    'Politique de produit = caractéristiques (3 dimensions) + cycle de vie + portefeuille (gamme, assortiment). Le prix, la distribution et la communication sont les 3 autres P.');

  -- QCM 12 — Distribution intensive vs sélective vs exclusive (difficile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'À quel type de produit la stratégie de distribution exclusive est-elle particulièrement adaptée ?',
    '[
      {"id":"a","label":"Aux produits de grande consommation à bas prix","is_correct":false},
      {"id":"b","label":"Aux produits de luxe ou à haute valeur ajoutée nécessitant un contrôle strict de l''image","is_correct":true},
      {"id":"c","label":"Aux produits disponibles en libre-service","is_correct":false},
      {"id":"d","label":"Aux produits saisonniers à forte rotation","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-b','capa-3-5t','distribution','exclusive'],
    'mft-2026:moduleB:qcm:12', true,
    'Distribution exclusive = peu de points de vente sélectionnés. Idéale pour le luxe, l''automobile haut de gamme, les contrats de franchise. Distribution intensive = grande consommation. Sélective = milieu de gamme.');

  -- QCM 13 — Circuit court (facile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Un circuit "court" de distribution se caractérise par :',
    '[
      {"id":"a","label":"Aucun intermédiaire entre producteur et consommateur","is_correct":false},
      {"id":"b","label":"Un seul intermédiaire entre producteur et consommateur","is_correct":true},
      {"id":"c","label":"Au moins trois intermédiaires","is_correct":false},
      {"id":"d","label":"Un transport sur courte distance uniquement","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-b','capa-3-5t','distribution','circuit'],
    'mft-2026:moduleB:qcm:13', true,
    'Ultra court = vente directe (0 intermédiaire). Court = 1 intermédiaire (ex : détaillant). Long = plusieurs (grossiste + détaillant…).');

  -- QCM 14 — Prospection objectif (facile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Quel est l''objectif principal de la prospection commerciale ?',
    '[
      {"id":"a","label":"Fidéliser les clients existants","is_correct":false},
      {"id":"b","label":"Identifier et acquérir de nouveaux clients","is_correct":true},
      {"id":"c","label":"Réduire les coûts de production","is_correct":false},
      {"id":"d","label":"Diversifier la gamme de produits","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-b','capa-3-5t','prospection'],
    'mft-2026:moduleB:qcm:14', true,
    'Prospection = acquisition de nouveaux clients. La fidélisation concerne les clients déjà acquis, c''est un autre métier (CRM, programmes de fidélité).');

  -- QCM 15 — Prospection digitale (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'En quoi la prospection digitale se distingue-t-elle de la prospection traditionnelle ?',
    '[
      {"id":"a","label":"Elle utilise des outils numériques (réseaux sociaux, e-mailing, marketing de contenu)","is_correct":true},
      {"id":"b","label":"Elle supprime tout contact direct avec les clients","is_correct":false},
      {"id":"c","label":"Elle se limite aux marchés locaux","is_correct":false},
      {"id":"d","label":"Elle élimine toute notion de coût d''acquisition","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-b','capa-3-5t','prospection','digital'],
    'mft-2026:moduleB:qcm:15', true,
    'Prospection digitale = outils numériques (LinkedIn, e-mailing, ads, contenu, SEO) qui complètent ou remplacent les méthodes traditionnelles (téléphone, terrain).');

  -- QCM 16 — Pitch commercial (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Quelles sont les caractéristiques d''un pitch commercial efficace ?',
    '[
      {"id":"a","label":"Long et exhaustif pour ne rien oublier","is_correct":false},
      {"id":"b","label":"Court, percutant, centré sur la proposition de valeur unique","is_correct":true},
      {"id":"c","label":"Focalisé exclusivement sur les caractéristiques techniques","is_correct":false},
      {"id":"d","label":"Centré sur les remises de prix immédiates","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-b','capa-3-5t','prospection','pitch'],
    'mft-2026:moduleB:qcm:16', true,
    'Un bon pitch tient en 30 secondes et répond à 3 questions : à qui je m''adresse, quel problème je règle, en quoi je suis différent.');

  -- QCM 17 — Taux de réponse (facile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Que représente le "taux de réponse" dans une campagne de prospection ?',
    '[
      {"id":"a","label":"Le nombre de ventes réalisées par rapport aux stocks","is_correct":false},
      {"id":"b","label":"Le pourcentage de prospects qui ont répondu favorablement à une sollicitation","is_correct":true},
      {"id":"c","label":"La proportion de clients qui recommandent le produit","is_correct":false},
      {"id":"d","label":"Le taux de retour des produits achetés","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-b','capa-3-5t','prospection','indicateurs'],
    'mft-2026:moduleB:qcm:17', true,
    'Taux de réponse = nb de réponses positives / nb de sollicitations. Indicateur d''efficacité d''un canal (e-mailing, phoning, etc.).');

  -- QCM 18 — RDV qualifié (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Une "prise de rendez-vous qualifiée" consiste à :',
    '[
      {"id":"a","label":"Programmer une rencontre avec un prospect ayant un fort potentiel d''achat","is_correct":true},
      {"id":"b","label":"Fixer des objectifs commerciaux mensuels","is_correct":false},
      {"id":"c","label":"Réaliser des ventes directes lors du rendez-vous","is_correct":false},
      {"id":"d","label":"Demander des références à des clients existants","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-b','capa-3-5t','prospection','rdv'],
    'mft-2026:moduleB:qcm:18', true,
    'RDV qualifié = le prospect a été identifié comme ayant un besoin réel et un budget. Évite de perdre du temps sur des prospects froids.');

  -- QCM 19 — Analyse PESTEL (difficile)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Que désigne précisément l''analyse "PESTEL" ?',
    '[
      {"id":"a","label":"Une méthode comptable de calcul des marges","is_correct":false},
      {"id":"b","label":"Une analyse des facteurs Politiques, Économiques, Sociaux, Technologiques, Environnementaux et Légaux affectant l''entreprise","is_correct":true},
      {"id":"c","label":"Une technique de segmentation marketing","is_correct":false},
      {"id":"d","label":"Une stratégie de gestion des ressources humaines","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-b','capa-3-5t','strategie','pestel'],
    'mft-2026:moduleB:qcm:19', true,
    'PESTEL = analyse des facteurs EXTERNES qui influencent une entreprise. Complémentaire à SWOT (qui mêle interne et externe). À ne pas confondre.');

  -- QCM 20 — SWOT (moyen)
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'L''analyse SWOT consiste à évaluer :',
    '[
      {"id":"a","label":"La satisfaction des employés en interne","is_correct":false},
      {"id":"b","label":"Les ressources financières disponibles","is_correct":false},
      {"id":"c","label":"Les forces, faiblesses, opportunités et menaces de l''entreprise","is_correct":true},
      {"id":"d","label":"La rentabilité par produit","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-b','capa-3-5t','strategie','swot'],
    'mft-2026:moduleB:qcm:20', true,
    'SWOT = Strengths (forces internes), Weaknesses (faiblesses internes), Opportunities (opportunités externes), Threats (menaces externes). Permet de croiser interne et environnement.');

  -- =================================================================
  -- BANQUE DE QR — Module B (4 mises en situation)
  -- =================================================================

  -- QR 1 — Étude de marché coursier urbain
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qr',
    'Vous projetez de lancer une activité de coursier urbain à Meaux (Seine-et-Marne, 56 000 habitants). Vous disposez de 4 semaines et de 800 € de budget pour réaliser votre étude de marché avant de signer le bail de votre local.

a. Listez 3 questions précises que votre étude doit obligatoirement éclairer.
b. Identifiez 2 sources de données SECONDAIRES gratuites ou peu coûteuses que vous pouvez exploiter.
c. Décrivez une démarche de collecte de données PRIMAIRES adaptée à votre budget et délai.
d. Quels indicateurs vous permettront de conclure si le marché est viable ?',
    NULL, 5, 'moyen',
    ARRAY['module-b','capa-3-5t','qr','etude-de-marche','cas-pratique'],
    'mft-2026:moduleB:qr:1', true,
    'Correction attendue : a. Volume de demande mensuelle estimé / Prix moyen pratiqué par les concurrents / Profil-type des clients (TPE, e-commerce, particuliers). b. INSEE (démographie + entreprises locales), CCI 77 (rapports sectoriels), URSSAF (données employeurs), FNTR (chiffres transport). c. Sondage en ligne ciblé (Google Forms, 50 répondants) + 5-10 entretiens téléphoniques avec des TPE locales. d. Volume mensuel x prix moyen > coûts fixes (loyer + véhicule + cotisations) avec marge de 15-20 %.');

  -- QR 2 — Choix de stratégie de prix
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qr',
    'Vous lancez un service de transport "express premium" pour pièces détachées industrielles : livraison sous 4h en Île-de-France, traçabilité GPS temps réel, chauffeur dédié. Le marché compte déjà 3 acteurs établis (prix moyens : 80 € à 120 € la course).

a. Parmi les 4 stratégies de prix (écrémage, pénétration, alignement, différenciation), laquelle recommandez-vous et pourquoi ?
b. Justifiez le choix d''un prix concret et indiquez vos hypothèses.
c. Quels sont les risques de cette stratégie ?
d. Comment ajusterez-vous votre stratégie au bout de 6 mois ?',
    NULL, 5, 'difficile',
    ARRAY['module-b','capa-3-5t','qr','prix','strategie','cas-pratique'],
    'mft-2026:moduleB:qr:2', true,
    'Correction attendue : a. Stratégie d''ÉCRÉMAGE → service haut de gamme avec valeur ajoutée distinctive (4h, GPS, chauffeur dédié). Cible étroite (clientèle industrielle B2B premium). b. Prix entre 140 € et 180 € (au-dessus du marché) pour valoriser la promesse. Hypothèses : 5 courses/jour, 22 jours/mois, marge 30 %. c. Risques : volume insuffisant pour atteindre la rentabilité, attaque concurrence sur le prix, attentes très élevées des clients (qualité de service). d. Mesurer le taux de conversion, le NPS clients, ajuster prix vers le bas si volume insuffisant ou enrichir le service (assurance, J+0).');

  -- QR 3 — Plan de prospection commerciale
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qr',
    'Vous avez créé votre entreprise de transport léger il y a 3 mois. Carnet de commandes : 2 clients réguliers, 8 000 € de CA mensuel, l''équivalent de 25 % de votre seuil de rentabilité.

a. Définissez votre cible prioritaire en B2B et justifiez.
b. Quelles 3 méthodes de prospection mettre en œuvre dans les 30 prochains jours ? Avec quel budget ?
c. Quels objectifs chiffrés vous fixez-vous (taux de réponse, nb RDV, nb conversions) ?
d. Comment gérez-vous le suivi et l''entretien des prospects qui ne convertissent pas immédiatement ?',
    NULL, 5, 'moyen',
    ARRAY['module-b','capa-3-5t','qr','prospection','cas-pratique'],
    'mft-2026:moduleB:qr:3', true,
    'Correction attendue : a. Cible : TPE/PME locales (artisans, BTP, e-commerce) avec 1-2 expéditions/semaine. Justification : panier moyen, fidélité, besoin récurrent. b. (1) Prospection téléphonique 10 appels/jour ciblés annuaire CCI = 200 appels/mois. (2) LinkedIn : 2 publications/semaine + 30 messages d''invitation aux décideurs. (3) Salon pro local + adhésion réseau d''entreprises (CCI, Pépinières). Budget : 0 € + 200 € adhésion. c. Taux de réponse 5-8 % phoning, 15-20 % LinkedIn personnalisé. Objectifs : 8 RDV qualifiés / mois, 2 nouveaux clients signés / mois. d. CRM (HubSpot gratuit), nurturing par newsletter mensuelle, contact tous les 2 mois, classement chaud/tiède/froid.');

  -- QR 4 — SWOT pour un transporteur
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qr',
    'Vous gérez votre entreprise de transport depuis 18 mois. Vous envisagez de passer de 1 à 3 véhicules (embauche de 2 chauffeurs), pour répondre à une demande croissante d''un gros client e-commerce.

a. Réalisez une matrice SWOT (au moins 2 éléments par case).
b. Quelles opportunités externes (PESTEL) influencent positivement la décision ?
c. Quelles menaces externes faut-il anticiper ?
d. Décision finale : avancez-vous ou pas ? Sous quelles conditions ?',
    NULL, 5, 'difficile',
    ARRAY['module-b','capa-3-5t','qr','strategie','swot','pestel','cas-pratique'],
    'mft-2026:moduleB:qr:4', true,
    'Correction attendue : a. SWOT — Forces : carnet de commandes consolidé, expérience opérationnelle, relation client. Faiblesses : trésorerie limitée, pas d''expérience management. Opportunités : croissance du e-commerce, demande locale, aides à l''embauche. Menaces : dépendance client, hausse carburant, concurrence. b. PESTEL Opportunités : essor du e-commerce (Économique), aide à l''embauche TPE (Politique), véhicules moins chers (Technologique). c. Menaces : ZFE, hausse carburant, normes environnementales (E + L), inflation (É). d. AVANCER avec conditions : (1) contrat-cadre signé avec le client e-commerce 12 mois min, (2) négocier paiement à 30 jours max, (3) recrutement progressif (1 chauffeur d''abord), (4) trésorerie de 3 mois de salaires + carburant en réserve.');

  -- =================================================================
  -- QUIZZES par leçon + examen blanc
  -- =================================================================

  -- Quiz Leçon 1 (étude de marché)
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Étude de marché — Quiz', 'Quiz d''entraînement sur la méthodologie d''étude de marché.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleB:qcm:1', 'mft-2026:moduleB:qcm:2', 'mft-2026:moduleB:qcm:3',
      'mft-2026:moduleB:qcm:4', 'mft-2026:moduleB:qcm:5'
    );

  -- Quiz Leçon 2 (politique commerciale)
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Politique commerciale — Quiz', 'Quiz sur les 4 stratégies de prix, le cycle de vie produit et la distribution.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleB:qcm:6', 'mft-2026:moduleB:qcm:7', 'mft-2026:moduleB:qcm:8',
      'mft-2026:moduleB:qcm:9', 'mft-2026:moduleB:qcm:10', 'mft-2026:moduleB:qcm:11',
      'mft-2026:moduleB:qcm:12', 'mft-2026:moduleB:qcm:13'
    );

  -- Quiz Leçon 3 (prospection)
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Prospection commerciale — Quiz', 'Quiz sur les méthodes et étapes de la prospection.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleB:qcm:14', 'mft-2026:moduleB:qcm:15', 'mft-2026:moduleB:qcm:16',
      'mft-2026:moduleB:qcm:17', 'mft-2026:moduleB:qcm:18', 'mft-2026:moduleB:qcm:19',
      'mft-2026:moduleB:qcm:20'
    );

  -- Examen blanc Module B (5 QCM en 12 min)
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Examen blanc — Module B', 'Examen blanc reproduisant les conditions de l''examen national : 5 QCM en 12 min, seuil 50 %.', 'examen', 720, 50)
  RETURNING id INTO v_quiz_eb;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleB:qcm:1', 'mft-2026:moduleB:qcm:6', 'mft-2026:moduleB:qcm:9',
      'mft-2026:moduleB:qcm:14', 'mft-2026:moduleB:qcm:19'
    );

  RAISE NOTICE '✅ Module B v2 chargé : 3 leçons, 20 QCM reformulés, 4 QR, 4 quizzes (3 entraînement + 1 examen blanc).';
END
$module_b_v2$;
