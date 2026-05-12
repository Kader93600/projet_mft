-- =====================================================================
-- MODULE A — DROIT CIVIL ET COMMERCIAL (Capacité de transport ≤ 3,5 T)
-- Version 3 (mai 2026) — REFONTE PÉDAGOGIQUE DENSIFIÉE
--
-- Diagnostic v2 corrigé :
--   ✓ Bug bloc : v_bloc résolu via slug fiable (pas ORDER BY id LIMIT 1)
--   ✓ Quiz : chaque quiz d'entraînement contient maintenant 10-15 QCM
--   ✓ Leçons : structure pédagogique pro (intro / dev / cas / synthèse /
--     "Ce que l'examinateur peut demander" / glossaire / mémo)
--   ✓ Banque enrichie : 60 QCM (vs 30) avec niveaux facile/moyen/difficile
--   ✓ QR : 8 (vs 6) avec barème implicite et cas réalistes
--   ✓ Examen blanc : 14 QCM + 5 QR pour reproduire l'épreuve nationale
--
-- Sources :
--   - COURS.pdf (Activ-Avenir / MFT, 230 p.)
--   - BASE DE DONNÉES 2026.pdf (694 QCM + 155 QR)
--   - LIVRE DES EXERCICES CAPA LEGERE.pdf
--   - Décision du 2 avril 2012, examen national QCM 14 questions,
--     2 pts/question = 28 pts sur 84 total, seuil 50 % global
--
-- Idempotent : DELETE ciblés par module/slug puis INSERT — safe à rejouer.
-- Pré-requis :
--   - Formation 'capacite-3-5t' présente dans public.formations
--   - Au moins un bloc dans public.blocs (BC1 par défaut, sinon création)
-- =====================================================================

DO $module_a_v3$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_lesson_1 uuid;
  v_lesson_2 uuid;
  v_lesson_3 uuid;
  v_lesson_4 uuid;
  v_lesson_5 uuid;
  v_quiz_1 uuid;
  v_quiz_2 uuid;
  v_quiz_3 uuid;
  v_quiz_4 uuid;
  v_quiz_5 uuid;
  v_quiz_eb uuid;
  v_q uuid;
BEGIN
  -- ─── 1. Pré-requis : formation Capacité ≤ 3,5 t ─────────────────────
  SELECT id INTO v_formation
    FROM public.formations
   WHERE slug = 'capacite-3-5t';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation capacite-3-5t introuvable. Joue d''abord formations_v2.sql.';
  END IF;

  -- ─── 1bis. Bloc fiable (FIX du bug v2) ──────────────────────────────
  -- v2 utilisait ORDER BY id LIMIT 1, ce qui pouvait rattacher le module
  -- au mauvais bloc (typiquement BC1 GOTRM). On résout via le code 'BC1'
  -- de manière déterministe. Si l'architecture évolue avec un bloc
  -- spécifique Capa (ex. code 'CAPA-A1'), il suffit de modifier la
  -- chaîne ci-dessous — sans toucher au reste du script.
  SELECT id INTO v_bloc
    FROM public.blocs
   WHERE code = 'BC1';

  -- Si aucun bloc BC1 n'existe, on tente une création légère pour ne
  -- pas planter (les contenus capa peuvent vivre temporairement sur ce
  -- bloc partagé). À durcir quand un référentiel Capa propre sera défini.
  IF v_bloc IS NULL THEN
    INSERT INTO public.blocs (code, title, description, "order")
    VALUES ('BC1', 'Bloc 1 — Compétences générales',
            'Bloc générique partagé entre formations. À spécialiser par formation à terme.',
            1)
    ON CONFLICT (code) DO NOTHING
    RETURNING id INTO v_bloc;
    IF v_bloc IS NULL THEN
      SELECT id INTO v_bloc FROM public.blocs WHERE code = 'BC1';
    END IF;
  END IF;

  IF v_bloc IS NULL THEN
    RAISE EXCEPTION 'Bloc BC1 introuvable et impossible à créer. Vérifie public.blocs.';
  END IF;

  -- ─── 2. Module : on supprime l'ancien et on recrée propre ─────────
  -- Cascade : supprime aussi lessons, quizzes, formation_modules.
  DELETE FROM public.modules WHERE slug = 'capa-droit-civil-commercial';

  INSERT INTO public.modules (
    title, slug, bloc_id, summary, difficulty, duration_min, "order"
  ) VALUES (
    'Module A — Droit civil et commercial',
    'capa-droit-civil-commercial',
    v_bloc,
    'Les fondamentaux juridiques pour créer et faire vivre une entreprise de transport léger : personnalité juridique, formes de société, facturation, effets de commerce, garanties, recouvrement, procédures collectives.',
    'intermediaire',
    540, -- durée officielle Capacité ≤ 3,5 t (révision client 2026-05)
    10
  ) RETURNING id INTO v_module;

  -- Rattachement explicite à la formation Capacité ≤ 3,5 t
  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 10, true)
  ON CONFLICT DO NOTHING;

  -- ─── 3. Banque : reset des questions Module A reformulées ─────────
  -- On supprime UNIQUEMENT les questions de cette formation et de ce
  -- module (préfixe source_ref) — pas d'interférence avec d'autres modules.
  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND source_ref LIKE 'mft-2026:moduleA:%';

  -- =================================================================
  -- LEÇON 1 — Le cadre juridique des personnes
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Le cadre juridique des personnes',
    'cadre-juridique-personnes',
    1, 45,
$lesson1$
# Le cadre juridique des personnes

> 🎯 **Objectifs pédagogiques**
>
> À la fin de cette leçon, vous serez capable de :
>
> - **Distinguer** personne physique et personne morale dans le contexte du transport routier de marchandises ≤ 3,5 t.
> - **Identifier** les quatre régimes matrimoniaux français et leurs conséquences sur le patrimoine de l'entrepreneur.
> - **Appliquer** les règles de capacité juridique pour exercer une activité commerciale.
> - **Reconnaître** les incompatibilités et interdictions qui empêchent l'exercice du commerce.
> - **Anticiper** les pièges patrimoniaux à éviter avant la création d'entreprise.

---

## Introduction

Avant de parler de **véhicules**, de **clients** ou de **factures**, vous devez maîtriser une notion qui décide de **tout** dans votre future entreprise : qui est juridiquement habilité à agir, sous quelles conditions, et avec quelles conséquences sur son patrimoine personnel ?

Comprenez bien : le jour où vous signerez votre premier contrat de transport, où vous embaucherez votre premier chauffeur, ou où vous demanderez votre premier crédit-bail VUL, le droit décidera **qui paie en cas de problème**. Si vous n'avez pas pris les bonnes décisions juridiques au démarrage, c'est **votre patrimoine personnel** (votre maison, votre compte joint, le 4×4 familial) qui sera saisi en cas de défaillance.

Cette leçon pose les fondations. Elle paraît théorique. Elle est en réalité **la plus rentable** de tout le module : maîtriser ces 4 chapitres peut vous épargner 50 000 € de pertes patrimoniales sur dix ans.

---

## 1. La personnalité juridique

### 1.1 Définition

> 📚 **Définition simple**
>
> La **personnalité juridique** est la capacité reconnue à un être (humain ou groupement) d'avoir des **droits** (posséder, contracter, agir en justice) et des **obligations** (payer, respecter ses engagements, réparer un dommage).
>
> Sans personnalité juridique, vous n'existez **pas pour le droit** : vous ne pouvez ni signer un contrat, ni encaisser une facture, ni embaucher.

> 📜 **Définition juridique**
>
> Article 16 du Code civil : *« La loi assure la primauté de la personne, interdit toute atteinte à la dignité de celle-ci et garantit le respect de l'être humain dès le commencement de sa vie. »* — La personnalité commence à la naissance vivante et viable.

### 1.2 Les deux familles de personnes

Le droit français distingue deux catégories fondamentales :

| Critère | Personne physique | Personne morale |
|---|---|---|
| **Nature** | Être humain vivant | Groupement reconnu par la loi |
| **Naissance juridique** | Naissance biologique | Immatriculation au RCS |
| **Mort juridique** | Décès biologique | Liquidation / radiation |
| **Patrimoine** | Unique (sauf statuts spéciaux) | Distinct des associés |
| **Exemple transport** | Coursier auto-entrepreneur | SARL de livraison à Reims |

> 💡 **À retenir**
>
> La personnalité morale d'une société (SAS, SARL, EURL…) **ne naît pas** à la signature des statuts ni à la publication de l'annonce légale. Elle naît **uniquement** à l'**immatriculation au Registre du commerce et des sociétés (RCS)**, c'est-à-dire à la délivrance du Kbis.

### 1.3 Les sous-catégories de personnes morales

| Catégorie | Régime | Exemples |
|---|---|---|
| **Personnes morales de droit public** | Code des collectivités, marchés publics | État, communes, départements, hôpitaux, régies |
| **Personnes morales de droit privé** | Code civil + Code de commerce | SARL, SAS, SASU, EURL, SNC, SCS, SA, associations |

Une entreprise de transport est **toujours** une personne morale de droit privé (sauf quelques cas marginaux comme les régies municipales de transport).

### 1.4 Cas pratique 1 — La personnalité morale et le moment du contrat

> 🚛 **Mise en situation**
>
> **Marie** prépare la création de sa SARL « Marie-Express » pour livrer du frais en région parisienne. Le **3 mars**, elle signe les statuts chez le notaire. Le **6 mars**, elle publie l'annonce légale. Le **15 mars**, elle obtient son Kbis (= immatriculation RCS).
>
> Or, elle a **signé un contrat de location de hangar le 10 mars** au nom de « Marie-Express SARL en formation ».
>
> **Question :** ce contrat engage-t-il la SARL ?

**Correction :**
Le 10 mars, la SARL **n'existe pas encore juridiquement** : elle naît seulement le 15 mars (immatriculation). Le contrat est donc signé par Marie en son nom propre. Deux issues possibles :

- **Soit** la SARL **reprend l'engagement** lors de l'immatriculation (mécanisme prévu à l'article L. 210-6 du Code de commerce). Le contrat est alors réputé conclu par la SARL **rétroactivement**.
- **Soit** la SARL **ne reprend pas** l'engagement, et Marie reste personnellement engagée auprès du bailleur.

Conséquence pratique : **toujours mentionner « société en cours de formation »** sur les actes pré-immatriculation, et **lister explicitement** ces actes dans une annexe aux statuts pour reprise automatique.

---

## 2. La capacité juridique

### 2.1 Capacité de jouissance vs capacité d'exercice

> 📚 **Définitions**
>
> - **Capacité de jouissance** : aptitude à *posséder* des droits. Tous les humains l'ont, dès la naissance.
> - **Capacité d'exercice** : aptitude à *exercer* ces droits soi-même (signer, voter, agir en justice). Tous les humains ne l'ont pas.

| Cas | Capacité de jouissance | Capacité d'exercice |
|---|---|---|
| Majeur sain d'esprit | ✅ | ✅ Exercice libre |
| Mineur de < 16 ans | ✅ | ❌ Représenté par les parents |
| Mineur émancipé (par le juge) | ✅ | ✅ Exercice libre (avec restrictions) |
| Majeur sous tutelle | ✅ | ❌ Représenté par le tuteur |
| Majeur sous curatelle | ✅ | ⚠️ Exercice **assisté** par le curateur |

### 2.2 Cas pratique 2 — Le mineur entrepreneur

> 🚛 **Mise en situation**
>
> **Théo** a 17 ans, vit chez ses parents et veut créer son entreprise de coursier vélo dans Paris. Il dispose de 1 200 € d'économies, son vélo électrique, et a déjà identifié 3 clients potentiels (restaurants).
>
> **Question :** quelles démarches doit-il impérativement effectuer avant l'immatriculation ?

**Correction :**

1. **Demander son émancipation** au juge des tutelles (au tribunal judiciaire). L'audience est généralement publique. Les deux parents sont entendus.
2. **Obtenir l'autorisation écrite** des deux parents (ou du parent ayant l'autorité parentale). Sans accord parental, le juge refusera presque systématiquement.
3. Une fois l'émancipation prononcée, Théo a la **capacité d'exercice complète** pour son commerce. Il peut s'immatriculer au RCS, ouvrir un compte bancaire pro, signer des contrats et embaucher.

**Restriction importante :** même émancipé, un mineur ne peut **pas** :
- Acheter de l'alcool ni gérer une activité réglementée mineurs (exemple : transport scolaire).
- Se marier sans dispense du procureur.

### 2.3 Mini-exercice guidé

> ✏️ **À vous**
>
> Pour chacun des cas suivants, indiquez si la personne **peut signer** un contrat de transport en son nom propre, **oui ou non**, en justifiant.
>
> 1. Femme majeure, mariée sans contrat, sans tutelle ni curatelle.
> 2. Garçon de 16 ans non émancipé.
> 3. Homme majeur sous curatelle simple.
> 4. Société à responsabilité limitée immatriculée depuis 2 ans.

**Correction :**

1. **Oui.** Capacité d'exercice complète (majeur sain).
2. **Non.** Sans émancipation, ses parents doivent signer pour lui.
3. **Avec assistance.** Sa signature seule ne suffit pas : le curateur doit cosigner.
4. **Oui.** Personne morale immatriculée → représentée par son gérant ou président.

---

## 3. Les régimes matrimoniaux

C'est le chapitre que **80 % des futurs transporteurs négligent**, jusqu'au jour où une saisie sur le compte joint leur prouve qu'ils auraient dû y réfléchir avant. Le régime matrimonial détermine **comment vos biens et vos dettes circulent entre vous et votre conjoint**.

### 3.1 Les quatre régimes français

| Régime | Comment l'obtenir | Biens propres | Biens communs | Dettes |
|---|---|---|---|---|
| **Communauté réduite aux acquêts** | **Par défaut** (sans contrat) | Avant mariage + dons / héritages | Acquis à titre onéreux pendant le mariage | Communes (sauf exceptions) |
| **Communauté universelle** | Contrat de mariage notarié | Aucun (tout est commun) | Tout, présent et à venir | Toutes communes |
| **Séparation de biens** | Contrat de mariage notarié | Tout reste propre | Aucun | Personnelles (sauf ménage / éducation enfants) |
| **Participation aux acquêts** | Contrat de mariage notarié | Comme séparation pendant le mariage | Aucun pendant le mariage ; partage à la dissolution | Personnelles |

### 3.2 Comparaison pour un futur transporteur

| Régime | Avantage transporteur | Risque transporteur |
|---|---|---|
| Communauté légale | Aucun spécifique | **ÉLEVÉ** : créancier peut saisir compte joint, voiture du couple, résidence secondaire |
| Communauté universelle | Aucun | **MAXIMAL** : tout le patrimoine commun engagé |
| Séparation de biens | Patrimoine du conjoint protégé des dettes pro | Frais notariés (~1 000 € au mariage, plus cher à changer) |
| Participation aux acquêts | Pendant le mariage = comme séparation, à la dissolution = partage des enrichissements | Complexe à calculer en cas de divorce |

> ⚠️ **Attention examen**
>
> L'examinateur vérifie souvent ces deux points :
>
> 1. Le régime **par défaut** est la **communauté réduite aux acquêts** (et **non** la séparation de biens). Beaucoup de candidats se trompent sous le stress.
> 2. Sans contrat, les **revenus** du conjoint pendant le mariage sont des **biens communs** (donc saisissables pour les dettes professionnelles, sauf exception).

### 3.3 Cas pratique 3 — Apport et défaillance future

> 🚛 **Mise en situation**
>
> **Marc**, marié sans contrat depuis 12 ans avec **Léa** (cadre dans une grande entreprise), souhaite créer une SARL « Marc-Trans » avec un apport de **30 000 €** prélevé sur le compte joint.
>
> Trois ans plus tard, la SARL fait faillite avec **80 000 €** de dettes. Marc avait par ailleurs signé une **caution personnelle** de 25 000 € auprès de la banque.
>
> **Question :** que peuvent saisir les créanciers ?

**Correction étape par étape :**

1. **L'apport de 30 000 €** était un bien commun (compte joint). Les parts SARL souscrites avec cet argent sont également des **biens communs**, même si elles sont libellées au nom de Marc seul. La banque créancière peut donc poursuivre des biens communs jusqu'à hauteur de la dette **garantie par la caution** (25 000 €).
2. **Pour les 55 000 € restants** (dette SARL non couverte par la caution), seuls les **biens propres** de Marc et la SARL sont engagés. Les biens propres de Léa (héritages, salaires si placés sur compte séparé documenté) sont protégés.
3. **Si Léa avait cosigné la caution**, ses biens propres seraient également engagés à hauteur de 25 000 €.

**Leçon métier :** Marc aurait dû soit basculer en **séparation de biens** avant de créer la SARL (procédure judiciaire après 2 ans de mariage), soit faire **renoncer Léa expressément à la qualité de conjointe commune en biens** sur l'apport (article 1832-2 du Code civil).

### 3.4 Erreurs fréquentes à éviter

> ❌ **Erreur n° 1**
>
> Croire que la SARL « protège tout ». La responsabilité est limitée aux apports **uniquement** pour les dettes pour lesquelles **vous n'avez pas donné de garantie personnelle**. Dès que la banque demande votre **caution personnelle solidaire**, votre patrimoine personnel est **directement** engagé pour cette dette.

> ❌ **Erreur n° 2**
>
> Croire qu'on peut changer de régime matrimonial en 5 minutes. Avant 2017, il fallait passer par le tribunal. Depuis, c'est plus simple mais reste un acte notarié, surtout obligatoire si vous avez des **enfants mineurs**, et peut être contesté pendant **3 mois** par les créanciers.

---

## 4. La capacité de commerçant

Avoir la capacité juridique ne suffit pas pour devenir commerçant. Il faut **en plus** ne tomber sous aucune **incompatibilité** ni **interdiction**.

### 4.1 Les six incompatibilités professionnelles

L'activité commerciale est strictement **incompatible** avec ces professions (le code de déontologie de chacune l'interdit) :

| # | Profession | Raison |
|---|---|---|
| 1 | **Fonctionnaire** | Article 25 du statut général : indépendance vis-à-vis du privé |
| 2 | **Officier ministériel** (notaire, huissier) | Indépendance vis-à-vis du commerce |
| 3 | **Avocat** | Indépendance professionnelle (RIN) |
| 4 | **Commissaire aux comptes / expert-comptable** | Indépendance vis-à-vis des entreprises auditées |
| 5 | **Architecte en exercice** | Indépendance professionnelle |
| 6 | **Mineur non émancipé** | Capacité juridique insuffisante |

> 💡 **Astuce métier**
>
> Un fonctionnaire peut **temporairement** créer une activité accessoire (auto-entrepreneur) en transport léger avec **autorisation de cumul** de son administration. Mais s'il dépasse certains seuils ou souhaite se mettre à plein temps, il devra **démissionner ou être placé en disponibilité**. Vérifiez toujours auprès de la DRH avant de signer un Kbis.

### 4.2 Les interdictions par décision de justice

Lors d'un **redressement** ou d'une **liquidation judiciaire**, le tribunal de commerce peut prononcer deux sanctions distinctes contre un dirigeant fautif :

| Sanction | Durée maximale | Effet |
|---|---|---|
| **Faillite personnelle** | 15 ans | Interdiction de gérer + diriger + administrer + contrôler une société |
| **Interdiction de gérer** seule | 5 ans | Idem mais sans déchéance des droits civiques |

Une personne sous l'une de ces sanctions ne peut **ni** créer une entreprise individuelle, **ni** diriger une SARL/SAS/SA, **ni** être associé majoritaire dans une société commerciale.

### 4.3 Le Fichier national des interdits de gérer

Depuis le **1er janvier 2016**, toutes ces interdictions sont centralisées dans un **Fichier national** tenu par le **Conseil National des Greffiers des Tribunaux de Commerce (CNGTC)**.

- Le greffier consulte ce fichier **systématiquement** lors de toute demande d'immatriculation.
- Une fausse déclaration sur l'honneur (formulaire M0) constitue un **délit pénal** sanctionné par 6 mois de prison + 3 750 € d'amende.

### 4.4 Cas pratique 4 — Reprise après faillite

> 🚛 **Mise en situation**
>
> **Karim**, ancien gérant d'une SARL de transport en liquidation en 2021, a été condamné par le tribunal de commerce à une **interdiction de gérer de 4 ans** pour faute de gestion. Nous sommes en **mai 2026**. Il souhaite redémarrer une activité de coursier indépendant.
>
> **Question :** peut-il s'immatriculer aujourd'hui ?

**Correction :**

L'interdiction de **4 ans** court à compter du jugement (2021). Elle s'achève donc en **2025**. En mai 2026, Karim n'est **plus interdit**.

Mais attention :
1. La levée de l'interdiction n'est **pas automatique** dans le Fichier national. Karim doit demander au greffier la **mise à jour** sur présentation du jugement.
2. Lors de l'immatriculation, le greffier vérifiera. S'il y a un retard de mise à jour du Fichier, l'immatriculation sera **bloquée** tant que la situation n'est pas régularisée.

**Action concrète :** demander l'extrait du Fichier national des interdits de gérer **avant** le rendez-vous greffe pour anticiper.

---

## 5. Glossaire des notions clés

| Terme | Définition concise |
|---|---|
| **Personnalité juridique** | Aptitude à être titulaire de droits et d'obligations |
| **Personne morale** | Groupement de personnes ou de biens reconnu par la loi avec une existence juridique propre |
| **RCS** | Registre du commerce et des sociétés, tenu par les greffes des tribunaux de commerce |
| **Kbis** | Extrait officiel d'immatriculation, « carte d'identité » de la société |
| **Capacité de jouissance** | Aptitude à *posséder* des droits |
| **Capacité d'exercice** | Aptitude à *exercer* ses droits soi-même |
| **Émancipation** | Acte juridique conférant à un mineur la capacité d'exercice |
| **Régime matrimonial** | Ensemble de règles déterminant le sort des biens et dettes des époux |
| **Communauté réduite aux acquêts** | Régime légal par défaut sans contrat de mariage |
| **Faillite personnelle** | Sanction du tribunal contre un dirigeant fautif (jusqu'à 15 ans) |
| **CNGTC** | Conseil National des Greffiers des Tribunaux de Commerce, gère le Fichier national |

---

## 🧠 Synthèse opérationnelle

> 📌 **Les 8 points à retenir**
>
> 1. La personnalité morale d'une société naît à l'**immatriculation au RCS**, pas avant.
> 2. Tout humain a la **capacité de jouissance** dès la naissance, mais seulement les majeurs sains et les mineurs émancipés ont la **capacité d'exercice**.
> 3. Sans contrat de mariage, les époux sont sous **communauté réduite aux acquêts** (régime légal par défaut).
> 4. Pour protéger le patrimoine du conjoint, le régime adapté est la **séparation de biens** (contrat notarié).
> 5. Six professions sont **incompatibles** avec le commerce : fonctionnaires, officiers ministériels, avocats, experts-comptables, architectes, mineurs non émancipés.
> 6. La **faillite personnelle** peut durer jusqu'à **15 ans**, l'**interdiction de gérer** seule jusqu'à **5 ans**.
> 7. Le **Fichier national des interdits de gérer** est tenu par le **CNGTC** depuis 2016.
> 8. Une **caution personnelle** sur un prêt SARL annule en pratique la « responsabilité limitée aux apports » pour cette dette.

---

## 🎓 Ce que l'examinateur peut demander

L'épreuve nationale comporte 14 QCM en 30 minutes. Sur cette leçon, voici les questions-types récurrentes des dernières sessions :

1. **« Quand naît la personnalité morale d'une SARL ? »** → Réponse : à l'immatriculation au RCS. Piège fréquent : la signature des statuts ou la publication de l'annonce légale ne suffisent pas.
2. **« Quel est le régime matrimonial par défaut en France ? »** → Réponse : communauté réduite aux acquêts. Piège : confusion avec « séparation de biens » sous l'effet du stress.
3. **« Quelle est la durée maximale d'une interdiction de gérer ? »** → Réponse : 5 ans. Piège : confusion avec la faillite personnelle (15 ans).
4. **« Une SARL en faillite : un dirigeant interdit peut-il créer une nouvelle société ? »** → Réponse : non, pendant la durée de l'interdiction. Le greffier vérifie au Fichier national.
5. **Question piège récurrente** : la séparation automatique des patrimoines depuis 2022 (statut unique de l'entrepreneur individuel) est valable **uniquement pour l'EI**, pas pour les sociétés où un contrat notarié reste nécessaire.

---

## 📋 Mémo à imprimer

```
PERSONNALITÉ MORALE   → Immatriculation RCS (= Kbis délivré)
RÉGIME MATRIMONIAL    → Par défaut : communauté réduite aux acquêts
PROTECTION PATRIMOINE → Séparation de biens (contrat notarié)
INCOMPATIBILITÉS      → 6 : fonctionnaires, officiers ministériels,
                        avocats, experts-comptables, architectes,
                        mineurs non émancipés
FAILLITE PERSONNELLE  → Jusqu'à 15 ans
INTERDICTION DE GÉRER → Jusqu'à 5 ans
FICHIER NATIONAL      → CNGTC depuis 2016
CESSATION DE PAIEMENT → Passif exigible > Actif disponible
                        Déclaration sous 45 jours
```
$lesson1$,
'Comprendre qui peut exercer une activité commerciale, sous quel régime juridique et matrimonial, et comment éviter les pièges de la confusion patrimoniale.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Créer son entreprise de transport
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Créer son entreprise de transport',
    'creation-entreprise-transport',
    2, 50,
$lesson2$
# Créer son entreprise de transport

> 🎯 **Objectifs pédagogiques**
>
> À la fin de cette leçon, vous serez capable de :
>
> - **Choisir** la forme juridique adaptée à votre projet (EI, EURL, SARL, SASU, SAS).
> - **Comparer** régime fiscal, régime social et niveau de protection patrimoniale entre formes.
> - **Maîtriser** les seuils de capital, le nombre minimal d'associés et les organes de direction.
> - **Identifier** les obligations spécifiques au secteur transport (capacité, licence, garantie financière).
> - **Anticiper** le coût et le calendrier réel d'une création.

---

## Introduction

Le choix de la forme juridique conditionne **trois leviers majeurs** de votre futur quotidien : combien d'impôt et de cotisations vous paierez, quel risque pèse sur votre patrimoine, et comment vous serez protégé socialement (maladie, retraite). Cinq formes dominent le paysage : EI, EURL, SARL, SASU, SAS. Cette leçon vous donne les éléments pour décider — pas une réponse universelle, mais une grille de lecture pour décider **en connaissance de cause**.

Important : en transport, deux contraintes s'ajoutent au choix juridique pur — l'**attestation de capacité professionnelle** (l'examen que vous préparez) et la **licence de transport intérieur** délivrée par la DREAL. Aucune forme juridique ne vous dispense de ces obligations.

---

## 1. Les cinq formes juridiques candidates

### 1.1 Tableau comparatif synthétique

| Critère | **EI** | **EURL** | **SARL** | **SASU** | **SAS** |
|---|---|---|---|---|---|
| Personne morale | Non | Oui | Oui | Oui | Oui |
| Nb associés | 1 (= dirigeant) | 1 | 2 à 100 | 1 | ≥ 2 |
| Capital minimum | — | 1 € | 1 € | 1 € | 1 € |
| Régime fiscal défaut | IR (BIC) | IR (BIC) | IS | IS | IS |
| Option fiscale | Aucune | IS sur option | IR pour SARL famille (5 ans) | IR sur option (5 ans max) | IR sur option (5 ans max) |
| Régime social dirigeant | TNS | TNS | TNS si > 50 % parts, sinon assimilé | Assimilé salarié | Assimilé salarié |
| Cotisations | ~ 45 % du revenu | ~ 45 % | TNS ou ~ 80 % salaire brut | ~ 80 % du salaire brut | ~ 80 % du salaire brut |
| Responsabilité dirigeant | Limitée au patrimoine pro (séparation auto depuis 2022) | Limitée aux apports | Limitée aux apports | Limitée aux apports | Limitée aux apports |
| Coût création | ~ 0 € | ~ 200 € | ~ 200 à 400 € | ~ 200 à 400 € | ~ 200 à 400 € |

### 1.2 Comprendre TNS vs assimilé salarié

> 📚 **Définition simple**
>
> - **TNS (Travailleur Non-Salarié)** : régime des indépendants. Cotise à l'**URSSAF + SSI** (≈ 45 % du revenu net). Pas de chômage. Maladie / retraite moins protectrices.
> - **Assimilé salarié** : régime général de la Sécurité sociale (≈ 80 % du salaire brut, dont 25 % côté salarié + 55 % côté employeur). Pas de chômage non plus (sauf cumul avec un mandat ailleurs). Maladie / retraite plus protectrices.

| Aspect | TNS | Assimilé salarié |
|---|---|---|
| **Coût** | ✅ Moins cher (~ 45 %) | ❌ Plus cher (~ 80 %) |
| **Protection maladie** | ⚠️ Indemnités plus faibles, délai de carence plus long | ✅ Régime général |
| **Retraite** | ⚠️ Régime spécifique avec moins de points | ✅ Régime général |
| **Chômage** | ❌ Aucun (sauf assurance privée) | ❌ Aucun pour le mandataire social |

> 💡 **Astuce métier**
>
> Pour une activité de transport léger en démarrage (revenus < 30 000 €/an), le **TNS** est souvent plus intéressant : moins de cotisations, donc plus de revenu net à investir dans le véhicule. À mesure que les revenus montent (> 50 000 €), le calcul s'inverse pour la protection sociale.

---

## 2. Focus sur les formes les plus fréquentes en transport

### 2.1 L'Entreprise Individuelle (EI)

L'**EI** est la forme la plus simple et la plus fréquente pour démarrer en coursier ou en livraison.

**Avantages :**
- Création rapide (formulaire P0 + Kbis sous 72 h).
- Pas de capital social à libérer.
- Comptabilité simplifiée (recettes/dépenses si auto-entrepreneur).
- Depuis le **15 mai 2022**, le **patrimoine personnel est automatiquement séparé** du patrimoine professionnel : seuls les biens « utiles à l'activité » (camionnette, matériel pro) peuvent être saisis pour les dettes pro.

**Inconvénients :**
- Pas de personne morale → moins crédible pour de gros donneurs d'ordre.
- Difficile d'accueillir un associé.
- Pas de capital à exhiber pour une demande de licence (or la DREAL exige des **garanties financières** : 1 800 € pour le 1er VUL, 900 € par véhicule supplémentaire).

> ⚠️ **Attention examen**
>
> Avant 2022, on parlait d'**EIRL** (Entrepreneur Individuel à Responsabilité Limitée) qui nécessitait une déclaration d'affectation. **Depuis le 15 mai 2022**, l'EIRL **disparaît** au profit du **statut unique de l'entrepreneur individuel** (EI nouvelle formule), avec séparation **automatique** des patrimoines. Si l'examinateur évoque l'EIRL, il teste votre actualisation.

### 2.2 L'EURL et la SARL

L'**EURL** est une SARL à associé unique. La **SARL** est multi-associés (2 à 100). Les deux fonctionnent juridiquement de manière identique pour le régime des parts sociales et la responsabilité limitée aux apports.

**Spécificité TNS vs assimilé salarié pour le gérant SARL :**

- Gérant **majoritaire** (> 50 % des parts, seul ou avec conjoint et enfants mineurs) → **TNS**.
- Gérant **minoritaire ou égalitaire** (≤ 50 %) → **assimilé salarié**.
- Gérant **non associé** → **assimilé salarié**.

Cette règle est cruciale : un gérant à 50 % strict (avec un seul autre associé à 50 %) est **assimilé salarié**, alors qu'à 50 % + 1 part il bascule **TNS**. Soigner la répartition au moment des statuts évite des surprises sociales.

### 2.3 La SASU et la SAS

Plus jeunes (créées en 1994, modernisées en 1999 et 2008), la **SASU** (1 associé) et la **SAS** (≥ 2 associés) offrent une **liberté statutaire considérable**.

**Caractéristiques clés :**
- Capital minimum : 1 € (50 % à libérer à la constitution, le solde dans les 5 ans).
- Président **toujours assimilé salarié** quel que soit son niveau de détention. Donc cotisations plus lourdes mais protection sociale du régime général.
- **Pas de plafond de nombre d'associés**.
- Statuts personnalisables : on peut prévoir des actions à droit de vote multiple, des actions de préférence, des organes de direction sur mesure.

> 💡 **Astuce métier**
>
> La SASU est devenue le choix dominant pour les **transporteurs en croissance** qui anticipent une levée de fonds, l'entrée d'un associé, ou une cession future. L'EURL conserve son intérêt pour ceux qui privilégient le régime TNS (cotisations basses, dividendes peu chargés socialement).

---

## 3. Choisir : grille de décision

### 3.1 Arbre de décision simplifié

```
JE DÉMARRE SEUL EN COURSIER, PETIT VOLUME
    └─→ EI (auto-entrepreneur si CA < 77 700 €)

JE DÉMARRE SEUL, ACTIVITÉ ENGAGEANTE,
JE VEUX UNE PERSONNE MORALE
    ├─→ EURL (régime TNS, moins cher)
    └─→ SASU (régime salarié, plus protecteur)

NOUS DÉMARRONS À 2+ ASSOCIÉS, RELATION DE CONFIANCE
    └─→ SARL (cadre rigide, parts sociales)

NOUS DÉMARRONS À 2+ ASSOCIÉS, FUTURE LEVÉE DE FONDS
    └─→ SAS (statuts flexibles, actions)
```

### 3.2 Cas pratique 1 — Coursier solo

> 🚛 **Mise en situation**
>
> **Aïcha**, 28 ans, salariée en CDI, souhaite lancer une activité de coursier urbain à Meaux le soir et le week-end. Elle dispose d'un VUL personnel, 8 000 € d'économies, et estime un CA prévisionnel de 18 000 €/an au démarrage.
>
> **Question :** quelle forme recommandez-vous ?

**Correction :**

L'**Entreprise Individuelle au régime micro-fiscal (auto-entrepreneur)** est optimale pour Aïcha :

- **Cumul** avec son CDI **autorisé** sans difficulté (pas d'incompatibilité légale, simple information de l'employeur).
- **Démarches** : formulaire P0 sur autoentrepreneur.urssaf.fr → SIRET sous 5 jours → Kbis dans la foulée.
- **Cotisations** : 22 % du CA (transport de marchandises). Sur 18 000 € → 3 960 € de cotisations.
- **Fiscalité** : option **versement libératoire** possible si revenu fiscal de référence < 27 086 €. Sinon impôt classique.
- **Patrimoine personnel séparé automatiquement** depuis 2022 : son VUL personnel reste protégé tant qu'il n'est pas affecté au pro.

**Action complémentaire :** demander à la DREAL la **Licence de transport intérieur (LTI)** pour véhicules ≤ 3,5 t et la garantie financière de 1 800 €.

### 3.3 Cas pratique 2 — Couple créateur

> 🚛 **Mise en situation**
>
> **Karim et Léa**, mariés sous communauté légale, souhaitent créer une SARL « K&L Trans » à 2 associés (50 %-50 %). Ils ambitionnent 3 véhicules à 18 mois et un salarié chauffeur.
>
> **Question :** quelles décisions structurantes doivent-ils prendre ?

**Correction :**

1. **Régime matrimonial** : passer en **séparation de biens** avant la création (notaire, ~1 000 €). Cela protège le patrimoine de Léa si Karim est gérant unique et que la SARL fait défaut.
2. **Répartition des parts** : 50/50 strict implique que le gérant désigné sera **égalitaire** (< 50 % strictement). Donc **assimilé salarié**, pas TNS. Si Karim est seul à travailler dans la SARL et veut TNS, prévoir 51/49.
3. **Nomination du gérant** : majorité simple (50 % + 1 voix) suffit. À 50/50, prévoir une clause de **départage** (par exemple : le gérant est nommé par tirage au sort en cas d'égalité, ou un **tiers arbitre** intervient).
4. **Pacte d'associés** (en plus des statuts) : prévoir clauses de sortie (préemption, agrément, prix de cession), notamment si l'un des deux veut quitter dans 5 ans.
5. **Garantie financière** : pour 1 véhicule = 1 800 €, pour 3 véhicules = 1 800 € + 2 × 900 € = **3 600 €** auprès d'une banque ou compagnie d'assurance.

### 3.4 Mini-exercice guidé

> ✏️ **À vous**
>
> **Marc** est seul, dispose de 50 000 € d'épargne, anticipe 80 000 €/an de CA dès la 2e année avec 2 chauffeurs salariés et un objectif d'agrandissement. Il privilégie la **protection sociale**.
>
> Quelle forme juridique recommander ? Justifiez en 3 points.

**Correction :**

**SASU** est le choix le plus cohérent :

1. **Protection sociale** : Marc en tant que président est **assimilé salarié** → meilleure couverture maladie, retraite, prévoyance.
2. **Croissance** : avec 80 K€ de CA et des salariés, la SASU offre un cadre solide pour lever des fonds, intégrer des associés (devient SAS), céder des actions.
3. **Image commerciale** : statut « SAS » plus rassurant pour de gros donneurs d'ordre que « EI » ou « EURL ».

**Limite à connaître :** cotisations sociales plus lourdes (~ 80 % du salaire) qu'en EURL (~ 45 % du revenu). Si Marc préfère **maximiser le revenu disponible immédiat**, l'EURL est meilleure. Le bon arbitrage dépend de sa priorité (cash vs filet de sécurité).

---

## 4. Démarches et timing

### 4.1 Calendrier réaliste de création

| Étape | Délai indicatif | Coût |
|---|---|---|
| 1. Choix forme + rédaction statuts | 1 à 4 semaines | 0 à 1 500 € (DIY ou avocat) |
| 2. Dépôt du capital en banque | 2 à 5 jours ouvrés | 0 (compte ouvert pour l'occasion) |
| 3. Publication annonce légale | 1 jour | 100 à 200 € |
| 4. Dépôt du dossier au greffe (Infogreffe ou guichet unique INPI) | 1 à 7 jours | 60 à 80 € de frais greffe |
| 5. Obtention du Kbis | 24 à 72 h après validation | inclus |
| 6. Demande Licence transport (LTI) à la DREAL | 4 à 8 semaines | ~ 30 € de frais DREAL |
| **Total fourchette** | **2 à 12 semaines** | **190 à 1 800 €** |

### 4.2 Erreurs fréquentes

> ❌ **Erreur n° 1 — Sous-capitaliser**
>
> Capital de 1 € symbolique en SARL/SAS = signal négatif aux banques et donneurs d'ordre. Visez **5 000 à 10 000 €** minimum si vous voulez crédibiliser.

> ❌ **Erreur n° 2 — Oublier la licence DREAL**
>
> Sans **Licence de transport intérieur**, vous ne pouvez pas légalement transporter pour autrui en compte d'autrui (≥ 0,5 t en VUL). La sanction est lourde : amende administrative + immobilisation du véhicule + interdiction temporaire d'exercice.

> ❌ **Erreur n° 3 — Confondre attestation de capacité et licence**
>
> L'**attestation de capacité professionnelle** (votre examen) est **personnelle** : elle reste valide à vie. La **licence** est **rattachée à l'entreprise** : elle suit le SIRET et doit être renouvelée tous les 10 ans.

---

## 5. Glossaire des notions clés

| Terme | Définition |
|---|---|
| **EI** | Entreprise Individuelle, sans personne morale, dirigeant = personne physique |
| **EURL** | SARL à associé unique |
| **SARL** | Société à Responsabilité Limitée, 2 à 100 associés, parts sociales |
| **SASU** | SAS à associé unique, président assimilé salarié |
| **SAS** | Société par Actions Simplifiée, ≥ 2 actionnaires, statuts libres |
| **TNS** | Travailleur Non-Salarié, régime SSI, ~ 45 % de cotisations |
| **Assimilé salarié** | Régime général Sécurité sociale, ~ 80 % de cotisations |
| **IS** | Impôt sur les Sociétés, taux 15 % puis 25 % au-dessus de 42 500 € de bénéfice |
| **IR** | Impôt sur le Revenu, taux progressif personnel |
| **Capital social** | Apports des associés constituant le patrimoine initial de la société |
| **LTI** | Licence de Transport Intérieur, obligatoire en compte d'autrui |
| **Garantie financière** | Caution exigée par la DREAL : 1 800 € pour le 1er véhicule, 900 € par suivant |

---

## 🧠 Synthèse opérationnelle

> 📌 **Les 8 points à retenir**
>
> 1. **5 formes** dominent : EI (simple, sans PM), EURL (PM, TNS), SARL (PM, TNS si gérant majoritaire), SASU (PM, assimilé salarié), SAS (PM, idem).
> 2. **TNS** ≈ 45 % de cotisations, **assimilé salarié** ≈ 80 %.
> 3. La **SARL** distingue gérant majoritaire (TNS) et minoritaire/égalitaire (assimilé salarié).
> 4. La **SAS/SASU** met **toujours** son président en assimilé salarié.
> 5. Capital minimum : 1 € pour toutes les formes en société, 50 % à libérer à la constitution.
> 6. **EI nouvelle formule depuis le 15 mai 2022** : séparation automatique des patrimoines, l'EIRL est supprimée.
> 7. Pour le transport : LTI obligatoire + garantie financière 1 800 € (1er véhicule) + 900 € par suivant.
> 8. **Capacité professionnelle** = attestation **personnelle**, valide à vie. **Licence** = liée au SIRET, renouvelée tous les 10 ans.

---

## 🎓 Ce que l'examinateur peut demander

Questions-types récurrentes sur cette leçon :

1. **« Quel est le régime social du gérant majoritaire d'une SARL ? »** → TNS. Piège : confusion avec assimilé salarié réservé aux minoritaires/égalitaires et au président de SAS.
2. **« Quel est le capital minimum d'une SAS ? »** → 1 €. Piège : ancien seuil de 37 000 € pour la SA standard, qui ne s'applique pas à la SAS.
3. **« L'EIRL existe-t-elle encore ? »** → Non, supprimée le 15 mai 2022, remplacée par le statut unique de l'EI avec séparation automatique des patrimoines.
4. **« Quelle est la fiscalité par défaut d'une SARL ? »** → IS. Option IR possible pour SARL de famille ou jeunes SARL (5 ans max).
5. **Cas concret en QR** : « Vous voulez démarrer seul, anticiper une croissance et une cession dans 5 ans : quelle forme choisir ? » → SASU est l'option qui maximise la flexibilité statutaire et la cessibilité.

---

## 📋 Mémo à imprimer

```
RESPONSABILITÉ LIMITÉE   → EURL, SARL, SASU, SAS
                          + EI nouvelle formule depuis 15/05/2022

GÉRANT MAJORITAIRE SARL  → TNS (~ 45 % cotisations)
GÉRANT MINORITAIRE SARL  → Assimilé salarié (~ 80 %)
PRÉSIDENT SAS / SASU     → Toujours assimilé salarié

CAPITAL SOCIAL MINIMAL   → 1 € (toutes formes en société)
LIBÉRATION SAS/SASU      → 50 % à la constitution, solde sous 5 ans
LIBÉRATION SARL/EURL     → 20 % à la constitution, solde sous 5 ans

LICENCE DREAL            → 1 800 € + 900 € par véhicule supplémentaire
ATTESTATION DE CAPACITÉ  → Personnelle, à vie
```
$lesson2$,
'Maîtriser le choix de la forme juridique adaptée à un projet de transport léger : EI, EURL, SARL, SASU, SAS — fiscalité, social, protection patrimoniale et obligations DREAL.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Vendre, facturer, sécuriser ses encaissements
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Vendre, facturer, sécuriser ses encaissements',
    'vendre-facturer-encaissements',
    3, 50,
$lesson3$
# Vendre, facturer, sécuriser ses encaissements

> 🎯 **Objectifs pédagogiques**
>
> À la fin de cette leçon, vous serez capable de :
>
> - **Rédiger** une facture conforme aux 14 mentions légales obligatoires.
> - **Distinguer** chèque, virement, lettre de change (LC), billet à ordre (BAO), carte bancaire.
> - **Choisir** le bon outil de paiement selon le profil client et le délai souhaité.
> - **Mobiliser** vos créances (escompte, affacturage, cession Dailly) pour transformer du papier en cash.
> - **Anticiper** les pièges du paiement à 60 jours (réglementation LME).

---

## Introduction

Vous savez piloter votre véhicule, planifier vos tournées, négocier avec vos donneurs d'ordre. Et pourtant, c'est sur la **facturation** et le **mode de paiement** que se jouera votre survie financière. **Une entreprise ne meurt pas faute de chiffre d'affaires : elle meurt faute de trésorerie**. Cette leçon vous donne les outils pour ne pas être une statistique de plus.

Le marché du transport de marchandises se paie majoritairement à **30 ou 60 jours fin de mois**. Si vous facturez 5 000 € en mars et que vous attendez le 31 mai pour être payé, vous devez avoir 5 000 € de trésorerie pour avancer le carburant, les salaires, l'URSSAF. Sans outils de mobilisation de créance, l'arrêt cardiaque est garanti. La maîtrise des effets de commerce et de l'affacturage est ce qui distingue le transporteur qui dure de celui qui dépose le bilan à 18 mois.

---

## 1. La facture : pièce juridique reine

### 1.1 Les 14 mentions obligatoires

Une facture conforme doit contenir **toutes** ces mentions, sous peine d'amende fiscale (15 € par mention manquante, plafonné à 1/4 de la facture).

| # | Mention | Précision transport |
|---|---|---|
| 1 | Date d'émission de la facture | Format jj/mm/aaaa |
| 2 | Numéro de facture (séquence chronologique continue) | Préfixe annuel ex. 2026-001 |
| 3 | Identité du vendeur (nom commercial, adresse, SIRET, forme juridique, capital, RCS) | Mentions exhaustives |
| 4 | Identité de l'acheteur (nom, adresse, SIRET si pro) | Vérifier le SIRET sur Pappers ou Infogreffe |
| 5 | Numéro TVA intracommunautaire (si > 150 € et pro) | FR + 11 chiffres |
| 6 | Désignation précise des prestations | « Transport de X palettes de Paris à Reims le 12/03 » |
| 7 | Quantité et prix unitaire HT | En €, à 2 décimales |
| 8 | Date de la prestation (≠ date facture) | Date d'enlèvement ou livraison |
| 9 | Réductions accordées | Remise quantitative, ristourne |
| 10 | Total HT | Somme des lignes |
| 11 | Taux et montant de TVA | 20 % standard, 10 % parfois pour transport |
| 12 | Total TTC | HT + TVA |
| 13 | Date d'échéance ou délai de paiement | « Paiement à 30 j fin de mois » |
| 14 | Conditions d'escompte + pénalités de retard + indemnité forfaitaire 40 € | Mentions LME 2008 |

> ⚠️ **Attention examen**
>
> Les 14 mentions sont parfois résumées en « 12 » ou « 15 » selon les sources. La référence officielle est l'**article L. 441-9 du Code de commerce** (anciennement L. 441-3). En cas de question piège, citez l'article et listez 6-8 mentions principales en justifiant.

### 1.2 Mentions LME : pénalités de retard et indemnité forfaitaire

Depuis la **loi LME du 4 août 2008**, deux mentions sont **obligatoires** sur toute facture B2B :

1. **Pénalités de retard** : taux applicable en cas de retard de paiement. Minimum légal = **3 fois le taux d'intérêt légal** (≈ 11 % en 2026) ou **taux BCE + 10 points** au choix.
2. **Indemnité forfaitaire** pour frais de recouvrement : **40 € HT par facture impayée** (article D. 441-5 du Code de commerce).

**Phrase type à insérer en pied de facture :**

> *« En cas de retard de paiement, application d'une pénalité au taux annuel de [taux BCE + 10 pts ou 3 × taux légal] et d'une indemnité forfaitaire de 40 € HT pour frais de recouvrement (art. L. 441-10 du Code de commerce). Pas d'escompte pour paiement anticipé. »*

### 1.3 Délais de paiement légaux (LME)

Le **délai maximal légal** de paiement entre professionnels est de :

- **30 jours** à compter de la livraison ou de la réception (régime de droit commun).
- Sur **accord** entre les parties : maximum **60 jours nets** ou **45 jours fin de mois**.
- En transport routier : **30 jours** maximum (régime spécial article L. 441-11 du Code de commerce).

> ⚠️ **Attention examen — Spécificité transport**
>
> Le délai de paiement en transport routier est **30 jours date de facture** (et non 60 j comme dans le droit commun). C'est une **règle d'ordre public**, donc même si le client impose 60 j dans son contrat, vous pouvez exiger les 30 j. Cette règle protège les transporteurs des donneurs d'ordre dominants.

### 1.4 Cas pratique 1 — Facture conforme

> 🚛 **Mise en situation**
>
> **Vous** (SARL « Express77 », SIRET 893 456 789 00012, RCS Meaux, capital 5 000 €, TVA FR55893456789) avez livré le **18 mars** 12 palettes pour **Cartonnage Reims SAS** (SIRET 542 109 876 00021, basé 5 av. de Champagne 51100). Tarif négocié : **2 200 € HT**, TVA 20 %.
>
> **Question :** rédigez le bordereau facture conforme.

**Correction** (extrait essentiel) :

```
SARL EXPRESS77
12 rue du Transport - 77100 Meaux
SIRET 893 456 789 00012 - RCS Meaux
Capital 5 000 € - TVA FR55893456789

Facture n° 2026-014
Émise le 22/03/2026

Client : Cartonnage Reims SAS
SIRET 542 109 876 00021
5 avenue de Champagne, 51100 Reims

Désignation                                    PU       Qté    HT
Transport 12 palettes Meaux→Reims          2 200,00     1     2 200,00
le 18/03/2026

                                Total HT     2 200,00
                                TVA 20 %       440,00
                                Total TTC    2 640,00

Paiement : 30 jours date de facture, soit le 22/04/2026.
En cas de retard : pénalités au taux BCE + 10 pts + indemnité
forfaitaire de 40 € HT (art. L. 441-10 C. com.). Pas d'escompte.
```

---

## 2. Les modes de paiement classiques

### 2.1 Tableau comparatif

| Mode | Sécurité | Délai cash | Coût pour vous |
|---|---|---|---|
| **Espèces** | ⚠️ Plafond 1 000 € entre pros, 1 000 € entre pro et particulier français (15 000 € touriste étranger) | Immédiat | 0 |
| **Chèque** | ⚠️ Risque rejet 8-15 jours | 8 à 15 jours | ~0,50 € + frais rejet 30-50 € si impayé |
| **Virement SEPA** | ✅ Très sûr | Quelques heures à 2 jours | 0 à 1 € |
| **Carte bancaire** | ✅ Très sûr | 1 à 3 jours | Commission ~ 1 à 2,5 % du montant |
| **Prélèvement SEPA** | ✅ Sûr (mandat préalable) | 2 jours | Quelques centimes |

> 💡 **Astuce métier**
>
> Pour vos premiers clients pros, **exigez** le **virement SEPA** ou l'**acceptation de lettre de change** (voir ci-après). Le chèque est tolérable mais à éviter pour les petits clients dont vous ne connaissez pas la solvabilité (rejet de chèque = -50 € de frais bancaires + impayé à recouvrer).

---

## 3. Les effets de commerce : la mécanique du crédit

### 3.1 Définition et utilité

> 📚 **Définition simple**
>
> Un **effet de commerce** est un titre négociable qui constate une créance entre commerçants et qui peut être **transformé en cash immédiatement** auprès d'une banque (escompte) ou transmis à un tiers (endossement).
>
> Concrètement : votre client vous doit 5 000 € à 60 jours. Vous transformez cette « promesse de payer » en **papier négociable**. Vous pouvez alors :
>
> - **Attendre** 60 jours et l'encaisser à l'échéance.
> - **L'escompter** auprès de votre banque (recevoir le cash immédiatement, moins les agios).
> - **Le transmettre** à un fournisseur en règlement de votre propre dette.

### 3.2 Lettre de change (LC) vs Billet à ordre (BAO)

| Critère | **Lettre de change (LC)** | **Billet à ordre (BAO)** |
|---|---|---|
| Émis par | **Le créancier** (vous, le transporteur) | **Le débiteur** (le client) |
| Acceptation requise | ✅ Oui (signature du tiré obligatoire) | Non (le souscripteur signe par défaut) |
| 3 acteurs | Tireur (vous) / Tiré (client) / Bénéficiaire (vous ou banque) | Souscripteur (client) / Bénéficiaire (vous) |
| Mécanique | Vous tirez sur votre client | Votre client souscrit en votre faveur |
| Juridiquement | Acte de commerce **par la forme** | Acte de commerce **par la nature** (si commercial) |
| Sécurité | ✅ Renforcée (acceptation + provision) | ⚠️ Moins (pas d'acceptation préalable) |

> 💡 **Astuce métier**
>
> En pratique, la LC est l'outil dominant en B2B français. Elle est plus sûre (le client a explicitement accepté la dette par sa signature), et elle est le format que demandent les banques pour l'escompte. Le BAO est plus rare, surtout réservé à des clients de confiance.

### 3.3 Mentions obligatoires d'une LC

| # | Mention |
|---|---|
| 1 | La dénomination « lettre de change » insérée dans le texte |
| 2 | Le mandat pur et simple de payer une somme déterminée |
| 3 | Le nom du tiré (celui qui doit payer = votre client) |
| 4 | L'échéance |
| 5 | Le lieu de paiement |
| 6 | Le nom du bénéficiaire (= vous ou votre banque) |
| 7 | La date et le lieu de création |
| 8 | La signature manuscrite du tireur (= vous) |

L'absence d'une mention rend la LC **nulle**. La signature du tiré (= acceptation) est ajoutée par le client.

### 3.4 Cas pratique 2 — Trésorerie urgente

> 🚛 **Mise en situation**
>
> **Vous** avez livré pour **18 000 € HT** à un client industriel qui paie habituellement à **60 jours**. Vous devez payer dans **15 jours** votre crédit-bail VUL (3 200 €) et un plein de carburant (800 €).
>
> **Question :** comment transformer la créance en cash ?

**Correction étape par étape :**

1. **Émettre une lettre de change** à 60 jours sur votre client, libellée à l'ordre de votre banque.
2. **Faire accepter** la LC par le client (signature au verso). Sans acceptation, la LC n'est pas escomptable.
3. **Présenter à votre banque pour escompte** : la banque vous verse le montant sous **48 h**, déduit les **agios** (~ 1 à 3 % annuel pro rata du délai = pour 60 j, ≈ 0,5 % du montant, soit ~ 90 € sur 18 000 €) et une **commission fixe** (~ 25 €).
4. À l'échéance des 60 j, le client paie directement la **banque** (pas vous).
5. **Risque résiduel** : si le client ne paie pas, la banque vous redemande la somme (recours du tireur).

**Cash net immédiat :** 18 000 € - 90 € agios - 25 € commission = **17 885 €** crédités sous 48 h.

### 3.5 L'affacturage : la solution pour systématiser

L'**affacturage** consiste à céder de manière régulière l'**ensemble** de vos factures à un **factor** (établissement spécialisé). Avantages :

- **Cash immédiat** dès l'émission de la facture (parfois 24 h après).
- **Garantie d'impayé** (le factor peut assurer la créance).
- **Délégation du recouvrement** (le factor relance et procède aux poursuites).

**Coût total :** 1 à 3 % du CA cédé (commission de service) + agios sur le financement (~ taux marché).

> 💡 **Astuce métier**
>
> L'affacturage est rentable dès que vous facturez régulièrement à des clients connus, sur un volume mensuel > 10 000 €. En dessous, l'escompte ponctuel reste plus économique.

---

## 4. La cession Dailly : variante méconnue

La **cession Dailly** (loi du 2 janvier 1981) permet à une entreprise de céder ses créances professionnelles à sa banque comme **garantie d'un crédit**, sans avoir besoin de chaque fois recourir à un effet de commerce.

| Caractéristique | Détail |
|---|---|
| Forme | Bordereau de cession daté et signé |
| Mention obligatoire | « Acte de cession de créances professionnelles » |
| Effet | La banque devient **propriétaire** des créances dès la signature |
| Notification du débiteur | Optionnelle (la banque peut le notifier ou non) |
| Coût | Frais de gestion bancaires (~ 0,3 à 0,8 % du montant) |

> 📌 **À retenir**
>
> Dailly est plus souple que la LC (pas besoin d'acceptation par le débiteur), mais il s'agit avant tout d'une **garantie pour un crédit** : la banque ne crédite pas immédiatement votre compte, elle garantit son crédit avec ces créances.

---

## 5. Mini-exercice guidé

> ✏️ **À vous**
>
> Pour chacune des situations suivantes, recommandez l'outil de paiement le plus adapté :
>
> 1. Petit client occasionnel, livraison ponctuelle de 1 200 € HT.
> 2. Grand donneur d'ordre récurrent, contrat annuel à 80 K€, vous voulez sécuriser le cash flow.
> 3. Nouveau client industriel, première commande à 8 500 € HT, profil inconnu.
> 4. Particulier qui demande une livraison de mobilier à 350 € TTC.

**Correction :**

1. **Virement SEPA à réception**, ou paiement carte si possible. Petit montant, pas besoin d'effets de commerce.
2. **Affacturage** sur l'ensemble du contrat → cash immédiat + garantie d'impayé. Vous pouvez aussi négocier un **billet à ordre mensuel** signé par le client si vous souhaitez éviter le coût du factor.
3. **Lettre de change acceptée** au moment de la livraison + escompte si trésorerie tendue. Vérifiez la solvabilité (Pappers, Société.com) avant de livrer.
4. **Espèces** (plafond OK car < 1 000 € entre pro et particulier français) ou **carte bancaire** sur terminal portable. Évitez le chèque pour un particulier inconnu.

---

## 6. Glossaire des notions clés

| Terme | Définition |
|---|---|
| **LME** | Loi de Modernisation de l'Économie (2008), encadre les délais de paiement et les pénalités |
| **TVA** | Taxe sur la Valeur Ajoutée, 20 % standard, 10 % sur certains transports de personnes |
| **Lettre de change** | Effet par lequel le tireur ordonne au tiré de payer une somme à l'échéance au bénéficiaire |
| **Billet à ordre** | Effet par lequel le souscripteur s'engage à payer une somme à l'échéance |
| **Escompte** | Opération bancaire qui transforme un effet en cash immédiat moyennant agios |
| **Affacturage** | Cession régulière de créances à un factor avec financement et garantie d'impayé |
| **Cession Dailly** | Cession de créances pro à la banque comme garantie d'un crédit |
| **LCR / BOR** | Lettre de Change Relevé / Billet à Ordre Relevé (versions dématérialisées) |
| **Tiré** | Celui qui doit payer (votre client) |
| **Tireur** | Celui qui émet l'effet (vous, le créancier) |

---

## 🧠 Synthèse opérationnelle

> 📌 **Les 8 points à retenir**
>
> 1. **14 mentions obligatoires** sur une facture (article L. 441-9 C. com.).
> 2. **Délai légal max** entre pros : 30 j droit commun, 60 j sur accord, 30 j en transport routier (règle spéciale d'ordre public).
> 3. **Pénalités de retard** + **indemnité forfaitaire 40 € HT** obligatoires en pied de facture (LME).
> 4. **Lettre de change** (LC) : émise par le créancier, acceptée par le client. Plus sûr que le BAO.
> 5. **Billet à ordre** (BAO) : émis par le débiteur en faveur du créancier.
> 6. **Escompte** : transformer un effet en cash immédiat (~ 0,5 à 1 % de coût pour 60 j).
> 7. **Affacturage** : cession régulière de l'ensemble des factures, ~ 1 à 3 % de commission.
> 8. **Espèces** plafonnées à 1 000 € entre pros (15 000 € touriste étranger en France).

---

## 🎓 Ce que l'examinateur peut demander

Questions-types récurrentes :

1. **« Combien de mentions obligatoires sur une facture entre pros ? »** → 14 (variations possibles 12 à 15 selon sources). Article L. 441-9.
2. **« Quel est le délai max de paiement en transport routier ? »** → 30 jours date de facture (art. L. 441-11). Piège : confusion avec le 60 j de droit commun.
3. **« Différence LC / BAO ? »** → LC émise par le créancier (avec acceptation du tiré), BAO émis par le débiteur.
4. **« Coût indicatif d'un escompte sur LC à 60 j ? »** → ~ 0,5 % du montant en agios + commission fixe ≈ 25 €.
5. **Cas en QR** : Vous êtes en tension trésorerie, comment monétiser une créance à 60 j → escompte LC ou affacturage.

---

## 📋 Mémo à imprimer

```
DÉLAI LÉGAL TRANSPORT     → 30 j date de facture (ordre public)
DÉLAI MAX DROIT COMMUN    → 60 j nets ou 45 j fin de mois
INDEMNITÉ FORFAITAIRE     → 40 € HT / facture impayée
PÉNALITÉS                 → Min. 3 × taux légal ou taux BCE + 10 pts

LC (lettre de change)     → Émise PAR vous, acceptée PAR le client
BAO (billet à ordre)      → Émis PAR le client en VOTRE faveur

ESCOMPTE LC               → Cash sous 48 h, agios ~ 0,5 % pour 60 j
AFFACTURAGE              → Cash immédiat, ~ 1 à 3 % du CA cédé

ESPÈCES MAX (entre pros)  → 1 000 € (peines : amende 5 % du montant)
ESPÈCES MAX (particulier) → 1 000 € en France (touriste étranger : 15 000 €)
```
$lesson3$,
'Maîtriser la facturation conforme, choisir le bon mode de paiement, comprendre lettre de change, billet à ordre, escompte et affacturage pour sécuriser sa trésorerie.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Garantir et recouvrer ses créances
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Garantir et recouvrer ses créances',
    'garantir-recouvrer-creances',
    4, 45,
$lesson4$
# Garantir et recouvrer ses créances

> 🎯 **Objectifs pédagogiques**
>
> À la fin de cette leçon, vous serez capable de :
>
> - **Distinguer** les sûretés personnelles (caution) et réelles (gage, nantissement, hypothèque).
> - **Choisir** la sûreté adaptée selon le bien à garantir.
> - **Engager** une procédure de recouvrement amiable puis judiciaire.
> - **Comprendre** la mécanique de l'injonction de payer (procédure rapide et peu coûteuse).
> - **Anticiper** les délais de prescription pour ne pas perdre vos créances.

---

## Introduction

Avoir un bon contrat ne suffit pas. Le jour où votre client refuse de payer, votre survie dépend de **deux capacités** : la **garantie** que vous avez prise au démarrage (sûretés) et la **procédure** que vous savez engager rapidement (recouvrement).

Cette leçon traite de l'arsenal juridique disponible. Beaucoup de transporteurs débutants signent sans garanties, perdent 6 mois en relances stériles, puis découvrent trop tard que la créance est prescrite. Le cas le plus fréquent : votre client est en cessation de paiement et vous figurez parmi les **derniers** créanciers servis. Sans garantie, sans privilège, vous récupérez en moyenne **3 à 8 % de la créance** dans une liquidation judiciaire.

---

## 1. Les sûretés personnelles : la caution

### 1.1 Définition et mécanique

> 📚 **Définition simple**
>
> La **caution** est une personne (physique ou morale) qui s'engage à payer la dette d'un débiteur si celui-ci ne paie pas.
>
> Vous (créancier) → débiteur (votre client) → **caution** (engagement de la caution si défaut).

### 1.2 Caution simple vs caution solidaire

| Type | Définition | Conséquence pour vous (créancier) |
|---|---|---|
| **Caution simple** | La caution peut exiger que vous poursuiviez d'abord le débiteur principal (bénéfice de discussion) | ⚠️ Procédure plus longue : il faut établir l'insolvabilité du débiteur avant de saisir la caution |
| **Caution solidaire** | Vous pouvez poursuivre la caution **directement**, sans avoir à passer par le débiteur principal | ✅ Recouvrement plus rapide : exiger le paiement à la caution dès le 1er retard |

> ⚠️ **Attention examen**
>
> Une caution est **toujours simple par défaut** sauf si le contrat précise expressément « caution solidaire ». Toujours **exiger** la mention « caution solidaire » dans le contrat ; sans elle, vous perdez plusieurs mois en cas de poursuite.

### 1.3 Le « consentement exprès » du conjoint marié

Lorsqu'un dirigeant marié sous **communauté légale** se porte caution, l'**article 1415 du Code civil** impose une formalité essentielle :

> *« Chacun des époux ne peut, sans le consentement de l'autre, hypothéquer ou cautionner un emprunt, sauf si cet engagement n'a été consenti que sur ses biens propres et ses revenus. »*

**Conséquence pratique :** sans consentement exprès du conjoint, la caution n'engage **que** les biens propres de l'époux signataire et ses revenus, **pas les biens communs** (compte joint, voiture, résidence secondaire). C'est une protection puissante mais souvent ignorée.

### 1.4 Cas pratique 1 — Caution sur prêt SARL

> 🚛 **Mise en situation**
>
> **Vous gérez une SARL** de transport. La banque vous accorde un prêt de **80 000 €** pour acheter 2 VUL supplémentaires, à condition que vous vous portiez **caution personnelle solidaire à 100 %**.
>
> **Question :** quelles précautions concrètes prendre avant de signer ?

**Correction :**

1. **Limiter la caution dans le temps** : exiger qu'elle dégresse avec le remboursement du prêt (par exemple : capital restant dû, pas une somme fixe).
2. **Limiter le montant** : 100 % est la demande type des banques mais **négociable**. Visez **70-80 %** sur des prêts importants.
3. **Cosigner avec une caution mutuelle** (BPI, SIAGI) : ces organismes spécialisés peuvent se substituer à votre engagement personnel pour 30 à 50 % de la dette, moyennant une commission de 1 à 2 % de la garantie.
4. **Si vous êtes marié sous communauté** : votre conjoint doit signer un **consentement exprès** s'il veut que les biens communs soient engagés. Sans cette signature, la caution n'engage que vos biens propres.
5. **Faire relire** le contrat par un avocat ou un expert-comptable. Le surcoût de 200-400 € est rentable face à un risque de saisie de patrimoine personnel.

---

## 2. Les sûretés réelles : gage, nantissement, hypothèque

### 2.1 Tableau comparatif

| Sûreté | Bien grevé | Possession | Inscription |
|---|---|---|---|
| **Gage** | Bien meuble corporel (camion, machine, marchandise) | Avec ou sans dépossession | Registre des gages (greffe) |
| **Nantissement** | Bien meuble incorporel (parts sociales, fonds de commerce, créance) | Sans dépossession | RCS ou registre spécial |
| **Hypothèque** | Bien immeuble (terrain, bâtiment, hangar) | Sans dépossession | Service de la publicité foncière |

### 2.2 Le nantissement de fonds de commerce

Particulièrement utile en transport pour donner accès à un crédit : le nantissement du **fonds de commerce** (clientèle, droit au bail, matériel d'exploitation) permet à la banque d'avoir une garantie sans déposséder l'entrepreneur de l'usage de ses outils.

> 💡 **Astuce métier**
>
> En cas de difficulté future, le nantissement permet à la banque de saisir et vendre le fonds, mais elle préfère généralement renégocier la dette. C'est donc à la fois une garantie pour la banque **et** un levier de négociation pour vous (vous gardez la maîtrise de l'outil de travail tant que vous payez).

### 2.3 Cas pratique 2 — Bien grever quoi ?

> 🚛 **Mise en situation**
>
> **Vous demandez un crédit-bail VUL** de 35 000 € à votre concessionnaire. Quelle sûreté la société de financement va-t-elle exiger ?

**Correction :**

Dans un crédit-bail (leasing), la société financière reste **propriétaire** du véhicule jusqu'à la levée de l'option d'achat finale. Donc, techniquement, elle n'a pas besoin d'une sûreté distincte : elle conserve la **carte grise** au nom de l'organisme. C'est elle qui détient la « propriété-sûreté ».

En revanche, si le contrat est un **prêt classique** (vous achetez le véhicule comptant avec un crédit), la banque demandera :

1. **Gage du véhicule** (inscription au registre des gages tenu par le greffe) : la banque peut saisir et vendre le véhicule en cas de défaut.
2. **Caution personnelle** du gérant si entreprise jeune.
3. **Assurance crédit** parfois exigée (la banque est bénéficiaire en cas de décès / invalidité du dirigeant).

---

## 3. Le recouvrement amiable

### 3.1 Les étapes graduelles

| Étape | Délai | Outil | Coût |
|---|---|---|---|
| 1. Relance simple | J+5 après échéance | Email + appel | 0 |
| 2. 2e relance ferme | J+15 | Lettre simple | 1 € |
| 3. Mise en demeure | J+30 | LRAR (lettre recommandée avec accusé de réception) | 7 € |
| 4. Recours amiable formalisé | J+45 | Société de recouvrement | 8 à 15 % du recouvré |

### 3.2 La mise en demeure : pivot juridique

La **lettre recommandée de mise en demeure** est l'acte qui :

- **Marque officiellement** le retard de paiement.
- **Fait courir** les intérêts de retard à compter de sa réception.
- **Constitue** la **preuve** indispensable pour engager une procédure judiciaire ensuite.

**Mentions obligatoires :**
- Référence précise à la facture impayée.
- Mention « mise en demeure ».
- Délai imparti pour régler (8 à 15 jours).
- Conséquences en cas de non-paiement (procédure judiciaire, agios, indemnités).

> 💡 **Astuce métier**
>
> Sans mise en demeure préalable, votre dossier judiciaire ultérieur peut être considéré comme prématuré et vous risquez de devoir attendre encore. Toujours envoyer la LRAR **avant** de saisir le tribunal.

---

## 4. Le recouvrement judiciaire

### 4.1 Trois procédures rapides

| Procédure | Domaine | Avocat obligatoire | Délai |
|---|---|---|---|
| **Injonction de payer** | Créance certaine, exigible, en argent | Non | 4 à 8 semaines |
| **Référé provision** | Créance non sérieusement contestable | Oui (souvent) | 4 à 8 semaines |
| **Assignation au fond** | Toute créance, même contestée | Oui | 6 mois à 2 ans |

### 4.2 L'injonction de payer (la plus utilisée)

C'est la procédure-clé des transporteurs. **Article 1405 du Code de procédure civile.** Caractéristiques :

- **Avocat non obligatoire**.
- **Coût** : ~ 40 € de frais de greffe.
- **Délai** : ordonnance rendue sous 2 à 4 semaines.
- **Procédure non contradictoire** : seul le créancier dépose un dossier, le débiteur n'est convoqué qu'**après** l'ordonnance.

**Pour le transporteur, le tribunal compétent est le tribunal de commerce du domicile du débiteur** (créance commerciale).

### 4.3 Cas pratique 3 — Procédure rapide

> 🚛 **Mise en situation**
>
> **Votre SARL** (siège à Meaux, 77) a effectué une livraison pour un client commerçant à **Reims** (51) facturée **4 200 €** le 10 janvier. Le client n'a toujours pas payé au 15 mars malgré 2 relances et une mise en demeure recommandée.
>
> **Question :** quelle procédure engager ?

**Correction étape par étape :**

1. **Injonction de payer** (article 1405 CPC).
2. **Tribunal compétent** : tribunal de commerce de **Reims** (domicile du débiteur, règle pour créances commerciales).
3. **Dossier à déposer** : copie de la facture, mise en demeure LRAR avec AR signé, bons de livraison, requête en injonction.
4. **Coût** : ~ 40 € de frais de greffe. **Avocat non obligatoire**.
5. **Délai** : ordonnance rendue sous 2 à 4 semaines.
6. **Suite** :
   - Si le client **ne conteste pas** dans le mois suivant la signification de l'ordonnance par huissier → l'ordonnance devient un **titre exécutoire** permettant la saisie sur compte bancaire ou rémunérations.
   - S'il **conteste** (opposition) → l'affaire est renvoyée devant le tribunal qui jugera contradictoirement (avocat alors généralement nécessaire).

---

## 5. Les délais de prescription

### 5.1 Les 4 délais à connaître

| Type de créance | Prescription |
|---|---|
| **Civile entre particuliers** | 5 ans (art. 2224 C. civ.) |
| **Commerciale entre commerçants** | 5 ans (art. L. 110-4 C. com.) |
| **Transport de marchandises** | **1 an** (art. L. 133-6 C. com.) — **règle spéciale** |
| **Transport international (CMR)** | 1 an (3 ans en cas de dol ou faute lourde) |

> ⚠️ **Attention examen — Spécificité transport**
>
> En matière de transport de marchandises, la prescription est **réduite à 1 an** à compter de la livraison. C'est très court. Si vous laissez « traîner » un dossier 14 mois, vous perdez votre droit d'agir, même avec un titre parfait.
>
> **Comment interrompre la prescription ?**
> - Reconnaissance du débiteur (par écrit).
> - Acte d'exécution forcée (saisie).
> - Saisine du juge.

### 5.2 Mini-exercice guidé

> ✏️ **À vous**
>
> **Vous** avez livré le 15 janvier 2025. Le client a reçu la facture le 25 janvier 2025. Au 5 mars 2026, vous n'avez toujours pas été payé.
>
> 1. Quel est le délai de prescription applicable ?
> 2. À quelle date la créance se prescrit-elle ?
> 3. Que devez-vous faire avant cette date ?

**Correction :**

1. **Prescription transport** : 1 an à compter de la livraison.
2. **Prescription échue le 15 janvier 2026**. Au 5 mars 2026, **votre créance est prescrite** depuis 7 semaines.
3. **À cette date, il est trop tard** pour engager une procédure. Pour éviter ce piège : engager la procédure d'injonction de payer **au plus tard 9-10 mois** après la livraison pour avoir une marge de sécurité.

---

## 6. Glossaire des notions clés

| Terme | Définition |
|---|---|
| **Sûreté** | Garantie accordée à un créancier pour sécuriser sa créance |
| **Caution simple** | Engagement subsidiaire ; bénéfice de discussion possible |
| **Caution solidaire** | Engagement direct ; le créancier peut poursuivre directement la caution |
| **Gage** | Sûreté sur un bien meuble corporel |
| **Nantissement** | Sûreté sur un bien meuble incorporel (parts, créances, fonds de commerce) |
| **Hypothèque** | Sûreté sur un bien immeuble |
| **Mise en demeure** | LRAR sommant le débiteur de payer, fait courir les intérêts de retard |
| **Injonction de payer** | Procédure simplifiée et peu coûteuse pour créance non contestée |
| **Référé** | Procédure d'urgence devant le juge |
| **Prescription transport** | 1 an à compter de la livraison (art. L. 133-6 C. com.) |
| **CPC** | Code de procédure civile |

---

## 🧠 Synthèse opérationnelle

> 📌 **Les 8 points à retenir**
>
> 1. **Sûretés personnelles** : caution simple (avec bénéfice de discussion) ou caution solidaire (recours direct).
> 2. **Sûretés réelles** : gage (meubles corporels), nantissement (incorporels), hypothèque (immobilier).
> 3. **Conjoint marié sous communauté** doit donner un **consentement exprès** pour engager les biens communs (art. 1415 C. civ.).
> 4. **Mise en demeure LRAR** = pivot juridique : marque officiellement le retard, fait courir les intérêts.
> 5. **Injonction de payer** : procédure rapide, ~ 40 € de frais, avocat non obligatoire, ordonnance sous 2-4 semaines.
> 6. **Tribunal de commerce du domicile du débiteur** est compétent en transport (créance commerciale).
> 7. **Prescription transport** : **1 an** à compter de la livraison (règle spéciale plus courte que les 5 ans de droit commun).
> 8. **Saisir le juge** dans les 9-10 mois pour avoir une marge de sécurité avant la prescription d'1 an.

---

## 🎓 Ce que l'examinateur peut demander

Questions-types récurrentes :

1. **« Différence caution simple vs solidaire ? »** → Simple = bénéfice de discussion (poursuivre d'abord le débiteur). Solidaire = recours direct sur la caution.
2. **« Quelle prescription en transport ? »** → 1 an à compter de la livraison. Piège : confusion avec les 5 ans de droit commun.
3. **« Quelle sûreté pour un fonds de commerce ? »** → Nantissement (bien meuble incorporel).
4. **« Quel tribunal compétent pour recouvrer une créance commerciale ? »** → Tribunal de commerce du domicile du débiteur.
5. **Cas en QR** : impayé 4 200 € à Reims depuis 2 mois → injonction de payer au tribunal de commerce de Reims, ~ 40 € de frais, ordonnance sous 4 semaines.

---

## 📋 Mémo à imprimer

```
SÛRETÉ PERSONNELLE       → Caution simple OU solidaire
                          (toujours exiger SOLIDAIRE)
SÛRETÉ RÉELLE MEUBLE     → Gage (corporel) ou nantissement (incorporel)
SÛRETÉ RÉELLE IMMEUBLE   → Hypothèque

CONSENTEMENT CONJOINT    → Obligatoire (art. 1415 C. civ.) pour
                          engager biens communs (caution)

MISE EN DEMEURE          → LRAR avec mention « mise en demeure »,
                          fait courir intérêts retard

INJONCTION DE PAYER      → ~ 40 €, sans avocat, 4 semaines
                          Tribunal de commerce du domicile débiteur

PRESCRIPTION TRANSPORT   → 1 AN dès la livraison (art. L. 133-6 C. com.)
PRESCRIPTION COMMERCIALE → 5 ans (art. L. 110-4 C. com.)
```
$lesson4$,
'Maîtriser les sûretés personnelles et réelles, engager une procédure de recouvrement amiable puis judiciaire, et respecter le délai de prescription d''1 an en transport.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- LEÇON 5 — Difficultés de l'entreprise et juridictions
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Difficultés de l''entreprise et juridictions',
    'difficultes-juridictions',
    5, 50,
$lesson5$
# Difficultés de l'entreprise et juridictions

> 🎯 **Objectifs pédagogiques**
>
> À la fin de cette leçon, vous serez capable de :
>
> - **Identifier** le seuil d'alerte des capitaux propres et l'obligation de réunir l'AGE.
> - **Distinguer** sauvegarde, redressement et liquidation judiciaires.
> - **Définir** juridiquement la cessation de paiement et la déclarer dans les délais.
> - **Localiser** votre litige : tribunal judiciaire vs tribunal de commerce.
> - **Anticiper** les conséquences personnelles d'une faillite (faillite personnelle, banqueroute).

---

## Introduction

Personne ne crée son entreprise en imaginant la fermer. Pourtant, **30 %** des PME françaises de moins de 5 ans déposent le bilan. Connaître les procédures **avant** d'en avoir besoin permet de **les anticiper**, de **réagir vite** et parfois de **sauver l'entreprise**.

Le droit français a beaucoup évolué : depuis la loi de sauvegarde de 2005 et les retouches récentes, les procédures dites « préventives » se sont multipliées (mandat ad hoc, conciliation, sauvegarde) avant la procédure dure du redressement et de la liquidation. **Plus vous saisissez tôt, plus vos chances de sauver l'entreprise sont grandes.**

---

## 1. L'alerte sur les capitaux propres

### 1.1 Le seuil critique

> 📚 **Définition**
>
> Les **capitaux propres** correspondent au patrimoine net comptable de la société : capital social + réserves + report à nouveau + résultat de l'exercice. Lorsque les pertes successives consomment ces réserves, les capitaux propres peuvent devenir **négatifs**.

L'**article L. 223-42 du Code de commerce** (SARL) et **L. 225-248** (SA/SAS) impose une vigilance particulière dès que les **capitaux propres deviennent inférieurs à la moitié du capital social**.

### 1.2 Procédure obligatoire

| Étape | Délai | Acte |
|---|---|---|
| **1.** Constat par le gérant ou le commissaire aux comptes | À la clôture de l'exercice | Mention au rapport de gestion |
| **2.** Réunion d'une **AGE** (Assemblée Générale Extraordinaire) | Dans les **4 mois** suivant l'AG d'approbation | Vote sur la dissolution ou la poursuite |
| **3.** Si poursuite votée : **régularisation** des capitaux propres | Dans les **2 exercices** suivant celui de la perte | Recapitalisation, augmentation de capital, abandon de créance d'associé |
| **4.** Si non régularisé | Au-delà des 2 exercices | Tout intéressé peut demander la **dissolution judiciaire** |

> ⚠️ **Attention examen**
>
> Trois chiffres clés à retenir :
> - **< 50 % du capital social** → seuil critique
> - **4 mois** après l'AG → délai pour réunir l'AGE
> - **2 exercices** après celui de la perte → délai pour régulariser

---

## 2. Les trois procédures collectives

### 2.1 Tableau d'aiguillage

| Procédure | Conditions d'ouverture | Objectif | Sortie |
|---|---|---|---|
| **Sauvegarde** | Difficultés que l'entreprise ne peut pas surmonter mais **PAS encore** en cessation de paiement | Préventif : geler le passif, restructurer | Plan de sauvegarde |
| **Redressement judiciaire** | **Cessation de paiement** + entreprise jugée **redressable** | Curatif : sauver l'entreprise | Plan de redressement OU bascule en liquidation |
| **Liquidation judiciaire** | **Cessation de paiement** + redressement **manifestement impossible** | Mettre fin à l'activité, payer les créanciers | Vente des actifs, clôture |

### 2.2 La cessation de paiement : pivot juridique

> 📚 **Définition juridique** (article L. 631-1 C. com.)
>
> *« L'entreprise est en cessation de paiement lorsqu'elle est dans l'impossibilité de faire face au passif exigible avec son actif disponible. »*

| Élément | Précision |
|---|---|
| **Passif exigible** | Dettes échues et non payées (factures fournisseurs en retard, URSSAF, salaires) |
| **Actif disponible** | Trésorerie immédiate (compte courant, caisse, valeurs liquides) — PAS les créances clients à venir |

**Test rapide :**

```
Liquidités sur compte + caisse + valeurs immédiatement liquides
  vs
Dettes ÉCHUES NON PAYÉES (URSSAF en retard, factures impayées,
salaires en retard, échéances de prêt en défaut)
```

Si actif disponible **<** passif exigible → cessation de paiement.

### 2.3 L'obligation de déclaration : 45 jours

Le dirigeant est **obligé** de déclarer la cessation de paiement au tribunal de commerce dans les **45 jours** suivant son constat.

| Conséquence d'une déclaration tardive | Sanction |
|---|---|
| Faillite personnelle | Jusqu'à **15 ans** |
| Interdiction de gérer | Jusqu'à **5 ans** |
| Responsabilité civile pour insuffisance d'actif | Le tribunal peut faire payer **personnellement** au dirigeant tout ou partie du passif (art. L. 651-2) |
| Banqueroute (si fraude) | Délit pénal : 5 ans de prison + 75 000 € d'amende |

### 2.4 Cas pratique 1 — État de cessation ?

> 🚛 **Mise en situation**
>
> Votre SARL de transport présente la situation suivante au 31 mars :
>
> - Trésorerie compte pro : **2 200 €**
> - Caisse : **0 €**
> - Factures fournisseurs en retard : **18 000 €**
> - Cotisations URSSAF en retard : **12 000 €**
> - Découvert bancaire autorisé : **plein (limite atteinte)**
> - Créances clients à recouvrer (échéances mai/juin) : **45 000 €**
>
> **Question :** êtes-vous en cessation de paiement ?

**Correction :**

1. **Actif disponible** = 2 200 € (uniquement la trésorerie immédiate ; les créances clients à venir **ne comptent pas**, même si elles sont importantes).
2. **Passif exigible** = 18 000 + 12 000 = **30 000 €** (toutes ces dettes sont déjà échues et non payées).
3. **Actif disponible (2 200 €) < Passif exigible (30 000 €)** → **OUI, en cessation de paiement**.
4. **Obligation** : déclarer au tribunal de commerce dans les **45 jours**.
5. **Procédures possibles** :
   - **Redressement judiciaire** si le carnet de commandes laisse espérer un redressement.
   - **Liquidation judiciaire** si manifestement irredressable.

---

## 3. Le déroulement des procédures

### 3.1 La sauvegarde (procédure préventive)

| Étape | Détail |
|---|---|
| Demande | Par le dirigeant uniquement (volontaire) |
| Conditions | Difficultés mais **PAS de cessation de paiement** |
| Effet immédiat | Gel du passif antérieur, nomination d'un mandataire |
| Période d'observation | 6 mois renouvelable (max 18 mois) |
| Sortie | Plan de sauvegarde (10 ans max) ou bascule en redressement |

### 3.2 Le redressement judiciaire

| Étape | Détail |
|---|---|
| Demande | Dirigeant (obligatoire dans les 45 j de cessation) ou créancier ou ministère public |
| Conditions | Cessation de paiement + redressement possible |
| Effet immédiat | Gel du passif, période d'observation, nomination administrateur judiciaire |
| Période d'observation | 6 mois renouvelable (max 18 mois) |
| Sortie | Plan de redressement (10 ans), cession partielle ou totale, ou liquidation |

### 3.3 La liquidation judiciaire

| Étape | Détail |
|---|---|
| Demande | Idem redressement, mais entreprise irredressable |
| Effet immédiat | Cessation immédiate de l'activité (sauf maintien provisoire), nomination liquidateur |
| Mission liquidateur | Réaliser l'actif, apurer le passif, répartir entre créanciers selon ordre des privilèges |
| Sortie | Clôture pour insuffisance d'actif (cas le plus fréquent) ou pour extinction du passif |

### 3.4 Cas pratique 2 — Choix de la procédure

> 🚛 **Mise en situation**
>
> Votre SARL de transport a 35 000 € de dettes URSSAF, fournisseurs et carburant. Trésorerie : 1 800 €. Mais vous avez signé hier un contrat annuel récurrent de **120 000 €** avec un nouveau gros client industriel. Le carburant et les salaires sont à régler dans 8 jours.
>
> **Question :** quelle procédure demander ?

**Correction :**

L'analyse :

1. **Cessation de paiement** : oui (1 800 € < 35 000 €). Donc sauvegarde **exclue**.
2. **Capacité de redressement** : oui, le contrat de 120 K€ représente un flux régulier qui peut financer le remboursement progressif. L'entreprise n'est pas irréparablement compromise.
3. **Conclusion** : **redressement judiciaire** est la bonne option.

**Démarche concrète** :

- Demande au tribunal de commerce dans les **8 jours** (avant les échéances carburant/salaires si possible).
- Joindre au dossier : bilan, liste des créanciers, copie du contrat 120 K€, attestation du commissaire aux comptes.
- Le tribunal va probablement ouvrir le RJ avec **période d'observation de 6 mois**, le temps d'établir un plan de remboursement étalé sur 8-10 ans.

---

## 4. Les juridictions compétentes

### 4.1 Tribunal judiciaire vs tribunal de commerce

| Tribunal | Composition | Compétence |
|---|---|---|
| **Tribunal judiciaire** | Magistrats professionnels | Litiges civils, particuliers, baux, succession, divorce, procédures collectives des **professions libérales** et **agriculteurs** |
| **Tribunal de commerce** | **Juges consulaires** (commerçants élus pour 4 ans, non payés) | Litiges entre commerçants, actes de commerce, sociétés commerciales, **procédures collectives des entreprises commerciales** |

### 4.2 Composition du tribunal de commerce

- **Juges consulaires** élus par le **collège des commerçants** (chambre de commerce, syndicats pros).
- **3 juges minimum** par jugement.
- Mandat de **4 ans**, renouvelable.
- **Bénévoles** (non rémunérés).

### 4.3 Compétence territoriale

La règle générale : tribunal du **domicile du débiteur**.

| Cas | Tribunal compétent |
|---|---|
| Recouvrement créance commerciale | Tribunal de commerce du domicile du débiteur |
| Procédure collective (RJ, LJ) | Tribunal de commerce du siège social de l'entreprise débitrice |
| Litige bail commercial | Tribunal judiciaire du lieu de l'immeuble |
| Litige social (chauffeur salarié) | Conseil de prud'hommes du lieu d'emploi |

### 4.4 Voies de recours

| Montant du litige | Voie de recours |
|---|---|
| **≤ 5 000 €** | **Premier et dernier ressort** : pas d'appel possible, seul un pourvoi en cassation sur question de droit |
| **> 5 000 €** | **Appel** possible devant la **Cour d'appel** dans le **mois** suivant la signification, puis pourvoi en cassation sur question de droit |

---

## 5. Sanctions personnelles du dirigeant

### 5.1 Faillite personnelle

Prononcée par le tribunal en cas de **faute lourde** (détournement d'actif, comptabilité frauduleuse, poursuite abusive d'une activité déficitaire).

| Effet | Durée |
|---|---|
| Interdiction d'exercer toute activité commerciale | Jusqu'à **15 ans** |
| Interdiction de gérer toute société commerciale | Idem (corollaire) |
| Inscription au Fichier national des interdits de gérer (CNGTC) | Idem |

### 5.2 Interdiction de gérer

Sanction moins lourde, sans déchéance des droits civiques. **Jusqu'à 5 ans**. Interdit la direction, la gestion, l'administration ou le contrôle d'une société commerciale.

### 5.3 Banqueroute

Délit pénal (article L. 654-1 C. com.) sanctionné en cas de :

- Détournement ou dissimulation d'actif.
- Augmentation frauduleuse du passif.
- Tenue de comptabilité fictive ou disparition de pièces.
- Comptabilité incomplète ou irrégulière.

**Peines** : 5 ans de prison + 75 000 € d'amende.

### 5.4 Mini-exercice guidé

> ✏️ **À vous**
>
> Pour chacun des comportements suivants, identifiez la sanction encourue :
>
> 1. Le dirigeant a continué à signer des bons de commande pendant 6 mois après avoir constaté la cessation de paiement, sans déclaration au tribunal.
> 2. Le dirigeant a vendu un VUL à son frère pour 1 € la veille de la liquidation.
> 3. Le dirigeant n'a pas mis à jour la comptabilité depuis 8 mois et plusieurs documents ont disparu.

**Correction :**

1. **Responsabilité civile pour insuffisance d'actif** (art. L. 651-2) + faillite personnelle ou interdiction de gérer pour poursuite abusive d'activité déficitaire.
2. **Banqueroute** (détournement d'actif) → 5 ans de prison + 75 000 € d'amende. La vente sera également **annulée** par le mandataire.
3. **Banqueroute** (comptabilité fictive ou disparition de pièces) + **interdiction de gérer**.

---

## 6. Glossaire des notions clés

| Terme | Définition |
|---|---|
| **Capitaux propres** | Capital + réserves + report + résultat |
| **Cessation de paiement** | Impossibilité de faire face au passif exigible avec l'actif disponible |
| **Sauvegarde** | Procédure préventive sans cessation de paiement |
| **Redressement judiciaire (RJ)** | Procédure curative pour entreprise en cessation mais redressable |
| **Liquidation judiciaire (LJ)** | Procédure terminale pour entreprise irredressable |
| **Période d'observation** | Phase d'analyse pendant laquelle le passif est gelé (6 à 18 mois) |
| **Plan de sauvegarde / redressement** | Étalement des dettes sur 10 ans maximum |
| **Tribunal de commerce** | Juges consulaires, 3 par jugement, compétents pour entreprises commerciales |
| **Juge consulaire** | Commerçant élu, bénévole, mandat 4 ans |
| **Faillite personnelle** | Sanction jusqu'à 15 ans pour faute lourde du dirigeant |
| **Banqueroute** | Délit pénal pour fraude (5 ans prison + 75 000 €) |

---

## 🧠 Synthèse opérationnelle

> 📌 **Les 8 points à retenir**
>
> 1. **Capitaux propres < 50 % du capital social** → AGE obligatoire dans les **4 mois**, régularisation sous **2 exercices**.
> 2. **Cessation de paiement** = passif exigible > actif disponible. Déclaration sous **45 jours**.
> 3. **Sauvegarde** = préventif (sans cessation), **RJ** = curatif (avec cessation mais redressable), **LJ** = terminal (irredressable).
> 4. **Période d'observation** : 6 à 18 mois maximum.
> 5. **Plans de sauvegarde / RJ** : 10 ans maximum.
> 6. **Tribunal de commerce** : juges consulaires, **3 minimum** par jugement, mandat **4 ans** bénévole.
> 7. **Compétence territoriale** transport : tribunal du domicile du débiteur.
> 8. **Sanctions personnelles** : faillite personnelle (15 ans), interdiction de gérer (5 ans), banqueroute (5 ans prison + 75 000 €).

---

## 🎓 Ce que l'examinateur peut demander

Questions-types récurrentes :

1. **« Quel est le seuil critique des capitaux propres ? »** → < 50 % du capital social.
2. **« Délai pour déclarer la cessation de paiement ? »** → 45 jours.
3. **« Différence sauvegarde / RJ ? »** → Sauvegarde = sans cessation (préventif). RJ = avec cessation mais redressable.
4. **« Composition du tribunal de commerce ? »** → Juges consulaires, 3 minimum par jugement, mandat 4 ans bénévole.
5. **Cas en QR** : Trésorerie 2 200 € + dettes 30 000 € → cessation de paiement, déclaration sous 45 j, RJ ou LJ selon redressabilité.

---

## 📋 Mémo à imprimer

```
SEUIL CAP PROPRES        → < 50 % capital social
  AGE                    → Sous 4 mois
  RÉGULARISATION         → Sous 2 exercices

CESSATION DE PAIEMENT    → Passif exigible > Actif disponible
  DÉCLARATION            → Sous 45 jours
  SANCTIONS              → Faillite perso (15 ans), interdiction (5 ans),
                          banqueroute (5 ans + 75 K€)

3 PROCÉDURES
  SAUVEGARDE             → Préventif (sans cessation)
  REDRESSEMENT (RJ)      → Curatif (cessation + redressable)
  LIQUIDATION (LJ)       → Terminal (irredressable)

PÉRIODE D'OBSERVATION    → 6 à 18 mois max
PLAN                     → 10 ans max

TRIBUNAL DE COMMERCE
  Juges consulaires      → Commerçants élus, bénévoles, mandat 4 ans
  Min. par jugement      → 3 juges
  Compétence territoriale → Domicile du débiteur

VOIES DE RECOURS
  ≤ 5 000 €              → Dernier ressort (pas d'appel)
  > 5 000 €              → Appel sous 1 mois
```
$lesson5$,
'Identifier le seuil d''alerte des capitaux propres, distinguer sauvegarde / redressement / liquidation, déclarer la cessation de paiement dans les 45 jours et connaître les juridictions.'
  ) RETURNING id INTO v_lesson_5;

  -- =================================================================
  -- BANQUE DE QCM REFORMULÉS — Module A (60 questions, 12 par leçon)
  -- source_ref : mft-2026:moduleA:qcm:N
  -- Niveaux : facile / moyen / difficile (équilibré)
  -- =================================================================

  -- ───────────── LEÇON 1 — Cadre juridique des personnes (12 QCM) ─────────────

  -- QCM 1 — Personnalité morale (LEÇON 1) — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'À partir de quel moment une société (SAS, SARL, EURL...) acquiert-elle la personnalité morale ?',
    '[
      {"id":"a","label":"À la signature des statuts par les associés","is_correct":false},
      {"id":"b","label":"À la publication de l''annonce légale","is_correct":false},
      {"id":"c","label":"À l''immatriculation au Registre du commerce et des sociétés (RCS)","is_correct":true},
      {"id":"d","label":"Au démarrage effectif de l''activité commerciale","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','lecon-1','personnalite-juridique'],
    'mft-2026:moduleA:qcm:1', true,
    'C''est l''immatriculation au RCS (= délivrance du Kbis) qui crée juridiquement la société. Avant cela, elle est en formation et n''a pas de personnalité morale.');

  -- QCM 2 — Régime matrimonial par défaut — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'En l''absence de contrat de mariage, à quel régime matrimonial les époux sont-ils soumis en France ?',
    '[
      {"id":"a","label":"La séparation de biens","is_correct":false},
      {"id":"b","label":"La communauté universelle","is_correct":false},
      {"id":"c","label":"La communauté réduite aux acquêts","is_correct":true},
      {"id":"d","label":"La participation aux acquêts","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','lecon-1','regime-matrimonial'],
    'mft-2026:moduleA:qcm:2', true,
    'Sans contrat de mariage, c''est la communauté réduite aux acquêts qui s''applique de plein droit (régime légal).');

  -- QCM 3 — Faillite personnelle / interdiction de gérer — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Une interdiction de gérer prononcée par le tribunal de commerce peut être prononcée pour une durée maximale de :',
    '[
      {"id":"a","label":"3 ans","is_correct":false},
      {"id":"b","label":"5 ans","is_correct":true},
      {"id":"c","label":"10 ans","is_correct":false},
      {"id":"d","label":"15 ans","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-1','faillite'],
    'mft-2026:moduleA:qcm:3', true,
    'L''interdiction de gérer seule est limitée à 5 ans. À ne pas confondre avec la faillite personnelle qui peut atteindre 15 ans.');

  -- QCM 4 — Personne morale droit privé — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Une SARL de transport routier est juridiquement :',
    '[
      {"id":"a","label":"Une personne physique","is_correct":false},
      {"id":"b","label":"Une personne morale de droit public","is_correct":false},
      {"id":"c","label":"Une personne morale de droit privé","is_correct":true},
      {"id":"d","label":"Une administration commerciale","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','lecon-1','personnalite-juridique'],
    'mft-2026:moduleA:qcm:4', true,
    'Toute société commerciale (SARL, SAS, EURL...) est une personne morale de droit privé.');

  -- QCM 5 — Capacité de jouissance vs exercice — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Un mineur non émancipé possède :',
    '[
      {"id":"a","label":"La capacité de jouissance ET la capacité d''exercice","is_correct":false},
      {"id":"b","label":"La capacité de jouissance, mais pas la capacité d''exercice","is_correct":true},
      {"id":"c","label":"La capacité d''exercice, mais pas la capacité de jouissance","is_correct":false},
      {"id":"d","label":"Aucune des deux","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-1','capacite'],
    'mft-2026:moduleA:qcm:5', true,
    'Le mineur a la capacité de jouissance (il possède des droits), mais pas la capacité d''exercice (il ne peut les exercer seul). Il est représenté par ses parents.');

  -- QCM 6 — Incompatibilités — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Parmi les professions suivantes, laquelle EST compatible avec une activité commerciale en transport ?',
    '[
      {"id":"a","label":"Notaire","is_correct":false},
      {"id":"b","label":"Avocat","is_correct":false},
      {"id":"c","label":"Expert-comptable en exercice","is_correct":false},
      {"id":"d","label":"Cadre du privé en CDI","is_correct":true}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-1','incompatibilites'],
    'mft-2026:moduleA:qcm:6', true,
    'Un cadre du privé peut exercer une activité commerciale annexe (auto-entrepreneur ou autre forme), avec simple information de l''employeur. Notaires, avocats et experts-comptables sont juridiquement incompatibles.');

  -- QCM 7 — Patrimoine EI nouvelle formule — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Depuis le 15 mai 2022, l''entrepreneur individuel (EI) bénéficie automatiquement de :',
    '[
      {"id":"a","label":"Une exonération totale d''impôt sur les sociétés","is_correct":false},
      {"id":"b","label":"Une séparation entre patrimoine personnel et patrimoine professionnel","is_correct":true},
      {"id":"c","label":"Une garantie financière de la BPI","is_correct":false},
      {"id":"d","label":"Une exonération des cotisations URSSAF la première année","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-1','ei','patrimoine'],
    'mft-2026:moduleA:qcm:7', true,
    'Depuis le 15 mai 2022, le statut unique de l''EI sépare automatiquement le patrimoine pro (saisissable) du patrimoine perso (protégé), sans déclaration EIRL. L''EIRL a été supprimée.');

  -- QCM 8 — Article 1415 Code civil — difficile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'En vertu de l''article 1415 du Code civil, lorsqu''un époux marié sous communauté légale se porte caution, sans le consentement exprès du conjoint, l''engagement portera uniquement sur :',
    '[
      {"id":"a","label":"Les biens propres et les revenus du signataire","is_correct":true},
      {"id":"b","label":"Tous les biens du couple","is_correct":false},
      {"id":"c","label":"Les biens communs uniquement","is_correct":false},
      {"id":"d","label":"Aucun bien (la caution est nulle)","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-a','capa-3-5t','lecon-1','caution','article-1415'],
    'mft-2026:moduleA:qcm:8', true,
    'L''article 1415 limite l''engagement aux biens propres + revenus du signataire si le conjoint n''a pas donné son consentement exprès. C''est une protection pour le conjoint.');

  -- QCM 9 — Émancipation mineur — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Pour qu''un mineur de 17 ans puisse créer son entreprise de transport, il doit obtenir :',
    '[
      {"id":"a","label":"Une simple autorisation de ses parents","is_correct":false},
      {"id":"b","label":"Un accord du tribunal de commerce","is_correct":false},
      {"id":"c","label":"Une émancipation prononcée par le juge des tutelles","is_correct":true},
      {"id":"d","label":"Une dérogation préfectorale","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','lecon-1','mineur','emancipation'],
    'mft-2026:moduleA:qcm:9', true,
    'L''émancipation est prononcée par le juge des tutelles (au tribunal judiciaire) à la demande des parents ou du mineur lui-même.');

  -- QCM 10 — Fichier interdits de gérer — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Depuis 2016, le Fichier national des interdits de gérer est tenu par :',
    '[
      {"id":"a","label":"L''INSEE","is_correct":false},
      {"id":"b","label":"L''URSSAF","is_correct":false},
      {"id":"c","label":"Le Conseil National des Greffiers des Tribunaux de Commerce (CNGTC)","is_correct":true},
      {"id":"d","label":"La Banque de France","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','lecon-1','interdits-gerer'],
    'mft-2026:moduleA:qcm:10', true,
    'Le CNGTC centralise depuis 2016 toutes les interdictions de gérer et faillites personnelles. Consultable par les greffes lors des immatriculations.');

  -- QCM 11 — Personne morale droit public — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Parmi les structures suivantes, laquelle est une personne morale de droit PUBLIC ?',
    '[
      {"id":"a","label":"Une SARL familiale","is_correct":false},
      {"id":"b","label":"Une commune","is_correct":true},
      {"id":"c","label":"Une association loi 1901","is_correct":false},
      {"id":"d","label":"Un syndicat professionnel","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-1','personnalite-juridique'],
    'mft-2026:moduleA:qcm:11', true,
    'Les communes, l''État, les départements, les régions, les hôpitaux publics sont des personnes morales de droit public. Les associations, syndicats et sociétés sont de droit privé.');

  -- QCM 12 — Régime de séparation de biens — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Le principal avantage du régime de séparation de biens pour un futur transporteur est :',
    '[
      {"id":"a","label":"De réduire les cotisations URSSAF du gérant","is_correct":false},
      {"id":"b","label":"De protéger le patrimoine du conjoint des dettes professionnelles","is_correct":true},
      {"id":"c","label":"D''augmenter le capital de la société","is_correct":false},
      {"id":"d","label":"De diminuer l''impôt sur les sociétés","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-1','regime-matrimonial'],
    'mft-2026:moduleA:qcm:12', true,
    'En séparation de biens, chaque époux conserve son patrimoine propre. Les créanciers du gérant ne peuvent pas saisir les biens du conjoint (sauf caution cosignée).');

  -- ───────────── LEÇON 2 — Création d'entreprise (12 QCM) ─────────────

  -- QCM 13 — Capital SAS — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Quel est le capital social minimum exigé pour créer une SASU ou une SAS ?',
    '[
      {"id":"a","label":"1 €","is_correct":true},
      {"id":"b","label":"500 €","is_correct":false},
      {"id":"c","label":"7 500 €","is_correct":false},
      {"id":"d","label":"37 000 €","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','lecon-2','sasu','capital'],
    'mft-2026:moduleA:qcm:13', true,
    'Le capital de SAS et SASU est librement fixé par les actionnaires, avec un minimum symbolique de 1 €. 50 % doivent être libérés à la constitution.');

  -- QCM 14 — Régime social gérant majoritaire SARL — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Quel régime social s''applique à un gérant de SARL détenant 51 % des parts sociales ?',
    '[
      {"id":"a","label":"Le régime général de la Sécurité sociale (assimilé salarié)","is_correct":false},
      {"id":"b","label":"Le régime des travailleurs non-salariés (TNS)","is_correct":true},
      {"id":"c","label":"Aucun régime particulier","is_correct":false},
      {"id":"d","label":"Le régime des cadres uniquement","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-2','sarl','regime-social'],
    'mft-2026:moduleA:qcm:14', true,
    'Dès que le gérant détient plus de 50 % des parts, il bascule en TNS (cotisations ≈ 45 % du revenu). À 50 % strict ou en dessous, il est assimilé salarié.');

  -- QCM 15 — Régime fiscal SARL par défaut — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Quel régime fiscal s''applique par défaut à une SARL classique ?',
    '[
      {"id":"a","label":"L''impôt sur le revenu (IR)","is_correct":false},
      {"id":"b","label":"L''impôt sur les sociétés (IS)","is_correct":true},
      {"id":"c","label":"La franchise en base de TVA","is_correct":false},
      {"id":"d","label":"L''auto-liquidation","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','lecon-2','sarl','fiscalite'],
    'mft-2026:moduleA:qcm:15', true,
    'La SARL classique est soumise à l''IS de plein droit. L''option pour l''IR est possible uniquement pour les SARL de famille ou les SARL de moins de 5 ans (sous conditions).');

  -- QCM 16 — EI sans personne morale — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Parmi ces structures, laquelle ne possède PAS la personnalité morale ?',
    '[
      {"id":"a","label":"La SARL","is_correct":false},
      {"id":"b","label":"L''entreprise individuelle (EI)","is_correct":true},
      {"id":"c","label":"La SAS","is_correct":false},
      {"id":"d","label":"L''EURL","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','lecon-2','formes-juridiques'],
    'mft-2026:moduleA:qcm:16', true,
    'L''EI est rattachée directement à la personne physique du créateur. Elle ne crée pas de personne morale distincte (contrairement à l''EURL qui en crée une).');

  -- QCM 17 — Désignation gérant SARL — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Dans une SARL, le gérant est nommé par les associés à la majorité représentant :',
    '[
      {"id":"a","label":"L''unanimité des associés","is_correct":false},
      {"id":"b","label":"Au moins un quart des parts sociales","is_correct":false},
      {"id":"c","label":"Plus de la moitié des parts sociales","is_correct":true},
      {"id":"d","label":"Plus des trois quarts des parts sociales","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-2','sarl','gerance'],
    'mft-2026:moduleA:qcm:17', true,
    'C''est la majorité simple en parts sociales (50 % + 1 voix) qui désigne le gérant de SARL, sauf clause contraire des statuts.');

  -- QCM 18 — Président SAS régime social — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Le président d''une SAS est :',
    '[
      {"id":"a","label":"Toujours TNS, comme un gérant majoritaire de SARL","is_correct":false},
      {"id":"b","label":"Toujours assimilé salarié au régime général","is_correct":true},
      {"id":"c","label":"TNS s''il détient plus de 50 % du capital","is_correct":false},
      {"id":"d","label":"Salarié de droit commun avec contrat de travail","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-2','sas','regime-social'],
    'mft-2026:moduleA:qcm:18', true,
    'Quel que soit son niveau de détention, le président de SAS est toujours assimilé salarié (régime général). C''est une différence majeure avec la SARL.');

  -- QCM 19 — Garantie financière LTI — difficile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Quel est le montant de la garantie financière exigée par la DREAL pour le 1er véhicule d''une entreprise de transport léger ?',
    '[
      {"id":"a","label":"900 €","is_correct":false},
      {"id":"b","label":"1 800 €","is_correct":true},
      {"id":"c","label":"5 400 €","is_correct":false},
      {"id":"d","label":"9 000 €","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-a','capa-3-5t','lecon-2','dreal','garantie-financiere'],
    'mft-2026:moduleA:qcm:19', true,
    'La garantie financière en transport léger est de 1 800 € pour le 1er véhicule, puis 900 € par véhicule supplémentaire (à comparer avec les 9 000 €/véhicule en transport > 3,5 t).');

  -- QCM 20 — EIRL disparue — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'L''EIRL (Entrepreneur Individuel à Responsabilité Limitée) :',
    '[
      {"id":"a","label":"Reste la forme la plus courante en transport léger","is_correct":false},
      {"id":"b","label":"A été supprimée et remplacée par le statut unique de l''EI le 15 mai 2022","is_correct":true},
      {"id":"c","label":"Est réservée aux activités libérales","is_correct":false},
      {"id":"d","label":"Nécessite désormais un capital minimal de 5 000 €","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-2','eirl','ei'],
    'mft-2026:moduleA:qcm:20', true,
    'L''EIRL a disparu le 15 mai 2022. Le nouveau statut unique de l''EI offre automatiquement la séparation des patrimoines, sans déclaration d''affectation.');

  -- QCM 21 — Auto-entrepreneur seuil CA — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Le régime micro-entrepreneur (auto-entrepreneur) en transport de marchandises est plafonné à un chiffre d''affaires annuel de :',
    '[
      {"id":"a","label":"36 800 €","is_correct":false},
      {"id":"b","label":"77 700 €","is_correct":true},
      {"id":"c","label":"176 200 €","is_correct":false},
      {"id":"d","label":"247 100 €","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','lecon-2','auto-entrepreneur'],
    'mft-2026:moduleA:qcm:21', true,
    'Le seuil micro pour les prestations de services (transport, BTP, conseil) est de 77 700 € en 2026. Au-dessus, bascule en régime réel.');

  -- QCM 22 — Libération capital SAS — difficile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Lors de la création d''une SAS, à hauteur de quel pourcentage les apports en numéraire doivent-ils être libérés à la constitution ?',
    '[
      {"id":"a","label":"20 %","is_correct":false},
      {"id":"b","label":"50 %","is_correct":true},
      {"id":"c","label":"75 %","is_correct":false},
      {"id":"d","label":"100 %","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-a','capa-3-5t','lecon-2','sas','capital'],
    'mft-2026:moduleA:qcm:22', true,
    'En SAS, 50 % des apports en numéraire doivent être libérés à la constitution. Le solde dans les 5 ans suivant l''immatriculation. (En SARL : 20 % à la constitution.)');

  -- QCM 23 — Cotisations TNS — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Le taux global de cotisations sociales pour un travailleur non-salarié (TNS) en transport est approximativement de :',
    '[
      {"id":"a","label":"15 % du revenu net","is_correct":false},
      {"id":"b","label":"30 % du revenu net","is_correct":false},
      {"id":"c","label":"45 % du revenu net","is_correct":true},
      {"id":"d","label":"80 % du salaire brut","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-2','tns','cotisations'],
    'mft-2026:moduleA:qcm:23', true,
    'Un TNS cotise environ 45 % de son revenu net (URSSAF + SSI). À comparer avec les 80 % d''un assimilé salarié, mais avec une protection sociale moindre.');

  -- QCM 24 — LTI durée — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'La Licence de transport intérieur (LTI) est rattachée à l''entreprise et doit être renouvelée tous les :',
    '[
      {"id":"a","label":"5 ans","is_correct":false},
      {"id":"b","label":"10 ans","is_correct":true},
      {"id":"c","label":"15 ans","is_correct":false},
      {"id":"d","label":"À vie, comme l''attestation de capacité","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-2','lti','dreal'],
    'mft-2026:moduleA:qcm:24', true,
    'La LTI est valable 10 ans, renouvelable. À ne pas confondre avec l''attestation de capacité professionnelle qui est personnelle et valide à vie.');

  -- ───────────── LEÇON 3 — Vendre, facturer, encaissements (12 QCM) ─────────────

  -- QCM 25 — Délai paiement transport — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Quel est le délai légal maximal de paiement entre professionnels en transport routier ?',
    '[
      {"id":"a","label":"30 jours date de facture","is_correct":true},
      {"id":"b","label":"45 jours fin de mois","is_correct":false},
      {"id":"c","label":"60 jours nets","is_correct":false},
      {"id":"d","label":"90 jours fin de mois","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-3','delai-paiement'],
    'mft-2026:moduleA:qcm:25', true,
    'Article L. 441-11 du Code de commerce : règle d''ordre public en transport routier, 30 j max date de facture. Le client ne peut pas imposer 60 j même par contrat.');

  -- QCM 26 — Indemnité forfaitaire LME — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'En cas de retard de paiement entre professionnels, le créancier a droit à une indemnité forfaitaire de :',
    '[
      {"id":"a","label":"15 € HT","is_correct":false},
      {"id":"b","label":"40 € HT","is_correct":true},
      {"id":"c","label":"100 € HT","is_correct":false},
      {"id":"d","label":"5 % du montant impayé","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','lecon-3','lme'],
    'mft-2026:moduleA:qcm:26', true,
    'Indemnité forfaitaire de 40 € HT par facture impayée (article D. 441-5 C. com., issu de la loi LME de 2008). À mentionner obligatoirement en pied de facture.');

  -- QCM 27 — Lettre de change émetteur — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Une lettre de change est émise par :',
    '[
      {"id":"a","label":"Le débiteur (= votre client)","is_correct":false},
      {"id":"b","label":"Le créancier (= vous, le transporteur)","is_correct":true},
      {"id":"c","label":"La banque du débiteur","is_correct":false},
      {"id":"d","label":"Un huissier de justice","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-3','effets-commerce'],
    'mft-2026:moduleA:qcm:27', true,
    'La LC est émise par le créancier (= tireur) qui demande au débiteur (= tiré) de payer à l''échéance. Le BAO, lui, est émis par le débiteur en faveur du créancier.');

  -- QCM 28 — Billet à ordre émetteur — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Un billet à ordre est émis par :',
    '[
      {"id":"a","label":"Le débiteur (= votre client)","is_correct":true},
      {"id":"b","label":"Le créancier (= vous, le transporteur)","is_correct":false},
      {"id":"c","label":"Toute partie au contrat de transport","is_correct":false},
      {"id":"d","label":"La DREAL","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-3','effets-commerce'],
    'mft-2026:moduleA:qcm:28', true,
    'Le BAO est souscrit par le débiteur en faveur du créancier. C''est l''inverse de la LC qui est tirée par le créancier sur le débiteur.');

  -- QCM 29 — Escompte définition — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'L''escompte bancaire d''une lettre de change permet :',
    '[
      {"id":"a","label":"D''obtenir le paiement immédiat moins les agios","is_correct":true},
      {"id":"b","label":"D''annuler le délai de paiement contractuel","is_correct":false},
      {"id":"c","label":"De saisir le compte du débiteur sans procédure","is_correct":false},
      {"id":"d","label":"De réduire la TVA de 20 % à 10 %","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','lecon-3','escompte'],
    'mft-2026:moduleA:qcm:29', true,
    'L''escompte transforme une LC en cash immédiat : la banque verse le montant moins les agios (~ 0,5 % pour 60 jours) et se charge du recouvrement à l''échéance.');

  -- QCM 30 — Mentions facture — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Combien de mentions obligatoires doit comporter une facture entre professionnels ?',
    '[
      {"id":"a","label":"7","is_correct":false},
      {"id":"b","label":"10","is_correct":false},
      {"id":"c","label":"14","is_correct":true},
      {"id":"d","label":"21","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-3','facturation'],
    'mft-2026:moduleA:qcm:30', true,
    '14 mentions obligatoires (article L. 441-9 C. com.) : identités, SIRET, TVA, désignation, prix, dates, conditions de paiement, pénalités, indemnité forfaitaire 40 €.');

  -- QCM 31 — TVA standard transport — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Le taux normal de TVA applicable à la prestation de transport de marchandises en France est de :',
    '[
      {"id":"a","label":"5,5 %","is_correct":false},
      {"id":"b","label":"10 %","is_correct":false},
      {"id":"c","label":"20 %","is_correct":true},
      {"id":"d","label":"22 %","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','lecon-3','tva'],
    'mft-2026:moduleA:qcm:31', true,
    'Le transport de marchandises en France est soumis à la TVA standard de 20 %. Le taux 10 % concerne certains transports de personnes (taxis, navettes).');

  -- QCM 32 — Espèces plafond pro — difficile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Le paiement en espèces entre professionnels en France est plafonné à :',
    '[
      {"id":"a","label":"500 €","is_correct":false},
      {"id":"b","label":"1 000 €","is_correct":true},
      {"id":"c","label":"3 000 €","is_correct":false},
      {"id":"d","label":"15 000 €","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-a','capa-3-5t','lecon-3','especes'],
    'mft-2026:moduleA:qcm:32', true,
    'Plafond de 1 000 € entre professionnels et entre professionnel et particulier français. Le seuil de 15 000 € s''applique uniquement aux touristes étrangers.');

  -- QCM 33 — Mentions LME pénalités — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Le taux minimal légal des pénalités de retard sur une facture impayée est :',
    '[
      {"id":"a","label":"Le taux d''intérêt légal simple","is_correct":false},
      {"id":"b","label":"3 fois le taux d''intérêt légal","is_correct":true},
      {"id":"c","label":"Le taux directeur de la BCE","is_correct":false},
      {"id":"d","label":"5 % par mois","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-3','penalites'],
    'mft-2026:moduleA:qcm:33', true,
    '3 × le taux d''intérêt légal au minimum (~ 11 % en 2026) ou taux BCE + 10 points (~ 14 %). Le créancier choisit l''une de ces deux bases.');

  -- QCM 34 — Affacturage — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'L''affacturage permet à l''entreprise :',
    '[
      {"id":"a","label":"De ne pas payer la TVA sur ses factures","is_correct":false},
      {"id":"b","label":"De céder régulièrement ses factures à un factor pour obtenir du cash immédiat","is_correct":true},
      {"id":"c","label":"D''ouvrir un compte bancaire à l''étranger","is_correct":false},
      {"id":"d","label":"De prolonger automatiquement les délais de paiement","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-3','affacturage'],
    'mft-2026:moduleA:qcm:34', true,
    'L''affacturage = cession régulière des factures à un factor moyennant ~ 1 à 3 % de commission. Bénéfice : cash immédiat + garantie d''impayé + délégation du recouvrement.');

  -- QCM 35 — LCR dématérialisée — difficile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'La LCR (Lettre de Change Relevé) est :',
    '[
      {"id":"a","label":"Une LC dématérialisée traitée informatiquement par les banques","is_correct":true},
      {"id":"b","label":"Une lettre de change émise par lettre recommandée","is_correct":false},
      {"id":"c","label":"Une lettre de change garantie par l''État","is_correct":false},
      {"id":"d","label":"Une lettre de change pour les transports internationaux","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-a','capa-3-5t','lecon-3','lcr'],
    'mft-2026:moduleA:qcm:35', true,
    'La LCR (et son équivalent BOR pour le billet à ordre) est une version informatisée traitée par compensation interbancaire. Format dominant aujourd''hui en France.');

  -- QCM 36 — Cession Dailly — difficile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'La cession Dailly permet à une entreprise :',
    '[
      {"id":"a","label":"De vendre ses créances commerciales à sa banque comme garantie d''un crédit","is_correct":true},
      {"id":"b","label":"De geler ses dettes pendant 3 mois","is_correct":false},
      {"id":"c","label":"De déclarer une cessation de paiement sans poursuites","is_correct":false},
      {"id":"d","label":"De réduire automatiquement de 50 % ses cotisations URSSAF","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-a','capa-3-5t','lecon-3','dailly'],
    'mft-2026:moduleA:qcm:36', true,
    'La cession Dailly (loi du 2 janvier 1981) permet de céder ses créances pro à la banque comme garantie d''un crédit. Plus souple qu''une LC car pas besoin d''acceptation du débiteur.');

  -- ───────────── LEÇON 4 — Garanties et recouvrement (12 QCM) ─────────────

  -- QCM 37 — Caution simple vs solidaire — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Un créancier peut poursuivre directement la caution sans avoir à poursuivre d''abord le débiteur principal :',
    '[
      {"id":"a","label":"En cas de caution simple","is_correct":false},
      {"id":"b","label":"En cas de caution solidaire","is_correct":true},
      {"id":"c","label":"Toujours, quel que soit le type de caution","is_correct":false},
      {"id":"d","label":"Jamais, il doit toujours commencer par le débiteur","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','lecon-4','caution'],
    'mft-2026:moduleA:qcm:37', true,
    'Caution simple = bénéfice de discussion (poursuivre d''abord le débiteur). Caution solidaire = recours direct sur la caution. Toujours exiger « solidaire » dans un contrat.');

  -- QCM 38 — Hypothèque — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'L''hypothèque est une sûreté qui porte sur :',
    '[
      {"id":"a","label":"Les parts sociales d''une SARL","is_correct":false},
      {"id":"b","label":"Un véhicule utilitaire léger","is_correct":false},
      {"id":"c","label":"Un bien immobilier","is_correct":true},
      {"id":"d","label":"Un compte bancaire","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','lecon-4','hypotheque'],
    'mft-2026:moduleA:qcm:38', true,
    'L''hypothèque concerne uniquement l''immobilier. Pour les meubles corporels (camion) → gage. Pour les meubles incorporels (parts, fonds) → nantissement.');

  -- QCM 39 — Nantissement — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Pour grever un fonds de commerce en garantie d''un crédit, on utilise :',
    '[
      {"id":"a","label":"Un gage","is_correct":false},
      {"id":"b","label":"Une hypothèque","is_correct":false},
      {"id":"c","label":"Un nantissement","is_correct":true},
      {"id":"d","label":"Une caution","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-4','nantissement'],
    'mft-2026:moduleA:qcm:39', true,
    'Le nantissement vise les biens incorporels : parts sociales, créances, et fonds de commerce. Pour un véhicule (corporel) on parle de gage. Pour un immeuble, d''hypothèque.');

  -- QCM 40 — Mise en demeure — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'La mise en demeure de payer doit être envoyée par :',
    '[
      {"id":"a","label":"Email simple","is_correct":false},
      {"id":"b","label":"Lettre simple","is_correct":false},
      {"id":"c","label":"Lettre recommandée avec accusé de réception (LRAR)","is_correct":true},
      {"id":"d","label":"Huissier de justice obligatoirement","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','lecon-4','mise-en-demeure'],
    'mft-2026:moduleA:qcm:40', true,
    'LRAR : preuve de l''envoi, fait courir les intérêts de retard, prépare une procédure judiciaire. Sans LRAR préalable, le tribunal peut juger la procédure prématurée.');

  -- QCM 41 — Injonction de payer avocat — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Pour engager une procédure d''injonction de payer auprès du tribunal de commerce, l''assistance d''un avocat est :',
    '[
      {"id":"a","label":"Obligatoire en toutes circonstances","is_correct":false},
      {"id":"b","label":"Non obligatoire","is_correct":true},
      {"id":"c","label":"Obligatoire uniquement au-dessus de 10 000 €","is_correct":false},
      {"id":"d","label":"Obligatoire pour les SAS uniquement","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-4','injonction-payer'],
    'mft-2026:moduleA:qcm:41', true,
    'L''injonction de payer (article 1405 CPC) est une procédure simplifiée : avocat non obligatoire, ~ 40 € de frais de greffe. C''est l''outil idéal pour les transporteurs.');

  -- QCM 42 — Tribunal compétent recouvrement — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Pour recouvrer une créance commerciale auprès d''un client, le tribunal de commerce compétent est celui :',
    '[
      {"id":"a","label":"Du siège social du créancier","is_correct":false},
      {"id":"b","label":"Du domicile (siège) du débiteur","is_correct":true},
      {"id":"c","label":"Du lieu de la livraison","is_correct":false},
      {"id":"d","label":"Du lieu de signature du contrat","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-4','tribunal'],
    'mft-2026:moduleA:qcm:42', true,
    'Règle générale en matière commerciale : compétence territoriale du tribunal du domicile du débiteur. C''est lui qui sera convoqué et doit pouvoir se défendre près de chez lui.');

  -- QCM 43 — Prescription transport — difficile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Le délai de prescription d''une créance de transport routier de marchandises est de :',
    '[
      {"id":"a","label":"6 mois","is_correct":false},
      {"id":"b","label":"1 an","is_correct":true},
      {"id":"c","label":"2 ans","is_correct":false},
      {"id":"d","label":"5 ans","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-a','capa-3-5t','lecon-4','prescription'],
    'mft-2026:moduleA:qcm:43', true,
    'Article L. 133-6 C. com. : prescription d''1 AN à compter de la livraison. Règle SPÉCIALE plus courte que les 5 ans de droit commun. À ne surtout pas oublier !');

  -- QCM 44 — Article 1415 conjoint — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Pour qu''un dirigeant marié sous communauté légale puisse engager les biens communs en se portant caution, il doit obtenir :',
    '[
      {"id":"a","label":"Un accord verbal de son conjoint","is_correct":false},
      {"id":"b","label":"Un consentement exprès écrit du conjoint","is_correct":true},
      {"id":"c","label":"Une autorisation du tribunal","is_correct":false},
      {"id":"d","label":"Aucune formalité particulière","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-4','caution','article-1415'],
    'mft-2026:moduleA:qcm:44', true,
    'L''article 1415 du Code civil exige le consentement exprès écrit du conjoint pour engager les biens communs. Sans cette signature, la caution n''engage que les biens propres et revenus du signataire.');

  -- QCM 45 — Voies de recours seuil — difficile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Au-dessus de quel seuil une décision du tribunal de commerce est-elle susceptible d''appel ?',
    '[
      {"id":"a","label":"1 000 €","is_correct":false},
      {"id":"b","label":"5 000 €","is_correct":true},
      {"id":"c","label":"10 000 €","is_correct":false},
      {"id":"d","label":"30 000 €","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-a','capa-3-5t','lecon-4','recours'],
    'mft-2026:moduleA:qcm:45', true,
    'Au-dessus de 5 000 €, l''appel est ouvert (devant la Cour d''appel) dans le mois suivant la signification. En dessous, jugement en dernier ressort, seul un pourvoi en cassation sur question de droit est possible.');

  -- QCM 46 — Gage corporel — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Pour grever un véhicule utilitaire en garantie d''un prêt classique, on inscrit :',
    '[
      {"id":"a","label":"Une hypothèque","is_correct":false},
      {"id":"b","label":"Un nantissement","is_correct":false},
      {"id":"c","label":"Un gage","is_correct":true},
      {"id":"d","label":"Une caution","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','lecon-4','gage'],
    'mft-2026:moduleA:qcm:46', true,
    'Le gage porte sur un bien meuble corporel (camion, machine, matériel). Inscription au registre des gages tenu par le greffe du tribunal de commerce.');

  -- QCM 47 — Délai opposition injonction — difficile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Après la signification d''une ordonnance d''injonction de payer, le débiteur dispose pour faire opposition d''un délai de :',
    '[
      {"id":"a","label":"8 jours","is_correct":false},
      {"id":"b","label":"15 jours","is_correct":false},
      {"id":"c","label":"1 mois","is_correct":true},
      {"id":"d","label":"3 mois","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-a','capa-3-5t','lecon-4','injonction-payer'],
    'mft-2026:moduleA:qcm:47', true,
    'Le débiteur a 1 mois après la signification par huissier pour faire opposition. À défaut, l''ordonnance devient titre exécutoire : saisie possible.');

  -- QCM 48 — Indemnité forfaitaire 40 — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'L''indemnité forfaitaire de 40 € HT pour frais de recouvrement :',
    '[
      {"id":"a","label":"Doit être négociée avec le client","is_correct":false},
      {"id":"b","label":"Est due automatiquement par tout débiteur professionnel en retard","is_correct":true},
      {"id":"c","label":"S''applique uniquement aux clients particuliers","is_correct":false},
      {"id":"d","label":"Remplace les pénalités de retard","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-4','lme'],
    'mft-2026:moduleA:qcm:48', true,
    'Article D. 441-5 C. com. : 40 € HT dus automatiquement en cas de retard, S''AJOUTENT aux pénalités de retard. Mention obligatoire en pied de facture.');

  -- ───────────── LEÇON 5 — Difficultés et juridictions (12 QCM) ─────────────

  -- QCM 49 — Cessation de paiement déf. — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Comment se définit juridiquement la cessation de paiement d''une société commerciale ?',
    '[
      {"id":"a","label":"L''impossibilité de faire face au passif exigible avec son actif disponible","is_correct":true},
      {"id":"b","label":"La perte de la moitié du capital social","is_correct":false},
      {"id":"c","label":"Une infraction pénale imputable au dirigeant","is_correct":false},
      {"id":"d","label":"Une comptabilité non conforme","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-5','cessation-paiement'],
    'mft-2026:moduleA:qcm:49', true,
    'Définition légale (article L. 631-1 C. com.). Le dirigeant doit déclarer cette cessation au tribunal dans les 45 jours. Confondre avec la perte de capitaux propres est une erreur fréquente.');

  -- QCM 50 — Délai déclaration cessation — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Quel est le délai légal pour déclarer la cessation de paiement au tribunal ?',
    '[
      {"id":"a","label":"15 jours","is_correct":false},
      {"id":"b","label":"30 jours","is_correct":false},
      {"id":"c","label":"45 jours","is_correct":true},
      {"id":"d","label":"60 jours","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','lecon-5','cessation-paiement'],
    'mft-2026:moduleA:qcm:50', true,
    '45 jours depuis le constat de la cessation. Au-delà, sanctions personnelles : faillite personnelle (15 ans), interdiction de gérer (5 ans), responsabilité civile pour insuffisance d''actif.');

  -- QCM 51 — Sauvegarde — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'La procédure de sauvegarde concerne une entreprise qui :',
    '[
      {"id":"a","label":"Est déjà en cessation de paiement","is_correct":false},
      {"id":"b","label":"Rencontre des difficultés mais N''est PAS encore en cessation de paiement","is_correct":true},
      {"id":"c","label":"A déposé son bilan","is_correct":false},
      {"id":"d","label":"A perdu plus de 50 % de son capital","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-5','sauvegarde'],
    'mft-2026:moduleA:qcm:51', true,
    'La sauvegarde est PRÉVENTIVE : elle protège une entreprise en difficulté MAIS pas encore en cessation. Si cessation, la procédure est le redressement judiciaire (RJ).');

  -- QCM 52 — Liquidation — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'La liquidation judiciaire est ouverte lorsque :',
    '[
      {"id":"a","label":"L''entreprise rencontre quelques retards de paiement","is_correct":false},
      {"id":"b","label":"L''entreprise est en cessation de paiement et son redressement est manifestement impossible","is_correct":true},
      {"id":"c","label":"Le commissaire aux comptes émet une réserve","is_correct":false},
      {"id":"d","label":"Les associés en font la demande pour des raisons stratégiques","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','lecon-5','liquidation'],
    'mft-2026:moduleA:qcm:52', true,
    'La liquidation judiciaire est ouverte quand la cessation de paiement est avérée ET le redressement manifestement impossible. Mission du liquidateur : réaliser l''actif, payer les créanciers selon ordre des privilèges.');

  -- QCM 53 — Capitaux propres — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'À partir de quel seuil les pertes successives obligent les associés à statuer sur la dissolution ?',
    '[
      {"id":"a","label":"Quand les capitaux propres deviennent inférieurs au quart du capital social","is_correct":false},
      {"id":"b","label":"Quand les capitaux propres deviennent inférieurs à la moitié du capital social","is_correct":true},
      {"id":"c","label":"Quand les capitaux propres deviennent inférieurs à 10 000 €","is_correct":false},
      {"id":"d","label":"Quand le résultat de l''exercice est négatif","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-5','capitaux-propres'],
    'mft-2026:moduleA:qcm:53', true,
    'Seuil critique : capitaux propres < 50 % du capital social. AGE obligatoire dans les 4 mois, régularisation sous 2 exercices. À défaut, dissolution judiciaire possible.');

  -- QCM 54 — Délai régularisation — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Lorsque les capitaux propres descendent sous la moitié du capital social, les associés doivent :',
    '[
      {"id":"a","label":"Réunir une AGE dans les 4 mois et régulariser sous 2 exercices","is_correct":true},
      {"id":"b","label":"Déclarer immédiatement la cessation de paiement","is_correct":false},
      {"id":"c","label":"Vendre la moitié des parts à un tiers","is_correct":false},
      {"id":"d","label":"Augmenter le capital de 100 % obligatoirement","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-5','capitaux-propres'],
    'mft-2026:moduleA:qcm:54', true,
    'AGE dans les 4 mois pour décider dissolution ou poursuite. Si poursuite, régularisation sous 2 exercices (recapitalisation, abandon de créance d''associé, augmentation de capital).');

  -- QCM 55 — Tribunal commerce composition — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Le tribunal de commerce est composé de :',
    '[
      {"id":"a","label":"Magistrats professionnels rémunérés","is_correct":false},
      {"id":"b","label":"Juges consulaires (commerçants élus, bénévoles)","is_correct":true},
      {"id":"c","label":"Avocats désignés par leur barreau","is_correct":false},
      {"id":"d","label":"Juges désignés par le préfet","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','lecon-5','tribunal-commerce'],
    'mft-2026:moduleA:qcm:55', true,
    'Juges consulaires = commerçants élus par le collège des commerçants (CCI, syndicats). Mandat 4 ans, bénévoles. 3 juges minimum par jugement.');

  -- QCM 56 — Banqueroute — difficile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Le délit de banqueroute est puni d''une peine maximale de :',
    '[
      {"id":"a","label":"6 mois de prison + 30 000 € d''amende","is_correct":false},
      {"id":"b","label":"2 ans de prison + 50 000 € d''amende","is_correct":false},
      {"id":"c","label":"5 ans de prison + 75 000 € d''amende","is_correct":true},
      {"id":"d","label":"10 ans de prison + 150 000 € d''amende","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-a','capa-3-5t','lecon-5','banqueroute'],
    'mft-2026:moduleA:qcm:56', true,
    'Article L. 654-1 C. com. : 5 ans de prison + 75 000 € d''amende. Sanctionne notamment le détournement d''actif, la comptabilité fictive, ou la disparition de pièces.');

  -- QCM 57 — Plan redressement durée — difficile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'La durée maximale d''un plan de redressement adopté par le tribunal de commerce est de :',
    '[
      {"id":"a","label":"3 ans","is_correct":false},
      {"id":"b","label":"5 ans","is_correct":false},
      {"id":"c","label":"10 ans","is_correct":true},
      {"id":"d","label":"15 ans","is_correct":false}
    ]'::jsonb,
    1, 'difficile',
    ARRAY['module-a','capa-3-5t','lecon-5','plan-redressement'],
    'mft-2026:moduleA:qcm:57', true,
    '10 ans maximum pour un plan de redressement ou de sauvegarde, sauf agriculteurs (15 ans). Au-delà : refus du plan et bascule en liquidation.');

  -- QCM 58 — Période observation — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'La période d''observation d''un redressement judiciaire est, au maximum, de :',
    '[
      {"id":"a","label":"3 mois","is_correct":false},
      {"id":"b","label":"6 mois","is_correct":false},
      {"id":"c","label":"12 mois","is_correct":false},
      {"id":"d","label":"18 mois","is_correct":true}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-5','periode-observation'],
    'mft-2026:moduleA:qcm:58', true,
    'Période d''observation = 6 mois renouvelable, dans la limite de 18 mois maximum. Pendant cette période, le passif est gelé, l''entreprise continue son activité sous contrôle.');

  -- QCM 59 — Tribunal compétent transport — moyen
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'Pour un litige entre une SARL de transport et un commerçant client, la juridiction compétente est :',
    '[
      {"id":"a","label":"Le tribunal judiciaire","is_correct":false},
      {"id":"b","label":"Le conseil de prud''hommes","is_correct":false},
      {"id":"c","label":"Le tribunal de commerce","is_correct":true},
      {"id":"d","label":"La cour d''appel","is_correct":false}
    ]'::jsonb,
    1, 'moyen',
    ARRAY['module-a','capa-3-5t','lecon-5','tribunal'],
    'mft-2026:moduleA:qcm:59', true,
    'Le tribunal de commerce est compétent pour les litiges entre commerçants. Le tribunal judiciaire concerne les particuliers et les professions libérales. Le conseil de prud''hommes les litiges salarié-employeur.');

  -- QCM 60 — Faillite personnelle durée — facile
  INSERT INTO public.question_bank
    (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, 'qcm',
    'La faillite personnelle peut être prononcée pour une durée maximale de :',
    '[
      {"id":"a","label":"5 ans","is_correct":false},
      {"id":"b","label":"10 ans","is_correct":false},
      {"id":"c","label":"15 ans","is_correct":true},
      {"id":"d","label":"À vie","is_correct":false}
    ]'::jsonb,
    1, 'facile',
    ARRAY['module-a','capa-3-5t','lecon-5','faillite'],
    'mft-2026:moduleA:qcm:60', true,
    'Maximum 15 ans. Sanction réservée aux fautes lourdes (détournement, comptabilité frauduleuse, poursuite abusive d''activité déficitaire). À ne pas confondre avec l''interdiction de gérer (5 ans max).');

  -- =================================================================
  -- BANQUE DE QR — Module A : SUPPRIMÉE selon décision client (mai 2026)
  -- Le module A se concentre uniquement sur les QCM (60 QCM, 5 leçons).
  -- Les QR ont été redistribuées vers les modules D et E où elles
  -- ont plus de pertinence (calculs financiers, droit social).
  -- =================================================================

  -- =================================================================
  -- QUIZZES par leçon — chacun 12 QCM + lien vers la banque
  -- =================================================================

  -- Quiz Leçon 1 — Cadre juridique des personnes (12 QCM)
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Cadre juridique des personnes — Quiz',
          'Quiz d''entraînement (12 questions) sur la personnalité juridique, les régimes matrimoniaux, la capacité commerciale et les incompatibilités.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleA:qcm:1', 'mft-2026:moduleA:qcm:2', 'mft-2026:moduleA:qcm:3',
      'mft-2026:moduleA:qcm:4', 'mft-2026:moduleA:qcm:5', 'mft-2026:moduleA:qcm:6',
      'mft-2026:moduleA:qcm:7', 'mft-2026:moduleA:qcm:8', 'mft-2026:moduleA:qcm:9',
      'mft-2026:moduleA:qcm:10', 'mft-2026:moduleA:qcm:11', 'mft-2026:moduleA:qcm:12'
    );

  -- Quiz Leçon 2 — Création d'entreprise (12 QCM)
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Création d''entreprise et formes juridiques — Quiz',
          'Quiz d''entraînement (12 questions) sur les 5 formes juridiques (EI, EURL, SARL, SASU, SAS), régimes social et fiscal, obligations DREAL.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleA:qcm:13', 'mft-2026:moduleA:qcm:14', 'mft-2026:moduleA:qcm:15',
      'mft-2026:moduleA:qcm:16', 'mft-2026:moduleA:qcm:17', 'mft-2026:moduleA:qcm:18',
      'mft-2026:moduleA:qcm:19', 'mft-2026:moduleA:qcm:20', 'mft-2026:moduleA:qcm:21',
      'mft-2026:moduleA:qcm:22', 'mft-2026:moduleA:qcm:23', 'mft-2026:moduleA:qcm:24'
    );

  -- Quiz Leçon 3 — Vendre, facturer, encaissements (12 QCM)
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Facturation et effets de commerce — Quiz',
          'Quiz d''entraînement (12 questions) sur les mentions de facture, la lettre de change, le billet à ordre, l''escompte et l''affacturage.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleA:qcm:25', 'mft-2026:moduleA:qcm:26', 'mft-2026:moduleA:qcm:27',
      'mft-2026:moduleA:qcm:28', 'mft-2026:moduleA:qcm:29', 'mft-2026:moduleA:qcm:30',
      'mft-2026:moduleA:qcm:31', 'mft-2026:moduleA:qcm:32', 'mft-2026:moduleA:qcm:33',
      'mft-2026:moduleA:qcm:34', 'mft-2026:moduleA:qcm:35', 'mft-2026:moduleA:qcm:36'
    );

  -- Quiz Leçon 4 — Garanties et recouvrement (12 QCM)
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Garanties et recouvrement — Quiz',
          'Quiz d''entraînement (12 questions) sur les sûretés (caution, gage, nantissement, hypothèque), la mise en demeure et l''injonction de payer.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleA:qcm:37', 'mft-2026:moduleA:qcm:38', 'mft-2026:moduleA:qcm:39',
      'mft-2026:moduleA:qcm:40', 'mft-2026:moduleA:qcm:41', 'mft-2026:moduleA:qcm:42',
      'mft-2026:moduleA:qcm:43', 'mft-2026:moduleA:qcm:44', 'mft-2026:moduleA:qcm:45',
      'mft-2026:moduleA:qcm:46', 'mft-2026:moduleA:qcm:47', 'mft-2026:moduleA:qcm:48'
    );

  -- Quiz Leçon 5 — SUPPRIMÉ selon décision client (mai 2026).
  -- Les 12 QCM de la leçon 5 (procédures collectives) restent disponibles
  -- dans la banque de questions et sont mobilisés dans l'examen blanc.

  -- =================================================================
  -- EXAMEN BLANC Module A — 14 QCM (conditions examen national)
  -- 14 QCM en 60 min, seuil 50 %
  -- =================================================================
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold, is_mock_exam)
  VALUES (v_module, 'Examen blanc — Module A',
          'Examen blanc reproduisant les conditions de l''examen national : 14 QCM transversaux couvrant les 5 leçons, durée 60 minutes, seuil 50 %.',
          'examen', 3600, 50, true)
  RETURNING id INTO v_quiz_eb;

  -- 14 QCM tirés des 5 leçons (équilibrage difficulté)
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref IN (
      'mft-2026:moduleA:qcm:1',  'mft-2026:moduleA:qcm:8',  'mft-2026:moduleA:qcm:14',
      'mft-2026:moduleA:qcm:18', 'mft-2026:moduleA:qcm:19', 'mft-2026:moduleA:qcm:25',
      'mft-2026:moduleA:qcm:27', 'mft-2026:moduleA:qcm:32', 'mft-2026:moduleA:qcm:39',
      'mft-2026:moduleA:qcm:43', 'mft-2026:moduleA:qcm:47', 'mft-2026:moduleA:qcm:49',
      'mft-2026:moduleA:qcm:55', 'mft-2026:moduleA:qcm:57'
    );

  -- QR retirées de l'examen blanc (décision client mai 2026)

  RAISE NOTICE '✅ Module A v3 chargé : 5 leçons, 60 QCM, 0 QR, 5 quizzes (4 entraînement + 1 examen blanc 14 QCM).';
END
$module_a_v3$;
