-- =====================================================================
-- GOTRM (RNCP 40990) — BC01-04 · Réglementation sociale européenne
-- Version 3 (mai 2026) — REFONTE PÉDAGOGIQUE PREMIUM v3_dense
--
-- Bloc 01 : Concevoir, organiser et piloter des opérations de transport.
-- Module 4 : Règlement (CE) 561/2006 et accord AETR — temps de conduite,
-- pauses, repos, chronotachygraphe, contrôles et sanctions.
--
-- Référentiel RNCP 40990 — compétence visée :
--   « Garantir le respect de la réglementation sociale européenne dans la
--   planification et l'exécution des opérations de transport routier. »
--
-- ▸ 4 leçons (240 min total)
--   1. Cadre juridique : R561/2006, AETR, articulation (60 min)
--   2. Temps de conduite, pauses, repos quotidien (60 min)
--   3. Repos hebdomadaires, semaine de référence, dérogations (60 min)
--   4. Chronotachygraphe, contrôles, infractions et sanctions (60 min)
--
-- Idempotent. Pré-requis : formation 'gotrm' présente.
-- =====================================================================

DO $bc01_04_v3$
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

  -- ─── Remplacement complet (idempotent v2 + v3) ─────────────
  DELETE FROM public.modules WHERE slug IN (
    'gotrm-bc01-04-temps-conduite-r561',
    'gotrm-bc01-04-temps-conduite-r561-v3'
  );

  -- Nettoyage banque liée
  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND (source_ref LIKE 'mft-2026-gotrm:bc01-04:%'
       OR source_ref LIKE 'mft-2026-gotrm:bc01-04-v3:%');

  INSERT INTO public.modules (
    title, slug, bloc_id, summary, difficulty, duration_min, "order"
  ) VALUES (
    'BC01-04 — Réglementation sociale européenne : R561/2006 et AETR',
    'gotrm-bc01-04-temps-conduite-r561',
    v_bloc,
    'Maîtriser le règlement (CE) 561/2006 et l''accord AETR : champ d''application, temps de conduite (4h30/9h/56h/90h), pauses obligatoires, repos quotidien (11h/9h) et hebdomadaire (45h/24h), compensation, chronotachygraphe (numérique et intelligent 2e gén), contrôles routiers et entreprise, classification des infractions et sanctions.',
    'avance',
    240,
    40
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 40, true) ON CONFLICT DO NOTHING;

  -- =================================================================
  -- LEÇON 1 — Cadre juridique : R561/2006, AETR, champ d'application
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Cadre juridique : R561/2006, AETR et champ d''application',
    'cadre-r561-aetr-champ-application',
    1, 60,
$lessonG1$
# Cadre juridique : R561/2006, AETR et champ d'application

> 🎯 **Objectifs pédagogiques**
>
> À la fin de cette leçon, vous serez capable de :
>
> - **Identifier** les textes européens et internationaux qui régissent le temps de conduite.
> - **Délimiter** le champ d'application du règlement (CE) 561/2006.
> - **Distinguer** R561, AETR, Code des transports français et CCN Transport.
> - **Désigner** les acteurs du contrôle (DREAL, gendarmerie, Inspection du travail).
> - **Choisir** la bonne réglementation selon l'itinéraire (UE / hors UE).

---

## Introduction

La réglementation sociale européenne du transport routier est l'un des **piliers RNCP** que tout gestionnaire d'opérations doit maîtriser. **44 % des contrôles DREAL** portent sur les temps de conduite, et **28 % des entreprises de transport** ont au moins une infraction sérieuse par an dans ce domaine.

Le règlement (CE) **n° 561/2006 du 15 mars 2006** est le **texte de référence** pour les transports effectués au sein de l'Union européenne. Il a remplacé l'ancien règlement 3820/85 et harmonisé les règles entre les 27 États membres. Pour les transports **hors UE**, c'est l'**AETR** (Accord Européen sur les Transports Routiers) qui s'applique.

Cette leçon vous donne la **carte du paysage juridique** : quel texte appliquer, à qui, quand, et avec quelles conséquences. C'est le socle de toute la planification opérationnelle.

---

## 1. Le règlement (CE) n° 561/2006

### 1.1 Identité du texte

- **Nom complet** : Règlement (CE) n° 561/2006 du Parlement européen et du Conseil du 15 mars 2006 relatif à l'harmonisation de certaines dispositions de la législation sociale dans le domaine des transports par route.
- **Publication** : JOUE L 102 du 11 avril 2006.
- **Entrée en vigueur** : 11 avril 2007 (application générale).
- **Modifications majeures** : Paquet Mobilité I (règlement 2020/1054 du 15 juillet 2020) — durci sur les retours hebdomadaires, repos hebdo dans le véhicule, etc.

### 1.2 Articles structurants

| Article | Sujet |
|---|---|
| Art. 2 | Champ d'application (véhicules concernés et exclusions) |
| Art. 3 | Exclusions absolues (auto-école, secours, militaires...) |
| Art. 4 | Définitions (temps de conduite, repos, pause, etc.) |
| Art. 5 | Âge minimum du conducteur |
| Art. 6 | Durée maximale de conduite quotidienne / hebdo / bi-hebdo |
| Art. 7 | Pauses |
| Art. 8 | Repos quotidiens et hebdomadaires |
| Art. 9 | Travail en équipage |
| Art. 10 | Responsabilité de l'entreprise |
| Art. 11 | Dérogations exceptionnelles |
| Art. 12 | Article « urgence » (en cas de circonstances exceptionnelles) |

### 1.3 Champ d'application — qui est concerné ?

Le R561/2006 s'applique aux véhicules effectuant un **transport par route** :

| Catégorie | Critère | Concernés ? |
|---|---|---|
| Marchandises | PTAC > 3,5 t (avec ou sans remorque) | **OUI** |
| Voyageurs | + de 9 places (conducteur compris) | **OUI** |
| Voyageurs | ≤ 9 places (taxi, VTC, mini-bus 8 places) | NON |
| Marchandises | PTAC ≤ 3,5 t (VUL) | NON sauf cabotage international depuis 1/7/2026 |
| Pour autrui ou compte propre | indifféremment | OUI dans les deux cas |

> ⚠️ **Évolution Paquet Mobilité I** : depuis le 1er juillet 2026, les **VUL > 2,5 t** effectuant un transport international ou cabotage sont **soumis au R561** (équivalent transport lourd). Vérifier la date d'entrée en vigueur effective sur votre secteur.

### 1.4 Exclusions du R561 (article 3)

Sont **exclus** du règlement :
1. Véhicules d'**auto-école** (formation des futurs conducteurs).
2. Véhicules à usage **militaire**, **protection civile**, **services de secours** d'urgence.
3. Véhicules d'entretien des **routes** et de gestion des eaux usées (services publics).
4. Véhicules effectuant des **services réguliers** de transport voyageurs sur trajet ≤ 50 km.
5. Véhicules de **collecte de lait** ou de denrées (transport agricole local).
6. Véhicules-écoles utilisés dans le cadre d'un permis poids lourd.
7. Véhicules **historiques** de plus de 25 ans, ne servant pas à un transport rémunéré.

⚠️ **Piège** : ces exclusions sont **strictes** et **limitatives**. Une PME qui croit que son camion de chantier est « entretien des routes » sera redressée si elle ne fait pas un service public — il faut une convention DDT/DREAL.

---

## 2. L'accord AETR

### 2.1 Définition

L'**AETR** (Accord Européen sur les Transports Routiers) du 1er juillet 1970 est un accord international **antérieur au R561**. Il s'applique aux transports effectués **entre un pays de l'UE et un pays signataire hors UE**, ou entièrement hors UE.

### 2.2 Pays signataires (au-delà de l'UE)

| Région | Pays signataires AETR |
|---|---|
| Europe orientale | Russie, Ukraine, Biélorussie, Moldavie, Géorgie, Arménie |
| Caucase / Asie | Kazakhstan, Ouzbékistan, Azerbaïdjan, Turkménistan |
| Europe / Balkans | Bosnie, Serbie, Macédoine du Nord, Albanie, Monténégro |
| Méditerranée / MENA | Maroc, Tunisie, Turquie, Andorre, Liechtenstein, Saint-Marin |
| Royaume-Uni | depuis Brexit, le Royaume-Uni applique aussi l'AETR pour ses transports internationaux |

### 2.3 Différences clés AETR vs R561

| Point | R561/2006 | AETR |
|---|---|---|
| Champ géographique | Transport au sein UE | Hors UE ou mixte |
| Pause obligatoire | 45 min après 4h30 | 45 min après 4h30 (identique) |
| Repos quotidien | 11h / 9h réduit | 11h / 9h réduit (identique) |
| Repos hebdo normal | 45h | 45h (identique) |
| Repos hebdo réduit | 24h + compensation | 24h + compensation (identique) |
| Outils de contrôle | chronotachygraphe numérique / intelligent | idem |
| Sanctions | code transports français + barème EU | code de chaque pays signataire |

> 💡 **À retenir** : sur le **fond des règles**, AETR et R561 sont **quasi identiques** depuis l'harmonisation de 2010. Mais l'**autorité de contrôle**, la **monnaie de l'amende** et la **procédure de sanction** changent selon le pays. Un conducteur Paris-Moscou doit appliquer le R561 jusqu'à la frontière Pologne-Biélorussie, puis l'AETR ensuite.

### 2.4 Cas concret d'articulation

**Exemple** : Trajet Paris → Tunis, en passant par Lyon, Marseille (ferry), Tunis.

:::flow
1. Paris → Lyon → Marseille | R561 (intra-UE)
2. Embarquement ferry Marseille | période hors conduite décomptée comme repos
3. Tunis débarquement → arrivée Tunis | AETR (Tunisie signataire)
4. Retour avec ferry | reprise R561 dès débarquement Marseille
:::

**Règle pratique** : la transition AETR ↔ R561 se fait au **passage de frontière** ou à la **fin du transport maritime** entre deux pays.

---

## 3. Articulation avec le droit français

### 3.1 La pyramide des sources

:::flow
1. Règlement (CE) 561/2006 | application directe, prime sur le droit national
2. Accord AETR | application directe pour pays signataires hors UE
3. Code des transports français | art. L. 3312-1 et suivants (transposition / sanction)
4. Décret 2003-1242 du 22 décembre 2003 | mesures d'application
5. CCN Transport routier marchandises (IDCC 16) | dispositions plus favorables (durée du travail, pauses)
6. Convention d'entreprise / accord d'établissement | si plus favorable
:::

### 3.2 Règle de non-régression

⚠️ **Article 14 R561** : les États membres ne peuvent **pas adopter de mesures moins favorables** que le règlement. Mais ils peuvent **adopter des mesures plus favorables aux conducteurs** (repos plus long, pause plus fréquente).

C'est ce qu'a fait la France avec la **CCN Transport routier marchandises (IDCC 16)** : la pause repas est obligatoirement payée après 6 heures d'amplitude, au-delà du R561.

### 3.3 Différence durée du travail vs temps de conduite

**Distinction critique** à connaître pour l'examen :

| Notion | Texte | Plafond |
|---|---|---|
| **Temps de conduite** | R561 art. 6 | 9h/jour, 56h/semaine, 90h/2 sem. |
| **Durée du travail** (conduite + autres tâches) | Code du travail + CCN | 48h/sem max (moyenne 12 sem.) |
| **Amplitude** | CCN IDCC 16 art. 5 | 12h grands routiers, 14h dérogation |

Un conducteur peut faire **9h de conduite** + **2h de chargement** = **11h de durée du travail**. Le R561 contrôle la conduite, le Code du travail contrôle l'ensemble.

---

## 4. Les acteurs du contrôle

### 4.1 Contrôle routier (en circulation)

| Autorité | Rôle | Compétence |
|---|---|---|
| **Gendarmerie nationale** | Contrôles ponctuels et coordonnés | Toutes infractions, PV par OPJ |
| **Police nationale** | Zones urbaines, autoroutes en agglo | Idem gendarmerie |
| **Contrôleurs routiers DREAL** | Spécialisés transport | R561, ADR, surcharge, RSE |
| **Douanes** | Frontières, contrôles aléatoires | Cabotage, contrebande, ADR |

### 4.2 Contrôle entreprise

| Autorité | Rôle | Périmètre |
|---|---|---|
| **DREAL — service contrôle** | Audit des disques et tachy en entreprise | Vérifie 6 mois minimum |
| **Inspection du travail** | Durée du travail, paie, repos | Code du travail + CCN |
| **URSSAF** | Cotisations sociales associées | Cotisations + heures sup |
| **Autorité de la concurrence** | Pratiques anticoncurrentielles | Cabotage abusif |

### 4.3 Procédure de contrôle DREAL en entreprise

1. **Notification** : 2 à 4 semaines avant la visite (sauf inopiné).
2. **Présentation** des documents : carte conducteur, mémoire véhicule, planning, fiches de paie.
3. **Échantillonnage** : minimum 6 mois d'activité, jusqu'à 3 ans pour récidive.
4. **Constat** : procès-verbal d'infractions remis sur place ou notifié 2 semaines plus tard.
5. **Procédure contradictoire** : 2 mois pour répondre + audition.
6. **Sanction** : amende administrative + transmission éventuelle au Procureur si infraction pénale.

> 💡 **Astuce pro** : tenir un **registre des contrôles** dans l'entreprise (date, autorité, périmètre, suite donnée). En cas de redressement, prouver l'effort de mise en conformité réduit les amendes de 30 à 50 %.

---

## 5. Cas pratique chiffré : Paris → Tunis

**Énoncé** : Un VUL de **3,8 t** part de Paris pour livrer du matériel à Rome, puis embarque sur un ferry pour Tunis afin d'y décharger un autre lot. Le trajet est :
- Paris → Rome : 1 500 km, conducteur unique.
- Rome → Tunis (ferry compris) : 850 km routiers + 24h ferry.
- Tunis → Sfax : 270 km supplémentaires.

**Question** : Quelle réglementation s'applique sur chaque tronçon ? Quel chronotachygraphe ?

**Correction tronçon par tronçon** :

| Tronçon | Réglementation | Justification |
|---|---|---|
| Paris → Rome | **R561/2006** | Transport intra-UE (France-Italie), véhicule > 3,5 t |
| Rome (port) → embarquement | R561 | Encore sur le territoire UE |
| Ferry Italie-Tunisie | Repos | Le temps en cabine est décompté comme repos quotidien |
| Tunis → Sfax | **AETR** | Tunisie signataire AETR, hors UE |
| Retour Tunis → Rome | AETR | Idem |
| Retour Rome → Paris | R561 | Reprise UE |

**Outils de contrôle** : le véhicule embarque un **chronotachygraphe numérique intelligent (2e génération)** depuis 2019, qui reconnaît automatiquement le passage de frontière et l'inscrit en mémoire.

---

## 6. Les évolutions du Paquet Mobilité I

### 6.1 Mesures introduites

Le **règlement (UE) 2020/1054 du 15 juillet 2020** (Paquet Mobilité I) a modifié le R561 sur 6 points :

1. **Retour hebdomadaire au domicile** : obligation pour l'employeur d'organiser le retour du conducteur **toutes les 4 semaines maximum** (3 si repos hebdo réduit).
2. **Interdiction du repos hebdo normal en cabine** : depuis 21 août 2020, le repos de 45h DOIT se prendre **hors du véhicule** (hôtel, domicile, hébergement adapté), payé par l'employeur.
3. **Tachygraphe intelligent 2e génération** : déploiement obligatoire 2023-2026 pour tous les véhicules concernés.
4. **VUL > 2,5 t en transport international** : assujettis au R561 depuis 1/7/2026 (date sous réserve).
5. **Détachement des conducteurs** : règles renforcées sur le cabotage (max 3 opérations en 7 jours).
6. **Dérogations spécifiques** : trajets transbordés (ferry/train) jusqu'à 24h compatibles avec repos.

### 6.2 Conséquences pratiques

- **Coût hôtel** : 60 à 90 € par nuit en moyenne, à intégrer dans le coût de revient kilométrique.
- **Planification trajets** : besoin de **points de retour** programmés en exploitation.
- **Sanction non-respect** : amende **750 à 1 500 €** par infraction (employeur).

---

## 7. Mini-exercice à faire seul

**Énoncé** : Une PME exploite 3 véhicules :
- Véhicule A : VUL 3,2 t, transports nationaux uniquement.
- Véhicule B : Porteur 12 t, transport intra-UE (FR-DE-NL).
- Véhicule C : Semi 40 t, transport vers Russie (Moscou).

**Questions** :
1. Lesquels sont soumis au R561 ?
2. Lesquels sont soumis à l'AETR ?
3. Quel chronotachygraphe pour chacun ?
4. Que change le Paquet Mobilité I pour véhicule A à partir de 2026 ?

> 💡 Réponses en fin de module (corrections § 4).

---

## 8. Glossaire

- **R561/2006** : règlement européen du 15 mars 2006 sur les temps de conduite UE.
- **AETR** : Accord Européen sur les Transports Routiers (1970, hors UE).
- **Paquet Mobilité I** : règlement UE 2020/1054, durcissement des règles depuis 2020.
- **DREAL** : Direction régionale de l'environnement, de l'aménagement et du logement.
- **Chronotachygraphe** : appareil enregistreur des temps de conduite et de repos.
- **CCN IDCC 16** : Convention collective nationale du transport routier de marchandises.
- **VUL** : Véhicule utilitaire léger (≤ 3,5 t PTAC).
- **PTAC** : Poids total autorisé en charge.
- **Cabotage** : transport effectué dans un État autre que celui d'immatriculation.

---

## 9. Synthèse opérationnelle

1. **R561/2006** = règlement européen, transport intra-UE, marchandises > 3,5 t et autocars > 9 places.
2. **AETR** = règle équivalente pour transport hors UE (Russie, Maroc, Tunisie...).
3. **Articulation** : R561 prime sur droit national, mais le droit national peut être plus favorable.
4. **CCN IDCC 16** prévoit des règles plus favorables (durée travail, pause).
5. **Contrôles** : DREAL (entreprise et routier), gendarmerie/police (routier), Inspection travail (durée travail).
6. **Paquet Mobilité I** (2020) : retour 4 semaines, interdiction repos 45h cabine, tachy intelligent.
7. **Articles clés R561** : art. 6 (conduite), art. 7 (pauses), art. 8 (repos), art. 12 (urgence).
8. **VUL > 2,5 t en international** = R561 à partir de 1/7/2026.

---

## ⚠️ Points de vigilance

- **Ne pas confondre** R561 (temps de conduite) et Code du travail (durée du travail). Les deux s'appliquent simultanément.
- **Vérifier le statut juridique** des exclusions : un camion de chantier n'est PAS automatiquement exclu, il faut une convention DDT/DREAL.
- **AETR ≠ exotique** : Russie, Turquie, Maroc, UK = AETR. Beaucoup de PME oublient l'UK depuis le Brexit.
- **VUL 2,5-3,5 t** : transition réglementaire 2026, à anticiper dès maintenant.

## 💡 Astuces pro

- **Outil terrain** : application *Continental VDO Tisplus* ou *Inelo TachoScan* pour analyser automatiquement les disques et anticiper les infractions.
- **Veille réglementaire** : abonnement à la lettre **FNTR** (Fédération Nationale des Transports Routiers) — alertes mensuelles sur les modifications.
- **Tableau de bord** : créer un fichier Excel par conducteur avec colonnes (jour, conduite, repos, infractions). Couleur rouge si > seuil. Coût 0 €, gain en sérénité.

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : différence R561/AETR ; champ d'application (3,5 t, 9 places) ; articles structurants ; exclusions.
- **QR cas pratique** : « Sur ce trajet Paris-Moscou, quelles règles s'appliquent à chaque tronçon ? »
- **Oral DP** : « Comment intégrez-vous le Paquet Mobilité I dans la planification de vos tournées internationales ? »

---

## 📌 Synthèse à retenir

### R561/2006 vs AETR

| Critère | R561/2006 | AETR |
|---|---|---|
| Géographie | UE 27 | Hors UE ou mixte |
| Transport > 3,5 t | OUI | OUI |
| Autocars > 9 places | OUI | OUI |
| Tachygraphe numérique | OUI | OUI |
| Contrôles | DREAL, gendarmerie | autorité de chaque pays |

### Hiérarchie des sources

**Règlement (CE) 561/2006** → **AETR** (hors UE) → **Code transports français** → **CCN IDCC 16** → **Accord d'entreprise**

> 📌 **Les 3 articles à retenir par cœur**
>
> - **Art. 6** : durée maximale de conduite (9h/56h/90h)
> - **Art. 7** : pauses (45 min après 4h30)
> - **Art. 8** : repos quotidiens (11h/9h) et hebdomadaires (45h/24h)

### Paquet Mobilité I (juillet 2020)

- **Retour 4 semaines** au domicile obligatoire
- **Repos hebdo 45h** hors cabine (hôtel ou domicile)
- **Tachy intelligent 2e gén** déployé 2023-2026
- **VUL > 2,5 t international** au R561 depuis 1/7/2026

> ⚠️ **Les 4 acteurs du contrôle**
>
> - **DREAL** : contrôles routiers spécialisés et audits entreprise
> - **Gendarmerie / Police** : contrôles routiers généralistes
> - **Inspection du travail** : durée du travail et paie
> - **Douanes** : frontières et cabotage
$lessonG1$,
'Identifier le règlement (CE) 561/2006 (transport intra-UE) et l''accord AETR (hors UE), maîtriser leur champ d''application (> 3,5 t marchandises, > 9 places voyageurs), articuler avec le Code des transports et la CCN IDCC 16, connaître les acteurs du contrôle (DREAL, gendarmerie, Inspection du travail) et les évolutions du Paquet Mobilité I (retour 4 semaines, repos hebdo hors cabine, tachy intelligent).'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Temps de conduite, pauses, repos quotidien
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Temps de conduite, pauses et repos quotidien',
    'temps-conduite-pauses-repos-quotidien',
    2, 60,
$lessonG2$
# Temps de conduite, pauses et repos quotidien

> 🎯 **Objectifs pédagogiques**
>
> - **Maîtriser** les durées maximales de conduite (4h30, 9h, 10h, 56h, 90h).
> - **Calculer** les pauses obligatoires et leur fractionnement.
> - **Distinguer** repos quotidien normal (11h), réduit (9h) et fractionné (3h+9h).
> - **Construire** une journée type légale d'un conducteur longue distance.
> - **Détecter** les infractions et anticiper les dérogations possibles.

---

## Introduction

C'est **LE chapitre central** de la réglementation sociale européenne. **80 % des questions d'examen** RNCP portent sur les chiffres : 4h30, 9h, 10h, 11h, 45 min, 56h, 90h.

Une mauvaise lecture des plafonds = une infraction sérieuse = **750 à 1 500 €** d'amende **par jour** pour le conducteur ET pour l'entreprise (art. 10 R561 — responsabilité solidaire). Multiplié par 12 conducteurs sur 6 mois, c'est rapidement **50 000 €** de redressement DREAL.

Cette leçon vous arme avec les chiffres exacts (référence article par article), les exceptions, et **3 cas pratiques chiffrés** réels que les contrôleurs DREAL utilisent pour piéger.

---

## 1. La conduite continue et la pause obligatoire (art. 7 R561)

### 1.1 Règle de base : 4h30 → 45 min

> **Article 7 R561** : « Après une période de conduite de quatre heures et demie, le conducteur observe une pause ininterrompue d'au moins quarante-cinq minutes. »

**Mécanique** :
1. Démarrage du moteur, conducteur enclenché en mode « conduite ».
2. Cumul du temps de conduite réel.
3. Au plus tard à **4 h 30** de conduite cumulée, **arrêt obligatoire** + **pause 45 min minimum**.
4. Reprise possible avec un nouveau cycle de 4h30.

⚠️ **Erreur classique** : « 4h30 » signifie **temps de conduite réelle**, pas amplitude. Si le conducteur attend 30 min à un quai, ces 30 min ne comptent pas dans les 4h30.

### 1.2 Fractionnement de la pause (15 min + 30 min)

La pause peut être **fractionnée en 2 morceaux** mais avec règles strictes :
- **1ère partie** : minimum **15 minutes**.
- **2e partie** : minimum **30 minutes**.
- **Ordre** : la 15 min DOIT être prise **avant** la 30 min (pas l'inverse).
- **Total cumulé** dans la fenêtre 4h30 : **≥ 45 min**.

> 💡 **Astuce pro** : un fractionnement 15+30 permet d'optimiser un chargement quai. Pause 15 min en sortie d'entrepôt, puis 30 min en aire de repos après 2h supplémentaires.

### 1.3 Tableau récapitulatif pause

| Configuration | Légal ? | Cas d'usage |
|---|---|---|
| 1 pause unique de 45 min | OUI | Standard, en aire de repos |
| 15 min + 30 min (dans cet ordre) | OUI | Optimisation chargement |
| 30 min + 15 min | NON | Inversion interdite |
| 20 min + 25 min | NON | 1ère pause < 15 min |
| 10 min + 10 min + 25 min | NON | 3 fractions interdites |
| 45 min après 5h de conduite | NON (sauf force majeure) | Dépassement 4h30 |

### 1.4 Cas pratique

**Énoncé** : Un conducteur démarre à 6h00 de Paris pour Toulouse. Il roule 3h, fait 15 min de pause à 9h00, puis reprend la route. Il s'arrête à 12h00 (3h supplémentaires) pour 30 min. À quelle heure peut-il repartir et combien de temps peut-il rouler ?

**Correction** :
- 6h00 - 9h00 : 3h de conduite.
- 9h00 - 9h15 : pause 15 min.
- 9h15 - 12h00 : 2h45 de conduite. **Total cumulé** depuis le matin = 5h45. **Mais** dans la fenêtre depuis le démarrage de la dernière pause complète (45 min cumulés), le compteur est de 5h45 - 0 = 5h45 ⇒ **dépassement de 1h15**.
- En réalité, le conducteur aurait dû s'arrêter au plus tard à **9h15 + 4h30 = 13h45** uniquement si la pause 15 min était comptée comme « partielle ». En vérité, la pause complète n'étant pas terminée (il manque 30 min), le conducteur reste en cycle 4h30 depuis 6h00.
- **Bonne pratique** : pause 30 min à 12h00 = pause complète (15 + 30 = 45 cumulés). À partir de 12h30, nouveau cycle 4h30. Reprise à 12h30, conduite jusqu'à **17h00 maxi**.

---

## 2. La conduite quotidienne (art. 6.1 R561)

### 2.1 Plafond de base : 9 heures

> **Article 6.1 R561** : « La durée de conduite journalière ne dépasse pas neuf heures. »

**Définition d'une journée** : période entre deux repos quotidiens. Un conducteur peut donc **commencer une journée le mardi matin** et la **terminer le mercredi matin** (après son repos de 11h), avec une conduite cumulée plafonnée à 9h.

### 2.2 Extension à 10 heures (2 fois par semaine)

> **Article 6.1 R561 alinéa 2** : « La durée de conduite journalière peut être prolongée jusqu'à dix heures, mais pas plus de deux fois au cours de la semaine. »

**Règle stricte** : la « semaine » correspond à la **semaine de référence** (lundi 0h00 → dimanche 23h59). Le compteur **se réinitialise chaque lundi** à 0h.

⚠️ **Piège** : un conducteur qui fait 10h le **dimanche** + 10h le **lundi** + 10h le **mardi** = **3 dépassements en 3 jours**, mais répartis sur 2 semaines de référence (1 dimanche + 2 lundi/mardi). Donc **conforme** au regard du R561.

### 2.3 Conduite hebdomadaire (art. 6.2)

> **Article 6.2 R561** : « La durée de conduite hebdomadaire ne dépasse pas cinquante-six heures. »

**Plafond hebdomadaire** : **56 heures** entre lundi 0h et dimanche 23h59.

### 2.4 Conduite bi-hebdomadaire (art. 6.3)

> **Article 6.3 R561** : « La durée totale de conduite ne peut dépasser quatre-vingt-dix heures sur deux semaines consécutives. »

**Plafond bi-hebdo** : **90 heures** sur deux semaines consécutives (S1 + S2).

⚠️ **Conséquence** : si le conducteur fait **56h en S1**, il ne peut plus faire que **34h en S2** (90 - 56 = 34). Cette règle limite implicitement les semaines à très haute charge consécutives.

### 2.5 Tableau récapitulatif des durées

| Période | Plafond | Exception |
|---|---|---|
| Conduite continue | **4h30** | Pause 45 min obligatoire ensuite |
| Conduite quotidienne | **9h** | Extension 10h **2 fois/semaine** |
| Conduite hebdomadaire (lundi-dimanche) | **56h** | Aucune extension |
| Conduite bi-hebdomadaire (2 sem.) | **90h** | Aucune extension |

---

## 3. Le repos quotidien (art. 8.2 et 8.4 R561)

### 3.1 Repos quotidien normal : 11 heures

> **Article 8.2 R561** : « Au cours de chaque période de vingt-quatre heures suivant la fin du repos journalier ou hebdomadaire précédent, le conducteur a pris un nouveau repos journalier. »

**Règle** : repos quotidien = **11 heures consécutives** au minimum dans toute fenêtre de 24h.

**Mécanique de la fenêtre 24h** :
- Fin du repos précédent à 6h00 lundi → fenêtre 24h court jusqu'à 6h00 mardi.
- Le nouveau repos de 11h doit avoir débuté **avant 19h00 le lundi** (24 - 11 - 4h30 si pas reprise, sinon plus tôt).

### 3.2 Repos quotidien réduit : 9 heures (max 3x/semaine)

> **Article 8.4 R561** : « Le repos journalier peut être réduit à neuf heures consécutives, mais cette réduction ne peut être effectuée plus de trois fois entre deux repos hebdomadaires. »

**Règle** : repos réduit **9 heures** consécutives, **maximum 3 fois entre 2 repos hebdomadaires**.

⚠️ **Pas de compensation** : contrairement au repos hebdomadaire réduit, le repos quotidien réduit **ne nécessite pas de compensation**. C'est un avantage pour le conducteur, mais limité dans la fréquence.

### 3.3 Repos fractionné (3h + 9h)

Le repos quotidien peut être **fractionné en 2 morceaux** :
- **1ère partie** : minimum **3 heures** consécutives.
- **2e partie** : minimum **9 heures** consécutives.
- **Total** : ≥ **12 heures** (et non 11h !).

**Pourquoi 12h ?** Le R561 « pénalise » le fractionnement en imposant une heure de plus, pour décourager cette pratique.

### 3.4 Tableau des repos quotidiens

| Configuration | Durée | Fréquence max |
|---|---|---|
| Repos normal | **11h** consécutives | Standard |
| Repos réduit | **9h** consécutives | 3x entre 2 repos hebdo |
| Repos fractionné | **3h + 9h** = 12h | Pas de limite |
| Repos en équipage (cf. leçon 3) | **9h** consécutives sur 30h | Spécifique 2 conducteurs |

### 3.5 Cas pratique

**Énoncé** : Un conducteur termine son repos lundi 5h00. Mardi 5h00 il a déjà conduit 9h, mais il doit livrer encore à 200 km, soit 2h30 de conduite supplémentaire. Que faire ?

**Correction** :
- Conduite totale lundi : 9h ⇒ déjà au plafond quotidien.
- Pour ajouter 2h30, il faut **déclencher l'extension à 10h** (max 2x/semaine). Il roulera donc encore **1h** (de 9h00 à 10h00 cumulé) et devra s'arrêter.
- Il reste 1h30 de route. **Solution opérationnelle** : prendre un repos de 11h, puis reprendre le mercredi.
- **Alternative non conforme** : continuer 2h30 de plus = **infraction très sérieuse** (dépassement > 50 % du plafond), amende **1 500 €** conducteur + **1 500 €** entreprise.

---

## 4. La journée type d'un conducteur longue distance

:::timeline
1. **05h30** | Prise de service · vérifications véhicule · départ
2. **06h00 - 10h30** | Conduite continue 4h30 (plafond légal)
3. **10h30 - 11h15** | Pause obligatoire 45 minutes
4. **11h15 - 14h00** | Conduite 2h45 (cumulé 7h15 dans la journée)
5. **14h00 - 15h00** | Pause repas 1h (CCN IDCC 16) · Reprise nouveau cycle
6. **15h00 - 16h45** | Conduite 1h45 (cumulé 9h00 = plafond quotidien)
7. **16h45 - 18h00** | Tâches annexes : déchargement · paperasse · lavage
8. **18h00** | Fin de service (durée du travail = 12h30 amplitude)
9. **18h00 - 05h00 (J+1)** | Repos quotidien 11h consécutives
10. **05h00 (J+1)** | Reprise possible · nouveau cycle 9h conduite
:::

**Lecture** : la journée type légale = **9h conduite** (10h max 2x/sem) + **45 min pause** + **autres tâches** dans la limite de 12h amplitude (CCN). Repos 11h obligatoire avant nouvelle journée.

---

## 5. Cas pratique chiffré : Paris-Toulouse en une journée

**Énoncé** : Un conducteur doit livrer 18 palettes de Paris à Toulouse (680 km, 8h de conduite estimée), avec chargement Paris (1h) et déchargement Toulouse (2h). Vous planifiez la journée :
- 5h00 : prise de service à Paris
- 5h30 - 6h30 : chargement Paris (1h)
- 6h30 - ? : trajet
- arrivée Toulouse + déchargement 2h

**Question** : Décomposez la journée légale et indiquez l'heure d'arrivée à Toulouse.

**Correction décomposée** :

| Heure | Action | Cumul conduite | Cumul amplitude |
|---|---|---|---|
| 5h00 - 5h30 | Prise de service | 0h | 0h30 |
| 5h30 - 6h30 | Chargement (autre travail) | 0h | 1h30 |
| 6h30 - 11h00 | Conduite 4h30 (plafond continue) | 4h30 | 6h00 |
| 11h00 - 11h45 | **Pause obligatoire 45 min** | 4h30 | 6h45 |
| 11h45 - 14h45 | Conduite 3h | 7h30 | 9h45 |
| 14h45 - 15h45 | Pause repas 1h (CCN) | 7h30 | 10h45 |
| 15h45 - 17h15 | Conduite 1h30 | 9h00 | 12h15 |
| 17h15 - 19h15 | Déchargement Toulouse 2h | 9h00 | 14h15 |

**Constats** :
- Conduite quotidienne : **9h** = plafond standard (sans extension).
- Amplitude : **14h15** = au plafond CCN dérogation (14h grands routiers).
- **Légalité** : limite. À éviter en routine, à n'utiliser qu'occasionnellement.
- **Recommandation pro** : programmer un découcher à mi-trajet (Limoges) avec arrivée Toulouse J+1 matin → meilleur respect des durées et marge sécurité.

---

## 6. Conduite en équipage (art. 4 et 8 R561)

### 6.1 Définition

**Équipage** : 2 conducteurs ou plus se relayant sur le même véhicule, avec disponibilité simultanée pendant la 1ère heure puis facultative.

### 6.2 Règles spécifiques

- **Repos en équipage** : repos quotidien **9h consécutives sur 30h** (au lieu de 11h sur 24h).
- **Conducteur en repos** dans la cabine : décompte comme repos uniquement si véhicule en mouvement et conducteur effectivement allongé en couchette (pas en siège passager).
- **Disponibilité** : le 2e conducteur en cabine, prêt à conduire, est en « disponibilité » (mode 3 du tachygraphe). Ce n'est ni du repos, ni du travail effectif.

### 6.3 Avantage opérationnel

**Trajet Paris-Madrid** (1 250 km, 14h conduite estimée) :
- **Conducteur unique** : impossible en 1 jour (plafond 9h ou 10h). Nécessite 2 jours + 1 nuit.
- **Équipage 2 conducteurs** : faisable en **24h** consécutives (chacun fait 7h, repos 9h dans la couchette). Gain : **1 jour de transit**.

> ⚠️ **Coût équipage** : 2 salaires sur la même cargaison, justifié uniquement pour les **délais critiques** (urgence pharma, événementiel).

---

## 7. Mini-exercice à faire seul

**Énoncé** : Un conducteur a fait cette semaine :
- Lundi : 8h conduite
- Mardi : 9h conduite
- Mercredi : 10h conduite (extension)
- Jeudi : 10h conduite (extension)
- Vendredi : ? heures de conduite restantes possibles

**Questions** :
1. Quel est le total de conduite cumulé du lundi au jeudi ?
2. Quelle est la conduite restante autorisée vendredi (plafond hebdomadaire) ?
3. Une 3e extension à 10h est-elle possible vendredi ?

> 💡 Réponses en fin de module (corrections § 4).

---

## 8. Glossaire

- **Conduite continue** : durée ininterrompue au volant (max 4h30).
- **Conduite quotidienne** : cumul d'une journée (max 9h, ext. 10h).
- **Conduite hebdomadaire** : cumul lundi-dimanche (max 56h).
- **Pause** : interruption d'au moins 45 min après 4h30 de conduite.
- **Repos quotidien normal** : 11h consécutives par 24h.
- **Repos quotidien réduit** : 9h consécutives, max 3x/semaine.
- **Repos fractionné** : 3h + 9h (total ≥ 12h).
- **Équipage** : 2+ conducteurs alternés sur même véhicule.
- **Amplitude** : durée totale entre prise et fin de service (CCN max 12h ou 14h).
- **Disponibilité** : mode tachy 3, attente disponible (ni travail, ni repos).

---

## 9. Synthèse opérationnelle

1. **4h30 conduite continue** → **45 min pause** obligatoire (fractionnable 15+30).
2. **9h conduite quotidienne** → extension **10h max 2x/semaine**.
3. **56h** conduite hebdomadaire (lundi-dimanche).
4. **90h** conduite bi-hebdomadaire (2 sem. consécutives).
5. **11h repos quotidien normal** → réduit **9h max 3x/semaine** (pas de compensation).
6. **Repos fractionné 3h + 9h** = total 12h.
7. **Équipage** : repos 9h sur fenêtre 30h.
8. **CCN IDCC 16** : amplitude 12h grands routiers (14h dérogation).

---

## ⚠️ Points de vigilance

- **« 4h30 » = conduite RÉELLE**, pas amplitude. Attentes de quai non comptées.
- **Pause fractionnée** : ordre **15 min PUIS 30 min**, pas l'inverse.
- **Extension 10h** : compteur lundi 0h - dimanche 24h. Surveiller week-end.
- **Repos réduit 9h** : 3 fois max, pas de compensation. Tracer dans tachy.

## 💡 Astuces pro

- **Tableau de bord exploitation** : Excel par conducteur avec colonnes (jour, conduite, ext 10h ?, repos, infractions). Couleur rouge si > seuil. Coût 0 €.
- **Logiciel TMS** : Inelo TachoScan, Continental VDO Tisplus, Stoneridge Optac3. Coût 80-150 €/mois/véhicule, ROI en 1 mois sur amendes évitées.
- **Formation conducteurs** : intégrer un rappel R561 dans la **FCO** (Formation Continue Obligatoire) tous les 5 ans.

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : plafonds 4h30, 9h, 10h, 11h, 56h, 90h ; règles fractionnement.
- **QR cas pratique** : « Décomposez la journée du conducteur X et identifiez les infractions ».
- **Oral DP** : « Comment planifiez-vous une tournée de 12h amplitude en respectant le R561 ? »

---

## 📌 Synthèse à retenir

### Les chiffres clés du R561 art. 6, 7, 8

| Notion | Plafond | Exception |
|---|---|---|
| **Conduite continue** | 4h30 | Pause 45 min ensuite |
| **Pause** | 45 min | Fractionnable 15 + 30 |
| **Conduite quotidienne** | 9h | Ext. 10h **2x/semaine** |
| **Conduite hebdo (Lu-Di)** | 56h | — |
| **Conduite bi-hebdo (2 sem.)** | 90h | — |
| **Repos quotidien normal** | 11h consécutives | — |
| **Repos quotidien réduit** | 9h | **3x max** entre 2 repos hebdo |
| **Repos fractionné** | 3h + 9h = 12h | Pas de limite |

> 📌 **La règle d'or de la pause**
>
> Pause 45 min après 4h30 de conduite continue. Fractionnable en **15 min PUIS 30 min** (ordre obligatoire).

### Journée type légale

**5h conduite** + **45 min pause** + **4h conduite** + **autres tâches** = **9h conduite** + amplitude 12h (CCN).

> ⚠️ **Pièges classiques de l'examen**
>
> - Confusion **9h** (quotidien) et **10h** (extension)
> - Confusion **11h** (repos quotidien) et **9h** (repos réduit)
> - Confusion **45 min** (pause) et **45h** (repos hebdo)
> - Repos fractionné = **12h** total (pas 11h)
$lessonG2$,
'Maîtriser les durées maximales du R561 art. 6/7/8 : conduite continue 4h30 (pause 45 min), conduite quotidienne 9h (ext. 10h 2x/sem), hebdomadaire 56h, bi-hebdo 90h, repos quotidien 11h consécutives (réduit 9h max 3x/sem, fractionné 3h+9h=12h). Construire une journée type légale et anticiper les infractions DREAL.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Repos hebdomadaires, semaine de référence, dérogations
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Repos hebdomadaires, semaine de référence et dérogations',
    'repos-hebdo-semaine-reference-derogations',
    3, 60,
$lessonG3$
# Repos hebdomadaires, semaine de référence et dérogations

> 🎯 **Objectifs pédagogiques**
>
> - **Distinguer** repos hebdomadaire normal (45h) et réduit (24h).
> - **Calculer** la compensation d'un repos réduit (jusqu'à fin S+3).
> - **Appliquer** la règle d'alternance sur 2 semaines consécutives.
> - **Vérifier** la conformité du retour 4 semaines (Paquet Mobilité I).
> - **Mobiliser** les dérogations exceptionnelles (art. 12 R561).

---

## Introduction

Le repos hebdomadaire est **la zone de risque maximale** d'infraction. Les contrôleurs DREAL adorent y débusquer les irrégularités : compensations oubliées, alternance non respectée, repos pris en cabine illicitement.

**45 % des amendes** « infraction très sérieuse » concernent les repos hebdomadaires. Une compensation oubliée, c'est **1 500 €** par occurrence. Un repos 45h pris en cabine depuis 2017, c'est **1 500 €** supplémentaires.

Cette leçon vous donne les **outils de calcul** pour anticiper et **0 erreur** dans le tachygraphe.

---

## 1. Le repos hebdomadaire normal (art. 8.6 R561)

### 1.1 Règle de base : 45 heures consécutives

> **Article 8.6 R561** : « Au cours de deux semaines consécutives, le conducteur prend au moins deux repos hebdomadaires normaux ou un repos hebdomadaire normal et un repos hebdomadaire réduit d'au moins vingt-quatre heures. »

**Repos hebdomadaire normal = 45 heures consécutives** prises **dans la semaine** ou à cheval sur la semaine suivante.

### 1.2 Définition de la « semaine de référence »

**Semaine R561** : du **lundi 0h00** au **dimanche 23h59** (heure UTC du conducteur).

### 1.3 Délai pour prendre le repos hebdomadaire

> **Article 8.6 alinéa 2 R561** : « Le repos hebdomadaire commence au plus tard à la fin de six périodes de vingt-quatre heures comptées à partir de la fin du repos hebdomadaire précédent. »

**Règle des 6 jours (144h)** :
- Fin du repos hebdo précédent : lundi 5h00.
- Lundi 5h + 6×24h = **dimanche 5h** au plus tard pour DÉBUTER le nouveau repos hebdo.
- Sinon : infraction « début de repos hebdo tardif ».

### 1.4 Cas pratique

**Énoncé** : Un conducteur termine son repos hebdo le **dimanche soir 22h**. Quand doit-il prendre son prochain repos hebdomadaire au plus tard ?

**Correction** :
- Fin du repos précédent : dimanche 22h00.
- Délai 6 × 24h = 144h.
- Dimanche 22h + 144h = **samedi 22h00** au plus tard pour démarrer le repos hebdo suivant.
- Le repos doit durer 45h consécutives = jusqu'au **lundi 19h00** ⇒ retour au volant possible lundi 19h ou plus tard.

---

## 2. Le repos hebdomadaire réduit (art. 8.6 R561)

### 2.1 Règle : 24 heures + COMPENSATION obligatoire

**Repos hebdomadaire réduit = 24 heures consécutives** (au lieu de 45h).

### 2.2 La règle d'alternance

> **Article 8.6 R561 alinéa 1** : « Au cours de deux semaines consécutives, au moins un repos doit être normal (45h). »

**Règle stricte** : sur 2 semaines consécutives (S et S+1), il doit y avoir **au moins 1 repos hebdo normal de 45h**.

⚠️ **Conséquence** : on ne peut pas faire **2 repos réduits 24h** sur 2 semaines consécutives.

### 2.3 Calcul de la compensation

**Différence à compenser** : 45h - 24h = **21 heures**.

**Délai de compensation** : à prendre **avant la fin de la 3e semaine suivante** la semaine où le repos a été réduit.

**Mécanisme** : la compensation doit être **rattachée à un autre repos d'au moins 9h** (consécutifs avec ce repos).

### 2.4 Cas pratique chiffré

**Énoncé** : Sur 3 semaines consécutives, un conducteur prend les repos suivants :
- **S1** (8 au 14 janv.) : repos 45h le week-end ✓ normal
- **S2** (15 au 21 janv.) : repos 24h le week-end (réduit) ⇒ compensation 21h due
- **S3** (22 au 28 janv.) : repos 24h le week-end (réduit) ⇒ compensation 21h due
- **S4** (29 janv. au 4 févr.) : repos prévu 45h

**Questions** :
1. Compensation S2 due au plus tard ?
2. Compensation S3 due au plus tard ?
3. Conformité de l'alternance ?

**Correction** :
1. **Compensation S2** : 21h à prendre avant la fin de **S2 + 3 = S5** (semaine du 5-11 févr.).
2. **Compensation S3** : 21h à prendre avant la fin de **S3 + 3 = S6** (semaine du 12-18 févr.).
3. **Alternance S2/S3** : 2 repos réduits consécutifs **interdits** (art. 8.6) ⇒ **infraction** : il aurait fallu 1 repos normal sur ces 2 semaines. **Sanction** : amende **1 500 €** entreprise + **750 €** conducteur.

**Bonne pratique** : le conducteur pouvait réduire S2 (24h) puis prendre **45h en S3** (alternance OK), ou inversement.

---

## 3. Le retour hebdomadaire (Paquet Mobilité I)

### 3.1 Obligation depuis août 2020

> **Article 8.8 bis R561** (Paquet Mobilité I 2020/1054) : « Les entreprises de transport organisent le travail des conducteurs de telle sorte qu'ils puissent retourner au moins toutes les quatre semaines consécutives au centre opérationnel de l'employeur où ils ont leur lieu de travail habituel ou à leur domicile, afin d'y passer au moins un repos hebdomadaire normal. »

**Règle** : retour au domicile (ou au siège de l'entreprise) **toutes les 4 semaines maximum**.

### 3.2 Cas du conducteur en repos hebdo réduit

Si le conducteur a pris **2 repos hebdo réduits consécutifs** (cas exceptionnel autorisé en transport international, voir 4.4), le retour doit avoir lieu **toutes les 3 semaines**.

### 3.3 Documents à conserver

- **Planning de retours** prévisionnels (à présenter sur demande).
- **Justificatifs** : ticket de péage retour, position GPS du véhicule au domicile, fiche de paie mentionnant le repos pris au domicile.

### 3.4 Sanction non-respect

- Amende **750 à 1 500 €** par infraction (entreprise).
- En cas de récidive : suspension de l'autorisation de transport.

---

## 4. Le repos hebdomadaire et la cabine

### 4.1 Interdiction depuis août 2020

> **Article 8.8 R561** : « Les repos hebdomadaires normaux et tout repos hebdomadaire de plus de quarante-cinq heures pris en compensation d'une réduction antérieure ne peuvent pas être pris à bord d'un véhicule. »

**Règle** : le repos **45h** (et tout repos > 45h en compensation) DOIT être pris **hors du véhicule** :
- **Hôtel**
- **Domicile**
- **Hébergement adapté** (avec sanitaires, literie)

⚠️ **Cas autorisés en cabine** : repos quotidien (11h ou 9h) et repos hebdomadaire RÉDUIT (24h).

### 4.2 Exigences hôtel / hébergement

**Conditions** (recommandation Commission EU) :
- Chambre avec literie, sanitaires.
- Coût pris en charge par l'employeur (ou indemnisé).
- Possibilité de stationner le véhicule en sécurité à proximité.

### 4.3 Sanction

- Amende **1 500 €** par infraction (conducteur ET employeur).
- Cumulable : si 4 conducteurs sur 6 mois ⇒ 24 amendes possibles ⇒ 36 000 €.

### 4.4 Dérogation transport international

> **Article 8.6 quater R561** (depuis Paquet Mobilité I) : un conducteur en transport **international** peut prendre **2 repos hebdomadaires réduits consécutifs** à condition de :
> - Compenser intégralement les 2 réductions.
> - Prendre un **repos normal** dès la 4e semaine.
> - Conducteur effectivement à l'étranger plus de la moitié du temps.

**Exemple** : un conducteur Paris-Stockholm peut prendre 24h à Stockholm (S1), 24h à Stockholm (S2), 45h+45h chez lui (S3+S4). Légal.

---

## 5. Les dérogations (article 12 R561)

### 5.1 Cadre légal

> **Article 12 R561** : « À condition de ne pas compromettre la sécurité routière, le conducteur peut s'écarter des dispositions des articles 6, 7 et 8 [...] dans la mesure nécessaire pour gagner un point d'arrêt approprié. »

**Principe** : un conducteur peut **dépasser temporairement** les plafonds pour atteindre un **point d'arrêt sûr** (aire, parking, hôtel).

### 5.2 Conditions strictes

1. **Sécurité routière non compromise** (le conducteur n'est pas en état d'insécurité).
2. **Justification écrite** sur disque ou tachygraphe : « art. 12 - circonstances exceptionnelles ».
3. **Compensation immédiate** : si dépassement de 30 min, prendre 30 min de plus de repos.
4. **Documents à fournir** au contrôle : photo embouteillage, attestation employeur, intempéries.

### 5.3 Cas concrets fréquents

| Situation | Dérogation art. 12 ? |
|---|---|
| Embouteillage 1h sur autoroute (accident) | OUI |
| Intempéries soudaines (verglas, neige) | OUI |
| Attaque ou agression | OUI |
| Indisponibilité aire de repos saturée | OUI (point sûr suivant) |
| Mauvaise planification de l'exploitation | NON |
| « Le client veut sa marchandise » | NON |
| Retard pour ne pas dépasser de péage | NON |

### 5.4 Article 14 R561 (urgences nationales)

> **Article 14 R561** : possibilité pour un État membre d'accorder des **dérogations temporaires** (max 30 jours, prorogeable par la Commission) en cas de **circonstances exceptionnelles** :
> - Pandémies (COVID-19 : dérogations massives 2020-2022).
> - Attaques (gilets jaunes 2018-2019, blocages dépôts pétroliers 2010).
> - Catastrophes naturelles.

---

## 6. Cas pratique : compensation après 3 semaines de repos réduits

**Énoncé** : Un conducteur (transport national) a pris :
- S1 : repos 45h normal ✓
- S2 : repos 24h réduit ⇒ -21h compensation
- S3 : repos 24h réduit ⇒ -21h compensation

**Questions** :
1. L'alternance S2/S3 est-elle conforme ?
2. Quelle compensation doit être prise et avant quand ?
3. Le repos compensatoire peut-il se faire en cabine ?

**Correction** :

1. **Alternance** : NON, deux repos réduits consécutifs en transport **national** est interdit (art. 8.6). Sanction : 1 500 € employeur + 750 € conducteur.

2. **Compensation** :
   - Pour S2 : 21h à prendre avant la fin de **S5** (3 semaines après).
   - Pour S3 : 21h à prendre avant la fin de **S6**.
   - Cumul : **42h de compensation** à intégrer dans les 6 semaines suivantes.
   - **Modalité** : ajouter 42h à un autre repos (ex. semaine S4 : repos normal 45h + 21h = 66h consécutives).

3. **Cabine** : NON, tout repos hebdomadaire > 45h (compensation incluse) **interdit en cabine** depuis août 2020. À prendre en hôtel, domicile ou hébergement adapté.

---

## 7. Cas particuliers : transport en équipage

### 7.1 Repos hebdomadaire en équipage

Les **règles 45h / 24h restent identiques** en équipage. C'est uniquement le repos QUOTIDIEN qui est aménagé (9h sur 30h au lieu de 11h sur 24h).

### 7.2 Synchronisation des deux conducteurs

Les deux conducteurs ne sont pas obligés de prendre leur repos hebdo en **même temps**, mais l'entreprise doit pouvoir prouver que **chacun** a respecté les délais individuels (6 jours max).

### 7.3 Cas particulier : 2 conducteurs, 1 véhicule en mouvement

Si conducteur A est en repos quotidien (couchette) et conducteur B au volant, **le véhicule peut rouler**. Le repos est valable.

⚠️ Mais pour le repos hebdo 45h : l'**arrêt complet du véhicule** est obligatoire dans un lieu adapté (interdit cabine).

---

## 8. Cas pratique d'examen DREAL

**Énoncé** : Le contrôleur DREAL examine 6 semaines d'activité d'un conducteur :

| Semaine | Repos hebdo | Compensation prévue | Lieu |
|---|---|---|---|
| S1 | 45h | — | Domicile |
| S2 | 24h (réduit) | À prendre avant fin S5 | Hôtel |
| S3 | 45h normal | — | Cabine ⚠️ |
| S4 | 24h (réduit) | À prendre avant fin S7 | Hôtel |
| S5 | 24h (réduit) | À prendre avant fin S8 | Aire ⚠️ |
| S6 | 36h | Compensation S2 partielle | Cabine ⚠️ |

**Questions** :
1. Identifiez TOUTES les infractions.
2. Calculez le montant total des amendes (en supposant amende de base 1 500 €/infraction très sérieuse).

**Correction** :

**Infractions identifiées** :

1. **S3 — repos 45h en cabine** : interdit depuis août 2020 ⇒ 1 500 € conducteur + 1 500 € entreprise.
2. **S4/S5 — alternance** : 2 repos réduits consécutifs en transport national interdit ⇒ 1 500 € + 750 €.
3. **S5 — repos en aire** : aire = pas hébergement adapté ⇒ 750 € (mineure si conducteur).
4. **S6 — compensation 21h S2** : 36h - 24h = 12h seulement de compensation. Manque 9h ⇒ infraction « compensation insuffisante » ⇒ 750 €.
5. **S6 — repos 36h en cabine** : 36h > 24h donc considéré comme normal long ⇒ interdit cabine ⇒ 1 500 € + 1 500 €.

**Total amendes** :
- Conducteur : 1 500 + 750 + 750 + 750 + 1 500 = **5 250 €**
- Entreprise : 1 500 + 1 500 + 1 500 + 750 = **5 250 €**
- **Cumul** : **10 500 €** sur 6 semaines pour 1 conducteur.

**Bonne pratique** : auditer mensuellement les disques avec un logiciel de tachygraphe (TachoScan, VDO Tisplus). Coût ~80 €/mois, ROI immédiat.

---

## 9. Mini-exercice à faire seul

**Énoncé** : Un conducteur effectue un transport longue distance Paris-Madrid-Paris avec ces repos :
- S1 (Paris-Madrid) : 24h à Madrid (réduit)
- S2 (Madrid-Paris-Madrid) : 24h à Madrid (réduit)
- S3 (Madrid-Paris) : repos 45h prévu chez lui

**Questions** :
1. Cette configuration est-elle légale en transport international ?
2. Quelle compensation totale doit être versée et avant quand ?
3. Le retour 4 semaines est-il respecté ?

> 💡 Réponses en fin de module (corrections § 4).

---

## 10. Glossaire

- **Repos hebdo normal** : 45 heures consécutives.
- **Repos hebdo réduit** : 24 heures consécutives + compensation 21h.
- **Compensation** : 21h à rattacher à un autre repos d'au moins 9h.
- **Délai compensation** : avant fin de la 3e semaine suivante.
- **Alternance** : sur 2 semaines consécutives, au moins 1 repos normal.
- **Retour 4 semaines** : Paquet Mobilité I, retour domicile/siège.
- **Article 12 R561** : dérogation pour atteindre un point d'arrêt sûr.
- **Article 14 R561** : dérogations temporaires accordées par les États (catastrophes).

---

## 11. Synthèse opérationnelle

1. **Repos hebdo normal = 45h consécutives**, hebdomadaire (max 6 jours = 144h après le précédent).
2. **Repos hebdo réduit = 24h** + compensation **21h** avant fin S+3.
3. **Alternance** : sur 2 sem. consécutives, **au moins 1 repos normal**.
4. **Retour 4 semaines** au domicile (Paquet Mobilité I 2020).
5. **Repos 45h en cabine = INTERDIT** depuis août 2020 (hôtel ou domicile).
6. **Article 12** : dérogation pour point d'arrêt sûr, justifié et compensé.
7. **Transport international** : 2 repos réduits consécutifs autorisés sous conditions.
8. **Sanctions** : 750-1 500 € par infraction sérieuse / très sérieuse.

---

## ⚠️ Points de vigilance

- **NE JAMAIS** prendre 2 repos réduits consécutifs en transport national.
- **Compensation** : la **rattacher** à un autre repos d'au moins 9h — pas en isolé.
- **Repos 45h** : hôtel ou domicile, **pas cabine**. 1 500 €/infraction.
- **Retour 4 semaines** : tracer dans planning + GPS.

## 💡 Astuces pro

- **Logiciel tachy** : Inelo TachoScan (€80/mois), Continental VDO Tisplus, Stoneridge Optac3.
- **Tableau Excel** par conducteur : alerte automatique si compensation > J+18.
- **Convention partenariat hôtel** : tarifs négociés -30 % avec chaînes (B&B, Ibis Budget, Premiere Classe). Économie 20-30 € par nuit.

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : durée 45h/24h ; compensation 21h ; règle d'alternance ; retour 4 semaines.
- **QR cas pratique** : « Calculez la compensation due et identifiez les infractions sur ce planning de 6 semaines ».
- **Oral DP** : « Comment organisez-vous le retour 4 semaines dans une PME 5 véhicules ? »

---

## 📌 Synthèse à retenir

### Repos hebdomadaires R561 art. 8.6

| Type | Durée | Compensation | Lieu |
|---|---|---|---|
| **Normal** | 45h consécutives | — | Hôtel ou domicile |
| **Réduit** | 24h consécutives | **21h** avant fin S+3 | Cabine autorisée |
| **Compensation** | rattachée à repos ≥ 9h | — | **Hôtel ou domicile** |

### Règle d'alternance

Sur **2 semaines consécutives** (S et S+1), au moins **1 repos NORMAL 45h**.

> 📌 **3 chiffres sacrés à retenir**
>
> - **45h** : repos hebdo normal
> - **24h** : repos hebdo réduit
> - **21h** : compensation due (45 - 24)

### Paquet Mobilité I (août 2020)

- **Retour 4 semaines** au domicile/siège (3 si 2 réduits consécutifs)
- **Repos 45h en cabine = INTERDIT** : hôtel, domicile, hébergement adapté
- **Transport international** : 2 réduits consécutifs autorisés sous conditions

> ⚠️ **Sanctions cumulables**
>
> - Repos réduit en cabine OK · Repos 45h en cabine = **1 500 €**
> - Compensation oubliée = **750 €**
> - Alternance non respectée = **1 500 €**
> - Retour 4 sem. non respecté = **750-1 500 €**
$lessonG3$,
'Maîtriser les repos hebdomadaires R561 art. 8.6 : normal 45h consécutives (hôtel/domicile), réduit 24h avec compensation 21h avant fin S+3, alternance sur 2 semaines (au moins 1 normal), retour 4 semaines (Paquet Mobilité I 2020), interdiction du 45h en cabine. Mobiliser les dérogations art. 12 (point d''arrêt sûr) et art. 14 (catastrophes nationales).'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Chronotachygraphe, contrôles, infractions et sanctions
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Chronotachygraphe, contrôles, infractions et sanctions',
    'chrono-controles-infractions-sanctions',
    4, 60,
$lessonG4$
# Chronotachygraphe, contrôles, infractions et sanctions

> 🎯 **Objectifs pédagogiques**
>
> - **Distinguer** chronotachygraphes analogique, numérique et intelligent 2e gén.
> - **Maîtriser** les 4 modes du tachygraphe (conduite, travail, disponibilité, repos).
> - **Téléchager** carte conducteur (28 j) et mémoire véhicule (90 j).
> - **Identifier** les 4 niveaux d'infractions (mineure, sérieuse, très sérieuse, plus sérieuse).
> - **Calculer** les sanctions et anticiper la défense en cas de redressement.

---

## Introduction

Le chronotachygraphe est l'**organe central de la traçabilité** du temps de conduite. Sans lui, **aucun contrôle** R561 ne serait possible. C'est aussi l'**outil de défense** du conducteur et de l'entreprise en cas de litige.

**100 % des véhicules > 3,5 t** mis en service depuis 2006 ont un tachygraphe numérique. **Depuis juin 2019**, les véhicules neufs sont équipés du **tachygraphe intelligent 2e génération**, capable de reconnaître automatiquement les frontières et le cabotage.

Cette leçon vous donne les **gestes du quotidien** (manipulations, téléchargements, vérifications) et la **grille de lecture des infractions** pour évaluer un risque DREAL.

---

## 1. Histoire et générations du chronotachygraphe

### 1.1 Évolution chronologique

| Génération | Période | Caractéristique |
|---|---|---|
| **Analogique** | 1985 - 2006 | Disque papier ($ chronotachygraphe Kienzle / Veeder-Root). |
| **Numérique 1ère gén.** | 2006 - 2018 | Carte à puce, mémoire interne. Imposé par règlement 3821/85. |
| **Numérique 2e gén. (intelligent)** | depuis 15 juin 2019 | GNSS (positionnement satellite), DSRC (contrôle à distance). |
| **Tachygraphe intelligent v2** | depuis août 2023 | Reconnaissance frontières automatique, cabotage. |

### 1.2 Tachygraphe numérique : composants

- **Unité embarquée (VU)** : boîtier connecté au capteur de mouvement.
- **Capteur de mouvement (KIT)** : sur la boîte de vitesses.
- **Carte conducteur** : à insérer pour identifier le conducteur.
- **Carte entreprise** : pour télécharger les données et les protéger.
- **Carte de contrôle** : pour les contrôleurs DREAL/gendarmerie.
- **Carte d'atelier** : pour les ateliers agréés (calibration).

### 1.3 Tachygraphe intelligent 2e gén. — fonctions clés

- **Géolocalisation GNSS** : enregistrement automatique des positions toutes les 3 heures.
- **Reconnaissance frontières** : pour distinguer R561 vs AETR.
- **Détection cabotage** : compteur des opérations de cabotage en cours.
- **DSRC** (Dedicated Short-Range Communication) : contrôle à distance par les forces de l'ordre (« radar tachy »).

---

## 2. La carte conducteur

### 2.1 Caractéristiques

- **Format** : carte à puce (taille carte de crédit).
- **Émetteur** : ANTAI / IN Groupe (CHRONOSERVICES en France).
- **Coût** : ~70 € (renouvellement 5 ans).
- **Validité** : **5 ans**.
- **Contenu** : identité, date de naissance, photo.
- **Mémoire** : dernières **28 jours** d'activité.

### 2.2 Obligations conducteur

- **À insérer** dans le tachy à chaque prise de service.
- **À retirer** à la fin de service (sauf trajet partagé en équipage).
- **À conserver** sur soi en circulation (pas dans le véhicule).
- **À renouveler** **6 mois** avant l'expiration.

### 2.3 Carte perdue, volée ou défectueuse

**Procédure CHRONOSERVICES** :
1. **Déclaration** sous **7 jours** (en ligne sur chronoservices.fr).
2. **Demande de remplacement** (délai 3 semaines).
3. **Pendant la période sans carte** : conducteur peut conduire **15 jours** maximum, en imprimant 2 tickets papier (début + fin journée) avec mentions manuscrites.
4. **Au-delà de 15 jours** : conduite interdite.

⚠️ **Coût opérationnel** : 1 conducteur sans carte = 1 véhicule à l'arrêt 3 semaines = 8 000-15 000 € de manque à gagner.

---

## 3. Les 4 modes du tachygraphe

### 3.1 Tableau des 4 modes

| Mode | Symbole | Description | Décompté |
|---|---|---|---|
| **1 — Conduite** | volant | Conducteur au volant, véhicule en mouvement | Conduite (art. 6) |
| **2 — Travail** | marteaux croisés | Autres tâches : chargement, paperasse, lavage | Durée du travail |
| **3 — Disponibilité** | carré | Attente disponible : quai, ferry, équipage en cabine non couché | Ni travail ni repos |
| **4 — Repos** | lit | Repos effectif (couchette, hôtel, domicile) | Repos (art. 8) |

### 3.2 Manipulation manuelle

Le conducteur **doit basculer** manuellement entre les modes 2-3-4 (le mode 1 est automatique dès que le véhicule roule).

⚠️ **Erreur fréquente** : oublier de basculer en mode 4 (repos) à la fin de service. Le tachy reste en mode 2 (travail), ce qui peut générer une fausse alarme « repos quotidien insuffisant ».

### 3.3 Cas particulier : équipage

- Conducteur A conduit (mode 1) → Conducteur B doit être en mode 3 (disponibilité) si en siège passager, ou mode 4 (repos) si allongé en couchette.
- Au changement, A bascule en mode 4, B insère sa carte et passe en mode 1.

---

## 4. Téléchargement et conservation des données

### 4.1 Téléchargement carte conducteur

> **Décret 2003-1242, modifié** : tous les **28 jours** pour la carte conducteur, et **avant tout changement d'entreprise**.

**Procédure** :
1. Insérer la carte conducteur dans le **lecteur de l'entreprise** (lecteur USB ~150 €).
2. Ouvrir le logiciel (TachoScan, VDO Tisplus, Optac3).
3. Lecture des fichiers (.DDD).
4. Stockage **chiffré** sur serveur ou cloud sécurisé.

### 4.2 Téléchargement mémoire véhicule

> Tous les **90 jours** pour la mémoire véhicule (VU).

**Procédure** :
1. Insertion de la **carte entreprise** dans le tachygraphe (à bord du véhicule).
2. Téléchargement (~5 minutes).
3. Stockage des fichiers .DDD sur serveur entreprise.

### 4.3 Conservation des données

> **Article L. 3315-1 C. transports** : conservation obligatoire **1 an minimum**.

En pratique, conserver **3 ans** pour anticiper les contrôles DREAL (qui peuvent remonter sur 6 mois à 3 ans selon la gravité).

### 4.4 Registre des contrôles

L'entreprise doit tenir un **registre** des téléchargements :
- Date du téléchargement.
- Conducteur / véhicule concerné.
- Personne qui a effectué le téléchargement.
- Anomalies détectées et suite donnée.

---

## 5. Les 4 niveaux d'infractions

### 5.1 Classification (annexe III directive 2009/5/CE)

| Niveau | Type | Exemple | Amende |
|---|---|---|---|
| **MI — Mineure** | manquement formel | Carte oubliée, oubli mode 4 | **135 €** (forfaitaire) |
| **SI — Sérieuse** | dépassement modéré | Conduite continue 4h45 (15 min) | **750 €** |
| **VSI — Très sérieuse** | dépassement franc | Conduite continue > 5h | **1 500 €** |
| **MSI — Plus sérieuse** | abus grave | Manipulation tachy, falsification | **3 750 €** + amende pénale |

### 5.2 Détail des infractions courantes

| Infraction | Niveau | Amende |
|---|---|---|
| Conduite continue dépasse 4h30 (≤ 30 min) | MI | 135 € |
| Conduite continue dépasse 5h | SI | 750 € |
| Conduite continue dépasse 6h | VSI | 1 500 € |
| Conduite quotidienne dépasse 9h (≤ 1h) | MI | 135 € |
| Conduite quotidienne dépasse 10h | SI | 750 € |
| Conduite quotidienne dépasse 11h | VSI | 1 500 € |
| Conduite hebdo dépasse 56h (≤ 4h) | SI | 750 € |
| Conduite hebdo dépasse 60h | VSI | 1 500 € |
| Repos quotidien < 11h (réduit ≥ 8h30) | MI | 135 € |
| Repos quotidien < 8h30 | SI | 750 € |
| Repos quotidien < 7h | VSI | 1 500 € |
| Repos hebdo < 45h (≥ 42h) | MI | 135 € |
| Repos hebdo < 24h (réduit) | VSI | 1 500 € |
| Repos 45h en cabine | VSI | 1 500 € |
| Falsification tachy / carte | MSI | 3 750 € + pénal |

### 5.3 Cumul des amendes

- **Forfaitaires** : amende fixe par infraction.
- **Majorations** : si paiement > 30 jours, majoration de 50 %.
- **Cumul** : chaque infraction est sanctionnée individuellement (pas de plafond).

---

## 6. Cas pratique : sanction conducteur ET employeur

### 6.1 Énoncé

Un contrôle DREAL en entreprise audite 6 mois d'activité. Pour le conducteur Dupont :
- **3 dépassements** conduite quotidienne 9h30 (entre 9h et 10h, hors extension officielle) ⇒ MI 135 € × 3.
- **2 dépassements** repos quotidien (10h au lieu de 11h) ⇒ MI 135 € × 2.
- **1 dépassement** conduite continue 5h15 ⇒ SI 750 €.
- **1 repos 45h en cabine** ⇒ VSI 1 500 €.

### 6.2 Calcul amendes conducteur

3 × 135 + 2 × 135 + 750 + 1 500 = 405 + 270 + 750 + 1 500 = **2 925 €**.

### 6.3 Calcul amendes employeur (responsabilité solidaire)

> **Article 10 R561** : « L'entreprise organise les transports de manière à ce que le conducteur puisse respecter le règlement. »

L'entreprise est **présumée responsable** sauf preuve contraire (diligences raisonnables : formation, planning, contrôle des disques).

Amendes employeur identiques au conducteur ⇒ **2 925 €** supplémentaires.

### 6.4 Total

- Conducteur : 2 925 €.
- Entreprise : 2 925 €.
- **Cumul** : **5 850 €** sur 6 mois pour 1 conducteur.

⚠️ **Si 12 conducteurs avec profil similaire** sur 6 mois : potentiellement **70 200 €** de redressement.

### 6.5 Exonération possible

L'entreprise peut **réduire** les amendes en prouvant :
- **Formation** régulière des conducteurs (FCO + sessions internes).
- **Planning** cohérent avec R561 (audit logiciel).
- **Audit mensuel** des disques avec rapport d'anomalies.
- **Mesures correctives** prises (avertissement, suspension prime, FCO supplémentaire).

⇒ Réduction possible **30-50 %** des amendes employeur.

---

## 7. Procédure de défense en cas de contrôle

### 7.1 Étapes

1. **Réception du PV** : 2 mois pour répondre.
2. **Consultation du dossier** : auprès de la DREAL.
3. **Mémoire en défense** : argumenter chaque infraction (dérogation art. 12, force majeure, erreur tachy).
4. **Audition** : possibilité de demander un entretien avec l'agent.
5. **Décision** : confirmation, réduction ou annulation.
6. **Recours** : tribunal administratif sous 2 mois si désaccord.

### 7.2 Documents de défense

- **Tickets péage** : prouver le trajet réel.
- **GPS véhicule** : confirmer position et timing.
- **Bons de chargement** : prouver les attentes quai (mode 2 ou 3).
- **Attestation employeur** : circonstances exceptionnelles (commande urgente, cas de force majeure).
- **Photos / mails** : embouteillage, intempéries, attaque.

### 7.3 Astuce pro : exonération article 12

**Récit type** : « En sortie de Lyon le 15 mars 2026, accident sur A6 ⇒ embouteillage 3h. Conduite continue dépassée de 30 min pour atteindre l'aire de Mâcon (point sûr le plus proche). Compensation prise immédiatement (45 min au lieu de 30). Photos de bouchon en pièce jointe. »

Si bien argumenté, l'infraction est **annulée** dans 60-70 % des cas.

---

## 8. Cas pratique : redressement DREAL global

**Énoncé** : Un transport routier de 8 véhicules, 12 conducteurs, fait l'objet d'un contrôle DREAL en entreprise sur 6 mois. Constat : **52 infractions** dont :
- 28 mineures (135 € chacune).
- 18 sérieuses (750 € chacune).
- 5 très sérieuses (1 500 € chacune).
- 1 plus sérieuse (3 750 € chacune).

**Question** : Calculez le total redressement (conducteurs + entreprise).

**Correction** :

**Amendes conducteurs** (forfaitaires individuelles, max amendes / conducteur 1 500 €) :
- 28 × 135 = 3 780 €
- 18 × 750 = 13 500 €
- 5 × 1 500 = 7 500 €
- 1 × 3 750 = 3 750 €
- **Sous-total conducteurs** : **28 530 €**.

**Amendes entreprise** (responsabilité solidaire art. 10) :
- Idem ⇒ **28 530 €**.
- Possibilité d'exonération partielle si diligence prouvée (-30 % max).

**Total brut** : **57 060 €**.

**Total après défense** : ~ 40 000-45 000 €.

**Coût caché** : suspension licence transport (3 mois si récidive) ⇒ ~150-300 k€ manque à gagner.

---

## 9. Mini-exercice à faire seul

**Énoncé** : Un conducteur a effectué les manipulations suivantes :
- Insertion carte 5h00, départ 5h30.
- Conduite continue jusqu'à 10h15 (4h45) ⇒ infraction ?
- Pause 30 min puis 2h conduite (jusqu'à 12h45).
- Total quotidien : 6h45 conduite.
- Repos 10h cette nuit (au lieu de 11h).

**Questions** :
1. Quelle infraction sur la conduite continue ?
2. Quelle infraction sur le repos quotidien ?
3. Calculez les amendes conducteur + entreprise.

> 💡 Réponses en fin de module (corrections § 4).

---

## 10. Glossaire

- **Chronotachygraphe** : appareil enregistreur des temps de conduite et de repos.
- **VU (Vehicle Unit)** : unité embarquée du tachygraphe.
- **GNSS** : Global Navigation Satellite System (géolocalisation).
- **DSRC** : Dedicated Short-Range Communication (contrôle à distance).
- **Carte conducteur** : carte à puce nominative, valable 5 ans.
- **Mode 1/2/3/4** : conduite / travail / disponibilité / repos.
- **CHRONOSERVICES** : service public français d'émission des cartes (en. IN Groupe).
- **MI/SI/VSI/MSI** : niveaux d'infractions (mineure, sérieuse, très sérieuse, plus sérieuse).
- **Article 10 R561** : responsabilité solidaire de l'entreprise.

---

## 11. Synthèse opérationnelle

1. **3 générations** : analogique → numérique 2006 → intelligent 2e gén. 2019.
2. **Carte conducteur** : nominative, 5 ans, à insérer début/fin service. CHRONOSERVICES.
3. **4 modes tachy** : conduite (auto), travail (manuel), disponibilité, repos.
4. **Téléchargement** : carte conducteur **28 j**, mémoire véhicule **90 j**, conservation **1 an min** (3 ans recommandé).
5. **4 niveaux d'infractions** : MI (135 €), SI (750 €), VSI (1 500 €), MSI (3 750 €).
6. **Responsabilité solidaire** entreprise (art. 10 R561) — exonération possible -30 %.
7. **Défense** : tickets péage, GPS, attestation, photos, art. 12.
8. **Outils** : TachoScan, VDO Tisplus, Optac3 (~80-150 €/mois/véhicule).

---

## ⚠️ Points de vigilance

- **Carte conducteur perdue** : déclaration < 7 jours, conduite limitée à 15 jours sans carte.
- **Mode 4 oublié** : génère une fausse alarme « repos insuffisant ».
- **Téléchargement 90 j véhicule** : oubli = amende 750 € entreprise.
- **Falsification tachy** = MSI 3 750 € **+ poursuites pénales** (art. L. 3315-3 C. transports).

## 💡 Astuces pro

- **Logiciel TachoScan** : analyse mensuelle automatique, alertes anomalies. ROI 1 mois.
- **Formation FCO** : 35h tous les 5 ans, intégrer un module spécial « R561 nouvelle version ».
- **Convention atelier** : prendre un atelier agréé tachygraphe sous contrat (calibration tous les 2 ans, ~150 €/véhicule).

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : générations tachy ; modes 1-2-3-4 ; téléchargement 28/90 j ; niveaux infractions.
- **QR cas pratique** : « Calculez les amendes conducteur et employeur sur ce listing ».
- **Oral DP** : « Comment vous organisez-vous pour le téléchargement des cartes et VU ? »

---

## 12. Corrections des mini-exercices du module

### Leçon 1 — 3 véhicules (VUL, Porteur, Semi Russie)

1. **R561** : Véhicule B (Porteur 12 t intra-UE). À partir 1/7/2026, Véhicule A (VUL 3,2 t) si international.
2. **AETR** : Véhicule C (Semi vers Russie hors UE).
3. **Chronotachygraphe** :
   - A : pas obligatoire en transport national jusqu'à 1/7/2026, puis numérique intelligent.
   - B : numérique intelligent 2e génération.
   - C : numérique intelligent 2e génération.
4. **Paquet Mobilité I 2026** : Véhicule A devient soumis au R561 dès qu'il fait du transport international ou cabotage. Obligation d'installer un tachygraphe et de respecter les temps de conduite.

### Leçon 2 — Conduite hebdomadaire

1. **Total Lu-Je** : 8 + 9 + 10 + 10 = **37 heures**.
2. **Reste vendredi** : 56 - 37 = **19 heures** théoriques. Mais plafond **quotidien 9h** (ou 10h ext.) ⇒ vendredi conduite max 10h si extension dispo.
3. **3e extension** : NON, déjà 2 extensions cette semaine (mercredi + jeudi). Vendredi limité à **9h**. Total semaine = 37 + 9 = **46h** (sous plafond 56h).

### Leçon 3 — Paris-Madrid-Paris

1. **Légal en international** : OUI, art. 8.6 quater R561 (Paquet Mobilité I) autorise 2 réduits consécutifs si compensation et repos normal en S+1 ou S+2.
2. **Compensation totale** : 2 × 21h = **42h** à intégrer dans les 6 semaines suivantes.
   - S1 réduit : compensation avant fin S4.
   - S2 réduit : compensation avant fin S5.
   - **S3 = 45h normal + 42h compensation** = 87h consécutives au domicile.
3. **Retour 4 semaines** : repos S3 au domicile en France ⇒ retour respecté en S3 (≤ 4 semaines après début mission).

### Leçon 4 — Conduite continue + repos

1. **Conduite continue 4h45** : dépassement 15 min ⇒ **infraction MI** 135 € (mineure, < 30 min).
2. **Repos quotidien 10h** : repos réduit possible 9h max 3x/sem. 10h n'est pas réduit conforme (10h ≥ 9h mais non standard normal 11h). En pratique, contrôleur considère 10h comme **MI** (135 €) si occasionnel.
3. **Amendes** :
   - Conducteur : 135 + 135 = **270 €**.
   - Entreprise (art. 10) : 270 €.
   - **Total** : **540 €** pour 1 jour. Si répété 5x/mois ⇒ 2 700 €/mois soit **32 400 €/an** pour 1 conducteur.

---

## 📌 Synthèse à retenir

### Chronotachygraphe — 3 générations

| Génération | Période | Particularité |
|---|---|---|
| Analogique | avant 2006 | Disque papier |
| Numérique 1ère gén. | 2006-2019 | Carte à puce |
| **Intelligent 2e gén.** | depuis juin 2019 | GNSS + DSRC + frontières |

### Les 4 modes du tachygraphe

- **Mode 1** — Conduite (volant) — automatique
- **Mode 2** — Travail (chargement, paperasse) — manuel
- **Mode 3** — Disponibilité (attente) — manuel
- **Mode 4** — Repos (couchette) — manuel

### Téléchargements obligatoires

| Source | Fréquence | Acteur |
|---|---|---|
| **Carte conducteur** | tous les **28 jours** | entreprise |
| **Mémoire véhicule** | tous les **90 jours** | entreprise |
| **Conservation** | **1 an minimum** (3 ans recommandé) | entreprise |

### Les 4 niveaux d'infractions

| Niveau | Code | Amende type |
|---|---|---|
| Mineure | MI | **135 €** |
| Sérieuse | SI | **750 €** |
| Très sérieuse | VSI | **1 500 €** |
| Plus sérieuse | MSI | **3 750 €** + pénal |

> 📌 **Responsabilité solidaire art. 10 R561**
>
> L'entreprise est **présumée responsable** des infractions de ses conducteurs. Exonération possible si diligence prouvée (-30 % à -50 %).

> ⚠️ **Carte conducteur perdue**
>
> - Déclaration sous **7 jours** chez CHRONOSERVICES
> - Conduite limitée à **15 jours** maximum sans carte
> - Renouvellement standard : **6 mois avant** expiration (validité 5 ans)
$lessonG4$,
'Maîtriser le chronotachygraphe (générations analogique/numérique/intelligent 2e gén.), la carte conducteur (5 ans, 28 jours mémoire), les 4 modes (conduite/travail/disponibilité/repos), les téléchargements (28 j carte, 90 j véhicule), les 4 niveaux d''infractions (MI 135€/SI 750€/VSI 1500€/MSI 3750€) et la responsabilité solidaire de l''entreprise (art. 10 R561).'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- BANQUE DE QUESTIONS — 48 QCM + 8 QR
  -- =================================================================

  -- ===== LEÇON 1 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'Le règlement (CE) n° 561/2006 s''applique aux véhicules de transport de marchandises de :',
   '[{"id":"a","label":"Plus de 2,5 t PTAC","is_correct":false},{"id":"b","label":"Plus de 3,5 t PTAC","is_correct":true},{"id":"c","label":"Plus de 7,5 t PTAC","is_correct":false},{"id":"d","label":"Plus de 12 t PTAC","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-04','lecon-1','champ-application'], 'mft-2026-gotrm:bc01-04-v3:l1:q1', true,
   'Art. 2 R561/2006 : véhicules > 3,5 t PTAC (avec ou sans remorque). Le Paquet Mobilité I étend aux VUL > 2,5 t en transport international depuis le 1/7/2026.'),
  (v_formation, v_module, 'qcm', 'L''accord AETR s''applique au transport :',
   '[{"id":"a","label":"Uniquement intra-UE","is_correct":false},{"id":"b","label":"Hors UE ou mixte avec pays signataire","is_correct":true},{"id":"c","label":"Uniquement maritime","is_correct":false},{"id":"d","label":"Uniquement aérien","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-04','lecon-1','aetr'], 'mft-2026-gotrm:bc01-04-v3:l1:q2', true,
   'AETR (Accord Européen sur les Transports Routiers, 1970) : transport entre UE et pays signataires hors UE (Russie, Maroc, Tunisie, Turquie, UK depuis Brexit).'),
  (v_formation, v_module, 'qcm', 'Pour les autocars, le R561 s''applique aux véhicules de :',
   '[{"id":"a","label":"Plus de 5 places","is_correct":false},{"id":"b","label":"Plus de 9 places (conducteur compris)","is_correct":true},{"id":"c","label":"Plus de 20 places","is_correct":false},{"id":"d","label":"Plus de 50 places","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-04','lecon-1','autocars'], 'mft-2026-gotrm:bc01-04-v3:l1:q3', true,
   'Art. 2 R561 : transport de personnes > 9 places (conducteur compris). En dessous = taxi, VTC, mini-bus exclus.'),
  (v_formation, v_module, 'qcm', 'Lequel de ces véhicules est EXCLU du R561 ?',
   '[{"id":"a","label":"Camion 26 t pour autrui","is_correct":false},{"id":"b","label":"Véhicule auto-école PL","is_correct":true},{"id":"c","label":"Semi 40 t en compte propre","is_correct":false},{"id":"d","label":"Autocar 50 places","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-04','lecon-1','exclusions'], 'mft-2026-gotrm:bc01-04-v3:l1:q4', true,
   'Art. 3 R561 : véhicules d''auto-école exclus, ainsi que militaires, secours d''urgence, entretien des routes, services réguliers ≤ 50 km, collecte de lait, véhicules historiques > 25 ans.'),
  (v_formation, v_module, 'qcm', 'L''article 6 du R561/2006 traite de :',
   '[{"id":"a","label":"Le contrôle des chargements","is_correct":false},{"id":"b","label":"La durée maximale de conduite","is_correct":true},{"id":"c","label":"Les pauses obligatoires","is_correct":false},{"id":"d","label":"Le tachygraphe","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-04','lecon-1','articles'], 'mft-2026-gotrm:bc01-04-v3:l1:q5', true,
   'Art. 6 = durée conduite (9h/56h/90h). Art. 7 = pauses (45 min). Art. 8 = repos (11h/45h). Art. 12 = dérogations.'),
  (v_formation, v_module, 'qcm', 'Quelle autorité contrôle prioritairement les temps de conduite en entreprise ?',
   '[{"id":"a","label":"DRFiP","is_correct":false},{"id":"b","label":"DREAL — service contrôle","is_correct":true},{"id":"c","label":"URSSAF","is_correct":false},{"id":"d","label":"DGCCRF","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-04','lecon-1','controle'], 'mft-2026-gotrm:bc01-04-v3:l1:q6', true,
   'DREAL (Direction régionale de l''environnement, de l''aménagement et du logement) — service contrôle des transports terrestres : audits entreprise R561, ADR, surcharge.'),
  (v_formation, v_module, 'qcm', 'Le Paquet Mobilité I (juillet 2020) impose :',
   '[{"id":"a","label":"Le retour au domicile toutes les 4 semaines max","is_correct":true},{"id":"b","label":"L''interdiction des semi-remorques","is_correct":false},{"id":"c","label":"Le port de l''uniforme","is_correct":false},{"id":"d","label":"Le passage en boîte automatique","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-04','lecon-1','paquet-mobilite'], 'mft-2026-gotrm:bc01-04-v3:l1:q7', true,
   'Règlement UE 2020/1054 : retour 4 semaines (3 si 2 réduits consécutifs), repos 45h hors cabine, tachygraphe intelligent 2e gén., VUL > 2,5 t en international au 1/7/2026.'),
  (v_formation, v_module, 'qcm', 'La CCN IDCC 16 (transport routier de marchandises) :',
   '[{"id":"a","label":"Remplace le R561","is_correct":false},{"id":"b","label":"Peut prévoir des règles plus favorables au conducteur","is_correct":true},{"id":"c","label":"Est applicable uniquement aux ouvriers","is_correct":false},{"id":"d","label":"S''applique seulement à l''international","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-04','lecon-1','ccn'], 'mft-2026-gotrm:bc01-04-v3:l1:q8', true,
   'Art. 14 R561 : les États peuvent adopter des mesures plus favorables. La CCN IDCC 16 prévoit amplitude 12h (14h dérogation), pause repas payée, etc.'),
  (v_formation, v_module, 'qcm', 'Un trajet Paris → Moscou utilise :',
   '[{"id":"a","label":"Uniquement R561","is_correct":false},{"id":"b","label":"R561 jusqu''à frontière UE puis AETR","is_correct":true},{"id":"c","label":"Uniquement le code Russe","is_correct":false},{"id":"d","label":"Aucune réglementation","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-04','lecon-1','articulation'], 'mft-2026-gotrm:bc01-04-v3:l1:q9', true,
   'R561 dans l''UE (jusqu''à frontière Pologne-Biélorussie), puis AETR ensuite (Biélorussie + Russie signataires). Le tachygraphe intelligent reconnaît automatiquement le passage.'),
  (v_formation, v_module, 'qcm', 'La distinction entre temps de conduite et durée du travail repose sur :',
   '[{"id":"a","label":"Aucune (synonymes)","is_correct":false},{"id":"b","label":"Le temps de conduite est un sous-ensemble de la durée du travail","is_correct":true},{"id":"c","label":"La durée du travail est un sous-ensemble du temps de conduite","is_correct":false},{"id":"d","label":"Ils sont totalement indépendants","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-04','lecon-1','definitions'], 'mft-2026-gotrm:bc01-04-v3:l1:q10', true,
   'Temps de conduite (R561, max 9h) ⊂ Durée du travail (Code travail + CCN, max 48h/sem moyenne). Conduite + chargement + paperasse + lavage = durée du travail.'),
  (v_formation, v_module, 'qcm', 'Depuis le Brexit, le Royaume-Uni applique :',
   '[{"id":"a","label":"Uniquement R561","is_correct":false},{"id":"b","label":"L''AETR pour les transports vers l''UE","is_correct":true},{"id":"c","label":"Sa propre réglementation incompatible","is_correct":false},{"id":"d","label":"Aucune réglementation","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-04','lecon-1','brexit'], 'mft-2026-gotrm:bc01-04-v3:l1:q11', true,
   'Depuis le Brexit (2020), le UK est un pays tiers signataire de l''AETR. Les transports France-UK sont régis par l''AETR.'),
  (v_formation, v_module, 'qcm', 'Le R561 prime sur :',
   '[{"id":"a","label":"La Constitution","is_correct":false},{"id":"b","label":"Les lois nationales contraires","is_correct":true},{"id":"c","label":"Les conventions internationales","is_correct":false},{"id":"d","label":"Aucun texte","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-04','lecon-1','hierarchie'], 'mft-2026-gotrm:bc01-04-v3:l1:q12', true,
   'Règlement européen = application directe + primauté sur droit national contraire. Mais le droit national peut adopter des mesures plus favorables au conducteur (art. 14 R561).');

  -- ===== LEÇON 2 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'La conduite continue maximale avant pause obligatoire est de :',
   '[{"id":"a","label":"3 heures","is_correct":false},{"id":"b","label":"4 heures","is_correct":false},{"id":"c","label":"4 heures 30","is_correct":true},{"id":"d","label":"5 heures","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-04','lecon-2','conduite-continue'], 'mft-2026-gotrm:bc01-04-v3:l2:q1', true,
   'Art. 7 R561 : conduite continue 4h30 max → pause 45 min obligatoire. Fractionnable en 15 + 30 min (dans cet ordre).'),
  (v_formation, v_module, 'qcm', 'La pause obligatoire après 4h30 de conduite est de :',
   '[{"id":"a","label":"15 minutes","is_correct":false},{"id":"b","label":"30 minutes","is_correct":false},{"id":"c","label":"45 minutes","is_correct":true},{"id":"d","label":"60 minutes","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-04','lecon-2','pause'], 'mft-2026-gotrm:bc01-04-v3:l2:q2', true,
   'Art. 7 R561 : pause 45 minutes minimum, ininterrompue ou fractionnée 15 + 30 (ordre obligatoire).'),
  (v_formation, v_module, 'qcm', 'Le fractionnement de la pause obligatoire doit être :',
   '[{"id":"a","label":"30 min puis 15 min","is_correct":false},{"id":"b","label":"15 min puis 30 min","is_correct":true},{"id":"c","label":"3 fractions de 15 min","is_correct":false},{"id":"d","label":"2 fractions de 22 min","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-04','lecon-2','fractionnement'], 'mft-2026-gotrm:bc01-04-v3:l2:q3', true,
   'Ordre obligatoire : **15 min PUIS 30 min**. L''inverse (30 + 15) est non conforme. Ne pas fractionner en 3.'),
  (v_formation, v_module, 'qcm', 'La conduite quotidienne maximale standard est de :',
   '[{"id":"a","label":"8 heures","is_correct":false},{"id":"b","label":"9 heures","is_correct":true},{"id":"c","label":"10 heures","is_correct":false},{"id":"d","label":"11 heures","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-04','lecon-2','conduite-quotidienne'], 'mft-2026-gotrm:bc01-04-v3:l2:q4', true,
   'Art. 6.1 R561 : 9 heures conduite quotidienne, extension 10h **max 2 fois par semaine** (lundi-dimanche).'),
  (v_formation, v_module, 'qcm', 'L''extension de conduite quotidienne à 10h est autorisée :',
   '[{"id":"a","label":"Tous les jours","is_correct":false},{"id":"b","label":"3 fois par semaine","is_correct":false},{"id":"c","label":"2 fois par semaine","is_correct":true},{"id":"d","label":"Jamais","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-04','lecon-2','extension'], 'mft-2026-gotrm:bc01-04-v3:l2:q5', true,
   'Art. 6.1 alinéa 2 R561 : extension 10h max 2 fois par semaine de référence (lundi 0h - dimanche 24h).'),
  (v_formation, v_module, 'qcm', 'La conduite hebdomadaire maximale est de :',
   '[{"id":"a","label":"40 heures","is_correct":false},{"id":"b","label":"48 heures","is_correct":false},{"id":"c","label":"56 heures","is_correct":true},{"id":"d","label":"60 heures","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-04','lecon-2','hebdo'], 'mft-2026-gotrm:bc01-04-v3:l2:q6', true,
   'Art. 6.2 R561 : 56 heures conduite par semaine de référence (lundi-dimanche). 48h = durée du travail (Code du travail).'),
  (v_formation, v_module, 'qcm', 'La conduite bi-hebdomadaire (2 sem. consécutives) ne peut dépasser :',
   '[{"id":"a","label":"80 heures","is_correct":false},{"id":"b","label":"90 heures","is_correct":true},{"id":"c","label":"100 heures","is_correct":false},{"id":"d","label":"112 heures","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-04','lecon-2','bihebdo'], 'mft-2026-gotrm:bc01-04-v3:l2:q7', true,
   'Art. 6.3 R561 : 90 heures sur 2 semaines consécutives. Si S1 = 56h, S2 limitée à 34h (90 - 56).'),
  (v_formation, v_module, 'qcm', 'Le repos quotidien normal est de :',
   '[{"id":"a","label":"8 heures","is_correct":false},{"id":"b","label":"9 heures","is_correct":false},{"id":"c","label":"11 heures consécutives","is_correct":true},{"id":"d","label":"24 heures","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-04','lecon-2','repos-quotidien'], 'mft-2026-gotrm:bc01-04-v3:l2:q8', true,
   'Art. 8.2 R561 : 11 heures consécutives par fenêtre de 24h. Réduit possible 9h (3x max/sem). Fractionné 3h + 9h = total 12h.'),
  (v_formation, v_module, 'qcm', 'Le repos quotidien réduit (9h) est autorisé maximum :',
   '[{"id":"a","label":"1 fois par semaine","is_correct":false},{"id":"b","label":"3 fois entre 2 repos hebdomadaires","is_correct":true},{"id":"c","label":"5 fois par semaine","is_correct":false},{"id":"d","label":"Tous les jours","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-04','lecon-2','repos-reduit'], 'mft-2026-gotrm:bc01-04-v3:l2:q9', true,
   'Art. 8.4 R561 : repos réduit 9h, max 3 fois entre 2 repos hebdomadaires. Pas de compensation due (contrairement au repos hebdo réduit).'),
  (v_formation, v_module, 'qcm', 'Le repos quotidien fractionné doit totaliser :',
   '[{"id":"a","label":"9 heures","is_correct":false},{"id":"b","label":"11 heures","is_correct":false},{"id":"c","label":"12 heures (3h + 9h)","is_correct":true},{"id":"d","label":"24 heures","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-04','lecon-2','fractionne'], 'mft-2026-gotrm:bc01-04-v3:l2:q10', true,
   'Repos fractionné : 3h consécutives + 9h consécutives = total 12h. Le R561 « pénalise » le fractionnement par 1h supplémentaire.'),
  (v_formation, v_module, 'qcm', 'En équipage, le repos quotidien minimal est :',
   '[{"id":"a","label":"11h sur 24h (identique seul)","is_correct":false},{"id":"b","label":"9h consécutives sur 30h","is_correct":true},{"id":"c","label":"6h consécutives","is_correct":false},{"id":"d","label":"Pas de repos","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-04','lecon-2','equipage'], 'mft-2026-gotrm:bc01-04-v3:l2:q11', true,
   'Art. 8 R561 équipage : 9h consécutives dans une fenêtre de 30h. Permet de couvrir 1 250 km en 24h consécutives (Paris-Madrid).'),
  (v_formation, v_module, 'qcm', 'Un conducteur a fait 9h conduite lundi, 9h mardi, 10h mercredi, 10h jeudi. Conduite max possible vendredi :',
   '[{"id":"a","label":"9h (avec extension)","is_correct":false},{"id":"b","label":"9h (sans extension, 2 déjà utilisées)","is_correct":true},{"id":"c","label":"10h","is_correct":false},{"id":"d","label":"Aucune","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-04','lecon-2','calcul'], 'mft-2026-gotrm:bc01-04-v3:l2:q12', true,
   'Extensions à 10h utilisées mercredi + jeudi = 2/2. Vendredi : retour à 9h max. Cumul Lu-Je = 38h, soit 18h dispo (56-38) mais plafonné par quotidien 9h.');

  -- ===== LEÇON 3 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'Le repos hebdomadaire normal est de :',
   '[{"id":"a","label":"24 heures","is_correct":false},{"id":"b","label":"36 heures","is_correct":false},{"id":"c","label":"45 heures consécutives","is_correct":true},{"id":"d","label":"72 heures","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-04','lecon-3','repos-normal'], 'mft-2026-gotrm:bc01-04-v3:l3:q1', true,
   'Art. 8.6 R561 : repos hebdo normal = 45h consécutives. Réduit = 24h consécutives + compensation.'),
  (v_formation, v_module, 'qcm', 'Le repos hebdomadaire réduit minimum est de :',
   '[{"id":"a","label":"12 heures","is_correct":false},{"id":"b","label":"24 heures consécutives","is_correct":true},{"id":"c","label":"36 heures","is_correct":false},{"id":"d","label":"45 heures","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-04','lecon-3','repos-reduit'], 'mft-2026-gotrm:bc01-04-v3:l3:q2', true,
   'Art. 8.6 R561 : repos hebdo réduit = 24h consécutives + compensation 21h (différence 45 - 24) avant fin de la 3e semaine suivante.'),
  (v_formation, v_module, 'qcm', 'La compensation pour un repos hebdomadaire réduit est de :',
   '[{"id":"a","label":"9 heures","is_correct":false},{"id":"b","label":"21 heures","is_correct":true},{"id":"c","label":"24 heures","is_correct":false},{"id":"d","label":"45 heures","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-04','lecon-3','compensation'], 'mft-2026-gotrm:bc01-04-v3:l3:q3', true,
   'Compensation = 45 - 24 = **21h** à rattacher à un autre repos d''au moins 9h (consécutives), avant fin 3e semaine suivante.'),
  (v_formation, v_module, 'qcm', 'La compensation doit être prise avant :',
   '[{"id":"a","label":"La fin de la semaine suivante","is_correct":false},{"id":"b","label":"La fin de la 3e semaine suivante","is_correct":true},{"id":"c","label":"La fin du mois","is_correct":false},{"id":"d","label":"Pas de délai","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-04','lecon-3','delai'], 'mft-2026-gotrm:bc01-04-v3:l3:q4', true,
   'Art. 8.6 R561 : compensation à prendre avant la fin de la 3e semaine suivant la semaine où le repos a été réduit.'),
  (v_formation, v_module, 'qcm', 'Sur 2 semaines consécutives, le conducteur doit avoir :',
   '[{"id":"a","label":"2 repos réduits","is_correct":false},{"id":"b","label":"Au moins 1 repos hebdo normal de 45h","is_correct":true},{"id":"c","label":"Aucune obligation","is_correct":false},{"id":"d","label":"Toujours des repos normaux","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-04','lecon-3','alternance'], 'mft-2026-gotrm:bc01-04-v3:l3:q5', true,
   'Art. 8.6 R561 : règle d''alternance — sur 2 semaines consécutives, au moins un repos NORMAL (45h). Interdit en transport national de 2 réduits consécutifs.'),
  (v_formation, v_module, 'qcm', 'Depuis août 2020, le repos hebdomadaire NORMAL (45h) :',
   '[{"id":"a","label":"Peut être pris en cabine","is_correct":false},{"id":"b","label":"Doit être pris hors cabine (hôtel ou domicile)","is_correct":true},{"id":"c","label":"Doit être pris au siège","is_correct":false},{"id":"d","label":"Est interdit","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-04','lecon-3','cabine'], 'mft-2026-gotrm:bc01-04-v3:l3:q6', true,
   'Paquet Mobilité I (août 2020) : repos 45h ou tout repos > 45h en compensation **interdit en cabine**. Hôtel, domicile, hébergement adapté payés par employeur.'),
  (v_formation, v_module, 'qcm', 'Le retour 4 semaines (Paquet Mobilité I) impose :',
   '[{"id":"a","label":"Retour véhicule au garage","is_correct":false},{"id":"b","label":"Retour conducteur au domicile / siège max 4 semaines","is_correct":true},{"id":"c","label":"Audit DREAL trimestriel","is_correct":false},{"id":"d","label":"Pause obligatoire 4 semaines","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-04','lecon-3','retour-4-semaines'], 'mft-2026-gotrm:bc01-04-v3:l3:q7', true,
   'Art. 8.8 bis R561 : retour conducteur domicile / siège toutes les 4 semaines max (3 si 2 réduits consécutifs). Sanction 750-1500 € si non respect.'),
  (v_formation, v_module, 'qcm', 'L''article 12 R561 permet :',
   '[{"id":"a","label":"De refuser un transport","is_correct":false},{"id":"b","label":"De déroger pour atteindre un point d''arrêt sûr","is_correct":true},{"id":"c","label":"D''augmenter les amendes","is_correct":false},{"id":"d","label":"D''ignorer le tachygraphe","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-04','lecon-3','derogation'], 'mft-2026-gotrm:bc01-04-v3:l3:q8', true,
   'Art. 12 R561 : dérogation possible pour atteindre un point d''arrêt sûr (aire, parking, hôtel) à condition de ne pas compromettre la sécurité, justifier par écrit et compenser immédiatement.'),
  (v_formation, v_module, 'qcm', 'Le délai max entre 2 repos hebdomadaires (règle des 6 jours) est :',
   '[{"id":"a","label":"96 heures","is_correct":false},{"id":"b","label":"144 heures (6 × 24h)","is_correct":true},{"id":"c","label":"168 heures","is_correct":false},{"id":"d","label":"240 heures","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-04','lecon-3','144h'], 'mft-2026-gotrm:bc01-04-v3:l3:q9', true,
   'Art. 8.6 alinéa 2 R561 : repos hebdo doit débuter au plus tard à la fin de 6 périodes de 24h (= 144h) après la fin du précédent. Au-delà = infraction « démarrage tardif ».'),
  (v_formation, v_module, 'qcm', 'En transport international, 2 repos réduits consécutifs sont :',
   '[{"id":"a","label":"Toujours interdits","is_correct":false},{"id":"b","label":"Autorisés sous conditions strictes (Paquet Mobilité I)","is_correct":true},{"id":"c","label":"Autorisés librement","is_correct":false},{"id":"d","label":"Sanctionnés pénalement","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-04','lecon-3','international'], 'mft-2026-gotrm:bc01-04-v3:l3:q10', true,
   'Art. 8.6 quater R561 (Paquet Mobilité I) : 2 réduits consécutifs autorisés en international si compensation intégrale + repos normal en S+1 ou S+2 + conducteur > 50 % du temps à l''étranger.'),
  (v_formation, v_module, 'qcm', 'Une amende pour repos 45h pris en cabine est typiquement de :',
   '[{"id":"a","label":"135 €","is_correct":false},{"id":"b","label":"750 €","is_correct":false},{"id":"c","label":"1 500 € (très sérieuse)","is_correct":true},{"id":"d","label":"10 000 €","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-04','lecon-3','sanction'], 'mft-2026-gotrm:bc01-04-v3:l3:q11', true,
   'Repos 45h cabine = infraction très sérieuse (VSI) = 1 500 € conducteur + 1 500 € entreprise (responsabilité solidaire art. 10 R561).'),
  (v_formation, v_module, 'qcm', 'Le repos compensatoire 21h doit être :',
   '[{"id":"a","label":"Isolé","is_correct":false},{"id":"b","label":"Rattaché à un autre repos d''au moins 9h","is_correct":true},{"id":"c","label":"Pris en plusieurs fois","is_correct":false},{"id":"d","label":"En cabine","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-04','lecon-3','rattachement'], 'mft-2026-gotrm:bc01-04-v3:l3:q12', true,
   'Compensation = 21h consécutives, **rattachées** à un autre repos d''au moins 9h (typiquement repos normal 45h + 21h = 66h consécutives au domicile).');

  -- ===== LEÇON 4 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'Le tachygraphe intelligent 2e génération est obligatoire depuis :',
   '[{"id":"a","label":"2006","is_correct":false},{"id":"b","label":"15 juin 2019","is_correct":true},{"id":"c","label":"2010","is_correct":false},{"id":"d","label":"2025","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-04','lecon-4','tachy-intelligent'], 'mft-2026-gotrm:bc01-04-v3:l4:q1', true,
   'Tachygraphe intelligent 2e gén. obligatoire pour véhicules neufs depuis 15 juin 2019. v2 (frontières + cabotage automatiques) depuis août 2023.'),
  (v_formation, v_module, 'qcm', 'La carte conducteur a une validité de :',
   '[{"id":"a","label":"1 an","is_correct":false},{"id":"b","label":"3 ans","is_correct":false},{"id":"c","label":"5 ans","is_correct":true},{"id":"d","label":"10 ans","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-04','lecon-4','carte"'], 'mft-2026-gotrm:bc01-04-v3:l4:q2', true,
   'Carte conducteur : validité 5 ans. À renouveler 6 mois avant expiration. Émise par CHRONOSERVICES (IN Groupe en France). Coût ~70 €.'),
  (v_formation, v_module, 'qcm', 'La carte conducteur conserve combien de jours d''activité ?',
   '[{"id":"a","label":"7 jours","is_correct":false},{"id":"b","label":"14 jours","is_correct":false},{"id":"c","label":"28 jours","is_correct":true},{"id":"d","label":"90 jours","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-04','lecon-4','memoire-carte'], 'mft-2026-gotrm:bc01-04-v3:l4:q3', true,
   'Mémoire carte conducteur = 28 jours derniers d''activité. Téléchargement obligatoire tous les 28 jours minimum.'),
  (v_formation, v_module, 'qcm', 'La mémoire véhicule (VU) doit être téléchargée au moins :',
   '[{"id":"a","label":"Tous les 28 jours","is_correct":false},{"id":"b","label":"Tous les 60 jours","is_correct":false},{"id":"c","label":"Tous les 90 jours","is_correct":true},{"id":"d","label":"Tous les ans","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-04','lecon-4','memoire-vu'], 'mft-2026-gotrm:bc01-04-v3:l4:q4', true,
   'Mémoire véhicule (VU) = 90 jours min. Téléchargement avec carte entreprise. Conservation 1 an minimum (3 ans recommandé).'),
  (v_formation, v_module, 'qcm', 'Les modes du tachygraphe sont :',
   '[{"id":"a","label":"2 (conduite/repos)","is_correct":false},{"id":"b","label":"4 (conduite/travail/disponibilité/repos)","is_correct":true},{"id":"c","label":"6","is_correct":false},{"id":"d","label":"8","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-04','lecon-4','modes'], 'mft-2026-gotrm:bc01-04-v3:l4:q5', true,
   '4 modes : 1 = conduite (auto), 2 = travail (chargement), 3 = disponibilité (attente quai/équipage), 4 = repos (couchette/hôtel).'),
  (v_formation, v_module, 'qcm', 'Le mode 3 « disponibilité » correspond à :',
   '[{"id":"a","label":"Conduite active","is_correct":false},{"id":"b","label":"Repos effectif","is_correct":false},{"id":"c","label":"Attente disponible (quai, ferry, équipage)","is_correct":true},{"id":"d","label":"Pause repas","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-04','lecon-4','mode-3'], 'mft-2026-gotrm:bc01-04-v3:l4:q6', true,
   'Mode 3 = disponibilité : conducteur en attente, prêt à reprendre. Ni temps de travail ni repos. Ex : équipage en cabine non couché, attente ferry, attente quai.'),
  (v_formation, v_module, 'qcm', 'En cas de perte de carte conducteur, la déclaration doit être faite sous :',
   '[{"id":"a","label":"24 heures","is_correct":false},{"id":"b","label":"7 jours","is_correct":true},{"id":"c","label":"30 jours","is_correct":false},{"id":"d","label":"Aucun délai","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-04','lecon-4','carte-perdue'], 'mft-2026-gotrm:bc01-04-v3:l4:q7', true,
   'Déclaration sous 7 jours chez CHRONOSERVICES (chronoservices.fr). Conduite limitée à 15 jours sans carte avec tickets papier (départ + arrivée).'),
  (v_formation, v_module, 'qcm', 'Une infraction « mineure » (MI) au R561 est sanctionnée par :',
   '[{"id":"a","label":"Avertissement","is_correct":false},{"id":"b","label":"135 € forfaitaire","is_correct":true},{"id":"c","label":"750 €","is_correct":false},{"id":"d","label":"3 750 €","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-04','lecon-4','mi'], 'mft-2026-gotrm:bc01-04-v3:l4:q8', true,
   'Infraction mineure (MI) = 135 € forfaitaires (ex : conduite continue 4h45, repos 10h30 au lieu de 11h, carte oubliée occasionnellement).'),
  (v_formation, v_module, 'qcm', 'Une infraction « très sérieuse » (VSI) est sanctionnée par :',
   '[{"id":"a","label":"135 €","is_correct":false},{"id":"b","label":"750 €","is_correct":false},{"id":"c","label":"1 500 €","is_correct":true},{"id":"d","label":"3 750 €","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-04','lecon-4','vsi'], 'mft-2026-gotrm:bc01-04-v3:l4:q9', true,
   'VSI = 1 500 € (ex : conduite quotidienne > 11h, repos quotidien < 7h, repos 45h en cabine, conduite continue > 6h).'),
  (v_formation, v_module, 'qcm', 'L''article 10 R561 prévoit :',
   '[{"id":"a","label":"Une amnistie","is_correct":false},{"id":"b","label":"La responsabilité solidaire de l''entreprise","is_correct":true},{"id":"c","label":"Une dérogation totale","is_correct":false},{"id":"d","label":"L''interdiction du travail de nuit","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-04','lecon-4','responsabilite'], 'mft-2026-gotrm:bc01-04-v3:l4:q10', true,
   'Art. 10 R561 : « L''entreprise organise le travail de manière à respecter le règlement. » Présomption de responsabilité solidaire ⇒ amende doublée (conducteur + entreprise). Exonération possible -30 % à -50 % si diligence prouvée.'),
  (v_formation, v_module, 'qcm', 'La falsification de tachygraphe (MSI) :',
   '[{"id":"a","label":"Est tolérée occasionnellement","is_correct":false},{"id":"b","label":"Donne lieu à 3 750 € + poursuites pénales","is_correct":true},{"id":"c","label":"Est sanctionnée d''un avertissement","is_correct":false},{"id":"d","label":"N''est pas une infraction","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-04','lecon-4','falsification'], 'mft-2026-gotrm:bc01-04-v3:l4:q11', true,
   'Art. L. 3315-3 C. transports : falsification = MSI 3 750 € + poursuites pénales (jusqu''à 6 mois prison + 3 750 € pénal). Y compris aimants détournés du capteur.'),
  (v_formation, v_module, 'qcm', 'La défense d''une infraction art. 12 R561 nécessite :',
   '[{"id":"a","label":"Aucune justification","is_correct":false},{"id":"b","label":"Justification écrite + compensation immédiate","is_correct":true},{"id":"c","label":"Un accord employeur préalable","is_correct":false},{"id":"d","label":"L''accord du contrôleur","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-04','lecon-4','art-12'], 'mft-2026-gotrm:bc01-04-v3:l4:q12', true,
   'Art. 12 R561 : justification écrite (mention sur disque/tachy : « art. 12 - circonstances exceptionnelles »), preuves (photos bouchon, GPS), compensation immédiate du dépassement, et sécurité non compromise.');

  -- ===== 8 QR (cas pratiques métier, max_score 5-7) =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qr',
   'Une PME exploite 4 véhicules : VUL 3,2 t (transport national uniquement), VUL 2,8 t (transport intra-UE Belgique-Pays-Bas), Porteur 12 t (transport France-Allemagne-Pologne), Semi 40 t (transport France-Russie via Pologne-Biélorussie). Pour chaque véhicule, indiquez : (1) la réglementation applicable (R561, AETR, ou les deux), (2) le tachygraphe requis, (3) les obligations Paquet Mobilité I à anticiper en 2026.',
   NULL, 6, 'moyen', ARRAY['gotrm','bc01-04','qr','cadre','application'], 'mft-2026-gotrm:bc01-04-v3:qr1', true,
   'Véhicule 1 (VUL 3,2 t national) : actuellement non soumis au R561 (PTAC ≤ 3,5 t et national). Pas de tachygraphe obligatoire. Pas d''impact Paquet Mobilité I si reste national.\n\nVéhicule 2 (VUL 2,8 t intra-UE) : à partir du 1/7/2026, soumis au R561 (Paquet Mobilité I étend aux VUL > 2,5 t en transport international). Installation tachygraphe intelligent + carte conducteur obligatoires.\n\nVéhicule 3 (Porteur 12 t intra-UE) : R561/2006 sur tout le trajet (FR-DE-PL tous UE). Tachygraphe numérique intelligent 2e génération. Retour 4 semaines obligatoire, repos 45h hors cabine.\n\nVéhicule 4 (Semi 40 t France-Russie) : R561 sur tronçon UE (FR-DE-PL), puis AETR sur tronçon Biélorussie-Russie. Tachygraphe intelligent v2 (reconnaissance frontière auto depuis août 2023). Retour 4 semaines obligatoire (calcul difficile en Russie : prévoir relais ou retour véhicule à l''UE).'),

  (v_formation, v_module, 'qr',
   'Un conducteur démarre lundi 5h00 de Paris pour livrer à Toulouse (680 km, 8h conduite estimée), avec 1h chargement Paris et 2h déchargement Toulouse. Décomposez la journée légale en respectant strictement le R561 et indiquez l''heure réelle de fin de service. Si la journée n''est pas faisable en respectant R561, proposez une alternative.',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-04','qr','calcul','journee'], 'mft-2026-gotrm:bc01-04-v3:qr2', true,
   'Décomposition stricte R561 :\n- 5h00-5h30 : prise de service (mode 2)\n- 5h30-6h30 : chargement Paris (mode 2, 1h)\n- 6h30-11h00 : conduite continue 4h30 (mode 1, plafond)\n- 11h00-11h45 : pause obligatoire 45 min (mode 4 ou 3)\n- 11h45-14h45 : conduite 3h\n- 14h45-15h45 : pause repas 1h (CCN, mode 4)\n- 15h45-17h15 : conduite 1h30 (cumul 9h, plafond standard)\n- 17h15-19h15 : déchargement Toulouse 2h (mode 2)\n- **Fin de service 19h15** = amplitude 14h15 (limite CCN dérogation)\n\n**Légalité** : conformité limite. Conduite 9h = plafond standard. Amplitude 14h15 = plafond CCN dérogation. À éviter en routine.\n\n**Alternative recommandée** : programmer un découcher à mi-trajet (Limoges, ~360 km) avec chargement Paris J0 après-midi, départ J0 soir 16h, conduite jusqu''à Limoges (4h30, 21h arrivée), repos 11h, reprise J1 8h pour Toulouse (4h conduite, arrivée 12h, déchargement 14h). Plus serein, marge sécurité, conducteur moins fatigué.'),

  (v_formation, v_module, 'qr',
   'Sur 4 semaines consécutives, un conducteur en transport NATIONAL prend ces repos hebdomadaires : S1 = 45h normal (domicile), S2 = 24h réduit (hôtel), S3 = 24h réduit (cabine), S4 = 45h prévu (domicile). Identifiez TOUTES les infractions, calculez la compensation due et les amendes (employeur + conducteur).',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-04','qr','repos-hebdo','sanctions'], 'mft-2026-gotrm:bc01-04-v3:qr3', true,
   'Infractions identifiées :\n\n1. **Alternance S2/S3** : 2 repos réduits CONSÉCUTIFS en transport national = interdit (art. 8.6 R561). En national, cette dérogation Paquet Mobilité n''est pas autorisée. ⇒ infraction très sérieuse (VSI) : 1 500 € employeur + 1 500 € conducteur.\n\n2. **Repos S3 24h pris en cabine** : cabine autorisée pour repos réduit. Pas d''infraction sur ce point.\n\nCompensation due :\n- S2 : 21h à prendre avant fin S5.\n- S3 : 21h à prendre avant fin S6.\n- **Total compensation 42h** à intégrer en S4 ou suivantes.\n- Recommandation : prendre 45h normal + 21h S2 = 66h consécutives en S4 (couvre alternance + 1 compensation).\n- Reste compensation S3 (21h) à prendre avant fin S6.\n\nAmendes totales (alternance) : 1 500 + 1 500 = **3 000 €** pour la PME. Si récidive sur autres conducteurs ⇒ inscription registre national des sanctions et majoration possible.\n\nMesures correctives : auditer les 6 derniers mois avec TachoScan, former les conducteurs FCO sur alternance, mettre en place un planning automatique avec alerte « 2 réduits consécutifs interdits ».'),

  (v_formation, v_module, 'qr',
   'Un conducteur perd sa carte tachygraphe le mardi matin lors d''un arrêt sur aire d''autoroute (vol probable). Il doit livrer le jeudi en Italie. Détaillez la procédure complète à suivre par le conducteur ET par l''entreprise, les délais légaux, et les documents à conserver. Précisez quelles options s''offrent à l''entreprise pour ne pas perdre la livraison.',
   NULL, 6, 'moyen', ARRAY['gotrm','bc01-04','qr','carte','procedure'], 'mft-2026-gotrm:bc01-04-v3:qr4', true,
   'Procédure conducteur :\n1. Déclaration de vol immédiate (en gendarmerie de l''aire ou commissariat le plus proche).\n2. Photographier le récépissé de plainte.\n3. Déclaration en ligne sous 7 jours sur chronoservices.fr (procédure perte/vol).\n4. Demande de carte de remplacement (délai 2-3 semaines).\n\nProcédure entreprise :\n1. Récupérer le récépissé de plainte du conducteur.\n2. Contacter CHRONOSERVICES pour confirmer la procédure.\n3. Imprimer 2 tickets papier par jour de conduite (départ + fin) avec mentions manuscrites : nom, immatriculation, kilométrage, signature.\n4. Conserver tickets dans dossier conducteur (3 ans).\n5. Notifier le client du risque de retard.\n\nDélais légaux :\n- Déclaration : 7 jours.\n- Conduite limite SANS carte : **15 jours maximum** avec tickets papier.\n- Au-delà : conduite interdite, immobilisation véhicule.\n\nDocuments à conserver : récépissé plainte, demande CHRONOSERVICES (avec n° de suivi), tickets papier signés, notifications client, fiche de paie indemnisation conducteur.\n\nOptions livraison :\n- Option A : conducteur conduit avec tickets papier (légal 15 j) ⇒ livraison maintenue.\n- Option B : remplacer le conducteur par un collègue (autre carte) ⇒ idéal si dispo.\n- Option C : sous-traiter la livraison à un partenaire (perte marge mais évite litige client).\n\nCoût opérationnel : ~70 € carte de remplacement + ~50 € admin entreprise + risque livraison perdue (qq milliers €). À l''avenir : assurance carte (incluse RCCT premium ~50 €/an).'),

  (v_formation, v_module, 'qr',
   'Audit DREAL en entreprise : sur 6 mois, le contrôleur identifie 18 infractions au tachygraphe pour 1 conducteur unique : 8 mineures (135 €), 6 sérieuses (750 €), 3 très sérieuses (1 500 €), 1 plus sérieuse (3 750 €). Calculez le redressement total (conducteur + entreprise), explicitez la responsabilité solidaire, et proposez 5 mesures correctives concrètes pour éviter une récidive.',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-04','qr','audit','correctives'], 'mft-2026-gotrm:bc01-04-v3:qr5', true,
   'Calcul amendes conducteur :\n- 8 × 135 = 1 080 €\n- 6 × 750 = 4 500 €\n- 3 × 1 500 = 4 500 €\n- 1 × 3 750 = 3 750 €\n- **Sous-total conducteur** : **13 830 €**.\n\nResponsabilité solidaire (art. 10 R561) : l''entreprise est présumée responsable car elle organise le travail. ⇒ Amende identique pour l''entreprise : **13 830 €**.\n\n**Total brut redressement** : **27 660 €** + intérêts si paiement > 30 jours.\n\nExonération possible (-30 % à -50 % entreprise) si l''entreprise prouve diligence raisonnable :\n- Formation FCO récente du conducteur.\n- Planning conforme R561 (audit logiciel).\n- Tableau de bord mensuel des disques.\n- Mesures internes (avertissement, suspension prime).\n\n5 mesures correctives concrètes :\n\n1. **Logiciel TachoScan** ou VDO Tisplus (~80 €/mois) : analyse mensuelle automatique des cartes + mémoires véhicule + alerte anomalies. ROI < 1 mois.\n\n2. **Tableau de bord exploitation** : Excel ou TMS avec colonnes (jour, conduite réelle, repos, infractions). Alerte rouge si > seuil. Revue hebdomadaire avec conducteur.\n\n3. **Formation FCO interne** : 1 session mensuelle 1h sur un thème R561 (pause, repos hebdo, retour 4 semaines). Documentée dans dossier individuel.\n\n4. **Convention atelier agréé** : calibration tachygraphe tous les 2 ans (~150 €/véhicule). Prévention infractions techniques.\n\n5. **Procédure formelle** : note de service signée par le conducteur engageant la conformité, suspension de prime variable si infraction sérieuse, FCO supplémentaire si VSI.\n\nROI mesures : coût annuel ~3 000 € (logiciel + atelier + formation) vs économie ~15 000 € amendes évitées par an + protection licence.'),

  (v_formation, v_module, 'qr',
   'Un conducteur en transport intra-UE (France-Allemagne-Pologne) prend ces repos sur 4 semaines : S1 = 45h en cabine (aire d''autoroute), S2 = 24h réduit en cabine (aire), S3 = 24h réduit (hôtel via Booking), S4 = 45h prévu au domicile. Le conducteur n''est pas rentré au domicile depuis 5 semaines. Identifiez les infractions, le coût des amendes et l''obligation employeur retour 4 semaines.',
   NULL, 6, 'difficile', ARRAY['gotrm','bc01-04','qr','cabine','retour'], 'mft-2026-gotrm:bc01-04-v3:qr6', true,
   'Infractions identifiées :\n\n1. **S1 - repos 45h en cabine** : interdit depuis 21 août 2020 (Paquet Mobilité I, art. 8.8). ⇒ infraction très sérieuse (VSI) : 1 500 € conducteur + 1 500 € entreprise = **3 000 €**.\n\n2. **S2 - repos 24h en cabine** : repos hebdo réduit cabine **autorisé** (uniquement les normaux 45h sont interdits). Pas d''infraction sur ce point.\n\n3. **S3 - repos 24h hôtel** : conforme.\n\n4. **Alternance S2/S3** : 2 réduits consécutifs en transport intra-UE = autorisé (art. 8.6 quater R561, Paquet Mobilité I) à condition de :\n   - compensation 21h × 2 = 42h en S4 ou avant.\n   - repos normal en S+1 ou S+2 (S4 = 45h normal prévu, OK).\n   - conducteur > 50 % du temps à l''étranger (à vérifier).\n   ⇒ Pas d''infraction directe SI les conditions sont remplies. Sinon ⇒ VSI.\n\n5. **Retour 4 semaines** (Paquet Mobilité I) : conducteur 5 semaines sans retour ⇒ infraction « retour tardif ». Sanction : 750-1500 € entreprise.\n\n**Total amendes minimum** : 3 000 € (cabine) + 1 500 € (retour tardif) = **4 500 €** + amendes alternance si conditions non remplies.\n\nObligation employeur retour 4 semaines :\n- Organiser le retour du conducteur au siège ou domicile toutes les 4 semaines max (3 si 2 réduits consécutifs).\n- Documenter le retour : tickets péage, position GPS véhicule au domicile, fiche de paie mentionnant repos pris au domicile.\n- Couvrir les frais de retour (carburant, hôtel sur la route, etc.).\n- En cas d''empêchement (livraison urgente, panne) : note écrite avec preuve circonstances exceptionnelles.\n\nMesures correctives :\n- Convention partenariat hôtel (B&B, Premiere Classe) : -30 % tarif négocié.\n- Planning automatique avec alerte « repos 45h prochain - hôtel à réserver ».\n- Politique « 0 cabine 45h » communiquée aux conducteurs.'),

  (v_formation, v_module, 'qr',
   'Un conducteur souhaite invoquer l''article 12 R561 (dérogation point d''arrêt sûr) pour un dépassement de conduite continue de 30 minutes (5h au lieu de 4h30) suite à un embouteillage sur l''A6. Quelles preuves doit-il rassembler ? Comment doit-il manipuler le tachygraphe ? Quelles sont les chances de succès en cas de contrôle DREAL ?',
   NULL, 5, 'moyen', ARRAY['gotrm','bc01-04','qr','article-12','derogation'], 'mft-2026-gotrm:bc01-04-v3:qr7', true,
   'Manipulation tachygraphe :\n1. Au moment où le dépassement devient inévitable (vers 4h25 conduite continue), basculer en mode 1 (conduite) maintenu.\n2. Imprimer un ticket papier dès l''arrivée à l''aire de repos avec mention manuscrite signée : « Article 12 R561 - circonstances exceptionnelles - embouteillage A6 km X - sécurité non compromise - compensation immédiate prise. »\n3. Le tachygraphe enregistrera l''infraction automatiquement, mais la défense art. 12 documentée peut l''annuler.\n\nPreuves à rassembler :\n- Photo de l''embouteillage avec horodatage GPS.\n- Trace GPS du véhicule (vitesse 0 ou très ralenti pendant la période).\n- Communiqué Sytadin / Bison Futé / France Bleu sur l''accident.\n- Ticket de péage A6 avec horaire correspondant.\n- Témoignage radio CB ou message employeur.\n- Compensation prise : pause 75 min au lieu de 45 min (30 min en plus pour compenser).\n\nConditions de succès art. 12 :\n- Sécurité non compromise (pas en hypoglycémie, pas dangereux).\n- Atteindre le point d''arrêt SÛR le plus proche (pas continuer à plein régime).\n- Justification ÉCRITE immédiate (pas a posteriori).\n- Compensation IMMÉDIATE (pas reportée).\n\nChances de succès en cas de contrôle DREAL : **60-70 %** si bien argumenté avec preuves. **30-40 %** si simple déclaration verbale sans preuves. Risque résiduel : 135 € (mineure 30 min) à 750 € (sérieuse) si défense rejetée.\n\nBonne pratique : former les conducteurs à la procédure art. 12 lors de la FCO, fournir un kit défense (carnet de bord, formulaire prérempli, contacts utiles).'),

  (v_formation, v_module, 'qr',
   'Vous êtes responsable d''exploitation d''une PME 8 véhicules. Construisez un PLAN COMPLET de gouvernance R561 sur 12 mois : organisation, outils, processus, indicateurs, formation. Inclure les coûts estimés et le ROI attendu.',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-04','qr','gouvernance','plan'], 'mft-2026-gotrm:bc01-04-v3:qr8', true,
   'Plan gouvernance R561 sur 12 mois (PME 8 véhicules) :\n\n**Phase 1 (M1-M2) - Audit initial**\n- Audit TachoScan sur 6 mois historique (~500 €).\n- Cartographie des infractions par conducteur (typologie, fréquence).\n- Identification des 3 conducteurs à risque + 3 tendances entreprise.\n- Coût Phase 1 : ~1 500 € (audit + temps interne).\n\n**Phase 2 (M3-M4) - Outillage**\n- Installation logiciel TachoScan ou VDO Tisplus (~80 €/mois × 12 = 960 €).\n- Formation 1 personne admin sur le logiciel (~500 €).\n- Création tableau de bord Excel ou intégration TMS.\n- Achat 1 lecteur USB carte conducteur (~150 €) + 1 par véhicule (~120 €).\n- Coût Phase 2 : ~2 600 €.\n\n**Phase 3 (M5-M6) - Processus**\n- Procédure téléchargement : carte conducteur tous les 28 j, mémoire véhicule tous les 90 j.\n- Procédure analyse hebdo des anomalies + revue mensuelle de direction.\n- Convention atelier agréé tachygraphe (~150 €/véhicule × 8 / 2 ans = 600 €/an).\n- Coût Phase 3 : ~700 €.\n\n**Phase 4 (M7-M9) - Formation**\n- 2 sessions internes 2h × 8 conducteurs sur R561 (~500 € coût interne).\n- 1 session FCO renforcée sur Paquet Mobilité I.\n- Note de service signée + dossier individuel par conducteur.\n- Coût Phase 4 : ~1 500 €.\n\n**Phase 5 (M10-M12) - Pilotage**\n- Indicateurs mensuels : nb infractions par conducteur, % compensation à temps, retour 4 semaines respecté, coût des amendes vs année N-1.\n- Cible an 2 : -70 % infractions, -90 % VSI/MSI, 0 amende cabine 45h.\n- Coût Phase 5 : ~500 €.\n\n**Coût total an 1** : ~7 000 €.\n\n**ROI attendu** :\n- Année N-1 (sans plan) : 25 000 € amendes potentielles + 50 000 € risque licence.\n- Année N (avec plan) : 5 000 € amendes résiduelles + 0 € risque licence.\n- **Économie nette an 1 : 18 000 €** = ROI 257 % en 12 mois.\n- Bénéfice indirect : image de pro, fidélisation conducteurs, sérénité direction.');

  -- =================================================================
  -- QUIZZES (4 entraînement + 1 examen blanc module)
  -- =================================================================

  -- Quiz 1 — Cadre R561/AETR
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Cadre R561/AETR — Quiz',
          'Quiz d''entraînement (12 questions) sur le règlement (CE) 561/2006, l''accord AETR, le champ d''application, l''articulation avec le droit français et le Paquet Mobilité I.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-04-v3:l1:%';

  -- Quiz 2 — Temps de conduite et repos quotidien
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Temps de conduite et repos quotidien — Quiz',
          'Quiz d''entraînement (12 questions) sur la conduite continue 4h30, conduite quotidienne 9h/10h, hebdo 56h, bi-hebdo 90h, repos quotidien 11h/9h, équipage.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-04-v3:l2:%';

  -- Quiz 3 — Repos hebdomadaires et dérogations
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Repos hebdomadaires et dérogations — Quiz',
          'Quiz d''entraînement (12 questions) sur le repos hebdo normal 45h, réduit 24h, compensation 21h, alternance, retour 4 semaines, interdiction cabine et art. 12 R561.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-04-v3:l3:%';

  -- Quiz 4 — Chronotachygraphe et contrôles
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Chronotachygraphe et contrôles — Quiz',
          'Quiz d''entraînement (12 questions) sur les générations de tachygraphe, carte conducteur, 4 modes, téléchargement 28/90 j, niveaux d''infractions et art. 10 (responsabilité solidaire).',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-04-v3:l4:%';

  -- Examen blanc module — 15 QCM transversaux + 5 QR cas pratique
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold, is_mock_exam)
  VALUES (v_module, 'Examen blanc — BC01-04 Réglementation sociale européenne',
          'Examen blanc reproduisant les conditions de l''examen RNCP : 15 QCM transversaux (4 leçons) + 5 QR cas pratiques métier, durée 60 min, seuil 50 %.',
          'examen', 3600, 50, true)
  RETURNING id INTO v_quiz_eb;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref IN (
     -- 4 QCM Leçon 1
     'mft-2026-gotrm:bc01-04-v3:l1:q1','mft-2026-gotrm:bc01-04-v3:l1:q2',
     'mft-2026-gotrm:bc01-04-v3:l1:q5','mft-2026-gotrm:bc01-04-v3:l1:q7',
     -- 4 QCM Leçon 2
     'mft-2026-gotrm:bc01-04-v3:l2:q1','mft-2026-gotrm:bc01-04-v3:l2:q4',
     'mft-2026-gotrm:bc01-04-v3:l2:q6','mft-2026-gotrm:bc01-04-v3:l2:q8',
     -- 4 QCM Leçon 3
     'mft-2026-gotrm:bc01-04-v3:l3:q1','mft-2026-gotrm:bc01-04-v3:l3:q3',
     'mft-2026-gotrm:bc01-04-v3:l3:q5','mft-2026-gotrm:bc01-04-v3:l3:q6',
     -- 3 QCM Leçon 4
     'mft-2026-gotrm:bc01-04-v3:l4:q3','mft-2026-gotrm:bc01-04-v3:l4:q4',
     'mft-2026-gotrm:bc01-04-v3:l4:q10',
     -- 5 QR (cas pratiques transversaux)
     'mft-2026-gotrm:bc01-04-v3:qr1','mft-2026-gotrm:bc01-04-v3:qr2',
     'mft-2026-gotrm:bc01-04-v3:qr3','mft-2026-gotrm:bc01-04-v3:qr5',
     'mft-2026-gotrm:bc01-04-v3:qr8'
   );

  RAISE NOTICE '✓ GOTRM BC01-04 v3 dense importé : 4 leçons (cadre R561/AETR, conduite/pauses/repos quotidien, repos hebdo/dérogations, tachygraphe/contrôles), 48 QCM, 8 QR cas pratiques métier, 5 quiz (4 entraînement + 1 examen blanc 15 QCM + 5 QR / 60 min).';
END $bc01_04_v3$;

