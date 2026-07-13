-- =====================================================================
-- TITRE PRO ECSR : MODULE 5 : SENSIBILISER TOUS LES PUBLICS (CCP2)
-- v1 (juillet 2026)
-- Coeur du CCP2 : concevoir et animer des actions de sensibilisation
-- (scolaires, entreprises, seniors, publics fragilisés), traiter les
-- grands facteurs de risque en animation, connaître les stages et
-- dispositifs, développer son activité d'intervenant.
-- ⚠ STATUT : questions insérées avec active = false (« à valider »).
-- Idempotent : DELETE ciblés par slug/source_ref, rejouable sans doublon.
-- =====================================================================

DO $ecsrm5$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_l4 uuid;
  v_quiz uuid; v_q uuid; v_ord int := 0;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'ecsr';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation ecsr introuvable.'; END IF;

  INSERT INTO public.blocs (id, code, title, description, "order") VALUES (60, 'ECSR', 'Titre professionnel Enseignant de la conduite et de la sécurité routière', 'Préparation au titre professionnel ECSR (niveau 5, deux CCP) : former des apprenants conducteurs et sensibiliser tous les usagers de la route.', 60) ON CONFLICT DO NOTHING;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'ECSR';

  DELETE FROM public.question_bank WHERE source_ref LIKE 'ECSR-M5-%';
  DELETE FROM public.modules WHERE slug = 'ecsr-sensibilisation';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 5 : Sensibiliser tous les publics (CCP2)',
    'ecsr-sensibilisation', v_bloc,
    'Concevoir et animer des actions de sensibilisation à la sécurité routière : scolaires, entreprises, seniors, publics fragilisés : et traiter les grands facteurs de risque en animation.',
    'avance', 330, 50) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 50, true);

  -- ─── Leçon 1 : Construire une action de sensibilisation ─────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'construire-une-action',
    'Construire une action de sensibilisation efficace',
    $mft$> 🎯 **Objectifs**
> - Analyser une demande de sensibilisation et caractériser le public réel.
> - Formuler des objectifs évaluables et choisir des modalités actives.
> - Boucler budget et logistique, évaluer l'action et rendre compte au commanditaire.

## Une action de sensibilisation est un projet

Le CCP2 ne demande pas de « faire une intervention » : il demande de conduire un projet complet, de la commande au bilan. Une action réussie se reconnaît à une chose : on peut dire, preuves à l'appui, ce qu'elle a changé. Tout le reste (la salle pleine, les applaudissements, le commanditaire content le jour J) est agréable mais ne prouve rien.

:::flow
1. Analyser | La demande du commanditaire et le public réel (âge, rapport au risque, contexte)
2. Cibler | Des objectifs évaluables, peu nombreux et réalistes
3. Concevoir | Des modalités actives adaptées au public, au lieu et au budget
4. Organiser | Logistique, matériel, intervenants, budget validé
5. Animer | Dérouler en gardant la main sur le temps et la dynamique de groupe
6. Évaluer | À chaud puis à froid, et rendre compte au commanditaire
:::

## Analyser la demande et le public

Le commanditaire (école, entreprise, collectivité) exprime rarement un besoin précis : « il faut faire quelque chose pour les jeunes », « nos salariés roulent mal ». Votre premier travail consiste à transformer cette demande floue en commande exploitable.

| Question au commanditaire | Ce qu'elle change dans votre action |
| --- | --- |
| Qui est le public exact (âge, expérience) ? | Le ton, les exemples, les modalités |
| Pourquoi cette demande maintenant ? | Un accident vécu impose du tact |
| Quel effectif, quelle durée, quel lieu ? | Ateliers tournants ou groupe unique |
| Quel budget ? | Simulateur, réalité virtuelle ou ateliers sobres |
| Qu'attendez-vous à la fin ? | Les critères du compte rendu final |

Le rapport au risque varie énormément d'un public à l'autre : un adolescent se croit invulnérable, un professionnel banalise le trajet quotidien, un senior redoute d'être jugé. La même action ne convient jamais à tous.

## Des objectifs évaluables, pas des intentions

« Sensibiliser les jeunes » n'est pas un objectif : c'est une intention invérifiable. Un objectif utile décrit un résultat observable : « à l'issue de l'atelier, les participants savent citer trois effets du téléphone au volant », « chaque participant repart avec une stratégie personnelle écrite pour ses retours de soirée ». Cette exigence n'est pas du confort méthodologique : c'est elle qui rend l'évaluation possible et le compte rendu crédible.

> ❌ **Piège à éviter**
> L'objectif fourre-tout (« faire prendre conscience », « marquer les esprits ») condamne l'action : impossible de savoir si elle a servi, impossible de le prouver au commanditaire, impossible de s'améliorer.

## Choisir des modalités actives

Le descendant pur (conférence, diaporama, brochure) ne marche pas : le public écoute poliment et ne change rien. Les modalités qui produisent des effets font participer : ateliers en petits groupes, témoignages suivis d'un échange animé, mises en situation, réalité virtuelle et simulateurs, quiz interactifs. La règle pratique : à chaque séquence, les participants doivent FAIRE quelque chose (estimer, tester, débattre, formuler), pas seulement écouter.

> 💡 **Astuce**
> Sur un effectif important, préférez les ateliers tournants en petits groupes à la séance plénière : chaque participant vit trois ou quatre expériences courtes au lieu de subir deux heures assises.

## Budget et logistique

Une action tient ou s'effondre sur des détails matériels : salle adaptée aux ateliers, matériel réservé et testé, plan B en cas de pluie pour l'extérieur, rôles écrits pour chaque intervenant, horaires réalistes (les rotations prennent toujours plus de temps que prévu). Côté budget : chiffrer l'animation, le matériel et les déplacements, prioriser l'humain (un témoignage bien accompagné vaut mieux qu'un gadget coûteux) et tout faire valider par écrit avant d'engager des frais.

## Évaluer à chaud, à froid, et rendre compte

L'évaluation à chaud se fait en fin d'action : satisfaction, mais surtout acquis (quelques questions sur le contenu, comparées si possible à un mini-quiz d'entrée). L'évaluation à froid intervient quelques semaines plus tard : que reste-t-il, quels comportements ont changé (déclaratif, relayé par le commanditaire) ? Le compte rendu final présente la participation, les résultats au regard des objectifs annoncés et des pistes pour la suite : c'est ce document, plus que le jour J, qui fait revenir le commanditaire.

## ✅ Synthèse

- Une action = un projet : **analyser, cibler, concevoir, organiser, animer, évaluer**.
- Objectifs **évaluables** (résultats observables), jamais d'intentions floues.
- Modalités **actives** : le descendant pur ne change pas les comportements.
- Évaluation **à chaud et à froid**, compte rendu au commanditaire : la preuve fait revenir.$mft$,
    $mft$La méthodologie de projet d'une action de sensibilisation : analyse de la demande et du public, objectifs évaluables, modalités actives, budget et logistique, évaluation à chaud et à froid, compte rendu au commanditaire.$mft$,
    1, 45) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : Les facteurs de risque en animation ──────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'facteurs-de-risque-en-animation',
    'Traiter les facteurs de risque sans moraliser',
    $mft$> 🎯 **Objectifs**
> - Animer les grands facteurs de risque avec des faits, sans moraliser.
> - Dérouler la méthode : croyances, confrontation aux faits, stratégies personnelles.
> - Adapter l'angle du discours aux adolescents et aux professionnels.

## La morale ne change pas les comportements

Tout le monde « sait » que la vitesse tue et que le téléphone distrait : si le savoir suffisait, les accidents auraient disparu. Ce qui résiste, ce sont les croyances personnelles : « moi je gère », « je tiens l'alcool », « je connais la route ». L'animateur efficace ne fait pas la leçon : il organise la rencontre entre ces croyances et les faits.

:::flow
1. Faire émerger | Les croyances du groupe : tour de table, vote à main levée, post-it anonymes
2. Confronter | Aux faits : expérience vécue en atelier, démonstration, témoignage
3. Faire formuler | Des stratégies personnelles réalistes, validées par le groupe
:::

Le troisième temps est le plus souvent oublié : c'est pourtant lui qui produit le changement. Une croyance ébranlée sans stratégie de remplacement se reconstruit dès le lendemain.

## Vitesse : la physique plutôt que la peur

La vitesse se traite par la physique accessible : la distance d'arrêt se décompose en distance de réaction (le véhicule file pendant que le cerveau traite l'information) et distance de freinage ; l'énergie à dissiper croît comme le carré de la vitesse, donc un « petit » excès produit un grand écart de distance d'arrêt. En atelier : faire ESTIMER les distances par le groupe avant de les faire calculer ou mesurer : l'écart entre l'intuition et le résultat vaut tous les discours.

## Alcool et stupéfiants : travailler les représentations

Le sujet charrie des mythes solides : « je tiens l'alcool », « un bon café et ça repart », « le sport élimine ». Les faits à installer : la sensation de sobriété ne dit rien des effets réels (réflexes et perception se dégradent avant les signes visibles) ; le verre standard servi aux normes contient la même quantité d'alcool quelle que soit la boisson ; l'élimination est lente et rien ne l'accélère : ni café, ni douche, ni effort. Faire travailler des situations concrètes de soirée par les participants et appuyer par un témoignage : le vécu porte plus qu'un tableau de chiffres.

> 🔍 **Zoom**
> Ne pas asséner : faire chercher. « À votre avis, lequel de ces trois verres contient le plus d'alcool ? » ouvre un débat que la bonne réponse conclut ; l'affirmation directe aurait fermé l'échange.

## Distracteurs : l'expérience de double tâche

Le téléphone au volant se démontre en deux minutes d'atelier : faire recopier un texte pendant qu'on pose des questions orales : la copie ralentit, les réponses se dégradent, le groupe rit puis comprend. L'attention ne se partage pas, elle bascule, et chaque basculement coûte du temps de réaction. Le transfert vers la conduite se fait alors naturellement, y compris sur la conversation elle-même, qui capte l'attention au-delà du simple geste de tenir l'appareil.

## Fatigue et ceinture

La fatigue se travaille sur les signes annonciateurs (paupières lourdes, dérives de trajectoire, passages du trajet dont on ne se souvient plus) et sur une vérité simple : la seule contre-mesure fiable est de s'arrêter et de dormir, le reste (fenêtre ouverte, musique forte) ne fait que masquer. La ceinture s'anime par la démonstration et le témoignage plutôt que par le rappel de l'obligation, que tout le monde connaît déjà.

## Adapter l'angle au public

| Public | L'angle qui porte | L'angle qui échoue |
| --- | --- | --- |
| Adolescents | Le groupe de pairs, l'image de soi, les scénarios de soirée | La peur brute, la leçon d'adulte |
| Professionnels | La responsabilité, l'emploi, le permis outil de travail | La culpabilisation, l'infantilisation |

Chez les adolescents, la stratégie validée par les pairs pèse plus que la consigne d'un adulte : faire travailler les scénarios EN groupe. Chez les professionnels, relier chaque risque à l'activité réelle : tournées, trajets domicile-travail, véhicules de service.

> 🎓 **Pour l'examen**
> Le jury du CCP2 attend la méthode, pas le catalogue : montrer sur UN facteur comment vous faites émerger, confronter et formuler vaut mieux que réciter les cinq facteurs à la suite.

## ✅ Synthèse

- Méthode en trois temps : **faire émerger, confronter aux faits, faire formuler des stratégies**.
- Vitesse : physique accessible (réaction + freinage, énergie au carré de la vitesse).
- Alcool : sensation trompeuse, verre standard, élimination que rien n'accélère.
- Distracteurs : la double tâche se fait **vivre** en atelier.
- Ados : pairs et image ; pros : responsabilité et emploi.$mft$,
    $mft$La méthode croyances-faits-stratégies appliquée aux grands facteurs de risque : vitesse par la physique accessible, alcool par les représentations, distracteurs par la double tâche, fatigue et ceinture, avec un angle adapté à chaque public.$mft$,
    2, 45) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : Les publics spécifiques ──────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'publics-specifiques',
    'Adapter l''action à chaque public',
    $mft$> 🎯 **Objectifs**
> - Identifier les spécificités de chaque public : scolaires, salariés, seniors, publics fragilisés.
> - Respecter les cadres institutionnels propres à chaque contexte d'intervention.
> - Ajuster sa posture d'animateur pour créer l'adhésion sans stigmatiser.

## Scolaires : s'inscrire dans un continuum

L'école ne découvre pas la sécurité routière avec vous : elle la travaille dans un continuum éducatif qui court de la maternelle au lycée, jalonné notamment par les attestations ASSR préparées au collège. L'intervenant extérieur ne remplace pas ce continuum, il le renforce : action préparée AVEC l'équipe enseignante, prolongée en classe avant et après votre venue.

> ⚠️ **Attention**
> En milieu scolaire, on n'entre pas librement : l'intervention se fait dans le cadre fixé par l'Éducation nationale et par l'établissement (accord du chef d'établissement, préparation avec les équipes, contenus validés, autorisations nécessaires). Toute promotion commerciale (flyers de l'auto-école, offres aux élèves) y est proscrite : elle discréditerait l'action et son auteur.

Côté modalités : séquences courtes, très interactives, appuyées sur le levier des pairs (leçon 2). Le bon intervenant scolaire n'est ni le gendarme ni le « grand frère » : il tient un cadre bienveillant en appui de l'équipe éducative.

## Entreprises : le risque routier professionnel

Le risque routier est la première cause de mortalité au travail : ce fait, beaucoup de dirigeants l'ignorent, et il change la conversation. L'accident de mission ou de trajet coûte des vies, désorganise les équipes et engage l'entreprise. Votre offre : aider l'employeur à structurer un plan de prévention du risque routier et le décliner en ateliers pour les salariés, ancrés dans les déplacements réels de l'entreprise (tournées, véhicules utilisés, contraintes horaires).

L'angle : professionnel à professionnel. On ne culpabilise pas des adultes qui conduisent toute l'année ; on les outille : faits, expériences vécues en atelier, stratégies applicables dès la prochaine tournée.

## Seniors : la bienveillance d'abord

Le public senior arrive souvent sur la défensive : peur d'être jugé, parfois pression de la famille. La remise à niveau est bienveillante ou elle n'est pas : valoriser des décennies d'expérience, actualiser ce qui a changé (giratoires, nouveaux aménagements, signalisation), aborder les aptitudes (vision, temps de réaction) comme une évolution normale qui se compense par l'anticipation et le choix des horaires et des itinéraires. Les alternatives de mobilité se présentent comme une boîte à outils qui prolonge l'autonomie, jamais comme une sanction.

> ❌ **Piège à éviter**
> Transformer l'atelier seniors en examen déguisé. Au premier parfum de test éliminatoire, la confiance disparaît et le public ne revient jamais : or c'est le retour qui fait la prévention.

## Publics en insertion et sous main de justice

Stages et actions se montent avec des partenaires : structures d'insertion, services de justice, associations. Pour ces publics, le permis est souvent un levier d'emploi et de réinsertion : l'angle de l'utilité concrète fonctionne mieux que tout autre. La posture : respect absolu, codes adaptés, aucune réactivation des échecs scolaires (éviter le format « salle de classe », privilégier l'atelier et le concret).

## Personnes en situation de handicap

L'apprentissage et la reprise de la conduite sont possibles dans de nombreuses situations grâce aux aménagements du véhicule et à une filière spécialisée (enseignants formés, véhicules adaptés, évaluations dédiées). Le rôle de l'ECSR généraliste : informer sur l'existence de ces solutions et ORIENTER vers les structures compétentes, sans promettre à leur place.

## La posture selon le public

| Public | Posture qui fonctionne | Écueil qui condamne |
| --- | --- | --- |
| Scolaires | Cadre bienveillant, appui sur l'équipe éducative | Jouer au gendarme ou au grand frère |
| Salariés | Pro à pro, faits et enjeux d'emploi | Culpabiliser, infantiliser |
| Seniors | Valoriser, sécuriser, compenser | Examen déguisé, infantilisation |
| Insertion / justice | Respect, utilité concrète (permis = emploi) | Moraliser, réactiver l'échec scolaire |
| Handicap | Informer, orienter | Promettre hors de son périmètre |

## ✅ Synthèse

- Scolaires : continuum éducatif, ASSR, cadre Éducation nationale et autorisations : **jamais en solo**.
- Entreprises : risque routier = **première cause de mortalité au travail** ; plan de prévention + ateliers.
- Seniors : remise à niveau **bienveillante**, aptitudes abordées avec tact, alternatives en boîte à outils.
- Insertion/justice : partenariats, utilité concrète ; handicap : **informer et orienter**.
- Une posture par public : la même action ne convient jamais à tous.$mft$,
    $mft$Les publics de la sensibilisation et leurs cadres : scolaires (continuum, ASSR, Éducation nationale), entreprises (risque routier professionnel), seniors, publics en insertion ou sous main de justice, handicap, avec la posture adaptée à chacun.$mft$,
    3, 45) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : Stages et dispositifs ────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'stages-et-dispositifs',
    'Stages, dispositifs et développement de l''activité',
    $mft$> 🎯 **Objectifs**
> - Situer les stages de sensibilisation à la sécurité routière et leurs conditions d'animation.
> - Connaître le post-permis volontaire et les actions locales ouvertes à l'ECSR.
> - Construire son activité d'intervenant : statut, réseau, appels à projets.

## Les stages de sensibilisation à la sécurité routière

Ce sont les « stages de récupération de points » du langage courant : un conducteur qui a perdu des points peut suivre un stage qui se déroule sur deux jours consécutifs et permet d'en récupérer quatre au maximum. Ces stages sont animés par un binôme aux compétences complémentaires : un expert en psychologie et un animateur expert en sécurité routière (profil BAFM ou titulaire d'une autorisation d'enseigner, selon les textes applicables).

> ⚠️ **Point de prudence réglementaire**
> Les conditions exactes d'animation de ces stages (qualifications précises exigées de chaque membre du binôme, agréments) sont fixées par des textes spécifiques : vérifiez la réglementation en vigueur avant de vous positionner. Ce qui est certain : le titre ECSR seul n'y donne pas accès ; l'enseignant qui veut s'y projeter doit acquérir des qualifications complémentaires.

Pour l'ECSR, ce marché récurrent (les stages tournent toute l'année, partout en France) constitue un objectif de moyen terme dans un parcours de qualification.

## Le post-permis volontaire et les actions locales

Le dispositif post-permis s'adresse aux conducteurs novices VOLONTAIRES : consolider l'expérience des premiers mois, revenir sur les situations vécues, ancrer l'auto-évaluation : un terrain naturel pour l'ECSR. À côté, tout un tissu d'actions locales cherche des animateurs qualifiés : journées sécurité routière des collectivités, forums d'associations, actions des assureurs et des fédérations, semaines de la mobilité. Ces actions mobilisent tout le module : commande à analyser, objectifs évaluables, modalités actives, évaluation.

| Dispositif | Public | Rôle possible de l'ECSR |
| --- | --- | --- |
| Stage de sensibilisation (points) | Conducteurs ayant perdu des points | À terme, avec qualifications complémentaires |
| Post-permis volontaire | Conducteurs novices volontaires | Animation adaptée à sa qualification |
| Journées collectivités / associations | Grand public, tous âges | Conception et animation complètes |
| Actions en entreprise | Salariés | Conception, animation, appui au plan de prévention |

## Monter son activité d'intervenant

Le CCP2 ne sert à rien s'il reste un diplôme dans un tiroir : l'activité de sensibilisation se construit.

:::timeline
1. **Mois 1 à 3 :** définir l'offre (deux ou trois formats reproductibles, publics visés, tarifs) et choisir le statut adapté : salarié d'une école qui diversifie, indépendant, cadre associatif.
2. **Mois 3 à 6 :** construire le réseau (collectivités, entreprises locales, associations, établissements scolaires) et réaliser une première action vitrine documentée.
3. **Mois 6 à 12 :** répondre aux appels à projets ; livrer, évaluer, capitaliser les bilans chiffrés.
4. **Année 2 :** consolider les références, viser les qualifications complémentaires (stages), équilibrer leçons de conduite et actions collectives.
:::

La réponse à un appel à projets reprend la logique de la leçon 1 : le commanditaire (collectivité, assureur, fondation) publie un cahier des charges ; votre réponse gagne si elle présente des objectifs évaluables, une méthode active argumentée, un budget honnête et un dispositif d'évaluation. Les bilans chiffrés de vos actions passées sont votre meilleur argument : d'où l'importance de bien évaluer dès la première action.

> 💡 **Astuce**
> La première référence est la plus dure à obtenir : une action vitrine, même modestement rémunérée, vaut l'investissement si elle est irréprochable et DOCUMENTÉE (photos, chiffres, retours des participants, attestation du commanditaire).

## Le CCP2, relais de croissance du métier

L'enseignant qui ne fait que des leçons de conduite dépend d'un seul marché, avec ses creux saisonniers et sa pression tarifaire. Le CCP2 ouvre d'autres portes : entreprises, collectivités, écoles, associations. Diversifier, c'est lisser son activité, élargir ses revenus, s'ancrer dans le tissu local : et souvent retrouver du sens, en travaillant la prévention en amont plutôt que la seule préparation à l'examen.

## ✅ Synthèse

- Stages de sensibilisation : **2 jours consécutifs, 4 points récupérés au plus**, binôme d'animation qualifié : conditions exactes à vérifier dans les textes, qualifications complémentaires nécessaires pour l'ECSR.
- Post-permis volontaire et actions locales : terrains immédiatement accessibles.
- Activité à construire : **offre, statut, réseau, appels à projets**, bilans chiffrés capitalisés.
- Le CCP2 est un relais de croissance : diversification et ancrage local.$mft$,
    $mft$Les stages de sensibilisation (2 jours consécutifs, 4 points, binôme qualifié : conditions exactes à vérifier), le post-permis volontaire, les actions locales, et la construction d'une activité d'intervenant : statut, réseau, appels à projets.$mft$,
    4, 45) RETURNING id INTO v_l4;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : Sensibiliser tous les publics',
    'Vérifiez le module 5 : méthodologie de projet, facteurs de risque en animation, publics spécifiques, stages et dispositifs.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Une mairie vous appelle : « il nous faut une intervention sécurité routière pour les jeunes de la commune ». Quelle est votre première étape ?$mft$,
    $mft$[
      {"id":"a","label":"Analyser la demande : quel public exact, quel contexte, quelles contraintes de durée, de lieu et de budget","is_correct":true},
      {"id":"b","label":"Réserver tout de suite un simulateur pour marquer les esprits","is_correct":false},
      {"id":"c","label":"Ressortir le diaporama de votre dernière intervention en lycée","is_correct":false},
      {"id":"d","label":"Fixer la date et lancer la communication sur les réseaux de la commune","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ecsr','module-5','qcm-v1'], 'ECSR-M5-QCM-01', false,
    $mft$Sans analyse de la demande et du public, le format choisi ne correspond à rien : simulateur réservé d'office, diaporama recyclé ou communication précoce enferment l'action avant même de l'avoir conçue.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Parmi ces formulations, laquelle constitue un objectif d'action ÉVALUABLE ?$mft$,
    $mft$[
      {"id":"a","label":"À l'issue de l'atelier, chaque participant sait citer trois effets du téléphone au volant","is_correct":true},
      {"id":"b","label":"Sensibiliser les participants aux dangers de la route","is_correct":false},
      {"id":"c","label":"Faire prendre conscience des risques routiers","is_correct":false},
      {"id":"d","label":"Marquer durablement les esprits des participants","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ecsr','module-5','qcm-v1'], 'ECSR-M5-QCM-02', false,
    $mft$Un objectif évaluable décrit un résultat observable et mesurable ; « sensibiliser », « faire prendre conscience » et « marquer les esprits » sont des intentions invérifiables qui rendent tout bilan impossible.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Pour ouvrir un atelier alcool avec des lycéens sans moraliser, vous commencez par :$mft$,
    $mft$[
      {"id":"a","label":"Faire émerger leurs croyances (tour de table, vote à main levée) avant toute information","is_correct":true},
      {"id":"b","label":"Énumérer les sanctions encourues pour donner le ton","is_correct":false},
      {"id":"c","label":"Diffuser un film choc puis passer directement à l'atelier suivant","is_correct":false},
      {"id":"d","label":"Distribuer une brochure à lire pour la semaine suivante","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ecsr','module-5','qcm-v1'], 'ECSR-M5-QCM-03', false,
    $mft$La méthode part des représentations du groupe pour les confronter ensuite aux faits ; sanctions assénées, film sans échange et brochure relèvent du descendant, qui ne modifie pas les comportements.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Pour convaincre un dirigeant de PME d'organiser une action de prévention routière, quel argument est le plus juste ?$mft$,
    $mft$[
      {"id":"a","label":"Le risque routier est la première cause de mortalité au travail : ses salariés sont concernés en mission comme en trajet","is_correct":true},
      {"id":"b","label":"La loi impose une journée de sensibilisation routière annuelle dans toutes les entreprises","is_correct":false},
      {"id":"c","label":"Cela sert surtout à améliorer l'image de l'entreprise sur les réseaux sociaux","is_correct":false},
      {"id":"d","label":"Les accidents de trajet ne concernent que les grandes entreprises","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ecsr','module-5','qcm-v1'], 'ECSR-M5-QCM-04', false,
    $mft$L'argument factuel du risque routier professionnel (première cause de mortalité au travail) porte auprès d'un employeur ; l'obligation annuelle citée est inventée et les accidents de trajet touchent toutes les tailles d'entreprise.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Trois semaines après votre action en entreprise, vous envoyez un court questionnaire sur les comportements adoptés depuis. De quoi s'agit-il ?$mft$,
    $mft$[
      {"id":"a","label":"D'une évaluation à froid : mesurer ce qui reste et ce qui a changé à distance de l'action","is_correct":true},
      {"id":"b","label":"D'une évaluation à chaud simplement décalée pour améliorer le taux de réponse","is_correct":false},
      {"id":"c","label":"D'une opération de fidélisation commerciale déguisée","is_correct":false},
      {"id":"d","label":"D'un contrôle réglementaire obligatoire après toute action de sensibilisation","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-5','qcm-v1'], 'ECSR-M5-QCM-05', false,
    $mft$L'évaluation à froid mesure les effets durables à distance, en complément du questionnaire à chaud de fin d'action ; ce n'est ni un artifice commercial ni une obligation réglementaire.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$En atelier distracteurs, vous faites recopier un texte aux participants pendant que vous leur posez des questions orales. Que cherchez-vous à leur faire constater ?$mft$,
    $mft$[
      {"id":"a","label":"Que l'attention ne se partage pas : en double tâche, les deux performances se dégradent, comme au volant avec un téléphone","is_correct":true},
      {"id":"b","label":"Que certains participants sont naturellement multitâches et peuvent donc téléphoner en conduisant","is_correct":false},
      {"id":"c","label":"Que l'écriture est un exercice plus difficile que la conduite","is_correct":false},
      {"id":"d","label":"Que les questions orales n'ont aucun effet sur la concentration","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-5','qcm-v1'], 'ECSR-M5-QCM-06', false,
    $mft$L'expérience de double tâche fait vivre la dégradation simultanée des deux performances : c'est l'inverse d'une démonstration du « multitâche », qui est précisément la croyance à déconstruire.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$En animation, un participant affirme qu'un café serré et une douche froide lui permettent de reprendre le volant après une soirée arrosée. Votre réponse d'animateur :$mft$,
    $mft$[
      {"id":"a","label":"Faire réagir le groupe puis rétablir le fait : l'élimination de l'alcool est lente et rien ne l'accélère, ni café ni douche","is_correct":true},
      {"id":"b","label":"Confirmer que le café accélère un peu l'élimination, mais pas suffisamment","is_correct":false},
      {"id":"c","label":"Éviter le sujet pour ne pas le braquer devant le groupe","is_correct":false},
      {"id":"d","label":"Répondre que tout dépend de la corpulence et clore l'échange","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-5','qcm-v1'], 'ECSR-M5-QCM-07', false,
    $mft$Café et douche sont des mythes tenaces : seule l'attente élimine l'alcool. L'animateur utilise la croyance exprimée comme matériau pédagogique au lieu de l'éviter, de la valider partiellement ou de clore le débat.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Un collège vous ouvre ses portes pour une action autour de l'ASSR. Quelle condition de cadre respectez-vous en priorité ?$mft$,
    $mft$[
      {"id":"a","label":"Préparer l'intervention avec l'équipe enseignante et dans le cadre fixé par l'établissement (autorisations, continuité pédagogique)","is_correct":true},
      {"id":"b","label":"Intervenir librement : une fois dans l'établissement, le contenu vous appartient","is_correct":false},
      {"id":"c","label":"En profiter pour distribuer les tarifs de votre auto-école aux élèves","is_correct":false},
      {"id":"d","label":"Remplacer l'enseignant pendant votre séquence pour avoir le champ libre","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-5','qcm-v1'], 'ECSR-M5-QCM-08', false,
    $mft$En milieu scolaire, l'intervenant extérieur agit dans le cadre de l'Éducation nationale, avec les autorisations et en continuité avec l'équipe : la promotion commerciale et le cavalier seul y sont proscrits.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Un automobiliste inscrit à un stage de sensibilisation vous demande ce qu'il peut concrètement en attendre. Vous répondez :$mft$,
    $mft$[
      {"id":"a","label":"La récupération de 4 points au plus, à l'issue d'un stage suivi sur 2 jours consécutifs","is_correct":true},
      {"id":"b","label":"La récupération de la totalité des points du permis dès la fin du premier jour","is_correct":false},
      {"id":"c","label":"Une simple attestation de présence sans effet sur le capital de points","is_correct":false},
      {"id":"d","label":"Une remise de points accordée uniquement après un examen final noté","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-5','qcm-v1'], 'ECSR-M5-QCM-09', false,
    $mft$Le stage de sensibilisation, suivi sur deux jours consécutifs, permet de récupérer 4 points au maximum ; il ne restaure pas tout le capital et ne comporte pas d'examen final noté.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Une collectivité exige « une conférence d'une heure devant 200 lycéens réunis en amphithéâtre ». Vous savez que ce format produit peu d'effets. Votre réponse professionnelle :$mft$,
    $mft$[
      {"id":"a","label":"Reformuler la demande avec le commanditaire et proposer des modalités actives en petits groupes, en expliquant les limites du descendant","is_correct":true},
      {"id":"b","label":"Accepter tel quel : le commanditaire paie, il décide seul du format","is_correct":false},
      {"id":"c","label":"Refuser la mission sans proposer d'alternative","is_correct":false},
      {"id":"d","label":"Garder le format mais ajouter un film choc pour garantir l'impact","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ecsr','module-5','qcm-v1'], 'ECSR-M5-QCM-10', false,
    $mft$Le conseil au commanditaire fait partie du métier : reformuler et proposer mieux. Accepter tel quel ou compenser par un film choc reconduit un format inefficace ; refuser sans alternative n'est pas professionnel.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Lors d'un atelier seniors, une participante de 79 ans confie que ses enfants veulent « lui prendre les clés ». Quelle posture adoptez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Valoriser son expérience, travailler avec elle les situations qui la gênent et présenter les alternatives de mobilité comme des outils, sans trancher à la place du médecin","is_correct":true},
      {"id":"b","label":"Lui conseiller d'arrêter de conduire pour rassurer sa famille","is_correct":false},
      {"id":"c","label":"Organiser un test de conduite éliminatoire pour objectiver la décision","is_correct":false},
      {"id":"d","label":"Éviter soigneusement le sujet des aptitudes pour ne pas la vexer","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ecsr','module-5','qcm-v1'], 'ECSR-M5-QCM-11', false,
    $mft$La remise à niveau seniors est bienveillante et non prescriptive : l'ECSR n'est ni le médecin ni la famille. Trancher à leur place, tester pour éliminer ou fuir le sujet des aptitudes manquent tous la cible.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Fraîchement titulaire du titre ECSR, pouvez-vous animer dès aujourd'hui un stage de récupération de points ?$mft$,
    $mft$[
      {"id":"a","label":"Non : ces stages sont animés par un binôme aux qualifications spécifiques ; l'ECSR peut s'y projeter en acquérant les qualifications complémentaires requises","is_correct":true},
      {"id":"b","label":"Oui : le titre ECSR donne automatiquement accès à l'animation de ces stages","is_correct":false},
      {"id":"c","label":"Oui, à condition que l'exploitant de votre auto-école vous y autorise par écrit","is_correct":false},
      {"id":"d","label":"Non : l'animation de ces stages est réservée aux forces de l'ordre","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ecsr','module-5','qcm-v1'], 'ECSR-M5-QCM-12', false,
    $mft$Le titre seul ne suffit pas : le binôme d'animation (expert en psychologie et animateur sécurité routière) répond à des conditions réglementaires précises, à vérifier dans les textes en vigueur ; ni l'accord de l'employeur ni un statut de force de l'ordre ne sont le critère.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Un proviseur vous demande de « sensibiliser les élèves à la vitesse ». Reformulez cette intention en un objectif évaluable.$mft$,
   $mft$Par exemple : à l'issue de l'atelier, chaque élève sait expliquer que la distance d'arrêt se décompose en distance de réaction et distance de freinage, et citer deux conséquences concrètes pour sa pratique.$mft$,
   2, 'facile', ARRAY['ecsr','module-5','question-courte'], 'ECSR-M5-QC-01', false,
   $mft$Un résultat observable et mesurable, pas une intention.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Rappelez les trois temps de la méthode d'animation d'un facteur de risque sans moraliser.$mft$,
   $mft$Faire émerger les croyances du groupe, les confronter aux faits (expérience, démonstration, témoignage), puis faire formuler à chacun des stratégies personnelles réalistes.$mft$,
   2, 'facile', ARRAY['ecsr','module-5','question-courte'], 'ECSR-M5-QC-02', false,
   $mft$Les trois temps dans l'ordre.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Un conducteur ayant perdu des points vous interroge : combien de temps dure un stage de sensibilisation et combien de points permet-il de récupérer ?$mft$,
   $mft$Le stage se déroule sur 2 jours consécutifs et permet de récupérer 4 points au maximum.$mft$,
   2, 'facile', ARRAY['ecsr','module-5','question-courte'], 'ECSR-M5-QC-03', false,
   $mft$Deux jours consécutifs, 4 points au plus.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Distinguez l'évaluation à chaud de l'évaluation à froid, avec un exemple d'outil pour chacune.$mft$,
   $mft$À chaud : en fin d'action, mesurer la satisfaction et les acquis immédiats (questionnaire de sortie, quiz). À froid : plusieurs semaines après, mesurer ce qui reste et les changements déclarés (courte enquête relayée par le commanditaire).$mft$,
   2, 'moyen', ARRAY['ecsr','module-5','question-courte'], 'ECSR-M5-QC-04', false,
   $mft$Deux moments, deux objets de mesure.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Vous traitez le même risque (téléphone au volant) devant des lycéens puis devant des salariés. Quel angle privilégiez-vous pour chaque public ?$mft$,
   $mft$Lycéens : le groupe de pairs et l'image de soi (scénarios entre amis, stratégies validées par le groupe). Salariés : la responsabilité professionnelle et l'emploi (le permis comme outil de travail, les conséquences d'un accident en mission ou en trajet).$mft$,
   2, 'moyen', ARRAY['ecsr','module-5','question-courte'], 'ECSR-M5-QC-05', false,
   $mft$Pairs et image pour les ados, responsabilité et emploi pour les pros.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Quel fait majeur légitime une action de prévention du risque routier en entreprise, et quel outil structurant proposez-vous à l'employeur ?$mft$,
   $mft$Le risque routier est la première cause de mortalité au travail ; l'outil structurant est un plan de prévention du risque routier, décliné en ateliers pour les salariés.$mft$,
   2, 'moyen', ARRAY['ecsr','module-5','question-courte'], 'ECSR-M5-QC-06', false,
   $mft$Fait + outil : mortalité au travail et plan de prévention.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Une personne en situation de handicap moteur souhaite apprendre à conduire et vous sollicite. Quel est votre rôle ?$mft$,
   $mft$L'informer sur l'existence d'aménagements du véhicule et l'orienter vers la filière spécialisée compétente : l'enseignant généraliste ne promet pas à la place des structures spécialisées.$mft$,
   2, 'moyen', ARRAY['ecsr','module-5','question-courte'], 'ECSR-M5-QC-07', false,
   $mft$Informer et orienter.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Citez deux dispositifs, hors stages de récupération de points, dans lesquels un ECSR peut animer des actions de sensibilisation.$mft$,
   $mft$Par exemple : le post-permis volontaire pour les conducteurs novices, les journées sécurité routière des collectivités ou des associations, les actions de prévention en entreprise.$mft$,
   2, 'moyen', ARRAY['ecsr','module-5','question-courte'], 'ECSR-M5-QC-08', false,
   $mft$Deux dispositifs distincts attendus.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Pour un atelier vitesse, quels contenus de « physique accessible » retenez-vous et pourquoi ce choix pédagogique ?$mft$,
   $mft$La décomposition de la distance d'arrêt (réaction + freinage) et l'énergie qui croît comme le carré de la vitesse : des faits démontrables et manipulables par les participants eux-mêmes, qui convainquent sans moraliser.$mft$,
   2, 'difficile', ARRAY['ecsr','module-5','question-courte'], 'ECSR-M5-QC-09', false,
   $mft$Des faits manipulables plutôt qu'un discours.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Vous répondez à un appel à projets d'une collectivité pour des actions de sensibilisation. Citez trois éléments incontournables de votre réponse.$mft$,
   $mft$Par exemple : des objectifs évaluables, la description des publics et des modalités actives, le budget et la logistique, les modalités d'évaluation (à chaud, à froid) et le compte rendu prévu.$mft$,
   2, 'difficile', ARRAY['ecsr','module-5','question-courte'], 'ECSR-M5-QC-10', false,
   $mft$Trois éléments cohérents du dossier.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Une entreprise de travaux publics de 40 salariés vous commande une demi-journée de sensibilisation après deux accidents de trajet. Déroulez votre méthodologie complète, de l'analyse de la demande au compte rendu au dirigeant.$mft$,
   $mft$Réponse modèle. Analyser : entretien avec le dirigeant pour comprendre le contexte (circonstances des deux accidents, trajets ou missions concernés, profils des salariés) et les contraintes (demi-journée, effectif, lieu, budget). Cibler : des objectifs évaluables, par exemple : à l'issue de la demi-journée, chaque salarié sait citer trois situations à risque sur ses trajets et a formulé une stratégie personnelle. Concevoir : des modalités actives en petits groupes tournants : atelier distance d'arrêt (physique accessible), expérience de double tâche sur les distracteurs, échange autour d'un témoignage ; pas de conférence descendante. Organiser : salle, matériel testé, répartition des groupes construite avec l'employeur, budget validé par écrit. Animer : dérouler avec tact, les accidents récents pouvant avoir marqué les équipes. Évaluer : à chaud, questionnaire de satisfaction et d'acquis en fin de session ; à froid, courte enquête quelques semaines plus tard relayée en interne. Rendre compte : bilan écrit au dirigeant : participation, résultats mesurés au regard des objectifs annoncés, recommandations pour inscrire l'action dans un plan de prévention du risque routier durable.$mft$,
   $mft$Barème /5 : analyse de la demande et du contexte (1 pt) ; objectifs évaluables correctement formulés (1 pt) ; modalités actives adaptées au public (1 pt) ; organisation et budget (0,5 pt) ; évaluation à chaud et à froid + compte rendu au commanditaire (1,5 pt). Erreurs fréquentes : proposer une conférence descendante ; formuler des intentions invérifiables (« sensibiliser ») au lieu d'objectifs ; oublier le compte rendu final.$mft$,
   5, 'facile', ARRAY['ecsr','module-5','question-redigee'], 'ECSR-M5-QR-01', false,
   $mft$La méthodologie de projet appliquée à une commande d'entreprise.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Expliquez pourquoi une conférence descendante seule modifie peu les comportements routiers, puis décrivez la méthode d'animation en trois temps appliquée au téléphone au volant avec une classe de lycéens.$mft$,
   $mft$Réponse modèle. Le format descendant échoue parce que le public est passif et que l'information délivrée est déjà connue : chacun sait que le téléphone au volant est dangereux, mais la croyance intime (« moi, je gère ») n'est jamais travaillée, et aucun engagement personnel n'est produit ; l'émotion d'un film retombe dès la sortie. La méthode en trois temps : 1) faire émerger les croyances : vote à main levée, tour de table (« qui répond à un message en scooter ou en voiture ? qui pense y arriver sans risque ? ») : les représentations s'expriment sans jugement ; 2) confronter aux faits : expérience de double tâche en atelier (recopier un texte en répondant à des questions : les deux performances chutent) : chaque lycéen constate sur lui-même que l'attention ne se partage pas ; 3) faire formuler des stratégies personnelles : chacun écrit sa parade réaliste (mode silencieux, téléphone hors de portée, réponse à l'arrêt) et le groupe la valide, car chez les adolescents une stratégie approuvée par les pairs pèse bien plus que la consigne d'un adulte.$mft$,
   $mft$Barème /5 : limites du descendant expliquées (passivité, croyances non travaillées, absence d'engagement) (1,5 pt) ; les trois temps exacts et ordonnés (1,5 pt) ; application concrète au téléphone avec l'expérience de double tâche (1 pt) ; adaptation à l'angle adolescent (pairs, image) (1 pt). Erreurs fréquentes : réduire la méthode au film choc ; oublier le troisième temps (stratégies personnelles), celui qui produit le changement.$mft$,
   5, 'facile', ARRAY['ecsr','module-5','question-redigee'], 'ECSR-M5-QR-02', false,
   $mft$Les limites du descendant et la méthode en trois temps sur un cas concret.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Comparez une intervention auprès de collégiens autour de l'ASSR et un atelier de prévention pour les salariés d'une entreprise : cadre d'intervention, objectifs, modalités d'animation et posture de l'intervenant.$mft$,
   $mft$Réponse modèle. Cadre : au collège, l'intervenant extérieur agit dans le cadre de l'Éducation nationale : action préparée avec l'équipe enseignante, autorisations de l'établissement, inscription dans le continuum éducatif dont l'ASSR est un jalon ; en entreprise, le commanditaire est l'employeur, dans une logique de prévention du risque routier professionnel, première cause de mortalité au travail. Objectifs : au collège, préparer et prolonger l'ASSR, ancrer des réflexes de piéton, de cycliste et de futur conducteur ; en entreprise, des objectifs évaluables reliés à un plan de prévention (trajets et missions réels). Modalités : séquences courtes et interactives adaptées à l'âge d'un côté ; ateliers concrets ancrés dans les situations de travail de l'autre. Posture : avec les collégiens, un cadre ferme et bienveillant, ni gendarme ni grand frère, en appui de l'équipe éducative ; avec les salariés, une relation de professionnel à professionnel, factuelle, jamais culpabilisante, centrée sur la responsabilité et l'emploi. Constantes : la méthode active (croyances, faits, stratégies), l'évaluation et le compte rendu au commanditaire restent identiques dans les deux contextes.$mft$,
   $mft$Barème /5 : cadre exact des deux contextes (Éducation nationale avec autorisations ; employeur et risque professionnel) (1,5 pt) ; objectifs différenciés (1 pt) ; modalités adaptées à chaque public (1 pt) ; postures distinctes et justifiées (1 pt) ; constantes méthodologiques identifiées (0,5 pt). Erreurs fréquentes : traiter le collège comme un public captif sans cadre institutionnel ; culpabiliser les salariés au lieu de les outiller.$mft$,
   5, 'moyen', ARRAY['ecsr','module-5','question-redigee'], 'ECSR-M5-QR-03', false,
   $mft$Deux contextes, deux cadres, une même méthode.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$En atelier avec des jeunes en insertion, un participant lance : « moi je tiens l'alcool, deux verres ne me font rien ». Construisez votre réponse d'animateur : méthode mobilisée, contenus factuels, écueils à éviter avec ce public.$mft$,
   $mft$Réponse modèle. Ne pas contrer frontalement : la croyance exprimée est le matériau pédagogique idéal. Premier temps, faire émerger : renvoyer au groupe (« qui partage cette impression ? ») et faire préciser (« tenir l'alcool », c'est quoi : ne pas tituber ? se sentir normal ?). Deuxième temps, confronter aux faits : distinguer la sensation des effets réels : l'alcool dégrade les réflexes et la perception bien avant les signes visibles, la sensation de « tenir » ne protège de rien ; rappeler l'équivalence des verres standard (même quantité d'alcool d'un verre servi aux normes à l'autre) et l'élimination lente que rien n'accélère : ni café, ni douche, ni effort : des mythes à déconstruire avec le groupe ; un témoignage renforce le propos. Troisième temps, faire formuler : chacun construit sa stratégie de retour de soirée réaliste (conducteur désigné, dormir sur place, transports). Écueils : humilier le participant devant le groupe (il se braque et le groupe le suit), asséner des chiffres sans dialogue, glisser vers la morale : avec un public en insertion, la posture est le respect et l'utilité concrète, le permis étant souvent un levier d'emploi.$mft$,
   $mft$Barème /5 : refus du contre frontal et exploitation pédagogique de la croyance (1 pt) ; méthode en trois temps appliquée (1,5 pt) ; contenus factuels exacts (sensation vs effets, verre standard, élimination lente) (1,5 pt) ; écueils et posture propres au public en insertion (1 pt). Erreurs fréquentes : ridiculiser le participant ; répondre par les seules sanctions ; oublier les stratégies personnelles.$mft$,
   5, 'moyen', ARRAY['ecsr','module-5','question-redigee'], 'ECSR-M5-QR-04', false,
   $mft$Une croyance exprimée transformée en séquence pédagogique.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Votre commune (3 000 habitants) vous confie l'organisation d'une journée sécurité routière avec un budget limité. Concevez l'action : objectifs évaluables, ateliers proposés, logistique et budget, évaluation et compte rendu.$mft$,
   $mft$Réponse modèle. Analyse : public hétérogène (familles, jeunes, seniors), attente du commanditaire : de la visibilité et des résultats présentables au conseil municipal. Objectifs évaluables par public, par exemple : les visiteurs de l'atelier vitesse savent expliquer la décomposition de la distance d'arrêt ; dix seniors s'inscrivent à un atelier de remise à niveau. Ateliers en stands tournants : parcours distracteurs avec expérience de double tâche, quiz interactifs, atelier équivalences de verres, stand seniors (aptitudes et alternatives de mobilité), témoignage à heure fixe annoncée ; le format descendant est limité au mot d'ouverture. Logistique : salle ou place couverte, plan B météo, matériel emprunté aux partenaires (associations, assureurs, services de l'État prêtent souvent des outils), bénévoles briefés sur un rôle écrit. Budget : prioriser l'humain (animation, témoignage) sur le matériel coûteux, valoriser les prêts et les partenariats dans le dossier. Évaluation : comptage des passages par stand, mini-quiz de sortie, retour à froid via le bulletin municipal ; compte rendu chiffré au maire et au conseil : c'est lui qui déclenche la reconduction l'année suivante.$mft$,
   $mft$Barème /5 : objectifs évaluables différenciés par public (1,5 pt) ; ateliers actifs cohérents avec un public hétérogène (1,5 pt) ; logistique et budget réalistes (partenariats, plan B) (1 pt) ; évaluation et compte rendu au commanditaire (1 pt). Erreurs fréquentes : empiler des stands sans objectifs ; dépenser le budget en matériel au détriment de l'animation ; oublier le compte rendu au conseil.$mft$,
   5, 'moyen', ARRAY['ecsr','module-5','question-redigee'], 'ECSR-M5-QR-05', false,
   $mft$Une journée communale conçue en projet complet à budget contraint.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Une association vous confie un atelier pour des seniors dont plusieurs sont envoyés par des familles qui veulent « qu'ils arrêtent de conduire ». Analysez les enjeux de la situation, puis construisez votre posture et votre déroulé d'atelier.$mft$,
   $mft$Réponse modèle. Enjeux : une double injonction traverse l'atelier : des familles inquiètes d'un côté, des seniors attachés à leur autonomie de l'autre, la voiture représentant le lien social, les courses, l'accès aux soins. L'atelier n'est ni une expertise d'aptitude ni un tribunal : l'ECSR n'a pas à « retirer les clés », décision qui relève d'autres acteurs, le médecin notamment. Posture : bienveillance et valorisation de l'expérience (des décennies de conduite), aborder les aptitudes (vision, temps de réaction) comme une évolution normale qui se compense (anticipation, choix des horaires et des itinéraires), sans test éliminatoire déguisé ni infantilisation. Déroulé : accueil et expression des attentes ; remise à niveau choisie avec eux (giratoires, nouveaux aménagements, angles morts) ; auto-positionnement individuel sur ses propres situations difficiles ; présentation des alternatives de mobilité comme une boîte à outils (transports, covoiturage, services locaux) et non comme une sanction ; entretien individuel proposé à qui le souhaite. Avec les familles : rappeler le cadre (pas de rapport nominatif) et orienter vers le médecin en cas d'inquiétude sur l'aptitude. Le succès se mesure simplement : des seniors qui reviennent.$mft$,
   $mft$Barème /5 : analyse de la double injonction et des limites du rôle de l'ECSR (1,5 pt) ; posture bienveillante et non prescriptive argumentée (1 pt) ; déroulé complet avec remise à niveau choisie et alternatives en boîte à outils (1,5 pt) ; gestion du lien avec les familles (orientation médecin, pas de rapport nominatif) (1 pt). Erreurs fréquentes : se substituer au médecin ; transformer l'atelier en test de conduite ; présenter les alternatives comme une punition.$mft$,
   5, 'moyen', ARRAY['ecsr','module-5','question-redigee'], 'ECSR-M5-QR-06', false,
   $mft$L'atelier seniors sous double injonction : enjeux, posture, déroulé.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Titulaire du titre ECSR depuis un an, vous enseignez la conduite en auto-école et souhaitez développer une activité de sensibilisation (CCP2). Construisez votre plan de développement sur deux ans : offre, statut, réseau, appels à projets et qualifications complémentaires.$mft$,
   $mft$Réponse modèle. Première année. Offre : trois formats reproductibles et documentés (demi-journée entreprise, intervention scolaire cadrée avec l'établissement, atelier seniors), chacun avec objectifs évaluables et grille d'évaluation prête. Statut : rester salarié si l'école de conduite diversifie son activité, sinon structure indépendante ou associative, choisie selon le volume visé et la sécurité recherchée. Réseau : se faire connaître des collectivités, entreprises locales, associations et établissements ; accepter une action vitrine, même modestement rémunérée, et en tirer un bilan chiffré qui servira de référence. Appels à projets : organiser une veille (collectivités, assureurs, fondations) et répondre avec la structure attendue : objectifs, méthode active, budget, évaluation. Deuxième année. Capitaliser : références, bilans chiffrés, taux de reconduction ; viser les qualifications complémentaires nécessaires pour l'animation des stages de sensibilisation (récupération de points), marché récurrent dont les conditions exactes d'animation sont à vérifier dans les textes en vigueur avant de s'engager dans un parcours de qualification. Indicateurs de pilotage : nombre d'actions, taux de reconduction, part du chiffre d'affaires hors leçons. Le CCP2 devient ainsi un relais de croissance et un amortisseur des creux d'activité de l'auto-école.$mft$,
   $mft$Barème /5 : offre structurée en formats reproductibles avec objectifs évaluables (1,5 pt) ; choix de statut argumenté (0,5 pt) ; démarche réseau et action vitrine documentée (1 pt) ; méthode de réponse aux appels à projets (1 pt) ; trajectoire de qualification vers les stages avec la prudence réglementaire attendue (1 pt). Erreurs fréquentes : plan sans indicateurs de pilotage ; se présenter comme animateur de stages à points sans les qualifications requises.$mft$,
   5, 'difficile', ARRAY['ecsr','module-5','question-redigee'], 'ECSR-M5-QR-07', false,
   $mft$Le CCP2 transformé en plan de développement d'activité.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Un lycée vous recontacte après une action jugée décevante l'an dernier : une conférence de deux heures avec film choc devant 200 élèves, sans aucun effet constaté. Analysez les causes de l'échec puis reconstruisez l'action, évaluation comprise.$mft$,
   $mft$Réponse modèle. Causes de l'échec : format descendant pur devant un effectif massif, donc aucune interaction possible ; film choc seul, qui produit une émotion sans travail des croyances ni formulation de stratégies : l'effet retombe à la sortie ; aucun objectif évaluable défini en amont, donc rien n'était mesurable : « aucun effet constaté » signifie d'abord qu'aucune mesure n'était prévue ; pas de co-construction avec les enseignants ni de continuité pédagogique. Reconstruction : analyser avec l'équipe (niveaux, vécu des classes, articulation avec l'ASSR et les projets de l'établissement) ; formuler des objectifs évaluables par classe ; remplacer l'amphithéâtre par des ateliers tournants en demi-classes : expérience de double tâche sur les distracteurs, physique accessible de la vitesse, scénarios de soirée ; conserver le témoignage mais en petit groupe et suivi d'un échange animé ; impliquer des élèves relais, l'approbation des pairs pesant plus qu'un discours d'adulte ; respecter le cadre de l'Éducation nationale (autorisations, préparation et prolongement en classe). Évaluation : quiz avant et après, engagement écrit personnel, mesure à froid au trimestre suivant avec les enseignants, compte rendu chiffré au proviseur. Reformuler la demande du commanditaire fait partie du métier.$mft$,
   $mft$Barème /5 : diagnostic complet de l'échec (descendant, effectif massif, film sans exploitation, absence d'objectifs mesurables) (2 pts) ; reconstruction en modalités actives et petits groupes (1,5 pt) ; respect du cadre scolaire et co-construction (0,5 pt) ; dispositif d'évaluation avant/après et à froid avec compte rendu (1 pt). Erreurs fréquentes : garder le format en ajoutant un atelier symbolique ; incriminer le public plutôt que le format ; oublier de définir ce qui sera mesuré.$mft$,
   5, 'difficile', ARRAY['ecsr','module-5','question-redigee'], 'ECSR-M5-QR-08', false,
   $mft$Autopsie d'une action ratée et reconstruction méthodique.$mft$);

  RAISE NOTICE 'Module 5 ECSR créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $ecsrm5$;
