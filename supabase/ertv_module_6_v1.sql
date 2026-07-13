-- =====================================================================
-- ERTV : EXPLOITANT EN TRANSPORT ROUTIER DE VOYAGEURS
-- MODULE 6 : PRÉPARATION À L'ÉVALUATION + 2 ÉVALUATIONS BLANCHES
-- v1 (juillet 2026)
--
-- ⚠ PRÉREQUIS : appliquer d'abord les modules 1 à 5 (ERTV-M1 à ERTV-M5).
--   Les évaluations blanches sont composées de questions EXISTANTES de
--   la banque (liaison par source_ref, aucune duplication) : si un
--   module manque, l'examen blanc sera partiel (le script l'indique
--   en NOTICE).
--
-- Contenu :
--   - 1 leçon : méthode de l'évaluation + tableau de synthèse des
--     5 modules voyageurs + paires piégeuses + planning final
--   - 10 questions transversales de synthèse (6 QC + 4 QR), à valider
--   - Examen blanc 1 : 20 QCM (4 par module), 30 min, seuil 60 %
--   - Examen blanc 2 : épreuve mixte 10 QCM + 5 QR, 90 min, seuil 60 %
--
-- ⚠ STATUT : questions insérées avec active = false (« à valider »).
-- Idempotent : DELETE ciblés par slug/source_ref, rejouable sans doublon.
-- =====================================================================

DO $ertvm6$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_l uuid;
  v_eb1 uuid;
  v_eb2 uuid;
  v_count int;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'ertv';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation ertv introuvable.'; END IF;

  INSERT INTO public.blocs (id, code, title, description, "order") VALUES (70, 'ERTV', 'Exploitant en transport routier de voyageurs', 'Concevoir, exploiter et réguler des services de transport routier de voyageurs : cadre réglementaire, graphicage, exploitation, social, sécurité et qualité.', 70) ON CONFLICT DO NOTHING;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'ERTV';

  DELETE FROM public.question_bank WHERE source_ref LIKE 'ERTV-M6-%';
  DELETE FROM public.modules WHERE slug = 'ertv-preparation';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 6 : Préparation à l''évaluation',
    'ertv-preparation', v_bloc,
    'Méthode d''évaluation, synthèse des cinq modules du transport de voyageurs et deux évaluations blanches en conditions.',
    'avance', 180, 60) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 60, true);

  -- ─── Leçon unique : réussir l'évaluation ERTV ──────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'reussir-evaluation-ertv',
    'Réussir l''évaluation : méthode et synthèse voyageurs',
    $mft$> 🎯 **Objectifs**
> - Connaître la forme de l'évaluation et la méthode propre à chaque exercice.
> - Réviser en une page les points clés des cinq modules voyageurs.
> - Dérouler un cas pratique d'exploitation sans sauter l'étape juridique.

## Ce qui vous attend

L'évaluation combine deux exercices complémentaires : un **QCM** qui balaie les cinq modules, et des **cas pratiques d'exploitation** qui vous placent dans le fauteuil de l'exploitant : une offre à monter, un conducteur à affecter, un incident à réguler. Le QCM vérifie la précision de vos connaissances ; le cas pratique vérifie que vous savez les faire travailler ensemble sous contrainte de temps.

Pour chaque cas pratique, une seule ossature, à appliquer systématiquement :

:::flow
1. Règle | Énoncer la règle applicable (type de service, régime social, priorité de régulation)
2. Application | La confronter aux faits du cas, chiffres à l'appui
3. Décision | Trancher explicitement : qui roule, quand, comment, et qui informe
:::

## Le QCM : précision et lecture double

Lisez chaque énoncé deux fois : repérez les négations, les unités (g/L de sang), et surtout la **nature du service** (régulier, SRS, occasionnel, SLO) : c'est elle qui commande presque toujours la bonne réponse. Répondez en deux passes : d'abord les certitudes, ensuite les hésitations par élimination des distracteurs impossibles ; ne restez jamais bloqué sur une question.

## La synthèse des cinq modules

| Module | L'essentiel à mobiliser |
| --- | --- |
| M1 : Cadre | Quatre familles de services : **réguliers**, **SRS** (services réguliers spécialisés, scolaires notamment), **occasionnels** (avec **billet collectif**), **SLO** (services librement organisés) ; les **AOM** et les **régions** organisent, la **DSP** délègue l'exploitation |
| M2 : Conception | **Graphicage** : construire les courses, y compris **haut-le-pied** et **battements** ; **habillage** : transformer les courses en **services de conducteurs** |
| M3 : Régulation | Priorités dans l'ordre : **sécurité**, puis **correspondances**, puis **régularité** ; **information des voyageurs** en continu |
| M4 : Social | Affectabilité : **permis D + FIMO voyageurs** ; règlement **561/2006** dès plus de 9 places, **SAUF** services réguliers de **50 km ou moins** ; alcool : **0,2 g/L** en transport en commun ; amplitude et coupures : régime de la **CCN** |
| M5 : Sécurité | Enfants : la **montée/descente** est le moment critique, **ceintures**, **EAD** ; accueil des **PMR** ; plan de crise : la **liste des passagers** d'abord |

> 📌 **Les paires piégeuses voyageurs**
> - **50 km** : le seuil d'exclusion du 561/2006 ne vaut que pour les services **réguliers** ; un service **occasionnel** reste soumis au règlement quelle que soit sa distance.
> - **0,2 vs 0,5 g/L** : le 0,2 s'applique au conducteur de **transport en commun** ; le 0,5 reste le seuil du conducteur du cas général.
> - **Billet collectif vs feuille de route** : deux documents de bord des services occasionnels qui ne s'échangent pas : identifiez le type de service avant de choisir le document (distinction détaillée au module 1).

## Le cas pratique : le réflexe qui rapporte

> ⚠️ **Attention**
> Dans tout cas d'affectation, vérifiez l'**affectabilité LÉGALE du conducteur AVANT le raisonnement opérationnel** : permis D en cours de validité, qualification voyageurs valide, régime de temps applicable au type de service, alcoolémie compatible. Un planning brillant construit sur un conducteur non affectable vaut zéro : dans le cas pratique comme dans la vraie vie.

Autres réflexes payants : nommer le type de service dès la première ligne (il commande tout le régime applicable), chiffrer ce qui peut l'être (kilomètres, minutes de battement), et clore chaque cas par une **décision explicite**, assortie de l'information des voyageurs ou de l'autorité organisatrice quand elle s'impose.

> 💡 **Astuce**
> Les cas pratiques se travaillent par écrit, chronomètre en marche : à l'évaluation, la difficulté n'est pas de savoir, c'est de produire une réponse structurée en temps limité. Relisez ensuite votre copie barème en main : c'est l'exercice qui fait le plus progresser.

## Les derniers jours

:::timeline
1. **J-14 à J-8** : Examen blanc 1 (QCM) sans documents ; retour ciblé sur les deux modules les plus faibles ; relecture du tableau de synthèse chaque soir.
2. **J-7 à J-3** : Examen blanc 2 (mixte) en conditions réelles : rédigez réellement les cas, puis corrigez-vous barème en main ; refaites par écrit les cas ratés.
3. **J-2 à J-1** : Révision légère : tableau des cinq modules, paires piégeuses, fiches d'erreurs ; pas de contenu nouveau ; logistique du jour J préparée.
4. **Jour J** : QCM en deux passes ; cas pratiques : règle, application, décision ; garder quelques minutes de relecture finale.
:::

## ✅ Synthèse

- Deux exercices : **QCM** (précision) et **cas pratiques** (règle, application, décision).
- Un seul support de révision finale : le **tableau des cinq modules** et les **paires piégeuses**.
- Cas d'affectation : l'**affectabilité légale d'abord**, l'opérationnel ensuite.$mft$,
    $mft$La méthode des deux exercices (QCM et cas pratiques en règle/application/décision), le tableau de synthèse des cinq modules voyageurs, les paires piégeuses (50 km, 0,2/0,5 g/L, billet collectif/feuille de route) et le planning des derniers jours.$mft$,
    1, 40) RETURNING id INTO v_l;

  -- ─── Questions transversales de synthèse (6 QC) ────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l, 'qr',
   $mft$Votre réseau exploite une ligne régulière de 38 km et des services occasionnels longue distance, tous assurés en autocars de 55 places. Lequel de ces services relève du règlement (CE) 561/2006, et pourquoi ?$mft$,
   $mft$Les services occasionnels : au-delà de 9 places, le règlement 561/2006 s'applique, et l'exception ne vise que les services réguliers dont le parcours n'excède pas 50 km. La ligne régulière de 38 km en est donc exclue.$mft$,
   2, 'moyen', ARRAY['ertv','module-6','question-courte'], 'ERTV-M6-QC-01', false,
   $mft$Le seuil de 50 km ne joue que pour les services réguliers, jamais pour l'occasionnel.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Un conducteur se présente à la prise de service d'un circuit scolaire ; le contrôle affiche 0,3 g/L de sang. Peut-il prendre le volant ? Justifiez.$mft$,
   $mft$Non : pour un conducteur de transport en commun, le seuil d'alcoolémie est abaissé à 0,2 g/L (contre 0,5 g/L pour le conducteur du cas général) : à 0,3 g/L il est en infraction et ne doit pas conduire.$mft$,
   2, 'facile', ARRAY['ertv','module-6','question-courte'], 'ERTV-M6-QC-02', false,
   $mft$Le 0,2 g/L propre au transport en commun est attendu, avec la comparaison au 0,5 g/L.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Votre nouvel assistant d'exploitation confond graphicage et habillage. Distinguez les deux notions en précisant l'objet de chacune.$mft$,
   $mft$Le graphicage construit les courses des véhicules (courses commerciales, haut-le-pied, battements) ; l'habillage construit les services des conducteurs à partir de ces courses.$mft$,
   2, 'facile', ARRAY['ertv','module-6','question-courte'], 'ERTV-M6-QC-03', false,
   $mft$Deux objets distincts : le véhicule d'un côté, le conducteur de l'autre.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$En cours d'exploitation, un même aléa met en jeu la sécurité à un point d'arrêt, une correspondance et la régularité de la ligne. Dans quel ordre le régulateur arbitre-t-il, et quelle obligation transversale accompagne chaque décision ?$mft$,
   $mft$Sécurité d'abord, correspondances ensuite, régularité enfin ; à chaque étape, le régulateur informe les voyageurs de la situation et de la décision prise.$mft$,
   2, 'moyen', ARRAY['ertv','module-6','question-courte'], 'ERTV-M6-QC-04', false,
   $mft$L'ordre des trois priorités et l'information voyageurs continue sont attendus.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$On vous propose un conducteur de remplacement disponible immédiatement pour couvrir un service au pied levé. Quelles vérifications LÉGALES précèdent tout raisonnement de planning ?$mft$,
   $mft$Vérifier son affectabilité légale : permis D en cours de validité, qualification voyageurs (FIMO voyageurs) valide, puis régime de temps applicable au type de service et compatibilité avec les temps déjà effectués. L'optimisation opérationnelle ne vient qu'après.$mft$,
   2, 'moyen', ARRAY['ertv','module-6','question-courte'], 'ERTV-M6-QC-05', false,
   $mft$L'affectabilité légale prime toujours sur l'urgence et sur le planning.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Un autocar transportant un groupe est impliqué dans un accident et le plan de crise est déclenché. Quel document la cellule de crise réclame-t-elle en priorité, et pour quels usages ?$mft$,
   $mft$La liste des passagers : elle permet de dénombrer et d'identifier les personnes à bord, de vérifier que personne ne manque à l'appel et de renseigner les secours et les familles.$mft$,
   2, 'difficile', ARRAY['ertv','module-6','question-courte'], 'ERTV-M6-QC-06', false,
   $mft$Sans liste des passagers fiable, aucun comptage ni information des familles n'est possible.$mft$);

  -- ─── Questions rédigées transversales (4 QR) : barème /5 ───────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l, 'qr',
   $mft$Cas de synthèse. Votre entreprise remporte la DSP d'un réseau interurbain confié par la région (deux lignes régulières de 35 et 42 km, une ligne de 65 km et un ensemble de circuits scolaires en SRS). Décrivez la démarche complète de mise en exploitation, du cahier des charges au premier jour de service, en mobilisant le cadre juridique, la conception de l'offre et le volet social.$mft$,
   $mft$Réponse modèle. 1) Cadre (module 1) : qualifier chaque service : lignes régulières et SRS scolaires, organisés par la région (AOM) qui délègue l'exploitation par DSP ; le cahier des charges fixe l'offre, la qualité et l'information voyageurs attendues. 2) Conception (module 2) : graphicage : construire les courses à partir des horaires imposés, en insérant les haut-le-pied et des battements réalistes aux terminus ; puis habillage : découper les courses en services de conducteurs respectant l'amplitude et les coupures prévues par la CCN. 3) Social (module 4) : vérifier l'affectabilité légale de chaque conducteur AVANT de publier les plannings : permis D valide, qualification FIMO voyageurs à jour ; identifier le régime de temps : les lignes de 35 et 42 km, régulières et de 50 km ou moins, échappent au 561/2006 ; la ligne de 65 km y reste soumise ; rappeler le seuil de 0,2 g/L. 4) Lancement : véhicules vérifiés (ceintures des circuits scolaires, EAD), procédures de montée/descente, information voyageurs et remontées à l'AOM. La séquence est impérative : un habillage optimisé avec un conducteur non affectable ne vaut rien.$mft$,
   $mft$Barème /5 : qualification des services et du cadre AOM/DSP (1 pt) ; graphicage complet avec haut-le-pied et battements (1 pt) ; habillage conforme au régime CCN (0,75 pt) ; affectabilité légale et régimes de temps corrects (seuil des 50 km réservé aux réguliers) (1,5 pt) ; lancement : sécurité scolaire et information (0,75 pt). Erreurs fréquentes : soumettre toutes les lignes au 561/2006 ; construire l'habillage avant de vérifier les titres des conducteurs.$mft$,
   5, 'difficile', ARRAY['ertv','module-6','question-redigee'], 'ERTV-M6-QR-01', false,
   $mft$Cas de synthèse DSP, transversal M1/M2/M4 : le grand classique du cas pratique d'exploitation.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Cas de régulation. À 16 h 50, l'autocar d'une ligne régulière transportant des collégiens est immobilisé par une avarie à un point d'arrêt, à quinze minutes de l'unique correspondance de la vallée ; un véhicule de réserve est disponible à vingt minutes. Déroulez la conduite de la régulation dans l'ordre des priorités, puis les actions du plan de crise si la situation impose une évacuation du véhicule.$mft$,
   $mft$Réponse modèle. Priorité 1 : sécurité : sécuriser le véhicule et le groupe ; la montée/descente est le moment critique : les collégiens ne descendent que si nécessaire, de manière encadrée, vers une zone sûre à l'écart de la chaussée ; information immédiate des voyageurs sur la situation et la solution en préparation. Priorité 2 : correspondances : prévenir le PC et la course de la vallée : faire retenir la correspondance quelques minutes ou organiser une solution de report pour les correspondants ; engager le véhicule de réserve (arrivée à vingt minutes) vers le point d'incident. Priorité 3 : régularité : recaler la suite de la ligne (courses suivantes, battements) une fois les personnes prises en charge. Si l'évacuation s'impose : appliquer le plan de crise : produire immédiatement la liste des passagers, compter les élèves à la descente et au point de regroupement, vérifier que personne ne manque, renseigner les secours, informer la cellule de crise qui gère familles et autorité organisatrice ; consigner la chronologie des décisions. Fil rouge : l'information des voyageurs et de l'AOM accompagne chaque étape ; la régularité ne passe jamais avant la sécurité ni les correspondances.$mft$,
   $mft$Barème /5 : ordre des priorités respecté (sécurité, correspondances, régularité) (1,5 pt) ; traitement sécurisé de la descente encadrée des collégiens (1 pt) ; gestion de la correspondance et du véhicule de réserve (1 pt) ; plan de crise : liste des passagers, comptage, secours, familles (1 pt) ; information continue voyageurs/AOM (0,5 pt). Erreurs fréquentes : raisonner d'abord en régularité ; faire descendre le groupe sans encadrement ; oublier la liste des passagers.$mft$,
   5, 'difficile', ARRAY['ertv','module-6','question-redigee'], 'ERTV-M6-QR-02', false,
   $mft$Incident scolaire avec correspondance en jeu, transversal M3/M5 : priorités et plan de crise.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Samedi, votre conducteur titulaire se déclare malade au réveil. Deux services à couvrir : la ligne régulière urbaine de 12 km et un service occasionnel de 280 km pour un club sportif. Deux conducteurs sont volontaires : Ali, permis D valide mais carte de qualification voyageurs expirée depuis un mois ; Nadia, tous titres à jour. Analysez l'affectabilité de chacun et proposez l'affectation, en structurant règle, application, décision.$mft$,
   $mft$Réponse modèle. Règle : l'affectation exige d'abord l'affectabilité légale : permis D valide ET qualification voyageurs en cours de validité ; le raisonnement opérationnel ne vient qu'ensuite. Côté temps : le service occasionnel (autocar de plus de 9 places) relève du 561/2006 quelle que soit sa distance ; la ligne de 12 km, régulière et de 50 km ou moins, en est exclue mais reste soumise aux règles d'amplitude et de coupures de la CCN. Application : Ali n'est affectable sur AUCUN des deux services : sa qualification expirée l'écarte aussi bien de la « petite » ligne urbaine que de l'occasionnel ; ni l'urgence ni la courte distance ne créent de tolérance. Nadia est affectable sur les deux, sous réserve de la compatibilité de ses temps déjà effectués avec le service visé. Décision : affecter Nadia sur un seul des deux services (par exemple l'occasionnel, plus difficile à couvrir au dernier moment) et traiter l'autre autrement : conducteur de réserve, sous-traitance, ou signalement immédiat à l'autorité organisatrice si une course doit être supprimée, avec information des voyageurs. Enfin, engager sans délai la régularisation de la qualification d'Ali.$mft$,
   $mft$Barème /5 : règle d'affectabilité complète (permis D + qualification voyageurs) énoncée avant l'opérationnel (1,5 pt) ; Ali écarté de TOUT service malgré l'urgence (1,5 pt) ; régimes de temps corrects (occasionnel au 561/2006, ligne courte exclue mais CCN applicable) (1 pt) ; décision opérationnelle argumentée avec solution pour le service découvert et information (1 pt). Erreurs fréquentes : affecter Ali sur la ligne courte « parce que c'est local » ; confondre exclusion du 561/2006 et absence de toute règle.$mft$,
   5, 'moyen', ARRAY['ertv','module-6','question-redigee'], 'ERTV-M6-QR-03', false,
   $mft$Affectation en urgence, transversal M1/M4 : l'affectabilité légale avant l'opérationnel.$mft$),

  (v_formation, v_module, v_l, 'qr',
   $mft$Audit sécurité de rentrée sur votre réseau scolaire, trois constats : des élèves descendent avant l'immobilisation complète des véhicules ; un conducteur interrogé ne sait pas produire la liste des passagers de sa course ; une réclamation PMR signale un refus de prise en charge. Construisez un plan d'action hiérarchisé : mesures immédiates, actions à moyen terme, indicateurs de suivi.$mft$,
   $mft$Réponse modèle. Hiérarchisation : 1) la montée/descente est le moment le plus critique du transport d'enfants : le constat d'élèves descendant avant l'immobilisation passe en tête ; 2) une liste des passagers introuvable rend le plan de crise inopérant le jour où il faut compter et identifier ; 3) la réclamation PMR touche une obligation d'accueil et l'image du réseau. Mesures immédiates : consigne rappelée à tous les conducteurs (portes fermées jusqu'à l'immobilisation complète, descente encadrée, port des ceintures), vérification du fonctionnement des EAD ; procédure de liste des passagers à jour et embarquée à chaque course scolaire ; réponse écrite au réclamant PMR et rappel des consignes de prise en charge. Moyen terme : causeries sécurité sur les points d'arrêt sensibles, exercice d'évacuation avec comptage sur liste, formation à l'accueil des PMR, aménagement des arrêts problématiques signalés. Indicateurs : incidents de montée/descente déclarés, taux de courses avec liste conforme lors des contrôles internes, nombre et délai de traitement des réclamations PMR, résultats des exercices d'évacuation. Boucler par l'information de l'autorité organisatrice sur le plan engagé : la transparence documentée fait partie de la qualité de service.$mft$,
   $mft$Barème /5 : hiérarchisation justifiée avec la montée/descente en premier (1,5 pt) ; mesures immédiates concrètes (portes/immobilisation, ceintures, EAD, liste embarquée) (1,5 pt) ; traitement de la réclamation PMR (réponse écrite + formation) (1 pt) ; indicateurs de suivi mesurables (0,5 pt) ; information de l'autorité organisatrice (0,5 pt). Erreurs fréquentes : traiter la réclamation PMR en premier au détriment du risque enfants ; livrer un plan sans indicateurs ni exercice.$mft$,
   5, 'moyen', ARRAY['ertv','module-6','question-redigee'], 'ERTV-M6-QR-04', false,
   $mft$Plan d'action sécurité et qualité, transversal M3/M5 : hiérarchiser, agir, mesurer.$mft$);

  -- ═══════════════ EXAMEN BLANC 1 : QCM (20 questions, 30 min) ════════
  -- Composé de questions EXISTANTES des modules 1 à 5 (4 par module),
  -- liées par source_ref : aucune duplication de contenu.
  INSERT INTO public.quizzes (module_id, title, description, "type", time_limit_s, pass_threshold, is_mock_exam, shuffle_questions)
  VALUES (v_module, 'Examen blanc 1 : QCM des 5 modules voyageurs',
    'Conditions proches de l''évaluation : 20 QCM couvrant les modules 1 à 5 (4 par module), 30 minutes, seuil 60 %. À faire sans documents.',
    'examen', 1800, 60, true, true)
  RETURNING id INTO v_eb1;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_eb1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN (
    'ERTV-M1-QCM-02','ERTV-M1-QCM-05','ERTV-M1-QCM-08','ERTV-M1-QCM-11',
    'ERTV-M2-QCM-02','ERTV-M2-QCM-05','ERTV-M2-QCM-08','ERTV-M2-QCM-11',
    'ERTV-M3-QCM-02','ERTV-M3-QCM-05','ERTV-M3-QCM-08','ERTV-M3-QCM-11',
    'ERTV-M4-QCM-02','ERTV-M4-QCM-05','ERTV-M4-QCM-08','ERTV-M4-QCM-11',
    'ERTV-M5-QCM-02','ERTV-M5-QCM-05','ERTV-M5-QCM-08','ERTV-M5-QCM-11'
  );
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RAISE NOTICE 'Examen blanc 1 : % questions liées sur 20 attendues (si < 20 : appliquer les modules 1 à 5).', v_count;

  -- ══════ EXAMEN BLANC 2 : Épreuve mixte (10 QCM + 5 QR, 90 min) ══════
  INSERT INTO public.quizzes (module_id, title, description, "type", time_limit_s, pass_threshold, is_mock_exam, shuffle_questions)
  VALUES (v_module, 'Examen blanc 2 : Épreuve mixte (QCM + cas rédigés)',
    'Simulation du format complet : 10 QCM (2 par module) puis 5 questions rédigées (1 par module), 90 minutes, seuil 60 %. Rédigez réellement vos réponses : la correction s''appuie sur les barèmes.',
    'examen', 5400, 60, true, false)
  RETURNING id INTO v_eb2;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_eb2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN (
    'ERTV-M1-QCM-03','ERTV-M1-QCM-09',
    'ERTV-M2-QCM-03','ERTV-M2-QCM-09',
    'ERTV-M3-QCM-03','ERTV-M3-QCM-09',
    'ERTV-M4-QCM-03','ERTV-M4-QCM-09',
    'ERTV-M5-QCM-03','ERTV-M5-QCM-09',
    'ERTV-M1-QR-03','ERTV-M2-QR-03','ERTV-M3-QR-03',
    'ERTV-M4-QR-03','ERTV-M5-QR-03'
  );
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RAISE NOTICE 'Examen blanc 2 : % questions liées sur 15 attendues (10 QCM + 5 QR).', v_count;

  -- Rattachement des examens blancs au niveau formation
  INSERT INTO public.formation_quizzes (formation_id, quiz_id, is_mock_exam, display_order)
  VALUES (v_formation, v_eb1, true, 60), (v_formation, v_eb2, true, 61);

  RAISE NOTICE 'Module 6 ERTV créé : module %, 1 leçon, 6 QC + 4 QR transversales (inactives, à valider), 2 examens blancs.', v_module;
END $ertvm6$;

-- =====================================================================
-- CONTRÔLES POST-EXÉCUTION
-- =====================================================================
-- 1) Les 2 examens blancs et leur composition :
--    select q.title, count(qqb.question_id) as nb_questions
--      from quizzes q left join quiz_question_bank qqb on qqb.quiz_id = q.id
--     where q.is_mock_exam and q.module_id in
--           (select id from modules where slug = 'ertv-preparation')
--     group by q.title;   → 20 et 15.
-- 2) Questions transversales : select "type", active, count(*)
--      from question_bank where source_ref like 'ERTV-M6-%'
--     group by 1, 2;      → qr/false = 10.
-- 3) Leçon du module :
--    select m.slug, count(l.id) as lecons from modules m
--      left join lessons l on l.module_id = m.id
--     where m.slug = 'ertv-preparation' group by m.slug;   → 1 leçon.
