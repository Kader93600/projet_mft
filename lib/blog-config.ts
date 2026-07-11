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
