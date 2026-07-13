-- =====================================================================
-- TAXI / VTC : MODULE 7 : SPÉCIFIQUE TAXI (ADS, TAXIMÈTRE, TARIFS)
-- v1 (juillet 2026) : LOT TAXI-VTC
-- Angle candidat : tout le régime propre au taxi : équipements
-- obligatoires, tarification préfectorale A B C D, maraude et
-- stationnement, courses conventionnées CPAM.
-- ⚠ STATUT : active = false (« à valider »). Idempotent.
-- =====================================================================

DO $taxim7$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_l4 uuid;
  v_quiz uuid; v_q uuid; v_ord int := 0;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'taxi-vtc';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation taxi-vtc introuvable.'; END IF;

  INSERT INTO public.blocs (id, code, title, description, "order") VALUES (50, 'TAXI-VTC', 'Taxi et VTC : transport public particulier de personnes', 'Préparation aux examens taxi et VTC (T3P) organisés par les chambres de métiers et de l''artisanat : épreuves communes, spécifiques et pratique.', 50) ON CONFLICT DO NOTHING;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'TAXI-VTC';

  DELETE FROM public.question_bank WHERE source_ref LIKE 'TAXI-M7-%';
  DELETE FROM public.modules WHERE slug = 'taxi-specifique';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 7 : Spécifique taxi : ADS, taximètre et tarifs',
    'taxi-specifique', v_bloc,
    'Tout le régime propre au taxi : équipements obligatoires, tarifs préfectoraux A B C D et suppléments, stationnement et maraude, courses conventionnées et obligations locales.',
    'avance', 300, 70) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 70, true);

  -- ─── Leçon 1 : Les équipements obligatoires du taxi ─────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'equipements-du-taxi',
    'Les équipements obligatoires du taxi',
    $mft$> 🎯 **Objectifs**
> - Identifier les équipements obligatoires qui distinguent le taxi de tout autre véhicule.
> - Comprendre le rôle du taximètre et de sa vérification métrologique.
> - Mesurer les risques encourus en cas de compteur trafiqué ou d'équipement manquant.

## Un véhicule qui se reconnaît au premier regard

Le taxi bénéficie d'une prérogative unique : prendre en charge des clients directement dans la rue, sans réservation. Cette prérogative a une contrepartie stricte : le véhicule doit porter des équipements obligatoires qui permettent au client comme aux agents de contrôle d'identifier immédiatement un taxi en règle, sa commune de rattachement et son régime tarifaire. À l'examen, on attend de vous la liste complète de ces équipements ET la compréhension de la fonction de chacun.

## Le taximètre : le cœur du système

Le taximètre est un compteur horokilométrique homologué : il calcule le prix de la course en combinant la distance parcourue et le temps écoulé, selon la position tarifaire enclenchée. C'est un instrument de mesure réglementé, au même titre qu'une balance de commerçant : il fait l'objet d'une vérification périodique par un organisme de métrologie, matérialisée par une vignette apposée sur l'appareil. Un taximètre non vérifié, déréglé ou plombé de façon suspecte interdit de facturer des courses tant que la situation n'a pas été régularisée par un professionnel habilité.

> ⚠️ **Attention**
> Le compteur trafiqué (distances majorées, temps accéléré) n'est pas une simple irrégularité commerciale : c'est une fraude sur un instrument de mesure réglementé, qui expose à des sanctions pénales et administratives lourdes et met en péril la poursuite même de l'activité. Aucun gain de course ne vaut ce risque.

## Le dispositif lumineux « TAXI »

Le lumineux fixé sur le toit signale le statut du véhicule : il indique notamment si le taxi est libre ou occupé. La convention la plus répandue associe le vert au taxi libre et le rouge au taxi occupé, mais les modalités précises d'affichage sont à vérifier dans les textes en vigueur et les usages de votre département. C'est ce dispositif qui rend la maraude possible : le client repère de loin un taxi disponible, de jour comme de nuit.

## La plaque, l'imprimante et l'affichage des tarifs

| Équipement | Fonction | Risque si absent ou non conforme |
| --- | --- | --- |
| Plaque extérieure | Indique la commune de rattachement et le numéro de l'ADS | Taxi non identifiable : contrôle défavorable |
| Imprimante ou terminal | Délivre une note détaillée au client dans les cas prévus | Litige client indémontrable, manquement aux obligations |
| Affichage des tarifs | Tarifs en vigueur visibles du client | Suspicion sur le prix, contestations facilitées |
| Taximètre vérifié | Calcul du prix opposable au client | Interdiction de facturer une course au compteur |

La plaque et le lumineux disent QUI vous êtes (un taxi rattaché à telle commune, sous telle ADS) ; le taximètre, l'affichage et la note disent COMBIEN et POURQUOI : ensemble, ils fondent la confiance du client et la régularité de votre activité.

## Le contrôle métrologique en pratique

:::flow
1. Vérification périodique | Passage du taximètre chez un organisme agréé de métrologie
2. Contrôle de l'instrument | Exactitude des mesures de distance et de temps
3. Vignette | Apposée sur l'appareil, elle atteste la conformité
4. Non-conformité | Intervention d'un installateur habilité avant toute reprise des courses
:::

> 💡 **Astuce**
> Face à un client qui doute du montant, ne polémiquez pas : montrez la vignette de vérification, l'affichage des tarifs et remettez la note imprimée détaillée. La transparence documentée désamorce la quasi-totalité des contestations.

> 🔍 **Zoom**
> Lors d'un contrôle sur station, l'agent vérifie typiquement la cohérence de l'ensemble : plaque et ADS, lumineux en état, vignette métrologique, affichage des tarifs, capacité à délivrer une note. Un seul élément manquant suffit à transformer un contrôle de routine en procédure.

## ✅ Synthèse

- Équipements obligatoires : **taximètre homologué et vérifié, lumineux TAXI, plaque (commune + numéro d'ADS), imprimante ou terminal pour la note, affichage des tarifs**.
- Le taximètre est un **instrument de mesure réglementé** : vérification périodique par un organisme de métrologie, vignette de conformité.
- Compteur trafiqué = **fraude lourdement sanctionnée** : la transparence (vignette, affichage, note) est votre meilleure protection.$mft$,
    $mft$Les équipements obligatoires du taxi (taximètre homologué, lumineux, plaque ADS, imprimante, affichage des tarifs), la vérification métrologique périodique et les sanctions du compteur trafiqué.$mft$,
    1, 40) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : La tarification préfectorale ──────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'tarifs-reglementes',
    'La tarification préfectorale : positions A, B, C, D',
    $mft$> 🎯 **Objectifs**
> - Décomposer le prix d'une course : prise en charge, kilomètres, temps, suppléments.
> - Comprendre la logique des positions A, B, C et D du taximètre.
> - Savoir pourquoi il faut maîtriser la STRUCTURE des tarifs et non des montants.

## Un prix réglementé, pas un prix libre

Le taxi ne fixe pas librement ses prix : la tarification est encadrée par arrêté préfectoral. Le taximètre applique automatiquement cette grille : votre rôle est d'enclencher la bonne position et d'appliquer les bons suppléments. À l'examen comme en clientèle, l'erreur de position tarifaire est l'erreur la plus coûteuse : elle fausse le prix et engage votre responsabilité.

## Les trois composantes du prix

| Composante | Ce qu'elle rémunère | Quand elle court |
| --- | --- | --- |
| Prise en charge | Le forfait de départ de la course | Dès la prise en charge du client |
| Tarif kilométrique | La distance parcourue | Quand le véhicule roule normalement |
| Tarif horaire | L'attente ou la marche lente | À l'arrêt ou quand le véhicule roule au pas |

Le tarif horaire est le plus mal compris des clients : dans un embouteillage, le compteur ne « tourne pas pour rien », il bascule de la distance vers le temps, car votre véhicule et votre travail restent mobilisés.

## Les positions A, B, C, D : la logique avant tout

La grille type croise deux critères : le moment de la course (jour, ou nuit et dimanches/jours fériés) et le retour du taxi (en charge vers sa station, ou à vide).

| Position | Moment | Retour | Logique |
| --- | --- | --- | --- |
| A | Jour | Retour en charge à la station | Tarif de base |
| B | Nuit, dimanches et fériés | Retour en charge | Majoration liée au moment |
| C | Jour | Retour à vide | Majoration liée au retour non payé |
| D | Nuit, dimanches et fériés | Retour à vide | Cumul des deux majorations |

> ⚠️ **Attention**
> Cette présentation correspond à la grille type : les définitions exactes des positions varient selon les départements. Vérifiez impérativement l'arrêté préfectoral applicable dans votre zone avant l'examen et avant la mise en service.

La logique à expliquer au client comme à l'examinateur : une course en aller simple qui sort de la zone oblige le taxi à revenir à vide, sans client payant. Le tarif majoré du retour à vide compense ce trajet retour non rémunéré : ce n'est pas une pénalité pour le client, c'est l'économie réelle de la course.

## Suppléments et tarif minimum

Des suppléments encadrés peuvent s'ajouter au montant du compteur : par exemple la prise en charge d'un quatrième passager, ou certains bagages. La liste exacte et les conditions de ces suppléments figurent dans l'arrêté applicable localement : elle est à vérifier, ne récitez jamais une liste apprise ailleurs. De même, un tarif minimum de course est prévu : son montant, fixé par arrêté, est également à vérifier.

## La construction du prix, pas à pas

:::flow
1. Prise en charge | Le forfait de départ s'affiche au compteur
2. Kilomètres | La distance court au tarif de la position enclenchée
3. Attente ou marche lente | Le tarif horaire prend le relais à l'arrêt ou au pas
4. Suppléments | Ajoutés en fin de course selon la liste de l'arrêté local
5. Note | Le détail est remis au client dans les cas prévus
:::

> ❌ **Piège à éviter**
> Apprendre par cœur des montants en euros : les tarifs sont revalorisés par arrêté chaque année et varient selon les départements. Le professionnel maîtrise la STRUCTURE (composantes, positions, suppléments) et consulte l'arrêté en vigueur pour les montants.

> 🎓 **Pour l'examen**
> Les questions tarifaires portent presque toujours sur la logique : quelle position pour telle course, quelle composante court dans un embouteillage, pourquoi un aller simple coûte plus cher. Entraînez-vous à raisonner, pas à réciter.

## ✅ Synthèse

- Prix = **prise en charge + kilomètres (selon position) + temps (attente, marche lente) + suppléments encadrés**.
- Positions : **A jour retour en charge, B nuit/fériés retour en charge, C jour retour à vide, D nuit/fériés retour à vide** (grille type, définitions locales à vérifier).
- Retour à vide = tarif majoré : il **compense le trajet retour non payé**.
- Les montants changent chaque année par arrêté : **maîtrisez la structure, vérifiez les montants**.$mft$,
    $mft$Les composantes du prix (prise en charge, kilomètres, temps), la logique des positions A B C D (jour/nuit, retour en charge ou à vide), les suppléments encadrés et le principe de l'arrêté annuel.$mft$,
    2, 45) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : Maraude, stationnement et obligations ─────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'maraude-stationnement-obligations',
    'Maraude, stationnement et obligations du titulaire',
    $mft$> 🎯 **Objectifs**
> - Délimiter où s'exercent la maraude et le stationnement du taxi.
> - Distinguer les refus de course admis des refus interdits.
> - Situer les obligations du titulaire vis-à-vis de son ADS et de la mairie.

## Le privilège de la maraude : dans SA zone

La maraude (circuler en quête de clients qui hèlent le taxi) et le stationnement sur les stations réservées sont le cœur du monopole du taxi. Mais ce privilège s'exerce dans la zone de rattachement de l'ADS, pas au-delà : en dehors de sa zone, le taxi ne peut ni marauder ni stationner en attente de clientèle. Déposer un client hors zone ne vous ouvre aucun droit à y charger un passant au retour : c'est l'une des infractions les plus contrôlées, car elle empiète sur le monopole des taxis locaux.

> 📌 **À retenir**
> L'ADS vous ouvre la maraude et les stations DE VOTRE ZONE. Le lumineux, la plaque et la position au compteur doivent toujours raconter la même histoire qu'un contrôleur peut vérifier en quelques secondes.

## L'obligation d'exploiter

L'ADS n'est pas un simple bien que l'on pourrait laisser dormir : son titulaire est tenu à une exploitation effective et continue de l'autorisation. Les modalités précises de cette obligation (justification, contrôles, conséquences d'une inexploitation prolongée) sont à vérifier auprès de votre autorité locale, mais le principe est constant : une autorisation délivrée pour servir le public doit effectivement servir le public, sous peine d'être remise en cause.

## Prise en charge : le principe de non-discrimination

Le taxi en maraude ou en station prend en charge le client qui se présente : le refus de course est l'exception, jamais la règle de confort.

| Situation | Refus possible ? | Pourquoi |
| --- | --- | --- |
| Client en état d'ivresse manifeste, agressif | Oui, encadré | Sécurité du conducteur et de la course |
| Animal de compagnie ordinaire | Oui, selon les conditions prévues | Tolérance possible mais non systématique |
| Chien guide accompagnant une personne déficiente visuelle | NON, jamais | Le chien guide ne peut pas être refusé |
| Course jugée « trop courte » | NON | La longueur de la course ne justifie pas un refus |
| Client au motif de sa destination dans la zone | NON | Prise en charge non discriminatoire |

> ❌ **Piège à éviter**
> Refuser une personne accompagnée de son chien guide est une discrimination caractérisée, sanctionnable, et l'un des cas les plus cités aux examens comme dans les contrôles. Aucune considération de propreté ou de confort ne le justifie.

> ⚠️ **Attention**
> Le refus pour ivresse manifeste doit rester exceptionnel et fondé sur des faits observables (comportement agressif, incapacité à se tenir) : un simple client éméché mais calme reste un client à transporter.

## Radio-taxi, applications et clientèle réservée

Les centraux radio-taxi et les applications de mise en relation apportent des courses réservées qui complètent la maraude. Elles ne modifient en rien vos obligations : mêmes équipements, même tarification au compteur, mêmes règles de prise en charge. L'application n'est qu'un canal d'apport de clientèle, jamais un régime juridique différent.

## La mairie et le règlement local

L'activité du taxi est organisée localement : le règlement local fixe notamment l'implantation et l'usage des stations, les règles de comportement sur ces stations et les usages propres à la commune. Le professionnel entretient une relation suivie avec la mairie : connaître son règlement local est une obligation pratique, et les questions d'examen y font régulièrement référence.

> 🎓 **Pour l'examen**
> Trois réflexes à ancrer : maraude = MA zone ; refus de course = exception strictement encadrée ; chien guide = jamais refusé. Ces trois points concentrent une grande partie des questions sur les obligations du taxi.

## ✅ Synthèse

- Maraude et stationnement : **uniquement dans la zone de rattachement de l'ADS**.
- ADS : **obligation d'exploitation effective et continue** (modalités locales à vérifier).
- Prise en charge **non discriminatoire** : refus admis seulement pour des motifs encadrés (ivresse manifeste) ; **chien guide jamais refusé** ; course courte = pas un motif.
- Radio-taxi et applications complètent la maraude **sans changer les obligations** ; le règlement local de la mairie s'impose à vous.$mft$,
    $mft$La maraude et le stationnement limités à la zone de l'ADS, l'obligation d'exploitation effective, les refus de course encadrés (chien guide jamais refusé, course courte pas un motif) et le règlement local.$mft$,
    3, 40) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : Courses conventionnées et transport de patients ───────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'courses-conventionnees-social',
    'Courses conventionnées et transport de patients',
    $mft$> 🎯 **Objectifs**
> - Comprendre le conventionnement CPAM du taxi et le transport assis de patients.
> - Dérouler une course conventionnée : prescription, transport, facturation.
> - Identifier les autres marchés contractuels et les obligations comptables associées.

## Le taxi, acteur du transport de patients

Au-delà de la maraude, le taxi occupe une place majeure dans le transport assis professionnalisé de patients : conduire des personnes vers leurs soins (consultations, traitements réguliers, examens) sans nécessiter d'ambulance. Pour de nombreux taxis, en particulier en zone rurale, ces courses conventionnées représentent une part importante du chiffre d'affaires : c'est souvent elles qui rendent l'activité viable là où la maraude est rare.

## Le conventionnement CPAM

Pour que la course soit prise en charge par l'assurance maladie, le taxi doit être conventionné : une convention est signée avec la CPAM, le véhicule est identifié comme conventionné, et la facturation s'effectue directement auprès de l'assurance maladie selon les règles prévues par la convention.

> ⚠️ **Attention**
> Les règles précises de facturation et les remises applicables aux courses conventionnées sont fixées par la convention : elles sont à vérifier auprès de votre CPAM. Ne partez jamais du principe qu'une course conventionnée se facture comme une course au compteur ordinaire.

## La prescription médicale de transport

La clé d'entrée de toute course conventionnée est la prescription médicale de transport : c'est ce document, établi par le médecin, qui justifie la prise en charge du transport par l'assurance maladie. Sans prescription, pas de facturation à la CPAM : le patient devient un client ordinaire qui règle sa course.

:::flow
1. Prescription | Le médecin établit la prescription médicale de transport
2. Vérification | Le taxi conventionné vérifie le document avant la course
3. Transport | Course assurée dans le respect de la convention
4. Facturation | Adressée à l'assurance maladie selon les règles conventionnelles
5. Justificatifs | Prescriptions et factures conservées pour les contrôles
:::

> 📌 **À retenir**
> Trois conditions cumulatives : un taxi CONVENTIONNÉ, une PRESCRIPTION médicale de transport, une facturation CONFORME à la convention. Si l'une manque, la course ne peut pas être réglée par l'assurance maladie.

## La relation avec le patient

Le transport de patients change la nature de la relation : clientèle souvent âgée ou fragilisée, trajets réguliers (traitements itératifs), ponctualité vitale pour les rendez-vous médicaux. Le professionnel adapte son accompagnement : aide à l'installation, discrétion sur les informations de santé entendues en course, régularité qui construit une relation de confiance durable. Cette fidélité est aussi un actif commercial : le patient satisfait vous redemande pour chaque trajet prescrit.

## Les autres marchés contractuels

| Marché | Ce qu'il apporte | Ce qu'il exige |
| --- | --- | --- |
| Contrats scolaires | Courses régulières planifiées | Ponctualité absolue, rigueur avec les mineurs |
| Entreprises | Volume et facturation en compte | Service irréprochable, facturation propre |
| Gares et flux locaux | Clientèle de passage récurrente | Présence organisée, respect des stations |

Ces marchés lissent l'activité sur l'année et réduisent la dépendance à la maraude : un portefeuille équilibré (conventionné, scolaire, entreprises, maraude) est la meilleure protection du chiffre d'affaires.

## Des obligations comptables renforcées

Facturer un tiers payeur public impose une rigueur supérieure : chaque course conventionnée doit pouvoir être justifiée (prescription, date, trajet, facture concordante). La CPAM contrôle, et toute facturation irrégulière expose au remboursement, aux sanctions et à la perte du conventionnement : c'est à dire, pour beaucoup de taxis ruraux, à la perte de l'essentiel de leur activité.

> 💡 **Astuce**
> Traitez chaque course conventionnée comme un dossier : classement systématique des prescriptions et des factures, le jour même. Le temps de classement se compte en minutes ; un contrôle CPAM mal préparé se compte en semaines.

## ✅ Synthèse

- Transport assis professionnalisé : **conventionnement CPAM + prescription médicale de transport + facturation conforme** à la convention (règles et remises à vérifier).
- Part **importante du chiffre d'affaires** de nombreux taxis, surtout ruraux.
- Autres marchés : **scolaire, entreprises, gares** : ils équilibrent l'activité.
- Obligations comptables **renforcées** : justificatifs concordants, contrôles CPAM, conventionnement en jeu.$mft$,
    $mft$Le conventionnement CPAM (véhicule conventionné, prescription médicale de transport, facturation à l'assurance maladie), la part du CA des taxis ruraux, les autres marchés et les obligations comptables renforcées.$mft$,
    4, 40) RETURNING id INTO v_l4;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : Spécifique taxi',
    'Vérifiez le module 7 : équipements du taxi, tarification préfectorale, maraude et courses conventionnées.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$En fin de course, votre client demande une note détaillée. Quel équipement obligatoire du taxi vous permet de la lui délivrer ?$mft$,
    $mft$[
      {"id":"a","label":"L'imprimante ou le terminal relié au taximètre, prévu pour délivrer la note dans les cas réglementés","is_correct":true},
      {"id":"b","label":"Le dispositif lumineux TAXI, qui enregistre les montants","is_correct":false},
      {"id":"c","label":"La plaque extérieure indiquant la commune et le numéro d'ADS","is_correct":false},
      {"id":"d","label":"Aucun : la note se rédige obligatoirement à la main sur papier libre","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-7','qcm-v1'], 'TAXI-M7-QCM-01', false,
    $mft$L'imprimante ou le terminal fait partie des équipements obligatoires du taxi pour délivrer la note. Le lumineux signale la disponibilité et la plaque identifie le véhicule : aucun des deux ne facture, et la note manuscrite improvisée ne remplace pas l'équipement prévu.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un client monte dans votre taxi et s'étonne : le compteur affiche déjà un montant alors que vous n'avez pas encore roulé. Que lui répondez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"C'est la prise en charge : le forfait de départ prévu par la grille tarifaire, affiché dès le début de la course","is_correct":true},
      {"id":"b","label":"C'est un supplément bagages appliqué par défaut","is_correct":false},
      {"id":"c","label":"C'est un dysfonctionnement du compteur, à ignorer","is_correct":false},
      {"id":"d","label":"C'est le tarif horaire de la course précédente","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-7','qcm-v1'], 'TAXI-M7-QCM-02', false,
    $mft$La prise en charge est le forfait de départ, première composante du prix. Les suppléments ne s'appliquent jamais « par défaut », un compteur qui dysfonctionne ne se néglige pas, et le taximètre est remis à zéro entre les courses.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$À la station, une personne déficiente visuelle se présente avec son chien guide. Un collègue vous souffle que « le chien va salir la banquette ». Que faites-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Vous prenez en charge la personne avec son chien guide : ce refus est interdit, sans exception","is_correct":true},
      {"id":"b","label":"Vous refusez poliment en invoquant la propreté du véhicule","is_correct":false},
      {"id":"c","label":"Vous acceptez uniquement si le chien voyage dans le coffre","is_correct":false},
      {"id":"d","label":"Vous demandez un supplément animal librement fixé par vous","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-7','qcm-v1'], 'TAXI-M7-QCM-03', false,
    $mft$Le chien guide ne peut jamais être refusé : la propreté n'est pas un motif, le coffre est indigne et dangereux pour l'animal, et aucun supplément ne se fixe « librement » dans un régime de tarifs réglementés.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Votre taxi est conventionné. Un patient présente une prescription médicale de transport pour se rendre à sa séance de soins. Qui règle la course ?$mft$,
    $mft$[
      {"id":"a","label":"La course est facturée à l'assurance maladie selon les règles de la convention CPAM","is_correct":true},
      {"id":"b","label":"Le patient paie plein tarif sans aucune prise en charge possible","is_correct":false},
      {"id":"c","label":"La mairie de rattachement de votre ADS règle la course","is_correct":false},
      {"id":"d","label":"L'établissement de soins paie systématiquement toutes les courses de patients","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-7','qcm-v1'], 'TAXI-M7-QCM-04', false,
    $mft$Taxi conventionné + prescription médicale = facturation à l'assurance maladie selon la convention. Le patient prescrit n'est pas un client plein tarif, la mairie ne finance pas les courses, et l'établissement de soins n'est pas le payeur de droit commun.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Lors d'un contrôle, l'agent examine la vignette apposée sur votre taximètre. Que cherche-t-il à vérifier ?$mft$,
    $mft$[
      {"id":"a","label":"Que le taximètre a passé la vérification périodique de métrologie auprès d'un organisme agréé et mesure exactement","is_correct":true},
      {"id":"b","label":"Que votre assurance professionnelle est à jour","is_correct":false},
      {"id":"c","label":"Que votre ADS est bien exploitée de façon continue","is_correct":false},
      {"id":"d","label":"Que les tarifs de l'année sont correctement affichés dans l'habitacle","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-7','qcm-v1'], 'TAXI-M7-QCM-05', false,
    $mft$La vignette atteste la vérification métrologique périodique de l'instrument de mesure. L'assurance, l'exploitation de l'ADS et l'affichage des tarifs se contrôlent par d'autres moyens : la vignette ne parle que du taximètre.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Dimanche, 2 h du matin : vous déposez un client dans une commune éloignée hors de votre zone et vous rentrez à vide. Selon la grille type des positions tarifaires, laquelle enclenchez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"La position D : course de nuit (ou dimanche/férié) avec retour à vide","is_correct":true},
      {"id":"b","label":"La position A : c'est la position par défaut de toutes les courses","is_correct":false},
      {"id":"c","label":"La position B : la nuit suffit à déterminer la position","is_correct":false},
      {"id":"d","label":"La position C : le retour à vide suffit à déterminer la position","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-7','qcm-v1'], 'TAXI-M7-QCM-06', false,
    $mft$La grille type croise le moment ET le retour : nuit + retour à vide = D. La position A correspond au jour avec retour en charge, B ne couvre que le critère du moment et C que celui du retour : chacune ignore la moitié de la situation (définitions locales à vérifier dans l'arrêté).$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Vous venez de déposer un client dans une commune située hors de votre zone de rattachement. Sur place, un passant hèle votre taxi. Que faites-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Vous ne le prenez pas en charge : la maraude hors de la zone de votre ADS vous est interdite","is_correct":true},
      {"id":"b","label":"Vous le prenez : un client qui hèle un taxi libre ne se refuse jamais","is_correct":false},
      {"id":"c","label":"Vous le prenez si la course le ramène vers votre zone","is_correct":false},
      {"id":"d","label":"Vous le prenez en éteignant le lumineux pour rester discret","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-7','qcm-v1'], 'TAXI-M7-QCM-07', false,
    $mft$La maraude s'exerce uniquement dans la zone de l'ADS : charger un passant hors zone empiète sur le monopole des taxis locaux. Ni la direction de la course ni la « discrétion » ne changent l'interdiction, et le principe de prise en charge ne vaut que là où vous avez le droit de marauder.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un candidat révise en apprenant par cœur les montants en euros de la prise en charge et du kilomètre de son département. Pourquoi cette stratégie est-elle fragile ?$mft$,
    $mft$[
      {"id":"a","label":"Les montants sont fixés par arrêté et revalorisés chaque année : c'est la structure de la tarification qu'il faut maîtriser","is_correct":true},
      {"id":"b","label":"Les montants sont confidentiels et ne doivent pas être connus des chauffeurs","is_correct":false},
      {"id":"c","label":"Chaque chauffeur fixe librement ses montants, il n'y a rien à apprendre","is_correct":false},
      {"id":"d","label":"Les montants sont identiques dans toute la France et ne changent jamais","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-7','qcm-v1'], 'TAXI-M7-QCM-08', false,
    $mft$Les montants évoluent par arrêté annuel et varient localement : seul le raisonnement (composantes, positions, suppléments) reste stable. Ils ne sont ni confidentiels (ils s'affichent dans le véhicule), ni libres (tarification réglementée), ni uniformes et figés.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Vous reprenez un taxi dans une petite commune rurale. Le cédant vous précise que « l'essentiel du chiffre se fait avec la CPAM ». De quoi parle-t-il ?$mft$,
    $mft$[
      {"id":"a","label":"Des courses conventionnées de transport assis de patients, facturées à l'assurance maladie, part majeure du CA de nombreux taxis ruraux","is_correct":true},
      {"id":"b","label":"Des courses de maraude nocturne autour des lieux festifs","is_correct":false},
      {"id":"c","label":"D'un contrat publicitaire affiché sur les portières","is_correct":false},
      {"id":"d","label":"Des transferts touristiques vers les aéroports internationaux","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-7','qcm-v1'], 'TAXI-M7-QCM-09', false,
    $mft$En zone rurale, le transport conventionné de patients représente souvent la part dominante de l'activité. La maraude nocturne et les transferts touristiques y sont marginaux, et la publicité n'a rien à voir avec la CPAM.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Un chauffeur fait discrètement régler son taximètre pour majorer les distances mesurées. Comment qualifier ce comportement et ses conséquences ?$mft$,
    $mft$[
      {"id":"a","label":"Fraude sur un instrument de mesure réglementé : sanctions pénales et administratives lourdes, activité en péril","is_correct":true},
      {"id":"b","label":"Simple pratique commerciale déloyale, réglée par un avertissement de la mairie","is_correct":false},
      {"id":"c","label":"Aucun risque s'il rembourse les clients qui s'en plaignent","is_correct":false},
      {"id":"d","label":"Défaut technique bénin, corrigé à la prochaine vérification sans autre suite","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-7','qcm-v1'], 'TAXI-M7-QCM-10', false,
    $mft$Le taximètre est un instrument de mesure réglementé : le trafiquer est une fraude sanctionnée pénalement et administrativement. Ce n'est ni une affaire d'avertissement municipal, ni une question de remboursement amiable, ni un défaut technique fortuit puisque la manipulation est volontaire.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Un titulaire d'ADS n'exploite plus son autorisation depuis de longs mois : il « attend des jours meilleurs » en travaillant ailleurs. Quel principe risque de lui être opposé ?$mft$,
    $mft$[
      {"id":"a","label":"L'obligation d'exploitation effective et continue de l'ADS, dont la méconnaissance peut remettre en cause l'autorisation","is_correct":true},
      {"id":"b","label":"Aucun : l'ADS est un bien privé que l'on gèle librement aussi longtemps qu'on veut","is_correct":false},
      {"id":"c","label":"L'obligation de transformer son ADS en autorisation VTC après une période d'inactivité","is_correct":false},
      {"id":"d","label":"L'obligation de céder immédiatement son véhicule à la commune","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-7','qcm-v1'], 'TAXI-M7-QCM-11', false,
    $mft$L'ADS doit être exploitée de façon effective et continue (modalités précises à vérifier localement) : la laisser dormir expose le titulaire sur son autorisation. Elle n'est pas un bien librement gelable, ne se « transforme » pas en autorisation VTC, et la commune ne confisque pas le véhicule.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un client conteste : « Pourquoi mon aller simple vers la commune voisine coûte-t-il plus cher au kilomètre que le même trajet quand vous ramenez un client au retour ? » Quelle est la bonne explication ?$mft$,
    $mft$[
      {"id":"a","label":"Le tarif majoré compense le retour à vide : le taxi rentre vers sa zone sans client payant, et ce trajet a un coût réel","is_correct":true},
      {"id":"b","label":"Les clients qui sortent de la zone paient une taxe spéciale de franchissement","is_correct":false},
      {"id":"c","label":"Le carburant est plus cher en dehors de la zone de rattachement","is_correct":false},
      {"id":"d","label":"Le chauffeur applique la majoration de son choix quand la course lui déplaît","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-7','qcm-v1'], 'TAXI-M7-QCM-12', false,
    $mft$La logique des positions « retour à vide » est économique : le prix couvre aussi le retour non rémunéré vers la zone. Il n'existe ni taxe de franchissement, ni surcoût carburant lié à la zone, et aucune majoration ne relève de l'humeur du chauffeur dans un régime de tarifs réglementés.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Quelles sont les deux informations portées par la plaque fixée à l'extérieur du taxi ?$mft$,
   $mft$La commune de rattachement et le numéro de l'autorisation de stationnement (ADS).$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-7','question-courte'], 'TAXI-M7-QC-01', false,
   $mft$La plaque identifie le taxi : commune + numéro d'ADS.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Citez les trois composantes principales du prix d'une course de taxi calculé au taximètre.$mft$,
   $mft$La prise en charge (forfait de départ), le tarif kilométrique (distance) et le tarif horaire (attente ou marche lente).$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-7','question-courte'], 'TAXI-M7-QC-02', false,
   $mft$Les trois composantes, avant suppléments éventuels.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Quel document, établi par le médecin, conditionne la facturation d'une course de taxi conventionné à l'assurance maladie ?$mft$,
   $mft$La prescription médicale de transport.$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-7','question-courte'], 'TAXI-M7-QC-03', false,
   $mft$Sans prescription, pas de facturation à la CPAM.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$À quoi sert la vérification périodique du taximètre et par qui est-elle réalisée ?$mft$,
   $mft$Elle garantit l'exactitude de l'instrument de mesure (distance et temps) ; elle est réalisée par un organisme de métrologie agréé et matérialisée par une vignette apposée sur l'appareil.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-7','question-courte'], 'TAXI-M7-QC-04', false,
   $mft$Exactitude de la mesure + organisme agréé + vignette.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Vous êtes bloqué au pas dans un embouteillage avec un client à bord. Quelle composante tarifaire prend le relais du tarif kilométrique, et pourquoi ?$mft$,
   $mft$Le tarif horaire (attente ou marche lente) : à l'arrêt ou au pas, le compteur bascule de la distance vers le temps, car le véhicule et le conducteur restent mobilisés pour le client.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-7','question-courte'], 'TAXI-M7-QC-05', false,
   $mft$Bascule distance vers temps en marche lente.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$À la station, un client demande une course de 500 mètres. Pouvez-vous la refuser au motif qu'elle est trop courte ?$mft$,
   $mft$Non : la longueur de la course ne justifie pas un refus. La prise en charge est non discriminatoire et le refus de course reste une exception strictement encadrée.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-7','question-courte'], 'TAXI-M7-QC-06', false,
   $mft$Course courte = jamais un motif de refus.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Où un taxi peut-il exercer la maraude et stationner en attente de clientèle ?$mft$,
   $mft$Uniquement dans la zone de rattachement de son ADS : sur les stations et la voirie de sa zone, dans le respect du règlement local. Hors zone, ni maraude ni stationnement en attente de clients.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-7','question-courte'], 'TAXI-M7-QC-07', false,
   $mft$Maraude et stations = la zone de l'ADS, pas au-delà.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Citez trois marchés qui complètent la maraude dans l'activité d'un taxi.$mft$,
   $mft$Par exemple : les courses conventionnées CPAM (transport assis de patients), les contrats scolaires, les contrats d'entreprises, la clientèle des gares.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-7','question-courte'], 'TAXI-M7-QC-08', false,
   $mft$Trois marchés distincts parmi conventionné, scolaire, entreprises, gares.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Expliquez en une ou deux phrases la logique économique qui distingue les positions « retour en charge » des positions « retour à vide ».$mft$,
   $mft$Quand le taxi revient à vide vers sa zone après un aller simple, ce trajet retour n'est payé par personne : le tarif « retour à vide » est donc majoré pour couvrir ce coût, alors que le retour en charge est rémunéré par un autre client.$mft$,
   2, 'difficile', ARRAY['taxi-vtc','module-7','question-courte'], 'TAXI-M7-QC-09', false,
   $mft$La majoration compense le retour non rémunéré.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un titulaire voisin laisse son ADS inexploitée depuis des mois en attendant « que ça remonte ». Quel principe méconnaît-il et à quoi s'expose-t-il ?$mft$,
   $mft$Il méconnaît l'obligation d'exploitation effective et continue de l'ADS : une inexploitation prolongée peut remettre en cause son autorisation (modalités précises à vérifier auprès de l'autorité locale).$mft$,
   2, 'difficile', ARRAY['taxi-vtc','module-7','question-courte'], 'TAXI-M7-QC-10', false,
   $mft$Exploitation effective et continue exigée, autorisation en jeu.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ─────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$En fin de course, un client conteste le montant affiché et vous accuse d'avoir un « compteur trafiqué ». Expliquez ce que garantit le dispositif de contrôle métrologique du taximètre, puis décrivez votre réponse professionnelle face à ce client.$mft$,
   $mft$Réponse modèle. Ce que garantit le dispositif : le taximètre est un instrument de mesure réglementé et homologué, qui calcule le prix en combinant la distance et le temps selon la position tarifaire enclenchée ; il subit une vérification périodique par un organisme de métrologie agréé, attestée par une vignette apposée sur l'appareil ; le trafiquer constitue une fraude lourdement sanctionnée, pénalement et administrativement, au point de mettre l'activité en péril : un professionnel n'a objectivement aucun intérêt à tricher. La réponse professionnelle : garder son calme et ne pas se vexer ; montrer la vignette de vérification et l'affichage des tarifs visible dans le véhicule ; expliquer simplement la composition du prix (prise en charge, kilomètres selon la position, temps d'attente ou de marche lente, suppléments éventuels prévus par l'arrêté) ; remettre la note détaillée, qui permet au client de tout vérifier point par point ; indiquer poliment les voies de réclamation s'il maintient sa contestation. Ce qu'il ne faut pas faire : polémiquer, refuser la note ou brader le prix « pour acheter la paix » : la transparence documentée est la meilleure défense du chauffeur, et elle protège aussi l'image de toute la profession.$mft$,
   $mft$Barème /5 : rôle du taximètre (instrument de mesure réglementé, calcul distance + temps) (1 pt) ; vérification métrologique par organisme agréé et vignette (1,5 pt) ; réponse professionnelle concrète : calme, vignette et affichage montrés, note détaillée remise, voie de réclamation indiquée (2 pts) ; sanctions du compteur trafiqué évoquées (0,5 pt). Erreurs fréquentes : répondre sur le ton du conflit ; brader la course au lieu de démontrer par les documents ; oublier la note.$mft$,
   5, 'facile', ARRAY['taxi-vtc','module-7','question-redigee'], 'TAXI-M7-QR-01', false,
   $mft$La métrologie du taximètre et la gestion d'une contestation de prix.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Un candidat débutant vous demande « comment se calcule le prix d'une course de taxi ». Expliquez-lui la structure complète de la tarification : composantes, positions tarifaires, suppléments, et pourquoi il ne doit pas apprendre les montants par cœur.$mft$,
   $mft$Réponse modèle. Les composantes : le prix se construit avec la prise en charge (forfait de départ affiché dès le début de la course), le tarif kilométrique (la distance, au tarif de la position enclenchée) et le tarif horaire (l'attente ou la marche lente : à l'arrêt ou au pas, le compteur bascule de la distance vers le temps). Les positions : la grille type croise deux critères, le moment de la course (jour, ou nuit et dimanches/fériés) et le retour du taxi (en charge ou à vide) : A jour retour en charge, B nuit/fériés retour en charge, C jour retour à vide, D nuit/fériés retour à vide ; les définitions exactes varient selon les départements et sont à vérifier dans l'arrêté préfectoral local. La logique : le retour à vide est majoré car il compense un trajet retour non rémunéré. Les suppléments : encadrés par l'arrêté (par exemple quatrième passager, certains bagages : liste locale à vérifier), jamais librement inventés ; un tarif minimum de course est également prévu (montant à vérifier). Enfin, les montants sont fixés par arrêté et revalorisés chaque année : c'est la structure qui est stable et qu'il faut maîtriser, les montants se consultent dans l'arrêté en vigueur.$mft$,
   $mft$Barème /5 : trois composantes exactes avec leur rôle (1,5 pt) ; grille A B C D avec les deux critères croisés et mention de la vérification locale (1,5 pt) ; logique du retour à vide expliquée (1 pt) ; suppléments encadrés + tarif minimum + principe de l'arrêté annuel (1 pt). Erreurs fréquentes : réciter des montants en euros ; présenter les positions comme identiques partout et immuables ; oublier le tarif horaire.$mft$,
   5, 'facile', ARRAY['taxi-vtc','module-7','question-redigee'], 'TAXI-M7-QR-02', false,
   $mft$La structure tarifaire complète expliquée à un débutant.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Cas pratique : samedi 23 h 30, vous chargez un client à votre station ; il demande un aller simple vers une commune située hors de votre zone, avec un passage encombré au centre-ville et deux grosses valises ; vous rentrerez à vide. Décomposez tout ce qui entrera dans le prix final et justifiez la position tarifaire enclenchée selon la grille type.$mft$,
   $mft$Réponse modèle. Position tarifaire : la course a lieu de nuit et se termine par un retour à vide vers la zone : selon la grille type, c'est la position D (nuit/fériés, retour à vide), la plus majorée car elle cumule les deux critères ; les définitions exactes des positions restant locales, on vérifie l'arrêté préfectoral de sa zone. Décomposition du prix : d'abord la prise en charge, forfait de départ affiché dès le début ; ensuite les kilomètres parcourus, comptés au tarif de la position D ; dans le passage encombré du centre-ville, le compteur bascule sur le tarif horaire (marche lente) : le temps remplace la distance tant que le véhicule avance au pas ; enfin, les suppléments éventuels prévus par l'arrêté local, par exemple pour certains bagages : la liste et les conditions exactes sont à vérifier, on n'applique jamais un supplément qui ne figure pas dans l'arrêté. En fin de course, remise de la note détaillée dans les cas prévus. Justification à donner au client si besoin : le tarif majoré ne le pénalise pas arbitrairement, il couvre le retour à vide du taxi vers sa zone, trajet qu'aucun client ne paie.$mft$,
   $mft$Barème /5 : position D identifiée avec les deux critères (nuit + retour à vide) et réserve de vérification locale (1,5 pt) ; décomposition complète : prise en charge, kilomètres, bascule sur le tarif horaire en marche lente (2 pts) ; suppléments rattachés à la liste de l'arrêté local, sans invention (1 pt) ; note remise et logique du retour à vide expliquée (0,5 pt). Erreurs fréquentes : choisir B en ne voyant que la nuit ; chiffrer le prix en euros ; ajouter un supplément bagages « automatique » sans référence à l'arrêté.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-7','question-redigee'], 'TAXI-M7-QR-03', false,
   $mft$Cas pratique nocturne : position D et construction du prix.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Trois situations se présentent successivement à votre station : (1) une personne déficiente visuelle accompagnée de son chien guide ; (2) un client en état d'ivresse manifeste, titubant et agressif ; (3) un client qui demande une course de 600 mètres. Pour chaque situation, dites si un refus est possible et justifiez votre décision en rappelant le principe général applicable.$mft$,
   $mft$Réponse modèle. Principe général : la prise en charge du taxi est non discriminatoire ; le refus de course est une exception strictement encadrée, jamais une commodité. Situation 1 : refus impossible, sans aucune exception : le chien guide accompagnant une personne déficiente visuelle ne peut pas être refusé ; ni la propreté, ni le confort, ni un autre prétexte ne le justifient ; refuser constituerait une discrimination sanctionnable. Situation 2 : refus possible, car l'ivresse manifeste associée à un comportement agressif menace la sécurité du conducteur et le bon déroulement de la course ; ce refus doit rester fondé sur des faits observables (titubements, agressivité) : un client simplement éméché mais calme reste un client à transporter ; on refuse avec courtoisie et sans provocation, en se protégeant. Situation 3 : refus impossible : la brièveté de la course n'est pas un motif admis ; le client de 600 mètres a le même droit à la prise en charge que celui d'une longue course, et le tarif minimum de course prévu par l'arrêté (montant à vérifier) évite que la course soit économiquement absurde. Conclusion : sur trois demandes, une seule autorise le refus, et uniquement pour des raisons de sécurité caractérisées.$mft$,
   $mft$Barème /5 : principe de non-discrimination posé (1 pt) ; chien guide : refus impossible, discrimination sanctionnable (1,5 pt) ; ivresse manifeste : refus possible, fondé sur des faits observables et exercé avec courtoisie (1,5 pt) ; course courte : refus impossible, mention du tarif minimum (1 pt). Erreurs fréquentes : accepter le refus du chien guide « pour hygiène » ; refuser tout client alcoolisé même calme ; croire qu'une course courte se refuse librement.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-7','question-redigee'], 'TAXI-M7-QR-04', false,
   $mft$Trois demandes de prise en charge : le tri entre refus admis et interdits.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Décrivez la procédure complète d'une course conventionnée type, depuis l'appel du patient jusqu'à l'encaissement : conditions préalables, documents à vérifier, déroulement du transport et facturation.$mft$,
   $mft$Réponse modèle. Conditions préalables : le taxi doit être conventionné : convention signée avec la CPAM et véhicule identifié comme conventionné ; sans conventionnement, la course ne peut pas être réglée par l'assurance maladie. À l'appel : vérifier que le patient dispose d'une prescription médicale de transport établie par le médecin : c'est la clé d'entrée de toute la procédure ; sans prescription, le patient reste un client ordinaire qui paie sa course. Au départ : contrôler la prescription, noter les éléments de la course (date, trajet) qui devront concorder avec la facture. Pendant le transport : ponctualité stricte (rendez-vous médical), accompagnement adapté à une clientèle souvent âgée ou fragilisée, discrétion sur les informations de santé entendues. Après la course : facturation adressée à l'assurance maladie selon les règles prévues par la convention, remises comprises : ces règles précises sont à vérifier auprès de sa CPAM, car la course conventionnée ne se facture pas comme une course ordinaire. Enfin : classement systématique des justificatifs (prescription, facture) le jour même, car la CPAM contrôle la concordance ; une facturation irrégulière expose au remboursement, aux sanctions et à la perte du conventionnement, donc d'une part souvent majeure du chiffre d'affaires.$mft$,
   $mft$Barème /5 : conditions préalables (conventionnement, véhicule identifié) (1 pt) ; prescription médicale vérifiée comme clé d'entrée (1,5 pt) ; déroulement adapté (ponctualité, accompagnement, discrétion) (1 pt) ; facturation à la CPAM selon la convention avec réserve de vérification + classement des justificatifs et enjeu du contrôle (1,5 pt). Erreurs fréquentes : transporter sans vérifier la prescription ; facturer comme une course ordinaire ; négliger l'archivage des justificatifs.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-7','question-redigee'], 'TAXI-M7-QR-05', false,
   $mft$La course conventionnée déroulée de bout en bout.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Vous venez d'obtenir une ADS dans une commune et vous préparez la mise en service de votre véhicule. Établissez votre plan d'action : équipements à installer et à faire vérifier, points de contrôle avant la première course, démarches auprès des acteurs locaux.$mft$,
   $mft$Réponse modèle. Équipements à installer : le taximètre homologué, à faire vérifier par un organisme de métrologie agréé (vignette de conformité apposée) ; le dispositif lumineux TAXI en état de fonctionnement, signalant libre ou occupé (modalités précises d'affichage à vérifier dans les textes et usages locaux) ; la plaque extérieure portant la commune de rattachement et le numéro de l'ADS ; l'imprimante ou le terminal permettant de délivrer la note dans les cas prévus ; l'affichage des tarifs en vigueur, visible du client. Points de contrôle avant la première course : cohérence de l'ensemble (plaque, lumineux, vignette, affichage), essai du compteur sur chaque position tarifaire, test d'impression d'une note. Démarches locales : prendre connaissance du règlement local auprès de la mairie (implantation et usage des stations, règles de comportement), récupérer l'arrêté tarifaire en vigueur pour connaître les montants de l'année, les suppléments admis et le tarif minimum (à vérifier chaque année), et organiser son apport de clientèle (radio-taxi, applications) sans oublier que ces canaux ne modifient aucune obligation. Enfin, garder à l'esprit l'obligation d'exploitation effective et continue de l'ADS : la mise en service rapide et régulière fait partie des obligations du titulaire (modalités à vérifier).$mft$,
   $mft$Barème /5 : les cinq équipements obligatoires cités avec leur fonction (2 pts) ; vérification métrologique et vignette avant mise en service (1 pt) ; démarches locales : règlement local en mairie + arrêté tarifaire de l'année (1,5 pt) ; mention de l'exploitation effective et continue (0,5 pt). Erreurs fréquentes : oublier l'affichage des tarifs ou l'imprimante ; négliger le règlement local ; croire la vérification métrologique facultative à la mise en service.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-7','question-redigee'], 'TAXI-M7-QR-06', false,
   $mft$Check-list de mise en service : équipements, contrôles, démarches locales.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un collègue affirme : « L'ADS, c'est mon bien : je maraude où je veux, je refuse les clients qui ne m'arrangent pas, et je peux la laisser dormir si mes contrats d'entreprise me suffisent. » Analysez et corrigez chacune de ces trois affirmations en vous appuyant sur les règles applicables.$mft$,
   $mft$Réponse modèle. Affirmation 1 : « je maraude où je veux » : faux. La maraude et le stationnement en attente de clientèle s'exercent uniquement dans la zone de rattachement de l'ADS ; hors zone, charger un passant qui hèle est interdit, même après y avoir déposé un client : c'est un empiètement sur le monopole des taxis locaux, très contrôlé. Affirmation 2 : « je refuse qui je veux » : faux. La prise en charge est non discriminatoire ; le refus est une exception encadrée : l'ivresse manifeste avec comportement dangereux peut le justifier, mais le chien guide ne se refuse jamais, et une course jugée trop courte n'est pas un motif ; refuser par convenance expose à des sanctions. Affirmation 3 : « je peux la laisser dormir » : faux. Le titulaire est tenu à une exploitation effective et continue de son autorisation : une ADS durablement inexploitée peut être remise en cause (modalités précises à vérifier auprès de l'autorité locale) ; les contrats d'entreprise complètent l'activité mais ne dispensent pas d'exploiter l'autorisation. Conclusion : l'ADS n'est pas un bien de pure propriété privée dont on disposerait librement : c'est une autorisation assortie d'obligations territoriales, sociales et d'exploitation.$mft$,
   $mft$Barème /5 : maraude limitée à la zone, avec le cas du retour hors zone (1,5 pt) ; refus encadrés : non-discrimination, chien guide, course courte (1,5 pt) ; obligation d'exploitation effective et continue avec réserve de vérification (1,5 pt) ; conclusion sur la nature de l'ADS (autorisation avec obligations) (0,5 pt). Erreurs fréquentes : valider la maraude hors zone « au retour » ; oublier le chien guide ; traiter l'ADS comme un simple placement patrimonial.$mft$,
   5, 'difficile', ARRAY['taxi-vtc','module-7','question-redigee'], 'TAXI-M7-QR-07', false,
   $mft$Trois idées reçues sur l'ADS analysées et corrigées.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Taxi rural, 60 % de votre activité provient de courses conventionnées. Votre CPAM annonce un contrôle de facturation. Construisez votre plan : documents à rassembler, points de conformité à vérifier avant le contrôle, et plan d'action durable pour sécuriser cette part de votre chiffre d'affaires.$mft$,
   $mft$Réponse modèle. Documents à rassembler : la convention CPAM en vigueur ; l'ensemble des prescriptions médicales de transport correspondant aux courses facturées ; les factures émises à l'assurance maladie ; les éléments des courses (dates, trajets) permettant de démontrer la concordance entre prescription, course réelle et facture. Points de conformité à vérifier : chaque facture correspond à une prescription valable ; les règles de facturation et les remises prévues par la convention ont été appliquées (règles précises à vérifier auprès de sa CPAM) ; le véhicule était bien conventionné sur toute la période ; aucune course ordinaire n'a été facturée comme conventionnée. Plan d'action durable : instaurer un classement systématique des justificatifs le jour même de chaque course ; tenir une comptabilité rigoureuse à la hauteur des obligations renforcées qu'impose la facturation d'un tiers payeur public ; se former aux évolutions de la convention ; enfin, diversifier l'activité (contrats scolaires, entreprises, clientèle des gares, maraude) pour réduire la dépendance à un payeur unique : à 60 % du chiffre d'affaires, la perte du conventionnement serait existentielle, et c'est précisément ce que risque une facturation irrégulière (remboursements, sanctions, déconventionnement).$mft$,
   $mft$Barème /5 : documents complets et concordants (prescriptions, factures, convention) (1,5 pt) ; points de conformité pertinents avec réserve de vérification des règles conventionnelles (1,5 pt) ; plan durable : classement immédiat, comptabilité renforcée, veille (1 pt) ; analyse du risque de dépendance et diversification (1 pt). Erreurs fréquentes : se présenter au contrôle sans concordance prescription/facture ; considérer les remises conventionnelles comme optionnelles ; ignorer le risque stratégique de la dépendance à la CPAM.$mft$,
   5, 'difficile', ARRAY['taxi-vtc','module-7','question-redigee'], 'TAXI-M7-QR-08', false,
   $mft$Contrôle CPAM : préparation documentaire et sécurisation du CA conventionné.$mft$);

  RAISE NOTICE 'Module 7 taxi (specifique) cree : module %, 4 lecons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, a valider).', v_module;
END $taxim7$;
