-- =====================================================================
-- FIMO / FCO MARCHANDISES : MODULE 5 : PRÉPARATION À L'ÉVALUATION
-- + 2 EXAMENS BLANCS : v1 (juillet 2026) : LOT FIMO-6 (FINAL)
--
-- ⚠ PRÉREQUIS : appliquer d'abord les lots FIMO-1 à FIMO-5 (M0, T1-T4) :
--   les examens blancs lient des questions EXISTANTES par source_ref.
-- ⚠ STATUT : questions active = false (« à valider »). Idempotent.
-- =====================================================================

DO $fimom5$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_l1 uuid;
  v_eb1 uuid; v_eb2 uuid;
  v_count int;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'fimo-fco';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation fimo-fco introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'FIMO-FCO';

  DELETE FROM public.question_bank WHERE source_ref LIKE 'FIMO-M5-%';
  DELETE FROM public.modules WHERE slug = 'fimo-m5-evaluation';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 5 : Préparation à l''évaluation',
    'fimo-m5-evaluation', v_bloc,
    'La méthode pour réussir l''évaluation finale, la synthèse des chiffres clés du conducteur, des questions transversales de synthèse et deux évaluations blanches en conditions.',
    'avance', 180, 60) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 60, true);

  -- ─── Leçon unique : Réussir l'évaluation + chiffres clés ───────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'reussir-evaluation-chiffres-cles',
    'Réussir l''évaluation : méthode et chiffres clés',
    $mft$> 🎯 **Objectifs**
> - Aborder l'évaluation finale avec la bonne méthode.
> - Réviser en une page les chiffres incontournables du conducteur.

## L'évaluation finale : à quoi s'attendre

La FIMO se conclut par une **évaluation des connaissances** (questionnaire couvrant les quatre thèmes) et des mises en situation pratiques ; les modalités précises (nombre de questions, seuils) sont communiquées par votre centre : la méthode, elle, ne change pas.

**Méthode questionnaire** : lire chaque énoncé deux fois (les négations et les « toujours/jamais » piègent), répondre d'abord aux certitudes, éliminer les réponses impossibles sur les hésitations, ne rien laisser sans réponse, garder cinq minutes de relecture. **Méthode pratique** : verbaliser vos contrôles (« je vérifie mes trois points d'appui, mon rétro d'accostage… ») : l'évaluateur note ce qu'il voit ET ce qu'il entend.

## Les chiffres clés du conducteur

| Domaine | À connaître par cœur |
| --- | --- |
| Qualification | FIMO **140 h** ; FCO **35 h / 5 ans** ; passerelle **35 h** ; carte **5 ans** ; conduite dès **18 ans** avec qualification |
| Conduite | **4 h 30** → pause **45 min (15 + 30)** ; **9 h**/jour (2 × **10 h**/sem) ; **56 h**/sem ; **90 h**/2 sem |
| Repos | Journalier **11 h** (réduit **9 h** × 3 ; fractionné **3 + 9**) ; hebdo **45 h** (réduit ≥ **24 h**) ; nouveau repos hebdo après **6 × 24 h** ; jamais le 45 h en cabine |
| Tachygraphe | Carte perso **5 ans** ; justifier **28 jours** en contrôle ; heure en **UTC** |
| Véhicule | CT **annuel** ; limiteur **90 km/h** ; vitesses **90/80/50** ; interdiction > 7,5 t **sam 22 h → dim 22 h** ; interdistance **50 m** |
| Chargement | Poussée avant ≈ **0,8 × poids** (latéral 0,5) ; CU = PTAC/PTRA − PV ; sangle nouée = HS |
| Santé | Alcool : contravention **0,5 g/L**, délit **0,8** ; élimination ~**0,10-0,15 g/L/h** ; stupéfiants : **tolérance zéro** ; médicaments niveaux **2/3** ; sieste flash **15-20 min** |
| Accident | **Protéger, Alerter (112), Secourir** ; AT : salarié **24 h** → employeur **48 h** ; téléphone tenu : **135 € + 3 points** |

> 📌 **À retenir**
> Les paires piégeuses du questionnaire : **15 + 30** (jamais 30 + 15) : **9 h / 10 h × 2** : **56 / 90 h** (conduite) à ne pas confondre avec **48 / 60 h** (travail) : **28 jours** (contrôle tachy) vs **30 jours** (délais commerciaux, hors de votre copie) : **0,5 / 0,8 g/L**.

## Vos deux évaluations blanches

L'**évaluation blanche 1** (questionnaire, 20 questions, 30 minutes) balaie les cinq modules : faites-la en conditions (sans notes), analysez chaque erreur avec la leçon concernée. L'**évaluation blanche 2** (mixte : questionnaire + questions à réponse construite, 90 minutes) travaille aussi la rédaction : répondez par écrit, structurez (règle → application), comparez au barème. Deux passages « à blanc » bien exploités valent une semaine de relecture passive.

## ✅ Synthèse

- Questionnaire : **deux lectures, certitudes d'abord, zéro case vide** ; pratique : **verbaliser** ses contrôles.
- Le tableau ci-dessus = votre fiche de révision finale ; travaillez les **paires piégeuses**.
- Deux évaluations blanches en conditions, erreurs analysées leçon par leçon.$mft$,
    $mft$Méthode du questionnaire et des mises en situation, tableau complet des chiffres clés du conducteur (qualification, conduite, repos, tachy, véhicule, santé) et mode d'emploi des deux évaluations blanches.$mft$,
    1, 40) RETURNING id INTO v_l1;

  -- ─── Questions transversales (6 QC + 4 QR) ─────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Restituez la « colonne vertébrale » d'une journée de conduite : conduite maximale continue, pause, plafond journalier et repos.$mft$,
   $mft$4 h 30 de conduite maximum, pause de 45 minutes (15 + 30), 9 heures de conduite par jour (10 h deux fois par semaine), repos journalier de 11 heures achevé dans la fenêtre de 24 h.$mft$,
   2, 'facile', ARRAY['fimo-fco','module-5','question-courte','transversal'], 'FIMO-M5-QC-01', false,
   $mft$Les quatre maillons enchaînés.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Deux « 45 » traversent votre métier : lesquels ?$mft$,
   $mft$La pause de 45 minutes après 4 h 30 de conduite, et le repos hebdomadaire normal de 45 heures (jamais pris en cabine).$mft$,
   2, 'moyen', ARRAY['fimo-fco','module-5','question-courte','transversal'], 'FIMO-M5-QC-02', false,
   $mft$Minutes d'un côté, heures de l'autre.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Trois validités de 5 ans encadrent votre activité : lesquelles ?$mft$,
   $mft$La carte de qualification (renouvelée par la FCO), la carte de conducteur du chronotachygraphe, et le permis du groupe lourd avant 60 ans (visite médicale).$mft$,
   2, 'moyen', ARRAY['fimo-fco','module-5','question-courte','transversal'], 'FIMO-M5-QC-03', false,
   $mft$Trois échéances distinctes qui ne tombent jamais ensemble.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Associez chaque seuil d'alcoolémie à sa qualification : 0,5 g/L et 0,8 g/L.$mft$,
   $mft$0,5 g/L : contravention (6 points) ; 0,8 g/L : délit (tribunal, suspension/annulation possibles).$mft$,
   2, 'facile', ARRAY['fimo-fco','module-5','question-courte','transversal'], 'FIMO-M5-QC-04', false,
   $mft$Et tolérance zéro pour les stupéfiants.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Quels sont les deux réflexes documentaires qui encadrent chaque transport, de l'enlèvement à la livraison ?$mft$,
   $mft$Les réserves écrites précises à l'enlèvement en cas d'anomalie, et l'émargement complet du destinataire (avec ses éventuelles réserves) à la livraison.$mft$,
   2, 'moyen', ARRAY['fimo-fco','module-5','question-courte','transversal'], 'FIMO-M5-QC-05', false,
   $mft$La lettre de voiture aux deux bouts.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Citez, dans l'ordre, les trois mots de la réaction à un accident corporel et les deux délais de la déclaration d'accident du travail.$mft$,
   $mft$Protéger, Alerter, Secourir ; salarié → employeur sous 24 h, employeur → CPAM sous 48 h.$mft$,
   2, 'difficile', ARRAY['fimo-fco','module-5','question-courte','transversal'], 'FIMO-M5-QC-06', false,
   $mft$PAS + 24/48.$mft$);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Cas de synthèse. Journée noire : réveil en retard après une soirée arrosée, départ précipité sans tour du véhicule, pause sautée « pour rattraper », téléphone en main au volant, livraison déposée sans émargement « pour finir plus tôt ». Reprenez chaque décision : le risque créé, la règle enfreinte, la bonne décision.$mft$,
   $mft$Réponse modèle. 1) Conduire au petit matin après une soirée arrosée : alcoolémie résiduelle probable (élimination ~0,10-0,15 g/L/h) : contravention voire délit, vigilance dégradée : la bonne décision se prenait la veille (modération) ; au matin : retarder la prise de service et prévenir, plutôt que rouler « au jugé ». 2) Départ sans tour du véhicule : pneu, feux, arrimage non vérifiés : le conducteur est le dernier contrôle : cinq minutes de walk-around, non négociables. 3) Pause sautée : infraction enregistrée par le tachygraphe ET fatigue accrue : la pause de 45 min après 4 h 30 se planifie, le retard se gère par l'alerte à l'exploitation. 4) Téléphone tenu en main : 135 € + 3 points et attention détruite : messages à l'arrêt uniquement. 5) Dépôt sans émargement : marchandise juridiquement non livrée : litige quasi garanti : appel à l'exploitation, jamais de dépôt sauvage. Mécanique d'ensemble : chaque « gain de temps » a créé un risque supérieur au temps gagné ; la journée noire se corrige en amont (sommeil, marges) et par un réflexe unique : quand ça dérape, on ALERTE au lieu d'improviser.$mft$,
   $mft$Barème /5 : les cinq décisions traitées avec risque + règle + alternative (4 pts : 0,8 chacune) ; mécanique d'ensemble (alerte vs improvisation) (1 pt). Erreurs fréquentes : moraliser sans citer les règles précises ; oublier l'alcool résiduel du matin.$mft$,
   5, 'moyen', ARRAY['fimo-fco','module-5','question-redigee','transversal'], 'FIMO-M5-QR-01', false,
   $mft$La journée noire : cinq erreurs en chaîne, cinq corrections.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Cas de synthèse. Tournée réelle : départ 6 h, 3 h 50 de conduite, chargement 45 min chez un client (vous chargez au hayon), 40 min de conduite, pause déjeuner 45 min, puis 4 h 20 de conduite pour livrer à 17 h 30 un destinataire qui compte avec vous et signe. Vérifiez la conformité complète de la journée (conduite, pauses, sélecteur, repos possible le soir) et citez les gestes documentaires réalisés.$mft$,
   $mft$Réponse modèle. Conduite continue : 3 h 50 puis 40 min = 4 h 30 pile au moment de la pause déjeuner : conforme À CONDITION que la pause de 45 min intervienne dès 4 h 30 atteintes : c'est le cas (déjeuner 45 min) ; le chargement de 45 min N'est PAS une pause (travail au hayon : sélecteur « autres travaux ») : il n'interrompt pas le compteur de conduite : vigilance : après le déjeuner, nouveau cycle : 4 h 20 de conduite < 4 h 30 : conforme. Total conduite : 3 h 50 + 0 h 40 + 4 h 20 = 8 h 50 ≤ 9 h : conforme sans extension. Sélecteur : conduite (auto), « autres travaux » au chargement, « repos » au déjeuner : la journée raconte la vérité. Amplitude : 6 h → 17 h 30 + fin de service : repos journalier de 11 h possible dès ~18 h, achevé vers 5 h : dans la fenêtre de 24 h ouverte à 6 h : conforme (et permet une prise de service à 5 h le lendemain, ou 6 h avec marge). Gestes documentaires : tour du véhicule au départ, LV vérifiée à l'enlèvement (réserves si besoin), comptage contradictoire à la livraison, émargement complet (nom, date, heure), tachy : pays début/fin. Conclusion : journée dense mais parfaitement conforme : la conformité est une affaire de construction, pas de chance.$mft$,
   $mft$Barème /5 : cycle de conduite correctement décompté avec le chargement classé travail (2 pts) ; total 8 h 50 vérifié (0,75 pt) ; sélecteur juste aux trois moments (0,75 pt) ; repos calé dans la fenêtre (0,75 pt) ; gestes documentaires (0,75 pt). Erreurs fréquentes : compter le chargement comme pause ; rater le « 4 h 30 pile ».$mft$,
   5, 'moyen', ARRAY['fimo-fco','module-5','question-redigee','transversal'], 'FIMO-M5-QR-02', false,
   $mft$Journée complète auditée minute par minute. Calculs vérifiés.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Vous parrainez un nouveau conducteur qui débute lundi. Rédigez votre « brief du premier jour » en cinq priorités absolues, en justifiant chacune par ce qu'elle évite.$mft$,
   $mft$Réponse modèle (cinq priorités types). 1) « Tes trois cartes et leurs dates » (permis/CQC/carte tachy) : évite l'infraction immédiate et l'immobilisation : on vérifie ensemble les échéances ce matin. 2) « Ton tour du véhicule, chaque prise de poste » (pneus, feux, attelage, arrimage, documents) : évite la panne évitable, l'accident mécanique et l'amende bête : cinq minutes qui sauvent des journées. 3) « Ta pause avant l'heure, jamais après » (4 h 30 → 45 min, alarme personnelle à 4 h) : évite l'infraction enregistrée ET la fatigue : le tachy n'oublie rien. 4) « Trois points d'appui, jamais de saut, jamais le téléphone en descendant » : évite l'accident du travail le plus fréquent du métier dès la première semaine. 5) « Quand ça coince : tu documentes et tu appelles l'exploitation » (retard, surcharge suspectée, client difficile, incident) : évite les décisions solitaires qui transforment un problème en faute : ici, on n'improvise pas, on alerte. Bonus de parrain : montrer, pas seulement dire : le premier tour du véhicule et la première LV se font à deux.$mft$,
   $mft$Barème /5 : cinq priorités pertinentes et hiérarchisées (2,5 pts) ; justification « ce que ça évite » pour chacune (2 pts) ; posture de parrainage (montrer, faire ensemble) (0,5 pt). Erreurs fréquentes : liste de règles sans justification ; oublier le réflexe d'alerte.$mft$,
   5, 'difficile', ARRAY['fimo-fco','module-5','question-redigee','transversal'], 'FIMO-M5-QR-03', false,
   $mft$Le brief du parrain : transmission des cinq fondamentaux.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Démontrez, chiffres à l'appui sur une année type (110 000 km), qu'un conducteur formé « coûte moins cher » qu'un conducteur non formé, en agrégeant carburant, sinistralité et litiges.$mft$,
   $mft$Réponse modèle. Carburant : écart courant de 3 à 5 L/100 km entre conduite formée et non formée ; hypothèse prudente 3 L/100 : 3 × 1 100 = 3 300 L/an ; à une valeur d'étude de 1,60 €/L : ≈ 5 280 € par an (à ajuster au prix réel). Sinistralité : la conduite anticipatrice réduit les accrochages : un seul petit sinistre évité économise franchise (souvent 500-1 500 €), immobilisation du véhicule (journées de CA perdues), majoration d'assurance et heures d'exploitation : chiffrage prudent : 1 500 à 3 000 €/an lissés. Litiges : des livraisons documentées (comptage, émargement, réserves) évitent des indemnisations et des heures de traitement : quelques centaines à quelques milliers d'euros selon l'activité : retenons 500 à 1 500 €. Usure : freins et pneus préservés par l'éco-conduite : plusieurs centaines d'euros. Total prudent : 7 000 à 10 000 € par an et par véhicule : soit plusieurs fois le coût d'une FCO (35 h) et des causeries : la formation n'est pas une dépense contrainte, c'est l'investissement au meilleur rendement de l'entreprise : et l'argument chiffré qui valorise le conducteur formé (prime, évolution).$mft$,
   $mft$Barème /5 : calcul carburant posé et exact avec réserve sur le prix (2 pts) ; sinistralité chiffrée avec ses composantes (franchise, immobilisation, majoration) (1,5 pt) ; litiges et usure intégrés (1 pt) ; conclusion investissement vs dépense (0,5 pt). Erreurs fréquentes : additionner sans hypothèses prudentes ; oublier les coûts indirects des sinistres.$mft$,
   5, 'difficile', ARRAY['fimo-fco','module-5','question-redigee','transversal'], 'FIMO-M5-QR-04', false,
   $mft$Le ROI de la formation conducteur, agrégé et prudent. Calcul carburant vérifié (3×1100=3300 L ; ×1,60=5 280 €).$mft$);

  -- ═══ ÉVALUATION BLANCHE 1 : Questionnaire 20 questions, 30 min ═════
  INSERT INTO public.quizzes (module_id, title, description, "type", time_limit_s, pass_threshold, is_mock_exam, shuffle_questions)
  VALUES (v_module, 'Évaluation blanche 1 : Questionnaire',
    'Vingt questions couvrant les cinq modules (qualification, conduite rationnelle, réglementations, santé/sécurité, service), 30 minutes, sans documents.',
    'examen', 1800, 60, true, true)
  RETURNING id INTO v_eb1;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_eb1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN (
    'FIMO-M0-QCM-02','FIMO-M0-QCM-05','FIMO-M0-QCM-08','FIMO-M0-QCM-11',
    'FIMO-T1-QCM-02','FIMO-T1-QCM-05','FIMO-T1-QCM-08','FIMO-T1-QCM-11',
    'FIMO-T2-QCM-02','FIMO-T2-QCM-05','FIMO-T2-QCM-08','FIMO-T2-QCM-11',
    'FIMO-T3-QCM-02','FIMO-T3-QCM-05','FIMO-T3-QCM-08','FIMO-T3-QCM-11',
    'FIMO-T4-QCM-02','FIMO-T4-QCM-05','FIMO-T4-QCM-08','FIMO-T4-QCM-11'
  );
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RAISE NOTICE 'Évaluation blanche 1 : % questions liées sur 20 attendues (si < 20 : appliquer les lots FIMO-1 à 5).', v_count;

  -- ═══ ÉVALUATION BLANCHE 2 : Mixte 10 QCM + 5 QR, 90 min ════════════
  INSERT INTO public.quizzes (module_id, title, description, "type", time_limit_s, pass_threshold, is_mock_exam, shuffle_questions)
  VALUES (v_module, 'Évaluation blanche 2 : Mixte (questionnaire + rédigé)',
    'Format complet : dix questions de questionnaire puis cinq questions à réponse construite (une par module), 90 minutes. Rédigez réellement : la correction s''appuie sur les barèmes.',
    'examen', 5400, 60, true, false)
  RETURNING id INTO v_eb2;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_eb2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN (
    'FIMO-M0-QCM-03','FIMO-M0-QCM-09',
    'FIMO-T1-QCM-03','FIMO-T1-QCM-09',
    'FIMO-T2-QCM-03','FIMO-T2-QCM-09',
    'FIMO-T3-QCM-03','FIMO-T3-QCM-09',
    'FIMO-T4-QCM-03','FIMO-T4-QCM-09',
    'FIMO-M0-QR-03','FIMO-T1-QR-03','FIMO-T2-QR-03','FIMO-T3-QR-03','FIMO-T4-QR-03'
  );
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RAISE NOTICE 'Évaluation blanche 2 : % questions liées sur 15 attendues (10 QCM + 5 QR).', v_count;

  INSERT INTO public.formation_quizzes (formation_id, quiz_id, is_mock_exam, display_order)
  VALUES (v_formation, v_eb1, true, 60), (v_formation, v_eb2, true, 61);

  RAISE NOTICE 'Module 5 FIMO créé : 1 leçon, 6 QC + 4 QR transversales (à valider), 2 évaluations blanches.';
END $fimom5$;
