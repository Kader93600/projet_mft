-- =====================================================================
-- FIMO / FCO MARCHANDISES : MODULE 0 : LA QUALIFICATION DES
-- CONDUCTEURS (FIMO, FCO, CARTE) : v1 (juillet 2026) : LOT FIMO-1
--
-- Référentiels : directive 2003/59/CE modifiée (2018/645), arrêté du
-- 3 janvier 2008 modifié (qualification initiale et continue des
-- conducteurs du transport routier de marchandises).
-- Public : conducteurs et futurs conducteurs (ton direct, cas terrain).
--
-- ⚠ STATUT : questions insérées avec active = false (« à valider »).
-- Idempotent : DELETE ciblés par slug/source_ref, rejouable sans doublon.
-- =====================================================================

DO $fimo0$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_l1 uuid;
  v_l2 uuid;
  v_l3 uuid;
  v_l4 uuid;
  v_quiz uuid;
  v_q uuid;
  v_ord int := 0;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'fimo-fco';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation fimo-fco introuvable dans public.formations.';
  END IF;

  INSERT INTO public.blocs (id, code, title, description, "order")
  VALUES (40, 'FIMO-FCO',
          'FIMO / FCO : Qualification des conducteurs marchandises',
          'Référentiel de la qualification initiale (FIMO) et continue (FCO) des conducteurs du transport routier de marchandises : directive 2003/59/CE modifiée et arrêté du 3 janvier 2008.',
          40)
  ON CONFLICT DO NOTHING;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'FIMO-FCO';

  DELETE FROM public.question_bank WHERE source_ref LIKE 'FIMO-M0-%';
  DELETE FROM public.modules WHERE slug = 'fimo-cadre-qualification';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Module 0 : FIMO, FCO et carte de qualification',
    'fimo-cadre-qualification',
    v_bloc,
    'Qui doit être qualifié pour conduire un poids lourd, comment s''obtient la FIMO, comment la FCO maintient la qualification tous les 5 ans, et comment fonctionne la carte de qualification de conducteur.',
    'debutant',
    240,
    10
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 10, true);

  -- ─── Leçon 1 : Qui doit être qualifié ? ────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'qui-doit-etre-qualifie',
    'Qui doit être qualifié ? Champ et exemptions',
    $mft$> 🎯 **Objectifs**
> - Savoir si VOTRE situation exige la qualification de conducteur.
> - Citer les principales exemptions sans vous tromper.
> - Comprendre ce que risquent le conducteur et l'entreprise en cas de défaut.

## La règle

Tout conducteur qui effectue du **transport de marchandises** avec un véhicule de **plus de 3,5 tonnes** de PTAC (permis C1, C1E, C, CE) doit détenir une **qualification professionnelle**, en plus du permis de conduire :

- la **qualification initiale** : FIMO (ou un diplôme équivalent) pour entrer dans le métier ;
- la **qualification continue** : FCO, renouvelée tous les 5 ans, pour y rester.

Le permis autorise à conduire le véhicule ; la qualification autorise à en faire **son métier**. Les deux sont contrôlés ensemble sur la route.

## Les principales exemptions

Certaines conduites échappent à l'obligation de qualification :

| Situation | Exemple concret |
| --- | --- |
| Véhicules dont la vitesse maximale ne dépasse pas 45 km/h | Engins lents |
| Services de l'État et secours | Armées, pompiers, forces de l'ordre, protection civile |
| Essais, réparation, entretien | Convoyage atelier, essais techniques |
| Transport à des fins privées, non commerciales | Déménager ses propres meubles |
| Transport de matériel utilisé par le conducteur dans son activité principale | L'artisan qui livre son propre chantier, la conduite restant accessoire |

> ❌ **Piège à éviter**
> L'exemption « artisan » suppose que la conduite ne soit PAS l'activité principale : un maçon qui apporte ses parpaings au chantier est exempté ; un salarié embauché pour livrer les chantiers toute la journée ne l'est pas. En cas de doute, la qualification s'impose.

## Ce que vous risquez sans qualification

- **Conducteur** : amende, immobilisation possible du véhicule, impossibilité de justifier son activité au contrôle.
- **Entreprise** : amende par conducteur non qualifié, responsabilité en cas d'accident (assureur, juge), image dégradée auprès des donneurs d'ordre.
- **En cas d'accident grave** : conduire sans qualification valide pèse lourdement dans le dossier pénal et assurantiel.

> 📌 **À retenir**
> Avant toute embauche ou prise de poste : **permis + carte de qualification + carte conducteur (tachygraphe)**. Les trois, valides, ensemble. C'est aussi simple que ça.

## ✅ Synthèse

- Marchandises + véhicule **> 3,5 t** = qualification obligatoire (FIMO puis FCO).
- Exemptions principales : ≤ 45 km/h, État/secours, essais-atelier, usage **privé**, conduite **accessoire** de l'artisan.
- Sans qualification : amendes, immobilisation, responsabilités aggravées pour le conducteur ET l'entreprise.$mft$,
    $mft$Champ de la qualification obligatoire (marchandises > 3,5 t), les cinq exemptions principales avec le piège de la conduite accessoire, et les risques encourus sans qualification.$mft$,
    1, 30) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : La FIMO : entrer dans le métier ─────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'fimo-entrer-dans-le-metier',
    'La FIMO : entrer dans le métier',
    $mft$> 🎯 **Objectifs**
> - Connaître le contenu et la durée de la FIMO marchandises.
> - Identifier les équivalences qui dispensent de la FIMO.
> - Utiliser la passerelle voyageurs ↔ marchandises.

## La FIMO en bref

La **formation initiale minimale obligatoire** (FIMO marchandises) dure **140 heures** (environ 4 semaines) et se conclut par une **évaluation finale**. Elle couvre les quatre thèmes du référentiel :

:::flow
1. Thème 1 | Conduite rationnelle axée sécurité
2. Thème 2 | Réglementations du transport
3. Thème 3 | Santé, sécurité routière et environnementale
4. Thème 4 | Service, logistique, image du métier
:::

Ces quatre thèmes structurent la suite de cette formation : un module chacun.

## Les conditions d'accès

- Être titulaire du **permis** de la catégorie concernée (C1, C1E, C, CE) ou en formation simultanée ;
- La FIMO abaisse l'**âge d'accès** au métier : conduire dès **18 ans** en catégorie C/CE avec la qualification initiale (21 ans sinon).

## Les équivalences : qui est dispensé de FIMO ?

Sont notamment réputés qualifiés, sans passer la FIMO « sèche » :

- les titulaires d'un **titre professionnel de conducteur** du transport routier de marchandises ;
- les titulaires d'un **CAP / bac pro conducteur** (diplômes de conduite routière) ;
- les conducteurs pouvant justifier d'une **expérience antérieure** dans les conditions prévues par les textes (droits acquis historiques).

> 💡 **Astuce**
> Pour un demandeur d'emploi ou une reconversion, le **titre professionnel** (plus long) donne à la fois la qualification ET un diplôme reconnu ; la FIMO (4 semaines) est la voie rapide vers l'embauche. Le choix dépend du projet et du financement.

## La passerelle voyageurs ↔ marchandises

Un conducteur déjà titulaire de la qualification **voyageurs** qui veut passer aux **marchandises** (ou l'inverse) ne refait pas 140 h : il suit une **passerelle** raccourcie (de l'ordre d'une semaine, 35 heures) centrée sur les spécificités de la nouvelle spécialité.

## À l'issue de la FIMO

Réussite à l'évaluation → **attestation de qualification** → demande de la **carte de qualification de conducteur** (leçon 4) → prise de poste. L'échéance de la première **FCO** se calcule à partir de la délivrance : 5 ans.

## ✅ Synthèse

- FIMO marchandises : **140 h**, 4 thèmes, évaluation finale ; conduite possible dès **18 ans** avec la qualification.
- Dispenses : **titre pro / diplômes de conduite** ; passerelle **35 h** entre voyageurs et marchandises.
- Après la FIMO : carte de qualification, et première FCO **5 ans** plus tard.$mft$,
    $mft$FIMO 140 h en 4 thèmes avec évaluation finale, accès au métier dès 18 ans, équivalences (titre pro, CAP/bac pro conduite), passerelle 35 h entre spécialités et enchaînement vers la carte puis la FCO.$mft$,
    2, 35) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : La FCO : rester qualifié ────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'fco-rester-qualifie',
    'La FCO : rester qualifié tous les 5 ans',
    $mft$> 🎯 **Objectifs**
> - Planifier sa FCO sans jamais laisser expirer sa qualification.
> - Savoir quoi faire après une interruption d'activité.
> - Comprendre le contenu et le déroulement du stage.

## Le principe

La **formation continue obligatoire** (FCO) actualise les connaissances et la pratique : **35 heures** (une semaine), à renouveler **tous les 5 ans**, tant que l'on exerce. Elle reprend les quatre thèmes du référentiel en format condensé : bilan de conduite individuel, actualités réglementaires, sécurité, et retours d'expérience.

> 📌 **À retenir**
> L'échéance court à partir de la **délivrance de la qualification précédente** (FIMO, équivalence ou dernière FCO). La règle d'or du conducteur : connaître SA date. La règle d'or de l'employeur : tenir l'**échéancier de tous ses conducteurs** et programmer les stages 3 à 6 mois avant l'échéance.

## Conduire avec une FCO expirée

C'est conduire **sans qualification valide** : mêmes conséquences qu'au module précédent (amende, immobilisation possible, responsabilités aggravées), pour le conducteur ET pour l'employeur qui a laissé faire. La paie, le planning, rien ne justifie de « finir la semaine » avec une carte expirée.

## Le retour au métier après une interruption

Un conducteur qui a cessé l'activité et dont la qualification est **expirée** doit suivre une **FCO avant la reprise** : c'est la voie normale du retour au métier, quelle que soit la durée de l'interruption, tant que la qualification initiale (ou équivalence) a été détenue.

Exemple : Nadia a conduit jusqu'en 2019, sa FCO expirait en 2021 ; elle veut reprendre en 2026 : une **FCO de 35 h suffit** avant la reprise : pas de nouvelle FIMO.

## Le déroulement type d'une FCO

| Séquence | Contenu |
| --- | --- |
| Bilan | Conduite individuelle observée, axes de progrès |
| Thème 1 | Perfectionnement conduite rationnelle et sécurité |
| Thème 2 | Actualités réglementaires (temps de conduite, tachy, documents) |
| Thème 3 | Santé, sécurité routière et environnementale |
| Thème 4 | Service et image du métier |
| Évaluation | Acquis vérifiés en fin de stage |

> 💡 **Astuce**
> La FCO est finançable dans le plan de développement des compétences de l'entreprise (OPCO Mobilités pour la branche) : anticiper les échéances, c'est aussi lisser le budget et éviter d'immobiliser trois conducteurs le même mois.

## ✅ Synthèse

- FCO : **35 h tous les 5 ans**, échéance calculée depuis la dernière qualification.
- FCO expirée = conduite **sans qualification** : ni le conducteur ni l'employeur n'ont d'excuse.
- Retour au métier après interruption : **une FCO avant la reprise**, pas une nouvelle FIMO.$mft$,
    $mft$FCO 35 h tous les 5 ans, gestion des échéances côté conducteur et employeur, conséquences d'une FCO expirée et retour au métier après interruption par simple FCO.$mft$,
    3, 30) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : La carte de qualification ───────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'carte-de-qualification-conducteur',
    'La carte de qualification de conducteur (CQC)',
    $mft$> 🎯 **Objectifs**
> - Obtenir et renouveler sa carte de qualification.
> - Savoir quoi présenter en contrôle, et distinguer les trois « cartes » du conducteur.
> - Réagir en cas de perte ou de vol.

## Ce qu'est la carte

La **carte de qualification de conducteur** (CQC) matérialise la qualification : format carte bancaire, délivrée sur justification de la FIMO, d'une équivalence ou de la FCO. Sa validité suit la qualification : **5 ans**, renouvelée à chaque FCO.

Demande et renouvellement s'effectuent en ligne auprès de l'organisme national chargé des titres des conducteurs, justificatifs à l'appui (attestation de formation, permis, identité). Anticiper : la carte doit être disponible AVANT l'échéance pour enchaîner sans interruption.

## Les trois cartes du conducteur : ne plus confondre

| Carte | Rôle | Validité |
| --- | --- | --- |
| Permis de conduire | Droit de conduire la catégorie (C/CE) | 5 ans (visite médicale, avant 60 ans) |
| **Carte de qualification (CQC)** | Droit d'exercer le **métier** | 5 ans (FIMO/FCO) |
| Carte de conducteur (tachygraphe) | Enregistrer l'activité | 5 ans (renouvellement administratif) |

> ❌ **Piège à éviter**
> Trois cartes, trois échéances **différentes** qui ne tombent presque jamais en même temps. Le conducteur professionnel tient ses trois dates ; l'exploitant les tient pour toute la flotte. Une seule expirée = véhicule à l'arrêt.

## Au contrôle

Sur route, présenter : permis, **CQC**, carte conducteur insérée dans le tachygraphe, et les documents du transport (copie conforme de licence, lettre de voiture). Une CQC oubliée à la maison se régularise ; une CQC **expirée** est une infraction.

## Perte, vol, détérioration

Déclaration (perte/vol), demande de **duplicata** en ligne, attestation provisoire le cas échéant : prévenir aussi son employeur immédiatement. Rouler des semaines « en attendant » sans titre valide n'est pas une option.

## ✅ Synthèse

- CQC = la **preuve** de la qualification ; validité **5 ans**, renouvelée par la FCO, demande en ligne à anticiper.
- **Trois cartes, trois échéances** : permis, CQC, carte tachygraphe : l'échéancier est vital.
- Contrôle : permis + CQC + carte conducteur + documents transport ; duplicata immédiat en cas de perte.$mft$,
    $mft$La CQC (obtention, renouvellement 5 ans via FCO, demande en ligne), la distinction des trois cartes du conducteur et leurs échéances, la conduite à tenir en contrôle et en cas de perte.$mft$,
    4, 25) RETURNING id INTO v_l4;

  -- ─── Quiz d'entraînement ────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module,
    'Quiz : FIMO, FCO et carte de qualification',
    'Vérifiez le socle : qui doit être qualifié, FIMO, FCO et carte de qualification.',
    'entrainement', 70, false)
  RETURNING id INTO v_quiz;

  -- ─── QCM (12) : 4 faciles / 5 moyens / 3 difficiles ────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Quelle est la durée de la FIMO marchandises ?$mft$,
    $mft$[
      {"id":"a","label":"35 heures","is_correct":false},
      {"id":"b","label":"70 heures","is_correct":false},
      {"id":"c","label":"140 heures","is_correct":true},
      {"id":"d","label":"280 heures","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['fimo-fco','module-0','qcm-v1'], 'FIMO-M0-QCM-01', false,
    $mft$140 heures, environ quatre semaines, réparties sur les quatre thèmes du référentiel, avec évaluation finale. 35 h correspond à la FCO (et à la passerelle entre spécialités).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$À quelle fréquence et pour quelle durée la FCO doit-elle être suivie ?$mft$,
    $mft$[
      {"id":"a","label":"35 heures tous les 5 ans","is_correct":true},
      {"id":"b","label":"140 heures tous les 5 ans","is_correct":false},
      {"id":"c","label":"35 heures tous les 10 ans","is_correct":false},
      {"id":"d","label":"21 heures tous les 3 ans","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['fimo-fco','module-0','qcm-v1'], 'FIMO-M0-QCM-02', false,
    $mft$Une semaine de 35 heures tous les 5 ans, échéance calculée depuis la dernière qualification délivrée (FIMO, équivalence ou FCO précédente).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$La qualification de conducteur (FIMO/FCO) est obligatoire pour conduire, en transport de marchandises, les véhicules :$mft$,
    $mft$[
      {"id":"a","label":"De plus de 3,5 tonnes de PTAC","is_correct":true},
      {"id":"b","label":"De plus de 7,5 tonnes uniquement","is_correct":false},
      {"id":"c","label":"De plus de 12 tonnes uniquement","is_correct":false},
      {"id":"d","label":"De toutes les catégories, y compris les VUL","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['fimo-fco','module-0','qcm-v1'], 'FIMO-M0-QCM-03', false,
    $mft$Le champ suit les permis du groupe lourd (C1, C1E, C, CE) : plus de 3,5 t. Les VUL ≤ 3,5 t n'exigent pas la qualification (mais d'autres règles s'y appliquent).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Quelle est la durée de validité de la carte de qualification de conducteur ?$mft$,
    $mft$[
      {"id":"a","label":"2 ans","is_correct":false},
      {"id":"b","label":"5 ans","is_correct":true},
      {"id":"c","label":"10 ans","is_correct":false},
      {"id":"d","label":"Illimitée une fois obtenue","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['fimo-fco','module-0','qcm-v1'], 'FIMO-M0-QCM-04', false,
    $mft$5 ans, alignée sur le cycle des FCO : chaque FCO validée permet le renouvellement de la carte.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Grâce à la qualification initiale, à partir de quel âge peut-on conduire un poids lourd (permis C) à titre professionnel ?$mft$,
    $mft$[
      {"id":"a","label":"18 ans","is_correct":true},
      {"id":"b","label":"21 ans obligatoirement","is_correct":false},
      {"id":"c","label":"23 ans","is_correct":false},
      {"id":"d","label":"16 ans en apprentissage","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','module-0','qcm-v1'], 'FIMO-M0-QCM-05', false,
    $mft$La qualification initiale (FIMO ou titre professionnel) abaisse l'âge de conduite en C/CE à 18 ans, contre 21 ans sans qualification.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Un artisan plombier livre lui-même ses chantiers avec un 19 t, la conduite restant accessoire à son métier. Doit-il détenir la FIMO ?$mft$,
    $mft$[
      {"id":"a","label":"Non : le transport de matériel utilisé dans le cadre de son activité principale est exempté","is_correct":true},
      {"id":"b","label":"Oui, dès que le véhicule dépasse 3,5 t","is_correct":false},
      {"id":"c","label":"Oui, sauf s'il roule moins de 100 km par jour","is_correct":false},
      {"id":"d","label":"Non, car les artisans sont toujours exemptés de tout","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','module-0','qcm-v1'], 'FIMO-M0-QCM-06', false,
    $mft$Exemption du transport de matériel utilisé par le conducteur dans son activité principale, la conduite restant accessoire. Si la conduite devient l'activité principale (chauffeur-livreur), la qualification s'impose.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un conducteur déjà qualifié en transport de voyageurs veut passer au transport de marchandises. Que doit-il suivre ?$mft$,
    $mft$[
      {"id":"a","label":"Une FIMO complète de 140 heures","is_correct":false},
      {"id":"b","label":"Une passerelle raccourcie (35 heures) vers la nouvelle spécialité","is_correct":true},
      {"id":"c","label":"Rien : la qualification est commune aux deux spécialités","is_correct":false},
      {"id":"d","label":"Un simple test en ligne","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','module-0','qcm-v1'], 'FIMO-M0-QCM-07', false,
    $mft$La passerelle (35 h) couvre les spécificités de la nouvelle spécialité : le conducteur déjà qualifié ne refait pas le tronc commun des 140 h.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Après six ans sans conduire (FCO expirée depuis quatre ans), que doit faire un ancien conducteur pour reprendre le métier ?$mft$,
    $mft$[
      {"id":"a","label":"Suivre une FCO de 35 heures avant la reprise","is_correct":true},
      {"id":"b","label":"Repasser une FIMO complète de 140 heures","is_correct":false},
      {"id":"c","label":"Repasser le permis C","is_correct":false},
      {"id":"d","label":"Rien : la qualification est acquise à vie","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','module-0','qcm-v1'], 'FIMO-M0-QCM-08', false,
    $mft$Le retour au métier passe par une FCO avant la reprise, dès lors que la qualification initiale (ou équivalence) a été détenue : pas de nouvelle FIMO. Le permis reste soumis à sa propre validité médicale.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Lequel de ces titres dispense de passer la FIMO ?$mft$,
    $mft$[
      {"id":"a","label":"Le titre professionnel de conducteur du transport routier de marchandises","is_correct":true},
      {"id":"b","label":"Le permis CE obtenu depuis plus de 10 ans","is_correct":false},
      {"id":"c","label":"L'attestation de capacité de transport","is_correct":false},
      {"id":"d","label":"Le certificat ADR de base","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','module-0','qcm-v1'], 'FIMO-M0-QCM-09', false,
    $mft$Les diplômes et titres de conduite routière (titre pro, CAP/bac pro conducteur) valent qualification initiale. Le permis seul, l'attestation de capacité (gestionnaire) et l'ADR ne qualifient pas.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Lors d'un contrôle routier, quels titres personnels le conducteur professionnel doit-il pouvoir présenter ?$mft$,
    $mft$[
      {"id":"a","label":"Permis de conduire, carte de qualification (CQC) et carte de conducteur (tachygraphe)","is_correct":true},
      {"id":"b","label":"Uniquement son permis de conduire","is_correct":false},
      {"id":"c","label":"Sa carte d'identité et son contrat de travail","is_correct":false},
      {"id":"d","label":"Le Kbis de l'entreprise et la liasse fiscale","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['fimo-fco','module-0','qcm-v1'], 'FIMO-M0-QCM-10', false,
    $mft$Le triptyque du conducteur : permis (droit de conduire), CQC (droit d'exercer le métier), carte tachygraphe (traçabilité). S'y ajoutent les documents du véhicule et du transport (copie conforme, lettre de voiture).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Parmi ces conduites, laquelle EXIGE la qualification FIMO/FCO ?$mft$,
    $mft$[
      {"id":"a","label":"Un salarié embauché pour livrer les chantiers de son entreprise toute la journée en 19 t","is_correct":true},
      {"id":"b","label":"Un particulier qui déménage ses meubles avec un camion loué","is_correct":false},
      {"id":"c","label":"Un mécanicien qui convoie un camion pour essai après réparation","is_correct":false},
      {"id":"d","label":"Un pompier au volant d'un véhicule d'incendie","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['fimo-fco','module-0','qcm-v1'], 'FIMO-M0-QCM-11', false,
    $mft$Quand la conduite EST l'activité principale (chauffeur-livreur), la qualification s'impose. Usage privé, essais-atelier et services de secours sont exemptés.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$La FCO d'un conducteur expire le 15 du mois prochain ; son planning est complet. Que doit faire l'employeur ?$mft$,
    $mft$[
      {"id":"a","label":"Programmer la FCO avant l'échéance, quitte à réorganiser le planning : après le 15, le conducteur ne peut plus conduire","is_correct":true},
      {"id":"b","label":"Le laisser finir le mois : une tolérance de 30 jours existe","is_correct":false},
      {"id":"c","label":"Demander une dérogation à la DREAL","is_correct":false},
      {"id":"d","label":"Lui faire signer une décharge de responsabilité","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['fimo-fco','module-0','qcm-v1'], 'FIMO-M0-QCM-12', false,
    $mft$Aucune tolérance ni décharge : au lendemain de l'échéance, conduire est une infraction pour le conducteur et pour l'employeur. La seule bonne réponse est l'anticipation (échéancier 3-6 mois avant).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l2, 'qr',
   $mft$Combien d'heures dure la FIMO marchandises, et combien de thèmes couvre-t-elle ?$mft$,
   $mft$140 heures, couvrant les 4 thèmes du référentiel.$mft$,
   2, 'facile', ARRAY['fimo-fco','module-0','question-courte'], 'FIMO-M0-QC-01', false,
   $mft$Exiger la durée ; les 4 thèmes sont un plus attendu.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Donnez la durée et la périodicité de la FCO.$mft$,
   $mft$35 heures, tous les 5 ans.$mft$,
   2, 'facile', ARRAY['fimo-fco','module-0','question-courte'], 'FIMO-M0-QC-02', false,
   $mft$Les deux valeurs sont exigées.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$À partir de quel PTAC la qualification de conducteur est-elle exigée en transport de marchandises ?$mft$,
   $mft$Au-delà de 3,5 tonnes (permis du groupe lourd).$mft$,
   2, 'facile', ARRAY['fimo-fco','module-0','question-courte'], 'FIMO-M0-QC-03', false,
   $mft$Accepter « plus de 3,5 t ».$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Citez deux titres ou diplômes qui dispensent de passer la FIMO.$mft$,
   $mft$Le titre professionnel de conducteur du transport routier de marchandises et les diplômes de conduite routière (CAP ou bac pro conducteur).$mft$,
   2, 'moyen', ARRAY['fimo-fco','module-0','question-courte'], 'FIMO-M0-QC-04', false,
   $mft$Deux réponses parmi : titre pro conducteur, CAP conducteur routier, bac pro CTRM.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Comment s'appelle et combien dure la formation permettant à un conducteur voyageurs déjà qualifié de passer aux marchandises ?$mft$,
   $mft$La passerelle : 35 heures.$mft$,
   2, 'moyen', ARRAY['fimo-fco','module-0','question-courte'], 'FIMO-M0-QC-05', false,
   $mft$Fonctionne dans les deux sens (voyageurs ↔ marchandises).$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$À partir de quel événement se calcule l'échéance des 5 ans de la FCO ?$mft$,
   $mft$À partir de la délivrance de la dernière qualification (FIMO, équivalence ou FCO précédente).$mft$,
   2, 'moyen', ARRAY['fimo-fco','module-0','question-courte'], 'FIMO-M0-QC-06', false,
   $mft$L'idée clé : la date de la DERNIÈRE qualification, pas la date d'embauche.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Citez les trois titres personnels que le conducteur professionnel présente en contrôle routier.$mft$,
   $mft$Le permis de conduire, la carte de qualification de conducteur (CQC) et la carte de conducteur du chronotachygraphe.$mft$,
   2, 'moyen', ARRAY['fimo-fco','module-0','question-courte'], 'FIMO-M0-QC-07', false,
   $mft$Le triptyque du conducteur ; les documents du véhicule s'y ajoutent.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un conducteur dont la FCO a expiré il y a deux ans veut reprendre le métier : que doit-il suivre ?$mft$,
   $mft$Une FCO de 35 heures avant la reprise (pas de nouvelle FIMO).$mft$,
   2, 'moyen', ARRAY['fimo-fco','module-0','question-courte'], 'FIMO-M0-QC-08', false,
   $mft$La FIMO ne se repasse pas : la qualification initiale reste acquise.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Sans qualification initiale, à quel âge peut-on conduire en catégorie C ? Et avec la qualification ?$mft$,
   $mft$21 ans sans qualification ; 18 ans avec la qualification initiale (FIMO ou titre professionnel).$mft$,
   2, 'difficile', ARRAY['fimo-fco','module-0','question-courte'], 'FIMO-M0-QC-09', false,
   $mft$Les deux âges sont exigés, correctement appariés.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Un maçon livre occasionnellement ses propres chantiers en camion de 19 t : pourquoi est-il exempté de FIMO, et quand cesserait-il de l'être ?$mft$,
   $mft$Parce qu'il transporte le matériel utilisé dans le cadre de son activité principale, la conduite restant accessoire ; il cesserait de l'être si la conduite devenait son activité principale (chauffeur-livreur).$mft$,
   2, 'difficile', ARRAY['fimo-fco','module-0','question-courte'], 'FIMO-M0-QC-10', false,
   $mft$Exiger la condition (activité accessoire) ET sa limite.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Expliquez la différence entre le permis de conduire et la qualification professionnelle du conducteur, puis présentez les deux volets de cette qualification (initiale et continue).$mft$,
   $mft$Réponse modèle. Le permis (C1, C1E, C, CE) donne le droit de CONDUIRE un véhicule de la catégorie ; la qualification professionnelle donne le droit d'en faire son MÉTIER : transporter des marchandises pour le compte d'une entreprise avec un véhicule de plus de 3,5 t exige les deux, contrôlés ensemble. Volet initial : la FIMO (140 heures, quatre thèmes : conduite rationnelle et sécurité, réglementations, santé/sécurité routière et environnementale, service et logistique), avec évaluation finale ; des équivalences existent (titre professionnel de conducteur, CAP/bac pro conduite) et la qualification initiale abaisse l'âge d'accès en C/CE à 18 ans. Volet continu : la FCO, 35 heures tous les 5 ans, qui actualise connaissances et pratique et conditionne le renouvellement de la carte de qualification. La logique : un métier réglementé où la compétence se prouve à l'entrée puis s'entretient tout au long de la carrière.$mft$,
   $mft$Barème /5 : distinction permis/qualification claire (1,5 pt) ; FIMO 140 h + 4 thèmes + équivalences (1,5 pt) ; FCO 35 h / 5 ans et son rôle (1 pt) ; âge 18 ans ou logique d'ensemble (1 pt). Erreurs fréquentes : croire que le permis suffit ; confondre les durées 140/35.$mft$,
   5, 'facile', ARRAY['fimo-fco','module-0','question-redigee'], 'FIMO-M0-QR-01', false,
   $mft$Question de structuration du socle, posée à chaque session.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Karima, 34 ans, a obtenu sa FIMO en 2018 et sa dernière FCO en février 2022, puis a quitté le métier en 2024 pour une reconversion. Elle souhaite reprendre un poste de conductrice en septembre 2026. Analysez sa situation (qualification, carte, permis) et indiquez la marche à suivre.$mft$,
   $mft$Réponse modèle. Qualification : dernière FCO en février 2022 : validité jusqu'en février 2027 : en septembre 2026, sa qualification est ENCORE VALIDE : aucune formation n'est juridiquement exigée pour reprendre ; prudence toutefois : son échéance arrive dans six mois : programmer la prochaine FCO avant février 2027 dès la reprise. Carte de qualification : vérifier sa validité (alignée sur la FCO 2022) et son état ; en cas de perte pendant l'interruption : demande de duplicata en ligne avant la prise de poste. Permis : le permis C reste soumis à sa validité propre (visite médicale, 5 ans avant 60 ans) : vérifier la date et refaire la visite médicale si expirée : c'est le point le plus souvent oublié après une interruption. Marche à suivre : 1) contrôler les trois échéances (permis/visite médicale, CQC, carte tachygraphe) ; 2) régulariser ce qui est expiré (visite médicale probable) ; 3) reprendre, en planifiant la FCO avant février 2027. Si la reprise avait eu lieu APRÈS février 2027 : une FCO de 35 h préalable aurait suffi (jamais de nouvelle FIMO).$mft$,
   $mft$Barème /5 : calcul correct de la validité (février 2022 + 5 ans = février 2027, donc valide en septembre 2026) (2 pts) ; réflexe des trois titres dont la visite médicale du permis (1,5 pt) ; planification de la FCO avant l'échéance (0,75 pt) ; règle du retour après expiration (FCO, pas FIMO) (0,75 pt). Erreurs fréquentes : imposer une FCO immédiate alors que la qualification court ; oublier le permis.$mft$,
   5, 'facile', ARRAY['fimo-fco','module-0','question-redigee'], 'FIMO-M0-QR-02', false,
   $mft$Cas de reprise avec calcul d'échéance : la nuance « encore valide » piège la moitié des candidats.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Vous gérez 14 conducteurs. Concevez le système de suivi des qualifications et des titres : informations à suivre, organisation des échéances, règles internes en cas d'expiration imminente.$mft$,
   $mft$Réponse modèle. Informations par conducteur : date et nature de la qualification (FIMO/équivalence), date de la dernière FCO et échéance des 5 ans ; validité de la carte de qualification ; validité du permis et date de la prochaine visite médicale (5/2/1 ans selon l'âge) ; carte de conducteur tachygraphe (5 ans) ; le cas échéant ADR et CACES. Organisation : tableau unique (ou module RH) avec alertes à J-180, J-90 et J-30 ; revue mensuelle en réunion d'exploitation ; programmation des FCO par vagues lissées sur l'année (éviter trois conducteurs en stage le même mois) et arbitrées avec les plannings et le budget formation (OPCO) ; copie des titres au dossier, mise à jour à chaque renouvellement. Règles internes : à J-90 sans stage programmé : escalade au responsable ; à J-30 : blocage de toute affectation au-delà de l'échéance ; au lendemain de l'échéance : retrait de la conduite, sans exception ni « décharge » ; à l'embauche : vérification des originaux et des échéances AVANT la prise de poste. Indicateur : zéro jour de conduite avec titre expiré : c'est un indicateur de conformité, pas un objectif souple.$mft$,
   $mft$Barème /5 : exhaustivité des titres suivis (qualification, CQC, permis/visite, carte tachy) (1,5 pt) ; mécanique d'alertes échelonnées et lissage des stages (1,5 pt) ; règles internes fermes avec blocage à l'échéance (1,5 pt) ; contrôle à l'embauche (0,5 pt). Erreurs fréquentes : suivre la seule FCO en oubliant permis/visite médicale ; tolérances de fait après l'échéance.$mft$,
   5, 'moyen', ARRAY['fimo-fco','module-0','question-redigee'], 'FIMO-M0-QR-03', false,
   $mft$Organisation d'un échéancier de flotte : la question « employeur » du module.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Trois candidats veulent devenir conducteurs poids lourd : Lucas, 18 ans, sans expérience ; Sonia, 28 ans, conductrice de car qualifiée voyageurs ; Marc, 41 ans, titulaire du permis CE depuis 2010 mais qui n'a jamais exercé. Indiquez pour chacun la voie d'accès adaptée et sa durée.$mft$,
   $mft$Réponse modèle. Lucas (18 ans, débutant) : deux voies : la FIMO marchandises (140 h) après ou avec l'obtention du permis C : voie rapide ; ou le titre professionnel de conducteur (plus long, souvent en alternance) qui vaut qualification initiale ET diplôme : recommandé à 18 ans pour l'employabilité ; dans les deux cas, la qualification initiale lui permet de conduire dès 18 ans. Sonia (qualifiée voyageurs) : elle détient déjà une qualification initiale : une PASSERELLE de 35 heures vers les marchandises suffit (pas de FIMO complète), sous réserve de détenir ou passer le permis C/CE (elle a le D : le C s'ajoute). Marc (permis CE ancien, jamais exercé) : le permis seul ne qualifie pas : il lui faut la qualification initiale complète : FIMO 140 heures (ou titre pro) ; son ancien permis reste valable sous réserve de la visite médicale à jour. Synthèse : la voie dépend de la QUALIFICATION déjà détenue, pas de l'ancienneté du permis.$mft$,
   $mft$Barème /5 : Lucas : FIMO ou titre pro + accès à 18 ans (1,5 pt) ; Sonia : passerelle 35 h + question du permis C (1,5 pt) ; Marc : FIMO complète malgré le permis ancien + visite médicale (1,5 pt) ; conclusion « la qualification prime sur le permis » (0,5 pt). Erreurs fréquentes : dispenser Marc au motif de l'ancienneté du permis ; imposer 140 h à Sonia.$mft$,
   5, 'moyen', ARRAY['fimo-fco','module-0','question-redigee'], 'FIMO-M0-QR-04', false,
   $mft$Trois profils, trois voies : l'exercice d'orientation type.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Votre entreprise de BTP possède deux camions de 26 t. Le chef d'équipe les conduit occasionnellement pour approvisionner ses chantiers ; vous envisagez aussi d'embaucher un chauffeur dédié aux livraisons inter-chantiers. Analysez l'obligation de qualification pour chacun et les risques d'une mauvaise appréciation.$mft$,
   $mft$Réponse modèle. Chef d'équipe : il transporte du matériel utilisé dans le cadre de son activité principale (le chantier), la conduite restant accessoire : EXEMPTÉ de FIMO/FCO, tant que ces conditions demeurent (fréquence faible, pas de transport pour autrui) ; son permis C et la visite médicale restent bien sûr exigés, ainsi que les règles du chronotachygraphe selon les trajets. Chauffeur dédié : la conduite EST son activité principale : qualification OBLIGATOIRE (FIMO ou équivalence, puis FCO), carte de qualification à vérifier à l'embauche. Risques d'une mauvaise appréciation : faire glisser le chef d'équipe vers un mi-temps de livraison (l'exemption tombe : requalification en conduite professionnelle non qualifiée) ; embaucher le chauffeur sans vérifier la CQC (infraction dès le premier trajet : amendes conducteur et entreprise, immobilisation possible, responsabilité aggravée en cas d'accident, malus assurantiel). Bonne pratique : décrire la part de conduite dans les fiches de poste, revoir l'analyse à chaque évolution des tournées, et documenter la vérification des titres à l'embauche.$mft$,
   $mft$Barème /5 : exemption du chef d'équipe correctement conditionnée (1,5 pt) ; obligation pleine pour le chauffeur dédié avec vérification à l'embauche (1,5 pt) ; risques du glissement d'activité et du défaut de vérification (1,5 pt) ; bonnes pratiques documentaires (0,5 pt). Erreurs fréquentes : exemption « BTP » globale ; ignorer que l'exemption dépend de la part réelle de conduite.$mft$,
   5, 'moyen', ARRAY['fimo-fco','module-0','question-redigee'], 'FIMO-M0-QR-05', false,
   $mft$Cas frontière de l'exemption « activité accessoire », très fréquent en PME.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Lors d'un contrôle, un de vos conducteurs présente un permis valide mais une carte de qualification expirée depuis trois semaines ; il affirme que « la FCO est réservée le mois prochain ». Analysez la situation côté conducteur et côté entreprise, et décrivez ce qui aurait dû se passer.$mft$,
   $mft$Réponse modèle. Situation : la réservation d'un stage ne vaut pas qualification : depuis trois semaines, ce conducteur conduit SANS qualification valide : infraction constituée à chaque service. Côté conducteur : amende, immobilisation possible du véhicule, et sa responsabilité en cas d'accident serait examinée sévèrement. Côté entreprise : amende également (elle a laissé conduire un salarié non qualifié), désorganisation immédiate (le véhicule ne repart qu'avec un conducteur en règle), image auprès du client du chargement en cours, signalement possible ; la « bonne foi » (stage réservé) atténue moralement mais n'efface pas l'infraction. Ce qui aurait dû se passer : l'échéancier aurait déclenché des alertes à J-180/J-90/J-30 ; la FCO devait être PROGRAMMÉE AVANT l'échéance ; à défaut, au lendemain de l'expiration : retrait de la conduite et réaffectation (quai, navette interne non soumise, congés) jusqu'au stage. Suites : régulariser (FCO au plus tôt, demande de carte), analyser la défaillance de suivi (pourquoi l'alerte a manqué), corriger le processus, et informer les conducteurs : une carte expirée immobilise, sans négociation.$mft$,
   $mft$Barème /5 : « réservé » ≠ qualifié, infraction continue (1,5 pt) ; conséquences des deux côtés (1,5 pt) ; le processus correct (alertes, programmation avant échéance, retrait de la conduite) (1,5 pt) ; suites correctives (0,5 pt). Erreurs fréquentes : accorder une tolérance de fait ; ne sanctionner que le conducteur en oubliant la défaillance d'organisation.$mft$,
   5, 'difficile', ARRAY['fimo-fco','module-0','question-redigee'], 'FIMO-M0-QR-06', false,
   $mft$Cas de contrôle avec CQC expirée : responsabilités croisées et processus.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Votre PME peine à recruter des conducteurs. Construisez une stratégie de sourcing s'appuyant sur les dispositifs de qualification : profils cibles, parcours de formation mobilisables, financements, et points de vigilance.$mft$,
   $mft$Réponse modèle. Profils et parcours : 1) jeunes dès 18 ans : titre professionnel de conducteur (qualification + diplôme) en alternance ou POEI, vivier durable ; 2) demandeurs d'emploi en reconversion : permis C/CE + FIMO (140 h) financés (France Travail, régions), opérationnels en quelques mois ; 3) conducteurs voyageurs souhaitant changer de spécialité : passerelle 35 h : délai très court ; 4) anciens conducteurs éloignés du métier : simple FCO de 35 h avant reprise : le vivier le plus rapide et le plus sous-estimé ; 5) salariés internes volontaires (caristes, magasiniers) : promotion interne via permis + FIMO, fidélisation forte. Financements : plan de développement des compétences et OPCO Mobilités, aides à l'embauche selon dispositifs, POEI/AFPR pour les demandeurs d'emploi, CPF des candidats (permis, FIMO éligibles selon droits). Points de vigilance : vérifier systématiquement titres et échéances à l'embauche ; anticiper les délais (places de stage, cartes) ; accompagner les débutants (tutorat, montée en charge progressive) ; l'exemption « accessoire » ne fabrique pas des chauffeurs : pas de bricolage avec des non-qualifiés. Une PME qui maîtrise ces parcours recrute là où les autres attendent le candidat idéal.$mft$,
   $mft$Barème /5 : au moins quatre viviers avec le bon parcours chacun (2,5 pts) ; financements pertinents cités (1 pt) ; vigilance vérification des titres et délais (1 pt) ; accompagnement des débutants (0,5 pt). Erreurs fréquentes : tout miser sur l'annonce classique ; oublier la passerelle et le retour par FCO.$mft$,
   5, 'difficile', ARRAY['fimo-fco','module-0','question-redigee'], 'FIMO-M0-QR-07', false,
   $mft$Stratégie RH fondée sur les parcours de qualification : vision employeur.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Rédigez la procédure interne « titres du conducteur » de votre entreprise, de l'embauche au renouvellement, en dix points maximum, prête à être affichée en exploitation.$mft$,
   $mft$Réponse modèle (procédure type). 1) Avant toute embauche : contrôle des originaux : permis + visite médicale, carte de qualification, carte de conducteur ; copies datées au dossier. 2) Aucune prise de poste sans les trois titres valides : la promesse d'embauche le mentionne. 3) Saisie des échéances dans l'échéancier partagé (RH + exploitation) le jour de l'arrivée. 4) Alertes automatiques à J-180, J-90, J-30 avant chaque échéance. 5) À J-90 : stage FCO ou visite médicale PROGRAMMÉS, convocation remise au conducteur. 6) À J-30 sans programmation : escalade direction, blocage des affectations au-delà de l'échéance. 7) Lendemain d'une échéance dépassée : retrait immédiat de la conduite, réaffectation temporaire, aucune exception. 8) Perte ou vol d'un titre : déclaration et demande de duplicata sous 48 h, information de l'exploitation. 9) Retour d'un conducteur après absence longue : re-contrôle complet des trois titres avant reprise. 10) Revue mensuelle de l'échéancier en réunion d'exploitation ; indicateur affiché : zéro jour de conduite avec titre expiré. Chaque étape a un responsable nommé (RH ou exploitation) et laisse une trace écrite.$mft$,
   $mft$Barème /5 : contrôle à l'embauche avec originaux (1 pt) ; mécanique d'alertes et de programmation anticipée (1,5 pt) ; règle de blocage sans exception à l'échéance (1 pt) ; cas particuliers (perte, retour d'absence) (1 pt) ; responsabilités et traçabilité (0,5 pt). Erreurs fréquentes : procédure sans responsable désigné ; oublier la visite médicale du permis.$mft$,
   5, 'difficile', ARRAY['fimo-fco','module-0','question-redigee'], 'FIMO-M0-QR-08', false,
   $mft$Livrable opérationnel : la procédure interne complète en 10 points.$mft$);

  RAISE NOTICE 'Module 0 FIMO/FCO créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $fimo0$;

-- =====================================================================
-- CONTRÔLES POST-EXÉCUTION
-- =====================================================================
-- 1) Volumes : select "type", active, count(*) from question_bank
--     where source_ref like 'FIMO-M0-%' group by 1, 2;
--    → attendu : qcm/false = 12, qr/false = 18.
-- 2) QCM à bonne réponse unique :
--    select source_ref from question_bank
--     where source_ref like 'FIMO-M0-QCM-%'
--       and (select count(*) from jsonb_array_elements(choices) c
--             where (c->>'is_correct')::boolean) <> 1;   → 0 ligne.
-- 3) Doublons d'énoncés sur la formation :
--    select statement, count(*) from question_bank
--     where formation_id = (select id from formations where slug='fimo-fco')
--     group by 1 having count(*) > 1;                    → 0 ligne.
