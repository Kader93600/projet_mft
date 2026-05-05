-- =====================================================================
-- GOTRM (RNCP 40990) — BC01-05 : Documents de transport et formalités douanières
-- Lettre de voiture, CMR, T1/T2, DAU, Incoterms 2020.
-- =====================================================================

DO $bc01_05$
DECLARE
  v_formation uuid; v_bloc int; v_module uuid;
  v_lesson_1 uuid; v_lesson_2 uuid; v_lesson_3 uuid; v_lesson_4 uuid;
  v_quiz_1 uuid; v_quiz_2 uuid; v_quiz_3 uuid; v_quiz_4 uuid; v_quiz_eb uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc.'; END IF;

  DELETE FROM public.modules WHERE slug = 'gotrm-bc01-05-documents-douane';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'BC01-05 — Documents de transport et formalités douanières',
    'gotrm-bc01-05-documents-douane', v_bloc,
    'Maîtriser les documents de transport (lettre de voiture, CMR, BL) et les formalités douanières (DAU, T1/T2, EX, IM) dans le cadre des Incoterms 2020.',
    'intermediaire', 180, 50
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 50, true) ON CONFLICT DO NOTHING;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-05:%';

  -- =================================================================
  -- LEÇON 1 — Documents de transport national
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Documents du transport national : lettre de voiture, BL',
    'gotrm-bc01-05-01-documents-national', 1, 45,
$lesson1$
# Documents du transport national : lettre de voiture, BL

En transport national, plusieurs documents accompagnent la marchandise. Chacun a une fonction juridique précise et des conséquences en cas de litige. Bien les distinguer est la première compétence documentaire de l'exploitant.

> 🎯 **Objectifs de la leçon**
>
> - Identifier le rôle de la **lettre de voiture nationale**.
> - Distinguer **bordereau de livraison** (BL) et **bon de commande**.
> - Comprendre la valeur juridique de chaque document.
> - Maîtriser les **mentions obligatoires** et la **distribution** des exemplaires.

---

## 1. La lettre de voiture nationale (LVN)

### 1.1 Définition

La **lettre de voiture** est le document qui matérialise le **contrat de transport** et accompagne la marchandise du chargement à la livraison. Elle est régie par le contrat-type général (décret 99-269).

### 1.2 Mentions obligatoires (article R3411-13 du Code des transports)

| # | Mention |
|---|---|
| 1 | Date d'émission |
| 2 | Identification de l'expéditeur (nom, adresse) |
| 3 | Identification du destinataire (nom, adresse) |
| 4 | Identification du transporteur (raison sociale, SIREN, numéro LTI/LTM) |
| 5 | Lieux de chargement et livraison |
| 6 | Désignation de la marchandise (nature, conditionnement, marques) |
| 7 | Nombre de colis et poids brut |
| 8 | Caractère dangereux ou particulier (ADR, ATP) |
| 9 | Prix du transport (facultatif si confidentiel) |
| 10 | Instructions d'expédition (délais, contre-remboursement, valeur déclarée) |

### 1.3 Distribution des exemplaires

La LVN est établie en **3 exemplaires** :

| Exemplaire | Destinataire |
|---|---|
| 1er (original) | Expéditeur (preuve de remise au transporteur) |
| 2e | Transporteur (suit la marchandise) |
| 3e | Destinataire (preuve de livraison) |

### 1.4 Valeur juridique

| Sans LVN | Avec LVN |
|---|---|
| Le contrat-type général s'applique | Le contrat est défini sur mesure |
| Charge de la preuve plus difficile | Preuve écrite immédiate |
| Plafonds légaux par défaut | Possibilité de plafonds négociés |

> ⚠️ **Pas de LVN, pas de blocage**
>
> L'absence de lettre de voiture **n'invalide pas** le contrat (qui est consensuel) mais affaiblit considérablement la position du transporteur en cas de litige. À éviter absolument.

---

## 2. Le bordereau de livraison (BL)

### 2.1 Différence avec la lettre de voiture

| Critère | Lettre de voiture | Bordereau de livraison |
|---|---|---|
| Émetteur | Transporteur ou expéditeur | Expéditeur |
| Fonction | Contrat de transport | Liste de colisage à livrer |
| Valeur juridique | Preuve du contrat | Preuve de la livraison |
| Cadre légal | Contrat-type 99-269 | Pratique commerciale |

### 2.2 Mentions classiques du BL

- Numéro de BL et date
- Bon de commande client de référence
- Identification expéditeur et destinataire
- Détail ligne par ligne : code produit, désignation, quantité, prix unitaire (selon usage)
- Poids et nombre de colis
- Conditions de livraison (Incoterm si applicable)
- **Réserves** émises au déchargement

> 📌 **Le BL signé**
>
> À la livraison, le destinataire signe le BL en y portant éventuellement des **réserves**. Un BL « signé sans réserve » fait présumer la conformité de la livraison. Sa modification ultérieure est très difficile.

---

## 3. Les réserves au déchargement

### 3.1 Pourquoi des réserves ?

À l'arrivée, le destinataire doit **vérifier** la marchandise et noter immédiatement toute anomalie. Les réserves font foi.

### 3.2 Types de réserves

| Type | Définition | Exemple |
|---|---|---|
| **Apparente** | Visible immédiatement au déchargement | « Carton n° 3 enfoncé, vérification du contenu impossible » |
| **Non apparente** | Découverte après déchargement | Casse interne, quantité partielle |
| **Quantitative** | Nombre de colis incorrect | « Reçu 47 colis au lieu de 50 » |
| **Qualitative** | État dégradé | « Palette mouillée, étiquettes décollées » |

### 3.3 Délais de déclaration

| Type de réserve | Délai légal |
|---|---|
| **Apparente** | À la livraison (mention sur le BL ou la LVN) |
| **Non apparente (national)** | **3 jours** ouvrés après livraison |
| **Non apparente (CMR international)** | **7 jours** ouvrés (sauf perte) |

> ⚠️ **Réserves vagues = inopposables**
>
> Une mention type « sous réserve de déballage » est trop vague et peut être déclarée **sans valeur juridique**. Préférer : « Carton n° 3, dim. 60×40×30, enfoncé sur la face supérieure, traces d'humidité. »

---

## 4. Cas pratique : la livraison contestée

**Contexte** : *Distribution Aquitaine* livre 120 cartons de fournitures à *Bureautique Pyrénées*. À l'arrivée, le réceptionnaire signe le BL sans contrôler. 4 jours plus tard, il découvre que 8 cartons sont vides.

| Étape | Analyse |
|---|---|
| 1. Signature sans réserve | Présomption de conformité (livraison correcte présumée) |
| 2. Découverte 4 jours après | Délai de **3 jours** pour les réserves non apparentes dépassé |
| 3. Position du transporteur | Aucune responsabilité opposable, charge de la preuve sur le destinataire |
| 4. Position du destinataire | Doit prouver que les cartons étaient déjà vides à l'arrivée (vidéosurveillance, témoins, etc.) |

> 💡 **Bonne pratique exploitant**
>
> Sensibiliser les clients à l'importance de la **vérification systématique** au déchargement et à l'émission immédiate des réserves. Cela protège **tout le monde**, y compris vous en tant que transporteur.

---

> ✅ **À retenir**
>
> - **LVN** : matérialise le contrat de transport (3 exemplaires).
> - **BL** : preuve de livraison émise par l'expéditeur, signé par le destinataire.
> - Mentions obligatoires : parties, marchandise, lieux, dates, particularités.
> - **Réserves** : apparentes au déchargement, non apparentes sous **3 jours** (national) ou **7 jours** (CMR).
$lesson1$,
'Lettre de voiture nationale, bordereau de livraison, mentions obligatoires, réserves apparentes et non apparentes (3 jours national / 7 jours CMR).'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Documents internationaux : CMR
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Documents du transport international : la CMR',
    'gotrm-bc01-05-02-cmr-international', 2, 45,
$lesson2$
# Documents du transport international : la CMR

À l'international, le document central est la **lettre de voiture CMR**. Elle a la même fonction que la LVN mais s'inscrit dans le cadre de la Convention CMR (Genève 1956), avec ses propres règles et obligations.

> 🎯 **Objectifs de la leçon**
>
> - Identifier les **caractéristiques** de la lettre de voiture CMR.
> - Connaître les **mentions obligatoires** spécifiques à l'international.
> - Comprendre le **rôle juridique** de la CMR (preuve, présomption).
> - Maîtriser les **délais de réserve** propres à la CMR.

---

## 1. Le document CMR

### 1.1 Champ d'application

La lettre de voiture CMR s'applique dès qu'**au moins un des deux pays** (chargement OU livraison) est signataire de la Convention CMR. Plus de **55 pays** sont signataires (UE + voisins + nombreux pays Asie / Afrique).

### 1.2 Couleur et présentation

| Exemplaire | Couleur | Destinataire |
|---|---|---|
| 1er (rouge) | Rouge | Expéditeur (chargeur) |
| 2e (bleu) | Bleu | Suit la marchandise (livré au destinataire) |
| 3e (vert) | Vert | Conservé par le transporteur |

> 📌 **Mémo couleur**
>
> *Rouge — Reste chez l'expéditeur*
> *Bleu — Bouge avec la marchandise*
> *Vert — Vit dans les archives du transporteur*

### 1.3 Mentions obligatoires (CMR art. 6)

Toutes les mentions de la LVN nationale + spécificités internationales :

- **Pays** d'expédition et de destination
- **Nature précise** des marchandises (en français + langue du pays destinataire si possible)
- **Liste des documents** annexes (factures, certificats, douane)
- Frais à la charge de l'expéditeur ou du destinataire
- **Valeur déclarée** (si pertinent)
- **Intérêt spécial à la livraison** (si pertinent)
- Mention du **caractère ADR** (matières dangereuses)

---

## 2. Valeur juridique de la CMR

### 2.1 Présomptions

La CMR pose deux **présomptions juridiques** :

| Présomption | Effet |
|---|---|
| Article 9 §1 | La CMR fait foi des conditions du contrat et de la réception des marchandises |
| Article 9 §2 | À défaut de réserves, le transporteur est présumé avoir reçu marchandise et emballage en bon état apparent |

### 2.2 Renversement de la présomption

Le transporteur peut **renverser la présomption** en prouvant :
- Force majeure ou cas exonératoire (CMR art. 17 §2)
- Faute de l'expéditeur ou du destinataire
- Vice propre de la marchandise

### 2.3 Réserves CMR

| Type | Délai |
|---|---|
| **Apparente** | Mention à la livraison sur l'exemplaire bleu |
| **Non apparente** | **7 jours** ouvrés à compter de la livraison |
| **Retard** | **21 jours** à compter de la mise à disposition |
| **Perte présumée** | **30 jours** après le délai convenu, ou 60 jours après la prise en charge |

---

## 3. Les exonérations CMR (article 17)

### 3.1 Causes générales

Le transporteur peut s'exonérer en cas de :
- Faute du chargeur ou du destinataire
- Instructions du chargeur (sauf faute)
- Vice propre de la marchandise
- **Circonstances que le transporteur n'a pas pu éviter** ni aux conséquences desquelles il n'a pu obvier

> 📌 **Vocabulaire CMR**
>
> La CMR utilise une formulation plus large que le national : « circonstances que le transporteur n'a pas pu éviter ». La force majeure stricte est déjà couverte, mais la CMR ouvre l'exonération à des situations un peu plus souples.

### 3.2 Causes particulières (CMR art. 17 §4)

Le transporteur est exonéré s'il prouve que la perte ou avarie résulte de :
- a) Emploi de **véhicules ouverts non bâchés** convenu expressément
- b) **Absence ou défectuosité de l'emballage** pour des marchandises sujettes par leur nature
- c) **Manutention** par le chargeur, le destinataire ou tiers
- d) **Nature de certaines marchandises** (rouille, casse, fuite)
- e) Insuffisance ou imperfection des **marques ou numéros**
- f) Transport d'**animaux vivants**

---

## 4. Indemnisation CMR

### 4.1 Plafond standard (CMR art. 23 §3)

Le plafond est de **8,33 DTS par kilogramme** brut manquant ou avarié.

> 📌 **Le DTS**
>
> Le DTS (Droit de Tirage Spécial) est l'unité de compte du FMI. **1 DTS ≈ 1,30 € en 2026** (variable). Soit environ **10,80 €/kg** sur les transports CMR.

### 4.2 Déclaration de valeur (CMR art. 24)

L'expéditeur peut, moyennant **supplément de prix**, déclarer une valeur supérieure aux 8,33 DTS/kg. La déclaration doit figurer **sur la lettre de voiture CMR**.

### 4.3 Intérêt spécial à la livraison (CMR art. 26)

L'expéditeur peut fixer un **intérêt spécial à la livraison** (montant pour retard) moyennant supplément. Sans clause, le retard est indemnisé jusqu'au prix du transport.

### 4.4 Faute lourde / dol (CMR art. 29)

En cas de **dol** (faute intentionnelle) ou de **faute équivalente** (article 29), les plafonds **sautent** et le transporteur indemnise **intégralement**.

---

## 5. Cas pratique : litige CMR

**Contexte** : *Trans-Cargo Lyon* transporte 6 t de matériel électronique (valeur 240 000 €) Lyon → Düsseldorf. À l'arrivée, 1,5 t sont volées sur l'aire de stationnement. Le transporteur n'a pas activé l'antivol GPS.

| Élément | Analyse |
|---|---|
| Type de litige | Vol pendant transport (perte) |
| Texte | CMR (international UE) |
| Indemnité de base | 1 500 kg × 8,33 DTS = 12 495 DTS ≈ 16 244 € |
| Faute lourde ? | Antivol non activé : possible faute lourde au sens art. 29 |
| Position chargeur | Sans déclaration de valeur sur la CMR : limite à 8,33 DTS/kg sauf prouve de la faute lourde |
| Si faute lourde reconnue | Indemnité intégrale = **valeur des biens volés ~ 60 000 €** |
| Recommandation préventive | Toujours activer les dispositifs antivol, choisir des aires sécurisées CTPark, formation équipages |

---

> ✅ **À retenir**
>
> - **CMR** = international, **3 exemplaires colorés** (rouge, bleu, vert).
> - Mentions obligatoires : parties, marchandise, pays, valeur, ADR.
> - Plafond CMR : **8,33 DTS/kg** (≈ 10,80 €/kg en 2026).
> - Délais de réserves : **7 jours** non apparente, **21 jours** retard, **30 jours** perte.
> - **Faute lourde / dol** (art. 29) = plafonds sautent, indemnité intégrale.
$lesson2$,
'Lettre de voiture CMR (3 exemplaires colorés), mentions obligatoires, présomptions, plafond 8,33 DTS/kg, délais de réserves (7j/21j/30j), faute lourde art. 29.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Formalités douanières
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Formalités douanières : DAU, T1/T2, EX, IM',
    'gotrm-bc01-05-03-formalites-douanieres', 3, 45,
$lesson3$
# Formalités douanières : DAU, T1/T2, EX, IM

Sortir ou entrer en UE, traverser un pays tiers, ou acheminer une marchandise non dédouanée : autant d'opérations qui imposent des **formalités douanières précises**. L'exploitant doit en connaître les bases pour éviter blocages, amendes et retards.

> 🎯 **Objectifs de la leçon**
>
> - Distinguer **transport intra-UE** (sans douane) et **transport hors UE** (douane requise).
> - Comprendre les **statuts douaniers** : T1, T2, T2L.
> - Identifier le rôle du **DAU** (Document Administratif Unique) et des codes **EX / IM**.
> - Maîtriser le système **NSTI / NCTS** (transit communautaire informatisé).

---

## 1. Cadre général

### 1.1 Le marché unique européen

Au sein de l'UE, les marchandises **circulent librement** : pas de douane, pas de droits de douane, pas de TVA aux frontières. Ce qui circule à l'intérieur de l'UE est une **livraison intracommunautaire** (régime fiscal).

### 1.2 Hors UE

Pour les flux **vers/depuis pays tiers**, les formalités douanières s'appliquent :
- **Exportation** (EX) : sortie de marchandises hors UE
- **Importation** (IM) : entrée de marchandises depuis pays tiers
- **Transit** (T1, T2) : marchandises traversant l'UE sans dédouanement immédiat

### 1.3 Les pays « hors UE » à connaître

| Catégorie | Pays |
|---|---|
| AELE (régime spécial) | Suisse, Norvège, Islande, Liechtenstein |
| EEE (mais hors UE) | Norvège, Islande, Liechtenstein |
| Hors UE/AELE | Royaume-Uni (depuis Brexit), Turquie (douane mais accord), Russie, Maroc, Tunisie, etc. |

---

## 2. Les statuts douaniers : T1, T2, T2L

### 2.1 T1 — Marchandises non communautaires

| Critère | Détail |
|---|---|
| Origine | Pays tiers, en transit dans l'UE |
| Statut | Non dédouanées, droits de douane non perçus |
| Garantie | Caution exigée (mainlevée) |
| Usage | Transit interne / externe entre territoires douaniers |

> 📌 **Exemple T1**
>
> Un container chinois arrive au Havre, doit aller en Allemagne pour dédouanement. Pendant le trajet Le Havre → Mannheim, la marchandise est sous **régime T1**.

### 2.2 T2 — Marchandises communautaires en transit

| Critère | Détail |
|---|---|
| Origine | UE |
| Statut | Communautaire, dédouanée |
| Usage | Transit dans un pays tiers (ex : Suisse) avant retour UE |

> 📌 **Exemple T2**
>
> Une remorque de pièces françaises pour l'Italie traverse la Suisse. Régime **T2** car marchandises UE qui transitent dans un pays tiers.

### 2.3 T2L — Document de preuve de statut

C'est un **document de preuve** que les marchandises ont le statut communautaire (utilisé dans les ports, aéroports, lors de la sortie/retour temporaire de l'UE).

---

## 3. Le DAU (Document Administratif Unique)

### 3.1 Fonction

Le DAU est le formulaire officiel utilisé pour :
- **Déclaration d'exportation** (EX)
- **Déclaration d'importation** (IM)
- **Déclaration de transit** (CO, T1, T2)

Aujourd'hui largement **dématérialisé** via les téléservices Delta XI / Delta T (France) ou équivalents européens.

### 3.2 Mentions clés

- Numéro EORI de l'expéditeur (numéro douanier européen)
- Numéro EORI du destinataire
- Code marchandise (nomenclature **HS / SH** ou **TARIC** européen 10 chiffres)
- Valeur en douane et **Incoterm** applicable
- Pays d'origine et pays de destination
- Régime douanier (40 = mise en libre pratique, 10 = exportation définitive, etc.)

### 3.3 Numéro EORI

Tout opérateur économique qui dédouane doit avoir un **EORI** (Economic Operator Registration and Identification). C'est l'équivalent d'un SIREN, mais à l'échelle européenne.

> 💡 **Pour le transporteur**
>
> Le transporteur n'a pas besoin de l'EORI si la marchandise reste **en transit** (T1/T2) sans changement de statut. Mais si l'entreprise effectue une mise en libre pratique pour le compte du client (déclaration en douane), un EORI est nécessaire.

---

## 4. Le NSTI / NCTS — transit informatisé

### 4.1 Principe

Le **NSTI** (Nouveau Système de Transit Informatisé), aussi appelé **NCTS** au niveau européen, est la plateforme qui suit en temps réel les opérations de transit T1/T2 dans toute l'UE + AELE.

### 4.2 Fonctionnement

1. **Bureau de départ** : transitaire / exportateur fait la déclaration NSTI, reçoit un **MRN** (Movement Reference Number).
2. **Document d'accompagnement** (TAD/DAT) imprimé : c'est le « passeport » de la marchandise pendant le transit.
3. **Passages aux frontières** : scellement du véhicule, lecture du MRN à chaque bureau.
4. **Bureau de destination** : déclaration de fin de transit, mainlevée, paiement éventuel des droits.

### 4.3 Délai d'apurement

Le transit doit être **apuré** dans le délai fixé par le bureau de départ (en général **8 jours** pour un trajet européen). Au-delà, des **majorations et pénalités** s'appliquent.

> ⚠️ **Importance pratique**
>
> Un T1 non apuré dans les délais peut engendrer :
> - Activation de la garantie financière du transporteur
> - Présomption d'introduction frauduleuse
> - Paiement des droits de douane + TVA
> - Amendes pouvant dépasser 10 000 €

---

## 5. Le carnet ATA et le carnet TIR

### 5.1 Carnet ATA

| Caractéristique | Détail |
|---|---|
| Usage | Importations TEMPORAIRES (foires, salons, démonstrations, équipements professionnels) |
| Pays | 80+ pays |
| Délai | 12 mois max |
| Bénéfice | Pas de paiement de droits ni de TVA si réexportation dans les délais |

### 5.2 Carnet TIR

| Caractéristique | Détail |
|---|---|
| Usage | Transit international par route |
| Pays | 76 pays signataires (UE, Russie, Turquie, Iran, etc.) |
| Garantie | Couverte par l'IRU jusqu'à 100 000 € par carnet |
| Visa frontières | Bureaux frontières apposent les visas et plombent le véhicule |

> 📌 **Brexit et carnets TIR**
>
> Depuis 2021, beaucoup de transporteurs UK utilisent le carnet TIR pour fluidifier les passages — mais le UK n'est pas dans l'UE, donc des formalités complètes restent nécessaires.

---

## 6. Cas pratique douanier

**Contexte** : *Logitrans Marseille* doit acheminer 28 palettes de produits cosmétiques de Marseille vers Casablanca (Maroc) via le port de Tanger Med (ferry).

### Démarches étape par étape

1. **Vérification documentaire** :
   - Facture commerciale (Incoterm CIP Casablanca convenu)
   - Liste de colisage
   - Certificat d'origine (pour bénéfice de l'accord UE-Maroc, droits réduits)

2. **Déclaration d'exportation EX** au bureau de Marseille :
   - DAU/Delta XI rempli avec code marchandise (HS 33xx)
   - Visa douane (mainlevée)

3. **Trajet Marseille → Tanger** :
   - Marchandise sous **régime T2** (UE en transit) jusqu'au port d'embarquement
   - À l'embarquement : remise du document d'export visé au commandant du ferry

4. **Arrivée Tanger Med** :
   - **Importation au Maroc** (IM marocain) avec déclaration douanière marocaine
   - Paiement des droits réduits (accord UE-Maroc) ou TVA marocaine
   - Mainlevée pour livraison Casablanca

5. **Documents à conserver** :
   - DAU export visé (5 ans pour la comptabilité)
   - CMR signé à la livraison Casablanca
   - Certificat d'origine
   - Preuve de l'arrivée à destination (pour exonération TVA française)

> ⚠️ **Pas de preuve de sortie = redressement TVA**
>
> Si l'exportateur ne peut pas prouver la sortie effective de la marchandise hors UE, l'administration française peut réclamer la **TVA française à 20 %** sur la valeur de la marchandise. Conserver tous les documents (DAU visé, CMR, certificats) est CRITIQUE.

---

> ✅ **À retenir**
>
> - **Intra-UE** : pas de douane (livraison intracommunautaire).
> - **Hors UE** : douane requise (EX / IM / T1 / T2).
> - **T1** = non communautaire en transit, **T2** = communautaire en transit pays tiers, **T2L** = preuve de statut.
> - **DAU** = formulaire universel, dématérialisé via Delta XI (France) / NSTI (UE).
> - **EORI** obligatoire pour l'opérateur qui dédouane.
> - **Carnet TIR** = transit international 76 pays, **Carnet ATA** = importations temporaires.
$lesson3$,
'Statuts douaniers (T1, T2, T2L), DAU, codes EX/IM, transit NSTI/NCTS, EORI, carnets TIR et ATA, gestion d''un export hors UE.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Incoterms 2020
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Incoterms 2020 et conséquences douanières',
    'gotrm-bc01-05-04-incoterms-2020', 4, 45,
$lesson4$
# Incoterms 2020 et conséquences douanières

Les **Incoterms** définissent qui (vendeur / acheteur) prend en charge le transport, l'assurance, les formalités douanières et à quel moment a lieu le **transfert de risque**. Mal choisi, un Incoterm peut transformer une vente bénéficiaire en perte sèche.

> 🎯 **Objectifs de la leçon**
>
> - Distinguer les **11 Incoterms 2020**.
> - Identifier les **groupes E / F / C / D**.
> - Comprendre l'impact sur **transport**, **risque**, **douane** et **TVA**.
> - Choisir l'Incoterm adapté à un cas commercial donné.

---

## 1. Les 11 Incoterms 2020

Mis à jour par la **Chambre de Commerce Internationale (CCI)** en 2020, applicables jusqu'à la prochaine révision.

### 1.1 Incoterms multimodaux (tous modes)

| Incoterm | Nom complet | Niveau de prise en charge vendeur |
|---|---|---|
| **EXW** | Ex Works (départ usine) | Minimal |
| **FCA** | Free Carrier | Limité |
| **CPT** | Carriage Paid To | Transport mais pas risque |
| **CIP** | Carriage and Insurance Paid To | Transport + assurance |
| **DAP** | Delivered At Place | Transport jusqu'au lieu, hors douane import |
| **DPU** | Delivered at Place Unloaded | Comme DAP + déchargement |
| **DDP** | Delivered Duty Paid | Tout pris en charge (maximum vendeur) |

### 1.2 Incoterms maritimes (mer / fluvial uniquement)

| Incoterm | Nom complet | Particularité |
|---|---|---|
| **FAS** | Free Alongside Ship | Mise à quai au port d'embarquement |
| **FOB** | Free On Board | Chargement à bord du navire |
| **CFR** | Cost and Freight | Transport mer payé, risque transféré au chargement |
| **CIF** | Cost, Insurance, Freight | CFR + assurance |

> ⚠️ **Erreur fréquente**
>
> Utiliser **FOB** ou **CIF** pour un transport routier ou aérien. Les Incoterms maritimes **ne s'appliquent qu'au transport par eau** (mer ou voies navigables intérieures). Pour la route, utilisez FCA, CPT, CIP, DAP, DPU ou DDP.

---

## 2. Les 4 groupes Incoterms

### 2.1 Groupe E — Départ

| Incoterm | Vendeur | Acheteur |
|---|---|---|
| **EXW** | Met la marchandise à disposition dans ses locaux | Tout le reste : enlèvement, douane export, transport, douane import |

### 2.2 Groupe F — Sans paiement transport principal

| Incoterm | Vendeur paie | Acheteur paie |
|---|---|---|
| **FCA** | Pré-acheminement + douane export | Transport principal + douane import |
| **FAS** | Mise à quai port + douane export | Transport mer + douane import |
| **FOB** | Chargement bateau + douane export | Transport mer + douane import |

### 2.3 Groupe C — Avec paiement transport principal mais sans risque

| Incoterm | Vendeur paie | Risque transféré |
|---|---|---|
| **CPT** | Transport jusqu'à destination | Au premier transporteur |
| **CIP** | Transport + assurance jusqu'à destination | Au premier transporteur |
| **CFR** | Transport mer | Au chargement bateau |
| **CIF** | Transport mer + assurance | Au chargement bateau |

### 2.4 Groupe D — Arrivée

| Incoterm | Vendeur prend en charge | Vendeur ne prend pas |
|---|---|---|
| **DAP** | Transport jusqu'au lieu | Déchargement, douane import |
| **DPU** | Transport + déchargement | Douane import |
| **DDP** | TOUT (transport + douanes import + TVA + livraison) | Rien (ou presque) |

---

## 3. Le transfert de risque

C'est l'aspect **le plus important** des Incoterms. Le risque, c'est qui supporte la perte ou l'avarie de la marchandise.

| Incoterm | Transfert de risque |
|---|---|
| EXW | Mise à disposition dans les locaux du vendeur |
| FCA | Remise au transporteur à l'endroit convenu |
| FAS | Mise à quai du port d'embarquement |
| FOB / CFR / CIF | Chargement à bord du navire |
| CPT / CIP | Remise au premier transporteur |
| DAP / DPU | Au lieu de destination convenu |
| DDP | Au lieu de destination convenu, après dédouanement |

> 📌 **Piège du groupe C**
>
> Beaucoup pensent que **CIF** ou **CPT** transfère le risque à l'arrivée. **NON** : le risque passe **dès le chargement / la remise au transporteur**, même si le vendeur paie le transport jusqu'à destination. C'est l'Incoterm le plus mal compris.

---

## 4. Les douanes selon Incoterms

| Incoterm | Douane EXPORT (qui paie ?) | Douane IMPORT (qui paie ?) |
|---|---|---|
| **EXW** | Acheteur | Acheteur |
| **FCA / FAS / FOB** | Vendeur | Acheteur |
| **CPT / CIP / CFR / CIF** | Vendeur | Acheteur |
| **DAP / DPU** | Vendeur | Acheteur |
| **DDP** | Vendeur | **Vendeur** |

### 4.1 Pièges du DDP

Le **DDP** charge le vendeur de tout, y compris :
- Droits de douane à l'importation
- TVA à l'importation
- Formalités locales

> ⚠️ **DDP = à éviter**
>
> Pour un vendeur français exportant aux États-Unis, le DDP signifie payer la **TVA américaine (sales tax) variable par État**, les droits de douane US, et avoir un **EIN** (équivalent SIREN US). C'est extrêmement complexe et risqué. **Préférer DAP ou DPU**.

### 4.2 Le piège de l'EXW

Avec **EXW**, c'est l'acheteur étranger qui doit gérer la **douane export française**. Or, il n'a pas d'**EORI européen**. Conséquences :
- Risque de blocage de l'export
- TVA française à 20 % facturée à tort
- Perte du certificat d'exportation indispensable au remboursement de la TVA

> 💡 **Recommandation pratique**
>
> Un vendeur français exportant hors UE devrait privilégier **FCA** plutôt qu'EXW (qui charge le vendeur de la douane export, en gardant simplicité côté transport).

---

## 5. Tableau de choix Incoterm selon objectif

| Objectif | Incoterm recommandé |
|---|---|
| Vendeur veut faire le minimum | EXW ou FCA |
| Vendeur veut maîtriser transport et coûts | CPT ou CIP |
| Acheteur veut réception « clé en main » | DAP ou DPU |
| Vendeur veut simplifier au maximum pour l'acheteur | DDP (à éviter sauf cas simples) |
| Transport maritime UE → Asie | FOB ou CIF (selon préférence) |
| Vente intra-UE B2B | DAP ou FCA selon habitude commerciale |

---

## 6. Cas pratique : choisir un Incoterm

**Contexte** : *Métallerie Béziers* vend 12 t de structures métalliques à *Construcciones Madrid* (Espagne). Les deux entreprises sont équipées en transport. Le client veut un prix **livré sur chantier**.

### Analyse comparée

| Option | Caractéristiques | Évaluation |
|---|---|---|
| **EXW Béziers** | Acheteur tout gère | Trop contraignant pour l'acheteur, complexe |
| **FCA Béziers** | Vendeur livre au transporteur, douane export simple | Bon mais pas « livré chantier » |
| **CPT Madrid** | Vendeur paie transport, risque transféré au chargement | Transport oui mais risque trompeur |
| **DAP Chantier Madrid** | Vendeur transporte jusqu'au chantier, déchargement par acheteur | **Idéal** — clarté + sécurité juridique |
| **DDP Chantier Madrid** | Vendeur tout, y compris TVA espagnole | Complexité TVA inutile (UE intra) |

**Choix recommandé** : **DAP Chantier de la Calle de la Cadena, Madrid (Espagne)**.

Le DAP est bien adapté :
- Pas de douane (intra-UE)
- Le vendeur garde la maîtrise du transport et de l'assurance
- Le risque ne passe qu'à l'arrivée au chantier
- Déchargement à la charge de l'acheteur (qui dispose des moyens sur chantier)

> 💡 **Mention contractuelle correcte**
>
> *« Vente DAP Chantier "Construcciones Madrid", Calle de la Cadena 12, 28013 Madrid (Espagne) — Incoterms 2020. »*
>
> Préciser **toujours** le lieu géographique exact ET la version « Incoterms 2020 » pour éviter toute ambiguïté.

---

> ✅ **À retenir**
>
> - **11 Incoterms 2020** classés en 4 groupes (E, F, C, D).
> - 4 Incoterms maritimes uniquement : **FAS, FOB, CFR, CIF**.
> - **Groupe C** : transport payé par vendeur, risque transféré au chargement (piège classique).
> - **DDP** = vendeur tout, **DAP/DPU** = douane import à charge acheteur.
> - **EXW** déconseillé en export hors UE (problème EORI).
> - Toujours préciser le **lieu géographique** + la mention **Incoterms 2020**.
$lesson4$,
'11 Incoterms 2020 (groupes E/F/C/D), transfert de risque, répartition des douanes export/import, pièges (DDP, EXW, groupe C) et cas pratique.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- 28 QCM REFORMULÉS
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qcm', 'La lettre de voiture nationale est établie en combien d''exemplaires ?', '[{"id":"a","label":"1 exemplaire","is_correct":false},{"id":"b","label":"2 exemplaires","is_correct":false},{"id":"c","label":"3 exemplaires","is_correct":true},{"id":"d","label":"4 exemplaires","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['lvn','exemplaires'], 'mft-2026-gotrm:bc01-05:qcm:1', true, 'La LVN est en 3 exemplaires : un pour l''expéditeur, un qui suit la marchandise (transporteur), un pour le destinataire. Cette tripartition matérialise le contrat de transport entre les trois acteurs.'),
  (v_formation, 'qcm', 'L''absence de lettre de voiture rend-elle le contrat de transport invalide ?', '[{"id":"a","label":"Oui, le contrat est nul de plein droit","is_correct":false},{"id":"b","label":"Non, le contrat est consensuel et reste valide, mais la preuve est plus difficile","is_correct":true},{"id":"c","label":"Oui, sauf accord verbal écrit a posteriori","is_correct":false},{"id":"d","label":"Non, mais le transporteur perd toute indemnisation","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['lvn','validite'], 'mft-2026-gotrm:bc01-05:qcm:2', true, 'Le contrat de transport est consensuel : il existe dès l''accord des parties. L''absence de LVN n''entraîne pas sa nullité mais affaiblit la position du transporteur en cas de litige (charge de la preuve plus lourde).'),
  (v_formation, 'qcm', 'En transport national, le délai pour formuler des réserves non apparentes après livraison est de :', '[{"id":"a","label":"24 heures","is_correct":false},{"id":"b","label":"3 jours ouvrés","is_correct":true},{"id":"c","label":"7 jours ouvrés","is_correct":false},{"id":"d","label":"15 jours calendaires","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['reserves','delai-national'], 'mft-2026-gotrm:bc01-05:qcm:3', true, 'Pour les réserves non apparentes en transport national, le destinataire dispose de 3 jours ouvrés à compter de la livraison. Au-delà, la marchandise est présumée livrée conforme.'),
  (v_formation, 'qcm', 'En transport international CMR, le délai pour formuler des réserves non apparentes est de :', '[{"id":"a","label":"3 jours ouvrés","is_correct":false},{"id":"b","label":"7 jours ouvrés","is_correct":true},{"id":"c","label":"14 jours calendaires","is_correct":false},{"id":"d","label":"30 jours","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['cmr','reserves'], 'mft-2026-gotrm:bc01-05:qcm:4', true, 'La CMR (article 30) prévoit 7 jours ouvrés pour les réserves non apparentes. Pour les retards : 21 jours. Pour la perte présumée : 30 jours après le délai convenu.'),
  (v_formation, 'qcm', 'La couleur de l''exemplaire CMR remis à l''expéditeur est :', '[{"id":"a","label":"Bleu","is_correct":false},{"id":"b","label":"Vert","is_correct":false},{"id":"c","label":"Rouge","is_correct":true},{"id":"d","label":"Jaune","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['cmr','exemplaires'], 'mft-2026-gotrm:bc01-05:qcm:5', true, 'Mémo : Rouge = Reste chez l''expéditeur, Bleu = Bouge avec la marchandise (livré au destinataire), Vert = Vit dans les archives du transporteur.'),
  (v_formation, 'qcm', 'Le plafond standard d''indemnisation CMR est de :', '[{"id":"a","label":"33 €/kg","is_correct":false},{"id":"b","label":"8,33 DTS/kg (≈ 10,80 €/kg)","is_correct":true},{"id":"c","label":"1 000 € par colis","is_correct":false},{"id":"d","label":"15 €/kg","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['cmr','plafond'], 'mft-2026-gotrm:bc01-05:qcm:6', true, 'Le plafond CMR (article 23 §3) est de 8,33 DTS par kg, soit environ 10,80 € selon la valeur du DTS. À distinguer du plafond national (33 €/kg ou 1 000 €/colis pour le contrat-type général).'),
  (v_formation, 'qcm', 'L''article 29 de la CMR prévoit que les plafonds d''indemnisation sautent en cas de :', '[{"id":"a","label":"Retard de plus de 30 jours","is_correct":false},{"id":"b","label":"Faute lourde, dol ou faute équivalente du transporteur","is_correct":true},{"id":"c","label":"Refus de l''expéditeur de remplir la CMR","is_correct":false},{"id":"d","label":"Marchandises périssables","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['cmr','article-29'], 'mft-2026-gotrm:bc01-05:qcm:7', true, 'L''article 29 lève les plafonds en cas de dol (faute intentionnelle) ou de faute considérée comme équivalente par le droit applicable (faute lourde / inexcusable). Le transporteur doit alors indemniser intégralement.'),
  (v_formation, 'qcm', 'Une marchandise sous régime T1 est :', '[{"id":"a","label":"Une marchandise communautaire en transit dans un pays tiers","is_correct":false},{"id":"b","label":"Une marchandise non communautaire en transit dans l''UE","is_correct":true},{"id":"c","label":"Une marchandise dédouanée définitivement","is_correct":false},{"id":"d","label":"Une marchandise destinée à une zone franche","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['douane','t1'], 'mft-2026-gotrm:bc01-05:qcm:8', true, 'T1 = marchandise non communautaire (provenance pays tiers) circulant dans l''UE sans avoir été dédouanée. Garantie financière exigée. T2 = inverse (marchandise UE qui transite dans un pays tiers).'),
  (v_formation, 'qcm', 'Une marchandise sous régime T2 est :', '[{"id":"a","label":"Une marchandise non communautaire","is_correct":false},{"id":"b","label":"Une marchandise communautaire qui transite dans un pays tiers (ex : Suisse)","is_correct":true},{"id":"c","label":"Une marchandise refusée par la douane","is_correct":false},{"id":"d","label":"Une marchandise sous procédure spéciale fiscale","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['douane','t2'], 'mft-2026-gotrm:bc01-05:qcm:9', true, 'T2 désigne une marchandise UE qui transite par un pays tiers (typiquement la Suisse) avant retour dans l''UE ou livraison. Le statut UE est conservé pendant le transit grâce au document T2.'),
  (v_formation, 'qcm', 'Le DAU est :', '[{"id":"a","label":"Un document d''ambulance routière","is_correct":false},{"id":"b","label":"Le Document Administratif Unique pour les déclarations en douane","is_correct":true},{"id":"c","label":"Un document fiscal européen","is_correct":false},{"id":"d","label":"Une autorisation préalable de transport","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['dau','definition'], 'mft-2026-gotrm:bc01-05:qcm:10', true, 'Le DAU (Document Administratif Unique) est le formulaire universel de déclaration douanière en UE pour l''exportation, l''importation et le transit. Aujourd''hui largement dématérialisé via Delta XI (France) ou NSTI/NCTS au niveau européen.'),
  (v_formation, 'qcm', 'Le numéro EORI est :', '[{"id":"a","label":"Un identifiant fiscal européen pour le commerce intra-UE","is_correct":false},{"id":"b","label":"L''identifiant douanier européen pour les opérateurs économiques","is_correct":true},{"id":"c","label":"Le code des produits dangereux","is_correct":false},{"id":"d","label":"Un permis de transport spécifique","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['eori','douane'], 'mft-2026-gotrm:bc01-05:qcm:11', true, 'EORI = Economic Operator Registration and Identification. Indispensable pour toute entreprise qui dédouane (export/import). Délivré par la douane française à partir du SIREN.'),
  (v_formation, 'qcm', 'Le système NSTI / NCTS est utilisé pour :', '[{"id":"a","label":"La déclaration de TVA intracommunautaire","is_correct":false},{"id":"b","label":"Le suivi informatisé des opérations de transit douanier T1/T2","is_correct":true},{"id":"c","label":"La gestion des temps de conduite","is_correct":false},{"id":"d","label":"Le contrôle des températures ATP","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['nsti','transit'], 'mft-2026-gotrm:bc01-05:qcm:12', true, 'Le NSTI (français) / NCTS (européen) est le système informatisé de transit. Il génère un MRN (Movement Reference Number) qui suit la marchandise du bureau de départ au bureau d''arrivée.'),
  (v_formation, 'qcm', 'Le carnet TIR couvre :', '[{"id":"a","label":"Les transports temporaires (foires, salons)","is_correct":false},{"id":"b","label":"Le transit international par route entre 76 pays signataires","is_correct":true},{"id":"c","label":"L''importation de marchandises agricoles","is_correct":false},{"id":"d","label":"Le transport maritime UE → Afrique","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['tir','carnet'], 'mft-2026-gotrm:bc01-05:qcm:13', true, 'Le carnet TIR est un document de transit international par route, couvert par une garantie IRU jusqu''à 100 000 € par carnet. 76 pays signataires (UE, Russie, Turquie, Iran, etc.).'),
  (v_formation, 'qcm', 'Le carnet ATA est utilisé pour :', '[{"id":"a","label":"Le transit international permanent","is_correct":false},{"id":"b","label":"Les importations TEMPORAIRES (foires, salons, démonstrations)","is_correct":true},{"id":"c","label":"Le transport de matières dangereuses","is_correct":false},{"id":"d","label":"Les marchandises sous température dirigée","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['ata','temporaire'], 'mft-2026-gotrm:bc01-05:qcm:14', true, 'Le carnet ATA permet l''importation temporaire dans plus de 80 pays sans payer droits ni TVA, à condition de réexporter dans un délai maximum de 12 mois. Très utilisé pour les salons et démonstrations.'),
  (v_formation, 'qcm', 'Combien d''Incoterms 2020 existent au total ?', '[{"id":"a","label":"7","is_correct":false},{"id":"b","label":"9","is_correct":false},{"id":"c","label":"11","is_correct":true},{"id":"d","label":"13","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['incoterms','nombre'], 'mft-2026-gotrm:bc01-05:qcm:15', true, 'Les Incoterms 2020 comportent 11 termes : 7 multimodaux (EXW, FCA, CPT, CIP, DAP, DPU, DDP) et 4 maritimes uniquement (FAS, FOB, CFR, CIF).'),
  (v_formation, 'qcm', 'Lesquels de ces Incoterms sont réservés au transport maritime ?', '[{"id":"a","label":"EXW, FCA, CPT, CIP","is_correct":false},{"id":"b","label":"FAS, FOB, CFR, CIF","is_correct":true},{"id":"c","label":"DAP, DPU, DDP","is_correct":false},{"id":"d","label":"Tous les Incoterms s''appliquent à tous les modes","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['incoterms','maritime'], 'mft-2026-gotrm:bc01-05:qcm:16', true, 'FAS, FOB, CFR et CIF ne s''utilisent que pour le transport maritime ou par voies navigables intérieures. Pour la route, l''air ou le multimodal : utiliser FCA, CPT, CIP, DAP, DPU ou DDP.'),
  (v_formation, 'qcm', 'L''Incoterm où le vendeur prend en charge le maximum (transport, douanes import, TVA destination) est :', '[{"id":"a","label":"EXW","is_correct":false},{"id":"b","label":"DAP","is_correct":false},{"id":"c","label":"DPU","is_correct":false},{"id":"d","label":"DDP","is_correct":true}]'::jsonb, 1, 'facile', ARRAY['incoterms','ddp'], 'mft-2026-gotrm:bc01-05:qcm:17', true, 'DDP (Delivered Duty Paid) charge le vendeur de tout : transport, douanes export, douanes import, TVA destination. Souvent déconseillé hors UE car complexité administrative locale.'),
  (v_formation, 'qcm', 'L''Incoterm où l''acheteur prend en charge le maximum (presque tout) est :', '[{"id":"a","label":"EXW","is_correct":true},{"id":"b","label":"FCA","is_correct":false},{"id":"c","label":"DAP","is_correct":false},{"id":"d","label":"DDP","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['incoterms','exw'], 'mft-2026-gotrm:bc01-05:qcm:18', true, 'EXW (Ex Works) : le vendeur met simplement la marchandise à disposition dans ses locaux. L''acheteur gère tout le reste : enlèvement, douane export, transport, douane import.'),
  (v_formation, 'qcm', 'En CIP, à quel moment le risque est-il transféré du vendeur à l''acheteur ?', '[{"id":"a","label":"À l''arrivée au lieu de destination","is_correct":false},{"id":"b","label":"À la remise au premier transporteur","is_correct":true},{"id":"c","label":"Au chargement à bord du navire","is_correct":false},{"id":"d","label":"Au déchargement","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['incoterms','cip','risque'], 'mft-2026-gotrm:bc01-05:qcm:19', true, 'En CIP (et CPT), le vendeur paie le transport jusqu''à destination MAIS le risque est transféré dès la remise au premier transporteur. Confusion fréquente : transport payé ≠ risque assumé.'),
  (v_formation, 'qcm', 'Pour une vente intra-UE de matériel BTP livrée sur chantier client, l''Incoterm le plus simple à utiliser est :', '[{"id":"a","label":"DDP","is_correct":false},{"id":"b","label":"DAP chantier","is_correct":true},{"id":"c","label":"EXW usine","is_correct":false},{"id":"d","label":"FOB","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['incoterms','choix-pratique'], 'mft-2026-gotrm:bc01-05:qcm:20', true, 'DAP au chantier client : le vendeur livre, le déchargement est fait par le client (qui dispose des moyens sur chantier). Pas de douane car intra-UE. DDP serait excessif (TVA locale gérée par défaut), EXW peu pratique, FOB inadapté à la route.'),
  (v_formation, 'qcm', 'Une « réserve » très vague comme « sous réserve de déballage » est :', '[{"id":"a","label":"Toujours valable juridiquement","is_correct":false},{"id":"b","label":"Très souvent considérée sans valeur juridique car non spécifique","is_correct":true},{"id":"c","label":"Valable seulement si le destinataire est commerçant","is_correct":false},{"id":"d","label":"Valable mais doit être confirmée par lettre recommandée","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['reserves','validite'], 'mft-2026-gotrm:bc01-05:qcm:21', true, 'Une réserve vague ou générale est souvent jugée inopposable au transporteur car elle ne décrit aucune anomalie spécifique. Préférer : « Carton n° X, dim. Y, enfoncé sur la face supérieure, traces d''humidité ».'),
  (v_formation, 'qcm', 'L''absence de preuve de sortie effective de l''UE pour une marchandise exportée peut entraîner :', '[{"id":"a","label":"Un avertissement administratif","is_correct":false},{"id":"b","label":"Un redressement de TVA française à 20 % sur la valeur","is_correct":true},{"id":"c","label":"Le retrait de la licence de transport","is_correct":false},{"id":"d","label":"Aucune conséquence si le client est connu","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['tva','export','preuve'], 'mft-2026-gotrm:bc01-05:qcm:22', true, 'L''exonération de TVA à l''export suppose la preuve de la sortie effective hors UE (DAU visé, CMR, certificat de sortie). À défaut, l''administration française peut réclamer la TVA française à 20 %.'),
  (v_formation, 'qcm', 'Le délai d''apurement classique pour un transit T1 dans l''UE est de :', '[{"id":"a","label":"24 h","is_correct":false},{"id":"b","label":"8 jours","is_correct":true},{"id":"c","label":"30 jours","is_correct":false},{"id":"d","label":"60 jours","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['transit','apurement'], 'mft-2026-gotrm:bc01-05:qcm:23', true, 'Le bureau de départ fixe un délai d''apurement, généralement 8 jours pour un trajet européen. Au-delà, la garantie financière du transporteur peut être activée et des pénalités s''appliquent.'),
  (v_formation, 'qcm', 'L''Incoterm DPU se distingue du DAP par :', '[{"id":"a","label":"L''inclusion de la douane import","is_correct":false},{"id":"b","label":"L''inclusion du déchargement par le vendeur","is_correct":true},{"id":"c","label":"L''inclusion de la TVA destination","is_correct":false},{"id":"d","label":"L''exclusion du transport principal","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['incoterms','dpu'], 'mft-2026-gotrm:bc01-05:qcm:24', true, 'DPU (Delivered at Place Unloaded) = DAP + déchargement par le vendeur. Apparu en 2020 (remplace DAT 2010). Utile quand le vendeur dispose des moyens de déchargement.'),
  (v_formation, 'qcm', 'En cas de retard de livraison, le délai de réserve CMR est de :', '[{"id":"a","label":"7 jours","is_correct":false},{"id":"b","label":"14 jours","is_correct":false},{"id":"c","label":"21 jours","is_correct":true},{"id":"d","label":"30 jours","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['cmr','retard'], 'mft-2026-gotrm:bc01-05:qcm:25', true, 'En cas de retard, la CMR (article 30 §3) prévoit un délai de 21 jours à compter de la mise à disposition pour formuler la réserve. Au-delà, plus de réclamation possible.'),
  (v_formation, 'qcm', 'Pour un transport hors UE (ex : France → Maroc), l''opérateur qui dédouane à l''export doit avoir :', '[{"id":"a","label":"Un EORI européen","is_correct":true},{"id":"b","label":"Un permis de conduire international","is_correct":false},{"id":"c","label":"Une autorisation TIR uniquement","is_correct":false},{"id":"d","label":"Aucune formalité spécifique","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['eori','export'], 'mft-2026-gotrm:bc01-05:qcm:26', true, 'L''EORI est obligatoire pour tout opérateur qui réalise des opérations douanières en UE. Sans EORI, impossible de déposer un DAU export. Le numéro est unique au niveau européen, à partir du SIREN français.'),
  (v_formation, 'qcm', 'Une déclaration de valeur portée sur la lettre de voiture CMR permet :', '[{"id":"a","label":"De diminuer le coût du transport","is_correct":false},{"id":"b","label":"D''augmenter le plafond d''indemnisation au-delà des 8,33 DTS/kg, moyennant supplément","is_correct":true},{"id":"c","label":"De renoncer aux délais de réserves","is_correct":false},{"id":"d","label":"De choisir le tribunal compétent","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['cmr','declaration-valeur'], 'mft-2026-gotrm:bc01-05:qcm:27', true, 'L''article 24 CMR permet de déclarer une valeur supérieure aux 8,33 DTS/kg, contre supplément de prix de transport. Cette déclaration doit figurer expressément sur la lettre de voiture CMR (case dédiée).'),
  (v_formation, 'qcm', 'Quel Incoterm est le moins recommandé pour un export hors UE car charge l''acheteur étranger de la douane export française ?', '[{"id":"a","label":"FCA","is_correct":false},{"id":"b","label":"DAP","is_correct":false},{"id":"c","label":"EXW","is_correct":true},{"id":"d","label":"CPT","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['incoterms','exw','piege'], 'mft-2026-gotrm:bc01-05:qcm:28', true, 'En EXW, l''acheteur étranger doit gérer la douane export française, mais il n''a pas d''EORI européen ! Cela bloque le dédouanement et peut entraîner facturation à tort de la TVA. FCA est l''alternative simple : vendeur fait la douane export, acheteur le reste.');


  -- =================================================================
  -- 5 QR
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qr', 'Votre client transporteur livre 80 colis de matériel chez un grossiste. Le réceptionnaire signe le BL « sous réserve de déballage ». 5 jours plus tard, il signale que 6 colis sont écrasés et entame une procédure d''indemnisation. Analysez la position juridique de votre entreprise et précisez vos arguments de défense.', NULL, 1, 'difficile', ARRAY['reserves','defense','jurisprudence'], 'mft-2026-gotrm:bc01-05:qr:1', true, 'Position juridique :

1. Réserve « sous réserve de déballage » : trop vague, considérée généralement sans valeur juridique. Ce type de mention générique ne décrit aucune anomalie spécifique et est régulièrement écarté par les tribunaux. Elle ne fait pas naître de présomption de responsabilité du transporteur.

2. Délai de réserves non apparentes : 3 jours ouvrés en transport national. Ici, 5 jours sont écoulés → délai dépassé.

3. Conclusion : double argument pour le transporteur :
- Réserve initiale inopposable (trop vague)
- Délai de réserves non apparentes dépassé

Arguments de défense à développer :

a. Formalisme : citer la jurisprudence constante qui invalide les réserves vagues (« sous réserve de déballage », « sous réserve d''inventaire » jugées non conformes par la Cour de cassation).

b. Délais : article L. 133-3 du Code de commerce et contrat-type général prévoient 3 jours ouvrés pour les réserves non apparentes.

c. Présomption de conformité : à défaut de réserve recevable dans les délais, la livraison est présumée conforme et le destinataire ne peut plus prouver une avarie ayant eu lieu pendant le transport.

d. Charge de la preuve : c''est désormais au destinataire de prouver que les colis étaient écrasés à l''arrivée et que cela résulte du transport (vidéosurveillance, témoins, photos datées).

Recommandations préventives à diffuser au client :
- Vérification systématique au déchargement (briefing du personnel réception).
- Réserves précises : « Colis n° 12, 24 et 36 — face supérieure enfoncée — humidité visible. »
- En cas de doute : refus de la livraison ou réception « avec réserves détaillées ».'),
  (v_formation, 'qr', 'Vous organisez un transport de 14 t de pièces automobiles Lyon → Istanbul (Turquie). Décrivez les documents de transport et les formalités douanières à anticiper, ainsi que la séquence T1/T2/CMR sur le parcours.', NULL, 1, 'difficile', ARRAY['international','douane','turquie'], 'mft-2026-gotrm:bc01-05:qr:2', true, 'Documents et formalités :

1. Documents de transport :
- Lettre de voiture CMR en 3 exemplaires (rouge expéditeur, bleu destinataire, vert transporteur)
- Liste de colisage détaillée (pièces auto avec références)
- Facture commerciale (Incoterm CPT Istanbul ou CIP Istanbul)

2. Formalités douanières (avant départ) :
- Vérification de l''EORI de l''entreprise (numéro douanier européen)
- Déclaration d''exportation EX au bureau de Lyon (Delta XI) pour la sortie UE → pays tiers (Turquie)
- Code marchandise (HS / TARIC) à 10 chiffres pour les pièces auto
- Certificat d''origine (formulaire EUR.1 si l''accord UE-Turquie permet la réduction des droits, ou A.TR pour les produits industriels couverts par l''union douanière UE-Turquie)

3. Régime douanier sur le parcours :
- Lyon → frontière UE (Bulgarie/Grèce) : marchandise sous régime UE (intra), aucune formalité particulière.
- Frontière UE → Istanbul : passage en pays tiers (Turquie) → la marchandise sort de l''UE.
- Pour le transit, on utilise typiquement un carnet TIR (Turquie est signataire) qui couvre le passage de l''UE à Istanbul avec garantie IRU.
- Alternativement, un transit T1 (NSTI) jusqu''à la frontière UE puis prise en charge douane turque.

4. Documents douaniers à présenter à la frontière turque :
- A.TR ou EUR.1 (selon nature marchandise)
- Facture commerciale visée
- DAU export visé par la douane française
- CMR signée à chaque étape
- Carnet TIR si utilisé

5. Apurement à l''arrivée :
- Déclaration d''importation au bureau de douane d''Istanbul
- Paiement des droits turcs (réduits si A.TR valide pour produits industriels)
- Mainlevée et livraison

6. Documents à conserver :
- DAU export visé → 5 ans (comptabilité)
- CMR signé à la livraison Istanbul
- Preuve de paiement des droits turcs
- A.TR / EUR.1 et certificats associés

Délais à anticiper :
- Préparation des documents : 5 à 7 jours ouvrés
- Trajet Lyon-Istanbul : 4 à 5 jours en simple équipage (R561 + AETR côté turc)
- Passages frontières : 4 à 24 h selon trafic, scellement et contrôles'),
  (v_formation, 'qr', 'Comparez les Incoterms FCA, CPT, CIP et DAP pour une vente France → Allemagne par route. Pour chacun, indiquez : qui paie le transport, qui assume le risque, et quelle est la mention contractuelle correcte. Recommandez le plus adapté pour un nouveau client allemand.', NULL, 1, 'difficile', ARRAY['incoterms','comparaison','recommandation'], 'mft-2026-gotrm:bc01-05:qr:3', true, 'Comparaison :

1. FCA (Free Carrier) - Strasbourg :
- Vendeur paie : pré-acheminement jusqu''au transporteur, douane export
- Acheteur paie : transport principal, assurance, douane import (intra-UE = aucune)
- Risque transféré : à la remise au transporteur
- Mention : « Vente FCA Strasbourg, France — Incoterms 2020 »
- Avantage : simple, vendeur garde la main sur l''export
- Inconvénient : l''acheteur organise le transport (peut être un frein si le client n''est pas habitué)

2. CPT (Carriage Paid To) - Munich :
- Vendeur paie : transport jusqu''à Munich
- Acheteur paie : assurance (recommandée), douane import (aucune intra-UE)
- Risque transféré : à la remise au premier transporteur (PIÈGE classique)
- Mention : « Vente CPT Munich, Allemagne — Incoterms 2020 »
- Avantage : prix incluant transport (bien perçu côté acheteur)
- Inconvénient : risque transféré tôt, l''acheteur doit assurer

3. CIP (Carriage and Insurance Paid To) - Munich :
- Vendeur paie : transport + assurance jusqu''à Munich
- Acheteur paie : douane import (aucune intra-UE)
- Risque transféré : à la remise au premier transporteur
- Mention : « Vente CIP Munich, Allemagne — Incoterms 2020 »
- Avantage : assurance incluse, package complet
- Inconvénient : nouveau Incoterm 2020 impose assurance « tous risques » (Institute Cargo Clauses A) — coût plus élevé qu''avant

4. DAP (Delivered At Place) - Munich :
- Vendeur paie : transport jusqu''à Munich (lieu précis)
- Acheteur paie : déchargement et douane import (aucune intra-UE)
- Risque transféré : à l''arrivée au lieu de destination
- Mention : « Vente DAP Hauptlagerstrasse 12, 80331 München, Allemagne — Incoterms 2020 »
- Avantage : clarté maximale, risque sur le vendeur jusqu''à l''arrivée, simple côté client
- Inconvénient : vendeur prend plus de risque (couvert par assurance)

Recommandation pour un nouveau client allemand :
DAP (Lieu précis chez le client) est le plus adapté.

Justifications :
- Transaction intra-UE → pas de douane → simplifie tout.
- Le client achète une « livraison clé en main » sans avoir à organiser le transport.
- Le risque est porté par le vendeur (avec assurance prise par lui), ce qui sécurise la relation commerciale neuve.
- Le déchargement est laissé au client (qui dispose typiquement d''un quai en Allemagne).
- Pas de piège du transfert de risque comme en CPT/CIP.

Négociation possible :
- Si l''acheteur préfère gérer son transport (relation logistique intégrée), proposer FCA + remise commerciale.
- Si l''acheteur exige TVA et douane : DDP, mais à éviter sauf si maîtrise de la TVA allemande.'),
  (v_formation, 'qr', 'Lors d''un trajet international Le Havre → Madrid sous régime CMR, votre véhicule est victime d''un cambriolage sur une aire d''autoroute en Espagne. La marchandise valait 85 000 € et pèse 4 200 kg. Le client réclame 85 000 €. Calculez l''indemnité de base CMR et identifiez les conditions qui permettraient au transporteur d''indemniser au-delà du plafond.', NULL, 1, 'difficile', ARRAY['cmr','sinistre','calcul-indemnisation'], 'mft-2026-gotrm:bc01-05:qr:4', true, 'Calcul de l''indemnité CMR de base :

- Plafond CMR : 8,33 DTS/kg (article 23 §3)
- Valeur DTS en 2026 : ≈ 1,30 €
- Plafond par kg : 8,33 × 1,30 ≈ 10,83 €/kg
- Indemnité base : 4 200 kg × 10,83 = 45 486 €

Le transporteur n''indemnise donc que 45 486 € sur les 85 000 € réclamés, soit environ 53 % de la valeur.

Conditions pour aller au-delà du plafond :

1. Déclaration de valeur (CMR art. 24)
- Si l''expéditeur a porté une déclaration de valeur (ex : 85 000 €) sur la CMR, contre supplément de prix, l''indemnité est calculée sur cette valeur déclarée.
- À vérifier : la case « valeur déclarée » de la CMR a-t-elle été remplie ? Le supplément a-t-il été facturé et payé ?

2. Faute lourde / dol (CMR art. 29)
- Si le transporteur a commis une faute lourde ou intentionnelle, les plafonds sautent et l''indemnisation est intégrale (85 000 €).
- Exemples de faute lourde :
  - Aire de stationnement non sécurisée alors qu''une aire CTPark était à 5 km
  - Antivol GPS désactivé volontairement
  - Conducteur ayant quitté le véhicule longtemps sans relais
  - Itinéraire à risque connu non évité

3. Intérêt spécial à la livraison (CMR art. 26)
- Si l''expéditeur a fixé un intérêt spécial (montant pour retard ou perte particulière) avec supplément, ce montant peut s''ajouter à l''indemnité.

Conséquences pratiques pour l''entreprise :

a. Vérifier immédiatement la CMR :
- Case déclaration de valeur remplie ?
- Cases ADR / particularités ?
- Réserves éventuelles à la prise en charge ?

b. Constituer le dossier sinistre :
- Plainte aux autorités espagnoles
- Photos et constat
- Témoignages éventuels
- Disque tachygraphe (heure exacte de l''arrêt)

c. Évaluer la faute lourde potentielle :
- L''entreprise a-t-elle imposé un parking sécurisé ?
- Le conducteur a-t-il respecté les consignes ?
- Si OUI sur les deux, défense en plafond CMR. Si NON, risque art. 29.

d. Activer l''assurance RC transporteur :
- Police habituelle couvre 8,33 DTS/kg
- Vérifier extension « valeur réelle » ou « tous risques »

e. Négocier amiablement :
- Si la responsabilité est partagée, propose un règlement transactionnel à 60-70 % de la valeur réelle.
- Évite un procès long et coûteux.'),
  (v_formation, 'qr', 'Listez les 7 documents indispensables à embarquer pour un trajet international Lyon → Bruxelles avec un chargement de matériel électrique sous régime intra-UE. Pour chacun, précisez son rôle juridique et qui le délivre.', NULL, 1, 'moyen', ARRAY['documents','checklist'], 'mft-2026-gotrm:bc01-05:qr:5', true, 'Documents indispensables (intra-UE, donc PAS de DAU douane) :

1. Lettre de voiture CMR
- Rôle : matérialise le contrat de transport international
- Émetteur : transporteur ou expéditeur
- Distribution : 3 exemplaires (rouge expéditeur, bleu destinataire, vert transporteur)
- Mentions clés : parties, marchandise, valeur, ADR éventuel, déclarations spéciales

2. Bordereau de livraison (BL)
- Rôle : preuve de la livraison, signé par le destinataire
- Émetteur : expéditeur (ici le client français)
- Mentions : références produits, quantités, BL relié au bon de commande

3. Facture commerciale
- Rôle : justificatif fiscal et comptable, base de la TVA intracommunautaire
- Émetteur : vendeur français
- Mentions obligatoires : numéro TVA intracommunautaire vendeur ET acheteur, mention « autoliquidation art. 138 directive TVA UE », montant HT, devise

4. Liste de colisage (packing list)
- Rôle : détail du contenu du chargement (poids, volumes, références)
- Émetteur : expéditeur
- Utilité : facilite contrôles douaniers (même intra-UE peut faire l''objet d''un contrôle aléatoire) et réception destinataire

5. Documents conducteur :
- Permis de conduire en cours de validité
- Carte conducteur tachygraphique (R561)
- Carte qualification conducteur (CQC) ou attestation FCO (formation continue)
- Carte d''identité ou passeport

6. Documents véhicule :
- Carte grise
- Attestation d''assurance véhicule (carte verte)
- Visite technique en cours de validité
- Licence communautaire de transport (LTC) ou copie certifiée pour l''international

7. Attestation de transport ADR (si matériel électrique avec batteries lithium ou tensions spécifiques)
- Rôle : attester du caractère ADR ou non du chargement
- Si ADR :
  - Document de transport ADR (article 5.4.1.1)
  - Consignes écrites (article 5.4.3)
  - Attestation conducteur ADR
  - Certificat d''agrément du véhicule
- Émetteur : expéditeur (responsable ADR)

Bonus : Documents conseillés (non obligatoires intra-UE) :
- Certificat d''origine (si demandé contractuellement)
- Attestation de température (si chaîne du froid à respecter même sans ATP officiel)
- Garantie financière du transporteur

Conséquences en cas de défaut :
- Document obligatoire manquant : amende (90-1 500 €), retard, perte de confiance client.
- Document conducteur manquant : immobilisation du véhicule, retrait permis si récidive.
- ADR non documenté : amende lourde + interdiction de circulation immédiate.');


  -- =================================================================
  -- QUIZZES (4 entraînement + 1 examen blanc)
  -- =================================================================
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — Documents nationaux', 'LVN, BL, mentions obligatoires, réserves nationales.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-05:qcm:1','mft-2026-gotrm:bc01-05:qcm:2','mft-2026-gotrm:bc01-05:qcm:3','mft-2026-gotrm:bc01-05:qcm:21');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — CMR international', 'Lettre de voiture CMR, plafonds, art. 29, déclaration de valeur.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-05:qcm:4','mft-2026-gotrm:bc01-05:qcm:5','mft-2026-gotrm:bc01-05:qcm:6','mft-2026-gotrm:bc01-05:qcm:7','mft-2026-gotrm:bc01-05:qcm:25','mft-2026-gotrm:bc01-05:qcm:27');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — Formalités douanières', 'T1/T2, DAU, EORI, NSTI, carnets TIR/ATA, transit.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-05:qcm:8','mft-2026-gotrm:bc01-05:qcm:9','mft-2026-gotrm:bc01-05:qcm:10','mft-2026-gotrm:bc01-05:qcm:11','mft-2026-gotrm:bc01-05:qcm:12','mft-2026-gotrm:bc01-05:qcm:13','mft-2026-gotrm:bc01-05:qcm:14','mft-2026-gotrm:bc01-05:qcm:22','mft-2026-gotrm:bc01-05:qcm:23','mft-2026-gotrm:bc01-05:qcm:26');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — Incoterms 2020', '11 Incoterms, groupes E/F/C/D, transfert de risque, douanes.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-05:qcm:15','mft-2026-gotrm:bc01-05:qcm:16','mft-2026-gotrm:bc01-05:qcm:17','mft-2026-gotrm:bc01-05:qcm:18','mft-2026-gotrm:bc01-05:qcm:19','mft-2026-gotrm:bc01-05:qcm:20','mft-2026-gotrm:bc01-05:qcm:24','mft-2026-gotrm:bc01-05:qcm:28');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Examen blanc — BC01-05 Documents et douane', '12 QCM en 25 min, seuil 50 %. Synthèse documentaire et douanière.', 'examen', 1500, 50)
  RETURNING id INTO v_quiz_eb;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-05:qcm:1','mft-2026-gotrm:bc01-05:qcm:3','mft-2026-gotrm:bc01-05:qcm:5','mft-2026-gotrm:bc01-05:qcm:6','mft-2026-gotrm:bc01-05:qcm:7','mft-2026-gotrm:bc01-05:qcm:8','mft-2026-gotrm:bc01-05:qcm:11','mft-2026-gotrm:bc01-05:qcm:15','mft-2026-gotrm:bc01-05:qcm:17','mft-2026-gotrm:bc01-05:qcm:19','mft-2026-gotrm:bc01-05:qcm:22','mft-2026-gotrm:bc01-05:qcm:28');

  RAISE NOTICE '✅ GOTRM BC01-05 v2 chargé : 4 leçons, 28 QCM, 5 QR, 5 quizzes (4 entraînement + 1 examen blanc).';
END
$bc01_05$;
