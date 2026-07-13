-- =====================================================================
-- FIMO / FCO MARCHANDISES : THÈME 3 : SANTÉ, SÉCURITÉ ROUTIÈRE ET
-- ENVIRONNEMENTALE : v1 (juillet 2026) : LOT FIMO-4
-- Angle conducteur : vigilance et hygiène de vie, gestes et postures,
-- réaction à l'accident, sûreté du fret et passagers clandestins.
-- ⚠ STATUT : active = false (« à valider »). Idempotent.
-- =====================================================================

DO $fimot3$
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

  DELETE FROM public.question_bank WHERE source_ref LIKE 'FIMO-T3-%';
  DELETE FROM public.modules WHERE slug = 'fimo-t3-sante-securite';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Thème 3 : Santé, sécurité routière et environnementale',
    'fimo-t3-sante-securite', v_bloc,
    'Rester apte et vigilant (fatigue, substances, hygiène de vie), préserver son corps (gestes, postures, chutes), réagir correctement à l''accident, et protéger le fret comme le véhicule (vols, passagers clandestins).',
    'intermediaire', 420, 40) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 40, true);

  -- ─── Leçon 1 : Vigilance, hygiène de vie et substances ─────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'vigilance-hygiene-de-vie',
    'Vigilance au volant : fatigue, substances, hygiène de vie',
    $mft$> 🎯 **Objectifs**
> - Reconnaître VOS signes de fatigue et réagir avant l'endormissement.
> - Connaître les règles alcool, stupéfiants et médicaments appliquées à votre journée.
> - Construire une hygiène de vie compatible avec le métier.

## La fatigue : l'ennemi silencieux

L'endormissement au volant ne prévient pas : il s'annonce. **Vos signaux** : paupières lourdes, bâillements répétés, nuque raide, trajectoire qui flotte, kilomètres « oubliés », micro-absences. À partir de là, il ne reste que quelques minutes utiles.

> 📌 **À retenir**
> Le seul remède efficace : **s'arrêter et dormir 15 à 20 minutes** (la sieste flash), café éventuel juste avant. Ouvrir la fenêtre, monter le son ou « se concentrer » ne fonctionnent pas : la dette de sommeil ne se négocie pas.

Prévention : dormir suffisamment AVANT la prise de service (les repos réglementaires sont un minimum, pas un objectif), attention aux heures critiques (2 h-5 h, début d'après-midi), repas légers le midi, hydratation régulière.

## Alcool : votre seuil, vos règles

En dessous de 0,5 g/L la loi tolère : votre métier, lui, tolère mal : deux verres suffisent à approcher le seuil, les réflexes se dégradent bien avant. La veille au soir compte : l'alcool s'élimine lentement (environ **0,10 à 0,15 g/L par heure**) : une soirée arrosée se retrouve dans le sang à la prise de service de 6 h. Beaucoup d'entreprises fixent le **zéro alcool en service** au règlement intérieur : c'est votre référence.

## Stupéfiants et médicaments

- **Stupéfiants** : tolérance zéro, dépistage salivaire possible, délit quel que soit le dosage : et des traces détectables plusieurs jours après consommation.
- **Médicaments** : regardez le pictogramme sur la boîte : **niveau 2** (triangle orange) : avis d'un professionnel de santé avant de conduire ; **niveau 3** (triangle rouge) : conduite interdite. Somnifères, anxiolytiques, certains antihistaminiques et antidouleurs sont concernés : signalez votre métier à chaque prescription.

## L'hygiène de vie du routier

| Levier | En pratique |
| --- | --- |
| Sommeil | Régularité, cabine ventilée et obscure, rituel de coucher |
| Alimentation | Repas légers et réguliers, limiter les sucres rapides (coup de barre), eau à portée |
| Activité | Marcher aux pauses, étirements quotidiens : le dos et les jambes remercient |
| Écrans | Pas de téléphone tenu en main (135 € + 3 points) : messages à l'arrêt uniquement |

## ✅ Synthèse

- Fatigue : reconnaître SES signaux, **sieste flash 15-20 min** : seul remède réel.
- Alcool : élimination lente (~0,10-0,15 g/L/h) : la veille compte ; stupéfiants : **tolérance zéro** ; médicaments : **pictogrammes 2 et 3**.
- Hygiène de vie : sommeil régulier, repas légers, bouger aux pauses, téléphone à l'arrêt.$mft$,
    $mft$Signes de fatigue et sieste flash, élimination lente de l'alcool (la veille compte), tolérance zéro stupéfiants, pictogrammes médicaments 2/3, et l'hygiène de vie du conducteur.$mft$,
    1, 40) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : Votre corps est votre outil ─────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'gestes-postures-risques-physiques',
    'Votre corps est votre outil : gestes, postures, chutes',
    $mft$> 🎯 **Objectifs**
> - Éviter les deux accidents types du conducteur : la chute et le tour de reins.
> - Appliquer la technique de levage et les bons réglages de poste.
> - Utiliser hayon et transpalette sans vous mettre en danger.

## Les deux accidents qui remplissent les statistiques

Dans le transport, l'accident du travail typique n'est pas routier : c'est la **chute** (descente de cabine, hayon, remorque) et la **lombalgie** de manutention. Les deux se préviennent par des gestes simples répétés à chaque fois.

## La descente de cabine : trois points d'appui

> ❌ **Piège à éviter**
> Sauter de la cabine face à la route, téléphone en main : la cheville et le genou encaissent plusieurs fois le poids du corps, sol glissant en prime. La règle : **descendre face à la cabine**, comme à une échelle, **trois points d'appui** en permanence (deux mains + un pied, ou deux pieds + une main), marches et poignées propres.

Même logique pour la remorque et le plateau : jamais de saut, jamais de dos à l'échelle.

## Lever sans se casser

:::flow
1. Évaluer | Poids, prises, trajet dégagé : à deux ou à l'aide si trop lourd
2. Se placer | Pieds écartés de part et d'autre, charge PRÈS du corps
3. Lever | Dos droit, jambes fléchies : ce sont les cuisses qui poussent
4. Porter | Charge collée au corps, pivoter avec les PIEDS, jamais le buste
:::

Poste de conduite : siège réglé (cuisses soutenues, dos en appui), volant et rétros ajustés à CHAQUE prise de véhicule : huit heures dans un siège mal réglé fabriquent la lombalgie aussi sûrement qu'un mauvais levage.

## Hayon et transpalette : les règles d'or

- **Hayon** : personne sur la plateforme pendant la manœuvre autre que l'opérateur, charge stabilisée au centre, transpalette roues bloquées, ne jamais reculer au bord du vide, plateforme rangée verrouillée avant de rouler ;
- **Transpalette** : tirer sur le plat en marchant devant, pousser dans les pentes légères, jamais entre le transpalette et un obstacle (pieds !), chaussures de sécurité systématiques ;
- **EPI du conducteur** : chaussures de sécurité, gants adaptés, gilet haute visibilité dès que vous quittez la cabine sur zone de circulation, casquette anti-heurt si le site l'exige.

## Aptitude et suivi médical

Votre aptitude est suivie (visite du permis lourd, suivi en entreprise). Douleurs récurrentes, troubles du sommeil, vue qui baisse : en parler TÔT (médecin du travail) : des aménagements existent ; le déni finit en inaptitude.

## ✅ Synthèse

- **Trois points d'appui, face à la cabine** : la chute est l'accident n° 1 : elle se prévient à chaque descente.
- Levage : **dos droit, jambes fléchies, charge près du corps, pivoter des pieds**.
- Hayon/transpalette : positions sûres, EPI systématiques ; santé : alerter tôt, pas au stade de l'inaptitude.$mft$,
    $mft$Les deux accidents types (chute, lombalgie), la descente trois points d'appui, la technique de levage, les règles hayon/transpalette, les EPI et le suivi d'aptitude.$mft$,
    2, 40) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : L'accident : éviter, réagir ─────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'accident-eviter-reagir',
    'L''accident : l''éviter, y réagir',
    $mft$> 🎯 **Objectifs**
> - Neutraliser les situations à haut risque du poids lourd (angles morts, interdistances).
> - Dérouler les bons gestes dans les minutes qui suivent un accident.
> - Remplir un constat qui protège, et déclarer dans les délais.

## Les situations à haut risque du PL

- **Angles morts en ville** : le cycliste remonte à droite au feu, le piéton traverse devant le pare-chocs : contrôles croisés rétros + fenêtre AVANT tout démarrage et tout tournant à droite, vitesse au pas dans les zones partagées ; vos autocollants signalent, vos yeux vérifient.
- **Interdistances** : à 90 km/h, un 44 t lancé ne s'arrête pas comme une berline : la seconde de distraction se paie en dizaines de mètres : 50 m minimum entre PL hors agglo, davantage sous la pluie.
- **Manœuvres et marche arrière** : la moitié des tôles froissées : reconnaissance à pied si nécessaire, guide au sol quand c'est possible, klaxon de recul respecté.
- **Météo** : pluie (aquaplanage, distances doublées), brouillard (feux adaptés, allure), vent latéral (semi vide = voile de bateau), neige/verglas (équipements, ou l'arrêt).

## Les premières minutes d'un accident

:::timeline
1. **Se protéger** : Feux de détresse, moteur coupé, gilet AVANT de descendre, ne pas s'exposer au trafic.
2. **Protéger la zone** : Triangle à distance utile (sauf exposition dangereuse sur autoroute : priorité à la mise à l'abri derrière la glissière), passagers et témoins écartés de la chaussée.
3. **Alerter** : 112 (ou borne d'urgence qui localise) : lieu précis, blessés, nombre de véhicules, risques particuliers (fuite, marchandise).
4. **Secourir** : Sans déplacer les blessés (sauf danger immédiat type incendie), couvrir, parler, rester.
:::

## Le constat qui protège

Un croquis clair (positions, sens, signalisation), les circonstances cochées SANS en rajouter, les observations factuelles (« le véhicule B a déboîté sans clignotant »), témoins notés (nom, téléphone), photos sous plusieurs angles, signatures. En désaccord : chacun ses observations, ne signez rien qui déforme les faits. Pas d'aveu de responsabilité sur place (« je suis désolé, je ne vous ai pas vu ») : les faits, l'assureur qualifiera.

> 📌 **À retenir**
> Après l'accident : exploitation prévenue immédiatement ; déclaration assureur dans les délais du contrat ; si un collègue ou vous êtes blessé : information de l'employeur sous **24 h**, qui déclare l'accident du travail sous **48 h**. Et quel que soit le stress : le tachygraphe continue d'enregistrer VOTRE journée : posez-la proprement (repos ou travail selon la suite).

## Après l'accident : l'analyse

Un accident, même bénin, s'analyse à froid : qu'est-ce qui l'a rendu possible (vitesse, angle mort, fatigue, pression horaire) ? L'entreprise le fait avec vous : ce n'est pas chercher un coupable, c'est empêcher le suivant. Les conducteurs expérimentés sont ceux qui ont appris de leurs presqu'accidents.

## ✅ Synthèse

- Ville = **angles morts** (contrôles croisés systématiques) ; route = **distances** ; manœuvres = reconnaissance.
- Accident : **se protéger, protéger, alerter (112), secourir** : dans cet ordre.
- Constat : croquis + faits + photos + témoins ; **pas d'aveu** ; exploitation et assureur informés vite, AT déclaré (24 h / 48 h).$mft$,
    $mft$Situations à risque du PL (angles morts, interdistances, manœuvres, météo), la séquence des premières minutes, le constat qui protège sans aveu de responsabilité, et les délais AT 24/48 h.$mft$,
    3, 40) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : Sûreté : fret, véhicule, clandestins ────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'surete-fret-vehicule-clandestins',
    'Sûreté : protéger le fret, le véhicule et éviter les passagers clandestins',
    $mft$> 🎯 **Objectifs**
> - Réduire le risque de vol de fret et de véhicule au quotidien.
> - Appliquer la routine anti-intrusion avant les passages sensibles.
> - Réagir correctement en cas de découverte ou de soupçon.

## Le vol de fret : un risque de tournée

Le fret se vole à l'arrêt : parkings de nuit, zones industrielles désertes, attentes prolongées. Vos réflexes :

- **Stationner malin** : parkings éclairés, fréquentés, sécurisés quand l'entreprise en donne l'accès ; remorque dos à un mur ou à un autre véhicule quand c'est possible ;
- **Verrouiller toujours** : cabine fermée même pour dix minutes, clés JAMAIS sur le contact ni « cachées », portes de caisse cadenassées, **scellés/plombs** posés et numéros notés sur la LV ;
- **Discrétion** : ne pas détailler chargement et itinéraire (CB, réseaux sociaux, inconnus « curieux » au parking) ; les vols ciblés commencent par du renseignement ;
- **Remise en main propre** : la marchandise se livre au destinataire prévu, pas au « collègue » pressé sur un parking : les détournements par faux réceptionnaires existent.

## Les passagers clandestins

Sur les axes vers certains ports et plateformes, des personnes tentent de monter à bord des remorques. Au-delà du drame humain, le transporteur et le conducteur s'exposent à des **sanctions** (notamment à l'entrée de certains pays) et à l'immobilisation.

:::flow
1. Avant le départ | Vérifier l'intégrité : bâches, toit, portes, scellés numérotés
2. À chaque arrêt en zone sensible | Tour complet : lacérations de bâche, sangles déplacées, bruits
3. Avant l'embarquement / la frontière | Contrôle documenté : check-list datée et signée, scellé vérifié
4. En cas de doute | NE PAS ouvrir seul : se mettre en sécurité et appeler les autorités (17/112) et l'exploitation
:::

> ⚠️ **Attention**
> Découvrir des personnes dans la remorque n'est pas une situation à gérer seul : ni confrontation, ni transport « jusqu'au prochain parking » : sécurité d'abord, autorités ensuite, exploitation informée. Votre check-list signée démontre votre diligence : c'est elle qui vous protège des sanctions.

## Le véhicule aussi

Carte carburant et code jamais ensemble, cabine vidée des objets visibles (téléphone, sacoche), antivol mécanique le cas échéant, alerte immédiate en cas de vol (géolocalisation d'entreprise). Un camion volé, c'est un fret perdu ET un outil de travail en moins.

## ✅ Synthèse

- Fret : **parking choisi, tout verrouillé, scellés notés, discrétion** sur le chargement.
- Clandestins : **vérifications documentées** aux étapes clés ; en cas de doute : sécurité, **autorités**, jamais seul.
- Véhicule : clés, carte carburant, objets visibles : les basiques font 90 % de la sûreté.$mft$,
    $mft$Prévention du vol de fret (stationnement, verrouillage, scellés, discrétion), routine anti-intrusion documentée contre les passagers clandestins, réaction en cas de découverte, sûreté du véhicule.$mft$,
    4, 35) RETURNING id INTO v_l4;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : Santé et sécurité',
    'Vérifiez le thème 3 : vigilance, gestes et postures, réaction à l''accident, sûreté.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Paupières lourdes, trajectoire qui flotte, kilomètres « oubliés » : quel est le seul remède efficace ?$mft$,
    $mft$[
      {"id":"a","label":"S'arrêter et dormir 15 à 20 minutes","is_correct":true},
      {"id":"b","label":"Ouvrir la fenêtre et monter la radio","is_correct":false},
      {"id":"c","label":"Boire un café en continuant de rouler","is_correct":false},
      {"id":"d","label":"Se concentrer davantage jusqu'à l'arrivée","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['fimo-fco','theme-3','qcm-v1'], 'FIMO-T3-QCM-01', false,
    $mft$Ces signes annoncent l'endormissement imminent : seule la sieste flash restaure la vigilance ; les autres « trucs » ne font que masquer quelques minutes.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Comment descend-on correctement d'une cabine de poids lourd ?$mft$,
    $mft$[
      {"id":"a","label":"Face à la cabine, trois points d'appui en permanence","is_correct":true},
      {"id":"b","label":"Face à la route, pour surveiller le trafic","is_correct":false},
      {"id":"c","label":"En sautant, pour gagner du temps","is_correct":false},
      {"id":"d","label":"Dos à la cabine, une main sur la poignée","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['fimo-fco','theme-3','qcm-v1'], 'FIMO-T3-QCM-02', false,
    $mft$Comme à une échelle : face à la cabine, deux mains + un pied (ou l'inverse) en appui. La chute de cabine est l'accident du travail le plus banal du métier.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Quel est l'ordre correct des actions dans les premières minutes d'un accident corporel ?$mft$,
    $mft$[
      {"id":"a","label":"Se protéger et protéger la zone, alerter le 112, secourir","is_correct":true},
      {"id":"b","label":"Secourir, alerter, protéger","is_correct":false},
      {"id":"c","label":"Alerter, déplacer les blessés, protéger","is_correct":false},
      {"id":"d","label":"Remplir le constat, puis alerter","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['fimo-fco','theme-3','qcm-v1'], 'FIMO-T3-QCM-03', false,
    $mft$Protéger (soi, la zone), alerter (112, localisation précise), secourir (sans déplacer sauf danger immédiat) : un secouriste percuté n'aide plus personne.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Avant d'embarquer vers une zone sensible, vous suspectez une intrusion dans votre remorque (bâche lacérée). Que faites-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Vous ne l'ouvrez pas seul : mise en sécurité, appel aux autorités et à l'exploitation","is_correct":true},
      {"id":"b","label":"Vous ouvrez pour vérifier vous-même","is_correct":false},
      {"id":"c","label":"Vous roulez jusqu'au prochain parking pour contrôler","is_correct":false},
      {"id":"d","label":"Vous recousez la bâche et continuez","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['fimo-fco','theme-3','qcm-v1'], 'FIMO-T3-QCM-04', false,
    $mft$Ni confrontation ni transport : sécurité d'abord, autorités (17/112) ensuite, exploitation informée. La check-list signée documente votre diligence.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Soirée arrosée jusqu'à 23 h (environ 1 g/L au coucher), prise de service à 6 h. Êtes-vous en règle pour conduire ?$mft$,
    $mft$[
      {"id":"a","label":"Probablement pas : à environ 0,10-0,15 g/L éliminé par heure, le taux peut rester au-dessus du seuil","is_correct":true},
      {"id":"b","label":"Oui : une nuit de sommeil élimine tout","is_correct":false},
      {"id":"c","label":"Oui, avec un café serré au réveil","is_correct":false},
      {"id":"d","label":"Oui si l'on se sent bien","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','theme-3','qcm-v1'], 'FIMO-T3-QCM-05', false,
    $mft$7 heures d'élimination à ~0,10-0,15 g/L/h ne suffisent pas toujours à redescendre sous 0,5 g/L depuis 1 g/L : ni le café ni la sensation ne changent la chimie. La veille au soir fait partie du métier.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Votre médecin vous prescrit un médicament portant un triangle rouge (niveau 3). Que faites-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Vous ne conduisez pas sous ce traitement et vous en parlez au prescripteur (métier signalé) et à l'employeur si besoin","is_correct":true},
      {"id":"b","label":"Vous conduisez en redoublant de prudence","is_correct":false},
      {"id":"c","label":"Vous prenez le traitement uniquement le soir et conduisez le jour","is_correct":false},
      {"id":"d","label":"Le pictogramme ne concerne que les voitures","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','theme-3','qcm-v1'], 'FIMO-T3-QCM-06', false,
    $mft$Niveau 3 = conduite interdite sous traitement (niveau 2 = avis médical). Signaler son métier au prescripteur permet souvent une alternative compatible.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Quelle est la bonne technique pour soulever une caisse lourde au sol ?$mft$,
    $mft$[
      {"id":"a","label":"Dos droit, jambes fléchies, charge près du corps, pivoter avec les pieds","is_correct":true},
      {"id":"b","label":"Jambes tendues, dos arrondi pour attraper plus vite","is_correct":false},
      {"id":"c","label":"Charge à bout de bras pour mieux voir où l'on marche","is_correct":false},
      {"id":"d","label":"Pivoter le buste en gardant les pieds fixes","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','theme-3','qcm-v1'], 'FIMO-T3-QCM-07', false,
    $mft$Ce sont les cuisses qui poussent, pas le dos qui tire ; la rotation du buste charge les lombaires : on pivote des pieds, charge collée au corps.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Feu vert, vous tournez à droite en ville. Quel est LE réflexe avant d'engager le mouvement ?$mft$,
    $mft$[
      {"id":"a","label":"Contrôles croisés rétroviseurs + vitre : un cycliste peut remonter dans l'angle mort","is_correct":true},
      {"id":"b","label":"Accélérer pour dégager vite l'intersection","is_correct":false},
      {"id":"c","label":"Klaxonner systématiquement","is_correct":false},
      {"id":"d","label":"Se fier aux autocollants angles morts","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','theme-3','qcm-v1'], 'FIMO-T3-QCM-08', false,
    $mft$Le tourne-à-droite PL/cycliste est l'accident urbain grave type : les autocollants signalent, seuls VOS contrôles croisés vérifient : rétros, rétro d'accostage, vitre.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Sur le constat amiable, après un accrochage dont vous vous estimez non responsable, vous devez :$mft$,
    $mft$[
      {"id":"a","label":"Décrire les faits (croquis, observations, témoins) sans reconnaître de responsabilité","is_correct":true},
      {"id":"b","label":"Écrire « je suis désolé, je ne vous avais pas vu » par courtoisie","is_correct":false},
      {"id":"c","label":"Refuser de remplir le constat","is_correct":false},
      {"id":"d","label":"Signer le constat rempli par l'autre conducteur sans le lire","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','theme-3','qcm-v1'], 'FIMO-T3-QCM-09', false,
    $mft$Les faits, le croquis, les témoins, vos observations : l'assureur qualifie les responsabilités. Un aveu de politesse sur place se retourne contre vous.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Pause de 30 minutes sur une aire. Concernant la cabine et le fret, le bon réflexe est :$mft$,
    $mft$[
      {"id":"a","label":"Cabine verrouillée, clés sur vous, portes de caisse cadenassées, objets de valeur hors de vue","is_correct":true},
      {"id":"b","label":"Clés sur le contact pour repartir vite","is_correct":false},
      {"id":"c","label":"Cabine ouverte : une demi-heure ne craint rien","is_correct":false},
      {"id":"d","label":"Confier la surveillance au conducteur d'à côté","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['fimo-fco','theme-3','qcm-v1'], 'FIMO-T3-QCM-10', false,
    $mft$Les vols opportunistes se jouent en minutes : verrouiller TOUJOURS, même bref. Les basiques (clés, cadenas, discrétion) font l'essentiel de la sûreté.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Vous vous blessez à la cheville en descendant du hayon chez un client. Côté déclarations, que doit-il se passer ?$mft$,
    $mft$[
      {"id":"a","label":"Vous informez votre employeur sous 24 h ; il déclare l'accident du travail à la CPAM sous 48 h","is_correct":true},
      {"id":"b","label":"Rien si la douleur passe dans la semaine","is_correct":false},
      {"id":"c","label":"C'est au client de déclarer : l'accident a eu lieu chez lui","is_correct":false},
      {"id":"d","label":"Vous déclarez vous-même à la CPAM sous 8 jours","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['fimo-fco','theme-3','qcm-v1'], 'FIMO-T3-QCM-11', false,
    $mft$Salarié → employeur sous 24 h ; employeur → CPAM sous 48 h. Le lieu (site client) ne déplace pas l'obligation : c'est votre employeur qui déclare. Ne pas déclarer prive de la protection AT.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Que faut-il noter sur la lettre de voiture lorsque vous posez un scellé sur les portes de la remorque ?$mft$,
    $mft$[
      {"id":"a","label":"Le numéro du scellé","is_correct":true},
      {"id":"b","label":"Rien : le scellé se suffit à lui-même","is_correct":false},
      {"id":"c","label":"La couleur du scellé","is_correct":false},
      {"id":"d","label":"L'heure de pose uniquement","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['fimo-fco','theme-3','qcm-v1'], 'FIMO-T3-QCM-12', false,
    $mft$Le numéro tracé sur la LV permet de prouver l'intégrité à l'arrivée (même numéro, scellé intact) : sans trace écrite, le scellé perd sa valeur probatoire.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Quelle est la durée idéale d'une sieste de récupération face aux signes de fatigue ?$mft$,
   $mft$15 à 20 minutes (la « sieste flash »).$mft$,
   2, 'facile', ARRAY['fimo-fco','theme-3','question-courte'], 'FIMO-T3-QC-01', false,
   $mft$Au-delà, l'inertie du sommeil profond dégrade le réveil.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Énoncez la règle des « trois points d'appui ».$mft$,
   $mft$Garder en permanence trois appuis (deux mains et un pied, ou deux pieds et une main) en montant ou descendant de la cabine, face à celle-ci.$mft$,
   2, 'facile', ARRAY['fimo-fco','theme-3','question-courte'], 'FIMO-T3-QC-02', false,
   $mft$Et jamais de saut.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Quel numéro appelez-vous en cas d'accident corporel, et quelle information donnez-vous en premier ?$mft$,
   $mft$Le 112 (ou la borne d'urgence) ; la localisation précise en premier (axe, sens, point kilométrique).$mft$,
   2, 'facile', ARRAY['fimo-fco','theme-3','question-courte'], 'FIMO-T3-QC-03', false,
   $mft$La borne localise automatiquement : un avantage sur autoroute.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Que signifient les pictogrammes de niveau 2 et de niveau 3 sur une boîte de médicaments ?$mft$,
   $mft$Niveau 2 (orange) : avis d'un professionnel de santé avant de conduire ; niveau 3 (rouge) : conduite interdite sous traitement.$mft$,
   2, 'moyen', ARRAY['fimo-fco','theme-3','question-courte'], 'FIMO-T3-QC-04', false,
   $mft$Les deux niveaux avec leur conséquence.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$À quelle vitesse approximative l'organisme élimine-t-il l'alcool ?$mft$,
   $mft$Environ 0,10 à 0,15 g/L de sang par heure.$mft$,
   2, 'moyen', ARRAY['fimo-fco','theme-3','question-courte'], 'FIMO-T3-QC-05', false,
   $mft$D'où l'importance de la veille au soir pour une prise de service matinale.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Citez trois EPI du conducteur lors des opérations hors cabine.$mft$,
   $mft$Chaussures de sécurité, gants adaptés, gilet haute visibilité (casquette anti-heurt selon le site).$mft$,
   2, 'moyen', ARRAY['fimo-fco','theme-3','question-courte'], 'FIMO-T3-QC-06', false,
   $mft$Trois EPI distincts attendus.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Citez quatre éléments qui donnent sa force probante à un constat amiable.$mft$,
   $mft$Un croquis clair, les circonstances cochées avec exactitude, les observations factuelles, les témoins identifiés (et des photos).$mft$,
   2, 'moyen', ARRAY['fimo-fco','theme-3','question-courte'], 'FIMO-T3-QC-07', false,
   $mft$Quatre éléments parmi croquis/cases/observations/témoins/photos/signatures.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$À quels moments effectuez-vous un contrôle anti-intrusion de la remorque en zone sensible ?$mft$,
   $mft$Avant le départ, à chaque arrêt en zone sensible, et avant l'embarquement ou le passage de frontière (contrôle documenté : check-list datée et signée).$mft$,
   2, 'moyen', ARRAY['fimo-fco','theme-3','question-courte'], 'FIMO-T3-QC-08', false,
   $mft$Les trois moments + la notion de trace écrite.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Pourquoi ne faut-il jamais écrire « je ne vous avais pas vu, désolé » sur un constat ?$mft$,
   $mft$Parce que c'est un aveu de responsabilité : le constat doit rapporter les faits, l'assureur qualifie les responsabilités.$mft$,
   2, 'difficile', ARRAY['fimo-fco','theme-3','question-courte'], 'FIMO-T3-QC-09', false,
   $mft$Faits oui, conclusions non.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$En cas de découverte de personnes dans votre remorque, citez les deux interdits et les deux gestes corrects.$mft$,
   $mft$Interdits : ouvrir/confronter seul, et reprendre la route avec les personnes à bord ; gestes : se mettre en sécurité et alerter les autorités (17/112) puis l'exploitation.$mft$,
   2, 'difficile', ARRAY['fimo-fco','theme-3','question-courte'], 'FIMO-T3-QC-10', false,
   $mft$Sécurité, autorités, exploitation : jamais seul.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Décrivez les signes annonciateurs de l'endormissement au volant, les fausses solutions couramment utilisées, et la seule stratégie efficace (avec les créneaux horaires les plus dangereux).$mft$,
   $mft$Réponse modèle. Signes : paupières lourdes, bâillements en série, nuque et épaules raides, picotements des yeux, trajectoire qui flotte (corrections de volant), kilomètres parcourus sans souvenir, micro-absences (tête qui tombe) : à ce stade, l'endormissement est une question de minutes. Fausses solutions : fenêtre ouverte, radio forte, se pincer, « tenir jusqu'à l'aire suivante » : elles masquent quelques instants sans restaurer la vigilance ; le café seul retarde sans annuler. Stratégie efficace : s'arrêter dès les premiers signes, sieste de 15 à 20 minutes (le café juste AVANT la sieste agit au réveil), puis quelques pas et de l'eau ; si la fatigue revient vite : la journée est en cause (dette de sommeil) : alerter l'exploitation plutôt que s'obstiner. Créneaux à risque : 2 h-5 h du matin (creux circadien majeur) et début d'après-midi (13 h-15 h, surtout après repas lourd) : y placer les pauses préventivement. Prévention de fond : dormir suffisamment avant service, repas légers, hydratation, dépistage des troubles du sommeil (apnées : fréquentes et traitables).$mft$,
   $mft$Barème /5 : au moins quatre signes (1,5 pt) ; fausses solutions démontées (1 pt) ; sieste flash + café avant + réévaluation (1,5 pt) ; créneaux 2-5 h et début d'après-midi (0,5 pt) ; prévention de fond (0,5 pt). Erreurs fréquentes : café pendant la conduite comme solution ; ignorer les créneaux circadiens.$mft$,
   5, 'facile', ARRAY['fimo-fco','theme-3','question-redigee'], 'FIMO-T3-QR-01', false,
   $mft$La fatigue de bout en bout : signes, mythes, stratégie.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Votre collègue vient de se tordre la cheville en sautant de sa cabine, téléphone en main. Au-delà de ce cas, présentez les trois familles de risques physiques du conducteur et les gestes de prévention associés.$mft$,
   $mft$Réponse modèle. 1) Les chutes (l'accident du cas) : descente de cabine, hayon, remorque, sols glissants : prévention : trois points d'appui face à la cabine, jamais de saut, jamais le téléphone en main pendant les montées/descentes, marches et poignées propres, chaussures de sécurité à semelles adhérentes, hayon utilisé selon les règles (charge centrée, personne au bord du vide). 2) Les manutentions et TMS : levages répétés, postures contraintes : prévention : technique de levage (dos droit, jambes fléchies, charge près du corps, pivoter des pieds), aides mécaniques (transpalette, diable) dès que possible, à deux pour les charges lourdes, échauffement et étirements, réglage du poste de conduite à chaque prise de véhicule. 3) Les heurts et écrasements : quais, engins, circulation sur sites : prévention : gilet haute visibilité, cheminements piétons respectés, ne jamais passer derrière un véhicule en manœuvre, transpalette tiré sur le plat (jamais entre soi et un obstacle), respect des consignes des protocoles de sécurité des sites. Fil rouge : ces accidents « bêtes » font l'essentiel des arrêts de travail du métier : la prévention tient dans des gestes de trente secondes répétés à chaque fois.$mft$,
   $mft$Barème /5 : trois familles correctement identifiées (1,5 pt) ; gestes de prévention concrets et exacts pour chacune (3 pts : 1 par famille) ; fil rouge répétition/gestes simples (0,5 pt). Erreurs fréquentes : tout centrer sur la route en oubliant chutes et manutention.$mft$,
   5, 'facile', ARRAY['fimo-fco','theme-3','question-redigee'], 'FIMO-T3-QR-02', false,
   $mft$Panorama des risques physiques avec leurs parades.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Scène urbaine : vous êtes à l'arrêt au feu, clignotant à droite. Un cycliste remonte la file par la droite, un piéton attend devant votre pare-chocs, hors de vue directe. Décrivez la géographie de vos angles morts, vos contrôles AVANT de démarrer, et votre séquence de virage.$mft$,
   $mft$Réponse modèle. Angles morts d'un PL : devant, sous le pare-brise (piéton proche du pare-chocs invisible) ; à droite, tout le long de la caisse (le cycliste qui remonte disparaît des rétros à hauteur de cabine) ; derrière, totalement sans caméra ; à gauche, plus réduit mais réel. Contrôles avant démarrage : rétro plan américain droit + rétro d'accostage (zone basse droite) + rétro frontal (zone pare-chocs) + regard direct par la vitre droite : le cycliste « disparu » est peut-être exactement le long de votre caisse ; laisser passer le piéton identifié. Séquence de virage à droite : vitesse au pas, serrer raisonnablement pour fermer la remontée SANS masquer la visibilité, re-contrôle rétro d'accostage PENDANT le virage (le cycliste peut s'engager en cours), être prêt à s'arrêter net. Règle générale : en ville, on ne démarre ni ne tourne jamais « parce que le feu est vert » mais parce que la zone est VÉRIFIÉE : les autocollants angles morts préviennent les autres, seuls vos contrôles vous préviennent vous.$mft$,
   $mft$Barème /5 : cartographie des angles morts (1,5 pt) ; contrôles complets avant démarrage, rétro d'accostage inclus (1,5 pt) ; séquence de virage avec re-contrôle pendant (1,5 pt) ; règle « vérifié, pas vert » (0,5 pt). Erreurs fréquentes : croire les rétros suffisants ; serrer à droite au point de tout masquer.$mft$,
   5, 'moyen', ARRAY['fimo-fco','theme-3','question-redigee'], 'FIMO-T3-QR-03', false,
   $mft$Le tourne-à-droite urbain décomposé : LA situation à risque mortel.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Accident matériel avec un VL sur un rond-point : le conducteur adverse, agressif, refuse le constat et menace d'appeler « ses connaissances ». Gérez la situation de A à Z.$mft$,
   $mft$Réponse modèle. Sécuriser : feux de détresse, dégager le giratoire si les véhicules roulent (photos AVANT de déplacer : positions, traces), gilet, passagers à l'abri. Désamorcer : rester calme, phrases neutres, ne pas répondre aux provocations : l'objectif est la preuve, pas la victoire verbale. Face au refus de constat : le constat n'est pas obligatoire s'il refuse : relever IMMÉDIATEMENT la plaque, marque et couleur du véhicule, identité si possible (sans confrontation), témoins (noms, téléphones), photos des dégâts des DEUX véhicules et de la scène ; remplir VOTRE partie du constat seul en mentionnant « l'autre conducteur refuse de remplir et de signer ». En cas de menaces : ne pas s'attarder : appeler le 17 (menaces = affaire de police), rester dans la cabine verrouillée si nécessaire. Ensuite : exploitation prévenue, déclaration à l'assureur dans les délais avec tout le dossier (photos, témoins, constat unilatéral, éventuel dépôt de plainte). Ce dossier unilatéral bien constitué protège presque autant qu'un constat signé : c'est la panique et l'absence de preuves qui coûtent.$mft$,
   $mft$Barème /5 : sécurisation avec photos avant déplacement (1 pt) ; désescalade et refus de la confrontation (1 pt) ; collecte de preuves complète malgré le refus + constat unilatéral annoté (2 pts) ; recours au 17 face aux menaces + suites assureur (1 pt). Erreurs fréquentes : s'accrocher au constat signé « à tout prix » ; répondre à l'agressivité.$mft$,
   5, 'moyen', ARRAY['fimo-fco','theme-3','question-redigee'], 'FIMO-T3-QR-04', false,
   $mft$Accident + conflit : préserver la preuve sans s'exposer.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Vous effectuez chaque semaine une liaison vers un port sensible aux intrusions. Construisez votre routine de sûreté complète : préparation, arrêts, contrôle final, documentation et réaction en cas de découverte.$mft$,
   $mft$Réponse modèle. Préparation : véhicule adapté (bâche en bon état, portes saines, scellés fournis), itinéraire évitant les derniers arrêts en zone à risque immédiate, plein et pause pris EN AMONT pour rouler direct sur la fin. Chargement : scellé numéroté posé aux portes, numéro reporté sur la LV, photos ; état de bâche documenté. Arrêts : parkings sécurisés ou très fréquentés uniquement ; à CHAQUE arrêt : tour complet : bâche (lacérations, coutures), toit visible depuis la cabine ou un point haut, dessous, sangles, scellé intact ; cabine verrouillée pendant le tour. Contrôle final avant l'enceinte portuaire : check-list datée, heure, points vérifiés, signature : elle démontre la diligence en cas de découverte ultérieure côté contrôles. Découverte ou doute (bruit, bâche entaillée, scellé rompu) : ne pas ouvrir, ne pas confronter, s'éloigner du véhicule si besoin, appeler la police (17/112) et l'exploitation, attendre en sécurité ; ne JAMAIS reprendre la route avec un doute non levé : quelques kilomètres « pour vérifier plus loin » se qualifient très mal ensuite. Après incident : rapport écrit, scellés remplacés, retour d'expérience partagé avec l'exploitation.$mft$,
   $mft$Barème /5 : préparation intelligente (pause en amont, matériel) (1 pt) ; routine d'arrêt complète (1,5 pt) ; check-list finale documentée et son rôle probatoire (1,5 pt) ; réaction correcte à la découverte (1 pt). Erreurs fréquentes : contrôles réels mais jamais tracés ; « rouler jusqu'au prochain parking » en cas de doute.$mft$,
   5, 'moyen', ARRAY['fimo-fco','theme-3','question-redigee'], 'FIMO-T3-QR-05', false,
   $mft$La routine sûreté du corridor sensible, documentée de bout en bout.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Construisez la semaine type « hygiène de vie » d'un conducteur en découchés (4 nuits en cabine) : sommeil, repas, activité physique, écrans : avec les pièges spécifiques de la vie en cabine et leurs parades.$mft$,
   $mft$Réponse modèle. Sommeil : viser des horaires réguliers malgré les tournées, cabine préparée (rideaux occultants, aération, température modérée), rituel court (lecture, pas d'écran au lit), bouchons d'oreilles sur parkings bruyants ; le repos réglementaire est un MINIMUM : la dette se cumule sur la semaine. Repas : piège du duo station-service/restauration rapide : parade : glacière de cabine (eau, fruits, produits simples), un vrai repas léger le midi, dîner tôt et digeste avant la nuit en cabine, café stoppé en fin d'après-midi. Activité : 15 minutes de marche à chaque pause longue (le tour du parking compte), étirements dos/épaules/jambes au réveil et le soir : le corps assis huit heures se venge sinon. Écrans : le piège du « scroll » nocturne en cabine qui vole le sommeil : parade : limite horaire fixe, téléphone en charge HORS de la couchette ; en journée : messages à l'arrêt uniquement. Pièges spécifiques cabine : sédentarité totale, isolement (garder le lien : appels aux proches à heure fixe), alcool « pour dormir » (sommeil de mauvaise qualité et prise de service à risque : à proscrire). Une semaine tenue = vigilance stable, dos préservé, et une FCO qui n'a rien à corriger.$mft$,
   $mft$Barème /5 : sommeil en cabine avec parades concrètes (1,5 pt) ; alimentation réaliste en tournée (1 pt) ; activité physique intégrée (1 pt) ; écrans et alcool du soir traités (1 pt) ; cohérence d'ensemble (0,5 pt). Erreurs fréquentes : conseils de bureau inapplicables en cabine ; oublier l'alcool « pour dormir ».$mft$,
   5, 'difficile', ARRAY['fimo-fco','theme-3','question-redigee'], 'FIMO-T3-QR-06', false,
   $mft$L'hygiène de vie RÉALISTE du découché : le quotidien qui protège.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Analyse d'accident du travail : un conducteur intérimaire s'est fait rouler sur le pied par son transpalette chargé en descendant une pente de quai mouillée. Reconstituez l'arbre des causes probable et proposez les mesures de prévention à chaque niveau.$mft$,
   $mft$Réponse modèle. Arbre des causes (du fait à l'organisation) : Fait : pied écrasé par le transpalette. Causes immédiates : conducteur placé ENTRE le transpalette et la pente (position interdite : dans une descente, le transpalette se retient depuis l'amont), sol mouillé (adhérence réduite), charge lourde qui pousse. Causes sous-jacentes : technique non maîtrisée (on TIRE sur le plat, on retient en amont dans les pentes ; jamais le corps en aval de la charge), chaussures de sécurité présentes mais semelles usées ?, pente de quai non traitée antidérapant, absence d'équipement adapté (transpalette électrique avec frein pour les pentes). Causes organisationnelles : intérimaire : accueil sécurité insuffisant sur CE site (les intérimaires sont statistiquement surexposés), pas de consigne écrite sur la manœuvre en pente, protocole de sécurité du site muet sur ce flux. Mesures : immédiates : consigne pente diffusée (position amont, charge freinée), zone traitée antidérapante, vérification des EPI ; organisationnelles : module « transpalette » dans l'accueil sécurité de TOUT nouvel arrivant avec démonstration pratique, transpalette électrique freiné pour les quais en pente, protocole de sécurité mis à jour avec le client ; suivi : AT déclaré (24 h/48 h), analyse partagée en causerie, vérification à 3 mois que la consigne vit.$mft$,
   $mft$Barème /5 : causes immédiates exactes dont la position corps/charge (1,5 pt) ; remontée aux causes organisationnelles (intérimaire, consignes, site) (1,5 pt) ; mesures à chaque niveau, pas seulement individuelles (1,5 pt) ; boucle AT/causerie/suivi (0,5 pt). Erreurs fréquentes : s'arrêter à « faute de l'intérimaire » ; mesures uniquement matérielles.$mft$,
   5, 'difficile', ARRAY['fimo-fco','theme-3','question-redigee'], 'FIMO-T3-QR-07', false,
   $mft$Arbre des causes complet sur un AT de manutention typique.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Votre entreprise vous confie un chargement à forte valeur (électronique, 380 000 €) avec nuit en route. L'exploitation vous laisse « gérer comme d'habitude ». Démontrez que « comme d'habitude » ne suffit pas : analysez les risques spécifiques et proposez le protocole renforcé que vous demanderiez.$mft$,
   $mft$Réponse modèle. Risques spécifiques : le fret à forte valeur est CIBLÉ : repérage possible dès le chargement, suivi sur l'itinéraire, attaque au stationnement (bâche lacérée, effraction rapide), détournement par faux réceptionnaire, vol du véhicule complet ; la nuit en route est LE point de vulnérabilité. Pourquoi « comme d'habitude » échoue : les basiques (verrouillage, scellés) traitent l'opportuniste, pas l'attaque préparée. Protocole renforcé à demander : itinéraire : validé à l'avance, axes principaux, pas de divulgation (discrétion radio/téléphone/réseaux), départ calé pour minimiser l'arrêt nocturne ; stationnement : parking SÉCURISÉ réservé à l'avance (gardiennage, clôture) : sinon, revoir l'horaire pour rouler de jour ; véhicule : caisse rigide plutôt que bâche si possible, scellés numérotés + cadenas renforcé, géolocalisation active et bouton d'alerte testés ; procédures : points de contact horaires avec l'exploitation, consigne en cas de suspicion de suivi (ne pas s'arrêter en zone isolée, se diriger vers une zone fréquentée/station, appeler), livraison : identité du réceptionnaire vérifiée contre la LV, pas de remise « sur le parking » ; en cas d'attaque : ne JAMAIS résister physiquement : la marchandise est assurée, pas vous. Conclusion : demander ces moyens par écrit : une exploitation sérieuse les accorde ; un refus documenté déplace la responsabilité.$mft$,
   $mft$Barème /5 : analyse du risque ciblé vs opportuniste (1,5 pt) ; protocole renforcé complet (itinéraire, parking sécurisé, véhicule, contacts, livraison vérifiée) (2,5 pts) ; consigne de non-résistance (0,5 pt) ; demande écrite des moyens (0,5 pt). Erreurs fréquentes : em­piler des gadgets sans traiter la nuit ; jouer au héros en cas d'attaque.$mft$,
   5, 'difficile', ARRAY['fimo-fco','theme-3','question-redigee'], 'FIMO-T3-QR-08', false,
   $mft$Fret à forte valeur : du « comme d'habitude » au protocole renforcé argumenté.$mft$);

  RAISE NOTICE 'Thème 3 FIMO/FCO créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $fimot3$;
