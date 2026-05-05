-- =====================================================================
-- GOTRM (RNCP 40990) — BC01-02 : Le contrat de transport
-- CMR, contrat-type, droits et obligations.
-- =====================================================================

DO $bc01_02$
DECLARE
  v_formation uuid; v_bloc int; v_module uuid;
  v_lesson_1 uuid; v_lesson_2 uuid; v_lesson_3 uuid; v_lesson_4 uuid;
  v_quiz_1 uuid; v_quiz_2 uuid; v_quiz_3 uuid; v_quiz_4 uuid; v_quiz_eb uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc.'; END IF;

  DELETE FROM public.modules WHERE slug = 'gotrm-bc01-02-contrat-cmr';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'BC01-02 — Le contrat de transport : CMR, contrat-type, droits et obligations',
    'gotrm-bc01-02-contrat-cmr', v_bloc,
    'Maîtriser le cadre juridique du transport routier : CMR à l''international, contrat-type général en national, droits et obligations des parties, responsabilités et indemnisations.',
    'intermediaire', 220, 20
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 20, true) ON CONFLICT DO NOTHING;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-02:%';

  -- =================================================================
  -- LEÇON 1 — Le cadre juridique du transport
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Le cadre juridique du transport : CMR vs contrat-type',
    'gotrm-bc01-02-01-cadre-juridique', 1, 50,
$lesson1$
# Le cadre juridique du transport : CMR vs contrat-type

Selon que votre transport est **national** ou **international**, ce ne sont pas les mêmes textes qui s'appliquent. Maîtriser cette distinction est essentiel pour rédiger un contrat efficace et défendre vos intérêts en cas de litige.

> 🎯 **Objectifs de la leçon**
>
> - Distinguer les sources juridiques : **CMR** (international), **contrat-type général** (national).
> - Comprendre la **hiérarchie des normes** applicables.
> - Identifier les **conventions internationales** principales.
> - Maîtriser le **champ d'application** de chaque texte.

---

## 1. La hiérarchie des sources

| # | Source | Champ |
|---|---|---|
| 1 | **Conventions internationales** (CMR notamment) | Transports internationaux |
| 2 | **Code de commerce** (articles L. 132-1 à L. 133-7) | Transports nationaux |
| 3 | **Code des transports** | Régime professionnel et social |
| 4 | **Conventions écrites des parties** (contrat) | Si elles n'enfreignent pas la loi |
| 5 | **Contrats-types** (décret 99-269 et suivants) | À défaut de convention écrite |

> 📌 **Ordre de priorité**
>
> En cas de transport international entre deux pays signataires de la CMR, **la CMR prévaut** sur les conventions des parties (sauf si la convention est plus favorable au client / chargeur). En national pur, le **contrat-type général** s'applique automatiquement à défaut d'écrit particulier.

---

## 2. La CMR (Convention de transport de marchandises par route)

Signée à **Genève en 1956**, ratifiée par plus de **55 pays**.

### 2.1 Champ d'application

| Critère | Détail |
|---|---|
| **Type de transport** | Route uniquement (pas air, mer, fer) |
| **Marchandises** | Tous types (sauf déménagement, courrier postal, transports funéraires) |
| **Géographie** | Lieu de prise en charge OU lieu de livraison dans un pays signataire CMR |
| **Caractère** | Obligatoire et impérative (non dérogeable) |

### 2.2 Le titulaire de la CMR : la lettre de voiture CMR

Document **obligatoire** pour tout transport international CMR. Émis en **3 exemplaires** :

| Exemplaire | Couleur | Pour qui ? |
|---|---|---|
| 1er | **Rouge** | Expéditeur |
| 2e | **Bleu** | Destinataire (accompagne la marchandise) |
| 3e | **Vert** | Transporteur |

### 2.3 Les 14 mentions obligatoires de la CMR

| # | Mention |
|---|---|
| 1 | Lieu et date d'établissement |
| 2 | Nom et adresse de l'expéditeur |
| 3 | Nom et adresse du transporteur |
| 4 | Lieu et date de prise en charge |
| 5 | Lieu prévu de livraison |
| 6 | Nom et adresse du destinataire |
| 7 | Dénomination courante de la nature de la marchandise |
| 8 | Nombre de colis et marques |
| 9 | Poids brut |
| 10 | Frais (port payé / port dû) |
| 11 | Instructions douanières |
| 12 | Indication CMR ("ce transport est soumis aux dispositions de la CMR") |
| 13 | Délais convenus |
| 14 | Liste des documents remis au transporteur |

> ⚠️ **Article 5 CMR**
>
> L'absence de lettre de voiture **n'invalide pas** le contrat. Mais elle complique fortement la preuve. Toujours en émettre une.

---

## 3. Le contrat-type général en national

> Décret 99-269 du 6 avril 1999 (mis à jour). S'applique automatiquement à tout transport routier national de marchandises ≥ 3 tonnes en l'absence de convention écrite particulière.

### 3.1 Articles clés

| Article | Sujet |
|---|---|
| **Article 1er** | Champ d'application |
| **Article 4** | Prise en charge |
| **Article 5** | Vérifications et réserves |
| **Article 7** | Obligations du transporteur |
| **Article 8** | Livraison et destinataire |
| **Article 21** | Plafonds d'indemnisation |
| **Article 26** | Force majeure |

### 3.2 Les contrats-types par spécialité

| Contrat-type | Décret / arrêté |
|---|---|
| **Général** ≥ 3 tonnes | Décret 99-269 du 6/4/1999 |
| **Envois de moins de 3 tonnes** | Décret 99-269 (annexe) |
| **Citerne** | Décret 2000-815 |
| **Bois** | Décret 2007-1226 |
| **Animaux vivants** | Décret 99-754 |
| **Matières dangereuses** | Décret 92-352 |
| **Température dirigée** | Décret 2002-921 |
| **Location avec conducteur** | Décret 2014-644 du 19/06/2014 |
| **Sous-traitance** | Décret 2003-1295 |
| **Commission de transport** | Décret 90-200 |
| **Déménagement** | Décret 99-869 |

---

## 4. Conventions internationales connexes

### 4.1 La Convention de Vienne (CVIM)

Sur la **vente internationale de marchandises**. Régit le contrat de vente, **pas le transport**, mais influence la responsabilité de chaque partie sur les Incoterms.

### 4.2 La Convention TIR

Régime simplifié de transit douanier international. Permet le transport sous **carnet TIR** sans dédouanement à chaque frontière.

### 4.3 Le règlement (CE) n° 1072/2009

Règle l'**accès au marché** du transport routier de marchandises dans l'UE : licence communautaire, cabotage limité (3 opérations en 7 jours).

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| Convention internationale routière de référence | **CMR** (1956) |
| Lieu d'application CMR | Au moins un pays signataire (prise en charge OU livraison) |
| Nb d'exemplaires de la lettre de voiture CMR | **3** (rouge / bleu / vert) |
| Décret du contrat-type général | **99-269 du 6 avril 1999** |
| Contrat-type pour la location avec conducteur | Décret **2014-644** |
| Caractère de la CMR | Obligatoire et impérative |
| Texte UE pour le cabotage | Règlement **(CE) 1072/2009** : 3 opérations / 7 jours |
$lesson1$,
'CMR (1956), contrat-type général décret 99-269, hiérarchie sources, lettre de voiture CMR 3 exemplaires, conventions connexes (CVIM, TIR, règlement UE 1072/2009).'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Les clauses du contrat-type général
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Les clauses essentielles du contrat-type général',
    'gotrm-bc01-02-02-clauses-contrat-type', 2, 60,
$lesson2$
# Les clauses essentielles du contrat-type général

Le contrat-type général est **dense et technique**. Voici les clauses qui, dans 90 % des cas, déterminent l'issue d'un litige.

> 🎯 **Objectifs de la leçon**
>
> - Maîtriser les **délais de mise à disposition** et de livraison.
> - Connaître les **temps d'attente** et leur facturation.
> - Comprendre les conditions de **résiliation** et de **modification**.
> - Identifier les obligations **de chargement et déchargement**.

---

## 1. Délais et temps d'attente (article 4)

### 1.1 Mise à disposition du véhicule

| Type | Délai accordé |
|---|---|
| **Demande ferme acceptée** | Le transporteur s'engage sur la date convenue |
| **Sans engagement particulier** | Délai « raisonnable » selon les usages (en pratique, 24 à 72 h) |

### 1.2 Temps d'attente au chargement / déchargement

> **Référence contrat-type général** : franchise de **30 minutes** au chargement et **30 minutes** au déchargement, par envoi.

| Au-delà de la franchise | Indemnisation |
|---|---|
| **Première heure** | Forfait selon véhicule (ex. ≈ 35 € pour un PL ≥ 7,5 t) |
| **Heures suivantes** | Tarif horaire (≈ 50 €/h) |

> ⚠️ **À retenir**
>
> Pour les **envois de plus de 3 tonnes**, le donneur d'ordre dispose d'**1 heure** par tranche de 5 tonnes pour effectuer chargement et déchargement avant facturation des temps d'attente.

---

## 2. La modification du contrat en cours de transport (article 17)

### 2.1 Qui peut modifier ?

| Phase du transport | Qui a le droit de modifier ? |
|---|---|
| **Avant la prise en charge** | L'expéditeur (donneur d'ordre) |
| **Pendant le transport** | L'expéditeur, **sauf** si la marchandise est en cours de livraison |
| **Pendant la livraison** | Le destinataire devient seul décideur |

### 2.2 Coût des modifications

> **Toute modification engendre un surcoût** : nouveau temps d'attente, déroutement, immobilisation du véhicule. Documenter dans un **avenant écrit**.

---

## 3. Le déroutement et le contre-ordre (article 17)

| Cas | Conséquence |
|---|---|
| **Déroutement vers une autre destination** | Indemnisation du transporteur sur la base d'un tarif horaire ou kilométrique |
| **Contre-ordre avant prise en charge** | Frais de mise à disposition |
| **Contre-ordre pendant transport** | Indemnisation des frais réellement engagés (carburant, kilomètres, temps) |
| **Contre-ordre après livraison** | Aucune obligation pour le transporteur |

---

## 4. La résiliation (article 25)

### 4.1 Cas de résiliation

| Cas | Conséquence |
|---|---|
| **Force majeure** (article 26) | Résiliation sans indemnité |
| **Manquement grave** d'une partie | Résiliation aux torts de la partie défaillante avec dommages-intérêts |
| **Insolvabilité** d'une partie (procédure collective) | Possibilité de résilier sans préavis |

### 4.2 Le préavis dans un contrat-cadre

Pour les contrats-cadres pluriannuels, **préavis raisonnable** exigé (3 à 12 mois selon la durée du contrat). À défaut, indemnisation pour rupture brutale (article L. 442-1 II du Code de commerce).

---

## 5. Obligations de chargement et déchargement

### 5.1 Qui charge ? Qui décharge ?

| Type d'envoi | Qui charge ? | Qui décharge ? |
|---|---|---|
| **Envoi ≥ 3 tonnes** | **Expéditeur** | **Destinataire** |
| **Envoi < 3 tonnes** | **Transporteur** | **Transporteur** |

### 5.2 Cas particuliers

- **Hayon élévateur** : si le véhicule en est équipé, le transporteur peut être tenu d'aider, surtout pour les envois de petits volumes (messagerie, livraison à des particuliers).
- **Manutention sur quai** avec transpalette : à la charge du destinataire.
- **Marchandises hors gabarit** ou exceptionnelles : prestation annexe à facturer.

> 📌 **L'arrimage**
>
> Pour les envois ≥ 3 tonnes, l'**arrimage** est de la responsabilité de l'**expéditeur**. Pour les envois < 3 tonnes, c'est le **transporteur** qui doit veiller à la bonne sécurisation de la marchandise.

---

## 6. Le mode de port (article 14)

| Mode | Qui paie ? | À quel moment ? |
|---|---|---|
| **Port payé** | Expéditeur | Au départ |
| **Port dû** | Destinataire | À l'arrivée |

> ⚠️ **Port dû refusé**
>
> Si le destinataire refuse de payer le port dû, le transporteur peut se prévaloir de son **privilège** (article L. 132-2 C. com.) et conserver la marchandise jusqu'au paiement. Mais il doit en informer l'expéditeur sous 24 h.

---

## 7. Les délais et la rémunération du transport

### 7.1 Délais de paiement (rappel)

> **Article L. 441-11 C. com.** : **30 jours fin de décade** maximum entre transporteurs et donneurs d'ordre. Toute clause contraire est réputée non écrite.

### 7.2 Pénalités de retard de paiement

| Pénalité | Détail |
|---|---|
| **Taux d'intérêt légal majoré de 10 points** | Applicable de plein droit |
| **Indemnité forfaitaire de 40 €** | Pour frais de recouvrement, par facture impayée |

### 7.3 Le privilège du transporteur

> Article L. 132-2 C. com. : le transporteur a un **privilège** sur la marchandise transportée pour le paiement de ses prestations.

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| Franchise temps d'attente chargement/déchargement | **30 minutes** par envoi |
| Pour les envois > 3 t : durée du chargement avant facturation | **1 heure / 5 tonnes** |
| Qui charge ≥ 3 t ? | **Expéditeur** |
| Qui charge < 3 t ? | **Transporteur** |
| Qui peut modifier le contrat avant la livraison ? | **L'expéditeur**, sauf au moment de la livraison |
| Délai paiement L. 441-11 | **30 j fin de décade** maximum |
| Pénalité de retard | Taux légal +10 points + indemnité forfaitaire 40 € |
| Privilège du transporteur | Conserver la marchandise jusqu'au paiement (art. L. 132-2 C. com.) |
$lesson2$,
'Délais et temps d''attente, modifications du contrat, résiliation, obligations chargement/déchargement (≥/<3 t), modes de port, paiement et privilège.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Droits et obligations des parties
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Droits et obligations des parties au contrat',
    'gotrm-bc01-02-03-droits-obligations', 3, 50,
$lesson3$
# Droits et obligations des parties au contrat

Le contrat de transport implique **3 parties** : l'expéditeur, le transporteur, le destinataire. Chacune a des **obligations légales** précises et des **droits** correspondants. Une bonne maîtrise évite 80 % des litiges.

> 🎯 **Objectifs de la leçon**
>
> - Identifier les **obligations** de chaque partie.
> - Maîtriser les **droits de réserves** à la livraison.
> - Comprendre le rôle du **destinataire** (devient partie au contrat).
> - Connaître les recours possibles en cas de manquement.

---

## 1. Les obligations de l'expéditeur

| # | Obligation | Article CMR / Code |
|---|---|---|
| 1 | Fournir une **lettre de voiture** dûment remplie | Article 6 CMR |
| 2 | Donner les **instructions** nécessaires pour la conservation | Article 16 CMR |
| 3 | Présenter la marchandise dans un **état correct** (emballage, conditionnement) | L. 133-1 C. com. |
| 4 | Charger la marchandise (envois ≥ 3 t) | Article 4 contrat-type |
| 5 | **Arrimer** correctement (envois ≥ 3 t) | Article 4 contrat-type |
| 6 | **Payer** le prix (sauf port dû) | Article 14 |
| 7 | Indiquer la **valeur déclarée** ou intérêt spécial à la livraison s'il souhaite des plafonds majorés | Article 24 CMR |
| 8 | Déclarer correctement les **matières dangereuses** | Réglementation ADR |

### 1.1 Conséquence du défaut d'emballage

Si la marchandise est mal emballée, le transporteur peut **émettre des réserves** au moment de la prise en charge. Si le transport cause des avaries en lien avec ce défaut, le transporteur s'**exonère** partiellement ou totalement (article L. 133-1 C. com.).

---

## 2. Les obligations du transporteur

### 2.1 Avant le transport

- **Choisir un véhicule adapté** (PTAC, équipements, climatisation, etc.)
- **Contrôler** la lettre de voiture
- **Vérifier l'état apparent** de la marchandise
- **Émettre des réserves** si défaut d'emballage ou poids douteux

### 2.2 Pendant le transport

| Obligation | Détail |
|---|---|
| **Soigner la marchandise** | Conduite adaptée, contrôle de la sangle, surveillance |
| **Acheminer par l'itinéraire le plus direct** | Sauf instruction contraire |
| **Signaler les empêchements** | Panne, accident, route fermée, etc. |
| **Respecter les modifications** | Du contrat initial, communiquées par l'expéditeur |
| **Respecter les délais** | Convenus ou raisonnables |

### 2.3 À la livraison

- **Mettre la marchandise à disposition** du destinataire
- **Présenter les documents** (lettre de voiture, bons)
- **Décharger** si envoi < 3 tonnes
- **Recueillir les éventuelles réserves** du destinataire

---

## 3. Le destinataire : partie au contrat dès l'origine

> **Spécificité du contrat de transport** : le destinataire est **partie au contrat** alors qu'il n'a pas négocié les clauses. Il bénéficie de **droits** et est tenu d'**obligations**.

### 3.1 Les obligations du destinataire

| Obligation | Détail |
|---|---|
| **Réceptionner** la marchandise | À l'heure et au lieu prévus |
| **Vérifier** l'état | Émettre les réserves si nécessaire |
| **Émarger** la lettre de voiture | Avec date, heure, nom et signature |
| **Décharger** si envoi ≥ 3 tonnes | Article 4 contrat-type |
| **Payer le port dû** si applicable | Article 14 |

### 3.2 Les droits du destinataire

- Refuser la marchandise si elle est manifestement avariée ou non conforme
- Demander la **constatation contradictoire** de l'état (expert)
- Émettre des **réserves** sur la lettre de voiture
- Contre-ordonner le transporteur (donner d'autres instructions de livraison)

---

## 4. Les réserves à la livraison

> 🚛 **C'est LE moment crucial du contrat. Une réserve mal formulée = perte du droit à indemnisation.**

### 4.1 Les conditions de validité des réserves

Selon **l'article L. 133-3 C. com.** :

| Type de dommage | Délai pour les réserves |
|---|---|
| **Dommages apparents** | À la livraison, sur la lettre de voiture |
| **Dommages non apparents** (cachés à l'œil nu) | **3 jours francs** à partir de la livraison, par LRAR |

### 4.2 La forme des réserves

| Critère | Détail |
|---|---|
| **Précises** | « 2 cartons écrasés sur la palette n° 5 » et non « marchandise abîmée » |
| **Datées** | Date et heure exactes |
| **Signées** | Par le destinataire (et idéalement contresignées par le transporteur) |
| **Confirmées par LRAR** | Dans les 3 jours pour les dommages non apparents |

### 4.3 Sanctions en cas de réserves invalides

| Cas | Conséquence |
|---|---|
| Réserves vagues (« avaries ») | Forclusion possible |
| Réserves non signées | Contestables par le transporteur |
| Hors délai pour les dommages cachés | **Perte définitive** du droit à indemnisation |

> 📌 **Conseil pratique**
>
> Préparez à votre équipe **une fiche de réserves type** avec un check-list (cartons, palettes, état emballage, état apparent, vérifications spécifiques selon nature de la marchandise).

---

## 5. Le bordereau de livraison et la lettre de voiture émargée

### 5.1 La lettre de voiture émargée

> Document **fondateur de preuve** de la bonne exécution du contrat.

#### Mentions à compléter à la livraison

- **Date et heure** d'arrivée
- **Nom** du destinataire (en clair)
- **Signature**
- **Réserves éventuelles** (en clair, précises)

### 5.2 Pourquoi l'émargement est crucial

| Avec émargement | Sans émargement |
|---|---|
| Preuve de livraison | Aucune preuve |
| Délai de réclamation court | Délai allongé pour le destinataire |
| Sécurise la facturation | Litige facile sur le paiement |

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| Obligation #1 de l'expéditeur | Fournir lettre de voiture remplie + emballage adapté |
| Obligation #1 du transporteur | Choisir véhicule adapté + soigner la marchandise |
| Le destinataire devient partie au contrat | Dès l'origine (spécificité du contrat de transport) |
| Délai pour réserves dommages apparents | À la livraison, sur la lettre de voiture |
| Délai pour réserves dommages cachés | **3 jours francs** par LRAR |
| Forme de réserves valides | Précises, datées, signées |
| Émargement de la lettre de voiture | Date, heure, nom, signature |
$lesson3$,
'Obligations expéditeur (lettre voiture, emballage, charger ≥3 t, valeur déclarée), transporteur (véhicule, itinéraire, délais), destinataire (récep, vérif, réserves, décharger ≥3 t, port dû), réserves L.133-3 (3 j francs).'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Responsabilités et plafonds d'indemnisation
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Responsabilités et plafonds d''indemnisation',
    'gotrm-bc01-02-04-responsabilites-plafonds', 4, 60,
$lesson4$
# Responsabilités et plafonds d'indemnisation

C'est **LE** chapitre crucial. En cas de litige, ce sont les plafonds qui déterminent ce que vous paierez (ou ce que vous serez payé). Un transporteur qui ne maîtrise pas ces règles s'expose à des pertes massives.

> 🎯 **Objectifs de la leçon**
>
> - Comprendre la **présomption de responsabilité** du transporteur.
> - Maîtriser les **3 causes d'exonération**.
> - Calculer les **plafonds d'indemnisation** (national et international).
> - Connaître la **déclaration de valeur** et l'**intérêt spécial à la livraison**.

---

## 1. Le principe : présomption de responsabilité

> **Article L. 133-1 C. com.** : *« Le voiturier est garant de la perte des objets à transporter et des avaries, hors le cas des forces majeures. »*

### 1.1 Concrètement

Le transporteur est **présumé responsable** entre la prise en charge et la livraison. **Le donneur d'ordre n'a rien à prouver**. C'est au transporteur de démontrer une cause d'exonération pour s'en dégager.

> 📌 **Différence majeure avec une obligation de moyens**
>
> Dans une obligation de moyens (médecin, avocat), il faut **prouver une faute**. Dans une obligation de résultat (transporteur), la faute est **présumée** dès qu'il y a un dommage.

### 1.2 Le champ temporel

```
Prise en charge ────────────────────────────────► Livraison
        │                                              │
        │      Présomption de responsabilité           │
        └───────────► PLEINE et ENTIÈRE ◄──────────────┘
```

---

## 2. Les 3 causes d'exonération

### 2.1 La force majeure

> **Article 1218 C. civ.** : événement **imprévisible**, **irrésistible** et **extérieur**.

| Critère | Définition | Exemple en transport |
|---|---|---|
| **Imprévisibilité** | Au moment de la conclusion du contrat | Tempête classée catastrophe naturelle |
| **Irrésistibilité** | Le transporteur ne pouvait empêcher le dommage | Inondation barre la route |
| **Extériorité** | Causée par un élément extérieur | Incendie de la cabine causé par défaut produit du véhicule = **NON exonératoire** |

> ⚠️ **Cas non force majeure**
>
> - Panne mécanique du véhicule (responsabilité de l'entreprise)
> - Erreur du conducteur
> - Vol "classique" sur aire de service
> - Embouteillage prévisible

### 2.2 Le vice propre de la chose

> Détérioration **due à une cause interne** à la marchandise.

| Exemple | Détail |
|---|---|
| **Fruits trop mûrs** au départ | Détérioration normale en transport |
| **Produit chimique instable** | Décomposition spontanée |
| **Marchandise mal emballée** par l'expéditeur (et avec réserves du transporteur) | Chocs lors du transport |

### 2.3 Le fait ou la faute d'un tiers

| Exemple | Détail |
|---|---|
| **Faute du destinataire** | Refuse de réceptionner, blocage administratif |
| **Faute de l'expéditeur** | Mauvais étiquetage, mauvaise déclaration de matière dangereuse |
| **Acte d'un tiers** | Vol violent, sabotage |

---

## 3. Les plafonds d'indemnisation en NATIONAL (contrat-type général)

> **Règle d'or** : on retient le **MONTANT LE PLUS PETIT** entre les deux calculs.

### 3.1 Pour la perte ou l'avarie

| Type d'envoi | Calcul A | Calcul B |
|---|---|---|
| **< 3 tonnes** | **33 €/kg** de marchandise manquante ou avariée | **1 000 €/colis** perdu, incomplet ou avarié |
| **≥ 3 tonnes** | **20 €/kg** | **3 200 €/tonne d'envoi** |

### 3.2 Exemple de calcul

Vous perdez un **colis de 50 kg**, valeur réelle **1 500 €**.

- Calcul A (< 3 t) : 50 × 33 = **1 650 €**
- Calcul B (< 3 t) : **1 000 €** (1 colis)
- **Plafond retenu = 1 000 €** (le plus petit)
- Vous indemnisez : min(préjudice 1 500 €, plafond 1 000 €) = **1 000 €**

### 3.3 En cas de retard

> **Plafond retard = montant du prix du transport** (pas de la marchandise).

Sauf déclaration d'**intérêt spécial à la livraison**.

### 3.4 Pour le contrat-type température dirigée

| Envoi | Calcul A | Calcul B |
|---|---|---|
| < 3 tonnes | 23 €/kg | 750 €/colis |
| ≥ 3 tonnes | 14 €/kg | 4 000 €/tonne |

---

## 4. Les plafonds d'indemnisation à l'INTERNATIONAL (CMR)

### 4.1 Le DTS (Droit de Tirage Spécial)

> Unité de compte du **FMI** (Fonds Monétaire International). Cours variable, autour de **1,20 € au début 2026**.

### 4.2 Les plafonds CMR

| Type | Plafond |
|---|---|
| **Perte ou avarie** (article 23 CMR) | **8,33 DTS / kg brut** = environ **10 €/kg** |
| **Retard** (article 23.5 CMR) | **Prix du transport** maximum |
| **Frais de transport, douanes, autres frais** | Remboursés intégralement (article 23.4) |

> 📌 **À retenir**
>
> 8,33 DTS/kg ≈ **10 €/kg** soit nettement **moins protecteur** que le plafond national de 33 €/kg pour les envois < 3 t. Conseillez à vos clients la **déclaration de valeur** pour les expéditions internationales de marchandises de valeur.

---

## 5. Déclaration de valeur et intérêt spécial à la livraison

### 5.1 Déclaration de valeur

> Outil pour **substituer le montant déclaré** au plafond légal pour pertes / avaries.

| Critère | Détail |
|---|---|
| **Forme** | Écrite (lettre de voiture, contrat) |
| **Moment** | À la conclusion du contrat |
| **Effet** | Le montant déclaré devient le plafond |
| **Coût** | Surcoût convenu (généralement 0,1 à 0,5 % de la valeur déclarée) |

### 5.2 Intérêt spécial à la livraison

> Outil pour **substituer le montant déclaré** au plafond pour le **retard**.

Mêmes règles que la déclaration de valeur, mais ne couvre pas pertes / avaries.

---

## 6. Quand le transporteur perd ses plafonds

> ⚠️ **Article L. 133-8 C. com.** : le transporteur **ne peut pas** invoquer les plafonds en cas de :

| Cause | Définition |
|---|---|
| **Dol** | Manquement intentionnel |
| **Faute lourde** ou **inexcusable** | Négligence d'une exceptionnelle gravité |
| **Déclaration de valeur** | Substitution du plafond |

### 6.1 Exemples de faute lourde

- Conducteur conduisant en état d'ivresse
- Véhicule sans contrôle technique à jour
- Cargaison non arrimée par négligence flagrante
- Itinéraire grossièrement non conforme à la réglementation ADR

> 📌 **Indemnisation alors due**
>
> Indemnisation **intégrale** sur la **valeur réelle** de la marchandise (sans plafond).

---

## 🧠 Synthèse

| Question | Réponse rapide |
|---|---|
| Article fondateur de la responsabilité | **L. 133-1 C. com.** |
| 3 causes d'exonération | Force majeure, vice propre, faute d'un tiers |
| 3 conditions de la force majeure | Imprévisibilité, irrésistibilité, extériorité |
| Plafond national < 3 t | **33 €/kg** OU **1 000 €/colis** (le plus petit) |
| Plafond national ≥ 3 t | **20 €/kg** OU **3 200 €/tonne** (le plus petit) |
| Plafond international CMR | **8,33 DTS/kg** ≈ 10 €/kg |
| Plafond retard national | Prix du transport |
| Outil pour augmenter le plafond | **Déclaration de valeur** (pertes/avaries) ou **intérêt spécial à la livraison** (retard) |
| Cas de perte des plafonds | Dol, faute lourde, déclaration de valeur |
$lesson4$,
'Présomption de responsabilité L.133-1, 3 causes d''exonération, plafonds national 33 €/kg ou 1 000 €/colis (<3 t), plafond CMR 8,33 DTS/kg, déclaration de valeur, faute lourde fait perdre les plafonds.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- BANQUE QCM REFORMULÉS — BC01-02 (28 questions)
  -- =================================================================

  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qcm', 'Quel texte régit le transport routier international entre 2 pays signataires ?', '[{"id":"a","label":"Le contrat-type général français","is_correct":false},{"id":"b","label":"La CMR (Convention de Genève 1956)","is_correct":true},{"id":"c","label":"Le Code de commerce français","is_correct":false},{"id":"d","label":"Le règlement Bruxelles I","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['gotrm','bc01-02','cmr'], 'mft-2026-gotrm:bc01-02:qcm:1', true, 'CMR (Convention de transport de marchandises par route, signée à Genève en 1956). Plus de 55 pays signataires. S''applique dès qu''un des pays (prise en charge ou livraison) est signataire.'),
  (v_formation, 'qcm', 'En combien d''exemplaires la lettre de voiture CMR est-elle établie ?', '[{"id":"a","label":"2","is_correct":false},{"id":"b","label":"3","is_correct":true},{"id":"c","label":"4","is_correct":false},{"id":"d","label":"5","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['gotrm','bc01-02','cmr','lettre-voiture'], 'mft-2026-gotrm:bc01-02:qcm:2', true, '3 exemplaires CMR : rouge (expéditeur), bleu (destinataire, accompagne la marchandise), vert (transporteur). À distinguer du déménagement (4 exemplaires) ou des transports nationaux (forme libre).'),
  (v_formation, 'qcm', 'Le décret 99-269 du 6 avril 1999 régit :', '[{"id":"a","label":"La CMR","is_correct":false},{"id":"b","label":"Le contrat-type général applicable au transport routier de marchandises ≥ 3 t","is_correct":true},{"id":"c","label":"Le contrat-type matières dangereuses","is_correct":false},{"id":"d","label":"Le règlement européen sur le cabotage","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-02','contrat-type'], 'mft-2026-gotrm:bc01-02:qcm:3', true, 'Décret 99-269 du 6 avril 1999 = contrat-type général en transport routier national. S''applique automatiquement à défaut de convention écrite. Pour les spécialités (citerne, ADR, frigo, etc.), des contrats-types dédiés existent.'),
  (v_formation, 'qcm', 'Combien de pays sont signataires de la CMR ?', '[{"id":"a","label":"Une dizaine","is_correct":false},{"id":"b","label":"Plus de 50","is_correct":true},{"id":"c","label":"Tous les pays du monde","is_correct":false},{"id":"d","label":"Uniquement les pays UE","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['gotrm','bc01-02','cmr','signataires'], 'mft-2026-gotrm:bc01-02:qcm:4', true, 'Plus de 55 pays signataires : Europe entière, plus Russie, Turquie, Maghreb, Moyen-Orient, certains pays d''Asie centrale. PAS les États-Unis, Canada, Japon, Chine, Australie.'),
  (v_formation, 'qcm', 'Combien de mentions obligatoires figurent sur une lettre de voiture CMR ?', '[{"id":"a","label":"7","is_correct":false},{"id":"b","label":"10","is_correct":false},{"id":"c","label":"14","is_correct":true},{"id":"d","label":"20","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['gotrm','bc01-02','cmr','lettre-voiture'], 'mft-2026-gotrm:bc01-02:qcm:5', true, 'Article 6 CMR : 14 mentions obligatoires dont lieu et date d''établissement, identité des parties, lieu de prise en charge / livraison, marchandise, frais, instructions douanières, indication de soumission CMR, délais.'),
  (v_formation, 'qcm', 'Le règlement (CE) 1072/2009 régit notamment :', '[{"id":"a","label":"Les temps de conduite (R561)","is_correct":false},{"id":"b","label":"La CMR","is_correct":false},{"id":"c","label":"L''accès au marché du transport routier dans l''UE et le cabotage","is_correct":true},{"id":"d","label":"Le contrat de travail des conducteurs","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-02','europe','cabotage'], 'mft-2026-gotrm:bc01-02:qcm:6', true, 'Règlement (CE) 1072/2009 : licence communautaire + cabotage limité (maximum 3 opérations en 7 jours après un transport international entrant). Les R561 et R165 sont distincts.'),
  (v_formation, 'qcm', 'Selon le contrat-type général, la franchise au chargement / déchargement est de :', '[{"id":"a","label":"15 minutes","is_correct":false},{"id":"b","label":"30 minutes","is_correct":true},{"id":"c","label":"1 heure","is_correct":false},{"id":"d","label":"2 heures","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-02','contrat-type','attente'], 'mft-2026-gotrm:bc01-02:qcm:7', true, 'Franchise de 30 minutes par envoi au chargement et 30 minutes au déchargement. Au-delà : forfait première heure puis tarif horaire à facturer.'),
  (v_formation, 'qcm', 'Pour un envoi de plus de 3 tonnes, qui est responsable du chargement de la marchandise ?', '[{"id":"a","label":"Le transporteur","is_correct":false},{"id":"b","label":"L''expéditeur","is_correct":true},{"id":"c","label":"Le destinataire","is_correct":false},{"id":"d","label":"Le commissionnaire","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-02','chargement','responsabilite'], 'mft-2026-gotrm:bc01-02:qcm:8', true, 'Article 4 contrat-type : pour les envois ≥ 3 tonnes, le chargement et l''arrimage incombent à l''expéditeur. Pour < 3 t, c''est le transporteur. Le déchargement suit la même règle (≥ 3 t = destinataire, < 3 t = transporteur).'),
  (v_formation, 'qcm', 'Pour un envoi de moins de 3 tonnes, qui décharge la marchandise ?', '[{"id":"a","label":"Le destinataire","is_correct":false},{"id":"b","label":"Le transporteur","is_correct":true},{"id":"c","label":"L''expéditeur","is_correct":false},{"id":"d","label":"Aucune des trois","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-02','dechargement'], 'mft-2026-gotrm:bc01-02:qcm:9', true, 'Pour les envois < 3 t, le transporteur charge ET décharge. Cas typique : messagerie, livraison à des particuliers. Pour ≥ 3 t, c''est l''expéditeur qui charge et le destinataire qui décharge.'),
  (v_formation, 'qcm', 'En cas de port dû refusé par le destinataire, le transporteur peut :', '[{"id":"a","label":"Saisir immédiatement le tribunal","is_correct":false},{"id":"b","label":"Conserver la marchandise en exerçant son privilège (article L. 132-2 C. com.)","is_correct":true},{"id":"c","label":"Vendre la marchandise","is_correct":false},{"id":"d","label":"Restituer immédiatement à l''expéditeur","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['gotrm','bc01-02','privilege','port-du'], 'mft-2026-gotrm:bc01-02:qcm:10', true, 'Privilège du transporteur (L. 132-2 C. com.) : conserver la marchandise jusqu''au paiement. Doit informer l''expéditeur sous 24 h. À distinguer du droit de rétention non spécialisé.'),
  (v_formation, 'qcm', 'Le contrat de transport est qualifié de :', '[{"id":"a","label":"Solennel et bipartite","is_correct":false},{"id":"b","label":"Consensuel, tripartite, à obligation de résultat","is_correct":true},{"id":"c","label":"Aléatoire","is_correct":false},{"id":"d","label":"De moyens","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['gotrm','bc01-02','contrat','caracteristiques'], 'mft-2026-gotrm:bc01-02:qcm:11', true, '3 caractéristiques : CONSENSUEL (échange consentement), TRIPARTITE (expéditeur, transporteur, destinataire), à OBLIGATION DE RÉSULTAT (présomption L. 133-1).'),
  (v_formation, 'qcm', 'L''article fondateur de la responsabilité du transporteur en droit français est :', '[{"id":"a","label":"L. 133-1 C. com.","is_correct":true},{"id":"b","label":"L. 411-1 C. com.","is_correct":false},{"id":"c","label":"1382 C. civ.","is_correct":false},{"id":"d","label":"L. 132-1 C. com.","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-02','responsabilite','article'], 'mft-2026-gotrm:bc01-02:qcm:12', true, 'Article L. 133-1 C. com. : « Le voiturier est garant de la perte des objets à transporter et des avaries, hors le cas des forces majeures. ». Pose la présomption de responsabilité.'),
  (v_formation, 'qcm', 'Combien de causes d''exonération existent pour le transporteur en cas de perte ou avarie ?', '[{"id":"a","label":"1","is_correct":false},{"id":"b","label":"3","is_correct":true},{"id":"c","label":"5","is_correct":false},{"id":"d","label":"Aucune, la responsabilité est totale","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-02','exoneration'], 'mft-2026-gotrm:bc01-02:qcm:13', true, '3 causes d''exonération : (1) Force majeure (imprévisible, irrésistible, extérieure), (2) Vice propre de la chose, (3) Fait ou faute d''un tiers (expéditeur, destinataire, tiers).'),
  (v_formation, 'qcm', 'Quel élément manquant DISQUALIFIE un événement comme force majeure ?', '[{"id":"a","label":"L''imprévisibilité au moment de la conclusion du contrat","is_correct":false},{"id":"b","label":"L''irrésistibilité","is_correct":false},{"id":"c","label":"L''extériorité par rapport à l''entreprise","is_correct":false},{"id":"d","label":"N''importe lequel des 3 critères manquant disqualifie","is_correct":true}]'::jsonb, 1, 'difficile', ARRAY['gotrm','bc01-02','force-majeure'], 'mft-2026-gotrm:bc01-02:qcm:14', true, 'Article 1218 C. civ. : 3 critères CUMULATIFS. Si UN seul manque, ce n''est pas force majeure. Exemple : panne mécanique = imprévisible mais pas extérieure (issue du véhicule du transporteur).'),
  (v_formation, 'qcm', 'Pour un envoi national de moins de 3 tonnes, le plafond d''indemnisation général est :', '[{"id":"a","label":"33 €/kg ou 1 000 €/colis (le plus petit)","is_correct":true},{"id":"b","label":"20 €/kg ou 3 200 €/tonne","is_correct":false},{"id":"c","label":"100 €/kg sans limite","is_correct":false},{"id":"d","label":"La valeur facturée","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-02','plafond','national'], 'mft-2026-gotrm:bc01-02:qcm:15', true, 'Contrat-type général < 3 t : 33 €/kg OU 1 000 €/colis perdu/avarié. On retient le PLUS PETIT des deux. Pour ≥ 3 t : 20 €/kg ou 3 200 €/tonne.'),
  (v_formation, 'qcm', 'Le plafond d''indemnisation à l''international (CMR) pour pertes ou avaries est de :', '[{"id":"a","label":"33 €/kg","is_correct":false},{"id":"b","label":"8,33 DTS / kg de marchandise brute","is_correct":true},{"id":"c","label":"100 €/kg","is_correct":false},{"id":"d","label":"Le prix du transport uniquement","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['gotrm','bc01-02','cmr','plafond'], 'mft-2026-gotrm:bc01-02:qcm:16', true, 'Article 23 CMR : 8,33 DTS / kg brut, soit environ 10 €/kg (1 DTS ≈ 1,20 €). Nettement moins protecteur que le plafond français de 33 €/kg pour < 3 t. Conseiller la déclaration de valeur pour les expéditions internationales.'),
  (v_formation, 'qcm', 'Le DTS (Droit de Tirage Spécial) est :', '[{"id":"a","label":"Une monnaie virtuelle européenne","is_correct":false},{"id":"b","label":"Une unité de compte du FMI","is_correct":true},{"id":"c","label":"Une devise du transport","is_correct":false},{"id":"d","label":"Un droit de douane","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['gotrm','bc01-02','dts','cmr'], 'mft-2026-gotrm:bc01-02:qcm:17', true, 'DTS = unité de compte officielle du FMI (Fonds Monétaire International). Cours variable, autour de 1,20 € début 2026. Utilisé par la CMR pour fixer ses plafonds (8,33 DTS/kg).'),
  (v_formation, 'qcm', 'En cas de retard, le plafond d''indemnisation est généralement :', '[{"id":"a","label":"La valeur de la marchandise","is_correct":false},{"id":"b","label":"Le prix du transport","is_correct":true},{"id":"c","label":"Le double du prix du transport","is_correct":false},{"id":"d","label":"50 €/jour de retard","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-02','retard','plafond'], 'mft-2026-gotrm:bc01-02:qcm:18', true, 'Plafond retard = montant du prix du transport. Sauf déclaration d''intérêt spécial à la livraison qui substitue un montant plus élevé.'),
  (v_formation, 'qcm', 'La déclaration de valeur du donneur d''ordre :', '[{"id":"a","label":"Est gratuite et automatique","is_correct":false},{"id":"b","label":"Substitue le montant déclaré au plafond pour pertes/avaries, contre paiement d''un prix convenu","is_correct":true},{"id":"c","label":"Permet de doubler le délai de transport","is_correct":false},{"id":"d","label":"Engage uniquement l''assurance personnelle du conducteur","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-02','declaration-valeur'], 'mft-2026-gotrm:bc01-02:qcm:19', true, 'Déclaration de valeur écrite, formulée à la conclusion du contrat, contre paiement d''un prix convenu. Substitue le montant déclaré au plafond. Pour le retard, c''est l''intérêt spécial à la livraison.'),
  (v_formation, 'qcm', 'Quel délai a un destinataire PROFESSIONNEL pour confirmer par LRAR des réserves émises pour dommages CACHÉS ?', '[{"id":"a","label":"24 heures","is_correct":false},{"id":"b","label":"3 jours francs","is_correct":true},{"id":"c","label":"10 jours","is_correct":false},{"id":"d","label":"30 jours","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['gotrm','bc01-02','reserves','delai'], 'mft-2026-gotrm:bc01-02:qcm:20', true, 'Article L. 133-3 C. com. : 3 jours francs (hors fériés) pour confirmer les réserves par LRAR pour les dommages NON apparents. Pour les particuliers : 10 jours (article L. 224-65 C. consom.).'),
  (v_formation, 'qcm', 'Le transporteur PERD ses plafonds d''indemnisation en cas de :', '[{"id":"a","label":"Force majeure","is_correct":false},{"id":"b","label":"Vice propre de la chose","is_correct":false},{"id":"c","label":"Faute lourde, dol ou déclaration de valeur","is_correct":true},{"id":"d","label":"Retard simple","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['gotrm','bc01-02','plafond','faute-lourde'], 'mft-2026-gotrm:bc01-02:qcm:21', true, 'Article L. 133-8 C. com. : le transporteur ne peut invoquer les plafonds en cas de DOL (intentionnel), de FAUTE LOURDE ou inexcusable (négligence d''une exceptionnelle gravité), ou de DÉCLARATION DE VALEUR (substitution du plafond par accord).'),
  (v_formation, 'qcm', 'L''émargement de la lettre de voiture par le destinataire à la livraison :', '[{"id":"a","label":"Est facultatif","is_correct":false},{"id":"b","label":"Constitue la preuve de bonne exécution du contrat","is_correct":true},{"id":"c","label":"Engage le destinataire à payer le port dû","is_correct":false},{"id":"d","label":"Annule les éventuelles réserves","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-02','emargement','livraison'], 'mft-2026-gotrm:bc01-02:qcm:22', true, 'Émargement = date, heure, nom, signature à la livraison. Constitue la preuve de bonne exécution. Sans émargement, le destinataire peut réclamer plus longtemps. Les réserves doivent être inscrites SUR la lettre de voiture émargée.'),
  (v_formation, 'qcm', 'En cas de modification du contrat pendant le transport, quel principe s''applique au coût ?', '[{"id":"a","label":"Aucun surcoût","is_correct":false},{"id":"b","label":"Les modifications engendrent un surcoût (déroutement, immobilisation, attente)","is_correct":true},{"id":"c","label":"Le transporteur supporte tout","is_correct":false},{"id":"d","label":"L''assurance prend en charge automatiquement","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-02','modification','contrat'], 'mft-2026-gotrm:bc01-02:qcm:23', true, 'Article 17 contrat-type : toute modification engendre un surcoût (kilomètres supplémentaires, attente, immobilisation). Documenter dans un avenant écrit. Coût indemnisé sur la base du tarif kilométrique ou horaire.'),
  (v_formation, 'qcm', 'Selon le contrat-type général, quelles obligations a l''expéditeur AVANT le transport ?', '[{"id":"a","label":"Aucune, c''est le transporteur qui prépare tout","is_correct":false},{"id":"b","label":"Fournir une lettre de voiture, un emballage adapté, et déclarer la valeur si applicable","is_correct":true},{"id":"c","label":"Uniquement payer le prix","is_correct":false},{"id":"d","label":"Vérifier l''état du véhicule du transporteur","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-02','expediteur','obligations'], 'mft-2026-gotrm:bc01-02:qcm:24', true, 'Obligations expéditeur : fournir lettre de voiture + emballage adapté + arrimage (≥ 3 t) + payer le prix (sauf port dû) + déclarer valeur si applicable + déclarer matières dangereuses (ADR).'),
  (v_formation, 'qcm', 'Le destinataire devient partie au contrat de transport :', '[{"id":"a","label":"À la livraison","is_correct":false},{"id":"b","label":"Dès l''origine du contrat","is_correct":true},{"id":"c","label":"Lors du paiement","is_correct":false},{"id":"d","label":"Jamais","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['gotrm','bc01-02','destinataire','partie-contrat'], 'mft-2026-gotrm:bc01-02:qcm:25', true, 'Spécificité du contrat de transport : le destinataire est PARTIE AU CONTRAT dès l''origine, alors qu''il n''a pas négocié les clauses. Il bénéficie de droits (réserves, refus si avarie manifeste) et est tenu d''obligations (réceptionner, vérifier, payer port dû).'),
  (v_formation, 'qcm', 'Le délai de paiement maximum entre transporteurs et donneurs d''ordre est :', '[{"id":"a","label":"15 jours","is_correct":false},{"id":"b","label":"30 jours fin de décade","is_correct":true},{"id":"c","label":"45 jours fin de mois","is_correct":false},{"id":"d","label":"60 jours date de facture","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['gotrm','bc01-02','paiement','delai'], 'mft-2026-gotrm:bc01-02:qcm:26', true, 'Article L. 441-11 C. com. : 30 jours fin de décade maximum. Toute clause contraire est réputée non écrite. Pénalité : taux légal +10 points + indemnité forfaitaire 40 €.'),
  (v_formation, 'qcm', 'Pour les envois > 3 t, combien de temps a le donneur d''ordre par tranche de 5 tonnes pour effectuer chargement et déchargement ?', '[{"id":"a","label":"30 minutes","is_correct":false},{"id":"b","label":"1 heure","is_correct":true},{"id":"c","label":"2 heures","is_correct":false},{"id":"d","label":"4 heures","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['gotrm','bc01-02','attente','tonnage'], 'mft-2026-gotrm:bc01-02:qcm:27', true, 'Pour les envois > 3 t, le donneur d''ordre dispose d''1 heure par tranche de 5 t pour effectuer chargement et déchargement avant facturation des temps d''attente. Au-delà : franchise 30 min + facturation horaire.'),
  (v_formation, 'qcm', 'L''article 4 du contrat-type général concerne :', '[{"id":"a","label":"Les plafonds d''indemnisation","is_correct":false},{"id":"b","label":"La prise en charge et les conditions de chargement / déchargement","is_correct":true},{"id":"c","label":"La force majeure","is_correct":false},{"id":"d","label":"Le délai de paiement","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['gotrm','bc01-02','contrat-type','article-4'], 'mft-2026-gotrm:bc01-02:qcm:28', true, 'Article 4 du contrat-type général : conditions de prise en charge, chargement, déchargement et arrimage. À distinguer de l''article 21 (plafonds) et 26 (force majeure).');

  -- =================================================================
  -- BANQUE QR — BC01-02 (5 mises en situation)
  -- =================================================================

  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qr',
    'Vous transportez 5 palettes de matériel électronique de Lyon à Marseille pour le compte de SOLAREX. À la livraison, le destinataire constate une casse sur 1 palette (valeur 2 800 €). Le destinataire signe la lettre de voiture sans réserves.

a. Le destinataire peut-il encore engager votre responsabilité ? À quelles conditions ?
b. Quel délai et quel formalisme doit-il respecter ?
c. Si le destinataire émet des réserves dans les délais, quel plafond d''indemnisation s''applique ?
d. Calculez l''indemnité due si la palette pèse 80 kg et 4 cartons sur la palette sont impactés.',
    NULL, 5, 'difficile',
    ARRAY['gotrm','bc01-02','qr','reserves','indemnisation','cas-pratique'],
    'mft-2026-gotrm:bc01-02:qr:1', true,
    'Correction : a. Oui pour dommages NON apparents, en confirmant les réserves par LRAR dans les 3 jours francs. b. Article L. 133-3 C. com. : 3 jours francs (hors fériés) à compter de la livraison, par LRAR avec réserves précises (« 4 cartons écrasés sur la palette n° 3, dommages non visibles à l''ouverture »). c. Plafond contrat-type général < 3 t (envoi 5 palettes mais 1 seule impactée donc < 3 t) : 33 €/kg ou 1 000 €/colis (le plus petit). d. Calcul : kg = 80 × 33 = 2 640 €. Colis = 4 × 1 000 = 4 000 €. Plafond retenu = 2 640 € (le plus petit). Indemnisation due = min(préjudice 2 800 €, plafond 2 640 €) = 2 640 € HT.'),

  (v_formation, 'qr',
    'Un chauffeur de votre entreprise est immobilisé 6 heures sur l''autoroute suite à une tempête (catastrophe naturelle officiellement reconnue par arrêté préfectoral). La cargaison de denrées non périssables (1,5 t) arrive avec des dommages liés à l''humidité.

a. Êtes-vous présumé responsable ? Pourquoi ?
b. Quelle cause d''exonération invoquerez-vous ? Sur quels arguments ?
c. Quels documents devez-vous rassembler pour vous défendre ?
d. Si l''exonération est rejetée, quel plafond d''indemnisation et quel calcul ?',
    NULL, 5, 'difficile',
    ARRAY['gotrm','bc01-02','qr','force-majeure','exoneration','cas-pratique'],
    'mft-2026-gotrm:bc01-02:qr:2', true,
    'Correction : a. Oui (article L. 133-1 C. com.) : présomption de responsabilité du transporteur entre prise en charge et livraison. b. Force majeure (article 1218 C. civ.) si 3 critères : irrésistibilité (vous ne pouviez quitter l''autoroute), imprévisibilité (tempête classée catastrophe naturelle), extériorité (élément extérieur au véhicule). c. Documents : arrêté préfectoral de catastrophe naturelle, bulletin Météo France, attestations des services routiers, photos, déclaration assurance, témoignages d''autres usagers. d. Plafond < 3 t : kg = 1 500 × 33 = 49 500 €. Selon nb de colis si applicable. On retient le plus petit. À comparer au préjudice réel HT.'),

  (v_formation, 'qr',
    'Vous organisez un transport international Paris → Madrid pour MEUBLEX (40 cartons d''ameublement, valeur 18 000 €).

a. Quel régime juridique s''applique automatiquement ?
b. Quelle est la lettre de voiture obligatoire et combien d''exemplaires ?
c. Quel plafond d''indemnisation s''applique en cas de perte totale, et le client est-il bien protégé ?
d. Que recommandez-vous au client pour mieux se protéger financièrement ?',
    NULL, 5, 'moyen',
    ARRAY['gotrm','bc01-02','qr','cmr','international','cas-pratique'],
    'mft-2026-gotrm:bc01-02:qr:3', true,
    'Correction : a. CMR (Convention de Genève 1956), car les deux pays France et Espagne sont signataires. La CMR prévaut sur le contrat-type français. b. Lettre de voiture CMR en 3 exemplaires : rouge (expéditeur), bleu (destinataire), vert (transporteur). 14 mentions obligatoires (article 6 CMR). c. Plafond CMR : 8,33 DTS/kg ≈ 10 €/kg de marchandise brute. Pour 40 cartons d''environ 25 kg = 1 t. Plafond = 10 000 € maximum. PROTECTION INSUFFISANTE pour 18 000 € de marchandise. d. Recommander au client : DÉCLARATION DE VALEUR (au moment de la conclusion du contrat, écrite, contre paiement d''un prix convenu — typiquement 0,1 à 0,5 % de la valeur). Le montant déclaré (18 000 €) substituera le plafond CMR. Alternative : assurance ad valorem souscrite par le client.'),

  (v_formation, 'qr',
    'Vous gérez un litige : un client vous reproche un retard de 48 h sur une livraison J+1 garantie. La marchandise est arrivée intacte mais le client a perdu une vente d''un montant de 15 000 €.

a. Êtes-vous responsable du retard ? Quel principe s''applique ?
b. Quel plafond d''indemnisation s''applique si vous êtes responsable ?
c. Le client peut-il obtenir 15 000 € ? Sous quelle condition aurait-il pu ?
d. Comment formaliser pour l''avenir ce type d''engagement ?',
    NULL, 5, 'difficile',
    ARRAY['gotrm','bc01-02','qr','retard','plafond','cas-pratique'],
    'mft-2026-gotrm:bc01-02:qr:4', true,
    'Correction : a. Oui, sauf force majeure ou faute du donneur d''ordre. Présomption L. 133-1 + L. 133-2 (retard). b. Plafond retard = MONTANT DU PRIX DU TRANSPORT (pas de la marchandise). Si la course coûtait 800 €, indemnisation max = 800 €. c. NON, le client ne peut pas obtenir 15 000 €. POUR L''AVOIR : il aurait dû déclarer un INTÉRÊT SPÉCIAL À LA LIVRAISON au moment de la conclusion du contrat (forme écrite, paiement d''un prix convenu). Cet outil substitue le montant déclaré au plafond pour le retard. d. Pour l''avenir : (1) Sensibiliser commercial à proposer la déclaration d''intérêt spécial à la livraison aux clients qui ont des engagements en aval, (2) Documenter clairement les délais convenus dans le devis et la lettre de voiture, (3) Tarif adapté avec assurance retard intégrée pour les clients exigeants.'),

  (v_formation, 'qr',
    'Distinguez clairement les obligations de :
a. L''expéditeur
b. Le transporteur
c. Le destinataire

Pour chacun, donnez : 3 obligations principales, son statut juridique vis-à-vis du contrat, et un cas concret où le manquement engage sa responsabilité.',
    NULL, 5, 'moyen',
    ARRAY['gotrm','bc01-02','qr','obligations','parties'],
    'mft-2026-gotrm:bc01-02:qr:5', true,
    'Correction : a. EXPÉDITEUR. 3 obligations : (1) Fournir la lettre de voiture remplie, (2) Présenter une marchandise en bon état (emballage adapté), (3) Charger et arrimer (envois ≥ 3 t). Statut : initiateur du contrat, signataire. Manquement : si l''expéditeur emballe mal et que la marchandise s''abîme à cause de cela, sa responsabilité est engagée (vice propre / faute du contractant). b. TRANSPORTEUR. 3 obligations : (1) Choisir un véhicule adapté et soigner la marchandise pendant le transport, (2) Acheminer par le chemin le plus direct et respecter les délais, (3) Livrer au bon destinataire. Statut : exécutant principal, débiteur de l''obligation de résultat. Manquement : si la marchandise est endommagée pendant le transport, présomption de responsabilité L. 133-1, le transporteur est responsable sauf preuve d''une cause d''exonération. c. DESTINATAIRE. 3 obligations : (1) Réceptionner la marchandise, (2) Vérifier et émettre des réserves si nécessaire, (3) Décharger (envois ≥ 3 t) et payer le port dû le cas échéant. Statut : partie au contrat dès l''origine (spécificité). Manquement : si le destinataire ne signale pas un dommage caché dans les 3 jours francs par LRAR, il perd son droit à indemnisation (forclusion, article L. 133-3).');

  -- =================================================================
  -- QUIZZES par leçon + examen blanc
  -- =================================================================

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Cadre juridique du transport — Quiz', 'Quiz sur la CMR, le contrat-type général, la hiérarchie des sources.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026-gotrm:bc01-02:qcm:1','mft-2026-gotrm:bc01-02:qcm:2','mft-2026-gotrm:bc01-02:qcm:3','mft-2026-gotrm:bc01-02:qcm:4','mft-2026-gotrm:bc01-02:qcm:5','mft-2026-gotrm:bc01-02:qcm:6');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Clauses du contrat-type — Quiz', 'Quiz sur les délais, attentes, port, modifications, paiement.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026-gotrm:bc01-02:qcm:7','mft-2026-gotrm:bc01-02:qcm:8','mft-2026-gotrm:bc01-02:qcm:9','mft-2026-gotrm:bc01-02:qcm:10','mft-2026-gotrm:bc01-02:qcm:23','mft-2026-gotrm:bc01-02:qcm:26','mft-2026-gotrm:bc01-02:qcm:27','mft-2026-gotrm:bc01-02:qcm:28');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Droits et obligations des parties — Quiz', 'Quiz sur les obligations expéditeur, transporteur, destinataire, et les réserves.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026-gotrm:bc01-02:qcm:11','mft-2026-gotrm:bc01-02:qcm:20','mft-2026-gotrm:bc01-02:qcm:22','mft-2026-gotrm:bc01-02:qcm:24','mft-2026-gotrm:bc01-02:qcm:25');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Responsabilités et plafonds — Quiz', 'Quiz sur la présomption de responsabilité, les exonérations, les plafonds national et CMR.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026-gotrm:bc01-02:qcm:12','mft-2026-gotrm:bc01-02:qcm:13','mft-2026-gotrm:bc01-02:qcm:14','mft-2026-gotrm:bc01-02:qcm:15','mft-2026-gotrm:bc01-02:qcm:16','mft-2026-gotrm:bc01-02:qcm:17','mft-2026-gotrm:bc01-02:qcm:18','mft-2026-gotrm:bc01-02:qcm:19','mft-2026-gotrm:bc01-02:qcm:21');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Examen blanc — BC01-02', 'Examen blanc Module BC01-02 : 12 QCM en 25 min, seuil 50 %.', 'examen', 1500, 50)
  RETURNING id INTO v_quiz_eb;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank WHERE formation_id = v_formation
    AND source_ref IN ('mft-2026-gotrm:bc01-02:qcm:1','mft-2026-gotrm:bc01-02:qcm:3','mft-2026-gotrm:bc01-02:qcm:7','mft-2026-gotrm:bc01-02:qcm:8','mft-2026-gotrm:bc01-02:qcm:11','mft-2026-gotrm:bc01-02:qcm:12','mft-2026-gotrm:bc01-02:qcm:15','mft-2026-gotrm:bc01-02:qcm:16','mft-2026-gotrm:bc01-02:qcm:20','mft-2026-gotrm:bc01-02:qcm:21','mft-2026-gotrm:bc01-02:qcm:25','mft-2026-gotrm:bc01-02:qcm:26');

  RAISE NOTICE '✅ GOTRM BC01-02 v2 chargé : 4 leçons, 28 QCM, 5 QR, 5 quizzes.';
END
$bc01_02$;
