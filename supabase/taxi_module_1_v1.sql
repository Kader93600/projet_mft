-- =====================================================================
-- TAXI / VTC (T3P) : MODULE 1 : LE CADRE DU T3P ET L'ACCÈS AU MÉTIER
-- v1 (juillet 2026) : LOT TAXI-1
-- Le transport public particulier de personnes, la carte professionnelle,
-- l'examen des CMA, les conditions d'accès et l'exercice illégal.
-- ⚠ STATUT : active = false (« à valider »). Idempotent.
-- =====================================================================

DO $taxim1$
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

  DELETE FROM public.question_bank WHERE source_ref LIKE 'TAXI-M1-%';
  DELETE FROM public.modules WHERE slug = 'taxi-vtc-cadre-t3p';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 1 : Le cadre du T3P et l''accès au métier',
    'taxi-vtc-cadre-t3p', v_bloc,
    'Le transport public particulier de personnes (taxis, VTC), la carte professionnelle, l''examen des chambres de métiers, les conditions d''accès et les sanctions de l''exercice illégal.',
    'debutant', 300, 10) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 10, true);

  -- ─── Leçon 1 : Le T3P et ses acteurs ────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'le-t3p-et-ses-acteurs',
    'Le T3P : un secteur, deux métiers',
    $mft$> 🎯 **Objectifs**
> - Définir le T3P et situer précisément taxis et VTC dans ce cadre commun.
> - Retenir ce que les lois Thévenoud (2014) et Grandguillaume (2016) ont changé.
> - Identifier les acteurs institutionnels du secteur et le rôle exact de chacun.

## Un sigle à maîtriser dès le premier jour

T3P signifie **transport public particulier de personnes**. Le code des transports range sous ce sigle les activités de transport de personnes effectuées à titre onéreux dans des véhicules de **moins de 10 places** : concrètement, les **taxis** et les **VTC** (voitures de transport avec chauffeur). Décryptons les mots : « public » signifie que le service est ouvert à tout client qui le demande ; « particulier » signifie que le client (seul ou avec son groupe) dispose du véhicule entier, contrairement au transport collectif où chacun achète une place dans un véhicule partagé.

Retenez d'emblée ce qui unit et ce qui sépare les deux métiers. Ce qui les unit : le même code des transports, une carte professionnelle de même nature (avec une mention différente), un examen organisé par le même réseau consulaire, les mêmes exigences de fond (honorabilité, aptitude, assurance). Ce qui les sépare : **le mode de rencontre avec le client**. Le taxi peut être hélé dans la rue et stationner sur des emplacements réservés ; le VTC travaille exclusivement sur réservation préalable. Cette frontière, vous la retrouverez partout dans votre préparation : la leçon 4 lui est consacrée.

## Deux lois qui ont façonné le secteur

L'arrivée des plateformes de réservation au début des années 2010 a bouleversé un secteur organisé autour du taxi. Le législateur est intervenu en deux temps :

:::timeline
2014 | Loi Thévenoud : encadrement de l'activité VTC, consécration du principe de la réservation préalable
2016 | Loi Grandguillaume : fin du détournement du statut LOTI pour les véhicules de moins de 10 places, examen unique confié aux chambres de métiers et de l'artisanat (CMA)
:::

La **loi Thévenoud (2014)** répond aux tensions entre taxis et nouveaux entrants : elle encadre l'activité VTC et pose le principe qui la définit encore aujourd'hui : pas de prise en charge sans **réservation préalable**.

La **loi Grandguillaume (2016)** ferme une brèche : de nombreux conducteurs exerçaient une activité de type VTC sous un statut prévu pour le transport collectif léger (le statut dit LOTI), échappant ainsi aux règles du T3P. La loi met fin à ce détournement pour les véhicules de moins de 10 places et confie l'organisation d'un **examen unique aux CMA** : c'est exactement l'examen que vous préparez.

> 📌 **À retenir**
> Thévenoud 2014 : les VTC encadrés, la réservation préalable consacrée. Grandguillaume 2016 : fin du contournement LOTI en moins de 10 places, l'examen passe aux CMA. Deux dates, deux verbes : encadrer, unifier.

## Les acteurs autour de vous

| Acteur | Rôle dans le T3P |
| --- | --- |
| Préfecture | Délivre la carte professionnelle T3P (mention taxi ou VTC) |
| CMA | Organise l'examen d'accès (admissibilité et admission) |
| Mairie | Délivre les autorisations de stationnement (ADS) des taxis |
| Plateformes | Mettent en relation clients et conducteurs, portent la réservation préalable |

> ❌ **Piège à éviter**
> Confondre les guichets : la CMA ne délivre aucune carte professionnelle, la préfecture ne fait passer aucune épreuve, et la mairie n'intervient que pour l'ADS des taxis. À l'examen, les questions « qui fait quoi ? » comptent parmi les points les plus faciles à sécuriser : ne les offrez pas à la concurrence.

> 💡 **Astuce**
> Les plateformes sont des partenaires commerciaux, pas des autorités : elles ne remplacent ni la carte professionnelle, ni l'examen, ni l'assurance. Une inscription validée sur une application ne vous autorise à rien tant que votre situation administrative n'est pas complète.

## ✅ Synthèse

- T3P : **transport public particulier de personnes**, véhicules de **moins de 10 places** : taxis et VTC (code des transports).
- 2014 Thévenoud : encadrement VTC et **réservation préalable** ; 2016 Grandguillaume : fin du détournement LOTI et **examen unique CMA**.
- Qui fait quoi : **préfecture = carte**, **CMA = examen**, **mairie = ADS taxi**, plateformes = mise en relation commerciale.$mft$,
    $mft$Le T3P (taxis et VTC, moins de 10 places), les lois Thévenoud (2014, réservation préalable) et Grandguillaume (2016, fin du détournement LOTI, examen unique CMA), et la répartition des rôles entre préfecture, CMA, mairies et plateformes.$mft$,
    1, 40) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : Conditions d'accès et carte professionnelle ──────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'conditions-acces-carte-pro',
    'La carte professionnelle : conditions et délivrance',
    $mft$> 🎯 **Objectifs**
> - Lister les conditions d'accès à la carte professionnelle T3P, sans en oublier.
> - Savoir qui délivre la carte, ce qu'elle mentionne et comment elle vit dans le temps.
> - Repérer les pièges de dossier qui retardent ou bloquent une demande.

## Votre titre d'exercice

Aucune course rémunérée sans elle : la **carte professionnelle T3P** est délivrée par le **préfet** du département et porte la mention de votre activité : **taxi** ou **VTC**. C'est elle que vous présenterez à chaque contrôle. Elle atteste deux choses : vous remplissez les conditions d'accès à la profession, et vous avez réussi l'examen correspondant à votre filière.

## Les conditions d'accès, une par une

| Condition | Contenu | Le piège classique |
| --- | --- | --- |
| Permis B | Détenu depuis au moins 3 ans, ramenés à 2 ans en cas de conduite accompagnée | Compter depuis la date d'obtention du permis, pas depuis un autre repère |
| Aptitude médicale | Constatée par un médecin agréé par la préfecture | Un certificat du médecin traitant n'est pas recevable |
| Honorabilité | Certaines condamnations inscrites au bulletin n° 2 du casier judiciaire sont incompatibles avec la profession | C'est l'administration qui consulte ce bulletin, pas le candidat |
| Premiers secours | Attestation de formation (PSC1 ou équivalent) : exigence à vérifier auprès de votre préfecture | Se fier à l'expérience d'un collègue d'un autre département |

> ⚠️ **Attention**
> Sur les premiers secours, les exigences précises (type d'attestation admis, ancienneté tolérée) doivent être vérifiées auprès de votre préfecture ou de votre CMA avant de constituer le dossier : ce point évolue et les pratiques locales diffèrent. Ne bâtissez jamais un dossier sur une information de forum.

## L'honorabilité : la condition silencieuse mais décisive

L'administration vérifie le **bulletin n° 2** du casier judiciaire, celui auquel le candidat n'a pas accès directement. Certaines condamnations y figurant sont **incompatibles** avec l'exercice du T3P : la carte est alors refusée, quels que soient les résultats à l'examen. Et la condition ne s'éteint pas à la délivrance : une condamnation incompatible survenant en cours de carrière expose au retrait de la carte. Le métier consiste à transporter des personnes, parfois vulnérables, souvent seules avec vous : le législateur a placé la barre en conséquence.

> 🔍 **Zoom**
> Candidat concerné par un antécédent judiciaire ? Renseignez-vous précisément sur votre situation AVANT d'engager des frais de préparation : c'est la première vérification à faire, pas la dernière.

## Une carte qui vit : renouvellement et suivi médical

La carte professionnelle n'est pas acquise à vie : elle se **renouvelle**. L'aptitude médicale, elle, se vérifie périodiquement : pour un conducteur professionnel titulaire du permis B, la visite médicale revient en règle générale **tous les 5 ans avant 60 ans** ; au-delà de cet âge, la périodicité change : vérifiez le rythme applicable à votre situation auprès de la préfecture. Anticipez : obtenir un rendez-vous chez un médecin agréé peut demander plusieurs semaines.

> 💡 **Astuce**
> Constituez dès maintenant un dossier « carte pro » (copies du permis, attestations, certificats datés) et notez vos échéances (renouvellement de la carte, prochaine visite médicale) dans votre agenda. Le professionnel qui exerce avec une carte périmée s'expose comme s'il n'en avait jamais eu.

## ✅ Synthèse

- Carte délivrée par le **préfet**, mention **taxi** ou **VTC** : obligatoire pour toute course rémunérée.
- Conditions cumulatives : **permis B 3 ans (2 ans si conduite accompagnée)**, **aptitude médicale constatée par un médecin agréé**, **honorabilité (bulletin n° 2)**, attestation de premiers secours (exigences précises à vérifier localement).
- La carte se **renouvelle** ; visite médicale périodique (de l'ordre de 5 ans avant 60 ans, périodicité à vérifier selon votre situation).$mft$,
    $mft$La carte professionnelle T3P (préfet, mention taxi ou VTC), les quatre conditions d'accès (permis B 3 ans ou 2 ans en conduite accompagnée, médecin agréé, honorabilité au bulletin n° 2, premiers secours à vérifier) et le suivi dans le temps (renouvellement, visite médicale).$mft$,
    2, 40) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : L'examen des CMA ─────────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'l-examen-cma',
    'L''examen organisé par les CMA',
    $mft$> 🎯 **Objectifs**
> - Visualiser le parcours complet de l'examen, de l'inscription à la carte.
> - Distinguer épreuves communes, épreuve spécifique et épreuve pratique d'admission.
> - Savoir où vérifier les modalités précises (barèmes, coefficients, calendrier).

## Le parcours en quatre étapes

Depuis la loi Grandguillaume, l'examen d'accès aux professions de conducteur de taxi et de VTC est organisé par les **chambres de métiers et de l'artisanat (CMA)**, avec des sessions régulières. Le parcours type :

:::flow
1. Inscription | Dossier déposé auprès de la CMA de votre département, choix de la filière (taxi ou VTC)
2. Admissibilité | Épreuves écrites : tronc commun taxi/VTC + épreuve spécifique de votre filière
3. Admission | Épreuve pratique de conduite avec mise en situation client
4. Carte professionnelle | Demande auprès de la préfecture avec l'attestation de réussite
:::

## L'admissibilité : le tronc commun

Les épreuves d'admissibilité **communes aux deux filières** couvrent cinq domaines :

| Domaine | Ce qu'on attend de vous |
| --- | --- |
| Réglementation du T3P | Cartes, acteurs, maraude et réservation préalable, sanctions : le cœur du métier |
| Gestion | Comprendre les bases d'une activité indépendante : charges, obligations, documents |
| Sécurité routière | Comportements du conducteur professionnel, règles de circulation appliquées |
| Français | Comprendre un texte, rédiger correctement : le client le remarque aussi |
| Anglais | Accueillir et gérer une course avec un client étranger : phrases du quotidien |

## L'épreuve spécifique : votre filière

À l'inscription, vous choisissez votre filière, et l'épreuve spécifique suit : **réglementation et tarification taxi** pour les candidats taxi, **réglementation VTC** pour les candidats VTC. C'est l'épreuve qui distingue vraiment les deux préparations : le candidat taxi doit maîtriser sa tarification réglementée, le candidat VTC son cadre propre. Choisissez donc votre filière en fonction de votre projet réel (travailler la clientèle de passage et les stations, ou construire une activité sur réservation), pas en fonction de la réputation supposée de telle ou telle épreuve.

## L'admission : la pratique en situation

Après la réussite de l'admissibilité vient l'**épreuve d'admission** : une épreuve pratique de **conduite avec mise en situation client**. L'examinateur n'évalue pas un candidat au permis B : il évalue un professionnel du transport de personnes. Deux dimensions comptent : la conduite (sûre, souple, réglementaire) et la prestation (accueil du client, courtoisie, gestion du trajet, attitude professionnelle du début à la fin de la course).

Concrètement, tout se joue dans les détails d'une vraie course : la manière de saluer et d'installer le passager, la vérification de son confort, l'annonce claire du trajet envisagé, la fluidité de la conduite (ni brusque, ni hésitante), la réaction posée face à un imprévu de circulation, et la clôture correcte de la prestation. Beaucoup de candidats solides sur la théorie échouent ici, faute d'avoir répété la dimension service : entraînez-vous avec un passager qui joue le client, du bonjour jusqu'à la fin de la course.

> ⚠️ **Attention**
> Les barèmes, les coefficients et les éventuelles notes éliminatoires relèvent des textes et des modalités en vigueur : vérifiez-les dans la documentation officielle de votre CMA et travaillez sur les **annales officielles**. Ne préparez jamais l'examen sur la foi de chiffres glanés sur des forums ou des vidéos : une modalité périmée peut vous coûter la session.

> 🎓 **Pour l'examen**
> La régularité bat le bachotage : des sessions courtes et fréquentes de QCM, un carnet d'erreurs relu chaque semaine, l'anglais de prise en charge répété à voix haute, et au moins une répétition complète de la mise en situation client avec un proche jouant le passager. Le jour J, vous devez dérouler des automatismes, pas improviser.

## ✅ Synthèse

- Un guichet unique : **la CMA** (inscription, sessions régulières) ; la carte reste délivrée par la préfecture.
- Admissibilité : **tronc commun** (réglementation T3P, gestion, sécurité routière, français, anglais) + **épreuve spécifique** (réglementation et tarification taxi OU réglementation VTC).
- Admission : **épreuve pratique de conduite avec mise en situation client** : conduite ET prestation.
- Barèmes, coefficients, notes éliminatoires : **à vérifier auprès de votre CMA et dans les annales officielles**.$mft$,
    $mft$Le parcours d'examen CMA en quatre étapes : admissibilité commune (réglementation T3P, gestion, sécurité routière, français, anglais), épreuve spécifique par filière (taxi ou VTC), admission pratique avec mise en situation client, et le réflexe de vérifier les modalités précises auprès de la CMA.$mft$,
    3, 40) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : Exercice illégal, contrôles, assurance ───────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'exercice-illegal-controles',
    'Exercice illégal, contrôles et assurance',
    $mft$> 🎯 **Objectifs**
> - Tracer la frontière exacte entre maraude et réservation préalable.
> - Identifier les figures de l'exercice illégal du T3P et leurs sanctions.
> - Comprendre les contrôles et l'exigence d'assurance professionnelle.

## La frontière qui organise tout le secteur

| | Maraude | Réservation préalable |
| --- | --- | --- |
| Définition | Stationner ou circuler en quête de clients et prendre en charge immédiatement une personne qui hèle le véhicule | La course est commandée avant la prise en charge (application, téléphone, comptoir) |
| Qui peut la pratiquer | **Monopole des taxis**, avec une autorisation de stationnement (ADS) | **VTC et taxis** |

Le taxi cumule donc les deux modes de travail ; le VTC n'a que le second. Un VTC qui se poste devant une gare et charge un client qui le hèle bascule dans la maraude : il exerce illégalement, même avec une carte VTC parfaitement valide. À l'inverse, une course commandée sur une application, même peu de temps avant la prise en charge, reste une réservation préalable : ce qui compte, c'est que la réservation **existe avant** la montée du client.

## Les trois figures de l'exercice illégal

1. **Sans carte professionnelle** : transporter des personnes à titre onéreux sans carte T3P, quelle que soit la qualité de la prestation.
2. **La maraude sans ADS** : la maraude suppose une autorisation de stationnement délivrée par la mairie ; la carte taxi seule ne suffit pas.
3. **Le VTC en maraude** : carte valide, mais mode de travail réservé aux taxis.

## Les sanctions : pénales, patrimoniales, professionnelles

L'exercice illégal du T3P expose à des **sanctions pénales** : amendes, **confiscation possible du véhicule** (c'est l'outil de travail qui part), et **peines complémentaires**. Retenez la logique plutôt que des montants : la sanction peut toucher le portefeuille, le patrimoine et l'avenir professionnel en même temps.

Les **contrôles** sont le quotidien du secteur : police et gendarmerie, unités spécialisées dans le contrôle du T3P (les « boers », selon le surnom historique de ces agents), et agents habilités. Ils se concentrent là où la demande est forte : gares, aéroports, sorties de spectacles. Face à eux, un VTC doit pouvoir montrer que sa prise en charge repose bien sur une réservation préalable.

## L'assurance : le risque que l'on ne voit qu'après l'accident

Transporter des personnes contre rémunération exige une **responsabilité civile professionnelle couvrant le transport de personnes à titre onéreux**. L'assurance auto personnelle ne couvre pas cette activité : en cas d'accident avec un client, l'assureur peut **refuser sa garantie** si l'activité exercée ne correspond pas au contrat, ou si la course relevait d'un exercice illégal. Des dommages corporels non couverts se chiffrent en sommes qui ruinent une vie professionnelle : c'est le risque le plus sous-estimé par ceux qui « dépannent » quelques courses sans être en règle.

> ❌ **Piège à éviter**
> « J'ai une carte VTC, donc je suis en règle. » Non : la carte autorise un MODE d'exercice (la réservation préalable), pas tous les comportements. La légalité se vérifie course par course : carte valide, réservation existante, assurance adaptée.

> 📌 **À retenir**
> Trois questions avant chaque course : ai-je ma carte ? cette course a-t-elle été réservée avant la prise en charge (ou suis-je taxi avec ADS en maraude) ? mon assurance couvre-t-elle ce que je fais là, maintenant ? Trois oui, ou pas de course.

## ✅ Synthèse

- **Maraude = monopole taxi (avec ADS)** ; **réservation préalable = VTC et taxis** : la frontière du secteur.
- Exercice illégal : **sans carte**, **maraude sans ADS**, **VTC en maraude** : amendes, **confiscation possible du véhicule**, peines complémentaires.
- Contrôles par police, unités spécialisées (« boers ») et agents habilités, surtout aux points de forte demande.
- **RC professionnelle transport de personnes à titre onéreux obligatoire** : sans elle, l'accident avec client peut ne pas être couvert.$mft$,
    $mft$La distinction maraude (monopole taxi avec ADS) / réservation préalable (VTC et taxi), les trois figures de l'exercice illégal et leurs sanctions (amendes, confiscation possible, peines complémentaires), les contrôles (police, boers, agents) et l'obligation de RC professionnelle.$mft$,
    4, 40) RETURNING id INTO v_l4;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : Le cadre du T3P',
    'Vérifiez le module 1 : T3P et ses acteurs, carte professionnelle, examen CMA, exercice illégal.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Yanis prépare l'examen et découvre le sigle T3P sur son livret. Que recouvre-t-il exactement ?$mft$,
    $mft$[
      {"id":"a","label":"Le transport public particulier de personnes : taxis et VTC, dans des véhicules de moins de 10 places","is_correct":true},
      {"id":"b","label":"Le transport collectif urbain : bus et tramways de plus de 10 places","is_correct":false},
      {"id":"c","label":"Uniquement les taxis, les VTC relevant d'un autre cadre juridique","is_correct":false},
      {"id":"d","label":"Le transport de marchandises légères en zone urbaine","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-1','qcm-v1'], 'TAXI-M1-QCM-01', false,
    $mft$Le code des transports regroupe taxis ET VTC sous le T3P (moins de 10 places) : le transport collectif et les marchandises relèvent d'autres régimes, et les VTC ne sont pas à part.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Un passant hèle votre VTC devant la gare et veut monter immédiatement, sans réservation. Que faites-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Vous refusez : la prise en charge immédiate dans la rue est de la maraude, monopole des taxis ; le VTC travaille sur réservation préalable","is_correct":true},
      {"id":"b","label":"Vous acceptez si la course est courte et payée en espèces","is_correct":false},
      {"id":"c","label":"Vous acceptez : votre carte VTC vous autorise toutes les prises en charge","is_correct":false},
      {"id":"d","label":"Vous acceptez à condition qu'il valide la course sur l'application pendant le trajet","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-1','qcm-v1'], 'TAXI-M1-QCM-02', false,
    $mft$La réservation doit exister AVANT la montée du client : ni la brièveté de la course, ni la carte VTC, ni une validation après coup ne rendent la prise en charge légale.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Sonia a obtenu son permis B il y a 2 ans et demi, par la filière classique. Peut-elle demander sa carte professionnelle VTC ?$mft$,
    $mft$[
      {"id":"a","label":"Non : il faut détenir le permis B depuis au moins 3 ans (2 ans seulement en cas de conduite accompagnée)","is_correct":true},
      {"id":"b","label":"Oui : 2 ans de permis suffisent pour tous les candidats","is_correct":false},
      {"id":"c","label":"Oui : la réussite de l'examen dispense de la condition de permis","is_correct":false},
      {"id":"d","label":"Non : il faut 5 ans de permis dans tous les cas","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-1','qcm-v1'], 'TAXI-M1-QCM-03', false,
    $mft$La condition est de 3 ans en filière classique, ramenée à 2 ans après conduite accompagnée : l'examen ne dispense d'aucune condition d'accès, et aucun texte n'exige 5 ans.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Karim veut s'inscrire à l'examen taxi. Auprès de quel organisme dépose-t-il son dossier d'inscription ?$mft$,
    $mft$[
      {"id":"a","label":"La chambre de métiers et de l'artisanat (CMA), qui organise l'examen","is_correct":true},
      {"id":"b","label":"La préfecture, qui organise aussi les épreuves","is_correct":false},
      {"id":"c","label":"La mairie, au titre des autorisations de stationnement","is_correct":false},
      {"id":"d","label":"La plateforme avec laquelle il souhaite travailler","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-1','qcm-v1'], 'TAXI-M1-QCM-04', false,
    $mft$Depuis la loi Grandguillaume, la CMA organise l'examen : la préfecture délivre la carte mais ne fait passer aucune épreuve, la mairie gère les ADS et la plateforme n'est qu'un partenaire commercial.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Avant 2016, de nombreux conducteurs exerçaient une activité de type VTC sous statut LOTI dans des berlines. Qu'a changé la loi Grandguillaume ?$mft$,
    $mft$[
      {"id":"a","label":"Elle a mis fin au détournement du statut LOTI pour les véhicules de moins de 10 places et confié un examen unique aux CMA","is_correct":true},
      {"id":"b","label":"Elle a autorisé la maraude pour les VTC en zone rurale","is_correct":false},
      {"id":"c","label":"Elle a supprimé l'examen taxi au profit d'une simple formation en ligne","is_correct":false},
      {"id":"d","label":"Elle a transféré la délivrance des cartes professionnelles aux mairies","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-1','qcm-v1'], 'TAXI-M1-QCM-05', false,
    $mft$Grandguillaume 2016 = fermeture de la brèche LOTI en moins de 10 places + examen unique CMA : la maraude reste un monopole taxi, l'examen existe toujours et la carte reste préfectorale.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Lors de l'instruction d'une demande de carte VTC, l'administration constate une condamnation incompatible inscrite au bulletin n° 2 du candidat. Quelle conséquence ?$mft$,
    $mft$[
      {"id":"a","label":"La carte peut être refusée : la condition d'honorabilité n'est pas remplie","is_correct":true},
      {"id":"b","label":"Aucune : le casier judiciaire ne concerne pas les professions du transport","is_correct":false},
      {"id":"c","label":"La carte est délivrée avec une période d'essai de six mois","is_correct":false},
      {"id":"d","label":"Le candidat doit simplement repasser l'épreuve de réglementation","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-1','qcm-v1'], 'TAXI-M1-QCM-06', false,
    $mft$L'honorabilité est une condition d'accès à part entière : une mention incompatible au bulletin n° 2 bloque la délivrance, sans « période d'essai » ni rattrapage par l'examen.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Louise passe les épreuves d'admissibilité en filière taxi. En plus des épreuves communes, quelle épreuve spécifique l'attend ?$mft$,
    $mft$[
      {"id":"a","label":"La réglementation et la tarification propres à l'activité taxi","is_correct":true},
      {"id":"b","label":"La réglementation VTC","is_correct":false},
      {"id":"c","label":"Une épreuve de mécanique automobile","is_correct":false},
      {"id":"d","label":"Un test psychotechnique de gestion du stress","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-1','qcm-v1'], 'TAXI-M1-QCM-07', false,
    $mft$L'épreuve spécifique suit la filière choisie à l'inscription : réglementation et tarification taxi pour Louise, réglementation VTC pour un candidat VTC ; mécanique et tests psychotechniques ne figurent pas dans l'admissibilité.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Contrôlé pendant une course rémunérée, Malik ne peut présenter aucune carte professionnelle T3P. Quels risques encourt-il ?$mft$,
    $mft$[
      {"id":"a","label":"Des sanctions pénales : amende, confiscation possible du véhicule et peines complémentaires","is_correct":true},
      {"id":"b","label":"Un simple rappel à la loi, sans autre suite possible","is_correct":false},
      {"id":"c","label":"Uniquement un retrait de points sur le permis de conduire","is_correct":false},
      {"id":"d","label":"Rien, s'il rembourse la course au client","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-1','qcm-v1'], 'TAXI-M1-QCM-08', false,
    $mft$L'exercice illégal du T3P est une infraction pénale : la réponse peut toucher le portefeuille (amende), l'outil de travail (confiscation possible) et l'avenir (peines complémentaires) ; rembourser le client n'efface rien.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$En 2014, le législateur intervient pour la première fois massivement sur les VTC. Quel est l'apport central de la loi Thévenoud ?$mft$,
    $mft$[
      {"id":"a","label":"L'encadrement de l'activité VTC autour du principe de la réservation préalable","is_correct":true},
      {"id":"b","label":"L'ouverture de la maraude aux VTC dans les grandes villes","is_correct":false},
      {"id":"c","label":"La création d'autorisations de stationnement pour les VTC","is_correct":false},
      {"id":"d","label":"L'interdiction pure et simple des plateformes de réservation","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-1','qcm-v1'], 'TAXI-M1-QCM-09', false,
    $mft$Thévenoud 2014 encadre les VTC et consacre la réservation préalable : la maraude et les ADS restent l'apanage des taxis, et les plateformes n'ont pas été interdites mais encadrées.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Nadia démarre en VTC avec la seule assurance auto personnelle de sa berline. Lors d'une course, un client est blessé. Quelle est la position probable de l'assureur ?$mft$,
    $mft$[
      {"id":"a","label":"Un refus de garantie possible : le transport de personnes à titre onéreux exige une RC professionnelle spécifique, non couverte par un contrat personnel","is_correct":true},
      {"id":"b","label":"Une prise en charge complète : une assurance auto couvre tous les usages du véhicule","is_correct":false},
      {"id":"c","label":"Une prise en charge automatique dès que Nadia présente sa carte VTC","is_correct":false},
      {"id":"d","label":"Aucune conséquence : c'est toujours la plateforme qui assure les courses","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-1','qcm-v1'], 'TAXI-M1-QCM-10', false,
    $mft$L'activité rémunérée doit être couverte par une RC professionnelle transport de personnes à titre onéreux : ni le contrat personnel, ni la carte, ni la plateforme ne s'y substituent, et les dommages corporels non garantis restent à charge.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Pour justifier son aptitude médicale, Théo joint à son dossier un certificat rédigé par son médecin traitant. Le dossier est-il recevable sur ce point ?$mft$,
    $mft$[
      {"id":"a","label":"Non : l'aptitude doit être constatée par un médecin agréé par la préfecture","is_correct":true},
      {"id":"b","label":"Oui : tout docteur en médecine peut établir ce certificat","is_correct":false},
      {"id":"c","label":"Oui, à condition que le certificat date de moins de huit jours","is_correct":false},
      {"id":"d","label":"Non : seul un médecin hospitalier est habilité","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-1','qcm-v1'], 'TAXI-M1-QCM-11', false,
    $mft$Le certificat du médecin traitant n'est pas recevable : il faut un médecin AGRÉÉ par la préfecture, ce qui n'est ni « tout docteur » ni spécifiquement un praticien hospitalier ; la fraîcheur du document ne corrige pas ce défaut.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$À l'épreuve d'admission, l'examinateur monte à bord et se comporte comme un client à conduire vers une destination. Qu'évalue réellement cette épreuve ?$mft$,
    $mft$[
      {"id":"a","label":"La conduite en situation réelle ET la relation client : accueil, attitude professionnelle, gestion du trajet","is_correct":true},
      {"id":"b","label":"Uniquement le respect du code de la route, comme au permis B","is_correct":false},
      {"id":"c","label":"La connaissance théorique de la réglementation, restituée à l'oral","is_correct":false},
      {"id":"d","label":"La capacité à diagnostiquer une panne mécanique simple","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-1','qcm-v1'], 'TAXI-M1-QCM-12', false,
    $mft$L'admission évalue un professionnel en prestation : conduite sûre PLUS mise en situation client ; la théorie a déjà été vérifiée à l'admissibilité et la mécanique ne fait pas partie de l'épreuve.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Vous expliquez votre futur métier à un proche : que signifie le sigle T3P et quels véhicules sont concernés ?$mft$,
   $mft$Transport public particulier de personnes : les taxis et les VTC, dans des véhicules de moins de 10 places.$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-1','question-courte'], 'TAXI-M1-QC-01', false,
   $mft$Le sigle développé + les deux métiers + le seuil de 10 places.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Qui délivre la carte professionnelle T3P et quelle mention y figure selon votre activité ?$mft$,
   $mft$Le préfet (la préfecture) ; la carte porte la mention « taxi » ou « VTC » selon la filière.$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-1','question-courte'], 'TAXI-M1-QC-02', false,
   $mft$Préfet + mention taxi ou VTC.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Un client tente de monter dans votre VTC en pleine rue, sans réservation : quelle règle vous oblige à refuser ?$mft$,
   $mft$La prise en charge immédiate sur la voie publique (maraude) est un monopole des taxis : le VTC ne travaille que sur réservation préalable, qui doit exister avant la montée du client.$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-1','question-courte'], 'TAXI-M1-QC-03', false,
   $mft$Maraude = taxis ; VTC = réservation préalable.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Citez les deux apports majeurs de la loi Grandguillaume (2016) pour le secteur du T3P.$mft$,
   $mft$La fin du détournement du statut LOTI pour les véhicules de moins de 10 places, et l'examen unique confié aux chambres de métiers et de l'artisanat (CMA).$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-1','question-courte'], 'TAXI-M1-QC-04', false,
   $mft$Les deux apports attendus : fin du contournement LOTI + examen CMA.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Citez trois matières des épreuves d'admissibilité communes aux candidats taxi et VTC.$mft$,
   $mft$Trois parmi : la réglementation du T3P, la gestion, la sécurité routière, le français, l'anglais.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-1','question-courte'], 'TAXI-M1-QC-05', false,
   $mft$Trois matières exactes du tronc commun.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Votre cousin a obtenu son permis B il y a 2 ans et 3 mois, après une conduite accompagnée. Remplit-il la condition d'ancienneté de permis pour la carte T3P ?$mft$,
   $mft$Oui : la condition est de 3 ans, ramenée à 2 ans pour les titulaires passés par la conduite accompagnée ; avec 2 ans et 3 mois, il la remplit.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-1','question-courte'], 'TAXI-M1-QC-06', false,
   $mft$La réduction à 2 ans en conduite accompagnée doit être citée.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Avant votre toute première course rémunérée, quelle assurance spécifique devez-vous impérativement détenir ?$mft$,
   $mft$Une responsabilité civile professionnelle couvrant le transport de personnes à titre onéreux : l'assurance auto personnelle ne couvre pas cette activité.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-1','question-courte'], 'TAXI-M1-QC-07', false,
   $mft$RC pro transport de personnes à titre onéreux.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$En quoi consiste l'épreuve d'admission de l'examen T3P ?$mft$,
   $mft$Une épreuve pratique de conduite avec mise en situation client (accueil, gestion du trajet, attitude professionnelle), passée après la réussite des épreuves d'admissibilité.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-1','question-courte'], 'TAXI-M1-QC-08', false,
   $mft$Conduite + mise en situation client, après l'admissibilité.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$L'administration consulte le bulletin n° 2 du casier judiciaire d'un candidat : quelle condition vérifie-t-elle et quelle peut être la conséquence d'une mention incompatible ?$mft$,
   $mft$Elle vérifie l'honorabilité : certaines condamnations inscrites au bulletin n° 2 sont incompatibles avec la profession et entraînent le refus de la carte professionnelle (ou son retrait si elles surviennent ensuite).$mft$,
   2, 'difficile', ARRAY['taxi-vtc','module-1','question-courte'], 'TAXI-M1-QC-09', false,
   $mft$Honorabilité + refus ou retrait de la carte.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Un conducteur pratique la maraude sans y être autorisé : citez deux sanctions ou risques encourus au-delà de l'amende.$mft$,
   $mft$Deux parmi : la confiscation possible du véhicule, des peines complémentaires, le refus de garantie de l'assureur en cas d'accident pendant l'exercice illégal.$mft$,
   2, 'difficile', ARRAY['taxi-vtc','module-1','question-courte'], 'TAXI-M1-QC-10', false,
   $mft$Deux risques distincts au-delà de l'amende.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ─────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l4, 'qr',
   $mft$Comparez la maraude et la réservation préalable : définissez chacune, précisez qui peut pratiquer quoi, et expliquez pourquoi cette frontière structure tout le secteur du T3P.$mft$,
   $mft$Réponse modèle. La maraude consiste à stationner ou circuler sur la voie publique en quête de clients et à prendre en charge immédiatement une personne qui hèle le véhicule. Elle est le monopole des taxis et suppose une autorisation de stationnement (ADS) délivrée par la mairie : elle ouvre l'accès aux stations, aux gares et à la clientèle de passage. La réservation préalable consiste à commander la course avant la prise en charge (application, téléphone, comptoir d'hôtel) : c'est le seul mode de travail des VTC, et les taxis peuvent aussi l'utiliser. Cette frontière structure tout le secteur : elle définit les métiers (le taxi cumule les deux modes, le VTC n'en a qu'un), elle donne leur valeur aux ADS, elle fonde la principale infraction du secteur (le VTC en maraude) et elle a guidé le législateur (loi Thévenoud de 2014, qui a consacré la réservation préalable comme critère de l'activité VTC). Pour le client, la différence est presque invisible ; pour le professionnel contrôlé, elle sépare l'exercice légal de l'exercice illégal, avec ses sanctions pénales et ses conséquences assurantielles.$mft$,
   $mft$Barème /5 : définitions exactes des deux notions (1,5 pt) ; attribution correcte (maraude = taxis avec ADS ; réservation préalable = VTC et taxis) (1,5 pt) ; au moins deux raisons pour lesquelles la frontière structure le secteur (métiers, valeur des ADS, infraction type, loi Thévenoud) (1,5 pt) ; conséquence concrète en contrôle (0,5 pt). Erreurs fréquentes : croire que le taxi ne peut pas prendre de réservations ; oublier que la maraude exige une ADS en plus de la carte.$mft$,
   5, 'facile', ARRAY['taxi-vtc','module-1','question-redigee'], 'TAXI-M1-QR-01', false,
   $mft$La frontière fondatrice du T3P, comparée et justifiée.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Un ami salarié veut devenir chauffeur VTC. Construisez-lui la feuille de route complète : conditions personnelles à vérifier, démarches à accomplir, jusqu'à l'obtention de la carte professionnelle et au démarrage légal de l'activité.$mft$,
   $mft$Réponse modèle. Étape 1, vérifier les conditions personnelles : permis B détenu depuis au moins 3 ans (2 ans si conduite accompagnée) ; honorabilité (certaines condamnations inscrites au bulletin n° 2 du casier judiciaire sont incompatibles ; l'administration le consulte directement) ; aptitude médicale à faire constater par un médecin agréé par la préfecture, et non par le médecin traitant ; attestation de formation aux premiers secours (PSC1 ou équivalent), dont l'exigence précise est à vérifier auprès de la préfecture. Étape 2, préparer et passer l'examen : inscription auprès de la chambre de métiers et de l'artisanat, épreuves d'admissibilité (tronc commun : réglementation T3P, gestion, sécurité routière, français, anglais, plus l'épreuve spécifique de réglementation VTC), puis épreuve pratique d'admission avec mise en situation client. Étape 3, obtenir la carte : demande auprès de la préfecture avec l'attestation de réussite ; la carte portera la mention VTC. Étape 4, démarrer légalement : souscrire une responsabilité civile professionnelle couvrant le transport de personnes à titre onéreux avant la première course, puis choisir statut et canaux de réservation. Conseil final : anticiper les délais (médecin agréé, sessions), qui se comptent en semaines.$mft$,
   $mft$Barème /5 : les quatre conditions personnelles exactes, avec médecin agréé et bulletin n° 2 (2 pts) ; parcours d'examen complet CMA (admissibilité + spécifique + admission) (1,5 pt) ; carte demandée à la préfecture, mention VTC (0,5 pt) ; RC professionnelle avant la première course + anticipation des délais (1 pt). Erreurs fréquentes : oublier l'assurance dans la feuille de route ; envoyer le candidat chercher sa carte à la CMA.$mft$,
   5, 'facile', ARRAY['taxi-vtc','module-1','question-redigee'], 'TAXI-M1-QR-02', false,
   $mft$La feuille de route du candidat VTC, de zéro à la première course légale.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Expliquez comment les lois Thévenoud (2014) et Grandguillaume (2016) ont réorganisé le transport public particulier de personnes, et ce que cet héritage change concrètement pour un candidat qui entre dans le métier aujourd'hui.$mft$,
   $mft$Réponse modèle. Avant 2014, l'essor des plateformes fait entrer massivement de nouveaux conducteurs dans un secteur bâti autour du taxi, avec de fortes tensions. La loi Thévenoud (2014) apporte la première réponse : elle encadre l'activité VTC et consacre la réservation préalable comme critère du métier : le VTC ne prend en charge que des courses commandées à l'avance, la maraude restant le monopole des taxis. Mais un contournement subsiste : des conducteurs exercent une activité de type VTC sous le statut LOTI, prévu pour le transport collectif léger, en échappant aux règles du T3P. La loi Grandguillaume (2016) ferme cette brèche : fin du détournement du statut LOTI pour les véhicules de moins de 10 places, et examen unique confié aux chambres de métiers et de l'artisanat. Pour un candidat aujourd'hui, l'héritage est concret : un seul guichet d'examen (la CMA), une carte professionnelle à mention (taxi ou VTC) délivrée par le préfet, une frontière nette entre les deux métiers (maraude contre réservation préalable) et un niveau d'exigence identique pour tous : il n'existe plus de porte dérobée pour entrer dans la profession.$mft$,
   $mft$Barème /5 : contexte d'avant 2014 (plateformes, tensions) (0,5 pt) ; Thévenoud : encadrement VTC + réservation préalable (1,5 pt) ; Grandguillaume : fin du détournement LOTI en moins de 10 places + examen unique CMA (1,5 pt) ; conséquences concrètes pour le candidat actuel, au moins deux (1,5 pt). Erreurs fréquentes : inverser les apports des deux lois ; croire que le statut LOTI a disparu de tout le transport (seul le détournement en moins de 10 places est visé).$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-1','question-redigee'], 'TAXI-M1-QR-03', false,
   $mft$Deux lois, une réorganisation : l'héritage expliqué au candidat.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$À trois mois d'une session d'examen, construisez votre plan de préparation aux trois volets de l'examen T3P (épreuves communes, épreuve spécifique, admission pratique), en précisant où trouver les informations officielles sur les barèmes et modalités.$mft$,
   $mft$Réponse modèle. Mois 1, le socle : travailler le tronc commun en continu : la réglementation du T3P (cartes, acteurs, maraude et réservation préalable, sanctions), qui irrigue toute la préparation ; la gestion (bases d'une activité indépendante) ; la sécurité routière ; réactiver le français écrit et l'anglais de prise en charge (accueil, destination, paiement). Mois 2, la spécialisation : l'épreuve spécifique de sa filière (réglementation et tarification taxi, ou réglementation VTC), travaillée sur les annales officielles ; c'est aussi le moment de vérifier auprès de sa CMA les modalités exactes de la session : calendrier, barèmes, coefficients et éventuelles notes éliminatoires, qui relèvent des textes en vigueur et ne doivent jamais être supposés d'après des forums. Mois 3, la pratique : préparer l'admission comme une prestation professionnelle : conduite souple et réglementaire, et mise en situation client (accueil, courtoisie, annonce du trajet, gestion d'un imprévu), répétée avec un passager jouant des profils variés. En transversal : des sessions régulières de QCM chronométrés, un carnet d'erreurs relu chaque semaine, et la vérification systématique de toute information chiffrée à la source officielle (CMA, annales).$mft$,
   $mft$Barème /5 : plan structuré dans le temps couvrant les trois volets (1,5 pt) ; contenu exact du tronc commun (cinq domaines) (1 pt) ; épreuve spécifique correctement identifiée selon la filière (0,5 pt) ; préparation de l'admission comme prestation client (1 pt) ; réflexe de vérification des modalités auprès de la CMA et des annales (1 pt). Erreurs fréquentes : négliger l'anglais et le français ; annoncer des barèmes ou notes éliminatoires précis sans source officielle.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-1','question-redigee'], 'TAXI-M1-QR-04', false,
   $mft$Un plan de préparation en trois mois, adossé aux sources officielles.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Cas pratique : titulaire d'une carte VTC, Medhi stationne chaque soir devant une gare et accepte les clients qui le hèlent, « pour rentabiliser ses heures creuses ». Analysez les infractions commises, l'éventail des risques (pénal, assurantiel, professionnel) et ce qu'il devrait mettre en place pour travailler légalement ces créneaux.$mft$,
   $mft$Réponse modèle. Les infractions : en chargeant des clients qui le hèlent devant la gare, Medhi pratique la maraude, monopole des taxis titulaires d'une ADS : sa carte VTC ne l'autorise qu'à exécuter des courses réservées à l'avance ; chaque prise en charge sans réservation constitue un exercice illégal du T3P. Les risques : au pénal, amendes, confiscation possible du véhicule (son outil de travail) et peines complémentaires ; les abords de gares sont précisément les lieux les plus contrôlés (police, unités spécialisées dans le contrôle du T3P, agents habilités). Au plan assurantiel : en cas d'accident avec un client pris en maraude, l'assureur peut refuser sa garantie, l'activité ne correspondant pas au cadre couvert : des dommages corporels resteraient à sa charge. Au plan professionnel : mise en péril de sa carte, réputation, exclusion possible des plateformes. Pour travailler légalement ses heures creuses : se positionner près des zones de demande MAIS n'accepter que des courses réservées (une commande passée sur l'application, même peu de temps avant la prise en charge, reste une réservation préalable), développer une clientèle d'habitués qui réserve en direct, ou viser à terme la filière taxi (examen spécifique, ADS) si la maraude correspond à son vrai modèle d'activité.$mft$,
   $mft$Barème /5 : qualification exacte (maraude, monopole taxi avec ADS, exercice illégal course par course) (1,5 pt) ; risques pénaux complets (amendes, confiscation possible, peines complémentaires) (1 pt) ; risque assurantiel expliqué (refus de garantie, dommages corporels) (1 pt) ; alternatives légales concrètes, dont la logique de réservation même rapprochée (1,5 pt). Erreurs fréquentes : croire que la carte VTC couvre « quelques courses » de maraude ; proposer comme solution de simples espèces non déclarées.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-1','question-redigee'], 'TAXI-M1-QR-05', false,
   $mft$Le VTC en maraude : qualification, risques en cascade, remise en conformité.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Trois candidats se présentent : Awa (permis B depuis 2 ans et demi, filière classique), Bilal (permis B depuis 2 ans et 2 mois, après conduite accompagnée), Chloé (permis B depuis 6 ans, condamnation récente inscrite au bulletin n° 2). Analysez la situation de chacun face aux conditions d'accès à la carte professionnelle et indiquez, le cas échéant, ce qu'ils peuvent faire.$mft$,
   $mft$Réponse modèle. Awa (2 ans et demi, filière classique) : la condition d'ancienneté est de 3 ans pour un permis obtenu par la voie classique ; elle ne la remplit pas encore. Ce n'est pas un refus définitif mais une question de calendrier : elle peut employer les mois restants à préparer les épreuves et déposer son dossier dès les 3 ans atteints. Bilal (2 ans et 2 mois, après conduite accompagnée) : pour les titulaires passés par la conduite accompagnée, l'ancienneté exigée est ramenée à 2 ans : il remplit la condition et peut avancer dès maintenant, sous réserve des autres exigences (aptitude médicale constatée par un médecin agréé, honorabilité, premiers secours selon les modalités en vigueur, à vérifier localement). Chloé (6 ans de permis, condamnation récente au bulletin n° 2) : l'ancienneté ne pose aucun problème, mais l'honorabilité est en jeu : si sa condamnation fait partie des condamnations incompatibles avec la profession, la carte lui sera refusée, quels que soient ses résultats à l'examen. Elle doit clarifier précisément sa situation avant d'engager des frais de préparation. Leçon générale : les conditions d'accès sont cumulatives ; une seule condition manquante bloque tout le dossier.$mft$,
   $mft$Barème /5 : Awa correctement analysée (3 ans en filière classique, stratégie d'attente utile) (1,5 pt) ; Bilal correctement analysé (réduction à 2 ans, autres conditions rappelées) (1,5 pt) ; Chloé correctement analysée (honorabilité, refus possible malgré l'examen, vérification préalable) (1,5 pt) ; conclusion sur le caractère cumulatif des conditions (0,5 pt). Erreurs fréquentes : appliquer les 2 ans à tous les candidats ; croire que la réussite de l'examen neutralise le bulletin n° 2.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-1','question-redigee'], 'TAXI-M1-QR-06', false,
   $mft$Trois profils, trois verdicts : les conditions d'accès appliquées.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Cartographiez les acteurs institutionnels et économiques du T3P (préfecture, CMA, mairie, plateformes) : précisez le rôle de chacun, puis indiquez à quel acteur un chauffeur s'adresse dans quatre situations : demander sa carte professionnelle, s'inscrire à l'examen, obtenir une autorisation de stationnement taxi, contester une course affectée par une application.$mft$,
   $mft$Réponse modèle. La préfecture est l'autorité de délivrance : elle instruit les demandes de carte professionnelle T3P (mention taxi ou VTC), vérifie les conditions d'accès (permis, aptitude médicale constatée par un médecin agréé, honorabilité au bulletin n° 2) et suit la vie de la carte. La chambre de métiers et de l'artisanat organise l'examen : inscriptions, sessions régulières d'admissibilité et d'admission, information officielle sur les modalités. La mairie gère les autorisations de stationnement (ADS) des taxis : sans ADS, pas de maraude, même avec une carte taxi valide. Les plateformes sont des acteurs économiques privés : mise en relation, portage de la réservation préalable, conditions commerciales ; elles n'ont aucun pouvoir sur la carte ni sur l'examen. Les quatre situations : demander sa carte : la préfecture ; s'inscrire à l'examen : la CMA ; obtenir une ADS : la mairie de la commune visée ; contester une course affectée : la plateforme elle-même (support, conditions contractuelles), car la relation est commerciale et privée. Retenez la logique d'ensemble : l'État autorise (préfecture), le réseau consulaire évalue (CMA), la commune attribue l'accès au domaine public (ADS), le privé met en relation. Se tromper de guichet, c'est un dossier qui repart de zéro et des semaines perdues.$mft$,
   $mft$Barème /5 : rôle exact des quatre acteurs (2 pts) ; les quatre situations correctement routées (2 pts) ; logique de synthèse (État/consulaire/commune/privé) ou coût d'une erreur de guichet (1 pt). Erreurs fréquentes : attribuer la carte à la CMA ; envoyer les litiges de plateforme vers la préfecture ; oublier que l'ADS est communale.$mft$,
   5, 'difficile', ARRAY['taxi-vtc','module-1','question-redigee'], 'TAXI-M1-QR-07', false,
   $mft$Le « qui fait quoi » du T3P appliqué à quatre démarches réelles.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un candidat vient d'échouer à l'épreuve d'admission (conduite avec mise en situation client) alors qu'il avait réussi l'admissibilité. Analysez ce que cette épreuve évalue réellement, les erreurs classiques qui la font échouer, et construisez son plan de remédiation jusqu'à la session suivante.$mft$,
   $mft$Réponse modèle. Ce que l'épreuve évalue : l'admission n'est pas un second permis B ; elle évalue un professionnel du transport de personnes en situation : une conduite sûre, souple et réglementaire, ET une prestation client complète : accueil, courtoisie, installation du passager, annonce et gestion du trajet, attitude face aux imprévus. Les erreurs classiques : traiter l'examinateur comme un inspecteur et non comme un client (silence, absence d'accueil) ; une conduite brusque ou hésitante trahissant le stress ; négliger la dimension service (pas de bonjour, aucune communication sur l'itinéraire) ; ou l'excès inverse, la sur-familiarité. Plan de remédiation : reconstituer un retour précis sur la prestation ratée et lister les points faibles ; s'entraîner en conditions réelles avec un passager jouant des profils variés (client pressé, client étranger anglophone, client silencieux) ; installer des rituels de prestation (accueil, vérification du confort, annonce du trajet) jusqu'à l'automatisme ; consolider la conduite avec un professionnel si nécessaire ; vérifier auprès de la CMA les modalités de repassage (calendrier, règles de conservation du bénéfice de l'admissibilité : ces points relèvent des règles en vigueur et se confirment à la source) ; puis se représenter avec deux ou trois mises en situation complètes par semaine jusqu'à la session.$mft$,
   $mft$Barème /5 : double nature de l'épreuve (conduite + prestation client) (1,5 pt) ; au moins trois erreurs classiques crédibles (1,5 pt) ; plan de remédiation concret et progressif (entraînement scénarisé, rituels, conduite) (1,5 pt) ; réflexe de vérification des modalités de repassage auprès de la CMA (0,5 pt). Erreurs fréquentes : réduire l'échec à la seule conduite ; inventer des règles de conservation de l'admissibilité sans les vérifier.$mft$,
   5, 'difficile', ARRAY['taxi-vtc','module-1','question-redigee'], 'TAXI-M1-QR-08', false,
   $mft$Échec à l'admission : diagnostic et plan de remédiation jusqu'à la session suivante.$mft$);

  RAISE NOTICE 'Module 1 Taxi/VTC créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $taxim1$;
