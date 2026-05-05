-- =====================================================================
-- GOTRM (RNCP 40990) — BC03-02 : RSE, transition énergétique et rentabilité
-- Démarche RSE, énergies alternatives, ZFE, KPI rentabilité durable.
-- =====================================================================

DO $bc03_02$
DECLARE
  v_formation uuid; v_bloc int; v_module uuid;
  v_lesson_1 uuid; v_lesson_2 uuid; v_lesson_3 uuid; v_lesson_4 uuid;
  v_quiz_1 uuid; v_quiz_2 uuid; v_quiz_3 uuid; v_quiz_4 uuid; v_quiz_eb uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc.'; END IF;

  DELETE FROM public.modules WHERE slug = 'gotrm-bc03-02-rse-transition-energetique';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'BC03-02 — Démarche RSE, transition énergétique et KPI rentabilité',
    'gotrm-bc03-02-rse-transition-energetique', v_bloc,
    'Démarche RSE complète, énergies alternatives (électrique, gaz, hydrogène), ZFE, et pilotage de la rentabilité durable.',
    'intermediaire', 150, 140
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 140, true) ON CONFLICT DO NOTHING;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc03-02:%';

  -- =================================================================
  -- LEÇON 1 — Démarche RSE en transport
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Démarche RSE complète en transport',
    'gotrm-bc03-02-01-rse-demarche', 1, 40,
$lesson1$
# Démarche RSE complète en transport

La RSE (Responsabilité Sociétale des Entreprises) n'est plus une option — c'est une exigence des chargeurs grands comptes, un levier de différenciation et un avantage concurrentiel. Comprendre les piliers et les démarches concrètes est essentiel.

> 🎯 **Objectifs de la leçon**
>
> - Maîtriser les **3 piliers** de la RSE.
> - Connaître les **certifications** sectorielles.
> - Construire une **démarche** progressive.
> - Mesurer le **ROI RSE**.

---

## 1. Les 3 piliers de la RSE

| Pilier | Domaine |
|---|---|
| **Environnemental** | Émissions CO2, énergie, déchets |
| **Social** | Conditions de travail, formation, dialogue social |
| **Gouvernance** | Éthique, transparence, parties prenantes |

### 1.1 Pilier environnemental

| Levier | Action |
|---|---|
| Émissions CO2 | Mesure, réduction, compensation |
| Consommation carburant | Éco-conduite, véhicules récents |
| Énergies alternatives | Électrique, gaz, hydrogène |
| Gestion des déchets | Recyclage, réduction, économie circulaire |
| Consommation énergétique | Locaux, équipements |

### 1.2 Pilier social

| Levier | Action |
|---|---|
| Conditions de travail | Salaires, ergonomie, sécurité |
| Formation continue | Plan annuel, polyvalence |
| Diversité et inclusion | Égalité H/F, handicap |
| Dialogue social | CSE, accords d'entreprise |
| Bien-être au travail | Aménagements, écoute |

### 1.3 Pilier gouvernance

| Levier | Action |
|---|---|
| Éthique | Charte, code de déontologie |
| Transparence | Reporting, communication |
| Lutte anti-corruption | Sapin 2, cadeaux, conflits d'intérêts |
| Achats responsables | Sélection sous-traitants |
| Engagement parties prenantes | Clients, fournisseurs, territoires |

---

## 2. Les certifications RSE sectorielles

### 2.1 ISO 26000

Norme internationale de référence (non certifiable). Sert de **guide de bonnes pratiques** sur les 7 questions centrales : gouvernance, droits humains, relations et conditions de travail, environnement, loyauté des pratiques, questions relatives aux consommateurs, communautés et développement local.

### 2.2 ISO 14001 (environnement)

Système de management environnemental certifiable :
- Engagement de la direction
- Identification des aspects environnementaux
- Conformité réglementaire
- Programmes d'amélioration continue
- Audit annuel

### 2.3 Objectif CO2 (FNTR + ADEME)

Charte volontaire spécifique au transport routier de marchandises :
- Engagement chiffré sur 3 ans
- Plan d'action en 4 axes (véhicules, conducteurs, organisation, énergie)
- Suivi annuel
- 1 600+ entreprises signataires en 2025

### 2.4 Label Engagement RSE

Certification plus récente (AFNOR), évolutive selon niveaux :
- Bronze (premières actions)
- Argent (démarche structurée)
- Or (excellence)
- Audit tous les 3 ans

### 2.5 EcoVadis

Évaluation par cabinet international, demandée par les chargeurs grands comptes :
- Note sur 100
- Niveaux : platinum, gold, silver, bronze
- Renouvellement annuel
- Critère discriminant pour appels d'offres internationaux

---

## 3. Construire une démarche progressive

### 3.1 Phase 1 — Diagnostic (M1-M3)

Actions :
- Bilan carbone simplifié (Scope 1, 2, 3)
- Audit social (conditions, climat, formation)
- Audit gouvernance (procédures, chartes)
- Identification des 5-7 enjeux prioritaires

Outils gratuits :
- ADEME Bilan Carbone
- Outil ATEnDi (transport routier)
- Diagnostic RSE FNTR

### 3.2 Phase 2 — Engagement (M3-M6)

Actions :
- Charte RSE entreprise (1 page)
- Engagements chiffrés (objectifs 3 ans)
- Communication interne et externe
- Désignation d'un référent RSE

### 3.3 Phase 3 — Plan d'action (M6-M12)

Actions concrètes par pilier :
- 5-7 actions prioritaires par pilier
- Indicateurs de mesure
- Échéances et budgets
- Responsables désignés

### 3.4 Phase 4 — Mise en œuvre et suivi (M12+)

- Réunion trimestrielle RSE
- Reporting annuel
- Communication aux parties prenantes
- Ajustement continu

### 3.5 Phase 5 — Certification (M18-M30)

Selon ambition :
- ISO 14001 (environnement)
- Objectif CO2 (transport routier)
- EcoVadis (évaluation grand compte)
- Label RSE AFNOR

---

## 4. Le bilan carbone

### 4.1 Les 3 scopes

| Scope | Définition | Sources principales transport |
|---|---|---|
| **Scope 1** | Émissions directes | Carburant véhicules |
| **Scope 2** | Émissions indirectes énergie | Électricité locaux |
| **Scope 3** | Autres émissions indirectes | Déplacements, achats, sous-traitance |

### 4.2 Calcul indicatif

Pour un porteur 19 t à 28 L/100 km, 110 000 km/an :
- Consommation : 30 800 L de gazole/an
- Facteur d'émission gazole : 2,52 kg CO2eq/L
- Émissions Scope 1 par véhicule : 30 800 × 2,52 = 77 616 kg CO2eq = 77,6 tCO2eq/an

Pour 22 véhicules : 22 × 77,6 = 1 707 tCO2eq/an

### 4.3 Obligations légales

- **BEGES** (Bilan d'Émissions de Gaz à Effet de Serre) : obligatoire pour entreprises > 500 salariés (DROM > 250) et tous les 4 ans, avec Scope 1 et 2 minimum.
- **Loi Grenelle 2** : entreprises > 500 salariés.
- **Loi Climat et Résilience 2021** : étiquette CO2 transports, obligation d'information clients.

---

## 5. ROI de la démarche RSE

### 5.1 Bénéfices tangibles

| Levier | Impact |
|---|---|
| Économies carburant (éco-conduite) | -5 à -12 % carburant = 50-150 k€/an pour 20 véhicules |
| Économies énergie locaux | -10-20 % facture |
| Réduction turnover (climat) | 5-10 % de turnover évité = 30-80 k€/an |
| Argument commercial | +5-15 % de chiffre d''affaires sur les chargeurs RSE |
| Subventions et aides | Suramortissement, ADEME, régionales |

### 5.2 Bénéfices intangibles

- Image de marque renforcée
- Attractivité RH (recrutement facilité)
- Anticipation réglementaire
- Engagement des équipes
- Partenariats avec collectivités

### 5.3 Investissement type

Pour une PME 20 véhicules :
- Diagnostic et certification : 15-25 k€
- Plan d'actions an 1 (formation, équipements) : 30-50 k€
- Communication : 5-10 k€
- Total : 50-85 k€

ROI typique 2-4 ans selon l'agressivité de la démarche.

---

## 6. Cas pratique : démarche RSE pour PME 25 véhicules

**Contexte** : *Trans-Méditerranée* (25 véhicules, 4,8 M€ CA) souhaite engager une démarche RSE structurée pour répondre à la pression de ses 3 plus gros clients.

### Plan 18 mois

**M+1 à M+3 — Diagnostic**
- Bilan Carbone simplifié (cabinet 8 k€)
- Audit social interne
- Identification 5 enjeux prioritaires

**M+4 à M+6 — Engagement**
- Charte RSE adoptée (1 page, signée par direction)
- 7 engagements chiffrés sur 3 ans
- Référent RSE désigné (responsable QHSE à 30 % de son temps)

**M+7 à M+12 — Mise en œuvre**

Pilier environnemental :
- Formation éco-conduite tous conducteurs (5 k€)
- 1 véhicule électrique en pilote (130 k€ net après aides)
- Système télématique avec scoring éco (25 €/véhicule/mois)
- Bilan : -8 % conso, -150 t CO2/an

Pilier social :
- Plan formation 20 h/conducteur (12 k€)
- Prime d'ancienneté +1 % (15 k€/an)
- Aménagement ergonomique vestiaires (8 k€)

Pilier gouvernance :
- Charte achats responsables
- Comité RSE trimestriel
- Communication externe (site web, brochure)

**M+13 à M+18 — Certification**
- Engagement Objectif CO2 (FNTR-ADEME, gratuit)
- Évaluation EcoVadis (3 k€)
- Niveau Bronze obtenu, plan d'action vers Argent

### Budget total an 1 : 60 k€

### Bénéfices attendus an 1

| Bénéfice | Montant |
|---|---|
| Économies carburant (-8 %) | 28 k€ |
| Subventions ADEME véhicule électrique | 50 k€ (one-shot, déjà déduit) |
| Argumentation commerciale (+5 % CA) | 20 k€ |
| Réduction turnover (-3 pts) | 18 k€ |
| Total an 1 | 66 k€ |

Bénéfice net : 66 - 60 = +6 k€ dès an 1 (ROI > 100 % an 1)
Récurrent années suivantes : 50-80 k€/an de bénéfice net.

---

> ✅ **À retenir**
>
> - **3 piliers RSE** : environnemental, social, gouvernance.
> - Certifications : **ISO 14001, Objectif CO2, EcoVadis, Label AFNOR**.
> - Démarche en 5 phases : diagnostic → engagement → plan → mise en œuvre → certification.
> - **Bilan carbone Scope 1/2/3** : Scope 1 = carburant véhicules (~ 77 tCO2/véhicule/an).
> - **ROI 2-4 ans**, mais bénéfices intangibles (image, RH, anticipation réglementaire) majeurs.
$lesson1$,
'3 piliers RSE (environnemental, social, gouvernance), certifications (ISO 14001, Objectif CO2, EcoVadis, Label AFNOR), démarche 5 phases, bilan carbone Scope 1/2/3, ROI 2-4 ans.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Énergies alternatives
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Énergies alternatives : électrique, gaz, hydrogène',
    'gotrm-bc03-02-02-energies-alternatives', 2, 40,
$lesson2$
# Énergies alternatives : électrique, gaz, hydrogène

La transition énergétique du transport routier est en cours. Comprendre les **technologies disponibles**, leurs **avantages**, **limites** et **maturité** est essentiel pour les décisions d'investissement.

> 🎯 **Objectifs de la leçon**
>
> - Connaître les **3 alternatives** principales au diesel.
> - Évaluer **maturité, coûts, autonomie**.
> - Identifier les **aides et subventions**.
> - Construire une **stratégie de transition** progressive.

---

## 1. Le véhicule électrique

### 1.1 Caractéristiques

| Critère | Valeur 2026 |
|---|---|
| Autonomie | 200-450 km (selon batterie) |
| Temps de charge | 1-2 h (charge rapide DC), 8 h (charge lente) |
| Prix d'acquisition | +40-60 % vs diesel équivalent |
| Coût énergie | ~ 0,10-0,15 €/km (électricité industrielle) |
| Émissions Scope 1 | 0 (pas de carburant fossile) |
| Émissions cycle de vie | 30-60 % de moins que diesel |

### 1.2 Avantages

- Zéro émission directe à l'usage
- Coût d'énergie très faible
- Maintenance réduite (moins de pièces mobiles)
- Silencieux (livraisons nocturnes possibles)
- Accès facilité aux ZFE
- Suramortissement fiscal +40 %

### 1.3 Limites

- Autonomie limitée pour longue distance
- Prix d'acquisition élevé
- Infrastructure de recharge à développer
- Charge utile parfois réduite (poids des batteries)
- Maintenance spécialisée

### 1.4 Cas d'usage idéal

- Distribution urbaine et péri-urbaine
- Lignes régulières courtes (< 200 km)
- Tournées avec retour quotidien base
- Zones ZFE imposées

---

## 2. Le véhicule au gaz (GNV / bioGNV)

### 2.1 Caractéristiques

| Critère | Valeur 2026 |
|---|---|
| Autonomie | 350-600 km (GNV comprimé), 800-1 200 km (GNL) |
| Temps de remplissage | 5-15 min |
| Prix d'acquisition | +15-25 % vs diesel |
| Coût énergie | ~ 0,30-0,40 €/km |
| Émissions Scope 1 | -15 à -20 % vs diesel (GNV), -85 % (bioGNV) |

### 2.2 Avantages

- Autonomie comparable au diesel
- Temps de remplissage rapide
- Réseau de stations en croissance (300+ stations en France 2026)
- bioGNV : émissions équivalentes à l'électrique
- Suramortissement fiscal +40 %

### 2.3 Limites

- Coût acquisition supérieur
- Réseau encore limité géographiquement
- Performances thermiques en baisse à froid (GNV comprimé)
- Réservoirs encombrants
- Maintenance spécifique

### 2.4 Cas d'usage idéal

- Lignes régulières moyennes/longues
- Régions avec réseau de stations dense
- Grandes flottes pour amortir l'investissement
- Engagement RSE avec bioGNV (émissions -85 %)

---

## 3. L'hydrogène

### 3.1 Caractéristiques

| Critère | Valeur 2026 |
|---|---|
| Autonomie | 400-800 km |
| Temps de remplissage | 10-15 min |
| Prix d'acquisition | +200-300 % vs diesel (en 2026, en baisse rapide) |
| Coût énergie | ~ 0,80-1,20 €/km (en baisse) |
| Émissions Scope 1 | 0 (pas de combustion) |

### 3.2 Avantages

- Zéro émission directe
- Autonomie proche du diesel
- Temps de remplissage rapide
- Pas de problème de poids (vs électrique)
- Soutien gouvernemental fort (plan H2 France)

### 3.3 Limites

- Technologie naissante (peu de modèles disponibles)
- Prix très élevé
- Réseau de stations très limité (10-20 en France 2026, 100+ prévus à 2030)
- Coût de l'hydrogène vert élevé
- Maintenance spécialisée

### 3.4 Cas d'usage idéal

- Lignes longue distance (> 400 km/jour)
- Volumes importants justifiant station privée
- Engagement RSE fort (image de marque)
- Région avec aides spécifiques (Île-de-France, Occitanie)

---

## 4. Comparaison synthétique

| Critère | Diesel | Électrique | GNV/bioGNV | Hydrogène |
|---|---|---|---|---|
| Maturité | Mature | Mature | Mature | Naissante |
| Autonomie | 1 000 km+ | 200-450 km | 350-1 200 km | 400-800 km |
| Prix d'acquisition | 100 % | +40-60 % | +15-25 % | +200-300 % |
| Coût énergie/km | 0,40 € | 0,12 € | 0,35 € | 1,00 € |
| Émissions CO2 | 100 % | 0 % | 80-15 % | 0 % |
| Réseau | Excellent | Croissant | Bon en croissance | Très limité |
| Maintenance | Standard | Réduite | Spécifique | Spécialisée |

---

## 5. Aides et subventions

### 5.1 Suramortissement fiscal (loi de finances)

| Type véhicule | Suramortissement |
|---|---|
| Tracteurs et porteurs gaz/électrique/hydrogène | +40 % de la valeur d''origine, déductible étalé sur 6 ans |
| Véhicules de PTAC ≥ 2,6 t fonctionnant gaz, électrique, hydrogène | Éligible |

### 5.2 ADEME — Programme « EcoEnergie Transports »

- Aide à l'acquisition de véhicules « propres »
- Montants : 5-25 k€ par véhicule selon type
- Cumulable avec suramortissement
- Conditions : flottes professionnelles, scrappage diesel ancien

### 5.3 Aides régionales

Variables selon régions, par exemple :
- Île-de-France : 10-25 k€/véhicule électrique
- Occitanie : 8-20 k€/véhicule hydrogène
- Hauts-de-France : 5-15 k€/GNV

### 5.4 Avantages de circulation

| Avantage | Détail |
|---|---|
| Vignette Crit'Air | E (électrique), 1 (gaz, hydrogène, hybride rechargeable récent) |
| Accès ZFE | Garanti pour Crit'Air E et 1 |
| Stationnement | Gratuit ou réduit dans certaines villes |
| Voies réservées | Selon municipalités |

---

## 6. Stratégie de transition

### 6.1 Approche progressive recommandée

| Année | Action |
|---|---|
| An 1 | Diagnostic flotte, identification cas d''usage |
| An 1 | 1-2 véhicules pilote (électrique distribution + GNV ligne) |
| An 2 | Évaluation pilote, ajustements |
| An 3-5 | Déploiement progressif (20-30 % parc) |
| An 5-10 | Bascule majoritaire selon maturité technologies |

### 6.2 Critères de choix

| Profil mission | Énergie recommandée |
|---|---|
| Distribution urbaine | Électrique |
| Distribution péri-urbaine | Électrique ou GNV |
| Régional 200-400 km | GNV |
| Régional 400+ km | bioGNV ou hydrogène |
| Longue distance > 600 km/jour | GNV (puis hydrogène à 2030) |

### 6.3 Exemple de plan flottes 25 véhicules

À horizon 2030 :
- 5 véhicules électriques (distribution)
- 12 véhicules GNV/bioGNV (régional)
- 3 véhicules hydrogène (longue distance pilote)
- 5 véhicules diesel (transition, à phaser out)

---

## 7. Cas pratique : choix d'investissement

**Contexte** : *Trans-Atlantique* (15 véhicules) doit renouveler 3 véhicules en 2026. Choix entre 3 électriques, 3 GNV, 3 hydrogène, ou mix.

### Analyse

| Option | Investissement net | Économies/an | Bénéfices image | ROI |
|---|---|---|---|---|
| 3 électriques (distribution) | 3 × 130 k€ = 390 k€ (après aides) | 3 × 20 k€ = 60 k€ | Élevé (ZFE) | 6,5 ans |
| 3 GNV (régional) | 3 × 110 k€ = 330 k€ | 3 × 8 k€ = 24 k€ | Modéré | 14 ans |
| 3 hydrogène (longue distance) | 3 × 280 k€ = 840 k€ | -10 k€/an (coût énergie) | Très élevé | 30+ ans |
| Mix : 1 élec + 1 GNV + 1 H2 | 110 + 110 + 280 = 500 k€ | 20 + 8 - 3 = 25 k€ | Élevé | 20 ans |

### Recommandation

**Mix 2 électriques + 1 GNV** (320 k€) :
- Bénéfices RSE significatifs (ZFE, communication)
- ROI raisonnable (~ 7-8 ans)
- Diversification des risques technologiques
- Apprentissage progressif des équipes

L'hydrogène reste à différer (2-3 ans) pour profiter de la baisse des prix et du développement du réseau.

---

> ✅ **À retenir**
>
> - **Électrique** : distribution urbaine, ZFE, autonomie 200-450 km.
> - **GNV/bioGNV** : régional, autonomie 350-1 200 km, réseau en développement.
> - **Hydrogène** : technologie naissante, longue distance, prix élevé.
> - **Suramortissement +40 %** + aides ADEME 5-25 k€ + aides régionales.
> - **Stratégie progressive** : pilote → évaluation → déploiement par phases.
$lesson2$,
'Électrique (distribution, ZFE), GNV/bioGNV (régional), hydrogène (longue distance, naissante), suramortissement +40 % + aides, stratégie progressive 5-10 ans.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — ZFE et adaptations urbaines
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'ZFE et adaptations urbaines',
    'gotrm-bc03-02-03-zfe-urbain', 3, 35,
$lesson3$
# ZFE et adaptations urbaines

Les **Zones à Faibles Émissions** (ZFE) transforment les conditions d'accès aux centres urbains. Comprendre la réglementation, anticiper les évolutions et adapter sa flotte est désormais une nécessité opérationnelle.

> 🎯 **Objectifs de la leçon**
>
> - Maîtriser le **cadre légal des ZFE**.
> - Connaître le **calendrier** des restrictions.
> - Adapter la **flotte** aux ZFE.
> - Identifier les **opportunités commerciales**.

---

## 1. Le cadre légal des ZFE

### 1.1 Loi d'orientation des mobilités (LOM 2019)

Le cadre légal général. Loi Climat et Résilience (2021) renforce et étend les ZFE :
- 11 métropoles obligatoirement à partir de 2025
- 33 agglomérations > 150 000 habitants à partir de 2030
- Restrictions Crit'Air progressives

### 1.2 Les vignettes Crit'Air

| Vignette | Type véhicule | Couleur |
|---|---|---|
| **Crit'Air E** | Électrique, hydrogène | Verte |
| **Crit'Air 1** | Hybride rechargeable, gaz, hybride essence (depuis 2011) | Violette |
| **Crit'Air 2** | Diesel Euro 5/6 (depuis 2011) | Jaune |
| **Crit'Air 3** | Diesel Euro 4 (2006-2010) | Orange |
| **Crit'Air 4** | Diesel Euro 3 (2001-2005) | Marron |
| **Crit'Air 5** | Diesel Euro 2 (1997-2000) | Gris |
| **Sans vignette** | Diesel < 1997 | — |

### 1.3 Obligations

- Vignette obligatoire pour circuler en ZFE (sauf véhicules militaires, secours, etc.)
- Coût : 3,72 € (en 2026)
- Apposition sur le pare-brise

---

## 2. Calendrier des restrictions principales

### 2.1 Paris et région Île-de-France (ZFE-m métropole du Grand Paris)

| Date | Restriction véhicules utilitaires/PL |
|---|---|
| 1er juillet 2019 | Crit'Air 5 et non-classés |
| 1er juillet 2021 | Crit'Air 4 |
| 1er juillet 2023 | Crit'Air 3 |
| 1er janvier 2025 | Crit'Air 2 (initialement, reporté au 1er janvier 2026) |
| 2030 | Tout sauf Crit'Air E (zéro émission) |

### 2.2 Lyon

| Date | Restriction VUL/PL |
|---|---|
| 1er sept 2022 | Crit'Air 5 et non-classés |
| 1er janvier 2024 | Crit'Air 4 |
| 1er janvier 2026 | Crit'Air 3 |
| 1er janvier 2028 | Crit'Air 2 |

### 2.3 Autres grandes métropoles

| Ville | Phase actuelle (2026) | Horizon 2030 |
|---|---|---|
| Marseille | Crit'Air 4+ | Crit'Air 1 |
| Toulouse | Crit'Air 4+ | Crit'Air 1 |
| Nice | Crit'Air 4+ | Crit'Air 1 |
| Strasbourg | Crit'Air 5+ | Crit'Air 1 |
| Grenoble | Crit'Air 4+ | Crit'Air 1 |
| Rouen | Crit'Air 5+ | Crit'Air 1 |
| Reims | Crit'Air 5+ | Crit'Air 1 |
| Saint-Étienne | Crit'Air 5+ | Crit'Air 1 |

> ⚠️ **Important**
>
> Les calendriers sont régulièrement ajustés (renforcés ou retardés). Toujours vérifier la version actualisée sur le site de chaque métropole.

---

## 3. Adapter sa flotte aux ZFE

### 3.1 Audit de la flotte

| Étape | Action |
|---|---|
| 1 | Inventaire complet du parc avec date de mise en service et vignette Crit'Air |
| 2 | Identification des véhicules circulant en ZFE |
| 3 | Cartographie des restrictions à 2 ans, 5 ans, 10 ans |
| 4 | Plan de renouvellement par véhicule |

### 3.2 Stratégies d'adaptation

| Stratégie | Quand l'utiliser |
|---|---|
| **Renouvellement anticipé** | Véhicules anciens (> 8 ans) en zone ZFE |
| **Réaffectation** | Véhicules Crit'Air 3-4 vers zones rurales |
| **Acquisition de véhicules propres** (E, 1) | Distribution urbaine |
| **Sous-traitance ZFE** | Solution temporaire si flotte non adaptée |
| **Cross-docking en périphérie** | Schéma logistique périphérie + dernière mile électrique |

### 3.3 Le scrappage

- Prime de conversion (état, jusqu'à 9 000 € pour utilitaires)
- Cumul possible avec aides régionales
- Conditions : ancienneté véhicule, achat véhicule propre

---

## 4. Le dernier kilomètre urbain

### 4.1 Le défi

La **dernière distance** (5-30 km) en ville représente :
- 50 % du coût d'une livraison
- 30 % des émissions urbaines de transport
- Concentration des contraintes (ZFE, congestion, créneaux)

### 4.2 Solutions innovantes

| Solution | Application |
|---|---|
| Vélos cargo | Très petite distribution (< 50 kg) |
| Triporteurs électriques | 50-200 kg, livraison de proximité |
| Camionnettes électriques 3,5 t | Volumes moyens en centre-ville |
| Hubs urbains (cross-docking) | Découplage longue distance / dernière mile |
| Livraisons nocturnes (silencieuses) | Concentration des arrêts en heures creuses |

### 4.3 Coûts indicatifs

| Solution | Coût mensuel |
|---|---|
| Cargo vélo loueur | 200-400 €/mois |
| Camionnette électrique louée | 600-900 €/mois |
| Hub urbain partagé | 500-1 500 €/mois |

---

## 5. Opportunités commerciales

### 5.1 Démarcher les chargeurs RSE

Les grands chargeurs (industrie, distribution) ont des engagements de réduction CO2. Un transporteur conforme ZFE et RSE devient un partenaire privilégié.

### 5.2 Premium tarifaire

- Premium "vert" : +5 à 15 % sur prix standard
- Justifications : véhicules récents, traçabilité CO2, certifications
- Argumentaire : économies fiscales (suramortissement transmissible), image, anticipation réglementaire

### 5.3 Communication RSE

- Étiquetage CO2 sur les missions (loi Climat 2021)
- Reporting client trimestriel
- Certificats de transport vert
- Communication sur le parc

---

## 6. Cas pratique : adaptation aux ZFE

**Contexte** : *Distrib Lyon* (12 véhicules), dont 6 livrent quotidiennement Lyon centre. Composition :
- 2 porteurs 12 t Crit'Air 2 (acquis en 2018)
- 4 porteurs 12 t Crit'Air 3 (acquis en 2014)
- 6 véhicules régionaux (hors ZFE)

### Calendrier de risque

- 2026 : Crit'Air 3 INTERDITS à Lyon → 4 véhicules concernés
- 2028 : Crit'Air 2 INTERDITS → 2 véhicules supplémentaires concernés

### Plan d'adaptation 2026-2028

**M+0 à M+6** (urgence Crit'Air 3)
- Vente de 4 Crit'Air 3 (récupération ~ 30-50 k€/véhicule)
- Acquisition de 4 véhicules Crit'Air 1 (gaz) ou E (électriques) :
  - 2 électriques 12 t (240 k€ net après aides) → distribution Lyon centre
  - 2 GNV 12 t (180 k€) → distribution Lyon péri-urbain
- Investissement net : 420 k€ - 160 k€ revente = **260 k€**
- Aides : 60 k€ (ADEME + région) → net 200 k€
- Suramortissement : économie fiscale 80 k€

**M+12 à M+24** (anticipation Crit'Air 2)
- Renouvellement progressif des 2 Crit'Air 2 par 2 électriques
- Investissement net : 200 k€

### Opportunités commerciales activées

- Premium "vert" sur top 10 clients : +8 % CA = 35 k€/an
- Ouverture marché ZFE (clients non livrables actuellement) : 5 nouveaux clients × 25 k€ = 125 k€ additionnels CA

### Bilan ROI 5 ans

- Investissement : 460 k€ (cumulé sur 3 ans)
- Bénéfices annuels (récurrent) : 50-80 k€/an (économies + premium + nouveaux clients)
- Payback : 6-9 ans
- À cela s'ajoute : éviter la perte des clients actuels en ZFE (potentiel 200-400 k€/an de CA si non adaptation)

> 💡 **L''adaptation aux ZFE n''est pas une charge — c''est un investissement à ROI positif sur 5-10 ans, ET une nécessité pour conserver l''accès aux centres urbains.**

---

> ✅ **À retenir**
>
> - **ZFE** : 11 métropoles obligatoires à 2025, 33 agglomérations à 2030.
> - **Crit'Air** : E, 1, 2, 3, 4, 5 selon ancienneté et motorisation.
> - **Calendrier** : Crit'Air 3 interdit à Paris et Lyon en 2026, Crit'Air 2 en 2028.
> - **Adaptation** : audit flotte, plan de renouvellement, sous-traitance, cross-docking.
> - **Opportunité commerciale** : premium "vert" +5-15 % et accès marché ZFE.
$lesson3$,
'Cadre légal LOM 2019 + Climat 2021, vignettes Crit''Air E à 5, calendrier ZFE Paris/Lyon/autres, adaptation flotte, dernier km urbain (vélos cargo, hubs), opportunités commerciales.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — KPI rentabilité durable
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'KPI de rentabilité durable',
    'gotrm-bc03-02-04-kpi-durable', 4, 35,
$lesson4$
# KPI de rentabilité durable

La rentabilité durable se mesure à la croisée de la **performance économique** et de la **performance ESG** (Environnement, Social, Gouvernance). Une démarche RSE n'a de sens que si elle est mesurée et pilotée.

> 🎯 **Objectifs de la leçon**
>
> - Définir les **KPI ESG** essentiels.
> - Construire un **tableau de bord intégré**.
> - Maîtriser le **reporting RSE**.
> - Anticiper les **futures obligations**.

---

## 1. KPI environnementaux

### 1.1 Émissions CO2

| KPI | Unité | Cible 2030 |
|---|---|---|
| Émissions totales (Scope 1 + 2 + 3) | tCO2eq/an | -30 % vs 2020 |
| Intensité CO2 par km commercial | gCO2/km | -25 % vs 2020 |
| Intensité CO2 par tonne.km | gCO2/t.km | -30 % vs 2020 |
| % flotte zéro émission | % | > 30 % |

### 1.2 Énergie

| KPI | Cible |
|---|---|
| Consommation moyenne carburant (L/100 km) | < 28 L (porteur) |
| % véhicules Crit'Air E ou 1 | > 30 % à 2030 |
| Consommation énergétique locaux (kWh/m²/an) | < 100 |
| % énergie renouvelable (locaux) | > 50 % |

### 1.3 Déchets et économie circulaire

| KPI | Cible |
|---|---|
| Tonnes déchets/an | À réduire annuellement |
| % recyclage | > 60 % |
| Réutilisation pneus, pièces détachées | À développer |

---

## 2. KPI sociaux

### 2.1 Conditions de travail

| KPI | Cible |
|---|---|
| Turnover annuel conducteurs | < 15 % |
| Absentéisme | < 6 % |
| Taux de fréquence (TF) accidents | < 25 |
| Taux de gravité (TG) accidents | < 1,2 |
| Heures de formation/salarié/an | > 14 h |

### 2.2 Diversité et inclusion

| KPI | Cible |
|---|---|
| % femmes dans l'effectif | > 15 % à terme |
| % cadres femmes | À mesurer et viser progrès |
| % travailleurs handicapés | > 6 % (obligation légale) |
| Index égalité H/F | > 75/100 |

### 2.3 Engagement et bien-être

| KPI | Cible |
|---|---|
| NPS interne (recommanderaient l'entreprise) | > 40 |
| Taux de réponse aux enquêtes internes | > 70 % |
| Promotions internes / total recrutements | > 30 % |

---

## 3. KPI gouvernance

| KPI | Mesure |
|---|---|
| Code de conduite signé par 100 % des collaborateurs | Annuelle |
| Formation lutte anti-corruption | 100 % collaborateurs concernés/3 ans |
| Procédure d'alerte (whistleblower) | Active et utilisée |
| Audit fournisseurs RSE | % audités/an |
| Communication transparente (rapport annuel) | Publié |

---

## 4. Tableau de bord intégré

### 4.1 Format type

Pour une PME 25 véhicules :

```
TABLEAU DE BORD ESG — TRIMESTRE [N]

ENVIRONNEMENT
- Émissions Scope 1 (carburant) : 423 tCO2eq (-3 % vs T-1) 🟩
- Conso moyenne flotte : 28,3 L/100 km (cible < 29) 🟩
- % flotte propre (E/1) : 8 % (cible 30 % à 2030) 🟧
- Déchets recyclés : 65 % (cible 60 %) 🟩

SOCIAL
- Turnover conducteurs : 16 % (cible < 15 %) 🟧
- Heures formation/salarié : 18 h (cible > 14 h) 🟩
- TF accidents : 23 (cible < 25) 🟩
- Index égalité H/F : 82 (cible > 75) 🟩

GOUVERNANCE
- Code de conduite : 100 % signé 🟩
- Formation anti-corruption : 95 % (cible 100 %) 🟧
- Audit fournisseurs RSE : 30 % (cible 40 %) 🟧

SCORE ESG GLOBAL : 78/100 (cible > 75)
```

### 4.2 Suivi

- Mensuel : KPI opérationnels (émissions, conso, accidents)
- Trimestriel : KPI complets, comité ESG
- Annuel : rapport public, actions stratégiques

---

## 5. Reporting RSE

### 5.1 Formats de reporting

| Format | Public |
|---|---|
| Rapport annuel intégré | Toutes parties prenantes (10-30 pages) |
| Rapport ESG dédié | Investisseurs, clients grands comptes |
| Reporting EcoVadis | Évaluation tiers, demandé par chargeurs |
| Rapport CSRD | Obligatoire pour grandes entreprises (Directive UE 2024) |

### 5.2 Structure type d'un rapport RSE

1. Mot de la direction (1 page)
2. Présentation de l'entreprise (2 pages)
3. Stratégie ESG et engagements (2 pages)
4. Performance environnementale (4-6 pages)
5. Performance sociale (4-6 pages)
6. Gouvernance (2-3 pages)
7. Engagement parties prenantes (1-2 pages)
8. Tableau de bord et perspectives (2 pages)

### 5.3 Communication

- Site web dédié (page "RSE")
- Réseaux sociaux (LinkedIn pour B2B)
- Présentations clients (slides 5-10 pages)
- Communications internes (newsletter mensuelle)
- Salons et événements professionnels

---

## 6. Anticiper les futures obligations

### 6.1 CSRD (Corporate Sustainability Reporting Directive)

| Élément | Détail |
|---|---|
| Application | À partir de 2024 (entreprises cotées), 2025+ (PME selon critères) |
| Contenu | Reporting détaillé sur 12 thèmes ESG |
| Vérification | Audit obligatoire |
| Sanctions | Amendes administratives |

### 6.2 Trajectoires décarbonation

| Échéance | Réglementation prévisible |
|---|---|
| 2025 | Bilan Carbone obligatoire pour entreprises > 50 salariés |
| 2030 | Trajectoires de réduction CO2 par secteur |
| 2035 | Interdiction véhicules thermiques neufs (UE) |
| 2050 | Neutralité carbone (objectif UE) |

### 6.3 Préparation

- Anticiper le Bilan Carbone (faire un blanc dès maintenant)
- Investir progressivement dans la transition
- Documenter les actions en cours
- Former les équipes
- Communiquer sur la trajectoire

---

## 7. Cas pratique : score ESG d'une PME

**Contexte** : *Trans-Méditerranée* (25 véhicules) lance son premier rapport RSE et vise un score ESG de 75/100 à 18 mois.

### Score initial

| Pilier | Score actuel | Cible 18 mois |
|---|---|---|
| Environnement | 65/100 | 80/100 |
| Social | 70/100 | 75/100 |
| Gouvernance | 55/100 | 75/100 |
| **Total** | **63/100** | **77/100** |

### Plan d'action

**Environnement** (65 → 80)
- Engagement Objectif CO2 (FNTR-ADEME)
- 2 véhicules électriques
- Éco-conduite généralisée
- Photovoltaïque locaux

**Social** (70 → 75)
- Augmentation salaires +3 %
- Plan formation 20 h/conducteur
- Nouvel accord QVCT (Qualité de Vie et des Conditions de Travail)

**Gouvernance** (55 → 75)
- Code de conduite formel
- Comité éthique trimestriel
- Audit RSE des 5 plus gros fournisseurs
- Rapport RSE public (1ère édition)

### Investissement total

| Poste | Montant |
|---|---|
| Diagnostic et certification | 12 k€ |
| Actions environnement | 65 k€ |
| Actions social | 30 k€ |
| Actions gouvernance | 8 k€ |
| Communication | 6 k€ |
| Total | 121 k€ |

### Bénéfices attendus

| Bénéfice | Annuel |
|---|---|
| Économies carburant (-7 %) | 32 k€ |
| Subventions véhicules propres (one-shot) | 35 k€ |
| Argument commercial (+5 % CA top clients) | 25 k€ |
| Réduction turnover (-3 pts) | 22 k€ |
| Anticipation réglementaire (préparation 2030) | Précieux |
| Total an 1 | 114 k€ |

ROI : 114 / 121 = 94 % an 1 (sans même valoriser les bénéfices intangibles).

---

> ✅ **À retenir**
>
> - **3 dimensions ESG** : environnement, social, gouvernance, chaque dimension avec 4-5 KPI.
> - **Tableau de bord intégré** trimestriel avec score global.
> - **Reporting** : rapport annuel intégré, EcoVadis, CSRD (obligatoire grandes entreprises).
> - **Anticipation** : Bilan Carbone obligatoire à 2025 (> 50 salariés), neutralité 2050.
> - **ROI** RSE positif dès an 1 avec démarche structurée.
$lesson4$,
'KPI ESG (environnement, social, gouvernance), tableau de bord intégré trimestriel, reporting CSRD, anticipation 2025/2030/2050, ROI positif dès an 1.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- 25 QCM
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qcm', 'La RSE comporte combien de piliers principaux ?', '[{"id":"a","label":"2 (économique et social)","is_correct":false},{"id":"b","label":"3 (environnemental, social, gouvernance)","is_correct":true},{"id":"c","label":"5","is_correct":false},{"id":"d","label":"7","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['rse','piliers'], 'mft-2026-gotrm:bc03-02:qcm:1', true, 'RSE = Responsabilité Sociétale des Entreprises avec 3 piliers : Environnemental (CO2, énergie), Social (conditions de travail, formation), Gouvernance (éthique, transparence). Aussi appelée ESG (Environment, Social, Governance).'),
  (v_formation, 'qcm', 'Le bilan carbone Scope 1 inclut :', '[{"id":"a","label":"Les émissions de la chaîne d''approvisionnement","is_correct":false},{"id":"b","label":"Les émissions directes (carburant véhicules, gaz locaux)","is_correct":true},{"id":"c","label":"Les émissions liées à l''électricité achetée","is_correct":false},{"id":"d","label":"Les émissions clients","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['bilan-carbone','scope'], 'mft-2026-gotrm:bc03-02:qcm:2', true, 'Scope 1 = émissions directes (carburant véhicules, gaz chauffage locaux). Scope 2 = émissions indirectes liées à l''énergie achetée (électricité). Scope 3 = autres émissions indirectes (déplacements, achats, sous-traitance).'),
  (v_formation, 'qcm', 'Le facteur d''émission CO2 du gazole est de :', '[{"id":"a","label":"0,52 kg CO2eq/L","is_correct":false},{"id":"b","label":"2,52 kg CO2eq/L","is_correct":true},{"id":"c","label":"5,52 kg CO2eq/L","is_correct":false},{"id":"d","label":"10 kg CO2eq/L","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['co2','gazole'], 'mft-2026-gotrm:bc03-02:qcm:3', true, 'Facteur d''émission gazole : 2,52 kg CO2eq/L (combustion). Pour un porteur 19 t à 28 L/100 km × 110 000 km/an : 30 800 L × 2,52 = 77,6 tCO2eq/véhicule/an.'),
  (v_formation, 'qcm', 'La certification "Objectif CO2" est portée par :', '[{"id":"a","label":"L''ONU","is_correct":false},{"id":"b","label":"FNTR + ADEME","is_correct":true},{"id":"c","label":"L''Union européenne","is_correct":false},{"id":"d","label":"Chacun seul","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['objectif-co2','certification'], 'mft-2026-gotrm:bc03-02:qcm:4', true, 'Objectif CO2 = charte volontaire portée par la FNTR (Fédération Nationale des Transports Routiers) et l''ADEME. Plus de 1 600 entreprises signataires en 2025. Engagement sur 3 ans avec plan d''action 4 axes.'),
  (v_formation, 'qcm', 'EcoVadis est :', '[{"id":"a","label":"Un transporteur","is_correct":false},{"id":"b","label":"Une plateforme d''évaluation RSE des fournisseurs (note sur 100)","is_correct":true},{"id":"c","label":"Une banque verte","is_correct":false},{"id":"d","label":"Un type de véhicule électrique","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['ecovadis'], 'mft-2026-gotrm:bc03-02:qcm:5', true, 'EcoVadis = plateforme d''évaluation RSE des fournisseurs (cabinet international). Note sur 100, niveaux : Bronze, Silver, Gold, Platinum. Demandé par les chargeurs grands comptes pour appels d''offres. Renouvellement annuel.'),
  (v_formation, 'qcm', 'L''autonomie typique d''un véhicule électrique poids lourd en 2026 est de :', '[{"id":"a","label":"50-100 km","is_correct":false},{"id":"b","label":"200-450 km","is_correct":true},{"id":"c","label":"800-1 200 km","is_correct":false},{"id":"d","label":"2 000 km","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['electrique','autonomie'], 'mft-2026-gotrm:bc03-02:qcm:6', true, 'Autonomie électrique 2026 : 200-450 km selon batterie. Distribution urbaine et péri-urbaine = idéal. Lignes longue distance = pas encore adapté. Hydrogène ou GNV pour ces usages.'),
  (v_formation, 'qcm', 'Le bioGNV permet une réduction des émissions CO2 par rapport au diesel de :', '[{"id":"a","label":"5 %","is_correct":false},{"id":"b","label":"15-20 %","is_correct":false},{"id":"c","label":"60 %","is_correct":false},{"id":"d","label":"~ 85 %","is_correct":true}]'::jsonb, 1, 'difficile', ARRAY['biognv','emissions'], 'mft-2026-gotrm:bc03-02:qcm:7', true, 'BioGNV (gaz naturel d''origine renouvelable) : ~ 85 % de réduction CO2 vs diesel. GNV "fossile" : -15 à -20 %. Le bioGNV est une excellente solution RSE avec autonomie et infrastructure adaptées.'),
  (v_formation, 'qcm', 'Le suramortissement véhicules propres permet une déduction supplémentaire de :', '[{"id":"a","label":"10 %","is_correct":false},{"id":"b","label":"40 %","is_correct":true},{"id":"c","label":"80 %","is_correct":false},{"id":"d","label":"100 %","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['suramortissement'], 'mft-2026-gotrm:bc03-02:qcm:8', true, 'Suramortissement véhicules propres (gaz, électrique, hydrogène) : 40 % de la valeur d''origine en déduction supplémentaire, étalée sur la durée d''amortissement. Valable jusqu''en 2030 (à confirmer chaque loi de finances).'),
  (v_formation, 'qcm', 'L''hydrogène pour véhicules industriels est aujourd''hui :', '[{"id":"a","label":"Une technologie mature","is_correct":false},{"id":"b","label":"Une technologie naissante (réseau limité, prix élevé)","is_correct":true},{"id":"c","label":"Interdite en France","is_correct":false},{"id":"d","label":"Disponible uniquement pour les voitures particulières","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['hydrogene','maturite'], 'mft-2026-gotrm:bc03-02:qcm:9', true, 'Hydrogène = technologie naissante : peu de modèles disponibles, prix +200-300 % vs diesel, réseau de stations très limité (10-20 en France 2026, 100+ prévus à 2030). Avenir prometteur mais à différer pour la plupart des PME aujourd''hui.'),
  (v_formation, 'qcm', 'L''ADEME peut accorder une aide pour acquisition de véhicule propre de :', '[{"id":"a","label":"Aucune aide","is_correct":false},{"id":"b","label":"5-25 k€ par véhicule selon type","is_correct":true},{"id":"c","label":"100 % du prix","is_correct":false},{"id":"d","label":"Uniquement pour les vélos","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['ademe','aide'], 'mft-2026-gotrm:bc03-02:qcm:10', true, 'Programme ADEME EcoEnergie Transports : aides 5-25 k€ par véhicule selon type (électrique, GNV, hydrogène). Cumulables avec suramortissement et aides régionales. Conditions sur ancienneté et caractéristiques.'),
  (v_formation, 'qcm', 'Une ZFE (Zone à Faibles Émissions) est :', '[{"id":"a","label":"Une zone industrielle","is_correct":false},{"id":"b","label":"Une zone géographique avec restrictions de circulation selon vignettes Crit''Air","is_correct":true},{"id":"c","label":"Une zone fiscale franche","is_correct":false},{"id":"d","label":"Une zone agricole","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['zfe','definition'], 'mft-2026-gotrm:bc03-02:qcm:11', true, 'ZFE = Zone à Faibles Émissions, zone géographique délimitée (souvent les centres urbains) avec restrictions de circulation selon les vignettes Crit''Air. Loi LOM 2019 + Climat 2021. 11 métropoles obligatoires à 2025, 33 à 2030.'),
  (v_formation, 'qcm', 'La vignette Crit''Air E correspond à :', '[{"id":"a","label":"Diesel récent","is_correct":false},{"id":"b","label":"Véhicule électrique ou hydrogène","is_correct":true},{"id":"c","label":"Véhicule essence ancien","is_correct":false},{"id":"d","label":"Véhicule sans catalyseur","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['critair','e'], 'mft-2026-gotrm:bc03-02:qcm:12', true, 'Crit''Air E (couleur verte) : véhicules zéro émission directe (électrique, hydrogène). Crit''Air 1 (violette) : hybride rechargeable, gaz, hybride essence récent. Diesels = Crit''Air 2 à 5 selon ancienneté.'),
  (v_formation, 'qcm', 'À l''horizon 2030, dans les grandes métropoles ZFE, les véhicules autorisés seront typiquement :', '[{"id":"a","label":"Tous Crit''Air","is_correct":false},{"id":"b","label":"Crit''Air 5 et plus récents","is_correct":false},{"id":"c","label":"Crit''Air E uniquement (zéro émission)","is_correct":true},{"id":"d","label":"Aucun véhicule","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['zfe','2030'], 'mft-2026-gotrm:bc03-02:qcm:13', true, 'À 2030, la plupart des grandes métropoles (Paris, Lyon, Marseille, etc.) prévoient l''interdiction des Crit''Air 1, 2, 3, 4, 5. Seuls les Crit''Air E (zéro émission) seront autorisés. Calendriers évolutifs à vérifier régulièrement.'),
  (v_formation, 'qcm', 'Le "dernier kilomètre" en distribution urbaine représente typiquement :', '[{"id":"a","label":"5 % du coût d''une livraison","is_correct":false},{"id":"b","label":"50 % du coût d''une livraison","is_correct":true},{"id":"c","label":"Aucun impact","is_correct":false},{"id":"d","label":"100 % du coût","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['dernier-km','cout'], 'mft-2026-gotrm:bc03-02:qcm:14', true, 'Le dernier kilomètre représente ~ 50 % du coût total d''une livraison (parking, accès difficile, créneaux). Solutions : vélos cargo, triporteurs électriques, hubs urbains de cross-docking, livraisons nocturnes.'),
  (v_formation, 'qcm', 'La directive CSRD (Corporate Sustainability Reporting Directive) de l''UE :', '[{"id":"a","label":"Est facultative","is_correct":false},{"id":"b","label":"Impose un reporting détaillé sur 12 thèmes ESG, audit obligatoire","is_correct":true},{"id":"c","label":"Concerne uniquement les TPE","is_correct":false},{"id":"d","label":"S''applique uniquement à 2050","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['csrd'], 'mft-2026-gotrm:bc03-02:qcm:15', true, 'CSRD = directive UE 2024 : reporting ESG détaillé sur 12 thèmes, audit obligatoire, sanctions administratives. Application progressive : 2024 grandes entreprises cotées, 2025 et plus pour PME selon critères. Anticiper dès maintenant.'),
  (v_formation, 'qcm', 'Le Bilan Carbone est obligatoire (BEGES) pour les entreprises de :', '[{"id":"a","label":"> 50 salariés","is_correct":false},{"id":"b","label":"> 500 salariés","is_correct":true},{"id":"c","label":"Toutes","is_correct":false},{"id":"d","label":"Aucune","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['beges'], 'mft-2026-gotrm:bc03-02:qcm:16', true, 'BEGES (Bilan d''Émissions de Gaz à Effet de Serre) : obligatoire pour entreprises > 500 salariés (DROM > 250). Tous les 4 ans. Scope 1 et 2 minimum. Loi Climat 2021 prévoit une extension progressive à > 50 salariés à partir de 2025.'),
  (v_formation, 'qcm', 'L''interdiction des véhicules thermiques neufs en UE est prévue pour :', '[{"id":"a","label":"2028","is_correct":false},{"id":"b","label":"2035","is_correct":true},{"id":"c","label":"2050","is_correct":false},{"id":"d","label":"Pas d''interdiction prévue","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['2035','thermique'], 'mft-2026-gotrm:bc03-02:qcm:17', true, '2035 : interdiction prévue de la vente de véhicules thermiques neufs en UE (cars, voitures particulières, utilitaires légers). Pour les poids lourds, calendrier différent (en cours de discussion). Préparer la transition dès maintenant.'),
  (v_formation, 'qcm', 'L''ISO 14001 est :', '[{"id":"a","label":"Une norme financière","is_correct":false},{"id":"b","label":"Une certification de système de management environnemental","is_correct":true},{"id":"c","label":"Une norme RH","is_correct":false},{"id":"d","label":"Une certification cybersécurité","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['iso-14001'], 'mft-2026-gotrm:bc03-02:qcm:18', true, 'ISO 14001 = certification de système de management environnemental. Engagement direction, identification aspects environnementaux, conformité réglementaire, programmes amélioration continue, audit annuel. De plus en plus demandée par les chargeurs.'),
  (v_formation, 'qcm', 'L''indice de référence pour la diversité de genre dans une entreprise est :', '[{"id":"a","label":"Index égalité H/F (DGCCRF)","is_correct":true},{"id":"b","label":"Indice CAC 40","is_correct":false},{"id":"c","label":"PIB","is_correct":false},{"id":"d","label":"Aucun","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['egalite','index'], 'mft-2026-gotrm:bc03-02:qcm:19', true, 'Index égalité H/F (DGCCRF) : note sur 100, mesure les écarts de salaire, augmentation, promotion, retour congé maternité, présence dans les top 10 rémunérations. Cible > 75/100. Entreprises < 75 doivent prendre des actions correctives.'),
  (v_formation, 'qcm', 'Pour les véhicules en distribution urbaine en 2030, l''énergie la plus adaptée sera typiquement :', '[{"id":"a","label":"Diesel","is_correct":false},{"id":"b","label":"Électrique","is_correct":true},{"id":"c","label":"Hydrogène uniquement","is_correct":false},{"id":"d","label":"Toutes équivalentes","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['distribution','electrique'], 'mft-2026-gotrm:bc03-02:qcm:20', true, 'Distribution urbaine 2030 : électrique idéal (autonomie 200-450 km suffisante, ZFE imposent zéro émission, infrastructure de recharge en ville développée). Hydrogène plus adapté longue distance.'),
  (v_formation, 'qcm', 'L''argument "premium vert" sur le tarif de transport peut atteindre :', '[{"id":"a","label":"Pas de premium possible","is_correct":false},{"id":"b","label":"+5 à +15 % sur prix standard","is_correct":true},{"id":"c","label":"+50 %","is_correct":false},{"id":"d","label":"+100 %","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['premium','vert'], 'mft-2026-gotrm:bc03-02:qcm:21', true, 'Premium "vert" : +5 à +15 % sur prix standard pour transport en véhicules propres (E, GNV, etc.). Justifications : économies fiscales pour le client, image, traçabilité CO2, anticipation réglementaire. À développer en démarchant les chargeurs RSE.'),
  (v_formation, 'qcm', 'La trajectoire de neutralité carbone européenne vise :', '[{"id":"a","label":"2025","is_correct":false},{"id":"b","label":"2050","is_correct":true},{"id":"c","label":"2100","is_correct":false},{"id":"d","label":"Aucun objectif","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['neutralite','2050'], 'mft-2026-gotrm:bc03-02:qcm:22', true, '2050 : objectif de neutralité carbone de l''Union Européenne (Fit for 55, Pacte Vert). Implique réduction massive des émissions et compensation. Préparer la trajectoire dès maintenant via les bilans carbone et plans d''action.'),
  (v_formation, 'qcm', 'Le rapport RSE annuel d''une entreprise comporte typiquement :', '[{"id":"a","label":"1 page","is_correct":false},{"id":"b","label":"10-30 pages","is_correct":true},{"id":"c","label":"100 pages obligatoirement","is_correct":false},{"id":"d","label":"Aucune structure","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['rapport-rse','format'], 'mft-2026-gotrm:bc03-02:qcm:23', true, 'Rapport RSE intégré type : 10-30 pages avec mot direction, présentation entreprise, stratégie ESG, performance environnementale, performance sociale, gouvernance, parties prenantes, tableau de bord. Lisible et engageant.'),
  (v_formation, 'qcm', 'Pour une PME 25 véhicules, le coût annuel d''une démarche RSE structurée est typiquement :', '[{"id":"a","label":"500 €","is_correct":false},{"id":"b","label":"50-85 k€ an 1, 30-50 k€ années suivantes","is_correct":true},{"id":"c","label":"500 k€/an","is_correct":false},{"id":"d","label":"Aucun coût","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['rse','cout'], 'mft-2026-gotrm:bc03-02:qcm:24', true, 'PME 25 véhicules : démarche RSE coût an 1 ~ 50-85 k€ (diagnostic, certification, plan actions, communication). Années suivantes : 30-50 k€ récurrents. ROI 2-4 ans typiquement (économies, premium commercial, réduction turnover, anticipation réglementaire).'),
  (v_formation, 'qcm', 'Le suivi du KPI "intensité CO2 par tonne.km" permet :', '[{"id":"a","label":"De mesurer la rentabilité","is_correct":false},{"id":"b","label":"De comparer la performance environnementale par unité de service","is_correct":true},{"id":"c","label":"De calculer le prix de vente","is_correct":false},{"id":"d","label":"D''économiser le carburant","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['kpi','intensite-co2'], 'mft-2026-gotrm:bc03-02:qcm:25', true, 'Intensité CO2 par tonne.km = gCO2 / (tonnes transportées × km) = vraie mesure de la performance environnementale par unité de service. Permet la comparaison entre entreprises, types de véhicules, modes de transport. Standard du secteur.');


  -- =================================================================
  -- 4 QR
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qr', 'Construisez la démarche RSE complète sur 18 mois pour une PME de 30 véhicules. Détaillez les 5 phases, les actions par pilier (environnemental, social, gouvernance), les indicateurs de mesure, le budget et le ROI attendu.', NULL, 1, 'difficile', ARRAY['rse','demarche','18-mois'], 'mft-2026-gotrm:bc03-02:qr:1', true, 'DÉMARCHE RSE 18 MOIS — PME 30 VÉHICULES

OBJECTIF : Démarche structurée alignée avec les obligations réglementaires et les attentes des chargeurs grands comptes. Obtention d''une certification (Objectif CO2 + EcoVadis Bronze minimum) à 18 mois.

PHASE 1 — DIAGNOSTIC (M+1 à M+3)

a. Bilan carbone simplifié
- Cabinet externe (8-12 k€) ou outil ADEME interne (gratuit + 5 k€ formation)
- Scope 1 (carburant) + Scope 2 (électricité locaux)
- Identification des sources d''émission
- Estimation des potentiels de réduction

b. Audit social interne
- Climat social (enquête anonyme conducteurs et exploitation)
- Conditions de travail (ergonomie, salaires, formation)
- Statistiques accidents (TF, TG)
- Diversité (% femmes, handicap)

c. Audit gouvernance
- Procédures existantes (achats, finances, RH)
- Code de conduite (existe ? appliqué ?)
- Lutte anti-corruption (Sapin 2)
- Engagements parties prenantes

d. Identification des 5-7 enjeux prioritaires
- Mix : 2-3 environnementaux, 2 sociaux, 1-2 gouvernance
- Priorisation par impact et faisabilité

PHASE 2 — ENGAGEMENT (M+4 à M+6)

a. Charte RSE entreprise (1 page)
- Vision et valeurs
- 7 engagements chiffrés à 3 ans
- Signée par la direction
- Diffusée à tous les collaborateurs

b. Désignation référent RSE
- 1 personne à 30 % de son temps
- Souvent QHSE ou RH
- Formation dédiée (3-5 jours)

c. Communication interne et externe
- Présentation aux équipes (1 jour)
- Page web dédiée
- LinkedIn et communication client
- Mise à jour des supports commerciaux

PHASE 3 — PLAN D''ACTION (M+7 à M+12)

PILIER ENVIRONNEMENTAL

Action 1 : Formation éco-conduite généralisée
- 35 conducteurs × 7 h × 50 €/h = 12 250 €
- Cible : -8 % consommation carburant
- Indicateur : suivi mensuel par conducteur via télématique

Action 2 : 2 véhicules électriques pilote (distribution urbaine)
- 2 × 220 k€ HT = 440 k€
- Aides ADEME + région : -100 k€
- Net : 340 k€
- Cible : -150 tCO2/an
- Indicateur : émissions Scope 1 mensuelles

Action 3 : Photovoltaïque locaux
- 50 kWc installés : 60 k€ HT (autoconsommation 50 %)
- Économie électricité : 7 000 €/an
- Cible : -25 % énergie achetée
- Indicateur : kWh achetés / kWh totaux

Action 4 : Programme déchets (recyclage, économie circulaire)
- Tri sélectif renforcé : 3 000 €
- Réutilisation pneus : -2 000 €/an
- Cible : 70 % recyclage

PILIER SOCIAL

Action 5 : Plan formation continue
- 20 h/conducteur/an (35 × 20 × 35 €/h) = 24 500 €
- Cible : 100 % conducteurs formés
- Indicateur : heures de formation par salarié

Action 6 : Augmentation salariale ciblée
- +3 % conducteurs (impact masse salariale 35 000 €/an)
- +2 % cadres
- Cible : turnover < 12 %

Action 7 : Aménagements ergonomiques
- Vestiaires, salle de repos : 12 000 €
- Chaussures sécurité, vêtements : 5 000 €
- Cible : satisfaction interne +15 pts

Action 8 : Égalité H/F
- Recrutement actif femmes (objectif 18 %)
- Index égalité H/F mesuré
- Cible : index > 80

PILIER GOUVERNANCE

Action 9 : Code de conduite formel
- Rédaction (cabinet juridique 5 000 €)
- Signature 100 % collaborateurs
- Formation anti-corruption (cabinet 4 000 €)
- Indicateur : taux de signature et formation

Action 10 : Comité éthique trimestriel
- Composition : direction + représentant salariés + externe
- Fréquence trimestrielle
- Procès-verbaux et actions

Action 11 : Audit fournisseurs RSE
- Évaluation top 10 fournisseurs (2 k€)
- Critères ESG inclus dans les AO
- Cible : 50 % audités/an

Action 12 : Communication transparente
- Rapport RSE annuel (consultant 8 000 €)
- Site web actualisé (3 000 €)
- Présentations commerciales

PHASE 4 — MISE EN ŒUVRE ET SUIVI (M+13 à M+18)

Suivi mensuel :
- KPI opérationnels environnementaux (émissions, conso)
- KPI sociaux (turnover, accidents)
- Avancement des plans d''action (% réalisé)

Suivi trimestriel :
- Comité RSE (60 min) avec direction
- Tableau de bord intégré ESG
- Communication interne

Bilan annuel :
- Rapport RSE (15-25 pages)
- Communication aux parties prenantes
- Bilan vs engagements de la charte
- Ajustements pour année suivante

PHASE 5 — CERTIFICATION (M+15 à M+18)

a. Engagement Objectif CO2 (gratuit, FNTR-ADEME)
- Dossier de candidature
- Plan d''action 3 ans
- Signature charte

b. Évaluation EcoVadis (3 000 €)
- Questionnaire détaillé
- Documents justificatifs
- Note attendue : > 50/100 (Bronze)

c. Communication des certifications
- Logos sur supports commerciaux
- Argument commercial différenciant
- Renouvellement annuel

BUDGET TOTAL 18 MOIS

| Poste | Coût |
|---|---|
| Diagnostic et audit | 18 k€ |
| Charte et communication | 14 k€ |
| Référent RSE (30 % d''un poste) | 25 k€ |
| Actions environnementales (formation, photovoltaïque) | 79 k€ |
| 2 véhicules électriques (net après aides) | 340 k€ |
| Actions sociales (formation, salaires, ergonomie) | 76 k€ |
| Actions gouvernance | 19 k€ |
| Certifications | 3 k€ |
| **Total budget RSE 18 mois** | **574 k€** |

Hors véhicules : 234 k€ sur 18 mois, soit ~ 156 k€/an équivalent.

BÉNÉFICES ATTENDUS (récurrents annuels après mise en œuvre)

| Bénéfice | Montant annuel |
|---|---|
| Économies carburant (-8 %) | 38 k€ |
| Économies électricité (-25 %) | 7 k€ |
| Subventions véhicules électriques (one-shot) | 100 k€ |
| Argument commercial (+5-8 % CA top 10 clients) | 60 k€ |
| Réduction turnover (-3 pts) | 28 k€ |
| Réduction accidents (-15 % TF) | 12 k€ |
| Amortissement fiscal supplémentaire véhicules propres | 35 k€ |
| **Total bénéfices annuels récurrents** | **180 k€** |

ROI

| Indicateur | Valeur |
|---|---|
| Investissement total 18 mois | 574 k€ |
| Bénéfices an 1 (avec subventions) | 280 k€ |
| Bénéfices récurrents | 180 k€/an |
| Payback | ~ 24-30 mois |
| ROI 5 ans | x 1,5 |

INDICATEURS GLOBAUX DE RÉUSSITE À 18 MOIS

- Score ESG global : > 75/100 (vs 60 initial)
- Émissions CO2 : -10 % (vs 2024)
- Turnover : 12 % (vs 17 % initial)
- TF accidents : 22 (vs 28 initial)
- Index égalité H/F : 80 (vs 72 initial)
- 1 nouvelle certification minimum (Objectif CO2)

BÉNÉFICES INTANGIBLES

- Image de marque renforcée (LinkedIn, salons, presse)
- Attractivité RH (recrutement facilité)
- Anticipation réglementaire (CSRD, BEGES)
- Engagement des équipes (sentiment d''utilité)
- Différenciation commerciale durable

Le ROI brut est positif sur 30 mois, mais les bénéfices intangibles et la pérennité de l''entreprise face aux évolutions réglementaires justifient pleinement la démarche dès aujourd''hui. Les chargeurs grands comptes vont de plus en plus exiger ces démarches, et les retardataires perdront mécaniquement leur place.'),
  (v_formation, 'qr', 'Vous devez choisir entre 4 options de transition énergétique pour 5 véhicules à renouveler : tout diesel, mix diesel/électrique, mix électrique/GNV/hydrogène, ou tout zéro émission. Comparez en termes d''investissement, autonomie, ROI 5 ans, et impacts RSE.', NULL, 1, 'difficile', ARRAY['transition','arbitrage','energie'], 'mft-2026-gotrm:bc03-02:qr:2', true, 'COMPARAISON DES 4 OPTIONS — 5 VÉHICULES À RENOUVELER

OPTION 1 — TOUT DIESEL (5 véhicules diesel)

Caractéristiques :
- Investissement : 5 × 95 k€ = 475 k€
- Autonomie : 1 000+ km
- Coût km : 1,30 €/km
- Émissions Scope 1 : 388 tCO2/an
- Crit''Air : 2 (limite ZFE après 2026)

Avantages :
- Investissement maîtrisé
- Technologie mature
- Autonomie sans contrainte

Inconvénients :
- Pas d''adaptation ZFE
- Coûts énergétiques élevés
- Pas de bénéfice RSE
- Risque réglementaire

ROI 5 ans : +250 k€ marge brute (sans considérer pénalités ZFE)

OPTION 2 — MIX DIESEL + ÉLECTRIQUE (3 diesel + 2 électriques)

Caractéristiques :
- Investissement : 3 × 95 + 2 × 220 (HT) = 285 + 440 = 725 k€
- Aides ADEME (50 k€/véhicule électrique) : -100 k€
- Suramortissement (40 % × 440 k€ × 25 % impôt) : économie 44 k€
- Net : 725 - 100 - 44 = 581 k€
- Autonomie diesel : 1 000+ km, électrique : 250 km
- Émissions Scope 1 : 232 tCO2/an (-40 %)
- Crit''Air : 2 (diesel) + E (électrique)

Avantages :
- Bénéfice RSE significatif
- Adaptation partielle ZFE
- Différentiation commerciale (premium)
- Apprentissage progressif

Inconvénients :
- Investissement plus élevé
- Gestion 2 technologies
- Contrainte autonomie sur certains trajets

ROI 5 ans : +350 k€ marge brute (incluant économies + premium)

OPTION 3 — MIX ÉQUILIBRÉ (1 électrique + 2 GNV + 1 hydrogène + 1 diesel)

Caractéristiques :
- Investissement : 220 + 2 × 110 + 280 + 95 = 815 k€
- Aides : -150 k€
- Suramortissement : -56 k€
- Net : 609 k€
- Autonomies variées : 250 km / 600 km / 700 km / 1 000+ km
- Émissions Scope 1 : 175 tCO2/an (-55 %)
- Crit''Air : E + 1 + E + 2

Avantages :
- Diversification technologique (apprentissage)
- Image RSE forte
- Adaptation à différents profils mission
- Anticipation 2030

Inconvénients :
- Investissement très élevé
- Gestion complexe (4 technologies)
- Maintenance multi-techno
- Risque hydrogène (techno naissante)

ROI 5 ans : +280 k€ marge brute (mais bénéfice intangible image fort)

OPTION 4 — TOUT ZÉRO ÉMISSION (3 électriques + 2 GNV)

Caractéristiques :
- Investissement : 3 × 220 + 2 × 110 = 880 k€
- Aides : -190 k€
- Suramortissement : -68 k€
- Net : 622 k€
- Autonomie électrique : 250 km, GNV : 600 km
- Émissions Scope 1 : 60 tCO2/an (-85 %)
- Crit''Air : E + 1

Avantages :
- Impact RSE maximal
- Accès ZFE total
- Premium commercial maximum (+15 %)
- Image visionnaire

Inconvénients :
- Investissement majeur
- Limites d''autonomie sur longues distances
- Exigeant en infrastructure (recharge, station GNV)
- Apprentissage massif requis

ROI 5 ans : +400 k€ marge brute (incluant gros premium et nouveaux clients ZFE)

SYNTHÈSE COMPARATIVE

| Critère | Option 1 (diesel) | Option 2 (mix élec/diesel) | Option 3 (mix équilibré) | Option 4 (zéro émission) |
|---|---|---|---|---|
| Investissement net | 475 k€ | 581 k€ | 609 k€ | 622 k€ |
| Émissions CO2 (vs option 1) | 100 % | -40 % | -55 % | -85 % |
| Adaptation ZFE | 0 % | 40 % | 60 % | 100 % |
| Image RSE | Faible | Modéré | Élevée | Très élevée |
| Risque techno | Aucun | Modéré (élec) | Élevé (H2) | Modéré |
| ROI 5 ans (marge brute) | +250 k€ | +350 k€ | +280 k€ | +400 k€ |

DÉCISION RECOMMANDÉE

OPTION 2 — MIX DIESEL + ÉLECTRIQUE (3 + 2)

Justifications :
1. ROI très favorable (350 k€ sur 5 ans pour +106 k€ d''investissement vs option 1)
2. Image RSE significative pour différentiation commerciale
3. Adaptation partielle aux ZFE (40 % de la flotte)
4. Risque technologique maîtrisé (électrique mature, diesel en complément)
5. Apprentissage progressif des équipes
6. Diversification commerciale (clients ZFE + clients nationaux)

OPTION 4 — À CONSIDÉRER SI :

- Volonté forte de leadership RSE
- Capacité financière importante
- Marché client orienté ZFE et RSE
- Stratégie long terme déjà claire

OPTION 1 — À ÉVITER

Risque réglementaire et concurrentiel important. Les Crit''Air 2 seront interdits dans la plupart des grandes ZFE entre 2026 et 2028. Sans adaptation, perte d''accès aux centres urbains.

OPTION 3 — TROP RISQUÉE EN PHASE INITIALE

L''hydrogène est une technologie naissante. Mieux vaut différer son intégration de 2-3 ans pour profiter de la baisse des prix et du développement du réseau.

PLAN DE DÉPLOIEMENT (option 2)

M+0 : Validation du choix, signature commandes
M+1 à M+3 : Diesel livrés, mise en service immédiate
M+3 à M+6 : Électriques livrés, formation conducteurs
M+6 à M+9 : Mise en service progressive électriques
M+9 à M+12 : Optimisation, premier bilan
M+12 à M+24 : Capitalisation, préparation des 2-3 véhicules suivants

ÉVOLUTION SUR 5 ANS

À 3 ans : 2 électriques + 3 diesel
À 5 ans : 4-5 électriques + 1-2 diesel + 1 GNV (intégration progressive)
À 10 ans : flotte essentiellement zéro émission

Cette stratégie progressive permet :
- Maîtrise des risques
- Apprentissage des équipes
- Optimisation des coûts (baisse progressive des prix électrique)
- Adaptation aux évolutions réglementaires
- Préservation de la trésorerie

CONCLUSION

L''option 2 (mix diesel/électrique) est le meilleur compromis pour la majorité des PME en 2026 : ROI immédiat, image RSE, anticipation réglementaire, risque maîtrisé. Elle constitue le tremplin idéal vers une flotte plus largement décarbonée à l''horizon 2030-2035.'),
  (v_formation, 'qr', 'Décrivez l''adaptation complète de votre flotte aux ZFE sur 5 ans (12 véhicules dont 5 livrent quotidiennement Paris/Lyon centres). Plan d''adaptation, investissements, opportunités commerciales et bilan ROI.', NULL, 1, 'difficile', ARRAY['zfe','plan-5-ans','roi'], 'mft-2026-gotrm:bc03-02:qr:3', true, 'PLAN D''ADAPTATION ZFE — FLOTTE 12 VÉHICULES SUR 5 ANS

CONTEXTE INITIAL

Composition de la flotte :
- 5 véhicules livrent quotidiennement Paris ou Lyon centres (zone ZFE)
  - 3 porteurs 12 t Crit''Air 2 (acquis 2018, 5-7 ans)
  - 2 porteurs 12 t Crit''Air 3 (acquis 2014, 9-11 ans)
- 7 véhicules régionaux hors ZFE
  - 4 porteurs 19 t Crit''Air 2
  - 3 tracteurs 44 t Crit''Air 1 ou 2

Calendrier ZFE attendu :
- 2026 : Crit''Air 3 INTERDITS (2 véhicules concernés)
- 2028 : Crit''Air 2 INTERDITS (3 véhicules supplémentaires + 4 hors ZFE)
- 2030 : Seuls Crit''Air E et 1 autorisés

PLAN SUR 5 ANS

ANNÉE 1 (2026) — URGENCE CRIT''AIR 3

Actions immédiates :
- Vente des 2 Crit''Air 3 (récupération 30 k€/véhicule = 60 k€)
- Acquisition de 2 porteurs 12 t électriques pour distribution Paris/Lyon
  - Prix HT : 2 × 220 k€ = 440 k€
  - Aides ADEME (50 k€) + Île-de-France (15 k€) : -130 k€
  - Net : 310 k€

Bénéfices :
- Aucune perte d''accès ZFE
- Économies carburant : 2 × 22 k€/an = 44 k€/an
- Différentiation commerciale (premium "vert" 8 % sur 2 clients)
- Image renforcée

Investissement net an 1 : 310 - 60 (vente) = 250 k€

ANNÉE 2-3 (2027-2028) — ANTICIPATION CRIT''AIR 2

Actions :
- Renouvellement progressif des 3 Crit''Air 2 ZFE par 3 véhicules propres :
  - 2 électriques (260 k€ × 2 - 130 k€ aides = 390 k€)
  - 1 GNV (140 k€ - 25 k€ aides = 115 k€)
- Vente des 3 Crit''Air 2 sortants : 3 × 25 k€ = 75 k€

Investissement net : 505 - 75 = 430 k€

Bénéfices an 2-3 :
- Anticipation interdiction Crit''Air 2 en 2028
- Économies carburant accrues
- Premium commercial étendu à 5 clients

ANNÉE 4 (2029) — ADAPTATION FLOTTE RÉGIONALE

Actions :
- Renouvellement des 4 véhicules régionaux Crit''Air 2 par GNV :
  - 4 × 140 k€ - 4 × 25 k€ aides = 460 k€
- Vente des 4 Crit''Air 2 sortants : 4 × 30 k€ = 120 k€

Investissement net : 460 - 120 = 340 k€

Bénéfices an 4 :
- Préparation 2030 (Crit''Air 1 obligatoire)
- Économies carburant régional
- Image RSE consolidée

ANNÉE 5 (2030) — FINALISATION

Actions :
- Renouvellement des 3 tracteurs 44 t Crit''Air 1/2 par bioGNV :
  - 3 × 200 k€ - 3 × 30 k€ aides = 510 k€
- Vente des 3 tracteurs sortants : 3 × 50 k€ = 150 k€

Investissement net : 510 - 150 = 360 k€

Bénéfices an 5 :
- Conformité ZFE 2030 totale
- Émissions Scope 1 réduites de 70 % vs 2025
- Premium commercial maximum
- Avant-garde sectorielle

INVESTISSEMENT TOTAL 5 ANS

| Année | Investissement net | Total cumulé |
|---|---|---|
| 1 | 250 k€ | 250 k€ |
| 2-3 | 430 k€ | 680 k€ |
| 4 | 340 k€ | 1 020 k€ |
| 5 | 360 k€ | 1 380 k€ |
| **Total 5 ans** | **1 380 k€** | |

Soit ~ 276 k€/an d''investissement net.

OPPORTUNITÉS COMMERCIALES ACTIVÉES

a. Premium "vert" sur clients existants
- An 1 : 2 clients × 12 % CA = 30 k€/an
- An 3 : 5 clients × 12 % = 75 k€/an
- An 5 : 10 clients × 15 % = 150 k€/an

b. Conquête de nouveaux clients ZFE
- An 2 : 3 nouveaux clients × 25 k€/an = 75 k€/an
- An 4 : 6 nouveaux clients × 30 k€/an = 180 k€/an

c. Conservation des clients existants menacés par les ZFE
- Sans adaptation : perte estimée 200-400 k€/an de CA en 2028
- Avec adaptation : 0 perte

ÉCONOMIES OPÉRATIONNELLES

| Source | Annuel an 5 |
|---|---|
| Économies carburant (-25 %) | 90 k€ |
| Économies maintenance (-15 % véhicules récents) | 25 k€ |
| Suramortissement fiscal (cumulé) | 60 k€/an |
| Total | 175 k€/an |

BILAN GLOBAL 5 ANS

| Indicateur | Valeur |
|---|---|
| Investissement total | 1 380 k€ |
| Bénéfices commerciaux récurrents an 5 | 330 k€/an |
| Économies opérationnelles an 5 | 175 k€/an |
| Total bénéfices an 5 | 505 k€/an |
| ROI 5 ans (cumul bénéfices) | 1 800 k€ |
| Net (bénéfices - investissement) | +420 k€ sur 5 ans |
| Payback | ~ 4,2 ans |

Sur 10 ans (avec véhicules amortis) :
- ROI : x 3,5
- Bénéfices nets cumulés : ~ 4-5 M€

INDICATEURS RSE À 5 ANS

| Indicateur | 2025 | 2030 |
|---|---|---|
| Émissions CO2 (Scope 1) | 1 050 tCO2 | 320 tCO2 (-70 %) |
| % flotte zéro émission | 0 % | 33 % |
| % flotte Crit''Air 1 et plus | 8 % | 100 % |
| Conso moyenne flotte | 30,5 L/100 km | 25,5 L/100 km |
| Vignette moyenne | Crit''Air 2,5 | Crit''Air 1 |

RISQUES ET MITIGATION

Risque 1 — Évolution réglementaire plus rapide
- Mitigation : surveillance trimestrielle, capacité d''accélérer

Risque 2 — Hausse des coûts énergie
- Mitigation : RPC, mix énergétique diversifié, autoconsommation

Risque 3 — Adoption ralentie de l''électrique
- Mitigation : pilote progressif, formation, partenariat infrastructures

Risque 4 — Perte de compétitivité prix vs concurrents diesel
- Mitigation : argumentation RSE, premium "vert", clients orientés RSE

Risque 5 — Difficultés de financement
- Mitigation : étalement progressif, mix achat / leasing, négociation banques

CONCLUSION

Cette stratégie d''adaptation aux ZFE sur 5 ans transforme une menace réglementaire en avantage concurrentiel :

- Conservation totale de l''accès aux centres urbains
- Différentiation commerciale durable
- Anticipation des évolutions réglementaires (2030 et au-delà)
- ROI net positif sur 5 ans + considérable sur 10 ans
- Image RSE renforcée
- Préparation à la trajectoire de neutralité carbone 2050

Sans cette stratégie, l''entreprise perdrait mécaniquement son accès aux ZFE et 30-50 % de son chiffre d''affaires d''ici 2028-2030. C''est un investissement de survie autant qu''une opportunité de leadership.

L''ADAPTATION AUX ZFE N''EST PAS UNE CHARGE — C''EST UNE OBLIGATION STRATÉGIQUE PROFITABLE.'),
  (v_formation, 'qr', 'Construisez un tableau de bord ESG complet pour votre PME 30 véhicules avec 12 KPI répartis sur les 3 piliers, leurs cibles, sources de données, fréquences de mesure et plans d''action en cas d''écart.', NULL, 1, 'difficile', ARRAY['tableau-bord','esg','kpi'], 'mft-2026-gotrm:bc03-02:qr:4', true, 'TABLEAU DE BORD ESG COMPLET — PME 30 VÉHICULES

12 KPI ESG ESSENTIELS

PILIER ENVIRONNEMENTAL (4 KPI)

KPI 1 — Émissions CO2 totales (Scope 1)
- Cible : -10 % an 1, -25 % à 5 ans (vs base 2025)
- Périodicité : Mensuelle
- Source : Litres carburant achetés × 2,52 kg CO2eq/L (gazole) ou 2,1 (GNV) ou 0,07 (électricité Mix France)
- Plan d''action écart : audit consommations véhicules, formation éco-conduite, optimisation tournées

KPI 2 — Intensité CO2 par tonne.km
- Cible : 80 gCO2/t.km, vs 110 gCO2/t.km initial
- Périodicité : Trimestrielle
- Source : Émissions / (Tonnes transportées × Km commerciaux)
- Plan d''action écart : Optimisation chargement, réduction retour à vide, véhicules plus efficients

KPI 3 — % flotte zéro émission
- Cible : 10 % an 2, 30 % an 5, 50 % à 2030
- Périodicité : Annuelle (avec mise à jour mensuelle si nouveaux véhicules)
- Source : Composition du parc, vignettes Crit''Air
- Plan d''action écart : Plan de renouvellement, négociation aides, formation équipes

KPI 4 — Consommation moyenne flotte (L/100 km)
- Cible : 27 L/100 km moyenne pondérée
- Périodicité : Mensuelle
- Source : Litres consommés / km parcourus (par véhicule, pondéré)
- Plan d''action écart : Éco-conduite, maintenance préventive, scoring conducteurs

PILIER SOCIAL (5 KPI)

KPI 5 — Turnover conducteurs
- Cible : < 12 % annuel
- Périodicité : Mensuelle (cumul rolling 12 mois)
- Source : Système RH (départs / effectif moyen)
- Plan d''action écart : Audit climat, augmentation salariale, plan fidélisation, prime ancienneté

KPI 6 — Absentéisme
- Cible : < 5 %
- Périodicité : Mensuelle
- Source : Système de paie (heures absence / heures théoriques)
- Plan d''action écart : Ergonomie, prévention santé, écoute des équipes, équipement renforcé

KPI 7 — Taux de fréquence (TF) accidents du travail
- Cible : < 22 (norme secteur ~ 28)
- Périodicité : Trimestrielle (cumul rolling 12 mois)
- Source : Registre AT × 1 000 000 / heures travaillées
- Plan d''action écart : Renforcement formation sécurité, audit ergonomie, équipement, briefings

KPI 8 — Index égalité H/F
- Cible : > 80/100
- Périodicité : Annuelle (calcul DGCCRF)
- Source : Calcul officiel (écarts salaires, augmentations, promotions, retours congé maternité, top 10)
- Plan d''action écart : Recrutement actif femmes, plan d''augmentation ciblé, sensibilisation managers

KPI 9 — Heures de formation par salarié
- Cible : > 18 h/an
- Périodicité : Trimestrielle (cumul annuel)
- Source : Système RH / paie / fournisseurs formation
- Plan d''action écart : Plan annuel structuré, validation budgétaire, communication

PILIER GOUVERNANCE (3 KPI)

KPI 10 — % collaborateurs ayant signé le code de conduite
- Cible : 100 %
- Périodicité : Annuelle
- Source : Système RH / signatures
- Plan d''action écart : Relances ciblées, formation refresher, intégration au processus d''accueil

KPI 11 — % fournisseurs RSE évalués
- Cible : 60 % an 1, 80 % an 3
- Périodicité : Annuelle
- Source : Tableau de suivi achats responsables
- Plan d''action écart : Plan d''évaluation, intégration aux AO, formation acheteurs

KPI 12 — Score EcoVadis
- Cible : Bronze (50/100) an 1, Silver (60/100) an 3, Gold (75/100) an 5
- Périodicité : Annuelle (renouvellement EcoVadis)
- Source : Évaluation EcoVadis
- Plan d''action écart : Audit interne, renforcement actions sur axes faibles, accompagnement consultant

FORMAT DU TABLEAU DE BORD

PRÉSENTATION TYPE (1 page)

```
TABLEAU DE BORD ESG — TRIMESTRE [N] - [ANNÉE]

ENVIRONNEMENT
- Émissions Scope 1 : 432 tCO2 (-2 % vs T-1) 🟩
- Intensité CO2/t.km : 95 g (cible 90) 🟧
- % flotte zéro émission : 7 % (cible 10 %) 🟧
- Conso moyenne : 28,1 L (cible 27,5) 🟧

SOCIAL
- Turnover : 14 % (cible 12 %) 🟧
- Absentéisme : 5,2 % (cible 5 %) 🟧
- TF accidents : 21 (cible 22) 🟩
- Index égalité H/F : 78 (cible 80) 🟧
- Heures formation : 16 h (cible 18) 🟧

GOUVERNANCE
- Code conduite : 100 % 🟩
- Audit fournisseurs : 45 % (cible 60 %) 🟧
- Score EcoVadis : 55 (Bronze, cible 50) 🟩

SCORE ESG GLOBAL : 73/100 (cible 75)
TENDANCE : ↗ vs T-1

ALERTES :
- Conso moyenne en stagnation depuis 2 trimestres
- Index égalité en retard (recrutement actif requis)

ACTIONS DÉCIDÉES :
- Renforcement programme éco-conduite (5 nouveaux conducteurs)
- Plan de recrutement spécifique femmes (5 postes ouverts)
- Audit fournisseurs accéléré (10 nouveaux fournisseurs sur le trimestre)
```

GOUVERNANCE DU TABLEAU DE BORD

Niveau opérationnel (mensuel) :
- Diffusion aux managers
- Identification des écarts
- Actions correctives immédiates

Niveau direction (trimestriel) :
- Comité ESG (60-90 min)
- Revue complète des 12 KPI
- Validation des plans d''action

Niveau gouvernance (annuel) :
- Rapport RSE complet
- Présentation conseil d''administration
- Communication parties prenantes

OUTILS RECOMMANDÉS

a. Sources de données
- TMS pour KPI opérationnels
- Système paie pour KPI RH
- Comptabilité pour KPI environnementaux (factures carburant)
- CRM pour KPI clients
- Outil dédié RSE (Carbio, Greenly, Sweep)

b. Visualisation
- Power BI / Looker Studio
- Tableau de bord temps réel
- Mobile pour direction

c. Reporting
- Templates Word / PowerPoint
- Site web dédié
- LinkedIn et communication externe

PLAN D''ACTION GLOBAL EN CAS D''ALERTES

Niveau 1 — KPI orange (entre cible et seuil critique)
- Plan d''action interne avec responsable nommé
- Suivi hebdomadaire jusqu''à retour au vert

Niveau 2 — KPI rouge (sous seuil critique)
- Comité d''alerte sous 7 jours
- Plan d''action formalisé sous 15 jours
- Reporting bi-mensuel direction

Niveau 3 — Plusieurs KPI rouges simultanément
- Audit complet (cabinet externe)
- Refonte du plan ESG
- Mobilisation tous les niveaux hiérarchiques

CALENDRIER DE PROGRESSION

| Indicateur | An 1 | An 3 | An 5 |
|---|---|---|---|
| Score ESG global | 65 | 75 | 85 |
| Émissions CO2 (vs base) | -10 % | -25 % | -40 % |
| % flotte zéro émission | 5 % | 20 % | 40 % |
| Turnover | 14 % | 11 % | 9 % |
| EcoVadis | Bronze | Silver | Gold |

LIENS AVEC LE DASHBOARD OPÉRATIONNEL EXISTANT

Le tableau de bord ESG complète (sans remplacer) le tableau de bord opérationnel-financier-client-RH. Il y a des intersections naturelles :
- Conso moyenne (op + ESG environnemental)
- Turnover (RH + ESG social)
- KPI clients (client + ESG via NPS, satisfaction)

L''intégration des deux est l''étape ultime de maturité (tableau de bord intégré stratégique).

CONCLUSION

Ce tableau de bord ESG :
- Mesure objectivement la performance durable
- Anticipe les obligations CSRD à venir
- Stimule l''amélioration continue
- Communique aux parties prenantes
- Différencie commercialement
- Prépare aux certifications

Sa qualité de mise en œuvre détermine la maturité RSE de l''entreprise. Bien construit, il devient un outil stratégique majeur pour l''évolution de l''entreprise vers un modèle plus durable et performant.');


  -- =================================================================
  -- QUIZZES
  -- =================================================================
  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_1, 'Quiz — RSE et certifications', 'gotrm-bc03-02-quiz-01', '3 piliers, ISO 14001, Objectif CO2, EcoVadis, Bilan Carbone.', 70, NULL, false, 1)
  RETURNING id INTO v_quiz_1;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc03-02:qcm:1','mft-2026-gotrm:bc03-02:qcm:2','mft-2026-gotrm:bc03-02:qcm:3','mft-2026-gotrm:bc03-02:qcm:4','mft-2026-gotrm:bc03-02:qcm:5','mft-2026-gotrm:bc03-02:qcm:18','mft-2026-gotrm:bc03-02:qcm:24');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_2, 'Quiz — Énergies alternatives', 'gotrm-bc03-02-quiz-02', 'Électrique, GNV/bioGNV, hydrogène, suramortissement, ADEME.', 70, NULL, false, 2)
  RETURNING id INTO v_quiz_2;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc03-02:qcm:6','mft-2026-gotrm:bc03-02:qcm:7','mft-2026-gotrm:bc03-02:qcm:8','mft-2026-gotrm:bc03-02:qcm:9','mft-2026-gotrm:bc03-02:qcm:10','mft-2026-gotrm:bc03-02:qcm:20');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_3, 'Quiz — ZFE et urbain', 'gotrm-bc03-02-quiz-03', 'Crit''Air, calendriers ZFE, dernier kilomètre, opportunités.', 70, NULL, false, 3)
  RETURNING id INTO v_quiz_3;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc03-02:qcm:11','mft-2026-gotrm:bc03-02:qcm:12','mft-2026-gotrm:bc03-02:qcm:13','mft-2026-gotrm:bc03-02:qcm:14','mft-2026-gotrm:bc03-02:qcm:21');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_4, 'Quiz — KPI rentabilité durable', 'gotrm-bc03-02-quiz-04', 'KPI ESG, CSRD, Bilan Carbone, neutralité carbone, reporting.', 70, NULL, false, 4)
  RETURNING id INTO v_quiz_4;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc03-02:qcm:15','mft-2026-gotrm:bc03-02:qcm:16','mft-2026-gotrm:bc03-02:qcm:17','mft-2026-gotrm:bc03-02:qcm:19','mft-2026-gotrm:bc03-02:qcm:22','mft-2026-gotrm:bc03-02:qcm:23','mft-2026-gotrm:bc03-02:qcm:25');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, NULL, 'Examen blanc — BC03-02 RSE et transition', 'gotrm-bc03-02-examen-blanc', '12 QCM en 25 min, seuil 50 %.', 50, 25, true, 5)
  RETURNING id INTO v_quiz_eb;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc03-02:qcm:1','mft-2026-gotrm:bc03-02:qcm:2','mft-2026-gotrm:bc03-02:qcm:5','mft-2026-gotrm:bc03-02:qcm:6','mft-2026-gotrm:bc03-02:qcm:8','mft-2026-gotrm:bc03-02:qcm:11','mft-2026-gotrm:bc03-02:qcm:12','mft-2026-gotrm:bc03-02:qcm:13','mft-2026-gotrm:bc03-02:qcm:15','mft-2026-gotrm:bc03-02:qcm:17','mft-2026-gotrm:bc03-02:qcm:21','mft-2026-gotrm:bc03-02:qcm:22');

  RAISE NOTICE '✅ GOTRM BC03-02 v2 chargé : 4 leçons, 25 QCM, 4 QR, 5 quizzes (4 entraînement + 1 examen blanc).';
  RAISE NOTICE '═══════════════════════════════════════════════════════';
  RAISE NOTICE '🎯 BLOC BC03 COMPLET (2 modules)';
  RAISE NOTICE '🎯 14/14 MODULES GOTRM CRÉÉS';
  RAISE NOTICE '═══════════════════════════════════════════════════════';
END
$bc03_02$;
