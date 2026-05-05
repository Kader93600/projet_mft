-- =====================================================================
-- GOTRM (RNCP 40990) — BC01-04 : Réglementation sociale R561/2006 et AETR
-- Temps de conduite, pauses, repos, chronotachygraphe.
-- =====================================================================

DO $bc01_04$
DECLARE
  v_formation uuid; v_bloc int; v_module uuid;
  v_lesson_1 uuid; v_lesson_2 uuid; v_lesson_3 uuid; v_lesson_4 uuid;
  v_quiz_1 uuid; v_quiz_2 uuid; v_quiz_3 uuid; v_quiz_4 uuid; v_quiz_eb uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc.'; END IF;

  DELETE FROM public.modules WHERE slug = 'gotrm-bc01-04-temps-conduite-r561';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'BC01-04 — Réglementation sociale européenne : R561/2006 et AETR',
    'gotrm-bc01-04-temps-conduite-r561', v_bloc,
    'Maîtriser le règlement (CE) n° 561/2006 et l''accord AETR : champ d''application, temps de conduite, pauses, repos journaliers et hebdomadaires, fonctionnement du chronotachygraphe et contrôles.',
    'avance', 240, 40
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 40, true) ON CONFLICT DO NOTHING;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-04:%';

  -- =================================================================
  -- LEÇON 1 — Cadre R561 vs AETR
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Cadre réglementaire : R561/2006 vs AETR',
    'gotrm-bc01-04-01-cadre-r561-aetr', 1, 60,
$lesson1$
# Cadre réglementaire : R561/2006 vs AETR

Deux textes encadrent les temps de conduite et de repos en transport routier : le **règlement européen 561/2006** et l'**accord AETR**. Connaître leur champ d'application est la première compétence d'un exploitant : se tromper expose le conducteur et l'entreprise à des sanctions lourdes.

> 🎯 **Objectifs de la leçon**
>
> - Identifier le **champ d'application** de la R561/2006.
> - Distinguer les **transports soumis** et les **dérogations**.
> - Comprendre quand l'**AETR** s'applique à la place de la R561.
> - Maîtriser la **terminologie** professionnelle (semaine, journée, période de conduite).

---

## 1. Le règlement (CE) n° 561/2006

Adopté le **15 mars 2006**, applicable depuis le **11 avril 2007**, modifié par le **paquet mobilité** (règlements 2020/1054 et 2020/1055).

### 1.1 Champ d'application principal

| Critère | Détail |
|---|---|
| **Type de transport** | Marchandises ET voyageurs par route |
| **Géographie** | Trafic au sein de l'**UE / EEE** + Suisse |
| **Véhicules visés** | PTAC > 3,5 t (marchandises) ou plus de 9 places (voyageurs) |

### 1.2 Dérogations à la R561

Certains transports échappent au règlement. Les principales dérogations :

| Catégorie | Exemple |
|---|---|
| **Véhicules ≤ 3,5 t** (jusqu'au 1er juillet 2026) | Transport léger local |
| **VL marchandises ≤ 2,5 t** | Définitivement hors R561 même au paquet mobilité |
| **Vitesse maximale** ≤ 40 km/h | Engins agricoles, chariots élévateurs |
| **Forces armées, police, services d'urgence** | Mission régalienne |
| **Véhicules d'essais ou prototypes** | Tests techniques |
| **Véhicules anciens d'exception** | Plus de 25 ans, non commercial |
| **Transport non commercial** d'aide humanitaire | Cas exceptionnel |
| **Rayon de 100 km** autour du siège | Marchandises liées à l'activité principale (artisans BTP) |

> ⚠️ **Évolution majeure (paquet mobilité)**
>
> Depuis le **1er juillet 2026**, les **utilitaires de 2,5 t à 3,5 t en transport international** doivent respecter la R561 (chronotachygraphe, temps de conduite). Cela concerne les VUL utilisés en messagerie internationale (notamment vers le Royaume-Uni post-Brexit).

---

## 2. L'accord AETR

L'**Accord Européen sur les Transports Routiers** (AETR), signé à Genève en 1970, encadre les transports routiers **internationaux** entre les pays signataires. Aujourd'hui, plus de **50 pays** ont signé l'AETR (UE + pays voisins comme Russie, Turquie, Ukraine, Maroc, Albanie, etc.).

### 2.1 Quand l'AETR s'applique-t-il ?

L'AETR s'applique pour la **partie du trajet effectuée sur le territoire** d'un pays AETR non-UE.

| Trajet | Texte applicable |
|---|---|
| Lyon → Berlin | R561 sur tout le parcours (UE-UE) |
| Lyon → Istanbul | R561 jusqu'à la frontière UE, **AETR ensuite** (Turquie) |
| Paris → Casablanca | R561 dans l'UE, **AETR ensuite** (Maroc) |
| Marseille → Genève | R561 dans l'UE, R561 en Suisse (par accord bilatéral) |

### 2.2 Différences principales R561 vs AETR

| Élément | R561 | AETR |
|---|---|---|
| **Conduite quotidienne max** | 9 h (10 h × 2/sem) | 9 h (10 h × 2/sem) — identique |
| **Conduite hebdomadaire max** | 56 h | 56 h — identique |
| **Pauses** | 45 min après 4 h 30 | 45 min après 4 h 30 — identique |
| **Repos journalier** | 11 h (9 h réduit × 3/sem) | 11 h (9 h réduit × 3/sem) — identique |
| **Repos hebdomadaire** | 45 h (24 h réduit) | 45 h (24 h réduit) — identique |
| **Chronotachygraphe** | Numérique (smart tachygraphe gen.2v2 obligatoire) | Tachygraphe homologué requis |
| **Carte conducteur** | Délivrée par État membre UE | Délivrée par chaque État AETR |

> 💡 **Bonne nouvelle**
>
> Les règles **fond** sont harmonisées (temps de conduite, pauses, repos). Seul le matériel et les cartes peuvent différer. Un conducteur formé R561 connaît à 95 % les règles AETR.

---

## 3. Vocabulaire professionnel à maîtriser

### 3.1 La « semaine » (R561)

C'est la **semaine civile** : du **lundi 0 h 00** au **dimanche 24 h 00**. Pas une semaine glissante.

### 3.2 La « journée de travail »

Période de **24 heures** à partir de la **fin du dernier repos journalier ou hebdomadaire**.

> 📌 **Exemple**
>
> Un conducteur termine son repos journalier le mardi à 6 h 00. Sa nouvelle journée de travail s'achève au plus tard le mercredi à 6 h 00 — il doit alors avoir pris son repos journalier suivant.

### 3.3 La « période de conduite »

C'est la durée **cumulée de conduite** entre deux repos journaliers ou hebdomadaires. À ne pas confondre avec les périodes continues de conduite (qui imposent une pause après 4 h 30).

### 3.4 Le « repos »

Période ininterrompue **sans aucun travail** durant laquelle le conducteur dispose librement de son temps. Une période de simple « disponibilité » (en attente, à proximité du véhicule) **n'est pas du repos**.

---

## 4. Sanctions et catégories

Les infractions à la R561 sont classées en 4 niveaux par le règlement (UE) 2016/403 :

| Catégorie | Sévérité | Exemple |
|---|---|---|
| **MI** (Mineure) | Peu grave | Dépassement < 1 h conduite quotidienne |
| **GI** (Grave) | Grave | Dépassement 1 à 2 h conduite quotidienne |
| **TGI** (Très Grave) | Très grave | Dépassement > 2 h conduite quotidienne |
| **IPG** (Particulièrement Grave) | Critique | Conduite sans carte ou avec falsification |

| Sanction | Montant indicatif (France 2026) |
|---|---|
| Contravention 4e classe (MI) | 90 à 750 € |
| Contravention 5e classe (GI) | 1 500 à 3 000 € |
| Délit (TGI / IPG) | Jusqu'à 30 000 € + immobilisation + suspension permis + emprisonnement (cas extrêmes) |

> ⚠️ **Responsabilité partagée**
>
> Le conducteur ET l'entreprise sont responsables. Une **mauvaise organisation** (planning impossible à respecter) expose l'entreprise à des **amendes administratives** et à une **perte d'honorabilité** professionnelle.

---

> ✅ **À retenir**
>
> - **R561** = trafic intra-UE/EEE/Suisse. **AETR** = trafic vers/depuis pays AETR non-UE.
> - VUL > 3,5 t soumis ; **VUL 2,5 - 3,5 t en international à partir du 1er juillet 2026**.
> - Les règles fond sont **identiques** entre R561 et AETR.
> - Sanctions de 90 € à 30 000 € selon catégorie (MI / GI / TGI / IPG).
$lesson1$,
'Champ d''application de la R561/2006 et de l''AETR, dérogations, vocabulaire professionnel (semaine, journée, période de conduite) et sanctions.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Temps de conduite
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Les temps de conduite : quotidien, hebdomadaire, bihebdomadaire',
    'gotrm-bc01-04-02-temps-conduite', 2, 60,
$lesson2$
# Les temps de conduite : quotidien, hebdomadaire, bihebdomadaire

Le règlement 561/2006 fixe **trois plafonds de conduite** que l'exploitant doit gérer simultanément. Une planification qui respecte le quotidien mais explose l'hebdomadaire est tout aussi sanctionnable.

> 🎯 **Objectifs de la leçon**
>
> - Connaître les **plafonds quotidiens** (9 h normal, 10 h réduit).
> - Maîtriser la **limite hebdomadaire** (56 h).
> - Calculer la **conduite bihebdomadaire** (90 h sur 2 semaines).
> - Appliquer les règles à des **plannings réels**.

---

## 1. Conduite quotidienne

### 1.1 Plafond normal : 9 heures

La conduite **quotidienne** ne peut excéder **9 heures** entre deux repos journaliers.

### 1.2 Plafond exceptionnel : 10 heures

Le conducteur peut prolonger sa conduite quotidienne à **10 heures**, mais **deux fois par semaine maximum**.

### 1.3 Calcul

Le compteur se remet à zéro **après chaque repos journalier régulier ou hebdomadaire**.

| Jour | Conduite réalisée | Validité |
|---|---|---|
| Lundi | 9 h 00 | OK (normal) |
| Mardi | 10 h 00 | OK (1er dépassement de la semaine) |
| Mercredi | 9 h 30 | ❌ Dépassement (mercredi non comptable comme dépassement, mais 9h30 dépasse les 9h normaux) → INFRACTION |
| Jeudi | 10 h 00 | OK (2e dépassement de la semaine) |
| Vendredi | 9 h 00 | OK |

> ⚠️ **Piège fréquent**
>
> Beaucoup confondent « dépassement à 10 h » et « peut conduire 10 h n'importe quand ». **NON** : le plafond reste 9 h. Les **deux exceptions hebdomadaires** doivent être tracées et planifiées.

---

## 2. Conduite hebdomadaire

### 2.1 Plafond : 56 heures

Sur une **semaine civile** (lundi 0 h 00 à dimanche 24 h 00), la conduite cumulée ne peut excéder **56 heures**.

### 2.2 Calcul pratique

Pour un conducteur faisant 9 h × 5 jours + 10 h × 2 jours :
- 9 × 5 = 45 h
- 10 × 2 = 20 h
- **Total = 65 h** → INFRACTION (dépasse 56 h)

Le conducteur doit donc moduler sa conduite. Exemple conforme :
- 9 × 4 + 10 × 2 = 36 + 20 = 56 h (limite) → ratio acceptable mais saturé.

> 💡 **Astuce d'exploitant**
>
> Toujours prévoir une **marge de 4 à 6 h** (viser 50-52 h hebdo) pour absorber les imprévus : aléas circulation, déchargements longs, déclassements.

---

## 3. Conduite bihebdomadaire

### 3.1 Plafond : 90 heures sur 2 semaines consécutives

C'est la règle **la plus contraignante** : sur deux semaines glissantes, la conduite ne peut excéder **90 heures**.

### 3.2 Calcul pratique

| Élément | Détail |
|---|---|
| Semaine 1 | 56 h max possible |
| Semaine 2 | 90 − 56 = **34 h max possible** |

> 📌 **Exemple**
>
> Un conducteur a fait **52 h** en semaine 12. En semaine 13, il pourra conduire **38 h** maximum (52 + 38 = 90). S'il monte à 56 h en semaine 13, il sera en infraction TGI.

### 3.3 Synthèse des trois plafonds

| Plafond | Limite | Notes |
|---|---|---|
| **Quotidien** | 9 h (10 h × 2/sem) | Entre deux repos journaliers |
| **Hebdomadaire** | 56 h | Lundi 0 h à dimanche 24 h |
| **Bihebdomadaire** | 90 h | Sur 2 semaines glissantes |

Les trois s'appliquent **cumulativement** : il faut respecter les trois en même temps.

---

## 4. Cas pratique d'exploitation

**Contexte** : Un conducteur de l'entreprise *Trans-Lyon SAS* a réalisé en semaine 14 :

| Jour | Conduite | Cumul hebdo |
|---|---|---|
| Lundi | 8 h 30 | 8 h 30 |
| Mardi | 9 h 00 | 17 h 30 |
| Mercredi | 10 h 00 | 27 h 30 (1er dépassement) |
| Jeudi | 9 h 30 | 37 h 00 → ❌ INFRACTION (9h30 > 9h sans 2e exception déclarée) |
| Vendredi | 10 h 00 | 47 h 00 (2e dépassement) |
| **Total** | **47 h 00** | — |

Si l'exploitant **avait inversé** mercredi (10 h) et jeudi (9 h 30) :
- Mercredi : 10 h (1er dépassement) → OK
- Jeudi : 9 h 30 → INFRACTION (sans dépassement déclaré, max 9 h)

**Solution conforme** :
- Mercredi : 10 h (1er dépassement)
- Jeudi : 9 h (limite normale)
- Vendredi : 10 h (2e dépassement)
- Total possible : 8 h 30 + 9 h + 10 h + 9 h + 10 h = 46 h 30 (OK quotidien et hebdo)

> 🎯 **Apprentissage**
>
> Anticiper les **deux dépassements** de la semaine **dès le planning du lundi**. Ne pas les utiliser « à la surprise » en cours de semaine.

---

## 5. Doubles équipages et règles spécifiques

### 5.1 Doubles équipages (R561 art. 8 §5)

Avec deux conducteurs, on peut prolonger la **journée de travail** mais **les temps de conduite individuels restent** : 9 h / 10 h × 2.

### 5.2 Cas particulier ferry / train

Lorsqu'un véhicule traverse en ferry ou en train, le conducteur peut **interrompre son repos journalier** maximum **2 fois** pour une durée **totale ≤ 1 heure** (embarquement + débarquement).

> 📌 **Travel time**
>
> Le temps passé pour rejoindre un véhicule situé hors du domicile (taxi, train, avion) compte comme **autre travail** et impacte les temps cumulés.

---

> ✅ **À retenir**
>
> - Conduite quotidienne : **9 h** (10 h × 2/sem maximum).
> - Conduite hebdomadaire : **56 h** maximum.
> - Conduite bihebdomadaire : **90 h** sur 2 semaines glissantes.
> - Toujours prévoir une **marge de sécurité de 4 à 6 h hebdo** dans les plannings.
> - Anticiper les 2 dépassements à 10 h **dès la planification**.
$lesson2$,
'Plafonds de conduite quotidiens (9h/10h), hebdomadaires (56h) et bihebdomadaires (90h), avec cas pratiques de planification.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Pauses et repos
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Pauses et repos : journaliers et hebdomadaires',
    'gotrm-bc01-04-03-pauses-repos', 3, 60,
$lesson3$
# Pauses et repos : journaliers et hebdomadaires

Les **pauses** s'imposent au cours de la conduite, les **repos** entre deux journées de travail. Bien gérer ces périodes est aussi important que les temps de conduite eux-mêmes — et autant sanctionnable en cas de manquement.

> 🎯 **Objectifs de la leçon**
>
> - Maîtriser la **pause obligatoire** après 4 h 30 de conduite.
> - Connaître le **repos journalier** (normal et réduit).
> - Connaître le **repos hebdomadaire** (régulier et réduit) et la **compensation**.
> - Appliquer le retour au domicile **toutes les 4 semaines** (paquet mobilité).

---

## 1. La pause obligatoire (R561 art. 7)

### 1.1 Le principe

Après **4 h 30 de conduite cumulée**, le conducteur doit prendre une pause de **45 minutes** minimum.

### 1.2 Le fractionnement autorisé

La pause de 45 min peut être fractionnée en **deux parties** :
- Une **première période** de **15 min** minimum
- Suivie d'une **seconde période** de **30 min** minimum
- Dans cet ordre uniquement (15 puis 30, jamais l'inverse)

> 📌 **Exemple**
>
> Conduite 2 h → pause 15 min → conduite 2 h 30 → pause 30 min → conduite jusqu'au prochain seuil.
>
> Total : 45 min de pause atteinte avant 4 h 30, conforme.

### 1.3 Ce qui n'est PAS une pause

| Activité | Compte comme pause ? |
|---|---|
| Repas dans un restaurant routier | ✅ Oui (si pas de travail) |
| Attente du déchargement, conducteur disponible | ❌ Non (« autre travail ») |
| Sieste de 20 min seule | ❌ Non (durée insuffisante) |
| Discussion téléphonique professionnelle | ❌ Non |

---

## 2. Le repos journalier (R561 art. 8)

### 2.1 Repos journalier normal

**11 heures consécutives** dans une période de **24 heures** suivant la fin du dernier repos.

### 2.2 Repos journalier fractionné

Le 11 h peut être fractionné en :
- Une **première période** de **3 h** minimum
- Suivie d'une **seconde période** de **9 h** minimum
- **Total ≥ 12 h** dans cet ordre

### 2.3 Repos journalier réduit

**9 heures consécutives** au lieu de 11 h.

| Règle | Détail |
|---|---|
| Maximum | **3 fois entre deux repos hebdomadaires** |
| Compensation | Aucune compensation requise depuis le paquet mobilité |
| Application typique | Tournées exigeantes, retour tardif |

### 2.4 Synthèse repos journalier

| Type | Durée | Limite |
|---|---|---|
| Normal | 11 h consécutives | Standard |
| Fractionné | 3 h + 9 h (≥12 h) | Possible si 1ère période avant la 2e |
| Réduit | 9 h consécutives | 3 fois max entre 2 repos hebdo |

---

## 3. Le repos hebdomadaire (R561 art. 8 §6)

### 3.1 Repos hebdomadaire régulier

**45 heures consécutives** au moins une fois par semaine.

### 3.2 Repos hebdomadaire réduit

**24 heures consécutives** au minimum.

### 3.3 La règle des « 6 jours »

Un conducteur ne peut conduire **plus de 6 jours consécutifs** sans prendre un repos hebdomadaire (régulier ou réduit). Ce repos doit débuter au plus tard **après 6 périodes de 24 h** de conduite.

### 3.4 Combinaison régulier / réduit sur 2 semaines

Sur **deux semaines consécutives**, le conducteur doit prendre :
- **Soit** 2 repos hebdomadaires réguliers (45 h × 2 = 90 h)
- **Soit** 1 régulier (45 h) + 1 réduit (24 h) = 69 h

> 📌 **Compensation du réduit**
>
> Lorsque le repos hebdomadaire est réduit (24 h au lieu de 45 h), le conducteur a droit à une **compensation** de **21 h** (= 45 − 24) à prendre **avant la fin de la 3e semaine** suivante, en bloc, accolée à un autre repos d'au moins 9 heures.

### 3.5 Repos hebdomadaire et cabine (paquet mobilité)

Depuis le **paquet mobilité (août 2020)**, le **repos hebdomadaire régulier (45 h)** ne peut **plus être pris dans la cabine du véhicule**. L'employeur doit fournir **un hébergement adapté** (hôtel, base, domicile).

| Type de repos | Cabine autorisée ? |
|---|---|
| Repos journalier (9 h ou 11 h) | ✅ Oui |
| Repos hebdomadaire **réduit** (24 h) | ✅ Oui |
| Repos hebdomadaire **régulier** (45 h) | ❌ NON — hébergement obligatoire |

> ⚠️ **Sanction nouvelle**
>
> Un conducteur qui prend son repos hebdomadaire régulier en cabine s'expose à une amende de **500 €** (le conducteur), et l'entreprise à une amende administrative pouvant atteindre **30 000 €** par cas constaté.

---

## 4. Le retour au domicile (paquet mobilité)

L'entreprise doit **organiser le retour** du conducteur **toutes les 4 semaines** au :
- **Centre opérationnel d'établissement** de l'employeur (siège ou base d'attachement), OU
- **Domicile du conducteur**

Le conducteur peut prendre **ses 2 repos hebdomadaires réguliers consécutifs** dans ce contexte (donc absent jusqu'à 4 semaines en théorie, mais avec un retour minimum à cette fréquence).

> 📌 **Trace dans le tachygraphe**
>
> Le conducteur doit pouvoir **prouver** son retour : enregistrement automatique du passage frontière depuis le smart tachygraphe gen.2, ou attestation employeur.

---

## 5. Cas pratique : un planning conforme

**Contexte** : Tournée internationale Strasbourg → Madrid.

| Période | Activité | Conformité |
|---|---|---|
| Lun 6 h - 10 h 30 | Conduite 4 h 30 | OK (limite avant pause) |
| Lun 10 h 30 - 11 h 15 | Pause 45 min | OK |
| Lun 11 h 15 - 14 h 45 | Conduite 3 h 30 | Total quotidien : 8 h |
| Lun 14 h 45 - 16 h | Déchargement | « Autre travail » |
| Lun 16 h - 17 h | Conduite 1 h | Total : 9 h (limite) |
| Lun 17 h - Mar 4 h | **Repos journalier 11 h** | OK (normal, en cabine autorisé) |
| Mar 4 h - 8 h 30 | Conduite 4 h 30 | OK |
| Mar 8 h 30 - 9 h 15 | Pause 45 min | OK |
| ... | ... | ... |
| Sam 17 h - Lun 14 h | **Repos hebdomadaire régulier 45 h** | OK, pris en hôtel à Madrid |

---

## 6. Récapitulatif visuel

| Compteur | Limite | Reset |
|---|---|---|
| Conduite continue | 4 h 30 → pause 45 min | Après chaque pause |
| Conduite quotidienne | 9 h (10 h × 2/sem) | Repos journalier |
| Conduite hebdomadaire | 56 h | Lundi 0 h |
| Conduite bihebdomadaire | 90 h | 2 sem glissantes |
| Repos journalier | 11 h (9 h × 3/sem) | Entre 2 journées |
| Repos hebdomadaire | 45 h (24 h × 1/2 sem) | 1 fois par semaine |
| Repos hebdo régulier en cabine | INTERDIT | — |
| Retour au domicile | Toutes les 4 sem max | — |

---

> ✅ **À retenir**
>
> - **Pause** : 45 min après 4 h 30 conduite (fractionnable 15 + 30).
> - **Repos journalier** : 11 h (réduit 9 h × 3/sem).
> - **Repos hebdo** : 45 h (réduit 24 h × 1/2 sem, avec compensation 21 h).
> - **Repos hebdo régulier 45 h INTERDIT en cabine** depuis août 2020.
> - **Retour au domicile** organisé toutes les 4 semaines maximum.
$lesson3$,
'Pauses (45 min après 4h30), repos journaliers (11h/9h), repos hebdomadaires (45h/24h), interdiction du 45h en cabine et retour au domicile.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Chronotachygraphe et contrôles
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Le chronotachygraphe et les contrôles',
    'gotrm-bc01-04-04-chronotachygraphe', 4, 60,
$lesson4$
# Le chronotachygraphe et les contrôles

Le **chronotachygraphe** est l'outil central qui enregistre toute l'activité du conducteur et permet le contrôle a posteriori. L'exploitant doit savoir l'utiliser, télécharger les données régulièrement et défendre l'entreprise lors des contrôles.

> 🎯 **Objectifs de la leçon**
>
> - Connaître les **types de tachygraphes** (analogique, numérique, smart gen.1, gen.2, gen.2v2).
> - Maîtriser les **cartes** (conducteur, entreprise, atelier, contrôleur).
> - Respecter les **obligations de téléchargement** des données.
> - Préparer un **contrôle routier** ou **en entreprise**.

---

## 1. Évolution des tachygraphes

| Génération | Période | Caractéristique |
|---|---|---|
| **Analogique** | Avant 2006 | Disques papier, encre |
| **Numérique** (1B) | 2006 - 2019 | Carte conducteur, mémoire interne |
| **Smart Tachygraphe gen.1** | Juin 2019 - août 2023 | GPS, communication DSRC contrôleur |
| **Smart Tachygraphe gen.2** | Depuis août 2023 (neufs) | Frontières automatiques, plus précis |
| **Smart Tachygraphe gen.2v2** | Depuis 21/08/2023 (neufs) — rétrofit obligatoire selon calendrier | Détection franchissement frontières renforcée, ferry/train |

### 1.1 Calendrier de rétrofit (paquet mobilité)

| Échéance | Obligation |
|---|---|
| **31 décembre 2024** | Tous les véhicules en transport international doivent avoir un smart tachygraphe gen.1 minimum |
| **18 août 2025** | Smart tachygraphe gen.2v2 obligatoire pour tout véhicule en international |
| **1er juillet 2026** | VUL 2,5 - 3,5 t en international doivent avoir un tachygraphe |

> ⚠️ **Vérifier le parc**
>
> Un exploitant qui maintient un véhicule avec tachygraphe non conforme **après l'échéance** s'expose à une **immobilisation immédiate** lors du contrôle, et à une amende administrative de plusieurs milliers d'euros.

---

## 2. Les cartes tachygraphiques

### 2.1 La carte conducteur

| Caractéristique | Valeur |
|---|---|
| Délivrée par | Chronoservices (France) |
| Validité | **5 ans** |
| Coût | Environ **70 €** |
| Stockage | **28 jours** d'activité minimum |
| Utilisation | 1 conducteur = 1 carte unique nominative |

> 📌 **Obligation**
>
> Tout conducteur soumis à la R561 doit **insérer sa carte** dès la prise du véhicule. Conduire sans carte (ou avec celle d'autrui) est une infraction **IPG** (Particulièrement Grave) avec immobilisation immédiate.

### 2.2 La carte entreprise

| Caractéristique | Valeur |
|---|---|
| Délivrée à | Toute entreprise de transport |
| Validité | **5 ans** |
| Usage | Verrouillage des données, téléchargement, accès aux fichiers |
| Quantité | Plusieurs cartes possibles (1 par exploitant) |

### 2.3 Les autres cartes

| Carte | Usage |
|---|---|
| **Carte d'atelier** | Centres techniques agréés (calibrage, test) |
| **Carte de contrôleur** | DREAL, douanes, gendarmerie, police |

---

## 3. Téléchargement des données

### 3.1 Données véhicule (VU)

À télécharger **au moins tous les 90 jours**, et systématiquement **avant la cession** ou **mise au rebut** d'un véhicule.

### 3.2 Données conducteur (carte)

À télécharger **au moins tous les 28 jours** (la carte conserve seulement 28 jours).

> 📌 **Conséquence d'un retard**
>
> Si vous télécharger la carte d'un conducteur tous les 60 jours, vous **perdez** les 32 premiers jours d'activité. Lors d'un contrôle qui demande 56 jours d'historique, vous serez en infraction documentaire.

### 3.3 Conservation des données

| Document | Durée légale de conservation |
|---|---|
| Données véhicule (VU) | **1 an** minimum |
| Données conducteur (carte) | **1 an** minimum |
| Disques analogiques (anciens véhicules) | **1 an** minimum |
| Documents écrits (LIC, CMR, BL) | **5 ans** (obligation comptable) |

### 3.4 Outils de téléchargement

| Outil | Caractéristique |
|---|---|
| **Clé de téléchargement** | Téléchargement local sur USB (Continental DLK Pro, Tachoreader) |
| **Logiciel d'exploitation** | Tachostore, OPTAC3, FleetBoard, TKBL, etc. |
| **Téléchargement à distance** | Via télématique embarquée + serveur distant |
| **Analyse infractions** | Logiciels métier identifient automatiquement les infractions |

---

## 4. Le contrôle routier

### 4.1 Qui contrôle ?

| Autorité | Mission |
|---|---|
| **DREAL** (contrôleurs des transports terrestres) | Contrôle métier complet, immobilisation possible |
| **Police nationale, gendarmerie** | Contrôle de la conformité |
| **Douanes** | Marchandises et tachygraphe |
| **Inspection du travail** | Conditions de travail conducteur |

### 4.2 Documents à présenter

Le conducteur doit pouvoir présenter :
- **Carte conducteur** insérée dans le tachygraphe
- **Permis de conduire**
- **Disque(s) analogique(s)** des 28 derniers jours si véhicule analogique
- **Lettre de voiture**, CMR, documents marchandise
- **Attestation d'activité** (jours sans conduite, congés, formation, maladie)
- **Carte qualification conducteur** (CQC) ou attestation FCO
- **Permis de conduire** et carte conducteur valides

### 4.3 Période de contrôle

Le contrôle porte sur **la journée en cours et les 56 jours précédents** (paquet mobilité, contre 28 auparavant).

> 📌 **Smart tachygraphe et DSRC**
>
> Les smart tachygraphes communiquent avec un boîtier DSRC qui permet aux contrôleurs de **détecter à distance** les anomalies sans même arrêter le véhicule. La présélection des véhicules à contrôler est de plus en plus systématique.

---

## 5. Le contrôle en entreprise

### 5.1 Déroulement type

1. Avis de contrôle (7 jours minimum, sauf flagrance)
2. Présentation des cartes entreprise et du parc véhicules
3. Mise à disposition des fichiers tachygraphes (.DDD, .V1B, .C1B)
4. Vérification croisée : disques analogiques / numériques / plannings / bulletins de paie
5. Procès-verbal de contrôle

### 5.2 Sanctions possibles

| Niveau | Sanction |
|---|---|
| Infractions ponctuelles | Amendes par cas (90 à 3 000 €) |
| Anomalies systémiques | Mise en demeure, contrôle approfondi |
| Manquement grave | Retrait d'**honorabilité** professionnelle |
| Fraude organisée | Procédure pénale, retrait LTI |

> ⚠️ **L'honorabilité**
>
> Le gestionnaire de transport et l'entreprise doivent maintenir leur **honorabilité professionnelle** (article R3411-1 du Code des transports). Une perte d'honorabilité **suspend la licence de transport** : c'est la sanction la plus redoutable.

---

## 6. Cas pratique de défense

**Contexte** : Lors d'un contrôle DREAL, l'inspecteur constate **3 infractions GI** sur 56 jours pour un conducteur :
- 1 dépassement quotidien (9 h 25 au lieu de 9 h)
- 1 pause insuffisante (40 min au lieu de 45)
- 1 repos hebdomadaire pris en cabine

**Réaction de l'exploitant** :

1. **Documenter le contexte** : conditions exceptionnelles (intempéries, accident en amont) ?
2. **Présenter les outils de prévention** : système télématique, alerte IA en temps réel.
3. **Démontrer la formation** : carnet de formation conducteur, briefings.
4. **Plan d'action correctif** : règle interne, sanction disciplinaire éventuelle, suivi mensuel.
5. **Coopération** : transmission spontanée des fichiers complémentaires demandés.

> 💡 **Ce qu'il faut éviter**
>
> - Nier ou minimiser
> - Tenter de modifier les fichiers tachygraphes (fraude pénale)
> - Mettre la faute sur le conducteur sans assumer la responsabilité d'employeur

---

> ✅ **À retenir**
>
> - **Smart tachygraphe gen.2v2** obligatoire en international depuis août 2025.
> - **Carte conducteur** stocke 28 jours → téléchargement tous les **28 jours**.
> - **Données véhicule** téléchargées tous les **90 jours**, conservées **1 an**.
> - Contrôle porte sur **56 jours** (paquet mobilité) — ne plus se limiter aux 28 jours.
> - **Honorabilité professionnelle** = condition de la licence de transport.
$lesson4$,
'Évolution des tachygraphes (analogique → smart gen.2v2), cartes, obligations de téléchargement (28j conducteur, 90j véhicule, 1 an conservation) et contrôles routiers/entreprise.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- 30 QCM REFORMULÉS
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, source_ref, type, prompt, choices, correct, explanation, difficulty, tags) VALUES

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:1', 'qcm',
   'Le règlement (CE) n° 561/2006 s''applique au transport de marchandises par véhicule de PTAC :',
   jsonb '[
     {"key":"a","label":"Strictement supérieur à 2,5 t"},
     {"key":"b","label":"Strictement supérieur à 3,5 t"},
     {"key":"c","label":"Strictement supérieur à 7,5 t"},
     {"key":"d","label":"Strictement supérieur à 12 t"}
   ]', '["b"]'::jsonb,
   'La R561/2006 s''applique aux véhicules de marchandises dont le PTAC excède 3,5 t. Depuis le 1er juillet 2026, les VUL de 2,5 à 3,5 t en transport international y sont également soumis (paquet mobilité).',
   'facile', '{r561,champ-application}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:2', 'qcm',
   'L''accord AETR s''applique pour la partie du trajet effectuée :',
   jsonb '[
     {"key":"a","label":"Sur le territoire d''un pays UE"},
     {"key":"b","label":"Sur le territoire d''un pays AETR non-UE (Russie, Turquie, Maroc...)"},
     {"key":"c","label":"En cabotage uniquement"},
     {"key":"d","label":"Pour le transport intérieur français"}
   ]', '["b"]'::jsonb,
   'L''AETR couvre le trafic international entre pays signataires. Sur un Lyon-Istanbul, la R561 s''applique côté UE et l''AETR côté Turquie. Les règles fond sont harmonisées entre les deux textes.',
   'moyenne', '{aetr,champ-application}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:3', 'qcm',
   'Le temps de conduite quotidien maximum normal est de :',
   jsonb '[
     {"key":"a","label":"8 heures"},
     {"key":"b","label":"9 heures"},
     {"key":"c","label":"10 heures"},
     {"key":"d","label":"11 heures"}
   ]', '["b"]'::jsonb,
   'La R561 fixe la conduite quotidienne à 9 h. Elle peut être prolongée à 10 h deux fois par semaine maximum, ce qui doit être planifié et tracé.',
   'facile', '{conduite,quotidien}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:4', 'qcm',
   'Le temps de conduite hebdomadaire maximum est de :',
   jsonb '[
     {"key":"a","label":"45 heures"},
     {"key":"b","label":"48 heures"},
     {"key":"c","label":"56 heures"},
     {"key":"d","label":"60 heures"}
   ]', '["c"]'::jsonb,
   'La conduite hebdomadaire ne peut excéder 56 h sur une semaine civile (lundi 0h à dimanche 24h). À ne pas confondre avec le temps de travail qui obéit à d''autres règles (Code du travail).',
   'facile', '{conduite,hebdo}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:5', 'qcm',
   'Le temps de conduite bihebdomadaire (sur 2 semaines consécutives) est plafonné à :',
   jsonb '[
     {"key":"a","label":"80 heures"},
     {"key":"b","label":"90 heures"},
     {"key":"c","label":"100 heures"},
     {"key":"d","label":"112 heures"}
   ]', '["b"]'::jsonb,
   'La conduite cumulée sur 2 semaines glissantes ne peut dépasser 90 h. Si un conducteur a fait 56 h en S1, il ne peut conduire que 34 h en S2 (90-56).',
   'moyenne', '{conduite,bihebdo}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:6', 'qcm',
   'La pause après 4 h 30 de conduite continue est de :',
   jsonb '[
     {"key":"a","label":"30 minutes"},
     {"key":"b","label":"45 minutes"},
     {"key":"c","label":"60 minutes"},
     {"key":"d","label":"15 minutes"}
   ]', '["b"]'::jsonb,
   'La pause obligatoire après 4 h 30 de conduite cumulée est de 45 minutes. Elle peut être fractionnée en 15 min puis 30 min (dans cet ordre uniquement).',
   'facile', '{pause}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:7', 'qcm',
   'Le fractionnement de la pause de 45 min est autorisé sous la forme :',
   jsonb '[
     {"key":"a","label":"30 min puis 15 min"},
     {"key":"b","label":"15 min puis 30 min"},
     {"key":"c","label":"3 × 15 min"},
     {"key":"d","label":"20 min + 25 min"}
   ]', '["b"]'::jsonb,
   'Le fractionnement n''est autorisé qu''en 15 min minimum suivi de 30 min minimum, dans cet ordre. L''inverse (30+15) ou un fractionnement en 3 fois ne sont pas conformes.',
   'moyenne', '{pause,fractionnement}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:8', 'qcm',
   'Le repos journalier normal est de :',
   jsonb '[
     {"key":"a","label":"9 h consécutives"},
     {"key":"b","label":"10 h consécutives"},
     {"key":"c","label":"11 h consécutives"},
     {"key":"d","label":"12 h consécutives"}
   ]', '["c"]'::jsonb,
   'Le repos journalier normal est de 11 h consécutives. Il peut être réduit à 9 h trois fois entre deux repos hebdomadaires, ou fractionné 3+9 (total ≥ 12 h).',
   'facile', '{repos,journalier}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:9', 'qcm',
   'Le repos journalier réduit à 9 h est autorisé :',
   jsonb '[
     {"key":"a","label":"Sans limite"},
     {"key":"b","label":"3 fois entre deux repos hebdomadaires"},
     {"key":"c","label":"1 fois par semaine"},
     {"key":"d","label":"Uniquement si compensation immédiate"}
   ]', '["b"]'::jsonb,
   'Le repos réduit à 9 h est limité à 3 fois entre deux repos hebdomadaires consécutifs. Depuis le paquet mobilité, aucune compensation n''est due (avant 2020, oui).',
   'moyenne', '{repos,reduit}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:10', 'qcm',
   'Le repos hebdomadaire régulier est de :',
   jsonb '[
     {"key":"a","label":"24 h"},
     {"key":"b","label":"36 h"},
     {"key":"c","label":"45 h"},
     {"key":"d","label":"56 h"}
   ]', '["c"]'::jsonb,
   'Le repos hebdomadaire régulier est de 45 h consécutives au moins. Il peut être réduit à 24 h dans la limite d''un sur deux semaines, avec compensation de 21 h à prendre dans les 3 semaines suivantes.',
   'facile', '{repos,hebdo}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:11', 'qcm',
   'Le repos hebdomadaire régulier de 45 h peut-il être pris dans la cabine du véhicule ?',
   jsonb '[
     {"key":"a","label":"Oui, c''est expressément autorisé"},
     {"key":"b","label":"Oui, à condition que la cabine soit aménagée"},
     {"key":"c","label":"Non, c''est interdit depuis le paquet mobilité (août 2020)"},
     {"key":"d","label":"Oui, mais uniquement à l''étranger"}
   ]', '["c"]'::jsonb,
   'Depuis août 2020, le repos hebdomadaire régulier (45 h) doit obligatoirement être pris hors cabine (hôtel, base, domicile). Sanction : 500 € pour le conducteur, jusqu''à 30 000 € pour l''entreprise.',
   'moyenne', '{repos,paquet-mobilite}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:12', 'qcm',
   'L''entreprise doit organiser le retour du conducteur au domicile ou à la base au moins :',
   jsonb '[
     {"key":"a","label":"Toutes les semaines"},
     {"key":"b","label":"Toutes les 2 semaines"},
     {"key":"c","label":"Toutes les 4 semaines"},
     {"key":"d","label":"Toutes les 8 semaines"}
   ]', '["c"]'::jsonb,
   'Le paquet mobilité impose l''organisation du retour au moins toutes les 4 semaines, soit au centre d''établissement de l''employeur, soit au domicile du conducteur.',
   'moyenne', '{retour-domicile,paquet-mobilite}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:13', 'qcm',
   'Quand le repos hebdomadaire est réduit (24 h), la compensation due est de :',
   jsonb '[
     {"key":"a","label":"9 h"},
     {"key":"b","label":"15 h"},
     {"key":"c","label":"21 h"},
     {"key":"d","label":"45 h"}
   ]', '["c"]'::jsonb,
   'La différence entre le repos régulier (45 h) et le repos réduit (24 h) est de 21 h. Cette compensation doit être prise en bloc avant la fin de la 3e semaine suivante, accolée à un repos d''au moins 9 h.',
   'moyenne', '{compensation,calcul}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:14', 'qcm',
   'Un conducteur ne peut conduire plus de combien de jours consécutifs sans repos hebdomadaire ?',
   jsonb '[
     {"key":"a","label":"5 jours"},
     {"key":"b","label":"6 jours"},
     {"key":"c","label":"7 jours"},
     {"key":"d","label":"10 jours"}
   ]', '["b"]'::jsonb,
   'La règle des 6 jours impose un repos hebdomadaire (régulier ou réduit) au plus tard après 6 périodes de 24 h consécutives de travail.',
   'moyenne', '{repos,regle-6-jours}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:15', 'qcm',
   'La carte conducteur tachygraphique a une validité de :',
   jsonb '[
     {"key":"a","label":"2 ans"},
     {"key":"b","label":"5 ans"},
     {"key":"c","label":"7 ans"},
     {"key":"d","label":"10 ans"}
   ]', '["b"]'::jsonb,
   'La carte conducteur a une validité de 5 ans. Son renouvellement doit être anticipé car son absence interdit la conduite de tout véhicule soumis au tachygraphe numérique.',
   'facile', '{carte-conducteur}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:16', 'qcm',
   'La carte conducteur stocke combien de jours d''activité minimum ?',
   jsonb '[
     {"key":"a","label":"7 jours"},
     {"key":"b","label":"14 jours"},
     {"key":"c","label":"28 jours"},
     {"key":"d","label":"56 jours"}
   ]', '["c"]'::jsonb,
   'La carte conducteur conserve au minimum 28 jours d''activité (en pratique souvent un peu plus). C''est pourquoi le téléchargement doit être fait au moins tous les 28 jours pour éviter toute perte de données.',
   'moyenne', '{carte-conducteur,stockage}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:17', 'qcm',
   'Le téléchargement des données de l''unité véhicule doit être effectué au moins tous les :',
   jsonb '[
     {"key":"a","label":"28 jours"},
     {"key":"b","label":"60 jours"},
     {"key":"c","label":"90 jours"},
     {"key":"d","label":"180 jours"}
   ]', '["c"]'::jsonb,
   'Les données VU doivent être téléchargées au moins tous les 90 jours, et systématiquement avant cession ou mise au rebut du véhicule. Les données conducteur, elles, doivent être téléchargées tous les 28 jours.',
   'moyenne', '{telechargement,vu}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:18', 'qcm',
   'Les données du tachygraphe doivent être conservées par l''entreprise pendant au moins :',
   jsonb '[
     {"key":"a","label":"6 mois"},
     {"key":"b","label":"1 an"},
     {"key":"c","label":"3 ans"},
     {"key":"d","label":"5 ans"}
   ]', '["b"]'::jsonb,
   'La conservation légale est de 1 an minimum pour les données numériques (VU et carte) ainsi que pour les disques analogiques. La comptabilité impose 5 ans pour les pièces commerciales (CMR, BL, factures).',
   'moyenne', '{conservation,donnees}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:19', 'qcm',
   'Le contrôle routier porte sur quelle période d''activité (paquet mobilité 2020) ?',
   jsonb '[
     {"key":"a","label":"Le jour même uniquement"},
     {"key":"b","label":"Les 28 derniers jours"},
     {"key":"c","label":"La journée en cours et les 56 jours précédents"},
     {"key":"d","label":"Les 12 derniers mois"}
   ]', '["c"]'::jsonb,
   'Le paquet mobilité a étendu la période de contrôle de 28 à 56 jours. Le conducteur doit pouvoir présenter ses activités du jour et des 56 jours précédents (carte numérique + attestations d''activité).',
   'moyenne', '{controle,periode}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:20', 'qcm',
   'Conduire avec la carte d''un autre conducteur constitue une infraction :',
   jsonb '[
     {"key":"a","label":"Mineure (MI)"},
     {"key":"b","label":"Grave (GI)"},
     {"key":"c","label":"Très Grave (TGI)"},
     {"key":"d","label":"Particulièrement Grave (IPG)"}
   ]', '["d"]'::jsonb,
   'Conduire avec la carte d''un autre, ou sans carte, est une infraction IPG (Particulièrement Grave) qui peut entraîner immobilisation immédiate, retrait permis, amende délictuelle jusqu''à 30 000 € et perte d''honorabilité.',
   'difficile', '{infraction,categorie}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:21', 'qcm',
   'Un conducteur a effectué 52 h de conduite en semaine 8. Quelle est sa conduite maximale en semaine 9 ?',
   jsonb '[
     {"key":"a","label":"38 h"},
     {"key":"b","label":"45 h"},
     {"key":"c","label":"52 h"},
     {"key":"d","label":"56 h"}
   ]', '["a"]'::jsonb,
   'Le plafond bihebdomadaire est de 90 h. Si le conducteur a fait 52 h en S8, il peut faire 90-52=38 h en S9. La limite hebdo de 56 h n''est pas atteinte mais le bihebdo prime.',
   'difficile', '{calcul,bihebdo}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:22', 'qcm',
   'Le smart tachygraphe gen.2v2 est obligatoire en transport international depuis :',
   jsonb '[
     {"key":"a","label":"Janvier 2024"},
     {"key":"b","label":"Août 2025"},
     {"key":"c",  "label":"Janvier 2026"},
     {"key":"d","label":"Janvier 2030"}
   ]', '["b"]'::jsonb,
   'Le calendrier paquet mobilité impose le smart tachygraphe gen.2v2 pour tous les véhicules en transport international depuis le 18 août 2025. Les véhicules anciens doivent être rétrofittés.',
   'moyenne', '{smart-tachygraphe,calendrier}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:23', 'qcm',
   'Un dépassement de conduite quotidienne de 25 minutes est classé :',
   jsonb '[
     {"key":"a","label":"MI - Mineure"},
     {"key":"b","label":"GI - Grave"},
     {"key":"c","label":"TGI - Très Grave"},
     {"key":"d","label":"IPG - Particulièrement Grave"}
   ]', '["a"]'::jsonb,
   'Un dépassement < 1 h de conduite quotidienne est classé MI (Mineure). Entre 1 h et 2 h : GI. Au-delà de 2 h : TGI. Les seuils sont fixés par le règlement (UE) 2016/403.',
   'difficile', '{infraction,gradation}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:24', 'qcm',
   'L''attestation d''activité (jours sans conduite) est utilisée pour justifier :',
   jsonb '[
     {"key":"a","label":"Les pauses non enregistrées sur la carte"},
     {"key":"b","label":"Les jours de congés, maladie, formation, repos hors véhicule"},
     {"key":"c","label":"Les heures supplémentaires"},
     {"key":"d","label":"Les frais professionnels"}
   ]', '["b"]'::jsonb,
   'L''attestation d''activité (formulaire UE) sert à justifier les périodes où le conducteur n''a pas inséré sa carte (congés, maladie, formation, RTT, autre travail non lié à un véhicule). Elle est signée par l''employeur et le conducteur.',
   'moyenne', '{attestation-activite}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:25', 'qcm',
   'En double équipage, le temps de conduite individuel maximum reste :',
   jsonb '[
     {"key":"a","label":"9 h (10 h × 2/sem)"},
     {"key":"b","label":"12 h"},
     {"key":"c","label":"18 h"},
     {"key":"d","label":"Aucune limite"}
   ]', '["a"]'::jsonb,
   'En double équipage, on peut prolonger la journée de travail (déplacement plus long) mais les temps individuels de conduite restent les mêmes : 9 h normal, 10 h max 2 fois/semaine. Chaque conducteur doit respecter ses propres plafonds.',
   'moyenne', '{double-equipage}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:26', 'qcm',
   'Une attente de 2 h pendant un déchargement où le conducteur reste à proximité du véhicule est classée :',
   jsonb '[
     {"key":"a","label":"Conduite"},
     {"key":"b","label":"Pause"},
     {"key":"c","label":"Autre travail / Disponibilité"},
     {"key":"d","label":"Repos"}
   ]', '["c"]'::jsonb,
   'Une attente où le conducteur n''est pas libre de son temps n''est pas du repos ni une pause. Elle est classée comme « disponibilité » ou « autre travail » selon le contexte. Seule une période ininterrompue où le conducteur dispose librement de son temps est une pause valide.',
   'moyenne', '{disponibilite}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:27', 'qcm',
   'L''honorabilité professionnelle peut être perdue notamment en cas de :',
   jsonb '[
     {"key":"a","label":"Retard de paiement de la TVA"},
     {"key":"b","label":"Cumul d''infractions graves répétées (notamment R561)"},
     {"key":"c","label":"Dépassement de capacité du véhicule"},
     {"key":"d","label":"Défaut d''ABS"}
   ]', '["b"]'::jsonb,
   'L''honorabilité professionnelle (R3411-1 Code des transports) repose sur l''absence de condamnations ou cumul d''infractions graves : R561, fraudes tachygraphe, pratiques anticoncurrentielles. Sa perte suspend la licence de transport.',
   'difficile', '{honorabilite}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:28', 'qcm',
   'Sur un trajet Marseille → Casablanca, quel(s) texte(s) s''applique(nt) ?',
   jsonb '[
     {"key":"a","label":"R561 sur tout le parcours"},
     {"key":"b","label":"AETR sur tout le parcours"},
     {"key":"c","label":"R561 dans l''UE puis AETR au Maroc"},
     {"key":"d","label":"Aucune réglementation européenne au-delà de l''UE"}
   ]', '["c"]'::jsonb,
   'Le Maroc est signataire de l''AETR. La R561 s''applique sur le parcours UE (jusqu''au port d''embarquement), puis l''AETR prend le relais au Maroc. Les règles fond étant identiques, le conducteur ne change rien à ses temps.',
   'moyenne', '{aetr,trajet-international}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:29', 'qcm',
   'Pour les VUL marchandises de 2,5 t à 3,5 t en transport international, l''application de la R561 est obligatoire depuis :',
   jsonb '[
     {"key":"a","label":"Janvier 2020"},
     {"key":"b","label":"Mai 2022"},
     {"key":"c","label":"1er juillet 2026"},
     {"key":"d","label":"Cette catégorie reste exemptée"}
   ]', '["c"]'::jsonb,
   'Le paquet mobilité a étendu la R561 aux VUL 2,5-3,5 t en transport international à partir du 1er juillet 2026. Les VUL ≤ 2,5 t restent exemptés, ainsi que les transports nationaux.',
   'difficile', '{paquet-mobilite,vul}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qcm:30', 'qcm',
   'Lors d''un contrôle routier, si le conducteur ne peut pas présenter d''attestation d''activité pour 5 jours non enregistrés sur sa carte :',
   jsonb '[
     {"key":"a","label":"Pas d''infraction si la période est ancienne"},
     {"key":"b","label":"Infraction documentaire passible d''amende"},
     {"key":"c","label":"Infraction tolérée si le conducteur s''explique oralement"},
     {"key":"d","label":"Infraction uniquement à l''étranger"}
   ]', '["b"]'::jsonb,
   'Toute période non enregistrée par le tachygraphe doit être justifiée par une attestation d''activité (formulaire UE). En l''absence de justificatif, c''est une infraction documentaire avec amende à la charge de l''entreprise et du conducteur.',
   'moyenne', '{attestation,controle}');

  -- =================================================================
  -- 6 QR (questions rédigées)
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, source_ref, type, prompt, choices, correct, explanation, difficulty, tags) VALUES

  (v_formation, 'mft-2026-gotrm:bc01-04:qr:1', 'qr',
   'Un conducteur de votre entreprise réalise la semaine 18 le planning suivant : Lundi 9 h conduite, Mardi 10 h, Mercredi 9 h 30, Jeudi 9 h, Vendredi 10 h. Identifiez la ou les infractions, la catégorie de gravité et expliquez comment réorganiser la semaine pour la rendre conforme.',
   '[]'::jsonb, '[]'::jsonb,
   'Analyse :

1. Total hebdomadaire : 9 + 10 + 9,5 + 9 + 10 = 47 h 30 → OK (sous 56 h).

2. Plafond quotidien : 9 h normal, 10 h × 2 maximum.
- Mardi 10 h = 1er dépassement → OK
- Mercredi 9 h 30 = INFRACTION → dépasse 9 h sans utiliser le 2e dépassement (qui doit être à 10 h, pas à 9 h 30)
- Vendredi 10 h = 2e dépassement → OK car les dépassements à 10 h sont autorisés 2 fois/semaine

L''infraction sur le mercredi (9 h 30 = 30 min de dépassement) est classée MI (Mineure), passible d''une amende de 90 à 750 €.

Réorganisation conforme :
- Lundi : 9 h
- Mardi : 10 h (1er dépassement)
- Mercredi : 9 h (limite normale)
- Jeudi : 9 h
- Vendredi : 10 h (2e dépassement)
Total : 47 h, deux dépassements autorisés bien tracés.

Mesure préventive : intégrer les 10 h dans la planification hebdomadaire dès le lundi, ne jamais les utiliser « à la surprise » en cours de semaine.',
   'difficile', '{cas-pratique,planification}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qr:2', 'qr',
   'Lors d''un contrôle DREAL, un inspecteur constate qu''un de vos conducteurs a pris son repos hebdomadaire régulier (45 h) en cabine sur le parking d''une aire de service en Italie. Quelles sont les conséquences pour le conducteur ET pour votre entreprise, et quelles mesures correctives mettre en place ?',
   '[]'::jsonb, '[]'::jsonb,
   'Conséquences :

1. Pour le conducteur : amende administrative de 500 € (sanction prévue au paquet mobilité). Cette amende peut lui être retenue sur salaire si l''entreprise l''a explicitement informé de la règle (pas par défaut).

2. Pour l''entreprise : amende administrative pouvant atteindre 30 000 € par cas constaté. En cas de récidive ou d''infractions multiples, risque d''atteinte à l''honorabilité et de retrait/suspension de la licence de transport.

3. Risque réputationnel : sanction publique dans les bases européennes ERRU (registre électronique des entreprises de transport routier).

Mesures correctives à présenter :

a. Formation immédiate de tous les conducteurs sur la règle (paquet mobilité août 2020).

b. Système de réservation d''hôtel intégré : partenariat avec une chaîne (Ibis, B&B, Hôtels routiers) pour assurer un hébergement à chaque coupure 45 h.

c. Plan de tournées révisé : intégrer dès la planification le lieu et le mode d''hébergement pour chaque coupure 45 h prévue.

d. Pièce justificative : facture d''hôtel ou attestation employeur jointe à chaque tournée internationale > 6 jours.

e. Sanction interne au conducteur (avertissement, voire mise à pied selon gravité).

f. Audit interne semestriel : croisement des données tachygraphes (45 h détecté) avec les justificatifs d''hébergement.',
   'difficile', '{paquet-mobilite,sanctions,plan-action}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qr:3', 'qr',
   'Vous gérez un conducteur qui doit livrer un fret urgent Paris → Bucarest (Roumanie) en 3 jours. Le trajet fait 2 200 km. Le conducteur seul. Décrivez la planification respectant la R561 et précisez les frontières AETR éventuellement traversées.',
   '[]'::jsonb, '[]'::jsonb,
   'Planification proposée :

1. Calcul base :
- 2 200 km à 65 km/h moyen = 33,8 h de conduite minimum
- Conduite max sur 3 jours : 9 + 10 + 9 = 28 h ou 10 + 9 + 10 = 29 h → INSUFFISANT en seul.
- Avec 4 jours : 10 + 9 + 10 + 9 = 38 h → faisable.

2. Conclusion : 3 jours en conducteur seul est INFAISABLE en respectant la R561. Deux options :
- Allonger le délai à 4 jours (J+3 départ → arrivée J+4)
- Mettre en place un double équipage (2 conducteurs) qui permet d''atteindre Bucarest en 30 h roulées non-stop (avec respect des temps individuels et un seul repos journalier en double).

3. Frontières et règlements :
- Paris → Frontière allemande (UE) : R561
- Allemagne, Autriche, Hongrie : R561 (tous UE)
- Hongrie → Roumanie : R561 (Roumanie UE depuis 2007)
- TOUT LE TRAJET : R561, pas d''AETR

4. Planning détaillé en équipage solo, J → J+3 :
- J0 : Paris (départ 6 h) → Strasbourg (450 km, 7 h conduite + pause 45 min) → Munich (350 km, 5 h conduite). Conduite : 8 h. Repos en hôtel.
- J1 : Munich → Vienne (450 km, 7 h conduite + pause) → Budapest (240 km, 4 h conduite). Conduite : 9 h (limite). Repos hôtel.
- J2 : Budapest → Cluj (430 km, 7 h conduite + pause) → Sibiu (180 km, 3 h conduite). Conduite : 10 h (1er dépassement). Repos hôtel.
- J3 : Sibiu → Bucarest (270 km, 4 h 30 conduite). Livraison J+3 vers 11 h.

5. Recommandations commerciales :
- Annoncer J+4 au client pour sécurité.
- Si vraiment urgent : facturer le surcoût d''un double équipage (+45 % du prix).
- Anticiper la réservation des 3 hébergements et la clause RPC (carburant Allemagne/Autriche).',
   'difficile', '{cas-pratique,international,planification}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qr:4', 'qr',
   'Expliquez la différence entre temps de conduite, temps de travail et temps de service. Pourquoi un planning « R561-conforme » peut-il quand même violer le Code du travail ?',
   '[]'::jsonb, '[]'::jsonb,
   'Distinction des trois notions :

1. Temps de CONDUITE (R561) : strictement le temps de mise en mouvement du véhicule. Mesuré par le tachygraphe.

2. Temps de TRAVAIL EFFECTIF (Code du travail / convention collective des transports) : conduite + autre travail (chargement, déchargement, formalités, entretien...). Exclut les pauses et la disponibilité simple.

3. Temps de SERVICE (amplitude / coupures) : durée totale entre la prise de service et la fin de service, incluant pauses et disponibilité.

Plafonds applicables :

| Notion | R561 | Code du travail / CCN TRM |
|---|---|---|
| Conduite quotidienne | 9 h (10 h × 2) | — |
| Conduite hebdo | 56 h | — |
| Travail hebdo | — | 48 h en moyenne sur 4 mois (D 3312-45) |
| Travail hebdo absolu | — | 60 h max une semaine isolée |
| Amplitude journalière | — | 14 h max (temps de service) |

Exemple concret de conflit :
Un conducteur peut faire 9 h de conduite + 4 h de chargement/déchargement + 1 h de pause = 14 h d''amplitude → R561 OK mais limite Code du travail.

Si en plus le total hebdomadaire (conduite + autre travail) dépasse 48 h en moyenne sur 4 mois, c''est une infraction Code du travail même si la conduite reste sous 56 h.

Implication pratique pour l''exploitant :
- Suivi DOUBLE : R561 par les fichiers tachygraphes ET temps de travail par les pointages/feuilles de route.
- Coordination paie/exploitation : les heures supplémentaires sont calculées sur le temps de travail, pas la conduite seule.
- Respect des conventions collectives (CCN Transports - IDCC 16) qui fixent durées, repos, pauses spécifiques au secteur.',
   'difficile', '{r561,code-travail,distinction}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qr:5', 'qr',
   'Un conducteur termine son repos hebdomadaire régulier (45 h) le dimanche à 22 h 00. Il commence la semaine suivante (lundi) à 5 h 00. Détaillez ses possibilités de conduite sur les 5 premiers jours, en intégrant un planning de tournées entre Lyon et Lille (650 km A/R).',
   '[]'::jsonb, '[]'::jsonb,
   'Planning proposé :

Repos terminé dimanche 22 h. Nouvelle semaine commence légalement immédiatement. Le repos suivant (journalier) doit intervenir avant que la « journée de travail » de 24 h ne s''achève.

Lundi (départ 5 h) :
- 5 h - 9 h 30 : conduite 4 h 30 (Lyon → Mâcon → Beaune)
- 9 h 30 - 10 h 15 : pause 45 min
- 10 h 15 - 14 h : conduite 3 h 45 (Beaune → Reims)
- 14 h - 15 h : déchargement (autre travail)
- 15 h - 16 h : conduite 1 h vers Lille
- 16 h - Mardi 3 h : repos journalier 11 h (en hôtel ou cabine OK)
- Total conduite Lundi : 4 h 30 + 3 h 45 + 1 h = 9 h 15... INFRACTION !

Correction (planning conforme) :
- 5 h - 9 h 30 : 4 h 30 conduite
- 9 h 30 - 10 h 15 : pause 45 min
- 10 h 15 - 13 h 45 : 3 h 30 conduite (Lyon → région Reims)
- 13 h 45 - 14 h 30 : pause 45 min
- 14 h 30 - 15 h 30 : 1 h conduite arrivée
- Total : 9 h, OK

Mardi (livraison Lille puis retour Lyon - 650 km cumulés) :
- 4 h - 8 h 30 : 4 h 30 conduite
- Pause 45 min
- 9 h 15 - 13 h 45 : 4 h 30 conduite
- Pause 45 min
- 14 h 30 - 15 h 30 : 1 h conduite
- Total : 10 h (1er dépassement)
- Repos 11 h

Mercredi à Vendredi : exploitations régionales 9 h chacun.

Cumul hebdo : 9 + 10 + 9 + 9 + 9 = 46 h → OK (sous 56 h).
Marge : 10 h pour absorber les imprévus.

Le conducteur prendra son prochain repos hebdomadaire vendredi soir à samedi soir (24 h réduit) ou vendredi soir à lundi 5 h (45 h régulier).',
   'difficile', '{planning,cas-pratique}'),

  (v_formation, 'mft-2026-gotrm:bc01-04:qr:6', 'qr',
   'Listez et expliquez les 5 principaux outils ou pratiques d''un service exploitation pour prévenir les infractions R561 dans une entreprise de 30 véhicules.',
   '[]'::jsonb, '[]'::jsonb,
   'Outils et pratiques recommandés :

1. Téléchargement automatisé des cartes et VU :
- Outil : clé physique (DLK Pro) ou télématique embarquée (FleetBoard, OPTAC, Frotcom).
- Fréquence : carte tous les 21 jours (sécurité), VU tous les 60 jours.
- Bénéfice : zéro perte de données, alertes automatiques.

2. Logiciel d''analyse des infractions :
- Outils : OPTAC3, Tachostore, Continental VDO Easy, Idem Plus.
- Fonction : détection automatique des dépassements, des pauses insuffisantes, des repos non conformes.
- Bénéfice : action corrective immédiate, traçabilité auprès de la DREAL.

3. Plannings prédictifs :
- Outils : TMS avec moteur R561 intégré (Dispatcher Pro, AlpegaTMS, PTV Map&Guide).
- Fonction : simulation préalable des tournées avec contrôle des temps et des points de pause/repos.
- Bénéfice : planning par construction conforme, optimisation de l''empreinte.

4. Briefings réguliers conducteurs :
- Fréquence : trimestrielle, ou ponctuelle après évolution réglementaire.
- Contenu : rappel des règles, retour sur les infractions constatées, formation continue.
- Bénéfice : conducteurs informés, responsabilisation, baisse des erreurs humaines.

5. Audit interne mensuel :
- Échantillonnage : 5 conducteurs sur 30 chaque mois (rotation).
- Vérification croisée : carte tachygraphe vs feuille de route vs paie vs réservations hôtel.
- Bénéfice : détection précoce des dérives, préparation aux contrôles DREAL.

Bonus : système d''alerte temps réel via télématique embarquée
- Le boîtier alerte le conducteur ET l''exploitant 30 min avant un dépassement potentiel.
- Permet une intervention en direct (replan, pause anticipée).
- Coût modéré (~15 €/mois/véhicule) compensé par les amendes évitées.',
   'moyenne', '{outils,prevention}');

  -- =================================================================
  -- QUIZZES (4 entraînement + 1 examen blanc)
  -- =================================================================
  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_1, 'Quiz — Cadre R561 et AETR', 'gotrm-bc01-04-quiz-01', 'Champ d''application, dérogations, vocabulaire (semaine, journée, période).', 70, NULL, false, 1)
  RETURNING id INTO v_quiz_1;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-04:qcm:1','mft-2026-gotrm:bc01-04:qcm:2','mft-2026-gotrm:bc01-04:qcm:23','mft-2026-gotrm:bc01-04:qcm:27','mft-2026-gotrm:bc01-04:qcm:28','mft-2026-gotrm:bc01-04:qcm:29');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_2, 'Quiz — Temps de conduite', 'gotrm-bc01-04-quiz-02', 'Plafonds quotidien, hebdo, bihebdo, double équipage.', 70, NULL, false, 2)
  RETURNING id INTO v_quiz_2;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-04:qcm:3','mft-2026-gotrm:bc01-04:qcm:4','mft-2026-gotrm:bc01-04:qcm:5','mft-2026-gotrm:bc01-04:qcm:21','mft-2026-gotrm:bc01-04:qcm:25');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_3, 'Quiz — Pauses et repos', 'gotrm-bc01-04-quiz-03', 'Pause 45 min, repos journalier 11h/9h, repos hebdo 45h/24h, retour domicile.', 70, NULL, false, 3)
  RETURNING id INTO v_quiz_3;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-04:qcm:6','mft-2026-gotrm:bc01-04:qcm:7','mft-2026-gotrm:bc01-04:qcm:8','mft-2026-gotrm:bc01-04:qcm:9','mft-2026-gotrm:bc01-04:qcm:10','mft-2026-gotrm:bc01-04:qcm:11','mft-2026-gotrm:bc01-04:qcm:12','mft-2026-gotrm:bc01-04:qcm:13','mft-2026-gotrm:bc01-04:qcm:14','mft-2026-gotrm:bc01-04:qcm:26');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_4, 'Quiz — Tachygraphe et contrôles', 'gotrm-bc01-04-quiz-04', 'Smart tachygraphe, cartes, téléchargements, contrôles, sanctions.', 70, NULL, false, 4)
  RETURNING id INTO v_quiz_4;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-04:qcm:15','mft-2026-gotrm:bc01-04:qcm:16','mft-2026-gotrm:bc01-04:qcm:17','mft-2026-gotrm:bc01-04:qcm:18','mft-2026-gotrm:bc01-04:qcm:19','mft-2026-gotrm:bc01-04:qcm:20','mft-2026-gotrm:bc01-04:qcm:22','mft-2026-gotrm:bc01-04:qcm:24','mft-2026-gotrm:bc01-04:qcm:30');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, NULL, 'Examen blanc — BC01-04 R561 et AETR', 'gotrm-bc01-04-examen-blanc', '15 QCM en 30 min, seuil 50 %. Synthèse du module.', 50, 30, true, 5)
  RETURNING id INTO v_quiz_eb;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-04:qcm:1','mft-2026-gotrm:bc01-04:qcm:3','mft-2026-gotrm:bc01-04:qcm:4','mft-2026-gotrm:bc01-04:qcm:5','mft-2026-gotrm:bc01-04:qcm:6','mft-2026-gotrm:bc01-04:qcm:8','mft-2026-gotrm:bc01-04:qcm:10','mft-2026-gotrm:bc01-04:qcm:11','mft-2026-gotrm:bc01-04:qcm:13','mft-2026-gotrm:bc01-04:qcm:16','mft-2026-gotrm:bc01-04:qcm:17','mft-2026-gotrm:bc01-04:qcm:19','mft-2026-gotrm:bc01-04:qcm:21','mft-2026-gotrm:bc01-04:qcm:22','mft-2026-gotrm:bc01-04:qcm:29');

  RAISE NOTICE '✅ GOTRM BC01-04 v2 chargé : 4 leçons, 30 QCM, 6 QR, 5 quizzes (4 entraînement + 1 examen blanc).';
END
$bc01_04$;
