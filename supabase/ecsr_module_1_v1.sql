-- =====================================================================
-- ECSR : MODULE 1 : LE MÉTIER ET LE TITRE ECSR
-- v1 (juillet 2026)
-- Public : futurs enseignants de la conduite et de la sécurité routière
-- (reconversions fréquentes). Métier, titre professionnel et ses deux
-- CCP, autorisation d'enseigner, écosystème des écoles de conduite.
-- ⚠ STATUT : active = false (« à valider »). Idempotent.
-- =====================================================================

DO $ecsrm1$
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

  DELETE FROM public.question_bank WHERE source_ref LIKE 'ECSR-M1-%';
  DELETE FROM public.modules WHERE slug = 'ecsr-metier-titre';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 1 : Le métier et le titre ECSR',
    'ecsr-metier-titre', v_bloc,
    'Le métier d''enseignant de la conduite, le titre professionnel et ses deux CCP, l''autorisation d''enseigner et l''écosystème des écoles de conduite.',
    'debutant', 300, 10) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 10, true);

  -- ─── Leçon 1 : Le métier d'enseignant ──────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'le-metier-d-enseignant',
    'Enseignant de la conduite : pédagogue avant tout',
    $mft$> 🎯 **Objectifs**
> - Comprendre le cœur du métier : former des conducteurs sûrs et autonomes.
> - Identifier les lieux d'exercice et les publics rencontrés.
> - Mesurer les qualités attendues et les conditions réelles (rythmes, samedis).

## Pédagogue avant tout

Oubliez l'image du « moniteur » qui fait répéter des créneaux jusqu'à ce que « ça passe ». L'enseignant de la conduite et de la sécurité routière est un pédagogue : il analyse les besoins d'un apprenant, fixe des objectifs, construit une progression, choisit des méthodes, évalue et remédie. Sa mission ne s'arrête pas à la réussite de l'examen : il construit des conducteurs **sûrs et autonomes**, capables d'analyser une situation de circulation et de décider seuls, longtemps après avoir quitté l'école de conduite.

Cette différence change tout au quotidien : face à un élève qui échoue trois fois le même demi-tour, le répétiteur fait recommencer ; le pédagogue cherche la cause (où porte le regard ? quels repères ? quel niveau de stress ?) et adapte son approche.

## Où exerce-t-on ?

| Lieu d'exercice | Ce qu'on y fait |
| --- | --- |
| École de conduite traditionnelle | Leçons individuelles, séances collectives, accompagnement à l'examen |
| École en ligne | Mêmes leçons, mais réservation et suivi via une plateforme, élèves très divers |
| Association d'insertion | Publics éloignés de l'emploi pour qui le permis est un levier de retour à l'activité |
| Post-permis | Perfectionnement de conducteurs déjà titulaires du permis |
| Entreprise | Sensibilisation des salariés au risque routier professionnel |

Un même titre ouvre donc des exercices très différents : du face-à-face pédagogique en circulation à l'animation collective devant un groupe de salariés.

## Les qualités qui font la différence

Trois qualités reviennent chez tous les bons enseignants : la **patience** (chaque élève a son rythme), l'**observation** (détecter le regard mal placé, la crispation sur le volant, la fatigue) et l'**adaptation** (changer de méthode quand la première ne fonctionne pas, ajuster son vocabulaire au public).

> ⚠️ **Attention**
> La spécificité absolue du métier : la **double tâche permanente**. En leçon, vous enseignez ET vous garantissez la sécurité en même temps : surveiller l'environnement, anticiper l'erreur de l'élève, être prêt à intervenir, tout en continuant d'expliquer. Cette vigilance ne se relâche jamais, même à la trentième leçon de la semaine.

## Rythmes et conditions réelles

Parlons franchement, surtout aux candidats en reconversion : les élèves sont disponibles quand les autres ne travaillent pas. Les journées comportent souvent de larges amplitudes (tôt le matin, fin de journée) et le samedi est fréquemment travaillé. En contrepartie, beaucoup d'enseignants apprécient l'autonomie de leur volant, la variété des publics et le sentiment d'utilité : chaque permis obtenu change concrètement une vie.

## Et après ? Les évolutions

:::flow
1. Enseignant | Leçons individuelles et actions collectives
2. Spécialisation | Post-permis, publics en insertion, interventions en entreprise
3. Responsabilités | Gérant d'école de conduite, intervenant sécurité routière
4. Formation de formateurs | Former les futurs enseignants
:::

> 🔍 **Focus**
> Pour former à son tour les futurs enseignants, il existait historiquement le BAFM (brevet d'aptitude à la formation des moniteurs). Ce diplôme a laissé place à un titre de formateur d'enseignants de la conduite : vérifiez l'intitulé exact et les conditions d'accès dans les textes en vigueur au moment de votre projet.

> 💡 **Astuce**
> Les reconversions réussies s'appuient sur les acquis du premier métier : un ancien commercial excelle dans la relation avec les élèves, une ancienne infirmière dans la gestion du stress. Votre parcours n'est pas un handicap, c'est un capital pédagogique.

## ✅ Synthèse

- Le métier : **pédagogue** qui construit des conducteurs **sûrs et autonomes**, pas un répétiteur de manœuvres.
- Lieux variés : écoles traditionnelles et en ligne, associations d'insertion, post-permis, entreprises.
- Qualités : patience, observation, adaptation ; et la **double tâche permanente** : enseigner ET garantir la sécurité.
- Conditions réelles : amplitudes, samedis ; évolutions possibles vers la formation de formateurs, la gérance ou la sécurité routière.$mft$,
    $mft$Le métier réel (pédagogue, pas répétiteur : des conducteurs sûrs et autonomes), les lieux d'exercice, les qualités (patience, observation, adaptation, double tâche), les rythmes et les évolutions.$mft$,
    1, 45) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : Le titre professionnel ──────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'le-titre-professionnel',
    'Le titre professionnel ECSR et ses deux CCP',
    $mft$> 🎯 **Objectifs**
> - Situer le titre professionnel ECSR : niveau, ministère, histoire.
> - Distinguer les deux CCP et ce qu'ils recouvrent concrètement.
> - Choisir sa voie d'accès et comprendre la session d'examen.

## Un titre du ministère du Travail

Le métier s'ouvre par le **titre professionnel ECSR** (enseignant de la conduite et de la sécurité routière), un titre de **niveau 5** (équivalent bac+2) délivré par le **ministère du Travail**. Il remplace depuis **2016** l'ancien BEPECASER. Ce changement n'est pas qu'administratif : le titre est construit autour de compétences professionnelles évaluées en situation, et non d'épreuves purement académiques.

## Deux CCP, deux facettes du métier

Le titre se compose de **deux certificats de compétences professionnelles** (CCP) :

| CCP | Intitulé | Concrètement |
| --- | --- | --- |
| CCP 1 | Former des apprenants conducteurs par des actions individuelles et collectives, dans le respect des cadres réglementaires | Leçons de conduite, séances collectives en salle, évaluation et suivi des apprenants |
| CCP 2 | Sensibiliser l'ensemble des usagers de la route à l'adoption de comportements sûrs et respectueux de l'environnement | Actions de sensibilisation : salariés d'entreprise, conducteurs expérimentés, éco-conduite |

Retenez la logique : le CCP 1 regarde vers l'**apprenant conducteur** (celui qui apprend à conduire), le CCP 2 regarde vers **tous les usagers de la route**, y compris ceux qui conduisent depuis vingt ans.

> 📌 **À retenir**
> Les deux CCP sont nécessaires pour obtenir le titre complet. Cette double compétence explique la variété des débouchés vus à la leçon 1 : l'école de conduite mobilise surtout le CCP 1, l'intervention en entreprise mobilise le CCP 2.

## Trois voies d'accès

| Voie | Pour qui ? |
| --- | --- |
| Formation continue en centre agréé | Le parcours classique : formation suivie dans un centre agréé, souvent dans le cadre d'une reconversion financée |
| Alternance | Contrat avec une école de conduite : on se forme en centre ET on pratique en entreprise |
| VAE (validation des acquis de l'expérience) | Les candidats qui justifient d'une expérience en rapport direct avec le titre et la font valider |

> 💡 **Astuce**
> Avant de choisir, vérifiez trois choses : votre financement (dispositifs de reconversion), la présence d'un centre agréé accessible, et pour l'alternance, une école prête à vous accueillir. La bonne voie est celle qui tient jusqu'au bout, pas la plus rapide sur le papier.

## La session d'examen

:::timeline
1. **Mises en situation professionnelle** : le candidat conduit des actions de formation ou de sensibilisation devant des évaluateurs professionnels.
2. **Dossier professionnel** : le candidat y décrit et analyse des situations de travail vécues pendant son parcours.
3. **Entretiens avec le jury** : échanges sur les pratiques, les choix pédagogiques et la maîtrise du référentiel du métier.
:::

> ⚠️ **Attention**
> Les modalités précises (durées, ordre des épreuves, critères détaillés) relèvent du référentiel d'évaluation en vigueur : elles peuvent évoluer. Procurez-vous systématiquement la version applicable à VOTRE session auprès de votre centre agréé, plutôt que de vous fier à des témoignages datés trouvés en ligne.

> 🎓 **Conseil de formateur**
> Pensez le titre comme un permis de pédagogie : le jury cherche moins la récitation de règles que la capacité à expliquer VOS choix (pourquoi cette méthode, cette progression, ce vocabulaire pour ce public). Entraînez-vous à justifier chacun de vos gestes professionnels.

## ✅ Synthèse

- Titre professionnel ECSR : **niveau 5** (équivalent bac+2), délivré par le **ministère du Travail**, remplaçant du BEPECASER depuis **2016**.
- **CCP 1** : former des apprenants conducteurs (actions individuelles et collectives, cadres réglementaires) ; **CCP 2** : sensibiliser tous les usagers (comportements sûrs et respectueux de l'environnement).
- Trois voies : **formation continue en centre agréé, alternance, VAE**.
- Session : mises en situation professionnelle, dossier professionnel, entretiens avec le jury ; modalités précises à vérifier dans le référentiel en vigueur.$mft$,
    $mft$Le titre ECSR (niveau 5, ministère du Travail, remplaçant du BEPECASER depuis 2016), les deux CCP distingués, les trois voies d'accès et la session d'examen avec prudence sur le référentiel en vigueur.$mft$,
    2, 45) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : L'autorisation d'enseigner ──────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'autorisation-d-enseigner',
    'L''autorisation d''enseigner',
    $mft$> 🎯 **Objectifs**
> - Comprendre pourquoi le titre seul ne permet pas d'enseigner.
> - Connaître les conditions de délivrance de l'autorisation d'enseigner.
> - Identifier les obligations en poste : contrôle, véhicule école.

## Le titre ne suffit pas

Diplôme en poche, vous ne pouvez PAS encore donner de leçon. L'exercice du métier exige une **autorisation d'enseigner**, délivrée par le **préfet**. Elle est **personnelle** : elle vous suit, que vous soyez salarié d'une école, indépendant, ou que vous changiez d'employeur. Ne la confondez pas avec l'agrément de l'école (leçon 4) : l'agrément couvre l'établissement, l'autorisation couvre l'enseignant.

## Les conditions de délivrance

| Condition | Contenu |
| --- | --- |
| Qualification | Être titulaire du titre ECSR ou d'un diplôme équivalent |
| Permis | Permis B hors période probatoire (au moins 2 ans) |
| Aptitude médicale | Contrôle médical auprès d'un médecin agréé |
| Âge et honorabilité | Conditions d'âge et d'honorabilité exigées par la réglementation |

> ⚠️ **Attention**
> Les conditions exactes d'âge et d'honorabilité (nature des vérifications effectuées) relèvent des textes en vigueur : elles doivent être vérifiées auprès de votre préfecture au moment de la demande. Ne partez jamais d'un forum ou d'un souvenir de promotion précédente.

:::flow
1. Titre obtenu | Titre ECSR ou diplôme équivalent
2. Dossier | Demande auprès de la préfecture
3. Vérifications | Permis, aptitude médicale, âge, honorabilité
4. Délivrance | Autorisation d'enseigner par le préfet
5. Renouvellement | Avant l'échéance de validité
:::

## Une validité limitée

L'autorisation d'enseigner n'est pas acquise à vie : sa validité est limitée dans le temps (5 ans renouvelable, durée à vérifier dans les textes en vigueur). Notez l'échéance dès la délivrance et anticipez le renouvellement : un enseignant dont l'autorisation a expiré ne peut plus exercer, même excellent, même en poste depuis des années.

## En cas de contrôle

Salarié ou indépendant, l'enseignant doit pouvoir **présenter son autorisation d'enseigner** en cas de contrôle. Réflexe simple : l'avoir toujours avec soi en leçon, exactement comme le conducteur a son permis.

> ❌ **Piège à éviter**
> « L'école est agréée, donc je suis couvert. » Faux : l'agrément de l'établissement ne remplace jamais l'autorisation personnelle de l'enseignant. Un gérant qui fait travailler un enseignant sans autorisation valide met en danger l'école, l'enseignant et les élèves.

## Le véhicule école

L'outil de travail quotidien obéit lui aussi à des exigences propres :

- **double commande** : l'enseignant doit pouvoir agir sur le véhicule (c'est le support matériel de la double tâche vue en leçon 1) ;
- **signalétique** : le véhicule est identifiable comme véhicule école ;
- **assurance spécifique** : l'usage école doit être couvert par un contrat adapté.

> 💡 **Astuce**
> À l'embauche, jetez un œil professionnel au véhicule qu'on vous confie : double commande entretenue, signalétique en place, assurance adaptée à l'usage école. C'est votre sécurité juridique autant que physique.

## ✅ Synthèse

- Exercer exige l'**autorisation d'enseigner** délivrée par le **préfet** : personnelle, distincte de l'agrément de l'école.
- Conditions : titre ECSR (ou équivalent), permis B **hors période probatoire** (au moins 2 ans), **aptitude médicale** (médecin agréé), conditions d'âge et d'honorabilité (à vérifier).
- Validité limitée (5 ans renouvelable, à vérifier) : anticiper le renouvellement ; la **présenter en cas de contrôle**.
- Véhicule école : **double commande, signalétique, assurance spécifique**.$mft$,
    $mft$L'autorisation d'enseigner délivrée par le préfet : conditions (titre, permis B hors probatoire, aptitude médicale, âge et honorabilité à vérifier), validité limitée, présentation en contrôle, véhicule école.$mft$,
    3, 40) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : L'écosystème et le cadre ────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'ecosysteme-et-cadre',
    'L''écosystème de l''école de conduite',
    $mft$> 🎯 **Objectifs**
> - Distinguer agrément de l'établissement et autorisation de l'enseignant.
> - Connaître le cadre commercial : label qualité, contrat, livret.
> - Situer les acteurs institutionnels autour de l'école de conduite.

## L'agrément : la porte d'entrée de l'école

Une école de conduite ne s'ouvre pas librement : l'établissement doit détenir un **agrément préfectoral**, qui porte sur l'**exploitant**, le **local** et les **moyens** de l'école. C'est le pendant, côté établissement, de votre autorisation d'enseigner : deux autorisations distinctes, deux titulaires différents, et l'une ne remplace jamais l'autre.

> 🔍 **Focus**
> En pratique, un contrôle peut porter sur les deux niveaux : l'agrément de l'établissement et l'autorisation de chaque enseignant. Une école en règle, c'est les deux à jour.

## Le label qualité

Un label qualité des formations existe au sein des écoles de conduite : il repose sur un référentiel qualité et ouvre des avantages, comme l'accès au dispositif du permis à 1 euro ou l'utilisation de contrats types.

> ⚠️ **Attention**
> Les contours actuels du label (critères, avantages exacts, articulation avec les autres obligations qualité) doivent être vérifiés dans les textes et référentiels en vigueur. Retenez le principe : une démarche qualité formalisée ouvre des avantages commerciaux réels ; les détails se vérifient au moment où l'école s'engage.

## Le contrat avec l'élève

La relation avec l'élève est contractualisée par écrit :

- une **évaluation de départ** situe le niveau de l'élève et permet de proposer un volume de formation ;
- le **contrat écrit** détaille les prestations, les **forfaits** et leurs prix, ainsi que les conditions de **résiliation** ;
- le suivi de la formation s'appuie sur le **livret d'apprentissage**, avec un suivi désormais dématérialisé.

> 📌 **À retenir**
> L'évaluation de départ précède le contrat : on ne vend pas un forfait avant d'avoir évalué le besoin. C'est à la fois une obligation, une protection du consommateur et un acte pédagogique : votre première évaluation d'enseignant, en somme.

## Les acteurs institutionnels

| Acteur | Rôle |
| --- | --- |
| Préfecture / DDT | Agréments des établissements, autorisations, attribution des places d'examen |
| Délégué au permis de conduire et IPCSR | Le délégué pilote l'organisation des examens ; les inspecteurs (IPCSR) font passer les épreuves |
| ANTS | Portail des inscriptions et démarches dématérialisées liées au permis |

## Le parcours d'un élève, vu du cadre

:::flow
1. Évaluation de départ | Situer le niveau, proposer un volume de formation
2. Contrat écrit | Prestations, forfaits, résiliation
3. Formation | Leçons tracées dans le livret d'apprentissage
4. Inscription | Démarches via l'ANTS
5. Place d'examen | Attribuée via la préfecture / DDT
6. Examen | Épreuve évaluée par un IPCSR
:::

Chaque maillon de ce parcours engage l'école : un contrat mal rédigé, un livret non tenu ou une inscription ANTS oubliée se paient en litiges, en retards d'examen et en réputation.

> 💡 **Astuce**
> Même salarié « simple enseignant », comprenez ce cadre : c'est vous qui répondez aux questions des élèves (« pourquoi je n'ai pas encore ma place d'examen ? »), et c'est souvent l'enseignant qui détecte le premier un dossier mal parti.

## ✅ Synthèse

- **Agrément préfectoral** de l'établissement (exploitant, local, moyens) : distinct de l'autorisation d'enseigner.
- **Label qualité** : référentiel qualité, avantages (permis à 1 euro, contrats types) ; contours actuels à vérifier.
- Relation élève : **évaluation de départ**, puis **contrat écrit** (forfaits, résiliation), suivi par le **livret d'apprentissage** dématérialisé.
- Acteurs : **préfecture/DDT** (agréments, places d'examen), **délégué au permis et IPCSR** (examens), **ANTS** (inscriptions).$mft$,
    $mft$L'agrément préfectoral de l'établissement, le label qualité (avantages à vérifier), le contrat écrit précédé de l'évaluation de départ, le livret d'apprentissage dématérialisé et les acteurs institutionnels.$mft$,
    4, 45) RETURNING id INTO v_l4;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : Le métier et le titre ECSR',
    'Vérifiez le module 1 : le métier, le titre professionnel et ses CCP, l''autorisation d''enseigner et l''écosystème des écoles de conduite.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Un proche vous lance : « moniteur, c'est juste faire répéter des créneaux jusqu'à ce que ça passe ». Quelle réponse correspond à la réalité du métier ?$mft$,
    $mft$[
      {"id":"a","label":"L'enseignant est un pédagogue : il construit des conducteurs sûrs et autonomes, en analysant les besoins et en adaptant ses méthodes","is_correct":true},
      {"id":"b","label":"C'est exact : l'essentiel du métier consiste à faire répéter les manœuvres de l'examen","is_correct":false},
      {"id":"c","label":"Le métier consiste surtout à surveiller que l'élève ne commette pas d'infraction","is_correct":false},
      {"id":"d","label":"L'enseignant applique un programme identique pour tous les élèves","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ecsr','module-1','qcm-v1'], 'ECSR-M1-QCM-01', false,
    $mft$Le cœur du métier est pédagogique : diagnostiquer, adapter, rendre autonome. La répétition mécanique, la surveillance seule ou le programme unique ignorent l'analyse des besoins propre à chaque élève.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Votre conseiller en évolution professionnelle vous demande de préciser la nature exacte du titre ECSR que vous visez. Que répondez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Un titre professionnel de niveau 5 (équivalent bac+2) délivré par le ministère du Travail, qui remplace le BEPECASER depuis 2016","is_correct":true},
      {"id":"b","label":"Un diplôme universitaire de niveau licence délivré par l'Éducation nationale","is_correct":false},
      {"id":"c","label":"Une attestation délivrée par la préfecture après un simple stage pratique","is_correct":false},
      {"id":"d","label":"Un certificat interne délivré par les écoles de conduite elles-mêmes","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ecsr','module-1','qcm-v1'], 'ECSR-M1-QCM-02', false,
    $mft$Le titre ECSR relève du ministère du Travail (niveau 5, équivalent bac+2) et succède au BEPECASER depuis 2016. La préfecture délivre l'autorisation d'enseigner, pas le titre ; l'université et les écoles n'interviennent pas dans sa délivrance.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Titre ECSR en poche, une école veut vous faire commencer les leçons lundi. Que devez-vous impérativement détenir avant votre première leçon ?$mft$,
    $mft$[
      {"id":"a","label":"L'autorisation d'enseigner, délivrée par le préfet","is_correct":true},
      {"id":"b","label":"Uniquement votre titre ECSR : il vaut autorisation d'exercer","is_correct":false},
      {"id":"c","label":"Une carte professionnelle délivrée par l'école qui vous embauche","is_correct":false},
      {"id":"d","label":"Rien de plus : l'agrément préfectoral de l'école couvre tous ses salariés","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ecsr','module-1','qcm-v1'], 'ECSR-M1-QCM-03', false,
    $mft$Le titre ne vaut pas autorisation : il en est une condition. L'autorisation d'enseigner est personnelle et préfectorale ; l'agrément couvre l'établissement, pas l'enseignant, et l'école ne délivre aucune carte valant droit d'exercer.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Une élève souhaite s'inscrire dans votre école pour préparer le permis B. Dans quel ordre s'enchaînent les premières étapes ?$mft$,
    $mft$[
      {"id":"a","label":"Évaluation de départ, puis signature du contrat écrit détaillant forfaits et conditions de résiliation","is_correct":true},
      {"id":"b","label":"Signature du contrat, puis évaluation de départ si l'élève le demande","is_correct":false},
      {"id":"c","label":"Paiement du forfait complet, puis évaluation en fin de formation","is_correct":false},
      {"id":"d","label":"Inscription à l'examen d'abord, contrat ensuite","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ecsr','module-1','qcm-v1'], 'ECSR-M1-QCM-04', false,
    $mft$L'évaluation de départ précède le contrat : elle permet de proposer un volume de formation adapté avant de vendre. Contrat d'abord, paiement sans évaluation ou inscription anticipée inversent la logique de protection de l'élève.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Une entreprise de livraison demande à votre école une intervention pour sensibiliser ses salariés aux comportements sûrs et à l'éco-conduite. De quelle compétence du titre ECSR cette mission relève-t-elle ?$mft$,
    $mft$[
      {"id":"a","label":"Du CCP 2 : sensibiliser l'ensemble des usagers de la route à des comportements sûrs et respectueux de l'environnement","is_correct":true},
      {"id":"b","label":"Du CCP 1 : il s'agit d'une action de formation d'apprenants conducteurs","is_correct":false},
      {"id":"c","label":"D'aucun des deux CCP : ce type de mission n'entre pas dans le titre","is_correct":false},
      {"id":"d","label":"De l'autorisation d'enseigner, qui définit les publics autorisés","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-1','qcm-v1'], 'ECSR-M1-QCM-05', false,
    $mft$Les salariés sont déjà titulaires du permis : ce sont des usagers de la route, pas des apprenants conducteurs, donc CCP 2. Le CCP 1 vise la formation des apprenants ; l'autorisation d'enseigner ne définit pas la répartition des CCP.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Lucas a obtenu son permis B il y a 18 mois et vient de valider son titre ECSR. Il dépose sa demande d'autorisation d'enseigner. Quelle est l'issue prévisible ?$mft$,
    $mft$[
      {"id":"a","label":"Refus à ce stade : le permis B doit être hors période probatoire, soit au moins 2 ans","is_correct":true},
      {"id":"b","label":"Accord : le titre ECSR dispense de toute condition liée au permis","is_correct":false},
      {"id":"c","label":"Accord sous réserve de suivre une conduite accompagnée préalable","is_correct":false},
      {"id":"d","label":"Refus définitif : il devra repasser son titre dans deux ans","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-1','qcm-v1'], 'ECSR-M1-QCM-06', false,
    $mft$Le permis B hors période probatoire (au moins 2 ans) est une condition de délivrance : à 18 mois, Lucas ne la remplit pas encore. Le refus n'a rien de définitif (son titre reste acquis) et le titre ne dispense d'aucune condition.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$En leçon, votre élève s'engage dans un carrefour complexe pendant que vous lui expliquez la règle de priorité. Qu'illustre cette situation ?$mft$,
    $mft$[
      {"id":"a","label":"La double tâche permanente : enseigner ET garantir la sécurité en même temps, prêt à intervenir à tout instant","is_correct":true},
      {"id":"b","label":"Une erreur de planification : on ne doit jamais parler pendant que l'élève conduit","is_correct":false},
      {"id":"c","label":"Un moment de relâche pour l'enseignant, puisque c'est l'élève qui conduit","is_correct":false},
      {"id":"d","label":"Une situation à proscrire : les carrefours se travaillent uniquement en salle","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-1','qcm-v1'], 'ECSR-M1-QCM-07', false,
    $mft$Enseigner en circulation impose de mener deux tâches de front : expliquer ET surveiller l'environnement, anticiper l'erreur, être prêt à agir. Le silence total, le relâchement ou le repli en salle nieraient la nature même de la leçon pratique.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Le gérant de votre école veut communiquer sur le dispositif du permis à 1 euro. Quelle condition son établissement doit-il remplir ?$mft$,
    $mft$[
      {"id":"a","label":"Détenir le label qualité des formations, dont ce dispositif est l'un des avantages","is_correct":true},
      {"id":"b","label":"Aucune : toute école agréée peut le proposer automatiquement","is_correct":false},
      {"id":"c","label":"Employer uniquement des enseignants titulaires de l'ancien BEPECASER","is_correct":false},
      {"id":"d","label":"Obtenir une dérogation délivrée par l'ANTS","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-1','qcm-v1'], 'ECSR-M1-QCM-08', false,
    $mft$Le label qualité ouvre des avantages comme le permis à 1 euro ou les contrats types (contours actuels à vérifier dans les textes en vigueur). L'agrément seul ne suffit pas, l'ANTS gère les inscriptions et le diplôme des enseignants n'est pas le critère.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Sofia anime depuis plusieurs années des actions de sécurité routière en association et souhaite obtenir le titre ECSR sans refaire toute la formation. Quelle voie d'accès correspond à sa situation ?$mft$,
    $mft$[
      {"id":"a","label":"La VAE : faire valider les acquis de son expérience en rapport avec le titre","is_correct":true},
      {"id":"b","label":"L'alternance : elle doit d'abord signer un contrat avec une école de conduite","is_correct":false},
      {"id":"c","label":"Aucune : le titre exige toujours la formation complète en centre agréé","is_correct":false},
      {"id":"d","label":"L'équivalence automatique : son expérience vaut directement le titre","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-1','qcm-v1'], 'ECSR-M1-QCM-09', false,
    $mft$La VAE valide une expérience en rapport direct avec le titre, sans repasser par la formation complète. Elle n'a toutefois rien d'automatique (dossier, évaluation) ; l'alternance et la formation continue sont d'autres voies, non adaptées à son cas.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Contrôle sur route pendant une leçon : les agents demandent ses justificatifs à l'enseignante salariée. Au téléphone, le gérant affirme que « l'agrément de l'école couvre tout ». Qu'en est-il ?$mft$,
    $mft$[
      {"id":"a","label":"Faux : l'enseignante doit présenter son autorisation d'enseigner personnelle, distincte de l'agrément de l'établissement","is_correct":true},
      {"id":"b","label":"Vrai : l'agrément préfectoral vaut pour l'école et tous ses salariés","is_correct":false},
      {"id":"c","label":"Vrai, à condition que l'enseignante figure sur le registre du personnel","is_correct":false},
      {"id":"d","label":"Faux : c'est le contrat de l'élève qui doit être présenté en priorité","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ecsr','module-1','qcm-v1'], 'ECSR-M1-QCM-10', false,
    $mft$L'agrément couvre l'établissement (exploitant, local, moyens) ; l'autorisation d'enseigner est personnelle et doit pouvoir être présentée en contrôle, salarié ou non. Ni le registre du personnel ni le contrat de l'élève ne remplacent ce document.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Votre élève a finalisé ses démarches sur l'ANTS et son niveau est validé, mais il attend toujours son passage à l'épreuve pratique. Par quel canal l'école obtient-elle la place d'examen ?$mft$,
    $mft$[
      {"id":"a","label":"Via la préfecture / DDT, qui attribue les places d'examen","is_correct":true},
      {"id":"b","label":"Via l'ANTS, qui gère aussi le planning des inspecteurs","is_correct":false},
      {"id":"c","label":"Directement auprès de l'IPCSR, par demande individuelle","is_correct":false},
      {"id":"d","label":"Auprès du ministère du Travail, qui délivre le titre ECSR","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ecsr','module-1','qcm-v1'], 'ECSR-M1-QCM-11', false,
    $mft$Les places d'examen relèvent de la préfecture/DDT. L'ANTS gère les inscriptions dématérialisées, l'IPCSR fait passer les épreuves sans les planifier lui-même, et le ministère du Travail délivre le titre de l'enseignant, sans lien avec l'examen de l'élève.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$À l'approche de votre session d'examen du titre ECSR, vous demandez au centre agréé le format des épreuves. Quelle description correspond à la session ?$mft$,
    $mft$[
      {"id":"a","label":"Des mises en situation professionnelle, un dossier professionnel et des entretiens avec le jury, selon le référentiel d'évaluation en vigueur","is_correct":true},
      {"id":"b","label":"Un unique QCM national de connaissances théoriques","is_correct":false},
      {"id":"c","label":"Une simple épreuve de conduite personnelle chronométrée","is_correct":false},
      {"id":"d","label":"Un mémoire de recherche soutenu à l'université","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ecsr','module-1','qcm-v1'], 'ECSR-M1-QCM-12', false,
    $mft$Le titre professionnel s'évalue en situation : mises en situation professionnelle, dossier professionnel et entretiens avec le jury, dont les modalités précises se vérifient dans le référentiel en vigueur. QCM sec, conduite chronométrée ou mémoire universitaire ne correspondent pas à cette logique.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l2, 'qr',
   $mft$Depuis 2016, quel diplôme le titre professionnel ECSR a-t-il remplacé pour accéder au métier ?$mft$,
   $mft$Le BEPECASER.$mft$,
   2, 'facile', ARRAY['ecsr','module-1','question-courte'], 'ECSR-M1-QC-01', false,
   $mft$Le titre est délivré par le ministère du Travail.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Quelle autorité délivre l'autorisation d'enseigner, indispensable avant toute première leçon ?$mft$,
   $mft$Le préfet (la préfecture).$mft$,
   2, 'facile', ARRAY['ecsr','module-1','question-courte'], 'ECSR-M1-QC-02', false,
   $mft$Autorisation personnelle, distincte de l'agrément de l'école.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Citez trois lieux ou contextes d'exercice possibles pour un enseignant de la conduite.$mft$,
   $mft$Par exemple : école de conduite traditionnelle, école en ligne, association d'insertion, actions post-permis, interventions en entreprise.$mft$,
   2, 'facile', ARRAY['ecsr','module-1','question-courte'], 'ECSR-M1-QC-03', false,
   $mft$Trois contextes distincts attendus.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Karim veut préparer le titre ECSR tout en étant salarié d'une école de conduite pendant sa formation. Quelle voie d'accès correspond à ce projet ?$mft$,
   $mft$L'alternance : contrat avec une école de conduite, formation en centre et pratique en entreprise.$mft$,
   2, 'moyen', ARRAY['ecsr','module-1','question-courte'], 'ECSR-M1-QC-04', false,
   $mft$Les deux autres voies : formation continue en centre agréé et VAE.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Résumez l'objet de chacun des deux CCP du titre ECSR.$mft$,
   $mft$CCP 1 : former des apprenants conducteurs par des actions individuelles et collectives, dans le respect des cadres réglementaires. CCP 2 : sensibiliser l'ensemble des usagers de la route à l'adoption de comportements sûrs et respectueux de l'environnement.$mft$,
   2, 'moyen', ARRAY['ecsr','module-1','question-courte'], 'ECSR-M1-QC-05', false,
   $mft$Apprenants conducteurs d'un côté, tous les usagers de l'autre.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Citez trois exigences propres au véhicule utilisé pour l'enseignement de la conduite.$mft$,
   $mft$La double commande, la signalétique de véhicule école et une assurance spécifique couvrant l'usage école.$mft$,
   2, 'moyen', ARRAY['ecsr','module-1','question-courte'], 'ECSR-M1-QC-06', false,
   $mft$Les trois exigences attendues.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Avant de faire signer un contrat à un nouvel élève, quelle étape obligatoire doit être réalisée et à quoi sert-elle ?$mft$,
   $mft$L'évaluation de départ : situer le niveau de l'élève pour proposer un volume de formation adapté avant de contractualiser (forfaits, conditions de résiliation).$mft$,
   2, 'moyen', ARRAY['ecsr','module-1','question-courte'], 'ECSR-M1-QC-07', false,
   $mft$Évaluer avant de vendre.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$En leçon de conduite, que recouvre la « double tâche permanente » de l'enseignant ?$mft$,
   $mft$Enseigner tout en garantissant la sécurité : expliquer, observer l'élève et l'environnement, anticiper l'erreur et rester prêt à intervenir à tout instant.$mft$,
   2, 'moyen', ARRAY['ecsr','module-1','question-courte'], 'ECSR-M1-QC-08', false,
   $mft$Les deux volets simultanés attendus.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Un élève confond « l'ANTS » et « l'inspecteur ». Distinguez le rôle de l'ANTS et celui de l'IPCSR dans son parcours.$mft$,
   $mft$L'ANTS est le portail des inscriptions et démarches dématérialisées ; l'IPCSR est l'inspecteur qui fait passer et évalue l'épreuve du permis (les places d'examen étant attribuées via la préfecture/DDT).$mft$,
   2, 'difficile', ARRAY['ecsr','module-1','question-courte'], 'ECSR-M1-QC-09', false,
   $mft$Inscription d'un côté, évaluation de l'autre.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un gérant vous affirme que l'agrément de son école vous dispense d'autorisation d'enseigner personnelle. Que lui répondez-vous et pourquoi ?$mft$,
   $mft$Non : l'agrément couvre l'établissement (exploitant, local, moyens) tandis que l'autorisation d'enseigner est personnelle, délivrée par le préfet, et doit pouvoir être présentée en cas de contrôle.$mft$,
   2, 'difficile', ARRAY['ecsr','module-1','question-courte'], 'ECSR-M1-QC-10', false,
   $mft$Deux autorisations distinctes, deux titulaires.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Un ami vous lance : « enseignant de la conduite, c'est juste faire répéter des créneaux jusqu'à ce que ça passe ». Expliquez en quoi le métier est d'abord un métier de pédagogue, en illustrant votre propos par des situations concrètes de leçon.$mft$,
   $mft$Réponse modèle. Le métier ne consiste pas à faire répéter : il consiste à construire des conducteurs sûrs et autonomes. Le pédagogue analyse les besoins de l'élève, fixe des objectifs, bâtit une progression, choisit ses méthodes, évalue et remédie. Exemple : face à un élève qui échoue trois fois le même demi-tour, le répétiteur fait recommencer ; le pédagogue cherche la cause (où porte le regard, quels repères, quel niveau de stress) et change d'approche. Autre illustration : plutôt que de dicter chaque action, l'enseignant questionne (« que vois-tu, que décides-tu ? ») pour développer l'analyse et l'autonomie, car l'élève devra décider seul toute sa vie de conducteur. S'y ajoute la double tâche permanente : pendant qu'il enseigne, l'enseignant garantit la sécurité (surveiller l'environnement, anticiper l'erreur, rester prêt à intervenir). Les qualités du métier découlent de cette réalité : patience (chaque élève a son rythme), observation (détecter la crispation, le regard mal placé), adaptation (changer de méthode, ajuster le vocabulaire au public). Enfin, la variété des publics (apprenants, salariés en entreprise, publics en insertion, post-permis) confirme que la compétence centrale est pédagogique, pas répétitive.$mft$,
   $mft$Barème /5 : opposition répétiteur/pédagogue avec démarche complète (analyser, progresser, évaluer, remédier) (1,5 pt) ; objectif de conducteurs sûrs et autonomes (1 pt) ; double tâche permanente expliquée (1 pt) ; au moins un exemple concret de leçon (1 pt) ; qualités du métier reliées (0,5 pt). Erreurs fréquentes : réduire le métier à la préparation de l'examen ; oublier le volet sécurité pendant l'enseignement.$mft$,
   5, 'facile', ARRAY['ecsr','module-1','question-redigee'], 'ECSR-M1-QR-01', false,
   $mft$Le métier de pédagogue argumenté contre le cliché du répétiteur.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Lors d'une réunion d'information sur la reconversion, on vous demande de présenter le titre professionnel ECSR en cinq minutes : nature du titre, contenu, voies d'accès et évaluation. Rédigez votre présentation structurée.$mft$,
   $mft$Réponse modèle. Nature : le titre professionnel ECSR (enseignant de la conduite et de la sécurité routière) est un titre de niveau 5, équivalent bac+2, délivré par le ministère du Travail ; il remplace le BEPECASER depuis 2016. Contenu : deux certificats de compétences professionnelles. Le CCP 1 : former des apprenants conducteurs par des actions individuelles et collectives, dans le respect des cadres réglementaires (leçons de conduite, séances collectives, évaluation des apprenants). Le CCP 2 : sensibiliser l'ensemble des usagers de la route à l'adoption de comportements sûrs et respectueux de l'environnement (interventions en entreprise, actions post-permis, éco-conduite). Voies d'accès : la formation continue en centre agréé (parcours classique de reconversion), l'alternance (contrat avec une école de conduite, pratique et centre), et la VAE pour ceux qui justifient d'une expérience en rapport avec le titre. Évaluation : une session d'examen comportant des mises en situation professionnelle, un dossier professionnel et des entretiens avec le jury ; les modalités précises relèvent du référentiel d'évaluation en vigueur, à vérifier auprès du centre agréé. Conclusion : un titre professionnalisant, évalué en situation, qui ouvre écoles, associations, post-permis et entreprises.$mft$,
   $mft$Barème /5 : nature exacte du titre (niveau 5, ministère du Travail, remplaçant du BEPECASER depuis 2016) (1,5 pt) ; les deux CCP correctement distingués (1,5 pt) ; les trois voies d'accès (1 pt) ; composantes de la session avec réserve sur le référentiel en vigueur (1 pt). Erreurs fréquentes : attribuer le titre au ministère de l'Intérieur ou à l'Éducation nationale ; confondre CCP 1 et CCP 2.$mft$,
   5, 'facile', ARRAY['ecsr','module-1','question-redigee'], 'ECSR-M1-QR-02', false,
   $mft$Le titre ECSR présenté de façon complète et structurée.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Vous venez de valider votre titre ECSR et une école souhaite vous faire démarrer dans un mois. Décrivez la procédure pour obtenir votre autorisation d'enseigner, les conditions à remplir, et vos obligations une fois en poste (contrôle, véhicule).$mft$,
   $mft$Réponse modèle. Procédure : déposer la demande d'autorisation d'enseigner auprès du préfet (préfecture), sans attendre : aucune leçon ne peut être donnée avant sa délivrance, même avec le titre en poche. Conditions : être titulaire du titre ECSR (ou d'un diplôme équivalent) ; détenir le permis B hors période probatoire, soit au moins 2 ans ; justifier de l'aptitude médicale par un contrôle auprès d'un médecin agréé (anticiper la prise de rendez-vous, souvent le point lent du dossier) ; satisfaire aux conditions d'âge et d'honorabilité, dont les exigences exactes sont à vérifier auprès de la préfecture au moment de la demande. Validité : l'autorisation est limitée dans le temps (5 ans renouvelable, durée à vérifier dans les textes en vigueur) : noter l'échéance et anticiper le renouvellement. En poste : conserver l'autorisation avec soi et pouvoir la présenter en cas de contrôle, que l'on soit salarié ou indépendant ; vérifier le véhicule école confié : double commande fonctionnelle, signalétique en place, assurance spécifique couvrant l'usage école. Refuser poliment tout démarrage anticipé « en attendant le papier » : ce serait exercer sans autorisation.$mft$,
   $mft$Barème /5 : autorité compétente (préfet) et interdiction d'exercer avant délivrance (1 pt) ; les quatre conditions citées, avec prudence sur âge et honorabilité (2 pts) ; validité limitée et anticipation du renouvellement (1 pt) ; obligations en poste : présentation en cas de contrôle et véhicule conforme (double commande, signalétique, assurance) (1 pt). Erreurs fréquentes : croire que le titre vaut autorisation ; oublier la visite médicale auprès d'un médecin agréé.$mft$,
   5, 'moyen', ARRAY['ecsr','module-1','question-redigee'], 'ECSR-M1-QR-03', false,
   $mft$La procédure d'autorisation d'enseigner de bout en bout.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Trois candidats visent le titre ECSR : Karim, demandeur d'emploi avec un financement de reconversion ; Léa, qu'une école de conduite est prête à recruter pendant sa formation ; Sofia, qui anime depuis des années des ateliers de sécurité routière en association. Comparez les trois voies d'accès au titre et attribuez à chacun la plus adaptée, en justifiant.$mft$,
   $mft$Réponse modèle. Les trois voies : la formation continue en centre agréé (parcours complet suivi en centre, adapté aux reconversions financées) ; l'alternance (contrat avec une école de conduite : on apprend en centre et on pratique en entreprise, avec un statut de salarié) ; la VAE (validation des acquis de l'expérience, pour qui justifie d'une expérience en rapport direct avec le titre, sans refaire la formation complète). Attribution : Karim relève de la formation continue en centre agréé : demandeur d'emploi, financement de reconversion, disponibilité pour un parcours complet. Léa relève de l'alternance : un employeur est prêt à la recruter, elle cumule revenu, expérience de terrain et formation, et l'école prépare ainsi sa future embauche. Sofia relève de la VAE : ses années d'animation en sécurité routière constituent une expérience à faire valider ; attention toutefois, la VAE n'est pas automatique : elle exige un dossier solide et une évaluation, et Sofia devra démontrer que son expérience couvre bien les compétences du titre, y compris la formation d'apprenants conducteurs. Critères de comparaison mobilisés : financement, durée, statut, exigence d'expérience préalable, présence d'un employeur.$mft$,
   $mft$Barème /5 : les trois voies correctement décrites (1,5 pt) ; attribution justifiée pour chacun des trois profils (2 pts) ; limite de la VAE identifiée (dossier, évaluation, couverture des compétences) (1 pt) ; critères de comparaison explicites (0,5 pt). Erreurs fréquentes : présenter la VAE comme une équivalence automatique ; oublier que l'alternance suppose un employeur.$mft$,
   5, 'moyen', ARRAY['ecsr','module-1','question-redigee'], 'ECSR-M1-QR-04', false,
   $mft$Les trois voies d'accès comparées sur trois profils réels.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Une élève de 19 ans pousse la porte de votre école pour « passer le permis ». Décrivez pas à pas son parcours, de l'accueil jusqu'à l'épreuve pratique, en citant à chaque étape le document ou l'acteur concerné.$mft$,
   $mft$Réponse modèle. 1) Évaluation de départ : situer son niveau et proposer un volume de formation ; elle précède obligatoirement toute contractualisation. 2) Contrat écrit : prestations, forfaits et prix, conditions de résiliation ; l'élève sait ce qu'elle achète et comment sortir du contrat. 3) Démarches administratives : inscription et demandes dématérialisées via l'ANTS. 4) Formation : leçons individuelles et éventuelles séances collectives, progression tracée dans le livret d'apprentissage, au suivi désormais dématérialisé ; l'enseignant y consigne les compétences travaillées. 5) Présentation à l'examen : quand le niveau est atteint (décision pédagogique, pas commerciale), l'école sollicite une place d'examen, attribuée via la préfecture/DDT. 6) Épreuve pratique : évaluée par un inspecteur (IPCSR), l'organisation des examens relevant du délégué au permis de conduire. Tout au long du parcours, l'école engage sa responsabilité : un contrat mal rédigé, un livret non tenu ou un dossier ANTS incomplet se traduisent en litiges et en retards. L'enseignant, interlocuteur quotidien de l'élève, est souvent le premier à détecter un dossier mal parti : connaître ce circuit fait partie du métier.$mft$,
   $mft$Barème /5 : évaluation de départ placée AVANT le contrat (1 pt) ; contrat écrit avec forfaits et résiliation (1 pt) ; ANTS pour les démarches et livret d'apprentissage dématérialisé pour le suivi (1 pt) ; place d'examen via préfecture/DDT et épreuve évaluée par un IPCSR (1,5 pt) ; rôle de vigilance de l'enseignant (0,5 pt). Erreurs fréquentes : faire signer le contrat avant l'évaluation de départ ; attribuer les places d'examen à l'ANTS.$mft$,
   5, 'moyen', ARRAY['ecsr','module-1','question-redigee'], 'ECSR-M1-QR-05', false,
   $mft$Le parcours complet de l'élève, acteurs et documents à chaque étape.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Ancien commercial, Mehdi hésite à se reconvertir : il craint « les journées à rallonge et les samedis ». La semaine type qu'on lui annonce : leçons de 8 h à 12 h et de 14 h à 19 h en semaine, samedi de 8 h à 16 h, repos dimanche et lundi. Analysez les réalités du métier à lui présenter honnêtement, puis construisez-lui un plan en trois étapes pour sécuriser sa décision.$mft$,
   $mft$Réponse modèle. Analyse honnête : les craintes de Mehdi correspondent à des réalités du métier : les élèves sont disponibles quand les autres ne travaillent pas, d'où de larges amplitudes (débuts à 8 h, fins à 19 h) et un samedi fréquemment travaillé ; s'y ajoute une exigence méconnue, la double tâche permanente (enseigner tout en garantissant la sécurité), qui rend les journées denses nerveusement, pas seulement longues. En face, des atouts réels : un repos consécutif possible (ici dimanche et lundi), l'autonomie au volant, la variété des publics et l'utilité concrète du métier ; et son profil commercial (écoute, relation, adaptation) constitue un vrai capital pédagogique. Plan en trois étapes : 1) immersion : observer plusieurs journées réelles dans une école, et si possible dans un autre contexte (association d'insertion, post-permis, entreprise) pour éprouver le rythme ; 2) auto-évaluation : patience, observation, capacité à rester vigilant des heures durant ; échanger avec des enseignants de profils différents, notamment issus de reconversions ; 3) validation du projet : choisir sa voie d'accès au titre, sécuriser le financement, et se projeter sur les évolutions possibles (interventions en entreprise, post-permis, à terme formation de formateurs ou gérance) qui diversifient les rythmes.$mft$,
   $mft$Barème /5 : réalités présentées sans enjolivement (amplitudes, samedi, densité liée à la double tâche) (1,5 pt) ; contreparties et atouts du profil identifiés (1 pt) ; plan en trois étapes concret (immersion, auto-évaluation, validation du projet) (2 pts) ; perspectives d'évolution mentionnées (0,5 pt). Erreurs fréquentes : nier les contraintes pour « vendre » le métier ; proposer un plan théorique sans immersion réelle.$mft$,
   5, 'moyen', ARRAY['ecsr','module-1','question-redigee'], 'ECSR-M1-QR-06', false,
   $mft$Reconversion : analyse honnête des rythmes et plan de décision.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Recruté dans une petite école, vous constatez dès la première semaine : deux élèves récents sans contrat écrit, des livrets d'apprentissage non tenus depuis des semaines, et un gérant qui communique sur le « permis à 1 euro » sans être certain que l'école y ait encore droit. Analysez chaque manquement (risques pour l'école, les élèves et vous-même) puis proposez une remise en conformité priorisée.$mft$,
   $mft$Réponse modèle. Manquement 1 : élèves sans contrat écrit : la relation doit être contractualisée après l'évaluation de départ, avec forfaits et conditions de résiliation ; sans contrat, litiges probables sur les prix et les prestations, élèves privés de leurs protections, image de l'école en jeu. Manquement 2 : livrets d'apprentissage non tenus : le livret trace la progression (suivi dématérialisé) ; non tenu, impossible de justifier le travail réalisé, le niveau atteint et la décision de présentation à l'examen : risque pédagogique et administratif, et l'enseignant qui anime des leçons non tracées s'expose personnellement. Manquement 3 : communication sur le permis à 1 euro sans certitude : cet avantage est lié au label qualité, dont les contours actuels sont à vérifier ; l'annoncer sans y avoir droit revient à tromper les élèves et expose l'école. Priorisation : 1) régulariser immédiatement les deux contrats (risque juridique direct sur des élèves déjà en formation) ; 2) remettre les livrets à jour et instaurer la saisie après chaque leçon ; 3) vérifier la situation de l'école au regard du label et suspendre la communication en attendant. Posture : alerter le gérant par écrit, de façon factuelle et constructive, sans inquiéter les élèves.$mft$,
   $mft$Barème /5 : les trois manquements analysés avec leurs risques respectifs (2,5 pts) ; lien correct entre permis à 1 euro et label qualité, avec prudence sur les contours actuels (0,5 pt) ; priorisation argumentée de la remise en conformité (1,5 pt) ; posture professionnelle (alerte écrite au gérant, protection des élèves) (0,5 pt). Erreurs fréquentes : tout traiter au même niveau d'urgence ; couvrir les manquements par loyauté envers l'employeur.$mft$,
   5, 'difficile', ARRAY['ecsr','module-1','question-redigee'], 'ECSR-M1-QR-07', false,
   $mft$Audit d'une école : manquements, risques, remise en conformité.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$À quatre mois de votre session d'examen du titre ECSR, construisez votre plan de préparation couvrant les trois composantes de la session (mises en situation professionnelle, dossier professionnel, entretiens avec le jury), en précisant comment vous fiabilisez vos informations sur les modalités exactes.$mft$,
   $mft$Réponse modèle. Étape préalable : se procurer le référentiel d'évaluation en vigueur auprès du centre agréé, car les modalités précises (durées, ordre, critères) évoluent : ne jamais se caler sur des témoignages datés trouvés en ligne. Mois 1 : diagnostic : lister les compétences des deux CCP (former des apprenants conducteurs ; sensibiliser l'ensemble des usagers) et s'auto-positionner pour cibler ses faiblesses. Mois 2 et 3 : mises en situation professionnelle : s'entraîner sur les deux registres (leçon individuelle type CCP 1, animation collective type CCP 2), en conditions réelles ou simulées, avec retour des formateurs ; se filmer pour objectiver posture et consignes. Dossier professionnel : le rédiger au fil de l'eau, en décrivant des situations de travail réellement vécues (stage, alternance) et leur analyse, plutôt qu'une rédaction de dernière minute ; le faire relire. Mois 4 : entretiens avec le jury : préparer l'explicitation de ses choix pédagogiques (pourquoi cette méthode, cette progression, ce vocabulaire pour ce public), s'entraîner à l'oral avec un pair, réviser les cadres réglementaires du métier. Transversal : jalons hebdomadaires ; et anticiper l'après-titre en constituant dès maintenant le dossier d'autorisation d'enseigner (visite médicale chez un médecin agréé) pour ne pas retarder l'embauche.$mft$,
   $mft$Barème /5 : fiabilisation par le référentiel d'évaluation en vigueur (1 pt) ; préparation des mises en situation couvrant les deux CCP avec entraînement objectivé (1,5 pt) ; dossier professionnel rédigé au fil de l'eau à partir de situations vécues (1 pt) ; préparation des entretiens (explicitation des choix pédagogiques) (1 pt) ; rétroplanning et anticipation de l'autorisation d'enseigner (0,5 pt). Erreurs fréquentes : rédiger le dossier la dernière semaine ; ignorer le CCP 2 dans l'entraînement.$mft$,
   5, 'difficile', ARRAY['ecsr','module-1','question-redigee'], 'ECSR-M1-QR-08', false,
   $mft$Plan de préparation à la session, fiabilisé sur le référentiel.$mft$);

  RAISE NOTICE 'Module 1 ECSR créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $ecsrm1$;
