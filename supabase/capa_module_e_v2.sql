-- =====================================================================
-- MODULE E — L'ENTREPRISE ET SES SALARIÉS (Capacité ≤ 3,5 T)
-- Version 2 (mai 2026) — refonte complète depuis PDF officiels.
--
-- Référentiel (décision du 2 avril 2012) : 10 QCM (20 pts) + 3 QR (30 pts)
-- = 50 points sur 84. 2e plus gros coefficient de l'examen national.
--
-- ▸ 4 leçons (sources sociales / contrat de travail / durée et rémunération
--   / IRP et conditions de travail)
-- ▸ 35 QCM reformulés (préfixe mft-2026:moduleE:qcm:N)
-- ▸ 6 QR transport (max_score 5)
-- ▸ Quizzes par leçon + 1 examen blanc
-- =====================================================================

DO $module_e_v2$
DECLARE
  v_formation uuid; v_bloc int; v_module uuid;
  v_lesson_1 uuid; v_lesson_2 uuid; v_lesson_3 uuid; v_lesson_4 uuid;
  v_quiz_1 uuid; v_quiz_2 uuid; v_quiz_3 uuid; v_quiz_4 uuid; v_quiz_eb uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'capacite-3-5t';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation capacite-3-5t introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc.'; END IF;

  DELETE FROM public.modules WHERE slug = 'capa-salaries-droit-social';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Module E — L''entreprise et ses salariés',
    'capa-salaries-droit-social', v_bloc,
    'Maîtriser les sources du droit social du transport, le contrat de travail (du recrutement à la rupture), la durée du travail et la rémunération, ainsi que les institutions représentatives du personnel.',
    'avance', 200, 50
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 50, true) ON CONFLICT DO NOTHING;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026:moduleE:%';

  -- =================================================================
  -- LEÇON 1 — Sources sociales et institutions
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Les sources du droit social et les institutions', 'sources-sociales-institutions',
    1, 50,
$lesson1$
# Les sources du droit social et les institutions

Le droit social du transport repose sur une **hiérarchie** de textes (du plus général au plus spécifique) et un **écosystème d'institutions** que tout dirigeant doit connaître pour rester en conformité.

> 🎯 **Objectifs de la leçon**
>
> - Maîtriser la **hiérarchie des sources** (Code du travail → CCNTRAAT → règlement intérieur).
> - Identifier les **affichages et registres obligatoires**.
> - Connaître la **CCNTRAAT** et ses 7 annexes.
> - Identifier les **principales institutions** (médecine du travail, URSSAF, CARCEPT, France Travail, inspection du travail).

---

## 1. La hiérarchie des sources sociales

### 1.1 Du plus général au plus spécifique

| # | Niveau | Exemples |
|---|---|---|
| 1 | **Sources internationales** | Conventions OIT, conventions européennes |
| 2 | **Sources nationales générales** | Code du travail, Code des transports, Code de la Sécurité sociale, arrêtés, décrets, ordonnances |
| 3 | **Sources conventionnelles** | **CCNTRAAT** (Convention Collective Nationale des Transports Routiers et Activités Auxiliaires du Transport) |
| 4 | **Accords d'entreprise / d'établissement** | Négociés au niveau de l'entreprise |
| 5 | **Règlement intérieur** | Rédigé par l'employeur |
| 6 | **Contrat de travail** | Individuel, salarié par salarié |

> 📌 **Principe de faveur**
>
> En droit social, **un texte inférieur peut déroger à un texte supérieur uniquement si c'est plus favorable au salarié**. Une CC ne peut pas réduire les droits prévus par le Code du travail.

### 1.2 La CCNTRAAT

> Convention collective qui régit les **conditions de travail** dans les transports routiers et activités auxiliaires.

**Structure** :

| Partie | Contenu |
|---|---|
| **CCNP** (Convention Collective Nationale Principale) | Clauses communes : durée du travail, congés, conditions d'emploi |
| **CCNA1** | Annexe 1 : Ouvriers |
| **CCNA2** | Annexe 2 : Employés |
| **CCNA3** | Annexe 3 : Techniciens et agents de maîtrise |
| **CCNA4** | Annexe 4 : Ingénieurs et cadres |
| **CCNA5** | Annexe 5 : Régime de retraite et de prévoyance |
| **CCNA6** | Annexe 6 : Participation des salariés aux résultats |
| **CCNA7** | Annexe 7 : Formation professionnelle et emploi |

> 💡 **Obligation d'affichage**
>
> La CCNTRAAT doit être affichée dans l'entreprise + un exemplaire à la disposition du personnel + un exemplaire remis au CSE. La référence figure également sur le **bulletin de paie**.

### 1.3 Le règlement intérieur

| Critère | Détail |
|---|---|
| **Obligatoire à partir de** | **50 salariés** sur 12 mois consécutifs |
| **Rédigé par** | L'employeur |
| **Contenu obligatoire** | Discipline, sanctions, hygiène/sécurité, harcèlement, lanceurs d'alerte |
| **Procédure** | Consultation CSE → DREETS → greffe Prud'hommes → publication |
| **Entrée en vigueur** | **1 mois** après accomplissement des formalités |

---

## 2. Affichages et registres obligatoires

### 2.1 Les principaux affichages

| Affichage | Détail |
|---|---|
| **Convention collective** | CCNTRAAT applicable |
| **Horaires de travail** | Heures de début et fin, pauses |
| **Repos hebdomadaire** | Jour habituel |
| **Coordonnées de l'inspection du travail (DREETS)** | Adresse + téléphone |
| **Coordonnées du médecin du travail** | Service auquel l'entreprise adhère |
| **Coordonnées des secours** | SAMU, pompiers, police |
| **Égalité professionnelle** | Hommes / femmes |
| **Lutte contre les discriminations** | Affiche obligatoire |
| **Harcèlement moral et sexuel** | Sanctions encourues |
| **Représentants du personnel** | CSE et syndicats |
| **Document Unique d'Évaluation des Risques Professionnels (DUERP)** | Mention obligatoire de sa mise à jour |

### 2.2 Les registres obligatoires

| Registre | Cible |
|---|---|
| **Registre unique du personnel (RUP)** | Toute entreprise dès le 1er salarié |
| **Registre médical** | Suivi médical |
| **Registre des accidents du travail** | Si DRH et CHSCT |
| **Registre des observations de l'inspection du travail** | Toutes entreprises |
| **Registre du DUERP** | Pour la mise à jour annuelle |

> ⚠️ **Sanctions du travail dissimulé**
>
> Le défaut de déclaration préalable à l'embauche (DPAE), de bulletin de paie ou la non-inscription au registre du personnel constituent un **délit de travail dissimulé**, sanctionné de **3 ans de prison** et **45 000 € d'amende** (224 000 € pour personne morale).

---

## 3. Les institutions sociales

| Institution | Rôle | Mission clé |
|---|---|---|
| **URSSAF** | Recouvrement des cotisations | Déclarations sociales mensuelles ou trimestrielles |
| **Médecine du travail** | Prévention santé au travail | VIP à l'embauche (3 mois), visite mi-carrière |
| **CARCEPT** | Régime spécifique transport | Retraite complémentaire, prévoyance, action sociale |
| **France Travail** | Anciennement Pôle Emploi | Accompagnement chômeurs + recrutements |
| **Inspection du travail (DREETS)** | Contrôle du droit du travail | Visites entreprise, mise en demeure, PV |
| **Sécurité sociale** | Régime général | Maladie, maternité, AT/MP, retraite de base |

### 3.1 La médecine du travail

| Action | Détail |
|---|---|
| **VIP** (Visite d'Information et de Prévention) | Obligatoire dans les **3 mois** suivant l'embauche |
| **Visite mi-carrière** | À 45 ans environ |
| **Visite de reprise** | Après arrêt > 30 jours |
| **Visite à la demande** | Salarié, employeur, médecin |

> 📌 **Indépendance**
>
> Le médecin du travail a un rôle **exclusivement préventif**. Il ne soigne pas, il prévient et conseille.

### 3.2 L'URSSAF

Recouvre les cotisations sociales (≈ 42 % du brut côté employeur, 22 % côté salarié). Déclarations via la **DSN** (Déclaration Sociale Nominative) mensuelle.

### 3.3 La CARCEPT (Caisse Autonome de Retraites Complémentaires et de Prévoyance du Transport)

| Caisse | Rôle |
|---|---|
| **CARCEPT-Prévoyance** | Prévoyance des transporteurs |
| **CARCEPT Retraite** | Retraite complémentaire AGIRC-ARRCO |

Adhésion **obligatoire** pour toute entreprise du transport routier.

### 3.4 L'inspection du travail (DREETS depuis 2021)

> Les DIRECCTE sont devenues **DREETS** (Directions Régionales de l'Économie, de l'Emploi, du Travail et des Solidarités) depuis avril 2021.

**Pouvoirs** :
- Visites inopinées sans préavis
- Demande de documents (contrats, DSN, bulletins de paie)
- Mises en demeure et PV
- Saisie du tribunal correctionnel ou prud'homal

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| Hiérarchie des sources sociales | Internationales > Nationales > Conventionnelles > Accords entreprise > RI > Contrat |
| Convention collective du transport | **CCNTRAAT** (CCNP + 7 annexes) |
| Annexe 1 CCNA1 | **Ouvriers** |
| Règlement intérieur obligatoire | À partir de **50 salariés** sur 12 mois |
| VIP médecin du travail | Dans les **3 mois** après embauche |
| Caisse spécifique transport | **CARCEPT** |
| Sanction travail dissimulé | **3 ans de prison + 45 000 €** |
| Inspection du travail (depuis 2021) | **DREETS** |
| Registre obligatoire dès 1 salarié | Registre Unique du Personnel (RUP) |
$lesson1$,
'Hiérarchie des sources, CCNTRAAT (CCNP + 7 annexes), règlement intérieur, affichages et registres, institutions (URSSAF, CARCEPT, médecine du travail, DREETS).'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Le contrat de travail
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Le contrat de travail : embauche, vie, rupture', 'contrat-de-travail',
    2, 60,
$lesson2$
# Le contrat de travail : embauche, vie, rupture

De l'embauche à la rupture, le contrat de travail rythme la vie du salarié. Vous devez maîtriser les types de contrats, la période d'essai, les motifs de suspension et les modes de rupture pour rester en conformité.

> 🎯 **Objectifs de la leçon**
>
> - Connaître les **règles d'embauche** (DPAE, contrat écrit, délais).
> - Distinguer les **types de contrats** (CDI, CDD, intérim, apprentissage, professionnalisation).
> - Maîtriser la **période d'essai** et son renouvellement.
> - Identifier les modes de **suspension** et de **rupture** du contrat.
> - Connaître la procédure **prud'homale**.

---

## 1. L'embauche

### 1.1 Les obligations de l'employeur

| Obligation | Délai | Sanction |
|---|---|---|
| **DPAE** (Déclaration Préalable À l'Embauche) | **8 jours avant** l'embauche, ou au plus tard le jour même | Travail dissimulé |
| **Visite d'information et de prévention** (VIP) | Dans les **3 mois** | Mise en demeure DREETS |
| **Inscription au registre unique du personnel** | Dès l'embauche | Travail dissimulé |
| **Bulletin de paie** | Mensuel | Sanctions civiles et pénales |
| **Contrat de travail écrit** | Obligatoire pour CDD et temps partiel — recommandé pour CDI | Requalification CDD → CDI |

> 📌 **DPAE = "ex-DUE"**
>
> Déclaration unique combinant immatriculation Sécu, médecin du travail, URSSAF. Accessible sur `urssaf.fr` ou `net-entreprises.fr`.

### 1.2 Le contrat de travail : éléments fondamentaux

3 conditions cumulatives :
- **Prestation de travail** effective
- **Rémunération**
- **Lien de subordination** (l'employeur exerce un pouvoir de direction et de sanction)

---

## 2. Les types de contrats

### 2.1 Le CDI (Contrat à Durée Indéterminée)

| Caractéristique | Détail |
|---|---|
| Durée | Indéterminée (norme générale) |
| Forme | Écrit recommandé, mais oral possible (ce qui est rare) |
| Rupture | Démission, licenciement, rupture conventionnelle, retraite, décès |

### 2.2 Le CDD (Contrat à Durée Déterminée)

> Doit être **EXCLUSIVEMENT** justifié par un **motif** précis (article L. 1242-1 C. trav.).

| Motif autorisé | Durée maximale (renouvellement inclus) |
|---|---|
| **Remplacement d'un salarié absent** | Jusqu'au retour du salarié remplacé |
| **Accroissement temporaire d'activité** | **18 mois** max (24 mois en cas d'export) |
| **Travail saisonnier** | 8 mois maximum |
| **Emploi à caractère temporaire d'usage** | Variable selon secteur |

> ⚠️ **Sanctions de l'usage abusif**
>
> Un CDD non justifié, mal rédigé, ou utilisé pour pourvoir un emploi durable → **requalification en CDI** par le Conseil des prud'hommes.

#### Mentions obligatoires d'un CDD écrit

- Motif du recours au CDD
- Date de début et de fin
- Durée minimale (si pas de date précise)
- Période d'essai
- Identité de la personne remplacée (si remplacement)
- Convention collective applicable

### 2.3 La période d'essai

> Période durant laquelle l'employeur **et** le salarié peuvent rompre le contrat sans motif ni indemnité (sauf préavis de rupture).

| Type de salarié | Durée initiale | Renouvellement (max 1 fois) | Durée totale max |
|---|---|---|---|
| **Ouvrier / Employé** | 2 mois | 2 mois | **4 mois** |
| **Agent de maîtrise / Technicien** | 3 mois | 3 mois | **6 mois** |
| **Cadre** | 4 mois | 4 mois | **8 mois** |

> 📌 **Préavis de rupture en cours d'essai**
>
> | Présence | Préavis si rupture par employeur | Préavis si rupture par salarié |
> |---|---|---|
> | < 8 jours | 24 h | 24 h |
> | 8 jours à 1 mois | 48 h | 48 h |
> | 1 à 3 mois | 2 semaines | 48 h |
> | > 3 mois | 1 mois | 48 h |

### 2.4 Autres contrats

| Contrat | Spécificité |
|---|---|
| **Intérim** | Triangulaire : entreprise utilisatrice + agence d'intérim + salarié |
| **Apprentissage** | Jeune 16-29 ans, alternance école/entreprise, 1-3 ans |
| **Professionnalisation** | Adultes ou jeunes 16-25 ans, alternance, 6-24 mois |
| **Temps partiel** | Durée < 35h hebdo (ou < à la durée applicable dans l'entreprise) |

---

## 3. La suspension du contrat

### 3.1 Les principales causes

| Cause | Effet sur le contrat | Maintien de salaire |
|---|---|---|
| **Maladie** | Suspension | IJSS Sécu + complément employeur (selon ancienneté) |
| **Accident du travail / MP** | Suspension | IJSS majorées + complément employeur |
| **Maternité / Paternité** | Suspension | IJSS + souvent compléments |
| **Congés payés** | Suspension | Indemnité de congés payés |
| **Mise à pied conservatoire** | Suspension | Pas de salaire |
| **Grève** | Suspension | Pas de salaire (sauf accord) |
| **Congé parental** | Suspension | Pas de salaire (mais éventuelles allocations) |

> 📌 **Pendant la suspension**
>
> Le contrat est gelé : le salarié ne travaille pas, n'est pas rémunéré (sauf indemnités), mais il reste dans les effectifs et son ancienneté continue de courir (sauf cas spécifiques).

---

## 4. La rupture du contrat

### 4.1 La démission (initiative du salarié)

- Acte **clair et non équivoque**
- Préavis variable (1-3 mois selon CCNTRAAT)
- Pas d'indemnité (sauf droits acquis)

### 4.2 Le licenciement (initiative de l'employeur)

| Type | Cause | Indemnité |
|---|---|---|
| **Personnel** | Faute (simple, grave, lourde) ou insuffisance professionnelle | Selon faute |
| **Économique** | Difficultés économiques, mutations technologiques, sauvegarde | Indemnité légale + préavis |

#### Procédure de licenciement personnel

1. **Convocation à l'entretien préalable** par lettre recommandée (5 jours min avant)
2. **Entretien préalable** (le salarié peut être assisté)
3. **Notification du licenciement** (par LRAR, après 2 jours min)
4. **Préavis** (sauf faute grave / lourde)
5. **Remise des documents de fin de contrat** : certificat de travail, attestation France Travail, reçu pour solde de tout compte

#### Indemnités légales de licenciement

> Article L. 1234-9 du Code du travail.
>
> Calcul : **1/4 de mois × ancienneté en années** jusqu'à 10 ans, puis **1/3 de mois × ancienneté** au-delà de 10 ans.

> 🚛 **Exemple**
>
> Un chauffeur licencié après 12 ans d'ancienneté avec un salaire mensuel de 2 200 €.
> - Pour les 10 premières années : (2 200 / 4) × 10 = 5 500 €
> - Pour les 2 années suivantes : (2 200 / 3) × 2 = 1 467 €
> - **Total = 6 967 €** d'indemnité légale minimale

### 4.3 La rupture conventionnelle

> Mode de rupture **amiable** (créé en 2008) où employeur et salarié s'accordent.

| Étape | Détail |
|---|---|
| 1. Entretien | Au moins un (le salarié peut être assisté) |
| 2. Convention | Signée par les deux parties |
| 3. **Délai de rétractation** | **15 jours calendaires** |
| 4. Homologation | Demande à la DREETS, qui dispose de **15 jours ouvrables** |
| 5. Rupture | Date convenue dans la convention |

**Indemnité** : au moins égale à l'indemnité légale de licenciement.

> ⚠️ **Pas de rupture conventionnelle pendant**
>
> Une période de protection (maternité, accident du travail, harcèlement…). Risque de nullité.

### 4.4 Le Conseil des prud'hommes

> Juridiction qui tranche les **litiges individuels** entre employeur et salarié relatifs au contrat de travail.

| Caractéristique | Détail |
|---|---|
| Composition | Juges **non professionnels** : 4 conseillers (2 employeurs + 2 salariés) |
| Procédure | 1. Bureau de conciliation (BCO) → 2. Bureau de jugement (BJ) si pas d'accord |
| Avocat | **Non obligatoire** |
| Recours | Cour d'appel (litige > 5 000 €) puis Cour de cassation |
| Compétence territoriale | Lieu de l'entreprise OU domicile du salarié |

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| Délai DPAE | **8 jours avant** ou jour même de l'embauche |
| Période d'essai ouvrier max | **4 mois** (2 + renouvellement 2) |
| Période d'essai cadre max | **8 mois** (4 + renouvellement 4) |
| CDD durée max | **18 mois** (renouvellements inclus) |
| Procédure licenciement | Convocation → Entretien (5 j min après) → Notification (2 j min) → Préavis |
| Indemnité légale licenciement | 1/4 mois/an jusqu'à 10 ans, puis 1/3 mois/an |
| Délai rétractation rupture conventionnelle | **15 jours calendaires** |
| Délai homologation DREETS | **15 jours ouvrables** |
| Composition prud'hommes | 2 conseillers employeurs + 2 conseillers salariés |
| Étape 1 prud'hommes | Bureau de **conciliation** |
$lesson2$,
'DPAE 8 j, période d''essai (4/6/8 mois), CDD (18 mois max + motif), licenciement (procédure 5+2 j), rupture conventionnelle (rétractation 15 j), prud''hommes (BCO + BJ).'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Durée du travail et rémunération
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Durée du travail et rémunération', 'duree-travail-remuneration',
    3, 50,
$lesson3$
# Durée du travail et rémunération

Le transport routier a un régime spécifique en matière de durée du travail (Code des transports), différent du droit commun (Code du travail). C'est un point CHAUD à l'examen et au quotidien.

> 🎯 **Objectifs de la leçon**
>
> - Distinguer **durée du travail sédentaire** vs **personnel roulant**.
> - Maîtriser les **heures supplémentaires** et leurs majorations.
> - Connaître les règles du **travail à temps partiel** et de **nuit**.
> - Calculer une **paie** : rémunération + congés payés + mensualisation.

---

## 1. La durée légale du travail

### 1.1 Personnel sédentaire (Code du travail)

| Élément | Durée |
|---|---|
| **Durée légale** | **35 heures** par semaine |
| **Durée maximale journalière** | **10 heures** (12 h en cas d'urgence avec accord) |
| **Durée maximale hebdomadaire** | **48 h** (44 h sur 12 semaines consécutives) |
| **Repos quotidien** | **11 heures** consécutives |
| **Repos hebdomadaire** | **35 heures** consécutives (24 h + 11 h de repos quotidien) |

### 1.2 Personnel roulant (Code des transports)

> **Spécificité transport** : règles dérogatoires au Code du travail, encadrées par le Code des transports + règlement européen R561/2006.

| Élément | Durée |
|---|---|
| **Durée hebdomadaire de service** (équivalent semaine sédentaire) | **52 heures** maximum (48 h en moyenne sur 4 mois) |
| **Durée maximale journalière de conduite** | **9 heures** (10 h max 2x/semaine) |
| **Durée maximale hebdomadaire de conduite** | **56 h sur une semaine, 90 h sur 2 semaines** |
| **Repos quotidien** | **11 heures** (réductible à 9 h max 3x/semaine) |
| **Pause obligatoire** | **45 minutes** après 4 h 30 de conduite (en 2 fois min 15 + 30 min) |
| **Repos hebdomadaire normal** | **45 heures** consécutives |
| **Repos hebdomadaire réduit** | **24 heures** (récupération obligatoire dans les 3 semaines) |

> 📌 **Coursiers et personnel < 3,5 t**
>
> Pour les conducteurs de véhicules ≤ 3,5 t en transport pour compte d'autrui, le règlement R561/2006 ne s'applique pas systématiquement (sous certaines conditions). Mais la CCNTRAAT et le Code du travail restent applicables. Les règles d'amplitude et de pauses sont à vérifier au cas par cas.

---

## 2. Les heures supplémentaires

### 2.1 Définition

> Heures effectuées **au-delà de la durée légale** (35 h/semaine pour sédentaire, 39 h forfait possible).

### 2.2 Majorations

| Heures sup | Majoration |
|---|---|
| **De la 36e à la 43e h** (8 premières) | **+25 %** |
| **À partir de la 44e h** | **+50 %** |

> 📌 **Contingent annuel**
>
> Les heures supplémentaires sont limitées à un **contingent annuel** (220 h par défaut, modifiable par accord). Au-delà, elles ouvrent droit à une **contrepartie obligatoire en repos**.

### 2.3 Paiement vs repos compensateur

L'entreprise peut **remplacer le paiement** des heures sup par un **repos équivalent** (1 h sup à +25 % = 1 h 15 min de repos).

---

## 3. La rémunération

### 3.1 Le SMIC et la mensualisation

| Concept | Détail |
|---|---|
| **SMIC horaire 2026** | À ajuster selon le taux en vigueur |
| **Mensualisation** | Salaire **lissé sur 12 mois** indépendamment du nombre exact de jours / heures travaillés dans le mois |
| **Calcul** | Salaire mensuel = (Taux horaire × 35 × 52) / 12 = Taux × 151,67 h |

> 💡 **Pourquoi mensualiser ?**
>
> Pour garantir un revenu régulier au salarié et simplifier la paie. Le salaire est le même quel que soit le nombre exact de jours travaillés dans le mois (28 ou 31).

### 3.2 Les composantes de la rémunération

| Composante | Détail |
|---|---|
| **Salaire de base** | Au moins SMIC ou rémunération conventionnelle (CCNTRAAT) |
| **Heures supplémentaires** | Avec majoration |
| **Primes** | De panier, de route, de qualité, d'ancienneté, de productivité |
| **Frais de route** | Repas, hébergement (barème URSSAF) |
| **Avantages en nature** | Véhicule de fonction, repas, logement |

### 3.3 Indemnité de congés payés

> Tout salarié a droit à **2,5 jours ouvrables de congés payés par mois travaillé**, soit **30 jours ouvrables par an** (5 semaines).

#### Calcul (méthode du 1/10e)

> **Indemnité de congés = 1/10e de la rémunération brute totale perçue durant la période de référence (1er juin N-1 au 31 mai N)**.

#### Calcul (méthode du maintien de salaire)

> Le salarié perçoit pendant ses congés ce qu'il aurait perçu en travaillant.

> 📌 **Règle du plus favorable**
>
> L'employeur applique la **méthode la plus favorable au salarié** pour chaque période de congés.

### 3.4 Frais et indemnités

| Indemnité | Cible |
|---|---|
| **Indemnité de panier** | Repas pris à l'extérieur (8 € en 2026 environ, à ajuster) |
| **Indemnité de grand déplacement** | Découcher (≈ 70 €/nuit, barème URSSAF) |
| **Frais de transport domicile-travail** | 50 % minimum des abonnements de transport public |

---

## 4. Le travail à temps partiel et le travail de nuit

### 4.1 Temps partiel

| Critère | Détail |
|---|---|
| **Définition** | Durée < à la durée légale (35 h) ou conventionnelle |
| **Durée minimale** | **24 h hebdomadaires** sauf dérogations (étudiants, multi-employeurs, demande écrite du salarié) |
| **Mentions obligatoires** | Durée hebdo, répartition, modalités d'heures complémentaires |
| **Heures complémentaires** | Limitées à **1/10e** (ou 1/3 par accord) de la durée contractuelle |

### 4.2 Travail de nuit du personnel roulant

> Tout travail effectué **entre 21 h et 6 h** est considéré comme travail de nuit (article L. 3122-29 C. trav.).

#### Spécificités transport

| Type de personnel | Plage horaire de nuit |
|---|---|
| **Personnel roulant marchandises** | **21 h - 6 h** (9 h consécutives entre 21 h et 7 h) |
| **Coursiers** | Idem droit commun |

#### Compensations

- **Majoration salariale** ≥ 20 % du taux horaire (souvent ≥ 30 % en transport)
- **Repos compensateur** obligatoire
- **Surveillance médicale renforcée**
- Durée maximale : **8 h** par poste de nuit (10 h sur dérogation)

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| Durée légale sédentaire | **35 h** / semaine |
| Durée maximale journalière | **10 h** (12 h dérogation) |
| Durée maximale hebdomadaire | **48 h** (44 h sur 12 semaines) |
| Conduite max journalière personnel roulant | **9 h** (10 h max 2x/sem) |
| Pause après 4 h 30 de conduite | **45 minutes** |
| Repos quotidien minimum | **11 h** consécutives |
| Repos hebdomadaire normal | **45 h** consécutives |
| Heures sup 36e à 43e h | **+25 %** |
| Heures sup à partir de la 44e h | **+50 %** |
| Mensualisation | **151,67 h/mois** (35 × 52 / 12) |
| Congés payés / mois travaillé | **2,5 jours ouvrables** |
| Travail de nuit | **21 h - 6 h** |
| Temps partiel durée minimale | **24 h hebdo** |
$lesson3$,
'35 h légales (sédentaire), 9 h conduite max + 45 min pause après 4 h 30 + 11 h repos quotidien (roulant), heures sup +25 %/+50 %, mensualisation 151,67 h, 2,5 j CP/mois.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Représentation du personnel et conditions de travail
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Représentation du personnel et conditions de travail', 'irp-conditions-travail',
    4, 40,
$lesson4$
# Représentation du personnel et conditions de travail

Au-delà de 11 salariés, la mise en place du CSE devient obligatoire. Et bien avant, vous avez des obligations en matière de **prévention des risques** et de **conditions de travail** que tout dirigeant doit anticiper.

> 🎯 **Objectifs de la leçon**
>
> - Comprendre les **seuils** de mise en place du CSE.
> - Distinguer **CSE**, **délégué syndical**, **délégué du personnel**.
> - Maîtriser le **DUERP** (Document Unique d'Évaluation des Risques Professionnels).
> - Connaître les obligations en matière de **sécurité et hygiène au travail**.

---

## 1. Le Comité Social et Économique (CSE)

> Instance unique de représentation du personnel depuis 2018, fusionne les anciens CE, DP et CHSCT.

### 1.1 Seuils de mise en place

| Effectif | CSE obligatoire ? | Compétences |
|---|---|---|
| **< 11 salariés** | Non | Pas d'instance obligatoire |
| **11 à 49 salariés** | **OUI** | Réclamations individuelles et collectives, hygiène/sécurité |
| **≥ 50 salariés** | **OUI étendu** | + attribution économique (consultation sur orientations stratégiques, ...) |

### 1.2 Calcul de l'effectif

> L'effectif s'apprécie sur les **12 derniers mois**, en équivalents temps plein.

| Type de salarié | Compte pour |
|---|---|
| **CDI temps plein** | 1 |
| **CDD non remplaçant** | Au prorata du temps présent |
| **Temps partiel** | Au prorata du temps de travail |
| **Apprentis / contrats pro** | **Hors effectif** |

### 1.3 Élections du CSE

| Étape | Délai |
|---|---|
| Information du personnel | Affichage **90 jours avant** le 1er tour |
| Négociation du protocole | Avec les syndicats représentatifs |
| 1er tour | Réservé aux candidats syndiqués (10 %) |
| 2nd tour | Si quorum non atteint au 1er tour, ouvert à tous |
| Mandat | **4 ans** (3 mandats successifs maximum) |

### 1.4 Heures de délégation

| Effectif | Heures par mois et par titulaire |
|---|---|
| **11-49** | **10 h** |
| **50-74** | **18 h** |
| **75-99** | **19 h** |
| **100+** | **22 h** + |

---

## 2. Les syndicats et délégués syndicaux

### 2.1 Représentativité

| Syndicat | Conditions de représentativité |
|---|---|
| **Au niveau de l'entreprise** | Avoir obtenu ≥ 10 % des suffrages aux dernières élections CSE |
| **Au niveau de la branche** | Avoir obtenu ≥ 8 % des suffrages dans la branche |

### 2.2 Délégué syndical

| Critère | Détail |
|---|---|
| **Désigné** | Par le syndicat représentatif (≥ 10 %) |
| **Effectif minimum** | **50 salariés** |
| **Mission** | Négocier les accords collectifs, défendre les intérêts collectifs |
| **Heures de délégation** | 10-25 h/mois selon effectif |

---

## 3. Le DUERP et la prévention des risques

### 3.1 Le Document Unique d'Évaluation des Risques Professionnels (DUERP)

> **Obligatoire pour TOUTE entreprise dès le 1er salarié**.

| Élément | Détail |
|---|---|
| **Contenu** | Inventaire de tous les risques professionnels par unité de travail |
| **Mise à jour** | Annuelle + à chaque modification importante |
| **Conservation** | **40 ans** (depuis loi de 2021) |
| **Mise à disposition** | Salariés, médecin du travail, inspection du travail |

### 3.2 Les principaux risques en transport

| Risque | Source | Mesure de prévention |
|---|---|---|
| **Routier** | Conduite, accidents | Formation éco-conduite, contrôle des temps |
| **Manutention** | Chargement / déchargement | Formation gestes et postures, équipements |
| **Bruit / vibrations** | Conduite prolongée | Cabine isolée, sièges ergonomiques |
| **Chimique** | Carburants, solvants, ADR | Équipements de protection individuelle |
| **Stress** | Pression, délais | Charge de travail mesurée, écoute |

### 3.3 Le plan d'actions et de prévention

> Établi chaque année à partir du DUERP. Liste les actions concrètes, leurs responsables, les délais, les budgets.

### 3.4 Sanctions

L'absence de DUERP ou sa non-mise à jour est sanctionnée :
- Amende **1 500 €** (3 000 € en cas de récidive)
- Responsabilité civile et pénale du dirigeant en cas d'accident du travail

---

## 4. La sécurité et la santé au travail

### 4.1 Obligations de l'employeur

> Article L. 4121-1 C. trav. : **« L'employeur prend les mesures nécessaires pour assurer la sécurité et protéger la santé physique et mentale des travailleurs »**.

Obligation **de moyens renforcée** : il faut prouver avoir mis en œuvre tous les moyens disponibles.

### 4.2 Les 9 principes de prévention

1. Éviter les risques
2. Évaluer les risques (DUERP)
3. Combattre les risques à la source
4. Adapter le travail à l'homme
5. Tenir compte de l'évolution technique
6. Remplacer ce qui est dangereux
7. Planifier la prévention
8. Privilégier les mesures collectives
9. Donner les instructions appropriées

### 4.3 Obligations du salarié

| Obligation | Détail |
|---|---|
| **Conformité aux instructions** | Respecter les règles de sécurité données |
| **Signalement** | Alerter sur tout danger imminent |
| **Droit de retrait** | Possibilité de quitter le poste en cas de danger grave et imminent |
| **EPI** | Porter les équipements de protection individuelle fournis |

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| CSE obligatoire à partir de | **11 salariés** sur 12 mois consécutifs |
| Délégué syndical obligatoire à partir de | **50 salariés** |
| Mandat CSE | **4 ans** (3 mandats max) |
| Heures de délégation CSE 11-49 salariés | **10 h/mois** |
| Représentativité syndicale entreprise | ≥ **10 %** des voix aux élections CSE |
| DUERP obligatoire dès | **1 salarié** |
| Conservation du DUERP | **40 ans** |
| Sanction défaut DUERP | **1 500 €** (3 000 € récidive) |
| Principe N°1 de prévention | **Éviter** les risques |
| Article fondateur sécurité au travail | **L. 4121-1** Code du travail |
$lesson4$,
'CSE 11+ / délégué syndical 50+, DUERP obligatoire dès 1 salarié à conserver 40 ans, 9 principes de prévention, droit de retrait du salarié.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- BANQUE QCM REFORMULÉS — Module E (35 questions)
  -- =================================================================

  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qcm', 'Quelle est la convention collective applicable au transport routier ?', '[{"id":"a","label":"La CCN66 (santé)","is_correct":false},{"id":"b","label":"La CCNTRAAT (transports routiers et activités auxiliaires du transport)","is_correct":true},{"id":"c","label":"La CC bâtiment","is_correct":false},{"id":"d","label":"La CC commerce de gros","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['module-e','capa-3-5t','sources-sociales','ccntraat'], 'mft-2026:moduleE:qcm:1', true, 'CCNTRAAT = Convention Collective Nationale des Transports Routiers et des Activités Auxiliaires du Transport. S''applique obligatoirement à tous les employeurs du secteur.'),
  (v_formation, 'qcm', 'L''annexe CCNA1 de la CCNTRAAT s''applique aux :', '[{"id":"a","label":"Cadres","is_correct":false},{"id":"b","label":"Employés","is_correct":false},{"id":"c","label":"Ouvriers","is_correct":true},{"id":"d","label":"Techniciens et agents de maîtrise","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-e','capa-3-5t','ccntraat'], 'mft-2026:moduleE:qcm:2', true, 'CCNA1 = ouvriers, CCNA2 = employés, CCNA3 = TAM, CCNA4 = ingénieurs et cadres, CCNA5-7 = retraite/prévoyance, participation, formation.'),
  (v_formation, 'qcm', 'Le règlement intérieur est obligatoire dans toute entreprise comptant au minimum :', '[{"id":"a","label":"10 salariés","is_correct":false},{"id":"b","label":"20 salariés","is_correct":false},{"id":"c","label":"50 salariés","is_correct":true},{"id":"d","label":"100 salariés","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-e','capa-3-5t','reglement-interieur'], 'mft-2026:moduleE:qcm:3', true, 'Obligatoire dès 50 salariés sur 12 mois consécutifs. En dessous, il reste possible mais non obligatoire.'),
  (v_formation, 'qcm', 'Quelle institution remplace l''ancien Pôle Emploi depuis le 1er janvier 2024 ?', '[{"id":"a","label":"L''APEC","is_correct":false},{"id":"b","label":"France Travail","is_correct":true},{"id":"c","label":"L''URSSAF","is_correct":false},{"id":"d","label":"La CARCEPT","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['module-e','capa-3-5t','institutions','france-travail'], 'mft-2026:moduleE:qcm:4', true, 'France Travail remplace Pôle Emploi depuis le 1er janvier 2024. Mêmes missions : accompagnement chômeurs + recrutements entreprises.'),
  (v_formation, 'qcm', 'La caisse de retraite et de prévoyance spécifique au secteur du transport est :', '[{"id":"a","label":"L''AGIRC-ARRCO","is_correct":false},{"id":"b","label":"La CARSAT","is_correct":false},{"id":"c","label":"La CARCEPT","is_correct":true},{"id":"d","label":"L''IPSEC","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-e','capa-3-5t','institutions','carcept'], 'mft-2026:moduleE:qcm:5', true, 'CARCEPT = Caisse Autonome de Retraites Complémentaires Et de Prévoyance du Transport. Adhésion obligatoire pour toute entreprise du transport routier.'),
  (v_formation, 'qcm', 'L''Inspection du travail est rattachée depuis 2021 à :', '[{"id":"a","label":"La DIRECCTE","is_correct":false},{"id":"b","label":"La DREETS","is_correct":true},{"id":"c","label":"La DRH","is_correct":false},{"id":"d","label":"La DREAL","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-e','capa-3-5t','institutions','dreets'], 'mft-2026:moduleE:qcm:6', true, 'Depuis avril 2021, les anciennes DIRECCTE sont devenues DREETS (Directions Régionales de l''Économie, de l''Emploi, du Travail et des Solidarités).'),
  (v_formation, 'qcm', 'La DPAE (Déclaration Préalable À l''Embauche) doit être effectuée :', '[{"id":"a","label":"Au plus tard 1 mois après l''embauche","is_correct":false},{"id":"b","label":"Au plus tard 8 jours avant l''embauche, ou le jour même","is_correct":true},{"id":"c","label":"Uniquement si le salarié est en CDD","is_correct":false},{"id":"d","label":"Avant la fin de la période d''essai","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-e','capa-3-5t','embauche','dpae'], 'mft-2026:moduleE:qcm:7', true, 'DPAE obligatoire au plus tôt 8 jours avant l''embauche, au plus tard le jour même. Défaut de DPAE = travail dissimulé.'),
  (v_formation, 'qcm', 'Quelle est la durée maximale de la période d''essai d''un OUVRIER en CDI (renouvellement compris) ?', '[{"id":"a","label":"2 mois","is_correct":false},{"id":"b","label":"4 mois","is_correct":true},{"id":"c","label":"6 mois","is_correct":false},{"id":"d","label":"8 mois","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-e','capa-3-5t','periode-essai'], 'mft-2026:moduleE:qcm:8', true, 'Ouvrier/employé : 2 mois initiale + 2 mois renouvellement = 4 mois max. TAM : 6 mois. Cadre : 8 mois.'),
  (v_formation, 'qcm', 'La période d''essai d''un CADRE en CDI peut atteindre au maximum (renouvellement compris) :', '[{"id":"a","label":"3 mois","is_correct":false},{"id":"b","label":"6 mois","is_correct":false},{"id":"c","label":"8 mois","is_correct":true},{"id":"d","label":"12 mois","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-e','capa-3-5t','periode-essai','cadre'], 'mft-2026:moduleE:qcm:9', true, 'Cadre : période initiale 4 mois + renouvellement 4 mois = 8 mois maximum.'),
  (v_formation, 'qcm', 'Un CDD pour accroissement temporaire d''activité a une durée maximale de (renouvellements inclus) :', '[{"id":"a","label":"6 mois","is_correct":false},{"id":"b","label":"12 mois","is_correct":false},{"id":"c","label":"18 mois","is_correct":true},{"id":"d","label":"24 mois","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-e','capa-3-5t','cdd'], 'mft-2026:moduleE:qcm:10', true, '18 mois max pour accroissement temporaire (24 mois pour export ou survenance d''une commande exceptionnelle export).'),
  (v_formation, 'qcm', 'Un CDD non justifié par un motif valable peut être :', '[{"id":"a","label":"Maintenu sans conséquence","is_correct":false},{"id":"b","label":"Requalifié en CDI par le Conseil des prud''hommes","is_correct":true},{"id":"c","label":"Annulé sans indemnité","is_correct":false},{"id":"d","label":"Renouvelé indéfiniment","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-e','capa-3-5t','cdd','requalification'], 'mft-2026:moduleE:qcm:11', true, 'Requalification en CDI : sanction principale du CDD irrégulier. Indemnité = 1 mois de salaire en plus pour le salarié.'),
  (v_formation, 'qcm', 'La VIP (Visite d''Information et de Prévention) doit être organisée dans un délai de :', '[{"id":"a","label":"15 jours suivant l''embauche","is_correct":false},{"id":"b","label":"3 mois suivant l''embauche","is_correct":true},{"id":"c","label":"6 mois suivant l''embauche","is_correct":false},{"id":"d","label":"1 an suivant l''embauche","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-e','capa-3-5t','medecine-travail'], 'mft-2026:moduleE:qcm:12', true, 'VIP obligatoire dans les 3 mois suivant la prise de fonction effective. Réalisée par le médecin du travail ou son équipe.'),
  (v_formation, 'qcm', 'Le délai de rétractation pour une rupture conventionnelle est de :', '[{"id":"a","label":"7 jours calendaires","is_correct":false},{"id":"b","label":"15 jours calendaires","is_correct":true},{"id":"c","label":"15 jours ouvrables","is_correct":false},{"id":"d","label":"1 mois","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-e','capa-3-5t','rupture-conventionnelle'], 'mft-2026:moduleE:qcm:13', true, '15 jours CALENDAIRES (week-ends inclus) à compter de la signature de la convention. Puis homologation DREETS sous 15 jours OUVRABLES.'),
  (v_formation, 'qcm', 'Pour un licenciement personnel, la convocation à l''entretien préalable doit être adressée au minimum combien de jours avant l''entretien ?', '[{"id":"a","label":"2 jours ouvrables","is_correct":false},{"id":"b","label":"5 jours ouvrables","is_correct":true},{"id":"c","label":"15 jours calendaires","is_correct":false},{"id":"d","label":"1 mois","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-e','capa-3-5t','licenciement','procedure'], 'mft-2026:moduleE:qcm:14', true, 'Convocation par LRAR au moins 5 jours ouvrables avant l''entretien. Puis notification du licenciement au moins 2 jours ouvrables après l''entretien.'),
  (v_formation, 'qcm', 'L''indemnité légale de licenciement est calculée jusqu''à 10 ans d''ancienneté à hauteur de :', '[{"id":"a","label":"1/8 mois par année","is_correct":false},{"id":"b","label":"1/4 mois par année","is_correct":true},{"id":"c","label":"1/3 mois par année","is_correct":false},{"id":"d","label":"1/2 mois par année","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-e','capa-3-5t','licenciement','indemnite'], 'mft-2026:moduleE:qcm:15', true, 'Article L. 1234-9 C. trav. : 1/4 de mois × ancienneté jusqu''à 10 ans, puis 1/3 de mois × ancienneté au-delà. Calcul sur le salaire brut moyen des 12 ou 3 derniers mois (le plus favorable).'),
  (v_formation, 'qcm', 'Le Conseil des prud''hommes est compétent pour :', '[{"id":"a","label":"Les litiges entre entreprises","is_correct":false},{"id":"b","label":"Les litiges individuels du contrat de travail","is_correct":true},{"id":"c","label":"Les contraventions au Code de la route","is_correct":false},{"id":"d","label":"Les conflits collectifs uniquement","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['module-e','capa-3-5t','prudhommes'], 'mft-2026:moduleE:qcm:16', true, 'Compétence = litiges INDIVIDUELS entre employeurs et salariés portant sur le contrat de travail. Composé de juges non professionnels (2 employeurs + 2 salariés), avocat non obligatoire.'),
  (v_formation, 'qcm', 'La 1re étape de la procédure prud''homale est :', '[{"id":"a","label":"Le bureau de jugement","is_correct":false},{"id":"b","label":"Le bureau de conciliation et d''orientation (BCO)","is_correct":true},{"id":"c","label":"L''appel","is_correct":false},{"id":"d","label":"La saisine de la Cour de cassation","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-e','capa-3-5t','prudhommes','procedure'], 'mft-2026:moduleE:qcm:17', true, 'BCO (Bureau de Conciliation et d''Orientation) → tentative de conciliation. Si échec, renvoi au Bureau de Jugement (BJ).'),
  (v_formation, 'qcm', 'La durée légale du travail hebdomadaire pour le personnel sédentaire est de :', '[{"id":"a","label":"30 heures","is_correct":false},{"id":"b","label":"35 heures","is_correct":true},{"id":"c","label":"39 heures","is_correct":false},{"id":"d","label":"40 heures","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['module-e','capa-3-5t','duree-travail'], 'mft-2026:moduleE:qcm:18', true, '35 h hebdomadaires depuis 2000 (lois Aubry). Durée légale, pas une durée maximale (qui est de 48 h).'),
  (v_formation, 'qcm', 'La durée maximale journalière de conduite pour le personnel roulant est en général de :', '[{"id":"a","label":"8 heures","is_correct":false},{"id":"b","label":"9 heures","is_correct":true},{"id":"c","label":"11 heures","is_correct":false},{"id":"d","label":"12 heures","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-e','capa-3-5t','duree-travail','roulant'], 'mft-2026:moduleE:qcm:19', true, '9 h max par jour, portable à 10 h max 2 fois/semaine. Règlement R561/2006 + Code des transports.'),
  (v_formation, 'qcm', 'Après combien de temps de conduite continu une pause d''au moins 45 minutes est-elle obligatoire ?', '[{"id":"a","label":"2 heures","is_correct":false},{"id":"b","label":"3 heures","is_correct":false},{"id":"c","label":"4 heures 30","is_correct":true},{"id":"d","label":"6 heures","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-e','capa-3-5t','duree-travail','pause'], 'mft-2026:moduleE:qcm:20', true, '45 minutes après 4h30 de conduite continue. Peut être fractionnée : 15 min puis 30 min minimum.'),
  (v_formation, 'qcm', 'Le repos quotidien minimum d''un conducteur est de :', '[{"id":"a","label":"8 heures","is_correct":false},{"id":"b","label":"11 heures","is_correct":true},{"id":"c","label":"12 heures","is_correct":false},{"id":"d","label":"24 heures","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-e','capa-3-5t','duree-travail','repos'], 'mft-2026:moduleE:qcm:21', true, '11 heures consécutives par 24 heures. Réductible à 9 heures max 3 fois/semaine. Doit être pris hors du véhicule (sauf cabine adaptée).'),
  (v_formation, 'qcm', 'Le repos hebdomadaire normal d''un conducteur est de :', '[{"id":"a","label":"24 heures","is_correct":false},{"id":"b","label":"35 heures","is_correct":false},{"id":"c","label":"45 heures","is_correct":true},{"id":"d","label":"60 heures","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-e','capa-3-5t','duree-travail','repos'], 'mft-2026:moduleE:qcm:22', true, '45 h consécutives par semaine (normal). Possibilité de réduire à 24 h (réduit) avec récupération obligatoire dans les 3 semaines.'),
  (v_formation, 'qcm', 'La majoration des 8 premières heures supplémentaires (de la 36e à la 43e h) est de :', '[{"id":"a","label":"+10 %","is_correct":false},{"id":"b","label":"+25 %","is_correct":true},{"id":"c","label":"+50 %","is_correct":false},{"id":"d","label":"+100 %","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-e','capa-3-5t','heures-supplementaires'], 'mft-2026:moduleE:qcm:23', true, '+25 % de la 36e à la 43e h. +50 % à partir de la 44e h. Possibilité de remplacer le paiement par un repos compensateur équivalent.'),
  (v_formation, 'qcm', 'La mensualisation correspond à un calcul du salaire mensuel sur la base de :', '[{"id":"a","label":"35 h × 4 semaines = 140 h","is_correct":false},{"id":"b","label":"35 h × 52 / 12 = 151,67 h","is_correct":true},{"id":"c","label":"40 h × 52 / 12 = 173,33 h","is_correct":false},{"id":"d","label":"Heures réellement effectuées chaque mois","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-e','capa-3-5t','mensualisation'], 'mft-2026:moduleE:qcm:24', true, 'Mensualisation = lissage : (35 h × 52 semaines) / 12 mois = 151,67 h/mois. Le salaire est constant indépendamment du nombre de jours du mois.'),
  (v_formation, 'qcm', 'Tout salarié a droit à combien de jours ouvrables de congés payés par mois travaillé ?', '[{"id":"a","label":"1,5 jours","is_correct":false},{"id":"b","label":"2 jours","is_correct":false},{"id":"c","label":"2,5 jours","is_correct":true},{"id":"d","label":"3 jours","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['module-e','capa-3-5t','conges-payes'], 'mft-2026:moduleE:qcm:25', true, '2,5 jours OUVRABLES par mois travaillé = 30 jours par an = 5 semaines (article L. 3141-3 C. trav.).'),
  (v_formation, 'qcm', 'L''indemnité de congés payés se calcule selon la méthode la plus favorable au salarié entre :', '[{"id":"a","label":"Le 1/12e ou le 1/24e","is_correct":false},{"id":"b","label":"Le 1/10e ou le maintien de salaire","is_correct":true},{"id":"c","label":"Le 1/8e ou le 1/4","is_correct":false},{"id":"d","label":"Le SMIC ou le salaire conventionnel","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-e','capa-3-5t','conges-payes','indemnite'], 'mft-2026:moduleE:qcm:26', true, 'Méthode du 1/10e : 1/10e du brut total perçu sur la période de référence. Méthode du maintien : ce que le salarié aurait gagné en travaillant. Le plus favorable s''applique.'),
  (v_formation, 'qcm', 'Le travail de nuit dans le transport routier de marchandises est défini comme tout travail entre :', '[{"id":"a","label":"22 h et 5 h","is_correct":false},{"id":"b","label":"21 h et 6 h","is_correct":true},{"id":"c","label":"20 h et 7 h","is_correct":false},{"id":"d","label":"18 h et 8 h","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-e','capa-3-5t','travail-nuit'], 'mft-2026:moduleE:qcm:27', true, 'Article L. 3122-29 C. trav. : tout travail entre 21 h et 6 h. Compensations : majoration ≥ 20 %, repos compensateur, surveillance médicale renforcée.'),
  (v_formation, 'qcm', 'La durée minimale du temps partiel est de :', '[{"id":"a","label":"15 h hebdomadaires","is_correct":false},{"id":"b","label":"24 h hebdomadaires","is_correct":true},{"id":"c","label":"28 h hebdomadaires","is_correct":false},{"id":"d","label":"30 h hebdomadaires","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-e','capa-3-5t','temps-partiel'], 'mft-2026:moduleE:qcm:28', true, '24 h hebdo minimum (article L. 3123-7 C. trav.). Dérogations : étudiants, multi-employeurs, demande écrite du salarié pour raisons personnelles.'),
  (v_formation, 'qcm', 'Le CSE (Comité Social et Économique) est obligatoire dans toute entreprise comptant au moins :', '[{"id":"a","label":"5 salariés","is_correct":false},{"id":"b","label":"11 salariés","is_correct":true},{"id":"c","label":"50 salariés","is_correct":false},{"id":"d","label":"100 salariés","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-e','capa-3-5t','cse'], 'mft-2026:moduleE:qcm:29', true, 'CSE obligatoire dès 11 salariés sur 12 mois consécutifs. À partir de 50 salariés, ses attributions économiques s''élargissent (consultation sur stratégie, situation économique...).'),
  (v_formation, 'qcm', 'La durée du mandat des élus du CSE est de :', '[{"id":"a","label":"2 ans","is_correct":false},{"id":"b","label":"3 ans","is_correct":false},{"id":"c","label":"4 ans","is_correct":true},{"id":"d","label":"5 ans","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-e','capa-3-5t','cse','mandat'], 'mft-2026:moduleE:qcm:30', true, '4 ans (article L. 2314-33 C. trav.), avec un maximum de 3 mandats successifs (sauf accord d''entreprise).'),
  (v_formation, 'qcm', 'Pour qu''un syndicat soit représentatif au niveau de l''entreprise, il doit avoir obtenu au minimum :', '[{"id":"a","label":"5 % des voix au 1er tour CSE","is_correct":false},{"id":"b","label":"10 % des voix au 1er tour CSE","is_correct":true},{"id":"c","label":"30 % des voix","is_correct":false},{"id":"d","label":"50 % des voix","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-e','capa-3-5t','syndicats','representativite'], 'mft-2026:moduleE:qcm:31', true, '10 % des suffrages exprimés au 1er tour des dernières élections CSE. À partir de 50 salariés, ces syndicats peuvent désigner un délégué syndical.'),
  (v_formation, 'qcm', 'Le DUERP (Document Unique d''Évaluation des Risques Professionnels) est obligatoire pour toute entreprise comptant au minimum :', '[{"id":"a","label":"1 salarié","is_correct":true},{"id":"b","label":"11 salariés","is_correct":false},{"id":"c","label":"20 salariés","is_correct":false},{"id":"d","label":"50 salariés","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['module-e','capa-3-5t','duerp','prevention'], 'mft-2026:moduleE:qcm:32', true, 'Obligatoire dès le 1er salarié (article R. 4121-1 C. trav.). Mise à jour annuelle. Conservation 40 ans depuis la loi du 2 août 2021.'),
  (v_formation, 'qcm', 'Depuis 2021, le DUERP doit être conservé pendant :', '[{"id":"a","label":"5 ans","is_correct":false},{"id":"b","label":"10 ans","is_correct":false},{"id":"c","label":"20 ans","is_correct":false},{"id":"d","label":"40 ans","is_correct":true}]'::jsonb, 1, 'difficile', ARRAY['module-e','capa-3-5t','duerp'], 'mft-2026:moduleE:qcm:33', true, '40 ans depuis la loi Santé au travail du 2 août 2021. Cette mesure permet aux salariés de prouver une exposition aux risques même longtemps après leur départ.'),
  (v_formation, 'qcm', 'Le travail dissimulé peut être sanctionné, pour une personne physique, jusqu''à :', '[{"id":"a","label":"3 mois de prison et 7 500 €","is_correct":false},{"id":"b","label":"6 mois de prison et 15 000 €","is_correct":false},{"id":"c","label":"3 ans de prison et 45 000 €","is_correct":true},{"id":"d","label":"5 ans de prison et 75 000 €","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-e','capa-3-5t','travail-dissimule'], 'mft-2026:moduleE:qcm:34', true, 'Article L. 8224-1 C. trav. : 3 ans de prison et 45 000 € pour personne physique, 224 000 € pour personne morale + sanctions civiles (rappel de salaires, dommages-intérêts).'),
  (v_formation, 'qcm', 'Quel est le 1er principe général de prévention des risques professionnels ?', '[{"id":"a","label":"Combattre les risques à la source","is_correct":false},{"id":"b","label":"Éviter les risques","is_correct":true},{"id":"c","label":"Adapter le travail à l''homme","is_correct":false},{"id":"d","label":"Donner les instructions appropriées","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['module-e','capa-3-5t','prevention'], 'mft-2026:moduleE:qcm:35', true, '1er principe : ÉVITER les risques. 2e : Évaluer les risques (DUERP). 3e : Combattre à la source. 4e : Adapter le travail à l''homme. (Article L. 4121-2 C. trav.)');

  -- =================================================================
  -- BANQUE QR — Module E (6 mises en situation)
  -- =================================================================

  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qr',
    'Vous êtes dirigeant d''une SARL de 18 salariés (10 chauffeurs, 5 manutentionnaires, 3 administratifs). Vous embauchez votre 19e salarié, un nouveau chauffeur en CDI à temps plein.

a. Listez les 5 obligations administratives à respecter avant et après l''embauche.
b. Quelle convention collective s''applique et quelles annexes spécifiques pour ce poste ?
c. Quelle période d''essai pouvez-vous prévoir au maximum ?
d. Devez-vous mettre en place un CSE et un règlement intérieur ?',
    NULL, 5, 'moyen',
    ARRAY['module-e','capa-3-5t','qr','embauche','cas-pratique'],
    'mft-2026:moduleE:qr:1', true,
    'Correction : a. (1) DPAE 8 j avant ou jour même via urssaf.fr, (2) signature contrat de travail écrit (recommandé CDI, obligatoire CDD/temps partiel), (3) inscription au registre unique du personnel dès l''embauche, (4) déclaration auprès de la CARCEPT et de la médecine du travail, (5) VIP organisée dans les 3 mois. b. CCNTRAAT, annexe CCNA1 (Ouvriers) pour un chauffeur. c. Période d''essai ouvrier max = 2 mois initial + 2 mois renouvellement = 4 mois. d. CSE OUI obligatoire (≥ 11 salariés). Règlement intérieur : non obligatoire (< 50 salariés) mais peut être adopté volontairement.'),

  (v_formation, 'qr',
    'Vous décidez de licencier un chauffeur en CDI suite à des absences répétées non justifiées. Il est dans l''entreprise depuis 8 ans, son salaire mensuel brut est de 2 100 €.

a. Quelle est la procédure de licenciement à suivre, étape par étape avec délais ?
b. Le chauffeur peut-il être assisté lors de l''entretien préalable ? Par qui ?
c. Calculez le montant de l''indemnité légale de licenciement.
d. Quels documents devez-vous remettre au chauffeur lors de son départ ?',
    NULL, 5, 'difficile',
    ARRAY['module-e','capa-3-5t','qr','licenciement','cas-pratique'],
    'mft-2026:moduleE:qr:2', true,
    'Correction : a. (1) Convocation à l''entretien préalable par LRAR au moins 5 jours ouvrables avant l''entretien, (2) entretien préalable, (3) notification du licenciement par LRAR au moins 2 jours ouvrables après l''entretien, (4) préavis légal (1 mois pour < 2 ans, 2 mois pour ≥ 2 ans), (5) versement des indemnités. b. Oui, par un salarié de l''entreprise, ou un conseiller extérieur inscrit sur la liste préfectorale (s''il n''y a pas de représentant du personnel). c. 8 ans → 1/4 mois × 8 = 2 × 2 100 = 4 200 € d''indemnité légale minimale. d. Certificat de travail, attestation France Travail, reçu pour solde de tout compte, éventuelle clause de non-concurrence.'),

  (v_formation, 'qr',
    'Un chauffeur travaille pour vous 10h par jour pendant 6 jours d''affilée, sans pause de 45 min après 4h30 de conduite. Il refuse de prendre son repos de 45h après cette semaine.

a. Quelles infractions à la durée du travail constatez-vous ?
b. Quelles sont vos obligations légales en tant qu''employeur ?
c. Quelles sanctions risquez-vous en cas de contrôle de la DREETS ?
d. Comment organiser correctement le travail pour respecter la réglementation ?',
    NULL, 5, 'difficile',
    ARRAY['module-e','capa-3-5t','qr','duree-travail','cas-pratique'],
    'mft-2026:moduleE:qr:3', true,
    'Correction : a. Plusieurs infractions : (1) durée journalière > 9h non motivée, (2) absence de pause obligatoire de 45 min après 4h30 de conduite, (3) repos hebdo réduit à <45h non récupéré dans les 3 semaines, (4) potentiellement durée hebdo > 56h. b. Obligation de moyens renforcée (article L. 4121-1) : organiser le travail conformément à la loi, contrôler les temps via chronotachygraphe, former les conducteurs, surveiller les pauses. c. Sanctions : amendes (jusqu''à 750 € par infraction par jour, 1 500 € en cas de récidive), retrait de licence en cas d''infractions multiples, responsabilité civile et pénale en cas d''accident lié à la fatigue. d. (1) Planifier les tournées avec pauses obligatoires, (2) former les conducteurs aux règles, (3) suivre les données chronotachygraphe en temps réel, (4) imposer le repos hebdo et planifier la récupération, (5) ne jamais faire pression pour dépasser les durées.'),

  (v_formation, 'qr',
    'Un chauffeur en CDI réclame une rupture conventionnelle pour reconversion. Vous êtes d''accord. Salaire mensuel brut : 2 200 €. Ancienneté : 6 ans.

a. Décrivez la procédure complète à suivre.
b. Quel est le délai de rétractation et qui peut s''en prévaloir ?
c. Calculez le montant minimum de l''indemnité spécifique de rupture conventionnelle.
d. Quels avantages pour le salarié par rapport à une démission ?',
    NULL, 5, 'moyen',
    ARRAY['module-e','capa-3-5t','qr','rupture-conventionnelle','cas-pratique'],
    'mft-2026:moduleE:qr:4', true,
    'Correction : a. (1) Au moins un entretien (le salarié peut être assisté), (2) signature de la convention de rupture, (3) délai de rétractation 15 jours calendaires, (4) demande d''homologation à la DREETS, (5) homologation tacite ou explicite sous 15 jours ouvrables, (6) date de rupture convenue. b. 15 jours calendaires (week-ends inclus) à compter du lendemain de la signature, pour les DEUX parties (employeur et salarié). c. Indemnité spécifique = au moins l''indemnité légale de licenciement = 1/4 mois × 6 = 1,5 × 2 200 = 3 300 €. d. Ouvre droit à l''ASSURANCE CHÔMAGE (contrairement à la démission), pas de motif à donner, négociation amiable possible (montant supérieur au minimum légal).'),

  (v_formation, 'qr',
    'Calculez la rémunération mensuelle d''un coursier qui a effectué le mois écoulé : 35h hebdo × 4 semaines + 6h supplémentaires (4 dans les 8 premières, 2 au-delà). Taux horaire de base : 13 €.

a. Calculez le salaire de base mensualisé.
b. Calculez le coût des heures supplémentaires majorées.
c. Calculez le salaire brut total.
d. Si le salarié bénéficie de 50 € de prime de panier dans le mois, quel est le brut final ?',
    NULL, 5, 'moyen',
    ARRAY['module-e','capa-3-5t','qr','remuneration','cas-pratique'],
    'mft-2026:moduleE:qr:5', true,
    'Correction : a. Mensualisation = 13 × 151,67 = 1 971,71 €. b. 4 h × 13 × 1,25 = 65 €. 2 h × 13 × 1,50 = 39 €. Total HS : 104 €. c. Salaire brut sans prime = 1 971,71 + 104 = 2 075,71 €. d. La prime de panier est en principe non soumise à cotisations dans la limite du barème URSSAF (≈ 8 €/jour), donc à isoler du brut. Si forfait : Brut total = 2 075,71 + 50 = 2 125,71 € (mais prime panier pas dans la base de calcul des cotisations sociales si dans la limite).'),

  (v_formation, 'qr',
    'Vous démarrez votre activité avec votre 1er salarié. Vous voulez vous mettre en conformité concernant la prévention des risques.

a. Quels documents devez-vous obligatoirement établir ?
b. Quelles sont les principales catégories de risques en transport routier ?
c. Quel est le 1er principe général de prévention ?
d. Que risquez-vous en cas d''accident du travail si vous n''avez pas de DUERP ?',
    NULL, 5, 'moyen',
    ARRAY['module-e','capa-3-5t','qr','prevention','duerp','cas-pratique'],
    'mft-2026:moduleE:qr:6', true,
    'Correction : a. (1) DUERP obligatoire dès le 1er salarié, conservé 40 ans, mis à jour annuellement, (2) Plan d''actions de prévention, (3) Affichage des consignes de sécurité et numéros d''urgence, (4) Affichage du médecin du travail et de l''inspection du travail. b. Risques transport : routiers (accidents, fatigue), manutention (TMS, dos), bruit / vibrations, chimique (carburants, ADR), stress / RPS, intempéries, agression. c. 1er principe : ÉVITER les risques. 2e : Évaluer (DUERP). 3e : Combattre à la source. 4e : Adapter le travail à l''homme. d. Risques : (1) responsabilité civile (réparation du préjudice du salarié + ayants droit en cas de décès), (2) responsabilité pénale (article 121-3 Code pénal pour faute caractérisée), (3) faute INEXCUSABLE de l''employeur reconnue automatiquement → indemnités majorées, prise en charge des compléments par l''entreprise (sans recours sur la Sécu).');

  -- =================================================================
  -- QUIZZES par leçon + examen blanc
  -- =================================================================

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Sources sociales et institutions — Quiz', 'Quiz sur les sources du droit social, la CCNTRAAT, les institutions.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026:moduleE:qcm:1','mft-2026:moduleE:qcm:2','mft-2026:moduleE:qcm:3','mft-2026:moduleE:qcm:4','mft-2026:moduleE:qcm:5','mft-2026:moduleE:qcm:6');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Contrat de travail — Quiz', 'Quiz sur l''embauche, les types de contrats, la rupture, les prud''hommes.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026:moduleE:qcm:7','mft-2026:moduleE:qcm:8','mft-2026:moduleE:qcm:9','mft-2026:moduleE:qcm:10','mft-2026:moduleE:qcm:11','mft-2026:moduleE:qcm:12','mft-2026:moduleE:qcm:13','mft-2026:moduleE:qcm:14','mft-2026:moduleE:qcm:15','mft-2026:moduleE:qcm:16','mft-2026:moduleE:qcm:17');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Durée du travail et rémunération — Quiz', 'Quiz sur la durée du travail (Code des transports), heures sup, congés, mensualisation.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026:moduleE:qcm:18','mft-2026:moduleE:qcm:19','mft-2026:moduleE:qcm:20','mft-2026:moduleE:qcm:21','mft-2026:moduleE:qcm:22','mft-2026:moduleE:qcm:23','mft-2026:moduleE:qcm:24','mft-2026:moduleE:qcm:25','mft-2026:moduleE:qcm:26','mft-2026:moduleE:qcm:27','mft-2026:moduleE:qcm:28');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'IRP et conditions de travail — Quiz', 'Quiz sur le CSE, les syndicats, le DUERP, la prévention des risques.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026:moduleE:qcm:29','mft-2026:moduleE:qcm:30','mft-2026:moduleE:qcm:31','mft-2026:moduleE:qcm:32','mft-2026:moduleE:qcm:33','mft-2026:moduleE:qcm:34','mft-2026:moduleE:qcm:35');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Examen blanc — Module E', 'Examen blanc Module E : 10 QCM en 22 min, seuil 50 %.', 'examen', 1320, 50)
  RETURNING id INTO v_quiz_eb;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026:moduleE:qcm:1','mft-2026:moduleE:qcm:7','mft-2026:moduleE:qcm:8','mft-2026:moduleE:qcm:13','mft-2026:moduleE:qcm:15','mft-2026:moduleE:qcm:18','mft-2026:moduleE:qcm:20','mft-2026:moduleE:qcm:23','mft-2026:moduleE:qcm:29','mft-2026:moduleE:qcm:32');

  RAISE NOTICE '✅ Module E v2 chargé : 4 leçons, 35 QCM, 6 QR, 5 quizzes.';
END
$module_e_v2$;
