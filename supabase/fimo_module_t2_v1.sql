-- =====================================================================
-- FIMO / FCO MARCHANDISES — THÈME 2 : RÉGLEMENTATIONS DU TRANSPORT
-- v1 (juillet 2026) — LOT FIMO-3
-- Angle conducteur : les règles APPLIQUÉES au volant (scénarios),
-- le chronotachygraphe au quotidien, les documents et le contrôle.
-- ⚠ STATUT : active = false (« à valider »). Idempotent.
-- =====================================================================

DO $fimot2$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_l4 uuid;
  v_quiz uuid; v_q uuid; v_ord int := 0;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'fimo-fco';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation fimo-fco introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'FIMO-FCO';
  IF v_bloc IS NULL THEN RAISE EXCEPTION 'Bloc FIMO-FCO introuvable (appliquer le lot FIMO-1).'; END IF;

  DELETE FROM public.question_bank WHERE source_ref LIKE 'FIMO-T2-%';
  DELETE FROM public.modules WHERE slug = 'fimo-t2-reglementations';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Thème 2 — Réglementations du transport',
    'fimo-t2-reglementations', v_bloc,
    'Vos temps de conduite et de repos appliqués à la journée réelle, le chronotachygraphe au quotidien (sélecteur, carte, incidents), les documents de bord et le bon déroulement d''un contrôle routier.',
    'intermediaire', 420, 30) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 30, true);

  -- ─── Leçon 1 — Vos temps de conduite et de repos, en vrai ──────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'temps-conduite-repos-au-quotidien',
    'Vos temps de conduite et de repos, appliqués à la journée',
    $mft$> 🎯 **Objectifs**
> - Dérouler une journée type conforme sans réfléchir dix minutes à chaque pause.
> - Savoir ce que vous pouvez encore faire à 15 h quand la journée a mal tourné.
> - Ne plus confondre pause, repos et coupure.

## La journée type

Prise de service 6 h 00. Vous pouvez conduire **4 h 30** au maximum d'affilée : première pause au plus tard à 10 h 30 (45 minutes, ou 15 puis 30 déjà entamées avant). Nouvelle tranche de conduite possible de 4 h 30. Total conduite du jour : **9 heures** (10 h possibles deux fois dans la semaine). Avant la fin de la fenêtre de **24 h** ouverte à 6 h 00 : votre repos journalier de **11 heures** (réductible à 9 h, trois fois entre deux repos hebdomadaires) doit être TERMINÉ.

> 📌 **À retenir**
> La pause interrompt la conduite mais ne raccourcit pas la journée ; le repos clôt la journée. Fractionnements admis : pause **15 puis 30** (jamais l'inverse) ; repos journalier **3 h puis 9 h** (12 h au total, compte comme repos normal).

## Les scénarios qui fâchent

- **« J'ai fait 15 + 20 + 10 de pause »** : non conforme : après la fraction de 15, il faut **30 minutes d'un bloc** avant l'échéance des 4 h 30.
- **« Je finis ma livraison, il me reste 20 minutes de conduite »** : si les 4 h 30 tombent avant l'arrivée : pause d'abord. Le client attend 45 minutes, pas l'inverse.
- **« Deux fois 10 h cette semaine, mardi et jeudi ; vendredi je suis chargé »** : vendredi, c'est **9 h maximum** : les rallonges sont épuisées.
- **« Semaine à 56 h de conduite »** : possible : mais la semaine suivante plafonne à **34 h** (90 h sur deux semaines).

## Ce qui compte aussi

- **Amplitude et autres travaux** : le chargement, l'attente au quai, l'administratif sont du **travail**, pas du repos : ils comptent dans vos durées de travail (48 h en moyenne, 60 h maxi par semaine) même s'ils ne sont pas de la conduite.
- **Le repos hebdomadaire** : au plus tard après **six périodes de 24 h** depuis la fin du précédent : 45 h (normal) ou au moins 24 h (réduit, à compenser). Le repos normal ne se prend **jamais en cabine**.
- **Double équipage** : la présence d'un second conducteur change les fenêtres (9 h de repos dans une fenêtre de 30 h) : règles spécifiques à réviser avant de rouler en binôme.

> ❌ **Piège à éviter**
> « Je coupe 45 minutes moteur tournant au quai en chargeant » : ce n'est PAS une pause : vous travaillez. La pause est du temps **librement disponible** : ni conduite, ni manutention, ni paperasse.

## ✅ Synthèse

- Journée : **4 h 30 → pause 45 (15+30) → 4 h 30**, total **9 h** (2 × 10 h/semaine), repos **11 h** dans la fenêtre de 24 h.
- Semaine : **56 h** de conduite maxi, **90 h** sur deux semaines, repos hebdo après **6 × 24 h**.
- Pause = temps libre ; chargement et attente = **travail** ; repos normal jamais en cabine.$mft$,
    $mft$La journée type 4h30/45min/4h30, les scénarios de fin de journée (rallonges épuisées, 56h→34h), la distinction pause/travail/repos et les fenêtres de 24h et 6×24h.$mft$,
    1, 45) RETURNING id INTO v_l1;

  -- ─── Leçon 2 — Le chronotachygraphe au quotidien ───────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'chronotachygraphe-au-quotidien',
    'Le chronotachygraphe au quotidien',
    $mft$> 🎯 **Objectifs**
> - Utiliser correctement carte et sélecteur d'activités, du premier au dernier geste de la journée.
> - Réagir proprement aux incidents : carte oubliée, défaillance, activité manquante.
> - Présenter les bonnes données en contrôle.

## Les gestes de la journée

:::timeline
1. **Prise de service** — Insérer VOTRE carte, saisir le pays, vérifier l'heure (le tachy est en temps universel : l'heure locale se convertit).
2. **En roulant** — La conduite s'enregistre automatiquement dès que le véhicule bouge.
3. **À l'arrêt** — Basculer le sélecteur : **autres travaux** (chargement, plein, administratif), **disponibilité** (attente sans obligation de rester au poste), **repos/pause** (temps libre). Le sélecteur ne se règle pas « plus tard » : il se règle au moment.
4. **Fin de service** — Saisir le pays de fin, retirer la carte. Votre repos commence quand l'activité s'arrête vraiment.
:::

> ❌ **Piège à éviter**
> Rester sur « autres travaux » pendant sa pause déjeuner, ou sur « repos » pendant le déchargement : dans les deux cas les données mentent. Les analyses d'entreprise et les contrôleurs recoupent tout (géolocalisation, lettres de voiture, badges de quai) : l'incohérence se voit.

## Les incidents et leurs bons réflexes

- **Carte oubliée à la maison** : ne pas rouler avec la carte d'un collègue (fraude grave) ni « sans rien » : prévenir l'exploitation ; selon la situation : retour chercher la carte ou solution d'exploitation ; en cas de carte **défaillante, perdue ou volée** en cours de mission : impressions papier en début et fin de journée, annotées et signées, déclaration et demande de remplacement dans les délais.
- **Panne du tachygraphe** : noter les activités manuellement (sortie d'impression ou feuillet), faire réparer dans les délais réglementaires.
- **Journées non travaillées ou hors champ** (congés, maladie, autre emploi) : l'**attestation d'activités** de l'employeur comble les trous que la carte ne peut pas expliquer.
- **Saisie manuelle** : à l'insertion, compléter les activités effectuées carte retirée (repos à l'hôtel, ferry).

## Le contrôle routier

Vous devez pouvoir justifier la journée en cours et les **28 jours précédents** : carte + données du véhicule + impressions/attestations éventuelles. Le contrôleur lit : dépassements, pauses écourtées, conduites sans carte. Restez factuel, fournissez ce qui est demandé, ne « racontez » pas les données : elles parlent seules.

> 📌 **À retenir**
> La carte est **strictement personnelle**. La prêter, utiliser celle d'un autre ou manipuler l'appareil (aimant, débranchement) fait basculer dans la fraude : sanctions lourdes pour vous ET l'entreprise, et un dossier indéfendable en cas d'accident.

## ✅ Synthèse

- Gestes : carte à l'insertion, **sélecteur juste au bon moment**, pays début/fin, saisies manuelles à l'insertion.
- Incidents : impressions signées, attestation d'activités, jamais la carte d'un autre.
- Contrôle : la journée + **28 jours** justifiés ; les données ne se négocient pas.$mft$,
    $mft$Les gestes tachy de la journée (carte, sélecteur au bon moment, pays), les incidents (carte oubliée/perdue, panne, attestation d'activités, saisies manuelles) et le contrôle des 28 jours.$mft$,
    2, 45) RETURNING id INTO v_l2;

  -- ─── Leçon 3 — Documents de bord et contrôle ───────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'documents-de-bord-controle',
    'Vos documents de bord et le contrôle routier',
    $mft$> 🎯 **Objectifs**
> - Réunir les documents exigibles avant de démarrer, sans en oublier.
> - Utiliser la lettre de voiture comme un outil (pas une corvée).
> - Traverser un contrôle routier proprement.

## Le tour des documents

| Famille | Documents |
| --- | --- |
| Vous | Permis, carte de qualification, carte de conducteur (+ certificat ADR le cas échéant) |
| Le véhicule | Certificat d'immatriculation, preuve du contrôle technique, attestation d'assurance |
| Le transport | **Copie conforme de la licence**, **lettre de voiture**, documents spécifiques (ADR, déchets, animaux vivants…), attestation de détachement à l'international le cas échéant |

## La lettre de voiture : votre meilleur témoin

Elle matérialise le contrat de transport et suit la marchandise : expéditeur, destinataire, nature et **poids annoncé**, prise en charge, livraison. Pour vous, trois moments clés :

:::flow
1. Enlèvement | Vérifier les mentions, compter, RÉSERVES écrites si écart ou anomalie
2. Route | La LV à bord justifie le chargement transporté
3. Livraison | Faire émarger (date, heure, identité), noter les réserves du destinataire
:::

> 📌 **À retenir**
> Une réserve utile est **précise** : « 2 palettes filmées éventrées côté droit, produits visibles » et non « colis abîmé ». Photos à l'appui. Sans réserve à l'enlèvement, l'avarie vous sera présumée imputable ; sans émargement à la livraison, la livraison elle-même se discute.

## Bien vivre un contrôle

Sur route (forces de l'ordre, contrôleurs des transports) : ralentir, suivre les indications, couper le moteur, rester courtois. Présenter ce qui est demandé dans l'ordre : vos trois titres, les données tachy (jour + 28 jours), les documents du véhicule et du transport. Ne pas improviser d'explications sur les données : répondre aux questions, factuellement. En cas d'infraction relevée : lire avant de signer, vous pouvez porter des observations ; l'amende éventuelle peut être consignée ; prévenir l'exploitation dès que possible.

## Ce qui coûte cher inutilement

- Copie conforme restée au bureau : le véhicule peut être immobilisé pour un document qui existe.
- Lettre de voiture non remplie « on la fera à l'arrivée » : en contrôle, chargement injustifié.
- CT ou assurance périmés dans la pochette : vérifier les dates fait partie du métier.

> 💡 **Astuce**
> La pochette de bord se vérifie à la prise de poste comme les pneus : 30 secondes, toujours les mêmes documents, toujours dans le même ordre. Les conducteurs contrôlés sereins sont ceux qui savent exactement ce qu'il y a dans la pochette.

## ✅ Synthèse

- Trois familles : **vous / le véhicule / le transport** ; la copie conforme et la LV voyagent TOUJOURS.
- LV : vérifier, **réserver précisément**, faire émarger : c'est votre preuve dans les deux sens.
- Contrôle : courtoisie, documents dans l'ordre, observations écrites si désaccord, exploitation prévenue.$mft$,
    $mft$Les trois familles de documents de bord, la lettre de voiture aux trois moments clés (réserves précises, émargement), et le comportement professionnel en contrôle routier.$mft$,
    3, 40) RETURNING id INTO v_l3;

  -- ─── Leçon 4 — Le cadre du transport, vu du volant ─────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'cadre-du-transport-vu-du-volant',
    'Le cadre du transport, vu du volant',
    $mft$> 🎯 **Objectifs**
> - Comprendre pourquoi votre entreprise détient licences et copies conformes.
> - Gérer les interdictions de circulation dans une tournée réelle.
> - Connaître vos droits et devoirs face à la surcharge et aux consignes illégales.

## Pourquoi tous ces papiers d'entreprise ?

Votre employeur est inscrit au **registre des transporteurs** et détient une **licence** (intérieure ou communautaire) : la **copie conforme** à bord prouve que le camion roule pour une entreprise autorisée. Sans elle, ce n'est pas « un oubli administratif » : c'est l'exploitation qui est en cause : d'où l'immobilisation possible.

## Les interdictions de circulation, en pratique

Votre 44 t est concerné par l'interdiction générale **du samedi 22 h au dimanche 22 h** (et veilles/jours fériés). Concrètement : une tournée du samedi se termine avant 22 h, position et repos anticipés ; certaines marchandises (denrées périssables notamment) bénéficient de dérogations : le document ou la consigne d'exploitation le précise AVANT le départ : ce n'est pas au conducteur de « tenter ».

- Ajoutez les interdictions locales (tunnels, centres-villes, ZFE selon vignette) et hivernales (équipements en zones de montagne).
- Le planning intègre ces contraintes : signalez à l'exploitation tout risque de dépassement d'horaire AVANT le créneau interdit, pas après.

## Surcharge : vos droits, vos devoirs

Le poids annoncé figure sur la lettre de voiture ; la charge utile de VOTRE ensemble, vous la connaissez. En cas de doute sérieux (essieux écrasés, poids annoncé incohérent) : demander la pesée ou **refuser** : en cas de contrôle, le conducteur du véhicule en surcharge est en première ligne (amende, immobilisation le temps de délester), même si l'expéditeur a mal déclaré : la fausse déclaration se retournera contre lui ensuite, mais c'est VOTRE journée qui est perdue.

> ⚠️ **Attention**
> Une consigne manifestement illégale (« pars quand même, tu délesteras là-bas », « mets la carte de Karim ») ne protège personne : elle expose le conducteur qui l'exécute ET l'entreprise. Refuser par écrit (message à l'exploitation) est le geste professionnel : un bon employeur le respecte, un mauvais vous renseigne.

## Qui est qui autour de votre camion

- **L'expéditeur/chargeur** : remet la marchandise, déclare le poids, charge souvent (gros envois) ;
- **Le commissionnaire** : organise le transport pour un client et sous-traite à votre entreprise ;
- **Le destinataire** : réceptionne et émarge ;
- **Votre exploitation** : construit les tournées dans les règles : votre retour terrain (attentes, créneaux, accès) la rend meilleure.

## ✅ Synthèse

- La **copie conforme** prouve l'entreprise autorisée : elle voyage toujours.
- Interdictions **sam 22 h → dim 22 h** : anticipées au planning ; dérogations = document AVANT départ.
- Surcharge ou consigne illégale : **vérifier, alerter, refuser par écrit** : c'est le professionnalisme, pas l'insubordination.$mft$,
    $mft$Le sens des licences et copies conformes, la gestion pratique des interdictions de circulation et dérogations, les droits et devoirs du conducteur face à la surcharge et aux consignes illégales, les acteurs autour du camion.$mft$,
    4, 35) RETURNING id INTO v_l4;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz — Réglementations du transport',
    'Vérifiez le thème 2 : temps de conduite appliqués, chronotachygraphe, documents et contrôle.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Vous prenez votre service à 6 h et roulez sans interruption. À quelle heure au plus tard devez-vous être en pause ?$mft$,
    $mft$[
      {"id":"a","label":"10 h 30 (après 4 h 30 de conduite)","is_correct":true},
      {"id":"b","label":"11 h (après 5 h de conduite)","is_correct":false},
      {"id":"c","label":"12 h (après 6 h de conduite)","is_correct":false},
      {"id":"d","label":"Quand la livraison du matin est terminée","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['fimo-fco','theme-2','qcm-v1'], 'FIMO-T2-QCM-01', false,
    $mft$4 h 30 de conduite cumulée déclenchent la pause de 45 minutes (ou le solde de 30 si 15 déjà prises). La livraison attend : pas l'inverse.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Pendant que vous chargez au hayon, sur quelle position doit être le sélecteur du chronotachygraphe ?$mft$,
    $mft$[
      {"id":"a","label":"Autres travaux","is_correct":true},
      {"id":"b","label":"Repos","is_correct":false},
      {"id":"c","label":"Disponibilité","is_correct":false},
      {"id":"d","label":"Conduite","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['fimo-fco','theme-2','qcm-v1'], 'FIMO-T2-QCM-02', false,
    $mft$Le chargement est du travail : « autres travaux ». Le déclarer en repos fausse les données et se recoupe facilement (badges de quai, LV).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$À l'enlèvement, vous constatez 2 palettes filmées éventrées. Que faites-vous sur la lettre de voiture ?$mft$,
    $mft$[
      {"id":"a","label":"Des réserves écrites précises (nombre, localisation, nature des dégâts), photos à l'appui","is_correct":true},
      {"id":"b","label":"Rien : c'est le problème de l'expéditeur","is_correct":false},
      {"id":"c","label":"La mention « colis abîmé » suffit","is_correct":false},
      {"id":"d","label":"Un appel oral à l'exploitation, sans écrit","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['fimo-fco','theme-2','qcm-v1'], 'FIMO-T2-QCM-03', false,
    $mft$Sans réserve précise à l'enlèvement, l'avarie sera présumée survenue pendant le transport : donc imputée au transporteur. La précision fait la valeur de la réserve.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$En contrôle routier, sur quelle période devez-vous pouvoir justifier vos activités ?$mft$,
    $mft$[
      {"id":"a","label":"La journée en cours et les 28 jours précédents","is_correct":true},
      {"id":"b","label":"La journée en cours uniquement","is_correct":false},
      {"id":"c","label":"Les 7 derniers jours","is_correct":false},
      {"id":"d","label":"Les 90 derniers jours","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['fimo-fco','theme-2','qcm-v1'], 'FIMO-T2-QCM-04', false,
    $mft$Jour en cours + 28 jours : carte, impressions et attestations d'activités comblent les périodes sans enregistrement.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Vous avez déjà utilisé vos deux journées à 10 h de conduite cette semaine. Jeudi, l'exploitation vous propose une tournée nécessitant 9 h 45 de volant. Que répondez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Non : le plafond est revenu à 9 h, la tournée doit être adaptée","is_correct":true},
      {"id":"b","label":"Oui : 45 minutes de plus, ça passe","is_correct":false},
      {"id":"c","label":"Oui, en écourtant la pause de 45 minutes","is_correct":false},
      {"id":"d","label":"Oui, si le client est prévenu","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','theme-2','qcm-v1'], 'FIMO-T2-QCM-05', false,
    $mft$Les deux extensions à 10 h sont consommées : 9 h maxi. Ni la pause ni l'accord du client ne créent du temps de conduite légal.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Votre carte de conducteur reste bloquée dans le lecteur, illisible, à 300 km de la base. Quelle est la bonne réaction ?$mft$,
    $mft$[
      {"id":"a","label":"Impressions papier signées en début et fin de journée, exploitation prévenue, déclaration et remplacement de la carte dans les délais","is_correct":true},
      {"id":"b","label":"Emprunter la carte d'un collègue jusqu'au retour","is_correct":false},
      {"id":"c","label":"Rouler sans rien : la panne excuse tout","is_correct":false},
      {"id":"d","label":"Débrancher le tachygraphe pour éviter les erreurs","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','theme-2','qcm-v1'], 'FIMO-T2-QCM-06', false,
    $mft$La procédure de secours existe : impressions annotées et signées, puis remplacement. Carte d'autrui ou manipulation = fraude grave.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Après une semaine à 56 h de conduite, combien pouvez-vous conduire au maximum la semaine suivante ?$mft$,
    $mft$[
      {"id":"a","label":"34 heures","is_correct":true},
      {"id":"b","label":"56 heures","is_correct":false},
      {"id":"c","label":"45 heures","is_correct":false},
      {"id":"d","label":"28 heures","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','theme-2','qcm-v1'], 'FIMO-T2-QCM-07', false,
    $mft$90 h maximum sur deux semaines consécutives : 90 − 56 = 34 h. La grosse semaine se paie la semaine d'après : à anticiper au planning.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Samedi 21 h 15, il vous reste 1 h 30 de route avec votre 44 t de marchandise générale. Que faites-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Vous vous arrêtez avant 22 h dans un endroit sûr : l'interdiction s'applique de samedi 22 h à dimanche 22 h","is_correct":true},
      {"id":"b","label":"Vous continuez : entamé avant 22 h, le trajet peut s'achever","is_correct":false},
      {"id":"c","label":"Vous continuez en évitant l'autoroute","is_correct":false},
      {"id":"d","label":"Vous continuez : la marchandise générale est dérogataire","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','theme-2','qcm-v1'], 'FIMO-T2-QCM-08', false,
    $mft$Pas de « droit de finir » : à 22 h, un > 7,5 t non dérogataire est à l'arrêt, quel que soit le réseau. L'anticipation appartient au planning ET au conducteur qui voit l'heure tourner.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Quel document prouve, en contrôle, que votre camion roule pour une entreprise de transport autorisée ?$mft$,
    $mft$[
      {"id":"a","label":"La copie conforme de la licence, présente à bord","is_correct":true},
      {"id":"b","label":"Votre carte de qualification","is_correct":false},
      {"id":"c","label":"La lettre de voiture","is_correct":false},
      {"id":"d","label":"Le certificat d'immatriculation","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','theme-2','qcm-v1'], 'FIMO-T2-QCM-09', false,
    $mft$La copie conforme atteste l'autorisation de l'ENTREPRISE ; la CQC vous concerne vous, la LV concerne la marchandise. Trois preuves, trois objets.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Votre journée a commencé à 5 h. Vous voulez prendre un repos journalier normal non fractionné : à quelle heure au plus tard doit-il DÉBUTER ?$mft$,
    $mft$[
      {"id":"a","label":"18 h (11 h de repos achevées dans la fenêtre de 24 h ouverte à 5 h)","is_correct":true},
      {"id":"b","label":"20 h","is_correct":false},
      {"id":"c","label":"Minuit","is_correct":false},
      {"id":"d","label":"Peu importe, seule la durée compte","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['fimo-fco','theme-2','qcm-v1'], 'FIMO-T2-QCM-10', false,
    $mft$Fenêtre 5 h → 5 h : un repos de 11 h doit être TERMINÉ à 5 h du matin : il débute au plus tard à 18 h. C'est la fin du repos qui doit tenir dans la fenêtre, pas seulement son début.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$L'exploitation vous écrit : « le client jure que ça fait 27 t, charge tout, tu pèseras au retour ». Les essieux semblent écrasés. Votre réaction professionnelle :$mft$,
    $mft$[
      {"id":"a","label":"Demander une pesée avant de partir, ou refuser par écrit : en surcharge, c'est vous qui êtes contrôlé","is_correct":true},
      {"id":"b","label":"Partir : l'ordre écrit de l'exploitation vous couvre","is_correct":false},
      {"id":"c","label":"Partir en roulant doucement","is_correct":false},
      {"id":"d","label":"Partir de nuit pour éviter les contrôles","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['fimo-fco','theme-2','qcm-v1'], 'FIMO-T2-QCM-11', false,
    $mft$Aucun ordre ne « couvre » une infraction : le conducteur du véhicule en surcharge est en première ligne (amende, immobilisation). Vérifier, alerter, refuser par écrit : c'est le geste pro.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Vous revenez de deux semaines de congés. À l'insertion de votre carte, comment justifier cette période sans enregistrement ?$mft$,
    $mft$[
      {"id":"a","label":"Par l'attestation d'activités établie par l'employeur (et la saisie manuelle à l'insertion)","is_correct":true},
      {"id":"b","label":"Aucune justification n'est nécessaire","is_correct":false},
      {"id":"c","label":"En recopiant les journées manquantes sur la carte d'un collègue","is_correct":false},
      {"id":"d","label":"Par une simple déclaration orale au contrôleur","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['fimo-fco','theme-2','qcm-v1'], 'FIMO-T2-QCM-12', false,
    $mft$Les périodes sans conduite (congés, maladie, autre poste) se justifient par l'attestation d'activités de l'employeur, complétée par les saisies manuelles : le contrôleur doit pouvoir reconstituer les 28 jours.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Après combien de conduite cumulée votre pause devient-elle obligatoire, et quelle est sa durée ?$mft$,
   $mft$Après 4 h 30 de conduite : 45 minutes (fractionnables en 15 puis 30).$mft$,
   2, 'facile', ARRAY['fimo-fco','theme-2','question-courte'], 'FIMO-T2-QC-01', false,
   $mft$Les deux éléments sont attendus.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Citez les trois positions du sélecteur d'activités utilisées à l'arrêt, et un exemple pour chacune.$mft$,
   $mft$Autres travaux (chargement, plein, administratif), disponibilité (attente sans obligation au poste), repos/pause (temps libre).$mft$,
   2, 'facile', ARRAY['fimo-fco','theme-2','question-courte'], 'FIMO-T2-QC-02', false,
   $mft$Trois positions + exemples cohérents.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Quels documents liés AU TRANSPORT (hors titres personnels et papiers du véhicule) doivent se trouver à bord ?$mft$,
   $mft$La copie conforme de la licence et la lettre de voiture (plus les documents spécifiques : ADR, détachement, selon le cas).$mft$,
   2, 'facile', ARRAY['fimo-fco','theme-2','question-courte'], 'FIMO-T2-QC-03', false,
   $mft$Copie conforme + LV attendues ; les spécifiques en bonus.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Le chargement d'un camion au hayon compte-t-il comme pause, repos ou travail ?$mft$,
   $mft$Comme du travail (« autres travaux ») : ni pause ni repos.$mft$,
   2, 'moyen', ARRAY['fimo-fco','theme-2','question-courte'], 'FIMO-T2-QC-04', false,
   $mft$La pause est du temps librement disponible.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Votre carte de conducteur est volée pendant un déplacement. Citez les deux gestes immédiats côté enregistrement.$mft$,
   $mft$Impressions papier en début et fin de journée, annotées et signées, et déclaration/demande de remplacement dans les délais (exploitation prévenue).$mft$,
   2, 'moyen', ARRAY['fimo-fco','theme-2','question-courte'], 'FIMO-T2-QC-05', false,
   $mft$Impressions signées + déclaration ; jamais la carte d'un tiers.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Combien de périodes de 24 h au maximum peuvent s'écouler entre la fin d'un repos hebdomadaire et le début du suivant ?$mft$,
   $mft$Six périodes de 24 heures.$mft$,
   2, 'moyen', ARRAY['fimo-fco','theme-2','question-courte'], 'FIMO-T2-QC-06', false,
   $mft$La règle des 6 × 24 h.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$À la livraison, quels deux gestes sur la lettre de voiture protègent votre entreprise ?$mft$,
   $mft$Faire émarger le destinataire (date, heure, identité) et noter précisément ses éventuelles réserves.$mft$,
   2, 'moyen', ARRAY['fimo-fco','theme-2','question-courte'], 'FIMO-T2-QC-07', false,
   $mft$Émargement + réserves consignées.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Sur quel créneau votre 44 t de marchandise générale est-il interdit de circuler le week-end, et que faites-vous si la tournée du samedi menace de déborder ?$mft$,
   $mft$Du samedi 22 h au dimanche 22 h ; alerter l'exploitation AVANT le créneau et se positionner à l'arrêt avant 22 h.$mft$,
   2, 'moyen', ARRAY['fimo-fco','theme-2','question-courte'], 'FIMO-T2-QC-08', false,
   $mft$Créneau exact + réflexe d'anticipation.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$En quoi consiste le repos journalier fractionné, et quelle durée totale atteint-il ?$mft$,
   $mft$Une première période de 3 h puis une seconde de 9 h, soit 12 h au total (compte comme repos normal).$mft$,
   2, 'difficile', ARRAY['fimo-fco','theme-2','question-courte'], 'FIMO-T2-QC-09', false,
   $mft$Ordre imposé 3 puis 9.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Pourquoi l'heure affichée par le chronotachygraphe ne correspond-elle pas à votre montre, et quelle précaution en tirer ?$mft$,
   $mft$L'appareil enregistre en temps universel (UTC) : convertir l'heure locale (une à deux heures d'écart en France) avant toute saisie ou lecture.$mft$,
   2, 'difficile', ARRAY['fimo-fco','theme-2','question-courte'], 'FIMO-T2-QC-10', false,
   $mft$Source classique d'erreurs de saisie manuelle.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) — barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Déroulez une journée complète conforme pour cette mission : prise de service 5 h, trajet aller 4 h de conduite, déchargement 1 h, trajet retour 4 h 30 de conduite. Placez pauses et repos avec les horaires.$mft$,
   $mft$Réponse modèle. 5 h 00 prise de service (carte insérée, tour du véhicule). Conduite 5 h 15 → 9 h 15 (4 h 00). 9 h 15 → 10 h 15 : déchargement (« autres travaux », 1 h) : n'interrompt pas l'obligation de pause liée à la conduite cumulée : il reste 30 min de conduite possibles avant pause. Option propre : prendre la pause de 45 min à 10 h 15 (ou 15 min avant le déchargement puis 30 min après : fractionnement 15 + 30 conforme). 11 h 00 : départ retour, conduite 4 h 30 d'un bloc jusqu'à 15 h 30 : la deuxième tranche atteint exactement 4 h 30 : pause obligatoire si la journée continuait. Total conduite : 8 h 30 (≤ 9 h : conforme sans utiliser une extension). 15 h 30 → 16 h 00 : fin de service (pleins, documents), retrait de carte. Repos journalier : débuté à 16 h 00, 11 h achevées à 3 h 00 : dans la fenêtre de 24 h ouverte à 5 h 00 : conforme, avec marge pour une prise de service au plus tôt à 3 h 00 le lendemain (ou repos réduit 9 h si besoin, dans la limite de trois).$mft$,
   $mft$Barème /5 : première pause correctement positionnée par rapport aux 4 h 30 cumulées, fractionnement licite (1,5 pt) ; déchargement classé travail sans valoir pause (1 pt) ; total conduite 8 h 30 vérifié (1 pt) ; repos 11 h calé dans la fenêtre de 24 h avec horaires (1,5 pt). Erreurs fréquentes : compter le déchargement comme pause ; oublier la fenêtre des 24 h.$mft$,
   5, 'facile', ARRAY['fimo-fco','theme-2','question-redigee'], 'FIMO-T2-QR-01', false,
   $mft$Construction d'une journée conforme : l'exercice roi de l'évaluation.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Listez les gestes chronotachygraphe d'une journée parfaite, de la prise de service à la fin, puis les trois erreurs de sélecteur les plus courantes et leurs conséquences.$mft$,
   $mft$Réponse modèle. Journée parfaite : insertion de SA carte à la prise de service, saisie du pays, saisie manuelle des activités effectuées carte retirée depuis le dernier retrait (repos) ; en journée : sélecteur basculé AU MOMENT du changement : autres travaux au chargement/plein/administratif, disponibilité en attente libre, repos à la pause ; contrôle visuel du symbole affiché ; en fin de service : pays de fin, retrait de la carte, impression si anomalie. Trois erreurs courantes : 1) rester sur « autres travaux » pendant la pause : la pause disparaît des données : infraction de pause apparente, journée faussée ; 2) rester sur « repos » pendant un déchargement : donnée mensongère, recoupable (badges, LV) : suspicion de fraude ; 3) oublier la saisie manuelle à l'insertion (trou entre deux services) : périodes inexpliquées au contrôle : attestations à produire, temps perdu, doute installé. Fil rouge : les données doivent raconter exactement la journée : elles sont votre meilleure défense quand elles sont justes, votre pire accusateur quand elles mentent.$mft$,
   $mft$Barème /5 : séquence complète insertion→pays→saisies→sélecteur→fin (2 pts) ; bascule « au moment » explicitée (0,5 pt) ; trois erreurs avec conséquences distinctes (2 pts) ; conclusion sur la valeur probatoire (0,5 pt). Erreurs fréquentes : oublier les saisies manuelles ; conséquences vagues (« c'est interdit ») sans mécanisme.$mft$,
   5, 'facile', ARRAY['fimo-fco','theme-2','question-redigee'], 'FIMO-T2-QR-02', false,
   $mft$La journée tachy exemplaire et ses anti-modèles.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Cas. Il est 14 h, vous avez pris votre service à 6 h, conduit 7 h 40 au total (pauses réglementaires prises), et il reste 180 km d'autoroute (environ 2 h) pour livrer un client qui ferme à 17 h. Vous n'avez plus d'extension à 10 h disponible cette semaine. Analysez et décidez.$mft$,
   $mft$Réponse modèle. Contrainte : plafond du jour 9 h (extensions épuisées) : il reste 1 h 20 de conduite légale : les 2 h nécessaires ne passent PAS. Analyse des fausses solutions : rouler quand même : dépassement enregistré, infraction pour vous et l'entreprise, indéfendable en cas d'accident ; « oublier » la carte ou jouer du sélecteur : fraude, bien pire que le retard. Décision professionnelle : alerter l'exploitation IMMÉDIATEMENT (14 h, pas 15 h 30) avec les données : conduite restante 1 h 20, distance 180 km : options : 1) relais par un autre conducteur en cours de route ; 2) report de la livraison au lendemain matin (client prévenu par l'exploitation, créneau recalé) ; 3) rapprochement maximal : rouler 1 h 20, se poser à ~60 km du client, repos, livraison à l'ouverture. La moins mauvaise option se choisit avec l'exploitation : mais AUCUNE ne consiste à dépasser. Leçon : l'alerte précoce transforme un problème de conducteur en solution d'exploitation ; l'alerte tardive transforme tout en infraction.$mft$,
   $mft$Barème /5 : calcul du solde 1 h 20 vs besoin 2 h (1,5 pt) ; rejet motivé du dépassement et de la fraude (1 pt) ; alerte précoce + au moins deux options réalistes (relais, report, rapprochement) (2 pts) ; leçon d'anticipation (0,5 pt). Erreurs fréquentes : « finir et s'expliquer après » ; écourter la pause pour gagner du temps de conduite (sans effet légal).$mft$,
   5, 'moyen', ARRAY['fimo-fco','theme-2','question-redigee'], 'FIMO-T2-QR-03', false,
   $mft$Le dilemme de fin de journée : décision sous contrainte, réflexe d'alerte.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Contrôle routier complet : racontez le déroulement idéal, de la signalisation au redémarrage, en précisant ce que vous présentez, dans quel ordre, et votre attitude si une infraction est relevée.$mft$,
   $mft$Réponse modèle. Interception : ralentir, clignotant, suivre les indications vers la zone de contrôle, moteur coupé, frein de parc, rester courtois et disponible. Présentation ordonnée : 1) vos titres : permis, carte de qualification, carte de conducteur ; 2) les données : carte dans le lecteur pour lecture, impressions/attestations couvrant les 28 jours si besoin ; 3) le véhicule : certificat d'immatriculation, contrôle technique, assurance ; 4) le transport : copie conforme de la licence, lettre de voiture (et ADR le cas échéant). Pendant la lecture : répondre aux questions factuellement, sans commenter ni « expliquer » spontanément les données ; laisser le contrôleur dérouler. Si une infraction est relevée : écouter la qualification, LIRE le procès-verbal avant de signer, porter des observations écrites si désaccord factuel (la signature n'emporte pas reconnaissance des faits selon les cas, les observations préservent la discussion) ; consignation ou amende selon la procédure ; demander le document remis. Ensuite : prévenir l'exploitation immédiatement (suites, contestation éventuelle, analyse interne), reprendre la route sereinement : un contrôle bien vécu dure vingt minutes ; c'est la préparation quotidienne qui le rend indolore.$mft$,
   $mft$Barème /5 : mise en sécurité et attitude (1 pt) ; présentation complète et ordonnée des quatre familles (2 pts) ; sobriété face aux données (0,5 pt) ; gestion de l'infraction : lecture, observations écrites, information de l'exploitation (1,5 pt). Erreurs fréquentes : justifications spontanées qui aggravent ; signer sans lire ; oublier de prévenir l'entreprise.$mft$,
   5, 'moyen', ARRAY['fimo-fco','theme-2','question-redigee'], 'FIMO-T2-QR-04', false,
   $mft$Le contrôle routier scénarisé de bout en bout.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$À la livraison, le réceptionnaire refuse de signer la lettre de voiture « par principe » mais accepte la marchandise. Par ailleurs il annonce oralement « 3 cartons écrasés ». Traitez la situation.$mft$,
   $mft$Réponse modèle. Enjeu : sans émargement, la preuve de la livraison s'affaiblit ; des dommages annoncés oralement sans écrit se transformeront en litige invérifiable. Conduite : 1) rester calme et professionnel : expliquer que la signature constate la REMISE (pas la renonciation aux réserves : il peut signer ET réserver) ; 2) si le refus persiste : ne pas repartir sans trace : noter sur la LV « le destinataire accepte la marchandise et refuse de signer », date, heure, identité déclinée du réceptionnaire, et prévenir l'exploitation depuis le quai (message écrit horodaté) ; photographier la marchandise déposée en l'état ; 3) pour les « 3 cartons écrasés » : demander une réserve ÉCRITE précise sur la LV ; à défaut, photographier les cartons désignés et noter la déclaration orale ; ne JAMAIS reconnaître par écrit une responsabilité (« c'est ma faute ») : les faits, pas les conclusions ; 4) transmettre le tout (LV annotée, photos, heure) à l'exploitation le jour même : les délais de protestation courent vite. Leçon : votre stylo et votre téléphone sont vos outils de preuve ; un départ « pour ne pas faire d'histoires » se paie des semaines plus tard.$mft$,
   $mft$Barème /5 : pédagogie signature/réserves (1 pt) ; trace écrite du refus avec mentions utiles + alerte exploitation (1,5 pt) ; traitement écrit/photo des dommages annoncés sans aveu de responsabilité (1,5 pt) ; transmission immédiate et enjeu des délais (1 pt). Erreurs fréquentes : repartir sans écrit ; consigner une reconnaissance de faute.$mft$,
   5, 'moyen', ARRAY['fimo-fco','theme-2','question-redigee'], 'FIMO-T2-QR-05', false,
   $mft$Litige de quai : préserver la preuve sans envenimer.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Semaine réelle : lundi 9 h de conduite, mardi 10 h, mercredi 8 h 30, jeudi 10 h, vendredi vous êtes planifié à 9 h 30. a) Ce planning est-il conforme ? b) Corrigez-le si besoin. c) Quelle vigilance pour la semaine suivante ?$mft$,
   $mft$Réponse modèle. a) Extensions : mardi (10 h) et jeudi (10 h) : les deux rallonges hebdomadaires sont consommées : vendredi est plafonné à 9 h : 9 h 30 NON conforme. Total si vendredi restait à 9 h 30 : 47 h 30 ; corrigé à 9 h : 9 + 10 + 8,5 + 10 + 9 = 46 h 30 (≤ 56 h : conforme). b) Correction : ramener vendredi à 9 h de conduite maximum : réduire la tournée, basculer un point de livraison, ou prévoir un relais pour l'excédent de 30 minutes. c) Semaine suivante : plafond bi-hebdomadaire 90 h : 90 − 46,5 = 43 h 30 de conduite maximum : encore confortable ici, mais à surveiller si la semaine avait frôlé 56 h ; et les compteurs d'extensions repartent à deux : ne pas les griller dès lundi-mardi si la fin de semaine s'annonce chargée. Réflexe : le conducteur suit SES compteurs (extensions, cumul hebdo, bi-hebdo) sans attendre que l'exploitation le fasse pour lui.$mft$,
   $mft$Barème /5 : détection des deux extensions consommées et non-conformité du vendredi (2 pts) ; totaux exacts 46 h 30 / marge bi-hebdo 43 h 30 (1,5 pt) ; correction réaliste (1 pt) ; réflexe de suivi personnel des compteurs (0,5 pt). Erreurs fréquentes : autoriser une « troisième » rallonge ; oublier le calcul bi-hebdomadaire.$mft$,
   5, 'difficile', ARRAY['fimo-fco','theme-2','question-redigee'], 'FIMO-T2-QR-06', false,
   $mft$Audit d'un planning hebdomadaire : compteurs et corrections. Calculs vérifiés.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Vous êtes tractionnaire pour un commissionnaire. Au chargement chez son client, on vous demande de signer une LV mentionnant 24 t alors que le récapitulatif de préparation affiché indique 26,4 t, et de « partir vite ». Analysez les risques et construisez votre réponse en cinq gestes.$mft$,
   $mft$Réponse modèle. Risques : rouler en surcharge probable (26,4 t réelles vs 24 annoncées) : contrôle = amende + immobilisation POUR VOUS ; signer une LV à 24 t que vous savez fausse : vous validez une déclaration inexacte : votre marge de recours contre l'expéditeur fond ; accident avec surcharge : responsabilités aggravées. Le montage (commissionnaire → client chargeur) ne change rien sur la route : le conducteur du véhicule en infraction est en première ligne. Cinq gestes : 1) ne PAS signer en l'état : signaler calmement l'écart constaté (récapitulatif affiché photographié) ; 2) demander la pesée ou la correction de la LV au poids réel : vérifier la compatibilité avec la charge utile de l'ensemble ; 3) alerter l'exploitation par écrit (photo + message horodaté) : elle traite avec le commissionnaire ; 4) si correction impossible et charge réellement excédentaire : refuser le départ ou faire délester : proposer le fractionnement (reliquat sur un second voyage) ; 5) consigner l'incident (heure, interlocuteurs) : si le client insiste régulièrement, l'entreprise doit requalifier la relation. Un « pars vite » n'a jamais payé une amende ni relevé un camion couché.$mft$,
   $mft$Barème /5 : identification du double risque surcharge + LV sciemment fausse (1,5 pt) ; position du conducteur en première ligne malgré la chaîne commissionnaire (1 pt) ; cinq gestes concrets et ordonnés avec trace écrite (2 pts) ; fermeté professionnelle sans conflit (0,5 pt). Erreurs fréquentes : signer « en réservant oralement » ; croire que le commissionnaire assume à votre place sur la route.$mft$,
   5, 'difficile', ARRAY['fimo-fco','theme-2','question-redigee'], 'FIMO-T2-QR-07', false,
   $mft$Pression au chargement : écart de poids et LV inexacte, réponse en cinq gestes.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Votre entreprise vous informe qu'une analyse mensuelle a détecté sur VOTRE carte : deux pauses de 38 et 41 minutes (au lieu de 45), et une journée à 9 h 12 de conduite (sans extension disponible). Préparez votre entretien : comment vérifier, expliquer, corriger : et que risquez-vous à recommencer ?$mft$,
   $mft$Réponse modèle. Vérifier : demander les relevés détaillés (dates, heures) et les confronter à votre souvenir et vos documents (LV des jours concernés) : erreurs possibles : oubli de bascule du sélecteur (pause réelle prise mais enregistrée en travail), UTC mal converti sur une saisie manuelle, attente de quai classée à tort. Expliquer sans se défausser : si les infractions sont réelles (pauses écourtées « pour finir », dépassement de 12 minutes), le reconnaître : minimiser ou inventer détruit la confiance et aggrave en cas de contrôle externe ultérieur. Corriger : réflexes concrets : alarme personnelle à 4 h de conduite, pause posée AVANT la contrainte client, alerte exploitation dès qu'une tournée menace le plafond (leçon du dilemme de 14 h), vigilance sélecteur à chaque arrêt. Risques en cas de récidive : sanctions internes (l'entreprise DOIT réagir : son honorabilité et ses analyses sont contrôlées), amendes personnelles en contrôle routier, et responsabilité lourde si un accident survenait en période irrégulière. Conclure l'entretien en demandant un point télématique à 30 jours : montrer la correction vaut mieux que la promettre.$mft$,
   $mft$Barème /5 : démarche de vérification avec causes d'erreur plausibles (1,5 pt) ; posture de reconnaissance sans défausse (1 pt) ; corrections concrètes et datées (1,5 pt) ; conscience des risques de récidive pour soi et l'entreprise (1 pt). Erreurs fréquentes : contester en bloc ; promettre sans mécanisme de correction.$mft$,
   5, 'difficile', ARRAY['fimo-fco','theme-2','question-redigee'], 'FIMO-T2-QR-08', false,
   $mft$L'entretien post-analyse : professionnalisme face à ses propres données.$mft$);

  RAISE NOTICE 'Thème 2 FIMO/FCO créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $fimot2$;
