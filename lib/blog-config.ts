// =====================================================================
// Hub éditorial / guides — MA FORMATION TRANSPORT
//
// Source unique des articles de blog (SEO informationnel, top-of-funnel).
// Consommée par /blog (index) et /blog/[slug] (article).
//
// Objectif SEO : capter les requêtes informationnelles que la vitrine
// transactionnelle ne touche pas ("comment obtenir la capacité de
// transport", "financer une formation FIMO"…), et mailler ces articles
// vers les fiches formation + la page financements.
//
// Le corps (`body`) est du markdown rendu par lib/markdown.ts.
// =====================================================================

export interface Article {
  /** slug URL — stable, en minuscules-tirets. */
  slug: string;
  /** Titre H1 de l'article (peut différer du seoTitle). */
  title: string;
  /** Titre SEO (<title>, ≤ 60 car, mot-clé en tête). */
  seoTitle: string;
  /** Meta description (150-160 car). */
  seoDescription: string;
  /** Chapeau affiché sous le titre + résumé pour la carte d'index. */
  excerpt: string;
  /** Catégorie éditoriale (badge + filtrage). */
  category:
    | "Capacité de transport"
    | "Titres professionnels"
    | "Conducteurs (FIMO/FCO)"
    | "Taxi / VTC"
    | "Financement";
  /** Date de publication (ISO, pour <time> + JSON-LD datePublished). */
  publishedAt: string;
  /** Date de dernière mise à jour (ISO). */
  updatedAt: string;
  /** Temps de lecture estimé (minutes). */
  readingMinutes: number;
  /** Slugs de formations liées (maillage interne vers les fiches). */
  relatedFormations: string[];
  /** Corps de l'article en markdown. */
  body: string;
}

export const ARTICLES: Article[] = [
  // ───────────────────────────────────────────────────────────────────
  {
    slug: "obtenir-capacite-transport-marchandises",
    title:
      "Comment obtenir la capacité de transport de marchandises ? (guide 2026)",
    seoTitle: "Obtenir la capacité de transport de marchandises",
    seoDescription:
      "Guide complet 2026 pour obtenir l'attestation de capacité de transport de marchandises : conditions, examen, équivalences, formation et démarches. Centre à Meaux.",
    excerpt:
      "Attestation de capacité, examen national, équivalences par diplôme ou expérience, formation : le parcours complet pour piloter légalement une entreprise de transport de marchandises.",
    category: "Capacité de transport",
    publishedAt: "2026-07-11",
    updatedAt: "2026-07-11",
    readingMinutes: 8,
    relatedFormations: ["capacite-3-5t", "capacite-plus-3-5t", "gotrm"],
    body: `## Qu'est-ce que la capacité de transport de marchandises ?

L'attestation de capacité professionnelle en transport routier de marchandises est le sésame **obligatoire** pour diriger une entreprise de transport public de marchandises. Sans elle, impossible de s'inscrire au registre des transporteurs tenu par la DREAL et donc d'exercer légalement.

Elle atteste que le dirigeant (ou le gestionnaire de transport désigné) possède les connaissances nécessaires en gestion, en réglementation sociale, en droit et en sécurité pour exploiter une flotte en conformité.

## Deux capacités selon le tonnage des véhicules

Il existe **deux attestations distinctes**, selon le poids des véhicules utilisés :

- **Capacité de transport léger (≤ 3,5 t de PMA)** : pour exploiter des véhicules légers (utilitaires, VUL). L'accès se fait par une **formation obligatoire de 105 heures** suivie d'un examen. C'est la voie privilégiée des livreurs, coursiers et transporteurs du dernier kilomètre.
- **Capacité de transport lourd (> 3,5 t)** : pour exploiter des poids lourds. Elle s'obtient principalement par **l'examen national écrit** organisé chaque année, ou par équivalence (voir plus bas).

> Le choix entre les deux dépend uniquement du **type de véhicules** que vous comptez exploiter, pas de votre projet commercial. Beaucoup de créateurs démarrent en léger puis basculent en lourd.

## Les trois voies d'obtention

### 1. Par l'examen

L'examen national de capacité de transport lourd a lieu **une fois par an** (généralement en octobre). Il s'agit d'une épreuve écrite de 4 heures : un questionnaire à choix multiples et des questions rédactionnelles, plus une étude de cas. La réussite exige une **préparation sérieuse** aux matières juridiques, sociales, commerciales et techniques.

Pour le transport léger (≤ 3,5 t), il n'y a **pas d'examen national** : l'attestation est délivrée à l'issue de la **formation de 105 heures** dispensée par un centre agréé, sous réserve de réussite au test final.

### 2. Par équivalence de diplôme

Certains diplômes dispensent totalement de l'examen. C'est le cas notamment des diplômes de niveau bac+2 et plus en transport et logistique, ou du **titre professionnel GOTRM (RNCP 40990)**, qui ouvre l'accès à la capacité de transport de marchandises par équivalence.

### 3. Par équivalence d'expérience

Si vous avez **dirigé de manière continue une entreprise de transport** dans les dix années précédentes, vous pouvez demander la capacité au titre de l'expérience, sans repasser l'examen. Un dossier justificatif est à constituer auprès de la DREAL.

## Le parcours étape par étape

:::timeline
Choisir la bonne capacité — Déterminez selon vos véhicules : légère (≤ 3,5 t) ou lourde (> 3,5 t).
Se former — 105 h obligatoires pour le léger ; préparation à l'examen national pour le lourd.
Passer l'épreuve — Test final de formation (léger) ou examen national annuel (lourd).
Obtenir l'attestation — Délivrée par la DREAL de votre région après réussite.
S'inscrire au registre — Inscription au registre des transporteurs pour exercer légalement.
:::

## Quels justificatifs préparer ?

Pour l'inscription au registre après obtention, prévoyez généralement :

- une pièce d'identité en cours de validité ;
- l'attestation de capacité professionnelle ;
- les justificatifs de **capacité financière** (montant minimal par véhicule exigé) ;
- l'extrait Kbis de l'entreprise ;
- un justificatif d'établissement (siège).

## Combien de temps et combien ça coûte ?

La formation **légère de 105 heures** se déroule en général sur environ 3 semaines. La **préparation à l'examen lourd** s'étale sur 8 à 12 semaines selon le rythme. Le coût varie selon la formule, mais la bonne nouvelle est que ces formations sont **éligibles à plusieurs financements** : CPF, France Travail, OPCO. Vous n'avez donc souvent que peu, voire rien, à payer de votre poche.

## Se faire accompagner

Passer la capacité seul est possible, mais le taux de réussite grimpe nettement avec une préparation encadrée : cours structurés, examens blancs en conditions réelles et suivi personnalisé. Notre centre à Meaux prépare aux deux capacités, avec des formats adaptés aux demandeurs d'emploi comme aux salariés en reconversion.

Pour aller plus loin, découvrez nos formations : la **capacité de transport léger (≤ 3,5 t)**, la **capacité de transport (> 3,5 t)**, ou le **titre professionnel GOTRM** qui ouvre la capacité par équivalence tout en formant au métier de gestionnaire d'exploitation.`,
  },

  // ───────────────────────────────────────────────────────────────────
  {
    slug: "financer-formation-transport-cpf-france-travail-opco",
    title:
      "Financer sa formation transport : CPF, France Travail, OPCO (guide 2026)",
    seoTitle: "Financer sa formation transport : CPF, OPCO, aides",
    seoDescription:
      "Tous les dispositifs pour financer votre formation transport en 2026 : CPF, France Travail (AIF), OPCO, employeur, Transitions Pro. Montage de dossier expliqué.",
    excerpt:
      "CPF, France Travail, OPCO, plan de développement des compétences, Transitions Pro : le guide clair pour financer votre formation transport sans reste à charge, ou presque.",
    category: "Financement",
    publishedAt: "2026-07-11",
    updatedAt: "2026-07-11",
    readingMinutes: 7,
    relatedFormations: ["gotrm", "fimo-fco", "taxi-vtc", "capacite-3-5t"],
    body: `## Bonne nouvelle : vous n'avez probablement pas à tout payer

La quasi-totalité de nos formations transport sont **éligibles à un ou plusieurs dispositifs de financement**. Selon votre situation (demandeur d'emploi, salarié, en reconversion, chef d'entreprise), le reste à charge peut être **nul ou fortement réduit**. Encore faut-il activer le bon dispositif. Ce guide fait le tri.

## 1. Le CPF (Compte Personnel de Formation)

Le CPF est le dispositif le plus connu. Chaque année travaillée crédite votre compte en euros, mobilisables directement depuis la plateforme **Mon Compte Formation** pour financer une formation certifiante.

- **Pour qui ?** Tout actif (salarié ou demandeur d'emploi) disposant de droits.
- **Comment ?** Vous sélectionnez la formation sur Mon Compte Formation et validez avec vos droits. Si le solde ne couvre pas tout, un **abondement** (France Travail, employeur, région) peut compléter.
- **Avantage :** aucune avance de frais, démarche autonome.

## 2. France Travail — l'AIF

Si vous êtes **demandeur d'emploi**, France Travail peut financer votre formation via l'**Aide Individuelle à la Formation (AIF)**, sur étude de votre projet de retour à l'emploi.

- **Pour qui ?** Demandeurs d'emploi inscrits, avec un projet cohérent.
- **Comment ?** Votre conseiller valide un devis établi par le centre. L'AIF peut se combiner avec vos droits CPF pour couvrir l'intégralité.
- **Avantage :** peut financer 100 % du coût quand le projet est validé.

## 3. L'OPCO (pour les salariés et les employeurs)

Les **OPCO** (opérateurs de compétences, comme OPCO Mobilités pour le transport) financent la formation des salariés dans le cadre du **plan de développement des compétences** de l'entreprise.

- **Pour qui ?** Salariés, à l'initiative de l'employeur.
- **Comment ?** L'entreprise monte le dossier avec son OPCO ; le centre facture directement l'OPCO après accord de prise en charge.
- **Cas typique :** un employeur qui forme ses conducteurs à la **FIMO / FCO** obligatoire.

## 4. Le plan de développement des compétences

L'employeur peut aussi financer **directement** une formation, hors OPCO, dans le cadre de son plan interne. C'est fréquent pour les formations réglementaires courtes ou urgentes.

## 5. Transitions Pro (reconversion)

Pour un salarié qui souhaite **changer de métier**, le dispositif **Projet de Transition Professionnelle** (ex-CIF), géré par Transitions Pro, peut financer une formation longue et certifiante tout en maintenant une rémunération.

- **Pour qui ?** Salariés en reconversion, sous conditions d'ancienneté.
- **Cas typique :** une reconversion vers le **titre GOTRM** ou l'**enseignement de la conduite (ECSR)**.

## Quel dispositif pour quelle situation ?

:::flow
Demandeur d'emploi → CPF + AIF France Travail → Reste à charge souvent nul
Salarié (même métier) → OPCO / plan employeur → Financement par l'entreprise
Salarié en reconversion → Transitions Pro (+ CPF) → Formation longue financée
Chef d'entreprise → OPCO / auto-financement → Selon statut et OPCO
:::

## Comment monter votre dossier ?

Le montage administratif décourage souvent les candidats. C'est justement là que notre équipe intervient : nous établissons le **devis**, la **convention de formation**, et nous vous guidons dans les démarches auprès de votre financeur (CPF, France Travail, OPCO). Vous n'êtes jamais seul face à la paperasse.

## En résumé

Il existe presque toujours une solution pour financer votre formation transport. Le bon réflexe : **nous contacter avec votre situation** (statut, projet, formation visée). Nous identifions ensemble le dispositif le plus avantageux et nous préparons le dossier.

Pour découvrir les financements applicables à chaque cursus, consultez notre page dédiée aux **financements**, ou demandez un **devis personnalisé** — réponse sous 24 h ouvrées.`,
  },

  // ───────────────────────────────────────────────────────────────────
  {
    slug: "fimo-fco-differences-obligations-recyclage",
    title:
      "FIMO ou FCO : différences, obligations et délais de recyclage",
    seoTitle: "FIMO ou FCO : différences et obligations",
    seoDescription:
      "FIMO ou FCO : quelle formation pour les conducteurs poids lourds ? Différences, durées (140 h / 35 h), délais de recyclage tous les 5 ans et financement. Centre à Meaux.",
    excerpt:
      "FIMO à l'entrée dans le métier, FCO tous les 5 ans : comprendre ces deux formations obligatoires des conducteurs professionnels, leurs durées et leurs échéances.",
    category: "Conducteurs (FIMO/FCO)",
    publishedAt: "2026-07-10",
    updatedAt: "2026-07-10",
    readingMinutes: 6,
    relatedFormations: ["fimo-fco", "gotrm"],
    body: `## FIMO et FCO : deux formations, un même objectif

La FIMO (Formation Initiale Minimale Obligatoire) et la FCO (Formation Continue Obligatoire) encadrent l'ensemble de la carrière d'un **conducteur routier professionnel**. Elles répondent à une exigence européenne : garantir que tout conducteur de poids lourd maîtrise en permanence la sécurité, la réglementation sociale et l'éco-conduite.

La différence tient à **quand** elles interviennent :

- **FIMO** : à l'**entrée** dans le métier, avant de conduire professionnellement.
- **FCO** : en **continu**, tous les 5 ans, pour maintenir la qualification.

## La FIMO : le passeport d'entrée

La FIMO marchandises dure **140 heures** (environ 4 semaines). Elle est obligatoire pour tout conducteur souhaitant exercer le transport de marchandises avec un véhicule de plus de 3,5 tonnes, sauf s'il détient déjà un titre équivalent.

Au programme : perfectionnement à la conduite rationnelle axée sécurité, application des réglementations, santé et sécurité routière, service et logistique. À l'issue, le conducteur obtient sa **carte de qualification de conducteur (CQC)**.

## La FCO : le maintien de la qualification

La FCO dure **35 heures** (5 jours) et doit être suivie **tous les 5 ans**. Elle actualise les connaissances : évolutions réglementaires, rappels de sécurité, éco-conduite, prévention des risques.

> Point de vigilance : la FCO doit être réalisée **avant l'échéance** des 5 ans. Un conducteur dont la FCO a expiré ne peut plus conduire professionnellement tant qu'il ne l'a pas repassée. Anticipez la date pour éviter toute interruption d'activité.

## FIMO ou FCO : comment savoir laquelle passer ?

:::flow
Nouveau conducteur → FIMO (140 h) → Carte de qualification (CQC)
Conducteur déjà qualifié → FCO (35 h) tous les 5 ans → Renouvellement de la CQC
CQC expirée → FCO de mise à jour → Reprise de l'activité
:::

## Qui finance la FIMO / FCO ?

Ces formations relèvent le plus souvent de l'**employeur**, via son **OPCO** (OPCO Mobilités pour le transport) dans le cadre du plan de développement des compétences. Un demandeur d'emploi peut mobiliser **France Travail**. Notre équipe monte le dossier de prise en charge avec vous ou votre entreprise.

## En résumé

FIMO pour démarrer, FCO pour continuer. Ces deux formations rythment toute la carrière du conducteur professionnel et conditionnent le droit d'exercer. Pour préparer votre FIMO ou votre FCO à Meaux, découvrez notre **formation FIMO & FCO**, ou demandez un **devis** adapté à votre situation.`,
  },

  // ───────────────────────────────────────────────────────────────────
  {
    slug: "titre-gotrm-rncp-40990-programme-debouches-salaire",
    title:
      "Titre pro GOTRM (RNCP 40990) : programme, débouchés et salaire",
    seoTitle: "Titre GOTRM (RNCP 40990) : programme et débouchés",
    seoDescription:
      "Tout sur le titre professionnel GOTRM (RNCP 40990, niveau 5) : 3 blocs de compétences, débouchés (exploitant, affréteur), salaire et accès à la capacité de transport.",
    excerpt:
      "Le titre GOTRM forme les gestionnaires d'exploitation transport. Blocs de compétences, métiers visés, rémunération et passerelle vers la capacité de transport.",
    category: "Titres professionnels",
    publishedAt: "2026-07-09",
    updatedAt: "2026-07-09",
    readingMinutes: 7,
    relatedFormations: ["gotrm", "capacite-plus-3-5t"],
    body: `## Le titre GOTRM en bref

Le titre professionnel **Gestionnaire des Opérations de Transport Routier de Marchandises** (GOTRM) est une certification de **niveau 5** (équivalent bac+2) enregistrée au RNCP sous le numéro **40990** et délivrée par le Ministère du Travail. Il forme les futurs **cadres de l'exploitation transport** : ceux qui organisent, pilotent et optimisent l'acheminement des marchandises.

## Les 3 blocs de compétences officiels

La certification est structurée en trois blocs de compétences (chacun validable indépendamment) :

- **Bloc 1 (BC01)** — Concevoir, organiser, mettre en œuvre et piloter des prestations de transport routier de marchandises jusqu'à la clôture des dossiers.
- **Bloc 2 (BC02)** — Piloter les trafics réguliers réalisés sous contrat de sous-traitance.
- **Bloc 3 (BC03)** — Optimiser l'ensemble des moyens liés à l'activité de transport.

Ces intitulés correspondent exactement au référentiel publié par France Compétences : c'est important pour la reconnaissance de la certification par les financeurs et les employeurs.

## Les épreuves

L'examen final se déroule devant un **jury professionnel** : une mise en situation professionnelle de 10 heures (en deux parties), un entretien technique d'1 heure, un questionnement à partir de productions (30 min) et un entretien final (30 min), soit **12 heures d'épreuves** au total. Une **période en entreprise d'au moins 280 heures** est exigée pour se présenter.

## Les débouchés

Le titre GOTRM ouvre sur des postes recherchés dans un secteur en tension :

- **Responsable ou gestionnaire d'exploitation** transport
- **Affréteur**, **dispatcher**, **chef de quai**
- **Responsable de site logistique**

Il donne aussi accès, **par équivalence**, à la **capacité de transport de marchandises** — un atout décisif pour ceux qui visent la création d'entreprise.

## Quel salaire ?

La rémunération varie selon l'expérience, la région et la taille de l'entreprise. Un gestionnaire d'exploitation débutant se situe généralement dans une fourchette d'entrée de cadre intermédiaire du transport, avec une progression rapide vers des responsabilités élargies (multi-sites, management d'équipe). Le secteur, structurellement en manque de profils qualifiés, offre de réelles perspectives d'évolution.

> Les chiffres précis de rémunération dépendent de trop de facteurs pour être garantis ici : renseignez-vous sur les conventions collectives du transport et les offres locales pour une estimation fiable.

## Pour qui ?

Le titre s'adresse aux demandeurs d'emploi, aux salariés en évolution et aux chefs d'entreprise du secteur. Prérequis : niveau bac ou expérience significative en transport / logistique.

## En savoir plus

Le GOTRM est notre formation phare. Pour le programme détaillé, les modalités et le financement, consultez la **fiche formation GOTRM**. Si votre objectif est de créer votre entreprise, regardez aussi la **capacité de transport (> 3,5 t)**.`,
  },

  // ───────────────────────────────────────────────────────────────────
  {
    slug: "devenir-chauffeur-taxi-vtc-examen-carte-pro",
    title:
      "Devenir chauffeur Taxi ou VTC : examen, carte pro et réglementation",
    seoTitle: "Devenir chauffeur Taxi ou VTC : le guide",
    seoDescription:
      "Devenir chauffeur Taxi ou VTC en 2026 : différences des deux statuts, examen, carte professionnelle, prérequis et formation. Préparez votre examen à Meaux.",
    excerpt:
      "Taxi ou VTC ? Deux statuts, deux examens, deux marchés. Le guide clair pour choisir, réussir l'examen et obtenir votre carte professionnelle de chauffeur.",
    category: "Taxi / VTC",
    publishedAt: "2026-07-08",
    updatedAt: "2026-07-08",
    readingMinutes: 6,
    relatedFormations: ["taxi-vtc"],
    body: `## Taxi ou VTC : deux métiers proches, deux statuts distincts

Taxi et VTC (Voiture de Transport avec Chauffeur) transportent tous deux des personnes contre rémunération, mais relèvent de **cadres réglementaires différents**. Choisir entre les deux est la première décision à prendre, car l'examen et les démarches ne sont pas les mêmes.

- **Taxi** : peut être hélé dans la rue et stationner sur la voie publique, dispose d'un **compteur horokilométrique** et d'une **autorisation de stationnement** (l'« ADS », souvent appelée « licence »). Marché encadré localement.
- **VTC** : uniquement sur **réservation préalable**, pas de maraude ni de stationnement en attente de clientèle. Accès plus souple, forte présence des plateformes.

## L'examen

Dans les deux cas, l'accès à la profession passe par un **examen** comprenant :

- une **épreuve d'admissibilité** (théorique) : réglementation du transport de personnes, sécurité routière, gestion, français, et pour le taxi une partie sur la réglementation locale ;
- une **épreuve d'admission** (pratique) : conduite et mise en situation de la relation client.

La réussite de l'examen conditionne la délivrance de la **carte professionnelle**.

## Les prérequis

Pour se présenter, il faut généralement :

- être **titulaire du permis B** depuis une durée minimale et hors période probatoire ;
- disposer d'un **casier judiciaire** compatible avec la profession ;
- fournir une **attestation d'aptitude médicale** délivrée par un médecin agréé ;
- être titulaire d'une attestation de **formation aux premiers secours** (PSC1) en cours de validité.

## De la formation à la carte pro

:::timeline
Choisir son statut — Taxi (maraude, ADS) ou VTC (réservation, plateformes).
Se former — Préparation aux épreuves théoriques et pratiques (150 à 250 h selon la formule).
Passer l'examen — Admissibilité (théorie) puis admission (conduite + relation client).
Obtenir la carte pro — Délivrance après réussite et dossier complet.
Démarrer l'activité — Immatriculation (registre VTC) ou obtention d'une ADS (taxi).
:::

## Combien de temps et quel financement ?

La préparation s'étale sur **150 à 250 heures** selon la formule et le statut visé. Ces formations sont **éligibles au CPF**, à l'**OPCO** et à **France Travail** pour les demandeurs d'emploi. Un devis personnalisé permet d'identifier la meilleure prise en charge.

## En résumé

Taxi pour la maraude et un marché local encadré, VTC pour la réservation et la souplesse : à vous de choisir selon votre projet. Dans les deux cas, la réussite à l'examen passe par une préparation solide. Découvrez notre **formation Taxi & VTC** ou demandez un **devis** adapté.`,
  },

  // ───────────────────────────────────────────────────────────────────
  {
    slug: "capacite-transport-leger-vs-lourd-quelle-formation",
    title:
      "Capacité de transport léger (≤ 3,5 t) ou lourd (> 3,5 t) : quelle formation choisir ?",
    seoTitle: "Capacité transport léger ou lourd : que choisir",
    seoDescription:
      "Capacité de transport léger (≤ 3,5 t) ou lourde (> 3,5 t) : différences, formation (105 h vs examen national), coût et démarches pour créer votre entreprise de transport.",
    excerpt:
      "Le choix entre capacité légère et lourde dépend uniquement de vos véhicules. Comparatif clair pour créer votre entreprise de transport avec la bonne attestation.",
    category: "Capacité de transport",
    publishedAt: "2026-07-07",
    updatedAt: "2026-07-07",
    readingMinutes: 6,
    relatedFormations: ["capacite-3-5t", "capacite-plus-3-5t"],
    body: `## Une seule question : quels véhicules allez-vous exploiter ?

Le choix entre la capacité de transport **légère** et **lourde** ne dépend ni de votre statut, ni de votre projet commercial : il dépend **uniquement du poids des véhicules** que vous comptez utiliser.

- **Capacité légère** : véhicules dont le poids maximum autorisé (PMA) est **inférieur ou égal à 3,5 tonnes** (utilitaires, VUL).
- **Capacité lourde** : véhicules de **plus de 3,5 tonnes** (poids lourds).

## Comparatif des deux voies

| Critère | Léger (≤ 3,5 t) | Lourd (> 3,5 t) |
|---|---|---|
| Véhicules | Utilitaires, VUL | Poids lourds |
| Accès | Formation obligatoire | Examen national (ou équivalence) |
| Durée | 105 heures | Préparation 8 à 12 semaines |
| Examen | Test final de formation | Épreuve nationale annuelle |
| Profil type | Livraison dernier kilomètre | Transport longue distance, lots |

## La capacité légère (≤ 3,5 t)

C'est la voie la plus accessible. Elle s'obtient par une **formation obligatoire de 105 heures** (environ 3 semaines) dispensée par un centre agréé, sanctionnée par un test. Pas d'examen national à date fixe : dès la formation réussie, vous pouvez demander votre attestation.

C'est le choix privilégié des créateurs qui démarrent en **messagerie, coursier, livraison du dernier kilomètre** — un secteur porté par l'essor du e-commerce.

## La capacité lourde (> 3,5 t)

Elle donne accès à l'exploitation de **poids lourds** et vise le transport de lots, la longue distance, la logistique industrielle. L'accès principal est l'**examen national écrit**, organisé une fois par an, qui demande une **préparation rigoureuse**. Des **équivalences** de diplôme (dont le titre GOTRM) ou d'expérience existent.

> Bon à savoir : démarrer en léger n'enferme pas. Beaucoup d'entrepreneurs commencent avec la capacité légère, puis passent la capacité lourde une fois leur activité lancée.

## Quel financement ?

Les deux formations sont **éligibles au CPF** et à **France Travail** pour les demandeurs d'emploi ; la capacité lourde ouvre en plus l'**OPCO** et le financement employeur. Un devis personnalisé précise votre prise en charge.

## En résumé

Regardez d'abord vos véhicules : ≤ 3,5 t → capacité légère (formation de 105 h) ; > 3,5 t → capacité lourde (examen national). Pour approfondir, consultez nos fiches **capacité ≤ 3,5 t** et **capacité > 3,5 t**, ou lisez notre guide complet sur l'obtention de la capacité de transport.`,
  },

  // ───────────────────────────────────────────────────────────────────
  {
    slug: "commissionnaire-de-transport-role-examen-difference",
    title:
      "Commissionnaire de transport : rôle, examen et différence avec le transporteur",
    seoTitle: "Commissionnaire de transport : rôle et examen",
    seoDescription:
      "Commissionnaire de transport : définition, rôle d'organisateur, différence avec le transporteur, examen national et attestation de capacité. Préparez-vous à Meaux.",
    excerpt:
      "Le commissionnaire organise le transport sans forcément posséder de camions. Rôle, responsabilité, examen et différence clé avec le transporteur, expliqués simplement.",
    category: "Titres professionnels",
    publishedAt: "2026-07-06",
    updatedAt: "2026-07-06",
    readingMinutes: 5,
    relatedFormations: ["commissionnaire", "gotrm"],
    body: `## Qu'est-ce qu'un commissionnaire de transport ?

Le **commissionnaire de transport** est un **organisateur** : il se charge, en son nom propre et sous sa responsabilité, de faire acheminer des marchandises pour le compte d'un client, en choisissant librement les moyens et les sous-traitants (transporteurs). Il ne possède pas nécessairement de véhicules : son métier, c'est l'**ingénierie et la coordination** du transport.

## La différence clé avec le transporteur

C'est la distinction la plus importante à comprendre :

- Le **transporteur** exécute matériellement le déplacement (il possède ou conduit les véhicules) et répond d'une obligation de moyens sur le trajet.
- Le **commissionnaire** organise et **garantit le résultat** : il est responsable de la bonne fin de l'opération, y compris des fautes de ses sous-traitants. Sa responsabilité est donc **plus étendue**.

> En pratique : le transporteur roule, le commissionnaire orchestre. Un commissionnaire peut faire appel à plusieurs transporteurs pour un même flux.

## L'attestation de capacité de commissionnaire

Comme pour le transport, exercer en tant que commissionnaire exige une **attestation de capacité professionnelle** spécifique, obtenue via un **examen national** (ou par équivalence de diplôme / expérience). Elle atteste la maîtrise du droit des contrats de transport, de la réglementation, de la gestion et des responsabilités propres à ce rôle d'organisateur.

## Pourquoi se former ?

L'examen couvre des matières exigeantes (droit du transport national et international, douane, assurances, gestion). Une **préparation intensive** structurée maximise les chances de réussite. Notre centre propose un cursus de **8 semaines intensives** dédié.

## Pour qui ?

Le métier attire les profils qui aiment **piloter des flux et négocier**, sans vouloir gérer une flotte : anciens exploitants, affréteurs, entrepreneurs de la logistique. Le titre **GOTRM** constitue une excellente base pour évoluer vers ce rôle.

## En savoir plus

Pour préparer l'examen national de commissionnaire, découvrez notre **formation Commissionnaire de transport**, ou le titre **GOTRM** si vous visez d'abord l'exploitation. Un **devis personnalisé** précise le financement possible (CPF, OPCO, Transitions Pro).`,
  },

  // ───────────────────────────────────────────────────────────────────
  {
    slug: "devenir-moniteur-auto-ecole-titre-ecsr",
    title: "Devenir moniteur d'auto-école : le titre ECSR expliqué",
    seoTitle: "Devenir moniteur d'auto-école : le titre ECSR",
    seoDescription:
      "Devenir moniteur d'auto-école avec le titre ECSR (niveau 5) : rôle, programme, durée, prérequis et débouchés. Formation d'enseignant de la conduite à Meaux.",
    excerpt:
      "Le titre ECSR forme les enseignants de la conduite et de la sécurité routière. Métier, programme, prérequis et débouchés pour devenir moniteur d'auto-école agréé.",
    category: "Titres professionnels",
    publishedAt: "2026-07-05",
    updatedAt: "2026-07-05",
    readingMinutes: 5,
    relatedFormations: ["ecsr"],
    body: `## Le métier d'enseignant de la conduite

L'**enseignant de la conduite et de la sécurité routière** (ECSR) — communément appelé « moniteur d'auto-école » — forme les futurs conducteurs et les prépare aux examens du permis. Son rôle dépasse la simple conduite : il transmet une **culture de la sécurité routière**, adapte sa pédagogie à chaque élève et évalue la progression.

## Le titre ECSR

Devenir moniteur exige le **titre professionnel ECSR**, une certification de **niveau 5** (équivalent bac+2). Il remplace l'ancien BEPECASER et constitue la voie officielle vers l'exercice du métier et l'obtention de l'**autorisation d'enseigner**.

## Au programme

La formation combine des compétences pédagogiques et techniques :

- psychopédagogie et méthodes d'apprentissage de la conduite ;
- réglementation, sécurité routière et évaluation des élèves ;
- animation de séances théoriques (code) et pratiques (conduite) ;
- mises en situation professionnelles évaluées.

L'obtention passe par un **contrôle continu** et des **épreuves de certification** du titre.

## Durée et prérequis

Le cursus s'étale sur **8 à 12 mois** selon le rythme et le parcours. Prérequis usuels : être titulaire du **permis B** depuis une durée minimale, disposer d'un casier judiciaire compatible avec l'enseignement, et satisfaire aux conditions d'aptitude.

## Les débouchés

- **Enseignant de la conduite** en auto-école (salarié ou indépendant)
- Évolution vers **responsable pédagogique** d'établissement
- À terme, **direction ou création d'une auto-école** (qualifications complémentaires requises)

Le métier bénéficie d'une **demande soutenue** : les auto-écoles recrutent régulièrement des moniteurs diplômés.

## Quel financement ?

Le titre ECSR est **éligible au CPF**, à **France Travail** et à **Transitions Pro** pour les reconversions. Une prise en charge partielle ou totale est souvent possible.

## En savoir plus

Pour devenir moniteur d'auto-école, découvrez notre **formation ECSR** — programme, modalités et financement détaillés. Vous pouvez aussi demander un **devis personnalisé** pour évaluer votre prise en charge.`,
  },

  // ───────────────────────────────────────────────────────────────────
  {
    slug: "ertv-exploiter-transport-de-voyageurs",
    title: "ERTV : exploiter une activité de transport de voyageurs",
    seoTitle: "ERTV : exploitant transport de voyageurs",
    seoDescription:
      "Le titre ERTV (niveau 4) forme les exploitants en régulation du transport de voyageurs : rôle, programme, débouchés et passerelle vers le GOTRM. Formation à Meaux.",
    excerpt:
      "Régulation, planification des conducteurs, gestion des incidents : le titre ERTV forme les exploitants du transport de voyageurs. Rôle, programme et débouchés.",
    category: "Titres professionnels",
    publishedAt: "2026-07-04",
    updatedAt: "2026-07-04",
    readingMinutes: 5,
    relatedFormations: ["ertv", "gotrm"],
    body: `## Le métier d'exploitant transport de voyageurs

L'**exploitant en régulation du transport de voyageurs** (ERTV) est le chef d'orchestre des opérations dans le transport de personnes : autocar, transport urbain, interurbain. Il **planifie les services**, affecte les conducteurs, **régule en temps réel** et gère les aléas (retards, incidents, remplacements) pour garantir la continuité du service.

## Le titre ERTV

Le titre professionnel ERTV est une certification de **niveau 4** (équivalent bac). Il valide les compétences nécessaires pour exploiter une activité de transport de voyageurs dans le respect de la **réglementation sociale spécifique** au secteur (temps de conduite TRV, obligations de bord).

## Au programme

- réglementation du transport de voyageurs (règlement européen, temps de conduite TRV) ;
- **régulation et exploitation** : outils SAE/SIV, planification des graphicages ;
- **gestion des incidents** en temps réel ;
- relation client et **management** d'une équipe de conducteurs.

L'évaluation combine contrôle continu, examens blancs et épreuves de certification devant jury.

## Les débouchés

- **Régulateur** ou **agent d'exploitation** transport de voyageurs
- **Responsable de ligne, de dépôt ou d'exploitation**
- Passerelle vers le titre **GOTRM** (marchandises) ou une licence transport

Le secteur (réseaux urbains, autocaristes, transport scolaire et interurbain) recrute régulièrement des profils capables de tenir la régulation.

## Durée, prérequis et financement

La formation dure **12 semaines**. Prérequis : niveau CAP/BEP ou expérience dans le transport ; le permis D est apprécié mais non obligatoire. Le titre est **éligible au CPF**, à l'**OPCO**, à l'**employeur** et à **France Travail**.

## En savoir plus

Pour devenir exploitant transport de voyageurs, découvrez notre **formation ERTV**. Si vous hésitez avec le transport de marchandises, comparez avec le titre **GOTRM**. Demandez un **devis** pour connaître votre financement.`,
  },
];

const BY_SLUG = new Map(ARTICLES.map((a) => [a.slug, a]));

export function findArticle(slug: string): Article | undefined {
  return BY_SLUG.get(slug);
}

/** Articles triés du plus récent au plus ancien. */
export function articlesSorted(): Article[] {
  return [...ARTICLES].sort((a, b) =>
    b.publishedAt.localeCompare(a.publishedAt)
  );
}
