// =====================================================================
// Configuration légale centrale.
// ⚠️ À compléter AVANT mise en production. Les valeurs entre crochets
//    [À COMPLÉTER] doivent être remplacées par les vraies données.
//
// Cette config est consommée par :
//   - /mentions-legales
//   - /cgu, /cgv
//   - /retractation
//   - /reglement-interieur
//   - /confidentialite (DPO)
//   - PDF : convention de formation, attestation, certificat
// =====================================================================

export const LEGAL = {
  // Identité de l'organisme
  brand: "MA FORMATION TRANSPORT",
  legalName: "MA FORMATION TRANSPORT",
  legalForm: "[À COMPLÉTER : SAS / SASU / EURL / SARL / EI]",
  siren: "908 851 280",
  siret: "[À COMPLÉTER : SIREN + 5 chiffres NIC]",
  rcs: "[À COMPLÉTER : RCS Meaux + numéro]",
  vatNumber: "[À COMPLÉTER : FR XX 908851280]",
  shareCapital: "[À COMPLÉTER : x xxx €]",
  apeCode: "8559B",
  apeLabel: "Autres enseignements",

  // Adresse
  address: {
    street: "39 Avenue des Sablons Bouillants",
    postalCode: "77100",
    city: "Meaux",
    country: "France",
  },

  // Direction
  director: "[À COMPLÉTER : nom du représentant légal]",
  publicationDirector: "[À COMPLÉTER : directeur de publication]",

  // Contact
  email: "contact@maformationtransport.fr",
  phone: "[À COMPLÉTER : 0X XX XX XX XX]",
  supportEmail: "support@maformationtransport.fr",

  // Organisme de formation
  trainingActivityNumber: "[À COMPLÉTER : numéro de déclaration d'activité OF — 11 chiffres + région]",
  qualiopiNumber: "[À COMPLÉTER : numéro de certification Qualiopi]",
  qualiopiBody: "[À COMPLÉTER : nom de l'organisme certificateur, ex. AFNOR Certification]",

  // Référentiel principal (gardé pour compatibilité PDF — voir formations-config.ts pour le détail multi-formations)
  rncpCode: "RNCP 40990",
  rncpTitle: "Gestionnaire des Opérations de Transport Routier de Marchandises",

  // RGPD
  dpoName: "[À COMPLÉTER : nom du DPO ou délégué]",
  dpoEmail: "dpo@maformationtransport.fr",

  // Hébergement
  hosting: {
    name: "Supabase",
    company: "Supabase Inc.",
    address: "970 Toa Payoh North, #07-04, Singapore 318992",
    euDataCenter: "AWS eu-west-3 (Paris) / eu-central-1 (Frankfurt)",
    website: "https://supabase.com",
  },

  // Site
  website: "https://maformationtransport.fr",
  // Tagline / promesse
  tagline: "L'école qui forme les pros du transport",
  shortDescription:
    "Centre de formation spécialisé dans les métiers du transport routier de marchandises et de voyageurs. Préparation aux titres pros, capacité de transport, FIMO/FCO, taxi/VTC.",

  // Médiateur de la consommation (B2C — obligatoire si vente à des particuliers)
  mediator: {
    name: "[À COMPLÉTER : nom du médiateur — ex. CM2C]",
    website: "[À COMPLÉTER : URL]",
  },

  // Informations Qualiopi à afficher
  qualiopi: {
    averageSatisfaction: "[À COMPLÉTER après 1ère cohorte : ex. 4,5/5]",
    successRate: "[À COMPLÉTER après 1ère cohorte : ex. 87 %]",
    accessibilityContact: "accessibilite@maformationtransport.fr",
  },
} as const;

export const LEGAL_DATE_FR = new Intl.DateTimeFormat("fr-FR", {
  day: "2-digit",
  month: "long",
  year: "numeric",
});

// Date de dernière mise à jour des CGU/CGV (à incrémenter manuellement)
export const LEGAL_LAST_UPDATE = "2026-04-25";
