-- =====================================================================
-- ECSR : MODULE 3 : ENSEIGNER EN VOITURE : LA SÉANCE INDIVIDUELLE
-- v1 (juillet 2026) : LOT ECSR-3
-- Préparer, animer et évaluer la leçon de conduite : objectif unique,
-- guidage décroissant, double tâche sécurité/pédagogie, profils d'élèves.
-- ⚠ STATUT : active = false (« à valider »). Idempotent.
-- =====================================================================

DO $ecsrm3$
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

  DELETE FROM public.question_bank WHERE source_ref LIKE 'ECSR-M3-%';
  DELETE FROM public.modules WHERE slug = 'ecsr-seance-individuelle';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 3 : Enseigner en voiture : la séance individuelle',
    'ecsr-seance-individuelle', v_bloc,
    'Préparer, animer et évaluer une leçon de conduite : objectifs pédagogiques, techniques d''animation en double tâche, gestion de la sécurité et des profils d''élèves.',
    'avance', 360, 30) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 30, true);

  -- ─── Leçon 1 : Préparer la séance ───────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'preparer-la-seance',
    'Préparer la séance : un objectif, un parcours, des critères',
    $mft$> 🎯 **Objectifs**
> - Exploiter le livret d'apprentissage et le bilan de la séance précédente pour situer l'élève.
> - Formuler un objectif de séance unique, atteignable et annoncé.
> - Choisir un parcours et des critères de réussite au service de cet objectif.

## Tout part de l'élève, donc du livret

Une leçon de conduite ne se prépare pas sur le parking, deux minutes avant de monter en voiture. Elle se prépare à partir de deux sources : le **livret d'apprentissage**, qui situe l'élève dans les compétences et sous-compétences du référentiel, et le **bilan de la séance précédente**, qui dit ce qui a été travaillé, ce qui est acquis et ce qui a résisté. Ces deux documents répondent à la seule question qui compte au moment de préparer : où en est CET élève, aujourd'hui ? Un élève n'est pas « à 12 heures de conduite » : il est à tel endroit de telle compétence, avec telle sous-compétence encore fragile. La séance naît de ce diagnostic, pas d'une habitude ni d'une envie du moment.

## Un objectif de séance : UN seul

La tentation est de vouloir tout travailler à chaque sortie : c'est la garantie de ne rien travailler vraiment. La règle professionnelle tient en trois mots : un objectif **unique** (une chose à la fois), **atteignable** dans le temps de la séance (calibré sur le niveau réel constaté au livret), et **annoncé** (l'élève sait ce qu'on travaille et pourquoi). « Aujourd'hui, on travaille la traversée des giratoires : observer tôt, choisir sa voie, céder le passage » mobilise l'attention de l'élève sur une cible précise ; « on va rouler et on verra » la disperse. Un élève qui connaît l'objectif accepte mieux les répétitions, comprend le sens des exercices et pourra s'auto-évaluer en fin de séance.

## Le parcours se choisit APRÈS l'objectif

Le parcours n'est pas un rituel (« le tour habituel ») : c'est un plateau d'exercices au service de l'objectif.

| Objectif de la séance | Parcours adapté |
| --- | --- |
| Maniement (volant, embrayage, démarrages) | Zone calme, très faible trafic, sans pression |
| Giratoires : observation et choix de voie | Itinéraire enchaînant des giratoires variés (tailles, voies, trafic) |
| Insertions et changements de voie | Voie rapide ou rocade à trafic modéré |
| Conduite autonome | Itinéraire vers une destination annoncée, guidage minimal |

Emmener un débutant en plein maniement dans un centre-ville dense, c'est le placer en surcharge : il n'apprend plus, il subit. À l'inverse, faire tourner un élève avancé sur trois giratoires déserts, c'est du temps facturé qui ne produit rien. L'adéquation entre le parcours et l'objectif est un marqueur de professionnalisme que les jurys comme les employeurs repèrent immédiatement.

## Des critères de réussite observables

Comment saurez-vous, l'un et l'autre, que l'objectif est atteint ? Par des **critères observables**, préparés à l'avance et annoncés avec l'objectif : « tu contrôles rétroviseur puis angle mort avant chacun de tes changements de voie », « tu t'engages dans le giratoire sans arrêt inutile quand la voie est libre ». Un critère observable se constate de l'extérieur ; « être plus à l'aise » ou « mieux comprendre » ne se constatent pas et ne se discutent que sur des impressions. Ces critères serviront trois fois : pendant la séance (guider le regard de l'élève), au bilan (mesurer), au livret (tracer).

> ❌ **Piège à éviter**
> La leçon-promenade : on roule, l'enseignant commente au fil de l'eau, il ne se passe rien de structuré. L'élève paie une heure sans savoir ce qu'il y a appris, le livret ne peut pas être renseigné honnêtement, et la progression réelle devient invisible : pour l'élève, pour les payeurs et pour vous-même.

:::flow
1. Lire | Livret + bilan précédent : situer la compétence en cours
2. Cibler | UN objectif unique, atteignable dans la séance
3. Tracer | Un parcours choisi pour servir cet objectif
4. Définir | Des critères de réussite observables
5. Annoncer | Objectif et critères dits à l'élève dès le départ
:::

> 💡 **Astuce**
> Écrivez l'objectif en une phrase que l'élève peut répéter. S'il ne parvient pas à le reformuler après votre annonce, l'objectif est trop flou ou trop gros : redécoupez.

## ✅ Synthèse

- La séance se prépare à partir du **livret** et du **bilan précédent** : où en est cet élève, aujourd'hui.
- **Un objectif unique, atteignable, annoncé** : l'élève sait ce qu'il travaille et pourquoi.
- Le parcours vient APRÈS l'objectif ; les critères de réussite sont **observables**, annoncés, réutilisés au bilan et au livret.$mft$,
    $mft$Préparer la séance à partir du livret et du bilan précédent : un objectif unique, atteignable et annoncé, un parcours au service de l'objectif, des critères de réussite observables.$mft$,
    1, 45) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : Animer en double tâche ───────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'animer-en-double-tache',
    'Animer la séance : guider, questionner, sécuriser',
    $mft$> 🎯 **Objectifs**
> - Dérouler la structure d'une séance de conduite, de l'accueil au bilan.
> - Doser le guidage du pas-à-pas verbal vers l'autonomie, au bon rythme.
> - Tenir la double tâche sécurité/pédagogie, y compris l'intervention aux doubles commandes.

## La colonne vertébrale d'une séance

:::flow
1. Accueillir | Accueil et rappel de la séance précédente (5 min environ)
2. Annoncer | L'objectif du jour et ses critères de réussite
3. Expliquer | Bref et imagé : ce qu'on va faire, comment, pourquoi
4. Démontrer | Si utile : l'enseignant montre, l'élève observe activement
5. Faire faire | L'élève agit, guidage décroissant, questionnement
6. Conclure | Bilan co-construit et trace au livret
:::

L'accueil et le rappel (cinq minutes suffisent) réactivent la mémoire : « qu'avons-nous travaillé la dernière fois ? qu'est-ce qui restait difficile ? ». C'est déjà du questionnement : c'est l'élève qui dit, pas vous. Puis l'objectif est annoncé (leçon 1) et la phase d'apprentissage commence.

## Expliquer, démontrer, faire faire

**Expliquer** : bref et imagé. Une image bien choisie vaut un paragraphe technique, et un élève assis dans une voiture n'écoute pas un cours magistral de dix minutes. **Démontrer** si utile : certains gestes se montrent mieux qu'ils ne s'expliquent : prenez le volant quelques minutes, avec une consigne d'observation précise donnée à l'élève. Mais l'essentiel du temps appartient au **faire faire** : on n'apprend à conduire qu'en conduisant, et le véhicule à doubles commandes est conçu exactement pour cela.

## Le guidage décroissant

Le guidage suit une pente descendante : d'abord le **pas-à-pas verbal complet** (« tu ralentis, tu regardes à gauche, tu passes en seconde »), puis des **annonces partielles** (« giratoire dans 200 mètres »), puis le **questionnement** (« que vois-tu ? que décides-tu ? »), enfin la **supervision silencieuse**. Le signal pour descendre d'un cran : l'élève réussit avec le niveau de guidage actuel. Les deux erreurs symétriques : rester en pas-à-pas (vous fabriquez un élève-perroquet, dépendant de votre voix, incapable de décider seul) et lâcher trop vite (l'échec en situation complexe casse une confiance durement construite).

## Les commentaires en circulation : une affaire de timing

L'information pédagogique s'**anticipe** : elle se donne AVANT le point de décision, quand l'élève a encore le temps de l'intégrer calmement. Une consigne lancée au milieu de l'anneau du giratoire arrive trop tard : l'élève est en pleine action, en charge mentale maximale : elle ajoute de la confusion, parfois du danger. **Jamais pendant l'urgence** : si le moment est passé, taisez-vous, notez, et débriefez à l'arrêt. Se taire au bon moment est un acte pédagogique à part entière.

## Faire dire plutôt que dire

Le questionnement pédagogique transforme l'élève en acteur de sa propre lecture de la route : « que vois-tu ? », « que décides-tu ? », « qu'est-ce qui pourrait te faire renoncer à t'engager ici ? ». L'élève qui verbalise sa perception et ses décisions construit son jugement : exactement ce dont il aura besoin quand vous ne serez plus assis à sa droite. Le réflexe professionnel : avant de donner votre analyse, demander la sienne.

## La double tâche : la sécurité PRIME

Pendant toute la séance, vous menez deux tâches en parallèle : la **sécurité** (lecture de la route, anticipation, pieds prêts aux doubles commandes) et la **pédagogie** (observer l'élève, guider, questionner). Quand les deux entrent en conflit, la hiérarchie est absolue : **la sécurité prime, toujours**.

> ⚠️ **Attention**
> L'intervention aux doubles commandes s'**assume** : c'est votre rôle, elle protège l'élève et les tiers, elle n'est ni un échec de l'élève ni le vôtre. Puis elle se **débriefe**, dès que possible, sans dramatiser : le fait (ce qui s'est passé), la raison (pourquoi vous êtes intervenu), la piste (ce que l'élève pourra faire la prochaine fois). Une intervention jamais débriefée laisse l'élève dans le flou ou la honte ; une intervention dramatisée fige l'apprentissage.

> 📌 **À retenir**
> Un enseignant qui parle en continu n'enseigne pas : il occupe l'espace sonore. Informer tôt, questionner souvent, se taire quand l'élève agit, débriefer après : c'est ce dosage que le jury du CCP1 observe.

## ✅ Synthèse

- Structure : **accueil et rappel, annonce de l'objectif, expliquer (bref), démontrer (si utile), faire faire, bilan**.
- Guidage **décroissant** : on réduit dès que l'élève réussit ; l'information s'anticipe, jamais pendant l'urgence.
- **Faire dire plutôt que dire** ; la **sécurité prime** ; toute intervention aux doubles commandes est assumée puis **débriefée** sans dramatiser.$mft$,
    $mft$La structure d'une séance (accueil, annonce, expliquer, démontrer, faire faire, bilan), le guidage décroissant, le questionnement pédagogique et la double tâche : la sécurité prime, les interventions se débriefent.$mft$,
    2, 50) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : Évaluer et tracer ────────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'evaluer-et-tracer',
    'Évaluer, tracer, rendre compte',
    $mft$> 🎯 **Objectifs**
> - Pratiquer l'évaluation formative en continu, sur des critères annoncés.
> - Formuler un feedback factuel et développer l'auto-évaluation de l'élève.
> - Tracer la progression (livret, fiche de suivi, bilans) et communiquer avec les payeurs.

## Évaluer pour apprendre, pas pour sanctionner

L'évaluation **formative** accompagne l'apprentissage en continu : elle mesure l'écart entre ce qui est visé et ce qui est produit, pour ajuster la suite. Elle n'a de sens que sur des **critères annoncés** dès le début de séance (leçon 1) : évaluer sur des attentes que l'élève ne connaît pas, c'est le piéger. Chaque exercice, chaque giratoire franchi, chaque insertion nourrit cette évaluation : pas besoin d'attendre une « épreuve » pour évaluer.

## Le feedback factuel : le fait, l'effet, la piste

Le feedback efficace décrit trois choses, dans cet ordre : le **fait** observé (« au stop, tu n'as contrôlé qu'à gauche »), son **effet** (« la voiture qui venait de droite a dû freiner »), la **piste** (« avant de t'engager, balaye des deux côtés »). Il ne vise **jamais la personne** : « tu es dangereux », « tu es tête en l'air » n'apprennent rien et abîment la relation.

| Formulation | Nature | Effet sur l'élève |
| --- | --- | --- |
| « Tu es vraiment imprudent » | Jugement de personne | Se défend ou se dévalorise, cache ses erreurs |
| « C'était moyen, fais mieux » | Vague | Ne sait pas quoi corriger, anxiété diffuse |
| Le fait, l'effet, la piste | Factuel | Sait exactement quoi refaire, l'erreur devient un objet de travail |

## L'auto-évaluation : la condition de l'autonomie

Après le permis, plus personne n'est assis à droite pour corriger : l'élève devra évaluer seul ses décisions. Ce jugement se construit PENDANT la formation, en donnant systématiquement la parole à l'élève avant de donner la vôtre : « comment évalues-tu ton giratoire ? », « qu'est-ce que tu referais différemment ? ». L'écart entre son estimation et vos observations est un matériau pédagogique précieux : il se travaille, il se réduit, et sa réduction est un progrès aussi important que la technique.

## Le bilan de fin de séance : co-construit

Le bilan n'est pas un verdict : c'est une construction à deux. L'élève s'exprime d'abord (auto-évaluation), l'enseignant complète et ajuste, puis l'on formalise trois volets : les **acquis** (ce qui est désormais stable), l'**à travailler** (ce qui reste fragile), la **prochaine étape** (l'objectif probable de la séance suivante). Ce bilan alimente directement la préparation de la séance suivante : la boucle est bouclée.

## Tracer : le livret, la fiche de suivi, les bilans formels

Ce qui n'est pas tracé n'existe pas : ni pour l'élève, ni pour un collègue qui reprendrait la formation, ni face à une contestation. La **traçabilité** passe par le livret d'apprentissage (renseigné honnêtement, séance après séance) et la fiche de suivi de l'école. Avant de valider une compétence, un **bilan de compétence formel** fait le point de manière structurée : c'est lui qui justifie le passage à l'étape suivante et, à terme, la décision de présentation à l'examen.

## Communiquer avec les payeurs

Les parents (ou tout autre payeur) financent la formation sans monter dans la voiture : leur seule fenêtre sur ce qui s'y passe, c'est vous. La règle : une communication **factuelle et bienveillante**, appuyée sur le livret et les bilans : ce qui est acquis, ce qui reste, le plan. Ni promesse de date d'examen pour faire plaisir, ni jugement de la personne, ni jargon : des faits, une progression, une prochaine étape.

> 📌 **À retenir**
> La traçabilité protège tout le monde : l'élève (sa progression est objectivée), l'enseignant (ses décisions sont documentées), l'école (face aux contestations). Le jour où un payeur conteste, ce sont vos bilans tracés qui rendent l'entretien serein.

> 🔍 **Zoom**
> Le feedback factuel se prépare dès la leçon 1 : sans critères annoncés en début de séance, vous n'avez rien d'objectif à décrire en fin de séance. Préparation, animation et évaluation sont trois faces du même geste professionnel.

## ✅ Synthèse

- Évaluation **formative** en continu, sur des **critères annoncés** ; feedback factuel : **le fait, l'effet, la piste**, jamais la personne.
- **Auto-évaluation** systématique : l'élève parle d'abord ; c'est la condition de son autonomie.
- Bilan **co-construit** (acquis, à travailler, prochaine étape), tracé au **livret** ; bilans formels avant validation ; payeurs informés **factuellement**.$mft$,
    $mft$L'évaluation formative sur critères annoncés, le feedback factuel (fait, effet, piste), l'auto-évaluation, le bilan co-construit, la traçabilité au livret et la communication factuelle avec les payeurs.$mft$,
    3, 45) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : Profils et difficultés ───────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'profils-et-difficultes',
    'Des profils différents, une exigence constante',
    $mft$> 🎯 **Objectifs**
> - Adapter la pédagogie aux principaux profils d'élèves sans baisser les exigences.
> - Outiller les cas fréquents : anxiété, sur-confiance, troubles DYS et TDAH, publics éloignés de l'écrit, seniors.
> - Savoir quand et comment questionner une possible inaptitude, et tenir la bonne posture.

## Adapter le chemin, jamais l'exigence

Le principe qui gouverne toute cette leçon : l'objectif final (un conducteur autonome et sûr) ne se négocie pas ; c'est le **chemin** qui s'adapte. Adapter n'est pas abaisser : un élève anxieux passera par d'autres étapes qu'un élève sur-confiant, mais tous deux devront, au bout, satisfaire aux mêmes exigences. L'enseignant qui « laisse passer » par gentillesse ne rend service à personne : ni à l'élève, ni aux autres usagers de la route.

## L'élève anxieux

L'anxiété se travaille, elle ne se sermonne pas. Quatre leviers : **dédramatiser** (l'erreur fait partie de l'apprentissage : elle est attendue, c'est un matériau de travail), les **micro-réussites** (découper la difficulté en petites victoires consécutives : chaque réussite constatée nourrit la confiance), la **respiration** (quelques respirations calmes avant de démarrer, après un passage difficile), les **parcours progressifs** (ne pas exposer d'emblée aux situations redoutées : y arriver par paliers). Ce qu'on ne fait pas : l'exposition brutale (« jette-toi dedans, ça passera ») : elle produit des blocages durables.

## Le sur-confiant

Le sur-confiant ne s'argumente pas : il se confronte **factuellement** à ses limites. Trois outils : les **exercices révélateurs** (une situation qu'il croit maîtriser, conçue pour rester sûre, qui le met objectivement en défaut), la **vidéo** et les observables (se voir, compter les contrôles absents, constater les distances), le comptage de vos **interventions**. Puis l'entretien : le laisser s'auto-évaluer d'abord ; l'écart entre son estimation et les faits travaille pour vous. L'affrontement d'ego, lui, ne produit que de la résistance.

## Troubles DYS et TDAH : des aménagements simples

| Aménagement | Concrètement |
| --- | --- |
| Consignes courtes | Une consigne à la fois, reformulée par l'élève |
| Supports visuels | Schémas, photos du parcours, gestes montrés |
| Répétition espacée | Revenir sur la notion sur plusieurs séances, plutôt qu'une seule grosse dose |

Ces aménagements n'abaissent aucune exigence : ils changent le canal et le rythme. Ils profitent d'ailleurs à tous les élèves.

## Publics éloignés de l'écrit, publics en insertion

Pour les élèves en difficulté avec l'écrit ou en parcours d'insertion, le permis est souvent une clé d'accès à l'emploi : l'enjeu est fort, la pression aussi. Passer par l'**oral et l'image**, vérifier la compréhension par **reformulation** (« explique-moi avec tes mots »), et surtout ne jamais confondre difficulté avec l'écrit et difficulté de conduite : ce sont deux choses distinctes.

## Les seniors en remise à niveau

On ne repart pas de zéro avec un conducteur expérimenté : on **respecte l'acquis** et on **actualise** (giratoires, aménagements récents, aides à la conduite). Les automatismes anciens devenus inadaptés se déconstruisent en douceur, par la prise de conscience guidée plutôt que par la correction frontale. Le rythme s'adapte ; l'exigence de sécurité, non.

## Quand la difficulté questionne l'aptitude

Certaines difficultés persistent malgré toutes les adaptations pédagogiques : détection visuelle défaillante d'un côté, malaises, confusions importantes et répétées. La ligne est claire : **l'enseignant ne diagnostique pas**. Son rôle : décrire factuellement ce qu'il observe, séance après séance ; en parler à l'élève avec tact, sans étiquette (« voilà ce que je constate, de façon répétée ») ; et **orienter vers un avis médical** avant d'aller plus loin. Poursuivre comme si de rien n'était expose l'élève et les tiers ; exclure sans explication est indigne du métier.

## Ni copain ni adjudant

La posture professionnelle tient en une formule : **exigeant et sécurisant**. Le « copain » n'ose plus exiger : il laisse s'installer des lacunes qui se paieront plus tard. L'« adjudant » fait taire les questions : l'élève cache ses difficultés, l'apprentissage devient une performance de façade. La bonne distance : bienveillance inconditionnelle envers la personne, exigence constante sur les comportements.

> 🎓 **Pour l'examen**
> Au CCP1, le jury observe précisément ce double mouvement : votre capacité à ADAPTER (consignes, parcours, rythme, supports) ET à MAINTENIR les exigences de sécurité et de progression. L'un sans l'autre ne convainc pas.

## ✅ Synthèse

- Adapter le **chemin**, jamais l'**exigence** finale.
- Anxieux : dédramatiser, micro-réussites, respiration, progressivité. Sur-confiant : confrontation **factuelle** (exercices révélateurs, vidéo). DYS/TDAH : consignes courtes, supports visuels, répétition espacée.
- Difficultés persistantes touchant à la santé : décrire les faits, **orienter vers un avis médical**, jamais diagnostiquer. Posture : **ni copain ni adjudant**.$mft$,
    $mft$Adapter sans renoncer aux exigences : élève anxieux, sur-confiant, troubles DYS et TDAH, publics éloignés de l'écrit, seniors ; questionner une inaptitude possible avec tact ; ni copain ni adjudant.$mft$,
    4, 50) RETURNING id INTO v_l4;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : Enseigner en voiture',
    'Vérifiez le module 3 : préparation de séance, animation en double tâche, évaluation et adaptation aux profils d''élèves.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Le bilan de la séance précédente indique : « créneaux acquis, giratoires hésitants : ne cède pas toujours le passage ». Quel objectif annoncez-vous pour la séance du jour ?$mft$,
    $mft$[
      {"id":"a","label":"« Aujourd'hui, on travaille les giratoires : observer tôt et céder le passage avant de s'engager »","is_correct":true},
      {"id":"b","label":"« On va rouler une heure et on verra ce qui se présente »","is_correct":false},
      {"id":"c","label":"« On refait des créneaux pour consolider ce qui marche déjà »","is_correct":false},
      {"id":"d","label":"« On travaille les giratoires, les insertions, les dépassements et la conduite de nuit »","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ecsr','module-3','qcm-v1'], 'ECSR-M3-QCM-01', false,
    $mft$L'objectif se déduit du bilan : unique, ciblé sur la difficulté identifiée, annoncé à l'élève. La promenade n'a pas d'objectif, refaire l'acquis ne fait pas progresser, et tout viser garantit de ne rien travailler.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Après l'accueil et le rappel de la séance précédente, que faites-vous avant de faire rouler l'élève ?$mft$,
    $mft$[
      {"id":"a","label":"Vous annoncez l'objectif du jour et ses critères de réussite","is_correct":true},
      {"id":"b","label":"Vous démarrez immédiatement pour ne pas perdre de temps de conduite","is_correct":false},
      {"id":"c","label":"Vous faites un contrôle surprise des connaissances du code","is_correct":false},
      {"id":"d","label":"Vous laissez l'élève choisir librement ce qu'il a envie de travailler","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ecsr','module-3','qcm-v1'], 'ECSR-M3-QCM-02', false,
    $mft$L'élève doit savoir ce qu'on travaille et pourquoi : c'est ce qui mobilise son attention. Démarrer sans cadre, tester par surprise ou déléguer le choix à l'élève prive la séance de sa structure.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$En fin de séance, comment se construit un bon bilan ?$mft$,
    $mft$[
      {"id":"a","label":"Avec l'élève : il s'auto-évalue d'abord, vous complétez : acquis, à travailler, prochaine étape","is_correct":true},
      {"id":"b","label":"Par l'enseignant seul, qui dicte ses conclusions à l'élève","is_correct":false},
      {"id":"c","label":"Par une note sur 20 inscrite au livret, sans commentaire","is_correct":false},
      {"id":"d","label":"Il est inutile si la séance s'est bien passée","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ecsr','module-3','qcm-v1'], 'ECSR-M3-QCM-03', false,
    $mft$Le bilan co-construit développe le jugement de l'élève et prépare la séance suivante. Le verdict dicté ou la note sèche ne font pas travailler l'auto-évaluation, et une bonne séance mérite d'autant plus d'être tracée.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Votre élève anxieuse se crispe et bloque sa respiration à l'approche de chaque giratoire. Quelle stratégie adoptez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Dédramatiser, découper en micro-réussites sur des giratoires simples, travailler la respiration, augmenter la difficulté par paliers","is_correct":true},
      {"id":"b","label":"L'emmener directement sur un grand giratoire dense pour qu'elle affronte sa peur","is_correct":false},
      {"id":"c","label":"Éviter définitivement les giratoires pour ne pas la braquer","is_correct":false},
      {"id":"d","label":"Lui dire de se détendre et enchaîner le programme comme prévu","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ecsr','module-3','qcm-v1'], 'ECSR-M3-QCM-04', false,
    $mft$L'anxiété se travaille par la progressivité et les réussites constatées. L'exposition brutale crée des blocages durables, l'évitement n'apprend rien, et l'injonction « détends-toi » ne change rien au mécanisme.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Objectif du jour : premiers démarrages et maniement du volant pour un élève à sa deuxième heure de conduite. Quel parcours choisissez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Une zone calme à très faible trafic, où l'élève peut répéter sans pression","is_correct":true},
      {"id":"b","label":"Le centre-ville à l'heure de sortie des bureaux, pour du réalisme","is_correct":false},
      {"id":"c","label":"La rocade, puisqu'il faudra bien y passer un jour","is_correct":false},
      {"id":"d","label":"Le parcours type de l'examen, pour l'habituer le plus tôt possible","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-3','qcm-v1'], 'ECSR-M3-QCM-05', false,
    $mft$Le parcours sert l'objectif : le maniement exige un environnement pauvre en stimulations. Centre-ville dense, rocade ou parcours d'examen placent un débutant en surcharge : il subit au lieu d'apprendre.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Votre élève approche d'un giratoire à deux voies où il devra prendre la troisième sortie. Quand donnez-vous l'information sur la voie à emprunter ?$mft$,
    $mft$[
      {"id":"a","label":"En amont, avant le point de décision, pendant qu'il peut encore l'intégrer calmement","is_correct":true},
      {"id":"b","label":"Au dernier moment, en haussant la voix si nécessaire pour être entendu","is_correct":false},
      {"id":"c","label":"Pendant la traversée de l'anneau, au moment précis où il agit","is_correct":false},
      {"id":"d","label":"Jamais : à ce stade, il doit tout déduire seul","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-3','qcm-v1'], 'ECSR-M3-QCM-06', false,
    $mft$L'information pédagogique s'anticipe : donnée en pleine action, elle surcharge et peut créer du danger. Et supprimer tout guidage ne se justifie que lorsque l'élève réussit déjà avec le niveau d'aide actuel.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Vous venez de freiner aux doubles commandes pour un piéton masqué par une camionnette. L'élève est secoué. Que faites-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Vous assumez l'intervention et la débriefez calmement dès que possible : le fait, la raison, la piste pour la prochaine fois","is_correct":true},
      {"id":"b","label":"Vous ne dites rien pour ne pas enfoncer l'élève","is_correct":false},
      {"id":"c","label":"Vous haussez le ton pour bien marquer la gravité de l'erreur","is_correct":false},
      {"id":"d","label":"Vous interrompez la séance : elle est devenue inutile","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-3','qcm-v1'], 'ECSR-M3-QCM-07', false,
    $mft$L'intervention s'assume (la sécurité prime) puis se débriefe sans dramatiser. Le silence laisse l'élève dans le flou, la dramatisation casse la confiance, et arrêter la séance transforme l'incident en échec.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Au stop, votre élève ne regarde qu'à gauche et s'engage ; une voiture venant de droite doit freiner. Quel feedback donnez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"« Au stop, tu n'as contrôlé qu'à gauche ; la voiture de droite a dû freiner ; avant de t'engager, balaye des deux côtés »","is_correct":true},
      {"id":"b","label":"« Tu es vraiment dangereux, concentre-toi »","is_correct":false},
      {"id":"c","label":"« C'était moyen, fais mieux la prochaine fois »","is_correct":false},
      {"id":"d","label":"« Si tu continues comme ça, tu n'auras jamais le permis »","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-3','qcm-v1'], 'ECSR-M3-QCM-08', false,
    $mft$Le feedback factuel décrit le fait, l'effet et la piste : l'élève sait quoi refaire. Le jugement de personne et la menace abîment la relation, le commentaire vague ne donne rien à corriger.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Un élève sur-confiant conduit vite, colle les véhicules et réclame son passage à l'examen. Comment le faites-vous évoluer ?$mft$,
    $mft$[
      {"id":"a","label":"En le confrontant factuellement à ses limites : exercice révélateur, images vidéo, comptage de vos interventions","is_correct":true},
      {"id":"b","label":"En cédant : l'échec à l'examen le calmera bien assez tôt","is_correct":false},
      {"id":"c","label":"En le remettant à sa place sèchement pour casser son ego","is_correct":false},
      {"id":"d","label":"En ignorant le sujet : la confiance est toujours bonne à prendre","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-3','qcm-v1'], 'ECSR-M3-QCM-09', false,
    $mft$Le sur-confiant ne s'argumente pas, il se confronte à des observables. Miser sur l'échec à l'examen coûte cher et n'apprend rien de précis, l'humiliation crée de la résistance, et l'excès de confiance est un facteur de risque.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Parmi ces formulations, laquelle est un critère de réussite OBSERVABLE pour une séance sur les changements de voie ?$mft$,
    $mft$[
      {"id":"a","label":"« L'élève contrôle rétroviseur puis angle mort avant chacun de ses changements de voie du parcours »","is_correct":true},
      {"id":"b","label":"« L'élève est plus à l'aise sur la rocade »","is_correct":false},
      {"id":"c","label":"« L'élève comprend mieux les insertions »","is_correct":false},
      {"id":"d","label":"« L'élève a fait de son mieux pendant la séance »","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ecsr','module-3','qcm-v1'], 'ECSR-M3-QCM-10', false,
    $mft$Un critère observable se constate de l'extérieur et se compte. L'aisance, la compréhension et l'effort sont des impressions : impossibles à mesurer, donc à tracer au livret et à discuter au bilan.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Votre élève réussit désormais les giratoires simples avec votre guidage verbal complet. Quelle est l'étape suivante cohérente ?$mft$,
    $mft$[
      {"id":"a","label":"Réduire le guidage : annonces partielles, puis questionnement (« que décides-tu ? »), vers l'autonomie","is_correct":true},
      {"id":"b","label":"Conserver le pas-à-pas verbal complet : c'est ce qui fonctionne","is_correct":false},
      {"id":"c","label":"Passer directement à l'autonomie totale sur un itinéraire complexe inconnu","is_correct":false},
      {"id":"d","label":"Revenir aux explications théoriques depuis le début","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ecsr','module-3','qcm-v1'], 'ECSR-M3-QCM-11', false,
    $mft$Le guidage décroissant se réduit dès que l'élève réussit au niveau d'aide actuel. Le maintenir fabrique un élève dépendant de votre voix ; le supprimer d'un coup provoque l'échec et casse la confiance.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Malgré vos adaptations, un élève ne détecte toujours pas les véhicules arrivant de la gauche ; vous suspectez un trouble du champ visuel. Que faites-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Vous en parlez avec tact sur la base des faits observés et vous l'orientez vers un avis médical","is_correct":true},
      {"id":"b","label":"Vous posez vous-même le diagnostic et le notez au livret","is_correct":false},
      {"id":"c","label":"Vous continuez les leçons sans rien dire : cela finira par venir","is_correct":false},
      {"id":"d","label":"Vous arrêtez la formation sans explication","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ecsr','module-3','qcm-v1'], 'ECSR-M3-QCM-12', false,
    $mft$L'enseignant n'est pas médecin : il décrit des faits répétés et oriente vers un avis médical. Diagnostiquer sort de son rôle, poursuivre sans agir expose l'élève et les tiers, exclure sans explication est indigne du métier.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Avant de préparer une séance, quelles sont les deux sources d'information à consulter pour situer l'élève ?$mft$,
   $mft$Le livret d'apprentissage (compétence et sous-compétence en cours) et le bilan de la séance précédente.$mft$,
   2, 'facile', ARRAY['ecsr','module-3','question-courte'], 'ECSR-M3-QC-01', false,
   $mft$Les deux sources sont attendues, pas une seule.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Citez, dans l'ordre, les deux premiers temps d'une séance de conduite, avant la phase d'apprentissage.$mft$,
   $mft$L'accueil avec rappel de la séance précédente (5 minutes environ), puis l'annonce de l'objectif du jour et de ses critères de réussite.$mft$,
   2, 'facile', ARRAY['ecsr','module-3','question-courte'], 'ECSR-M3-QC-02', false,
   $mft$Rappel puis annonce, avant de rouler.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Quels sont les trois volets d'un bilan de fin de séance co-construit ?$mft$,
   $mft$Les acquis, les points à travailler, la prochaine étape.$mft$,
   2, 'facile', ARRAY['ecsr','module-3','question-courte'], 'ECSR-M3-QC-03', false,
   $mft$Les trois volets, co-construits avec l'élève.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Pourquoi la « leçon-promenade » sans objectif est-elle une faute professionnelle ?$mft$,
   $mft$Sans objectif annoncé, l'élève ne sait pas ce qu'il travaille : pas de critères, pas de progrès mesurable, pas de traçabilité honnête au livret : du temps payé qui ne produit rien.$mft$,
   2, 'moyen', ARRAY['ecsr','module-3','question-courte'], 'ECSR-M3-QC-04', false,
   $mft$Objectif absent = progression impossible à mesurer et à tracer.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Définissez le guidage décroissant en une phrase et donnez un exemple concret.$mft$,
   $mft$Réduire progressivement l'aide verbale à mesure que l'élève réussit : du pas-à-pas complet aux annonces partielles, puis au questionnement, jusqu'à l'autonomie (exemple : ne plus annoncer la voie du giratoire et demander « que décides-tu ? »).$mft$,
   2, 'moyen', ARRAY['ecsr','module-3','question-courte'], 'ECSR-M3-QC-05', false,
   $mft$La progression vers l'autonomie doit apparaître.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Vous êtes intervenu aux doubles commandes. Citez les deux temps de la gestion pédagogique de cette intervention.$mft$,
   $mft$Assumer l'intervention sur le moment (la sécurité prime), puis la débriefer calmement dès que possible, sans dramatiser (le fait, la raison, la piste).$mft$,
   2, 'moyen', ARRAY['ecsr','module-3','question-courte'], 'ECSR-M3-QC-06', false,
   $mft$Assumer puis débriefer, sans dramatiser.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Quelles sont les trois composantes d'un feedback factuel, et que ne vise-t-il jamais ?$mft$,
   $mft$Le fait observé, son effet, la piste d'amélioration ; il ne vise jamais la personne.$mft$,
   2, 'moyen', ARRAY['ecsr','module-3','question-courte'], 'ECSR-M3-QC-07', false,
   $mft$Fait, effet, piste : jamais la personne.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Citez trois aménagements pédagogiques adaptés à un élève présentant un trouble DYS ou un TDAH.$mft$,
   $mft$Des consignes courtes (une à la fois, reformulées par l'élève), des supports visuels (schémas, images du parcours), la répétition espacée sur plusieurs séances.$mft$,
   2, 'moyen', ARRAY['ecsr','module-3','question-courte'], 'ECSR-M3-QC-08', false,
   $mft$Trois aménagements concrets attendus.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$En quoi l'auto-évaluation de l'élève pendant la formation prépare-t-elle sa sécurité APRÈS le permis ?$mft$,
   $mft$Après le permis, plus personne ne corrige ses décisions : l'auto-évaluation entraîne son jugement propre pendant la formation ; c'est la condition de l'autonomie et d'une conduite sûre sans accompagnement.$mft$,
   2, 'difficile', ARRAY['ecsr','module-3','question-courte'], 'ECSR-M3-QC-09', false,
   $mft$Le jugement propre comme condition de l'autonomie.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Des difficultés persistantes (détection visuelle, malaises) résistent à toutes vos adaptations pédagogiques. Quelle est la limite de votre rôle et la conduite à tenir ?$mft$,
   $mft$L'enseignant ne diagnostique pas : il décrit factuellement les difficultés observées, en parle avec tact à l'élève et l'oriente vers un avis médical avant de poursuivre la formation.$mft$,
   2, 'difficile', ARRAY['ecsr','module-3','question-courte'], 'ECSR-M3-QC-10', false,
   $mft$Des faits et une orientation médicale, jamais de diagnostic.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ─────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Votre élève a 15 heures de conduite. Le livret situe la compétence « circuler dans des conditions normales » en cours d'acquisition ; le bilan précédent note : « giratoires : observation tardive, hésite à s'engager ». Préparez la séance suivante : objectif, parcours, critères de réussite et annonce à l'élève.$mft$,
   $mft$Réponse modèle. Sources : le livret et le bilan précédent convergent vers une difficulté ciblée, les giratoires. Objectif unique et atteignable : « franchir des giratoires en observant tôt et en décidant de s'engager au bon moment ». Parcours au service de l'objectif : un itinéraire enchaînant des giratoires variés, en commençant par de petits giratoires à faible trafic puis en augmentant progressivement la taille et la densité : la difficulté monte par paliers, jamais d'un coup. Critères observables, préparés à l'avance : « sur les giratoires du parcours, tu portes ton regard sur l'anneau AVANT la ligne de cédez-le-passage » et « tu t'engages sans arrêt inutile quand la voie est libre ». Annonce en début de séance, après le rappel : dire ce qu'on travaille (les giratoires), pourquoi (le bilan précédent), comment (le parcours choisi) et à quoi se verra la réussite (les critères). En fin de séance, ces mêmes critères serviront à l'auto-évaluation de l'élève, au bilan co-construit et à la trace au livret. Ce qu'on ne fait pas : la promenade, l'empilement d'objectifs, le parcours habituel sans lien avec la difficulté.$mft$,
   $mft$Barème /5 : exploitation du livret et du bilan précédent (1 pt) ; objectif unique, atteignable, annoncé (1,5 pt) ; parcours progressif cohérent avec l'objectif (1,25 pt) ; critères observables réutilisés au bilan et au livret (1,25 pt). Erreurs fréquentes : empiler plusieurs objectifs ; formuler des critères non observables (« être plus à l'aise »).$mft$,
   5, 'facile', ARRAY['ecsr','module-3','question-redigee'], 'ECSR-M3-QR-01', false,
   $mft$La chaîne complète de préparation : diagnostic, objectif, parcours, critères, annonce.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Déroulez la structure complète d'une leçon de conduite d'une heure, en précisant pour chaque phase ce que fait l'enseignant, ce que fait l'élève, et la place du questionnement pédagogique.$mft$,
   $mft$Réponse modèle. 1) Accueil et rappel (5 minutes environ) : l'enseignant questionne (« qu'avons-nous travaillé ? qu'est-ce qui restait difficile ? ») : c'est l'élève qui dit, la mémoire se réactive. 2) Annonce de l'objectif du jour et de ses critères de réussite : l'élève sait ce qu'il travaille et pourquoi. 3) Phase d'apprentissage : expliquer, bref et imagé ; démontrer si utile (l'enseignant conduit, l'élève observe avec une consigne précise) ; puis faire faire, l'essentiel du temps : l'élève agit sous guidage décroissant (pas-à-pas verbal, annonces partielles, questionnement, supervision). 4) En circulation : les informations s'anticipent, données avant les points de décision, jamais pendant l'urgence ; le questionnement (« que vois-tu ? que décides-tu ? ») fait dire plutôt que dire ; l'enseignant tient en parallèle la sécurité, qui prime. 5) Bilan final co-construit : l'élève s'auto-évalue d'abord, l'enseignant complète : acquis, à travailler, prochaine étape ; trace au livret. Le questionnement traverse ainsi toute la séance, du rappel initial au bilan : il construit le jugement de l'élève, condition de son autonomie future.$mft$,
   $mft$Barème /5 : phases complètes et ordonnées, de l'accueil au bilan (1,5 pt) ; triptyque expliquer/démontrer/faire faire avec guidage décroissant (1,5 pt) ; questionnement présent et bien placé, informations anticipées (1 pt) ; bilan co-construit et trace au livret (1 pt). Erreurs fréquentes : réduire la séance au « faire faire » ; oublier l'annonce de l'objectif.$mft$,
   5, 'facile', ARRAY['ecsr','module-3','question-redigee'], 'ECSR-M3-QR-02', false,
   $mft$La structure d'une séance phase par phase, avec le rôle de chacun.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$En circulation, vous freinez aux doubles commandes : un piéton surgissait entre deux véhicules en stationnement et votre élève ne l'avait pas vu. L'élève, choqué, lâche : « je suis nul, je n'y arriverai jamais ». Rédigez votre gestion complète : sur le moment, le débriefing, la remise en confiance et la suite de la séance.$mft$,
   $mft$Réponse modèle. Sur le moment : sécuriser d'abord : le véhicule est maîtrisé, on poursuit calmement jusqu'à un endroit où s'arrêter ; aucune analyse à chaud en roulant, l'élève est en surcharge émotionnelle. À l'arrêt, débriefing factuel sans dramatiser : le fait (piéton masqué par le stationnement, détection tardive), la raison de l'intervention (« mon rôle est de garantir la sécurité ; il est normal que j'intervienne pendant l'apprentissage »), la piste (« dans une rue avec du stationnement, on réduit l'allure et on balaye les intervalles entre véhicules »). Remise en confiance : recadrer le « je suis nul » en séparant la personne de la performance : l'erreur porte sur une compétence en cours d'acquisition, elle est un matériau de travail ; rappeler les réussites constatées dans la séance. Suite : refaire passer l'élève dans une situation similaire mais simplifiée (rue calme avec stationnement) pour terminer sur une réussite, puis bilan co-construit où l'événement devient un acquis (« je sais repérer les zones à piétons masqués ») ; trace factuelle au livret.$mft$,
   $mft$Barème /5 : gestion de la sécurité sur le moment, pas d'analyse à chaud en roulant (1 pt) ; débriefing fait/raison/piste sans dramatiser (1,5 pt) ; recadrage de la dévalorisation, personne distinguée de la performance (1,25 pt) ; reprise sur situation similaire simplifiée et bilan tracé (1,25 pt). Erreurs fréquentes : moraliser à chaud en roulant ; nier l'incident pour « protéger » l'élève.$mft$,
   5, 'moyen', ARRAY['ecsr','module-3','question-redigee'], 'ECSR-M3-QR-03', false,
   $mft$L'intervention aux doubles commandes gérée de bout en bout, élève dévalorisé compris.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Après une même erreur (contrôle d'angle mort oublié lors d'un rabattement, un véhicule a klaxonné), comparez trois feedbacks possibles : « tu es vraiment tête en l'air », « ce n'était pas terrible, fais attention », et un feedback factuel que vous rédigerez. Analysez l'effet de chacun sur l'apprentissage et sur la relation pédagogique.$mft$,
   $mft$Réponse modèle. Premier feedback (jugement de personne) : « tête en l'air » vise l'identité, pas le comportement : l'élève se défend ou se dévalorise, n'apprend rien de précis, et la relation se dégrade ; à terme, il cache ses erreurs, ce qui prive l'enseignant de son matériau de travail. Deuxième feedback (vague) : pas d'attaque, mais rien d'utilisable : qu'est-ce qui n'était « pas terrible » ? que corriger, concrètement ? L'élève reste dans un flou anxiogène et l'erreur se reproduira. Troisième feedback (factuel) : « au rabattement, tu n'as pas contrôlé ton angle mort ; le véhicule qui arrivait a dû klaxonner et ralentir ; avant chaque rabattement, rétroviseur puis angle mort ». Il décrit le fait, l'effet, la piste : l'élève sait exactement quoi refaire, l'erreur devient un objet de travail extérieur à sa personne, la relation reste saine. Conclusion : seul le feedback factuel produit de l'apprentissage ; il se prépare en amont (critères annoncés en début de séance) et alimente ensuite l'auto-évaluation et le bilan co-construit.$mft$,
   $mft$Barème /5 : analyse du jugement de personne et de ses effets (1,25 pt) ; analyse du feedback vague (1,25 pt) ; feedback factuel correctement rédigé : fait, effet, piste (1,5 pt) ; lien avec les critères annoncés et l'auto-évaluation (1 pt). Erreurs fréquentes : rédiger un feedback « factuel » qui reste un jugement déguisé ; oublier l'effet sur la relation.$mft$,
   5, 'moyen', ARRAY['ecsr','module-3','question-redigee'], 'ECSR-M3-QR-04', false,
   $mft$Trois feedbacks comparés : seule la version factuelle fait apprendre.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Cas pratique : votre élève a consommé 12 heures de son forfait de 20 heures. État des lieux : maniement et zones calmes acquis, giratoires en cours, circulation dense et voies rapides non abordées ; les parents pressent pour fixer une date d'examen. Construisez le plan des 8 heures restantes (objectifs par séance) et votre message aux parents.$mft$,
   $mft$Réponse modèle. Plan par objectifs, du connu vers l'inconnu, une cible par séance : heures 13 et 14 : consolider les giratoires en trafic croissant, avec critères observables ; heures 15 et 16 : insertions et voies rapides, guidage décroissant ; heures 17 et 18 : circulation urbaine dense ; heure 19 : conduite autonome sur un itinéraire complet (destination annoncée, guidage minimal) ; heure 20 : bilan de compétences formel et mise en situation d'évaluation. Chaque séance suit la méthode : UN objectif annoncé, des critères, un bilan co-construit tracé au livret. Message aux parents : factuel et bienveillant, appuyé sur le livret : ce qui est acquis (valoriser le chemin parcouru), ce qui reste à construire, le plan des 8 heures. Aucune promesse de date : la présentation se décide sur un bilan de compétences validé, pas sur le calendrier ; c'est une question de sécurité, pas de rétention commerciale. Si les 8 heures s'avèrent insuffisantes, l'annoncer tôt, avec des faits, plutôt que de le laisser découvrir à la vingtième heure.$mft$,
   $mft$Barème /5 : progression cohérente du plan, du connu vers l'inconnu (2 pts) ; un objectif et des critères par séance, bilans tracés (1 pt) ; message aux parents factuel et bienveillant appuyé sur le livret (1,5 pt) ; refus motivé de promettre une date (0,5 pt). Erreurs fréquentes : promettre l'examen pour rassurer ; empiler plusieurs objectifs par séance.$mft$,
   5, 'moyen', ARRAY['ecsr','module-3','question-redigee'], 'ECSR-M3-QR-05', false,
   $mft$Un forfait à mi-parcours : plan de séances et communication avec les payeurs.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Votre élève de 19 ans se juge « déjà prêt » : vitesse au maximum autorisé en permanence, distances de sécurité courtes, il exige de passer l'examen dans deux semaines. Vos observations : analyse des risques insuffisante, deux interventions de votre part cette semaine. Construisez votre démarche pour le faire évoluer sans casser la relation.$mft$,
   $mft$Réponse modèle. Principe : le sur-confiant ne s'argumente pas, il se confronte à des observables. 1) Réunir les faits : les deux interventions datées et décrites, les erreurs comptées sur des critères annoncés à l'avance. 2) Concevoir un exercice révélateur : une situation qu'il croit maîtriser (itinéraire dense, imprévus à gérer), conçue pour rester parfaitement sûre, qui le met objectivement en défaut. 3) Utiliser la vidéo ou des observables : se voir, compter les contrôles absents, constater les distances réelles. 4) Mener l'entretien : le laisser s'auto-évaluer d'abord ; l'écart entre son estimation et les faits constitue le levier pédagogique, bien plus efficace que votre discours ; puis feedback factuel : fait, effet, piste, jamais la personne. 5) Poser le cadre : la présentation à l'examen se décide sur un bilan de compétences validé, pas sur l'envie ; tracer ce cadre au livret. Posture constante : ni copain (céder pour rester apprécié) ni adjudant (humilier pour reprendre la main) : exigeant et sécurisant. La confrontation aux faits préserve la relation parce qu'elle ne juge pas la personne.$mft$,
   $mft$Barème /5 : faits et observables réunis en amont (1 pt) ; exercice révélateur conçu pour rester sûr (1,25 pt) ; entretien : auto-évaluation d'abord, feedback factuel ensuite (1,5 pt) ; cadre de décision de présentation posé et tracé (0,75 pt) ; posture ni copain ni adjudant (0,5 pt). Erreurs fréquentes : rabaisser l'élève ; céder « pour qu'il apprenne de l'échec ».$mft$,
   5, 'moyen', ARRAY['ecsr','module-3','question-redigee'], 'ECSR-M3-QR-06', false,
   $mft$Le sur-confiant confronté aux faits, sans casser la relation pédagogique.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un parent payeur vous interpelle sèchement : « 15 heures et toujours pas de date d'examen, vous faites durer pour facturer ! ». Préparez et déroulez l'entretien : les éléments factuels à réunir, la conduite de l'échange, votre posture, et les issues possibles.$mft$,
   $mft$Réponse modèle. Préparation : réunir le livret d'apprentissage (compétences validées et en cours), les bilans de séance tracés, les critères restant à atteindre, et le plan des heures à venir : sans ces traces, l'entretien se joue sur des impressions et il est perdu d'avance. Conduite de l'échange : écouter sans couper, reformuler l'inquiétude légitime (le coût, le délai), puis dérouler les faits : où en est l'élève compétence par compétence, ce qui est acquis (valoriser), ce qui manque et pourquoi cela conditionne la sécurité, pas seulement la réussite à l'examen. Présenter le plan : objectifs des prochaines séances, jalon de bilan de compétences formel. Posture : factuelle et bienveillante : ni justification défensive, ni promesse de date pour acheter la paix, ni jugement de l'élève ; la décision de présentation repose sur un bilan validé, dans l'intérêt et la sécurité de l'élève. Issues possibles : un plan partagé avec un point d'étape daté ; si le désaccord persiste, proposer un bilan formel documenté remis au payeur. Leçon de fond : c'est la traçabilité constante des séances qui rend cet entretien serein.$mft$,
   $mft$Barème /5 : préparation documentaire complète : livret, bilans, plan (1,25 pt) ; conduite de l'échange : écouter, reformuler, dérouler les faits (1,5 pt) ; posture sans promesse de date ni défensive, sécurité mise en avant (1,25 pt) ; issues concrètes avec point d'étape (1 pt). Erreurs fréquentes : promettre une date pour clore le conflit ; opposer au parent des impressions sans traces écrites.$mft$,
   5, 'difficile', ARRAY['ecsr','module-3','question-redigee'], 'ECSR-M3-QR-07', false,
   $mft$Contestation d'un payeur : la traçabilité comme socle d'un entretien factuel.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Vous accueillez une élève de 58 ans, titulaire du permis, qui n'a plus conduit depuis 12 ans à la suite d'un accident. Elle arrive très anxieuse à sa première séance de remise à niveau. Construisez votre plan d'action pour les premières séances : évaluation initiale, adaptations, progression, limites de votre rôle.$mft$,
   $mft$Réponse modèle. Évaluation initiale : un entretien d'accueil (historique, situations redoutées, besoins réels : quels trajets vise-t-elle au quotidien), puis une évaluation en conduite sur parcours calme : observer sans juger, repérer les acquis anciens (l'expérience existe, on ne repart pas de zéro) et les points à actualiser (giratoires, aménagements récents, aides à la conduite du véhicule). Adaptations à l'anxiété : dédramatiser (l'erreur est un matériau de travail), micro-réussites (séquences courtes et réussies, constatées ensemble), respiration avant de démarrer et après un passage difficile, parcours progressifs évitant d'emblée les situations liées à l'accident, guidage d'abord rassurant puis décroissant. Progression : un objectif annoncé par séance, des critères observables, des bilans co-construits qui rendent le progrès visible : l'élève anxieuse sous-estime ses réussites, la trace écrite les objective. Limites du rôle : si des signaux dépassent la pédagogie (malaises, troubles perceptifs persistants), décrire les faits avec tact et orienter vers un avis médical ; ne jamais diagnostiquer. Posture constante : exigeante et sécurisante : l'objectif reste une conduite autonome et sûre, c'est le chemin qui s'adapte.$mft$,
   $mft$Barème /5 : évaluation initiale en deux temps : entretien puis conduite (1,25 pt) ; adaptations concrètes à l'anxiété (1,5 pt) ; progression tracée rendant les réussites visibles (1,25 pt) ; limites du rôle et orientation médicale (0,5 pt) ; posture exigeante et sécurisante (0,5 pt). Erreurs fréquentes : infantiliser l'élève expérimentée ; l'exposer brutalement aux situations redoutées.$mft$,
   5, 'difficile', ARRAY['ecsr','module-3','question-redigee'], 'ECSR-M3-QR-08', false,
   $mft$Remise à niveau d'une senior anxieuse : évaluer, adapter, rendre le progrès visible.$mft$);

  RAISE NOTICE 'Module 3 ECSR créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $ecsrm3$;
