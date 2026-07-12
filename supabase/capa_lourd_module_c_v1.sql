-- =====================================================================
-- CAPACITÉ DE TRANSPORT > 3,5 T (LOURD) — MODULE C : DROIT SOCIAL — v1
-- (juillet 2026) — LOT 4
--
-- Domaine C de l'annexe I du règlement (CE) n° 1071/2009 : contrat de
-- travail et embauche du conducteur, durées de conduite et de repos
-- (règlement CE 561/2006 + paquet mobilité), chronotachygraphe
-- (règlement UE 165/2014), temps de travail des roulants (directive
-- 2002/15/CE), paie, formation obligatoire (FIMO/FCO), rupture, IRP.
--
-- ⚠ STATUT : questions insérées avec active = false (« à valider »).
-- Idempotent : DELETE ciblés par slug/source_ref, rejouable sans doublon.
-- =====================================================================

DO $capac$
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

  DELETE FROM public.question_bank WHERE source_ref LIKE 'CAPA-LOURD-C-%';
  DELETE FROM public.modules WHERE slug = 'capa-lourd-droit-social';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Module C — Droit social',
    'capa-lourd-droit-social',
    v_bloc,
    'Embaucher et gérer les conducteurs : contrat de travail et convention collective, durées de conduite et de repos du règlement 561/2006, chronotachygraphe, temps de travail des roulants, paie, formation obligatoire et rupture du contrat.',
    'intermediaire',
    600,
    30
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 30, true);

  -- ─── Leçon 1 — Contrat de travail et embauche du conducteur ────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'contrat-travail-embauche-conducteur',
    'Le contrat de travail et l''embauche du conducteur',
    $mft$> 🎯 **Objectifs**
> - Choisir le bon contrat (CDI, CDD) et sécuriser la période d'essai.
> - Dérouler la procédure d'embauche d'un conducteur poids lourd.
> - Situer la convention collective des transports routiers.

## CDI, CDD : le cadre

Le **CDI** est la forme normale de la relation de travail. Le **CDD** n'est possible que dans des **cas de recours** limités : remplacement d'un salarié absent, accroissement temporaire d'activité, emplois saisonniers ou d'usage. Il est écrit, motivé, et ne peut pourvoir **durablement un emploi lié à l'activité normale et permanente** de l'entreprise : à défaut, le juge le **requalifie en CDI** (avec indemnité).

La **période d'essai** permet d'évaluer le salarié : durée encadrée par la loi et la convention collective, renouvellement possible seulement s'il est prévu et accepté.

> 📌 **À retenir**
> Un CDD irrégulier (motif absent, succession abusive de contrats) = requalification en CDI + rappels. Dans le transport, enchaîner des CDD « accroissement d'activité » sur un poste de conducteur permanent est un contentieux classique.

## La convention collective

Les entreprises de transport routier relèvent de la **convention collective nationale des transports routiers et activités auxiliaires** : classifications et coefficients des conducteurs, primes et frais de déplacement, durées d'essai, préavis, garanties spécifiques. Elle complète le code du travail ; en cas de conflit, s'applique la disposition **la plus favorable** au salarié (dans les matières où la loi ne prime pas).

## Embaucher un conducteur PL : la procédure

:::timeline
1. **Vérifications préalables** — permis de conduire en cours de validité (C/CE), carte de qualification de conducteur (FIMO/FCO à jour), carte de conducteur (chronotachygraphe).
2. **DPAE** — déclaration préalable à l'embauche auprès de l'URSSAF, avant la prise de poste.
3. **Contrat écrit** — poste, coefficient conventionnel, lieu de rattachement, durée du travail, clauses utiles (mobilité).
4. **Formalités internes** — inscription au registre unique du personnel, affiliations (mutuelle, prévoyance), remise des documents d'entreprise.
5. **Suivi médical** — visite d'information et de prévention, ou suivi renforcé selon le poste ; aptitude à surveiller dans le temps.
6. **Intégration** — accueil sécurité, consignes d'exploitation, procédure en cas d'accident.
:::

> ⚠️ **Attention**
> Faire conduire un salarié sans FIMO/FCO valide ou sans carte conducteur expose l'entreprise à des sanctions et engage sa responsabilité en cas d'accident. Ces vérifications se **renouvellent** (échéances de la carte de qualification, validité du permis) : un échéancier par conducteur est indispensable.

## Les clauses utiles au transport

- **Clause de mobilité** : accepter des affectations dans une zone géographique définie précisément.
- **Clause de dédit-formation** : rembourser une formation coûteuse en cas de départ rapide (conditions strictes).
- **Polyvalence** : conduite + quai + livraisons, à décrire honnêtement dans le contrat.

## ✅ Synthèse

- **CDI par principe** ; CDD seulement dans les cas de recours, sinon requalification.
- Embauche conducteur : **permis + CQC + carte conducteur**, DPAE, contrat écrit, registre, visite.
- La **convention collective transports** complète le code du travail (coefficients, frais, préavis).$mft$,
    $mft$CDI/CDD et cas de recours, période d'essai, convention collective des transports routiers, procédure complète d'embauche d'un conducteur PL (permis, CQC, carte conducteur, DPAE, visite).$mft$,
    1, 45) RETURNING id INTO v_l1;

  -- ─── Leçon 2 — Durées de conduite et de repos (561/2006) ───────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'durees-conduite-repos-561-2006',
    'Durées de conduite et de repos : le règlement 561/2006',
    $mft$> 🎯 **Objectifs**
> - Mémoriser les plafonds de conduite et les minima de repos.
> - Appliquer les règles de fractionnement (pauses et repos).
> - Intégrer les apports du paquet mobilité (retour, cabine).

## Les plafonds de conduite

| Règle | Plafond |
| --- | --- |
| Conduite journalière | **9 h**, extensible à **10 h** deux fois par semaine |
| Conduite hebdomadaire | **56 h** |
| Conduite sur deux semaines consécutives | **90 h** |

## La pause

Après **4 h 30** de conduite : pause de **45 minutes**, fractionnable en **15 min puis 30 min** (dans cet ordre). La pause n'est pas du repos : elle interrompt la conduite.

> ❌ **Piège à éviter**
> Le fractionnement 30 + 15 est **non conforme** : la première fraction est d'au moins 15 minutes, la seconde d'au moins 30 minutes. À l'examen comme en contrôle, l'ordre compte.

## Les repos

- **Repos journalier normal** : **11 h** dans les 24 h suivant la prise de service ; **réduit** à **9 h** au plus **3 fois** entre deux repos hebdomadaires ; **fractionné** possible en **3 h + 9 h** (12 h au total).
- **Repos hebdomadaire normal** : **45 h** ; **réduit** : au moins **24 h**, avec **compensation** en bloc avant la fin de la troisième semaine suivante.
- Après **six périodes de 24 h** maximum depuis la fin du dernier repos hebdomadaire, un nouveau repos hebdomadaire doit commencer.

### Les apports du paquet mobilité

> 📌 **À retenir**
> - Le **repos hebdomadaire normal (45 h ou plus) en cabine est interdit** : il se prend dans un hébergement adapté, aux frais de l'employeur s'il est pris en déplacement.
> - **Droit au retour** : l'employeur organise le travail pour que le conducteur puisse rentrer (domicile ou centre opérationnel) **toutes les quatre semaines** ; retour après **trois semaines** si le conducteur a pris deux repos hebdomadaires réduits consécutifs (possibilité ouverte à l'international, avec compensation cumulée).

## Exemple d'application

Un conducteur prend son service lundi 6 h. Il peut conduire 9 h (10 h ce jour s'il n'a pas épuisé ses deux rallonges), avec 45 min de pause au plus tard après 4 h 30 de conduite. Son repos journalier de 11 h doit être achevé dans les 24 h de la prise de service : parti à 6 h, il doit au plus tard être en repos à 19 h pour un repos normal complet (sauf réduction à 9 h, décomptée).

:::flow
1. Prise de service | Début de la fenêtre de 24 h
2. Conduite et travail | Max 9-10 h de conduite, pauses réglementaires
3. Repos journalier | 11 h (ou 9 h réduit) avant la fin de la fenêtre
:::

## ✅ Synthèse

- **9 h/j (2 × 10 h), 56 h/semaine, 90 h/deux semaines** ; pause **45 min après 4 h 30** (15 + 30).
- Repos journalier **11 h** (réduit 9 h × 3 ; fractionné 3 + 9) ; hebdomadaire **45 h** (réduit ≥ 24 h + compensation).
- Paquet mobilité : **45 h jamais en cabine**, retour du conducteur **toutes les 4 semaines** (3 si deux réduits consécutifs).$mft$,
    $mft$Plafonds 9h/56h/90h, pause 45 min (15+30) après 4h30, repos journalier 11h (réduit 9h, fractionné 3+9) et hebdomadaire 45h (réduit 24h + compensation), interdiction du 45h en cabine et droit au retour.$mft$,
    2, 55) RETURNING id INTO v_l2;

  -- ─── Leçon 3 — Chronotachygraphe et temps de travail ───────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'chronotachygraphe-temps-travail',
    'Chronotachygraphe et temps de travail des roulants',
    $mft$> 🎯 **Objectifs**
> - Gérer les cartes et les téléchargements de données dans les délais.
> - Distinguer temps de conduite, temps de travail et temps de service.
> - Prévenir les infractions au chronotachygraphe, lourdes de conséquences.

## Le chronotachygraphe

Les véhicules lourds sont équipés d'un **chronotachygraphe numérique** (règlement UE 165/2014) qui enregistre conduite, autres travaux, disponibilité et repos. Les générations récentes (tachygraphe **intelligent**) ajoutent le positionnement par satellite et facilitent les contrôles à distance ; les échéances de mise à niveau des flottes internationales sont fixées par la réglementation européenne (calendrier à vérifier chaque année).

### Les cartes

| Carte | Titulaire | Usage |
| --- | --- | --- |
| Carte de conducteur | Le conducteur (validité **5 ans**) | Enregistre ses activités ; personnelle et incessible |
| Carte d'entreprise | L'entreprise | Verrouillage et téléchargement des données |
| Carte de contrôleur | Forces de contrôle | Lecture lors des contrôles |
| Carte d'atelier | Centres agréés | Installation, étalonnage |

### Les obligations de l'entreprise

- **Télécharger** les données de la **carte conducteur au moins tous les 28 jours** et de la **mémoire du véhicule au moins tous les 90 jours** ; conserver et tenir à disposition (un an au moins).
- **Analyser** les données, détecter les infractions, **former et sanctionner** si besoin : l'entreprise doit organiser le travail pour permettre le respect des règles ; elle répond des infractions favorisées par son organisation.
- Conducteur : utiliser **sa** carte, sélectionner les bonnes activités, justifier les journées non enregistrées (attestation d'activités).

> ⚠️ **Attention**
> Utiliser la carte d'un autre conducteur, conduire sans carte insérée ou manipuler l'appareil (aimants, dispositifs) constituent des infractions graves : fortes amendes, immobilisation, incidence sur l'honorabilité de l'entreprise, jusqu'au pénal pour les fraudes délibérées.

## Temps de conduite, temps de travail, temps de service

Trois notions à ne pas confondre :

- **Temps de conduite** : plafonné par le règlement 561/2006 (leçon 2).
- **Temps de travail effectif** : conduite + autres tâches (chargement, entretien, administratif).
- **Temps de service** des roulants : cadre français propre au transport, incluant des équivalences ; les plafonds précis dépendent de la catégorie (grands routiers, courtes distances) fixés par décret et convention (à vérifier dans les textes en vigueur).

Le socle européen (directive 2002/15/CE) pour les travailleurs mobiles :

> 📌 **À retenir**
> Durée hebdomadaire de travail : **48 h en moyenne** (période de référence) avec un **maximum de 60 h** sur une semaine isolée ; si travail de **nuit**, le travail quotidien est limité à **10 h** par période de 24 h.

## Contrôles et documents

Sur route : carte + données des **28 jours courants** (le conducteur doit pouvoir justifier la période réglementaire glissante) ; en entreprise : fichiers téléchargés, analyses, plannings. Les infractions se classent par gravité (jusqu'aux **infractions les plus graves** qui pèsent sur l'honorabilité, module F).

## ✅ Synthèse

- Cartes : conducteur (**5 ans**), entreprise, contrôleur, atelier ; téléchargements **28 j / 90 j**.
- **48 h en moyenne / 60 h max** par semaine (directive 2002/15) ; nuit : 10 h max.
- Fraudes au tachy = amendes, immobilisation, **honorabilité** en jeu ; l'entreprise répond de son organisation.$mft$,
    $mft$Chronotachygraphe et cartes (conducteur 5 ans), téléchargements 28/90 jours, distinction conduite/travail/service, plafonds 48h moyenne et 60h max, infractions et honorabilité.$mft$,
    3, 50) RETURNING id INTO v_l3;

  -- ─── Leçon 4 — Paie, formation, rupture et relations collectives ───
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'paie-formation-rupture-irp',
    'Paie, formation obligatoire, rupture et relations collectives',
    $mft$> 🎯 **Objectifs**
> - Composer la rémunération d'un conducteur (salaire, frais, primes).
> - Tenir les échéances de formation obligatoire (FIMO, FCO).
> - Mener une rupture de contrat sans faute de procédure.

## La rémunération du conducteur

La paie s'appuie sur la **classification conventionnelle** (coefficients) et comprend typiquement : salaire de base (taux horaire × heures), **heures supplémentaires** majorées, primes éventuelles, et **frais de déplacement** de la convention collective (indemnités de repas, de grand déplacement/découcher) qui indemnisent les sujétions sans être du salaire. Le bulletin de paie récapitule aussi les cotisations et le net social.

> 💡 **Astuce**
> Distinguer rigoureusement **salaire** (soumis à cotisations) et **frais professionnels** (indemnités conventionnelles, exonérées dans les limites) : une requalification de frais en salaire lors d'un contrôle URSSAF coûte cher.

## La formation obligatoire des conducteurs

- **FIMO** : formation initiale minimale obligatoire (**140 h**) pour accéder au métier (sauf équivalences par titres ou diplômes de conduite).
- **FCO** : formation continue obligatoire de **35 h tous les 5 ans**, qui maintient la **carte de qualification de conducteur (CQC)** en cours de validité.
- L'employeur planifie les échéances : conduire avec une CQC expirée est une infraction pour le conducteur **et** l'entreprise.

## La rupture du contrat

| Mode | Points clés |
| --- | --- |
| Démission | Volonté claire et non équivoque du salarié ; préavis conventionnel |
| Rupture conventionnelle | Accord des deux parties, entretien(s), homologation ; indemnité au moins égale à l'indemnité légale de licenciement |
| Licenciement pour motif personnel | Cause réelle et sérieuse ; disciplinaire (faute) ou non (insuffisance, inaptitude) ; procédure : convocation, entretien préalable, notification motivée |
| Licenciement économique | Motif économique réel ; ordre des licenciements, priorité de réembauche |

### Le cas d'école du transport : la perte du permis

La suspension ou l'invalidation du permis d'un conducteur, même pour des faits de **vie privée**, peut rendre l'exécution du contrat impossible : un licenciement pour **cause réelle et sérieuse** est envisageable (trouble objectif au fonctionnement), sans être nécessairement disciplinaire. Vérifier d'abord les solutions alternatives prévues par la convention ou l'usage (reclassement temporaire sur un poste sans conduite, congés), documenter, puis respecter scrupuleusement la procédure.

> ⚠️ **Attention**
> Sanctionner deux fois les mêmes faits est interdit ; le délai pour engager une procédure disciplinaire après connaissance des faits est encadré. En cas de faute grave alléguée, la mise à pied conservatoire se manie avec précaution.

## Les relations collectives et les contrôles

- **CSE** : comité social et économique obligatoire à partir de **11 salariés** (attributions élargies à 50).
- **Syndicats** : liberté syndicale, négociation collective (accords d'entreprise).
- **Inspection du travail** : accès à l'entreprise, contrôle des durées, de la paie, du travail dissimulé ; le **travail dissimulé** expose à des sanctions pénales et à la perte d'**honorabilité** (module F).

## ✅ Synthèse

- Paie conducteur : classification conventionnelle + **frais de déplacement** distincts du salaire.
- **FIMO 140 h**, **FCO 35 h / 5 ans** : échéancier CQC obligatoire côté employeur.
- Rupture : cause réelle et sérieuse + **procédure** ; perte de permis = cas classique à traiter méthodiquement.
- **CSE dès 11 salariés** ; inspection du travail ; travail dissimulé = honorabilité en jeu.$mft$,
    $mft$Rémunération et frais conventionnels, FIMO 140h et FCO 35h/5 ans (CQC), modes de rupture et cas de la perte de permis, CSE dès 11 salariés et contrôles de l'inspection du travail.$mft$,
    4, 50) RETURNING id INTO v_l4;

  -- ─── Quiz d'entraînement ────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module,
    'Quiz — Droit social',
    'Validez les fondamentaux du module C : contrat de travail, règlement 561/2006, chronotachygraphe, paie et rupture.',
    'entrainement', 70, false)
  RETURNING id INTO v_quiz;

  -- ─── QCM (12) — 4 faciles / 5 moyens / 3 difficiles ────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Quelle est la durée maximale de conduite journalière, et combien de fois par semaine peut-elle être portée à son plafond dérogatoire ?$mft$,
    $mft$[
      {"id":"a","label":"9 heures, extensible à 10 heures deux fois par semaine","is_correct":true},
      {"id":"b","label":"8 heures, extensible à 9 heures une fois par semaine","is_correct":false},
      {"id":"c","label":"10 heures, extensible à 11 heures trois fois par semaine","is_correct":false},
      {"id":"d","label":"9 heures, sans dérogation possible","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-c','qcm-v1'], 'CAPA-LOURD-C-QCM-01', false,
    $mft$Règlement (CE) 561/2006 : 9 h de conduite journalière, portées à 10 h au maximum deux fois dans la semaine.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Après combien de temps de conduite une pause est-elle obligatoire, et de quelle durée ?$mft$,
    $mft$[
      {"id":"a","label":"Après 4 h 30 de conduite : pause de 45 minutes","is_correct":true},
      {"id":"b","label":"Après 4 heures : pause de 30 minutes","is_correct":false},
      {"id":"c","label":"Après 5 heures : pause de 60 minutes","is_correct":false},
      {"id":"d","label":"Après 6 heures : pause de 20 minutes","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-c','qcm-v1'], 'CAPA-LOURD-C-QCM-02', false,
    $mft$45 minutes après 4 h 30 de conduite, fractionnables en 15 puis 30 minutes (dans cet ordre uniquement).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$À quel rythme la formation continue obligatoire (FCO) des conducteurs doit-elle être renouvelée ?$mft$,
    $mft$[
      {"id":"a","label":"35 heures tous les 5 ans","is_correct":true},
      {"id":"b","label":"140 heures tous les 5 ans","is_correct":false},
      {"id":"c","label":"35 heures tous les 3 ans","is_correct":false},
      {"id":"d","label":"70 heures tous les 10 ans","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-c','qcm-v1'], 'CAPA-LOURD-C-QCM-03', false,
    $mft$FCO : 35 h tous les 5 ans, qui maintient la carte de qualification de conducteur (CQC). La FIMO (140 h) est la formation initiale d'accès au métier.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Une entreprise peut-elle recruter en CDD pour pourvoir durablement un poste de conducteur lié à son activité normale et permanente ?$mft$,
    $mft$[
      {"id":"a","label":"Oui, si le contrat est écrit","is_correct":false},
      {"id":"b","label":"Non : le CDD serait requalifié en CDI par le juge","is_correct":true},
      {"id":"c","label":"Oui, dans la limite de 5 ans","is_correct":false},
      {"id":"d","label":"Oui, avec l'accord de l'inspection du travail","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['capa-lourd','module-c','qcm-v1'], 'CAPA-LOURD-C-QCM-04', false,
    $mft$Le CDD est réservé aux cas de recours (remplacement, accroissement temporaire, saisonnier). Pourvoir durablement un emploi permanent en CDD expose à la requalification en CDI avec indemnité.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Où le repos hebdomadaire normal (45 heures ou plus) peut-il être pris ?$mft$,
    $mft$[
      {"id":"a","label":"Dans la cabine du véhicule si elle est équipée d'une couchette","is_correct":false},
      {"id":"b","label":"Hors cabine, dans un hébergement adapté ; en déplacement, les frais incombent à l'employeur","is_correct":true},
      {"id":"c","label":"Uniquement au domicile du conducteur","is_correct":false},
      {"id":"d","label":"Indifféremment en cabine ou à l'hôtel","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-c','qcm-v1'], 'CAPA-LOURD-C-QCM-05', false,
    $mft$Le repos hebdomadaire normal en cabine est interdit (précision consacrée par le paquet mobilité). Le repos journalier et le repos hebdomadaire réduit restent possibles en cabine équipée, à l'arrêt.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Quels sont les plafonds de conduite hebdomadaire et sur deux semaines consécutives ?$mft$,
    $mft$[
      {"id":"a","label":"56 heures sur une semaine et 90 heures sur deux semaines","is_correct":true},
      {"id":"b","label":"48 heures sur une semaine et 96 heures sur deux semaines","is_correct":false},
      {"id":"c","label":"60 heures sur une semaine et 100 heures sur deux semaines","is_correct":false},
      {"id":"d","label":"45 heures sur une semaine et 90 heures sur deux semaines","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-c','qcm-v1'], 'CAPA-LOURD-C-QCM-06', false,
    $mft$561/2006 : 56 h maximum de conduite sur une semaine, 90 h sur deux semaines consécutives. Ne pas confondre avec les 48 h/60 h de la directive 2002/15 qui portent sur le temps de TRAVAIL.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$À quelle fréquence minimale l'entreprise doit-elle télécharger les données de la carte conducteur et celles de la mémoire du chronotachygraphe ?$mft$,
    $mft$[
      {"id":"a","label":"Carte : tous les 28 jours ; mémoire du véhicule : tous les 90 jours","is_correct":true},
      {"id":"b","label":"Carte : tous les 90 jours ; mémoire du véhicule : tous les 28 jours","is_correct":false},
      {"id":"c","label":"Carte et véhicule : tous les 7 jours","is_correct":false},
      {"id":"d","label":"Une fois par an pour les deux","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-c','qcm-v1'], 'CAPA-LOURD-C-QCM-07', false,
    $mft$Téléchargement au moins tous les 28 jours pour la carte conducteur et tous les 90 jours pour la mémoire du véhicule ; données conservées et analysées (détection des infractions).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Quelle est la durée de validité de la carte de conducteur (chronotachygraphe) ?$mft$,
    $mft$[
      {"id":"a","label":"3 ans","is_correct":false},
      {"id":"b","label":"5 ans","is_correct":true},
      {"id":"c","label":"10 ans","is_correct":false},
      {"id":"d","label":"Illimitée","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-c','qcm-v1'], 'CAPA-LOURD-C-QCM-08', false,
    $mft$La carte de conducteur est personnelle, incessible et valable 5 ans ; son renouvellement s'anticipe pour éviter toute interruption d'activité.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Selon la directive 2002/15/CE, la durée hebdomadaire de travail d'un conducteur est limitée à :$mft$,
    $mft$[
      {"id":"a","label":"48 heures en moyenne, avec un maximum de 60 heures sur une semaine isolée","is_correct":true},
      {"id":"b","label":"35 heures dans tous les cas","is_correct":false},
      {"id":"c","label":"56 heures en moyenne et 90 heures maximum","is_correct":false},
      {"id":"d","label":"44 heures en moyenne, 52 heures maximum","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['capa-lourd','module-c','qcm-v1'], 'CAPA-LOURD-C-QCM-09', false,
    $mft$Temps de TRAVAIL des travailleurs mobiles : 48 h hebdomadaires en moyenne sur la période de référence, 60 h maximum sur une semaine. Les 56 h/90 h concernent le temps de CONDUITE (561/2006).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Combien de fois le repos journalier peut-il être réduit à 9 heures entre deux repos hebdomadaires ?$mft$,
    $mft$[
      {"id":"a","label":"Une fois","is_correct":false},
      {"id":"b","label":"Deux fois","is_correct":false},
      {"id":"c","label":"Trois fois au maximum","is_correct":true},
      {"id":"d","label":"Sans limite si le conducteur est volontaire","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-c','qcm-v1'], 'CAPA-LOURD-C-QCM-10', false,
    $mft$Le repos journalier normal de 11 h peut être réduit à 9 h au plus trois fois entre deux repos hebdomadaires, sans compensation exigée. Le fractionnement 3 h + 9 h reste, lui, un repos normal.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Selon le droit au retour du paquet mobilité, l'employeur doit organiser le travail pour permettre au conducteur de rentrer (domicile ou centre opérationnel) :$mft$,
    $mft$[
      {"id":"a","label":"Toutes les 4 semaines, ou 3 semaines après deux repos hebdomadaires réduits consécutifs","is_correct":true},
      {"id":"b","label":"Toutes les 8 semaines dans tous les cas","is_correct":false},
      {"id":"c","label":"Chaque semaine","is_correct":false},
      {"id":"d","label":"Uniquement à la demande écrite du conducteur","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-c','qcm-v1'], 'CAPA-LOURD-C-QCM-11', false,
    $mft$Droit au retour : toutes les 4 semaines ; si le conducteur a pris deux repos hebdomadaires réduits consécutifs (faculté ouverte en transport international), le retour intervient dès la 3e semaine avec compensation cumulée. Ne pas confondre avec le retour des VÉHICULES toutes les 8 semaines.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Comment la pause de 45 minutes peut-elle être fractionnée ?$mft$,
    $mft$[
      {"id":"a","label":"En une fraction d'au moins 15 minutes suivie d'une fraction d'au moins 30 minutes","is_correct":true},
      {"id":"b","label":"En une fraction de 30 minutes suivie d'une fraction de 15 minutes","is_correct":false},
      {"id":"c","label":"En trois fractions de 15 minutes","is_correct":false},
      {"id":"d","label":"Elle ne peut jamais être fractionnée","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['capa-lourd','module-c','qcm-v1'], 'CAPA-LOURD-C-QCM-12', false,
    $mft$Fractionnement imposé dans cet ordre : au moins 15 minutes, puis au moins 30 minutes, la seconde fraction devant intervenir avant l'échéance des 4 h 30 de conduite cumulée. L'ordre inverse (30 puis 15) est non conforme.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l2, 'qr',
   $mft$Quelle pause est obligatoire après 4 h 30 de conduite ?$mft$,
   $mft$Une pause de 45 minutes (fractionnable en 15 minutes puis 30 minutes).$mft$,
   2, 'facile', ARRAY['capa-lourd','module-c','question-courte'], 'CAPA-LOURD-C-QC-01', false,
   $mft$Exiger la durée ; le fractionnement 15 + 30 est un bonus.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Quelle est la durée de la formation initiale minimale obligatoire (FIMO) des conducteurs de marchandises ?$mft$,
   $mft$140 heures.$mft$,
   2, 'facile', ARRAY['capa-lourd','module-c','question-courte'], 'CAPA-LOURD-C-QC-02', false,
   $mft$Environ quatre semaines. La FCO de renouvellement dure 35 h tous les 5 ans.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$À partir de quel effectif la mise en place d'un CSE est-elle obligatoire ?$mft$,
   $mft$À partir de 11 salariés.$mft$,
   2, 'facile', ARRAY['capa-lourd','module-c','question-courte'], 'CAPA-LOURD-C-QC-03', false,
   $mft$Comité social et économique ; attributions élargies à partir de 50 salariés.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Quelles sont la durée maximale de conduite journalière et ses possibilités d'extension ?$mft$,
   $mft$9 heures par jour, extensibles à 10 heures au maximum deux fois par semaine.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-c','question-courte'], 'CAPA-LOURD-C-QC-04', false,
   $mft$Exiger les deux éléments : 9 h et l'extension 10 h limitée à deux fois.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Quelle est la durée du repos journalier normal, et à combien peut-il être réduit ?$mft$,
   $mft$11 heures ; réductible à 9 heures au maximum trois fois entre deux repos hebdomadaires.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-c','question-courte'], 'CAPA-LOURD-C-QC-05', false,
   $mft$Le fractionnement 3 h + 9 h compte comme repos normal, pas comme repos réduit.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Quelles sont les durées du repos hebdomadaire normal et du repos hebdomadaire réduit ?$mft$,
   $mft$45 heures pour le repos normal ; au moins 24 heures pour le repos réduit, avec compensation avant la fin de la troisième semaine suivante.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-c','question-courte'], 'CAPA-LOURD-C-QC-06', false,
   $mft$Exiger 45 h et 24 h ; la règle de compensation est attendue au moins dans son principe.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$À quelle fréquence l'entreprise doit-elle au minimum télécharger les données de la carte conducteur et de la mémoire du véhicule ?$mft$,
   $mft$Tous les 28 jours pour la carte conducteur et tous les 90 jours pour la mémoire du véhicule.$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-c','question-courte'], 'CAPA-LOURD-C-QC-07', false,
   $mft$Les deux délais sont exigés (28 et 90 jours).$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Quelle déclaration l'employeur doit-il effectuer auprès de l'URSSAF avant toute embauche ?$mft$,
   $mft$La déclaration préalable à l'embauche (DPAE).$mft$,
   2, 'moyen', ARRAY['capa-lourd','module-c','question-courte'], 'CAPA-LOURD-C-QC-08', false,
   $mft$Accepter DPAE ; elle s'effectue au plus tôt 8 jours avant la prise de poste.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Quel est le plafond de conduite sur deux semaines consécutives ?$mft$,
   $mft$90 heures.$mft$,
   2, 'difficile', ARRAY['capa-lourd','module-c','question-courte'], 'CAPA-LOURD-C-QC-09', false,
   $mft$Conséquence : une semaine à 56 h impose de limiter la suivante à 34 h de conduite.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Comment le repos journalier peut-il être fractionné, et quel total atteint-il alors ?$mft$,
   $mft$En deux périodes : 3 heures puis 9 heures, soit 12 heures au total.$mft$,
   2, 'difficile', ARRAY['capa-lourd','module-c','question-courte'], 'CAPA-LOURD-C-QC-10', false,
   $mft$L'ordre est imposé (3 h d'abord, 9 h ensuite) ; ce repos fractionné reste un repos « normal ».$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) — barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l2, 'qr',
   $mft$Présentez l'ensemble des règles de conduite et de pause du règlement 561/2006 : plafonds journalier, hebdomadaire et bi-hebdomadaire, et régime de la pause.$mft$,
   $mft$Réponse modèle. Conduite journalière : 9 heures, extensibles à 10 heures au maximum deux fois par semaine. Conduite hebdomadaire : 56 heures au plus. Conduite sur deux semaines consécutives : 90 heures au plus (une semaine à 56 h impose de plafonner la suivante à 34 h). Pause : après 4 h 30 de conduite cumulée, interruption de 45 minutes, fractionnable uniquement en une première période d'au moins 15 minutes suivie d'une seconde d'au moins 30 minutes, la totalité étant acquise avant de rouvrir un cycle de 4 h 30. La pause interrompt la conduite mais n'est pas un repos. Ces règles s'appliquent aux véhicules de plus de 3,5 t (sauf exemptions) et sont contrôlées via le chronotachygraphe, sur route et en entreprise.$mft$,
   $mft$Barème /5 : 9 h / 2 × 10 h (1 pt) ; 56 h (0,5 pt) ; 90 h avec la conséquence pratique (1 pt) ; pause 45 min après 4 h 30 (1 pt) ; fractionnement 15 + 30 dans l'ordre (1 pt) ; distinction pause/repos (0,5 pt). Erreurs fréquentes : fractionner 30 + 15 ; confondre les plafonds de conduite avec les durées de travail 48/60 h.$mft$,
   5, 'facile', ARRAY['capa-lourd','module-c','question-redigee'], 'CAPA-LOURD-C-QR-01', false,
   $mft$Restitution complète du socle 561/2006, incontournable à l'examen.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Comparez le CDI et le CDD pour le recrutement de conducteurs : cas de recours, formalisme, risques pour l'employeur.$mft$,
   $mft$Réponse modèle. Le CDI est la forme normale du contrat : il ne requiert pas de motif, peut être oral (l'écrit restant indispensable en pratique) et se rompt selon les modes légaux (démission, licenciement, rupture conventionnelle). Le CDD est l'exception : cas de recours limités (remplacement d'un salarié absent, accroissement temporaire d'activité, emplois saisonniers ou d'usage), écrit obligatoire transmis dans les délais, motif précis, durée et renouvellements encadrés, indemnité de fin de contrat. Risques employeur : recourir au CDD pour pourvoir durablement un emploi lié à l'activité normale et permanente (une tournée régulière, par exemple) ou enchaîner les CDD sur le même poste = requalification en CDI, rappels de salaire et indemnités ; l'absence d'écrit ou de motif produit le même effet. Dans le transport, où l'activité connaît des pointes réelles (saisonnalité), le CDD se justifie par des éléments objectifs documentés (volumes, contrats clients temporaires).$mft$,
   $mft$Barème /5 : principe CDI / exception CDD (1 pt) ; au moins trois cas de recours exacts (1,5 pt) ; formalisme du CDD (écrit, motif, indemnité de fin) (1 pt) ; risque de requalification correctement expliqué avec un exemple transport (1,5 pt). Erreurs fréquentes : croire qu'un CDD écrit suffit à le valider ; ignorer l'indemnité de fin de contrat.$mft$,
   5, 'facile', ARRAY['capa-lourd','module-c','question-redigee'], 'CAPA-LOURD-C-QR-02', false,
   $mft$Comparaison structurée avec application au recrutement de conducteurs.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Analyse de planning. Un conducteur réalise : lundi 9 h de conduite, mardi 10 h, mercredi 9 h, jeudi 10 h, vendredi 9 h, samedi 8 h. Ce planning hebdomadaire est-il conforme au règlement 561/2006 ? Justifiez par le calcul et corrigez-le si nécessaire.$mft$,
   $mft$Réponse modèle. Total de conduite : 9 + 10 + 9 + 10 + 9 + 8 = 55 heures, sous le plafond hebdomadaire de 56 h : conforme sur ce point. Extensions à 10 h : utilisées mardi et jeudi, soit exactement deux fois : conforme (maximum deux par semaine). Vérifications complémentaires nécessaires : chaque jour, pause de 45 min par tranche de 4 h 30 de conduite ; repos journaliers de 11 h (ou 9 h réduits, trois fois maximum) entre les prises de service ; un repos hebdomadaire doit débuter au plus tard après six périodes de 24 h depuis la fin du précédent : avec six jours de conduite consécutifs, le repos hebdomadaire doit impérativement commencer à l'issue du samedi. Attention à la semaine suivante : 90 h maximum sur deux semaines consécutives, donc au plus 35 h de conduite la semaine d'après. Conclusion : planning conforme en l'état sur les plafonds de conduite, sous réserve des pauses et repos, avec une semaine suivante nécessairement allégée (≤ 35 h).$mft$,
   $mft$Barème /5 : total exact 55 h et comparaison au plafond 56 h (1,5 pt) ; contrôle des deux extensions à 10 h (1 pt) ; règle des six périodes de 24 h / position du repos hebdomadaire (1 pt) ; conséquence bi-hebdomadaire 90 h → ≤ 35 h ensuite (1 pt) ; mention des pauses/repos journaliers à vérifier (0,5 pt). Erreurs fréquentes : oublier le plafond bi-hebdomadaire ; compter trois extensions à 10 h comme licites.$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-c','question-redigee'], 'CAPA-LOURD-C-QR-03', false,
   $mft$Exercice de calcul type examen sur les plafonds de conduite.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Établissez, dans l'ordre chronologique, la procédure complète d'embauche d'un conducteur poids lourd, en distinguant les vérifications propres au métier des formalités communes à toute embauche.$mft$,
   $mft$Réponse modèle. Vérifications propres au métier, avant tout engagement : permis C ou CE en cours de validité ; carte de qualification de conducteur (FIMO initiale ou FCO à jour) ; carte de conducteur pour le chronotachygraphe ; le cas échéant, ADR ou CACES selon le poste ; références et aptitudes. Formalités communes : DPAE auprès de l'URSSAF avant la prise de poste ; signature du contrat écrit (poste, coefficient conventionnel, lieu de rattachement, durée du travail, clauses de mobilité ou de polyvalence) ; inscription au registre unique du personnel ; affiliation aux régimes complémentaires (mutuelle, prévoyance) ; organisation de la visite d'information et de prévention ou du suivi adapté ; remise des documents internes (règlement, consignes sécurité, procédures accident). Après l'entrée : période d'essai suivie, plan d'intégration (accompagnement sur les tournées), création de l'échéancier individuel (permis, CQC, carte conducteur, visites) pour garantir la validité permanente des titres.$mft$,
   $mft$Barème /5 : triptyque permis + CQC + carte conducteur (1,5 pt) ; DPAE avant prise de poste (0,5 pt) ; contrat écrit avec au moins deux mentions pertinentes (1 pt) ; registre du personnel + visite médicale (1 pt) ; échéancier de validité des titres (1 pt). Erreurs fréquentes : oublier la carte conducteur ; placer la DPAE après l'embauche ; négliger le suivi des échéances.$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-c','question-redigee'], 'CAPA-LOURD-C-QR-04', false,
   $mft$Checklist opérationnelle d'embauche, très proche des attentes du jury.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Cas professionnel. Lors de l'analyse mensuelle des données du chronotachygraphe, vous découvrez qu'un conducteur a inséré la carte d'un collègue pendant deux journées pour masquer des dépassements. Analysez les responsabilités encourues et bâtissez la réaction de l'entreprise.$mft$,
   $mft$Réponse modèle. Qualification : utiliser la carte d'un autre conducteur est une fraude au chronotachygraphe, parmi les infractions les plus graves : sanctions pénales et administratives pour le conducteur (amende, retrait de points le cas échéant) et risques pour l'entreprise (amendes, immobilisation, atteinte à l'honorabilité du gestionnaire et de l'entreprise, signalement au registre européen via ERRU). Responsabilité de l'entreprise : elle doit organiser le travail de façon à permettre le respect des règles et contrôler les données téléchargées ; sa réaction documentée est sa meilleure défense. Réaction : 1) sécuriser les preuves (fichiers, rapports d'analyse) ; 2) entretien avec les deux conducteurs concernés (l'usage de la carte d'autrui implique aussi son titulaire) ; 3) procédure disciplinaire proportionnée dans les délais (la fraude délibérée peut justifier une sanction lourde, jusqu'au licenciement pour faute grave selon les circonstances) ; 4) rappel collectif des règles et formation ; 5) correction organisationnelle si les dépassements révèlent des plannings intenables (cause racine) ; 6) traçabilité de l'ensemble pour démontrer la diligence de l'entreprise en cas de contrôle.$mft$,
   $mft$Barème /5 : qualification en infraction très grave avec double niveau de responsabilité conducteur/entreprise (1,5 pt) ; enjeu honorabilité/ERRU (1 pt) ; réaction disciplinaire procéduralement correcte et proportionnée (1,5 pt) ; analyse de la cause racine (plannings) et mesures préventives (1 pt). Erreurs fréquentes : sanctionner sans preuve consolidée ; ignorer le titulaire de la carte prêtée ; ne pas interroger l'organisation qui a rendu la fraude « utile ».$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-c','question-redigee'], 'CAPA-LOURD-C-QR-05', false,
   $mft$Cas disciplinaire et conformité, transversal modules C et F (honorabilité).$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Votre entreprise développe des tournées internationales de trois semaines. Construisez l'organisation conforme au paquet mobilité : repos hebdomadaires, hébergement, retour des conducteurs, et points de vigilance de planification.$mft$,
   $mft$Réponse modèle. Cadre : en transport international, le conducteur peut prendre deux repos hebdomadaires réduits consécutifs (hors de l'État d'établissement), à condition de cumuler les compensations avec le repos normal suivant ; l'employeur doit alors organiser le retour dès la troisième semaine (au lieu de quatre), au domicile ou au centre opérationnel, temps de trajet non imputé sur le repos. Le repos hebdomadaire normal (45 h et plus) est interdit en cabine : prévoir un hébergement adapté aux frais de l'entreprise lorsqu'il est pris en déplacement. Organisation proposée : semaine 1 repos réduit (≥ 24 h) à l'étranger avec hébergement ; semaine 2 second repos réduit ; fin de semaine 3 : retour planifié du conducteur et repos hebdomadaire normal allongé des compensations cumulées, pris à domicile. Points de vigilance : suivre les compensations au fichier de paie et de planning ; ne pas dépasser six périodes de 24 h entre repos hebdomadaires ; anticiper les plafonds 56 h/90 h sur les semaines chargées ; conserver les justificatifs d'hébergement ; coordonner avec le retour des véhicules (8 semaines, module F) sans confondre les deux obligations.$mft$,
   $mft$Barème /5 : mécanique des deux repos réduits consécutifs + compensations cumulées (1,5 pt) ; retour du conducteur en semaine 3 correctement placé (1 pt) ; interdiction du 45 h en cabine + hébergement employeur (1 pt) ; planification chiffrée cohérente (6 × 24 h, 56/90 h) (1 pt) ; distinction retour conducteur / retour véhicule (0,5 pt). Erreurs fréquentes : confondre les délais de retour (3-4 semaines vs 8 semaines) ; oublier la compensation en bloc.$mft$,
   5, 'moyen', ARRAY['capa-lourd','module-c','question-redigee'], 'CAPA-LOURD-C-QR-06', false,
   $mft$Plan d'exploitation international conforme paquet mobilité.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Cas professionnel. Le permis de conduire d'un conducteur en CDI est suspendu six mois à la suite d'un excès de vitesse commis le week-end avec son véhicule personnel. Analysez les options de l'employeur et la procédure applicable si la rupture est envisagée.$mft$,
   $mft$Réponse modèle. Principe : un fait de vie privée ne constitue pas, en soi, une faute disciplinaire ; mais la suspension du permis rend impossible l'exécution du contrat d'un conducteur : elle peut fonder un licenciement pour cause réelle et sérieuse tiré du trouble objectif au fonctionnement de l'entreprise, distinct du terrain disciplinaire. Options préalables à explorer et documenter : reclassement temporaire sur un poste sans conduite (quai, exploitation) s'il en existe, prise de congés ou absence autorisée, suspension du contrat si un accord ou la convention le permettent ; durée de la suspension (six mois) et taille de l'entreprise pèsent sur le caractère sérieux de la cause. Si la rupture est retenue : convocation à entretien préalable (lettre précisant objet, date, faculté d'assistance), entretien, notification motivée dans les délais, préavis (souvent inexécutable, alors non payé si l'impossibilité vient du salarié) et documents de fin de contrat. Vérifier les stipulations conventionnelles éventuelles propres aux conducteurs (garanties de reclassement). À proscrire : la sanction disciplinaire automatique pour des faits privés et toute précipitation sans recherche d'alternative documentée.$mft$,
   $mft$Barème /5 : distinction fait de vie privée / trouble objectif, terrain non disciplinaire par principe (1,5 pt) ; alternatives explorées et documentées avant rupture (1,5 pt) ; procédure de licenciement complète et correcte (1,5 pt) ; nuance préavis/documents de fin de contrat ou garanties conventionnelles (0,5 pt). Erreurs fréquentes : licencier pour « faute grave » automatique ; ignorer le reclassement temporaire ; procédure bâclée (pas d'entretien préalable).$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-c','question-redigee'], 'CAPA-LOURD-C-QR-07', false,
   $mft$Grand classique du contentieux transport, traité méthode et procédure.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un conducteur grand routier cumule sur quatre semaines : 58 h, 44 h, 52 h et 46 h de temps de travail. a) Ces valeurs respectent-elles la directive 2002/15/CE ? b) Quelles autres limites faut-il vérifier avant de valider ces plannings ? c) Quels leviers d'organisation proposez-vous si la moyenne dérape ?$mft$,
   $mft$Réponse modèle. a) Semaine isolée : maximum 60 h : la semaine à 58 h est licite (58 ≤ 60), aucune semaine ne dépasse. Moyenne : (58 + 44 + 52 + 46) / 4 = 200 / 4 = 50 h : SUPÉRIEURE à la moyenne autorisée de 48 h ; sur une période de référence de quatre semaines prise isolément, ce rythme n'est pas tenable : la moyenne de 48 h s'apprécie sur la période de référence applicable (jusqu'à quatre mois selon les textes et accords) : il faut donc compenser par des semaines plus légères au sein de la période pour ramener la moyenne à 48 h au plus. b) Vérifier aussi : plafonds de CONDUITE 56 h/90 h (distincts du travail), pauses et repos journaliers/hebdomadaires, travail de nuit (10 h par 24 h le cas échéant), et les règles françaises de temps de service applicables à la catégorie (décret/convention, à jour). c) Leviers : lisser les tournées sur la période de référence, alterner semaines chargées et allégées, redistribuer les tâches non-conduite (quai), recourir à un conducteur supplémentaire sur les pics, suivre mensuellement les compteurs individuels avec alerte avant dépassement.$mft$,
   $mft$Barème /5 : contrôle 60 h correct (1 pt) ; calcul de moyenne exact 50 h et comparaison aux 48 h avec la notion de période de référence (2 pts) ; autres limites citées (conduite 56/90, nuit, repos) (1 pt) ; leviers d'organisation réalistes (1 pt). Erreurs fréquentes : confondre travail et conduite ; conclure à la conformité parce qu'aucune semaine ne dépasse 60 h en oubliant la moyenne.$mft$,
   5, 'difficile', ARRAY['capa-lourd','module-c','question-redigee'], 'CAPA-LOURD-C-QR-08', false,
   $mft$Exercice chiffré sur la directive 2002/15, avec la confusion conduite/travail en piège central.$mft$);

  RAISE NOTICE 'Module C Capa lourd créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $capac$;

-- =====================================================================
-- CONTRÔLES POST-EXÉCUTION
-- =====================================================================
-- 1) Volumes : select "type", active, count(*) from question_bank
--     where source_ref like 'CAPA-LOURD-C-%' group by 1, 2;
--    → attendu : qcm/false = 12, qr/false = 18.
-- 2) QCM à bonne réponse unique :
--    select source_ref from question_bank
--     where source_ref like 'CAPA-LOURD-C-QCM-%'
--       and (select count(*) from jsonb_array_elements(choices) c
--             where (c->>'is_correct')::boolean) <> 1;   → 0 ligne.
-- 3) Doublons d'énoncés sur la formation :
--    select statement, count(*) from question_bank
--     where formation_id = (select id from formations where slug='capacite-plus-3-5t')
--     group by 1 having count(*) > 1;                    → 0 ligne.
