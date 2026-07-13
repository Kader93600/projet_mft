-- =====================================================================
-- COMMISSIONNAIRE DE TRANSPORT : MODULE 1 : LE MÉTIER ET SON CADRE
-- v1 (juillet 2026) : LOT COMMISSIONNAIRE-1
-- Le commissionnaire, organisateur de transport en son nom propre :
-- le métier, ses frontières juridiques (transporteur, mandataire,
-- courtier), l'accès à la profession (cadre réformé, à vérifier)
-- et sa place dans la chaîne logistique.
-- ⚠ STATUT : active = false (« à valider »). Idempotent.
-- =====================================================================

DO $commm1$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_l4 uuid;
  v_quiz uuid; v_q uuid; v_ord int := 0;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'commissionnaire';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation commissionnaire introuvable.'; END IF;

  INSERT INTO public.blocs (id, code, title, description, "order") VALUES (80, 'COMMISSIONNAIRE', 'Commissionnaire de transport', 'Le métier de commissionnaire de transport : contrat de commission, responsabilités, organisation multimodale, douane et Incoterms, gestion et assurances.', 80) ON CONFLICT DO NOTHING;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'COMMISSIONNAIRE';

  DELETE FROM public.question_bank WHERE source_ref LIKE 'COMM-M1-%';
  DELETE FROM public.modules WHERE slug = 'comm-metier-cadre';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 1 : Le métier de commissionnaire de transport',
    'comm-metier-cadre', v_bloc,
    'Organisateur de transport en son nom propre : le métier, ses frontières avec le transporteur, le mandataire et le courtier, et son cadre d''accès en pleine évolution.',
    'debutant', 300, 10) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 10, true);

  -- ─── Leçon 1 : Le métier ────────────────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'le-metier',
    'Organisateur de transport : un métier en nom propre',
    $mft$> 🎯 **Objectifs**
> - Comprendre ce que fait concrètement un commissionnaire de transport.
> - Identifier ce qui le distingue du transporteur et de l'entreprise cliente.
> - Découvrir les métiers réels qui vivent sous ce statut : groupeurs, organisateurs internationaux, opérateurs multimodaux.

## Vendre de l'organisation, pas des camions

Le commissionnaire de transport ne déplace pas la marchandise : il **organise** son déplacement, de bout en bout, pour le compte de son client, appelé le **commettant**. Ce client lui confie un besoin (« 26 palettes de Lille à Milan pour vendredi ») et le commissionnaire construit LA solution : il choisit **librement** les modes (route, mer, air, rail), sélectionne les transporteurs, décide de grouper ou non la marchandise avec celle d'autres clients, et pilote la gestion documentaire de l'opération.

Cette liberté de choix des voies et des moyens est la première signature du métier : le commettant achète un acheminement réussi, pas une liste de prestations imposées.

## En son nom propre, sur un résultat

Deuxième signature : le commissionnaire s'engage **en son nom propre**. Ce n'est pas un porte-voix du client : c'est lui qui contracte avec les transporteurs, lui qui facture un prix global, lui qui répond du bon acheminement. Vis-à-vis du commettant, il s'engage sur un **résultat** : la marchandise arrivée à destination dans les conditions convenues.

| Acteur | Ce qu'il fait | Ce sur quoi il s'engage |
| --- | --- | --- |
| L'entreprise cliente (commettant) | Exprime un besoin de transport | Payer le prix convenu, remettre la marchandise |
| Le commissionnaire | Conçoit et organise l'acheminement, en son nom propre | Le résultat : la marchandise à destination |
| Le transporteur | Déplace physiquement la marchandise avec ses moyens | L'exécution du déplacement qui lui est confié |

> 📌 **À retenir**
> Trois expressions résument le métier : **organiser** (concevoir la solution de bout en bout), **librement** (choix des voies et des moyens), **en son nom propre** (c'est lui qui s'engage). Retirez un seul de ces trois piliers et vous n'êtes plus face à un commissionnaire.

## Une mission type, étape par étape

:::flow
1. Demande | Le commettant exprime son besoin (marchandise, origine, destination, délai)
2. Conception | Choix des modes, des transporteurs, groupage éventuel
3. Achat | Contrats passés avec les transporteurs, en son nom propre
4. Pilotage | Suivi de l'acheminement, gestion documentaire, traitement des aléas
5. Livraison | Marchandise remise au destinataire, preuve de livraison, facturation globale
:::

## Les métiers réels derrière le statut

Le statut de commissionnaire recouvre des activités concrètes très différentes :

- **La commission de transport « classique »** : organiser des acheminements nationaux ou européens, principalement routiers, pour des industriels et des distributeurs.
- **L'organisation de transports internationaux** : bâtir des solutions porte-à-porte combinant pré-acheminement routier, traversée maritime ou aérienne et post-acheminement, avec la gestion documentaire associée.
- **Le groupage** : consolider les envois de plusieurs clients dans une même unité de transport (camion, conteneur) : c'est le cœur économique de la messagerie et du groupage maritime.
- **L'opération multimodale** : concevoir des chaînes combinant plusieurs modes (rail-route, fleuve-mer) sous une responsabilité unique.

> 💡 **Astuce**
> Sur le terrain, les entreprises s'appellent rarement « commissionnaire » : elles se présentent comme transitaire, freight forwarder, groupeur, organisateur de transport. Ce qui compte n'est pas le nom commercial mais la réalité de l'opération : qui choisit, qui s'engage, en quel nom. C'est tout l'objet de la leçon suivante.

## Ce que le métier exige

Organiser en son nom propre, c'est porter la promesse entière. Le commissionnaire doit connaître les modes et leurs contraintes, les transporteurs fiables, les documents exigés, les délais réalistes. Un transporteur défaillant, un document manquant, une correspondance ratée : c'est SA responsabilité qui est en jeu devant le client, même si la faute matérielle est celle d'un tiers qu'il a choisi.

> ❌ **Piège à éviter**
> Croire qu'« organiser » est plus léger que « transporter ». C'est l'inverse : le transporteur répond de son déplacement ; le commissionnaire répond de TOUTE la chaîne qu'il a construite, y compris des entreprises qu'il s'est substituées.

## ✅ Synthèse

- Le commissionnaire **organise librement** le transport de bout en bout pour son client, le **commettant**.
- Il s'engage **en son nom propre** sur un **résultat**, pas sur une liste de moyens.
- Métiers réels : commission classique, organisation de transports internationaux, **groupage**, opérations **multimodales**.
- Différence fondamentale avec le transporteur : l'un déplace avec ses moyens, l'autre conçoit la chaîne et en répond entièrement.$mft$,
    $mft$Le commissionnaire organise librement le transport de bout en bout pour le commettant, s'engage en son nom propre sur un résultat, et recouvre des métiers réels : commission classique, organisation internationale, groupage, multimodal.$mft$,
    1, 45) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : Les frontières juridiques ────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'frontieres-juridiques',
    'Transporteur, mandataire, courtier : où passe la frontière ?',
    $mft$> 🎯 **Objectifs**
> - Distinguer les quatre acteurs : transporteur, commissionnaire, mandataire, courtier.
> - Maîtriser la méthode du faisceau d'indices utilisée par les juges.
> - Mesurer les conséquences de la qualification sur la responsabilité.

## Quatre acteurs, quatre régimes

Autour d'une même expédition peuvent intervenir quatre professionnels aux statuts très différents. Les confondre coûte cher, car la responsabilité de chacun n'a rien à voir.

| Acteur | Agit... | Liberté d'organisation | Répond de... |
| --- | --- | --- | --- |
| Transporteur | En son nom, avec ses moyens | Aucune : il exécute le déplacement confié | Sa prestation de voiturier |
| Commissionnaire | En son nom propre | Totale : libre choix des voies et moyens | Son fait personnel ET le fait de ses substitués |
| Mandataire (transitaire) | Au nom et pour le compte du client | Réduite : il suit les instructions | Ses seules fautes personnelles prouvées |
| Courtier | En intermédiaire | Aucune : il met en relation | Sa mission de rapprochement |

Le **transporteur** déplace la marchandise avec ses véhicules et ses équipes : c'est la responsabilité de voiturier. Le **commissionnaire** organise en son nom propre : il porte l'opération entière. Le **mandataire**, souvent appelé transitaire, est un intermédiaire transparent : il agit au nom du client, exécute ses instructions (réserver telle place sur tel navire, accomplir telle formalité) et ne répond que de ses fautes propres : une erreur de réservation, un document mal transmis. Le **courtier**, lui, se contente de mettre en relation un chargeur et un transporteur : une fois le contact noué, il sort de la scène.

> ⚠️ **Attention**
> La différence décisive tient à la responsabilité : le commissionnaire répond du fait des transporteurs qu'il s'est substitués, même sans faute de sa part ; le mandataire ne répond que de ses fautes personnelles. Une même avarie peut donc être indemnisée par l'un et ne pas être reprochée à l'autre.

## La qualification au faisceau d'indices

Comment savoir si une entreprise est commissionnaire ou simple mandataire ? Pas en lisant le titre du contrat. Les juges qualifient l'opération d'après un **faisceau d'indices**, c'est-à-dire un ensemble de signes convergents :

- la **liberté d'organisation** : l'entreprise choisit-elle elle-même les modes, les itinéraires, les transporteurs ? Ou exécute-t-elle des instructions précises ?
- le **prix forfaitaire global** : facture-t-elle un prix unique couvrant toute l'opération ? Ou refacture-t-elle des débours au réel, plus des honoraires d'intermédiaire ?
- l'**engagement en nom propre** : contracte-t-elle avec les transporteurs en son nom ? Ou au nom de son client ?

Quand les trois indices pointent vers l'organisation libre, le forfait et le nom propre, la qualification de commission de transport s'impose : quel que soit le nom que les parties ont donné au contrat.

> 🔍 **Focus jurisprudence**
> Les tribunaux requalifient régulièrement : un contrat intitulé « mandat de transit » ou « prestations logistiques » est jugé contrat de commission dès lors que l'opérateur choisissait librement ses transporteurs et facturait un forfait global en son nom. À l'inverse, un professionnel qui se présentait comme commissionnaire a pu être jugé simple mandataire parce qu'il suivait pas à pas les instructions de son client. L'intitulé ne protège personne : la réalité de l'opération commande.

## Pourquoi la frontière compte autant

La qualification détermine tout ce qui suit :

- **qui indemnise le client** en cas de perte ou d'avarie : le commissionnaire indemnise puis se retourne contre son substitué ; le mandataire renvoie le client vers le transporteur, sauf faute personnelle démontrée ;
- **le régime de responsabilité** applicable au litige, et la manière dont il se plaide ;
- **la structure de la rémunération** : marge intégrée dans un forfait, ou honoraires transparents d'intermédiaire.

> ❌ **Piège à éviter**
> Se croire protégé par une clause « le prestataire agit en qualité de simple mandataire ». Si, dans les faits, vous choisissez librement les transporteurs et facturez un forfait en votre nom, le juge vous traitera en commissionnaire, avec la responsabilité qui va avec : y compris pour la faute d'un transporteur que vous n'avez jamais rencontré.

## ✅ Synthèse

- **Transporteur** : déplace avec ses moyens. **Commissionnaire** : organise librement en son nom propre. **Mandataire** : intermédiaire transparent au nom du client. **Courtier** : met en relation.
- La qualification se fait au **faisceau d'indices** : liberté d'organisation, prix forfaitaire global, engagement en nom propre. Jamais à l'intitulé du contrat.
- Conséquence majeure : le commissionnaire répond de **son fait ET du fait de ses substitués** ; le mandataire, de ses seules fautes propres.$mft$,
    $mft$Les quatre statuts (transporteur, commissionnaire, mandataire, courtier), la qualification au faisceau d'indices (liberté d'organisation, forfait global, nom propre) et ses conséquences sur la responsabilité.$mft$,
    2, 50) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : L'accès à la profession ──────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'acces-a-la-profession',
    'Accéder à la profession : un cadre réformé, à vérifier',
    $mft$> 🎯 **Objectifs**
> - Connaître l'histoire du cadre d'accès : capacité professionnelle, examen, registre.
> - Comprendre ce que la réforme récente a changé et ce qu'elle n'a pas changé.
> - Identifier les trois exigences qui demeurent : professionnalisme, responsabilité, assurance.

## Un cadre historique bâti sur l'autorisation

Pendant des décennies, l'accès à la profession de commissionnaire de transport a reposé en France sur une logique d'autorisation préalable, cousine de celle des transporteurs. Le parcours type se déroulait ainsi :

:::timeline
1. **La capacité professionnelle** : le candidat justifiait d'une attestation de capacité professionnelle de commissionnaire de transport, obtenue notamment par la réussite d'un examen, ou par des voies d'équivalence (diplômes, expérience).
2. **L'inscription au registre** : l'entreprise était inscrite au registre des commissionnaires de transport tenu par l'administration.
3. **L'exercice sous contrôle** : l'inscription conditionnait le droit d'exercer et pouvait être remise en cause.
:::

La logique était claire : celui qui organise des transports en son nom propre engage sa responsabilité sur des chaînes entières ; la collectivité vérifiait donc en amont ses compétences.

## La réforme : la fin du registre

Ce cadre a été **réformé récemment** : l'inscription obligatoire au **registre des commissionnaires a été supprimée**. Le parcours historique « examen de capacité puis inscription au registre » ne décrit donc plus le régime applicable aujourd'hui.

> ⚠️ **Point de vigilance majeur (à vérifier)**
> Le régime d'accès en vigueur doit être **vérifié auprès de votre formateur ou de la DREAL** de votre région au moment de votre projet. Cette leçon fait volontairement le choix de ne détailler aucune modalité chiffrée ni aucune procédure précise : le cadre est en pleine évolution et un détail appris aujourd'hui pourrait être faux demain. Retenez l'histoire et les principes ; vérifiez les modalités à la source officielle.

> 💡 **Astuce**
> Posez vos questions par écrit (une attestation est-elle exigée ? un enregistrement ? sous quelle forme et auprès de qui ?) et conservez les réponses officielles obtenues : elles sécurisent votre dossier de création et prouvent votre diligence.

## Ce qui demeure, quel que soit le régime

La disparition d'une formalité n'a pas allégé le métier. Trois exigences demeurent entières, et ce sont elles que ce module vous demande de retenir.

### Le professionnalisme

Organiser des chaînes de transport suppose des compétences réelles et entretenues : connaître les modes et leurs contraintes, les documents de transport, les acteurs fiables, les délais réalistes, les usages du commerce international. Les chargeurs confient leurs flux à des professionnels crédibles : la compétence est votre premier actif commercial, avec ou sans registre.

### La responsabilité contractuelle lourde

Le cœur du statut n'a pas bougé : le commissionnaire s'engage en son nom propre sur un résultat et répond de son fait comme du fait de ses substitués (leçon 2). Un dossier d'avarie sur une chaîne complète, un client industriel qui réclame la valeur d'une expédition entière : la facture peut être sans commune mesure avec la marge du dossier concerné.

### L'assurance responsabilité civile professionnelle

Conséquence directe : la **RC professionnelle est indispensable**. Elle couvre l'entreprise contre les conséquences financières de sa responsabilité d'organisateur. Avant le premier dossier, le futur commissionnaire fait le tour de ses risques avec un assureur ou un courtier d'assurance spécialisé : nature des marchandises, zones desservies, modes utilisés, montants engagés.

> ❌ **Piège à éviter**
> Confondre la fin du registre avec une dérégulation du métier. La formalité d'accès a changé ; la responsabilité, elle, est intacte. Exercer sans RC professionnelle, c'est jouer la survie de l'entreprise sur chaque expédition.

## ✅ Synthèse

- Historique : attestation de **capacité professionnelle** de commissionnaire (examen, équivalences) puis inscription au **registre des commissionnaires**.
- La réforme récente a **supprimé le registre** : le régime d'accès en vigueur est **à vérifier auprès du formateur ou de la DREAL**.
- Demeurent, quel que soit le régime : le **professionnalisme**, la **responsabilité contractuelle lourde**, la **RC professionnelle indispensable**.$mft$,
    $mft$L'histoire du cadre d'accès (capacité professionnelle, examen, registre), la réforme récente qui a supprimé le registre (régime en vigueur à vérifier auprès du formateur ou de la DREAL), et ce qui demeure : professionnalisme, responsabilité lourde, RC professionnelle.$mft$,
    3, 40) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : La place dans la chaîne ──────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'place-dans-la-chaine',
    'La place du commissionnaire dans la chaîne logistique',
    $mft$> 🎯 **Objectifs**
> - Cartographier une opération type, du chargeur au destinataire.
> - Formuler ce que le client achète : un interlocuteur, un prix, une responsabilité.
> - Comprendre le modèle économique du métier et les tendances qui le transforment.

## La cartographie d'une opération type

:::flow
1. Chargeur | Industriel ou distributeur : exprime le besoin et remet la marchandise
2. Commissionnaire | Conçoit la solution, achète le transport, pilote et documente
3. Transporteurs | Route, mer, air : chacun exécute son segment de la chaîne
4. Destinataire | Réceptionne, vérifie, émarge
:::

Exemple : un fabricant de mobilier de la région nantaise vend à une enseigne de Turin. Le commissionnaire organise le pré-acheminement routier jusqu'à sa plateforme, groupe la marchandise avec d'autres envois vers l'Italie, confie le trajet principal à un transporteur partenaire et fait livrer par un distributeur local. Le fabricant, lui, n'a eu qu'un devis, un contact et un suivi.

## Ce que le client achète vraiment

Passer par un commissionnaire, c'est acheter trois « UN » :

| Ce que le client achète | Ce que cela lui évite |
| --- | --- |
| **UN interlocuteur** | Coordonner lui-même plusieurs transporteurs, relancer, arbitrer les aléas |
| **UN prix** | Additionner des devis segment par segment, subir les à-côtés imprévus |
| **UNE responsabilité** | Chercher le responsable dans la chaîne en cas de perte ou d'avarie |

Le troisième « UN » est le plus précieux : en cas d'incident, le client n'a pas à démêler qui, du transporteur routier ou du manutentionnaire, a causé le dommage : il se tourne vers son commissionnaire, qui répond de la chaîne qu'il a construite et exerce ensuite ses recours.

## Le modèle économique : acheter, organiser, revendre

Le commissionnaire vit de la différence entre le prix qu'il vend à son client et le coût du transport qu'il achète, plus la valeur de son organisation. Deux leviers structurent la marge :

- **l'achat de transport** : des volumes réguliers, des paiements fiables et des relations dans la durée obtiennent de meilleurs prix qu'un chargeur occasionnel ;
- **le groupage** : « vendre au colis, acheter au camion ». En consolidant les envois de plusieurs clients dans une même unité, le groupeur vend au détail une capacité achetée en gros : sa marge dépend directement du taux de remplissage.

> 📌 **À retenir**
> Le nerf du métier n'est pas le camion, mais la **capacité**. Le commissionnaire qui a sécurisé, par des relations longues avec ses transporteurs, des capacités réservées à l'année tient ses engagements même quand le marché se tend ; celui qui achète tout au jour le jour subit les prix et les défaillances.

## Des relations longues avec les transporteurs

Le transporteur n'est pas un fournisseur interchangeable : c'est lui qui exécute la promesse. Les commissionnaires solides construisent un réseau de partenaires réguliers : engagements de volumes contre capacité réservée, exigences de qualité partagées (ponctualité, documents, remontée d'information), traitement correct (prévisibilité, paiements). Un réseau fidèle est un actif aussi stratégique que le portefeuille clients.

## Les tendances qui transforment le métier

**La digitalisation.** Les bourses de fret mettent en relation offres et demandes de transport en quelques clics ; les plateformes de visibilité donnent au client la position et le statut de ses flux en temps réel. Le commissionnaire y gagne des outils (sourcing de capacité pour les pointes, suivi automatisé) et y affronte une exigence nouvelle : le client attend désormais l'information sans avoir à la demander.

**Les attentes RSE des chargeurs.** Les grands donneurs d'ordre intègrent l'empreinte environnementale dans leurs appels d'offres : mesure des émissions des flux, solutions moins émettrices (massification, report modal quand il est pertinent), plans de progrès documentés. Pour le commissionnaire, la RSE devient un critère de sélection au même titre que le prix et le délai.

> 🎓 **Pour aller plus loin**
> Le commissionnaire qui combine un réseau de transporteurs fidèles, des outils numériques de visibilité et une offre RSE crédible coche les trois cases des appels d'offres modernes : c'est le profil vers lequel le métier converge.

## ✅ Synthèse

- Chaîne type : **chargeur → commissionnaire → transporteurs (route, mer, air) → destinataire**.
- Le client achète **UN interlocuteur, UN prix, UNE responsabilité** de bout en bout.
- Modèle économique : **achat de transport + marge** ; pour le groupage : **vendre au colis, acheter au camion** (le remplissage fait la marge).
- Actif stratégique : des relations longues et de la **capacité réservée** chez les transporteurs.
- Tendances : **digitalisation** (bourses de fret, visibilité temps réel) et **attentes RSE** des chargeurs.$mft$,
    $mft$L'opération type (chargeur, commissionnaire, transporteurs, destinataire), les trois « UN » achetés par le client, le modèle économique (marge, groupage, capacité réservée) et les tendances : digitalisation et RSE.$mft$,
    4, 45) RETURNING id INTO v_l4;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : Le métier de commissionnaire',
    'Vérifiez le module 1 : le métier d''organisateur, les frontières juridiques, l''accès à la profession et la place dans la chaîne.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Une PME confie à la société Translog l'acheminement de 26 palettes de Lille à Milan. Translog choisit seule les transporteurs et l'itinéraire, facture un prix global unique et s'engage sur la livraison de vendredi. Quel est le statut de Translog ?$mft$,
    $mft$[
      {"id":"a","label":"Commissionnaire de transport : elle organise librement, en son nom propre, contre un prix forfaitaire global","is_correct":true},
      {"id":"b","label":"Transporteur routier, puisque la marchandise voyage par la route","is_correct":false},
      {"id":"c","label":"Mandataire, puisqu'elle agit pour le compte de la PME","is_correct":false},
      {"id":"d","label":"Courtier, puisqu'elle a trouvé des transporteurs","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['commissionnaire','module-1','qcm-v1'], 'COMM-M1-QCM-01', false,
    $mft$Liberté d'organisation, engagement en nom propre et prix forfaitaire global : les trois signatures de la commission. Le transporteur déplace avec ses moyens, le mandataire suit des instructions, le courtier se borne à mettre en relation.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un professionnel met en relation un chargeur de céréales et un transporteur fluvial, perçoit une rémunération pour ce rapprochement, puis sort complètement de l'opération. Comment le qualifier ?$mft$,
    $mft$[
      {"id":"a","label":"Courtier : il se borne à mettre en relation les parties, sans organiser ni s'engager","is_correct":true},
      {"id":"b","label":"Commissionnaire, puisqu'il a trouvé le transporteur","is_correct":false},
      {"id":"c","label":"Transporteur fluvial, par extension de l'opération","is_correct":false},
      {"id":"d","label":"Mandataire du transporteur, chargé de ses formalités","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['commissionnaire','module-1','qcm-v1'], 'COMM-M1-QCM-02', false,
    $mft$Le courtier rapproche les parties puis disparaît de la scène : aucune organisation, aucun engagement en nom propre. Le commissionnaire organise et s'engage ; le mandataire exécute des instructions ; le transporteur déplace.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Un directeur logistique justifie le recours à un commissionnaire pour ses flux export plutôt que de contracter lui-même avec quatre transporteurs. Quel résumé exact peut-il donner de ce qu'il achète ?$mft$,
    $mft$[
      {"id":"a","label":"Un interlocuteur unique, un prix unique et une responsabilité unique sur toute la chaîne","is_correct":true},
      {"id":"b","label":"Un tarif toujours inférieur à celui des transporteurs contactés en direct","is_correct":false},
      {"id":"c","label":"Une exonération de ses propres obligations de chargeur","is_correct":false},
      {"id":"d","label":"La propriété des véhicules utilisés pendant l'opération","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['commissionnaire','module-1','qcm-v1'], 'COMM-M1-QCM-03', false,
    $mft$Les trois « UN » sont la proposition de valeur du métier. Le prix n'est pas mécaniquement plus bas, le chargeur conserve ses obligations propres, et le commissionnaire ne possède pas les véhicules : il organise.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Un candidat à la création d'entreprise vous affirme : « il suffit de s'inscrire au registre des commissionnaires pour exercer ». Que lui répondez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Ce registre a été supprimé par une réforme récente : le régime d'accès en vigueur doit être vérifié auprès de la DREAL ou du formateur","is_correct":true},
      {"id":"b","label":"Il a raison : l'inscription au registre reste la seule formalité exigée","is_correct":false},
      {"id":"c","label":"Aucune exigence de professionnalisme ni d'assurance ne subsiste pour ce métier","is_correct":false},
      {"id":"d","label":"L'inscription se fait désormais auprès de la mairie du siège social","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['commissionnaire','module-1','qcm-v1'], 'COMM-M1-QCM-04', false,
    $mft$L'ancienne inscription au registre a disparu, mais professionnalisme, responsabilité lourde et RC professionnelle demeurent : les modalités actuelles se vérifient à la source officielle, pas dans un manuel daté.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un contrat s'intitule « mandat de transit ». Dans les faits, l'opérateur choisit librement les transporteurs, facture un forfait global et contracte en son nom. Une avarie survient : comment le juge qualifiera-t-il l'opération ?$mft$,
    $mft$[
      {"id":"a","label":"Contrat de commission de transport : la qualification suit le faisceau d'indices, pas l'intitulé","is_correct":true},
      {"id":"b","label":"Mandat, puisque c'est le titre librement choisi par les parties","is_correct":false},
      {"id":"c","label":"Contrat de courtage, faute de précision suffisante","is_correct":false},
      {"id":"d","label":"Contrat de location de véhicule, car un camion a été utilisé","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-1','qcm-v1'], 'COMM-M1-QCM-05', false,
    $mft$Liberté d'organisation + forfait global + nom propre : les trois indices convergent vers la commission. L'intitulé du contrat n'a aucun pouvoir de qualification devant le juge.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Le transporteur routier auquel le commissionnaire Oceanlog a confié un lot perd trois palettes, sans aucune faute d'Oceanlog dans son choix ni ses instructions. Quelle affirmation décrit correctement la situation d'Oceanlog ?$mft$,
    $mft$[
      {"id":"a","label":"Oceanlog doit répondre devant son commettant : le commissionnaire répond du fait de ses substitués, puis exerce son recours contre le transporteur","is_correct":true},
      {"id":"b","label":"Oceanlog n'est pas responsable, faute de faute personnelle démontrée","is_correct":false},
      {"id":"c","label":"Oceanlog n'est responsable que si le transporteur est insolvable","is_correct":false},
      {"id":"d","label":"Oceanlog est responsable uniquement s'il avait trouvé ce transporteur sur une bourse de fret","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-1','qcm-v1'], 'COMM-M1-QCM-06', false,
    $mft$Répondre de son fait ET du fait de ses substitués est la marque du statut : c'est justement la responsabilité unique que le client achète. L'absence de faute personnelle exonérerait un mandataire, pas un commissionnaire.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$La société Grouplog collecte chaque jour les envois de dizaines de PME de sa région, les consolide par destination dans des camions complets et organise leur réexpédition. Comment appelle-t-on cette activité ?$mft$,
    $mft$[
      {"id":"a","label":"Le groupage : consolider les envois de plusieurs clients dans une même unité de transport","is_correct":true},
      {"id":"b","label":"Le dégroupage, puisque les envois viennent de clients différents","is_correct":false},
      {"id":"c","label":"La location de véhicules industriels avec conducteur","is_correct":false},
      {"id":"d","label":"Le courtage de fret entre PME","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-1','qcm-v1'], 'COMM-M1-QCM-07', false,
    $mft$Le groupage consolide au départ ; le dégroupage est l'opération inverse, à l'arrivée. Grouplog organise et s'engage : elle ne loue pas de véhicules et ne se contente pas de mettre en relation.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Un groupeur achète un camion complet Lille-Barcelone à un transporteur partenaire et revend cette capacité « à la palette » à douze clients différents. D'où vient sa marge ?$mft$,
    $mft$[
      {"id":"a","label":"De la massification : le prix de vente cumulé des douze lots dépasse le prix d'achat du camion complet","is_correct":true},
      {"id":"b","label":"D'une subvention publique versée pour chaque camion rempli","is_correct":false},
      {"id":"c","label":"Des pénalités de retard facturées aux transporteurs","is_correct":false},
      {"id":"d","label":"De la revente du carburant économisé sur le trajet","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-1','qcm-v1'], 'COMM-M1-QCM-08', false,
    $mft$« Vendre au colis, acheter au camion » : la marge du groupage naît du remplissage de la capacité achetée en gros. Les trois distracteurs ne décrivent aucun revenu réel du groupeur.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un transitaire du Havre réserve, sur instructions précises de son client et au nom de celui-ci, une place sur un navire désigné par ce client. La compagnie maritime égare le conteneur. Le client peut-il obtenir réparation auprès du transitaire ?$mft$,
    $mft$[
      {"id":"a","label":"Non, sauf faute personnelle prouvée : mandataire transparent, il ne répond pas du fait de la compagnie maritime","is_correct":true},
      {"id":"b","label":"Oui : tout intermédiaire répond des transporteurs qu'il fait intervenir","is_correct":false},
      {"id":"c","label":"Oui, dès lors qu'il a perçu une rémunération sur l'opération","is_correct":false},
      {"id":"d","label":"Non, car la marchandise voyageait aux risques exclusifs du client dans tous les cas","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-1','qcm-v1'], 'COMM-M1-QCM-09', false,
    $mft$Au nom du client, sur ses instructions : les indices du mandat. Le mandataire ne répond que de ses fautes propres (erreur de réservation, document mal transmis) ; seule la commission engage sur le fait des substitués.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Deux dossiers sur votre bureau. Dossier A : l'opérateur refacture les débours de transport au réel, ajoute des honoraires et suit ligne à ligne les instructions du client. Dossier B : l'opérateur facture un forfait global et choisit seul ses transporteurs, en son nom. Quelle lecture est correcte ?$mft$,
    $mft$[
      {"id":"a","label":"Le dossier A présente les indices du mandat, le dossier B ceux de la commission de transport","is_correct":true},
      {"id":"b","label":"Les deux sont des commissions : il y a organisation de transport dans les deux cas","is_correct":false},
      {"id":"c","label":"Les deux sont des mandats : seul l'intitulé du contrat permettrait de trancher","is_correct":false},
      {"id":"d","label":"Le dossier A est une commission, car les honoraires constituent une marge déguisée","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['commissionnaire','module-1','qcm-v1'], 'COMM-M1-QCM-10', false,
    $mft$Débours au réel + honoraires + instructions suivies = intermédiaire transparent ; forfait global + libre choix + nom propre = commission. L'intitulé, lui, ne tranche jamais : c'est la réalité de chaque dossier qui parle.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Haute saison : le marché du transport se tend et les prix au coup par coup flambent. Le commissionnaire Nordfret honore pourtant tous ses engagements sans surcoût majeur. Quelle pratique explique le plus probablement cette résistance ?$mft$,
    $mft$[
      {"id":"a","label":"Des relations longues avec ses transporteurs, incluant des capacités réservées à l'année","is_correct":true},
      {"id":"b","label":"Le recours exclusif aux bourses de fret, au jour le jour","is_correct":false},
      {"id":"c","label":"La sous-traitance systématique au moins-disant du moment","is_correct":false},
      {"id":"d","label":"Le report de tous les flux sur l'aérien, réputé moins cher","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['commissionnaire','module-1','qcm-v1'], 'COMM-M1-QCM-11', false,
    $mft$La capacité réservée auprès de partenaires réguliers sécurise les pointes d'activité. Le tout-spot expose exactement à l'inverse (prix et défaillances), et l'aérien est un mode coûteux, pas un refuge économique.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Une jeune société d'organisation de transport estime que, le registre des commissionnaires ayant disparu, l'assurance responsabilité civile professionnelle est devenue superflue. Votre analyse ?$mft$,
    $mft$[
      {"id":"a","label":"Erreur : la responsabilité contractuelle du métier reste lourde (fait personnel et fait des substitués) et la RC professionnelle demeure indispensable","is_correct":true},
      {"id":"b","label":"Exact : sans registre, il n'y a plus de responsabilité à assurer","is_correct":false},
      {"id":"c","label":"Exact : la responsabilité pèse désormais uniquement sur les transporteurs substitués","is_correct":false},
      {"id":"d","label":"Erreur, mais seulement pour les flux internationaux : en national, l'assurance est inutile","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['commissionnaire','module-1','qcm-v1'], 'COMM-M1-QCM-12', false,
    $mft$La réforme a touché la formalité d'accès, pas le régime de responsabilité : un seul dossier d'avarie sur une chaîne organisée peut menacer la survie d'une structure non assurée, en national comme à l'international.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Dans un dossier de commission de transport, comment appelle-t-on le client donneur d'ordre pour le compte duquel le commissionnaire organise l'acheminement ?$mft$,
   $mft$Le commettant.$mft$,
   2, 'facile', ARRAY['commissionnaire','module-1','question-courte'], 'COMM-M1-QC-01', false,
   $mft$Le vocabulaire de base du contrat de commission.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Un chargeur confie un flux Lyon-Rotterdam sans imposer ni mode ni transporteur, contre un prix global. Sur quoi porte l'engagement de l'organisateur : les moyens ou le résultat ?$mft$,
   $mft$Sur le résultat : il s'engage en son nom propre à ce que la marchandise arrive à destination, en choisissant librement les voies et les moyens.$mft$,
   2, 'facile', ARRAY['commissionnaire','module-1','question-courte'], 'COMM-M1-QC-02', false,
   $mft$Engagement de résultat + liberté d'organisation : les signatures du métier.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Résumez en trois « UN » ce qu'un chargeur achète lorsqu'il confie sa chaîne de transport à un commissionnaire.$mft$,
   $mft$Un interlocuteur unique, un prix unique, une responsabilité unique de bout en bout.$mft$,
   2, 'facile', ARRAY['commissionnaire','module-1','question-courte'], 'COMM-M1-QC-03', false,
   $mft$Les trois « UN » attendus.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Citez les trois indices principaux du faisceau qui conduit un juge à qualifier une opération de commission de transport.$mft$,
   $mft$La liberté d'organisation (choix des voies, des moyens et des transporteurs), le prix forfaitaire global, l'engagement en nom propre.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-1','question-courte'], 'COMM-M1-QC-04', false,
   $mft$Les trois indices, l'intitulé du contrat ne comptant pas.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Le transporteur choisi par un commissionnaire endommage la marchandise sans aucune faute du commissionnaire. Le commettant peut-il demander réparation au commissionnaire ?$mft$,
   $mft$Oui : le commissionnaire répond de son fait et du fait de ses substitués ; il indemnise son commettant puis exerce son recours contre le transporteur.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-1','question-courte'], 'COMM-M1-QC-05', false,
   $mft$La responsabilité du fait des substitués, avec le recours en second temps.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Quelle différence essentielle de responsabilité sépare le mandataire (transitaire) du commissionnaire de transport ?$mft$,
   $mft$Le mandataire, intermédiaire transparent agissant au nom du client, ne répond que de ses fautes personnelles ; le commissionnaire répond aussi du fait des transporteurs qu'il s'est substitués.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-1','question-courte'], 'COMM-M1-QC-06', false,
   $mft$Fautes propres d'un côté, fait des substitués de l'autre.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un confrère vous décrit avec assurance le régime d'accès à la profession qu'il a appris il y a dix ans, registre à l'appui. Quel réflexe professionnel adoptez-vous avant de créer votre structure ?$mft$,
   $mft$Vérifier le régime en vigueur auprès du formateur ou de la DREAL : la réforme récente a supprimé l'inscription au registre des commissionnaires et l'ancien parcours ne décrit plus le droit applicable.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-1','question-courte'], 'COMM-M1-QC-07', false,
   $mft$Le réflexe de vérification à la source officielle.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Expliquez en une phrase la formule « vendre au colis, acheter au camion ».$mft$,
   $mft$Le groupeur achète la capacité d'un camion complet à un transporteur puis la revend au détail (au colis, à la palette) à plusieurs clients : la marge naît de la massification et du taux de remplissage.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-1','question-courte'], 'COMM-M1-QC-08', false,
   $mft$Le modèle économique du groupage en une phrase.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Pourquoi intituler un contrat « prestations de transit » ne met-il pas l'opérateur à l'abri d'une requalification en commission de transport ?$mft$,
   $mft$Parce que le juge qualifie d'après la réalité de l'opération, au faisceau d'indices (liberté d'organisation, prix forfaitaire global, engagement en nom propre), et non d'après l'intitulé choisi par les parties.$mft$,
   2, 'difficile', ARRAY['commissionnaire','module-1','question-courte'], 'COMM-M1-QC-09', false,
   $mft$La réalité de l'opération commande, jamais le titre.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Citez deux tendances de fond qui transforment actuellement le métier de commissionnaire et, pour chacune, une conséquence concrète pour l'offre de service.$mft$,
   $mft$La digitalisation (bourses de fret, visibilité en temps réel : le client attend un suivi permanent de ses flux) et les attentes RSE des chargeurs (mesure des émissions, solutions moins émettrices et reporting à intégrer dans les offres).$mft$,
   2, 'difficile', ARRAY['commissionnaire','module-1','question-courte'], 'COMM-M1-QC-10', false,
   $mft$Deux tendances + une conséquence chacune.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$« Le commissionnaire vend de l'organisation, pas des camions. » Expliquez cette formule : ce que fait concrètement un commissionnaire pour son commettant, ce qui le distingue du transporteur, et les métiers réels qui vivent sous ce statut.$mft$,
   $mft$Réponse modèle. Le commissionnaire ne déplace pas la marchandise : il conçoit et pilote son acheminement de bout en bout pour son client, le commettant. Concrètement : il analyse le besoin (marchandise, origine, destination, délai), choisit librement les modes (route, mer, air, rail) et les transporteurs, décide de grouper ou non l'envoi avec ceux d'autres clients, passe les contrats de transport en son nom propre, pilote l'exécution, gère la documentation de l'opération et facture un prix global. La distinction avec le transporteur est fondamentale : le transporteur déplace la marchandise avec ses propres moyens et répond de ce déplacement ; le commissionnaire s'engage en son nom propre sur le résultat, la marchandise à destination, et répond de toute la chaîne qu'il a construite, y compris du fait des transporteurs qu'il s'est substitués. Sous ce statut vivent des métiers concrets : la commission de transport classique (flux nationaux et européens), l'organisation de transports internationaux porte-à-porte, le groupage (consolider les envois de plusieurs clients dans une même unité de transport) et l'opération multimodale sous responsabilité unique.$mft$,
   $mft$Barème /5 : rôle d'organisateur de bout en bout pour le commettant, avec au moins trois tâches concrètes (1,5 pt) ; liberté de choix des voies et des moyens (1 pt) ; engagement en nom propre sur un résultat, distinct du transporteur qui déplace (1,5 pt) ; au moins deux métiers réels cités (groupage, organisation internationale, multimodal) (1 pt). Erreurs fréquentes : présenter le commissionnaire comme un transporteur sans camions ; oublier l'engagement en nom propre.$mft$,
   5, 'facile', ARRAY['commissionnaire','module-1','question-redigee'], 'COMM-M1-QR-01', false,
   $mft$Le cœur du métier reformulé avec ses trois piliers.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Décrivez l'opération type d'un flux confié à un commissionnaire, du chargeur au destinataire, puis expliquez ce que le client achète réellement en passant par lui plutôt qu'en contractant lui-même avec chaque transporteur.$mft$,
   $mft$Réponse modèle. La chaîne type : le chargeur (industriel ou distributeur) exprime son besoin et remet la marchandise ; le commissionnaire conçoit la solution, achète le transport en son nom propre, pilote et documente l'opération ; les transporteurs (route, mer, air) exécutent chacun leur segment ; le destinataire réceptionne, vérifie et émarge. Exemple : un fabricant nantais vendant à Turin n'a qu'un devis, un contact et un suivi, pendant que le commissionnaire enchaîne pré-acheminement routier, groupage et livraison locale. Ce que le client achète tient en trois « UN » : UN interlocuteur (plus de coordination de plusieurs transporteurs, de relances ni d'arbitrages d'aléas à sa charge), UN prix (un forfait global au lieu de devis segment par segment avec leurs à-côtés imprévus), UNE responsabilité (en cas de perte ou d'avarie, il n'a pas à démêler qui, dans la chaîne, a causé le dommage : il se tourne vers son commissionnaire, qui répond de la chaîne construite et exerce ensuite ses recours). Ce troisième « UN » est le plus précieux : il transforme un risque diffus, réparti sur plusieurs contrats, en un engagement unique et actionnable.$mft$,
   $mft$Barème /5 : chaîne complète avec le rôle exact de chaque acteur (1,5 pt) ; les trois « UN » explicités (1,5 pt) ; bénéfice concret en cas d'aléa : recours unique vers le commissionnaire, qui se retourne ensuite (1,5 pt) ; exemple ou illustration cohérente (0,5 pt). Erreurs fréquentes : confondre destinataire et client du commissionnaire ; réduire l'apport du commissionnaire au seul prix.$mft$,
   5, 'facile', ARRAY['commissionnaire','module-1','question-redigee'], 'COMM-M1-QR-02', false,
   $mft$La cartographie de l'opération et la proposition de valeur.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Comparez le transporteur, le commissionnaire, le mandataire (transitaire) et le courtier selon trois critères : au nom de qui ils agissent, leur liberté d'organisation, l'étendue de leur responsabilité. Illustrez chaque statut par une situation d'avarie.$mft$,
   $mft$Réponse modèle. Le transporteur agit en son nom avec ses propres moyens ; aucune liberté d'organisation (il exécute le déplacement confié) ; il répond de sa prestation de voiturier : si sa remorque prend l'eau et abîme les cartons, il indemnise ce dommage. Le commissionnaire agit en son nom propre ; liberté totale de choix des voies, des moyens et des transporteurs ; il répond de son fait ET du fait de ses substitués : si le transporteur qu'il a choisi perd des palettes, le commettant se retourne contre lui, à charge de recours. Le mandataire (transitaire) agit au nom et pour le compte du client ; liberté réduite, il exécute des instructions ; il ne répond que de ses fautes personnelles : si la compagnie maritime qu'il a réservée sur ordre du client égare le conteneur, il n'est pas responsable, sauf faute propre (erreur de réservation, document mal transmis). Le courtier agit en intermédiaire ; aucune organisation : il met en relation chargeur et transporteur ; sa responsabilité se limite à sa mission de rapprochement : une avarie pendant le transport ne lui est pas imputable. La ligne de partage majeure : nom propre et fait des substitués d'un côté, transparence et fautes propres de l'autre.$mft$,
   $mft$Barème /5 : les quatre statuts couverts avec les trois critères (2 pts) ; responsabilités exactes, dont l'opposition fait des substitués / fautes propres (2 pts) ; illustrations d'avarie cohérentes avec chaque statut (1 pt). Erreurs fréquentes : confondre mandataire et commissionnaire ; attribuer au courtier une responsabilité sur l'exécution du transport.$mft$,
   5, 'moyen', ARRAY['commissionnaire','module-1','question-redigee'], 'COMM-M1-QR-03', false,
   $mft$Le tableau comparatif des quatre statuts, appliqué à l'avarie.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Cas pratique. La société Fluxor signe avec un chargeur un contrat intitulé « mandat de prestations de transit ». Dans les faits, Fluxor choisit seule les transporteurs, refuse toute instruction sur les itinéraires et facture un forfait global en son nom. Un transporteur qu'elle a choisi détruit une partie de la marchandise. Fluxor oppose au chargeur sa qualité de « simple mandataire ». Analysez : quelle qualification retiendra le juge, sur quels indices, et avec quelles conséquences pour Fluxor ?$mft$,
   $mft$Réponse modèle. Le juge ne s'arrêtera pas à l'intitulé « mandat de prestations de transit » : la qualification se fait au faisceau d'indices, d'après la réalité de l'opération. Ici, les trois indices de la commission sont réunis : liberté d'organisation (Fluxor choisit seule les transporteurs et refuse toute instruction sur les itinéraires), prix forfaitaire global (et non des débours refacturés au réel plus honoraires), engagement en nom propre (Fluxor contracte et facture en son nom). L'opération sera donc requalifiée en commission de transport. Conséquences : Fluxor ne peut pas s'abriter derrière l'absence de faute personnelle, argument qui n'exonère que le mandataire transparent ; en qualité de commissionnaire, elle répond du fait du transporteur qu'elle s'est substitué et doit indemniser le chargeur dans les conditions applicables au dossier ; elle conserve ensuite son recours contre le transporteur fautif, au titre de la responsabilité de celui-ci, et mobilisera sa RC professionnelle. Enseignement pratique : la protection ne vient pas des mots du contrat mais de la cohérence entre le montage juridique, la pratique commerciale et la facturation : qui veut le régime du mandat doit agir en mandataire, réellement.$mft$,
   $mft$Barème /5 : requalification en commission annoncée et justifiée par la méthode du faisceau d'indices (1 pt) ; les trois indices mobilisés sur les faits du cas (2 pts) ; conséquences exactes : responsabilité du fait du substitué, indemnisation du chargeur, recours contre le transporteur (1,5 pt) ; enseignement pratique sur la cohérence contrat/pratique (0,5 pt). Erreurs fréquentes : trancher d'après l'intitulé ; oublier le recours du commissionnaire contre son substitué.$mft$,
   5, 'moyen', ARRAY['commissionnaire','module-1','question-redigee'], 'COMM-M1-QR-04', false,
   $mft$La requalification au faisceau d'indices, déroulée sur un cas.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Cas chiffré. Un groupeur achète un camion complet Lille-Barcelone 1 500 euros à un transporteur partenaire. Le camion peut charger 22 palettes, et le groupeur vend la palette 95 euros à ses clients. Calculez la recette et la marge brute à camion plein, le nombre minimal de palettes vendues pour couvrir l'achat, puis expliquez ce que ce calcul enseigne sur le modèle économique du groupage et sur l'intérêt des relations longues avec les transporteurs.$mft$,
   $mft$Réponse modèle. À camion plein : recette = 22 x 95 = 2 090 euros ; marge brute = 2 090 - 1 500 = 590 euros. Seuil de couverture : 1 500 / 95 = 15,8 : il faut donc vendre 16 palettes (16 x 95 = 1 520 euros) pour couvrir le prix d'achat du camion ; à 15 palettes (1 425 euros), le départ est déficitaire. Enseignements : la marge du groupage naît du remplissage : les six dernières palettes vendues sont presque intégralement de la marge, tandis qu'un camion aux deux tiers plein peut partir à perte ; « vendre au colis, acheter au camion » n'est rentable que si le commercial alimente des flux réguliers et massifiés sur l'axe. D'où l'intérêt des relations longues avec les transporteurs : un prix d'achat stable et une capacité réservée à l'année sécurisent le calcul, là où l'achat au coup par coup en haute saison peut faire flamber le coût du camion et effacer la marge ; en retour, le groupeur apporte au transporteur des volumes prévisibles. Le pilotage du taux de remplissage, axe par axe, est donc l'indicateur central du métier.$mft$,
   $mft$Barème /5 : recette et marge brute exactes (2 090 et 590 euros) (1,5 pt) ; seuil justifié de 16 palettes, et non 15 (1,5 pt) ; lecture du modèle : remplissage, dernières unités très margées, départ partiel à perte (1,5 pt) ; lien avec capacité réservée et relations longues (0,5 pt). Erreurs fréquentes : arrondir le seuil à 15 palettes ; confondre marge brute et bénéfice net (frais de structure non déduits).$mft$,
   5, 'moyen', ARRAY['commissionnaire','module-1','question-redigee'], 'COMM-M1-QR-05', false,
   $mft$L'arithmétique du groupage : remplissage, seuil, marge.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Vous préparez votre installation comme commissionnaire de transport. Construisez votre plan d'action pour sécuriser le volet « accès à la profession et responsabilité » : ce que vous vérifiez, auprès de qui, et ce que vous mettez en place quel que soit le régime en vigueur.$mft$,
   $mft$Réponse modèle. Premier chantier : vérifier le régime d'accès EN VIGUEUR. Le cadre a été réformé récemment (l'inscription au registre des commissionnaires a été supprimée) : je ne me fie ni aux manuels anciens ni aux souvenirs de confrères ; j'interroge par écrit mon formateur et la DREAL de ma région (une attestation est-elle exigée ? un enregistrement ? sous quelle forme ?) et je conserve les réponses officielles : elles documentent mon dossier de création et prouvent ma diligence. Deuxième chantier : l'assurance. La responsabilité du métier reste lourde (engagement en nom propre sur un résultat, fait des substitués) : je souscris une RC professionnelle adaptée AVANT le premier dossier, construite avec un assureur ou un courtier d'assurance spécialisé sur mon profil réel : marchandises visées, zones desservies, modes utilisés, montants engagés. Troisième chantier : le professionnalisme. Je consolide mes compétences (modes et contraintes, documents, délais réalistes) et je construis un premier réseau de transporteurs fiables, car ma promesse reposera sur leur exécution. Enfin, je fais relire mes contrats et conditions de vente par un conseil, pour que ma pratique (facturation, instructions, nom propre) reste cohérente avec le statut que j'assume.$mft$,
   $mft$Barème /5 : vérification du régime à la source officielle (formateur, DREAL) avec mention de la réforme et du registre supprimé (1,5 pt) ; traçabilité écrite des questions et réponses (0,5 pt) ; RC professionnelle souscrite avant le premier dossier, reliée à la responsabilité du fait des substitués (1,5 pt) ; volet compétences et réseau de transporteurs (1 pt) ; cohérence d'ensemble du plan (0,5 pt). Erreurs fréquentes : réciter un régime chiffré périmé au lieu de vérifier ; traiter l'assurance comme une option à reporter.$mft$,
   5, 'moyen', ARRAY['commissionnaire','module-1','question-redigee'], 'COMM-M1-QR-06', false,
   $mft$Le plan d'installation : vérifier, s'assurer, se professionnaliser.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Le commettant Agrofrais réclame au commissionnaire Translog l'indemnisation de six palettes détruites par le transporteur routier que Translog s'était substitué. Déroulez le traitement complet du dossier côté Translog : fondement de la réclamation du client, réponse à lui apporter, recours à préparer contre le transporteur, et pièces à réunir dès le premier jour.$mft$,
   $mft$Réponse modèle. Fondement : Translog a organisé le transport en son nom propre ; il répond de son fait et du fait de ses substitués : la réclamation d'Agrofrais est donc dirigée contre le bon interlocuteur, et Translog ne peut pas renvoyer son client vers le transporteur en invoquant son absence de faute personnelle. Réponse au client : accuser réception sans délai, instruire le dossier (réalité et étendue du dommage) et indemniser dans les conditions applicables au contrat : la responsabilité unique est précisément ce qu'Agrofrais a acheté ; la qualité du traitement du sinistre fait partie de la prestation et conditionne la fidélité du compte. Recours : préparer en parallèle l'action contre le transporteur substitué, responsable de sa prestation de voiturier, et déclarer le dossier aux assureurs concernés (RC professionnelle de Translog, assureur du transporteur), en veillant aux délais de réclamation et de prescription applicables au dossier, à vérifier selon le contrat et le mode. Pièces à réunir dès le premier jour : lettre de voiture et réserves du destinataire, photos et constats, températures ou conditions de transport le cas échéant, contrat et échanges avec le transporteur, valorisation de la marchandise, chronologie écrite des faits. Un dossier documenté au jour un se règle ; un dossier reconstitué des semaines après se plaide.$mft$,
   $mft$Barème /5 : fondement exact : responsabilité du fait des substitués, pas de renvoi du client vers le transporteur (1,5 pt) ; posture client : instruction rapide et indemnisation, la responsabilité unique étant la prestation vendue (1 pt) ; recours contre le voiturier et mobilisation des assureurs, avec vigilance sur les délais applicables (1,5 pt) ; pièces probantes réunies dès le premier jour (1 pt). Erreurs fréquentes : renvoyer le commettant vers le transporteur ; négliger la constitution des preuves immédiate.$mft$,
   5, 'difficile', ARRAY['commissionnaire','module-1','question-redigee'], 'COMM-M1-QR-07', false,
   $mft$Le sinistre côté commissionnaire : indemniser, se retourner, prouver.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Un chargeur industriel majeur lance un appel d'offres : il exige une visibilité en temps réel sur ses flux et un volet RSE documenté (mesure des émissions, plan de progrès). Votre société de commission, organisée « à l'ancienne » (suivi par téléphone et tableurs), veut répondre. Construisez le plan d'action commercial et opérationnel.$mft$,
   $mft$Réponse modèle. Diagnostic : l'écart porte sur deux attentes désormais standard chez les grands chargeurs : l'information en temps réel (le client ne veut plus demander où est son flux) et la preuve environnementale. Volet visibilité : déployer un outil de suivi connecté aux transporteurs (statuts, positions, alertes), en commençant par les partenaires réguliers, qui représentent l'essentiel des flux ; contractualiser avec eux la remontée de données ; réserver les bourses de fret aux pointes, en gardant la main sur la qualité. Volet RSE : mesurer les émissions des flux types du client, proposer des leviers concrets : massification et groupage (meilleur remplissage = moins d'émissions par palette), report modal quand il est pertinent, choix de transporteurs engagés ; formaliser un reporting régulier et un plan de progrès daté, sans promettre ce que les données ne peuvent pas encore prouver. Volet réseau : la crédibilité des deux promesses repose sur les relations longues avec les transporteurs (capacité réservée, exigences partagées, données fournies). Volet commercial : répondre en assumant la trajectoire (existant, jalons, phase pilote sur un périmètre restreint) et rappeler la valeur du métier : un interlocuteur, un prix, une responsabilité, désormais outillés et mesurés.$mft$,
   $mft$Barème /5 : diagnostic honnête de l'écart (0,5 pt) ; visibilité temps réel : outil + remontée de données contractualisée avec les transporteurs réguliers (1,5 pt) ; volet RSE structuré : mesure, leviers (massification, report modal), reporting et plan de progrès (1,5 pt) ; mobilisation du réseau et de la capacité réservée comme condition de crédibilité (1 pt) ; réponse commerciale avec phase pilote et jalons (0,5 pt). Erreurs fréquentes : promettre un outil sans les données des transporteurs ; réduire la RSE à une déclaration d'intention sans mesure.$mft$,
   5, 'difficile', ARRAY['commissionnaire','module-1','question-redigee'], 'COMM-M1-QR-08', false,
   $mft$Moderniser l'offre : visibilité, RSE, réseau, trajectoire commerciale.$mft$);

  RAISE NOTICE 'Module 1 Commissionnaire créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $commm1$;
