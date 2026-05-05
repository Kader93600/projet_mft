-- =====================================================================
-- GOTRM (RNCP 40990) — BC01-08 : Relation client et qualité de service
-- Cycle relation, SLA, CRM, gestion des situations difficiles.
-- =====================================================================

DO $bc01_08$
DECLARE
  v_formation uuid; v_bloc int; v_module uuid;
  v_lesson_1 uuid; v_lesson_2 uuid; v_lesson_3 uuid; v_lesson_4 uuid;
  v_quiz_1 uuid; v_quiz_2 uuid; v_quiz_3 uuid; v_quiz_4 uuid; v_quiz_eb uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc.'; END IF;

  DELETE FROM public.modules WHERE slug = 'gotrm-bc01-08-relation-client-qualite';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'BC01-08 — Relation client et qualité de service',
    'gotrm-bc01-08-relation-client-qualite', v_bloc,
    'Cycle de la relation client transport, qualité de service et SLA, outils CRM et feedback, gestion des situations difficiles.',
    'intermediaire', 150, 80
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 80, true) ON CONFLICT DO NOTHING;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-08:%';

  -- =================================================================
  -- LEÇON 1 — Cycle de la relation client
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Le cycle complet de la relation client transport',
    'gotrm-bc01-08-01-cycle-relation', 1, 40,
$lesson1$
# Le cycle complet de la relation client transport

La relation client en transport ne commence pas à la livraison : elle débute au premier contact commercial et se prolonge bien au-delà du dernier bon livré. Comprendre ce cycle permet de **fidéliser durablement** et de transformer chaque mission en opportunité.

> 🎯 **Objectifs de la leçon**
>
> - Identifier les **5 phases** du cycle relation client.
> - Distinguer les **rôles** côté transporteur (commercial, exploitant, conducteur, comptable).
> - Comprendre le concept de **moments de vérité**.
> - Mesurer la **valeur d'un client** sur la durée (LTV).

---

## 1. Les 5 phases du cycle

### Phase 1 — Prospection et qualification

Premier contact avec un prospect. L'objectif : identifier si l'entreprise correspond à votre offre, et inversement.

| Élément clé | Détail |
|---|---|
| Sources | Bouche-à-oreille, salons, démarchage, web |
| Qualifier | Volumes, fréquence, exigences, budget, décideurs |
| Éviter | Devis à l'aveugle sans qualification minimum |

### Phase 2 — Devis et négociation

Le prospect demande une cotation, on construit l'offre, on négocie.

| Élément clé | Détail |
|---|---|
| Outils | Calcul CRT, marge cible, prix marché |
| Délai standard | Devis sous 24-48 h pour requêtes simples, 5-7 jours pour appels d'offres |
| Personnalisation | Mention des points spécifiques relevés en qualification |

### Phase 3 — Première mission (test)

C'est le moment crucial. Le prospect devient client avec une mission « test », souvent surveillée de près.

| Élément clé | Détail |
|---|---|
| Anticipation | Brief équipage : c'est un nouveau client, soin maximal |
| Exécution | Respect strict des engagements (heure, état marchandise) |
| Communication | Confirmation enlèvement, livraison effectuée, scan documents |
| Suivi | Appel commercial 24-48 h après pour retour |

### Phase 4 — Récurrence et fidélisation

Le client renouvelle. C'est la phase la plus rentable : on amortit le coût d'acquisition.

| Élément clé | Détail |
|---|---|
| Bilan trimestriel | Revue commerciale chiffrée |
| Anticipation des besoins | Volumes saisonniers, projets futurs |
| Up-selling / cross-selling | Nouveaux services (ADR, hayon, ATP) |
| Engagement | Avenants, contrats annuels, tarifs négociés |

### Phase 5 — Sortie ou rupture

Tout client peut un jour partir : reprise par concurrent, fin d'activité, désaccord. Une bonne sortie laisse une porte ouverte au retour.

| Élément clé | Détail |
|---|---|
| Comprendre | Demander la raison du départ (questionnaire, entretien) |
| Conserver | Données pour relance future |
| Soigner | Dernière facture, réponse aux dernières demandes |
| Capitaliser | Apprentissages pour les autres clients |

---

## 2. Les rôles côté transporteur

### 2.1 Le commercial

| Mission | Détail |
|---|---|
| Prospection active | Identification, premiers contacts |
| Qualification | Compréhension des besoins |
| Négociation tarifaire | Avec validation direction selon seuils |
| Suivi commercial | Bilans trimestriels, plan de comptes |

### 2.2 L'exploitant

| Mission | Détail |
|---|---|
| Prise de commande quotidienne | Confirmation, ajustements, urgences |
| Allocation ressources | Véhicules, conducteurs |
| Suivi opérationnel | Tracking, alertes, anticipation |
| Communication client | Heure d'arrivée, retards, problèmes |

### 2.3 Le conducteur

| Mission | Détail |
|---|---|
| Représentation | C'est l'image de l'entreprise sur le terrain |
| Exécution | Heure, état marchandise, documents signés |
| Communication | Politesse, pédagogie sur les contraintes |
| Remontée information | Tout incident, toute observation utile |

### 2.4 Le service client / comptabilité

| Mission | Détail |
|---|---|
| Facturation | Émission, suivi des paiements |
| Réclamations | Traitement amiable, escalade si besoin |
| Bilan annuel | Statistiques, KPI, communication transparente |

---

## 3. Les moments de vérité

Concept marketing transposé au transport : ce sont les **instants où le client juge réellement** la qualité de service. Une seule défaillance peut effacer 10 missions parfaites.

| Moment de vérité | Risque |
|---|---|
| **Premier appel** : qui répond, en combien de temps, comment ? | Image du sérieux |
| **Confirmation enlèvement** : précise, à l'heure ? | Confiance dans l'exécution |
| **Comportement conducteur** : ponctuel, courtois, pro ? | Image de l'entreprise |
| **Émission CMR/BL** : signé proprement, sans erreur ? | Sérieux administratif |
| **Communication d'un retard** : proactive ou tardive ? | Sentiment de respect |
| **Délai de réponse à une réclamation** : sous 4 h ou jamais ? | Confiance dans la fidélisation |
| **Facture** : claire, conforme au devis, dans les délais ? | Sérieux global |

> 💡 **Règle d'or**
>
> Une **mauvaise expérience** sur un moment de vérité a **5 à 10 fois plus de poids** qu'une bonne expérience pour la fidélisation. C'est pourquoi les meilleurs transporteurs investissent en priorité sur la **réduction des risques** plutôt que sur l'excellence partielle.

---

## 4. La valeur vie client (LTV)

### 4.1 Définition

La **LTV** (Lifetime Value) est la somme des revenus qu'un client va générer pendant toute sa relation avec l'entreprise. Pour un transporteur :

```
LTV = Revenu annuel moyen × Marge nette × Durée moyenne de la relation
```

### 4.2 Calcul pratique

> 📌 **Exemple LTV**
>
> Un client *Distribution Vendée* :
> - Volume annuel : 180 000 €
> - Marge nette transporteur : 7 %
> - Durée moyenne client (statistique) : 6 ans
> - **LTV = 180 000 × 7 % × 6 = 75 600 €**
>
> Une rupture précoce à 2 ans représenterait une perte de **50 400 €** par rapport à la moyenne.

### 4.3 Implication

Investir dans la fidélisation est **5 à 10 fois plus rentable** que d'acquérir un nouveau client (coût d'acquisition = 8-15 % du CA annuel typiquement). C'est le principal levier de profitabilité d'un transporteur.

---

## 5. Cas pratique : structurer un cycle client

**Contexte** : *Trans-Loire SAS* (12 véhicules) souhaite structurer sa relation client. Aujourd'hui : 1 commercial, 2 exploitants, pas de processus formalisé.

### Plan de structuration sur 3 mois

| Action | Échéance |
|---|---|
| Définir le **profil idéal client** (segment cible, volumes, secteurs) | Sem 1-2 |
| Cartographier les **5 phases** du cycle pour son entreprise | Sem 3 |
| Créer un **processus écrit** par phase, accessible à tous | Sem 4-5 |
| Outils minimum : **CRM léger** (HubSpot gratuit, Pipedrive) | Sem 6-7 |
| Formation interne : commercial, exploitants, comptabilité | Sem 8-9 |
| Mise en œuvre, retours, ajustements | Sem 10-12 |
| Bilan : nombre de prospects qualifiés, taux conversion, retour clients | Mois 3+ |

> 💡 **Bonne pratique**
>
> Tenir un **dossier client centralisé** comprenant : fiche identification, contrats, historique missions, échanges (mails, appels), incidents, paiements, opportunités. Cela transforme un client « propriété » du commercial en client « propriété » de l'entreprise.

---

> ✅ **À retenir**
>
> - **5 phases** : prospection → devis → première mission → fidélisation → sortie.
> - **4 rôles** transporteur : commercial, exploitant, conducteur, service client.
> - **Moments de vérité** : 1 défaillance efface 10 missions parfaites.
> - **LTV** : un client moyen = 5 à 10 ans de relation, fidéliser = 5 fois moins coûteux qu'acquérir.
$lesson1$,
'5 phases du cycle relation client (prospection → fidélisation), rôles côté transporteur, moments de vérité, calcul de la LTV (lifetime value).'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Qualité de service et SLA
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Qualité de service, SLA et engagements contractuels',
    'gotrm-bc01-08-02-qualite-sla', 2, 40,
$lesson2$
# Qualité de service, SLA et engagements contractuels

La **qualité de service** est l'écart entre ce que le client attend et ce qu'il reçoit. La maîtriser passe par des **engagements clairs** (SLA) et une **mesure objective** des performances.

> 🎯 **Objectifs de la leçon**
>
> - Définir la **qualité de service** en transport.
> - Maîtriser les **SLA** (Service Level Agreements).
> - Identifier les **KPI qualité** : ponctualité, intégrité, conformité.
> - Comprendre les **pénalités** et les **bonus contractuels**.

---

## 1. Définir la qualité de service

### 1.1 Les 5 dimensions

| Dimension | Définition |
|---|---|
| **Fiabilité** | Tenir ses engagements (heure, intégrité, prix) |
| **Réactivité** | Répondre rapidement aux demandes |
| **Compétence** | Savoir-faire technique et expertise |
| **Empathie** | Comprendre et s'adapter au client |
| **Tangible** | Aspect des véhicules, propreté, tenue conducteur |

### 1.2 La satisfaction client

```
Satisfaction = Perception - Attente
```

| Cas | Effet |
|---|---|
| Perception > Attente | Client enchanté, ambassadeur |
| Perception = Attente | Client satisfait, fidèle |
| Perception < Attente | Client mécontent, risque de fuite |

> 📌 **Erreur classique**
>
> Sur-promettre pour décrocher un contrat puis sous-livrer = **fuite garantie** sous 6 mois. Mieux vaut sous-promettre et sur-livrer.

---

## 2. Les SLA (Service Level Agreements)

### 2.1 Définition

Le **SLA** est un engagement contractuel **chiffré** sur un niveau de service à atteindre. Il transforme la qualité subjective en mesure objective.

### 2.2 Les SLA classiques en transport

| KPI | SLA standard | SLA exigeant |
|---|---|---|
| **Ponctualité livraison** | 95 % dans la fenêtre RDV | 98 % |
| **Intégrité marchandise** | 99,5 % livré sans avarie | 99,9 % |
| **Conformité documentaire** | 99 % CMR sans erreur | 99,9 % |
| **Délai d'enlèvement** | J+0 ou J+1 | J+0 garanti |
| **Délai de livraison** | J+1 régional, J+2 national | J+1 national |
| **Réponse réclamation** | Sous 24 h ouvrées | Sous 4 h ouvrées |

### 2.3 Mesurer un SLA

Pour qu'un SLA soit utile, il doit être :
- **S**pécifique : qui, quoi, où
- **M**esurable : indicateur précis avec calcul
- **A**tteignable : pas une promesse irréaliste
- **R**éaliste : aligné avec les capacités opérationnelles
- **T**emporel : période de référence (mois, trimestre)

> 📌 **Exemple SLA bien rédigé**
>
> *« Pour les livraisons en région Île-de-France hors zones de circulation restreinte, le transporteur s'engage à livrer 96 % des points dans la fenêtre RDV de 60 minutes mesurée mensuellement sur l'ensemble des livraisons facturées. »*

---

## 3. Pénalités et bonus

### 3.1 Pénalités contractuelles

Les pénalités sont des **réductions de facturation** automatiques en cas de non-atteinte des SLA.

| Type de pénalité | Exemple |
|---|---|
| **Forfaitaire** | 50 € par livraison hors créneau |
| **Proportionnelle** | 1 % du prix par tranche d'écart |
| **Progressive** | 2 % au 1er manquement, 5 % aux 2 suivants, 10 % au-delà |
| **Plafonnée** | Maximum 15 % du CA mensuel |

### 3.2 Bonus de performance

Moins fréquents mais existants, surtout en partenariats stratégiques :

| Type de bonus | Exemple |
|---|---|
| **Bonus de ponctualité** | +1 % du CA si ponctualité > 99 % sur le mois |
| **Bonus zéro avarie** | Prime fixe si trimestre sans incident |
| **Bonus volume** | Tarif dégressif au-delà de seuils |

### 3.3 Bonne pratique de négociation

| Recommandation | Raison |
|---|---|
| Ne pas accepter un **plafond de pénalité > 15 % du CA** | Au-delà, la rentabilité est en risque |
| Définir **clairement les exclusions** (force majeure, faute du client) | Éviter les contestations |
| Lier **bonus et pénalités** | Équilibre |
| Prévoir une **revoyure** annuelle des SLA | Adaptation aux évolutions |

---

## 4. Le système de management qualité

### 4.1 ISO 9001

La certification **ISO 9001** est la norme internationale de management de la qualité. Elle est de plus en plus demandée par les chargeurs grands comptes.

| Avantage | Inconvénient |
|---|---|
| Crédibilité commerciale | Coût (audit annuel, structuration) |
| Démarche structurée | Charge administrative supplémentaire |
| Amélioration continue formalisée | Délai de mise en place 12-18 mois |
| Réduction des erreurs / incidents | Investissement humain à prévoir |

### 4.2 ISO 9001 + qualifications transport

Quelques certifications spécifiques au transport :

- **OEA** (Opérateur Économique Agréé) — Douane
- **TAPA** (Transported Asset Protection Association) — Sûreté marchandises de valeur
- **HACCP** — Sécurité sanitaire (alimentaire)
- **GDP** — Bonnes pratiques de distribution (médicaments)

---

## 5. Cas pratique : négocier un SLA

**Contexte** : Un client industriel important (volumes 2 M€/an) propose le SLA suivant :

```
- Ponctualité : 99 %
- Intégrité : 99,9 %
- Pénalité : 5 % de la facture mensuelle pour chaque % manquant
- Pas d'exclusion (sauf force majeure stricte)
- Pas de bonus
```

### Analyse et contre-proposition

**Risques avec ce SLA** :
- 99 % de ponctualité = très exigeant, peu réalisable en distribution urbaine
- Pénalités cumulables sans plafond : si 95 % atteint au lieu de 99 % = 4 × 5 % = 20 % de pénalité
- Pas d'exclusion pour la faute du client (RDV non tenu, etc.)
- Pas de bonus en compensation

**Contre-proposition recommandée** :

```
- Ponctualité : 96 % (réaliste, conforme prix marché actuel)
- Intégrité : 99,5 %
- Pénalité progressive :
  - 1 pt en deçà : 2 % pénalité
  - 2 à 3 pts : 4 % pénalité
  - Au-delà : 6 % pénalité
- Plafond : 12 % du CA mensuel
- Exclusions : force majeure + faute prouvée du client + retards routiers majeurs
- Bonus : +1 % du CA si ponctualité > 99 % sur le trimestre
- Revoyure annuelle des SLA
```

> 💡 **Logique de la contre-proposition**
>
> - Cible **réaliste** atteignable
> - Pénalité **progressive** plus juste
> - **Plafond** protège la rentabilité
> - **Exclusions** clarifiées
> - **Bonus** récompense l'excellence

Si le client refuse toute négociation, il faut savoir **refuser le contrat** plutôt que d'accepter un cadre intenable.

---

> ✅ **À retenir**
>
> - **5 dimensions** qualité : fiabilité, réactivité, compétence, empathie, tangible.
> - **SLA** = engagement chiffré, mesurable, dans le temps.
> - KPI standards : ponctualité 95-98 %, intégrité 99,5-99,9 %, conformité doc 99 %.
> - Toujours négocier **plafond pénalités** + **exclusions** + **bonus** + **revoyure annuelle**.
> - **ISO 9001** est de plus en plus demandée par les grands chargeurs.
$lesson2$,
'5 dimensions de la qualité, formule satisfaction = perception - attente, SLA SMART, pénalités/bonus, ISO 9001 + certifications transport (OEA, TAPA, GDP).'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — CRM et feedback client
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'CRM et outils de feedback client',
    'gotrm-bc01-08-03-crm-feedback', 3, 35,
$lesson3$
# CRM et outils de feedback client

Mesurer la satisfaction client, capter les signaux faibles, anticiper les ruptures : c'est le rôle des outils **CRM** et des **dispositifs de feedback** structurés.

> 🎯 **Objectifs de la leçon**
>
> - Identifier les **fonctions clés** d'un CRM en transport.
> - Connaître les **principaux outils** du marché.
> - Maîtriser le **NPS**, le **CSAT** et le **CES**.
> - Mettre en place une **boucle d'amélioration** par le feedback.

---

## 1. Le CRM (Customer Relationship Management)

### 1.1 Fonctions clés

| Fonction | Détail |
|---|---|
| **Base clients** | Identification, contacts, historique |
| **Pipeline commercial** | Prospects → devis → contrats |
| **Suivi missions** | Lien avec TMS / facturation |
| **Réclamations** | Tickets, traitement, statistiques |
| **Reporting** | KPI commerciaux, tableaux de bord |

### 1.2 Principaux CRM utilisés en transport

| Outil | Profil |
|---|---|
| **HubSpot CRM** | Gratuit jusqu'à 1 M contacts, intuitif, idéal PME |
| **Salesforce** | Leader mondial, riche mais coûteux et complexe |
| **Pipedrive** | Pipeline visuel, simple, bon rapport prix/fonction |
| **Zoho CRM** | Suite complète à prix maîtrisé |
| **Monday CRM** | Hybrid CRM/projet, visuel |
| **TMS intégré** | Certains TMS (AlpegaTMS, Optitrans) intègrent un module CRM |

### 1.3 Données clés à tracer

- Identification : raison sociale, SIREN, contacts, secteur
- Volumes : CA mensuel, fréquence, saisonnalité
- Conditions : délais paiement, RDV, exigences SLA
- Historique : missions, factures, paiements
- Communications : appels, mails, courriers
- Réclamations : nombre, type, statut, traitement
- Opportunités : prospects en cours, tarif négocié

---

## 2. Le NPS (Net Promoter Score)

### 2.1 Définition

Indicateur simple de satisfaction et fidélité. **1 question** : *« Recommanderiez-vous notre entreprise sur une échelle de 0 à 10 ? »*

| Score | Catégorie |
|---|---|
| 9-10 | **Promoteurs** |
| 7-8 | Passifs |
| 0-6 | **Détracteurs** |

```
NPS = % Promoteurs - % Détracteurs
```

### 2.2 Interprétation

| NPS | Signification |
|---|---|
| > 50 | Excellent |
| 30-50 | Bon |
| 0-30 | Moyen |
| < 0 | Mauvais (plus de détracteurs que de promoteurs) |

> 📌 **NPS moyen secteur transport**
>
> Le NPS moyen du transport B2B en France est de **20-30**. Au-dessus de 40, l'entreprise est dans le top quartile.

### 2.3 Quand mesurer ?

- **Annuellement** pour la base cliente complète
- **Après un moment de vérité** (1ère mission, réclamation traitée)
- **Trimestriellement** pour les top 20 % de la base

---

## 3. CSAT et CES

### 3.1 CSAT (Customer Satisfaction)

Échelle de 1 à 5 sur une mission spécifique.

```
*« Globalement, comment évaluez-vous cette mission ? »*
1 - Très insatisfait | 2 - Insatisfait | 3 - Neutre | 4 - Satisfait | 5 - Très satisfait
```

```
CSAT = (% de notes 4 et 5) - (% de notes 1 et 2)
```

### 3.2 CES (Customer Effort Score)

Mesure l'effort que le client a dû fournir pour obtenir le service.

```
*« Quel effort avez-vous dû fournir pour résoudre votre demande ? »*
1 - Très peu d'effort à 7 - Beaucoup d'effort
```

| Application | Détail |
|---|---|
| Idéal pour mesurer une réclamation | Plus prédictif que NPS sur la fidélisation |
| Cible | < 3 |
| Levier d'action | Simplifier les processus client |

---

## 4. Construire une boucle de feedback

### 4.1 Les 4 étapes

1. **Collecter** régulièrement (NPS, CSAT, réclamations)
2. **Analyser** par segment (taille client, secteur, géographie)
3. **Restituer** en interne (commercial, exploitation, direction)
4. **Agir** : plans d'action sur les points faibles

### 4.2 Outils de collecte

| Outil | Caractéristique |
|---|---|
| **SurveyMonkey** | Standard simple, gratuit |
| **Typeform** | Élégant, expérience utilisateur soignée |
| **Trustpilot** | Avis publics, visible client final |
| **Google Forms** | Gratuit, intégration Google Workspace |
| **Module TMS / CRM intégré** | Lien avec les missions |

### 4.3 Ratio à viser

| Indicateur | Cible |
|---|---|
| Taux de réponse aux enquêtes | > 25 % (motiver via relance) |
| Délai d'analyse | < 7 jours après collecte |
| Taux d'action | 100 % des feedbacks négatifs traités |
| Bouclage retour client | < 30 jours |

> 💡 **Boucler la boucle**
>
> Quand un client donne un feedback, lui **revenir vers lui sous 30 jours** avec un message du type : *« Vous nous avez signalé X. Voici ce que nous avons fait pour y répondre. Merci de votre confiance. »* Cela transforme un détracteur en promoteur.

---

## 5. Cas pratique : NPS et plan d'action

**Contexte** : *Express Loire* lance sa première campagne NPS sur 80 clients actifs. Résultats :

| Catégorie | Nombre | % |
|---|---|---|
| Promoteurs (9-10) | 24 | 30 % |
| Passifs (7-8) | 38 | 47 % |
| Détracteurs (0-6) | 18 | 23 % |
| Total | 80 | 100 % |

**Calcul NPS** : 30 % - 23 % = **7** (NPS faible)

### Analyse qualitative des détracteurs

Sur les 18 détracteurs, l'analyse des verbatims révèle 3 motifs principaux :
1. **Communication tardive sur les retards** (10 mentions)
2. **Délais de réponse réclamation > 48 h** (8 mentions)
3. **Erreurs de facturation récurrentes** (5 mentions)

### Plan d'action 6 mois

| Action | Cible | Échéance |
|---|---|---|
| Mise en place alertes télématiques retard automatique | Communication < 30 min après détection | M+1 |
| Engagement formel : réponse réclamation < 4 h ouvrées | CES réclamation < 3 | M+2 |
| Audit du processus facturation + double check | Erreurs / 100 factures < 1 | M+3 |
| Re-mesure NPS à M+6 | NPS > 25 (cible top tiers) | M+6 |

### Communication aux clients

Tous les répondants reçoivent un message :
- Promoteurs : *« Merci de votre confiance, comment puis-je vous aider à grandir avec nous ? »* + opportunité commerciale.
- Passifs : *« Que ferions-nous différemment pour passer à 9 ou 10 ? »*
- Détracteurs : *« Nous avons entendu votre feedback, voici notre plan d'action. Nous reviendrons vers vous dans 6 mois. »*

> 📌 **ROI typique d'une démarche feedback**
>
> Pour 80 clients, NPS qui passe de 7 à 30 en 6 mois = ~30 % de risque de churn en moins (statistique sectorielle). Si le churn naturel était de 12 % annuel, on passe à ~ 8 %. Soit **3,2 clients sauvés** = ~ 75 k€ de CA non perdu (3,2 × 23 k€/client moyen).

---

> ✅ **À retenir**
>
> - **CRM** : base centralisée pour structurer la relation client (HubSpot, Salesforce, Pipedrive).
> - **NPS** = % promoteurs - % détracteurs ; secteur transport B2B moyen 20-30, excellent > 50.
> - **CSAT** : satisfaction sur une mission, **CES** : effort fourni par le client.
> - **Boucler la boucle** : revenir vers le client dans les 30 jours avec les actions menées.
$lesson3$,
'CRM (HubSpot, Salesforce, Pipedrive), NPS (% promoteurs - % détracteurs, cible >30 secteur), CSAT, CES, boucle feedback en 4 étapes, communication retour < 30 jours.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Gestion des situations difficiles
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Gérer les situations difficiles : retards, refus, conflits',
    'gotrm-bc01-08-04-situations-difficiles', 4, 35,
$lesson4$
# Gérer les situations difficiles : retards, refus, conflits

Tout exploitant rencontre des situations difficiles : retards inévitables, livraisons refusées, clients agressifs. La manière de les gérer fait la différence entre **fidéliser** et **perdre** un client.

> 🎯 **Objectifs de la leçon**
>
> - Maîtriser la **communication d'un retard**.
> - Gérer un **refus de livraison** sans perdre le client.
> - Désamorcer un **conflit** par téléphone ou en face à face.
> - Identifier les **clients toxiques** à éconduire.

---

## 1. Communiquer un retard

### 1.1 Les 5 règles d'or

| # | Règle | Pourquoi |
|---|---|---|
| 1 | **Anticiper** : alerter dès que le retard est probable, pas constaté | Permet au client d'adapter son organisation |
| 2 | **Donner une nouvelle ETA précise** : pas « bientôt » | Information actionnable |
| 3 | **Expliquer** brièvement la cause | Pas de longues justifications |
| 4 | **Proposer une alternative** si possible | Démontre l'engagement |
| 5 | **Confirmer la résolution** au moment de la livraison | Boucler la boucle |

### 1.2 Script type

> *« Bonjour Madame X, ici Y de Trans-Sud. Nous suivons votre livraison prévue à 14 h aujourd'hui. Suite à un accident sur l'A6, notre véhicule est retardé. La nouvelle heure d'arrivée prévue est 15 h 45. Pouvez-vous nous confirmer si ce nouveau créneau est compatible avec vos contraintes ? Si non, nous pouvons proposer une livraison demain matin avant 10 h. »*

### 1.3 Ce qu'il NE faut PAS faire

- Attendre que le client appelle pour signaler le retard
- Communiquer un horaire approximatif (« en début d'après-midi »)
- Multiplier les excuses sans solution
- Renvoyer la responsabilité (« c'est pas notre faute »)
- Ignorer les conséquences concrètes pour le client

---

## 2. Gérer un refus de livraison

### 2.1 Causes typiques

| Cause | Origine |
|---|---|
| Marchandise endommagée | Transporteur (manutention, chute) |
| Quantité ou référence incorrecte | Expéditeur |
| Hors créneau RDV | Transporteur |
| Marchandise non commandée | Expéditeur (erreur) |
| Document manquant | Expéditeur ou transporteur |
| Réceptionnaire absent | Client (problème interne) |

### 2.2 Procédure conducteur en cas de refus

1. **Ne pas insister** s'il y a un refus formel
2. **Documenter** : photos de la marchandise, état, quai
3. **Faire signer** un constat de refus motivé
4. **Appeler l'exploitation** sur place (avant départ)
5. **Récupérer** les marchandises avec consignes claires (retour, garde, attente)

### 2.3 Procédure exploitation

1. **Information immédiate** au client expéditeur
2. **Décision rapide** : réexpédition, retour, expertise
3. **Documentation** complète : constat, photos, CMR
4. **Suivi** : facturation, indemnisation éventuelle
5. **Analyse** : prévenir la récurrence

> 💡 **Cas particulier — refus pour motif financier**
>
> Si le client refuse pour un litige antérieur (impayé), le conducteur ne livre pas et l'exploitation prend le relais avec la comptabilité. Ne **jamais** créer un nouveau litige pour résoudre un litige antérieur.

---

## 3. Désamorcer un conflit

### 3.1 Les 4 étapes du désamorçage

1. **Écouter** : laisser le client exprimer sa frustration
2. **Reformuler** : *« Si je comprends bien, vous me dites que... »*
3. **Reconnaître** : *« Je comprends que cette situation soit pénible »*
4. **Proposer** : une solution concrète, action datée

### 3.2 Phrases utiles

| Phrase | Effet |
|---|---|
| *« Je vous remercie de me signaler ce point »* | Désamorce l'agressivité |
| *« Je vais m'en occuper personnellement »* | Engagement nominatif |
| *« Je vous rappelle dans X minutes avec une réponse »* | Engagement temporel précis |
| *« Quelle solution serait acceptable pour vous ? »* | Dialogue constructif |

### 3.3 Phrases à éviter absolument

- *« Calmez-vous »* (effet inverse garanti)
- *« C'est la procédure »* (rigidité froide)
- *« Ce n'est pas mon problème »* (déresponsabilisation)
- *« Vous auriez dû... »* (culpabilisation)
- *« On ne peut rien faire »* (impuissance affichée)

### 3.4 Cas du client agressif verbalement

Si la conversation dérape et que le client devient injurieux :

1. Garder son **calme** et un ton **posé**
2. **Mettre en garde** : *« Monsieur, je comprends votre énervement, mais je vous demande de garder un ton respectueux »*
3. Si persistance : **proposer un rappel ultérieur** *« Je vais vous laisser, je vous rappellerai dans 30 minutes pour reprendre notre discussion »*
4. **Faire le point** avec sa hiérarchie

---

## 4. Identifier les clients toxiques

### 4.1 Signaux d'alerte

Tous les clients ne sont pas bons à garder. Certains coûtent **plus** qu'ils ne rapportent.

| Signal | Risque |
|---|---|
| Retards de paiement chroniques | BFR négatif |
| Réclamations infondées répétées | Temps perdu |
| Pression tarifaire constante sans contrepartie | Marge dégradée |
| Comportement disrespectueux récurrent | Climat social interne dégradé |
| Demandes hors contrat permanentes | Charge cachée |
| Recours abusif aux pénalités | Rentabilité érodée |

### 4.2 La règle des 3 chocs

Si un client cumule **3 dérapages graves en 12 mois** sans amélioration après échanges directs :

1. Bilan factuel chiffré : impayés, pénalités, temps passé en réclamations
2. Calcul de la rentabilité réelle (pas seulement le CA)
3. Décision de **mettre fin progressivement** à la relation
4. Plan de désengagement sur 6-12 mois (préavis, fin de contrat)

> 📌 **Désengagement réussi**
>
> *« Madame X, après analyse, nous constatons que notre collaboration ne nous permet plus de vous offrir le niveau de service auquel vous avez droit. Nous vous proposons de nous accompagner sur les 6 prochains mois pour vous laisser le temps de trouver un partenaire mieux aligné avec vos exigences. »*

### 4.3 Quantification

Un client toxique (mauvais payeur, réclamations infondées, agressivité) coûte typiquement :
- **30-50 % de marge en moins** que la moyenne
- **3 à 5 fois plus de temps administratif**
- **Risque de contagion** sur la motivation interne

S'en séparer libère du **temps, de la marge et de l'énergie** pour développer les bons clients.

---

## 5. Cas pratique : un client agressif au téléphone

**Contexte** : Lundi 10 h. M. Dupont (responsable logistique chez *Bricolage Plus*) appelle l'exploitation, hors de lui : *« Votre conducteur a livré 2 h en retard SAMEDI, le quai était fermé, on a dû tout reprendre AUJOURD'HUI ! C'est INADMISSIBLE ! Je veux votre directeur, MAINTENANT ! »*

### Réponse type

```
Exploitant : « Bonjour M. Dupont, je suis [prénom], exploitant.
Je vous remercie de me signaler ce problème.

[ÉCOUTE] Je vous écoute, expliquez-moi exactement ce qui s'est passé...

[RECONNAISSANCE] Je comprends parfaitement votre énervement,
une livraison à un quai fermé est une situation très pénible
qui vous a fait perdre du temps.

[ACTION IMMÉDIATE] Voici ce que je vous propose :
je consulte tout de suite le tracking GPS et le rapport conducteur
de samedi, je vous rappelle dans 20 minutes maximum
avec les faits exacts et une proposition concrète.
M. Dupont, est-ce que cela vous convient ? »
```

### Analyse interne 20 minutes

- Vérifier tracking : heure d'arrivée réelle au quai
- Lire commentaires conducteur (samedi 14 h, quai fermé, attente vaine 30 min, retour)
- Vérifier ordre de mission : créneau 10 h-12 h ou tournée flexible ?
- Rechercher l'origine du retard (reroutage, problème véhicule, planning trop serré)

### Rappel à H+20 min

```
« M. Dupont, j'ai vérifié les éléments.
Voici les faits : notre conducteur est arrivé à 14 h 15 samedi
au lieu du créneau 10 h-12 h convenu.
Le retard est de notre responsabilité - une casse mécanique
a allongé la tournée matinale.
Nous aurions dû vous prévenir dès 11 h 30, ce qui n'a pas été fait.
Je m'en excuse personnellement.

Voici ce que je vous propose :
1. Un avoir de 30 % sur cette livraison (180 € au lieu de 257 €)
2. Une priorité absolue sur vos 3 prochaines livraisons (ETA confirmée -2h, +1h)
3. Un point téléphonique avec moi tous les vendredis pendant 1 mois
pour valider avec vous le bon déroulement

Ce plan d'action vous convient-il ? »
```

### Effet recherché

- **Reconnaissance** sincère du tort sans excuses excessives
- **Mesure correctrice** chiffrée et concrète
- **Engagement personnel** futur (pas une vague promesse)
- **Bouclage** dans les jours suivants

Statistiquement, un client mécontent **bien traité** devient un client **plus fidèle** que la moyenne — c'est ce qu'on appelle le **paradoxe de la récupération**.

---

> ✅ **À retenir**
>
> - Communiquer un retard : **anticiper, ETA précise, brièveté, alternative, bouclage**.
> - Refus livraison : **documenter, ne pas insister, escalader à l'exploitation**.
> - Désamorcer : **écouter, reformuler, reconnaître, proposer**.
> - Détecter les **clients toxiques** : 3 dérapages en 12 mois → désengagement progressif.
> - **Paradoxe de la récupération** : un client bien traité après incident est plus fidèle que la moyenne.
$lesson4$,
'5 règles communication retard, procédure refus livraison, 4 étapes désamorçage conflit, identification client toxique (règle 3 chocs), paradoxe récupération.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- 25 QCM
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qcm', 'Le cycle classique de relation client transport comporte combien de phases principales ?', '[{"id":"a","label":"3 phases","is_correct":false},{"id":"b","label":"5 phases","is_correct":true},{"id":"c","label":"7 phases","is_correct":false},{"id":"d","label":"10 phases","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['cycle','phases'], 'mft-2026-gotrm:bc01-08:qcm:1', true, 'Le cycle se compose de 5 phases : prospection/qualification → devis/négociation → première mission → fidélisation/récurrence → sortie/rupture éventuelle.'),
  (v_formation, 'qcm', 'La LTV (Lifetime Value) d''un client se calcule comme :', '[{"id":"a","label":"CA × marge brute","is_correct":false},{"id":"b","label":"Revenu annuel moyen × Marge nette × Durée moyenne de la relation","is_correct":true},{"id":"c","label":"Marge mensuelle × 12","is_correct":false},{"id":"d","label":"Volume client / coût d''acquisition","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['ltv','calcul'], 'mft-2026-gotrm:bc01-08:qcm:2', true, 'LTV = Revenu annuel × Marge nette × Durée moyenne. Permet d''évaluer la valeur réelle d''un client sur sa durée de vie chez vous, et de justifier les investissements de fidélisation.'),
  (v_formation, 'qcm', 'Un coût d''acquisition d''un nouveau client en transport B2B représente typiquement :', '[{"id":"a","label":"1-2 % du CA annuel","is_correct":false},{"id":"b","label":"8-15 % du CA annuel","is_correct":true},{"id":"c","label":"30-40 % du CA annuel","is_correct":false},{"id":"d","label":"Plus de 50 %","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['cout-acquisition','fidelisation'], 'mft-2026-gotrm:bc01-08:qcm:3', true, 'Le coût d''acquisition (commercial + marketing) en transport B2B est typiquement de 8-15 % du CA annuel d''un nouveau client. Fidéliser est 5 à 10 fois moins cher qu''acquérir.'),
  (v_formation, 'qcm', 'La formule de la satisfaction client est :', '[{"id":"a","label":"Perception × Attente","is_correct":false},{"id":"b","label":"Perception - Attente","is_correct":true},{"id":"c","label":"Perception + Attente","is_correct":false},{"id":"d","label":"Perception / Attente","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['satisfaction','formule'], 'mft-2026-gotrm:bc01-08:qcm:4', true, 'Satisfaction = Perception - Attente. Si la perception dépasse l''attente : enchantement. Si elle est égale : satisfaction. Si elle est inférieure : insatisfaction. D''où la règle "sous-promettre et sur-livrer".'),
  (v_formation, 'qcm', 'Le SLA est :', '[{"id":"a","label":"Service Level Agreement = engagement chiffré contractuel","is_correct":true},{"id":"b","label":"Société Logistique Auto-organisée","is_correct":false},{"id":"c","label":"Schéma Logistique Annuel","is_correct":false},{"id":"d","label":"Stock Logistique Avancé","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['sla','definition'], 'mft-2026-gotrm:bc01-08:qcm:5', true, 'SLA = Service Level Agreement. Engagement contractuel chiffré sur un niveau de service à atteindre (ponctualité, intégrité, conformité), avec pénalités en cas de non-respect.'),
  (v_formation, 'qcm', 'Une cible de ponctualité standard en SLA transport est de :', '[{"id":"a","label":"80 %","is_correct":false},{"id":"b","label":"95-98 %","is_correct":true},{"id":"c","label":"100 % strict","is_correct":false},{"id":"d","label":"60 %","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['sla','ponctualite'], 'mft-2026-gotrm:bc01-08:qcm:6', true, 'Le standard du marché est 95-98 % de ponctualité dans la fenêtre RDV. 99 % est très exigeant et coûte cher. 100 % strict n''est pas réaliste vu les aléas (trafic, accidents, météo).'),
  (v_formation, 'qcm', 'Un SLA bien rédigé doit être :', '[{"id":"a","label":"Vague pour laisser de la flexibilité","is_correct":false},{"id":"b","label":"SMART : Spécifique, Mesurable, Atteignable, Réaliste, Temporel","is_correct":true},{"id":"c","label":"Très exigeant pour rassurer le client","is_correct":false},{"id":"d","label":"Identique à tous les clients","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['sla','smart'], 'mft-2026-gotrm:bc01-08:qcm:7', true, 'Un bon SLA est SMART : Spécifique (quoi, où, quand), Mesurable (indicateur précis), Atteignable, Réaliste (aligné aux capacités), Temporel (période de référence).'),
  (v_formation, 'qcm', 'Le plafond recommandé pour les pénalités contractuelles SLA est typiquement :', '[{"id":"a","label":"30 % du CA","is_correct":false},{"id":"b","label":"15 % du CA mensuel maximum","is_correct":true},{"id":"c","label":"50 % du CA","is_correct":false},{"id":"d","label":"Pas de plafond","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['sla','plafond-penalites'], 'mft-2026-gotrm:bc01-08:qcm:8', true, 'Au-delà de 15 % du CA mensuel, les pénalités menacent la rentabilité. Toujours négocier un plafond, des exclusions claires (force majeure, faute du client) et idéalement un bonus en compensation.'),
  (v_formation, 'qcm', 'La certification qualité internationale la plus courante en transport est :', '[{"id":"a","label":"ISO 14001","is_correct":false},{"id":"b","label":"ISO 9001","is_correct":true},{"id":"c","label":"ISO 27001","is_correct":false},{"id":"d","label":"ISO 50001","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['iso-9001'], 'mft-2026-gotrm:bc01-08:qcm:9', true, 'ISO 9001 = norme management qualité. De plus en plus demandée par les chargeurs grands comptes. ISO 14001 = environnement, ISO 27001 = sécurité de l''information, ISO 50001 = énergie.'),
  (v_formation, 'qcm', 'L''agrément OEA s''applique principalement à :', '[{"id":"a","label":"La sécurité alimentaire","is_correct":false},{"id":"b","label":"La douane et la simplification des procédures internationales","is_correct":true},{"id":"c","label":"Les transports voyageurs","is_correct":false},{"id":"d","label":"L''environnement","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['oea','certification'], 'mft-2026-gotrm:bc01-08:qcm:10', true, 'OEA = Opérateur Économique Agréé. Statut douanier reconnaissant la fiabilité d''une entreprise pour bénéficier de simplifications (contrôles allégés, garanties réduites, dédouanement centralisé).'),
  (v_formation, 'qcm', 'Le NPS se calcule comme :', '[{"id":"a","label":"% de promoteurs / % de détracteurs","is_correct":false},{"id":"b","label":"% de promoteurs - % de détracteurs","is_correct":true},{"id":"c","label":"Moyenne des notes /10","is_correct":false},{"id":"d","label":"Nombre de promoteurs en valeur absolue","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['nps','calcul'], 'mft-2026-gotrm:bc01-08:qcm:11', true, 'NPS = % Promoteurs (notes 9-10) - % Détracteurs (notes 0-6). Les passifs (7-8) ne sont pas comptabilisés. Échelle de -100 à +100.'),
  (v_formation, 'qcm', 'Les clients ayant donné une note de 9 ou 10 au NPS sont appelés :', '[{"id":"a","label":"Passifs","is_correct":false},{"id":"b","label":"Promoteurs","is_correct":true},{"id":"c","label":"Détracteurs","is_correct":false},{"id":"d","label":"Indifférents","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['nps','categories'], 'mft-2026-gotrm:bc01-08:qcm:12', true, 'Les notes 9-10 = Promoteurs (potentiellement ambassadeurs). 7-8 = Passifs. 0-6 = Détracteurs (susceptibles de partir et de communiquer négativement).'),
  (v_formation, 'qcm', 'Le NPS moyen du secteur transport B2B en France se situe autour de :', '[{"id":"a","label":"-10","is_correct":false},{"id":"b","label":"20-30","is_correct":true},{"id":"c","label":"60-70","is_correct":false},{"id":"d","label":"90+","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['nps','benchmark'], 'mft-2026-gotrm:bc01-08:qcm:13', true, 'NPS moyen secteur transport B2B France : 20-30. Au-dessus de 40, on est dans le top quartile. Un NPS > 50 est excellent, < 0 est mauvais.'),
  (v_formation, 'qcm', 'Le CES (Customer Effort Score) mesure :', '[{"id":"a","label":"La satisfaction globale","is_correct":false},{"id":"b","label":"L''effort que le client a dû fournir pour obtenir le service","is_correct":true},{"id":"c","label":"Le coût payé par le client","is_correct":false},{"id":"d","label":"Le nombre d''appels passés","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['ces','definition'], 'mft-2026-gotrm:bc01-08:qcm:14', true, 'CES = Customer Effort Score, mesure l''effort fourni par le client (1 à 7). Plus prédictif de la fidélisation que le NPS pour les interactions de service. Idéal pour mesurer une réclamation ou un parcours.'),
  (v_formation, 'qcm', 'Lors d''un retard livraison, la 1ère règle de communication est :', '[{"id":"a","label":"Attendre que le client appelle","is_correct":false},{"id":"b","label":"Anticiper en alertant dès que le retard est probable","is_correct":true},{"id":"c","label":"Minimiser le retard pour rassurer","is_correct":false},{"id":"d","label":"Justifier longuement la cause","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['retard','communication'], 'mft-2026-gotrm:bc01-08:qcm:15', true, 'Anticiper > constater. Alerter le client dès que le retard est probable lui permet d''adapter son organisation. Mieux vaut prévenir 1 h avant que de constater 1 h après.'),
  (v_formation, 'qcm', 'Lors d''un refus de livraison, la 1ère action du conducteur est :', '[{"id":"a","label":"Insister pour faire accepter la marchandise","is_correct":false},{"id":"b","label":"Documenter (photos, constat signé) puis appeler l''exploitation","is_correct":true},{"id":"c","label":"Repartir immédiatement avec la marchandise","is_correct":false},{"id":"d","label":"Décharger sans signature","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['refus','procedure'], 'mft-2026-gotrm:bc01-08:qcm:16', true, 'Documenter (photos, constat de refus signé) protège l''entreprise en cas de litige. Puis appeler l''exploitation pour décision (réexpédition, retour, garde). Ne jamais insister face à un refus formel.'),
  (v_formation, 'qcm', 'Les 4 étapes du désamorçage d''un conflit téléphonique sont :', '[{"id":"a","label":"Couper, parler fort, refuser, raccrocher","is_correct":false},{"id":"b","label":"Écouter, Reformuler, Reconnaître, Proposer","is_correct":true},{"id":"c","label":"Justifier, Excuser, Promettre, Espérer","is_correct":false},{"id":"d","label":"Ignorer, Rappeler, Esquiver, Conclure","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['conflit','desamorcage'], 'mft-2026-gotrm:bc01-08:qcm:17', true, 'Méthode universelle : Écouter (laisser exprimer), Reformuler (« si je comprends bien »), Reconnaître (« je comprends que cela soit pénible »), Proposer (action concrète, datée).'),
  (v_formation, 'qcm', 'Quelle phrase est à éviter absolument face à un client mécontent ?', '[{"id":"a","label":"« Je vais m''en occuper personnellement »","is_correct":false},{"id":"b","label":"« Calmez-vous »","is_correct":true},{"id":"c","label":"« Je vous rappelle dans 30 minutes avec une réponse »","is_correct":false},{"id":"d","label":"« Quelle solution serait acceptable pour vous ? »","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['conflit','phrases-eviter'], 'mft-2026-gotrm:bc01-08:qcm:18', true, '« Calmez-vous » a l''effet inverse de l''intention : c''est perçu comme condescendant et déclenche la colère. À éviter aussi : « C''est la procédure », « Ce n''est pas mon problème », « Vous auriez dû ».'),
  (v_formation, 'qcm', 'Un client toxique présente typiquement :', '[{"id":"a","label":"Un volume élevé","is_correct":false},{"id":"b","label":"Des retards de paiement chroniques + réclamations infondées + pression tarifaire constante","is_correct":true},{"id":"c","label":"Une fidélité de longue date","is_correct":false},{"id":"d","label":"Une marge nette élevée","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['client-toxique','signaux'], 'mft-2026-gotrm:bc01-08:qcm:19', true, 'Signaux : impayés chroniques, réclamations infondées répétées, pression tarifaire sans contrepartie, comportement disrespectueux, demandes hors contrat permanentes. Coût caché : 30-50 % de marge en moins.'),
  (v_formation, 'qcm', 'La règle des 3 chocs en gestion de la relation client signifie :', '[{"id":"a","label":"Faire 3 réductions par an","is_correct":false},{"id":"b","label":"Si 3 dérapages graves en 12 mois sans amélioration → désengagement progressif du client","is_correct":true},{"id":"c","label":"3 réunions clients par mois","is_correct":false},{"id":"d","label":"3 relances de paiement avant huissier","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['client-toxique','3-chocs'], 'mft-2026-gotrm:bc01-08:qcm:20', true, 'Règle managériale : 3 dérapages graves en 12 mois (impayés, agressivité, abus) sans amélioration après échanges directs justifient un plan de désengagement progressif (préavis, fin de contrat sur 6-12 mois).'),
  (v_formation, 'qcm', 'Le « paradoxe de la récupération » signifie que :', '[{"id":"a","label":"Un incident jamais résolu fidélise le client","is_correct":false},{"id":"b","label":"Un client mécontent bien traité après incident est plus fidèle que la moyenne","is_correct":true},{"id":"c","label":"Récupérer un client coûte plus cher que d''en perdre un","is_correct":false},{"id":"d","label":"Tous les clients reviennent","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['paradoxe','recuperation'], 'mft-2026-gotrm:bc01-08:qcm:21', true, 'Paradoxe documenté : un client mécontent dont la réclamation est traitée rapidement, sincèrement et avec une mesure correctrice concrète devient plus fidèle qu''un client n''ayant jamais eu de problème.'),
  (v_formation, 'qcm', 'Quel CRM est le plus adapté à une PME transport débutante avec budget limité ?', '[{"id":"a","label":"Salesforce Enterprise","is_correct":false},{"id":"b","label":"HubSpot CRM (version gratuite)","is_correct":true},{"id":"c","label":"Oracle Siebel","is_correct":false},{"id":"d","label":"SAP CRM","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['crm','pme'], 'mft-2026-gotrm:bc01-08:qcm:22', true, 'HubSpot CRM en version gratuite est très adapté aux PME : 1 M de contacts, fonctionnalités de base solides, intuitif. Salesforce, Oracle Siebel et SAP CRM sont des solutions enterprise plus coûteuses.'),
  (v_formation, 'qcm', 'Pour boucler une boucle de feedback client, on doit :', '[{"id":"a","label":"Ne jamais revenir vers le client","is_correct":false},{"id":"b","label":"Revenir vers le client sous 30 jours avec les actions menées suite à son retour","is_correct":true},{"id":"c","label":"Revenir uniquement si on demande quelque chose","is_correct":false},{"id":"d","label":"Attendre que le client redemande","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['feedback','boucle'], 'mft-2026-gotrm:bc01-08:qcm:23', true, 'Boucler la boucle = revenir vers le client dans les 30 jours avec un message du type « Vous nous avez signalé X, voici ce que nous avons fait pour y répondre ». Transforme un détracteur en promoteur potentiel.'),
  (v_formation, 'qcm', 'Un « moment de vérité » dans la relation client est :', '[{"id":"a","label":"Une réunion mensuelle","is_correct":false},{"id":"b","label":"Un instant où le client juge réellement la qualité de service","is_correct":true},{"id":"c","label":"La signature du contrat","is_correct":false},{"id":"d","label":"Le paiement de la facture","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['moment-verite'], 'mft-2026-gotrm:bc01-08:qcm:24', true, 'Moment de vérité (concept Karl Albrecht) = instant où le client forme son jugement (premier appel, comportement conducteur, communication retard, traitement réclamation). Une seule défaillance peut effacer 10 missions parfaites.'),
  (v_formation, 'qcm', 'Le délai de réponse standard à une réclamation client en transport est de :', '[{"id":"a","label":"1 heure ouvrée","is_correct":false},{"id":"b","label":"24 h ouvrées (4 h pour SLA exigeant)","is_correct":true},{"id":"c","label":"1 semaine","is_correct":false},{"id":"d","label":"1 mois","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['reclamation','delai'], 'mft-2026-gotrm:bc01-08:qcm:25', true, 'Standard du marché : sous 24 h ouvrées. Pour les contrats à SLA exigeant : sous 4 h ouvrées. Au-delà de 48 h, le client perçoit un manque d''engagement et le risque de churn augmente fortement.');


  -- =================================================================
  -- 4 QR
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qr', 'Calculez la LTV d''un client *Distribution Bretagne* (volume annuel 240 000 €, marge nette 8 %, durée moyenne client secteur transport 7 ans). Comparez à un coût d''acquisition de 12 % du CA annuel et concluez sur l''importance de la fidélisation.', NULL, 1, 'difficile', ARRAY['ltv','calcul','fidelisation'], 'mft-2026-gotrm:bc01-08:qr:1', true, 'Calcul LTV :

LTV = Volume annuel × Marge nette × Durée moyenne
LTV = 240 000 × 0,08 × 7 = 134 400 €

Calcul coût d''acquisition :

CAC = 240 000 × 12 % = 28 800 € (coût pour acquérir ce client)

Ratio LTV/CAC :

134 400 / 28 800 = 4,67 (un client rapporte 4,67 fois ce qu''il a coûté à acquérir)

Analyse :

a. Une perte de ce client à 3 ans au lieu de 7 = perte de 4 années de marge :
4 × 240 000 × 8 % = 76 800 € de marge perdue
Cela représente 2,67 fois le coût d''acquisition d''un nouveau client de remplacement.

b. Investir dans la fidélisation est rentable jusqu''à 76 800 € sur la durée du client (2,67 années de coût d''acquisition).

c. Levier majeur : prolonger d''un an la durée moyenne (7 → 8 ans) ajoute 19 200 € de marge / client, soit ~ 21 % de marge supplémentaire avec un investissement de fidélisation marginal.

Conclusion :

Pour ce client, des investissements de fidélisation jusqu''à 5 000 - 8 000 €/an (CRM, NPS annuel, bilans trimestriels, gestion proactive des incidents) sont totalement justifiés économiquement.

À l''échelle d''une flotte de 50 clients moyens similaires :
- LTV totale : 50 × 134 400 = 6,7 M€
- Investir 250-400 k€/an en fidélisation pour pérenniser cette base est cohérent.

Recommandations concrètes :

1. Bilan commercial trimestriel formel (1 h)
2. NPS annuel + actions correctrices ciblées
3. Réponse réclamation < 4 h ouvrées
4. Politique « zéro impayé » par communication proactive
5. Up-selling : nouveaux services (ATP, ADR, hayon) au fil des opportunités

ROI estimé : si la durée moyenne passe de 7 à 8 ans grâce à ces actions, gain marge / client = 19 200 € pour ~ 5 000 € de coût annuel = ROI x 3,8.'),
  (v_formation, 'qr', 'Un grand client industriel vous propose un contrat annuel à 1,8 M€ avec ce SLA strict :
- Ponctualité 99 % (créneau RDV ±15 min)
- Intégrité 99,9 %
- Pénalité 4 % de la facture mensuelle par % manquant (cumulable, sans plafond)
- Force majeure stricte uniquement (pas de panne véhicule, pas de trafic)
- Pas de bonus

Analysez les risques et formulez une contre-proposition argumentée.', NULL, 1, 'difficile', ARRAY['sla','negociation','risques'], 'mft-2026-gotrm:bc01-08:qr:2', true, 'Analyse des risques :

1. Ponctualité 99 % avec créneau RDV ±15 min :
- Très exigeant, surtout en distribution urbaine
- Aléas non maîtrisables : trafic, accidents, déchargements antérieurs
- 99 % = 1,5 livraisons sur 150 acceptées en retard / mois
- En pratique, atteindre 96-97 % est déjà excellent

2. Intégrité 99,9 % :
- 1 livraison sur 1 000 peut avoir une avarie sans pénalité
- Standard exigeant mais atteignable

3. Pénalité 4 % par % manquant, cumulable, sans plafond :
- Si la performance tombe à 95 % (au lieu de 99 %) = 4 × 4 % = 16 % de pénalité
- Sans plafond, la pénalité peut atteindre 30-40 % du CA
- Sur 1,8 M€ annuel = jusqu''à 720 k€ de pénalité possible
- Cela rendrait le contrat largement déficitaire

4. Force majeure stricte uniquement :
- Pas de protection contre les pannes véhicules ou les retards trafic
- Or, ces événements sont normaux en transport

5. Pas de bonus :
- Asymétrie totale : risque sans contrepartie

Coûts supplémentaires pour atteindre 99 % :
- Marge de planification renforcée (15-20 %)
- Doubles backups véhicules
- Système d''alerte télématique premium
- Coût additionnel estimé : 8-12 % du CA annuel

Conclusion : ce contrat est à hauts risques. Sans contre-proposition, refus recommandé.

Contre-proposition argumentée :

```
- Ponctualité : 96 % (créneau RDV ±60 min raisonnable)
- Intégrité : 99,5 % (atteignable)
- Conformité documentaire : 99 % (à ajouter)
- Pénalité progressive :
   - 1 pt en deçà : 2 % pénalité
   - 2-3 pts : 4 % pénalité
   - Au-delà : 6 % pénalité
- Plafond : 12 % du CA mensuel
- Exclusions :
   - Force majeure
   - Faute prouvée du client (RDV non respecté, marchandise non prête)
   - Retards trafic majeurs documentés (accidents, intempéries exceptionnelles)
- Bonus :
   - +1 % du CA mensuel si ponctualité > 98 % sur le mois
   - +0,5 % si intégrité 100 % sur le trimestre
- Revoyure annuelle des SLA
- Période d''adaptation : SLA appliqué après 3 mois de référence
```

Justification commerciale à présenter au client :

« Nous comprenons votre exigence de qualité et nous y souscrivons. Le SLA proposé ferme la porte à toute viabilité économique pour nous, ce qui n''est pas dans votre intérêt à long terme (nous ne pourrions pas maintenir le service). Notre contre-proposition garantit :

a. Une qualité de service réellement atteignable et donc tenue
b. Une équité dans le partage des risques et des gains
c. Un cadre de progression incitatif pour nous (bonus)
d. Une protection contre les facteurs hors de notre contrôle

Nous vous suggérons d''ailleurs une période d''observation de 3 mois où nous fournirons les statistiques mensuelles de performance, ce qui nous permettra ensuite d''ajuster collectivement les SLA si besoin. »

Position de repli si négociation difficile :
- Si le client insiste sur 99 % : possibilité d''accepter mais avec :
  - Tarif majoré de 12 %
  - Plafond pénalité 8 %
  - Bonus minimum 1,5 %
- Si refus total : ne pas signer. Un contrat à risque > 15 % du CA en pénalités est un piège.'),
  (v_formation, 'qr', 'Vous lancez votre première campagne NPS sur 120 clients. Résultats : 28 promoteurs, 64 passifs, 28 détracteurs. Calculez le NPS, analysez la situation par rapport au benchmark sectoriel et proposez un plan d''action 6 mois.', NULL, 1, 'difficile', ARRAY['nps','plan-action','calcul'], 'mft-2026-gotrm:bc01-08:qr:3', true, 'Calcul NPS :

Total répondants : 28 + 64 + 28 = 120 (taux de réponse non précisé)

% Promoteurs : 28 / 120 = 23,3 %
% Détracteurs : 28 / 120 = 23,3 %
% Passifs : 64 / 120 = 53,4 %

NPS = 23,3 - 23,3 = 0

Analyse :

a. Un NPS de 0 est faible :
- Benchmark transport B2B France : 20-30 (moyenne)
- Top quartile : > 40
- Excellent : > 50

b. Score de 0 = autant de détracteurs que de promoteurs :
- Risque de churn élevé chez les détracteurs (statistiquement, 25-30 % partent dans les 12 mois sans intervention)
- Manque d''ambassadeurs (les promoteurs amèneraient ~ 2 nouveaux clients chacun par bouche-à-oreille)

c. Une majorité de passifs (53 %) :
- Population à transformer en promoteurs
- Lever d''action : passer de 7-8 à 9-10 nécessite une expérience excellente, pas seulement satisfaisante

Plan d''action 6 mois :

Mois 1 — Analyse qualitative

a. Téléphoner aux 28 détracteurs (entretien 15 min)
b. Identifier les 3 motifs principaux de mécontentement
c. Croiser avec les données opérationnelles (réclamations, ponctualité, facturation)
d. Cartographier les segments les plus impactés

Mois 2 — Plan d''action ciblé

Sur la base des entretiens, plans d''action sur les top 3 problèmes (typiquement) :
1. Communication retards trop tardive → alertes télématique automatiques < 30 min
2. Délai réponse réclamation > 48 h → engagement formel < 4 h ouvrées
3. Erreurs facturation → audit processus + double check

Mois 3-4 — Mise en œuvre

a. Déploiement opérationnel des actions
b. Communication interne : formation des exploitants, sensibilisation conducteurs
c. Communication externe : message à tous les répondants leur indiquant le plan d''action

Mois 5 — Suivi intermédiaire

a. NPS partiel sur les 28 détracteurs initiaux
b. Évolution attendue : 50 % d''entre eux passent en passifs ou promoteurs
c. Réajustements si nécessaire

Mois 6 — Re-mesure complète

a. NPS sur les 120 clients (idéalement étendu à toute la base)
b. Analyse comparative avec score initial
c. Cible : NPS > 25 (top tertile sectoriel)
d. Communication des résultats en interne (motivation équipes) et auprès des promoteurs

Indicateurs de suivi :

| Indicateur | M0 | Cible M+6 |
|---|---|---|
| NPS | 0 | > 25 |
| Taux churn annuel | À mesurer | -30 % vs base |
| Délai réponse réclamation | > 24 h | < 4 h |
| Taux livraisons à l''heure | À mesurer | +3 pts |

Coût estimé du plan : 20-30 k€ (système alertes télématique, formation, audit facturation, NPS x 2).

ROI attendu :
- 28 détracteurs sauvés (taux churn évité 30 %) = 8,4 clients × LTV moyenne 80 k€ = 672 k€ de marge sauvée
- Promoteurs amenant nouveaux clients (effet bouche-à-oreille) : ~ 5-10 nouveaux clients/an x 80 k€ LTV = 400-800 k€

ROI total estimé : ~ 1 M€ pour 30 k€ d''investissement, soit x 33 sur 5 ans.

Communication aux détracteurs (3 jours après calcul) :

« Madame/Monsieur, vous nous avez confié une note de [X]. Nous l''entendons comme un signal fort. Voici ce que nous mettons en œuvre dans les 60 prochains jours pour transformer cette expérience :
- Action 1 (mesurable et datée)
- Action 2
- Action 3
Nous vous proposons un point d''avancement à 60 jours pour mesurer ensemble les progrès. Cordialement, [direction nominative]. »'),
  (v_formation, 'qr', 'Un de vos plus gros clients (CA 600 k€/an, 12 % de votre CA total) accumule depuis 8 mois : impayés répétés, 14 réclamations dont 9 jugées infondées par votre service qualité, agressivité verbale de son responsable logistique envers 3 de vos exploitants, demandes hors contrat permanentes. Que faites-vous ?', NULL, 1, 'difficile', ARRAY['client-toxique','desengagement','plan'], 'mft-2026-gotrm:bc01-08:qr:4', true, 'Analyse de la situation :

1. Évaluation factuelle :

a. Impayés : à chiffrer précisément
- Montant total impayé > 30 jours : € ?
- Coût financier (intérêts, recouvrement) : ~ 5-8 % du montant
- Risque de défaillance client : à évaluer

b. Réclamations infondées :
- Temps perdu : ~ 30 min × 9 = 4,5 h × coût horaire 70 € = 315 €
- Sur 8 mois, surcharge de ~ 50 h pour cette gestion = ~ 3 500 €

c. Agressivité verbale :
- Risque psycho-social pour 3 exploitants
- Risque RH (démotivation, départ)
- Coût caché : difficile à chiffrer mais réel

d. Demandes hors contrat :
- Charge non facturable
- Glissement contractuel

2. Diagnostic global :

Ce client présente les 4 signaux majeurs de toxicité : impayés + réclamations infondées + comportement disrespectueux + demandes hors contrat. Cumul depuis 8 mois sans inflexion.

Évaluation rentabilité réelle (vs facial) :
- CA facial : 600 000 €
- Marge nette à 7 % : 42 000 €
- Coûts cachés annuels :
  - Surcharge administrative (réclamations infondées) : ~ 5 000 €
  - Coût impayés (BFR + recouvrement) : ~ 8 000 €
  - Coût RH et risque social : ~ 6 000 €
  - Demandes hors contrat absorbées : ~ 12 000 €
- Total coûts cachés : 31 000 €
- Marge nette réelle : 42 000 - 31 000 = 11 000 € (1,8 % de marge réelle vs 7 % faciale)

Conclusion : ce client génère 1,8 % de marge nette réelle pour 12 % du CA et 100 % du stress de l''équipe.

3. Plan d''action recommandé : la règle des 3 chocs activée

Étape 1 — Réunion direct avec le client (Sem 1)

Demander un rendez-vous formel avec la direction du client (pas seulement le responsable logistique). Présenter les faits factuels :
- Tableau des impayés et anciennetés
- Liste des 9 réclamations infondées avec preuves
- Témoignages écrits des 3 exploitants
- Liste des demandes hors contrat absorbées

Position : « Notre relation a dérivé. Voici les faits. Nous souhaitons remettre la collaboration sur des bases saines. Voici ce que nous attendons. »

Demandes :
- Apurement des impayés sous 30 jours
- Désignation d''un nouveau référent logistique
- Engagement écrit de respect des délais et conditions contractuelles
- Période d''observation 3 mois

Étape 2 — Si engagement et amélioration (Sem 13)

a. Bilan d''observation à 3 mois
b. Si amélioration significative (impayés résolus, comportement OK, réclamations sous 5 % du volume) : redémarrage relation propre, tarif révisé à la hausse pour compenser la phase difficile
c. Mise en place SLA strict avec pénalités symétriques

Étape 3 — Si pas d''amélioration (Sem 13)

Décision de désengagement progressif.

Lettre formelle :
« Madame/Monsieur, malgré notre échange du [date] et la période d''observation de 3 mois, nous constatons que les conditions de notre collaboration n''ont pas évolué. Notre engagement à votre égard, à la qualité que nous voulons offrir, nous oblige à mettre fin à notre contrat dans les conditions suivantes :
- Préavis de 6 mois conformément à notre contrat
- Maintien du service qualité standard pendant cette période
- Soutien à votre transition vers un nouveau partenaire »

Étape 4 — Désengagement opérationnel (M+3 à M+9)

a. Maintien strict du service contractuel (pas de relâchement)
b. Apurement final des comptes
c. Documentation complète (au cas où litige)
d. Relations professionnelles préservées : la situation peut évoluer, ne pas brûler les ponts

4. Mesures parallèles à activer immédiatement

a. Service comptable :
- Mise en demeure formelle pour les impayés
- Limitation de l''encours à 60 j max
- Si nécessaire, recours à un cabinet de recouvrement amiable

b. Service exploitation :
- Briefing des 3 exploitants : protection nominative, pas seuls face au client agressif
- Toute interaction documentée
- Escalade systématique à la direction

c. Service commercial :
- Plan de remplacement du CA : prospection ciblée pour combler les 12 % progressivement
- Délai 6-12 mois pour ne pas mettre l''entreprise en risque

d. Direction :
- Information confidentielle aux salariés concernés sans dramatiser
- Soutien moral aux exploitants
- Ajustement du planning de paiement et du BFR

5. Risques à anticiper

- Représailles client : avis négatifs sur réseaux pros, démarchage de vos autres clients
- Communication maîtrisée : ne pas se justifier publiquement, lettres recommandées formelles uniquement
- Possible transition juridique : prévoir conseil d''avocat dès le début

Conclusion stratégique : un client toxique de 600 k€ qui en réalité ne rapporte que 11 k€ de marge nette n''est pas un client à conserver. Le perdre libère l''équipe et permet de reconstruire avec des clients sains. C''est l''une des décisions les plus importantes en gestion de la relation client.');


  -- =================================================================
  -- QUIZZES
  -- =================================================================
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — Cycle relation client', '5 phases, rôles, moments de vérité, LTV.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-08:qcm:1','mft-2026-gotrm:bc01-08:qcm:2','mft-2026-gotrm:bc01-08:qcm:3','mft-2026-gotrm:bc01-08:qcm:24');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — Qualité et SLA', 'Satisfaction, SLA SMART, pénalités, ISO 9001, OEA.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-08:qcm:4','mft-2026-gotrm:bc01-08:qcm:5','mft-2026-gotrm:bc01-08:qcm:6','mft-2026-gotrm:bc01-08:qcm:7','mft-2026-gotrm:bc01-08:qcm:8','mft-2026-gotrm:bc01-08:qcm:9','mft-2026-gotrm:bc01-08:qcm:10');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — CRM, NPS et feedback', 'CRM, NPS, CSAT, CES, boucle feedback.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-08:qcm:11','mft-2026-gotrm:bc01-08:qcm:12','mft-2026-gotrm:bc01-08:qcm:13','mft-2026-gotrm:bc01-08:qcm:14','mft-2026-gotrm:bc01-08:qcm:22','mft-2026-gotrm:bc01-08:qcm:23');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — Situations difficiles', 'Retard, refus, conflits, clients toxiques, paradoxe récupération.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-08:qcm:15','mft-2026-gotrm:bc01-08:qcm:16','mft-2026-gotrm:bc01-08:qcm:17','mft-2026-gotrm:bc01-08:qcm:18','mft-2026-gotrm:bc01-08:qcm:19','mft-2026-gotrm:bc01-08:qcm:20','mft-2026-gotrm:bc01-08:qcm:21','mft-2026-gotrm:bc01-08:qcm:25');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Examen blanc — BC01-08 Relation client', '12 QCM en 25 min, seuil 50 %.', 'examen_blanc', 1500, 50)
  RETURNING id INTO v_quiz_eb;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-08:qcm:1','mft-2026-gotrm:bc01-08:qcm:2','mft-2026-gotrm:bc01-08:qcm:5','mft-2026-gotrm:bc01-08:qcm:7','mft-2026-gotrm:bc01-08:qcm:8','mft-2026-gotrm:bc01-08:qcm:11','mft-2026-gotrm:bc01-08:qcm:12','mft-2026-gotrm:bc01-08:qcm:15','mft-2026-gotrm:bc01-08:qcm:17','mft-2026-gotrm:bc01-08:qcm:19','mft-2026-gotrm:bc01-08:qcm:20','mft-2026-gotrm:bc01-08:qcm:25');

  RAISE NOTICE '✅ GOTRM BC01-08 v2 chargé : 4 leçons, 25 QCM, 4 QR, 5 quizzes (4 entraînement + 1 examen blanc).';
END
$bc01_08$;
