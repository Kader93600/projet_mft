-- =====================================================================
-- TAXI / VTC (T3P) : MODULE 3 : GÉRER SON ACTIVITÉ T3P
-- v1 (juillet 2026)
-- Statuts d'exercice, coût de revient et point mort, facturation/TVA,
-- assurances et risques du chauffeur indépendant.
-- ⚠ STATUT : active = false (« à valider »). Idempotent.
-- =====================================================================

DO $taxim3$
DECLARE
  v_formation uuid;
  v_bloc int;
  v_module uuid;
  v_l1 uuid; v_l2 uuid; v_l3 uuid; v_l4 uuid;
  v_quiz uuid; v_q uuid; v_ord int := 0;
BEGIN
  INSERT INTO public.blocs (id, code, title, description, "order") VALUES (50, 'TAXI-VTC', 'Taxi et VTC : transport public particulier de personnes', 'Préparation aux examens taxi et VTC (T3P) organisés par les chambres de métiers et de l''artisanat : épreuves communes, spécifiques et pratique.', 50) ON CONFLICT DO NOTHING;

  SELECT id INTO v_formation FROM public.formations WHERE slug = 'taxi-vtc';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation taxi-vtc introuvable.'; END IF;
  SELECT id INTO v_bloc FROM public.blocs WHERE code = 'TAXI-VTC';

  DELETE FROM public.question_bank WHERE source_ref LIKE 'TAXI-M3-%';
  DELETE FROM public.modules WHERE slug = 'taxi-vtc-gestion';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 3 : Gérer son activité T3P',
    'taxi-vtc-gestion', v_bloc,
    'Choisir son statut, calculer son prix de revient et sa rentabilité, facturer, s''assurer et piloter sa micro-entreprise ou sa société de transport de personnes.',
    'intermediaire', 330, 30) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 30, true);

  -- ─── Leçon 1 : Choisir son statut d'exercice ───────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'statuts-exercice',
    'Choisir son statut d''exercice',
    $mft$> 🎯 **Objectifs**
> - Distinguer les grandes formes d'exercice du transport public particulier de personnes.
> - Comparer micro-entreprise, entreprise individuelle au réel et société (EURL, SASU).
> - Situer le salarié et le locataire-gérant par rapport au titulaire d'une ADS taxi.

## Un choix qui engage vos revenus et votre protection

Avant même la première course, une décision conditionne tout le reste : sous quelle forme allez-vous exercer ? Ce choix détermine ce que vous paierez en cotisations, ce que vous pourrez déduire, votre protection en cas de coup dur et votre capacité à vous développer. Il n'existe pas de « bon statut » dans l'absolu : il existe un statut adapté à VOTRE situation, à réexaminer quand l'activité évolue.

## Le panorama des formes d'exercice

| Forme | Idée directrice | Pour qui ? |
| --- | --- | --- |
| Artisan taxi indépendant | Métier relevant du secteur des métiers (CMA), exploitation de sa propre autorisation | Le taxi qui exploite son ADS |
| Micro-entrepreneur | Simplicité maximale, cotisations en pourcentage du chiffre d'affaires | Démarrage, charges réelles faibles |
| Entreprise individuelle au réel | Déduction des charges réelles, comptabilité complète | Charges importantes, activité installée |
| Société (EURL, SASU) | Structure distincte, développement, embauche | Croissance, plusieurs véhicules |
| Salarié d'un titulaire | Salaire et subordination, recettes à l'employeur | Sécurité, pas de gestion |
| Locataire-gérant | Exploite le taxi d'un titulaire contre redevance | Accès au taxi sans acheter l'ADS |

## La micro-entreprise : la simplicité, avec des limites

Le régime micro séduit par sa simplicité : création rapide, déclarations allégées, cotisations sociales calculées en pourcentage du chiffre d'affaires réellement encaissé (pas de recettes, pas de cotisations). Fiscalement, un **abattement forfaitaire** est appliqué sur le chiffre d'affaires pour déterminer le revenu imposable : vous ne déduisez PAS vos charges réelles. En dessous de certains seuils de chiffre d'affaires, la **franchise en base de TVA** dispense de facturer la TVA (seuils et plafonds : montants à vérifier dans les textes en vigueur, ils sont régulièrement révisés).

> ⚠️ **Attention**
> L'abattement forfaitaire est aveugle : que vos charges réelles soient faibles ou écrasantes (location du véhicule, commissions de plateforme, carburant), le calcul reste le même. Un chauffeur à grosses charges peut se retrouver imposé et cotisant sur un revenu qu'il n'a jamais vu. Le régime micro est aussi borné par des plafonds de chiffre d'affaires (montants à vérifier).

## Le réel et la société : déduire, structurer, se développer

L'**entreprise individuelle au réel** déduit toutes les charges justifiées (véhicule, assurance, commissions, carburant, comptable) : l'imposition porte sur le bénéfice réel. Contrepartie : une comptabilité complète, en pratique un expert-comptable.

La **société** ajoute une personne morale distincte. Deux formes dominent pour un chauffeur seul : l'**EURL**, dont le gérant associé unique relève du régime des **travailleurs non salariés** (TNS : cotisations plus légères, protection plus limitée), et la **SASU**, dont le président est **assimilé salarié** (cotisations plus lourdes, protection sociale plus étendue). La société facilite l'embauche, l'exploitation de plusieurs véhicules et la crédibilité bancaire.

## Travailler pour un titulaire d'ADS : salarié ou locataire-gérant

Côté taxi, tout le monde n'est pas titulaire de son autorisation de stationnement (ADS). Deux voies existent chez un titulaire :

- le **salarié** : contrat de travail, salaire, lien de subordination ; les recettes de l'activité reviennent à l'employeur ;
- le **locataire-gérant** : il loue l'exploitation du taxi, **encaisse les recettes** de son activité, **verse une redevance** au titulaire et exploite **à ses propres risques** : c'est un indépendant, avec les obligations de gestion qui vont avec.

> 💡 **À comprendre**
> La question « qui encaisse quoi ? » résume les deux statuts : salaire fixe et recettes à l'employeur d'un côté ; recettes pour soi moins la redevance, et tout le risque, de l'autre.

## Les critères pour trancher

- **Niveau de charges réelles** : élevées, elles plaident pour le réel ou la société ; faibles, le micro suffit souvent au départ.
- **TVA** : la franchise simplifie ; le régime réel permet de récupérer la TVA sur les frais professionnels.
- **Protection sociale** : TNS ou assimilé salarié, un arbitrage entre coût des cotisations et niveau de couverture (la leçon 4 y revient avec la prévoyance).
- **Ambition** : embaucher, exploiter plusieurs véhicules, céder un jour : la société prépare la suite.

> 🎓 **Réflexe de pro**
> Faites chiffrer deux scénarios par un comptable AVANT de choisir, puis réexaminez le statut chaque année : le bon choix du lancement n'est pas toujours celui de la croissance.

## ✅ Synthèse

- Micro : **simplicité et cotisations sur le CA encaissé**, mais abattement forfaitaire aveugle aux charges réelles et plafonds à surveiller (montants à vérifier).
- Réel et société : **charges déduites, bénéfice réel** ; EURL = dirigeant TNS, SASU = assimilé salarié.
- Chez un titulaire d'ADS : salarié (salaire, recettes à l'employeur) ou locataire-gérant (recettes pour lui, redevance versée, risques assumés).$mft$,
    $mft$Le panorama des formes d'exercice (artisan CMA, micro, réel, EURL/SASU, salarié, locataire-gérant), le mécanisme de l'abattement forfaitaire, la différence TNS/assimilé salarié et les critères de choix.$mft$,
    1, 40) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : Coût de revient et point mort ───────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'cout-de-revient-course',
    'Construire son coût de revient et son point mort',
    $mft$> 🎯 **Objectifs**
> - Recenser les charges fixes et variables d'une activité T3P.
> - Calculer un coût kilométrique et un coût horaire complets.
> - Déterminer son point mort en courses par jour.

## Le calcul qui décide de tout

Un chauffeur qui ignore son coût de revient ne sait pas s'il gagne ou s'il perd de l'argent en acceptant une course. Il « voit » les encaissements, il ne voit pas les charges qui tombent plus tard : l'assurance, les pneus, le comptable, et surtout sa propre rémunération. Le coût de revient transforme cette impression en chiffre : en dessous de tel prix, je travaille à perte.

## Les trois blocs du coût de revient

:::flow
1. Charges fixes | Elles tombent chaque année, que le véhicule roule ou non
2. Charges variables | Elles croissent avec les kilomètres parcourus
3. Rémunération visée | Votre salaire cible, cotisations comprises : une charge comme les autres
:::

| Bloc | Contenu type |
| --- | --- |
| Charges fixes | Amortissement ou loyers du véhicule, assurance RC professionnelle transport onéreux, carte professionnelle et frais de registre, stationnement ou garage, comptable |
| Charges variables | Carburant ou énergie, entretien, pneus, lavage |
| Rémunération | L'enveloppe annuelle que vous vous fixez, charges sociales comprises |

> ❌ **L'erreur classique**
> Oublier sa propre rémunération « parce qu'on se paiera avec ce qui reste ». Ce qui reste, sans calcul, c'est souvent rien : la rémunération visée se traite comme une charge à couvrir, pas comme un espoir.

## L'exemple chiffré : les hypothèses d'abord

Toute simulation vaut ce que valent ses hypothèses : on les pose noir sur blanc, puis on calcule. Hypothèses de travail (à adapter à votre situation) :

| Hypothèse | Valeur retenue |
| --- | --- |
| Véhicule acheté 24 000 €, amorti sur 4 ans | 6 000 € / an |
| Assurance RC professionnelle | 3 000 € / an |
| Carte professionnelle, registre, frais administratifs | 400 € / an |
| Stationnement / garage | 1 200 € / an |
| Comptable | 1 400 € / an |
| Carburant : 7 L/100 km à 2,00 € le litre | 0,14 € / km |
| Entretien et pneus | 0,05 € / km |
| Lavage et divers | 0,01 € / km |
| Kilométrage annuel | 40 000 km |
| Rémunération chargée visée | 30 000 € / an |
| Jours travaillés | 250 / an |
| Heures travaillées | 2 000 / an |
| Panier moyen par course | 25 € |

**Calcul.** Charges fixes : 6 000 + 3 000 + 400 + 1 200 + 1 400 = **12 000 € par an**. Charges variables : 0,14 + 0,05 + 0,01 = 0,20 € par kilomètre, soit 0,20 × 40 000 = **8 000 € par an**. Coût complet : 12 000 + 8 000 + 30 000 = **50 000 € par an**.

## Coût kilométrique, coût horaire

- **Coût kilométrique complet** : 50 000 / 40 000 = **1,25 € par kilomètre**. Toute course facturée en dessous de ce niveau, kilomètres d'approche compris, détruit de la valeur.
- **Coût horaire complet** : 50 000 / 2 000 = **25 € par heure** travaillée. Une heure d'attente non facturée coûte, elle ne rapporte pas.

> 🔍 **Zoom : les kilomètres à vide**
> Le client paie les kilomètres en charge ; vous supportez aussi les kilomètres d'approche et de retour. Si un tiers de vos kilomètres sont à vide, le même coût total se répartit sur les deux tiers restants : le coût réel du kilomètre FACTURÉ grimpe de moitié. Suivez ce ratio de près (via votre application ou un simple relevé).

## Le point mort en courses par jour

Le point mort répond à la question la plus concrète du métier : combien de courses par jour pour être à flot ?

- Coût complet par jour : 50 000 / 250 = **200 € par jour**.
- Point mort : 200 / 25 = **8 courses par jour** (au panier moyen de 25 €).
- Charges seules (sans votre rémunération) : 20 000 / 250 = 80 € par jour, soit 3,2 courses : à ce niveau, l'entreprise survit mais VOUS travaillez gratuitement.

> 📌 **À retenir**
> Le vrai point mort intègre votre rémunération : ici, 8 courses par jour. Les « 3 ou 4 courses qui couvrent les frais » sont un mirage : elles ne paient ni votre loyer ni votre retraite.

## Piloter avec son coût de revient

Ce chiffre unique éclaire toutes les décisions : accepter ou refuser une course lointaine, choisir entre acheter et louer le véhicule, mesurer l'impact réel d'une commission de plateforme, fixer un tarif de mise à disposition. Recalculez-le à chaque changement significatif (véhicule, assurance, volume d'activité) et comparez chaque mois le réalisé aux hypothèses.

## ✅ Synthèse

- Coût de revient = **fixes + variables + rémunération visée** : la rémunération est une charge, pas un reliquat.
- Avec nos hypothèses : 50 000 € par an, soit **1,25 € / km**, **25 € / h**, **200 € / jour**.
- Point mort : **8 courses par jour** à 25 € de panier moyen ; en dessous, la journée est à perte.$mft$,
    $mft$Les trois blocs du coût de revient (fixes, variables, rémunération visée), un exemple chiffré complet à hypothèses explicites (1,25 €/km, 25 €/h, 200 €/jour) et le point mort en courses par jour.$mft$,
    2, 45) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : Facturer, encaisser, déclarer ───────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'facturation-obligations',
    'Facturer, encaisser, déclarer',
    $mft$> 🎯 **Objectifs**
> - Établir une note ou une facture conforme après chaque course.
> - Comprendre la TVA applicable au transport de personnes et la franchise en base.
> - Organiser la traçabilité des recettes et les déclarations selon son statut.

## La note ou la facture : la preuve de votre prestation

Chaque course donne lieu à un justificatif remis au client : c'est à la fois une obligation et une protection (contestation de prix, note de frais du client, contrôle). Le document comporte notamment : l'identification de votre entreprise (nom ou raison sociale, adresse, numéro d'identification), la date, le détail de la prestation (trajet réalisé, suppléments éventuels), le prix, et la TVA le cas échéant (ou la mention indiquant qu'elle n'est pas applicable). Un doublon (papier ou numérique) est conservé dans votre comptabilité.

> 💡 **Bon réflexe**
> Les applications de facturation génèrent note et duplicata en quelques secondes et alimentent directement votre suivi de recettes : autant s'équiper dès le premier jour plutôt que de courir après les justificatifs en fin d'année.

## La TVA du transport de personnes

Le transport de voyageurs relève d'un taux réduit de TVA : 10 % à la date de rédaction de ce cours, taux à vérifier dans les textes en vigueur avant toute facturation. Deux situations en pratique :

- **Franchise en base** (micro-entrepreneurs sous les seuils, montants à vérifier) : vous ne facturez PAS de TVA, la facture porte une mention le précisant, et symétriquement vous ne récupérez pas la TVA sur vos achats (véhicule, carburant, entretien).
- **Assujetti** (réel, société, ou micro ayant dépassé les seuils) : vous facturez la TVA au taux en vigueur, la reversez, et déduisez la TVA sur vos frais professionnels.

> ⚠️ **Attention**
> Le dépassement des seuils de franchise ne prévient pas : suivez votre chiffre d'affaires en cours d'année. Basculer dans la TVA change vos prix, vos factures et vos déclarations : anticipez avec votre comptable.

## Caisse et traçabilité des recettes

Toutes les recettes se déclarent : carte, virement, plateformes ET espèces. Concrètement : chaque course est enregistrée (journal des recettes, application, logiciel), les encaissements sont rapprochés régulièrement des courses réalisées, et les espèces suivent le même chemin que le reste. La tentation de « l'espèce qui disparaît » coûte cher : redressement, majorations, et fragilité totale en cas de contrôle : des recettes incohérentes avec les kilomètres parcourus se repèrent vite.

## Les obligations selon le statut

| Statut | Comptabilité | Déclarations principales |
| --- | --- | --- |
| Micro-entrepreneur | Livre des recettes, factures conservées | Déclaration du CA encaissé (mensuelle ou trimestrielle), cotisations calculées dessus, revenus repris dans la déclaration annuelle |
| EI au réel | Comptabilité complète (comptable recommandé) | Résultat professionnel déclaré, TVA le cas échéant, cotisations TNS régularisées sur le bénéfice réel |
| Société (EURL, SASU) | Comptabilité complète, comptes annuels | Déclarations de la société ; rémunération du dirigeant selon son régime (TNS ou assimilé salarié) |

Le TNS (indépendant, gérant d'EURL) déclare ses revenus professionnels : ses cotisations sociales sont d'abord appelées à titre provisionnel puis régularisées quand le revenu réel est connu : d'où l'importance de PROVISIONNER (mettre de côté chaque mois la part des encaissements destinée aux cotisations et aux impôts).

## Les plateformes : relevés et commissions

Les plateformes (VTC comme applis taxi) fournissent des relevés d'activité : chiffre d'affaires réalisé, commissions prélevées, sommes reversées. Ces relevés sont des pièces comptables à télécharger et à archiver chaque mois. Au réel et en société, les **commissions passent en charges** déductibles ; en micro, rien ne se déduit (l'abattement forfaitaire tient lieu de tout), ce qui pèse lourd quand la commission représente une part importante des courses : un élément de plus dans le choix du statut.

> 🔍 **Zoom : le rapprochement mensuel**
> Chaque mois : relevé de plateforme, relevé bancaire et journal des recettes doivent raconter la même histoire. Un écart non expliqué aujourd'hui est un problème de contrôle demain.

## ✅ Synthèse

- Chaque course : **note ou facture** avec identification, date, prestation, prix : et duplicata conservé.
- TVA : taux réduit du transport de voyageurs (10 %, à vérifier dans les textes en vigueur) ; **franchise en base** = pas de TVA facturée, pas de TVA récupérée ; seuils à surveiller.
- **Toutes** les recettes se tracent, espèces comprises ; relevés de plateformes archivés ; commissions déductibles au réel, pas en micro ; provisionner cotisations et impôts.$mft$,
    $mft$La note ou facture et ses mentions, la TVA du transport de voyageurs (taux réduit à vérifier, franchise en base), la traçabilité de toutes les recettes et l'exploitation des relevés de plateformes.$mft$,
    3, 40) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : Assurances et risques du métier ─────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'assurances-risques',
    'S''assurer et maîtriser les risques du métier',
    $mft$> 🎯 **Objectifs**
> - Assurer correctement le véhicule pour l'usage transport onéreux de personnes.
> - Compléter la couverture : RC exploitation, protection juridique, prévoyance du TNS.
> - Gérer un sinistre avec un client à bord et prévenir les risques du métier.

## L'assurance circulation : le point non négociable

Transporter des personnes contre rémunération est un **usage professionnel spécifique** qui doit être déclaré à l'assureur. Une assurance auto personnelle, même « tous risques », ne couvre PAS cet usage : en cas de sinistre, l'assureur peut invoquer la **nullité de la garantie** : pas d'indemnisation du véhicule, et surtout un risque financier majeur si des tiers ou votre client sont blessés. Rouler professionnellement avec une police « usage privé » revient à rouler sans assurance : c'est LA faute de gestion qui peut détruire une activité (et un patrimoine) en un instant.

> ❌ **Piège mortel pour l'activité**
> « Je viens de commencer, je passerai au contrat pro plus tard. » Un seul accrochage avec un client à bord suffit : garantie nulle, dommages corporels en jeu, et des sommes sans commune mesure avec l'économie de prime réalisée.

## Les garanties qui protègent l'activité

| Garantie | Ce qu'elle couvre |
| --- | --- |
| RC circulation usage professionnel T3P | Dommages causés aux tiers (dont vos clients transportés) par le véhicule |
| RC exploitation | Dommages causés dans le cadre de l'activité hors fait de circulation : client qui chute en montant, bagage abîmé |
| Protection juridique | Frais de défense et conseils en cas de litige (client, plateforme, administration) |
| Garanties du véhicule | Vol, bris de glace, dommages : le véhicule est votre outil de travail |
| Véhicule de remplacement / perte d'exploitation | Limiter les jours sans rouler, donc sans recette |

Le véhicule immobilisé ne produit plus rien alors que les charges fixes continuent : les garanties d'immobilisation (véhicule relais, indemnités) se raisonnent en jours de chiffre d'affaires sauvés, pas en euros de prime.

## Protéger la personne : prévoyance et santé du TNS

Le chauffeur indépendant est le moteur de son entreprise : s'il s'arrête, tout s'arrête. Or la protection par défaut du TNS ne garantit pas un maintien de revenu confortable en cas de maladie ou d'accident. Trois briques s'imposent :

- une **prévoyance** avec indemnités journalières calibrées sur vos charges fixes ET votre rémunération ;
- une **complémentaire santé** adaptée ;
- une réflexion **retraite** (compléter tôt coûte moins cher).

> 🎓 **Réflexe de pro**
> Calibrez la prévoyance avec votre coût de revient (leçon 2) : combien coûte UN mois d'arrêt, charges fixes comprises ? C'est le montant que vos indemnités journalières doivent approcher.

## Sinistre avec un client à bord : la procédure

:::flow
1. Sécuriser | Feux de détresse, mise en sécurité des personnes, gilet si l'on descend sur la chaussée
2. Le client d'abord | État de santé, secours au moindre doute, rassurer, organiser la suite de son trajet
3. Constater | Constat amiable : des FAITS précis, un croquis, aucune reconnaissance de responsabilité hâtive
4. Documenter | Photos des véhicules et des lieux, coordonnées de l'autre conducteur, client noté comme passager témoin
5. Déclarer | Assureur dans le délai prévu au contrat, constat et photos joints
6. Informer | Plateforme ou central radio selon le cas, suivi des frais (remorquage, immobilisation)
:::

> 📌 **À retenir**
> Le constat consigne des faits, pas des conclusions : la répartition des responsabilités appartient aux assureurs. Et le client à bord est un témoin précieux : ses coordonnées se prennent AVANT qu'il reparte.

## Les risques du métier : agression, dégradations

Le T3P expose à des risques spécifiques : passager agressif, dégradations du véhicule, vols. La prévention d'abord : attitude professionnelle qui désamorce (calme, courtoisie, pas de surenchère verbale), vigilance sur les courses et les zones sensibles la nuit, véhicule verrouillé hors service, limitation des espèces à bord grâce au paiement dématérialisé. En cas d'agression : priorité à votre intégrité (pas de résistance héroïque pour une recette), mise en sécurité, alerte des secours et dépôt de plainte, information de la plateforme ou du central, déclaration à l'assureur pour les dommages.

> ⚠️ **Caméras embarquées : prudence**
> La caméra peut dissuader et documenter, mais son usage est encadré (information des personnes filmées, conservation et accès aux images) : cadre juridique à vérifier auprès des sources officielles avant toute installation.

## ✅ Synthèse

- RC circulation avec **usage T3P déclaré** : sans elle, nullité de garantie : c'est le socle absolu.
- Compléter : RC exploitation, protection juridique, garanties véhicule et immobilisation ; côté personne : **prévoyance à indemnités journalières**, santé, retraite.
- Sinistre avec client : sécuriser, client d'abord, constat factuel, photos, déclaration dans les délais ; agression : intégrité d'abord, plainte, déclaration ; caméras : cadre à vérifier.$mft$,
    $mft$L'assurance de l'usage T3P (nullité de garantie sinon), les garanties complémentaires (RC exploitation, protection juridique, véhicule), la prévoyance du TNS, la procédure de sinistre avec client à bord et la prévention des risques métier.$mft$,
    4, 40) RETURNING id INTO v_l4;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : gérer son activité T3P',
    'Vérifiez le module 3 : statuts d''exercice, coût de revient, facturation, TVA et assurances du chauffeur T3P.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Karim se lance seul en VTC avec une voiture d'occasion déjà payée et peu de frais. Il veut la gestion la plus simple possible pour tester l'activité. Quelle forme d'exercice correspond le mieux à sa situation ?$mft$,
    $mft$[
      {"id":"a","label":"Micro-entrepreneur : déclarations simplifiées, cotisations calculées sur le chiffre d'affaires encaissé","is_correct":true},
      {"id":"b","label":"SASU : il sera assimilé salarié, avec une gestion de société et des comptes annuels à produire","is_correct":false},
      {"id":"c","label":"Entreprise individuelle au réel, avec comptabilité complète dès le premier jour","is_correct":false},
      {"id":"d","label":"Locataire-gérant : il doit d'abord trouver un titulaire d'ADS qui lui loue son taxi","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-3','qcm-v1'], 'TAXI-M3-QCM-01', false,
    $mft$La micro-entreprise est adaptée au démarrage à charges légères : formalités réduites, cotisations proportionnelles aux encaissements. Le réel et la société se justifient quand les charges montent ; la location-gérance concerne l'exploitation du taxi d'un titulaire d'ADS.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Dans le budget annuel d'une chauffeuse VTC, laquelle de ces dépenses est une charge VARIABLE, c'est-à-dire proportionnelle aux kilomètres parcourus ?$mft$,
    $mft$[
      {"id":"a","label":"Le carburant","is_correct":true},
      {"id":"b","label":"La prime annuelle d'assurance RC professionnelle","is_correct":false},
      {"id":"c","label":"Les honoraires du comptable","is_correct":false},
      {"id":"d","label":"L'abonnement annuel du garage où stationne le véhicule","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-3','qcm-v1'], 'TAXI-M3-QCM-02', false,
    $mft$Le carburant croît avec les kilomètres, comme l'entretien, les pneus et le lavage. Assurance, comptable et stationnement tombent chaque année, que le véhicule roule ou non : ce sont des charges fixes.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Nadia commence le VTC avec sa voiture personnelle, assurée « tous risques » en usage privé. Un client est à bord lors d'un accrochage responsable. Que peut faire son assureur ?$mft$,
    $mft$[
      {"id":"a","label":"Invoquer la nullité de la garantie : l'usage transport onéreux de personnes n'était pas déclaré, les dommages peuvent rester à sa charge","is_correct":true},
      {"id":"b","label":"Indemniser normalement : une formule « tous risques » couvre tous les usages","is_correct":false},
      {"id":"c","label":"Appliquer une simple franchise doublée, comme pour un jeune conducteur","is_correct":false},
      {"id":"d","label":"Transférer le dossier à l'assurance personnelle du client transporté","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-3','qcm-v1'], 'TAXI-M3-QCM-03', false,
    $mft$Le transport onéreux de personnes exige une assurance adaptée à cet usage professionnel. Une police « usage privé », même tous risques, ne le couvre pas : l'assureur peut opposer la nullité de garantie, aux conséquences financières majeures.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$En fin de course, votre client professionnel vous demande un justificatif pour sa note de frais. Que lui remettez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Une note ou facture comportant notamment l'identification de votre entreprise, la date, le détail de la prestation et le prix","is_correct":true},
      {"id":"b","label":"Rien : le ticket de carte bancaire suffit toujours","is_correct":false},
      {"id":"c","label":"Un simple SMS récapitulant le montant de la course","is_correct":false},
      {"id":"d","label":"Un justificatif uniquement s'il a réglé en espèces","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['taxi-vtc','module-3','qcm-v1'], 'TAXI-M3-QCM-04', false,
    $mft$La note ou facture est le document de preuve de la prestation, avec ses mentions d'identification, de date, de prestation et de prix. Le ticket de carte bancaire prouve un paiement, pas le contenu de la prestation.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Sofiane hésite entre créer une EURL dont il serait gérant associé unique et une SASU dont il serait président. Quelle est la différence principale de régime social entre ces deux options ?$mft$,
    $mft$[
      {"id":"a","label":"EURL : travailleur non salarié (cotisations plus légères, protection plus limitée) ; SASU : assimilé salarié (cotisations plus lourdes, protection plus étendue)","is_correct":true},
      {"id":"b","label":"Aucune : le régime social du dirigeant est identique dans les deux cas","is_correct":false},
      {"id":"c","label":"SASU : travailleur non salarié obligatoirement ; EURL : assimilé salarié","is_correct":false},
      {"id":"d","label":"Dans les deux cas, il relèverait automatiquement du régime des salariés du transport","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-3','qcm-v1'], 'TAXI-M3-QCM-05', false,
    $mft$Le gérant associé unique d'EURL relève du régime des travailleurs non salariés ; le président de SASU est assimilé salarié. Le choix se joue entre coût des cotisations et niveau de protection sociale, pas sur un régime unique.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Vos charges fixes atteignent 12 000 € par an, vos charges variables 0,20 € par kilomètre, pour 40 000 km parcourus dans l'année. Quel est votre coût de revient kilométrique, hors rémunération ?$mft$,
    $mft$[
      {"id":"a","label":"0,50 € par kilomètre","is_correct":true},
      {"id":"b","label":"0,30 € par kilomètre","is_correct":false},
      {"id":"c","label":"0,20 € par kilomètre","is_correct":false},
      {"id":"d","label":"1,25 € par kilomètre","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-3','qcm-v1'], 'TAXI-M3-QCM-06', false,
    $mft$(12 000 + 0,20 × 40 000) / 40 000 = 20 000 / 40 000 = 0,50 €/km. 0,30 € ne compte que les fixes, 0,20 € que les variables ; 1,25 € correspondrait à un coût complet incluant une rémunération.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Léa est micro-entrepreneuse VTC sous le régime de la franchise en base de TVA. Comment établit-elle ses factures ?$mft$,
    $mft$[
      {"id":"a","label":"Sans TVA, avec une mention précisant que la TVA n'est pas applicable, tant que son chiffre d'affaires reste sous les seuils de la franchise","is_correct":true},
      {"id":"b","label":"Avec la TVA au taux réduit du transport de voyageurs, qu'elle reverse chaque mois","is_correct":false},
      {"id":"c","label":"Avec une TVA au taux normal sur la seule partie « mise à disposition du véhicule »","is_correct":false},
      {"id":"d","label":"Sans TVA facturée, mais en récupérant quand même la TVA payée sur son carburant","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-3','qcm-v1'], 'TAXI-M3-QCM-07', false,
    $mft$La franchise en base dispense de facturer la TVA (avec mention sur la facture) mais interdit symétriquement de la récupérer sur les achats. Les seuils de chiffre d'affaires de la franchise sont à vérifier dans les textes en vigueur.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Votre cliente glisse en montant dans le véhicule à l'arrêt et se blesse au poignet. Elle vous met en cause. Quelle garantie a vocation à jouer ?$mft$,
    $mft$[
      {"id":"a","label":"La responsabilité civile exploitation, qui couvre les dommages causés aux tiers dans le cadre de l'activité, hors fait de circulation","is_correct":true},
      {"id":"b","label":"La garantie bris de glace du véhicule","is_correct":false},
      {"id":"c","label":"La protection juridique, qui indemnisera directement la cliente","is_correct":false},
      {"id":"d","label":"Aucune : une chute à l'arrêt ne peut jamais engager le chauffeur","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-3','qcm-v1'], 'TAXI-M3-QCM-08', false,
    $mft$Hors fait de circulation, c'est la RC exploitation qui prend le relais de l'assurance automobile. La protection juridique finance la défense et le conseil, elle n'indemnise pas la victime.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Vos charges annuelles (hors rémunération) atteignent 20 000 €. Vous travaillez 250 jours par an, avec un panier moyen de 20 € par course. Combien de courses par jour faut-il pour couvrir SEULEMENT ces charges ?$mft$,
    $mft$[
      {"id":"a","label":"4 courses par jour","is_correct":true},
      {"id":"b","label":"2 courses par jour","is_correct":false},
      {"id":"c","label":"8 courses par jour","is_correct":false},
      {"id":"d","label":"10 courses par jour","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['taxi-vtc','module-3','qcm-v1'], 'TAXI-M3-QCM-09', false,
    $mft$20 000 / 250 = 80 € de charges par jour ; 80 / 20 = 4 courses. Attention : à 4 courses par jour, le chauffeur travaille encore gratuitement, sa rémunération n'est pas couverte : le vrai point mort est plus haut.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Djamel signe un contrat de locataire-gérant avec un artisan taxi titulaire d'une ADS. Comment fonctionne leur relation financière ?$mft$,
    $mft$[
      {"id":"a","label":"Djamel exploite le taxi à ses risques, encaisse les recettes de son activité et verse une redevance au titulaire","is_correct":true},
      {"id":"b","label":"Le titulaire encaisse toutes les recettes et verse à Djamel un salaire fixe","is_correct":false},
      {"id":"c","label":"Les recettes sont obligatoirement partagées à parts égales entre eux","is_correct":false},
      {"id":"d","label":"Djamel ne verse rien tant qu'il n'a pas racheté l'ADS","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-3','qcm-v1'], 'TAXI-M3-QCM-10', false,
    $mft$Le locataire-gérant est un exploitant indépendant : recettes pour lui, redevance pour le titulaire de l'autorisation, risques assumés. Le schéma « salaire fixe, recettes à l'employeur » correspond au statut de salarié.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Yanis, micro-entrepreneur, réalise tout son chiffre d'affaires via une plateforme qui prélève 25 % de commission. Quel est l'impact fiscal de cette commission pour lui ?$mft$,
    $mft$[
      {"id":"a","label":"Il ne peut pas la déduire : en micro, l'abattement forfaitaire tient lieu de toutes les charges ; si commissions et frais réels dépassent cet abattement, un régime réel devient plus pertinent","is_correct":true},
      {"id":"b","label":"Il la déduit de son chiffre d'affaires, en plus de l'abattement forfaitaire","is_correct":false},
      {"id":"c","label":"La plateforme paie les cotisations sociales à sa place, la commission n'a donc aucun impact","is_correct":false},
      {"id":"d","label":"La commission constitue une TVA déductible qu'il récupère chaque trimestre","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-3','qcm-v1'], 'TAXI-M3-QCM-11', false,
    $mft$Le régime micro ne déduit aucune charge réelle : l'abattement forfaitaire couvre tout. Des commissions lourdes plaident donc pour comparer avec un régime réel où elles passeraient en charges déductibles.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Accrochage sans blessé, client à bord. L'autre conducteur, pressé, propose « un arrangement entre nous, sans papiers ». Quelle conduite tenez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Constat amiable rempli sur place avec les faits, coordonnées échangées, client noté comme témoin, déclaration à votre assureur dans le délai prévu au contrat","is_correct":true},
      {"id":"b","label":"Accepter l'arrangement : sans papiers, pas de malus","is_correct":false},
      {"id":"c","label":"Faire signer à l'autre conducteur une reconnaissance de responsabilité rédigée par vous","is_correct":false},
      {"id":"d","label":"Ne rien déclarer si les dégâts semblent inférieurs à la franchise","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['taxi-vtc','module-3','qcm-v1'], 'TAXI-M3-QCM-12', false,
    $mft$Sans constat, impossible de prouver quoi que ce soit si l'autre conducteur change de version ou si le client se plaint plus tard de douleurs. On consigne les faits, on déclare dans les délais du contrat et on informe sa plateforme ou son central.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l2, 'qr',
   $mft$Citez trois charges fixes annuelles typiques d'un chauffeur T3P indépendant.$mft$,
   $mft$Par exemple : l'amortissement ou les loyers du véhicule, l'assurance RC professionnelle transport onéreux, les honoraires du comptable, le stationnement ou le garage, les frais de carte professionnelle et de registre.$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-3','question-courte'], 'TAXI-M3-QC-01', false,
   $mft$Trois postes indépendants du kilométrage attendus.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Pourquoi une assurance auto « usage privé », même tous risques, ne permet-elle pas d'exercer en taxi ou en VTC ?$mft$,
   $mft$Parce que l'usage transport onéreux de personnes n'est ni déclaré ni couvert : en cas de sinistre, l'assureur peut invoquer la nullité de la garantie et refuser toute indemnisation.$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-3','question-courte'], 'TAXI-M3-QC-02', false,
   $mft$Usage professionnel non déclaré = nullité de garantie.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Quel est le régime social du président de SASU, par opposition à celui du gérant associé unique d'EURL ?$mft$,
   $mft$Le président de SASU est assimilé salarié ; le gérant associé unique d'EURL relève du régime des travailleurs non salariés (TNS).$mft$,
   2, 'facile', ARRAY['taxi-vtc','module-3','question-courte'], 'TAXI-M3-QC-03', false,
   $mft$Assimilé salarié contre TNS.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Donnez la formule du coût de revient kilométrique complet d'une activité T3P.$mft$,
   $mft$(Charges fixes annuelles + charges variables annuelles + rémunération chargée visée) divisées par le kilométrage annuel.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-3','question-courte'], 'TAXI-M3-QC-04', false,
   $mft$Les trois blocs au numérateur, les kilomètres au dénominateur.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Un client paie sa course en espèces et repart sans rien demander. Que devez-vous faire côté recettes ?$mft$,
   $mft$Enregistrer la course dans le suivi des recettes (journal des recettes, application) comme toute autre course : chaque encaissement, espèces comprises, doit être tracé et déclaré.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-3','question-courte'], 'TAXI-M3-QC-05', false,
   $mft$La traçabilité vaut pour toutes les recettes, surtout les espèces.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Citez deux différences entre le salarié d'un titulaire d'ADS et le locataire-gérant.$mft$,
   $mft$Le salarié perçoit un salaire et les recettes reviennent à l'employeur, avec un lien de subordination ; le locataire-gérant encaisse les recettes, verse une redevance au titulaire et exploite à ses propres risques.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-3','question-courte'], 'TAXI-M3-QC-06', false,
   $mft$Qui encaisse, qui supporte le risque.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Au-delà de la RC circulation professionnelle, citez deux garanties ou contrats utiles pour protéger votre activité et vos revenus.$mft$,
   $mft$Par exemple : la RC exploitation, la protection juridique, un contrat de prévoyance avec indemnités journalières, la complémentaire santé, les garanties du véhicule (vol, bris de glace) ou une garantie véhicule de remplacement.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-3','question-courte'], 'TAXI-M3-QC-07', false,
   $mft$Deux protections distinctes et cohérentes attendues.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Pourquoi un chauffeur imposé au réel doit-il conserver les relevés mensuels de sa plateforme ?$mft$,
   $mft$Parce qu'ils justifient le chiffre d'affaires réalisé et les commissions prélevées, que le chauffeur déduit en charges : ce sont des pièces de base de sa comptabilité et de ses déclarations.$mft$,
   2, 'moyen', ARRAY['taxi-vtc','module-3','question-courte'], 'TAXI-M3-QC-08', false,
   $mft$Preuve du chiffre d'affaires et des commissions déductibles.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Votre coût complet annuel (charges + rémunération visée) est de 50 000 € pour 40 000 km parcourus. Calculez votre coût kilométrique complet et concluez sur une course payée 1 € du kilomètre.$mft$,
   $mft$50 000 / 40 000 = 1,25 € par kilomètre. Une course payée 1 € du kilomètre est vendue en dessous du coût de revient : elle se fait à perte.$mft$,
   2, 'difficile', ARRAY['taxi-vtc','module-3','question-courte'], 'TAXI-M3-QC-09', false,
   $mft$1,25 €/km ; toute recette kilométrique inférieure détruit de la valeur.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Pourquoi la prévoyance est-elle présentée comme indispensable pour un chauffeur TNS ?$mft$,
   $mft$Parce que la protection de base du TNS ne garantit pas un maintien de revenu confortable en cas d'arrêt de travail : sans contrat de prévoyance avec indemnités journalières, un accident ou une maladie fait chuter les revenus alors que les charges fixes continuent de courir.$mft$,
   2, 'difficile', ARRAY['taxi-vtc','module-3','question-courte'], 'TAXI-M3-QC-10', false,
   $mft$Arrêt de travail = revenus coupés, charges maintenues.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Un ami se lance en VTC et vous dit : « je prends micro-entrepreneur, c'est ce que tout le monde fait ». Expliquez-lui les avantages réels de ce régime, puis les situations où il devient un mauvais calcul.$mft$,
   $mft$Réponse modèle. Les avantages sont réels au démarrage : création rapide, gestion administrative allégée (livre des recettes, déclarations simplifiées), cotisations sociales calculées en pourcentage du chiffre d'affaires réellement encaissé (un mois creux coûte peu), et franchise en base de TVA sous certains seuils (montants à vérifier) : pas de TVA à facturer ni à déclarer. Mais le régime repose sur un abattement forfaitaire : les charges réelles ne se déduisent jamais. Si ton activité supporte des charges lourdes (location du véhicule, commissions de plateforme, carburant, assurance professionnelle), leur total peut dépasser l'abattement : tu cotises et tu es imposé sur un revenu que tu n'as pas réellement gagné. Autres limites : impossible de récupérer la TVA sur le véhicule et les frais (la franchise joue dans les deux sens), des plafonds de chiffre d'affaires qui bornent le développement (montants à vérifier dans les textes en vigueur), et un cadre peu adapté si tu veux embaucher ou exploiter plusieurs véhicules. Conclusion : excellent régime de test à charges légères, mais il faut comparer chaque année charges réelles et abattement, et basculer au réel ou en société quand les chiffres l'exigent.$mft$,
   $mft$Barème /5 : au moins trois avantages exacts du régime micro (1,5 pt) ; mécanisme abattement forfaitaire contre charges réelles expliqué (1,5 pt) ; au moins deux autres limites citées (TVA non récupérable, plafonds à vérifier, développement) (1,5 pt) ; conclusion nuancée avec réexamen périodique (0,5 pt). Erreurs fréquentes : citer des taux ou des plafonds chiffrés inventés ; croire que les charges réelles se déduisent en plus de l'abattement.$mft$,
   5, 'facile', ARRAY['taxi-vtc','module-3','question-redigee'], 'TAXI-M3-QR-01', false,
   $mft$Les forces et les angles morts du régime micro, argumentés.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Vous êtes percuté à un carrefour, votre cliente est à bord, choquée mais apparemment indemne. Déroulez la procédure complète, de la sécurisation du véhicule à la déclaration du sinistre.$mft$,
   $mft$Réponse modèle. D'abord sécuriser : feux de détresse, véhicule immobilisé sans créer de sur-risque, gilet si l'on descend sur la chaussée. Ensuite la cliente, priorité absolue : vérifier son état, appeler les secours au moindre doute (un choc peut se révéler après coup : lui conseiller un avis médical), la rassurer et organiser la suite de son trajet (autre véhicule, proche prévenu). Puis constater : remplir le constat amiable avec des faits précis (position des véhicules, croquis, circonstances), sans reconnaissance de responsabilité hâtive ; relever l'identité, l'assurance et l'immatriculation de l'autre conducteur ; noter la cliente comme passagère témoin, avec ses coordonnées, AVANT qu'elle reparte. Documenter : photos des véhicules, des dégâts et des lieux sous plusieurs angles. Déclarer ensuite le sinistre à l'assureur dans le délai prévu au contrat, constat et photos joints, et informer la plateforme ou le central de la course interrompue. Enfin, assurer le suivi : conserver tous les justificatifs (remorquage, immobilisation, frais annexes) et activer si besoin la garantie véhicule de remplacement pour limiter les jours sans recette.$mft$,
   $mft$Barème /5 : sécurisation correcte puis prise en charge de la cliente en premier (1,5 pt) ; constat factuel complet, cliente mentionnée comme passagère témoin, photos (1,5 pt) ; déclaration à l'assureur dans le délai du contrat et information de la plateforme ou du central (1,5 pt) ; suivi (justificatifs, véhicule de remplacement) (0,5 pt). Erreurs fréquentes : reconnaître sa responsabilité sur place ; laisser repartir la cliente sans prendre ses coordonnées.$mft$,
   5, 'facile', ARRAY['taxi-vtc','module-3','question-redigee'], 'TAXI-M3-QR-02', false,
   $mft$La procédure sinistre avec client à bord, de bout en bout.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Inès démarre en VTC avec ces hypothèses : location longue durée du véhicule 450 € par mois, assurance professionnelle 2 400 € par an, comptable et frais divers 1 200 € par an, charges variables 0,20 € par kilomètre, 45 000 km par an, rémunération chargée visée 27 000 € par an, 250 jours travaillés, panier moyen 24 € par course. Calculez son coût de revient annuel complet, son coût kilométrique et son point mort en courses par jour.$mft$,
   $mft$Réponse modèle. Premier bloc, les charges fixes : location 450 × 12 = 5 400 € ; plus l'assurance 2 400 € et le comptable et frais divers 1 200 €, soit 5 400 + 2 400 + 1 200 = 9 000 € par an. Deuxième bloc, les charges variables : 0,20 × 45 000 = 9 000 € par an. Troisième bloc, la rémunération chargée visée : 27 000 € par an. Coût de revient annuel complet : 9 000 + 9 000 + 27 000 = 45 000 €. Coût kilométrique complet : 45 000 / 45 000 = 1,00 € par kilomètre : toute course facturée en dessous de ce niveau, approche comprise, se fait à perte. Point mort quotidien : 45 000 / 250 = 180 € de recettes nécessaires par jour ; au panier moyen de 24 €, cela représente 180 / 24 = 7,5 courses, donc 8 courses entières par jour pour couvrir le coût complet, rémunération incluse. En dessous, Inès entame sa propre paie. Limite du modèle à signaler : panier moyen et jours réellement travaillés varient ; si elle travaille moins de 250 jours, l'objectif quotidien monte mécaniquement.$mft$,
   $mft$Barème /5 : charges fixes exactes (9 000 €) (1 pt) ; charges variables exactes (9 000 €) et total 45 000 € (1 pt) ; coût kilométrique 1,00 €/km avec interprétation (1 pt) ; point mort 180 €/jour soit 7,5 courses arrondies à 8 (1,5 pt) ; limite du modèle signalée (panier ou jours variables) (0,5 pt). Erreurs fréquentes : oublier la rémunération dans le total ; arrondir 7,5 à 7 courses, ce qui laisse la journée en dessous du point mort.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-3','question-redigee'], 'TAXI-M3-QR-03', false,
   $mft$Le coût de revient complet d'Inès, hypothèses posées puis calculées.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Mehdi veut exercer en VTC haut de gamme : berline récente en location longue durée coûteuse, grosses commissions de plateforme, carburant et lavages fréquents. Comparez pour lui la micro-entreprise et un régime réel (entreprise individuelle au réel ou société), puis concluez.$mft$,
   $mft$Réponse modèle. En micro, la gestion est simple mais l'abattement forfaitaire s'applique quel que soit le niveau des charges : Mehdi supporterait une location longue durée coûteuse, des commissions élevées, du carburant et des lavages fréquents que l'abattement ne reflète pas ; il cotiserait et serait imposé sur une base déconnectée de son bénéfice réel. La franchise en base l'empêcherait en outre de récupérer la TVA sur la location et ses frais, et les plafonds de chiffre d'affaires du micro (montants à vérifier) se heurtent vite à des courses haut de gamme. Au réel ou en société, toutes les charges justifiées se déduisent (location, commissions, carburant, lavage, assurance, comptable) : l'imposition porte sur le bénéfice réel ; assujetti à la TVA, il facturerait au taux du transport de voyageurs en vigueur (à vérifier) et récupérerait la TVA sur ses frais professionnels. Contrepartie : comptabilité complète et honoraires de comptable, eux-mêmes déductibles. En société, il choisirait aussi son régime social : gérant d'EURL en TNS ou président de SASU assimilé salarié. Conclusion : avec un profil à charges élevées, le régime réel est presque toujours plus pertinent ; la décision se prend en faisant chiffrer les deux scénarios par un comptable.$mft$,
   $mft$Barème /5 : mécanisme du micro démontré sur ce profil (abattement contre charges élevées) (1,5 pt) ; avantages du réel exposés (déduction intégrale, bénéfice réel) (1,5 pt) ; dimension TVA traitée avec prudence (récupération au réel, franchise en micro, taux à vérifier) (1 pt) ; conclusion argumentée avec recommandation de chiffrage comparatif (1 pt). Erreurs fréquentes : trancher sans évoquer la TVA ; citer des seuils ou des taux chiffrés non vérifiés.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-3','question-redigee'], 'TAXI-M3-QR-04', false,
   $mft$Micro contre réel sur un profil à charges lourdes.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Construisez l'organisation administrative mensuelle d'une chauffeuse indépendante : pièces à produire et à conserver, suivi des recettes, relevés de plateformes, échéances déclaratives. Présentez un déroulé type du mois.$mft$,
   $mft$Réponse modèle. Au fil de l'eau, chaque jour : une note ou facture par course avec les mentions requises (identification de l'entreprise, date, prestation, prix, TVA ou mention de franchise), duplicata conservé ; enregistrement quotidien des recettes dans le journal ou l'application, espèces comprises ; classement immédiat des justificatifs de charges (carburant, lavage, entretien, péages). Chaque semaine : rapprochement rapide entre courses réalisées et encaissements constatés, pour repérer tout écart à chaud. En fin de mois : télécharger les relevés de plateformes (chiffre d'affaires, commissions prélevées, sommes reversées) et les rapprocher du relevé bancaire et du journal des recettes : les trois doivent raconter la même histoire. Selon le statut : en micro, déclarer le chiffre d'affaires encaissé à l'échéance choisie (mensuelle ou trimestrielle) et payer les cotisations correspondantes ; au réel ou en société, transmettre les pièces au comptable, les commissions passant en charges déductibles, et traiter la TVA le cas échéant. Enfin, provisionner systématiquement sur un compte à part la part des encaissements destinée aux cotisations et aux impôts, puis archiver l'ensemble du mois (notes, relevés, déclarations).$mft$,
   $mft$Barème /5 : documents de vente conformes produits au fil de l'eau (1 pt) ; traçabilité quotidienne des recettes, espèces comprises (1 pt) ; exploitation mensuelle des relevés de plateformes avec triple rapprochement banque/journal/relevé (1,5 pt) ; échéances déclaratives selon le statut et provision des sommes dues (1,5 pt). Erreurs fréquentes : ne tracer que les paiements par carte ; découvrir le montant des cotisations au moment de les payer, sans provision.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-3','question-redigee'], 'TAXI-M3-QR-05', false,
   $mft$Le mois administratif type, du justificatif à la déclaration.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Yasmine doit encaisser 45 000 € par an, nets de commission, pour couvrir son coût complet (rémunération incluse). Sa plateforme prélève 25 % de commission. Elle travaille 250 jours par an, avec un panier moyen de 24 € par course. Calculez le chiffre d'affaires brut nécessaire, l'objectif quotidien en euros et en courses, puis analysez le poids réel de la commission.$mft$,
   $mft$Réponse modèle. La plateforme prélève 25 % : Yasmine ne conserve que 75 % de chaque course. Pour garder 45 000 €, il faut donc un chiffre d'affaires brut de 45 000 / 0,75 = 60 000 € par an (et non 45 000 × 1,25 = 56 250 €, erreur classique : la commission se calcule sur le brut). La commission annuelle atteint 60 000 − 45 000 = 15 000 €. Objectif quotidien : 60 000 / 250 = 240 € de courses brutes par jour ; au panier moyen de 24 €, cela fait 240 / 24 = 10 courses par jour. Sans commission, l'objectif serait de 45 000 / 250 = 180 € par jour, soit 7,5 courses : la commission représente donc 2,5 courses supplémentaires chaque jour, un quart du volume brut travaillé pour la plateforme. Analyse : la commission est une charge majeure, à intégrer explicitement au coût de revient. Leviers possibles : développer une clientèle directe ou d'autres canaux moins commissionnés, travailler le panier moyen, et examiner le statut fiscal : au réel, la commission se déduit en charges ; en micro, l'abattement forfaitaire ne la reflète pas, ce qui aggrave son poids réel.$mft$,
   $mft$Barème /5 : chiffre d'affaires brut exact (60 000 €, division par 0,75 et non majoration de 25 %) (1,5 pt) ; objectif quotidien exact (240 €, 10 courses) (1 pt) ; comparaison avec et sans commission (2,5 courses d'écart par jour) (1 pt) ; analyse et leviers (clientèle directe, panier moyen, traitement fiscal selon le statut) (1,5 pt). Erreurs fréquentes : calculer 45 000 × 1,25 au lieu de diviser par 0,75 ; oublier que la commission se paie aussi sur la part destinée à la rémunération.$mft$,
   5, 'moyen', ARRAY['taxi-vtc','module-3','question-redigee'], 'TAXI-M3-QR-06', false,
   $mft$Le vrai coût d'une commission de plateforme, chiffré puis analysé.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Vous accompagnez un nouveau chauffeur TNS dans la construction de son plan de protection complet : assurances de l'activité, protection de la personne, prévention des risques métier. Structurez ce plan et justifiez chaque poste.$mft$,
   $mft$Réponse modèle. Premier pilier, l'activité : la RC circulation avec usage transport onéreux de personnes déclaré est le socle absolu : sans elle, nullité de garantie, autant dire interdiction de fait de travailler. S'y ajoutent les garanties du véhicule (vol, bris de glace, dommages), car il est l'outil de travail, complétées par une garantie véhicule de remplacement ou perte d'exploitation : chaque jour d'immobilisation est un jour sans recette alors que les charges fixes courent. La RC exploitation couvre les dommages hors fait de circulation (client qui chute en montant, bagage abîmé) et la protection juridique finance défense et conseil en cas de litige avec un client, une plateforme ou l'administration. Deuxième pilier, la personne : la couverture par défaut du TNS ne garantit pas un maintien de revenu confortable ; il faut une prévoyance avec indemnités journalières calibrées sur les charges fixes et la rémunération (chiffrer le coût d'un mois d'arrêt), une complémentaire santé, et une réflexion retraite engagée tôt. Troisième pilier, la prévention : attitude professionnelle qui désamorce les tensions, vigilance la nuit et dans les zones sensibles, paiement dématérialisé pour limiter les espèces à bord, véhicule verrouillé ; pour les caméras embarquées, intérêt dissuasif réel mais cadre juridique précis (information des personnes filmées, gestion des images) à vérifier avant toute installation. L'ensemble du budget s'intègre au coût de revient.$mft$,
   $mft$Barème /5 : socle assurances de l'activité complet (RC circulation usage professionnel, RC exploitation, garanties véhicule et immobilisation, protection juridique) (2 pts) ; protection de la personne (prévoyance à indemnités journalières, santé) justifiée par la faiblesse de la couverture TNS par défaut (1,5 pt) ; prévention des risques métier avec au moins deux mesures concrètes et la prudence sur le cadre des caméras (1 pt) ; intégration du budget de protection au coût de revient (0,5 pt). Erreurs fréquentes : réduire la protection à l'assurance du véhicule ; recommander les caméras sans réserve juridique.$mft$,
   5, 'difficile', ARRAY['taxi-vtc','module-3','question-redigee'], 'TAXI-M3-QR-07', false,
   $mft$Le plan de protection complet du chauffeur indépendant.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Après dix-huit mois en micro-entreprise, Bilal fait le point : chiffre d'affaires en forte hausse, location du véhicule, commissions de plateforme et carburant représentant une part importante de ses encaissements, et projet d'embaucher un second chauffeur à terme. Analysez sa situation et bâtissez sa démarche de décision pour un éventuel changement de statut.$mft$,
   $mft$Réponse modèle. Trois signaux convergent. D'abord les charges réelles élevées : location, commissions et carburant peuvent dépasser l'abattement forfaitaire du micro ; dans ce cas, Bilal cotise et paie l'impôt sur un revenu surestimé, déconnecté de son bénéfice réel. Ensuite la croissance du chiffre d'affaires : elle rapproche des plafonds du régime micro et des seuils de la franchise en base de TVA (montants à vérifier dans les textes en vigueur) ; le dépassement se subit si on ne l'a pas anticipé. Enfin le projet d'embauche : le micro s'y prête mal ; salarier un second chauffeur et exploiter deux véhicules appelle une structure au réel, le plus souvent une société. Démarche de décision : 1) chiffrer : reconstituer sur douze mois le bénéfice réel (chiffre d'affaires moins toutes les charges) et le comparer au bénéfice forfaitaire du micro ; 2) simuler avec un comptable les scénarios entreprise individuelle au réel, EURL (dirigeant TNS) et SASU (assimilé salarié) : cotisations, protection sociale, et volet TVA (facturation au taux du transport de voyageurs en vigueur, récupération sur les frais) ; 3) préparer la transition : calendrier, formalités, information des plateformes, assurances et comptes au nom de la structure ; 4) décider sur les chiffres, pas sur l'habitude du statut actuel.$mft$,
   $mft$Barème /5 : les trois signaux identifiés (charges réelles contre abattement, plafonds et franchise à surveiller, projet d'embauche) (2 pts) ; démarche de chiffrage comparatif du bénéfice réel contre le forfait (1,5 pt) ; scénarios de statuts avec conséquence sociale (TNS ou assimilé salarié) et volet TVA formulé avec prudence (1 pt) ; organisation concrète de la transition (0,5 pt). Erreurs fréquentes : changer de statut par principe sans chiffrage ; ignorer le volet TVA du passage au réel.$mft$,
   5, 'difficile', ARRAY['taxi-vtc','module-3','question-redigee'], 'TAXI-M3-QR-08', false,
   $mft$Le diagnostic de sortie du micro : signaux, chiffrage, transition.$mft$);

  RAISE NOTICE 'Module 3 Taxi/VTC créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $taxim3$;
