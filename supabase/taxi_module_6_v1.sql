-- =====================================================================
-- TAXI / VTC (T3P) : MODULE 6 : CONNAISSANCE DU TERRITOIRE ET ITINÉRAIRES
-- v1 (juillet 2026)
-- Lire une carte, connaître les grands axes, aéroports et gares,
-- estimer durées et distances ; le GPS assiste, le professionnel décide.
-- ⚠ STATUT : questions insérées avec active = false (« à valider »).
-- Idempotent : DELETE ciblés par slug/source_ref, rejouable sans doublon.
-- =====================================================================

DO $taxim6$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid;
  v_quiz uuid; v_q uuid; v_ord int := 0;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'taxi-vtc';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation taxi-vtc introuvable.'; END IF;

  INSERT INTO public.blocs (id, code, title, description, "order") VALUES (50, 'TAXI-VTC', 'Taxi et VTC : transport public particulier de personnes', 'Préparation aux examens taxi et VTC (T3P) organisés par les chambres de métiers et de l''artisanat : épreuves communes, spécifiques et pratique.', 50) ON CONFLICT DO NOTHING;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'TAXI-VTC';

  DELETE FROM public.question_bank WHERE source_ref LIKE 'TAXI-M6-%';
  DELETE FROM public.modules WHERE slug = 'taxi-vtc-territoire';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 6 : Connaissance du territoire et itinéraires',
    'taxi-vtc-territoire', v_bloc,
    'Lire une carte, connaître les grands axes, aéroports et gares, estimer durées et distances : l''épreuve de connaissance du territoire, et le sens de l''itinéraire au quotidien.',
    'intermediaire', 240, 60) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 60, true);

  -- ─── Leçon 1 : Grands axes, aéroports et gares ─────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'grands-axes-poles',
    'Grands axes, aéroports et gares : la carte mentale du chauffeur',
    $mft$> 🎯 **Objectifs**
> - Mémoriser les dix autoroutes structurantes et le rôle de chacune.
> - Associer chaque grand aéroport et chaque gare parisienne à ses dessertes.
> - Construire la carte mentale qui fait de vous le décideur en course.

## Pourquoi une carte mentale à l'heure du GPS

L'épreuve de connaissance du territoire vérifie une chose simple : que vous savez situer les grands axes, les aéroports et les gares sans assistance. Ce n'est pas un caprice d'examinateur. En course, le client qui annonce « je prends l'Eurostar » attend que vous rouliez vers la bonne gare sans consulter un écran ; et vous ne pouvez détecter l'itinéraire aberrant d'un GPS que si vous savez déjà, en gros, par où passe le trajet. La carte mentale est à la fois votre outil de contrôle et votre argument de professionnalisme : elle vous permet d'annoncer un axe, une durée plausible et un ordre de prix dès la prise en charge.

## Les dix autoroutes structurantes

| Autoroute | Liaison | Rôle à retenir |
| --- | --- | --- |
| A1 | Paris-Lille | L'axe du nord, porte vers les Hauts-de-France et le secteur de Roissy |
| A4 | Paris-Strasbourg | L'axe de l'est |
| A6 | Paris-Lyon | Le grand départ vers le sud-est |
| A7 | Lyon-Marseille | La descente de la vallée du Rhône vers le grand sud |
| A8 | Aix-Nice | La desserte de la Provence littorale et de la Côte d'Azur |
| A9 | Orange-Espagne | L'axe languedocien : Montpellier, Perpignan, la frontière espagnole |
| A10 | Paris-Bordeaux | L'axe atlantique du sud-ouest |
| A13 | Paris-Normandie | La sortie ouest vers Rouen et la côte normande |
| A75 | Clermont-Ferrand vers la Méditerranée | La traversée du Massif central, alternative à la vallée du Rhône |
| A89 | Bordeaux-Lyon | La grande transversale est-ouest, sans repasser par Paris |

> 💡 **Astuce**
> Mémorisez en étoile depuis Paris, dans le sens des aiguilles d'une montre : A1 (nord), A4 (est), A6 (sud-est), A10 (sud-ouest), A13 (ouest). Ajoutez ensuite les prolongements et transversales : l'A7 prolonge l'A6 au sud de Lyon, l'A9 bifurque vers l'Espagne, l'A8 dessert la Côte d'Azur, l'A75 et l'A89 traversent le centre du pays.

## Les aéroports que vos clients fréquentent

| Aéroport | À retenir |
| --- | --- |
| Paris-Charles de Gaulle (CDG) | Le premier aéroport du pays, au nord-est de Paris, hub international |
| Paris-Orly | Le deuxième aéroport parisien, au sud de la capitale |
| Lyon-Saint Exupéry | La porte aérienne de la région lyonnaise |
| Nice | La desserte de la Côte d'Azur |
| Marseille-Provence | La desserte de Marseille et de sa région |
| Toulouse-Blagnac | Accolé à la métropole toulousaine |
| Bordeaux | La desserte de la métropole bordelaise |
| Nantes | La desserte de la métropole nantaise et de sa région |

## Les six grandes gares parisiennes

| Gare | Dessertes principales |
| --- | --- |
| Gare du Nord | Lille, Londres (Eurostar), Bruxelles |
| Gare de l'Est | L'est du pays |
| Gare de Lyon | Le Sud-Est |
| Gare Montparnasse | L'Ouest et le Sud-Ouest |
| Gare Saint-Lazare | La Normandie et l'ouest francilien |
| Gare d'Austerlitz | L'axe classique vers le centre du pays |

> 📌 **À retenir**
> Les réflexes qui sauvent une course : « Eurostar » ou « Lille » = gare du Nord ; « TGV pour Marseille » = gare de Lyon ; « Rennes, Nantes ou Bordeaux en train » = Montparnasse. L'erreur de gare fait rater un train au client : c'est la faute la plus coûteuse en confiance.

## Les villes-clés par région

Pour chaque grande région, mémorisez la métropole et deux ou trois villes secondaires : Hauts-de-France (Lille, Amiens), Grand Est (Strasbourg, Reims, Metz, Nancy), Auvergne-Rhône-Alpes (Lyon, Grenoble, Saint-Étienne, Clermont-Ferrand), Provence-Alpes-Côte d'Azur (Marseille, Nice, Toulon, Aix-en-Provence), Occitanie (Toulouse, Montpellier, Perpignan), Nouvelle-Aquitaine (Bordeaux, Limoges, Poitiers), Pays de la Loire (Nantes, Angers, Le Mans), Bretagne (Rennes, Brest), Normandie (Rouen, Caen, Le Havre), Centre-Val de Loire (Orléans, Tours), Bourgogne-Franche-Comté (Dijon, Besançon). Associez chaque ville à son axe : Reims et Strasbourg regardent vers l'A4, Rouen et Caen vers l'A13, Montpellier vers l'A9.

> 🎓 **Pour l'examen**
> Les questions du module associent très souvent une ville, un aéroport ou une gare à l'axe ou à la desserte qui lui correspond. Entraînez-vous dans les deux sens : de la destination vers l'axe (« Bordeaux ? A10 ») et de l'axe vers les destinations (« A7 ? Lyon vers Marseille »).

## ✅ Synthèse

- **Dix autoroutes** : mémorisation en étoile depuis Paris, plus les prolongements (A7, A8, A9) et les transversales (A75, A89).
- **Huit aéroports et six gares parisiennes** : chaque pôle associé à ses dessertes, dans les deux sens.
- La carte mentale sert à **contrôler le GPS**, conseiller le client et estimer temps et prix dès la prise en charge.$mft$,
    $mft$Les dix autoroutes structurantes mémorisées en étoile depuis Paris, les huit grands aéroports, les six gares parisiennes et leurs dessertes, et les villes-clés par région.$mft$,
    1, 35) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : Lire une carte, estimer distances et temps ──────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'lire-carte-estimer',
    'Lire une carte, estimer distances et temps',
    $mft$> 🎯 **Objectifs**
> - Exploiter l'échelle, l'orientation et la légende d'une carte ou d'un plan.
> - Estimer une distance et un temps de parcours réalistes selon le contexte.
> - Choisir un itinéraire sous contraintes, comme le demande l'épreuve.

## Les trois clés d'une carte

**L'échelle** donne le rapport entre le papier et le terrain : au 1/100 000, 1 cm sur la carte représente 1 km dans la réalité ; au 1/25 000, 1 cm représente 250 m. C'est la première information à vérifier avant toute mesure. **L'orientation** : par convention, le nord est en haut, sauf indication contraire signalée par une flèche ou une rose des vents. **La légende** décode les symboles : type de route (autoroute, nationale, départementale), péages, échangeurs, zones urbaines, voies ferrées, aéroports. Une carte se lit comme un tableau de bord : échelle, orientation, légende, puis seulement l'itinéraire.

## Estimer une distance

Mesurez sur la carte, convertissez avec l'échelle, puis majorez : 8,5 cm au 1/100 000 font 8,5 km à vol d'oiseau, mais la route réelle est plus longue (tracé, relief, contournements). L'estimation du chauffeur n'a pas besoin d'être exacte au mètre : elle doit donner un ordre de grandeur fiable pour annoncer un temps et un prix plausibles.

## Estimer un temps : les ordres de grandeur du professionnel

| Contexte | Vitesse moyenne réelle | Repère pratique |
| --- | --- | --- |
| Autoroute | 110 à 130 km/h réels | Environ 2 km par minute : 100 km se roulent en 50 minutes environ |
| Ville dense | 15 à 25 km/h de moyenne | 5 km peuvent prendre 12 à 20 minutes |
| Route secondaire | Intermédiaire, très variable | Traversées d'agglomération et giratoires cassent la moyenne |

> ⚠️ **Attention**
> L'heure de pointe peut effondrer la vitesse moyenne en ville. Le professionnel annonce une **fourchette** (« comptez 15 à 25 minutes ») plutôt qu'un temps sec qu'il ne tiendra pas : la promesse tenue vaut mieux que la promesse flatteuse.

## Péages et itinéraires alternatifs

L'autoroute à péage achète du temps et de la fiabilité ; l'itinéraire alternatif gratuit économise le péage mais allonge le parcours et fiabilise moins l'horaire. L'arbitrage se fait sur trois critères : le temps estimé dans les conditions réelles du moment, le coût, et l'enjeu de l'horaire (un client qui a un avion ou un train à prendre paie la fiabilité). Dans tous les cas, le client est informé du choix et de son impact sur le prix : c'est lui qui arbitre en connaissance de cause.

## Ronds-points et numérotation des sorties

Sur autoroute, les sorties sont **numérotées** : les panneaux et la carte utilisent le même numéro, ce qui sécurise le guidage (« sortie 12 » se vérifie des deux côtés). Au rond-point, on compte les sorties **dans le sens de circulation de l'anneau**, en comptant chaque débouché rencontré depuis son entrée, y compris ceux que l'on ne prend pas : « prenez la troisième sortie » désigne le troisième débouché, pas la troisième rue qui vous intéresse.

## La méthode de l'épreuve : choisir un itinéraire sous contraintes

:::flow
1. Cadrer | Départ, destination, heure, exigence du client (rapidité, coût, horaire impératif)
2. Repérer | Les axes structurants disponibles sur la carte ou le plan
3. Mesurer | La distance de chaque option avec l'échelle
4. Convertir | En temps, avec la vitesse moyenne adaptée au contexte et à l'heure
5. Intégrer | Les contraintes : heure de pointe, travaux, péages, événements
6. Trancher | L'option au temps le plus fiable, pas la distance la plus courte
:::

**Exemple corrigé.** Mardi 8 h 30 : rejoindre l'aéroport soit par la rocade (22 km, fluide hors pointe, travaux signalés), soit par le centre (9 km en ville dense). Le centre donne 9 km à 15-25 km/h, soit 22 à 36 minutes : fourchette large mais bornée. La rocade serait rapide à vide, mais pointe du matin plus travaux rendent sa vitesse réelle imprévisible, avec un risque de blocage sans échappatoire. Pour un client contraint par un horaire, le centre offre le temps le plus **fiable** : c'est lui que le professionnel retient, en annonçant la fourchette haute.

> ❌ **Piège à éviter**
> Appliquer le repère autoroutier (2 km par minute) à un trajet urbain : à 20 km/h de moyenne, il faut environ 3 minutes par kilomètre, soit jusqu'à six fois plus. C'est l'erreur classique qui fait promettre l'impossible au client.

## ✅ Synthèse

- Carte : **échelle, orientation, légende** avant toute mesure ; au 1/100 000, 1 cm = 1 km.
- Temps : **110-130 km/h réels** sur autoroute, **15-25 km/h** en ville dense ; annoncer des fourchettes.
- Itinéraire : comparer des **temps estimés dans les conditions réelles** (pointe, travaux, péage), jamais des distances sèches.$mft$,
    $mft$L'échelle, l'orientation et la légende, les ordres de grandeur de vitesse (autoroute 110-130 réels, ville dense 15-25 km/h), l'arbitrage péage/alternatif et la méthode de choix d'itinéraire sous contraintes.$mft$,
    2, 35) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : Le GPS assiste, le professionnel décide ─────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'gps-et-sens-de-l-itineraire',
    'Le GPS assiste, le professionnel décide',
    $mft$> 🎯 **Objectifs**
> - Utiliser le GPS comme un assistant, jamais comme un décideur.
> - Connaître ses zones et anticiper les événements qui bouleversent le trafic.
> - Gérer l'itinéraire imposé par le client et préparer une ville nouvelle.

## L'assistant, pas le pilote

Le GPS calcule vite, mais sur des données qui peuvent être fausses ou périmées : plan de circulation modifié, rue passée en zone piétonne, fermeture temporaire. Le premier réflexe professionnel est la **vérification de cohérence** : si la destination est à 3 km en ligne directe et que l'appareil propose 25 km, quelque chose cloche (mauvaise adresse saisie, option de calcul inadaptée, données obsolètes). **Un détour absurde se refuse** : on s'arrête, on vérifie l'adresse et le paramétrage, on confronte la proposition à sa carte mentale (leçon 1). Le client ne paie pas les errements d'une machine.

## Connaître ses zones

Le GPS connaît la France entière superficiellement ; le professionnel connaît **son secteur** en profondeur :

- **les raccourcis licites** : un raccourci n'en est un que s'il est légal (pas de couloir réservé, pas de sens interdit « toléré ») ;
- **les sens interdits récents** : les plans de circulation évoluent, et la mise à jour des données peut tarder : les premières semaines après des travaux de voirie sont les plus piégeuses ;
- **les zones piétonnes** et leurs horaires, les bornes d'accès, les secteurs où la dépose est malaisée.

> 🔍 **Zoom**
> Le sens interdit récent est le piège classique du chauffeur qui « connaissait » la rue : la connaissance du territoire n'est pas un acquis, c'est un entretien. Chaque course dans un secteur remis en travaux est l'occasion de mettre à jour sa carte mentale.

## Anticiper les événements

Salons, matchs, concerts, manifestations : autant d'événements qui ferment des voiries, saturent des quartiers entiers et allongent les temps de parcours. Le professionnel fait sa **veille** : info trafic à la radio, applications de navigation et leurs signalements communautaires, sites et comptes officiels de la ville et de la préfecture (arrêtés de circulation), presse locale, calendrier du parc des expositions et du stade. Dix minutes de veille le matin évitent vingt minutes de détour subi le soir, et permettent d'annoncer au client un itinéraire de contournement crédible au lieu de découvrir la barrière avec lui.

## Le client impose SON itinéraire

Principe : **le client choisit, le chauffeur informe**. Si l'itinéraire demandé est plus long que celui que vous auriez retenu : annoncez **avant de démarrer** le surcoût probable, sans juger ni discuter la préférence du client (il a parfois ses raisons : habitude, mal des transports, souvenir d'un blocage). Ensuite, **tracez** la demande : annonce explicite, mention sur le support de course ou l'application selon l'outil utilisé. En cas de contestation du prix à l'arrivée, cette traçabilité protège les deux parties. Seule limite : l'itinéraire illégal (sens interdit, voie réservée, zone piétonne) se refuse calmement, en proposant l'alternative licite la plus proche du souhait exprimé.

## Préparer une prise de poste dans une ville nouvelle

:::timeline
1. J-7 | Carte et plan : axes structurants, pénétrantes, rocade, échelle du plan, quartiers denses
2. J-5 | Pôles générateurs de courses : gares, aéroport, hôpitaux, hôtels d'affaires, palais des congrès, stade
3. J-3 | Repérage terrain : rouler réellement les liaisons les plus demandées, noter sens interdits et zones piétonnes
4. J-2 | Événements de la semaine : salons, matchs, manifestations, arrêtés de circulation
5. J-1 | Routines : sources d'info trafic locales enregistrées, points de dépose et de stationnement repérés
6. Jour J | Premières courses sur les liaisons repérées, GPS en simple assistance, notes après chaque course
:::

> 🎓 **Pour l'examen**
> Les sujets aiment le cas du « GPS contre bon sens » : la bonne réponse valorise toujours la vérification, la connaissance locale et l'information du client, jamais l'obéissance aveugle à l'appareil ni son rejet complet.

## ✅ Synthèse

- Le GPS **assiste**, le professionnel **décide** : cohérence vérifiée, détour absurde refusé.
- Connaître ses zones (raccourcis licites, sens interdits récents, zones piétonnes) et **anticiper les événements** grâce aux sources d'info trafic.
- Itinéraire du client : **il choisit, vous informez** du surcoût probable avant de partir, et vous **tracez** la demande ; une ville nouvelle se prépare méthodiquement, de J-7 au jour J.$mft$,
    $mft$La vérification de cohérence du GPS, la connaissance fine de ses zones, la veille des événements, la gestion de l'itinéraire imposé par le client (information, surcoût, traçabilité) et la préparation d'une ville nouvelle.$mft$,
    3, 30) RETURNING id INTO v_l3;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : Territoire et itinéraires',
    'Vérifiez le module 6 : grands axes et pôles, lecture de carte et estimation des temps, GPS et sens de l''itinéraire.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Votre client doit rejoindre Lille depuis Paris en voiture avec vous. Quel axe autoroutier structure ce trajet ?$mft$,
    $mft$[
      {"id":"a","label":"L'A1, l'axe Paris-Lille","is_correct":true},
      {"id":"b","label":"L'A6, qui descend vers Lyon","is_correct":false},
      {"id":"c","label":"L'A13, qui part vers la Normandie","is_correct":false},
      {"id":"d","label":"L'A10, qui file vers Bordeaux","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-6','qcm-v1'], 'TAXI-M6-QCM-01', false,
    $mft$L'A1 est l'axe du nord (Paris-Lille). L'A6 (Lyon), l'A13 (Normandie) et l'A10 (Bordeaux) partent dans trois autres directions depuis Paris.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Un client vous demande de le déposer pour son Eurostar vers Londres. Vers quelle gare parisienne roulez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"La gare du Nord","is_correct":true},
      {"id":"b","label":"La gare de Lyon","is_correct":false},
      {"id":"c","label":"La gare Montparnasse","is_correct":false},
      {"id":"d","label":"La gare Saint-Lazare","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-6','qcm-v1'], 'TAXI-M6-QCM-02', false,
    $mft$La gare du Nord dessert Lille, Londres et Bruxelles. La gare de Lyon regarde vers le Sud-Est, Montparnasse vers l'Ouest et le Sud-Ouest, Saint-Lazare vers la Normandie.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Sur une carte au 1/100 000, vous mesurez 12 cm entre deux communes. Quelle distance cela représente-t-il sur le terrain ?$mft$,
    $mft$[
      {"id":"a","label":"Environ 12 km","is_correct":true},
      {"id":"b","label":"Environ 1,2 km","is_correct":false},
      {"id":"c","label":"Environ 120 km","is_correct":false},
      {"id":"d","label":"Environ 2,4 km","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-6','qcm-v1'], 'TAXI-M6-QCM-03', false,
    $mft$Au 1/100 000, 1 cm représente 1 km : 12 cm font donc 12 km à vol d'oiseau. Les autres valeurs correspondent à des erreurs de conversion d'échelle.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Votre GPS propose un itinéraire de 25 km alors que vous savez la destination à environ 3 km, accessible directement. Que faites-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Vous refusez ce détour absurde : vous vérifiez l'adresse et la cohérence, puis suivez l'itinéraire court que vous connaissez","is_correct":true},
      {"id":"b","label":"Vous suivez le GPS : la machine a forcément une bonne raison","is_correct":false},
      {"id":"c","label":"Vous éteignez le GPS pour le reste de la journée","is_correct":false},
      {"id":"d","label":"Vous demandez au client de trancher à votre place","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-6','qcm-v1'], 'TAXI-M6-QCM-04', false,
    $mft$Le GPS assiste, le professionnel décide : un détour incohérent signale une adresse mal saisie ou des données erronées. Suivre aveuglément coûte au client, éteindre l'appareil prive d'un outil utile, et la décision d'itinéraire relève du chauffeur.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Votre client atterrit à Nice et doit rejoindre Marseille par autoroute. Quel axe empruntez-vous principalement ?$mft$,
    $mft$[
      {"id":"a","label":"L'A8, qui relie Aix à Nice le long de la Provence littorale","is_correct":true},
      {"id":"b","label":"L'A9, l'axe d'Orange vers l'Espagne","is_correct":false},
      {"id":"c","label":"L'A7, la descente de Lyon vers Marseille","is_correct":false},
      {"id":"d","label":"L'A75, la traversée du Massif central","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-6','qcm-v1'], 'TAXI-M6-QCM-05', false,
    $mft$Nice-Marseille se joue sur l'A8 (Aix-Nice). L'A9 part d'Orange vers Montpellier et l'Espagne, l'A7 descend la vallée du Rhône depuis Lyon, l'A75 traverse le Massif central.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Course longue distance : un client part de Paris pour Bordeaux par la route. Quel axe structure ce trajet ?$mft$,
    $mft$[
      {"id":"a","label":"L'A10, l'axe atlantique du sud-ouest","is_correct":true},
      {"id":"b","label":"L'A4, qui file vers Strasbourg","is_correct":false},
      {"id":"c","label":"L'A6, qui descend vers Lyon","is_correct":false},
      {"id":"d","label":"L'A13, qui rejoint la Normandie","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-6','qcm-v1'], 'TAXI-M6-QCM-06', false,
    $mft$Paris-Bordeaux se joue sur l'A10. L'A4 (est), l'A6 (sud-est) et l'A13 (Normandie) desservent d'autres façades du territoire.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Vous devez parcourir 220 km essentiellement sur autoroute. Avec une vitesse réelle de 110 à 130 km/h, quel temps de roulage annoncez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Entre 1 h 40 et 2 h environ","is_correct":true},
      {"id":"b","label":"Environ 1 h 10","is_correct":false},
      {"id":"c","label":"Entre 3 h et 3 h 30","is_correct":false},
      {"id":"d","label":"Moins d'une heure","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-6','qcm-v1'], 'TAXI-M6-QCM-07', false,
    $mft$220 km à 110-130 km/h réels donnent 1 h 40 à 2 h de roulage. 1 h 10 supposerait près de 190 km/h, et 3 h correspondrait à une moyenne d'environ 70 km/h, irréaliste sur autoroute fluide.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un client pressé vous demande le temps nécessaire pour une course de 6 km en hypercentre à 18 h. Quelle estimation honnête lui donnez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Une fourchette de 15 à 25 minutes environ, la vitesse moyenne en ville dense étant de 15 à 25 km/h","is_correct":true},
      {"id":"b","label":"5 minutes, comme sur voie rapide","is_correct":false},
      {"id":"c","label":"Une heure au minimum, quoi qu'il arrive","is_correct":false},
      {"id":"d","label":"Exactement 10 minutes, montre en main","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-6','qcm-v1'], 'TAXI-M6-QCM-08', false,
    $mft$À 15-25 km/h de moyenne, 6 km prennent environ 15 à 24 minutes : on annonce une fourchette. 5 minutes supposerait plus de 70 km/h en ville, et promettre un temps exact en pleine pointe expose à décevoir.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Votre client exige de passer par les quais, itinéraire que vous savez plus long que votre proposition. Quelle est la conduite professionnelle ?$mft$,
    $mft$[
      {"id":"a","label":"Suivre l'itinéraire choisi par le client après l'avoir informé du surcoût probable, en gardant une trace de sa demande","is_correct":true},
      {"id":"b","label":"Refuser et imposer votre itinéraire, plus court","is_correct":false},
      {"id":"c","label":"Accepter sans rien dire et justifier le prix seulement à l'arrivée","is_correct":false},
      {"id":"d","label":"Refuser la course : un client qui choisit son itinéraire est un client difficile","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-6','qcm-v1'], 'TAXI-M6-QCM-09', false,
    $mft$Le client choisit, le chauffeur informe : le surcoût probable s'annonce AVANT le départ et la demande se trace en cas de contestation. Imposer son itinéraire, se taire jusqu'à l'arrivée ou refuser la course crée exactement le litige que l'on veut éviter.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Un client doit relier Bordeaux à Lyon par la route sans remonter par Paris. Quel axe répond à ce besoin ?$mft$,
    $mft$[
      {"id":"a","label":"L'A89, la grande transversale entre Bordeaux et Lyon","is_correct":true},
      {"id":"b","label":"L'A75, qui traverse le Massif central du nord au sud","is_correct":false},
      {"id":"c","label":"L'A10 puis l'A6, en repassant par la région parisienne","is_correct":false},
      {"id":"d","label":"L'A9, l'axe languedocien vers l'Espagne","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-6','qcm-v1'], 'TAXI-M6-QCM-10', false,
    $mft$L'A89 relie directement Bordeaux à Lyon d'ouest en est. L'A75 est un axe nord-sud par le Massif central, et remonter par l'A10 puis l'A6 rallonge précisément ce que le client veut éviter.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Épreuve type examen : mardi 8 h 15, deux itinéraires vers l'aéroport : une rocade de 22 km réputée fluide hors pointe, ou 9 km par le centre. Des travaux sont signalés sur la rocade. Quelle démarche est la bonne ?$mft$,
    $mft$[
      {"id":"a","label":"Estimer le temps de chaque option dans les conditions réelles du moment (pointe, travaux) et choisir le temps le plus fiable, pas la distance la plus courte","is_correct":true},
      {"id":"b","label":"Prendre systématiquement la distance la plus courte","is_correct":false},
      {"id":"c","label":"Prendre systématiquement la rocade : une voie rapide bat toujours le centre","is_correct":false},
      {"id":"d","label":"Laisser le GPS trancher sans analyser les contraintes","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-6','qcm-v1'], 'TAXI-M6-QCM-11', false,
    $mft$Le choix d'itinéraire se raisonne en temps fiable dans les conditions du moment : une rocade saturée par la pointe et les travaux peut perdre face à 9 km de centre à vitesse connue. Distance courte, voie rapide ou GPS seul ne sont des arguments qu'à conditions égales.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Vous prenez votre poste samedi dans une ville qui accueille le même jour un match et un salon. Quelle préparation fait la différence ?$mft$,
    $mft$[
      {"id":"a","label":"Identifier en amont les secteurs et horaires touchés (stade, parc des expositions), consulter les sources d'info trafic et prévoir des contournements","is_correct":true},
      {"id":"b","label":"Compter sur le GPS, qui recalculera en temps réel au milieu des fermetures","is_correct":false},
      {"id":"c","label":"Ne rien préparer : les événements ne concernent que les riverains","is_correct":false},
      {"id":"d","label":"Refuser toutes les courses proches du stade ce jour-là","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-6','qcm-v1'], 'TAXI-M6-QCM-12', false,
    $mft$Anticiper les événements (fermetures, saturation) permet de proposer des itinéraires réalistes et d'informer les clients. Le GPS subit les fermetures plus qu'il ne les anticipe, et refuser les courses n'est pas un modèle économique.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Un client pris en charge à Paris-Charles de Gaulle doit rejoindre Lille par la route. Quel axe autoroutier annoncez-vous ?$mft$,
   $mft$L'A1, l'axe Paris-Lille, qui dessert le nord du pays.$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-6','question-courte'], 'TAXI-M6-QC-01', false,
   $mft$L'axe du nord.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Votre client doit prendre un TGV pour Marseille au départ de Paris. À quelle gare le déposez-vous, et pourquoi ?$mft$,
   $mft$À la gare de Lyon, qui assure les dessertes du Sud-Est (dont Lyon et Marseille).$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-6','question-courte'], 'TAXI-M6-QC-02', false,
   $mft$Gare de Lyon = Sud-Est.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Avant de mesurer une distance sur un plan avec une règle, quelle information devez-vous impérativement vérifier ?$mft$,
   $mft$L'échelle du plan, c'est-à-dire le rapport entre la distance mesurée et la distance réelle (par exemple 1 cm = 1 km au 1/100 000).$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-6','question-courte'], 'TAXI-M6-QC-03', false,
   $mft$Sans l'échelle, la mesure ne se convertit pas.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Un client vous demande combien de temps prendra sa course de 5 km en hypercentre à l'heure de pointe. Quelle fourchette annoncez-vous, et sur quelle base ?$mft$,
   $mft$Environ 12 à 20 minutes, sur la base d'une vitesse moyenne de 15 à 25 km/h en ville dense : on annonce une fourchette, pas un temps sec.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-6','question-courte'], 'TAXI-M6-QC-04', false,
   $mft$Fourchette fondée sur les 15-25 km/h de moyenne.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Citez trois critères à comparer avant de choisir entre l'autoroute à péage et l'itinéraire alternatif gratuit.$mft$,
   $mft$Le temps de parcours estimé dans les conditions réelles, le coût (péage) et la fiabilité de l'horaire (rendez-vous, avion ou train à prendre) ; le client est informé du choix et de son impact sur le prix.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-6','question-courte'], 'TAXI-M6-QC-05', false,
   $mft$Temps + coût + fiabilité, annoncés au client.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Le GPS vous envoie dans une rue passée en zone piétonne il y a un mois. Que révèle cet incident, et quel réflexe adopter ?$mft$,
   $mft$Les données du GPS peuvent être périmées (plans de circulation modifiés) : le professionnel garde la décision, s'appuie sur sa connaissance des changements récents de son secteur et contourne par un itinéraire licite.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-6','question-courte'], 'TAXI-M6-QC-06', false,
   $mft$Le GPS assiste, le chauffeur décide.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un client impose un itinéraire plus long que le vôtre. Citez les deux réflexes professionnels à avoir avant de démarrer.$mft$,
   $mft$L'informer du surcoût probable avant le départ, et garder une trace de sa demande (traçabilité) ; ensuite, suivre son choix : le client décide de l'itinéraire.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-6','question-courte'], 'TAXI-M6-QC-07', false,
   $mft$Information préalable + traçabilité.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Citez trois grandes gares parisiennes et, pour chacune, une desserte caractéristique.$mft$,
   $mft$Par exemple : gare du Nord (Lille, Londres, Bruxelles), gare de Lyon (le Sud-Est), gare Montparnasse (l'Ouest et le Sud-Ouest), gare Saint-Lazare (la Normandie), gare de l'Est (l'est du pays), gare d'Austerlitz (l'axe classique vers le centre).$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-6','question-courte'], 'TAXI-M6-QC-08', false,
   $mft$Trois couples gare/desserte cohérents.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Au rond-point, le GPS annonce « prenez la troisième sortie ». Comment comptez-vous les sorties pour ne pas vous tromper ?$mft$,
   $mft$Dans le sens de circulation de l'anneau, en comptant chaque débouché rencontré depuis son entrée, y compris ceux que l'on ne prend pas : la troisième sortie est le troisième débouché.$mft$,
   2, 'difficile', ARRAY['taxi-vtc','module-6','question-courte'], 'TAXI-M6-QC-09', false,
   $mft$Tous les débouchés comptent, dans l'ordre.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Vous démarrez la semaine prochaine dans une ville que vous ne connaissez pas. Citez trois actions de préparation avant votre première course.$mft$,
   $mft$Par exemple : étudier la carte et le plan (axes structurants, rocade, échelle) et situer les pôles (gares, aéroport, hôpitaux, hôtels), faire un repérage terrain des liaisons les plus demandées, et vérifier les événements de la semaine (salons, matchs, manifestations) via les sources d'info trafic locales.$mft$,
   2, 'difficile', ARRAY['taxi-vtc','module-6','question-courte'], 'TAXI-M6-QC-10', false,
   $mft$Trois actions distinctes de préparation.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Un collègue qui débute vous lance : « Apprendre les autoroutes et les gares par cœur ? Le GPS fait ça très bien. » Expliquez-lui, exemples à l'appui, ce que la connaissance des grands axes et des pôles apporte à un chauffeur professionnel.$mft$,
   $mft$Réponse modèle. D'abord, l'examen : l'épreuve de connaissance du territoire se passe sans assistance, il faut savoir situer axes et pôles. Ensuite, la relation client : celui qui annonce « je prends l'Eurostar » attend qu'on roule vers la gare du Nord sans consulter un écran ; celui qui parle d'un vol à Orly ou d'un TGV à Montparnasse jauge immédiatement le professionnalisme du chauffeur. Troisième apport, le contrôle du GPS : pour refuser un détour absurde, il faut savoir que Paris-Bordeaux se joue sur l'A10 et non sur l'A6 ; sans carte mentale, on subit la machine. Quatrième apport, l'anticipation : connaître les axes permet d'estimer un temps et un prix plausibles dès la prise en charge (l'A1 pour Lille, l'A13 pour la Normandie), de proposer une alternative en cas d'incident et de répondre aux questions du client pendant la course. Enfin, l'efficacité : le chauffeur qui connaît son territoire enchaîne les courses sans temps mort ni hésitation. Le GPS reste un excellent assistant : la carte mentale fait de vous le décideur.$mft$,
   $mft$Barème /5 : au moins quatre apports distincts (examen sans assistance, relation client, contrôle du GPS, estimation temps/prix, anticipation, efficacité) (3 pts) ; exemples concrets d'axes ou de gares exacts (1,5 pt) ; conclusion « le GPS assiste, le professionnel décide » (0,5 pt). Erreurs fréquentes : répondre uniquement « pour la panne de GPS » ; citer des couples axe/destination erronés.$mft$,
   5, 'facile', ARRAY['taxi-vtc','module-6','question-redigee'], 'TAXI-M6-QR-01', false,
   $mft$L'intérêt professionnel de la carte mentale, argumenté et illustré.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Cas chiffré. Une course relie la gare à l'aéroport : option A, 30 km essentiellement sur autoroute ; option B, 12 km par le centre-ville dense. Avec les ordres de grandeur du cours (110 à 130 km/h réels sur autoroute, 15 à 25 km/h en ville dense), estimez le temps de chaque option, concluez et indiquez ce que vous annoncez au client.$mft$,
   $mft$Réponse modèle. Option A : 30 km à 110-130 km/h réels représentent environ 14 à 16 minutes de roulage sur la section autoroutière, auxquelles s'ajoutent les accès urbains de part et d'autre : comptons une vingtaine de minutes au total. Option B : 12 km à 15-25 km/h de moyenne donnent environ 29 à 48 minutes. Conclusion : malgré une distance plus que doublée, l'option autoroutière est nettement plus rapide et surtout plus prévisible ; l'option centre-ville expose à une fourchette large qui se dégrade encore à l'heure de pointe. Annonce au client : l'option A avec son temps estimé en fourchette et, si l'autoroute est à péage, le coût correspondant : le client arbitre en connaissance de cause s'il préfère économiser le péage en acceptant un temps plus long et plus incertain. Méthode à retenir : convertir chaque option en temps avec la vitesse moyenne du contexte, comparer des temps et non des distances, et annoncer une fourchette honnête plutôt qu'un temps sec impossible à tenir.$mft$,
   $mft$Barème /5 : calcul de l'option A correct (environ 14-16 minutes de roulage, majorées des accès) (1,5 pt) ; calcul de l'option B correct (environ 29-48 minutes) (1,5 pt) ; conclusion comparant des temps et non des distances (1 pt) ; annonce client incluant la fourchette et le péage éventuel (1 pt). Erreurs fréquentes : conclure sur la distance la plus courte ; annoncer un temps sec sans fourchette.$mft$,
   5, 'facile', ARRAY['taxi-vtc','module-6','question-redigee'], 'TAXI-M6-QR-02', false,
   $mft$Le cas chiffré autoroute contre centre-ville, calculé et conclu.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Procédure. Un client monte et impose d'emblée son propre itinéraire, sensiblement plus long que celui que vous auriez choisi. Décrivez la procédure professionnelle complète, de la prise en charge à la fin de course : information, surcoût, traçabilité, attitude, limites.$mft$,
   $mft$Réponse modèle. 1) Écouter et reformuler la demande (« vous souhaitez passer par les quais, c'est noté »). 2) Informer AVANT de démarrer : signaler courtoisement que cet itinéraire est plus long que celui que vous proposiez et qu'il entraînera un surcoût probable ; donner un ordre de grandeur honnête. 3) Laisser le choix : le client décide de l'itinéraire, le rôle du chauffeur est d'informer, pas d'imposer. 4) Tracer : conserver une trace de la demande (annonce explicite, mention sur le support de course ou l'application selon l'outil utilisé) : en cas de contestation du prix à l'arrivée, cette traçabilité protège les deux parties. 5) Exécuter loyalement l'itinéraire choisi, sans détour supplémentaire ni commentaire désobligeant. 6) Limites : refuser toute demande illégale (sens interdit, voie réservée, zone piétonne) en expliquant calmement le motif, et proposer l'alternative licite la plus proche du souhait exprimé. 7) Fin de course : si le client s'étonne du montant, rappeler factuellement l'information donnée au départ. Attitude générale : courtoisie, neutralité, aucune leçon de géographie au client.$mft$,
   $mft$Barème /5 : information du surcoût probable AVANT le départ (1,5 pt) ; principe « le client choisit, le chauffeur informe » (1 pt) ; traçabilité de la demande et usage en cas de contestation (1,5 pt) ; limite des demandes illégales et attitude courtoise (1 pt). Erreurs fréquentes : imposer son propre itinéraire ; accepter sans informer puis justifier le prix seulement à l'arrivée.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-6','question-redigee'], 'TAXI-M6-QR-03', false,
   $mft$La procédure complète face à l'itinéraire imposé par le client.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Comparez la préparation de deux courses au départ de Paris : le client 1 part en voiture avec vous vers Strasbourg ; le client 2 doit prendre un train pour Bordeaux. Pour chacun : axe ou gare concerné, informations à donner, et ce que cette double connaissance (route et rail) apporte au chauffeur.$mft$,
   $mft$Réponse modèle. Client 1 (route vers Strasbourg) : l'axe structurant est l'A4, l'autoroute de l'est. Préparation : estimer le temps de roulage avec les vitesses réelles d'autoroute, intégrer le coût des péages dans l'information donnée au client, vérifier les conditions du jour (trafic, météo, travaux signalés) et prévoir un point d'étape si la durée le justifie. Client 2 (train pour Bordeaux) : Bordeaux relève des dessertes de la gare Montparnasse (l'Ouest et le Sud-Ouest) ; l'erreur classique serait de filer vers la gare de Lyon ou d'Austerlitz. Préparation : caler l'heure de dépose sur l'horaire du train avec une marge, choisir l'itinéraire le plus fiable à l'heure dite et annoncer une fourchette de temps. Apport de la double connaissance : le chauffeur qui associe chaque destination à son axe ET chaque grande ville à sa gare parisienne répond instantanément, rassure le client, évite l'erreur de gare (qui fait rater un train et perd un client), détecte les incohérences du GPS et gagne un rôle de conseil : exactement ce que l'épreuve de connaissance du territoire cherche à vérifier.$mft$,
   $mft$Barème /5 : A4 identifiée pour Strasbourg avec préparation route (péages, temps, conditions du jour) (1,5 pt) ; gare Montparnasse identifiée pour Bordeaux avec gestion de l'horaire et de la marge (1,5 pt) ; risque d'erreur de gare signalé (1 pt) ; apport professionnel de la double connaissance route/rail (1 pt). Erreurs fréquentes : confondre Montparnasse et gare de Lyon ; oublier la marge sur l'horaire du train.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-6','question-redigee'], 'TAXI-M6-QR-04', false,
   $mft$Deux préparations comparées : axe routier et gare parisienne.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Analyse type examen. Mardi 8 h 30, un client part de son hôtel du centre pour un rendez-vous : itinéraire 1 par la rocade (18 km, fluide hors pointe, travaux signalés sur un tronçon), itinéraire 2 en traversée directe (7 km en ville dense). Déroulez la méthode complète de choix d'itinéraire et justifiez votre décision.$mft$,
   $mft$Réponse modèle. Méthode : cadrer (heure de pointe du mardi matin, client attendu à un rendez-vous : la fiabilité prime), repérer les deux options, convertir chacune en temps avec les vitesses du contexte, intégrer les contraintes, trancher sur le temps le plus fiable. Itinéraire 2 : 7 km à 15-25 km/h de moyenne donnent environ 17 à 28 minutes : fourchette large mais bornée et connue. Itinéraire 1 : 18 km fluides se rouleraient vite, mais à 8 h 30 la rocade subit la pointe ET des travaux : la vitesse réelle est imprévisible, le risque de blocage sans échappatoire est réel ; le temps peut être meilleur comme bien pire. Décision : pour un client contraint par un horaire, l'itinéraire 2 offre le temps le plus fiable ; on annonce la fourchette haute (une trentaine de minutes) pour tenir la promesse. Si le client préfère tenter la rocade, on l'informe du risque : le choix éclairé lui revient. Enseignement : on compare des temps estimés dans les conditions réelles, jamais des distances, et l'on privilégie la fiabilité quand un horaire est en jeu.$mft$,
   $mft$Barème /5 : méthode déroulée dans l'ordre (cadrer, convertir, intégrer les contraintes, trancher) (1,5 pt) ; calcul correct de l'itinéraire urbain (environ 17-28 minutes) (1 pt) ; analyse du risque rocade (pointe + travaux = temps imprévisible) (1,5 pt) ; décision justifiée par la fiabilité et annonce en fourchette haute (1 pt). Erreurs fréquentes : choisir la rocade « parce que c'est une voie rapide » ; comparer les distances au lieu des temps.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-6','question-redigee'], 'TAXI-M6-QR-05', false,
   $mft$Le choix d'itinéraire sous contraintes, méthode déroulée et justifiée.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Plan d'action. Vous prenez un poste de chauffeur dans une ville que vous ne connaissez pas, dans une semaine. Construisez votre plan de préparation jour par jour : carte et axes, pôles, repérage terrain, événements, sources d'information, routines du premier jour.$mft$,
   $mft$Réponse modèle. J-7 à J-6 : étude de la carte et du plan : axes structurants, pénétrantes et rocade, échelle du plan, quartiers d'affaires et zones denses ; repérer aussi comment la ville se raccorde aux grands axes nationaux. J-5 à J-4 : situer les pôles générateurs de courses : gares, aéroport, hôpitaux et cliniques, hôtels d'affaires, palais des congrès, stade, zones commerciales. J-3 : repérage terrain : rouler réellement les liaisons les plus demandées (gare-aéroport, centre-hôpitaux), noter les sens interdits, les zones piétonnes et les particularités récentes de circulation que le GPS peut ignorer. J-2 : recenser les événements de la semaine (salons, matchs, manifestations) via les sources locales : info trafic, arrêtés de circulation de la mairie et de la préfecture, presse locale, calendrier du parc des expositions et du stade. J-1 : installer ses routines : sources d'info trafic enregistrées, points de dépose et de stationnement autorisés identifiés, itinéraires de contournement préparés. Jour J : commencer par les liaisons repérées, GPS en simple assistance, et noter chaque enseignement du terrain pour enrichir sa carte mentale au fil des courses.$mft$,
   $mft$Barème /5 : progression logique et complète sur la semaine (2 pts) ; pôles générateurs de courses identifiés (1 pt) ; repérage terrain réel avec attention aux changements récents (1 pt) ; veille des événements avec sources nommées (1 pt). Erreurs fréquentes : réduire la préparation au téléchargement d'une carte GPS ; oublier les événements de la semaine.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-6','question-redigee'], 'TAXI-M6-QR-06', false,
   $mft$Le plan de préparation d'une ville nouvelle, de J-7 au jour J.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Comparaison d'axes. Un client souhaite rejoindre Montpellier depuis Paris par la route. Deux grandes options existent : la vallée du Rhône (A6 vers Lyon, A7 vers le sud, puis A9) ou la traversée du Massif central par l'A75. Comparez ces options (rôle des axes, péages, arbitrage) et expliquez comment présenter le choix au client.$mft$,
   $mft$Réponse modèle. Option vallée du Rhône : l'A6 relie Paris à Lyon, l'A7 descend la vallée du Rhône de Lyon vers le grand sud, puis l'A9, l'axe languedocien parti d'Orange vers l'Espagne, dessert Montpellier. C'est le grand itinéraire classique : entièrement autoroutier et rapide, mais jalonné de péages et très chargé lors des grands départs. Option Massif central : rejoindre Clermont-Ferrand puis l'A75, qui traverse le Massif central vers la Méditerranée ; elle est réputée en grande partie sans péage (hors ouvrages comme le viaduc de Millau), donc intéressante sur le coût, avec un profil plus montagneux et une météo hivernale à surveiller. Arbitrage : temps et fiabilité contre coût, en intégrant la saison, les conditions du jour et l'objectif du client (horaire impératif ou budget serré). Présentation au client : exposer factuellement les deux options, l'estimation de temps de chacune et la différence de coût de péage, formuler une recommandation argumentée, puis laisser le client trancher : c'est lui qui choisit, le chauffeur informe et trace le choix retenu.$mft$,
   $mft$Barème /5 : enchaînement A6/A7/A9 exact avec le rôle de chaque axe (1,5 pt) ; option A75 correctement décrite (Massif central, coût de péage réduit, points de vigilance) (1,5 pt) ; arbitrage temps/coût/fiabilité contextualisé (saison, conditions, objectif du client) (1 pt) ; présentation au client : information factuelle, recommandation, choix laissé au client (1 pt). Erreurs fréquentes : confondre l'A9 et l'A8 ; présenter une seule option comme évidente sans informer du coût.$mft$,
   5, 'difficile', ARRAY['taxi-vtc','module-6','question-redigee'], 'TAXI-M6-QR-07', false,
   $mft$Vallée du Rhône contre A75 : deux itinéraires comparés et présentés.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Analyse d'incident. Un soir de match, un chauffeur suit son GPS sans réfléchir : rue fermée par arrêté aux abords du stade, demi-tour, vingt minutes perdues, client furieux qui conteste le prix à l'arrivée. Analysez les manquements professionnels, leurs conséquences, et reconstituez la course telle qu'elle aurait dû se dérouler.$mft$,
   $mft$Réponse modèle. Manquements : 1) aucune anticipation de l'événement : un match est prévisible, les fermetures aux abords du stade aussi ; la veille (sources d'info trafic, arrêtés municipaux, presse locale) fait partie du métier ; 2) confiance aveugle dans le GPS, qui subit les fermetures temporaires plus qu'il ne les anticipe : la cohérence de l'itinéraire n'a pas été vérifiée ; 3) aucune information du client en amont : ni sur le contexte du match, ni sur l'itinéraire de contournement, ni sur le temps prévisible ; 4) aucune traçabilité : à l'arrivée, rien ne documente que le détour subi n'était pas une manœuvre pour gonfler le prix. Conséquences : temps perdu, prix contesté, client mécontent, image dégradée et pourboire envolé. Course corrigée : avant la prise en charge, vérifier les événements du soir ; annoncer au client le contexte et proposer un itinéraire de contournement avec une fourchette de temps honnête ; rouler l'itinéraire annoncé, GPS en simple assistance ; si un imprévu surgit malgré tout, informer immédiatement et tracer. Leçon : le GPS assiste, le professionnel anticipe, informe et décide.$mft$,
   $mft$Barème /5 : les quatre manquements identifiés (anticipation, confiance aveugle, information du client, traçabilité) (2 pts) ; conséquences reliées aux manquements (1 pt) ; course corrigée complète (veille, annonce, contournement, information continue) (1,5 pt) ; leçon générale formulée (0,5 pt). Erreurs fréquentes : accabler le seul GPS sans traiter la responsabilité du chauffeur ; oublier l'information du client avant le départ.$mft$,
   5, 'difficile', ARRAY['taxi-vtc','module-6','question-redigee'], 'TAXI-M6-QR-08', false,
   $mft$Autopsie d'une course ratée un soir de match : manquements et version corrigée.$mft$);

  RAISE NOTICE 'Module 6 Taxi-VTC créé : module %, 3 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $taxim6$;
