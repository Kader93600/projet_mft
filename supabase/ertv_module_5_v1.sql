-- =====================================================================
-- ERTV : EXPLOITANT EN TRANSPORT ROUTIER DE VOYAGEURS
-- MODULE 5 : SÉCURITÉ DES VOYAGEURS ET QUALITÉ DE SERVICE
-- v1 (juillet 2026)
-- Transporter des personnes en sécurité : transport d'enfants,
-- accessibilité PMR, gestion de crise, et la qualité de service qui
-- fidélise les autorités organisatrices.
-- ⚠ STATUT : active = false (« à valider »). Idempotent.
-- =====================================================================

DO $ertvm5$
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

  DELETE FROM public.question_bank WHERE source_ref LIKE 'ERTV-M5-%';
  DELETE FROM public.modules WHERE slug = 'ertv-securite-qualite';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 5 : Sécurité des voyageurs et qualité de service',
    'ertv-securite-qualite', v_bloc,
    'Transporter des personnes en sécurité : transport d''enfants, accessibilité PMR, gestion de crise, et la qualité de service qui fidélise les autorités organisatrices.',
    'avance', 330, 50) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 50, true);

  -- ─── Leçon 1 : Le transport d'enfants ──────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'transport-d-enfants',
    'Le transport scolaire : des enfants à bord, zéro routine',
    $mft$> 🎯 **Objectifs**
> - Équiper et signaler correctement un service de transport d'enfants.
> - Sécuriser LE moment critique du circuit scolaire : la montée et la descente.
> - Outiller les conducteurs : listes, ceintures, EAD, consignes spécifiques.

## Un service qui ne tolère aucune routine

Le transport scolaire est le service le plus sensible du transport de voyageurs : des passagers jeunes, parfois très jeunes, imprévisibles, transportés deux fois par jour sur les mêmes itinéraires. Cette répétition est un piège : la routine installe la vitesse d'approche « habituelle », l'arrêt « comme d'habitude », le coup d'œil écourté. L'exploitant construit donc le service pour que la vigilance ne repose pas sur la seule bonne volonté du conducteur : signalisation en état, arrêts étudiés, consignes écrites, sensibilisation répétée.

## La signalisation « transport d'enfants »

Un véhicule affecté au transport d'enfants porte un pictogramme spécifique à l'avant et à l'arrière : il avertit les autres usagers que des enfants peuvent surgir aux abords du véhicule, en particulier à l'arrêt. Des feux spéciaux de signalisation complètent le dispositif lors des arrêts pour la montée et la descente : leurs modalités précises d'utilisation sont à vérifier dans la réglementation en vigueur avant de rédiger vos consignes. Côté exploitation, deux vérifications simples : les véhicules affectés sont correctement équipés, pictogrammes propres, visibles et en bon état ; et la signalisation correspond à la réalité du service, faute de quoi le message se banalise et perd son effet d'alerte auprès des autres conducteurs.

## Liste des passagers et encadrement

Selon les cas (circuit régulier, sortie occasionnelle, voyage avec nuitées), le service s'accompagne d'une liste des passagers et d'un encadrement adapté. L'exploitant exige la liste avant le départ et vérifie l'encadrement convenu avec l'organisateur. Cette liste a un double usage : dimensionner l'accompagnement selon les cas, et surtout servir de référence de recensement si un incident survient (voir la leçon sur la gestion de crise) : on ne peut savoir qui manque que si l'on sait qui est à bord.

## Ceintures : informer et contrôler

Le port de la ceinture est obligatoire dans les autocars. Le rôle de l'entreprise tient en deux mots : information et contrôle. Information : annonce en début de trajet, signalétique aux sièges, rappels par les accompagnateurs, actions de sensibilisation menées avec les établissements. Contrôle : le conducteur et les accompagnateurs rappellent l'obligation et signalent les refus répétés ; l'exploitant traite ces signalements avec l'établissement plutôt que de laisser le conducteur seul face au problème.

## La montée et la descente : LE moment critique

> ⚠️ **Attention**
> Les accidents mortels du transport scolaire ne se produisent pas, pour l'essentiel, pendant le roulage : ils se concentrent aux abords des arrêts, au moment de la montée et surtout de la descente, quand un enfant traverse devant ou derrière le car et échappe au champ de vision des conducteurs.

Trois leviers pour l'exploitant :

- **Des arrêts sécurisés, étudiés avec l'autorité organisatrice** : implantation, visibilité, cheminements piétons, traversées. Un arrêt dangereux se signale, se documente et se fait modifier, il ne se subit pas.
- **La sensibilisation des enfants** : interventions dans les établissements sur les règles vitales : attendre le départ du car pour traverser, ne jamais passer devant ou derrière le véhicule, ne pas courir après un car qui part.
- **Des consignes conducteurs sans ambiguïté**, résumées dans la séquence d'arrêt :

:::flow
1. Approche | Vitesse réduite, surveillance des abords, signalisation activée
2. Arrêt | Uniquement au point d'arrêt défini, jamais d'arrêt improvisé
3. Montée/descente | Portes surveillées, pas de précipitation
4. Contrôle des abords | Rétroviseurs et angles vérifiés : aucun enfant devant ni derrière
5. Départ | Redémarrage souple, insertion prudente
:::

> ❌ **Piège à éviter**
> Le passage en avance sur l'horaire. Un car en retard fait attendre ; un car en avance laisse un enfant seul à l'arrêt, ou le pousse à courir. Sur circuit scolaire, l'avance est une faute de service, pas une performance.

## L'éthylotest antidémarrage (EAD)

Les autocars sont équipés d'un éthylotest antidémarrage : le véhicule ne démarre pas si le dispositif détecte une alcoolémie chez le conducteur. Le périmètre exact des véhicules concernés est à vérifier dans les textes en vigueur. Côté exploitation, trois règles : le dispositif est maintenu en état de fonctionnement, il ne se neutralise jamais (aucune « dérogation » locale, aucun contournement toléré, même pour gagner du temps), et tout dysfonctionnement se signale et se traite comme une immobilisation technique.

## Consignes spécifiques scolaires

La fiche de consignes du conducteur scolaire rassemble : le respect strict de l'horaire (jamais d'avance), la desserte exclusive des arrêts définis, la séquence d'arrêt ci-dessus, la gestion du comportement à bord (ton calme et ferme, jamais de conflit en conduisant : on s'arrête si la sécurité l'exige), le renvoi des parents et des établissements vers l'exploitation, et le signalement immédiat de tout incident (enfant non récupéré à la descente, malaise, chahut dangereux).

## ✅ Synthèse

- Signalisation en état : pictogrammes avant/arrière, feux spéciaux à l'arrêt (modalités à vérifier) ; arrêts définis avec l'AO.
- Montée/descente = LE moment critique : séquence d'arrêt, sensibilisation des enfants, jamais d'avance sur l'horaire.
- Listes de passagers fiables, ceintures (informer ET contrôler), EAD intouchable, incidents signalés à l'exploitation.$mft$,
    $mft$La signalisation transport d'enfants (pictogrammes, feux d'arrêt à vérifier), les listes et l'encadrement, les ceintures, la sécurisation de la montée/descente (moment critique) et l'EAD.$mft$,
    1, 40) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : Accessibilité PMR ───────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'accessibilite-pmr',
    'Accessibilité : transporter tout le monde, vraiment',
    $mft$> 🎯 **Objectifs**
> - Connaître les obligations d'accessibilité : matériel embarqué et démarche réseau.
> - Préparer l'exploitation : formation des conducteurs, procédure en cas de panne de rampe.
> - Situer le TPMR dédié et l'enjeu contractuel et réputationnel de l'accessibilité.

## L'accessibilité n'est pas une option

Les services de transport de voyageurs doivent être accessibles aux personnes handicapées et à mobilité réduite. L'obligation se joue à deux niveaux : le véhicule (équipements embarqués) et le réseau (démarche planifiée de mise en accessibilité, formalisée dans les schémas directeurs d'accessibilité). L'exploitant est en première ligne : ce sont son matériel, ses conducteurs et ses procédures qui transforment une obligation de papier en service réel.

## Le matériel : ce que le véhicule doit offrir

| Équipement | À quoi il sert |
| --- | --- |
| Rampe ou palette d'accès | Permettre la montée d'un fauteuil roulant |
| Emplacement UFR | Accueillir et arrimer l'utilisateur de fauteuil roulant |
| Annonces sonores | Informer les voyageurs déficients visuels (arrêts, correspondances) |
| Annonces visuelles | Informer les voyageurs sourds ou malentendants |

L'accessibilité couvre tous les handicaps, pas seulement le fauteuil : les annonces sonores ET visuelles servent des publics différents et sont l'une comme l'autre indispensables.

> 📌 **À retenir**
> Un équipement présent mais en panne équivaut, pour le voyageur concerné, à un équipement absent. La maintenance des rampes et des systèmes d'annonces fait partie de l'accessibilité au même titre que leur installation : test de la rampe au départ du dépôt, signalement immédiat des pannes, priorité de réparation.

## Le réseau : les schémas directeurs d'accessibilité

À l'échelle du réseau, la mise en accessibilité se programme : les schémas directeurs d'accessibilité planifient la mise à niveau des services et des points d'arrêt. L'exploitant y contribue activement : il connaît le terrain (arrêts impraticables en fauteuil, cheminements dangereux, équipements dégradés) et remonte ces constats à l'autorité organisatrice, qui pilote la programmation.

## En exploitation : le conducteur fait l'accessibilité

La rampe la plus fiable ne sert à rien si le conducteur ne sait pas accueillir. La formation des conducteurs à l'accueil des personnes handicapées porte sur trois piliers :

- **Les gestes techniques** : déploiement de la rampe, arrimage du fauteuil à l'emplacement UFR, vérifications avant départ.
- **Les priorités** : accès à l'emplacement UFR, gestion des conflits d'usage (poussettes, bagages) avec calme et méthode.
- **L'attitude** : s'adresser directement à la personne (pas à son accompagnateur), proposer son aide sans l'imposer, ne jamais présumer de ce que la personne peut ou veut faire.

## La panne de rampe : jamais de refus sec

:::flow
1. Constat | La rampe ne se déploie pas : le conducteur informe le voyageur, calmement
2. Alerte | Appel à l'exploitation : la panne est signalée, la solution s'organise
3. Solution | Selon le réseau : course suivante garantie, véhicule de remplacement, TPMR
4. Traçabilité | Panne consignée, maintenance saisie, suivi jusqu'à réparation
:::

Le refus sec (« la rampe est en panne, je ne peux rien pour vous ») est la pire réponse possible : il laisse une personne sans solution, il expose l'entreprise vis-à-vis de l'AO et il fabrique l'incident réputationnel. La règle d'exploitation : une panne se gère, elle ne se transfère jamais au voyageur.

## Le TPMR dédié

Pour les personnes que le réseau régulier ne peut pas prendre en charge, des services de transport de personnes à mobilité réduite (TPMR) fonctionnent avec des véhicules adaptés, souvent sur réservation, dans un cadre conventionné (conventions avec l'AO ou les collectivités). L'exploitant articule les deux offres : le réseau régulier accessible pour le plus grand nombre, le TPMR pour les situations qui exigent un service dédié.

> 💡 **Astuce**
> Tenez un tableau de bord spécifique de l'accessibilité : disponibilité des rampes, pannes et délais de réparation, réclamations liées au handicap, conducteurs formés. C'est un langage que les AO comprennent immédiatement, et une preuve de sérieux en revue de contrat.

## Contractuel ET réputationnel

L'accessibilité est doublement engageante. Contractuellement : elle figure dans les engagements pris vis-à-vis de l'AO, qui la contrôle et peut la sanctionner. Réputationnellement : un refus de prise en charge filmé ou relayé par une association fait plus de dégâts qu'une année de retards, parce qu'il touche à la dignité des personnes. La qualité de l'accueil des voyageurs handicapés est un marqueur de la qualité globale d'un réseau.

## ✅ Synthèse

- Matériel : rampe/palette, emplacement UFR, annonces sonores et visuelles : installés ET maintenus.
- Réseau : schémas directeurs d'accessibilité, constats de terrain remontés à l'AO.
- Conducteurs formés (gestes, priorités, attitude) ; panne de rampe = procédure et solution, jamais de refus sec ; TPMR conventionné en complément.
- L'accessibilité engage le contrat et la réputation.$mft$,
    $mft$Les équipements d'accessibilité (rampes, UFR, annonces sonores et visuelles), les schémas directeurs, la formation des conducteurs, la procédure de panne de rampe sans refus sec et le TPMR conventionné.$mft$,
    2, 40) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : Gérer une crise ─────────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'gerer-une-crise',
    'L''accident d''autocar : gérer la crise',
    $mft$> 🎯 **Objectifs**
> - Construire le plan d'urgence de l'entreprise pour l'accident d'autocar.
> - Maîtriser la chronologie de crise : alerte, actions sur place, recensement, communication.
> - Préparer l'après : soutien, enquêtes, retour d'expérience, exercices.

## Le plan d'urgence : décider avant, pour ne pas improviser pendant

Un accident d'autocar est l'événement le plus redouté d'un exploitant voyageurs : des dizaines de personnes impliquées, des familles à informer, des médias en quelques minutes. Le plan d'urgence de l'entreprise fixe à froid ce que personne ne saura inventer à chaud : qui alerte qui, qui décide, qui parle, avec quels numéros à jour et quels documents. Il tient en quelques pages, il est connu de la régulation et de l'encadrement, et il vit : mis à jour, testé, corrigé.

:::timeline
1. Alerte : le conducteur alerte les secours puis l'exploitation ; la régulation prévient la direction et l'autorité organisatrice
2. Sur place : mise en sécurité des passagers, évacuation ordonnée si nécessaire
3. Recensement : comptage des personnes évacuées, comparaison avec la liste des passagers
4. Communication : la direction, seule, parle aux familles et aux médias, en messages factuels
5. Après : soutien psychologique, coopération avec les enquêtes, retour d'expérience
:::

## L'alerte : les secours d'abord

Premier réflexe du conducteur : alerter les secours, puis son exploitation. La régulation déroule ensuite la chaîne interne : direction prévenue immédiatement, autorité organisatrice informée (elle l'apprendra de toute façon : mieux vaut par vous), moyens de l'entreprise mobilisés (véhicule de substitution, encadrement envoyé sur place). Le plan d'urgence contient la liste des numéros à jour : une chaîne d'alerte qui bute sur un numéro obsolète perd des minutes qui comptent.

## Sur place : évacuer de façon ORDONNÉE, si nécessaire

L'évacuation n'est pas systématique : on évacue si le véhicule ou son environnement expose les passagers (feu, position dangereuse, risque de sur-accident). Quand elle s'impose, elle doit être ordonnée : un mouvement de panique dans un couloir d'autocar blesse. Le conducteur s'appuie sur les équipements réglementaires de bord : issues de secours signalées, marteaux brise-vitre, coupe-ceintures pour libérer un passager bloqué par sa ceinture, extincteurs pour un départ de feu. Les passagers valides aident les plus fragiles ; le groupe s'éloigne du véhicule vers une zone sûre, à l'écart de la circulation.

## Le recensement : LA liste

> 📌 **À retenir**
> Le recensement répond à une seule question, vitale : manque-t-il quelqu'un ? Il n'a de sens que par comparaison entre les personnes comptées en zone de regroupement et la liste des passagers. C'est pour cet instant précis que la liste doit être fiable AVANT le départ : établie, complète, et accessible (l'exploitation doit pouvoir la produire même si l'exemplaire de bord est resté dans le véhicule).

Un comptage de 42 personnes pour 45 inscrites n'est pas une anomalie administrative : c'est une information de secours, à transmettre immédiatement aux équipes sur place.

## Familles et médias : une seule voix

La règle est absolue : la direction, et elle seule, s'exprime. Ni le conducteur, ni la régulation, ni un encadrant sur place ne répondent aux journalistes ou ne confirment des informations. Les messages sont factuels : ce qui est établi (un accident a eu lieu, les secours interviennent, un numéro est ouvert pour les familles), jamais de spéculation sur les causes, jamais de bilan non confirmé, pas de noms. Les familles sont accueillies et informées en priorité, avant et mieux que les médias : c'est une question de dignité, et c'est ce que l'on retiendra de l'entreprise.

## Le soutien psychologique

Passagers, familles, mais aussi conducteur et équipes d'exploitation : un accident grave laisse des traces chez tous ceux qu'il touche. Le plan d'urgence prévoit l'activation d'un soutien psychologique, et l'encadrement ne « remet pas au travail » un conducteur choqué comme si de rien n'était.

## Les enquêtes et le retour d'expérience

Deux logiques d'enquête coexistent : l'enquête judiciaire menée par les forces de l'ordre (établir les responsabilités) et l'enquête technique du BEA-TT (comprendre pour prévenir). L'entreprise coopère avec les deux : éléments préservés (véhicule, documents, données), interlocuteurs désignés, aucune pièce « arrangée ». Vient ensuite le retour d'expérience interne : qu'est-ce qui a fonctionné, qu'est-ce qui a manqué (numéros, liste, délais, communication), et quelles corrections apporter au plan, aux consignes, à la formation.

> 🎓 **Le réflexe du pro**
> Une crise se répète AVANT qu'elle arrive. L'exercice de simulation (alerte déclenchée, liste réclamée, appels de « journalistes » simulés) transforme le plan d'urgence en réflexes et révèle les failles quand elles ne coûtent rien : un numéro obsolète découvert en exercice est une anecdote ; découvert un soir d'accident, c'est un drame dans le drame.

## ✅ Synthèse

- Plan d'urgence écrit, connu, à jour : alerte (secours, direction, AO), rôles définis.
- Évacuation ordonnée si nécessaire : issues, marteaux brise-vitre, coupe-ceintures, extincteurs.
- Recensement par comparaison avec LA liste, fiable avant le départ ; tout écart est transmis aux secours.
- La direction seule parle, en messages factuels ; soutien psychologique ; coopération BEA-TT et forces de l'ordre ; REX et exercices réguliers.$mft$,
    $mft$Le plan d'urgence accident : alerte (secours, direction, AO), évacuation ordonnée avec les équipements de bord, recensement sur liste fiable, communication par la direction seule, soutien, enquêtes BEA-TT et REX.$mft$,
    3, 45) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : Qualité et relation AO ──────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'qualite-et-relation-ao',
    'La qualité mesurée et la relation avec l''autorité organisatrice',
    $mft$> 🎯 **Objectifs**
> - Mesurer la qualité : référentiels, enquêtes mystère et de satisfaction, indicateurs.
> - Traiter les réclamations avec méthode et délais.
> - Entretenir la relation avec l'AO : reporting sincère, revues de contrat, avenants.

## La qualité ne se déclare pas, elle se mesure

Dans un contrat de transport public, la qualité n'est pas un slogan : c'est un ensemble d'engagements de service formalisés dans un référentiel (ponctualité, information des voyageurs, propreté, accueil, accessibilité, traitement des réclamations), chacun assorti d'un niveau attendu et d'une méthode de mesure. L'exploitant qui découvre le référentiel au moment du contrôle a déjà perdu : les engagements se pilotent au quotidien, comme la production.

## Mesurer : enquêtes mystère et satisfaction

Deux outils complémentaires. L'enquête mystère (un enquêteur anonyme parcourt le réseau avec une grille : propreté du véhicule, tenue, annonce des arrêts, accueil) photographie la conformité aux engagements, course par course. L'enquête de satisfaction interroge les voyageurs sur leur perception globale du service. Les deux ne racontent pas la même histoire : un réseau peut être conforme et mal perçu, ou l'inverse ; c'est le croisement des deux qui apprend quelque chose. L'exploitant mène aussi ses propres contrôles internes, sans attendre ceux de l'AO.

## Les réclamations : une méthode, des délais

:::flow
1. Accusé de réception | Le réclamant sait qu'il est entendu, un délai de réponse est annoncé
2. Enquête | Faits établis en interne : données d'exploitation, témoignages, sans a priori
3. Réponse | Factuelle et honnête : on reconnaît ce qui est avéré, on explique ce qui ne l'est pas
4. Correctif | La cause est traitée (consigne, formation, horaire) et le traitement est tracé
:::

Chaque étape a un délai défini, et tenu. Une réclamation bien traitée fidélise souvent mieux qu'un service sans incident : elle prouve que le réseau écoute. Le fichier des réclamations, analysé par motif, par ligne et par période, est aussi l'un des meilleurs capteurs de dérive du réseau : une hausse des réclamations de retard sur une ligne signale des temps de parcours à revoir.

## Propreté et confort : le fil conducteur

La propreté est l'indicateur le plus visible du réseau : le voyageur comme l'élu jugent d'abord ce qu'ils voient et où ils s'assoient. Véhicules nettoyés selon un plan défini et contrôlé, dégradations traitées vite (un tag qui reste appelle le suivant), confort maintenu (sièges, chauffage, climatisation). D'un contrat à l'autre, la propreté et le confort sont le fil conducteur du renouvellement des contrats : c'est l'image que l'AO garde de « son » réseau.

## Le reporting à l'AO : la sincérité comme stratégie

> ⚠️ **Attention**
> Le tableau de bord transmis à l'AO doit être sincère, y compris quand il est mauvais. Un indicateur maquillé finit toujours par se voir (enquête mystère, réclamations, terrain), et un seul chiffre arrangé découvert détruit la crédibilité de TOUS les chiffres transmis, passés et futurs. La confiance vaut mieux que le maquillage : un mauvais mois s'explique et s'accompagne d'un plan d'action ; une tricherie ne se rattrape pas.

Le bon reporting : des indicateurs définis au contrat, produits régulièrement, commentés (causes, actions engagées, échéances), et des alertes données AVANT que l'AO ne découvre le problème par un autre canal.

## Revues de contrat et avenants : le contrat vit

La revue de contrat est le rendez-vous périodique où exploitant et AO examinent ensemble les indicateurs, les réclamations, les évolutions du réseau et les sujets qui fâchent. S'y présenter préparé (chiffres consolidés, analyses, propositions), c'est démontrer la maîtrise de son exploitation. Quand l'offre évolue (prolongement de ligne, nouveau quartier, horaires modifiés), l'évolution se formalise par un avenant : périmètre décrit, moyens chiffrés (véhicules, heures, kilomètres), incidences financières validées. Exécuter une évolution « de bonne volonté » sans formalisation crée un service sans base contractuelle ; la refuser sèchement abîme la relation : l'avenant est le chemin professionnel entre les deux.

> 💡 **Astuce**
> Tenez un journal de la vie du contrat : demandes de l'AO, engagements pris en réunion, incidents notables, courriers échangés. À la revue de contrat comme au renouvellement, ce journal vaut de l'or : il objective ce qui a été fait et évite les mémoires sélectives.

## La reconduction se gagne toute l'année

Au moment du renouvellement, l'AO ne relit pas votre mémoire technique : elle se souvient de ce qu'elle a vécu. Des indicateurs sincères, des réclamations traitées, des véhicules propres, des crises gérées avec sérieux, des revues de contrat préparées : c'est cette accumulation, semaine après semaine, qui fait la différence face à un concurrent au dossier séduisant mais sans historique. La reconduction n'est pas un sprint final : c'est la note d'une année entière.

## ✅ Synthèse

- Qualité = engagements de service mesurés : enquêtes mystère, satisfaction, contrôles internes.
- Réclamation : accusé de réception, enquête, réponse, correctif : dans les délais, avec traçabilité.
- Propreté et confort : fil conducteur du renouvellement ; reporting sincère, jamais maquillé.
- Revues de contrat préparées, évolutions par avenant : la reconduction se gagne toute l'année.$mft$,
    $mft$Les référentiels d'engagements de service, enquêtes mystère et satisfaction, le traitement des réclamations en quatre étapes, la propreté, le reporting sincère à l'AO, les revues de contrat et les avenants.$mft$,
    4, 40) RETURNING id INTO v_l4;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : Sécurité des voyageurs et qualité de service',
    'Vérifiez le module 5 : transport d''enfants, accessibilité PMR, gestion de crise et qualité de service.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Vous accueillez un conducteur nouvellement affecté à un circuit scolaire. Sur quel moment du service insistez-vous en priorité lors de son briefing ?$mft$,
    $mft$[
      {"id":"a","label":"La montée et la descente des enfants : c'est aux abords des arrêts que se concentrent les accidents mortels","is_correct":true},
      {"id":"b","label":"Le roulage sur route départementale, statistiquement le plus dangereux","is_correct":false},
      {"id":"c","label":"Les manœuvres au dépôt, en début et fin de service","is_correct":false},
      {"id":"d","label":"Le remplissage des documents de bord en fin de journée","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ertv','module-5','qcm-v1'], 'ERTV-M5-QCM-01', false,
    $mft$Le drame type du transport scolaire n'est pas une sortie de route : c'est l'enfant qui traverse devant ou derrière le car à l'arrêt. Roulage et manœuvres comptent, mais ne concentrent pas les accidents mortels d'enfants.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un voyageur en fauteuil roulant attend à l'arrêt. La rampe du véhicule refuse de se déployer. Quelle consigne le conducteur doit-il appliquer ?$mft$,
    $mft$[
      {"id":"a","label":"Appliquer la procédure : informer le voyageur, alerter l'exploitation et déclencher une solution de remplacement, jamais de refus sec","is_correct":true},
      {"id":"b","label":"S'excuser et repartir : la panne le dispense de la prise en charge","is_correct":false},
      {"id":"c","label":"Demander aux autres voyageurs de porter le fauteuil dans le véhicule","is_correct":false},
      {"id":"d","label":"Faire patienter le voyageur sans engagement jusqu'à la réparation de la rampe","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ertv','module-5','qcm-v1'], 'ERTV-M5-QCM-02', false,
    $mft$Le refus sec est proscrit : la procédure prévoit l'alerte de l'exploitation et une solution (course garantie, véhicule de remplacement, TPMR). Le portage improvisé est dangereux pour la personne comme pour les porteurs.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Un conducteur vous appelle : son autocar vient de percuter une glissière, des passagers sont choqués. En tant qu'exploitant, quelle est votre toute première vérification ?$mft$,
    $mft$[
      {"id":"a","label":"Que les secours ont bien été alertés, avant de dérouler le plan d'urgence (direction, autorité organisatrice)","is_correct":true},
      {"id":"b","label":"Que l'assureur a été prévenu pour ouvrir le dossier","is_correct":false},
      {"id":"c","label":"Que le conducteur a photographié les dégâts pour le constat","is_correct":false},
      {"id":"d","label":"Qu'un communiqué de presse est en préparation","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ertv','module-5','qcm-v1'], 'ERTV-M5-QCM-03', false,
    $mft$L'alerte des secours prime sur tout ; le plan d'urgence s'enchaîne ensuite (direction, AO, familles). Assureur, constat et communication viennent après la mise en sécurité des personnes.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Un parent adresse une réclamation écrite : le car serait passé en avance et son enfant est resté à l'arrêt. Quel est le premier geste du traitement ?$mft$,
    $mft$[
      {"id":"a","label":"Envoyer un accusé de réception, puis ouvrir l'enquête interne dans les délais définis","is_correct":true},
      {"id":"b","label":"Répondre immédiatement que le conducteur conteste les faits","is_correct":false},
      {"id":"c","label":"Classer la réclamation en attendant d'autres signalements sur la même course","is_correct":false},
      {"id":"d","label":"Transmettre la réclamation au conducteur pour qu'il réponde lui-même au parent","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ertv','module-5','qcm-v1'], 'ERTV-M5-QCM-04', false,
    $mft$La chaîne est : accusé de réception, enquête, réponse, correctif, chacun dans un délai défini. Répondre avant d'enquêter ou laisser le conducteur gérer en direct décrédibilise le traitement.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Un collège affrète un de vos autocars pour une sortie. Pourquoi exigez-vous la liste nominative des participants et le nombre d'accompagnateurs avant le départ ?$mft$,
    $mft$[
      {"id":"a","label":"Pour vérifier l'encadrement prévu selon les cas et disposer d'un recensement fiable des personnes à bord en cas d'incident","is_correct":true},
      {"id":"b","label":"Pour facturer la sortie au nombre exact d'élèves transportés","is_correct":false},
      {"id":"c","label":"Parce que la liste remplace le contrôle des titres de transport","is_correct":false},
      {"id":"d","label":"Pour que le conducteur fasse l'appel à chaque montée","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-5','qcm-v1'], 'ERTV-M5-QCM-05', false,
    $mft$La liste sert à deux choses : dimensionner l'encadrement selon les cas, et savoir précisément qui est à bord si un accident survient. La facturation n'en dépend pas, et l'appel n'incombe pas au conducteur.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Sur une ligne scolaire, les élèves ne bouclent pas leur ceinture malgré la signalétique. Quelle réponse d'exploitation est la plus adaptée ?$mft$,
    $mft$[
      {"id":"a","label":"Renforcer l'information (annonces, consignes en début de trajet, actions avec les établissements) et rappeler que le port est obligatoire dans l'autocar","is_correct":true},
      {"id":"b","label":"Interdire le transport aux élèves non attachés, en les laissant à l'arrêt","is_correct":false},
      {"id":"c","label":"Demander au conducteur d'attacher lui-même chaque enfant avant de partir","is_correct":false},
      {"id":"d","label":"Ignorer le sujet : la ceinture ne relève pas du transporteur","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-5','qcm-v1'], 'ERTV-M5-QCM-06', false,
    $mft$Le levier de l'exploitant est l'information et le contrôle : annonces, signalétique, sensibilisation avec les établissements. Laisser des enfants à l'arrêt crée un danger pire, et le conducteur ne peut pas attacher chaque passager à chaque arrêt.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Vous bâtissez le module de formation « accueil des personnes handicapées » pour vos conducteurs. Quel trio de compétences doit en constituer le cœur ?$mft$,
    $mft$[
      {"id":"a","label":"L'arrimage du fauteuil, la gestion des priorités d'accès et l'attitude d'accueil (s'adresser à la personne, proposer sans imposer)","is_correct":true},
      {"id":"b","label":"La mécanique des rampes, la facturation des courses TPMR et la vidéoprotection","is_correct":false},
      {"id":"c","label":"Le diagnostic médical du handicap pour adapter le service à chaque voyageur","is_correct":false},
      {"id":"d","label":"La rédaction des schémas directeurs d'accessibilité du réseau","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-5','qcm-v1'], 'ERTV-M5-QCM-07', false,
    $mft$En exploitation, le conducteur doit savoir arrimer un fauteuil, gérer les priorités et adopter la bonne attitude. Le diagnostic médical ne le regarde pas, et le schéma directeur relève du réseau et de l'AO, pas du poste de conduite.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Deux heures après un accident, un journaliste appelle le poste de régulation et demande le nom du conducteur et son ancienneté. Que fait le régulateur qui décroche ?$mft$,
    $mft$[
      {"id":"a","label":"Il renvoie vers la direction, seule habilitée à s'exprimer, sans confirmer aucune information","is_correct":true},
      {"id":"b","label":"Il donne les informations demandées : elles sont factuelles et non confidentielles","is_correct":false},
      {"id":"c","label":"Il livre son analyse des causes probables pour couper court aux rumeurs","is_correct":false},
      {"id":"d","label":"Il nie qu'un accident ait eu lieu pour protéger l'entreprise","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-5','qcm-v1'], 'ERTV-M5-QCM-08', false,
    $mft$En crise, une seule voix parle : la direction, avec des messages factuels. Confirmer des détails, spéculer sur les causes ou mentir alimente la crise et peut gêner les enquêtes en cours.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Votre ponctualité mensuelle chute sous le seuil contractuel à cause d'un chantier. Que présentez-vous à l'autorité organisatrice dans le reporting ?$mft$,
    $mft$[
      {"id":"a","label":"L'indicateur réel, l'explication du chantier et le plan d'action engagé : un tableau de bord sincère","is_correct":true},
      {"id":"b","label":"Un indicateur recalculé en excluant discrètement les courses touchées par le chantier","is_correct":false},
      {"id":"c","label":"Rien : le sujet attendra la revue de contrat annuelle","is_correct":false},
      {"id":"d","label":"Une moyenne lissée sur douze mois pour masquer le mois dégradé","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-5','qcm-v1'], 'ERTV-M5-QCM-09', false,
    $mft$La confiance vaut mieux que le maquillage : une AO qui découvre un chiffre arrangé ne croit plus aucun reporting. L'indicateur sincère accompagné d'un plan d'action protège la relation contractuelle.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Un conducteur se plaint : l'éthylotest antidémarrage (EAD) de son autocar « fait perdre du temps » et il demande s'il peut être débranché sur les services courts. Votre réponse d'exploitant ?$mft$,
    $mft$[
      {"id":"a","label":"Refus : l'EAD est un équipement de sécurité obligatoire sur les autocars, il se maintient en état de marche et ne se neutralise jamais","is_correct":true},
      {"id":"b","label":"Accord ponctuel si le conducteur s'engage par écrit à ne pas boire","is_correct":false},
      {"id":"c","label":"Accord sur les circuits scolaires uniquement, où le temps est compté","is_correct":false},
      {"id":"d","label":"Renvoi de la décision au conducteur : le dispositif équipe son véhicule","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ertv','module-5','qcm-v1'], 'ERTV-M5-QCM-10', false,
    $mft$L'EAD empêche le démarrage en cas d'alcoolémie détectée : le neutraliser revient à supprimer une barrière de sécurité obligatoire, à plus forte raison sur un service scolaire. Aucun engagement écrit ne remplace le dispositif.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Après l'évacuation d'un autocar accidenté, le comptage en zone de regroupement donne 42 personnes pour 45 inscrites sur la liste des passagers. Que faites-vous de cet écart ?$mft$,
    $mft$[
      {"id":"a","label":"Le transmettre immédiatement aux secours : trois personnes sont potentiellement encore dans le véhicule ou aux alentours","is_correct":true},
      {"id":"b","label":"Le corriger : la liste comporte sûrement des noms en double","is_correct":false},
      {"id":"c","label":"Attendre la fin des opérations pour refaire un comptage plus calme","is_correct":false},
      {"id":"d","label":"Le noter dans le rapport interne du lendemain","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ertv','module-5','qcm-v1'], 'ERTV-M5-QCM-11', false,
    $mft$C'est exactement pour cet instant que la liste doit être fiable : l'écart oriente les secours vers des personnes potentiellement manquantes. Supposer une erreur de liste ou différer l'information peut coûter des vies.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$En cours de contrat, l'autorité organisatrice vous demande de prolonger une ligne vers un nouveau quartier. Comment traitez-vous cette évolution d'offre ?$mft$,
    $mft$[
      {"id":"a","label":"Par un avenant formalisé : chiffrage des moyens supplémentaires (véhicules, heures, kilomètres), validation, puis mise en œuvre","is_correct":true},
      {"id":"b","label":"En l'exécutant immédiatement sans formalisation : refuser fragiliserait la reconduction","is_correct":false},
      {"id":"c","label":"En la refusant : le contrat initial fait foi jusqu'à son terme","is_correct":false},
      {"id":"d","label":"En l'appliquant seulement si les voyageurs la réclament","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ertv','module-5','qcm-v1'], 'ERTV-M5-QCM-12', false,
    $mft$Une évolution d'offre se gère par avenant : chiffrée, validée, traçable. L'exécuter sans formalisation crée un service sans base contractuelle ; la refuser sèchement abîme la relation qui conditionne la reconduction.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$À quel moment d'un circuit scolaire se concentrent les accidents mortels, et où se produisent-ils précisément ?$mft$,
   $mft$À la montée et surtout à la descente : aux abords immédiats de l'arrêt, quand l'enfant traverse devant ou derrière le véhicule.$mft$,
   2, 'facile', ARRAY['ertv','module-5','question-courte'], 'ERTV-M5-QC-01', false,
   $mft$Le moment critique : l'arrêt, pas le roulage.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Après un accident d'autocar, qui est la seule voix autorisée à s'exprimer auprès des familles et des médias, et sur quel type de messages ?$mft$,
   $mft$La direction uniquement, avec des messages factuels : jamais de spéculation sur les causes, pas de bilan non confirmé, pas de noms.$mft$,
   2, 'facile', ARRAY['ertv','module-5','question-courte'], 'ERTV-M5-QC-02', false,
   $mft$Une seule voix, des faits.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Citez, dans l'ordre, les quatre étapes du traitement d'une réclamation voyageur.$mft$,
   $mft$Accusé de réception, enquête interne, réponse au réclamant, mesure corrective : chaque étape dans un délai défini.$mft$,
   2, 'facile', ARRAY['ertv','module-5','question-courte'], 'ERTV-M5-QC-03', false,
   $mft$Les quatre étapes ordonnées, avec la notion de délais.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Quel double rôle joue la signalisation « transport d'enfants » apposée à l'avant et à l'arrière d'un car scolaire ?$mft$,
   $mft$Elle avertit les autres usagers de la présence d'enfants à bord, et elle les incite à redoubler de prudence aux abords des arrêts, là où les enfants montent, descendent et traversent.$mft$,
   2, 'moyen', ARRAY['ertv','module-5','question-courte'], 'ERTV-M5-QC-04', false,
   $mft$Avertir et faire ralentir autour des arrêts.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Un conducteur a refusé sèchement un voyageur en fauteuil au motif d'une rampe en panne, sans prévenir personne. Citez deux fautes commises et un risque pour l'entreprise.$mft$,
   $mft$Fautes : refus sec au lieu de la procédure (information du voyageur, solution de remplacement) et absence d'alerte de l'exploitation (panne non signalée, donc non réparée). Risque : manquement aux engagements contractuels vis-à-vis de l'AO et dégât réputationnel.$mft$,
   2, 'moyen', ARRAY['ertv','module-5','question-courte'], 'ERTV-M5-QC-05', false,
   $mft$Deux fautes procédurales + un risque contractuel ou réputationnel.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Citez trois équipements d'accessibilité attendus sur un véhicule de transport de voyageurs.$mft$,
   $mft$Par exemple : rampe ou palette d'accès, emplacement UFR (utilisateur de fauteuil roulant) avec arrimage, annonces sonores et annonces visuelles des arrêts.$mft$,
   2, 'moyen', ARRAY['ertv','module-5','question-courte'], 'ERTV-M5-QC-06', false,
   $mft$Trois équipements matériels distincts.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Citez trois équipements réglementaires de bord mobilisables pour évacuer un autocar.$mft$,
   $mft$Par exemple : issues de secours signalées, marteaux brise-vitre, coupe-ceintures, extincteurs.$mft$,
   2, 'moyen', ARRAY['ertv','module-5','question-courte'], 'ERTV-M5-QC-07', false,
   $mft$Trois équipements d'évacuation distincts.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Pourquoi un tableau de bord « arrangé » remis à l'autorité organisatrice est-il une faute d'exploitation, même quand les chiffres réels sont mauvais ?$mft$,
   $mft$Parce que la relation avec l'AO repose sur la confiance : un maquillage découvert décrédibilise tout le reporting, passé et futur, et compromet la reconduction ; un chiffre sincère accompagné d'un plan d'action entretient au contraire la confiance.$mft$,
   2, 'moyen', ARRAY['ertv','module-5','question-courte'], 'ERTV-M5-QC-08', false,
   $mft$La confiance vaut mieux que le maquillage.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Pourquoi la liste des passagers doit-elle être fiable AVANT le départ, et non reconstituée après un accident ?$mft$,
   $mft$Parce que le recensement après évacuation se fait par comparaison entre les personnes comptées et la liste : si elle est fausse ou incomplète, on ne sait pas qui manque, et les secours ne peuvent pas orienter leurs recherches.$mft$,
   2, 'difficile', ARRAY['ertv','module-5','question-courte'], 'ERTV-M5-QC-09', false,
   $mft$La liste est la référence du recensement.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$« La reconduction d'un contrat se gagne toute l'année, pas au moment du renouvellement. » Justifiez en citant deux mécanismes concrets.$mft$,
   $mft$La qualité est mesurée en continu (indicateurs, enquêtes mystère et de satisfaction, propreté) et la relation vit toute l'année (reporting sincère, revues de contrat, traitement des réclamations) : au renouvellement, l'AO juge sur cet historique vécu, pas sur un dossier de dernière minute.$mft$,
   2, 'difficile', ARRAY['ertv','module-5','question-courte'], 'ERTV-M5-QC-10', false,
   $mft$Deux mécanismes : mesure continue + relation continue.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Votre entreprise remporte un circuit scolaire. Rédigez la note de consignes spécifiques destinée aux conducteurs affectés : signalisation, arrêts, montée/descente, ceintures, comportement et incidents.$mft$,
   $mft$Réponse modèle. Signalisation : vérifier avant chaque départ le pictogramme transport d'enfants à l'avant et à l'arrière et le bon état des feux de signalisation utilisés à l'arrêt (modalités rappelées selon la réglementation en vigueur). Arrêts : desservir uniquement les points d'arrêt définis avec l'autorité organisatrice, jamais d'arrêt improvisé ; approche à vitesse réduite, abords surveillés. Montée/descente : c'est LE moment critique ; portes surveillées, aucun départ tant que les abords ne sont pas contrôlés dans les rétroviseurs (un enfant peut traverser devant ou derrière le car) ; jamais de passage en avance sur l'horaire : un car en avance laisse un enfant seul à l'arrêt ou le pousse à courir. Ceintures : annoncer en début de trajet que le port est obligatoire dans l'autocar, s'appuyer sur la signalétique et les accompagnateurs, signaler les refus répétés. Comportement : ton calme et ferme avec les enfants, jamais de conflit en conduisant (on s'arrête si la sécurité l'exige), aucun échange conflictuel avec les parents : renvoi vers l'exploitation. Incidents : tout événement (enfant non récupéré à la descente, malaise, chahut dangereux) est signalé immédiatement à l'exploitation. EAD : ne jamais chercher à contourner l'éthylotest antidémarrage, signaler tout dysfonctionnement.$mft$,
   $mft$Barème /5 : signalisation et vérifications avant départ (1 pt) ; sécurisation de la montée/descente avec contrôle des abords et interdiction de l'avance (1,5 pt) ; ceintures : information et relais accompagnateurs (1 pt) ; comportement et renvoi des conflits vers l'exploitation (0,75 pt) ; signalement des incidents et respect de l'EAD (0,75 pt). Erreurs fréquentes : oublier l'interdiction de passer en avance ; réduire la sécurité au seul roulage.$mft$,
   5, 'facile', ARRAY['ertv','module-5','question-redigee'], 'ERTV-M5-QR-01', false,
   $mft$La note de consignes scolaires complète, du pictogramme à l'incident.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Un parent réclame : le car serait passé cinq minutes en avance et son enfant de 11 ans est resté seul à l'arrêt par temps froid. Déroulez le traitement complet de cette réclamation, de la réception au correctif, en précisant l'esprit de chaque étape.$mft$,
   $mft$Réponse modèle. Étape 1, accusé de réception rapide : le parent sait qu'il est entendu et connaît le délai de réponse annoncé ; sujet sensible (enfant seul), donc traitement prioritaire. Étape 2, enquête factuelle : données d'exploitation disponibles sur la course (horaires constatés) et témoignage du conducteur, recueillis sans a priori : il s'agit d'établir les faits, pas de désigner un coupable avant d'avoir vérifié. Étape 3, réponse au parent : factuelle et honnête ; si l'avance est avérée, on la reconnaît, on présente les mesures prises et on s'excuse du préjudice ; si les faits ne sont pas établis, on l'explique sans arrogance. Étape 4, correctif : rappel formel de la consigne (jamais d'avance sur circuit scolaire : l'avance est une faute de service), sensibilisation du conducteur concerné, surveillance de la course les semaines suivantes pour vérifier l'effet. Transversal : chaque étape respecte un délai défini, le dossier est tracé dans le suivi qualité, la réclamation alimente l'analyse par motif et par ligne, et l'AO est informée si le contrat le prévoit. Une réclamation bien traitée peut refidéliser : elle prouve que le réseau écoute.$mft$,
   $mft$Barème /5 : accusé de réception rapide avec délai annoncé et priorisation du cas sensible (1 pt) ; enquête factuelle sur données et témoignage (1,25 pt) ; réponse sincère, sans langue de bois ni accusation (1,25 pt) ; correctif concret et suivi de la course (1 pt) ; traçabilité qualité et information de l'AO le cas échéant (0,5 pt). Erreurs fréquentes : répondre avant d'avoir enquêté ; nier par principe ; oublier le suivi après correctif.$mft$,
   5, 'facile', ARRAY['ertv','module-5','question-redigee'], 'ERTV-M5-QR-02', false,
   $mft$Le traitement d'une réclamation sensible, étape par étape.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Le maire d'une commune desservie vous signale des traversées dangereuses d'enfants à la descente du car, sur un arrêt en bord de départementale. Construisez votre démarche complète, en lien avec l'autorité organisatrice.$mft$,
   $mft$Réponse modèle. Premier temps : le diagnostic sur site, aux heures réelles de desserte, pas sur plan : observation des comportements (où les enfants traversent, devant ou derrière le car), de la visibilité, des cheminements piétons existants, de la vitesse des véhicules qui croisent ; constats objectivés (photos, notes datées). Deuxième temps : la saisine de l'autorité organisatrice, car l'aménagement de l'arrêt relève d'elle et du gestionnaire de voirie : dossier factuel transmis, étude conjointe d'un arrêt sécurisé (implantation, visibilité, cheminement, traversée aménagée), l'exploitant apportant sa connaissance du terrain sans promettre lui-même des travaux qui ne dépendent pas de lui. Troisième temps : les mesures immédiates, sans attendre l'aménagement : consignes renforcées aux conducteurs sur cet arrêt (contrôle prolongé des abords avant départ, signalement de chaque presque-accident) et, si le danger est trop grave, proposition motivée de déplacement provisoire du point d'arrêt. Quatrième temps : la sensibilisation des enfants, en lien avec l'établissement : ne jamais traverser devant ou derrière le car, attendre son départ. Dernier temps : la boucle de suivi : retour écrit au maire et à l'AO, vérification sur site après aménagement.$mft$,
   $mft$Barème /5 : diagnostic sur site objectivé aux heures réelles (1,25 pt) ; saisine de l'AO avec dossier factuel, sans promesse hors périmètre (1,25 pt) ; mesures conservatoires immédiates côté conducteurs (1 pt) ; sensibilisation des enfants avec l'établissement (1 pt) ; boucle de suivi avec le maire et l'AO (0,5 pt). Erreurs fréquentes : promettre un aménagement qui relève de l'AO ou de la voirie ; ne traiter que l'infrastructure en oubliant le comportement des enfants.$mft$,
   5, 'moyen', ARRAY['ertv','module-5','question-redigee'], 'ERTV-M5-QR-03', false,
   $mft$L'arrêt dangereux : diagnostic, AO, mesures immédiates, sensibilisation.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Vous reprenez l'exploitation d'un réseau dont l'accessibilité est jugée défaillante par l'AO. Construisez votre plan de mise à niveau (matériel, formation, procédures, TPMR) et expliquez pourquoi l'enjeu dépasse la conformité contractuelle.$mft$,
   $mft$Réponse modèle. État des lieux d'abord : sur chaque véhicule, fonctionnement réel des rampes et palettes, état des emplacements UFR, annonces sonores et visuelles opérationnelles ; sur le réseau, arrêts impraticables recensés et remontés à l'AO au titre du schéma directeur d'accessibilité. Volet matériel : maintenance préventive des rampes, test de déploiement au départ du dépôt, priorité de réparation sur les pannes d'accessibilité (un équipement en panne équivaut à un équipement absent). Volet formation : tous les conducteurs formés à l'accueil des personnes handicapées : gestes techniques (arrimage du fauteuil), priorités d'accès, attitude (s'adresser à la personne, proposer sans imposer) ; vérification des acquis, pas seulement des présences. Volet procédures : panne de rampe cadrée : jamais de refus sec, information du voyageur, alerte de l'exploitation, solution de remplacement (course garantie, autre véhicule, TPMR), traçabilité jusqu'à réparation. Volet TPMR : conventions et véhicules adaptés articulés avec le réseau régulier. Pilotage : tableau de bord accessibilité (disponibilité des rampes, délais de réparation, réclamations, conducteurs formés) partagé avec l'AO. L'enjeu dépasse le contrat : un refus de prise en charge filmé touche à la dignité des personnes et fait plus de dégâts d'image qu'une année de retards.$mft$,
   $mft$Barème /5 : état des lieux matériel et réseau, lien avec le schéma directeur (1 pt) ; maintenance et test des équipements (1 pt) ; formation des conducteurs sur les trois piliers avec vérification des acquis (1 pt) ; procédure panne de rampe sans refus sec, avec solutions et traçabilité (1,25 pt) ; TPMR et argumentation contractuelle ET réputationnelle (0,75 pt). Erreurs fréquentes : plan tout matériel qui oublie la formation et l'attitude ; absence de solution de remplacement en cas de panne.$mft$,
   5, 'moyen', ARRAY['ertv','module-5','question-redigee'], 'ERTV-M5-QR-04', false,
   $mft$Le plan de mise à niveau accessibilité, du dépôt à la revue de contrat.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Rédigez la trame du plan d'urgence « accident d'autocar » de votre entreprise : pour chaque volet (alerte, actions sur place, recensement, familles et médias, soutien, enquêtes, retour d'expérience), précisez qui fait quoi.$mft$,
   $mft$Réponse modèle. Alerte : le conducteur alerte les secours d'abord, puis l'exploitation ; la régulation prévient immédiatement la direction et informe l'autorité organisatrice ; la liste des numéros est tenue à jour et testée. Sur place : le conducteur met les passagers en sécurité ; évacuation ORDONNÉE seulement si le véhicule ou l'environnement expose (feu, position dangereuse, sur-accident possible), en s'appuyant sur les équipements réglementaires de bord : issues de secours, marteaux brise-vitre, coupe-ceintures, extincteurs ; regroupement en zone sûre à l'écart de la circulation ; l'entreprise envoie un encadrant et un véhicule de substitution. Recensement : comptage des personnes en zone de regroupement, comparaison avec la liste des passagers produite par l'exploitation ; tout écart est transmis immédiatement aux secours. Familles et médias : la direction, et elle seule, s'exprime, en messages factuels, sans spéculation sur les causes ; un numéro d'accueil des familles est ouvert, les familles sont informées avant les médias. Soutien : dispositif psychologique activé pour passagers, familles, conducteur et équipes. Enquêtes : coopération avec les forces de l'ordre (judiciaire) et le BEA-TT (technique), éléments préservés, interlocuteurs désignés. Retour d'expérience : analyse à froid, corrections du plan, des consignes et de la formation, puis exercice de validation.$mft$,
   $mft$Barème /5 : chaîne d'alerte complète et ordonnée, secours d'abord (1 pt) ; actions sur place avec évacuation ordonnée conditionnée et équipements de bord (1 pt) ; recensement par comparaison avec la liste et transmission des écarts (1 pt) ; communication à voix unique et accueil des familles (1 pt) ; soutien, enquêtes BEA-TT/forces de l'ordre et REX (1 pt). Erreurs fréquentes : évacuation présentée comme systématique ; oublier l'information de l'AO ; laisser la communication à n'importe qui.$mft$,
   5, 'moyen', ARRAY['ertv','module-5','question-redigee'], 'ERTV-M5-QR-05', false,
   $mft$Le plan d'urgence complet, volet par volet, avec les rôles.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$En revue de contrat, l'AO pointe une dégradation de la propreté des véhicules et des retards récurrents sur deux lignes. Construisez votre réponse d'exploitant : posture, analyse, plan d'action, suivi.$mft$,
   $mft$Réponse modèle. Posture : reconnaître les faits mesurés sans les contester par principe (contester l'outil de mesure sans erreur démontrée détruit la crédibilité) : la sincérité est la condition de la suite de l'échange. Analyse des causes, distincte pour chaque sujet : propreté : fréquence réelle de nettoyage face au plan prévu, contrôles internes réalisés ou non, dégradations et vandalisme traités trop lentement ; retards : temps de parcours qui ont dérivé (chantiers, trafic), horaires devenus intenables, incidents d'exploitation répétés sur ces deux lignes. Plan d'action chiffré et daté : renforcement du plan de nettoyage avec contrôles internes type enquête mystère, traitement accéléré des dégradations ; côté retards, relevés de temps de parcours aux heures réelles, retouche des horaires si la dérive est structurelle, et proposition d'avenant si des moyens supplémentaires sont nécessaires. Suivi : indicateurs mensuels transmis à l'AO avec commentaires (causes, actions, échéances), point d'étape intermédiaire avant la prochaine revue, alertes données avant que l'AO ne découvre un nouveau problème ailleurs. Esprit d'ensemble : la revue de contrat se prépare, ne se subit pas, et la reconduction se gagne toute l'année par cette constance.$mft$,
   $mft$Barème /5 : posture sincère, faits reconnus (1 pt) ; analyse des causes distincte propreté/retards (1,25 pt) ; plan d'action chiffré et daté, avec avenant éventuel pour les moyens (1,5 pt) ; dispositif de suivi et d'alerte vers l'AO (0,75 pt) ; mise en perspective : la reconduction se gagne toute l'année (0,5 pt). Erreurs fréquentes : contester les mesures en bloc ; promettre sans échéances ni moyens ; traiter les deux sujets par une réponse unique et vague.$mft$,
   5, 'moyen', ARRAY['ertv','module-5','question-redigee'], 'ERTV-M5-QR-06', false,
   $mft$Répondre à une AO mécontente : sincérité, causes, plan, suivi.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Concevez l'exercice annuel de simulation d'accident de votre entreprise : scénario, participants, déroulé, points de contrôle et exploitation du débriefing. Justifiez la phrase : « une crise se répète AVANT qu'elle arrive ».$mft$,
   $mft$Réponse modèle. Scénario : réaliste et daté, par exemple un autocar scolaire accidenté avec passagers à recenser, détail non annoncé aux participants pour tester les vrais réflexes. Participants : régulation, encadrement, direction, conducteurs, et si possible l'autorité organisatrice et les services de secours associés à l'exercice. Déroulé : déclenchement de l'alerte par un appel simulé du conducteur, remontée de l'information dans la chaîne (régulation, direction, AO), activation du plan d'urgence, production de la liste des passagers par l'exploitation, appels simulés de familles et de « journalistes » pour tester la discipline de communication. Points de contrôle : délai entre l'appel et l'alerte complète, capacité à produire une liste de passagers fiable et rapidement, respect de la voix unique (personne d'autre que la direction ne répond aux médias), exactitude des numéros du plan, tenue d'une main courante des décisions. Débriefing : à chaud (ressenti, blocages) puis à froid (analyse des écarts), aboutissant à des corrections concrètes : mise à jour du plan et des numéros, consignes reformulées, formations complémentaires. Justification : sous stress, on ne fait que ce que l'on a répété ; l'exercice transforme un document en réflexes et révèle les failles (numéro obsolète, liste introuvable) au moment où elles ne coûtent rien.$mft$,
   $mft$Barème /5 : scénario réaliste non annoncé et participants pertinents (1 pt) ; déroulé complet incluant les appels simulés familles/médias (1,25 pt) ; points de contrôle mesurables, dont la liste et la voix unique (1,25 pt) ; débriefing double et corrections concrètes (1 pt) ; justification du principe de répétition (0,5 pt). Erreurs fréquentes : exercice annoncé dans le détail qui ne teste rien ; débriefing sans mise à jour du plan.$mft$,
   5, 'difficile', ARRAY['ertv','module-5','question-redigee'], 'ERTV-M5-QR-07', false,
   $mft$L'exercice de crise : concevoir, contrôler, corriger.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Une association saisit l'AO : un même voyageur en fauteuil s'est vu refuser l'accès deux fois en un mois (rampe en panne non signalée, puis conducteur visiblement non formé à l'arrimage). Analysez les défaillances en chaîne et construisez le plan correctif complet.$mft$,
   $mft$Réponse modèle. Défaillances en chaîne : 1) maintenance : la panne de rampe n'a pas été signalée, donc pas réparée : défaut de procédure de signalement et de culture du « tout se remonte » ; 2) formation : un conducteur incapable d'arrimer un fauteuil révèle un plan de formation lacunaire ou non suivi d'effet (présence sans vérification des acquis) ; 3) procédure : dans les deux cas, refus au lieu d'une solution de remplacement : la consigne « jamais de refus sec » n'est pas connue ou pas appliquée ; 4) management : deux incidents en un mois sur le même voyageur sans réaction de l'encadrement : aucun capteur (réclamations, signalements) n'a alerté. Plan correctif : réponse au voyageur et à l'association (faits reconnus, excuses, engagements datés) ; vérification du parc avec test des rampes au départ du dépôt ; remise à niveau de la formation accueil handicap avec vérification pratique des acquis ; procédure de panne réaffirmée et affichée (information, alerte exploitation, solution de remplacement, traçabilité) ; suivi des réclamations accessibilité en indicateur d'alerte ; reporting transparent à l'AO avec échéances. L'enjeu est contractuel ET réputationnel : la confiance se reconstruit par des actes tracés, pas par des courriers.$mft$,
   $mft$Barème /5 : les quatre défaillances identifiées avec leur mécanisme (2 pts) ; réponse au voyageur et à l'association (0,75 pt) ; plan correctif complet : parc, formation vérifiée, procédure, capteurs (1,5 pt) ; reporting à l'AO avec échéances et lecture contractuelle/réputationnelle (0,75 pt). Erreurs fréquentes : tout imputer au conducteur sans remonter aux causes d'organisation ; plan correctif sans vérification des acquis ni suivi.$mft$,
   5, 'difficile', ARRAY['ertv','module-5','question-redigee'], 'ERTV-M5-QR-08', false,
   $mft$Deux refus PMR : l'analyse organisationnelle et le redressement.$mft$);

  RAISE NOTICE 'Module 5 ERTV créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $ertvm5$;
