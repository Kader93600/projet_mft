-- =====================================================================
-- ERTV : EXPLOITANT EN TRANSPORT ROUTIER DE VOYAGEURS
-- MODULE 3 : EXPLOITER ET RÉGULER AU QUOTIDIEN (v1, juillet 2026)
--
-- La journée de l'exploitation voyageurs : préparation de la veille,
-- sorties de dépôt, suivi temps réel (SAEIV), régulation des aléas,
-- information des voyageurs et pilotage par les indicateurs.
-- ⚠ STATUT : questions insérées avec active = false (« à valider »).
-- Idempotent : DELETE ciblés par source_ref ERTV-M3-% et slug du module.
-- =====================================================================

DO $ertvm3$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_l4 uuid;
  v_quiz uuid; v_q uuid; v_ord int := 0;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'ertv';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation ertv introuvable.'; END IF;

  INSERT INTO public.blocs (id, code, title, description, "order") VALUES (70, 'ERTV', 'Exploitant en transport routier de voyageurs', 'Concevoir, exploiter et réguler des services de transport routier de voyageurs : cadre réglementaire, graphicage, exploitation, social, sécurité et qualité.', 70) ON CONFLICT DO NOTHING;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'ERTV';

  DELETE FROM public.question_bank WHERE source_ref LIKE 'ERTV-M3-%';
  DELETE FROM public.modules WHERE slug = 'ertv-exploitation-regulation';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 3 : Exploiter et réguler au quotidien',
    'ertv-exploitation-regulation', v_bloc,
    'La journée de l''exploitation voyageurs : affectations, régulation en temps réel des aléas, information des voyageurs et pilotage par les indicateurs.',
    'avance', 330, 30) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 30, true);

  -- ─── Leçon 1 : La journée d'exploitation ────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'la-journee-d-exploitation',
    'La journée d''exploitation',
    $mft$> 🎯 **Objectifs**
> - Préparer la veille une journée d'exploitation qui tient la route.
> - Réussir les sorties de dépôt du matin et suivre la production en temps réel avec le SAEIV.
> - Tenir une main courante d'exploitation qui protège l'entreprise.

## Une journée d'exploitation se gagne la veille

Une journée réussie ne commence pas à 5 h du matin : elle commence la veille, quand l'exploitant verrouille trois chantiers.

| Chantier de la veille | La question à laquelle il faut savoir répondre |
| --- | --- |
| Affectations conducteurs | Chaque service a-t-il son conducteur, absences comprises ? |
| Affectations véhicules | Chaque service a-t-il un véhicule réellement disponible ? |
| Aléas déjà connus | Travaux, manifestation, météo annoncée : qu'a-t-on anticipé ? |

**Les conducteurs.** Chaque service doit avoir un nom en face. Les absences connues (congés, maladie déclarée, formation) se traitent la veille par des remplacements organisés, pas au petit matin dans l'urgence. Un tableau d'affectations bouclé la veille, c'est un dépôt calme le lendemain.

**Les véhicules.** Le plan de transport se croise avec la disponibilité réelle du parc, en dialogue quotidien avec la maintenance : un véhicule immobilisé à l'atelier sort de la liste, un véhicule apte prend sa place. Affecter un véhicule « sur le papier » sans vérifier son état réel, c'est fabriquer la panne de demain matin.

**Les aléas connus.** Les travaux annoncés, la manifestation déclarée, l'épisode météo prévu s'intègrent dès la veille : consignes, itinéraires, renforts éventuels.

## Le matin : la sortie de dépôt, moment de vérité

> ⚠️ **Attention**
> Un départ raté au dépôt ne se rattrape presque jamais : la première course part en retard, fait rater des correspondances, décale la course suivante du même véhicule, qui décale la suivante. Un seul raté à 6 h peut se payer jusqu'à midi : c'est l'effet cascade.

Le matin, tout doit être joué d'avance : chaque conducteur sait quel véhicule prendre et quel service assurer, les documents sont prêts, l'encadrement est présent pour traiter en direct les imprévus de prise de service (retardataire, véhicule qui ne démarre pas). La ponctualité du réseau entier se décide dans la cour du dépôt.

## Suivre la journée en temps réel : le SAEIV

Le SAEIV (système d'aide à l'exploitation et information voyageurs) est l'outil central du poste de régulation. Chaque véhicule est géolocalisé ; sa position est comparée en continu à l'horaire théorique ; l'écran affiche l'avance ou le retard de chaque course. Le régulateur ne découvre plus les problèmes par téléphone : il les voit naître, course par course, et peut agir avant que le voyageur ne subisse. Une avance se surveille d'ailleurs autant qu'un retard : un véhicule qui passe avant l'heure laisse des voyageurs à l'arrêt.

:::timeline
1. **La veille** : affectations conducteurs et véhicules verrouillées, remplacements organisés, point maintenance, aléas connus anticipés.
2. **Le matin** : sorties de dépôt à l'heure, traitement immédiat des imprévus de prise de service.
3. **En journée** : suivi SAEIV en continu, régulation des aléas, information des voyageurs.
4. **Le soir** : main courante consolidée, débrief des incidents, préparation du lendemain.
:::

## La main courante : tout écrire, toujours

La main courante d'exploitation est le journal de bord de la journée : chaque événement y entre avec son heure, sa description factuelle, la décision prise et le résultat. Sa règle est simple : tracer TOUT, même ce qui semble anodin sur le moment.

> 📌 **À retenir**
> La main courante est la base des réponses à l'autorité organisatrice (AO) et des litiges. Des mois plus tard, quand l'AO demande des comptes sur une course non réalisée ou qu'un voyageur conteste, la main courante est la seule mémoire fiable : ce qui n'a pas été tracé n'existe plus.

> 💡 **Astuce**
> Écrivez les faits au moment où ils se produisent, pas en fin de journée de mémoire : une main courante reconstituée le soir perd les heures exactes, et c'est précisément ce détail qui fait la différence dans un dossier.

## ✅ Synthèse

- La journée se prépare **la veille** : conducteurs affectés (absences remplacées), véhicules réellement disponibles (dialogue maintenance), aléas connus anticipés.
- Le matin, **les sorties de dépôt à l'heure** sont vitales : un départ raté se propage en cascade.
- Le **SAEIV** donne la vision temps réel (géolocalisation, avance/retard) ; la **main courante** trace tout : c'est la base des réponses à l'AO et des litiges.$mft$,
    $mft$La préparation de la veille (conducteurs, véhicules, aléas connus), les sorties de dépôt et l'effet cascade, le suivi temps réel par le SAEIV et la main courante qui trace tout.$mft$,
    1, 40) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : Réguler les aléas ────────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'reguler-les-aleas',
    'Réguler les aléas : la boîte à outils',
    $mft$> 🎯 **Objectifs**
> - Mobiliser la bonne réponse face à chaque famille d'aléas.
> - Prioriser quand tout arrive en même temps : sécurité, scolaires et correspondances, régularité.
> - Décider vite, dans le respect du cadre social, et tracer chaque décision.

## La boîte à outils du régulateur

Chaque famille d'aléas appelle une réponse type, connue à l'avance : le régulateur ne réinvente pas la solution sous pression, il déclenche un scénario préparé.

| Aléa | Réponse type |
| --- | --- |
| Retard simple | Absorber au battement du terminus, informer les voyageurs |
| Bouchon, route coupée | Déclencher un itinéraire de repli préparé à l'avance |
| Panne en ligne | Sécuriser, envoyer le véhicule de réserve, transborder en sécurité |
| Conducteur manquant | Réserve, rappel d'un volontaire, recomposition des services |
| Incident voyageur | Procédure : sécuriser, secours si besoin, tracer |

**Le retard simple.** C'est l'aléa quotidien : il s'absorbe au battement du terminus, ce temps tampon prévu au graphicage entre deux courses. Tant que le battement encaisse, la course suivante part à l'heure ; le travail du régulateur se limite à surveiller et à informer.

**Le bouchon et la déviation.** Un bon itinéraire de repli se prépare au bureau, à froid, pas dans la panique : gabarit des rues vérifié, arrêts de substitution repérés, consignes écrites. Le jour J, on déclenche, on diffuse aux conducteurs, on informe sur les arrêts non desservis.

**La panne en ligne.** Trois gestes : mettre les voyageurs en sécurité, envoyer le véhicule de réserve, organiser le transbordement en sécurité (à l'endroit adapté, jamais dans la précipitation). Le dépannage du véhicule vient après les personnes.

**Le conducteur manquant.** L'escalade est connue : conducteur de réserve, rappel d'un volontaire dont la situation le permet, puis recomposition des services (arbitrer les courses, concentrer les moyens sur les priorités).

> ❌ **Piège à éviter**
> Le « bricolage illégal » : faire rouler un conducteur dont le cadre social ne le permet plus pour boucher un trou. La recomposition des services se fait TOUJOURS dans le respect du cadre social : un dépannage qui le viole fabrique un risque juridique et un risque de sécurité bien pires que la course supprimée.

**L'incident voyageur.** Malaise à bord : arrêt, appel des secours selon la procédure, pas de reprise avant leur feu vert. Conflit entre voyageurs ou avec le conducteur : procédure, appui de l'exploitation, jamais d'héroïsme individuel.

## Prioriser quand tout tombe en même temps

Le vrai quotidien du régulateur, ce sont les aléas simultanés. L'ordre de traitement ne se discute pas :

1. **La sécurité** : toute situation où des personnes sont en danger passe devant tout le reste.
2. **Les scolaires et les correspondances** : un car scolaire qui n'arrive pas ou une correspondance ratée ont des conséquences humaines immédiates.
3. **La régularité** : le bus urbain à quelques minutes de retard attendra son tour.

## Décider vite et tracer

:::flow
1. Qualifier | Quel aléa, où, combien de voyageurs concernés, quel risque
2. Sécuriser | Les personnes d'abord : voyageurs, conducteur, tiers
3. Décider | La moins mauvaise solution disponible maintenant, dans le cadre social
4. Informer | Conducteurs, voyageurs, AO selon la règle convenue
5. Tracer | Main courante : heure, faits, décision, résultat
:::

> 💡 **Astuce**
> Une décision correcte prise en trois minutes vaut mieux qu'une décision parfaite prise en trente : en régulation, le temps fait partie du problème. On décide avec ce qu'on sait, on ajuste ensuite, et on trace tout.

> 🎓 **Le réflexe du professionnel**
> Après chaque incident significatif, un débrief court : la réponse type a-t-elle fonctionné ? L'itinéraire de repli était-il à jour ? C'est ainsi que la boîte à outils s'améliore d'un aléa à l'autre.

## ✅ Synthèse

- Chaque aléa a sa **réponse type** : battement (retard), repli préparé (déviation), réserve et transbordement (panne), escalade licite (conducteur manquant), procédure (incident voyageur).
- Priorité invariable : **sécurité, puis scolaires et correspondances, puis régularité**.
- **Décider vite, dans le cadre social, et tout tracer** dans la main courante : jamais de bricolage illégal.$mft$,
    $mft$Les réponses types par famille d'aléas (retard, déviation, panne, conducteur manquant, incident voyageur), la priorisation sécurité puis scolaires/correspondances puis régularité, et la décision rapide tracée.$mft$,
    2, 45) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : Informer les voyageurs ───────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'informer-les-voyageurs',
    'Informer les voyageurs, surtout quand ça va mal',
    $mft$> 🎯 **Objectifs**
> - Construire une information voyageurs utile en situation perturbée.
> - Choisir les bons canaux et coordonner la communication avec l'AO.
> - Traiter les publics sensibles, scolaires en tête.

## La moitié de la qualité perçue

À perturbation égale, deux réseaux ne laissent pas le même souvenir. Celui qui informe (ce qui se passe, ce que ça change, ce qu'on propose) transforme des voyageurs qui subissent en voyageurs qui comprennent ; celui qui se tait transforme un retard de vingt minutes en rancune durable. C'est pourquoi on dit que **l'information en situation perturbée fait la moitié de la qualité perçue** : le voyageur pardonne l'aléa, il ne pardonne pas le silence.

## Les canaux à orchestrer

| Canal | Usage type |
| --- | --- |
| Girouettes | Destination et mention de déviation visibles sur le véhicule |
| Annonces à bord | Information directe des voyageurs déjà transportés |
| Appli et SMS de l'AO | Alertes poussées vers les voyageurs abonnés |
| Affichage aux arrêts | Temps d'attente, perturbations, arrêts non desservis |
| Réseaux sociaux du réseau | Perturbations majeures, suivi en continu, réponses |

Aucun canal ne suffit seul : le voyageur à l'arrêt ne voit pas l'appli, l'abonné à l'appli n'est pas encore à l'arrêt. L'information efficace est la même sur tous les canaux, adaptée au format de chacun.

## Les règles d'or

- **Dire ce qu'on SAIT** : des faits, pas des suppositions. « Un accident bloque l'avenue depuis 7 h 50 » vaut mieux qu'un vague « perturbations en cours ».
- **Quand on ne sait pas : dire quand on saura.** « Prochain point à 8 h 30 » est une information en soi : elle donne au voyageur un rendez-vous au lieu d'un vide.
- **Donner des solutions** : prochain passage, itinéraire bis, correspondance possible. Le voyageur informé d'une solution redevient acteur de son trajet.

:::flow
1. Les faits | Ce qui se passe, où, depuis quand
2. L'impact | Ce que ça change : retard estimé, arrêts non desservis
3. La solution | Prochain passage, itinéraire bis, alternative
4. Le rendez-vous | Quand la prochaine information sera donnée
:::

> ❌ **Piège à éviter**
> Promettre une durée inventée « pour calmer » : le « c'est réglé dans dix minutes » démenti vingt minutes plus tard détruit la confiance pour longtemps. L'autre piège symétrique : le silence en espérant que ça passe. Les voyageurs préfèrent une incertitude annoncée à une certitude fausse.

## Qui communique quoi : la coordination avec l'AO

Plusieurs canaux appartiennent à l'autorité organisatrice (appli, SMS) quand d'autres sont tenus par l'exploitant (véhicules, arrêts, poste de régulation). La règle « qui communique quoi » se convient à l'avance avec l'AO : sans elle, on obtient des messages contradictoires (l'appli annonce une reprise quand le terrain annonce une suppression), et la contradiction est pire que l'absence d'information. En situation majeure, un point de contact unique de chaque côté maintient la cohérence.

## Les publics sensibles : les scolaires d'abord

Un autocar scolaire qui n'arrive pas déclenche l'inquiétude des familles en quelques minutes. Les scolaires relèvent donc d'un traitement à part : **information des établissements et des familles selon le protocole** défini avec l'AO (qui prévient qui, par quel moyen, à partir de quel événement). Anticiper (la veille quand l'aléa est prévisible, comme la neige annoncée) plutôt que subir les appels de parents sans réponse.

> 📌 **À retenir**
> Une information voyageurs se juge à quatre éléments : les faits, l'impact, la solution, le rendez-vous. Si votre message contient les quatre, il est bon ; s'il en manque un, complétez-le avant de diffuser.

## ✅ Synthèse

- L'information en situation perturbée fait **la moitié de la qualité perçue** : le silence coûte plus cher que l'aléa.
- Règles d'or : **dire ce qu'on sait, annoncer quand on saura, donner des solutions** ; message structuré faits, impact, solution, rendez-vous.
- Canaux multiples (girouettes, annonces, appli/SMS de l'AO, arrêts, réseaux sociaux) coordonnés avec l'AO ; **scolaires : établissements et familles selon le protocole**.$mft$,
    $mft$L'information en situation perturbée (la moitié de la qualité perçue), les canaux et leur orchestration, les règles d'or (dire ce qu'on sait, quand on saura, des solutions), la coordination AO et le protocole scolaires.$mft$,
    3, 40) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : Piloter par les indicateurs ──────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'piloter-par-les-indicateurs',
    'Piloter par les indicateurs',
    $mft$> 🎯 **Objectifs**
> - Connaître les indicateurs contractuels et ce qu'ils mesurent vraiment.
> - Mesurer honnêtement, analyser les causes racines et bâtir des plans d'action.
> - Faire de la revue mensuelle avec l'AO un outil d'amélioration, pas un tribunal.

## Les indicateurs du contrat

Le contrat avec l'autorité organisatrice ne se pilote pas au ressenti : il se pilote avec des indicateurs définis, mesurés et suivis.

| Indicateur | Ce qu'il mesure |
| --- | --- |
| Ponctualité | La part des passages « à l'heure », la fenêtre étant définie au contrat |
| Régularité | La fréquence tenue sur les lignes exploitées à intervalle |
| Taux de service | Les courses réalisées rapportées aux courses prévues |
| Propreté | L'état des véhicules et des espaces voyageurs |
| Réclamations | Le volume des plaintes et la qualité de leur traitement |

> 📌 **À retenir**
> « À l'heure » n'est pas une intuition : c'est une **fenêtre définie au contrat**. Avant de discuter un chiffre de ponctualité, vérifiez la définition contractuelle de la fenêtre : c'est elle qui fait foi, pas l'impression du terrain.

## Mesurer honnêtement

La source de la mesure, c'est le SAEIV : les positions et horodatages des véhicules alimentent les indicateurs sans intervention manuelle. La tentation d'arranger un chiffre existe toujours ; elle est doublement perdante : un indicateur maquillé se retourne contre l'exploitant quand l'écart éclate, et surtout il le prive de son propre outil de pilotage. On ne corrige pas un problème qu'on s'est caché à soi-même.

## Analyser les causes racines

Un indicateur qui se dégrade est un symptôme : le travail commence quand on cherche la cause racine.

> 🔍 **Focus : le retard de 7 h 40**
> La course de 7 h 40 arrive en retard presque tous les jours, quel que soit le conducteur. Ce n'est pas une affaire de personnes : un retard qui se répète à la même heure avec des conducteurs différents désigne le graphique. Le temps de parcours a été sous-évalué au graphicage : la bonne réponse est de **re-graphiquer la course**, pas de presser les conducteurs. Presser les conducteurs sur un temps intenable dégrade la sécurité et le climat social, et le retard reviendra demain.

:::flow
1. Mesurer | Données SAEIV fiables, sans maquillage
2. Analyser | Chercher la cause racine, pas le coupable commode
3. Agir | Plan d'action daté, avec un responsable par action
4. Vérifier | L'indicateur bouge-t-il le mois suivant ?
5. Rendre compte | Revue mensuelle avec l'AO
:::

## La revue mensuelle avec l'AO

La revue mensuelle est le rendez-vous où l'exploitant présente ses indicateurs, ses analyses et ses plans d'action. Deux postures possibles : la défensive (minimiser, contester, cacher), qui installe la méfiance et transforme chaque revue en tribunal ; ou la transparence outillée (chiffres honnêtes, causes identifiées, actions datées, résultats du mois précédent), qui installe la confiance et donne à l'exploitant la main sur l'agenda. Une AO qui voit les problèmes traités avant qu'elle les soulève devient un partenaire.

> 💡 **Astuce**
> Les pénalités évitées financent les améliorations : chaque point d'indicateur regagné, ce sont des pénalités contractuelles en moins, et ces sommes financent précisément ce qui fiabilise le service (re-graphicage, réserve, maintenance). C'est un cercle vertueux : la qualité paie la qualité. L'inverse existe aussi : dissimulation, pénalités, méfiance, contentieux.

## ✅ Synthèse

- Indicateurs contractuels : **ponctualité (fenêtre du contrat), régularité, taux de service (réalisé/prévu), propreté, réclamations**.
- **Mesurer honnêtement** avec le SAEIV : un chiffre maquillé prive l'exploitant de son propre pilotage.
- **Cause racine avant plan d'action** : un retard récurrent à heure fixe se re-graphique, il ne se « presse » pas ; revue mensuelle en transparence : les pénalités évitées financent les améliorations.$mft$,
    $mft$Les indicateurs contractuels (ponctualité, régularité, taux de service, propreté, réclamations), la mesure honnête par le SAEIV, l'analyse des causes racines (re-graphiquer plutôt que presser) et la revue mensuelle avec l'AO.$mft$,
    4, 40) RETURNING id INTO v_l4;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : Exploiter et réguler au quotidien',
    'Vérifiez le module 3 : journée d''exploitation, régulation des aléas, information voyageurs et pilotage par les indicateurs.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$En préparant la journée du lendemain, l'exploitant découvre qu'un conducteur sera en formation et qu'un autocar est immobilisé à l'atelier. Que fait-il ?$mft$,
    $mft$[
      {"id":"a","label":"Il organise dès la veille le remplacement du conducteur et affecte un autre véhicule réellement disponible","is_correct":true},
      {"id":"b","label":"Il attend le matin pour voir si le problème se règle de lui-même","is_correct":false},
      {"id":"c","label":"Il supprime par précaution toutes les courses concernées","is_correct":false},
      {"id":"d","label":"Il exige de l'atelier la restitution du véhicule avant la fin de la maintenance","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ertv','module-3','qcm-v1'], 'ERTV-M3-QCM-01', false,
    $mft$La préparation de la veille consiste exactement à cela : absences remplacées et parc vérifié avec la maintenance. Attendre le matin ou amputer l'offre transforme un imprévu géré en crise.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Pourquoi une sortie de dépôt ratée sur la première course du matin est-elle particulièrement redoutée en exploitation voyageurs ?$mft$,
    $mft$[
      {"id":"a","label":"Parce que le retard se propage en cascade sur toutes les courses suivantes du véhicule et du conducteur","is_correct":true},
      {"id":"b","label":"Parce que le carburant coûte plus cher aux heures de pointe","is_correct":false},
      {"id":"c","label":"Parce que le SAEIV ne fonctionne pas avant 7 h","is_correct":false},
      {"id":"d","label":"Parce que les voyageurs du matin ne déposent jamais de réclamation","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ertv','module-3','qcm-v1'], 'ERTV-M3-QCM-02', false,
    $mft$Un départ raté au dépôt décale la première course, fait rater des correspondances et décale chaque course suivante : l'effet cascade peut durer toute la matinée. Les autres réponses n'ont aucun lien avec ce mécanisme.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un autocar tombe en panne en pleine ligne avec des voyageurs à bord. Quelle est la réponse type du régulateur ?$mft$,
    $mft$[
      {"id":"a","label":"Sécuriser les voyageurs, envoyer le véhicule de réserve et organiser le transbordement en sécurité","is_correct":true},
      {"id":"b","label":"Demander aux voyageurs de terminer le trajet par leurs propres moyens","is_correct":false},
      {"id":"c","label":"Attendre la fin du dépannage sans rien communiquer","is_correct":false},
      {"id":"d","label":"Faire remorquer le véhicule avec les voyageurs restés à bord","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ertv','module-3','qcm-v1'], 'ERTV-M3-QCM-03', false,
    $mft$Les personnes passent avant le véhicule : mise en sécurité, réserve, transbordement organisé. Abandonner les voyageurs, se taire ou les laisser à bord pendant un remorquage sont autant de fautes.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Une ligne est bloquée et vous ignorez encore la durée de la perturbation. Quel message diffusez-vous aux voyageurs ?$mft$,
    $mft$[
      {"id":"a","label":"Ce que vous savez, l'heure du prochain point d'information et une solution (itinéraire bis, prochain passage)","is_correct":true},
      {"id":"b","label":"Une durée rassurante inventée pour calmer l'attente","is_correct":false},
      {"id":"c","label":"Rien, pour éviter d'inquiéter inutilement les voyageurs","is_correct":false},
      {"id":"d","label":"Un message technique détaillé destiné en réalité aux conducteurs","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ertv','module-3','qcm-v1'], 'ERTV-M3-QCM-04', false,
    $mft$Règles d'or : dire ce qu'on sait, annoncer quand on saura, donner des solutions. Une promesse inventée détruit la confiance dès qu'elle est démentie, et le silence est pire que l'incertitude annoncée.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Au poste de régulation, l'écran signale la course de 8 h 10 de la ligne 12 à plus neuf minutes. D'où vient cette information ?$mft$,
    $mft$[
      {"id":"a","label":"Du SAEIV, qui géolocalise les véhicules et compare leur position à l'horaire théorique en continu","is_correct":true},
      {"id":"b","label":"D'un appel radio systématique du conducteur toutes les dix minutes","is_correct":false},
      {"id":"c","label":"Des réclamations déposées en temps réel par les voyageurs","is_correct":false},
      {"id":"d","label":"De l'affichage aux arrêts, qui remonte les passages constatés","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-3','qcm-v1'], 'ERTV-M3-QCM-05', false,
    $mft$Le SAEIV (système d'aide à l'exploitation et information voyageurs) donne la vision temps réel : géolocalisation et écart avance/retard course par course. Les appels, réclamations ou affichages sont des canaux, pas la source de mesure.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Six mois après les faits, l'autorité organisatrice conteste la réalisation de plusieurs courses un jour de neige. Sur quoi l'exploitant s'appuie-t-il pour répondre ?$mft$,
    $mft$[
      {"id":"a","label":"Sur la main courante d'exploitation, qui a tracé heure par heure les événements et les décisions du jour","is_correct":true},
      {"id":"b","label":"Sur la mémoire du régulateur qui était de service ce jour-là","is_correct":false},
      {"id":"c","label":"Sur les messages publiés à l'époque sur les réseaux sociaux du réseau","is_correct":false},
      {"id":"d","label":"Sur une attestation rédigée après coup par les conducteurs concernés","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-3','qcm-v1'], 'ERTV-M3-QCM-06', false,
    $mft$La main courante est la base des réponses à l'AO et des litiges : faits horodatés, décisions, résultats. La mémoire s'efface, les réseaux sociaux ne prouvent pas la production, et une attestation tardive n'a pas la force d'une trace du jour même.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$À 5 h 15, un conducteur ne se présente pas à la prise de service et reste injoignable. Parmi ces solutions, laquelle est exclue d'office ?$mft$,
    $mft$[
      {"id":"a","label":"Faire assurer le service par un conducteur dont le cadre social ne le permet plus","is_correct":true},
      {"id":"b","label":"Mobiliser le conducteur de réserve prévu au planning","is_correct":false},
      {"id":"c","label":"Rappeler un volontaire dont la situation permet la prise de service","is_correct":false},
      {"id":"d","label":"Recomposer les services en concentrant les moyens sur les courses prioritaires","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-3','qcm-v1'], 'ERTV-M3-QCM-07', false,
    $mft$Le bricolage illégal est la seule option interdite : il crée un risque juridique et un risque de sécurité pires que la course supprimée. Réserve, rappel licite et recomposition sont les leviers normaux du régulateur.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$À 7 h 45, trois alertes tombent en même temps : un malaise voyageur sur la ligne 2, un car scolaire retardé par des travaux et un bus urbain à plus six minutes. Dans quel ordre traitez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Le malaise d'abord (sécurité), puis le car scolaire, puis le bus à plus six minutes","is_correct":true},
      {"id":"b","label":"Le bus urbain d'abord, car la régularité est un indicateur contractuel","is_correct":false},
      {"id":"c","label":"Le car scolaire d'abord, car les familles vont téléphoner","is_correct":false},
      {"id":"d","label":"Les trois en parallèle, sans hiérarchie particulière","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-3','qcm-v1'], 'ERTV-M3-QCM-08', false,
    $mft$La priorisation du régulateur est invariable : la sécurité d'abord (personne en danger), puis les scolaires et les correspondances, puis la régularité. Traiter « tout en même temps » revient à ne rien prioriser.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Des chutes de neige annoncées entraîneront demain matin la suppression probable de plusieurs circuits scolaires. Qui informez-vous, et comment ?$mft$,
    $mft$[
      {"id":"a","label":"Les établissements scolaires et les familles, selon le protocole d'information défini avec l'AO, dès la veille","is_correct":true},
      {"id":"b","label":"Uniquement les conducteurs concernés, la veille au soir","is_correct":false},
      {"id":"c","label":"Personne avant 6 h du matin, pour éviter des annulations inutiles","is_correct":false},
      {"id":"d","label":"Uniquement la presse locale, qui relaiera l'information","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-3','qcm-v1'], 'ERTV-M3-QCM-09', false,
    $mft$Les scolaires sont un public sensible : l'information des établissements et des familles suit le protocole convenu avec l'AO, et s'anticipe quand l'aléa est prévisible. Informer les seuls conducteurs ou attendre le matin laisse les familles sans réponse.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$La course de 7 h 40 de la ligne 3 arrive en retard presque tous les jours, quel que soit le conducteur. Quelle est la lecture correcte ?$mft$,
    $mft$[
      {"id":"a","label":"Le temps de parcours a été sous-évalué au graphicage : il faut re-graphiquer la course, pas presser les conducteurs","is_correct":true},
      {"id":"b","label":"Les conducteurs de cette ligne manquent de rigueur : un rappel à l'ordre collectif s'impose","is_correct":false},
      {"id":"c","label":"C'est le hasard : un retard récurrent n'a pas forcément de cause","is_correct":false},
      {"id":"d","label":"Il faut demander de rouler plus vite sur ce créneau pour tenir l'horaire","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ertv','module-3','qcm-v1'], 'ERTV-M3-QCM-10', false,
    $mft$Un retard qui se répète à la même heure avec des conducteurs différents désigne le graphique, pas les personnes. Presser ou faire accélérer dégrade la sécurité sans supprimer la cause : le temps alloué est intenable.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Sur un mois, 200 courses étaient prévues au contrat et 194 ont été réalisées. Quel indicateur ce rapport alimente-t-il ?$mft$,
    $mft$[
      {"id":"a","label":"Le taux de service : courses réalisées rapportées aux courses prévues, soit 97 %","is_correct":true},
      {"id":"b","label":"La ponctualité, qui compte les courses réalisées dans le mois","is_correct":false},
      {"id":"c","label":"La régularité, qui mesure les kilomètres produits","is_correct":false},
      {"id":"d","label":"Le taux de réclamations, qui suit la production mensuelle","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ertv','module-3','qcm-v1'], 'ERTV-M3-QCM-11', false,
    $mft$Le taux de service mesure l'offre effectivement produite (réalisé/prévu). La ponctualité mesure les passages dans la fenêtre définie au contrat, la régularité la fréquence tenue : trois indicateurs distincts à ne pas confondre en revue AO.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Deux réseaux subissent la même déviation de trente minutes. Le premier informe en continu avec des solutions, le second reste silencieux. Les enquêtes de satisfaction divergent fortement. Pourquoi ?$mft$,
    $mft$[
      {"id":"a","label":"Parce qu'en situation perturbée l'information fait environ la moitié de la qualité perçue : informés et orientés, les voyageurs jugent la même perturbation bien plus acceptable","is_correct":true},
      {"id":"b","label":"Parce que les voyageurs du second réseau étaient forcément plus nombreux","is_correct":false},
      {"id":"c","label":"Parce que la déviation du premier réseau était nécessairement plus courte","is_correct":false},
      {"id":"d","label":"Parce que les enquêtes de satisfaction ne mesurent en réalité que la ponctualité","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ertv','module-3','qcm-v1'], 'ERTV-M3-QCM-12', false,
    $mft$À perturbation égale, la perception diverge selon l'information reçue : faits, impact, solutions et rendez-vous transforment des voyageurs qui subissent en voyageurs qui comprennent. Les autres réponses inventent des différences que l'énoncé exclut.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Que désigne le sigle SAEIV et quelles sont ses deux fonctions pour l'exploitation ?$mft$,
   $mft$Le système d'aide à l'exploitation et à l'information voyageurs : suivre les véhicules en temps réel (géolocalisation, avance/retard par rapport à l'horaire théorique) et informer les voyageurs.$mft$,
   2, 'facile', ARRAY['ertv','module-3','question-courte'], 'ERTV-M3-QC-01', false,
   $mft$Sigle développé + les deux fonctions.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Une panne immobilise un véhicule en ligne avec des voyageurs à bord : citez les deux actions clés du régulateur envers ces voyageurs.$mft$,
   $mft$Les mettre en sécurité, puis organiser leur transbordement en sécurité vers le véhicule de réserve envoyé sur place.$mft$,
   2, 'facile', ARRAY['ertv','module-3','question-courte'], 'ERTV-M3-QC-02', false,
   $mft$Sécurisation puis transbordement, avec la réserve.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$En situation perturbée, que doit contenir votre message d'information quand la durée de la perturbation est inconnue ?$mft$,
   $mft$Ce que l'on sait (les faits), l'heure à laquelle la prochaine information sera donnée, et une solution pour le voyageur (prochain passage, itinéraire bis).$mft$,
   2, 'facile', ARRAY['ertv','module-3','question-courte'], 'ERTV-M3-QC-03', false,
   $mft$Faits + rendez-vous + solution : jamais de durée inventée.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Pourquoi dit-on qu'un départ raté au dépôt sur la première course du matin ne se rattrape presque jamais ?$mft$,
   $mft$Parce que le retard se propage en cascade : chaque course suivante du même véhicule et du même conducteur part décalée, et les correspondances ratées amplifient l'effet.$mft$,
   2, 'moyen', ARRAY['ertv','module-3','question-courte'], 'ERTV-M3-QC-04', false,
   $mft$L'effet cascade attendu.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Au-delà du jour même, à quoi sert la main courante d'exploitation ? Donnez deux usages.$mft$,
   $mft$Elle sert de base aux réponses à l'autorité organisatrice (justifier les courses et les incidents) et au traitement des litiges : ce qui est tracé avec heure et faits reste opposable des mois plus tard.$mft$,
   2, 'moyen', ARRAY['ertv','module-3','question-courte'], 'ERTV-M3-QC-05', false,
   $mft$Réponses à l'AO + litiges.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Trois aléas vous arrivent en même temps au poste de régulation : rappelez l'ordre de priorité de traitement.$mft$,
   $mft$La sécurité d'abord (personnes en danger), puis les scolaires et les correspondances, puis la régularité de la ligne.$mft$,
   2, 'moyen', ARRAY['ertv','module-3','question-courte'], 'ERTV-M3-QC-06', false,
   $mft$Les trois niveaux dans l'ordre.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Un conducteur manque à la prise de service : citez trois leviers licites de recomposition et la limite à ne jamais franchir.$mft$,
   $mft$Mobiliser le conducteur de réserve, rappeler un volontaire dont la situation le permet, recomposer les services (arbitrer les courses) : jamais de solution qui viole le cadre social du conducteur (pas de bricolage illégal).$mft$,
   2, 'moyen', ARRAY['ertv','module-3','question-courte'], 'ERTV-M3-QC-07', false,
   $mft$Trois leviers + la limite du cadre social.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Sur une semaine, 180 courses étaient prévues et 171 ont été réalisées. Quel indicateur calculez-vous et que vaut-il ?$mft$,
   $mft$Le taux de service : courses réalisées divisées par courses prévues, soit 171 sur 180, donc 95 %.$mft$,
   2, 'moyen', ARRAY['ertv','module-3','question-courte'], 'ERTV-M3-QC-08', false,
   $mft$Indicateur nommé + calcul exact.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Un retard récurrent frappe la même course chaque matin, quel que soit le conducteur. Quelle est la cause racine probable et la correction appropriée ?$mft$,
   $mft$Un temps de parcours sous-évalué au graphicage : la correction consiste à re-graphiquer la course (revoir le temps alloué), pas à presser les conducteurs.$mft$,
   2, 'difficile', ARRAY['ertv','module-3','question-courte'], 'ERTV-M3-QC-09', false,
   $mft$Le graphique, pas les personnes.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Avant de publier un message de perturbation majeure sur l'appli et les réseaux sociaux du réseau, que devez-vous vérifier vis-à-vis de l'AO ?$mft$,
   $mft$La règle de coordination convenue avec l'AO (qui communique quoi, sur quels canaux), afin de diffuser un message cohérent sur tous les supports et d'éviter les informations contradictoires.$mft$,
   2, 'difficile', ARRAY['ertv','module-3','question-courte'], 'ERTV-M3-QC-10', false,
   $mft$La règle « qui communique quoi ».$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ─────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Décrivez la préparation de la veille d'une journée d'exploitation voyageurs et montrez comment elle conditionne les sorties de dépôt du lendemain matin.$mft$,
   $mft$Réponse modèle. La veille, l'exploitant verrouille trois chantiers. Les conducteurs : chaque service reçoit un nom ; les absences connues (congés, maladie déclarée, formation) sont traitées immédiatement par des remplacements organisés, pas laissées au hasard du matin. Les véhicules : le plan de transport est croisé avec la disponibilité réelle du parc, en dialogue avec la maintenance : un véhicule immobilisé à l'atelier sort de la liste et un véhicule apte le remplace. Les aléas déjà connus : travaux annoncés, manifestation, météo prévue sont intégrés (consignes, itinéraires, renforts éventuels). Effet sur le matin : au dépôt, tout est joué d'avance : chaque conducteur sait quel véhicule prendre et quel service assurer, les documents sont prêts, et les sorties partent à l'heure. Ce point est décisif : un départ raté au dépôt se propage en cascade sur toutes les courses suivantes du véhicule et du conducteur, avec correspondances manquées, et ne se rattrape presque jamais. La préparation de la veille est donc la première action de régulation de la journée : elle réduit les aléas du matin à ce qui est réellement imprévisible, que le régulateur traite ensuite avec ses outils (réserve, SAEIV, main courante).$mft$,
   $mft$Barème /5 : trois chantiers de la veille détaillés (conducteurs et remplacements, véhicules et maintenance, aléas connus) (2,5 pts) ; mécanisme du départ raté et de l'effet cascade expliqué (1,5 pt) ; lien explicite entre préparation de la veille et sorties de dépôt à l'heure (1 pt). Erreurs fréquentes : réduire la préparation au seul planning des conducteurs ; oublier le dialogue quotidien avec la maintenance.$mft$,
   5, 'facile', ARRAY['ertv','module-3','question-redigee'], 'ERTV-M3-QR-01', false,
   $mft$La préparation de la veille comme première action de régulation.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un exploitant affirme : « en situation perturbée, l'information fait la moitié de la qualité perçue ». Expliquez cette idée, énoncez les règles d'or de l'information voyageurs et illustrez-les sur une déviation pour travaux.$mft$,
   $mft$Réponse modèle. À perturbation égale, la perception diverge : le voyageur informé comprend et s'organise, le voyageur laissé dans le silence subit et retient une rancune durable ; l'aléa se pardonne, le silence non. D'où les règles d'or. Un : dire ce qu'on SAIT, des faits précis (« travaux avenue de la Gare, arrêts Mairie et Collège non desservis ») et non des formules vagues. Deux : quand on ne sait pas, dire quand on saura (« prochain point à 8 h 30 ») : le rendez-vous d'information est une information en soi. Trois : donner des solutions : prochain passage, itinéraire bis, correspondance possible. Sur la déviation pour travaux : girouettes signalant la déviation, annonces à bord pour les voyageurs transportés, affichage aux arrêts (arrêts non desservis, arrêts de report), appli et SMS de l'AO pour les abonnés, réseaux sociaux du réseau pour le suivi. Le message suit la structure faits, impact, solution, rendez-vous, et il est identique sur tous les canaux, en cohérence avec la règle « qui communique quoi » convenue avec l'AO. Les deux pièges à éviter : la durée inventée « pour calmer », démentie ensuite, et le silence en espérant que ça passe.$mft$,
   $mft$Barème /5 : explication de la qualité perçue (subir ou comprendre la même perturbation) (1,5 pt) ; les trois règles d'or exactes (1,5 pt) ; illustration concrète de la déviation avec des canaux adaptés (1,5 pt) ; coordination avec l'AO mentionnée (0,5 pt). Erreurs fréquentes : promettre des durées inventées ; se limiter à un seul canal de diffusion.$mft$,
   5, 'facile', ARRAY['ertv','module-3','question-redigee'], 'ERTV-M3-QR-02', false,
   $mft$Les règles d'or de l'information appliquées à une déviation.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$À 17 h 15, un autocar tombe en panne en ligne avec une quarantaine de voyageurs à bord, dont des scolaires attendus en correspondance. Déroulez votre régulation de bout en bout, de l'alerte à la clôture de l'incident.$mft$,
   $mft$Réponse modèle. Qualifier d'abord : position exacte du véhicule, nature de la panne, situation des voyageurs, risque immédiat. Sécuriser ensuite : consignes au conducteur (véhicule à l'écart si possible, voyageurs maintenus à bord ou regroupés en zone sûre selon la configuration) : rien ne se décide avant que les personnes soient en sécurité. Décider : envoi du véhicule de réserve, transbordement organisé en sécurité à l'endroit adapté. La correspondance des scolaires est prioritaire après la sécurité : prévenir le point de correspondance pour faire attendre si possible, sinon organiser la suite de leur trajet. Informer en parallèle : les voyageurs à bord (ce qu'on sait, délai estimé de la réserve, prochain point), l'AO selon la règle de communication convenue, et les établissements ou familles si le protocole scolaire le prévoit. Tracer tout dans la main courante : heure de l'alerte, décisions, heure du transbordement, reprise du service. Clôturer : véhicule remorqué vers la maintenance, retour de la réserve, débrief court (la réponse type a-t-elle fonctionné, que faut-il ajuster). La chaîne complète tient en cinq verbes : qualifier, sécuriser, décider, informer, tracer.$mft$,
   $mft$Barème /5 : sécurisation immédiate des voyageurs avant toute autre décision (1 pt) ; véhicule de réserve et transbordement en sécurité (1,5 pt) ; priorité à la correspondance des scolaires traitée concrètement (1 pt) ; information voyageurs, AO et protocole scolaire (0,75 pt) ; traçage en main courante et clôture avec débrief (0,75 pt). Erreurs fréquentes : lancer le transbordement avant la mise en sécurité ; oublier la correspondance des scolaires.$mft$,
   5, 'moyen', ARRAY['ertv','module-3','question-redigee'], 'ERTV-M3-QR-03', false,
   $mft$Une panne en ligne déroulée en cinq verbes.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Comparez le traitement d'un retard simple et celui d'un bouchon imposant une déviation : outils mobilisés, information diffusée, et ce qui doit avoir été préparé à l'avance.$mft$,
   $mft$Réponse modèle. Le retard simple est l'aléa ordinaire : il s'absorbe au battement du terminus, ce temps tampon prévu au graphicage entre deux courses. Tant que le battement encaisse, la course suivante part à l'heure ; le régulateur surveille l'écart au SAEIV et l'information reste légère : temps d'attente actualisé aux arrêts et à bord. Le bouchon avec déviation change d'échelle : on ne peut plus tenir l'itinéraire, il faut basculer sur un itinéraire de repli préparé à l'avance, au bureau, à froid : gabarit des rues vérifié, arrêts de substitution repérés, consignes écrites. Le jour J, le régulateur déclenche le scénario, diffuse les consignes aux conducteurs et lance une information beaucoup plus riche : arrêts non desservis, arrêts de report, itinéraire bis, sur tous les canaux et en coordination avec l'AO. Points communs aux deux situations : la détection précoce par le SAEIV, la décision rapide (une solution correcte maintenant vaut mieux qu'une solution parfaite trop tard) et le traçage en main courante. La différence essentielle tient à la préparation : le battement se dimensionne au graphicage, l'itinéraire de repli s'étudie avant la crise ; dans les deux cas, le travail décisif a eu lieu avant l'aléa.$mft$,
   $mft$Barème /5 : retard simple traité par le battement avec information légère (1,5 pt) ; déviation traitée par un itinéraire de repli préparé à froid, consignes et arrêts non desservis (2 pts) ; points communs identifiés (SAEIV, décision rapide, main courante) (1 pt) ; rôle de la préparation en amont souligné (0,5 pt). Erreurs fréquentes : improviser la déviation en direct ; oublier d'informer sur les arrêts non desservis.$mft$,
   5, 'moyen', ARRAY['ertv','module-3','question-redigee'], 'ERTV-M3-QR-04', false,
   $mft$Deux aléas comparés : battement contre itinéraire de repli.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$À 5 h 50, le conducteur du premier service scolaire ne s'est pas présenté et reste injoignable. Construisez votre plan d'action minute par minute, en précisant la limite que vous ne franchirez jamais.$mft$,
   $mft$Réponse modèle. Vérifier d'abord : appel du conducteur, contrôle de la prise de service, confirmation de l'absence : quelques minutes suffisent et évitent de déclencher pour rien. Mobiliser ensuite le conducteur de réserve s'il est prévu au planning : c'est le levier fait pour cela. À défaut, rappeler un volontaire dont la situation permet la prise de service : le rappel se fait dans les règles, pas à l'arraché. Si aucun conducteur n'est disponible, recomposer les services : arbitrer les courses, concentrer les moyens sur les priorités, et le scolaire passe en tête (correspondances, familles qui attendent) ; on décale ou on coupe une course de moindre enjeu plutôt que de laisser des élèves au bord de la route. Informer pendant qu'on recompose : les établissements et les familles selon le protocole si un retard est inévitable, l'AO selon la règle convenue. Tracer tout en main courante : heures d'appel, décisions, solution retenue, heure de départ effective. La limite absolue : jamais de bricolage illégal : on ne fait pas rouler un conducteur dont le cadre social ne le permet plus ; le dépannage ne vaut ni le risque juridique ni le risque de sécurité, et une course supprimée proprement se justifie devant l'AO, une infraction jamais.$mft$,
   $mft$Barème /5 : escalade correcte et ordonnée (vérifier, réserve, rappel licite, recomposition) (2 pts) ; priorité au service scolaire et information des établissements et familles selon le protocole (1 pt) ; traçage en main courante avec les heures (0,75 pt) ; limite du cadre social explicitement posée et justifiée (1,25 pt). Erreurs fréquentes : « dépanner » en violant les repos du conducteur rappelé ; recomposer sans informer personne.$mft$,
   5, 'moyen', ARRAY['ertv','module-3','question-redigee'], 'ERTV-M3-QR-05', false,
   $mft$Le conducteur manquant : escalade licite et limite absolue.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Revue mensuelle dans un mois : la ponctualité de la ligne 5 recule depuis trois mois, le taux de service du réseau est de 96 % (192 courses réalisées sur 200) et les réclamations se concentrent sur la course de 7 h 40. Préparez votre analyse et votre plan d'action pour la réunion avec l'AO.$mft$,
   $mft$Réponse modèle. Fiabiliser la mesure d'abord : les chiffres présentés viennent du SAEIV, sans retraitement arrangeant : un indicateur maquillé se retourne contre l'exploitant et le prive de son propre pilotage. Analyser ensuite les causes racines. Ligne 5 : croiser les retards par course et par heure ; si les réclamations et les retards se concentrent sur la course de 7 h 40 quel que soit le conducteur, la cause est un temps de parcours sous-évalué au graphicage : proposer un re-graphicage de la course, pas une pression sur les conducteurs. Taux de service à 96 % : identifier une par une les 8 courses non réalisées (pannes, conducteurs manquants, autres causes) et traiter la cause dominante : renfort de la réserve, action maintenance, selon le diagnostic. Construire un plan d'action daté, avec un responsable par action et une échéance, puis vérifier le mois suivant si l'indicateur bouge. En réunion : transparence outillée : chiffres honnêtes, causes identifiées, actions engagées, résultats du mois précédent. Une AO qui voit les problèmes traités avant qu'elle les soulève devient un partenaire, et les pénalités évitées financent précisément les améliorations proposées.$mft$,
   $mft$Barème /5 : mesure honnête issue du SAEIV et assumée (0,75 pt) ; cause racine du 7 h 40 identifiée avec proposition de re-graphicage (1,5 pt) ; analyse course par course des 8 courses non réalisées avec pistes (réserve, maintenance) (1,25 pt) ; plan d'action daté et responsabilisé, vérifié le mois suivant (1 pt) ; posture de transparence en revue avec l'AO (0,5 pt). Erreurs fréquentes : désigner les conducteurs comme cause unique ; présenter des chiffres sans plan d'action.$mft$,
   5, 'moyen', ARRAY['ertv','module-3','question-redigee'], 'ERTV-M3-QR-06', false,
   $mft$Préparer une revue mensuelle : causes racines et plan d'action.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un épisode neigeux est annoncé pour demain matin, avec suppression probable de plusieurs circuits scolaires et déviations sur deux lignes régulières. Construisez le plan d'information voyageurs complet : publics, canaux, contenu des messages, calendrier et coordination avec l'AO.$mft$,
   $mft$Réponse modèle. Publics d'abord : les scolaires sont prioritaires : information des établissements et des familles selon le protocole défini avec l'AO, dès la veille puisque l'aléa est prévisible ; puis les voyageurs des lignes régulières concernées par les déviations ; enfin les conducteurs, destinataires des consignes opérationnelles. Canaux ensuite : la veille, appli et SMS de l'AO, réseaux sociaux du réseau, affichage aux arrêts quand c'est possible ; le jour J, annonces à bord et girouettes signalant les déviations, actualisation continue des canaux numériques. Contenu : chaque message suit la structure faits (épisode neigeux annoncé), impact (circuits supprimés nommément, arrêts non desservis), solution (itinéraires bis, arrêts de report, alternatives) et rendez-vous (heure du prochain point, par exemple un point à 6 h puis à intervalles réguliers). Règle d'or maintenue le jour J : dire ce qu'on sait, jamais de promesse de reprise inventée. Coordination avec l'AO : appliquer la règle « qui communique quoi » convenue à l'avance, avec un point de contact unique de chaque côté pour garantir des messages cohérents sur tous les supports. Tracer enfin les diffusions en main courante : quels messages, à quelle heure, sur quels canaux : cette trace servira aux réponses à l'AO après l'épisode.$mft$,
   $mft$Barème /5 : scolaires traités en priorité via le protocole établissements et familles, dès la veille (1,5 pt) ; canaux multiples et adaptés à chaque public et à chaque moment (1 pt) ; messages structurés faits, impact, solution, rendez-vous (1,25 pt) ; coordination avec l'AO sur qui communique quoi (0,75 pt) ; traçage des diffusions en main courante (0,5 pt). Erreurs fréquentes : attendre le jour J pour informer les familles ; diffuser des messages sans rendez-vous d'actualisation.$mft$,
   5, 'difficile', ARRAY['ertv','module-3','question-redigee'], 'ERTV-M3-QR-07', false,
   $mft$Plan d'information neige : publics, canaux, messages, coordination AO.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$« Les pénalités évitées financent les améliorations. » Développez cette logique de pilotage : de la mesure honnête à la revue mensuelle avec l'AO, montrez comment un exploitant transforme ses indicateurs contractuels en cercle vertueux plutôt qu'en contentieux.$mft$,
   $mft$Réponse modèle. Le point de départ est la mesure honnête : les indicateurs (ponctualité dans la fenêtre définie au contrat, régularité, taux de service, propreté, réclamations) sortent du SAEIV sans retraitement arrangeant. Un chiffre maquillé est doublement perdant : il se retourne contre l'exploitant quand l'écart éclate, et il le prive de son propre outil de pilotage : on ne corrige pas un problème qu'on s'est caché. Vient ensuite l'analyse des causes racines : un retard récurrent à heure fixe, tous conducteurs confondus, désigne un temps de parcours sous-évalué : on re-graphique la course au lieu de presser les conducteurs ; des courses non réalisées se comptent une par une pour traiter la cause dominante. Puis le plan d'action : daté, responsabilisé, vérifié le mois suivant sur l'indicateur. La revue mensuelle devient alors un outil : transparence, actions engagées, résultats montrés ; l'AO qui voit les problèmes traités avant de les soulever fait confiance. La boucle économique se referme : chaque point d'indicateur regagné évite des pénalités contractuelles, et ces sommes financent la fiabilisation (re-graphicage, réserve, maintenance), qui améliore encore les indicateurs : la qualité paie la qualité. Le chemin inverse existe : dissimulation, pénalités, méfiance, audits, contentieux : un cercle vicieux où chacun perd.$mft$,
   $mft$Barème /5 : chaîne complète mesurer, analyser, agir, vérifier, rendre compte (1,5 pt) ; exigence de mesure honnête argumentée (double perte du chiffre maquillé) (1 pt) ; mécanisme économique du réinvestissement des pénalités évitées (1,5 pt) ; contraste avec le cercle vicieux de la dissimulation (1 pt). Erreurs fréquentes : voir la revue avec l'AO comme un tribunal ; traiter les indicateurs comme une contrainte administrative sans lien avec l'exploitation.$mft$,
   5, 'difficile', ARRAY['ertv','module-3','question-redigee'], 'ERTV-M3-QR-08', false,
   $mft$Le cercle vertueux du pilotage par les indicateurs.$mft$);

  RAISE NOTICE 'Module 3 ERTV créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $ertvm3$;
