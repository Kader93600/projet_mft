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
  // Identité de l'organisme (source : attestation INPI/RNE 03/05/2026)
  brand: "MA FORMATION TRANSPORT",
  legalName: "MA FORMATION TRANSPORT",
  legalForm: "SAS, société par actions simplifiée",
  siren: "908 851 280",
  siret: "908 851 280 00028",
  rcs: "RCS Meaux 908 851 280",
  vatNumber: "FR58908851280",
  shareCapital: "3 000 €",
  apeCode: "8559B",
  apeLabel: "Autres enseignements",

  // Adresse (siège social)
  address: {
    street: "39 Avenue des Sablons Bouillants",
    postalCode: "77100",
    city: "Meaux",
    country: "France",
  },

  // Direction (source : INPI/RNE)
  director: "Mehdie Debbouza",
  publicationDirector: "Mehdie Debbouza",

  // Contact
  email: "contact@maformationtransport.fr",
  phone: "01 60 09 54 47",
  supportEmail: "support@maformationtransport.fr",

  // Organisme de formation (NDA délivré par la DREETS Île-de-France, région 11)
  trainingActivityNumber: "11 77 09 47177",
  qualiopiNumber: "CW202525-4287",
  qualiopiBody: "BCI France (Bureau de Certification International)",

  // Référentiel principal (gardé pour compatibilité PDF — voir formations-config.ts pour le détail multi-formations)
  rncpCode: "RNCP 40990",
  rncpTitle: "Gestionnaire des Opérations de Transport Routier de Marchandises",

  // RGPD (par défaut : le représentant légal assume la fonction DPO)
  dpoName: "Mehdie Debbouza",
  dpoEmail: "dpo@maformationtransport.fr",

  // Hébergement
  hosting: {
    name: "Supabase",
    company: "Supabase Inc.",
    address: "970 Toa Payoh North, #07-04, Singapore 318992",
    euDataCenter: "AWS eu-west-3 (Paris) / eu-central-1 (Frankfurt)",
    website: "https://supabase.com",
  },

  // Site — domaine CANONIQUE (www) : la prod sert www, l'apex redirige.
  // Consommé par metadataBase, sitemap, robots, Open Graph et JSON-LD.
  website: "https://www.maformationtransport.fr",
  // Tagline / promesse
  tagline: "L'école qui forme les pros du transport",
  shortDescription:
    "Centre de formation spécialisé dans les métiers du transport routier de marchandises et de voyageurs. Préparation aux titres pros, capacité de transport, FIMO/FCO, taxi/VTC.",

  // Médiateur de la consommation (B2C — OBLIGATOIRE dès le 1er client
  // particulier : art. L.612-1 & R.616-1 du Code de la consommation).
  //
  // ⚠️ ACTION CLIENT : adhérer à UN médiateur agréé, puis remplacer les
  //    2 lignes ci-dessous par le nom et l'URL communiqués à l'adhésion.
  //    Tant que "COMPLÉTER" est présent, le site affiche une mention
  //    transitoire conforme (coordonnées « sur demande ») et n'expose
  //    jamais ce placeholder aux visiteurs.
  //
  // Médiateurs agréés courants (~120 €/an, choisir-en UN) :
  //   - CM2C          : https://www.cm2c.net
  //   - MEDICYS       : https://www.medicys-consommation.fr
  //   - ANM Conso     : https://anm-conso.com
  //   - Médiation de la consommation (AME) : https://www.mediationconso-ame.com
  // Exemple une fois adhéré :
  //   name: "CM2C — Centre de la médiation de la consommation de conciliateurs de justice",
  //   website: "https://www.cm2c.net",
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
