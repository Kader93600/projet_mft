-- =====================================================================
-- GOTRM (RNCP 40990) — BC02-02 : Suivi qualité, conformité et audit sous-traitants
-- KPI sous-traitants, audits, gestion conflits, désengagement.
-- =====================================================================

DO $bc02_02$
DECLARE
  v_formation uuid; v_bloc int; v_module uuid;
  v_lesson_1 uuid; v_lesson_2 uuid; v_lesson_3 uuid; v_lesson_4 uuid;
  v_quiz_1 uuid; v_quiz_2 uuid; v_quiz_3 uuid; v_quiz_4 uuid; v_quiz_eb uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc.'; END IF;

  DELETE FROM public.modules WHERE slug = 'gotrm-bc02-02-suivi-audit-soustraitants';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'BC02-02 — Suivre la qualité, la conformité et auditer les sous-traitants',
    'gotrm-bc02-02-suivi-audit-soustraitants', v_bloc,
    'Pilotage des KPI sous-traitants, audits conformité semestriels, plans d''amélioration, gestion des conflits et désengagement maîtrisé.',
    'intermediaire', 150, 120
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 120, true) ON CONFLICT DO NOTHING;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc02-02:%';

  -- =================================================================
  -- LEÇON 1 — KPI et reporting sous-traitants
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'KPI et reporting des sous-traitants',
    'gotrm-bc02-02-01-kpi-reporting', 1, 40,
$lesson1$
# KPI et reporting des sous-traitants

Mesurer la performance des sous-traitants est le préalable à toute amélioration. Un système de KPI clair, partagé et suivi régulièrement transforme une relation passive en partenariat actif.

> 🎯 **Objectifs de la leçon**
>
> - Définir les **KPI** essentiels du suivi sous-traitants.
> - Construire un **scorecard** par sous-traitant.
> - Mettre en place le **reporting mensuel**.
> - Gérer le **benchmarking** entre sous-traitants.

---

## 1. Les KPI essentiels

### 1.1 KPI opérationnels

| KPI | Cible | Période |
|---|---|---|
| Ponctualité (RDV ±60 min) | > 95 % | Mensuelle |
| Intégrité (% sans avarie) | > 99,5 % | Mensuelle |
| Conformité documentaire | > 99 % | Mensuelle |
| Communication ETA temps réel | 100 % missions | Mensuelle |
| Délai réponse incident | < 4 h ouvrées | Mensuelle |

### 1.2 KPI financiers

| KPI | Cible | Période |
|---|---|---|
| Exactitude facturation | > 99,5 % | Mensuelle |
| Délai facturation | < 7 j fin de mois | Mensuelle |
| Litiges facturation | < 1 % | Trimestrielle |

### 1.3 KPI qualité

| KPI | Cible | Période |
|---|---|---|
| Taux d'incidents majeurs | < 0,5 % | Mensuelle |
| Taux de réclamations clients | < 1 % | Mensuelle |
| Réactivité plan d'action | < 7 j | Trimestrielle |

### 1.4 KPI conformité

| KPI | Cible | Période |
|---|---|---|
| Validité pièces administratives | 100 % | Semestrielle |
| Validité licences transport | 100 % | Annuelle |
| Validité formations (CQC FCO, ADR) | 100 % | Trimestrielle |

---

## 2. Le scorecard sous-traitant

### 2.1 Format type

```
SCORECARD SOUS-TRAITANT — [NOM] - [MOIS / ANNÉE]

PERFORMANCE OPÉRATIONNELLE
- Ponctualité : 96,2 % (cible > 95 %) 🟩
- Intégrité : 99,8 % (cible > 99,5 %) 🟩
- Conformité doc : 98,5 % (cible > 99 %) 🟧
- Délai réponse incident : 6 h (cible < 4 h) 🟧

CONFORMITÉ
- Pièces administratives à jour : 100 % 🟩
- CQC FCO valides : 100 % 🟩
- Licence transport : OK 🟩

QUALITÉ
- Incidents majeurs : 1 (cible < 0,5 %) 🟩
- Réclamations clients : 2 (cible < 1 %) 🟩

SCORE GLOBAL : 89/100 (sur 100)
TENDANCE : ↗ vs M-1

ACTIONS MOIS :
- Plan d'amélioration conformité documentaire
- Formation conducteurs sur incident process
```

### 2.2 Le score global

Calculé sur 100 points selon la pondération :
- Performance opérationnelle : 50 points
- Conformité : 25 points
- Qualité : 15 points
- Innovation/RSE : 10 points

| Score | Statut |
|---|---|
| > 90 | Excellence |
| 75-90 | Performant |
| 60-75 | À surveiller |
| < 60 | Plan d'action urgent |

---

## 3. Le reporting mensuel

### 3.1 Format diffusion

| Niveau | Format | Délai |
|---|---|---|
| Direction sous-traitant | Scorecard détaillé | J+5 |
| Exploitation | Tableau analytique | J+2 |
| Direction donneur d'ordre | Synthèse + tendances | J+8 |

### 3.2 Comité mensuel

Réunion 60 min avec sous-traitant, ordre du jour standard :
- Revue scorecard (15 min)
- Analyse des écarts (15 min)
- Suivi plans d'action en cours (10 min)
- Nouvelles décisions (15 min)
- Conclusion (5 min)

---

## 4. Le benchmarking

### 4.1 Comparaison entre sous-traitants

Tableau comparatif mensuel pour les sous-traitants d'un même segment :

| Sous-traitant | Ponctualité | Intégrité | Score global | Évolution |
|---|---|---|---|---|
| A | 97,2 % | 99,9 % | 92 | ↗ |
| B | 95,5 % | 99,5 % | 87 | → |
| C | 93,1 % | 98,8 % | 78 | ↘ |
| D | 96,8 % | 99,7 % | 90 | ↗ |
| Moyenne | 95,7 % | 99,5 % | 87 | → |

### 4.2 Animation par benchmarking

- Communiquer la position relative (anonymisée si nécessaire)
- Identifier les meilleures pratiques du leader
- Inviter les autres à s'inspirer
- Récompenser symboliquement le leader (mention, contrat élargi)

---

## 5. Cas pratique : tableau de bord 8 sous-traitants

**Contexte** : Vous suivez 8 sous-traitants. KPI moyenne du panel :
- Ponctualité 94,5 %, intégrité 99,3 %, conformité 98,1 %
- Score global 84/100

Distribution :
- 2 leaders : > 90/100
- 4 médians : 80-90
- 1 surveillance : 70-80
- 1 critique : < 60

### Plan d'action

| Profil | Action |
|---|---|
| 2 Leaders | Augmentation volumes + bonus contractuel |
| 4 Médians | Plan d'amélioration ciblé sur 1 KPI |
| 1 Surveillance | Audit terrain immédiat + plan 6 mois |
| 1 Critique | Mise en demeure + plan 90 jours strict, sinon désengagement |

---

> ✅ **À retenir**
>
> - **KPI 4 dimensions** : opérationnels, financiers, qualité, conformité.
> - **Scorecard mensuel** sur 100 points avec score global.
> - **Comité mensuel** 60 min standardisé.
> - **Benchmarking** entre sous-traitants pour stimuler la performance.
$lesson1$,
'KPI 4 dimensions, scorecard sur 100 points, comité mensuel 60 min, benchmarking inter-sous-traitants.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Audits conformité
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Audits de conformité semestriels',
    'gotrm-bc02-02-02-audits-conformite', 2, 40,
$lesson2$
# Audits de conformité semestriels

Au-delà de la performance opérationnelle, les audits de conformité vérifient le respect des obligations légales et contractuelles. C'est une protection pour le donneur d'ordre face aux risques de complicité.

> 🎯 **Objectifs de la leçon**
>
> - Maîtriser le **calendrier** des audits.
> - Construire une **grille d'audit** complète.
> - Mener un **audit terrain** structuré.
> - Documenter les **constats** et le suivi.

---

## 1. Le calendrier des audits

### 1.1 Audit semestriel administratif

Obligation L. 8222-1 : vérification tous les 6 mois.

| Document | Vérification |
|---|---|
| KBIS | Récent, pas de modification suspecte |
| Attestation URSSAF de vigilance | < 6 mois |
| Attestation fiscale | À jour |
| DPAE | Cohérence avec le parc et le volume |
| Licence transport | Validité (LTI / LTM) |

### 1.2 Audit annuel terrain

Visite physique des locaux du sous-traitant :
- État du parc et des équipements
- Organisation et procédures
- Climat social
- Sécurité, ergonomie

### 1.3 Audit thématique

Selon l'actualité :
- ADR (matières dangereuses) : avant chaque renouvellement
- ATP (température dirigée) : annuel + sur incident
- Sécurité (accidents) : sur déclenchement
- Cybersécurité : annuel pour les sous-traitants connectés au TMS

---

## 2. La grille d'audit type

### 2.1 Section 1 — Documents administratifs (20 points)

| Élément | Points |
|---|---|
| KBIS récent | 4 |
| URSSAF | 4 |
| Fiscalité | 4 |
| DPAE | 4 |
| Bulletins n°2 dirigeants | 2 |
| RC professionnelle | 2 |

### 2.2 Section 2 — Conformité véhicules (25 points)

| Élément | Points |
|---|---|
| Cartes grises à jour | 5 |
| Contrôles techniques valides | 5 |
| Certificats d'agrément (ADR/ATP) | 5 |
| Plaques ATP en cours | 5 |
| Cartes tachygraphes | 5 |

### 2.3 Section 3 — Conducteurs (25 points)

| Élément | Points |
|---|---|
| CQC FCO < 5 ans | 8 |
| Permis CE valides | 5 |
| ADR conducteurs (selon véhicules) | 5 |
| Cartes conducteurs tachygraphes | 4 |
| Visites médicales | 3 |

### 2.4 Section 4 — Procédures et qualité (15 points)

| Élément | Points |
|---|---|
| Procédure incident documentée | 4 |
| Plan formation continu | 4 |
| Politique qualité (ISO 9001 ou démarche) | 4 |
| Tableau de bord interne | 3 |

### 2.5 Section 5 — Conformité spécifique (15 points)

| Élément | Points |
|---|---|
| ADR : équipement, formation, attestations | 5 |
| ATP : enregistrement, calibration, plaque | 5 |
| RGPD : registre, charte, DPO si nécessaire | 5 |

**Total : 100 points**

| Score | Statut |
|---|---|
| > 90 | Conforme exemplaire |
| 80-90 | Conforme |
| 70-80 | À surveiller |
| < 70 | Non-conformité — plan d'action urgent |

---

## 3. La conduite d'un audit terrain

### 3.1 Préparation (J-7)

- Annonce officielle au sous-traitant (sauf audits inopinés)
- Demande des documents en amont
- Préparation de la grille
- Choix de l'auditeur (interne, externe ou mixte)

### 3.2 Déroulement (J0, demi-journée)

| Étape | Durée |
|---|---|
| 1. Réunion d'ouverture | 30 min |
| 2. Revue des documents | 60 min |
| 3. Visite des locaux | 30 min |
| 4. Visite du parc | 30 min |
| 5. Échanges avec opérationnels | 45 min |
| 6. Réunion de clôture | 30 min |

### 3.3 Posture de l'auditeur

| À faire | À éviter |
|---|---|
| Bienveillance et professionnalisme | Hostilité, condescendance |
| Questions précises et factuelles | Questions piège |
| Vérification croisée | Confiance aveugle |
| Documentation systématique | Notes mentales seulement |

---

## 4. Le rapport d'audit

### 4.1 Structure type (10-15 pages)

1. Synthèse exécutive (1 page)
2. Périmètre et méthode (1 page)
3. Constats par section (5-8 pages)
4. Score global et benchmarking (1 page)
5. Recommandations et plan d'action (2-3 pages)
6. Annexes (documents, photos)

### 4.2 Classification des constats

| Type | Définition | Action |
|---|---|---|
| **Non-conformité majeure** | Risque légal, financier, sécuritaire | Régularisation < 30 j |
| **Non-conformité mineure** | Écart sans impact immédiat | Régularisation < 90 j |
| **Observation** | Point d'amélioration | Plan à moyen terme |
| **Bonne pratique** | À documenter et partager | Capitalisation |

### 4.3 Diffusion

- Au sous-traitant : intégral
- Direction donneur d'ordre : intégral
- Comité de pilotage : synthèse exécutive
- Archives : conservation 5 ans minimum

---

## 5. Le suivi des actions

### 5.1 Tableau de suivi

```
SUIVI DES ACTIONS POST-AUDIT — SOUS-TRAITANT [NOM]

Audit du : [date]
Score : 78/100

| Action | Type | Échéance | Statut | Validation |
|---|---|---|---|---|
| Renouveler attestation URSSAF | NC majeure | J+15 | ✅ Fait | OK |
| Former 2 conducteurs au FCO | NC mineure | J+60 | 🟧 En cours | À J+45 |
| Documenter procédure incident | Observation | J+90 | 🟩 Démarré | À J+60 |
| ... | ... | ... | ... | ... |
```

### 5.2 Audit de suivi

À J+90 ou J+180 selon les actions :
- Vérification de la mise en œuvre
- Mesure de l'évolution du score
- Décision sur la continuité de la collaboration

---

> ✅ **À retenir**
>
> - **Audit semestriel** administratif (L. 8222-1) + **annuel** terrain.
> - **Grille de 100 points** sur 5 sections (administratif, véhicules, conducteurs, procédures, spécifique).
> - **Audit terrain** demi-journée : ouverture, documents, locaux, parc, échanges, clôture.
> - **Constats** classifiés en 4 niveaux : NC majeure (30 j), NC mineure (90 j), observation, bonne pratique.
> - **Suivi** par tableau de bord, audit de suivi à 3-6 mois.
$lesson2$,
'Calendrier (semestriel administratif, annuel terrain), grille 100 points sur 5 sections, conduite audit demi-journée, rapport structuré, classification des constats.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Plans d'amélioration et gestion des conflits
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Plans d''amélioration et gestion des conflits',
    'gotrm-bc02-02-03-amelioration-conflits', 3, 35,
$lesson3$
# Plans d'amélioration et gestion des conflits

Quand un sous-traitant glisse en performance, un plan d'amélioration construit collaborativement permet souvent de redresser la situation. À défaut, savoir gérer les conflits maintient la qualité de service.

> 🎯 **Objectifs de la leçon**
>
> - Construire un **plan d'amélioration** efficace.
> - Mener une **réunion de recadrage**.
> - Désamorcer les **conflits** avec un sous-traitant.
> - Décider d'une **escalade** si nécessaire.

---

## 1. Le plan d'amélioration

### 1.1 Quand le déclencher ?

- Score scorecard < 75/100 sur 2 mois consécutifs
- Non-conformité majeure post-audit
- Plainte client significative
- Évolution dégradée d'un KPI clé

### 1.2 Construction co-élaborée

L'erreur classique : imposer le plan unilatéralement. La bonne pratique : **co-construire** avec le sous-traitant pour engagement réel.

| Étape | Action |
|---|---|
| 1. Diagnostic partagé | Présenter les chiffres factuels, écouter les explications |
| 2. Identification causes racines | 5 pourquoi, Ishikawa, Pareto |
| 3. Définition objectifs SMART | Cibles chiffrées, datées |
| 4. Actions concrètes | Qui fait quoi, échéance, coût |
| 5. Indicateurs de mesure | Pour suivre le progrès |
| 6. Engagement écrit | Signé par les 2 parties |

### 1.3 Format type

```
PLAN D'AMÉLIORATION SOUS-TRAITANT [NOM]

Période : [date début] - [date fin]
Référent donneur d'ordre : [nom]
Référent sous-traitant : [nom]

CONSTAT
- Score scorecard : 68/100 (M-1) vs cible 80
- KPI principal en alerte : Ponctualité 89 % (cible 95 %)

CAUSES IDENTIFIÉES (analyse 5 pourquoi)
- Manque de conducteurs (2 départs récents non remplacés)
- Conducteurs intérimaires moins efficaces sur la ligne
- Conditions hivernales : alertes télématique non utilisées

OBJECTIFS À 90 JOURS
- Ponctualité ≥ 93 % (cible intermédiaire)
- Score global ≥ 75/100

ACTIONS
1. Recrutement 2 conducteurs (échéance 30 j) [sous-traitant]
2. Formation accélérée intérimaires (15 j) [sous-traitant]
3. Mise en place alertes télématique automatiques (15 j) [donneur d'ordre]
4. Réunion hebdo dédiée pendant 90 j [partage]

INDICATEURS DE SUIVI HEBDO
- Ponctualité semaine
- Nombre incidents semaine

POINTS DE PASSAGE
- J+30 : revue intermédiaire (50 % progression)
- J+60 : revue intermédiaire (70 % progression)
- J+90 : bilan final + décision

DÉCISIONS POSSIBLES À J+90
- Score > 80 : reprise de collaboration normale
- Score 70-80 : prolongation surveillance 3 mois
- Score < 70 : préavis de désengagement

[Signatures 2 parties]
```

---

## 2. La réunion de recadrage

### 2.1 Préparation

- Tableau factuel chiffré
- Documents à l'appui (scorecard, audit)
- Plan préparé mais ouvert à discussion
- Cadre temporel (60-90 min)

### 2.2 Déroulement

| Étape | Durée |
|---|---|
| 1. Cadrage du contexte | 5 min |
| 2. Présentation des constats | 15 min |
| 3. Échanges (écoute des explications) | 15 min |
| 4. Identification commune des causes | 10 min |
| 5. Construction des actions | 25 min |
| 6. Engagement et conclusion | 10 min |

### 2.3 Posture managériale

| À faire | À éviter |
|---|---|
| Présenter les faits, pas les jugements | « Vous êtes nuls » |
| Écouter activement | Couper la parole |
| Reconnaître les difficultés | Les minimiser |
| Co-construire | Imposer |
| Documenter et conclure formellement | Laisser flou |

---

## 3. La gestion des conflits

### 3.1 Les sources de conflit fréquentes

| Source | Cause typique |
|---|---|
| Tarifaire | Hausse coûts, demande de revalorisation |
| Qualité | Désaccord sur la responsabilité d'un sinistre |
| Volume | Engagement non tenu d'un côté ou de l'autre |
| Délai | Retard de paiement, demande d'avenant |
| Communication | Manque d'écoute, non-respect des engagements |

### 3.2 La méthode de désamorçage (4R)

| Étape | Action |
|---|---|
| **R**econnaître | Le problème existe, je l'entends |
| **R**eformuler | « Si je comprends bien, vous demandez X parce que Y » |
| **R**echercher | Solutions ensemble, pas en opposition |
| **R**ésoudre | Décision claire, datée, communiquée |

### 3.3 Le cas du conflit sur sinistre

Voir BC01-09 pour le cadre juridique. Spécificité sous-traitance :
- Définir clairement la responsabilité (transporteur ou sous-traitant ?)
- Documenter les preuves (CMR, photos, télématique)
- Médiation amiable préférable au procès
- Protéger la relation à long terme si possible

---

## 4. L'escalade

### 4.1 Quand escalader ?

- Conflit non résolu après 2 réunions
- Manquement contractuel grave et persistant
- Risque d'image ou réglementaire
- Incompatibilité durable

### 4.2 Niveaux d'escalade

| Niveau | Action |
|---|---|
| 1 — Direction d'exploitation | Réunion bilatérale 2 h, accord écrit |
| 2 — Direction générale | Comité de pilotage formel |
| 3 — Médiation amiable | CCI, organisations professionnelles |
| 4 — Mise en demeure | Lettre RAR + 30 j pour résolution |
| 5 — Résiliation | Selon clauses contractuelles |
| 6 — Contentieux | Tribunal de commerce |

### 4.3 Documentation systématique

Tout au long du processus :
- Compte rendus de réunions
- Lettres formelles
- Engagements écrits
- Constats d'huissier si nécessaire

Cette documentation protège en cas de contentieux ultérieur.

---

> ✅ **À retenir**
>
> - **Plan d'amélioration co-construit** : diagnostic, causes racines, objectifs SMART, actions, indicateurs.
> - **Réunion de recadrage** : 60-90 min, factuel, écoute, co-construction.
> - **4R désamorçage** : Reconnaître, Reformuler, Rechercher, Résoudre.
> - **Escalade graduée** : 6 niveaux, documentation systématique.
$lesson3$,
'Plan amélioration co-construit, réunion recadrage 60-90 min, 4R désamorçage conflit, escalade graduée 6 niveaux avec documentation.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Désengagement maîtrisé
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Désengagement maîtrisé d''un sous-traitant',
    'gotrm-bc02-02-04-desengagement', 4, 35,
$lesson4$
# Désengagement maîtrisé d'un sous-traitant

Mettre fin à une collaboration est parfois nécessaire. Bien géré, le désengagement préserve les intérêts juridiques, financiers et opérationnels. Mal mené, il génère contentieux, ruptures de service et perte d'image.

> 🎯 **Objectifs de la leçon**
>
> - Identifier les **motifs** légitimes de désengagement.
> - Maîtriser la **procédure** de résiliation.
> - Construire un **plan de transition**.
> - Anticiper les **risques** liés à la rupture.

---

## 1. Les motifs de désengagement

### 1.1 Pour faute grave

- Non-conformité réglementaire répétée
- Travail dissimulé prouvé
- Faute lourde sur un sinistre majeur
- Sous-traitance occulte non déclarée
- Refus de plans d'amélioration validés
- Cessation de paiements

Ces motifs permettent une **résiliation sans préavis** ou avec préavis raccourci.

### 1.2 Pour convenance

- Restructuration interne
- Évolution stratégique (réduction du panel, internalisation)
- Saturation du sous-traitant (plus de capacité)
- Désaccord persistant non grave

Ces motifs imposent le **préavis contractuel** (typiquement 6 mois).

### 1.3 Pour défaillance opérationnelle

- Score scorecard < 70 sur 6 mois consécutifs
- Plan d'amélioration non respecté
- Incidents répétés malgré les recadrages

Ces motifs justifient une résiliation avec **préavis raccourci** (3 mois) selon les clauses contractuelles.

---

## 2. La procédure de résiliation

### 2.1 Étape 1 — Décision interne (J-90 à J-60)

| Action | Détail |
|---|---|
| Bilan factuel chiffré | Synthèse de la dégradation |
| Validation hiérarchique | Direction générale |
| Vérification clauses contractuelles | Préavis, motifs valides |
| Choix de la stratégie | Faute / convenance |
| Préparation des alternatives | Sous-traitants de remplacement |

### 2.2 Étape 2 — Notification (J-60 à J0)

Lettre RAR signée par la direction :
- Référence au contrat
- Motifs précis
- Date d'effet
- Modalités du préavis
- Engagements pendant la période transition
- Conséquences financières (solde de tout compte)

### 2.3 Étape 3 — Période de transition (J0 à J+préavis)

| Action | Détail |
|---|---|
| Maintien du service contractuel | Pas de relâchement |
| Apurement des comptes | Soldes en cours |
| Documentation pour successeur | Procédures, contacts |
| Communication clients | Si nécessaire (gros volumes) |
| Récupération des matériels | Cartes, télématique, badges |

### 2.4 Étape 4 — Clôture (post préavis)

| Action | Détail |
|---|---|
| Bilan financier final | Dernière facturation, soldes |
| Lettre de clôture | Formelle |
| Archivage | 5 ans minimum |
| Bilan interne | Capitaliser sur l'expérience |

---

## 3. Le plan de transition

### 3.1 Construction (en parallèle de la décision)

| Échéance | Action |
|---|---|
| J-60 | Identification du sous-traitant remplaçant |
| J-45 | Signature contrat avec remplaçant |
| J-30 | Démarrage pilote remplaçant |
| J-15 | Montée en puissance progressive |
| J0 | Remplaçant à 100 % |

### 3.2 Risques opérationnels

| Risque | Mesure |
|---|---|
| Rupture de service | Pilote remplaçant en parallèle |
| Perte de connaissance | Documentation systématique |
| Démotivation des conducteurs | Communication claire |
| Évasion d'informations | Confidentialité contractuelle |

### 3.3 Communication

| Cible | Message |
|---|---|
| Sous-traitant sortant | Lettre RAR + RDV de clôture |
| Sous-traitant entrant | Préparation détaillée + briefing |
| Clients finaux | Communication transparente si volumes importants |
| Équipe interne | Information sur le changement et raisons |

---

## 4. Les risques juridiques

### 4.1 Rupture brutale (article L. 442-1 du Code de commerce)

> *« Engage la responsabilité de son auteur et l'oblige à réparer le préjudice causé le fait, dans le cadre de relations commerciales, de rompre brutalement, même partiellement, une relation commerciale établie. »*

Critères :
- Relation établie (durée significative, volumes réguliers)
- Rupture brutale (sans préavis raisonnable)
- Préjudice causé

Préavis raisonnable :
- Moins d'1 an de relation : 1-2 mois
- 1-3 ans : 3-6 mois
- 3-10 ans : 6-12 mois
- > 10 ans : 12-24 mois

### 4.2 Risque de demande de paiement direct

Si le sous-traitant est en difficulté, ses propres sous-traitants ou créanciers peuvent demander un **paiement direct** au donneur d'ordre principal (loi 1975).

### 4.3 Contentieux

Si le sous-traitant conteste la rupture :
- Contestation des motifs (faute / convenance)
- Demande d'indemnités pour rupture brutale
- Action en concurrence déloyale (si récupération de clients)

Documentation et formalisme protègent ces risques.

---

## 5. Cas pratique : désengagement progressif

**Contexte** : Vous décidez de mettre fin à 3 ans de collaboration avec *Trans-Express Bourgogne* (volumes 280 k€/an). Score scorecard 65/100 sur 6 mois, plan d'amélioration non respecté.

### Plan sur 12 mois

#### M-3 — Préparation interne

- Bilan factuel : score, KPI, incidents
- Validation direction
- Recherche de remplaçant (AO restreint sur 3 candidats)

#### M-2 — Sélection remplaçant

- Évaluation des 3 candidats
- Visite terrain finalistes
- Choix et négociation contrat

#### M-1 — Notification

Lettre RAR au sous-traitant sortant :
> *« Madame X, après nos échanges des derniers mois et le bilan d''octobre faisant état d''un score de 65/100 et d''une non-réalisation du plan d''amélioration validé en juin, nous vous informons de notre décision de mettre fin à notre collaboration. Conformément à notre contrat (article 12.2), nous activons un préavis de 6 mois à compter de réception de la présente. La fin de la collaboration interviendra le [date]. »*

#### M0 — Démarrage pilote remplaçant

- Le remplaçant prend 30 % du volume en pilote
- Le sortant maintient le service contractuel sur les 70 % restants

#### M+2 — Bascule progressive 50/50

#### M+4 — Bascule 80/20

#### M+6 — Fin du préavis

- Le remplaçant à 100 %
- Solde de tout compte avec le sortant
- Clôture formelle

### Bilan

| Élément | Détail |
|---|---|
| Coût transition | 25-40 k€ (sur-coût pendant la phase parallèle) |
| Risque évité | Rupture de service, perte clients |
| Bénéfice attendu | Score panel +5 points, marge +1 % |
| ROI | Sur 24 mois |

---

> ✅ **À retenir**
>
> - **Motifs** : faute grave (sans préavis), convenance (préavis 6 mois), défaillance (préavis raccourci).
> - **Procédure** : décision interne, notification RAR, transition, clôture.
> - **Plan de transition** : pilote du remplaçant en parallèle, bascule progressive.
> - **Risques juridiques** : rupture brutale (L. 442-1), paiement direct (loi 1975).
> - **Documentation** systématique pour éviter contentieux.
$lesson4$,
'Motifs (faute, convenance, défaillance), procédure résiliation 4 étapes, plan de transition avec pilote parallèle, risques juridiques L. 442-1, documentation 5 ans.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- 25 QCM
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qcm', 'Le scorecard mensuel d''un sous-traitant est noté typiquement sur :', '[{"id":"a","label":"10 points","is_correct":false},{"id":"b","label":"100 points","is_correct":true},{"id":"c","label":"5 étoiles","is_correct":false},{"id":"d","label":"Aucune notation","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['scorecard','notation'], 'mft-2026-gotrm:bc02-02:qcm:1', true, 'Le scorecard est noté sur 100 points, ventilé typiquement : opérationnel 50 pts, conformité 25 pts, qualité 15 pts, RSE 10 pts. Permet une lecture immédiate (> 90 excellence, < 60 plan urgent).'),
  (v_formation, 'qcm', 'Un audit administratif d''un sous-traitant est obligatoire :', '[{"id":"a","label":"Une fois en début de contrat uniquement","is_correct":false},{"id":"b","label":"Tous les 6 mois (L. 8222-1)","is_correct":true},{"id":"c","label":"Tous les 5 ans","is_correct":false},{"id":"d","label":"Aucune obligation","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['audit','semestriel'], 'mft-2026-gotrm:bc02-02:qcm:2', true, 'L. 8222-1 du Code du travail : vérifications avant la conclusion + tous les 6 mois pendant la durée du contrat. À défaut : risque de complicité travail dissimulé (75 k€ + solidarité).'),
  (v_formation, 'qcm', 'Une grille d''audit complète d''un sous-traitant transport contient typiquement :', '[{"id":"a","label":"5 sections (administratif, véhicules, conducteurs, procédures, spécifique)","is_correct":true},{"id":"b","label":"1 seule section (administratif)","is_correct":false},{"id":"c","label":"50 sections détaillées","is_correct":false},{"id":"d","label":"Aucune structure","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['audit','sections'], 'mft-2026-gotrm:bc02-02:qcm:3', true, '5 sections clés : administratif (20 pts), véhicules (25 pts), conducteurs (25 pts), procédures et qualité (15 pts), conformité spécifique ADR/ATP/RGPD (15 pts). Total 100 pts.'),
  (v_formation, 'qcm', 'Une non-conformité majeure dans un audit doit être régularisée sous :', '[{"id":"a","label":"24 heures","is_correct":false},{"id":"b","label":"30 jours","is_correct":true},{"id":"c","label":"6 mois","is_correct":false},{"id":"d","label":"Aucun délai","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['non-conformite','delai'], 'mft-2026-gotrm:bc02-02:qcm:4', true, 'Non-conformité majeure (risque légal, financier, sécuritaire) : régularisation < 30 jours. Mineure : < 90 jours. Observation : plan moyen terme. Bonne pratique : à capitaliser.'),
  (v_formation, 'qcm', 'Un audit terrain d''un sous-traitant dure typiquement :', '[{"id":"a","label":"15 min","is_correct":false},{"id":"b","label":"Demi-journée (4 h)","is_correct":true},{"id":"c","label":"Une semaine entière","is_correct":false},{"id":"d","label":"Aucune durée standard","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['audit','duree'], 'mft-2026-gotrm:bc02-02:qcm:5', true, 'Audit terrain : demi-journée minimum (réunion ouverture, revue documents, visite locaux et parc, échanges opérationnels et conducteurs, clôture). Pour les sous-traitants stratégiques, parfois une journée complète.'),
  (v_formation, 'qcm', 'Le plan d''amélioration d''un sous-traitant doit être :', '[{"id":"a","label":"Imposé unilatéralement","is_correct":false},{"id":"b","label":"Co-construit avec le sous-traitant pour engagement réel","is_correct":true},{"id":"c","label":"Confidentiel, non communiqué au sous-traitant","is_correct":false},{"id":"d","label":"Verbal sans engagement","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['plan-amelioration'], 'mft-2026-gotrm:bc02-02:qcm:6', true, 'Co-construction = engagement réel. L''erreur classique est d''imposer unilatéralement, ce qui génère résistance passive. La co-construction (diagnostic partagé, causes racines, objectifs SMART, actions) garantit l''adhésion.'),
  (v_formation, 'qcm', 'La méthode 4R pour désamorcer un conflit signifie :', '[{"id":"a","label":"Refuser, Renvoyer, Reporter, Réclamer","is_correct":false},{"id":"b","label":"Reconnaître, Reformuler, Rechercher, Résoudre","is_correct":true},{"id":"c","label":"Récupérer, Rectifier, Réparer, Restituer","is_correct":false},{"id":"d","label":"Aucun acronyme officiel","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['4r','desamorcage'], 'mft-2026-gotrm:bc02-02:qcm:7', true, '4R : Reconnaître (le problème existe), Reformuler (« si je comprends bien... »), Rechercher (solutions ensemble), Résoudre (décision claire, datée). Universellement applicable en gestion de conflits.'),
  (v_formation, 'qcm', 'L''article L. 442-1 du Code de commerce sanctionne :', '[{"id":"a","label":"Le travail dissimulé","is_correct":false},{"id":"b","label":"La rupture brutale d''une relation commerciale établie","is_correct":true},{"id":"c","label":"Les retards de paiement","is_correct":false},{"id":"d","label":"Les incoterms incorrects","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['rupture-brutale','L442-1'], 'mft-2026-gotrm:bc02-02:qcm:8', true, 'L. 442-1 : la rupture brutale d''une relation commerciale établie engage la responsabilité de son auteur. Préavis raisonnable obligatoire selon ancienneté (1-2 mois si < 1 an, 12-24 mois si > 10 ans).'),
  (v_formation, 'qcm', 'Pour une relation commerciale de 3-10 ans, le préavis raisonnable typique est :', '[{"id":"a","label":"1 mois","is_correct":false},{"id":"b","label":"6-12 mois","is_correct":true},{"id":"c","label":"24 mois","is_correct":false},{"id":"d","label":"Aucun préavis","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['preavis','raisonnable'], 'mft-2026-gotrm:bc02-02:qcm:9', true, 'Échelle indicative préavis raisonnable : < 1 an = 1-2 mois, 1-3 ans = 3-6 mois, 3-10 ans = 6-12 mois, > 10 ans = 12-24 mois. À adapter selon volume, dépendance, contexte.'),
  (v_formation, 'qcm', 'Un score scorecard < 60 sur 100 indique typiquement :', '[{"id":"a","label":"Une excellente performance","is_correct":false},{"id":"b","label":"Une situation nécessitant un plan d''action urgent","is_correct":true},{"id":"c","label":"Un fonctionnement normal","is_correct":false},{"id":"d","label":"Une innovation","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['score','seuils'], 'mft-2026-gotrm:bc02-02:qcm:10', true, 'Échelle : > 90 excellence, 75-90 performant, 60-75 à surveiller, < 60 plan d''action urgent (avec risque de désengagement). Décliner les indicateurs en plan détaillé.'),
  (v_formation, 'qcm', 'La conservation légale des rapports d''audit sous-traitant est de :', '[{"id":"a","label":"6 mois","is_correct":false},{"id":"b","label":"5 ans minimum","is_correct":true},{"id":"c","label":"30 ans","is_correct":false},{"id":"d","label":"À vie","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['archivage','5-ans'], 'mft-2026-gotrm:bc02-02:qcm:11', true, '5 ans minimum (correspond à la prescription en matière commerciale). Recommandé : conservation pendant toute la durée du contrat + 5 ans après la fin. Format papier ou numérique.'),
  (v_formation, 'qcm', 'Le benchmarking entre sous-traitants permet :', '[{"id":"a","label":"De diviser pour mieux régner","is_correct":false},{"id":"b","label":"De stimuler la performance par comparaison et identification des meilleures pratiques","is_correct":true},{"id":"c","label":"De mettre les sous-traitants en concurrence agressive","is_correct":false},{"id":"d","label":"D''ignorer les performances individuelles","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['benchmarking'], 'mft-2026-gotrm:bc02-02:qcm:12', true, 'Le benchmarking (anonymisé si nécessaire) stimule la performance par émulation, identifie les meilleures pratiques transférables, et permet d''appuyer les plans d''amélioration sur des références.'),
  (v_formation, 'qcm', 'Lors d''un désengagement, la 1ère étape de la procédure est :', '[{"id":"a","label":"Notification immédiate au sous-traitant","is_correct":false},{"id":"b","label":"Décision interne avec bilan factuel et validation hiérarchique","is_correct":true},{"id":"c","label":"Lettre aux clients finaux","is_correct":false},{"id":"d","label":"Saisine du tribunal","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['desengagement','procedure'], 'mft-2026-gotrm:bc02-02:qcm:13', true, 'Étape 1 = décision interne (J-90 à J-60) : bilan factuel chiffré, validation direction, vérification clauses contractuelles, choix stratégie (faute / convenance), préparation alternatives.'),
  (v_formation, 'qcm', 'Le pilote du sous-traitant remplaçant doit démarrer :', '[{"id":"a","label":"Après la fin du préavis du sortant","is_correct":false},{"id":"b","label":"En parallèle de la fin du préavis (généralement à J-30)","is_correct":true},{"id":"c","label":"6 mois après la fin du préavis","is_correct":false},{"id":"d","label":"Aucun pilote nécessaire","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['transition','parallele'], 'mft-2026-gotrm:bc02-02:qcm:14', true, 'Le pilote du remplaçant démarre EN PARALLÈLE pour éviter les ruptures de service. Bascule progressive : 30 % à J-30, 50 % à J-15, 80 % à J-5, 100 % à la fin du préavis du sortant.'),
  (v_formation, 'qcm', 'En cas de défaillance financière du sous-traitant en cours de mission, ses propres créanciers peuvent demander :', '[{"id":"a","label":"Aucun recours","is_correct":false},{"id":"b","label":"Le paiement direct au donneur d''ordre principal (loi 1975)","is_correct":true},{"id":"c","label":"Une médiation judiciaire systématique","is_correct":false},{"id":"d","label":"L''annulation des contrats","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['paiement-direct','defaillance'], 'mft-2026-gotrm:bc02-02:qcm:15', true, 'Loi 1975 : en cas de défaillance du sous-traitant, ses sous-traitants ou créanciers peuvent demander le paiement direct au donneur d''ordre principal. Risque pour le donneur d''ordre : payer 2 fois.'),
  (v_formation, 'qcm', 'Une attestation URSSAF de vigilance valide doit avoir au maximum :', '[{"id":"a","label":"3 mois","is_correct":false},{"id":"b","label":"6 mois","is_correct":true},{"id":"c","label":"1 an","is_correct":false},{"id":"d","label":"5 ans","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['urssaf','validite'], 'mft-2026-gotrm:bc02-02:qcm:16', true, 'Attestation URSSAF de vigilance < 6 mois pour être opposable. Au-delà : à renouveler. À demander tous les semestres dans le cadre des vérifications L. 8222-1.'),
  (v_formation, 'qcm', 'Lors d''une réunion de recadrage, la 1ère étape est :', '[{"id":"a","label":"Annoncer immédiatement la sanction","is_correct":false},{"id":"b","label":"Présenter les constats factuels chiffrés","is_correct":true},{"id":"c","label":"Crier","is_correct":false},{"id":"d","label":"Refuser le dialogue","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['recadrage','methode'], 'mft-2026-gotrm:bc02-02:qcm:17', true, 'Présenter les FAITS chiffrés (scorecard, KPI, incidents) avant tout jugement. Permet d''éviter le débat émotionnel et de partir sur une base objective. Posture : factuel, professionnel, ouvert.'),
  (v_formation, 'qcm', 'Le critère qui DÉCLENCHE généralement un plan d''amélioration sous-traitant est :', '[{"id":"a","label":"Score scorecard < 75/100 sur 2 mois consécutifs","is_correct":true},{"id":"b","label":"Une seule mauvaise mission","is_correct":false},{"id":"c","label":"Un changement de directeur","is_correct":false},{"id":"d","label":"L''anniversaire du contrat","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['declencheur','plan-amelioration'], 'mft-2026-gotrm:bc02-02:qcm:18', true, 'Déclencheurs typiques d''un plan d''amélioration : score < 75 sur 2 mois consécutifs, non-conformité majeure post-audit, plainte client significative, dégradation d''un KPI critique.'),
  (v_formation, 'qcm', 'Lors d''une rupture pour faute grave, le préavis :', '[{"id":"a","label":"Reste de 6 mois minimum","is_correct":false},{"id":"b","label":"Peut être supprimé ou très raccourci selon les clauses contractuelles","is_correct":true},{"id":"c","label":"Doit être doublé","is_correct":false},{"id":"d","label":"N''est pas applicable","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['rupture','faute-grave'], 'mft-2026-gotrm:bc02-02:qcm:19', true, 'Faute grave (travail dissimulé, sous-traitance occulte, faute lourde sinistre majeur) : préavis supprimé ou très raccourci selon les clauses contractuelles. Pour la faute "ordinaire" et la convenance : préavis contractuel standard.'),
  (v_formation, 'qcm', 'Le format type d''un rapport d''audit sous-traitant fait :', '[{"id":"a","label":"1 page","is_correct":false},{"id":"b","label":"10-15 pages","is_correct":true},{"id":"c","label":"100 pages minimum","is_correct":false},{"id":"d","label":"Aucune limite","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['rapport-audit','format'], 'mft-2026-gotrm:bc02-02:qcm:20', true, 'Rapport d''audit type 10-15 pages : synthèse exécutive (1), périmètre et méthode (1), constats par section (5-8), score et benchmark (1), recommandations (2-3), annexes (photos, documents). Lisible et utilisable.'),
  (v_formation, 'qcm', 'L''escalade en cas de conflit non résolu se fait typiquement par niveaux :', '[{"id":"a","label":"3 niveaux maximum","is_correct":false},{"id":"b","label":"6 niveaux : direction expl., direction G, médiation, mise en demeure, résiliation, contentieux","is_correct":true},{"id":"c","label":"50 niveaux","is_correct":false},{"id":"d","label":"Aucun niveau structuré","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['escalade','niveaux'], 'mft-2026-gotrm:bc02-02:qcm:21', true, '6 niveaux d''escalade : 1) direction d''exploitation, 2) direction générale, 3) médiation amiable (CCI), 4) mise en demeure RAR, 5) résiliation contractuelle, 6) contentieux judiciaire. Documentation à chaque niveau.'),
  (v_formation, 'qcm', 'Un audit thématique annuel ADR vérifie notamment :', '[{"id":"a","label":"Le coût du carburant","is_correct":false},{"id":"b","label":"Les attestations conducteurs ADR, équipement véhicules, certificats d''agrément","is_correct":true},{"id":"c","label":"Les places de parking","is_correct":false},{"id":"d","label":"Les habitudes alimentaires","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['audit-adr'], 'mft-2026-gotrm:bc02-02:qcm:22', true, 'Audit ADR : attestations conducteurs (Base, Citerne, classe 1, classe 7), équipement véhicules obligatoire, certificats d''agrément véhicules (EX/II ou EX/III), consignes écrites à bord, plan d''urgence.'),
  (v_formation, 'qcm', 'La validité d''une attestation conducteur ADR est de :', '[{"id":"a","label":"1 an","is_correct":false},{"id":"b","label":"5 ans","is_correct":true},{"id":"c","label":"10 ans","is_correct":false},{"id":"d","label":"À vie","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['adr','attestation'], 'mft-2026-gotrm:bc02-02:qcm:23', true, '5 ans avec recyclage obligatoire avant expiration (13 h pour la base, 8 h citerne, 8 h classe 1 ou 7). Audit annuel des sous-traitants ADR pour vérifier la validité de toutes les attestations.'),
  (v_formation, 'qcm', 'Lors d''un désengagement pour convenance, la communication aux clients finaux :', '[{"id":"a","label":"N''est jamais nécessaire","is_correct":false},{"id":"b","label":"Est nécessaire si volumes importants ou impact direct sur le service","is_correct":true},{"id":"c","label":"Doit être anonyme","is_correct":false},{"id":"d","label":"Doit dénigrer le sortant","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['communication','desengagement'], 'mft-2026-gotrm:bc02-02:qcm:24', true, 'Communication client final = nécessaire si volumes significatifs, impact direct sur le service, ou si le client connaît le sous-traitant. Posture : transparente, factuelle, sans dénigrer (risque diffamation).'),
  (v_formation, 'qcm', 'Le coût typique d''une transition de sous-traitant (sur-coût pendant la phase parallèle) est de :', '[{"id":"a","label":"5-10 % du CA annuel concerné","is_correct":true},{"id":"b","label":"50 %","is_correct":false},{"id":"c","label":"Aucun sur-coût","is_correct":false},{"id":"d","label":"100 %","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['transition','cout'], 'mft-2026-gotrm:bc02-02:qcm:25', true, 'Sur-coût transition : 5-10 % du CA annuel concerné (3-6 mois de fonctionnement parallèle). À comparer aux risques évités : rupture de service, perte clients, contentieux. ROI typiquement positif sur 12-24 mois.');


  -- =================================================================
  -- 4 QR
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qr', 'Un sous-traitant a un score scorecard de 62/100 sur 3 mois consécutifs. Détaillez la procédure de redressement en 5 étapes (sur 6 mois), avec actions, indicateurs de suivi et arborescence des décisions à la fin.', NULL, 1, 'difficile', ARRAY['plan-amelioration','procedure','decision'], 'mft-2026-gotrm:bc02-02:qr:1', true, 'PROCÉDURE DE REDRESSEMENT — 6 MOIS

PHASE 1 — Diagnostic et alerte (M0)

a. Préparation du dossier
- Synthèse 12 mois des KPI
- Liste des incidents et leur classification
- Comparaison vs cibles contractuelles
- Identification des 3 KPI les plus dégradés

b. Réunion d''alerte avec le sous-traitant (sous 7 jours)
- Présentation factuelle des constats
- Écoute des explications
- Demande d''un plan d''action sous 21 jours

PHASE 2 — Plan d''action co-construit (M+0,5 à M+1)

a. Atelier conjoint (1 journée)
- Diagnostic 5 pourquoi
- Identification des causes racines
- Définition de 5-7 actions concrètes
- Cibles SMART à 6 mois

b. Engagement formel
- Plan signé par les deux parties
- Indicateurs de suivi mensuel
- Points de passage J+30, J+60, J+90, J+120, J+150

PHASE 3 — Surveillance intensive (M+1 à M+3)

a. Reporting hebdomadaire détaillé du sous-traitant
b. Réunion bi-mensuelle (au lieu de mensuelle standard)
c. Visite terrain à M+1,5
d. Si écart significatif : escalade direction immédiate

Indicateurs de suivi hebdomadaire :
- KPI principaux (ponctualité, intégrité, conformité doc)
- Avancement des 5-7 actions du plan
- Nouveaux incidents et leur traitement

PHASE 4 — Bilan intermédiaire (M+3)

Mesure des progrès :
- Score scorecard à M+3 vs M0
- % d''actions réalisées
- Évolution des KPI clés

Décision :
- Si score > 75/100 : on continue le plan, allègement de la surveillance
- Si score 65-75 : on intensifie, ajout de moyens
- Si score < 65 : alerte rouge, escalade direction générale

PHASE 5 — Bilan final (M+6)

Mesure complète :
- Score scorecard final
- Bilan qualitatif (climat, communication, fiabilité)
- Visite terrain finale
- Feedback clients finaux

ARBORESCENCE DES DÉCISIONS À M+6

DÉCISION A — REPRISE DE COLLABORATION NORMALE
- Conditions : score > 80/100, tous KPI cibles atteints
- Action : retour au pilotage standard, communication positive
- Capitalisation : intégrer les améliorations dans les standards

DÉCISION B — POURSUITE DU PLAN AVEC AJUSTEMENTS
- Conditions : score 70-80, progression nette mais pas finalisée
- Action : prolongation du plan 3 mois, focus sur les 1-2 axes restants
- Communication transparente sur les progrès

DÉCISION C — DÉSENGAGEMENT PROGRESSIF
- Conditions : score < 70, peu de progression, manque d''engagement réel
- Action : déclenchement procédure de désengagement (voir leçon 4)
- Préavis contractuel respecté
- Plan de transition activé

DÉCISION D — RUPTURE BRUTALE (faute grave découverte pendant le plan)
- Conditions : travail dissimulé, fraude, sinistre majeur découvert
- Action : mise en demeure RAR, résiliation pour faute grave
- Documentation pour défense juridique

CONDITIONS DE SUCCÈS

Pour qu''un plan d''amélioration fonctionne :

1. Engagement direction des 2 parties
- Le DG du sous-traitant doit s''engager personnellement
- Soutien actif du donneur d''ordre

2. Co-construction réelle
- Pas d''imposition unilatérale
- Causes racines identifiées ensemble
- Adhésion au diagnostic

3. Indicateurs précis et mesurables
- Pas de cibles vagues
- Mesures hebdomadaires
- Communication transparente

4. Soutien tangible du donneur d''ordre
- Mise à disposition de ressources si nécessaire (formation, outils)
- Reconnaissance des progrès intermédiaires
- Communication interne positive

5. Documentation systématique
- Compte rendus de toutes les réunions
- Tableau de suivi mis à jour
- Engagements écrits

ROI DU PLAN D''AMÉLIORATION

Coûts estimés :
- Temps interne (manager dédié 25 % de son temps) : ~ 18 000 €
- Outils de suivi : 2 000 €
- Visites terrain : 3 000 €
- Total : ~ 23 000 €

Bénéfices estimés (si réussite) :
- Maintien du sous-traitant existant (vs coût transition 50-100 k€)
- Amélioration des KPI sur le panel : +2-3 points score moyen
- Préservation de la relation client (NPS, litiges)
- Total : 75-150 k€ évités/gagnés

ROI : x 3-6 si succès. À l''inverse, si le plan échoue, il aura permis d''anticiper le désengagement et de préparer la transition dans de bonnes conditions.

LEÇONS À CAPITALISER

À chaque plan d''amélioration mené, capitaliser :
- Les causes racines fréquentes
- Les actions qui fonctionnent
- Les pièges à éviter
- Les bons indicateurs de progression

Ces apprentissages enrichissent le référentiel interne et améliorent la sélection future des sous-traitants.'),
  (v_formation, 'qr', 'Construisez la grille d''audit complète d''un sous-traitant transport ATP (température dirigée). 50 critères répartis sur les 5 sections, avec barème de notation et seuils éliminatoires.', NULL, 1, 'difficile', ARRAY['audit','grille','atp'], 'mft-2026-gotrm:bc02-02:qr:2', true, 'GRILLE D''AUDIT — SOUS-TRAITANT ATP (TEMPÉRATURE DIRIGÉE)

50 critères, 100 points

SECTION 1 — DOCUMENTS ADMINISTRATIFS (20 points, 10 critères)

| # | Critère | Pts |
|---|---|---|
| 1 | KBIS < 3 mois, dirigeants identifiés | 2 |
| 2 | Attestation URSSAF de vigilance < 6 mois | 2 |
| 3 | Attestation fiscale à jour | 2 |
| 4 | DPAE conducteurs concernés | 3 |
| 5 | Bulletins n°2 dirigeants (honorabilité) | 2 |
| 6 | Licence transport en cours (LTI/LTM) | 2 |
| 7 | Attestation RC professionnelle | 2 |
| 8 | Attestation RC marchandises étendue | 2 |
| 9 | Inscription registre des transporteurs | 2 |
| 10 | Convention collective TRM appliquée | 1 |

SECTION 2 — VÉHICULES ATP (25 points, 10 critères)

| # | Critère | Pts |
|---|---|---|
| 11 | Cartes grises à jour pour tous véhicules dédiés | 3 |
| 12 | Contrôles techniques valides | 3 |
| 13 | Plaque ATP sur chaque véhicule (visible, lisible) | 4 |
| 14 | Validité plaque (initial 6 ans, renouvellement 3 ans) | 4 |
| 15 | Type de véhicule conforme cahier des charges (FRC, FRA, etc.) | 3 |
| 16 | Groupe frigorifique entretenu (carnet de visites) | 2 |
| 17 | Sondes calibrées < 12 mois | 2 |
| 18 | Enregistreur de température fonctionnel et certifié | 2 |
| 19 | Système d''alarme dépassement de seuil | 1 |
| 20 | Carnet d''entretien à jour | 1 |

SECTION 3 — CONDUCTEURS (25 points, 10 critères)

| # | Critère | Pts |
|---|---|---|
| 21 | Tous conducteurs avec permis CE valide | 3 |
| 22 | CQC FCO < 5 ans pour 100 % | 4 |
| 23 | Carte conducteur tachygraphique valide | 2 |
| 24 | Visite médicale du travail à jour | 2 |
| 25 | Formation HACCP (chaîne du froid) | 3 |
| 26 | Formation interne procédure ATP | 3 |
| 27 | Formation éco-conduite | 2 |
| 28 | Ancienneté moyenne > 3 ans | 2 |
| 29 | Plan de formation continue documenté | 2 |
| 30 | Procédure d''accueil et briefing | 2 |

SECTION 4 — PROCÉDURES ATP (15 points, 10 critères)

| # | Critère | Pts |
|---|---|---|
| 31 | Procédure de pré-refroidissement avant chargement | 1,5 |
| 32 | Procédure de contrôle température au chargement | 1,5 |
| 33 | Procédure de surveillance pendant transport | 1,5 |
| 34 | Procédure de gestion rupture chaîne du froid | 2 |
| 35 | Procédure de communication client en cas d''alerte | 1,5 |
| 36 | Procédure de livraison avec contrôle température | 1,5 |
| 37 | Conservation enregistrements 12 mois minimum | 2 |
| 38 | Procédure documentée et accessible | 1 |
| 39 | Tableau de bord interne ATP | 1 |
| 40 | Audit interne annuel ATP | 1,5 |

SECTION 5 — CONFORMITÉ SPÉCIFIQUE (15 points, 10 critères)

| # | Critère | Pts |
|---|---|---|
| 41 | Certification GDP (Bonnes Pratiques Distribution) si médicaments | 2 |
| 42 | Certification HACCP (alimentaire) | 2 |
| 43 | Conformité RGPD (télématique, données conducteurs) | 1,5 |
| 44 | Politique sécurité documentée | 1,5 |
| 45 | Plan de continuité (panne véhicule, panne groupe) | 1,5 |
| 46 | Politique RSE (carbone, social) | 1 |
| 47 | ISO 9001 ou démarche équivalente | 2 |
| 48 | Statistiques accidents AT (TF, TG) | 1 |
| 49 | Bilan formation annuel | 1 |
| 50 | Engagement environnement (véhicules récents, éco-conduite) | 1,5 |

TOTAL : 100 POINTS

ÉCHELLE DE NOTATION

| Score | Statut | Action |
|---|---|---|
| > 90 | Conforme exemplaire | Maintien + valorisation |
| 80-90 | Conforme | Suivi standard |
| 70-80 | À surveiller | Plan d''amélioration sur 90 j |
| 60-70 | Non-conforme partielle | Plan d''action urgent + audit suivi 60 j |
| < 60 | Non-conforme grave | Mise en demeure 30 j ou désengagement |

SEUILS ÉLIMINATOIRES (rejet automatique sans calcul)

- KBIS > 3 mois ou pièces obligatoires manquantes
- Licence transport non valide
- Attestation URSSAF expirée
- Plaque ATP expirée sans renouvellement engagé
- Sondes non calibrées depuis > 18 mois
- Conducteurs sans CQC FCO valide pour activité dédiée
- Antécédents de fraude ou condamnations bloquantes

POINTS D''ATTENTION SPÉCIFIQUES ATP

a. Calibration sondes
- Vérification de la traçabilité (qui, quand, comment)
- Étalonnage par laboratoire agréé recommandé

b. Plaque ATP
- Date d''émission et date d''expiration
- Validité 6 ans initialement, renouvellement 3 ans
- Centre agréé (Cemafroid en France)

c. Procédure rupture chaîne du froid
- Document détaillé attendu
- Test annuel de la procédure
- Communication client < 2 h après détection

d. Enregistrements de température
- Conservation 12 mois minimum
- Format exploitable (PDF + données brutes)
- Accessibles à la demande sous 4 h

DÉROULEMENT TYPE DE L''AUDIT (1/2 journée)

8h30 — Réunion d''ouverture (30 min)
- Présentation des participants
- Rappel du périmètre et de la méthode
- Confirmation des accès aux documents

9h00 — Revue documentaire (90 min)
- Sections 1, 3 et 4 sur dossiers
- Vérification croisée

10h30 — Pause (15 min)

10h45 — Visite terrain (90 min)
- Inspection des locaux
- Visite du parc
- Section 2 (véhicules ATP)
- Section 5 (conformité spécifique)

12h15 — Échanges opérationnels (45 min)
- Avec le responsable d''exploitation
- Avec 2-3 conducteurs concernés
- Vérification de l''application réelle des procédures

13h00 — Déjeuner (60 min)

14h00 — Synthèse et clôture (60 min)
- Constats préliminaires
- Discussion ouverte avec le sous-traitant
- Premières orientations
- Date du rapport final (J+15)

15h00 — Fin de l''audit

LIVRABLES POST-AUDIT

J+15 : Rapport complet (10-15 pages) :
1. Synthèse exécutive
2. Périmètre et méthode
3. Constats par section
4. Score global avec ventilation
5. Recommandations classées (NC majeure, NC mineure, observation)
6. Plan d''action proposé
7. Annexes (photos, documents)

J+30 : Plan d''action signé par le sous-traitant

J+90 : Audit de suivi pour vérification de la mise en œuvre des actions critiques.

Cette grille structure une évaluation complète et reproductible. Elle peut être adaptée au contexte (ADR, transports exceptionnels, distribution urbaine) en modifiant la section 5 spécifique.'),
  (v_formation, 'qr', 'Vous décidez de mettre fin à 5 ans de collaboration avec *Express Sud SARL* (volumes 450 k€/an). Décrivez la procédure de désengagement complète sur 12 mois, en anticipant les risques juridiques et opérationnels.', NULL, 1, 'difficile', ARRAY['desengagement','procedure','risques'], 'mft-2026-gotrm:bc02-02:qr:3', true, 'PROCÉDURE DE DÉSENGAGEMENT — 12 MOIS

CONTEXTE INITIAL

- Sous-traitant : Express Sud SARL
- Durée de la collaboration : 5 ans
- Volumes : 450 k€/an (≈ 12 % du CA sous-traité)
- Préavis contractuel : 6 mois
- Préavis raisonnable selon L. 442-1 (5 ans de relation) : 6-12 mois

DÉCISION : préavis 9 mois (sécurisation juridique)

PHASE 1 — PRÉPARATION INTERNE (M-3 à M0)

M-3 — Décision et validation interne

a. Bilan factuel
- Synthèse 24 derniers mois des KPI
- Coûts cachés et incidents
- Comparaison avec autres sous-traitants
- Évaluation des coûts de transition

b. Validation hiérarchique
- Comité direction d''exploitation
- Validation DG
- Vérification des clauses contractuelles
- Vérification de l''absence de procédure judiciaire

c. Choix de la stratégie
- Désengagement pour convenance (volumes, restructuration)
- Préavis 9 mois (au-delà du contractuel pour sécuriser)
- Communication progressive

M-2 — Préparation du remplacement

a. AO restreint
- 4 candidats consultés (2 existants + 2 nouveaux)
- Cahier des charges adapté
- Délai 6 semaines

b. Sélection
- Critères multi-axes (prix, qualité, capacité, RSE)
- Visite terrain des 3 finalistes
- Choix du remplaçant

M-1 — Contractualisation remplaçant

a. Négociation conditions
b. Signature contrat 12 mois renouvelable
c. Préparation logistique (intégration télématique, formation équipes)

PHASE 2 — NOTIFICATION (J0)

J0 — Lettre RAR au sous-traitant sortant

```
[En-tête entreprise]
[Date]

OBJET : Dénonciation du contrat n° [ref] - Préavis de 9 mois
Lettre recommandée avec accusé de réception

Madame X, Monsieur Y,

Par la présente, nous vous informons de notre décision de mettre fin
à notre contrat n° [ref] daté du [date] et reconduit tacitement
depuis [date].

Conformément aux dispositions de l''article 12 de notre contrat,
nous activons un préavis de 9 mois, ce qui porte la fin effective
de notre collaboration au [date J+270].

Pendant cette période :
- Nous nous engageons à maintenir le volume de missions selon
les modalités habituelles
- Vous vous engagez à exécuter les missions confiées avec la
qualité contractuelle (SLA en vigueur)
- Nous procéderons à un apurement progressif et transparent

Cette décision est prise pour des motifs de réorganisation interne
et n''est en aucun cas liée à des manquements de votre part.
Nous restons reconnaissants du travail accompli durant ces 5 années
de collaboration.

Nous vous proposons un rendez-vous le [date], à votre convenance,
pour formaliser les modalités pratiques de cette transition.

Cordialement,
[Direction Générale]
[Signature]
```

PHASE 3 — TRANSITION OPÉRATIONNELLE (M0 à M+9)

M0 à M+3 — Démarrage parallèle

- Le sous-traitant sortant maintient 100 % du volume
- Le remplaçant démarre avec 30 % du volume (tournées dédiées)
- Reporting hebdomadaire intensif (2 sous-traitants en parallèle)
- Visite terrain remplaçant à M+1
- Bilan intermédiaire à M+2

M+3 à M+6 — Bascule progressive

- Sortant : 70 % → 50 % → 30 %
- Remplaçant : 30 % → 50 % → 70 %
- Communication client final (top 5 clients concernés)
- Documentation systématique des transferts

M+6 à M+9 — Finalisation

- Sortant : 30 % → 10 % → 0 %
- Remplaçant : 70 % → 90 % → 100 %
- Apurement des comptes (paiements en cours)
- Récupération des matériels (cartes, badges, télématique)

PHASE 4 — CLÔTURE (M+9 à M+12)

M+9 — Bilan financier

- Solde de tout compte
- Vérification des paiements en cours
- Confirmation de l''absence de litiges en cours

M+10 — Lettre de clôture

- Confirmation officielle de la fin
- Solde de tout compte signé par les 2 parties
- Quittance pour paiements

M+11 — Documentation et archivage

- Archivage de l''ensemble des dossiers (5 ans minimum)
- Compte rendu interne de la procédure
- Capitalisation des apprentissages

M+12 — Bilan retour d''expérience

- Bilan financier global de la transition
- Performance du remplaçant (3 mois de recul)
- Lessons learned pour les prochains désengagements

ANTICIPATION DES RISQUES

RISQUE 1 — Demande de paiement direct

Si le sortant rencontre des difficultés financières pendant la transition :
- Vérifier mensuellement la situation (Infogreffe)
- Limiter les encours
- Sécuriser les paiements (avant le préavis si possible)

RISQUE 2 — Action en rupture brutale

Si le sortant conteste le préavis (estime qu''il est insuffisant) :
- Documentation systématique de la décision
- Référence aux clauses contractuelles
- Préavis confortable (9 mois > contractuel 6 mois)
- Facturation maintenue pendant le préavis

RISQUE 3 — Concurrence déloyale

Si le sortant tente de récupérer des clients :
- Clause de non-concurrence dans le contrat (si présente)
- Communication client transparente mais courtoise
- Préservation des relations clients via le remplaçant

RISQUE 4 — Rupture de service

Si la bascule se passe mal :
- Plan de continuité (sous-traitants tactiques en réserve)
- Buffer de capacité interne (parc propre si disponible)
- Communication anticipée aux clients

RISQUE 5 — Communication agressive

Si le sortant communique négativement :
- Pas de réponse publique
- Lettre formelle uniquement si diffamation
- Témoignages clients positifs préparés

RISQUE 6 — Demande d''indemnité

Si le sortant demande une indemnité de rupture :
- Document tous les manquements antérieurs (le cas échéant)
- Vérifier l''absence de clause d''indemnisation
- Proposer un geste commercial limité (1-2 mois de CA) si nécessaire

COÛT TOTAL DE LA TRANSITION

| Poste | Coût estimé |
|---|---|
| Sur-coût phase parallèle (3 mois × 30 % volume × tarif majoré) | 25 000 € |
| AO et sélection remplaçant | 8 000 € |
| Documentation et juridique | 5 000 € |
| Temps interne (manager dédié 30 % sur 12 mois) | 22 000 € |
| Total | 60 000 € |

À comparer aux risques évités :
- Rupture de service : 80-200 k€
- Contentieux : 30-80 k€
- Perte clients : 100-300 k€
- Total potentiel : 200-600 k€

ROI : x 3-10 selon les risques évités. La transition maîtrisée est largement profitable face à une rupture brutale.

INDICATEURS DE RÉUSSITE

À M+12, mesurer :
- Aucun litige juridique avec le sortant
- Performance du remplaçant ≥ standard du panel
- Aucune perte de client significative
- Coûts de transition dans les estimations
- Bonne préservation de l''image

CAPITALISATION

Documents à conserver et capitaliser :
- Procédure de désengagement (template)
- Modèles de lettres
- Calendrier type
- Coûts standards
- Pièges identifiés
- Apprentissages spécifiques

Ces livrables enrichissent le référentiel interne et facilitent les prochains désengagements (qui sont inévitables dans toute relation longue durée).'),
  (v_formation, 'qr', 'Comparez le pilotage d''un panel de 5 sous-traitants stratégiques (gros volumes) vs 15 sous-traitants tactiques (volumes moyens). Différences en termes de KPI, fréquence de suivi, audits, ressources allouées et coût total de gestion.', NULL, 1, 'difficile', ARRAY['pilotage','strategiques','tactiques'], 'mft-2026-gotrm:bc02-02:qr:4', true, 'COMPARAISON DU PILOTAGE — STRATÉGIQUES VS TACTIQUES

PROFILS

| Profil | Stratégiques | Tactiques |
|---|---|---|
| Nombre | 5 | 15 |
| Volume unitaire moyen | 800 k€/an | 200 k€/an |
| Volume total | 4 M€/an (50 % du CA panel) | 3 M€/an (50 % du CA panel) |
| Engagement contractuel | Long terme (3-5 ans) | Annuel reconduit |
| Dépendance | Élevée | Diluée |

KPI ET FRÉQUENCE DE SUIVI

KPI STRATÉGIQUES (5 sous-traitants)

| KPI | Fréquence |
|---|---|
| Ponctualité | Quotidienne (alertes télématique) + agrégat hebdomadaire |
| Intégrité, conformité doc | Hebdomadaire |
| Score scorecard complet (16 indicateurs) | Mensuelle |
| KPI financiers (DSO, encours) | Mensuelle |
| KPI clients (NPS, churn) | Trimestrielle |
| Bilan complet | Annuelle |

Reporting type : 12 KPI suivis quotidien/hebdo, 25 KPI suivis mensuel.

KPI TACTIQUES (15 sous-traitants)

| KPI | Fréquence |
|---|---|
| Ponctualité, intégrité | Hebdomadaire (synthèse) |
| Score scorecard (10 indicateurs simplifiés) | Mensuelle |
| Conformité documentaire | Semestrielle |
| Bilan complet | Annuelle |

Reporting type : 6 KPI suivis hebdomadaire, 12 KPI suivis mensuel.

AUDITS

AUDITS STRATÉGIQUES

| Audit | Fréquence | Profondeur |
|---|---|---|
| Administratif (L. 8222-1) | Semestrielle | Approfondi |
| Terrain | Annuelle | Complet (1 jour) |
| Financier (bilans) | Annuelle | Détaillé |
| Spécifique (ADR, ATP) | Annuelle | Très détaillé |
| Cybersécurité (intégration TMS) | Annuelle | Complet |

Coût audits/an par stratégique : ~ 6 000-10 000 €
Total stratégiques : 30 000-50 000 €/an

AUDITS TACTIQUES

| Audit | Fréquence | Profondeur |
|---|---|---|
| Administratif (L. 8222-1) | Semestrielle | Standard |
| Terrain | Tous les 2-3 ans | Allégé (1/2 jour) |
| Financier | Annuelle | Vérification rapide |
| Spécifique | Selon nécessité | Standard |

Coût audits/an par tactique : ~ 1 500-3 000 €
Total tactiques : 22 500-45 000 €/an

RESSOURCES ALLOUÉES

ÉQUIPE STRATÉGIQUES

- 1 chef d''exploitation référent par 1-2 sous-traitants stratégiques
- Total : 3-4 chefs d''exploitation à 30 % de leur temps
- Coût : 90 000-130 000 €/an

ÉQUIPE TACTIQUES

- 1 chef d''exploitation pour 5-7 sous-traitants tactiques
- Total : 2-3 chefs d''exploitation à 25 % de leur temps
- Coût : 50 000-80 000 €/an

OUTILS ET SYSTÈMES

POUR LES STRATÉGIQUES

- Intégration télématique (échange de données temps réel)
- Module CRM dédié avec scorecard automatisé
- Comité de pilotage trimestriel formalisé
- Plan de continuité actif (alternatives identifiées)

Coût : 15 000-25 000 €/an

POUR LES TACTIQUES

- Reporting mensuel via TMS standard
- Tableau de bord agrégé (Power BI)
- Comité de pilotage annuel
- Pas de plan de continuité formalisé (panel suffisamment large)

Coût : 5 000-10 000 €/an

GOUVERNANCE

GOUVERNANCE STRATÉGIQUES

- Comité de pilotage trimestriel (60-90 min)
- Bilan annuel formel (présentation direction)
- Engagement de volume contractuel
- Discussions stratégiques (évolution des besoins, partenariats)

GOUVERNANCE TACTIQUES

- Comité de pilotage annuel (60 min)
- Bilan synthétique
- Pas d''engagement de volume contractuel
- Renouvellement annuel ou non

GESTION DES RISQUES

RISQUE STRATÉGIQUES

- Concentration : 1 sous-traitant = 1 M€/an
- Conséquence d''une défaillance : majeure
- Plan de continuité IMPÉRATIF (alternatives prêtes)
- Audit financier RENFORCÉ (Infogreffe, bilans, trésorerie)
- Diversification volontaire

RISQUE TACTIQUES

- Dilution : 1 sous-traitant = 200 k€/an
- Conséquence d''une défaillance : limitée (3-5 % du panel)
- Plan de continuité ALLÉGÉ (panel suffisant)
- Audit financier STANDARD

COÛTS TOTAUX ANNUELS

| Poste | Stratégiques (5) | Tactiques (15) |
|---|---|---|
| Audits | 30-50 k€ | 22-45 k€ |
| Équipes (temps) | 90-130 k€ | 50-80 k€ |
| Outils et systèmes | 15-25 k€ | 5-10 k€ |
| Total | 135-205 k€ | 77-135 k€ |
| Par sous-traitant | 27-41 k€ | 5-9 k€ |
| Par k€ de CA | 3,4-5,1 % | 2,6-4,5 % |

LE COÛT DE GESTION RAPPORTÉ AU CA EST PLUS ÉLEVÉ POUR LES STRATÉGIQUES (PLUS DE SUIVI INTENSIF) MAIS L''IMPACT SUR LA PERFORMANCE EST AUSSI PLUS ÉLEVÉ.

OPTIMISATION POSSIBLE

POUR LES STRATÉGIQUES

- Industrialiser les processus (templates scorecard, automatisation reporting)
- Co-investir dans des outils communs (TMS partagé, télématique)
- Développer des partenariats préférentiels (engagement croissant)
- Coopération sur des sujets innovation (carbone, électrification)

POUR LES TACTIQUES

- Réduire le panel si certains sont peu performants
- Standardiser les attentes (cahier des charges commun)
- Automatiser les vérifications administratives
- Reporting léger mais systématique

DÉCISION TYPE

Pour une PME bien gérée :
- Maintenir l''écart de traitement entre stratégiques et tactiques
- Réviser annuellement la classification (un tactique peut devenir stratégique si volumes augmentent)
- Communiquer la classification aux sous-traitants (transparent + motivant)

Cette différenciation permet :
- Investissement maximal sur les enjeux clés (stratégiques)
- Efficience opérationnelle sur les volumes diffus (tactiques)
- Allocation optimale des ressources internes
- Réduction des risques systémiques

CONCLUSION

Le pilotage différencié n''est pas une discrimination mais une optimisation des ressources face à des enjeux différents. Les sous-traitants comprennent généralement bien cette logique, surtout si la communication est transparente et si les ascensions du tactique vers le stratégique sont possibles selon les performances.

Sans différenciation, on traite tous les sous-traitants soit avec un excès de moyens (gaspillage sur les tactiques) soit avec un défaut de moyens (risques sur les stratégiques). La maturité d''une fonction sous-traitance se mesure à la qualité de cette différenciation.');


  -- =================================================================
  -- QUIZZES
  -- =================================================================
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — KPI et reporting sous-traitants', 'Scorecard, KPI, reporting, benchmarking.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc02-02:qcm:1','mft-2026-gotrm:bc02-02:qcm:10','mft-2026-gotrm:bc02-02:qcm:12','mft-2026-gotrm:bc02-02:qcm:18');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — Audits de conformité', 'Calendrier audits, grille, conduite, rapport.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc02-02:qcm:2','mft-2026-gotrm:bc02-02:qcm:3','mft-2026-gotrm:bc02-02:qcm:4','mft-2026-gotrm:bc02-02:qcm:5','mft-2026-gotrm:bc02-02:qcm:11','mft-2026-gotrm:bc02-02:qcm:16','mft-2026-gotrm:bc02-02:qcm:20','mft-2026-gotrm:bc02-02:qcm:22','mft-2026-gotrm:bc02-02:qcm:23');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — Plans amélioration et conflits', 'Plan d''amélioration co-construit, recadrage, 4R, escalade.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc02-02:qcm:6','mft-2026-gotrm:bc02-02:qcm:7','mft-2026-gotrm:bc02-02:qcm:17','mft-2026-gotrm:bc02-02:qcm:21');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — Désengagement maîtrisé', 'Procédure résiliation, transition, risques juridiques.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc02-02:qcm:8','mft-2026-gotrm:bc02-02:qcm:9','mft-2026-gotrm:bc02-02:qcm:13','mft-2026-gotrm:bc02-02:qcm:14','mft-2026-gotrm:bc02-02:qcm:15','mft-2026-gotrm:bc02-02:qcm:19','mft-2026-gotrm:bc02-02:qcm:24','mft-2026-gotrm:bc02-02:qcm:25');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Examen blanc — BC02-02 Suivi sous-traitants', '12 QCM en 25 min, seuil 50 %.', 'examen', 1500, 50)
  RETURNING id INTO v_quiz_eb;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc02-02:qcm:1','mft-2026-gotrm:bc02-02:qcm:2','mft-2026-gotrm:bc02-02:qcm:4','mft-2026-gotrm:bc02-02:qcm:6','mft-2026-gotrm:bc02-02:qcm:7','mft-2026-gotrm:bc02-02:qcm:8','mft-2026-gotrm:bc02-02:qcm:9','mft-2026-gotrm:bc02-02:qcm:13','mft-2026-gotrm:bc02-02:qcm:14','mft-2026-gotrm:bc02-02:qcm:15','mft-2026-gotrm:bc02-02:qcm:21','mft-2026-gotrm:bc02-02:qcm:23');

  RAISE NOTICE '✅ GOTRM BC02-02 v2 chargé : 4 leçons, 25 QCM, 4 QR, 5 quizzes (4 entraînement + 1 examen blanc).';
END
$bc02_02$;
