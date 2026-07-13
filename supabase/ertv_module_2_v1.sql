-- =====================================================================
-- ERTV : EXPLOITANT EN TRANSPORT ROUTIER DE VOYAGEURS
-- MODULE 2 : CONCEVOIR L'OFFRE : GRAPHICAGE ET HABILLAGE
-- v1 (juillet 2026)
-- Du besoin de mobilité au service qui roule : construction des courses
-- (graphicage), affectation des conducteurs (habillage), coûts et
-- optimisation des moyens.
-- ⚠ STATUT : active = false (« à valider »). Idempotent.
-- =====================================================================

DO $ertvm2$
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

  DELETE FROM public.question_bank WHERE source_ref LIKE 'ERTV-M2-%';
  DELETE FROM public.modules WHERE slug = 'ertv-graphicage-habillage';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 2 : Concevoir l''offre : graphicage et habillage',
    'ertv-graphicage-habillage', v_bloc,
    'Du besoin de mobilité au service qui roule : construction des courses (graphicage), affectation des conducteurs (habillage), coûts et optimisation des moyens.',
    'avance', 360, 20) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 20, true);

  -- ─── Leçon 1 : Du besoin au réseau ─────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'du-besoin-au-reseau',
    'Comprendre le besoin avant de tracer la ligne',
    $mft$> 🎯 **Objectifs**
> - Analyser une demande de mobilité : flux, heures de pointe, saisonnalité.
> - Dimensionner une offre : fréquence, amplitude, capacité des véhicules.
> - Employer le vocabulaire de l'exploitant : ligne, course, service, terminus, battement, girouette.

## Une ligne ne se dessine pas sur un coin de table

Le point de départ n'est jamais l'itinéraire : c'est le besoin de mobilité. Qui se déplace, d'où, vers où, à quelle heure, à quelle période de l'année ? Les flux domicile-travail et domicile-école structurent la journée : une pointe du matin concentrée, une pointe du soir plus étalée, et des creux en milieu de journée où la demande s'effondre. La saisonnalité scolaire est le deuxième marqueur du transport de voyageurs : pendant les vacances, une ligne calée sur les collèges et lycées peut perdre l'essentiel de sa fréquentation. Concevoir l'offre, c'est d'abord photographier ces rythmes.

Les sources de l'exploitant : comptages à bord, données de billettique, enquêtes origine-destination, horaires des établissements scolaires et des grands employeurs desservis, et l'observation directe sur le terrain (files d'attente aux arrêts, véhicules saturés ou vides).

## Trois curseurs pour dimensionner

| Curseur | Question posée | Effet principal |
| --- | --- | --- |
| Fréquence | Combien de temps entre deux départs ? | Attractivité et coût (plus de départs = plus de moyens) |
| Amplitude | Premier et dernier départ de la journée ? | Couverture des besoins (postés, étudiants, soirées) |
| Capacité | Quel véhicule pour quelle charge ? | Confort en pointe, coût en creux |

Côté capacité, l'exploitant joue sur la gamme : le minibus pour les zones peu denses ou les creux, le véhicule standard pour l'essentiel du service, le véhicule articulé pour absorber les pointes fortes sans multiplier les départs. Règle d'or : on dimensionne la capacité sur la charge en pointe, pas sur la moyenne de la journée. Un véhicule saturé à 7 h 45 et vide à 14 h est normal ; un véhicule saturé toute la journée est un sous-dimensionnement.

## Les arbitrages coût/service

Toute amélioration du service a un prix, et l'exploitant arbitre en permanence. Le cadencement (un départ à intervalle régulier, aux mêmes minutes toute la journée) rend l'horaire mémorisable et l'offre attractive ; mais il peut imposer des courses peu remplies en creux et des kilomètres à vide pour repositionner les véhicules. À l'inverse, une offre taillée au plus juste sur la demande observée coûte moins cher, mais son horaire illisible décourage les voyageurs occasionnels.

> 💡 **Astuce**
> Présentez toujours les scénarios à l'autorité organisatrice avec les deux faces : niveau de service (fréquence, amplitude) ET moyens engagés (véhicules, heures de conduite, kilomètres). Un élu arbitre mieux quand il voit ce que coûte chaque minute de fréquence gagnée.

## Points d'arrêt et temps de parcours : le réel, pas la carte

Un temps de parcours estimé sur une carte un mardi à 14 h ne vaut rien à 7 h 45. Les temps de parcours se relèvent sur le terrain, aux heures de pointe, dans les deux sens, en incluant les temps d'arrêt en station (montées, validations, descentes). Un graphique construit sur des temps optimistes produit des retards en chaîne dès la première semaine. Les points d'arrêt s'étudient aussi sur place : visibilité, cheminements piétons, traversées sécurisées, accessibilité aux personnes à mobilité réduite, possibilité pour le véhicule de s'arrêter sans bloquer la circulation.

## Le vocabulaire de l'exploitant

| Terme | Définition |
| --- | --- |
| Ligne | Liaison commerciale entre deux terminus, avec itinéraire et arrêts définis |
| Course | Trajet d'un véhicule d'un terminus à l'autre, à un horaire donné |
| Service | Ensemble ordonné de courses confié à un véhicule (voiture) ou à un conducteur |
| Terminus | Extrémité de la ligne, où le véhicule fait demi-tour et prend son battement |
| Battement | Temps prévu au terminus entre l'arrivée d'une course et le départ de la suivante |
| Girouette | Afficheur de destination du véhicule, premier repère du voyageur |

> 📌 **À retenir**
> La course est l'unité de base de toute l'exploitation : c'est elle que l'on dessine au graphicage, que l'on enchaîne en voitures, puis que l'on distribue aux conducteurs à l'habillage.

## ✅ Synthèse

- Analyser d'abord : flux domicile-travail et domicile-école, pointes et creux, saisonnalité scolaire.
- Dimensionner avec trois curseurs : fréquence, amplitude, capacité (minibus, standard, articulé), calés sur la pointe.
- Arbitrer coût/service en toute transparence : le cadencement attire mais se paie.
- Relever les temps de parcours sur le terrain, aux heures de pointe : jamais sur la carte.$mft$,
    $mft$L'analyse de la demande de mobilité (flux, pointes, saisonnalité scolaire), les trois curseurs du dimensionnement (fréquence, amplitude, capacité), les arbitrages coût/service et le vocabulaire de base de l'exploitant.$mft$,
    1, 45) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : Le graphicage ───────────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'le-graphicage',
    'Le graphicage : dessiner les courses, former les voitures',
    $mft$> 🎯 **Objectifs**
> - Lire et construire un graphique de circulation (axe temps/distance).
> - Enchaîner les courses en voitures en limitant les haut-le-pied.
> - Calculer le nombre de véhicules nécessaires sur une ligne cadencée.

## Le graphique de circulation : la ligne mise en musique

Le graphicage consiste à représenter toutes les courses de la journée sur un graphique espace-temps : l'axe horizontal porte le temps, l'axe vertical la distance (les arrêts de la ligne, du terminus G au terminus Z). Chaque course devient un trait oblique : il monte quand le véhicule va vers Z, il descend quand il revient vers G. La pente traduit la vitesse ; les paliers horizontaux aux extrémités représentent les battements aux terminus. D'un coup d'œil, l'exploitant visualise les croisements, les intervalles entre départs et les trous de l'offre.

## Des courses aux voitures

Une fois les courses tracées, on les enchaîne : une arrivée au terminus Z, un battement, puis la course retour vers G, et ainsi de suite jusqu'à la fin de service. Chaque chaîne de courses confiée à un même véhicule forme un service véhicule, que le métier appelle une voiture. Deux règles guident l'enchaînement :

- **Minimiser les haut-le-pied** : les trajets à vide (sortie du dépôt vers le terminus, rentrée du soir, repositionnements entre terminus) coûtent de l'énergie et des heures sans produire aucune recette. Un bon graphique enchaîne les courses de façon que chaque arrivée serve le départ suivant.
- **Préserver les battements de régulation** : le battement au terminus n'est pas du temps perdu, c'est l'amortisseur du système. Il absorbe les aléas (circulation, montées nombreuses, incident léger) pour que chaque course reparte à l'heure, quel que soit le retard de la précédente.

:::timeline
1. Tracer chaque course sur le graphique espace-temps, avec les temps de parcours relevés en pointe
2. Positionner les battements aux terminus (régulation) et repérer les creux de la journée
3. Enchaîner les courses en voitures, en cherchant le nombre minimal de véhicules
4. Ajouter les haut-le-pied indispensables : sorties et rentrées de dépôt
5. Placer les coupures en creux, vérifier la faisabilité (temps réels, terminus) et lisser
:::

> ⚠️ **Attention**
> Un battement trop court se paie cash : le premier retard se propage de course en course toute la journée, les intervalles se creusent, les voyageurs s'accumulent aux arrêts et chaque montée aggrave le retard. Rogner les battements pour économiser une voiture sur le papier revient souvent à dégrader tout le service sur le terrain.

## Exemple guidé : combien de voitures sur la ligne A ?

La ligne A relie la gare (terminus G) à la zone d'activités (terminus Z).

- Temps de parcours : 40 minutes dans chaque sens (relevé en pointe).
- Battement : 10 minutes à chaque terminus.
- Fréquence visée : un départ toutes les 30 minutes dans chaque sens.
- Amplitude : premiers départs à 6 h 00, derniers départs à 19 h 30.

**Étape 1 : le temps de cycle.** C'est le temps pour qu'un véhicule revienne à son point de départ : 40 + 10 + 40 + 10 = 100 minutes.

**Étape 2 : le nombre de voitures.** Nombre de voitures = temps de cycle divisé par la fréquence : 100 / 30 = 3,33, arrondi au supérieur : il faut 4 voitures.

**Étape 3 : redistribuer l'arrondi.** Quatre voitures espacées de 30 minutes offrent un cycle de 4 x 30 = 120 minutes. L'écart avec les 100 minutes nécessaires (20 minutes) se redistribue en battement, par exemple 20 minutes à chaque terminus au lieu de 10 : la régulation y gagne, sans véhicule supplémentaire.

**Étape 4 : compter les courses.** De 6 h 00 à 19 h 30, un départ toutes les 30 minutes donne 28 départs par sens, soit 56 courses commerciales à couvrir, plus les haut-le-pied de sortie et de rentrée de dépôt.

## Les coupures

En milieu de journée, quand la demande s'effondre, maintenir toutes les voitures en ligne serait du gaspillage : le graphique peut prévoir des coupures : certaines voitures rentrent au dépôt ou stationnent au terminus, puis reprennent pour la pointe du soir. La coupure côté véhicule prépare le travail de l'habillage côté conducteur (leçon suivante).

## ✅ Synthèse

- Le graphique espace-temps représente chaque course en trait oblique : l'outil de base de l'exploitant.
- Enchaîner les courses en voitures : minimum de haut-le-pied, battements de régulation préservés.
- Nombre de voitures = temps de cycle (aller + retour + battements) divisé par la fréquence, arrondi au supérieur.
- L'arrondi supérieur se recycle en battement supplémentaire : la régulation en profite.$mft$,
    $mft$Le graphique espace-temps, l'enchaînement des courses en voitures (haut-le-pied minimisés, battements de régulation), le calcul du nombre de véhicules (temps de cycle divisé par la fréquence) et les coupures en creux.$mft$,
    2, 55) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : L'habillage ─────────────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'l-habillage',
    'L''habillage : des voitures aux services conducteurs',
    $mft$> 🎯 **Objectifs**
> - Transformer les services véhicules en services conducteurs conformes au cadre social.
> - Construire des habillages équilibrés et des billets de service clairs.
> - Mesurer ce qu'un bon habillage économise : heures payées et fatigue.

## De la voiture au conducteur

Le graphicage produit des voitures : des journées de véhicules. L'habillage les découpe et les recompose en services conducteurs : des journées de travail humaines. La différence est fondamentale : une voiture peut rouler de 6 h à 20 h ; aucun conducteur ne le peut. Il faut donc découper la voiture en vacations, les combiner entre lignes, insérer coupures et relèves (changement de conducteur en cours de voiture), et vérifier chaque journée contre le cadre social.

## Le cadre social : les logiques à connaître

La journée du conducteur de voyageurs est encadrée par plusieurs familles de règles : le temps de conduite, le temps de service (qui inclut la conduite, mais aussi la préparation du véhicule, les attentes imposées et les opérations en terminus), les coupures et pauses, et l'amplitude de la journée de travail. L'amplitude se mesure de la prise de service à la fin de service, coupures comprises : un service en deux vacations (6 h 30 à 9 h 30 puis 16 h 00 à 19 h 30) ne compte que 6 h 30 de travail, mais l'amplitude court sur 13 heures.

> ⚠️ **Prudence réglementaire**
> Les valeurs chiffrées exactes (amplitude maximale selon le type de service, durée et fractionnement des coupures, seuils propres aux services réguliers et occasionnels) relèvent de la convention collective nationale des transports routiers et des décrets applicables au transport de voyageurs, et varient selon les cas : elles sont à vérifier systématiquement dans les textes en vigueur avant de publier un habillage. Retenez ici les logiques ; les seuils exacts se contrôlent dans la CCN.

## Les grandes formes de services conducteurs

| Type de service | Principe | Usage typique |
| --- | --- | --- |
| Continu | Une seule vacation d'un bloc | Lignes régulières en journée |
| En deux fois | Deux vacations séparées par une coupure longue | Scolaire matin et soir, renforts de pointe |
| Mixte | Combinaison de lignes, scolaire et occasionnel | Optimisation du creux méridien |

Le service en deux fois colle parfaitement aux pointes, mais il étire l'amplitude et pèse sur la vie personnelle : il doit rester équilibré par la répartition dans l'équipe.

## L'équité, condition de la paix sociale

Un habillage techniquement parfait mais injuste explose en quelques semaines. Les points de vigilance : répartir matinées et soirées (personne ne veut uniquement des prises de service à 5 h 45), tourner les week-ends et jours fériés selon un roulement lisible, équilibrer les services coupés et les services continus, et publier les plannings assez tôt pour que chacun s'organise. La concertation avec les représentants du personnel n'est pas une contrainte : c'est un capteur de terrain.

## Le billet de service

Le billet de service est la feuille de route du conducteur : prise de service (heure, lieu, véhicule), liste ordonnée des courses avec horaires, coupures (début, fin, lieu), relèves éventuelles, fin de service. Un billet ambigu produit des courses non assurées : l'exploitant écrit pour être compris à 5 h du matin, par un conducteur qui découvre le service.

## Ce qu'un bon habillage rapporte

Chaque heure payée non roulée (attente entre deux courses, haut-le-pied évitable, temps mort mal placé) est un coût sec : le conducteur est le premier poste de dépense de l'exploitation. Mais l'optimisation a deux faces : un habillage qui compresse tout épuise les équipes ; la fatigue produit de l'absentéisme, des accidents et du turn-over qui coûtent plus cher que les heures économisées. Le bon habillage optimise les deux : les heures payées ET la charge humaine.

> 🎓 **Pour l'examen**
> Sachez dérouler la chaîne complète : graphicage (les courses en voitures), puis habillage (les voitures en services conducteurs), puis billets de service. Et sachez justifier un habillage sur les deux axes : conformité sociale et équilibre économique.

## ✅ Synthèse

- L'habillage transforme les voitures en services conducteurs : découpage, combinaisons, relèves, coupures.
- Amplitude = de la prise de service à la fin de service, coupures comprises ; les seuils exacts se vérifient dans la CCN et les décrets.
- Équité : matinées/soirées, week-ends, services coupés répartis ; plannings publiés tôt.
- Un bon habillage économise les heures payées non roulées ET la fatigue : les deux comptent.$mft$,
    $mft$L'habillage (des voitures aux services conducteurs), les logiques du cadre social (amplitude coupures comprises, seuils à vérifier dans la CCN), les formes de services, l'équité entre conducteurs et le billet de service.$mft$,
    3, 50) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : Coûts et optimisation ───────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'couts-et-optimisation',
    'Coûts et optimisation : faire rouler juste',
    $mft$> 🎯 **Objectifs**
> - Décomposer la structure de coûts d'un service de voyageurs.
> - Raisonner en coût kilométrique ET en coût horaire selon le type de service.
> - Optimiser les moyens : haut-le-pied, mutualisation, taux d'utilisation du parc.

## La structure de coûts : le conducteur d'abord

Contrairement à une idée reçue, le premier poste de coût d'un service de voyageurs n'est ni l'énergie ni le véhicule : c'est le conducteur. Ses heures de service se paient intégralement, qu'il conduise, qu'il attende au terminus ou qu'il effectue un haut-le-pied. Viennent ensuite le véhicule (amortissement du capital, énergie : gazole, GNV ou électricité, entretien, pneumatiques, assurance) puis les coûts de structure : dépôt, encadrement, exploitation, fonctions support.

| Famille | Contenu | Ce qui la fait varier |
| --- | --- | --- |
| Conducteur | Salaires et charges, heures de service (dont attentes) | La qualité de l'habillage |
| Véhicule | Amortissement, énergie, entretien, assurance | Kilomètres parcourus, âge et motorisation du parc |
| Structure | Dépôt, encadrement, exploitation, support | La taille et l'organisation de l'entreprise |

## Coût kilométrique ET coût horaire

Le coût kilométrique (tout ce que coûte un kilomètre parcouru) parle bien pour les services interurbains et occasionnels, où le véhicule roule vite et longtemps. Pour un service urbain lent, il ment : à faible vitesse commerciale, le poste dominant (le conducteur) dépend du temps passé et non de la distance. L'exploitant manie donc les deux unités : le coût horaire pour les services où le temps domine, le coût kilométrique pour ceux où la distance domine, et il sait convertir l'un dans l'autre via la vitesse commerciale du service.

## Trois gisements d'optimisation

- **Réduire les haut-le-pied.** Un dépôt bien placé par rapport aux terminus, des enchaînements de courses qui évitent les repositionnements et des prises de service en ligne quand c'est possible : chaque kilomètre à vide supprimé économise l'énergie ET les heures payées correspondantes. Hypothèse d'école pour fixer les idées : un dépôt éloigné de 12 km du terminus impose, pour une voiture qui sort le matin et rentre le soir, 24 km à vide par jour ; sur 300 jours d'exploitation, 7 200 km à vide par an et par voiture, à multiplier par le coût kilométrique complet et par le nombre de voitures.
- **Mutualiser : un car, plusieurs vies.** Le même véhicule peut assurer les circuits scolaires du matin, une ligne régulière ou une navette en journée, une sortie périscolaire en creux méridien et un service occasionnel le soir ou le week-end. La mutualisation répartit les coûts fixes (amortissement, assurance) sur davantage de recettes.
- **Augmenter le taux d'utilisation du parc.** Un véhicule qui dort au dépôt coûte son amortissement sans rien produire. L'indicateur se suit par véhicule et par période : heures ou kilomètres productifs rapportés au potentiel.

> 🔍 **Zoom**
> Les trois gisements se commandent l'un l'autre : c'est le graphicage qui réduit les haut-le-pied, l'habillage qui limite les heures payées non roulées, et la mutualisation qui remplit les creux. L'optimisation est une chaîne, pas une addition de recettes isolées.

## Répondre à un appel d'offres : chiffrer sérieusement

Une part majeure de l'activité voyageurs se gagne sur appel d'offres (autorités organisatrices, Régions, communautés de communes). Le chiffrage sérieux part de l'exploitation : esquisser graphicage et habillage AVANT de poser les prix, intégrer les coûts complets (kilomètres commerciaux ET haut-le-pied, heures de service dont attentes, structure locale), provisionner les aléas et les pénalités contractuelles (ponctualité, courses non assurées, propreté), et prévoir les mécanismes de révision sur la durée du contrat.

> ❌ **Piège à éviter**
> Le chiffrage optimiste qui « achète » le marché : temps de parcours de carte, zéro haut-le-pied, zéro pénalité, marge symbolique. Les pénalités et les coûts réels mangent les marges optimistes pendant toute la durée du contrat, sans renégociation garantie.

## ✅ Synthèse

- Structure de coûts : conducteur d'abord (heures de service, dont attentes), puis véhicule (amortissement, énergie, entretien, assurance), puis structure.
- Deux unités de mesure : coût horaire quand le temps domine (urbain lent), coût kilométrique quand la distance domine (interurbain, occasionnel).
- Optimiser : haut-le-pied réduits, mutualisation (un car, plusieurs vies), taux d'utilisation du parc suivi.
- Appel d'offres : chiffrer en exploitant (coûts complets, pénalités, révision), jamais en optimiste.$mft$,
    $mft$La structure de coûts voyageurs (conducteur premier poste), le double raisonnement coût horaire/coût kilométrique, les trois gisements d'optimisation (haut-le-pied, mutualisation, taux d'utilisation) et le chiffrage sérieux d'un appel d'offres.$mft$,
    4, 50) RETURNING id INTO v_l4;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : Graphicage et habillage',
    'Vérifiez le module 2 : analyse de la demande, graphicage des courses, habillage des conducteurs, coûts et optimisation.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Une communauté de communes vous demande de créer une ligne vers son nouveau lycée. Par quoi commencez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Par l'analyse de la demande : flux domicile-école, horaires de l'établissement, pointes et saisonnalité","is_correct":true},
      {"id":"b","label":"Par l'achat des véhicules, pour être prêt le jour J","is_correct":false},
      {"id":"c","label":"Par le choix du texte de la girouette","is_correct":false},
      {"id":"d","label":"Par le recrutement immédiat des conducteurs","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ertv','module-2','qcm-v1'], 'ERTV-M2-QCM-01', false,
    $mft$L'offre découle du besoin : sans analyse des flux et des horaires, véhicules et recrutements risquent d'être surdimensionnés ou inadaptés. Girouette et moyens viennent en bout de chaîne.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Sur la ligne A, un véhicule quitte le terminus G à 7 h 30 et arrive au terminus Z à 8 h 10, selon l'horaire publié. Comment s'appelle ce trajet dans le vocabulaire de l'exploitant ?$mft$,
    $mft$[
      {"id":"a","label":"Une course","is_correct":true},
      {"id":"b","label":"Un service","is_correct":false},
      {"id":"c","label":"Un battement","is_correct":false},
      {"id":"d","label":"Une girouette","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ertv','module-2','qcm-v1'], 'ERTV-M2-QCM-02', false,
    $mft$La course est le trajet d'un terminus à l'autre à un horaire donné : l'unité de base du graphicage. Le service est un ensemble de courses, le battement un temps d'attente au terminus, la girouette un afficheur.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$À 6 h 15, une voiture quitte le dépôt à vide pour rejoindre le terminus G et assurer sa première course. Comment qualifiez-vous ce trajet ?$mft$,
    $mft$[
      {"id":"a","label":"Un haut-le-pied : un trajet sans voyageurs, qui coûte sans produire de recette","is_correct":true},
      {"id":"b","label":"Une course commerciale comme une autre","is_correct":false},
      {"id":"c","label":"Un battement de régulation","is_correct":false},
      {"id":"d","label":"Une coupure","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ertv','module-2','qcm-v1'], 'ERTV-M2-QCM-03', false,
    $mft$Le haut-le-pied est un déplacement à vide (dépôt vers terminus, repositionnement) que le graphicage cherche à minimiser. Battement et coupure sont des temps d'attente, pas des trajets.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Le graphicage de votre réseau est terminé : les voitures sont construites. En quoi consiste l'étape suivante, appelée habillage ?$mft$,
    $mft$[
      {"id":"a","label":"Découper et combiner les services véhicules en services conducteurs conformes au cadre social","is_correct":true},
      {"id":"b","label":"Choisir la livrée publicitaire des véhicules","is_correct":false},
      {"id":"c","label":"Installer les girouettes sur le parc","is_correct":false},
      {"id":"d","label":"Négocier les tarifs avec l'autorité organisatrice","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ertv','module-2','qcm-v1'], 'ERTV-M2-QCM-04', false,
    $mft$L'habillage transforme les journées de véhicules en journées de conducteurs : vacations, coupures, relèves, équité. La livrée n'a rien à voir malgré le mot.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Sur une ligne, le temps de cycle complet (aller, retour et battements compris) est de 120 minutes. Vous visez un départ toutes les 20 minutes dans chaque sens. Combien de voitures faut-il ?$mft$,
    $mft$[
      {"id":"a","label":"6 voitures","is_correct":true},
      {"id":"b","label":"4 voitures","is_correct":false},
      {"id":"c","label":"8 voitures","is_correct":false},
      {"id":"d","label":"3 voitures","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-2','qcm-v1'], 'ERTV-M2-QCM-05', false,
    $mft$Nombre de voitures = temps de cycle divisé par la fréquence : 120 / 20 = 6. Les autres réponses correspondent à des erreurs de division ou à l'oubli des battements dans le cycle.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$En pointe du soir, une course arrive au terminus avec 8 minutes de retard. Le graphique prévoit 12 minutes de battement. Que se passe-t-il ?$mft$,
    $mft$[
      {"id":"a","label":"La course suivante repart à l'heure : le battement a absorbé l'aléa, c'est son rôle de régulation","is_correct":true},
      {"id":"b","label":"La course suivante part mécaniquement avec 8 minutes de retard","is_correct":false},
      {"id":"c","label":"Le conducteur doit rattraper le retard en roulant plus vite","is_correct":false},
      {"id":"d","label":"La course suivante est supprimée par précaution","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-2','qcm-v1'], 'ERTV-M2-QCM-06', false,
    $mft$Le battement est l'amortisseur du système : il encaisse les aléas pour que chaque départ reste à l'heure. Rattraper en roulant plus vite dégrade la sécurité, et rien ne justifie une suppression.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Vous hésitez entre un horaire cadencé (départ toutes les 30 minutes, aux mêmes minutes toute la journée) et des horaires calés au plus près de la demande observée. Quel est le principal argument POUR le cadencement ?$mft$,
    $mft$[
      {"id":"a","label":"Un horaire mémorisable qui rend l'offre lisible et attire les voyageurs occasionnels","is_correct":true},
      {"id":"b","label":"Il supprime tous les kilomètres à vide","is_correct":false},
      {"id":"c","label":"Il réduit toujours le nombre de véhicules nécessaires","is_correct":false},
      {"id":"d","label":"Il dispense de relever les temps de parcours sur le terrain","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-2','qcm-v1'], 'ERTV-M2-QCM-07', false,
    $mft$Le cadencement se retient sans consulter la fiche horaire : c'est son atout commercial. En revanche il peut coûter davantage (courses peu remplies en creux) et n'exonère jamais des relevés terrain.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$L'habillage d'un conducteur prévoit chaque jour 1 h 45 d'attente payée au terminus entre deux courses, sans autre tâche possible. Quelle lecture d'exploitant en faites-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Des heures payées non roulées : un coût sec qui appelle à revoir les enchaînements ou à combiner ce service avec une autre activité","is_correct":true},
      {"id":"b","label":"Un avantage social à généraliser sur tous les services","is_correct":false},
      {"id":"c","label":"Un temps sans importance économique puisque le véhicule ne roule pas","is_correct":false},
      {"id":"d","label":"Une anomalie sans conséquence tant que le conducteur est d'accord","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-2','qcm-v1'], 'ERTV-M2-QCM-08', false,
    $mft$Le conducteur est le premier poste de coût : chaque heure payée improductive pèse. La réponse n'est pas de supprimer toute attente, mais de réorganiser (réenchaînement, mutualisation avec du scolaire ou de l'occasionnel).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Dans le compte d'exploitation d'un réseau de transport de voyageurs, quel est en général le premier poste de coût ?$mft$,
    $mft$[
      {"id":"a","label":"Le personnel de conduite : les heures de service, y compris les attentes","is_correct":true},
      {"id":"b","label":"Le carburant","is_correct":false},
      {"id":"c","label":"L'assurance de la flotte","is_correct":false},
      {"id":"d","label":"Les péages autoroutiers","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-2','qcm-v1'], 'ERTV-M2-QCM-09', false,
    $mft$Les salaires et charges de conduite dominent la structure de coûts, d'où l'enjeu majeur de l'habillage. Énergie, assurance et péages pèsent, mais loin derrière.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Sur la ligne A (temps de cycle de 100 minutes dont 10 minutes de battement à chaque terminus, fréquence 30 minutes, 4 voitures), on vous propose de réduire chaque battement à 5 minutes pour tenter d'économiser une voiture. Le cycle tombe à 90 minutes. Qu'en concluez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"90 / 30 = 3 voitures : l'économie est réelle sur le papier, mais 5 minutes de battement n'absorberont presque aucun aléa : le premier retard se propagera toute la journée","is_correct":true},
      {"id":"b","label":"L'économie est impossible : le nombre de voitures ne dépend pas des battements","is_correct":false},
      {"id":"c","label":"Il faudra au contraire 5 voitures pour compenser","is_correct":false},
      {"id":"d","label":"Le service devient plus régulier puisque les véhicules attendent moins","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ertv','module-2','qcm-v1'], 'ERTV-M2-QCM-10', false,
    $mft$L'arithmétique fonctionne (90 / 30 = 3) mais la régulation disparaît : c'est l'arbitrage classique entre coût et robustesse. Le battement fait bien partie du cycle, et le réduire ne rend pas le service plus régulier, au contraire.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Un service conducteur comporte deux vacations : de 6 h 30 à 9 h 30, puis de 16 h 00 à 19 h 30. Quelle est l'amplitude de cette journée ?$mft$,
    $mft$[
      {"id":"a","label":"13 heures : l'amplitude court de la prise de service à la fin de service, coupure comprise","is_correct":true},
      {"id":"b","label":"6 h 30 : la somme des deux vacations travaillées","is_correct":false},
      {"id":"c","label":"9 heures : l'amplitude exclut les coupures","is_correct":false},
      {"id":"d","label":"3 h 30 : la durée de la vacation la plus longue","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ertv','module-2','qcm-v1'], 'ERTV-M2-QCM-11', false,
    $mft$De 6 h 30 à 19 h 30 il s'écoule 13 heures : c'est l'amplitude, coupures comprises. Le temps travaillé (6 h 30) est une autre notion ; les seuils maximaux exacts se vérifient dans la CCN.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Deux candidats répondent à un appel d'offres scolaire. Le moins-disant a chiffré sans les haut-le-pied ni les pénalités contractuelles de ponctualité. S'il gagne, que risque-t-il ?$mft$,
    $mft$[
      {"id":"a","label":"Une exploitation à perte : les kilomètres à vide et les pénalités mangeront une marge déjà optimiste, pendant toute la durée du contrat","is_correct":true},
      {"id":"b","label":"Rien : les pénalités ne s'appliquent jamais la première année","is_correct":false},
      {"id":"c","label":"Rien : les haut-le-pied sont toujours remboursés par l'autorité organisatrice","is_correct":false},
      {"id":"d","label":"Une simple renégociation automatique du prix à la hausse","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ertv','module-2','qcm-v1'], 'ERTV-M2-QCM-12', false,
    $mft$Un marché se vit aux conditions signées : les coûts oubliés restent à la charge du transporteur et les pénalités s'appliquent dès les premiers manquements. Ni remboursement automatique des kilomètres à vide, ni renégociation garantie.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Quels sont les deux curseurs qui définissent quand et à quel rythme une ligne fonctionne dans la journée ?$mft$,
   $mft$La fréquence (intervalle entre deux départs) et l'amplitude (du premier au dernier départ de la journée).$mft$,
   2, 'facile', ARRAY['ertv','module-2','question-courte'], 'ERTV-M2-QC-01', false,
   $mft$Le troisième curseur, la capacité, dimensionne le véhicule.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Comment appelle-t-on l'ensemble ordonné des courses confiées à un même véhicule sur la journée ?$mft$,
   $mft$Un service véhicule, appelé une voiture dans le vocabulaire de l'exploitation.$mft$,
   2, 'facile', ARRAY['ertv','module-2','question-courte'], 'ERTV-M2-QC-02', false,
   $mft$C'est le produit du graphicage, avant l'habillage.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Quel document détaille au conducteur sa prise de service, ses courses, ses coupures et sa fin de service ?$mft$,
   $mft$Le billet de service.$mft$,
   2, 'facile', ARRAY['ertv','module-2','question-courte'], 'ERTV-M2-QC-03', false,
   $mft$Il doit être lisible sans ambiguïté, y compris à 5 h du matin.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Pourquoi les temps de parcours d'une future ligne doivent-ils être relevés sur le terrain aux heures de pointe, et non estimés sur une carte ?$mft$,
   $mft$Parce qu'un temps estimé hors pointe est optimiste : un graphique construit dessus produit des retards en chaîne dès la mise en service, les battements sont consommés et le cadencement s'effondre.$mft$,
   2, 'moyen', ARRAY['ertv','module-2','question-courte'], 'ERTV-M2-QC-04', false,
   $mft$Le graphique vaut ce que valent ses temps de parcours.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Temps de cycle de 80 minutes (aller, retour et battements compris), fréquence visée de 20 minutes : combien de voitures faut-il, et par quel calcul ?$mft$,
   $mft$80 / 20 = 4 voitures : le nombre de voitures est le temps de cycle divisé par la fréquence, arrondi au supérieur si la division ne tombe pas juste.$mft$,
   2, 'moyen', ARRAY['ertv','module-2','question-courte'], 'ERTV-M2-QC-05', false,
   $mft$Ici la division tombe juste : pas d'arrondi à redistribuer.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$À quoi sert le battement au terminus, et que se passe-t-il concrètement s'il est trop court ?$mft$,
   $mft$Il absorbe les aléas pour que chaque course reparte à l'heure ; trop court, le moindre retard se propage de course en course toute la journée et les intervalles deviennent irréguliers.$mft$,
   2, 'moyen', ARRAY['ertv','module-2','question-courte'], 'ERTV-M2-QC-06', false,
   $mft$Le battement est un investissement de régularité, pas du temps perdu.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Citez trois critères d'équité à respecter entre conducteurs lors de l'habillage.$mft$,
   $mft$Par exemple : la répartition des matinées et des soirées, le roulement des week-ends et jours fériés, l'équilibre des services coupés et des services continus, la publication des plannings à l'avance.$mft$,
   2, 'moyen', ARRAY['ertv','module-2','question-courte'], 'ERTV-M2-QC-07', false,
   $mft$Trois critères distincts attendus.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Donnez trois usages qui peuvent se succéder dans la même journée pour mutualiser un autocar.$mft$,
   $mft$Par exemple : circuits scolaires le matin et le soir, ligne régulière ou navette en journée, sorties périscolaires en creux méridien, service occasionnel en soirée ou le week-end.$mft$,
   2, 'moyen', ARRAY['ertv','module-2','question-courte'], 'ERTV-M2-QC-08', false,
   $mft$Un car, plusieurs vies : la journée type du parc bien utilisé.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Pourquoi le coût horaire est-il plus pertinent que le coût kilométrique pour analyser un service urbain lent ?$mft$,
   $mft$Parce qu'à faible vitesse commerciale, le poste dominant (le conducteur) dépend du temps passé et non de la distance : un raisonnement au kilomètre sous-estimerait le coût réel des services lents.$mft$,
   2, 'difficile', ARRAY['ertv','module-2','question-courte'], 'ERTV-M2-QC-09', false,
   $mft$On convertit l'un dans l'autre par la vitesse commerciale.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$En quoi un bon habillage agit-il à la fois sur les coûts et sur la fatigue des conducteurs ?$mft$,
   $mft$Il réduit les heures payées non roulées (attentes, haut-le-pied évitables) tout en maîtrisant amplitudes et coupures : moins de journées étirées, donc moins de fatigue, d'absentéisme et de turn-over, qui sont aussi des coûts.$mft$,
   2, 'difficile', ARRAY['ertv','module-2','question-courte'], 'ERTV-M2-QC-10', false,
   $mft$Optimiser les heures ET la charge humaine : les deux faces du même travail.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Un président de communauté de communes vous demande « un car toutes les 10 minutes de 5 h à minuit » sur une liaison rurale qui transporte surtout des scolaires. Expliquez la démarche d'analyse que vous conduisez et la manière de présenter les arbitrages coût/service à l'élu.$mft$,
   $mft$Réponse modèle. Démarche d'analyse : objectiver la demande avant de discuter l'offre : comptages et enquêtes origine-destination, flux domicile-école (horaires précis des établissements) et domicile-travail, courbe de charge par tranche horaire, saisonnalité scolaire (vacances). Sur une liaison rurale à dominante scolaire, la demande se concentre en deux pointes courtes ; les creux et la soirée sont probablement vides. Dimensionnement : proposer des scénarios contrastés : un socle calé sur les pointes (fréquence renforcée aux heures d'entrée et de sortie des établissements, capacité adaptée), un service en creux plus léger (fréquence réduite, minibus, voire transport à la demande), une amplitude réaliste. Présentation des arbitrages : pour chaque scénario, montrer les deux faces : niveau de service (fréquence, amplitude, capacité) ET moyens engagés (véhicules, heures de conduite, kilomètres, dont kilomètres à vide). Chiffrer ce que coûterait la demande initiale (10 minutes de fréquence sur 19 heures d'amplitude : un parc et des heures sans rapport avec la fréquentation attendue) et proposer le meilleur service par euro investi. Conclure sur une démarche d'essai : lancement, comptages, ajustement aux résultats.$mft$,
   $mft$Barème /5 : démarche d'analyse complète (sources, pointes/creux, saisonnalité) (1,5 pt) ; scénarios différenciés pointe/creux avec capacité adaptée (1,5 pt) ; présentation double face service/moyens à l'élu (1,5 pt) ; logique d'ajustement après lancement (0,5 pt). Erreurs fréquentes : accepter ou refuser la demande sans la chiffrer ; oublier la saisonnalité scolaire.$mft$,
   5, 'facile', ARRAY['ertv','module-2','question-redigee'], 'ERTV-M2-QR-01', false,
   $mft$L'arbitrage coût/service argumenté face à une demande politique.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Décrivez, étape par étape, la construction du graphique de circulation d'une ligne nouvelle : de la course isolée aux services véhicules prêts pour l'habillage. Précisez où se placent les battements, les haut-le-pied et les coupures, et pourquoi.$mft$,
   $mft$Réponse modèle. Étape 1 : rassembler les données d'entrée : itinéraire, arrêts, temps de parcours relevés sur le terrain aux heures de pointe (dans les deux sens), fréquences et amplitude visées. Étape 2 : tracer chaque course sur le graphique espace-temps (temps en horizontal, distance en vertical) : chaque trait oblique matérialise une course ; les intervalles entre traits vérifient la fréquence. Étape 3 : positionner les battements aux terminus : temps de régulation entre l'arrivée d'une course et le départ de la suivante, dimensionnés pour absorber les aléas récurrents constatés. Étape 4 : enchaîner les courses en voitures : chaque arrivée alimente un départ suivant, en cherchant le nombre minimal de véhicules (temps de cycle divisé par la fréquence, arrondi au supérieur, l'écart redistribué en battement). Étape 5 : ajouter les haut-le-pied indispensables : sortie du dépôt avant la première course, rentrée après la dernière, repositionnements éventuels : ils se minimisent car ils coûtent sans produire. Étape 6 : placer les coupures dans les creux (voitures rentrant au dépôt ou stationnées) pour ne pas faire rouler des courses vides. Étape 7 : vérifier la faisabilité globale (temps réels, capacité des terminus) et livrer les voitures à l'habillage.$mft$,
   $mft$Barème /5 : enchaînement logique et complet des étapes (2 pts) ; battements expliqués (régulation) et bien placés (1 pt) ; haut-le-pied identifiés et minimisés (1 pt) ; coupures en creux et passage à l'habillage (1 pt). Erreurs fréquentes : confondre battement et coupure ; oublier les sorties et rentrées de dépôt.$mft$,
   5, 'facile', ARRAY['ertv','module-2','question-redigee'], 'ERTV-M2-QR-02', false,
   $mft$La procédure de graphicage complète, du relevé terrain aux voitures.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Cas chiffré. La ligne B affiche 35 minutes de parcours par sens et 10 minutes de battement à chaque terminus. En pointe, la fréquence visée est de 15 minutes ; en creux, de 30 minutes. Calculez le nombre de voitures nécessaires en pointe puis en creux, et expliquez ce que l'exploitant fait des voitures libérées entre les deux.$mft$,
   $mft$Réponse modèle. Temps de cycle : 35 + 10 + 35 + 10 = 90 minutes, identique en pointe et en creux (les battements font partie du cycle). En pointe : 90 / 15 = 6 voitures exactement. En creux : 90 / 30 = 3 voitures. Trois voitures sont donc libérées à la fin de la pointe du matin. Options de l'exploitant : la coupure simple (rentrée au dépôt si le haut-le-pied est court, sinon stationnement au terminus) en attendant la pointe du soir ; la réaffectation productive : services occasionnels, sorties périscolaires, renfort d'une autre ligne : c'est la mutualisation, qui améliore le taux d'utilisation du parc ; ou l'entretien programmé en journée, qui évite d'immobiliser des véhicules pendant les pointes. Côté conducteurs, l'habillage traduit cette modulation : services en deux fois (pointe du matin puis pointe du soir) ou services continus combinant ligne et activités de creux ; les choix se vérifient contre le cadre social (amplitude, coupures : seuils exacts dans la CCN). La modulation pointe/creux est le premier levier d'économie d'une ligne bien graphiquée.$mft$,
   $mft$Barème /5 : cycle correct de 90 minutes incluant les deux battements (1 pt) ; 6 voitures en pointe et 3 en creux, calculs posés (2 pts) ; au moins deux options crédibles pour les voitures libérées (1,5 pt) ; lien avec l'habillage et le cadre social (0,5 pt). Erreurs fréquentes : oublier les battements dans le cycle ; croire que la fréquence de creux change le temps de cycle.$mft$,
   5, 'moyen', ARRAY['ertv','module-2','question-redigee'], 'ERTV-M2-QR-03', false,
   $mft$Modulation pointe/creux calculée puis exploitée.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Analysez ce billet de service et proposez vos corrections : prise de service 6 h 00 au dépôt ; courses jusqu'à 9 h 00 ; attente payée au terminus de 9 h 00 à 11 h 00 sans tâche prévue ; courses de 11 h 00 à 13 h 00 ; coupure ; reprise 16 h 30 ; dernières courses jusqu'à 19 h 30. Identifiez les défauts économiques et humains, puis les pistes d'amélioration.$mft$,
   $mft$Réponse modèle. Défauts économiques : deux heures payées non roulées chaque jour (de 9 h à 11 h), sans production ni tâche : sur une année, un coût considérable pour zéro service rendu ; c'est le signe d'un enchaînement de courses mal construit au graphicage, ou d'un habillage qui n'a pas combiné ce service avec une autre activité. Défauts humains : l'amplitude court de 6 h 00 à 19 h 30, soit 13 h 30 : une journée très étirée, avec une coupure d'après-midi qui hache la vie personnelle ; les seuils réglementaires d'amplitude et de coupure applicables (CCN, décrets voyageurs) doivent être vérifiés avant toute publication. Pistes : combler l'attente de 9 h à 11 h par une activité mutualisée (sortie périscolaire, navette de marché, renfort d'une autre ligne) ; sinon repenser l'enchaînement des courses pour rapprocher les blocs ; envisager de scinder en deux services distincts (un service du matin, un service d'après-midi et soirée) pour réduire les amplitudes individuelles ; vérifier l'équité : ce type de journée ne doit pas retomber toujours sur les mêmes ; et réécrire le billet pour que chaque séquence (lieu, heure, tâche) soit sans ambiguïté.$mft$,
   $mft$Barème /5 : coût des heures payées non roulées identifié et raisonné en logique annuelle (1,5 pt) ; amplitude de 13 h 30 calculée et questionnée avec renvoi aux seuils CCN (1,5 pt) ; au moins deux pistes de correction crédibles (mutualisation, réenchaînement, scission) (1,5 pt) ; dimension équité (0,5 pt). Erreurs fréquentes : confondre amplitude et temps de travail ; supprimer l'attente sans proposer de solution d'exploitation.$mft$,
   5, 'moyen', ARRAY['ertv','module-2','question-redigee'], 'ERTV-M2-QR-04', false,
   $mft$Autopsie d'un billet de service coûteux et fatigant.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Cas chiffré (hypothèse d'école). Votre ligne mobilise 5 voitures qui sortent le matin et rentrent le soir. Deux implantations de dépôt sont possibles : le dépôt A à 2 km du terminus, le dépôt B à 12 km. L'exploitation compte 300 jours par an. Calculez les kilomètres à vide annuels dans chaque cas, commentez l'écart et élargissez aux autres critères de choix d'un dépôt.$mft$,
   $mft$Réponse modèle. Chaque voiture effectue deux haut-le-pied par jour : une sortie et une rentrée. Dépôt A : 2 x 2 km = 4 km à vide par voiture et par jour ; pour 5 voitures sur 300 jours : 5 x 300 x 4 = 6 000 km à vide par an. Dépôt B : 2 x 12 km = 24 km par voiture et par jour, soit 5 x 300 x 24 = 36 000 km à vide par an. Écart : 30 000 km annuels improductifs, à valoriser au coût kilométrique complet du véhicule (énergie, entretien, usure), auxquels s'ajoute le temps de conduite payé correspondant : le conducteur est payé pendant le haut-le-pied. Élargissement : le choix d'un dépôt ne se réduit pas aux kilomètres : coût du foncier et des installations (un dépôt proche du centre coûte plus cher), capacité d'accueil et d'extension, accès pour les véhicules, possibilité d'avitaillement et d'entretien sur site, position par rapport à l'ensemble des lignes actuelles et futures (un dépôt optimal pour une ligne peut être excentré pour le réseau). L'arbitrage se chiffre sur la durée du contrat : loyer économisé contre kilomètres et heures perdus chaque jour.$mft$,
   $mft$Barème /5 : calculs exacts (6 000 et 36 000 km, écart de 30 000 km) posés proprement (2 pts) ; valorisation double : coût kilométrique ET heures de conduite payées (1,5 pt) ; au moins trois critères complémentaires de choix du dépôt (1 pt) ; logique d'arbitrage sur la durée (0,5 pt). Erreurs fréquentes : oublier que la voiture fait DEUX trajets à vide par jour ; ignorer le coût du temps de conducteur.$mft$,
   5, 'moyen', ARRAY['ertv','module-2','question-redigee'], 'ERTV-M2-QR-05', false,
   $mft$Le poids économique du positionnement du dépôt, chiffré.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Plan d'action. Dans votre entreprise, les conducteurs dénoncent un habillage injuste : services du matin toujours attribués aux mêmes, week-ends mal répartis, plannings connus au dernier moment. Construisez votre plan d'action d'exploitant : diagnostic, critères d'équité, méthode de répartition, concertation et indicateurs de suivi.$mft$,
   $mft$Réponse modèle. Diagnostic : objectiver avant d'agir : extraire sur plusieurs mois la répartition réelle des services par conducteur (matinées, soirées, coupés, week-ends, jours fériés) et mesurer les écarts ; identifier les causes (attributions historiques, arrangements informels, absence de règle écrite). Critères d'équité : définir avec l'équipe des règles explicites : rotation des prises de service matinales et des fins tardives, roulement des week-ends et fériés sur un cycle connu, plafond de services coupés par conducteur et par semaine, prise en compte encadrée des contraintes individuelles (sans créer de privilèges permanents). Méthode : construire un roulement type sur plusieurs semaines, publié à l'avance à échéance fixe, avec une procédure claire d'échanges de services (validés par l'exploitation pour rester conformes au cadre social : amplitudes et coupures vérifiées, seuils CCN). Concertation : associer les représentants du personnel et des conducteurs volontaires à la construction ; tester le roulement sur une période pilote, recueillir les retours, ajuster. Indicateurs de suivi : écart maximal de week-ends travaillés entre conducteurs, répartition des matinées, délai moyen de publication des plannings, absentéisme et réclamations. L'équité ne supprime pas les contraintes du métier : elle les répartit selon une règle connue de tous.$mft$,
   $mft$Barème /5 : diagnostic objectivé par les données (1 pt) ; critères d'équité explicites et complets (1,5 pt) ; méthode de roulement publiée avec procédure d'échanges encadrée (1,5 pt) ; concertation et indicateurs de suivi (1 pt). Erreurs fréquentes : promettre l'équité sans règle mesurable ; laisser les échanges de services sans validation d'exploitation.$mft$,
   5, 'moyen', ARRAY['ertv','module-2','question-redigee'], 'ERTV-M2-QR-06', false,
   $mft$Rétablir l'équité d'habillage par une démarche outillée.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Votre entreprise prépare une réponse à un appel d'offres : 12 circuits scolaires et 2 lignes régulières sur un territoire voisin, contrat de plusieurs années avec pénalités (ponctualité, courses non assurées). Décrivez votre méthode de chiffrage sérieux et les pièges du chiffrage optimiste.$mft$,
   $mft$Réponse modèle. Méthode : partir de l'exploitation réelle, pas des tableurs : reconnaître le terrain (temps de parcours en pointe, accès des établissements, zones de retournement), esquisser graphicage et habillage AVANT de chiffrer, car ce sont eux qui déterminent les moyens : nombre de voitures et de services conducteurs, kilomètres commerciaux ET haut-le-pied (le territoire est voisin : où stationneront les véhicules ? un dépôt ou un parking relais est-il à prévoir ?). Chiffrer en coûts complets : heures de service payées (dont attentes), véhicules (amortissement, énergie, entretien, assurance), structure et encadrement local ; ajouter une provision pour aléas et pour les pénalités résiduelles inévitables (aucune exploitation n'est parfaite), intégrer les mécanismes de révision de prix sur la durée du contrat, et tester la marge sur des hypothèses dégradées (absentéisme, hausse d'énergie). Vérifier enfin la capacité à faire : conducteurs recrutables localement, véhicules disponibles au calendrier imposé. Pièges du chiffrage optimiste : oublier les haut-le-pied et les heures non roulées, supposer zéro pénalité, chiffrer sur des temps de parcours de carte, ignorer la montée en charge (formation, recrutement), et acheter le marché à perte en espérant renégocier : les pénalités et les coûts réels mangent les marges optimistes pendant toute la durée du contrat.$mft$,
   $mft$Barème /5 : graphicage et habillage esquissés avant chiffrage (1 pt) ; coûts complets incluant haut-le-pied, attentes et implantation locale (1,5 pt) ; provisions pénalités/aléas et révision de prix sur la durée (1,5 pt) ; au moins trois pièges du chiffrage optimiste (1 pt). Erreurs fréquentes : chiffrer au kilomètre commercial seul ; considérer les pénalités comme théoriques.$mft$,
   5, 'difficile', ARRAY['ertv','module-2','question-redigee'], 'ERTV-M2-QR-07', false,
   $mft$Chiffrer un appel d'offres en exploitant, pas en optimiste.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Comparez deux scénarios d'offre pour une même ligne (amplitude 6 h à 20 h) : scénario 1, cadencement uniforme à 30 minutes toute la journée ; scénario 2, offre modulée à 15 minutes en pointes et 60 minutes en creux. Comparez moyens engagés, lisibilité pour le voyageur, robustesse, et formulez une recommandation argumentée.$mft$,
   $mft$Réponse modèle. Moyens : à temps de cycle égal, la fréquence dicte la flotte : le scénario 2 exige en pointe deux fois plus de voitures que le scénario 1 (fréquence doublée), mais deux fois moins en creux ; comme le parc se dimensionne sur la pointe, le scénario 2 coûte plus cher en véhicules et en conducteurs de pointe (services en deux fois plus nombreux), tandis que le scénario 1 fait rouler en creux des courses peu remplies. Lisibilité : le cadencement uniforme est imbattable (un départ aux mêmes minutes toute la journée) ; l'offre modulée reste lisible si les basculements sont simples et bien affichés (15 minutes en pointe, heure fixe en creux). Robustesse : la pointe à 15 minutes encaisse mieux la charge (moins de saturation, montées plus rapides) ; en revanche, le creux à 60 minutes rend chaque course supprimée très pénalisante pour le voyageur. Adéquation à la demande : le scénario 2 colle aux flux domicile-travail et scolaires ; le scénario 1 sert mieux les déplacements occasionnels de journée. Recommandation : sur une ligne à pointes marquées, le scénario 2, à condition de soigner la communication horaire et de mutualiser en creux les voitures de pointe libérées ; le scénario 1 se défend sur une ligne à demande étale, à vocation urbaine.$mft$,
   $mft$Barème /5 : lien fréquence/flotte posé (pointe dimensionnante, rapport du simple au double) (1,5 pt) ; comparaison lisibilité et robustesse argumentée dans les deux sens (1,5 pt) ; adéquation aux profils de demande (1 pt) ; recommandation conditionnelle argumentée (1 pt). Erreurs fréquentes : recommander sans condition ; oublier que le parc se dimensionne sur la pointe.$mft$,
   5, 'difficile', ARRAY['ertv','module-2','question-redigee'], 'ERTV-M2-QR-08', false,
   $mft$Cadencement uniforme contre offre modulée : l'arbitrage complet.$mft$);

  RAISE NOTICE 'Module 2 ERTV créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $ertvm2$;
