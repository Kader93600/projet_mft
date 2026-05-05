-- =====================================================================
-- GOTRM (RNCP 40990) — BC01-09 : Litiges, réclamations et indemnisations
-- Régime de responsabilité, plafonds, prescriptions, gestion des sinistres.
-- =====================================================================

DO $bc01_09$
DECLARE
  v_formation uuid; v_bloc int; v_module uuid;
  v_lesson_1 uuid; v_lesson_2 uuid; v_lesson_3 uuid; v_lesson_4 uuid;
  v_quiz_1 uuid; v_quiz_2 uuid; v_quiz_3 uuid; v_quiz_4 uuid; v_quiz_eb uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc.'; END IF;

  DELETE FROM public.modules WHERE slug = 'gotrm-bc01-09-litiges-indemnisation';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'BC01-09 — Litiges, réclamations et indemnisations',
    'gotrm-bc01-09-litiges-indemnisation', v_bloc,
    'Régime de responsabilité du transporteur, plafonds d''indemnisation, prescriptions, gestion amiable et contentieuse des sinistres.',
    'avance', 180, 90
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 90, true) ON CONFLICT DO NOTHING;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation AND source_ref LIKE 'mft-2026-gotrm:bc01-09:%';

  -- =================================================================
  -- LEÇON 1 — Régime de responsabilité
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Le régime de responsabilité du transporteur',
    'gotrm-bc01-09-01-regime-responsabilite', 1, 50,
$lesson1$
# Le régime de responsabilité du transporteur

Le transporteur est tenu d'une **obligation de résultat** : livrer la marchandise en l'état dans les délais convenus. À défaut, il est présumé responsable, sauf à prouver une cause d'exonération. Comprendre ce régime est essentiel pour évaluer les risques et organiser sa défense.

> 🎯 **Objectifs de la leçon**
>
> - Comprendre l'**obligation de résultat** du transporteur.
> - Distinguer **avarie**, **perte** et **retard**.
> - Identifier les **causes d'exonération** (force majeure, faute, vice propre).
> - Maîtriser les **3 régimes** : national, CMR, contractuel.

---

## 1. L'obligation de résultat

### 1.1 Le principe

Article **L. 133-1 du Code de commerce** :

> *« Le voiturier est garant de la perte des objets à transporter, hors les cas de force majeure. Il est garant des avaries autres que celles qui proviennent du vice propre de la chose ou de la force majeure. »*

Le transporteur est **présumé responsable** dès la prise en charge. C'est au transporteur de prouver une cause d'exonération, pas au client de prouver une faute.

### 1.2 Les 3 types de manquements

| Type | Définition | Exemple |
|---|---|---|
| **Avarie** | Détérioration physique de la marchandise | Carton écrasé, palette mouillée, produit cassé |
| **Perte totale** | Disparition de tout ou partie | Vol, marchandise non livrée, container ouvert |
| **Perte partielle** | Manque de quantité par rapport au document | 47 colis livrés sur 50 |
| **Retard** | Livraison hors délai contractuel | Livraison J+3 au lieu de J+1 |

### 1.3 La période de responsabilité

```
Prise en charge ──────────────► Livraison effective
       │                                │
       └────── PÉRIODE DE RESPONSABILITÉ ┘
```

Avant la prise en charge ou après la livraison effective, le transporteur n'est plus responsable. La signature du document de transport (CMR/LV/BL) matérialise les bornes.

---

## 2. Les causes d'exonération

### 2.1 La force majeure

3 critères cumulatifs à prouver :

| Critère | Définition |
|---|---|
| **Extérieur** | Événement extérieur à l'activité du transporteur |
| **Imprévisible** | Impossible à anticiper raisonnablement |
| **Irrésistible** | Impossible à éviter ou aux conséquences inévitables |

| Exemples reconnus | Exemples non reconnus |
|---|---|
| Tempête majeure imprévue | Pluie en hiver |
| Attentat sur le trajet | Embouteillage |
| Blocage routier inopiné par manifestation soudaine | Grève prévue à l'avance |
| Incendie de forêt non prévisible | Panne mécanique du véhicule |

> ⚠️ **Critères stricts**
>
> Les juges interprètent la force majeure de façon restrictive. Une simple difficulté ou un événement « grave » mais prévisible (intempéries hivernales, grève annoncée, embouteillage chronique) n'est généralement pas reconnu.

### 2.2 Le vice propre de la marchandise

Défaut interne à la marchandise, indépendant de toute faute du transporteur.

| Exemples | Détail |
|---|---|
| Fermentation de produits agricoles | Marchandise altérée par sa nature |
| Pourriture de fruits non protégés | Inhérent au produit |
| Auto-inflammation de matières instables | Risque interne |
| Évaporation d'un liquide volatil | Caractéristique du produit |

### 2.3 La faute de l'expéditeur ou du destinataire

| Exemples | Détail |
|---|---|
| Emballage insuffisant | Carton trop fin pour le poids |
| Marquage absent ou incorrect | Pas d'indication « Fragile » |
| Mauvais arrimage par le chargeur | Si effectué par le chargeur |
| Marchandise non préparée à l'enlèvement | Retard imputable au client |
| Documents manquants ou erronés | Bloquent la chaîne |

### 2.4 L'instruction du chargeur

Si le transporteur agit conformément aux instructions écrites du chargeur (itinéraire, mode de transport, manutention), il s'exonère sauf faute manifeste.

### 2.5 Les exonérations spécifiques CMR (article 17 §4)

La CMR ajoute des **causes particulières** d'exonération :
- a) Véhicules ouverts non bâchés convenus expressément
- b) Absence ou défectuosité d'emballage
- c) Manutention par chargeur, destinataire ou tiers
- d) Nature de certaines marchandises (rouille, casse, fuite)
- e) Insuffisance ou imperfection des marques ou numéros
- f) Transport d'animaux vivants

---

## 3. Les 3 régimes applicables

### 3.1 Régime national (contrat-type général, décret 99-269)

| Élément | Valeur |
|---|---|
| Plafond avarie/perte | 33 €/kg ou 1 000 €/colis (le moindre des deux) |
| Plafond perte totale colis | 1 000 €/colis |
| Plafond retard | Limité au prix du transport |
| Prescription | 1 an (article L. 133-6 Code de commerce) |
| Réserve apparente | Jour de la livraison |
| Réserve non apparente | 3 jours ouvrés |

### 3.2 Régime CMR (international)

| Élément | Valeur |
|---|---|
| Plafond avarie/perte | 8,33 DTS/kg (~10,80 €/kg en 2026) |
| Plafond retard | Limité au prix du transport |
| Prescription | 1 an, ou 3 ans en cas de dol/faute lourde |
| Réserve apparente | Jour de la livraison |
| Réserve non apparente | 7 jours ouvrés |
| Réserve retard | 21 jours |

### 3.3 Régime contractuel

Les parties peuvent **déroger** aux contrats-types par écrit, à condition de ne pas tomber sous les plafonds légaux minimums (sauf si déclaration de valeur expresse).

| Possibilités | Limites |
|---|---|
| Plafonds **augmentés** par déclaration de valeur (avec supplément) | Possibilité encadrée |
| Plafonds **diminués** | Souvent possible (mais à éviter pour le transporteur en général) |
| Délais de réserve **prolongés** | Possible |
| Délais de prescription | Non modifiables |

---

## 4. La déclaration de valeur

### 4.1 Principe

L'expéditeur peut, en payant un **supplément de prix**, fixer une valeur **supérieure** au plafond légal. Cette valeur s'appliquera en cas de sinistre (limité à la valeur déclarée).

### 4.2 Mise en œuvre

| Étape | Action |
|---|---|
| Mention sur la lettre de voiture | Case spécifique cochée et chiffrée |
| Acceptation transporteur | Confirmation de la couverture |
| Supplément de prix | ~ 0,5 % à 2 % de la valeur déclarée |
| Vérification assurance | Police RC adaptée au montant |

### 4.3 Intérêt spécial à la livraison

Concept distinct (mais lié) : montant fixé pour le **retard** ou un dommage particulier, au-delà du simple prix du transport.

---

## 5. La faute lourde et le dol

### 5.1 Définition

| Notion | Définition |
|---|---|
| **Dol** | Faute intentionnelle (ex : vol par le conducteur) |
| **Faute lourde** | Négligence si grave qu'elle équivaut au dol par son insouciance |
| **Faute inexcusable** (CMR art. 29) | Comportement qui démontre une indifférence aux risques |

### 5.2 Conséquences

En cas de dol ou de faute équivalente :
- Les **plafonds sautent** (national et CMR)
- L'indemnisation est **intégrale** (valeur réelle de la marchandise)
- La **prescription** passe à 3 ans (au lieu de 1 an)
- L'**assurance RC professionnelle** peut refuser la garantie

### 5.3 Exemples reconnus comme faute lourde

- Antivol GPS désactivé volontairement
- Stationnement en zone connue à risques sans précautions
- Conducteur quittant le véhicule longtemps avec marchandises de valeur
- Itinéraire à risque emprunté sans nécessité
- Falsification de documents tachygraphes
- Sous-traitance occulte à un tiers non autorisé

---

## 6. Cas pratique : qualifier un sinistre

**Contexte** : Vous transportez 200 cartons de chaussures Lyon → Marseille. À l'arrivée, le destinataire signale 12 cartons écrasés (face supérieure enfoncée). Au chargement, votre conducteur a noté sur la CMR : « Palette n° 2 et n° 5 : manutention par chariot du chargeur, gerbage 4 niveaux non sécurisé. »

### Analyse

| Élément | Diagnostic |
|---|---|
| Type de sinistre | Avarie partielle (12 cartons sur 200) |
| Régime | National (Lyon-Marseille) → contrat-type 99-269 |
| Plafond | 33 €/kg ou 1 000 €/colis (le moindre) |
| Cause apparente | Manutention par chargeur (gerbage 4 niveaux) |

### Stratégie de défense

1. **Réserves au chargement** :
- La CMR mentionne explicitement le mode de manutention par chargeur et le gerbage
- C'est une cause d'exonération forte (faute du chargeur, art. 17 §4 CMR transposable au national)

2. **Vérification chez le destinataire** :
- Réserves émises au déchargement ? Si oui, dans le délai (apparent à la livraison) ?
- Photos des cartons endommagés à l'arrivée
- Comparaison avec la photo de chargement (si disponible)

3. **Argumentaire** :
- Preuve par la CMR signée que le chargement a été fait par le client
- Le gerbage 4 niveaux par le client = cause directe possible des écrasements
- Demande de partage de responsabilité ou exonération totale

4. **Calcul de l'indemnité maximale (si responsabilité retenue)** :
- 12 cartons × poids unitaire (à confirmer)
- Plafond : moindre de (12 × 1 000 €) = 12 000 € OU (poids total × 33 €/kg)
- Exemple : si 25 kg/carton → 300 kg × 33 € = 9 900 €

### Procédure recommandée

1. Réponse écrite sous 7 jours
2. Demande d'expertise contradictoire
3. Production de la CMR signée avec mentions
4. Photos chargement/déchargement
5. Si désaccord persistant, médiation amiable avant judiciaire

---

> ✅ **À retenir**
>
> - Le transporteur a une **obligation de résultat** (présomption de responsabilité).
> - 3 manquements : **avarie**, **perte**, **retard**.
> - Causes d'exonération : **force majeure**, **vice propre**, **faute du client**, **instruction écrite**.
> - Plafonds : **33 €/kg ou 1 000 €/colis** (national), **8,33 DTS/kg** (CMR).
> - **Faute lourde / dol** : plafonds sautent, indemnisation intégrale, prescription 3 ans.
$lesson1$,
'Obligation de résultat (L. 133-1), avarie/perte/retard, causes d''exonération (force majeure, vice propre, faute client), 3 régimes (national/CMR/contrat), faute lourde art. 29.'
  ) RETURNING id INTO v_lesson_1;

  -- =================================================================
  -- LEÇON 2 — Plafonds et prescriptions
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Plafonds d''indemnisation et prescriptions',
    'gotrm-bc01-09-02-plafonds-prescriptions', 2, 40,
$lesson2$
# Plafonds d'indemnisation et prescriptions

Connaître par cœur les **plafonds** et les **délais de prescription** est indispensable. Une erreur sur ces points coûte cher : dépassement de plafond non couvert par l'assurance, prescription opposée au client, etc.

> 🎯 **Objectifs de la leçon**
>
> - Maîtriser les **plafonds d'indemnisation** par type de transport.
> - Calculer une **indemnisation** dans un cas concret.
> - Connaître les **délais de prescription** et leurs interruptions.
> - Identifier les **frais accessoires** indemnisables.

---

## 1. Les plafonds d'indemnisation

### 1.1 Synthèse comparative

| Régime | Avarie/Perte | Retard | Source légale |
|---|---|---|---|
| **National (contrat-type)** | 33 €/kg OU 1 000 €/colis (le moindre) | Prix du transport | Décret 99-269 art. 21 |
| **CMR international** | 8,33 DTS/kg | Prix du transport | CMR art. 23 |
| **National avec contrat spécifique** | Selon contrat-type (denrées, déménagement, etc.) | Selon clause | Décrets spécifiques |
| **Avec déclaration de valeur** | Valeur déclarée maximum | Selon contrat | Choix des parties |
| **Faute lourde / dol** | Indemnisation intégrale | Idem | L. 133-1, CMR art. 29 |

### 1.2 La règle du « moindre des deux » (national)

Pour un sinistre national, on calcule **les deux plafonds** et on prend le plus faible.

> 📌 **Exemple chiffré**
>
> Avarie sur **5 colis de 30 kg** chacun.
> - Plafond poids : 5 × 30 × 33 = 4 950 €
> - Plafond colis : 5 × 1 000 = 5 000 €
> - Plafond retenu : **4 950 € (le moindre)**

### 1.3 Calcul CMR (DTS)

Le **DTS** (Droit de Tirage Spécial du FMI) varie quotidiennement. En 2026, **1 DTS ≈ 1,30 €** (à vérifier à la date du sinistre).

| Calcul | Détail |
|---|---|
| Plafond CMR par kg | 8,33 × 1,30 ≈ 10,80 € |
| Sur 1 000 kg perdus | 8 330 DTS = ~ 10 800 € |

### 1.4 Indemnisation au-delà des plafonds

3 voies pour dépasser le plafond légal :

| Voie | Conditions |
|---|---|
| **Déclaration de valeur** | Mention CMR + supplément payé |
| **Intérêt spécial à la livraison** | Pour le retard, montant fixé contractuellement |
| **Faute lourde / dol** | À prouver par le demandeur |

---

## 2. Les frais accessoires indemnisables

### 2.1 Frais nécessaires

Au-delà de l'indemnisation principale, le transporteur doit en principe rembourser :

| Frais | Détail |
|---|---|
| **Prix du transport** | Restitué proportionnellement à la perte |
| **Droits de douane** | Si déjà payés sur la marchandise perdue |
| **Frais d'expertise contradictoire** | Si elle conclut à la responsabilité du transporteur |
| **Frais de constatation** | Procès-verbal officiel, photos, etc. |

### 2.2 Frais NON indemnisables (sauf clause spéciale)

| Frais exclus | Raison |
|---|---|
| **Manque à gagner** du destinataire | Préjudice indirect |
| **Pénalités vis-à-vis de tiers** | Hors champ |
| **Coûts de remplacement urgent** | Au-delà de la valeur |
| **Préjudice d'image** | Non chiffrable juridiquement |

> 💡 **Exception : intérêt spécial à la livraison**
>
> Si l'expéditeur a fixé un intérêt spécial à la livraison (CMR art. 26 ou clause nationale), il peut récupérer un **préjudice étendu** (jusqu'à la valeur de l'intérêt spécial), même au-delà du prix du transport.

---

## 3. Les délais de prescription

### 3.1 Principes

La **prescription** est le délai au-delà duquel une action en justice n'est plus possible. Une fois prescrit, le client ne peut plus réclamer même si sa demande est légitime.

### 3.2 Délais selon régime

| Régime | Délai standard | Cas dol/faute lourde |
|---|---|---|
| National (Code commerce L. 133-6) | **1 an** | 5 ans (prescription civile générale) |
| CMR international | **1 an** | **3 ans** |
| Contrats spécifiques (déménagement, etc.) | Selon contrat-type |
| Frais de transport (impayés) | 1 an |

### 3.3 Point de départ

| Type d'action | Point de départ |
|---|---|
| Avarie ou perte partielle | Date de livraison |
| Perte totale | 30 jours après le délai convenu (national), 60 jours après prise en charge (CMR) |
| Retard | Date de livraison |
| Frais (action transporteur) | Date d'émission de la facture |

### 3.4 Interruption et suspension

La prescription peut être **interrompue** (le délai repart à zéro) par :
- **Reconnaissance** écrite de la dette par le débiteur
- **Acte de poursuite** (mise en demeure formelle, citation en justice)
- **Réclamation écrite** notifiée au transporteur (CMR art. 32 §2)

> 📌 **Important CMR**
>
> En CMR, une réclamation écrite suspend la prescription jusqu'à la réponse du transporteur. Cette particularité (différente du droit national) doit être maîtrisée.

---

## 4. Cas pratique : calcul d'indemnisation

**Contexte** : Litige sur perte totale d'une expédition Lyon → Hambourg (CMR).
- Marchandise : 350 cartons de chaussures, valeur déclarée à la facture 84 000 €
- Poids brut : 1 800 kg
- Aucune déclaration de valeur sur la CMR (case vide)
- Cause : vol sur aire de stationnement, après plus de 3 h sans surveillance

### Calcul indemnisation de base

```
Plafond CMR : 1 800 kg × 8,33 DTS/kg = 14 994 DTS
Conversion : 14 994 × 1,30 €/DTS ≈ 19 492 €
```

L'indemnisation de base est de ~ **19 492 €**, soit 23 % de la valeur réelle.

### Faute lourde possible ?

Le stationnement plus de 3 h sans surveillance avec des marchandises de valeur peut être qualifié de faute lourde au sens de l'article 29 CMR.

Conditions à prouver :
- Connaissance de la marchandise de valeur (oui : valeur sur facture 84 000 €)
- Stationnement non sécurisé (à vérifier : zone connue, alternatives disponibles)
- Désactivation antivol GPS éventuelle (à vérifier données télématique)
- Procédure de l'entreprise non respectée

**Si faute lourde reconnue** : indemnisation intégrale = 84 000 €

### Stratégie

| Pour le client | Pour le transporteur |
|---|---|
| Plaider la faute lourde art. 29 CMR | Démontrer la diligence du conducteur (pause obligatoire R561, alternatives non disponibles) |
| Chiffrer la valeur réelle (facture, douanes) | Limiter l'indemnité au plafond CMR |
| Prescription 3 ans si faute lourde reconnue | Prescription 1 an sinon |

### Recommandations préventives

1. **Toujours faire compléter la déclaration de valeur CMR** en présence de marchandises > 20 000 €
2. **Politique stationnement** documentée : seules les aires sécurisées (CTPark, parkings TOP-IRU) autorisées la nuit
3. **Antivol GPS** systématiquement actif et tracé
4. **Assurance RC marchandises** étendue au-delà des 8,33 DTS/kg
5. **Procédure interne** signée par chaque conducteur

---

## 5. Synthèse des plafonds par cas

| Cas | Régime | Indemnité plafond |
|---|---|---|
| Avarie 200 kg colis 8 t (national) | Contrat-type | 200 × 33 = 6 600 € |
| Perte 50 colis 1 200 kg (national) | Contrat-type | min(50 × 1 000, 1 200 × 33) = 39 600 € |
| Avarie 100 kg international UE | CMR | 100 × 8,33 × 1,30 ≈ 1 083 € |
| Retard livraison J+5 (CMR, prix 850 €) | CMR | 850 € (= prix transport) |
| Marchandise volée avec antivol désactivé | Faute lourde CMR | Valeur réelle (intégrale) |
| Avarie après réserve forme par destinataire à J+8 | Prescription dépassée (3 j) | Aucune indemnité |

---

> ✅ **À retenir**
>
> - National : **33 €/kg OU 1 000 €/colis** (le moindre).
> - CMR : **8,33 DTS/kg** (~ 10,80 € en 2026).
> - Retard : limité au **prix du transport** (sauf intérêt spécial).
> - Frais accessoires : prix transport, droits de douane, expertise.
> - Prescription : **1 an** (national + CMR), **3 ans** (CMR + faute lourde), **5 ans** (national + dol).
$lesson2$,
'Plafonds par régime (33 €/kg, 8,33 DTS/kg), règle du moindre des deux, frais accessoires, prescriptions (1 an / 3 ans / 5 ans), interruption par réclamation écrite.'
  ) RETURNING id INTO v_lesson_2;

  -- =================================================================
  -- LEÇON 3 — Gestion amiable des sinistres
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Gérer une réclamation amiable',
    'gotrm-bc01-09-03-gestion-amiable', 3, 45,
$lesson3$
# Gérer une réclamation amiable

90 % des litiges transport se règlent à l'amiable. La qualité de la gestion **amiable** détermine si on perd un client ou si on le fidélise après l'incident. C'est une compétence métier centrale.

> 🎯 **Objectifs de la leçon**
>
> - Maîtriser la **procédure** de gestion d'une réclamation.
> - Construire un **dossier** de défense solide.
> - Mener une **expertise contradictoire**.
> - Négocier une **transaction** équilibrée.

---

## 1. La procédure de réception

### 1.1 Les 4 premières heures

| Action | Responsable |
|---|---|
| Accuser réception écrite (mail, courrier) | Service client |
| Identifier le numéro de mission concerné | Service client |
| Envoyer un référent unique au client | Service client |
| Lancer la collecte initiale d'informations | Service client + exploitation |

> 📌 **Importance de l'accusé de réception**
>
> Sans accusé, le client se sent ignoré. Avec un accusé sous 4 h ouvrées + un nom de référent, il a la preuve de la prise en compte.

### 1.2 La collecte des éléments

| Élément | Source |
|---|---|
| CMR / lettre de voiture signée | Archives |
| Photos chargement / déchargement | Conducteur, télématique |
| Données tachygraphe | Téléchargement |
| Tracking GPS heure par heure | Télématique |
| Témoignage conducteur écrit | Conducteur |
| Préalables : devis, contrat, CGT | Service commercial |

### 1.3 Délai de réponse cible

| Type de SLA | Délai de réponse |
|---|---|
| Standard | 24-48 h ouvrées |
| Exigeant | 4 h ouvrées |
| Excellent | < 2 h |

---

## 2. Construire le dossier de défense

### 2.1 Les 5 angles d'analyse

1. **Réception conforme** : la marchandise a-t-elle été prise en charge en bon état apparent ? (cf réserves au chargement)
2. **Exécution** : conditions du transport conformes (R561, chaîne du froid, ADR) ?
3. **Livraison** : remise effective, créneau respecté, signature ?
4. **Réserves destinataire** : émises dans les délais, précises ?
5. **Causes possibles d'exonération** : force majeure, faute du client, vice propre, instruction ?

### 2.2 La fiche dossier

Pour chaque litige, créer un **dossier structuré** :

```
DOSSIER LITIGE N° 2026-074
Date d'ouverture : 12 mai 2026
Référent : J. Dupont (service qualité)

1. IDENTIFICATION
- Client : [nom + référence interne]
- Mission : [n°, date, trajet]
- Marchandise : [nature, poids, valeur]
- CMR n° : [référence]

2. FAITS
- Description du sinistre par le client (copie courrier)
- Date et heure de la livraison
- Réserves émises (citation exacte)

3. ÉLÉMENTS COLLECTÉS
- Photos chargement (3) : OK
- Photos arrivée (4) : OK
- Tracking GPS : extrait joint
- Tachygraphe : extrait joint
- Témoignage conducteur : signé le [date]

4. ANALYSE JURIDIQUE
- Régime applicable : national / CMR
- Plafond légal : [calcul]
- Causes d'exonération possibles : [liste]
- Position préliminaire : responsabilité / exonération / partage

5. PROPOSITION
- Indemnisation : [montant ou refus motivé]
- Échéance : [date]

6. SUITES
- Si désaccord : expertise, médiation, judiciaire
```

---

## 3. L'expertise contradictoire

### 3.1 Quand la solliciter ?

L'expertise est utile quand :
- La nature exacte du dommage est contestée
- L'origine du dommage est incertaine
- Les montants sont importants (> 5 000 €)
- Les positions sont éloignées (refus / accusation)

### 3.2 Les 3 types d'expertise

| Type | Caractéristique |
|---|---|
| **Amiable** | Choix d'un expert d'un commun accord, partage des coûts |
| **Contradictoire d'assurance** | Chaque partie a son expert, conciliation |
| **Judiciaire** | Désigné par le tribunal, force exécutoire |

### 3.3 Choisir un expert

| Profil | Caractéristiques |
|---|---|
| Expert près des Cours d'appel | Crédibilité judiciaire forte |
| Expert spécialisé secteur (frigorifique, ADR, mécanique) | Compréhension technique |
| Expert d'assurance | Habitué aux dossiers transport |
| Cabinet indépendant | Neutralité, indépendance |

### 3.4 Coût indicatif

- Expertise simple : 1 500 - 3 000 € HT
- Expertise complexe : 5 000 - 15 000 € HT
- À répartir selon décision (accord, ou imputable au perdant en justice)

---

## 4. Négocier une transaction

### 4.1 Définition

La **transaction** (article 2044 Code civil) est un contrat par lequel les parties terminent une contestation née ou préviennent une contestation à naître, avec **concessions réciproques**.

### 4.2 Les principes

| Principe | Détail |
|---|---|
| **Concessions réciproques** | Les deux parties cèdent quelque chose |
| **Forme écrite obligatoire** | Lettre signée par les deux parties |
| **Force exécutoire** | Vaut décision de justice |
| **Non révision** | Sauf erreur, dol, violence |
| **Confidentialité** | Souvent prévue (clause expresse) |

### 4.3 Stratégie de négociation

| Étape | Action |
|---|---|
| 1. Évaluer | Calculer indemnisation maximale légale + risque procès |
| 2. Définir BATNA | Best Alternative To a Negotiated Agreement = ce qu'on fait si pas d'accord |
| 3. Première offre | Plus basse que cible (pour avoir marge négociation) |
| 4. Concessions progressives | Toujours en échange d'une concession adverse |
| 5. Conclusion | Lettre de transaction signée |

### 4.4 Exemple type

| Position initiale | Cible | Position de repli |
|---|---|---|
| Refus total (faute du client) | 30 % de la demande | 50 % de la demande |
| 1 000 € (refus partiel) | 3 000 € | 5 000 € |
| Demande client 8 500 € | Transaction à 3 000-4 000 € | — |

> 💡 **Astuce d'expérience**
>
> Une transaction réussie est celle où **chaque partie sort en pensant qu'elle a gagné un peu et perdu un peu**. Si une partie est triomphante et l'autre amère, le client ne reviendra pas.

---

## 5. La médiation

### 5.1 Quand y recourir ?

- Litige bloqué amiablement mais sans agressivité
- Volonté de préserver la relation commerciale
- Coût et délai d'un procès jugés disproportionnés

### 5.2 Médiateurs spécialisés transport

| Acteur | Mission |
|---|---|
| **Comité de protection des consommateurs** (B2C) | Pour les litiges grand public |
| **CCI** (Chambres de commerce) | Médiation B2B générale |
| **OTRE, FNTR, TLF** (organisations professionnelles) | Médiation sectorielle transport |
| **Médiateur des entreprises** (ministère Économie) | Litiges B2B impliquant grandes entreprises |

### 5.3 Procédure

1. Saisine commune par les 2 parties
2. Désignation d'un médiateur agréé
3. 1-3 réunions sur 2-4 mois
4. Procès-verbal d'accord (vaut transaction) ou de désaccord
5. Coût : ~ 2 000 - 5 000 € à partager

---

## 6. Cas pratique : gérer un litige bloqué

**Contexte** : Un client réclame 18 000 € pour 4 palettes endommagées (national). Vous estimez votre responsabilité limitée à 4 800 € (plafond légal). Le client refuse votre offre et menace d'aller en justice.

### Analyse

| Élément | Détail |
|---|---|
| Demande client | 18 000 € (= valeur estimée) |
| Plafond légal | 4 800 € (national, 33 €/kg ou moindre des deux) |
| Marge de manœuvre | 4 800 € à 7 000 € si dérapage justifié |
| Coût d'un procès | 8 000-15 000 € (avocat + expertise + temps) + risque |
| Durée procès | 18-30 mois |

### Stratégie de négociation

1. **Réaffirmer fermement** la position juridique (plafond légal)
2. **Reconnaître** le préjudice réel du client (oui, 18 000 € sont perdus, mais le plafond est légal)
3. **Proposer une transaction** :
   - Indemnité : 5 500 € (plafond + 15 % de geste commercial)
   - Avoir transport : -10 % sur les 6 prochaines factures
   - Engagement : amélioration des procédures de manutention
   - Confidentialité de l'accord
4. **Si refus** :
   - Proposer une médiation CCI
   - Sinon, prendre le risque procès en sachant que le tribunal appliquera le plafond légal (4 800 € a priori)

### Argumentaire au client

```
« Madame X, je comprends votre frustration : 18 000 € de marchandise
endommagée, c'est un préjudice réel.

Cependant, la loi française (Code de commerce, contrat-type général)
limite notre responsabilité à 4 800 € sur ce dossier. Sans déclaration
de valeur sur la CMR, ni faute lourde de notre part, c'est ce qu'un
tribunal accordera.

Plutôt qu'un procès qui durerait 2 ans et coûterait 10 000 € à chacun,
je vous propose :
- 5 500 € d'indemnisation immédiate (plafond + geste)
- Un avoir de 10 % sur vos 6 prochaines factures
- Une procédure renforcée à la prise en charge avec photos
  systématiques

Cet accord clôt le dossier et préserve notre collaboration. À l'avenir,
je vous suggère de toujours utiliser la déclaration de valeur sur la
CMR pour les expéditions de plus de 5 000 € : pour ~ 1 % de
supplément, vous êtes couvert intégralement.

Je reste à disposition pour valider cette proposition. »
```

### Suivi

- Si transaction signée : bouclage en 30 jours, communication interne, mise en œuvre des procédures.
- Si refus : passage en médiation CCI, ou défense judiciaire avec avocat spécialisé transport.
- Quoi qu'il en soit : analyse interne pour comprendre la cause profonde et l'éviter.

---

> ✅ **À retenir**
>
> - **Accusé de réception** sous 4 h, référent unique nommé.
> - **Dossier structuré** : faits, éléments, analyse juridique, proposition.
> - **Expertise contradictoire** pour les enjeux > 5 000 €.
> - **Transaction** = concessions réciproques, écrit, vaut décision de justice.
> - **Médiation** : alternative au procès, 2-4 mois, ~ 2-5 k€.
$lesson3$,
'Procédure réception (accusé sous 4 h), dossier de défense en 5 angles, expertise contradictoire, transaction (art. 2044 CC), médiation (CCI, organisations professionnelles).'
  ) RETURNING id INTO v_lesson_3;

  -- =================================================================
  -- LEÇON 4 — Procédure judiciaire et assurance
  -- =================================================================
  INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
  VALUES (
    v_module, 'Procédure judiciaire et rôle de l''assurance',
    'gotrm-bc01-09-04-judiciaire-assurance', 4, 45,
$lesson4$
# Procédure judiciaire et rôle de l'assurance

Quand l'amiable échoue, le contentieux s'ouvre. Comprendre les **juridictions compétentes**, les **délais** et le **rôle de l'assurance** est essentiel pour piloter un dossier sans subir.

> 🎯 **Objectifs de la leçon**
>
> - Identifier les **juridictions compétentes** en transport.
> - Comprendre la **procédure** civile / commerciale.
> - Maîtriser le rôle des **assurances** (RC professionnelle, RC marchandises).
> - Anticiper le **coût** d'un contentieux.

---

## 1. Les juridictions compétentes

### 1.1 Selon le statut des parties

| Type de partie | Juridiction |
|---|---|
| Deux commerçants (B2B) | **Tribunal de commerce** |
| Particulier / consommateur (B2C) | **Tribunal judiciaire** |
| Litige international > 10 000 € | Selon convention (CMR : tribunal du domicile défendeur ou lieu de prise en charge / livraison) |
| Petits litiges (< 10 000 €) | Procédure simplifiée à l'amiable préalable obligatoire |

### 1.2 Compétence territoriale

| Cas | Tribunal compétent |
|---|---|
| Domicile du défendeur | Principe général |
| Lieu de livraison | Si contrat de transport (option) |
| Lieu de prise en charge | Si contrat de transport (option) |
| Compétence imposée par les CGT | Si elle a été acceptée |

### 1.3 Compétence CMR (international)

L'article 31 §1 de la CMR donne 4 options :
- Domicile du défendeur
- Lieu de prise en charge de la marchandise
- Lieu de livraison
- Tribunal désigné par accord des parties

---

## 2. La procédure type B2B

### 2.1 Étapes principales

| Étape | Délai | Action |
|---|---|---|
| 1. Mise en demeure formelle | J+0 | Lettre RAR demandant paiement / indemnisation sous 30 j |
| 2. Recours médiation préalable | J+30 | Obligatoire pour litige < 5 000 € |
| 3. Assignation devant tribunal | J+60 | Acte d'huissier déposé au greffe |
| 4. Échanges écritures | M+3 à M+12 | Conclusions de chaque partie |
| 5. Audience de plaidoirie | M+12 à M+18 | Débats devant le juge |
| 6. Délibéré et jugement | M+1 à M+3 | Décision motivée |
| 7. Exécution ou appel | M+1 | Délai d'appel 1 mois |

**Total délai moyen tribunal de commerce** : 18 à 30 mois pour un litige standard.

### 2.2 Coûts

| Poste | Coût indicatif |
|---|---|
| Avocat (procédure 1ère instance) | 4 000 - 12 000 € HT |
| Huissier (assignation, signification) | 800 - 2 000 € HT |
| Expertise judiciaire (si ordonnée) | 3 000 - 10 000 € HT |
| Frais de greffe | ~ 100 € |
| **Total minimum** | **5 000 - 25 000 €** |

À cela s'ajoutent les coûts internes : temps des dirigeants et personnel, stress, image.

### 2.3 Article 700 (frais de procédure)

Le perdant peut être condamné à payer une somme au gagnant pour couvrir partiellement ses frais d'avocat. Typiquement 1 000-5 000 € selon enjeu et travail.

---

## 3. Les assurances du transporteur

### 3.1 La RC Professionnelle (RC Pro)

Couvre la **responsabilité civile** du transporteur dans le cadre du contrat de transport.

| Couverture | Détail |
|---|---|
| Avaries / pertes / retards | Selon plafonds légaux |
| Frais de défense | Avocat, expertise |
| Remboursement clients | Indemnisation sinistres |
| Plafond annuel | 1 à 5 M€ généralement |

> ⚠️ **Limites de la RC Pro**
>
> La RC Pro ne couvre **pas** :
> - Les **fautes lourdes ou dol** du transporteur
> - Les **dépassements de plafonds** sans déclaration de valeur
> - Les **manquements aux obligations** délibérées (sans-papiers, sans-licence)
> - Les **dommages immatériels purs** (manque à gagner, pénalités tiers)

### 3.2 La RC marchandises étendue

Pour couvrir au-delà des plafonds légaux, surtout pour les marchandises de valeur.

| Niveau | Couverture |
|---|---|
| Standard | Plafonds légaux (33 €/kg, 8,33 DTS/kg) |
| Étendue | Jusqu'à 100 000 € par sinistre |
| Premium | Jusqu'à 1 M€ par sinistre |
| All risks | Tous risques sauf exclusions limitées |

### 3.3 L'assurance flotte véhicules

Distincte de la RC Pro, couvre les véhicules eux-mêmes :
- Responsabilité circulation (obligatoire)
- Tous risques (optionnel)
- Vol, incendie, bris de glace
- Dommages aux remorques

### 3.4 Autres assurances utiles

| Assurance | Mission |
|---|---|
| **Protection juridique** | Prise en charge des frais d'avocat |
| **Cyber-risque** | Données piratées, télématique compromise |
| **Pertes d'exploitation** | Si véhicule immobilisé longuement |
| **Responsabilité environnementale** | Fuite ADR, pollution |

---

## 4. La gestion d'un sinistre auprès de l'assureur

### 4.1 Déclaration

| Délai | Action |
|---|---|
| Sous 5 jours ouvrés | Déclaration formelle à l'assureur (RAR + dossier numérique) |
| Pièces obligatoires | CMR, photos, plainte (si vol), témoignages, devis réparation |

### 4.2 Procédure

1. Désignation d'un expert (par l'assureur ou contradictoire)
2. Évaluation du préjudice
3. Application des plafonds et franchises
4. Versement de l'indemnité (sous 30-60 j typiquement)

### 4.3 Franchise

Le **transporteur conserve une part** du sinistre à sa charge :
- Franchise classique : 1 000 - 5 000 € par sinistre
- Franchise plus élevée = prime moins chère
- Stratégie : choisir une franchise compatible avec sa trésorerie

### 4.4 Subrogation

Une fois indemnisé, l'assureur **se substitue** au transporteur pour récupérer le montant auprès du véritable responsable (sous-traitant, voleur identifié, etc.).

---

## 5. Cas pratique : gestion d'un sinistre vol

**Contexte** : Vol de 22 t de matériel high-tech (valeur 150 000 €) sur aire d'autoroute en Espagne. Trajet sous CMR.

### Actions immédiates

#### J0 (jour du vol)

1. **Sur place** :
   - Conducteur dépose plainte auprès des autorités locales
   - Photos du véhicule, de l'aire, des dégâts éventuels
   - Témoignages d'autres conducteurs présents
2. **Côté entreprise** :
   - Information immédiate du client expéditeur
   - Bloquer la marchandise dans les bases (numéros de série)
   - Activer alerte télématique sur les éventuels modules GPS embarqués

#### J+1 à J+5

3. **Déclaration assurance** :
   - Formulaire de sinistre à l'assureur RC Pro et RC marchandises
   - Joindre : plainte, CMR, photos, factures du chargeur, antécédents de l'aire (si zone connue à risque)
4. **Information autorités** :
   - Déclaration à la police française (si retour en France)
   - Information préfecture (signalisation grands sinistres)

#### J+5 à J+30

5. **Expertise contradictoire** :
   - Expert assureur + expert client convergent (ou divergent)
   - Évaluation du préjudice indemnisable
6. **Position juridique** :
   - Plafond CMR sans déclaration : 22 000 kg × 8,33 DTS = 183 260 DTS ≈ 238 000 € → couvre la valeur déclarée
   - Si déclaration de valeur sur CMR : indemnisation à 150 000 € (valeur déclarée + supplément)
   - Argument client : faute lourde du transporteur (stationnement non sécurisé) → indemnisation intégrale

### Analyse de la faute lourde

| Élément à examiner | Conséquence |
|---|---|
| L'aire choisie était-elle sécurisée (TOP-IRU, CTPark) ? | Si non, faute lourde possible |
| Antivol GPS activé ? | Si non, faute lourde renforcée |
| Pause R561 obligatoire à ce moment ? | Si oui, exonération renforcée |
| Procédure interne respectée ? | Si oui, défense solide |

### Stratégies possibles

#### Stratégie 1 — Plafond CMR

- Indemnisation : 150 000 € (couverte par CMR sans dépassement)
- Procès rapide en cas de désaccord
- Préserve la relation commerciale

#### Stratégie 2 — Faute lourde admise

- Indemnisation intégrale par le transporteur (au-delà du plafond CMR)
- Couverture par RC marchandises étendue (si présente)
- Risque pour la prime d'assurance future

#### Stratégie 3 — Recours subrogatoire

- Assureur paie le client
- Assureur se subroge contre les voleurs (peu efficace en pratique) et contre les sous-traitants éventuels (si chaîne)

### Mesures correctives ultérieures

1. **Politique aires de stationnement** : seules les aires TOP-IRU autorisées la nuit
2. **Antivol GPS systématique** sur tout chargement > 30 000 €
3. **Briefing conducteurs** : procédures de sécurité, stationnement, équilibre vie pro / sécurité
4. **Audit assurance** : couverture suffisante pour les marchandises de valeur typiques ?
5. **Demande systématique de déclaration de valeur** sur CMR pour expéditions sensibles

---

> ✅ **À retenir**
>
> - **Tribunal de commerce** pour B2B, **TJ** pour B2C, **CMR art. 31** pour international.
> - Procédure 1ère instance : **18 à 30 mois**, coût avocat + huissier + expertise = **5 à 25 k€**.
> - **RC Pro** = couverture standard, **RC marchandises étendue** = au-delà des plafonds.
> - **Faute lourde / dol** : plafond saute, RC peut refuser la garantie.
> - **Subrogation** : l'assureur paie, puis se retourne contre le vrai responsable.
$lesson4$,
'Juridictions (TC B2B, TJ B2C, CMR art. 31), procédure 18-30 mois, RC Pro vs RC marchandises étendue, gestion sinistre, franchise, subrogation.'
  ) RETURNING id INTO v_lesson_4;

  -- =================================================================
  -- 28 QCM
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qcm', 'L''article L. 133-1 du Code de commerce établit que le transporteur :', '[{"id":"a","label":"Est libre de toute responsabilité","is_correct":false},{"id":"b","label":"A une obligation de moyens","is_correct":false},{"id":"c","label":"A une obligation de résultat (présomption de responsabilité)","is_correct":true},{"id":"d","label":"N''est responsable que sur preuve de faute par le client","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['responsabilite','L133-1'], 'mft-2026-gotrm:bc01-09:qcm:1', true, 'L. 133-1 : "Le voiturier est garant de la perte des objets à transporter, hors les cas de force majeure". Obligation de résultat = présomption de responsabilité. C''est au transporteur de prouver une cause d''exonération.'),
  (v_formation, 'qcm', 'Les 3 critères cumulatifs de la force majeure sont :', '[{"id":"a","label":"Public, médiatisé, validé par préfecture","is_correct":false},{"id":"b","label":"Extérieur, imprévisible, irrésistible","is_correct":true},{"id":"c","label":"Soudain, grave, exceptionnel","is_correct":false},{"id":"d","label":"Reconnu, documenté, attesté","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['force-majeure'], 'mft-2026-gotrm:bc01-09:qcm:2', true, 'Force majeure = événement extérieur (pas lié à l''activité), imprévisible (anticipation impossible), irrésistible (conséquences inévitables). Critères cumulatifs interprétés strictement par les juges.'),
  (v_formation, 'qcm', 'Une panne mécanique du véhicule est-elle un cas de force majeure ?', '[{"id":"a","label":"Oui, par principe","is_correct":false},{"id":"b","label":"Non, c''est un risque inhérent à l''activité du transporteur","is_correct":true},{"id":"c","label":"Oui si récente","is_correct":false},{"id":"d","label":"Oui si véhicule en bon état général","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['force-majeure','panne'], 'mft-2026-gotrm:bc01-09:qcm:3', true, 'Une panne mécanique n''est pas extérieure à l''activité du transporteur (entretien et bon état du parc lui incombent). Elle peut atténuer (en cas de retard) mais pas exonérer.'),
  (v_formation, 'qcm', 'Le plafond d''indemnisation national pour avarie/perte est de :', '[{"id":"a","label":"33 €/kg ou 1 000 €/colis (le moindre des deux)","is_correct":true},{"id":"b","label":"100 €/kg uniformément","is_correct":false},{"id":"c","label":"500 €/kg ou 5 000 €/colis","is_correct":false},{"id":"d","label":"Aucun plafond","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['plafond','national'], 'mft-2026-gotrm:bc01-09:qcm:4', true, 'Contrat-type général (décret 99-269 art. 21) : plafond de 33 €/kg OU 1 000 €/colis, le plus faible des deux étant retenu. À distinguer du plafond CMR (8,33 DTS/kg).'),
  (v_formation, 'qcm', 'Le plafond CMR international est de :', '[{"id":"a","label":"33 €/kg","is_correct":false},{"id":"b","label":"8,33 DTS/kg (~ 10,80 €/kg)","is_correct":true},{"id":"c","label":"100 DTS/kg","is_correct":false},{"id":"d","label":"1 000 € par expédition","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['plafond','cmr'], 'mft-2026-gotrm:bc01-09:qcm:5', true, 'Article 23 §3 CMR : 8,33 DTS/kg de marchandise manquante ou avariée. En 2026, 1 DTS ≈ 1,30 € soit ~ 10,80 €/kg. Le DTS varie quotidiennement.'),
  (v_formation, 'qcm', 'L''indemnisation pour retard est généralement plafonnée à :', '[{"id":"a","label":"100 % du prix du transport","is_correct":false},{"id":"b","label":"50 % du prix de la marchandise","is_correct":false},{"id":"c","label":"Le prix du transport (sauf intérêt spécial à la livraison)","is_correct":true},{"id":"d","label":"Aucun plafond","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['retard','plafond'], 'mft-2026-gotrm:bc01-09:qcm:6', true, 'Pour le retard, l''indemnité est limitée au prix du transport (sauf déclaration d''intérêt spécial à la livraison qui peut élargir). Cela vaut tant en national qu''en CMR.'),
  (v_formation, 'qcm', 'Pour 200 kg de marchandise endommagée en transport national (10 colis de 20 kg), le plafond d''indemnisation est :', '[{"id":"a","label":"6 600 €","is_correct":true},{"id":"b","label":"10 000 €","is_correct":false},{"id":"c","label":"33 €/kg sans limite","is_correct":false},{"id":"d","label":"500 €/colis fixé","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['plafond','calcul'], 'mft-2026-gotrm:bc01-09:qcm:7', true, 'Calcul : poids = 200 × 33 = 6 600 € ; colis = 10 × 1 000 = 10 000 €. Le moindre des deux est 6 600 €. C''est le plafond légal applicable.'),
  (v_formation, 'qcm', 'En cas de faute lourde ou de dol du transporteur :', '[{"id":"a","label":"Les plafonds restent applicables","is_correct":false},{"id":"b","label":"Les plafonds sautent et l''indemnisation devient intégrale","is_correct":true},{"id":"c","label":"Le transport est annulé","is_correct":false},{"id":"d","label":"Le client perd toute indemnisation","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['faute-lourde','article-29'], 'mft-2026-gotrm:bc01-09:qcm:8', true, 'Faute lourde / dol (CMR art. 29, jurisprudence française) = les plafonds légaux et contractuels sautent. Indemnisation intégrale = valeur réelle du préjudice. Prescription passe à 3 ans (CMR) ou 5 ans (national).'),
  (v_formation, 'qcm', 'La déclaration de valeur sur la lettre de voiture permet :', '[{"id":"a","label":"De réduire le prix du transport","is_correct":false},{"id":"b","label":"D''augmenter le plafond d''indemnisation au-delà du plafond légal moyennant supplément","is_correct":true},{"id":"c","label":"D''éviter les douanes","is_correct":false},{"id":"d","label":"De renoncer aux délais de réserves","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['declaration-valeur'], 'mft-2026-gotrm:bc01-09:qcm:9', true, 'Déclaration de valeur (art. 24 CMR ou clause nationale) : permet, contre supplément (~ 0,5 à 2 % de la valeur), de fixer un plafond supérieur. Doit figurer expressément sur la CMR/LV.'),
  (v_formation, 'qcm', 'Le délai de prescription d''une action contre le transporteur (régime national standard) est de :', '[{"id":"a","label":"6 mois","is_correct":false},{"id":"b","label":"1 an","is_correct":true},{"id":"c","label":"3 ans","is_correct":false},{"id":"d","label":"5 ans","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['prescription','national'], 'mft-2026-gotrm:bc01-09:qcm:10', true, 'Article L. 133-6 du Code de commerce : prescription de 1 an pour les actions liées au transport. Passe à 5 ans en cas de dol prouvé. À ne pas confondre avec la prescription civile générale.'),
  (v_formation, 'qcm', 'Le délai de prescription d''une action sous CMR avec faute lourde est de :', '[{"id":"a","label":"6 mois","is_correct":false},{"id":"b","label":"1 an","is_correct":false},{"id":"c","label":"3 ans","is_correct":true},{"id":"d","label":"10 ans","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['cmr','prescription','faute-lourde'], 'mft-2026-gotrm:bc01-09:qcm:11', true, 'Article 32 CMR : 1 an de prescription standard, 3 ans en cas de dol ou de faute considérée comme équivalente par le droit applicable. À distinguer du droit national (5 ans en cas de dol).'),
  (v_formation, 'qcm', 'En CMR, une réclamation écrite envoyée au transporteur :', '[{"id":"a","label":"Court la prescription","is_correct":false},{"id":"b","label":"Suspend la prescription jusqu''à la réponse du transporteur","is_correct":true},{"id":"c","label":"Annule la prescription","is_correct":false},{"id":"d","label":"N''a aucun effet","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['cmr','prescription','suspension'], 'mft-2026-gotrm:bc01-09:qcm:12', true, 'Art. 32 §2 CMR : la réclamation écrite suspend la prescription jusqu''à la réponse du transporteur. Le client peut donc préserver ses droits en envoyant simplement une lettre RAR avant le délai d''un an.'),
  (v_formation, 'qcm', 'Le délai pour formuler une réserve sur une avarie non apparente en transport national est de :', '[{"id":"a","label":"24 heures","is_correct":false},{"id":"b","label":"3 jours ouvrés","is_correct":true},{"id":"c","label":"7 jours ouvrés","is_correct":false},{"id":"d","label":"30 jours","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['reserves','national'], 'mft-2026-gotrm:bc01-09:qcm:13', true, '3 jours ouvrés en transport national pour les avaries non apparentes. À distinguer du CMR (7 jours). Au-delà, la marchandise est présumée livrée conforme.'),
  (v_formation, 'qcm', 'Le délai pour formuler une réserve sur une avarie non apparente en CMR est de :', '[{"id":"a","label":"3 jours","is_correct":false},{"id":"b","label":"7 jours ouvrés","is_correct":true},{"id":"c","label":"21 jours","is_correct":false},{"id":"d","label":"30 jours","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['cmr','reserves'], 'mft-2026-gotrm:bc01-09:qcm:14', true, 'Article 30 §1 CMR : 7 jours ouvrés pour les avaries non apparentes. 21 jours pour le retard. 30 jours après le délai convenu pour la perte présumée (ou 60 jours après prise en charge).'),
  (v_formation, 'qcm', 'Une réserve « sous réserve de déballage » est :', '[{"id":"a","label":"Toujours valable","is_correct":false},{"id":"b","label":"Souvent jugée trop vague et inopposable au transporteur","is_correct":true},{"id":"c","label":"Valable seulement sur les denrées","is_correct":false},{"id":"d","label":"Valable si signée d''un huissier","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['reserves','validite'], 'mft-2026-gotrm:bc01-09:qcm:15', true, 'Une réserve générique sans description précise de l''anomalie (« sous réserve de déballage », « sous réserve d''inventaire ») est régulièrement écartée par les tribunaux. Préférer : « Carton n° X, dim. Y, enfoncé sur la face Z, traces d''humidité ».'),
  (v_formation, 'qcm', 'Le tribunal compétent en cas de litige entre 2 commerçants est :', '[{"id":"a","label":"Tribunal judiciaire (TJ)","is_correct":false},{"id":"b","label":"Tribunal de commerce","is_correct":true},{"id":"c","label":"Conseil des prud''hommes","is_correct":false},{"id":"d","label":"Cour administrative d''appel","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['juridiction','B2B'], 'mft-2026-gotrm:bc01-09:qcm:16', true, 'B2B = Tribunal de commerce. B2C (consommateur) = Tribunal judiciaire. Prud''hommes = litiges salariés/employeurs. Administrative = relations avec puissance publique.'),
  (v_formation, 'qcm', 'L''article 31 CMR prévoit que pour un litige international, le tribunal compétent peut être :', '[{"id":"a","label":"Uniquement celui du domicile du transporteur","is_correct":false},{"id":"b","label":"Uniquement celui du destinataire","is_correct":false},{"id":"c","label":"Domicile défendeur, lieu de prise en charge ou lieu de livraison","is_correct":true},{"id":"d","label":"Le tribunal de l''État émetteur de la CMR uniquement","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['cmr','article-31'], 'mft-2026-gotrm:bc01-09:qcm:17', true, 'Article 31 §1 CMR : 4 options de tribunal compétent : domicile du défendeur, lieu de prise en charge, lieu de livraison, ou tribunal désigné par accord des parties. Le demandeur choisit.'),
  (v_formation, 'qcm', 'La durée moyenne d''un procès en première instance au tribunal de commerce est de :', '[{"id":"a","label":"3-6 mois","is_correct":false},{"id":"b","label":"6-12 mois","is_correct":false},{"id":"c","label":"18-30 mois","is_correct":true},{"id":"d","label":"5 ans","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['procedure','duree'], 'mft-2026-gotrm:bc01-09:qcm:18', true, 'Procédure standard tribunal de commerce : 18-30 mois (échanges d''écritures, expertise éventuelle, audience, délibéré). À cela peut s''ajouter un appel (12-18 mois supplémentaires).'),
  (v_formation, 'qcm', 'Le coût moyen d''un avocat pour une procédure de 1ère instance en transport est de :', '[{"id":"a","label":"500-1 000 € HT","is_correct":false},{"id":"b","label":"4 000-12 000 € HT","is_correct":true},{"id":"c","label":"50 000-100 000 € HT","is_correct":false},{"id":"d","label":"Toujours gratuit","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['avocat','cout'], 'mft-2026-gotrm:bc01-09:qcm:19', true, 'Coût avocat 1ère instance pour litige transport : 4 000-12 000 € HT selon complexité. À cela s''ajoutent huissier (800-2 000 €), expertise judiciaire éventuelle (3-10 k€), greffe (~ 100 €).'),
  (v_formation, 'qcm', 'La RC Pro (Responsabilité Civile Professionnelle) du transporteur :', '[{"id":"a","label":"Couvre toujours les fautes lourdes","is_correct":false},{"id":"b","label":"Couvre les avaries/pertes/retards dans les plafonds légaux + frais de défense","is_correct":true},{"id":"c","label":"Remplace les plafonds légaux","is_correct":false},{"id":"d","label":"Est facultative","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['rc-pro','couverture'], 'mft-2026-gotrm:bc01-09:qcm:20', true, 'RC Pro couvre la responsabilité contractuelle (avaries, pertes, retards) dans les plafonds légaux + frais de défense (avocat, expertise). Elle ne couvre PAS les fautes lourdes ou le dol du transporteur.'),
  (v_formation, 'qcm', 'La RC marchandises étendue est utile :', '[{"id":"a","label":"Pour les transports en zone rurale","is_correct":false},{"id":"b","label":"Pour couvrir au-delà des plafonds légaux (marchandises de valeur)","is_correct":true},{"id":"c","label":"Pour remplacer la RC Pro","is_correct":false},{"id":"d","label":"Uniquement pour les transports internationaux","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['rc-marchandises','etendue'], 'mft-2026-gotrm:bc01-09:qcm:21', true, 'RC marchandises étendue couvre au-delà des plafonds légaux (jusqu''à 100 000 € à 1 M€ ou plus). Indispensable pour les marchandises de valeur (high-tech, parfumerie, vins fins) où les plafonds légaux sont insuffisants.'),
  (v_formation, 'qcm', 'Une transaction (article 2044 Code civil) :', '[{"id":"a","label":"Est un simple accord verbal","is_correct":false},{"id":"b","label":"Implique des concessions réciproques, doit être écrite, et vaut décision de justice","is_correct":true},{"id":"c","label":"Peut être annulée à tout moment","is_correct":false},{"id":"d","label":"Ne nécessite pas de signature","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['transaction','2044'], 'mft-2026-gotrm:bc01-09:qcm:22', true, 'Article 2044 CC : la transaction met fin ou prévient un litige par concessions réciproques. Forme écrite obligatoire, force exécutoire (vaut décision de justice), non révision sauf erreur, dol, violence.'),
  (v_formation, 'qcm', 'La subrogation en assurance signifie :', '[{"id":"a","label":"L''assurance refuse le sinistre","is_correct":false},{"id":"b","label":"L''assureur paie l''assuré, puis se substitue à lui pour récupérer l''argent du vrai responsable","is_correct":true},{"id":"c","label":"L''assuré paie sa franchise","is_correct":false},{"id":"d","label":"L''assurance est annulée","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['subrogation','assurance'], 'mft-2026-gotrm:bc01-09:qcm:23', true, 'Subrogation : l''assureur indemnise l''assuré, puis exerce les droits de l''assuré contre le tiers responsable (vol identifié, sous-traitant, etc.). Permet de minimiser le coût final pour l''assureur.'),
  (v_formation, 'qcm', 'En cas de vol d''une marchandise CMR sous prétexte de pause R561, l''argument de défense le plus solide est :', '[{"id":"a","label":"Aucun, on est forcément responsable","is_correct":false},{"id":"b","label":"Démontrer la diligence : aire sécurisée, antivol activé, procédure interne respectée","is_correct":true},{"id":"c","label":"Prouver que la marchandise valait peu","is_correct":false},{"id":"d","label":"Plaider l''ignorance","is_correct":false}]'::jsonb, 1, 'difficile', ARRAY['vol','defense','diligence'], 'mft-2026-gotrm:bc01-09:qcm:24', true, 'Pour s''exonérer de la faute lourde, il faut démontrer la diligence : aire sécurisée (TOP-IRU, CTPark), antivol GPS activé, procédure interne suivie, pause R561 imposée par la loi. Les éléments matériels sont déterminants.'),
  (v_formation, 'qcm', 'La franchise dans une assurance transport est :', '[{"id":"a","label":"Le montant maximum couvert","is_correct":false},{"id":"b","label":"La part du sinistre que le transporteur conserve à sa charge","is_correct":true},{"id":"c","label":"Le délai de prescription","is_correct":false},{"id":"d","label":"Le coût de la souscription","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['franchise','assurance'], 'mft-2026-gotrm:bc01-09:qcm:25', true, 'Franchise = part du sinistre à la charge de l''assuré. Typiquement 1 000 - 5 000 € par sinistre transport. Plus la franchise est élevée, moins la prime est chère.'),
  (v_formation, 'qcm', 'Une réserve est dite « apparente » si :', '[{"id":"a","label":"Elle est visible immédiatement au déchargement (carton enfoncé, palette mouillée)","is_correct":true},{"id":"b","label":"Elle est documentée par expert","is_correct":false},{"id":"c","label":"Elle est validée par la direction","is_correct":false},{"id":"d","label":"Elle est jointe au CMR","is_correct":false}]'::jsonb, 1, 'facile', ARRAY['reserves','apparente'], 'mft-2026-gotrm:bc01-09:qcm:26', true, 'Réserve apparente = anomalie visible immédiatement à la livraison (sans déballage). Elle doit être mentionnée le jour même sur le BL ou la CMR pour être valable. À distinguer des réserves non apparentes (3 j national, 7 j CMR).'),
  (v_formation, 'qcm', 'Un client réclame 50 000 € sur un sinistre limité à 6 000 € par le plafond légal. La meilleure stratégie est généralement :', '[{"id":"a","label":"Accepter pour préserver la relation","is_correct":false},{"id":"b","label":"Refuser sèchement et attendre le procès","is_correct":false},{"id":"c","label":"Proposer une transaction au plafond + un geste commercial (ex : 7 500 €) pour clore","is_correct":true},{"id":"d","label":"Proposer 50 000 € en avoir transport","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['transaction','strategie'], 'mft-2026-gotrm:bc01-09:qcm:27', true, 'Stratégie équilibrée : transaction au plafond légal + 15-25 % de geste commercial, en échange d''abandon de toute autre réclamation et confidentialité. Évite un procès long et coûteux, préserve la relation.'),
  (v_formation, 'qcm', 'Le dol en droit du transport désigne :', '[{"id":"a","label":"Une faute légère","is_correct":false},{"id":"b","label":"Une faute intentionnelle (ex : vol par le conducteur, falsification documents)","is_correct":true},{"id":"c","label":"Une simple négligence","is_correct":false},{"id":"d","label":"Un cas de force majeure","is_correct":false}]'::jsonb, 1, 'moyen', ARRAY['dol','definition'], 'mft-2026-gotrm:bc01-09:qcm:28', true, 'Dol = faute intentionnelle. Distinct de la faute lourde (négligence si grave qu''elle équivaut au dol). Tous deux font sauter les plafonds d''indemnisation et la couverture RC Pro.');


  -- =================================================================
  -- 5 QR
  -- =================================================================
  INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, 'qr', 'Calculez l''indemnité maximale légale pour les sinistres suivants et identifiez le régime applicable :
a) Avarie de 8 palettes (poids unitaire 350 kg) sur trajet Lille-Marseille
b) Perte totale de 2 t en transport Lyon-Hambourg (CMR)
c) Retard de 3 jours sur une livraison express, prix transport 1 200 €
d) Vol de marchandises high-tech (1 200 kg, valeur 180 000 €) avec antivol GPS désactivé volontairement par le conducteur', NULL, 1, 'difficile', ARRAY['calcul','plafonds','cas-pratique'], 'mft-2026-gotrm:bc01-09:qr:1', true, 'Calculs détaillés :

a) Avarie 8 palettes 350 kg national :
- Régime : national (Lille-Marseille) → contrat-type général 99-269
- Plafond poids : 8 × 350 × 33 = 92 400 €
- Plafond colis : 8 × 1 000 = 8 000 €
- Le moindre des deux : 8 000 €
- INDEMNITÉ MAXIMALE : 8 000 €

Note : Si chaque palette contient 50 cartons, on peut argumenter que le « colis » est le carton (50 × 8 = 400 cartons × 1 000 = 400 000 €). Mais sauf clause contraire, c''est généralement le palette qui fait colis.

b) Perte totale 2 t CMR Lyon-Hambourg :
- Régime : CMR (international UE)
- Plafond : 2 000 kg × 8,33 DTS/kg = 16 660 DTS
- Conversion 2026 : 16 660 × 1,30 €/DTS ≈ 21 658 €
- INDEMNITÉ MAXIMALE : ~ 21 658 €

c) Retard 3 jours, prix transport 1 200 € :
- Régime : selon trajet (national ou CMR)
- Plafond retard : prix du transport (national art. 21 contrat-type, CMR art. 23 §5)
- INDEMNITÉ MAXIMALE : 1 200 €

Sauf si déclaration d''intérêt spécial à la livraison (CMR art. 26) qui peut élargir l''indemnité au-delà du prix du transport, jusqu''à la valeur de l''intérêt déclaré.

d) Vol 1 200 kg, antivol désactivé volontairement :
- Cas de FAUTE LOURDE (ou dol)
- Régime : CMR (probablement international vu la nature des marchandises)
- Calcul standard CMR : 1 200 × 8,33 × 1,30 ≈ 12 994 €
- MAIS faute lourde / dol article 29 CMR : LES PLAFONDS SAUTENT
- INDEMNITÉ MAXIMALE : 180 000 € (valeur réelle complète)

Conséquences additionnelles :
- Prescription : 3 ans au lieu d''1 an (CMR art. 32)
- RC Pro peut refuser la garantie (faute volontaire)
- Sanctions internes possibles contre le conducteur (responsabilité disciplinaire)
- Risque pénal éventuel si complicité de vol

Synthèse :

| Cas | Régime | Plafond | Indemnité max |
|-----|--------|---------|---------------|
| a | National | 33€/kg ou 1000€/colis | 8 000 € |
| b | CMR | 8,33 DTS/kg | 21 658 € |
| c | National/CMR retard | Prix transport | 1 200 € |
| d | CMR + faute lourde | Plafond saute | 180 000 € |

Recommandations :

1. Pour les marchandises de valeur (cas d : high-tech 180 k€) : exiger systématiquement déclaration de valeur sur CMR + assurance étendue.

2. Pour le retard : insérer une clause de pénalité forfaitaire de retard dans le contrat (10-15 % du prix transport / jour de retard) plutôt que de subir le plafond légal.

3. Pour le vol : politique stricte sur le stationnement (aires TOP-IRU uniquement la nuit), antivol GPS systématique avec contrôle aléatoire, sanctions internes en cas de désactivation.

4. Pour les avaries colis : photos systématiques avant/après chargement, réserves précises au déchargement.'),
  (v_formation, 'qr', 'Un client envoie une réclamation pour une avarie : 4 cartons écrasés sur 80 livrés. Il réclame 12 500 €. Vous estimez votre responsabilité limitée à 2 800 €. Décrivez votre stratégie de gestion en 5 étapes, incluant la rédaction de la lettre de réponse.', NULL, 1, 'difficile', ARRAY['strategie','gestion-litige','lettre'], 'mft-2026-gotrm:bc01-09:qr:2', true, 'Stratégie en 5 étapes :

ÉTAPE 1 — Accusé de réception et collecte (J+0 à J+1)

Action immédiate :
- Accusé de réception écrit (mail) sous 4 h : « Bonjour Monsieur X, je confirme la bonne réception de votre courrier du [date]. Mme/M. Y, responsable qualité, prend en charge votre dossier. Vous serez recontacté(e) sous 5 jours ouvrés avec notre position. »
- Désigner un référent unique pour ne pas multiplier les interlocuteurs

Collecte :
- CMR signée à la livraison (réserves émises ?)
- Photos chargement (côté expéditeur)
- Photos arrivée (côté destinataire si disponibles)
- Tracking GPS du véhicule, données tachygraphe
- Témoignage écrit du conducteur
- Devis chargeur, valeur facturée

ÉTAPE 2 — Analyse juridique (J+2 à J+5)

Évaluation :
- Régime applicable : national (a priori)
- Plafond légal :
  - Plafond poids : 4 cartons × poids unitaire × 33 €/kg
  - Plafond colis : 4 × 1 000 € = 4 000 €
  - Le moindre des deux
- Hypothèse calcul : 4 cartons × 21 kg × 33 € = 2 772 € (donc plafond ≈ 2 800 €, conforme à votre estimation)

Causes d''exonération possibles :
- Réserves au chargement par le conducteur (manutention chargeur, état emballage)
- Vice propre de la marchandise
- Faute du destinataire au déchargement

Vérifier la réserve à la livraison : signée dans les délais ? Description précise ?

ÉTAPE 3 — Position et proposition (J+5)

Position juridique : responsabilité plafonnée à 2 800 € maximum.

Proposition de transaction :
- Indemnité : 2 800 € (plafond légal)
- + Geste commercial : 15 % du plafond = 420 €, soit total 3 220 €
- OU avoir transport : -10 % sur les 5 prochaines factures
- Engagement : audit interne sur la cause profonde, communication sous 30 jours

ÉTAPE 4 — Lettre de réponse formelle (J+5)

```
[En-tête entreprise]
[Date]

OBJET : Réclamation n° [ref] - Mission n° [ref]
Recommandé avec accusé de réception

Madame/Monsieur,

Suite à votre courrier du [date] concernant l''avarie constatée
sur la livraison de [date], nous avons procédé à l''analyse
détaillée du dossier.

1. RAPPEL DES FAITS

[Brève chronologie objective de la mission, de la prise en charge
à la livraison, mention des réserves émises et des éléments
matériels collectés.]

2. POSITION JURIDIQUE

L''opération relevait du contrat-type général (décret 99-269 du
6 avril 1999, modifié). Conformément à son article 21,
l''indemnisation est plafonnée au moindre des deux montants
suivants : 33 €/kg de marchandise endommagée OU 1 000 €/colis.

Sur la base des éléments du dossier (4 cartons, poids unitaire
21 kg), le plafond légal s''établit à 2 800 €.

3. ÉLÉMENTS À PRENDRE EN COMPTE

[Mention des réserves au chargement / autres facteurs.]

4. PROPOSITION

Sans reconnaissance de responsabilité au-delà du cadre légal et
afin de maintenir notre relation commerciale dans les meilleures
conditions, nous vous proposons :

- Une indemnité globale de 3 220 €, comprenant le plafond légal
  (2 800 €) majoré d''un geste commercial (420 €).
- Cette proposition est exclusive de toute autre réclamation
  ultérieure sur ce dossier.
- Engagement de notre part : un audit interne sera diligenté pour
  prévenir la récurrence d''incidents similaires. Nous vous
  communiquerons les actions mises en œuvre sous 30 jours.

Cette proposition est valable 30 jours à compter de la présente.
Sans réponse de votre part dans ce délai, elle deviendra caduque.

Nous restons à votre disposition pour tout échange complémentaire.

Cordialement,
[Signature]
```

ÉTAPE 5 — Négociation et clôture (J+10 à J+45)

Si le client accepte :
- Rédaction d''une transaction écrite (article 2044 CC)
- Concessions réciproques mentionnées
- Clause de non-renouvellement de la réclamation
- Clause de confidentialité
- Signature des deux parties
- Versement de l''indemnité sous 10 jours

Si le client refuse :
- Marge de négociation : monter jusqu''à 4 200 € (50 % du geste)
- Au-delà : proposer médiation CCI
- Sinon : préparer dossier judiciaire (mais sachant que le tribunal appliquera le plafond légal de 2 800 €, avec frais et délais à anticiper)

Actions correctives en interne :

1. Réunion exploitation + qualité
2. Analyse des causes (5 pourquoi)
3. Plan d''action : briefing conducteurs, photos systématiques, réserves au chargement
4. Suivi mensuel des incidents similaires
5. Communication de l''engagement au client à J+30 (lettre de suivi avec actions menées)

Boucler la boucle : revenir vers le client à J+30 avec les actions concrètes prises = transformation possible d''un détracteur en client fidèle (paradoxe de la récupération).'),
  (v_formation, 'qr', 'Un de vos conducteurs a fait l''objet d''un vol de marchandises pour 80 000 €. Le client envisage de plaider la faute lourde. Listez les 8 éléments à examiner pour évaluer la solidité de cette qualification, et déterminez la stratégie défensive.', NULL, 1, 'difficile', ARRAY['vol','faute-lourde','strategie'], 'mft-2026-gotrm:bc01-09:qr:3', true, '8 éléments à examiner pour qualifier (ou non) la faute lourde :

1. NATURE DE L''AIRE DE STATIONNEMENT
- L''aire choisie était-elle sécurisée ?
- Aires reconnues : TOP-IRU, CTPark, parkings européens IRU certifiés
- Aire d''autoroute classique sans surveillance = présomption négative
- Conséquence : si le conducteur a choisi une aire sécurisée disponible, défense forte. Si une aire sécurisée existait à proximité raisonnable et n''a pas été choisie, faute lourde possible.

2. ÉTAT DES DISPOSITIFS ANTIVOL
- Antivol GPS activé pendant l''arrêt ?
- Vérification via télématique embarquée
- Si désactivé volontairement : présomption forte de faute lourde
- Si activé : élément de défense majeur

3. DURÉE DE L''ABSENCE DU CONDUCTEUR
- Repos R561 obligatoire (pause 45 min ou repos journalier 11 h) ?
- Si repos obligatoire : justification réglementaire, défense forte
- Si arrêt non justifié (course personnelle, repas prolongé) : faute lourde possible

4. RESPECT DE LA PROCÉDURE INTERNE
- L''entreprise a-t-elle une procédure stationnement / sécurité documentée ?
- Le conducteur l''a-t-il signée et reçue en formation ?
- Le respect strict de la procédure est un argument de défense majeur
- Le non-respect manifeste est une faute lourde

5. NATURE DE LA MARCHANDISE
- Le conducteur connaissait-il la valeur (~ 80 000 €) ?
- La marchandise était-elle particulièrement sensible (high-tech, parfumerie, vins) ?
- Les précautions devraient être proportionnées : pour 80 000 €, vigilance accrue exigée
- Si banalisation par le conducteur : faute lourde possible

6. ANTÉCÉDENTS DE L''AIRE / ZONE
- L''aire est-elle connue à risque (statistiques police, alertes IRU) ?
- Le conducteur en avait-il été averti ?
- Le choix d''une aire connue à risque sans précaution = faute lourde caractérisée

7. RÉACTION POST-VOL
- Le conducteur a-t-il alerté immédiatement (autorités, exploitation) ?
- Plainte déposée, photos, témoignages ?
- Une réaction professionnelle attenue le débat sur la faute (le conducteur n''est pas resté inactif)

8. ÉTAT DE FATIGUE / VIGILANCE
- Le conducteur respectait-il les temps de conduite et de repos ?
- Une infraction R561 antérieure peut être un facteur aggravant
- Si conformité totale aux temps : argument de diligence

Synthèse stratégique :

Cas favorables au transporteur (défense solide) :
- Aire sécurisée choisie quand disponible
- Antivol GPS activé, traçable
- Pause R561 obligatoire (forcée par la loi)
- Procédure interne strictement appliquée
- Réaction professionnelle post-vol
- Alerte de zone non transmise au conducteur

Cas défavorables au transporteur (faute lourde probable) :
- Aire à risque connu choisie sans nécessité
- Antivol désactivé volontairement
- Arrêt non justifié réglementairement
- Procédure interne violée délibérément
- Conducteur informé du risque et passé outre

Stratégie défensive proposée :

ÉTAPE 1 — Collecte exhaustive des éléments objectifs (J+1 à J+5)

- Données télématique : tracking, antivol, vitesses, arrêts
- Données tachygraphe : conformité R561
- Procédure interne : version signée par le conducteur
- Témoignage écrit du conducteur (sans pression, neutre)
- Plainte autorités locales
- Photos de l''aire, du véhicule
- Carte des aires sécurisées disponibles à proximité

ÉTAPE 2 — Analyse juridique (J+5 à J+10)

- Plafond CMR : 80 000 / (poids × 8,33 × 1,30) = ratio à calculer pour voir l''écart
- Si plafond CMR couvre la valeur déclarée : pas d''enjeu de faute lourde
- Si plafond CMR insuffisant : enjeu sur faute lourde

ÉTAPE 3 — Position et défense (J+10)

Si défense solide (5 éléments favorables sur 8) :
- Refuser la qualification de faute lourde
- Proposer indemnisation au plafond CMR
- Argumentaire écrit avec preuves

Si défense fragile (5 éléments défavorables sur 8) :
- Reconnaître partage de responsabilité
- Négocier transaction transactionnelle (50-70 % de la valeur)
- Éviter le procès qui risque de confirmer la faute lourde

Mesures internes correctives :

1. Audit complet du parcours conducteur (formation, procédures)
2. Renforcement procédure stationnement (carte aires sécurisées, validation préalable)
3. Renforcement antivol (alarme désactivation, suivi temps réel)
4. Formation refresher tous les conducteurs
5. Sanction interne si manquement individuel avéré (avertissement, voire procédure disciplinaire)
6. Communication interne anonyme : « voici ce qui s''est passé, voici ce qu''on change »'),
  (v_formation, 'qr', 'Comparez RC Pro et RC marchandises étendue pour une PME de transport ayant 25 véhicules dont 5 dédiés au transport de produits cosmétiques de luxe (valeur moyenne 200 000 €/chargement). Pourquoi et comment souscrire ? Coûts indicatifs ?', NULL, 1, 'difficile', ARRAY['assurance','couverture','roi'], 'mft-2026-gotrm:bc01-09:qr:4', true, 'Comparaison RC Pro vs RC marchandises étendue :

RC PRO (Responsabilité Civile Professionnelle) — Standard

Couverture :
- Avaries, pertes, retards dans les plafonds légaux
- Frais de défense (avocat, expertise)
- Dommages causés par le transporteur dans le cadre du contrat de transport
- Plafond annuel typique : 1-5 M€ tous sinistres confondus

Limites :
- Plafonds légaux uniquement (33 €/kg national, 8,33 DTS/kg CMR)
- PAS la faute lourde / dol
- PAS les dommages immatériels purs (manque à gagner)
- PAS les dépassements sans déclaration de valeur

Coût pour une PME 25 véhicules :
- Prime annuelle : 8 000 - 15 000 € (selon antécédents, secteur)
- Franchise : 1 000 - 5 000 € par sinistre
- Souvent obligatoire (clause type chez les chargeurs)

RC MARCHANDISES ÉTENDUE — Couverture renforcée

Couverture :
- Au-delà des plafonds légaux : jusqu''à 100 000 € à 1 M€ par sinistre
- Tous risques (avec exclusions limitées)
- Couvre la valeur réelle des marchandises
- Souvent inclut la faute lourde (selon clauses)

Limites :
- Exclusions explicites (guerre, dol prouvé, fraude)
- Souvent franchise plus élevée (5 000 - 15 000 €)
- Certaines exigences (suivi GPS obligatoire, parkings sécurisés)

Coût pour une PME 25 véhicules :
- Prime annuelle additionnelle : 5 000 - 15 000 € (selon plafond et couverture)
- Souvent en sus de la RC Pro
- Pour les marchandises sensibles : peut être obligatoire client

Calcul de pertinence pour notre PME :

Profil :
- 25 véhicules, dont 5 cosmétiques luxe (200 000 € chargement)
- Volume estimé : 5 véhicules × 200 missions/an = 1 000 missions sensibles/an
- Valeur transportée annuelle sur ces 5 véhicules : 1 000 × 200 000 = 200 M€

Risque sinistre :
- Statistiques sectorielles : 0,1 % à 0,3 % des missions sensibles donnent un sinistre
- 1 000 missions × 0,2 % = 2 sinistres / an en moyenne
- Valeur moyenne par sinistre : 50 000 € (perte partielle)

Couverture :
- Sans RC marchandises étendue : plafond CMR ~ 12 000 € par sinistre (1 200 kg × 10 €/kg)
- Manque à couvrir : 50 000 - 12 000 = 38 000 € par sinistre, soit 76 000 € / an non couvert

Avec RC marchandises étendue :
- Plafond 200 000 € par sinistre
- Couverture : 50 000 € par sinistre, soit 100 000 € / an
- Coût de la prime additionnelle : ~ 12 000 €/an
- Économie nette : 100 000 - 12 000 = 88 000 € / an

CONCLUSION : la RC marchandises étendue est largement rentable.

Stratégie de souscription recommandée :

1. RC Pro standard : 12 000 €/an (pour les 25 véhicules globalement)

2. RC marchandises étendue ciblée :
- Souscription dédiée aux 5 véhicules cosmétiques (police séparée)
- Plafond : 250 000 € par sinistre (couvre la valeur typique × 1,25)
- Franchise : 5 000 € par sinistre (compatible avec trésorerie)
- Exigences à respecter : antivol GPS systématique, aires sécurisées, formation conducteurs
- Coût additionnel : 12 000 - 18 000 €/an

3. Politique de gestion :
- Demander systématiquement déclaration de valeur sur CMR
- Tarifer en conséquence (supplément 1,5 - 2 % de la valeur)
- Constituer un dossier sinistre complet avant la déclaration
- Mesurer les incidents pour ajuster les couvertures annuellement

4. Mesures préventives complémentaires :
- Antivol GPS sur les 5 véhicules sensibles : ~ 3 000 €/an
- Convention avec réseau d''aires sécurisées (TOP-IRU) : ~ 2 000 €/an
- Formation conducteurs sécurité chargements de valeur : ~ 1 500 €/an
- Audit annuel des procédures : ~ 2 000 €

Budget global protection sinistres :

| Poste | Coût annuel |
|---|---|
| RC Pro standard | 12 000 € |
| RC marchandises étendue (5 véhicules) | 15 000 € |
| Antivol GPS, aires sécurisées | 5 000 € |
| Formation, audit | 3 500 € |
| Total | 35 500 € |

Sur un CA estimé à 5 M€ (25 véhicules × 200 k€/an), cela représente 0,71 % du CA — investissement très raisonnable pour la sécurisation de 200 M€ de marchandises transportées.

ROI de la stratégie :
- Sinistres évités estimés : 100 000 €/an
- Surcoût investissement : 18 000 €/an
- Net : 82 000 €/an d''économie + sérénité opérationnelle.'),
  (v_formation, 'qr', 'Listez 8 mesures préventives concrètes à mettre en place dans une entreprise de transport pour réduire significativement le risque de litiges et de sinistres. Pour chacune, précisez le coût indicatif et le bénéfice attendu.', NULL, 1, 'difficile', ARRAY['prevention','plan','roi'], 'mft-2026-gotrm:bc01-09:qr:5', true, '8 mesures préventives concrètes :

1. PROCÉDURE DE PRISE EN CHARGE STANDARDISÉE
- Action : photo systématique de chaque palette/colis au chargement
- Application mobile dédiée (gratuites : Mappy, Maps, ou TMS intégré)
- Réserves systématiques au chargement si emballage suspect
- Coût : 1 500 €/an (mobile + temps formation)
- Bénéfice : élimine 30-40 % des litiges avariis (preuve photo)
- ROI : x 5 (litiges évités ~ 7 500 €/an)

2. POLITIQUE STATIONNEMENT SÉCURISÉE
- Carte des aires sécurisées (TOP-IRU, CTPark) accessible aux conducteurs
- Procédure : aires sécurisées la nuit pour marchandises > 30 000 €
- Convention avec réseau d''aires (~ 800 €/an)
- Coût : 2 500 €/an (formation + frais aires)
- Bénéfice : réduction vols 50-70 %
- ROI : x 8-12 sur les zones à risque

3. ANTIVOL GPS SYSTÉMATIQUE
- Installation sur tous véhicules transportant des marchandises de valeur
- Activation systématique pendant les arrêts > 30 min
- Coût : 200 €/véhicule + 15 €/mois abonnement
- Pour 25 véhicules : ~ 4 500 € installation + 4 500 €/an abonnement
- Bénéfice : taux récupération vol > 60 % (vs 5 % sans GPS)
- Bonus assurance : prime RC marchandises - 8 à 12 %

4. FORMATION CONDUCTEURS « SÉCURITÉ - LITIGES »
- Module 1/2 jour annuel obligatoire pour tous conducteurs
- Contenu : procédures réserves, sécurité, communication client, gestion incidents
- Coût : 200 €/conducteur × 25 = 5 000 €/an
- Bénéfice : réduction des erreurs humaines de 20-30 %
- ROI : x 3-5 sur sinistres évités

5. SYSTÈME D''ALERTE TEMPS RÉEL
- Télématique avec alertes : arrêt anormal, désactivation antivol, hors itinéraire, conduite agressive
- Notification SMS / app à l''exploitation 24/7
- Coût : 25 €/véhicule/mois × 25 × 12 = 7 500 €/an
- Bénéfice : intervention immédiate possible (vol évité, panne anticipée)
- ROI : x 5-10 sur incidents majeurs évités

6. POLITIQUE DÉCLARATION DE VALEUR SYSTÉMATIQUE
- Demande systématique aux chargeurs : déclaration de valeur sur CMR pour > 5 000 €
- Supplément de prix de transport facturé
- Mise à jour des CGT pour préciser cette obligation
- Coût : 1 000 € (audit juridique CGT, mise à jour)
- Bénéfice : couverture intégrale des sinistres importants, réduction des contestations
- ROI : x 20+ sur les sinistres marchandises de valeur

7. CRM / GESTION RÉCLAMATIONS DÉDIÉE
- Outil de ticketing pour les réclamations (HubSpot Service Hub gratuit, Freshdesk, Zendesk)
- Procédure : accusé de réception < 4 h, réponse < 48 h
- Reporting hebdomadaire des litiges au DG
- Coût : 2 000 €/an (logiciel + paramétrage)
- Bénéfice : moins d''escalades, traitement amiable accéléré, satisfaction client
- ROI : x 3-5 (transactions réussies, churn évité)

8. AUDIT TRIMESTRIEL DES PROCÉDURES
- Audit interne par responsable qualité (1 j/trimestre)
- Vérification : photos chargement, réserves, conformité tachygraphe, antivols
- Plan d''action correctif communiqué en CODIR
- Coût : 4 000 €/an (temps interne)
- Bénéfice : amélioration continue, détection précoce des dérives
- ROI : x 2-4 (par effet levier sur tous les autres axes)

SYNTHÈSE BUDGÉTAIRE ET ROI :

| Mesure | Coût annuel | Bénéfice estimé annuel |
|---|---|---|
| 1. Procédure prise en charge | 1 500 € | 7 500 € |
| 2. Stationnement sécurisé | 2 500 € | 25 000 € |
| 3. Antivol GPS | 9 000 € | 35 000 € (vols + assurance) |
| 4. Formation conducteurs | 5 000 € | 18 000 € |
| 5. Alertes temps réel | 7 500 € | 40 000 € |
| 6. Déclaration de valeur | 1 000 € | 20 000 € |
| 7. CRM réclamations | 2 000 € | 12 000 € |
| 8. Audit trimestriel | 4 000 € | 15 000 € |
| TOTAL | 32 500 € | 172 500 € |

ROI global estimé : x 5,3

Effet bonus :
- Image de marque renforcée auprès des chargeurs
- Argument commercial différenciant (« 0,3 % de litiges moyens vs 1,2 % secteur »)
- Crédibilité dans les appels d''offres exigeants (grandes industries, pharma)
- Réduction des primes d''assurance à terme (-15 à -25 % sur 3 ans)

Mise en place :
- Année 1 : déploiement progressif, mesures urgentes (1, 3, 6)
- Année 2 : montée en puissance (2, 4, 5)
- Année 3 : optimisation (7, 8) et capitalisation
- Bilan annuel pour ajuster les investissements selon ROI réel.');


  -- =================================================================
  -- QUIZZES
  -- =================================================================
  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — Régime de responsabilité', 'Obligation de résultat, force majeure, exonérations, faute lourde.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_1;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-09:qcm:1','mft-2026-gotrm:bc01-09:qcm:2','mft-2026-gotrm:bc01-09:qcm:3','mft-2026-gotrm:bc01-09:qcm:8','mft-2026-gotrm:bc01-09:qcm:28');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — Plafonds et prescriptions', 'Plafonds national/CMR, frais accessoires, prescriptions.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_2;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-09:qcm:4','mft-2026-gotrm:bc01-09:qcm:5','mft-2026-gotrm:bc01-09:qcm:6','mft-2026-gotrm:bc01-09:qcm:7','mft-2026-gotrm:bc01-09:qcm:9','mft-2026-gotrm:bc01-09:qcm:10','mft-2026-gotrm:bc01-09:qcm:11','mft-2026-gotrm:bc01-09:qcm:12','mft-2026-gotrm:bc01-09:qcm:13','mft-2026-gotrm:bc01-09:qcm:14');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — Gestion amiable', 'Procédure réception, dossier de défense, expertise, transaction.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_3;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_3, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-09:qcm:15','mft-2026-gotrm:bc01-09:qcm:22','mft-2026-gotrm:bc01-09:qcm:26','mft-2026-gotrm:bc01-09:qcm:27');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Quiz — Procédure judiciaire et assurance', 'Juridictions, RC Pro, RC étendue, subrogation, franchise.', 'entrainement', NULL, 70)
  RETURNING id INTO v_quiz_4;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_4, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-09:qcm:16','mft-2026-gotrm:bc01-09:qcm:17','mft-2026-gotrm:bc01-09:qcm:18','mft-2026-gotrm:bc01-09:qcm:19','mft-2026-gotrm:bc01-09:qcm:20','mft-2026-gotrm:bc01-09:qcm:21','mft-2026-gotrm:bc01-09:qcm:23','mft-2026-gotrm:bc01-09:qcm:24','mft-2026-gotrm:bc01-09:qcm:25');

  INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)
  VALUES (v_module, 'Examen blanc — BC01-09 Litiges', '15 QCM en 30 min, seuil 50 %.', 'examen', 1800, 50)
  RETURNING id INTO v_quiz_eb;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_quiz_eb, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN ('mft-2026-gotrm:bc01-09:qcm:1','mft-2026-gotrm:bc01-09:qcm:2','mft-2026-gotrm:bc01-09:qcm:4','mft-2026-gotrm:bc01-09:qcm:5','mft-2026-gotrm:bc01-09:qcm:7','mft-2026-gotrm:bc01-09:qcm:8','mft-2026-gotrm:bc01-09:qcm:10','mft-2026-gotrm:bc01-09:qcm:11','mft-2026-gotrm:bc01-09:qcm:13','mft-2026-gotrm:bc01-09:qcm:14','mft-2026-gotrm:bc01-09:qcm:18','mft-2026-gotrm:bc01-09:qcm:20','mft-2026-gotrm:bc01-09:qcm:22','mft-2026-gotrm:bc01-09:qcm:24','mft-2026-gotrm:bc01-09:qcm:27');

  RAISE NOTICE '✅ GOTRM BC01-09 v2 chargé : 4 leçons, 28 QCM, 5 QR, 5 quizzes (4 entraînement + 1 examen blanc).';
END
$bc01_09$;
