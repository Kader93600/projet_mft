-- =====================================================================
-- TAXI / VTC : MODULE 9 : PRÉPARATION À L'EXAMEN + 2 EXAMENS BLANCS
-- v1 (juillet 2026) : LOT TAXI-VTC
--
-- ⚠ PRÉREQUIS : appliquer d'abord les modules 1 à 8 de la formation
--   taxi-vtc. Les examens blancs sont composés de questions EXISTANTES
--   de la banque (liaison par source_ref, aucune duplication) : si un
--   module manque, l'examen blanc sera partiel (NOTICE en fin de script).
--
-- Contenu :
--   - Module 9 (1 leçon) : méthode des épreuves CMA, synthèse des
--     points clés des huit modules, paires piégeuses, épreuve pratique
--   - 10 questions transversales de synthèse (6 QC + 4 QR), à valider
--   - Examen blanc 1 : 24 QCM (3 par module), 30 min, seuil 60 %
--   - Examen blanc 2 : épreuve mixte 16 QCM + 8 QR, 90 min, seuil 60 %
--
-- ⚠ STATUT : questions insérées avec active = false (« à valider »).
-- Idempotent : DELETE ciblés par slug/source_ref, rejouable sans doublon.
-- =====================================================================

DO $taxim9$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_l uuid;
  v_eb1 uuid;
  v_eb2 uuid;
  v_count int;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'taxi-vtc';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation taxi-vtc introuvable.'; END IF;

  INSERT INTO public.blocs (id, code, title, description, "order") VALUES (50, 'TAXI-VTC', 'Taxi et VTC : transport public particulier de personnes', 'Préparation aux examens taxi et VTC (T3P) organisés par les chambres de métiers et de l''artisanat : épreuves communes, spécifiques et pratique.', 50) ON CONFLICT DO NOTHING;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'TAXI-VTC';

  DELETE FROM public.question_bank WHERE source_ref LIKE 'TAXI-M9-%';
  DELETE FROM public.modules WHERE slug = 'taxi-vtc-preparation-examen';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 9 : Préparation à l''examen',
    'taxi-vtc-preparation-examen', v_bloc,
    'La méthode des épreuves CMA, la synthèse des points clés des huit modules, des questions transversales et deux examens blancs en conditions.',
    'avance', 180, 90) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 90, true);

  -- ─── Leçon unique : Réussir l'examen T3P ─────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'reussir-examen-t3p',
    'Réussir l''examen T3P : méthode et synthèse finale',
    $mft$> 🎯 **Objectifs**
> - Connaître le déroulement des épreuves et adopter une stratégie de réponse.
> - Réviser en une page les points clés des huit modules de la formation.
> - Dérouler la dernière semaine de préparation et aborder l'épreuve pratique avec méthode.

## L'examen : ce qui vous attend

L'examen d'accès aux professions de conducteur de taxi et de conducteur de VTC est organisé par les **chambres de métiers et de l'artisanat (CMA)**. L'admissibilité repose sur des épreuves écrites : un tronc commun aux deux filières, puis la matière spécifique de votre filière (taxi ou VTC). Les questions prennent la forme de **QCM et de questions à réponse courte** selon les matières : la répartition exacte entre les deux formats et les barèmes par matière sont fixés par les textes d'organisation de la session (à vérifier sur votre convocation et auprès de votre CMA). L'admission se joue ensuite sur l'**épreuve pratique** : une mise en situation de course réelle, du premier contact avec le client jusqu'au paiement.

## La stratégie de l'écrit

- **Lire chaque énoncé deux fois** : repérez les négations (« lequel n'est PAS autorisé »), les mots absolus (« toujours », « jamais », souvent faux) et les termes précis (qui DÉLIVRE, qui ORGANISE, qui CONTRÔLE : trois verbes, trois réponses différentes).
- **Répondre en trois passes** : d'abord les certitudes, rapidement ; puis les hésitations, en éliminant les distracteurs impossibles ; enfin les inconnues, sans jamais rester bloqué sur une question.
- **Surveiller le temps** : une question laissée en suspens se marque et se retrouve ; une question ruminée cinq minutes coûte trois autres questions.
- **Se méfier des ressemblances** : l'examen adore placer côte à côte deux notions voisines (autorisation du véhicule et carte du conducteur, maraude et réservation). C'est précisément l'objet du tableau ci-dessous.

## La synthèse des huit modules

| Module | Les points à savoir sans hésiter |
| --- | --- |
| M1 : Cadre du T3P et carte professionnelle | Permis B depuis au moins 3 ans ; carte professionnelle délivrée par le préfet ; examen organisé par la CMA |
| M2 : Taxi et VTC, deux régimes | Maraude et stationnement en attente de clientèle réservés au taxi ; VTC : réservation préalable uniquement ; nouvelles ADS : 5 ans, incessibles ; inscription au registre des VTC (REVTC) : 5 ans |
| M3 : Gestion de l'activité | Choix du statut, calcul du prix de revient d'une course, assurance RC professionnelle spécifique au transport de personnes à titre onéreux |
| M4 : Sécurité routière | Seuils d'alcoolémie 0,5 et 0,8 g/L ; ouverture de portière « à la hollandaise » (main opposée) ; dispositifs de retenue adaptés pour les enfants |
| M5 : Anglais professionnel | Les phrases clés de la prise en charge : accueil, destination, durée, prix, paiement |
| M6 : Connaissance du territoire | Grands axes, dessertes des aéroports et des gares, choix d'itinéraire justifiable |
| M7 : Spécifique taxi | Taximètre et positions tarifaires A, B, C, D ; suppléments affichés ; conventionnement CPAM pour le transport assis de patients |
| M8 : Spécifique VTC | Retour à la base entre deux courses, sauf réservation suivante ; justificatif de réservation présentable en cas de contrôle |

> 📌 **Les paires piégeuses à ne plus confondre**
> - **ADS et carte professionnelle** : l'autorisation de stationnement (ADS) concerne le véhicule et relève du maire de la commune de rattachement ; la carte professionnelle concerne le conducteur et relève du préfet.
> - **Maraude et maraude électronique** : chercher le client sur la voie publique, physiquement ou en affichant en temps réel sa position et sa disponibilité immédiate, relève du régime du taxi ; le VTC travaille sur réservation préalable, y compris quand elle passe par une application.
> - **Prix réglementé et prix libre** : le taxi applique la grille de l'arrêté préfectoral via le taximètre (positions A à D, suppléments affichés) ; le VTC convient librement de son prix avec le client au moment de la réservation.

> ⚠️ **Attention**
> Ne révisez jamais un chiffre isolé : révisez la paire qui l'accompagne. À l'examen, le distracteur le plus choisi est presque toujours le « jumeau » de la bonne réponse (l'autre autorité, l'autre régime, l'autre durée).

## La dernière semaine

:::timeline
1. **J-7 et J-6** : Examen blanc 1 (QCM) en conditions réelles, puis correction et retour ciblé sur les deux modules les plus faibles.
2. **J-5 et J-4** : Examen blanc 2 (épreuve mixte) chronométré ; refaire PAR ÉCRIT les questions rédigées ratées, barème sous les yeux.
3. **J-3 et J-2** : relecture du tableau des huit modules et des paires piégeuses, une série de questions courtes par jour, aucun contenu nouveau.
4. **J-1** : logistique du jour J (convocation, pièce d'identité, trajet repéré, matériel), révision légère, coucher tôt.
5. **Jour J** : arriver en avance ; écrit en trois passes ; garder cinq minutes de relecture ; pratique : dérouler le rituel travaillé, sans improviser.
:::

## L'épreuve pratique : les gestes qui font la note

- **L'accueil** : tenue soignée, salutation, aide aux bagages, installation du client, vérification de la destination. Les trente premières secondes installent la note.
- **L'itinéraire commenté** : annoncez l'itinéraire envisagé et justifiez-le (axes principaux, conditions de circulation, demande du client). Un détour subi se pardonne ; un itinéraire injustifiable, non.
- **La conduite souple** : anticipation, allure régulière, respect strict du code : l'examinateur évalue le confort et la sécurité du passager, pas la vitesse du trajet.
- **La fin de course** : annonce claire du prix, encaissement, remise de la note ou du justificatif, prise de congé courtoise.

> 💡 **Astuce**
> Répétez l'épreuve pratique comme un rituel en quatre temps (accueil, itinéraire annoncé, conduite, fin de course) avec un proche en passager : le déroulé automatisé libère l'attention pour la circulation et pour le client.

## ✅ Synthèse

- Écrit CMA : **QCM et questions à réponse courte selon les matières** (modalités précises : voir convocation) ; trois passes, chasse aux négations et aux jumeaux.
- Un seul support final : **le tableau des huit modules** et les paires piégeuses (ADS/carte, maraude/réservation, prix réglementé/prix libre).
- Dernière semaine : **examens blancs d'abord**, consolidation ensuite, rien de nouveau après J-3.
- Pratique : **accueil, itinéraire commenté, conduite souple, fin de course** : un rituel répété, pas une improvisation.$mft$,
    $mft$La méthode des épreuves écrites CMA (trois passes, pièges de lecture), le tableau de synthèse des huit modules, les paires piégeuses (ADS/carte, maraude/réservation, prix réglementé/libre), le planning de la dernière semaine et le rituel de l'épreuve pratique.$mft$,
    1, 45) RETURNING id INTO v_l;

  -- ─── Questions transversales de synthèse (6 QC + 4 QR) ─────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l, 'qr',
   $mft$Un candidat confond les autorités : qui délivre l'autorisation de stationnement (ADS) d'un taxi, et qui délivre la carte professionnelle du conducteur ?$mft$,
   $mft$L'ADS est délivrée par le maire de la commune de rattachement ; la carte professionnelle est délivrée par le préfet, après réussite à l'examen organisé par la CMA.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-9','question-courte','transversal'], 'TAXI-M9-QC-01', false,
   $mft$Paire piégeuse classique : le véhicule relève de la commune, le conducteur relève du préfet.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Un conducteur VTC stationne devant une gare et propose ses services aux voyageurs qui sortent, sans réservation. Qu'est-ce qui lui est reproché, et que devrait-il pouvoir présenter pour une prise en charge régulière ?$mft$,
   $mft$Il pratique la maraude, réservée aux taxis : le VTC ne peut prendre en charge un client que sur réservation préalable, et doit pouvoir présenter un justificatif de cette réservation en cas de contrôle.$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-9','question-courte','transversal'], 'TAXI-M9-QC-02', false,
   $mft$Maraude = monopole du taxi ; VTC = réservation préalable prouvable.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Deux durées de cinq ans encadrent l'accès au marché du T3P : l'une côté taxi, l'autre côté VTC. Lesquelles, avec leur caractéristique principale ?$mft$,
   $mft$Les nouvelles ADS sont délivrées pour cinq ans et sont incessibles (renouvelables, mais non revendables) ; l'inscription au registre des VTC (REVTC) est valable cinq ans et doit être renouvelée.$mft$,
   2, 'difficile', ARRAY['taxi-vtc','module-9','question-courte','transversal'], 'TAXI-M9-QC-03', false,
   $mft$Même durée, deux objets : l'autorisation communale du taxi et l'inscription au registre du VTC.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Un client exige un prix ferme avant le départ. Comparez ce que peuvent lui répondre un taxi pour une course au compteur et un VTC.$mft$,
   $mft$Le prix du taxi est réglementé : il résulte du taximètre selon la grille de l'arrêté préfectoral (positions A à D et suppléments affichés), le conducteur ne le fixe pas librement ; le VTC fixe librement son prix, convenu avec le client au moment de la réservation, souvent sous forme de forfait.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-9','question-courte','transversal'], 'TAXI-M9-QC-04', false,
   $mft$Prix réglementé (taxi au compteur) contre prix libre convenu à la réservation (VTC).$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Un patient présente une prescription médicale de transport et souhaite que sa course soit prise en charge par l'assurance maladie. À quelle condition le taxi peut-il facturer cette course à la CPAM ?$mft$,
   $mft$Le taxi doit être conventionné : avoir signé la convention avec la CPAM, qui permet la facturation du transport assis de patients effectué sur prescription médicale.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-9','question-courte','transversal'], 'TAXI-M9-QC-05', false,
   $mft$Sans conventionnement, pas de facturation à l'assurance maladie : c'est un choix d'activité structurant du module 7.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Un conducteur VTC vient de déposer un client en centre-ville et n'a pas de course suivante. Que doit-il faire de son véhicule, et quelle est l'exception ?$mft$,
   $mft$Il doit retourner à sa base d'exploitation entre deux courses, sauf s'il peut justifier d'une réservation préalable suivante (justificatif présentable en cas de contrôle).$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-9','question-courte','transversal'], 'TAXI-M9-QC-06', false,
   $mft$Le retour à la base empêche la fausse maraude : seule une réservation suivante justifie de rester en circulation.$mft$);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l, 'qr',
   $mft$Cas de synthèse. Nadia hésite entre s'installer comme artisan taxi dans sa ville (une nouvelle ADS vient d'être publiée) et créer une activité VTC. Comparez les deux options : accès au marché, prérogatives commerciales, formation du prix, obligations d'exploitation ; puis bâtissez une recommandation argumentée pour son profil (clientèle locale d'habitués en journée, peu d'attrait pour les plateformes).$mft$,
   $mft$Réponse modèle. Accès au marché : dans les deux cas, carte professionnelle délivrée par le préfet après l'examen CMA ; côté taxi, l'ADS est délivrée par le maire, et une nouvelle ADS vaut cinq ans et reste incessible (renouvelable, mais sans valeur de revente) ; côté VTC, inscription au REVTC valable cinq ans, à renouveler. Prérogatives : le taxi dispose de la maraude et du stationnement en attente de clientèle, et peut se conventionner avec la CPAM pour le transport assis de patients ; le VTC ne travaille que sur réservation préalable, avec justificatif à bord et retour à la base entre deux courses. Prix : réglementé pour le taxi (taximètre, positions A à D, suppléments affichés) ; libre pour le VTC, convenu à la réservation. Gestion commune : prix de revient à calculer et assurance RC professionnelle du transport à titre onéreux (module 3). Recommandation : pour une clientèle locale d'habitués en journée, sans appétence pour les plateformes, le taxi s'impose : la maraude, la station et le conventionnement CPAM sécurisent un flux régulier sans dépendre des applications ; en contrepartie, Nadia accepte un tarif réglementé et une ADS incessible qui ne constituera pas un patrimoine revendable.$mft$,
   $mft$Barème /5 : accès au marché exact des deux côtés (ADS nouvelle 5 ans incessible, REVTC 5 ans, carte préfet commune) (1,5 pt) ; prérogatives et obligations bien opposées (maraude et CPAM contre réservation, justificatif, retour base) (1,5 pt) ; formation du prix correcte (réglementé contre libre) (1 pt) ; recommandation cohérente avec le profil, avantages ET contreparties (1 pt). Erreurs fréquentes : croire la nouvelle ADS revendable ; attribuer la carte professionnelle à la mairie ; recommander sans contrepartie.$mft$,
   5, 'difficile', ARRAY['taxi-vtc','module-9','question-redigee','transversal'], 'TAXI-M9-QR-01', false,
   $mft$Comparaison d'installation taxi/VTC, transversale M1, M2, M3, M7 et M8 : le grand classique de la synthèse.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Cas pratique. Lors d'un contrôle devant une gare, un conducteur VTC : attendait le client « au cas où », sans réservation ; n'a pas pu présenter de justificatif pour sa course précédente ; et enchaîne les stationnements devant la gare entre deux courses au lieu de regagner sa base. Analysez chaque manquement (règle en cause, ce qu'il révèle), les risques encourus, puis proposez une organisation de travail conforme et efficace.$mft$,
   $mft$Réponse modèle. Manquement 1 : l'attente de clientèle sur la voie publique sans réservation est de la maraude, prérogative exclusive du taxi : c'est le grief le plus grave, il capte une clientèle qui ne lui est pas ouverte. Manquement 2 : l'absence de justificatif de réservation prive le conducteur de toute preuve de régularité : la réservation préalable doit pouvoir être démontrée en contrôle, sur support papier ou électronique ; sans preuve, la course est présumée irrégulière. Manquement 3 : le stationnement prolongé entre deux courses contourne l'obligation de retour à la base, qui n'admet qu'une exception : une réservation suivante justifiée. L'accumulation révèle un modèle d'activité construit sur le flux de la gare, c'est-à-dire sur le terrain commercial du taxi. Risques : sanctions lors du contrôle, mise en cause de l'activité, image dégradée auprès des clients et des donneurs d'ordres. Organisation conforme : bâtir un carnet de réservations (clients directs, partenariats avec hôtels et entreprises, plateformes), conserver systématiquement chaque justificatif, planifier les retours base entre les créneaux, et si le flux gare reste stratégique, le capter par la réservation (offres aux voyageurs réguliers) plutôt que par l'attente en voirie.$mft$,
   $mft$Barème /5 : trois manquements correctement qualifiés avec la règle en cause (1,5 pt) ; hiérarchisation avec la maraude en tête (0,5 pt) ; risques identifiés (1 pt) ; organisation conforme concrète fondée sur la réservation et les justificatifs (1,5 pt) ; lecture d'ensemble (modèle d'activité à corriger, pas trois hasards) (0,5 pt). Erreurs fréquentes : croire que la disponibilité affichée sur une application autorise l'attente en voirie ; traiter les trois griefs comme indépendants.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-9','question-redigee','transversal'], 'TAXI-M9-QR-02', false,
   $mft$Contrôle VTC en gare, transversale M2 et M8 : qualification, risques, remédiation.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Cas de gestion. Karim, artisan taxi conventionné avec la CPAM, trouve ses fins de mois trop justes malgré des journées pleines. Construisez sa démarche d'analyse : postes du prix de revient à recenser, indicateurs à suivre, examen de son mix d'activité (station, maraude, courses conventionnées, réservations), puis trois leviers d'action hiérarchisés.$mft$,
   $mft$Réponse modèle. Étape 1, le prix de revient : recenser les charges fixes (financement et amortissement du véhicule, assurance RC professionnelle du transport à titre onéreux, entretien, cotisations, taximètre et équipements) et les charges variables (carburant, lavage, usure), puis les rapporter au kilomètre et à l'heure travaillée : sans ce coût complet, aucune décision n'est fiable. Étape 2, les indicateurs : recette moyenne par course, kilomètres à vide, heures réellement facturées sur heures travaillées, répartition de la recette par type d'activité. Étape 3, le mix : les courses conventionnées CPAM apportent un volume régulier et prévisible mais à tarification encadrée par la convention ; la station et la maraude sont plus variables ; les réservations d'habitués fidélisent. L'analyse consiste à comparer la marge horaire de chaque segment, kilomètres à vide inclus (une course conventionnée lointaine avec retour à vide peut coûter plus qu'elle ne rapporte). Leviers hiérarchisés : 1) réduire les kilomètres à vide (regrouper les courses conventionnées par secteur, caler les retours sur des réservations) ; 2) rééquilibrer le mix vers les segments à meilleure marge horaire mesurée ; 3) passer en revue les charges fixes (assurance, financement) à échéance. Décider sur des chiffres, pas sur l'impression de journées pleines.$mft$,
   $mft$Barème /5 : prix de revient complet distinguant charges fixes et variables, rapporté au km et à l'heure (1,5 pt) ; indicateurs pertinents dont les kilomètres à vide (1 pt) ; analyse du mix avec la spécificité des courses conventionnées (volume régulier, tarification encadrée) (1,5 pt) ; trois leviers hiérarchisés et cohérents avec l'analyse (1 pt). Erreurs fréquentes : raisonner sur la seule recette sans les coûts ; conclure sans avoir mesuré la marge par segment.$mft$,
   5, 'difficile', ARRAY['taxi-vtc','module-9','question-redigee','transversal'], 'TAXI-M9-QR-03', false,
   $mft$Rentabilité d'un taxi conventionné, transversale M3 et M7 : la méthode avant les recettes toutes faites.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Méthode. À sept jours de l'examen, un candidat n'a encore fait aucun examen blanc et redoute l'épreuve pratique. Construisez son plan des sept derniers jours (contenus, ordre, volumes), puis le déroulé type d'une épreuve pratique réussie, de la prise en charge au paiement, en signalant les erreurs qui coûtent le plus de points.$mft$,
   $mft$Réponse modèle. Plan des sept jours : J-7 et J-6, examen blanc 1 (QCM) en conditions réelles puis correction ciblée sur les deux modules les plus faibles ; J-5 et J-4, examen blanc 2 (épreuve mixte) chronométré, puis refaire par écrit les questions rédigées ratées avec le barème sous les yeux ; J-3 et J-2, consolidation : tableau des huit modules, paires piégeuses (ADS et carte, maraude et réservation, prix réglementé et prix libre), une série de questions courtes par jour, aucun contenu nouveau ; J-1, logistique (convocation, pièce d'identité, trajet repéré) et repos ; chaque jour, quinze minutes de répétition du rituel pratique avec un proche en passager. Déroulé de l'épreuve pratique : accueil (tenue, salutation, bagages, installation, vérification de la destination) ; itinéraire annoncé et justifié (axes principaux, circulation, souhait du client) ; conduite souple et strictement réglementaire, centrée sur le confort et la sécurité du passager ; fin de course : annonce du prix, encaissement, remise de la note ou du justificatif, prise de congé. Erreurs les plus coûteuses : itinéraire subi et injustifiable, conduite brusque ou infraction, accueil négligé, et réciter ses connaissances au lieu de conduire pour le client.$mft$,
   $mft$Barème /5 : plan des sept jours réaliste avec les examens blancs placés en début de semaine (1,5 pt) ; consolidation sans contenu nouveau après J-3 (0,5 pt) ; déroulé pratique complet, de l'accueil à la prise de congé (2 pt) ; erreurs coûteuses pertinentes (1 pt). Erreurs fréquentes : garder l'examen blanc pour la veille ; réduire l'épreuve pratique à la seule conduite.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-9','question-redigee','transversal'], 'TAXI-M9-QR-04', false,
   $mft$Plan de dernière semaine et rituel de l'épreuve pratique : la méthode du module appliquée à soi-même.$mft$);

  -- ═══════════════ EXAMEN BLANC 1 : QCM (24 questions, 30 min) ════════
  -- Composé de questions EXISTANTES des modules 1 à 8 (3 par module),
  -- liées par source_ref : aucune duplication de contenu.
  INSERT INTO public.quizzes (module_id, title, description, "type", time_limit_s, pass_threshold, is_mock_exam, shuffle_questions)
  VALUES (v_module, 'Examen blanc 1 : QCM des 8 modules',
    'Conditions proches de l''épreuve : 24 QCM couvrant les modules 1 à 8 (3 par module), 30 minutes, seuil 60 %. À faire sans documents.',
    'examen', 1800, 60, true, true)
  RETURNING id INTO v_eb1;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_eb1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN (
    'TAXI-M1-QCM-02','TAXI-M1-QCM-05','TAXI-M1-QCM-08',
    'TAXI-M2-QCM-02','TAXI-M2-QCM-05','TAXI-M2-QCM-08',
    'TAXI-M3-QCM-02','TAXI-M3-QCM-05','TAXI-M3-QCM-08',
    'TAXI-M4-QCM-02','TAXI-M4-QCM-05','TAXI-M4-QCM-08',
    'TAXI-M5-QCM-02','TAXI-M5-QCM-05','TAXI-M5-QCM-08',
    'TAXI-M6-QCM-02','TAXI-M6-QCM-05','TAXI-M6-QCM-08',
    'TAXI-M7-QCM-02','TAXI-M7-QCM-05','TAXI-M7-QCM-08',
    'TAXI-M8-QCM-02','TAXI-M8-QCM-05','TAXI-M8-QCM-08'
  );
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RAISE NOTICE 'Examen blanc 1 : % questions liées sur 24 attendues (si < 24 : appliquer les modules 1 à 8).', v_count;

  -- ══════ EXAMEN BLANC 2 : Épreuve mixte (16 QCM + 8 QR, 90 min) ══════
  INSERT INTO public.quizzes (module_id, title, description, "type", time_limit_s, pass_threshold, is_mock_exam, shuffle_questions)
  VALUES (v_module, 'Examen blanc 2 : épreuve mixte (QCM + rédigé)',
    'Simulation complète : 16 QCM (2 par module) puis 8 questions rédigées (1 par module), 90 minutes, seuil 60 %. Rédigez réellement vos réponses : la correction s''appuie sur les barèmes.',
    'examen', 5400, 60, true, false)
  RETURNING id INTO v_eb2;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_eb2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN (
    'TAXI-M1-QCM-03','TAXI-M1-QCM-11',
    'TAXI-M2-QCM-03','TAXI-M2-QCM-11',
    'TAXI-M3-QCM-03','TAXI-M3-QCM-11',
    'TAXI-M4-QCM-03','TAXI-M4-QCM-11',
    'TAXI-M5-QCM-03','TAXI-M5-QCM-11',
    'TAXI-M6-QCM-03','TAXI-M6-QCM-11',
    'TAXI-M7-QCM-03','TAXI-M7-QCM-11',
    'TAXI-M8-QCM-03','TAXI-M8-QCM-11',
    'TAXI-M1-QR-03','TAXI-M2-QR-03','TAXI-M3-QR-03','TAXI-M4-QR-03',
    'TAXI-M5-QR-03','TAXI-M6-QR-03','TAXI-M7-QR-03','TAXI-M8-QR-03'
  );
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RAISE NOTICE 'Examen blanc 2 : % questions liées sur 24 attendues (16 QCM + 8 QR).', v_count;

  -- Rattachement des examens blancs au niveau formation
  INSERT INTO public.formation_quizzes (formation_id, quiz_id, is_mock_exam, display_order)
  VALUES (v_formation, v_eb1, true, 90), (v_formation, v_eb2, true, 91);

  RAISE NOTICE 'Module 9 taxi/VTC créé : module %, 1 leçon, 6 QC + 4 QR transversales (inactives, à valider), 2 examens blancs.', v_module;
END $taxim9$;

-- =====================================================================
-- CONTRÔLES POST-EXÉCUTION
-- =====================================================================
-- 1) Les 2 examens blancs et leur composition :
--    select q.title, count(qqb.question_id) as nb_questions
--      from quizzes q left join quiz_question_bank qqb on qqb.quiz_id = q.id
--     where q.is_mock_exam and q.module_id in
--           (select id from modules where slug = 'taxi-vtc-preparation-examen')
--     group by q.title;   → 24 et 24.
-- 2) Questions transversales : select "type", active, count(*)
--      from question_bank where source_ref like 'TAXI-M9-%'
--     group by 1, 2;      → qr/false = 10.
-- 3) Module et leçon du lot :
--    select m.slug, count(l.id) as lecons from modules m
--      left join lessons l on l.module_id = m.id
--     where m.slug = 'taxi-vtc-preparation-examen'
--     group by m.slug;    → 1 leçon.
