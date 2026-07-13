-- =====================================================================
-- ECSR : MODULE 2 : LE REMC ET LES PARCOURS DE FORMATION
-- v1 (juillet 2026) : LOT ECSR
-- Le référentiel pour l'éducation à une mobilité citoyenne, la matrice
-- GDE, les quatre compétences du permis B, les parcours AAC et conduite
-- supervisée, le continuum éducatif.
-- ⚠ STATUT : active = false (« à valider »). Idempotent.
-- =====================================================================

DO $ecsrm2$
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

  DELETE FROM public.question_bank WHERE source_ref LIKE 'ECSR-M2-%';
  DELETE FROM public.modules WHERE slug = 'ecsr-remc-parcours';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 2 : Le REMC et les parcours de formation',
    'ecsr-remc-parcours', v_bloc,
    'Le référentiel pour l''éducation à une mobilité citoyenne, la matrice GDE, les quatre compétences du permis B et les parcours AAC et conduite supervisée.',
    'intermediaire', 330, 20) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 20, true);

  -- ─── Leçon 1 : Le REMC et la matrice GDE ───────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'remc-matrice-gde',
    'Le REMC et la matrice GDE : former un conducteur-citoyen',
    $mft$> 🎯 **Objectifs**
> - Comprendre la philosophie du REMC : former un conducteur-citoyen par une approche par compétences.
> - Mémoriser les quatre niveaux de la matrice GDE et leur hiérarchie.
> - Relier les niveaux supérieurs de la matrice aux prises de risque des conducteurs novices.

## Un référentiel qui change le métier

Le REMC, référentiel pour l'éducation à une mobilité citoyenne, est le texte qui structure aujourd'hui l'enseignement de la conduite en France. Sa philosophie tient en une formule : former un **conducteur-citoyen**, pas un passeur d'examen. La nuance est fondamentale pour votre futur métier. Le passeur d'examen apprend des recettes : la position des mains, le regard au bon endroit le jour J, les parcours types du centre d'examen. Le conducteur-citoyen, lui, construit des compétences durables : il comprend pourquoi il agit, il évalue ses propres limites, il prend en compte les autres usagers, et il continuera à le faire des années après l'examen.

Le REMC repose sur une **approche par compétences** : on ne compte pas des heures « faites », on observe des compétences acquises. Une compétence, c'est un ensemble de savoirs, de savoir-faire et de savoir-être mobilisés dans une situation réelle. Conséquence directe pour l'enseignant : chaque séance vise des objectifs précis, annoncés à l'élève, évalués en fin de séance, et la progression se pilote sur ce qui est réellement maîtrisé, pas sur un compteur d'heures.

> 📌 **À retenir**
> Sous le REMC, l'élève n'est pas un réservoir à remplir d'heures : c'est un apprenant qui construit des compétences, avec des objectifs explicites et des bilans réguliers.

## La matrice GDE : la hiérarchie des comportements

La matrice GDE (Goals for Driver Education) hiérarchise ce qui se joue quand une personne conduit. Elle se lit comme un immeuble à quatre étages :

| Niveau | Intitulé | Ce qui s'y joue |
| --- | --- | --- |
| 1 | Maniement du véhicule | Démarrer, diriger, freiner, manœuvrer : la technique pure |
| 2 | Maîtrise des situations de circulation | Intersections, insertions, interactions avec les autres usagers |
| 3 | Objectifs et contexte du déplacement | Pourquoi, quand, avec qui, dans quel état on part |
| 4 | Projets de vie et aptitudes de vie | Valeurs, image de soi, rapport au risque, influence du groupe |

L'apport décisif de la matrice : les niveaux hauts expliquent l'essentiel des prises de risque. Un jeune conducteur ne s'accidente presque jamais parce qu'il ne sait pas tourner le volant (niveau 1) : il s'accidente parce qu'il part à une heure risquée, fatigué, avec des passagers qui le poussent à s'affirmer (niveaux 3 et 4). La jeunesse, la pression des pairs et les émotions sont des facteurs de risque situés tout en haut de l'immeuble : et ils redescendent sur tous les étages inférieurs.

:::flow
1. Fait observable | Excès de vitesse un samedi soir
2. Niveau 2 | La situation de circulation est mal évaluée
3. Niveau 3 | Le contexte : sortie nocturne, fatigue, passagers à bord
4. Niveau 4 | La cause profonde : besoin de reconnaissance devant les amis
:::

> 🔍 **Zoom**
> La matrice se lit de haut en bas : les projets de vie (niveau 4) influencent le choix des déplacements (niveau 3), qui conditionne les situations rencontrées (niveau 2), où s'exprime la technique (niveau 1). Corriger le geste sans toucher aux étages supérieurs revient à traiter le symptôme.

## Enseigner sur les quatre niveaux

La conclusion pédagogique s'impose : l'enseignement doit toucher les quatre niveaux. Concrètement :

- aux niveaux 1 et 2 : des exercices techniques et des mises en situation, cœur historique du métier ;
- au niveau 3 : des échanges sur le choix des itinéraires, des horaires, de l'état de forme (« serais-tu parti dans ces conditions si tu avais été seul ? ») ;
- au niveau 4 : un travail sur l'auto-évaluation, la connaissance de soi, la résistance à la pression du groupe : questionnements, débats, retours d'expérience.

> 💡 **Astuce**
> En séance, prenez l'habitude de « faire monter » les situations : un simple refus de priorité peut ouvrir sur le contexte (pourquoi étais-tu pressé ?) puis sur la personne (que voulais-tu prouver ?). C'est ce questionnement qui distingue l'enseignant de la conduite du simple répétiteur technique.

> ⚠️ **Vigilance**
> Un enseignement limité au maniement prépare peut-être à l'examen, mais laisse l'élève désarmé face à ce qui accidente réellement les novices : c'est précisément ce que le REMC veut corriger.

## ✅ Synthèse

- REMC : former un **conducteur-citoyen** par une **approche par compétences**, pas un passeur d'examen.
- Matrice GDE : **1 maniement, 2 situations de circulation, 3 contexte du déplacement, 4 projets de vie**.
- Les niveaux hauts (jeunesse, pairs, émotions) expliquent les prises de risque : l'enseignement doit **toucher les quatre niveaux**.$mft$,
    $mft$La philosophie du REMC (conducteur-citoyen, approche par compétences), les quatre niveaux de la matrice GDE et la nécessité d'enseigner sur les quatre niveaux, y compris les facteurs personnels.$mft$,
    1, 45) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : Les quatre compétences du permis B ──────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'quatre-competences-b',
    'Les quatre compétences du REMC pour la catégorie B',
    $mft$> 🎯 **Objectifs**
> - Connaître les quatre compétences du REMC pour la catégorie B et leur logique de progression.
> - Comprendre la validation progressive : sous-compétences, objectifs, bilans tracés au livret.
> - Relier l'évaluation de départ au volume prévisionnel du contrat de formation.

## Les quatre compétences de la catégorie B

Le REMC structure la formation au permis B autour de quatre compétences :

| Compétence | Intitulé | Terrain d'apprentissage type |
| --- | --- | --- |
| C1 | Maîtriser le maniement du véhicule dans un trafic faible ou nul | Parking, voie calme, zone d'exercice |
| C2 | Appréhender la route et circuler dans des conditions normales | Agglomération, routes ordinaires |
| C3 | Circuler dans des conditions difficiles et partager la route avec les autres usagers | Nuit, intempéries, voies rapides, usagers vulnérables |
| C4 | Pratiquer une conduite autonome, sûre et économique | Trajets préparés et conduits en autonomie, éco-conduite |

La logique est celle d'un escalier : le geste d'abord (C1), la circulation ordinaire ensuite (C2), les conditions exigeantes et le partage de la route (C3), l'autonomie complète enfin (C4). Dans la réalité des séances, l'enseignant navigue : on peut consolider un point de C1 alors que C2 est déjà bien engagée. Ce qui ne se négocie pas, c'est la traçabilité de ce qui est acquis.

> 📌 **À retenir**
> Chaque compétence se décline en **sous-compétences**, travaillées avec des objectifs de séance explicites : l'élève sait ce qu'il apprend, pourquoi, et comment ce sera évalué.

## La validation progressive

Le REMC remplace la question « combien d'heures reste-t-il ? » par « qu'est-ce qui est acquis ? ». La validation suit un cycle simple :

:::flow
1. Objectif annoncé | La séance vise une sous-compétence précise
2. Travail guidé | Exercices, mises en situation, questionnement
3. Évaluation partagée | L'élève s'auto-évalue, l'enseignant objective
4. Bilan de compétences | Quand la compétence est acquise : bilan tracé au livret
:::

Le livret d'apprentissage devient la mémoire du parcours : objectifs abordés, acquis validés, axes de travail restants. C'est aussi un outil de dialogue : avec l'élève (il voit sa progression), avec les parents ou l'accompagnateur, et le cas échéant avec un autre enseignant qui reprend la formation en cours de route.

> ⚠️ **Vigilance**
> Valider trop vite pour « avancer » fragilise tout l'édifice : une compétence mal acquise resurgit dans les conditions difficiles de C3, ou pire, après l'examen. Le bilan de compétences engage votre responsabilité pédagogique : il se prononce sur des observations répétées, pas sur une réussite isolée.

## L'évaluation de départ et le contrat

Avant l'entrée en formation, l'évaluation de départ mesure les aptitudes et l'expérience du candidat : perception, compréhension, habiletés, connaissances, motivation. Elle débouche sur un **volume prévisionnel personnalisé** d'heures de formation, qui sert de base au contrat signé avec l'école de conduite.

Repères : le minimum légal de formation pratique est de **20 heures en boîte manuelle** ; pour la boîte automatique, le minimum est abaissé à 13 heures (chiffre à vérifier dans les textes en vigueur). Ces minima sont des planchers, pas des objectifs : le prévisionnel issu de l'évaluation doit refléter le niveau constaté de l'élève, pas un argument commercial.

> ❌ **Piège à éviter**
> Annoncer « permis en 20 heures » à tous les prospects : c'est transformer le minimum légal en promesse. L'élève évalué à 30 heures qui signe pour 20 vivra chaque heure ajoutée comme un abus : alors que le prévisionnel honnête, expliqué dès le départ, construit la confiance.

> 💡 **Astuce**
> Présentez le livret dès la première séance : un élève qui comprend le système de validation devient acteur de sa progression et accepte beaucoup mieux le rythme réel de son apprentissage.

## ✅ Synthèse

- Quatre compétences B : **C1 maniement (trafic faible ou nul), C2 conditions normales, C3 conditions difficiles et partage de la route, C4 conduite autonome, sûre et économique**.
- Validation **progressive** : sous-compétences, objectifs explicites, **bilans de compétences tracés au livret**.
- Évaluation de départ → **volume prévisionnel personnalisé** ; minima légaux : **20 h en boîte manuelle**, 13 h en automatique (à vérifier) : des planchers, jamais des promesses.$mft$,
    $mft$Les quatre compétences du REMC pour la catégorie B, la validation progressive tracée au livret d'apprentissage, et l'évaluation de départ qui fonde le volume prévisionnel personnalisé du contrat.$mft$,
    2, 50) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : AAC et conduite supervisée ──────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'parcours-aac-cs',
    'AAC et conduite supervisée : les parcours accompagnés',
    $mft$> 🎯 **Objectifs**
> - Maîtriser le parcours AAC : conditions, jalons, avantages.
> - Situer la conduite supervisée et ses cas d'usage.
> - Définir le rôle de l'enseignant : rendez-vous pédagogiques et outillage des accompagnateurs.

## L'apprentissage anticipé de la conduite (AAC)

L'AAC permet de commencer tôt et d'accumuler une vraie expérience de conduite avant l'autonomie. Le parcours se déroule ainsi :

:::timeline
1. Dès 15 ans | Inscription et formation initiale en école de conduite, structurée par les quatre compétences du REMC
2. Phase accompagnée | Conduite avec un ou plusieurs accompagnateurs : au moins un an et environ 3000 km (volumes à vérifier dans les textes en vigueur)
3. Rendez-vous pédagogiques | Deux RVP obligatoires, préparés et animés par l'enseignant
4. Dès 17 ans | Présentation à l'examen pratique
5. Après la réussite | Période probatoire réduite : 2 ans au lieu de 3
:::

L'esprit du dispositif : l'expérience se construit sur des milliers de kilomètres variés (saisons, nuit, pluie, longs trajets, autoroute), sous le regard d'un accompagnateur, AVANT la conduite solo. L'élève arrive à l'examen avec un vécu routier qu'aucune formation classique ne peut offrir, et les statistiques d'accidentalité des novices plaident pour cette maturation longue.

> 📌 **À retenir**
> Depuis janvier 2024, le permis B peut être obtenu dès 17 ans pour TOUS les candidats. L'AAC conserve néanmoins ses atouts propres : l'expérience longue de la phase accompagnée et la période probatoire réduite à 2 ans au lieu de 3, avantage spécifique de ce parcours.

## Les rendez-vous pédagogiques : votre cœur de métier

Les deux RVP rythment la phase accompagnée et sont animés par l'enseignant. Un RVP articule classiquement une phase de conduite (l'élève conduit, l'enseignant observe, l'accompagnateur assiste) et un temps d'échanges : retours sur les situations vécues, difficultés rencontrées, situations encore à découvrir (nuit, intempéries, longs trajets), et réajustement des consignes données à l'accompagnateur. Le RVP n'est ni un contrôle ni une leçon ordinaire : c'est un moment de régulation pédagogique du trio élève, accompagnateur, enseignant.

> ⚠️ **Vigilance**
> Un RVP bâclé (simple heure de conduite facturée) prive l'élève de la valeur ajoutée du dispositif et expose l'école : préparez chaque RVP à partir du livret et des kilomètres réellement parcourus.

## La conduite supervisée (CS)

La conduite supervisée s'adresse aux candidats majeurs : elle est accessible dès 18 ans, après la formation initiale en école, ou après un échec à l'épreuve pratique. Sa logique est la même que l'AAC (rouler accompagné pour gagner de l'expérience), avec davantage de souplesse dans le calendrier.

| Point de comparaison | AAC | Conduite supervisée |
| --- | --- | --- |
| Âge d'accès | Dès 15 ans | Dès 18 ans |
| Point d'entrée | Formation initiale en école | Formation initiale, ou échec à l'examen |
| Cadre de la phase accompagnée | Au moins 1 an et environ 3000 km (à vérifier), 2 RVP obligatoires | Cadre plus souple, mêmes logiques d'accompagnement |
| Période probatoire | Réduite : 2 ans au lieu de 3 | Avantage propre à l'AAC, non prévu ici |

Cas d'usage typiques de la CS : continuer à progresser après un échec sans multiplier les heures en école, consolider l'expérience en attendant une place d'examen, réduire le coût global de la formation.

## Outiller les accompagnateurs

L'accompagnateur ne remplace pas l'enseignant : il fait pratiquer. Votre rôle est de l'outiller : un guide de l'accompagnateur, une grille des situations à couvrir progressivement, un carnet de suivi des trajets, et surtout des consignes de posture : rester calme, anticiper ses indications, débriefer avec bienveillance, ne pas transmettre ses propres habitudes discutables, ne pas reprendre le volant à la moindre erreur.

> 💡 **Astuce**
> Lors de la préparation de la phase accompagnée, faites verbaliser l'accompagnateur sur SA conduite : celui qui reconnaît ses écarts (vitesse, téléphone) est mieux placé pour ne pas les transmettre : et l'élève bénéficie d'un discours cohérent entre l'école et la voiture familiale.

## ✅ Synthèse

- AAC : **dès 15 ans**, formation initiale puis phase accompagnée (au moins 1 an et 3000 km, à vérifier), **2 RVP obligatoires**, examen **dès 17 ans**, probatoire **2 ans au lieu de 3**.
- Depuis **janvier 2024**, le permis B est possible dès 17 ans pour tous : l'AAC garde l'expérience longue et l'avantage probatoire.
- CS : **dès 18 ans**, après formation initiale ou échec : souplesse, mêmes logiques d'accompagnement.
- L'enseignant **prépare et anime les RVP** et **outille les accompagnateurs** : guide, grille de situations, posture.$mft$,
    $mft$Le parcours AAC (dès 15 ans, phase accompagnée, 2 RVP, examen dès 17 ans, probatoire réduite), la conduite supervisée dès 18 ans, et le rôle de l'enseignant auprès des accompagnateurs.$mft$,
    3, 50) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : Le continuum éducatif ───────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'continuum-educatif',
    'Le continuum éducatif : l''éducation routière tout au long de la vie',
    $mft$> 🎯 **Objectifs**
> - Situer les étapes de l'éducation routière, de l'école primaire au post-permis.
> - Connaître les attestations scolaires et leurs équivalents pour les non-scolarisés.
> - Identifier la place de l'enseignant ECSR dans ce continuum : le pont vers le CCP2.

## Une éducation qui commence bien avant l'auto-école

L'éducation routière ne commence pas à 15 ou 18 ans dans une salle de code : elle démarre à l'école primaire et se poursuit toute la vie. Comprendre ce continuum, c'est comprendre où se situe votre métier et vers quoi il peut s'élargir.

:::timeline
1. École primaire | APER : premiers apprentissages de piéton, de passager et de rouleur
2. Classe de cinquième | ASSR 1 : premier socle théorique commun au collège
3. Classe de troisième | ASSR 2 : second jalon scolaire de sécurité routière
4. Dès 14 ans | Permis AM (héritier du BSR) pour conduire un cyclomoteur, après une formation de 8 heures (durée à vérifier dans les textes en vigueur)
5. Formation au permis | Le cœur d'activité de l'école de conduite : REMC, AAC, conduite supervisée
6. Post-permis | Formation complémentaire volontaire, stages de sensibilisation
:::

Pour les personnes non scolarisées en France (ou qui ne peuvent pas justifier des attestations scolaires), l'équivalent est l'**ASR**, attestation de sécurité routière, accessible hors cadre scolaire.

> 🔍 **Zoom**
> Ces jalons ne sont pas décoratifs : ils installent très tôt une culture du risque routier et conditionnent l'accès aux étapes suivantes. L'enseignant qui connaît ce parcours dialogue mieux avec les familles et repère ce qui a déjà été travaillé (ou pas) chez son élève.

## Après le permis : l'éducation continue

Le continuum ne s'arrête pas à la réussite de l'examen :

- **la formation complémentaire volontaire** : suivie par le jeune conducteur pendant sa période probatoire, elle permet d'en réduire la durée (conditions et modalités à vérifier dans les textes en vigueur) : c'est un rendez-vous de consolidation, pas une sanction ;
- **les stages de sensibilisation à la sécurité routière** : ils permettent notamment la récupération de points ; le public y est souvent contraint et adulte, ce qui exige une animation spécifique, très éloignée de la leçon de conduite classique.

> ⚠️ **Vigilance**
> Face à un public de stage (adultes, parfois hostiles, aux profils très variés), les recettes de la formation initiale ne suffisent pas : il faut animer un groupe, faire émerger la parole, travailler les représentations. C'est une compétence professionnelle à part entière.

## La place de l'enseignant ECSR : le pont vers le CCP2

Le titre professionnel ECSR ne forme pas seulement au permis B : son second certificat de compétences professionnelles (CCP2) vise la sensibilisation de TOUS les usagers de la route. Le continuum éducatif est exactement son terrain de jeu :

| Terrain | Action de l'enseignant ECSR |
| --- | --- |
| Milieu scolaire | Interventions de sensibilisation, appui à la préparation des ASSR |
| Deux-roues motorisés | Formation au permis AM des plus jeunes conducteurs |
| Stages | Animation d'actions de sensibilisation, notamment liées à la récupération de points, dans le cadre réglementaire en vigueur |
| Entreprises | Prévention du risque routier professionnel auprès des salariés |
| Post-permis | Accompagnement des conducteurs novices volontaires |

> 🎓 **Pour l'examen**
> Le jury du titre attend que vous sachiez situer votre action dans ce continuum : une intervention en classe de troisième ne se conçoit pas comme une leçon de conduite, et un stage en entreprise ne se conçoit pas comme un cours de code. Public, objectifs, méthodes : tout s'adapte.

> 💡 **Astuce**
> Dès votre formation, collectionnez les occasions d'animer des publics variés (ateliers, réunions d'accompagnateurs, journées sécurité) : ces expériences nourrissent directement le CCP2 et diversifient votre future activité.

## ✅ Synthèse

- Continuum scolaire : **APER (primaire), ASSR 1 (5e), ASSR 2 (3e)**, et **ASR** pour les non-scolarisés.
- **Permis AM** dès 14 ans pour les cyclomoteurs, après une formation courte (8 h, à vérifier).
- Post-permis : **formation complémentaire volontaire** (réduction de probatoire, à vérifier) et **stages de sensibilisation** (récupération de points).
- L'enseignant ECSR intervient sur tout le continuum : école, stages, entreprises : c'est le cœur du **CCP2**.$mft$,
    $mft$Le continuum éducatif : APER, ASSR 1 et 2, ASR, permis AM, puis formation complémentaire post-permis et stages de sensibilisation, avec la place de l'enseignant ECSR et le lien vers le CCP2.$mft$,
    4, 45) RETURNING id INTO v_l4;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : REMC et parcours de formation',
    'Vérifiez le module 2 : philosophie du REMC, matrice GDE, compétences du permis B, parcours AAC et conduite supervisée, continuum éducatif.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Un élève vous demande pourquoi son livret parle d'« aptitudes de vie » alors qu'il veut « juste apprendre à conduire ». Que lui répondez-vous, dans l'esprit du REMC ?$mft$,
    $mft$[
      {"id":"a","label":"Le REMC vise à former un conducteur-citoyen : les attitudes et le mode de vie pèsent sur la sécurité autant que la technique","is_correct":true},
      {"id":"b","label":"C'est une exigence administrative sans effet sur le contenu de la formation","is_correct":false},
      {"id":"c","label":"Cela ne concerne que les candidats inscrits en conduite accompagnée","is_correct":false},
      {"id":"d","label":"C'est un contenu réservé aux stages de récupération de points","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ecsr','module-2','qcm-v1'], 'ECSR-M2-QCM-01', false,
    $mft$Le REMC forme un conducteur-citoyen, pas un passeur d'examen : les facteurs personnels font partie du programme pour tous les élèves, pas seulement en AAC ou en stage.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$En séance, votre élève circule sur un parking désert et enchaîne démarrages, arrêts de précision et marches arrière. Quelle compétence du REMC travaillez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"C1 : maîtriser le maniement du véhicule dans un trafic faible ou nul","is_correct":true},
      {"id":"b","label":"C2 : appréhender la route et circuler dans des conditions normales","is_correct":false},
      {"id":"c","label":"C3 : circuler dans des conditions difficiles","is_correct":false},
      {"id":"d","label":"C4 : pratiquer une conduite autonome, sûre et économique","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ecsr','module-2','qcm-v1'], 'ECSR-M2-QCM-02', false,
    $mft$Trafic faible ou nul + travail du geste = C1. C2 suppose la circulation ordinaire, C3 les conditions difficiles, C4 l'autonomie : trois contextes absents du parking désert.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Au téléphone, une mère vous demande à partir de quel âge sa fille peut s'inscrire en apprentissage anticipé de la conduite. Votre réponse :$mft$,
    $mft$[
      {"id":"a","label":"Dès 15 ans, en commençant par la formation initiale en école de conduite","is_correct":true},
      {"id":"b","label":"Dès 14 ans, comme pour le permis AM","is_correct":false},
      {"id":"c","label":"Dès 16 ans, à condition d'avoir déjà réussi le code","is_correct":false},
      {"id":"d","label":"Dès 17 ans seulement, depuis la réforme de 2024","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ecsr','module-2','qcm-v1'], 'ECSR-M2-QCM-03', false,
    $mft$L'AAC est accessible dès 15 ans et débute par la formation initiale. Les 14 ans correspondent au permis AM ; la réforme de 2024 concerne l'obtention du permis B à 17 ans, pas l'entrée en AAC.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Un père vous indique que son fils, en classe de troisième, doit passer cette année une attestation scolaire de sécurité routière. Laquelle ?$mft$,
    $mft$[
      {"id":"a","label":"L'ASSR 2, passée en classe de troisième","is_correct":true},
      {"id":"b","label":"L'ASSR 1, passée en classe de troisième","is_correct":false},
      {"id":"c","label":"L'APER, passée au collège","is_correct":false},
      {"id":"d","label":"L'ASR, réservée aux collégiens","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ecsr','module-2','qcm-v1'], 'ECSR-M2-QCM-04', false,
    $mft$ASSR 2 = classe de troisième. L'ASSR 1 se passe en cinquième, l'APER à l'école primaire, et l'ASR s'adresse aux personnes non scolarisées.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Votre élève maîtrise parfaitement le véhicule en séance, mais vous apprenez qu'il roule vite le samedi soir quand ses amis sont à bord. Selon la matrice GDE, à quels niveaux se joue principalement ce risque ?$mft$,
    $mft$[
      {"id":"a","label":"Aux niveaux 3 et 4 : contexte du déplacement, influence des pairs et rapport au risque","is_correct":true},
      {"id":"b","label":"Au niveau 1 : c'est un défaut de maniement du véhicule","is_correct":false},
      {"id":"c","label":"Au niveau 2 : il gère mal les intersections","is_correct":false},
      {"id":"d","label":"À aucun niveau : la matrice GDE ne traite pas des comportements","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-2','qcm-v1'], 'ECSR-M2-QCM-05', false,
    $mft$La technique (niveau 1) est acquise : le risque vient du contexte (sortie nocturne, passagers, niveau 3) et des facteurs personnels (pairs, image de soi, niveau 4), précisément ce que la matrice met en évidence.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$À l'issue de l'évaluation de départ d'un nouvel élève, vous annoncez un volume de 27 heures. Quel est le statut exact de ce chiffre ?$mft$,
    $mft$[
      {"id":"a","label":"Un volume prévisionnel personnalisé qui sert de base au contrat, sans pouvoir descendre sous le minimum légal","is_correct":true},
      {"id":"b","label":"Un nombre d'heures garanti pour obtenir le permis","is_correct":false},
      {"id":"c","label":"Un chiffre commercial librement négociable en dessous du minimum légal","is_correct":false},
      {"id":"d","label":"Une simple formalité sans lien avec le contrat de formation","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-2','qcm-v1'], 'ECSR-M2-QCM-06', false,
    $mft$L'évaluation de départ produit un prévisionnel personnalisé inscrit au contrat : ni garantie de réussite, ni variable commerciale, et jamais en dessous du plancher légal.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Votre élève réussit désormais régulièrement insertions et intersections en agglomération. Comment officialisez-vous ce progrès dans la logique du REMC ?$mft$,
    $mft$[
      {"id":"a","label":"Par un bilan de compétences partagé avec l'élève et tracé au livret d'apprentissage","is_correct":true},
      {"id":"b","label":"Par une félicitation orale, sans trace écrite","is_correct":false},
      {"id":"c","label":"En le présentant immédiatement à l'examen pratique","is_correct":false},
      {"id":"d","label":"En réduisant le volume du contrat sans autre formalité","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-2','qcm-v1'], 'ECSR-M2-QCM-07', false,
    $mft$La validation est progressive et TRACÉE : le bilan de compétences au livret fait foi. L'oral ne laisse rien, et une réussite partielle ne justifie ni présentation immédiate ni modification sauvage du contrat.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Votre élève AAC entame sa phase de conduite accompagnée. Quels jalons pédagogiques obligatoires devez-vous planifier avec lui et son accompagnateur ?$mft$,
    $mft$[
      {"id":"a","label":"Deux rendez-vous pédagogiques, préparés et animés par l'enseignant, au cours de la phase accompagnée","is_correct":true},
      {"id":"b","label":"Un examen blanc mensuel en centre d'examen","is_correct":false},
      {"id":"c","label":"Aucun : la famille gère seule la phase accompagnée","is_correct":false},
      {"id":"d","label":"Une nouvelle évaluation de départ tous les six mois","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-2','qcm-v1'], 'ECSR-M2-QCM-08', false,
    $mft$Les 2 RVP sont les jalons obligatoires de l'AAC : l'école reste présente pendant toute la phase accompagnée. L'évaluation de départ, elle, se fait une fois, avant l'entrée en formation.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Un adulte de 25 ans, jamais scolarisé en France, s'inscrit chez vous pour le permis B. Il ne détient ni ASSR 1 ni ASSR 2. Quelle attestation le concerne ?$mft$,
    $mft$[
      {"id":"a","label":"L'ASR, l'attestation prévue pour les personnes non scolarisées","is_correct":true},
      {"id":"b","label":"L'APER, à repasser dans une école primaire","is_correct":false},
      {"id":"c","label":"L'ASSR 2, délivrée uniquement en classe de troisième","is_correct":false},
      {"id":"d","label":"Le permis AM, qui remplace toutes les attestations","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-2','qcm-v1'], 'ECSR-M2-QCM-09', false,
    $mft$L'ASR est l'équivalent hors cadre scolaire des attestations : elle s'obtient sans repasser par le collège. L'APER relève du primaire et le permis AM est un titre de conduite de cyclomoteur, pas une attestation.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Deux de vos anciens élèves obtiennent leur permis B la même semaine : Lina après un parcours AAC, Tom après une filière traditionnelle. Comparez leurs périodes probatoires.$mft$,
    $mft$[
      {"id":"a","label":"Lina : 2 ans ; Tom : 3 ans : le parcours AAC réduit la période probatoire","is_correct":true},
      {"id":"b","label":"3 ans pour les deux : la filière suivie ne change rien","is_correct":false},
      {"id":"c","label":"2 ans pour les deux depuis janvier 2024","is_correct":false},
      {"id":"d","label":"1 an pour Lina, 2 ans pour Tom","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ecsr','module-2','qcm-v1'], 'ECSR-M2-QCM-10', false,
    $mft$La réduction à 2 ans (au lieu de 3) est un avantage propre à l'AAC. La réforme de janvier 2024 a ouvert le permis B à 17 ans pour tous, mais n'a pas aligné les périodes probatoires.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Un collègue conçoit toutes ses séances autour du seul maniement : « le reste viendra tout seul avec l'expérience ». Quelle critique la matrice GDE permet-elle de formuler ?$mft$,
    $mft$[
      {"id":"a","label":"Il ne travaille que le niveau 1, alors que les prises de risque se jouent surtout aux niveaux supérieurs : l'enseignement doit toucher les quatre niveaux","is_correct":true},
      {"id":"b","label":"Aucune : la matrice recommande de se concentrer sur le maniement","is_correct":false},
      {"id":"c","label":"Il devrait remplacer tout le maniement par de la théorie en salle","is_correct":false},
      {"id":"d","label":"La matrice interdit d'enseigner le maniement avant l'examen théorique","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ecsr','module-2','qcm-v1'], 'ECSR-M2-QCM-11', false,
    $mft$La matrice hiérarchise sans exclure : le maniement reste le socle, mais s'y limiter laisse de côté les niveaux 2, 3 et 4, là où se décident les accidents des novices. Elle n'impose ni tout-théorie ni ordre d'examen.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$En février 2024, un candidat de 17 ans issu de la filière traditionnelle (hors AAC) réussit l'épreuve pratique du permis B. Peut-il conduire seul ?$mft$,
    $mft$[
      {"id":"a","label":"Oui : depuis janvier 2024, le permis B peut être obtenu dès 17 ans pour tous les candidats","is_correct":true},
      {"id":"b","label":"Non : il doit attendre 18 ans, seule l'AAC permettait l'examen à 17 ans","is_correct":false},
      {"id":"c","label":"Oui, mais uniquement accompagné d'un titulaire du permis","is_correct":false},
      {"id":"d","label":"Non : l'épreuve pratique est réservée aux candidats majeurs","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ecsr','module-2','qcm-v1'], 'ECSR-M2-QCM-12', false,
    $mft$Depuis janvier 2024, l'obtention du permis B dès 17 ans est ouverte à tous, plus seulement aux élèves AAC : la réussite de l'épreuve donne le droit de conduire seul, sans attendre la majorité.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Un élève pressé vous lance : « apprenez-moi juste à réussir l'examen ». En une phrase, que vise réellement la formation selon le REMC ?$mft$,
   $mft$Former un conducteur-citoyen, autonome et responsable, par une approche par compétences : pas seulement un candidat capable de réussir l'épreuve.$mft$,
   2, 'facile', ARRAY['ecsr','module-2','question-courte'], 'ECSR-M2-QC-01', false,
   $mft$Conducteur-citoyen + approche par compétences attendus.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$À quel âge un jeune peut-il commencer l'AAC, et par quelle étape ce parcours débute-t-il obligatoirement ?$mft$,
   $mft$Dès 15 ans, par la formation initiale en école de conduite, avant la phase de conduite accompagnée.$mft$,
   2, 'facile', ARRAY['ecsr','module-2','question-courte'], 'ECSR-M2-QC-02', false,
   $mft$15 ans + formation initiale d'abord.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Citez les trois attestations du parcours scolaire d'éducation routière et le niveau où chacune se passe.$mft$,
   $mft$L'APER à l'école primaire, l'ASSR 1 en classe de cinquième, l'ASSR 2 en classe de troisième.$mft$,
   2, 'facile', ARRAY['ecsr','module-2','question-courte'], 'ECSR-M2-QC-03', false,
   $mft$Les trois couples attestation/niveau exacts.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Citez, dans l'ordre, les quatre niveaux de la matrice GDE.$mft$,
   $mft$Niveau 1 : maniement du véhicule ; niveau 2 : maîtrise des situations de circulation ; niveau 3 : objectifs et contexte du déplacement ; niveau 4 : projets de vie et aptitudes de vie.$mft$,
   2, 'moyen', ARRAY['ecsr','module-2','question-courte'], 'ECSR-M2-QC-04', false,
   $mft$Les quatre niveaux dans l'ordre.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Énumérez les quatre compétences du REMC pour la catégorie B.$mft$,
   $mft$C1 : maîtriser le maniement du véhicule dans un trafic faible ou nul ; C2 : appréhender la route et circuler dans des conditions normales ; C3 : circuler dans des conditions difficiles et partager la route avec les autres usagers ; C4 : pratiquer une conduite autonome, sûre et économique.$mft$,
   2, 'moyen', ARRAY['ecsr','module-2','question-courte'], 'ECSR-M2-QC-05', false,
   $mft$Les quatre intitulés complets attendus.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Un élève vous demande pourquoi vous lui proposez 30 heures alors que « la loi dit 20 heures ». Que répondez-vous sur le sens de ces deux chiffres ?$mft$,
   $mft$20 heures est le minimum légal de formation pratique en boîte manuelle, un plancher : le volume proposé est un prévisionnel personnalisé issu de l'évaluation de départ, qui reflète le niveau réel de l'élève.$mft$,
   2, 'moyen', ARRAY['ecsr','module-2','question-courte'], 'ECSR-M2-QC-06', false,
   $mft$Plancher légal vs prévisionnel personnalisé issu de l'évaluation.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Avant de présenter un élève AAC à l'examen pratique, quelles conditions de la phase accompagnée vérifiez-vous ?$mft$,
   $mft$Au moins un an de conduite accompagnée et environ 3000 km parcourus (volumes à vérifier dans les textes en vigueur), ainsi que la réalisation des deux rendez-vous pédagogiques obligatoires ; la présentation est possible dès 17 ans.$mft$,
   2, 'moyen', ARRAY['ecsr','module-2','question-courte'], 'ECSR-M2-QC-07', false,
   $mft$Durée + kilométrage (avec prudence) + 2 RVP.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un candidat de 19 ans vient d'échouer à l'épreuve pratique et veut continuer à progresser sans multiplier les heures en école. Quel dispositif lui proposez-vous et pourquoi ?$mft$,
   $mft$La conduite supervisée, accessible dès 18 ans après la formation initiale ou après un échec : il continue à rouler avec un accompagnateur, selon les mêmes logiques d'accompagnement que l'AAC, avec plus de souplesse.$mft$,
   2, 'moyen', ARRAY['ecsr','module-2','question-courte'], 'ECSR-M2-QC-08', false,
   $mft$Conduite supervisée + conditions d'accès.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Après l'obtention du permis, citez deux dispositifs de formation qui jalonnent encore la vie du conducteur, et l'effet principal de chacun.$mft$,
   $mft$La formation complémentaire volontaire post-permis, qui permet de réduire la période probatoire (modalités à vérifier dans les textes en vigueur), et les stages de sensibilisation à la sécurité routière, qui permettent notamment la récupération de points.$mft$,
   2, 'difficile', ARRAY['ecsr','module-2','question-courte'], 'ECSR-M2-QC-09', false,
   $mft$Formation post-permis + stages, avec leurs effets.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Pourquoi dit-on que les niveaux 3 et 4 de la matrice GDE « expliquent » les accidents des jeunes conducteurs davantage que le niveau 1 ?$mft$,
   $mft$Parce que les prises de risque tiennent au contexte du déplacement et aux facteurs personnels (jeunesse, influence des pairs, émotions, projets de vie) bien plus qu'à un défaut de maniement du véhicule.$mft$,
   2, 'difficile', ARRAY['ecsr','module-2','question-courte'], 'ECSR-M2-QC-10', false,
   $mft$Contexte + facteurs personnels vs technique.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Un nouveau collègue, ancien moniteur « à l'ancienne », vous dit : « mon travail, c'est de faire réussir l'examen ». Expliquez-lui la philosophie du REMC et ce qu'elle change concrètement dans la manière de construire les séances.$mft$,
   $mft$Réponse modèle. Le REMC ne vise pas un candidat capable de réussir une épreuve, mais un conducteur-citoyen : une personne autonome, consciente de ses limites, respectueuse des autres usagers, et capable de le rester toute sa vie. Concrètement, cela change trois choses dans la construction des séances. D'abord l'approche par compétences : chaque séance vise des objectifs explicites, annoncés à l'élève et évalués en fin de séance ; on ne « fait pas des heures », on valide des acquis. Ensuite la couverture des quatre niveaux de la matrice GDE : le maniement et les situations de circulation restent le socle, mais l'enseignant travaille aussi le contexte des déplacements (fatigue, horaires, passagers) et les facteurs personnels (image de soi, pression du groupe, rapport au risque), car c'est là que se jouent les accidents des novices. Enfin la posture : l'élève devient acteur, il s'auto-évalue, participe aux bilans et comprend le pourquoi des exercices. Former « pour l'examen » produit des recettes vite oubliées ; former un conducteur-citoyen produit des compétences durables : l'examen n'est alors qu'une étape naturellement franchie.$mft$,
   $mft$Barème /5 : philosophie du conducteur-citoyen opposée au passeur d'examen (1,5 pt) ; approche par compétences avec objectifs et évaluation de séance (1,5 pt) ; référence aux quatre niveaux de la GDE dont les niveaux hauts (1,5 pt) ; posture d'élève acteur (0,5 pt). Erreurs fréquentes : réduire le REMC à un programme officiel de plus ; opposer caricaturalement technique et éducation, alors que les deux se complètent.$mft$,
   5, 'facile', ARRAY['ecsr','module-2','question-redigee'], 'ECSR-M2-QR-01', false,
   $mft$La philosophie du REMC traduite en pratiques de séance.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Décrivez le parcours d'un élève en catégorie B, de l'évaluation de départ à la validation de la quatrième compétence : étapes, outils de traçabilité et rôle des bilans de compétences.$mft$,
   $mft$Réponse modèle. Tout commence par l'évaluation de départ : elle mesure les aptitudes et l'expérience de l'élève et débouche sur un volume prévisionnel personnalisé, inscrit au contrat, qui ne peut pas descendre sous le minimum légal (20 heures en boîte manuelle ; 13 heures en boîte automatique, chiffre à vérifier dans les textes en vigueur). La formation se déroule ensuite selon les quatre compétences du REMC : C1 maîtriser le maniement du véhicule dans un trafic faible ou nul ; C2 appréhender la route et circuler dans des conditions normales ; C3 circuler dans des conditions difficiles et partager la route avec les autres usagers ; C4 pratiquer une conduite autonome, sûre et économique. Chaque compétence se décline en sous-compétences travaillées avec des objectifs de séance explicites. La validation est progressive : quand les sous-compétences sont acquises, l'enseignant organise un bilan de compétences, partagé avec l'élève et tracé au livret d'apprentissage. Le livret constitue la mémoire du parcours : objectifs travaillés, acquis validés, axes restants. La présentation à l'examen intervient quand les quatre compétences sont validées, pas quand le volume initial est épuisé : c'est l'acquisition qui pilote, pas le compteur d'heures.$mft$,
   $mft$Barème /5 : évaluation de départ et prévisionnel personnalisé avec minima légaux dont la prudence sur la boîte automatique (1,5 pt) ; les quatre compétences correctement énoncées (1,5 pt) ; validation progressive par bilans tracés au livret (1,5 pt) ; conclusion : l'acquisition pilote, pas les heures (0,5 pt). Erreurs fréquentes : présenter les 20 heures comme une durée normale de formation ; oublier la traçabilité au livret.$mft$,
   5, 'facile', ARRAY['ecsr','module-2','question-redigee'], 'ECSR-M2-QR-02', false,
   $mft$Le parcours B complet : évaluation, compétences, validation tracée.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Étude de cas. Hugo, 19 ans, réussit toutes les manœuvres et gère bien la circulation en séance. Ses parents vous confient qu'il conduit « autrement » le week-end : musique forte, amis à bord, vitesse. Analysez la situation avec la matrice GDE et proposez des leviers pédagogiques concrets pour vos prochaines séances.$mft$,
   $mft$Réponse modèle. Analyse par la matrice : aux niveaux 1 et 2, Hugo est solide : le maniement et la gestion des situations sont acquis en séance. Le problème se situe aux niveaux 3 et 4. Niveau 3 (contexte du déplacement) : ses trajets à risque ont un profil précis : le week-end, de nuit probablement, avec des passagers, dans un climat festif. Niveau 4 (projets de vie et aptitudes de vie) : la présence des amis change son comportement, ce qui signale un besoin de reconnaissance, une image de soi liée à la prise de risque et une sensibilité à la pression du groupe. Leviers pédagogiques : d'abord faire émerger le sujet sans moraliser : auto-évaluation (« ta conduite est-elle la même selon les personnes à bord ? »), commentaires de situations vécues, échanges sur des scénarios (sortie, fatigue, musique, passagers). Ensuite travailler des stratégies concrètes : anticiper le contexte (départ, itinéraire, état de forme), préparer des réponses à la pression des pairs, identifier ses propres signaux d'excitation. Enfin adapter les séances : varier les conditions (nuit, pluie) et questionner systématiquement le contexte après chaque situation. La technique seule ne corrigera rien : le risque d'Hugo se joue en haut de la matrice.$mft$,
   $mft$Barème /5 : diagnostic correct par niveaux (1 et 2 acquis, 3 et 4 en cause) (1,5 pt) ; lecture fine du niveau 4 (pairs, image de soi, reconnaissance) (1 pt) ; leviers d'émergence sans moralisation (auto-évaluation, scénarios) (1,5 pt) ; adaptation concrète des séances et du questionnement (1 pt). Erreurs fréquentes : proposer davantage d'exercices techniques ; moraliser au lieu de faire verbaliser.$mft$,
   5, 'moyen', ARRAY['ecsr','module-2','question-redigee'], 'ECSR-M2-QR-03', false,
   $mft$Cas Hugo : diagnostic GDE et leviers pédagogiques.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Comparez l'apprentissage anticipé de la conduite et la conduite supervisée : conditions d'accès, déroulement, intérêts pour l'élève, et ce qui change (ou pas) dans votre travail d'enseignant.$mft$,
   $mft$Réponse modèle. Accès : l'AAC s'adresse aux jeunes dès 15 ans ; la conduite supervisée concerne les candidats majeurs, dès 18 ans, après la formation initiale ou après un échec à l'examen. Déroulement : dans les deux cas, l'élève suit d'abord une formation initiale en école, puis conduit avec un accompagnateur. L'AAC impose un cadre structuré : au moins un an de conduite accompagnée et environ 3000 km (volumes à vérifier dans les textes en vigueur), avec deux rendez-vous pédagogiques obligatoires ; l'examen est possible dès 17 ans. La conduite supervisée est plus souple : elle offre l'expérience de la conduite accompagnée sans le formalisme complet de l'AAC, avec les mêmes logiques d'accompagnement. Intérêts : l'AAC construit une expérience longue avant l'autonomie et réduit la période probatoire (2 ans au lieu de 3) ; la supervisée permet de consolider à moindre coût entre deux présentations ou après la formation. Pour l'enseignant, le cœur du travail reste identique : préparer la phase accompagnée, outiller les accompagnateurs (consignes, progression, posture), animer les rendez-vous pédagogiques pour l'AAC, et maintenir le lien pédagogique pendant toute la phase : l'accompagnateur prolonge la formation, il ne la remplace pas.$mft$,
   $mft$Barème /5 : conditions d'accès exactes des deux dispositifs (1,5 pt) ; cadre AAC complet (durée, kilométrage avec prudence, 2 RVP, examen dès 17 ans) (1,5 pt) ; intérêts comparés dont la probatoire réduite propre à l'AAC (1 pt) ; rôle constant de l'enseignant auprès des accompagnateurs (1 pt). Erreurs fréquentes : attribuer la réduction de probatoire à la conduite supervisée ; présenter la CS comme une formation sans école.$mft$,
   5, 'moyen', ARRAY['ecsr','module-2','question-redigee'], 'ECSR-M2-QR-04', false,
   $mft$AAC et CS comparés point par point, côté élève et côté enseignant.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Vous devez animer le premier rendez-vous pédagogique d'un élève AAC, accompagné de son père. Construisez votre préparation et votre déroulé : objectifs, contenus, place de l'accompagnateur, et outillage que vous lui remettez.$mft$,
   $mft$Réponse modèle. Préparation : relire le livret d'apprentissage de l'élève (compétences validées, axes de progrès), rassembler les données de la phase accompagnée (kilomètres parcourus, types de trajets), préparer un support simple pour l'accompagnateur et prévoir les deux volets du rendez-vous : une partie pratique en conduite et une partie d'échanges. Déroulé : accueillir et poser le cadre (un moment de formation, pas un contrôle) ; phase de conduite avec l'élève au volant, le père à bord, pour objectiver le niveau réel après plusieurs mois de conduite accompagnée ; puis temps d'échange à trois : ce qui progresse, ce qui inquiète, les situations rencontrées (nuit, pluie, longs trajets) et celles à rechercher avant le prochain jalon. Place de l'accompagnateur : le valoriser et le repositionner : il n'enseigne pas, il fait pratiquer ; rappeler les attitudes utiles (calme, anticipation des consignes, débriefing bienveillant) et les pièges (reprendre le volant à la moindre erreur, transmettre ses propres habitudes discutables). Outillage remis : guide de l'accompagnateur, grille des situations à couvrir, carnet de suivi des trajets, et objectifs concrets pour la période suivante. Conclure en fixant le cap vers le second rendez-vous pédagogique obligatoire.$mft$,
   $mft$Barème /5 : préparation à partir du livret et des données de conduite (1 pt) ; déroulé en deux volets (conduite observée puis échanges) (1,5 pt) ; positionnement de l'accompagnateur : attitudes et pièges (1,5 pt) ; outillage remis et cap vers le second RVP (1 pt). Erreurs fréquentes : transformer le RVP en leçon de conduite ordinaire ; oublier la place active de l'accompagnateur.$mft$,
   5, 'moyen', ARRAY['ecsr','module-2','question-redigee'], 'ECSR-M2-QR-05', false,
   $mft$Le premier RVP construit de bout en bout, accompagnateur inclus.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Cas pratique. L'évaluation de départ de Sarah aboutit à un prévisionnel de 30 heures. Son père conteste : « la loi dit 20 heures, vous gonflez la facture ». Construisez votre réponse professionnelle : sens du minimum légal, logique du prévisionnel personnalisé, et traçabilité qui protège l'école comme l'élève.$mft$,
   $mft$Réponse modèle. Le point de droit d'abord : les 20 heures sont un minimum légal de formation pratique en boîte manuelle, en dessous duquel aucun contrat ne peut descendre ; ce n'est ni une moyenne, ni un objectif, ni une promesse de réussite. Le prévisionnel de 30 heures repose, lui, sur l'évaluation de départ de Sarah : un diagnostic individuel de ses aptitudes et de son expérience, réalisé avant la signature, qui fonde un volume personnalisé. Vendre 20 heures à une élève évaluée à 30, ce serait programmer un échec coûteux : heures ajoutées au fil de l'eau, présentation prématurée à l'examen, échec et délais de repassage. La réponse au père articule donc trois messages : le sens du minimum légal (un plancher de protection, pas un tarif), la logique du prévisionnel (issu d'une évaluation objective et traçable, dont on peut lui montrer la méthode et le résultat), et la souplesse du dispositif (le volume est prévisionnel : si Sarah progresse plus vite, les bilans de compétences tracés au livret le montreront et le parcours s'ajustera). La traçabilité protège les deux parties : évaluation conservée, objectifs de séance, bilans validés : le père peut suivre chaque étape de la progression réelle.$mft$,
   $mft$Barème /5 : statut exact du minimum légal (plancher, pas objectif) (1,5 pt) ; prévisionnel fondé sur l'évaluation de départ et risques d'un contrat sous-évalué (1,5 pt) ; caractère ajustable du prévisionnel via les bilans (1 pt) ; traçabilité protectrice pour les deux parties (1 pt). Erreurs fréquentes : céder commercialement en signant 20 heures ; répondre sur le ton du conflit au lieu d'expliquer la méthode.$mft$,
   5, 'moyen', ARRAY['ecsr','module-2','question-redigee'], 'ECSR-M2-QR-06', false,
   $mft$Objection « 20 heures » : la réponse pédagogique et contractuelle.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Votre école de conduite veut développer son activité au-delà du permis B : interventions en milieu scolaire, post-permis, sensibilisation en entreprise. Construisez un plan d'action qui s'appuie sur le continuum éducatif, en précisant la place de l'enseignant ECSR à chaque étape et le lien avec le CCP2 du titre.$mft$,
   $mft$Réponse modèle. Le continuum éducatif donne la carte des publics : avant le permis, pendant, après. Étape 1 : cartographier les publics locaux : écoles et collèges (APER, préparation aux ASSR 1 et 2), jeunes dès 14 ans (permis AM), personnes non scolarisées (ASR), conducteurs novices (post-permis volontaire), entreprises (risque routier professionnel), publics des stages de sensibilisation. Étape 2 : construire les offres : interventions en établissement scolaire (ateliers adossés aux ASSR), module post-permis volontaire présenté comme consolidation de la période probatoire (effets et modalités à vérifier dans les textes en vigueur), ateliers de prévention en entreprise (situations vécues, engagement des salariés). Étape 3 : outiller les enseignants : ces actions relèvent du CCP2 du titre (sensibiliser tous les usagers de la route) : concevoir des séquences collectives, animer des groupes hétérogènes, évaluer autrement qu'en voiture. Étape 4 : formaliser des partenariats (établissements, collectivités, employeurs) et un calendrier annuel. Étape 5 : mesurer et ajuster (participation, satisfaction, actions renouvelées). L'enseignant y gagne une activité diversifiée, moins dépendante du seul permis B ; l'école y gagne un ancrage local ; le territoire y gagne une éducation routière continue, de l'école primaire à l'entreprise.$mft$,
   $mft$Barème /5 : cartographie des publics adossée au continuum (1,5 pt) ; offres concrètes par public avec prudence sur le post-permis (1,5 pt) ; lien explicite avec le CCP2 et les compétences d'animation collective (1,5 pt) ; partenariats et mesure des résultats (0,5 pt). Erreurs fréquentes : dupliquer la leçon de conduite pour tous les publics ; oublier que le CCP2 exige des méthodes d'animation de groupe spécifiques.$mft$,
   5, 'difficile', ARRAY['ecsr','module-2','question-redigee'], 'ECSR-M2-QR-07', false,
   $mft$Diversification par le continuum : publics, offres, CCP2.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Montrez comment les quatre compétences du REMC pour la catégorie B permettent de travailler les quatre niveaux de la matrice GDE. Illustrez avec, pour chaque compétence, un exemple de séance ou de questionnement qui « monte » vers les niveaux 3 et 4.$mft$,
   $mft$Réponse modèle. Les quatre compétences du REMC portent en elles la montée dans la matrice GDE. C1 (maniement dans un trafic faible ou nul) travaille d'abord le niveau 1 : mais dès ce stade, l'auto-évaluation (« comment juges-tu ta manœuvre ? ») installe la connaissance de soi, embryon du niveau 4. C2 (conditions normales de circulation) couvre le niveau 2 : la séance monte d'un étage en questionnant les choix : « pourquoi ce carrefour t'a-t-il surpris ? qu'aurais-tu changé dans ton itinéraire ? » (niveau 3). C3 (conditions difficiles, partage de la route) est le terrain naturel des niveaux 2 et 3 : conduite de nuit ou sous la pluie, échanges sur la décision de partir, l'état de forme, l'adaptation aux usagers vulnérables ; le questionnement touche aussi le niveau 4 : « qu'est-ce qui te pousse à maintenir ta vitesse quand tu es suivi de près ? ». C4 (conduite autonome, sûre et économique) est la compétence des niveaux hauts par excellence : trajets autonomes préparés par l'élève (choix d'itinéraire et d'horaire, niveau 3), débriefing sur ses tendances personnelles, sa gestion des pressions et ses projets de mobilité (niveau 4). Chaque compétence ancre ainsi la technique tout en faisant monter l'élève vers les étages où se joue le risque réel.$mft$,
   $mft$Barème /5 : correspondance globale compétences/niveaux correctement posée (1,5 pt) ; un exemple pertinent de questionnement montant pour C1 et C2 (1,5 pt) ; un exemple pertinent pour C3 et C4 dont le niveau 4 (1,5 pt) ; conclusion sur le risque réel situé aux niveaux hauts (0,5 pt). Erreurs fréquentes : plaquer une correspondance rigide un niveau par compétence ; proposer des questionnements purement techniques qui ne montent jamais.$mft$,
   5, 'difficile', ARRAY['ecsr','module-2','question-redigee'], 'ECSR-M2-QR-08', false,
   $mft$Le croisement REMC/GDE illustré séance par séance.$mft$);

  RAISE NOTICE 'Module 2 ECSR créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $ecsrm2$;
