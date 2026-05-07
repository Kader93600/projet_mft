-- =====================================================================
-- GOTRM (RNCP 40990) — BC01-02 · Le contrat de transport (CMR, contrat-type, droits et obligations)
-- Version 3 (mai 2026) — REFONTE PÉDAGOGIQUE PREMIUM v3_dense
--
-- Bloc 01 : Concevoir, organiser et piloter des opérations de transport.
-- Module pilote n° 2 sur 10 du BC01.
--
-- ▸ 4 leçons (220 min total)
--   1. Le contrat de transport — nature, formation, parties (55 min)
--   2. CMR (international) et contrat-type général (national) (55 min)
--   3. Droits et obligations des parties — exécution du contrat (55 min)
--   4. Modifications, contestations, prescription (55 min)
--
-- Idempotent. Pré-requis : formation 'gotrm' présente.
-- =====================================================================

DO $bc01_02_v3$
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

  -- ─── Remplacement complet du module BC01-02 (v2 → v3) ─────────────
  DELETE FROM public.modules WHERE slug IN (
    'gotrm-bc01-02-contrat-cmr',
    'gotrm-bc01-02-contrat-cmr-v3'
  );

  -- Nettoyage de la banque de questions liées (v2 + v3) pour éviter les doublons
  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND (source_ref LIKE 'mft-2026-gotrm:bc01-02:%'
       OR source_ref LIKE 'mft-2026-gotrm:bc01-02-v3:%');

  INSERT INTO public.modules (
    title, slug, bloc_id, summary, difficulty, duration_min, "order"
  ) VALUES (
    'BC01-02 — Le contrat de transport (CMR, contrat-type, droits et obligations)',
    'gotrm-bc01-02-contrat-cmr',
    v_bloc,
    'Maîtriser la nature juridique du contrat de transport, les sources applicables (CMR, contrat-type général déc. 99-269, Code de commerce, Code des transports), les droits et obligations des trois parties (expéditeur, transporteur, destinataire), et la procédure de réclamation/prescription pour sécuriser ses opérations en national et international.',
    'intermediaire',
    220,
    20
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 20, true) ON CONFLICT DO NOTHING;

  -- =================================================================
  -- LEÇON 1 — Le contrat de transport — nature, formation, parties
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Le contrat de transport — nature, formation, parties',
    'contrat-transport-nature-formation',
    1, 55,
$lessonH1$
# Le contrat de transport — nature, formation, parties

> 🎯 **Objectifs pédagogiques**
>
> À la fin de cette leçon, vous serez capable de :
>
> - **Définir** juridiquement le contrat de transport et le différencier du contrat de commission.
> - **Identifier** les parties au contrat (expéditeur, transporteur, destinataire) et leurs rôles respectifs.
> - **Comprendre** les caractéristiques du contrat (consensuel, synallagmatique, à titre onéreux, commercial).
> - **Décrire** le mécanisme de formation du contrat (offre + acceptation).
> - **Qualifier** une opération mixte (transport vs commission) à l'aide d'indices objectifs.

---

## Introduction

Le contrat de transport est le **socle juridique** sur lequel repose toute opération de transport routier de marchandises. C'est lui qui détermine **qui doit quoi à qui**, **dans quels délais**, **sous quel régime de responsabilité** et **avec quels recours en cas de litige**. Mal le qualifier, c'est s'exposer à des indemnisations imprévues, à des prescriptions perdues, à des contestations de paiement et à des sanctions administratives.

En 2026, le secteur compte près de **40 000 entreprises de transport routier de marchandises** en France et le contentieux du transport représente **environ 8 000 décisions judiciaires par an**, dont **60 % sont liées à une mauvaise qualification juridique du contrat** (commission vs transport, national vs international, contrat-type vs CGV).

Cette leçon vous donne les **bases juridiques solides** : définition, sources, parties, formation, distinction commission/transport. Elle vaut **5 à 8 points d'examen RNCP** et vous permet d'éviter les pièges les plus coûteux du métier.

---

## 1. Définition juridique du contrat de transport

### 1.1 Texte fondateur

Le contrat de transport est défini par convergence de plusieurs textes :

- **Article L. 132-1 du Code de commerce** : régit le contrat de commission de transport.
- **Article L. 132-4 et suivants du Code de commerce** : régit le voiturier (transporteur).
- **Articles L. 1432-1 à L. 1432-14 du Code des transports** : règles spécifiques au transport routier.
- **Décret 99-269 du 6 avril 1999** : contrat-type général applicable à défaut.
- **Convention de Genève du 19 mai 1956 (CMR)** : pour le transport international.

> 📚 **Définition de référence**
>
> Le contrat de transport est la convention par laquelle un **transporteur** s'engage, contre rémunération, à **déplacer matériellement** une marchandise d'un lieu à un autre, dans les délais convenus et à la remettre au destinataire.

### 1.2 Les 3 obligations essentielles du transporteur

Le contrat de transport implique **3 obligations substantielles** sans lesquelles il n'est pas valable :

| Obligation | Contenu | Article de référence |
|---|---|---|
| **Déplacement** | Acheminer matériellement la marchandise du point A au point B | L. 1432-1 C. transports |
| **Conservation** | Préserver l'intégrité physique de la marchandise pendant le trajet | L. 133-1 C. com. |
| **Livraison** | Remettre la marchandise au destinataire désigné, dans les délais | Art. 17 CMR / L. 132-9 C. com. |

L'absence d'une de ces 3 obligations transforme le contrat en autre chose : un simple entreposage (contrat de dépôt), une commission (contrat de commission), une location (contrat de location de véhicule).

### 1.3 Schéma : la chaîne tripartite du contrat de transport

:::flow
1. Expéditeur | Remet matériellement la marchandise au transporteur
2. Transporteur | Achemine et conserve pendant le trajet
3. Destinataire | Reçoit la marchandise, vérifie, paye éventuellement
:::

C'est un **contrat tripartite** par nature : 3 personnes, 3 rôles, 3 régimes de responsabilité distincts. Le destinataire **adhère** au contrat conclu entre l'expéditeur et le transporteur dès qu'il accepte la marchandise (art. L. 132-8 C. com.).

---

## 2. Caractéristiques juridiques du contrat de transport

### 2.1 Un contrat consensuel

Le contrat de transport se forme par le **simple échange des consentements** (offre + acceptation). Pas besoin d'écrit pour qu'il existe juridiquement. Une lettre de voiture (CMR ou national) est souvent rédigée pour des raisons probatoires, mais ce n'est pas une condition de validité.

⚠️ **Conséquence pratique** : un mail, un SMS, un appel téléphonique peuvent suffire à créer un contrat de transport. D'où l'importance de **tracer chaque échange** pour preuve en cas de litige.

### 2.2 Un contrat synallagmatique

Chaque partie a des obligations envers l'autre :

- **Expéditeur** : remettre la marchandise conditionnée + payer (sauf clause CIF).
- **Transporteur** : exécuter le déplacement conformément au contrat.
- **Destinataire** : recevoir la marchandise, faire les réserves, payer (si CIF).

L'**inexécution** d'une obligation par une partie peut entraîner la résolution du contrat ou la suspension de l'obligation correspondante (exception d'inexécution, art. 1219 C. civ.).

### 2.3 Un contrat à titre onéreux

Le transport est rémunéré, fût-ce **symboliquement**. Un transport gratuit (entre amis, dépannage) n'est pas un contrat de transport au sens juridique mais un transport bénévole, soumis au droit commun de la responsabilité civile (art. 1240 C. civ.).

> ⚠️ **Le transport gratuit n'engage la responsabilité du transporteur qu'en cas de faute prouvée** par l'expéditeur (et non par présomption comme dans le contrat de transport rémunéré).

### 2.4 Un contrat commercial

Le contrat de transport routier de marchandises **entre professionnels** (B2B) est commercial par nature (art. L. 110-1 C. com.). Conséquences :

- **Tribunal de commerce** compétent en cas de litige.
- **Prescription commerciale** : 1 an (art. L. 133-6 C. com.).
- **Liberté de la preuve** (mail, SMS, attestation).
- **Solidarité présumée** entre commerçants pour les dettes commerciales.

Si le destinataire est un **particulier**, le régime devient **mixte** (commercial pour le transporteur, civil pour le particulier) avec application possible du Code de la consommation (art. L. 217-4 C. conso.).

---

## 3. La formation du contrat : offre et acceptation

### 3.1 L'offre de transport

L'**offre** émane généralement du donneur d'ordre (souvent l'expéditeur) :
- Demande mail, appel téléphonique, ordre de transport, EDI.
- Doit comporter les **éléments essentiels** : marchandise, lieux, dates, prix.

⚠️ Une offre vague ou ambiguë (« faites-moi un transport demain ») n'est pas une offre **ferme** au sens juridique. Le transporteur doit demander précision avant d'accepter.

### 3.2 L'acceptation par le transporteur

L'acceptation peut être :
- **Expresse** : signature d'un devis, mail de confirmation, accord verbal explicite.
- **Tacite** : début d'exécution (envoi du véhicule au point de chargement).

**Effet immédiat** : dès acceptation, le contrat existe juridiquement, même sans écrit. Le transporteur s'engage à exécuter dans les conditions convenues.

### 3.3 La lettre de voiture : preuve, pas validité

La **lettre de voiture** (national) ou la **CMR** (international) est un document de transport qui :
- **Sert de preuve** du contrat (qui, quoi, quand, combien).
- N'est **pas** une condition de validité du contrat (art. 4 CMR).
- Est obligatoire en transport international (CMR) à 3 exemplaires.
- Est facultative mais conseillée en transport national.

| Type | National (CT général) | International (CMR) |
|---|---|---|
| Document obligatoire ? | Non (recommandé) | **Oui** (art. 4 CMR) |
| Nombre d'exemplaires | Libre | **3** (DO, transporteur, destinataire) |
| Mentions obligatoires | Libres | **Art. 6 CMR** (15 mentions) |
| Force probante | Présomption simple | **Présomption légale** (art. 9 CMR) |

### 3.4 Cas pratique : le contrat verbal d'urgence

**Énoncé** : Le 12 mars 2026 à 14h, un client appelle pour un transport urgent à 17h le même jour. Le transporteur accepte par téléphone. Le véhicule est envoyé. Pas de devis signé, pas de mail, pas de CMR.

**Question** : Le contrat existe-t-il juridiquement ? Quels sont les risques ?

**Correction** :
- **Oui, le contrat existe** : l'offre + l'acceptation verbale + le début d'exécution forment un contrat consensuel valable (art. 1108 C. civ.).
- **Risque** : sans écrit, **la preuve est difficile** en cas de litige (prix, délais, marchandise, conditions). Le contrat-type général (déc. 99-269) s'applique d'office, ce qui peut convenir au transporteur.
- **Action recommandée** : envoyer un mail de **confirmation immédiate** dès la prise de commande verbale, récapitulant les conditions essentielles. Il fait office de **preuve écrite** opposable.

---

## 4. Les parties au contrat de transport

### 4.1 L'expéditeur (chargeur)

L'**expéditeur** est celui qui **remet matériellement** la marchandise au transporteur. Son rôle est central dans la phase amont :

- **Conditionne** la marchandise (palettes, filmage, sangles).
- **Déclare** les caractéristiques (poids, nature, ADR éventuel).
- **Charge** le véhicule (ou supervise le chargement).
- **Signe** la lettre de voiture (preuve de la prise en charge).

Il peut être **différent du donneur d'ordre** : un industriel envoie sa marchandise à un grossiste qui la fait livrer chez un détaillant. L'expéditeur est l'industriel (sur place au chargement), le DO est le grossiste (qui paye), le destinataire est le détaillant.

### 4.2 Le transporteur

Le **transporteur** est l'entreprise qui exécute matériellement le transport contre rémunération.

- **Inscrit au REGT** (Registre Électronique national des entreprises de Transport).
- **4 conditions cumulatives** : établissement, honorabilité, capacité financière (9 000 € pour le 1er véhicule), capacité professionnelle.
- **Responsable de plein droit** des dommages à la marchandise (art. L. 133-1 C. com.).

> 💡 **Le transporteur peut sous-traiter, mais reste responsable envers le DO/expéditeur**. La sous-traitance est limitée à **2 rangs** (art. L. 3224-1 C. transports).

### 4.3 Le destinataire

Le **destinataire** est le bénéficiaire final, celui à qui la marchandise est livrée. Particularité : il **n'est pas signataire** du contrat à l'origine, mais il y **adhère** par l'acceptation de la marchandise (art. L. 132-8 C. com.).

Conséquences :
- Il devient **partie au contrat** dès réception.
- Il peut **agir en responsabilité** contre le transporteur s'il subit un préjudice.
- Il peut être tenu de **payer le transport** si la clause CIF (Cost, Insurance, Freight) est prévue.
- Il **doit faire les réserves** dans les délais légaux (3 jours visible / 7 jours cachée en national).

### 4.4 Tableau récapitulatif des rôles

| Partie | Rôle principal | Obligations clés | Risques |
|---|---|---|---|
| **Expéditeur** | Remet la marchandise | Conditionnement, déclarations, instructions | Refus de prise en charge si non-conforme |
| **Transporteur** | Achemine et conserve | Exécution conforme, livraison, conseil | Indemnité plafonnée 14 €/kg sauf déclaration |
| **Destinataire** | Reçoit | Vérification, réserves, paiement (si CIF) | Forclusion si réserves hors délai |

---

## 5. Distinction contrat de transport vs contrat de commission

### 5.1 Pourquoi cette distinction est cruciale

Le **régime juridique** diffère radicalement :
- **Transport** : obligation de **moyen renforcé**, plafonds CT 14 €/kg.
- **Commission** : obligation de **résultat**, mêmes plafonds CT mais responsabilité plus large (choix des sous-traitants, délais).

Mal qualifier = mal indemniser. Un commissionnaire qui se croit transporteur sous-évalue son risque ; un transporteur qui se croit commissionnaire surfacture sa prestation.

### 5.2 Les 4 indices de qualification

**Indice 1 — Choix libre du mode** : si vous décidez vous-même comment transporter (route, fer, mer, aérien, partenaires), vous êtes **commissionnaire**. Si on vous impose le mode, vous êtes transporteur.

**Indice 2 — Marge sur sous-traitance** : si vous prenez une marge entre votre achat (au sous-traitant) et votre vente (au DO), vous êtes **commissionnaire**. Pas de marge = simple intermédiaire.

**Indice 3 — Garantie du résultat** : si vous garantissez la livraison conforme indépendamment du sous-traitant, vous êtes **commissionnaire** (responsabilité de résultat, art. L. 132-4 C. com.).

**Indice 4 — Refacturation à l'identique** : si vous refacturez le transport au prix exact du sous-traitant + une commission séparée, vous êtes **mandataire** (régime intermédiaire).

### 5.3 Cas pratique chiffré : qualification d'une opération mixte

**Énoncé** : La société **Transex Logistics** reçoit une commande de **Lactalis** pour livrer **24 palettes de yaourts** de Laval à Carquefou, en chaîne du froid 2-4°C. Transex achète la prestation à **Transports Boucherie** pour **620 € HT**. Transex facture à Lactalis **890 € HT** (marge 270 € = 30,3 %). Transex choisit le sous-traitant et garantit la livraison à temps avec respect strict de la chaîne du froid.

**Question** : Transex est-elle commissionnaire ou transporteur ? Quelle est sa responsabilité si la chaîne du froid est rompue (marchandise détruite, valeur 28 000 €) ?

**Correction** :

| Indice | Réponse Transex | Conclusion partielle |
|---|---|---|
| Choix libre du mode ? | OUI (Transex choisit Boucherie) | Commissionnaire |
| Marge sur sous-traitance ? | OUI (270 € de marge) | Commissionnaire |
| Garantie du résultat ? | OUI (chaîne du froid garantie) | Commissionnaire |
| Refacturation à l'identique ? | NON (890 vs 620) | Pas mandataire |

**Conclusion** : Transex est **commissionnaire de transport** (art. L. 132-1 C. com.). En cas de rupture de chaîne du froid :

- Transex **indemnise Lactalis** (responsabilité de résultat) : indemnité plafonnée par contrat-type ATP frigo (souvent 6 €/kg ou 50 % de la valeur).
- Calcul : 24 palettes × 600 kg × 6 €/kg = **86 400 €** (mais plafonné à la valeur réelle 28 000 €) ⇒ **28 000 €** dus à Lactalis.
- Transex se retourne ensuite contre **Boucherie** (action récursoire, art. L. 132-6 C. com.) pour récupérer tout ou partie de l'indemnité.

⚠️ **Sans capacité professionnelle de commissionnaire** (titre + garantie financière 100 k€), Transex serait sanctionnée pour exercice illégal (amende 15 000 € PP / 75 000 € PM, nullité du contrat).

---

## 6. Sources juridiques applicables au contrat de transport

### 6.1 Hiérarchie des sources

```
1. CONSTITUTION (libertés économiques)
        |
2. CODES (Civil, Commerce, Transports)
        |
3. CONVENTIONS INTERNATIONALES (CMR 1956)
        |
4. RÈGLEMENTS UE (cabotage, temps de conduite)
        |
5. DÉCRETS / ARRÊTÉS (contrat-type général 99-269)
        |
6. CGV transporteur (si transmises et acceptées)
        |
7. CONTRAT particulier (devis, bon de commande)
        |
8. USAGES professionnels (FNTR, OTRE)
```

### 6.2 Les 5 textes fondamentaux à connaître

| Texte | Champ d'application | Articles clés |
|---|---|---|
| **Code de commerce** | Voiturier, commissionnaire, prescription | L. 132-1 à L. 133-9 |
| **Code des transports** | Transport routier français | L. 1432-1 à L. 1432-14 |
| **Décret 99-269** | Contrat-type général | Art. 1 à 25 |
| **CMR (1956)** | Transport international | Art. 1 à 51 |
| **Code civil** | Droit commun des contrats | Art. 1101 à 1231 |

### 6.3 Les 5 contrats-types français

Il existe **5 contrats-types** (décrets spécifiques) selon la nature de l'opération :

1. **Contrat-type général** (déc. 99-269) : marchandises générales.
2. **Contrat-type marchandises périssables** (frigorifique) : ATP.
3. **Contrat-type citernes** : matières liquides en vrac.
4. **Contrat-type animaux vivants** : règlement CE 1/2005.
5. **Contrat-type déménagement** : règles spécifiques aux particuliers.

À chaque contrat-type ses **plafonds d'indemnité**, **délais de réclamation** et **règles de responsabilité** propres.

---

## 7. Mini-exercice à faire seul

**Énoncé** : Vous êtes responsable d'exploitation chez **Stef Transport** (transporteur public + activité commission). Un client (PME industrielle, **CA 8 M€**) vous appelle le lundi 9h pour un transport :
- 18 palettes EUR de pièces métalliques (poids 350 kg/palette, valeur 90 000 €).
- Trajet Strasbourg → Madrid (Espagne).
- Départ mercredi, livraison vendredi avant 14h.
- Vous décidez de sous-traiter à un partenaire espagnol pour 1 850 €.
- Vous facturez 2 380 € au client.

**Questions** :
1. Quel est le régime juridique applicable (national ou international) ?
2. Êtes-vous transporteur ou commissionnaire dans cette opération ?
3. Quelle est votre marge brute (€ et %) ?
4. Si la marchandise est volée en route, quel plafond d'indemnité s'applique au client ?

> 💡 Réponses en fin de module (corrections § 4).

---

## 8. Glossaire

- **Contrat de transport** : convention par laquelle un transporteur s'engage à déplacer une marchandise contre rémunération.
- **Contrat de commission** : convention par laquelle un commissionnaire organise un transport en son propre nom pour le compte d'un commettant (art. L. 132-1 C. com.).
- **Voiturier** : terme historique du Code de commerce désignant le transporteur (art. L. 132-4 et s.).
- **Lettre de voiture** : document national qui prouve le contrat de transport.
- **CMR** : Convention de Genève du 19 mai 1956 sur le contrat de transport international de marchandises par route.
- **Consensuel** : se dit d'un contrat formé par le seul échange des consentements (sans formalisme).
- **Synallagmatique** : contrat où chaque partie a des obligations envers l'autre.
- **Action récursoire** : action en remboursement contre un sous-traitant après avoir indemnisé le client (art. L. 132-6 C. com.).
- **CIF (Cost, Insurance, Freight)** : clause par laquelle le destinataire paye le transport et les assurances.
- **Adhésion au contrat** : mécanisme par lequel le destinataire devient partie au contrat dès la réception (art. L. 132-8 C. com.).

---

## 9. Synthèse opérationnelle

1. **Contrat de transport** = déplacer + conserver + livrer (3 obligations cumulatives).
2. **Caractéristiques** : consensuel, synallagmatique, à titre onéreux, commercial (B2B).
3. **3 parties** : expéditeur (remet), transporteur (achemine), destinataire (reçoit, adhère au contrat).
4. **Formation** : offre + acceptation suffisent (mail/SMS/téléphone OK pour preuve).
5. **Lettre de voiture** : preuve, pas validité (sauf CMR international = 3 exemplaires obligatoires).
6. **Distinction transport/commission** : 4 indices (choix mode, marge, garantie résultat, refacturation).
7. **Sources** : C. civ. + C. com. + C. transports + CT (déc. 99-269) + CMR.
8. **5 contrats-types** spécifiques (général, périssables, citernes, animaux, déménagement).

---

## ⚠️ Points de vigilance

- **Contrat verbal valable** mais difficile à prouver. Toujours **mail de confirmation** dans les 60 minutes.
- **Lettre de voiture obligatoire en CMR** (3 exemplaires). Absente = présomption contre le transporteur.
- **Confusion transport/commission** : si vous prenez une marge sans capacité commissionnaire, sanction 15 k€ + nullité du contrat.
- **Destinataire** : il devient partie au contrat dès réception. Réserves obligatoires sous 3 j (visible) / 7 j (cachée).

## 💡 Astuces pro

- **Modèle de mail de confirmation** type : « Bonjour, suite à votre appel de [date/heure], je confirme la prise en charge du transport [origine → destination] pour [date livraison]. Conditions : [prix HT, délai, conditions]. Régime juridique applicable : contrat-type général déc. 99-269 + CGV transporteur jointes. À très vite. »
- **Outil pratique** : créer une checklist en 10 questions pour qualifier transport vs commission à chaque nouvelle opération (gain : 2 minutes par devis, sécurité juridique).
- **Coup malin** : si vous êtes transporteur ET commissionnaire occasionnel, **mentionner clairement** sur chaque devis le régime juridique applicable. Ça évite les contestations en cas de litige.

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : caractéristiques du contrat, parties, sources juridiques, lettre de voiture.
- **QR cas pratique** : « Qualifiez juridiquement l'opération suivante : commission ou transport ? Argumentez et calculez les conséquences indemnitaires. »
- **Oral DP** : « Comment distinguez-vous, dans votre entreprise, les opérations de commission et de transport ? Quelle traçabilité mettez-vous en place ? »

---

## 📌 Synthèse à retenir

### Définition condensée

> **Contrat de transport** = convention par laquelle un transporteur s'engage, contre rémunération, à **déplacer matériellement une marchandise** d'un lieu à un autre et à la **livrer** au destinataire désigné.

### Les 4 caractéristiques

| Caractéristique | Signification |
|---|---|
| **Consensuel** | Formé par échange des consentements (pas d'écrit obligatoire) |
| **Synallagmatique** | Obligations réciproques |
| **À titre onéreux** | Rémunéré (même symbolique) |
| **Commercial** | Tribunal commerce, prescription 1 an, liberté de preuve |

### Les 3 parties et leur rôle

| Partie | Rôle | Article clé |
|---|---|---|
| **Expéditeur** | Remet la marchandise | Conditionnement + déclarations |
| **Transporteur** | Achemine + livre | L. 1432-1 C. transports |
| **Destinataire** | Reçoit + adhère au contrat | L. 132-8 C. com. |

> ⚠️ **Les 4 règles d'or à ne jamais oublier**
>
> - **Contrat verbal valable** mais traçabilité écrite indispensable
> - **Lettre de voiture CMR** : 3 exemplaires obligatoires en international
> - **Distinction commission/transport** : 4 indices (choix mode, marge, garantie, refacturation)
> - **Destinataire devient partie au contrat** dès réception (réserves obligatoires)
$lessonH1$,
'Maîtriser la définition juridique du contrat de transport (3 obligations : déplacer/conserver/livrer), ses caractéristiques (consensuel, synallagmatique, onéreux, commercial), les parties (expéditeur, transporteur, destinataire) et la distinction transport/commission (4 indices objectifs).'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — La CMR et le contrat-type général
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'La CMR (international) et le contrat-type général (national)',
    'cmr-contrat-type-general',
    2, 55,
$lessonH2$
# La CMR (transport international) et le contrat-type général (national)

> 🎯 **Objectifs pédagogiques**
>
> - **Distinguer** clairement le régime national (contrat-type) du régime international (CMR).
> - **Maîtriser** les mentions obligatoires de la lettre de voiture CMR (art. 6).
> - **Calculer** les indemnités CMR (8,33 DTS/kg) et contrat-type (14 €/kg, 750/2 300 €).
> - **Connaître** les délais de réclamation et de prescription.
> - **Choisir** le régime applicable selon l'opération (national, international, mixte).

---

## Introduction

Pour un GOTRM, **savoir quelle convention s'applique** à un transport est aussi crucial que savoir conduire un poids lourd. Une erreur de qualification — appliquer la CMR à un transport national, ou le contrat-type à un transport international — peut **doubler ou diviser par 4** l'indemnité due en cas d'avarie, faire **manquer la prescription** (1 an), ou exposer à des **sanctions douanières**.

Le secteur du transport routier de marchandises français exporte chaque année **environ 215 milliards d'euros de marchandises** en intracommunautaire. Le contentieux CMR représente **environ 12 % des dossiers transport** des cabinets spécialisés, mais **40 % des indemnisations** en valeur, car les marchandises internationales sont souvent à plus forte valeur ajoutée.

Cette leçon vous donne les **réflexes juridiques** pour passer de la commande à la facture en sécurisant le régime applicable.

---

## 1. La Convention CMR (transport international)

### 1.1 Champ d'application

La **Convention de Genève du 19 mai 1956 (CMR)** s'applique à **tout transport routier international de marchandises contre rémunération** dès lors que :

- Le **point de chargement** ET le **point de livraison** sont situés dans **deux États différents** signataires de la CMR.
- Le transport s'effectue **par véhicule** (route uniquement, ou multimodal avec route prédominante).
- Il y a **rémunération** (donc pas de transport gratuit).

> 📚 **56 États signataires** en 2026 : tous les États de l'UE, Royaume-Uni, Suisse, Norvège, Russie, Maroc, Tunisie, Turquie, Iran, Kazakhstan, Mongolie, etc.

### 1.2 Application **automatique** et **impérative**

⚠️ La CMR s'applique **d'office** dès que les conditions de l'art. 1 sont réunies. Les parties **ne peuvent pas y déroger** par contrat (art. 41 CMR : nullité de toute clause contraire).

**Exception unique** : possibilité d'aggraver la responsabilité du transporteur par **déclaration de valeur** (art. 24 CMR) ou **déclaration d'intérêt spécial à la livraison** (art. 26 CMR).

### 1.3 La lettre de voiture CMR

La **lettre de voiture CMR** est obligatoire (art. 4 CMR) et établie en **3 exemplaires originaux** :

| Exemplaire | Destinataire | Couleur | Rôle |
|---|---|---|---|
| 1er | **Expéditeur** | Rouge | Preuve de remise au transporteur |
| 2e | **Destinataire** | Bleu | Preuve de livraison + réserves éventuelles |
| 3e | **Transporteur** | Vert | Conservé pour preuve d'exécution |

### 1.4 Mentions obligatoires de la CMR (art. 6)

L'**article 6 CMR** liste **15 mentions obligatoires** dans la lettre de voiture :

1. Lieu et date d'établissement.
2. Nom et adresse de l'expéditeur.
3. Nom et adresse du transporteur.
4. Lieu et date de prise en charge.
5. Lieu prévu pour la livraison.
6. Nom et adresse du destinataire.
7. Dénomination courante de la marchandise.
8. Nombre de colis, marques et numéros.
9. Poids brut ou quantité.
10. Frais relatifs au transport (port payé, port dû).
11. Instructions douanières.
12. Indication que le transport est soumis à la CMR.
13. Liste des documents remis au transporteur.
14. Délai de livraison (s'il est convenu).
15. Valeur déclarée (si déclarée).

⚠️ **Sanction** : l'absence de mention sur le véhicule indique une présomption contre le transporteur en cas de litige sur le contenu (art. 9 CMR).

### 1.5 Indemnité CMR (art. 23 et 25)

**Plafond CMR** : **8,33 DTS/kg** de poids brut manquant ou avarié.

> 💡 **DTS = Droit de Tirage Spécial** (FMI). Cours moyen 2026 : 1 DTS ≈ **1,30 €**.
>
> Plafond CMR ≈ **10,80 €/kg**.

| Préjudice | Indemnité CMR |
|---|---|
| Perte totale | Valeur marchandise × poids × 8,33 DTS/kg, plafonnée |
| Avarie partielle | Pourcentage de dépréciation × plafond |
| Retard | Plafonné au **prix du transport** (art. 23§5) |
| Frais accessoires | Restitution du fret, droits de douane, autres frais |

**Cas d'aggravation** :
- **Déclaration de valeur** (art. 24) : indemnité au prix réel + surprime de transport.
- **Dol ou faute lourde équivalente** (art. 29) : plafonds inopposables, indemnité intégrale + prescription portée à **3 ans**.

### 1.6 Délais CMR (art. 30)

- **Réserves visibles** à la livraison : immédiates ou **dans les 7 jours calendaires** (hors dimanches et fériés).
- **Réserves cachées** : **21 jours** après livraison.
- **Retard** : réclamation par écrit dans les **21 jours** suivant la livraison.
- **Prescription** : **1 an** (3 ans en cas de dol, art. 32 CMR).

---

## 2. Le contrat-type général (transport national)

### 2.1 Origine et champ d'application

Le **contrat-type général** est annexé au **décret n° 99-269 du 6 avril 1999**. Il s'applique :

- **À défaut** de contrat écrit entre le DO et le transporteur.
- Pour les **transports nationaux** de marchandises générales > 3 t.
- Sous réserve des **5 contrats-types spéciaux** (périssables, citernes, animaux, déménagement, courrier).

### 2.2 Application **par défaut**, **dérogeable**

Contrairement à la CMR, les parties peuvent **déroger** au contrat-type général par **accord écrit** (art. L. 1432-2 C. transports), à condition que les clauses ne soient pas abusives (art. L. 442-1 C. com.).

### 2.3 Indemnités contrat-type général (art. 21 du décret)

| Type d'envoi | Plafond / kg | Plafond / envoi |
|---|---|---|
| **< 3 tonnes** | **23 €/kg** (depuis 2017) | **750 €** |
| **≥ 3 tonnes** | **14 €/kg** | **2 300 €** |

L'indemnité due est **le plus bas** des deux plafonds (kg ou envoi).

### 2.4 Délais nationaux (art. L. 133-3 C. com.)

| Type de réclamation | Délai national | Sanction si dépassé |
|---|---|---|
| Avarie / manquant **visible** | **3 jours** ouvrés | Forclusion |
| Avarie / manquant **caché** | **7 jours** | Forclusion |
| Retard | À la livraison ou **3 jours** | Forclusion |
| Prescription | **1 an** (art. L. 133-6 C. com.) | Action irrecevable |

⚠️ **Forclusion** : si le destinataire ne fait pas les réserves dans les délais, il **perd définitivement** son droit à indemnité.

---

## 3. Comparaison CMR vs Contrat-type général

### 3.1 Tableau comparatif

| Critère | **CMR** | **Contrat-type général** |
|---|---|---|
| **Champ** | 2 pays signataires différents | France métropolitaine |
| **Source** | Convention Genève 1956 | Décret 99-269 (1999) |
| **Application** | Automatique, impérative | Par défaut, dérogeable |
| **Document** | LV CMR 3 ex. **obligatoires** | LV facultative |
| **Plafond / kg** | 8,33 DTS/kg ≈ **10,80 €/kg** | **14 €/kg** (≥3t) / **23 €/kg** (<3t) |
| **Plafond / envoi** | Aucun | **2 300 €** (≥3t) / **750 €** (<3t) |
| **Réserves visibles** | 7 jours | 3 jours |
| **Réserves cachées** | 21 jours | 7 jours |
| **Prescription** | 1 an (3 ans dol) | 1 an |

### 3.2 Cas pratique : comparaison sur même cargaison

**Énoncé** : Une cargaison de **5 t** de pièces métalliques, valeur 60 000 €, est détruite lors d'un accident.

**Hypothèse 1 — Transport national Paris → Lyon** :
- Plafond / kg : 5 000 × 14 = 70 000 €.
- Plafond / envoi (≥ 3 t) : **2 300 €**.
- **Indemnité due = MIN(70 000, 2 300) = 2 300 €**.

**Hypothèse 2 — Transport international Paris → Cologne (Allemagne)** :
- Plafond CMR : 5 000 × 10,80 € = **54 000 €**.
- Pas de plafond global.
- **Indemnité due = 54 000 €**.

**Conclusion** : pour la même cargaison détruite, le client touche **2 300 €** en national vs **54 000 €** en international. Différence : **24× plus**.

---

## 4. Schéma : opération internationale Hambourg-Lyon

:::flow
1. Hambourg (DE) | Chargement chez expéditeur, signature CMR (3 exemplaires)
2. Frontière DE-NL | Contrôle douanier sortie + scellés
3. Anvers (BE) | Transit, scan CT
4. Frontière BE-FR | Contrôle douanier entrée FR
5. Lyon (FR) | Plateforme groupage
6. Destinataire final | Livraison + réserves éventuelles
:::

À chaque maillon, la **lettre de voiture CMR** suit la marchandise. Toute irrégularité est notée sur l'exemplaire correspondant.

---

## 5. Cas pratiques d'application

### 5.1 Cas 1 : transport mixte UE → CH → UE

**Énoncé** : Lyon (France) → Bâle (Suisse) → Vienne (Autriche). Quel régime ?

**Réponse** :
- **CMR** car les 3 pays sont signataires.
- Pas de règlements UE sur la portion suisse.
- LV CMR + DAU douanier obligatoires aux frontières.

### 5.2 Cas 2 : intracommunautaire (Lyon → Madrid)

**Énoncé** : 800 kg hi-tech, valeur 25 000 €, sans déclaration de valeur. Marchandise détruite.

**Réponse** :
- **Régime CMR**.
- Plafond : 800 × 10,80 € = **8 640 €**.
- Préjudice non couvert : 16 360 € à charge du DO.

### 5.3 Cas 3 : multimodal route + ferry

**Énoncé** : Calais → ferry → Manchester (UK signataire CMR).

**Réponse** :
- **CMR** appliquée à l'ensemble (art. 2 CMR).
- Sauf si l'avarie est prouvée comme survenue à bord du navire = régime maritime.

---

## 6. Cas pratique d'examen

**Énoncé** : Vous recevez une commande Lyon → Stuttgart (Allemagne) :
- 28 palettes de pièces auto (8 960 kg).
- Valeur 145 000 €.
- Délai impératif J+2 avant 8h pour chaîne Mercedes.

**Questions** :
1. Quel régime juridique s'applique ?
2. Indemnité maximale due si destruction sans déclaration ?
3. Indemnité due si retard entraîne arrêt chaîne facturé 80 000 € ?
4. Comment sécuriser cette opération ?

**Correction** :

1. **CMR** (deux États signataires).

2. Plafond CMR = 8 960 × 10,80 € = **96 768 €**.

3. **Retard CMR** (art. 23§5) : indemnité plafonnée au **prix du transport** (≈ 2 200 €). Préjudice non couvert : 77 800 €.

4. **Sécurisation** :
   - Déclaration de valeur (art. 24) à 145 000 €.
   - Déclaration d'intérêt spécial à la livraison (art. 26) pour le retard.
   - Assurance « tous risques marchandises ».

> 💡 **Astuce pro** : sur fort enjeu, **toujours** la double déclaration art. 24 + 26 CMR.

---

## 7. Mini-exercice à faire seul

**Énoncé** : Comparez l'indemnité due dans ces 4 cas (marchandise détruite valeur 30 000 €, sans déclaration) :

| Cas | Trajet | Poids |
|---|---|---|
| A | Lille → Marseille | 2 t |
| B | Lille → Marseille | 5 t |
| C | Paris → Bruxelles | 2 t |
| D | Paris → Bruxelles | 5 t |

> 💡 Réponses en fin de module.

---

## 8. Glossaire

- **CMR** : Convention de Genève 1956 sur le transport international par route.
- **DTS** : Droit de Tirage Spécial (FMI). 1 DTS ≈ 1,30 € en 2026.
- **Lettre de voiture CMR** : document international en 3 exemplaires originaux.
- **Contrat-type général** : décret 99-269 applicable d'office en national.
- **Déclaration de valeur** (art. 24 CMR) : lève les plafonds standards.
- **Déclaration d'intérêt spécial** (art. 26 CMR) : couvre le retard.
- **Forclusion** : perte du droit à indemnité par non-respect des délais.
- **DAU** : Document Administratif Unique douanier.
- **e-CMR** : lettre de voiture CMR dématérialisée (norme TransFollow).

---

## 9. Synthèse opérationnelle

1. **CMR** = international, application **automatique et impérative**.
2. **3 exemplaires** lettre de voiture, **15 mentions** art. 6.
3. **Plafond CMR** : 8,33 DTS/kg ≈ **10,80 €/kg**.
4. **CT général** : national, par défaut, dérogeable.
5. **Plafond CT** : 14 €/kg + 2 300 € (≥3t) ou 23 €/kg + 750 € (<3t).
6. **Délais** : CMR 7/21 j ; national 3/7 j.
7. **Prescription** : 1 an (3 ans dol).
8. **Sécurisation** : art. 24 + 26 CMR + assurance ad valorem.

---

## ⚠️ Points de vigilance

- **CMR impérative** : clauses contraires nulles (art. 41).
- **Délais réserves** différents national vs CMR.
- **Forclusion** : signature « sans réserves » = perte du droit.
- **Déclaration de valeur** : indispensable pour > 10 €/kg.

## 💡 Astuces pro

- **CMR pré-imprimée IRU** : 50 € le carnet de 50 exemplaires.
- **e-CMR** : 27 pays UE en 2026, gain productivité 30 %.
- **Contrat-cadre annuel** : sur trajets récurrents internationaux.

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : champ CMR, plafonds, délais, mentions obligatoires.
- **QR cas pratique** : « Comparez national vs CMR pour la même cargaison. »
- **Oral DP** : « Comment gérez-vous les déclarations de valeur ? »

---

## 📌 Synthèse à retenir

### Tableau de bord CMR vs CT général

| Critère | CMR | CT général |
|---|---|---|
| Géographie | International (2 pays signataires) | National FR |
| Plafond / kg | **10,80 €/kg** | **14** (≥3t) / **23** (<3t) €/kg |
| Plafond / envoi | Aucun | **2 300** (≥3t) / **750** (<3t) € |
| Réserves visibles | 7 j | 3 j |
| Réserves cachées | 21 j | 7 j |
| Prescription | 1 an (3 ans dol) | 1 an |

> 📌 **L'indemnité CT est TOUJOURS le MIN des 2 plafonds** (kg × poids OU plafond envoi).

### Mentions CMR (art. 6) — les 5 critiques

1. Lieu et date d'établissement
2. Identités complètes (3 parties)
3. Description marchandise
4. Délai de livraison
5. Référence CMR + déclarations spéciales

> ⚠️ **Les 4 réflexes à avoir absolument**
>
> - **Identifier le régime** AVANT de signer
> - **Lettre voiture CMR** : 3 exemplaires originaux
> - **Déclarations art. 24 + 26 CMR** pour > 10 €/kg
> - **Délais réserves** : 3/7 j national, 7/21 j CMR
$lessonH2$,
'Maîtriser la distinction entre transport national (contrat-type général déc. 99-269) et international (CMR Genève 1956 ; 8,33 DTS/kg ≈ 10,80 €/kg ; lettre de voiture obligatoire en 3 exemplaires), et calculer les indemnités selon le régime applicable.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Droits et obligations des parties
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Droits et obligations des parties — exécution du contrat',
    'droits-obligations-parties',
    3, 55,
$lessonH3$
# Droits et obligations des parties — exécution du contrat

> 🎯 **Objectifs pédagogiques**
>
> - **Lister** les obligations de l'expéditeur, du transporteur et du destinataire.
> - **Comprendre** la responsabilité de plein droit du transporteur (art. L. 133-1 C. com.).
> - **Identifier** les 3 causes d'exonération du transporteur.
> - **Maîtriser** les conséquences d'une signature sans réserves.
> - **Activer** l'action directe en cas de DO insolvable.

---

## Introduction

Une fois le contrat formé, **chaque partie doit exécuter ses obligations** sous peine d'engager sa responsabilité contractuelle. Dans le transport, ces obligations sont **strictement encadrées** par la loi, le contrat-type général et la CMR. La jurisprudence française rendant **environ 1 200 décisions par an** sur les responsabilités du transporteur, il est crucial de connaître précisément ce que vous pouvez ET ne pouvez pas exiger des autres parties.

L'enjeu financier est considérable : un transporteur qui signe un bon de livraison **sans réserves** alors que les palettes sont visiblement endommagées peut **perdre 100 % de son droit à recours** contre le sous-traitant, soit des dizaines de milliers d'euros à supporter seul.

Cette leçon vous arme pour **gérer correctement chaque maillon** : la prise en charge, le transport proprement dit, la livraison et les éventuelles réserves.

---

## 1. Obligations de l'expéditeur

### 1.1 Remise d'une marchandise conditionnée

L'expéditeur doit remettre la marchandise dans un **conditionnement adéquat** au mode de transport choisi (art. L. 1432-3 C. transports). Cela inclut :

- **Emballage** approprié (cartons, palettes, conteneurs).
- **Filmage / sanglage** si palettes (stabilité pour route).
- **Étiquetage** lisible (destinataire, expéditeur, fragile, ce côté en haut).
- **Calage** intérieur pour éviter les chocs.

⚠️ **Conséquence** : un emballage défaillant est un **vice propre** (art. 17§4 CMR / art. 21 CT général) qui **exonère le transporteur** de sa responsabilité en cas d'avarie.

### 1.2 Déclarations exactes et complètes

L'expéditeur doit **déclarer** au transporteur :

- **Nature** de la marchandise (avec code NST si applicable).
- **Poids brut** (réel, vérifiable).
- **Dimensions** (longueur, largeur, hauteur, volume).
- **Conditions ADR** (numéro ONU, classe, groupe d'emballage) si matières dangereuses.
- **Conditions ATP** (température dirigée) si périssables.
- **Valeur déclarée** (au-delà des plafonds standards).

⚠️ **Sanction** d'une fausse déclaration : **art. L. 1432-4 C. transports** — l'expéditeur est responsable des dommages causés par une déclaration inexacte (frais supplémentaires, accident, sanction administrative).

### 1.3 Paiement (sauf clause CIF)

L'expéditeur (ou plus précisément le **donneur d'ordre**) doit payer le transport selon les conditions convenues :

- **Délai LME maximum 60 jours** date facture (art. L. 441-10 C. com.).
- **Pénalités de retard** : taux BCE + 10 points + indemnité forfaitaire 40 €.
- **Clause CIF** : possibilité de basculer le paiement sur le destinataire.

### 1.4 Instructions précises

L'expéditeur doit donner des **instructions claires** sur :
- L'itinéraire si imposé.
- Les créneaux de livraison.
- Les contacts au déchargement.
- Les documents douaniers à présenter (international).

---

## 2. Obligations du transporteur

### 2.1 Prise en charge effective

Le transporteur s'engage à **prendre en charge** la marchandise à la date et au lieu convenus. Cela implique :

- **Présentation du véhicule** dans les délais (tolérance ~30 minutes).
- **Vérification du chargement** (nombre de colis, état apparent).
- **Émission de réserves** si défaut visible (palette cassée, emballage déchiré, marchandise mouillée).
- **Signature de la lettre de voiture** (national) ou CMR (international).

> 💡 **Attention aux réserves de prise en charge** : si le transporteur signe sans réserves alors que les palettes sont visiblement endommagées, il **assume la dégradation initiale** et ne pourra pas se retourner contre l'expéditeur.

### 2.2 Exécution conforme au contrat

Le transporteur doit exécuter **conformément** aux conditions convenues :

| Obligation | Description |
|---|---|
| **Délai** | Respecter la date/heure de livraison (engagée ou indicative) |
| **Itinéraire** | Suivre l'itinéraire imposé si convenu |
| **Intégrité** | Conserver la marchandise sans dommage |
| **Sécurité** | Respecter le code de la route, RSE, ADR |
| **Confidentialité** | Pas de divulgation des informations commerciales |

### 2.3 Responsabilité de plein droit (art. L. 133-1 C. com.)

> 📚 **Article L. 133-1 du Code de commerce**
>
> « Le voiturier est garant de la perte des objets à transporter, hors les cas de force majeure. Il est garant des avaries autres que celles qui proviennent du vice propre de la chose ou de la faute de l'expéditeur. »

Cette responsabilité est **de plein droit** (présomption simple) : le client n'a **pas à prouver la faute** du transporteur, il suffit de démontrer le préjudice.

**3 causes d'exonération possibles** :

1. **Force majeure** : événement imprévisible, irrésistible, extérieur (catastrophe naturelle, attentat).
2. **Vice propre de la marchandise** : défaut d'emballage, périssable mal conservé.
3. **Faute de l'expéditeur ou du destinataire** : instructions erronées, déclaration inexacte.

### 2.4 Livraison au destinataire désigné

La **livraison** consiste à remettre la marchandise au destinataire désigné :
- Au **lieu indiqué** sur la lettre de voiture.
- À la **personne habilitée** (signature requise).
- **Avec tous les documents** d'accompagnement (BL, CMR, certificats).

⚠️ **Livraison à mauvaise personne** = faute lourde. Sanction : indemnité intégrale, prescription portée à 3 ans.

### 2.5 Obligation de conseil

Le transporteur, professionnel du déplacement, a un **devoir de conseil** envers son client (jurisprudence constante depuis Cass. com. 5 mai 1987) :

- Alerter sur les **risques** d'un emballage insuffisant.
- Recommander une **assurance ad valorem** pour marchandise > 10 €/kg.
- Signaler les **délais** réalistes versus engagés.
- Informer des **obligations douanières** à l'international.

---

## 3. Obligations du destinataire

### 3.1 Réception de la marchandise

Le destinataire doit **réceptionner** la marchandise dans les conditions convenues. Cela implique :
- **Présence** d'une personne habilitée à la livraison.
- **Mise à disposition** des moyens de déchargement (sauf si à la charge du transporteur).
- **Respect** des créneaux convenus.

⚠️ **Refus injustifié** : le destinataire est tenu de **payer les frais** de re-livraison ou de stockage (art. L. 1432-7 C. transports).

### 3.2 Vérification à l'arrivée

Le destinataire doit **vérifier la marchandise** avant signature du bon de livraison :
- Nombre de colis (comparé à la lettre de voiture).
- État extérieur des emballages.
- Température (si ATP).
- Plombs/scellés intacts (international).

### 3.3 Émission des réserves

C'est une **obligation cruciale**. Si le destinataire ne fait pas les réserves dans les délais légaux, il **perd définitivement** son droit à indemnité (forclusion).

| Type d'avarie | National (CT) | International (CMR) |
|---|---|---|
| **Visible** | 3 jours | 7 jours |
| **Cachée** | 7 jours | 21 jours |
| **Retard** | À la livraison ou 3 j | 21 jours |

**Forme** : les réserves doivent être :
- **Précises** (nature et étendue du dommage).
- **Écrites** (sur la LV/CMR + courrier recommandé confirmant).
- **Notifiées** au transporteur (mail ou LRAR).

### 3.4 Paiement (si CIF)

Si le contrat prévoit la clause **CIF** ou « port dû », le destinataire paye le transport. À défaut, il appartient au DO/expéditeur (clause « port payé »).

---

## 4. Responsabilité de plein droit du transporteur

### 4.1 Mécanisme et présomption

L'article L. 133-1 C. com. instaure une **présomption simple** de responsabilité du transporteur. Le client n'a qu'à prouver :
1. **L'existence du contrat** (lettre de voiture, mail).
2. **Le préjudice** (avarie, perte, retard).
3. **Le lien temporel** (entre prise en charge et livraison).

Le transporteur, pour s'exonérer, doit prouver **l'une des 3 causes** d'exonération.

### 4.2 Cas pratique : le transporteur signe sans réserves

**Énoncé** : Le 14 mars 2026, **Transports Martin** prend en charge **30 palettes** de produits chimiques chez Sanofi (Évry). Le conducteur **signe la lettre de voiture sans réserves**, alors que **3 palettes sont visiblement penchées et 1 colis a un emballage déchiré**. À l'arrivée chez le destinataire (Lille), **15 colis sont endommagés**. Le destinataire réclame **18 000 €**.

**Question** : Quelle est la situation juridique de Transports Martin ?

**Correction** :

1. **Présomption de bon état initial** : la signature sans réserves vaut **acceptation de l'état apparent** des marchandises au chargement (art. 9 CMR pour international, jurisprudence pour national).

2. **Conséquences** :
   - Transports Martin est **présumé responsable** des 15 colis endommagés.
   - Indemnité due : 18 000 € (sauf si plafonds CT applicables).
   - **Pas de recours efficace** contre Sanofi car aucune réserve initiale.

3. **Calcul indemnité** (CT général, envoi > 3 t) :
   - Poids : 15 colis × 25 kg ≈ 375 kg.
   - Plafond / kg : 375 × 14 = 5 250 €.
   - Plafond / envoi : 2 300 €.
   - **Indemnité due = 2 300 €** (le plus bas).

4. **Préjudice à la charge du destinataire** : 18 000 − 2 300 = **15 700 €**.

5. **Leçon** : le conducteur aurait dû **inscrire des réserves précises** sur la LV : « 3 palettes penchées, 1 colis emballage déchiré (palette n° 12). » Ces réserves auraient permis :
   - De **transférer** la responsabilité initiale à Sanofi.
   - De **limiter** la responsabilité de Transports Martin aux dommages survenus pendant le transport.

---

## 5. Indemnisation et déclaration de valeur

### 5.1 Plafonds standards

| Régime | Plafond / kg | Plafond / envoi |
|---|---|---|
| **CT général ≥ 3 t** | 14 €/kg | 2 300 € |
| **CT général < 3 t** | 23 €/kg | 750 € |
| **CMR** | 8,33 DTS ≈ 10,80 €/kg | Aucun |

### 5.2 Déclaration de valeur préalable

Pour **lever les plafonds**, l'expéditeur doit faire une **déclaration de valeur** par écrit **avant** le transport :

- Mention sur la lettre de voiture (case dédiée).
- Surprime de transport (généralement 0,3-0,5 % de la valeur déclarée).
- Souscription d'une **assurance ad valorem** par l'expéditeur.

### 5.3 Assurance ad valorem

L'**assurance ad valorem** (« sur la valeur ») couvre la marchandise au prix réel :
- Souscription par l'expéditeur ou le destinataire.
- Prime ~0,15-0,30 % de la valeur déclarée.
- Couverture incluant le vol, l'avarie, la perte totale.
- Subrogation de l'assureur dans les droits de l'assuré contre le transporteur.

### 5.4 Cas pratique chiffré

**Énoncé** : Cargaison 200 kg de bijoux, valeur 500 000 €. 3 hypothèses :

| Hypothèse | Régime | Indemnité due |
|---|---|---|
| **A** : sans déclaration, vol national | CT général < 3 t | MIN(200×23 ; 750) = **750 €** |
| **B** : avec déclaration de valeur 500 000 € national | CT dérogé | **500 000 €** (couvert ad valorem) |
| **C** : avec déclaration CMR international | CMR + art. 24 | **500 000 €** + restitution fret |

**Différence A vs B/C** : un client qui ne fait pas de déclaration de valeur perd **499 250 €** sur sinistre.

---

## 6. L'action directe (art. L. 3242-3 C. transports)

### 6.1 Mécanisme

L'**action directe** est une protection unique au transport (loi Gayssot 1992) qui permet au transporteur impayé d'exiger le paiement de **l'expéditeur ou du destinataire** si le donneur d'ordre est insolvable.

> 📚 **Article L. 3242-3 C. transports**
>
> « Si le donneur d'ordre ne paie pas, le transporteur peut, dans les 30 jours suivant la mise en demeure, exiger le paiement de l'expéditeur ou du destinataire, qui sont solidairement tenus du paiement du prix du transport. »

### 6.2 Conditions d'exercice

1. **Mise en demeure** du DO par LRAR.
2. **Délai de 30 jours** sans paiement.
3. **Action contre l'expéditeur ou le destinataire** dans le **délai d'un an** (prescription).

### 6.3 Cas pratique

**Énoncé** : Vous transportez pour **Grossiste X** qui dépose le bilan. Facture impayée 8 500 €. Marchandise livrée chez **Détaillant Y**.

**Réponse** :
- Mise en demeure de Grossiste X par LRAR.
- 30 jours sans paiement.
- Action directe contre **Détaillant Y** (destinataire) ou **Fabricant Z** (expéditeur).
- Choix : généralement **Détaillant Y** car solvable et a déjà reçu/vendu la marchandise.

---

## 7. Mini-exercice à faire seul

**Énoncé** : Le 18 mars 2026, vous livrez **40 palettes de meubles** à un client GMS (Conforama). Le manutentionnaire signe le bon de livraison **sans réserves**. Le lendemain, le directeur de magasin appelle : **8 palettes ont été endommagées par un chariot pendant le déchargement** (manipulation par le personnel Conforama). Il réclame 12 000 €.

**Questions** :
1. Le destinataire peut-il vous tenir responsable ?
2. Comment vous protéger en pratique ?
3. Que prévoir dans les CGV ?

> 💡 Réponses en fin de module.

---

## 8. Glossaire

- **Responsabilité de plein droit** : responsabilité présumée sans preuve de faute (art. L. 133-1 C. com.).
- **Force majeure** : événement imprévisible, irrésistible, extérieur (3 critères).
- **Vice propre** : défaut intrinsèque de la marchandise (mauvais emballage, périssable mal conservé).
- **Réserves** : observations écrites sur la LV à la livraison.
- **Forclusion** : perte du droit à indemnité par non-respect des délais.
- **CIF** (Cost, Insurance, Freight) : clause où le destinataire paye.
- **Action directe** : droit du transporteur impayé contre l'expéditeur ou le destinataire.
- **Subrogation** : transfert des droits du client à son assureur.
- **Devoir de conseil** : obligation jurisprudentielle d'information du transporteur professionnel.
- **Ad valorem** : assurance « à la valeur réelle » de la marchandise.

---

## 9. Synthèse opérationnelle

1. **3 obligations expéditeur** : conditionnement + déclarations + paiement (sauf CIF).
2. **Obligations transporteur** : prise en charge + exécution conforme + livraison + conseil.
3. **Obligations destinataire** : réception + vérification + réserves + paiement (si CIF).
4. **Responsabilité de plein droit** transporteur (art. L. 133-1 C. com.).
5. **3 causes d'exonération** : force majeure, vice propre, faute expéditeur.
6. **Réserves obligatoires** : 3/7 j (national), 7/21 j (CMR).
7. **Déclaration de valeur** + ad valorem indispensables > 10 €/kg.
8. **Action directe** (L. 3242-3) : protection contre DO insolvable.

---

## ⚠️ Points de vigilance

- **Signer sans réserves** = perte du recours. Toujours inspecter au chargement et à la livraison.
- **Devoir de conseil** : alerter par écrit le client en cas de risque.
- **Pas de réserves verbales** : tout doit être écrit sur la LV + LRAR confirmant.
- **Action directe** : la mettre en œuvre rapidement (1 an de prescription).

## 💡 Astuces pro

- **Photos systématiques** au chargement et à la livraison (mobile + envoi cloud).
- **Tampon « SOUS RÉSERVES DE DÉBALLAGE »** sur tous les BL signés.
- **Mention CGV** : « Tout dommage non immédiatement signalé est présumé survenu après la livraison. »

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : obligations parties, causes exonération, délais réserves.
- **QR cas pratique** : « Le transporteur signe sans réserves, conséquences ? »
- **Oral DP** : « Comment formez-vous vos conducteurs aux réserves ? »

---

## 📌 Synthèse à retenir

### Les 3 obligations clés par partie

| Partie | Obligation 1 | Obligation 2 | Obligation 3 |
|---|---|---|---|
| **Expéditeur** | Conditionnement | Déclarations | Paiement |
| **Transporteur** | Prise en charge | Exécution conforme | Livraison + conseil |
| **Destinataire** | Réception | Vérification + réserves | Paiement (si CIF) |

### Responsabilité de plein droit

> 📚 **Art. L. 133-1 C. com.** : le voiturier est garant de la perte et des avaries, hors **3 causes** :
> 1. **Force majeure**
> 2. **Vice propre** de la marchandise
> 3. **Faute** de l'expéditeur

### Délais de réserves

| Avarie | National | CMR |
|---|---|---|
| **Visible** | 3 jours | 7 jours |
| **Cachée** | 7 jours | 21 jours |

> ⚠️ **Les 4 réflexes ABSOLUS**
>
> - **Toujours faire des réserves** précises et écrites
> - **Photos systématiques** chargement + livraison
> - **Déclaration de valeur** > 10 €/kg
> - **Action directe** dans les 30 j si DO insolvable
$lessonH3$,
'Maîtriser les obligations des 3 parties (expéditeur, transporteur, destinataire), la responsabilité de plein droit du transporteur (art. L. 133-1 C. com.) et ses 3 causes d''exonération, l''importance des réserves à la livraison, et l''action directe (art. L. 3242-3) en cas de DO insolvable.'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Modifications, contestations, prescription
  -- =================================================================
  INSERT INTO public.lessons (
    module_id, title, slug, "order", duration_min, content_md, summary_md
  ) VALUES (
    v_module,
    'Modifications, contestations, prescription',
    'modifications-contestations-prescription',
    4, 55,
$lessonH4$
# Modifications, contestations, prescription

> 🎯 **Objectifs pédagogiques**
>
> - **Modifier** une instruction de transport en cours d'exécution (art. 12 CMR / L. 1432-7).
> - **Gérer** un empêchement à la livraison (refus destinataire, absence).
> - **Construire** une procédure de réclamation chronométrée (réserves, mise en demeure, action).
> - **Maîtriser** les délais de prescription (1 an national, 1-3 ans CMR).
> - **Sécuriser** ses CGV transporteur et le paiement (LME, caution, affacturage).

---

## Introduction

Un transport ne se déroule **jamais comme prévu à 100 %**. Le client change d'avis, le destinataire est absent, la marchandise est endommagée, le DO ne paye pas. Le GOTRM doit savoir **réagir vite et juridiquement** à chaque incident pour **préserver les droits** de son entreprise.

L'enjeu est de taille : la prescription de **1 an** (art. L. 133-6 C. com.) signifie qu'**au-delà de 365 jours après la livraison**, toute action en justice est **irrecevable**. C'est la guillotine du contentieux transport. Pareil pour les **délais de réserves** (3 jours visible, 7 jours cachée) : passé ces délais, le destinataire **perd son droit à indemnité**.

Cette leçon vous donne les **timelines précises** de chaque procédure, les modèles de courriers à utiliser, et les **astuces pro** pour sécuriser le paiement et limiter les contentieux.

---

## 1. Modification d'instructions en cours de transport

### 1.1 Le droit de disposition de la marchandise

L'**expéditeur** conserve un **droit de disposition** sur la marchandise tant qu'elle n'est pas livrée (art. 12 CMR international ; art. L. 1432-7 C. transports national). Il peut :
- **Arrêter** le transport en cours.
- **Changer** le lieu de livraison.
- **Changer** le destinataire.
- Demander **restitution** au point de départ.

### 1.2 Conditions et modalités

La modification d'instruction doit :
- Être **écrite** (mail, fax, ordre formel).
- Être **possible techniquement** (pas si déjà livré, pas si retour vers point opposé).
- **Indemniser** le transporteur des frais supplémentaires.

⚠️ **Limite** : le droit de disposition de l'expéditeur **cesse** dès que :
- Le **deuxième exemplaire CMR** a été remis au destinataire (international).
- Le destinataire a **réclamé la marchandise** ou l'a acceptée (national).

À ce moment, c'est le **destinataire** qui devient le détenteur du droit de disposition.

### 1.3 Tarification des modifications

Le transporteur peut facturer :
- **Frais de re-routage** (km supplémentaires × tarif kilométrique).
- **Temps d'attente** ou de stockage.
- **Indemnité forfaitaire** prévue dans les CGV (typiquement 50-150 €).

### 1.4 Cas pratique : changement de destinataire

**Énoncé** : Camion en route Lyon → Marseille avec 20 palettes destinées à **Société A** (Marseille). À Avignon, l'expéditeur appelle : « Société A est en cessation de paiement, livrez à **Société B** (Toulon). »

**Réponse** :
- **Possible** : le transport n'est pas terminé, l'expéditeur a encore le droit de disposition.
- **Modalité** : ordre écrit (mail) confirmant le changement.
- **Tarification** : surcoût km Marseille → Toulon (~70 km) + indemnité 100 €.
- **Document** : nouvelle lettre de voiture à Toulon avec mention « Modifié sur ordre de l'expéditeur le [date] ».

---

## 2. Empêchement à la livraison

### 2.1 Cas d'empêchement

Plusieurs situations bloquent la livraison :
- **Destinataire absent** au moment de la livraison.
- **Destinataire refuse** la marchandise (avariée, mauvaise commande).
- **Adresse introuvable** ou inexacte.
- **Cessation de paiement** du destinataire.

### 2.2 Procédure (art. 14-16 CMR / L. 1432-8 C. transports)

Face à un empêchement, le transporteur doit :

**Étape 1** : Demander **nouvelles instructions** à l'expéditeur (par mail ou téléphone, traçabilité).

**Étape 2** : En attendant, **stocker la marchandise** :
- Soit dans son propre dépôt (avec facturation).
- Soit en magasin tiers agréé (entrepôt douanier si nécessaire).

**Étape 3** : Si pas de réponse sous **délai raisonnable** (généralement 8-15 jours selon nature) :
- **Vente d'office** par autorité de justice (procédure peu fréquente).
- **Restitution** au point de départ aux frais de l'expéditeur.

### 2.3 Tarification de l'empêchement

| Action | Tarification typique |
|---|---|
| **Présentation infructueuse** | 80-150 € forfaitaire |
| **Stockage en dépôt** | 5-15 € / palette / jour |
| **Re-livraison** | Tarif transport normal |
| **Vente aux enchères** | Frais judiciaires + 10-15 % du produit |

### 2.4 Cas pratique : destinataire absent

**Énoncé** : Livraison prévue chez un particulier le 15 mars 14h. Le conducteur arrive : personne. Que faire ?

**Réponse** :
1. **Tentative d'appel** au numéro renseigné.
2. **Avis de passage** dans la boîte aux lettres.
3. **Mail au DO** : « Destinataire absent ce jour. Marchandise retournée au dépôt. Coût stockage 12 €/palette/jour. Représentation possible le 17/03 (frais 80 €). »
4. **Re-livraison** sur ordre écrit du DO.

> 💡 **Astuce CGV** : prévoir une clause « Toute présentation infructueuse engage des frais de 80 €. Toute re-livraison est facturée au tarif standard. »

---

## 3. Procédure de réclamation chronométrée

### 3.1 Timeline national (CT général)

:::timeline
1. **J = livraison** | Réserves visibles inscrites sur la LV (immédiates)
2. **J + 3 jours** | Délai max pour confirmer réserves visibles par LRAR
3. **J + 7 jours** | Délai max pour signaler avaries cachées par LRAR
4. **J + 30 jours** | Mise en demeure transporteur (paiement indemnité)
5. **J + 90 jours** | Action en justice (assignation tribunal commerce)
6. **J + 365 jours** | **PRESCRIPTION** : action irrecevable (art. L. 133-6 C. com.)
:::

### 3.2 Timeline international (CMR)

:::timeline
1. **J = livraison** | Réserves visibles inscrites sur la CMR
2. **J + 7 jours** | Délai max pour confirmer réserves visibles
3. **J + 21 jours** | Délai max pour signaler avaries cachées + retard
4. **J + 60 jours** | Mise en demeure transporteur
5. **J + 180 jours** | Action en justice (tribunal commerce)
6. **J + 365 jours** | **PRESCRIPTION** (3 ans en cas de dol, art. 32 CMR)
:::

### 3.3 La mise en demeure

La **mise en demeure** est l'acte par lequel un créancier somme un débiteur d'exécuter (paiement, indemnité, etc.). Elle est obligatoire pour :
- Faire courir les **intérêts moratoires** (art. 1344 C. civ.).
- **Démarrer** le délai d'action directe (30 jours).
- **Constituer** une preuve en cas d'action en justice.

**Contenu** :
- Référence du contrat (date, n° devis, LV).
- Nature de la créance ou réclamation.
- Montant exact réclamé.
- Délai impératif (généralement 8 ou 15 jours).
- Mention « à défaut, action en justice ».
- Envoi en **LRAR** obligatoirement.

### 3.4 Action en justice

Si la mise en demeure reste sans effet :

**Tribunal compétent** :
- **Tribunal de commerce** si litige B2B (~95 % des cas).
- **Tribunal judiciaire** si l'une des parties est non commerçante.

**Procédures** :
- **Référé** : urgence, décision sous 4-8 semaines (frais ~1 500 €).
- **Procédure au fond** : décision sous 6-18 mois (frais ~3 000-10 000 €).
- **Injonction de payer** : créance certaine et liquide, 2-4 semaines (frais ~50 €).

### 3.5 Cas pratique : timeline de réclamation

**Énoncé** : Le **12 mars 2026**, vous livrez une cargaison endommagée chez un client. Le client réclame 8 500 €. Établissez les **dates butoirs**.

**Correction** :

| Date | Action |
|---|---|
| **12/03/2026** | Livraison — réserves immédiates sur LV |
| **15/03/2026** | Limite réserves visibles (J+3) |
| **19/03/2026** | Limite avaries cachées (J+7) |
| **11/04/2026** | Mise en demeure transporteur (J+30) |
| **12/03/2027** | **PRESCRIPTION** (J+365) |

**Recommandation pro** :
- Faire la mise en demeure **avant J+90** pour laisser temps de négocier.
- Lancer l'**injonction de payer** avant J+180.
- **Ne jamais attendre** au-delà de J+300 sans action concrète.

---

## 4. Prescription : la guillotine du transport

### 4.1 Principes

La **prescription** est le délai au-delà duquel une action en justice devient irrecevable. Pour le transport :

| Régime | Délai standard | Délai en cas de dol |
|---|---|---|
| **National** (art. L. 133-6 C. com.) | **1 an** | 5 ans (droit commun) |
| **CMR** (art. 32) | **1 an** | **3 ans** |

### 4.2 Point de départ du délai

| Action | Point de départ |
|---|---|
| Action contre transporteur (avarie) | Date de livraison (ou dernière instruction) |
| Action en paiement (transporteur) | Date d'exigibilité de la facture |
| Action récursoire (commissionnaire vs transporteur) | Date de paiement de l'indemnité au client |

### 4.3 Causes d'interruption / suspension

La prescription peut être :
- **Interrompue** par : reconnaissance de dette, action en justice, mise en demeure conservatoire (art. 2241 C. civ.).
- **Suspendue** par : médiation, conciliation (art. 2238 C. civ.).

**Effet de l'interruption** : le délai **redémarre à zéro** à compter de l'événement interruptif.

### 4.4 Cas pratique : prescription manquée

**Énoncé** : Avarie le 12/03/2025. Client réclame 15 000 €. Vous négociez à l'amiable jusqu'au 20/01/2026 puis le client cesse de répondre. Vous décidez d'agir en justice le **15/05/2026**.

**Question** : Pouvez-vous encore agir ?

**Réponse** :
- **NON**. La prescription a expiré le **12/03/2026** (1 an après la livraison).
- Sans interruption (LRAR de mise en demeure entre le 12/03/2025 et le 12/03/2026), votre action est **irrecevable**.
- **15 000 € définitivement perdus**.

**Leçon** : pendant les négociations amiables, **toujours envoyer une LRAR de mise en demeure** au moins une fois pour interrompre la prescription.

---

## 5. Sécuriser les CGV et le paiement

### 5.1 Mentions LME obligatoires

Toute facture doit comporter (art. L. 441-9 et L. 441-10 C. com.) :

- **Date d'échéance** (max 60 jours date facture, ou 45 jours fin de mois).
- **Pénalités de retard** : taux **BCE + 10 points** (en 2026 : ~14,75 %).
- **Indemnité forfaitaire** : **40 €** par facture impayée.
- **Mention** « facture acquittée » si payée comptant.

⚠️ **Sanction** : **75 000 € PP / 375 000 € PM** par mention manquante.

### 5.2 Modèle de clause CGV — paiement

> « **Article X - Paiement**
> Les factures sont payables à **30 jours fin de mois** suivant la date de facturation. En cas de retard, application **automatique** des pénalités au taux **BCE majoré de 10 points** par jour calendaire, ainsi qu'une **indemnité forfaitaire de 40 €** par facture (art. L. 441-10 C. com.). Tout retard supérieur à 30 jours autorise le transporteur à **suspendre les prestations** en cours et à **exiger paiement comptant** des prochaines opérations. »

### 5.3 Outils de sécurisation du paiement

**1. Caution bancaire / garantie première demande** :
- Le DO fournit une caution bancaire pour garantir le paiement.
- Coût pour le DO : 0,3-0,8 % du montant garanti par an.
- Sécurité maximale pour le transporteur (paiement à première demande de la banque).

**2. Affacturage** :
- Cession de créances commerciales à un factor (Bibby, Eurofactor, BNP Factor).
- Cash immédiat : 90-95 % du montant facturé.
- Solde versé à paiement client (-1 à 2 % de commission).
- Idéal pour PME transport avec gros DO solvables.

**3. Assurance impayés (Coface, Atradius)** :
- Couverture du risque d'impayé en cas de défaillance du DO.
- Prime : 0,3-0,8 % du CA assuré.
- Indemnité : 80-90 % de la créance.

**4. Mandat à recouvrement** :
- Société de recouvrement amiable (Intrum, Coface).
- Frais : 10-25 % du montant recouvré.
- Pour litiges < 5 000 € : injonction de payer (50 € de frais).

### 5.4 Cas pratique : sécurisation d'un nouveau client

**Énoncé** : Un nouveau client (PME, CA 5 M€, Coface B+) vous demande **120 transports/an** à 1 200 € HT chacun (CA annuel 144 000 €). Comment sécurisez-vous ?

**Plan en 4 leviers** :

1. **Acompte 30 %** à la commande pour les 6 premiers mois (signal de pro).
2. **Affacturage** sur ce nouveau client : cash immédiat 90 % à la facture, gain trésorerie.
3. **Assurance impayés Coface** : prime 0,5 % × 144 000 € = 720 €/an, indemnité 80 % en cas d'impayé.
4. **CGV signées** avec clause LME complète + suspension prestations en cas de retard > 30 j.

**Coût total an 1** : ~1 500-2 000 €. **Sécurité gagnée** : ~115 000 € de risque maîtrisé.

---

## 6. Cas pratique d'examen

**Énoncé** : Le **12/03/2026**, vous livrez une cargaison de **800 kg de matériel hi-tech** (valeur 50 000 €) à un client GMS. Le manutentionnaire signe le BL **avec mention manuscrite « 5 colis manquent »**. Le **18/03/2026**, le client envoie un mail réclamant **6 000 €** d'indemnité. Vous transportez sous régime contrat-type général (pas de déclaration de valeur).

**Questions** :
1. Les réserves sont-elles valables ?
2. Quelle est l'indemnité maximale due ?
3. Date butoir pour la prescription ?
4. Que faire en pratique ?

**Correction** :

1. **Réserves valables** : la mention manuscrite sur le BL est conforme au CT général + le mail du 18/03 (J+6) confirme dans les **7 jours** (cachée) ou les **3 jours** (visible). En l'occurrence, manque visible = J+3 max. Toutefois, la mention manuscrite sur le BL **immédiate** suffit à constituer une réserve valable.

2. **Indemnité plafonnée** :
   - Poids des 5 colis manquants : ~125 kg (sur 800 kg).
   - Plafond / kg : 125 × 14 = **1 750 €**.
   - Plafond / envoi (envoi total < 3 t) : **750 €**.
   - **Indemnité due = 750 €**.

3. **Prescription** : **12/03/2027** (1 an après livraison, art. L. 133-6 C. com.).

4. **Actions** :
   - Acquitter la réclamation à hauteur de **750 €** (offre de règlement amiable).
   - Si client refuse et veut 6 000 € : envoyer **LRAR** rappelant le plafond CT.
   - **Avant 12/03/2027** : si pas d'accord, **injonction de payer** ou **action au fond** au tribunal de commerce.
   - **Conseil au client** : à l'avenir, faire une **déclaration de valeur** pour lever les plafonds.

---

## 7. Mini-exercice à faire seul

**Énoncé** : Le **5 janvier 2026**, vous livrez une cargaison à Lyon. Le client signe **sans réserves**. Le **20 janvier 2026** (J+15), il vous envoie un mail réclamant 4 200 € pour des avaries qu'il dit avoir « découvertes au déballage ».

**Questions** :
1. La réclamation est-elle recevable ?
2. Quelle réponse argumentée envoyez-vous au client ?

> 💡 Réponse en fin de module.

---

## 8. Glossaire

- **Droit de disposition** : pouvoir de l'expéditeur de modifier les instructions en cours de transport (art. 12 CMR).
- **Empêchement à la livraison** : situation bloquant la livraison (refus, absence, adresse introuvable).
- **Mise en demeure** : LRAR formelle sommant un débiteur d'exécuter sous délai.
- **Prescription** : délai au-delà duquel une action est irrecevable (1 an national, 1-3 ans CMR).
- **Interruption** : événement qui remet à zéro le délai de prescription.
- **Suspension** : événement qui suspend le décompte sans le remettre à zéro.
- **Référé** : procédure d'urgence au tribunal de commerce (4-8 semaines).
- **Injonction de payer** : procédure rapide pour créance certaine (~2 semaines, 50 €).
- **Affacturage** : cession de créances contre cash immédiat à un factor.
- **Coface / Atradius** : assureurs-crédit pour le risque d'impayé B2B.

---

## 9. Synthèse opérationnelle

1. **Modification d'instruction** : possible tant que le destinataire n'a pas réclamé la marchandise (art. 12 CMR / L. 1432-7).
2. **Empêchement à la livraison** : demander instructions, stocker, re-livraison ou vente d'office.
3. **Réserves** : 3 j (visible) / 7 j (cachée) en national ; 7 j / 21 j en CMR.
4. **Mise en demeure** par LRAR : interruption de prescription + démarrage intérêts.
5. **Prescription** : 1 an national, 1 an CMR (3 ans en cas de dol).
6. **CGV LME** : pénalités BCE+10 + indemnité 40 € obligatoires.
7. **Sécuriser paiement** : caution bancaire, affacturage, Coface, mandat recouvrement.
8. **Outils contentieux** : injonction de payer (50 €), référé (1 500 €), action au fond (3 000+ €).

---

## ⚠️ Points de vigilance

- **Prescription 1 an** : la guillotine. Toujours envoyer une LRAR avant l'échéance.
- **Réserves trop tardives** : forclusion du destinataire = avantage transporteur.
- **CGV non transmises** : non opposables. Toujours les envoyer **avant** signature.
- **Mention LME manquante** : 75 k€ / 375 k€ d'amende — strict.

## 💡 Astuces pro

- **Calendrier prescription** : automatiser dans le TMS un rappel à J+300 pour LRAR.
- **Templates Outlook** : 5 modèles types (réserves, mise en demeure, refus, modification, contestation).
- **Coup malin** : mention CGV « Tout dommage non immédiatement signalé est présumé survenu après livraison. »

---

## 🎓 Ce que l'examinateur peut demander

- **QCM** : délais réserves, prescription, mentions LME, modification instructions.
- **QR cas pratique** : « Établissez la timeline de réclamation à partir d'une livraison du [date]. »
- **Oral DP** : « Comment gérez-vous les impayés dans votre entreprise ? »

---

## 10. Corrections des mini-exercices du module

### Leçon 1 — Stef Transport, Strasbourg-Madrid

1. **Régime** : transport **international** entre 2 pays signataires CMR ⇒ **CMR applicable**.
2. **Rôle Stef** : Stef choisit le sous-traitant + prend une marge + garantit la livraison ⇒ **commissionnaire** (art. L. 132-1 C. com.). Capacité professionnelle commission obligatoire.
3. **Marge** : 2 380 − 1 850 = **530 € HT** (22,3 % de marge brute).
4. **Plafond CMR** : 18 × 350 × 10,80 € = **68 040 €**. Avec déclaration de valeur, indemnité au prix réel 90 000 €.

### Leçon 2 — 4 cas comparatifs

- **Cas A** (Lille→Marseille, 2 t) : CT général < 3 t. Plafond MIN(2000×23 ; 750) = **750 €**.
- **Cas B** (Lille→Marseille, 5 t) : CT général ≥ 3 t. Plafond MIN(5000×14 ; 2300) = **2 300 €**.
- **Cas C** (Paris→Bruxelles, 2 t) : CMR. Plafond 2000×10,80 = **21 600 €** (mais plafonné à 30 000 € valeur ⇒ indemnité = **21 600 €**).
- **Cas D** (Paris→Bruxelles, 5 t) : CMR. Plafond 5000×10,80 = **54 000 €**, plafonné à valeur **30 000 €** ⇒ indemnité = **30 000 €**.

**Conclusion** : pour 30 000 € de marchandise détruite, le client touche **750 € en national léger**, mais **30 000 € en CMR**. L'écart est **40×** !

### Leçon 3 — Conforama, dommages au déchargement

1. **Non**, vous n'êtes pas responsable. Les dommages sont survenus **après livraison** (déchargement par personnel Conforama). Le BL signé sans réserves vaut **acceptation de l'état de la marchandise au moment de la livraison**.
2. **Protection pratique** : (a) photos systématiques des palettes au moment de la livraison (avant déchargement) ; (b) tampon « SOUS RÉSERVES DE DÉBALLAGE » sur tous les BL ; (c) instruction conducteur : ne jamais participer au déchargement.
3. **Mention CGV** : « La responsabilité du transporteur cesse à la livraison effective. Tout dommage causé par le déchargement effectué par le destinataire ou sous sa responsabilité ne saurait être imputé au transporteur. »

### Leçon 4 — Réclamation tardive 5/01 → 20/01

1. **Non, irrecevable**. La signature **sans réserves** vaut **acceptation de l'état apparent** (visible). Le délai pour avaries cachées est de **7 jours** (national) ou 21 jours (CMR). Au 20/01 (J+15), le délai national est **forclos**.
2. **Mail de réponse type** :
> « Cher Monsieur, j'accuse réception de votre réclamation du 20/01/2026. Conformément à l'article L. 133-3 du Code de commerce et au contrat-type général (décret 99-269), les avaries cachées doivent être signalées par lettre recommandée dans les **7 jours** suivant la livraison. Votre courrier intervenant **15 jours après la livraison** (5/01/2026), votre réclamation est **forclos**. Je ne peux donner suite à votre demande d'indemnisation. Restant à votre disposition pour vos prochaines opérations, cordialement. »

---

## 📌 Synthèse à retenir

### Timeline national (CT général)

| Étape | Délai depuis livraison |
|---|---|
| Réserves visibles (LV ou LRAR) | **3 jours** |
| Réserves cachées (LRAR) | **7 jours** |
| Mise en demeure | **30 jours** (recommandé) |
| Action en justice | **avant 1 an** |
| **PRESCRIPTION** | **1 an** |

### Timeline CMR (international)

| Étape | Délai depuis livraison |
|---|---|
| Réserves visibles | **7 jours** |
| Réserves cachées + retard | **21 jours** |
| Mise en demeure | **60 jours** (recommandé) |
| Action en justice | **avant 1 an** |
| **PRESCRIPTION** | **1 an** (3 ans dol) |

### Sécurisation paiement (4 outils)

| Outil | Coût | Bénéfice |
|---|---|---|
| **Acompte 30 %** | 0 € | Trésorerie immédiate |
| **Affacturage** | 1-2 % CA | Cash 90 % à la facture |
| **Assurance impayés** | 0,3-0,8 % CA | Indemnité 80 % en cas de défaillance |
| **Caution bancaire** | 0,3-0,8 % du DO | Garantie première demande |

> ⚠️ **Les 4 commandements ABSOLUS**
>
> - **LRAR de mise en demeure** dans les 30 j en cas de litige
> - **Prescription 1 an** : la guillotine, automatiser le rappel TMS
> - **Mentions LME** : strict (sanction 75 k€ / 375 k€)
> - **CGV transmises AVANT** signature uniquement
$lessonH4$,
'Maîtriser la modification d''instructions en cours de transport (art. 12 CMR / L. 1432-7), les empêchements à la livraison, la procédure de réclamation chronométrée (3/7 j national, 7/21 j CMR), la prescription (1 an / 3 ans dol) et les outils de sécurisation du paiement (LME, caution, affacturage, Coface).'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- BANQUE DE QUESTIONS — 48 QCM + 8 QR
  -- =================================================================

  -- ===== LEÇON 1 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'Le contrat de transport est un contrat :',
   '[{"id":"a","label":"Réel (formé par remise de la chose)","is_correct":false},{"id":"b","label":"Consensuel (formé par échange des consentements)","is_correct":true},{"id":"c","label":"Solennel (nécessite un acte notarié)","is_correct":false},{"id":"d","label":"Unilatéral","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-02','lecon-1','nature'], 'mft-2026-gotrm:bc01-02-v3:l1:q1', true,
   'Le contrat de transport est consensuel : il se forme par le seul échange des consentements (offre + acceptation). Pas besoin d''écrit pour qu''il existe juridiquement. La lettre de voiture sert de preuve, pas de validité.'),
  (v_formation, v_module, 'qcm', 'Les 3 obligations essentielles du transporteur sont :',
   '[{"id":"a","label":"Charger, conduire, facturer","is_correct":false},{"id":"b","label":"Déplacer, conserver, livrer","is_correct":true},{"id":"c","label":"Garer, dormir, repartir","is_correct":false},{"id":"d","label":"Accepter, refuser, négocier","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-02','lecon-1','obligations'], 'mft-2026-gotrm:bc01-02-v3:l1:q2', true,
   'Les 3 obligations cumulatives du transporteur : (1) déplacer matériellement la marchandise, (2) la conserver pendant le trajet, (3) la livrer au destinataire désigné (art. L. 1432-1 C. transports + L. 133-1 C. com.).'),
  (v_formation, v_module, 'qcm', 'Le destinataire devient partie au contrat de transport :',
   '[{"id":"a","label":"À la signature du devis","is_correct":false},{"id":"b","label":"Dès qu''il accepte la marchandise (art. L. 132-8 C. com.)","is_correct":true},{"id":"c","label":"Au paiement de la facture","is_correct":false},{"id":"d","label":"Jamais","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-02','lecon-1','destinataire'], 'mft-2026-gotrm:bc01-02-v3:l1:q3', true,
   'Mécanisme d''adhésion (art. L. 132-8 C. com.) : le destinataire n''est pas signataire à l''origine, mais adhère au contrat dès la réception. Il devient partie et peut agir en responsabilité contre le transporteur.'),
  (v_formation, v_module, 'qcm', 'Quel est le critère principal pour distinguer un commissionnaire d''un transporteur ?',
   '[{"id":"a","label":"Le nombre de véhicules détenus","is_correct":false},{"id":"b","label":"Le choix libre du mode + marge sur sous-traitance + garantie de résultat","is_correct":true},{"id":"c","label":"L''ancienneté de l''entreprise","is_correct":false},{"id":"d","label":"Le chiffre d''affaires","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-02','lecon-1','qualification'], 'mft-2026-gotrm:bc01-02-v3:l1:q4', true,
   '4 indices de qualification : choix libre du mode, marge sur sous-traitance, garantie du résultat, refacturation. Si tous OUI = commissionnaire (art. L. 132-1 C. com.).'),
  (v_formation, v_module, 'qcm', 'La lettre de voiture en transport national est :',
   '[{"id":"a","label":"Obligatoire à 3 exemplaires","is_correct":false},{"id":"b","label":"Facultative mais recommandée comme preuve","is_correct":true},{"id":"c","label":"Interdite","is_correct":false},{"id":"d","label":"Réservée au transport routier","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-02','lecon-1','lv'], 'mft-2026-gotrm:bc01-02-v3:l1:q5', true,
   'En transport national, la lettre de voiture est facultative mais sert de preuve probatoire. En transport international (CMR), elle est obligatoire à 3 exemplaires (art. 4 et 6 CMR).'),
  (v_formation, v_module, 'qcm', 'Un contrat de transport gratuit (entre amis) :',
   '[{"id":"a","label":"Engage le transporteur de la même manière","is_correct":false},{"id":"b","label":"N''est pas un contrat de transport au sens juridique (responsabilité 1240 C. civ.)","is_correct":true},{"id":"c","label":"Est interdit","is_correct":false},{"id":"d","label":"Engage uniquement le destinataire","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-02','lecon-1','onereux'], 'mft-2026-gotrm:bc01-02-v3:l1:q6', true,
   'Le contrat de transport est nécessairement à titre onéreux. Un transport gratuit relève du droit commun (art. 1240 C. civ. - faute prouvée requise) et non du régime spécial transport.'),
  (v_formation, v_module, 'qcm', 'Quel article fonde la responsabilité de plein droit du voiturier ?',
   '[{"id":"a","label":"Article L. 132-1 C. com.","is_correct":false},{"id":"b","label":"Article L. 133-1 C. com.","is_correct":true},{"id":"c","label":"Article L. 441-9 C. com.","is_correct":false},{"id":"d","label":"Article 1240 C. civ.","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-02','lecon-1','responsabilite'], 'mft-2026-gotrm:bc01-02-v3:l1:q7', true,
   'Art. L. 133-1 C. com. : « Le voiturier est garant de la perte des objets à transporter, hors les cas de force majeure. » L. 132-1 régit la commission ; L. 441-9 les factures.'),
  (v_formation, v_module, 'qcm', 'En transport B2B, quel est le tribunal compétent en cas de litige ?',
   '[{"id":"a","label":"Tribunal judiciaire","is_correct":false},{"id":"b","label":"Tribunal de commerce","is_correct":true},{"id":"c","label":"Conseil de prud''hommes","is_correct":false},{"id":"d","label":"Tribunal administratif","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-02','lecon-1','tribunal'], 'mft-2026-gotrm:bc01-02-v3:l1:q8', true,
   'Le contrat de transport B2B est commercial par nature (art. L. 110-1 C. com.). Tribunal de commerce compétent. Si destinataire particulier = mixte avec possibilité tribunal judiciaire.'),
  (v_formation, v_module, 'qcm', 'Combien de contrats-types français existent (selon nature de l''opération) ?',
   '[{"id":"a","label":"1","is_correct":false},{"id":"b","label":"3","is_correct":false},{"id":"c","label":"5","is_correct":true},{"id":"d","label":"10","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-02','lecon-1','contrat-type'], 'mft-2026-gotrm:bc01-02-v3:l1:q9', true,
   '5 contrats-types français : général (déc. 99-269), périssables/frigo, citernes, animaux vivants, déménagement. Chacun a ses propres règles d''indemnité.'),
  (v_formation, v_module, 'qcm', 'L''expéditeur est :',
   '[{"id":"a","label":"Toujours identique au donneur d''ordre","is_correct":false},{"id":"b","label":"Celui qui remet matériellement la marchandise au transporteur","is_correct":true},{"id":"c","label":"Toujours le destinataire","is_correct":false},{"id":"d","label":"Le commissionnaire","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-02','lecon-1','expediteur'], 'mft-2026-gotrm:bc01-02-v3:l1:q10', true,
   'L''expéditeur (chargeur) remet matériellement la marchandise. Il peut être différent du donneur d''ordre (qui paye) : industriel = expéditeur, grossiste = DO, détaillant = destinataire.'),
  (v_formation, v_module, 'qcm', 'Un contrat synallagmatique signifie :',
   '[{"id":"a","label":"Sans engagement","is_correct":false},{"id":"b","label":"Avec obligations réciproques entre les parties","is_correct":true},{"id":"c","label":"Conclu uniquement à l''oral","is_correct":false},{"id":"d","label":"Sans rémunération","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-02','lecon-1','synallagmatique'], 'mft-2026-gotrm:bc01-02-v3:l1:q11', true,
   'Synallagmatique = obligations réciproques. Chaque partie a des obligations envers l''autre : expéditeur (conditionne, paye), transporteur (achemine), destinataire (réceptionne).'),
  (v_formation, v_module, 'qcm', 'L''action récursoire du commissionnaire contre son sous-traitant est fondée sur :',
   '[{"id":"a","label":"L''article 1240 C. civ.","is_correct":false},{"id":"b","label":"L''article L. 132-6 C. com.","is_correct":true},{"id":"c","label":"L''article L. 441-10 C. com.","is_correct":false},{"id":"d","label":"L''article 6 CMR","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-02','lecon-1','recours'], 'mft-2026-gotrm:bc01-02-v3:l1:q12', true,
   'Art. L. 132-6 C. com. : le commissionnaire qui a indemnisé le client peut se retourner contre le transporteur sous-traitant fautif (action récursoire). Limité aux plafonds CT du sous-traitant.');

  -- ===== LEÇON 2 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'La CMR s''applique à un transport :',
   '[{"id":"a","label":"National en France uniquement","is_correct":false},{"id":"b","label":"Routier international entre 2 pays signataires","is_correct":true},{"id":"c","label":"Maritime international","is_correct":false},{"id":"d","label":"Tout transport rémunéré","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-02','lecon-2','cmr'], 'mft-2026-gotrm:bc01-02-v3:l2:q1', true,
   'CMR (Convention Genève 1956) : transport routier de marchandises contre rémunération entre deux États signataires différents. 56 États en 2026 (UE + UK + CH + autres).'),
  (v_formation, v_module, 'qcm', 'Le plafond d''indemnité CMR est de :',
   '[{"id":"a","label":"5 €/kg","is_correct":false},{"id":"b","label":"8,33 DTS/kg ≈ 10,80 €/kg","is_correct":true},{"id":"c","label":"14 €/kg","is_correct":false},{"id":"d","label":"23 €/kg","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-02','lecon-2','plafond-cmr'], 'mft-2026-gotrm:bc01-02-v3:l2:q2', true,
   'Plafond CMR (art. 23) : 8,33 DTS/kg de poids brut manquant. 1 DTS ≈ 1,30 € en 2026 ⇒ ≈ 10,80 €/kg. Plafond / envoi : aucun (uniquement plafond / kg).'),
  (v_formation, v_module, 'qcm', 'La lettre de voiture CMR doit être établie en :',
   '[{"id":"a","label":"1 exemplaire","is_correct":false},{"id":"b","label":"2 exemplaires","is_correct":false},{"id":"c","label":"3 exemplaires","is_correct":true},{"id":"d","label":"5 exemplaires","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-02','lecon-2','cmr-document'], 'mft-2026-gotrm:bc01-02-v3:l2:q3', true,
   'Art. 5 CMR : 3 exemplaires originaux. 1 pour l''expéditeur (rouge), 1 pour le destinataire (bleu), 1 pour le transporteur (vert).'),
  (v_formation, v_module, 'qcm', 'Le plafond du contrat-type général pour un envoi ≥ 3 tonnes est de :',
   '[{"id":"a","label":"750 €","is_correct":false},{"id":"b","label":"2 300 €","is_correct":true},{"id":"c","label":"5 000 €","is_correct":false},{"id":"d","label":"Illimité","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-02','lecon-2','plafond-ct'], 'mft-2026-gotrm:bc01-02-v3:l2:q4', true,
   'Contrat-type général ≥ 3 t : plafond / kg = 14 €/kg, plafond / envoi = 2 300 €. Pour < 3 t : 23 €/kg + 750 €. L''indemnité = MIN des deux.'),
  (v_formation, v_module, 'qcm', 'Le délai de réclamation pour avarie cachée en CMR est de :',
   '[{"id":"a","label":"3 jours","is_correct":false},{"id":"b","label":"7 jours","is_correct":false},{"id":"c","label":"21 jours","is_correct":true},{"id":"d","label":"30 jours","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-02','lecon-2','delai-cmr'], 'mft-2026-gotrm:bc01-02-v3:l2:q5', true,
   'Art. 30 CMR : avarie visible = 7 jours, avarie cachée = 21 jours, retard = 21 jours après livraison. Au-delà = forclusion.'),
  (v_formation, v_module, 'qcm', 'La prescription en CMR est de :',
   '[{"id":"a","label":"6 mois","is_correct":false},{"id":"b","label":"1 an (3 ans en cas de dol)","is_correct":true},{"id":"c","label":"2 ans","is_correct":false},{"id":"d","label":"5 ans","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-02','lecon-2','prescription-cmr'], 'mft-2026-gotrm:bc01-02-v3:l2:q6', true,
   'Art. 32 CMR : prescription 1 an, portée à 3 ans en cas de dol ou faute lourde équivalente (art. 29).'),
  (v_formation, v_module, 'qcm', 'L''article 24 CMR permet :',
   '[{"id":"a","label":"D''annuler le contrat","is_correct":false},{"id":"b","label":"De déclarer une valeur supérieure aux plafonds standards","is_correct":true},{"id":"c","label":"D''interrompre la prescription","is_correct":false},{"id":"d","label":"De refuser la livraison","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-02','lecon-2','art24'], 'mft-2026-gotrm:bc01-02-v3:l2:q7', true,
   'Art. 24 CMR : déclaration de valeur (au-delà de 8,33 DTS/kg) avec surprime. L''art. 26 prévoit la déclaration d''intérêt spécial à la livraison (couverture du retard au-delà du prix du transport).'),
  (v_formation, v_module, 'qcm', 'Un transport Lyon → Madrid (Espagne) relève du régime :',
   '[{"id":"a","label":"Contrat-type général","is_correct":false},{"id":"b","label":"CMR","is_correct":true},{"id":"c","label":"Code civil uniquement","is_correct":false},{"id":"d","label":"Convention de Bâle","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-02','lecon-2','application'], 'mft-2026-gotrm:bc01-02-v3:l2:q8', true,
   'Espagne signataire CMR ⇒ application automatique et impérative de la CMR (art. 1). Plafond 10,80 €/kg.'),
  (v_formation, v_module, 'qcm', 'Le contrat-type général s''applique :',
   '[{"id":"a","label":"À titre obligatoire et impératif","is_correct":false},{"id":"b","label":"Par défaut, à défaut de contrat écrit, et il est dérogeable","is_correct":true},{"id":"c","label":"Uniquement au transport international","is_correct":false},{"id":"d","label":"Pour les déménagements seulement","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-02','lecon-2','ct-application'], 'mft-2026-gotrm:bc01-02-v3:l2:q9', true,
   'Décret 99-269 : applicable d''office en l''absence de contrat écrit, mais dérogeable par accord exprès (art. L. 1432-2 C. transports). À distinguer de la CMR qui est impérative.'),
  (v_formation, v_module, 'qcm', 'Combien de mentions obligatoires comporte la lettre de voiture CMR (art. 6) ?',
   '[{"id":"a","label":"5","is_correct":false},{"id":"b","label":"10","is_correct":false},{"id":"c","label":"15","is_correct":true},{"id":"d","label":"25","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-02','lecon-2','art6'], 'mft-2026-gotrm:bc01-02-v3:l2:q10', true,
   'Art. 6 CMR : 15 mentions obligatoires (lieu/date, identités complètes, marchandise, frais, instructions douanières, référence CMR, etc.).'),
  (v_formation, v_module, 'qcm', 'Cargaison 5 t détruite, valeur 60 000 €, sans déclaration, transport Paris-Lyon. Indemnité due :',
   '[{"id":"a","label":"60 000 €","is_correct":false},{"id":"b","label":"2 300 € (plafond CT par envoi ≥ 3 t)","is_correct":true},{"id":"c","label":"54 000 €","is_correct":false},{"id":"d","label":"750 €","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-02','lecon-2','calcul-ct'], 'mft-2026-gotrm:bc01-02-v3:l2:q11', true,
   'Régime : CT général (national, ≥ 3 t). Plafond / kg : 5000×14 = 70 000 €. Plafond / envoi : 2 300 €. Indemnité = MIN = 2 300 €. Le client subit 57 700 € non couverts.'),
  (v_formation, v_module, 'qcm', 'L''e-CMR (lettre de voiture dématérialisée) est utilisable en 2026 dans :',
   '[{"id":"a","label":"3 pays uniquement","is_correct":false},{"id":"b","label":"27 pays UE","is_correct":true},{"id":"c","label":"Tous les pays du monde","is_correct":false},{"id":"d","label":"Pas encore en service","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-02','lecon-2','e-cmr'], 'mft-2026-gotrm:bc01-02-v3:l2:q12', true,
   'e-CMR (norme TransFollow) : 27 pays UE en 2026. Gain de productivité 30 %. Protocole additionnel CMR de 2008 (entré en vigueur 2011).');

  -- ===== LEÇON 3 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'L''expéditeur doit remettre une marchandise :',
   '[{"id":"a","label":"Sans aucun emballage","is_correct":false},{"id":"b","label":"Conditionnée de manière adaptée au mode de transport","is_correct":true},{"id":"c","label":"Toujours filmée et sanglée même pour un colis","is_correct":false},{"id":"d","label":"Sans étiquette","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-02','lecon-3','expediteur'], 'mft-2026-gotrm:bc01-02-v3:l3:q1', true,
   'Art. L. 1432-3 C. transports : conditionnement adapté au mode de transport (palettes, filmage, calage, étiquetage). Un emballage défaillant = vice propre exonérant le transporteur.'),
  (v_formation, v_module, 'qcm', 'La responsabilité de plein droit du transporteur (art. L. 133-1 C. com.) est :',
   '[{"id":"a","label":"Une présomption irréfragable","is_correct":false},{"id":"b","label":"Une présomption simple, exonérable par 3 causes","is_correct":true},{"id":"c","label":"Une responsabilité optionnelle","is_correct":false},{"id":"d","label":"Réservée au transport ferroviaire","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-02','lecon-3','responsabilite'], 'mft-2026-gotrm:bc01-02-v3:l3:q2', true,
   'Présomption simple. 3 causes d''exonération : force majeure, vice propre de la marchandise, faute de l''expéditeur ou du destinataire.'),
  (v_formation, v_module, 'qcm', 'Quelle n''est PAS une cause d''exonération du transporteur ?',
   '[{"id":"a","label":"Force majeure","is_correct":false},{"id":"b","label":"Vice propre de la marchandise","is_correct":false},{"id":"c","label":"Faute de l''expéditeur","is_correct":false},{"id":"d","label":"Mauvaise rentabilité du voyage","is_correct":true}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-02','lecon-3','exoneration'], 'mft-2026-gotrm:bc01-02-v3:l3:q3', true,
   'Les 3 seules causes d''exonération sont : (1) force majeure, (2) vice propre, (3) faute expéditeur/destinataire. La rentabilité commerciale n''a aucun effet juridique.'),
  (v_formation, v_module, 'qcm', 'Un conducteur signe un BL sans réserves alors que les palettes sont visiblement endommagées. Conséquence :',
   '[{"id":"a","label":"Aucune","is_correct":false},{"id":"b","label":"Le transporteur est présumé avoir reçu la marchandise en bon état","is_correct":true},{"id":"c","label":"Le contrat est nul","is_correct":false},{"id":"d","label":"L''expéditeur est sanctionné","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-02','lecon-3','reserves'], 'mft-2026-gotrm:bc01-02-v3:l3:q4', true,
   'La signature sans réserves vaut acceptation de l''état apparent au chargement. Le transporteur ne pourra pas se retourner contre l''expéditeur pour un dommage initial. Photos systématiques + tampon « SOUS RÉSERVES DE DÉBALLAGE » obligatoires.'),
  (v_formation, v_module, 'qcm', 'L''action directe (art. L. 3242-3 C. transports) permet au transporteur :',
   '[{"id":"a","label":"De saisir le véhicule du DO","is_correct":false},{"id":"b","label":"D''exiger le paiement de l''expéditeur ou du destinataire si DO insolvable","is_correct":true},{"id":"c","label":"De refuser la livraison","is_correct":false},{"id":"d","label":"De doubler la facture","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-02','lecon-3','action-directe'], 'mft-2026-gotrm:bc01-02-v3:l3:q5', true,
   'Art. L. 3242-3 C. transports : protection unique du transporteur. Si DO ne paye pas dans les 30 j après mise en demeure, action directe contre expéditeur ou destinataire.'),
  (v_formation, v_module, 'qcm', 'Le devoir de conseil du transporteur consiste à :',
   '[{"id":"a","label":"Conseiller le client sur sa stratégie marketing","is_correct":false},{"id":"b","label":"Alerter sur les risques (emballage, valeur, délai) et recommander assurances","is_correct":true},{"id":"c","label":"Faire de la formation gratuite","is_correct":false},{"id":"d","label":"Donner des conseils juridiques","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-02','lecon-3','conseil'], 'mft-2026-gotrm:bc01-02-v3:l3:q6', true,
   'Devoir de conseil (jurisprudence Cass. com. 5 mai 1987) : alerter sur risques d''emballage, recommander assurance ad valorem > 10 €/kg, signaler délais réalistes, informer sur obligations douanières.'),
  (v_formation, v_module, 'qcm', 'Le destinataire qui refuse une marchandise sans motif valable doit :',
   '[{"id":"a","label":"Rien","is_correct":false},{"id":"b","label":"Payer les frais de re-livraison ou stockage","is_correct":true},{"id":"c","label":"Payer le double","is_correct":false},{"id":"d","label":"Aller en justice immédiatement","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-02','lecon-3','refus'], 'mft-2026-gotrm:bc01-02-v3:l3:q7', true,
   'Art. L. 1432-7 C. transports : le refus injustifié engage la responsabilité du destinataire pour frais de re-livraison, stockage, ou retour expéditeur.'),
  (v_formation, v_module, 'qcm', 'Quelle est la prime typique d''une assurance ad valorem ?',
   '[{"id":"a","label":"5 % de la valeur","is_correct":false},{"id":"b","label":"0,15 à 0,30 % de la valeur déclarée","is_correct":true},{"id":"c","label":"Gratuite","is_correct":false},{"id":"d","label":"100 € fixe","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-02','lecon-3','ad-valorem'], 'mft-2026-gotrm:bc01-02-v3:l3:q8', true,
   'Assurance ad valorem (à la valeur réelle) : prime ~0,15-0,30 % de la valeur déclarée. Couvre vol, avarie, perte. Subrogation de l''assureur dans les droits contre le transporteur.'),
  (v_formation, v_module, 'qcm', 'Une cargaison 200 kg, valeur 500 000 €, sans déclaration, est volée en France. Indemnité due :',
   '[{"id":"a","label":"500 000 €","is_correct":false},{"id":"b","label":"750 € (plafond CT < 3 t)","is_correct":true},{"id":"c","label":"50 000 €","is_correct":false},{"id":"d","label":"Aucune","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-02','lecon-3','calcul'], 'mft-2026-gotrm:bc01-02-v3:l3:q9', true,
   'CT général < 3 t : MIN(200×23 ; 750) = 750 €. Le client subit 499 250 € de préjudice non couvert. Démontrer l''intérêt vital de la déclaration de valeur.'),
  (v_formation, v_module, 'qcm', 'En CMR, l''indemnité maximale en cas de simple retard est :',
   '[{"id":"a","label":"Le double du fret","is_correct":false},{"id":"b","label":"Le prix du transport (art. 23§5)","is_correct":true},{"id":"c","label":"100 % de la valeur marchandise","is_correct":false},{"id":"d","label":"10 €/kg","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-02','lecon-3','retard-cmr'], 'mft-2026-gotrm:bc01-02-v3:l3:q10', true,
   'Art. 23§5 CMR : retard simple = indemnité plafonnée au prix du transport. Pour couvrir le préjudice supérieur, déclaration d''intérêt spécial à la livraison (art. 26).'),
  (v_formation, v_module, 'qcm', 'Le destinataire doit faire ses réserves visibles à l''arrivée :',
   '[{"id":"a","label":"Verbalement uniquement","is_correct":false},{"id":"b","label":"Par écrit, immédiatement sur la LV ou dans les 3 jours (national)","is_correct":true},{"id":"c","label":"Dans les 30 jours","is_correct":false},{"id":"d","label":"Aucune obligation","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-02','lecon-3','reserves-delai'], 'mft-2026-gotrm:bc01-02-v3:l3:q11', true,
   'National : 3 j (visible) ou 7 j (cachée). CMR : 7 j (visible) ou 21 j (cachée). Réserves écrites obligatoires (LV + LRAR confirmant). Au-delà = forclusion.'),
  (v_formation, v_module, 'qcm', 'La force majeure se caractérise par :',
   '[{"id":"a","label":"Imprévisibilité, irrésistibilité, extériorité","is_correct":true},{"id":"b","label":"Force motrice du véhicule","is_correct":false},{"id":"c","label":"Vitesse excessive du conducteur","is_correct":false},{"id":"d","label":"Incident routier banal","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-02','lecon-3','force-majeure'], 'mft-2026-gotrm:bc01-02-v3:l3:q12', true,
   'Force majeure (art. 1218 C. civ.) : 3 critères cumulatifs - imprévisible (au moment du contrat), irrésistible (impossibilité d''exécution), extérieur (échappe au contrôle). Catastrophe naturelle, attentat, blocage frontalier.');

  -- ===== LEÇON 4 : 12 QCM =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qcm', 'Le droit de disposition de l''expéditeur cesse :',
   '[{"id":"a","label":"À la signature du devis","is_correct":false},{"id":"b","label":"Quand le destinataire a réclamé ou accepté la marchandise","is_correct":true},{"id":"c","label":"Au paiement","is_correct":false},{"id":"d","label":"Jamais","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-02','lecon-4','disposition'], 'mft-2026-gotrm:bc01-02-v3:l4:q1', true,
   'Art. 12 CMR / L. 1432-7 C. transports : le droit de disposition de l''expéditeur cesse dès remise du 2e exemplaire CMR au destinataire ou réclamation par lui de la marchandise.'),
  (v_formation, v_module, 'qcm', 'En cas d''empêchement à la livraison, le transporteur doit :',
   '[{"id":"a","label":"Détruire la marchandise","is_correct":false},{"id":"b","label":"Demander de nouvelles instructions à l''expéditeur","is_correct":true},{"id":"c","label":"Garder pour lui","is_correct":false},{"id":"d","label":"Donner à un tiers","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-02','lecon-4','empechement'], 'mft-2026-gotrm:bc01-02-v3:l4:q2', true,
   'Art. 14-16 CMR / L. 1432-8 C. transports : demander instructions, stocker en attendant, vente d''office en dernier recours.'),
  (v_formation, v_module, 'qcm', 'Le délai de prescription de l''action contre le transporteur en transport national est de :',
   '[{"id":"a","label":"6 mois","is_correct":false},{"id":"b","label":"1 an","is_correct":true},{"id":"c","label":"2 ans","is_correct":false},{"id":"d","label":"5 ans","is_correct":false}]'::jsonb,
   1, 'facile', ARRAY['gotrm','bc01-02','lecon-4','prescription'], 'mft-2026-gotrm:bc01-02-v3:l4:q3', true,
   'Art. L. 133-6 C. com. : prescription 1 an pour les actions en responsabilité contre le transporteur. Au-delà = action irrecevable. La guillotine du transport.'),
  (v_formation, v_module, 'qcm', 'Une mise en demeure efficace doit être :',
   '[{"id":"a","label":"Verbale par téléphone","is_correct":false},{"id":"b","label":"Envoyée en LRAR avec délai impératif","is_correct":true},{"id":"c","label":"Publiée au journal officiel","is_correct":false},{"id":"d","label":"Affichée en mairie","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-02','lecon-4','mise-en-demeure'], 'mft-2026-gotrm:bc01-02-v3:l4:q4', true,
   'Mise en demeure par LRAR : interrompt la prescription, fait courir les intérêts moratoires, démarre le délai d''action directe (30 j). Préalable obligatoire à l''action en justice.'),
  (v_formation, v_module, 'qcm', 'L''indemnité forfaitaire LME pour facture impayée à échéance est de :',
   '[{"id":"a","label":"10 €","is_correct":false},{"id":"b","label":"40 €","is_correct":true},{"id":"c","label":"100 €","is_correct":false},{"id":"d","label":"5 % du fret","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-02','lecon-4','lme'], 'mft-2026-gotrm:bc01-02-v3:l4:q5', true,
   'Art. L. 441-10 C. com. (LME) : indemnité forfaitaire 40 € par facture impayée + intérêts au taux BCE majoré de 10 points. À mentionner sur chaque facture.'),
  (v_formation, v_module, 'qcm', 'Sanction maximum pour mention LME manquante sur facture (personne morale) :',
   '[{"id":"a","label":"75 €","is_correct":false},{"id":"b","label":"7 500 €","is_correct":false},{"id":"c","label":"375 000 €","is_correct":true},{"id":"d","label":"1 % du CA","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-02','lecon-4','sanction-lme'], 'mft-2026-gotrm:bc01-02-v3:l4:q6', true,
   'Art. L. 441-9 C. com. : 75 000 € PP / 375 000 € PM par facture incomplète. Sanction lourde, contrôle DGCCRF possible.'),
  (v_formation, v_module, 'qcm', 'L''interruption de la prescription :',
   '[{"id":"a","label":"Suspend le décompte sans le remettre à zéro","is_correct":false},{"id":"b","label":"Remet le délai à zéro à compter de l''événement","is_correct":true},{"id":"c","label":"Annule la créance","is_correct":false},{"id":"d","label":"N''existe pas","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-02','lecon-4','interruption'], 'mft-2026-gotrm:bc01-02-v3:l4:q7', true,
   'Interruption (art. 2241 C. civ.) : reconnaissance de dette, action en justice, mise en demeure conservatoire. Le délai redémarre à zéro. À distinguer de la suspension (qui fige le décompte).'),
  (v_formation, v_module, 'qcm', 'L''affacturage permet au transporteur :',
   '[{"id":"a","label":"D''éviter de payer la TVA","is_correct":false},{"id":"b","label":"De recevoir 90-95 % du montant facturé immédiatement","is_correct":true},{"id":"c","label":"De doubler son CA","is_correct":false},{"id":"d","label":"De ne pas faire de facture","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-02','lecon-4','affacturage'], 'mft-2026-gotrm:bc01-02-v3:l4:q8', true,
   'Affacturage = cession de créances commerciales à un factor (Bibby, Eurofactor). Cash immédiat 90-95 %, solde au paiement client. Coût 1-2 % du CA. Idéal PME avec gros DO.'),
  (v_formation, v_module, 'qcm', 'L''injonction de payer est une procédure :',
   '[{"id":"a","label":"Longue et coûteuse","is_correct":false},{"id":"b","label":"Rapide (~2 semaines, 50 €) pour créance certaine","is_correct":true},{"id":"c","label":"Réservée au pénal","is_correct":false},{"id":"d","label":"Non disponible en commerce","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-02','lecon-4','injonction'], 'mft-2026-gotrm:bc01-02-v3:l4:q9', true,
   'Injonction de payer : procédure rapide (~2 semaines, 50 €) au tribunal de commerce pour créance certaine, liquide, exigible. Ordonnance non contradictoire signifiée par huissier.'),
  (v_formation, v_module, 'qcm', 'Une signature « sans réserves » à la livraison vaut :',
   '[{"id":"a","label":"Acceptation de l''état apparent (visible) de la marchandise","is_correct":true},{"id":"b","label":"Refus de paiement","is_correct":false},{"id":"c","label":"Annulation du contrat","is_correct":false},{"id":"d","label":"Augmentation du fret","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-02','lecon-4','signature'], 'mft-2026-gotrm:bc01-02-v3:l4:q10', true,
   'Signature sans réserves = acceptation de l''état apparent. Pour avaries cachées, le destinataire dispose encore de 7 j (national) ou 21 j (CMR). Au-delà = forclusion.'),
  (v_formation, v_module, 'qcm', 'Sur livraison du 12/03/2026, la prescription expire le :',
   '[{"id":"a","label":"12/06/2026","is_correct":false},{"id":"b","label":"12/03/2027","is_correct":true},{"id":"c","label":"12/03/2031","is_correct":false},{"id":"d","label":"Jamais","is_correct":false}]'::jsonb,
   1, 'difficile', ARRAY['gotrm','bc01-02','lecon-4','calcul-prescription'], 'mft-2026-gotrm:bc01-02-v3:l4:q11', true,
   'Prescription 1 an national (art. L. 133-6 C. com.) : 12/03/2026 + 1 an = 12/03/2027. Au-delà, action irrecevable sauf interruption (LRAR de mise en demeure).'),
  (v_formation, v_module, 'qcm', 'Une réclamation par mail après 15 jours pour une avarie cachée en transport national :',
   '[{"id":"a","label":"Est valable","is_correct":false},{"id":"b","label":"Est forclos (délai 7 j dépassé)","is_correct":true},{"id":"c","label":"Permet une action de 5 ans","is_correct":false},{"id":"d","label":"Est suspendue à validation préfectorale","is_correct":false}]'::jsonb,
   1, 'moyen', ARRAY['gotrm','bc01-02','lecon-4','forclusion'], 'mft-2026-gotrm:bc01-02-v3:l4:q12', true,
   'Avarie cachée en national : délai 7 jours (art. L. 133-3 C. com.). 15 jours = forclusion. Le destinataire perd définitivement son droit à indemnité. Avantage transporteur en cas de signature « sans réserves ».');

  -- ===== 8 QR (cas pratiques métier, max_score 5-7) =====
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, 'qr',
   'La société Transex Logistics reçoit une commande de Lactalis pour livrer 24 palettes de yaourts (chaîne du froid 2-4°C) de Laval à Carquefou. Transex achète la prestation à Transports Boucherie pour 620 € HT. Transex facture à Lactalis 890 € HT. Transex choisit le sous-traitant et garantit la livraison à temps avec respect strict de la chaîne du froid. (a) Qualifiez juridiquement la position de Transex. (b) Détaillez le test des 4 indices. (c) Si la chaîne du froid est rompue (marchandise détruite, valeur 28 000 €), qui indemnise Lactalis et sur quel fondement ? (d) Quelle action récursoire est possible ?',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-02','qr','qualification','commission'], 'mft-2026-gotrm:bc01-02-v3:qr1', true,
   '(a) Transex est commissionnaire de transport (art. L. 132-1 C. com.).\n\n(b) Test des 4 indices : (1) Choix libre du mode/sous-traitant : OUI (Transex choisit Boucherie) ; (2) Marge sur sous-traitance : OUI (270 € soit 30,3 %) ; (3) Garantie du résultat : OUI (chaîne du froid garantie) ; (4) Refacturation à l''identique : NON (890 vs 620). Conclusion : commissionnaire.\n\n(c) Transex indemnise Lactalis sur le fondement de l''art. L. 132-4 C. com. (responsabilité de plein droit du commissionnaire). Indemnité plafonnée par contrat-type ATP frigo (souvent 6 €/kg) : 24 × 600 × 6 = 86 400 €, plafonnée à la valeur réelle 28 000 € ⇒ 28 000 € dus.\n\n(d) Action récursoire : Transex se retourne contre Boucherie sur le fondement de l''art. L. 132-6 C. com. Limitée aux plafonds CT du sous-traitant. Si Boucherie a souscrit RCCT 1,5 M€, indemnité couverte par son assurance.\n\nVigilance : Transex doit avoir la capacité professionnelle de commissionnaire + garantie financière 100 k€ (art. R. 1411-9), sinon nullité du contrat + amende 15 k€ PP / 75 k€ PM.'),

  (v_formation, v_module, 'qr',
   'Vous gérez une PME de transport (CA 4 M€). Un nouveau client (industriel automobile) vous demande de transporter 18 palettes de pièces métalliques (poids 350 kg/palette, valeur 90 000 €) de Strasbourg à Madrid (Espagne) en J+2. Vous décidez de sous-traiter à un partenaire espagnol pour 1 850 €. Vous facturez 2 380 € au client. (a) Quel régime juridique s''applique ? (b) Êtes-vous transporteur ou commissionnaire ? (c) Calculez votre marge brute (€ et %). (d) Si la marchandise est volée en route sans déclaration de valeur, quelle indemnité maximale due au client ? (e) Comment auriez-vous pu sécuriser cette opération ?',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-02','qr','cmr','calcul'], 'mft-2026-gotrm:bc01-02-v3:qr2', true,
   '(a) Régime CMR : transport routier international entre 2 pays signataires (France + Espagne).\n\n(b) Commissionnaire : choix libre du sous-traitant + marge + garantie résultat + refacturation différenciée.\n\n(c) Marge brute : 2 380 − 1 850 = 530 € HT, soit 22,3 % (530/2380).\n\n(d) Plafond CMR : 18 × 350 × 8,33 DTS/kg ≈ 18 × 350 × 10,80 € = 68 040 €. Pas de plafond par envoi en CMR. La valeur 90 000 € > plafond CMR ⇒ indemnité due = 68 040 €. Préjudice non couvert : 21 960 € à charge du client.\n\n(e) Sécurisation : (i) déclaration de valeur écrite (art. 24 CMR) à 90 000 € + surprime ; (ii) déclaration d''intérêt spécial à la livraison (art. 26 CMR) pour le retard si délai impératif ; (iii) assurance ad valorem souscrite par le client (~270 € de prime à 0,3 %) ; (iv) lettre de voiture CMR en 3 exemplaires originaux signée à chaque maillon ; (v) RCCT du sous-traitant espagnol vérifiée 1,5 M€ minimum.'),

  (v_formation, v_module, 'qr',
   'Comparez précisément le régime CMR (Genève 1956) et le contrat-type général français (décret 99-269) sur les 6 points suivants : (a) champ d''application ; (b) caractère impératif vs dérogeable ; (c) document de transport ; (d) plafonds d''indemnité ; (e) délais de réclamation visible/cachée ; (f) prescription. Illustrez chaque écart par un exemple chiffré pour une cargaison de 4 t valant 50 000 €.',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-02','qr','cmr','comparaison'], 'mft-2026-gotrm:bc01-02-v3:qr3', true,
   '(a) Champ : CMR = international (2 États signataires différents). CT général = national FR uniquement.\n\n(b) Caractère : CMR impérative (clauses contraires nulles, art. 41). CT général dérogeable par accord écrit (art. L. 1432-2).\n\n(c) Document : CMR = lettre de voiture obligatoire en 3 exemplaires originaux (art. 4-6, 15 mentions). CT national = lettre de voiture facultative mais recommandée.\n\n(d) Plafonds : CMR = 8,33 DTS/kg ≈ 10,80 €/kg, pas de plafond global. CT général ≥ 3 t = 14 €/kg + 2 300 € envoi (MIN). CT général < 3 t = 23 €/kg + 750 € envoi (MIN).\n\n(e) Délais : CMR visible 7 j / cachée 21 j. CT national visible 3 j / cachée 7 j.\n\n(f) Prescription : CMR 1 an (3 ans dol). CT national 1 an. Identique sauf dol.\n\nExemple cargaison 4 t valant 50 000 €, détruite : (i) Transport Lyon-Marseille (CT général ≥ 3 t) : MIN(4000×14 ; 2 300) = 2 300 €. (ii) Transport Lyon-Madrid (CMR) : 4000×10,80 = 43 200 €. Différence : 18,8× plus en international. Conséquence : toujours préciser le régime applicable dès le devis.'),

  (v_formation, v_module, 'qr',
   'Le 14 mars 2026 à 8h, vos Transports Martin prennent en charge 30 palettes de produits chimiques chez Sanofi (Évry). Le conducteur signe la lettre de voiture sans réserves, alors que 3 palettes sont visiblement penchées et 1 colis a un emballage déchiré. À l''arrivée chez le destinataire (Lille) le 14/03 à 17h, 15 colis sont endommagés. Le destinataire réclame 18 000 €. (a) Quelle est la situation juridique de Transports Martin ? (b) Calculez l''indemnité due. (c) Quelles erreurs ont été commises ? (d) Procédure pratique à mettre en place pour éviter ce type de situation.',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-02','qr','reserves','responsabilite'], 'mft-2026-gotrm:bc01-02-v3:qr4', true,
   '(a) Situation juridique : la signature sans réserves vaut acceptation de l''état apparent au chargement (jurisprudence constante + art. 9 CMR pour international). Transports Martin est présumé responsable des 15 colis endommagés.\n\n(b) Calcul indemnité (CT général, envoi probablement > 3 t) : poids 15 × 25 = 375 kg. Plafond / kg : 375 × 14 = 5 250 €. Plafond / envoi ≥ 3 t : 2 300 €. Indemnité due = MIN = 2 300 €. Le destinataire subit 15 700 € de préjudice non couvert.\n\n(c) Erreurs commises : (1) Conducteur n''a pas inspecté la marchandise au chargement ; (2) Aucune réserve écrite sur la LV ; (3) Pas de photo prise du chargement ; (4) Pas d''alerte au DO sur le mauvais conditionnement.\n\n(d) Procédure pratique : (i) formation conducteurs - inspection visuelle systématique au chargement ; (ii) photos systématiques (mobile + envoi cloud horodaté) ; (iii) tampon « Pris en charge sous réserves apparentes » pour cas litigieux ; (iv) instructions écrites au DO en cas de mauvais conditionnement (mail confirmant) ; (v) refus de prise en charge si dommages graves visibles ; (vi) check-list 5 points : nombre colis, état emballage, état palettes, présence scellés, conformité étiquetage.'),

  (v_formation, v_module, 'qr',
   'Vous transportez 800 kg de matériel hi-tech (valeur 50 000 €) entre Lille et Paris pour un client B2B. Pas de contrat signé, pas de CGV transmises, pas de déclaration de valeur. Le chauffeur a un accident, marchandise détruite. Le client réclame 50 000 €. (a) Quel régime s''applique ? (b) Quelle indemnité maximale due ? (c) Quels recours pour le client ? (d) Comment auriez-vous pu vous protéger ? (e) Quelles clauses CGV ajouter pour sécuriser à l''avenir ?',
   NULL, 6, 'difficile', ARRAY['gotrm','bc01-02','qr','contrat-type','calcul'], 'mft-2026-gotrm:bc01-02-v3:qr5', true,
   '(a) Régime : contrat-type général (décret 99-269) applicable d''office en l''absence de contrat écrit (transport national).\n\n(b) Calcul : envoi < 3 t (800 kg). Plafond / kg : 800 × 23 = 18 400 €. Plafond / envoi : 750 €. Indemnité due = MIN = 750 €. Le client subit 49 250 € de préjudice non couvert.\n\n(c) Recours du client : (i) sa propre assurance « tous risques marchandises » (souvent souscrite par les industriels) qui couvrira le solde si elle existe ; (ii) action en faute lourde du transporteur (art. L. 133-8 C. com.) si négligence prouvée - lève les plafonds, prescription portée à 5 ans ; (iii) si commissionnaire intermédiaire - recours sur celui-ci.\n\n(d) Protection préalable : (i) bon de commande signé avec mention valeur déclarée 50 000 € ; (ii) souscription d''une assurance ad valorem ; (iii) transmission CGV par mail pour acceptation tacite.\n\n(e) Clauses CGV à ajouter : (1) « Le contrat-type général s''applique sauf dérogation expresse écrite » ; (2) « Pour toute marchandise > 14 €/kg, déclaration de valeur écrite obligatoire avant le transport, à défaut plafonds CT s''appliquent automatiquement » ; (3) « Pénalités LME au taux BCE+10 + indemnité 40 € » ; (4) « Tribunal de commerce de [siège transporteur] compétent » ; (5) « Réserves obligatoires sous 3 j (visible) / 7 j (cachée) sous peine de forclusion ».'),

  (v_formation, v_module, 'qr',
   'Vous recevez une commande Lyon → Stuttgart (Allemagne) : 28 palettes de pièces auto (8 960 kg), valeur 145 000 €, délai impératif J+2 avant 8h pour chaîne Mercedes (sinon arrêt chaîne facturé 80 000 €/jour). (a) Quel régime juridique ? (b) Indemnité maximale CMR sans déclaration en cas de destruction ? (c) Indemnité maximale en cas de retard simple ? (d) Comment sécuriser cette opération en utilisant la CMR (articles précis) ? (e) Quelles assurances complémentaires souscrire ?',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-02','qr','cmr','declaration'], 'mft-2026-gotrm:bc01-02-v3:qr6', true,
   '(a) Régime CMR (France + Allemagne signataires).\n\n(b) Plafond CMR : 8 960 × 10,80 = 96 768 €. Préjudice non couvert : 48 232 € à charge du client.\n\n(c) Retard simple (art. 23§5 CMR) : indemnité plafonnée au prix du transport (≈ 2 200 €). Si arrêt chaîne 80 000 €/jour, préjudice non couvert massif.\n\n(d) Sécurisation CMR : (1) Déclaration de valeur (art. 24 CMR) à 145 000 € sur la lettre de voiture, avec surprime de transport (~0,5-1 % de la valeur) ; (2) Déclaration d''intérêt spécial à la livraison (art. 26 CMR) pour couvrir le retard - mention sur LV avec montant de l''intérêt ; (3) Lettre de voiture CMR en 3 exemplaires originaux mentionnant ces 2 déclarations + clause « délai impératif J+2 avant 8h » ; (4) Vérification ADR si applicable.\n\n(e) Assurances complémentaires : (i) assurance « tous risques marchandises » spécifique automotive (couvre 145 k€) ; (ii) assurance perte d''exploitation pour le client (couvre l''arrêt chaîne) ; (iii) RCCT transporteur 1,5 M€ minimum ; (iv) si sous-traitance : RCCT du sous-traitant + certif transporteur en règle (REGT). En transport international hi-value/just-in-time, la double déclaration art. 24+26 CMR est INCONTOURNABLE.'),

  (v_formation, v_module, 'qr',
   'Le 18 mars 2026, vous livrez 40 palettes de meubles à un client GMS (Conforama). Le manutentionnaire signe le BL sans réserves. Le lendemain (19/03), le directeur de magasin appelle : 8 palettes ont été endommagées par un chariot pendant le déchargement (manipulation par personnel Conforama). Il réclame 12 000 €. (a) Êtes-vous responsable ? Argumentez juridiquement. (b) Quelle réponse écrite envoyez-vous ? (c) Comment formaliser cette protection à l''avenir dans vos CGV et procédures ?',
   NULL, 6, 'moyen', ARRAY['gotrm','bc01-02','qr','livraison','cgv'], 'mft-2026-gotrm:bc01-02-v3:qr7', true,
   '(a) Non, vous n''êtes pas responsable. La signature du BL sans réserves vaut acceptation de l''état apparent à la livraison effective. Les dommages sont survenus APRÈS la livraison (déchargement par personnel Conforama). La responsabilité du transporteur (art. L. 133-1 C. com.) cesse à la livraison effective. C''est le destinataire qui assume les risques liés à son propre déchargement.\n\n(b) Mail de réponse type : « Cher Monsieur, j''accuse réception de votre réclamation du 19/03/2026. Conformément au contrat-type général (décret 99-269) et à l''article L. 133-1 C. com., la responsabilité du transporteur s''achève à la livraison effective, attestée par la signature du bon de livraison sans réserves. Les dommages survenus pendant le déchargement, effectué par votre personnel à l''aide de votre matériel, ne peuvent m''être imputés. Je vous invite à vous retourner vers votre assureur RC ou à examiner vos procédures internes de manutention. Restant à votre disposition pour vos prochaines opérations, cordialement. »\n\n(c) Protection à l''avenir : (i) Clause CGV : « La responsabilité du transporteur cesse à la livraison effective. Tout dommage causé pendant le déchargement effectué par le destinataire est à sa charge » ; (ii) Procédure conducteur : ne JAMAIS participer au déchargement sauf clause expresse + facturation distincte ; (iii) Photos systématiques de l''état des palettes à l''arrivée AVANT déchargement ; (iv) Tampon « Livré en bon état apparent. Tout dommage ultérieur non imputable au transporteur » sur les BL ; (v) Formation conducteurs sur le moment juridique de la livraison.'),

  (v_formation, v_module, 'qr',
   'Vous gérez une entreprise de transport. Un nouveau client (PME industrielle, CA 5 M€, Coface B+) vous demande 120 transports/an à 1 200 € HT chacun (CA annuel 144 000 €). Vous voulez sécuriser le paiement et limiter les risques d''impayés. (a) Quel diagnostic financier faites-vous ? (b) Détaillez un plan en 4 leviers concrets de sécurisation. (c) Calculez le coût annuel de chaque levier et le ROI global. (d) Quelles clauses LME et CGV inclure absolument ? (e) Que faire en cas d''impayé constaté à J+45 après facturation ?',
   NULL, 7, 'difficile', ARRAY['gotrm','bc01-02','qr','paiement','strategie'], 'mft-2026-gotrm:bc01-02-v3:qr8', true,
   '(a) Diagnostic : Coface B+ = risque modéré. CA client 5 M€ vs facturation 144 k€/an = ratio 2,9 % (dépendance acceptable). Volume 120 transports = client significatif. Risque cumulé : ~12 k€ (1 mois de facturation impayé).\n\n(b) Plan en 4 leviers : (1) Acompte 30 % à la commande pour les 6 premiers mois (signal pro + cash immédiat) ; (2) Affacturage sur ce client : cash 90 % à la facture, sécurité tréso, coût 1,5 % CA ; (3) Assurance impayés Coface : prime 0,5 % × 144 k€ = 720 €/an, indemnité 80 % en cas de défaillance ; (4) CGV signées avec clause LME complète + suspension prestations en cas de retard > 30 j.\n\n(c) Coût annuel : (i) Acompte = 0 € ; (ii) Affacturage = 1,5 % × 144 k€ = 2 160 € ; (iii) Coface = 720 € ; (iv) CGV/contrat = ~0 € (template juridique amorti). Total = 2 880 €/an. ROI : sécurité gagnée 115 k€ (80 % de 144 k€) - coût 2 880 € = ROI 40× (rentabilité immédiate dès le premier impayé évité).\n\n(d) Clauses LME et CGV obligatoires : (1) « Délai paiement 30 jours fin de mois (LME 60 j max) » ; (2) « Pénalités au taux BCE majoré de 10 points par jour calendaire » ; (3) « Indemnité forfaitaire 40 € par facture impayée (art. L. 441-10 C. com.) » ; (4) « Suspension immédiate des prestations en cas de retard > 30 j » ; (5) « Tribunal de commerce de [siège] compétent » ; (6) « Acceptation des CGV vaut renonciation à toute clause contraire des bons de commande client ».\n\n(e) Action à J+45 : (1) Mail de relance amiable (J+30) puis téléphonique (J+38) ; (2) LRAR de mise en demeure à J+45 (interrompt prescription, fait courir intérêts, démarre les 30 j d''action directe) ; (3) Si pas de réponse à J+75, action directe contre expéditeur ou destinataire (art. L. 3242-3 C. transports) ; (4) Si récidive, injonction de payer (50 €, 2 semaines au TC) ; (5) Activation assurance Coface si défaillance avérée.');

  -- =================================================================
  -- QUIZZES (4 entraînement + 1 examen blanc module)
  -- =================================================================

  -- Quiz 1 — Le contrat de transport
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Le contrat de transport — Quiz',
          'Quiz d''entraînement (12 questions) sur la nature, la formation et les parties au contrat de transport, distinction commission vs transport.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-02-v3:l1:%';

  -- Quiz 2 — CMR et contrat-type
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'CMR et contrat-type général — Quiz',
          'Quiz d''entraînement (12 questions) sur la Convention CMR (Genève 1956), le contrat-type général (déc. 99-269), plafonds d''indemnité et délais.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-02-v3:l2:%';

  -- Quiz 3 — Droits et obligations
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Droits et obligations des parties — Quiz',
          'Quiz d''entraînement (12 questions) sur les obligations des parties, la responsabilité de plein droit du transporteur (art. L. 133-1), les réserves et l''action directe.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-02-v3:l3:%';

  -- Quiz 4 — Modifications, contestations, prescription
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Modifications, contestations, prescription — Quiz',
          'Quiz d''entraînement (12 questions) sur la modification d''instructions, l''empêchement à la livraison, la procédure de réclamation, la prescription et la sécurisation du paiement.',
          'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-02-v3:l4:%';

  -- Examen blanc module — 15 QCM transversaux + 5 QR cas pratique
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold, is_mock_exam)
  VALUES (v_module, 'Examen blanc — BC01-02 Le contrat de transport',
          'Examen blanc reproduisant les conditions de l''examen RNCP : 15 QCM transversaux (4 leçons) + 5 QR cas pratiques métier, durée 60 min, seuil 50 %.',
          'examen', 3600, 50, true)
  RETURNING id INTO v_quiz_eb;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref) FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref IN (
     -- 4 QCM Leçon 1
     'mft-2026-gotrm:bc01-02-v3:l1:q1','mft-2026-gotrm:bc01-02-v3:l1:q2',
     'mft-2026-gotrm:bc01-02-v3:l1:q4','mft-2026-gotrm:bc01-02-v3:l1:q7',
     -- 4 QCM Leçon 2
     'mft-2026-gotrm:bc01-02-v3:l2:q1','mft-2026-gotrm:bc01-02-v3:l2:q2',
     'mft-2026-gotrm:bc01-02-v3:l2:q5','mft-2026-gotrm:bc01-02-v3:l2:q11',
     -- 4 QCM Leçon 3
     'mft-2026-gotrm:bc01-02-v3:l3:q2','mft-2026-gotrm:bc01-02-v3:l3:q4',
     'mft-2026-gotrm:bc01-02-v3:l3:q5','mft-2026-gotrm:bc01-02-v3:l3:q9',
     -- 3 QCM Leçon 4
     'mft-2026-gotrm:bc01-02-v3:l4:q3','mft-2026-gotrm:bc01-02-v3:l4:q5',
     'mft-2026-gotrm:bc01-02-v3:l4:q11',
     -- 5 QR (cas pratiques transversaux)
     'mft-2026-gotrm:bc01-02-v3:qr1','mft-2026-gotrm:bc01-02-v3:qr2',
     'mft-2026-gotrm:bc01-02-v3:qr4','mft-2026-gotrm:bc01-02-v3:qr5',
     'mft-2026-gotrm:bc01-02-v3:qr8'
   );

  RAISE NOTICE '✓ GOTRM BC01-02 v3 dense importé : 4 leçons (contrat de transport, CMR/CT, droits/obligations, prescription), 48 QCM, 8 QR cas pratiques métier, 5 quiz (4 entraînement + 1 examen blanc 15 QCM + 5 QR / 60 min).';
END $bc01_02_v3$;
