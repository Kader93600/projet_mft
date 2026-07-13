-- =====================================================================
-- FIMO / FCO MARCHANDISES : THÈME 4 : SERVICE, LOGISTIQUE ET IMAGE
-- v1 (juillet 2026) : LOT FIMO-5
-- Angle conducteur : ambassadeur de l'entreprise, livraison sans
-- litige, compréhension du marché du transport et de sa propre valeur.
-- ⚠ STATUT : active = false (« à valider »). Idempotent.
-- =====================================================================

DO $fimot4$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid;
  v_quiz uuid; v_q uuid; v_ord int := 0;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'fimo-fco';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation fimo-fco introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'FIMO-FCO';

  DELETE FROM public.question_bank WHERE source_ref LIKE 'FIMO-T4-%';
  DELETE FROM public.modules WHERE slug = 'fimo-t4-service-image';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Thème 4 : Service, logistique et image du métier',
    'fimo-t4-service-image', v_bloc,
    'Le conducteur, premier visage de l''entreprise : posture professionnelle, relation client, livraison sans litige, et compréhension du marché du transport pour situer sa propre valeur.',
    'debutant', 240, 50) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 50, true);

  -- ─── Leçon 1 : Le conducteur ambassadeur ───────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'conducteur-ambassadeur',
    'Vous êtes le visage de l''entreprise',
    $mft$> 🎯 **Objectifs**
> - Mesurer l'impact commercial direct de votre comportement.
> - Adopter les codes professionnels chez le client et sur la route.
> - Gérer un interlocuteur difficile sans dégrader la relation.

## Le seul salarié que le client voit

Le commercial signe le contrat une fois ; **vous**, le client vous voit à chaque livraison. Ponctualité, tenue, propreté du véhicule, politesse au quai : c'est là-dessus que le client juge l'entreprise entière : et qu'il renouvelle, ou pas. Dans un marché où les prestations se ressemblent, le conducteur EST la différence.

## Les codes qui comptent

| Moment | Le geste pro |
| --- | --- |
| Arrivée | À l'heure (ou l'exploitation a prévenu du retard AVANT), présentation au bon interlocuteur |
| Sur site | Consignes de sécurité du site respectées (vitesse, cheminements, EPI), zone laissée propre |
| Échanges | Politesse simple, vocabulaire correct, pas de commentaires sur les autres clients ni sur son entreprise |
| Sur la route | Conduite exemplaire : le camion floqué est une publicité roulante, dans les deux sens |
| Incident | On prévient, on ne « laisse pas découvrir » : l'exploitation d'abord, qui gère le client |

> ❌ **Piège à éviter**
> Le coup de klaxon rageur ou la queue de poisson avec la remorque floquée au nom de l'entreprise : des clients, des prospects et parfois l'employeur lui-même sont sur la même route. Les réseaux sociaux transforment chaque écart en vidéo.

## Gérer un interlocuteur difficile

Réceptionnaire agacé, gardien tatillon, client pressé : la méthode tient en quatre temps : **écouter** sans couper, **reformuler** le problème (« si je comprends bien, il vous manque deux palettes »), **agir dans son périmètre** (vérifier, appeler l'exploitation) et **ne jamais promettre** ce qui ne dépend pas de vous (remise, re-livraison gratuite : c'est le rôle du commercial). La fermeté polie (« je ne peux pas signer cela, mais voilà ce que je peux faire ») protège tout le monde.

## Ce que l'image rapporte (et coûte)

Un client satisfait renouvelle et recommande ; un client froissé consulte la concurrence dès l'appel d'offres suivant. Côté conducteur : la réputation individuelle circule vite dans le secteur : les exploitations se souviennent des conducteurs « sans histoires » au moment des promotions, des tournées premium et des embauches.

## ✅ Synthèse

- Vous êtes le **contact le plus fréquent** du client : ponctualité, tenue, politesse, site respecté.
- Interlocuteur difficile : **écouter, reformuler, agir dans son périmètre, ne rien promettre** hors périmètre.
- Le camion floqué engage l'entreprise sur la route ; votre réputation VOUS suit.$mft$,
    $mft$L'impact commercial du conducteur (seul salarié vu à chaque livraison), les codes professionnels par moment, la méthode en quatre temps face à l'interlocuteur difficile et la valeur de la réputation.$mft$,
    1, 30) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : La livraison sans litige ────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'livraison-sans-litige',
    'La livraison sans litige',
    $mft$> 🎯 **Objectifs**
> - Dérouler une livraison qui ne génère ni litige ni impayé.
> - Traiter les cas dégradés : absent, refus, quantité contestée.
> - Comprendre ce que coûte un litige et comment vos gestes l'évitent.

## La livraison parfaite en six gestes

:::flow
1. Préparer | Bon de livraison et LV prêts, marchandise du client identifiée
2. Se présenter | Bon interlocuteur, consignes du site
3. Décharger | Selon le protocole du site, marchandise comptée ENSEMBLE
4. Faire constater | Le réceptionnaire vérifie quantité et état AVANT signature
5. Faire émarger | Nom, date, heure, signature (et cachet si demandé)
6. Consigner | Réserves éventuelles notées précisément, photos, exploitation informée
:::

Le point 4 est votre assurance : une marchandise **comptée ensemble** ne se conteste plus « après coup ».

## Les cas dégradés

- **Destinataire absent ou site fermé** : ne JAMAIS livrer « au voisin » ou déposer sans instruction : appel à l'exploitation qui décide (attente, report, retour) : une marchandise déposée sans émargement est une marchandise juridiquement non livrée.
- **Refus partiel ou total** : noter le motif exact déclaré, faire écrire le refus sur la LV, ne pas négocier soi-même : la marchandise refusée reste sous VOTRE garde : instructions de l'exploitation (retour, autre destinataire).
- **Écart de quantité contesté** : recompter ensemble, calmement ; si le désaccord persiste : mention précise des deux comptages sur la LV, photos, exploitation en copie le jour même.
- **Dommage découvert au déchargement** : laisser le réceptionnaire formuler SES réserves écrites (c'est son droit), photographier, ne rien reconnaître : les faits, pas les conclusions (l'assureur et les contrats types feront le tri).

> 📌 **À retenir**
> Vos ennemis dans les litiges : l'oral (tout ce qui n'est pas écrit n'existe pas), la précipitation (le comptage sauté), et la « gentillesse » mal placée (livrer sans émargement « pour dépanner »). Vos alliés : la LV bien tenue, le téléphone (photos + exploitation), et la constance.
 
## Ce qu'un litige coûte vraiment

Un litige moyen mobilise l'exploitation, le commercial et parfois un juriste sur des semaines ; l'indemnisation éventuelle ampute la marge de plusieurs tournées ; et le client échaudé re-consulte. Vos trente secondes de comptage et d'émargement sont l'assurance la moins chère de l'entreprise.

## ✅ Synthèse

- Livraison : **compter ensemble, faire constater, faire émarger, consigner** : dans cet ordre.
- Cas dégradés : jamais de dépôt sans instruction, refus par écrit, écarts documentés, **rien reconnaître**.
- L'écrit protège ; l'oral coûte ; l'exploitation s'informe LE JOUR MÊME.$mft$,
    $mft$La livraison en six gestes (compter ensemble, faire émarger), les quatre cas dégradés (absent, refus, écart, dommage) traités par l'écrit, et le coût réel d'un litige.$mft$,
    2, 35) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : Le marché du transport et votre place ───────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'marche-transport-votre-place',
    'Le marché du transport et votre place dedans',
    $mft$> 🎯 **Objectifs**
> - Situer les acteurs de la chaîne et leurs attentes.
> - Comprendre les grands segments d'activité et leurs exigences.
> - Relier votre conduite quotidienne à l'économie de l'entreprise.

## La chaîne autour de votre camion

Le **chargeur** (industriel, distributeur) a un besoin de transport ; il traite en direct avec un **transporteur**, ou passe par un **commissionnaire** qui organise et sous-traite ; des **plateformes logistiques** massifient et redistribuent ; le **destinataire** réceptionne. Votre entreprise peut être transporteur principal ou **sous-traitant** (tractionnaire) : dans les deux cas, VOUS êtes au bout de la chaîne, là où la promesse se tient : ou se casse.

## Les grands segments et leurs exigences

| Segment | Ce qui compte le plus |
| --- | --- |
| Lot complet (un client, un camion) | Ponctualité, arrimage, relation directe |
| Messagerie / palettes (tournées multi-clients) | Cadence, exactitude des livraisons, LV irréprochables |
| Frigorifique | Chaîne du froid : températures relevées et tracées |
| Vrac / benne | Propreté des bennes, pesées, sites exigeants |
| Distribution urbaine | Créneaux courts, ZFE, riverains, angles morts |

Changer de segment, c'est changer de « règles du jeu » : le professionnel s'adapte vite parce qu'il comprend ce qui compte pour CE client.

## L'économie vue de la cabine

Rappel utile : le camion qui roule coûte (gazole, péages, entretien) et ne gagne que s'il roule **chargé, à l'heure, sans litige et sans casse**. Votre part dans la marge est directe :

- la **consommation** (thème 1) : plusieurs milliers d'euros d'écart par an entre conducteurs ;
- les **litiges évités** (leçon 2) : marge préservée, client conservé ;
- la **casse et les sinistres** : franchises, malus, immobilisations ;
- l'**image** (leçon 1) : renouvellements et recommandations ;
- le **retour d'information terrain** : attentes réelles chez les clients, créneaux impossibles, accès dangereux : l'exploitation cote mieux avec vos remontées.

> 💡 **Astuce**
> Le conducteur qui comprend « pourquoi » (marges serrées, clients volatils, gazole indexé) devient force de proposition : et c'est exactement le profil que les entreprises promeuvent vers les postes de formateur interne, de conducteur référent ou d'exploitation.

## ✅ Synthèse

- Chaîne : **chargeur → (commissionnaire) → transporteur → vous** ; la promesse se tient au dernier maillon.
- Chaque segment a SA priorité (froid, cadence, ponctualité) : l'identifier, s'y adapter.
- Votre valeur économique : **conso + zéro litige + zéro casse + image + remontées terrain**.$mft$,
    $mft$Les acteurs de la chaîne (chargeur, commissionnaire, transporteur, sous-traitant), les segments et leurs exigences propres, et la contribution économique directe du conducteur.$mft$,
    3, 30) RETURNING id INTO v_l3;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : Service et image',
    'Vérifiez le thème 4 : posture professionnelle, livraison sans litige, marché du transport.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Pourquoi dit-on que le conducteur est « le visage de l'entreprise » ?$mft$,
    $mft$[
      {"id":"a","label":"Parce qu'il est le salarié que le client voit le plus souvent : son comportement détermine l'image de toute l'entreprise","is_correct":true},
      {"id":"b","label":"Parce que sa photo figure sur les documents de transport","is_correct":false},
      {"id":"c","label":"Parce qu'il fixe les tarifs avec le client","is_correct":false},
      {"id":"d","label":"Parce qu'il signe les contrats commerciaux","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['fimo-fco','theme-4','qcm-v1'], 'FIMO-T4-QCM-01', false,
    $mft$Le commercial signe une fois, le conducteur livre chaque semaine : ponctualité, tenue et politesse pèsent directement sur le renouvellement des contrats.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Le destinataire est absent et le site fermé. Que faites-vous de la marchandise ?$mft$,
    $mft$[
      {"id":"a","label":"Vous appelez l'exploitation et suivez ses instructions : jamais de dépôt sans émargement","is_correct":true},
      {"id":"b","label":"Vous la déposez devant le portail avec une photo","is_correct":false},
      {"id":"c","label":"Vous la confiez à l'entreprise voisine","is_correct":false},
      {"id":"d","label":"Vous la rapportez chez vous pour la nuit","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['fimo-fco','theme-4','qcm-v1'], 'FIMO-T4-QCM-02', false,
    $mft$Sans émargement, la marchandise est juridiquement non livrée : dépôt sauvage = litige garanti. L'exploitation décide (attente, report, retour).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Quel acteur organise un transport pour le compte d'un client et le sous-traite à des transporteurs ?$mft$,
    $mft$[
      {"id":"a","label":"Le commissionnaire de transport","is_correct":true},
      {"id":"b","label":"Le destinataire","is_correct":false},
      {"id":"c","label":"Le gardien de la plateforme","is_correct":false},
      {"id":"d","label":"L'expert de l'assureur","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['fimo-fco','theme-4','qcm-v1'], 'FIMO-T4-QCM-03', false,
    $mft$Le commissionnaire organise librement l'acheminement pour son client et fait exécuter par des transporteurs : votre entreprise est parfois son sous-traitant (tractionnaire).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Avant de faire signer la lettre de voiture à la livraison, le geste clé est :$mft$,
    $mft$[
      {"id":"a","label":"Compter et vérifier la marchandise ENSEMBLE avec le réceptionnaire","is_correct":true},
      {"id":"b","label":"Faire signer d'abord, vérifier ensuite","is_correct":false},
      {"id":"c","label":"Laisser le réceptionnaire vérifier seul après votre départ","is_correct":false},
      {"id":"d","label":"Photographier la signature du réceptionnaire","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['fimo-fco','theme-4','qcm-v1'], 'FIMO-T4-QCM-04', false,
    $mft$Une marchandise comptée ensemble avant émargement ne se conteste plus « après coup » : c'est le geste anti-litige numéro un.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Un réceptionnaire furieux vous reproche deux palettes manquantes. Quelle est la bonne séquence ?$mft$,
    $mft$[
      {"id":"a","label":"Écouter, reformuler le problème, vérifier/recompter, appeler l'exploitation : sans rien promettre hors de votre périmètre","is_correct":true},
      {"id":"b","label":"Promettre une re-livraison gratuite pour calmer la situation","is_correct":false},
      {"id":"c","label":"Répondre sur le même ton pour ne pas perdre la face","is_correct":false},
      {"id":"d","label":"Partir immédiatement : ce n'est pas votre problème","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','theme-4','qcm-v1'], 'FIMO-T4-QCM-05', false,
    $mft$Écouter, reformuler, agir dans son périmètre, ne rien promettre qui appartient au commercial : la fermeté polie protège la relation ET l'entreprise.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Le destinataire refuse la moitié de la marchandise « trop tard livrée ». Que devient la partie refusée ?$mft$,
    $mft$[
      {"id":"a","label":"Elle reste sous votre garde : refus écrit sur la LV et instructions de l'exploitation (retour, re-livraison)","is_correct":true},
      {"id":"b","label":"Vous la laissez sur le quai du client","is_correct":false},
      {"id":"c","label":"Vous la vendez pour couvrir les frais","is_correct":false},
      {"id":"d","label":"Vous la jetez si elle est périssable","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','theme-4','qcm-v1'], 'FIMO-T4-QCM-06', false,
    $mft$Marchandise refusée = toujours sous la garde du transporteur : motif écrit, exploitation informée, instructions suivies. L'abandon sur quai engage votre responsabilité.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$En transport frigorifique, quelle exigence domine toutes les autres ?$mft$,
    $mft$[
      {"id":"a","label":"Le respect et la traçabilité de la chaîne du froid (températures relevées)","is_correct":true},
      {"id":"b","label":"La vitesse de livraison avant tout","is_correct":false},
      {"id":"c","label":"Le lavage extérieur quotidien du véhicule","is_correct":false},
      {"id":"d","label":"Le nombre de palettes par voyage","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','theme-4','qcm-v1'], 'FIMO-T4-QCM-07', false,
    $mft$Chaque segment a SA priorité : en frigo, une rupture de chaîne du froid détruit la marchandise et la confiance : relevés et alertes de température font partie du métier.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Vous allez arriver avec 40 minutes de retard chez un client. Le bon réflexe :$mft$,
    $mft$[
      {"id":"a","label":"Prévenir l'exploitation dès que le retard est certain, pour que le client soit informé AVANT votre arrivée","is_correct":true},
      {"id":"b","label":"Arriver et s'excuser sur place","is_correct":false},
      {"id":"c","label":"Rattraper le retard en roulant plus vite","is_correct":false},
      {"id":"d","label":"Appeler le client directement pour négocier","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','theme-4','qcm-v1'], 'FIMO-T4-QCM-08', false,
    $mft$Un retard annoncé s'organise (créneau recalé, quai libéré) ; un retard découvert s'envenime. Et on ne « rattrape » jamais au détriment de la sécurité ou des temps de conduite.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Au déchargement, le réceptionnaire découvre un carton écrasé et veut noter une réserve. Votre attitude :$mft$,
    $mft$[
      {"id":"a","label":"Le laisser formuler SA réserve écrite précise, photographier, ne rien reconnaître : les faits, pas les conclusions","is_correct":true},
      {"id":"b","label":"Refuser qu'il écrive quoi que ce soit sur la LV","is_correct":false},
      {"id":"c","label":"Écrire vous-même « erreur du chargeur » pour l'orienter","is_correct":false},
      {"id":"d","label":"Reconnaître par écrit que c'est votre faute pour clore le sujet","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','theme-4','qcm-v1'], 'FIMO-T4-QCM-09', false,
    $mft$La réserve du destinataire est son droit ; votre rôle : précision des faits, photos, aucune reconnaissance de responsabilité : assureur et contrats types qualifieront.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Votre entreprise roule comme « tractionnaire ». Qu'est-ce que cela signifie ?$mft$,
    $mft$[
      {"id":"a","label":"Elle exécute des transports en sous-traitance pour un donneur d'ordre (commissionnaire ou autre transporteur)","is_correct":true},
      {"id":"b","label":"Elle ne transporte que des tracteurs agricoles","is_correct":false},
      {"id":"c","label":"Elle loue ses véhicules sans conducteurs","is_correct":false},
      {"id":"d","label":"Elle n'a pas besoin de licence de transport","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['fimo-fco','theme-4','qcm-v1'], 'FIMO-T4-QCM-10', false,
    $mft$Le tractionnaire tire des remorques/lots pour un donneur d'ordre qui garde la relation client. Licence et règles restent pleinement applicables : la sous-traitance ne dispense de rien.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Parmi ces comportements, lequel contribue DIRECTEMENT à la marge de l'entreprise ?$mft$,
    $mft$[
      {"id":"a","label":"Livrer sans litige, consommer sobrement et éviter la casse","is_correct":true},
      {"id":"b","label":"Rouler au maximum de la vitesse autorisée en permanence","is_correct":false},
      {"id":"c","label":"Sauter les pauses pour livrer plus de clients","is_correct":false},
      {"id":"d","label":"Économiser le lave-glace et les ampoules","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['fimo-fco','theme-4','qcm-v1'], 'FIMO-T4-QCM-11', false,
    $mft$Conso, litiges, casse : les trois postes où le conducteur pèse des milliers d'euros par an. Vitesse maximale et pauses sautées produisent l'inverse (conso, risque, infractions).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Sur un site client, le gardien vous impose un cheminement piéton qui rallonge de cinq minutes. Vous êtes pressé. Que faites-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Vous respectez la consigne du site : ses règles de sécurité s'imposent à vous","is_correct":true},
      {"id":"b","label":"Vous coupez au plus court : cinq minutes comptent","is_correct":false},
      {"id":"c","label":"Vous négociez une exception avec le cariste","is_correct":false},
      {"id":"d","label":"Vous restez dans la cabine tant que le gardien regarde","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['fimo-fco','theme-4','qcm-v1'], 'FIMO-T4-QCM-12', false,
    $mft$Chez le client, ses consignes de sécurité font loi (protocole de sécurité) : les transgresser expose à l'accident, à l'exclusion du site et dégrade l'image de votre entreprise.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l2, 'qr',
   $mft$Quel geste, effectué AVEC le réceptionnaire avant la signature, prévient l'essentiel des litiges de livraison ?$mft$,
   $mft$Compter et vérifier la marchandise ensemble avant l'émargement.$mft$,
   2, 'facile', ARRAY['fimo-fco','theme-4','question-courte'], 'FIMO-T4-QC-01', false,
   $mft$Le comptage contradictoire.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Comment appelle-t-on le transporteur qui exécute des transports en sous-traitance pour un donneur d'ordre ?$mft$,
   $mft$Un tractionnaire (sous-traitant).$mft$,
   2, 'facile', ARRAY['fimo-fco','theme-4','question-courte'], 'FIMO-T4-QC-02', false,
   $mft$La relation client reste chez le donneur d'ordre.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Citez trois éléments de votre présentation qui pèsent sur l'image de l'entreprise chez le client.$mft$,
   $mft$Par exemple : la ponctualité, la tenue correcte, la politesse, la propreté du véhicule, le respect des consignes du site.$mft$,
   2, 'facile', ARRAY['fimo-fco','theme-4','question-courte'], 'FIMO-T4-QC-03', false,
   $mft$Trois éléments distincts.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Pourquoi ne faut-il jamais déposer une marchandise sans émargement, même « pour dépanner » ?$mft$,
   $mft$Parce que sans émargement la livraison n'est pas prouvée : la marchandise est juridiquement non livrée et le litige (perte, vol, contestation) retombe sur le transporteur.$mft$,
   2, 'moyen', ARRAY['fimo-fco','theme-4','question-courte'], 'FIMO-T4-QC-04', false,
   $mft$L'émargement est LA preuve de livraison.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Face à un interlocuteur difficile, rappelez la méthode en quatre temps.$mft$,
   $mft$Écouter sans couper, reformuler le problème, agir dans son périmètre (vérifier, appeler l'exploitation), ne rien promettre hors de son périmètre.$mft$,
   2, 'moyen', ARRAY['fimo-fco','theme-4','question-courte'], 'FIMO-T4-QC-05', false,
   $mft$Les quatre temps dans l'ordre.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Le destinataire refuse une partie de la marchandise : citez les deux gestes documentaires immédiats.$mft$,
   $mft$Faire écrire le refus et son motif sur la lettre de voiture, et informer l'exploitation (qui donne les instructions pour la marchandise restée sous votre garde).$mft$,
   2, 'moyen', ARRAY['fimo-fco','theme-4','question-courte'], 'FIMO-T4-QC-06', false,
   $mft$Refus écrit + exploitation.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Citez trois segments du transport routier de marchandises et l'exigence dominante de chacun.$mft$,
   $mft$Par exemple : frigorifique (chaîne du froid tracée), messagerie (cadence et exactitude), lot complet (ponctualité et arrimage), distribution urbaine (créneaux et angles morts), vrac (propreté et pesées).$mft$,
   2, 'moyen', ARRAY['fimo-fco','theme-4','question-courte'], 'FIMO-T4-QC-07', false,
   $mft$Trois couples segment/exigence cohérents.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Un retard de 45 minutes devient certain à 9 h pour une livraison à 10 h. Que faites-vous à 9 h ?$mft$,
   $mft$Prévenir immédiatement l'exploitation, qui informe le client et recale le créneau : jamais « rattraper » en roulant plus vite.$mft$,
   2, 'moyen', ARRAY['fimo-fco','theme-4','question-courte'], 'FIMO-T4-QC-08', false,
   $mft$L'alerte précoce transforme le retard en réorganisation.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Citez les trois postes économiques principaux sur lesquels un conducteur influe directement.$mft$,
   $mft$La consommation de carburant, les litiges de livraison, la casse et les sinistres (auxquels s'ajoutent l'image et les remontées terrain).$mft$,
   2, 'difficile', ARRAY['fimo-fco','theme-4','question-courte'], 'FIMO-T4-QC-09', false,
   $mft$Conso + litiges + casse attendus.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Pourquoi ne devez-vous jamais écrire vous-même la cause probable d'un dommage (« erreur du chargeur ») sur la LV à la livraison ?$mft$,
   $mft$Parce que la LV consigne des FAITS constatés, pas des conclusions : attribuer une cause engage sans preuve et sera opposé à l'entreprise ; la qualification appartient à l'assureur et aux règles applicables.$mft$,
   2, 'difficile', ARRAY['fimo-fco','theme-4','question-courte'], 'FIMO-T4-QC-10', false,
   $mft$Faits oui, conclusions non : même logique que le constat.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$« Le commercial gagne le contrat, le conducteur le garde. » Développez cette affirmation : par quels comportements concrets le conducteur fait-il renouveler (ou perdre) un client ?$mft$,
   $mft$Réponse modèle. Ce qui fait renouveler : la ponctualité récurrente (ou le retard TOUJOURS annoncé à l'avance), la marchandise livrée complète et intacte, comptée ensemble, une LV impeccable qui évite au client tout litige administratif, le respect visible des consignes de son site (sécurité, propreté, cheminements), la courtoisie constante avec ses équipes de quai, et la remontée utile d'informations (accès difficile, créneau saturé) qui améliore le service. Ce qui fait perdre : les retards subis sans prévenance, les litiges à répétition (écarts non documentés, dommages contestés), le non-respect du site (vitesse, zones interdites : certains clients excluent nommément des conducteurs), l'attitude (agressivité, commentaires déplacés), et l'image extérieure (conduite dangereuse du camion floqué, vidéos sur les réseaux). Mécanisme économique : le client compare à chaque appel d'offres ; à prix proches, l'expérience vécue tranche : le conducteur est donc l'argument commercial permanent de l'entreprise : et sa propre réputation professionnelle suit la même logique.$mft$,
   $mft$Barème /5 : au moins quatre comportements fidélisants concrets (2 pts) ; au moins trois comportements destructeurs (1,5 pt) ; mécanisme économique du renouvellement (1 pt) ; dimension réputation personnelle (0,5 pt). Erreurs fréquentes : rester sur des généralités (« être poli ») sans gestes concrets.$mft$,
   5, 'facile', ARRAY['fimo-fco','theme-4','question-redigee'], 'FIMO-T4-QR-01', false,
   $mft$L'impact commercial du conducteur, argumenté et concret.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Déroulez la livraison parfaite en six gestes, puis montrez sur DEUX cas dégradés (destinataire absent ; écart de quantité contesté) comment la méthode protège l'entreprise.$mft$,
   $mft$Réponse modèle. Les six gestes : 1) préparer (documents prêts, marchandise identifiée) ; 2) se présenter au bon interlocuteur et respecter les consignes du site ; 3) décharger selon le protocole ; 4) faire constater : compter et examiner ENSEMBLE ; 5) faire émarger (nom, date, heure, signature) ; 6) consigner réserves et incidents, photos, exploitation informée le jour même. Cas 1 : destinataire absent : la méthode interdit le dépôt sans émargement (geste 5 impossible = pas de livraison) : appel à l'exploitation qui décide : attente, report, retour ; trace écrite de l'absence (heure, photo du site fermé) : l'entreprise peut facturer l'immobilisation et re-planifier, sans risque de « marchandise disparue ». Cas 2 : écart contesté (le client annonce 46 colis reçus pour 48 annoncés) : le comptage CONTRADICTOIRE du geste 4 règle la question à la source : recompter ensemble ; si le désaccord persiste : les deux comptages consignés sur la LV, photos des palettes, exploitation informée immédiatement : le litige éventuel se traite sur des faits documentés datés du jour, pas sur des souvenirs opposés une semaine après. Conclusion : chaque geste produit une preuve ; la série complète rend le litige soit impossible, soit gagnable.$mft$,
   $mft$Barème /5 : six gestes exacts et ordonnés (2 pts) ; cas absent traité sans dépôt + trace (1,5 pt) ; cas écart traité par comptage contradictoire + double consignation (1,5 pt). Erreurs fréquentes : émargement avant vérification ; « dépannage » sans instruction.$mft$,
   5, 'facile', ARRAY['fimo-fco','theme-4','question-redigee'], 'FIMO-T4-QR-02', false,
   $mft$La méthode de livraison éprouvée sur deux cas dégradés.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Jeu de rôle écrit. Sur le quai, un réceptionnaire excédé vous lance : « Vous êtes encore en retard, votre boîte est nulle, je vais tout refuser ! » Il est 10 h 20, le créneau était 9 h 30-10 h, le retard vient d'un accident sur l'autoroute (exploitation prévenue à 9 h). Rédigez votre réponse dialoguée et vos actions, dans l'esprit de la méthode.$mft$,
   $mft$Réponse modèle (esprit attendu). Écouter sans couper, puis : « Je comprends, votre organisation était calée sur 9 h 30 et vous attendez depuis presque une heure » (reformulation, reconnaissance du désagrément SANS dénigrer son entreprise ni sur-promettre). Factualiser calmement : « Un accident bloquait l'A6 ; notre exploitation vous a signalé le retard à 9 h : je suis là maintenant et je peux décharger immédiatement si vous m'ouvrez un quai. » Agir dans son périmètre : proposer le déchargement immédiat, compter ensemble, soigner particulièrement la LV. Si la menace de refus persiste : ne pas négocier commercialement (« je ne peux pas décider d'un geste commercial, mais je peux appeler mon exploitation tout de suite pour que vous ayez un interlocuteur ») : appel devant lui : le client entend que sa réclamation est prise au sérieux. En cas de refus effectif : motif écrit sur la LV, marchandise sous garde, instructions. Après coup : compte rendu factuel à l'exploitation (heure, échanges, décision) pour le suivi commercial. Ce qui est évalué : le calme, l'absence de dénigrement et de promesse hors périmètre, la proposition d'action immédiate, l'escalade PROPRE vers l'exploitation.$mft$,
   $mft$Barème /5 : reformulation et reconnaissance du désagrément (1 pt) ; factualisation sans dénigrer ni sur-promettre (1,5 pt) ; action immédiate proposée + escalade propre à l'exploitation (1,5 pt) ; gestion du refus éventuel et compte rendu (1 pt). Erreurs fréquentes : s'excuser en accablant sa propre entreprise ; promettre un geste commercial.$mft$,
   5, 'moyen', ARRAY['fimo-fco','theme-4','question-redigee'], 'FIMO-T4-QR-03', false,
   $mft$Conflit de quai scénarisé : la méthode en dialogue.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Votre entreprise vous fait passer de la messagerie (tournées de 25 points) au lot complet frigorifique international. Comparez ce qui change dans votre quotidien et les nouvelles priorités à maîtriser.$mft$,
   $mft$Réponse modèle. Rythme et organisation : la messagerie vit à la cadence (25 émargements, gestion du temps par arrêt, LV en série, urbain dense) ; le lot complet frigo international vit au long cours : un client au bout, mais des heures de route, découchés, passages de frontière : la gestion des temps de conduite et de repos devient l'enjeu central (semaines type, retour toutes les 3-4 semaines). Marchandise : en frigo, la chaîne du froid domine tout : température consignée au chargement, groupe surveillé en route, relevés/tickets conservés, alarmes traitées immédiatement ; une rupture = marchandise détruite et litige majeur : les réserves et contrôles au chargement (température À CŒUR annoncée, pré-refroidissement de la caisse) deviennent des réflexes. Relation client : moins d'interlocuteurs mais des enjeux unitaires plus lourds (une remorque complète) : rigueur documentaire absolue (CMR à l'international, scellés, protocoles d'usine). Compétences à monter : réglementation internationale (cabotage, détachement le cas échéant), gestion du groupe frigorifique, itinéraires et parkings sécurisés longue distance, anglais fonctionnel de quai. Constante : les fondamentaux (comptage, émargement, réserves, image) restent identiques : c'est le contexte qui se durcit.$mft$,
   $mft$Barème /5 : bascule rythme/organisation (cadence vs long cours, RSE centrale) (1,5 pt) ; exigences frigo précises (pré-refroidissement, relevés, alarmes) (1,5 pt) ; dimension internationale (CMR, découchés, parkings) (1 pt) ; constantes documentaires identifiées (1 pt). Erreurs fréquentes : réduire le changement au « plus long » ; ignorer la traçabilité du froid.$mft$,
   5, 'moyen', ARRAY['fimo-fco','theme-4','question-redigee'], 'FIMO-T4-QR-04', false,
   $mft$Changement de segment : nouvelles règles du jeu comparées.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Reconstituez un litige évitable : la semaine dernière, un collègue a livré 33 palettes « comptées vite fait », émargement griffonné sans nom, deux palettes retrouvées manquantes trois jours après, client furieux, indemnisation en cours. Identifiez chaque faille, son coût, et la version corrigée de la même livraison.$mft$,
   $mft$Réponse modèle. Failles : 1) comptage non contradictoire (« vite fait ») : personne ne peut prouver 33 ou 31 palettes à la remise : le doute profite au réclamant ; 2) émargement sans identité lisible ni heure : la signature ne rattache la réception à personne : contestable ; 3) aucune réserve ni photo : rien ne fige l'état à la livraison ; 4) découverte à J+3 : sans preuves initiales, l'écart de trois jours (vols internes ? erreurs d'inventaire du client ?) devient indémontrable : l'entreprise paie. Coûts : l'indemnisation des deux palettes, des heures d'exploitation et de commercial sur le dossier, la confiance du client entamée : le tout pour 90 secondes économisées au quai. Version corrigée : annonce du nombre AVANT déchargement (« 33 palettes, on compte ensemble »), pointage contradictoire ligne à ligne, émargement complet exigé (nom lisible, date, HEURE, signature : « c'est la procédure, elle vous protège aussi »), photo de la pile déchargée en cas de moindre doute, transmission de la LV le soir même. Avec ce déroulé, la réclamation de J+3 se réfute en deux minutes : LV opposable, comptage contradictoire daté.$mft$,
   $mft$Barème /5 : les quatre failles identifiées avec leur mécanisme (2 pts) ; coûts complets au-delà de l'indemnisation (1 pt) ; version corrigée geste à geste (1,5 pt) ; formulation client de l'exigence d'émargement (0,5 pt). Erreurs fréquentes : accuser le client sans traiter les failles internes ; corriger seulement l'émargement.$mft$,
   5, 'moyen', ARRAY['fimo-fco','theme-4','question-redigee'], 'FIMO-T4-QR-05', false,
   $mft$Autopsie d'un litige : failles, coûts, gestes corrigés.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Schématisez la chaîne d'un flux réel : un industriel de Meaux vend 28 palettes à un distributeur de Lyon ; il confie l'organisation à un commissionnaire, qui affrète votre entreprise ; vous êtes le conducteur. Identifiez chaque acteur, ses attentes, et à qui vous adressez chaque problème (retard, avarie, attente au déchargement).$mft$,
   $mft$Réponse modèle. Chaîne : l'industriel de Meaux = expéditeur/chargeur (client final du commissionnaire) ; le commissionnaire = organisateur, donneur d'ordre de votre entreprise ; votre entreprise = transporteur exécutant (affrété) ; le distributeur de Lyon = destinataire ; vous = conducteur, dernier maillon où la promesse se réalise. Attentes : l'expéditeur veut un enlèvement à l'heure et une LV propre ; le commissionnaire veut une exécution sans vague qui préserve SON client ; votre exploitation veut la conformité (temps, documents) et l'information en continu ; le destinataire veut son créneau, ses 28 palettes complètes et intactes. Routage des problèmes : TOUT passe par VOTRE exploitation (jamais en direct au commissionnaire ni au client final, sauf consigne expresse) : retard : exploitation immédiatement, qui prévient le commissionnaire, qui gère le destinataire ; avarie constatée : réserves/photos + exploitation (la chaîne des responsabilités transporteur/commissionnaire se règle entre entreprises) ; attente excessive au déchargement : heures d'arrivée/départ consignées sur la LV + exploitation (facturation éventuelle par le commissionnaire à son client). Leçon : dans un flux affrété, le conducteur applique une règle simple : documenter tout, remonter tout à SA hiérarchie, ne rien négocier en direct.$mft$,
   $mft$Barème /5 : chaîne complète et rôles exacts (1,5 pt) ; attentes par acteur (1,5 pt) ; routage systématique via l'exploitation pour les trois problèmes (1,5 pt) ; leçon de posture du conducteur affrété (0,5 pt). Erreurs fréquentes : faire négocier le conducteur avec le commissionnaire ; confondre destinataire et client du transporteur.$mft$,
   5, 'difficile', ARRAY['fimo-fco','theme-4','question-redigee'], 'FIMO-T4-QR-06', false,
   $mft$Le flux affrété décomposé : acteurs, attentes, routage des problèmes.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Votre exploitation reçoit la réclamation suivante d'un client important : « votre conducteur a traversé notre entrepôt hors des passages piétons, a répondu sèchement au chef de quai, et son camion bloquait la zone pompiers ». C'est vous. Analysez chaque grief, ce qu'il révèle, et construisez votre réponse professionnelle (envers l'exploitation ET lors du retour chez ce client).$mft$,
   $mft$Réponse modèle. Analyse des griefs : 1) cheminement hors passages : infraction aux consignes du site (protocole de sécurité) : risque réel (chariots) ET motif d'exclusion du site : indéfendable, même « pour gagner du temps » ; 2) réponse sèche au chef de quai : dégradation relationnelle chez un client important : quelle qu'ait été la provocation, la méthode (écouter, reformuler, périmètre) n'a pas été appliquée ; 3) stationnement zone pompiers : faute de sécurité objective, potentiellement grave (accès secours) : la précipitation explique, n'excuse pas. Ce que l'accumulation révèle : une livraison faite « contre la montre » : le problème racine est peut-être un créneau intenable : à objectiver. Réponse à l'exploitation : reconnaître les faits sans se défausser, les resituer (planning du jour, attente préalable ?), proposer soi-même les corrections : c'est la posture qui préserve la confiance ; demander si besoin un échange sur les créneaux de ce client. Au retour chez le client : arriver irréprochable (consignes, stationnement validé au gardien), un mot simple et digne au chef de quai (« la dernière fois, j'étais sous pression, ce n'était pas correct ») : sans plate excuse interminable ; puis la constance sur la durée : c'est elle qui répare. Leçon : trois « petits » écarts un jour de bourre = une réclamation officielle chez un compte clé : la rigueur ne se module pas selon le stress.$mft$,
   $mft$Barème /5 : analyse lucide des trois griefs sans minimisation (1,5 pt) ; identification de la cause racine possible (créneau/pression) à objectiver (1 pt) ; réponse à l'exploitation : reconnaissance + propositions (1,25 pt) ; réparation chez le client : gestes concrets et constance (1,25 pt). Erreurs fréquentes : contester les faits en bloc ; sur-promettre ; ignorer la zone pompiers (le grief le plus grave).$mft$,
   5, 'difficile', ARRAY['fimo-fco','theme-4','question-redigee'], 'FIMO-T4-QR-07', false,
   $mft$Réclamation client nominative : lucidité, réponse interne, réparation.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Après deux ans de conduite, vous visez une évolution (conducteur référent, formateur interne, exploitation). Construisez votre dossier : les preuves chiffrées et comportementales à réunir dès maintenant, et comment le thème 4 s'y traduit concrètement.$mft$,
   $mft$Réponse modèle. Preuves chiffrées (les indicateurs existent, autant qu'ils travaillent pour vous) : consommation télématique dans le haut du classement et STABLE ; zéro (ou taux minimal) de litiges de livraison sur la période : LV propres, réserves documentées ; sinistralité nulle ou bénigne ; ponctualité et régularité (peu d'incidents planning imputables) ; conformité sociale irréprochable (analyses tachy sans infraction récurrente). Preuves comportementales : remontées terrain utiles et écrites (accès, créneaux, risques signalés à l'exploitation), remerciements ou absence de réclamations chez les clients réguliers, aide effective aux nouveaux (parrainage informel : le futur référent se voit déjà), participation active aux causeries sécurité. Traduction du thème 4 : demander un retour formalisé à l'exploitation une fois par an (entretien : mes indicateurs, mes axes) ; se former en continu (FCO investie et pas subie, ADR ou CACES additionnels) ; soigner LA compétence différenciante des postes visés : expliquer calmement (au client, au collègue) : c'est le cœur du métier de référent/formateur. Dossier final : une page d'indicateurs + exemples datés (litiges évités, situation client bien gérée) + souhaits d'évolution argumentés : présenté AVANT que le poste s'ouvre : les évolutions se préparent, elles ne se demandent pas la veille.$mft$,
   $mft$Barème /5 : indicateurs chiffrés pertinents et vérifiables (2 pts) ; preuves comportementales concrètes (1,5 pt) ; démarche proactive (entretien annuel, formations, dossier daté) (1,5 pt). Erreurs fréquentes : dossier d'intentions sans preuves ; attendre l'ouverture du poste pour se construire.$mft$,
   5, 'difficile', ARRAY['fimo-fco','theme-4','question-redigee'], 'FIMO-T4-QR-08', false,
   $mft$Le thème 4 comme plan de carrière : preuves et démarche.$mft$);

  RAISE NOTICE 'Thème 4 FIMO/FCO créé : module %, 3 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $fimot4$;
