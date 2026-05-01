-- =====================================================================
-- MODULE A — DROIT CIVIL & COMMERCIAL (Capacité -3,5T)
-- Enrichissement pédagogique premium
--
-- Crée le module + 5 leçons riches (callouts, lois, cas pratiques, mémo)
-- pour la formation Capacité de transport léger.
--
-- Idempotent — safe à rejouer.
-- Pré-requis :
--   - formations 'capacite-3-5t' présente
--   - blocs 'A' / BC1 ou un bloc bien défini (on prend le bloc 1 par défaut)
-- =====================================================================

DO $mod_a$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_lesson uuid;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'capacite-3-5t';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation capacite-3-5t introuvable.';
  END IF;

  -- Bloc — on prend le 1er disponible si pas de mapping spécifique
  SELECT id INTO v_bloc FROM public.blocs ORDER BY id LIMIT 1;
  IF v_bloc IS NULL THEN
    RAISE EXCEPTION 'Aucun bloc défini.';
  END IF;

  -- Création / récupération du module
  SELECT id INTO v_module FROM public.modules
   WHERE slug = 'capa-droit-civil-commercial' LIMIT 1;

  IF v_module IS NULL THEN
    INSERT INTO public.modules (
      title, slug, bloc_id, summary, difficulty, duration_min, "order"
    ) VALUES (
      'Droit civil et commercial — bases pour le transporteur',
      'capa-droit-civil-commercial',
      v_bloc,
      'Les fondamentaux juridiques pour créer, gérer et faire évoluer une entreprise de transport léger : formes juridiques, contrats, garanties, procédures collectives.',
      'intermediaire',
      180,
      10
    ) RETURNING id INTO v_module;

    -- Lien formation_modules
    INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
    VALUES (v_formation, v_module, 10, true)
    ON CONFLICT DO NOTHING;
  END IF;

  -- ─── LEÇON 1 : Choisir sa forme juridique ───────────────────────
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'formes-juridiques') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (
      v_module,
      'Choisir sa forme juridique',
      'formes-juridiques',
      1,
      35,
$lesson1$
La forme juridique est le **premier choix structurant** d'une entreprise. Elle détermine votre régime fiscal, votre couverture sociale, votre responsabilité, et même votre capacité d'investissement. Pour un transporteur léger, ce choix conditionne aussi votre rapport aux financements et aux clients.

:::objectifs
- Identifier les **5 formes juridiques** principales adaptées au transport léger.
- Comprendre les **critères de choix** (associés, capital, fiscalité, social).
- Savoir basculer d'une forme à l'autre quand l'activité grandit.
:::

## Les options du transporteur indépendant

Le créateur d'une entreprise de transport léger a globalement 5 voies. Voici la grille de lecture utilisée par les conseillers experts-comptables.

| Forme | Associés | Capital | Statut dirigeant | Responsabilité |
|---|---|---|---|---|
| Auto-entrepreneur | Seul | 0 € | TNS micro | Illimitée |
| EI à l'IR | Seul | 0 € | TNS | Illimitée patrimoine pro/perso |
| EURL | Seul (associé unique) | 1 € min | TNS | Limitée aux apports |
| SASU | Seul (associé unique) | 1 € min | Assimilé-salarié | Limitée aux apports |
| SARL | 2 à 100 | 1 € min | TNS gérant majoritaire | Limitée aux apports |

:::memo
**TNS = Travailleur Non Salarié.** Cotise au régime indépendants (URSSAF + SSI). Charges plus faibles mais protection sociale moindre (pas de chômage, retraite plus modeste).
**Assimilé-salarié.** Cotise au régime général (sauf chômage). Charges plus élevées mais protection identique à un salarié.
:::

## Les 3 critères vraiment décisifs

Vous trouverez en ligne des dizaines de comparatifs. En réalité, **3 critères** suffisent à trancher dans 90 % des cas.

### 1. Êtes-vous seul ou à plusieurs ?

- Seul : SASU ou EURL (pas de SARL).
- À plusieurs : SARL ou SAS.

### 2. Voulez-vous une protection sociale renforcée ?

- Oui (priorité retraite, indemnités journalières) : **SASU** (assimilé-salarié).
- Non, vous privilégiez l'optimisation immédiate : EURL/SARL (TNS).

### 3. Êtes-vous à l'aise avec la complexité administrative ?

- Oui, vous voulez rassurer un investisseur : SAS/SASU (rédaction libre des statuts).
- Non, vous voulez un cadre fixé par la loi : EURL/SARL (cadre légal protecteur).

:::caspratique
**Karim, 32 ans**, ancien chauffeur livreur, lance son activité de coursier-livraison à Meaux. Pas d'associé, projet de salarier sa femme à terme, besoin de financer un VU à 22 000 €.

**Choix recommandé : SASU.**
Pourquoi ?
1. Statut assimilé-salarié → meilleure protection sociale.
2. Possibilité d'évoluer en SAS multi-associés sans transformation lourde.
3. Capacité à lever des fonds plus tard si croissance.
4. TVA récupérable (vs auto-entrepreneur).

**À éviter :** auto-entrepreneur (plafond CA 77 700 € HT atteint en 12 mois si rythme soutenu, pas de récupération TVA, pas de charges déductibles → marge écrasée).
:::

## Quand changer de forme ?

Une transformation est un acte juridique formel (assemblée générale, modification des statuts, dépôt au greffe, parfois rédaction d'un commissaire à la transformation). Elle coûte typiquement 800 à 1 500 €.

Les déclencheurs classiques :

1. **Vous embauchez votre premier salarié** : passez d'auto-entrepreneur à SASU/EURL pour basculer en régime réel.
2. **Vous accueillez un associé** : EURL → SARL, ou SASU → SAS.
3. **Vous franchissez les 250 k€ de CA** : passage à l'IS quasi-systématique pour optimiser.
4. **Vous voulez attirer un investisseur** : SAS s'impose (plus souple).

:::piege
**Erreur fréquente :** créer une SARL parce que "c'est ce que tout le monde fait", sans réfléchir à la **place du conjoint** dans l'entreprise. Si votre conjoint travaille avec vous, le statut de **conjoint collaborateur** ou **conjoint salarié** doit être déclaré. Sans déclaration, en cas de contrôle, les sanctions peuvent atteindre **1 an de prison + 30 000 €** (art. L. 121-4 C. commerce).
:::

:::law code="Code de commerce" article="L. 223-1" date="01/01/2024"
La société à responsabilité limitée est instituée par une ou plusieurs personnes qui ne supportent les pertes qu'à concurrence de leurs apports.
:::

:::law code="Code de commerce" article="L. 227-1" date="01/01/2024"
La société par actions simplifiée peut être instituée par une ou plusieurs personnes. (...) Les statuts fixent les conditions dans lesquelles la société est dirigée.
:::

## En synthèse

Le couple **SASU** (pour démarrer seul) ou **SAS** (à plusieurs) couvre 80 % des cas de figure pour un transporteur léger moderne. L'EURL reste pertinente pour les profils très indépendants qui priorisent le coût social. L'auto-entrepreneur n'est viable qu'en activité accessoire ou en lancement très progressif.

:::conseil
Avant de choisir, **prenez 1 heure avec un expert-comptable**. Cette heure (gratuite chez la plupart des cabinets pour un prospect) vous évitera 5 ans d'erreurs structurelles. Vérifiez aussi les chambres consulaires (CCI, CMA) qui proposent des conseils gratuits.
:::
$lesson1$,
$summary1$
**À retenir**

- 5 formes principales : auto-entrepreneur, EI, EURL, SASU, SARL.
- Le choix se fait sur 3 critères : seul ou à plusieurs / protection sociale / complexité.
- Pour 80 % des cas modernes : SASU (seul) ou SAS (à plusieurs).
- TNS vs assimilé-salarié = différence majeure de protection sociale.
- Conjoint qui travaille = statut obligatoire sous peine de sanctions.
- Une transformation coûte 800–1 500 € mais reste fluide quand l'activité l'exige.
$summary1$
    );
  END IF;

  -- ─── LEÇON 2 : Capacité, immatriculation, démarrage ──────────────
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'immatriculation-demarrage') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (
      v_module,
      'Immatriculation et démarrage : les étapes obligatoires',
      'immatriculation-demarrage',
      2,
      30,
$lesson2$
Une fois la forme juridique choisie, place aux **étapes administratives**. L'erreur la plus coûteuse : démarrer son activité sans immatriculation. C'est un délit pénalement réprimé.

:::objectifs
- Comprendre les **étapes** d'immatriculation au RCS.
- Identifier les **organismes** à contacter et dans quel ordre.
- Anticiper les **délais réels** (pas ceux de la communication officielle).
:::

## La séquence en 6 étapes

1. **Choix du nom** (dénomination sociale). Vérifier la disponibilité INPI (recherche d'antériorité).
2. **Rédaction des statuts** (sauf auto-entrepreneur). 1 à 4 pages typiquement. Modèles disponibles, mais faire relire par un pro pour les SAS/SASU.
3. **Dépôt du capital** sur un compte bancaire bloqué. Attestation délivrée par la banque.
4. **Annonce légale** dans un journal habilité. Coût ~150–250 € selon département.
5. **Dépôt au greffe** du tribunal de commerce (en ligne via guichet-entreprises.fr ou en papier).
6. **Immatriculation au RCS** : SIREN, SIRET, extrait Kbis émis sous 1 à 5 jours ouvrés.

:::memo
**SIREN** : 9 chiffres, identifie l'**entité** (entreprise).
**SIRET** : SIREN + 5 chiffres NIC, identifie l'**établissement** (peut y en avoir plusieurs par entreprise).
**Kbis** : carte d'identité officielle de la société. Demandée par les banques, financeurs, gros clients.
:::

## Les déclarations dans la foulée

L'immatriculation déclenche automatiquement plusieurs notifications, mais quelques formalités restent à faire vous-même.

### Obligatoires dans les 8 jours

- **DPAE (Déclaration Préalable À l'Embauche)** dès que vous embauchez. URSSAF.
- **Affiliation à la médecine du travail**.
- **Souscription d'une assurance RC pro et auto pro** (preuve à présenter pour la licence).

### Obligatoires sous 1 mois

- **Déclaration au registre des transporteurs (DREAL)** : capacité, capacité financière, honorabilité.
- **Souscription au régime de retraite complémentaire** (Agirc-Arrco si SASU/SAS, autre si TNS).

### Recommandées rapidement

- **Compte bancaire pro** : obligatoire dès 10 000 € de CA pour les sociétés. Le mélange compte perso/pro est une faute classique en cas de contrôle.
- **Logiciel de comptabilité** (ou expert-comptable). Indispensable pour la TVA et les déclarations fiscales.

:::caspratique
**Sarah, 28 ans**, lance sa SASU "Express Livraison Île-de-France". Voici son chronogramme réel :

- **Jour 1** : recherche disponibilité du nom à l'INPI. OK.
- **Jour 2** : rédaction des statuts avec son avocat (forfait 600 €).
- **Jour 5** : dépôt du capital 1 000 € chez sa banque (compte bloqué).
- **Jour 7** : annonce légale dans un journal habilité (180 €).
- **Jour 8** : dépôt au greffe en ligne.
- **Jour 11** : Kbis reçu. SIREN/SIRET attribués.
- **Jour 12** : déclaration DREAL en ligne.
- **Jour 18** : licence intérieure reçue.
- **Jour 20** : 1ère facture émise.

**Total :** 3 semaines depuis l'idée. **Coût démarrage** : ~ 1 200 € (statuts + annonce + frais).
:::

:::piege
**Démarrer sans immatriculation = travail dissimulé.** Sanctions : jusqu'à **3 ans de prison + 45 000 € d'amende** (art. L. 8224-1 C. travail). Et pas d'assurance valide en cas d'accident. Risque civil ET pénal.
:::

## Les coûts à anticiper

| Poste | Auto-entr. | SASU | SARL |
|---|---|---|---|
| Statuts (avec accompagnement) | 0 € | 200–800 € | 200–600 € |
| Annonce légale | 0 € | 150–250 € | 150–250 € |
| Greffe | 0 € | 40–60 € | 40–60 € |
| Dépôt capital (frais bancaires) | 0 € | 0–60 € | 0–60 € |
| **Total démarrage** | **0 €** | **400–1 200 €** | **400–1 000 €** |

S'ajoutent : assurances (1 500–3 000 €/an), expert-comptable (1 200–3 000 €/an), comptable (logiciel ~ 250 €/an), capacité financière (1 800 € minimum, à immobiliser).

:::conseil
Beaucoup de chambres consulaires (CCI, CMA) proposent des **stages de préparation à l'installation** gratuits ou peu coûteux (50–200 €). Ils couvrent toutes ces étapes. Très utile pour un premier projet.
:::
$lesson2$,
$summary2$
**À retenir**

- 6 étapes pour s'immatriculer : nom, statuts, capital, annonce légale, dépôt greffe, RCS.
- Délai réel : 2 à 4 semaines de l'idée au 1er jour d'activité.
- Coût total : ~0 € (auto-entrepreneur) à 1 200 € (SASU/SARL).
- DPAE, médecine du travail, RC pro, DREAL : à régler dans les 30 premiers jours.
- Démarrer sans immatriculation = délit pénal (jusqu'à 3 ans + 45 k€).
$summary2$
    );
  END IF;

  -- ─── LEÇON 3 : Les contrats commerciaux ──────────────────────────
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'contrats-commerciaux') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (
      v_module,
      'Les contrats commerciaux du transport',
      'contrats-commerciaux',
      3,
      40,
$lesson3$
Le contrat est l'**ADN juridique** de votre relation commerciale. Bien rédigé, il vous protège des impayés, des contestations de prix et des disputes de responsabilité. Mal rédigé (ou absent), il vous expose à des indemnités plafonnées à votre désavantage.

:::objectifs
- Distinguer **contrat commercial spécifique** vs **contrat type général**.
- Connaître les **mentions obligatoires** d'un contrat de transport.
- Maîtriser les **règles d'indemnisation** en cas de perte ou avarie.
:::

## Le triptyque transport routier

Tout transport repose sur 3 acteurs et 3 obligations.

### Les acteurs

1. **L'expéditeur** : celui qui remet la marchandise.
2. **Le transporteur** : celui qui exécute le transport.
3. **Le destinataire** : celui qui reçoit la marchandise.

### Les obligations réciproques

| Acteur | Obligations principales |
|---|---|
| Expéditeur | Remettre une marchandise correctement emballée et identifiée. Payer le prix (si convenu). |
| Transporteur | Exécuter le transport dans les délais et avec les soins promis. Conserver la marchandise en bon état. |
| Destinataire | Réceptionner la marchandise. Émettre des réserves en cas de problème. |

## Contrat type général vs contrat spécifique

:::memo
**Sans convention écrite**, c'est le **contrat type général** (décret n° 99-269) qui s'applique de plein droit. Avec, vous pouvez **fixer vos propres règles** (dans les limites de l'ordre public).
:::

### Le contrat type général

C'est un contrat réglementaire, applicable par défaut. Il protège minimalement l'expéditeur et fixe :

- Indemnité plafonnée à **23 € HT/kg** (max 750 € par colis) en cas de perte/avarie.
- Indemnité de retard plafonnée au **prix du transport**.
- Délais de réclamation : **3 jours ouvrables** après livraison.

### Le contrat spécifique

Vous le rédigez avec votre client. Pour les transporteurs un peu structurés, c'est un **outil commercial puissant** :

1. **Tarifs fixés** (à la course, au km, au point, au volume…).
2. **Engagement de volume** réciproque.
3. **Indexation gazole/SMIC** (très important en transport, intégrer la clause CNR).
4. **Indemnités spécifiques** négociées.
5. **Procédure de réclamation** mieux définie.

:::caspratique
**Cas de litige réel :** un transporteur livre 50 cartons de pièces auto à un garagiste. À la livraison, un carton est constaté manquant (12 kg, valeur 4 500 € selon facture du fournisseur).

**Sans contrat spécifique → contrat type s'applique :**
- Indemnité = 23 € × 12 kg = **276 €** maximum.
- Le reste (4 500 – 276 = 4 224 €) est à la charge de... l'expéditeur, qui aurait dû déclarer une valeur supérieure ou souscrire une assurance ad valorem.

**Avec contrat spécifique prévoyant une assurance ad valorem :**
- Indemnité au coût réel : 4 500 €.
- Mais prime d'assurance répercutée sur le prix du transport (typiquement +0,5 % de la valeur déclarée).

**Leçon :** un client e-commerce avec marchandises de valeur exigera quasi-systématiquement la 2ème option. Anticipez ce point dès le devis.
:::

## Les mentions obligatoires d'une lettre de voiture

La lettre de voiture est le document qui matérialise le contrat de transport. Elle accompagne physiquement la marchandise.

### Mentions absolument obligatoires

1. Date d'émission.
2. Nom et adresse de l'expéditeur, transporteur, destinataire.
3. Désignation et quantité de la marchandise (poids, nombre de colis).
4. Conditions de paiement.
5. Lieu et date de chargement, lieu de livraison.

### Mentions recommandées (mais utiles)

- Valeur déclarée (déclenche la couverture assurance).
- Instructions spéciales (fragile, température dirigée, ADR…).
- Référence du donneur d'ordre.
- Numéro de bordereau / commande.

:::law code="Code de commerce" article="L. 132-1" date="01/01/2024"
Le commissionnaire de transport est celui qui agit en son nom propre ou sous un nom social pour le compte d'un commettant. Il est garant des avaries et pertes survenues au cours du transport.
:::

:::piege
**L'erreur la plus coûteuse** : ne pas formaliser de **réserves** à la livraison en cas d'anomalie visible (carton ouvert, palette inclinée, traces d'humidité).

Sans réserve écrite et précise sur le bon de livraison, **présomption de bonne livraison** s'applique. Le destinataire perd son recours quasi-systématiquement.

**Bonne pratique :** former les chauffeurs à émettre des réserves "circonstanciées" (pas juste "OK" ou "vu"). Exemple : "Carton n°7 légèrement enfoncé en partie supérieure, à vérifier en interne".
:::

## La signature électronique

Aujourd'hui, **80 % des grands transporteurs** ont basculé sur l'émargement électronique (PDA, smartphone, tablette). Les bénéfices :

- **Preuve horodatée** + géolocalisée → contestation très difficile.
- **Photo de l'état** au déchargement (preuve d'avarie ou de bonne livraison).
- **Signature manuscrite** scannée (recevable juridiquement depuis 2000).
- **Transmission instantanée** au client final, accélérant le paiement.

:::conseil
Si vous n'avez pas encore basculé en électronique, c'est probablement **le meilleur investissement** que vous puissiez faire pour réduire vos litiges. Tarifs : 100–300 € par appareil, +abonnement mensuel.
:::

## En synthèse

Le contrat n'est pas un détail administratif : c'est votre **bouclier financier**. Investir 30 minutes par client à formaliser une convention claire (ou utiliser des CGV solides + un bon de commande) vous fera gagner des milliers d'euros sur la durée.

:::memo
**3 réflexes commerciaux :**
1. Pas de transport sans devis ou contrat signé (même verbal au téléphone, même par message).
2. Émargement systématique à la livraison, avec instructions claires aux chauffeurs.
3. Réclamation par LRAR sous 3 jours en cas de problème.
:::
$lesson3$,
$summary3$
**À retenir**

- 3 acteurs : expéditeur, transporteur, destinataire.
- Sans contrat écrit → contrat type général s'applique (indemnité plafonnée à 23€/kg).
- Avec contrat spécifique → vous fixez vos règles (clauses tarifaires, assurance ad valorem, indexation).
- Lettre de voiture obligatoire : date, parties, marchandise, conditions de paiement.
- Réserves à la livraison = clé pour conserver son recours.
- Émargement électronique : meilleur investissement anti-litiges.
$summary3$
    );
  END IF;

  -- ─── LEÇON 4 : Procédures collectives ────────────────────────────
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'procedures-collectives') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (
      v_module,
      'Procédures collectives : anticiper et faire face aux difficultés',
      'procedures-collectives',
      4,
      35,
$lesson4$
Le transport routier connaît un **taux de défaillance élevé** (2 à 3 fois la moyenne nationale). Comprendre les procédures collectives est essentiel : pour s'en prémunir, mais aussi pour réagir vite quand les difficultés arrivent.

:::objectifs
- Connaître les **3 procédures principales** : sauvegarde, redressement, liquidation.
- Identifier les **signes avant-coureurs** de difficulté.
- Maîtriser le **délai légal de 45 jours** pour déclarer la cessation des paiements.
:::

## Le diagnostic : où en est mon entreprise ?

Avant les procédures, il y a 3 zones critiques à surveiller mensuellement.

### Zone verte : tout va bien

- **Trésorerie positive** sur 90 jours.
- **DSO (délai paiement clients)** < 60 jours.
- **Capacité d'autofinancement** > échéances de remboursement.

### Zone orange : alerte précoce

- Une ou plusieurs factures impayées **> 60 jours**.
- **Découvert bancaire** régulier.
- Retards de **2 mois** sur les charges sociales (URSSAF, retraite).
- Un seul gros client représentant **> 30 %** du CA.

:::piege
**Le piège classique** : croire qu'on peut "rattraper" en serrant les coûts ou en cherchant un nouveau gros contrat. Statistiquement, **70 % des entreprises** en zone orange basculent en rouge en moins de 12 mois si rien ne change.
:::

### Zone rouge : urgence

- **Cessation des paiements** : impossibilité de payer le passif exigible avec l'actif disponible.
- **Saisies** sur le compte bancaire ou matériel.
- Demande de **conciliation** par un fournisseur en colère.

## Les 3 procédures principales

### 1. Procédure de sauvegarde — anticipative

Pour qui ? Les entreprises **encore solvables** mais en difficulté prévisible.

Comment ça marche :
- Demande au tribunal de commerce, gel des dettes pendant l'observation.
- Élaboration d'un plan de sauvegarde sur 5 à 10 ans.
- Le dirigeant **garde la main** sur l'entreprise (vs redressement).

Avantage : **pas de stigmate** majeur, image relativement préservée.

### 2. Redressement judiciaire — correctif

Pour qui ? Entreprise en cessation des paiements **mais redressable**.

Comment ça marche :
- Période d'observation 6 à 18 mois.
- Plan de redressement (continuation par cession ou poursuite d'activité).
- Le tribunal nomme un **administrateur judiciaire** (qui supervise) et un **mandataire** (représentant les créanciers).

Issue : plan validé (l'entreprise survit, étalement des dettes) ou liquidation.

### 3. Liquidation judiciaire — terminal

Pour qui ? Entreprise en cessation des paiements **non redressable**.

Comment ça marche :
- Cession des actifs, paiement des créanciers selon le rang (super-privilégiés > privilégiés > chirographaires).
- Le dirigeant **perd la main**.
- L'entreprise est radiée à la clôture.

:::law code="Code de commerce" article="L. 631-4" date="01/01/2024"
La déclaration de cessation des paiements doit être faite dans les 45 jours qui suivent la cessation des paiements, par le débiteur, à moins qu'il n'ait dans ce délai demandé l'ouverture d'une procédure de conciliation.
:::

## Les sanctions du gérant en cas de retard

Si vous tardez à déclarer une cessation des paiements **avérée**, le tribunal peut prononcer plusieurs sanctions personnelles contre vous.

| Sanction | Durée / impact |
|---|---|
| Faillite personnelle | Jusqu'à 15 ans d'interdiction de gérer |
| Interdiction de gérer | Action séparée, durée variable |
| Comblement de passif | Vous devez régler personnellement les dettes |
| Banqueroute | Si éléments constitutifs (jusqu'à 5 ans + 75 000 €) |

:::caspratique
**SARL TRANSGO** : capital 8 000 €, passif exigible 50 000 €, actif disponible 30 000 €.

**Diagnostic** : cessation des paiements (50 > 30).

**Délai légal** : 45 jours pour déclarer.

**Procédures envisageables :**
- Sauvegarde : trop tard (déjà cessation).
- Redressement : si plan crédible (clients fidèles, contrats signés).
- Liquidation : si impossibilité de redresser.

**Sanctions du gérant si retard de déclaration** :
1. Faillite personnelle (jusqu'à 15 ans).
2. Comblement de passif (les 20 000 € manquants peuvent être à sa charge perso).
3. Banqueroute si dissimulation, comptabilité fictive...

**Le bon réflexe :** dès le seuil franchi, contacter le **tribunal de commerce** (cellule de prévention gratuite) ou un **mandataire ad hoc** (procédure amiable).
:::

## Les outils de prévention

### Mandat ad hoc et conciliation

**Procédures amiables**, confidentielles, sous l'égide du tribunal mais sans publicité. Excellent pour :
- Renégocier avec ses banques.
- Étaler ses dettes sociales/fiscales.
- Restructurer sans alerter le marché.

Coût : ~5 000 à 15 000 € (honoraires du conciliateur), souvent négociables.

### Plan de continuation négocié

Vous proposez à vos créanciers un **étalement amiable** (24 à 60 mois). En cas d'accord, vous évitez la procédure formelle. Marche surtout si vous avez peu de créanciers et qu'ils ont confiance en vous.

:::conseil
**Anticiper, c'est gagner.** Une entreprise qui consulte 6 mois avant la cessation a **70 % de chances** de redresser. Une qui consulte au moment de la cessation : 30 %. Une qui consulte après : 5 %.

Tenez vos comptes à jour mensuellement. Au moindre doute, prenez RDV avec votre expert-comptable, votre banque, et un avocat spécialisé en restructuration.
:::

## En synthèse

3 procédures, 3 niveaux de gravité. La **sauvegarde** est le luxe des prudents, le **redressement** la dernière chance, la **liquidation** la sortie. Le **délai de 45 jours** pour déclarer une cessation des paiements n'est pas négociable. Les sanctions personnelles peuvent être lourdes — jusqu'à perdre son statut d'entrepreneur.
$lesson4$,
$summary4$
**À retenir**

- 3 procédures : sauvegarde (préventive), redressement (correctif), liquidation (terminal).
- Cessation des paiements = passif exigible > actif disponible.
- Délai légal pour déclarer : 45 jours.
- Sanctions du gérant en cas de retard : faillite personnelle (15 ans), comblement de passif, banqueroute.
- Outils amiables préférables : mandat ad hoc, conciliation.
- Anticiper 6 mois à l'avance = 70 % de chances de redresser.
$summary4$
    );
  END IF;

  -- ─── LEÇON 5 : Synthèse + cas pratiques ──────────────────────────
  IF NOT EXISTS (SELECT 1 FROM public.lessons WHERE module_id = v_module AND slug = 'cas-pratiques-synthese') THEN
    INSERT INTO public.lessons (module_id, title, slug, "order", duration_min, content_md, summary_md)
    VALUES (
      v_module,
      'Cas pratiques de synthèse',
      'cas-pratiques-synthese',
      5,
      40,
$lesson5$
Cette leçon de synthèse vous propose **5 cas pratiques** inspirés de situations réelles, qui mobilisent l'ensemble des notions vues dans le module. Travaillez chaque cas en autonomie, puis comparez avec les corrigés.

:::objectifs
- Mobiliser les notions juridiques et commerciales dans des **cas concrets**.
- S'entraîner à un **raisonnement juridique** structuré (faits → règle → application → solution).
- Identifier les **pièges classiques** des examinateurs.
:::

## Cas n° 1 — Le coursier qui démarre

**Faits :** Sami, 26 ans, ancien chauffeur livreur, lance son activité de coursier à Lille. Il a 3 000 € d'épargne, pas d'associé, prévoit d'embaucher sa cousine en CDD dans 6 mois pour la gestion administrative. Il vise un CA de 60 000 € la 1ère année.

**Question :** quelle forme juridique recommandez-vous, et pourquoi ?

:::caspratique
**Analyse :**
- 1 personne au démarrage → exclu : SARL.
- Embauche prévue rapidement → exclu : auto-entrepreneur (limite 1 salarié).
- CA 60 000 € < seuils auto-entrepreneur (77 700 €) mais en croissance.
- Protection sociale souhaitable → SASU (assimilé-salarié).

**Réponse : SASU** avec capital 1 000 € (épargne en partie immobilisée).
- Fiscalité : option à l'IR pendant 5 ans pour étaler, puis IS.
- Statut : assimilé-salarié, charges environ 60 % du salaire net.
- Embauche cousine : DPAE, contrat CDD encadré.
:::

## Cas n° 2 — Le contrat verbal qui tourne mal

**Faits :** depuis 3 ans, vous travaillez avec une fromagerie locale. Aucun contrat écrit, juste un accord verbal sur des prix. La fromagerie demande aujourd'hui une remise de 8 % "rétroactive" sur les 6 derniers mois, sous peine de cesser la collaboration.

**Question :** que dit le droit, et que pouvez-vous faire ?

:::caspratique
**Analyse juridique :**
1. **Sans contrat écrit** : application du contrat type général (décret n° 99-269).
2. **Pas de remise rétroactive légale** sans accord express. Une remise rétroactive = renégociation d'un prix déjà accepté = non opposable sans accord écrit.
3. **Mais** : la fromagerie est un client important. Risque commercial réel.

**Stratégie :**
- Refuser la rétroactivité (juridiquement inattaquable).
- Proposer une **remise prospective** sur 12 mois moyennant un **engagement de volume** (ex : 8 % de remise pour 100+ courses/mois garanties).
- **Formaliser par écrit** la nouvelle convention (durée, prix, volumes, indexation).

**Leçon :** chaque contrat verbal ancien = bombe à retardement. Profiter de cet incident pour **régulariser tous les contrats verbaux**.
:::

## Cas n° 3 — Le sinistre coûteux

**Faits :** votre chauffeur livre 24 colis à un magasin de bricolage. À la réception, le magasin signe le bon de livraison "OK". Le lendemain, le magasin appelle : 3 colis sont introuvables, valeur déclarée 800 € chacun, soit 2 400 €.

**Questions :**
1. Êtes-vous responsable ?
2. Sous quelles conditions, et quelle indemnité ?
3. Que faire ?

:::caspratique
**Analyse :**
1. **Bon de livraison signé "OK" sans réserve** → présomption de bonne livraison (art. 27 CTG). Le destinataire a 3 jours ouvrables pour formuler réserves.
2. Si réserve faite dans le délai et **prouvée** (constat, photos, témoignages) :
   - Application du CTG : 23 €/kg max ou 750 €/colis. Probable indemnité ~ 750 € × 3 = 2 250 € si poids significatif.
3. Dans la pratique :
   - Réceptionner la réclamation, demander preuves.
   - Vérifier la lettre de voiture (poids, état initial).
   - Contacter votre assurance RC marchandise transportée.
   - Tenter une transaction amiable.

**Leçon :** la formation de votre chauffeur sur l'**émargement électronique avec photos** vaut son pesant d'or. Une photo des colis en bon état = preuve recevable.
:::

## Cas n° 4 — La capacité financière en jeu

**Faits :** votre entreprise a 4 véhicules. Trésorerie : 6 000 €. Vous voulez embaucher un 5ème véhicule. Capacité financière requise : 1 800 + 4 × 900 = **5 400 €**.

**Question :** votre entreprise est-elle conforme ? Si non, quelles solutions ?

:::caspratique
**Analyse :**
- Capacité requise pour 5 véhicules : 5 400 €.
- Trésorerie : 6 000 €.
- **À première vue conforme**, mais la trésorerie n'est pas la même chose que la **capacité financière justifiée**. Cette dernière doit être :
  - Soit en **fonds propres** au bilan (capital + réserves + report à nouveau).
  - Soit en **caution bancaire** spécifique (pas la trésorerie courante).

**Solutions :**
1. **Renforcer les fonds propres** : ne pas distribuer de bénéfice, augmenter le capital social.
2. **Souscrire une caution bancaire** : 1 à 3 % du montant cautionné par an. Coût : ~ 100–200 €/an.
3. **Reporter l'achat** du 5ème véhicule jusqu'à fonds propres suffisants.

**Piège :** si vous justifiez avec votre trésorerie courante au moment du contrôle DREAL, vous risquez la **suspension de licence** quelques mois plus tard si la trésorerie a baissé.
:::

## Cas n° 5 — La faillite qui menace

**Faits :** SARL TRANSEXPRESS, 3 ans, capital 8 000 €. État au 30 juin :
- Passif exigible : 75 000 € (40 000 fournisseurs + 35 000 URSSAF).
- Actif disponible : 25 000 € (banque) + 12 000 € (créances clients à échéance < 30j).
- 4 véhicules immobilisés (mais non liquides court terme).

**Questions :**
1. Êtes-vous en cessation des paiements ?
2. Quelle est l'urgence ?
3. Quelles options ?

:::caspratique
**Analyse :**
1. **Cessation des paiements** : passif exigible 75 000 € > actif disponible 37 000 € (25 + 12). **Oui**, par 38 000 €.
2. **Délai légal** : déclaration au tribunal sous **45 jours** depuis la cessation effective.
3. **Options** :
   - **Conciliation** (procédure amiable, confidentielle) si vous pensez pouvoir négocier avec vos créanciers principaux. Coût ~ 5 000 €.
   - **Redressement judiciaire** : si l'activité reste viable (carnet de commandes, contrats signés). Période d'observation, plan sur 10 ans max.
   - **Liquidation** : si impossibilité réelle de redresser.

**Mauvais réflexes :**
- Ne **pas** déclarer dans les 45 jours = risque de **faillite personnelle** + comblement de passif.
- Ne **pas** vendre des biens "sous le manteau" = constitutif de **banqueroute** (5 ans + 75 k€).

**Bon réflexe :**
- Prendre RDV **demain** avec un avocat en restructuration et le tribunal de commerce (cellule prévention).
- Préparer dossier : derniers bilans, situation comptable, contrats, créanciers.
:::

## En synthèse du module

Vous avez maintenant les fondations juridiques pour :
1. **Choisir** sereinement votre forme juridique.
2. **Démarrer** votre entreprise en respectant les obligations.
3. **Sécuriser** vos relations commerciales par des contrats solides.
4. **Détecter** et **réagir** aux difficultés avant qu'elles ne soient irréversibles.

:::conseil
**Le réflexe d'or :** un **point trimestriel** de 30 minutes avec votre expert-comptable. Coût : marginal. Bénéfice : voir venir les problèmes 6 mois à l'avance, ce qui change tout.
:::
$lesson5$,
$summary5$
**À retenir — Synthèse module**

- 5 cas pratiques couvrent l'ensemble du module Droit civil et commercial.
- Forme juridique = arbitrage seul/à plusieurs × protection sociale × complexité.
- Contrat écrit = bouclier financier ; sans contrat = contrat type général s'applique.
- Émargement électronique avec photos = preuve recevable, anti-litige.
- Capacité financière : fonds propres OU caution bancaire (pas la trésorerie courante).
- Cessation des paiements = passif exigible > actif disponible. 45 jours pour déclarer.
- Anticipation = clé : un point trimestriel avec l'expert-comptable change tout.
$summary5$
    );
  END IF;

  RAISE NOTICE 'Module A (Capa -3,5T - Droit) enrichi : 5 leçons premium créées.';
END
$mod_a$;
