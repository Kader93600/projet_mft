-- =====================================================================
-- TAXI / VTC (T3P) : MODULE 2 : TAXI ET VTC, DEUX RÉGIMES À MAÎTRISER
-- v1 (juillet 2026) : LOT TAXI-VTC
-- Angle candidat : maraude et réservation préalable, ADS et registre
-- VTC, tarification réglementée contre prix libre, comparés point
-- par point pour l'examen T3P.
-- ⚠ STATUT : active = false (« à valider »). Idempotent.
-- =====================================================================

DO $taxim2$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_l4 uuid;
  v_quiz uuid; v_q uuid; v_ord int := 0;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'taxi-vtc';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation taxi-vtc introuvable.'; END IF;

  INSERT INTO public.blocs (id, code, title, description, "order") VALUES (50, 'TAXI-VTC', 'Taxi et VTC : transport public particulier de personnes', 'Préparation aux examens taxi et VTC (T3P) organisés par les chambres de métiers et de l''artisanat : épreuves communes, spécifiques et pratique.', 50) ON CONFLICT DO NOTHING;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'TAXI-VTC';

  DELETE FROM public.question_bank WHERE source_ref LIKE 'TAXI-M2-%';
  DELETE FROM public.modules WHERE slug = 'taxi-vtc-deux-regimes';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 2 : Taxi et VTC, deux régimes à maîtriser',
    'taxi-vtc-deux-regimes', v_bloc,
    'Maraude et réservation préalable, ADS et registre VTC, tarification réglementée contre prix libre : les deux régimes du T3P comparés point par point.',
    'intermediaire', 300, 20) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 20, true);

  -- ─── Leçon 1 : Maraude ou réservation préalable ─────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'maraude-vs-reservation',
    'Maraude ou réservation préalable : la frontière entre deux métiers',
    $mft$> 🎯 **Objectifs**
> - Définir la maraude et expliquer pourquoi elle est réservée aux taxis.
> - Identifier la réservation préalable comme seul mode d'activité du VTC.
> - Trancher correctement les scénarios de frontière : client qui hèle, files de gare, applications de mise en relation.

## Deux métiers séparés par un mode de prise en charge

Le taxi et le VTC transportent les mêmes passagers, souvent dans les mêmes rues, parfois dans des véhicules identiques. Ce qui les sépare juridiquement n'est ni le confort ni le prix : c'est le mode de rencontre avec le client. Le taxi peut être choisi sur place, dans l'instant ; le VTC doit avoir été réservé avant. Toute l'architecture du transport public particulier de personnes (T3P) découle de cette ligne de partage, et l'examen adore la tester sur des cas concrets.

## Le monopole de la maraude

La maraude recouvre deux situations : la **prise en charge immédiate** d'un client sur la voie publique (le passant qui lève le bras) et le **stationnement en attente de clientèle** (la station devant la gare, la tête de station à l'aéroport). Ces deux prérogatives appartiennent exclusivement aux **taxis**. Elles ne s'exercent pas partout : chaque taxi maraude dans la **commune ou la zone de rattachement de son autorisation de stationnement (ADS)**, que la leçon suivante détaille. Hors de ce périmètre, la prise en charge suppose une réservation.

> 📌 **À retenir**
> Maraude = prise en charge immédiate sur la voie publique + stationnement en attente de clientèle, dans la zone de rattachement de l'ADS. Les deux volets sont indissociables du statut de taxi.

## La maraude électronique : le smartphone n'abolit pas la règle

Une application qui montre au client les véhicules disponibles autour de lui, pour une prise en charge immédiate sans réservation, reproduit la maraude sous forme numérique : on parle de **maraude électronique**. Elle est réservée aux taxis, exactement comme la maraude de rue. Un exploitant VTC ne peut donc pas afficher ses voitures « libres autour de vous » pour un départ immédiat : ce serait s'approprier le monopole des taxis par écran interposé.

## La réservation préalable, cœur du métier VTC

:::flow
1. Réservation | Le client commande sa course avant la prise en charge (application, centrale, téléphone, comptoir d'hôtel)
2. Confirmation | La course est enregistrée : lieu de prise en charge, destination, prix convenu (leçon 4)
3. Rendez-vous | Le conducteur rejoint le point convenu et attend SON client, sans proposer ses services à d'autres
4. Course | La prestation exécute la réservation, rien de plus, rien de moins
:::

Point essentiel : la réservation préalable n'impose pas de délai minimal. Une course commandée quelques minutes avant la prise en charge reste une course réservée, dès lors que la réservation précède la rencontre. Ce qui est interdit au VTC, c'est la rencontre SANS réservation.

## Les scénarios de frontière

| Situation | Conduite correcte |
| --- | --- |
| Un passant hèle votre VTC | Refuser courtoisement, l'inviter à réserver (application, centrale) |
| Un voyageur s'assoit dans votre VTC sans réservation | Ne pas démarrer : pas de réservation, pas de course |
| File de la gare réservée aux taxis | Interdite au VTC, même « deux minutes » : attendre son client réservé hors de la zone |
| Client d'hôtel qui veut partir tout de suite | Possible si une réservation est enregistrée avant la prise en charge |
| Application montrant les véhicules libres alentour pour départ immédiat | Maraude électronique : réservée aux taxis |

> ❌ **Piège à éviter**
> « Il était déjà assis dans la voiture, je n'allais pas le faire descendre. » Si : sans réservation préalable, le VTC qui démarre exerce illégalement la maraude, avec les sanctions et les risques commerciaux qui suivent (plateforme, assurance, contrôles).

> 💡 **Astuce d'examen**
> Devant un cas pratique, posez-vous une seule question : la réservation existait-elle AVANT la rencontre entre le client et la voiture ? Oui : le VTC peut rouler. Non : seul un taxi, dans sa zone de rattachement, pouvait prendre ce client.

## ✅ Synthèse

- La **maraude** (prise en charge immédiate + stationnement en attente de clientèle) est le **monopole des taxis**, dans la commune ou zone de rattachement de l'ADS.
- La **maraude électronique** est réservée aux taxis : une application de « prise immédiate » ne change pas la règle.
- Le **VTC ne travaille que sur réservation préalable**, même passée quelques minutes avant : la réservation doit précéder la rencontre.
- Files de gare et d'aéroport réservées aux taxis : le VTC attend son client réservé ailleurs.$mft$,
    $mft$Le monopole de la maraude des taxis (prise en charge immédiate et stationnement en attente, dans la zone de rattachement de l'ADS), la maraude électronique réservée aux taxis, la réservation préalable du VTC et les scénarios de frontière.$mft$,
    1, 40) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : L'ADS du taxi ────────────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'ads-taxi',
    'L''ADS : le sésame du taxi délivré par le maire',
    $mft$> 🎯 **Objectifs**
> - Décrire le régime des nouvelles ADS issu de la loi Thévenoud.
> - Distinguer les ADS anciennes (cessibles) des nouvelles (incessibles).
> - Connaître le parcours du candidat : carte professionnelle, liste d'attente, exploitation personnelle.

## Une autorisation délivrée par le maire

L'autorisation de stationnement (ADS) est le titre qui permet au taxi de marauder et de stationner en attente de clientèle sur la voie publique. Elle est **délivrée par le maire**. Sans ADS, pas de station et pas de maraude : la carte professionnelle atteste de l'aptitude du conducteur, l'ADS ouvre le territoire. Les deux se complètent, elles ne se remplacent pas.

## Avant et après la loi Thévenoud

:::timeline
Avant 2014 | Les ADS délivrées sous l'ancien régime sont cessibles : elles se revendent, et un marché du rachat s'est constitué, avec des prix très variables selon les villes
2014 : loi Thévenoud | Les NOUVELLES ADS deviennent incessibles : délivrées gratuitement, pour 5 ans renouvelables, à un conducteur titulaire de la carte professionnelle de taxi
Aujourd'hui | Les deux régimes coexistent : les anciennes ADS continuent de se revendre, les nouvelles restent attachées à leur titulaire
:::

## Le régime des nouvelles ADS

| Caractéristique | Nouvelle ADS (depuis la loi Thévenoud) |
| --- | --- |
| Coût de délivrance | Gratuite |
| Durée | 5 ans, renouvelables |
| Cession | Incessible : ne se revend pas, ne se transmet pas |
| Bénéficiaire | Conducteur titulaire de la carte professionnelle de taxi |
| Cumul | Une seule ADS par personne |
| Exploitation | Personnelle : le titulaire conduit lui-même |

L'esprit du texte : sortir l'accès au métier de la spéculation. La nouvelle ADS est une autorisation d'exercer, pas un actif à revendre. Elle se demande, elle s'exploite, elle se renouvelle ; elle ne se monnaye pas.

## Les ADS anciennes : un patrimoine qui subsiste

Les ADS délivrées avant 2014 restent **cessibles** : leur titulaire peut les revendre, et beaucoup comptent sur cette revente pour financer leur retraite. Ce marché du rachat constitue la seconde voie d'accès au métier : acheter une ADS ancienne coûte cher mais évite l'attente. Deux populations de taxis coexistent donc durablement dans les mêmes stations : des chauffeurs qui ont investi un capital dans leur autorisation, et des entrants qui ont obtenu la leur gratuitement mais sans valeur patrimoniale.

## Obtenir sa première ADS : la liste d'attente

Le candidat qui vise une ADS nouvelle s'inscrit sur la **liste d'attente tenue en mairie**. Le délai dépend du nombre de demandes et des autorisations qui se libèrent : il varie fortement d'une commune à l'autre. D'où l'arbitrage classique du candidat : attendre une ADS gratuite, ou acheter une ADS ancienne pour démarrer tout de suite.

> ⚠️ **Point de vigilance**
> Une ADS nouvelle, gratuite, ne se revend JAMAIS, même après des années d'exploitation. Le candidat qui compare « acheter une ancienne » et « attendre une nouvelle » compare aussi deux stratégies patrimoniales : l'une immobilise un capital récupérable à la revente (au prix du marché du moment), l'autre ne coûte rien mais ne vaudra jamais rien à la revente.

## Doublage et relais : prudence

Certaines organisations locales permettent qu'un même véhicule ou une même autorisation serve à plusieurs conducteurs qui se relaient (pratiques dites de doublage ou de relais). Ces possibilités dépendent des **règlements locaux** : avant d'organiser un relais, ce point est à vérifier auprès de l'autorité qui a délivré l'ADS et dans le règlement applicable à votre commune.

> 🔍 **Zoom examen**
> Les examinateurs aiment croiser les critères : qui délivre (le maire), à qui (un titulaire de la carte taxi), pour quel coût (gratuite), pour combien de temps (5 ans renouvelables), cessible ? (non pour les nouvelles, oui pour les anciennes d'avant 2014), combien par personne (une seule), qui conduit (le titulaire : exploitation personnelle).

## ✅ Synthèse

- L'ADS est délivrée par **le maire** ; elle conditionne maraude et stationnement (leçon 1).
- **Nouvelles ADS** (loi Thévenoud) : **gratuites, incessibles, 5 ans renouvelables**, une seule par personne, **exploitation personnelle**, réservées aux titulaires de la carte taxi.
- **ADS d'avant 2014** : cessibles, marché du rachat, enjeu patrimonial fort.
- Première ADS : **liste d'attente en mairie** ; doublage et relais : selon les règlements locaux, **à vérifier**.$mft$,
    $mft$L'ADS délivrée par le maire : régime des nouvelles autorisations (gratuites, incessibles, 5 ans renouvelables, exploitation personnelle), cessibilité maintenue des ADS d'avant 2014, liste d'attente en mairie et prudence sur le doublage.$mft$,
    2, 40) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : Le registre des VTC ──────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'registre-vtc',
    'Le registre des VTC : exister légalement comme exploitant',
    $mft$> 🎯 **Objectifs**
> - Situer le REVTC : l'inscription obligatoire de l'exploitant VTC.
> - Réunir les justificatifs et anticiper le renouvellement quinquennal.
> - Vérifier la conformité des véhicules aux conditions techniques fixées par décret.

## Le registre : la porte d'entrée de l'exploitant VTC

Là où le taxi obtient une ADS auprès du maire, l'exploitant VTC s'inscrit au **registre national des VTC (REVTC)**, tenu par l'administration. Cette inscription est le préalable à toute activité : sans inscription au registre, pas d'exploitation légale. Elle concerne l'**exploitant** (l'entreprise), à ne pas confondre avec la carte professionnelle, qui concerne le conducteur. Un même dossier peut donc mobiliser les deux : la carte pour conduire, le registre pour exploiter.

## L'inscription pas à pas

:::flow
1. Réunir les justificatifs | Carte professionnelle, assurance RC professionnelle, immatriculation de l'entreprise, garantie financière ou justificatifs de propriété ou de location du véhicule (modalités exactes à vérifier dans les textes)
2. Déposer la demande | Inscription au REVTC auprès de l'administration, avec paiement des frais d'inscription
3. Obtenir l'inscription | L'exploitant figure au registre : l'activité peut commencer
4. Renouveler | L'inscription est renouvelable tous les 5 ans : anticiper l'échéance
:::

## Les justificatifs demandés

| Pièce | Ce qu'elle prouve |
| --- | --- |
| Carte professionnelle | L'aptitude du conducteur à exercer dans le T3P |
| Assurance RC professionnelle | La couverture des dommages liés à l'activité |
| Immatriculation de l'entreprise | L'existence juridique de l'exploitant |
| Garantie financière ou justificatifs de propriété ou de location du véhicule | La consistance matérielle de l'exploitation (modalités à vérifier dans les textes) |

> ⚠️ **Frais d'inscription**
> L'inscription au REVTC donne lieu à des frais dont le montant est fixé par arrêté : vérifiez le montant en vigueur au moment de votre démarche, il évolue par voie réglementaire. À l'examen comme en gestion, citez la source (arrêté) plutôt qu'un chiffre incertain.

## Cinq ans, puis on recommence

L'inscription au REVTC n'est pas définitive : elle se **renouvelle tous les 5 ans**. L'exploitant qui laisse passer l'échéance se retrouve hors registre, donc hors la loi, même si son activité n'a pas changé d'un iota. Le réflexe professionnel : noter la date d'échéance le jour même de l'inscription, prévoir la mise à jour des justificatifs (assurance, véhicules) et ne jamais découvrir le renouvellement au moment d'un contrôle.

## Les véhicules : des conditions techniques fixées par décret

Les véhicules affectés à une activité VTC doivent respecter des conditions techniques fixées par **décret** : nombre de places, dimensions, ancienneté, puissance. Nous ne citons volontairement aucun chiffre ici : ces seuils sont fixés par les textes et susceptibles d'évoluer, vérifiez les valeurs en vigueur avant tout achat de véhicule. Retenez la logique : le VTC doit offrir une prestation d'une certaine tenue, donc un véhicule ni trop petit, ni trop ancien, ni sous-motorisé. Des **dérogations existent pour les véhicules hybrides et électriques** : là encore, le périmètre exact des dérogations est à vérifier dans les textes.

> ❌ **Erreur classique**
> Acheter d'abord, vérifier ensuite. Un véhicule non conforme (trop ancien, dimensions insuffisantes, puissance inadaptée) ne pourra pas être exploité : la vérification réglementaire précède l'investissement, jamais l'inverse.

> 🎓 **Réflexe professionnel**
> Le bon candidat ne récite pas des seuils appris par cœur et peut-être périmés : il sait QUI fixe la règle (décret pour les véhicules, arrêté pour les frais) et OÙ la vérifier. C'est exactement ce que valorisent les correcteurs, et ce qui évite les mauvaises surprises à l'exploitant.

## ✅ Synthèse

- L'exploitant VTC s'inscrit au **REVTC**, registre national tenu par l'administration : préalable à toute activité.
- Inscription **renouvelable tous les 5 ans** ; **frais fixés par arrêté** (montant à vérifier).
- Justificatifs : **carte professionnelle, RC professionnelle, immatriculation de l'entreprise, garantie financière ou justificatifs de propriété/location du véhicule** (modalités à vérifier).
- Véhicules : conditions techniques **fixées par décret** (places, dimensions, ancienneté, puissance), **dérogations hybrides/électriques**, chiffres à vérifier dans les textes en vigueur.$mft$,
    $mft$L'inscription de l'exploitant au registre national des VTC (REVTC) : justificatifs, frais fixés par arrêté, renouvellement tous les 5 ans, et conditions techniques des véhicules fixées par décret avec dérogations hybrides/électriques.$mft$,
    3, 40) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : Tarification comparée ────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'tarification-comparee',
    'Compteur réglementé contre prix libre : deux logiques tarifaires',
    $mft$> 🎯 **Objectifs**
> - Décomposer le prix réglementé d'une course de taxi.
> - Expliquer la formation du prix libre d'une course VTC.
> - Tirer les conséquences commerciales des deux modèles.

## Deux philosophies du prix

Le taxi vend au prix fixé par la puissance publique ; le VTC vend au prix qu'il annonce. Cette opposition n'est pas un détail comptable : elle structure la relation client, la concurrence et jusqu'à l'équipement du véhicule. L'examen la teste sous tous les angles, du calcul de course au cas de litige tarifaire.

## Le taxi : un prix réglementé, mesuré, affiché

Le prix d'une course de taxi est **réglementé par arrêté**. Le véhicule embarque un **compteur horokilométrique obligatoire** (le taximètre), qui mesure la course selon la grille en vigueur.

:::flow
1. Prise en charge | Montant forfaitaire enclenché au départ de la course
2. Parcours | Kilomètres facturés au tarif A, B, C ou D, selon jour ou nuit et selon la logique aller/retour
3. Suppléments | Uniquement ceux prévus et encadrés par l'arrêté
4. Note | Justificatif remis au client : obligatoire au-delà d'un seuil de prix (montant à vérifier)
:::

Les quatre positions tarifaires (A, B, C, D) croisent deux critères : le moment de la course (jour ou nuit) et la logique aller/retour du trajet. La correspondance exacte des lettres et les montants figurent dans l'arrêté et sur l'**affichage obligatoire** à bord : le client doit pouvoir lire la grille depuis la banquette.

> 📌 **À retenir**
> Réglementé ne veut pas dire opaque : compteur obligatoire, grille affichée, suppléments limités à ceux de l'arrêté, note au-delà d'un seuil (montant à vérifier). La transparence du taxi tient à ses instruments.

## Le VTC : un prix libre, mais fixé AVANT

Le prix du VTC est **libre** : c'est l'exploitant qui le détermine. En contrepartie, il est **fixé avant la course** : forfait annoncé à la réservation ou devis accepté par le client. Pas de compteur à bord. Le client sait ce qu'il paiera avant de monter ; l'exploitant porte le risque du trajet (trafic, détours) mais gagne la liberté commerciale : tarifs différenciés selon les heures, la gamme, la clientèle.

> ⚠️ **L'interdiction miroir**
> Le VTC ne peut pas facturer à la durée et à la distance parcourues « à la manière d'un taximètre » : ce mode de calcul, qui découvre le prix à l'arrivée, est en principe exclu du modèle VTC ; des exceptions existent (à vérifier dans les textes), mais le principe demeure : prix VTC = prix convenu avant la course.

## Tableau comparatif

| Critère | Taxi | VTC |
| --- | --- | --- |
| Qui fixe le prix | L'arrêté (prix réglementé) | L'exploitant (prix libre) |
| Quand le client le connaît | À l'arrivée (compteur) | Avant la course (forfait ou devis) |
| Instrument | Compteur horokilométrique obligatoire | Pas de compteur |
| Composantes | Prise en charge + km (A/B/C/D) + suppléments encadrés | Forfait ou devis global |
| Documents | Affichage obligatoire, note au-delà d'un seuil (à vérifier) | Prix annoncé à la réservation |
| Risque trafic | Plutôt côté client (le compteur tourne) | Côté exploitant (forfait garanti) |

## Conséquences commerciales

Dans le modèle taxi, pas de guerre des prix : la grille est la même pour tous, et le chauffeur se différencie par le service, la disponibilité et la connaissance de sa zone. Dans le modèle VTC, le prix devient un argument commercial : gammes, heures creuses, offres de fidélisation, mais aussi concurrence frontale entre exploitants et pression des plateformes sur les marges. Le taxi rassure (prix contrôlé par la puissance publique), le VTC séduit (prix connu d'avance, quel que soit le trafic). Aucun des deux modèles n'est « meilleur » : ils exécutent deux promesses différentes faites au client.

> 💡 **Astuce d'examen**
> Reliez toujours l'instrument au régime : compteur = prix réglementé = taxi ; forfait annoncé avant la course = prix libre = VTC. Un énoncé qui mélange les deux (un VTC « au compteur », un taxi « au forfait librement négocié ») décrit une anomalie à dénoncer.

## ✅ Synthèse

- Taxi : **prix réglementé par arrêté**, **compteur horokilométrique obligatoire**, prise en charge + kilomètres **A/B/C/D** (jour/nuit, aller/retour) + **suppléments encadrés**, **affichage obligatoire**, note au-delà d'un seuil (**à vérifier**).
- VTC : **prix libre**, **fixé avant la course** (forfait à la réservation ou devis), **pas de compteur**.
- Interdit au VTC de facturer durée + distance **à la manière d'un taximètre** (exceptions **à vérifier**).
- Commercialement : le taxi vend un prix **contrôlé**, le VTC un prix **connu d'avance**.$mft$,
    $mft$Le prix réglementé du taxi (arrêté, compteur horokilométrique, prise en charge + tarifs A/B/C/D + suppléments encadrés, affichage, note au-delà d'un seuil) face au prix libre du VTC fixé avant la course, et leurs conséquences commerciales.$mft$,
    4, 40) RETURNING id INTO v_l4;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : taxi et VTC, deux régimes',
    'Vérifiez le module 2 : maraude et réservation préalable, ADS, registre des VTC, tarification comparée.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Vous conduisez un VTC sans course en cours. Un passant vous hèle sur la voie publique pour un trajet court. Que faites-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Vous refusez et l'invitez à réserver via une application ou une centrale : sans réservation préalable, pas de prise en charge","is_correct":true},
      {"id":"b","label":"Vous acceptez : la course est courte et le véhicule est libre","is_correct":false},
      {"id":"c","label":"Vous acceptez à condition d'être payé en espèces","is_correct":false},
      {"id":"d","label":"Vous acceptez si aucun taxi n'est visible dans la rue","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-2','qcm-v1'], 'TAXI-M2-QCM-01', false,
    $mft$Prendre un client qui hèle relève de la maraude, monopole des taxis : ni la durée de la course, ni le mode de paiement, ni l'absence de taxis alentour ne créent d'exception pour le VTC.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Titulaire de la carte professionnelle de taxi, vous obtenez en 2025 une ADS délivrée par le maire de votre commune. Quelles sont ses caractéristiques ?$mft$,
    $mft$[
      {"id":"a","label":"Gratuite, incessible, valable 5 ans renouvelables, à exploiter personnellement","is_correct":true},
      {"id":"b","label":"Payante et cessible immédiatement à un autre chauffeur","is_correct":false},
      {"id":"c","label":"Gratuite et transmissible à vos héritiers","is_correct":false},
      {"id":"d","label":"Valable sur tout le territoire national, sans rattachement","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-2','qcm-v1'], 'TAXI-M2-QCM-02', false,
    $mft$Depuis la loi Thévenoud, les nouvelles ADS sont gratuites, incessibles, délivrées pour 5 ans renouvelables et exploitées personnellement : elles ne se revendent ni ne se transmettent, et restent rattachées à une commune ou zone.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Vous venez d'immatriculer votre société pour exploiter des VTC. Quelle démarche conditionne le démarrage légal de l'activité ?$mft$,
    $mft$[
      {"id":"a","label":"L'inscription au registre national des VTC (REVTC) tenu par l'administration","is_correct":true},
      {"id":"b","label":"Une demande d'autorisation de stationnement auprès du maire","is_correct":false},
      {"id":"c","label":"Un simple courrier d'information à la préfecture","is_correct":false},
      {"id":"d","label":"Aucune : travailler via une application dispense d'enregistrement","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-2','qcm-v1'], 'TAXI-M2-QCM-03', false,
    $mft$L'exploitant VTC doit figurer au REVTC avant toute activité : l'ADS concerne les taxis, un courrier ne vaut pas inscription, et passer par une application ne dispense de rien.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Une cliente réserve un VTC pour un trajet de la gare vers l'aéroport. Comment le prix de sa course est-il déterminé ?$mft$,
    $mft$[
      {"id":"a","label":"Librement par l'exploitant, mais fixé et annoncé avant la course (forfait ou devis)","is_correct":true},
      {"id":"b","label":"Au compteur horokilométrique pendant le trajet","is_correct":false},
      {"id":"c","label":"Par la grille tarifaire d'un arrêté","is_correct":false},
      {"id":"d","label":"À l'arrivée, selon la durée réelle constatée","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-2','qcm-v1'], 'TAXI-M2-QCM-04', false,
    $mft$Le prix VTC est libre mais fixé avant la course (forfait ou devis) : le compteur et la grille par arrêté appartiennent au régime taxi, et le calcul à l'arrivée contredit le principe du prix convenu d'avance.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Une application affiche en temps réel les véhicules disponibles autour du client pour une prise en charge immédiate, sans réservation. Qui peut légalement y proposer ses services ?$mft$,
    $mft$[
      {"id":"a","label":"Uniquement les taxis : il s'agit de maraude électronique","is_correct":true},
      {"id":"b","label":"Les taxis et les VTC, puisque tout passe par un smartphone","is_correct":false},
      {"id":"c","label":"Uniquement les VTC, spécialistes des applications","is_correct":false},
      {"id":"d","label":"Tout conducteur du T3P titulaire d'une carte professionnelle","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-2','qcm-v1'], 'TAXI-M2-QCM-05', false,
    $mft$Montrer les véhicules disponibles alentour pour une prise immédiate est de la maraude électronique, réservée aux taxis : le support numérique ne change pas la nature de la prise en charge, et la carte professionnelle seule ne suffit pas.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Conducteur VTC devant une gare : votre client réservé arrive dans dix minutes et la file d'attente réservée aux taxis est à moitié vide. Que faites-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Vous attendez hors de la zone réservée aux taxis, au point convenu avec votre client","is_correct":true},
      {"id":"b","label":"Vous vous insérez dans la file : elle est à moitié vide et votre client arrive","is_correct":false},
      {"id":"c","label":"Vous prenez un voyageur de la file en attendant votre client","is_correct":false},
      {"id":"d","label":"Vous stationnez en tête de file avec les feux de détresse","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-2','qcm-v1'], 'TAXI-M2-QCM-06', false,
    $mft$La file de la gare relève du stationnement en attente de clientèle, attribut de la maraude : le VTC attend son client réservé hors de la zone, sans y stationner ni y charger quiconque, feux de détresse ou pas.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un chauffeur partant à la retraite vous propose de racheter son ADS obtenue en 2010. Est-ce envisageable ?$mft$,
    $mft$[
      {"id":"a","label":"Oui : les ADS délivrées avant 2014 restent cessibles, un marché du rachat existe","is_correct":true},
      {"id":"b","label":"Non : toutes les ADS sont devenues incessibles depuis la loi Thévenoud","is_correct":false},
      {"id":"c","label":"Oui, mais seulement si le maire rachète l'ADS pour vous la céder ensuite","is_correct":false},
      {"id":"d","label":"Non : une ADS s'obtient exclusivement par la liste d'attente","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-2','qcm-v1'], 'TAXI-M2-QCM-07', false,
    $mft$La loi Thévenoud n'a rendu incessibles que les NOUVELLES ADS : celles délivrées avant 2014 se revendent toujours, sans passage obligé par la mairie, et le rachat constitue la seconde voie d'accès au métier à côté de la liste d'attente.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Exploitant VTC inscrit au registre en février 2022, vous n'avez effectué aucune démarche depuis. Quelle échéance vous concerne ?$mft$,
    $mft$[
      {"id":"a","label":"Le renouvellement de votre inscription au REVTC avant février 2027 (validité 5 ans)","is_correct":true},
      {"id":"b","label":"Un renouvellement annuel de l'inscription, chaque mois de février","is_correct":false},
      {"id":"c","label":"Un renouvellement décennal, en 2032","is_correct":false},
      {"id":"d","label":"Aucune : l'inscription au registre est définitive","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-2','qcm-v1'], 'TAXI-M2-QCM-08', false,
    $mft$L'inscription au REVTC se renouvelle tous les 5 ans : février 2022 plus 5 ans donne février 2027 ; elle n'est ni annuelle, ni décennale, ni définitive, et l'oubli met l'exploitant hors registre.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Course de taxi un samedi à 23 h. De quoi se compose le prix payé par le client ?$mft$,
    $mft$[
      {"id":"a","label":"Prise en charge, kilomètres au tarif applicable de la grille (A/B/C/D) et suppléments encadrés par l'arrêté","is_correct":true},
      {"id":"b","label":"Un forfait librement négocié avant de partir","is_correct":false},
      {"id":"c","label":"Un prix fixé par le chauffeur selon l'affluence du soir","is_correct":false},
      {"id":"d","label":"Un tarif kilométrique national unique, identique de jour comme de nuit","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-2','qcm-v1'], 'TAXI-M2-QCM-09', false,
    $mft$Le prix du taxi se construit selon la grille de l'arrêté : prise en charge, kilomètres au tarif applicable (A/B/C/D selon jour/nuit et aller/retour) et suppléments encadrés ; il n'est ni négocié, ni fixé par le chauffeur, ni identique jour et nuit.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Votre conjoint, lui aussi titulaire de la carte professionnelle de taxi, voudrait exploiter le week-end l'ADS que la mairie vous a délivrée en 2024. Que lui répondez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Que la nouvelle ADS impose une exploitation personnelle par son titulaire, et que toute pratique de doublage ou de relais dépend des règlements locaux, à vérifier avant d'agir","is_correct":true},
      {"id":"b","label":"Que c'est possible d'office entre membres du même foyer","is_correct":false},
      {"id":"c","label":"Qu'un courrier d'information au maire suffit à l'autoriser","is_correct":false},
      {"id":"d","label":"Que vous pouvez lui revendre la moitié de l'autorisation","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-2','qcm-v1'], 'TAXI-M2-QCM-10', false,
    $mft$Une ADS délivrée après la loi Thévenoud s'exploite personnellement : ni le lien familial ni un simple courrier n'y dérogent, et une autorisation incessible ne se revend pas, même pour moitié ; le doublage éventuel relève des règlements locaux, à vérifier.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Un exploitant VTC facture ses courses à l'arrivée en additionnant le temps passé et les kilomètres parcourus, « comme un compteur, mais sur tablette ». Qu'en pensez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Cette facturation à la manière d'un taximètre est en principe interdite au VTC, dont le prix doit être fixé avant la course (exceptions éventuelles à vérifier)","is_correct":true},
      {"id":"b","label":"Elle est légale dès lors que le client accepte le montant à l'arrivée","is_correct":false},
      {"id":"c","label":"Elle est légale si la tablette affiche une estimation pendant le trajet","is_correct":false},
      {"id":"d","label":"Elle est obligatoire, par souci de transparence tarifaire","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-2','qcm-v1'], 'TAXI-M2-QCM-11', false,
    $mft$Le prix VTC doit être fixé avant la course : la facturation a posteriori à la durée et à la distance, façon taximètre, est en principe interdite (exceptions à vérifier dans les textes) ; l'accord du client à l'arrivée ou une estimation affichée ne régularisent rien.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$La réception d'un hôtel appelle votre centrale VTC : un client au comptoir veut partir « tout de suite ». La centrale enregistre la réservation, puis vous prenez le client en charge trois minutes plus tard. Cette course est-elle régulière ?$mft$,
    $mft$[
      {"id":"a","label":"Oui : la réservation a été enregistrée avant la prise en charge, et aucun délai minimal n'est exigé","is_correct":true},
      {"id":"b","label":"Non : une réservation VTC doit être passée au moins la veille","is_correct":false},
      {"id":"c","label":"Non : seul un taxi peut assurer un départ immédiat, quel que soit le canal","is_correct":false},
      {"id":"d","label":"Oui, mais uniquement si l'hôtel dispose de sa propre flotte de véhicules","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-2','qcm-v1'], 'TAXI-M2-QCM-12', false,
    $mft$La réservation préalable n'exige pas de délai minimal : enregistrée avant la prise en charge, même de quelques minutes, elle rend la course licite pour le VTC ; ce qui est interdit, c'est la rencontre sans réservation, et la flotte de l'hôtel n'a rien à voir.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Un passant lève le bras sur la voie publique pour être transporté immédiatement. Lequel des deux professionnels du T3P peut le prendre en charge, et en vertu de quoi ?$mft$,
   $mft$Le taxi, au titre du monopole de la maraude (prise en charge immédiate sur la voie publique et stationnement en attente de clientèle), dans sa commune ou zone de rattachement ; le VTC ne travaille que sur réservation préalable.$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-2','question-courte'], 'TAXI-M2-QC-01', false,
   $mft$La maraude est le monopole territorialisé du taxi.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Vous souhaitez obtenir votre première autorisation de stationnement de taxi : auprès de qui la demande se fait-elle, et par quel mécanisme d'attente ?$mft$,
   $mft$Auprès du maire de la commune ; le candidat s'inscrit sur la liste d'attente tenue en mairie jusqu'à la délivrance d'une ADS nouvelle (gratuite, incessible, 5 ans renouvelables).$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-2','question-courte'], 'TAXI-M2-QC-02', false,
   $mft$Le maire délivre, la liste d'attente ordonne les demandes.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Un client de taxi vous demande de lui « faire un prix » pour une course habituelle. Que lui répondez-vous sur la formation du prix ?$mft$,
   $mft$Le prix du taxi est réglementé par arrêté et mesuré par le compteur horokilométrique obligatoire (prise en charge, kilomètres selon la grille, suppléments encadrés) : le chauffeur ne le fixe pas librement.$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-2','question-courte'], 'TAXI-M2-QC-03', false,
   $mft$Prix réglementé : la grille s'impose au chauffeur comme au client.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Un exploitant VTC veut inscrire sa flotte sur une application qui propose la prise en charge immédiate des véhicules « libres autour de vous », sans réservation. Que lui dites-vous ?$mft$,
   $mft$C'est de la maraude électronique, réservée aux taxis : le VTC ne peut proposer ses services que sur réservation préalable, et le support numérique ne change rien à la règle.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-2','question-courte'], 'TAXI-M2-QC-04', false,
   $mft$L'écran ne transforme pas la nature de la prise en charge.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Deux chauffeurs : l'un exploite une ADS achetée qui avait été délivrée en 2008, l'autre une ADS obtenue gratuitement en 2023. À la cessation d'activité, que peut faire le premier que le second ne pourra jamais faire ?$mft$,
   $mft$Céder (revendre) son ADS : les autorisations délivrées avant 2014 restent cessibles, alors que les nouvelles ADS sont incessibles et sans valeur de revente.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-2','question-courte'], 'TAXI-M2-QC-05', false,
   $mft$La loi Thévenoud n'a fermé la cessibilité que pour les nouvelles ADS.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Citez trois justificatifs exigés d'un exploitant pour son inscription au registre national des VTC.$mft$,
   $mft$Par exemple : la carte professionnelle, l'assurance de responsabilité civile professionnelle, l'immatriculation de l'entreprise, la garantie financière ou les justificatifs de propriété/location du véhicule (modalités à vérifier dans les textes).$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-2','question-courte'], 'TAXI-M2-QC-06', false,
   $mft$Trois pièces distinctes attendues parmi la liste.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Après une course de taxi d'un montant élevé, votre passager réclame un justificatif. Que prévoit la réglementation sur la remise d'une note ?$mft$,
   $mft$La remise d'une note au client est obligatoire au-delà d'un seuil de prix de course, dont le montant est fixé par les textes (à vérifier).$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-2','question-courte'], 'TAXI-M2-QC-07', false,
   $mft$Retenir le principe du seuil ; le montant exact se vérifie dans les textes en vigueur.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un exploitant VTC n'achète que des berlines hybrides récentes. Pourquoi doit-il malgré tout consulter le décret sur les conditions techniques des véhicules avant chaque acquisition ?$mft$,
   $mft$Parce que le décret fixe les critères (nombre de places, dimensions, ancienneté, puissance) et le périmètre des dérogations accordées aux véhicules hybrides et électriques : seuls les textes en vigueur permettent de confirmer la conformité, aucun chiffre ne doit être supposé.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-2','question-courte'], 'TAXI-M2-QC-08', false,
   $mft$Les dérogations hybrides/électriques existent, mais leur périmètre se vérifie.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Votre taxi est rattaché à la commune A. Alors que vous circulez dans la commune B, un piéton vous hèle pour un départ immédiat. Pouvez-vous le charger, et pourquoi ?$mft$,
   $mft$Non en maraude : le monopole de la maraude s'exerce dans la commune ou zone de rattachement de l'ADS ; hors de cette zone, la prise en charge suppose une réservation préalable.$mft$,
   2, 'difficile', ARRAY['taxi-vtc','module-2','question-courte'], 'TAXI-M2-QC-09', false,
   $mft$La maraude est un monopole territorialisé, pas un droit national.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Un VTC annonce 45 euros à la réservation puis facture 58 euros à l'arrivée « à cause des bouchons », calculés d'après la durée réelle. Quelles règles du régime tarifaire VTC ce comportement méconnaît-il ?$mft$,
   $mft$Le prix VTC, libre, doit être fixé avant la course (forfait ou devis) : la révision à l'arrivée et la facturation à la durée et à la distance à la manière d'un taximètre sont en principe interdites (exceptions à vérifier).$mft$,
   2, 'difficile', ARRAY['taxi-vtc','module-2','question-courte'], 'TAXI-M2-QC-10', false,
   $mft$Le forfait annoncé engage l'exploitant : le risque trafic lui incombe.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ─────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Expliquez à un candidat qui hésite entre les deux métiers ce que recouvre le monopole de la maraude et ce que cela change concrètement dans une journée de travail de taxi et de VTC.$mft$,
   $mft$Réponse modèle. La maraude désigne deux prérogatives : la prise en charge immédiate d'un client sur la voie publique (le passant qui hèle) et le stationnement en attente de clientèle (stations de gare, d'aéroport, de centre-ville). Ce monopole appartient aux taxis et s'exerce dans la commune ou la zone de rattachement de l'ADS : hors de cette zone, le taxi lui-même ne maraude plus. La maraude électronique (application montrant les véhicules disponibles alentour pour un départ immédiat) suit la même règle : taxis uniquement. Le VTC, lui, ne travaille que sur réservation préalable : chaque course doit avoir été commandée avant la rencontre avec le client. Concrètement, la journée du taxi s'organise autour du territoire : stations, flux de voyageurs (gares, aéroports), clients spontanés, complétés par les courses réservées. La journée du VTC s'organise autour du carnet de réservations : plateformes, centrale, clientèle d'entreprise, courses programmées ; entre deux courses, il ne peut ni stationner en attente de clients ni accepter un client qui le hèle. Le taxi vit de l'emplacement et de l'instant ; le VTC vit de la prospection commerciale et de la fidélisation.$mft$,
   $mft$Barème /5 : définition complète de la maraude avec ses deux volets (1,5 pt) ; rattachement territorial à la commune/zone de l'ADS (1 pt) ; maraude électronique réservée aux taxis (1 pt) ; traduction concrète des deux journées de travail (1,5 pt). Erreurs fréquentes : réduire la maraude au seul stationnement ; croire qu'un VTC peut accepter un client qui le hèle « si aucun taxi n'est disponible ».$mft$,
   5, 'facile', ARRAY['taxi-vtc','module-2','question-redigee'], 'TAXI-M2-QR-01', false,
   $mft$Le monopole de la maraude expliqué et traduit en organisation de journée.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Comparez point par point la formation du prix d'une même course (centre-ville vers aéroport) réalisée en taxi puis en VTC : qui fixe le prix, quand le client le connaît, quels instruments et documents entrent en jeu.$mft$,
   $mft$Réponse modèle. Côté taxi, le prix est réglementé par arrêté : le chauffeur ne le fixe pas. La course se compose de la prise en charge (forfait de départ), des kilomètres facturés au tarif A, B, C ou D (selon jour/nuit et aller/retour, grille fixée par l'arrêté) et des seuls suppléments encadrés. L'instrument central est le compteur horokilométrique obligatoire : le client voit le prix se construire et le connaît à l'arrivée. La grille doit être affichée dans le véhicule, et une note est remise au-delà d'un seuil de prix (montant à vérifier dans les textes). Côté VTC, le prix est libre : l'exploitant le détermine, mais il doit être fixé avant la course, sous forme de forfait annoncé à la réservation ou de devis. Pas de compteur à bord : le client connaît le montant exact avant de monter, quel que soit le trafic, et le VTC ne peut pas recalculer à l'arrivée à la durée et à la distance, à la manière d'un taximètre (exceptions à vérifier). Commercialement, le taxi vend un prix contrôlé par la puissance publique, le VTC un prix garanti d'avance : deux protections différentes du client.$mft$,
   $mft$Barème /5 : mécanisme taxi complet : arrêté, prise en charge + kilomètres A/B/C/D + suppléments encadrés, compteur, affichage (2 pts) ; mécanisme VTC : prix libre fixé avant la course, forfait ou devis, pas de compteur (1,5 pt) ; moment où le client connaît le prix dans chaque modèle (1 pt) ; note au-delà d'un seuil et interdiction du calcul façon taximètre, avec mention de prudence (0,5 pt). Erreurs fréquentes : doter le VTC d'un compteur ; croire que le taxi négocie librement sa grille.$mft$,
   5, 'facile', ARRAY['taxi-vtc','module-2','question-redigee'], 'TAXI-M2-QR-02', false,
   $mft$La même course sous deux régimes tarifaires : instruments et documents.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Vous êtes conducteur VTC devant une gare. Trois situations en dix minutes : un voyageur ouvre votre portière et s'assoit ; un autre vous demande de vous mettre dans la file des taxis « juste deux minutes » ; votre client réservé écrit qu'il arrive avec quinze minutes de retard. Décrivez votre conduite pour chaque situation et les règles qui la justifient.$mft$,
   $mft$Réponse modèle. Situation 1 : le voyageur qui s'assoit sans réservation. Je ne démarre pas : sans réservation préalable, prendre ce client reviendrait à marauder, monopole des taxis. Je l'informe courtoisement et je l'oriente : soit vers la file des taxis, soit vers une réservation immédiate (application, centrale) ; si une réservation est enregistrée avant la prise en charge, la course devient possible. Situation 2 : la file réservée aux taxis. Je refuse de m'y insérer, même « deux minutes » : ce stationnement en attente de clientèle est un attribut de la maraude, donc interdit au VTC ; je patiente hors de la zone réservée, à un emplacement autorisé. Situation 3 : mon client réservé retardé de quinze minutes. J'attends au point convenu ou à proximité, sans proposer mes services aux passants et sans occuper la zone des taxis ; je confirme au client le point de rencontre. Règles mobilisées : monopole de la maraude (prise en charge immédiate et stationnement en attente réservés aux taxis), obligation de réservation préalable pour le VTC, et principe que la réservation doit précéder la rencontre, sans délai minimal imposé. La constance dans ces refus protège ma carte professionnelle et mon exploitation.$mft$,
   $mft$Barème /5 : situation 1 : refus et orientation vers une réservation, avec la nuance « réservation enregistrée avant la prise en charge » (1,5 pt) ; situation 2 : refus de la file des taxis, attente hors zone (1,5 pt) ; situation 3 : attente au point convenu sans démarchage (1 pt) ; règles correctement nommées : maraude, réservation préalable (1 pt). Erreurs fréquentes : accepter le client « déjà assis » ; s'insérer dans la file des taxis avec les feux de détresse.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-2','question-redigee'], 'TAXI-M2-QR-03', false,
   $mft$Trois scénarios de gare tranchés par les règles de la maraude.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Un chauffeur salarié envisage de s'installer taxi dans sa commune. Analysez ses deux voies d'accès à l'ADS (liste d'attente en mairie contre rachat d'une ADS ancienne) : avantages, contraintes et points de vigilance de chacune.$mft$,
   $mft$Réponse modèle. Première voie : la liste d'attente en mairie. Le candidat, titulaire de la carte professionnelle de taxi, s'inscrit et attend qu'une ADS nouvelle lui soit délivrée par le maire. Avantages : gratuité, pas d'endettement. Contraintes : délai incertain selon les communes, et régime strict à l'arrivée : ADS incessible, valable 5 ans renouvelables, une seule par personne, exploitation personnelle ; elle ne constituera jamais un patrimoine revendable. Seconde voie : le rachat d'une ADS ancienne (délivrée avant 2014), restée cessible. Avantages : disponibilité immédiate et conservation d'une valeur patrimoniale : l'ADS pourra être revendue, par exemple au moment de la retraite. Contraintes : un coût d'acquisition élevé, souvent financé par emprunt, et une valeur de revente qui dépend du marché local au moment de la cession : rien ne garantit de retrouver le prix payé. Points de vigilance communs : la carte professionnelle reste le préalable dans les deux cas ; comparer le coût du rachat au manque à gagner de l'attente ; et ne jamais raisonner comme si une ADS gratuite pouvait se revendre ensuite : les deux régimes coexistent mais ne se convertissent pas l'un en l'autre.$mft$,
   $mft$Barème /5 : voie liste d'attente avec régime complet de la nouvelle ADS : gratuite, incessible, 5 ans, exploitation personnelle (1,5 pt) ; voie rachat avec cessibilité des ADS d'avant 2014 (1,5 pt) ; comparaison économique et patrimoniale argumentée (1 pt) ; points de vigilance : carte professionnelle préalable, valeur de marché fluctuante, non-convertibilité des régimes (1 pt). Erreurs fréquentes : croire qu'une nouvelle ADS devient cessible après 5 ans ; oublier l'exploitation personnelle.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-2','question-redigee'], 'TAXI-M2-QR-04', false,
   $mft$Liste d'attente contre rachat : l'arbitrage du candidat taxi.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Vous créez votre activité VTC pour janvier prochain. Construisez, dans l'ordre, votre plan d'action pour être en règle côté registre : pièces à réunir, inscription, budget, échéances de renouvellement, et points que vous devrez vérifier dans les textes.$mft$,
   $mft$Réponse modèle. Étape 1 : vérifier les prérequis : carte professionnelle en cours de validité et entreprise immatriculée, car l'inscription au REVTC vise l'exploitant. Étape 2 : réunir les justificatifs : carte professionnelle, attestation d'assurance RC professionnelle, justificatif d'immatriculation de l'entreprise, et garantie financière ou justificatifs de propriété/location du véhicule ; la liste exacte et les modalités de la garantie sont à vérifier dans les textes en vigueur. Étape 3 : vérifier le véhicule AVANT tout engagement : les conditions techniques (nombre de places, dimensions, ancienneté, puissance) sont fixées par décret, avec des dérogations pour les hybrides et les électriques ; les seuils chiffrés se contrôlent dans les textes du moment. Étape 4 : budgéter les frais d'inscription, dont le montant est fixé par arrêté (à vérifier lors de la démarche). Étape 5 : déposer l'inscription au REVTC et attendre de figurer au registre avant toute course : pas d'activité sans inscription. Étape 6 : programmer le renouvellement : l'inscription vaut 5 ans ; je note l'échéance dès l'obtention et je prévois la mise à jour des justificatifs. Ce séquencement évite les deux fautes classiques : rouler pendant l'instruction du dossier et investir dans un véhicule non conforme.$mft$,
   $mft$Barème /5 : justificatifs complets avec mention de prudence sur la garantie financière (1,5 pt) ; séquence correcte : inscription avant activité, renouvellement 5 ans programmé (1,5 pt) ; frais fixés par arrêté, montant à vérifier (1 pt) ; vérification du véhicule avant achat : décret et dérogations hybrides/électriques (1 pt). Erreurs fréquentes : commencer l'activité avant l'inscription ; confondre le REVTC (exploitant VTC) et l'ADS (taxi).$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-2','question-redigee'], 'TAXI-M2-QR-05', false,
   $mft$Plan d'action REVTC : pièces, séquence, budget, renouvellement.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Cas chiffré. Une course de 18 km est proposée à 52 euros en forfait VTC annoncé à la réservation ; en taxi, le client paiera prise en charge, kilomètres au tarif de la grille et suppléments encadrés, montant connu à l'arrivée. Analysez ce que chaque modèle apporte au client et au conducteur (prévisibilité, risque trafic, liberté commerciale), et ce que chacun a le droit ou non de faire sur le prix.$mft$,
   $mft$Réponse modèle. Côté VTC, les 52 euros annoncés à la réservation engagent l'exploitant : le prix, libre dans sa fixation, doit être déterminé avant la course. Si le trajet prend quarante minutes de plus à cause d'un accident, le forfait ne bouge pas : le risque trafic pèse sur l'exploitant, qui doit l'intégrer dans sa politique tarifaire (marges, heures de pointe). En contrepartie, il jouit d'une vraie liberté commerciale : moduler ses prix selon l'heure, la gamme, la fidélité du client. Ce qu'il ne peut pas faire : recalculer à l'arrivée en additionnant durée et distance à la manière d'un taximètre (interdiction de principe, exceptions à vérifier). Côté taxi, le prix résulte de la grille fixée par arrêté : prise en charge, kilomètres au tarif applicable (A/B/C/D selon jour/nuit et aller/retour), suppléments encadrés, le tout mesuré au compteur horokilométrique obligatoire. Le client ne connaît le montant exact qu'à l'arrivée : dans les bouchons, le compteur tourne, le risque trafic est plutôt de son côté. Pour le client : le VTC vend la certitude du montant, le taxi la garantie d'un prix contrôlé. Pour le conducteur : liberté commerciale d'un côté, sécurité d'une grille opposable à tous de l'autre.$mft$,
   $mft$Barème /5 : mécanisme VTC : forfait engageant fixé avant la course, interdiction du recalcul façon taximètre avec prudence sur les exceptions (1,5 pt) ; mécanisme taxi : grille par arrêté, compteur, composantes de la course (1,5 pt) ; répartition du risque trafic dans les deux modèles (1 pt) ; lecture commerciale pour le client et pour le conducteur (1 pt). Erreurs fréquentes : autoriser le VTC à réviser le prix à l'arrivée ; laisser croire que le taxi fixe librement sa grille.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-2','question-redigee'], 'TAXI-M2-QR-06', false,
   $mft$Un forfait VTC et une course au compteur : risques et libertés comparés.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Étude de cas. En 2013, Karim a acheté son ADS 180 000 euros ; en 2024, Lina a obtenu la sienne gratuitement en mairie après trois ans de liste d'attente. Analysez la situation patrimoniale et professionnelle de chacun : ce que chaque autorisation permet, vaut et impose, et ce que la coexistence des deux régimes implique pour la profession.$mft$,
   $mft$Réponse modèle. Karim détient une ADS de l'ancien régime (délivrée avant 2014) : elle est cessible. Les 180 000 euros investis constituent un actif professionnel : il pourra revendre l'autorisation, souvent pour financer sa retraite. Mais cette valeur n'est pas garantie : elle dépend du marché local au moment de la vente et peut se révéler inférieure au prix d'achat ; l'emprunt éventuel qui a financé l'acquisition a par ailleurs pesé sur ses années d'exploitation. Lina relève du régime issu de la loi Thévenoud : ADS gratuite, incessible, délivrée pour 5 ans renouvelables, une seule par personne, exploitation personnelle par la titulaire de la carte taxi. Elle n'a rien déboursé mais ne détient aucun actif : son autorisation ne se revend pas et ne se transmet pas. Pour la profession, la coexistence crée deux situations économiques dans les mêmes stations : des chauffeurs endettés ou attachés à la valeur de revente de leur ADS, et des entrants sans capital ni patrimoine d'autorisation. Le point commun demeure : carte professionnelle, rattachement territorial, mêmes règles de maraude. La divergence est patrimoniale, pas opérationnelle : au quotidien, Karim et Lina exercent le même métier.$mft$,
   $mft$Barème /5 : régime de Karim : cessibilité, valeur de marché fluctuante, logique retraite (1,5 pt) ; régime de Lina : gratuite, incessible, 5 ans renouvelables, exploitation personnelle (1,5 pt) ; analyse patrimoniale comparée : actif revendable contre autorisation d'exercer (1 pt) ; implications de la coexistence pour la profession et invariants communs (1 pt). Erreurs fréquentes : rendre incessibles les ADS anciennes ; laisser Lina revendre son ADS après 5 ans.$mft$,
   5, 'difficile', ARRAY['taxi-vtc','module-2','question-redigee'], 'TAXI-M2-QR-07', false,
   $mft$Deux générations d'ADS : lecture patrimoniale et professionnelle.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un investisseur veut lancer une flotte de six VTC haut de gamme avec des berlines de sept ans d'âge achetées d'occasion, dont deux hybrides. Rédigez la note d'analyse : vérifications réglementaires à mener avant l'achat (registre, véhicules, assurances), risques si un point n'est pas conforme, et recommandation de procédure.$mft$,
   $mft$Réponse modèle. Vérifications côté exploitant : inscription au REVTC obligatoire avant toute activité, avec les justificatifs (carte professionnelle des conducteurs, assurance RC professionnelle, immatriculation de l'entreprise, garantie financière ou justificatifs de propriété/location des véhicules : modalités à vérifier dans les textes) ; frais d'inscription fixés par arrêté (montant à vérifier) ; renouvellement tous les 5 ans à programmer. Vérifications côté véhicules : les conditions techniques sont fixées par décret (nombre de places, dimensions, ancienneté, puissance). Les berlines de sept ans d'âge constituent le point critique du projet : le critère d'ancienneté doit être contrôlé dans le texte en vigueur AVANT l'achat, faute de quoi les véhicules pourraient être inexploitables. Les deux hybrides peuvent relever des dérogations prévues pour les véhicules hybrides et électriques : périmètre exact à vérifier également. Risques en cas de non-conformité : impossibilité d'exploiter les véhicules concernés et blocage de l'activité malgré l'investissement engagé. Recommandation de procédure : 1) obtenir la version en vigueur du décret et de l'arrêté ; 2) confronter chaque véhicule pressenti aux critères, dérogations comprises ; 3) conditionner les achats à cette conformité (clause suspensive) ; 4) déposer l'inscription au REVTC ; 5) ne lancer l'exploitation qu'une fois l'inscription obtenue. Aucun chiffre de mémoire : la conformité se prouve textes en main.$mft$,
   $mft$Barème /5 : vérifications exploitant : REVTC, justificatifs, frais par arrêté, renouvellement 5 ans (1,5 pt) ; vérifications véhicules : décret, critère d'ancienneté identifié comme point critique, dérogations hybrides (1,5 pt) ; risques de non-conformité explicités (1 pt) ; procédure recommandée : vérifier avant d'acheter, achat conditionné, activité après inscription (1 pt). Erreurs fréquentes : acheter la flotte puis découvrir les critères ; citer des seuils chiffrés de mémoire au lieu des textes en vigueur.$mft$,
   5, 'difficile', ARRAY['taxi-vtc','module-2','question-redigee'], 'TAXI-M2-QR-08', false,
   $mft$Note d'analyse pour une flotte VTC : conformité avant investissement.$mft$);

  RAISE NOTICE 'Module 2 Taxi et VTC créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $taxim2$;
