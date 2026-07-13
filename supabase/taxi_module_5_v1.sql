-- =====================================================================
-- TAXI / VTC : MODULE 5 : RÉUSSIR LE FRANÇAIS ET L'ANGLAIS DE L'EXAMEN
-- v1 (juillet 2026)
-- Angle candidat : méthode pour l'épreuve de compréhension et
-- d'expression en français, et anglais professionnel du chauffeur
-- (accueil, itinéraire, paiement, imprévus, aéroport).
-- ⚠ STATUT : active = false (« à valider »). Idempotent.
-- =====================================================================

DO $taxim5$
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

  DELETE FROM public.question_bank WHERE source_ref LIKE 'TAXI-M5-%';
  DELETE FROM public.modules WHERE slug = 'taxi-vtc-francais-anglais';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 5 : Réussir le français et l''anglais de l''examen',
    'taxi-vtc-francais-anglais', v_bloc,
    'Méthode pour les épreuves de compréhension et d''expression en français, et l''anglais professionnel du chauffeur : accueil, itinéraire, paiement, imprévus.',
    'debutant', 240, 50) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 50, true);

  -- ─── Leçon 1 : L'épreuve de français : méthode ─────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'methode-epreuve-francais',
    'L''épreuve de français : méthode et entraînement',
    $mft$> 🎯 **Objectifs**
> - Connaître le déroulé de l'épreuve de français et ce qu'elle évalue.
> - Appliquer une méthode fiable : lire deux fois, souligner, répondre par phrases complètes.
> - Éliminer les fautes qui coûtent des points : accords simples et homophones classiques.

## Ce que l'épreuve évalue

L'épreuve de français des examens taxi et VTC ne cherche pas à faire de vous un écrivain : elle vérifie que vous comprenez un document du quotidien professionnel (consigne d'un client, article court, message d'une centrale de réservation, document de travail) et que vous savez vous exprimer par écrit de façon claire et correcte. Concrètement, vous lisez un texte, vous répondez à des questions de compréhension, puis une partie expression vous demande de rédiger quelques phrases.

> ⚠️ **Attention**
> Le format exact de l'épreuve (durée, nombre de questions, type de support, part de l'expression) peut varier selon les sessions et les organisateurs : vérifiez les modalités précises sur votre convocation et auprès de votre chambre de métiers et de l'artisanat.

## La méthode en cinq étapes

:::flow
1. Lire en entier | Une première lecture complète, sans stylo, pour comprendre de quoi parle le texte
2. Lire les questions | Repérer ce qui est demandé AVANT la seconde lecture
3. Relire en soulignant | Souligner les passages qui répondent aux questions (dates, lieux, consignes, chiffres)
4. Répondre par phrases complètes | Reprendre les mots de la question et y intégrer l'information soulignée
5. Se relire | Cinq minutes réservées à la chasse aux fautes : accords, homophones, ponctuation
:::

La double lecture n'est pas du temps perdu : la première donne le sens général, la seconde, guidée par les questions, localise les informations. Le candidat qui répond après une seule lecture rapide se trompe souvent de question : il répond à ce qu'il croit avoir lu.

## Répondre par phrases complètes

À la question « À quelle heure le client doit-il être pris en charge ? », la réponse « 9 h » est exacte mais pauvre. La réponse « Le client doit être pris en charge à 9 h devant son hôtel » montre que vous savez construire une phrase : sujet, verbe, complément. La technique est simple : reprendre les mots de la question pour démarrer la phrase, puis ajouter l'information trouvée dans le texte. Vous gagnez sur les deux tableaux : compréhension ET expression.

## L'orthographe qui rapporte des points

Inutile de viser les subtilités : l'essentiel des points se joue sur les accords simples et une poignée d'homophones.

| Homophones | L'astuce de remplacement | Exemple correct |
| --- | --- | --- |
| a / à | « a » se remplace par « avait » ; sinon, écrire « à » | Le client a réservé à 9 h |
| et / est | « est » se remplace par « était » ; « et » relie deux éléments | La course est confirmée et payée |
| ce / se | « ce » montre quelque chose (ce client) ; « se » précède un verbe (il se présente) | Ce client se présente à l'accueil |

Côté accords : le verbe s'accorde avec son sujet (le client attend, les clients attendent) et l'adjectif avec son nom (une course longue, des courses longues). En relecture, pointez chaque verbe et demandez-vous : qui fait l'action ?

> 💡 **Astuce**
> En relecture, testez chaque « a » en le remplaçant mentalement par « avait » : si la phrase reste correcte, pas d'accent ; sinon, écrivez « à ». Même réflexe avec « était » pour « est ». Trente secondes qui sauvent des points.

## Gérer le temps de l'épreuve

Répartissez dès le départ : environ un tiers du temps pour les lectures, la moitié pour les réponses, le reste pour la relecture. Ne restez jamais bloqué sur une question : marquez-la, passez à la suivante, revenez à la fin. S'il vous reste peu de temps pour l'expression, préférez deux phrases courtes et correctes à un paragraphe ambitieux mais inachevé et fautif.

## S'entraîner avec votre futur métier

Le meilleur entraînement utilise des situations que vous vivrez au volant :

- **Reformuler des consignes clients** : « Passez me prendre à 8 h 30, mais si je ne suis pas en bas, appelez-moi et attendez cinq minutes » : réécrivez la consigne en une phrase claire, comme si vous la transmettiez à un collègue.
- **Rédiger de courts messages professionnels** : un retard, un objet trouvé. Structure invariable : salutation, faits, solution proposée, formule de politesse.

> 📌 **À retenir**
> Message type de retard : « Bonjour, je serai en retard d'environ dix minutes en raison d'un accident sur le périphérique. Je vous prie de m'excuser pour ce contretemps. Cordialement. » Court, factuel, poli : et sans faute, parce que relu.

## ✅ Synthèse

- L'épreuve : comprendre un texte du quotidien professionnel et s'exprimer correctement (format exact : à vérifier selon votre session).
- Méthode : lire deux fois, souligner, répondre par **phrases complètes**, se relire.
- Priorités d'orthographe : accords sujet-verbe et homophones **a/à, et/est, ce/se**.
- Entraînement quotidien : reformuler des consignes, rédiger des messages professionnels courts.$mft$,
    $mft$La nature de l'épreuve de français (compréhension d'un document professionnel puis expression), la méthode en cinq étapes (double lecture, soulignage, phrases complètes, relecture), les homophones prioritaires et l'entraînement par messages professionnels.$mft$,
    1, 30) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : L'anglais du chauffeur (1) : accueil et course ──────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'anglais-du-chauffeur-1',
    'L''anglais du chauffeur (1) : accueil et course',
    $mft$> 🎯 **Objectifs**
> - Accueillir un client anglophone et confirmer la réservation et la destination.
> - Gérer les bagages, l'installation et le confort avec les formules justes.
> - Annoncer la durée du trajet, proposer un itinéraire et tenir un small talk professionnel.

## L'anglais, un outil de travail (et une épreuve)

Aéroports, gares, hôtels, salons professionnels : une part importante de la clientèle du taxi et du VTC ne parle pas français. Quelques dizaines de phrases bien maîtrisées suffisent à assurer une course complète : le client ne vous demande pas un anglais parfait, il vous demande de le comprendre et d'être compris. L'examen évalue exactement cela : la capacité à gérer en anglais les situations types du métier.

> ⚠️ **Attention**
> La forme exacte de l'interrogation d'anglais (QCM de compréhension, dialogue à compléter) peut varier selon les sessions : vérifiez les modalités sur votre convocation. La préparation, elle, ne change pas : maîtriser les dialogues types de la course.

## L'accueil : les trente premières secondes

Trois gestes verbaux ouvrent chaque course :

| Moment | La formule | Ce qu'elle fait |
| --- | --- | --- |
| Saluer | Good morning! / Good afternoon! / Good evening! | La salutation adaptée à l'heure donne le ton |
| Confirmer la réservation | Mr Smith? You booked a taxi to the airport, is that right? | Le bon client, la bonne course : zéro erreur de prise en charge |
| Confirmer la destination | Where would you like to go? | Indispensable quand la destination n'est pas déjà connue |

Un client confirmé par son nom et sa destination est un client rassuré : il sait qu'il est dans la bonne voiture.

## Bagages, installation, confort

- « Do you have any luggage? » : la question réflexe dès la rencontre.
- « I will put your suitcases in the trunk. » : le coffre se dit trunk en anglais américain et boot en anglais britannique : comprenez les deux.
- « Please fasten your seatbelt. » : la ceinture, formulée poliment.
- « Would you like some air conditioning? » : le confort proposé, pas imposé.
- « Is the temperature OK for you? » : la vérification simple qui fait la différence.

## Durée et itinéraire : informer et laisser choisir

Deux structures couvrent presque toutes les situations :

- **It takes about...** : « It takes about twenty minutes. » La durée estimée, avec « about » qui vous évite de promettre à la minute près.
- **Would you like...?** : « Would you like the highway or the city route? » Le choix d'itinéraire proposé au client : l'autoroute souvent plus rapide, la ville parfois plus directe selon l'heure.

En cas de circulation : « There is some traffic this morning, it may take a little longer. » Annoncer avant que le client ne s'impatiente : la règle vaut en anglais comme en français.

## Le small talk : bref, positif, professionnel

| On peut | On évite |
| --- | --- |
| La météo : It is a beautiful day | La politique, la religion, l'argent |
| Le séjour : Is this your first time in Paris? | Les confidences personnelles |
| Le quartier, un monument sur le trajet | Les opinions tranchées et les plaintes |

La règle d'or : le client mène la conversation, vous vous ajustez. Des réponses brèves et souriantes suffisent ; un client qui répond par monosyllabes ou sort son téléphone souhaite le calme : respectez-le.

## Le déroulé complet à mémoriser

:::timeline
1. Prise en charge | Good morning! Mr Smith? You booked a taxi to the airport, is that right?
2. Bagages | Do you have any luggage? I will put your suitcases in the trunk.
3. Installation | Please fasten your seatbelt. Would you like some air conditioning?
4. Départ | It takes about twenty-five minutes. Would you like the highway or the city route?
5. Trajet | There is some traffic this morning, it may take a little longer.
6. Conversation | Is this your first time in Paris? (bref, positif, si le client s'y prête)
:::

> 🎓 **Le saviez-vous ?**
> La mémorisation passe par la voix, pas seulement par les yeux : lisez chaque dialogue à voix haute, dix minutes par jour, en jouant les deux rôles. Enregistrez-vous avec votre téléphone et réécoutez-vous : au bout de deux semaines, les formules sortent toutes seules.

## ✅ Synthèse

- Accueil : saluer selon l'heure, **confirmer la réservation et la destination** (is that right?).
- Bagages et confort : luggage, trunk/boot, seatbelt, air conditioning : les mots clés de l'installation.
- Deux structures universelles : **It takes about...** (durée) et **Would you like...?** (proposition).
- Small talk : bref, positif, jamais de sujets sensibles ; le client mène, vous suivez.$mft$,
    $mft$L'accueil du client anglophone (salutation, confirmation de la réservation et de la destination), les formules pour les bagages et le confort, les structures it takes about et would you like, et les règles du small talk professionnel.$mft$,
    2, 35) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : L'anglais du chauffeur (2) : paiement et imprévus ───
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'anglais-du-chauffeur-2',
    'L''anglais du chauffeur (2) : paiement, imprévus et aéroport',
    $mft$> 🎯 **Objectifs**
> - Encaisser en anglais : annoncer le prix, gérer carte, espèces, monnaie et reçu.
> - Gérer les imprévus (bouchon, travaux, détour, objet oublié) sans perdre le client.
> - Maîtriser le vocabulaire de l'aéroport et la liste des mots indispensables.

## Le paiement : la dernière impression

La fin de course décide du pourboire, du commentaire en ligne et du client fidélisé. Quatre formules suffisent :

- « That will be twenty-five euros, please. » : le prix, annoncé clairement.
- « Do you pay by card or cash? » : le mode de paiement proposé sans détour.
- « Here is your change. » : la monnaie rendue, annoncée à voix haute (elle évite les contestations).
- « Would you like a receipt? » : le reçu proposé SPONTANÉMENT : la clientèle d'affaires en a besoin pour ses notes de frais et apprécie de ne pas avoir à le demander.

> 💡 **Astuce**
> Annoncez la monnaie en la comptant : « Out of fifty? Here is your change: twenty-five euros. » Le client entend, voit, vérifie : aucune ambiguïté possible.

## Les imprévus : informer d'abord, rassurer ensuite

Un client informé patiente ; un client sans nouvelles s'inquiète et note mal. Les phrases clés :

| Situation | La phrase |
| --- | --- |
| Embouteillage | I am sorry for the delay, there is a traffic jam. |
| Travaux | There is a small detour because of roadworks. |
| Rassurer | Do not worry, we will be there in ten minutes. |
| S'excuser à l'arrivée | Sorry again for the delay. Thank you for your patience. |

La séquence est toujours la même : excuse brève, cause factuelle, solution ou durée estimée. Pas de long discours : c'est l'information qui rassure, pas les justifications.

## Objets oubliés : l'appel qui fidélise

Le téléphone sur la banquette, l'écharpe, l'ordinateur : l'objet oublié est une occasion de prouver votre sérieux :

- « Hello, this is your taxi driver. You left your phone in the car. »
- « I will bring it back to you. » ou « I can leave it at your hotel reception. »

Un client qui récupère son téléphone dans l'heure raconte l'histoire autour de lui : c'est la meilleure publicité qui soit.

## L'aéroport : déposer au bon endroit

- « Which airline are you flying with? » : la compagnie détermine le terminal.
- « Your airline departs from Terminal 2. » : l'information qui rassure.
- « I will drop you at the drop-off area, right in front of the departures. » : la zone de dépose, au plus près.
- « Have a nice flight! » : la formule de départ.

> 🔍 **Zoom**
> Le chauffeur qui demande la compagnie AVANT d'entrer dans la zone aéroportuaire évite le tour des terminaux : minutes gagnées, client détendu, et une file de dépose abordée du premier coup.

## Les 66 mots et expressions indispensables

**Accueil et politesse**

| Anglais | Français |
| --- | --- |
| Good morning / Good afternoon / Good evening | Bonjour (matin / après-midi) / Bonsoir |
| Welcome | Bienvenue |
| Please | S'il vous plaît |
| Thank you (very much) | Merci (beaucoup) |
| You are welcome | Je vous en prie |
| Excuse me | Excusez-moi |
| I am sorry | Je suis désolé |
| Sir / Madam | Monsieur / Madame |
| Have a nice day | Bonne journée |
| Goodbye | Au revoir |

**Le véhicule et les bagages**

| Anglais | Français |
| --- | --- |
| luggage | bagages |
| suitcase | valise |
| trunk (US) / boot (UK) | coffre |
| seatbelt | ceinture de sécurité |
| to fasten | attacher |
| air conditioning | climatisation |
| window | vitre |
| door | portière |
| front seat / back seat | siège avant / siège arrière |
| child seat | siège enfant |

**Itinéraire et temps**

| Anglais | Français |
| --- | --- |
| Where would you like to go? | Où souhaitez-vous aller ? |
| destination / address | destination / adresse |
| highway (US) / motorway (UK) | autoroute |
| city route | itinéraire par la ville |
| It takes about twenty minutes | Il faut environ vingt minutes |
| near / far | près / loin |
| left / right / straight on | à gauche / à droite / tout droit |
| traffic | circulation |
| on time / late / early | à l'heure / en retard / en avance |
| We are almost there | Nous sommes presque arrivés |

**Le paiement**

| Anglais | Français |
| --- | --- |
| price | prix |
| That will be twenty-five euros | Cela fera vingt-cinq euros |
| card / cash | carte / espèces |
| change | monnaie (rendue) |
| receipt | reçu |
| Would you like a receipt? | Souhaitez-vous un reçu ? |
| to pay | payer |
| tip | pourboire |

**Les imprévus**

| Anglais | Français |
| --- | --- |
| traffic jam | embouteillage |
| roadworks | travaux |
| accident | accident |
| detour | détour, déviation |
| delay | retard |
| I am sorry for the delay | Je suis désolé pour le retard |
| Do not worry | Ne vous inquiétez pas |
| You left your phone | Vous avez oublié votre téléphone |
| I will bring it back | Je vous le rapporte |
| lost property | objets trouvés |

**Aéroport et gare**

| Anglais | Français |
| --- | --- |
| airport | aéroport |
| airline | compagnie aérienne |
| Which airline are you flying with? | Avec quelle compagnie volez-vous ? |
| terminal | terminal |
| flight | vol |
| drop-off area | zone de dépose |
| train station | gare |
| departures / arrivals | départs / arrivées |
| check-in | enregistrement |
| Have a nice flight! | Bon vol ! |

> 📌 **À retenir**
> Apprenez cette liste par thèmes, cinq à dix mots par jour, toujours dans une phrase (receipt seul s'oublie ; « Would you like a receipt? » reste). Les mots connus servent ensuite de points d'appui pour deviner le sens des phrases nouvelles.

## ✅ Synthèse

- Paiement : **that will be..., card or cash, change, receipt** : et le reçu proposé spontanément.
- Imprévus : excuse brève + cause (**traffic jam, roadworks**) + durée estimée : l'information rassure.
- Objet oublié : **You left your... I will bring it back** : l'occasion de fidéliser.
- Aéroport : **which airline, terminal, drop-off area** : la compagnie d'abord, la dépose ensuite.$mft$,
    $mft$Le paiement en anglais (prix, carte ou espèces, monnaie, reçu), la gestion des imprévus (traffic jam, roadworks, detour), les objets oubliés, le vocabulaire de l'aéroport et la liste des 66 mots et expressions indispensables classés par thèmes.$mft$,
    3, 35) RETURNING id INTO v_l3;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : Français et anglais du chauffeur',
    'Vérifiez le module 5 : méthode de l''épreuve de français, anglais de l''accueil, de la course, du paiement et des imprévus.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un client monte à bord et vous lui demandez : « Where would you like to go? ». Que cherchez-vous à connaître ?$mft$,
    $mft$[
      {"id":"a","label":"Sa destination","is_correct":true},
      {"id":"b","label":"Son mode de paiement","is_correct":false},
      {"id":"c","label":"L'heure de son vol","is_correct":false},
      {"id":"d","label":"Le nombre de ses bagages","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-5','qcm-v1'], 'TAXI-M5-QCM-01', false,
    $mft$« Where would you like to go? » demande la destination ; le paiement se règle avec « Do you pay by card or cash? » et les bagages avec « Do you have any luggage? ».$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$En fin de course, votre cliente vous dit : « Could I have a receipt, please? ». Que demande-t-elle ?$mft$,
    $mft$[
      {"id":"a","label":"Un reçu","is_correct":true},
      {"id":"b","label":"La monnaie","is_correct":false},
      {"id":"c","label":"Un détour","is_correct":false},
      {"id":"d","label":"La climatisation","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-5','qcm-v1'], 'TAXI-M5-QCM-02', false,
    $mft$Receipt signifie reçu ; la monnaie se dit change, le détour detour et la climatisation air conditioning : quatre mots à ne pas confondre en fin de course.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Le surveillant distribue le texte de l'épreuve de français. Quel est le bon premier réflexe ?$mft$,
    $mft$[
      {"id":"a","label":"Lire le texte en entier une première fois, puis lire les questions avant de le relire en soulignant","is_correct":true},
      {"id":"b","label":"Répondre aux questions dès la première lecture pour gagner du temps","is_correct":false},
      {"id":"c","label":"Recopier des passages entiers du texte en guise de réponses","is_correct":false},
      {"id":"d","label":"Commencer par la partie expression, plus longue à rédiger","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-5','qcm-v1'], 'TAXI-M5-QCM-03', false,
    $mft$La double lecture guidée par les questions évite les contresens ; répondre à chaud ou recopier sans phrase construite fait perdre des points, et l'expression se nourrit de la compréhension du texte.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Votre client répond « Yes, two suitcases » à votre question « Do you have any luggage? ». Que faites-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Vous ouvrez le coffre et l'aidez à charger ses deux valises","is_correct":true},
      {"id":"b","label":"Vous lui tendez un reçu","is_correct":false},
      {"id":"c","label":"Vous attachez sa ceinture à sa place","is_correct":false},
      {"id":"d","label":"Vous lui indiquez le terminal de départ","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-5','qcm-v1'], 'TAXI-M5-QCM-04', false,
    $mft$Suitcases signifie valises : le réflexe est le coffre (trunk ou boot) ; le reçu et le terminal appartiennent à d'autres moments de la course, et chacun attache sa propre ceinture.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Vous êtes à l'arrêt dans un embouteillage avec une cliente anglophone à bord. Quelle phrase est adaptée à la situation ?$mft$,
    $mft$[
      {"id":"a","label":"I am sorry for the delay, there is a traffic jam.","is_correct":true},
      {"id":"b","label":"You left your phone in the car.","is_correct":false},
      {"id":"c","label":"Would you like a receipt?","is_correct":false},
      {"id":"d","label":"That will be twenty-five euros.","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-5','qcm-v1'], 'TAXI-M5-QCM-05', false,
    $mft$Face au retard, on s'excuse et on donne la cause (traffic jam) ; les trois autres phrases parlent d'un objet oublié, du reçu et du prix : hors sujet à ce moment de la course.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un client vous demande : « How long does it take to get to the station? ». Quelle réponse est correcte et adaptée ?$mft$,
    $mft$[
      {"id":"a","label":"It takes about twenty minutes.","is_correct":true},
      {"id":"b","label":"That will be twenty euros.","is_correct":false},
      {"id":"c","label":"You can pay by card.","is_correct":false},
      {"id":"d","label":"The trunk is open.","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-5','qcm-v1'], 'TAXI-M5-QCM-06', false,
    $mft$How long interroge sur la durée : on répond avec it takes about... ; les autres réponses parlent du prix, du paiement et du coffre, donc à côté de la question.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Vous devez prévenir un client d'un retard de dix minutes par message écrit. Quelle version est professionnelle et sans faute ?$mft$,
    $mft$[
      {"id":"a","label":"Bonjour, je serai en retard d'environ dix minutes en raison d'un accident. Je vous prie de m'excuser.","is_correct":true},
      {"id":"b","label":"slt je sui en retar jarrive dan 10 min","is_correct":false},
      {"id":"c","label":"Bonjour, je serais en retard d'environ dix minutes en raison d'un accident. Je vous prie de m'excuser.","is_correct":false},
      {"id":"d","label":"C'est pas ma faute, il y a des bouchons partout, patientez.","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-5','qcm-v1'], 'TAXI-M5-QCM-07', false,
    $mft$La version b relève du langage SMS, la c confond le futur (je serai) et le conditionnel (je serais), la d est familière et rejette la faute sur les circonstances sans s'excuser.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Votre client vous dit simplement : « To the airport, please. ». Quelle question posez-vous pour le déposer au bon endroit ?$mft$,
    $mft$[
      {"id":"a","label":"Which airline are you flying with?","is_correct":true},
      {"id":"b","label":"Do you pay by card or cash?","is_correct":false},
      {"id":"c","label":"Would you like some air conditioning?","is_correct":false},
      {"id":"d","label":"Do you have any luggage?","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-5','qcm-v1'], 'TAXI-M5-QCM-08', false,
    $mft$La compagnie aérienne détermine le terminal et donc la zone de dépose (drop-off area) ; le paiement, la climatisation et les bagages ne répondent pas à ce besoin.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Quelle phrase ne comporte aucune faute d'homophone ?$mft$,
    $mft$[
      {"id":"a","label":"Ce client est arrivé à l'heure et a réglé sa course.","is_correct":true},
      {"id":"b","label":"Se client est arrivé a l'heure et a réglé sa course.","is_correct":false},
      {"id":"c","label":"Ce client et arrivé à l'heure est a réglé sa course.","is_correct":false},
      {"id":"d","label":"Ce client est arrivé à l'heure et à réglé sa course.","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-5','qcm-v1'], 'TAXI-M5-QCM-09', false,
    $mft$La version b confond se/ce et a/à, la c inverse et/est, la d met un accent à un « a » qui se remplace pourtant par « avait » : l'astuce de remplacement tranche à chaque fois.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Un client parti depuis cinq minutes vous appelle : son téléphone est resté sur la banquette. Quelle phrase est correcte ?$mft$,
    $mft$[
      {"id":"a","label":"You left your phone in the car. I will bring it back to you.","is_correct":true},
      {"id":"b","label":"You are leaving your phone in the car. I bring it back yesterday.","is_correct":false},
      {"id":"c","label":"I left your phone in the car. You will bring it back to me.","is_correct":false},
      {"id":"d","label":"You lost my phone in your car. I will keep it.","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-5','qcm-v1'], 'TAXI-M5-QCM-10', false,
    $mft$You left (passé) puis I will bring it back (engagement) : la b mélange les temps, la c inverse les personnes et la d inverse les possessifs et annonce de garder le téléphone.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Une cliente anglophone engage la conversation : « First time in Paris, what a beautiful city! ». Quelle attitude professionnelle adoptez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Une réponse brève et aimable, puis vous restez disponible sans monopoliser la parole","is_correct":true},
      {"id":"b","label":"Vous détaillez vos opinions sur la politique locale pour nourrir la discussion","is_correct":false},
      {"id":"c","label":"Vous ne répondez pas : la conduite exige un silence total","is_correct":false},
      {"id":"d","label":"Vous racontez vos problèmes personnels pour créer de la proximité","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-5','qcm-v1'], 'TAXI-M5-QCM-11', false,
    $mft$Le small talk professionnel est bref, positif et neutre : ni sujets sensibles (politique), ni confidences personnelles ; ignorer totalement la cliente serait perçu comme de la froideur.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Il reste dix minutes d'épreuve et deux questions d'expression à traiter. Quelle stratégie maximise vos points ?$mft$,
    $mft$[
      {"id":"a","label":"Rédiger pour chaque question une ou deux phrases courtes, complètes et correctes, puis garder deux minutes de relecture","is_correct":true},
      {"id":"b","label":"Rédiger un long paragraphe sur la première question et laisser la seconde en blanc","is_correct":false},
      {"id":"c","label":"Répondre aux deux en abréviations et langage SMS pour tout couvrir","is_correct":false},
      {"id":"d","label":"Recopier des phrases du texte au hasard pour remplir les lignes","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-5','qcm-v1'], 'TAXI-M5-QCM-12', false,
    $mft$Deux réponses courtes, complètes et relues rapportent plus qu'un paragraphe inachevé, une question laissée en blanc, du langage SMS ou du recopiage sans lien avec la question.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l2, 'qr',
   $mft$Un client anglophone monte avec deux grosses valises. Quelle question simple lui posez-vous, en anglais, pour prendre en charge ses bagages ?$mft$,
   $mft$« Do you have any luggage? » ou « Shall I put your suitcases in the trunk? » : toute question correcte utilisant luggage, suitcases ou trunk/boot.$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-5','question-courte'], 'TAXI-M5-QC-01', false,
   $mft$Une question avec luggage ou suitcase, et le réflexe du coffre.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Traduisez pour votre client : « Cela fera vingt-cinq euros. Vous payez par carte ou en espèces ? »$mft$,
   $mft$« That will be twenty-five euros. Do you pay by card or cash? »$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-5','question-courte'], 'TAXI-M5-QC-02', false,
   $mft$La formule du prix (that will be) et l'alternative card/cash.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Citez les trois couples d'homophones à vérifier en priorité lors de la relecture de l'épreuve de français.$mft$,
   $mft$a/à, et/est, ce/se.$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-5','question-courte'], 'TAXI-M5-QC-03', false,
   $mft$Les trois couples classiques travaillés dans la leçon.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$En début de course avec un client étranger, quelles sont les deux informations à confirmer avant de démarrer ? Donnez un exemple de formulation en anglais.$mft$,
   $mft$La réservation (l'identité du client) et la destination ; par exemple : « Mr Smith? You booked a taxi to the airport, is that right? » ou « Where would you like to go? ».$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-5','question-courte'], 'TAXI-M5-QC-04', false,
   $mft$Confirmer réservation et destination évite toute erreur de prise en charge.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Un client vous laisse une consigne longue à l'oral (le déposer, remettre un pli à un accueil, puis revenir le chercher à 15 h). Quelle technique issue de l'épreuve de français appliquez-vous avant d'exécuter, et pourquoi ?$mft$,
   $mft$Reformuler la consigne avec ses propres mots (« Si je comprends bien, je vous dépose, je remets le pli à l'accueil et je reviens à 15 h ») pour vérifier la compréhension avant d'agir.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-5','question-courte'], 'TAXI-M5-QC-05', false,
   $mft$La reformulation vérifie la compréhension : même logique que relire le texte avant de répondre.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Des travaux vous obligent à dévier de l'itinéraire annoncé. Donnez deux phrases en anglais pour informer votre client et le rassurer.$mft$,
   $mft$« There is a small detour because of roadworks. » puis « I am sorry for the delay, do not worry, we will be there in about ten minutes. » (ou formulations équivalentes avec detour, roadworks et sorry for the delay).$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-5','question-courte'], 'TAXI-M5-QC-06', false,
   $mft$Informer (detour, roadworks) puis rassurer (excuse et durée estimée).$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Votre client hésite sur le chemin à prendre. Quelle question en anglais lui posez-vous pour lui laisser le choix, et quelle information ajoutez-vous pour l'aider à décider ?$mft$,
   $mft$« Would you like the highway or the city route? » ; on ajoute la durée estimée, par exemple « The highway takes about twenty minutes. »$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-5','question-courte'], 'TAXI-M5-QC-07', false,
   $mft$Le choix d'itinéraire (would you like) et la durée (it takes about) aident le client à décider.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Rédigez en deux phrases le message professionnel type que vous envoyez à une cliente qui a oublié son écharpe dans votre véhicule.$mft$,
   $mft$Par exemple : « Bonjour, vous avez oublié votre écharpe dans mon véhicule à la fin de votre course. Je peux vous la rapporter ou la déposer à l'adresse de votre choix, cordialement. » (salutation, faits, solution, politesse).$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-5','question-courte'], 'TAXI-M5-QC-08', false,
   $mft$La structure attendue : salutation, faits, solution proposée, formule de politesse.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$À l'approche de l'aéroport, votre client pressé ne vous a donné aucune précision. Quelles deux questions en anglais posez-vous pour le déposer au bon endroit ?$mft$,
   $mft$« Which airline are you flying with? » et « Which terminal do you need? » : la compagnie et le terminal déterminent la zone de dépose (drop-off area).$mft$,
   2, 'difficile', ARRAY['taxi-vtc','module-5','question-courte'], 'TAXI-M5-QC-09', false,
   $mft$Compagnie + terminal = bonne zone de dépose, sans tour d'aéroport inutile.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Pourquoi une réponse en phrase complète rapporte-t-elle plus de points qu'une réponse exacte en un seul mot dans l'épreuve de français ?$mft$,
   $mft$Parce que l'épreuve évalue aussi l'expression : la phrase complète (sujet, verbe, complément) prouve la maîtrise de la syntaxe et de l'orthographe, alors que le mot seul ne montre que la compréhension.$mft$,
   2, 'difficile', ARRAY['taxi-vtc','module-5','question-courte'], 'TAXI-M5-QC-10', false,
   $mft$Compréhension ET expression sont notées : la phrase complète sert les deux.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Décrivez, étape par étape, votre méthode complète pour l'épreuve de compréhension et d'expression en français, de la distribution du texte à la dernière relecture, en justifiant l'intérêt de chaque étape.$mft$,
   $mft$Réponse modèle. Étape 1 : lire le texte en entier une première fois, sans stylo, pour en saisir le sens général : on évite les contresens. Étape 2 : lire les questions avant la seconde lecture : on sait ce que l'on cherche. Étape 3 : relire en soulignant les passages utiles (dates, lieux, consignes, chiffres) : chaque question a ainsi son passage repéré. Étape 4 : répondre par phrases complètes en reprenant les mots de la question puis en intégrant l'information soulignée : on prouve la compréhension ET l'expression. Étape 5 : traiter la partie expression avec des phrases courtes et bien construites plutôt que de longs paragraphes risqués. Étape 6 : réserver environ cinq minutes de relecture ciblée : accords sujet-verbe (pointer chaque verbe et chercher son sujet) et homophones a/à, et/est, ce/se avec les astuces de remplacement (avait, était). Gestion du temps transversale : ne jamais rester bloqué sur une question, la marquer et y revenir à la fin. Cette méthode transforme une épreuve stressante en procédure connue : exactement comme une prise en charge bien préparée.$mft$,
   $mft$Barème /5 : double lecture avec lecture des questions entre les deux (1,5 pt) ; soulignage et repérage des informations (0,5 pt) ; phrases complètes reprenant les mots de la question (1,5 pt) ; relecture ciblée accords et homophones avec astuces de remplacement (1 pt) ; gestion du temps (ne pas bloquer, réserver la relecture) (0,5 pt). Erreurs fréquentes : décrire une seule lecture ; oublier la relecture ; réciter les étapes sans les justifier.$mft$,
   5, 'facile', ARRAY['taxi-vtc','module-5','question-redigee'], 'TAXI-M5-QR-01', false,
   $mft$La méthode complète de l'épreuve de français, justifiée étape par étape.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Rédigez en anglais le dialogue complet d'une prise en charge réussie : accueil, confirmation de la réservation et de la destination, bagages, installation, annonce de la durée et choix de l'itinéraire. Indiquez les répliques du chauffeur et celles du client.$mft$,
   $mft$Réponse modèle. Chauffeur : « Good morning! Mr Smith? You booked a taxi to the airport, is that right? » Client : « Yes, that is right. » Chauffeur : « Do you have any luggage? » Client : « Yes, two suitcases. » Chauffeur : « I will put them in the trunk. Please, have a seat. » Une fois le client installé : « Please fasten your seatbelt. Would you like some air conditioning? » Client : « Yes, please. » Client : « How long does it take? » Chauffeur : « It takes about twenty-five minutes. Would you like the highway or the city route? » Client : « The highway, please. » Chauffeur : « Very well. There is some traffic this morning, it may take a little longer. » L'évaluation porte sur la présence des cinq moments (accueil et confirmation de la réservation, bagages, installation et confort, durée, itinéraire), sur des formules correctes et polies (please, would you like) et sur la cohérence des échanges : chaque réplique du client reçoit une réponse adaptée, et le chauffeur annonce spontanément ce qui peut allonger le trajet.$mft$,
   $mft$Barème /5 : accueil et confirmation de la réservation et de la destination (1,5 pt) ; bagages et installation (luggage, trunk, seatbelt) (1 pt) ; durée annoncée avec it takes about (1 pt) ; choix d'itinéraire proposé (highway ou city route) (1 pt) ; politesse constante (please, would you like) (0,5 pt). Erreurs fréquentes : oublier la confirmation de réservation ; dialogue sans répliques du client ; formules télégraphiques ou impolies.$mft$,
   5, 'facile', ARRAY['taxi-vtc','module-5','question-redigee'], 'TAXI-M5-QR-02', false,
   $mft$Le dialogue type de la prise en charge, du bonjour au choix d'itinéraire.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Rédigez deux messages professionnels complets : (1) vous serez en retard de quinze minutes chez une cliente à cause d'un accident ; (2) un client a oublié son ordinateur portable dans votre véhicule hier soir. Puis dégagez les règles de forme communes aux deux messages.$mft$,
   $mft$Réponse modèle. Message 1 : « Bonjour Madame, je serai en retard d'environ quinze minutes pour votre prise en charge de 9 h, en raison d'un accident sur le périphérique. Je vous prie de m'excuser pour ce contretemps et je fais au mieux pour arriver rapidement. Cordialement. » Message 2 : « Bonjour Monsieur, vous avez oublié votre ordinateur portable dans mon véhicule hier soir à la fin de votre course. Je le tiens à votre disposition : je peux vous le rapporter ou le déposer à l'adresse de votre choix. Cordialement. » Règles communes : une salutation adaptée ; les faits exposés simplement (quoi, quand, pourquoi) sans justifications interminables ; une solution proposée (heure d'arrivée estimée, modalités de restitution) ; une formule de politesse finale ; un registre professionnel sans familiarité ni langage SMS ; une relecture systématique des accords et des homophones, en particulier le piège du futur « je serai » (et non « je serais », conditionnel). Un message court, factuel et sans faute vaut toujours mieux qu'un long message brouillon : il rassure le client et protège votre image.$mft$,
   $mft$Barème /5 : message de retard complet (salutation, faits, excuse, solution, politesse) (1,5 pt) ; message objet trouvé complet avec solution de restitution (1,5 pt) ; règles de forme communes dégagées (structure en quatre temps, registre professionnel) (1,5 pt) ; mention de la relecture et du piège je serai/je serais (0,5 pt). Erreurs fréquentes : ton familier ; messages sans solution proposée ; fautes d'homophones dans les messages eux-mêmes.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-5','question-redigee'], 'TAXI-M5-QR-03', false,
   $mft$Deux messages professionnels types et leurs règles de forme.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Fin de course à l'aéroport : le compteur affiche vingt-cinq euros, votre client anglophone tend un billet de cinquante euros, souhaite un reçu et doit trouver son terminal. Rédigez toutes vos répliques en anglais, du prix annoncé au dépôt du client, et précisez le montant de la monnaie rendue.$mft$,
   $mft$Réponse modèle. Annonce du prix : « That will be twenty-five euros, please. » Le client tend cinquante euros : « Out of fifty? Here is your change: twenty-five euros. » (cinquante moins vingt-cinq : vingt-cinq euros rendus, comptés à voix haute pour éviter toute contestation). Reçu : « Would you like a receipt? Here you are. » Terminal : « Which airline are you flying with? » Le client répond ; « Your airline departs from Terminal 2. I will drop you at the drop-off area, right in front of the departures. » Dépôt : « Here we are. I will take your suitcases out of the trunk. Have a nice flight! » L'ordre des répliques suit la logique de la fin de course : prix annoncé, encaissement et monnaie exacte, reçu proposé, compagnie et terminal confirmés, dépôt à la zone de dépose avec les bagages, formule de départ aimable. La monnaie annoncée en la comptant et le reçu proposé spontanément sont deux marques de professionnalisme particulièrement appréciées de la clientèle d'affaires, qui en a besoin pour ses notes de frais.$mft$,
   $mft$Barème /5 : prix annoncé avec that will be (1 pt) ; monnaie exacte calculée et annoncée (vingt-cinq euros rendus) (1 pt) ; reçu proposé (would you like a receipt) (0,5 pt) ; terminal déterminé par la compagnie (which airline) et dépôt à la drop-off area (1,5 pt) ; dépôt complet (bagages sortis, formule finale) (1 pt). Erreurs fréquentes : monnaie fausse ; oublier le reçu ; déposer sans confirmer le terminal.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-5','question-redigee'], 'TAXI-M5-QR-04', false,
   $mft$La fin de course à l'aéroport en anglais : prix, monnaie, reçu, terminal.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Comparez le small talk réussi et le small talk raté avec un client étranger : sujets à privilégier, sujets à proscrire, longueur des interventions, lecture des signaux du client et manière de clore poliment la conversation. Donnez des exemples de formulation en anglais.$mft$,
   $mft$Réponse modèle. Le small talk réussi : des sujets neutres et positifs (la météo : « It is a beautiful day », le séjour : « Is this your first time in Paris? », un monument sur le trajet), des interventions brèves qui laissent le client mener l'échange, un ton souriant et l'attention à la conduite maintenue en permanence. Le small talk raté : les sujets sensibles (politique, religion, argent), les confidences personnelles, le monologue du chauffeur, les questions insistantes et les opinions tranchées ou les plaintes sur la circulation. La lecture des signaux : un client qui répond par monosyllabes, ouvre son ordinateur ou regarde son téléphone souhaite le calme : on respecte son silence sans se vexer, car la conversation est un service, pas un dû. Pour clore avec élégance : « Well, I will let you rest. Do not hesitate if you need anything. » La règle d'or : le client choisit le niveau de conversation, le chauffeur s'y ajuste. À l'examen comme en course, on attend des formules simples, correctes et polies plutôt qu'un vocabulaire sophistiqué mal maîtrisé.$mft$,
   $mft$Barème /5 : sujets à privilégier avec exemples en anglais (1 pt) ; sujets à proscrire (1 pt) ; brièveté et client qui mène l'échange (1 pt) ; lecture des signaux (monosyllabes, téléphone) et respect du silence (1 pt) ; clôture polie formulée en anglais (1 pt). Erreurs fréquentes : réduire le small talk à parler beaucoup ; ignorer les signaux du client ; exemples donnés uniquement en français.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-5','question-redigee'], 'TAXI-M5-QR-05', false,
   $mft$Le small talk professionnel comparé : réussite, échec, signaux, clôture.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Il vous reste six semaines avant l'examen et vos points faibles sont l'orthographe et la rédaction. Construisez votre plan d'entraînement hebdomadaire pour l'épreuve de français : exercices, supports tirés du métier, durées et manière de mesurer vos progrès.$mft$,
   $mft$Réponse modèle. Semaine type : trois séances courtes valent mieux qu'une longue. Séance 1 (30 minutes) : homophones et accords : dix phrases du métier à corriger (a/à, et/est, ce/se) en appliquant les astuces de remplacement (avait, était) ; noter ses erreurs récurrentes dans un carnet. Séance 2 (30 minutes) : compréhension : lire un texte court du quotidien professionnel (article, consigne de centrale, avis client) puis répondre à trois questions par phrases complètes reprenant les mots de la question. Séance 3 (30 minutes) : rédaction : un message professionnel par semaine en variant les scénarios (retard, objet trouvé, confirmation de prise en charge, réponse à une réclamation) avec la structure salutation, faits, solution, politesse. Progression sur six semaines : semaines 1 et 2 sans limite de temps, semaines 3 et 4 en temps limité, semaines 5 et 6 en conditions d'examen avec relecture chronométrée de cinq minutes. Mesure des progrès : compter les fautes par texte (l'objectif est une baisse continue), faire relire un message par un proche, refaire en semaine 6 les exercices ratés de la semaine 1. La régularité prime sur l'intensité.$mft$,
   $mft$Barème /5 : trois types d'exercices couvrant orthographe, compréhension et rédaction (1,5 pt) ; supports tirés du métier (consignes clients, messages professionnels) (1 pt) ; progression vers les conditions d'examen (temps limité, relecture chronométrée) (1,5 pt) ; mesure des progrès concrète (carnet d'erreurs, comptage des fautes, exercices refaits) (1 pt). Erreurs fréquentes : plan vague sans durées ; tout miser sur des dictées scolaires ; aucun indicateur de progrès.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-5','question-redigee'], 'TAXI-M5-QR-06', false,
   $mft$Un plan d'entraînement de six semaines pour l'épreuve de français.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Cas complet : vous conduisez à l'aéroport une cliente anglophone dont l'avion décolle dans une heure trente ; un accident bloque l'autoroute et vous devez prendre une déviation avec des travaux. Elle s'inquiète de rater son vol. Rédigez vos interventions en anglais aux moments clés (annonce du problème, information sur la déviation, réassurance, arrivée) et précisez la posture professionnelle qui accompagne les mots.$mft$,
   $mft$Réponse modèle. Annonce immédiate et calme : « I am sorry, there is a traffic jam on the highway because of an accident. » Information sur la solution : « There is a small detour, but do not worry: it takes about fifteen more minutes. » Réassurance factuelle plutôt que promesse vague : donner un horaire estimé rapporté à l'heure du vol : « We will be at the airport around ten past nine, you have time for your flight. » Pendant la déviation, informer sans surcharger : « Roadworks here, this is why we turn left. » À l'approche : « Which airline are you flying with? I will drop you at the drop-off area, right in front of the departures. » À l'arrivée : sortir les bagages en premier, puis « Here we are. Have a good flight! » La posture qui accompagne les mots : une voix posée, aucune conduite agressive pour « rattraper » le temps (la sécurité prime et la nervosité du chauffeur aggrave celle de la cliente), pas de promesse intenable, des informations factuelles régulières : c'est l'information qui rassure, pas les formules creuses.$mft$,
   $mft$Barème /5 : annonce du problème avec excuse et cause (traffic jam, accident) (1 pt) ; déviation expliquée (detour, roadworks) avec durée estimée (1 pt) ; réassurance factuelle rapportée à l'heure du vol (1 pt) ; arrivée organisée (airline, drop-off area, bagages) (1 pt) ; posture : calme, conduite sûre, informations régulières (1 pt). Erreurs fréquentes : promettre l'impossible ; rouler dangereusement pour compenser ; laisser la cliente sans information.$mft$,
   5, 'difficile', ARRAY['taxi-vtc','module-5','question-redigee'], 'TAXI-M5-QR-07', false,
   $mft$L'imprévu scénarisé : informer, rassurer et déposer une cliente pressée.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Un collègue candidat affirme : « L'anglais de l'examen, c'est du par cœur : dix phrases apprises et c'est réglé. » Discutez cette affirmation : ce que le par cœur couvre réellement, ses limites face à un vrai client ou à une question reformulée, et la méthode pour construire un anglais professionnel réutilisable.$mft$,
   $mft$Réponse modèle. Ce que le par cœur couvre : les situations prévisibles de la course suivent un script stable (accueil, bagages, durée, itinéraire, prix, reçu) : mémoriser les phrases types est donc le socle indispensable, et c'est un investissement rentable. Ses limites : le client ne récite pas le même script : il reformule, enchaîne les questions, parle vite ; une question d'examen peut tester la compréhension d'une variante, et un dialogue à compléter exige de choisir la réplique cohérente, pas de réciter. Le par cœur seul s'effondre dès que la situation dévie du script appris. La méthode complète : apprendre des structures réutilisables plutôt que des phrases figées (« it takes about... » fonctionne avec toutes les durées, « would you like...? » avec toutes les propositions), maîtriser le vocabulaire clé par thèmes (bagages, paiement, imprévus, aéroport) pour comprendre une phrase inconnue grâce aux mots repérés, pratiquer à voix haute en variant les scénarios, et accepter de faire répéter poliment (« Sorry, could you repeat, please? ») : comprendre l'essentiel et répondre simplement vaut mieux que réciter parfaitement à côté de la question.$mft$,
   $mft$Barème /5 : reconnaissance du socle par cœur et de son utilité (1 pt) ; limites argumentées (reformulations du client, variantes à l'examen) (1,5 pt) ; structures réutilisables avec exemples (it takes about, would you like) (1,5 pt) ; stratégie de compréhension (vocabulaire par thèmes, faire répéter poliment) (1 pt). Erreurs fréquentes : tout rejeter ou tout accepter en bloc ; aucun exemple de structure ; confondre mémoriser et comprendre.$mft$,
   5, 'difficile', ARRAY['taxi-vtc','module-5','question-redigee'], 'TAXI-M5-QR-08', false,
   $mft$Le par cœur en anglais : socle utile, limites réelles, méthode complète.$mft$);

  RAISE NOTICE 'Module 5 Taxi-VTC créé : module %, 3 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $taxim5$;
