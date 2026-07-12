-- =====================================================================
-- CAPACITÉ DE TRANSPORT > 3,5 T (LOURD) — MODULE H : SÉCURITÉ ROUTIÈRE
-- v1 (juillet 2026) — LOT 8
--
-- Domaine H de l'annexe I du règlement (CE) n° 1071/2009 : permis du
-- groupe lourd et aptitude, règles de circulation des PL (vitesses,
-- restrictions), alcool/stupéfiants et comportements, prévention des
-- accidents du travail et protocole de sécurité.
-- Références : code de la route (vitesses, permis), code du travail
-- (DUERP, protocole de sécurité R. 4515-x), code de la sécurité sociale
-- (déclaration AT).
--
-- ⚠ STATUT : questions insérées avec active = false (« à valider »).
-- Idempotent : DELETE ciblés par slug/source_ref, rejouable sans doublon.
-- =====================================================================

DO $capah$
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
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'capacite-plus-3-5t';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation capacite-plus-3-5t introuvable.';
  END IF;

  INSERT INTO public.blocs (id, code, title, description, "order")
  VALUES (30, 'CAPA-LOURD', 'Capacité de transport lourd > 3,5 t',
          'Programme officiel de l''examen d''attestation de capacité professionnelle en transport routier lourd de marchandises (annexe I du règlement CE 1071/2009).', 30)
  ON CONFLICT DO NOTHING;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'CAPA-LOURD';

  DELETE FROM public.question_bank WHERE source_ref LIKE 'CAPA-LOURD-H-%';
  DELETE FROM public.modules WHERE slug = 'capa-lourd-securite-routiere';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Module H — Sécurité routière',
    'capa-lourd-securite-routiere',
    v_bloc,
    'Le conducteur et la route : permis du groupe lourd et aptitude médicale, vitesses et restrictions de circulation des PL, alcool et stupéfiants, prévention des accidents du travail et protocole de sécurité chargement/déchargement.',
    'intermediaire',
    480,
    80
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 80, true);

  -- ─── Leçon 1 — Le conducteur et son permis ─────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'permis-groupe-lourd-aptitude',
    'Le permis du groupe lourd et l''aptitude du conducteur',
    $mft$> 🎯 **Objectifs**
> - Associer chaque catégorie de permis au bon véhicule.
> - Suivre la validité des permis et les visites médicales.
> - Mesurer l'impact du permis à points sur l'exploitation.

## Les catégories du groupe lourd

| Catégorie | Véhicules | Âge minimal |
| --- | --- | --- |
| C1 | 3,5 à 7,5 t (remorque ≤ 750 kg) | 18 ans |
| C1E | C1 + remorque > 750 kg (ensemble ≤ 12 t) | 18 ans |
| **C** | > 3,5 t (remorque ≤ 750 kg) | 21 ans, **18 ans** avec qualification initiale (FIMO ou titre pro conducteur) |
| **CE** | Véhicule C + remorque ou semi-remorque > 750 kg | 21 ans, 18 ans avec qualification initiale |

La conduite professionnelle exige en outre la **carte de qualification** (FIMO/FCO, module C) et la **carte de conducteur** (chronotachygraphe).

## Validité et aptitude médicale

Le permis du groupe lourd est délivré pour une durée limitée, subordonnée à une **visite médicale** (médecin agréé) :

> 📌 **À retenir**
> - Avant 60 ans : validité **5 ans**.
> - De 60 à 76 ans : validité **2 ans**.
> - Après 76 ans : validité **1 an**.
> Un permis lourd expiré = conduite sans permis valide : l'échéancier des visites médicales fait partie du suivi RH des conducteurs, au même titre que la CQC.

## Le permis à points

Capital de **12 points** (6 en période probatoire). Les infractions retirent de 1 à 6 points ; le retrait total invalide le permis. Enjeux d'exploitation :

- un conducteur professionnel « consomme » ses points sur la route toute la journée : sensibiliser (vitesses, téléphone, interdistances) ;
- l'employeur a l'obligation de **désigner** le conducteur auteur d'une infraction relevée par radar sur un véhicule de l'entreprise (à défaut : amende pour non-désignation) ;
- la perte du permis d'un conducteur désorganise l'exploitation (module C : reclassement, procédure).

> ⚠️ **Attention**
> Ne jamais « couvrir » un salarié en payant l'amende sans désignation : l'entreprise s'expose à une contravention spécifique de non-désignation, et la pratique fausse la prévention.

## ✅ Synthèse

- **C** : > 3,5 t ; **CE** : avec remorque/semi > 750 kg ; **18 ans possibles** avec qualification initiale.
- Visites médicales : **5 ans / 2 ans / 1 an** selon l'âge ; échéancier obligatoire.
- **12 points** ; obligation de **désignation** des conducteurs par l'entreprise.$mft$,
    $mft$Catégories C1/C1E/C/CE avec âges (18 ans si qualification), validité médicale 5/2/1 ans selon l'âge, permis à 12 points et obligation de désignation par l'employeur.$mft$,
    1, 40) RETURNING id INTO v_l1;

  -- ─── Leçon 2 — Vitesses et restrictions de circulation ─────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'vitesses-restrictions-circulation-pl',
    'Circuler en poids lourd : vitesses et restrictions',
    $mft$> 🎯 **Objectifs**
> - Restituer les vitesses maximales des PL selon le réseau.
> - Planifier avec les interdictions de circulation (week-ends, fériés).
> - Intégrer les règles spécifiques : interdistances, angles morts, hiver.

## Les vitesses maximales des véhicules > 3,5 t

| Réseau | Vitesse maximale |
| --- | --- |
| Autoroute | **90 km/h** |
| Route à deux chaussées séparées | **80 km/h** |
| Autres routes hors agglomération | **80 km/h** |
| Agglomération | **50 km/h** |

Des limitations plus basses s'appliquent à certains transports (matières dangereuses) et par signalisation locale. Le **limiteur** est réglé à 90 km/h (module G).

## Les interdictions générales de circulation

Les véhicules de transport de marchandises de **plus de 7,5 t** de PTAC sont interdits de circulation :

> 📌 **À retenir**
> Du **samedi 22 h au dimanche 22 h**, et de **la veille de jour férié 22 h au jour férié 22 h**, sur l'ensemble du réseau. Des interdictions complémentaires s'ajoutent (périodes de grands départs, itinéraires, agglomérations).

**Dérogations** : certaines existent de plein droit (notamment denrées et produits périssables, sous conditions) ; d'autres sur **autorisation préfectorale** (dérogations exceptionnelles). L'exploitant qui planifie une tournée de week-end vérifie AVANT d'engager le voyage.

## Les règles spécifiques au poids lourd

- **Interdistance** : hors agglomération, maintenir un intervalle d'au moins **50 mètres** entre véhicules lourds.
- **Angles morts** : signalisation obligatoire (autocollants réglementaires) sur les véhicules lourds ; vigilance renforcée vis-à-vis des cyclistes et piétons en ville : c'est l'un des premiers facteurs d'accidents graves en zone urbaine.
- **Dépassements** : interdictions spécifiques par panneaux (PL), forte pluie, chaussées à trois voies.
- **Équipements hivernaux** : en période hivernale, obligations de chaînes ou pneus hiver dans les zones de montagne définies (loi Montagne) : anticiper l'équipement des véhicules qui desservent ces massifs.

> 💡 **Astuce**
> Les interdictions et dérogations se gèrent au **planning**, jamais dans la cabine : un conducteur bloqué le samedi soir à 22 h avec un chargement non dérogatoire, ce sont des heures perdues, un client mécontent et un risque d'infraction : l'exploitation porte cette responsabilité.

## ✅ Synthèse

- Vitesses PL : **90 autoroute / 80 routes / 50 agglo**.
- **> 7,5 t : interdit du samedi 22 h au dimanche 22 h** (+ fériés) ; dérogations denrées périssables ou préfectorales.
- **50 m** d'interdistance entre PL hors agglo ; **angles morts** signalés ; équipements **hiver** en zones de montagne.$mft$,
    $mft$Vitesses PL (90/80/80/50), interdictions de circulation > 7,5 t (samedi 22 h → dimanche 22 h, fériés) et dérogations, interdistance 50 m, signalisation des angles morts, obligations hivernales.$mft$,
    2, 40) RETURNING id INTO v_l2;

  -- ─── Leçon 3 — Alcool, stupéfiants, comportements ──────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'alcool-stupefiants-comportements',
    'Alcool, stupéfiants et comportements à risque',
    $mft$> 🎯 **Objectifs**
> - Connaître les seuils d'alcoolémie et le régime des stupéfiants.
> - Chiffrer les sanctions des comportements à risque au volant.
> - Définir le rôle de prévention de l'employeur.

## L'alcool au volant

| Situation | Seuil |
| --- | --- |
| Contravention | À partir de **0,5 g/L de sang** (0,25 mg/L d'air expiré) |
| Délit | À partir de **0,8 g/L de sang** (0,40 mg/L d'air) |

Sanctions : retrait de **6 points**, amende, suspension de permis ; en délit : jusqu'à l'annulation, peines complémentaires, et conséquences professionnelles en cascade (module C : impossibilité d'exécuter le contrat).

> ❌ **Piège à éviter**
> Le seuil abaissé à 0,2 g/L concerne les conducteurs de **transport en commun de personnes** et les permis probatoires : pour le transport de marchandises, le seuil contraventionnel reste 0,5 g/L : question piège classique.

## Les stupéfiants : tolérance zéro

Toute conduite après usage de stupéfiants est un **délit**, quel que soit le dosage : dépistage salivaire possible lors des contrôles, retrait de 6 points, fortes amendes, suspension/annulation, aggravation en cas de cumul avec l'alcool. Certains traitements médicamenteux (pictogrammes niveaux 2 et 3) imposent avis médical avant la conduite professionnelle.

## Les autres comportements sanctionnés

- **Téléphone tenu en main** : amende de 4e classe (135 €) et **retrait de 3 points** ; kit main libre à oreillette également interdit ; le smartphone posé sur le siège est l'ennemi numéro un de l'attention.
- **Fatigue** : pas d'éthylotest pour elle, mais un rôle direct dans les accidents de PL : le respect des temps de conduite et de repos (module C) est une mesure de sécurité, pas une contrainte administrative.
- **Vitesse** : retraits de 1 à 6 points selon le dépassement, avec les vitesses PL spécifiques (leçon 2).

## Le rôle de l'employeur

L'entreprise ne peut pas se contenter de « faire confiance » :

:::flow
1. Prévenir | Règlement intérieur : alcool/stupéfiants interdits, contrôles prévus
2. Organiser | Plannings réalistes, pauses, pas d'incitation à la vitesse
3. Détecter | Éthylotests dans le cadre fixé par le règlement intérieur, vigilance managériale
4. Réagir | Retrait de la conduite, procédure adaptée, accompagnement
:::

Un accident causé par un conducteur alcoolisé dont l'employeur tolérait les dérives engage la responsabilité de l'entreprise (organisation fautive) et pèse sur l'**honorabilité** (module F). Le règlement intérieur, les causeries sécurité et la traçabilité des actions de prévention sont les preuves de diligence de l'exploitant.

## ✅ Synthèse

- Alcool : **0,5 g/L** contravention (6 points), **0,8 g/L** délit ; marchandises ≠ 0,2 g/L (transport de personnes).
- Stupéfiants : **délit, tolérance zéro** ; médicaments à pictogrammes : avis médical.
- Téléphone tenu en main : **135 € + 3 points**.
- Employeur : règlement intérieur, organisation réaliste, contrôles encadrés, réaction tracée.$mft$,
    $mft$Seuils alcool 0,5/0,8 g/L (piège du 0,2 réservé au transport de personnes), stupéfiants = délit tolérance zéro, téléphone 135 € + 3 points, et rôle de prévention encadré de l'employeur.$mft$,
    3, 40) RETURNING id INTO v_l3;

  -- ─── Leçon 4 — Accidents du travail et protocole de sécurité ───────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'accidents-travail-protocole-securite',
    'Prévenir les accidents du travail : le protocole de sécurité',
    $mft$> 🎯 **Objectifs**
> - Identifier les risques professionnels majeurs du transport.
> - Rédiger et faire vivre un protocole de sécurité de chargement/déchargement.
> - Réagir correctement à un accident (route et travail).

## La sinistralité du transport

Le transport routier est l'un des secteurs les plus accidentogènes : **chutes** de cabine ou de hayon (descendre face aux marches, trois points d'appui), **manutentions** (TMS, transpalettes), **écrasements à quai**, risque routier (première cause de mortalité au travail tous secteurs confondus). L'employeur évalue ces risques dans le **DUERP** (document unique d'évaluation des risques professionnels), obligatoire et tenu à jour.

## Le protocole de sécurité

Pour toute opération de **chargement ou de déchargement** réalisée par un transporteur dans une entreprise d'accueil, un **protocole de sécurité** écrit est établi entre les deux entreprises (code du travail).

> 📌 **À retenir**
> Le protocole de sécurité remplace le plan de prévention pour ces opérations. Il contient notamment :
> - côté **entreprise d'accueil** : consignes de sécurité du site, lieux de livraison, modalités d'accès et de stationnement, matériels et engins utilisés, moyens de secours ;
> - côté **transporteur** : caractéristiques du véhicule et de son aménagement, nature et conditionnement de la marchandise, précautions particulières.
> Pour les opérations **répétitives** chez un même client, un protocole unique établi à l'avance suffit, tant que les conditions ne changent pas.

Sans protocole, en cas d'accident du conducteur sur le site (chute de quai, engin), la carence documentaire pèse lourdement sur les deux entreprises.

## Réagir à un accident

**Sur la route (PAS)** :

:::timeline
1. **Protéger** — allumer les feux de détresse, gilet, triangle à distance utile, couper le contact, protéger la zone.
2. **Alerter** — 112 (ou 15/17/18), localisation précise (PK autoroute), nature des blessures, risques (matières dangereuses : consignes écrites ADR).
3. **Secourir** — gestes de premiers secours dans la limite de ses compétences, ne pas déplacer un blessé sauf danger immédiat.
:::

Ensuite : constat amiable précis (croquis, réserves), photos, déclaration à l'assureur dans les délais contractuels, information de l'exploitation.

**Accident du travail** : le salarié informe l'employeur sous 24 h sauf impossibilité ; l'employeur **déclare l'AT à la CPAM dans les 48 heures** (hors dimanches et jours fériés), avec réserves motivées le cas échéant ; registre et analyse de l'accident (arbre des causes) pour éviter la répétition. La reconnaissance d'une **faute inexcusable** (risque connu, mesures non prises) majore lourdement les conséquences financières pour l'employeur.

## Piloter la prévention

Indicateurs : **taux de fréquence** et **taux de gravité** des AT, sinistralité matérielle par conducteur/ligne, presqu'accidents remontés. Actions : accueil sécurité des nouveaux, causeries régulières, EPI adaptés (gants, chaussures, gilet), entretien des hayons et transpalettes, télématique d'aide à la conduite, formation post-accident.

## ✅ Synthèse

- Risques majeurs : **chutes, manutention, quai, route** ; DUERP obligatoire et vivant.
- **Protocole de sécurité** écrit pour tout chargement/déchargement en entreprise d'accueil ; version « répétitive » pour les clients réguliers.
- Route : **Protéger, Alerter, Secourir** ; AT : salarié 24 h, **employeur 48 h** à la CPAM ; faute inexcusable = addition très lourde.$mft$,
    $mft$Sinistralité du secteur et DUERP, protocole de sécurité chargement/déchargement (contenu des deux parties, cas répétitif), conduite à tenir PAS, déclaration AT sous 48 h et faute inexcusable, indicateurs TF/TG.$mft$,
    4, 45) RETURNING id INTO v_l4;

  -- ─── Quiz d'entraînement ────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module,
    'Quiz — Sécurité routière',
    'Validez les fondamentaux du module H : permis, vitesses, alcool et stupéfiants, protocole de sécurité et accidents du travail.',
    'entrainement', 70, false)
  RETURNING id INTO v_quiz;

  -- ─── QCM (12) — 4 faciles / 5 moyens / 3 difficiles ────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Quel permis est exigé pour conduire un ensemble tracteur + semi-remorque de 44 tonnes ?$mft$,
    $mft$[
      {"id":"a","label":"Permis C","is_correct":false},
      {"id":"b","label":"Permis CE","is_correct":true},
      {"id":"c","label":"Permis C1E","is_correct":false},
      {"id":"d","label":"Permis BE","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-h','qcm-v1'], 'CAPA-LOURD-H-QCM-01', false,
    $mft$CE = véhicule de catégorie C attelé d'une remorque ou semi-remorque de plus de 750 kg. Le permis C seul limite la remorque à 750 kg.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$À partir de quel taux d'alcool dans le sang la conduite devient-elle un délit ?$mft$,
    $mft$[
      {"id":"a","label":"0,2 g/L","is_correct":false},
      {"id":"b","label":"0,5 g/L","is_correct":false},
      {"id":"c","label":"0,8 g/L","is_correct":true},
      {"id":"d","label":"1,2 g/L","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-h','qcm-v1'], 'CAPA-LOURD-H-QCM-02', false,
    $mft$0,5 g/L = contravention (6 points) ; 0,8 g/L = délit (tribunal, annulation possible). Le 0,2 g/L vise le transport en commun de personnes et les permis probatoires.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Quelle est la vitesse maximale d'un véhicule de plus de 3,5 t sur autoroute ?$mft$,
    $mft$[
      {"id":"a","label":"80 km/h","is_correct":false},
      {"id":"b","label":"90 km/h","is_correct":true},
      {"id":"c","label":"100 km/h","is_correct":false},
      {"id":"d","label":"110 km/h","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-h','qcm-v1'], 'CAPA-LOURD-H-QCM-03', false,
    $mft$90 km/h sur autoroute (cohérent avec le limiteur), 80 km/h sur les autres routes, 50 km/h en agglomération.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$De combien de points dispose un permis de conduire (hors période probatoire) ?$mft$,
    $mft$[
      {"id":"a","label":"6 points","is_correct":false},
      {"id":"b","label":"10 points","is_correct":false},
      {"id":"c","label":"12 points","is_correct":true},
      {"id":"d","label":"15 points","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-h','qcm-v1'], 'CAPA-LOURD-H-QCM-04', false,
    $mft$12 points (6 en probatoire). Le retrait total invalide le permis : suivi et sensibilisation indispensables pour des conducteurs professionnels.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Quelle est la durée de validité du permis C/CE pour un conducteur de moins de 60 ans ?$mft$,
    $mft$[
      {"id":"a","label":"1 an","is_correct":false},
      {"id":"b","label":"2 ans","is_correct":false},
      {"id":"c","label":"5 ans","is_correct":true},
      {"id":"d","label":"15 ans","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-h','qcm-v1'], 'CAPA-LOURD-H-QCM-05', false,
    $mft$5 ans avant 60 ans, 2 ans de 60 à 76 ans, 1 an après 76 ans : validité subordonnée à la visite médicale auprès d'un médecin agréé.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Quand s'applique l'interdiction générale de circulation des véhicules de plus de 7,5 t ?$mft$,
    $mft$[
      {"id":"a","label":"Du samedi 22 h au dimanche 22 h, et les veilles de jours fériés 22 h aux jours fériés 22 h","is_correct":true},
      {"id":"b","label":"Du vendredi 20 h au lundi 6 h","is_correct":false},
      {"id":"c","label":"Uniquement les jours fériés de 8 h à 20 h","is_correct":false},
      {"id":"d","label":"Tous les dimanches de 6 h à 12 h","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-h','qcm-v1'], 'CAPA-LOURD-H-QCM-06', false,
    $mft$Samedi (ou veille de férié) 22 h → dimanche (ou férié) 22 h. Dérogations : denrées périssables (de plein droit, sous conditions) ou autorisations préfectorales exceptionnelles.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Qu'est-ce que le protocole de sécurité ?$mft$,
    $mft$[
      {"id":"a","label":"Un document écrit échangé entre l'entreprise d'accueil et le transporteur pour toute opération de chargement/déchargement","is_correct":true},
      {"id":"b","label":"Le plan d'évacuation incendie des locaux","is_correct":false},
      {"id":"c","label":"La procédure interne de contrôle des permis","is_correct":false},
      {"id":"d","label":"Le carnet d'entretien du véhicule","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-h','qcm-v1'], 'CAPA-LOURD-H-QCM-07', false,
    $mft$Prévu par le code du travail pour les opérations de chargement/déchargement : consignes du site et moyens de secours côté accueil, caractéristiques du véhicule et de la marchandise côté transporteur ; version unique pour les opérations répétitives.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Dans quel délai l'employeur doit-il déclarer un accident du travail à la CPAM ?$mft$,
    $mft$[
      {"id":"a","label":"24 heures","is_correct":false},
      {"id":"b","label":"48 heures (hors dimanches et jours fériés)","is_correct":true},
      {"id":"c","label":"8 jours","is_correct":false},
      {"id":"d","label":"1 mois","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-h','qcm-v1'], 'CAPA-LOURD-H-QCM-08', false,
    $mft$48 h pour l'employeur (le salarié informe l'employeur sous 24 h). Des réserves motivées peuvent accompagner la déclaration ; ne pas déclarer est une infraction.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Depuis 2021, quelle signalisation spécifique les véhicules lourds doivent-ils porter ?$mft$,
    $mft$[
      {"id":"a","label":"La signalisation des angles morts (autocollants réglementaires)","is_correct":true},
      {"id":"b","label":"Un gyrophare permanent","is_correct":false},
      {"id":"c","label":"Une plaque « transport lent »","is_correct":false},
      {"id":"d","label":"Un fanion rouge à l'arrière","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-h','qcm-v1'], 'CAPA-LOURD-H-QCM-09', false,
    $mft$Autocollants « angles morts » obligatoires sur les flancs et l'arrière des véhicules lourds : protection des cyclistes et piétons, premiers exposés aux angles morts en ville.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Hors agglomération, quel intervalle minimal deux véhicules lourds doivent-ils maintenir entre eux ?$mft$,
    $mft$[
      {"id":"a","label":"20 mètres","is_correct":false},
      {"id":"b","label":"30 mètres","is_correct":false},
      {"id":"c","label":"50 mètres","is_correct":true},
      {"id":"d","label":"100 mètres","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-h','qcm-v1'], 'CAPA-LOURD-H-QCM-10', false,
    $mft$50 mètres d'interdistance entre véhicules lourds hors agglomération : faciliter les dépassements et allonger les marges de freinage.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$À quel âge peut-on conduire un poids lourd (permis C) lorsqu'on est titulaire d'une qualification initiale de conducteur (FIMO ou titre professionnel) ?$mft$,
    $mft$[
      {"id":"a","label":"18 ans","is_correct":true},
      {"id":"b","label":"21 ans dans tous les cas","is_correct":false},
      {"id":"c","label":"23 ans","is_correct":false},
      {"id":"d","label":"25 ans","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-h','qcm-v1'], 'CAPA-LOURD-H-QCM-11', false,
    $mft$La qualification initiale abaisse l'âge du permis C (et CE) à 18 ans : c'est la voie des jeunes conducteurs professionnels (CAP conducteur routier, titre pro, FIMO).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Que risque un conducteur qui téléphone, appareil tenu en main, au volant de son poids lourd ?$mft$,
    $mft$[
      {"id":"a","label":"135 € d'amende et un retrait de 3 points","is_correct":true},
      {"id":"b","label":"Un simple avertissement","is_correct":false},
      {"id":"c","label":"35 € d'amende sans retrait de points","is_correct":false},
      {"id":"d","label":"Le retrait immédiat du permis dans tous les cas","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-h','qcm-v1'], 'CAPA-LOURD-H-QCM-12', false,
    $mft$Amende de 4e classe (135 €) + 3 points ; suspension possible en cas d'infraction simultanée. L'oreillette est également interdite : seul un dispositif intégré mains libres est toléré.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Quelle catégorie de permis faut-il pour conduire un ensemble articulé (tracteur + semi-remorque) ?$mft$,
   $mft$Le permis CE.$mft$,
   2, 'facile', ARRAY['capa-lourd','module-h','question-courte'], 'CAPA-LOURD-H-QC-01', false,
   $mft$C = porteur seul (remorque ≤ 750 kg) ; CE dès que la remorque/semi dépasse 750 kg.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$À partir de quel taux d'alcool dans le sang la conduite est-elle sanctionnée par une contravention ?$mft$,
   $mft$0,5 g/L de sang (0,25 mg/L d'air expiré).$mft$,
   2, 'facile', ARRAY['capa-lourd','module-h','question-courte'], 'CAPA-LOURD-H-QC-02', false,
   $mft$Délit à partir de 0,8 g/L.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Quelle est la vitesse maximale d'un poids lourd sur autoroute ?$mft$,
   $mft$90 km/h.$mft$,
   2, 'facile', ARRAY['capa-lourd','module-h','question-courte'], 'CAPA-LOURD-H-QC-03', false,
   $mft$Cohérente avec le réglage du limiteur.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Quelle est la durée de validité du permis C/CE avant 60 ans ?$mft$,
   $mft$Cinq ans, sous réserve de la visite médicale auprès d'un médecin agréé.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-h','question-courte'], 'CAPA-LOURD-H-QC-04', false,
   $mft$2 ans de 60 à 76 ans, 1 an ensuite.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Quel document obligatoire recense et évalue les risques professionnels de l'entreprise ?$mft$,
   $mft$Le document unique d'évaluation des risques professionnels (DUERP).$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-h','question-courte'], 'CAPA-LOURD-H-QC-05', false,
   $mft$Accepter « document unique » ; il doit être tenu à jour.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Qu'est-ce que le protocole de sécurité ?$mft$,
   $mft$Le document écrit échangé entre l'entreprise d'accueil et le transporteur, qui fixe les consignes de sécurité pour les opérations de chargement et de déchargement.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-h','question-courte'], 'CAPA-LOURD-H-QC-06', false,
   $mft$Deux idées : document écrit entre les deux entreprises + opérations de chargement/déchargement.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Sur quel créneau les véhicules de plus de 7,5 t sont-ils interdits de circulation chaque week-end ?$mft$,
   $mft$Du samedi 22 h au dimanche 22 h.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-h','question-courte'], 'CAPA-LOURD-H-QC-07', false,
   $mft$Même mécanique pour les jours fériés (veille 22 h → férié 22 h).$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Quel est le régime applicable à la conduite après usage de stupéfiants ?$mft$,
   $mft$Tolérance zéro : c'est un délit quel que soit le dosage détecté.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-h','question-courte'], 'CAPA-LOURD-H-QC-08', false,
   $mft$6 points, fortes amendes, suspension/annulation possibles.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Que signifie le sigle PAS en cas d'accident ?$mft$,
   $mft$Protéger, Alerter, Secourir.$mft$,
   2, 'difficile', ARRAY['capa-lourd','module-h','question-courte'], 'CAPA-LOURD-H-QC-09', false,
   $mft$Dans cet ordre : sécuriser la zone, appeler le 112 avec localisation précise, porter secours dans la limite de ses compétences.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$À quelle fréquence un conducteur de 65 ans doit-il renouveler la visite médicale de son permis C ?$mft$,
   $mft$Tous les deux ans (validité de 60 à 76 ans).$mft$,
   2, 'difficile', ARRAY['capa-lourd','module-h','question-courte'], 'CAPA-LOURD-H-QC-10', false,
   $mft$5 ans avant 60 ans, 1 an après 76 ans.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) — barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Présentez les catégories de permis du groupe lourd (C1, C1E, C, CE) avec leurs conditions d'âge, puis expliquez le dispositif de validité limitée et son suivi en entreprise.$mft$,
   $mft$Réponse modèle. Catégories : C1 (3,5 à 7,5 t, remorque ≤ 750 kg, 18 ans), C1E (C1 + remorque > 750 kg dans la limite de 12 t d'ensemble, 18 ans), C (plus de 3,5 t, remorque ≤ 750 kg, 21 ans, abaissé à 18 ans avec une qualification initiale de conducteur : FIMO ou titre professionnel), CE (véhicule C + remorque ou semi-remorque > 750 kg, mêmes conditions d'âge que C). Validité : le permis lourd est subordonné à l'aptitude médicale constatée par un médecin agréé : 5 ans avant 60 ans, 2 ans de 60 à 76 ans, 1 an au-delà. Suivi en entreprise : échéancier par conducteur (permis, visite médicale, CQC, carte conducteur), vérification périodique de la validité (copie du permis à l'embauche puis contrôles réguliers prévus au contrat ou au règlement), procédure en cas d'expiration ou d'invalidation (retrait immédiat de la conduite, module C). Un conducteur au permis expiré expose l'entreprise : conduite sans permis valide, assurance fragilisée, responsabilité en cas d'accident.$mft$,
   $mft$Barème /5 : quatre catégories exactes avec seuils (2 pts) ; âges dont l'abaissement à 18 ans avec qualification (1 pt) ; périodicités médicales 5/2/1 (1 pt) ; organisation du suivi et conséquences (1 pt). Erreurs fréquentes : confondre C1E et CE ; ignorer l'abaissement à 18 ans ; croire le permis lourd valable à vie.$mft$,
   5, 'facile', ARRAY['capa-lourd','module-h','question-redigee'], 'CAPA-LOURD-H-QR-01', false,
   $mft$Panorama permis + suivi RH, transversal module C.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Un de vos conducteurs est témoin direct d'un accident corporel sur autoroute. Décrivez la conduite à tenir, de la sécurisation aux formalités, y compris si votre propre salarié est blessé.$mft$,
   $mft$Réponse modèle. 1) Protéger : se garer en sécurité (bande d'arrêt d'urgence), feux de détresse, gilet haute visibilité avant de descendre, triangle si utilisable sans danger (déconseillé sur autoroute : privilégier la mise à l'abri derrière les glissières), couper le contact des véhicules accidentés, interdire de fumer. 2) Alerter : 112 (ou borne d'appel d'urgence qui localise automatiquement), indiquer le point kilométrique, le sens de circulation, le nombre de victimes et les risques (fuite de carburant, matières dangereuses : consignes écrites ADR à disposition). 3) Secourir : dans la limite de ses compétences, ne pas déplacer les blessés sauf danger immédiat (incendie), couvrir et rassurer. 4) Formalités : constat amiable précis (croquis, circonstances, témoins), photos, réserves ; information immédiate de l'exploitation ; déclaration à l'assureur dans les délais. 5) Si le salarié est blessé : information de l'employeur sous 24 h, déclaration d'accident du travail à la CPAM par l'employeur sous 48 heures (avec réserves motivées le cas échéant), certificat médical initial, analyse ultérieure de l'accident (arbre des causes) et actions correctives.$mft$,
   $mft$Barème /5 : séquence PAS correcte et adaptée à l'autoroute (2 pts) ; alerte précise avec localisation (0,5 pt) ; formalités assurance/constat (1 pt) ; volet AT : 24 h salarié / 48 h employeur + analyse (1,5 pt). Erreurs fréquentes : triangle posé en s'exposant sur autoroute ; oublier la déclaration AT en 48 h.$mft$,
   5, 'facile', ARRAY['capa-lourd','module-h','question-redigee'], 'CAPA-LOURD-H-QR-02', false,
   $mft$Conduite à tenir complète, route + accident du travail.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Cas professionnel. Lors d'un contrôle routier en tournée, un de vos conducteurs est mesuré à 0,6 g/L d'alcool dans le sang. Analysez les conséquences (routières, professionnelles, pour l'entreprise) et bâtissez la réponse managériale, immédiate et préventive.$mft$,
   $mft$Réponse modèle. Qualification routière : 0,6 g/L = contravention (entre 0,5 et 0,8) : amende, retrait de 6 points, immobilisation du véhicule possible tant qu'un conducteur apte ne le reprend pas, suspension administrative possible. Conséquences professionnelles : mise en danger, image, et si suspension du permis : impossibilité d'exécuter le contrat (module C : reclassement temporaire, procédure pouvant aller jusqu'au licenciement selon les circonstances et le règlement intérieur) ; au plan disciplinaire, conduire alcoolisé en service constitue une faute (vs faits de vie privée) : sanction proportionnée après procédure. Pour l'entreprise : organiser le rapatriement du véhicule et de la marchandise, informer le client si retard, vérifier l'historique du conducteur ; en cas d'accident, l'alcoolémie aurait aggravé les responsabilités (assurance, pénal) ; des manquements répétés tolérés interrogeraient l'organisation et l'honorabilité. Réponse managériale : immédiate : retrait de la conduite, entretien, procédure disciplinaire dans les délais avec les garanties ; préventive : règlement intérieur à jour (interdiction, modalités de contrôle par éthylotest encadrées), sensibilisation régulière (causeries), accompagnement (addictologie, médecine du travail), traçabilité des actions : la prévention documentée est la meilleure défense de l'entreprise.$mft$,
   $mft$Barème /5 : qualification contraventionnelle exacte avec sanctions (1,5 pt) ; volet disciplinaire distinguant service/vie privée avec procédure (1,5 pt) ; conséquences d'exploitation et responsabilités (1 pt) ; volet préventif encadré (règlement intérieur, éthylotests, accompagnement) (1 pt). Erreurs fréquentes : qualifier 0,6 g/L de délit ; licencier « sur-le-champ » sans procédure ; contrôles d'alcoolémie sans base dans le règlement intérieur.$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-h','question-redigee'], 'CAPA-LOURD-H-QR-03', false,
   $mft$Cas alcool en service : droit routier, droit social et management de la prévention.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Vous ouvrez un flux quotidien vers la plateforme logistique d'un nouveau client. Établissez le protocole de sécurité : contenu exigé de chaque partie, modalités pratiques, et vie du document.$mft$,
   $mft$Réponse modèle. Cadre : opérations de chargement/déchargement par une entreprise extérieure (le transporteur) dans une entreprise d'accueil : protocole de sécurité écrit obligatoire, préalable aux opérations. Contenu côté entreprise d'accueil : consignes de sécurité du site (plan de circulation, vitesses, port des EPI), lieux exacts de livraison et modalités d'accès et de stationnement, matériels et engins mis en œuvre (quais, chariots), moyens de secours et conduite en cas d'urgence, interlocuteur. Contenu côté transporteur : caractéristiques du véhicule et de son aménagement (hayon, tautliner), nature et conditionnement de la marchandise, précautions ou sujétions particulières (produits, gabarit). Modalités : échange et signature avant le premier flux ; flux quotidien = opérations répétitives : un protocole unique établi à l'avance suffit tant que les conditions restent identiques ; diffusion aux conducteurs concernés (à bord ou dématérialisé), accueil sécurité au premier passage. Vie du document : mise à jour à chaque changement significatif (nouveau quai, nouvel engin, nouvelle marchandise), revue périodique, traçabilité des versions ; en cas d'accident sur site, le protocole (ou son absence) est la première pièce examinée : responsabilités partagées et faute inexcusable en ligne de mire si un risque connu n'était pas traité.$mft$,
   $mft$Barème /5 : contenu côté accueil (1,5 pt) ; contenu côté transporteur (1 pt) ; régime des opérations répétitives (1 pt) ; diffusion aux conducteurs + mise à jour + enjeu en cas d'accident (1,5 pt). Erreurs fréquentes : confondre protocole de sécurité et plan de prévention général ; un protocole signé puis jamais mis à jour ni diffusé.$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-h','question-redigee'], 'CAPA-LOURD-H-QR-04', false,
   $mft$Construction du protocole de sécurité, question phare du domaine H.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Cas de planification. Un client exige une livraison à Lyon le dimanche à 8 h (marchandise générale, ensemble de 40 t). Analysez la faisabilité au regard des interdictions de circulation et proposez des solutions licites.$mft$,
   $mft$Réponse modèle. Contrainte : véhicule > 7,5 t : interdiction générale de circulation du samedi 22 h au dimanche 22 h : rouler dimanche matin est interdit ; la marchandise générale n'ouvre pas droit aux dérogations permanentes (réservées notamment aux denrées et produits périssables sous conditions). Solutions licites : 1) livrer le samedi avant 22 h (arrivée la veille, stationnement sécurisé sur site client ou à proximité, déchargement dimanche par le client si le véhicule reste à quai : vérifier l'acceptation du site et l'immobilisation du véhicule et du conducteur : coût à facturer) ; 2) positionner le véhicule le samedi et livrer dimanche après 22 h ou lundi tôt : renégocier l'heure avec le client ; 3) solliciter une dérogation préfectorale exceptionnelle si un motif réel l'appuie (rare pour un flux commercial ordinaire, délais d'instruction) ; 4) reporter sur un véhicule ≤ 7,5 t si le lot le permet (attention coûts et capacité) ; 5) anticiper contractuellement : clause sur les créneaux licites. À proscrire : rouler en infraction (amende, immobilisation, responsabilité en cas d'accident aggravée) : le devis doit intégrer la contrainte réglementaire plutôt que la subir.$mft$,
   $mft$Barème /5 : identification correcte de l'interdiction applicable (1,5 pt) ; absence de dérogation de plein droit pour la marchandise générale (1 pt) ; au moins trois solutions licites réalistes chiffrées en contraintes (2 pts) ; refus explicite de la circulation en infraction (0,5 pt). Erreurs fréquentes : croire toutes les marchandises dérogatoires ; oublier le repos du conducteur dans le montage horaire.$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-h','question-redigee'], 'CAPA-LOURD-H-QR-05', false,
   $mft$Planification sous interdictions de circulation, très concret exploitation.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Concevez la politique de prévention des accidents du travail d'une entreprise de 25 conducteurs : évaluation, actions techniques et humaines, pilotage par indicateurs.$mft$,
   $mft$Réponse modèle. Évaluation : DUERP à jour, construit avec le terrain : risques routiers (première cause de mortalité au travail), chutes de cabine et de hayon, manutentions (TMS), quais, agressions éventuelles ; hiérarchisation par gravité × fréquence. Actions techniques : entretien des hayons et transpalettes, éclairage et antidérapants, EPI adaptés (chaussures, gants, gilet), aides à la manutention, télématique d'aide à la conduite (freinages, vitesse), aménagement des tournées (temps réalistes, limitation du travail de nuit isolé). Actions humaines : accueil sécurité des nouveaux et intérimaires (les plus accidentés), causeries courtes régulières (angles morts, arrimage, descente de cabine trois points d'appui), formation post-accident, protocoles de sécurité à jour chez les clients, culture du presqu'accident (remontées sans sanction). Pilotage : taux de fréquence et de gravité des AT, sinistralité matérielle par conducteur/ligne, suivi des actions (qui/quoi/quand), revue annuelle avec le CSE (obligatoire dès 11 salariés : ici il existe), affichage des résultats. Boucle : chaque AT analysé (arbre des causes) alimente le DUERP et le plan d'actions : la prévention est un cycle, pas un classeur.$mft$,
   $mft$Barème /5 : DUERP et risques du métier correctement ciblés (1,5 pt) ; actions techniques pertinentes (1 pt) ; actions humaines dont accueil des nouveaux/intérimaires (1,5 pt) ; indicateurs TF/TG et boucle d'amélioration avec le CSE (1 pt). Erreurs fréquentes : catalogue d'EPI sans évaluation préalable ; oublier intérimaires et nouveaux ; aucun indicateur de suivi.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-h','question-redigee'], 'CAPA-LOURD-H-QR-06', false,
   $mft$Politique de prévention structurée, niveau dirigeant.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Cas professionnel. Un conducteur intérimaire, en mission chez vous depuis trois jours, chute du hayon d'un porteur en déchargeant seul chez un client, de nuit, sans protocole de sécurité établi. Blessure sérieuse. Analysez les responsabilités et les suites, puis les leçons organisationnelles.$mft$,
   $mft$Réponse modèle. Qualification : accident du travail d'un intérimaire : l'entreprise utilisatrice (vous) est responsable des conditions d'exécution du travail (santé et sécurité) pendant la mission ; l'employeur juridique reste l'agence d'intérim : déclaration d'AT par l'agence (informée sans délai par l'entreprise utilisatrice, qui lui transmet les circonstances), soins et indemnisation via l'agence. Manquements identifiables : absence de protocole de sécurité avec l'entreprise d'accueil (obligatoire pour le chargement/déchargement), travail isolé de nuit non organisé, accueil sécurité renforcé de l'intérimaire (obligatoire : les intérimaires sont surexposés) potentiellement insuffisant à J+3, état et utilisation du hayon à vérifier (entretien, formation). Suites possibles : enquête (CSE, inspection du travail éventuellement), analyse par arbre des causes, mise en cause pour faute inexcusable si un risque connu (déchargement de nuit, seul, sans protocole) n'a pas été traité : majoration des indemnisations, coût humain et financier lourd ; responsabilités partagées possibles avec le client (site d'accueil) selon les manquements de chacun. Leçons : protocoles de sécurité systématiques AVANT tout nouveau flux, interdiction du déchargement isolé de nuit sans mesures compensatoires, accueil sécurité renforcé et vérification des acquis des intérimaires, maintenance tracée des hayons, remontée des situations dangereuses. L'accident était prévisible : c'est précisément ce que la justice reprochera.$mft$,
   $mft$Barème /5 : répartition entreprise utilisatrice / agence d'intérim (déclaration, responsabilité sécurité) (1,5 pt) ; identification des manquements dont l'absence de protocole (1,5 pt) ; risque de faute inexcusable expliqué (1 pt) ; leçons organisationnelles concrètes (1 pt). Erreurs fréquentes : croire que l'intérim transfère toute la responsabilité à l'agence ; traiter le protocole comme une formalité optionnelle.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-h','question-redigee'], 'CAPA-LOURD-H-QR-07', false,
   $mft$Cas AT intérimaire croisant protocole de sécurité et faute inexcusable.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Votre sinistralité se dégrade : accrochages urbains en hausse (dont deux impliquant des cyclistes dans l'angle mort) et excès de vitesse relevés par la télématique. Analysez les causes probables et construisez un plan d'action sécurité routière à 12 mois.$mft$,
   $mft$Réponse modèle. Analyse : croiser les données (télématique, rapports d'accidents, lignes et horaires concernés, conducteurs récents ou anciens) pour objectiver : accrochages urbains = angles morts, manœuvres, pression horaire en livraison de centre-ville ; excès de vitesse = plannings tendus, culture du « rattrapage », absence de retour individuel. Plan à 12 mois : 1) Trimestre 1 : vérifier la signalisation angles morts de tous les véhicules, causerie dédiée cyclistes/piétons (trajectoires, contrôles avant manœuvre), revue des tournées urbaines (temps réalistes, créneaux hors pointe si possible) ; 2) Trimestre 2 : exploitation de la télématique en accompagnement individuel (entretiens factuels non punitifs, objectifs personnels), formation pratique manœuvres/angles morts pour les conducteurs impliqués ; 3) Trimestre 3 : équipements complémentaires si justifié (caméras de recul ou latérales, détecteurs), règles de vitesse internes rappelées au règlement, intégration de la sécurité aux entretiens annuels ; 4) Trimestre 4 : bilan chiffré (accrochages/100 000 km, alertes vitesse/conducteur, coût assurance), ajustement, reconnaissance des progrès (valorisation, pas seulement sanction). Conditions de réussite : exemplarité de l'exploitation (ne jamais demander l'impossible horaire), traçabilité des actions, association des conducteurs à l'analyse : la vitesse se corrige par l'organisation avant la sanction.$mft$,
   $mft$Barème /5 : analyse croisée des causes (données, organisation, pression horaire) (1,5 pt) ; plan séquencé réaliste sur 12 mois (2 pts) ; volet angles morts spécifique (0,75 pt) ; indicateurs de bilan et posture managériale (0,75 pt). Erreurs fréquentes : plan 100 % répressif ; ignorer la part de l'organisation (plannings) dans la vitesse.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-h','question-redigee'], 'CAPA-LOURD-H-QR-08', false,
   $mft$Pilotage de la sinistralité : diagnostic et plan d'action, niveau gestionnaire.$mft$);

  RAISE NOTICE 'Module H Capa lourd créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $capah$;

-- =====================================================================
-- CONTRÔLES POST-EXÉCUTION
-- =====================================================================
-- 1) Volumes : select "type", active, count(*) from question_bank
--     where source_ref like 'CAPA-LOURD-H-%' group by 1, 2;
--    → attendu : qcm/false = 12, qr/false = 18.
-- 2) QCM à bonne réponse unique :
--    select source_ref from question_bank
--     where source_ref like 'CAPA-LOURD-H-QCM-%'
--       and (select count(*) from jsonb_array_elements(choices) c
--             where (c->>'is_correct')::boolean) <> 1;   → 0 ligne.
-- 3) Doublons d'énoncés sur la formation :
--    select statement, count(*) from question_bank
--     where formation_id = (select id from formations where slug='capacite-plus-3-5t')
--     group by 1 having count(*) > 1;                    → 0 ligne.
