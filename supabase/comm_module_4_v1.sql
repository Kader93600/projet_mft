-- =====================================================================
-- COMMISSIONNAIRE DE TRANSPORT : MODULE 4 : INCOTERMS ET DOUANE
-- v1 (juillet 2026)
-- Les Incoterms 2020 (frais, risques, familles E/F/C/D, lecture
-- opérationnelle) et les fondamentaux douaniers du commissionnaire :
-- représentation en douane, déclaration (espèce, origine, valeur),
-- régimes particuliers, export et TVA à l'import.
-- Statut : active = false (« à valider »). Idempotent.
-- =====================================================================

DO $commm4$
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

  DELETE FROM public.question_bank WHERE source_ref LIKE 'COMM-M4-%';
  DELETE FROM public.modules WHERE slug = 'comm-incoterms-douane';

  INSERT INTO public.modules (title, slug, bloc_id, summary, difficulty, duration_min, "order")
  VALUES ('Module 4 : Incoterms et douane',
    'comm-incoterms-douane', v_bloc,
    'Les Incoterms 2020 appliqués (transfert des frais et des risques, qui organise quoi) et les fondamentaux douaniers : représentation, régimes, déclaration et TVA à l''import.',
    'avance', 360, 40) RETURNING id INTO v_module;

  INSERT INTO public.formation_modules (formation_id, module_id, display_order, required)
  VALUES (v_formation, v_module, 40, true);

  -- ─── Leçon 1 : La logique des Incoterms 2020 ───────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'incoterms-logique',
    'Incoterms 2020 : ce qu''ils règlent (et ce qu''ils ne règlent pas)',
    $mft$> 🎯 **Objectifs**
> - Délimiter ce que les Incoterms 2020 répartissent (frais, risques, formalités) et ce qu'ils laissent au contrat de vente.
> - Classer les onze règles en quatre familles (E, F, C, D) et retenir la logique de chacune.
> - Repérer le piège de la famille C et distinguer les règles maritimes pures des règles multimodales.

## Trois lettres, trois questions

Les Incoterms (International Commercial Terms) sont des règles publiées par la Chambre de commerce internationale (ICC) ; la version de référence est celle de 2020. Insérées dans le contrat de vente, ces trois lettres répondent à trois questions entre le vendeur et l'acheteur :

- **les frais** : qui paie le pré-acheminement, le transport principal, l'assurance, les opérations de douane ;
- **les risques** : à partir de quel point précis la perte ou l'avarie de la marchandise change de camp ;
- **les formalités** : qui accomplit les démarches d'exportation et d'importation.

Tout aussi important pour le conseil client : ce que les Incoterms ne règlent **pas**. Ils ne disent rien du transfert de propriété, qui relève du contrat de vente et de ses clauses (réserve de propriété par exemple), rien du prix, rien des modalités de paiement. Quand un client affirme « nous restons propriétaires jusqu'à destination, c'est du DAP », le commissionnaire repère la confusion : DAP parle de frais et de risques, jamais de propriété.

> ⚠️ **Attention**
> Un Incoterm n'est pas un contrat de transport. Il organise la relation vendeur-acheteur ; les contrats de transport, eux, se concluent séparément, souvent par votre intermédiaire de commissionnaire. Ne confondez jamais les deux plans : c'est la base de toute analyse de litige.

## Les quatre familles : l'effort croissant du vendeur

Les onze règles se classent en quatre familles, de la moins engageante à la plus engageante pour le vendeur.

| Famille | Règles | Logique |
| --- | --- | --- |
| E | EXW | Départ usine : mise à disposition dans les locaux du vendeur, l'acheteur fait tout |
| F | FCA, FAS, FOB | Le vendeur remet la marchandise au transport ; le transport principal n'est PAS payé par lui |
| C | CFR, CIF, CPT, CIP | Le transport principal est PAYÉ par le vendeur, mais le risque est transféré au départ |
| D | DAP, DPU, DDP | Le vendeur assume frais et risques jusqu'à destination |

:::flow
1. Famille E (EXW) | L'acheteur organise tout, formalités export comprises
2. Famille F (FCA, FAS, FOB) | Le vendeur livre au transport, l'acheteur paie le voyage principal
3. Famille C (CFR, CIF, CPT, CIP) | Le vendeur paie le voyage principal, le risque voyage déjà chez l'acheteur
4. Famille D (DAP, DPU, DDP) | Le vendeur porte l'opération jusqu'à destination
:::

## Le piège majeur : la famille C

CFR, CIF, CPT et CIP partagent un mécanisme contre-intuitif : le vendeur **paie** le transport principal jusqu'au point convenu (port d'arrivée, lieu de destination), mais le **risque** est transféré à l'acheteur dès le départ : à l'embarquement pour CFR et CIF, à la remise au premier transporteur pour CPT et CIP. L'acheteur qui lit « CIF port d'arrivée » croit spontanément être protégé jusqu'à ce port : il ne l'est pas.

> ❌ **Piège à éviter**
> Sous CIF, une avarie survenue en mer est le problème de l'acheteur, pas celui du vendeur. Le vendeur a rempli son contrat en embarquant une marchandise conforme et en payant fret et assurance. La réclamation de l'acheteur passe par l'assurance, pas par le contrat de vente. Ce quiproquo alimente une part considérable des litiges du commerce international.

## Maritimes purs et multimodaux

Quatre règles sont réservées au transport maritime : **FAS, FOB, CFR et CIF**. Elles supposent un navire, un port, une mise à bord. Les sept autres (EXW, FCA, CPT, CIP, DAP, DPU, DDP) sont **multimodales** : elles fonctionnent pour tout mode et toute combinaison de modes, y compris le conteneur en porte à porte.

> 🔍 **Zoom : l'assurance sous CIF et CIP**
> Ces deux règles sont les seules à imposer au vendeur de souscrire une assurance sur la marchandise, au bénéfice de l'acheteur. Les niveaux de couverture minimaux exigés par la version 2020 diffèrent entre CIF et CIP : avant de conseiller un client sur ce point, vérifiez les clauses d'assurance exactes applicables (point à vérifier au cas par cas).

> 🎓 **Pour la pratique**
> Un réflexe de lecture en deux colonnes : pour chaque Incoterm, tracez mentalement la colonne « frais » et la colonne « risques ». Dans les familles E, F et D, les deux colonnes basculent au même point. Dans la famille C, elles se dissocient : c'est tout ce qu'il faut retenir pour éviter la majorité des contresens.

## ✅ Synthèse

- Les Incoterms répartissent **frais, risques et formalités** ; ils ne règlent ni la propriété ni le prix.
- Quatre familles : **E** (l'acheteur fait tout), **F** (transport principal non payé par le vendeur), **C** (payé par le vendeur, risque au départ), **D** (vendeur jusqu'à destination).
- **FAS, FOB, CFR, CIF** : maritimes purs ; les sept autres : multimodaux.
- CIF et CIP : assurance **obligatoire** du vendeur, niveaux de couverture à vérifier avant tout conseil.$mft$,
    $mft$Le périmètre exact des Incoterms 2020 (frais, risques, formalités, jamais la propriété ni le prix), les quatre familles E/F/C/D, le piège de la famille C (risque transféré au départ) et la distinction maritimes purs / multimodaux.$mft$,
    1, 45) RETURNING id INTO v_l1;

  -- ─── Leçon 2 : Lecture opérationnelle des Incoterms ────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'incoterms-appliques',
    'Lire un Incoterm en commissionnaire : quatre situations types',
    $mft$> 🎯 **Objectifs**
> - Traduire un Incoterm en plan d'opérations : qui vous mandate, pour quelles prestations.
> - Analyser les quatre situations types : EXW, FOB, CIF, DDP.
> - Conseiller un Incoterm selon le rapport de force, la maîtrise logistique et la sécurité de paiement.

## L'Incoterm, feuille de route du commissionnaire

Pour le commissionnaire, l'Incoterm d'une vente répond à une question très concrète : **qui est mon mandant, et jusqu'où va ma mission ?** Quatre situations types couvrent l'essentiel des dossiers.

**Sous EXW (départ usine)** : le vendeur met la marchandise à disposition dans ses locaux, point final. L'acheteur, votre mandant, vous confie la totalité de la chaîne : enlèvement, formalités export du pays de départ, transport principal, assurance, douane import, livraison finale. C'est le mandat le plus complet : et le plus délicat quand l'export se joue dans un pays que l'acheteur ne connaît pas.

**Sous FOB (port de départ convenu)** : le vendeur assume jusqu'à la mise à bord du navire au port de départ ; l'acheteur prend le relais dès l'embarquement. Mandaté par l'acheteur, vous organisez le transport maritime, l'assurance éventuelle et toute l'importation.

**Sous CIF (port d'arrivée convenu)** : le vendeur paie la mer et l'assurance jusqu'au port d'arrivée, mais le risque voyage avec l'acheteur dès l'embarquement. En cas d'avarie pendant la traversée, la réclamation de l'acheteur ne vise pas le vendeur : elle actionne l'assurance que celui-ci a souscrite au bénéfice de l'acheteur. Votre rôle : sécuriser les réserves à l'arrivée et monter le dossier assurance.

**Sous DDP (rendu droits acquittés)** : le vendeur porte tout, jusqu'à la douane import et la TVA du pays de destination. Vendre DDP vers un pays tiers, c'est gérer à distance une fiscalité locale que l'on ne maîtrise pas : ce choix est souvent déconseillé au vendeur, sauf organisation solide sur place.

## Cas chiffré : la même vente sous trois Incoterms

Un lot expédié de Busan vers Lyon, avec les postes suivants : pré-acheminement et export 900 EUR, fret maritime 2 400 EUR, assurance 300 EUR, douane import et livraison France 1 100 EUR.

| Poste | FOB Busan | CIF Le Havre | DDP Lyon |
| --- | --- | --- | --- |
| Pré-acheminement + export (900 EUR) | Vendeur | Vendeur | Vendeur |
| Fret maritime (2 400 EUR) | Acheteur | Vendeur | Vendeur |
| Assurance (300 EUR) | Acheteur (s'il s'assure) | Vendeur (obligatoire) | Vendeur |
| Douane import + livraison (1 100 EUR) | Acheteur | Acheteur | Vendeur |
| Risque pendant la traversée | Acheteur | Acheteur | Vendeur |

Deux lectures s'imposent. D'abord, le prix facturé suit la charge : plus le vendeur assume de postes, plus il les répercute dans son prix de vente. Ensuite, la ligne des risques ne suit pas celle des frais : sous CIF, l'acheteur supporte la traversée alors qu'il n'en paie rien.

> 📌 **À retenir**
> Frais et risques se lisent séparément, toujours. Le tableau des frais dit qui paie ; il ne dit jamais qui supporte l'avarie.

## La réclamation sous CIF, pas à pas

:::flow
1. Constat à l'arrivée | Avarie découverte au déchargement au port ou à la livraison
2. Réserves immédiates | Réserves précises, photos, constat contradictoire : elles conditionnent le recours
3. Qui supporte | Le risque est à l'acheteur depuis l'embarquement : pas de recours fondé sur le contrat de vente
4. Quelle assurance | Celle souscrite par le vendeur au bénéfice de l'acheteur : notification à l'assureur
5. Dossier | Documents de transport, certificat d'assurance, facture, expertise : le commissionnaire assemble tout
:::

## Choisir l'Incoterm : trois curseurs

- **Le rapport de force commercial** : qui, du vendeur ou de l'acheteur, peut imposer ses conditions ? L'Incoterm suit souvent la négociation globale.
- **La maîtrise logistique** : confier le transport à celui qui achète le mieux le fret ; un acheteur outillé (ou bien accompagné par son commissionnaire) préfère souvent acheter FOB, voire EXW, pour garder la main.
- **La sécurité de paiement** : quand la vente est réglée par crédit documentaire, la banque exige souvent CIF ou FOB, dont les points de transfert et les documents sont clairement identifiables.

> 💡 **Astuce**
> Le bon conseil n'est pas « l'Incoterm le plus protecteur » dans l'absolu : c'est celui que votre client peut réellement exécuter. Recommander EXW à un acheteur incapable de gérer une douane export lointaine, c'est préparer le litige suivant.

## ✅ Synthèse

- EXW : mandat total pour le compte de l'**acheteur** ; FOB : vendeur jusqu'au navire au port de départ, acheteur ensuite.
- CIF : le vendeur paie mer et assurance jusqu'au port d'arrivée, mais le **risque** est à l'acheteur dès l'embarquement : réclamation via l'assurance.
- DDP : le vendeur assume jusqu'à la douane import et la TVA locale : souvent déconseillé.
- Choix de l'Incoterm : rapport de force, maîtrise logistique, sécurité de paiement (crédit documentaire : souvent CIF ou FOB).$mft$,
    $mft$La lecture opérationnelle des quatre situations types (EXW, FOB, CIF, DDP), un cas chiffré de répartition des frais, la réclamation sous CIF pas à pas et les trois curseurs du choix d'un Incoterm.$mft$,
    2, 50) RETURNING id INTO v_l2;

  -- ─── Leçon 3 : Fondamentaux douaniers ──────────────────────────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'douane-fondamentaux',
    'Douane : acteurs, déclaration et valeur',
    $mft$> 🎯 **Objectifs**
> - Situer l'importation dans l'Union douanière : mise en libre pratique, mise à la consommation.
> - Identifier les acteurs : opérateur (EORI), représentant en douane enregistré, administration.
> - Construire une déclaration sur ses trois piliers : espèce, origine, valeur.

## L'Union douanière : une frontière extérieure commune

L'Union européenne forme une union douanière : les marchandises circulent librement à l'intérieur, et la frontière douanière se joue aux points d'entrée et de sortie de l'Union. À l'importation, deux notions se combinent :

- la **mise en libre pratique** : l'acquittement des droits de douane sur la marchandise tierce ;
- la **mise à la consommation** : l'application de la TVA, qui permet la commercialisation sur le marché intérieur.

Retenez le couple : libre pratique = droits de douane ; mise à la consommation = TVA. Les deux réunies font d'une marchandise tierce une marchandise pleinement commercialisable dans l'Union.

## Les acteurs de l'opération douanière

**L'opérateur** (importateur ou exportateur) : il doit être immatriculé **EORI**, l'identifiant obligatoire sans lequel aucune opération douanière n'est possible. C'est la première vérification de tout nouveau dossier.

**Le représentant en douane enregistré (RDE)** : le professionnel qui accomplit les formalités pour le compte de l'opérateur. Le commissionnaire de transport est très souvent RDE : c'est un prolongement naturel de son métier d'organisateur. Le mandat précise le mode de représentation, **directe ou indirecte**, et ce choix emporte des conséquences différentes sur la responsabilité du représentant : les nuances exactes de cette répartition sont à vérifier au cas par cas avant de signer un mandat.

**L'administration des douanes (DGDDI)** : elle reçoit les déclarations, perçoit les droits et contrôle, avant comme après le dédouanement.

> ⚠️ **Attention**
> Le mode de représentation n'est pas une case administrative anodine : il conditionne qui répond de quoi en cas de redressement. C'est un point de vigilance absolu du commissionnaire-RDE (conséquences précises à vérifier selon le mandat).

## La déclaration : espèce, origine, valeur

:::flow
1. Espèce | Classer la marchandise dans la nomenclature tarifaire : le classement détermine le taux des droits
2. Origine | Établir l'origine, préférentielle ou non selon les accords, preuves à l'appui
3. Valeur | Construire la valeur en douane : valeur de transaction, ajustée selon l'Incoterm
4. Déclarer | Déposer la déclaration, acquitter les droits et traiter la TVA
5. Archiver | Conserver toutes les pièces : le contrôle peut venir après coup
:::

**L'espèce** : chaque marchandise se classe dans la nomenclature tarifaire ; de ce classement découle le taux des droits applicable. Un produit mal classé, c'est un taux faux et une déclaration fausse.

**L'origine** : elle peut être préférentielle (un accord entre l'Union et le pays concerné réduit ou supprime les droits, preuves d'origine à l'appui) ou non préférentielle. L'origine préférentielle mal documentée est un grand classique du contentieux douanier.

**La valeur en douane** : elle part de la valeur de transaction (le prix effectivement payé ou à payer) et s'ajuste. C'est ici que le module boucle sur lui-même : les ajustements de fret et d'assurance dépendent directement de l'**Incoterm** d'achat. Un achat FOB oblige à réintégrer le fret et l'assurance non compris dans le prix ; un achat CIF les contient déjà. Lire l'Incoterm, c'est déjà préparer la valeur en douane.

> 💡 **Astuce**
> Sur chaque dossier import, posez trois questions dans cet ordre : quoi (espèce), d'où (origine), combien (valeur). Si l'une des trois réponses est fragile, la déclaration l'est aussi.

## Contrôles et contentieux

La douane contrôle au moment du dédouanement, mais aussi **a posteriori**, parfois longtemps après l'opération. Si une donnée déclarée s'avère erronée (classement inexact, origine invalidée, valeur minorée), une **dette douanière** naît : les droits éludés deviennent exigibles, assortis le cas échéant de sanctions. Le **déclarant** engage sa responsabilité sur ce qu'il signe : la rigueur documentaire n'est pas une option pour le commissionnaire-RDE, c'est la matière première de son métier.

> 🎓 **Pour la pratique**
> Constituez pour chaque client importateur un dossier permanent : EORI, mandat de représentation, fiches de classement des produits récurrents, preuves d'origine, conditions d'achat (Incoterms). Le jour du contrôle, ce dossier fait toute la différence.

## ✅ Synthèse

- Import UE : **mise en libre pratique** (droits de douane) + **mise à la consommation** (TVA).
- Acteurs : opérateur immatriculé **EORI**, **RDE** (mandat, représentation directe ou indirecte : conséquences à vérifier), DGDDI.
- Déclaration : **espèce** (nomenclature, taux), **origine** (accords, preuves), **valeur** (transaction + ajustements selon l'Incoterm).
- Contrôle a posteriori : la **dette douanière** sanctionne les erreurs ; le déclarant en répond.$mft$,
    $mft$L'Union douanière (libre pratique et mise à la consommation), les acteurs (opérateur EORI, RDE et modes de représentation, DGDDI), le triptyque espèce/origine/valeur et le lien valeur en douane / Incoterm, les contrôles a posteriori.$mft$,
    3, 45) RETURNING id INTO v_l3;

  -- ─── Leçon 4 : Régimes particuliers, export et TVA import ──────────
  INSERT INTO public.lessons (module_id, slug, title, content_md, summary_md, "order", duration_min)
  VALUES (v_module, 'regimes-et-tva',
    'Régimes particuliers, export et TVA à l''import',
    $mft$> 🎯 **Objectifs**
> - Proposer le bon régime particulier selon l'usage du client : circuler, stocker, transformer.
> - Sécuriser une exportation : déclaration, preuve de sortie, documents d'accompagnement.
> - Expliquer l'autoliquidation de la TVA à l'import et l'exigence de rigueur du déclarant.

## Les régimes particuliers : raisonner par l'usage

Face à un client, ne récitez pas la liste des régimes : partez de ce qu'il veut FAIRE de la marchandise.

| Le client veut... | Régime adapté | Effet |
| --- | --- | --- |
| Faire circuler une marchandise non dédouanée | Transit (T1) | Circuler sous douane jusqu'au bureau de destination |
| Stocker sans vendre tout de suite | Entrepôt douanier | Stocker sans acquitter les droits, qui restent suspendus |
| Transformer avant de décider | Admission / perfectionnement | Travailler la marchandise sous régime douanier |

**Le transit (T1)** répond au besoin de mouvement : des conteneurs débarqués au Havre peuvent rejoindre un bureau intérieur ou un entrepôt sans être dédouanés au port. La marchandise voyage sous contrôle douanier jusqu'au bureau de destination, où les formalités s'accomplissent.

**L'entrepôt douanier** répond au besoin de stockage : les droits sont suspendus tant que la marchandise reste sous le régime. L'intérêt saute aux yeux dès qu'une partie du flux repartira hors de l'Union : cette part ne supportera jamais les droits européens. Pour le reste, les droits ne sont acquittés qu'à la sortie d'entrepôt, au plus près de la vente : trésorerie optimisée.

**L'admission et le perfectionnement** répondent au besoin de transformation : travailler la marchandise sous régime douanier avant de fixer son sort définitif. Les conditions et modalités précises de ces régimes se calent avec le bureau de douane (points à vérifier dossier par dossier).

> 💡 **Astuce**
> L'argument qui parle aux clients n'est pas réglementaire, il est financier : « pourquoi payer des droits sur des marchandises qui ne resteront pas dans l'Union, ou les payer six mois avant de les vendre ? » Les régimes particuliers sont d'abord des outils de trésorerie.

## L'exportation : déclarer, prouver, accompagner

Trois réflexes structurent l'export :

- **la déclaration d'exportation** : l'opération se déclare en douane avant la sortie du territoire ;
- **la preuve de sortie** : c'est elle qui justifie l'exonération de TVA dont bénéficie le vendeur exportateur ; sans preuve de sortie conservée, l'exonération devient indéfendable en cas de contrôle ;
- **les documents d'accompagnement** : la marchandise voyage avec les documents exigés, cohérents entre eux (facture, documents de transport, déclaration).

> ⚠️ **Attention**
> La preuve de sortie n'est pas une formalité de plus : c'est la pièce qui protège l'exonération de TVA du vendeur. Le commissionnaire qui organise l'export doit la sécuriser et la transmettre systématiquement : c'est un service à part entière, et une source de responsabilité s'il l'oublie.

## La TVA à l'import : l'autoliquidation

Le principe, désormais généralisé en France : la TVA à l'import ne se décaisse plus au moment du dédouanement ; elle est **autoliquidée** sur la déclaration de TVA française de l'importateur. Conséquence directe : la trésorerie est préservée, plus d'avance de TVA à chaque conteneur dédouané. Les modalités pratiques (conditions, lignes de la déclaration, situations particulières) sont à vérifier selon la situation de chaque client avant tout conseil précis.

:::timeline
1. Arrivée au port | Marchandise tierce non dédouanée
2. Transit T1 | Acheminement sous douane vers le site ou l'entrepôt
3. Entrepôt douanier | Stockage, droits suspendus
4. Sortie d'entrepôt | Mise en libre pratique de la part vendue dans l'Union : droits acquittés
5. Déclaration de TVA | TVA à l'import autoliquidée : pas de décaissement en douane
:::

## Le déclarant négligent : ce qu'il risque

Les erreurs de déclaration (espèce inexacte, origine non prouvée, valeur minorée, preuve de sortie manquante) se paient : rappel des droits éludés (la dette douanière), sanctions le cas échéant, et dégradation durable de la relation avec l'administration. Pour le **commissionnaire-RDE**, l'équation est simple : il engage sa propre responsabilité ET celle de son client sur chaque déclaration signée. La rigueur documentaire absolue (mandats précis, pièces vérifiées, archivage complet, cohérence entre facture, Incoterm et valeur déclarée) n'est pas du zèle : c'est le cœur de la valeur qu'il vend.

> 📌 **À retenir**
> Un bon dossier douane se reconnaît à ceci : un contrôleur qui l'ouvre longtemps après l'opération y trouve, sans aide, la réponse aux trois questions : quoi, d'où, combien. Si vous devez « chercher » une pièce, c'est qu'elle manque.

## ✅ Synthèse

- Régimes par l'usage : **circuler** (transit T1), **stocker** (entrepôt douanier, droits suspendus), **transformer** (admission/perfectionnement).
- Export : déclaration, **preuve de sortie** (elle fonde l'exonération de TVA du vendeur), documents cohérents.
- TVA import : **autoliquidation** sur la déclaration de TVA française, trésorerie préservée (modalités à vérifier par client).
- Déclarant négligent : dette douanière et sanctions ; le RDE vit de sa **rigueur documentaire**.$mft$,
    $mft$Les régimes particuliers présentés par l'usage (transit T1, entrepôt douanier, admission/perfectionnement), les trois réflexes de l'export (déclaration, preuve de sortie, documents), l'autoliquidation de la TVA à l'import et la responsabilité du déclarant.$mft$,
    4, 45) RETURNING id INTO v_l4;

  -- ─── Quiz ────────────────────────────────────────────────────────────
  INSERT INTO public.quizzes (module_id, title, description, "type", pass_threshold, timer_enabled)
  VALUES (v_module, 'Quiz : Incoterms et douane',
    'Vérifiez le module 4 : familles d''Incoterms, transfert des risques, déclaration en douane, régimes particuliers et TVA à l''import.',
    'entrainement', 70, false) RETURNING id INTO v_quiz;

  -- ─── QCM (12) ───────────────────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Votre nouveau client croit qu'en vendant DAP il reste propriétaire de la marchandise jusqu'à destination. Que lui répondez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Les Incoterms répartissent frais, risques et formalités : le transfert de propriété relève du contrat de vente, pas de l'Incoterm","is_correct":true},
      {"id":"b","label":"Il a raison : DAP transfère la propriété à l'arrivée","is_correct":false},
      {"id":"c","label":"La propriété se transfère toujours à l'embarquement, quel que soit l'Incoterm","is_correct":false},
      {"id":"d","label":"Seule la douane décide du moment du transfert de propriété","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['commissionnaire','module-4','qcm-v1'], 'COMM-M4-QCM-01', false,
    $mft$Les Incoterms ne traitent ni la propriété ni le prix : DAP fixe seulement le point de transfert des frais et des risques. Les distracteurs confondent propriété, risque et formalités.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Un importateur français achète EXW Shanghai. Qui doit organiser l'enlèvement à l'usine, la douane export chinoise et tout le transport ?$mft$,
    $mft$[
      {"id":"a","label":"L'acheteur français : sous EXW, le vendeur met seulement la marchandise à disposition dans ses locaux","is_correct":true},
      {"id":"b","label":"Le vendeur chinois, jusqu'au port de Shanghai","is_correct":false},
      {"id":"c","label":"Le vendeur et l'acheteur, à parts égales","is_correct":false},
      {"id":"d","label":"La compagnie maritime, automatiquement","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['commissionnaire','module-4','qcm-v1'], 'COMM-M4-QCM-02', false,
    $mft$EXW est l'Incoterm du vendeur minimaliste : tout le reste, formalités export comprises, incombe à l'acheteur, qui mandate le plus souvent un commissionnaire pour l'ensemble.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Une PME lyonnaise vend FOB Le Havre. Jusqu'à quel point supporte-t-elle les frais et les risques ?$mft$,
    $mft$[
      {"id":"a","label":"Jusqu'à la mise à bord du navire au port de départ","is_correct":true},
      {"id":"b","label":"Jusqu'au port d'arrivée convenu avec l'acheteur","is_correct":false},
      {"id":"c","label":"Jusqu'à l'entrepôt du client final","is_correct":false},
      {"id":"d","label":"Jusqu'à la sortie de son usine seulement","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['commissionnaire','module-4','qcm-v1'], 'COMM-M4-QCM-03', false,
    $mft$FOB : le vendeur assume le pré-acheminement, l'export et la mise à bord au port de départ ; l'acheteur prend le relais dès l'embarquement. Le port d'arrivée relèverait de CFR/CIF pour les frais, l'usine d'EXW.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Une entreprise française veut réaliser sa toute première importation. Avant toute opération en douane, elle doit obligatoirement disposer :$mft$,
    $mft$[
      {"id":"a","label":"D'un numéro EORI qui l'identifie comme opérateur auprès de la douane","is_correct":true},
      {"id":"b","label":"D'un entrepôt douanier agréé","is_correct":false},
      {"id":"c","label":"D'une licence de transport intérieur","is_correct":false},
      {"id":"d","label":"D'un crédit documentaire ouvert dans sa banque","is_correct":false}
    ]$mft$::jsonb,
    1, 'facile', ARRAY['commissionnaire','module-4','qcm-v1'], 'COMM-M4-QCM-04', false,
    $mft$L'EORI est l'identifiant obligatoire de l'opérateur pour toute opération douanière ; l'entrepôt, la licence de transport et le crédit documentaire répondent à d'autres besoins.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l1, 'qcm',
    $mft$Une marchandise vendue CPT Varsovie est avariée pendant le transport principal, pourtant payé par le vendeur. Qui supporte la perte ?$mft$,
    $mft$[
      {"id":"a","label":"L'acheteur : en famille C, le risque est transféré dès la remise au premier transporteur, même si le vendeur paie le transport","is_correct":true},
      {"id":"b","label":"Le vendeur, puisqu'il a payé le transport jusqu'à Varsovie","is_correct":false},
      {"id":"c","label":"Le transporteur, systématiquement et intégralement","is_correct":false},
      {"id":"d","label":"Personne : la famille C supprime la notion de risque","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-4','qcm-v1'], 'COMM-M4-QCM-05', false,
    $mft$C'est LE piège de la famille C : le vendeur paie jusqu'à destination, mais la perte en cours de route est l'affaire de l'acheteur. Payer le voyage n'est pas en supporter les aléas.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un conteneur est avarié pendant la traversée sous CIF Anvers. Votre client acheteur veut « se retourner contre le vendeur ». Que lui expliquez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"Le risque lui a été transféré à l'embarquement : il doit actionner l'assurance que le vendeur avait l'obligation de souscrire","is_correct":true},
      {"id":"b","label":"Le vendeur supporte l'avarie puisqu'il a payé le fret et l'assurance","is_correct":false},
      {"id":"c","label":"CIF oblige le vendeur à relivrer gratuitement la marchandise","is_correct":false},
      {"id":"d","label":"Une avarie en mer n'est jamais indemnisable","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-4','qcm-v1'], 'COMM-M4-QCM-06', false,
    $mft$Sous CIF, le vendeur paie la mer et l'assurance jusqu'au port d'arrivée, mais le risque voyage avec l'acheteur dès l'embarquement : la réclamation passe par l'assurance, pas par le contrat de vente.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Import par mer : facture d'achat FOB 40 000 EUR, fret maritime 2 000 EUR, assurance 200 EUR. Comment se construit la valeur en douane ?$mft$,
    $mft$[
      {"id":"a","label":"Valeur de transaction ajustée : le fret et l'assurance non compris dans le prix FOB viennent s'y ajouter","is_correct":true},
      {"id":"b","label":"40 000 EUR seulement : la facture fait toujours foi telle quelle","is_correct":false},
      {"id":"c","label":"On déduit le fret de la facture pour obtenir la valeur en douane","is_correct":false},
      {"id":"d","label":"Le déclarant fixe librement la valeur selon le cours du marché","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-4','qcm-v1'], 'COMM-M4-QCM-07', false,
    $mft$La valeur en douane part de la valeur de transaction et s'ajuste selon l'Incoterm : en achat FOB, fret et assurance doivent être réintégrés ; en CIF, ils figurent déjà dans le prix.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Des conteneurs non dédouanés arrivent au Havre et doivent être dédouanés dans un bureau intérieur à Lyon. Quel régime permet ce trajet ?$mft$,
    $mft$[
      {"id":"a","label":"Le transit (T1) : la marchandise circule sous douane jusqu'au bureau de destination","is_correct":true},
      {"id":"b","label":"La mise en libre pratique anticipée dès le quai du Havre","is_correct":false},
      {"id":"c","label":"L'entrepôt douanier itinérant","is_correct":false},
      {"id":"d","label":"L'exportation temporaire","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-4','qcm-v1'], 'COMM-M4-QCM-08', false,
    $mft$Le T1 déplace la marchandise sous contrôle douanier sans acquitter les droits en chemin ; l'« entrepôt itinérant » n'existe pas et la libre pratique au Havre est précisément ce que le client veut éviter.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Votre client importateur redoute de « devoir avancer la TVA à chaque conteneur dédouané en France ». Que lui répondez-vous ?$mft$,
    $mft$[
      {"id":"a","label":"La TVA à l'import s'autoliquide sur sa déclaration de TVA française : pas de décaissement au moment du dédouanement","is_correct":true},
      {"id":"b","label":"La TVA doit toujours être payée comptant au bureau de douane","is_correct":false},
      {"id":"c","label":"La TVA à l'import n'existe pas pour les entreprises","is_correct":false},
      {"id":"d","label":"Seul un entrepôt douanier permet d'éviter cette avance de TVA","is_correct":false}
    ]$mft$::jsonb,
    1, 'moyen', ARRAY['commissionnaire','module-4','qcm-v1'], 'COMM-M4-QCM-09', false,
    $mft$L'autoliquidation généralisée porte la TVA import sur la déclaration de TVA : la trésorerie est préservée. L'entrepôt douanier, lui, suspend les droits pendant le stockage : autre outil, autre besoin.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l2, 'qcm',
    $mft$Un industriel français veut vendre DDP à un client d'un pays tiers « pour lui rendre service ». Votre alerte principale de commissionnaire :$mft$,
    $mft$[
      {"id":"a","label":"En DDP, il assume la douane import et la TVA locale du pays de destination : un engagement souvent déconseillé","is_correct":true},
      {"id":"b","label":"DDP interdit de recourir à un commissionnaire","is_correct":false},
      {"id":"c","label":"DDP transfère le risque à l'acheteur dès la sortie d'usine","is_correct":false},
      {"id":"d","label":"DDP dispense de déclarer l'exportation en France","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['commissionnaire','module-4','qcm-v1'], 'COMM-M4-QCM-10', false,
    $mft$DDP pousse l'obligation du vendeur jusqu'à la douane import et la fiscalité locale, difficiles à maîtriser à distance : c'est l'exact inverse d'EXW, pas une simplification. L'export reste déclaré au départ.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l3, 'qcm',
    $mft$Deux ans après une importation, un contrôle requalifie le classement tarifaire (l'espèce) et réclame un complément de droits. Comment s'analyse cette situation ?$mft$,
    $mft$[
      {"id":"a","label":"Une dette douanière naît du contrôle a posteriori, et le déclarant peut être appelé à en répondre","is_correct":true},
      {"id":"b","label":"Toute réclamation devient impossible dès le lendemain du dédouanement","is_correct":false},
      {"id":"c","label":"Seul le transporteur maritime est redevable du complément","is_correct":false},
      {"id":"d","label":"La douane doit racheter la marchandise mal classée","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['commissionnaire','module-4','qcm-v1'], 'COMM-M4-QCM-11', false,
    $mft$Le contrôle a posteriori fait partie du dispositif : une erreur d'espèce génère une dette douanière (droits éludés exigibles), d'où la rigueur documentaire absolue exigée du déclarant. Le transporteur n'a rien déclaré.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
  VALUES (v_formation, v_module, v_l4, 'qcm',
    $mft$Votre client importe d'Asie des marchandises dont 40 % repartiront hors de l'Union sans être vendues en Europe. Quel régime lui évite de payer des droits sur cette part ?$mft$,
    $mft$[
      {"id":"a","label":"L'entrepôt douanier : les droits sont suspendus pendant le stockage et ne seront dus que sur la part mise en libre pratique","is_correct":true},
      {"id":"b","label":"La mise en libre pratique immédiate de la totalité à l'arrivée","is_correct":false},
      {"id":"c","label":"Le paiement des droits avec remboursement automatique, sans formalité","is_correct":false},
      {"id":"d","label":"La déclaration de la totalité comme échantillons gratuits","is_correct":false}
    ]$mft$::jsonb,
    1, 'difficile', ARRAY['commissionnaire','module-4','qcm-v1'], 'COMM-M4-QCM-12', false,
    $mft$Sous entrepôt douanier, la part réexpédiée hors de l'Union ne supporte jamais les droits européens ; la part vendue dans l'Union les acquitte à sa sortie d'entrepôt. Les distracteurs sont soit ruineux, soit frauduleux.$mft$)
  RETURNING id INTO v_q;
  v_ord := v_ord + 10;
  INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order) VALUES (v_quiz, v_q, v_ord);

  -- ─── QUESTIONS COURTES (10) ─────────────────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Un stagiaire affirme : « l'Incoterm fixe le prix et le moment où l'acheteur devient propriétaire ». Rectifiez : que répartissent réellement les Incoterms ?$mft$,
   $mft$Ils répartissent les frais, les risques et les formalités (export, import) entre vendeur et acheteur ; le prix et le transfert de propriété relèvent du contrat de vente.$mft$,
   2, 'facile', ARRAY['commissionnaire','module-4','question-courte'], 'COMM-M4-QC-01', false,
   $mft$Frais, risques, formalités : rien d'autre.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Citez les quatre Incoterms exclusivement maritimes de la version 2020.$mft$,
   $mft$FAS, FOB, CFR et CIF.$mft$,
   2, 'facile', ARRAY['commissionnaire','module-4','question-courte'], 'COMM-M4-QC-02', false,
   $mft$Les sept autres règles sont multimodales.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$À quoi sert le régime de transit T1 pour votre client importateur ?$mft$,
   $mft$À faire circuler une marchandise non dédouanée sous contrôle douanier jusqu'au bureau de destination, où les formalités seront accomplies.$mft$,
   2, 'facile', ARRAY['commissionnaire','module-4','question-courte'], 'COMM-M4-QC-03', false,
   $mft$Circuler sous douane, sans acquitter les droits en chemin.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$En quoi la famille C (CFR, CIF, CPT, CIP) est-elle le piège classique des acheteurs ?$mft$,
   $mft$Le vendeur paie le transport principal jusqu'au point convenu, mais le risque est transféré à l'acheteur dès le départ (embarquement ou remise au premier transporteur) : l'acheteur se croit couvert jusqu'à destination alors qu'il supporte les aléas du voyage.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-4','question-courte'], 'COMM-M4-QC-04', false,
   $mft$Frais jusqu'à destination, risque au départ : la dissociation attendue.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Votre client français achète EXW Osaka (Japon). En tant que commissionnaire, qui vous mandate et pour quelles étapes ?$mft$,
   $mft$L'acheteur français vous mandate pour la totalité de la chaîne : enlèvement chez le vendeur, formalités export japonaises, transport principal, assurance éventuelle, douane import dans l'Union et livraison finale.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-4','question-courte'], 'COMM-M4-QC-05', false,
   $mft$EXW = vendeur minimaliste : l'acheteur (et son commissionnaire) fait tout.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$À l'importation dans l'Union européenne, distinguez « mise en libre pratique » et « mise à la consommation ».$mft$,
   $mft$La mise en libre pratique correspond à l'acquittement des droits de douane ; la mise à la consommation y ajoute la TVA : les deux réunies permettent de commercialiser la marchandise sur le marché intérieur.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-4','question-courte'], 'COMM-M4-QC-06', false,
   $mft$Libre pratique = droits de douane ; mise à la consommation = TVA.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Citez les trois données fondamentales de toute déclaration en douane et le rôle de chacune.$mft$,
   $mft$L'espèce (classement dans la nomenclature tarifaire, qui détermine le taux des droits), l'origine (préférentielle ou non selon les accords, preuves à l'appui) et la valeur en douane (valeur de transaction ajustée, base de calcul des droits).$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-4','question-courte'], 'COMM-M4-QC-07', false,
   $mft$Espèce, origine, valeur : le triptyque du déclarant.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Pourquoi l'autoliquidation de la TVA à l'import préserve-t-elle la trésorerie de votre client importateur ?$mft$,
   $mft$Parce que la TVA à l'import n'est pas décaissée au moment du dédouanement : elle est autoliquidée sur la déclaration de TVA française du client, donc aucune avance de fonds à chaque conteneur dédouané.$mft$,
   2, 'moyen', ARRAY['commissionnaire','module-4','question-courte'], 'COMM-M4-QC-08', false,
   $mft$Autoliquidation = TVA déclarée, pas décaissée au passage en douane.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Une vente internationale est réglée par crédit documentaire. Pourquoi ce montage oriente-t-il souvent le choix vers CIF ou FOB ?$mft$,
   $mft$Parce que la sécurité du paiement repose sur des documents et des points de transfert clairement identifiables (embarquement, documents maritimes) : le crédit documentaire exige donc souvent CIF ou FOB, et le choix de l'Incoterm dépend aussi du montage financier, pas seulement de la logistique.$mft$,
   2, 'difficile', ARRAY['commissionnaire','module-4','question-courte'], 'COMM-M4-QC-09', false,
   $mft$La sécurité de paiement est le troisième curseur du choix d'un Incoterm.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Pourquoi la valeur en douane d'une même marchandise importée diffère-t-elle selon que l'achat est conclu FOB ou CIF ?$mft$,
   $mft$Parce que la valeur en douane part de la valeur de transaction puis s'ajuste selon l'Incoterm : en achat FOB, le fret et l'assurance doivent être réintégrés car ils ne sont pas compris dans le prix ; en achat CIF, ils y figurent déjà.$mft$,
   2, 'difficile', ARRAY['commissionnaire','module-4','question-courte'], 'COMM-M4-QC-10', false,
   $mft$L'Incoterm d'achat détermine les ajustements de fret et d'assurance.$mft$);

  -- ─── QUESTIONS RÉDIGÉES (8) : barème /5 ────────────────────────────
  INSERT INTO public.question_bank (formation_id, module_id, lesson_id, "type", statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active, explanation) VALUES
  (v_formation, v_module, v_l1, 'qr',
   $mft$Un client novice vous demande « à quoi servent les Incoterms et comment s'y retrouver ». Expliquez-lui le périmètre exact des Incoterms 2020, puis la logique des quatre familles E, F, C et D avec un exemple par famille, en terminant par le piège majeur à connaître.$mft$,
   $mft$Réponse modèle. Les Incoterms, publiés par la Chambre de commerce internationale (version 2020), répartissent entre vendeur et acheteur les frais, les risques et les formalités : ils ne règlent ni le prix ni le transfert de propriété, qui restent au contrat de vente. Quatre familles ordonnent l'effort croissant du vendeur. Famille E (EXW) : la marchandise est mise à disposition à l'usine, l'acheteur fait tout, formalités export comprises. Famille F (FCA, FAS, FOB) : le vendeur remet la marchandise au transport sans payer le transport principal ; exemple, FOB : vendeur jusqu'à la mise à bord au port de départ. Famille C (CFR, CIF, CPT, CIP) : le vendeur PAIE le transport principal ; exemple, CIF : mer et assurance payées jusqu'au port d'arrivée. Famille D (DAP, DPU, DDP) : le vendeur assume frais ET risques jusqu'à destination. Le piège majeur se loge dans la famille C : les frais courent jusqu'à destination mais le risque est transféré dès le départ ; une avarie en mer sous CIF est donc l'affaire de l'acheteur, via l'assurance que le vendeur a l'obligation de souscrire. D'où la règle de lecture : toujours distinguer la colonne des frais de celle des risques.$mft$,
   $mft$Barème /5 : périmètre exact (frais/risques/formalités, exclusion de la propriété et du prix) (1,5 pt) ; les quatre familles avec logique et exemple correct chacune (2 pts) ; piège de la famille C explicité (frais à destination, risque au départ) (1,5 pt). Erreurs fréquentes : affirmer que l'Incoterm transfère la propriété ; confondre le point de transfert des frais et celui des risques.$mft$,
   5, 'facile', ARRAY['commissionnaire','module-4','question-redigee'], 'COMM-M4-QR-01', false,
   $mft$Le socle du module : périmètre, familles, piège de la famille C.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Votre client français achète pour la première fois EXW Osaka (Japon). Listez, dans l'ordre, tout ce que vous devez organiser pour lui en tant que commissionnaire, et expliquez pourquoi EXW fait peser la quasi-totalité de l'opération sur l'acheteur.$mft$,
   $mft$Réponse modèle. Sous EXW, le vendeur remplit son obligation en mettant la marchandise à disposition dans ses locaux : tout le reste incombe à l'acheteur, qui nous mandate. Séquence à organiser : 1) enlèvement à l'usine d'Osaka (pré-acheminement) ; 2) formalités douanières export au Japon ; 3) réservation du transport principal (maritime ou aérien) ; 4) assurance de la marchandise pour le compte du client ; 5) formalités import dans l'Union : déclaration, droits de douane, TVA à l'import autoliquidée sur la déclaration de TVA ; 6) post-acheminement jusqu'à l'entrepôt du client. Pourquoi tout pèse sur l'acheteur : EXW est le degré zéro de l'engagement du vendeur ; le risque est transféré dès la mise à disposition dans ses locaux. C'est aussi ce qui rend EXW délicat pour un acheteur peu outillé : il doit gérer une douane export dans un pays qu'il ne connaît pas, avec un vendeur peu incité à coopérer. Le commissionnaire apporte exactement cette maîtrise : c'est le scénario où son mandat est le plus complet, et où sa valeur ajoutée se démontre le mieux.$mft$,
   $mft$Barème /5 : chaîne complète et ordonnée (enlèvement, export Japon, transport principal, assurance, import Union, post-acheminement) (2,5 pts) ; logique EXW (vendeur minimaliste, risque dès la mise à disposition) (1,5 pt) ; rôle du commissionnaire mandaté par l'acheteur (1 pt). Erreurs fréquentes : oublier la douane export japonaise ; croire que le vendeur doit charger et exporter.$mft$,
   5, 'facile', ARRAY['commissionnaire','module-4','question-redigee'], 'COMM-M4-QR-02', false,
   $mft$EXW déroulé en plan d'opérations complet.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Cas chiffré. Votre client importe de Busan un lot facturé 60 000 EUR. Postes de la chaîne : pré-acheminement et export Corée 900 EUR, fret maritime 2 400 EUR, assurance 300 EUR, dédouanement import et post-acheminement France 1 100 EUR. Comparez la répartition des frais entre vendeur et acheteur si la vente est conclue FOB Busan puis CIF Le Havre, et précisez qui supporte le risque pendant la traversée dans chaque cas.$mft$,
   $mft$Réponse modèle. Sous FOB Busan : le vendeur supporte le pré-acheminement, l'export coréen (900 EUR) et la mise à bord ; l'acheteur paie le fret maritime (2 400 EUR), l'assurance s'il veut se couvrir (300 EUR) et l'aval France (1 100 EUR), soit 3 800 EUR à sa charge en plus du prix. Sous CIF Le Havre : le vendeur ajoute à sa charge le fret (2 400 EUR) et l'assurance, obligatoire sous CIF (300 EUR) ; l'acheteur ne conserve que le dédouanement import et le post-acheminement (1 100 EUR) ; le prix facturé sera logiquement plus élevé, car le vendeur répercute ces coûts. Le risque pendant la traversée : dans les DEUX cas, il pèse sur l'acheteur dès l'embarquement à Busan ; c'est le point que le tableau des frais ne montre pas et que le commissionnaire doit rappeler. La différence est assurantielle : sous CIF, l'acheteur bénéficie de l'assurance souscrite par le vendeur ; sous FOB, il doit penser à s'assurer lui-même. Enfin, la valeur en douane sera ajustée différemment : en FOB, fret et assurance sont à réintégrer.$mft$,
   $mft$Barème /5 : répartition FOB exacte (1,5 pt) ; répartition CIF exacte avec assurance obligatoire du vendeur (1,5 pt) ; risque à l'acheteur dès l'embarquement dans les deux cas (1,5 pt) ; ouverture sur la valeur en douane ou l'assurance à prévoir sous FOB (0,5 pt). Erreurs fréquentes : croire que CIF fait porter le risque maritime au vendeur ; oublier que le prix CIF intègre les coûts ajoutés.$mft$,
   5, 'moyen', ARRAY['commissionnaire','module-4','question-redigee'], 'COMM-M4-QR-03', false,
   $mft$FOB contre CIF sur un cas chiffré : frais, risque, assurance.$mft$),

  (v_formation, v_module, v_l1, 'qr',
   $mft$Comparez CIF et CIP : mode de transport concerné, point de transfert du risque, obligation d'assurance. Puis expliquez pourquoi expédier des conteneurs en porte à porte sous CIF est une erreur de casting.$mft$,
   $mft$Réponse modèle. CIF appartient aux quatre règles exclusivement maritimes (FAS, FOB, CFR, CIF) : il suppose une marchandise mise à bord d'un navire, le risque étant transféré à l'embarquement au port de départ, le vendeur payant fret et assurance jusqu'au port d'arrivée. CIP est son équivalent multimodal : il fonctionne pour tout mode ou combinaison de modes, le risque étant transféré dès la remise au premier transporteur, le vendeur payant le transport et l'assurance jusqu'au lieu de destination convenu. Dans les deux cas, l'assurance du vendeur est OBLIGATOIRE, au bénéfice de l'acheteur ; les niveaux de couverture exigés par la version 2020 diffèrent toutefois entre les deux règles (clauses exactes à vérifier avant de conseiller un client). L'erreur de casting : un conteneur en porte à porte transite par des maillons routiers et des terminaux avant et après le navire ; sous CIF, le point de transfert du risque (l'embarquement) ne correspond plus à la réalité physique de la remise au transporteur, ce qui crée des zones grises en cas d'avarie survenue avant la mise à bord. Pour du conteneurisé porte à porte, la règle multimodale s'impose : CIP.$mft$,
   $mft$Barème /5 : CIF maritime pur avec transfert du risque à l'embarquement (1,5 pt) ; CIP multimodal avec transfert à la remise au premier transporteur (1,5 pt) ; assurance obligatoire dans les deux cas, prudence sur les niveaux de couverture (1 pt) ; démonstration de l'inadaptation de CIF au conteneur porte à porte (1 pt). Erreurs fréquentes : présenter CIP comme maritime ; situer le transfert du risque à l'arrivée.$mft$,
   5, 'moyen', ARRAY['commissionnaire','module-4','question-redigee'], 'COMM-M4-QR-04', false,
   $mft$CIF contre CIP : maritime pur contre multimodal, assurance comprise.$mft$),

  (v_formation, v_module, v_l2, 'qr',
   $mft$Analyse de sinistre. Sous CIF Fos-sur-Mer, le conteneur de votre client acheteur arrive avec 30 % de la marchandise détruite par l'eau de mer. Le client veut refuser de payer le vendeur et vous demande de « bloquer le dossier ». Analysez : qui supporte le risque, contre qui se retourner, avec quels documents, et quel est votre rôle exact de commissionnaire ?$mft$,
   $mft$Réponse modèle. Premier réflexe : requalifier la demande. Sous CIF, le risque a été transféré au client dès l'embarquement : le vendeur a rempli ses obligations en remettant une marchandise conforme à bord et en payant fret et assurance jusqu'au port d'arrivée ; refuser de payer la facture n'est donc pas la voie (sauf non-conformité au chargement, à vérifier via les documents d'embarquement). La voie normale : actionner l'assurance que le vendeur avait l'obligation de souscrire au bénéfice de l'acheteur. Dossier à constituer : réserves précises à la livraison (constat contradictoire, photos), documents de transport, certificat d'assurance, facture commerciale, expertise éventuelle. Un recours contre le transporteur maritime peut compléter le dispositif si sa responsabilité est engagée : les délais de réserves et d'action doivent être respectés (délais précis à vérifier selon le mode). Rôle du commissionnaire : sécuriser les réserves à temps, rassembler les pièces, notifier l'assureur et le transporteur, conseiller le client sur la voie réaliste (l'assurance d'abord). Pédagogie finale : si le client veut faire porter le risque maritime à son vendeur, il faut négocier un Incoterm de la famille D au prochain contrat.$mft$,
   $mft$Barème /5 : risque transféré à l'embarquement, refus de paiement non fondé sur ce motif (1,5 pt) ; voie assurantielle (assurance souscrite par le vendeur au bénéfice de l'acheteur) (1,5 pt) ; dossier documentaire complet avec réserves à temps (1 pt) ; rôle du commissionnaire et conseil pour l'avenir (famille D) (1 pt). Erreurs fréquentes : faire du vendeur le responsable du risque maritime ; négliger les réserves à la livraison.$mft$,
   5, 'moyen', ARRAY['commissionnaire','module-4','question-redigee'], 'COMM-M4-QR-05', false,
   $mft$Sinistre sous CIF : requalifier la demande du client et monter le bon recours.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Procédure. Un nouveau client n'a jamais importé : il achète des composants en Inde et vous confie l'opération de bout en bout. Décrivez la procédure douanière que vous mettez en place : identifiant, mandat de représentation, construction de la déclaration (les trois données clés) et traitement des droits et de la TVA.$mft$,
   $mft$Réponse modèle. Étape 1 : vérifier ou faire obtenir l'immatriculation EORI, sans laquelle aucune opération douanière n'est possible. Étape 2 : formaliser le mandat de représentation : notre société agit comme représentant en douane enregistré (RDE) ; le mode de représentation (directe ou indirecte) doit être précisé au mandat, car ses conséquences en matière de responsabilité diffèrent (nuances exactes à vérifier avant signature). Étape 3 : construire la déclaration sur ses trois piliers : l'espèce (classement des composants dans la nomenclature tarifaire, qui détermine le taux applicable), l'origine (préférentielle ou non selon les accords applicables avec l'Inde, à documenter par des preuves d'origine valides), la valeur en douane (valeur de transaction, ajustée du fret et de l'assurance selon l'Incoterm d'achat). Étape 4 : acquitter les droits de douane à la mise en libre pratique et porter la TVA à l'import en autoliquidation sur la déclaration de TVA française du client : pas d'avance de trésorerie. Étape 5 : archiver l'ensemble des justificatifs : en cas de contrôle a posteriori, la dette douanière se discute sur pièces, et le déclarant engage sa responsabilité.$mft$,
   $mft$Barème /5 : EORI préalable (0,75 pt) ; mandat RDE avec mode de représentation et prudence sur les conséquences (1 pt) ; les trois piliers espèce/origine/valeur correctement expliqués avec le lien Incoterm sur la valeur (2 pts) ; droits + TVA autoliquidée (0,75 pt) ; archivage et contrôle a posteriori (0,5 pt). Erreurs fréquentes : oublier l'EORI ; réduire la déclaration à la seule valeur facturée.$mft$,
   5, 'moyen', ARRAY['commissionnaire','module-4','question-redigee'], 'COMM-M4-QR-06', false,
   $mft$La première importation d'un client, déroulée en procédure complète.$mft$),

  (v_formation, v_module, v_l4, 'qr',
   $mft$Plan d'action client. Un industriel importe d'Asie une centaine de conteneurs par an de composants : 40 % sont réexpédiés hors de l'Union sans transformation, 30 % sont transformés avant revente, 30 % sont vendus en l'état dans l'Union. Aujourd'hui, il dédouane tout à l'arrivée. Proposez un schéma douanier optimisé, régime par régime, avec l'argument trésorerie pour chaque flux.$mft$,
   $mft$Réponse modèle. Constat : en dédouanant 100 % à l'arrivée, le client paie des droits sur des marchandises qui ne resteront pas dans l'Union : c'est le cas type où les régimes particuliers créent de la valeur. Schéma proposé. 1) Acheminement : transit T1 du port jusqu'au site, la marchandise circule sous douane sans acquitter les droits en chemin. 2) Stockage : entrepôt douanier sur site ou chez un logisticien agréé : les droits sont suspendus tant que la marchandise y demeure. 3) Flux réexpédié (40 %) : il ressort de l'entrepôt vers les pays tiers sans jamais supporter les droits de l'Union : économie sèche et définitive. 4) Flux transformé (30 %) : orienter vers le régime du perfectionnement (transformer sous régime douanier), le traitement final dépendant de la destination des produits finis (modalités à vérifier avec le bureau de douane). 5) Flux vendu en l'état dans l'Union (30 %) : mise en libre pratique au fil des sorties d'entrepôt, droits payés au plus près de la vente, TVA autoliquidée sur la déclaration de TVA : aucune avance. Gain global : les droits ne frappent que ce qui entre réellement sur le marché de l'Union, et au moment le plus tardif possible.$mft$,
   $mft$Barème /5 : diagnostic du dédouanement systématique inutile (0,5 pt) ; T1 pour l'acheminement (0,75 pt) ; entrepôt douanier et suspension des droits (1,25 pt) ; traitement correct des trois flux (réexpédition sans droits, perfectionnement avec prudence, libre pratique au fil de l'eau) (1,75 pt) ; argument trésorerie incluant la TVA autoliquidée (0,75 pt). Erreurs fréquentes : faire payer les droits sur la part réexpédiée ; confondre suspension et exonération définitive pour la part vendue dans l'Union.$mft$,
   5, 'difficile', ARRAY['commissionnaire','module-4','question-redigee'], 'COMM-M4-QR-07', false,
   $mft$Les régimes particuliers vendus en plan d'action trésorerie.$mft$),

  (v_formation, v_module, v_l3, 'qr',
   $mft$Analyse de responsabilité. Votre société, RDE, a déclaré pendant dix-huit mois des importations sous origine préférentielle sur la foi de certificats fournis par le client. Un contrôle a posteriori invalide ces preuves d'origine : la douane notifie un rappel de droits. Le client refuse de payer et affirme que « c'est le déclarant qui a signé ». Analysez : naissance de la dette, positions respectives, incidence du mode de représentation, et plan de prévention pour l'avenir.$mft$,
   $mft$Réponse modèle. La dette douanière naît du contrôle a posteriori : l'origine préférentielle déclarée étant invalidée, les droits éludés deviennent exigibles. Positions : le client, opérateur et bénéficiaire des importations, est au cœur de la dette ; mais le déclarant n'est pas un simple exécutant : il engage sa responsabilité sur les déclarations qu'il signe, et le mode de représentation choisi au mandat (directe ou indirecte) modifie l'exposition du RDE (les nuances exactes de cette répartition sont à vérifier au cas par cas avec un conseil). L'argument « c'est le déclarant qui a signé » se retourne d'ailleurs contre le client : le mandat et les échanges écrits montreront qui a fourni les certificats et qui devait en garantir la validité. Plan de prévention : 1) mandats précisant explicitement le mode de représentation et la responsabilité documentaire du client sur les preuves d'origine ; 2) contrôle de cohérence systématique des certificats avant déclaration (émetteur, période, marchandises couvertes) ; 3) clause contractuelle de garantie et de recours contre le client en cas de rappel imputable à ses documents ; 4) archivage horodaté de toutes les pièces. Leçon : le RDE vend de la rigueur documentaire, et c'est elle qui le protège.$mft$,
   $mft$Barème /5 : mécanisme de la dette née du contrôle a posteriori (1 pt) ; responsabilité du déclarant analysée sans absoudre le client (1,25 pt) ; incidence du mode de représentation avec prudence sur les nuances (1 pt) ; plan de prévention concret (mandat, contrôle des certificats, clause de recours, archivage) (1,75 pt). Erreurs fréquentes : affirmer que le RDE ne risque rien ; oublier la valeur probatoire du mandat et des échanges écrits.$mft$,
   5, 'difficile', ARRAY['commissionnaire','module-4','question-redigee'], 'COMM-M4-QR-08', false,
   $mft$Origine invalidée en contrôle a posteriori : la responsabilité du RDE disséquée.$mft$);

  RAISE NOTICE 'Module 4 Commissionnaire créé : module %, 4 leçons, 1 quiz, 12 QCM + 10 QC + 8 QR (tous inactifs, à valider).', v_module;
END $commm4$;
