-- =====================================================================
-- COMMISSIONNAIRE DE TRANSPORT : MODULE 3, ORGANISER LE TRANSPORT
-- MULTIMODAL. v1 (juillet 2026)
-- Choisir et combiner les modes : conventions (CMR, mer, air, fer),
-- documents, plafonds comparés, conteneurs, groupage, cotation.
-- STATUT : active = false (a valider). Idempotent.
-- =====================================================================

DO $commm3$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_l4 uuid;
  v_quiz uuid; v_q uuid; v_ord int := 0;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'commissionnaire';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation commissionnaire introuvable.';
  END IF;

  INSERT INTO public.blocs (id, code, title, description, "order") VALUES (80, 'COMMISSIONNAIRE', 'Commissionnaire de transport', 'Le métier de commissionnaire de transport : contrat de commission, responsabilités, organisation multimodale, douane et Incoterms, gestion et assurances.', 80) ON CONFLICT DO NOTHING;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'COMMISSIONNAIRE';

  DELETE FROM public.question_bank WHERE source_ref LIKE 'COMM-M3-%';
  DELETE FROM public.modules WHERE slug = 'comm-multimodal';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 3 : Organiser le transport multimodal',
    'comm-multimodal', v_bloc,
    'Choisir et combiner les modes : conventions applicables (CMR, maritime, aérien, fer), documents de transport, plafonds comparés et logiques de groupage.',
    'avance', 330, 30) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 30, true);

  -- ─── Leçon 1 : Panorama des modes ──────────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'panorama-des-modes',
    'Panorama des modes : choisir avant de coter',
    $mft$> 🎯 **Objectifs**
> - Croiser les cinq critères qui commandent le choix d'un mode.
> - Situer chaque mode par ses ordres de grandeur relatifs (délai, logique de coût, usage).
> - Maîtriser le vocabulaire de la conteneurisation (20/40 pieds, FCL/LCL) et la mécanique du groupage.

## Partir du besoin, jamais du véhicule

Le transporteur vend un camion, un navire ou un avion ; le commissionnaire, lui, vend une SOLUTION. Sa première question n'est donc pas « quel mode ? » mais « quel besoin ? ». Cinq critères structurent l'analyse :

| Critère | Les bonnes questions |
| --- | --- |
| Coût | Quel budget transport par rapport à la valeur de la marchandise ? |
| Délai | Date impérative (chaîne arrêtée, saison, salon) ou fenêtre souple ? |
| Fiabilité | Le client préfère-t-il un délai court mais variable, ou plus long mais tenu ? |
| Empreinte carbone | Le chargeur a-t-il des engagements environnementaux, un bilan carbone à tenir ? |
| Nature de la marchandise | Valeur au kilo, périssable, dangereuse, fragile, hors gabarit ? |

C'est le CROISEMENT des cinq qui décide : des fraises (périssables) n'attendent pas des semaines de mer ; des parpaings (faible valeur au kilo) ne prendront jamais l'avion.

## Les modes en ordres de grandeur

> ⚠️ **Attention**
> Aucun tarif chiffré dans cette leçon, et c'est volontaire : les prix du fret bougent en permanence. Le professionnel raisonne en ordres de grandeur RELATIFS et cote chaque dossier au cas par cas.

| Mode | Délai typique | Logique économique | Terrain de jeu |
| --- | --- | --- | --- |
| Aérien | Se compte en jours | Se paie en euros par kilo | Urgence, forte valeur, périssables |
| Maritime | Se compte en semaines | Se raisonne en conteneurs | Gros volumes intercontinentaux |
| Routier | Du lendemain à quelques jours en Europe | Souplesse porte-à-porte | Flexibilité, pré et post-acheminements |
| Ferroviaire / fluvial | Délais planifiés | Massification | Gros tonnages réguliers, empreinte carbone réduite |

Retenez la grammaire du métier : l'aérien se pense en JOURS et en EUROS PAR KILO ; le maritime en SEMAINES et en CONTENEURS ; la route apporte la flexibilité du porte-à-porte ; le fer et le fleuve massifient et décarbonent.

## La conteneurisation : la brique du commerce mondial

Le conteneur standardisé (20 pieds ou 40 pieds) a unifié la chaîne : la même boîte passe du camion au train puis au navire sans que la marchandise soit manipulée. Deux régimes d'utilisation :

- **FCL** (Full Container Load) : le conteneur complet est réservé à UN client, qui l'empote et le fait plomber ; idéal dès que le volume le justifie.
- **LCL** (Less than Container Load) : le client n'a que quelques palettes ; il paie sa PART d'un conteneur partagé avec d'autres chargeurs. C'est le groupage maritime.

> 💡 **Astuce**
> FCL ou LCL, la question n'est pas que le volume : en FCL le client garde la maîtrise de l'empotage et du plomb ; en LCL la marchandise subit plus de manipulations (empotage et dépotage par des tiers), donc plus de points de rupture.

## Le groupage : le cœur économique du commissionnaire

Le groupage, c'est acheter l'espace de transport « en gros » et le revendre « au détail » :

:::flow
1. Collecter | Plusieurs petits lots de clients différents
2. Consolider | Empotage groupé dans un conteneur ou une unité de charge
3. Acheminer | Un seul transport principal, massifié
4. Dégrouper | Éclatement du lot à l'arrivée
5. Livrer | Post-acheminement chez chaque destinataire
:::

Le petit chargeur accède ainsi à un prix qu'il n'obtiendrait jamais seul ; le commissionnaire construit sa marge sur la différence entre l'espace acheté en gros et l'espace revendu au détail. Contrepartie : des délais de consolidation (attendre que le conteneur se remplisse) et des ruptures de charge supplémentaires.

> 📌 **À retenir**
> Le groupage est LE modèle économique historique du commissionnaire : sans lui, le petit lot international serait hors de prix. C'est aussi pour cela que la maîtrise des points de rupture (leçon 3) est vitale : c'est là que le modèle gagne ou perd.

## ✅ Synthèse

- Cinq critères à croiser : **coût, délai, fiabilité, carbone, nature de la marchandise**.
- Ordres de grandeur : aérien en **jours et euros/kg**, maritime en **semaines et conteneurs**, route en **porte-à-porte**, fer et fluvial en **massification**.
- Conteneur **20 ou 40 pieds** ; **FCL** (conteneur complet) contre **LCL** (part de conteneur, groupage).
- Le **groupage** : acheter en gros, revendre au détail : le cœur économique du métier.$mft$,
    $mft$Les cinq critères de choix d'un mode, les ordres de grandeur relatifs (aérien en jours et euros/kg, maritime en semaines et conteneurs), la conteneurisation 20/40 pieds FCL/LCL et la mécanique économique du groupage.$mft$,
    1, 45) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : Conventions et documents ────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'conventions-et-documents',
    'Un mode, une convention, un document',
    $mft$> 🎯 **Objectifs**
> - Associer chaque mode à sa convention internationale et à son document de transport.
> - Retenir les plafonds d'indemnisation et comprendre leur unité, le DTS.
> - Mesurer la portée juridique particulière du connaissement maritime.

## Le DTS : l'unité commune des plafonds

Les grandes conventions internationales de transport expriment leurs plafonds d'indemnisation dans la même unité : le **DTS** (droit de tirage spécial). Ce n'est pas une monnaie qui circule : c'est une unité de compte définie par le FMI (Fonds monétaire international), dont la contre-valeur en euros VARIE dans le temps.

> 🔍 **Zoom**
> Conséquence pratique : une indemnité plafonnée « en DTS » ne se convertit en euros qu'au cours du jour retenu. Deux sinistres identiques à six mois d'écart peuvent donner deux montants en euros différents. Dans vos devis et vos explications au client, précisez toujours que la contre-valeur est variable.

## Route : la convention CMR

Le transport routier international est régi par la **convention CMR** ; son document est la **lettre de voiture CMR**. LE chiffre à connaître absolument : le plafond d'indemnisation du transporteur routier est de **8,33 DTS par kilogramme** de poids brut de marchandise manquante ou avariée.

À la livraison, le destinataire qui constate un dommage doit formuler des **réserves** écrites, précises et motivées : c'est ce qui préserve les recours contre le transporteur. Une signature « nette », sans réserve, affaiblit considérablement le dossier.

## Mer : le connaissement, bien plus qu'un reçu

Le document maritime est le **connaissement** (bill of lading). Il cumule trois fonctions : reçu de la marchandise, preuve du contrat de transport et, surtout, **titre représentatif de la marchandise** : celui qui présente le connaissement à destination est en droit de réclamer la marchandise. D'où sa **négociabilité** : la marchandise peut être vendue PENDANT la traversée par transmission du document, et un vendeur peut garder la main sur son lot tant qu'il n'a pas remis le connaissement, par exemple contre paiement.

Côté responsabilité, les **règles de La Haye-Visby** plafonnent l'indemnisation du transporteur maritime à un montant de l'ordre de **2 DTS par kilo ou 666,67 DTS par colis**, en retenant le montant le plus élevé des deux (formulation exacte et montants à vérifier dans les textes en vigueur).

> ⚠️ **Attention**
> Ce plafond maritime est structurellement BAS par rapport à la route et à l'aérien : pour un colis léger de forte valeur, l'écart entre l'indemnité plafonnée et la valeur réelle peut être énorme. C'est un des grands arguments de l'assurance ad valorem (leçons 3 et 4).

## Air : la LTA et la convention de Montréal

Le document aérien est la **LTA** (lettre de transport aérien, air waybill en anglais). À la différence du connaissement, la LTA n'est **pas négociable** : elle n'est pas un titre représentatif de la marchandise, seulement une preuve du contrat et un reçu.

La responsabilité du transporteur aérien relève de la **convention de Montréal** : plafond exprimé en DTS par kilo, **révisé périodiquement**, de l'ordre de 20 à 27 DTS par kilo (à vérifier au montant en vigueur au jour du dossier). C'est le plafond au kilo le plus élevé des grands modes, cohérent avec la nature des marchandises confiées à l'aérien (forte valeur au kilo).

## Fer : la convention CIM

Le transport ferroviaire international est régi par la **convention CIM**. La logique documentaire est comparable à celle de la route : un document de transport accompagne l'envoi, et les réserves à destination préservent les recours (plafond propre à la convention, à vérifier).

## Le tableau à mémoriser

| Mode | Convention | Document | Plafond indicatif |
| --- | --- | --- | --- |
| Route | CMR | Lettre de voiture CMR | 8,33 DTS/kg |
| Mer | La Haye-Visby | Connaissement (négociable) | De l'ordre de 2 DTS/kg ou 666,67 DTS par colis, le plus élevé (à vérifier) |
| Air | Montréal | LTA (non négociable) | De l'ordre de 20 à 27 DTS/kg, révisé périodiquement (à vérifier) |
| Fer | CIM | Document CIM | Plafond propre à la convention (à vérifier) |

> 🎓 **Pour l'examen**
> Le trio « mode, convention, document » tombe très souvent, avec deux pièges favoris : la négociabilité (connaissement OUI, LTA NON) et le plafond routier (8,33 DTS/kg, à savoir par cœur).

## ✅ Synthèse

- **DTS** : unité de compte du FMI, contre-valeur en euros variable : convertir au cours du jour.
- Route : **CMR**, lettre de voiture, plafond **8,33 DTS/kg**, réserves écrites à la livraison.
- Mer : **connaissement négociable**, titre représentatif ; La Haye-Visby : de l'ordre de 2 DTS/kg ou 666,67 DTS par colis, le plus élevé (à vérifier).
- Air : **LTA non négociable**, convention de **Montréal**, plafond au kilo révisé périodiquement (à vérifier).
- Fer : convention **CIM**.$mft$,
    $mft$Le DTS et sa contre-valeur variable, le couple convention/document de chaque mode (CMR et lettre de voiture, La Haye-Visby et connaissement négociable, Montréal et LTA, CIM), les plafonds comparés dont le 8,33 DTS/kg routier.$mft$,
    2, 50) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : Conteneurs, transit et trous de responsabilité ──────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'douane-transit-conteneurs',
    'Conteneurs, transit et trous de responsabilité',
    $mft$> 🎯 **Objectifs**
> - Repérer les points de rupture de charge et les risques juridiques associés.
> - Comprendre le rôle probatoire de l'empotage et du plomb numéroté.
> - Poser le problème du dommage non localisé et la réponse assurantielle.

## La rupture de charge : là où les ennuis commencent

Un trajet international multimodal, ce sont des marchandises qui changent de mains : quai de l'usine, terminal portuaire, navire, terminal d'arrivée, camion final. Chaque **rupture de charge** est un point où la marchandise peut être endommagée, perdue ou volée : et où, surtout, la question « qui en avait la garde À CE MOMENT-LÀ ? » devient difficile à trancher.

## Empotage, dépotage et plomb numéroté

L'**empotage** est le chargement du conteneur ; le **dépotage**, son déchargement. La question clé de tout litige conteneurisé : QUI a empoté et QUI a scellé ?

:::flow
1. Empoter | Chargement du conteneur, liste de colisage établie
2. Plomber | Scellé numéroté posé, numéro reporté sur les documents
3. Acheminer | Le conteneur voyage fermé, plomb contrôlable à chaque étape
4. Contrôler | À l'arrivée : plomb intact ou non, le faisceau de preuve s'oriente
5. Dépoter | Ouverture, comptage contradictoire, réserves immédiates si écart
:::

Le **plomb numéroté** est le témoin silencieux du voyage : si le numéro d'arrivée correspond au numéro de départ et que le scellé est intact, le conteneur n'a en principe pas été ouvert pendant le transport. Un manquant constaté au dépotage sous plomb intact oriente alors les recherches vers l'empotage lui-même (erreur de comptage, lot incomplet au départ) plutôt que vers les transporteurs.

> ❌ **Piège à éviter**
> Laisser un client empoter son conteneur FCL sans liste de colisage, sans photos et sans reporter le numéro de plomb sur les documents : au premier litige, plus personne ne peut rien prouver, et le dossier se plaide à l'aveugle.

## Le transit portuaire et aéroportuaire

Entre le navire ou l'avion et le camion, la marchandise passe entre les mains des **manutentionnaires** des terminaux. Ces intervenants relèvent de régimes de responsabilité qui leur sont propres, distincts de ceux des transporteurs (régimes, plafonds et délais de réclamation à vérifier selon le pays et le statut de l'intervenant). Pour le commissionnaire, la conséquence est concrète : un dommage survenu pendant la manutention portuaire ne se traite pas comme un dommage survenu en mer ou sur la route.

## Le document multimodal unique et le dommage non localisé

Pour simplifier la vie du client, le commissionnaire émet parfois **son propre document de transport multimodal**, couvrant le trajet de bout en bout. Élégant, mais une question juridique surgit : quel régime de responsabilité appliquer ?

- Logique **réseau** : on applique la convention du mode sur lequel le dommage est survenu (CMR si c'est sur la route, régime maritime si c'est en mer, etc.).
- Logique **uniforme** : un seul régime, celui prévu par le document, s'applique du départ à l'arrivée.

Tout se complique avec le **dommage non localisé** : le conteneur est parti complet, il arrive avarié, et personne ne sait si le dommage est survenu sur la route, au port ou en mer. Quel plafond appliquer alors ? La réponse dépend du document émis et de ses clauses (l'articulation précise de ces régimes est à vérifier au cas par cas) : ce qu'il faut retenir à ce stade, c'est l'existence du problème et le réflexe de LIRE le document.

> 🔍 **Zoom**
> Le dommage non localisé est le cas d'école du multimodal : mêmes faits, indemnités potentiellement très différentes selon le régime retenu. Un commissionnaire qui émet son propre document doit savoir ce que ses clauses prévoient pour ce cas précis.

## L'assurance : la réponse pratique aux trous de responsabilité

Plafonds bas, régimes différents selon le segment, dommage non localisé : plutôt que de parier sur l'issue juridique, la réponse PRATIQUE est l'**assurance de la marchandise** (dite ad valorem, sur la valeur réelle). Elle indemnise le client sur la valeur assurée sans attendre la démonstration de la responsabilité de tel ou tel maillon ; l'assureur exerce ensuite les recours.

> 💡 **Astuce**
> Réflexe professionnel : chaque fois que la valeur de la marchandise dépasse ce que donneraient les plafonds conventionnels, la proposition d'assurance ad valorem doit partir AVEC le devis, par écrit (leçon 4).

## ✅ Synthèse

- Chaque **rupture de charge** est un risque physique ET un flou de responsabilité potentiel.
- **Plomb numéroté** reporté aux documents : la preuve maîtresse de l'intégrité du conteneur ; plomb intact = recherche orientée vers l'empotage.
- Manutentionnaires des terminaux : régimes de responsabilité **propres** (à vérifier).
- Document multimodal unique : logique **réseau** contre logique **uniforme** ; le **dommage non localisé** est le cas difficile (clauses à vérifier).
- L'**assurance ad valorem** : la réponse pratique aux trous de responsabilité.$mft$,
    $mft$Les ruptures de charge et leurs risques, la preuve par l'empotage et le plomb numéroté, les régimes propres des manutentionnaires (à vérifier), la problématique réseau/uniforme du dommage non localisé et l'assurance comme réponse pratique.$mft$,
    3, 45) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : Construire une solution ─────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'construire-une-solution',
    'Construire la solution : le cas Meaux-Casablanca',
    $mft$> 🎯 **Objectifs**
> - Découper une cotation multimodale en segments chiffrables.
> - Comparer plusieurs options sur un cas concret et rédiger un arbitrage.
> - Structurer un devis professionnel : inclus, exclus, responsabilité, assurance.

## La méthode : découper avant de chiffrer

Une solution multimodale ne se cote jamais « en bloc ». On la découpe en segments, chacun avec son prestataire, son délai et ses risques :

| Segment | Contenu | Questions à trancher |
| --- | --- | --- |
| Pré-acheminement | Enlèvement chez le chargeur vers le port ou l'aéroport | Qui charge ? Quel délai de remise ? |
| Passage portuaire / aéroportuaire | Manutention, empotage éventuel, formalités export | Date limite de remise (cut-off) respectée ? |
| Transport principal | Mer, air, route ou fer | Fréquence des départs, délai, fiabilité |
| Douane | Formalités export et import | Qui déclare ? Documents prêts ? |
| Post-acheminement | Du port ou de l'aéroport d'arrivée au destinataire | Dernier kilomètre, prise de rendez-vous |

## Le cas guidé : 12 palettes de Meaux vers Casablanca

Votre client, un industriel de Meaux, expédie 12 palettes de pièces mécaniques à son distributeur de Casablanca. Trois options à instruire.

**Option A : camion direct + ferry.** Un ensemble routier prend les 12 palettes à Meaux, descend par l'Espagne et embarque sur un ferry vers le Maroc. Force : le porte-à-porte, la marchandise ne change pas de véhicule sur le trajet principal. Délai : se compte en jours. Points de vigilance : aléas routiers, attente à l'embarquement du ferry, formalités douanières au passage.

**Option B : groupage maritime conteneur via Le Havre.**

:::flow
1. Pré-acheminement | Camion de Meaux vers Le Havre, remise au terminal avant la date limite
2. Passage portuaire | Empotage en conteneur de groupage, formalités export
3. Transport principal | Traversée maritime vers Casablanca
4. Port d'arrivée | Débarquement, dépotage, formalités douanières d'import
5. Post-acheminement | Livraison finale chez le distributeur
:::

Force : le coût massifié du groupage pour un lot de cette taille. Délai : se compte en semaines, consolidation comprise. Points de vigilance : deux passages portuaires, empotage et dépotage par des tiers, soit plusieurs ruptures de charge à sécuriser (plomb, liste de colisage, réserves au dépotage).

**Option C : aérien au départ de CDG (si urgence).** Pré-acheminement court de Meaux vers CDG, LTA, vol vers Casablanca, douane, livraison. Force : le délai le plus court, en jours. Contrepartie : un coût en euros par kilo qui réserve cette option à une vraie urgence (chaîne arrêtée, pénalités contractuelles chez le client final).

> ⚠️ **Attention**
> Annoncez des délais RÉALISTES, en fourchettes, incluant consolidation, douane et aléas : un délai « vitrine » intenable coûte plus cher en litige et en crédibilité que quelques jours d'honnêteté dans le devis.

## L'arbitrage écrit au client

Le livrable du commissionnaire n'est pas une liste de prix : c'est un **arbitrage écrit** : les options comparées (coût relatif, délai en fourchette, points de risque), une **recommandation motivée** (par exemple : option B si la date de besoin est à plusieurs semaines, option A si le porte-à-porte et le délai intermédiaire priment, option C uniquement si l'urgence le justifie), et les conditions pour tenir la promesse (date limite de remise des documents, marchandise prête à date).

## Le devis professionnel : les quatre rubriques

1. **Prestations incluses** : segments couverts, formalités prises en charge.
2. **Prestations exclues** : ce qui reste chez le client (emballage, droits et taxes à destination, attente au déchargement...), écrit noir sur blanc.
3. **Base de responsabilité** : rappel que chaque segment relève de sa convention et de ses plafonds (leçon 2), souvent très inférieurs à la valeur réelle.
4. **Proposition d'assurance ad valorem** : SYSTÉMATIQUE et écrite, avec la valeur à assurer déclarée par le client. S'il la refuse, le refus aussi se consigne par écrit.

> ❌ **Piège à éviter**
> Le devis flou : « transport Meaux-Casablanca : tant ». Sans inclus/exclus, sans base de responsabilité, sans proposition d'assurance écrite, chaque zone d'ombre se retournera contre le commissionnaire au premier incident.

> 🎓 **Pour l'examen**
> Sachez dérouler la décomposition en cinq segments (pré-acheminement, passage portuaire, transport principal, douane, post-acheminement) sur n'importe quelle relation : c'est la grille de lecture attendue de tout cas pratique multimodal.

## ✅ Synthèse

- Toute cotation multimodale se **découpe en segments** : pré-acheminement, passage portuaire, transport principal, douane, post-acheminement.
- Meaux-Casablanca : **A** camion + ferry (porte-à-porte, jours), **B** groupage maritime via Le Havre (massifié, semaines, ruptures de charge), **C** aérien CDG (urgence, euros par kilo).
- Livrable : un **arbitrage écrit** avec recommandation motivée et délais en fourchettes.
- Devis pro : **inclus, exclus, base de responsabilité, assurance ad valorem écrite et systématique**.$mft$,
    $mft$La cotation multimodale segment par segment sur le cas guidé Meaux-Casablanca (camion + ferry, groupage maritime via Le Havre, aérien CDG), l'arbitrage écrit avec recommandation et le devis professionnel avec assurance ad valorem systématique.$mft$,
    4, 55) RETURNING id INTO v_l4;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : Organiser le transport multimodal',
    'Vérifiez le module 3 : critères de choix des modes, conventions et plafonds, conteneurs et transit, construction d''une cotation multimodale.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Une usine cliente est à l'arrêt : il lui faut 300 kg de pièces détachées à Tokyo au plus vite, quel qu'en soit le prix. Quel mode proposez-vous en priorité ?$mft$,
    $mft$[
      {"id":"a","label":"L'aérien : le délai se compte en jours et le coût en euros par kilo se justifie par l'urgence","is_correct":true},
      {"id":"b","label":"Le maritime en conteneur complet : le plus rapide sur longue distance","is_correct":false},
      {"id":"c","label":"Le routier de bout en bout, seul mode porte-à-porte possible","is_correct":false},
      {"id":"d","label":"Le fluvial, pour massifier l'envoi","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['commissionnaire','module-3','qcm-v1'], 'COMM-M3-QCM-01', false,
    $mft$L'urgence d'une chaîne arrêtée désigne l'aérien, malgré son coût au kilo. Le maritime se compte en semaines, la route ne relie pas Tokyo et le fluvial massifie des flux lents.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Un client expédie 6 palettes non urgentes vers Shanghai avec un budget serré. Quelle solution maritime est la plus adaptée ?$mft$,
    $mft$[
      {"id":"a","label":"Le LCL : il paie sa part d'un conteneur de groupage partagé avec d'autres chargeurs","is_correct":true},
      {"id":"b","label":"Le FCL 40 pieds réservé pour lui seul, même à moitié vide","is_correct":false},
      {"id":"c","label":"L'aérien, moins cher que la mer pour les petits lots","is_correct":false},
      {"id":"d","label":"Attendre d'avoir assez de commandes pour remplir un conteneur complet","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['commissionnaire','module-3','qcm-v1'], 'COMM-M3-QCM-02', false,
    $mft$Six palettes ne remplissent pas un conteneur : le groupage LCL mutualise l'espace et le coût. Le FCL à moitié vide se paie plein, l'aérien se paie au kilo, et différer l'expédition ne répond pas au besoin.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Sur un lot routier Paris-Milan sous convention CMR, une palette de 120 kg est détruite. Hors situation particulière, sur quelle base se calcule l'indemnité plafonnée du transporteur ?$mft$,
    $mft$[
      {"id":"a","label":"8,33 DTS par kilogramme de poids brut avarié, convertis en euros au cours du jour","is_correct":true},
      {"id":"b","label":"La valeur facture de la marchandise, remboursée intégralement d'office","is_correct":false},
      {"id":"c","label":"Un forfait fixe par palette, identique quel que soit le poids","is_correct":false},
      {"id":"d","label":"Le remboursement du seul prix du transport","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['commissionnaire','module-3','qcm-v1'], 'COMM-M3-QCM-03', false,
    $mft$Le plafond CMR est de 8,33 DTS par kilo de poids brut. Ni remboursement automatique de la valeur facture, ni forfait par palette : et le prix du transport n'est pas le régime d'indemnisation de la marchandise.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Votre client vend une machine à un acheteur qu'il connaît mal et veut garder la main sur la marchandise jusqu'au paiement. Quel document de transport sert le mieux cet objectif ?$mft$,
    $mft$[
      {"id":"a","label":"Le connaissement maritime : titre représentatif de la marchandise, il peut n'être remis à l'acheteur que contre paiement","is_correct":true},
      {"id":"b","label":"La LTA aérienne, négociable et transmissible à volonté","is_correct":false},
      {"id":"c","label":"La lettre de voiture CMR, qui bloque la livraison tant que la facture est impayée","is_correct":false},
      {"id":"d","label":"Aucun document de transport n'a d'effet sur la remise de la marchandise","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['commissionnaire','module-3','qcm-v1'], 'COMM-M3-QCM-04', false,
    $mft$Seul le connaissement est un titre représentatif : détenir le document permet de réclamer la marchandise. La LTA n'est pas négociable et la lettre de voiture CMR n'a pas cette fonction de blocage.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Vous annoncez à un client une indemnité plafonnée « en DTS ». Il s'étonne que le montant en euros communiqué le mois dernier ne soit plus le même. Que lui répondez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Le DTS est une unité de compte du FMI dont la contre-valeur en euros varie : la conversion se fait au cours du jour retenu","is_correct":true},
      {"id":"b","label":"Le transporteur choisit librement le taux de conversion qui l'arrange","is_correct":false},
      {"id":"c","label":"Le DTS est indexé sur le prix du carburant, d'où la variation","is_correct":false},
      {"id":"d","label":"C'est forcément une erreur de calcul du service litiges","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-3','qcm-v1'], 'COMM-M3-QCM-05', false,
    $mft$Le DTS n'est pas une monnaie fixe : sa contre-valeur évolue dans le temps. Ni le transporteur ni le prix du carburant ne fixent ce cours, et la variation n'est pas une erreur.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$À la livraison d'un lot routier international, le destinataire découvre trois cartons écrasés. Que doit-il faire pour préserver les recours contre le transporteur ?$mft$,
    $mft$[
      {"id":"a","label":"Formuler dès la livraison des réserves écrites, précises et motivées sur la lettre de voiture","is_correct":true},
      {"id":"b","label":"Rien : la convention protège automatiquement le destinataire, réserves ou pas","is_correct":false},
      {"id":"c","label":"Refuser de signer et laisser repartir le camion sans aucun écrit","is_correct":false},
      {"id":"d","label":"Attendre l'inventaire de fin de mois pour signaler le dommage en une fois","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-3','qcm-v1'], 'COMM-M3-QCM-06', false,
    $mft$La réserve écrite, précise et motivée, formulée à la livraison, préserve le dossier. L'absence d'écrit, le refus muet ou le signalement tardif affaiblissent considérablement le recours.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Un conteneur FCL empoté et plombé par l'expéditeur arrive à destination avec son plomb d'origine intact, mais il manque 40 cartons au dépotage. Vers quoi ce constat oriente-t-il d'abord les recherches ?$mft$,
    $mft$[
      {"id":"a","label":"Vers l'empotage au départ : plomb intact, le conteneur n'a en principe pas été ouvert pendant le transport","is_correct":true},
      {"id":"b","label":"Vers le transporteur maritime, présumé responsable dans tous les cas","is_correct":false},
      {"id":"c","label":"Vers le commissionnaire, responsable automatique de tout manquant","is_correct":false},
      {"id":"d","label":"Vers le manutentionnaire du port d'arrivée, dernier intervenant de la chaîne","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-3','qcm-v1'], 'COMM-M3-QCM-07', false,
    $mft$Un plomb numéroté intact indique un conteneur resté fermé : le manquant renvoie au comptage ou au chargement initial. Aucun autre maillon ne se présume responsable quand rien n'indique une ouverture en cours de transport.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Pour 12 palettes de Meaux vers Casablanca, sans urgence et à budget serré, quelle option instruisez-vous en priorité dans votre cotation ?$mft$,
    $mft$[
      {"id":"a","label":"Le groupage maritime en conteneur via Le Havre, avec pré-acheminement et post-acheminement routiers","is_correct":true},
      {"id":"b","label":"L'aérien au départ de CDG, pourtant réservé aux vraies urgences","is_correct":false},
      {"id":"c","label":"Un devis global « Meaux-Casablanca » sans décomposer les segments","is_correct":false},
      {"id":"d","label":"Le transport principal seul : le client se débrouillera pour les acheminements","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-3','qcm-v1'], 'COMM-M3-QCM-08', false,
    $mft$Sans urgence, la logique massifiée du groupage maritime correspond au besoin. L'aérien se paie en euros par kilo, et une cotation sans segments ni acheminements n'est pas un travail de commissionnaire.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Votre solution combine un pré-acheminement routier et un long parcours ferroviaire international. Quelle convention régit la partie ferroviaire internationale ?$mft$,
    $mft$[
      {"id":"a","label":"La convention CIM, propre au transport ferroviaire international","is_correct":true},
      {"id":"b","label":"La convention CMR, qui couvre tous les modes terrestres","is_correct":false},
      {"id":"c","label":"Les règles de La Haye-Visby, applicables aux parcours massifiés","is_correct":false},
      {"id":"d","label":"La convention de Montréal, commune au fer et à l'air","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-3','qcm-v1'], 'COMM-M3-QCM-09', false,
    $mft$Au fer international correspond la CIM. La CMR régit la route, La Haye-Visby la mer et Montréal l'aérien : chaque mode a sa convention.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Un conteneur couvert par le document multimodal unique émis par votre maison arrive avarié, sans qu'on puisse dire si le dommage est survenu sur la route, au port ou en mer. Quelle difficulté ce « dommage non localisé » soulève-t-il ?$mft$,
    $mft$[
      {"id":"a","label":"On ne sait pas quel régime appliquer : logique réseau (convention du mode où le dommage est survenu) contre logique uniforme (régime unique du document), à trancher selon les clauses","is_correct":true},
      {"id":"b","label":"Aucune : le plafond CMR s'applique d'office à tout transport multimodal","is_correct":false},
      {"id":"c","label":"Le client perd automatiquement tout droit à indemnisation","is_correct":false},
      {"id":"d","label":"L'assureur de la marchandise est dispensé d'indemniser","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['commissionnaire','module-3','qcm-v1'], 'COMM-M3-QCM-10', false,
    $mft$Sans localisation du dommage, le choix entre régime réseau et régime uniforme dépend du document et de ses clauses (à vérifier au cas par cas). Ni le plafond CMR d'office, ni la déchéance du client, ni la dispense de l'assureur ne sont exacts.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un client compare les plafonds conventionnels au kilo des trois grands modes internationaux. Quel classement, du plus élevé au plus bas, lui présentez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Aérien (de l'ordre de 20 à 27 DTS/kg, montant en vigueur à vérifier), puis route (8,33 DTS/kg), puis mer (de l'ordre de 2 DTS/kg, sous réserve de la règle par colis)","is_correct":true},
      {"id":"b","label":"Mer, puis route, puis aérien : les plafonds suivent le prix du transport","is_correct":false},
      {"id":"c","label":"Route, puis mer, puis aérien : la CMR est la convention la plus protectrice","is_correct":false},
      {"id":"d","label":"Les trois plafonds sont identiques puisqu'ils sont tous exprimés en DTS","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['commissionnaire','module-3','qcm-v1'], 'COMM-M3-QCM-11', false,
    $mft$Au kilo, l'aérien plafonne le plus haut et le maritime le plus bas, la route entre les deux à 8,33 DTS/kg ; en mer, la règle alternative par colis (de l'ordre de 666,67 DTS, à vérifier) peut relever l'indemnité d'un colis léger. L'unité DTS commune ne rend pas les montants identiques.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Un client confie au groupage maritime des équipements de 2 000 kg valant 80 000 euros, très au-dessus de ce que donneraient les plafonds conventionnels. Quelle est LA réponse pratique à lui proposer ?$mft$,
    $mft$[
      {"id":"a","label":"Une assurance ad valorem sur la valeur réelle, proposée par écrit avec le devis","is_correct":true},
      {"id":"b","label":"Une promesse verbale d'indemnisation intégrale en cas de sinistre","is_correct":false},
      {"id":"c","label":"Une majoration du prix de transport « pour couvrir le risque », sans police d'assurance","is_correct":false},
      {"id":"d","label":"Le passage en aérien, uniquement pour bénéficier d'un plafond au kilo plus élevé","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['commissionnaire','module-3','qcm-v1'], 'COMM-M3-QCM-12', false,
    $mft$L'assurance ad valorem comble l'écart entre plafonds et valeur réelle sans dépendre de la démonstration des responsabilités. La promesse verbale n'engage à rien de solide, la majoration ne crée aucune garantie et l'aérien ne se choisit pas pour son seul plafond.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Un chargeur hésite pour 5 palettes vers Montréal : FCL ou LCL ? Donnez la signification des deux sigles et dites lequel correspond au groupage.$mft$,
   $mft$FCL (Full Container Load) : conteneur complet réservé à un seul client. LCL (Less than Container Load) : le client paie sa part d'un conteneur partagé avec d'autres chargeurs : c'est le groupage, adapté à 5 palettes.$mft$,
   2, 'facile', ARRAY['commissionnaire','module-3','question-courte'], 'COMM-M3-QC-01', false,
   $mft$FCL = conteneur complet, LCL = part de conteneur (groupage).$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Pour la partie routière internationale de votre solution multimodale, quel document matérialise le contrat et quel plafond d'indemnisation au kilo lui est associé ?$mft$,
   $mft$La lettre de voiture CMR ; plafond de 8,33 DTS par kilogramme de poids brut.$mft$,
   2, 'facile', ARRAY['commissionnaire','module-3','question-courte'], 'COMM-M3-QC-02', false,
   $mft$Le couple CMR : lettre de voiture + 8,33 DTS/kg.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Avant de proposer un mode à un client, citez quatre des cinq critères que le commissionnaire croise systématiquement.$mft$,
   $mft$Quatre parmi : le coût, le délai, la fiabilité, l'empreinte carbone, la nature de la marchandise (valeur, périssable, dangereuse).$mft$,
   2, 'facile', ARRAY['commissionnaire','module-3','question-courte'], 'COMM-M3-QC-03', false,
   $mft$Quatre critères distincts attendus.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Un client s'étonne : l'indemnité plafonnée annoncée en euros a changé entre deux courriers. Qu'est-ce que le DTS et pourquoi cette variation ?$mft$,
   $mft$Le DTS (droit de tirage spécial) est une unité de compte définie par le FMI, pas une monnaie fixe : sa contre-valeur en euros varie dans le temps, la conversion se fait au cours du jour retenu.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-3','question-courte'], 'COMM-M3-QC-04', false,
   $mft$Unité de compte du FMI + contre-valeur variable.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Pourquoi dit-on que le connaissement maritime est un « titre représentatif de la marchandise », et quelle possibilité commerciale cela ouvre-t-il pendant la traversée ?$mft$,
   $mft$Parce que celui qui détient le connaissement est en droit de réclamer la marchandise à destination. Conséquence : le document est négociable, la marchandise peut être vendue en cours de voyage par transmission du connaissement.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-3','question-courte'], 'COMM-M3-QC-05', false,
   $mft$Titre représentatif + négociabilité.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Votre client empote lui-même son conteneur FCL. Quel geste matériel, complété par quelle mention documentaire, fige la preuve de l'intégrité du chargement jusqu'au dépotage ?$mft$,
   $mft$La pose d'un plomb (scellé) numéroté sur le conteneur, avec report du numéro sur les documents de transport : un plomb intact à l'arrivée établit que le conteneur n'a en principe pas été ouvert.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-3','question-courte'], 'COMM-M3-QC-06', false,
   $mft$Plomb numéroté + numéro reporté aux documents.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Décomposez en cinq segments la solution groupage maritime des 12 palettes de Meaux vers Casablanca via Le Havre.$mft$,
   $mft$Pré-acheminement routier de Meaux au Havre ; passage portuaire au Havre (empotage, formalités export) ; traversée maritime vers Casablanca ; passage portuaire et douane à l'import ; post-acheminement jusqu'au destinataire.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-3','question-courte'], 'COMM-M3-QC-07', false,
   $mft$Les cinq segments dans l'ordre.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Dans vos devis, pourquoi la proposition d'assurance ad valorem doit-elle être à la fois systématique et écrite ?$mft$,
   $mft$Parce que les plafonds conventionnels sont souvent très inférieurs à la valeur réelle : l'assurance comble cet écart ; et l'écrit prouve que le client a accepté ou refusé en connaissance de cause, ce qui protège le commissionnaire en cas de sinistre.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-3','question-courte'], 'COMM-M3-QC-08', false,
   $mft$Écart plafonds/valeur + preuve écrite de la proposition.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Qu'appelle-t-on un « dommage non localisé » en transport multimodal, et pourquoi est-ce le cas le plus délicat à indemniser ?$mft$,
   $mft$Un dommage dont on ne peut pas déterminer sur quel segment (route, port, mer...) il est survenu. Délicat car on ne sait pas quel régime ni quel plafond appliquer : logique réseau contre logique uniforme, selon les clauses du document (à vérifier au cas par cas).$mft$,
   2, 'difficile', ARRAY['commissionnaire','module-3','question-courte'], 'COMM-M3-QC-09', false,
   $mft$Définition + conflit de régimes réseau/uniforme.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Un colis maritime de 40 kg est perdu. Sous les règles de La Haye-Visby, comment s'articulent en principe les deux plafonds, et lequel jouerait ici ?$mft$,
   $mft$De l'ordre de 2 DTS par kilo ou 666,67 DTS par colis, en retenant le montant le plus élevé (formulation à vérifier). Pour 40 kg, le calcul au kilo donnerait environ 80 DTS : le plafond par colis, plus élevé, jouerait.$mft$,
   2, 'difficile', ARRAY['commissionnaire','module-3','question-courte'], 'COMM-M3-QC-10', false,
   $mft$Règle du plus élevé + application chiffrée au colis léger.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ─────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Un client novice vous demande pourquoi vos prix de groupage sont si compétitifs. Expliquez-lui le mécanisme du groupage, l'intérêt pour lui, l'intérêt pour vous, et les contreparties à connaître.$mft$,
   $mft$Réponse modèle. Le mécanisme : le commissionnaire collecte les petits lots de plusieurs clients, les consolide dans un même conteneur ou une même unité de charge, achète le transport principal « en gros » et revend l'espace « au détail » à chaque client. Intérêt pour le client : un petit lot international accède à un prix massifié qu'il n'obtiendrait jamais seul, avec un interlocuteur unique qui organise la chaîne de bout en bout. Intérêt pour le commissionnaire : sa marge se construit sur la différence entre l'espace acheté en gros et l'espace revendu au détail : le groupage est son cœur économique historique. Contreparties à annoncer honnêtement : des délais de consolidation (attendre que l'unité se remplisse avant le départ), des ruptures de charge supplémentaires (empotage et dépotage par des tiers), donc des points de manipulation à sécuriser : liste de colisage, plomb numéroté, réserves au dépotage ; et des plafonds d'indemnisation conventionnels qui justifient la proposition d'assurance ad valorem écrite. Un client bien informé de ces contreparties reste un client ; celui qui les découvre au premier incident se perd.$mft$,
   $mft$Barème /5 : mécanisme collecte, consolidation, achat en gros et revente au détail (1,5 pt) ; intérêt client : prix massifié, interlocuteur unique (1 pt) ; intérêt commissionnaire : marge de consolidation, cœur économique (1 pt) ; contreparties : délais de consolidation, ruptures de charge, plafonds et assurance (1,5 pt). Erreurs fréquentes : présenter le groupage comme sans inconvénient ; confondre groupage et affrètement d'un véhicule complet.$mft$,
   5, 'facile', ARRAY['commissionnaire','module-3','question-redigee'], 'COMM-M3-QR-01', false,
   $mft$Le modèle économique du groupage expliqué à un client.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Comparez le connaissement maritime et la LTA aérienne : nature juridique, négociabilité, et conséquences pratiques pour un vendeur qui veut garder la main sur sa marchandise jusqu'au paiement.$mft$,
   $mft$Réponse modèle. Nature : le connaissement (bill of lading) cumule trois fonctions : reçu de la marchandise, preuve du contrat de transport et titre représentatif de la marchandise : celui qui le détient peut la réclamer à destination. La LTA (lettre de transport aérien) n'est que reçu et preuve du contrat : elle ne représente pas la marchandise. Négociabilité : le connaissement est négociable : il peut être transmis pendant la traversée, ce qui permet de vendre la marchandise en cours de voyage ; la LTA n'est pas négociable. Conséquences pour le vendeur prudent : en maritime, il peut conserver le connaissement tant que l'acheteur n'a pas payé : sans le document, pas de remise de la marchandise : le connaissement devient un instrument de sécurisation du paiement. En aérien, ce levier n'existe pas : la LTA ne bloque pas la remise : le vendeur doit sécuriser son paiement autrement (acompte, garanties). Le choix du mode a donc aussi une dimension financière, pas seulement logistique : c'est au commissionnaire de la signaler à son client.$mft$,
   $mft$Barème /5 : trois fonctions du connaissement dont titre représentatif (1,5 pt) ; LTA non négociable, simple preuve et reçu (1 pt) ; mécanisme de rétention du connaissement contre paiement (1,5 pt) ; absence de ce levier en aérien et alternatives (1 pt). Erreurs fréquentes : attribuer la négociabilité à la LTA ; réduire le connaissement à un simple reçu.$mft$,
   5, 'facile', ARRAY['commissionnaire','module-3','question-redigee'], 'COMM-M3-QR-02', false,
   $mft$Deux documents, deux portées juridiques opposées.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Cas chiffré. Un lot routier international de 600 kg (valeur facture 18 000 euros) est entièrement détruit dans un accident, sans faute particulière du transporteur. Calculez le plafond d'indemnisation conventionnel en DTS, expliquez pourquoi vous ne pouvez pas donner un montant définitif en euros, mesurez l'écart avec la valeur réelle et tirez-en la conséquence commerciale.$mft$,
   $mft$Réponse modèle. Calcul : en transport routier international sous CMR, le plafond est de 8,33 DTS par kilogramme de poids brut : 600 kg x 8,33 = 4 998 DTS. Conversion : le DTS est une unité de compte du FMI dont la contre-valeur en euros varie dans le temps : le montant définitif ne se connaît qu'au cours du jour retenu ; on ne peut donc annoncer qu'un ordre de grandeur en euros, pas un chiffre ferme. Écart : quelle que soit la conversion, l'indemnité plafonnée restera très inférieure à la valeur facture de 18 000 euros : le client ne récupérerait qu'une fraction de son préjudice, hors cas particuliers où le plafond serait écarté. Conséquence commerciale : ce dossier illustre exactement pourquoi la proposition d'assurance ad valorem doit être systématique et écrite dès le devis : assurée sur sa valeur réelle, la marchandise aurait été indemnisée sur la base des 18 000 euros déclarés (selon la police), sans dépendre du plafond ni du débat de responsabilité. Un commissionnaire qui n'a pas proposé l'assurance par écrit se retrouve en position très inconfortable face à son client.$mft$,
   $mft$Barème /5 : calcul exact 600 x 8,33 = 4 998 DTS (1,5 pt) ; explication de la contre-valeur variable du DTS (1 pt) ; constat argumenté de l'écart avec 18 000 euros (1 pt) ; conséquence : assurance ad valorem systématique et écrite (1,5 pt). Erreurs fréquentes : convertir en euros avec un taux inventé ; conclure que le client sera intégralement indemnisé par le transporteur.$mft$,
   5, 'moyen', ARRAY['commissionnaire','module-3','question-redigee'], 'COMM-M3-QR-03', false,
   $mft$Le plafond CMR appliqué à un cas réel, jusqu'à la leçon commerciale.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Un même client vous confie trois flux : des fraises pour Dubaï (périssables, départ sous 48 h), des vêtements vers l'Europe du Nord depuis son entrepôt francilien (non urgents, volumes réguliers), et un groupe électrogène de 8 tonnes pour Dakar (chantier dont le démarrage est dans plusieurs semaines). Recommandez un mode par flux en croisant les critères de choix.$mft$,
   $mft$Réponse modèle. Fraises pour Dubaï : le critère dominant est la nature périssable combinée au délai : la marchandise ne survivrait pas à des semaines de mer : aérien, seul mode dont le délai se compte en jours sur cette distance ; le coût en euros par kilo se justifie par la valeur du produit frais et la perte totale en cas de retard. Vêtements vers l'Europe du Nord : flux régulier, non urgent, distances continentales : la route s'impose par sa souplesse porte-à-porte ; sur des volumes réguliers et massifiables, une combinaison ferroviaire mérite d'être cotée, notamment si le client a des engagements de réduction d'empreinte carbone. Groupe électrogène de 8 tonnes vers Dakar : lot lourd, faible urgence, date de chantier connue à plusieurs semaines : maritime, en conteneur adapté : le délai en semaines est compatible avec l'échéance à condition d'intégrer une marge pour la consolidation éventuelle, les passages portuaires et la douane. Méthode transversale : pour chaque flux, croiser coût, délai, fiabilité, empreinte carbone et nature de la marchandise, puis verrouiller les délais annoncés en fourchettes réalistes plutôt qu'en promesses de vitrine.$mft$,
   $mft$Barème /5 : fraises : aérien justifié par périssable et délai (1,5 pt) ; vêtements : route, avec option fer/carbone argumentée (1,5 pt) ; groupe électrogène : maritime avec marge de délai (1,5 pt) ; méthode : croisement explicite des critères (0,5 pt). Erreurs fréquentes : justifier chaque choix par un seul critère ; promettre des délais secs sans marge.$mft$,
   5, 'moyen', ARRAY['commissionnaire','module-3','question-redigee'], 'COMM-M3-QR-04', false,
   $mft$Trois flux, trois arbitrages de mode motivés.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Procédure. Un client empote pour la première fois son conteneur FCL dans son usine. Rédigez la procédure d'empotage et de plombage que vous lui imposez, étape par étape, en expliquant ce que chaque étape apporte le jour où un litige survient.$mft$,
   $mft$Réponse modèle. 1) Avant empotage : vérifier l'état du conteneur (propre, sec, étanche, sans odeur) et le consigner, photos à l'appui : évite qu'un dommage préexistant soit imputé au chargement du client. 2) Pendant l'empotage : établir une liste de colisage précise (nombre, références, poids), caler et arrimer correctement : la liste fait foi du contenu réellement chargé et l'arrimage prévient les avaries de roulis et de manutention. 3) Photographier le chargement terminé, conteneur encore ouvert : preuve visuelle du contenu et de son état au départ. 4) Plombage : poser le scellé numéroté immédiatement après fermeture et reporter le numéro sur les documents de transport : le plomb devient le témoin de l'intégrité du conteneur pendant tout le voyage. 5) Au dépotage à destination : vérifier le numéro et l'état du plomb AVANT ouverture, compter contradictoirement, formuler des réserves écrites immédiates en cas d'écart. Le jour du litige : plomb intact et documents concordants orientent la recherche vers l'empotage ; plomb absent ou différent, vers la phase de transport : sans cette procédure, personne ne peut rien prouver.$mft$,
   $mft$Barème /5 : contrôle initial du conteneur consigné (1 pt) ; liste de colisage et arrimage (1 pt) ; photos avant fermeture (0,5 pt) ; plomb numéroté posé et reporté aux documents (1,5 pt) ; contrôle du plomb et réserves au dépotage (1 pt). Erreurs fréquentes : plomber sans reporter le numéro ; ouvrir le conteneur à l'arrivée avant d'avoir constaté l'état du scellé.$mft$,
   5, 'moyen', ARRAY['commissionnaire','module-3','question-redigee'], 'COMM-M3-QR-05', false,
   $mft$La chaîne de preuve, de l'empotage au dépotage.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Votre client de Meaux doit livrer 12 palettes à Casablanca. Il hésite : « le moins cher possible, mais mon distributeur s'impatiente ». Construisez l'arbitrage écrit : trois options décomposées, délais relatifs, points de rupture, recommandation motivée et mention d'assurance.$mft$,
   $mft$Réponse modèle. Option A, camion direct + ferry : porte-à-porte sans rupture de charge sur le trajet principal, délai en jours ; points de vigilance : aléas routiers, attente à l'embarquement, douane au passage ; positionnement intermédiaire en coût et en délai. Option B, groupage maritime conteneur via Le Havre : pré-acheminement routier, passage portuaire (empotage groupage, formalités export), traversée, port et douane à Casablanca, post-acheminement ; le coût massifié le plus bas, mais un délai en semaines, consolidation comprise, et plusieurs ruptures de charge à sécuriser (plomb, liste de colisage, réserves au dépotage). Option C, aérien au départ de CDG : le délai le plus court, en jours ; coût en euros par kilo réservé à une urgence avérée : ici, l'impatience du distributeur n'est pas une chaîne arrêtée. Recommandation : si la date de besoin laisse plusieurs semaines, option B avec un délai annoncé en fourchette honnête ; si le délai est réellement critique, option A en compromis ; option C seulement si un événement transforme l'impatience en urgence chiffrable. Dans tous les cas : devis avec inclus et exclus, base de responsabilité rappelée et proposition d'assurance ad valorem écrite.$mft$,
   $mft$Barème /5 : trois options correctement décomposées (1,5 pt) ; délais relatifs et points de rupture par option (1,5 pt) ; recommandation motivée par la date de besoin (1,5 pt) ; mention du devis professionnel et de l'assurance ad valorem écrite (0,5 pt). Erreurs fréquentes : recommander l'aérien par confort ; annoncer des délais secs sans fourchette ; oublier pré et post-acheminements.$mft$,
   5, 'moyen', ARRAY['commissionnaire','module-3','question-redigee'], 'COMM-M3-QR-06', false,
   $mft$L'arbitrage multimodal complet sur le cas guidé.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Analyse. Votre maison a émis son propre document de transport multimodal sur un flux Lyon-Alger combinant route, port et mer. Le conteneur arrive avarié, dommage impossible à localiser. Exposez la problématique juridique (régime réseau contre régime uniforme), ses conséquences possibles sur l'indemnisation, et ce que vous auriez dû verrouiller en amont.$mft$,
   $mft$Réponse modèle. Problématique : quand le commissionnaire émet un document unique de bout en bout, deux logiques s'affrontent : la logique réseau applique au dommage la convention du mode sur lequel il est survenu (CMR sur la route, régime maritime en mer) ; la logique uniforme applique un régime unique, celui du document, à tout le trajet. Le dommage non localisé met le système en tension : impossible de désigner le mode, donc, en logique réseau, impossible de désigner le régime : la solution dépend alors des clauses du document émis, dont l'articulation exacte est à vérifier au cas par cas. Conséquences : selon le régime retenu, le plafond applicable peut varier fortement (les plafonds maritimes étant structurellement plus bas, au kilo, que les plafonds routiers ou aériens) : mêmes faits, indemnités très différentes, litige long et incertain. Ce qu'il fallait verrouiller en amont : premièrement, des clauses claires dans le document du commissionnaire prévoyant expressément le cas du dommage non localisé ; deuxièmement, la traçabilité aux points de rupture (plombs, comptages, réserves) qui réduit les cas non localisés ; troisièmement, et surtout, la proposition écrite et systématique d'assurance ad valorem, qui indemnise le client sur la valeur assurée sans attendre l'issue du débat juridique.$mft$,
   $mft$Barème /5 : logiques réseau et uniforme correctement exposées (1,5 pt) ; spécificité du dommage non localisé et renvoi prudent aux clauses (1 pt) ; conséquences sur plafonds et indemnisation (1 pt) ; triple verrouillage amont : clauses, traçabilité, assurance (1,5 pt). Erreurs fréquentes : affirmer qu'un régime unique s'applique dans tous les cas ; oublier que l'assurance marchandise règle le problème pour le client.$mft$,
   5, 'difficile', ARRAY['commissionnaire','module-3','question-redigee'], 'COMM-M3-QR-07', false,
   $mft$Le cas d'école du multimodal : le dommage non localisé.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Cas chiffré comparé. Un colis unique de 30 kg contenant des instruments de mesure valant 21 000 euros doit partir à l'international. Le client demande : « sans assurance, quel mode m'indemniserait le mieux en cas de perte ? ». Comparez les ordres de grandeur des plafonds route, mer et air sur ce colis, puis formulez la vraie réponse professionnelle.$mft$,
   $mft$Réponse modèle. Route (CMR) : 8,33 DTS/kg, soit environ 250 DTS pour 30 kg. Mer (La Haye-Visby) : de l'ordre de 2 DTS/kg, soit environ 60 DTS, ou 666,67 DTS par colis en retenant le montant le plus élevé (formulation à vérifier) : ici la règle par colis dominerait, autour de 666 DTS. Air (Montréal) : plafond au kilo révisé périodiquement, de l'ordre de 20 à 27 DTS/kg (montant en vigueur à vérifier), soit environ 600 à 810 DTS. Constat : quel que soit le mode, et quelle que soit la contre-valeur du DTS au jour du sinistre, l'indemnité plafonnée resterait très inférieure aux 21 000 euros de valeur réelle : comparer les plafonds pour choisir le mode est un faux raisonnement. La vraie réponse professionnelle : le mode se choisit sur les critères logistiques (délai, coût, fiabilité, nature de la marchandise) ; la couverture de la valeur relève de l'assurance ad valorem, proposée par écrit et systématiquement, sur la valeur déclarée de 21 000 euros. Le refus éventuel du client se consigne aussi par écrit.$mft$,
   $mft$Barème /5 : trois ordres de grandeur calculés, avec prudence sur les montants à vérifier (2 pts) ; application correcte de la règle maritime du plus élevé au colis léger (1 pt) ; constat de l'insuffisance générale face à 21 000 euros (1 pt) ; conclusion : mode choisi sur critères logistiques, valeur couverte par assurance écrite (1 pt). Erreurs fréquentes : recommander l'aérien pour son plafond ; donner des contre-valeurs en euros comme certaines.$mft$,
   5, 'difficile', ARRAY['commissionnaire','module-3','question-redigee'], 'COMM-M3-QR-08', false,
   $mft$Comparer les plafonds pour conclure : il faut assurer.$mft$);

  RAISE NOTICE 'Module 3 Commissionnaire créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $commm3$;
