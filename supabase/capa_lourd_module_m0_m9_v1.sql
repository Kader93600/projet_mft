-- =====================================================================
-- CAPACITÉ DE TRANSPORT > 3,5 T (LOURD) — LOT 9 (FINAL) :
-- M0 MÉTHODO & DÉCOUVERTE DE L'EXAMEN + M9 PRÉPARATION EXAMEN
-- + 2 EXAMENS BLANCS — v1 (juillet 2026)
--
-- ⚠ PRÉREQUIS : appliquer d'abord les lots 1 à 8 (modules A à H).
--   Les examens blancs sont composés de questions EXISTANTES de la
--   banque (liaison par source_ref, aucune duplication) : si un module
--   manque, l'examen blanc sera partiel (le script l'indique en NOTICE).
--
-- Contenu :
--   - M0 (2 leçons) : l'examen mode d'emploi, organiser sa préparation
--   - M9 (2 leçons) : méthodologie des épreuves, chiffres clés A-H
--   - 10 questions transversales de synthèse (6 QC + 4 QR), à valider
--   - Examen blanc 1 : 24 QCM (3 par domaine), 40 min, seuil 60 %
--   - Examen blanc 2 : épreuve mixte 16 QCM + 8 QR, 2 h, seuil 60 %
--
-- ⚠ STATUT : questions insérées avec active = false (« à valider »).
-- Idempotent : DELETE ciblés par slug/source_ref, rejouable sans doublon.
-- =====================================================================

DO $capam9$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_m0 uuid;
  v_m9 uuid;
  v_l uuid;
  v_l91 uuid;
  v_l92 uuid;
  v_eb1 uuid;
  v_eb2 uuid;
  v_count int;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'capacite-plus-3-5t';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation capacite-plus-3-5t introuvable.';
  END IF;

  INSERT INTO public.blocs (id, code, title, description, "order")
  VALUES (30, 'CAPA-LOURD', 'Capacité de transport lourd > 3,5 t',
          'Programme officiel de l''examen d''attestation de capacité professionnelle en transport routier lourd de marchandises (annexe I du règlement CE 1071/2009).', 30)
  ON CONFLICT DO NOTHING;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'CAPA-LOURD';

  DELETE FROM public.question_bank WHERE source_ref LIKE 'CAPA-LOURD-M9-%';
  DELETE FROM public.modules WHERE slug IN ('capa-lourd-methodo-examen', 'capa-lourd-preparation-examen');

  -- ═══════════════════════ M0 — MÉTHODO & DÉCOUVERTE ═══════════════════
  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Module 0 — Bien démarrer : l''examen et la méthode',
    'capa-lourd-methodo-examen',
    v_bloc,
    'Comprendre l''examen d''attestation de capacité lourde (épreuves, notation, inscription, dispenses) et organiser une préparation efficace sur la plateforme.',
    'debutant',
    120,
    5
  ) RETURNING id INTO v_m0;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_m0, 5, true);

  -- ─── M0 Leçon 1 — L'examen mode d'emploi ───────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_m0, 'examen-attestation-lourde-mode-emploi',
    'L''examen de l''attestation lourde : mode d''emploi',
    $mft$> 🎯 **Objectifs**
> - Savoir précisément à quoi ressemble l'examen que vous préparez.
> - Connaître les voies d'accès et les dispenses.
> - Repérer les échéances d'inscription.

## Ce que vous préparez

L'**attestation de capacité professionnelle en transport routier lourd de marchandises** permet d'exercer la fonction de **gestionnaire de transport** d'une entreprise exploitant des véhicules de plus de 3,5 t (module F). Trois voies :

1. **L'examen national annuel** : la voie que prépare cette formation.
2. **L'équivalence de diplôme** : certains diplômes dispensent d'examen (liste fixée par arrêté, notamment des diplômes bac +2 spécialisés transport).
3. **L'expérience de direction** : dispense encadrée pour les gestionnaires justifiant d'une longue expérience continue (conditions strictes, module F).

## L'épreuve écrite

L'examen est un **écrit national**, organisé une fois par an, structuré en deux parties :

| Partie | Forme | Esprit |
| --- | --- | --- |
| Questionnaire | **QCM** couvrant les domaines A à H | Rapidité, précision des connaissances |
| Épreuve rédigée | **Questions à réponse rédigée avec exercices de calcul** (gestion, exploitation, cas pratiques) | Raisonnement, méthode, calculs posés |

> ⚠️ **Attention**
> Le nombre exact de questions, le barème et le seuil d'admission sont fixés par la **décision annuelle** d'organisation : votre formateur vous communique les modalités de la session en cours. Ordre de grandeur constant : il faut viser une **majorité solide des points au total**, sans effondrement sur l'une des deux parties : on ne compense pas une épreuve rédigée vide par un bon QCM.

## L'inscription

Dossier d'inscription auprès de la **DREAL** de votre région (calendrier annuel : l'inscription ferme plusieurs semaines avant l'épreuve) ; pièces d'identité et formulaire ; convocation précisant lieu et matériel. Le jour J : pièce d'identité, convocation, stylos, **calculatrice autorisée selon la convocation** (vérifier chaque année), montre simple.

## Comment cette formation vous y prépare

Les **8 modules A à H** suivent exactement l'annexe I du règlement 1071/2009 (le programme officiel). Chaque module contient leçons, quiz, **questions courtes** (restitution rapide type QCM) et **questions rédigées avec barème** (l'épreuve rédigée). Le module 9 ajoute la méthodologie et **deux examens blancs**.

## ✅ Synthèse

- Attestation lourde = fonction de **gestionnaire de transport** ; examen national annuel, équivalences possibles.
- Écrit en **deux parties : QCM + rédigé avec calculs** ; les deux comptent : pas d'impasse.
- Inscription **DREAL**, calendrier annuel ; modalités précises = décision annuelle (formateur).$mft$,
    $mft$Les trois voies d'accès à l'attestation lourde, la structure de l'écrit national (QCM + épreuve rédigée avec calculs), l'inscription DREAL et l'articulation avec les modules A-H de la formation.$mft$,
    1, 30) RETURNING id INTO v_l;

  -- ─── M0 Leçon 2 — Organiser sa préparation ─────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_m0, 'organiser-sa-preparation',
    'Organiser sa préparation : la méthode qui marche',
    $mft$> 🎯 **Objectifs**
> - Construire un plan de travail réaliste jusqu'à l'examen.
> - Adopter la méthode active : se tester avant de relire.
> - Utiliser chaque type de contenu de la plateforme au bon moment.

## Le principe : la méthode active

Relire dix fois une leçon donne l'**illusion** de savoir ; se tester révèle ce qui est réellement acquis. La boucle efficace :

:::flow
1. Apprendre | Lire la leçon, noter les chiffres clés
2. Se tester | Quiz du module + questions courtes
3. Corriger | Relire UNIQUEMENT ce qui a manqué
4. Approfondir | Questions rédigées en conditions réelles
:::

## Le plan de travail type

Sur 8 à 12 semaines (adapter au temps disponible) :

| Phase | Contenu |
| --- | --- |
| Semaines 1-6 | Un module par semaine (A → H, F et E demandent davantage) : leçons + quiz + QC |
| Semaines 7-8 | Questions rédigées de chaque module, rédigées par écrit, barème en main |
| Semaines 9-10 | **Examen blanc 1 (QCM)** puis retour ciblé sur les domaines faibles |
| Dernière ligne droite | **Examen blanc 2 (mixte)** en conditions réelles + fiches chiffres clés (module 9) |

> 💡 **Astuce**
> Les questions rédigées se travaillent **par écrit, chronomètre en marche** : à l'examen, la difficulté n'est pas de savoir, c'est de produire une réponse structurée en temps limité. Rédiger dans sa tête ne compte pas.

## Les trois pièges de la préparation

- **L'impasse sur les calculs** (modules E et D) : l'épreuve rédigée en contient toujours : s'entraîner à POSER les calculs (unités, étapes).
- **Le survol des chiffres réglementaires** : 561/2006, masses, délais : ils font gagner des points « faciles » au QCM : fiches et répétition espacée.
- **La procrastination du rédigé** : commencer les QR dès la semaine 2 sur les modules déjà vus, pas à la fin.

## ✅ Synthèse

- **Se tester d'abord**, relire ensuite ; boucle apprendre → tester → corriger.
- Plan : modules A-H puis rédigé puis **examens blancs** ; E et F = les plus lourds.
- Les questions rédigées s'entraînent **par écrit et chronométrées**.$mft$,
    $mft$Méthode active (se tester avant de relire), plan de travail type sur 8-12 semaines, usage de chaque contenu (leçons, QC, QR, examens blancs) et les trois pièges classiques de la préparation.$mft$,
    2, 25) RETURNING id INTO v_l;

  -- ═══════════════════════ M9 — PRÉPARATION EXAMEN ═════════════════════
  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Module 9 — Préparation à l''examen',
    'capa-lourd-preparation-examen',
    v_bloc,
    'La méthodologie des deux épreuves (QCM et rédigé), la synthèse des chiffres clés des domaines A à H, les questions transversales de synthèse et deux examens blancs en conditions réelles.',
    'avance',
    360,
    90
  ) RETURNING id INTO v_m9;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_m9, 90, true);

  -- ─── M9 Leçon 1 — Méthodologie des épreuves ────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_m9, 'methodologie-des-epreuves',
    'Méthodologie : gagner des points au QCM et au rédigé',
    $mft$> 🎯 **Objectifs**
> - Appliquer une stratégie de QCM qui limite les pertes évitables.
> - Structurer chaque réponse rédigée pour coller au barème.
> - Gérer le temps des deux épreuves.

## Le QCM : la chasse aux pertes évitables

- **Lire l'énoncé deux fois** : repérer les négations (« lequel n'est PAS… »), les absolus (« toujours », « jamais », souvent faux), les unités (g/L vs mg/L, kg vs t).
- **Répondre en trois passes** : 1) les certitudes, vite ; 2) les hésitations, par élimination des distracteurs impossibles ; 3) les inconnues en dernier : ne jamais rester bloqué.
- **Les pièges récurrents du programme** : seuils voisins (7,5 t TICPE vs 12 t essieu), délais cousins (28 j carte tachy vs 30 j paiement), l'ordre 15 + 30 de la pause, le 0,2 g/L réservé au transport de personnes, conduite (56/90 h) vs travail (48/60 h).
- **Gestion du temps** : environ une minute par question ; marquer les questions à revoir, garder cinq minutes de relecture.

## Le rédigé : penser barème

Le correcteur note avec une grille. Chaque réponse suit la même ossature :

:::flow
1. Règle | Énoncer la règle applicable, avec ses chiffres
2. Application | L'appliquer aux faits du cas, calculs posés
3. Conclusion | Répondre explicitement à la question posée
:::

- **Analyser la question** : souligner les verbes (« calculez », « justifiez », « proposez ») : chaque verbe appelle un livrable différent.
- **Les calculs** : poser la formule AVANT les chiffres, écrire les unités, vérifier l'ordre de grandeur (un coût de revient de 0,15 €/km ou de 20 €/km doit alerter), encadrer le résultat.
- **La forme** : titres courts ou numérotation, une idée par paragraphe, pas de bavardage : un correcteur récompense ce qu'il retrouve vite.
- **Le temps** : répartir au prorata des points, traiter d'abord ce que l'on maîtrise, ne JAMAIS rendre une question à zéro : la règle seule rapporte déjà des points.

> 🎓 **Examen**
> Les questions rédigées de cette plateforme sont corrigées avec le même esprit : chaque barème détaille les points par élément attendu et les erreurs fréquentes. Entraînez-vous à relire vos copies AVEC le barème : c'est l'exercice qui fait le plus progresser.

## ✅ Synthèse

- QCM : lecture double, trois passes, pièges d'unités et de seuils voisins.
- Rédigé : **règle → application → conclusion**, calculs posés avec unités, barème en tête.
- Temps : au prorata des points ; jamais de question rendue vide.$mft$,
    $mft$Stratégie QCM (trois passes, pièges d'unités et de seuils voisins), ossature du rédigé (règle → application → conclusion), calculs posés et gestion du temps au prorata des points.$mft$,
    1, 40) RETURNING id INTO v_l91;

  -- ─── M9 Leçon 2 — Les chiffres clés A-H ────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_m9, 'chiffres-cles-derniere-ligne-droite',
    'La dernière ligne droite : tous les chiffres clés A-H',
    $mft$> 🎯 **Objectifs**
> - Réviser en une page tous les chiffres incontournables du programme.
> - Dérouler le planning des trente derniers jours.

## Le tableau des chiffres clés

| Domaine | Chiffres à connaître par cœur |
| --- | --- |
| A — Droit civil | Prescription **5 ans** (droit commun), **1 an** (contrat de transport) ; force majeure : 3 critères |
| B — Droit commercial | Cessation des paiements : déclaration **45 jours** ; créances : **2 mois** après BODACC ; garantie ≤ **50 %** de la capacité financière |
| C — Droit social | Conduite **9 h** (2 × 10 h), **56 h**/sem, **90 h**/2 sem ; pause **45 min (15 + 30)** après 4 h 30 ; repos **11 h** (réduit 9 h × 3, fractionné 3 + 9) ; hebdo **45 h** (réduit ≥ 24 h) ; carte tachy **5 ans** ; téléchargements **28 j / 90 j** ; travail **48 h** moyenne / **60 h** max ; FIMO **140 h**, FCO **35 h / 5 ans** ; retour conducteur **4 sem** (3 si 2 réduits) |
| D — Droit fiscal | TVA **20 %** ; gazole PL déductible **100 %** (VP 80 %) ; TICPE : remboursement **≥ 7,5 t** ; essieu : **≥ 12 t** ; IS **25 %** (15 % ≤ **42 500 €**) ; reprise fiscale **3 ans** |
| E — Gestion | Trinôme : **km × TK + h × TH + j × TJ** ; SR = **CF / taux de MCV** ; CAF = **résultat + dotations** ; paiement transport **30 jours** ; indemnité **40 €** ; BFR = clients − fournisseurs |
| F — Accès profession | Capacité financière : **9 000 / 5 000 €** (VUL int. : 1 800/900) ; gestionnaire externe : **4 entreprises / 50 véhicules** ; licences **10 ans** ; cabotage : **3 en 7 jours** (1 en 3 j à vide), carence **4 jours** ; retour véhicules **8 semaines** |
| G — Technique | **44 t** (≥ 5 essieux), 19/26/38 t ; essieu **13 t** ; largeur **2,55 m** ; longueurs **16,50 / 18,75 m** ; CT **annuel** ; limiteur **90 km/h** ; arrimage **0,8 / 0,5 G** ; contrats types : seuil **3 t** ; ADR : **9 classes**, exemption **1 000 points** |
| H — Sécurité routière | Vitesses PL **90 / 80 / 50** ; interdiction > 7,5 t **sam 22 h → dim 22 h** ; interdistance **50 m** ; alcool **0,5 / 0,8 g/L** ; téléphone **135 € + 3 pts** ; permis **12 points**, validité **5/2/1 ans** ; AT : **48 h** (employeur) |

> 📌 **À retenir**
> Les paires piégeuses à ne plus confondre : **7,5 t** (TICPE) / **12 t** (essieu) : **28 j** (carte) / **30 j** (paiement) : **56-90 h** (conduite) / **48-60 h** (travail) : **8 semaines** (véhicules) / **4 semaines** (conducteurs) : **45 h** (repos hebdo) / **45 jours** (cessation des paiements).

## Les trente derniers jours

:::timeline
1. **J-30 à J-15** — Examen blanc 1 (QCM) ; retour ciblé sur les deux domaines les plus faibles ; une série de questions courtes par jour.
2. **J-14 à J-7** — Examen blanc 2 (mixte) en conditions réelles ; refaire PAR ÉCRIT les questions rédigées ratées ; fiches chiffres relues chaque soir.
3. **J-6 à J-2** — Révision légère : tableau des chiffres, erreurs répertoriées, pas de nouveau contenu.
4. **J-1** — Repos, logistique du jour J (trajet, convocation, matériel), coucher tôt.
5. **Jour J** — Arriver en avance ; QCM en trois passes ; rédigé : règle → application → conclusion ; relecture.
:::

## ✅ Synthèse

- Un seul support de révision finale : **ce tableau** + vos fiches d'erreurs.
- Les points se gagnent sur les **paires piégeuses** et les **calculs posés**.
- Dernière semaine : consolidation, pas de nouveauté.$mft$,
    $mft$Tableau de synthèse des chiffres clés des 8 domaines, les paires piégeuses (7,5/12 t, 28/30 j, 56-90/48-60 h, 8/4 semaines), et le planning des 30 derniers jours jusqu'au jour J.$mft$,
    2, 35) RETURNING id INTO v_l92;

  -- ─── Questions transversales de synthèse (6 QC + 4 QR) ─────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_m9, v_l92, 'qr',
   $mft$Trois seuils de tonnage structurent le programme : citez le seuil du remboursement TICPE, celui de la taxe à l'essieu et la masse maximale d'un ensemble de 5 essieux et plus.$mft$,
   $mft$TICPE : 7,5 tonnes et plus ; taxe à l'essieu : 12 tonnes et plus ; masse maximale : 44 tonnes.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-9','question-courte','transversal'], 'CAPA-LOURD-M9-QC-01', false,
   $mft$Trio piège favori des QCM : exiger les trois valeurs correctement appariées.$mft$),

  (v_formation, v_m9, v_l92, 'qr',
   $mft$Le paquet mobilité impose deux « retours » périodiques distincts : lesquels, et à quelles fréquences ?$mft$,
   $mft$Le retour des véhicules au centre opérationnel au moins toutes les 8 semaines, et le retour des conducteurs (domicile ou centre) toutes les 4 semaines (3 semaines après deux repos hebdomadaires réduits consécutifs).$mft$,
   2, 'difficile', ARRAY['capa-lourd','module-9','question-courte','transversal'], 'CAPA-LOURD-M9-QC-02', false,
   $mft$Confusion classique 8 semaines/4 semaines : exiger les deux objets ET les deux fréquences.$mft$),

  (v_formation, v_m9, v_l92, 'qr',
   $mft$Distinguez le délai maximal de paiement d'une facture de transport et la périodicité minimale de téléchargement de la carte conducteur.$mft$,
   $mft$Paiement des factures de transport : 30 jours à compter de l'émission ; téléchargement de la carte conducteur : au moins tous les 28 jours.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-9','question-courte','transversal'], 'CAPA-LOURD-M9-QC-03', false,
   $mft$28 et 30 : deux délais voisins, deux domaines différents (paiement vs chronotachygraphe).$mft$),

  (v_formation, v_m9, v_l92, 'qr',
   $mft$Quelle prescription s'applique aux actions nées du contrat de transport, et quelle est la prescription de droit commun ?$mft$,
   $mft$Un an pour le contrat de transport ; cinq ans en droit commun.$mft$,
   2, 'facile', ARRAY['capa-lourd','module-9','question-courte','transversal'], 'CAPA-LOURD-M9-QC-04', false,
   $mft$Le « 1 an transport » vaut dans les deux sens : contre le transporteur ET pour ses impayés.$mft$),

  (v_formation, v_m9, v_l92, 'qr',
   $mft$Comparez la capacité financière exigée pour une flotte lourde et celle d'une flotte de véhicules légers utilisés à l'international (premier véhicule / véhicules suivants).$mft$,
   $mft$Lourd : 9 000 € pour le premier véhicule puis 5 000 € par véhicule suivant ; VUL à l'international (2,5-3,5 t) : 1 800 € puis 900 €.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-9','question-courte','transversal'], 'CAPA-LOURD-M9-QC-05', false,
   $mft$Les quatre montants sont attendus, correctement appariés.$mft$),

  (v_formation, v_m9, v_l92, 'qr',
   $mft$« 45 heures » et « 45 jours » : à quoi correspond chacun de ces deux chiffres dans le programme ?$mft$,
   $mft$45 heures : durée du repos hebdomadaire normal (interdit en cabine) ; 45 jours : délai maximal pour déclarer la cessation des paiements au tribunal.$mft$,
   2, 'difficile', ARRAY['capa-lourd','module-9','question-courte','transversal'], 'CAPA-LOURD-M9-QC-06', false,
   $mft$Même nombre, deux mondes : social (module C) et procédures collectives (module B).$mft$);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_m9, v_l91, 'qr',
   $mft$Cas de synthèse. Karim, titulaire de l'attestation de capacité lourde, crée une SAS de transport avec deux tracteurs 44 t. Décrivez le parcours complet, de la création de la société à la première tournée facturée, en mobilisant les domaines B, C, E et F.$mft$,
   $mft$Réponse modèle. 1) Société (B) : statuts SAS (objet : transport public routier de marchandises), dépôt du capital, annonce légale, immatriculation (RCS/RNE) : la société acquiert la personnalité morale. 2) Accès à la profession (F) : demande d'autorisation à la DREAL au nom de la société : les quatre exigences : établissement (locaux + centre opérationnel), honorabilité (dirigeant + gestionnaire), capacité financière (2 véhicules lourds = 9 000 + 5 000 = 14 000 € de capitaux propres attestés), capacité professionnelle (Karim gestionnaire, direction effective) ; inscription au registre, licence (communautaire si international) et 2 copies conformes. 3) Moyens (C/G) : achat ou crédit-bail des tracteurs (E), contrôle technique et équipements, embauche des conducteurs : permis CE + CQC + carte conducteur, DPAE, contrats, visite ; organisation 561/2006 et chronotachygraphe (téléchargements 28/90 j). 4) Vendre (E) : coût de revient par le trinôme, devis avec marge et clause d'indexation gazole, CGV (paiement 30 jours), assurances (RC, marchandises). 5) Exploiter et facturer : lettre de voiture, suivi des temps, facturation immédiate, encaissement sous 30 jours. Le parcours est séquentiel : sans l'autorisation DREAL (étape 2), rien ne roule légalement.$mft$,
   $mft$Barème /5 : création de la société correcte (0,75 pt) ; les 4 exigences avec le calcul 14 000 € (1,5 pt) ; embauche conducteurs complète (permis+CQC+carte, DPAE) (1 pt) ; dispositif commercial (trinôme, indexation gazole, 30 jours) (1 pt) ; séquencement logique dont autorisation avant exploitation (0,75 pt). Erreurs fréquentes : oublier la capacité financière chiffrée ; faire rouler avant l'inscription au registre.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-9','question-redigee','transversal'], 'CAPA-LOURD-M9-QR-01', false,
   $mft$Cas de synthèse création d'entreprise, transversal B/C/E/F : le grand classique de l'épreuve rédigée.$mft$),

  (v_formation, v_m9, v_l91, 'qr',
   $mft$Cas de synthèse. Un contrôle DREAL en entreprise révèle : des capitaux propres tombés à 11 000 € pour 3 véhicules lourds exploités, l'absence de téléchargement des cartes conducteurs depuis 3 mois, et un conducteur dont la carte de qualification (FCO) a expiré il y a six semaines. Hiérarchisez les manquements, chiffrez ce qui doit l'être et bâtissez le plan de régularisation.$mft$,
   $mft$Réponse modèle. Chiffrage : capacité financière exigée pour 3 véhicules lourds = 9 000 + 2 × 5 000 = 19 000 € : déficit de 8 000 €. Hiérarchisation par gravité et urgence : 1) le conducteur sans FCO valide : infraction immédiate à chaque prise de volant : retrait de la conduite AUJOURD'HUI, inscription en FCO (35 h), réaffectation temporaire ; 2) la capacité financière insuffisante : exigence d'accès en péril : régularisation via recapitalisation, comptes courants bloqués, ou garantie bancaire dans la limite de la moitié de l'exigence (9 500 € max) : ici une garantie de 8 000 € est admissible ; à défaut, réduire la flotte (rendre une copie conforme) ; 3) les téléchargements tachy (28 j carte / 90 j véhicule non respectés) : rattrapage immédiat de l'ensemble des données, analyse des infractions révélées, procédure et formation. Plan : sous 48 h : conducteur écarté de la conduite, téléchargements rattrapés ; sous 2 à 4 semaines : montage financier documenté (attestation expert-comptable + garantie), FCO planifiée ; en continu : échéancier des CQC/permis/visites, routine mensuelle de téléchargement, indicateur de capitaux propres au tableau de bord ; réponse écrite à la DREAL avec preuves : la bonne foi documentée évite l'escalade (mise en demeure, retrait).$mft$,
   $mft$Barème /5 : calcul 19 000 € et déficit 8 000 € (1 pt) ; hiérarchisation pertinente avec le conducteur en premier (1 pt) ; solutions capacité financière dont la limite de garantie à 50 % (1,5 pt) ; rattrapage tachy et prévention récidive (1 pt) ; posture vis-à-vis de la DREAL (réponse documentée) (0,5 pt). Erreurs fréquentes : traiter la finance avant le conducteur en infraction quotidienne ; proposer une garantie couvrant tout le déficit au-delà de la moitié exigible.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-9','question-redigee','transversal'], 'CAPA-LOURD-M9-QR-02', false,
   $mft$Cas de crise multi-manquements, transversal C/E/F : gestion des priorités.$mft$),

  (v_formation, v_m9, v_l91, 'qr',
   $mft$Cas de synthèse. Votre PME (transport national) veut ouvrir des flux réguliers vers l'Allemagne et la Belgique. Établissez la checklist complète : titres, règles d'exploitation, conducteurs, coûts : et signalez les trois erreurs qui coûtent le plus cher aux nouveaux entrants.$mft$,
   $mft$Réponse modèle. Titres (F) : licence communautaire + copies conformes à bord ; conducteurs de pays tiers : attestation de conducteur. Exploitation (F/C) : règles de cabotage en Allemagne/Belgique (3 opérations en 7 jours après livraison complète, 1 en 3 jours si entrée à vide, carence de 4 jours même État/même véhicule) avec preuves CMR conservées ; retour des véhicules toutes les 8 semaines ; retour des conducteurs (4 semaines, 3 si deux repos réduits) ; repos hebdomadaire normal hors cabine (hébergement payé). Social (C) : détachement pour cabotage et transports triangulaires : déclaration via le système européen, rémunération du pays d'accueil : les transports bilatéraux en sont exemptés ; temps de conduite inchangés (561/2006). Coûts (E) : intégrer péages étrangers, hébergements, surcoûts de détachement et de gestion au coût de revient et aux devis ; clause gazole ; trésorerie (BFR accru par les délais clients export). Assurances et documents : CMR, extension géographique. Trois erreurs coûteuses : 1) caboter au-delà des plafonds ou sans preuves CMR (amendes locales élevées, interdiction temporaire) ; 2) ignorer le détachement sur le cabotage/triangulaire (redressements et sanctions dans le pays d'accueil) ; 3) coter les flux au coût de revient national (péages, hébergement, retours à vide non intégrés) et perdre de l'argent sur chaque voyage.$mft$,
   $mft$Barème /5 : titres corrects (0,75 pt) ; règles de cabotage complètes avec preuves (1,25 pt) ; détachement bien périmétré (bilatéral exempté) (1 pt) ; intégration des coûts au devis (1 pt) ; trois erreurs pertinentes (1 pt). Erreurs fréquentes : confondre les retours 8/4 semaines ; croire le détachement applicable au bilatéral.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-9','question-redigee','transversal'], 'CAPA-LOURD-M9-QR-03', false,
   $mft$Ouverture à l'international, transversal C/E/F : checklist et pièges.$mft$),

  (v_formation, v_m9, v_l91, 'qr',
   $mft$Cas de synthèse. Votre plus gros client (28 % du chiffre d'affaires) exige une baisse de 8 % sur ses tarifs, sans quoi il consultera la concurrence. Vos marges : 4 % de résultat net, coûts conformes au trinôme du secteur. Analysez et construisez la réponse, chiffres à l'appui.$mft$,
   $mft$Réponse modèle. Analyse : accorder −8 % sur 28 % du CA ampute le CA total d'environ 2,2 % (0,28 × 8 %) : avec 4 % de marge nette et des coûts inchangés, le résultat chute de plus de moitié (la baisse de prix passe intégralement en perte de marge) : l'acceptation pure est destructrice. Démarche : 1) objectiver ses coûts sur CE client (trinôme par ligne : kilomètres à vide, attentes, saisonnalité) : identifier si le client est réellement rentable et où ; 2) chercher les contreparties créatrices de valeur avant toute remise : engagements de volume ferme, lissage des commandes (meilleur remplissage), réduction des attentes (créneaux garantis), fret retour, allongement du contrat avec indexation gazole verrouillée, paiement plus rapide (BFR) ; chaque contrepartie se chiffre ; 3) proposer un effort ciblé et conditionné (par exemple 2 à 3 % contre volumes et attentes réduites) plutôt qu'un −8 % sec ; 4) en parallèle, réduire la dépendance (28 % = risque client majeur) : prospection, diversification ; 5) fixer sa limite : en dessous du coût de revient complet, refuser : perdre un client vaut mieux que perdre de l'argent sur chaque course, et un plan de remplacement du volume se prépare dès maintenant. Conclusion attendue : réponse négociée, chiffrée, avec contreparties, ligne rouge explicite et plan B.$mft$,
   $mft$Barème /5 : impact chiffré de la demande (≈ −2,2 % de CA, effet majeur sur 4 % de marge) (1,5 pt) ; analyse de rentabilité par ligne avant de répondre (1 pt) ; contreparties pertinentes et chiffrables (1,5 pt) ; gestion du risque de dépendance et ligne rouge (1 pt). Erreurs fréquentes : accepter ou refuser sans chiffrer ; négocier sans connaître son coût de revient sur le client.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-9','question-redigee','transversal'], 'CAPA-LOURD-M9-QR-04', false,
   $mft$Négociation tarifaire sous contrainte de marge, transversal E : cas très réaliste.$mft$);

  -- ═══════════════ EXAMEN BLANC 1 — QCM (24 questions, 40 min) ════════
  -- Composé de questions EXISTANTES des modules A-H (3 par domaine),
  -- liées par source_ref : aucune duplication de contenu.
  INSERT INTO public.quizzes (module_id, title, description, "type", time_limit_s, pass_threshold, is_mock_exam, shuffle_questions)
  VALUES (v_m9, 'Examen blanc 1 — QCM des 8 domaines',
    'Conditions proches de l''épreuve : 24 QCM couvrant les domaines A à H (3 par domaine), 40 minutes, seuil 60 %. À faire sans documents.',
    'examen', 2400, 60, true, true)
  RETURNING id INTO v_eb1;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_eb1, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN (
    'CAPA-LOURD-A-QCM-02','CAPA-LOURD-A-QCM-06','CAPA-LOURD-A-QCM-10',
    'CAPA-LOURD-B-QCM-02','CAPA-LOURD-B-QCM-06','CAPA-LOURD-B-QCM-10',
    'CAPA-LOURD-C-QCM-02','CAPA-LOURD-C-QCM-06','CAPA-LOURD-C-QCM-10',
    'CAPA-LOURD-D-QCM-02','CAPA-LOURD-D-QCM-06','CAPA-LOURD-D-QCM-10',
    'CAPA-LOURD-E-QCM-02','CAPA-LOURD-E-QCM-06','CAPA-LOURD-E-QCM-10',
    'CAPA-LOURD-F-QCM-02','CAPA-LOURD-F-QCM-06','CAPA-LOURD-F-QCM-10',
    'CAPA-LOURD-G-QCM-02','CAPA-LOURD-G-QCM-06','CAPA-LOURD-G-QCM-10',
    'CAPA-LOURD-H-QCM-02','CAPA-LOURD-H-QCM-06','CAPA-LOURD-H-QCM-10'
  );
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RAISE NOTICE 'Examen blanc 1 : % questions liées sur 24 attendues (si < 24 : appliquer les lots 1-8).', v_count;

  -- ══════ EXAMEN BLANC 2 — Épreuve mixte (16 QCM + 8 QR, 2 h) ═════════
  INSERT INTO public.quizzes (module_id, title, description, "type", time_limit_s, pass_threshold, is_mock_exam, shuffle_questions)
  VALUES (v_m9, 'Examen blanc 2 — Épreuve mixte (QCM + rédigé)',
    'Simulation du format complet : 16 QCM (2 par domaine) puis 8 questions rédigées avec calculs (1 par domaine), 2 heures, seuil 60 %. Rédigez réellement vos réponses : la correction s''appuie sur les barèmes.',
    'examen', 7200, 60, true, false)
  RETURNING id INTO v_eb2;

  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
  SELECT v_eb2, id, ROW_NUMBER() OVER (ORDER BY source_ref)
  FROM public.question_bank
  WHERE source_ref IN (
    'CAPA-LOURD-A-QCM-03','CAPA-LOURD-A-QCM-11',
    'CAPA-LOURD-B-QCM-03','CAPA-LOURD-B-QCM-11',
    'CAPA-LOURD-C-QCM-03','CAPA-LOURD-C-QCM-11',
    'CAPA-LOURD-D-QCM-03','CAPA-LOURD-D-QCM-11',
    'CAPA-LOURD-E-QCM-03','CAPA-LOURD-E-QCM-11',
    'CAPA-LOURD-F-QCM-03','CAPA-LOURD-F-QCM-11',
    'CAPA-LOURD-G-QCM-03','CAPA-LOURD-G-QCM-11',
    'CAPA-LOURD-H-QCM-03','CAPA-LOURD-H-QCM-11',
    'CAPA-LOURD-A-QR-03','CAPA-LOURD-B-QR-03','CAPA-LOURD-C-QR-03',
    'CAPA-LOURD-D-QR-03','CAPA-LOURD-E-QR-03','CAPA-LOURD-F-QR-03',
    'CAPA-LOURD-G-QR-03','CAPA-LOURD-H-QR-03'
  );
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RAISE NOTICE 'Examen blanc 2 : % questions liées sur 24 attendues (16 QCM + 8 QR).', v_count;

  -- Rattachement des examens blancs au niveau formation
  INSERT INTO public.formation_quizzes (formation_id, quiz_id, is_mock_exam, display_order)
  VALUES (v_formation, v_eb1, true, 90), (v_formation, v_eb2, true, 91);

  RAISE NOTICE 'Lot 9 : M0 (2 leçons) + M9 (2 leçons, 6 QC + 4 QR transversales à valider) + 2 examens blancs créés.';
END $capam9$;

-- =====================================================================
-- CONTRÔLES POST-EXÉCUTION
-- =====================================================================
-- 1) Les 2 examens blancs et leur composition :
--    select q.title, count(qqb.question_id) as nb_questions
--      from quizzes q left join quiz_question_bank qqb on qqb.quiz_id = q.id
--     where q.is_mock_exam and q.module_id in
--           (select id from modules where slug = 'capa-lourd-preparation-examen')
--     group by q.title;   → 24 et 24.
-- 2) Questions transversales : select "type", active, count(*)
--      from question_bank where source_ref like 'CAPA-LOURD-M9-%'
--     group by 1, 2;      → qr/false = 10.
-- 3) Modules et leçons du lot :
--    select m.slug, count(l.id) as lecons from modules m
--      left join lessons l on l.module_id = m.id
--     where m.slug in ('capa-lourd-methodo-examen','capa-lourd-preparation-examen')
--     group by m.slug;    → 2 leçons chacun.
