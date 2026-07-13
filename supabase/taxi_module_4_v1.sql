-- =====================================================================
-- TAXI / VTC (T3P) : MODULE 4 : SÉCURITÉ ROUTIÈRE DU CONDUCTEUR T3P
-- v1 (juillet 2026) : LOT TAXI-VTC
-- Angle conducteur : vigilance et substances en scénarios métier,
-- conduite en ville avec des clients à bord, passagers particuliers
-- (enfants, PMR) et réaction à l'accident.
-- ⚠ STATUT : active = false (« à valider »). Idempotent.
-- =====================================================================

DO $taxim4$
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

  DELETE FROM public.question_bank WHERE source_ref LIKE 'TAXI-M4-%';
  DELETE FROM public.modules WHERE slug = 'taxi-vtc-securite-routiere';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 4 : Sécurité routière du conducteur T3P',
    'taxi-vtc-securite-routiere', v_bloc,
    'La sécurité routière appliquée au transport de personnes en ville : vigilance et substances au volant d''un client, partage de la voirie, transport d''enfants et réaction à l''accident.',
    'intermediaire', 240, 40) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 40, true);

  -- ─── Leçon 1 : Vigilance et substances en scénarios ─────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'vigilance-substances-scenarios',
    'Vigilance au volant : fatigue, substances et écrans',
    $mft$> 🎯 **Objectifs**
> - Reconnaître les signaux de fatigue en fin de service et décider l'arrêt à temps.
> - Refuser alcool, stupéfiants et médicaments incompatibles, même sous la pression amicale d'un client.
> - Faire du téléphone un outil de travail maîtrisé, jamais une distraction au volant.

## La nuit du chauffeur : un risque qui monte en silence

Samedi soir, vous avez enchaîné les sorties de restaurants puis les fins de soirée. Il est 3 h 40, une course aéroport vient de tomber : quarante minutes de voie rapide monotone. C'est exactement le profil de la course à risque : le corps réclame du sommeil au moment précis où la route ne stimule plus l'attention.

:::timeline
1. **22 h** : prise de service, vigilance élevée, trafic encore dense et stimulant
2. **1 h** : sorties de bars, les courses s'enchaînent, premiers bâillements entre deux clients
3. **3 h** : creux physiologique de la nuit, la vigilance est au plus bas quel que soit le café avalé
4. **4 h 30** : course aéroport, voie rapide monotone, habitacle chauffé, client endormi : cocktail à risque maximal
5. **6 h** : retour à vide, la garde baissée : l'accident de fin de service guette
:::

Les signaux qui imposent l'arrêt : bâillements répétés, paupières lourdes, regard qui se fige, difficultés à tenir la trajectoire, souvenirs flous des derniers kilomètres. À ce stade, le micro-sommeil menace : quelques secondes d'absence suffisent pour traverser un carrefour en aveugle, avec un client à bord.

> ⚠️ **Attention**
> Café, fenêtre ouverte, radio à fond : ces parades donnent quelques minutes d'illusion, pas de vigilance. Le seul remède efficace contre le sommeil est le sommeil : une vraie pause avec repos, ou la fin du service.

Le professionnel organise sa nuit : arriver reposé (sieste avant le service), pauses courtes et régulières dans les creux entre deux vagues de clients, repas légers, et une règle non négociable : au premier signal sérieux, on s'arrête en lieu sûr, quitte à refuser la course suivante.

## Le dernier verre : un scénario à savoir refuser

Fin de mariage, 2 h du matin. Le père de la mariée, ravi de votre service, insiste : « un dernier verre avec nous, vous le méritez ! ». Il vous reste deux navettes d'invités à assurer. La réponse professionnelle est simple : merci, mais non. Celui qui raccompagne des clients alcoolisés reste soumis aux mêmes seuils que n'importe quel conducteur : contravention dès 0,5 g d'alcool par litre de sang, délit à partir de 0,8 g/L. Le contexte festif, la gentillesse du client ou une prétendue « décharge » n'y changent rien.

> ❌ **Piège à éviter**
> « Une seule coupe, ça ne se voit pas. » L'alcool s'élimine lentement : le verre accepté à 2 h peut encore compter au contrôle de 4 h, et l'alcool de la veille peut suffire le lendemain matin. En cas d'accident avec des passagers à bord, l'addition est professionnelle autant que pénale.

Refuser avec élégance renforce d'ailleurs votre image : « je ne bois jamais en service, c'est ce qui garantit que vos invités rentrent bien ». Un soft, un remerciement, et tout le monde y gagne.

## Stupéfiants : tolérance zéro

Pour les stupéfiants, il n'existe aucun seuil toléré au volant : c'est la tolérance zéro. Le dépistage salivaire au bord de la route détecte des traces plusieurs jours après la consommation : le « joint du samedi soir » peut être positif au contrôle du lundi matin, alors même que les effets ressentis ont disparu. Pour un professionnel dont la carte est le gagne-pain, l'enjeu dépasse la sanction routière : c'est l'activité elle-même qui est en jeu.

## Médicaments : lire la boîte avant de prendre le volant

Antiallergiques, sirops, anxiolytiques, certains antidouleurs : de nombreux traitements courants altèrent la vigilance. Les boîtes portent des pictogrammes gradués, du simple appel à la prudence jusqu'à l'incompatibilité avec la conduite.

> 💡 **Astuce**
> Chez le médecin ou le pharmacien, annoncez systématiquement votre métier : « je conduis des clients toute la journée ». Il existe presque toujours une alternative compatible avec la conduite professionnelle. Et jamais d'automédication associée au volant sans cet avis.

## Le chauffeur connecté : l'écran, tentation permanente

Le téléphone est votre outil de travail : courses, guidage, messages clients. C'est précisément ce qui le rend dangereux : la sollicitation est permanente. Tenir le téléphone en main en conduisant est interdit, et le danger va au-delà de l'interdit : chaque regard à l'écran cumule distraction visuelle, manuelle et cognitive. À 50 km/h, une seconde d'écran représente environ 14 mètres parcourus sans regarder la route.

| Situation | Réflexe professionnel |
| --- | --- |
| Guidage GPS | Itinéraire saisi à l'arrêt, guidage vocal, support fixe qui ne masque pas la vue |
| Nouvelle course | Acceptation à l'arrêt en lieu licite, jamais en roulant ni arrêté au feu |
| Message client | Réponse différée ou message automatique : « je conduis, je réponds à l'arrêt » |
| Appel entrant | Laisser sonner : le rappel trois minutes plus tard n'a jamais perdu un client |

> 📌 **À retenir**
> La règle qui simplifie tout : TOUT se règle à l'arrêt. Un chauffeur arrêté trente secondes en lieu sûr reste plus rentable qu'un chauffeur accidenté.

## ✅ Synthèse

- Fatigue : signaux (bâillements, paupières, trajectoire) = **arrêt immédiat** ; seule la pause repose, pas le café.
- Alcool : les seuils s'appliquent au professionnel **en toutes circonstances** (contravention dès 0,5 g/L, délit à 0,8 g/L) ; stupéfiants : **tolérance zéro**, détection plusieurs jours après.
- Médicaments : pictogrammes lus, métier annoncé au prescripteur.
- Téléphone : support fixe, guidage vocal, **tout réglage à l'arrêt**.$mft$,
    $mft$La fatigue nocturne du chauffeur en scénario (signaux, pauses, décision d'arrêt), le refus du dernier verre malgré la pression du client (seuils 0,5 et 0,8 g/L), la tolérance zéro stupéfiants, les médicaments à pictogrammes et la maîtrise du téléphone connecté.$mft$,
    1, 35) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : Conduire en ville avec des clients à bord ────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'conduire-en-ville-avec-clients',
    'Conduire en ville avec des clients à bord',
    $mft$> 🎯 **Objectifs**
> - Adopter une conduite souple qui protège les usagers ET met le client en confiance.
> - Repérer cyclistes, trottinettes et piétons dans les angles morts urbains, jusqu'à la portière.
> - Choisir des arrêts de prise en charge et de dépose sûrs et licites, sans double file dangereuse.

## La conduite souple : le confort est un sous-produit de la sécurité

Un client détendu à l'arrière, c'est d'abord un conducteur qui lit la circulation loin devant : feux, flux de piétons, bus qui déboîte, livreur qui va s'arrêter. Cette lecture anticipée permet de lever le pied tôt, de freiner progressivement, de doser le volant. Résultat : pas de coups de frein qui projettent le client vers l'avant, pas de mal des transports, une conversation possible. Et exactement les mêmes gestes créent la sécurité : rouler souple, c'est conserver en permanence une marge de réaction.

En flux dense, la tentation du « collage » est forte : elle ne fait gagner que quelques mètres et supprime toute marge. Le professionnel maintient un intervalle constant avec le véhicule qui précède et anticipe les vagues de ralentissement : moins de freinages d'urgence, moins de risque de carambolage, et une note client qui grimpe.

> 🎓 **Pour l'examen**
> Les jurys valorisent le lien explicite entre confort du passager et sécurité : c'est la même conduite. Un candidat qui oppose « rapidité pour le client » et « prudence » se trompe de métier.

## Partager la voirie : les vulnérables ne font pas de bruit

La ville du T3P est saturée d'usagers vulnérables, souvent silencieux et rapides :

| Usager | Où il surgit | Le réflexe qui protège |
| --- | --- | --- |
| Cycliste | Entre les files, dans l'angle mort droit, au sas vélo des feux | Contrôle rétro + tête avant tout déport, large espace latéral au dépassement |
| Trottinette | Depuis les trottoirs et passages piétons, vitesse sous-estimée | Balayage visuel systématique aux intersections, vitesse réduite |
| Piéton | Masqué par un bus, un camion de livraison, une file arrêtée | Se méfier de tout masque de visibilité : pied levé, prêt à freiner |

Les montants du pare-brise et les rétroviseurs créent des angles morts qui cachent entièrement un piéton ou un cycliste proche : on bouge la tête, pas seulement les yeux.

> 🔍 **Zoom**
> Le « masque » est le piège urbain numéro un : le bus arrêté cache le piéton qui traverse devant lui. Ce que vous ne voyez pas n'est pas un espace vide : c'est un danger potentiel.

## La portière : le geste hollandais

L'« emportiérage » (une portière ouverte dans la trajectoire d'un cycliste) est un accident typique du transport de personnes : vos clients ouvrent des portières toute la journée. La parade s'appelle la poignée hollandaise : ouvrir la portière avec la main opposée (main droite pour une portière gauche). Le buste pivote, le regard balaie naturellement le rétroviseur et l'angle mort. Appliquez-la vous-même, et briefez le client quand la situation l'exige : « attendez une seconde, un vélo arrive : descendez plutôt côté trottoir ».

## S'arrêter pour charger et déposer : sûr et licite

L'arrêt est le moment de vérité du métier. La double file « juste deux minutes » devant l'école ou la pharmacie masque les piétons, bloque cyclistes et bus, et engage votre responsabilité.

:::flow
1. Repérer | Une zone d'arrêt licite et dégagée, même vingt mètres plus loin
2. Annoncer | Prévenir le client : « je vous dépose juste après, c'est plus sûr »
3. Signaler | Clignotant tôt, ralentissement progressif sans surprendre personne
4. S'arrêter | Le long du trottoir, hors passage piéton, sortie de parking et piste cyclable
5. Contrôler | Rétros et angles morts AVANT d'autoriser l'ouverture des portières
6. Accompagner | Descente et bagages côté trottoir, puis réinsertion avec contrôle et clignotant
:::

> ❌ **Piège à éviter**
> Les feux de détresse ne transforment pas un arrêt dangereux en arrêt autorisé : ils signalent, ils n'autorisent rien. « Le client l'a demandé » n'est pas un argument opposable : le choix du point d'arrêt vous appartient.

## Zones 30 et zones de rencontre : la ville apaisée

Les centres-villes multiplient les zones 30 et les zones de rencontre, où la circulation apaisée redonne l'avantage aux plus vulnérables : dans la zone de rencontre, le piéton est prioritaire et peut circuler sur la chaussée. Le chauffeur y adopte le pas roulant : vitesse très réduite, pied prêt au frein, aucune manœuvre d'intimidation (klaxon, collage des piétons). Ces zones sont votre terrain de travail quotidien : les subir, c'est s'épuiser ; les intégrer au trajet et au discours client (« le centre est en zone de rencontre, on roule au pas »), c'est du professionnalisme.

## ✅ Synthèse

- Conduite souple = **sécurité + confort + note client** : même geste, triple gain ; intervalle constant en flux dense.
- Vulnérables : angle mort contrôlé de la tête, **méfiance devant tout masque**, large espace aux cyclistes.
- Portière : **poignée hollandaise** et descente côté trottoir, client briefé.
- Arrêts : licites et dégagés, jamais de double file dangereuse ; **les feux de détresse n'autorisent rien**.
- Zone de rencontre : piéton prioritaire, allure au pas.$mft$,
    $mft$La conduite souple qui sert à la fois la sécurité et le confort du client, la protection des usagers vulnérables (angles morts, masques, poignée hollandaise), les arrêts de dépose sûrs et licites en six gestes et la circulation apaisée (zones 30 et de rencontre).$mft$,
    2, 35) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : Passagers particuliers et accident ───────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'passagers-particuliers-accident',
    'Passagers particuliers et conduite à tenir en cas d''accident',
    $mft$> 🎯 **Objectifs**
> - Assumer vos responsabilités sur les ceintures et l'installation des enfants.
> - Accueillir les passagers à mobilité réduite avec méthode et dignité.
> - Dérouler la séquence complète en cas d'accident avec un client à bord.

## Ceintures : qui répond de quoi

À bord, chaque passager majeur répond de sa propre ceinture. En revanche, le conducteur est responsable des passagers mineurs : c'est à vous de vérifier qu'ils sont attachés, avec un dispositif adapté, avant de démarrer. Le réflexe professionnel dépasse la répartition juridique : un regard circulaire et une phrase simple (« tout le monde est attaché ? ») avant chaque départ, quelle que soit la longueur de la course. Un passager non attaché à l'arrière devient un projectile pour lui-même et pour les autres au moindre choc.

> 📌 **À retenir**
> Mineur non attaché = responsabilité du conducteur. Adulte non attaché = sa propre responsabilité, mais votre professionnalisme consiste à le rappeler courtoisement avant de partir.

## Transporter des enfants : la règle générale et le réflexe pro

La règle générale du transport d'enfants : un dispositif de retenue adapté à la morphologie (siège ou rehausseur), installé de préférence à l'arrière, jusqu'à l'âge fixé par la réglementation. Des dérogations spécifiques aux taxis sont parfois évoquées : ce point est à vérifier dans les textes en vigueur avant de s'en prévaloir. Une chose est certaine : la dérogation éventuelle est une tolérance juridique, pas une protection physique. En cas de choc, un enfant sur les genoux d'un adulte ceinturé n'est retenu par rien.

| Passager | Installation professionnelle |
| --- | --- |
| Bébé et jeune enfant | Siège adapté à sa taille, à l'arrière, demandé ou confirmé dès la réservation |
| Enfant plus grand | Rehausseur (en garder un propre dans le coffre : petit investissement, grand signal de sérieux) |
| Adolescent | Ceinture classique, vérifiée par le conducteur tant qu'il est mineur |

> 🎓 **Pour l'examen**
> Sur les enfants en taxi, la réponse attendue distingue la règle générale, l'éventuelle dérogation (à vérifier) et la posture professionnelle : équipement adapté, anticipé dès la réservation.

## PMR : l'aide à la personne fait partie du service

Transporter une personne à mobilité réduite, c'est du transport ET du service : proposer l'aide sans l'imposer (« souhaitez-vous que je vous aide ? »), respecter le rythme de la personne, sécuriser le transfert vers le siège, plier et arrimer le fauteuil dans le coffre, puis refaire le chemin inverse à l'arrivée jusqu'à un endroit sûr. Le chien guide ou d'assistance accompagne son maître dans l'habitacle : son refus est sanctionnable et commercialement désastreux. Patience et dignité sont les maîtres mots : on aide une personne, on ne manipule pas un colis.

## L'accident avec un client à bord

L'accrochage arrive même aux meilleurs. Avec un client à bord, votre gestion est doublement observée : par la loi et par le client.

:::flow
1. Protéger | Feux de détresse, véhicule dégagé si possible, gilet haute visibilité, passagers à l'abri hors circulation
2. Alerter | Blessé ou danger : appel au 112 avec localisation précise et état des victimes
3. Secourir | Parler, couvrir, rassurer : ne jamais déplacer un blessé sauf danger immédiat
4. Constater | Constat amiable : des faits et un croquis, jamais de conclusions ni de reconnaissance de tort ; photos
5. Déclarer | Exploitation ou centrale immédiatement, assureur dans les délais du contrat, mention des passagers à bord
6. Prendre en charge | Réacheminement du client, effets personnels, suivi après la course
:::

Deux points méritent insistance. Le constat d'abord : il consigne des faits (positions, sens de circulation, dégâts visibles), pas des interprétations ; l'« arrangement sans papiers » proposé par l'autre conducteur est un piège, surtout avec un passager qui pourrait déclarer des douleurs le lendemain. Le client ensuite : même indemne, il reste votre responsabilité commerciale jusqu'à destination : organiser son réacheminement (autre chauffeur, centrale), lui restituer ses effets, reprendre contact ensuite. Un accident bien géré peut paradoxalement renforcer la confiance.

> ❌ **Piège à éviter**
> Écrire « je suis désolé, je ne l'ai pas vu » sur un constat, c'est signer une reconnaissance de responsabilité. Les faits, rien que les faits : l'assureur qualifiera.

## Trousse de secours et extincteur : l'équipement du professionnel

Trousse de premiers secours, gilet et triangle, extincteur, constats vierges et lampe : les obligations exactes varient selon les textes et les règles locales applicables aux taxis et VTC (point à vérifier auprès de votre autorité locale), mais le professionnel ne raisonne pas en minimum légal. Savoir où se trouve chaque élément, vérifier les dates de péremption, remplacer ce qui a servi : le jour où l'équipement sert, il sert vraiment.

> 🔍 **Zoom**
> Un extincteur enfoui au fond du coffre sous trois valises ne sert à rien : l'équipement d'urgence se range accessible, et son emplacement se connaît par cœur.

## ✅ Synthèse

- Ceintures : le conducteur répond des **mineurs** ; vérification systématique avant chaque départ.
- Enfants : dispositif adapté anticipé à la réservation ; dérogations taxi éventuelles **à vérifier**, mais l'équipement adapté reste la norme professionnelle.
- PMR : aide proposée, rythme respecté, fauteuil arrimé ; **le chien guide monte à bord**.
- Accident : protéger, alerter (112), secourir, **constat factuel sans reconnaissance de tort**, déclaration, prise en charge du client.
- Équipement d'urgence : accessible, vérifié, connu par cœur.$mft$,
    $mft$Les responsabilités du conducteur sur les ceintures des mineurs, le transport d'enfants (dispositifs adaptés, dérogations taxi à vérifier), l'accueil des PMR et du chien guide, la séquence complète de l'accident avec client à bord et l'équipement d'urgence du professionnel.$mft$,
    3, 40) RETURNING id INTO v_l3;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : Sécurité routière T3P',
    'Vérifiez le module 4 : vigilance au volant, partage de la voirie et gestion de l''accident avec un client à bord.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Fin de service, 3 h du matin : bâillements répétés et paupières lourdes sur la voie rapide, il reste vingt minutes de route. Quel est le bon réflexe ?$mft$,
    $mft$[
      {"id":"a","label":"S'arrêter dès que possible en lieu sûr pour une vraie pause, quitte à refuser la course suivante","is_correct":true},
      {"id":"b","label":"Monter le volume de la radio et ouvrir la fenêtre","is_correct":false},
      {"id":"c","label":"Continuer : la maison n'est qu'à vingt minutes","is_correct":false},
      {"id":"d","label":"Boire un café en roulant pour tenir jusqu'au bout","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-4','qcm-v1'], 'TAXI-M4-QCM-01', false,
    $mft$Seuls l'arrêt et le repos traitent la fatigue : radio, fenêtre et café donnent quelques minutes d'illusion, et « la maison est proche » est le raisonnement type de l'accident de fin de service.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Votre client s'apprête à descendre ; une piste cyclable longe votre file côté chaussée. Quelle consigne donnez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Descendre côté trottoir et, si le côté chaussée est inévitable, ouvrir avec la main opposée après contrôle (poignée hollandaise)","is_correct":true},
      {"id":"b","label":"Ouvrir vite pour ne pas bloquer la circulation derrière","is_correct":false},
      {"id":"c","label":"Laisser le client gérer sa descente : ce n'est pas votre rôle","is_correct":false},
      {"id":"d","label":"Allumer les feux de détresse, ce qui sécurise l'ouverture","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-4','qcm-v1'], 'TAXI-M4-QCM-02', false,
    $mft$La descente côté trottoir supprime le risque d'emportiérage et la main opposée force le contrôle de l'angle mort ; les feux de détresse n'autorisent rien et la sécurité des portières reste sous la responsabilité du conducteur.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Une cliente monte avec son fils de six ans, sans aucun dispositif prévu. Quelle est l'attitude professionnelle ?$mft$,
    $mft$[
      {"id":"a","label":"Installer l'enfant à l'arrière sur le rehausseur que vous gardez dans le coffre","is_correct":true},
      {"id":"b","label":"L'asseoir sur les genoux de sa mère, elle-même ceinturée","is_correct":false},
      {"id":"c","label":"L'installer à l'avant pour mieux le surveiller","is_correct":false},
      {"id":"d","label":"Partir sans dispositif : le trajet est court","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-4','qcm-v1'], 'TAXI-M4-QCM-03', false,
    $mft$Le rehausseur du coffre est la réponse professionnelle : les genoux d'un adulte ne retiennent rien en cas de choc, l'avant n'est pas la place d'un enfant et la courte distance n'a jamais amorti une collision.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Une notification de course arrive sur l'application pendant que vous roulez en ville. Que faites-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Elle attend : vous n'interagissez avec l'application qu'à l'arrêt en lieu licite, téléphone sur support fixe","is_correct":true},
      {"id":"b","label":"Vous acceptez d'un geste rapide : l'application est un outil de travail","is_correct":false},
      {"id":"c","label":"Vous prenez le téléphone en main au prochain feu rouge","is_correct":false},
      {"id":"d","label":"Vous acceptez en roulant si le trafic est fluide","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-4','qcm-v1'], 'TAXI-M4-QCM-04', false,
    $mft$Tout réglage et toute acceptation se font à l'arrêt en lieu licite : le téléphone tenu en main en conduisant est interdit, y compris arrêté au feu dans la circulation, et le trafic fluide ne supprime pas la distraction.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Fin de mariage, 2 h du matin : le père de la mariée insiste pour trinquer, il vous reste deux navettes d'invités à assurer. Votre réponse ?$mft$,
    $mft$[
      {"id":"a","label":"Refuser poliment : au volant vous restez soumis aux seuils (contravention dès 0,5 g/L, délit à 0,8 g/L), quel que soit le contexte","is_correct":true},
      {"id":"b","label":"Accepter une coupe : une seule ne se détecte pas","is_correct":false},
      {"id":"c","label":"Accepter puis attendre un quart d'heure avant de repartir","is_correct":false},
      {"id":"d","label":"Accepter si le client signe une décharge","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-4','qcm-v1'], 'TAXI-M4-QCM-05', false,
    $mft$Les seuils s'appliquent au professionnel en toutes circonstances : une seule coupe peut suffire à approcher 0,5 g/L, un quart d'heure n'élimine presque rien et aucune décharge d'un client n'a de valeur juridique.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$En zone de rencontre, un groupe de piétons marche au milieu de la chaussée devant vous. Votre client est pressé. Que faites-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Rouler au pas derrière eux : le piéton est prioritaire et peut circuler sur la chaussée dans cette zone","is_correct":true},
      {"id":"b","label":"Klaxonner pour dégager le passage","is_correct":false},
      {"id":"c","label":"Les contourner en montant partiellement sur le trottoir","is_correct":false},
      {"id":"d","label":"Accélérer dès qu'un espace se libère pour rattraper le temps","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-4','qcm-v1'], 'TAXI-M4-QCM-06', false,
    $mft$En zone de rencontre, le piéton est prioritaire : on roule au pas derrière lui ; klaxon, trottoir et accélération sont des fautes, quel que soit l'agenda du client.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Votre client demande d'attendre « juste deux minutes » en double file devant la pharmacie, en masquant un passage piéton. Votre décision ?$mft$,
    $mft$[
      {"id":"a","label":"Refuser et trouver un arrêt licite à proximité, quitte à faire le tour du pâté de maisons","is_correct":true},
      {"id":"b","label":"Accepter en allumant les feux de détresse","is_correct":false},
      {"id":"c","label":"Accepter à condition de rester au volant","is_correct":false},
      {"id":"d","label":"Accepter : l'usage le tolère pour le transport de personnes","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-4','qcm-v1'], 'TAXI-M4-QCM-07', false,
    $mft$Masquer un passage piéton en double file crée un danger immédiat pour les traversées : les feux de détresse signalent mais n'autorisent rien, rester au volant ne rend pas l'arrêt licite et aucun « usage » ne couvre un arrêt dangereux.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Accrochage léger avec un client à bord : l'autre conducteur propose de « s'arranger sans papiers ». Le client est indemne mais choqué. Que faites-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Sécuriser, vous assurer de l'état du client, remplir un constat factuel et prévenir centrale et assureur","is_correct":true},
      {"id":"b","label":"Accepter l'arrangement pour repartir plus vite avec le client","is_correct":false},
      {"id":"c","label":"Écrire sur le constat que l'autre conducteur est en tort pour accélérer le dossier","is_correct":false},
      {"id":"d","label":"Déposer d'abord le client à destination, puis revenir constater","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-4','qcm-v1'], 'TAXI-M4-QCM-08', false,
    $mft$Avec un passager à bord, l'arrangement sans papiers est un piège (des douleurs peuvent être déclarées le lendemain) ; le constat consigne des faits, jamais des conclusions, et on ne quitte pas les lieux avant de constater.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Vous commencez un traitement antiallergique dont la boîte porte un pictogramme signalant un risque de somnolence ; votre service commence ce soir. Que faites-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Demander au médecin ou au pharmacien, en précisant votre métier, une alternative compatible avec la conduite avant de prendre le volant","is_correct":true},
      {"id":"b","label":"Prendre le traitement et compenser avec du café","is_correct":false},
      {"id":"c","label":"Diviser la dose par deux de votre propre initiative","is_correct":false},
      {"id":"d","label":"Ignorer le pictogramme : c'est une simple précaution juridique","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-4','qcm-v1'], 'TAXI-M4-QCM-09', false,
    $mft$Le pictogramme signale un risque réel de somnolence : le prescripteur informé du métier trouve presque toujours une alternative ; café et demi-dose improvisée ne sécurisent rien.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Flux dense sur le périphérique, circulation en accordéon, client attentif à la qualité de conduite. Quelle stratégie concilie sécurité et note client ?$mft$,
    $mft$[
      {"id":"a","label":"Maintenir un intervalle constant et anticiper les vagues de ralentissement pour éviter tout freinage brusque","is_correct":true},
      {"id":"b","label":"Coller le véhicule précédent pour ne perdre aucune place","is_correct":false},
      {"id":"c","label":"Changer de file en continu pour progresser plus vite","is_correct":false},
      {"id":"d","label":"Freiner fort au dernier moment pour décourager les insertions","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-4','qcm-v1'], 'TAXI-M4-QCM-10', false,
    $mft$L'intervalle constant et l'anticipation évitent le carambolage ET les à-coups qui dégradent la note ; collage, zigzag et freinages tardifs augmentent le risque sans gain réel de temps.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Un client aveugle se présente avec son chien guide ; votre berline vient d'être nettoyée. Quelle est la seule attitude correcte ?$mft$,
    $mft$[
      {"id":"a","label":"Accueillir le client et son chien guide dans l'habitacle et faciliter leur installation, sans supplément","is_correct":true},
      {"id":"b","label":"Refuser poliment en proposant d'appeler un autre chauffeur","is_correct":false},
      {"id":"c","label":"Accepter en facturant un supplément « animal »","is_correct":false},
      {"id":"d","label":"Exiger que le chien voyage dans le coffre","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-4','qcm-v1'], 'TAXI-M4-QCM-11', false,
    $mft$Le chien guide n'est pas un animal de compagnie ordinaire : il accompagne son maître dans l'habitacle et son refus est sanctionnable ; le renvoi vers un confrère, le supplément et le coffre sont autant de refus déguisés.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Un collègue affirme qu'un « joint fumé samedi soir » est sans risque pour reprendre le volant lundi matin. Qu'en est-il ?$mft$,
    $mft$[
      {"id":"a","label":"C'est faux : les stupéfiants se dépistent plusieurs jours après la consommation et la règle au volant est la tolérance zéro, sans seuil","is_correct":true},
      {"id":"b","label":"C'est vrai si plus de vingt-quatre heures se sont écoulées","is_correct":false},
      {"id":"c","label":"C'est vrai : seul l'alcool est recherché lors des contrôles routiers","is_correct":false},
      {"id":"d","label":"C'est vrai tant qu'aucun effet n'est ressenti","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-4','qcm-v1'], 'TAXI-M4-QCM-12', false,
    $mft$La règle est la tolérance zéro et le dépistage salivaire détecte des traces plusieurs jours après : l'absence d'effet ressenti ne garantit en rien un test négatif, l'alcool n'est pas la seule substance recherchée, et la carte professionnelle est en jeu.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$En fin de service de nuit, quels signes vous imposent l'arrêt immédiat pour une pause ?$mft$,
   $mft$Bâillements répétés, paupières lourdes, regard qui se fige, écarts de trajectoire, souvenirs flous des derniers kilomètres : au premier signe sérieux, arrêt en lieu sûr et repos, seule parade efficace.$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-4','question-courte'], 'TAXI-M4-QC-01', false,
   $mft$Café, fenêtre et radio ne sont pas des remèdes.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Qu'est-ce que la « poignée hollandaise » et quel accident prévient-elle ?$mft$,
   $mft$Ouvrir la portière avec la main opposée : le buste pivote et le regard contrôle naturellement le rétroviseur et l'angle mort. Elle prévient l'emportiérage d'un cycliste ou d'une trottinette.$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-4','question-courte'], 'TAXI-M4-QC-02', false,
   $mft$Geste à appliquer soi-même et à faire appliquer au client.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Qui est responsable du port de la ceinture d'un enfant mineur transporté dans votre véhicule ?$mft$,
   $mft$Le conducteur : il doit s'assurer avant de démarrer que tout passager mineur est attaché avec un dispositif adapté ; les passagers majeurs répondent d'eux-mêmes.$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-4','question-courte'], 'TAXI-M4-QC-03', false,
   $mft$Vérification systématique avant chaque départ.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Fin de mariage : le client insiste pour trinquer et vous devez encore raccompagner des invités. Quels seuils continuent de s'appliquer à vous malgré le contexte festif ?$mft$,
   $mft$Les mêmes qu'à tout conducteur : contravention dès 0,5 g d'alcool par litre de sang, délit à partir de 0,8 g/L. Le contexte festif ou l'insistance du client n'y changent rien : refus poli obligatoire.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-4','question-courte'], 'TAXI-M4-QC-04', false,
   $mft$Aucune dérogation festive, aucune décharge possible.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Un client demande la dépose « juste là », en double file devant une sortie de parking très fréquentée. Que proposez-vous et pourquoi ?$mft$,
   $mft$Refuser et proposer un arrêt licite et dégagé quelques mètres plus loin, le long du trottoir : la double file devant une sortie fréquentée masque la visibilité, expose le client à la descente et engage la responsabilité du conducteur ; les feux de détresse n'y changent rien.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-4','question-courte'], 'TAXI-M4-QC-05', false,
   $mft$Le choix du point d'arrêt appartient au conducteur, pas au client.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Après un accrochage sans blessé avec un client à bord, citez les deux volets de votre gestion : documentaire et commercial.$mft$,
   $mft$Volet documentaire : constat amiable factuel (sans reconnaissance de tort) puis déclaration à l'assureur et à la centrale ou l'exploitation. Volet commercial : rassurer le client, organiser son réacheminement et assurer le suivi (effets personnels, prise de nouvelles).$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-4','question-courte'], 'TAXI-M4-QC-06', false,
   $mft$Les deux volets se mènent de front.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Pourquoi la règle professionnelle est-elle de régler l'application et d'accepter les courses uniquement à l'arrêt ?$mft$,
   $mft$Parce que le téléphone tenu en main en conduisant est interdit et que chaque regard à l'écran cumule distraction visuelle, manuelle et cognitive : à 50 km/h, une seconde d'écran représente environ 14 mètres parcourus sans voir la route.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-4','question-courte'], 'TAXI-M4-QC-07', false,
   $mft$Support fixe + réglages à l'arrêt : la règle qui simplifie tout.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Citez trois usagers vulnérables typiques de la circulation urbaine et le réflexe qui protège chacun.$mft$,
   $mft$Le cycliste (contrôle rétro et tête avant tout déport, large espace au dépassement), la trottinette (balayage visuel aux intersections, vitesse réduite), le piéton (méfiance devant les masques de visibilité, priorité respectée en zone apaisée).$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-4','question-courte'], 'TAXI-M4-QC-08', false,
   $mft$Trois couples usager/réflexe cohérents attendus.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Une famille réserve un VTC avec un bébé, sans siège auto ; le père propose de le tenir dans ses bras. Votre réponse professionnelle ?$mft$,
   $mft$Refuser le trajet dans ces conditions : un bébé tenu dans les bras n'est retenu par rien en cas de choc. Exiger ou fournir un dispositif adapté (à préciser dès la réservation) et reporter la course sinon : d'éventuelles dérogations taxi (point à vérifier) ne remplacent pas la protection physique.$mft$,
   2, 'difficile', ARRAY['taxi-vtc','module-4','question-courte'], 'TAXI-M4-QC-09', false,
   $mft$Professionnalisme = équipement adapté, pas tolérance juridique.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Vous prenez votre service à 19 h après une journée de déménagement presque sans sommeil. Analysez le risque et la décision professionnelle.$mft$,
   $mft$La fatigue accumulée AVANT le service compte autant que les heures de conduite : la vigilance est dégradée dès la première course. Décision : écourter ou décaler le service, planifier des pauses rapprochées, s'auto-surveiller et renoncer aux courses longues de fin de nuit.$mft$,
   2, 'difficile', ARRAY['taxi-vtc','module-4','question-courte'], 'TAXI-M4-QC-10', false,
   $mft$Le risque fatigue se gère avant la prise de service.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Expliquez pourquoi la fatigue est un risque majeur du chauffeur T3P de nuit, puis construisez votre organisation type d'une nuit de week-end (préparation, pauses, signaux d'alerte, décisions).$mft$,
   $mft$Réponse modèle. Pourquoi le risque est majeur : le chauffeur de nuit cumule un horaire à contre-courant de l'horloge biologique (creux de vigilance en milieu de nuit), des trajets monotones (voies rapides, retours à vide) et une pression commerciale (courses qui s'enchaînent aux heures de sortie). La fatigue allonge le temps de réaction, rétrécit le champ visuel et finit en micro-sommeil : quelques secondes suffisent pour traverser un carrefour en aveugle, avec un client à bord dont la sécurité vous incombe. Organisation type d'une nuit de week-end : arriver reposé (sieste en fin d'après-midi, pas de journée épuisante avant le service) ; planifier des pauses courtes et régulières dans les creux entre les vagues de clients plutôt qu'une seule pause tardive ; s'hydrater, éviter les repas lourds ; surveiller ses signaux (bâillements répétés, paupières lourdes, écarts de trajectoire) et s'imposer une règle non négociable : au premier signe sérieux, arrêt en lieu sûr et repos, quitte à refuser une course ; savoir écourter la nuit, car le trajet retour à vide reste un trajet à risque. Décision clé : la course de plus ne vaut jamais un endormissement.$mft$,
   $mft$Barème /5 : mécanisme du risque nocturne expliqué (creux de vigilance, monotonie, micro-sommeil) (1,5 pt) ; signaux d'alerte cités (1 pt) ; organisation concrète (repos avant service, pauses planifiées, hygiène de vie) (1,5 pt) ; décision d'arrêt assumée, y compris refuser une course (1 pt). Erreurs fréquentes : proposer café, fenêtre ou musique comme remèdes ; oublier le trajet retour à vide.$mft$,
   5, 'facile', ARRAY['taxi-vtc','module-4','question-redigee'], 'TAXI-M4-QR-01', false,
   $mft$Le risque fatigue nocturne compris et organisé.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$« La conduite souple est la meilleure alliée du chauffeur. » Développez : montrez comment le même style de conduite sert à la fois la sécurité, le confort du client, la note sur l'application et les coûts du véhicule.$mft$,
   $mft$Réponse modèle. La conduite souple repose sur un principe : lire la circulation loin devant (feux, flux de piétons, bus, livraisons) pour agir tôt et en douceur. Sécurité : anticiper, c'est conserver une marge : distances maintenues, freinages progressifs, pas de manœuvre de dernière seconde ; en flux dense, l'intervalle constant évite le carambolage. Confort du client : pas de coups de frein ni d'accélérations brutales, pas de mal des transports, un client détendu qui peut travailler ou converser : c'est la définition même de la prestation haut de gamme. Note sur l'application : les passagers évaluent d'abord le ressenti de conduite ; la souplesse produit des cinq étoiles et des commentaires positifs, la brutalité des signalements : or la note conditionne l'accès aux courses. Coûts : la conduite souple réduit la consommation de carburant, l'usure des freins et des pneus, et la sinistralité (franchises, malus, immobilisation du véhicule, manque à gagner). Conclusion : il n'existe pas un style « sécurité » et un style « commercial » : le même geste professionnel produit les quatre bénéfices, et c'est le cœur du métier de conducteur T3P.$mft$,
   $mft$Barème /5 : mécanisme de l'anticipation expliqué (1 pt) ; lien sécurité (distances, marge de réaction) (1 pt) ; lien confort client argumenté (1 pt) ; lien note d'application et accès aux courses (1 pt) ; lien coûts (carburant, usure, sinistralité) (1 pt). Erreurs fréquentes : opposer rapidité commerciale et prudence ; oublier la dimension économique.$mft$,
   5, 'facile', ARRAY['taxi-vtc','module-4','question-redigee'], 'TAXI-M4-QR-02', false,
   $mft$Un style de conduite, quatre bénéfices démontrés.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Scénario du dernier verre : fin de mariage à 2 h, le client insiste chaleureusement pour trinquer, il vous reste deux courses de raccompagnement. Rédigez votre refus dialogué et justifiez-le (seuils applicables, image professionnelle, conséquences).$mft$,
   $mft$Réponse modèle (esprit attendu). Dialogue : remercier chaleureusement (« merci, ça me touche, la soirée était magnifique »), refuser fermement et simplement (« mais je ne bois jamais en service : je reprends le volant, et vos invités doivent rentrer aussi bien qu'ils sont venus »), proposer une alternative conviviale (trinquer avec un soft, accepter le geste sans l'alcool). Ne jamais entrer en négociation (« juste une coupe ») ni invoquer une fausse excuse : la vérité professionnelle est le meilleur argument. Justification : au volant, le professionnel reste soumis aux seuils de droit commun, contravention dès 0,5 g/L de sang et délit à partir de 0,8 g/L ; il reste deux courses, donc de longues minutes de conduite avec des passagers dont la sécurité vous incombe ; aucune « décharge » du client n'a de valeur. Conséquences d'une acceptation : contrôle positif (sanctions, incidence sur la carte professionnelle et l'assurance), accident aggravé par l'alcoolémie, et destruction de l'image : le client qui insiste ce soir serait le premier à témoigner demain. Le refus élégant, lui, renforce la confiance : c'est un argument commercial, pas une froideur.$mft$,
   $mft$Barème /5 : refus clair, poli et sans négociation (1,5 pt) ; alternative conviviale proposée (0,5 pt) ; seuils exacts replacés dans le scénario (1 pt) ; conséquences professionnelles développées (carte, assurance, image) (1,5 pt) ; vérité professionnelle assumée sans fausse excuse (0,5 pt). Erreurs fréquentes : accepter « une seule » ; invoquer une décharge du client ; refus brutal qui abîme la relation.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-4','question-redigee'], 'TAXI-M4-QR-03', false,
   $mft$Le refus du dernier verre : dialogue, seuils, conséquences.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Procédure : décrivez pas à pas une dépose sûre et licite d'un client devant une gare très fréquentée (repérage, annonce, signalisation, arrêt, ouverture des portières, bagages, redémarrage), en identifiant le risque évité à chaque étape.$mft$,
   $mft$Réponse modèle. 1) Repérage en amont : identifier la zone de dépose officielle de la gare ou, à défaut, un arrêt licite et dégagé (jamais sur passage piéton, arrêt de bus, piste cyclable ou en double file) : évite le stationnement gênant et les piétons masqués. 2) Annonce au client : « je vous dépose vingt mètres plus loin, c'est plus sûr » : évite l'ouverture de portière impulsive au mauvais endroit. 3) Signalisation : clignotant tôt, ralentissement progressif : évite la collision arrière et prévient cyclistes et bus. 4) Arrêt le long du trottoir, roues droites : le véhicule ne déborde pas dans le flux. 5) Contrôle des rétros et des angles morts AVANT de déverrouiller ou d'autoriser l'ouverture : évite l'emportiérage d'un vélo ou d'une trottinette ; descente côté trottoir, poignée hollandaise si le côté chaussée est inévitable. 6) Bagages sortis côté trottoir, sans traverser le flux ; paiement et au revoir réglés avant ou pendant l'arrêt pour en réduire la durée. 7) Redémarrage : contrôle, clignotant, insertion progressive. Chaque étape produit la même chose : de la visibilité et de la marge, pour vous, pour le client et pour les usagers vulnérables.$mft$,
   $mft$Barème /5 : choix d'un point d'arrêt licite argumenté (1 pt) ; annonce et brief du client (0,5 pt) ; signalisation et arrêt corrects (1 pt) ; contrôle avant ouverture + gestion portières et bagages côté trottoir (1,5 pt) ; redémarrage sécurisé et risques évités nommés à chaque étape (1 pt). Erreurs fréquentes : déposer « juste là » en double file ; oublier le contrôle avant l'ouverture des portières.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-4','question-redigee'], 'TAXI-M4-QR-04', false,
   $mft$La dépose parfaite, étape par étape, risques nommés.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Cas pratique : une cliente réserve pour elle, son fils de quatre ans et sa mère qui se déplace en fauteuil roulant pliable. Préparez la course : équipements, installation de chacun, points de vigilance à bord et à la dépose.$mft$,
   $mft$Réponse modèle. À la réservation : confirmer les besoins précis (âge et taille de l'enfant pour le dispositif, fauteuil pliable ou non, temps supplémentaire à prévoir) et préparer le véhicule : dispositif enfant installé à l'arrière avant la prise en charge, coffre vidé pour le fauteuil. À la prise en charge : se garer en lieu sûr le long du trottoir ; installer d'abord la grand-mère : proposer l'aide sans l'imposer, respecter son rythme, sécuriser le transfert vers le siège, puis plier et arrimer le fauteuil dans le coffre ; installer l'enfant dans son siège ou rehausseur à l'arrière ; vérifier soi-même les ceintures de tous, l'enfant étant mineur sous votre responsabilité. En route : conduite particulièrement souple (passagère fragile, enfant sensible au mal des transports), climatisation modérée, annonces simples (« nous arrivons dans dix minutes »). À la dépose : arrêt côté trottoir en zone dégagée, fauteuil déplié et positionné en premier, aide au transfert, enfant qui descend côté trottoir en dernier et sous surveillance, effets personnels vérifiés. Ne repartir que lorsque tout le monde est en sécurité sur le trottoir. Fil conducteur : anticipation dès la réservation, dignité de la personne, responsabilité sur le mineur.$mft$,
   $mft$Barème /5 : préparation à la réservation (besoins, dispositif, coffre) (1 pt) ; installation de la PMR : aide proposée sans être imposée, rythme respecté, fauteuil arrimé (1,5 pt) ; enfant : dispositif adapté et ceinture vérifiée par le conducteur (1,5 pt) ; dépose sécurisée dans le bon ordre (1 pt). Erreurs fréquentes : enfant sur les genoux ; fauteuil non arrimé ; précipiter la personne âgée.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-4','question-redigee'], 'TAXI-M4-QR-05', false,
   $mft$Course multi-passagers : enfant, PMR, méthode complète.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un véhicule vous refuse la priorité et percute votre aile avant ; votre cliente, ceinturée à l'arrière, se plaint du cou. Déroulez votre conduite complète : sécurisation, alerte, constat, prise en charge de la cliente, déclarations et suites.$mft$,
   $mft$Réponse modèle. Protéger : feux de détresse immédiats, véhicule laissé en place ou dégagé selon la situation, gilet haute visibilité avant de sortir, personne debout sur la chaussée. La cliente se plaint du cou : elle ne sort pas et ne bouge pas (risque cervical), sauf danger immédiat ; la rassurer par la parole. Alerter : appel au 112 avec localisation exacte, nature de l'accident, état de la victime (douleur cervicale, consciente) ; suivre les consignes de l'opérateur. Secourir : rester auprès d'elle, surveiller son état, ne rien lui donner. Constat : une fois la situation sanitaire prise en main, constat amiable factuel avec l'autre conducteur : positions, croquis, dégâts, photos ; aucune reconnaissance de tort, aucun arrangement sans papiers, d'autant qu'une passagère est blessée. Déclarations : centrale ou exploitation immédiatement, assureur dans les délais du contrat, en mentionnant la passagère blessée transportée (essentiel pour les garanties). Prise en charge : prévenir un proche si elle le souhaite, l'accompagner dans la mesure du possible, organiser la suite pour d'éventuels autres passagers, reprendre des nouvelles ensuite. Clore par un rapport écrit factuel : heures, faits, témoins.$mft$,
   $mft$Barème /5 : protection correcte (feux de détresse, gilet, victime non déplacée) (1,5 pt) ; alerte au 112 complète (0,5 pt) ; constat factuel sans reconnaissance ni arrangement (1,5 pt) ; déclarations avec mention de la passagère blessée (0,5 pt) ; prise en charge humaine et suivi (1 pt). Erreurs fréquentes : faire sortir la blessée ; accepter l'arrangement ; oublier de signaler la cliente transportée à l'assureur.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-4','question-redigee'], 'TAXI-M4-QR-06', false,
   $mft$Accident avec blessée à bord : la séquence intégrale.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Plan d'action : chauffeur connecté. Vous constatez que le téléphone (notifications, GPS, messages clients) capte trop votre attention en conduite. Construisez un plan complet (matériel, réglages, routines, communication client) pour supprimer la distraction sans dégrader votre réactivité commerciale.$mft$,
   $mft$Réponse modèle. Diagnostic : mesurer honnêtement le problème (nombre d'interactions écran par heure de conduite, moments critiques : notifications de course, messages clients, ajustements GPS). Matériel : support fixe homologué dans le champ de vision sans masquer la route, chargeur branché en permanence (un téléphone en batterie faible pousse à la manipulation), audio diffusé par les haut-parleurs du véhicule : l'oreillette en conduite est interdite. Réglages : mode « ne pas déranger » en conduite avec exceptions limitées, notifications non essentielles coupées, guidage vocal systématique, itinéraire et préférences saisis à l'arrêt avant de démarrer. Routines : la règle unique « tout se règle à l'arrêt » : acceptation des courses, réponse aux messages et modification d'itinéraire uniquement véhicule arrêté en lieu licite ; entre deux courses, une minute dédiée au téléphone, puis écran ignoré ; jamais de manipulation au feu rouge. Communication client : message automatique (« je conduis, je vous réponds dès l'arrêt »), centrale informée de ce fonctionnement. Suivi : réévaluer après une semaine et ajuster. Arbitrage commercial : une réponse différée de deux ou trois minutes ne perd pas un client ; un accident, une sanction ou une mauvaise note liée à la distraction coûtent infiniment plus.$mft$,
   $mft$Barème /5 : diagnostic mesurable (0,5 pt) ; volet matériel complet (support fixe, chargeur, audio sans oreillette) (1,25 pt) ; réglages logiciels pertinents (1 pt) ; routines « tout à l'arrêt », y compris au feu rouge (1,25 pt) ; communication client/centrale et arbitrage commercial assumé (1 pt). Erreurs fréquentes : plan purement matériel sans routine ; tolérer la manipulation au feu rouge ; proposer l'oreillette.$mft$,
   5, 'difficile', ARRAY['taxi-vtc','module-4','question-redigee'], 'TAXI-M4-QR-07', false,
   $mft$Plan anti-distraction complet du chauffeur connecté.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Analyse : votre société étend son activité du centre-ville (zones 30, zones de rencontre) vers les liaisons aéroport (voies rapides en flux dense). Comparez les risques dominants des deux environnements et les adaptations de conduite qu'ils imposent au conducteur T3P.$mft$,
   $mft$Réponse modèle. Centre-ville apaisé (zones 30, zones de rencontre) : le danger dominant est l'usager vulnérable proche : piétons prioritaires pouvant circuler sur la chaussée en zone de rencontre, cyclistes et trottinettes entre les files, surgissements derrière les masques (bus, livraisons), risque d'emportiérage à chaque dépose. Adaptations : allure très réduite (au pas en zone de rencontre), regard mobile et contrôles de tête, méfiance systématique devant tout masque de visibilité, gestes de portière rigoureux (poignée hollandaise, descente côté trottoir), choix d'arrêts licites malgré la pression du client. Liaisons aéroport en flux dense : le danger change de nature : vitesses plus élevées, collision arrière et carambolage dans les vagues de ralentissement, insertions et changements de file, monotonie qui favorise la fatigue (départs très matinaux, retours de nuit), tentation du GPS en roulant. Adaptations : intervalle de sécurité constant, anticipation des freinages (lever le pied tôt), gestion coopérative des insertions, itinéraire préparé à l'arrêt, vigilance fatigue renforcée (pauses, autoévaluation avant les courses matinales). Constantes : conduite souple, client à bord, tout réglage à l'arrêt. Ce qui change : en ville, protéger les autres ; sur voie rapide, se protéger du flux et de soi-même (fatigue, distraction).$mft$,
   $mft$Barème /5 : risques urbains correctement hiérarchisés (vulnérables, masques, portières) (1,5 pt) ; risques de voie rapide identifiés (collision arrière, monotonie, fatigue) (1,5 pt) ; adaptations concrètes pour chaque environnement (1,5 pt) ; constantes et synthèse comparative (0,5 pt). Erreurs fréquentes : réduire la comparaison à la seule vitesse ; oublier la fatigue des liaisons matinales.$mft$,
   5, 'difficile', ARRAY['taxi-vtc','module-4','question-redigee'], 'TAXI-M4-QR-08', false,
   $mft$Deux environnements, deux familles de risques comparées.$mft$);

  RAISE NOTICE 'Module 4 Taxi/VTC créé : module %, 3 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $taxim4$;
