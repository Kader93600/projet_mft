// =====================================================================
// Catalogue des formations de MA FORMATION TRANSPORT
// Source unique consommée par : /formations, /formations/[slug],
// la home (carrefour), le footer, les pages financement.
// =====================================================================

export type FundingKey =
  | "cpf"
  | "opco"
  | "employeur"
  | "pole_emploi"
  | "auto"
  | "transitions_pro";

export interface Formation {
  /** slug URL — stable, en minuscules. */
  slug: string;
  /** Acronyme court (chip / mark). */
  code: string;
  /** Titre complet. */
  title: string;
  /** Sous-titre — promesse 1 ligne. */
  tagline: string;
  /** Catégorie pour filtrage. */
  category: "marchandises" | "voyageurs" | "enseignement" | "capacite" | "autre";
  /** Niveau RNCP (3, 4, 5, 6) si applicable. */
  level?: 3 | 4 | 5;
  /** Code RNCP si certification inscrite. */
  rncpCode?: string;
  /** Durée totale, format libre lisible. */
  duration: string;
  /** Modalité dominante. */
  modality: "presentiel" | "distanciel" | "mixte";
  /** Public cible. */
  audience: string;
  /** Prérequis. */
  prerequisites: string;
  /** Description longue (paragraphe accroche). */
  description: string;
  /** Objectifs pédagogiques (puces). */
  objectives: string[];
  /** Programme par modules / chapitres. */
  program: { title: string; details: string[] }[];
  /** Compétences visées. */
  skills: string[];
  /** Modalités d'évaluation (Qualiopi — critère 1, indicateur 1). */
  assessment: string;
  /** Débouchés, suites de parcours et passerelles (Qualiopi — critère 1). */
  outcomes: string[];
  /** Modes de financement applicables. */
  funding: FundingKey[];
  /** Mis en avant sur la home. */
  featured?: boolean;
  /** Couleur d'accent SVG (hex) — utilisée par le carrefour. */
  accent?: string;
  /** Icône lucide-react (nom du composant) pour cohérence visuelle. */
  iconName:
    | "Truck"
    | "Bus"
    | "GraduationCap"
    | "Car"
    | "Briefcase"
    | "Package"
    | "Award"
    | "ShieldCheck";
}

export const FUNDING_LABELS: Record<FundingKey, string> = {
  cpf: "CPF",
  opco: "OPCO",
  employeur: "Employeur",
  pole_emploi: "France Travail",
  auto: "Auto-financement",
  transitions_pro: "Transitions Pro",
};

export const FORMATIONS: Formation[] = [
  {
    slug: "gotrm",
    assessment:
      "Évaluation continue (QCM et études de cas), examens blancs en conditions réelles, puis épreuves du titre devant un jury (dossier professionnel et mises en situation). Titre RNCP 40990 de niveau 5 délivré par le Ministère du Travail.",
    outcomes: [
      "Responsable ou gestionnaire d'exploitation transport",
      "Affréteur, dispatcher, chef de quai",
      "Accès à la capacité de transport de marchandises (selon équivalences)",
      "Poursuite possible vers une licence pro logistique / transport",
    ],
    code: "GOTRM",
    title: "Gestionnaire des Opérations de Transport Routier de Marchandises",
    tagline:
      "Le titre pro de référence pour piloter une activité transport marchandises.",
    category: "marchandises",
    level: 5,
    rncpCode: "RNCP 40990",
    duration: "8 à 16 semaines selon formule",
    modality: "mixte",
    audience:
      "Demandeurs d'emploi, salariés en évolution, chefs d'entreprise du secteur transport.",
    prerequisites:
      "Niveau bac ou expérience significative dans le transport / logistique.",
    description:
      "Préparation complète au titre professionnel niveau 5 (RNCP 40990) délivré par le Ministère du Travail. La formation couvre les trois blocs de compétences : exploitation, gestion, qualité-sécurité.",
    objectives: [
      "Organiser une activité de transport routier conformément à la réglementation",
      "Gérer les ressources humaines et matérielles de l'exploitation",
      "Animer la démarche qualité, sécurité et environnement",
      "Préparer et passer l'examen final du titre RNCP 40990",
    ],
    program: [
      {
        title: "Bloc 1 — Exploitation",
        details: [
          "Réglementation européenne et nationale",
          "Temps de conduite et de repos (R561/2006, AETR)",
          "Cabotage et transport international",
          "Contrats type marchandises",
        ],
      },
      {
        title: "Bloc 2 — Gestion",
        details: [
          "Calculs de prix de revient et de vente",
          "Gestion des conducteurs et du matériel",
          "Outils numériques (TMS, télématique)",
          "Comptabilité et pilotage financier",
        ],
      },
      {
        title: "Bloc 3 — Qualité, sécurité, environnement",
        details: [
          "Management QSE",
          "Prévention des risques routiers",
          "Transport de marchandises dangereuses (notions ADR)",
          "Empreinte carbone et CSRD",
        ],
      },
    ],
    skills: [
      "Pilotage d'exploitation",
      "Réglementation transport",
      "Gestion économique",
      "Management d'équipe",
    ],
    funding: ["cpf", "opco", "employeur", "pole_emploi", "auto", "transitions_pro"],
    featured: true,
    accent: "#9FE220",
    iconName: "Truck",
  },
  {
    slug: "ertv",
    assessment:
      "Contrôle continu (QCM, études de cas), examens blancs et épreuves de certification du titre devant jury.",
    outcomes: [
      "Régulateur ou agent d'exploitation transport de voyageurs",
      "Responsable de ligne, de dépôt ou d'exploitation",
      "Poursuite possible vers le titre GOTRM ou une licence transport",
    ],
    code: "ERTV",
    title: "Exploitant en Régulation du Transport de Voyageurs",
    tagline:
      "Pilotez les opérations de transport de personnes en autocar et urbain.",
    category: "voyageurs",
    level: 4,
    duration: "12 semaines",
    modality: "mixte",
    audience:
      "Conducteurs voyageurs souhaitant évoluer, demandeurs d'emploi, reconversion.",
    prerequisites:
      "Niveau CAP/BEP ou expérience dans le transport. Permis D apprécié non obligatoire.",
    description:
      "Formation complète aux métiers de l'exploitation transport de voyageurs : régulation, planification des conducteurs, gestion des incidents, relation client.",
    objectives: [
      "Planifier et réguler une activité de transport de voyageurs",
      "Maîtriser la réglementation sociale spécifique TRV",
      "Gérer les aléas d'exploitation en temps réel",
      "Animer une équipe de conducteurs",
    ],
    program: [
      {
        title: "Réglementation transport voyageurs",
        details: [
          "Règlement européen 1071/2009",
          "Temps de conduite TRV",
          "Documents de bord et obligations",
        ],
      },
      {
        title: "Régulation et exploitation",
        details: [
          "Outils SAE/SIV",
          "Planification des graphicages",
          "Gestion temps réel et incidents",
        ],
      },
      {
        title: "Relation client et management",
        details: [
          "Service voyageur",
          "Gestion d'équipe",
          "KPIs d'exploitation",
        ],
      },
    ],
    skills: [
      "Régulation TRV",
      "Planification conducteurs",
      "Gestion d'incidents",
      "Outils SAE",
    ],
    funding: ["cpf", "opco", "employeur", "pole_emploi", "auto"],
    accent: "#5C6AF2",
    iconName: "Bus",
  },
  {
    slug: "ecsr",
    assessment:
      "Contrôle continu, mises en situation pédagogiques évaluées et épreuves de certification du titre d'enseignant de la conduite.",
    outcomes: [
      "Enseignant de la conduite et de la sécurité routière (auto-école)",
      "Évolution vers responsable pédagogique d'établissement",
      "Création ou direction d'une auto-école (qualifications complémentaires requises)",
    ],
    code: "ECSR",
    title: "Enseignant de la Conduite et de la Sécurité Routière",
    tagline:
      "Devenez moniteur d'auto-école et formateur agréé.",
    category: "enseignement",
    level: 5,
    duration: "8 à 12 mois",
    modality: "presentiel",
    audience:
      "Personnes souhaitant devenir moniteur d'auto-école ou formateur en conduite.",
    prerequisites:
      "Permis B ≥ 3 ans, casier vierge (B2), niveau bac requis.",
    description:
      "Formation au titre professionnel ECSR (RNCP). Préparation à l'enseignement de la conduite catégorie B et aux missions d'éducation à la sécurité routière.",
    objectives: [
      "Concevoir et animer des séances de formation à la conduite",
      "Évaluer les compétences d'un apprenti conducteur",
      "Sensibiliser aux risques routiers",
      "Maîtriser la pédagogie adulte appliquée à la conduite",
    ],
    program: [
      {
        title: "Pédagogie de la conduite",
        details: [
          "Référentiel REMC",
          "Construction de séances",
          "Évaluation des compétences",
        ],
      },
      {
        title: "Connaissance du véhicule et de la route",
        details: [
          "Mécanique appliquée",
          "Code de la route approfondi",
          "Risques et accidentologie",
        ],
      },
      {
        title: "Cadre réglementaire et déontologique",
        details: [
          "Statut du moniteur",
          "Agrément des écoles de conduite",
          "Éthique professionnelle",
        ],
      },
    ],
    skills: [
      "Pédagogie adulte",
      "Évaluation conducteur",
      "Sécurité routière",
      "Animation de groupe",
    ],
    funding: ["cpf", "opco", "pole_emploi", "auto", "transitions_pro"],
    accent: "#3845E5",
    iconName: "GraduationCap",
  },
  {
    slug: "fimo-fco",
    assessment:
      "Évaluation continue des acquis tout au long du stage ; attestation de formation délivrée à l'issue (formations obligatoires validées par l'assiduité et les tests réglementaires).",
    outcomes: [
      "Conducteur routier de marchandises (porteur, ensemble articulé)",
      "Maintien des droits à conduire via la FCO (tous les 5 ans)",
      "Passerelle vers le titre GOTRM pour évoluer vers l'exploitation",
    ],
    code: "FIMO / FCO",
    title: "FIMO Marchandises & FCO obligatoire",
    tagline:
      "Formation initiale et continue obligatoires pour les conducteurs pros.",
    category: "marchandises",
    duration: "FIMO : 140 h · FCO : 35 h tous les 5 ans",
    modality: "presentiel",
    audience:
      "Conducteurs professionnels, futurs conducteurs, employeurs renouvelant la qualification de leurs équipes.",
    prerequisites:
      "Permis C/CE en cours de validité (FIMO) ou FIMO précédente (FCO).",
    description:
      "Formations réglementaires obligatoires pour exercer en tant que conducteur de transport routier de marchandises (Décret 2007-1340). Sessions FIMO complètes ou FCO de remise à niveau.",
    objectives: [
      "Acquérir / renouveler la qualification professionnelle",
      "Mettre à jour la réglementation",
      "Améliorer la sécurité et l'éco-conduite",
      "Obtenir la carte de qualification conducteur (CQC)",
    ],
    program: [
      {
        title: "Bloc 1 — Conduite rationnelle et sécurité",
        details: ["Maîtrise du véhicule", "Éco-conduite", "Prévention des risques"],
      },
      {
        title: "Bloc 2 — Réglementation",
        details: [
          "Réglementation sociale européenne",
          "Document de transport",
          "Temps de conduite",
        ],
      },
      {
        title: "Bloc 3 — Santé, sécurité, environnement",
        details: [
          "Postures et ergonomie",
          "Comportement face aux situations d'urgence",
          "Service au client",
        ],
      },
    ],
    skills: [
      "Conduite professionnelle",
      "Éco-conduite",
      "Réglementation sociale",
      "Sécurité opérationnelle",
    ],
    funding: ["opco", "employeur", "pole_emploi"],
    accent: "#A8D729",
    iconName: "Truck",
  },
  {
    slug: "taxi-vtc",
    assessment:
      "QCM blancs et mises en situation en conditions d'examen ; préparation à l'examen officiel (épreuve d'admissibilité puis d'admission).",
    outcomes: [
      "Chauffeur de taxi ou VTC, indépendant ou salarié",
      "Création de sa propre activité de transport de personnes",
      "Évolution vers la gestion d'une flotte VTC",
    ],
    code: "Taxi & VTC",
    title: "Préparation aux examens Taxi et VTC",
    tagline:
      "Obtenez votre carte professionnelle Taxi ou VTC.",
    category: "voyageurs",
    duration: "150 à 250 h selon formule",
    modality: "mixte",
    audience:
      "Personnes souhaitant exercer en tant que chauffeur Taxi ou VTC, en propre ou en franchise.",
    prerequisites:
      "Permis B ≥ 3 ans, casier judiciaire compatible (bulletin n°2), aptitude médicale.",
    description:
      "Préparation complète aux examens Taxi (préfectoraux) et VTC (CMA / CCI). Modules réglementation, gestion, sécurité et relation client.",
    objectives: [
      "Maîtriser la réglementation Taxi/VTC",
      "Préparer l'examen théorique et pratique",
      "Gérer une activité de transport de personnes",
      "Optimiser sa relation client",
    ],
    program: [
      {
        title: "Réglementation",
        details: [
          "Statut et obligations",
          "Tarification",
          "Loi Grandguillaume",
        ],
      },
      {
        title: "Gestion d'activité",
        details: [
          "Gestion comptable",
          "Statut entrepreneur",
          "Charges et fiscalité",
        ],
      },
      {
        title: "Sécurité et conduite",
        details: [
          "Conduite rationnelle",
          "Premiers secours",
          "Anglais professionnel (VTC)",
        ],
      },
    ],
    skills: [
      "Réglementation T3P",
      "Gestion d'activité",
      "Relation client premium",
      "Sécurité routière",
    ],
    funding: ["cpf", "opco", "pole_emploi", "auto"],
    accent: "#F59E0B",
    iconName: "Car",
  },
  {
    slug: "commissionnaire",
    assessment:
      "Contrôle continu et examen blanc en conditions réelles ; préparation à l'examen national écrit de commissionnaire de transport.",
    outcomes: [
      "Commissionnaire ou organisateur de transport",
      "Affréteur national et international",
      "Création d'une entreprise de commission de transport",
    ],
    code: "Commissionnaire",
    title: "Préparation à l'examen national Commissionnaire de transport",
    tagline:
      "L'attestation pour exercer en tant que commissionnaire (organisateur de transport).",
    category: "marchandises",
    duration: "8 semaines intensives",
    modality: "mixte",
    audience:
      "Personnes souhaitant créer ou diriger une entreprise de commission de transport (3PL, freight forwarding).",
    prerequisites:
      "Niveau bac et/ou expérience secteur transport-logistique.",
    description:
      "Préparation complète à l'examen national permettant d'obtenir l'attestation de capacité professionnelle de commissionnaire de transport, indispensable pour exercer cette activité réglementée.",
    objectives: [
      "Maîtriser la réglementation de la commission de transport",
      "Comprendre les contrats internationaux (FIATA, Incoterms)",
      "Gérer la relation entre donneur d'ordre et transporteur",
      "Réussir l'examen national",
    ],
    program: [
      {
        title: "Cadre juridique",
        details: [
          "Contrat de commission",
          "Responsabilité du commissionnaire",
          "Conventions internationales (CMR, Varsovie)",
        ],
      },
      {
        title: "Multimodal et international",
        details: [
          "Incoterms 2020",
          "Procédures douanières",
          "Modes de transport combinés",
        ],
      },
      {
        title: "Économie et gestion",
        details: [
          "Tarification et marges",
          "Assurances transport",
          "Outils digitaux (TMS, EDI)",
        ],
      },
    ],
    skills: [
      "Droit du transport",
      "Multimodal",
      "Négociation",
      "Gestion des contrats internationaux",
    ],
    funding: ["cpf", "opco", "employeur", "auto", "transitions_pro"],
    accent: "#7EBE17",
    iconName: "Briefcase",
  },
  {
    slug: "capacite-3-5t",
    assessment:
      "QCM blancs en conditions d'examen ; préparation à l'examen national écrit (attestation de capacité professionnelle, transport léger).",
    outcomes: [
      "Création d'une entreprise de transport léger de marchandises (≤ 3,5 t)",
      "Inscription au registre des transporteurs",
      "Passerelle vers la capacité de transport > 3,5 t",
    ],
    code: "Capacité ≤ 3,5 t",
    title: "Attestation de capacité professionnelle — véhicules ≤ 3,5 t",
    tagline:
      "Créez votre entreprise de transport léger en toute conformité.",
    category: "capacite",
    duration: "105 h",
    modality: "mixte",
    audience:
      "Auto-entrepreneurs, créateurs d'entreprise transport léger (livraison, coursier).",
    prerequisites:
      "Aucun prérequis spécifique. Aucun bac requis.",
    description:
      "Formation préparant à l'attestation de capacité professionnelle pour les véhicules dont le PMA ≤ 3,5 tonnes (décret 2011-2045). Indispensable pour s'inscrire au registre des transporteurs.",
    objectives: [
      "Comprendre le cadre réglementaire transport léger",
      "Gérer une activité conformément aux obligations",
      "Obtenir l'attestation à l'issue de la formation",
      "S'inscrire au registre des transporteurs DREAL",
    ],
    program: [
      {
        title: "Réglementation",
        details: [
          "Conditions d'accès à la profession",
          "Documents de transport",
          "Obligations sociales",
        ],
      },
      {
        title: "Gestion d'entreprise",
        details: [
          "Statut juridique",
          "Comptabilité de base",
          "Tarification et coût de revient",
        ],
      },
      {
        title: "Sécurité et qualité",
        details: [
          "Sécurité routière",
          "Relation client",
          "Démarche qualité",
        ],
      },
    ],
    skills: [
      "Cadre réglementaire transport léger",
      "Création d'entreprise",
      "Gestion administrative",
      "Sécurité",
    ],
    funding: ["cpf", "pole_emploi", "auto"],
    accent: "#BEE74E",
    iconName: "Package",
  },
  {
    slug: "capacite-plus-3-5t",
    assessment:
      "Études de cas et examens blancs ; préparation à l'examen national (épreuve écrite et étude de cas) de capacité de transport lourd.",
    outcomes: [
      "Création ou direction d'une entreprise de transport routier lourd",
      "Gestionnaire de transport inscrit au registre national",
      "Accès à la profession de transporteur public routier de marchandises",
    ],
    code: "Capacité > 3,5 t",
    title: "Capacité de transport > 3,5 t — Préparation à l'examen national",
    tagline:
      "L'attestation indispensable pour gérer une entreprise de transport lourd.",
    category: "capacite",
    duration: "12 semaines (105 h théorie + 35 h pratique)",
    modality: "mixte",
    audience:
      "Créateurs ou repreneurs d'entreprises de transport lourd, dirigeants, gestionnaires.",
    prerequisites:
      "Niveau bac apprécié, ou expérience professionnelle dans le transport.",
    description:
      "Préparation complète à l'examen national de capacité professionnelle pour les véhicules > 3,5 tonnes (Décret 2011-2045 et Règlement CE 1071/2009). Obtention obligatoire pour s'inscrire en tant que transporteur lourd.",
    objectives: [
      "Maîtriser le cadre juridique européen et national",
      "Acquérir les fondamentaux de gestion comptable et financière",
      "Préparer l'examen national en conditions réelles",
      "Obtenir l'attestation de capacité professionnelle",
    ],
    program: [
      {
        title: "Droit civil, commercial, social et fiscal",
        details: [
          "Statut juridique des entreprises",
          "Contrats de transport",
          "Droit social du transport",
        ],
      },
      {
        title: "Gestion commerciale et financière",
        details: [
          "Comptabilité générale",
          "Analyse financière",
          "Coût de revient et tarification",
        ],
      },
      {
        title: "Réglementation routière et sécurité",
        details: [
          "Conditions d'accès",
          "Réglementation sociale européenne",
          "Sécurité et environnement",
        ],
      },
    ],
    skills: [
      "Droit du transport",
      "Gestion financière",
      "Réglementation européenne",
      "Sécurité opérationnelle",
    ],
    funding: ["cpf", "opco", "employeur", "pole_emploi", "auto", "transitions_pro"],
    featured: true,
    accent: "#2530D9",
    iconName: "ShieldCheck",
  },
];

export const CATEGORIES: Record<
  Formation["category"],
  { label: string; description: string }
> = {
  marchandises: {
    label: "Transport de marchandises",
    description: "Pour piloter ou créer une activité de fret routier.",
  },
  voyageurs: {
    label: "Transport de voyageurs",
    description: "Pour les métiers de la mobilité des personnes.",
  },
  enseignement: {
    label: "Enseignement de la conduite",
    description: "Pour devenir formateur ou moniteur d'auto-école.",
  },
  capacite: {
    label: "Capacité de transport",
    description: "Attestations professionnelles pour créer son entreprise.",
  },
  autre: {
    label: "Autres formations",
    description: "Sessions thématiques courtes.",
  },
};

export function findFormation(slug: string): Formation | undefined {
  return FORMATIONS.find((f) => f.slug === slug);
}

export function listByCategory() {
  return Object.entries(CATEGORIES).map(([key, meta]) => ({
    key: key as Formation["category"],
    ...meta,
    items: FORMATIONS.filter((f) => f.category === key),
  }));
}
