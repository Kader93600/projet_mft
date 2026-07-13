-- =====================================================================
-- ERTV : EXPLOITANT EN TRANSPORT ROUTIER DE VOYAGEURS
-- MODULE 4 : LE SOCIAL DU TRANSPORT DE VOYAGEURS
-- v1 (juillet 2026)
-- Recruter et planifier les conducteurs de voyageurs : titres exigés,
-- règles européennes appliquées aux services, spécificités
-- conventionnelles et scénarios d'exploitation conformes.
-- ⚠ STATUT : active = false (« à valider »). Idempotent.
-- =====================================================================

DO $ertvm4$
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

  DELETE FROM public.question_bank WHERE source_ref LIKE 'ERTV-M4-%';
  DELETE FROM public.modules WHERE slug = 'ertv-social-voyageurs';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 4 : Le social du transport de voyageurs',
    'ertv-social-voyageurs', v_bloc,
    'Recruter et planifier les conducteurs de voyageurs : titres exigés, règles européennes appliquées aux services, spécificités conventionnelles et scénarios d''exploitation conformes.',
    'avance', 330, 40) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 40, true);

  -- ─── Leçon 1 : Recruter un conducteur de voyageurs ─────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'recruter-un-conducteur-voyageurs',
    'Recruter un conducteur de voyageurs : le dossier complet',
    $mft$> 🎯 **Objectifs**
> - Vérifier l'ensemble des titres et documents exigés avant toute affectation.
> - Intégrer les exigences propres au transport de personnes : alcoolémie abaissée, honorabilité.
> - Bâtir une stratégie de recrutement et de fidélisation réaliste face à la pénurie.

## Un recrutement se vérifie, il ne se présume pas

En transport de voyageurs, l'exploitant qui affecte un conducteur non conforme engage l'entreprise à chaque kilomètre : la première protection, c'est un dossier d'embauche complet, contrôlé pièce par pièce AVANT la première affectation. Le candidat le plus sympathique du monde ne roule pas tant que son dossier n'est pas vert.

| Pièce | Ce que vérifie l'exploitant | Point de vigilance |
| --- | --- | --- |
| Permis D | Validité de la catégorie ET visite médicale associée au permis D en cours de validité | Une visite médicale expirée rend le conducteur inapte à conduire, même avec un permis « en règle » |
| Qualification initiale | FIMO voyageurs (140 h) OU titre professionnel de conducteur de voyageurs | Une qualification marchandises ne vaut pas pour les voyageurs |
| FCO | Formation continue obligatoire de 35 h, à renouveler tous les 5 ans | Reporter l'échéance dans le suivi RH : un conducteur « oublié » devient inaffectable du jour au lendemain |
| Carte de qualification | Matérialise la qualification (initiale puis FCO) | Croiser sa date avec le plan de formation de l'entreprise |
| Carte de conducteur | Indispensable pour les services soumis au tachygraphe | Anticiper le renouvellement : sans carte valide, pas d'affectation sur ces services |

Côté âge, le permis D s'obtient en principe à 21 ans ; des abaissements d'âge existent selon le parcours de qualification suivi, mais leurs conditions exactes sont à vérifier au cas par cas selon la voie de formation du candidat : aucune promesse d'embauche avant cette vérification.

## L'alcool : un seuil qui change tout

Scénario classique : un pot de départ est organisé au dépôt à midi, un conducteur reprend une ligne à 14 h et demande s'il peut « boire un seul verre ». La réponse de l'exploitant tient à une règle propre au métier : pour les conducteurs de transport en commun, le seuil d'alcoolémie est ABAISSÉ à 0,2 g/L de sang. À ce niveau, un seul verre peut suffire à dépasser le seuil : il n'existe aucun « verre de marge » à calculer.

> ⚠️ **Attention**
> C'est précisément parce que 0,2 g/L ne laisse aucune marge que les exploitants sérieux affichent une politique zéro alcool : pas de calcul, zéro. La note de service, la sensibilisation à l'embauche et l'exemplarité de l'encadrement font partie du dossier social de l'entreprise, et pèsent le jour où un incident survient.

## Transport scolaire : l'honorabilité renforcée

Le transport scolaire expose des mineurs : le conducteur affecté à ces services fait l'objet d'une exigence d'honorabilité renforcée. Les modalités précises des vérifications à conduire (nature des pièces, périodicité) relèvent des textes en vigueur : elles sont à vérifier avant de formaliser votre procédure de recrutement scolaire.

> 📌 **À retenir**
> Ce qui ne varie pas, quelles que soient les modalités : la vérification d'honorabilité se fait AVANT l'affectation sur les circuits scolaires, et son résultat est tracé dans le dossier du conducteur. Une vérification faite « après coup » ne protège ni les enfants ni l'entreprise.

## Recruter dans la pénurie

Le transport de voyageurs manque structurellement de conducteurs, et le scolaire cumule les handicaps : temps partiel, journées coupées, saisonnalité. L'exploitant qui attend le candidat idéal à temps complet attend longtemps. Les leviers qui fonctionnent :

- le **temps partiel en période scolaire** assumé : viser les profils dont la vie s'accorde avec les vacations (parents, jeunes retraités, personnes en cumul d'activité) ;
- les **cumuls d'emploi** organisés : un mi-temps scolaire peut se compléter ailleurs, à condition que l'exploitant garde la visibilité sur la charge totale du conducteur ;
- les **compléments internes** : périscolaire, sorties occasionnelles, renforts de lignes, qui gonflent le volume d'heures proposé ;
- la **fidélisation** : plannings vivables et équitables, coupures indemnisées conformément à la convention, parcours d'évolution vers le tourisme ou les lignes, tutorat des nouveaux.

> 💡 **Astuce**
> Le meilleur canal de recrutement reste le conducteur satisfait qui coopte : une équipe bien planifiée recrute pour vous ; une équipe épuisée fait fuir les candidats plus vite que n'importe quelle annonce.

## ✅ Synthèse

- Dossier d'embauche : permis D + visite médicale du permis, FIMO voyageurs (140 h) ou titre professionnel, FCO 35 h tous les 5 ans, carte de qualification, carte de conducteur.
- Permis D à 21 ans en principe : abaissements possibles selon la qualification, conditions à vérifier.
- Alcool : seuil abaissé à 0,2 g/L pour le transport en commun : politique zéro alcool.
- Scolaire : honorabilité renforcée, modalités à vérifier dans les textes, contrôle tracé avant affectation.
- Pénurie : temps partiels scolaires, cumuls organisés, compléments internes, fidélisation par le planning.$mft$,
    $mft$Le dossier d'embauche pièce par pièce (permis D et visite médicale, FIMO voyageurs 140 h ou titre professionnel, FCO 35 h/5 ans, cartes), le seuil d'alcool abaissé à 0,2 g/L, l'honorabilité renforcée du scolaire et les leviers face à la pénurie.$mft$,
    1, 45) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : La réglementation européenne appliquée aux services ─
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'rse-appliquee-aux-services',
    'La réglementation européenne appliquée à vos services',
    $mft$> 🎯 **Objectifs**
> - Déterminer, service par service, le régime applicable : règlement 561/2006 ou régime national.
> - Programmer un circuit occasionnel international en mobilisant la dérogation des 12 jours à bon escient.
> - Organiser le contrôle des données du tachygraphe côté exploitation.

## À quels services le règlement 561/2006 s'applique-t-il ?

En voyageurs, le règlement 561/2006 s'applique aux transports effectués avec des véhicules de PLUS de 9 places, conducteur compris. Mais il comporte une exception majeure, propre au métier : les services RÉGULIERS dont le parcours de la ligne ne dépasse pas 50 km relèvent du régime national, pas du règlement européen.

| Service | Parcours de la ligne | Régime applicable |
| --- | --- | --- |
| Ligne urbaine régulière | 18 km | Régime national |
| Circuit scolaire régulier court | 35 km | Régime national |
| Ligne régulière interurbaine | 72 km | Règlement 561/2006 |
| Excursion à la journée (occasionnel) | Sans objet | Règlement 561/2006 |
| Circuit touristique international | Sans objet | Règlement 561/2006, avec spécificités voyageurs |

Conséquence pratique : l'urbain et le scolaire court se pilotent avec les références nationales (décrets, convention collective), pas avec les compteurs du 561. À l'inverse, dès que la ligne régulière dépasse 50 km de parcours, ou dès que le service est occasionnel, les règles européennes classiques s'appliquent.

> 🔍 **Zoom**
> Le critère de l'exception est le parcours de la LIGNE du service régulier, pas la distance parcourue par le conducteur dans sa journée. Un conducteur d'urbain peut faire 200 km par jour sur une ligne de 15 km : il reste dans le régime national. Et le danger classique est le conducteur polyvalent : ligne courte le matin, occasionnel l'après-midi. Chaque service suit son régime, et l'exploitant doit savoir lequel s'applique à chaque affectation.

## Scénario : le circuit de 11 jours en Italie

Une agence vous commande un circuit occasionnel international de 11 jours consécutifs, sans retour intermédiaire. En logique classique, le repos hebdomadaire viendrait interrompre le circuit en plein milieu du séjour. La spécificité voyageurs qui change la donne : la dérogation dite « des 12 jours » permet, pour un circuit occasionnel international, de reporter le repos hebdomadaire jusqu'à 12 périodes de 24 heures consécutives.

> ⚠️ **Attention**
> Cette dérogation est strictement encadrée : nature du service, exigences complémentaires, compensations de repos au retour. Ses conditions exactes d'application sont à vérifier dans les textes en vigueur AVANT de programmer le circuit. L'exploitant qui découvre les conditions après avoir vendu le voyage se retrouve à choisir entre annuler et enfreindre : les deux coûtent cher.

:::flow
1. Qualifier le service | Régulier ou occasionnel ? National ou international ?
2. Déterminer le régime | Parcours de ligne de 50 km ou moins : régime national ; sinon : règlement 561/2006
3. Vérifier la faisabilité | Repos à caler, dérogation des 12 jours éventuelle, conditions à confirmer dans les textes
4. Affecter et informer | Conducteur qualifié et reposé, montage expliqué, documents à bord
5. Tracer et contrôler | Données du tachygraphe téléchargées et analysées au retour
:::

## Le tachygraphe vu du bureau d'exploitation

Sur les services soumis au règlement européen, la logique du tachygraphe est la même que partout : l'appareil enregistre, l'exploitation contrôle. Le rôle de l'exploitant voyageurs :

- **télécharger régulièrement** les données des cartes de conducteur et de la mémoire des véhicules ;
- **analyser les anomalies** : dépassements, oublis de sélecteur d'activité, conduite sans carte ;
- **traiter chaque anomalie** : entretien avec le conducteur quand la cause est individuelle, correction du graphique quand la cause est organisationnelle ;
- **conserver la trace** de ces contrôles et des suites données.

> 💡 **Astuce**
> Un dépassement qui se répète sur la même course dit rarement « conducteur fautif » : il dit presque toujours « horaire intenable ». Avant de sanctionner, regardez le graphique : si trois conducteurs différents dépassent au même endroit, c'est le planning qui est en infraction, pas les personnes.

## ✅ Synthèse

- Champ voyageurs du 561 : véhicules de plus de 9 places, conducteur compris.
- Exception majeure : services réguliers dont le parcours ne dépasse pas 50 km : régime national (urbain, scolaire court).
- Services longs et occasionnels : règles européennes classiques.
- Circuit occasionnel international : dérogation des 12 jours (report du repos hebdomadaire jusqu'à 12 périodes de 24 h), conditions exactes à vérifier avant de programmer.
- Tachygraphe : téléchargement, analyse, traitement des anomalies et traçabilité relèvent de l'exploitation.$mft$,
    $mft$Le champ d'application du règlement 561/2006 en voyageurs (plus de 9 places), l'exception des services réguliers de 50 km ou moins (régime national), la dérogation des 12 jours des circuits occasionnels internationaux et le contrôle des données tachygraphe par l'exploitation.$mft$,
    2, 45) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : Amplitude, coupures, planning ───────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'amplitude-coupures-planning',
    'Amplitude et coupures : construire des plannings vivables',
    $mft$> 🎯 **Objectifs**
> - Manier les notions propres au planning voyageurs : amplitude, coupure, vacation, temps annexes.
> - Intégrer travail de nuit, repos hebdomadaires et équité dans le planning mensuel.
> - Comprendre pourquoi l'absentéisme se fabrique dans les mauvais plannings.

## La journée voyageurs ne ressemble à aucune autre

Le transport de voyageurs, et d'abord le scolaire, vit en vacations : une pointe le matin, une pointe le soir, un creux au milieu. La journée d'un conducteur scolaire typique :

:::timeline
06:30 | Prise de service au dépôt : vérifications du véhicule, mise en place
06:50 | Vacation du matin : circuit scolaire aller
09:10 | Fin de la vacation du matin : retour au dépôt, nettoyage
09:30 | Début de la coupure méridienne : le conducteur est libéré
16:20 | Vacation du soir : reprise, circuit retour
18:40 | Fin de service : plein de carburant, remisage
:::

De 6 h 30 à 18 h 40, il s'écoule plus de 12 heures : c'est l'AMPLITUDE de la journée, mesurée du début à la fin du service, coupures comprises. Le travail effectif, lui, est très inférieur. Cette dissociation est la signature du métier.

## Les notions à manier sans hésiter

| Notion | Contenu | Traduction planning et paie |
| --- | --- | --- |
| Amplitude | Du début à la fin du service de la journée, coupures comprises | Encadrée : les maxima précis relèvent des décrets et de la convention collective voyageurs, à vérifier avant de graphier |
| Coupure | Interruption non travaillée entre deux vacations | Pas du travail effectif, mais indemnisation conventionnelle à appliquer |
| Vacation | Bloc de service continu (matin ou soir du scolaire) | L'unité de construction du planning |
| Temps annexes | Prise et fin de service, nettoyage, pleins, vérifications | Du travail effectif à compter et à payer, souvent sous-estimé |
| Travail de nuit | Services en plage nocturne (sorties tardives, transferts) | Contreparties prévues par les textes et la convention, à vérifier ; vigilance fatigue |
| Repos hebdomadaire | Week-ends et jours de repos | La répartition équitable entre conducteurs est un enjeu social majeur |

> 📌 **À retenir**
> Pourquoi l'amplitude admise en voyageurs est-elle structurellement large ? Parce que le scolaire impose des coupures méridiennes : sans amplitude étendue, impossible de couvrir la pointe du matin ET celle du soir avec le même conducteur. Les maxima chiffrés, eux, ne s'improvisent pas : ils se lisent dans les décrets et la convention collective applicables, à vérifier pour chaque type de service.

## Les temps annexes : le petit quart d'heure qui déborde

Prise de service, tour du véhicule, nettoyage, plein, remisage : chacun de ces temps paraît négligeable, et leur somme fait déborder les journées réelles au-delà du graphique théorique. Un planning qui les ignore produit mécaniquement des dépassements d'amplitude « inexpliqués » et de la paie contestée. L'exploitant sérieux les chiffre, les intègre au graphique et les paie comme le travail effectif qu'ils sont.

## L'absentéisme se fabrique dans les mauvais plannings

Un planning peut être conforme sur le papier et invivable en vrai. Les signaux : les mêmes conducteurs héritent toujours des amplitudes maximales, les week-ends travaillés se concentrent sur les nouveaux, le planning du mois sort trois jours avant le mois, les sorties de nuit tombent la veille de vacations matinales. La suite est connue : arrêts courts à répétition, démissions à la rentrée, et remplacement au pied levé qui dégrade encore le planning des présents : le cercle vicieux est bouclé.

Les principes du planning vivable :

- **équité mesurée** : rotation des week-ends, des coupures longues et des services ingrats, avec des compteurs visibles par tous ;
- **visibilité** : publication en avance, stabilité des roulements, gestion transparente des demandes ;
- **enchaînements humains** : pas de sortie tardive suivie d'une prise matinale, des coupures utilisables ;
- **écoute des préférences stables** : celui qui préfère le matin et celui qui préfère les sorties existent : les croiser coûte zéro.

> 💡 **Astuce**
> Comparez le taux d'absentéisme par type de service et par conducteur sur trois mois : les cases noires du tableau désignent presque toujours un défaut de conception du planning, pas un défaut de motivation des personnes.

## ✅ Synthèse

- Amplitude : du début à la fin du service, coupures comprises ; maxima dans les décrets et la CCN voyageurs, à vérifier.
- Coupures du scolaire : pas du travail effectif, mais indemnisation conventionnelle.
- Temps annexes (prise et fin de service, nettoyage, pleins) : du travail effectif à compter.
- Travail de nuit et week-ends : contreparties à vérifier, équité de répartition indispensable.
- Un planning conforme mais invivable produit absentéisme et démissions : la vivabilité se conçoit, elle ne se décrète pas.$mft$,
    $mft$Les notions du planning voyageurs (amplitude coupures comprises, vacations, coupures méridiennes indemnisées, temps annexes, travail de nuit), le renvoi aux décrets et à la CCN pour les maxima, et les principes du planning conforme et vivable contre l'absentéisme.$mft$,
    3, 45) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : Scénarios de conformité ─────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'scenarios-de-conformite',
    'Scénarios de conformité : affecter sans faute',
    $mft$> 🎯 **Objectifs**
> - Vérifier systématiquement cumuls, amplitude et repos AVANT toute affectation.
> - Distinguer un conducteur disponible d'un conducteur légalement affectable.
> - Tracer les vérifications : l'exploitant répond des infractions d'organisation.

## Le principe : vérifier avant, jamais régulariser après

En matière de temps de conduite et de repos, l'exploitant répond des infractions d'organisation : c'est lui qui affecte, c'est donc lui qui doit prouver que l'affectation était conforme au moment où il l'a décidée. Quatre scénarios reviennent sans cesse dans l'exploitation voyageurs : les voici, avec la méthode.

## Cas 1 : le conducteur scolaire qui « peut faire » l'excursion

Votre conducteur scolaire a terminé sa vacation du matin. Un client demande une excursion l'après-midi, et le conducteur est partant. La question n'est pas « est-il libre ? » mais « sa journée complète reste-t-elle conforme ? » : conduite déjà accomplie le matin, amplitude totale depuis la prise de service du matin jusqu'au retour du soir, temps annexes de l'excursion (mise en place, retour, remisage), et reprise du lendemain matin. Le calcul se fait AVANT de répondre au client, pas après avoir vendu la course.

## Cas 2 : le remplacement au pied levé

Un conducteur se déclare malade à 5 h 45. Un collègue volontaire répond au téléphone : « je peux venir tout de suite ». Disponible ne veut pas dire affectable. Avant de le lancer :

- ses repos journalier et hebdomadaire sont-ils respectés à l'heure où il prendrait le service ?
- sa conduite déjà accomplie sur la période est-elle compatible avec la mission ?
- l'amplitude de sa journée ainsi reconstruite tient-elle ?
- ses titres sont-ils à jour (FCO, visite médicale, carte de conducteur) ?

> ❌ **Piège à éviter**
> « Il était d'accord » n'est pas un moyen de défense. Le volontariat du conducteur n'exonère jamais l'exploitant : c'est l'affectation qui crée l'infraction d'organisation, pas la bonne volonté de celui qui l'accepte.

## Cas 3 : la sortie de nuit suivie d'une reprise matinale

Une sortie théâtre ramène le conducteur au dépôt à 0 h 45 ; son planning prévoit une reprise scolaire à 6 h 30. L'intervalle de 5 h 45 ne peut manifestement pas contenir le repos journalier : l'enchaînement est à recaler AVANT l'exécution, en réaffectant la reprise du matin à un autre conducteur ou en décalant le service. Règle d'or : une sortie tardive se planifie toujours AVEC la journée du lendemain, jamais seule. Et non, la coupure méridienne du lendemain ne « rattrape » rien : le repos journalier se prend entre deux journées de service.

## Cas 4 : le double équipage sur longue distance

Pour un transfert de nuit longue distance, deux conducteurs à bord se relaient : le véhicule progresse pendant que l'un se repose. Ce que le montage change : la progression du véhicule et le délai. Ce qu'il ne change pas : chaque conducteur reste individuellement soumis à ses propres limites de conduite, de pause et de repos selon les logiques du règlement 561/2006, avec sa propre carte dans le tachygraphe. Les conditions précises du double équipage sont à vérifier avant de monter l'opération, et la planification comme le contrôle des données se font conducteur par conducteur.

## La traçabilité : votre meilleure défense

:::flow
1. Recenser | Ce que le conducteur a déjà fait : conduite, amplitude, repos, sur la journée et la période
2. Projeter | Ce que la mission ajoute : conduite, temps annexes, heure de retour réelle
3. Confronter | La journée ET le lendemain restent-ils conformes ? Dans le doute : non
4. Décider | Affecter, aménager ou refuser : la conformité prime la demande commerciale
5. Tracer | Vérification horodatée dans l'outil d'exploitation : l'exploitant prouve son organisation
:::

Fiche d'affectation ou logiciel : peu importe l'outil, ce qui compte est de pouvoir montrer, des mois plus tard, qui a vérifié quoi et quand. Les meilleurs logiciels d'exploitation bloquent d'eux-mêmes les enchaînements non conformes : un garde-fou précieux les jours de tension, quand la tentation du « dépannage » est la plus forte.

> 🎓 **Pour l'examen**
> Retenez la formulation : l'exploitant répond des infractions d'organisation. Un contrôle en entreprise ne juge pas seulement les disques et les données : il juge la manière dont les affectations ont été décidées et documentées.

## ✅ Synthèse

- Toute affectation se vérifie AVANT : conduite accomplie, amplitude reconstruite, repos, titres.
- Disponible et volontaire ne signifie pas légalement affectable ; le volontariat n'exonère pas l'exploitant.
- Sortie tardive : se planifie avec la journée du lendemain ; repos journalier à caler entre les deux services.
- Double équipage : le véhicule avance, les obligations individuelles de chaque conducteur demeurent ; conditions précises à vérifier.
- Traçabilité horodatée des vérifications : c'est elle qui prouve que l'organisation n'est pas fautive.$mft$,
    $mft$Quatre scénarios d'affectation (excursion après le scolaire, remplacement au pied levé, sortie de nuit puis reprise matinale, double équipage), la distinction disponible/affectable, et la traçabilité des vérifications puisque l'exploitant répond des infractions d'organisation.$mft$,
    4, 45) RETURNING id INTO v_l4;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : Le social du transport de voyageurs',
    'Vérifiez le module 4 : recrutement des conducteurs, régimes applicables aux services, amplitude et coupures, scénarios d''affectation conformes.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Un candidat vous présente un permis D en cours de validité et sa carte de conducteur (tachygraphe). Avant de l'affecter à un service, quel élément de qualification devez-vous encore vérifier ?$mft$,
    $mft$[
      {"id":"a","label":"Sa carte de qualification : qualification initiale voyageurs (FIMO 140 h ou titre professionnel) et FCO à jour","is_correct":true},
      {"id":"b","label":"Une attestation sur l'honneur de son ancien employeur","is_correct":false},
      {"id":"c","label":"Son relevé de points, qui remplace toute autre vérification","is_correct":false},
      {"id":"d","label":"Sa carte grise personnelle, preuve de son expérience de conduite","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ertv','module-4','qcm-v1'], 'ERTV-M4-QCM-01', false,
    $mft$Le permis et la carte tachygraphe ne suffisent pas : la qualification (initiale voyageurs puis FCO) conditionne l'affectation. Attestation, relevé de points ou carte grise ne prouvent aucune qualification professionnelle.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Votre réseau lance une ligne régulière urbaine dont le parcours fait 18 km. De quel cadre relèvent les temps de conduite et de repos de ses conducteurs ?$mft$,
    $mft$[
      {"id":"a","label":"Du régime national : les services réguliers dont le parcours ne dépasse pas 50 km sont hors du champ du règlement 561/2006","is_correct":true},
      {"id":"b","label":"Du règlement 561/2006, qui couvre tous les transports de voyageurs sans exception","is_correct":false},
      {"id":"c","label":"D'aucun cadre : les lignes urbaines sont libres d'organisation","is_correct":false},
      {"id":"d","label":"Du choix de l'exploitant entre régime national et règlement européen","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ertv','module-4','qcm-v1'], 'ERTV-M4-QCM-02', false,
    $mft$Les services réguliers de 50 km de parcours ou moins relèvent du régime national. Le 561 n'est donc pas universel en voyageurs, aucune ligne n'est pour autant « libre », et le régime applicable ne se choisit pas.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Un pot de départ est organisé au dépôt à midi. Un conducteur reprend une ligne à 14 h et demande s'il peut « boire un seul verre ». Pourquoi votre note de service zéro alcool est-elle la bonne réponse ?$mft$,
    $mft$[
      {"id":"a","label":"Parce que le seuil d'alcoolémie des conducteurs de transport en commun est abaissé à 0,2 g/L : un seul verre peut suffire à le dépasser","is_correct":true},
      {"id":"b","label":"Parce que l'alcool est interdit dans les locaux de toute entreprise, quel que soit le poste","is_correct":false},
      {"id":"c","label":"Parce que le seuil de droit commun laisse une marge d'un verre, mais la direction préfère l'éviter","is_correct":false},
      {"id":"d","label":"Parce que seul un contrôle des forces de l'ordre compte, et qu'il vaut mieux protéger l'image","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ertv','module-4','qcm-v1'], 'ERTV-M4-QCM-03', false,
    $mft$À 0,2 g/L, il n'existe pas de « verre de marge » : la seule consigne tenable est zéro. Les autres réponses ignorent le seuil abaissé propre aux conducteurs de transport en commun.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Un conducteur scolaire prend son service à 6 h 30, coupe de 9 h 30 à 16 h 20, puis termine à 18 h 40. Comment nommez-vous la durée qui court de 6 h 30 à 18 h 40 ?$mft$,
    $mft$[
      {"id":"a","label":"L'amplitude de sa journée de travail, coupure comprise","is_correct":true},
      {"id":"b","label":"Son temps de conduite journalier","is_correct":false},
      {"id":"c","label":"Son temps de travail effectif","is_correct":false},
      {"id":"d","label":"Son repos journalier","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['ertv','module-4','qcm-v1'], 'ERTV-M4-QCM-04', false,
    $mft$L'amplitude va du début à la fin du service, coupures comprises : ici plus de 12 heures alors que le travail effectif est bien moindre. Conduite et travail effectif excluent la coupure, et le repos journalier se situe entre deux journées.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un client commande un circuit touristique international de 11 jours consécutifs, sans retour intermédiaire. Quelle spécificité voyageurs pouvez-vous étudier pour éviter d'interrompre le circuit ?$mft$,
    $mft$[
      {"id":"a","label":"La dérogation dite des 12 jours : report du repos hebdomadaire jusqu'à 12 périodes de 24 heures pour un circuit occasionnel international, sous conditions à vérifier avant le départ","is_correct":true},
      {"id":"b","label":"La suppression pure et simple du repos hebdomadaire pour les services touristiques","is_correct":false},
      {"id":"c","label":"Le passage du circuit en régime national pour sortir du règlement européen","is_correct":false},
      {"id":"d","label":"Le remplacement du repos hebdomadaire par une prime conventionnelle","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-4','qcm-v1'], 'ERTV-M4-QCM-05', false,
    $mft$La dérogation des 12 jours reporte le repos hebdomadaire sous conditions encadrées : elle ne le supprime jamais et il ne se rachète pas par une prime. Le régime national ne concerne que les services réguliers courts.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Votre conducteur scolaire a terminé sa vacation du matin. Un client demande une excursion de 13 h à 19 h 30 le jour même. Quel est votre premier réflexe d'exploitant ?$mft$,
    $mft$[
      {"id":"a","label":"Reconstituer sa journée complète (conduite déjà accomplie, amplitude depuis la prise du matin, reprise du lendemain) AVANT de répondre au client","is_correct":true},
      {"id":"b","label":"Accepter : il est disponible et volontaire, c'est l'essentiel","is_correct":false},
      {"id":"c","label":"Accepter, puis régulariser les compteurs la semaine suivante","is_correct":false},
      {"id":"d","label":"Lui demander s'il se sent en forme et le laisser décider","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-4','qcm-v1'], 'ERTV-M4-QCM-06', false,
    $mft$La disponibilité ne dit rien de la conformité : cumul de conduite, amplitude et repos du lendemain se vérifient avant l'affectation. On ne « régularise » pas une infraction après coup, et le ressenti du conducteur ne remplace pas le calcul.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Vos conducteurs scolaires coupent chaque jour plusieurs heures entre la vacation du matin et celle du soir. Comment cette coupure est-elle traitée ?$mft$,
    $mft$[
      {"id":"a","label":"Ce n'est pas du travail effectif, mais elle ouvre droit à une indemnisation prévue par la convention collective des voyageurs","is_correct":true},
      {"id":"b","label":"Elle compte intégralement comme du temps de conduite","is_correct":false},
      {"id":"c","label":"Elle n'a aucune existence : seules les heures de volant comptent","is_correct":false},
      {"id":"d","label":"Elle se transforme automatiquement en heures supplémentaires","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-4','qcm-v1'], 'ERTV-M4-QCM-07', false,
    $mft$La coupure n'est ni de la conduite ni du travail effectif, mais la convention collective des voyageurs prévoit son indemnisation : l'ignorer en paie est une source classique de contentieux.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Vous reprenez une ligne régulière interurbaine de 72 km de parcours. L'ancien exploitant la gérait comme ses lignes urbaines, en régime national. Que devez-vous faire ?$mft$,
    $mft$[
      {"id":"a","label":"Recaler l'exploitation sur le règlement 561/2006 : au-delà de 50 km de parcours, une ligne régulière sort de l'exception nationale","is_correct":true},
      {"id":"b","label":"Conserver le régime national : c'est le premier régime appliqué qui compte","is_correct":false},
      {"id":"c","label":"Appliquer les deux régimes en même temps, par sécurité","is_correct":false},
      {"id":"d","label":"Requalifier la ligne en service occasionnel pour simplifier","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-4','qcm-v1'], 'ERTV-M4-QCM-08', false,
    $mft$L'exception nationale s'arrête à 50 km de parcours de ligne : à 72 km, le 561 s'applique. Le régime ne se choisit pas, ne se cumule pas et ne dépend pas des habitudes du précédent exploitant.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Un conducteur absent au dernier moment, un collègue volontaire au téléphone : « je peux venir tout de suite ». Qu'est-ce qui rend son affectation réellement possible ?$mft$,
    $mft$[
      {"id":"a","label":"Qu'il soit légalement affectable : repos respectés, conduite déjà accomplie compatible, amplitude tenable et titres à jour, pas seulement disponible","is_correct":true},
      {"id":"b","label":"Son volontariat, qui vaut décharge de responsabilité pour l'exploitant","is_correct":false},
      {"id":"c","label":"Le fait qu'il connaisse bien la ligne concernée","is_correct":false},
      {"id":"d","label":"L'accord oral du chef d'exploitation, qui couvre l'affectation","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['ertv','module-4','qcm-v1'], 'ERTV-M4-QCM-09', false,
    $mft$Disponible et volontaire ne signifie pas affectable : repos, cumuls et titres se vérifient avant. Le volontariat n'exonère jamais l'exploitant, et la connaissance de la ligne ou un accord oral ne créent aucune conformité.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Vous constituez le dossier d'un candidat destiné aux circuits scolaires. Outre les titres de conduite et de qualification, quelle exigence propre à ce public intégrez-vous à vos vérifications ?$mft$,
    $mft$[
      {"id":"a","label":"Une honorabilité renforcée du conducteur, vérifiée selon les modalités prévues par les textes en vigueur, avant l'affectation","is_correct":true},
      {"id":"b","label":"Un âge minimal de 30 ans, spécifique au transport scolaire","is_correct":false},
      {"id":"c","label":"Un diplôme d'encadrement de la jeunesse","is_correct":false},
      {"id":"d","label":"Une ancienneté de dix ans de permis D","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ertv','module-4','qcm-v1'], 'ERTV-M4-QCM-10', false,
    $mft$Le transport scolaire expose des mineurs : l'honorabilité du conducteur fait l'objet d'exigences renforcées, à vérifier selon les modalités en vigueur et à tracer avant l'affectation. Ni un âge de 30 ans, ni un diplôme d'animation, ni dix ans de permis ne sont exigés.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Une sortie théâtre ramène un conducteur au dépôt à 0 h 45. Son planning prévoit une reprise scolaire à 6 h 30. Que fait l'exploitant qui découvre cet enchaînement la veille ?$mft$,
    $mft$[
      {"id":"a","label":"Il recale AVANT l'exécution : l'intervalle de 5 h 45 ne peut pas contenir le repos journalier, la reprise doit être réaffectée ou décalée","is_correct":true},
      {"id":"b","label":"Il laisse faire : le conducteur se reposera pendant la coupure méridienne du lendemain","is_correct":false},
      {"id":"c","label":"Il fait signer au conducteur une décharge de responsabilité","is_correct":false},
      {"id":"d","label":"Il laisse faire si le conducteur se déclare suffisamment reposé","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ertv','module-4','qcm-v1'], 'ERTV-M4-QCM-11', false,
    $mft$Le repos journalier se prend entre deux journées de service : 5 h 45 ne peuvent manifestement pas le contenir. Ni la coupure du lendemain, ni une « décharge », ni la bonne volonté du conducteur ne rendent l'enchaînement conforme.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Pour un transfert de nuit longue distance, vous montez un double équipage. Qu'est-ce que ce montage change, et ne change pas, dans votre planification ?$mft$,
    $mft$[
      {"id":"a","label":"Le véhicule peut progresser pendant que les conducteurs se relaient, mais chacun reste individuellement soumis à ses limites de conduite et de repos, vérifiées conducteur par conducteur","is_correct":true},
      {"id":"b","label":"Les temps des deux conducteurs s'additionnent sur un compteur commun","is_correct":false},
      {"id":"c","label":"Le tachygraphe devient facultatif puisque les conducteurs se surveillent mutuellement","is_correct":false},
      {"id":"d","label":"Le repos journalier disparaît tant que l'un des deux conduit","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['ertv','module-4','qcm-v1'], 'ERTV-M4-QCM-12', false,
    $mft$Le double équipage fait avancer le véhicule, pas disparaître les obligations : chaque conducteur conserve ses propres limites, enregistrées avec sa propre carte. Compteur commun, tachygraphe facultatif ou repos supprimé sont des contresens.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Un candidat conducteur n'a jamais suivi la FIMO voyageurs de 140 h. Quelle autre voie lui permet de détenir la qualification initiale exigée ?$mft$,
   $mft$Le titre professionnel de conducteur de voyageurs, qui vaut qualification initiale.$mft$,
   2, 'facile', ARRAY['ertv','module-4','question-courte'], 'ERTV-M4-QC-01', false,
   $mft$FIMO voyageurs ou titre professionnel : deux voies pour la même qualification.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Votre ligne régulière urbaine a un parcours de 12 km. Ses conducteurs relèvent-ils du règlement 561/2006 ?$mft$,
   $mft$Non : les services réguliers dont le parcours ne dépasse pas 50 km relèvent du régime national, pas du règlement 561/2006.$mft$,
   2, 'facile', ARRAY['ertv','module-4','question-courte'], 'ERTV-M4-QC-02', false,
   $mft$L'exception des services réguliers courts est attendue.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$En planning voyageurs, que recouvre l'amplitude d'une journée de travail ?$mft$,
   $mft$La durée totale entre le début et la fin du service de la journée, coupures comprises.$mft$,
   2, 'facile', ARRAY['ertv','module-4','question-courte'], 'ERTV-M4-QC-03', false,
   $mft$À distinguer du travail effectif et du temps de conduite.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Votre note de service impose le zéro alcool à tous les conducteurs. Quel argument réglementaire propre au transport en commun la justifie ?$mft$,
   $mft$Le seuil d'alcoolémie est abaissé à 0,2 g/L pour les conducteurs de transport en commun : un seul verre peut suffire à le dépasser, la seule consigne fiable est donc zéro.$mft$,
   2, 'moyen', ARRAY['ertv','module-4','question-courte'], 'ERTV-M4-QC-04', false,
   $mft$Le seuil abaissé à 0,2 g/L ne laisse aucune marge de calcul.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Un conducteur volontaire se propose pour un remplacement immédiat. Citez deux vérifications qui conditionnent son affectation légale, au-delà de sa disponibilité.$mft$,
   $mft$Par exemple : repos journalier et hebdomadaire respectés, conduite déjà accomplie compatible avec la mission, amplitude de la journée reconstruite tenable, titres et qualifications à jour (FCO, visite médicale, carte de conducteur).$mft$,
   2, 'moyen', ARRAY['ertv','module-4','question-courte'], 'ERTV-M4-QC-05', false,
   $mft$Deux vérifications distinctes attendues parmi repos, cumuls, amplitude, titres.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Citez trois temps annexes à intégrer au temps de travail d'un conducteur de voyageurs, en plus de la conduite.$mft$,
   $mft$Par exemple : la prise et la fin de service, le nettoyage du véhicule, les pleins de carburant, les vérifications avant départ.$mft$,
   2, 'moyen', ARRAY['ertv','module-4','question-courte'], 'ERTV-M4-QC-06', false,
   $mft$Trois temps annexes distincts, tous du travail effectif à compter.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Avant d'accepter un circuit occasionnel international de 11 jours sans retour, quelle dérogation étudiez-vous et quelle précaution prenez-vous ?$mft$,
   $mft$La dérogation dite des 12 jours (report du repos hebdomadaire jusqu'à 12 périodes de 24 heures pour un circuit occasionnel international) ; précaution : vérifier ses conditions exactes d'application dans les textes en vigueur avant de programmer le circuit.$mft$,
   2, 'moyen', ARRAY['ertv','module-4','question-courte'], 'ERTV-M4-QC-07', false,
   $mft$Dérogation des 12 jours + vérification préalable des conditions attendues.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Face à la pénurie de conducteurs scolaires, citez deux leviers d'organisation permettant de pourvoir les services.$mft$,
   $mft$Par exemple : les temps partiels en période scolaire, les cumuls d'emploi organisés, les compléments internes (périscolaire, occasionnel), la fidélisation par des plannings vivables.$mft$,
   2, 'moyen', ARRAY['ertv','module-4','question-courte'], 'ERTV-M4-QC-08', false,
   $mft$Deux leviers distincts propres au recrutement voyageurs.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Pourquoi la traçabilité des vérifications d'affectation protège-t-elle l'exploitant lors d'un contrôle en entreprise ?$mft$,
   $mft$Parce que l'exploitant répond des infractions d'organisation : une vérification horodatée (repos, cumuls, titres) prouve que l'affectation a été contrôlée au moment de la décision et que l'organisation n'est pas fautive.$mft$,
   2, 'difficile', ARRAY['ertv','module-4','question-courte'], 'ERTV-M4-QC-09', false,
   $mft$Sans trace, la vérification est réputée absente : c'est l'organisation qui est jugée.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Pourquoi l'amplitude admise en voyageurs est-elle structurellement plus large que la simple durée du travail, et où l'exploitant trouve-t-il les maxima applicables ?$mft$,
   $mft$Parce que le scolaire impose des coupures méridiennes entre deux vacations, ce qui étire la journée du matin au soir ; les maxima précis relèvent des décrets et de la convention collective des voyageurs, à vérifier avant de construire le planning.$mft$,
   2, 'difficile', ARRAY['ertv','module-4','question-courte'], 'ERTV-M4-QC-10', false,
   $mft$La logique des vacations + le renvoi aux décrets et à la CCN sont attendus.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ─────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Vous recevez demain un candidat pour un poste de conducteur mixte scolaire et périscolaire. Rédigez la check-list documentaire de l'entretien d'embauche : pour chaque pièce, ce que vous vérifiez et pourquoi.$mft$,
   $mft$Réponse modèle. Titres de conduite : permis D en cours de validité, avec la visite médicale associée au permis à jour (une aptitude médicale expirée rend le conducteur inaffectable) ; l'âge d'accès au permis D est en principe de 21 ans, avec des abaissements possibles selon le parcours de qualification, à confirmer selon la voie suivie par le candidat. Qualification : carte de qualification en cours de validité, adossée à la FIMO voyageurs de 140 heures ou au titre professionnel de conducteur de voyageurs ; échéance de la FCO (35 heures tous les 5 ans) reportée dans le suivi RH pour anticiper le renouvellement. Tachygraphe : carte de conducteur valide pour les services concernés. Spécificité scolaire : honorabilité renforcée du candidat, vérifiée selon les modalités prévues par les textes en vigueur (à confirmer avant de formaliser la procédure), résultat tracé au dossier AVANT toute affectation sur circuit scolaire. Prévention : information sur la politique alcool de l'entreprise, justifiée par le seuil abaissé à 0,2 g/L applicable aux conducteurs de transport en commun. Enfin, chaque pièce est copiée, datée, et son échéance reportée dans l'outil de suivi : un titre expiré découvert en cours de contrat est une faute d'organisation, pas une fatalité.$mft$,
   $mft$Barème /5 : titres de conduite et visite médicale du permis D (1 pt) ; qualification initiale (FIMO voyageurs 140 h ou titre professionnel) et suivi FCO 35 h / 5 ans (1,5 pt) ; carte de conducteur tachygraphe (0,5 pt) ; honorabilité renforcée scolaire avec prudence sur les modalités et traçabilité avant affectation (1 pt) ; politique alcool fondée sur le seuil abaissé et suivi des échéances (1 pt). Erreurs fréquentes : confondre la visite médicale du permis et la visite médicale du travail ; oublier l'échéance FCO ; promettre l'embauche avant la vérification d'honorabilité.$mft$,
   5, 'facile', ARRAY['ertv','module-4','question-redigee'], 'ERTV-M4-QR-01', false,
   $mft$La check-list d'embauche complète, pièce par pièce, avec les prudences réglementaires.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Votre réseau exploite la ligne A (parcours de 23 km) et la ligne B (parcours de 78 km), toutes deux régulières. Expliquez pourquoi elles ne relèvent pas du même cadre de temps de conduite et de repos, et ce que cela change concrètement pour votre exploitation.$mft$,
   $mft$Réponse modèle. Le règlement 561/2006 s'applique aux transports de voyageurs effectués avec des véhicules de plus de 9 places, conducteur compris, mais il exclut les services réguliers dont le parcours de la ligne ne dépasse pas 50 km : ceux-ci relèvent du régime national. La ligne A (23 km) est donc dans l'exception : ses conducteurs se gèrent avec les références nationales (décrets, convention collective). La ligne B (78 km) dépasse le seuil : les règles européennes classiques s'appliquent. Concrètement, l'exploitation ne construit pas les horaires des deux lignes avec les mêmes références : les compteurs suivis ne sont pas identiques, et les données du tachygraphe de la ligne B doivent être téléchargées et analysées régulièrement, avec traitement des anomalies. Le point sensible est le conducteur polyvalent qui passe de la ligne A à la ligne B dans la même semaine : chaque affectation suit le régime de SON service, et l'agent de planning doit connaître le régime applicable avant d'affecter, pas après. Erreur classique à bannir : copier les habitudes de la ligne urbaine sur la ligne longue au motif que « c'est le même métier » : c'est précisément ainsi que naissent les infractions d'organisation.$mft$,
   $mft$Barème /5 : critère d'application correct (plus de 9 places, exception des services réguliers de 50 km ou moins) (1,5 pt) ; qualification exacte des deux lignes (A : régime national, B : 561/2006) (1 pt) ; conséquences d'exploitation : références différentes, contrôle des données tachygraphe sur la B (1,5 pt) ; cas du conducteur polyvalent et vigilance d'affectation (1 pt). Erreurs fréquentes : croire que le 561 couvre tout le transport de voyageurs ; raisonner sur les kilomètres parcourus dans la journée au lieu du parcours de la ligne.$mft$,
   5, 'facile', ARRAY['ertv','module-4','question-redigee'], 'ERTV-M4-QR-02', false,
   $mft$Deux lignes régulières, deux régimes : le seuil des 50 km appliqué à l'exploitation.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Une agence vous commande un circuit occasionnel international de 11 jours consécutifs (France, Suisse, Italie). Construisez votre analyse d'exploitant avant d'accepter : dérogation mobilisable, vérifications préalables, organisation du suivi pendant et après le circuit.$mft$,
   $mft$Réponse modèle. Qualification du service : circuit occasionnel international, donc règlement 561/2006 avec ses spécificités voyageurs. Le problème : en logique classique, le repos hebdomadaire interromprait le circuit en plein séjour. La dérogation mobilisable : la dérogation dite des 12 jours, qui permet, pour un circuit occasionnel international, de reporter le repos hebdomadaire jusqu'à 12 périodes de 24 heures consécutives. Vérifications préalables : les conditions exactes d'application de cette dérogation sont encadrées (nature du service, exigences complémentaires, compensations de repos au retour) et doivent être confirmées dans les textes en vigueur AVANT d'accepter la commande ; vérifier aussi le conducteur pressenti : qualification et titres à jour, historique de conduite et de repos compatible avec un départ longue durée, information claire sur le montage retenu. Pendant le circuit : suivi des données et contact régulier avec le conducteur, plan de secours en cas d'aléa (panne, maladie). Au retour : téléchargement et analyse des données du tachygraphe, planification effective des repos de compensation prévus par le montage, archivage du dossier (vérifications, échanges, données) : c'est cette traçabilité qui prouvera la conformité de l'organisation en cas de contrôle.$mft$,
   $mft$Barème /5 : qualification correcte du service et identification du problème du repos hebdomadaire (1 pt) ; dérogation des 12 jours correctement décrite (report jusqu'à 12 périodes de 24 h, occasionnel international) (1,5 pt) ; prudence sur les conditions exactes à vérifier avant acceptation (1 pt) ; vérifications conducteur et organisation du suivi pendant/après (compensations, données, archivage) (1,5 pt). Erreurs fréquentes : présenter la dérogation comme une suppression du repos ; vendre le circuit avant d'avoir vérifié les conditions ; oublier les compensations au retour.$mft$,
   5, 'moyen', ARRAY['ertv','module-4','question-redigee'], 'ERTV-M4-QR-03', false,
   $mft$Le circuit de 11 jours analysé en exploitant : dérogation, conditions, suivi.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Vos plannings mensuels sont réputés conformes, mais l'absentéisme des conducteurs augmente et les démissions suivent. Analysez ce paradoxe et proposez un plan d'action pour des plannings conformes ET vivables.$mft$,
   $mft$Réponse modèle. Le paradoxe n'en est pas un : la conformité formelle ne mesure pas la vivabilité. Causes typiques : les amplitudes maximales concentrées sur les mêmes conducteurs, les week-ends travaillés qui tombent toujours sur les nouveaux, des coupures subies et mal valorisées, un planning publié au dernier moment, des temps annexes (prise et fin de service, nettoyage, pleins) sous-estimés qui font déborder les journées réelles, et des enchaînements pénibles (sortie tardive puis vacation matinale). Plan d'action : 1) mesurer : absentéisme par type de service et par conducteur sur trois mois, pour objectiver les cases noires ; 2) équité : compteurs visibles de week-ends, de coupures longues et de services ingrats, avec rotation ; 3) visibilité : publication du planning en avance, stabilité des roulements, gestion transparente des demandes ; 4) réalisme : intégrer les temps annexes dans les graphiques et indemniser les coupures conformément à la convention collective ; 5) enchaînements : proscrire la sortie tardive suivie d'une prise matinale ; 6) écoute : croiser les préférences stables (profils du matin, profils du soir) ; 7) suivre les indicateurs et corriger chaque mois. Conclusion : l'absentéisme se fabrique dans les mauvais plannings ; il se résorbe par la conception, pas par les rappels à l'ordre.$mft$,
   $mft$Barème /5 : analyse du paradoxe conformité/vivabilité avec au moins trois causes concrètes (1,5 pt) ; plan d'action structuré : mesure et indicateurs (0,5 pt), équité et rotation (1 pt), visibilité et réalisme des temps annexes/coupures (1 pt), enchaînements et préférences (1 pt). Erreurs fréquentes : répondre uniquement par la discipline ou la prime ; oublier les temps annexes ; proposer un plan sans mesure préalable.$mft$,
   5, 'moyen', ARRAY['ertv','module-4','question-redigee'], 'ERTV-M4-QR-04', false,
   $mft$Du planning conforme au planning vivable : analyse et plan d'action.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Cas pratique chiffré. Un conducteur scolaire a pris son service à 6 h 30 et terminé sa vacation du matin à 9 h 15. Un client demande une excursion de 13 h à 19 h 30 le même jour, puis le conducteur doit assurer sa vacation scolaire du lendemain à 6 h 30. Déroulez la vérification complète avant de répondre au client.$mft$,
   $mft$Réponse modèle. Étape 1, reconstituer la journée : la prise de service à 6 h 30 et une fin d'excursion à 19 h 30 donnent une amplitude d'au moins 13 heures, avant même les temps annexes ; or la fin réelle dépasse presque toujours l'horaire commercial (retour au dépôt, plein, remisage). Cette amplitude se confronte aux maxima applicables, qui relèvent des décrets et de la convention collective voyageurs : à vérifier pour ce type de journée avant toute réponse. Étape 2, les cumuls : additionner la conduite du matin, la conduite de l'excursion et les temps annexes ; vérifier que la journée complète reste dans les limites applicables au service concerné. Étape 3, le lendemain : entre la fin réelle du service et la reprise à 6 h 30, le repos journalier doit tenir intégralement ; si le retour dérape (bouchons, retard du groupe), c'est la reprise du lendemain qui saute : prévoir la marge ou un plan B avant d'accepter. Étape 4, décider et tracer : accepter, aménager (un autre conducteur pour l'excursion) ou refuser ; consigner la vérification horodatée dans l'outil d'exploitation. La réponse au client vient APRÈS ces quatre étapes : un exploitant qui vend la course avant de vérifier organise lui-même sa propre infraction.$mft$,
   $mft$Barème /5 : calcul d'amplitude correct (au moins 13 h) avec intégration des temps annexes et renvoi prudent aux maxima des décrets/CCN (1,5 pt) ; vérification des cumuls de conduite de la journée (1 pt) ; repos journalier avant la reprise du lendemain avec anticipation des dérives horaires (1,5 pt) ; décision tracée et réponse au client seulement après vérification (1 pt). Erreurs fréquentes : raisonner sur l'horaire commercial sans les temps annexes ; oublier la reprise du lendemain ; inventer un maximum d'amplitude chiffré sans le vérifier.$mft$,
   5, 'moyen', ARRAY['ertv','module-4','question-redigee'], 'ERTV-M4-QR-05', false,
   $mft$L'excursion après le scolaire : la vérification complète, chiffres à l'appui.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Chaque rentrée, votre entreprise perd des conducteurs scolaires et peine à recruter. Analysez les causes propres à ce métier et bâtissez un plan de fidélisation réaliste (contrats, plannings, parcours).$mft$,
   $mft$Réponse modèle. Causes structurelles : le poste scolaire cumule le temps partiel subi, des journées éclatées par la coupure méridienne, un faible volume d'heures, une saisonnalité qui vide les paies pendant les vacances, et la concurrence d'autres secteurs qui offrent des horaires continus. Plan de fidélisation. Contrats : assumer le temps partiel en période scolaire en ciblant les profils dont la vie s'y accorde (parents, jeunes retraités, personnes en cumul), garantir un volume d'heures lisible, organiser les cumuls d'emploi en gardant la visibilité sur la charge totale du conducteur. Compléments : proposer du périscolaire, des sorties occasionnelles et des renforts de lignes pour gonfler les heures de ceux qui en veulent. Plannings : équité mesurée des week-ends et des services ingrats, publication en avance, coupures indemnisées conformément à la convention collective, pas d'enchaînements pénibles. Parcours : tutorat des nouveaux, passerelles vers le tourisme et les lignes pour ceux qui veulent évoluer, entretiens réguliers. Recrutement : cooptation par les conducteurs satisfaits, qui reste le canal le plus efficace. Suivi : indicateurs de rotation du personnel et d'absentéisme, revus chaque trimestre. Conclusion : fidéliser coûte toujours moins cher que recruter en boucle sur un marché en pénurie.$mft$,
   $mft$Barème /5 : au moins trois causes structurelles propres au poste scolaire (1,5 pt) ; volet contrats et cumuls organisés (1 pt) ; volet plannings vivables et coupures indemnisées (1 pt) ; volet parcours, tutorat et cooptation (1 pt) ; indicateurs de suivi (0,5 pt). Erreurs fréquentes : répondre uniquement par le salaire ; proposer des temps complets irréalistes sur du scolaire pur ; ignorer la visibilité sur la charge totale en cas de cumul.$mft$,
   5, 'moyen', ARRAY['ertv','module-4','question-redigee'], 'ERTV-M4-QR-06', false,
   $mft$Pénurie scolaire : causes du métier et plan de fidélisation complet.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Lors d'un contrôle en entreprise, l'inspecteur relève qu'un conducteur a enchaîné une sortie de nuit (retour au dépôt à 0 h 45) et une reprise scolaire à 6 h 30 le lendemain. Le conducteur « était volontaire ». Analysez la responsabilité de l'exploitant, les défauts d'organisation en cause et la procédure à instaurer pour éviter la récidive.$mft$,
   $mft$Réponse modèle. Responsabilité : l'exploitant répond des infractions d'organisation : c'est lui qui a affecté, ou laissé s'affecter, un conducteur dont l'intervalle de 5 h 45 entre deux services ne pouvait manifestement pas contenir le repos journalier. Le volontariat du conducteur n'exonère rien : la bonne volonté de celui qui accepte ne rend pas conforme la décision de celui qui affecte. Défauts d'organisation : la sortie tardive a été planifiée seule, sans regarder la journée du lendemain ; aucun contrôle croisé entre le planning des sorties et celui du scolaire ; aucune trace de vérification au moment de l'affectation ; probablement une culture du « dépannage » qui valorise l'arrangement plutôt que la conformité. Procédure à instaurer : 1) règle écrite : toute sortie tardive se planifie AVEC la journée du lendemain ; 2) vérification systématique avant affectation (repos, cumuls, amplitude), horodatée dans l'outil d'exploitation ; 3) blocage logiciel des enchaînements non conformes ; 4) formation des agents de planning à ces contrôles ; 5) analyse a posteriori des données du tachygraphe et traitement documenté des anomalies ; 6) sensibilisation des conducteurs : le volontariat ne couvre personne, ni eux ni l'entreprise.$mft$,
   $mft$Barème /5 : responsabilité de l'exploitant correctement posée, volontariat non exonératoire (1,5 pt) ; démonstration de l'impossibilité du repos journalier dans l'intervalle (1 pt) ; au moins trois défauts d'organisation identifiés (1 pt) ; procédure complète : règle d'enchaînement, vérification horodatée, blocage logiciel, formation, contrôle a posteriori (1,5 pt). Erreurs fréquentes : rejeter la faute sur le seul conducteur ; proposer une décharge signée comme solution ; oublier la traçabilité.$mft$,
   5, 'difficile', ARRAY['ertv','module-4','question-redigee'], 'ERTV-M4-QR-07', false,
   $mft$Le contrôle en entreprise : responsabilité d'organisation et procédure corrective.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Transfert de nuit longue distance (environ 900 km). Vous hésitez entre un conducteur seul avec nuit d'hôtel en route, et un double équipage. Comparez les deux montages (conformité, coût, service) et précisez ce que le double équipage change, et ne change pas, dans vos vérifications.$mft$,
   $mft$Réponse modèle. Conducteur seul : ses limites individuelles de conduite imposent de fractionner le trajet ; le repos journalier se prend en route (nuit d'hôtel), l'arrivée est donc reportée au lendemain. Coût : un seul salaire, plus l'hébergement et l'immobilisation du véhicule ; service : délai long, aléa fatigue sur un trajet de nuit. Double équipage : deux conducteurs se relaient, le véhicule progresse pendant que l'un se repose à bord : le délai se raccourcit nettement et le service devient quasi continu. Mais le montage ne supprime rien : chaque conducteur reste individuellement soumis à ses propres limites de conduite, de pause et de repos selon les logiques du règlement 561/2006, et les conditions précises du double équipage sont à vérifier avant d'engager l'opération. Coût : deux salaires et deux dossiers conformes. Vérifications : ce qui change, c'est le volume, pas la nature : deux cartes de conducteur valides, deux plannings individuels vérifiés avant le départ (repos préalables, cumuls), données du tachygraphe téléchargées et analysées pour chacun au retour. Ce qui ne change pas : les obligations individuelles, l'enregistrement au tachygraphe et la traçabilité des vérifications. Décision : un arbitrage délai/coût, jamais un arbitrage conformité/coût.$mft$,
   $mft$Barème /5 : montage « conducteur seul » correctement décrit (fractionnement, repos en route, délai) (1,5 pt) ; apport réel du double équipage (progression du véhicule, délai) sans lui prêter d'exonération (1,5 pt) ; vérifications individuelles doublées : cartes, plannings, données par conducteur, conditions du montage à vérifier (1,5 pt) ; conclusion d'arbitrage délai/coût et non conformité/coût (0,5 pt). Erreurs fréquentes : additionner les temps des deux conducteurs sur un compteur commun ; croire le repos journalier supprimé ; oublier le contrôle des données des deux cartes.$mft$,
   5, 'difficile', ARRAY['ertv','module-4','question-redigee'], 'ERTV-M4-QR-08', false,
   $mft$Simple ou double équipage : comparaison d'exploitant et vérifications associées.$mft$);

  RAISE NOTICE 'Module 4 ERTV créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $ertvm4$;
