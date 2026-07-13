-- =====================================================================
-- ERTV (Exploitant en transport routier de voyageurs)
-- MODULE 1 : LE CADRE DU TRANSPORT ROUTIER DE VOYAGEURS
-- v1 (juillet 2026)
-- Angle exploitant : accès à la profession voyageurs, typologie des
-- services, autorités organisatrices, documents de bord et contrôles.
-- STATUT : active = false (« à valider »). Idempotent.
-- =====================================================================

DO $ertvm1$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_l4 uuid;
  v_quiz uuid; v_q uuid; v_ord int := 0;
BEGIN
  INSERT INTO public.blocs (id, code, title, description, "order")
  VALUES (70, 'ERTV', 'Exploitant en transport routier de voyageurs',
    'Concevoir, exploiter et réguler des services de transport routier de voyageurs : cadre réglementaire, graphicage, exploitation, social, sécurité et qualité.', 70)
  ON CONFLICT DO NOTHING;

  SELECT id INTO v_formation FROM public.formations WHERE slug = 'ertv';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation ertv introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'ERTV';

  DELETE FROM public.question_bank WHERE source_ref LIKE 'ERTV-M1-%';
  DELETE FROM public.modules WHERE slug = 'ertv-cadre-voyageurs';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 1 : Le cadre du transport routier de voyageurs',
    'ertv-cadre-voyageurs', v_bloc,
    'Le transport public routier de personnes : accès à la profession, typologie des services (réguliers, scolaires, occasionnels, SLO), autorités organisatrices et documents de bord.',
    'debutant', 300, 10) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 10, true);

  -- ─── Leçon 1 : L'accès à la profession voyageurs ───────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'acces-profession-voyageurs',
    'L''accès à la profession de transporteur de voyageurs',
    $mft$> 🎯 **Objectifs**
> - Identifier les quatre exigences d'accès à la profession, dans leur version voyageurs.
> - Situer le rôle du gestionnaire de transport et de l'inscription au registre.
> - Distinguer licence intérieure et licence communautaire, et comprendre l'usage des copies conformes.

## Changer de siège : du volant au bureau d'exploitation

Beaucoup de futurs exploitants voyageurs viennent de la conduite. Le changement de perspective est radical : vous ne préparez plus VOTRE prise de service, vous préparez celle de toute une entreprise. Et avant même de faire rouler le premier autocar, l'entreprise doit exister juridiquement dans le transport public de personnes : c'est tout l'enjeu de l'accès à la profession. Les exigences sont les mêmes quatre piliers que côté marchandises, mais avec des contenus propres aux voyageurs : c'est cet angle voyageurs que vous devez maîtriser.

## Les quatre exigences, version voyageurs

| Exigence | Ce qu'elle signifie pour une entreprise de voyageurs |
| --- | --- |
| Établissement | Une implantation stable et effective en France, où l'entreprise conserve ses documents et dirige réellement son activité |
| Honorabilité | Le dirigeant et le gestionnaire de transport ne doivent pas avoir de condamnations incompatibles avec l'exercice de la profession |
| Capacité financière | Des capitaux et réserves suffisants, avec des montants PROPRES aux voyageurs, calculés selon la taille des véhicules exploités |
| Capacité professionnelle | Une attestation de capacité professionnelle en transport de VOYAGEURS, obtenue par examen ou par équivalence |

### La capacité financière : le barème voyageurs

Le barème dépend de la capacité des véhicules. Pour les véhicules n'excédant pas neuf places, conducteur compris, le montant exigé est de l'ordre de 1500 euros par véhicule. Au-delà de neuf places, le barème change d'échelle : un montant plus élevé pour le premier véhicule (de l'ordre de 9000 euros), puis un montant réduit (de l'ordre de 5000 euros) pour chacun des véhicules suivants.

> ⚠️ **Attention**
> Ces montants sont donnés à titre d'ordre de grandeur et sont à vérifier dans les textes en vigueur au moment du dossier : l'exploitant sérieux vérifie le barème applicable AVANT de dimensionner son parc, car un véhicule ajouté sans capitaux suffisants met l'entreprise en irrégularité.

### La capacité professionnelle : examen ou équivalences

L'attestation voyageurs s'obtient principalement par un examen national. Des équivalences existent : certains diplômes reconnus, ou une expérience confirmée de direction d'une entreprise de transport de personnes, peuvent en dispenser. Un point essentiel pour vous : l'attestation MARCHANDISES ne suffit pas pour diriger une activité voyageurs, chaque champ a sa propre attestation.

## Le gestionnaire de transport : la personne clé

L'entreprise doit désigner un gestionnaire de transport : la personne physique qui détient la capacité professionnelle voyageurs et qui dirige effectivement et en permanence l'activité de transport (entretien des véhicules, contrats, affectation des conducteurs, sécurité). L'honorabilité s'apprécie aussi sur sa tête. Si le gestionnaire quitte l'entreprise ou perd son honorabilité, l'entreprise doit régulariser rapidement, sous peine de perdre son droit d'exercer.

## Registre, licences et copies conformes

:::flow
1. Réunir les exigences | Établissement, honorabilité, capacité financière, capacité professionnelle
2. Déposer le dossier | Auprès de l'administration compétente de la région d'implantation
3. Inscription au registre | L'entreprise est inscrite au registre des transporteurs de personnes
4. Délivrance de la licence | Licence de transport intérieur ou licence communautaire selon l'activité
5. Copies conformes | Une copie conforme numérotée embarquée à bord de chaque véhicule
:::

Selon les véhicules exploités et les services visés, l'entreprise reçoit une licence de transport intérieur (activité nationale) ou une licence communautaire (qui ouvre notamment les services internationaux). L'original reste au siège : ce sont les copies conformes, numérotées, qui voyagent à bord des véhicules et sont présentées en contrôle.

> 📌 **À retenir**
> Une copie conforme par véhicule en circulation : c'est la règle de gestion quotidienne de l'exploitant. Un car qui roule sans copie conforme à bord, c'est l'entreprise entière qui est en défaut lors d'un contrôle, pas seulement le conducteur.

> 💡 **Astuce d'exploitant**
> Tenez un tableau de bord : nombre de véhicules, nombre de copies conformes valides, montant de capacité financière couvert. Ces trois chiffres doivent rester alignés en permanence, surtout au moment d'acheter ou de louer un véhicule supplémentaire.

## ✅ Synthèse

- Quatre exigences, version voyageurs : **établissement, honorabilité, capacité financière (barème propre aux voyageurs), capacité professionnelle voyageurs**.
- Le **gestionnaire de transport** porte la capacité professionnelle et dirige effectivement l'activité.
- Inscription au **registre**, puis **licence intérieure ou communautaire** : l'original au siège, une **copie conforme** à bord de chaque véhicule.$mft$,
    $mft$Les quatre exigences d'accès à la profession dans leur version voyageurs (dont le barème financier propre aux voyageurs, à vérifier), le rôle du gestionnaire de transport, le registre et les licences avec copies conformes.$mft$,
    1, 40) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : La typologie des services ───────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'typologie-des-services',
    'La typologie des services de voyageurs',
    $mft$> 🎯 **Objectifs**
> - Classer n'importe quelle demande de transport de personnes dans la bonne catégorie de service.
> - Connaître le cadre propre à chaque catégorie : conventionnement, billet collectif, régulation.
> - Comprendre la libéralisation des liaisons interurbaines (SLO) et le rôle de l'ART.

## Un même autocar, plusieurs métiers

Le même véhicule peut, dans la même semaine, assurer une ligne conventionnée le lundi, un circuit scolaire le mardi et une excursion le samedi. Pour l'exploitant, la catégorie du service décide de tout : qui est le client, quel contrat s'applique, quels documents embarquer, quel prix pratiquer. Se tromper de catégorie, c'est exploiter hors cadre.

## La carte des services

| Service | Définition | Cadre |
| --- | --- | --- |
| Régulier | Ligne ouverte au public, horaires et itinéraire fixes | Conventionné avec une autorité organisatrice |
| Régulier spécialisé (SRS) | Circuits dédiés à une catégorie d'usagers, au premier rang desquels les scolaires | Marchés passés par les régions |
| Occasionnel | Groupe constitué, à la demande d'un donneur d'ordre : excursions, tourisme, transferts | Billet collectif obligatoire à bord |
| Librement organisé (SLO) | Liaison interurbaine commerciale ouverte à l'initiative du transporteur | Libéralisé depuis 2015, régulation ART sur les liaisons courtes |
| Transport à la demande (TAD) | Service déclenché à la réservation, sans horaire systématique | Généralement organisé pour le compte d'une autorité organisatrice |
| Cabotage voyageurs | Services intérieurs assurés en France par un transporteur non résident | Encadré par les règles européennes |

## Les services réguliers et les SRS

Le service régulier est une ligne ouverte à tous : n'importe quel voyageur peut monter, aux horaires et sur l'itinéraire publiés. Il est conventionné avec une autorité organisatrice, qui définit le service et le finance en partie. Le service régulier spécialisé (SRS) réserve des circuits à une catégorie d'usagers : le transport scolaire en est la figure principale, avec des circuits dédiés attribués par marchés des régions. Pour l'exploitant, le SRS est un métier de précision : circuits figés, points d'arrêt validés, ponctualité scrutée par les familles.

## Les services occasionnels : le billet collectif

Le service occasionnel transporte un groupe constitué (association, club, entreprise, scolaires en sortie) à la demande d'un donneur d'ordre : excursion, voyage touristique, transfert. Sa pièce maîtresse est le billet collectif, à bord du véhicule pendant tout le service.

> ⚠️ **Attention**
> Le format exact et les mentions détaillées du billet collectif sont à vérifier dans les textes en vigueur ; le principe, lui, est constant : un document établi AVANT le service, identifiant le donneur d'ordre, l'itinéraire et le groupe transporté.

## Les SLO : les liaisons libéralisées

:::timeline
2015 | Libéralisation des liaisons interurbaines par autocar : naissance des services librement organisés, dits « cars Macron »
Depuis 2015 | Les liaisons de plus de 100 km s'ouvrent librement, à l'initiative des transporteurs
Liaisons courtes | Les liaisons plus courtes passent par une régulation confiée à l'ART, qui peut les limiter ou les interdire si elles fragilisent un service conventionné
:::

Depuis 2015, un transporteur peut ouvrir de sa propre initiative une liaison interurbaine : c'est le service librement organisé. Au-delà de 100 km, la liaison est libre. En deçà, une régulation s'applique : l'ART (Autorité de régulation des transports) examine si la liaison porte atteinte à l'équilibre économique d'une ligne conventionnée, et peut la limiter ou l'interdire.

> 🔍 **Zoom**
> Les seuils et modalités précis de la régulation ART sur les liaisons courtes sont à vérifier avant tout projet de liaison SLO de moins de 100 km : c'est une étape d'instruction à intégrer au calendrier de lancement.

## TAD et cabotage : les cas particuliers

Le transport à la demande (TAD) ne roule que si des voyageurs ont réservé : il est généralement organisé pour le compte d'une autorité organisatrice dans les zones peu denses. Le cabotage voyageurs désigne les services intérieurs réalisés en France par un transporteur établi dans un autre État : il est encadré par les règles européennes, et l'exploitant qui sous-traite doit savoir à qui il confie ses services.

> 💡 **Astuce d'exploitant**
> Face à toute demande, posez trois questions : le service est-il ouvert à tous ou réservé à un groupe ? Existe-t-il une autorité organisatrice ou un donneur d'ordre privé ? La liaison est-elle librement commercialisable ? Les réponses donnent la catégorie, et la catégorie donne le cadre.

## ✅ Synthèse

- **Régulier** : ligne ouverte au public, conventionnée avec une autorité organisatrice ; **SRS** : circuits dédiés (scolaire), marchés des régions.
- **Occasionnel** : groupe constitué, **billet collectif** établi avant le service et présent à bord.
- **SLO** : liaisons interurbaines libéralisées depuis 2015 ; plus de 100 km libres, liaisons courtes régulées via l'**ART** (seuils à vérifier) ; sans oublier **TAD** et **cabotage**.$mft$,
    $mft$Les catégories de services voyageurs (réguliers, SRS et scolaire, occasionnels avec billet collectif, SLO libéralisés depuis 2015 avec régulation ART, TAD, cabotage) et le cadre propre à chacune.$mft$,
    2, 40) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : Les autorités organisatrices ────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'autorites-organisatrices',
    'Qui commande le transport public : AOM, régions et Île-de-France Mobilités',
    $mft$> 🎯 **Objectifs**
> - Identifier l'autorité organisatrice compétente selon le territoire et le type de service.
> - Distinguer les grands cadres contractuels : délégation de service public et marchés publics.
> - Comprendre la qualité contractualisée : cahier des charges, reporting, pénalités.

## Le transport public est un transport COMMANDÉ

Contrairement à l'occasionnel, où un client privé achète une prestation, le transport public régulier répond à une commande publique : une collectivité définit le service, le finance en partie et en contrôle l'exécution. Pour l'exploitant, connaître son autorité organisatrice, c'est connaître son vrai client.

## Qui organise quoi

| Territoire ou service | Autorité organisatrice |
| --- | --- |
| Mobilité urbaine (agglomérations) | Les AOM, autorités organisatrices de la mobilité |
| Interurbain et scolaire (hors Île-de-France) | La région, depuis la loi NOTRe |
| Île-de-France | Île-de-France Mobilités |

Les AOM organisent la mobilité dans les agglomérations : réseaux urbains, dessertes locales. Les régions ont hérité, avec la loi NOTRe, de l'interurbain et du transport scolaire : ce sont elles qui passent les marchés des circuits SRS. En Île-de-France, une autorité unique, Île-de-France Mobilités, organise l'ensemble des transports collectifs de la région capitale.

## DSP ou marché public : deux façons de contracter

L'autorité organisatrice confie l'exploitation par deux grands canaux :

- La **délégation de service public (DSP)** : l'exploitant se voit confier le service dans la durée, avec une part du risque d'exploitation à sa charge ; il fait vivre le service au quotidien dans le cadre fixé par la convention.
- Le **marché public** : la collectivité achète une prestation définie (par exemple des circuits scolaires) et la paie au prix convenu ; le cadre est plus prescriptif, la prestation plus délimitée.

Dans les deux cas, tout commence par un appel d'offres, et tout se joue ensuite dans la convention.

:::flow
1. Publication | L'autorité organisatrice publie son appel d'offres et son cahier des charges
2. Candidature | L'entreprise démontre ses capacités (parc, conducteurs, références)
3. Offre | Prix et mémoire technique : le projet d'exploitation proposé
4. Attribution | L'autorité choisit, puis signe la convention ou le marché
5. Exploitation | Le service roule, avec reporting régulier vers l'autorité
6. Contrôle | Indicateurs suivis, pénalités appliquées en cas de manquement
:::

## La qualité contractualisée

Le cahier des charges transforme la qualité en obligations mesurables : ponctualité, information des voyageurs, propreté des véhicules, accessibilité. L'exploitant ne vise plus une qualité « en général » : il vise LES indicateurs de SA convention, car chaque manquement mesuré peut déclencher une pénalité de service.

> 📌 **À retenir**
> Chez un exploitant conventionné, le réflexe professionnel est de raisonner cahier des charges : quel niveau de ponctualité est exigé, comment l'information voyageurs doit être diffusée, quel état de propreté est contrôlé, quelles obligations d'accessibilité s'appliquent. La convention est le document de travail quotidien, pas une pièce d'archive.

> ❌ **Piège à éviter**
> Considérer la pénalité comme un simple coût à payer. Une pénalité récurrente signale à l'autorité organisatrice un exploitant qui ne tient pas ses engagements : au renouvellement de la DSP ou du marché, cette réputation pèse plus lourd que le montant des pénalités elles-mêmes.

> 🎓 **Le saviez-vous ?**
> Dans les appels d'offres de transport public, le prix n'est pas le seul critère : le mémoire technique (organisation de l'exploitation, gestion des aléas, qualité de service) départage souvent des offres financièrement proches. Un exploitant qui sait décrire précisément SA méthode d'exploitation gagne des points.

## ✅ Synthèse

- **AOM** pour l'urbain, **régions** pour l'interurbain et le scolaire depuis la loi NOTRe, **Île-de-France Mobilités** en Île-de-France.
- Deux cadres : **DSP** (service confié dans la durée, part de risque) et **marché public** (prestation définie, prix convenu), toujours via appel d'offres.
- Qualité contractualisée : **ponctualité, information, propreté, accessibilité**, suivies par indicateurs avec pénalités de service.$mft$,
    $mft$Les autorités organisatrices (AOM pour l'urbain, régions depuis la loi NOTRe, Île-de-France Mobilités), les cadres contractuels DSP et marchés publics, et la qualité contractualisée par cahier des charges avec pénalités.$mft$,
    3, 40) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : Documents de bord et contrôles ──────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'documents-et-controles',
    'Documents de bord et contrôles en exploitation voyageurs',
    $mft$> 🎯 **Objectifs**
> - Constituer la pochette de bord complète selon le service exploité.
> - Vérifier les attestations du conducteur voyageurs avant chaque affectation.
> - Préparer les conducteurs aux contrôles routiers avec passagers à bord.

## L'exploitant, gardien des documents

Au moment du contrôle, c'est le conducteur qui présente les documents ; mais c'est l'exploitant qui les a préparés, vérifiés et embarqués. Une pochette de bord incomplète n'est jamais la faute du seul conducteur : c'est un défaut d'organisation de l'exploitation. Ce chapitre décrit ce qui doit se trouver à bord, et comment vivre un contrôle avec des passagers.

## La pochette de bord voyageurs

| Document | Rôle |
| --- | --- |
| Copie conforme de la licence | Prouve l'inscription de l'entreprise : une copie numérotée par véhicule |
| Billet collectif (services occasionnels) | Établi AVANT le service : identifie le donneur d'ordre, l'itinéraire et le groupe |
| Feuille de route | Exigée dans certains cas selon le service : à vérifier selon la nature du déplacement |
| Documents du véhicule | Papiers du véhicule et justificatifs d'assurance |
| Affichages à bord | Interdiction de fumer, consignes de sécurité visibles des voyageurs |

> ⚠️ **Attention**
> Les cas exacts où une feuille de route est exigée sont à vérifier selon le type de service exploité : l'exploitant doit trancher ce point AVANT le départ, service par service, et non laisser le conducteur improviser au bord de la route.

## Les attestations du conducteur voyageurs

Avant toute affectation, l'exploitation vérifie que le conducteur dispose de son permis D en cours de validité, de sa qualification professionnelle voyageurs (qualification initiale, entretenue par la formation continue) et de sa carte de qualification. Un conducteur récemment embauché venu du transport de marchandises n'est pas automatiquement apte : sa qualification doit couvrir le champ VOYAGEURS.

:::flow
1. Affectation | L'exploitation désigne conducteur et véhicule pour le service
2. Vérification conducteur | Permis D, qualification voyageurs à jour, carte de qualification
3. Vérification véhicule | Copie conforme à bord, documents du véhicule, affichages en place
4. Vérification service | Billet collectif établi si occasionnel, feuille de route si exigée
5. Départ | Pochette de bord complète remise au conducteur
:::

## Le billet collectif : avant, pas après

Pour un service occasionnel, le billet collectif doit exister AVANT que le véhicule parte : il identifie le donneur d'ordre, l'itinéraire et le groupe transporté. Un billet établi après coup, « régularisé » au retour, ne remplit pas sa fonction : au contrôle, le service apparaît comme non couvert.

> ❌ **Piège à éviter**
> Le transfert « dépannage » accepté par téléphone le samedi matin, parti sans billet collectif « qu'on fera lundi » : c'est précisément le service qui sera contrôlé. L'exploitant organise une procédure d'astreinte pour établir le document avant TOUT départ, y compris en urgence.

## Le contrôle routier avec passagers à bord

Le transport de voyageurs a une spécificité que les marchandises ne connaissent pas : le contrôle se déroule sous les yeux des clients. Cinquante passagers observent la scène, s'impatientent, filment parfois. La consigne d'exploitation aux conducteurs tient en trois points : coopérer pleinement avec les agents (documents présentés sans discussion), informer les passagers avec des mots simples (motif du contrôle, durée prévisible), et prévenir l'exploitation qui gère les conséquences (retard sur l'horaire, information du donneur d'ordre ou de l'autorité organisatrice).

> 🔍 **Zoom**
> Un contrôle bien vécu est presque invisible pour les passagers : documents accessibles en quelques secondes, conducteur calme, annonce courte et rassurante. Un contrôle mal préparé (documents introuvables, conducteur agacé) dégrade l'image de l'entreprise devant un car entier de clients.

> 💡 **Astuce d'exploitant**
> Standardisez la pochette de bord : même ordre de classement dans tous les véhicules, vérification à chaque prise de service, remplacement immédiat de toute pièce manquante. Le jour du contrôle, le conducteur trouve chaque document sans chercher.

## ✅ Synthèse

- Pochette de bord : **copie conforme**, **billet collectif** (occasionnels, établi AVANT le service), **feuille de route selon les cas (à vérifier)**, **affichages obligatoires** (interdiction de fumer, consignes).
- Conducteur : **permis D + qualification voyageurs + carte de qualification**, vérifiés par l'exploitation avant affectation.
- Contrôle avec passagers : **coopérer, informer les clients, prévenir l'exploitation** : le contrôle est aussi une vitrine.$mft$,
    $mft$La pochette de bord voyageurs (copie conforme, billet collectif établi avant le service, feuille de route selon les cas, affichages), la vérification des attestations conducteur et la conduite à tenir en contrôle routier avec passagers.$mft$,
    4, 40) RETURNING id INTO v_l4;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : Le cadre du transport de voyageurs',
    'Vérifiez le module 1 : accès à la profession voyageurs, typologie des services, autorités organisatrices, documents de bord.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Un conducteur d'autocar expérimenté veut créer son entreprise de transport de voyageurs. Quelles sont les quatre exigences d'accès à la profession qu'il devra satisfaire ?$mft$,
    $mft$[
      {"id":"a","label":"Établissement, honorabilité, capacité financière et capacité professionnelle voyageurs","is_correct":true},
      {"id":"b","label":"Permis D, carte de qualification, visite médicale et casier vierge","is_correct":false},
      {"id":"c","label":"Un local commercial, un site internet, une assurance et un comptable","is_correct":false},
      {"id":"d","label":"Une convention avec une autorité organisatrice, un parc de dix véhicules minimum, un atelier et un dépôt","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ertv','module-1','qcm-v1'], 'ERTV-M1-QCM-01', false,
    $mft$Les quatre piliers valent pour l'entreprise, pas pour le conducteur : permis et carte (b) concernent le salarié conducteur, et aucun texte n'impose de parc minimal ni de convention préalable (c, d).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un office de tourisme vous commande le transport aller-retour d'un groupe de 40 personnes vers un château, avec visite sur place. Dans quelle catégorie classez-vous ce service ?$mft$,
    $mft$[
      {"id":"a","label":"Un service occasionnel : groupe constitué à la demande d'un donneur d'ordre, avec billet collectif à bord","is_correct":true},
      {"id":"b","label":"Un service régulier, puisque le trajet a un horaire précis","is_correct":false},
      {"id":"c","label":"Un service librement organisé (SLO), puisque le client est privé","is_correct":false},
      {"id":"d","label":"Un transport à la demande (TAD), puisque le client a réservé","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ertv','module-1','qcm-v1'], 'ERTV-M1-QCM-02', false,
    $mft$Groupe constitué + donneur d'ordre + excursion = occasionnel. Le régulier est ouvert à tous (b), le SLO est une liaison commercialisée place par place (c) et le TAD est un service organisé déclenché à la réservation, pas une excursion privée (d).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Votre entreprise, implantée hors Île-de-France, veut se positionner sur des circuits de transport scolaire. Vers quelle autorité devez-vous surveiller les appels d'offres ?$mft$,
    $mft$[
      {"id":"a","label":"La région, compétente pour l'interurbain et le scolaire depuis la loi NOTRe","is_correct":true},
      {"id":"b","label":"Chaque établissement scolaire, qui choisit son transporteur","is_correct":false},
      {"id":"c","label":"L'ART, qui attribue les circuits scolaires","is_correct":false},
      {"id":"d","label":"La préfecture, qui désigne un transporteur par canton","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ertv','module-1','qcm-v1'], 'ERTV-M1-QCM-03', false,
    $mft$Depuis la loi NOTRe, les régions passent les marchés du scolaire (SRS). Les établissements ne contractent pas le transport régulier des élèves (b), l'ART régule les liaisons SLO courtes et n'attribue rien (c), et la préfecture ne désigne pas de transporteur (d).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Un car part samedi à 6 h pour un transfert de groupe vers un aéroport. Quel document propre à ce type de service doit impérativement se trouver à bord dès le départ ?$mft$,
    $mft$[
      {"id":"a","label":"Le billet collectif, établi avant le service : donneur d'ordre, itinéraire, groupe","is_correct":true},
      {"id":"b","label":"La convention signée avec l'autorité organisatrice","is_correct":false},
      {"id":"c","label":"L'original de la licence communautaire de l'entreprise","is_correct":false},
      {"id":"d","label":"Le registre des transporteurs de personnes","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ertv','module-1','qcm-v1'], 'ERTV-M1-QCM-04', false,
    $mft$Un transfert de groupe est un service occasionnel : billet collectif à bord, établi AVANT le départ. Il n'y a pas d'autorité organisatrice sur un occasionnel (b), l'original de la licence reste au siège, seule la copie conforme voyage (c), et le registre n'est pas un document de bord (d).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Votre parc passe de minibus de 9 places à des autocars de 55 places. Comment évolue l'exigence de capacité financière de l'entreprise ?$mft$,
    $mft$[
      {"id":"a","label":"Le barème change : pour les véhicules de plus de 9 places, un montant plus élevé est exigé pour le premier véhicule, puis un montant par véhicule supplémentaire","is_correct":true},
      {"id":"b","label":"Elle ne change pas : la capacité financière se calcule par entreprise, pas par véhicule","is_correct":false},
      {"id":"c","label":"Elle se calcule au nombre de sièges : un montant fixe par place assise","is_correct":false},
      {"id":"d","label":"Elle disparaît : au-delà de 9 places, seule la capacité professionnelle est exigée","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-1','qcm-v1'], 'ERTV-M1-QCM-05', false,
    $mft$Le barème voyageurs distingue les véhicules jusqu'à 9 places (montant par véhicule) et ceux au-delà (montant renforcé pour le premier, puis un montant par véhicule suivant ; montants exacts à vérifier). Le calcul est bien lié au parc (b), jamais au nombre de sièges (c), et aucune exigence ne disparaît (d).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Votre direction veut lancer une liaison commerciale par autocar entre deux métropoles distantes de 450 km, vendue place par place. Quel est le cadre applicable ?$mft$,
    $mft$[
      {"id":"a","label":"Un service librement organisé (SLO) : au-delà de 100 km, la liaison est libre depuis la libéralisation de 2015","is_correct":true},
      {"id":"b","label":"Une délégation de service public à demander à la région","is_correct":false},
      {"id":"c","label":"Un service occasionnel avec billet collectif pour chaque départ","is_correct":false},
      {"id":"d","label":"Une autorisation préalable de l'ART, obligatoire pour toute liaison SLO","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-1','qcm-v1'], 'ERTV-M1-QCM-06', false,
    $mft$Liaison interurbaine de plus de 100 km vendue au public = SLO libre depuis 2015. La DSP concerne les services commandés par une autorité (b), l'occasionnel suppose un groupe constitué (c), et la régulation ART vise les liaisons courtes, pas les longues distances (d).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Une agglomération confie à votre entreprise l'exploitation de son réseau urbain dans la durée, avec une part du risque d'exploitation à votre charge et des indicateurs qualité assortis de pénalités. Quel cadre contractuel reconnaissez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Une délégation de service public (DSP) conclue avec l'AOM","is_correct":true},
      {"id":"b","label":"Un service librement organisé, puisque l'entreprise porte un risque","is_correct":false},
      {"id":"c","label":"Un marché de fournitures classique","is_correct":false},
      {"id":"d","label":"Une simple autorisation d'exploiter délivrée par la préfecture","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-1','qcm-v1'], 'ERTV-M1-QCM-07', false,
    $mft$Service confié dans la durée par une AOM avec part de risque et qualité contractualisée : c'est la DSP. Le SLO est à l'initiative du transporteur, sans commande publique (b) ; un marché de fournitures achète des biens, pas un service public de transport (c) ; la préfecture ne délivre pas ce type d'autorisation (d).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Un de vos cars est contrôlé en bord de route avec 45 passagers à bord. Quelle consigne l'exploitation doit-elle avoir donnée à ses conducteurs pour ce cas ?$mft$,
    $mft$[
      {"id":"a","label":"Coopérer avec les agents, informer calmement les passagers du motif et de la durée prévisible, prévenir l'exploitation","is_correct":true},
      {"id":"b","label":"Demander aux agents de reporter le contrôle au terminus, par égard pour les clients","is_correct":false},
      {"id":"c","label":"Faire descendre tous les passagers sur l'accotement pendant la vérification","is_correct":false},
      {"id":"d","label":"Ne rien dire aux passagers pour ne pas les inquiéter","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-1','qcm-v1'], 'ERTV-M1-QCM-08', false,
    $mft$Le contrôle avec passagers se gère par la coopération, l'information des clients et l'alerte de l'exploitation qui traite les conséquences. On ne négocie pas le report d'un contrôle (b), on n'expose pas les passagers au bord de la route sans nécessité (c), et le silence nourrit l'inquiétude et les plaintes (d).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un investisseur vous demande d'ouvrir une liaison SLO entre deux villes distantes de 80 km, en parallèle d'une ligne régionale conventionnée. Que devez-vous anticiper ?$mft$,
    $mft$[
      {"id":"a","label":"Une régulation via l'ART : sur les liaisons courtes, elle peut limiter ou interdire le service s'il fragilise la ligne conventionnée","is_correct":true},
      {"id":"b","label":"Rien de particulier : toutes les liaisons SLO sont libres depuis 2015","is_correct":false},
      {"id":"c","label":"Une interdiction absolue : aucun SLO n'est possible en dessous de 100 km","is_correct":false},
      {"id":"d","label":"Un rachat obligatoire de la ligne conventionnée avant l'ouverture","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-1','qcm-v1'], 'ERTV-M1-QCM-09', false,
    $mft$En dessous de 100 km, la liberté n'est pas totale : l'ART examine l'atteinte à l'équilibre d'un service conventionné et peut limiter ou interdire (modalités précises à vérifier). Ni liberté totale (b), ni interdiction automatique (c), ni rachat (d) : c'est une régulation au cas par cas.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Votre gestionnaire de transport est condamné pour des faits incompatibles avec l'honorabilité professionnelle. Quelle est la conséquence pour l'entreprise ?$mft$,
    $mft$[
      {"id":"a","label":"L'exigence d'honorabilité n'est plus satisfaite : l'entreprise doit régulariser, notamment en désignant un autre gestionnaire, sous peine de perdre son droit d'exercer","is_correct":true},
      {"id":"b","label":"Aucune : l'honorabilité ne s'apprécie que sur la tête du dirigeant","is_correct":false},
      {"id":"c","label":"L'entreprise perd immédiatement et définitivement toutes ses licences, sans possibilité de régularisation","is_correct":false},
      {"id":"d","label":"Elle doit seulement doubler sa capacité financière pour compenser","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ertv','module-1','qcm-v1'], 'ERTV-M1-QCM-10', false,
    $mft$L'honorabilité s'apprécie aussi sur le gestionnaire de transport (pas seulement le dirigeant, b) : l'entreprise doit régulariser, par exemple en désignant un nouveau gestionnaire. La sanction n'est ni automatique et définitive sans issue (c), ni compensable par de l'argent (d).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Sur votre réseau urbain en DSP, l'indicateur de ponctualité du trimestre est nettement sous le seuil du cahier des charges. Que devez-vous anticiper dans la relation avec l'AOM ?$mft$,
    $mft$[
      {"id":"a","label":"L'application des pénalités prévues à la convention, et l'attente d'un plan d'action correctif de votre part","is_correct":true},
      {"id":"b","label":"Une amende fixée par l'ART, autorité compétente sur les réseaux urbains","is_correct":false},
      {"id":"c","label":"Rien, tant qu'aucun incident de sécurité n'est survenu","is_correct":false},
      {"id":"d","label":"La résiliation automatique et immédiate de la convention","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ertv','module-1','qcm-v1'], 'ERTV-M1-QCM-11', false,
    $mft$La qualité est contractualisée : le manquement mesuré déclenche les pénalités de la convention et appelle un plan d'action. L'ART n'intervient pas sur la qualité d'un réseau urbain conventionné (b), la sécurité n'est pas le seul engagement (c), et la résiliation n'est pas automatique au premier écart (d).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Débordé, vous sous-traitez une excursion de dimanche à un confrère autocariste. Quelles vérifications documentaires vous incombent avant le départ ?$mft$,
    $mft$[
      {"id":"a","label":"Que le sous-traitant est bien inscrit avec copie conforme de licence à bord, que le billet collectif est établi avant le service et que son conducteur détient permis D et qualification voyageurs à jour","is_correct":true},
      {"id":"b","label":"Aucune : en sous-traitance, la conformité documentaire repose entièrement sur le sous-traitant","is_correct":false},
      {"id":"c","label":"Uniquement l'assurance du véhicule : le reste ne concerne pas le donneur d'ordre","is_correct":false},
      {"id":"d","label":"Que le sous-traitant remette le billet collectif au retour du service, pour archivage","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ertv','module-1','qcm-v1'], 'ERTV-M1-QCM-12', false,
    $mft$Le donneur d'ordre professionnel s'assure que le service sous-traité est réglementairement couvert : licence, billet collectif AVANT le départ, conducteur qualifié voyageurs. Se défausser (b, c) expose votre entreprise et vos clients, et un billet établi après coup ne couvre pas le service (d).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l2, 'qr',
   $mft$Quelle caractéristique distingue fondamentalement un service régulier d'un service occasionnel ?$mft$,
   $mft$Le service régulier est une ligne ouverte à tout public, à horaires et itinéraire fixes, conventionnée avec une autorité organisatrice ; le service occasionnel transporte un groupe constitué à la demande d'un donneur d'ordre.$mft$,
   2, 'facile', ARRAY['ertv','module-1','question-courte'], 'ERTV-M1-QC-01', false,
   $mft$Ouvert à tous et conventionné, contre groupe constitué à la demande.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$En Île-de-France, quelle autorité organise l'ensemble des transports collectifs ?$mft$,
   $mft$Île-de-France Mobilités.$mft$,
   2, 'facile', ARRAY['ertv','module-1','question-courte'], 'ERTV-M1-QC-02', false,
   $mft$Une autorité unique pour toute la région capitale.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Citez trois documents ou attestations qui doivent pouvoir être présentés lors du contrôle d'un car assurant un service occasionnel.$mft$,
   $mft$Par exemple : la copie conforme de la licence, le billet collectif du service, le permis D du conducteur, sa carte de qualification voyageurs.$mft$,
   2, 'facile', ARRAY['ertv','module-1','question-courte'], 'ERTV-M1-QC-03', false,
   $mft$Trois pièces distinctes couvrant entreprise, service et conducteur.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Un candidat exploitant sans diplôme vous demande comment obtenir la capacité professionnelle en transport de voyageurs. Que lui répondez-vous ?$mft$,
   $mft$Principalement en réussissant l'examen de capacité professionnelle voyageurs ; des équivalences existent par certains diplômes reconnus ou par une expérience confirmée de direction d'une entreprise de transport de personnes.$mft$,
   2, 'moyen', ARRAY['ertv','module-1','question-courte'], 'ERTV-M1-QC-04', false,
   $mft$Examen comme voie principale, équivalences diplôme ou expérience.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Qu'est-ce qu'un service librement organisé (SLO), et à partir de quelle distance la liaison est-elle totalement libre ?$mft$,
   $mft$Une liaison interurbaine ouverte à l'initiative du transporteur, libéralisée depuis 2015 (services dits cars Macron) ; au-delà de 100 km la liaison est libre, en dessous elle passe par la régulation de l'ART.$mft$,
   2, 'moyen', ARRAY['ertv','module-1','question-courte'], 'ERTV-M1-QC-05', false,
   $mft$Libéralisation 2015, seuil de 100 km, régulation ART en deçà.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Pour l'exploitation d'un réseau de transport public, qu'est-ce qui distingue une délégation de service public d'un marché public ?$mft$,
   $mft$La DSP confie l'exploitation du service dans la durée avec une part du risque d'exploitation à la charge de l'exploitant ; le marché public achète une prestation définie, payée au prix convenu par la collectivité.$mft$,
   2, 'moyen', ARRAY['ertv','module-1','question-courte'], 'ERTV-M1-QC-06', false,
   $mft$Durée et part de risque contre prestation définie payée au prix.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Pourquoi le billet collectif d'un service occasionnel doit-il être établi AVANT le début du service, et non régularisé au retour ?$mft$,
   $mft$Parce qu'il identifie le donneur d'ordre, l'itinéraire et le groupe pendant le service : établi après coup, il ne couvre pas le transport en cas de contrôle et le service apparaît comme non justifié.$mft$,
   2, 'moyen', ARRAY['ertv','module-1','question-courte'], 'ERTV-M1-QC-07', false,
   $mft$Le document accompagne le service, il ne le raconte pas après coup.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Qu'est-ce qu'un service régulier spécialisé (SRS), et qui en passe les marchés ?$mft$,
   $mft$Un service régulier réservé à une catégorie d'usagers, dont le transport scolaire est la figure principale (circuits dédiés) ; les marchés sont passés par les régions.$mft$,
   2, 'moyen', ARRAY['ertv','module-1','question-courte'], 'ERTV-M1-QC-08', false,
   $mft$Circuits dédiés à une catégorie d'usagers, marchés des régions.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Votre parc passe de véhicules de 9 places à des autocars de grande capacité : expliquez en une phrase l'effet sur la capacité financière exigée.$mft$,
   $mft$Le barème change : on passe d'un montant par véhicule (de l'ordre de 1500 euros jusqu'à 9 places) à un barème renforcé pour les véhicules de plus de 9 places, avec un montant plus élevé pour le premier véhicule puis un montant par véhicule suivant (montants exacts à vérifier).$mft$,
   2, 'difficile', ARRAY['ertv','module-1','question-courte'], 'ERTV-M1-QC-09', false,
   $mft$Changement de barème lié à la capacité des véhicules, montants à vérifier.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Votre convention urbaine prévoit des pénalités sur la ponctualité : citez trois autres exigences de qualité classiques d'un cahier des charges voyageurs.$mft$,
   $mft$Par exemple : l'information des voyageurs, la propreté des véhicules, l'accessibilité (auxquelles s'ajoutent selon les conventions d'autres indicateurs de service).$mft$,
   2, 'difficile', ARRAY['ertv','module-1','question-courte'], 'ERTV-M1-QC-10', false,
   $mft$Information, propreté, accessibilité : la qualité contractualisée.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Un conducteur d'autocar de votre entreprise veut créer sa propre société de transport de voyageurs et vous demande conseil. Expliquez-lui les quatre exigences d'accès à la profession, en insistant sur ce qui est propre aux voyageurs, puis le parcours jusqu'aux copies conformes.$mft$,
   $mft$Réponse modèle. Quatre exigences. 1) L'établissement : une implantation stable et effective en France, où l'entreprise conserve ses documents et dirige réellement l'activité. 2) L'honorabilité : appréciée sur le dirigeant ET sur le gestionnaire de transport, sans condamnations incompatibles. 3) La capacité financière : des capitaux et réserves suffisants selon un barème PROPRE aux voyageurs, calculé sur le parc : un montant par véhicule jusqu'à 9 places, un barème renforcé au-delà (montant plus élevé pour le premier véhicule, puis un montant par véhicule suivant ; montants exacts à vérifier dans les textes en vigueur). 4) La capacité professionnelle VOYAGEURS : attestation obtenue par examen, ou par équivalence (diplômes reconnus, expérience de direction) ; l'attestation marchandises ne suffit pas. Parcours : désigner un gestionnaire de transport qui porte la capacité et dirige effectivement l'activité ; déposer le dossier ; inscription au registre des transporteurs de personnes ; délivrance de la licence (intérieure ou communautaire selon l'activité) ; enfin les copies conformes numérotées, une à bord de chaque véhicule, l'original restant au siège. Conseil final : dimensionner le parc en cohérence avec la capacité financière disponible avant de s'engager.$mft$,
   $mft$Barème /5 : les quatre exigences exactes (2 pts) ; spécificités voyageurs soulignées : barème financier propre (avec prudence sur les montants) et attestation voyageurs distincte (1,5 pt) ; parcours registre puis licence puis copies conformes dans l'ordre (1 pt) ; rôle du gestionnaire de transport (0,5 pt). Erreurs fréquentes : confondre les exigences de l'entreprise avec les documents du conducteur (permis D, carte) ; affirmer des montants précis sans réserve.$mft$,
   5, 'facile', ARRAY['ertv','module-1','question-redigee'], 'ERTV-M1-QR-01', false,
   $mft$Le parcours d'accès à la profession voyageurs, exigence par exigence.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Trois demandes arrivent le même matin à votre bureau d'exploitation : a) la région consulte pour un circuit domicile-école de 15 élèves ; b) un comité d'entreprise veut un aller-retour vers un parc d'attractions samedi ; c) la direction souhaite ouvrir une liaison commerciale de 300 km vendue en ligne place par place. Classez chaque demande dans la typologie des services et précisez le cadre applicable à chacune.$mft$,
   $mft$Réponse modèle. a) Circuit domicile-école : service régulier SPÉCIALISÉ (SRS) : un service régulier réservé à une catégorie d'usagers, ici des scolaires, avec circuits dédiés et points d'arrêt fixés ; le cadre est le marché public passé par la région (compétente pour le scolaire depuis la loi NOTRe) : réponse à l'appel d'offres, exécution conforme au marché. b) Comité d'entreprise vers un parc d'attractions : service OCCASIONNEL : groupe constitué transporté à la demande d'un donneur d'ordre privé ; le cadre est contractuel (devis, contrat avec le CE) avec la pièce maîtresse du billet collectif, établi AVANT le service (donneur d'ordre, itinéraire, groupe) et présent à bord. c) Liaison de 300 km vendue place par place : service LIBREMENT ORGANISÉ (SLO), issu de la libéralisation de 2015 : au-delà de 100 km, la liaison est libre, sans autorité organisatrice ni régulation ART ; l'entreprise définit seule dessertes, horaires et prix, et porte seule le risque commercial. Conclusion d'exploitant : trois clients différents (une région, un CE, le grand public), trois cadres documentaires et contractuels différents : la typologie est le premier réflexe de qualification d'une demande.$mft$,
   $mft$Barème /5 : classification exacte des trois demandes (1,5 pt) ; cadre du SRS : marché de la région (1 pt) ; cadre de l'occasionnel : billet collectif avant le service (1,25 pt) ; cadre du SLO : liberté au-delà de 100 km, risque commercial porté par l'entreprise (1,25 pt). Erreurs fréquentes : classer le circuit scolaire en occasionnel ; oublier que le billet collectif précède le service ; croire qu'un SLO longue distance nécessite une autorisation.$mft$,
   5, 'facile', ARRAY['ertv','module-1','question-redigee'], 'ERTV-M1-QR-02', false,
   $mft$Trois demandes, trois catégories, trois cadres : le tri du matin.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Votre entreprise hésite entre deux stratégies : candidater à la DSP du réseau urbain d'une agglomération, ou répondre aux marchés de circuits scolaires de la région. Comparez les deux cadres contractuels du point de vue de l'exploitant : nature de l'engagement, part de risque, relation avec l'autorité, exigences qualité.$mft$,
   $mft$Réponse modèle. Nature de l'engagement : la DSP confie l'exploitation d'un service public dans la durée : l'exploitant fait vivre le réseau au quotidien (offre, personnel, matériel) dans le cadre de la convention ; le marché scolaire achète une prestation délimitée : des circuits définis, exécutés conformément au marché. Part de risque : en DSP, une part du risque d'exploitation pèse sur le délégataire, ce qui exige une vraie capacité de gestion ; en marché public, la prestation est payée au prix convenu, le risque commercial est plus faible mais les marges sont serrées par la concurrence à l'appel d'offres. Relation avec l'autorité : en DSP, une relation continue et dense avec l'AOM (reporting, comités, avenants) ; en marché scolaire, une relation plus administrative avec la région, centrée sur l'exécution des circuits. Exigences qualité : dans les deux cas, un cahier des charges contractualise la qualité (ponctualité, information, propreté, accessibilité) avec pénalités ; en DSP, le spectre d'indicateurs est généralement plus large. Conclusion : la DSP demande une organisation d'exploitation complète et robuste ; les marchés scolaires constituent souvent une marche d'entrée plus accessible pour une entreprise qui grandit.$mft$,
   $mft$Barème /5 : nature des deux engagements correctement opposée (1,5 pt) ; part de risque distinguée (1,5 pt) ; relation avec l'autorité (AOM en continu, région sur l'exécution) (1 pt) ; qualité contractualisée avec pénalités dans les deux cas (1 pt). Erreurs fréquentes : présenter le marché public comme sans exigence qualité ; confondre l'autorité compétente (AOM pour l'urbain, région pour le scolaire).$mft$,
   5, 'moyen', ARRAY['ertv','module-1','question-redigee'], 'ERTV-M1-QR-03', false,
   $mft$DSP ou marchés scolaires : le comparatif stratégique de l'exploitant.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Rédigez la check-list documentaire qu'un exploitant remet à son équipe pour tout départ en service occasionnel : ce qu'il faut vérifier côté véhicule, côté conducteur et côté service, en justifiant chaque pièce en une phrase.$mft$,
   $mft$Réponse modèle. Côté véhicule : la copie conforme de la licence, numérotée, propre au véhicule (elle prouve en contrôle que l'entreprise est régulièrement inscrite ; l'original reste au siège) ; les documents du véhicule et les justificatifs d'assurance (identification et couverture du car) ; les affichages obligatoires en place et visibles, dont l'interdiction de fumer et les consignes de sécurité (information réglementaire des voyageurs). Côté conducteur : le permis D en cours de validité (droit de conduire le véhicule) ; la qualification professionnelle voyageurs à jour et la carte de qualification (droit d'exercer le métier sur ce champ : un conducteur venu des marchandises n'est pas automatiquement couvert). Côté service : le billet collectif établi AVANT le départ, mentionnant le donneur d'ordre, l'itinéraire et le groupe (il justifie le caractère occasionnel du service pendant toute son exécution ; le format détaillé est à vérifier dans les textes) ; la feuille de route lorsqu'elle est exigée pour ce type de déplacement (point à trancher par l'exploitation avant le départ, cas exacts à vérifier). Règle de fonctionnement : pochette de bord standardisée, même classement dans tous les véhicules, vérification à la prise de service, aucune régularisation après coup.$mft$,
   $mft$Barème /5 : les trois volets structurés véhicule/conducteur/service (1 pt) ; pièces exactes par volet dont copie conforme, permis D, qualification et carte, billet collectif avant le service (2,5 pts) ; justification pertinente de chaque pièce (1 pt) ; réserves de prudence sur feuille de route et format du billet collectif (0,5 pt). Erreurs fréquentes : placer l'original de la licence à bord ; accepter un billet collectif régularisé au retour ; oublier les affichages obligatoires.$mft$,
   5, 'moyen', ARRAY['ertv','module-1','question-redigee'], 'ERTV-M1-QR-04', false,
   $mft$La check-list de départ occasionnel : véhicule, conducteur, service.$mft$),
  (v_formation, v_module, v_l2, 'qr',
   $mft$Un investisseur veut lancer avec votre entreprise deux liaisons SLO : une Paris-Bordeaux et une liaison de 70 km entre deux villes moyennes desservies par une ligne régionale conventionnée. Analysez le régime applicable à chaque projet et les précautions à prendre avant tout engagement financier.$mft$,
   $mft$Réponse modèle. Paris-Bordeaux : liaison interurbaine très supérieure à 100 km : régime de liberté totale issu de la libéralisation de 2015 : l'entreprise ouvre la liaison de sa propre initiative, fixe dessertes, horaires et prix ; les précautions sont ici COMMERCIALES : étude de la demande, de la concurrence (autres SLO, train), des coûts d'exploitation longue distance, car l'entreprise porte seule le risque. La liaison de 70 km : en dessous de 100 km, la liberté n'est pas acquise : le projet passe par la régulation confiée à l'ART, qui examine si le service porte atteinte à l'équilibre économique de la ligne régionale conventionnée et peut le limiter ou l'interdire ; les modalités et seuils précis de cette procédure sont à vérifier avant de bâtir le plan d'affaires. Précautions transverses : ne pas engager de dépenses irréversibles (véhicules dédiés, personnels) avant que le régime de la liaison courte soit sécurisé ; intégrer le délai d'instruction au calendrier ; documenter l'étude de marché pour les deux liaisons ; prévoir un scénario de repli si la liaison courte est limitée ou refusée. Conclusion : même produit commercial, deux régimes juridiques distincts, et un séquencement prudent de l'investissement.$mft$,
   $mft$Barème /5 : régime correct de la liaison longue (liberté depuis 2015) (1,5 pt) ; régime correct de la liaison courte (régulation ART, limitation ou interdiction possible, prudence sur les modalités) (2 pts) ; précautions d'investissement séquencées (1 pt) ; distinction risque commercial / risque réglementaire (0,5 pt). Erreurs fréquentes : croire toutes les liaisons SLO libres ; engager l'investissement avant l'issue de la régulation ; inventer des seuils précis non vérifiés.$mft$,
   5, 'moyen', ARRAY['ertv','module-1','question-redigee'], 'ERTV-M1-QR-05', false,
   $mft$Deux projets SLO, deux régimes : analyse avant investissement.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Votre gestionnaire de transport annonce son départ pour le mois prochain. En tant que dirigeant, construisez votre plan d'action pour maintenir l'entreprise en conformité, en expliquant ce que le gestionnaire porte réglementairement et les risques d'une vacance prolongée.$mft$,
   $mft$Réponse modèle. Ce que porte le gestionnaire : il détient la capacité professionnelle voyageurs de l'entreprise et dirige effectivement et en permanence l'activité de transport (entretien, contrats, affectation des conducteurs, sécurité) ; l'honorabilité s'apprécie aussi sur sa personne. Son départ fait donc tomber une exigence d'accès à la profession si personne ne le remplace. Plan d'action. 1) Immédiat : cartographier les candidats internes (un cadre détient-il l'attestation voyageurs ?) et externes (recrutement, ou dirigeant passant lui-même l'examen ou faisant valoir une équivalence). 2) Avant le départ : organiser le tuyautage complet des dossiers (conventions, échéances des copies conformes, suivi du parc et de la capacité financière) pour éviter la perte de mémoire d'exploitation. 3) Désignation : nommer le nouveau gestionnaire et informer l'administration qui tient le registre, afin que la situation de l'entreprise reste régulière. 4) Vérifications : honorabilité du nouveau gestionnaire, réalité de sa direction effective (pas de gestionnaire de papier). Risques d'une vacance prolongée : l'entreprise ne satisfait plus aux exigences et s'expose à une remise en cause de son droit d'exercer ; risque commercial associé si les autorités organisatrices partenaires s'en inquiètent. Conclusion : le remplacement d'un gestionnaire se pilote comme un projet, avec un calendrier serré.$mft$,
   $mft$Barème /5 : rôle réglementaire du gestionnaire correctement décrit (capacité, direction effective, honorabilité) (1,5 pt) ; plan d'action séquencé avec désignation d'un remplaçant et information de l'administration du registre (1,5 pt) ; risques de la vacance (perte du droit d'exercer, impact commercial) (1 pt) ; vigilance contre le gestionnaire de papier (1 pt). Erreurs fréquentes : croire que la capacité professionnelle appartient à l'entreprise et non à une personne ; laisser la vacance ouverte en attendant le candidat idéal.$mft$,
   5, 'moyen', ARRAY['ertv','module-1','question-redigee'], 'ERTV-M1-QR-06', false,
   $mft$Départ du gestionnaire de transport : le plan de continuité réglementaire.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$La région publie un appel d'offres portant sur 12 circuits scolaires. Analysez les rubriques qualité attendues du cahier des charges (ponctualité, information, propreté, accessibilité, pénalités) et construisez l'ossature du mémoire technique qui rendra votre offre crédible face à un concurrent moins cher.$mft$,
   $mft$Réponse modèle. Lecture du cahier des charges : identifier pour chaque exigence l'indicateur mesuré et la pénalité associée : ponctualité (respect des horaires aux points d'arrêt, sensible pour les familles et les établissements), information (prévenance en cas d'aléa : qui alerte qui, dans quel délai), propreté (état intérieur des véhicules contrôlable), accessibilité (obligations applicables aux circuits et aux matériels). Ossature du mémoire technique. 1) Organisation d'exploitation : affectation nominative des conducteurs par circuit, véhicules dédiés avec plan de remplacement, encadrement joignable aux heures de pointe scolaires. 2) Gestion des aléas : procédure écrite en cas de panne ou d'absence conducteur (véhicule et conducteur de réserve, délais d'intervention), chaîne d'information vers la région, les familles et les établissements. 3) Qualité mesurée : autocontrôles de ponctualité et de propreté avec traces, revue périodique des indicateurs, plan d'action en cas de dérive AVANT la pénalité. 4) Moyens humains : conducteurs qualifiés voyageurs, sensibilisés à la spécificité du public scolaire. 5) Références : circuits comparables déjà exploités, indicateurs obtenus. Face au moins-disant : démontrer que chaque exigence a une réponse organisée et vérifiable ; un prix bas sans organisation crédible se paie en pénalités et en défaillances, ce que la région sait évaluer.$mft$,
   $mft$Barème /5 : les exigences qualité du cahier des charges correctement analysées avec leur logique de pénalité (1,5 pt) ; ossature de mémoire structurée : organisation, aléas, autocontrôle, moyens (2 pts) ; argumentation face au concurrent moins cher (1 pt) ; spécificité du public scolaire prise en compte (0,5 pt). Erreurs fréquentes : réduire l'offre au prix ; promettre des niveaux de service sans décrire le COMMENT ; ignorer la procédure d'aléa (panne, absence).$mft$,
   5, 'difficile', ARRAY['ertv','module-1','question-redigee'], 'ERTV-M1-QR-07', false,
   $mft$Appel d'offres scolaire : du cahier des charges au mémoire technique.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Retour d'expérience : un de vos cars a été contrôlé en pleine excursion avec 50 passagers. Constats des agents : carte de qualification du conducteur périmée depuis deux mois, billet collectif rédigé par téléphone PENDANT le contrôle, passagers laissés sans information pendant 40 minutes. Analysez chaque manquement, ses conséquences, puis construisez le plan correctif de l'exploitation.$mft$,
   $mft$Réponse modèle. Manquements. 1) Carte de qualification périmée : le conducteur n'aurait pas dû être affecté ; la faille est en amont, dans l'exploitation : aucun suivi des échéances de qualification ; conséquences : sanction lors du contrôle, question de couverture du service, image dégradée devant le donneur d'ordre. 2) Billet collectif établi pendant le contrôle : le document devait exister AVANT le départ (donneur d'ordre, itinéraire, groupe) ; régularisé en direct, il ne couvre pas le service et démontre aux agents une organisation défaillante. 3) Passagers sans information pendant 40 minutes : faute de consigne, le conducteur a laissé 50 clients dans l'incertitude : réclamations probables, réputation atteinte, alors qu'une annonce simple (motif, durée prévisible) aurait suffi. Plan correctif. a) Suivi des échéances : tableau des validités (permis D, qualification, cartes) avec alertes à 3 mois et blocage d'affectation en cas d'échéance dépassée. b) Procédure billet collectif : aucune mise en route sans document établi, y compris en urgence (astreinte exploitation le week-end). c) Consigne contrôle : coopérer, informer les passagers, prévenir l'exploitation ; intégrée au livret conducteur et rappelée en causerie. d) Vérification à la prise de service : pochette de bord standardisée contrôlée avant chaque départ. e) Suivi : audit interne à un mois sur ces trois points.$mft$,
   $mft$Barème /5 : les trois manquements analysés avec leur cause racine côté exploitation (2 pts) ; conséquences réalistes différenciées (sanction, non-couverture du service, réputation) (1 pt) ; plan correctif complet : suivi des échéances avec blocage, procédure billet collectif avant tout départ, consigne contrôle passagers (1,5 pt) ; boucle de vérification (audit, prise de service) (0,5 pt). Erreurs fréquentes : tout imputer au conducteur sans traiter l'organisation ; corriger le seul billet collectif ; oublier le volet information des passagers.$mft$,
   5, 'difficile', ARRAY['ertv','module-1','question-redigee'], 'ERTV-M1-QR-08', false,
   $mft$Contrôle raté en excursion : autopsie et plan correctif d'exploitation.$mft$);

  RAISE NOTICE 'Module 1 ERTV créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $ertvm1$;
