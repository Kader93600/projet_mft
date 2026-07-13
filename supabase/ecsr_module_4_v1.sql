-- =====================================================================
-- ECSR (TITRE PRO ENSEIGNANT DE LA CONDUITE ET DE LA SÉCURITÉ ROUTIÈRE)
-- MODULE 4 : SÉANCES COLLECTIVES ET EXAMENS DU PERMIS : v1 (juillet 2026)
-- CCP1 : animer des séances collectives (code, thématiques), préparer
-- aux épreuves théorique (ETG) et pratique (permis B), comprendre
-- l'évaluation de l'inspecteur et la posture des jours d'examen.
-- ⚠ STATUT : questions insérées avec active = false (« à valider »).
-- Idempotent : DELETE ciblés par source_ref/slug, rejouable sans doublon.
-- =====================================================================

DO $ecsrm4$
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

  DELETE FROM public.question_bank WHERE source_ref LIKE 'ECSR-M4-%';
  DELETE FROM public.modules WHERE slug = 'ecsr-collectif-examens';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 4 : Séances collectives et examens du permis',
    'ecsr-collectif-examens', v_bloc,
    'Animer des séances collectives (code, thématiques), préparer les élèves aux épreuves théorique et pratique, et comprendre l''évaluation de l''inspecteur.',
    'avance', 330, 40) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 40, true);

  -- ─── Leçon 1 : Animer le collectif ──────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'animer-le-collectif',
    'Animer une séance collective : sortir du défilement de séries',
    $mft$> 🎯 **Objectifs**
> - Construire un cours thématique structuré qui remplace le défilement passif de séries.
> - Mobiliser les techniques d'animation adaptées à un groupe hétérogène.
> - Aborder les thèmes durs (vitesse, alcool) en partant des représentations des participants.

## La salle de code n'est pas une salle d'attente

Trop d'écoles réduisent la « séance de code » à un rituel : une série défile, les réponses tombent, quelques corrections mécaniques, et chacun repart. L'élève est occupé, pas formé : il mémorise des réponses sans construire les raisonnements qui lui permettront de traiter une question nouvelle, puis une situation réelle. Le titre ECSR attend autre chose de vous : concevoir et animer de véritables actions de formation collectives, avec un objectif, une progression et une évaluation.

## Le cours thématique en cinq temps

:::flow
1. Objectif annoncé | Ce que le groupe saura faire à la fin de la séance, dit clairement en ouverture
2. Activation des connaissances | Questions au groupe, remue-méninges : ce que chacun sait ou croit savoir
3. Apport structuré | Le contenu, organisé et illustré, qui confirme, corrige et complète
4. Exercices commentés | Des questions travaillées ENSEMBLE : on justifie chaque réponse, y compris les mauvaises
5. Synthèse | Les points clés reformulés, si possible par les participants eux-mêmes
:::

L'activation initiale change tout : elle révèle le niveau réel du groupe, engage les participants et vous évite de répéter ce qui est déjà acquis. Les exercices commentés valent dix séries silencieuses : c'est la justification à voix haute qui construit le raisonnement.

## Les techniques d'animation qui font vivre le groupe

| Technique | Usage |
| --- | --- |
| Questionnement circulaire | Faire circuler la parole : la question rebondit d'un participant à l'autre au lieu de revenir toujours à l'animateur |
| Travail en sous-groupes | Un cas à traiter par îlots de trois ou quatre, puis mise en commun : les silencieux s'expriment davantage en petit comité |
| Cas concrets locaux | Le carrefour compliqué du centre-ville, la zone devant le lycée : le proche marque plus que l'abstrait |
| Reformulation | « Qu'est-ce que tu veux dire par... » : faire préciser plutôt que corriger sèchement |

## Groupe hétérogène, participants difficiles

Un même créneau peut réunir un lycéen en conduite accompagnée, une adulte en reconversion et un participant dont le français écrit est fragile. Face à cette hétérogénéité : varier les canaux (image, oral, écrit), faire travailler les plus avancés en appui des autres, et différencier les objectifs plutôt que d'imposer un rythme moyen qui ennuie les uns et perd les autres.

Trois profils demandent une attention particulière : le monopoliseur (canaliser en donnant explicitement la parole aux autres), le contestataire (« moi je roule vite et il ne m'est jamais rien arrivé » : ne pas s'affronter, renvoyer la question au groupe, revenir aux faits), le silencieux (le solliciter sur des questions accessibles, valoriser sa première prise de parole).

> ❌ **Piège à éviter**
> L'affrontement frontal avec un contestataire devant le groupe : même si vous « gagnez » l'argument, vous perdez le participant et vous crispez la salle. La question renvoyée au groupe (« qu'en pensent les autres ? ») fait souvent le travail à votre place.

## Les thèmes durs : partir des représentations

Vitesse, alcool : sur ces sujets, chaque participant arrive avec des croyances construites (« je tiens bien l'alcool », « la vitesse ne tue pas, c'est l'inattention »). Si vous assénez les faits d'emblée, ils glissent sur ces représentations sans les entamer. La démarche efficace inverse l'ordre : faire d'abord EXPRIMER les représentations (tour de table, post-it anonymes, échelle d'accord), puis les confronter aux faits et à l'expérience du groupe. Le participant qui a formulé sa croyance à voix haute est celui qui peut la réviser.

> 💡 **Astuce**
> Sur ces thèmes, bannissez la morale (« c'est mal ») au profit du concret : ce que la vitesse change dans ce que l'œil perçoit, ce qui se dégrade dans les réflexes après un verre. Le groupe doit conclure lui-même, pas subir la conclusion.

## Les supports au service du scénario

La vidéo courte suivie d'un débat guidé, l'image projetée que le groupe analyse, le simulateur le cas échéant pour faire vivre une situation impossible à reproduire sur route : chaque support sert le scénario pédagogique, jamais l'inverse. Une vidéo diffusée sans consigne d'observation ni exploitation derrière est un temps mort déguisé.

## ✅ Synthèse

- Un cours thématique en cinq temps : **objectif, activation, apport, exercices commentés, synthèse**.
- Animer, c'est faire parler : questionnement circulaire, sous-groupes, cas locaux, reformulation.
- Thèmes durs : **les représentations d'abord, les faits ensuite** ; jamais de morale assénée.
- Hétérogénéité et profils difficiles se gèrent par la technique, pas par l'autorité.$mft$,
    $mft$Le cours thématique en cinq temps (objectif, activation, apport, exercices commentés, synthèse), les techniques d'animation (questionnement circulaire, sous-groupes, cas locaux), la gestion du groupe hétérogène et des profils difficiles, et la pédagogie des thèmes durs : représentations avant les faits.$mft$,
    1, 90) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : L'épreuve théorique générale ─────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'epreuve-theorique-etg',
    'L''épreuve théorique générale : préparer à comprendre, pas à réciter',
    $mft$> 🎯 **Objectifs**
> - Connaître le format et les conditions de réussite de l'épreuve théorique générale.
> - Construire une préparation orientée compréhension plutôt que mémorisation de séries.
> - Outiller les élèves : lecture d'image, pièges de formulation, gestion du stress.

## La carte d'identité de l'épreuve

| Élément | Ce qu'il faut savoir |
| --- | --- |
| Format | 40 questions couvrant les thématiques officielles du code |
| Seuil de réussite | Admis à partir de 35 bonnes réponses |
| Lieu de passage | Centres agréés gérés par des opérateurs privés |
| Inscription | Démarches dématérialisées via l'ANTS |
| Validité | L'ETG obtenue reste valable 5 ans |

Deux conséquences pédagogiques immédiates : les questions posées le jour J ne seront pas celles des séries d'entraînement (donc le par-cœur est une impasse), et la validité de 5 ans structure le calendrier de l'élève : un candidat qui a « son code » depuis longtemps doit être alerté avant l'échéance, sous peine de devoir repasser l'épreuve.

## Préparer à comprendre, pas à réciter

L'élève qui enchaîne les séries finit par reconnaître les questions : il répond juste chez vous et échoue en centre, où les questions sont différentes. Votre travail : transformer chaque question en occasion de comprendre la NOTION, c'est-à-dire la règle sous-jacente et son pourquoi. Concrètement : corriger en expliquant la règle et non la réponse ; faire reformuler par l'élève (« explique-moi pourquoi c'est la réponse C ») ; regrouper les erreurs par thématique pour cibler les révisions ; alterner séries individuelles et séances thématiques collectives (leçon 1).

> 📌 **À retenir**
> Une série d'entraînement est un outil de DIAGNOSTIC et d'entraînement au format, pas un outil d'apprentissage : la notion s'apprend en cours thématique, la série vérifie qu'elle est acquise.

## Lecture d'image et pièges de formulation

Beaucoup d'échecs ne viennent pas d'un manque de connaissances mais d'une lecture défaillante. La méthode à enseigner : balayer TOUTE l'image avant de lire la question (rétroviseurs, panneaux, marquages, autres usagers), puis lire la question deux fois en repérant les mots qui changent tout : « je peux » (possibilité) contre « je dois » (obligation), les négations, les conditions (« si... »). Entraînez explicitement cette méthode en collectif : projetez une image SANS la question et faites verbaliser ce que le groupe voit ; ajoutez la question ensuite. Les écarts de lecture apparaissent au grand jour et se corrigent ensemble.

## La gestion du stress

Le centre d'examen est un environnement inconnu : tablettes ou boîtiers, temps limité par question, silence, autres candidats. Préparez : examens blancs dans les conditions du réel (durée, rythme, sans pause), familiarisation avec l'interface, stratégie face au doute (répondre, passer, ne pas ressasser : une question ratée ne doit pas en faire rater trois). Rappelez le droit à l'erreur : le seuil de 35 bonnes réponses sur 40 autorise cinq erreurs : viser le sans-faute ajoute une pression inutile et contre-productive.

## Le suivi et la décision de présentation

Tenez un tableau de bord simple par élève : régularité du travail, scores par thématique, évolution dans le temps. La date de passage se décide AVEC l'élève quand les indicateurs sont stables au-dessus du seuil sur plusieurs sessions récentes, pas à la première série réussie.

> ⚠️ **Attention**
> Un élève présenté trop tôt à l'ETG s'installe dans l'échec : coût financier, découragement, parfois abandon. La date d'examen se décide sur des résultats stables et récents, pas sur l'impatience (de l'élève, de la famille ou de l'école).

## ✅ Synthèse

- ETG : **40 questions, admis à partir de 35 bonnes réponses**, en centre agréé d'un opérateur privé, inscription via l'ANTS, validité **5 ans**.
- Préparer la **compréhension des notions** : les questions du jour J ne seront pas celles des séries.
- Méthode de lecture : l'image d'abord, la question deux fois, vigilance sur « je peux / je dois ».
- Le stress se prépare : conditions réelles, stratégie du doute, droit à l'erreur rappelé.$mft$,
    $mft$Le format de l'ETG (40 questions, admis à partir de 35, centres agréés d'opérateurs privés, ANTS, validité 5 ans), la préparation par la compréhension plutôt que le par-cœur, la méthode de lecture d'image et les pièges de formulation, la gestion du stress et la décision de présentation.$mft$,
    2, 75) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : L'épreuve pratique du permis B ───────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'epreuve-pratique-b',
    'L''épreuve pratique du permis B : la grille de l''inspecteur expliquée',
    $mft$> 🎯 **Objectifs**
> - Décrire le déroulé et la grille d'évaluation de l'épreuve pratique du permis B.
> - Distinguer erreur simple et erreur éliminatoire pour enseigner le droit à l'erreur.
> - Préparer l'élève par des examens blancs réalistes et un travail sur le stress.

## Le déroulé de l'épreuve

L'épreuve pratique du permis B dure 32 minutes. Elle est évaluée par un inspecteur du permis de conduire et de la sécurité routière (IPCSR) à l'aide d'une grille nationale : l'inspecteur n'improvise pas, il observe des compétences définies et les reporte sur cette grille. Comprendre la grille, c'est comprendre ce que vous devez enseigner : c'est aussi ce que vous devez expliquer à vos élèves pour désamorcer les fantasmes (« il m'a piégé », « il ne m'aimait pas »).

## La grille : notation sur 31 points, admis à partir de 20

La grille aboutit à une notation sur 31 points : le candidat est admis à partir de 20 points, À CONDITION de n'avoir commis aucune erreur éliminatoire. Les grandes compétences observées :

| Compétence observée | Ce que l'inspecteur regarde |
| --- | --- |
| Installation au poste de conduite | Réglages, ceinture, vérifications avant de démarrer |
| Connaissance du véhicule | Questions de vérifications (intérieure, extérieure) et de première assistance (notions de premiers secours) |
| Maniement du véhicule | Direction, allure, trajectoires, manœuvre |
| Circulation | Insertions, intersections, adaptation de l'allure, partage de la route |
| Autonomie | Phase de conduite autonome : suivre un itinéraire vers une destination sans guidage continu |
| Courtoisie | Comportement envers les autres usagers |
| Conduite économique | Valorisée par la grille (modalités exactes du bonus : à vérifier dans la grille en vigueur) |

> 🔍 **Point de vigilance**
> Le détail exact des rubriques et des points, notamment la valorisation de la conduite économe et de la courtoisie, dépend de la grille officielle en vigueur : vérifiez la version applicable avant de la présenter à vos élèves, et travaillez à partir du document authentique.

## Erreur simple, erreur éliminatoire : enseigner le droit à l'erreur

Une erreur éliminatoire entraîne l'échec quel que soit le total de points. C'est le cas, notamment, lorsque l'inspecteur doit INTERVENIR pour préserver la sécurité (verbalement de façon impérative ou physiquement sur les commandes), ou lors d'un franchissement dangereux. À l'inverse, une hésitation, un calage, un créneau repris coûtent au plus des points : le seuil de 20 sur 31 laisse une vraie marge.

Cette distinction est un levier pédagogique majeur : l'élève qui croit que « la moindre faute élimine » conduit crispé et multiplie justement les erreurs. Enseignez explicitement la conduite à tenir après une erreur : on respire, on sécurise, on CONTINUE : l'examen se joue sur l'ensemble des 32 minutes, pas sur un calage.

## Préparer par des examens blancs réalistes

L'examen blanc n'a de valeur que s'il reproduit les conditions : durée réelle, consignes données comme le jour J, phase de conduite autonome, questions de vérifications et de première assistance, ET posture neutre de l'enseignant : pas de conseil, pas de mimique, intervention seulement si la sécurité l'exige. Le débriefing suit la logique de la grille : points acquis, points de travail, verdict argumenté. Deux ou trois examens blancs espacés dans le temps valent mieux qu'un seul la veille.

> 🎓 **Pour l'examen (titre ECSR)**
> Le jury apprécie le candidat capable d'expliquer la grille à un élève avec des mots simples ET d'en faire un outil de formation (examens blancs, débriefings) : entraînez-vous à ces deux registres.

## Le stress du jour J

Techniques concrètes : ancrer une routine d'installation (toujours les mêmes gestes dans le même ordre : le geste automatique libère l'attention), dédramatiser l'inspecteur (il évalue des compétences définies, il ne « cherche » personne), préparer une phrase de reprise après erreur (« je me replace, je continue »). L'élève doit arriver le jour J en ayant déjà VÉCU la situation en examen blanc.

## Après l'épreuve : le résultat

Le candidat ne reçoit pas son résultat en fin d'épreuve : il lui est notifié de façon dématérialisée, généralement sous 48 heures (délai indicatif : à vérifier), par consultation en ligne. Préparez l'élève à cette attente et à la lecture de son bilan, favorable ou non : ce bilan est la matière première de la leçon suivante.

## ✅ Synthèse

- Épreuve B : **32 minutes**, évaluation par l'IPCSR sur grille, **notation sur 31 points, admis à partir de 20** SANS erreur éliminatoire.
- Éliminatoire : notamment **l'intervention de l'examinateur** et le **franchissement dangereux** ; le reste coûte des points, pas l'examen.
- Compétences : installation, vérifications et première assistance, maniement, circulation, **autonomie**, courtoisie, conduite économe (grille en vigueur à vérifier).
- Préparation : **examens blancs réalistes**, routine d'installation, droit à l'erreur enseigné ; résultat dématérialisé (généralement sous 48 h, à vérifier).$mft$,
    $mft$L'épreuve pratique B : 32 minutes, grille IPCSR notée sur 31 points (admis à partir de 20 sans erreur éliminatoire), compétences évaluées (installation, vérifications, maniement, circulation, autonomie, courtoisie), droit à l'erreur, examens blancs réalistes et résultat dématérialisé.$mft$,
    3, 90) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : Présenter et analyser ────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'presenter-et-analyser',
    'Présenter, accompagner, analyser : les jours d''examen',
    $mft$> 🎯 **Objectifs**
> - Tenir le rôle de l'enseignant les jours d'examen : logistique, documents, posture.
> - Analyser un échec sans complaisance ni accablement et construire la suite.
> - Lire honnêtement les statistiques de réussite et défendre une éthique de présentation.

## Le jour J : une logistique irréprochable, une posture calme

L'enseignant qui accompagne un candidat à l'épreuve pratique répond de trois choses : le véhicule (conforme, propre, en état, avec ses documents), les documents du candidat et de l'école (convocation, pièces exigées), et le climat. Pas de « dernière leçon » surchargée le matin même : un trajet calme, deux ou trois rappels courts, et la confiance affichée. Pendant l'épreuve, si vous êtes à bord : discrétion totale, aucun commentaire, aucun signe : le candidat est seul face à sa conduite, et c'est très bien ainsi.

## Après un échec : la méthode

:::timeline
Le jour de l'épreuve | Accueillir la déception sans la nier : pas d'analyse à chaud, pas de procès de l'inspecteur
Les jours suivants | Relecture du bilan de l'inspecteur avec l'élève : les faits notés, compétence par compétence
Les semaines qui suivent | Plan de travail ciblé sur les compétences en défaut : des leçons qui traitent LA cause, pas des heures génériques
Le bon moment | Re-présentation quand les compétences sont stabilisées : ni trop tôt (échec en boucle), ni trop tard (démobilisation)
:::

Sans complaisance : si l'élève n'était pas au niveau, le bilan le dit, et le nier prépare le prochain échec. Sans accablement : un échec est une information, pas un verdict sur la personne. La relecture factuelle du bilan dépersonnalise : « la grille dit que l'insertion n'est pas encore acquise », et non « tu es nul en insertion ».

> ❌ **Piège à éviter**
> Accuser l'inspecteur (« il était mal luné ») : cela soulage sur le moment et détruit à terme. L'élève n'apprend rien, aborde la re-présentation en victime, et l'école se décrédibilise si ce discours revient aux oreilles des professionnels.

## Les statistiques de réussite : savoir les lire avant de les brandir

Les taux de réussite des écoles de conduite sont publiés. Un taux se lit avec précaution : il dépend du profil des élèves accueillis, du volume de candidats présentés (un petit effectif rend le pourcentage instable) et de la politique de présentation : une école qui ne présente que des élèves très sûrs affiche un taux flatteur ; une école qui présente tôt affiche un taux dégradé. Le taux est un indicateur, pas une preuve de qualité pédagogique à lui seul : sachez l'expliquer honnêtement aux élèves et aux familles, et refusez d'en faire un argument trompeur.

## L'éthique de présentation

La place d'examen est une ressource rare. Présenter un élève non prêt, c'est consommer une place pour un échec prévisible, retarder les autres candidats, infliger à l'élève un échec coûteux (financièrement et moralement) et dégrader le taux de l'école. La règle professionnelle : **ne présenter que des élèves prêts**, au vu d'évaluations objectives (examens blancs, bilans de compétences), et savoir le dire à un élève ou à un payeur impatient : « le présenter maintenant, c'est le préparer à échouer ».

## Les relations professionnelles avec les inspecteurs

L'IPCSR n'est ni un adversaire ni un allié à séduire : c'est un professionnel de l'évaluation. La relation se construit sur la durée par la fiabilité : candidats prêts, véhicules conformes, horaires tenus, documents en ordre, aucune intervention pendant l'épreuve, aucune contestation à chaud devant l'élève. Cette crédibilité est un actif de l'école : elle se gagne lentement et se perd très vite.

> 🎓 **Pour l'examen (titre ECSR)**
> Le jury attend un futur enseignant capable de justifier une DÉCISION de présentation (ou de non-présentation) par des évaluations objectives, et d'exploiter un bilan d'échec en plan de formation : entraînez-vous à formuler ces raisonnements à voix haute.

## ✅ Synthèse

- Jour J : logistique irréprochable (véhicule conforme, documents), posture calme, zéro commentaire pendant l'épreuve.
- Échec : bilan de l'inspecteur relu FACTUELLEMENT, plan ciblé, re-présentation au bon moment : sans complaisance ni accablement.
- Taux de réussite : un indicateur à contextualiser (profil des élèves, volume, politique de présentation).
- Éthique : **ne présenter que des élèves prêts** : la place d'examen est rare et l'échec coûte à tous.$mft$,
    $mft$Le rôle de l'enseignant les jours d'examen (véhicule conforme, documents, posture), l'analyse des échecs sans complaisance ni accablement (bilan inspecteur, plan ciblé, re-présentation au bon moment), la lecture critique des taux de réussite, l'éthique de présentation et les relations avec les IPCSR.$mft$,
    4, 75) RETURNING id INTO v_l4;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : Séances collectives et examens',
    'Vérifiez le module 4 : animation collective, épreuve théorique, épreuve pratique du permis B et posture des jours d''examen.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un élève vous demande combien d'erreurs il « a le droit » de faire à l'épreuve théorique générale. Vous répondez :$mft$,
    $mft$[
      {"id":"a","label":"Cinq au maximum : il faut au moins 35 bonnes réponses sur les 40 questions","is_correct":true},
      {"id":"b","label":"Aucune : l'épreuve exige un sans-faute","is_correct":false},
      {"id":"c","label":"Dix, soit un quart du questionnaire","is_correct":false},
      {"id":"d","label":"Cela dépend du centre d'examen choisi","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ecsr','module-4','qcm-v1'], 'ECSR-M4-QCM-01', false,
    $mft$Le seuil est national : admis à partir de 35 bonnes réponses sur 40, soit cinq erreurs possibles ; il ne varie ni selon le centre ni selon l'opérateur, et exiger le sans-faute ajoute un stress inutile.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$À l'issue d'un examen blanc, vous rappelez à votre élève les conditions de réussite de l'épreuve pratique B :$mft$,
    $mft$[
      {"id":"a","label":"Obtenir au moins 20 points sur les 31 de la grille, sans commettre d'erreur éliminatoire","is_correct":true},
      {"id":"b","label":"Obtenir la totalité des 31 points de la grille","is_correct":false},
      {"id":"c","label":"Ne commettre aucune erreur pendant les 32 minutes, quel que soit le score","is_correct":false},
      {"id":"d","label":"Obtenir 20 points : une erreur éliminatoire retire simplement des points","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ecsr','module-4','qcm-v1'], 'ECSR-M4-QCM-02', false,
    $mft$Les deux conditions sont cumulatives : au moins 20 points sur 31 ET aucune erreur éliminatoire ; une faute éliminatoire entraîne l'échec quel que soit le total, mais une erreur simple ne coûte que des points.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Vous ouvrez une séance collective sur la vitesse. Conformément à la pédagogie des thèmes durs, vous commencez par :$mft$,
    $mft$[
      {"id":"a","label":"Faire exprimer les représentations du groupe (tour de table, croyances) avant tout apport de faits","is_correct":true},
      {"id":"b","label":"Projeter d'emblée les statistiques d'accidents pour marquer les esprits","is_correct":false},
      {"id":"c","label":"Lancer une série de questions type examen sur le thème","is_correct":false},
      {"id":"d","label":"Rappeler les sanctions encourues pour dissuader","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ecsr','module-4','qcm-v1'], 'ECSR-M4-QCM-03', false,
    $mft$Les faits assénés d'emblée glissent sur des croyances non exprimées : on fait d'abord émerger les représentations, puis on les confronte aux faits ; statistiques brutes, séries et menace de sanction ne travaillent pas les représentations.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Le matin d'un passage à l'épreuve pratique, votre priorité d'enseignant accompagnateur est :$mft$,
    $mft$[
      {"id":"a","label":"Présenter un véhicule conforme, des documents en ordre, et installer un climat calme","is_correct":true},
      {"id":"b","label":"Faire une dernière leçon intensive pour corriger les défauts restants","is_correct":false},
      {"id":"c","label":"Prévoir de glisser des consignes à l'élève pendant l'épreuve si besoin","is_correct":false},
      {"id":"d","label":"Négocier avec l'inspecteur un parcours plus facile","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ecsr','module-4','qcm-v1'], 'ECSR-M4-QCM-04', false,
    $mft$Le jour J, tout se joue sur la logistique (véhicule, documents) et le climat : la leçon intensive de dernière minute stresse, intervenir pendant l'épreuve est interdit, et l'inspecteur ne négocie pas son évaluation.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$En séance collective, un participant monopolise la parole et répond avant tout le monde. La technique la plus adaptée :$mft$,
    $mft$[
      {"id":"a","label":"Pratiquer le questionnement circulaire en adressant nommément les questions aux autres participants","is_correct":true},
      {"id":"b","label":"Le laisser faire : il dynamise la séance","is_correct":false},
      {"id":"c","label":"Le remettre à sa place devant le groupe pour le calmer durablement","is_correct":false},
      {"id":"d","label":"Supprimer les questions orales et revenir au défilement de séries","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-4','qcm-v1'], 'ECSR-M4-QCM-05', false,
    $mft$Le questionnement circulaire redistribue la parole sans conflit ; laisser faire éteint les autres participants, l'humiliation crispe la salle, et renoncer à l'animation revient à renoncer à former.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Votre élève réussit presque toutes ses séries en salle mais vient d'échouer à l'ETG en centre agréé. L'explication la plus probable :$mft$,
    $mft$[
      {"id":"a","label":"Il a mémorisé les réponses des séries : face aux questions nouvelles du centre, la compréhension des notions n'était pas acquise","is_correct":true},
      {"id":"b","label":"Le centre d'examen a utilisé des questions hors programme","is_correct":false},
      {"id":"c","label":"Le seuil de réussite est plus élevé en centre qu'en salle","is_correct":false},
      {"id":"d","label":"Le matériel du centre était nécessairement défectueux","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-4','qcm-v1'], 'ECSR-M4-QCM-06', false,
    $mft$Les questions du jour J ne sont pas celles des séries : la reconnaissance par cœur ne transfère pas. Le seuil de 35 sur 40 est national, les questions restent dans les thématiques officielles, et la panne matérielle est l'exception, pas l'explication.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Pendant l'épreuve B, votre élève cale au démarrage à un feu et pense avoir tout perdu. Que devez-vous lui avoir appris AVANT le jour J ?$mft$,
    $mft$[
      {"id":"a","label":"Qu'un calage n'est pas éliminatoire : il coûte au pire des points, et l'examen se joue sur l'ensemble de l'épreuve","is_correct":true},
      {"id":"b","label":"Qu'un calage entraîne systématiquement l'échec","is_correct":false},
      {"id":"c","label":"Que seul le total de points compte, même après une intervention de l'inspecteur","is_correct":false},
      {"id":"d","label":"Qu'il faut s'excuser longuement auprès de l'inspecteur pour limiter la sanction","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-4','qcm-v1'], 'ECSR-M4-QCM-07', false,
    $mft$L'éliminatoire, c'est notamment l'intervention de l'examinateur ou un franchissement dangereux ; l'erreur simple retire des points sans éliminer. La réponse c inverse la règle : une intervention élimine quel que soit le total.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Un élève échoue à l'épreuve pratique. La démarche professionnelle d'analyse commence par :$mft$,
    $mft$[
      {"id":"a","label":"La relecture factuelle du bilan de l'inspecteur, compétence par compétence, avec l'élève","is_correct":true},
      {"id":"b","label":"La contestation du résultat auprès du centre d'examen","is_correct":false},
      {"id":"c","label":"Une re-présentation immédiate pour ne pas perdre le rythme","is_correct":false},
      {"id":"d","label":"La reprise de la formation depuis le début","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-4','qcm-v1'], 'ECSR-M4-QCM-08', false,
    $mft$Le bilan de l'inspecteur est la matière première du plan de travail ciblé : contester à chaud décrédibilise, re-présenter trop tôt reproduit l'échec, et tout reprendre à zéro ignore les compétences déjà acquises.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un élève vous demande comment s'inscrire à l'épreuve théorique. Le circuit correct :$mft$,
    $mft$[
      {"id":"a","label":"Démarches dématérialisées via l'ANTS, puis réservation d'une session dans un centre agréé d'un opérateur privé","is_correct":true},
      {"id":"b","label":"Inscription au guichet de la préfecture","is_correct":false},
      {"id":"c","label":"Courrier adressé à l'inspecteur du secteur","is_correct":false},
      {"id":"d","label":"Aucune formalité : on se présente librement dans un centre","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ecsr','module-4','qcm-v1'], 'ECSR-M4-QCM-09', false,
    $mft$Les démarches passent par l'ANTS et l'épreuve se déroule dans les centres agréés d'opérateurs privés : ni guichet de préfecture, ni courrier à l'inspecteur, ni passage sans réservation.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Votre élève sort de l'épreuve B persuadé d'avoir échoué : il a raté son créneau et hésité à une insertion, mais l'inspecteur n'est jamais intervenu. Votre analyse :$mft$,
    $mft$[
      {"id":"a","label":"Rien n'est joué : sans erreur éliminatoire, tout dépend du total de points, qu'il connaîtra avec le résultat dématérialisé","is_correct":true},
      {"id":"b","label":"L'échec est certain : une manœuvre ratée est éliminatoire","is_correct":false},
      {"id":"c","label":"La réussite est certaine puisque l'inspecteur n'est pas intervenu","is_correct":false},
      {"id":"d","label":"Il peut exiger son résultat immédiatement à la fin de l'épreuve","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ecsr','module-4','qcm-v1'], 'ECSR-M4-QCM-10', false,
    $mft$La manœuvre ratée coûte des points sans éliminer, mais l'absence d'intervention ne garantit pas d'atteindre 20 points sur 31 : le résultat, notifié en ligne (généralement sous 48 h, à vérifier), tranchera.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Le gérant veut afficher un taux de réussite calculé sur ses vingt derniers candidats, tous soigneusement sélectionnés. Quelle lecture professionnelle en faites-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Le taux est réel mais biaisé : faible volume et sélection des candidats présentés le rendent peu représentatif de la qualité pédagogique","is_correct":true},
      {"id":"b","label":"Le taux prouve que l'école est meilleure que ses concurrentes","is_correct":false},
      {"id":"c","label":"Un taux publié est par définition représentatif","is_correct":false},
      {"id":"d","label":"Il faudrait présenter des élèves non prêts pour rendre le taux plus crédible","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ecsr','module-4','qcm-v1'], 'ECSR-M4-QCM-11', false,
    $mft$Un taux dépend du profil des élèves, du volume présenté et de la politique de présentation : sur vingt candidats triés, il ne compare rien. Présenter des élèves non prêts serait une faute éthique, pas une correction statistique.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Votre séance collective réunit un lycéen de dix-sept ans, une adulte en reconversion et un participant maîtrisant mal le français écrit. Votre stratégie d'animation :$mft$,
    $mft$[
      {"id":"a","label":"Varier les canaux (image, oral, écrit), travailler en sous-groupes et différencier les objectifs","is_correct":true},
      {"id":"b","label":"Caler tout le rythme sur le participant le plus en difficulté","is_correct":false},
      {"id":"c","label":"Faire défiler des séries : chacun avance à son rythme","is_correct":false},
      {"id":"d","label":"Renoncer au collectif et basculer les trois profils en séances individuelles","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ecsr','module-4','qcm-v1'], 'ECSR-M4-QCM-12', false,
    $mft$L'hétérogénéité se gère par la différenciation, pas par la suppression du collectif : le rythme unique ennuie ou perd une partie du groupe, et le défilement de séries occupe sans former.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l2, 'qr',
   $mft$Un élève vous demande où et comment s'inscrire pour passer l'épreuve théorique. Résumez-lui le circuit.$mft$,
   $mft$Les démarches se font en ligne via l'ANTS, puis l'élève réserve une session dans un centre agréé géré par un opérateur privé.$mft$,
   2, 'facile', ARRAY['ecsr','module-4','question-courte'], 'ECSR-M4-QC-01', false,
   $mft$ANTS + centre agréé d'un opérateur privé.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Rappelez la durée de l'épreuve pratique B et les deux conditions cumulatives de réussite.$mft$,
   $mft$L'épreuve dure 32 minutes ; le candidat est admis à partir de 20 points sur les 31 de la grille, à condition de n'avoir commis aucune erreur éliminatoire.$mft$,
   2, 'facile', ARRAY['ecsr','module-4','question-courte'], 'ECSR-M4-QC-02', false,
   $mft$32 minutes ; 20/31 ET aucune erreur éliminatoire.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Citez, dans l'ordre, les cinq temps d'un cours thématique structuré en séance collective.$mft$,
   $mft$Objectif annoncé, activation des connaissances, apport structuré, exercices commentés, synthèse.$mft$,
   2, 'facile', ARRAY['ecsr','module-4','question-courte'], 'ECSR-M4-QC-03', false,
   $mft$Les cinq temps dans l'ordre.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Avant d'apporter des faits sur l'alcool au volant en séance collective, quelle étape pédagogique est indispensable, et pourquoi ?$mft$,
   $mft$Faire émerger les représentations du groupe (tour de table, croyances exprimées) : des faits assénés d'emblée glissent sur des croyances non formulées, alors qu'une représentation exprimée à voix haute peut être confrontée aux faits et révisée.$mft$,
   2, 'moyen', ARRAY['ecsr','module-4','question-courte'], 'ECSR-M4-QC-04', false,
   $mft$Représentations d'abord, faits ensuite.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Expliquez en deux phrases pourquoi le bachotage de séries est une impasse pour préparer l'ETG.$mft$,
   $mft$Les questions posées le jour J en centre ne sont pas celles des séries : la mémorisation des réponses ne transfère pas. Seule la compréhension des notions, avec la méthode de lecture d'image et des formulations, permet de traiter une question nouvelle.$mft$,
   2, 'moyen', ARRAY['ecsr','module-4','question-courte'], 'ECSR-M4-QC-05', false,
   $mft$Les questions changent ; la compréhension transfère, pas le par-cœur.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Donnez deux exemples de fautes éliminatoires à l'épreuve pratique B, et ce qu'elles entraînent quel que soit le total de points.$mft$,
   $mft$L'intervention de l'examinateur (verbale impérative ou physique sur les commandes) et le franchissement dangereux : elles entraînent l'échec même si le candidat atteint le seuil de points.$mft$,
   2, 'moyen', ARRAY['ecsr','module-4','question-courte'], 'ECSR-M4-QC-06', false,
   $mft$Intervention de l'examinateur, franchissement dangereux : échec quel que soit le score.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Un élève vient d'échouer à l'épreuve pratique : citez les trois étapes de votre démarche d'analyse.$mft$,
   $mft$Relecture factuelle du bilan de l'inspecteur (sans complaisance ni accablement), plan de travail ciblé sur les compétences en défaut, re-présentation au bon moment (pas trop tôt).$mft$,
   2, 'moyen', ARRAY['ecsr','module-4','question-courte'], 'ECSR-M4-QC-07', false,
   $mft$Bilan relu, plan ciblé, re-présentation au bon moment.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Donnez trois raisons professionnelles de ne présenter à l'examen que des élèves prêts.$mft$,
   $mft$La place d'examen est rare (un échec prévisible la gaspille et retarde les autres candidats), l'échec coûte à l'élève (argent, confiance, parfois abandon), et il dégrade le taux de réussite de l'école ainsi que sa crédibilité auprès des inspecteurs.$mft$,
   2, 'moyen', ARRAY['ecsr','module-4','question-courte'], 'ECSR-M4-QC-08', false,
   $mft$Place rare, coût pour l'élève, taux et crédibilité de l'école.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$En quoi la phase de conduite autonome de l'épreuve B change-t-elle ce que vous devez enseigner en amont ?$mft$,
   $mft$L'élève doit suivre seul un itinéraire vers une destination, sans guidage continu : il faut donc enseigner la lecture d'itinéraire (panneaux, direction), la prise de décision et l'autonomie, et pas seulement l'exécution de consignes données au fil de l'eau.$mft$,
   2, 'difficile', ARRAY['ecsr','module-4','question-courte'], 'ECSR-M4-QC-09', false,
   $mft$Autonomie = décider seul, pas exécuter des consignes.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$En séance collective, un participant conteste systématiquement vos apports (« moi je roule vite et il ne m'est jamais rien arrivé »). Citez deux techniques pour le gérer sans crisper le groupe.$mft$,
   $mft$Ne pas s'affronter frontalement : renvoyer la question au groupe (« qu'en pensent les autres ? ») pour que le collectif fasse le travail, et ramener l'échange aux faits concrets (cas locaux, situations vécues) plutôt qu'au duel d'opinions.$mft$,
   2, 'difficile', ARRAY['ecsr','module-4','question-courte'], 'ECSR-M4-QC-10', false,
   $mft$Renvoi au groupe + retour aux faits, jamais d'affrontement frontal.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Concevez le plan détaillé d'une séance collective d'une heure sur le thème de la vitesse pour un groupe de dix élèves : étapes, techniques d'animation mobilisées et écueils à éviter.$mft$,
   $mft$Réponse modèle. Ouverture (environ 5 minutes) : annoncer l'objectif (« à la fin de la séance, vous saurez expliquer ce que la vitesse change dans la perception et les distances »). Activation (10 minutes) : faire émerger les représentations AVANT tout apport : tour de table ou post-it (« la vitesse, pour vous, c'est... »), sans juger les réponses. Apport structuré (15 minutes) : confronter les croyances exprimées aux faits (champ visuel, distances, énergie), avec images et exemples locaux (la départementale que tous connaissent). Exercices commentés (20 minutes) : cas concrets travaillés en sous-groupes de trois ou quatre, puis mise en commun : chaque sous-groupe justifie sa réponse à voix haute. Synthèse (10 minutes) : points clés reformulés par les participants eux-mêmes, l'animateur complète. Techniques transversales : questionnement circulaire pour faire circuler la parole, sollicitation nommée des silencieux, renvoi au groupe face au contestataire. Écueils : asséner les statistiques d'emblée (elles glissent sur les représentations), moraliser (« c'est mal »), affronter frontalement un contestataire, laisser la vidéo ou la série remplacer l'animation, et conclure soi-même ce que le groupe aurait pu conclure.$mft$,
   $mft$Barème /5 : structure complète en cinq temps avec minutage cohérent (2 pts) ; représentations recueillies avant les faits (1 pt) ; au moins deux techniques d'animation nommées et employées à propos (1 pt) ; au moins deux écueils identifiés (1 pt). Erreurs fréquentes : bâtir la séance sur un défilement de séries ; ouvrir par les statistiques ou la morale.$mft$,
   5, 'facile', ARRAY['ecsr','module-4','question-redigee'], 'ECSR-M4-QR-01', false,
   $mft$Un scénario de séance collective complet, technique et réaliste.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un élève anxieux vous demande : « concrètement, comment je serai noté à l'examen du permis ? ». Rédigez l'explication complète et rassurante que vous lui donnez : déroulé, grille, conditions de réussite, erreurs éliminatoires et droit à l'erreur.$mft$,
   $mft$Réponse modèle. « L'épreuve dure 32 minutes, avec un inspecteur (IPCSR) qui remplit une grille nationale : il n'improvise rien et ne cherche à piéger personne. La grille évalue des compétences : ton installation au poste de conduite, des questions de vérifications et de première assistance, le maniement du véhicule, ta conduite en circulation, une phase en autonomie où tu suis un itinéraire sans guidage continu, ainsi que ta courtoisie et ta conduite économe (selon la grille en vigueur). Le total est noté sur 31 points : tu es admis à partir de 20 points, à une condition : ne pas commettre d'erreur éliminatoire. Éliminatoire, cela veut dire une situation où l'inspecteur doit intervenir pour la sécurité, ou un franchissement dangereux. Tout le reste (un calage, un créneau repris, une hésitation) coûte au pire quelques points : avec le seuil à 20 sur 31, tu as une vraie marge. Donc si tu fais une erreur : tu respires, tu sécurises, tu continues : l'examen se joue sur les 32 minutes entières. Le résultat ne tombe pas sur place : il se consulte en ligne, en général sous 48 heures. Et tout cela, on l'aura déjà vécu ensemble en examen blanc. »$mft$,
   $mft$Barème /5 : durée et notation exactes (32 minutes, 31 points, admis à partir de 20) (1,5 pt) ; compétences de la grille citées, dont vérifications/première assistance et autonomie (1,5 pt) ; erreurs éliminatoires expliquées (intervention de l'examinateur, franchissement dangereux) (1 pt) ; droit à l'erreur et ton rassurant adapté à l'élève (1 pt). Erreurs fréquentes : présenter toute erreur comme éliminatoire ; oublier le caractère cumulatif des deux conditions (points ET absence d'éliminatoire).$mft$,
   5, 'facile', ARRAY['ecsr','module-4','question-redigee'], 'ECSR-M4-QR-02', false,
   $mft$Expliquer la grille avec des mots simples : un attendu du métier.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Un élève a échoué deux fois à l'épreuve théorique alors qu'il « fait des séries tous les soirs ». Posez votre diagnostic et construisez son plan de préparation pour la troisième présentation.$mft$,
   $mft$Réponse modèle. Diagnostic : le travail massif de séries produit de la reconnaissance, pas de la compréhension : l'élève reconnaît les questions déjà vues et échoue face aux questions nouvelles du centre, qui portent sur les mêmes notions autrement formulées. Vérifier aussi la méthode de lecture (l'image est-elle balayée ? la question lue deux fois ?) et le facteur stress : deux échecs installent l'appréhension. Plan : 1) analyser les résultats par thématique pour identifier les familles de notions faibles ; 2) reprendre ces notions en cours thématiques (objectif, activation, apport, exercices commentés, synthèse) : comprendre la règle, pas mémoriser la réponse ; 3) rééduquer la lecture : images projetées sans question puis verbalisation, repérage des formulations pièges (« je peux » contre « je dois », négations, conditions) ; 4) réintroduire les séries comme outil de diagnostic, en exigeant la justification de chaque réponse à voix haute ; 5) deux examens blancs en conditions réelles (durée, rythme, sans pause) ; 6) fixer la date quand les scores sont stables au-dessus du seuil de 35 sur 40 sur plusieurs sessions récentes, pas après une seule série réussie. Rappeler enfin le droit à l'erreur : cinq erreurs sont admises, viser le sans-faute nourrit le stress.$mft$,
   $mft$Barème /5 : diagnostic du bachotage (reconnaissance sans compréhension) (1,5 pt) ; plan structuré combinant cours thématiques, lecture d'image et pièges de formulation (1,5 pt) ; examens blancs en conditions réelles et gestion du stress (1 pt) ; critère objectif de re-présentation (scores stables au-dessus du seuil) (1 pt). Erreurs fréquentes : prescrire simplement « plus de séries » ; fixer la date sur l'impatience de l'élève.$mft$,
   5, 'moyen', ARRAY['ecsr','module-4','question-redigee'], 'ECSR-M4-QR-03', false,
   $mft$Du diagnostic au plan : sortir un élève de l'impasse du bachotage.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Séance collective sur l'alcool avec un groupe de jeunes conducteurs qui plaisantent (« moi je tiens bien l'alcool », « c'est bon, on habite à cinq minutes »). Décrivez votre conduite de séance : comment faire émerger et travailler ces représentations sans moraliser ni perdre le groupe.$mft$,
   $mft$Réponse modèle. Premier réflexe : ne pas rabattre les plaisanteries d'un « c'est faux » : sur les thèmes durs, les faits assénés glissent sur des croyances non exprimées. Étape 1, accueillir et faire formuler : « qui pense aussi qu'on peut bien tenir l'alcool ? » : tour de table ou vote à main levée, les représentations s'affichent sans jugement. Étape 2, faire travailler le groupe sur ses propres énoncés : renvoyer au collectif (« qu'en pensent les autres ? »), faire préciser (« tenir l'alcool, ça veut dire quoi pour la conduite ? »), mobiliser un cas concret local (le retour de soirée sur la route que tous connaissent). Étape 3, apporter les faits en réponse aux représentations exprimées : ce que l'alcool dégrade réellement (perception, réflexes, décision), sans morale ni menace : du concret, pas du « c'est mal ». Étape 4, exercices commentés en sous-groupes sur des situations de retour de soirée (qui conduit ? quelles solutions ?), puis mise en commun. Étape 5, synthèse formulée par les participants. Posture constante : jamais d'affrontement frontal avec le provocateur (le groupe, bien questionné, fait le travail), valorisation de la première prise de parole des silencieux. Le but : que le groupe conclue lui-même, car une conclusion construite est une conclusion retenue.$mft$,
   $mft$Barème /5 : représentations recueillies avant les faits (1,5 pt) ; techniques d'animation concrètes (renvoi au groupe, cas local, sous-groupes) (1,5 pt) ; apport factuel sans moralisation (1 pt) ; gestion du provocateur sans affrontement et synthèse par le groupe (1 pt). Erreurs fréquentes : ouvrir par les chiffres ou les sanctions ; humilier le plaisantin devant le groupe.$mft$,
   5, 'moyen', ARRAY['ecsr','module-4','question-redigee'], 'ECSR-M4-QR-04', false,
   $mft$Le thème dur par excellence, traité par les représentations.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Décrivez la procédure complète d'un examen blanc réaliste de l'épreuve pratique B, de la préparation au débriefing, en précisant votre posture pendant l'épreuve.$mft$,
   $mft$Réponse modèle. Préparation : programmer l'examen blanc quand les compétences approchent du niveau attendu ; choisir un secteur comparable aux parcours d'examen ; prévoir la durée réelle de 32 minutes. Mise en situation : accueillir l'élève comme le ferait l'inspecteur, donner les consignes du jour J, dérouler les composantes de l'épreuve : installation, questions de vérifications et de première assistance, conduite en circulation, manœuvre, phase de conduite autonome vers une destination. Posture pendant l'épreuve : neutralité totale : aucun conseil, aucune mimique, aucune correction ; on observe et on note dans la logique de la grille ; on n'intervient que si la sécurité l'exige, en expliquant ensuite à l'élève que cette intervention aurait été éliminatoire le jour J. Débriefing : à froid, structuré par la grille : points acquis, points de travail, verdict argumenté (« aujourd'hui, tu aurais obtenu tel niveau »), en distinguant erreurs simples (des points en moins) et erreurs éliminatoires (l'échec). Terminer par un plan : deux ou trois priorités de travail, pas une liste décourageante. Répéter l'exercice : deux ou trois examens blancs espacés valent mieux qu'un seul la veille ; le second mesure les progrès et installe la routine anti-stress.$mft$,
   $mft$Barème /5 : conditions réalistes (durée, consignes, composantes dont autonomie et vérifications) (2 pts) ; posture neutre justifiée, intervention limitée à la sécurité (1,5 pt) ; débriefing structuré par la grille avec distinction erreur simple/éliminatoire (1 pt) ; répétition espacée des examens blancs (0,5 pt). Erreurs fréquentes : conseiller pendant l'épreuve ; débriefer à chaud, en vrac, sans logique de grille.$mft$,
   5, 'moyen', ARRAY['ecsr','module-4','question-redigee'], 'ECSR-M4-QR-05', false,
   $mft$L'examen blanc comme outil professionnel, pas comme leçon déguisée.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Votre élève vient d'échouer à l'épreuve B : le bilan mentionne une intervention de l'inspecteur lors d'une insertion. Elle accuse « l'inspecteur qui l'a stressée ». Menez l'entretien post-échec et construisez la suite : analyse, plan de travail, décision de re-présentation.$mft$,
   $mft$Réponse modèle. À chaud, le jour même : accueillir la déception sans analyser ni valider l'accusation : « on regarde le bilan ensemble à tête reposée ». Quelques jours plus tard, l'entretien : relire le bilan FACTUELLEMENT, compétence par compétence : une intervention de l'examinateur est une erreur éliminatoire, elle signifie que la sécurité a dû être préservée à sa place : le fait est là, il ne se conteste pas. Dépersonnaliser : « la grille dit que l'insertion n'est pas encore fiable », pas « tu es nulle » : sans complaisance (nier le niveau prépare le prochain échec) ni accablement (un échec est une information, pas un verdict sur la personne). Traiter l'accusation : reconnaître le stress comme un facteur réel à travailler, sans en faire la cause unique : l'insertion a lâché sous pression parce qu'elle n'était pas assez automatisée. Plan ciblé : leçons dédiées aux insertions (variété de situations, trafic dense), puis remise en situation d'évaluation (examen blanc avec posture neutre) pour reproduire la pression. Re-présentation : au bon moment, quand l'insertion est stable en examen blanc : ni trop tôt (échec en boucle), ni trop tard (démobilisation). Formaliser le plan avec elle : objectifs, échéances, critères observables.$mft$,
   $mft$Barème /5 : gestion du chaud et du froid, refus du procès de l'inspecteur (1 pt) ; lecture factuelle du bilan et sens de l'intervention éliminatoire (1,5 pt) ; équilibre sans complaisance ni accablement, dépersonnalisation (1 pt) ; plan ciblé insertion avec examen blanc et critère objectif de re-présentation (1,5 pt). Erreurs fréquentes : valider l'accusation pour consoler ; re-présenter immédiatement sans traiter la cause.$mft$,
   5, 'moyen', ARRAY['ecsr','module-4','question-redigee'], 'ECSR-M4-QR-06', false,
   $mft$L'entretien post-échec : la lucidité qui reconstruit.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Le gérant de l'école vous demande de présenter à l'épreuve pratique un élève que vous jugez non prêt : « il a payé, il s'impatiente, et notre taux affiché est bon ». Analysez tous les enjeux (pédagogiques, éthiques, statistiques, relations avec les inspecteurs) et construisez votre réponse professionnelle.$mft$,
   $mft$Réponse modèle. Enjeux pédagogiques : un élève présenté non prêt subit un échec prévisible : coût financier, perte de confiance, parfois abandon ; l'échec n'apprend rien quand il ne fait que sanctionner un niveau insuffisant connu d'avance. Enjeux collectifs et éthiques : la place d'examen est une ressource rare : la consommer pour un échec probable retarde tous les autres candidats de l'école. Enjeux statistiques : paradoxe pour le gérant : présenter des élèves non prêts dégrade précisément le taux de réussite qu'il met en avant ; et un taux affiché se lit avec ses biais (profil des élèves, volume, politique de présentation). Enjeux professionnels : la crédibilité de l'école auprès des inspecteurs se construit sur des candidats prêts et des conditions irréprochables : elle se perd vite. Réponse : refuser la présentation en l'état, sur des éléments OBJECTIFS : résultats d'examens blancs, compétences non stabilisées au regard de la grille ; proposer une alternative datée : plan ciblé sur quelques semaines, examen blanc de validation, présentation dès que les critères sont atteints ; recevoir l'élève pour expliquer la décision avec les mêmes faits (« te présenter maintenant, c'est te préparer à échouer »). L'éthique de présentation n'est pas un luxe : c'est l'intérêt bien compris de l'élève, de l'école et de son taux.$mft$,
   $mft$Barème /5 : enjeux pédagogiques et coût de l'échec pour l'élève (1 pt) ; rareté de la place d'examen et impact collectif (1 pt) ; paradoxe statistique et biais des taux (1 pt) ; crédibilité vis-à-vis des IPCSR (0,5 pt) ; réponse structurée sur critères objectifs avec alternative datée (1,5 pt). Erreurs fréquentes : céder « pour cette fois » ; refuser sèchement sans proposer ni plan ni critères.$mft$,
   5, 'difficile', ARRAY['ecsr','module-4','question-redigee'], 'ECSR-M4-QR-07', false,
   $mft$Dire non au gérant : l'éthique de présentation argumentée.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Comparez l'épreuve théorique générale et l'épreuve pratique du permis B du point de vue de la préparation que l'enseignant doit construire : nature de l'évaluation, compétences visées, place des examens blancs et gestion du stress.$mft$,
   $mft$Réponse modèle. Nature de l'évaluation : l'ETG est une épreuve standardisée et automatisée (40 questions, admis à partir de 35 bonnes réponses, en centre agréé d'un opérateur privé) ; l'épreuve pratique est une évaluation humaine par un IPCSR sur grille (notation sur 31 points, admis à partir de 20, sans erreur éliminatoire) : d'un côté un score sec, de l'autre un jugement de compétences en situation. Compétences visées : pour l'ETG, comprendre des notions et savoir lire (image balayée, formulations pièges) : le par-cœur ne transfère pas car les questions changent ; pour la pratique, automatiser des savoir-faire (installation, maniement, circulation) ET construire l'autonomie (suivre un itinéraire sans guidage) : la compétence doit tenir sous pression. Examens blancs : indispensables des deux côtés, mais différents : pour l'ETG, reproduire le format (durée, rythme, interface) ; pour la pratique, reproduire la relation d'examen (posture neutre de l'enseignant, consignes du jour J, débriefing par la grille). Stress : à l'ETG, il se gère par la stratégie (cinq erreurs admises, ne pas ressasser une question ratée) ; à la pratique, par la routine d'installation, le droit à l'erreur non éliminatoire et la phrase de reprise après incident. Constante : la date de présentation se décide sur des résultats stables, jamais sur l'impatience.$mft$,
   $mft$Barème /5 : nature des deux évaluations avec les repères exacts (40/35 ; 31 points, admis à partir de 20, sans éliminatoire) (1,5 pt) ; compétences visées distinguées (compréhension et lecture contre automatismes et autonomie) (1,5 pt) ; rôle différencié des examens blancs (1 pt) ; gestion du stress propre à chaque épreuve et critère commun de présentation (1 pt). Erreurs fréquentes : comparer les seuls formats sans en tirer les conséquences pédagogiques ; oublier la condition d'absence d'erreur éliminatoire.$mft$,
   5, 'difficile', ARRAY['ecsr','module-4','question-redigee'], 'ECSR-M4-QR-08', false,
   $mft$Deux épreuves, deux préparations : la comparaison qui structure le métier.$mft$);

  RAISE NOTICE 'Module 4 ECSR créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $ecsrm4$;
