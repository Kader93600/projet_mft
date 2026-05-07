-- =====================================================================
-- GOTRM (RNCP 40990) — BC01-01 · Traiter une demande de transport
-- Version 3 (mai 2026) — REFONTE PÉDAGOGIQUE PREMIUM v3_dense
--
-- Bloc 01 : Concevoir, organiser et piloter des opérations de transport.
-- Module pilote n° 1 sur 10 du BC01.
--
-- Diagnostic v2 → v3 :
--   ✓ Bug bloc : v_bloc résolu via slug fiable (BC1)
--   ✓ Schéma question_bank correct (statement / max_score / tags / is_correct)
--   ✓ Leçons densifiées : 2 200-2 500 mots chacune (vs 800-1200 en v2)
--   ✓ 4 cas pratiques chiffrés (vs 1 en v2)
--   ✓ Mini-exercices à faire seul + corrections en fin de module
--   ✓ Astuces pro + Points de vigilance + Schémas ASCII
--   ✓ Banque enrichie : 48 QCM (vs 30) + 8 QR métier (vs 6)
--   ✓ Quizzes : 4 entraînement (12 QCM/quiz) + 1 examen blanc module
--     (15 QCM + 5 QR cas pratique long, 60 min, seuil 50 %)
--   ✓ Références : Code commerce, LOTI, décret 99-269 contrat-type général,
--     arrêté 9 nov 1999, CMR Convention Genève 1956, CGV transporteur
--
-- Référentiel RNCP 40990 — compétence visée :
--   « Analyser une demande de transport pour en extraire les paramètres
--   techniques, juridiques et économiques nécessaires à la planification. »
--
-- ▸ 4 leçons (180 min total)
--   1. Écosystème du transport et rôle des acteurs (45 min)
--   2. Qualifier une demande de transport — méthode SACO (45 min)
--   3. Cadre juridique de la demande (45 min)
--   4. Méthodologie MSP de traitement (45 min)
--
-- Idempotent. Pré-requis : formation 'gotrm' présente.
-- =====================================================================

DO $bc01_01_v3$
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

  -- ─── Remplacement complet du module BC01-01 (v2 → v3) ─────────────
  -- On supprime AUSSI l'ancien doublon v3 si le script avait été joué une 1ère fois.
  -- Le DELETE module cascade : lessons, formation_modules, quizzes, quiz_question_bank.
  DELETE FROM public.modules WHERE slug IN (
    'gotrm-bc01-01-demande-transport',         -- slug v2 (à reprendre pour la v3)
    'gotrm-traiter-demande-transport-v3'       -- ancien essai v3 (s'il a été joué)
  );

  -- Nettoyage de la banque de questions liées (v2 + v3) pour éviter les doublons
  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND (source_ref LIKE 'mft-2026-gotrm:bc01-01:%'        -- ancien pattern v2
       OR source_ref LIKE 'mft-2026-gotrm:bc01-01-v3:%');   -- nouveau pattern v3

  INSERT INTO public.modules (
    title, slug, bloc_id, summary, difficulty, duration_min, "order"
  ) VALUES (
    'BC01-01 — Traiter une demande de transport',
    'gotrm-bc01-01-demande-transport',
    v_bloc,
    'Identifier les acteurs de la chaîne logistique, qualifier une demande de transport (méthode SACO), maîtriser le cadre juridique (contrat-type général, CGV, CMR) et appliquer la méthodologie MSP pour transformer une demande en devis structuré et signé.',
    'intermediaire',
    180,
    10
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 10, true) ON CONFLICT DO NOTHING;

  -- =================================================================
  -- LEÇON 1 — Écosystème du transport et rôle des acteurs
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Écosystème du transport et rôle des acteurs',
    'ecosysteme-acteurs-transport',
    1, 45,
$lessonG1$
# Écosystème du transport et rôle des acteurs

> 🎯 **Objectifs pédagogiques**
>
> À la fin de cette leçon, vous serez capable de :
>
> - **Identifier** les 6 acteurs principaux de la chaîne du transport routier de marchandises.
> - **Distinguer** chargeur, donneur d'ordre, commissionnaire et transporteur public.
> - **Comprendre** la responsabilité juridique de chaque maillon.
> - **Cartographier** une chaîne complexe (e-commerce, GMS, industrie).
> - **Anticiper** les pièges de la sous-traitance en cascade.

---

## Introduction

Le transport routier de marchandises français représente **460 milliards d'euros de marchandises transportées par an**, **40 000 entreprises**, **400 000 conducteurs salariés**. Mais derrière ces chiffres, c'est un **écosystème à 6 niveaux** où chaque acteur a un rôle précis, une responsabilité juridique et un intérêt économique différent.

Le **gestionnaire d'opérations** (vous) se trouve au **point de jonction** : entre le client qui exprime un besoin (le chargeur) et l'opérationnel qui exécute (les conducteurs). Mal comprendre qui commande, qui paye, qui est responsable = générer des litiges, des impayés, et des sanctions administratives.

Cette leçon vous arme pour **5 à 8 points** d'examen RNCP, et surtout pour **éviter 80 % des erreurs juridiques** du métier.

---

## 1. Vue d'ensemble : la chaîne logistique

### 1.1 Schéma de référence

La chaîne du transport routier de marchandises se déroule en **6 maillons successifs**, du commanditaire jusqu'au receveur final :

:::flow
1. Expéditeur | Remet physiquement la marchandise
2. Donneur d'ordre | Commande et règle le transport
3. Commissionnaire | Organise librement modes et prestataires
4. Transporteur public | Exécute matériellement (1ᵉʳ rang)
5. Sous-traitant | Exécute pour le transporteur (2ᵉ rang max)
6. Destinataire | Reçoit la marchandise sur site
:::

### 1.2 Les 6 rôles à connaître par cœur

| Rôle | Définition | Responsabilité |
|---|---|---|
| **Expéditeur** (chargeur) | Celui qui remet la marchandise au transport, généralement propriétaire | Conformité du chargement, déclarations ADR, emballage |
| **Donneur d'ordre (DO)** | Celui qui commande le transport et paye le transporteur | Solvabilité, instructions précises, respect du contrat |
| **Commissionnaire de transport** | Organisateur qui choisit librement les modes et les transporteurs | Résultat du transport (responsabilité de plein droit, art. L. 132-4 C. com.) |
| **Transporteur public** | Exploitant inscrit au registre, exécute matériellement le transport | Exécution conforme du contrat, obligation de moyen renforcée |
| **Sous-traitant** | Transporteur qui exécute pour le compte d'un autre transporteur | Mêmes obligations + facture le 1er transporteur |
| **Destinataire** | Celui qui reçoit la marchandise | Réception conforme, réserves à l'arrivée, paiement final si CIF |

### 1.3 Cas concrets : qui est qui ?

**Cas A** — Carrefour commande un transport à Geodis pour livrer 30 palettes de yaourts depuis Danone (Paris) vers son entrepôt de Lyon.
- **Expéditeur** = Danone
- **Donneur d'ordre** = Carrefour (c'est lui qui paye Geodis)
- **Commissionnaire** = Geodis (organise, sous-traite si besoin)
- **Destinataire** = Carrefour (entrepôt Lyon)

**Cas B** — Un PME de meubles vend en ligne à un particulier ; commande à La Poste Colissimo.
- **Expéditeur** = la PME
- **Donneur d'ordre** = la PME
- **Commissionnaire** = La Poste (contrat de commission)
- **Transporteur** = sous-traitant local de La Poste
- **Destinataire** = le particulier

---

## 2. Le donneur d'ordre (DO) — pivot juridique

### 2.1 Définition légale

Le **donneur d'ordre** est défini par l'**article L. 3221-1 du Code des transports** : « personne pour le compte de laquelle le transport est exécuté ».

C'est lui qui :
- **Signe** le contrat de transport.
- **Paie** la facture (sauf clause CIF/franco où c'est le destinataire).
- Peut être **différent de l'expéditeur** : un grossiste qui achète chez un industriel et fait livrer chez un détaillant ⇒ DO = grossiste, expéditeur = industriel.

### 2.2 Obligations du DO

- **Information précise** sur la marchandise (nature, poids, dimensions, ADR).
- **Instructions** claires et complètes (adresse, créneaux, contacts).
- **Paiement** dans les délais LME (60 jours date facture max).
- **Solvabilité** : c'est à lui que le transporteur facture.

### 2.3 Solidarité financière (LOTI)

⚠️ **Article L. 3242-3 C. transports** — si le DO ne paie pas dans les 30 jours, le **transporteur peut se retourner contre l'expéditeur ou le destinataire** au titre de l'**action directe**. C'est unique au transport.

Exemple : Vous transportez pour un grossiste qui dépose le bilan. Vous pouvez exiger paiement directement du fabricant (expéditeur) ou du détaillant (destinataire).

---

## 3. Le commissionnaire de transport

### 3.1 Statut

Le **commissionnaire de transport** est défini par l'**article L. 132-1 du Code de commerce** : « celui qui agit en son propre nom pour le compte d'un commettant ». Il **organise** un transport en **choisissant librement** les modes (route, fer, mer, aérien) et les transporteurs.

### 3.2 Conditions d'accès au métier

- Inscription au **registre des commissionnaires** tenu par la DREAL.
- **Capacité professionnelle** : titre RNCP de niveau 5 (BAC+2) minimum + expérience ou attestation après examen.
- **Honorabilité** professionnelle (casier vierge des infractions transport).
- **Garantie financière** de **100 000 €** minimum pour les marchandises.

### 3.3 Responsabilité de plein droit (art. L. 132-4 à L. 132-9 C. com.)

C'est la **caractéristique majeure** du commissionnaire : il répond **du résultat** du transport, et pas seulement du choix du transporteur.

> Si la marchandise est détruite par sa faute ou par celle d'un transporteur sous-traité, **c'est le commissionnaire qui indemnise le client**, charge à lui de se retourner ensuite contre le transporteur fautif.

| Comparaison | Transporteur public | Commissionnaire |
|---|---|---|
| Choix du mode | Imposé par le DO | Libre |
| Prix au client | Tarif transporteur | Libre (marge sur sous-traitance) |
| Responsabilité | Obligation de moyen renforcée | Obligation de **résultat** |
| Indemnisation | Plafonds contrat-type | Plafonds contrat-type aussi (CMR à l'international) |

### 3.4 Le commissionnaire vs le transporteur (test pratique)

**Question : « Suis-je commissionnaire ou transporteur ? »** Quatre indices :
1. Est-ce que je **choisis** moi-même comment transporter ? Oui = commissionnaire.
2. Est-ce que je **facture une prestation organisationnelle** au-delà du transport pur ? Oui = commissionnaire.
3. Est-ce que je **prends une marge** sur la sous-traitance ? Oui = commissionnaire.
4. Est-ce que je **garantis** la livraison contre vol ou avarie au-delà des plafonds contrat-type ? Oui = commissionnaire.

---

## 4. Le transporteur public

### 4.1 Statut

Le **transporteur public routier de marchandises (TPRM)** est l'entreprise qui exécute matériellement le transport contre rémunération.

### 4.2 Conditions d'accès (LOTI 1982 + Code transports)

- Inscription au **registre électronique national des entreprises de transport routier (REGT)** tenu par la DREAL.
- **4 conditions cumulatives** :
  1. Établissement stable en France.
  2. **Honorabilité** professionnelle.
  3. **Capacité financière** (9 000 € pour le 1er véhicule + 5 000 € par véhicule suppl., ou 1 800 € + 900 € pour ≤ 3,5 T).
  4. **Capacité professionnelle** : attestation de capacité au transport (titre RNCP ou examen).

### 4.3 Sous-catégories

- **Transport public de marchandises** : tout véhicule moteur > 3,5 T PTAC.
- **Transport léger de marchandises** (TLM) : véhicules ≤ 3,5 T PTAC.
- **Loueur de véhicule industriel avec conducteur** (LOTI distinct).

---

## 5. Cas particuliers et pièges juridiques

### 5.1 La sous-traitance limitée à 2 rangs

⚠️ **Article L. 3224-1 C. transports** — interdiction de sous-traiter plus de **2 rangs** dans le transport de marchandises. Schéma autorisé :

```
DO → Transporteur 1 → Sous-traitant 1
                             │
                             └─► [INTERDIT au-delà]
```

**Sanction** : 15 000 € amende + retrait de la licence pour le donneur d'ordre fautif.

### 5.2 Le tractionnaire (location de véhicule industriel avec conducteur)

Un **tractionnaire** loue son véhicule + conducteur à une entreprise. Différent de la sous-traitance car :
- Pas de marchandise au nom du tractionnaire.
- Facturation à la mise à disposition (€/jour ou €/heure), pas à la course.
- L'entreprise locataire assume le rôle de transporteur public.

### 5.3 Le faux commissionnaire (PIÈGE)

Une PME qui se présente comme « commissionnaire de transport » sans avoir la capacité professionnelle et la garantie financière de 100 000 € s'expose à :
- **Nullité** du contrat de commission.
- **Amende** 15 000 € (personne morale 75 000 €).
- **Inscription au registre national des sanctions** transport.

---

## 6. Cas pratique : reconstituer une chaîne logistique e-commerce

**Énoncé :** Un client à Marseille commande un canapé sur **Amazon**. Le canapé est expédié par **Maisons du Monde** (entrepôt à Lyon). Amazon utilise sa filiale **Amazon Logistics** qui sous-traite à **DPD France**, qui sous-traite la livraison du dernier kilomètre à **un transporteur indépendant local**. Reconstituez la chaîne et identifiez les rôles.

**Correction — chaîne reconstituée :**

:::flow
1. Maisons du Monde | Expéditeur
2. Amazon | Donneur d'ordre
3. Amazon Logistics | Commissionnaire
4. DPD France | Transporteur (1ᵉʳ rang)
5. Indépendant local | Sous-traitant (2ᵉ rang)
6. Client Marseille | Destinataire
:::

**Vérifications juridiques :**
- 2 rangs de sous-traitance : OK (Amazon Log → DPD = rang 1, DPD → indé = rang 2).
- Si Amazon Logistics est inscrit comme commissionnaire (ou en a la capacité) : OK.
- Le transporteur indépendant doit avoir sa licence transport TLM (≤ 3,5 T) : à vérifier au REGT.
- Si litige avarie canapé, c'est **Amazon Logistics** qui indemnise le client (responsabilité du commissionnaire), puis se retourne contre DPD ou l'indépendant.

---

## 7. Mini-exercice à faire seul

**Énoncé :** Vous êtes chez **Stef Logistics** (commissionnaire). Un client (Lactalis) vous demande d'organiser le transport de 18 palettes de fromages frais (température dirigée 0-4°C) de Laval (53) vers la GMS Système U à Carquefou (44).

Vous décidez de sous-traiter à **Transports Boucherie** (PME locale). Stef facturera 950 € HT à Lactalis et achètera la prestation à Boucherie pour 720 € HT.

**Questions :**
1. Quel est le rôle de Stef ? De Boucherie ? De Lactalis ?
2. Quelle marge brute Stef réalise-t-elle ?
3. Si la chaîne du froid est rompue et la marchandise détruite (28 000 €), qui indemnise Lactalis en premier ?
4. Stef peut-il se retourner contre Boucherie ? À quel titre ?

> 💡 Réponses en fin de module (corrections § 4).

---

## 8. Glossaire

- **Chargeur / Expéditeur** : celui qui remet physiquement la marchandise.
- **Donneur d'ordre (DO)** : celui qui commande et qui paye.
- **Commissionnaire** : organisateur libre du transport, responsabilité de résultat.
- **Transporteur public** : exécutant inscrit au registre, responsabilité de moyen renforcée.
- **Sous-traitant** : transporteur exécutant pour un autre transporteur (max 2 rangs).
- **Tractionnaire** : loueur de véhicule industriel avec conducteur.
- **REGT** : Registre Électronique National des Entreprises de Transport.
- **Action directe** (art. L. 3242-3) : droit du transporteur impayé d'exiger le règlement de l'expéditeur ou du destinataire.
- **Garantie financière** : 100 000 € minimum pour le commissionnaire (art. R. 1411-9).

---

## 9. Synthèse opérationnelle

1. **6 acteurs** dans la chaîne : expéditeur, DO, commissionnaire, transporteur public, sous-traitant, destinataire.
2. **Donneur d'ordre = celui qui commande et paye**. Pas forcément l'expéditeur.
3. **Commissionnaire** : choix libre + responsabilité de **résultat**, garantie financière 100 k€.
4. **Transporteur public** : 4 conditions d'accès (REGT) — honorabilité, capacité financière, capacité professionnelle, établissement.
5. **Sous-traitance limitée à 2 rangs** (sanction 15 k€).
6. **Action directe** : transporteur impayé peut exiger paiement de l'expéditeur ou destinataire.
7. **Tractionnaire ≠ sous-traitant** (location de véhicule + conducteur, pas transport).
8. **Tester sa qualification** : choix du mode + marge sur sous-traitance + garantie résultat = commissionnaire.

---

## ⚠️ Points de vigilance

- **Ne JAMAIS** se présenter comme commissionnaire sans la capacité professionnelle et la garantie 100 k€. Sanction lourde + nullité des contrats.
- **Vérifier l'inscription** REGT du sous-traitant à la signature (en ligne sur transports.gouv.fr).
- **Tracer** par mail toutes les instructions du DO (preuve en cas de litige).
- **Solidarité financière** : si le DO est insolvable, vous ne perdez pas tout (action directe).

## 💡 Astuces pro

- **Outil terrain** : application *Transporeon* ou *Shippeo* pour visualiser en temps réel les chaînes multi-acteurs.
- **Checklist signature commissionnaire** : K-bis du sous-traitant, attestation REGT, attestation URSSAF, attestation responsabilité civile transport (RCCT) à 1,5 M€ minimum.
- **Coup malin** : faire signer une convention-cadre annuelle avec vos sous-traitants réguliers (paiement, délais, RC) plutôt qu'un contrat par voyage. Gain de 80 % de paperasse.

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : différence chargeur / DO / destinataire ; chaîne typique e-commerce ; sous-traitance max 2 rangs.
- **QR cas pratique** : « Reconstituez la chaîne d'acteurs à partir de l'énoncé suivant, identifiez les responsabilités et les risques. »
- **Oral DP** : « Dans votre entreprise actuelle, qui est commissionnaire et qui est transporteur ? Justifiez. »

---

## 📌 Synthèse à retenir

### Les 6 acteurs en un coup d'œil

| Acteur | Rôle métier |
|---|---|
| **Expéditeur** | Remet physiquement la marchandise |
| **Donneur d'ordre** | Commande et paye — peut différer de l'expéditeur |
| **Commissionnaire** | Organise librement, garantit le résultat (caution 100 k€) |
| **Transporteur public** | Exécute matériellement (REGT obligatoire) |
| **Sous-traitant** | Transporteur d'un autre transporteur (max 2 rangs) |
| **Destinataire** | Reçoit la marchandise |

### Responsabilités juridiques

- **Commissionnaire** : obligation de **RÉSULTAT** (art. L. 132-4 C. com.)
- **Transporteur public** : obligation de **MOYEN RENFORCÉ** (contrat-type)

> ⚠️ **Les 4 règles d'or à ne jamais oublier**
>
> - Sous-traitance limitée à **2 rangs** maximum (sanction 15 000 € sinon)
> - Vérifier l'inscription **REGT** à chaque signature de sous-traitant
> - **Action directe** (art. L. 3242-3) si le donneur d'ordre est insolvable
> - **Garantie financière commissionnaire** : 100 000 € MINIMUM
$lessonG1$,
'Identifier les 6 acteurs de la chaîne du transport routier (expéditeur, DO, commissionnaire, transporteur, sous-traitant, destinataire), distinguer leurs responsabilités juridiques (résultat vs moyen), maîtriser la règle des 2 rangs de sous-traitance et l''action directe en cas d''impayé.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Qualifier une demande de transport (méthode SACO)
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Qualifier une demande de transport — méthode SACO',
    'qualifier-demande-saco',
    2, 45,
$lessonG2$
# Qualifier une demande de transport — méthode SACO

> 🎯 **Objectifs pédagogiques**
>
> - **Appliquer** la méthode SACO pour qualifier une demande.
> - **Identifier** les 18 informations clés à recueillir systématiquement.
> - **Détecter** les contraintes spéciales (ADR, ATP, exceptionnel, animaux).
> - **Construire** une fiche de prise de commande exploitable.
> - **Refuser** professionnellement une demande mal qualifiée.

---

## Introduction

Une demande mal qualifiée = **30 % des litiges transport**, **50 % des dépassements de coût** et **80 % des refus client à la livraison**. La qualification est le **moment de vérité commerciale** : c'est là que vous transformez un besoin flou en une **prestation calibrée et pricée**.

Le pro ne dit jamais « oui » avant d'avoir qualifié. Il pose des questions. Il valide par écrit. Il signe un bon de commande. **Une demande non qualifiée écrite ne vaut rien** : elle ne créera pas de contrat, et pire, elle exposera votre entreprise à des risques juridiques et opérationnels.

Cette leçon vous donne la méthode **SACO** (Source-Activité-Contenu-Objectif) — l'outil de référence des services exploitation pour qualifier en 12-15 minutes une demande quelle qu'elle soit.

---

## 1. La méthode SACO : 4 piliers

### 1.1 Vue d'ensemble

| Pilier | Question clé | Informations clés |
|---|---|---|
| **S — Source** | Qui ? D'où ? | DO, expéditeur, contact, adresse origine |
| **A — Activité** | Quoi ? Combien ? Comment ? | Nature marchandise, poids, dimensions, conditionnement |
| **C — Contraintes** | Quelles règles ? | ADR, ATP, dimensions exceptionnelles, créneaux, accessibilité |
| **O — Objectif** | Quand ? Où ? Pour combien ? | Adresse destination, créneaux, prix cible, contact destinataire |

### 1.2 La fiche de prise de commande SACO

**18 informations à recueillir** sans exception, regroupées en 4 blocs.

#### Bloc S — Source (5 informations)

- Donneur d'ordre : raison sociale + N° SIREN
- Contact DO : nom, téléphone, mail
- Adresse expéditeur (avec accès : quai, hayon, latéral, sol)
- Contact expéditeur sur site (nom + téléphone)
- Créneaux de chargement (date + heure début / heure fin)

#### Bloc A — Activité (6 informations)

- Nature de la marchandise (description + code NAF si possible)
- Poids brut total (kg)
- Dimensions globales (palettes 80×120, 100×120, ou autres)
- Nombre d'unités de conditionnement (palettes, colis, big bags, conteneurs)
- Conditionnement (filmé, sanglé, gerbable oui / non)
- Valeur déclarée (pour calcul de l'indemnité forfaitaire R)

#### Bloc C — Contraintes (4 informations)

- ADR ? (oui / non + n° ONU + classe + groupe d'emballage)
- Température dirigée ATP ? (frais 0-4°C, surgelé −18°C)
- Transports exceptionnels ? (longueur > 12 m, largeur > 2,55 m, hauteur > 4 m)
- Manutention (transpalette, gerbeur, hayon obligatoire ?)

#### Bloc O — Objectif (3 informations)

- Adresse destinataire (avec accès)
- Créneaux de livraison (date + heure début / heure fin)
- Contact destinataire + budget cible (si annoncé)

---

## 2. Source : qui demande, d'où ?

### 2.1 Identifier le donneur d'ordre

Le DO **paye** la facture. Vous devez :
- Vérifier la **raison sociale exacte** (Pages Jaunes Pro, Infogreffe).
- Récupérer le **SIREN/SIRET** (souvent absent des demandes par mail).
- Demander un **K-bis < 3 mois** si nouveau client.
- Vérifier la **solvabilité** (Coface, Ellisphere, Creditsafe).

⚠️ **Piège fréquent** : un nouveau client envoie une commande urgente le vendredi à 17h pour un transport lundi 8h. Vous n'avez pas le temps de vérifier la solvabilité ⇒ refus, ou exigence de paiement comptant.

### 2.2 Adresse de chargement et accessibilité

Une adresse précise = **% de coût de revient**. Une adresse mal qualifiée peut coûter 50-200 € de surcoût au km :
- Quai = chargement rapide (15-30 min) — pas de surcoût.
- Sol + transpalette = +30 min (10-20 €).
- Sol + manutention manuelle = +60 min (40-80 €).
- Hayon obligatoire = véhicule équipé spécifique (+5-10 % du coût total).
- Camion porteur 19T impossible (rue étroite) = bascule sur VUL = +30 % de coût.

### 2.3 Cas concret : qualification d'adresse

**Énoncé** : « 12 rue de la Paix, 75002 Paris ». Insuffisant. À qualifier :
- Étage ? RDC ou n° d'étage avec ascenseur ?
- Code accès ? Digicode ?
- Quai de déchargement existant ?
- Stationnement véhicule possible ?
- Heure de bureau (9h-18h) ou horaires étendus ?

**Action** : envoyer un **email récapitulatif** au client avec les questions, demander confirmation par retour. Sans réponse = pas de prise de commande.

---

## 3. Activité : qualifier la marchandise

### 3.1 Nature et codification

| Catégorie | Exemples | Codification |
|---|---|---|
| Marchandises générales | Mobilier, vêtements, hi-tech | NST 09 |
| Denrées périssables | Yaourts, viande, plats préparés | NST 04 |
| Matières dangereuses | Carburants, peintures, gaz | ADR + n° ONU |
| Produits frigorifiques | Surgelés, glaces | ATP type Frigorifique |
| Produits pharmaceutiques | Médicaments, vaccins | BPDM (Bonnes Pratiques) |
| Animaux vivants | Bétail, équidés | Règlement CE 1/2005 |
| Déchets | DIB, DEEE, dangereux | Récépissé déchets |

### 3.2 Poids et dimensions

**Règle d'or** : toujours valider le **poids brut** (= poids net + emballage + palette). Une palette Europe pèse 25 kg à vide. 30 palettes = 750 kg de palettes seuls.

**Dimensions standard de palette** :
- **Europe (EUR)** : 80 × 120 cm — la référence.
- **Industrielle (US/PMR)** : 100 × 120 cm.
- **Demi-palette** : 80 × 60 cm.

**Hauteur palette** : standard 1,80 m max (gerbable simple), 2,40 m maxi avec hayon arrière.

### 3.3 Conditionnement et gerbage

- **Gerbable** : on peut empiler une 2e palette par-dessus → optimisation chargement.
- **Non gerbable** (« no stack ») : impossibilité, perte de place, surcoût.
- **Filmé / sanglé** : conditionnement de sécurité, indispensable pour palette stable.

⚠️ Un client qui annonce « 30 palettes » sans préciser gerbage / hauteur / poids unitaire = **demande non qualifiée**. Refusez ou facturez en mode forfait avec marge.

### 3.4 Calcul du volume occupé en porteur

Un porteur 12 t standard = **environ 36 palettes Europe** au sol (gerbage simple) ou **72 palettes** si gerbage double (rares en pratique).

Un semi-remorque 40 t = **33 palettes au sol** (90 m² de plancher) ou **66 si gerbage** (chargement « doublé »).

**Cas pratique** : 30 palettes Europe gerbables × 25 kg + marchandise = 600 kg/palette = 18 tonnes ⇒ semi-remorque obligatoire.

---

## 4. Contraintes spéciales

### 4.1 ADR (matières dangereuses)

L'ADR (Accord européen) liste 9 classes :

| Classe | Exemples | N° ONU type |
|---|---|---|
| 1 | Explosifs | 0084 (gaz toxique) |
| 2 | Gaz comprimés (butane, oxygène) | 1075, 1072 |
| 3 | Liquides inflammables (essence, peintures) | 1203, 1263 |
| 4 | Solides inflammables | — |
| 5 | Comburants (peroxydes) | — |
| 6 | Toxiques | — |
| 7 | Radioactifs | — |
| 8 | Corrosifs (acides, soude) | 1789, 1824 |
| 9 | Diverses | — |

**Implications transport** : conducteur avec FCO ADR, plaque orange, fiche de sécurité, document de transport spécifique. Surcoût 15-30 % vs marchandises générales.

### 4.2 ATP (températures dirigées)

| Type | Température | Marchandises |
|---|---|---|
| **IR (Frigorifique)** | 0-7°C | Yaourts, viande, charcuterie |
| **IN (Renforcé)** | −20°C | Surgelés, glaces |
| **RR (Frais)** | 12-15°C | Vins, fruits exotiques |

Véhicule certifié ATP avec bouchon, sondes, enregistreur. Contrôle DGCCRF possible.

### 4.3 Transports exceptionnels

| Critère | Limite | Au-delà |
|---|---|---|
| Longueur | ≤ 16,5 m semi | Convoi exceptionnel + autorisation préfectorale |
| Largeur | ≤ 2,55 m | Convoi 1ère cat. (≤ 3 m) ou suivante |
| Hauteur | ≤ 4 m | Itinéraire à valider (ponts, tunnels) |
| Poids | ≤ 44 t | Convoi 1ère cat. (≤ 48 t) ou suivantes |

**Délais** d'autorisation : 2 à 8 semaines selon catégorie. À anticiper !

### 4.4 Animaux vivants

Règlement CE 1/2005 : conducteur formé (CAPATAV), véhicule type, densité maximale, abreuvement. Hors champ d'un GOTRM standard mais à signaler en cas de demande.

---

## 5. Objectif : où, quand, pour combien

### 5.1 Adresse de livraison et créneaux

Mêmes exigences que l'adresse de chargement. Spécificités :
- **GMS** (Carrefour, Auchan, etc.) : créneaux de 30 min, retard = pénalité 100-300 €.
- **Industriel** : flexibilité variable, souvent 8h-12h / 14h-17h.
- **Chantier** : horaires courts (8h-16h), accessibilité PL parfois impossible.
- **Particulier** : créneau 4h (8h-12h ou 14h-18h), souvent absent → frais nouvelle livraison 50-100 €.

### 5.2 Engagement de délai

Distinction critique :
- **Date indicative** : pas d'engagement contractuel, retard tolérable.
- **Date impérative ou « engagée »** : contractuelle, pénalités contractuelles si retard.
- **Heure stricte** : pour GMS, PMR (point de regroupement) — tolérance 0.

⚠️ **Erreur fréquente** : accepter une « livraison avant 14h » sans contractualisation. En cas de retard, le client refuse de payer la facture totale. Toujours **écrire** dans le devis : « livraison souhaitée avant 14h, sans engagement contractuel sur l'horaire ».

### 5.3 Prix cible et budget client

Si le client annonce un budget : **noter** mais **ne pas s'aligner aveuglément**. Calculer votre coût de revient (cf. Module D Capa pour la méthode CRKM) et appliquer la marge cible. Si le budget client < votre prix → négocier ou refuser.

---

## 6. Cas pratique d'examen

**Énoncé** : Un client (« Boulangerie Pasquier ») envoie cette demande par mail :

> « Bonjour, j'ai 25 palettes de baguettes à faire livrer demain de Paris à Bordeaux. Pouvez-vous me faire un prix ? Cordialement. »

**Question : Listez les 12 informations manquantes pour qualifier correctement cette demande. Que faites-vous ?**

**Correction (informations manquantes) :**

S (Source) — manque :
1. SIREN du client (vérification solvabilité)
2. Adresse exacte de chargement Paris (zone industrielle, voie publique ?)
3. Créneau de chargement (heure début/fin)
4. Contact site chargement (nom + tél)

A (Activité) — manque :
5. Poids unitaire palette + poids total (baguettes = léger, donc volume ≠ tonnage)
6. Hauteur des palettes (gerbables ou pas)
7. Conditionnement (filmées, sanglées, sur PMR ou EUR ?)
8. Température (baguettes = ambiante OK, mais à vérifier)

C (Contraintes) — manque :
9. Hayon nécessaire à la livraison ?
10. Accès PL au site Bordeaux (dépôt boulangerie ou plateforme ?)

O (Objectif) — manque :
11. Adresse exacte de livraison Bordeaux
12. Créneau de livraison (avant 6h pour mise en rayon ? ou flexible ?)

**Action attendue** : envoyer un mail réponse structuré (template SACO), demander confirmation sous 24 h. **Ne pas donner de prix** avant qualification complète. Si demande pour lendemain et qualification incomplète à J-1 18h, **refus argumenté** ou **prix forfait + 30 % marge de précaution**.

---

## 7. Mini-exercice à faire seul

**Énoncé** : Un client industriel pharmaceutique vous demande le transport de 8 palettes EUR de vaccins (hauteur 1,40 m, gerbables 2 niveaux), à température dirigée 2-8°C, du site de production à Tours vers une plateforme à Lille, livraison à J+1 avant 9h, valeur déclarée 180 000 €.

**Listez** les 5 contraintes spéciales à activer dans le devis.

> 💡 Réponse en fin de module (corrections § 4).

---

## 8. Glossaire

- **SACO** : méthode de qualification (Source / Activité / Contraintes / Objectif).
- **NST** : Nomenclature Statistique des Transports (catégories marchandises).
- **UC** : Unité de Conditionnement (palette, colis, big bag).
- **Gerbable** : se dit d'une palette pouvant supporter une autre palette par-dessus.
- **PMR** : Palette Métrique Réutilisable (industrielle US 100×120).
- **ATP** : Accord sur les Transports Périssables (températures dirigées).
- **ADR** : Accord européen sur les marchandises Dangereuses par Route.
- **GMS** : Grande et Moyenne Surface (Carrefour, Leclerc, etc.).
- **Pénalité de créneau** : pénalité financière en cas de non-respect d'un créneau de livraison GMS.
- **Hayon** : plate-forme élévatrice à l'arrière du véhicule, pour livraison sans quai.

---

## 9. Synthèse opérationnelle

1. **Méthode SACO** : Source / Activité / Contraintes / Objectif → 18 infos à recueillir.
2. **Source** : DO, expéditeur, adresse, accessibilité, créneau chargement.
3. **Activité** : nature, poids brut, dimensions, conditionnement, gerbable.
4. **Contraintes** : ADR, ATP, transports exceptionnels, manutention.
5. **Objectif** : adresse + créneaux livraison + budget cible.
6. **Pas de prix sans qualification complète** — sinon perte sur litige garantie.
7. **Tracer par mail** chaque échange avec le client.
8. **Outils** : fiche de prise de commande standardisée, TMS avec champs obligatoires.

---

## ⚠️ Points de vigilance

- **Ne JAMAIS** prendre une commande verbale sans suivi mail. Un mail = preuve.
- **Adresse mal qualifiée** = 80 % des dépassements horaires. Toujours valider l'accessibilité.
- **« Livraison demain matin »** sans heure précise = **piège**. Toujours préciser.
- **Valeur déclarée** : si > 14 €/kg en marchandises générales (contrat-type), faire signer une déclaration de valeur, sinon plafond R automatique.

## 💡 Astuces pro

- Faire une **fiche standard SACO** dans Outlook/Notion à envoyer avant tout devis. Gain : 60 % du temps de qualification.
- **TMS recommandés** : Akanea TMS, Mantis TMS, AS400 EVALI — tous ont des modèles de fiche SACO intégrés.
- **Photo du chargement** : demander systématiquement une photo des palettes au client = preuve du conditionnement initial.

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : composants de la méthode SACO ; nombre d'infos clés ; règles ATP/ADR.
- **QR cas pratique** : « Qualifiez la demande suivante en listant toutes les informations manquantes » (typique BC01).
- **Oral** : « Décrivez votre processus de prise de commande dans votre entreprise actuelle. »

---

## 📌 Synthèse à retenir

### La méthode SACO en un mot

| Pilier | Ce qu'il couvre |
|---|---|
| **S — Source** | DO, expéditeur, adresse, accès, créneau |
| **A — Activité** | Nature, poids, dimensions, colis, gerbable |
| **C — Contraintes** | ADR, ATP, exceptionnel, manutention |
| **O — Objectif** | Adresse livraison, créneau, prix cible |

> 📌 **18 informations clés à recueillir** systématiquement
>
> 5 source · 6 activité · 4 contraintes · 3 objectif

### Standards palettes

| Type | Dimensions | Usage |
|---|---|---|
| **EUR** | 80 × 120 cm | Standard européen |
| **PMR** | 100 × 120 cm | Industrielle US |
| **Demi-palette** | 80 × 60 cm | Petits volumes |

**Gerbable** = empilable (gain volume) · **Non gerbable** = perte ~50 % de place

### ATP — températures dirigées

- **Frigorifique (IR)** : 0 à 7°C
- **Renforcé (IN)** : −20°C
- **Frais (RR)** : 12 à 15°C

**ADR** : 9 classes de matières dangereuses (n° ONU + plaque orange obligatoire).

> ⚠️ **Les 4 pièges à éviter absolument**
>
> - **Pas de prix** sans qualification complète SACO
> - **Tracer par mail** chaque échange (preuve juridique)
> - « Livraison demain matin » → toujours **préciser l'heure exacte**
> - **Hayon, accessibilité PL, créneau GMS** = à valider AVANT devis
$lessonG2$,
'Maîtriser la méthode SACO pour qualifier une demande en 12-15 minutes : 18 informations clés (origine, marchandise, contraintes ADR/ATP/exceptionnel, livraison) — éviter 80 % des litiges en sortie de devis.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Cadre juridique de la demande
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Cadre juridique de la demande de transport',
    'cadre-juridique-demande',
    3, 45,
$lessonG3$
# Cadre juridique de la demande de transport

> 🎯 **Objectifs pédagogiques**
>
> - **Connaître** la hiérarchie des sources juridiques applicables.
> - **Maîtriser** le contrat-type général (décret 99-269).
> - **Rédiger** des CGV transporteur conformes.
> - **Distinguer** transport national (contrat-type) et international (CMR).
> - **Identifier** les mentions obligatoires d'un devis et d'une facture.

---

## Introduction

Beaucoup de transporteurs croient qu'« en l'absence de contrat signé, il n'y a pas de règles ». **C'est l'inverse** : en l'absence de contrat écrit, c'est le **contrat-type général** (décret 99-269 du 6 avril 1999) qui s'applique d'office, **avec ses règles favorables au transporteur** (plafonds d'indemnité, délais de paiement, etc.).

Connaître ce cadre juridique = **3 avantages décisifs** :
1. **Refuser** des conditions abusives (clauses « pénalités illimitées » des GMS).
2. **Limiter** votre responsabilité en cas d'avarie (plafond contrat-type < 14 €/kg).
3. **Recouvrer** rapidement vos impayés (action directe LME 60 jours).

Cette leçon vous donne les **5 textes clés** à connaître + des modèles de clauses prêts à l'emploi.

---

## 1. La hiérarchie des sources juridiques

### 1.1 Vue d'ensemble (du plus fort au plus faible)

```
1. CONSTITUTION (droit de propriété, liberté du commerce)
        │
2. CODES (Commerce, Transports, Civil)
        │
3. CONVENTIONS INTERNATIONALES (CMR international)
        │
4. DÉCRETS / ARRÊTÉS (contrat-type 99-269)
        │
5. CGV transporteur (si signées par le client)
        │
6. CONTRAT particulier (devis, bon de commande)
        │
7. USAGES professionnels (codifiés FNTR, OTRE)
```

### 1.2 La règle de conflit

En cas de **conflit** entre deux sources :
- La **plus haute prime** (loi > décret > CGV).
- Sauf **exception** : un contrat particulier peut **déroger** au contrat-type général s'il est signé des deux parties (art. L. 1432-2 C. transports).

### 1.3 Cas pratique : qui prime ?

**Énoncé** : Un client GMS impose dans son bon de commande une « pénalité de retard de 1 000 €/h ». Le contrat-type général ne prévoit pas de pénalité de retard automatique. Que se passe-t-il ?

**Réponse** :
- Si vous **signez** le bon de commande → la pénalité s'applique (vous y avez consenti).
- Si vous **ne signez pas** → le contrat-type général s'applique → pas de pénalité automatique.
- **Astuce pro** : envoyer un contre-bon avec votre CGV qui plafonne les pénalités à un % du fret (typiquement 10 % pour les retards).

---

## 2. Le contrat-type général (décret 99-269)

### 2.1 Quand s'applique-t-il ?

Le **contrat-type général** s'applique **d'office** :
- En l'absence de contrat écrit entre transporteur et donneur d'ordre.
- Pour les transports nationaux de marchandises générales.
- Sauf accord contraire écrit.

### 2.2 Les règles clés à connaître

| Sujet | Règle contrat-type |
|---|---|
| **Délai de paiement** | 30 jours fin de décade (déc. 99-269 art. 14) |
| **Indemnité de retard** | Pas automatique. Sur preuve du préjudice subi. |
| **Plafond indemnité avarie/perte** | **14 €/kg de poids brut** (au-delà = déclaration de valeur préalable) |
| **Plafond indemnité par envoi** | **750 € si < 3 t** ou **2 300 € si > 3 t** |
| **Délai de réclamation** | 3 jours (avarie apparente) ou 7 jours (avarie cachée) à réception |
| **Prescription** | 1 an (art. L. 133-6 C. com.) |

### 2.3 La déclaration de valeur

Si la marchandise vaut **plus de 14 €/kg**, le client doit faire une **déclaration de valeur** par écrit **avant** le transport. Sinon, en cas d'avarie, le plafond contrat-type s'applique.

**Exemple** : 100 kg de bijoux à 5 000 €/kg = valeur 500 000 €. Sans déclaration de valeur ⇒ plafond indemnité = 100 × 14 = **1 400 €** seulement. Avec déclaration ⇒ indemnité au prix réel (l'assurance ad valorem doit être souscrite).

### 2.4 Les indemnités forfaitaires R

Il existe **5 contrats-types** spécifiques :
- **Général** (déc. 99-269, art. 13) — plafonds 14 €/kg.
- **Marchandises périssables** (réfrigéré).
- **Citernes** (matières liquides en vrac).
- **Animaux vivants**.
- **Déménagement**.

À chacun ses règles d'indemnité spécifiques.

---

## 3. Les CGV du transporteur

### 3.1 Pourquoi en avoir ?

Les **Conditions Générales de Vente** du transporteur permettent de **renforcer** votre position juridique au-delà du contrat-type :
- Plafonds d'indemnité spécifiques (en plus du R contrat-type).
- Conditions de paiement (acomptes, escompte).
- Garanties (clause de réserve de propriété, etc.).
- Compétence juridictionnelle (votre tribunal de commerce).

### 3.2 Mentions obligatoires des CGV

Pour être opposables au client, vos CGV doivent :
1. Être **transmises au client AVANT** la conclusion du contrat (par mail ou au dos du devis).
2. Être **acceptées** explicitement (signature ou mention « lu et approuvé ») ou **tacitement** (le client commande après réception).
3. Comporter les **mentions obligatoires** (art. L. 441-1 C. com.).

### 3.3 Modèle de clause type

**Exemple** : Clause de paiement
> « Le règlement intervient au plus tard le **30 du mois suivant la facturation** (LME 60 jours). En cas de retard, application de **pénalités au taux BCE majoré de 10 points**, calculées par jour de retard, et **indemnité forfaitaire de 40 €** (art. L. 441-10 C. com.). »

**Exemple** : Clause d'indemnité avarie/perte
> « Indemnité plafonnée à **14 €/kg poids brut** ou **750 €/2 300 € selon poids**, sauf déclaration de valeur préalable et écrite. »

### 3.4 Cas pratique : opposabilité des CGV

**Énoncé** : Vous avez transporté 30 palettes pour un nouveau client. La marchandise a été abîmée. Le client réclame 25 000 €. Vos CGV plafonnent à 14 €/kg = 18 000 €. Mais le client n'a **jamais reçu** vos CGV par mail.

**Question** : Peut-on lui opposer le plafond ?

**Réponse** :
- **Non** sur la base de vos CGV (non transmises = non opposables).
- **Mais oui** sur la base du **contrat-type général** (article 13 du décret 99-269), qui s'applique d'office en l'absence d'accord et plafonne aussi à 14 €/kg.

**Leçon** : transmettre vos CGV est une bonne pratique, **mais le contrat-type général reste votre dernier rempart**.

---

## 4. La CMR : transport international

### 4.1 Qu'est-ce que la CMR ?

La **Convention de Genève du 19 mai 1956 (CMR)** est la convention internationale qui régit le transport routier de marchandises **entre deux pays signataires** (UE + UK + Suisse + Norvège + Russie + Maroc + Tunisie + Turquie + autres = 56 pays).

### 4.2 Document CMR

Le **document CMR** (lettre de voiture internationale) est obligatoire pour tout transport international. Il comporte :
- Identité du donneur d'ordre, transporteur, destinataire.
- Lieux et dates de chargement/livraison.
- Description marchandise (nature, poids, nombre de colis).
- Instructions douanières.
- Réserves éventuelles.

3 exemplaires : 1 pour le DO, 1 pour le transporteur, 1 pour le destinataire.

### 4.3 Indemnité CMR

Plafond CMR : **8,33 DTS/kg** (Droits de Tirage Spéciaux, fixés par le FMI). 1 DTS ≈ 1,30 € en 2026.

⇒ Plafond CMR ≈ **10,80 €/kg** (vs 14 €/kg contrat-type général). Plus restrictif.

### 4.4 Délai de prescription CMR

**1 an** standard, **3 ans** en cas de dol ou faute lourde du transporteur.

---

## 5. Mentions obligatoires d'un devis et d'une facture

### 5.1 Devis (avant la prestation)

**Mentions** (art. L. 1432-3 C. transports) :
- Identité complète des parties (nom, adresse, SIRET).
- Description précise de la prestation (origine, destination, nature marchandise, poids).
- Prix HT, taux TVA, prix TTC.
- Délai d'exécution.
- Conditions de paiement.
- Validité du devis (souvent 30 jours).
- Référence au contrat-type ou aux CGV.

### 5.2 Facture (art. L. 441-9 C. com.)

**Mentions obligatoires** :
- Identité émetteur (nom, adresse, SIRET, n° TVA intracom).
- Identité destinataire.
- Date de la facture + date d'exécution.
- N° de facture (séquence sans rupture).
- Description prestation.
- Prix HT, taux TVA, prix TTC.
- Conditions de paiement (date d'échéance).
- Pénalités de retard et indemnité forfaitaire (clauses LME).
- Mention RIB pour paiement.

⚠️ **Sanction** facture incomplète : 75 000 € amende (personne physique), 375 000 € (personne morale). À ne pas négliger.

---

## 6. Cas pratique d'examen

**Énoncé** : Vous transportez 200 kg de matériel hi-tech (valeur 50 000 €) entre Lille et Paris pour un client B2B. Pas de contrat signé, pas de CGV transmises, pas de déclaration de valeur. Le chauffeur a un accident, marchandise détruite. Le client réclame 50 000 €.

**Questions :**
1. Quel régime juridique s'applique ?
2. Quel est le plafond d'indemnité ?
3. Comment auriez-vous pu vous protéger en amont ?

**Correction :**

1. **Contrat-type général** (déc. 99-269) — applicable d'office en l'absence de contrat écrit.
2. **Plafond** = min(14 €/kg × poids brut ; plafond par envoi)
   - 200 kg × 14 € = **2 800 €**.
   - Plafond par envoi < 3 t = 750 €.
   - **L'indemnité plafonne à 750 €** (le plus bas des deux).
3. **Protection** :
   - Faire signer un **bon de commande** précisant valeur déclarée (50 000 €) ⇒ plafond CT levé.
   - Souscrire une **assurance ad valorem** ou « tous risques marchandises ».
   - Transmettre vos CGV explicites par mail avant le transport.
   - Exiger un **paiement à la commande** ou en 30 jours date facture (vs LME 60 jours par défaut).

**Leçon** : **750 € pour 50 000 € de marchandise** = ratio 1,5 %. Le contrat-type est un cadre TRÈS protecteur du transporteur.

---

## 7. Mini-exercice à faire seul

**Énoncé** : Une PME fait livrer 50 kg de bijoux de luxe (valeur 80 000 €) sans déclaration de valeur. Le colis est volé en route. Calculez l'indemnité minimale due par le transporteur.

> 💡 Réponse en fin de module (corrections § 4).

---

## 8. Glossaire

- **Contrat-type général** : décret 99-269 du 6 avril 1999, applicable d'office.
- **CMR** : Convention de Genève 1956 sur le transport routier international.
- **CGV** : Conditions Générales de Vente du transporteur.
- **DTS** : Droit de Tirage Spécial (FMI), 1 DTS ≈ 1,30 €.
- **Indemnité ad valorem** : indemnité au prix réel, conditionnée à une déclaration de valeur préalable.
- **Action directe** : droit du transporteur impayé d'exiger le paiement de l'expéditeur ou du destinataire (art. L. 3242-3 C. transports).
- **LME** : Loi de Modernisation de l'Économie 2008. Délais paiement B2B : 60 j max date facture.
- **Indemnité forfaitaire R** : indemnité légale de retard du contrat-type général.
- **Réserve de propriété** : clause permettant au vendeur de récupérer le bien en cas de non-paiement.

---

## 9. Synthèse opérationnelle

1. **Hiérarchie** : Constitution > Codes > Conventions > Décrets > CGV > Contrat > Usages.
2. **Contrat-type général** (déc. 99-269) = défaut applicable. Plafond **14 €/kg + 750/2 300 € envoi**.
3. **CGV** = renforcement, opposables uniquement si transmises avant signature.
4. **CMR** = transport international, plafond **8,33 DTS/kg ≈ 10,80 €/kg**.
5. **Déclaration de valeur** = lever les plafonds, souscrire assurance ad valorem.
6. **Délais** réclamation : 3 j (avarie apparente) ou 7 j (cachée).
7. **Prescription** : 1 an (national), 1-3 ans (CMR).
8. **Mentions facture LME** : pénalités + indemnité 40 € obligatoires (art. L. 441-10).

---

## ⚠️ Points de vigilance

- **« Pas de contrat = pas de règles » est FAUX**. Le contrat-type général s'applique d'office.
- **CGV non transmises ≠ opposables**. Toujours les envoyer par mail au minimum 24h avant signature.
- **Bons de commande GMS** : lire les clauses pénalités. Beaucoup imposent 1 000 €/h, illégal sans contre-clause.
- **Déclaration de valeur** : **toujours** demander pour marchandise > 14 €/kg.

## 💡 Astuces pro

- **Modèle CGV gratuit** : OTRE, FNTR, FNTL proposent des modèles à jour, à adapter à votre activité.
- **Outil pratique** : créer un **bon de commande standard PDF** (1 page) avec clauses paiement, indemnité, juridiction. Faire signer électroniquement (DocuSign, Yousign).
- **Recouvrement** : factures impayées > 60 j = mise en demeure recommandée + intérêts de retard. Si récidive, action en référé devant le tribunal de commerce (procédure rapide 4-6 semaines).

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : plafonds contrat-type ; délais réclamation ; règles CMR vs national.
- **QR cas pratique** : « Quelle indemnité pour une marchandise détruite valant X €, sans déclaration de valeur ? »
- **Oral DP** : « Citez 3 clauses-clés de vos CGV transporteur et expliquez leur intérêt. »

---

## 📌 Synthèse à retenir

### Hiérarchie des sources juridiques

**Constitution** → **Codes** (Commerce, Transports) → **CMR** (international) → **Décrets** (contrat-type) → **CGV** transporteur → **Contrat** particulier → **Usages**

### Contrat-type général (décret 99-269)

Applicable **d'office** en l'absence de contrat écrit.

| Critère | Règle |
|---|---|
| Plafond avarie / perte | **14 €/kg** poids brut |
| Plafond par envoi | **750 €** (< 3 t) · **2 300 €** (> 3 t) |
| Délai réclamation | **3 j** (visible) · **7 j** (cachée) |
| Prescription | **1 an** |

> 📌 **Déclaration de valeur**
>
> Obligatoire si marchandise > 14 €/kg. Sinon le plafond contrat-type s'applique automatiquement (et le client subit la perte).

### CMR — transport international (Convention Genève 1956)

- Plafond : **8,33 DTS/kg** ≈ **10,80 €/kg**
- Document CMR obligatoire (**3 exemplaires** : DO, transporteur, destinataire)
- Prescription : 1 an (3 ans si dol)

### CGV transporteur — opposabilité

- **Transmises AVANT signature** (mail suffit)
- **Acceptation tacite** valide si commande après réception

> ⚠️ **Mentions obligatoires d'une facture (LME)**
>
> - Pénalités au taux **BCE majoré de 10 points**
> - **Indemnité forfaitaire 40 €** (art. L. 441-10 C. com.)
> - Sanction si manquement : **75 000 €** (PP) / **375 000 €** (PM)
$lessonG3$,
'Maîtriser la hiérarchie des sources (contrat-type général déc. 99-269, CMR international, CGV transporteur), les plafonds d''indemnité (14 €/kg national, 8,33 DTS/kg international), les délais de réclamation et les mentions obligatoires devis/facture LME.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Méthodologie MSP de traitement
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Méthodologie MSP de traitement de la demande',
    'methodologie-msp-traitement',
    4, 45,
$lessonG4$
# Méthodologie MSP de traitement de la demande

> 🎯 **Objectifs pédagogiques**
>
> - **Appliquer** la méthode MSP (Mesurer-Structurer-Pricer) à toute demande.
> - **Décider** GO/NO GO selon 4 critères objectifs.
> - **Construire** un devis professionnel en 15 minutes max.
> - **Refuser** une demande de manière argumentée et constructive.
> - **Suivre** un devis jusqu'à la conversion (CRM, relance).

---

## Introduction

Une demande mal traitée = perte de temps + perte client + risque litige. Une demande bien traitée = **conversion à 30-50 %** (vs 5-10 % en moyenne sectorielle), client fidélisé, marge sécurisée.

La **méthode MSP** (Mesurer-Structurer-Pricer) est l'outil de référence des services exploitation des grandes maisons françaises (Geodis, Kuehne+Nagel, ID Logistics). Elle s'appuie sur **6 étapes séquentielles** dont aucune ne peut être sautée sans risque.

À l'oral du DP RNCP 40990, le jury teste systématiquement votre maîtrise de cette méthode : « Décrivez votre processus de prise de commande dans votre entreprise actuelle. »

---

## 1. La méthode MSP : 6 étapes

:::timeline
1. **Réception et qualification** — phase Mesurer · 15-20 min · application de la méthode SACO
2. **Analyse des contraintes** — phase Mesurer · 10-15 min · légales, opérationnelles, capacitaires
3. **Recherche des informations manquantes** — phase Structurer · durée variable · relances J+1 / J+2 / J+3
4. **Décision GO / NO GO** — phase Structurer · 5-10 min · 4 critères pondérés
5. **Devis structuré** — phase Pricer · 15-20 min · en-tête, prix, conditions, CGV
6. **Suivi et conversion** — phase Pricer · continu · CRM, relances J+1/3/7/14
:::

**Durée totale** d'une qualification complète : 40 à 80 minutes selon complexité. À déléguer à un commercial transport ou exploiter en libre-service via un portail web (TMS B2B).

---

## 2. Étape 1 — Réception & qualification

### 2.1 Canaux de réception

- **Téléphone** : le plus rapide, mais pas tracé. À convertir immédiatement en mail.
- **Mail** : tracé, recommandé. À acquitter sous 1 h max (signal de pro).
- **Portail TMS B2B** (Transporeon, etc.) : déjà structuré, gain de temps.
- **EDI** (Échange de Données Informatisées) : automatisé, gros DO.
- **Téléphone portable WhatsApp** : à PROSCRIRE en B2B (non tracé, pas de preuve).

### 2.2 Acquittement

Toute demande doit être **acquittée** sous **60 minutes maximum** (norme professionnelle française) avec :

> « Bonjour, j'ai bien reçu votre demande de transport [origine → destination] pour [date]. Nous vous transmettons un devis structuré sous **24 heures**. À défaut, merci de nous contacter au [tél]. Cordialement. »

**Effet** : 30 % de conversion en plus que les concurrents qui mettent 4 h à répondre.

### 2.3 Qualification SACO complète

Dérouler la **fiche SACO** (cf. Leçon 2). Recueillir les **18 informations**. Si manquant : noter et passer à l'étape 3 (recherche d'informations).

---

## 3. Étape 2 — Analyse des contraintes

### 3.1 Contraintes légales

- **Capacité véhicule** : VUL ≤ 3,5 T ou PL > 3,5 T.
- **ADR** : conducteur ADR + véhicule équipé ?
- **ATP** : véhicule frigorifique ?
- **Cabotage UE** : limites de la directive 1071/2009.
- **Temps de conduite** : max 9 h/jour, 56 h/sem.

### 3.2 Contraintes opérationnelles

- **Disponibilité véhicule** à la date demandée ?
- **Disponibilité conducteur** (et compétences ADR/ATP) ?
- **Possibilité de groupage** avec d'autres demandes (optimisation) ?
- **Itinéraire faisable** dans les délais ?

### 3.3 Contraintes capacitaires (Yield Management)

- **Saturation parc** : si 100 % de la flotte est occupée, soit refus, soit sous-traitance.
- **Période** : juin = saison forte transport, marges +20 % possibles. Décembre = saison faible transport routier, marges -10 %.

### 3.4 Outil pratique : matrice Go/NoGo contraintes

| Contrainte | Réponse | Décision partielle |
|---|---|---|
| Véhicule disponible J ? | Oui / Non | NO si Non |
| Conducteur compétent ADR ? | Oui / N/A | NO si requis et Non |
| Itinéraire respect RSE ? | Oui / Non | NO si Non |
| Marge ≥ 15 % ? | Oui / Non | NO si Non |
| Capacité financière DO OK ? | Oui / Non / À vérifier | À vérifier ⇒ recherche |

Si **toutes les cases = OUI** ⇒ GO. Sinon ⇒ étape 3 (recherche) ou 4 (NO GO).

---

## 4. Étape 3 — Recherche des informations manquantes

### 4.1 Méthode de relance

Si une demande est mal qualifiée, **2 niveaux de relance** :

**Niveau 1 — Mail récapitulatif structuré** (à envoyer dans les 30 min suivant la demande)
> « Pour pouvoir vous transmettre un devis fiable, j'ai besoin de quelques précisions :
> 1. Hauteur palettes ?
> 2. Hayon nécessaire à la livraison ?
> 3. Créneau de livraison souhaité (heure début/fin) ?
> Merci de me confirmer sous 24 h. »

**Niveau 2 — Appel téléphonique** (si pas de réponse en 24 h)
- Reprendre le mail + insister sur les conséquences (devis incomplet, retard).
- Identifier un **interlocuteur de remplacement** (collègue, manager) si le contact initial est absent.

### 4.2 Délais à respecter

- **24 h max** entre demande client et 1ère relance.
- **48 h max** entre 1ère relance et 2e relance.
- **72 h** = limite avant **abandon de la piste** (sauf gros compte).

### 4.3 Escalade au DO direct

Si le contact opérationnel ne répond pas, **escalader** au :
1. Directeur logistique du DO.
2. Acheteur transport.
3. Contact commercial chez nous (cross-sell).

**Astuce** : LinkedIn Sales Navigator pour identifier les bons interlocuteurs.

---

## 5. Étape 4 — Décision GO / NO GO

### 5.1 Les 4 critères objectifs

| Critère | Seuil GO | Pondération |
|---|---|---|
| **Marge brute** ≥ ? | 15 % minimum (20 % cible) | 40 % |
| **Capacité disponible** ? | OUI obligatoire | 30 % |
| **Risque client** acceptable ? | Solvabilité < B (Coface) | 20 % |
| **Cohérence stratégique** ? | Cohérent avec axes / clients / volumes | 10 % |

### 5.2 Le score MSP

**Score MSP** = somme pondérée. Au-dessus de **70 %** = GO. Entre **50-70 %** = négociation. Sous **50 %** = NO GO.

**Exemple** :
- Marge 18 % → 18/30 = 60 % du critère, pondéré 40 % = **24 %**.
- Capacité OK → 30 % du critère, pondéré 30 % = **30 %**.
- Coface B+ → 70 % du critère, pondéré 20 % = **14 %**.
- Cohérence forte → 100 % du critère, pondéré 10 % = **10 %**.
- **Total = 78 %** ⇒ GO.

### 5.3 Refuser professionnellement

Si NO GO, **refus argumenté** sous 24 h max :

> « Bonjour, après analyse de votre demande, je ne suis pas en mesure de vous proposer un devis compétitif sur cette opération. La principale raison est [capacité saturée à cette date / marchandise hors notre cœur de métier / délai trop court]. Je peux vous orienter vers [partenaire 1] ou [partenaire 2] qui pourra répondre à votre besoin. Restant à votre disposition pour vos prochaines demandes. Cordialement. »

**Effets** : 80 % des clients reviennent à la prochaine demande, et l'image de pro est renforcée.

---

## 6. Étape 5 — Devis structuré

### 6.1 Anatomie d'un devis pro

| Section | Contenu |
|---|---|
| **En-tête** | Logo, raison sociale, SIRET, RCS, n° TVA, RIB |
| **Référence** | N° de devis (séquence), date émission, validité (30 j) |
| **Client** | Nom, adresse, contact (référence interne client si possible) |
| **Description prestation** | Origine → Destination, nature marchandise, poids, dimensions, type véhicule, créneaux |
| **Prix HT** | Détail (transport, hayon, ADR, ATP, péages, indemnités) |
| **TVA** | Taux 20 % (sauf intracom 0 %) |
| **Prix TTC** | Total |
| **Conditions** | Paiement (30/60 j), pénalités LME, indemnité 40 €, juridiction |
| **CGV** | Lien ou annexe |
| **Signature** | Bon pour accord, date, cachet |

### 6.2 Cas pratique : devis Lille-Marseille

**Données** :
- 1 PL 19 t.
- 660 km Lille → Marseille.
- 1 conducteur, 9 h conduite + 4 h amplitude.
- CRKM = 1,15 €/km.
- Marge cible 18 %.

**Calcul** :
- Coût direct : 660 × 1,15 = **759 €**.
- Coût conducteur : 9 h × 18 €/h coût total = **162 €**.
- Péages estimés : **75 €**.
- **Sous-total HT** : 996 €.
- **Marge 18 %** : 996 / 0,82 = **1 215 €**.
- **TVA 20 %** : 243 €.
- **Total TTC** : **1 458 €**.

Devis envoyé en PDF avec validité 30 jours.

### 6.3 Conditions de paiement

- **Standard B2B** : 30 jours fin de mois (LME max 60 j).
- **Nouveau client < 1 an** : acompte 30 % à la commande, solde 30 j.
- **Client TPE / particulier** : paiement comptant ou CB.
- **Client > 100 k€/an** : possibilité d'affacturage (Bibby, Eurofactor) pour cash-in immédiat.

---

## 7. Étape 6 — Suivi & conversion (CRM)

### 7.1 CRM minimum

Tout devis doit être suivi dans un CRM :
- **Pipedrive** (35 €/mois/user).
- **HubSpot CRM** (gratuit pour 2 users).
- **Salesforce** (75-150 €/mois/user).
- **Champs minimum** : DO, devis, prix, statut (Envoyé / Relancé / Gagné / Perdu), commentaires.

### 7.2 Plan de relance

| Jour | Action |
|---|---|
| J+1 | Mail accusé de réception du devis. |
| J+3 | Appel pour s'assurer de la réception et répondre aux questions. |
| J+7 | Mail de relance : « Avez-vous pris une décision ? Sinon, jusqu'à quand ? ». |
| J+14 | Appel + email final : « Sans retour, je considère le devis abandonné. ». |

### 7.3 Analyse des taux de conversion

- **Taux de conversion devis → commande** : indicateur clé. Cible **30-40 %** en B2B.
- Si < 20 % : revoir prix, qualité du devis, délai de réponse.
- Si > 50 % : prix peut-être trop bas, augmenter marges sur les prochaines.

---

## 8. Cas pratique d'examen

**Énoncé** : Un nouveau client (PME industrielle, CA 2 M€) vous contacte le **vendredi 18 h** pour un transport **lundi 8 h**. Demande : 8 palettes, 4 t, Paris → Lyon. Pas de SIREN fourni, pas d'adresse précise, juste « zone industrielle au sud de Paris ».

**Question** : Comment traitez-vous cette demande dans le respect de la méthode MSP ?

**Correction proposée :**

**Vendredi 18h-19h (Étape 1) :**
- Acquitter la demande par mail standard.
- Demander SIREN + adresse exacte + créneau précis chargement/livraison + nature marchandise + dimensions/gerbage.

**Vendredi 19h-20h (Étape 3) :**
- Si réponse client → continuer.
- Si pas de réponse → relance par mail avec rappel échéance lundi 8h.

**Samedi (Étape 2) :**
- Vérifier la disponibilité d'un véhicule lundi 8h Paris → Lyon (souvent saturé).
- Vérifier la solvabilité Coface si SIREN reçu (sinon refus).
- Vérifier la marge cible : 4 t Paris-Lyon ≈ 800 € coût direct. Marge 18 % = prix de vente ~ 980 €.

**Dimanche soir (Étape 4) :**
- Décision GO/NO GO :
  - Si toutes les infos OK + véhicule dispo + Coface OK → GO.
  - Si manque infos critiques → **NO GO documenté** : « Cher Monsieur, faute d'informations complètes, je ne peux pas garantir une exécution conforme lundi. Je propose une livraison mardi avec qualification complète d'ici lundi 14h. Cordialement. »

**Lundi matin (si GO) :**
- Devis envoyé 7h avec PDF.
- Bon de commande à signer dans la journée.
- Démarrage opérationnel dès signature.

**Leçon** : la méthode MSP **protège** le transporteur d'une exécution risquée et permet de **gagner** des clients pros qui apprécient le sérieux.

---

## 9. Mini-exercice à faire seul

Score MSP : devis 12 000 € ; coût total 9 800 € ; capacité disponible OUI ; Coface du client : « C » (risque élevé, 50 %) ; cohérence stratégique : 80 %.

**Calculez le score MSP. Décision GO / NO GO ?**

> 💡 Réponse en fin de module (corrections § 4).

---

## 10. Glossaire

- **MSP** : méthode Mesurer-Structurer-Pricer (process pro de gestion de demande).
- **CRM** : Customer Relationship Management (Pipedrive, HubSpot, Salesforce).
- **TMS** : Transport Management System (Akanea, Mantis, Stellium).
- **Yield management** : gestion dynamique des prix selon capacité et demande.
- **Cabotage** : transports nationaux effectués par un transporteur étranger (limites UE).
- **Coface / Ellisphere / Creditsafe** : agences de notation financière B2B.
- **Affacturage** : cession de créances commerciales contre cash immédiat (90-95 % de la valeur).
- **EDI** : Échange de Données Informatisées (norme EDIFACT en transport).
- **DocuSign / Yousign** : signatures électroniques certifiées EIDAS.

---

## 11. Synthèse opérationnelle

1. **MSP** = Mesurer (qualifier + analyser) → Structurer (rechercher + décider) → Pricer (devis + suivre).
2. **Acquittement** sous 1 h, devis sous 24 h max.
3. **4 critères GO/NO GO** : marge ≥ 15 %, capacité OK, risque client, cohérence stratégique.
4. **Score MSP** ≥ 70 % = GO direct ; 50-70 % = négocier ; < 50 % = NO GO.
5. **Devis pro** = en-tête + référence + description + prix + conditions + CGV + signature.
6. **CRM** obligatoire pour suivi devis et taux de conversion.
7. **Refus argumenté** = client conservé pour le futur.
8. **Outils** : Pipedrive, HubSpot, Akanea TMS, DocuSign.

---

## ⚠️ Points de vigilance

- **WhatsApp en B2B** : à proscrire (non tracé, perd le client en cas de litige).
- **Devis sans validité écrite** : le client peut commander 6 mois après au prix de l'époque.
- **Prix trop agressif** (marge < 10 %) : converti, mais perd 5 000 € sur l'opération si litige.
- **Acompte sur nouveau client** : exigez-le dès la 1ère commande, c'est un signal de pro.

## 💡 Astuces pro

- **Template Outlook** : créer 5-7 templates types (acquittement, demande infos, refus, devis, relance) → gain 70 % temps de rédaction.
- **Devis automatique** : pour transports répétitifs (clients réguliers), créer un calculateur Excel/Google Sheets avec votre CRKM intégré → devis en 30 secondes.
- **Indicateur clé** : mesurer le **lead-to-quote** (temps entre demande et envoi devis). Cible : **< 4 h ouvrées**.

---

## 12. Corrections des mini-exercices du module

### Leçon 1 — Stef, Boucherie, Lactalis
1. **Rôles** : Stef = commissionnaire (organise) ; Boucherie = transporteur sous-traité ; Lactalis = donneur d'ordre + expéditeur ; Système U = destinataire.
2. **Marge Stef** = 950 − 720 = **230 € HT** (24 % de marge).
3. **Indemnisation** : Stef indemnise Lactalis (responsabilité de résultat du commissionnaire, art. L. 132-4 C. com.).
4. **Recours** : Stef peut se retourner contre Boucherie au titre de la **responsabilité contractuelle** (faute de Boucherie sur la chaîne du froid). Limité aux plafonds contrat-type ATP.

### Leçon 2 — Vaccins Tours-Lille
Les **5 contraintes spéciales** :
1. **ATP IR** : 2-8°C, certificat ATP du véhicule.
2. **BPDM** : Bonnes Pratiques de Distribution du Médicament (transporteur certifié BPDM).
3. **Sécurité haute** : valeur 180 k€ ⇒ assurance ad valorem + véhicule équipé alarme/GPS.
4. **Délai engagé J+1 9h** : pénalité contractuelle si retard, à clarifier.
5. **Déclaration de valeur** : 180 k€ écrit dans le devis pour lever le plafond contrat-type 14 €/kg.

### Leçon 3 — Bijoux 50 kg, 80 000 €
- Sans déclaration de valeur, **plafond CT** = 50 × 14 = **700 €**.
- Plafond par envoi < 3 t = **750 €**.
- **Indemnité due** = min(700, 750) = **700 €**.
- **Préjudice client non indemnisé** : 80 000 − 700 = **79 300 €** à sa charge.

### Leçon 4 — Score MSP devis 12 000 €
- **Marge** = (12 000 − 9 800) / 12 000 = 18 % → 60 % du critère, pondéré 40 % = **24 %**.
- **Capacité** OK → 100 %, pondéré 30 % = **30 %**.
- **Coface C** = 50 % du critère, pondéré 20 % = **10 %**.
- **Cohérence** 80 %, pondéré 10 % = **8 %**.
- **Total = 72 %** ⇒ **GO avec acompte 30 %** (mitiger le risque Coface C).

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : étapes de la méthode MSP ; critères GO/NO GO ; mentions devis.
- **QR cas pratique** : « Décrivez votre traitement complet d'une demande arrivée vendredi 18 h pour lundi 8 h. »
- **Oral DP** : « Quels outils utilisez-vous pour suivre vos devis ? Quel est votre taux de conversion ? »

---

## 📌 Synthèse à retenir

### La méthode MSP en 6 étapes

**M — Mesurer**
1. Réception et qualification (méthode SACO)
2. Analyse des contraintes (légales, opérationnelles, capacitaires)

**S — Structurer**
3. Recherche d'informations manquantes (relances J+1 / J+2 / J+3)
4. Décision **GO / NO GO** (4 critères pondérés)

**P — Pricer**
5. Devis structuré (en-tête, prix, conditions, CGV)
6. Suivi et conversion (CRM, relances J+1 / J+3 / J+7 / J+14)

### Critères GO / NO GO

| Critère | Pondération |
|---|---|
| Marge ≥ 15 % (cible 20 %) | **40 %** |
| Capacité disponible | **30 %** |
| Risque client acceptable | **20 %** |
| Cohérence stratégique | **10 %** |

> 📌 **Décision selon le score MSP**
>
> - Score ≥ **70 %** → **GO**
> - Score **50-70 %** → négocier (acompte, conditions)
> - Score < **50 %** → **NO GO** argumenté (orienter vers partenaire)

### Outils recommandés

| Catégorie | Solutions |
|---|---|
| **CRM** | Pipedrive, HubSpot, Salesforce |
| **TMS** | Akanea, Mantis, Stellium |
| **Signature** | DocuSign, Yousign |
| **Solvabilité** | Coface, Ellisphere, Creditsafe |
$lessonG4$,
'Appliquer la méthode MSP (Mesurer-Structurer-Pricer) en 6 étapes pour traiter toute demande de transport : du premier contact au devis signé, avec critères GO/NO GO objectifs et plan de relance CRM.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- BANQUE DE QUESTIONS — 48 QCM + 8 QR
  -- =================================================================

  -- ===== LEÇON 1 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'Le donneur d''ordre est :',
   '[{"id":"a","label":"Le conducteur du véhicule","is_correct":false},{"id":"b","label":"Celui qui commande le transport et qui paye","is_correct":true},{"id":"c","label":"Celui qui reçoit la marchandise","is_correct":false},{"id":"d","label":"Le sous-traitant","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-01','lecon-1','acteurs'], 'mft-2026-gotrm:bc01-01-v3:l1:q1', true,
   'Art. L. 3221-1 C. transports : DO = personne pour le compte de laquelle le transport est exécuté, qui paie la facture.'),
  (v_formation, v_module, 'qcm', 'Le commissionnaire de transport :',
   '[{"id":"a","label":"Est seulement un courtier","is_correct":false},{"id":"b","label":"Choisit librement les modes et transporteurs, responsabilité de résultat","is_correct":true},{"id":"c","label":"Ne peut pas sous-traiter","is_correct":false},{"id":"d","label":"Doit être propriétaire des véhicules","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-01','lecon-1','commissionnaire'], 'mft-2026-gotrm:bc01-01-v3:l1:q2', true,
   'Art. L. 132-1 et L. 132-4 C. com. : commissionnaire organise librement et engage sa responsabilité de résultat (au-delà du choix des prestataires).'),
  (v_formation, v_module, 'qcm', 'La garantie financière minimale d''un commissionnaire de transport est de :',
   '[{"id":"a","label":"10 000 €","is_correct":false},{"id":"b","label":"50 000 €","is_correct":false},{"id":"c","label":"100 000 €","is_correct":true},{"id":"d","label":"500 000 €","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-01','lecon-1','garantie'], 'mft-2026-gotrm:bc01-01-v3:l1:q3', true,
   'Art. R. 1411-9 C. transports : 100 000 € minimum pour les marchandises (différent de la RC professionnelle).'),
  (v_formation, v_module, 'qcm', 'En transport routier de marchandises, la sous-traitance est limitée à :',
   '[{"id":"a","label":"1 rang maximum","is_correct":false},{"id":"b","label":"2 rangs maximum","is_correct":true},{"id":"c","label":"3 rangs maximum","is_correct":false},{"id":"d","label":"Aucune limite","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-01','lecon-1','sous-traitance'], 'mft-2026-gotrm:bc01-01-v3:l1:q4', true,
   'Art. L. 3224-1 C. transports : 2 rangs max. Sanction 15 000 € amende + retrait licence.'),
  (v_formation, v_module, 'qcm', 'L''action directe du transporteur impayé permet de :',
   '[{"id":"a","label":"Saisir directement les biens du DO","is_correct":false},{"id":"b","label":"Exiger le paiement de l''expéditeur ou du destinataire","is_correct":true},{"id":"c","label":"Refuser de livrer","is_correct":false},{"id":"d","label":"Doubler la facture","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-01','lecon-1','action-directe'], 'mft-2026-gotrm:bc01-01-v3:l1:q5', true,
   'Art. L. 3242-3 C. transports : si DO ne paye pas sous 30 j, le transporteur peut exiger paiement de l''expéditeur ou du destinataire.'),
  (v_formation, v_module, 'qcm', 'Le transporteur public routier doit être inscrit au :',
   '[{"id":"a","label":"Registre du commerce uniquement","is_correct":false},{"id":"b","label":"REGT (Registre Électronique national)","is_correct":true},{"id":"c","label":"URSSAF","is_correct":false},{"id":"d","label":"Médecine du travail","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-01','lecon-1','regt'], 'mft-2026-gotrm:bc01-01-v3:l1:q6', true,
   'Inscription au REGT (Registre Électronique national des entreprises de Transport) tenu par la DREAL.'),
  (v_formation, v_module, 'qcm', 'Un tractionnaire :',
   '[{"id":"a","label":"Est un transporteur","is_correct":false},{"id":"b","label":"Loue son véhicule + conducteur","is_correct":true},{"id":"c","label":"Est un commissionnaire","is_correct":false},{"id":"d","label":"N''existe pas en France","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-01','lecon-1','tractionnaire'], 'mft-2026-gotrm:bc01-01-v3:l1:q7', true,
   'Tractionnaire = location de véhicule industriel avec conducteur (LOTI). Différent du sous-traitant.'),
  (v_formation, v_module, 'qcm', 'La capacité financière d''un TPRM (> 3,5 T) pour le 1er véhicule est de :',
   '[{"id":"a","label":"1 800 €","is_correct":false},{"id":"b","label":"5 000 €","is_correct":false},{"id":"c","label":"9 000 €","is_correct":true},{"id":"d","label":"15 000 €","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-01','lecon-1','capacite-financiere'], 'mft-2026-gotrm:bc01-01-v3:l1:q8', true,
   '9 000 € pour le 1er véhicule + 5 000 € par véhicule supplémentaire (TPRM > 3,5 T). 1 800 € + 900 € pour TLM ≤ 3,5 T.'),
  (v_formation, v_module, 'qcm', 'Si un commissionnaire sans capacité professionnelle organise un transport :',
   '[{"id":"a","label":"Pas de conséquence","is_correct":false},{"id":"b","label":"Le contrat est nul + amende 15 000 € (75 000 € PM)","is_correct":true},{"id":"c","label":"Avertissement seulement","is_correct":false},{"id":"d","label":"Suspension de 1 mois","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-01','lecon-1','sanction'], 'mft-2026-gotrm:bc01-01-v3:l1:q9', true,
   'Nullité contrat + amende 15 k€ PP / 75 k€ PM + inscription registre national des sanctions.'),
  (v_formation, v_module, 'qcm', 'Dans une chaîne logistique e-commerce typique, qui indemnise le client final en cas d''avarie ?',
   '[{"id":"a","label":"Le sous-traitant transporteur","is_correct":false},{"id":"b","label":"Le commissionnaire qui a organisé","is_correct":true},{"id":"c","label":"Le destinataire lui-même","is_correct":false},{"id":"d","label":"L''État","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-01','lecon-1','responsabilite'], 'mft-2026-gotrm:bc01-01-v3:l1:q10', true,
   'Le commissionnaire est responsable du résultat (art. L. 132-4 C. com.). Il indemnise le client puis se retourne contre le sous-traitant.'),
  (v_formation, v_module, 'qcm', 'Le transport TLM (transport léger de marchandises) concerne les véhicules de :',
   '[{"id":"a","label":"≤ 3,5 T PTAC","is_correct":true},{"id":"b","label":"3,5 - 7,5 T","is_correct":false},{"id":"c","label":"7,5 - 12 T","is_correct":false},{"id":"d","label":"> 12 T","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-01','lecon-1','tlm'], 'mft-2026-gotrm:bc01-01-v3:l1:q11', true,
   'TLM = Transport Léger de Marchandises, véhicules ≤ 3,5 T PTAC. Au-dessus = TPRM (transport public routier de marchandises).'),
  (v_formation, v_module, 'qcm', 'Lequel de ces acteurs N''EST PAS un acteur du transport ?',
   '[{"id":"a","label":"L''expéditeur","is_correct":false},{"id":"b","label":"Le commissionnaire","is_correct":false},{"id":"c","label":"L''affréteur immobilier","is_correct":true},{"id":"d","label":"Le destinataire","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-01','lecon-1','piege'], 'mft-2026-gotrm:bc01-01-v3:l1:q12', true,
   'Question piège : l''affréteur immobilier n''existe pas (confusion avec affréteur transport). Les 6 acteurs réels sont : expéditeur, DO, commissionnaire, transporteur, sous-traitant, destinataire.');

  -- ===== LEÇON 2 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'La méthode SACO signifie :',
   '[{"id":"a","label":"Service Après Charge Organisé","is_correct":false},{"id":"b","label":"Source / Activité / Contraintes / Objectif","is_correct":true},{"id":"c","label":"Sécurité Active Commerce Objectif","is_correct":false},{"id":"d","label":"Stratégie / Approche / Coût / Organisation","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-01','lecon-2','saco'], 'mft-2026-gotrm:bc01-01-v3:l2:q1', true,
   'SACO = Source (qui/d''où) / Activité (quoi/combien) / Contraintes (règles) / Objectif (où/quand).'),
  (v_formation, v_module, 'qcm', 'Combien d''informations clés à recueillir dans la qualification SACO complète ?',
   '[{"id":"a","label":"5","is_correct":false},{"id":"b","label":"10","is_correct":false},{"id":"c","label":"18","is_correct":true},{"id":"d","label":"30","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-01','lecon-2','saco'], 'mft-2026-gotrm:bc01-01-v3:l2:q2', true,
   '18 informations : 5 source + 6 activité + 4 contraintes + 3 objectif.'),
  (v_formation, v_module, 'qcm', 'Une palette EUR a pour dimensions :',
   '[{"id":"a","label":"100 × 120 cm","is_correct":false},{"id":"b","label":"80 × 120 cm","is_correct":true},{"id":"c","label":"60 × 80 cm","is_correct":false},{"id":"d","label":"120 × 120 cm","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-01','lecon-2','palette'], 'mft-2026-gotrm:bc01-01-v3:l2:q3', true,
   'Palette EUR (Europe) standard : 80 × 120 cm. PMR (industrielle US) : 100 × 120 cm.'),
  (v_formation, v_module, 'qcm', 'Une palette « gerbable » signifie :',
   '[{"id":"a","label":"Très lourde","is_correct":false},{"id":"b","label":"Empilable, on peut mettre une autre palette par-dessus","is_correct":true},{"id":"c","label":"Fragile","is_correct":false},{"id":"d","label":"Peinte en vert","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-01','lecon-2','gerbable'], 'mft-2026-gotrm:bc01-01-v3:l2:q4', true,
   'Gerbable = empilable (gain de volume au chargement). Non gerbable = perte de place (~50 %).'),
  (v_formation, v_module, 'qcm', 'L''ATP IR (Frigorifique) impose une température de :',
   '[{"id":"a","label":"−20°C","is_correct":false},{"id":"b","label":"0-7°C","is_correct":true},{"id":"c","label":"12-15°C","is_correct":false},{"id":"d","label":"18-22°C","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-01','lecon-2','atp'], 'mft-2026-gotrm:bc01-01-v3:l2:q5', true,
   'ATP IR (Frigorifique) : 0-7°C (yaourts, viande). IN (Renforcé) : −20°C (surgelés). RR (Frais) : 12-15°C (vins).'),
  (v_formation, v_module, 'qcm', 'Un semi-remorque 40 t standard a une capacité au sol de :',
   '[{"id":"a","label":"15 palettes EUR","is_correct":false},{"id":"b","label":"33 palettes EUR","is_correct":true},{"id":"c","label":"66 palettes EUR","is_correct":false},{"id":"d","label":"100 palettes EUR","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-01','lecon-2','capacite'], 'mft-2026-gotrm:bc01-01-v3:l2:q6', true,
   'Semi 40 t standard ≈ 33 palettes EUR au sol (90 m² plancher). 66 si gerbage double (rare).'),
  (v_formation, v_module, 'qcm', 'Le transport exceptionnel commence dès que le véhicule dépasse :',
   '[{"id":"a","label":"2 m de largeur","is_correct":false},{"id":"b","label":"2,55 m de largeur","is_correct":true},{"id":"c","label":"3 m de largeur","is_correct":false},{"id":"d","label":"4 m de largeur","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-01','lecon-2','exceptionnel'], 'mft-2026-gotrm:bc01-01-v3:l2:q7', true,
   'Limites standards : longueur 16,5 m, largeur 2,55 m, hauteur 4 m, poids 44 t. Au-delà = convoi exceptionnel + autorisation préfectorale.'),
  (v_formation, v_module, 'qcm', 'Le code NST classe les marchandises :',
   '[{"id":"a","label":"Par valeur monétaire","is_correct":false},{"id":"b","label":"Par catégorie statistique de transport","is_correct":true},{"id":"c","label":"Par poids","is_correct":false},{"id":"d","label":"Par couleur d''emballage","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-01','lecon-2','nst'], 'mft-2026-gotrm:bc01-01-v3:l2:q8', true,
   'NST = Nomenclature Statistique des Transports. NST 04 = denrées périssables, NST 09 = marchandises générales.'),
  (v_formation, v_module, 'qcm', 'Pour livrer chez un particulier en RDC sans quai, il faut :',
   '[{"id":"a","label":"Un porteur 26 t","is_correct":false},{"id":"b","label":"Un véhicule avec hayon ou transpalette","is_correct":true},{"id":"c","label":"Un convoi exceptionnel","is_correct":false},{"id":"d","label":"Une grue","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-01','lecon-2','hayon'], 'mft-2026-gotrm:bc01-01-v3:l2:q9', true,
   'Hayon = plate-forme élévatrice arrière. Indispensable en livraison sans quai. Surcoût 5-10 %.'),
  (v_formation, v_module, 'qcm', 'En livraison GMS, le retard de créneau entraîne typiquement :',
   '[{"id":"a","label":"Aucune conséquence","is_correct":false},{"id":"b","label":"Une pénalité de 100-300 €","is_correct":true},{"id":"c","label":"Une suspension de licence","is_correct":false},{"id":"d","label":"Le doublement du fret","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-01','lecon-2','gms'], 'mft-2026-gotrm:bc01-01-v3:l2:q10', true,
   'Pénalités GMS contractuelles : 100-300 € par retard sur créneau (à plafonner dans CGV).'),
  (v_formation, v_module, 'qcm', 'Une demande mal qualifiée représente quel pourcentage des litiges ?',
   '[{"id":"a","label":"5 %","is_correct":false},{"id":"b","label":"15 %","is_correct":false},{"id":"c","label":"30 %","is_correct":true},{"id":"d","label":"60 %","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-01','lecon-2','statistique'], 'mft-2026-gotrm:bc01-01-v3:l2:q11', true,
   'Statistiques sectorielles : 30 % des litiges proviennent d''une qualification incomplète au démarrage.'),
  (v_formation, v_module, 'qcm', 'Que faire face à une demande arrivée par WhatsApp en B2B ?',
   '[{"id":"a","label":"Accepter sans condition","is_correct":false},{"id":"b","label":"La traiter mais demander confirmation par mail","is_correct":true},{"id":"c","label":"Refuser systématiquement","is_correct":false},{"id":"d","label":"Doubler le prix","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-01','lecon-2','whatsapp'], 'mft-2026-gotrm:bc01-01-v3:l2:q12', true,
   'WhatsApp non tracé en B2B = pas de preuve. Toujours basculer sur mail pour traçabilité (litige, comptabilité).');

  -- ===== LEÇON 3 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'En l''absence de contrat écrit, quel régime juridique s''applique au transport national ?',
   '[{"id":"a","label":"Code civil uniquement","is_correct":false},{"id":"b","label":"Le contrat-type général (décret 99-269)","is_correct":true},{"id":"c","label":"Aucun régime","is_correct":false},{"id":"d","label":"Le règlement européen","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-01','lecon-3','contrat-type'], 'mft-2026-gotrm:bc01-01-v3:l3:q1', true,
   'Décret 99-269 du 6 avril 1999 = contrat-type général applicable d''office. Toujours vérifier les autres CT spéciaux (frigo, citernes, animaux, déménagement).'),
  (v_formation, v_module, 'qcm', 'Le plafond d''indemnité du contrat-type général est de :',
   '[{"id":"a","label":"5 €/kg","is_correct":false},{"id":"b","label":"14 €/kg poids brut","is_correct":true},{"id":"c","label":"50 €/kg","is_correct":false},{"id":"d","label":"100 €/kg","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-01','lecon-3','plafond'], 'mft-2026-gotrm:bc01-01-v3:l3:q2', true,
   'Contrat-type général : 14 €/kg de poids brut. Sauf déclaration de valeur préalable (lève le plafond).'),
  (v_formation, v_module, 'qcm', 'Le plafond d''indemnité par envoi (envoi < 3 t) est de :',
   '[{"id":"a","label":"500 €","is_correct":false},{"id":"b","label":"750 €","is_correct":true},{"id":"c","label":"2 300 €","is_correct":false},{"id":"d","label":"10 000 €","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-01','lecon-3','plafond'], 'mft-2026-gotrm:bc01-01-v3:l3:q3', true,
   '750 € si envoi < 3 t ; 2 300 € si > 3 t. L''indemnité due = MIN(14 €/kg ; plafond par envoi).'),
  (v_formation, v_module, 'qcm', 'Le délai de réclamation pour une avarie apparente est de :',
   '[{"id":"a","label":"24 heures","is_correct":false},{"id":"b","label":"3 jours","is_correct":true},{"id":"c","label":"7 jours","is_correct":false},{"id":"d","label":"30 jours","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-01','lecon-3','reclamation'], 'mft-2026-gotrm:bc01-01-v3:l3:q4', true,
   'Avarie apparente : 3 jours. Avarie cachée : 7 jours. Au-delà = forclusion (perte du droit à indemnité).'),
  (v_formation, v_module, 'qcm', 'Le plafond CMR (transport international) est de :',
   '[{"id":"a","label":"5 €/kg","is_correct":false},{"id":"b","label":"8,33 DTS/kg ≈ 10,80 €/kg","is_correct":true},{"id":"c","label":"14 €/kg","is_correct":false},{"id":"d","label":"50 €/kg","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-01','lecon-3','cmr'], 'mft-2026-gotrm:bc01-01-v3:l3:q5', true,
   'CMR (Convention de Genève 1956) : 8,33 DTS/kg, soit ≈ 10,80 €/kg en 2026 (1 DTS ≈ 1,30 €). Plus restrictif que le national.'),
  (v_formation, v_module, 'qcm', 'Pour qu''une CGV transporteur soit opposable au client, il faut :',
   '[{"id":"a","label":"Rien, elle est automatique","is_correct":false},{"id":"b","label":"L''avoir transmise au client AVANT la conclusion du contrat","is_correct":true},{"id":"c","label":"L''envoyer après l''exécution","is_correct":false},{"id":"d","label":"L''afficher en mairie","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-01','lecon-3','cgv'], 'mft-2026-gotrm:bc01-01-v3:l3:q6', true,
   'Les CGV doivent être transmises AVANT signature (mail OK) + acceptation explicite ou tacite (commande après réception).'),
  (v_formation, v_module, 'qcm', 'Le délai de prescription d''une action en responsabilité contre le transporteur est de :',
   '[{"id":"a","label":"6 mois","is_correct":false},{"id":"b","label":"1 an","is_correct":true},{"id":"c","label":"2 ans","is_correct":false},{"id":"d","label":"5 ans","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-01','lecon-3','prescription'], 'mft-2026-gotrm:bc01-01-v3:l3:q7', true,
   'Art. L. 133-6 C. com. : prescription 1 an pour actions en responsabilité contre le transporteur (national). CMR : 1 an, 3 ans en cas de dol.'),
  (v_formation, v_module, 'qcm', 'L''indemnité forfaitaire de la LME pour facture impayée à échéance est de :',
   '[{"id":"a","label":"10 €","is_correct":false},{"id":"b","label":"40 €","is_correct":true},{"id":"c","label":"100 €","is_correct":false},{"id":"d","label":"5 % du fret","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-01','lecon-3','lme'], 'mft-2026-gotrm:bc01-01-v3:l3:q8', true,
   'Art. L. 441-10 C. com. : indemnité forfaitaire 40 € + intérêts au taux BCE majoré de 10 points par jour de retard.'),
  (v_formation, v_module, 'qcm', 'En cas d''absence de mention obligatoire sur une facture, l''amende maximum est de :',
   '[{"id":"a","label":"75 € par facture","is_correct":false},{"id":"b","label":"7 500 € par facture","is_correct":false},{"id":"c","label":"75 000 € PP / 375 000 € PM","is_correct":true},{"id":"d","label":"1 % du CA","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-01','lecon-3','sanction'], 'mft-2026-gotrm:bc01-01-v3:l3:q9', true,
   'Sanction lourde : 75 000 € pour personne physique, 375 000 € pour personne morale. Mentions obligatoires (art. L. 441-9 C. com.) à respecter strictement.'),
  (v_formation, v_module, 'qcm', 'La déclaration de valeur permet de :',
   '[{"id":"a","label":"Doubler le prix de transport","is_correct":false},{"id":"b","label":"Lever les plafonds d''indemnité du contrat-type","is_correct":true},{"id":"c","label":"Réduire la TVA","is_correct":false},{"id":"d","label":"Éviter le contrôle douanier","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-01','lecon-3','declaration-valeur'], 'mft-2026-gotrm:bc01-01-v3:l3:q10', true,
   'Déclaration de valeur écrite préalable = lève plafonds CT 14 €/kg / 750 €. Indemnité au prix réel + assurance ad valorem indispensable.'),
  (v_formation, v_module, 'qcm', 'Le document CMR international comporte combien d''exemplaires obligatoires ?',
   '[{"id":"a","label":"1","is_correct":false},{"id":"b","label":"2","is_correct":false},{"id":"c","label":"3","is_correct":true},{"id":"d","label":"5","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-01','lecon-3','cmr'], 'mft-2026-gotrm:bc01-01-v3:l3:q11', true,
   '3 exemplaires : 1 pour le DO, 1 pour le transporteur, 1 pour le destinataire. Quelques pays imposent un 4e (douane).'),
  (v_formation, v_module, 'qcm', 'Une bouteille de bijoux (50 kg, 80 000 €) sans déclaration de valeur est volée. Indemnité due :',
   '[{"id":"a","label":"80 000 € (le client est protégé)","is_correct":false},{"id":"b","label":"700 € maximum (plafond CT)","is_correct":true},{"id":"c","label":"40 000 € (50 % du préjudice)","is_correct":false},{"id":"d","label":"Aucune indemnité","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-01','lecon-3','calcul'], 'mft-2026-gotrm:bc01-01-v3:l3:q12', true,
   '50 kg × 14 € = 700 € < 750 € plafond envoi. Indemnité due = 700 €. Le client subit 79 300 € de préjudice non couvert. Importance de la déclaration de valeur !');

  -- ===== LEÇON 4 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'La méthode MSP signifie :',
   '[{"id":"a","label":"Méthode Stratégique de Pilotage","is_correct":false},{"id":"b","label":"Mesurer / Structurer / Pricer","is_correct":true},{"id":"c","label":"Marché / Service / Prix","is_correct":false},{"id":"d","label":"Mission Spécialisée Pro","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-01','lecon-4','msp'], 'mft-2026-gotrm:bc01-01-v3:l4:q1', true,
   'MSP = Mesurer (qualification + analyse) → Structurer (recherche + GO/NO GO) → Pricer (devis + suivi).'),
  (v_formation, v_module, 'qcm', 'Combien d''étapes contient la méthode MSP ?',
   '[{"id":"a","label":"3","is_correct":false},{"id":"b","label":"4","is_correct":false},{"id":"c","label":"6","is_correct":true},{"id":"d","label":"10","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-01','lecon-4','msp'], 'mft-2026-gotrm:bc01-01-v3:l4:q2', true,
   '6 étapes séquentielles : réception, analyse contraintes, recherche infos, GO/NO GO, devis, suivi.'),
  (v_formation, v_module, 'qcm', 'L''acquittement d''une demande client doit se faire sous :',
   '[{"id":"a","label":"15 minutes","is_correct":false},{"id":"b","label":"60 minutes maximum","is_correct":true},{"id":"c","label":"24 heures","is_correct":false},{"id":"d","label":"48 heures","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-01','lecon-4','acquittement'], 'mft-2026-gotrm:bc01-01-v3:l4:q3', true,
   'Norme professionnelle : acquittement < 60 min, devis < 24 h. +30 % de conversion vs concurrents lents.'),
  (v_formation, v_module, 'qcm', 'La marge brute minimum cible d''un transport B2B est de :',
   '[{"id":"a","label":"5 %","is_correct":false},{"id":"b","label":"15 % minimum (20 % cible)","is_correct":true},{"id":"c","label":"40 %","is_correct":false},{"id":"d","label":"80 %","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-01','lecon-4','marge'], 'mft-2026-gotrm:bc01-01-v3:l4:q4', true,
   '15 % minimum (couvre frais de structure et risque). Cible standard 20 %. Sous 10 % = pas rentable structurellement.'),
  (v_formation, v_module, 'qcm', 'Un score MSP de 78 % conduit à :',
   '[{"id":"a","label":"NO GO","is_correct":false},{"id":"b","label":"GO direct","is_correct":true},{"id":"c","label":"Négociation obligatoire","is_correct":false},{"id":"d","label":"Acompte 100 %","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-01','lecon-4','score'], 'mft-2026-gotrm:bc01-01-v3:l4:q5', true,
   'Score MSP : ≥ 70 % = GO direct, 50-70 % = négocier, < 50 % = NO GO argumenté. 78 % > 70 % = GO.'),
  (v_formation, v_module, 'qcm', 'Quel taux de conversion devis-commande est considéré comme bon en B2B transport ?',
   '[{"id":"a","label":"5 %","is_correct":false},{"id":"b","label":"30-40 %","is_correct":true},{"id":"c","label":"80 %","is_correct":false},{"id":"d","label":"100 %","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-01','lecon-4','conversion'], 'mft-2026-gotrm:bc01-01-v3:l4:q6', true,
   '30-40 % = standard B2B en transport. < 20 % = revoir prix/qualité. > 50 % = prix peut-être trop bas.'),
  (v_formation, v_module, 'qcm', 'En cas de refus argumenté à un nouveau client :',
   '[{"id":"a","label":"On perd définitivement le client","is_correct":false},{"id":"b","label":"80 % des clients reviennent à la prochaine demande","is_correct":true},{"id":"c","label":"On reçoit une amende","is_correct":false},{"id":"d","label":"Le client porte plainte","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-01','lecon-4','refus'], 'mft-2026-gotrm:bc01-01-v3:l4:q7', true,
   'Statistique : un refus pro et orienté (recommandation partenaire) renforce l''image de sérieux. 80 % des clients reviennent.'),
  (v_formation, v_module, 'qcm', 'Pour un nouveau client < 1 an, quelle condition de paiement appliquer ?',
   '[{"id":"a","label":"60 jours fin de mois","is_correct":false},{"id":"b","label":"Acompte 30 % à la commande, solde à 30 j","is_correct":true},{"id":"c","label":"Tout à 90 jours","is_correct":false},{"id":"d","label":"Pas de facture","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-01','lecon-4','paiement'], 'mft-2026-gotrm:bc01-01-v3:l4:q8', true,
   'Acompte 30 % à la commande sécurise la trésorerie et signale le sérieux. Standard < 1 an d''ancienneté client.'),
  (v_formation, v_module, 'qcm', 'Lequel n''est PAS un CRM courant en transport ?',
   '[{"id":"a","label":"Pipedrive","is_correct":false},{"id":"b","label":"HubSpot","is_correct":false},{"id":"c","label":"Salesforce","is_correct":false},{"id":"d","label":"AutoCAD","is_correct":true}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-01','lecon-4','crm'], 'mft-2026-gotrm:bc01-01-v3:l4:q9', true,
   'AutoCAD = logiciel CAO (dessin). Les vrais CRM sont Pipedrive, HubSpot, Salesforce, Zoho.'),
  (v_formation, v_module, 'qcm', 'Lead-to-quote (temps demande → devis) cible :',
   '[{"id":"a","label":"< 4 heures ouvrées","is_correct":true},{"id":"b","label":"24 heures","is_correct":false},{"id":"c","label":"3 jours","is_correct":false},{"id":"d","label":"1 semaine","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-01','lecon-4','kpi'], 'mft-2026-gotrm:bc01-01-v3:l4:q10', true,
   'Indicateur clé. < 4 h = best-in-class. > 24 h = perte de 50 % des deals au profit des concurrents plus rapides.'),
  (v_formation, v_module, 'qcm', 'L''affacturage en transport permet :',
   '[{"id":"a","label":"De doubler le prix","is_correct":false},{"id":"b","label":"De récupérer 90-95 % du montant facturé immédiatement","is_correct":true},{"id":"c","label":"D''éviter la TVA","is_correct":false},{"id":"d","label":"De garantir la livraison","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-01','lecon-4','affacturage'], 'mft-2026-gotrm:bc01-01-v3:l4:q11', true,
   'Affacturage = cession de créances commerciales contre cash immédiat à 90-95 % du montant. Solde versé après paiement client. Coût 1-2 % du CA. Bibby, Eurofactor, BNP Paribas Factor.'),
  (v_formation, v_module, 'qcm', 'Combien de relances effectuer après envoi du devis avant abandon ?',
   '[{"id":"a","label":"1 (à J+7)","is_correct":false},{"id":"b","label":"4 (à J+1, J+3, J+7, J+14)","is_correct":true},{"id":"c","label":"10 (1/jour)","is_correct":false},{"id":"d","label":"Aucune","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-01','lecon-4','relance'], 'mft-2026-gotrm:bc01-01-v3:l4:q12', true,
   '4 relances espacées : J+1 (accusé), J+3 (appel), J+7 (relance), J+14 (final + abandon). Au-delà = harcèlement contre-productif.');

  -- ===== 8 QR (cas pratiques métier, max_score 5-7) =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qr',
   'Reconstituez la chaîne logistique suivante et identifiez le rôle de chaque acteur, en précisant qui est juridiquement responsable en cas d''avarie : un client final commande un canapé chez Maisons du Monde via le site Amazon. Amazon Logistics gère le transport, sous-traite à Geodis qui sous-traite la livraison locale à un transporteur indépendant.',
   NULL, 6, 'moyen', ARRAY['gotrm','bc01-01','qr','acteurs','responsabilite'], 'mft-2026-gotrm:bc01-01-v3:qr1', true,
   'Maisons du Monde = expéditeur. Amazon = donneur d''ordre. Amazon Logistics = commissionnaire (responsabilité de résultat, art. L. 132-4). Geodis = transporteur public (1er rang). Indépendant = sous-traitant (2e rang, limite légale). Client = destinataire. En cas d''avarie : Amazon Logistics indemnise le client (commissionnaire), puis se retourne contre Geodis (resp. de moyen renforcé). Geodis se retourne contre l''indépendant. Vérifications : 2 rangs respectés, REGT du sous-traitant, RCCT 1,5 M€ minimum.'),

  (v_formation, v_module, 'qr',
   'Un client (PME industrielle, CA 4 M€) vous envoie cette demande par mail le mardi 16h : « Bonjour, j''ai besoin d''un transport mercredi pour 12 palettes de Paris à Toulouse. Merci. » Listez TOUTES les informations qu''il manque pour que vous puissiez transmettre un devis fiable, et rédigez le mail de relance que vous lui enverriez.',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-01','qr','saco','qualification'], 'mft-2026-gotrm:bc01-01-v3:qr2', true,
   'Informations manquantes (12 minimum) : SIREN, adresse précise origine, contact site origine, créneau chargement, nature marchandise, poids unitaire/total palettes, hauteur palettes, gerbable oui/non, conditionnement, ADR/ATP, adresse précise destination, créneau livraison, hayon nécessaire, valeur déclarée.\n\nMail de relance type : « Bonjour, j''ai bien reçu votre demande. Pour vous transmettre un devis fiable, j''ai besoin de précisions : (1) SIREN de votre société, (2) adresse exacte de chargement avec contact site et créneau, (3) poids total + hauteur des palettes (gerbables ou non), (4) nature de la marchandise et conditionnement, (5) adresse exacte de livraison + créneau souhaité + hayon nécessaire, (6) valeur déclarée. Sans ces éléments d''ici demain 12h, je ne pourrai pas garantir un transport mercredi. À très vite. »'),

  (v_formation, v_module, 'qr',
   'Une cargaison de 800 kg de matériel hi-tech (valeur déclarée 220 000 €) est détruite lors d''un accident. Le DO réclame l''indemnisation intégrale en justice. Vous transportiez sous régime contrat-type général (pas de CGV, pas de déclaration de valeur signée). Calculez l''indemnité réellement due et conseillez le DO sur ses recours.',
   NULL, 6, 'difficile', ARRAY['gotrm','bc01-01','qr','contrat-type','calcul'], 'mft-2026-gotrm:bc01-01-v3:qr3', true,
   'Calcul : 800 kg × 14 €/kg = 11 200 €. Plafond par envoi > 3 t = 2 300 €. **Indemnité due = 2 300 €** (le plus bas des deux). Préjudice non couvert : 220 000 − 2 300 = 217 700 € à la charge du DO.\n\nConseils au DO : (1) sa propre assurance « tous risques marchandises » devrait couvrir le solde si souscrite ; (2) à l''avenir, exiger une déclaration de valeur écrite + souscrire une couverture ad valorem ; (3) faire signer les CGV transporteur ou son propre contrat-type spécifique ; (4) éventuellement engager une action en faute lourde contre le transporteur si négligence prouvée (lève les plafonds : 3 ans prescription + indemnité réelle).'),

  (v_formation, v_module, 'qr',
   'Vous recevez une demande à 18h vendredi pour un transport lundi 8h : 8 palettes Paris-Lyon, 4 t. Le client n''a pas fourni son SIREN, son adresse exacte n''est qu''« en zone industrielle au sud de Paris », et il insiste pour avoir un prix immédiatement « sinon il ira voir ailleurs ». Comment traitez-vous cette demande dans le respect de la méthode MSP ? Détaillez votre raisonnement et la décision finale.',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-01','qr','msp','urgence'], 'mft-2026-gotrm:bc01-01-v3:qr4', true,
   'Étape 1 (Réception) : acquittement immédiat par mail. Étape 2 (Analyse) : impossibilité d''évaluer véhicule/conducteur/itinéraire faute d''adresse précise. Étape 3 (Recherche) : mail structuré demandant SIREN, adresse, créneaux, marchandise. Étape 4 (GO/NO GO) : sans SIREN, vérification Coface impossible → risque client inconnu. Sans adresse précise, marge incertaine. **Décision : NO GO argumenté** sous forme : « Cher client, votre demande étant urgente (lundi 8h) et certaines informations manquant (SIREN, adresse, créneaux), je ne peux pas garantir une exécution conforme. Je peux soit (a) vous proposer mardi avec qualification complète d''ici lundi 14h, soit (b) un devis forfait haut (+30 % marge sécurité) si vous acceptez les conditions actuelles. Sans retour d''ici samedi 12h, je devrai abandonner cette piste. » → 80 % des clients pros reviennent ensuite.'),

  (v_formation, v_module, 'qr',
   'Comparez le contrat-type général (décret 99-269) et la convention CMR pour un transport routier. Pour quels transports chacun s''applique-t-il ? Quels sont les principaux écarts en termes d''indemnité et de prescription ? Quelles sont les conséquences pratiques pour un GOTRM ?',
   NULL, 6, 'difficile', ARRAY['gotrm','bc01-01','qr','contrat-type','cmr'], 'mft-2026-gotrm:bc01-01-v3:qr5', true,
   'Contrat-type général : transports nationaux français, applicable d''office en l''absence de contrat. Plafond 14 €/kg + 750 €/2 300 € envoi. Prescription 1 an. CMR (Convention Genève 1956) : transports internationaux entre 56 pays signataires (UE + UK + Suisse + autres). Plafond 8,33 DTS/kg ≈ 10,80 €/kg. Document CMR obligatoire en 3 exemplaires. Prescription 1 an (3 ans en cas de dol).\n\nÉcarts majeurs : (1) Plafond CMR plus restrictif (10,80 €/kg vs 14 €/kg) ; (2) Document obligatoire CMR vs facultatif national ; (3) Délai prescription identique sauf dol.\n\nPour un GOTRM : il faut **distinguer le national de l''international dès le devis**, appliquer les bons plafonds, exiger le document CMR signé pour l''international, prévoir des assurances ad valorem pour les marchandises de valeur élevée. Toujours mentionner dans les CGV à quel régime juridique vous vous référez.'),

  (v_formation, v_module, 'qr',
   'Vous êtes commissionnaire de transport. Un nouveau client vous demande de transporter des produits pharmaceutiques (vaccins, valeur 180 000 € pour 8 palettes EUR à 2-8°C) de Tours à Lille en J+1 avec engagement horaire 9h. Listez les contraintes spéciales à activer dans votre devis et les couvertures d''assurance à souscrire ou exiger du sous-traitant.',
   NULL, 6, 'difficile', ARRAY['gotrm','bc01-01','qr','contraintes','assurance'], 'mft-2026-gotrm:bc01-01-v3:qr6', true,
   'Contraintes spéciales (5) : (1) ATP IR : 2-8°C, certification ATP du véhicule + sondes + enregistreur ; (2) BPDM : Bonnes Pratiques de Distribution du Médicament, transporteur certifié BPDM ; (3) Sécurité haute : valeur 180 k€ ⇒ alarme/GPS véhicule, conducteur formé sécurité, itinéraire validé ; (4) Délai engagé J+1 9h : pénalité contractuelle si retard, à clarifier ; (5) Déclaration de valeur écrite : 180 000 € pour lever plafond CT 14 €/kg.\n\nCouvertures d''assurance : (a) RCCT (responsabilité civile contractuelle transport) 1,5 M€ minimum, (b) **assurance ad valorem** ou tous risques marchandises spécifique vaccins (couverture 180 k€), (c) assurance température (rupture chaîne du froid spécifique), (d) si sous-traitance : exiger les mêmes couvertures du sous-traitant + son K-bis et certif BPDM.'),

  (v_formation, v_module, 'qr',
   'Un client GMS (Carrefour) vous transmet un bon de commande comportant cette clause : « Toute heure de retard sur le créneau de livraison engendre une pénalité de 1 000 € sans plafond. » Votre CGV transporteur prévoit un plafond de pénalités à 10 % du fret. Vous n''avez pas encore signé. Que faites-vous ? Argumentez votre stratégie.',
   NULL, 5, 'difficile', ARRAY['gotrm','bc01-01','qr','cgv','negociation'], 'mft-2026-gotrm:bc01-01-v3:qr7', true,
   'Stratégie en 3 étapes : (1) **NE PAS SIGNER** le bon de commande tel quel — la signature vaut acceptation des clauses pénales abusives ; (2) Envoyer un **contre-bon** ou **mail de réserve écrit** : « Cher Carrefour, j''accepte votre commande sous réserve de mes CGV en pièce jointe, qui plafonnent les pénalités à 10 % du fret. Toute pénalité supérieure ne peut être appliquée. » ; (3) Si Carrefour refuse, négocier : plafond 20 % maximum, ou exception pour cas de force majeure (intempéries, panne véhicule, accident).\n\nArgumentation : le contrat-type général ne prévoit pas de pénalité de retard automatique. Une clause de 1 000 €/h sans plafond peut être jugée abusive si dépasse manifestement le préjudice subi. En cas de litige, le tribunal de commerce peut **réduire d''office** les pénalités jugées excessives (art. 1231-5 C. civ.).\n\nAlternative : si Carrefour est un gros client (CA > 500 k€/an), sous-traiter ces opérations à risque élevé à un partenaire spécialisé GMS qui assume.'),

  (v_formation, v_module, 'qr',
   'Vous gérez 10 demandes de devis par semaine. Votre taux de conversion actuel est de 12 %. Détaillez un plan d''action en 5 leviers concrets pour passer à 30-35 % en 3 mois, avec les outils, les indicateurs et les coûts estimés.',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-01','qr','conversion','strategie'], 'mft-2026-gotrm:bc01-01-v3:qr8', true,
   'Plan en 5 leviers :\n\n1. **Réduire le lead-to-quote** (de 24 h actuel à < 4 h) : créer 7 templates Outlook (acquittement, demande infos, devis, refus, relance J+1/3/7/14). Coût : 0 €. Gain : +5-10 % de conversion.\n\n2. **CRM systématique** : déploiement Pipedrive (35 €/mois × 1 user = 420 €/an). Suivi pipeline, relances auto, taux de conversion par segment. Gain : +5 % par discipline de relance.\n\n3. **Qualification SACO obligatoire** : refuser les demandes incomplètes plutôt que faire un devis approximatif. Cible : passage en Pipeline complet uniquement après qualification SACO 100 %. Gain : meilleure qualité de devis = +5 %.\n\n4. **Calculateur Excel CRKM** pour devis répétitifs (clients réguliers) : coût 0 €, gain de temps 70 %, peut faire 30 devis/semaine au lieu de 10. Gain de conversion : +3-5 % par segmentation client.\n\n5. **Spécialisation produit** : se positionner sur 2-3 niches (palette ATP, ADR, exceptionnel) où la concurrence est moins agressive et la marge plus élevée. Gain : +5 % conversion + +5 % marge.\n\nIndicateurs (mensuels) : nombre de demandes entrantes, taux de qualification complète, lead-to-quote moyen, taux de conversion devis-commande, marge brute moyenne. Coût total an 1 ≈ 500 €. ROI sur conversion 12 % → 33 % avec 50 demandes/an = +10 commandes × 1 200 € marge = **+12 000 €**.');

  -- =================================================================
  -- QUIZZES (4 entraînement + 1 examen blanc module)
  -- =================================================================

  -- Quiz 1 — Acteurs
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Acteurs du transport — Quiz',
          'Quiz d''entraînement (12 questions) sur les 6 acteurs (expéditeur, DO, commissionnaire, transporteur, sous-traitant, destinataire), responsabilités juridiques et chaîne logistique.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-01-v3:l1:%';

  -- Quiz 2 — Qualification SACO
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Qualification SACO — Quiz',
          'Quiz d''entraînement (12 questions) sur la méthode SACO, palettes EUR/PMR, ATP/ADR, transports exceptionnels et hayon GMS.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-01-v3:l2:%';

  -- Quiz 3 — Cadre juridique
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Cadre juridique de la demande — Quiz',
          'Quiz d''entraînement (12 questions) sur le contrat-type général (déc. 99-269), CMR, CGV, plafonds d''indemnité et mentions LME.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-01-v3:l3:%';

  -- Quiz 4 — Méthode MSP
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Méthode MSP de traitement — Quiz',
          'Quiz d''entraînement (12 questions) sur la méthode MSP (6 étapes), critères GO/NO GO, devis structuré, suivi CRM et conversion.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-01-v3:l4:%';

  -- Examen blanc module — 15 QCM transversaux + 5 QR cas pratique
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold, is_mock_exam)
  VALUES (v_module, 'Examen blanc — BC01-01 Traiter une demande de transport',
          'Examen blanc reproduisant les conditions de l''examen RNCP : 15 QCM transversaux (4 leçons) + 5 QR cas pratiques métier, durée 60 min, seuil 50 %.',
          'examen', 3600, 50, true)
  RETURNING id INTO v_quiz_eb;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref IN (
     -- 4 QCM Leçon 1
     'mft-2026-gotrm:bc01-01-v3:l1:q1','mft-2026-gotrm:bc01-01-v3:l1:q2',
     'mft-2026-gotrm:bc01-01-v3:l1:q4','mft-2026-gotrm:bc01-01-v3:l1:q5',
     -- 4 QCM Leçon 2
     'mft-2026-gotrm:bc01-01-v3:l2:q1','mft-2026-gotrm:bc01-01-v3:l2:q2',
     'mft-2026-gotrm:bc01-01-v3:l2:q5','mft-2026-gotrm:bc01-01-v3:l2:q11',
     -- 4 QCM Leçon 3
     'mft-2026-gotrm:bc01-01-v3:l3:q1','mft-2026-gotrm:bc01-01-v3:l3:q2',
     'mft-2026-gotrm:bc01-01-v3:l3:q5','mft-2026-gotrm:bc01-01-v3:l3:q12',
     -- 3 QCM Leçon 4
     'mft-2026-gotrm:bc01-01-v3:l4:q1','mft-2026-gotrm:bc01-01-v3:l4:q5',
     'mft-2026-gotrm:bc01-01-v3:l4:q10',
     -- 5 QR (cas pratiques transversaux)
     'mft-2026-gotrm:bc01-01-v3:qr1','mft-2026-gotrm:bc01-01-v3:qr2',
     'mft-2026-gotrm:bc01-01-v3:qr3','mft-2026-gotrm:bc01-01-v3:qr4',
     'mft-2026-gotrm:bc01-01-v3:qr8'
   );

  RAISE NOTICE '✓ GOTRM BC01-01 v3 dense importé : 4 leçons (acteurs, SACO, juridique, MSP), 48 QCM, 8 QR cas pratiques métier, 5 quiz (4 entraînement + 1 examen blanc 15 QCM + 5 QR / 60 min).';

END $bc01_01_v3$;
