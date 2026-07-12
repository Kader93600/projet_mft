-- =====================================================================
-- FIMO / FCO MARCHANDISES — THÈME 1 : CONDUITE RATIONNELLE AXÉE
-- SÉCURITÉ — v1 (juillet 2026) — LOT FIMO-2
--
-- Objectifs 1.1 à 1.4 du référentiel (directive 2003/59/CE annexe I) :
-- chaîne cinématique, organes de freinage et aides électroniques,
-- optimisation de la consommation, chargement et arrimage côté
-- conducteur. Angle : les GESTES du conducteur (l'organisation
-- d'entreprise est traitée ailleurs).
--
-- ⚠ STATUT : questions insérées avec active = false (« à valider »).
-- Idempotent : DELETE ciblés par slug/source_ref, rejouable sans doublon.
-- =====================================================================

DO $fimot1$
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
    RAISE EXCEPTION 'Formation fimo-fco introuvable.';
  END IF;

  INSERT INTO public.blocs (id, code, title, description, "order")
  VALUES (40, 'FIMO-FCO',
          'FIMO / FCO — Qualification des conducteurs marchandises',
          'Référentiel de la qualification initiale (FIMO) et continue (FCO) des conducteurs du transport routier de marchandises : directive 2003/59/CE modifiée et arrêté du 3 janvier 2008.',
          40)
  ON CONFLICT DO NOTHING;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'FIMO-FCO';

  DELETE FROM public.question_bank WHERE source_ref LIKE 'FIMO-T1-%';
  DELETE FROM public.modules WHERE slug = 'fimo-t1-conduite-rationnelle';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES (
    'Thème 1 — Conduite rationnelle axée sécurité',
    'fimo-t1-conduite-rationnelle',
    v_bloc,
    'Comprendre et exploiter la chaîne cinématique (couple, puissance, consommation), maîtriser freins, ralentisseurs et aides électroniques, adopter l''éco-conduite et sécuriser le chargement : les gestes techniques du conducteur professionnel.',
    'intermediaire',
    480,
    20
  ) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 20, true);

  -- ─── Leçon 1 — La chaîne cinématique ───────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'chaine-cinematique-comprendre-son-camion',
    'La chaîne cinématique : comprendre son camion',
    $mft$> 🎯 **Objectifs**
> - Lire les courbes de couple, de puissance et de consommation.
> - Utiliser la bonne plage du compte-tours à chaque instant.
> - Exploiter la boîte de vitesses au service de la consommation et de la mécanique.

## Trois courbes qui expliquent tout

Le moteur d'un poids lourd se lit sur trois courbes :

- le **couple** (la force de traction) : maximal à **bas régime**, sur une plage large : c'est lui qui tire la charge ;
- la **puissance** (couple × régime) : maximale à régime plus élevé : utile en côte, coûteuse en carburant ;
- la **consommation spécifique** : minimale autour du **couple maximal** : le moteur y transforme le mieux le gazole en travail.

> 📌 **À retenir**
> Le camion moderne se conduit **au couple, pas à la puissance** : rester dans la plage du couple maxi (la **zone verte** du compte-tours), c'est tirer la charge avec la consommation la plus basse et l'usure minimale.

## Le compte-tours : votre tableau de bord économique

| Zone | Usage |
| --- | --- |
| **Zone verte** (bas régime, autour du couple maxi) | Croisière : consommation minimale |
| Zone intermédiaire | Reprises, montées en charge |
| Zone haute (proche du régime de puissance maxi) | Brefs instants : dépassement, forte côte : jamais en continu |
| Sur-régime | Interdit : casse mécanique, aucun gain |

## La boîte : monter tôt, rétrograder juste

Les rapports d'une boîte de PL se **recouvrent** : à une même vitesse, plusieurs rapports sont possibles ; le bon est celui qui place le moteur en zone verte.

- **Monter les rapports tôt** : dès que le couple le permet, sans attendre les hauts régimes ;
- **Sauter des rapports** quand la charge et le profil le permettent (boîtes robotisées : laisser travailler le mode éco) ;
- **Rétrograder juste** : avant la côte ou la descente, pas au milieu, pour rester dans la plage utile sans casser l'élan.

> 💡 **Astuce**
> Boîte robotisée : le mode automatique économique fait mieux que 95 % des conducteurs en solo. Le professionnel reprend la main pour l'ANTICIPATION que l'électronique ne voit pas : rond-point au loin, descente qui s'annonce, insertion.

## Ce que ça change au quotidien

Rouler au couple, c'est : moins de bruit, moins de gazole (le premier poste de coût du véhicule), moins d'usure (embrayage, freins, moteur), et une conduite plus souple qui préserve le chargement et les organes. La chaîne cinématique bien utilisée est le socle de l'éco-conduite (leçon 3).

## ✅ Synthèse

- **Couple maxi à bas régime** = zone d'utilisation optimale = **zone verte** = consommation spécifique minimale.
- La puissance se visite **brièvement** ; le sur-régime, jamais.
- Boîte : **monter tôt, sauter quand c'est possible, rétrograder avant** la difficulté.$mft$,
    $mft$Courbes de couple/puissance/consommation, conduite au couple dans la zone verte du compte-tours, usage de la boîte (monter tôt, recouvrement des rapports, rétrograder avant la difficulté).$mft$,
    1, 45) RETURNING id INTO v_l1;

  -- ─── Leçon 2 — Freins, ralentisseurs et aides électroniques ────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'freins-ralentisseurs-aides-electroniques',
    'Freins, ralentisseurs et aides électroniques',
    $mft$> 🎯 **Objectifs**
> - Combiner frein de service, frein moteur et ralentisseur sans surchauffe.
> - Descendre une longue pente en charge en sécurité.
> - Connaître le vrai rôle de l'ABS, de l'ESP et de l'AEBS.

## Les moyens de ralentir un 44 tonnes

- **Frein de service** (pneumatique) : puissant mais pas inépuisable : il chauffe ;
- **Frein moteur** et **frein sur échappement** : ralentissent sans user, efficacité liée au régime ;
- **Ralentisseur** (hydraulique ou électromagnétique) : l'outil des longues descentes : ralentit en continu **sans toucher aux freins** ;
- **Frein de stationnement** : immobilisation ; **freinage de secours** : selon les consignes constructeur en cas de défaillance.

## Le danger n° 1 : la surchauffe (fading)

Utiliser le frein de service en continu dans une descente élève la température des garnitures jusqu'au **fading** : la pédale répond, mais le camion **ne ralentit plus**. À 44 t, c'est l'accident.

> 📌 **À retenir**
> La règle de la descente : **on descend à une vitesse à laquelle on pourrait remonter**, rapport bas engagé AVANT la pente, **ralentisseur en action principale**, frein de service par **appuis brefs et fermes** pour ajuster : jamais en continu. Si la vitesse s'emballe malgré tout : appui fort immédiat pour casser la vitesse tant que les freins sont froids, rétrogradage, et en dernier recours l'aire de détresse.

## La montée en gamme électronique

| Système | Ce qu'il fait vraiment |
| --- | --- |
| **ABS** | Empêche le blocage des roues : le véhicule reste **dirigeable** en freinage d'urgence : il ne raccourcit pas la distance |
| **EBS** | Gestion électronique du freinage : répartition et temps de réponse optimisés |
| **ESP** | Corrige les amorces de dérive et de renversement (essentiel avec un centre de gravité haut) |
| **AEBS** | Freinage d'urgence automatique en cas d'obstacle : un filet de sécurité, pas un pilote |
| Régulateur / régulateur adaptatif | Vitesse stabilisée, distance gérée : à **désactiver ou surveiller en descente** (il ne voit pas la pente) |

> ❌ **Piège à éviter**
> « J'ai l'ABS, je freine plus court » : faux. L'ABS conserve la **direction**, pas la distance. Et l'ESP ne rattrape pas une vitesse d'entrée en courbe excessive avec une charge haute : l'électronique repousse les limites, elle ne les supprime pas.

## En cas de défaillance de freinage

Perte de pression, alerte au tableau de bord : réduire immédiatement l'allure, rapport bas, ralentisseur, chercher l'échappatoire (aire de détresse, montée, bas-côté dégagé), avertir (feux de détresse, klaxon), et ne JAMAIS couper le moteur en roulant (perte d'assistance).

## ✅ Synthèse

- Descente : **rapport bas avant la pente, ralentisseur en principal, frein de service par touches** ; vitesse « remontable ».
- **Fading** = freins surchauffés qui ne répondent plus : c'est l'usage continu qui le provoque.
- ABS = **directivité** (pas la distance) ; ESP = anti-dérive/renversement ; AEBS = filet ; régulateur : **prudence en descente**.$mft$,
    $mft$Les quatre moyens de ralentir, la règle de la descente longue (rapport bas avant, ralentisseur principal, freins par touches), le fading, et le vrai rôle des aides (ABS directivité, ESP, AEBS, régulateur).$mft$,
    2, 45) RETURNING id INTO v_l2;

  -- ─── Leçon 3 — L'éco-conduite ──────────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'eco-conduite-rouler-pro',
    'L''éco-conduite : rouler pro, consommer moins',
    $mft$> 🎯 **Objectifs**
> - Appliquer les six techniques qui font baisser la consommation.
> - Chiffrer ce que l'éco-conduite rapporte (et ce qu'elle ne coûte pas).
> - Relier éco-conduite et sécurité : c'est la même conduite.

## Pourquoi c'est VOTRE sujet

Le carburant représente le premier poste de coût d'exploitation d'un poids lourd. Entre deux conducteurs sur la même ligne et le même véhicule, l'écart atteint couramment **3 à 5 L/100 km** : sur 120 000 km annuels, 5 L/100 d'écart font **6 000 litres** : des milliers d'euros par an et par camion. L'éco-conduite est une compétence professionnelle valorisée, mesurée par la télématique et souvent primée.

## Les six techniques

:::flow
1. Anticiper | Regarder loin, lever le pied tôt : le meilleur freinage est celui qu'on évite
2. Utiliser l'inertie | Laisser rouler sur l'élan (rapport engagé) à l'approche des ralentissements
3. Rouler au couple | Zone verte, monter les rapports tôt (leçon 1)
4. Stabiliser la vitesse | Régulateur à bon escient, pas de yo-yo d'accélérateur
5. Modérer la vitesse de pointe | Quelques km/h de moins en croisière : gain net, temps quasi identique
6. Couper ce qui consomme | Pas de ralenti prolongé, pneus à la bonne pression, déflecteurs réglés
:::

> 💡 **Astuce**
> En décélération **rapport engagé**, l'injection se **coupe** : consommation quasi nulle tant que le moteur est entraîné. Au point mort, le moteur consomme pour tourner au ralenti ET le véhicule est moins contrôlable : l'éco-conduite ne se fait JAMAIS au point mort.

## Éco-conduite = conduite de sécurité

Les mêmes gestes servent les deux : l'**anticipation** allonge les distances de sécurité et supprime les freinages d'urgence ; la **vitesse stabilisée** réduit les écarts et le stress ; **regarder loin** fait détecter l'imprévu plus tôt. Les flottes qui forment à l'éco-conduite voient baisser la consommation ET la sinistralité : ce n'est pas une coïncidence, c'est la même conduite.

## Le mythe du temps perdu

Réduire la vitesse de pointe de quelques km/h change très peu la **vitesse moyenne** d'une tournée (feux, ronds-points, chargements pèsent bien plus que la pointe). L'écart se compte en minutes sur une journée : le gain en gazole, en usure (freins, pneus) et en sérénité se compte en milliers d'euros et en accidents évités.

## Mesurer et progresser

La **télématique** restitue vos indicateurs : consommation, anticipation (freinages), régime, ralenti. Le bon réflexe : suivre SA tendance mois par mois, viser la régularité plutôt que l'exploit, et demander un accompagnement (audit de conduite en FCO) si un indicateur décroche.

## ✅ Synthèse

- Écart courant entre conducteurs : **3 à 5 L/100** : énorme à l'année.
- Six techniques, une clé de voûte : **l'anticipation** ; jamais de point mort.
- Éco-conduite = **moins de gazole ET moins d'accidents** ; le temps « perdu » est un mythe.$mft$,
    $mft$Les six techniques d'éco-conduite (anticipation, inertie, couple, vitesse stabilisée, pointe modérée, chasse au ralenti), la coupure d'injection rapport engagé, le lien éco-conduite/sécurité et le mythe du temps perdu.$mft$,
    3, 40) RETURNING id INTO v_l3;

  -- ─── Leçon 4 — Charger et arrimer : les gestes du conducteur ───────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'charger-arrimer-gestes-conducteur',
    'Charger et arrimer : les gestes du conducteur',
    $mft$> 🎯 **Objectifs**
> - Anticiper les forces qui s'exercent sur le chargement en roulant.
> - Exécuter un plan de chargement qui respecte essieux et stabilité.
> - Contrôler sangles et arrimage au départ et à chaque étape.

## Ce que subit votre chargement

En mouvement, la marchandise « veut » continuer tout droit : au **freinage appuyé**, elle pousse vers l'avant avec une force pouvant approcher son propre poids (de l'ordre de 8 t pour un lot de 10 t) ; en courbe et à l'accélération, la poussée latérale ou arrière atteint la moitié du poids. Sans blocage ni arrimage dimensionné, la charge glisse, bascule : ou traverse la cloison.

## Le plan de chargement du conducteur

- **Lourd en bas, centré sur les essieux porteurs** : centre de gravité bas = stabilité en courbe ;
- **Répartir gauche/droite** et dans la longueur : un essieu peut être en surcharge alors que le poids total est correct ;
- **Penser tournée** : ce qui se livre en premier se charge en dernier ET la répartition doit rester correcte après chaque livraison ;
- **Bloquer les vides** : cloisons, barres, coins de palettes en quinconce : ce qui ne peut pas bouger n'a pas besoin d'être retenu ;
- **Ne pas dépasser la charge utile** : le poids annoncé se vérifie (documents, cohérence visuelle) : en cas de doute, peser.

## L'arrimage : vos outils, vos contrôles

| Outil | Le geste pro |
| --- | --- |
| Sangles | Lire l'étiquette (capacité), tendre correctement, protéger les arêtes vives |
| Tapis antiglisse | Sous les palettes glissantes : démultiplie l'efficacité des sangles |
| Barres et cloisons | Blocage direct : la structure encaisse à votre place |
| Points d'ancrage | En nombre suffisant, en bon état : jamais de sangle sur un élément non prévu |

> ❌ **Piège à éviter**
> Une sangle **coupée, nouée ou à l'étiquette illisible est bonne pour la benne**, pas pour le fret. Nouer une sangle divise sa résistance : c'est le bricolage qui lâche au premier freinage fort.

## Vos contrôles, du quai à la livraison

:::timeline
1. **Avant de partir** — Tour du véhicule : répartition visible, sangles tendues, portes et hayon verrouillés ; réserves écrites si l'expéditeur a mal chargé : vous êtes le dernier contrôle avant la route.
2. **Après quelques kilomètres** — Re-tension : le chargement se tasse, les sangles se détendent.
3. **À chaque livraison partielle** — Re-répartir et re-arrimer ce qui reste : une remorque à moitié vide mal répartie devient instable.
4. **À l'arrivée** — Ouvrir prudemment : une charge déplacée peut tomber à l'ouverture des portes.
:::

> 📌 **À retenir**
> Même quand l'expéditeur charge et arrime (gros envois), **vous vérifiez** ce qui se voit et vous signalez ce qui ne va pas : sur la route, c'est vous qui portez la sécurité de l'ensemble : un refus motivé vaut mieux qu'un renversement.

## ✅ Synthèse

- Freinage : poussée avant proche du **poids de la charge** ; courbe : la **moitié** : l'arrimage se dimensionne, ne se devine pas.
- Plan de chargement : **bas, centré, réparti, pensé tournée** ; vides bloqués.
- Contrôles : **départ, re-tension, chaque livraison, ouverture** ; sangle douteuse = sangle écartée.$mft$,
    $mft$Forces sur le chargement (poussée avant proche du poids, latérale moitié), plan de chargement du conducteur (bas, centré, pensé tournée), outils d'arrimage et les quatre contrôles du quai à la livraison.$mft$,
    4, 45) RETURNING id INTO v_l4;

  -- ─── Quiz d'entraînement ────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module,
    'Quiz — Conduite rationnelle',
    'Vérifiez le thème 1 : chaîne cinématique, freinage et ralentisseurs, éco-conduite, chargement et arrimage.',
    'entrainement', 70, false)
  RETURNING id INTO v_quiz;

  -- ─── QCM (12) — 4 faciles / 5 moyens / 3 difficiles ────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Que représente la « zone verte » du compte-tours d'un poids lourd ?$mft$,
    $mft$[
      {"id":"a","label":"La plage de régime où le couple est maximal et la consommation minimale","is_correct":true},
      {"id":"b","label":"La zone où la puissance est maximale","is_correct":false},
      {"id":"c","label":"La zone réservée aux dépassements","is_correct":false},
      {"id":"d","label":"La zone de ralenti","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['fimo-fco','theme-1','qcm-v1'], 'FIMO-T1-QCM-01', false,
    $mft$La zone verte correspond à la plage du couple maximal, où la consommation spécifique est la plus basse : c'est la zone de croisière du conducteur professionnel.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$À quoi sert principalement le ralentisseur d'un poids lourd ?$mft$,
    $mft$[
      {"id":"a","label":"À ralentir le véhicule en continu, notamment en descente, sans échauffer les freins de service","is_correct":true},
      {"id":"b","label":"À immobiliser le véhicule en stationnement","is_correct":false},
      {"id":"c","label":"À raccourcir la distance de freinage d'urgence","is_correct":false},
      {"id":"d","label":"À limiter la vitesse à 90 km/h","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['fimo-fco','theme-1','qcm-v1'], 'FIMO-T1-QCM-02', false,
    $mft$Le ralentisseur (hydraulique ou électromagnétique) absorbe l'énergie des longues descentes et préserve les freins de service pour les ajustements et l'urgence.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Quelle est la technique de base de l'éco-conduite ?$mft$,
    $mft$[
      {"id":"a","label":"L'anticipation : regarder loin et lever le pied tôt pour éviter les freinages inutiles","is_correct":true},
      {"id":"b","label":"Rouler au point mort dans les descentes","is_correct":false},
      {"id":"c","label":"Rouler le plus lentement possible partout","is_correct":false},
      {"id":"d","label":"Couper le moteur aux feux rouges courts","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['fimo-fco','theme-1','qcm-v1'], 'FIMO-T1-QCM-03', false,
    $mft$Tout part de l'anticipation : le freinage évité est un double gain (l'énergie n'est pas dissipée, la relance n'est pas payée). Le point mort est proscrit : moins de contrôle et consommation au ralenti.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$L'expéditeur a chargé et arrimé votre semi-remorque. Avant de prendre la route, vous devez :$mft$,
    $mft$[
      {"id":"a","label":"Vérifier ce qui est visible (répartition, arrimage, fermetures) et signaler toute anomalie","is_correct":true},
      {"id":"b","label":"Partir directement : l'arrimage ne vous concerne pas","is_correct":false},
      {"id":"c","label":"Refaire systématiquement tout l'arrimage vous-même","is_correct":false},
      {"id":"d","label":"Demander une pesée officielle à chaque départ","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['fimo-fco','theme-1','qcm-v1'], 'FIMO-T1-QCM-04', false,
    $mft$Le conducteur est le dernier contrôle avant la route : vérification visuelle, réserves écrites en cas d'anomalie, refus motivé si la sécurité est compromise. Sur la route, c'est lui qui porte l'ensemble.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Pourquoi faut-il monter les rapports tôt avec un poids lourd moderne ?$mft$,
    $mft$[
      {"id":"a","label":"Parce que le couple maximal est disponible à bas régime : le moteur tire fort en consommant peu","is_correct":true},
      {"id":"b","label":"Parce que la puissance maximale se trouve au ralenti","is_correct":false},
      {"id":"c","label":"Pour user l'embrayage régulièrement","is_correct":false},
      {"id":"d","label":"Parce que la boîte l'exige mécaniquement","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','theme-1','qcm-v1'], 'FIMO-T1-QCM-05', false,
    $mft$Le couple maxi à bas régime permet de monter tôt et de rester en zone économique : conduire « au couple », pas « à la puissance ».$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Qu'est-ce que le « fading » ?$mft$,
    $mft$[
      {"id":"a","label":"La perte d'efficacité des freins provoquée par leur surchauffe","is_correct":true},
      {"id":"b","label":"L'usure normale des plaquettes","is_correct":false},
      {"id":"c","label":"Le blocage des roues au freinage","is_correct":false},
      {"id":"d","label":"La panne du ralentisseur","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','theme-1','qcm-v1'], 'FIMO-T1-QCM-06', false,
    $mft$Freins surchauffés par un usage continu (descente) : la pédale répond mais le véhicule ne ralentit plus. Prévention : ralentisseur en principal, frein de service par touches.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Quelle est la bonne technique pour aborder une longue descente en charge ?$mft$,
    $mft$[
      {"id":"a","label":"Engager un rapport bas AVANT la pente, activer le ralentisseur, ajuster au frein de service par appuis brefs","is_correct":true},
      {"id":"b","label":"Descendre au point mort pour économiser du carburant","is_correct":false},
      {"id":"c","label":"Garder le rapport de plaine et freiner en continu","is_correct":false},
      {"id":"d","label":"Activer le régulateur de vitesse et laisser faire","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','theme-1','qcm-v1'], 'FIMO-T1-QCM-07', false,
    $mft$La vitesse de descente doit rester « remontable » ; le rapport se choisit avant la pente ; le régulateur ne voit pas la pente et le point mort supprime le frein moteur : deux fautes graves.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Quel est le véritable apport de l'ABS lors d'un freinage d'urgence ?$mft$,
    $mft$[
      {"id":"a","label":"Il empêche le blocage des roues et permet de conserver la direction","is_correct":true},
      {"id":"b","label":"Il raccourcit fortement la distance de freinage","is_correct":false},
      {"id":"c","label":"Il freine à la place du conducteur","is_correct":false},
      {"id":"d","label":"Il empêche le renversement en courbe","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','theme-1','qcm-v1'], 'FIMO-T1-QCM-08', false,
    $mft$L'ABS préserve la dirigeabilité (éviter l'obstacle en freinant) ; il ne raccourcit pas la distance. L'anti-renversement relève de l'ESP, le freinage automatique d'urgence de l'AEBS.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$En décélération, pourquoi faut-il rester sur un rapport engagé plutôt que passer au point mort ?$mft$,
    $mft$[
      {"id":"a","label":"Parce que l'injection se coupe moteur entraîné : consommation quasi nulle, et le véhicule reste freiné et contrôlable","is_correct":true},
      {"id":"b","label":"Parce que le point mort use la boîte de vitesses","is_correct":false},
      {"id":"c","label":"Parce que le moteur cale au point mort","is_correct":false},
      {"id":"d","label":"C'est faux : le point mort consomme moins","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['fimo-fco','theme-1','qcm-v1'], 'FIMO-T1-QCM-09', false,
    $mft$Rapport engagé : coupure d'injection (0 consommation) + frein moteur + contrôle. Point mort : le moteur consomme au ralenti et le véhicule n'est plus retenu : double perte.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Où la consommation spécifique d'un moteur diesel de poids lourd est-elle minimale ?$mft$,
    $mft$[
      {"id":"a","label":"Autour du régime de couple maximal","is_correct":true},
      {"id":"b","label":"Au régime de puissance maximale","is_correct":false},
      {"id":"c","label":"Au ralenti","is_correct":false},
      {"id":"d","label":"En sur-régime","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['fimo-fco','theme-1','qcm-v1'], 'FIMO-T1-QCM-10', false,
    $mft$Le moteur convertit le mieux le gazole en travail autour du couple maxi : c'est la base de la conduite en zone verte. La puissance maxi coûte cher, le ralenti gaspille.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Votre chargement est haut et lourd (centre de gravité élevé). Quelle est la conséquence directe sur votre conduite ?$mft$,
    $mft$[
      {"id":"a","label":"Réduire nettement la vitesse en courbe et en rond-point : le risque de renversement augmente","is_correct":true},
      {"id":"b","label":"Aucune : l'ESP compense tout","is_correct":false},
      {"id":"c","label":"Augmenter la pression des pneumatiques avant","is_correct":false},
      {"id":"d","label":"Freiner plus fort en entrée de courbe","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['fimo-fco','theme-1','qcm-v1'], 'FIMO-T1-QCM-11', false,
    $mft$Centre de gravité haut = seuil de renversement abaissé : la vitesse en courbe se réduit AVANT l'entrée. L'ESP aide mais ne rattrape pas une vitesse d'entrée excessive.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Laquelle de ces sangles peut être utilisée pour arrimer un chargement ?$mft$,
    $mft$[
      {"id":"a","label":"Une sangle intacte dont l'étiquette de capacité est lisible","is_correct":true},
      {"id":"b","label":"Une sangle nouée pour la raccourcir","is_correct":false},
      {"id":"c","label":"Une sangle légèrement coupée sur la tranche","is_correct":false},
      {"id":"d","label":"Une sangle sans étiquette mais d'apparence solide","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['fimo-fco','theme-1','qcm-v1'], 'FIMO-T1-QCM-12', false,
    $mft$Coupée, nouée ou sans étiquette lisible = hors service. Le nœud divise la résistance ; sans étiquette, la capacité est inconnue : on ne dimensionne pas un arrimage à l'aveugle.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Comment appelle-t-on la plage du compte-tours où il faut faire rouler un poids lourd en croisière ?$mft$,
   $mft$La zone verte (plage du couple maximal, consommation minimale).$mft$,
   2, 'facile', ARRAY['fimo-fco','theme-1','question-courte'], 'FIMO-T1-QC-01', false,
   $mft$Accepter « zone verte » ou « zone économique ».$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Quel équipement permet de ralentir en continu dans une longue descente sans user les freins de service ?$mft$,
   $mft$Le ralentisseur (hydraulique ou électromagnétique), complété par le frein moteur.$mft$,
   2, 'facile', ARRAY['fimo-fco','theme-1','question-courte'], 'FIMO-T1-QC-02', false,
   $mft$Accepter « ralentisseur » seul.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Citez trois techniques d'éco-conduite.$mft$,
   $mft$Par exemple : anticiper (regarder loin, lever le pied tôt), utiliser l'inertie rapport engagé, rouler au couple en zone verte, stabiliser la vitesse, modérer la vitesse de pointe, supprimer les ralentis prolongés.$mft$,
   2, 'facile', ARRAY['fimo-fco','theme-1','question-courte'], 'FIMO-T1-QC-03', false,
   $mft$Trois techniques distinctes parmi les six.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Comment appelle-t-on la perte d'efficacité des freins due à leur surchauffe ?$mft$,
   $mft$Le fading.$mft$,
   2, 'moyen', ARRAY['fimo-fco','theme-1','question-courte'], 'FIMO-T1-QC-04', false,
   $mft$Provoqué par l'usage continu du frein de service, typiquement en descente.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Pourquoi dit-on qu'un poids lourd moderne se conduit « au couple » ?$mft$,
   $mft$Parce que le couple maximal est disponible à bas régime : on monte les rapports tôt et on tire la charge dans la zone la plus économe.$mft$,
   2, 'moyen', ARRAY['fimo-fco','theme-1','question-courte'], 'FIMO-T1-QC-05', false,
   $mft$L'idée : bas régime + couple = traction efficace et sobre.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Que garantit l'ABS lors d'un freinage d'urgence, et que ne fait-il PAS ?$mft$,
   $mft$Il empêche le blocage des roues et conserve la direction ; il ne raccourcit pas la distance de freinage.$mft$,
   2, 'moyen', ARRAY['fimo-fco','theme-1','question-courte'], 'FIMO-T1-QC-06', false,
   $mft$Les deux volets sont attendus (ce qu'il fait / ce qu'il ne fait pas).$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Énoncez la règle de vitesse pour aborder une longue descente en charge.$mft$,
   $mft$Descendre à une vitesse à laquelle on pourrait remonter, rapport bas engagé avant la pente.$mft$,
   2, 'moyen', ARRAY['fimo-fco','theme-1','question-courte'], 'FIMO-T1-QC-07', false,
   $mft$La formule « vitesse remontable » est l'élément clé.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$En freinage d'urgence, quelle poussée vers l'avant peut exercer un chargement de 10 tonnes mal arrimé ?$mft$,
   $mft$Une poussée pouvant approcher 8 tonnes (de l'ordre de 0,8 fois le poids de la charge).$mft$,
   2, 'moyen', ARRAY['fimo-fco','theme-1','question-courte'], 'FIMO-T1-QC-08', false,
   $mft$Accepter « environ 8 t » ou « 0,8 fois le poids ».$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Pourquoi la consommation est-elle quasi nulle en décélération rapport engagé ?$mft$,
   $mft$Parce que l'injection se coupe tant que le moteur est entraîné par le véhicule.$mft$,
   2, 'difficile', ARRAY['fimo-fco','theme-1','question-courte'], 'FIMO-T1-QC-09', false,
   $mft$La coupure d'injection : raison pour laquelle le point mort est contre-productif.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Citez trois défauts qui mettent une sangle d'arrimage hors service.$mft$,
   $mft$Une sangle coupée ou entaillée, une sangle nouée, une étiquette de capacité absente ou illisible (ou coutures endommagées).$mft$,
   2, 'difficile', ARRAY['fimo-fco','theme-1','question-courte'], 'FIMO-T1-QC-10', false,
   $mft$Trois défauts distincts attendus.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) — barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Expliquez ce que représentent le couple, la puissance et la consommation spécifique d'un moteur de poids lourd, et ce que ces trois courbes impliquent concrètement pour votre façon de conduire.$mft$,
   $mft$Réponse modèle. Le couple est la force de traction du moteur : sur un PL moderne il est maximal à bas régime et sur une plage large : c'est lui qui emmène la charge. La puissance (couple × régime) culmine à régime plus élevé : elle sert ponctuellement (forte côte, dépassement) mais coûte cher en carburant. La consommation spécifique (carburant consommé par unité de travail) est minimale autour du couple maximal : le moteur y est le plus efficient. Implications de conduite : rouler en zone verte (plage du couple maxi) en croisière ; monter les rapports tôt puisque le couple est disponible en bas ; n'aller chercher les hauts régimes que brièvement quand la puissance est réellement nécessaire ; jamais de sur-régime. Résultat : consommation en baisse, mécanique préservée, conduite plus souple : la lecture des trois courbes fonde toute l'éco-conduite.$mft$,
   $mft$Barème /5 : définitions justes des trois notions (2,25 pts : 0,75 chacune) ; localisation correcte (couple bas régime, conso mini au couple maxi) (1,25 pt) ; implications concrètes (zone verte, monter tôt, hauts régimes brefs) (1,5 pt). Erreurs fréquentes : confondre couple et puissance ; situer l'efficience au régime de puissance maxi.$mft$,
   5, 'facile', ARRAY['fimo-fco','theme-1','question-redigee'], 'FIMO-T1-QR-01', false,
   $mft$Le socle technique du thème 1, restitué avec ses conséquences pratiques.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Décrivez, dans l'ordre, la technique complète pour franchir en sécurité une descente de 6 km à 6 % avec un ensemble à pleine charge : préparation, conduite dans la pente, signaux d'alerte et réaction en cas de problème.$mft$,
   $mft$Réponse modèle. Préparation (avant la pente) : réduire l'allure, engager un rapport bas adapté (règle : une vitesse à laquelle on pourrait remonter la même pente), activer le ralentisseur, vérifier l'espacement avec le véhicule suivant. Dans la pente : le ralentisseur et le frein moteur assurent la retenue principale ; le frein de service s'utilise par appuis brefs et fermes pour réajuster la vitesse, jamais en continu ; vitesse stable, distance longue, pas de changement de rapport dans la partie raide. Signaux d'alerte : odeur de garnitures chaudes, pédale qui s'allonge, vitesse qui dérive malgré le ralentisseur. Réaction : appuyer fort immédiatement pour casser la vitesse tant que les freins mordent encore, rétrograder si possible, augmenter la retenue (ralentisseur au maximum) ; si l'emballement se confirme : klaxon et feux de détresse, viser l'aire de détresse ou un échappatoire montant ; ne jamais couper le moteur (perte d'assistance) ni passer au point mort. Après la descente : laisser refroidir les freins avant tout arrêt prolongé frein serré.$mft$,
   $mft$Barème /5 : préparation complète avec la règle de la vitesse remontable (1,5 pt) ; retenue principale au ralentisseur + freins par touches (1,5 pt) ; signaux d'alerte (0,75 pt) ; réaction d'urgence correcte dont l'aire de détresse et l'interdit du moteur coupé (1,25 pt). Erreurs fréquentes : freiner en continu ; choisir le rapport dans la pente ; point mort.$mft$,
   5, 'facile', ARRAY['fimo-fco','theme-1','question-redigee'], 'FIMO-T1-QR-02', false,
   $mft$La descente longue : procédure complète, question de mise en situation type.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Construisez votre plan personnel d'éco-conduite : six techniques concrètes, l'effet attendu de chacune, et le lien entre cette conduite et la sécurité.$mft$,
   $mft$Réponse modèle. 1) Anticiper (regarder 300-500 m devant, lever le pied dès qu'un ralentissement se profile) : supprime les freinages et relances inutiles : le premier gisement de carburant. 2) Utiliser l'inertie rapport engagé : coupure d'injection : consommation quasi nulle sur les phases de décélération. 3) Rouler au couple en zone verte, monter les rapports tôt : le moteur travaille dans sa plage efficiente. 4) Stabiliser la vitesse (régulateur sur le plat, pied constant ailleurs) : le yo-yo d'accélérateur se paie cash. 5) Modérer la vitesse de pointe de quelques km/h : gain net sur la traînée et la consommation, temps de parcours quasi inchangé. 6) Chasser les consommations parasites : ralenti prolongé coupé, pressions des pneus vérifiées, déflecteurs réglés à la hauteur de la caisse. Lien sécurité : anticipation = distances augmentées et urgences évitées ; vitesse stabilisée et modérée = marges accrues et stress réduit : les indicateurs de consommation et de sinistralité s'améliorent ensemble, car c'est la même conduite calme et lue loin devant.$mft$,
   $mft$Barème /5 : six techniques distinctes et correctes (3 pts : 0,5 chacune) ; effets pertinents associés (1 pt) ; lien éco-conduite/sécurité argumenté (1 pt). Erreurs fréquentes : citer le point mort comme technique ; réduire l'éco-conduite à « rouler lentement ».$mft$,
   5, 'moyen', ARRAY['fimo-fco','theme-1','question-redigee'], 'FIMO-T1-QR-03', false,
   $mft$Plan d'action individuel : la question d'appropriation du thème.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Cas chiffré. La télématique affiche pour Mehdi 36 L/100 km quand la moyenne de la flotte, à tournées comparables, est de 31 L/100 km. Il parcourt 120 000 km par an. a) Chiffrez le surcoût annuel de carburant (prenez 1,60 €/L en valeur d'étude). b) Identifiez les causes probables à examiner dans ses données. c) Proposez un accompagnement en trois étapes.$mft$,
   $mft$Réponse modèle. a) Écart : 36 − 31 = 5 L/100 km ; sur 120 000 km : 5 × 1 200 = 6 000 litres par an ; à 1,60 €/L (valeur d'étude, à ajuster au prix réel) : 9 600 € de surcoût annuel pour un seul véhicule : l'enjeu justifie largement un accompagnement individuel. b) Causes probables à lire dans la télématique : freinages fréquents et tardifs (défaut d'anticipation), régimes élevés (rapports montés tard), vitesse de pointe systématiquement haute, yo-yo d'accélérateur, ralenti moteur prolongé (pauses, quais), éventuellement pressions de pneus ou déflecteurs mal réglés (à vérifier sur le véhicule pour ne pas tout imputer au conducteur). c) Accompagnement : 1) entretien factuel et bienveillant : présenter les données SANS accusation, écouter (tournées réellement comparables ? véhicule en état ?) ; 2) audit de conduite embarqué (formateur ou conducteur référent) puis objectifs ciblés sur 2-3 indicateurs, pas dix ; 3) suivi mensuel des mêmes indicateurs avec retour régulier, valorisation des progrès (reconnaissance, prime éco-conduite le cas échéant) et rappel en FCO. L'expérience montre des gains rapides de 2 à 4 L/100 quand l'accompagnement est individualisé et non punitif.$mft$,
   $mft$Barème /5 : calcul exact 6 000 L et 9 600 € avec la réserve sur le prix (2 pts) ; causes lues dans les données + réflexe de vérifier le véhicule (1,5 pt) ; accompagnement en trois étapes non punitif avec suivi (1,5 pt). Erreurs fréquentes : erreur d'échelle sur les litres ; plan 100 % sanction ; ignorer l'hypothèse véhicule.$mft$,
   5, 'moyen', ARRAY['fimo-fco','theme-1','question-redigee'], 'FIMO-T1-QR-04', false,
   $mft$Cas télématique chiffré : l'argent de l'éco-conduite, calcul vérifié.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Décrivez votre tour du véhicule technique complet avant un départ en tournée chargée : les points à contrôler dans l'ordre de votre cheminement, et ce qui vous ferait refuser de partir.$mft$,
   $mft$Réponse modèle. Cheminement type (de la cabine, en tournant autour) : 1) Cabine : niveaux et témoins (pression d'air, AdBlue), pare-brise et rétroviseurs propres, tachygraphe fonctionnel avec MA carte. 2) Avant : éclairage et clignotants, plaque, état du pare-chocs, fuites au sol. 3) Côtés : pneumatiques (usure visible, flancs sans blessure, pressions plausibles), passages de roues, réservoirs bouchés, béquilles remontées, sangles latérales de la bâche. 4) Attelage : sellette verrouillée (tirette), flexibles et connexions branchés sans frottement, béquilles hautes. 5) Arrière : feux, plaque, barre anti-encastrement, portes ou hayon verrouillés. 6) Chargement : répartition visible cohérente, arrimage tendu, protections d'arêtes en place, rien en appui sur les portes. Refus de partir (ou correction préalable) : pneu entaillé ou sous-gonflé manifeste, fuite d'air audible, feux stop hors service, sellette non verrouillée, arrimage insuffisant ou charge visiblement déséquilibrée, tachygraphe ou carte défaillants : la tournée attend, la sécurité non. Trace : anomalies signalées à l'exploitation (et réserves écrites si le chargement vient d'un tiers).$mft$,
   $mft$Barème /5 : cheminement structuré et complet (2 pts) ; points critiques présents (pneus, air, attelage, feux, arrimage) (1,5 pt) ; critères de refus fermes (1 pt) ; signalement/trace (0,5 pt). Erreurs fréquentes : tour limité aux feux ; oublier la sellette ; partir « en signalant plus tard ».$mft$,
   5, 'moyen', ARRAY['fimo-fco','theme-1','question-redigee'], 'FIMO-T1-QR-05', false,
   $mft$Le walk-around professionnel : gestes et critères de refus.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Récit d'incident. Dans une descente, un conducteur garde son rapport de plaine et freine en continu ; à mi-pente, la pédale s'allonge et le camion accélère. Il coupe le contact, paniqué, puis parvient à s'arrêter sur une aire de détresse. Analysez les erreurs commises une à une et reconstituez la conduite correcte.$mft$,
   $mft$Réponse modèle. Erreurs : 1) rapport de plaine conservé : frein moteur quasi nul, toute la retenue repose sur les freins de service ; 2) freinage en continu : montée en température des garnitures jusqu'au fading (pédale longue, efficacité effondrée) : c'est la cause directe de l'emballement ; 3) couper le contact en roulant : faute grave : perte de l'assistance de direction et de systèmes essentiels, risque de blocage de direction : la panique a ajouté un danger majeur ; 4) implicitement : vitesse d'entrée en pente trop élevée et ralentisseur non utilisé. Points positifs : l'aire de détresse a été utilisée : bon réflexe final. Conduite correcte : avant la pente : réduire fortement l'allure, engager un rapport bas (vitesse « remontable »), activer le ralentisseur ; dans la pente : retenue principale au ralentisseur/frein moteur, appuis de frein brefs et fermes pour réajuster ; aux premiers signes de surchauffe : casser la vitesse immédiatement tant que les freins répondent, augmenter la retenue, viser l'échappatoire ; moteur TOUJOURS en marche. Leçon : la descente se gagne AVANT la pente ; ensuite on ne fait que gérer.$mft$,
   $mft$Barème /5 : les trois erreurs majeures identifiées et expliquées (rapport, freinage continu→fading, contact coupé) (2,25 pts) ; reconstitution correcte avant/pendant (1,75 pt) ; réflexe d'urgence (casser la vitesse tôt, échappatoire) (0,75 pt) ; leçon de synthèse (0,25 pt). Erreurs fréquentes : ne pas voir la gravité du contact coupé ; corriger par « freiner plus fort » sans traiter le rapport.$mft$,
   5, 'difficile', ARRAY['fimo-fco','theme-1','question-redigee'], 'FIMO-T1-QR-06', false,
   $mft$Analyse d'incident de descente : erreurs en cascade et procédure correcte.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Tournée du jour : 24 palettes (les 8 plus lourdes à 600 kg, 16 à 250 kg) pour trois clients livrés dans l'ordre A (8 palettes légères), B (8 lourdes), C (8 légères). Construisez votre plan de chargement et vos gestes à chaque étape de la tournée.$mft$,
   $mft$Réponse modèle. Principes : dernier livré = chargé en premier (fond) ; lourdes centrées sur les essieux, en bas ; répartition gauche/droite symétrique ; chaque zone bloquée ou arrimée. Plan : au fond, les 8 palettes légères de C (250 kg) réparties sur deux rangées équilibrées ; au centre (zone des essieux porteurs), les 8 lourdes de B (600 kg = 4,8 t) plancher bas, deux files symétriques, antiglisse + sangles ; à l'entrée, les 8 légères de A pour un déchargement rapide en premier arrêt. Vérifications au départ : poids total (8 × 600 + 16 × 250 = 4 800 + 4 000 = 8 800 kg) compatible avec la charge utile, répartition visible, sangles tendues. Étape A (départ des 8 légères d'entrée) : re-tendre les sangles du bloc central, vérifier que rien n'a glissé. Étape B (départ des 8 lourdes du centre) : la remorque perd 4,8 t d'un coup : re-répartir les 8 palettes restantes de C vers la zone des essieux (ne pas les laisser au fond seul : essieu arrière déchargé, adhérence directrice modifiée), re-arrimer complètement. Étape C : déchargement final, sangles rangées, tapis récupérés. Fil rouge : après CHAQUE livraison, une minute de re-répartition/re-tension évite le chargement baladeur de fin de tournée.$mft$,
   $mft$Barème /5 : ordre de chargement inverse des livraisons (1 pt) ; lourdes au centre/en bas avec symétrie (1,25 pt) ; calcul de poids exact 8 800 kg et contrôle CU (0,75 pt) ; gestes aux étapes dont la re-répartition après B (1,5 pt) ; arrimage/antiglisse mentionnés (0,5 pt). Erreurs fréquentes : charger dans l'ordre des livraisons ; laisser les dernières palettes au fond après B.$mft$,
   5, 'difficile', ARRAY['fimo-fco','theme-1','question-redigee'], 'FIMO-T1-QR-07', false,
   $mft$Plan de chargement multi-clients avec re-répartition : le cas pratique du quotidien.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un collègue affirme : « l'éco-conduite, c'est bon pour les chronos de bureau : moi je perds du temps et le client attend ». Réfutez cet argument point par point, chiffres et mécanismes à l'appui.$mft$,
   $mft$Réponse modèle. 1) Le temps « perdu » est marginal : la vitesse MOYENNE d'une tournée dépend des arrêts, feux, giratoires et temps de quai bien plus que de la vitesse de pointe ; réduire la pointe de quelques km/h coûte quelques minutes par jour, souvent récupérées par une conduite plus fluide (moins de freinages-relances, files mieux anticipées). 2) Les gains sont massifs et mesurables : plusieurs L/100 km d'écart entre conducteurs, soit des milliers de litres par an et par véhicule (5 L/100 sur 120 000 km = 6 000 L) : de quoi financer des primes éco-conduite dont le conducteur profite directement. 3) La sécurité suit : l'anticipation qui économise le gazole est exactement celle qui évite l'accrochage ; moins d'accidents = moins d'immobilisations, de constats, de stress : du temps GAGNÉ. 4) Le confort aussi : conduite plus calme, moins de fatigue en fin de journée, mécanique préservée (moins de pannes, encore du temps gagné). 5) L'image professionnelle : télématique à l'appui, l'éco-conduite est devenue un critère d'évaluation et d'employabilité. Conclusion : l'opposition vitesse/rentabilité est une illusion de pointe ; à l'échelle d'une tournée réelle, l'éco-conduite rend du temps, de l'argent et de la marge de sécurité.$mft$,
   $mft$Barème /5 : argument vitesse moyenne vs vitesse de pointe (1,5 pt) ; chiffrage du gain carburant (1 pt) ; lien sécurité/temps gagné (1 pt) ; arguments confort/mécanique/image (1 pt) ; qualité de la réfutation structurée (0,5 pt). Erreurs fréquentes : concéder la perte de temps sans la quantifier ; répondre par l'autorité (« c'est obligatoire ») au lieu des mécanismes.$mft$,
   5, 'difficile', ARRAY['fimo-fco','theme-1','question-redigee'], 'FIMO-T1-QR-08', false,
   $mft$Argumentation contre l'objection classique : exercice d'adhésion, pas de contrainte.$mft$);

  RAISE NOTICE 'Thème 1 FIMO/FCO créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $fimot1$;

-- =====================================================================
-- CONTRÔLES POST-EXÉCUTION
-- =====================================================================
-- 1) Volumes : select "type", active, count(*) from question_bank
--     where source_ref like 'FIMO-T1-%' group by 1, 2;
--    → attendu : qcm/false = 12, qr/false = 18.
-- 2) QCM à bonne réponse unique :
--    select source_ref from question_bank
--     where source_ref like 'FIMO-T1-QCM-%'
--       and (select count(*) from jsonb_array_elements(choices) c
--             where (c->>'is_correct')::boolean) <> 1;   → 0 ligne.
-- 3) Doublons d'énoncés sur la formation :
--    select statement, count(*) from question_bank
--     where formation_id = (select id from formations where slug='fimo-fco')
--     group by 1 having count(*) > 1;                    → 0 ligne.
