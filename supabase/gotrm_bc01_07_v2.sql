-- =====================================================================
-- GOTRM (RNCP 40990) — BC01-07 : Transports spécifiques
-- TMD/ADR, ATP, transports exceptionnels.
-- =====================================================================

DO $bc01_07$
DECLARE
  v_formation uuid; v_bloc int; v_module uuid;
  v_lesson_1 uuid; v_lesson_2 uuid; v_lesson_3 uuid; v_lesson_4 uuid;
  v_quiz_1 uuid; v_quiz_2 uuid; v_quiz_3 uuid; v_quiz_4 uuid; v_quiz_eb uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc.'; END IF;

  DELETE FROM public.modules WHERE slug = 'gotrm-bc01-07-transports-specifiques';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'BC01-07 — Transports spécifiques : TMD/ADR, ATP, exceptionnel',
    'gotrm-bc01-07-transports-specifiques', v_bloc,
    'Maîtriser les transports spécifiques : matières dangereuses (ADR), température dirigée (ATP) et transports exceptionnels (gabarit, masse).',
    'avance', 200, 70
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 70, true) ON CONFLICT DO NOTHING;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-07:%';

  -- =================================================================
  -- LEÇON 1 — ADR : cadre, classes, étiquetage
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'ADR : matières dangereuses, classes et étiquetage',
    'gotrm-bc01-07-01-adr-classes', 1, 60,
$lesson1$
# ADR : matières dangereuses, classes et étiquetage

L'ADR (Accord européen relatif au transport international des marchandises **D**angereuses par **R**oute) encadre tous les transports de matières dangereuses en Europe. C'est l'un des domaines les plus régulés du transport — une erreur peut être catastrophique humainement, environnementalement et financièrement.

> 🎯 **Objectifs de la leçon**
>
> - Connaître le **cadre juridique** ADR (accord 1957, mises à jour bisannuelles).
> - Identifier les **9 classes** de matières dangereuses.
> - Maîtriser le **système d'étiquetage** (numéros ONU, codes danger).
> - Comprendre le rôle du **conseiller à la sécurité** (CSTMD).

---

## 1. Le cadre ADR

### 1.1 Origine

Accord européen signé à **Genève en 1957**, ratifié aujourd'hui par 53 pays. Mises à jour **tous les 2 ans** (années impaires : ADR 2025, 2027, etc.).

### 1.2 Structure

L'ADR est divisé en **9 parties** (le texte complet fait plusieurs milliers de pages) :

| Partie | Contenu |
|---|---|
| 1 | Dispositions générales |
| 2 | Classification |
| 3 | Liste des matières dangereuses (numéros ONU) |
| 4 | Emballage |
| 5 | Procédures d'expédition |
| 6 | Construction des emballages et citernes |
| 7 | Conditions de transport et chargement |
| 8 | Prescriptions véhicules et équipages |
| 9 | Prescriptions véhicules et essais |

---

## 2. Les 9 classes de matières dangereuses

| Classe | Type | Exemples |
|---|---|---|
| **1** | Matières et objets explosibles | Munitions, feux d'artifice, dynamite |
| **2** | Gaz | Propane, oxygène, ammoniac, chlore |
| **3** | Liquides inflammables | Essence, gazole, alcool, peintures |
| **4.1** | Solides inflammables | Soufre, magnésium, allumettes |
| **4.2** | Matières sujettes à l'inflammation spontanée | Phosphore blanc |
| **4.3** | Matières dégageant des gaz inflammables au contact de l'eau | Sodium métal, calcium |
| **5.1** | Matières comburantes | Nitrate d'ammonium, peroxydes |
| **5.2** | Peroxydes organiques | Eau oxygénée concentrée, peroxydes industriels |
| **6.1** | Matières toxiques | Pesticides, cyanure, mercure |
| **6.2** | Matières infectieuses | Échantillons biologiques, déchets hospitaliers |
| **7** | Matières radioactives | Sources médicales, déchets nucléaires |
| **8** | Matières corrosives | Acides (sulfurique, chlorhydrique), soude caustique |
| **9** | Matières et objets dangereux divers | Batteries lithium, amiante, glace carbonique, MD environnementales |

> 📌 **Numérotation onusienne**
>
> Chaque matière a un **numéro ONU à 4 chiffres** (UN1203 = essence, UN1789 = acide chlorhydrique, UN3480 = batteries lithium-ion). Ce numéro est central pour identifier les règles applicables.

---

## 3. L'étiquetage et la signalisation

### 3.1 Le panneau orange

Tout véhicule transportant des MD doit porter à l'avant et à l'arrière un **panneau orange réfléchissant**.

| Format | 30 × 40 cm |
|---|---|
| Couleur fond | Orange RAL 1028 |
| Bord noir | Largeur 15 mm |

Pour les transports en **citerne** ou en **vrac**, le panneau porte deux numéros :

```
┌───────┐
│  33   │  ← Code danger (ici : liquide très inflammable)
│ 1203  │  ← Numéro ONU (ici : essence)
└───────┘
```

### 3.2 Les codes danger (1er nombre)

| Code | Signification |
|---|---|
| **2** | Émanation de gaz |
| **3** | Inflammabilité de liquide |
| **4** | Inflammabilité de solide |
| **5** | Comburant ou peroxyde |
| **6** | Toxique |
| **7** | Radioactif |
| **8** | Corrosif |
| **9** | Risques divers |

### 3.3 Le doublement et les préfixes

- Un **double chiffre** (33, 88) = intensification du risque
- **X devant** (X423) = la matière réagit dangereusement avec l'eau
- **0 en 2e position** (30) = pas de danger secondaire
- Un **3e chiffre** = danger secondaire

### 3.4 Les étiquettes losanges

Chaque colis ADR doit porter une **étiquette losange** (10 × 10 cm minimum) selon la classe :
- Couleur, pictogramme et numéro de classe codifiés
- Apposées sur 2 faces opposées du colis
- Lisibles et résistantes (pas de papier qui se décolle)

---

## 4. Les exemptions ADR

### 4.1 Quantités limitées (LQ)

Certaines matières dangereuses peuvent être transportées **sans la totalité du régime ADR** si elles sont conditionnées en **petits colis** sous des seuils définis (chapitre 3.4 ADR).

| Avantages LQ | Conditions |
|---|---|
| Pas d'attestation conducteur ADR | Conditionnement en colis ≤ seuil défini |
| Pas de panneau orange (sauf > 8 t LQ par véhicule) | Marquage spécifique (losange noir et blanc avec « UN » à l'intérieur) |
| Documents simplifiés | Liste des UN transportés |

### 4.2 Quantités exceptées (EQ)

Régime encore plus allégé pour des **mini-quantités** (typiquement 1 g à 30 ml par récipient interne, paquet ≤ 1 kg).

### 4.3 Exemption « 1.1.3.6 » — exemption partielle pour transporteurs

Pour des **transports liés à l'activité principale** d'une entreprise, en quantités limitées (sommes pondérées sur le véhicule), certaines obligations ADR sont allégées (ex : artisan plombier transportant ses bouteilles de gaz pour intervention).

| Catégorie de transport | Quantité maximale |
|---|---|
| Catégorie 0 (très dangereux) | Aucune exemption |
| Catégorie 1 | 20 unités |
| Catégorie 2 | 333 unités |
| Catégorie 3 | 1 000 unités |
| Catégorie 4 | Pas de limite |

> 💡 **À retenir**
>
> L'exemption **1.1.3.6** est très utilisée par les artisans, garagistes, ascensoristes. Elle reste limitée à des quantités précises et ne dispense pas de toutes les obligations (étiquetage colis, document de transport simplifié).

---

## 5. Le conseiller à la sécurité (CSTMD)

### 5.1 Rôle

Toute entreprise qui charge, décharge ou transporte des MD au-delà des seuils d'exemption doit **désigner un conseiller à la sécurité** (article 1.8.3 ADR).

| Mission | Détail |
|---|---|
| Conseil | Auprès du chef d'entreprise sur la prévention |
| Audit | Vérification annuelle des pratiques |
| Rapport annuel | Bilan des incidents, plan d'action |
| Formation | Sensibilisation des équipes ADR |
| Liaison autorités | Interface avec préfecture, DREAL |

### 5.2 Qualification

| Condition | Détail |
|---|---|
| Examen national | Examen écrit + cas pratique |
| Certificat | Validité 5 ans, renouvelable par formation |
| Internalisation ou externalisation | CSTMD interne (salarié) ou externe (consultant) |

### 5.3 Sanctions

Absence de CSTMD = amende administrative pouvant atteindre **15 000 €** + risque pénal en cas d'accident.

---

## 6. Cas pratique : transport ADR

**Contexte** : Vous devez organiser le transport de **6 fûts de 200 L de gazole** (UN1202, classe 3, groupe d'emballage III) entre une raffinerie et un dépôt agricole.

### Analyse ADR

| Question | Réponse |
|---|---|
| Classe ? | 3 — liquides inflammables |
| Numéro ONU ? | UN1202 (gasoil ou diesel) |
| Code danger ? | 30 (liquide inflammable, pas de danger secondaire) |
| Volume total | 6 × 200 L = 1 200 L = 960 kg (densité 0,8) |
| Catégorie de transport ? | 3 (gazole < 1 000 unités → exempté 1.1.3.6 si ≤ 1 000 L) |
| > 1 000 L : | Régime ADR complet |

### Mesures à prendre

1. **Conducteur** : attestation ADR de base ou « citerne » selon le mode (fûts → ADR de base)
2. **Véhicule** : catégorie EX/II ou EX/III si véhicule spécifique, sinon véhicule classique avec extincteurs
3. **Document de transport ADR** :
   - UN1202 GAZOLE 3 III
   - Quantité : 1 200 L
   - Nombre de colis : 6 fûts de 200 L
   - Identification expéditeur et destinataire
4. **Consignes écrites** (équivalent du « tritan » en couleurs) à bord
5. **Équipement obligatoire** : 2 extincteurs (2 kg + 6 kg minimum), gants, lunettes, lampe, lampe portative, gilet HV, cale de roue
6. **Étiquetage** : losange classe 3 sur chaque fût + panneau orange 30 (matière inflammable)

---

> ✅ **À retenir**
>
> - **9 classes** de matières dangereuses (1 à 9), numéros **ONU à 4 chiffres**.
> - **Panneau orange** 30 × 40 cm : code danger (haut) + UN (bas).
> - **Quantités limitées (LQ)**, **exceptées (EQ)** et **exemption 1.1.3.6** allègent le régime.
> - Le **CSTMD** (conseiller à la sécurité) est obligatoire au-delà des seuils.
> - Conducteur ADR avec attestation valide 5 ans.
$lesson1$,
'Cadre ADR (1957, mises à jour bisannuelles), 9 classes de MD, numéros ONU et codes danger, panneau orange, LQ/EQ, exemption 1.1.3.6, CSTMD obligatoire.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — ATP : température dirigée
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'ATP : transport sous température dirigée',
    'gotrm-bc01-07-02-atp-temperature', 2, 50,
$lesson2$
# ATP : transport sous température dirigée

L'**Accord ATP** (Accord sur les **T**ransports **P**érissables) encadre le transport de denrées sous température dirigée. Glaces, viandes, produits laitiers, médicaments : sans le respect strict des températures, c'est la sécurité alimentaire et sanitaire qui est en jeu.

> 🎯 **Objectifs de la leçon**
>
> - Identifier le **cadre ATP** (accord 1970, classifications).
> - Connaître les **catégories** de véhicules (IR, IN, RR, RN, FNA, FRC).
> - Maîtriser les **températures réglementaires** par type de denrée.
> - Comprendre les **obligations documentaires** et de contrôle.

---

## 1. Le cadre ATP

### 1.1 Origine

Accord international signé à **Genève en 1970**, applicable depuis 1976. Concerne le transport routier ET ferroviaire des denrées sous température dirigée.

### 1.2 Marchandises concernées

L'ATP s'applique aux **denrées périssables** :
- **Surgelés** : -18 °C ou moins (glaces, légumes surgelés)
- **Congelés** : -12 °C ou moins
- **Réfrigérés** : 0 à +6 °C (viandes, produits laitiers, charcuterie)
- **Tempérés** : +12 à +25 °C selon produit (chocolat, médicaments)

### 1.3 Champ géographique

L'ATP s'applique aux **transports internationaux** entre pays signataires (50+). En national, des règles équivalentes (le plus souvent **identiques**) s'appliquent par transposition dans le droit français.

---

## 2. Les catégories de véhicules ATP

Les véhicules ATP sont classifiés selon leur **isothermie** et leur **équipement frigorifique** :

### 2.1 Lettres principales

| Code | Signification |
|---|---|
| **I** | Isotherme (parois isolantes, sans groupe) |
| **R** | Réfrigérant (avec source de froid passive : glace, neige carbonique) |
| **F** | Frigorifique (avec groupe frigorifique mécanique) |

### 2.2 Lettres secondaires (performance)

| Code | Performance isothermique |
|---|---|
| **N** | Normal (k ≤ 0,7 W/m²·K) |
| **R** | Renforcé (k ≤ 0,4 W/m²·K) |

> 📌 **Coefficient k**
>
> Le coefficient k mesure la perte thermique par unité de surface et par degré d'écart. Plus il est faible, mieux le véhicule isole. **k ≤ 0,4** = isolation renforcée (typique frigos haut de gamme).

### 2.3 Codes complets

| Code | Signification | Usage |
|---|---|---|
| **IN** | Isotherme normal | Marchandises peu sensibles |
| **IR** | Isotherme renforcé | Transit court, complément d'autres équipements |
| **RN / RR** | Réfrigérant normal/renforcé | Glace, eutectique |
| **FN / FR** | Frigorifique normal/renforcé | Avec groupe mécanique |
| **FNA** | Frigorifique normal classe A | Maintien -10 °C minimum |
| **FNB** | Frigorifique normal classe B | Maintien -10 à 0 °C |
| **FNC** | Frigorifique normal classe C | Maintien 0 à +12 °C |
| **FRA** | Frigorifique renforcé classe A | Maintien -20 °C minimum |
| **FRB** | Frigorifique renforcé classe B | Maintien -20 à 0 °C |
| **FRC** | Frigorifique renforcé classe C | **Maintien -20 à +12 °C — le plus polyvalent** |

> 💡 **Choix usuel**
>
> Le **FRC** est le standard du marché car capable de descendre à -20 °C et monter à +12 °C selon le besoin. Les transporteurs livrent surgelés et frais avec le même véhicule.

---

## 3. Les températures réglementaires

### 3.1 Aliments surgelés

| Produit | Température max |
|---|---|
| Crème glacée | -20 °C |
| Poissons et autres surgelés | -18 °C |

### 3.2 Aliments congelés (autres)

| Produit | Température max |
|---|---|
| Beurre | -10 °C |
| Volailles, gibiers, œufs hors coquille, lapin | -12 °C |
| Tous autres produits congelés | -10 °C |

### 3.3 Aliments réfrigérés

| Produit | Température max |
|---|---|
| Lait pasteurisé | +6 °C |
| Préparations à base de viande | +4 °C |
| Volailles fraîches | +4 °C |
| Viandes hachées | +2 °C |
| Poissons frais | 0 à +2 °C (sur glace) |
| Œufs en coquille | température ambiante stable < +12 °C |

> ⚠️ **Tolérances**
>
> Une légère hausse temporaire (rupture de chaîne du froid) est tolérée pendant le **chargement/déchargement** (max 3 °C au-dessus de la cible) **MAIS** la durée est strictement encadrée et ne doit pas se cumuler.

---

## 4. Le contrôle et les attestations

### 4.1 Attestation ATP

Tout véhicule ATP doit posséder une **attestation officielle** délivrée par un centre agréé (en France : **Cemafroid**) après un **test thermique** rigoureux.

| Caractéristique | Détail |
|---|---|
| Validité initiale | **6 ans** |
| Renouvellement | **3 ans** chaque |
| Contrôle | Test du coefficient k + test de mise en froid |
| Plaque | Apposée à l'extérieur du véhicule |

### 4.2 Plaque ATP

Plaque métallique fixée sur le véhicule indiquant :
- Code de classification (ex : FRC)
- Date d'émission et d'expiration
- Numéro d'identification
- Centre agréé émetteur

### 4.3 Enregistrement de la température

Tout transport ATP doit avoir un **enregistreur de température** :
- Mesures continues (toutes les 5-15 minutes)
- Conservation des données pendant 12 mois minimum
- Disponibilité immédiate pour les contrôles

> 📌 **Évolution moderne**
>
> Les enregistreurs sont aujourd'hui connectés (4G/IoT), avec **alerte temps réel** en cas de dépassement de seuil. Les chargeurs (grande distribution notamment) exigent souvent un accès direct aux données.

---

## 5. Cas pratique : transport ATP

**Contexte** : *Frigorifique du Sud* doit livrer 8 t de viande de bœuf hachée surgelée + 2 t de lait UHT (température ambiante autorisée) entre Toulouse et Strasbourg, distance 950 km.

### Analyse

| Donnée | Réponse |
|---|---|
| Type de produit principal | Surgelé : viande hachée (-12 °C minimum) |
| Type de véhicule | FRA, FRB ou FRC (capable de descendre à -20 °C minimum) |
| Co-chargement avec lait UHT | Possible : le lait UHT supporte les températures négatives, ou peut être placé en compartiment séparé |
| Durée de voyage | ~ 11 h de conduite + repos = total ~ 24 h (un repos journalier intermédiaire) |
| Équipement nécessaire | Enregistreur de température, sondes calibrées, alarme en cas de dépassement |

### Mesures à prendre

1. **Vérification pré-départ** :
   - Plaque ATP en cours de validité (date contrôlée)
   - Calibration des sondes effectuée < 12 mois
   - Enregistreur opérationnel et batterie chargée
   - Pré-refroidissement du compartiment à -25 °C avant chargement (réserve thermique)

2. **Au chargement** :
   - Refus si la marchandise arrive au-dessus de -10 °C (rupture déjà constatée chez le chargeur)
   - Mention du produit, quantité et température sur le bon de chargement
   - Photographie du thermomètre

3. **Pendant le transport** :
   - Vérification toutes les 4 h (à chaque pause)
   - Alerte si température dépasse -15 °C en continu pendant > 30 min
   - Pas de coupure du groupe en cas d'arrêt long

4. **À la livraison** :
   - Présentation de l'enregistrement température au client
   - Signature CMR avec mention « température conforme »
   - Conservation des données 12 mois

---

> ✅ **À retenir**
>
> - **ATP** = accord 1970, applicable aux denrées périssables.
> - Codes véhicules : **I** isotherme, **R** réfrigérant, **F** frigorifique + **N** normal / **R** renforcé.
> - **FRC** = standard polyvalent du marché (descente -20 à +12).
> - Températures à respecter selon produit (glaces -20, viandes hachées +2 etc.).
> - **Attestation ATP** valide 6 ans puis 3 ans, **enregistreur** obligatoire.
$lesson2$,
'ATP (1970), catégories de véhicules (IN/IR/RN/FNA/FRC), températures réglementaires, attestation ATP (6 ans puis 3), enregistreur de température obligatoire.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Transports exceptionnels
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Transports exceptionnels : gabarit, masse, longueur',
    'gotrm-bc01-07-03-transports-exceptionnels', 3, 50,
$lesson3$
# Transports exceptionnels : gabarit, masse, longueur

Quand la marchandise dépasse les **gabarits standards** (longueur, largeur, hauteur, masse), on entre dans le régime du **transport exceptionnel**, qui exige des autorisations préfectorales, des itinéraires spécifiques et parfois un accompagnement.

> 🎯 **Objectifs de la leçon**
>
> - Identifier les **seuils** déclenchant le régime de transport exceptionnel.
> - Maîtriser les **3 catégories** d'autorisation (1, 2, 3).
> - Connaître la procédure de **demande TIE-PI** (téléservice).
> - Anticiper les **moyens d'accompagnement** (voiture pilote, gendarmerie).

---

## 1. Les gabarits standards en France

### 1.1 Limites de droit commun (Code de la route)

| Dimension | Maximum |
|---|---|
| **Longueur** semi-remorque | 16,50 m |
| **Longueur** train double | 18,75 m |
| **Largeur** | 2,55 m (2,60 m pour véhicules ATP) |
| **Hauteur** | Pas de limite explicite (ouvrages d'art = contrainte réelle) |
| **Masse** semi-remorque | 40 t (44 t pour 5 essieux dérogatoire) |

### 1.2 Au-delà : transport exceptionnel

Tout dépassement d'une de ces dimensions/masses **active le régime exceptionnel**, défini par l'**arrêté du 4 mai 2006** modifié.

---

## 2. Les 3 catégories de transport exceptionnel

Selon le niveau de dépassement, le transport relève d'une catégorie qui détermine la procédure et l'accompagnement requis.

### 2.1 Catégorie 1 (mineure)

| Critère | Limite |
|---|---|
| Longueur | ≤ 20 m |
| Largeur | ≤ 3 m |
| Masse | ≤ 48 t |

| Procédure | Détail |
|---|---|
| Autorisation | **Permanente** ou de portée régionale, valable 5 ans |
| Itinéraire | Défini par décret, sans demande individuelle pour les axes courants |
| Accompagnement | Pas de voiture pilote requise |

### 2.2 Catégorie 2 (intermédiaire)

| Critère | Limite |
|---|---|
| Longueur | 20 < L ≤ 25 m |
| Largeur | 3 < l ≤ 4 m |
| Masse | 48 < M ≤ 72 t |

| Procédure | Détail |
|---|---|
| Autorisation | **Au cas par cas** ou portée régionale |
| Itinéraire | Examen préfectoral des contraintes (ouvrages, ponts, virages) |
| Accompagnement | **1 voiture pilote** obligatoire généralement |

### 2.3 Catégorie 3 (majeure)

| Critère | Limite |
|---|---|
| Longueur | > 25 m |
| Largeur | > 4 m |
| Masse | > 72 t |

| Procédure | Détail |
|---|---|
| Autorisation | **Spécifique pour chaque transport**, instruction longue (8 à 12 sem) |
| Itinéraire | Étude détaillée + visite des points sensibles |
| Accompagnement | **2 voitures pilotes** + souvent gendarmerie |
| Travaux préparatoires | Coupe d'arbres, neutralisation feux tricolores, démontage panneaux |

---

## 3. Le téléservice TIE-PI

### 3.1 Présentation

**TIE-PI** = Transports Intérieurs Exceptionnels - Procédure Informatisée. Téléservice de l'État pour la demande d'autorisation.

| Élément | Détail |
|---|---|
| Accès | https://tep.application.developpement-durable.gouv.fr |
| Public | Transporteurs et chargeurs |
| Délai | 30 jours minimum (cat. 2), 12 sem (cat. 3) |
| Coût | Gratuit (mais frais accompagnement à la charge du transporteur) |

### 3.2 Pièces à joindre

- Schéma précis du convoi (longueur, largeur, hauteur, masse, essieux)
- Caractéristiques techniques du véhicule (PV homologation)
- Itinéraire proposé (départ, arrivée, points intermédiaires)
- Photos du chargement
- Justificatif d'assurance majorée

### 3.3 Décision

| Réponse | Délai cat. 2 | Délai cat. 3 |
|---|---|---|
| Acceptation | 4-6 semaines | 8-12 semaines |
| Demande de compléments | +2-4 semaines | +4-8 semaines |
| Refus | Possible (motivé) | Possible (motivé) |

---

## 4. Les moyens d'accompagnement

### 4.1 Voiture pilote

Véhicule de moins de 3,5 t équipé spécifiquement :
- Gyrophare(s) orange
- Panneau « Convoi exceptionnel »
- Radio VHF pour communication avec le convoi
- Chauffeur formé (CACES voiture pilote)

### 4.2 Gendarmerie / police

Pour les convois de catégorie 3 ou en zones sensibles :
- 2 motards en escorte
- Frais à la charge du transporteur (~500 €/h)
- Coordination avec les centres opérationnels

### 4.3 Travaux temporaires

- Démontage de panneaux gênants
- Neutralisation feux tricolores
- Coupe d'arbres en bordure de route
- Renforcement temporaire d'ouvrages d'art (rare)
- Coordination ENEDIS (lignes basse tension)

---

## 5. Cas pratique : transport exceptionnel

**Contexte** : Vous devez transporter une **éolienne en kit** : nacelle 4,2 m × 4 m × 4,5 m hauteur, masse 78 tonnes, longueur 18 m. Trajet : port de Bayonne → site éolien à Tarbes (180 km).

### Analyse

| Critère | Valeur | Catégorie |
|---|---|---|
| Longueur | 18 m | OK cat. 1 (≤ 20 m) |
| Largeur | 4,2 m | Cat. 3 (> 4 m) |
| Hauteur | 4,5 m | Hors gabarit standard |
| Masse | 78 t | Cat. 3 (> 72 t) |

**Conclusion** : Catégorie 3 — autorisation spécifique requise, 2 voitures pilotes + escorte gendarmerie probable.

### Démarches à entreprendre

1. **J - 12 semaines minimum**
   - Identification du véhicule porteur (porte-engin extra-lourd, multi-essieux 8 lignes minimum)
   - Étude d'itinéraire par bureau d'études spécialisé (cabinets type Mauffrey, Capelle, Demenge)
   - Vérification ouvrages d'art (ponts à 80 t de capacité au moins)

2. **J - 10 semaines**
   - Dépôt demande TIE-PI catégorie 3
   - Pièces : schéma convoi, PV véhicule, itinéraire détaillé, attestation assurance
   - Demande complémentaire à ENEDIS pour neutralisation lignes basse tension

3. **J - 6 semaines**
   - Réception arrêté préfectoral d'autorisation
   - Réservation 2 voitures pilotes + chauffeurs habilités
   - Coordination gendarmerie (escorte sur ~40 km zones sensibles)

4. **J - 2 semaines**
   - Repérage final terrain (ponts, virages, points de stationnement temporaire)
   - Briefing équipage : conducteur principal + 2 chauffeurs voitures pilotes
   - Communication aux mairies traversées

5. **Jour J**
   - Départ tôt (5 h-6 h pour limiter la gêne)
   - Vitesse maximale : 60 km/h hors agglomération, 30 km/h en agglo
   - Arrêts obligatoires aux points de regroupement
   - Trajet 180 km : 5 à 7 h effectives + temps de coordination

6. **Coût indicatif**
   - Autorisation TIE-PI : gratuite
   - 2 voitures pilotes (chauffeurs + véhicules) : ~ 2 800 €
   - Escorte gendarmerie (4 h × 2 motards) : ~ 1 500 €
   - Bureau d'étude itinéraire : ~ 3 200 €
   - Assurance majorée : ~ 800 €
   - Total accompagnement : **~ 8 300 €** (en plus du transport lui-même)

> ⚠️ **Toujours anticiper**
>
> Une demande catégorie 3 à 4 semaines de l'enlèvement = mission impossible. Les chargeurs sérieux anticipent **3 à 4 mois** en amont.

---

> ✅ **À retenir**
>
> - **3 catégories** : cat. 1 (≤ 20 m / 3 m / 48 t), cat. 2 (intermédiaire), cat. 3 (au-delà).
> - **TIE-PI** = téléservice État, délais 4 à 12 semaines selon catégorie.
> - **Voitures pilotes** obligatoires en cat. 2 (1) et cat. 3 (2 + gendarmerie).
> - **Itinéraire imposé** par arrêté préfectoral, vitesse réduite (60/30 km/h).
> - Toujours anticiper **3-4 mois** pour un transport catégorie 3.
$lesson3$,
'Gabarits standards (16,5 m / 2,55 m / 40 t), 3 catégories de transport exceptionnel, téléservice TIE-PI, voitures pilotes/escorte, anticipation 3-4 mois pour cat. 3.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Documents et obligations spécifiques
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Documents et obligations transverses aux transports spécifiques',
    'gotrm-bc01-07-04-documents-obligations', 4, 40,
$lesson4$
# Documents et obligations transverses aux transports spécifiques

Au-delà des règles propres à chaque type (ADR, ATP, exceptionnel), il existe des **obligations transverses** : documents, formation conducteur, équipement véhicule, traçabilité. Synthèse opérationnelle.

> 🎯 **Objectifs de la leçon**
>
> - Lister les **documents** obligatoires par type de transport.
> - Connaître les **formations** des conducteurs (ADR, FIMO/FCO, ATP).
> - Identifier l'**équipement** spécifique des véhicules.
> - Maîtriser la **traçabilité** et les **incidents**.

---

## 1. Documents par type de transport

### 1.1 Transport ADR

| Document | Émetteur |
|---|---|
| Document de transport ADR (article 5.4.1.1) | Expéditeur |
| Consignes écrites en cas d'accident (article 5.4.3) | Transporteur |
| Attestation conducteur ADR | Conducteur |
| Certificat d'agrément du véhicule | Centre agréé |
| Liste de vérifications pré-chargement | Transporteur |
| Plan de sûreté (matières à haut risque) | Expéditeur |

### 1.2 Transport ATP

| Document | Émetteur |
|---|---|
| Plaque ATP fixée sur le véhicule | Cemafroid (centre agréé) |
| Enregistrement température continu | Transporteur |
| Certificat de calibration des sondes | Centre de calibration |
| Bon de chargement avec température mesurée | Expéditeur |

### 1.3 Transport exceptionnel

| Document | Émetteur |
|---|---|
| Arrêté préfectoral d'autorisation | Préfecture |
| Itinéraire détaillé visé | Préfecture / DREAL |
| Attestation des voitures pilotes | Société d'accompagnement |
| Certificat d'assurance majorée | Assureur |
| Constat de chargement | Expéditeur + transporteur |

---

## 2. Formation des conducteurs

### 2.1 Permis et qualifications de base

Tous les conducteurs PL doivent détenir :
- **Permis CE** (ou C selon véhicule)
- **CQC** (Carte de Qualification Conducteur) à jour : FIMO initiale + FCO 35h tous les 5 ans
- Carte conducteur tachygraphique

### 2.2 Formation ADR

| Niveau | Programme | Validité |
|---|---|---|
| **Base** | 18 h initial / 13 h recyclage | 5 ans |
| **Citerne** | +12 h | 5 ans |
| **Classe 1 (explosifs)** | +8 h | 5 ans |
| **Classe 7 (radioactif)** | +8 h | 5 ans |

> 📌 **Combinaison**
>
> Un conducteur qui transporte régulièrement gazole en citerne ET produits chimiques en colis aura besoin du **Base + Citerne** (pour les liquides en citerne).

### 2.3 Formation ATP

Pas d'attestation spécifique conducteur, mais :
- Formation interne sur la chaîne du froid (recommandée)
- Sensibilisation HACCP (hygiène alimentaire) souvent demandée par les chargeurs

### 2.4 Voiture pilote (transports exceptionnels)

| Formation | Détail |
|---|---|
| **Stage initial** | 14 h théorique + pratique |
| **Recyclage** | 7 h tous les 5 ans |
| **Réglementation, signalisation, communication, anticipation** | Programme défini |

---

## 3. Équipement spécifique des véhicules

### 3.1 ADR — équipement obligatoire

| Équipement | Quantité |
|---|---|
| Extincteurs | 2 minimum (un 2 kg cabine + un 6 kg sur véhicule) |
| Cale de roue | 1 par véhicule + 1 par remorque |
| Gilet HV par membre d'équipage | Obligatoire |
| Lampe portative | 1 |
| Lunettes de protection | 1 paire par membre |
| Gants chimiques | 1 paire par membre |
| Lave-œil portatif | 1 |
| Pelle (matières solides) | Selon classe |
| Récipient collecteur | Selon classe |
| Trousse premiers secours | 1 |

### 3.2 ATP — équipement obligatoire

| Équipement | Détail |
|---|---|
| Groupe frigorifique calibré | Selon catégorie |
| Sondes de température | 2 minimum (compartiment ET marchandise si possible) |
| Enregistreur certifié | Mémoire 12 mois minimum |
| Système d'alerte (modernes) | Optionnel mais conseillé |
| Volets thermiques | Pour ouverture brève sans rupture chaîne du froid |

### 3.3 Transports exceptionnels — équipement

| Équipement | Détail |
|---|---|
| Gyrophare orange sur cabine | Obligatoire |
| Panneau « Convoi exceptionnel » avant et arrière | Obligatoire |
| Feux clignotants latéraux selon largeur | Selon dimensions |
| Radio VHF | Pour coordination avec voitures pilotes |
| Câbles élingues spécifiques | Selon chargement |

---

## 4. Traçabilité et gestion des incidents

### 4.1 Documents à conserver (durée légale)

| Document | Conservation |
|---|---|
| CMR / lettre de voiture | 5 ans (commercial) |
| Document de transport ADR | 5 ans |
| Enregistrements température ATP | 12 mois |
| Rapports d'incident ADR | Permanent |
| Arrêté préfectoral exceptionnel | 5 ans |

### 4.2 Procédure incident ADR

En cas de fuite, déversement ou accident :

1. **Sécuriser** la zone : balisage, gilet HV, attente services secours.
2. **Alerter** : 112 ou 18 (pompiers) en priorité.
3. **Présenter** consignes écrites aux secours (qui détaillent le risque par classe).
4. **Notifier** au CSTMD (conseiller à la sécurité).
5. **Rédiger** un rapport d'incident dans les 5 jours.
6. **Notifier** la préfecture si déversement environnemental.

### 4.3 Procédure rupture chaîne du froid (ATP)

1. **Constater** la rupture : alerte enregistreur, contrôle visuel.
2. **Documenter** : photos, capture des données, heure exacte.
3. **Évaluer** : durée et amplitude de la rupture.
4. **Décider** :
   - Rupture courte (< 30 min, hausse < 3 °C) : reprendre le trajet, prévenir le client.
   - Rupture importante : retour rapide en site frigorifique, expertise produit.
5. **Informer** le client AVANT la livraison.
6. **Constituer** un dossier : données enregistreur, certificat calibration, photos.

---

## 5. Cas pratique : organisation d'un service multi-spécialités

**Contexte** : Vous reprenez la direction d'exploitation d'une PME de 18 véhicules :
- 6 frigorifiques FRC pour la grande distribution
- 4 citernes ADR (gazole, fioul)
- 8 porteurs polyvalents (national général)

### Diagnostic priorités

1. **CSTMD** : 1 conseiller à la sécurité externe à plein temps insuffisant ; à internaliser ou compléter avec audit annuel.
2. **Calibration sondes ATP** : vérifier les 6 véhicules sur calibration < 12 mois.
3. **CQC conducteurs** : 18 conducteurs, vérifier FCO valide pour chacun (5 ans).
4. **ADR** : sur 4 véhicules citerne, vérifier attestation conducteur + véhicule + équipement complet.
5. **Audit interne 5 jours** : passer en revue tous les documents pour préparer un éventuel contrôle DREAL.

### Plan d'action 90 jours

| Échéance | Action |
|---|---|
| J + 5 | Tableau de bord conformité tous véhicules + tous conducteurs |
| J + 15 | Renouvellements urgents (CQC, ADR, plaques ATP < 6 mois) |
| J + 30 | Désignation CSTMD interne ou contrat externe consolidé |
| J + 45 | Formation interne ADR refresher pour les 4 conducteurs citerne |
| J + 60 | Audit interne ATP avec contrôle calibration sondes |
| J + 75 | Test grandeur nature procédure incident (exercice avec pompiers) |
| J + 90 | Bilan, plan d'action 12 mois, reporting direction |

> 💡 **Bonne pratique**
>
> Tenir un **registre de conformité unique** (Excel ou GED) avec une ligne par véhicule et par conducteur, listant toutes les échéances (FCO, ADR, plaque ATP, contrôle technique, calibration, etc.) et alertes 60 jours avant échéance.

---

> ✅ **À retenir**
>
> - Documents par transport : **ADR** (consignes, attestation, certificat), **ATP** (plaque, enregistrement, calibration), **exceptionnel** (arrêté, itinéraire visé).
> - Formation : **CQC FCO 5 ans** + spécifique ADR (5 ans) + voiture pilote (5 ans).
> - Équipement véhicule : extincteurs, gilets HV, lampe (ADR), enregistreur (ATP), gyrophare (exceptionnel).
> - Conservation : **5 ans** général, **12 mois** enregistrements ATP, **permanent** incidents ADR.
> - Tenir un **registre de conformité** centralisé avec alertes échéances.
$lesson4$,
'Documents par type (ADR, ATP, exceptionnel), formations conducteurs (CQC FCO, ADR, voiture pilote), équipement véhicule, traçabilité, procédures incidents.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- 28 QCM
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, source_ref, type, prompt, choices, correct, explanation, difficulty, tags) VALUES

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:1', 'qcm',
   'L''ADR est un accord :',
   jsonb '[
     {"key":"a","label":"International signé à Genève en 1957"},
     {"key":"b","label":"Exclusivement français de 1992"},
     {"key":"c","label":"Européen de 2007 limité à l''UE"},
     {"key":"d","label":"Mondial de l''ONU sans force juridique"}
   ]', '["a"]'::jsonb,
   'L''ADR (Accord européen relatif au transport international des marchandises Dangereuses par Route) a été signé à Genève en 1957, ratifié par 53 pays. Mises à jour bisannuelles (années impaires).',
   'facile', '{adr,cadre}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:2', 'qcm',
   'Combien de classes de matières dangereuses compte l''ADR ?',
   jsonb '[
     {"key":"a","label":"5"},
     {"key":"b","label":"7"},
     {"key":"c","label":"9"},
     {"key":"d","label":"12"}
   ]', '["c"]'::jsonb,
   'L''ADR distingue 9 classes principales (1-explosifs, 2-gaz, 3-liquides inflammables, 4-solides inflammables, 5-comburants, 6-toxiques, 7-radioactifs, 8-corrosifs, 9-divers).',
   'facile', '{adr,classes}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:3', 'qcm',
   'Le numéro UN1203 désigne :',
   jsonb '[
     {"key":"a","label":"L''oxygène liquide"},
     {"key":"b","label":"L''essence"},
     {"key":"c","label":"L''ammoniac"},
     {"key":"d","label":"Les batteries lithium"}
   ]', '["b"]'::jsonb,
   'UN1203 = essence (carburant moteur). Chaque matière dangereuse a un numéro ONU unique à 4 chiffres permettant son identification universelle (UN1202 = gazole, UN1789 = acide chlorhydrique, UN3480 = batteries lithium-ion).',
   'moyenne', '{adr,numeros-un}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:4', 'qcm',
   'Sur un panneau orange ADR portant 33/1203, le 33 signifie :',
   jsonb '[
     {"key":"a","label":"Numéro de classe ADR"},
     {"key":"b","label":"Code danger : liquide très inflammable (intensification)"},
     {"key":"c","label":"Volume en hectolitres"},
     {"key":"d","label":"Date d''expiration de l''autorisation"}
   ]', '["b"]'::jsonb,
   'Le code danger (chiffre du haut) indique la nature et l''intensité du risque : 3 = liquide inflammable, 33 = liquide très inflammable (doublement = intensification). Le 1203 (chiffre du bas) = numéro ONU de l''essence.',
   'moyenne', '{adr,panneau-orange}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:5', 'qcm',
   'L''exemption ADR « 1.1.3.6 » permet :',
   jsonb '[
     {"key":"a","label":"De transporter sans aucune contrainte"},
     {"key":"b","label":"Un allègement partiel pour des quantités limitées par catégorie"},
     {"key":"c","label":"De transporter uniquement en agglomération"},
     {"key":"d","label":"D''éviter le permis PL"}
   ]', '["b"]'::jsonb,
   'L''exemption 1.1.3.6 ADR allège partiellement le régime pour des transports liés à l''activité principale, dans la limite de quantités définies par catégorie de transport (0 à 4). Elle ne dispense pas de toutes les obligations.',
   'moyenne', '{adr,exemption}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:6', 'qcm',
   'Le conseiller à la sécurité (CSTMD) est obligatoire :',
   jsonb '[
     {"key":"a","label":"Pour toute entreprise de transport"},
     {"key":"b","label":"Pour les entreprises qui chargent, déchargent ou transportent des MD au-delà des seuils d''exemption"},
     {"key":"c","label":"Uniquement pour le transport de classe 1 (explosifs)"},
     {"key":"d","label":"Uniquement pour les transports internationaux"}
   ]', '["b"]'::jsonb,
   'Article 1.8.3 ADR : toute entreprise impliquée dans le chargement, déchargement ou transport de MD au-delà des seuils d''exemption doit désigner un CSTMD. Sanction : amende administrative jusqu''à 15 000 €.',
   'moyenne', '{adr,cstmd}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:7', 'qcm',
   'L''attestation conducteur ADR a une validité de :',
   jsonb '[
     {"key":"a","label":"1 an"},
     {"key":"b","label":"3 ans"},
     {"key":"c","label":"5 ans"},
     {"key":"d","label":"10 ans"}
   ]', '["c"]'::jsonb,
   'L''attestation ADR conducteur (base, citerne, classe 1, classe 7) est valable 5 ans. Le recyclage de 13 h doit être fait avant l''expiration pour éviter de repasser la formation initiale (18 h base).',
   'facile', '{adr,attestation-conducteur}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:8', 'qcm',
   'L''ATP est un accord signé à Genève en :',
   jsonb '[
     {"key":"a","label":"1957"},
     {"key":"b","label":"1970"},
     {"key":"c","label":"1985"},
     {"key":"d","label":"2006"}
   ]', '["b"]'::jsonb,
   'L''Accord ATP (Accord sur les Transports Périssables) a été signé à Genève en 1970, applicable depuis 1976. Il couvre les transports internationaux et inspire les règles nationales de transport sous température dirigée.',
   'facile', '{atp,cadre}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:9', 'qcm',
   'Dans le code véhicule ATP « FRC », la lettre F signifie :',
   jsonb '[
     {"key":"a","label":"Fixe"},
     {"key":"b","label":"Frigorifique (avec groupe mécanique)"},
     {"key":"c","label":"Forcé"},
     {"key":"d","label":"Fluvial"}
   ]', '["b"]'::jsonb,
   'F = Frigorifique, c''est-à-dire véhicule avec groupe frigorifique mécanique. I = Isotherme (sans froid), R = Réfrigérant (froid passif type glace). FRC = Frigorifique Renforcé classe C (-20 à +12 °C).',
   'moyenne', '{atp,categorie-vehicule}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:10', 'qcm',
   'Un véhicule FRC est capable de maintenir des températures de :',
   jsonb '[
     {"key":"a","label":"0 à +12 °C uniquement"},
     {"key":"b","label":"-20 à +12 °C (le plus polyvalent)"},
     {"key":"c","label":"-30 °C minimum"},
     {"key":"d","label":"+12 à +25 °C uniquement"}
   ]', '["b"]'::jsonb,
   'Le FRC (Frigorifique Renforcé classe C) descend à -20 °C minimum et peut monter à +12 °C. C''est le standard polyvalent du marché : un seul véhicule pour surgelés ET frais.',
   'moyenne', '{atp,frc}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:11', 'qcm',
   'La température maximale admise pour le transport de viandes hachées est :',
   jsonb '[
     {"key":"a","label":"+8 °C"},
     {"key":"b","label":"+4 °C"},
     {"key":"c","label":"+2 °C"},
     {"key":"d","label":"0 °C"}
   ]', '["c"]'::jsonb,
   'Les viandes hachées sont les produits réfrigérés les plus exigeants : +2 °C maximum. Cela est dû à la surface développée par le hachage qui multiplie les risques bactériens.',
   'difficile', '{atp,temperatures}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:12', 'qcm',
   'L''attestation ATP d''un véhicule est valable :',
   jsonb '[
     {"key":"a","label":"6 ans initialement, puis 3 ans renouvelable"},
     {"key":"b","label":"10 ans sans renouvellement"},
     {"key":"c","label":"5 ans toujours"},
     {"key":"d","label":"À vie"}
   ]', '["a"]'::jsonb,
   'L''attestation ATP est délivrée pour 6 ans initialement, puis renouvelée par périodes de 3 ans après nouveau test thermique en centre agréé (Cemafroid en France).',
   'moyenne', '{atp,validite}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:13', 'qcm',
   'L''enregistrement de température en transport ATP doit être conservé pendant au minimum :',
   jsonb '[
     {"key":"a","label":"3 mois"},
     {"key":"b","label":"6 mois"},
     {"key":"c","label":"12 mois"},
     {"key":"d","label":"5 ans"}
   ]', '["c"]'::jsonb,
   'Les enregistrements de température doivent être conservés au moins 12 mois (article 1 et arrêté du 21 décembre 2009). Les chargeurs grande distribution exigent souvent un accès direct aux données.',
   'moyenne', '{atp,enregistrement}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:14', 'qcm',
   'En droit commun (sans transport exceptionnel), la longueur maximale d''une semi-remorque articulée est :',
   jsonb '[
     {"key":"a","label":"12 m"},
     {"key":"b","label":"16,5 m"},
     {"key":"c","label":"18,75 m"},
     {"key":"d","label":"22 m"}
   ]', '["b"]'::jsonb,
   'La longueur maximale d''une semi-remorque articulée est 16,50 m. Pour un train double (camion-remorque), la limite est 18,75 m. Au-delà : transport exceptionnel.',
   'facile', '{exceptionnel,gabarit}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:15', 'qcm',
   'La largeur maximale d''un véhicule routier en droit commun est :',
   jsonb '[
     {"key":"a","label":"2,30 m"},
     {"key":"b","label":"2,55 m (2,60 m pour véhicules ATP)"},
     {"key":"c","label":"3,00 m"},
     {"key":"d","label":"3,50 m"}
   ]', '["b"]'::jsonb,
   'La largeur standard est 2,55 m, portée à 2,60 m pour les véhicules ATP (parois isolantes plus épaisses). Au-delà : transport exceptionnel selon catégorie.',
   'moyenne', '{exceptionnel,largeur}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:16', 'qcm',
   'Un convoi de 22 m de long, 3,5 m de large et 55 t de masse relève de la catégorie :',
   jsonb '[
     {"key":"a","label":"Catégorie 1"},
     {"key":"b","label":"Catégorie 2"},
     {"key":"c","label":"Catégorie 3"},
     {"key":"d","label":"Pas un transport exceptionnel"}
   ]', '["b"]'::jsonb,
   'Cat. 1 : ≤ 20 m / 3 m / 48 t. Cat. 2 : 20 < L ≤ 25 m, 3 < l ≤ 4 m, 48 < M ≤ 72 t. Cat. 3 : au-delà. Ici 22 m + 3,5 m + 55 t = catégorie 2 (toutes les valeurs sont dans les seuils cat. 2).',
   'difficile', '{exceptionnel,categorie}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:17', 'qcm',
   'Le téléservice utilisé pour les demandes de transport exceptionnel s''appelle :',
   jsonb '[
     {"key":"a","label":"NSTI"},
     {"key":"b","label":"TIE-PI"},
     {"key":"c","label":"DELTA-XI"},
     {"key":"d","label":"PORTNET"}
   ]', '["b"]'::jsonb,
   'TIE-PI = Transports Intérieurs Exceptionnels - Procédure Informatisée. C''est le téléservice de l''État pour déposer les demandes d''autorisation. Délais : 4-6 sem cat. 2, 8-12 sem cat. 3.',
   'moyenne', '{tie-pi,exceptionnel}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:18', 'qcm',
   'Un transport exceptionnel de catégorie 3 nécessite généralement :',
   jsonb '[
     {"key":"a","label":"Aucune escorte"},
     {"key":"b","label":"1 voiture pilote"},
     {"key":"c","label":"2 voitures pilotes + souvent escorte gendarmerie"},
     {"key":"d","label":"Uniquement un gyrophare"}
   ]', '["c"]'::jsonb,
   'Catégorie 3 = au-delà de 25 m, 4 m ou 72 t. Accompagnement généralement par 2 voitures pilotes + escorte gendarmerie sur zones sensibles. Frais à la charge du transporteur.',
   'moyenne', '{exceptionnel,accompagnement}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:19', 'qcm',
   'La vitesse maximale typique d''un convoi exceptionnel hors agglomération est de :',
   jsonb '[
     {"key":"a","label":"40 km/h"},
     {"key":"b","label":"60 km/h"},
     {"key":"c","label":"80 km/h"},
     {"key":"d","label":"90 km/h"}
   ]', '["b"]'::jsonb,
   'Hors agglomération, la vitesse maximale d''un convoi exceptionnel est typiquement 60 km/h, et 30 km/h en agglomération. Ces vitesses sont fixées dans l''arrêté préfectoral d''autorisation et peuvent être plus restrictives selon le convoi.',
   'moyenne', '{exceptionnel,vitesse}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:20', 'qcm',
   'Le délai d''anticipation recommandé pour un transport exceptionnel catégorie 3 est de :',
   jsonb '[
     {"key":"a","label":"2 semaines"},
     {"key":"b","label":"1 mois"},
     {"key":"c","label":"3 à 4 mois"},
     {"key":"d","label":"1 an"}
   ]', '["c"]'::jsonb,
   'Pour un transport cat. 3, anticiper 3 à 4 mois est nécessaire : étude itinéraire (cabinet spécialisé), instruction TIE-PI (8-12 sem), réservation accompagnement, coordination ENEDIS/gendarmerie. Une demande à 4 sem est mission impossible.',
   'difficile', '{exceptionnel,anticipation}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:21', 'qcm',
   'Parmi cet équipement, lequel n''est PAS obligatoire en transport ADR ?',
   jsonb '[
     {"key":"a","label":"Extincteurs (2 minimum)"},
     {"key":"b","label":"Gilet HV par membre d''équipage"},
     {"key":"c","label":"Détecteur de gaz portable"},
     {"key":"d","label":"Lampe portative"}
   ]', '["c"]'::jsonb,
   'Le détecteur de gaz portable n''est pas obligatoire ADR (sauf cas spécifiques classe 2 en citerne). Les équipements de base ADR sont : extincteurs, gilets HV, lampe, gants chimiques, lunettes, lave-œil, cale de roue, trousse premiers secours.',
   'difficile', '{adr,equipement}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:22', 'qcm',
   'Les consignes écrites ADR (article 5.4.3) doivent être :',
   jsonb '[
     {"key":"a","label":"Conservées au siège de l''entreprise"},
     {"key":"b","label":"À bord du véhicule, accessibles au conducteur et aux secours"},
     {"key":"c","label":"Affichées au point de chargement"},
     {"key":"d","label":"Envoyées à la préfecture"}
   ]', '["b"]'::jsonb,
   'Les consignes écrites en cas d''accident (« tritan » dans le jargon) doivent être à bord du véhicule, dans la cabine, accessibles immédiatement par le conducteur et les services de secours. En français + langue du conducteur.',
   'moyenne', '{adr,consignes}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:23', 'qcm',
   'En cas de rupture de chaîne du froid en ATP (température dépassée pendant 1 h sur viande hachée) :',
   jsonb '[
     {"key":"a","label":"Le transporteur peut livrer en silence si la marchandise semble ok"},
     {"key":"b","label":"Le transporteur doit documenter, alerter le client AVANT livraison et constituer un dossier"},
     {"key":"c","label":"Le transporteur peut effacer les enregistrements"},
     {"key":"d","label":"Aucune action particulière"}
   ]', '["b"]'::jsonb,
   'Toute rupture significative doit être documentée (photos, capture des données, heure exacte), évaluée (durée, amplitude), et le client doit être prévenu AVANT la livraison. La modification ou suppression d''enregistrements est une fraude pénalement sanctionnée.',
   'moyenne', '{atp,rupture-chaine-froid}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:24', 'qcm',
   'En cas d''incident ADR avec déversement, l''ordre des actions est :',
   jsonb '[
     {"key":"a","label":"Notifier la préfecture, puis sécuriser, puis alerter les secours"},
     {"key":"b","label":"Sécuriser la zone, alerter les secours (112), présenter les consignes écrites"},
     {"key":"c","label":"Tenter d''arrêter la fuite avant tout"},
     {"key":"d","label":"Reprendre la route si la fuite est faible"}
   ]', '["b"]'::jsonb,
   'Ordre prioritaire : 1) Sécuriser la zone (balisage, gilet HV) ; 2) Alerter les secours (112 ou 18) ; 3) Présenter les consignes écrites aux pompiers/gendarmes pour qu''ils connaissent le risque ; 4) Notifier le CSTMD ; 5) Rapport d''incident sous 5 jours.',
   'moyenne', '{adr,incident}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:25', 'qcm',
   'Pour combien d''années la formation FCO de la CQC est-elle valable ?',
   jsonb '[
     {"key":"a","label":"3 ans"},
     {"key":"b","label":"5 ans"},
     {"key":"c","label":"7 ans"},
     {"key":"d","label":"10 ans"}
   ]', '["b"]'::jsonb,
   'La FCO (Formation Continue Obligatoire) de 35 h doit être suivie tous les 5 ans pour maintenir la CQC (Carte de Qualification Conducteur) valide. Une FCO périmée invalide la CQC et empêche la conduite professionnelle PL.',
   'facile', '{cqc,fco}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:26', 'qcm',
   'Une plaque ATP indique sur le véhicule :',
   jsonb '[
     {"key":"a","label":"Le numéro d''immatriculation et le PTAC"},
     {"key":"b","label":"Le code de classification (ex : FRC), date d''émission, date d''expiration, numéro et centre agréé"},
     {"key":"c","label":"La marque du groupe frigorifique"},
     {"key":"d","label":"Le coût de l''attestation"}
   ]', '["b"]'::jsonb,
   'La plaque ATP métallique fixée à l''extérieur du véhicule porte 4 informations clés : code de classification (IN, FRC, etc.), date d''émission, date d''expiration, numéro d''identification + centre agréé émetteur (Cemafroid en France).',
   'moyenne', '{atp,plaque}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:27', 'qcm',
   'Le « régime des quantités limitées » (LQ) en ADR permet :',
   jsonb '[
     {"key":"a","label":"De ne pas avoir d''attestation conducteur ADR pour ces colis"},
     {"key":"b","label":"De doubler les quantités transportables"},
     {"key":"c","label":"De supprimer les étiquettes"},
     {"key":"d","label":"De ne pas immatriculer le véhicule"}
   ]', '["a"]'::jsonb,
   'Le régime LQ (Limited Quantities, chap. 3.4 ADR) permet, pour des colis sous des seuils définis par matière, de ne pas exiger l''attestation conducteur ADR ni le panneau orange (sauf si le véhicule transporte plus de 8 t en LQ). Marquage spécifique : losange noir et blanc avec « UN ».',
   'difficile', '{adr,lq}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qcm:28', 'qcm',
   'Une voiture pilote pour transports exceptionnels doit être équipée :',
   jsonb '[
     {"key":"a","label":"D''un gyrophare bleu et d''une sirène"},
     {"key":"b","label":"De gyrophare(s) orange, panneau « Convoi exceptionnel » et radio VHF"},
     {"key":"c","label":"D''une flèche lumineuse"},
     {"key":"d","label":"D''aucun équipement particulier"}
   ]', '["b"]'::jsonb,
   'Une voiture pilote (≤ 3,5 t) est équipée de gyrophare(s) orange, panneau « Convoi exceptionnel » avant et arrière, et d''une radio VHF pour la communication avec le convoi. Le chauffeur doit avoir suivi le stage initial 14 h et recyclage 7 h tous les 5 ans.',
   'moyenne', '{exceptionnel,voiture-pilote}');

  -- =================================================================
  -- 5 QR
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, source_ref, type, prompt, choices, correct, explanation, difficulty, tags) VALUES

  (v_formation, 'mft-2026-gotrm:bc01-07:qr:1', 'qr',
   'Vous devez organiser le transport de 800 L d''acide chlorhydrique (UN1789, classe 8, groupe d''emballage II) en bidons de 25 L. Détaillez les obligations ADR : conducteur, véhicule, documents, équipement, étiquetage.',
   '[]'::jsonb, '[]'::jsonb,
   'Analyse :

UN1789 = acide chlorhydrique
Classe 8 (corrosifs)
Groupe d''emballage II (danger moyen)
Volume : 800 L = 32 bidons de 25 L
Code danger : 80 (corrosif simple)

Vérification exemption 1.1.3.6 : classe 8 GE II est en catégorie de transport 2 (limite 333 unités). Pour les liquides : 1 unité = 1 L. Donc 800 L > 333 → régime ADR complet requis.

Obligations :

1. Conducteur :
- Attestation ADR de base en cours de validité (5 ans)
- Permis CE valide
- CQC FCO à jour

2. Véhicule :
- Pas de catégorie spécifique pour les colis (EX/II ou EX/III pour citerne uniquement)
- Véhicule en bon état général, contrôle technique à jour

3. Documents à bord :
- Document de transport ADR avec mention :
  « UN1789 ACIDE CHLORHYDRIQUE, 8, II »
  + nombre de colis (32 bidons de 25 L)
  + identification expéditeur et destinataire
  + nom et adresse du transporteur
- Consignes écrites en cas d''accident (en FR + langue conducteur)
- Attestation conducteur ADR
- Certificat d''agrément du véhicule (le cas échéant)

4. Équipement obligatoire :
- 2 extincteurs (2 kg cabine + 6 kg véhicule)
- Cale de roue (1 par véhicule + 1 par remorque)
- Gilet HV par membre équipage
- Lampe portative
- Gants chimiques résistants aux acides
- Lunettes de protection
- Lave-œil portatif
- Trousse premiers secours
- Récipient collecteur ou matière absorbante (pour classe 8 liquide)

5. Étiquetage :
- Sur chaque bidon : étiquette losange classe 8 (corrosif)
- Marque UN1789 lisible
- Sur le véhicule : 2 panneaux orange réfléchissants (avant et arrière) — code 80, UN1789

6. Plan de chargement :
- Bidons calés et arrimés
- Pas de mélange avec matières incompatibles (classe 4.3, 5, 6)
- Position basse dans le véhicule (pour limiter les chutes)

7. Équipement spécifique classe 8 (corrosif) :
- Matériau de neutralisation (carbonate de sodium par exemple) recommandé
- Trousse anti-éclaboussure
- Douche d''urgence à proximité du chargement (chez l''expéditeur)

Sanction si non-respect : amende ADR (catégorie GI ou TGI selon manquement) + immobilisation immédiate possible.',
   'difficile', '{adr,cas-pratique,acide}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qr:2', 'qr',
   'Un de vos camions FRC livre 6 t de glaces (-18 °C requis) à une grande surface. À l''ouverture, le client constate -8 °C dans le compartiment et refuse la marchandise. L''enregistreur montre une température remontée à -8 °C pendant 4 heures la nuit. Analysez la situation et listez vos actions.',
   '[]'::jsonb, '[]'::jsonb,
   'Analyse de la situation :

1. Constat technique :
- Température cible : -18 °C minimum (glaces)
- Température mesurée : -8 °C — soit 10 °C au-dessus de la cible
- Durée de la remontée : 4 h
- Conséquence : rupture de chaîne du froid critique → marchandise non conforme à la consommation
- Refus client justifié : la grande surface ne peut pas remettre en vente des glaces ayant subi cet écart

2. Causes probables à investiguer :
- Panne du groupe frigorifique (court-circuit, fuite gaz, fusible)
- Coupure du groupe pour économie nocturne (erreur conducteur)
- Porte mal fermée
- Joint défectueux
- Sonde déréglée donnant une mauvaise lecture (à exclure si calibration récente)

Actions immédiates :

a. Sécuriser la marchandise refusée :
- Conserver dans un autre véhicule conforme ou en chambre froide
- Ne pas la retourner directement chez l''expéditeur sans accord
- Photos, vidéo, témoignage signé du réceptionnaire

b. Constater officiellement :
- Faire signer un constat de refus par le client
- Imprimer l''enregistrement température sur la période
- Photographier l''affichage du tableau de bord du frigo
- Récupérer la marchandise pour expertise

c. Alerter en interne :
- Exploitation : assurer le retour du véhicule
- Atelier : diagnostic groupe frigorifique sous 4 h
- Direction commerciale : information client expéditeur (le chargeur)

d. Activer assurance et procédure litige :
- Déclaration sinistre auprès de l''assureur RC marchandises
- Préparer dossier complet : CMR, bon de chargement (température départ), enregistrement, constat refus, expertise produit

e. Communication client :
- Informer le client expéditeur dans les 4 h
- Proposer une réexpédition urgente si stock disponible
- Lettre formelle : description précise des faits, temps, températures, mesures correctives

Actions correctives à moyen terme :

1. Diagnostic technique poussé du véhicule (panne groupe vs erreur humaine)
2. Si panne : réparation puis test 24 h en charge avant remise en service
3. Si erreur conducteur : formation/sensibilisation, instruction écrite ne pas couper le groupe
4. Audit télématique 7 derniers jours sur autres véhicules FRC
5. Vérification calibration sondes (si > 12 mois, recalibration immédiate)
6. Mise en place système d''alerte temps réel (SMS exploitation si T > -15 °C pendant > 30 min)

Aspect juridique :

- Refus client justifié : pas de litige sur le refus
- Indemnisation du chargeur :
  - Plafond contrat-type général : 33 €/kg ou 1 000 €/colis (palette)
  - 6 t de glaces × 33 €/kg = 198 000 € théorique max
  - En pratique, indemnisation limitée à la valeur réelle (ex : 6 t × 8 €/kg prix de gros = 48 000 €)
  - Vérifier la déclaration de valeur éventuelle et la clause d''assurance étendue

- Imputation interne :
  - Si panne groupe : responsabilité transporteur, indemnisation pleine
  - Si erreur conducteur (coupure volontaire) : responsabilité transporteur + sanction interne possible
  - Si bug enregistreur (sonde défaillante) : argument de défense possible mais à étayer

Mesure préventive globale :

Mettre en place un protocole « chaîne du froid » écrit, signé par chaque conducteur, avec engagement de ne jamais couper le groupe frigorifique pendant les coupures (même nocturnes), sauf urgence ou consigne expresse de l''exploitation.',
   'difficile', '{atp,rupture,plan-action}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qr:3', 'qr',
   'Vous devez organiser le transport d''une éolienne (3 sections, dont la nacelle de 4 m de large × 4,5 m de haut × 78 t) entre le port de La Rochelle et un site éolien proche de Bergerac (190 km). Le client souhaite une livraison sous 5 semaines. Réaliste ? Détaillez les démarches et calculez le coût total estimé.',
   '[]'::jsonb, '[]'::jsonb,
   'Analyse de la demande :

Caractéristiques convoi :
- Largeur : 4 m → catégorie 3 (>4 m approche limite mais reste bord catégorie 2 selon arrondi)
- Hauteur : 4,5 m → hors gabarit standard, examen ouvrages d''art
- Masse : 78 t → catégorie 3 (>72 t)
- Conclusion : catégorie 3 confirmée

Délai de 5 semaines : INSUFFISANT pour un cat. 3.

Justification :
- Étude d''itinéraire (cabinet spécialisé) : 2 à 3 sem
- Instruction TIE-PI : 8 à 12 semaines
- Coordination travaux préparatoires (ENEDIS, élagage) : 4 à 6 semaines
- Réservation accompagnement (voitures pilotes + gendarmerie) : 2 à 4 sem
- Total minimum incompressible : 12-14 semaines

Recommandation au client : reporter la livraison à environ 3 mois (12 sem), ou identifier une solution intermédiaire (ex : démontage de la nacelle en 2 sous-ensembles permettant de revenir en cat. 1 ou 2, plus rapide à autoriser).

Démarches détaillées (si délai accepté à 12 semaines) :

Sem 1-2 : Préparation
- Brief technique : poids, dimensions, points de levage, photos
- Choix porte-engin extra-lourd (8-12 lignes essieux, 100 t de capacité)
- Sélection cabinet d''études itinéraire (Capelle, Demenge, Leguen, Mauffrey)

Sem 3-5 : Étude itinéraire
- Reconnaissance terrain (survol drone, mesures pont, virages)
- Identification 2 itinéraires alternatifs
- Vérification capacité ouvrages d''art (ponts à 80 t minimum)
- Identification points sensibles (lignes BT, panneaux, feux)
- Estimation travaux préparatoires (élagage, dépose temporaire)

Sem 5-12 : Instruction TIE-PI
- Dépôt dossier complet avec :
  - Schéma précis du convoi
  - PV homologation porte-engin
  - Itinéraire principal + secondaire
  - Photos chargement
  - Attestation assurance majorée
- Instruction préfectures traversées (La Rochelle, Saintes, Bergerac : 3 préfectures)
- Réponse arrêté préfectoral

Sem 11-12 : Coordination opérationnelle
- Conventions ENEDIS pour neutralisation lignes
- Demande escorte gendarmerie (4 motards typiquement)
- Réservation 2 voitures pilotes
- Information mairies traversées
- Briefing équipage

Jour J - 1 : Repérage final
- Reconnaissance dernière minute (chantiers BTP, événements)
- Test communication radio VHF

Jour J : Convoi
- Départ tôt (5 h 30-6 h)
- Vitesse 60 km/h hors agglo, 30 km/h en agglo
- Arrêts toutes les 30 km pour vérifications
- Trajet 190 km : 5 à 7 h effectives + temps de coordination
- Arrivée sur site, déchargement sous grue (~2 h)

Coût total estimé :

| Poste | Montant |
|---|---|
| Étude d''itinéraire (cabinet spécialisé) | 4 800 € |
| Instruction TIE-PI | 0 (gratuit) |
| Cautions et assurances majorées | 1 500 € |
| Porte-engin extra-lourd (location 3 jours) | 14 000 € |
| Conducteur principal (formation transports exc.) | 2 200 € (2,5 jours) |
| 2 voitures pilotes + chauffeurs | 4 200 € |
| Escorte gendarmerie (4 motards × 6 h) | 3 800 € |
| Travaux préparatoires (ENEDIS + élagage) | 5 500 € |
| Communication mairies, frais administratifs | 1 200 € |
| Carburant véhicule + escorte | 1 800 € |
| Marge transporteur (15 %) | 5 800 € |
| **Total facturable HT** | **44 800 €** |

À ajouter : assurance valeur déclarée nacelle (à la charge du chargeur typiquement, ou refacturé).

Conseil au client : si le budget est contraint, négocier avec le chargeur la livraison directement par mer jusqu''à un port plus proche (Bordeaux), ou aérien (rare et coûteux). Sinon, anticiper le timing nécessaire.',
   'difficile', '{exceptionnel,delais,couts}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qr:4', 'qr',
   'Vous reprenez la direction d''exploitation d''une PME de 25 véhicules dont 8 ADR (citernes carburant) et 6 ATP (FRC distribution alimentaire). Identifiez les 8 points de conformité critiques à vérifier dans les 30 premiers jours et listez les actions correctives types.',
   '[]'::jsonb, '[]'::jsonb,
   'Audit conformité 30 jours — 8 points critiques :

1. CSTMD (Conseiller à la Sécurité TMD) — ADR
- Vérification : existe-t-il un conseiller désigné ? Rapport annuel à jour ?
- Risque : amende 15 000 € + sanctions si incident
- Action corrective : si absent, désigner sous 7 jours (interne ou externe contrat). Demander rapport audit complet sous 30 jours.

2. Attestations ADR conducteurs
- Vérification : 8 conducteurs citerne — attestations valides (5 ans), domaines (base + citerne)
- Risque : conduite illégale, immobilisation, perte client
- Action : tableau Excel avec dates expiration. Renouvellements urgents (< 6 mois) immédiats. Formation citerne pour les nouveaux.

3. Certificats d''agrément véhicules ADR (citernes)
- Vérification : 8 citernes carburant ont-elles un certificat d''agrément en cours de validité ?
- Risque : refus chargement, immobilisation, amende
- Action : faire passer les contrôles techniques annuels et les visites quinquennales. Calendrier 12 mois.

4. Plaques ATP des véhicules FRC
- Vérification : 6 plaques (initial 6 ans, renouvellement 3 ans). Quelle est l''échéance pour chaque ?
- Risque : interdiction chargement, retrait client grande distribution
- Action : planning des tests Cemafroid sur 3 mois si plaques anciennes. Coût ~2 500 € par véhicule (tests + démarches).

5. Calibration sondes ATP et enregistreurs
- Vérification : calibration < 12 mois pour les 6 véhicules ?
- Risque : enregistrements non valides, refus clients, défense impossible en cas de litige
- Action : recalibration immédiate des sondes hors délai. Contrat annuel avec laboratoire agréé.

6. CQC / FCO conducteurs (tous les 25)
- Vérification : 25 conducteurs — FCO 35h tous les 5 ans, FIMO si nouveau
- Risque : conduite illégale, amende 1 500 €/conducteur
- Action : tableau global. Renouvellements groupés en sessions internes (économie d''échelle).

7. Équipement obligatoire des véhicules (ADR + ATP)
- Vérification physique sur les 14 véhicules concernés :
  - ADR : extincteurs, gilets, lampes, gants, lunettes, lave-œil, cale, trousse premiers secours
  - ATP : enregistreur fonctionnel, sondes opérationnelles
- Risque : amende, immobilisation, sinistre non couvert
- Action : audit physique en 5 jours (1 personne dédiée), bon de commande pour matériel manquant, vérification trimestrielle.

8. Documents à bord et procédures incidents
- Vérification : consignes ADR à bord, attestations en cours, procédure rupture chaîne du froid documentée
- Risque : amende contrôle DREAL, défense impossible en cas d''incident
- Action : kit documents standardisé par véhicule, procédures écrites affichées en cabine, exercice incident annuel.

Tableau de bord 30 jours :

| Point | Statut J0 | Action | Échéance | Responsable |
|---|---|---|---|---|
| 1. CSTMD | ❓ | Désigner | J+7 | Direction |
| 2. Attestations ADR | À auditer | Tableau + renouvellements | J+15 | RH |
| 3. Agrément citernes | À vérifier | Planning contrôles | J+30 | Atelier |
| 4. Plaques ATP | À auditer | Planning tests Cemafroid | J+30 | Atelier |
| 5. Calibration sondes | À auditer | Contrat labo + recalibrations | J+15 | Atelier |
| 6. CQC/FCO | À auditer | Sessions formation | J+90 | RH |
| 7. Équipement véhicules | À auditer | Audit physique | J+10 | Exploit |
| 8. Documents/procédures | À auditer | Kit standardisé | J+30 | QHSE |

Investissement estimé pour mise en conformité 30 jours : 35 - 50 k€ (formations, équipement, tests Cemafroid, contrats). À comparer aux risques : amendes 15-30 k€ par manquement majeur + perte clients en cas d''incident médiatisé.',
   'difficile', '{audit,conformite,plan-30-jours}'),

  (v_formation, 'mft-2026-gotrm:bc01-07:qr:5', 'qr',
   'Comparez le transport ADR en colis vs en citerne pour le même produit (gazole UN1202). Différences en termes de réglementation, attestation conducteur, équipement, coûts et applicabilité de l''exemption 1.1.3.6.',
   '[]'::jsonb, '[]'::jsonb,
   'Comparaison transport ADR colis vs citerne pour UN1202 (gazole) :

| Critère | Transport en colis (fûts, IBC 1000 L) | Transport en citerne |
|---|---|---|
| Volume typique unitaire | 200 L (fût) ou 1 000 L (IBC) | 25 000 à 33 000 L |
| Quantité totale typique | 200 L à 30 000 L | 30 000 L et plus |
| Attestation ADR conducteur | Base (18 h initial / 13 h recyclage) | Base + Citerne (12 h supplémentaires) |
| Validité attestation | 5 ans | 5 ans |
| Véhicule | Véhicule de transport classique (PL standard) | Véhicule citerne agréé EX/II ou EX/III |
| Certificat d''agrément du véhicule | Non requis pour véhicule classique | OBLIGATOIRE (validité 1 an, vérification stricte) |
| Panneau orange | OUI (sauf < 1000 L et exemption 1.1.3.6) | OUI permanent (avec UN spécifique) |
| Étiquetage des emballages | Étiquette losange classe 3 sur chaque colis | Plaque-étiquette sur la citerne |
| Document de transport ADR | Obligatoire (sauf exemption 1.1.3.6) | Obligatoire |
| Consignes écrites | Obligatoires | Obligatoires |
| Équipement obligatoire | Standard ADR (extincteurs, gilets, lampe, etc.) | Standard ADR + équipement spécifique citerne (vannes de fond, dispositifs anti-débordement) |
| Plan de chargement | Calage et arrimage des fûts/IBC | Calculs de répartition par compartiment |
| Vitesse maximale | Selon véhicule (90 km/h PL classique) | Souvent limitée (selon arrêté local et type de matière) |

Applicabilité de l''exemption 1.1.3.6 :

UN1202 (gazole) en classe 3, groupe d''emballage III → catégorie de transport 3, limite 1 000 unités.
Pour les liquides : 1 unité = 1 L.

| Quantité totale | Régime applicable | Exemption 1.1.3.6 ? |
|---|---|---|
| 800 L (4 fûts de 200 L) | Allégé (sous le seuil 1 000 L) | OUI applicable |
| 1 200 L (6 fûts de 200 L) | Régime ADR complet | NON (au-delà du seuil) |
| Tout volume en citerne | Régime ADR complet | NON (citerne = jamais en exemption 1.1.3.6) |

Important : l''exemption 1.1.3.6 ne s''applique JAMAIS aux transports en citerne ou conteneur-citerne, quelle que soit la quantité. Elle ne concerne que les transports en colis.

Coûts comparés (indicatifs, base 1 livraison) :

| Poste | Colis (200 L × 4 fûts = 800 L) | Citerne (15 000 L) |
|---|---|---|
| Formation conducteur (amortie) | ~ 5 €/livraison | ~ 8 €/livraison |
| Coût horaire conducteur | 30 €/h | 32 €/h |
| Amortissement véhicule | 0,10 €/km | 0,18 €/km |
| Carburant | 0,40 €/km | 0,50 €/km |
| Manutention | 30 min × 35 €/h = 18 € (par fût) | 15 min × 35 €/h = 9 € (raccord) |
| Assurance majorée ADR | + 8 % | + 12 % |

Applicabilité commerciale :

Colis : adapté pour
- Quantités modestes (< 5 000 L typiquement)
- Plusieurs petits clients sur une tournée
- Clients sans installation de réception citerne

Citerne : adapté pour
- Gros volumes (> 5 000 L par livraison)
- Stations-service, dépôts
- Économies d''échelle sur la livraison unitaire
- Coût km commercial plus bas (~ 30-40 % moins cher au litre transporté)

Recommandation business :

Pour une PME de transport carburant :
- Citernes pour les clients réguliers à fort volume (stations, exploitations agricoles, BTP)
- Quelques porteurs avec capacité fûts/IBC pour le marché ponctuel et les artisans (en utilisant 1.1.3.6 pour ces derniers)
- Investissement : citerne 15 000 L = 80-110 k€, vs porteur 19 t = 95 k€ (mais polyvalent au-delà du carburant)',
   'difficile', '{adr,colis-citerne,comparaison}');

  -- =================================================================
  -- QUIZZES
  -- =================================================================
  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_1, 'Quiz — ADR : cadre et classes', 'gotrm-bc01-07-quiz-01', 'Cadre ADR, 9 classes, numéros UN, panneau orange, exemption 1.1.3.6, CSTMD.', 70, NULL, false, 1)
  RETURNING id INTO v_quiz_1;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-07:qcm:1','mft-2026-gotrm:bc01-07:qcm:2','mft-2026-gotrm:bc01-07:qcm:3','mft-2026-gotrm:bc01-07:qcm:4','mft-2026-gotrm:bc01-07:qcm:5','mft-2026-gotrm:bc01-07:qcm:6','mft-2026-gotrm:bc01-07:qcm:7','mft-2026-gotrm:bc01-07:qcm:21','mft-2026-gotrm:bc01-07:qcm:22','mft-2026-gotrm:bc01-07:qcm:24','mft-2026-gotrm:bc01-07:qcm:27');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_2, 'Quiz — ATP température dirigée', 'gotrm-bc01-07-quiz-02', 'Cadre ATP, catégories véhicules, températures, attestation, enregistrement.', 70, NULL, false, 2)
  RETURNING id INTO v_quiz_2;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-07:qcm:8','mft-2026-gotrm:bc01-07:qcm:9','mft-2026-gotrm:bc01-07:qcm:10','mft-2026-gotrm:bc01-07:qcm:11','mft-2026-gotrm:bc01-07:qcm:12','mft-2026-gotrm:bc01-07:qcm:13','mft-2026-gotrm:bc01-07:qcm:23','mft-2026-gotrm:bc01-07:qcm:26');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_3, 'Quiz — Transports exceptionnels', 'gotrm-bc01-07-quiz-03', 'Gabarits, 3 catégories, TIE-PI, voiture pilote, vitesse, anticipation.', 70, NULL, false, 3)
  RETURNING id INTO v_quiz_3;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-07:qcm:14','mft-2026-gotrm:bc01-07:qcm:15','mft-2026-gotrm:bc01-07:qcm:16','mft-2026-gotrm:bc01-07:qcm:17','mft-2026-gotrm:bc01-07:qcm:18','mft-2026-gotrm:bc01-07:qcm:19','mft-2026-gotrm:bc01-07:qcm:20','mft-2026-gotrm:bc01-07:qcm:28');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_4, 'Quiz — Documents et obligations transverses', 'gotrm-bc01-07-quiz-04', 'CQC FCO, équipement véhicule, traçabilité, incidents.', 70, NULL, false, 4)
  RETURNING id INTO v_quiz_4;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-07:qcm:21','mft-2026-gotrm:bc01-07:qcm:22','mft-2026-gotrm:bc01-07:qcm:23','mft-2026-gotrm:bc01-07:qcm:24','mft-2026-gotrm:bc01-07:qcm:25','mft-2026-gotrm:bc01-07:qcm:26');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, NULL, 'Examen blanc — BC01-07 Transports spécifiques', 'gotrm-bc01-07-examen-blanc', '15 QCM en 30 min, seuil 50 %.', 50, 30, true, 5)
  RETURNING id INTO v_quiz_eb;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-07:qcm:1','mft-2026-gotrm:bc01-07:qcm:2','mft-2026-gotrm:bc01-07:qcm:4','mft-2026-gotrm:bc01-07:qcm:6','mft-2026-gotrm:bc01-07:qcm:7','mft-2026-gotrm:bc01-07:qcm:8','mft-2026-gotrm:bc01-07:qcm:10','mft-2026-gotrm:bc01-07:qcm:11','mft-2026-gotrm:bc01-07:qcm:12','mft-2026-gotrm:bc01-07:qcm:14','mft-2026-gotrm:bc01-07:qcm:16','mft-2026-gotrm:bc01-07:qcm:17','mft-2026-gotrm:bc01-07:qcm:20','mft-2026-gotrm:bc01-07:qcm:22','mft-2026-gotrm:bc01-07:qcm:25');

  RAISE NOTICE '✅ GOTRM BC01-07 v2 chargé : 4 leçons, 28 QCM, 5 QR, 5 quizzes (4 entraînement + 1 examen blanc).';
END
$bc01_07$;
