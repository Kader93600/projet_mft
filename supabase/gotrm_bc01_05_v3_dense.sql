-- =====================================================================
-- GOTRM (RNCP 40990) — BC01-05 · Documents de transport et formalités douanières
-- Version 3 (mai 2026) — REFONTE PÉDAGOGIQUE PREMIUM v3_dense
--
-- Bloc 01 : Concevoir, organiser et piloter des opérations de transport.
-- Module 5 sur 10 du BC01.
--
-- Standard v3_dense :
--   ✓ 4 leçons denses (2 000-2 500 mots chacune)
--   ✓ 48 QCM + 8 QR cas pratiques métier
--   ✓ 4 quiz d'entraînement + 1 examen blanc (15 QCM + 5 QR, 60 min, seuil 50 %)
--   ✓ Schémas :::flow / :::timeline (PAS de code blocks)
--   ✓ Cas pratiques chiffrés et destinations réelles
--   ✓ Références conventions internationales (Genève 1956 CMR, Kyoto révisée douane)
--
-- Référentiel RNCP 40990 — compétence visée :
--   « Établir, contrôler et exploiter les documents de transport et
--   les formalités douanières applicables aux opérations nationales et
--   internationales. »
--
-- ▸ 4 leçons (180 min total)
--   1. Documents de transport national — lettre de voiture, BL (45 min)
--   2. Documents de transport international — CMR, BL maritime, AWB (45 min)
--   3. Formalités douanières — DAU, T1/T2, EX/IM (45 min)
--   4. Origine, valeur, INCOTERMS et contrôles (45 min)
--
-- Idempotent. Pré-requis : formation 'gotrm' présente.
-- =====================================================================

DO $bc01_05_v3$
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

  -- ─── Remplacement complet du module BC01-05 (idempotent) ──────────
  DELETE FROM public.modules WHERE slug IN (
    'gotrm-bc01-05-documents-douane',
    'gotrm-bc01-05-documents-douane-v3'
  );

  -- Nettoyage de la banque de questions liées (v2 + v3) pour éviter les doublons
  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND (source_ref LIKE 'mft-2026-gotrm:bc01-05:%'
       OR source_ref LIKE 'mft-2026-gotrm:bc01-05-v3:%');

  INSERT INTO public.modules (
    title, slug, bloc_id, summary, difficulty, duration_min, "order"
  ) VALUES (
    'BC01-05 — Documents de transport et formalités douanières',
    'gotrm-bc01-05-documents-douane',
    v_bloc,
    'Maîtriser les documents de transport (lettre de voiture nationale, CMR, BL maritime, AWB), les régimes douaniers (DAU, T1, T2, EX, IM), les INCOTERMS 2020 (transport, assurance, douane), la valeur en douane et les contrôles pour des opérations nationales et internationales conformes.',
    'intermediaire',
    180,
    50
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 50, true) ON CONFLICT DO NOTHING;

  -- =================================================================
  -- LEÇON 1 — Documents de transport national
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Documents de transport national — lettre de voiture, bordereau, BL',
    'documents-transport-national',
    1, 45,
$lessonG1$
# Documents de transport national — lettre de voiture, bordereau, BL

> 🎯 **Objectifs pédagogiques**
>
> À la fin de cette leçon, vous serez capable de :
>
> - **Identifier** les documents obligatoires d'un transport national de marchandises.
> - **Rédiger** une lettre de voiture nationale conforme (modèle FNTR ou OTRE).
> - **Distinguer** lettre de voiture, bordereau de livraison (BL) et récépissé.
> - **Apposer** des réserves recevables en cas d'avarie ou de manquant.
> - **Sécuriser** la traçabilité avec la signature électronique eIDAS.

---

## Introduction

En transport routier national, **80 % des litiges** sur les avaries trouvent leur origine dans des **documents mal remplis** ou des **réserves mal apposées**. La lettre de voiture, le bordereau de livraison et le récépissé ne sont pas de simples papiers : ce sont vos **preuves juridiques** en cas de conflit, et vos **outils de traçabilité** opérationnelle.

Le **gestionnaire d'opérations** doit savoir lire un document de transport en 30 secondes, repérer les mentions manquantes et imposer la rédaction conforme. C'est aussi lui qui forme les conducteurs aux bonnes pratiques de réserves : la différence entre une indemnité versée et un litige perdu.

Cette leçon vous donne les **modèles standard FNTR/OTRE**, la liste exhaustive des **mentions obligatoires** (article L. 1432-3 C. transports) et les **techniques de réserves** qui résistent en justice.

---

## 1. Vue d'ensemble : les documents du transport national

### 1.1 La trilogie documentaire

Tout transport routier national de marchandises s'appuie sur **3 documents principaux** :

:::flow
1. Récépissé de prise en charge | Preuve d'acceptation par le transporteur
2. Lettre de voiture | Contrat de transport et instructions
3. Bordereau de livraison (BL) | Preuve de remise au destinataire
:::

À ces 3 documents s'ajoutent, selon les cas :
- **Bordereau de suivi des déchets (BSD)** pour le transport de déchets professionnels.
- **Document ADR** (matières dangereuses).
- **Bon de chargement / déchargement** (interne entreprise).
- **Carnet TIR** (transport international hors UE).

### 1.2 La lettre de voiture nationale : pivot du contrat

La **lettre de voiture nationale** est le **contrat de transport matérialisé**. Sans elle, le contrat-type général (décret 99-269) s'applique mais aucun élément spécifique n'est tracé. Elle est imposée par les **modèles standard** publiés par la **FNTR (Fédération Nationale des Transports Routiers)** et l'**OTRE (Organisation des Transporteurs Routiers Européens)**.

**Format** : 4 exemplaires papier de couleurs différentes :
- **Blanc** : conservé par l'expéditeur.
- **Rose** : pour le transporteur (archives entreprise).
- **Vert** : pour le destinataire.
- **Jaune** : archives transporteur (5 ans).

### 1.3 Pourquoi 4 exemplaires ?

Chaque exemplaire a une fonction :
- L'**expéditeur** garde une preuve de remise des marchandises.
- Le **destinataire** signe à l'arrivée et conserve la preuve de réception.
- Le **transporteur** archive deux copies : une pour exploitation, une pour comptabilité/contentieux.

⚠️ **Erreur fréquente** : un transporteur qui ne récupère pas l'exemplaire signé au destinataire perd la preuve de bonne livraison. En cas de contestation, **c'est lui qui supporte la charge de la preuve**.

---

## 2. Les mentions obligatoires de la lettre de voiture

### 2.1 Cadre légal

L'**article L. 1432-3 du Code des transports** fixe les mentions obligatoires d'un document de transport. L'omission peut entraîner :
- L'application du **contrat-type général** (avec ses plafonds plutôt protecteurs du transporteur).
- Une **amende administrative** de 750 à 3 000 € en cas de contrôle DREAL.
- Une **présomption de faute** du transporteur en cas de litige.

### 2.2 Les 11 mentions obligatoires

| N° | Mention | Détail |
|---|---|---|
| 1 | **Date d'émission** | Jour de la prise en charge |
| 2 | **Identité expéditeur** | Raison sociale, adresse, SIRET |
| 3 | **Identité transporteur** | Raison sociale, n° licence, SIRET |
| 4 | **Identité destinataire** | Raison sociale ou nom, adresse complète |
| 5 | **Lieu et date prise en charge** | Adresse précise, heure |
| 6 | **Lieu et date livraison prévues** | Adresse, créneau horaire si engagé |
| 7 | **Désignation marchandise** | Nature, conditionnement, marques |
| 8 | **Nombre de colis** | Palettes, cartons, big bags, etc. |
| 9 | **Poids brut** | En kg |
| 10 | **Prix du transport** | Net HT (rémunération transporteur) |
| 11 | **Instructions particulières** | Hayon, créneau, ATP, ADR |

### 2.3 Mentions complémentaires recommandées

Bien que non obligatoires légalement, ces mentions **renforcent** la valeur juridique du document :
- **Numéro d'immatriculation** du véhicule.
- **Nom du conducteur** + numéro de permis.
- **Volume ou m³** (utile pour les contestations capacité).
- **Valeur déclarée** (si > 14 €/kg et déclaration souhaitée par expéditeur).
- **Référence client** (n° commande interne).

### 2.4 Cas pratique : LV manquante = quel régime ?

**Énoncé** : Le 4 mai 2026, vous transportez 12 palettes de Paris à Bordeaux **sans lettre de voiture émise**. Le destinataire conteste 2 palettes endommagées. Vous facturez 1 850 €.

**Question** : Quel régime juridique s'applique ? Quelle indemnité maximale ?

**Réponse** :
- **Régime** : contrat-type général (décret 99-269) — applicable d'office en l'absence de document écrit.
- **Plafond** : 14 €/kg poids brut OU 750 €/2 300 € selon poids du chargement.
- **Risque transporteur** : sans LV, **pas de réserves** documentables = présomption de bonne livraison conforme. Si l'expéditeur prouve l'avarie, le transporteur indemnise sans pouvoir contester l'état initial.

---

## 3. Le bordereau de livraison (BL) et les réserves

### 3.1 Définition

Le **bordereau de livraison (BL)** — parfois appelé **bon de livraison** — est le document remis au destinataire à l'arrivée, qu'il signe pour acquitter la réception. Il atteste de la livraison **conforme** ou **avec réserves**.

Concrètement, le BL est souvent **intégré** à la lettre de voiture (case « accusé de réception destinataire ») ou émis séparément (chez les commissionnaires industriels).

### 3.2 Les réserves : pourquoi et comment ?

**Sans réserves écrites au moment de la livraison**, le destinataire est présumé avoir reçu la marchandise **en bon état**. C'est une règle d'or du transport : **« pas de réserves = pas de litige acceptable »**.

⚠️ **Article L. 133-3 du Code de commerce** : le destinataire doit émettre ses réserves **au moment** de la livraison, OU dans les **3 jours** (avarie apparente) ou **7 jours** (avarie cachée) **par lettre recommandée AR** au transporteur.

### 3.3 Comment rédiger une réserve recevable ?

Une réserve doit être **précise**, **motivée**, **datée** et **chiffrée** :

✗ **Mauvaise réserve** : « Marchandise reçue sous réserves. »
✓ **Bonne réserve** : « 14 mai 2026, 8h45 — palette n° 3 sur 12 reçue avec film déchiré, 4 cartons détrempés sur 32 palette n° 7 manquante après comptage. Photos prises. »

### 3.4 Cas pratique : refus de signature du BL

**Énoncé** : Votre conducteur arrive chez le destinataire à 14h. Le destinataire constate des palettes affaissées et **refuse de signer** le BL.

**Procédure correcte** :
1. **Ne pas insister** verbalement ni laisser la marchandise en cas de refus catégorique.
2. **Photographier** chaque palette litigieuse + l'ensemble du chargement.
3. **Demander au destinataire** de noter par écrit la cause du refus (sur le BL ou sur un mail).
4. **Appeler immédiatement** le service exploitation transporteur.
5. **Émettre un PV de constat** (procès-verbal de carence) si refus total.
6. Sur instruction du DO, soit **rentrer la marchandise** au dépôt expéditeur, soit **livrer sous réserves** chez un autre destinataire désigné.

**À éviter** : forcer la livraison sans signature, abandonner la marchandise sur trottoir, accepter une signature « sous réserves générales » non motivée.

---

## 4. Le récépissé de prise en charge

### 4.1 Définition

Le **récépissé de prise en charge** est délivré par le transporteur à l'expéditeur **au chargement** — il atteste de la prise en compte de la marchandise. Il est souvent confondu avec la lettre de voiture, mais il a une fonction distincte : c'est la **preuve d'acceptation** par le transporteur.

### 4.2 Quand est-il obligatoire ?

Le récépissé est obligatoire pour :
- Les **commissionnaires de transport** (art. R. 1411-12 C. transports).
- Les transports **internationaux** (CMR — voir Leçon 2).
- Les transports de **valeur déclarée** ou de marchandises sensibles.

Pour le transporteur public en transport national standard, la lettre de voiture **fait foi** de récépissé.

### 4.3 Mentions du récépissé

| Mention | Détail |
|---|---|
| Identité du commissionnaire/transporteur | + n° licence |
| Identité de l'expéditeur | + SIRET |
| Date et lieu de prise en charge | Heure |
| Désignation marchandise | Nature, colis, poids |
| Engagement de prestation | Délai, mode |
| Référence dossier | N° interne |

---

## 5. Le bordereau de suivi des déchets (BSD)

### 5.1 Cadre réglementaire

Le **BSD** est obligatoire pour le transport de **déchets professionnels** (DIB, DEEE, DASRI, dangereux). Cadre : **Code de l'environnement art. R. 541-45**.

Depuis **2022**, dématérialisation obligatoire via la plateforme **Trackdéchets** (état dématérialisé).

### 5.2 Les acteurs du BSD

:::flow
1. Producteur du déchet | Émet le BSD (entreprise, hôpital, chantier)
2. Collecteur transporteur | Récupère et tient registre
3. Installation de traitement | Réceptionne et valorise / élimine
4. Préfecture / DREAL | Contrôle a posteriori
:::

### 5.3 Sanctions

Transport de déchets sans BSD : **75 000 € d'amende** + saisie du véhicule. Pour un GOTRM, c'est **vital** de vérifier que tous les voyages déchets disposent du BSD avant départ.

---

## 6. Signature électronique eIDAS

### 6.1 Cadre réglementaire

Le règlement européen **eIDAS** (2014) reconnaît la signature électronique avec la **même valeur juridique** que la signature manuscrite, à condition d'utiliser un fournisseur certifié.

### 6.2 3 niveaux de signature

| Niveau | Description | Valeur |
|---|---|---|
| **Simple** | Saisie d'un nom dans un champ | Faible (présomption faible) |
| **Avancée** | Lien unique signataire-document | Moyenne (présomption forte) |
| **Qualifiée** | Certificat délivré par un PSCo | Maximale (équivalent manuscrit) |

### 6.3 Solutions du marché en transport

| Solution | Coût | Niveau eIDAS |
|---|---|---|
| **DocuSign** | 30 €/mois/user | Avancée |
| **Yousign** | 25 €/mois/user | Avancée + qualifiée option |
| **Universign** | 20 €/mois/user | Qualifiée native |
| **Adobe Sign** | 35 €/mois/user | Avancée |

### 6.4 Cas pratique : LV signée sur tablette conducteur

**Procédure** :
1. Conducteur ouvre l'app TMS (Akanea, Mantis, Stellium).
2. Sélection du voyage en cours.
3. Au déchargement, le destinataire signe sur l'écran tactile.
4. Saisie d'un OTP envoyé par SMS pour signature avancée.
5. PDF horodaté + photo signature stocké en cloud.
6. Mail automatique au DO + destinataire avec PDF.

**Avantage** : preuve immédiate, archivage 5 ans, recherche en 1 clic en cas de litige.

---

## 7. Cas pratique d'examen

**Énoncé** : Le 12 mai 2026, vous transportez 25 palettes EUR de Renault (Lille) vers PSA Sochaux. Au déchargement à 11h30, le réceptionnaire constate :
- Palette n° 8 : 3 cartons écrasés sur 24.
- Palette n° 14 : film déchiré, 1 carton manquant.
- Palette n° 22 : taches d'humidité visibles.

**Questions :**
1. Quelle procédure de réserves le destinataire doit-il appliquer ?
2. Quels documents archiver côté transporteur ?
3. Délai pour confirmer les réserves par LRAR ?

**Correction :**

1. **Procédure de réserves** :
   - Réserves **écrites et précises** au moment de la livraison sur le bordereau de livraison : « 12 mai 2026, 11h30 — palette 8 : 3 cartons écrasés sur 24 ; palette 14 : film déchiré, 1 carton manquant ; palette 22 : taches d'humidité ».
   - **Photos** des palettes litigieuses (au moins 1 par anomalie).
   - **Refus partiel possible** : refus des palettes 14 et 22 si non conformes, acceptation 8 sous réserves.

2. **Documents archivés transporteur** :
   - Lettre de voiture signée + réserves.
   - Photos prises par le conducteur.
   - Mail de transmission au DO le jour même.
   - PV de constat si refus partiel.

3. **Délai LRAR** :
   - Avarie **apparente** (palettes 8 et 14) : **3 jours** (art. L. 133-3 C. com.).
   - Avarie **cachée** (humidité palette 22, à vérifier ouverture cartons) : **7 jours**.
   - Au-delà = **forclusion** : le destinataire perd son droit à indemnité.

---

## 8. Mini-exercice à faire seul

**Énoncé** : Transports Bonnafé livre 18 palettes de produits frais (température 0-4°C) à Carrefour Lyon. Au déchargement à 6h, le manutentionnaire constate que la sonde du frigo affiche 7°C depuis 2h (selon les enregistrements ATP). 4 palettes de yaourts présentent des emballages gonflés.

**Listez** :
1. Les 4 documents à mobiliser pour gérer ce litige.
2. La rédaction type des réserves sur le BL.
3. Les actions immédiates du conducteur et de l'exploitation.

> 💡 Réponse en fin de module (corrections § 4).

---

## 9. Glossaire

- **Lettre de voiture (LV)** : contrat de transport matérialisé, 4 exemplaires.
- **Bordereau de livraison (BL)** : preuve de remise au destinataire.
- **Récépissé de prise en charge** : preuve d'acceptation par le transporteur.
- **BSD** : Bordereau de Suivi des Déchets, obligatoire et dématérialisé via Trackdéchets.
- **eIDAS** : règlement européen 2014 sur signature électronique.
- **LRAR** : Lettre Recommandée avec Accusé de Réception (preuve juridique).
- **FNTR / OTRE** : fédérations syndicales émettrices des modèles standard.
- **Forclusion** : perte du droit à indemnité par dépassement des délais.
- **PV de carence** : procès-verbal en cas de refus de livraison.

---

## 10. Synthèse opérationnelle

1. **3 documents principaux** : récépissé (PEC), lettre de voiture, BL.
2. **11 mentions obligatoires** sur la LV (art. L. 1432-3 C. transports).
3. **4 exemplaires** lettre de voiture (blanc, rose, vert, jaune).
4. **Réserves** : précises, motivées, datées, chiffrées, photographiées.
5. **Délais** : 3 j (avarie visible) ou 7 j (cachée) en LRAR.
6. **BSD obligatoire** pour déchets pro (Trackdéchets, sanctions 75 k€).
7. **Signature eIDAS** : 3 niveaux (simple, avancée, qualifiée).
8. **Refus de livraison** : photo + PV de carence + appel exploitation.

---

## ⚠️ Points de vigilance

- **« Marchandise reçue sous réserves »** sans précision = réserve **non recevable**. Toujours détailler.
- Conducteur qui **part sans exemplaire signé** du destinataire = preuve perdue.
- **BSD obligatoire** dès qu'on transporte du **déchet professionnel** (même pour 1 m³ DIB d'un chantier).
- Signature **simple** sur tablette = niveau de preuve faible. Privilégier **avancée + OTP SMS**.

## 💡 Astuces pro

- **Modèle de réserve standard** à imprimer au dos du BL : « Le destinataire constate les anomalies suivantes : __________. Photos prises : oui / non. Date et heure : __________ . Signature : __________. »
- **App conducteur** : Akanea, Stellium, Mantis intègrent un module « réserves photo » avec géolocalisation = preuve béton.
- **Archivage 5 ans** : durée légale en transport routier (art. L. 123-22 C. com.). Cloud sécurisé = obligation RGPD.

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : nombre d'exemplaires LV, mentions obligatoires, délais réserves.
- **QR cas pratique** : « Le destinataire refuse de signer, que fait votre conducteur ? »
- **Oral DP** : « Décrivez votre processus de gestion documentaire dans votre entreprise actuelle. »

---

## 📌 Synthèse à retenir

### Les 3 documents nationaux

| Document | Rôle | Émetteur |
|---|---|---|
| **Récépissé PEC** | Preuve d'acceptation | Transporteur (chargement) |
| **Lettre de voiture** | Contrat de transport | Expéditeur ou transporteur |
| **Bordereau livraison** | Preuve de remise | Destinataire (signature) |

### Les 11 mentions obligatoires LV (art. L. 1432-3)

Date · Expéditeur · Transporteur · Destinataire · Lieux/dates chargement & livraison · Marchandise · Colis · Poids · Prix · Instructions

> 📌 **4 exemplaires lettre de voiture**
>
> Blanc (expéditeur) · Rose (transporteur exploitation) · Vert (destinataire) · Jaune (transporteur archives)

### Réserves recevables

| Niveau | Validité juridique |
|---|---|
| « Reçu sous réserves » sans détail | **Nulle** |
| Mention précise + chiffres | **Forte** |
| Mention + photos + LRAR < 3/7 j | **Maximale** |

> ⚠️ **Délais de réclamation**
>
> - Avarie **apparente** : **3 jours**
> - Avarie **cachée** : **7 jours**
> - Au-delà : **forclusion** (droit perdu)

### Signature eIDAS

- **Simple** (saisie nom) : faible valeur
- **Avancée** (lien unique + OTP) : forte valeur
- **Qualifiée** (PSCo certifié) : équivalent manuscrit

> ✅ Pour la flotte conducteurs : **avancée + OTP SMS** = bon compromis coût/sécurité
$lessonG1$,
'Identifier les documents obligatoires du transport national (lettre de voiture 4 exemplaires, BL, récépissé), maîtriser les 11 mentions obligatoires (art. L. 1432-3 C. transports), apposer des réserves recevables (précises, motivées, photo, LRAR < 3/7 j) et utiliser la signature électronique eIDAS pour la traçabilité.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Documents de transport international
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Documents de transport international — CMR, BL maritime, AWB',
    'documents-transport-international',
    2, 45,
$lessonG2$
# Documents de transport international — CMR, BL maritime, AWB

> 🎯 **Objectifs pédagogiques**
>
> - **Distinguer** les documents selon le mode de transport (route, mer, air, rail).
> - **Rédiger** une lettre de voiture CMR conforme à la Convention de Genève 1956.
> - **Comprendre** la différence entre BL négociable et AWB non-négociable.
> - **Articuler** documents et carnet TIR pour les transits hors UE.
> - **Construire** la cascade documentaire d'un transport multimodal.

---

## Introduction

Le transport international génère **70 % des litiges documentaires** du secteur. Pourquoi ? Parce qu'à chaque mode (route, mer, air, rail) correspond un **document différent**, des **conventions internationales distinctes**, et des **règles de réserves spécifiques**.

Le **gestionnaire d'opérations** doit savoir :
- Choisir le **document adapté** au mode (CMR pour la route, BL pour la mer, AWB pour l'air).
- Préparer le **carnet TIR** pour les transits hors UE (Russie, Maroc, Turquie).
- **Articuler** les documents en cas de transport multimodal (route + mer + route).

Cette leçon vous arme pour gérer des chaînes complexes — par exemple un Paris-Stockholm avec transbordement à Hambourg — sans **rupture documentaire** ni litige douanier.

---

## 1. La CMR — pivot du transport routier international

### 1.1 Convention de Genève 1956

La **Convention CMR** (Convention relative au contrat de transport international de Marchandises par Route), signée à Genève le **19 mai 1956**, régit le transport routier de marchandises **entre 2 pays signataires**. Elle s'applique automatiquement dès que le pays de départ OU d'arrivée est signataire.

**56 pays signataires** en 2026 :
- Tous les **27 États UE**.
- **Royaume-Uni** (post-Brexit, toujours signataire).
- **Suisse, Norvège, Islande, Liechtenstein** (AELE).
- **Russie, Ukraine, Biélorussie, Moldavie**.
- **Maroc, Tunisie, Algérie**.
- **Turquie, Iran, Liban, Jordanie**.
- **Asie centrale** : Kazakhstan, Ouzbékistan.

### 1.2 Le document CMR

Le **document CMR** (lettre de voiture internationale) est obligatoire pour tout transport CMR. **Format imposé** par la convention :

- **Couleur** : multicolore (souvent rouge / blanc / bleu selon éditeur).
- **Langues** : multilingue (français, anglais, allemand, néerlandais, etc.).
- **Numérotation séquentielle** par éditeur (FNTR, IRU, IATA).

### 1.3 Les exemplaires CMR

**3 exemplaires obligatoires** (article 5 de la convention) :

| Exemplaire | Couleur type | Destinataire |
|---|---|---|
| **1er** (« exemplaire d'expédition ») | Rouge | Expéditeur |
| **2e** (« exemplaire de transport ») | Bleu | Transporteur |
| **3e** (« exemplaire de réception ») | Vert | Destinataire |

Certains pays imposent un **4e exemplaire jaune** pour la douane (cas des transits hors UE).

### 1.4 Mentions obligatoires CMR (art. 6)

| N° | Mention |
|---|---|
| 1 | Lieu et date d'établissement |
| 2 | Nom et adresse de l'expéditeur |
| 3 | Nom et adresse du transporteur |
| 4 | Lieu et date de prise en charge |
| 5 | Lieu prévu pour la livraison |
| 6 | Nom et adresse du destinataire |
| 7 | Désignation courante de la marchandise et mode d'emballage |
| 8 | Nombre de colis, marques et numéros |
| 9 | Poids brut ou quantité |
| 10 | Frais relatifs au transport |
| 11 | Instructions douanières |
| 12 | Indication CMR si la convention s'applique |

### 1.5 Réserves CMR

Règle CMR (art. 8) : si le transporteur ne peut **vérifier l'exactitude** des mentions de l'expéditeur, il doit **inscrire des réserves motivées** :
- « Marchandise non vérifiée » (manque le temps).
- « Comptage de colis non effectué ».
- « État apparent : palettes éventées ».

**Droit au contre-pesage gratuit** (art. 8.3) : si le transporteur conteste le poids, l'expéditeur doit fournir une bascule au chargement. **Sans cela = pas de contestation possible** par le transporteur après coup.

### 1.6 Indemnité CMR

| Critère | Règle |
|---|---|
| Plafond | **8,33 DTS/kg** (≈ 10,80 €/kg en 2026) |
| Base | Poids brut |
| Frais inclus | Restitution prix de transport, droits douane, autres frais |
| Prescription | **1 an** (3 ans en cas de dol) |

⚠️ **Plafond CMR plus restrictif** que le contrat-type général français (14 €/kg). À noter dans les CGV transporteur.

---

## 2. Le BL maritime (Bill of Lading)

### 2.1 Définition

Le **Bill of Lading (BL)** ou **connaissement maritime** est un document délivré par le transporteur maritime à l'expéditeur. Il a **3 fonctions cumulatives** uniques au monde maritime :

1. **Reçu** de la marchandise par le transporteur.
2. **Contrat** de transport.
3. **Titre représentatif** de la marchandise (négociable).

### 2.2 Pourquoi le BL est unique : la négociabilité

Contrairement à la CMR ou à l'AWB, le **BL maritime peut être endossé** comme un chèque. Celui qui détient l'original peut **revendre la marchandise en cours de transport**. Très utilisé dans le commerce international (négoce de matières premières, etc.).

**Exemple** : un BL pour 5 000 tonnes de blé sur navire entre Rouen et Casablanca peut être revendu 3 fois en mer si les prix mondiaux varient.

### 2.3 Les exemplaires BL

**3 originaux** (« first », « second », « third » original) + plusieurs copies.

⚠️ **Règle** : la livraison se fait **uniquement contre remise d'un original**. Le transporteur libère la marchandise au porteur du connaissement endossé.

### 2.4 Types de BL

| Type | Description | Usage |
|---|---|---|
| **BL nominatif** | Au nom du destinataire précis | Sécurité, non négociable |
| **BL à ordre** | « To order of [banque/expéditeur] » | Négociable par endossement |
| **BL au porteur** | Au porteur (rare) | Très négociable, risque vol |

### 2.5 Conventions applicables

- **Convention de Bruxelles 1924** (Hague Rules) : régime initial.
- **Hague-Visby Rules 1968** : modernisation.
- **Hambourg Rules 1978** : pro-chargeur (peu signée).
- **Rotterdam Rules 2009** : la plus récente, peu ratifiée.

Plafond Hague-Visby : **666,67 DTS par colis** OU **2 DTS/kg**, le plus élevé des deux.

---

## 3. L'AWB (Air Waybill) — transport aérien

### 3.1 Définition

L'**Air Waybill (AWB)** est la lettre de transport aérien. **Document non-négociable** (différence majeure avec le BL maritime). Régi par la **Convention de Montréal 1999** (qui remplace la Convention de Varsovie 1929).

### 3.2 Caractéristiques

- **Non-négociable** : nominatif au destinataire désigné.
- **3 originaux** : 1 expéditeur, 1 destinataire, 1 transporteur aérien (compagnie).
- Format **standardisé IATA** (Association Internationale du Transport Aérien).
- **Numéro AWB** : 11 chiffres (les 3 premiers identifient la compagnie).

### 3.3 Indemnité Convention de Montréal

| Critère | Règle |
|---|---|
| Plafond | **22 DTS/kg** (≈ 28,60 €/kg) |
| Prescription | 2 ans |
| Délai de réclamation avarie | 14 jours après réception |

⚠️ Plafond aérien **2,5 fois plus élevé** que la CMR routière. C'est lié à la valeur typique des marchandises aériennes (haute valeur ajoutée, urgentes).

---

## 4. Le carnet TIR

### 4.1 Définition et utilité

Le **carnet TIR (Transport International Routier)** est un document douanier qui permet à un véhicule de **traverser plusieurs frontières hors UE** sans avoir à être déclaré et inspecté à chaque frontière.

**Convention TIR 1975** sous l'égide de la CEE-ONU. **76 pays** participants, dont la Russie, le Maroc, la Turquie, l'Iran, l'Asie centrale et l'Asie de l'Est.

### 4.2 Comment ça marche ?

:::flow
1. Émission carnet TIR | Par fédération nationale (FNTR pour la France)
2. Plombage douane départ | Scellage sous régime TIR
3. Transit pays intermédiaires | Pas d'inspection si plombs intacts
4. Vérification douane arrivée | Brisure des plombs et inspection
5. Apurement carnet | Décharge transporteur de sa garantie
:::

### 4.3 Garantie financière

Chaque carnet TIR est **garanti par la fédération émettrice** (FNTR pour la France) à hauteur de **50 000 €** pour couvrir les droits douaniers en cas de perte de marchandise ou de fraude.

### 4.4 Cas d'usage typiques

- **Paris → Moscou** : transit par UE puis Russie (hors UE).
- **Marseille → Casablanca** : transit Espagne (UE) puis Maroc (hors UE).
- **Lyon → Téhéran** : transit Italie/Turquie/Iran.

⚠️ **TIR pas applicable en UE seule** : pour Paris-Berlin, on utilise la CMR seule (sans TIR).

---

## 5. Cas pratique : Paris-Stockholm avec transbordement Hambourg

### 5.1 Énoncé

Vous organisez le transport de 12 palettes de pièces automobiles (8 t) de **Renault Paris** vers **Volvo Stockholm**, avec un **transbordement maritime** à **Hambourg** (camion → ferry → camion).

### 5.2 Cascade documentaire

:::flow
1. Récépissé PEC Paris | Émis par 1er transporteur routier
2. CMR n° 1 | Paris → Hambourg (route UE)
3. Transbordement Hambourg | Saisie sur BL maritime ferry
4. BL maritime | Hambourg → Trelleborg (Suède)
5. CMR n° 2 | Trelleborg → Stockholm (route UE)
6. BL livraison Stockholm | Signé par Volvo
:::

### 5.3 Régime juridique

- **Pas de TIR nécessaire** : tout est dans l'UE.
- **CMR n° 1** : régit Paris-Hambourg, signataire France/Allemagne.
- **BL maritime** : régit Hambourg-Trelleborg, Hague-Visby Rules.
- **CMR n° 2** : régit Trelleborg-Stockholm, signataire Suède.

### 5.4 Responsabilité en cas de perte

**Application de la règle CMR (art. 36)** : c'est le **transporteur du segment où la perte est survenue** qui indemnise.
- Perte avant Hambourg : 1er routier (CMR France-Allemagne).
- Perte en mer : compagnie maritime (BL).
- Perte après Trelleborg : 2e routier (CMR Suède).

⚠️ **Si le commissionnaire** organise toute la chaîne, c'est lui qui indemnise le client final, puis se retourne contre le transporteur fautif.

---

## 6. Documents annexes selon mode

### 6.1 Transport ferroviaire international (CIM)

- **Convention CIM** (Convention internationale concernant le transport des marchandises par chemin de fer).
- Document : **lettre de voiture CIM**.
- 5 exemplaires (rare en pratique pour route, à connaître pour multimodal).

### 6.2 Transport fluvial (CMNI)

- **Convention CMNI** (Budapest 2000) : transport par voie fluviale internationale (Rhin, Danube).
- Document : **connaissement fluvial** ou **lettre de voiture CMNI**.

### 6.3 Documents d'origine et facture

- **Facture commerciale** : valeur, devise, INCOTERM (voir Leçon 4).
- **Facture proforma** : devis avant transport, sans valeur fiscale.
- **Liste de colisage (packing list)** : détail palette par palette pour douane.

---

## 7. Cas pratique d'examen

**Énoncé** : Vous transportez 22 palettes de cosmétiques de **L'Oréal Clichy** vers **Marrakech** (Maroc) en route directe par RoRo (camion sur ferry Sète-Tanger). Valeur 380 000 €.

**Questions :**
1. Quels documents préparer côté transport ?
2. Quels documents douaniers prévoir ?
3. Plafond d'indemnité CMR sur ce transport ?

**Correction :**

1. **Documents transport** :
   - **Récépissé PEC** Clichy.
   - **CMR n° 1** : Clichy → Sète (segment routier France).
   - **BL maritime** : Sète → Tanger (ferry RoRo).
   - **CMR n° 2** : Tanger → Marrakech (Maroc, signataire CMR).
   - **Carnet TIR** non nécessaire si transit Espagne/France évité (RoRo direct).

2. **Documents douaniers** :
   - **DAU (Document Administratif Unique)** d'**exportation** France (régime EX).
   - **DAU** d'**importation** Maroc (régime IM).
   - **Facture commerciale** + **liste de colisage**.
   - **Certificat d'origine** EUR-MED si applicable (accord UE-Maroc).

3. **Plafond CMR** :
   - 22 palettes × 600 kg/palette estimés = ~13 200 kg poids brut total.
   - Plafond CMR : 13 200 × 8,33 DTS = 109 956 DTS × 1,30 €/DTS = **142 943 €**.
   - **Préjudice non couvert** sans déclaration de valeur : 380 000 − 142 943 = **237 057 €** à la charge de L'Oréal.
   - **Recommandation** : déclaration de valeur écrite + assurance ad valorem L'Oréal.

---

## 8. Mini-exercice à faire seul

**Énoncé** : Une PME de Lille expédie 8 palettes de vin (15 000 €) vers un client en **Russie (Saint-Pétersbourg)**, par route directe via Pologne et Biélorussie.

**Listez** :
1. Les documents transport à émettre.
2. Les documents douaniers.
3. La validité ou non du carnet TIR.

> 💡 Réponse en fin de module (corrections § 4).

---

## 9. Glossaire

- **CMR** : Convention de Genève 1956 sur transport routier international.
- **BL** : Bill of Lading, connaissement maritime, négociable.
- **AWB** : Air Waybill, lettre de transport aérien IATA.
- **DTS** : Droit de Tirage Spécial (FMI), 1 DTS ≈ 1,30 €.
- **TIR** : Transport International Routier (carnet, Convention 1975).
- **CIM** : Convention internationale transport ferroviaire marchandises.
- **CMNI** : Convention transport fluvial international (Budapest 2000).
- **Hague-Visby Rules** : régime maritime international.
- **IATA** : International Air Transport Association.
- **Endossement** : signature qui transfère la propriété (BL négociable).
- **RoRo** : Roll-on Roll-off (ferry transportant camions).

---

## 10. Synthèse opérationnelle

1. **CMR** : transport routier international (56 pays), 3 exemplaires (rouge/bleu/vert), plafond **8,33 DTS/kg ≈ 10,80 €/kg**.
2. **BL maritime** : 3 originaux, **négociable par endossement**, plafond Hague-Visby 666,67 DTS/colis ou 2 DTS/kg.
3. **AWB** : non-négociable, plafond Convention de Montréal **22 DTS/kg**, prescription 2 ans.
4. **Carnet TIR** : transit hors UE, garantie 50 000 €, scellage douanier.
5. **Multimodal** : cascade documentaire, responsabilité par segment.
6. **Mentions CMR (art. 6)** : 12 obligatoires + instructions douanières.
7. **Réserves CMR (art. 8)** : « non vérifié », contre-pesage gratuit.
8. **Documents annexes** : facture commerciale, packing list, certificat d'origine.

---

## ⚠️ Points de vigilance

- **CMR vs CIM** : CMR pour la route, CIM pour le rail. **Ne pas confondre**.
- **BL maritime endossé** = transfert de propriété. Garde précieuse des originaux.
- **Carnet TIR plombé** : briser un plomb sans douane = saisie marchandise + amende.
- **Plafond CMR < contrat-type français** : toujours mentionner « régime CMR » dans CGV pour les transports internationaux.
- **Multimodal** : un seul transporteur peut couvrir toute la chaîne avec **CMR couvrant l'ensemble** (multimodal CMR), simplification précieuse.

## 💡 Astuces pro

- **App de gestion CMR** : Akanea International, AS400 EVALI, TMS Mantis incluent module CMR digital + multilingue automatique.
- **Bibliothèque IRU** : l'**International Road Transport Union** publie les modèles CMR à jour (gratuits, en 23 langues).
- **Garantie TIR FNTR** : ouverture de compte gratuit pour les adhérents, paiement carnet par carnet (~25 €).
- **Photo des plombs TIR** : à chaque frontière, photo des plombs intacts par le conducteur = preuve d'absence d'effraction.

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : différence CMR/BL/AWB, plafonds, exemplaires, conventions.
- **QR cas pratique** : « Reconstituez la chaîne documentaire d'un transport multimodal Paris-Stockholm ».
- **Oral DP** : « Quelle convention internationale s'applique sur ce voyage ? Pourquoi ? »

---

## 📌 Synthèse à retenir

### Les 3 documents internationaux par mode

| Mode | Document | Convention | Plafond |
|---|---|---|---|
| **Route** | CMR | Genève 1956 | **8,33 DTS/kg** |
| **Mer** | BL (connaissement) | Hague-Visby 1968 | 2 DTS/kg ou 666,67/colis |
| **Air** | AWB | Montréal 1999 | **22 DTS/kg** |
| **Rail** | Lettre CIM | COTIF | 17 DTS/kg |
| **Fluvial** | CMNI | Budapest 2000 | 2 DTS/kg ou 666,67/colis |

### CMR — règles clés

- **3 exemplaires** : rouge (expéditeur), bleu (transporteur), vert (destinataire)
- **12 mentions obligatoires** (art. 6)
- **Réserves possibles** (art. 8) : « non vérifié », contre-pesage gratuit
- **Plafond** : 8,33 DTS/kg ≈ 10,80 €/kg (2026)
- **Prescription** : 1 an (3 ans en dol)

> 📌 **Carnet TIR**
>
> Hors UE seulement (Russie, Maroc, Turquie, etc.) · 50 000 € garantie · scellement douanier

### BL maritime : les 3 fonctions

1. **Reçu** de la marchandise
2. **Contrat** de transport
3. **Titre négociable** (endossable comme un chèque)

> ⚠️ **Multimodal — règle Article 36 CMR**
>
> En cas de perte, c'est le **transporteur du segment où la perte est survenue** qui indemnise.
> Sauf si un commissionnaire couvre toute la chaîne (sa responsabilité de résultat).
$lessonG2$,
'Distinguer les documents par mode de transport (CMR routier 8,33 DTS/kg, BL maritime négociable Hague-Visby, AWB aérien 22 DTS/kg Montréal), maîtriser les 12 mentions CMR obligatoires (art. 6 Genève 1956), articuler les documents en multimodal et préparer le carnet TIR pour les transits hors UE.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Formalités douanières
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Formalités douanières — DAU, T1/T2, EX/IM',
    'formalites-douanieres',
    3, 45,
$lessonG3$
# Formalités douanières — DAU, T1/T2, EX/IM

> 🎯 **Objectifs pédagogiques**
>
> - **Distinguer** les opérations intra-UE et hors UE.
> - **Maîtriser** le DAU (Document Administratif Unique) et ses 4 régimes principaux.
> - **Comprendre** le transit T1/T2 et ses garanties.
> - **Identifier** les acteurs douaniers et leurs rôles.
> - **Utiliser** la dématérialisation DELTA G / DELTA H7.

---

## Introduction

Depuis le **Brexit du 1er janvier 2021**, les formalités douanières sont **redevenues centrales** dans le métier du transport. Un Royaume-Uni ramené hors UE, c'est **2,3 millions de camions/an** qui doivent désormais produire des déclarations douanières — multipliant par 5 le travail des transitaires français.

Le **GOTRM** doit comprendre :
- Quand une **déclaration douanière** est nécessaire (hors UE) vs **non nécessaire** (intra-UE).
- Quel **régime douanier** appliquer (export EX, import IM, transit T1, transit T2).
- Quels **acteurs** mobiliser (commissionnaire en douane, transitaire, douane française).
- Comment utiliser les **outils dématérialisés** (DELTA G, DELTA H7).

Cette leçon est cruciale pour **éviter les saisies de marchandises**, les **retards en frontière** (24-72 h) et les **amendes douanières** pouvant atteindre 4 fois la valeur de la marchandise.

---

## 1. L'Union douanière européenne

### 1.1 Le marché unique

L'**Union douanière européenne** (1968) crée un **territoire douanier unique** : pas de frontières douanières entre **27 États membres** + accord de libre circulation avec :
- **Norvège, Islande, Liechtenstein** (EEE).
- **Suisse** (accords bilatéraux, partiellement intégrée).
- **Andorre, Monaco, San Marin** (territoires associés).

### 1.2 Conséquences pratiques

| Situation | Formalités douanières |
|---|---|
| **Paris → Berlin** (intra-UE) | **AUCUNE** déclaration nécessaire |
| **Paris → Genève** (UE → Suisse) | **DAU export** (EX) côté FR + **import** (IM) côté CH |
| **Paris → Londres** (UE → UK post-Brexit) | DAU export FR + import UK |
| **Paris → Casablanca** (UE → Maroc) | DAU export + IM + EUR-MED si applicable |

### 1.3 La déclaration intracom (DEB / DES)

Pour les échanges **intra-UE**, pas de douane mais une **déclaration statistique** mensuelle :
- **DEB (Déclaration d'Échanges de Biens)** : pour la TVA et les statistiques.
- **DES (Déclaration Européenne de Services)** : pour les prestations.
- **Seuils** : DEB obligatoire si > 460 000 €/an (introductions/expéditions intra-UE).
- **TVA intracom** : autoliquidation par l'acquéreur (TVA à 0 % chez l'expéditeur, déclarée chez l'acquéreur).

### 1.4 Cas Brexit

Depuis 2021, le **Royaume-Uni est hors UE**. Conséquences :
- DAU export pour chaque expédition vers UK (~ 80 € de frais transitaire).
- **CDS** côté UK (Customs Declaration Service).
- Délai en frontière : 1-3 h en moyenne (vs 0 avant Brexit).
- Volume de paperasse multipliée par 4 selon FNTR.

---

## 2. Le DAU (Document Administratif Unique)

### 2.1 Définition

Le **DAU (Document Administratif Unique)** est le formulaire douanier européen utilisé pour toute opération hors UE. Cadre : **Règlement UE 952/2013 (Code des Douanes de l'Union)**.

54 cases à remplir, classées en 8 zones (parties, marchandise, valeur, origine, etc.).

### 2.2 Les 4 régimes principaux

| Code | Régime | Description |
|---|---|---|
| **EX** | Export | Sortie définitive du territoire UE |
| **IM** | Import | Entrée définitive sur le territoire UE |
| **T1** | Transit externe | Marchandise non-UE en circulation dans UE |
| **T2** | Transit interne | Marchandise UE qui transite par un pays tiers |

### 2.3 Régime EX (export)

Pour toute marchandise quittant l'UE :
- **Bureau de douane d'exportation** (généralement origine).
- **Déclaration EX1** (régime définitif) ou EX2 (régime temporaire).
- **Document EAD (Export Accompanying Document)** = preuve papier transit.
- **MRN (Movement Reference Number)** : 18 caractères = identifiant unique.
- **Apurement** : sortie effective UE prouvée par scellage frontière.

### 2.4 Régime IM (import)

Pour toute marchandise entrant en UE :
- **Bureau de douane d'importation** (généralement destination ou frontière).
- **Déclaration IM4** (mise en libre pratique + mise à la consommation, taxes payées).
- **Liquidation** : douanes calculent droits + TVA, transporteur ou destinataire paye.
- **BAE (Bon À Enlever)** : autorisation finale de prendre la marchandise.

### 2.5 Cas pratique : Lyon → Genève (export simple)

**Données** : 8 palettes de matériel médical, valeur 45 000 €, transport routier.

**Procédure** :
1. **Préparation documentaire** (transitaire ou commissionnaire en douane) :
   - Facture commerciale.
   - Packing list.
   - DAU EX1.
   - CMR.
2. **Dépôt déclaration** dans **DELTA G** (en ligne).
3. **Visa du DAU** par bureau de douane Lyon ou bureau frontière (Annemasse).
4. **Livraison** à Genève : douane suisse réceptionne IM côté CH (procédure import suisse).
5. **Apurement** côté FR : envoi du EAD scellé en retour.

**Coût transitaire** : 60-120 € pour ce type d'opération.

---

## 3. Les régimes de transit T1 et T2

### 3.1 Régime T1 — transit externe

Le **T1** est utilisé pour les marchandises **non-UE** qui circulent dans l'UE en attendant d'être dédouanées.

**Exemple** :
- Marchandise chinoise débarquée au port du Havre.
- Transit T1 du Havre vers Munich où sera déclaré l'import IM4.
- Pendant le T1 : marchandise « sous douane », non taxable.

**Caractéristiques** :
- **Pas de droits payés** pendant le transit.
- **Garantie financière** (NCTS — Nouveau Système Computerisé de Transit) : 30 % de la valeur des droits estimés.
- **Apurement** au bureau de destination : preuve d'arrivée → libération de la garantie.

### 3.2 Régime T2 — transit interne

Le **T2** est utilisé pour les marchandises **UE** qui doivent **traverser un pays tiers** en restant statut UE.

**Exemple** :
- Marchandise française expédiée vers Italie via Suisse.
- T2 protège le statut UE pendant la traversée Suisse.
- Pas de risque de devoir refaire un import à l'arrivée Italie.

**Caractéristiques** :
- Marchandise **conserve son statut UE** (pas de TVA à l'arrivée).
- **Garantie** plus faible que T1 (statut UE moins risqué).

### 3.3 Cas pratique : Lyon → Vienne via Suisse

**Données** : transport routier, marchandise UE, livraison Vienne (Autriche).

**Choix** : T2 ou pas T2 ?
- Sans T2 : à l'entrée Italie/Autriche, faire IM4 (importer en UE) puis EX (exporter vers Vienne) → lourd, lent, coûteux.
- Avec T2 : marchandise UE protégée, formalité unique, gain temps + coûts.

**Procédure T2** :
1. **Émission T2** au bureau de douane FR (Annecy par ex.).
2. **Garantie** déposée par transporteur ou commissionnaire.
3. **Plombage** véhicule.
4. **Traversée Suisse** sous T2 (douane suisse contrôle).
5. **Apurement T2** à l'arrivée Vienne (Autriche).

---

## 4. Acteurs des formalités douanières

### 4.1 Le commissionnaire en douane

Le **commissionnaire en douane (CED)** ou **représentant en douane (RDE)** est un professionnel agréé qui établit les déclarations pour le compte du DO.

- **Statut** : profession réglementée (Code des Douanes art. 86-90).
- **Agrément** : délivré par la DGDDI (Direction Générale des Douanes et Droits Indirects).
- **Responsabilité** : solidaire du DO pour le paiement des droits et taxes.
- **Tarification** : 50-150 € par déclaration simple, 200-500 € pour opérations complexes.

### 4.2 Le transitaire

Le **transitaire** est un commissionnaire de transport spécialisé en logistique internationale, qui s'occupe :
- De l'**organisation transport** (multimodale).
- Des **formalités douanières** (souvent agréé CED).
- De l'**assurance ad valorem**.
- Du **dédouanement complet**.

**Exemples** : Geodis, DSV, DB Schenker, Bolloré Logistics, Kuehne+Nagel.

### 4.3 La douane française (DGDDI)

- **Bureaux principaux** : Roissy, Le Havre, Marseille-Fos, Dunkerque, Strasbourg.
- **Bureaux secondaires** : tous départements.
- **Brigades volantes** : contrôles routiers, autoroutiers.
- **Sanctions** : amendes administratives, retenue marchandise, infraction pénale.

### 4.4 Le déclarant

Toute personne (DO, transporteur, transitaire) qui **dépose la déclaration** est appelée le **déclarant**. Il est solidairement responsable des droits et taxes.

⚠️ **Risque déclarant** : si le DO ne paie pas, la douane peut se retourner contre le transporteur ou le transitaire (action solidaire).

---

## 5. Dématérialisation : DELTA G et DELTA H7

### 5.1 DELTA G (Dédouanement en Ligne par Traitement Automatisé)

**Plateforme française** unique pour toutes les déclarations douanières.

- **Accès** : via certificat numérique (PKI Douane) ou via connecteur transitaire.
- **Volume** : 16 millions de déclarations/an traitées en France (2024).
- **Délai** : décision automatique en **moins de 5 minutes** dans 80 % des cas.

### 5.2 DELTA H7 — modernisation

**DELTA H7** est la nouvelle version (2023+) qui intègre :
- **Open data** : remontées automatiques pour statistiques.
- **APIs** : connexions directes TMS / DELTA pour les transitaires.
- **Pré-déclaration** : déclaration anticipée avant arrivée.

### 5.3 Outils complémentaires

| Outil | Fonction |
|---|---|
| **NCTS** | Transit (T1/T2) |
| **EMCS** | Excise (alcool, tabac, énergie) |
| **ICS2** | Sécurité-sûreté pré-arrivée |
| **DELTA C** | Conex (collaboration commerciale) |

---

## 6. Cas pratique d'examen

**Énoncé** : Vous organisez un transport de **15 palettes de pneus Michelin** (valeur 85 000 €) de **Clermont-Ferrand** vers **Casablanca (Maroc)**, par route directe (transbordement Sète-Tanger en RoRo).

**Questions :**
1. Quelles formalités douanières prévoir, étape par étape ?
2. Quel acteur mobiliser pour les déclarations ?
3. Quels documents préparer ?
4. Coût douanier estimé pour le DO ?

**Correction :**

1. **Formalités étape par étape** :
   - Clermont → Sète : transit intra-UE, **aucune déclaration**.
   - Sète : embarquement RoRo, **DAU EX1** déposé par transitaire FR.
   - Tanger : arrivée Maroc, **import IM** déposé par transitaire MA.
   - Tanger → Casablanca : transit intra-MA, aucune déclaration UE.
   - **Apurement EX1 FR** : preuve sortie UE retour vers DGDDI.

2. **Acteurs** :
   - **Transitaire France** (Geodis, Bolloré, etc.) pour DAU EX1.
   - **Transitaire Maroc** (correspondant local) pour IM.
   - Si DO préfère : **commissionnaire en douane Roissy** ou Marseille (DGDDI).

3. **Documents** :
   - Facture commerciale Michelin.
   - Packing list.
   - DAU EX1 (Sète).
   - CMR (Clermont → Sète).
   - BL maritime (Sète → Tanger).
   - CMR n° 2 (Tanger → Casablanca).
   - Certificat d'origine **EUR-MED** (accord UE-Maroc, droits réduits).

4. **Coût douanier** :
   - Transitaire FR : ~120 € (DAU + apurement).
   - Transitaire MA : ~200 € + droits import Maroc (typiquement 25-40 % pneus).
   - **Droits import MA** : 85 000 × 30 % = **25 500 €** dus par le DO.
   - **TVA Maroc** : 20 % sur valeur en douane = 17 000 €.
   - **Total** : ~42 820 € de droits/taxes + ~320 € de transitaires.

---

## 7. Mini-exercice à faire seul

**Énoncé** : Vous devez livrer 30 palettes de jus de fruit (valeur 12 000 €) de **Bordeaux** vers **Bratislava (Slovaquie)** via **Suisse** (raccourci routier intéressant).

**Questions :**
1. Faut-il un T2 ? Pourquoi ?
2. Quelles formalités à la frontière FR-CH ?
3. Quelles formalités à la frontière CH-AT (puis AT-SK intra-UE) ?

> 💡 Réponse en fin de module (corrections § 4).

---

## 8. Glossaire

- **DAU** : Document Administratif Unique, formulaire douanier UE.
- **EX** : Export (sortie UE).
- **IM** : Import (entrée UE).
- **T1** : Transit externe (marchandise non-UE en circulation UE).
- **T2** : Transit interne (marchandise UE traversant un pays tiers).
- **EAD** : Export Accompanying Document (papier transit DAU EX).
- **MRN** : Movement Reference Number (18 caractères, identifiant DAU).
- **BAE** : Bon À Enlever (autorisation finale d'enlèvement après import).
- **DELTA G / H7** : plateforme française de dédouanement dématérialisé.
- **DGDDI** : Direction Générale des Douanes et Droits Indirects.
- **NCTS** : Nouveau Système Computerisé de Transit (T1/T2).
- **CED / RDE** : Commissionnaire ou Représentant en Douane.
- **DEB** : Déclaration d'Échanges de Biens (intra-UE statistique).
- **CDS** : Customs Declaration Service (équivalent UK DELTA).

---

## 9. Synthèse opérationnelle

1. **Intra-UE** = libre circulation, **DEB** déclaration statistique > 460 k€/an.
2. **Hors UE** = **DAU** obligatoire (EX export, IM import).
3. **T1** = transit marchandise non-UE dans UE (garantie NCTS).
4. **T2** = transit marchandise UE via pays tiers (préserve statut UE).
5. **Acteurs** : transitaire / commissionnaire en douane / DGDDI.
6. **Dématérialisation** : DELTA G/H7 + NCTS + EMCS.
7. **Brexit** : UK désormais hors UE, DAU obligatoire UK ↔ UE.
8. **MRN** : identifiant unique 18 caractères, à conserver.

---

## ⚠️ Points de vigilance

- **Confusion T1/T2** : T1 = non-UE, T2 = UE. **Inverser = saisie marchandise**.
- **Apurement EX manquant** : risque amende 1 500 € + remboursement TVA si export non prouvé.
- **Transitaire non-agréé** : nullité de la déclaration, retard livraison, sanction DO.
- **Brexit** : oublier la formalité douanière vers UK = blocage frontière (Eurotunnel, Calais).
- **Marchandise sous douane** : interdiction d'ouvrir, modifier ou utiliser pendant T1.

## 💡 Astuces pro

- **Formation CED** : la DGDDI propose des formations gratuites pour devenir représentant en douane.
- **Plateforme PORTNET** (Maroc) : équivalent DELTA pour l'import marocain, à connaître pour clients MA.
- **TVA intracom** : système d'autoliquidation, facture HT 0 % chez l'expéditeur — vérifier le n° TVA acquéreur sur **VIES** (UE) avant facturation.
- **Pré-dédouanement** : utiliser DELTA H7 « pré-déclaration » pour gagner 30-60 min en frontière.

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : différence T1/T2, régimes EX/IM, conséquences Brexit.
- **QR cas pratique** : « Pour un transport Lyon-Genève, quelles formalités prévoir et quel acteur mobiliser ? »
- **Oral DP** : « Comment gérez-vous les formalités douanières dans votre entreprise ? »

---

## 📌 Synthèse à retenir

### Quand faut-il une déclaration douanière ?

| Trajet | Déclaration ? |
|---|---|
| **Paris → Berlin** (intra-UE) | NON (DEB statistique si > 460 k€/an) |
| **Paris → Genève** (UE → CH) | OUI : EX FR + IM CH |
| **Paris → Londres** (UE → UK post-Brexit) | OUI : EX FR + IM UK |
| **Paris → Casablanca** (UE → MA) | OUI : EX + IM + EUR-MED |

### Les 4 régimes DAU

| Code | Régime | Quand l'utiliser |
|---|---|---|
| **EX** | Export | Sortie définitive UE |
| **IM** | Import | Entrée définitive UE |
| **T1** | Transit externe | Non-UE circulant dans UE |
| **T2** | Transit interne | UE traversant pays tiers |

> 📌 **Acteurs douaniers**
>
> - **Commissionnaire en douane (CED)** : déclarations agréées DGDDI
> - **Transitaire** : organisation + douane (Geodis, DSV, Bolloré, K+N)
> - **DGDDI** : douane française (Roissy, Le Havre, Marseille...)

### Outils dématérialisés

| Outil | Usage |
|---|---|
| **DELTA G/H7** | Déclarations douanières FR |
| **NCTS** | Transit T1/T2 |
| **EMCS** | Accises (alcool/tabac/énergie) |
| **VIES** | Vérification n° TVA intracom |

> ⚠️ **Brexit — règle cruciale**
>
> UK est désormais **hors UE**. Toute opération UK ↔ UE nécessite :
> - DAU export FR (DELTA G)
> - Customs Declaration Service (CDS) côté UK
> - **Coût ~80-150 €** + délai 1-3 h en frontière
$lessonG3$,
'Distinguer les opérations intra-UE (DEB statistique) des opérations hors UE (DAU obligatoire), maîtriser les 4 régimes (EX export, IM import, T1 transit externe, T2 transit interne), mobiliser les bons acteurs (commissionnaire en douane, transitaire, DGDDI) et utiliser les outils dématérialisés (DELTA G/H7, NCTS, EMCS, VIES).'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Origine, valeur, INCOTERMS et contrôles
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Origine, valeur, INCOTERMS et contrôles douaniers',
    'origine-valeur-incoterms',
    4, 45,
$lessonG4$
# Origine, valeur, INCOTERMS et contrôles douaniers

> 🎯 **Objectifs pédagogiques**
>
> - **Distinguer** origine préférentielle et non-préférentielle.
> - **Calculer** la valeur en douane d'une marchandise.
> - **Appliquer** les 11 INCOTERMS 2020 (transport, assurance, douane).
> - **Lire** une facture commerciale et identifier le terme commercial.
> - **Anticiper** les contrôles douaniers et les sanctions possibles.

---

## Introduction

Trois éléments **chiffrés** déterminent les droits de douane à payer : l'**origine**, la **valeur**, et le **classement tarifaire** (code SH). Mais c'est l'**INCOTERM** qui décide qui paye, qui assure, qui dédouane — et qui supporte le risque pendant le transport.

Le **GOTRM** doit savoir, en lisant une facture :
- Identifier l'**INCOTERM** et ses implications.
- **Calculer** la valeur en douane (= base de taxation).
- **Repérer** un certificat d'origine valide.
- **Anticiper** les contrôles douaniers possibles.

Cette leçon clôt le module BC01-05 en vous donnant les **derniers leviers de pilotage** pour des opérations internationales conformes, optimisées et sécurisées.

---

## 1. Origine de la marchandise

### 1.1 Origine non-préférentielle vs préférentielle

| Type | Définition | Conséquence |
|---|---|---|
| **Non-préférentielle** | Origine selon règles communes (lieu fabrication / dernière transformation substantielle) | Droits de douane standard |
| **Préférentielle** | Origine UE OU pays signataire d'un accord de libre-échange | Droits réduits ou nuls |

### 1.2 Les accords préférentiels UE (sélection)

| Accord | Pays | Avantage |
|---|---|---|
| **UE-Maroc / Tunisie / Algérie** | Maghreb | Origine EUR-MED, droits réduits |
| **UE-Japon (JEPA)** | Japon | 99 % droits supprimés |
| **UE-Mercosur** | Argentine, Brésil, Uruguay, Paraguay | En cours de ratification |
| **UE-Royaume-Uni (TCA)** | UK | 0 % si origine UE/UK respectée |
| **UE-Suisse** | Suisse | EUR.1, droits réduits |
| **UE-Vietnam (EVFTA)** | Vietnam | Réduction progressive |

### 1.3 Les certificats d'origine

| Certificat | Usage | Délivré par |
|---|---|---|
| **EUR.1** | Accords classiques (Suisse, Norvège, Maroc...) | Bureau douane export |
| **EUR-MED** | Accords Pan-Euro-Méditerranée (origine cumulée) | Bureau douane export |
| **Certificat d'origine** (CO) | Pays sans accord, preuve fabrication | Chambres de commerce CCI |
| **Form A** | Pays SPG (système préférences généralisées) | Pays exportateur |
| **EUR.2** | Petits envois < 6 000 € | Auto-déclaration |

### 1.4 Cas pratique : pneus Michelin pour Maroc

Michelin produit en France ⇒ **origine UE**.
Accord UE-Maroc EUR-MED applicable ⇒ **droits réduits** au Maroc.
Sans EUR-MED, droits import standard ~30 % ⇒ avec EUR-MED **droits 0-5 %**.
**Certificat EUR-MED** délivré au bureau de douane export Clermont-Ferrand → **gain ~25 % sur valeur**.

---

## 2. Valeur en douane

### 2.1 Définition

La **valeur en douane** est la **base de calcul** des droits et taxes à l'importation. Elle est régie par le **Code des Douanes de l'Union (Règlement 952/2013)**, basé sur l'**accord OMC sur l'évaluation en douane (1994)**.

### 2.2 Méthodes d'évaluation (par ordre de priorité)

| Priorité | Méthode | Description |
|---|---|---|
| 1 | **Valeur transactionnelle** | Prix effectivement payé ou à payer pour la marchandise |
| 2 | **Marchandise identique** | Référence à transaction similaire récente |
| 3 | **Marchandise similaire** | Référence à transaction comparable |
| 4 | **Méthode déductive** | Prix de revente − marges habituelles |
| 5 | **Méthode du coût de revient** | Coût production + bénéfice raisonnable |
| 6 | **Méthode dite « du dernier ressort »** | Estimation raisonnable par douane |

**99 % des cas** : méthode 1 (valeur transactionnelle = prix facture).

### 2.3 Inclus dans la valeur en douane

✓ **Prix de la marchandise** (méthode 1).
✓ **Frais de transport et assurance** **jusqu'au lieu d'introduction UE** (selon INCOTERM).
✓ **Frais de chargement et manutention** au départ.
✓ **Royalties et licences** liées à la marchandise.
✓ **Coûts d'emballage** (sauf containers).

### 2.4 Exclus de la valeur en douane

✗ **Frais de transport et manutention** **après l'introduction** sur le territoire UE.
✗ **Droits et taxes UE** (ils sont calculés sur la valeur, pas inclus dans la base).
✗ **Frais de stockage** post-import.
✗ **Intérêts** sur paiement différé.

### 2.5 Cas pratique : valeur en douane Lille → Casablanca

**Données** :
- Marchandise valeur facturée : 50 000 € (INCOTERM CIF Casablanca).
- Frais transport Lille → Casablanca : 4 000 € (déjà inclus dans CIF).
- Frais assurance : 800 € (déjà inclus dans CIF).
- Frais manutention port Casablanca : 1 200 € (NON inclus dans CIF, à la charge de l'acheteur).

**Calcul valeur en douane Maroc à l'import** :
- Valeur transactionnelle CIF Casablanca = **50 000 €** (transport + assurance déjà inclus).
- Frais manutention post-import = **NON INCLUS** dans valeur en douane.
- **Valeur en douane = 50 000 €**.

**Si EXW Lille (départ usine, acheteur prend tout en charge)** :
- Valeur facturée = 50 000 € (uniquement marchandise).
- Frais transport Lille → port Casablanca à ajouter = 4 000 €.
- Frais assurance = 800 €.
- **Valeur en douane = 54 800 €**.

⇒ Le choix de l'INCOTERM influe sur la valeur en douane !

---

## 3. INCOTERMS 2020

### 3.1 Définition

Les **INCOTERMS** (International Commercial Terms) sont publiés par la **Chambre de Commerce Internationale (ICC)**. Version actuelle : **INCOTERMS 2020**, en vigueur depuis le 1er janvier 2020.

**11 termes** classés en **2 catégories** :
- **7 termes multimodaux** (route, mer, air, rail, fluvial).
- **4 termes maritimes purs** (mer ou fluvial uniquement).

### 3.2 Les 7 termes multimodaux

| Terme | Lieu | Description |
|---|---|---|
| **EXW** | Ex Works | Vendeur met à dispo dans son usine, acheteur prend tout en charge |
| **FCA** | Free Carrier | Vendeur livre au transporteur désigné par l'acheteur (lieu convenu) |
| **CPT** | Carriage Paid To | Vendeur paye transport jusqu'à destination, **risque transféré au 1er transporteur** |
| **CIP** | Carriage and Insurance Paid To | CPT + assurance jusqu'à destination |
| **DAP** | Delivered At Place | Vendeur livre prêt à décharger au lieu convenu |
| **DPU** | Delivered at Place Unloaded | Vendeur livre déchargé au lieu convenu |
| **DDP** | Delivered Duty Paid | Vendeur livre dédouané, taxes payées (formule la plus complète) |

### 3.3 Les 4 termes maritimes purs

| Terme | Lieu | Description |
|---|---|---|
| **FAS** | Free Alongside Ship | Marchandise sur quai au port d'embarquement |
| **FOB** | Free On Board | Marchandise à bord du navire (transfert risque dès rambarde) |
| **CFR** | Cost and Freight | Vendeur paye fret maritime jusqu'à destination |
| **CIF** | Cost, Insurance and Freight | CFR + assurance maritime |

### 3.4 Tableau comparatif INCOTERMS 2020

| INCOTERM | Transport principal | Assurance | Douane export | Douane import | Risque transféré |
|---|---|---|---|---|---|
| **EXW** | Acheteur | Acheteur | Acheteur | Acheteur | Usine vendeur |
| **FCA** | Acheteur | Acheteur | Vendeur | Acheteur | Lieu remise transporteur |
| **CPT** | **Vendeur** | Acheteur | Vendeur | Acheteur | 1er transporteur |
| **CIP** | **Vendeur** | **Vendeur** | Vendeur | Acheteur | 1er transporteur |
| **DAP** | **Vendeur** | Acheteur | Vendeur | Acheteur | Lieu convenu |
| **DPU** | **Vendeur** | Acheteur | Vendeur | Acheteur | Lieu déchargé |
| **DDP** | **Vendeur** | **Vendeur** | Vendeur | **Vendeur** | Lieu livraison |
| **FAS** | Acheteur | Acheteur | Vendeur | Acheteur | Quai port embarquement |
| **FOB** | Acheteur | Acheteur | Vendeur | Acheteur | À bord du navire |
| **CFR** | **Vendeur** | Acheteur | Vendeur | Acheteur | À bord du navire |
| **CIF** | **Vendeur** | **Vendeur** | Vendeur | Acheteur | À bord du navire |

### 3.5 INCOTERM et risque vs coût : 2 notions distinctes

⚠️ Erreur fréquente : confondre **transfert des risques** et **transfert des coûts**.

**Exemple CPT Berlin** :
- Vendeur **paye** le transport jusqu'à Berlin.
- Mais **risque transféré dès que le 1er transporteur prend la marchandise** (au départ usine vendeur).
- Si avarie en route Paris-Berlin : c'est l'**acheteur** qui supporte le risque, même si le vendeur a payé.
- L'acheteur doit donc souscrire son **propre assurance**.

### 3.6 Cas pratique : Lille → Casablanca CIP

**Données** : commande 50 000 €, INCOTERM **CIP Casablanca**.

**Qui supporte quoi ?**

| Élément | Vendeur | Acheteur |
|---|---|---|
| Coût transport Lille → port Sète | ✓ | |
| Coût ferry Sète → Tanger | ✓ | |
| Coût route Tanger → Casablanca | ✓ | |
| **Assurance transport** | ✓ | |
| Douane export France (DAU EX) | ✓ | |
| Douane import Maroc (DAU IM) | | ✓ |
| Droits et taxes Maroc | | ✓ |
| **Risque (avarie/perte)** | | ✓ (dès 1er transporteur) |

⚠️ **Le vendeur paye le transport et l'assurance mais ne supporte PAS le risque**. Si avarie en route, c'est l'**acheteur** qui se fait indemniser par l'assurance souscrite par le vendeur.

---

## 4. Contrôles douaniers et sanctions

### 4.1 Types de contrôles

| Contrôle | Description | Lieu |
|---|---|---|
| **Documentaire** | Vérification documents (DAU, factures) | Bureau de douane |
| **Physique partiel** | Ouverture de quelques colis | Frontière ou bureau |
| **Physique total** | Déchargement complet, inspection minutieuse | Bureau ou plateforme |
| **Scanner** | Inspection radioscopique | Frontière (camion / conteneur) |
| **Brigade volante** | Contrôle routier inopiné | Autoroute, péage, parking |

### 4.2 Critères de ciblage

La douane utilise des **algorithmes de risque** pour cibler :
- **Origine** (pays à risque : Asie, certains pays africains).
- **Valeur déclarée anormalement basse** vs valeur de marché.
- **Code SH** atypique vs nature marchandise.
- **Antécédents** du DO ou transitaire (fraudes passées).
- **Marchandises sensibles** : tabac, alcool, contrefaçon, ADR.

### 4.3 Conséquences d'un contrôle positif

Si la douane détecte une irrégularité :

| Niveau | Sanction | Exemple |
|---|---|---|
| **Régularisation** | Paiement différentiel droits + taxes | Erreur déclarative bonne foi |
| **Amende administrative** | 1-4 fois la valeur | Sous-évaluation marchandise |
| **Retenue marchandise** | Saisie en attente | Sécurisation enquête |
| **Confiscation** | Destruction ou vente aux enchères | Contrefaçon, contrebande |
| **Infraction pénale** | Tribunal correctionnel | Contrebande organisée, faux |

### 4.4 Cas pratique : Mauvaise valeur déclarée

**Énoncé** : Un transitaire déclare 20 000 € pour 100 sacs Louis Vuitton, valeur réelle 120 000 €. Détection lors d'un contrôle scanner Marseille.

**Sanction** :
- Régularisation droits + TVA : 100 000 × 22 % = 22 000 €.
- Amende administrative : **valeur fraude × 1 à 4** = 100 000 à 400 000 €.
- Saisie marchandise possible.
- Inscription au **fichier DGDDI** (signal pour futurs contrôles).
- Possible **infraction pénale** si répété (jusqu'à 10 ans prison).

---

## 5. Tracer la valeur déclarée pour éviter contestation

### 5.1 Bonnes pratiques

✓ **Facture commerciale claire** : prix unitaire, quantité, totaux, INCOTERM, devise.
✓ **Cohérence prix vs catalogue** public si disponible.
✓ **Justificatifs complets** : virements bancaires, contrats commerciaux.
✓ **Code SH précis** (8-10 chiffres).
✓ **Origine documentée** : EUR.1, EUR-MED, certificat CCI.

### 5.2 Astuces pro pour les transitaires

- **Pré-validation valeur** : pour les opérations sensibles, soumettre à la DGDDI un dossier de pré-validation (« décision contraignante en matière de valeur »).
- **Audit annuel** : faire auditer les pratiques de classement et valeur tous les 12-24 mois.
- **Veille tarifaire** : suivi des modifications du tarif douanier UE (TARIC) trimestriellement.

---

## 6. Cas pratique d'examen

**Énoncé** : Vous gérez le transport de **50 conteneurs de meubles IKEA** de **Shanghai** vers **Le Havre** puis vers **Lyon** chez votre client BUT (DO).

**Données** :
- Valeur facturée IKEA → BUT : 800 000 € **CIF Le Havre**.
- Frais transbordement Le Havre : 25 000 €.
- Frais transport Le Havre → Lyon : 18 000 €.
- Origine : Chine, code SH 9403.
- Droit de douane UE pour meubles : **2,7 %**.
- TVA UE : 20 %.

**Questions :**
1. Quel régime douanier appliquer à l'arrivée Le Havre ?
2. Calculer la valeur en douane.
3. Calculer les droits et taxes dus.
4. Qui paye quoi selon l'INCOTERM CIF ?

**Correction :**

1. **Régime** : **IM4** (mise en libre pratique + mise à la consommation), traitement DELTA G + paiement droits/TVA. Possibilité de **régime entrepôt** (suspension droits) si pas de revente immédiate.

2. **Valeur en douane** :
   - CIF Le Havre = 800 000 € (transport + assurance jusqu'au Havre déjà inclus).
   - Frais Le Havre → Lyon = **NON inclus** (post-import).
   - **Valeur en douane = 800 000 €**.

3. **Droits et taxes** :
   - Droits de douane : 800 000 × 2,7 % = **21 600 €**.
   - Base TVA = 800 000 + 21 600 = 821 600 €.
   - TVA : 821 600 × 20 % = **164 320 €**.
   - **Total droits + TVA = 185 920 €**.

4. **Qui paye selon CIF** :
   - **IKEA (vendeur)** : transport Shanghai → Le Havre + assurance + douane export Chine.
   - **BUT (acheteur, DO)** : douane import Le Havre + droits 21 600 € + TVA 164 320 € + transport Le Havre → Lyon (18 000 €) + frais transbordement (25 000 €).
   - **Risque transféré** dès embarquement Shanghai (FOB-like en CIF) ⇒ si avarie en mer, c'est BUT qui réclame à l'assurance maritime souscrite par IKEA.

---

## 7. Mini-exercice à faire seul

**Énoncé** : Vous facturez un client allemand pour 4 palettes de produits cosmétiques (valeur 28 000 €) en INCOTERM **DDP Munich**. Le coût total transport + douane + TVA Allemagne = 6 500 €.

**Questions :**
1. Quelle marge avez-vous prévue ? (Dites comment intégrer cela dans votre prix de vente.)
2. Qui souscrit l'assurance ?
3. À quel moment le risque est-il transféré ?

> 💡 Réponse en fin de module (corrections § 4).

---

## 8. Glossaire

- **Origine non-préférentielle** : règles communes (fabrication / transformation substantielle).
- **Origine préférentielle** : pays partenaire d'un accord libre-échange UE.
- **EUR.1, EUR-MED** : certificats d'origine préférentielle.
- **Valeur en douane** : base de calcul droits/taxes (typiquement valeur transactionnelle).
- **INCOTERM** : terme commercial international ICC (11 termes en 2020).
- **EXW** : Ex Works (départ usine, acheteur prend tout).
- **FCA, CPT, CIP, DAP, DPU, DDP** : termes multimodaux.
- **FAS, FOB, CFR, CIF** : termes maritimes purs.
- **TARIC** : tarif douanier intégré UE (codes SH + droits).
- **Code SH** : Système Harmonisé OMC, classement marchandises 6+2 chiffres.
- **Décision contraignante valeur** : pré-validation DGDDI (sécurité juridique).

---

## 9. Synthèse opérationnelle

1. **Origine** : préférentielle (accord) ou non. Certificats EUR.1, EUR-MED, Form A, CO.
2. **Valeur en douane** = valeur transactionnelle + transport jusqu'au lieu d'introduction UE.
3. **INCOTERMS 2020** : **11 termes**, 7 multimodaux + 4 maritimes purs.
4. **Distinction risque/coût** : CPT/CIP transfèrent risque dès 1er transporteur.
5. **DDP** = formule la plus complète, vendeur prend tout en charge.
6. **EXW** = formule minimale vendeur, acheteur prend tout.
7. **Contrôles douaniers** : ciblage par algorithme + brigades volantes.
8. **Sanctions** : régularisation, amende 1-4× valeur, saisie, pénal.

---

## ⚠️ Points de vigilance

- **Ne pas confondre transfert risque et transfert coût** : CPT vendeur paye, mais risque acheteur.
- **Valeur sous-déclarée** : amende 1 à 4 fois la valeur de la fraude + pénal.
- **EUR.1 / EUR-MED** : à demander **AVANT** sortie marchandise (impossible a posteriori).
- **DDP** : engagement très lourd côté vendeur, à manier avec précaution.
- **Contrôle scanner** : tout véhicule peut être scanné en frontière (3-15 % du trafic).

## 💡 Astuces pro

- **Calculatrice INCOTERMS** : plusieurs apps (ICC, transitaires) calculent automatiquement coûts/risques selon le terme choisi.
- **Veille TARIC** : module gratuit DGDDI, alerte par mail des modifications de droits.
- **Pré-validation douane** : pour gros volumes/valeurs récurrents, demander une « décision contraignante » à la DGDDI = sécurité juridique 3 ans.
- **Audit valeur annuel** : faire valider par cabinet externe (PwC, KPMG, Mazars) les pratiques de classement et valeur — coût 5-15 k€, économies potentielles 50-200 k€/an.

---

## 10. Corrections des mini-exercices du module

### Leçon 1 — Bonnafé livraison Carrefour Lyon

**Documents à mobiliser (4)** :
1. Lettre de voiture nationale.
2. Bordereau de livraison + réserves écrites.
3. Enregistrement ATP du véhicule (sondes température).
4. Photos des palettes litigieuses + emballages gonflés.

**Rédaction des réserves type** : « 14 mai 2026, 6h00 — réception 18 palettes produits frais. Sonde ATP affiche 7°C depuis 2h (selon enregistrement). 4 palettes de yaourts présentent emballages gonflés. Photos prises (n°1-12). Réserves émises sur palettes 3, 7, 11, 15. Refus de réception palette 11 (yaourts visiblement compromis). »

**Actions immédiates** :
- Conducteur : ne pas livrer palette 11, photographier, appeler exploitation.
- Exploitation : récupérer enregistrement ATP, archiver, mailer DO sous 30 min.
- Exploitation : déclencher procédure assurance ATP (rupture chaîne du froid).
- LRAR sous 3 j à transporteur (avarie apparente).

### Leçon 2 — Lille → Saint-Pétersbourg

**Documents transport** :
- Récépissé PEC Lille.
- **CMR n° 1** : Lille → frontière polonaise (UE).
- **CMR n° 2** : Pologne → Russie (avec passage Biélorussie).
- BL final signé Saint-Pétersbourg.

**Documents douaniers** :
- DAU EX (export UE) côté FR ou frontière PL.
- DAU IM Russie (par transitaire local).
- Facture commerciale + packing list.
- Certificat d'origine **non-préférentiel** (pas d'accord UE-Russie).
- Facture en devise USD ou EUR selon contrat.

**Carnet TIR** :
- **OUI nécessaire** : transit Biélorussie (hors UE) puis Russie (hors UE).
- Émission par FNTR France, garantie 50 000 €.
- Plombage douane PL avant entrée Biélorussie.
- Apurement bureau Saint-Pétersbourg.

### Leçon 3 — Bordeaux → Bratislava via Suisse

1. **T2 nécessaire** : marchandise UE qui traverse pays tiers (CH). Le T2 préserve le statut UE et évite re-import à l'arrivée Autriche.

2. **Frontière FR-CH** :
   - DAU EX (sortie UE temporaire).
   - **T2 émis** au bureau de douane FR (Annecy) avec garantie.
   - Plombage véhicule, MRN T2 enregistré.

3. **Frontière CH-AT puis AT-SK** :
   - Sortie CH : visa T2 par douane suisse.
   - Entrée AT (UE) : **apurement T2** au bureau autrichien → marchandise statut UE confirmée.
   - AT → SK : intra-UE, pas de formalité.

### Leçon 4 — DDP Munich, marge sur prix de vente

1. **Marge à intégrer** :
   - Coût transport + douane + TVA = 6 500 €.
   - Si marge cible 18 % : (28 000 + 6 500) / 0,82 = **42 073 €** prix de vente.
   - Marge brute = 42 073 − 28 000 − 6 500 = **7 573 €** (18 %).

2. **Assurance** : **vendeur** souscrit (DDP = couverture complète).

3. **Risque transféré** : à la **livraison effective Munich**, déchargement effectué. Avant, c'est le vendeur qui supporte tous les risques (vol, avarie, perte).

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : INCOTERMS 2020, accords libre-échange, valeur en douane, certificats origine.
- **QR cas pratique** : « Pour CIP Casablanca, qui paye, qui assure, qui dédouane ? »
- **Oral DP** : « Citez 3 INCOTERMS et expliquez la différence de risque. »

---

## 📌 Synthèse à retenir

### Origine et certificats

| Certificat | Pays | Effet |
|---|---|---|
| **EUR.1** | Suisse, Norvège, Maroc... | Droits réduits |
| **EUR-MED** | Pan-Euro-Méd | Cumul d'origine |
| **Form A** | Pays SPG | Préférences |
| **CO (CCI)** | Pays sans accord | Preuve fabrication |

### Valeur en douane

> 📌 **Méthode 1 (99 % des cas)** = valeur transactionnelle (prix payé)
>
> **+ inclus** : transport jusqu'au lieu d'introduction UE, assurance, manutention départ
> **− exclus** : transport post-import UE, droits/taxes UE, intérêts paiement différé

### INCOTERMS 2020 — qui paye / qui supporte le risque

| INCOTERM | Vendeur paye | Acheteur paye | Risque transféré |
|---|---|---|---|
| **EXW** | Rien | Tout | À l'usine vendeur |
| **FCA** | Douane export | Transport + import | Remise transporteur |
| **CPT** | Transport principal | Import | **1er transporteur** ⚠️ |
| **CIP** | Transport + assurance | Import | **1er transporteur** ⚠️ |
| **DAP** | Transport principal | Import | Lieu convenu |
| **DPU** | Transport + déchargement | Import | Lieu déchargé |
| **DDP** | **TOUT** | Rien | Lieu livraison |
| **FAS** | Quai port | Tout après | Quai embarquement |
| **FOB** | À bord | Tout après | À bord (rambarde) |
| **CFR** | Fret maritime | Import | À bord (rambarde) |
| **CIF** | Fret + assurance | Import | À bord (rambarde) |

### Contrôles douaniers — sanctions

| Niveau | Sanction |
|---|---|
| **Régularisation** | Paiement différentiel |
| **Amende** | **1 à 4 fois** la valeur |
| **Saisie** | Retenue marchandise |
| **Confiscation** | Destruction / vente |
| **Pénal** | Prison + amende |

> ⚠️ **Erreur fatale à éviter**
>
> **Confondre transfert de risque et transfert de coût** dans CPT/CIP.
>
> Vendeur **paye** transport mais **risque transféré dès 1er transporteur**. L'acheteur doit souscrire sa propre assurance (sauf CIP où vendeur souscrit assurance minimale).

> 📌 **Règle des 3 leviers du dédouanement**
>
> 1. **Origine** (pays + accord) → détermine le taux de droit
> 2. **Valeur** (transactionnelle) → détermine la base
> 3. **Code SH** (8-10 chiffres) → détermine le taux applicable
>
> Erreur sur l'un des 3 = sous-évaluation = amende 1 à 4× valeur fraude.
$lessonG4$,
'Distinguer origine préférentielle (EUR.1/EUR-MED) et non-préférentielle, calculer la valeur en douane (méthode 1 transactionnelle), appliquer les 11 INCOTERMS 2020 (7 multimodaux EXW/FCA/CPT/CIP/DAP/DPU/DDP + 4 maritimes FAS/FOB/CFR/CIF), distinguer transfert de risque vs coût et anticiper les contrôles douaniers (1-4× valeur en sanction).'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- BANQUE DE QUESTIONS — 48 QCM + 8 QR
  -- =================================================================

  -- ===== LEÇON 1 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'La lettre de voiture nationale comporte combien d''exemplaires ?',
   '[{"id":"a","label":"2","is_correct":false},{"id":"b","label":"3","is_correct":false},{"id":"c","label":"4","is_correct":true},{"id":"d","label":"5","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-05','lecon-1','lettre-voiture'], 'mft-2026-gotrm:bc01-05-v3:l1:q1', true,
   '4 exemplaires : blanc (expéditeur), rose (transporteur exploitation), vert (destinataire), jaune (transporteur archives 5 ans).'),
  (v_formation, v_module, 'qcm', 'Les mentions obligatoires de la lettre de voiture sont fixées par :',
   '[{"id":"a","label":"L''article L. 1432-3 C. transports","is_correct":true},{"id":"b","label":"Le Code civil","is_correct":false},{"id":"c","label":"La Convention CMR","is_correct":false},{"id":"d","label":"Le règlement européen 952/2013","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-05','lecon-1','mentions'], 'mft-2026-gotrm:bc01-05-v3:l1:q2', true,
   'Article L. 1432-3 du Code des transports fixe les 11 mentions obligatoires (date, parties, lieux/dates, marchandise, poids, prix, instructions).'),
  (v_formation, v_module, 'qcm', 'Le délai de réclamation pour une avarie apparente est de :',
   '[{"id":"a","label":"24 heures","is_correct":false},{"id":"b","label":"3 jours","is_correct":true},{"id":"c","label":"7 jours","is_correct":false},{"id":"d","label":"30 jours","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-05','lecon-1','reserves'], 'mft-2026-gotrm:bc01-05-v3:l1:q3', true,
   'Avarie apparente : 3 jours par LRAR (art. L. 133-3 C. com.). Au-delà = forclusion.'),
  (v_formation, v_module, 'qcm', 'Le délai de réclamation pour une avarie cachée est de :',
   '[{"id":"a","label":"3 jours","is_correct":false},{"id":"b","label":"7 jours","is_correct":true},{"id":"c","label":"15 jours","is_correct":false},{"id":"d","label":"1 mois","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-05','lecon-1','reserves'], 'mft-2026-gotrm:bc01-05-v3:l1:q4', true,
   'Avarie cachée : 7 jours par LRAR. Au-delà = perte du droit à indemnité (forclusion).'),
  (v_formation, v_module, 'qcm', 'Une réserve « marchandise reçue sous réserves » sans précision est :',
   '[{"id":"a","label":"Pleinement valable","is_correct":false},{"id":"b","label":"Non recevable juridiquement","is_correct":true},{"id":"c","label":"Valable seulement en B2C","is_correct":false},{"id":"d","label":"Valable si signée du conducteur","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-05','lecon-1','reserves'], 'mft-2026-gotrm:bc01-05-v3:l1:q5', true,
   'Une réserve doit être précise, motivée, datée et chiffrée. La mention générale « sous réserves » n''est pas recevable juridiquement.'),
  (v_formation, v_module, 'qcm', 'Le BSD (Bordereau de Suivi des Déchets) est obligatoire pour :',
   '[{"id":"a","label":"Tout transport","is_correct":false},{"id":"b","label":"Les transports de déchets professionnels","is_correct":true},{"id":"c","label":"Uniquement les déchets dangereux","is_correct":false},{"id":"d","label":"Les transports en convoi exceptionnel","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-05','lecon-1','bsd'], 'mft-2026-gotrm:bc01-05-v3:l1:q6', true,
   'BSD obligatoire pour tous les déchets professionnels (DIB, DEEE, DASRI, dangereux). Dématérialisation Trackdéchets depuis 2022.'),
  (v_formation, v_module, 'qcm', 'Le règlement européen sur la signature électronique s''appelle :',
   '[{"id":"a","label":"GDPR","is_correct":false},{"id":"b","label":"eIDAS","is_correct":true},{"id":"c","label":"PSD2","is_correct":false},{"id":"d","label":"NIS2","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-05','lecon-1','signature'], 'mft-2026-gotrm:bc01-05-v3:l1:q7', true,
   'eIDAS (electronic IDentification, Authentication and trust Services) — règlement UE 2014/910 sur la signature électronique.'),
  (v_formation, v_module, 'qcm', 'Le niveau de signature électronique équivalent à une signature manuscrite est :',
   '[{"id":"a","label":"Simple","is_correct":false},{"id":"b","label":"Avancée","is_correct":false},{"id":"c","label":"Qualifiée","is_correct":true},{"id":"d","label":"Numérique","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-05','lecon-1','signature'], 'mft-2026-gotrm:bc01-05-v3:l1:q8', true,
   'eIDAS : signature qualifiée (certificat délivré par PSCo) = équivalent juridique d''une signature manuscrite.'),
  (v_formation, v_module, 'qcm', 'Le récépissé de prise en charge est obligatoire pour :',
   '[{"id":"a","label":"Tout transport national","is_correct":false},{"id":"b","label":"Les commissionnaires de transport","is_correct":true},{"id":"c","label":"Uniquement les TLM ≤ 3,5 T","is_correct":false},{"id":"d","label":"Les transports de moins de 100 km","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-05','lecon-1','recepisse'], 'mft-2026-gotrm:bc01-05-v3:l1:q9', true,
   'Art. R. 1411-12 C. transports : récépissé obligatoire pour le commissionnaire. Pour le transporteur, la lettre de voiture fait foi.'),
  (v_formation, v_module, 'qcm', 'En cas de refus de signature du BL par le destinataire, le conducteur doit :',
   '[{"id":"a","label":"Forcer la livraison","is_correct":false},{"id":"b","label":"Photographier, demander un écrit, appeler exploitation","is_correct":true},{"id":"c","label":"Abandonner la marchandise sur place","is_correct":false},{"id":"d","label":"Signer à la place du destinataire","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-05','lecon-1','refus'], 'mft-2026-gotrm:bc01-05-v3:l1:q10', true,
   'Procédure : photographier les palettes, demander écrit motivé du destinataire, appeler exploitation, émettre un PV de carence si refus total.'),
  (v_formation, v_module, 'qcm', 'L''archivage légal des documents de transport est de :',
   '[{"id":"a","label":"1 an","is_correct":false},{"id":"b","label":"3 ans","is_correct":false},{"id":"c","label":"5 ans","is_correct":true},{"id":"d","label":"10 ans","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-05','lecon-1','archivage'], 'mft-2026-gotrm:bc01-05-v3:l1:q11', true,
   'Article L. 123-22 C. com. : archivage 5 ans des documents commerciaux et de transport. Cloud sécurisé conforme RGPD.'),
  (v_formation, v_module, 'qcm', 'Les modèles standard de lettre de voiture sont publiés par :',
   '[{"id":"a","label":"L''Etat français","is_correct":false},{"id":"b","label":"FNTR et OTRE","is_correct":true},{"id":"c","label":"Le tribunal de commerce","is_correct":false},{"id":"d","label":"L''ICC","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-05','lecon-1','fntr'], 'mft-2026-gotrm:bc01-05-v3:l1:q12', true,
   'FNTR (Fédération Nationale des Transports Routiers) et OTRE (Organisation des Transporteurs Routiers Européens) publient les modèles standard à jour.');

  -- ===== LEÇON 2 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'La Convention CMR a été signée à :',
   '[{"id":"a","label":"Genève en 1956","is_correct":true},{"id":"b","label":"Bruxelles en 1924","is_correct":false},{"id":"c","label":"Montréal en 1999","is_correct":false},{"id":"d","label":"Vienne en 1968","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-05','lecon-2','cmr'], 'mft-2026-gotrm:bc01-05-v3:l2:q1', true,
   'Convention de Genève du 19 mai 1956 : transport routier international de marchandises. 56 pays signataires (UE + UK + Suisse + Russie + Maroc + Turquie...).'),
  (v_formation, v_module, 'qcm', 'Le document CMR comporte combien d''exemplaires obligatoires ?',
   '[{"id":"a","label":"2","is_correct":false},{"id":"b","label":"3","is_correct":true},{"id":"c","label":"4","is_correct":false},{"id":"d","label":"5","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-05','lecon-2','cmr'], 'mft-2026-gotrm:bc01-05-v3:l2:q2', true,
   '3 exemplaires (art. 5 CMR) : rouge (expéditeur), bleu (transporteur), vert (destinataire). 4e exemplaire jaune optionnel pour la douane.'),
  (v_formation, v_module, 'qcm', 'Le plafond d''indemnité CMR est de :',
   '[{"id":"a","label":"5 DTS/kg","is_correct":false},{"id":"b","label":"8,33 DTS/kg ≈ 10,80 €/kg","is_correct":true},{"id":"c","label":"22 DTS/kg","is_correct":false},{"id":"d","label":"50 DTS/kg","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-05','lecon-2','plafond-cmr'], 'mft-2026-gotrm:bc01-05-v3:l2:q3', true,
   'Plafond CMR : 8,33 DTS/kg, soit ≈ 10,80 €/kg en 2026. Plus restrictif que le contrat-type français (14 €/kg).'),
  (v_formation, v_module, 'qcm', 'Les mentions obligatoires CMR sont fixées par :',
   '[{"id":"a","label":"L''article 6 de la Convention","is_correct":true},{"id":"b","label":"Le Code des transports","is_correct":false},{"id":"c","label":"L''ICC","is_correct":false},{"id":"d","label":"L''IATA","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-05','lecon-2','cmr-art6'], 'mft-2026-gotrm:bc01-05-v3:l2:q4', true,
   'Article 6 de la Convention CMR : 12 mentions obligatoires (lieu/date émission, parties, lieux/dates, marchandise, frais, instructions douanières, indication CMR).'),
  (v_formation, v_module, 'qcm', 'Le BL maritime est unique par sa :',
   '[{"id":"a","label":"Couleur","is_correct":false},{"id":"b","label":"Négociabilité par endossement","is_correct":true},{"id":"c","label":"Gratuité","is_correct":false},{"id":"d","label":"Validité 5 ans","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-05','lecon-2','bl'], 'mft-2026-gotrm:bc01-05-v3:l2:q5', true,
   'Le BL maritime est négociable par endossement (transfert propriété). Permet revente marchandise en cours de transport.'),
  (v_formation, v_module, 'qcm', 'L''AWB (Air Waybill) est :',
   '[{"id":"a","label":"Négociable","is_correct":false},{"id":"b","label":"Non-négociable","is_correct":true},{"id":"c","label":"Optionnel","is_correct":false},{"id":"d","label":"Délivré par la douane","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-05','lecon-2','awb'], 'mft-2026-gotrm:bc01-05-v3:l2:q6', true,
   'AWB nominatif au destinataire (Convention de Montréal 1999), 11 chiffres IATA. Différence majeure avec le BL maritime qui est négociable.'),
  (v_formation, v_module, 'qcm', 'Le plafond Convention de Montréal pour le transport aérien est de :',
   '[{"id":"a","label":"8,33 DTS/kg","is_correct":false},{"id":"b","label":"22 DTS/kg ≈ 28,60 €/kg","is_correct":true},{"id":"c","label":"50 DTS/kg","is_correct":false},{"id":"d","label":"Sans plafond","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-05','lecon-2','montreal'], 'mft-2026-gotrm:bc01-05-v3:l2:q7', true,
   'Convention de Montréal 1999 : 22 DTS/kg ≈ 28,60 €/kg. Plus élevé que CMR car marchandises aériennes haute valeur.'),
  (v_formation, v_module, 'qcm', 'Le carnet TIR est utilisé pour :',
   '[{"id":"a","label":"Les transports intra-UE","is_correct":false},{"id":"b","label":"Les transits hors UE avec scellage douanier","is_correct":true},{"id":"c","label":"Les transports aériens","is_correct":false},{"id":"d","label":"Les déchets industriels","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-05','lecon-2','tir'], 'mft-2026-gotrm:bc01-05-v3:l2:q8', true,
   'Carnet TIR (Convention 1975) : scellement douanier permettant traversée de plusieurs frontières hors UE (Russie, Maroc, Turquie...) sans inspection à chaque frontière.'),
  (v_formation, v_module, 'qcm', 'La garantie financière d''un carnet TIR est de :',
   '[{"id":"a","label":"10 000 €","is_correct":false},{"id":"b","label":"50 000 €","is_correct":true},{"id":"c","label":"100 000 €","is_correct":false},{"id":"d","label":"500 000 €","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-05','lecon-2','tir-garantie'], 'mft-2026-gotrm:bc01-05-v3:l2:q9', true,
   'Garantie financière TIR : 50 000 € par carnet, fournie par la fédération émettrice (FNTR pour la France). Couvre droits douaniers en cas de perte ou fraude.'),
  (v_formation, v_module, 'qcm', 'En cas de transport multimodal route + mer + route, on utilise :',
   '[{"id":"a","label":"Une seule CMR","is_correct":false},{"id":"b","label":"Une cascade : CMR + BL + CMR","is_correct":true},{"id":"c","label":"Uniquement le BL","is_correct":false},{"id":"d","label":"Uniquement l''AWB","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-05','lecon-2','multimodal'], 'mft-2026-gotrm:bc01-05-v3:l2:q10', true,
   'Cascade documentaire : 1 CMR par segment routier + 1 BL pour le segment maritime. Possibilité d''une CMR multimodale unique si transporteur unique couvre toute la chaîne.'),
  (v_formation, v_module, 'qcm', 'Le contre-pesage gratuit en CMR est prévu par :',
   '[{"id":"a","label":"L''article 8.3 de la Convention","is_correct":true},{"id":"b","label":"Le Code des douanes","is_correct":false},{"id":"c","label":"Le Code civil","is_correct":false},{"id":"d","label":"Le Code des transports","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-05','lecon-2','contre-pesage'], 'mft-2026-gotrm:bc01-05-v3:l2:q11', true,
   'Article 8.3 CMR : si le transporteur conteste le poids déclaré, l''expéditeur doit fournir une bascule au chargement. Sans cela, pas de contestation possible après coup.'),
  (v_formation, v_module, 'qcm', 'Le transport ferroviaire international utilise :',
   '[{"id":"a","label":"La CMR","is_correct":false},{"id":"b","label":"La lettre de voiture CIM","is_correct":true},{"id":"c","label":"Le BL maritime","is_correct":false},{"id":"d","label":"L''AWB","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-05','lecon-2','cim'], 'mft-2026-gotrm:bc01-05-v3:l2:q12', true,
   'CIM (Convention internationale concernant le transport des marchandises par chemin de fer) : lettre de voiture spécifique au rail. CMR pour la route uniquement.');

  -- ===== LEÇON 3 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'Pour un transport Paris → Berlin, quelles formalités douanières ?',
   '[{"id":"a","label":"DAU EX + DAU IM","is_correct":false},{"id":"b","label":"Aucune (intra-UE)","is_correct":true},{"id":"c","label":"Carnet TIR","is_correct":false},{"id":"d","label":"T1 obligatoire","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-05','lecon-3','intra-ue'], 'mft-2026-gotrm:bc01-05-v3:l3:q1', true,
   'France et Allemagne sont membres UE = libre circulation, pas de douane. Seule obligation : DEB statistique mensuelle si > 460 k€/an.'),
  (v_formation, v_module, 'qcm', 'Le DAU est :',
   '[{"id":"a","label":"Une carte bancaire","is_correct":false},{"id":"b","label":"Le Document Administratif Unique douanier","is_correct":true},{"id":"c","label":"Un certificat d''origine","is_correct":false},{"id":"d","label":"Une lettre de voiture","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-05','lecon-3','dau'], 'mft-2026-gotrm:bc01-05-v3:l3:q2', true,
   'DAU = Document Administratif Unique, formulaire douanier européen. Régi par le Règlement UE 952/2013 (Code des Douanes de l''Union).'),
  (v_formation, v_module, 'qcm', 'Le régime T1 concerne :',
   '[{"id":"a","label":"Les marchandises UE en transit interne","is_correct":false},{"id":"b","label":"Les marchandises non-UE en circulation dans UE","is_correct":true},{"id":"c","label":"Les exports finaux","is_correct":false},{"id":"d","label":"Les imports finaux","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-05','lecon-3','t1'], 'mft-2026-gotrm:bc01-05-v3:l3:q3', true,
   'T1 = transit externe : marchandise non-UE qui circule dans UE en attente de dédouanement (ex. import chinois Le Havre → Munich avant IM4).'),
  (v_formation, v_module, 'qcm', 'Le régime T2 concerne :',
   '[{"id":"a","label":"Les marchandises non-UE","is_correct":false},{"id":"b","label":"Les marchandises UE traversant un pays tiers","is_correct":true},{"id":"c","label":"Les exports temporaires","is_correct":false},{"id":"d","label":"Les imports avec entrepôt","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-05','lecon-3','t2'], 'mft-2026-gotrm:bc01-05-v3:l3:q4', true,
   'T2 = transit interne : marchandise UE qui traverse un pays tiers (Suisse) en conservant son statut UE. Ex. Lyon → Vienne via Suisse.'),
  (v_formation, v_module, 'qcm', 'Depuis le Brexit (2021), pour Paris → Londres il faut :',
   '[{"id":"a","label":"Aucune formalité","is_correct":false},{"id":"b","label":"DAU EX FR + import UK (CDS)","is_correct":true},{"id":"c","label":"Uniquement DEB","is_correct":false},{"id":"d","label":"Carnet TIR","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-05','lecon-3','brexit'], 'mft-2026-gotrm:bc01-05-v3:l3:q5', true,
   'Depuis 2021, UK hors UE. DAU export FR (DELTA G) + déclaration import UK via CDS (Customs Declaration Service). Coût ~80-150 €.'),
  (v_formation, v_module, 'qcm', 'Le MRN (Movement Reference Number) comporte :',
   '[{"id":"a","label":"6 caractères","is_correct":false},{"id":"b","label":"10 caractères","is_correct":false},{"id":"c","label":"18 caractères","is_correct":true},{"id":"d","label":"24 caractères","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-05','lecon-3','mrn'], 'mft-2026-gotrm:bc01-05-v3:l3:q6', true,
   'MRN = identifiant unique 18 caractères d''un DAU. À conserver précieusement, sert à l''apurement.'),
  (v_formation, v_module, 'qcm', 'La plateforme française de dédouanement dématérialisé est :',
   '[{"id":"a","label":"VIES","is_correct":false},{"id":"b","label":"DELTA G / DELTA H7","is_correct":true},{"id":"c","label":"NCTS","is_correct":false},{"id":"d","label":"TARIC","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-05','lecon-3','delta'], 'mft-2026-gotrm:bc01-05-v3:l3:q7', true,
   'DELTA G (Dédouanement en Ligne par Traitement Automatisé), modernisé en DELTA H7 depuis 2023. 16 millions de déclarations/an.'),
  (v_formation, v_module, 'qcm', 'Le seuil de la DEB (Déclaration d''Échanges de Biens) est de :',
   '[{"id":"a","label":"50 000 €/an","is_correct":false},{"id":"b","label":"460 000 €/an","is_correct":true},{"id":"c","label":"1 000 000 €/an","is_correct":false},{"id":"d","label":"Aucun seuil","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-05','lecon-3','deb'], 'mft-2026-gotrm:bc01-05-v3:l3:q8', true,
   'DEB obligatoire pour les échanges intra-UE > 460 000 €/an. Statistique + TVA. DES pour les services.'),
  (v_formation, v_module, 'qcm', 'Le commissionnaire en douane est agréé par :',
   '[{"id":"a","label":"L''ICC","is_correct":false},{"id":"b","label":"La DGDDI","is_correct":true},{"id":"c","label":"L''IATA","is_correct":false},{"id":"d","label":"La DREAL","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-05','lecon-3','ced'], 'mft-2026-gotrm:bc01-05-v3:l3:q9', true,
   'CED ou RDE agréé par la DGDDI (Direction Générale des Douanes et Droits Indirects). Profession réglementée (Code des Douanes art. 86-90).'),
  (v_formation, v_module, 'qcm', 'En transit T1, la garantie financière représente typiquement :',
   '[{"id":"a","label":"10 % de la valeur","is_correct":false},{"id":"b","label":"30 % des droits estimés","is_correct":true},{"id":"c","label":"50 % de la valeur","is_correct":false},{"id":"d","label":"100 % de la valeur","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-05','lecon-3','garantie-t1'], 'mft-2026-gotrm:bc01-05-v3:l3:q10', true,
   'Garantie NCTS T1 : ~30 % des droits estimés. Libérée à l''apurement (preuve d''arrivée au bureau de destination).'),
  (v_formation, v_module, 'qcm', 'Le BAE (Bon À Enlever) est :',
   '[{"id":"a","label":"Le bordereau de livraison","is_correct":false},{"id":"b","label":"L''autorisation finale d''enlèvement après import","is_correct":true},{"id":"c","label":"Un certificat d''origine","is_correct":false},{"id":"d","label":"Le carnet TIR","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-05','lecon-3','bae'], 'mft-2026-gotrm:bc01-05-v3:l3:q11', true,
   'BAE = Bon À Enlever, autorisation finale délivrée par la douane après import (IM4) et liquidation des droits/taxes.'),
  (v_formation, v_module, 'qcm', 'Confondre T1 et T2 peut entraîner :',
   '[{"id":"a","label":"Aucune conséquence","is_correct":false},{"id":"b","label":"Une saisie de marchandise","is_correct":true},{"id":"c","label":"Un avertissement seul","is_correct":false},{"id":"d","label":"Une réduction de TVA","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-05','lecon-3','confusion'], 'mft-2026-gotrm:bc01-05-v3:l3:q12', true,
   'Confusion T1/T2 = erreur déclarative grave. Risque : saisie marchandise + amende + retard 24-72h en frontière.');

  -- ===== LEÇON 4 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'Les INCOTERMS 2020 comptent :',
   '[{"id":"a","label":"7 termes","is_correct":false},{"id":"b","label":"11 termes","is_correct":true},{"id":"c","label":"13 termes","is_correct":false},{"id":"d","label":"15 termes","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-05','lecon-4','incoterms'], 'mft-2026-gotrm:bc01-05-v3:l4:q1', true,
   '11 INCOTERMS 2020 : 7 multimodaux (EXW, FCA, CPT, CIP, DAP, DPU, DDP) + 4 maritimes purs (FAS, FOB, CFR, CIF).'),
  (v_formation, v_module, 'qcm', 'L''INCOTERM EXW signifie :',
   '[{"id":"a","label":"Vendeur livre dédouané","is_correct":false},{"id":"b","label":"Vendeur met à dispo dans son usine, acheteur prend tout","is_correct":true},{"id":"c","label":"Vendeur paye transport","is_correct":false},{"id":"d","label":"Vendeur souscrit assurance","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-05','lecon-4','exw'], 'mft-2026-gotrm:bc01-05-v3:l4:q2', true,
   'EXW (Ex Works) = formule minimale vendeur. Acheteur prend tout : transport, assurance, douane export, douane import, risque.'),
  (v_formation, v_module, 'qcm', 'L''INCOTERM DDP signifie :',
   '[{"id":"a","label":"Vendeur prend tout en charge, formule la plus complète","is_correct":true},{"id":"b","label":"Acheteur prend tout","is_correct":false},{"id":"c","label":"Partage 50/50","is_correct":false},{"id":"d","label":"Sans assurance","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-05','lecon-4','ddp'], 'mft-2026-gotrm:bc01-05-v3:l4:q3', true,
   'DDP (Delivered Duty Paid) = formule maximale vendeur : transport, assurance, douane export ET import, taxes payées. Risque transféré à la livraison.'),
  (v_formation, v_module, 'qcm', 'Sous l''INCOTERM CIP, le risque est transféré :',
   '[{"id":"a","label":"À la livraison finale","is_correct":false},{"id":"b","label":"Au 1er transporteur","is_correct":true},{"id":"c","label":"Au déchargement","is_correct":false},{"id":"d","label":"À l''import douanier","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-05','lecon-4','cip'], 'mft-2026-gotrm:bc01-05-v3:l4:q4', true,
   'CIP (Carriage Insurance Paid) : vendeur paye transport + assurance, mais risque transféré dès remise au 1er transporteur. Erreur fréquente : confondre paiement et risque.'),
  (v_formation, v_module, 'qcm', 'Lequel n''est PAS un INCOTERM maritime pur ?',
   '[{"id":"a","label":"FAS","is_correct":false},{"id":"b","label":"FOB","is_correct":false},{"id":"c","label":"CFR","is_correct":false},{"id":"d","label":"DAP","is_correct":true}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-05','lecon-4','maritime'], 'mft-2026-gotrm:bc01-05-v3:l4:q5', true,
   'DAP est multimodal. Les 4 maritimes purs : FAS, FOB, CFR, CIF (utilisés mer/fluvial uniquement).'),
  (v_formation, v_module, 'qcm', 'Le certificat EUR-MED est utilisé pour :',
   '[{"id":"a","label":"Les transports rapides","is_correct":false},{"id":"b","label":"Les accords Pan-Euro-Méditerranée (UE-Maroc, etc.)","is_correct":true},{"id":"c","label":"Les marchandises périssables","is_correct":false},{"id":"d","label":"Les transports militaires","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-05','lecon-4','eur-med'], 'mft-2026-gotrm:bc01-05-v3:l4:q6', true,
   'EUR-MED = certificat d''origine pour accords Pan-Euro-Méditerranée. Permet le cumul d''origine entre UE, Maroc, Tunisie, Algérie, Turquie, etc.'),
  (v_formation, v_module, 'qcm', 'La méthode 1 d''évaluation de la valeur en douane est :',
   '[{"id":"a","label":"Méthode du coût","is_correct":false},{"id":"b","label":"Valeur transactionnelle (prix payé)","is_correct":true},{"id":"c","label":"Méthode déductive","is_correct":false},{"id":"d","label":"Estimation douane","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-05','lecon-4','valeur-douane'], 'mft-2026-gotrm:bc01-05-v3:l4:q7', true,
   'Méthode 1 (99 % des cas) = valeur transactionnelle = prix effectivement payé ou à payer. Inclut transport et assurance jusqu''au lieu d''introduction UE.'),
  (v_formation, v_module, 'qcm', 'Une amende douanière pour sous-évaluation peut atteindre :',
   '[{"id":"a","label":"100 € fixe","is_correct":false},{"id":"b","label":"1 à 4 fois la valeur de la fraude","is_correct":true},{"id":"c","label":"10 % de la valeur","is_correct":false},{"id":"d","label":"50 €/jour","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-05','lecon-4','amende'], 'mft-2026-gotrm:bc01-05-v3:l4:q8', true,
   'Sous-évaluation valeur en douane : amende administrative 1 à 4 fois la valeur de la fraude + saisie possible + infraction pénale en cas de récidive.'),
  (v_formation, v_module, 'qcm', 'L''accord UE-Royaume-Uni post-Brexit s''appelle :',
   '[{"id":"a","label":"BREXIT Agreement","is_correct":false},{"id":"b","label":"TCA (Trade and Cooperation Agreement)","is_correct":true},{"id":"c","label":"NAFTA","is_correct":false},{"id":"d","label":"Accord de Genève","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-05','lecon-4','tca'], 'mft-2026-gotrm:bc01-05-v3:l4:q9', true,
   'TCA (Trade and Cooperation Agreement) signé fin 2020, entré en vigueur 2021. 0 % droits si origine UE/UK respectée (mais formalités douanières maintenues).'),
  (v_formation, v_module, 'qcm', 'En INCOTERM FOB, le risque est transféré :',
   '[{"id":"a","label":"À l''usine","is_correct":false},{"id":"b","label":"Sur le quai port d''embarquement","is_correct":false},{"id":"c","label":"À bord du navire (rambarde)","is_correct":true},{"id":"d","label":"Au déchargement port destination","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-05','lecon-4','fob'], 'mft-2026-gotrm:bc01-05-v3:l4:q10', true,
   'FOB (Free On Board) = risque transféré quand la marchandise franchit la rambarde du navire au port d''embarquement.'),
  (v_formation, v_module, 'qcm', 'Le code SH (Système Harmonisé) classifie :',
   '[{"id":"a","label":"Les transporteurs","is_correct":false},{"id":"b","label":"Les marchandises selon nomenclature OMC","is_correct":true},{"id":"c","label":"Les véhicules","is_correct":false},{"id":"d","label":"Les pays","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-05','lecon-4','sh'], 'mft-2026-gotrm:bc01-05-v3:l4:q11', true,
   'Code SH = Système Harmonisé OMC, nomenclature internationale. 6 chiffres harmonisés mondiaux + 2-4 chiffres complémentaires UE (TARIC).'),
  (v_formation, v_module, 'qcm', 'Pour CIF Casablanca, qui paye la douane import au Maroc ?',
   '[{"id":"a","label":"Le vendeur","is_correct":false},{"id":"b","label":"L''acheteur","is_correct":true},{"id":"c","label":"50/50","is_correct":false},{"id":"d","label":"L''assureur","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-05','lecon-4','cif-douane'], 'mft-2026-gotrm:bc01-05-v3:l4:q12', true,
   'CIF (Cost Insurance Freight) : vendeur paye fret + assurance jusqu''au port destination, mais douane import à la charge de l''acheteur (sauf DDP qui inclut la douane import).');

  -- ===== 8 QR (cas pratiques métier, max_score 5-7) =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qr',
   'Au déchargement chez votre client GMS (Carrefour Lyon), le réceptionnaire constate à 6h du matin que 4 palettes sur 18 (yaourts) présentent des emballages gonflés et que la sonde ATP du véhicule a enregistré une rupture de chaîne du froid (passage à 7°C pendant 2h dans la nuit). Comment votre conducteur doit-il gérer cette situation ? Détaillez la procédure complète, la rédaction des réserves et l''archivage des preuves.',
   NULL, 6, 'moyen', ARRAY['gotrm','bc01-05','qr','reserves','reception'], 'mft-2026-gotrm:bc01-05-v3:qr1', true,
   'Procédure complète :\n\n1. **Au déchargement** : ne pas livrer les palettes 11, 14 (et autres litigieuses), photographier chaque palette + les emballages gonflés + la sonde ATP affichant 7°C.\n\n2. **Réserves écrites précises** sur le BL : « 14 mai 2026, 6h00 — réception 18 palettes produits frais. 4 palettes (n° 11, 14, 16, 17) présentent emballages gonflés. Enregistrement ATP montre passage à 7°C de 2h à 4h. Photos prises (n°1-12). Réserves émises sur ces 4 palettes. Refus de réception palette 11 (yaourts visiblement compromis). »\n\n3. **Appel exploitation** dans les 30 min : alerte du DO, blocage du transit, déclenchement procédure assurance.\n\n4. **Archivage des preuves** :\n   - Lettre de voiture signée + réserves\n   - Photos numérotées\n   - Enregistrement ATP exporté du véhicule\n   - Appel téléphonique tracé (CRM)\n   - LRAR sous 3 jours au transporteur (avarie apparente)\n\n5. **Documents à mobiliser** (4) : LV, BL avec réserves, enregistrement ATP, photos.'),

  (v_formation, v_module, 'qr',
   'Vous êtes commissionnaire de transport et organisez la livraison de 22 palettes de cosmétiques de L''Oréal Clichy vers Marrakech (Maroc) en route avec transbordement RoRo Sète-Tanger. Valeur 380 000 €, INCOTERM CIP Marrakech, accord UE-Maroc applicable. Détaillez la cascade documentaire complète à mobiliser, les formalités douanières et l''indemnité maximale CMR sur ce transport.',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-05','qr','multimodal','cmr'], 'mft-2026-gotrm:bc01-05-v3:qr2', true,
   'Cascade documentaire complète :\n\n1. **Récépissé PEC** Clichy émis par 1er transporteur routier.\n2. **CMR n° 1** : Clichy → Sète (segment routier France), 3 exemplaires.\n3. **DAU EX1** : déclaration export France à Sète, déposée par transitaire FR via DELTA G.\n4. **BL maritime** : Sète → Tanger, 3 originaux endossables.\n5. **DAU IM** Maroc : déclaration import par transitaire marocain à Tanger.\n6. **CMR n° 2** : Tanger → Marrakech (Maroc, signataire CMR).\n7. **BL livraison** Marrakech signé par destinataire.\n\nDocuments annexes :\n- Facture commerciale L''Oréal\n- Packing list (détail palette par palette)\n- **Certificat EUR-MED** (accord UE-Maroc, droits réduits 0-5 % au lieu de 30 %)\n- Liste des marchandises selon code SH cosmétiques (3304)\n\nPlafond CMR :\n- 22 palettes × 600 kg/palette estimés = ~13 200 kg poids brut.\n- Plafond CMR : 13 200 × 8,33 DTS × 1,30 €/DTS = **142 943 €**.\n- Préjudice non couvert : 380 000 − 142 943 = **237 057 €** à charge L''Oréal.\n\nRecommandation : déclaration de valeur écrite + assurance ad valorem souscrite par L''Oréal (CIP = vendeur souscrit assurance minimale, mais à compléter si valeur > plafond CMR).'),

  (v_formation, v_module, 'qr',
   'Comparez de façon détaillée le contrat-type général français (décret 99-269) et la Convention CMR pour un transport de marchandises. Pour quels transports chacun s''applique ? Quels sont les écarts en termes de plafonds d''indemnité, de réserves, de prescription ? Quelles sont les conséquences pratiques pour un GOTRM dans la rédaction des CGV transporteur ?',
   NULL, 6, 'difficile', ARRAY['gotrm','bc01-05','qr','contrat-type','cmr'], 'mft-2026-gotrm:bc01-05-v3:qr3', true,
   'Comparaison détaillée :\n\n**Contrat-type général (décret 99-269)** :\n- Champ : transports nationaux français, applicable d''office en l''absence de contrat.\n- Plafond : **14 €/kg poids brut** + **750 €/2 300 € par envoi** selon poids.\n- Réserves : précises et motivées sur BL ou LRAR < 3j (apparente) / 7j (cachée).\n- Prescription : **1 an** (art. L. 133-6 C. com.).\n- Doc obligatoire : aucun spécifique (LV recommandée).\n\n**Convention CMR (Genève 1956)** :\n- Champ : transports routiers internationaux entre 2 pays signataires (56 pays).\n- Plafond : **8,33 DTS/kg ≈ 10,80 €/kg** (plus restrictif que national).\n- Réserves : possibles (art. 8) « non vérifié » + contre-pesage gratuit (art. 8.3).\n- Prescription : **1 an** (3 ans en cas de dol ou faute lourde).\n- Doc obligatoire : **document CMR** en 3 exemplaires (rouge/bleu/vert).\n\nÉcarts majeurs :\n1. Plafond CMR plus bas (10,80 vs 14 €/kg) → impact en cas d''avarie.\n2. Document CMR obligatoire en international vs LV facultative en national.\n3. Réserves et procédure formalisées CMR vs souples national.\n\nConséquences pratiques pour un GOTRM (CGV) :\n- **Distinguer dans les CGV** les transports nationaux (CT général) et internationaux (CMR).\n- **Mentionner le régime CMR** dans les devis internationaux.\n- **Exiger le document CMR** signé pour chaque transport international.\n- **Prévoir la déclaration de valeur** systématique pour marchandises > 11 €/kg international (lever plafond CMR).\n- **Souscrire une RCCT** internationale 1,5 M€ minimum + ad valorem pour valeurs élevées.'),

  (v_formation, v_module, 'qr',
   'Vous organisez le transport de 30 palettes de jus de fruit (valeur 12 000 €) de Bordeaux vers Bratislava (Slovaquie) via Suisse (raccourci routier intéressant). Faut-il un T2 ? Détaillez les formalités douanières à chaque frontière (FR-CH, CH-AT, AT-SK), expliquez le rôle du T2 et les risques en cas d''oubli.',
   NULL, 6, 'difficile', ARRAY['gotrm','bc01-05','qr','t2','transit'], 'mft-2026-gotrm:bc01-05-v3:qr4', true,
   'Décision : **T2 nécessaire**.\n\nRaison : la marchandise UE doit traverser un pays tiers (Suisse), le T2 préserve son statut UE et évite un re-import à l''arrivée Autriche.\n\nFormalités étape par étape :\n\n1. **Frontière FR-CH (Bardonnex / Saint-Genis)** :\n   - DAU EX (sortie UE temporaire).\n   - **T2 émis** au bureau de douane FR (Annecy ou Genève) avec garantie financière.\n   - Plombage véhicule par douane FR.\n   - MRN T2 enregistré dans NCTS (Nouveau Système Computerisé de Transit).\n\n2. **Sortie CH-AT (Hohenems / Bregenz)** :\n   - Visa T2 par douane suisse (vérification plombs intacts).\n   - Sortie CH validée.\n\n3. **Entrée AT (UE)** :\n   - **Apurement T2** au bureau de douane autrichien.\n   - Marchandise statut UE confirmée.\n   - Garantie libérée.\n\n4. **AT → SK (Bratislava)** :\n   - Intra-UE = libre circulation, **AUCUNE FORMALITÉ**.\n\nRisques en cas d''oubli T2 :\n- À l''entrée AT, douane autrichienne considère la marchandise comme non-UE (vient de Suisse) → exige IM4 (import) avec droits + TVA = ~3 000 € de coûts inutiles.\n- À la sortie SK, problème car marchandise considérée comme importée → re-export complexe.\n- Retard 24-72h en frontière + amendes.\n\nRecommandation : transitaire spécialisé Suisse pour gestion T2 (~80-150 € de frais, économie 3 000 € en évitant double dédouanement).'),

  (v_formation, v_module, 'qr',
   'Un client vous vend 50 conteneurs de meubles IKEA de Shanghai vers Le Havre puis Lyon, valeur facturée 800 000 € en INCOTERM CIF Le Havre, frais transbordement Le Havre 25 000 €, frais transport Le Havre-Lyon 18 000 €, droits import UE meubles 2,7 %, TVA 20 %. Calculez la valeur en douane, les droits et taxes UE dus, et expliquez qui paye quoi selon le CIF.',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-05','qr','valeur-douane','cif'], 'mft-2026-gotrm:bc01-05-v3:qr5', true,
   'Calculs :\n\n**1. Valeur en douane** :\n- CIF Le Havre = 800 000 € (transport + assurance jusqu''au port d''introduction UE déjà inclus).\n- Frais transbordement Le Havre = à analyser : si effectués pendant le trajet maritime (chargement/déchargement port) → INCLUS dans CIF. Si effectués après l''introduction UE (post-douane) → EXCLUS.\n- Frais Le Havre → Lyon = **NON inclus** (post-introduction UE).\n- **Valeur en douane = 800 000 €**.\n\n**2. Droits et taxes** :\n- Droits de douane UE meubles 2,7 % : 800 000 × 2,7 % = **21 600 €**.\n- Base TVA = valeur en douane + droits = 800 000 + 21 600 = 821 600 €.\n- TVA 20 % : 821 600 × 20 % = **164 320 €**.\n- **Total droits + TVA = 185 920 €**.\n\n**3. Qui paye selon CIF** :\n- **IKEA (vendeur)** : transport Shanghai → Le Havre + assurance maritime + douane export Chine.\n- **BUT (acheteur, DO)** : douane import UE (DAU IM4) + droits 21 600 € + TVA 164 320 € + frais transbordement 25 000 € (à valider) + transport Le Havre → Lyon 18 000 €.\n- **Risque transféré dès embarquement Shanghai** (CIF = même règle que FOB pour le transfert de risque, à bord du navire).\n- Si avarie en mer : assurance maritime souscrite par IKEA mais bénéfice à BUT (réclamation par BUT à l''assureur).\n\n**4. Conseils** :\n- Régime entrepôt sous douane possible si pas de revente immédiate (suspension droits/TVA).\n- Mobiliser un transitaire Le Havre (Geodis, Bolloré) pour DAU IM4 + manutention port.\n- Coût total transitaire ~500 €.'),

  (v_formation, v_module, 'qr',
   'Vous êtes GOTRM et un client vous demande conseil sur le choix entre les INCOTERMS CPT, CIP, DAP et DDP pour un transport Lille → Casablanca de 50 000 € de cosmétiques. Comparez ces 4 termes en détaillant : qui paye le transport, qui souscrit l''assurance, qui dédouane à l''import, qui supporte le risque, et à quel moment. Recommandez le plus adapté selon le profil client (PME exportatrice débutante).',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-05','qr','incoterms','conseil'], 'mft-2026-gotrm:bc01-05-v3:qr6', true,
   'Comparaison détaillée des 4 INCOTERMS :\n\n**1. CPT (Carriage Paid To) Casablanca** :\n- Vendeur paye transport jusqu''à Casablanca.\n- Acheteur souscrit assurance.\n- Acheteur dédouane à l''import Maroc.\n- **Risque transféré au 1er transporteur** (dès Lille, attention !).\n- Acheteur supporte avaries en route.\n\n**2. CIP (Carriage Insurance Paid) Casablanca** :\n- Vendeur paye transport + assurance.\n- Acheteur dédouane à l''import.\n- **Risque transféré au 1er transporteur** (même règle que CPT).\n- Avarie en route → acheteur réclame à l''assureur souscrit par vendeur.\n- **Niveau d''assurance minimum (clause C ICC)** = couverture limitée.\n\n**3. DAP (Delivered At Place) Casablanca** :\n- Vendeur paye transport et assume risque jusqu''à Casablanca.\n- Acheteur dédouane à l''import.\n- Risque transféré à la livraison physique (pas déchargement).\n- Avarie en route → vendeur supporte.\n\n**4. DDP (Delivered Duty Paid) Casablanca** :\n- Vendeur prend TOUT en charge : transport, assurance, douane export ET import, taxes payées au Maroc.\n- Acheteur ne fait rien.\n- Risque transféré uniquement à la livraison.\n- Vendeur paye droits import (~30 % au Maroc) + TVA Maroc (20 %).\n\n**Tableau récapitulatif** :\n| Terme | Transport | Assurance | Douane import | Risque transféré |\n|---|---|---|---|---|\n| CPT | Vendeur | Acheteur | Acheteur | 1er transporteur |\n| CIP | Vendeur | Vendeur | Acheteur | 1er transporteur |\n| DAP | Vendeur | Acheteur | Acheteur | Lieu convenu |\n| DDP | Vendeur | Vendeur | **Vendeur** | Lieu livraison |\n\n**Recommandation pour PME exportatrice débutante** :\n- **Éviter DDP** : trop lourd, exige connaissance douane Maroc, risque coûts cachés.\n- **Éviter EXW/FCA** : client doit tout gérer, complexe pour acheteur étranger.\n- **Recommander CIP Casablanca** : vendeur garde la maîtrise transport + assurance, acheteur s''occupe uniquement de l''import → équilibre risque/effort.\n- **Alternative CIF** si transbordement maritime majeur (ferry Sète-Tanger) : règles maritimes pures plus claires.\n\nÉvolution selon volume :\n- Année 1-2 : CIP (équilibre).\n- Année 3+ : CPT (économie d''assurance, prendre sa propre couverture).\n- Année 5+ : EXW (acheteur grand groupe, gère sa logistique).'),

  (v_formation, v_module, 'qr',
   'La douane française détecte lors d''un contrôle scanner Marseille qu''un transitaire a déclaré 20 000 € pour 100 sacs Louis Vuitton, alors que la valeur réelle est de 120 000 €. Décrivez les sanctions encourues, les recours possibles pour le DO, et les mesures préventives qu''aurait dû prendre le transitaire pour éviter cette situation.',
   NULL, 6, 'difficile', ARRAY['gotrm','bc01-05','qr','sanctions','controle'], 'mft-2026-gotrm:bc01-05-v3:qr7', true,
   'Sanctions encourues :\n\n1. **Régularisation des droits et taxes** :\n   - Différence valeur : 100 000 € (120 000 − 20 000).\n   - Droits supplémentaires (~5 % maroquinerie code SH 4202) : 5 000 €.\n   - TVA supplémentaire 20 % sur 100 000 + 5 000 = 21 000 €.\n   - Total régularisation : **26 000 €**.\n\n2. **Amende administrative** :\n   - Article 414 Code des Douanes : amende **1 à 4 fois la valeur de la fraude**.\n   - Valeur de la fraude = 100 000 € (différence valeur déclarée vs réelle).\n   - Amende : entre **100 000 et 400 000 €**.\n\n3. **Saisie marchandise** :\n   - Possible mise sous main de la douane pendant l''enquête (jusqu''à plusieurs mois).\n   - Si confirmation fraude → confiscation possible.\n\n4. **Inscription fichier DGDDI** :\n   - Le transitaire et le DO sont inscrits au fichier des contrevenants.\n   - Tous les futurs envois feront l''objet de contrôles renforcés.\n\n5. **Infraction pénale** :\n   - En cas de récidive ou intention frauduleuse : tribunal correctionnel.\n   - Peines maximales : **10 ans de prison** + amende jusqu''à 4 fois la valeur (art. 414 Code des Douanes).\n\nRecours possibles pour le DO :\n- **Bonne foi** invoquée si erreur déclarative non intentionnelle (ex. erreur de devise, conversion EUR/USD).\n- **Recours administratif** auprès de la DGDDI dans les 30 jours.\n- **Recours contentieux** au tribunal administratif si décision défavorable.\n- **Solidarité** : DO et transitaire sont solidairement responsables. Le DO peut se retourner contre le transitaire si négligence prouvée.\n\nMesures préventives qu''aurait dû prendre le transitaire :\n1. **Vérification cohérence prix** vs valeur de marché Louis Vuitton (sacs 1 200 €/unité = norme).\n2. **Justificatifs** : facture commerciale + virements bancaires + contrat commercial.\n3. **Code SH précis** + classement validé.\n4. **Demande de décision contraignante valeur** auprès de la DGDDI pour opérations sensibles.\n5. **Audit annuel externe** des pratiques de classement et valeur.\n6. **Refus de la déclaration** si valeur visiblement sous-évaluée par le DO.\n\nLeçon : un transitaire qui couvre une fraude de son client devient pénalement responsable. Le « sentir bon le risque » est une compétence métier essentielle.'),

  (v_formation, v_module, 'qr',
   'Construisez un plan d''action en 5 leviers pour un GOTRM qui gère 200 transports/mois (60 % nationaux, 40 % internationaux dont 30 % hors UE) et qui souhaite professionnaliser sa gestion documentaire et douanière. Détaillez les outils, les formations, les indicateurs et les coûts estimés sur 12 mois.',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-05','qr','professionnalisation','plan'], 'mft-2026-gotrm:bc01-05-v3:qr8', true,
   'Plan d''action en 5 leviers :\n\n**1. Outils — Digitalisation documentaire**\n- TMS Akanea International (intègre CMR digital, multilingue, archivage 5 ans, signature eIDAS) : **1 200 €/mois × 12 = 14 400 €/an**.\n- App conducteur Stellium pour preuves photos et signature destinataire : 500 €/an.\n- DocuSign Business Pro (signature avancée + qualifiée option) : **35 €/mois × 3 users = 1 260 €/an**.\n- **Total outils : 16 160 €/an**.\n\n**2. Formations — Compétence GOTRM et conducteurs**\n- Formation CED (commissionnaire en douane) pour 1 collaborateur : 3 500 € + 1 mois.\n- Formation INCOTERMS 2020 (ICC France) pour équipe commerciale : 1 500 € (5 personnes × 300 €).\n- Formation conducteurs « réserves et photos » : 800 € (interne via plateforme e-learning).\n- Formation continue annuelle (FNTR, OTRE) : 2 000 €.\n- **Total formations : 7 800 €/an**.\n\n**3. Externalisation douane — Partenariat transitaire**\n- Mandat transitaire pour 30 % des transports internationaux hors UE (60 transports/mois) : 100 €/déclaration × 60 × 12 = 72 000 €/an. **Économie potentielle** vs interne : -30 %.\n- **Total externalisation : ~50 000 €/an** (vs 72 000 € sans optimisation).\n\n**4. Procédures internes — Manuels et templates**\n- Création manuel qualité documentaire (LV, BL, CMR, DAU) : 5 000 € (consultant externe, 1 mois).\n- Templates Outlook (acquittement, demande infos, devis, refus) : 0 € (interne).\n- Procédure réserves photos + LRAR < 3/7j : 0 € (interne).\n- **Total procédures : 5 000 €**.\n\n**5. Audit annuel — Sécurité juridique**\n- Audit cabinet externe (PwC, Mazars) sur classement SH et valeur en douane : 8 000 €.\n- Décision contraignante DGDDI (gros volumes récurrents) : 0 € (gratuit DGDDI).\n- Mise à jour CGV transporteur par avocat spécialisé : 2 000 €.\n- **Total audit : 10 000 €**.\n\n**Total investissement an 1 : ~89 000 €**.\n\n**Indicateurs de pilotage** (mensuel) :\n- Taux de réserves résolues sous 7 j : cible > 95 %.\n- Taux de DAU acceptés sans rectification : cible > 98 %.\n- Coût douanier moyen par transport hors UE : cible < 150 €.\n- Délai en frontière hors UE : cible < 90 min.\n- Litiges documentaires/an : cible < 5.\n- Amendes douanières/an : cible 0.\n\n**ROI estimé** :\n- Économie litiges (~10 → 2/an × 5 000 € moyen) : **40 000 €**.\n- Économie temps gestion (gain 30 % via TMS) : **30 000 €**.\n- Économie amendes (évite 1 à 2 par an × 30 000 € moyen) : **45 000 €**.\n- **ROI total an 1 : 115 000 € − 89 000 € = +26 000 €**, et croissant les années suivantes.\n\n**Calendrier suggéré** :\n- T1 : déploiement TMS + formations.\n- T2 : montée en puissance, premiers résultats.\n- T3 : audit + ajustements.\n- T4 : bilan et plan d''amélioration continue.');

  -- =================================================================
  -- QUIZZES (4 entraînement + 1 examen blanc module)
  -- =================================================================

  -- Quiz 1 — Documents transport national
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Documents transport national — Quiz',
          'Quiz d''entraînement (12 questions) sur la lettre de voiture nationale (4 exemplaires), les 11 mentions obligatoires (art. L. 1432-3 C. transports), le bordereau de livraison, les réserves recevables et la signature électronique eIDAS.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-05-v3:l1:%';

  -- Quiz 2 — Documents transport international
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Documents transport international — Quiz',
          'Quiz d''entraînement (12 questions) sur la CMR (Genève 1956), le BL maritime négociable, l''AWB aérien (Montréal 1999), le carnet TIR, les conventions et plafonds par mode (8,33 vs 22 DTS/kg).',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-05-v3:l2:%';

  -- Quiz 3 — Formalités douanières
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Formalités douanières — Quiz',
          'Quiz d''entraînement (12 questions) sur le DAU et ses 4 régimes (EX, IM, T1, T2), le Brexit, les acteurs douaniers (CED, transitaire, DGDDI) et la dématérialisation DELTA G/H7.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-05-v3:l3:%';

  -- Quiz 4 — Origine, valeur, INCOTERMS
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Origine, valeur, INCOTERMS — Quiz',
          'Quiz d''entraînement (12 questions) sur l''origine préférentielle (EUR.1/EUR-MED), la valeur en douane (méthode transactionnelle), les 11 INCOTERMS 2020 (transfert risque vs coût) et les sanctions douanières (1-4× valeur).',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-05-v3:l4:%';

  -- Examen blanc module — 15 QCM transversaux + 5 QR cas pratique
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold, is_mock_exam)
  VALUES (v_module, 'Examen blanc — BC01-05 Documents et douane',
          'Examen blanc reproduisant les conditions de l''examen RNCP : 15 QCM transversaux (4 leçons) + 5 QR cas pratiques métier, durée 60 min, seuil 50 %.',
          'examen', 3600, 50, true)
  RETURNING id INTO v_quiz_eb;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref IN (
     -- 4 QCM Leçon 1
     'mft-2026-gotrm:bc01-05-v3:l1:q1','mft-2026-gotrm:bc01-05-v3:l1:q3',
     'mft-2026-gotrm:bc01-05-v3:l1:q5','mft-2026-gotrm:bc01-05-v3:l1:q8',
     -- 4 QCM Leçon 2
     'mft-2026-gotrm:bc01-05-v3:l2:q1','mft-2026-gotrm:bc01-05-v3:l2:q3',
     'mft-2026-gotrm:bc01-05-v3:l2:q5','mft-2026-gotrm:bc01-05-v3:l2:q8',
     -- 4 QCM Leçon 3
     'mft-2026-gotrm:bc01-05-v3:l3:q3','mft-2026-gotrm:bc01-05-v3:l3:q4',
     'mft-2026-gotrm:bc01-05-v3:l3:q5','mft-2026-gotrm:bc01-05-v3:l3:q12',
     -- 3 QCM Leçon 4
     'mft-2026-gotrm:bc01-05-v3:l4:q1','mft-2026-gotrm:bc01-05-v3:l4:q4',
     'mft-2026-gotrm:bc01-05-v3:l4:q8',
     -- 5 QR (cas pratiques transversaux)
     'mft-2026-gotrm:bc01-05-v3:qr1','mft-2026-gotrm:bc01-05-v3:qr2',
     'mft-2026-gotrm:bc01-05-v3:qr4','mft-2026-gotrm:bc01-05-v3:qr5',
     'mft-2026-gotrm:bc01-05-v3:qr7'
   );

  RAISE NOTICE '✓ GOTRM BC01-05 v3 dense importé : 4 leçons (LV nationale, CMR/BL/AWB, DAU/T1/T2, INCOTERMS 2020), 48 QCM, 8 QR cas pratiques métier, 5 quiz (4 entraînement + 1 examen blanc 15 QCM + 5 QR / 60 min).';

END $bc01_05_v3$;
