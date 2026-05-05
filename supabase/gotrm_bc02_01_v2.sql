-- =====================================================================
-- GOTRM (RNCP 40990) — BC02-01 : Appels d'offres et sélection sous-traitants
-- Cadre juridique sous-traitance, AO, évaluation, contractualisation.
-- =====================================================================

DO $bc02_01$
DECLARE
  v_formation uuid; v_bloc int; v_module uuid;
  v_lesson_1 uuid; v_lesson_2 uuid; v_lesson_3 uuid; v_lesson_4 uuid;
  v_quiz_1 uuid; v_quiz_2 uuid; v_quiz_3 uuid; v_quiz_4 uuid; v_quiz_eb uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc.'; END IF;

  DELETE FROM public.modules WHERE slug = 'gotrm-bc02-01-appels-offres-soustraitance';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'BC02-01 — Élaborer un appel d''offres et sélectionner les sous-traitants',
    'gotrm-bc02-01-appels-offres-soustraitance', v_bloc,
    'Cadre juridique de la sous-traitance transport, construction d''un appel d''offres, évaluation et sélection des sous-traitants, contractualisation.',
    'avance', 180, 110
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 110, true) ON CONFLICT DO NOTHING;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc02-01:%';

  -- =================================================================
  -- LEÇON 1 — Cadre juridique sous-traitance
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Cadre juridique de la sous-traitance transport',
    'gotrm-bc02-01-01-cadre-juridique', 1, 45,
$lesson1$
# Cadre juridique de la sous-traitance transport

La sous-traitance représente **40 à 60 %** du chiffre d'affaires des commissionnaires de transport en France. Maîtriser son cadre juridique est essentiel pour éviter les pièges (cascade abusive, défaillance du sous-traitant, responsabilité solidaire).

> 🎯 **Objectifs de la leçon**
>
> - Distinguer **commissionnaire** et **transporteur public**.
> - Comprendre la **loi du 31 décembre 1975** (sous-traitance).
> - Identifier les **risques** (cascade, complicité travail dissimulé).
> - Maîtriser les **obligations** de l'opérateur principal.

---

## 1. Acteurs de la sous-traitance

### 1.1 Le commissionnaire de transport

| Caractéristique | Détail |
|---|---|
| Rôle | Organise un transport pour le compte d'un client |
| Choix moyens | Libre (route, fer, mer, air, multimodal) |
| Responsabilité | De ses faits + faits de ses substitués |
| Statut | Profession réglementée (LCB, capacité GOTRM) |

### 1.2 Le transporteur public routier (TPR)

| Caractéristique | Détail |
|---|---|
| Rôle | Exécute un transport (effectue le déplacement) |
| Statut | Inscription au registre des TPR + licence (LTI/LTM) |
| Responsabilité | Du transport effectué |

### 1.3 Le donneur d'ordre principal

L'entreprise (commissionnaire ou TPR) qui sous-traite tout ou partie d'une mission à un autre acteur.

### 1.4 Le sous-traitant

L'entreprise qui exécute la mission pour le compte du donneur d'ordre.

---

## 2. La loi du 31 décembre 1975

### 2.1 Principe

La loi 75-1334 du 31 décembre 1975 encadre la sous-traitance en France. Pour le transport, elle est complétée par les textes spécifiques (Code des transports, contrat-type sous-traitance).

### 2.2 Les obligations majeures

| Obligation | Détail |
|---|---|
| **Information du client final** | Le donneur d'ordre informe son client de la sous-traitance |
| **Acceptation du sous-traitant** | Le client peut refuser un sous-traitant |
| **Paiement direct** | En cas de défaillance du donneur d'ordre, le client peut payer directement le sous-traitant |
| **Garantie financière** | Le donneur d'ordre apporte une garantie au sous-traitant |

### 2.3 Le contrat-type sous-traitance

Le **contrat-type sous-traitance** transport (décret 2003-1295 du 26 décembre 2003) définit les obligations entre commissionnaire et sous-traitant en l'absence d'accord écrit spécifique.

---

## 3. Les obligations de vérification

### 3.1 Les vérifications obligatoires (article L. 8222-1 du Code du travail)

Tout donneur d'ordre doit vérifier **AVANT** de sous-traiter, et **TOUS LES 6 MOIS** ensuite, que son sous-traitant :

| # | Vérification | Document |
|---|---|---|
| 1 | Régulièrement immatriculé | Extrait KBIS < 3 mois |
| 2 | À jour de ses cotisations sociales | Attestation URSSAF |
| 3 | À jour de ses cotisations fiscales | Attestation fiscale |
| 4 | Déclare bien ses salariés | Liste DPAE / DSN |

### 3.2 Le risque : complicité de travail dissimulé

Si le sous-traitant emploie des travailleurs non déclarés et que le donneur d'ordre ne pouvait l'ignorer (vigilance insuffisante), il peut être poursuivi pour **complicité de travail dissimulé** :
- Amende pénale jusqu'à **75 000 €**
- Solidarité financière (paiement des salaires et cotisations dus)
- Suspension de la licence

### 3.3 Vérifications spécifiques transport

| # | Vérification | Document |
|---|---|---|
| 1 | Inscription au registre des transporteurs | Capacité financière |
| 2 | Licence transport en cours de validité | LTI ou LTM |
| 3 | Honorabilité professionnelle | Bulletin n°2 dirigeants |
| 4 | Assurance responsabilité civile | Attestation < 12 mois |
| 5 | Capacité professionnelle | Certificat |

---

## 4. Les limites à la sous-traitance en cascade

### 4.1 Principe d'interdiction

L'**article L. 3221-3 du Code des transports** limite la sous-traitance en cascade : un opérateur ne peut sous-traiter sans en informer son donneur d'ordre principal.

### 4.2 Sous-traitance de second rang

Le sous-traitant peut **lui-même** sous-traiter, mais :
- En **informant explicitement** le donneur d'ordre principal
- Dans le respect des règles de capacité et d'honorabilité
- Sans cumul de marges abusives

### 4.3 Risque de cascade abusive

Une cascade non maîtrisée (sous-traitance de sous-traitance de sous-traitance) crée :
- Dilution de la responsabilité
- Risque de défaillance d'un maillon
- Impossibilité de tracer la marchandise
- Risque de complicité de travail dissimulé

> ⚠️ **Sanction**
>
> Une cascade non déclarée peut entraîner annulation des contrats, amendes et perte d'honorabilité (suspension de la licence).

---

## 5. La responsabilité du donneur d'ordre

### 5.1 Responsabilité du fait du sous-traitant

Le donneur d'ordre (commissionnaire ou TPR) est **responsable** vis-à-vis du client final :
- Du transport effectué par le sous-traitant
- Des fautes éventuelles du sous-traitant
- De la sécurité (matières dangereuses, chaîne du froid)
- De la qualité de service (ponctualité, intégrité)

### 5.2 Recours contre le sous-traitant

Une fois indemnisé le client, le donneur d'ordre peut se retourner contre le sous-traitant pour récupérer les sommes versées :
- Action en garantie contre le sous-traitant fautif
- Subrogation à l'assurance du client

### 5.3 Limites contractuelles

Les contrats avec les sous-traitants peuvent prévoir :
- Indemnités libératoires
- Plafonds de responsabilité
- Exclusions
- Obligations d'assurance spécifique

---

## 6. La rémunération du sous-traitant (« prix de référence »)

### 6.1 Le principe

Article **L. 3222-3 du Code des transports** : le donneur d'ordre doit payer un **prix qui couvre les coûts** du sous-traitant. Pratique du « **prix abusivement bas** » interdite.

### 6.2 Définition du prix abusivement bas

Un prix est qualifié d'abusivement bas s'il :
- Ne couvre pas les coûts d'exploitation (carburant, conducteur, amortissement, structure)
- Met le sous-traitant en risque économique structurel
- Est manifestement inférieur aux prix de marché

### 6.3 Sanctions

| Infraction | Sanction |
|---|---|
| Pratique de prix abusivement bas | Amende administrative jusqu'à 90 000 € |
| Négligence dans les vérifications | Solidarité financière complete |
| Complicité de travail dissimulé | Pénal + financier |

> 💡 **Bonne pratique**
>
> Avoir un **barème interne minimum** par type de mission/véhicule (€/km, €/h, forfaits), ne pas y déroger sans validation hiérarchique. Tracer toutes les négociations.

---

## 7. Cas pratique : décliner ou accepter un sous-traitant

**Contexte** : Un nouveau sous-traitant *Trans-Aquila SARL* propose un tarif 18 % en dessous du marché pour une ligne régulière hebdomadaire Lyon-Strasbourg. Devez-vous accepter ?

### Vérifications préalables

| Élément | À vérifier |
|---|---|
| KBIS récent | < 3 mois ? |
| URSSAF | À jour ? |
| Fiscalité | À jour ? |
| DPAE | Salariés déclarés ? |
| Licence transport | En cours de validité ? |
| Honorabilité | Bulletins B2 dirigeants ? |
| Assurance RC | Attestation valide ? |
| Antécédents | Référence vérifiable ? |

### Analyse du tarif

Si tous les documents sont valides MAIS que le tarif est 18 % sous le marché :

**Question 1** : comment couvre-t-il ses coûts ?
- Optimisation extrême (taux remplissage, retour à vide minimisé) ?
- Sous-rémunération de ses conducteurs ?
- Travail dissimulé ?
- Stratégie d'acquisition (perte initiale acceptée) ?

**Question 2** : quel risque pour vous ?
- Si défaillance économique → arrêt de la ligne sans préavis
- Si infraction sociale → complicité possible
- Si baisse qualité → impacts client final

### Recommandation

**Action 1** : Demander le **détail des coûts** (carburant + conducteur + amortissement minimum) pour vérifier la viabilité.

**Action 2** : Vérifier les **rémunérations conducteurs** (bulletins de paie type, conventions collectives respectées).

**Action 3** : **Audit terrain** : visite des locaux, état du parc, ambiance.

**Action 4** : Prévoir une **clause de sortie rapide** (préavis 30 j) en cas de défaillance.

**Action 5** : Si OK, **engagement progressif** : 1-2 lignes en pilote, montée en puissance après 3 mois.

Si doute persistant : refuser. Mieux vaut perdre une opportunité que gagner un risque pénal.

---

> ✅ **À retenir**
>
> - Sous-traitance encadrée par **loi 1975**, **L. 8222-1** (vérifications), **L. 3221-3** (cascade), **L. 3222-3** (prix).
> - Vérifications **avant** + **tous les 6 mois** : KBIS, URSSAF, fiscalité, DPAE, licence, honorabilité, assurance.
> - **Prix abusivement bas** interdit : amende jusqu'à 90 k€.
> - **Complicité travail dissimulé** : amende 75 k€ + solidarité.
> - Le donneur d'ordre est **responsable** vis-à-vis du client final des fautes du sous-traitant.
$lesson1$,
'Loi 31 déc 1975 + L. 8222-1 (vérifications), L. 3221-3 (cascade), L. 3222-3 (prix abusivement bas), commissionnaire vs TPR, responsabilité solidaire, vérifications semestrielles.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Construire un appel d'offres
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Construire un appel d''offres sous-traitance',
    'gotrm-bc02-01-02-construire-ao', 2, 45,
$lesson2$
# Construire un appel d'offres sous-traitance

Un appel d'offres bien construit attire les meilleurs sous-traitants, permet une comparaison juste et structure la relation contractuelle. Une AO mal cadrée donne des offres incomparables et un partenariat fragile.

> 🎯 **Objectifs de la leçon**
>
> - Identifier les **étapes** d'un appel d'offres.
> - Construire un **cahier des charges** complet.
> - Définir les **critères de notation**.
> - Anticiper les **questions** des candidats.

---

## 1. Les 6 étapes d'un appel d'offres

### Étape 1 — Définition du besoin (interne)

| Action | Détail |
|---|---|
| Identifier le périmètre | Lignes, volumes, fréquences |
| Quantifier précisément | km/an, missions/mois, t/an |
| Définir les exigences | Délais, créneaux, équipements |
| Estimer le budget | Pour orienter sans dévoiler |

### Étape 2 — Rédaction du cahier des charges

| Section | Contenu |
|---|---|
| Identification donneur d'ordre | Raison sociale, contacts |
| Périmètre du marché | Quantitatif, géographique |
| Exigences techniques | Véhicules, équipements |
| Exigences qualité | SLA, KPI |
| Cadre contractuel | Durée, prix, indexation, pénalités |

### Étape 3 — Liste des candidats à consulter

Trois sources :
- Sous-traitants existants performants (à élargir)
- Recommandations professionnelles (FNTR, OTRE, TLF)
- Recherches sectorielles (annuaires, salons)

### Étape 4 — Diffusion et réponse

| Action | Délai |
|---|---|
| Envoi cahier des charges | J-30 à J-45 avant remise |
| Période de questions | J-30 à J-15 |
| Réponses aux questions | J-15 à J-7 (en commun à tous) |
| Remise des offres | J0 (date limite stricte) |
| Analyse | J+1 à J+15 |
| Décision et notification | J+30 |

### Étape 5 — Évaluation

| Critère | Pondération typique |
|---|---|
| Prix | 30-40 % |
| Qualité de service / SLA | 25-30 % |
| Capacité technique | 15-20 % |
| Solidité financière | 10-15 % |
| Démarche RSE | 5-10 % |

### Étape 6 — Notification et démarrage

| Action | Détail |
|---|---|
| Information lauréats | Lettre formelle, négociations finales |
| Information non-retenus | Lettre courtoise + retours qualitatifs |
| Signature contrat | Avenant ou contrat dédié |
| Période de pilote | 3-6 mois pour ajustements |

---

## 2. Le cahier des charges détaillé

### 2.1 Section 1 — Présentation

- Identification donneur d'ordre + activité
- Présentation du marché et sa stratégie
- Calendrier prévisionnel

### 2.2 Section 2 — Périmètre quantitatif

- Volume mensuel par ligne (en km, missions, t)
- Saisonnalité (graphiques mensuels)
- Évolution prévue sur 3-5 ans

### 2.3 Section 3 — Exigences techniques

- Type de véhicule requis (porteur, semi, frigo, ADR...)
- PTAC, longueur utile, hauteur sous toit
- Équipements obligatoires (hayon, rideau coulissant, palettiseur)
- Qualifications conducteurs (CQC, ADR base/citerne, FCO < 5 ans)
- Système télématique compatible (en cas d'intégration)

### 2.4 Section 4 — Exigences opérationnelles

- Plages horaires de chargement
- Délais de livraison contractuels
- Procédure de réservation, communication
- Gestion des incidents (escalade, communication)
- Reporting attendu (fréquence, format)

### 2.5 Section 5 — Exigences qualité

- SLA chiffrés : ponctualité, intégrité, conformité doc
- KPI à reporter mensuellement
- Pénalités et bonus définis
- ISO 9001, OEA, certifications spécifiques

### 2.6 Section 6 — Exigences contractuelles

- Durée du marché (1 an, 3 ans, etc.)
- Prix unitaire ou forfait par mission
- Indexation gazole (RPC obligatoire L. 3222-1)
- Conditions de paiement
- Plafonds d'indemnisation
- Conditions de résiliation

### 2.7 Section 7 — Pièces à fournir

Pièces administratives :
- KBIS < 3 mois
- Attestation URSSAF + fiscalité
- Liste DPAE des conducteurs concernés
- Licence transport en cours
- Bulletins n°2 dirigeants
- Attestation RC professionnelle

Pièces techniques :
- Composition du parc affecté
- CV des conducteurs principaux
- Composition équipe d'exploitation dédiée

Pièces financières :
- Bilans des 3 derniers exercices
- Compte de résultat synthétique
- Lettre de référence bancaire

Pièces qualité :
- Certifications (ISO 9001, OEA, GDP, etc.)
- Statistiques de qualité 12 derniers mois
- Plan de prévention sécurité

### 2.8 Section 8 — Critères et notation

Le cahier des charges précise **a priori** :
- La grille de notation
- Le poids de chaque critère
- Les seuils éliminatoires
- Le calendrier de la décision

---

## 3. La grille de notation

### 3.1 Modèle type

| Critère | Poids | Sous-critères |
|---|---|---|
| Prix | 35 % | Prix de base (25 %), Conditions financières (10 %) |
| Qualité de service | 30 % | SLA proposés (15 %), Statistiques 12 mois (10 %), Capacités gestion incident (5 %) |
| Capacité technique | 15 % | Parc dédié (8 %), Conducteurs qualifiés (4 %), Outils télématique (3 %) |
| Solidité financière | 10 % | Bilans (6 %), Trésorerie / fonds propres (4 %) |
| RSE et certifications | 5 % | ISO 9001 (2 %), Démarche carbone (2 %), Politique sociale (1 %) |
| Démarche commerciale | 5 % | Présentation orale (3 %), Adéquation projet (2 %) |
| Total | 100 % | |

### 3.2 Bonnes pratiques

| Pratique | Pourquoi |
|---|---|
| Pondération équilibrée (pas tout sur le prix) | Évite le « moins-disant » destructeur |
| Seuils éliminatoires précis | Filtrage rapide |
| Notation transparente | Traçabilité, équité |
| Visite terrain pour les 3 finalistes | Validation qualitative |

---

## 4. Cas pratique : appel d'offres lignes régulières

**Contexte** : Vous gérez le département affrètement de *MetalParc Distribution*. Besoin : 4 lignes hebdomadaires Lyon-Strasbourg pour 1 an renouvelable. Volume : 16 missions/sem, 40 t. Budget enveloppe : 1 200 000 €/an.

### Construction du dossier

#### Cahier des charges (15 pages)

1. **Présentation** : MetalParc, distributeur grossiste métallurgie, 28 M€ CA.

2. **Périmètre** : Ligne Lyon-Strasbourg, 4 départs/semaine, semi-remorque 40 t, accessoires métalliques (sangles, cales).

3. **Exigences techniques** :
   - Semi-remorque rideaux coulissants 13,6 m
   - PTRA 40 t
   - Hayon arrière (selon livraisons)
   - Conducteur CQC FCO < 5 ans
   - Carte conducteur tachygraphique

4. **Exigences opérationnelles** :
   - Chargement Lyon : Lundi, Mercredi, Jeudi, Vendredi entre 6 h et 14 h
   - Livraison Strasbourg : J+1 entre 6 h et 12 h
   - Communication ETA temps réel via app dédiée
   - Reporting ponctualité hebdomadaire

5. **Exigences qualité** :
   - Ponctualité ≥ 96 % (sur fenêtre RDV ±60 min)
   - Intégrité : 99,5 %
   - Conformité doc : 99 %
   - Pénalités progressives (2 % à 6 %, plafond 10 %)
   - Bonus ponctualité > 99 % (1 %)

6. **Cadre contractuel** :
   - 12 mois renouvelable tacitement
   - Préavis 6 mois pour résiliation
   - Indexation CNR mensuelle (part gazole 30 %)
   - Paiement 30 j fin de mois

#### Critères et pondération

| Critère | Poids |
|---|---|
| Prix | 35 % |
| Qualité (SLA + stats 12 mois) | 30 % |
| Capacité technique (parc + conducteurs) | 15 % |
| Solidité financière | 10 % |
| RSE | 5 % |
| Démarche commerciale | 5 % |

#### Liste de candidats

5 sous-traitants consultés (3 existants + 2 nouveaux) parmi un panel sélectionné :
- Trans-Loire (existant, satisfaisant)
- Trans-Strasbourg (existant, satisfaisant)
- Express Logistique (nouveau)
- Astre Transport (nouveau, label coopératif)
- Trans-Métal (nouveau)

#### Calendrier

- J-30 : envoi cahier des charges
- J-15 à J-7 : questions / réponses
- J0 : remise offres
- J+15 : analyse + 3 finalistes
- J+25 : visite terrain finalistes
- J+30 : décision finale et notification

### Évaluation des offres reçues

| Sous-traitant | Prix annuel | Qualité | Capacité | Finance | RSE | Démarche | Total |
|---|---|---|---|---|---|---|---|
| Trans-Loire | 1 180 000 € | 27/30 | 14/15 | 8/10 | 3/5 | 4/5 | **89/100** |
| Trans-Strasbourg | 1 220 000 € | 28/30 | 14/15 | 9/10 | 4/5 | 4/5 | **88/100** |
| Express Logistique | 1 050 000 € | 22/30 | 12/15 | 6/10 | 2/5 | 3/5 | **74/100** |
| Astre Transport | 1 195 000 € | 26/30 | 15/15 | 9/10 | 5/5 | 5/5 | **91/100** |
| Trans-Métal | 1 350 000 € | 25/30 | 13/15 | 7/10 | 3/5 | 3/5 | **77/100** |

### Décision

**Lauréat : Astre Transport** (91/100), avec un excellent score qualité, capacité, finances et RSE. Prix légèrement supérieur à Trans-Loire mais largement compensé par la qualité.

Ne pas retenir Express Logistique malgré le prix le plus bas (74/100) : risque qualité et financier important.

### Notification

- Astre : lettre + RDV final pour signature
- Autres : lettre courtoise + invitation à participer aux prochaines AO
- Trans-Loire et Trans-Strasbourg (existants) : valoriser leur engagement pour les autres lignes

---

> ✅ **À retenir**
>
> - **6 étapes** : besoin → cahier des charges → liste candidats → diffusion → évaluation → notification.
> - **Cahier des charges** : 8 sections (présentation, périmètre, technique, opérationnel, qualité, contractuel, pièces, critères).
> - **Pondération équilibrée** : prix 35 %, qualité 30 %, capacité 15 %, finance 10 %, RSE 5 %, démarche 5 %.
> - **Délai standard AO** : 30 jours minimum entre envoi et remise des offres.
> - **Visite terrain** des 3 finalistes recommandée.
$lesson2$,
'6 étapes appel d''offres, cahier des charges en 8 sections, pondération équilibrée des critères, calendrier 30 jours, grille de notation, visite terrain finalistes.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Évaluer et sélectionner
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Évaluer et sélectionner les sous-traitants',
    'gotrm-bc02-01-03-evaluation-selection', 3, 45,
$lesson3$
# Évaluer et sélectionner les sous-traitants

Au-delà des critères formels, la **sélection** d'un sous-traitant est un acte de jugement. Trop de critères tue le critère, mais pas assez expose à des choix biaisés.

> 🎯 **Objectifs de la leçon**
>
> - Maîtriser les **5 axes d'évaluation** d'un sous-traitant.
> - Mener une **visite terrain** efficace.
> - Détecter les **signaux faibles**.
> - Construire un **panel** de sous-traitants équilibré.

---

## 1. Les 5 axes d'évaluation

### 1.1 Axe FINANCIER

| Indicateur | Cible |
|---|---|
| Chiffre d'affaires (3 dernières années) | Croissance ou stabilité |
| Marge nette | > 3 % |
| Fonds propres / total bilan | > 25 % |
| Trésorerie nette | Positive |
| Dette / EBE | < 4 |
| Délai paiement client (DSO) | < 60 j |

> ⚠️ **Signaux d'alerte**
>
> - Compte de résultat en perte 2 années consécutives
> - Inscription d'hypothèques ou nantissements
> - Procédure collective récente
> - Refus de fournir bilans détaillés

### 1.2 Axe OPÉRATIONNEL

| Indicateur | Évaluation |
|---|---|
| Composition du parc | Âge moyen, états, polyvalence |
| Effectif conducteurs | Nombre, ancienneté moyenne |
| Outils télématique / TMS | Niveau d'équipement |
| Statistiques qualité 12 mois | Ponctualité, incidents, litiges |
| Procédures internes | Documentées, à jour |
| Capacité de pic | Marges, sous-traitance, partenariats |

### 1.3 Axe HUMAIN

| Indicateur | Évaluation |
|---|---|
| Turnover annuel | < 15 % idéal |
| Politique de formation | Plan annuel structuré |
| Conditions de rémunération | Conformité conventions |
| Climat social | Absentéisme, conflits récents |
| Engagement direction | Stabilité management |

### 1.4 Axe QUALITÉ ET RSE

| Indicateur | Cible |
|---|---|
| ISO 9001 | Possession ou démarche |
| Politique sécurité (TF, TG accidents) | Comparable au secteur |
| Certifications spécifiques (ADR, ATP, GDP) | Selon besoins |
| Démarche carbone | Engagement chiffré |
| Bilan formation | Heures > 14 h/salarié/an |

### 1.5 Axe COMPATIBILITÉ

| Indicateur | Évaluation |
|---|---|
| Compatibilité culturelle | Valeurs partagées |
| Référence sectorielle | Clients similaires au vôtre |
| Communication | Réactivité, transparence |
| Capacité d'évolution | Roadmap qui correspond |
| Engagement partenarial | Volonté long terme |

---

## 2. La visite terrain

### 2.1 Pourquoi faire la visite ?

Les dossiers papiers ne montrent pas tout. La visite terrain révèle :
- L'état réel du parc
- L'ambiance et le climat
- Les outils utilisés au quotidien
- La qualité de l'organisation
- La sincérité des engagements

### 2.2 Programme type (1/2 journée)

| Étape | Durée | Action |
|---|---|---|
| 1. Accueil et présentation entreprise | 30 min | Direction + responsables clés |
| 2. Visite locaux (bureaux, exploitation) | 30 min | Observer organisation, outils |
| 3. Visite parc | 30 min | Voir véhicules, état, équipements |
| 4. Démonstration TMS / télématique | 30 min | Voir l'outil en action |
| 5. Échanges avec exploitants | 30 min | Comprendre le quotidien |
| 6. Échanges avec conducteurs | 30 min | Climat social, écoute |
| 7. Bilan et questions | 30 min | Synthèse, prochaines étapes |

### 2.3 Points d'attention

| Point | À observer |
|---|---|
| État des locaux | Propreté, équipement, modernité |
| Parc visible | Nettoyé, identifié, lisible |
| Communication interne | Tableau, écrans, ambiance |
| Réactivité de l'équipe | Aux questions, aux imprévus |
| Cohérence du discours | Direction et opérationnels alignés ? |
| Documentation | Procédures accessibles, à jour |
| Sécurité | Casques, EPI, vigilance |

---

## 3. Détecter les signaux faibles

### 3.1 Signaux de qualité douteuse

- Parc visiblement vieillissant (> 8 ans en moyenne)
- Conducteurs peu engagés, fatigués
- Manque de procédures écrites
- Téléphones au volant des conducteurs
- Ambiance tendue, communication descendante uniquement

### 3.2 Signaux de fragilité financière

- Locaux mal entretenus
- Investissements minimum
- Salariés payés au lance-pierre
- Trésorerie tendue (paiements en retard côté fournisseurs)
- Discours sur les pertes récurrentes

### 3.3 Signaux de risque réglementaire

- Tachygraphes mal téléchargés
- Sous-traitance occulte évoquée
- Pratiques tarifaires douteuses
- Difficultés à fournir attestations URSSAF récentes
- Conducteurs sans CQC valide

### 3.4 Le test des questions ouvertes

| Question | Bon signal | Mauvais signal |
|---|---|---|
| « Quel est votre principal challenge ? » | Réponse précise + plan | Évite, généralités |
| « Comment gérez-vous les retards conducteurs ? » | Procédure structurée | « On gère au cas par cas » |
| « Combien d'incidents l'année dernière ? » | Chiffre précis + analyse | Esquive, banalisation |
| « Que feriez-vous si on doublait votre volume ? » | Plan de croissance | Improvisation |

---

## 4. Construire un panel équilibré

### 4.1 Diversification

Un panel de **5 à 10 sous-traitants** par segment évite la dépendance à un seul.

| Profil | Pondération recommandée |
|---|---|
| Sous-traitants stratégiques (gros volume) | 2-3 |
| Sous-traitants tactiques (volume moyen) | 3-5 |
| Sous-traitants ponctuels (pics, urgences) | 2-3 |

### 4.2 Diversification géographique

Pour un commissionnaire couvrant plusieurs régions :
- 1-2 sous-traitants par région principale
- 1 sous-traitant national / européen pour le multi-trajets

### 4.3 Diversification fonctionnelle

- Lots complets (FTL)
- Distribution
- Spécifiques (ADR, ATP, exceptionnel)
- Express / urgences

### 4.4 Mise à jour annuelle

| Action | Fréquence |
|---|---|
| Bilan qualité par sous-traitant | Semestrielle |
| Mise à jour pièces administratives | Tous les 6 mois |
| Renouvellement audit terrain | Annuelle |
| Référencement complet | Tous les 3 ans |

---

## 5. Cas pratique : référencement de panel

**Contexte** : Vous renouvelez votre panel sous-traitants (15 acteurs, dont 8 stratégiques). Démarche.

### Phase 1 — Inventaire

| Catégorie | Nombre | Action |
|---|---|---|
| Sous-traitants > 5 ans collaboration | 6 | Audit court (focus performances) |
| Sous-traitants 1-5 ans | 5 | Audit complet |
| Sous-traitants < 1 an | 4 | Évaluation initiale post-pilote |

### Phase 2 — Audit standardisé

Grille commune de 35 critères, notation 0-3 :
- 12 critères opérationnels
- 8 critères financiers
- 6 critères humains
- 5 critères qualité
- 4 critères RSE/conformité

Score total /105.

### Phase 3 — Visite terrain

Pour les 5 sous-traitants identifiés à risque (score < 70) :
- Visite 1/2 journée
- Rencontre direction + opérationnels + conducteurs
- Compte rendu structuré

### Phase 4 — Décisions

| Catégorie | Score | Action |
|---|---|---|
| > 90 | Excellence | Maintien + augmentation des volumes |
| 75-90 | Performance | Maintien |
| 60-75 | Surveillance | Plan d'amélioration 6 mois |
| < 60 | Désengagement | Plan sortie 6-12 mois |

### Phase 5 — Communication

- Lettre de bilan à chaque sous-traitant
- Plan d'amélioration co-construit pour ceux en surveillance
- Communication transparente sur le désengagement

### Phase 6 — Recherche de nouveaux sous-traitants

- Pour combler les sorties, lancer 2-3 AO ciblés
- Délai prévisionnel : 6 mois pour intégration complète

ROI de la démarche :
- Réduction des incidents (estimation -20 % grâce à la sélection)
- Économies négociation (regroupement des volumes)
- Meilleure couverture des risques (panel plus solide)
- Investissement : 25-40 k€ (audit, visites)
- Bénéfice annuel estimé : 60-100 k€

---

> ✅ **À retenir**
>
> - **5 axes** : financier, opérationnel, humain, qualité/RSE, compatibilité.
> - **Visite terrain** indispensable pour les 3 finalistes (1/2 journée min).
> - Détecter les **signaux faibles** : parc vieux, climat tendu, sous-traitance occulte, tachygraphes mal gérés.
> - **Panel équilibré** : 5-10 sous-traitants par segment, diversifié géographique et fonctionnellement.
> - **Référencement annuel** + bilan semestriel.
$lesson3$,
'5 axes évaluation, visite terrain (1/2 journée, 7 étapes), signaux faibles à détecter, panel diversifié 5-10 sous-traitants par segment, référencement annuel.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Contractualiser et démarrer
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Contractualiser et démarrer la collaboration',
    'gotrm-bc02-01-04-contractualiser-demarrer', 4, 45,
$lesson4$
# Contractualiser et démarrer la collaboration

Une fois le sous-traitant choisi, le contrat encadre la relation et la phase de démarrage cristallise les engagements opérationnels. Bien menés, ils posent les fondations d'un partenariat durable.

> 🎯 **Objectifs de la leçon**
>
> - Maîtriser les **clauses contractuelles** essentielles.
> - Construire une **phase de pilote**.
> - Mettre en place les **rituels** de pilotage.
> - Anticiper les **risques** de dérapage.

---

## 1. Le contrat de sous-traitance

### 1.1 Mentions essentielles

| Section | Contenu |
|---|---|
| Identification | Parties, objet, périmètre |
| Durée | Initiale + renouvellement |
| Prix | Formule, indexation, conditions de paiement |
| Volumes | Engagements minimums et maximums |
| Qualité | SLA chiffrés, KPI, pénalités, bonus |
| Responsabilités | Plafonds, exclusions, assurances |
| Confidentialité | Engagements mutuels |
| Résiliation | Conditions, préavis, motifs |
| Litiges | Médiation, juridiction compétente |

### 1.2 Le prix

| Modalité | Quand utiliser |
|---|---|
| Prix unitaire au km | Lots complets, lignes régulières |
| Forfait par mission | Trajets répétitifs identifiés |
| Tarif au pourcentage | Affrètement classique (5-15 % sur le prix client) |
| Engagement de volume | Conditions préférentielles si seuil atteint |

### 1.3 La clause d'indexation gazole (RPC obligatoire)

> *« Conformément à l'article L. 3222-1 du Code des transports, le prix mentionné au présent contrat est indexé chaque mois sur la variation du Comité National Routier (CNR), indice gazole national mensuel. La part carburant est fixée à [30 %] du prix de transport. La répercussion s'applique de plein droit sur toutes les factures émises au cours du mois suivant la publication de l'indice. »*

### 1.4 Les SLA et pénalités

Voir BC01-08. Points clés :
- SLA SMART (Spécifique, Mesurable, Atteignable, Réaliste, Temporel)
- Pénalités progressives + plafond
- Exclusions (force majeure, faute du donneur d'ordre)
- Bonus en compensation

### 1.5 Les pénalités équilibrées

| Type | Mode |
|---|---|
| **Forfaitaire** | 50 € par retard signalé |
| **Proportionnelle** | 1 % du prix par tranche d'écart |
| **Progressive** | 2 % au 1er, 5 % aux 2-3, 10 % au-delà |
| **Plafonnée** | Maximum 10-15 % du CA mensuel |

### 1.6 Confidentialité

Souvent symétrique :
- Pas de divulgation des données sensibles (volumes, tarifs, clients)
- Durée pendant et 3 ans après la fin du contrat
- Sanction en cas de violation (clause pénale)

### 1.7 Résiliation

| Motif | Délai préavis |
|---|---|
| Pour convenance (sans faute) | 6 mois |
| Manquement contractuel grave | Mise en demeure 30 j sans amélioration |
| Force majeure | Sans préavis (avec preuve) |
| Procédure collective | Sans préavis |

---

## 2. La phase de pilote

### 2.1 Pourquoi un pilote ?

Avant un déploiement complet, le **pilote** sur 1-3 mois permet :
- Vérifier la capacité opérationnelle réelle
- Tester les processus de communication
- Mesurer les SLA en conditions réelles
- Ajuster avant l'engagement complet

### 2.2 Cadre type

| Élément | Valeur |
|---|---|
| Durée | 1-3 mois |
| Périmètre | 25-40 % du volume cible |
| Coût | Tarifs négociés (mais pas dérogatoires) |
| Suivi | Hebdomadaire intensif |
| Décision | Bilan formel à la fin avec décision oui/non |

### 2.3 Indicateurs de pilote

- Ponctualité atteinte vs cible
- Intégrité (% sans avarie)
- Respect des procédures
- Qualité de la communication
- Réactivité aux incidents
- Qualité du reporting

### 2.4 Gérer une fin de pilote négative

Si le sous-traitant ne tient pas ses engagements pendant le pilote :
- Bilan factuel chiffré présenté
- Possibilité d'un avenant correctif (extension du pilote 1 mois)
- Si pas d'amélioration : non-renouvellement (préavis prévu au contrat)
- Documentation complète pour transmettre au futur successeur

---

## 3. Les rituels de pilotage

### 3.1 Rituels opérationnels

| Fréquence | Format | Participants |
|---|---|---|
| Quotidien | Email synthèse incidents | Exploitants |
| Hebdomadaire | Réunion 30 min | Exploitants des 2 parties |
| Mensuel | Reporting KPI complet | Exploitants + manager |

### 3.2 Rituels managériaux

| Fréquence | Format | Participants |
|---|---|---|
| Mensuel | Réunion 60 min | Direction d'exploitation 2 parties |
| Trimestriel | Comité de pilotage 2 h | Direction générale 2 parties |
| Annuel | Bilan + revue contrat | Direction générale 2 parties |

### 3.3 Reporting attendu

Du sous-traitant vers le donneur d'ordre, mensuellement :

| KPI | Périodicité | Format |
|---|---|---|
| Taux ponctualité | Mensuel | Tableau + graphe |
| Taux intégrité | Mensuel | Tableau + graphe |
| Conformité doc | Mensuel | Tableau |
| Incidents (liste détaillée) | Mensuel | Liste |
| Évolution volumes | Mensuel | Tableau |

---

## 4. Les risques de dérapage

### 4.1 Risque qualitatif

Le sous-traitant ne tient pas ses engagements de qualité :
- Causes : surcharge, perte conducteur clé, problème véhicule
- Action : revue avec le sous-traitant, plan d'action, suivi rapproché
- Si persistance : pénalités contractuelles, voire résiliation

### 4.2 Risque financier

Le sous-traitant montre des signes de difficultés :
- Causes : croissance trop rapide, perte clients, impayés
- Action : revoir conditions de paiement, exiger garanties supplémentaires
- Si grave : préparer plan de transition rapide

### 4.3 Risque humain

Tensions sociales chez le sous-traitant :
- Causes : grèves, démissions massives, accidents
- Action : audit climat, soutien éventuel, plan de prévention
- Continuer à payer pour ne pas aggraver

### 4.4 Risque réglementaire

Sous-traitance occulte, travail dissimulé, infractions R561 :
- Causes : pression sur les coûts, manque de pilotage
- Action : audit immédiat, mise en demeure de régulariser
- Si gravissime : résiliation sans préavis

### 4.5 Tableau de bord risques

| Risque | Niveau | Indicateur de détection | Action préventive |
|---|---|---|---|
| Qualité | 🟢🟧🟥 | Évolution KPI | Audit |
| Financier | 🟢🟧🟥 | Données KBIS, paiement | Vérification semestrielle |
| Humain | 🟢🟧🟥 | Turnover, climat | Visite terrain |
| Réglementaire | 🟢🟧🟥 | Documents, contrôles DREAL | Audit annuel |

---

## 5. Cas pratique : démarrage avec un nouveau sous-traitant

**Contexte** : Vous lancez la collaboration avec *Astre Transport* (lauréat AO précédent). 4 lignes Lyon-Strasbourg, démarrage J+30.

### Étape 1 — Signature contrat (J-30)

- Signature contrat 12 mois renouvelable
- Conditions négociées : prix 1 195 000 €/an, RPC mensuelle, SLA ponctualité 96 %
- Avenants si volumes > +20 %

### Étape 2 — Pilote (J0 à J+90)

- 50 % du volume sur les 3 premiers mois (2 lignes au lieu de 4)
- Reporting hebdomadaire intense
- Visite terrain à J+45
- Bilan formel à J+90

### Étape 3 — Préparation opérationnelle (J-15 à J0)

| Action | Délai |
|---|---|
| Mise en place outils communs (ETA app, télématique) | J-15 |
| Formation exploitants (2 j) | J-10 |
| Briefing conducteurs Astre | J-7 |
| Test grandeur nature (1 mission) | J-3 |
| Lancement officiel | J0 |

### Étape 4 — Suivi pilote (J+1 à J+90)

| Fréquence | Action |
|---|---|
| Quotidien | Synthèse incidents par mail |
| Hebdomadaire | Réunion 30 min en visio |
| Mensuel | Reporting complet KPI + tendances |
| Trimestriel | Comité pilotage avec direction |

### Étape 5 — Bilan pilote J+90

| Indicateur | Valeur | Cible | Statut |
|---|---|---|---|
| Ponctualité | 95,8 % | 96 % | 🟧 Très proche |
| Intégrité | 99,7 % | 99,5 % | 🟩 Au-dessus |
| Conformité doc | 99,2 % | 99 % | 🟩 |
| Incidents majeurs | 1 (résolu) | < 2 | 🟩 |

Décision : **passage à 100 % du volume** à J+91, avec un **plan d'amélioration** sur la ponctualité (cible 97 % à 6 mois).

### Étape 6 — Vie courante

- Reporting mensuel automatisé
- Comité trimestriel
- Bilan annuel pour décision renouvellement
- Revue tarifaire annuelle

---

> ✅ **À retenir**
>
> - **Contrat sous-traitance** : 9 sections (identification, durée, prix, volumes, qualité, responsabilités, confidentialité, résiliation, litiges).
> - **RPC obligatoire** : indexation CNR mensuelle, part carburant 30 %.
> - **Pilote 1-3 mois** sur 25-40 % du volume avant déploiement complet.
> - **Rituels** : daily synthèse, hebdo 30 min, mensuel KPI complet, trimestriel direction.
> - 4 risques majeurs : **qualité, financier, humain, réglementaire** — tableau de bord dédié.
$lesson4$,
'Contrat sous-traitance (9 sections), RPC obligatoire L. 3222-1, pilote 1-3 mois sur 25-40 % du volume, rituels de pilotage (daily, hebdo, mensuel, trimestriel), 4 risques majeurs.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- 25 QCM
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qcm', 'La sous-traitance représente typiquement quelle part du CA chez les commissionnaires de transport ?', '[{"id":"a","label":"5-10 %","is_correct":false},{"id":"b","label":"40-60 %","is_correct":true},{"id":"c","label":"80-95 %","is_correct":false},{"id":"d","label":"100 %","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['soustraitance','part-CA'], 'mft-2026-gotrm:bc02-01:qcm:1', true, 'La sous-traitance représente 40-60 % du CA chez les commissionnaires de transport en France. C''est un levier économique majeur mais aussi un risque (responsabilité solidaire, complicité de travail dissimulé).'),
  (v_formation, 'qcm', 'Le commissionnaire de transport :', '[{"id":"a","label":"Effectue lui-même les transports","is_correct":false},{"id":"b","label":"Organise un transport pour le compte d''un client en choisissant librement les moyens","is_correct":true},{"id":"c","label":"Est uniquement un conseiller","is_correct":false},{"id":"d","label":"Possède obligatoirement des véhicules","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['commissionnaire'], 'mft-2026-gotrm:bc02-01:qcm:2', true, 'Le commissionnaire organise un transport pour le compte d''un client, choisit librement les moyens (route, fer, mer, air, multimodal). Profession réglementée nécessitant licence commissionnaire (LCB) + capacité GOTRM.'),
  (v_formation, 'qcm', 'L''article L. 8222-1 du Code du travail impose au donneur d''ordre de vérifier son sous-traitant :', '[{"id":"a","label":"Une seule fois en début de contrat","is_correct":false},{"id":"b","label":"Avant la conclusion ET tous les 6 mois ensuite","is_correct":true},{"id":"c","label":"Tous les 5 ans","is_correct":false},{"id":"d","label":"Aucune obligation de vérification","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['vigilance','verifications'], 'mft-2026-gotrm:bc02-01:qcm:3', true, 'L. 8222-1 : vérifications avant la conclusion + tous les 6 mois pendant la durée du contrat. KBIS, URSSAF, fiscalité, DPAE. À défaut : risque de complicité de travail dissimulé (75 k€ + solidarité).'),
  (v_formation, 'qcm', 'Le risque de complicité de travail dissimulé peut entraîner pour le donneur d''ordre :', '[{"id":"a","label":"Un avertissement verbal","is_correct":false},{"id":"b","label":"Une amende pénale jusqu''à 75 000 € + solidarité financière","is_correct":true},{"id":"c","label":"Une interdiction de sous-traiter pendant 1 an","is_correct":false},{"id":"d","label":"Aucune sanction","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['travail-dissimule','sanctions'], 'mft-2026-gotrm:bc02-01:qcm:4', true, 'Complicité de travail dissimulé : amende pénale jusqu''à 75 000 €, solidarité financière (paiement des salaires et cotisations dus), suspension de la licence transport. C''est un risque majeur en sous-traitance.'),
  (v_formation, 'qcm', 'Le contrat-type sous-traitance transport est défini par le décret :', '[{"id":"a","label":"99-269 du 6 avril 1999","is_correct":false},{"id":"b","label":"2003-1295 du 26 décembre 2003","is_correct":true},{"id":"c","label":"75-1334 du 31 décembre 1975","is_correct":false},{"id":"d","label":"Aucun décret spécifique","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['contrat-type','soustraitance'], 'mft-2026-gotrm:bc02-01:qcm:5', true, 'Décret 2003-1295 du 26 déc 2003 = contrat-type sous-traitance transport (s''applique à défaut d''accord écrit spécifique). Distinct du contrat-type général (décret 99-269 pour le transport routier).'),
  (v_formation, 'qcm', 'Le « prix abusivement bas » d''un sous-traitant est :', '[{"id":"a","label":"Un avantage économique pour le donneur d''ordre","is_correct":false},{"id":"b","label":"Interdit par L. 3222-3 du Code des transports, amende jusqu''à 90 000 €","is_correct":true},{"id":"c","label":"Toléré si négocié librement","is_correct":false},{"id":"d","label":"Recommandé pour augmenter la marge","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['prix-abusivement-bas'], 'mft-2026-gotrm:bc02-01:qcm:6', true, 'L. 3222-3 : pratique du prix abusivement bas (qui ne couvre pas les coûts du sous-traitant) interdite. Amende administrative jusqu''à 90 000 € pour le donneur d''ordre. Bonne pratique : barème interne minimum.'),
  (v_formation, 'qcm', 'En cas de défaillance du donneur d''ordre, la loi de 1975 prévoit pour le sous-traitant :', '[{"id":"a","label":"Aucun recours","is_correct":false},{"id":"b","label":"Un paiement direct par le client final","is_correct":true},{"id":"c","label":"Une garantie d''État","is_correct":false},{"id":"d","label":"Une priorité de paiement sur tous autres créanciers","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['paiement-direct','1975'], 'mft-2026-gotrm:bc02-01:qcm:7', true, 'Loi 75-1334 : en cas de défaillance du donneur d''ordre, le sous-traitant peut demander le paiement direct par le client final. C''est une garantie majeure pour le sous-traitant.'),
  (v_formation, 'qcm', 'Pour qu''un sous-traitant puisse lui-même sous-traiter (cascade) :', '[{"id":"a","label":"Aucune contrainte","is_correct":false},{"id":"b","label":"Il doit informer explicitement le donneur d''ordre principal","is_correct":true},{"id":"c","label":"Il faut une autorisation préfectorale","is_correct":false},{"id":"d","label":"C''est interdit en France","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['cascade','information'], 'mft-2026-gotrm:bc02-01:qcm:8', true, 'Article L. 3221-3 : la sous-traitance en cascade nécessite l''information explicite du donneur d''ordre principal. Une cascade non déclarée peut entraîner annulation, amendes, perte d''honorabilité.'),
  (v_formation, 'qcm', 'Dans un appel d''offres bien conçu, la pondération recommandée pour le critère "prix" est :', '[{"id":"a","label":"5-10 %","is_correct":false},{"id":"b","label":"30-40 %","is_correct":true},{"id":"c","label":"60-70 %","is_correct":false},{"id":"d","label":"100 %","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['appel-offres','ponderation'], 'mft-2026-gotrm:bc02-01:qcm:9', true, 'Pondération équilibrée : prix 30-40 %, qualité 25-30 %, capacité 15-20 %, finance 10-15 %, RSE 5-10 %. Mettre 100 % sur le prix mène au "moins-disant" destructeur (sous-traitant fragile, risques sécurité).'),
  (v_formation, 'qcm', 'Le délai standard entre envoi d''un cahier des charges et remise des offres est :', '[{"id":"a","label":"3 jours","is_correct":false},{"id":"b","label":"30-45 jours","is_correct":true},{"id":"c","label":"6 mois","is_correct":false},{"id":"d","label":"1 an","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['appel-offres','delai'], 'mft-2026-gotrm:bc02-01:qcm:10', true, '30-45 jours minimum. Permet une analyse sérieuse, une réponse de qualité et une période de questions. Moins = travail bâclé, plus = perte de focus. Pour un appel d''offres complexe, prévoir 60 jours.'),
  (v_formation, 'qcm', 'Un cahier des charges complet d''AO transport contient au minimum :', '[{"id":"a","label":"3 sections","is_correct":false},{"id":"b","label":"8 sections (présentation, périmètre, technique, opé, qualité, contractuel, pièces, critères)","is_correct":true},{"id":"c","label":"15 sections obligatoires","is_correct":false},{"id":"d","label":"Aucune structure imposée","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['cahier-charges','sections'], 'mft-2026-gotrm:bc02-01:qcm:11', true, '8 sections clés : présentation donneur d''ordre, périmètre quantitatif, exigences techniques, exigences opérationnelles, exigences qualité, cadre contractuel, pièces à fournir, critères de notation.'),
  (v_formation, 'qcm', 'La visite terrain d''un sous-traitant finaliste dure typiquement :', '[{"id":"a","label":"15 minutes","is_correct":false},{"id":"b","label":"1/2 journée minimum","is_correct":true},{"id":"c","label":"1 semaine entière","is_correct":false},{"id":"d","label":"Aucune visite nécessaire","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['visite-terrain','duree'], 'mft-2026-gotrm:bc02-01:qcm:12', true, 'Visite terrain : 1/2 journée minimum (4 h) pour rencontrer direction, voir locaux et parc, observer outils, échanger avec exploitants et conducteurs. Indispensable pour les 3 finalistes d''un AO sérieux.'),
  (v_formation, 'qcm', 'Parmi ces signaux, lequel est un signal d''ALERTE chez un sous-traitant potentiel ?', '[{"id":"a","label":"Parc moderne et propre","is_correct":false},{"id":"b","label":"Conducteurs avec téléphone au volant pendant la visite","is_correct":true},{"id":"c","label":"Procédures écrites accessibles","is_correct":false},{"id":"d","label":"Direction qui parle ouvertement de ses challenges","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['signaux-faibles'], 'mft-2026-gotrm:bc02-01:qcm:13', true, 'Téléphone au volant des conducteurs lors d''une visite = signal d''alerte (manque de discipline, non-respect des règles). Les autres options sont des signaux POSITIFS (modernité, transparence, organisation).'),
  (v_formation, 'qcm', 'Un panel équilibré de sous-traitants par segment compte typiquement :', '[{"id":"a","label":"1 seul (dépendance maximale)","is_correct":false},{"id":"b","label":"5 à 10 sous-traitants","is_correct":true},{"id":"c","label":"50 sous-traitants","is_correct":false},{"id":"d","label":"Plus de 100","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['panel','nombre'], 'mft-2026-gotrm:bc02-01:qcm:14', true, 'Un panel équilibré = 5 à 10 sous-traitants par segment. Évite la dépendance à un seul (risque de défaillance), permet une saine émulation tarifaire, et offre une couverture des risques.'),
  (v_formation, 'qcm', 'Une période de pilote chez un nouveau sous-traitant dure typiquement :', '[{"id":"a","label":"1 jour","is_correct":false},{"id":"b","label":"1 à 3 mois sur 25-40 % du volume cible","is_correct":true},{"id":"c","label":"1 an minimum","is_correct":false},{"id":"d","label":"Aucun pilote","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['pilote','duree'], 'mft-2026-gotrm:bc02-01:qcm:15', true, 'Pilote 1-3 mois sur 25-40 % du volume cible. Permet de tester en conditions réelles avant déploiement complet, d''identifier les ajustements nécessaires, et de réduire le risque d''engagement.'),
  (v_formation, 'qcm', 'La clause RPC (indexation gazole) dans un contrat de sous-traitance est :', '[{"id":"a","label":"Optionnelle","is_correct":false},{"id":"b","label":"D''ordre public selon L. 3222-1, obligatoire dans tout contrat de transport","is_correct":true},{"id":"c","label":"Réservée aux gros transporteurs","is_correct":false},{"id":"d","label":"Limitée à l''international","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['rpc','obligation'], 'mft-2026-gotrm:bc02-01:qcm:16', true, 'L. 3222-1 : la RPC (Répercussion du Prix du Carburant) est d''ordre public. Aucune clause ne peut y renoncer. Standard : indexation CNR mensuelle, part carburant 30 % (porteur) ou 35 % (TRR).'),
  (v_formation, 'qcm', 'Le préavis standard pour résiliation pour convenance d''un contrat de sous-traitance est :', '[{"id":"a","label":"1 semaine","is_correct":false},{"id":"b","label":"1 mois","is_correct":false},{"id":"c","label":"6 mois","is_correct":true},{"id":"d","label":"3 ans","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['resiliation','preavis'], 'mft-2026-gotrm:bc02-01:qcm:17', true, 'Préavis standard 6 mois pour résiliation pour convenance. Pour faute grave : mise en demeure 30 j sans amélioration. Pour force majeure ou procédure collective : sans préavis.'),
  (v_formation, 'qcm', 'Lors d''un appel d''offres, les seuils éliminatoires sont :', '[{"id":"a","label":"Optionnels","is_correct":false},{"id":"b","label":"Des conditions minimales en deçà desquelles l''offre est rejetée d''office","is_correct":true},{"id":"c","label":"Des indications de prix","is_correct":false},{"id":"d","label":"Des conditions négociables","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['seuils-eliminatoires'], 'mft-2026-gotrm:bc02-01:qcm:18', true, 'Seuils éliminatoires = conditions minimales (ex : licence transport en cours, KBIS < 3 mois, ISO 9001 si exigée). Si non respectés : rejet automatique sans analyse complète. Doivent être annoncés dans le cahier des charges.'),
  (v_formation, 'qcm', 'Un commissionnaire reste responsable vis-à-vis du client final :', '[{"id":"a","label":"Uniquement de ses propres actes","is_correct":false},{"id":"b","label":"De ses faits ET des faits de ses substitués (sous-traitants)","is_correct":true},{"id":"c","label":"Aucune responsabilité une fois le sous-traitant désigné","is_correct":false},{"id":"d","label":"Uniquement si faute prouvée","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['commissionnaire','responsabilite'], 'mft-2026-gotrm:bc02-01:qcm:19', true, 'Article L. 132-3 Code de commerce : le commissionnaire est responsable de ses faits ET des faits de ses substitués. Il peut ensuite se retourner contre le sous-traitant fautif (action en garantie, subrogation).'),
  (v_formation, 'qcm', 'Lors du référencement d''un sous-traitant, parmi les pièces administratives obligatoires :', '[{"id":"a","label":"Bulletin de paie d''un conducteur","is_correct":false},{"id":"b","label":"KBIS < 3 mois, attestations URSSAF et fiscale, DPAE, licence transport, RC pro","is_correct":true},{"id":"c","label":"Plan de masse des locaux","is_correct":false},{"id":"d","label":"Lettre du maire de la commune","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['pieces','obligatoires'], 'mft-2026-gotrm:bc02-01:qcm:20', true, 'Pièces administratives obligatoires : KBIS < 3 mois, URSSAF, fiscalité, DPAE conducteurs, licence transport (LTI/LTM), bulletins n°2 dirigeants (honorabilité), attestation RC professionnelle.'),
  (v_formation, 'qcm', 'Les rituels de pilotage avec un sous-traitant régulier comprennent typiquement :', '[{"id":"a","label":"1 réunion annuelle uniquement","is_correct":false},{"id":"b","label":"Quotidien (synthèse), hebdo (réunion 30 min), mensuel (KPI), trimestriel (direction)","is_correct":true},{"id":"c","label":"Une newsletter trimestrielle","is_correct":false},{"id":"d","label":"Aucune communication régulière","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['rituels','pilotage'], 'mft-2026-gotrm:bc02-01:qcm:21', true, '4 niveaux de rituels : quotidien (synthèse incidents par mail), hebdo (réunion 30 min exploitants), mensuel (reporting KPI complet), trimestriel (comité de pilotage avec direction). Plus annuel (bilan + revue contrat).'),
  (v_formation, 'qcm', 'Un signal de fragilité financière chez un sous-traitant est :', '[{"id":"a","label":"Investissements dans le parc","is_correct":false},{"id":"b","label":"Compte de résultat en perte 2 années consécutives","is_correct":true},{"id":"c","label":"Croissance du CA","is_correct":false},{"id":"d","label":"Embauche de conducteurs","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['fragilite','financiere'], 'mft-2026-gotrm:bc02-01:qcm:22', true, 'Signaux financiers d''alerte : pertes 2 années consécutives, hypothèques/nantissements, procédure collective récente, refus de fournir bilans détaillés. À surveiller régulièrement (Infogreffe, attestations).'),
  (v_formation, 'qcm', 'Pour les 3 finalistes d''un appel d''offres important, la pratique recommandée est :', '[{"id":"a","label":"Décider sur dossier sans rencontrer","is_correct":false},{"id":"b","label":"Visite terrain 1/2 journée + soutenance commerciale","is_correct":true},{"id":"c","label":"Demander un pilote gratuit","is_correct":false},{"id":"d","label":"Faire signer immédiatement","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['finalistes','visite'], 'mft-2026-gotrm:bc02-01:qcm:23', true, 'Pour les 3 finalistes : visite terrain (1/2 journée minimum) pour valider l''adéquation entre dossier et réalité, et soutenance commerciale (présentation orale 30-60 min + questions). Permet une décision finale informée.'),
  (v_formation, 'qcm', 'Lors d''un audit semestriel d''un sous-traitant, on vérifie notamment :', '[{"id":"a","label":"Uniquement les KPI qualité","is_correct":false},{"id":"b","label":"Renouvellement des pièces administratives + KPI + état du panel","is_correct":true},{"id":"c","label":"Le résultat du dernier match de football","is_correct":false},{"id":"d","label":"Aucun audit nécessaire","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['audit','semestriel'], 'mft-2026-gotrm:bc02-01:qcm:24', true, 'Audit semestriel : vérification renouvellement attestations URSSAF, fiscalité, DPAE (obligation L. 8222-1), KPI qualité, statistiques incidents, évolution du parc et de l''effectif, situation financière.'),
  (v_formation, 'qcm', 'L''engagement de volume dans un contrat de sous-traitance permet :', '[{"id":"a","label":"De fixer le prix unitaire","is_correct":false},{"id":"b","label":"D''obtenir des conditions préférentielles si un seuil de volume est atteint","is_correct":true},{"id":"c","label":"De résilier sans préavis","is_correct":false},{"id":"d","label":"De refuser tout sinistre","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['engagement','volume'], 'mft-2026-gotrm:bc02-01:qcm:25', true, 'Engagement de volume = clause par laquelle le donneur d''ordre s''engage sur un volume minimum, contre des conditions préférentielles (tarif dégressif, priorité, exclusivité). C''est un levier de négociation gagnant-gagnant.');


  -- =================================================================
  -- 4 QR
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qr', 'Un nouveau sous-traitant *Trans-Sud SARL* propose un tarif 22 % sous le marché pour une ligne hebdomadaire. Décrivez la procédure de vérification et d''évaluation à mener avant tout engagement, en listant minimum 10 points de contrôle et les sanctions encourues en cas de manquement.', NULL, 1, 'difficile', ARRAY['verification','procedure','sanctions'], 'mft-2026-gotrm:bc02-01:qr:1', true, 'PROCÉDURE DE VÉRIFICATION COMPLÈTE :

PHASE 1 — Vérifications administratives (obligatoires L. 8222-1)

1. KBIS récent < 3 mois
- Vérifier raison sociale, statut juridique, dirigeants
- Date d''inscription au RCS, ancienneté de l''entreprise

2. Attestation URSSAF
- Cotisations sociales à jour
- Pas de redressement en cours
- Attestation de vigilance < 6 mois

3. Attestation fiscale
- Cotisations fiscales à jour
- Pas de procédure de recouvrement

4. DPAE (Déclaration Préalable À l''Embauche)
- Liste des conducteurs effectivement déclarés
- Cohérence avec le parc et le volume annoncé
- Vigilance sur les écarts (10 véhicules / 3 conducteurs déclarés = signal rouge)

5. Licence transport en cours
- Inscription au registre des TPR
- LTI ou LTM selon véhicules
- Capacité financière prouvée

6. Bulletins n°2 dirigeants
- Honorabilité professionnelle (R3411-1 Code des transports)
- Absence de condamnations bloquantes

7. Attestation RC Professionnelle
- En cours de validité
- Plafonds adaptés aux marchandises transportées

PHASE 2 — Analyse économique du tarif

8. Décomposition du prix demandé
- Demander le détail des coûts (carburant, conducteur, amortissement, structure)
- Calculer le seuil de rentabilité théorique
- Comparer aux barèmes CNR / études sectorielles

9. Analyse de la cohérence
- Le prix peut-il couvrir les coûts ?
- Sinon : comment le sous-traitant compense-t-il (volume, retour à vide minimisé, autres clients) ?
- Si pas de réponse satisfaisante : présomption de prix abusivement bas (L. 3222-3)

PHASE 3 — Analyse opérationnelle

10. Visite terrain (1/2 journée)
- Direction, exploitation, conducteurs
- État du parc, modernité, propreté
- Outils utilisés (TMS, télématique)
- Climat, ambiance, organisation

11. Vérification des références
- Demander 3 clients référents et appeler
- Vérifier la cohérence des informations
- Sentiment global sur la qualité

12. Bilans des 3 derniers exercices
- Évolution CA, résultat net, fonds propres
- Trésorerie nette
- Stabilité financière

PHASE 4 — Évaluation finale

13. Calcul de risque global
- Risque de défaillance (échelle 1-5)
- Risque qualité (1-5)
- Risque réglementaire (1-5)
- Si total > 9 : refuser

14. Décision graduée
- Si tout OK : pilote 3 mois sur 30 % du volume, déploiement complet ensuite
- Si doutes : pilote très court (1 mois) sur 10 % du volume, surveillance intensive
- Si signaux d''alerte : refuser et documenter

SANCTIONS ENCOURUES EN CAS DE MANQUEMENT :

A. Travail dissimulé (sans vérification L. 8222-1)
- Amende pénale jusqu''à 75 000 €
- Solidarité financière (paiement salaires + cotisations dus)
- Inscription dans le registre national
- Conséquences réputationnelles graves

B. Prix abusivement bas (L. 3222-3)
- Amende administrative jusqu''à 90 000 €
- Annulation du contrat
- Inscription au registre des entreprises sanctionnées

C. Cascade non déclarée (L. 3221-3)
- Annulation du contrat
- Amendes complémentaires
- Perte d''honorabilité professionnelle (suspension licence)

D. Faute lourde de gestion (négligence dans la sélection)
- Responsabilité civile vis-à-vis des clients et tiers
- Sinistres potentiellement non couverts par l''assurance
- Risque pénal en cas d''accident grave

DÉCISION RECOMMANDÉE pour ce cas (-22 % du marché)

Compte tenu de l''écart inhabituel (22 % < marché), la vigilance doit être maximale :

1. Demander immédiatement le détail économique du tarif
2. Si pas de justification cohérente : refuser
3. Si justification (optimisation extrême) : pilote très court 1 mois sur 1 ligne uniquement, audit terrain renforcé
4. Si signaux d''alerte (DPAE incohérente, refus de fournir bilans) : refuser sans appel et documenter

DOCUMENTATION

Conserver pendant 5 ans tous les éléments :
- Cahier des charges et offre reçue
- Attestations vérifiées
- Compte rendu de visite
- Justifications économiques
- Décision finale motivée

En cas de contrôle, ces éléments prouvent la diligence du donneur d''ordre.'),
  (v_formation, 'qr', 'Construisez la grille de notation détaillée pour un appel d''offres lignes régulières (60 missions/mois, ligne nationale 600 km), avec pondérations, sous-critères, échelles de notation et seuils éliminatoires.', NULL, 1, 'difficile', ARRAY['grille','notation','construction'], 'mft-2026-gotrm:bc02-01:qr:2', true, 'GRILLE DE NOTATION COMPLÈTE — AO LIGNES RÉGULIÈRES

OBJET : 60 missions/mois sur ligne nationale 600 km, 1 an renouvelable

PONDÉRATIONS GLOBALES

| Critère principal | Poids |
|---|---|
| 1. Prix | 35 % |
| 2. Qualité de service / SLA | 30 % |
| 3. Capacité technique | 15 % |
| 4. Solidité financière | 10 % |
| 5. RSE et certifications | 5 % |
| 6. Démarche commerciale | 5 % |
| TOTAL | 100 % |

SEUILS ÉLIMINATOIRES (rejets automatiques)

- KBIS > 3 mois ou pièces obligatoires manquantes
- Licence transport non valide
- Capacité financière < 11 800 € par véhicule (réglementaire)
- Inscription au registre des entreprises ayant été sanctionnées
- Déclaration de difficultés financières en cours
- Antécédents de fraude documentés

CRITÈRE 1 — PRIX (35 %)

Sous-critère 1.1 — Prix unitaire de la mission (25 %)

| Note | Critère |
|---|---|
| 5 (excellent) | < -10 % vs moyenne offres |
| 4 (très bon) | -5 à -10 % vs moyenne |
| 3 (bon) | -5 à +5 % vs moyenne |
| 2 (moyen) | +5 à +10 % vs moyenne |
| 1 (faible) | > +10 % vs moyenne |
| 0 | Hors barème (trop bas → suspect) |

Sous-critère 1.2 — Conditions financières (10 %)

- Délai paiement standard accepté (5 pts)
- Indexation gazole conforme (5 pts)
- Volumes engagés sans surcoût (5 pts)
- Pas de minimum facturable abusif (5 pts)

CRITÈRE 2 — QUALITÉ DE SERVICE / SLA (30 %)

Sous-critère 2.1 — Engagements SLA proposés (15 %)

| Note | Critère |
|---|---|
| 5 | Ponctualité ≥ 98 %, intégrité ≥ 99,9 %, conformité doc ≥ 99,5 % |
| 4 | Ponctualité ≥ 96 %, intégrité ≥ 99,7 %, conformité doc ≥ 99 % |
| 3 | Ponctualité ≥ 95 %, intégrité ≥ 99,5 %, conformité doc ≥ 98 % |
| 2 | Ponctualité ≥ 93 %, intégrité ≥ 99 %, conformité doc ≥ 97 % |
| 1 | Ponctualité ≥ 90 %, intégrité ≥ 98 %, conformité doc ≥ 95 % |
| 0 | < 90 % ou pas d''engagement |

Sous-critère 2.2 — Statistiques qualité 12 derniers mois (10 %)

- Ponctualité réelle (4 pts)
- Taux d''avaries (3 pts)
- Taux de litiges (3 pts)

Pour chaque sous-critère, noter sur la base des chiffres fournis et vérifiables.

Sous-critère 2.3 — Capacité de gestion incident (5 %)

- Procédure documentée (2 pts)
- Système d''alerte temps réel (2 pts)
- Astreinte 24/7 (1 pt)

CRITÈRE 3 — CAPACITÉ TECHNIQUE (15 %)

Sous-critère 3.1 — Parc dédié (8 %)

- Type de véhicule conforme (4 pts)
- Âge moyen du parc dédié (2 pts) : < 5 ans = 2, 5-8 ans = 1, > 8 ans = 0
- Polyvalence et back-up disponible (2 pts)

Sous-critère 3.2 — Conducteurs qualifiés (4 %)

- CQC FCO < 5 ans pour 100 % des conducteurs concernés (2 pts)
- Ancienneté moyenne (2 pts) : > 5 ans = 2, 2-5 ans = 1, < 2 ans = 0

Sous-critère 3.3 — Outils télématique (3 %)

- Télématique embarquée full sur le parc dédié (1 pt)
- Possibilité d''intégration TMS donneur d''ordre (1 pt)
- Capacité de partager les données client (1 pt)

CRITÈRE 4 — SOLIDITÉ FINANCIÈRE (10 %)

Sous-critère 4.1 — Bilans des 3 dernières années (6 %)

- Croissance ou stabilité du CA (2 pts)
- Marge nette > 3 % (2 pts)
- Résultat net positif (2 pts)

Sous-critère 4.2 — Trésorerie et fonds propres (4 %)

- Fonds propres / total bilan > 25 % (2 pts)
- Trésorerie nette positive (2 pts)

CRITÈRE 5 — RSE ET CERTIFICATIONS (5 %)

- ISO 9001 (1,5 pt)
- Démarche carbone documentée (1 pt)
- Politique sociale (1 pt)
- Certifications spécifiques (ADR, GDP) selon besoin (1 pt)
- Engagement environnemental (véhicules récents, formation éco-conduite) (0,5 pt)

CRITÈRE 6 — DÉMARCHE COMMERCIALE (5 %)

Sous-critère 6.1 — Présentation orale (3 %)

- Compréhension du besoin (1 pt)
- Qualité de la présentation (1 pt)
- Réactivité aux questions (1 pt)

Sous-critère 6.2 — Adéquation projet (2 %)

- Engagement de volume (1 pt)
- Vision long terme cohérente (1 pt)

ÉCHELLE DE NOTATION

Pour chaque sous-critère noté de 0 à 5, on convertit en pondération :
- Note × poids du sous-critère / 5

Exemple : prix unitaire (poids 25 %), note 4/5
- Score = 4 × 25 / 5 = 20 % du critère final

DÉCISION SUR LA BASE DES SCORES

| Score total | Décision |
|---|---|
| > 90/100 | Lauréat probable |
| 80-90 | Finaliste, négociation possible |
| 70-80 | À considérer si manque de candidats |
| 60-70 | Rejeté |
| < 60 | Rejet automatique |

PHASES SUIVANTES

1. Présélection : 3 finalistes sur la base des dossiers
2. Visite terrain (1/2 journée) chez chaque finaliste
3. Soutenance commerciale (1 h)
4. Décision finale par direction
5. Notification + négociations finales
6. Signature contrat
7. Phase de pilote 1-3 mois
8. Déploiement complet

OBSERVATIONS

- La pondération PRIX à 35 % évite le moins-disant destructeur tout en restant concurrentielle
- Les SEUILS ÉLIMINATOIRES garantissent l''écart des candidats à risque
- La VISITE TERRAIN ne fait pas partie de la grille mais est INDISPENSABLE pour les finalistes
- La GRILLE est COMMUNICABLE aux candidats (transparence)

Cette grille structure une décision objective et défendable. Elle peut être adaptée au contexte (volumes, exigences, marché).'),
  (v_formation, 'qr', 'Vous lancez une collaboration avec un nouveau sous-traitant. Décrivez le plan détaillé du pilote (3 mois) avec étapes, indicateurs de suivi, critères de validation, et arborescence des décisions à la fin du pilote.', NULL, 1, 'difficile', ARRAY['pilote','plan','arborescence'], 'mft-2026-gotrm:bc02-01:qr:3', true, 'PLAN DE PILOTE COLLABORATION SOUS-TRAITANT — 3 MOIS

OBJECTIF : valider la capacité opérationnelle, qualité et compatibilité avant déploiement complet (montée à 100 % du volume cible à M+3).

PHASE 0 — PRÉPARATION (M-1 à M0)

J-30 — Cadrage administratif
- Signature contrat 12 mois (avec clause de pilote)
- Échange des contacts clés
- Mise en place outils de communication
- Définition des accès aux systèmes (TMS, télématique)

J-15 — Préparation opérationnelle
- Formation conjointe exploitants (1 jour)
- Briefing conducteurs sous-traitant
- Tests d''intégration (ETA, télématique, app)
- Définition des procédures de communication

J-7 — Pilote technique
- 1 mission test grandeur nature
- Vérification de tous les flux (commande → exécution → facturation)
- Identification et correction des points de friction

J0 — Lancement officiel
- Communication interne (donneur d''ordre + sous-traitant)
- Information clients finaux concernés (le cas échéant)
- Démarrage des missions

PHASE 1 — PILOTE EN ROUTE (M0 à M+3)

PÉRIMÈTRE DU PILOTE

- 30 % du volume cible (au lieu de 100 %)
- 1-2 lignes pilotes (sur 4 lignes prévues)
- Conducteurs et véhicules dédiés identifiés
- Procédures complètes appliquées

INDICATEURS DE SUIVI HEBDOMADAIRE

| KPI | Cible Mois 1 | Cible Mois 2 | Cible Mois 3 |
|---|---|---|---|
| Ponctualité | > 92 % | > 94 % | > 96 % |
| Intégrité | > 99 % | > 99,5 % | > 99,5 % |
| Conformité doc | > 97 % | > 98 % | > 99 % |
| Incidents majeurs | < 3 | < 2 | < 1 |
| Délai réponse réclamations | < 8 h ouv | < 6 h | < 4 h |

INDICATEURS DE SUIVI MENSUEL

- Évolution KPI vs M-1
- Nombre de missions effectuées vs prévues
- Taux d''utilisation du parc dédié
- Nombre de litiges et leur résolution
- Feedback exploitants donneur d''ordre
- Feedback clients finaux (NPS partiel)

RITUELS PENDANT LE PILOTE

| Fréquence | Format | Participants |
|---|---|---|
| Quotidien | Email synthèse incidents | Exploitants |
| Hebdomadaire (Lundi 9h) | Visio 30 min | Exploitants 2 parties |
| Bi-mensuel (Vendredi 14h) | Visio 1 h | Exploitants + chef d''exploitation |
| Mensuel (1er du mois) | Réunion physique 2 h | Direction d''exploitation 2 parties |

POINTS DE VIGILANCE M+1

- Les 4 premières semaines sont critiques
- Tolérance pour ajustements mais traçabilité de tout
- Communication transparente sur les difficultés
- Plan d''action immédiat si dérapage majeur

POINTS DE VIGILANCE M+2

- Les KPI doivent commencer à se stabiliser
- Rotation conducteurs si nécessaire
- Optimisation du parc dédié
- Vérification des procédures réelles vs documentées

POINTS DE VIGILANCE M+3

- Approche du bilan final
- Visite terrain à mi-pilote (M+1,5)
- Interview de 3-5 clients finaux concernés
- Préparation du bilan formel

BILAN FORMEL À M+3

Document de bilan structuré (10-15 pages) :

1. Synthèse exécutive (1 page)
2. Performance KPI (3 pages avec graphes)
3. Analyse qualitative (2 pages)
4. Incidents et leur traitement (2 pages)
5. Feedback clients finaux (1 page)
6. Feedback équipes internes (1 page)
7. Bilan financier (volumes, paiements) (1 page)
8. Recommandations (2 pages)
9. Décision et plan d''action (2 pages)

ARBORESCENCE DES DÉCISIONS POSSIBLES

DÉCISION A — DÉPLOIEMENT COMPLET (cas favorable)
Conditions : tous KPI cibles atteints, pas d''alerte majeure
Plan : montée à 100 % du volume sur 4 semaines
Suivi : revue mensuelle, comité trimestriel

DÉCISION B — DÉPLOIEMENT GRADUEL (cas mitigé)
Conditions : majorité des KPI atteints, 1-2 axes en amélioration
Plan : montée à 60 % du volume sur 4 semaines, puis 100 % à M+5 si KPI stables
Suivi : revue bi-mensuelle, plan d''amélioration formel

DÉCISION C — PROLONGATION DU PILOTE (cas en surveillance)
Conditions : 2-3 KPI sous cible, mais marges de progression visibles
Plan : prolongation 2 mois sur même périmètre, plan d''amélioration co-construit
Suivi : revue hebdomadaire, bilan à M+5

DÉCISION D — ARRÊT (cas défavorable)
Conditions : 3+ KPI sous cible, incidents répétés, fragilité financière
Plan : non-déploiement, préavis de fin de contrat (1 mois conformément à clause pilote)
Action : transition rapide vers solution alternative (autre sous-traitant en réserve)

DÉCISION E — ROLLBACK D''URGENCE (cas critique)
Conditions : faute grave, sinistre majeur, défaillance opérationnelle
Plan : arrêt immédiat, activation d''un plan de continuité
Action : exécution interne ou bascule sur sous-traitant existant

PLAN DE CONTINUITÉ EN CAS DE DÉCISION D OU E

Préparé EN AMONT du pilote :
- 2 sous-traitants alternatifs identifiés et déjà référencés
- Capacité de bascule sous 7-10 jours
- Sur-coût accepté en transition
- Communication clients finaux préparée

INDICATEURS DE SUCCÈS GLOBAUX DU PILOTE

À mesurer à la fin :
- 80 % des KPI atteints en M+3 = succès
- 60-80 % atteints = à débattre
- < 60 % = échec, plan B

ROI DE LA PROCÉDURE PILOTE

Coût estimé (3 mois) :
- Temps interne (exploitants, manager) : 15 000-25 000 €
- Outils et intégration : 2 000-5 000 €
- Total : 17 000-30 000 €

Bénéfice :
- Évite un mauvais déploiement complet (coût d''un sinistre majeur ou rupture : 50-200 k€)
- Réduit le risque opérationnel à long terme
- ROI : x 3-10 selon la taille du marché

LEÇONS À CAPITALISER

À chaque pilote :
- Mettre à jour les procédures avec les apprentissages
- Documenter les pièges fréquents
- Former les équipes sur les retours d''expérience
- Affiner la grille d''évaluation pour les prochains AO

Le pilote n''est pas une formalité administrative — c''est un investissement stratégique qui sécurise les choix de partenariat à long terme.'),
  (v_formation, 'qr', 'Identifiez et expliquez 6 risques majeurs liés à la sous-traitance transport, avec pour chacun : indicateurs de détection, mesures préventives et plan d''action en cas de matérialisation.', NULL, 1, 'difficile', ARRAY['risques','prevention','plan'], 'mft-2026-gotrm:bc02-01:qr:4', true, '6 RISQUES MAJEURS LIÉS À LA SOUS-TRAITANCE TRANSPORT

RISQUE 1 — COMPLICITÉ DE TRAVAIL DISSIMULÉ

Description : le sous-traitant emploie des travailleurs non déclarés ou en infraction (auto-entrepreneurs faussement indépendants, conducteurs étrangers sans détachement régulier).

Indicateurs de détection :
- DPAE incohérente avec le parc et le volume annoncé
- Refus de fournir attestations URSSAF récentes
- Conducteurs payés au noir (signalements anonymes)
- Tarifs significativement sous le marché sans justification économique
- Composition d''équipage variable (rotation suspect)

Mesures préventives :
- Vérification semestrielle (L. 8222-1) systématique
- Demande d''attestation URSSAF de vigilance < 6 mois
- Croisement DPAE et registre des conducteurs
- Audit terrain incluant rencontre conducteurs et vérification fiches de paie type
- Politique de prix cohérente avec les coûts réels (pas de prix abusivement bas)

Plan d''action si matérialisé :
- Suspension immédiate du contrat (mise en demeure 7 jours pour régularisation)
- Audit URSSAF en interne sur les 6 derniers mois
- Documentation complète pour défense
- Si confirmation : résiliation pour faute grave + déclaration aux autorités
- Sanctions encourues : 75 k€ + solidarité financière + suspension licence

RISQUE 2 — DÉFAILLANCE FINANCIÈRE DU SOUS-TRAITANT

Description : le sous-traitant rencontre des difficultés financières (perte clients, hausse coûts, mauvaise gestion) pouvant aller jusqu''à la cessation des paiements.

Indicateurs de détection :
- Bilan en perte 2 années consécutives
- Trésorerie tendue (paiements fournisseurs en retard)
- Inscription d''hypothèques ou nantissements
- Procédure d''alerte (mandat ad hoc, conciliation)
- Demandes de paiement anticipé ou de raccourcissement DSO
- Articles de presse économique négatifs

Mesures préventives :
- Vérification annuelle des bilans
- Suivi mensuel via Infogreffe (alertes inscriptions)
- Limitation des encours (engagement maximum sur le sous-traitant)
- Diversification du panel (5-10 sous-traitants par segment)
- Garantie financière incluse dans le contrat

Plan d''action si matérialisé :
- Activation du plan de continuité (sous-traitants alternatifs)
- Sécurisation des paiements (pas de paiement anticipé)
- Clauses de continuité négociées (mainmise sur les commandes en cours)
- Communication transparente aux clients finaux concernés
- Documentation pour défense en cas de demande de paiement direct

RISQUE 3 — CASCADE DE SOUS-TRAITANCE NON DÉCLARÉE

Description : le sous-traitant délègue à son tour une partie ou l''intégralité de la mission à un autre opérateur sans déclaration au donneur d''ordre principal.

Indicateurs de détection :
- Véhicules avec une raison sociale autre que celle du sous-traitant
- Conducteurs non listés dans les DPAE du sous-traitant
- Numéro de téléphone des conducteurs ne correspondant pas au sous-traitant officiel
- Échanges électroniques avec une autre entreprise
- Témoignages clients finaux (« le conducteur ne connaissait pas votre nom »)

Mesures préventives :
- Clause contractuelle stricte sur la cascade (article L. 3221-3)
- Audit terrain régulier (visite des locaux, parc, conducteurs)
- Croisement permanent des conducteurs effectifs et des DPAE
- Tracking GPS sur tous les véhicules pour vérifier la cohérence
- Engagement écrit du sous-traitant à toute occasion

Plan d''action si matérialisé :
- Mise en demeure formelle (15 jours pour régulariser)
- Si pas de régularisation : résiliation pour faute grave
- Information des clients finaux concernés
- Documentation complète (preuves, dates, témoignages)
- Possibilité de saisine de la DREAL pour suspension de la licence

RISQUE 4 — DÉGRADATION DE LA QUALITÉ DE SERVICE

Description : le sous-traitant ne tient pas ses engagements de qualité (ponctualité, intégrité, communication), affectant l''image du donneur d''ordre auprès du client final.

Indicateurs de détection :
- Évolution dégradée des KPI (ponctualité, intégrité)
- Augmentation du nombre de litiges
- Plaintes clients finaux récurrentes
- Réactivité dégradée aux incidents
- Turnover élevé chez le sous-traitant (perte de compétences)

Mesures préventives :
- SLA chiffrés contractuels avec pénalités progressives
- Reporting mensuel détaillé
- Comité de pilotage trimestriel
- Visite terrain semestrielle
- Plan d''amélioration formalisé en cas de dérapage

Plan d''action si matérialisé :
- Réunion d''alerte sous 5 jours (présentation des écarts)
- Plan d''amélioration co-construit avec échéances
- Application progressive des pénalités contractuelles
- Surveillance hebdomadaire pendant 2-3 mois
- Si pas d''amélioration : préparation de l''alternative et résiliation

RISQUE 5 — ACCIDENT GRAVE OU SINISTRE MAJEUR

Description : un accident impliquant le sous-traitant a des conséquences graves (humaines, matérielles, environnementales) avec impact sur le donneur d''ordre.

Indicateurs de détection :
- Politique sécurité du sous-traitant peu documentée
- Conducteurs sans formation continue récente
- Parc vieillissant (> 8 ans en moyenne)
- Statistiques accidents du travail élevées
- Procédure de gestion d''incident absente ou floue

Mesures préventives :
- Vérification du TF (taux de fréquence) accidents
- Politique de sécurité contractuelle (formations, équipements)
- Assurance RC pro adaptée au risque
- Audit annuel des procédures sécurité
- Intégration aux exercices de simulation d''incidents

Plan d''action si matérialisé :
- Activation immédiate de la cellule de crise
- Coordination avec autorités, assurances et médias
- Communication client final transparente et anticipée
- Soutien au sous-traitant dans la gestion (sans engager juridiquement)
- Bilan post-incident pour ajuster les procédures

RISQUE 6 — RUPTURE BRUTALE DE LA COLLABORATION

Description : le sous-traitant ou le donneur d''ordre rompt unilatéralement la collaboration sans préavis raisonnable, créant une situation d''urgence.

Indicateurs de détection :
- Tensions répétées dans les échanges
- Plaintes du sous-traitant sur les conditions
- Concurrents qui démarchent activement le sous-traitant
- Signaux financiers d''une partie ou de l''autre
- Changement de management majeur

Mesures préventives :
- Contrat avec préavis explicite (6 mois standard)
- Clauses de continuité (achèvement des missions en cours)
- Plan de continuité en réserve (sous-traitant alternatif)
- Diversification du panel (pas de dépendance > 30 % sur un sous-traitant)
- Communication régulière pour anticiper les tensions

Plan d''action si matérialisé :
- Vérification de la conformité au contrat (préavis, motifs)
- Si rupture abusive : recours juridique (mise en demeure, dommages-intérêts)
- Activation du plan de continuité (transition vers alternatif)
- Communication aux clients finaux pour préserver la relation
- Capitalisation sur l''expérience pour renforcer les contrats futurs

CARTOGRAPHIE GLOBALE DES RISQUES

| Risque | Probabilité | Impact | Niveau global |
|---|---|---|---|
| Travail dissimulé | Faible-Moyen | Très élevé | 🟧 |
| Défaillance financière | Moyen | Élevé | 🟧 |
| Cascade non déclarée | Faible-Moyen | Élevé | 🟧 |
| Dégradation qualité | Élevé | Moyen | 🟧 |
| Accident grave | Faible | Très élevé | 🟧 |
| Rupture brutale | Moyen | Moyen | 🟢 |

PILOTAGE GLOBAL DU RISQUE

- Tableau de bord risques mis à jour mensuellement
- Revue trimestrielle en comité de pilotage
- Audit annuel de chaque sous-traitant clé
- Bilan annuel global des incidents pour ajuster les procédures
- Formation continue des équipes sur les obligations légales

Sans gestion proactive de ces risques, la sous-traitance peut transformer un avantage économique en source de difficultés majeures. Avec un cadre rigoureux, elle reste un levier puissant de flexibilité et de compétitivité.');


  -- =================================================================
  -- QUIZZES
  -- =================================================================
  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_1, 'Quiz — Cadre juridique sous-traitance', 'gotrm-bc02-01-quiz-01', 'Loi 1975, vérifications L. 8222-1, prix abusivement bas, cascade.', 70, NULL, false, 1)
  RETURNING id INTO v_quiz_1;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc02-01:qcm:1','mft-2026-gotrm:bc02-01:qcm:2','mft-2026-gotrm:bc02-01:qcm:3','mft-2026-gotrm:bc02-01:qcm:4','mft-2026-gotrm:bc02-01:qcm:5','mft-2026-gotrm:bc02-01:qcm:6','mft-2026-gotrm:bc02-01:qcm:7','mft-2026-gotrm:bc02-01:qcm:8','mft-2026-gotrm:bc02-01:qcm:19');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_2, 'Quiz — Construire un AO', 'gotrm-bc02-01-quiz-02', '6 étapes, cahier des charges, pondération critères, calendrier.', 70, NULL, false, 2)
  RETURNING id INTO v_quiz_2;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc02-01:qcm:9','mft-2026-gotrm:bc02-01:qcm:10','mft-2026-gotrm:bc02-01:qcm:11','mft-2026-gotrm:bc02-01:qcm:18','mft-2026-gotrm:bc02-01:qcm:20');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_3, 'Quiz — Évaluer et sélectionner', 'gotrm-bc02-01-quiz-03', '5 axes, visite terrain, signaux faibles, panel.', 70, NULL, false, 3)
  RETURNING id INTO v_quiz_3;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc02-01:qcm:12','mft-2026-gotrm:bc02-01:qcm:13','mft-2026-gotrm:bc02-01:qcm:14','mft-2026-gotrm:bc02-01:qcm:22','mft-2026-gotrm:bc02-01:qcm:23','mft-2026-gotrm:bc02-01:qcm:24');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_4, 'Quiz — Contrat et démarrage', 'gotrm-bc02-01-quiz-04', 'Clauses contractuelles, RPC, pilote, rituels, résiliation.', 70, NULL, false, 4)
  RETURNING id INTO v_quiz_4;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc02-01:qcm:15','mft-2026-gotrm:bc02-01:qcm:16','mft-2026-gotrm:bc02-01:qcm:17','mft-2026-gotrm:bc02-01:qcm:21','mft-2026-gotrm:bc02-01:qcm:25');

  INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, NULL, 'Examen blanc — BC02-01 AO sous-traitance', 'gotrm-bc02-01-examen-blanc', '12 QCM en 25 min, seuil 50 %.', 50, 25, true, 5)
  RETURNING id INTO v_quiz_eb;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc02-01:qcm:1','mft-2026-gotrm:bc02-01:qcm:3','mft-2026-gotrm:bc02-01:qcm:4','mft-2026-gotrm:bc02-01:qcm:6','mft-2026-gotrm:bc02-01:qcm:9','mft-2026-gotrm:bc02-01:qcm:11','mft-2026-gotrm:bc02-01:qcm:12','mft-2026-gotrm:bc02-01:qcm:14','mft-2026-gotrm:bc02-01:qcm:15','mft-2026-gotrm:bc02-01:qcm:16','mft-2026-gotrm:bc02-01:qcm:20','mft-2026-gotrm:bc02-01:qcm:21');

  RAISE NOTICE '✅ GOTRM BC02-01 v2 chargé : 4 leçons, 25 QCM, 4 QR, 5 quizzes (4 entraînement + 1 examen blanc).';
END
$bc02_01$;
