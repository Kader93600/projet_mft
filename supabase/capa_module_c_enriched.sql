-- =====================================================================
-- MODULE C — CADRE RÉGLEMENTAIRE DU TRANSPORT (Capa -3,5T)
-- 5 leçons premium ~ 175 min de contenu pédagogique.
-- Idempotent.
-- =====================================================================

DO $mod_c$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'capacite-3-5t';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation capacite-3-5t introuvable.'; END IF;

  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Aucun bloc défini.'; END IF;

  SELECT id INTO v_module FROM public.modules WHERE slug = 'capa-cadre-reglementaire' LIMIT 1;

  IF v_module IS NULL THEN
    INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
    VALUES (
      'Cadre réglementaire du transport routier léger',
      'capa-cadre-reglementaire',
      v_bloc,
      'Maîtriser les conditions d''accès à la profession, les règles de transport, les responsabilités et les contrôles. Module socle pour exercer en conformité.',
      'intermediaire',
      175,
      30
    ) RETURNING id INTO v_module;

    INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
    VALUES (v_formation, v_module, 30, true)
    ON CONFLICT DO NOTHING;
  END IF;

  -- ─── LEÇON 1 : Accès à la profession ────────────────────────────
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'acces-profession') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (
      v_module,
      'Accès à la profession : les 4 conditions',
      'acces-profession',
      1,
      35,
$lesson1$
Le transport routier de marchandises est une **profession réglementée**. Pour exercer légalement, il faut justifier de **4 conditions cumulatives** fixées par le règlement européen 1071/2009. Maîtriser ces conditions, c'est sécuriser durablement votre activité.

:::objectifs
- Identifier les **4 conditions** d'accès à la profession.
- Comprendre les **modalités de justification** de chaque condition.
- Anticiper les **contrôles périodiques** par la DREAL.
:::

## Les 4 conditions cumulatives

:::law code="Règlement (CE)" article="1071/2009 art. 3" date="01/01/2024"
Pour exercer la profession de transporteur par route, l'entreprise doit :
1. Avoir un établissement effectif et stable dans un État membre ;
2. Être honorable ;
3. Avoir la capacité financière appropriée ;
4. Avoir la capacité professionnelle requise.
:::

### 1. L'établissement effectif et stable

**Définition** : siège réel de gestion dans le pays d'inscription, avec des **locaux** où sont conservés les documents.

**Justifications acceptées** :
- Bail commercial ou propriété au siège.
- Présence physique du dirigeant.
- Conservation des documents (contrats, comptabilité, lettres de voiture, etc.) au siège.

**Contrôles fréquents** : la DREAL peut exiger une visite des locaux, surtout pour les structures juridiques complexes.

:::piege
**Domiciliation fictive** = motif de refus ou de retrait de licence. Une simple boîte aux lettres ne suffit pas. Il doit y avoir un local où l'on peut **réellement vous joindre** et consulter vos documents.
:::

### 2. L'honorabilité professionnelle

**Définition** : absence de condamnations graves liées au transport, à la gestion d'entreprise ou aux délits financiers.

**Personnes vérifiées** :
- Le **dirigeant** de l'entreprise.
- Le **gestionnaire de transport** (souvent le dirigeant lui-même en TPE).

**Condamnations entraînant la perte d'honorabilité** :
- Banqueroute, abus de biens sociaux, faux et usage de faux.
- Infractions graves au Code de la route (alcoolémie aggravée, mise en danger, délit de fuite).
- Infractions à la réglementation sociale ou fiscale (travail dissimulé, fraude TVA majeure).
- Atteintes aux personnes (escroquerie, blanchiment).

**Modalité de vérification** : extrait de casier judiciaire **bulletin n° 2** (B2), demandé directement par la DREAL aux services compétents.

### 3. La capacité financière

**Montants requis** (transport ≤ 3,5 T) :

| Critère | Montant |
|---|---|
| 1er véhicule motorisé | **1 800 €** |
| Chaque véhicule motorisé suivant | **+ 900 €** |

**Exemples** :
- 1 véhicule = 1 800 €.
- 3 véhicules = 1 800 + (2 × 900) = **3 600 €**.
- 10 véhicules = 1 800 + (9 × 900) = **9 900 €**.

**Justifications acceptées** :

1. **Fonds propres au bilan** (capital + réserves + report à nouveau) — la solution la plus solide.
2. **Caution bancaire** spécifique : engagement écrit d'une banque (~1-3 % du montant cautionné par an).
3. **Cautionnement par un organisme** (chambre de commerce, etc.) — plus rare.

:::caspratique
**Karim** a 5 véhicules. Capacité financière requise : 1 800 + 4×900 = **5 400 €**.

Sa trésorerie est de 6 000 €, mais les fonds propres au bilan ne sont que de 2 000 € (le reste = comptes courants d'associés).

**Solution** :
- Soit **renforcer les fonds propres** (capitalisation des CCA, ou augmentation de capital).
- Soit **souscrire une caution bancaire** pour 3 400 € (différence). Coût annuel : ~ 100 €.

S'il ne fait rien, en cas de contrôle DREAL : **suspension de licence** possible.
:::

### 4. La capacité professionnelle

**Définition** : compétences nécessaires pour gérer une entreprise de transport, validées par un titre.

**Voies d'obtention** :

1. **Examen écrit** organisé par la DREAL :
   - Programme : 8 matières (droit, gestion, fiscalité, social, technique, exploitation, sécurité, normes).
   - QCM + questions ouvertes + cas pratiques (~ 4h).
   - Durée préparation : typiquement 30-50h de formation.

2. **Équivalence par expérience** :
   - **2 ans minimum** d'expérience continue en gestion d'entreprise de transport routier de marchandises au cours des **10 dernières années**.
   - Justifications : contrats de travail, bulletins de paie, attestations.
   - Demande à la DREAL avec dossier complet.

3. **Diplômes équivalents** :
   - BTS Transport, licence pro Transport-Logistique, diplôme d'ingénieur transport.
   - Liste précise des diplômes reconnus.

:::memo
**Le titulaire de la capacité** doit être présent dans l'entreprise et **réellement impliqué** dans la gestion. Si c'est un dirigeant absent (capacité "prêtée"), c'est juridiquement frauduleux et peut entraîner le retrait de la licence.
:::

## La licence de transport

Une fois les 4 conditions remplies, vous pouvez demander votre **licence**.

### Licence intérieure

- Pour les transports **dans un seul pays** (France).
- Délivrée par la **DREAL** de la région du siège social.
- **Durée** : 10 ans renouvelable.
- **Coût** : ~150-200 € pour la 1ère délivrance.

### Licence communautaire

- Pour les transports **internationaux** dans l'UE.
- Conditions : licence intérieure + capacité financière renforcée.
- Délivrée par la **DREAL** également.
- **Durée** : 10 ans renouvelable.

### Copie certifiée conforme

**Une copie** de la licence doit être présente **à bord de chaque véhicule** en circulation. Document contrôlable par la police, gendarmerie, DREAL.

:::piege
**Conduire sans la copie certifiée** = infraction. Amende 750 € + immobilisation du véhicule. Photocopier soi-même ne vaut pas "copie certifiée" : seules les copies estampillées par la DREAL sont valides.
:::

## Le registre des transporteurs

L'inscription au **registre national des transporteurs** est obligatoire et **publique**. Conséquences pratiques :

- Vos clients peuvent vérifier votre inscription en ligne.
- Vos sous-traitants peuvent être vérifiés par vous.
- Toute modification (siège, dirigeant, véhicules) doit être notifiée à la DREAL.

:::conseil
**Tenez à jour** votre fiche au registre : changement d'adresse, nouveau dirigeant, augmentation/diminution de flotte. Une fiche incohérente déclenche systématiquement un contrôle approfondi.
:::

## En synthèse

4 conditions cumulatives, contrôles réguliers, sanctions graves en cas de manquement. Mais **rien d'insurmontable** avec un suivi rigoureux. La plupart des entreprises perdues le sont par négligence (capacité financière non renouvelée, gestionnaire de transport remplacé sans notification, etc.) — pas par incapacité à respecter le cadre.
$lesson1$,
$summary1$
**À retenir**

- 4 conditions cumulatives : établissement, honorabilité, capacité financière, capacité professionnelle.
- Capacité financière : 1 800 € (1er véh.) + 900 € par véhicule supplémentaire.
- Capacité professionnelle : examen, équivalence (2 ans expérience/10), ou diplôme reconnu.
- Licence intérieure (France) ou communautaire (UE), valable 10 ans.
- Copie certifiée conforme obligatoire à bord de chaque véhicule.
- Registre national des transporteurs : à tenir à jour à chaque modification.
$summary1$
    );
  END IF;

  -- ─── LEÇON 2 : Contrats et responsabilité ──────────────────────
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'contrats-responsabilite-transport') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (
      v_module,
      'Contrats de transport et responsabilité',
      'contrats-responsabilite-transport',
      2,
      35,
$lesson2$
Le contrat de transport est un **objet juridique précis** avec ses propres règles, distinctes du droit commercial général. Maîtriser ces règles, c'est savoir ce que vous devez **vraiment** à votre client — et ce qu'il **peut** vous réclamer.

:::objectifs
- Distinguer **contrat type général** vs **convention spécifique**.
- Maîtriser les **plafonds d'indemnisation** légaux.
- Comprendre les **causes d'exonération** de responsabilité.
:::

## Le contrat type général (CTG)

**S'applique de plein droit** en l'absence de convention écrite spécifique.

:::law code="Décret n°" article="99-269 du 6 avril 1999" date="01/01/2024"
Le contrat type "général" applicable aux transports publics routiers de marchandises (...) régit, en l'absence de stipulations contractuelles différentes, les relations entre l'expéditeur, le transporteur et le destinataire.
:::

### Les obligations du transporteur (CTG)

1. **Charger** la marchandise en présence de l'expéditeur (ou son représentant).
2. **Établir** la lettre de voiture en 3 exemplaires.
3. **Vérifier** l'aspect extérieur de la marchandise et formuler des réserves si nécessaire.
4. **Transporter** dans les délais convenus.
5. **Livrer** la marchandise au destinataire désigné.

### Les obligations de l'expéditeur (CTG)

1. **Préparer** la marchandise (emballage, palettisation, marquage).
2. **Communiquer** les informations exactes (poids, nature, valeur, instructions).
3. **Payer** le prix convenu (sauf transfert au destinataire).

### Les obligations du destinataire (CTG)

1. **Réceptionner** la marchandise.
2. **Vérifier** son état avant signature.
3. **Émettre des réserves** en cas d'anomalie (dans les délais).

## Les plafonds d'indemnisation

**Point central** du CTG : la responsabilité du transporteur est **limitée**.

### Pertes et avaries (transport intérieur)

| Critère | Plafond |
|---|---|
| Au poids | **23 € HT par kg manquant ou avarié** |
| Au colis | **750 € HT par colis** |

**Exemple** : carton de 12 kg perdu, valeur réelle 4 500 €.
- Plafond au poids : 23 × 12 = 276 €.
- Plafond au colis : 750 €.
- **Indemnité** : la plus avantageuse pour le client = 750 €.
- Le différentiel (3 750 €) est à la charge de l'expéditeur, sauf assurance ad valorem.

### Retard

**Plafond** : montant du **prix de transport**.

**Exemple** : transport facturé 200 €, retard d'1 jour ayant causé un préjudice de 1 200 € au client.
- Indemnité maximale : 200 € (le prix de transport), sauf préjudice supérieur prouvé.

### En transport international (CMR)

| Critère | Plafond |
|---|---|
| Pertes et avaries | **8,33 DTS/kg** ≈ 9,5 € HT/kg |

Le DTS (Droit de Tirage Spécial) est une unité monétaire du FMI, valeur publiée quotidiennement.

:::piege
**Erreur fréquente** : croire que les plafonds CTG s'appliquent à l'international. Faux ! En CMR, le plafond est de 8,33 DTS/kg, sans plafond de colis. Plafonds plus élevés qu'en intérieur dans la plupart des cas.
:::

## Les causes d'exonération

Le transporteur peut s'**exonérer** totalement ou partiellement de sa responsabilité s'il prouve l'une des causes suivantes :

### 1. La force majeure

Événement **imprévisible**, **irrésistible**, **extérieur**.

**Exemples acceptés** :
- Catastrophe naturelle (inondation, ouragan).
- Acte de guerre, attentat.
- Grève **non prévisible** (mouvement social spontané).

**Exemples rejetés** :
- Embouteillage, intempéries habituelles.
- Grève annoncée plusieurs jours à l'avance.
- Panne du véhicule.

### 2. La faute de l'expéditeur

**Exemples** :
- Emballage défaillant.
- Information erronée (poids déclaré inférieur au réel).
- Marquage incorrect.

### 3. Le vice propre de la marchandise

**Exemples** :
- Marchandise déjà avariée au chargement.
- Maturité anormale d'un produit alimentaire.
- Altération inhérente à la nature du produit.

### 4. Les instructions de l'expéditeur

Si vous suivez **strictement** les instructions de l'expéditeur et que cela cause un dommage : exonération.

**Exemple** : l'expéditeur exige un transport non-frigorifié pour des produits sensibles. Si la marchandise s'altère, vous n'êtes pas responsable (à condition d'avoir prévenu et fait signer une décharge).

:::caspratique
**Cas réel** : un transporteur livre des produits frais. Le destinataire constate une altération (température excessive). Il réclame 2 500 € d'indemnité.

**Enquête** :
1. La lettre de voiture mentionne "transport sec" demandé par l'expéditeur (alors que les produits sont frais).
2. Le transporteur a un email où l'expéditeur a refusé le sur-coût frigo.
3. La température dans la cargaison était bien celle d'un transport sec normal.

**Conclusion** : exonération du transporteur. Le préjudice est à la charge de l'expéditeur qui a donné une instruction inadaptée.

**Leçon** : conserver **toutes les traces écrites** des choix logistiques imposés par l'expéditeur.
:::

## Les délais de réclamation

| Type | Délai |
|---|---|
| Réserves à la livraison (dommage apparent) | **Avant signature** ou **3 jours ouvrables** après |
| Réserves à la livraison (dommage non apparent) | **3 jours ouvrables** |
| Action judiciaire transport intérieur | **1 an** |
| Action judiciaire transport international (CMR) | **1 an** (3 ans en cas de dol) |

Passé ces délais : **forclusion**. Aucun recours possible.

## L'assurance ad valorem

Pour aller au-delà des plafonds CTG/CMR, l'expéditeur peut souscrire une **assurance complémentaire** :

- **Coût** : ~ 0,3 à 0,5 % de la valeur déclarée.
- **Bénéfice** : indemnisation à la valeur réelle de la marchandise.
- **Modalités** : valeur déclarée à l'avance, mention sur la lettre de voiture.

:::conseil
Pour les expéditions de **valeur élevée** (> 5 000 €), proposez **systématiquement** l'option ad valorem dans votre devis. Vous transformez un risque potentiel pour vous en revenu pour vous (vous facturez la prime + une marge).
:::

## En synthèse

| Élément | Règle |
|---|---|
| Sans contrat | CTG s'applique |
| Avec contrat spécifique | Vous fixez vos règles (dans la limite de l'ordre public) |
| Indemnisation | 23 €/kg ou 750 €/colis (intérieur) — 8,33 DTS/kg (international) |
| Retard | Plafond = prix de transport |
| Exonération | Force majeure / faute expéditeur / vice / instructions |
| Réclamation | 3 jours ouvrables après livraison |
| Action judiciaire | 1 an (3 ans en cas de dol) |
$lesson2$,
$summary2$
**À retenir**

- Sans contrat écrit : contrat type général s'applique de plein droit.
- Indemnisation transport intérieur : 23 €/kg OU 750 €/colis (le plus avantageux pour le client).
- Indemnisation CMR : 8,33 DTS/kg ≈ 9,5 €/kg.
- Retard : plafond = prix de transport.
- 4 causes d'exonération : force majeure, faute expéditeur, vice marchandise, instructions.
- Réserves à la livraison : 3 jours ouvrables.
- Action judiciaire : 1 an de prescription.
$summary2$
    );
  END IF;

  -- ─── LEÇON 3 : Tachygraphe et temps de service ─────────────────
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'tachygraphe-temps-service') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (
      v_module,
      'Tachygraphe et temps de service',
      'tachygraphe-temps-service',
      3,
      35,
$lesson3$
La réglementation européenne sur les **temps de conduite et de repos** s'applique à tous les véhicules > 3,5 T (sauf rares exceptions). Pour le transporteur léger, c'est moins strict — mais les règles existent et doivent être respectées.

:::objectifs
- Comprendre **quand** le tachygraphe est obligatoire.
- Maîtriser les **temps de conduite et de repos** réglementaires.
- Savoir **lire** les données tachygraphe et identifier les infractions.
:::

## Le tachygraphe : quand est-il obligatoire ?

### Véhicules concernés

Le tachygraphe est obligatoire pour les véhicules :
- De **transport de marchandises > 3,5 T** (PTAC).
- De **transport de voyageurs > 9 places**.

Pour le transport **léger ≤ 3,5 T**, **pas d'obligation tachygraphe** dans la plupart des cas.

### Exceptions notables

**Exemptés** même au-delà de 3,5 T :
- Transport pour usage propre (compte propre, marchandise de l'entreprise).
- Véhicules d'urgence (ambulances, pompiers).
- Véhicules anciens (immatriculés avant 1985).
- Trajets < 100 km sur certaines opérations agricoles.

**Imposés** pour les véhicules ≤ 3,5 T : si **transport international** (cabotage), certaines règles s'appliquent.

## Les temps de conduite

:::law code="Règlement (CE)" article="561/2006" date="01/01/2024"
Le temps de conduite journalier ne dépasse pas 9 heures. Le temps de conduite journalier peut être prolongé à 10 heures au maximum, deux fois au cours de la semaine.
:::

### Limites quotidiennes

| Limite | Durée |
|---|---|
| Conduite continue maximum | **4h30** sans pause |
| Conduite quotidienne normale | **9h** |
| Conduite quotidienne maximum | **10h** (max 2 fois/semaine) |

### Limites hebdomadaires

| Limite | Durée |
|---|---|
| Conduite hebdomadaire | **56h** |
| Conduite sur 2 semaines | **90h max cumulées** |

### Pauses

- Après **4h30 de conduite continue** : pause minimum **45 min**.
- Possibilité de **fractionner** la pause : 15 min + 30 min (dans cet ordre).

## Les temps de repos

### Repos quotidien

| Type | Durée |
|---|---|
| Repos quotidien normal | **11h consécutives** |
| Repos quotidien réduit | **9h** (max 3 fois/semaine) |
| Repos quotidien fractionné | **3h + 9h** dans la même journée |

### Repos hebdomadaire

| Type | Durée |
|---|---|
| Repos hebdomadaire normal | **45h consécutives** |
| Repos hebdomadaire réduit | **24h** (à compenser dans les 3 semaines) |

**Règle** : sur 2 semaines consécutives, au moins **1 repos hebdomadaire normal** (45h) doit être pris.

:::caspratique
**Une semaine type d'un chauffeur** :
- Lundi : conduite 9h, repos 11h.
- Mardi : conduite 9h, repos 11h.
- Mercredi : conduite 10h (1ère extension), repos 11h.
- Jeudi : conduite 10h (2ème extension), repos 11h.
- Vendredi : conduite 9h.
- **Total** : 47h de conduite (sous le plafond 56h).
- **Samedi+Dimanche** : repos hebdomadaire 45h consécutives.

Tout est conforme.
:::

## Le tachygraphe numérique

Depuis **2006**, tous les véhicules neufs > 3,5 T sont équipés d'un tachygraphe **numérique**. Depuis **2019**, c'est le tachygraphe **intelligent V2** (avec GPS, communication à distance). À partir de **2024-2025**, généralisation du V2.2 (anti-fraude renforcé).

### Les 4 cartes du tachygraphe

| Carte | Utilisateur | Rôle |
|---|---|---|
| **Conducteur** | Conducteur | Enregistre toutes ses activités sur 28 jours |
| **Entreprise** | Transporteur | Lit les données des cartes conducteurs |
| **Atelier** | Centre technique agréé | Calibre/répare les tachygraphes |
| **Contrôleur** | Forces de l'ordre, DREAL | Lit les données pour contrôle |

### Comment ça marche

1. Avant la prise de service : conducteur **insère sa carte**.
2. Le tachygraphe enregistre automatiquement : conduite, autres tâches, disponibilité, repos.
3. Tous les **28 jours**, le conducteur télécharge sa carte (via l'entreprise).
4. L'entreprise **doit conserver** les données pendant **1 an** au moins (en pratique : 5 ans).

### Les obligations du conducteur

- **Insérer la carte** à chaque prise de service.
- **Sélectionner manuellement** l'activité (autre travail, disponibilité) quand le tachygraphe ne le détecte pas.
- **Imprimer** un ticket en cas de panne tachygraphe.

### Les obligations de l'entreprise

- **Télécharger** les données régulièrement (carte conducteur tous les 28 jours, mémoire véhicule tous les 90 jours).
- **Conserver** les données 1 à 5 ans.
- **Vérifier** les infractions et **alerter** les conducteurs.
- **Former** les conducteurs à l'usage du tachygraphe.

:::piege
**Falsification du tachygraphe** : sanction pénale jusqu'à **1 an de prison + 30 000 € d'amende**. Pour l'entreprise : **retrait de licence** possible. Risque énorme pour gagner quelques heures de conduite.
:::

## Les sanctions

### Sanctions immédiates (par les contrôleurs)

| Infraction | Sanction immédiate |
|---|---|
| Conduite sans carte | 750 € + retrait points |
| Sur-temps de conduite < 1h | 135 € (4ème classe) |
| Sur-temps de conduite > 2h | 1 500 € (5ème classe) |
| Repos insuffisant grave | 1 500 € + immobilisation |
| Falsification tachygraphe | Mise en danger d'autrui (procédure judiciaire) |

### Sanctions cumulées

Pour l'**entreprise**, les infractions répétées peuvent entraîner :
- Suspension de licence.
- Perte d'honorabilité du dirigeant.
- Retrait de la licence.

## En pratique pour le transport ≤ 3,5 T

Vous n'êtes **pas soumis** au tachygraphe. Mais le **Code du travail** s'applique :

- Durée du travail : 35h/semaine (durée légale), 48h max absolue.
- Heures supplémentaires : majoration 25 % (8 premières) puis 50 %.
- Repos quotidien : **11h consécutives**.
- Repos hebdomadaire : **35h consécutives** minimum.

:::conseil
Même si vous n'êtes pas tenu au tachygraphe, **tracez** les temps de conduite et de pause. Outil simple : carnet de bord ou app mobile (myDrivers, Wepio). Utile en cas d'accident pour prouver que le conducteur n'était pas en surfatigue.
:::

## En synthèse

Le transport léger échappe au tachygraphe, mais pas au Code du travail. Si votre flotte évolue vers du > 3,5 T, vous basculerez sous le règlement 561/2006 — préparez-vous à un suivi rigoureux. Les outils numériques modernes facilitent énormément ce suivi.
$lesson3$,
$summary3$
**À retenir**

- Tachygraphe obligatoire > 3,5 T (sauf exemptions précises).
- Conduite : 9h/jour normale (10h max 2x/sem), 56h/sem, 90h/2 sem.
- Pause : 45 min après 4h30 (fractionnable 15 + 30).
- Repos quotidien : 11h normales (9h réduites max 3x/sem).
- Repos hebdo : 45h normales (24h réduites avec compensation).
- 4 cartes : conducteur, entreprise, atelier, contrôleur.
- Sanctions falsification : 1 an prison + 30 000 € + retrait licence possible.
- Transport ≤ 3,5 T : pas de tachygraphe mais Code du travail s'applique.
$summary3$
    );
  END IF;

  -- ─── LEÇON 4 : Contrôles et sanctions ─────────────────────────
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'controles-sanctions') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (
      v_module,
      'Contrôles et sanctions : être prêt',
      'controles-sanctions',
      4,
      35,
$lesson4$
Le secteur du transport est l'un des **plus contrôlés** de France. DREAL, gendarmerie, police, URSSAF, inspection du travail, douanes : nombreux services peuvent diligenter un contrôle. Être prêt = limiter les sanctions, voire les éviter complètement.

:::objectifs
- Connaître les **différents types de contrôles** et leurs autorités.
- Préparer les **documents obligatoires** à présenter.
- Réagir **professionnellement** lors d'un contrôle inopiné.
:::

## Les autorités de contrôle

### 1. La DREAL — autorité du transport

**Compétences** :
- Vérification de l'inscription au registre.
- Contrôle des conditions de la profession (capacité financière, honorabilité).
- Suivi des licences et copies certifiées.

**Modalités** : contrôles planifiés (sur dossier) ou inopinés (visite des locaux, contrôle routier).

### 2. La gendarmerie / police — sécurité routière

**Compétences** :
- Vérification des documents à bord (carte grise, assurance, copie licence, lettre de voiture).
- Contrôle alcoolémie, stupéfiants.
- Contrôle des temps de conduite (pour les véhicules tachygraphe).

**Modalités** : contrôles routiers, opérations ciblées (radar, checkpoint).

### 3. L'URSSAF — cotisations sociales

**Compétences** :
- Vérification des déclarations de salariés (DPAE).
- Contrôle du paiement des cotisations.
- Lutte contre le travail dissimulé.

**Modalités** : contrôle sur dossier (sur place dans l'entreprise) ou inopiné. Convocation 15 jours avant en règle générale.

### 4. L'Inspection du travail — relations sociales

**Compétences** :
- Conditions de travail.
- Respect des conventions collectives.
- DUERP, médecine du travail.
- Heures supplémentaires, RTT, congés.

**Modalités** : visite inopinée possible ; contrôle sur dossier majoritaire.

### 5. Les douanes — international

**Compétences** :
- Vérification des marchandises transportées (origine, taxes, conformité).
- Contrôle ADR (matières dangereuses).

**Modalités** : ciblage, contrôles aléatoires aux frontières et à l'intérieur.

## Les documents à avoir TOUJOURS à portée

### Sur le siège social

- **Statuts** de l'entreprise.
- **Extrait Kbis** récent.
- **Licence** originale et copies certifiées en cours de validité.
- **Justificatifs de capacité financière** (bilans, attestations bancaires).
- **Justificatifs de capacité professionnelle** (attestation, diplômes).
- **Contrats de travail** des salariés.
- **DUERP** à jour.
- **Convention collective** applicable (CCNTRAAT).
- **Registres légaux** (registre du personnel, registre unique du personnel).

### À bord de chaque véhicule

- **Carte grise** du véhicule.
- **Attestation d'assurance** valide.
- **Copie certifiée conforme de la licence** (pas une simple photocopie).
- **Contrôle technique** récent.
- **Lettre de voiture** ou bon de commande pour la marchandise transportée.
- **Permis de conduire** du chauffeur.
- **Carte conducteur** (si tachygraphe).

### Pour les marchandises spéciales

- **ADR** : déclaration de chargement, fiches de données de sécurité, plaques orange.
- **Frigo** : enregistrements de température, certificat ATP.
- **Animaux vivants** : autorisation de transporter (numéro ASV).
- **Périssables** : certificat phytosanitaire si applicable.

:::piege
**Erreur fréquente** : mélanger original et photocopie. Une **copie certifiée** est tamponnée par la DREAL. Une **simple photocopie** ne vaut pas. Vérifiez régulièrement la validité de vos copies à bord.
:::

## Réagir lors d'un contrôle

### Le contrôle routier (gendarmerie/police)

**Réflexes** :
1. **Coopérer** : politesse, calme, courtoisie.
2. **Présenter** les documents demandés sans discussion.
3. **Répondre aux questions** de manière factuelle.
4. **Ne pas** mentir ou dissimuler.

**Si vous identifiez une anomalie** (par ex : copie expirée) :
- **Reconnaître** l'erreur.
- **Expliquer** le contexte (renouvellement en cours, etc.).
- **Demander** un délai de régularisation.

Le contrôleur a une marge de manœuvre. Une attitude collaborative peut réduire la sanction (avertissement vs amende).

### Le contrôle URSSAF/Travail

**Préparation** (si convocation préalable) :
1. **Réunir** tous les documents demandés.
2. **Anticiper** les questions sur les points sensibles (heures sup, déclarations).
3. **Faire appel à** un expert-comptable ou avocat pour assistance si dossier complexe.

**Pendant le contrôle** :
- Présence obligatoire du dirigeant ou d'un mandataire.
- Possibilité de se faire accompagner par un conseiller.
- Demander la **mention écrite** des questions/réponses.

### Le contrôle DREAL

**Spécificités** :
- Vérification de la conformité aux 4 conditions de la profession.
- Visite éventuelle des locaux (établissement effectif).
- Contrôle des véhicules (copies licence, conformité technique).

**Action si non-conformité constatée** :
- Délai de régularisation **généralement** accordé (15-30 jours).
- Si non-régularisation : **suspension** de licence puis **retrait** possible.

:::caspratique
**Cas réel** : contrôle DREAL inopiné à 9h. Le dirigeant est sur la route, l'épouse au siège.

**Bonne réaction** :
- "Bonjour, je vous accueille. Mon mari, le dirigeant, est en mission. Je peux vous donner accès à tous les documents qu'il vous faut."
- Présentation : statuts, Kbis, licences, fiches véhicules, contrats salariés.
- Le contrôleur trouve : copie licence du véhicule 3 expirée depuis 2 mois (renouvellement non lancé).

**Conséquence** :
- Avertissement formel.
- 15 jours pour renouveler.
- Pas de sanction pécuniaire.

**Si mauvaise réaction** (refus d'accès, agressivité, dissimulation) : sanction immédiate, contrôle approfondi, sanctions financières.
:::

## Les sanctions principales

### Pécuniaires

| Type | Montant |
|---|---|
| Contraventions classes 1-4 (routier) | 38 € à 750 € |
| Contraventions 5ème classe | 1 500 € (3 000 € pers. morale) |
| Délits routiers | jusqu'à 75 000 € |
| Travail dissimulé | jusqu'à 225 000 € (entreprise) |
| Falsification tachygraphe | 30 000 € + emprisonnement |

### Administratives

| Type | Conséquence |
|---|---|
| Suspension de licence | 1-12 mois |
| Retrait de licence | Définitif (avec délai pour redemander) |
| Interdiction de gérer | 1-15 ans |
| Faillite personnelle | 1-15 ans (procédures collectives) |

### Pénales

| Type | Peine |
|---|---|
| Mise en danger d'autrui | jusqu'à 1 an + 15 000 € |
| Travail dissimulé aggravé | jusqu'à 3 ans + 45 000 € |
| Banqueroute | jusqu'à 5 ans + 75 000 € |

:::conseil
**Préparez un dossier "contrôle" type** : tous les documents-clés numérisés, à jour, classés. En cas de contrôle, vous gagnez 80 % du temps et donnez immédiatement l'image d'un transporteur sérieux.
:::

## En synthèse

Les contrôles sont une **routine** dans le transport. Bien préparé, vous transformez un risque en opportunité de démontrer votre professionnalisme. **Mal préparé**, c'est la sanction quasi-certaine. La différence : 5 minutes de classement par mois.
$lesson4$,
$summary4$
**À retenir**

- 5 autorités de contrôle : DREAL, gendarmerie/police, URSSAF, Inspection du travail, douanes.
- Documents au siège : statuts, Kbis, licence, capacité financière/professionnelle, DUERP, contrats.
- Documents à bord : carte grise, assurance, copie certifiée licence, CT, lettre de voiture, permis.
- Réaction contrôle : coopération + transparence + documents prêts.
- Sanctions : pécuniaires, administratives (suspension/retrait licence), pénales.
- Préparer un dossier "contrôle" type, à jour numériquement.
$summary4$
    );
  END IF;

  -- ─── LEÇON 5 : Cas pratiques de synthèse ───────────────────────
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'cas-pratiques-reglementaire') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (
      v_module,
      'Cas pratiques de synthèse — Cadre réglementaire',
      'cas-pratiques-reglementaire',
      5,
      35,
$lesson5$
4 cas pratiques pour mobiliser l'ensemble du module.

## Cas n° 1 — La capacité financière qui s'effondre

**Situation** : votre entreprise a 4 véhicules. Capacité financière requise : 4 500 €. À l'arrêté du 31/12, vos fonds propres tombent à 2 800 € (suite à un exercice déficitaire).

**Question** : quelle est votre situation ? Que faites-vous ?

:::caspratique
**Analyse** :
1. Vous êtes en **non-conformité** : 2 800 € < 4 500 € requis.
2. La DREAL peut vous le reprocher dès le prochain contrôle ou lors du renouvellement annuel de licence.
3. Sanctions possibles : avertissement → délai de régularisation → suspension de licence.

**Plan d'action** :
- **Court terme** : souscrire une **caution bancaire** de 1 700 € (différence). Coût annuel ~ 100-200 €. Effet immédiat.
- **Moyen terme** : restaurer les fonds propres :
  - Capitalisation des comptes courants d'associés (2 000 € disponibles ?).
  - Augmentation de capital par incorporation de réserves.
  - Apport en numéraire des associés.
- **Long terme** : surveiller mensuellement le ratio fonds propres / capacité requise.

**Anticipation** : vérifier la capacité **avant** de prendre un nouveau véhicule. Sinon, en cas de croissance rapide, on se retrouve sous-capitalisé.
:::

## Cas n° 2 — Le contrôle URSSAF inopiné

**Situation** : 9h45, l'URSSAF se présente à votre siège. Le dirigeant est en clientèle. L'inspecteur demande : contrats de travail, bulletins de paie, déclarations sociales, registre unique du personnel.

**Question** : que fait votre adjoint(e) ?

:::caspratique
**Bonne réaction** :
1. **Accueillir** courtoisement.
2. **Vérifier les habilitations** de l'inspecteur (carte professionnelle).
3. **Prévenir** le dirigeant immédiatement.
4. **Présenter** les documents demandés (a priori tout est à jour).
5. **Ne signer aucun document** sans l'aval du dirigeant ou de l'expert-comptable.
6. **Demander** la transcription écrite des questions/réponses.

**Si non-conformité possible** :
- Demander un **délai** pour produire des documents nécessitant recherches.
- **Faire appel** à l'expert-comptable pour le débrief.

**Mauvaise réaction** :
- Refuser l'accès → constitue un **obstacle** punissable.
- Mentir ou dissimuler → aggrave la sanction.
- Signer sans avoir consulté → engage l'entreprise sur des aveux non vérifiés.

**Risque réel** : si travail dissimulé constaté, **redressement** des cotisations sur 3 ans + majorations. Pour 1 ETP non déclaré sur 1 an : ~ 30 000 € de redressement.
:::

## Cas n° 3 — La copie expirée découverte en contrôle

**Situation** : contrôle routier de la gendarmerie. Le chauffeur présente une copie de licence... expirée depuis 4 mois (votre erreur de gestion).

**Question** : conséquences immédiates et à éviter ?

:::caspratique
**Analyse** :
1. **Infraction** : conduire avec un titre expiré = équivalent à conduire **sans titre**.
2. **Sanctions immédiates** :
   - Amende **750 €** (4ème classe).
   - **Immobilisation** du véhicule jusqu'à régularisation.
   - Pour l'entreprise : risque de **report à la DREAL**.
3. **Si répétition** : ouverture d'un dossier DREAL avec avertissement formel, voire suspension.

**Réaction sur place** :
- **Reconnaître** l'erreur, ne pas chercher d'excuse.
- **Expliquer** le contexte (négligence administrative, pas de fraude).
- **Demander** la procédure de régularisation rapide.

**Plan d'action immédiat** :
- Demander **en urgence** une nouvelle copie certifiée à la DREAL (24-48h).
- **Acquitter** l'amende.
- **Mettre en place un suivi** : alertes 60 jours avant expiration de chaque copie/licence.

**Outils** : un simple Google Calendar avec rappels suffit. Erreur courante mais facilement évitable.
:::

## Cas n° 4 — Le sinistre avec conducteur fatigué

**Situation** : votre chauffeur (CDI 35h, 5 ans d'ancienneté) cause un accident corporel à 18h, après avoir conduit 11h dans la journée (officiellement 9h). Pas de tachygraphe (véhicule ≤ 3,5 T) mais des relevés GPS.

**Question** : conséquences pour vous ? Que faire ?

:::caspratique
**Analyse** :
1. **Code du travail** : durée maximale du travail (heures supp incluses) = 12h/jour. 11h reste légal sur 1 jour mais signal de surcharge.
2. **Code de la route** : pas de plafond formel pour les ≤ 3,5 T, mais **mise en danger d'autrui** possible si fatigue manifeste.
3. **Responsabilité civile** : votre RC pro couvre l'accident, mais votre **responsabilité pénale** comme employeur peut être engagée si négligence prouvée.

**Risques pour vous** :
- Procédure pénale pour **mise en danger d'autrui** ou **homicide involontaire** (si décès).
- **Faute inexcusable** vis-à-vis du chauffeur (s'il est blessé) : majoration des indemnités AT-MP.
- **Suspension de licence** par la DREAL en cas de répétition.

**Actions immédiates** :
1. **Déclaration assurance** dans les 5 jours.
2. **Déclaration AT** à la CPAM dans les 48h.
3. **Mise à pied conservatoire** du chauffeur si suspicion d'alcool/stupéfiants.
4. **Protection juridique** : prévenir votre avocat.

**Actions long terme** :
- Mise en place d'un **carnet de bord** pour tracer les temps de conduite (même non-tachygraphe).
- **Formation** des chauffeurs sur la fatigue.
- **Limitation interne** : 9h conduite max + 1h pause minimum.
- Insertion d'une **clause** dans les contrats de travail : interdiction formelle de dépasser X heures/jour.
:::

## En synthèse du module

Vous maîtrisez maintenant :

1. **Les 4 conditions** d'accès à la profession et les modalités de leur preuve.
2. **Le contrat de transport** et les règles d'indemnisation.
3. **La réglementation tachygraphe** et les temps de service.
4. **La préparation aux contrôles** et la gestion des incidents.

:::conseil
La conformité réglementaire **n'est pas un coût**, c'est une **assurance-vie professionnelle**. Un transporteur conforme = un transporteur durable.
:::
$lesson5$,
$summary5$
**À retenir — Synthèse module C**

- Capacité financière à surveiller mensuellement, alerte si baisse.
- Contrôle URSSAF : accueillir, présenter, ne rien signer sans aval.
- Copie licence expirée = équivalent conduire sans titre. Suivre les dates !
- Conducteur fatigué = responsabilité pénale possible. Tracer les temps même sans tachygraphe.
- Conformité = assurance-vie professionnelle. Pas un coût, un investissement.
$summary5$
    );
  END IF;

  RAISE NOTICE 'Module C (Capa -3,5T - Cadre réglementaire) : 5 leçons premium créées.';
END
$mod_c$;
