-- =====================================================================
-- TITRE PROFESSIONNEL ECSR : MODULE 6 : PRÉPARER LA SESSION DU TITRE
-- v1 (juillet 2026)
--
-- ⚠ PRÉREQUIS : appliquer d'abord les modules 1 à 5 (ECSR-M1 à ECSR-M5).
--   Les examens blancs sont composés de questions EXISTANTES de la
--   banque (liaison par source_ref, aucune duplication) : si un module
--   manque, l'examen blanc sera partiel (le script l'indique en NOTICE).
--
-- Contenu :
--   - 1 leçon : la session du titre (mise en situation, dossier
--     professionnel, entretiens), synthèse des 5 modules, planning
--   - 6 questions courtes + 4 questions rédigées transversales
--   - Examen blanc 1 : 20 QCM (4 par module), 30 min, seuil 60 %
--   - Examen blanc 2 : épreuve mixte 10 QCM + 5 QR, 90 min, seuil 60 %
--
-- ⚠ STATUT : questions insérées avec active = false (« à valider »).
-- Idempotent : DELETE ciblés par slug/source_ref, rejouable sans doublon.
-- =====================================================================

DO $ecsrm6$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_l uuid;
  v_eb1 uuid;
  v_eb2 uuid;
  v_count int;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'ecsr';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation ecsr introuvable.';
  END IF;

  INSERT INTO public.blocs (id, code, title, description, "order") VALUES (60, 'ECSR', 'Titre professionnel Enseignant de la conduite et de la sécurité routière', 'Préparation au titre professionnel ECSR (niveau 5, deux CCP) : former des apprenants conducteurs et sensibiliser tous les usagers de la route.', 60) ON CONFLICT DO NOTHING;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'ECSR';

  DELETE FROM public.question_bank WHERE source_ref LIKE 'ECSR-M6-%';
  DELETE FROM public.modules WHERE slug = 'ecsr-preparation-titre';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Module 6 : Préparer la session du titre',
    'ecsr-preparation-titre',
    v_bloc,
    'La session d''examen du titre (mises en situation, dossier professionnel, entretiens), la synthèse des cinq modules et deux évaluations blanches.',
    'avance',
    180,
    60
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 60, true);

  -- ─── Leçon unique : réussir la session ──────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'reussir-la-session',
    'Réussir la session du titre : épreuves, dossier, entretiens',
    $mft$> 🎯 **Objectifs**
> - Connaître le déroulé type d'une session d'examen du titre ECSR.
> - Rédiger un dossier professionnel qui prépare réellement les entretiens.
> - Réviser l'essentiel des cinq modules en un seul tableau.
> - Dérouler un planning de préparation efficace jusqu'au jour J.

## Ce qui vous attend le jour de la session

Le titre professionnel ECSR est un titre de niveau 5, délivré par le préfet, composé de deux CCP : former des apprenants conducteurs (CCP1) et sensibiliser tous les usagers de la route (CCP2). La session d'examen vous place face à un jury composé de professionnels du secteur, qui évalue des compétences en action, pas des connaissances récitées. Déroulé type :

:::flow
1. Mise en situation | Une séance de conduite ou une animation à préparer puis à conduire devant le jury
2. Dossier professionnel | Vos pratiques rédigées, remises en amont, socle des échanges
3. Entretien technique | Le jury questionne vos choix pédagogiques et vos connaissances
4. Entretien final | Échange sur votre posture et votre vision du métier
:::

> ⚠️ **Attention**
> Les modalités précises (durées, ordre des épreuves, grilles de notation) sont fixées par le référentiel d'évaluation en vigueur : elles peuvent évoluer d'une session à l'autre (à vérifier auprès de votre centre d'examen avant la session). Ce qui ne change pas : le jury cherche un professionnel capable d'agir ET d'expliquer pourquoi il agit ainsi.

## La mise en situation professionnelle

Que le sort vous donne une séance de conduite ou une animation, la logique est la même : préparer, conduire, justifier. Le jury doit retrouver les marqueurs travaillés dans les modules 2, 3 et 5 : un objectif annoncé et relié au référentiel, une démarche adaptée à la personne ou au public, un guidage qui laisse progressivement la main, un bilan fondé sur des faits observés. Une prestation techniquement correcte mais muette sur ses intentions pédagogiques laisse le jury deviner : ne le laissez jamais deviner, annoncez.

## Le dossier professionnel : rédiger ses pratiques

Le dossier professionnel raconte VOS pratiques, avec des exemples vécus. Pour chaque activité, la même ossature fonctionne : le contexte (qui, où, quel besoin), ce que vous avez fait (vos choix, dans l'ordre), ce que cela a produit (progression constatée, réaction du public), et ce que vous en retirez. Trois exigences :

- **Des exemples vécus, datés, incarnés** : une situation réelle avec un vrai prénom d'élève (anonymisé) vaut mieux que trois généralités.
- **Le vocabulaire du référentiel** : nommer la compétence REMC travaillée, situer l'élève dans la matrice GDE : le jury lit un futur collègue, pas un candidat qui découvre les mots.
- **Rien que du défendable** : chaque ligne du dossier peut devenir une question d'entretien ; n'écrivez rien que vous ne puissiez développer cinq minutes.

## Les deux entretiens

L'entretien technique part de votre mise en situation et de votre dossier : pourquoi cet objectif, pourquoi ce guidage, qu'auriez-vous fait si l'élève avait échoué ? La bonne réponse relie toujours un choix à un besoin constaté. L'entretien final élargit : votre représentation du métier, votre manière de continuer à vous former, votre posture face aux publics difficiles. Le jury étant composé de professionnels du secteur, il repère vite le discours plaqué : parlez de ce que vous avez réellement vécu en formation.

## Le tableau de synthèse des cinq modules

| Module | L'essentiel à mobiliser le jour J |
| --- | --- |
| M1 : Le métier et le titre | Titre de niveau 5 délivré par le préfet ; deux CCP : former des apprenants conducteurs, sensibiliser tous les usagers |
| M2 : REMC et GDE | REMC structuré en 4 compétences ; matrice GDE en 4 niveaux (du maniement du véhicule aux motivations et au style de vie) |
| M3 : Pédagogie individuelle | Objectif de séance annoncé, guidage décroissant, feedback factuel |
| M4 : Collectif et examens | ETG : 35 bonnes réponses sur 40 ; épreuve pratique B : 32 minutes, admissible à partir de 20 points sur 31, sans erreur éliminatoire |
| M5 : Sensibilisation (CCP2) | Objectifs évaluables ; démarche adaptée au public, participative et non descendante |

> 📌 **À retenir**
> Les paires piégeuses à ne plus confondre : les **4 compétences** du REMC et les **4 niveaux** de la GDE (deux « 4 » qui ne décrivent pas la même chose) ; **35/40** (ETG) et **20/31** (épreuve pratique B) ; l'**entretien technique** (vos choix pédagogiques) et l'**entretien final** (votre posture et votre vision du métier) ; **CCP1** (former) et **CCP2** (sensibiliser).

## Les pièges classiques du candidat

- ❌ **La séance sans objectif** : on roule, on corrige, mais personne ne sait ce qui se travaille ni comment mesurer la progression. C'est le piège le plus fréquent et le plus coûteux.
- ❌ **Le feedback jugeant** : « c'était moyen », « il faut être plus sérieux » : un jugement sur la personne au lieu de faits observés. Le jury y voit un enseignant qui décourage au lieu de faire progresser.
- ❌ **L'action de sensibilisation descendante** : un exposé magistral de rappels de règles devant un public passif. La sensibilisation se construit AVEC le public, à partir de son vécu, vers des objectifs évaluables.

## Se préparer : trois outils qui changent tout

- 🔍 **Filmer ses séances** : la vidéo révèle ce que la mémoire embellit (temps de parole, consignes floues, guidage qui ne décroît jamais). Une grille simple suffit : objectif annoncé ? guidage décroissant ? bilan factuel ?
- 💡 **La banque de situations vécues** : une fiche par situation marquante (contexte, ce que j'ai fait, résultat, lien avec le référentiel). Le jour des entretiens, vous puisez dedans au lieu d'improviser.
- 🎓 **Les simulations d'entretien** : un pair ou un formateur vous questionne à partir de votre dossier, en conditions réelles. Deux simulations valent mieux que dix relectures.

## Le planning des derniers jours

:::timeline
1. **J-21 à J-15** : examen blanc 1 (QCM) sans documents ; retour ciblé sur les deux modules les plus faibles ; deux séances filmées et auto-analysées avec la grille.
2. **J-14 à J-8** : examen blanc 2 (mixte) en conditions réelles ; dossier professionnel finalisé et relu par un tiers ; première simulation d'entretien technique.
3. **J-7 à J-2** : dernière séance filmée ; simulation d'entretien final ; banque de situations et tableau des cinq modules relus chaque soir ; aucun contenu nouveau.
4. **J-1** : logistique du jour J (trajet, convocation, tenue professionnelle, dossier), coucher tôt.
5. **Jour J** : arriver en avance ; en mise en situation, annoncer l'objectif et sécuriser ; en entretien, relier chaque réponse à une situation vécue.
:::

## ✅ Synthèse

- La session : **mise en situation + dossier professionnel + entretien technique + entretien final**, devant un jury de professionnels (modalités exactes : référentiel d'évaluation en vigueur, à vérifier).
- Le dossier se rédige avec des **exemples vécus** et le **vocabulaire du référentiel** ; tout ce qui y figure doit être défendable en entretien.
- Révision finale : **le tableau des cinq modules** et les paires piégeuses ; préparation active : **filmer, ficher, simuler**.
- Trois pièges éliminatoires dans les têtes du jury : séance sans objectif, feedback jugeant, sensibilisation descendante.$mft$,
    $mft$Le déroulé type de la session du titre (mise en situation, dossier professionnel, deux entretiens), la rédaction du dossier, le tableau de synthèse des cinq modules avec les paires piégeuses, et le planning des trois dernières semaines.$mft$,
    1, 45) RETURNING id INTO v_l;

  -- ─── Questions courtes transversales (6) ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l, 'qr',
   $mft$De combien de CCP se compose le titre professionnel ECSR, quels sont-ils, et quelle autorité délivre le titre ?$mft$,
   $mft$Deux CCP : former des apprenants conducteurs (CCP1) et sensibiliser tous les usagers de la route (CCP2) ; le titre, de niveau 5, est délivré par le préfet.$mft$,
   2, 'facile', ARRAY['ecsr','module-6','question-courte'], 'ECSR-M6-QC-01', false,
   $mft$Les deux CCP nommés ET l'autorité de délivrance sont attendus.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Deux « 4 » structurent le référentiel : combien de compétences pour le REMC, combien de niveaux pour la matrice GDE ?$mft$,
   $mft$Le REMC est structuré en 4 compétences ; la matrice GDE compte 4 niveaux (du maniement du véhicule jusqu'aux motivations et au style de vie).$mft$,
   2, 'facile', ARRAY['ecsr','module-6','question-courte'], 'ECSR-M6-QC-02', false,
   $mft$Deux « 4 » différents à ne pas fusionner : compétences d'enseignement d'un côté, niveaux d'analyse du conducteur de l'autre.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Pendant votre mise en situation, quels sont les trois marqueurs pédagogiques que le jury doit retrouver dans votre séance individuelle ?$mft$,
   $mft$Un objectif de séance annoncé (et relié au référentiel), un guidage décroissant (l'aide diminue à mesure que l'élève progresse) et un feedback factuel (fondé sur des faits observés, pas sur un jugement de la personne).$mft$,
   2, 'moyen', ARRAY['ecsr','module-6','question-courte'], 'ECSR-M6-QC-03', false,
   $mft$Le triptyque du module 3 : objectif, guidage décroissant, feedback factuel.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Votre élève affirme : « avec 30 bonnes réponses au code, je suis tranquille, et à la pratique il suffit de ne pas caler ». Rétablissez les seuils réels des deux épreuves du permis B.$mft$,
   $mft$ETG : au moins 35 bonnes réponses sur 40 ; épreuve pratique B : 32 minutes, admissible à partir de 20 points sur 31, à condition de ne commettre aucune erreur éliminatoire.$mft$,
   2, 'moyen', ARRAY['ecsr','module-6','question-courte'], 'ECSR-M6-QC-04', false,
   $mft$Les deux seuils exacts et la condition « sans erreur éliminatoire » sont attendus : caler n'est pas le sujet.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Citez les deux exigences qui distinguent une véritable action de sensibilisation (CCP2) d'un simple exposé de rappels de règles.$mft$,
   $mft$Des objectifs évaluables (on peut mesurer ce que le public a acquis à la fin) et une démarche adaptée au public visé, participative et construite à partir de son vécu, plutôt que descendante.$mft$,
   2, 'moyen', ARRAY['ecsr','module-6','question-courte'], 'ECSR-M6-QC-05', false,
   $mft$Objectifs évaluables + adaptation au public : les deux critères du module 5.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$La session du titre comporte deux entretiens : distinguez l'objet de l'entretien technique de celui de l'entretien final.$mft$,
   $mft$L'entretien technique porte sur les choix professionnels et pédagogiques du candidat, à partir de sa mise en situation et de son dossier professionnel ; l'entretien final, mené par le jury de professionnels, porte sur la posture et la vision globale du métier (les modalités précises relèvent du référentiel d'évaluation en vigueur).$mft$,
   2, 'difficile', ARRAY['ecsr','module-6','question-courte'], 'ECSR-M6-QC-06', false,
   $mft$Technique = justifier ses choix ; final = posture et représentation du métier. Vérifier les modalités de la session en cours auprès du centre.$mft$);

  -- ─── Questions rédigées transversales (4) : barème /5 ───────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l, 'qr',
   $mft$Session blanche. Un candidat conduit une séance individuelle : il démarre sans annoncer d'objectif, corrige l'élève en continu du début à la fin, puis conclut par « c'était moyen, il faut être plus sérieux ». Analysez ses trois erreurs au regard des modules 2 et 3, puis réécrivez le déroulé corrigé de la même séance.$mft$,
   $mft$Réponse modèle. Erreur 1 : la séance sans objectif : l'élève ne sait ni ce qu'il travaille ni comment mesurer sa progression, et le candidat ne peut relier sa séance à aucune compétence du REMC : le jury ne voit qu'une heure de conduite surveillée. Erreur 2 : la correction en continu : le guidage ne décroît jamais, l'élève n'accède pas à l'autonomie ; or c'est précisément le retrait progressif de l'aide qui prouve l'apprentissage. Erreur 3 : le bilan jugeant : « moyen » et « plus sérieux » qualifient la personne, pas la conduite ; sans faits observés, l'élève ne sait pas quoi corriger et se décourage. Déroulé corrigé : annoncer en début de séance un objectif relié à une compétence du REMC, avec des critères de réussite observables ; guider fortement les premières réalisations puis se taire progressivement, en laissant l'élève décider ; conclure par un bilan factuel : les réussites constatées, un ou deux points précis à retravailler, une auto-évaluation demandée à l'élève, et l'objectif de la séance suivante. La séance devient mesurable, autonomisante et motivante : exactement ce que le jury cherche.$mft$,
   $mft$Barème /5 : les trois erreurs identifiées avec leur mécanisme (1,5 pt) ; lien explicite avec le référentiel (compétence REMC, autonomie visée) (1 pt) ; déroulé corrigé complet : objectif annoncé avec critères, guidage décroissant, bilan factuel avec auto-évaluation (2 pts) ; qualité de la posture décrite (encourager sans juger) (0,5 pt). Erreurs fréquentes : réécrire une belle séance sans traiter les trois erreurs une à une ; remplacer le jugement négatif par un compliment tout aussi vague.$mft$,
   5, 'moyen', ARRAY['ecsr','module-6','question-redigee'], 'ECSR-M6-QR-01', false,
   $mft$Autopsie d'une séance ratée : les trois pièges du candidat traités et corrigés.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Vous rédigez votre dossier professionnel. Choisissez deux situations vécues (une pour chaque CCP) et montrez, pour chacune, comment la rédiger : structure, faits, lien avec le référentiel, et l'usage que vous en ferez pendant les entretiens.$mft$,
   $mft$Réponse modèle. Structure commune : le contexte (qui, où, quel besoin constaté), mes actions dans l'ordre et les raisons de chaque choix, le résultat observé, ce que j'en retire. Situation CCP1 (former) : un élève bloqué sur une compétence du REMC (par exemple l'insertion en circulation dense) ; je raconte le diagnostic, l'objectif fixé avec lui, le guidage fort puis décroissant sur plusieurs séances, les feedbacks factuels, et la progression constatée ; le vocabulaire du référentiel (compétence REMC, niveau GDE de l'élève) montre que je pense en professionnel. Situation CCP2 (sensibiliser) : une action auprès d'un public identifié ; je décris les objectifs évaluables fixés à l'avance, la démarche participative construite sur le vécu des participants, et la mesure des acquis en fin d'action. Usage en entretien : le jury part du dossier ; chaque affirmation doit donc être développable cinq minutes, avec des détails vrais (réactions, difficultés, ajustements). Je prépare pour chaque situation les questions probables (pourquoi ce choix ? et si cela avait échoué ?) et je fais relire l'ensemble par un pair avant dépôt.$mft$,
   $mft$Barème /5 : structure de rédaction claire et réutilisable (1 pt) ; situation CCP1 pertinente avec vocabulaire du référentiel (REMC, GDE) (1,5 pt) ; situation CCP2 avec objectifs évaluables et démarche adaptée au public (1,5 pt) ; anticipation de l'usage en entretien (questions probables, relecture) (1 pt). Erreurs fréquentes : recopier le référentiel sans vécu personnel ; choisir deux situations relevant du même CCP ; affirmer dans le dossier ce qu'on ne sait pas défendre à l'oral.$mft$,
   5, 'moyen', ARRAY['ecsr','module-6','question-redigee'], 'ECSR-M6-QR-02', false,
   $mft$Le dossier professionnel construit comme un outil d'entretien : deux CCP, deux récits défendables.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Le jury vous demande de concevoir une animation de sensibilisation destinée aux conducteurs expérimentés d'une entreprise, présents sur inscription de leur employeur (public non volontaire). Construisez-la : objectifs évaluables, démarche adaptée, déroulé, évaluation ; expliquez en quoi la matrice GDE justifie vos choix.$mft$,
   $mft$Réponse modèle. Objectifs évaluables, formulés en capacités : « à la fin de l'animation, les participants sauront identifier leurs trois situations à risque les plus fréquentes et s'engager sur une action concrète ». Démarche : public expérimenté et non volontaire, donc partir de LEUR vécu : tour de table des situations réellement rencontrées, ateliers en petits groupes sur des cas apportés par eux, échanges entre pairs ; aucun exposé descendant de rappels de règles, aucun ton moralisateur, qui braqueraient un public qui conduit depuis vingt ans. Justification par la GDE : chez des conducteurs expérimentés, le risque ne se joue plus au niveau du maniement du véhicule mais aux niveaux supérieurs de la matrice : contexte des déplacements, motivations, style de vie (pression des tournées, téléphone, fatigue) ; l'animation travaille donc les représentations et les choix, pas la technique. Déroulé : accroche par le vécu, ateliers, synthèse co-construite, engagements individuels. Évaluation reliée aux objectifs : comparaison avant/après des risques identifiés, engagements écrits, et si possible un suivi différé avec l'entreprise. Le jury doit entendre : objectifs mesurables, public respecté, GDE mobilisée à bon escient.$mft$,
   $mft$Barème /5 : objectifs formulés en capacités mesurables (1 pt) ; démarche participative adaptée au public non volontaire, sans exposé descendant ni moralisation (1,5 pt) ; mobilisation pertinente des niveaux supérieurs de la GDE (motivations, style de vie) (1,5 pt) ; évaluation reliée aux objectifs, avec suivi (1 pt). Erreurs fréquentes : « faire prendre conscience » comme objectif (non mesurable) ; dérouler un cours magistral de règles devant des conducteurs chevronnés.$mft$,
   5, 'difficile', ARRAY['ecsr','module-6','question-redigee'], 'ECSR-M6-QR-03', false,
   $mft$Cas CCP2 complet : un public difficile, des objectifs évaluables, la GDE comme boussole.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$À trois semaines de votre session, vous n'avez encore ni filmé de séance ni simulé d'entretien. Construisez votre plan de préparation jusqu'au jour J : priorités semaine par semaine, outils (vidéo, banque de situations, simulations), et votre stratégie pour chaque épreuve de la session.$mft$,
   $mft$Réponse modèle. Semaine 1 : filmer deux séances réelles et les auto-analyser avec une grille en trois questions (objectif annoncé ? guidage décroissant ? bilan factuel ?) ; commencer la banque de situations vécues (une fiche par situation : contexte, actions, résultat, lien référentiel) ; passer l'examen blanc QCM et retravailler les deux modules les plus faibles. Semaine 2 : examen blanc mixte en conditions réelles ; finaliser le dossier professionnel et le faire relire ; première simulation d'entretien technique avec un pair ou un formateur qui questionne à partir du dossier. Semaine 3 : dernière séance filmée pour constater les progrès ; simulation d'entretien final ; relecture quotidienne du tableau des cinq modules et des paires piégeuses ; les deux derniers jours, aucun contenu nouveau, logistique du jour J préparée. Stratégie par épreuve : en mise en situation, annoncer l'objectif, sécuriser, guider en décroissant, conclure par des faits ; en entretien technique, relier chaque choix à un besoin constaté et au référentiel ; en entretien final, s'appuyer sur des situations vécues de la banque plutôt que sur un discours général. Fil rouge : produire et se faire questionner, plutôt que relire.$mft$,
   $mft$Barème /5 : plan séquencé réaliste sur trois semaines avec priorités (1,5 pt) ; usage pertinent des trois outils : vidéo avec grille, banque de situations, simulations d'entretien (1,5 pt) ; stratégie différenciée pour chacune des épreuves de la session (1,5 pt) ; gestion des derniers jours et du jour J (pas de nouveauté, logistique) (0,5 pt). Erreurs fréquentes : réviser la théorie sans jamais se filmer ni se faire questionner ; garder la préparation du dossier et des entretiens pour la dernière semaine.$mft$,
   5, 'difficile', ARRAY['ecsr','module-6','question-redigee'], 'ECSR-M6-QR-04', false,
   $mft$Le plan de préparation actif des trois dernières semaines : filmer, ficher, simuler.$mft$);

  -- ═══════════ EXAMEN BLANC 1 : QCM (20 questions, 30 min) ════════════
  -- Composé de questions EXISTANTES des modules 1 à 5 (4 par module),
  -- liées par source_ref : aucune duplication de contenu.
  INSERT INTO public.quizzes (module_id, title, description, "type", time_limit_s, pass_threshold, is_mock_exam, shuffle_questions)
  VALUES (v_module, 'Examen blanc 1 : QCM des 5 modules',
    'Conditions proches de l''évaluation : 20 QCM couvrant les modules 1 à 5 (4 par module), 30 minutes, seuil 60 %. À faire sans documents.',
    'examen', 1800, 60, true, true)
  RETURNING id INTO v_eb1;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_eb1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN (
    'ECSR-M1-QCM-02','ECSR-M1-QCM-05','ECSR-M1-QCM-08','ECSR-M1-QCM-11',
    'ECSR-M2-QCM-02','ECSR-M2-QCM-05','ECSR-M2-QCM-08','ECSR-M2-QCM-11',
    'ECSR-M3-QCM-02','ECSR-M3-QCM-05','ECSR-M3-QCM-08','ECSR-M3-QCM-11',
    'ECSR-M4-QCM-02','ECSR-M4-QCM-05','ECSR-M4-QCM-08','ECSR-M4-QCM-11',
    'ECSR-M5-QCM-02','ECSR-M5-QCM-05','ECSR-M5-QCM-08','ECSR-M5-QCM-11'
  );
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RAISE NOTICE 'Examen blanc 1 : % questions liées sur 20 attendues (si < 20 : appliquer d''abord les modules 1 à 5).', v_count;

  -- ════ EXAMEN BLANC 2 : Épreuve mixte (10 QCM + 5 QR, 90 min) ════════
  INSERT INTO public.quizzes (module_id, title, description, "type", time_limit_s, pass_threshold, is_mock_exam, shuffle_questions)
  VALUES (v_module, 'Examen blanc 2 : Épreuve mixte (QCM + rédigé)',
    'Simulation du format complet : 10 QCM (2 par module) puis 5 questions rédigées (1 par module), 90 minutes, seuil 60 %. Rédigez réellement vos réponses : la correction s''appuie sur les barèmes.',
    'examen', 5400, 60, true, false)
  RETURNING id INTO v_eb2;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_eb2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN (
    'ECSR-M1-QCM-03','ECSR-M1-QCM-09',
    'ECSR-M2-QCM-03','ECSR-M2-QCM-09',
    'ECSR-M3-QCM-03','ECSR-M3-QCM-09',
    'ECSR-M4-QCM-03','ECSR-M4-QCM-09',
    'ECSR-M5-QCM-03','ECSR-M5-QCM-09',
    'ECSR-M1-QR-03','ECSR-M2-QR-03','ECSR-M3-QR-03',
    'ECSR-M4-QR-03','ECSR-M5-QR-03'
  );
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RAISE NOTICE 'Examen blanc 2 : % questions liées sur 15 attendues (10 QCM + 5 QR).', v_count;

  -- Rattachement des examens blancs au niveau formation
  INSERT INTO public.formation_quizzes (formation_id, quiz_id, is_mock_exam, display_order)
  VALUES (v_formation, v_eb1, true, 60), (v_formation, v_eb2, true, 61);

  RAISE NOTICE 'Module 6 ECSR créé : module %, 1 leçon, 6 QC + 4 QR transversales (inactives, à valider), 2 examens blancs.', v_module;
END $ecsrm6$;

-- =====================================================================
-- CONTRÔLES POST-EXÉCUTION
-- =====================================================================
-- 1) Les 2 examens blancs et leur composition :
--    select q.title, count(qqb.question_id) as nb_questions
--      from quizzes q left join quiz_question_bank qqb on qqb.quiz_id = q.id
--     where q.is_mock_exam and q.module_id in
--           (select id from modules where slug = 'ecsr-preparation-titre')
--     group by q.title;   → 20 et 15.
-- 2) Questions transversales : select "type", active, count(*)
--      from question_bank where source_ref like 'ECSR-M6-%'
--     group by 1, 2;      → qr/false = 10.
-- 3) Module et leçon du lot :
--    select m.slug, count(l.id) as lecons from modules m
--      left join lessons l on l.module_id = m.id
--     where m.slug = 'ecsr-preparation-titre'
--     group by m.slug;    → 1 leçon.
