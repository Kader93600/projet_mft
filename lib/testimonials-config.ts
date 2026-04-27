// =====================================================================
// Témoignages stagiaires affichés sur /temoignages.
// À enrichir au fur et à mesure des promotions.
// Conserver l'anonymat ou demander l'accord écrit avant de mettre nom complet.
// =====================================================================

export interface Testimonial {
  /** Identifiant stable. */
  id: string;
  /** Prénom + initiale du nom (ex. "Karim B.") ou "Anonyme". */
  name: string;
  /** Année de la promotion. */
  year: number;
  /** Slug de la formation (cf. formations-config.ts) — null si générique. */
  formationSlug: string | null;
  /** Note sur 5. */
  rating: 1 | 2 | 3 | 4 | 5;
  /** Témoignage. */
  quote: string;
  /** Optionnel : profession actuelle / situation. */
  role?: string;
  /** Optionnel : ville. */
  city?: string;
}

export const TESTIMONIALS: Testimonial[] = [
  {
    id: "karim-b-2026",
    name: "Karim B.",
    year: 2026,
    formationSlug: "gotrm",
    rating: 5,
    role: "Exploitant transport",
    city: "Meaux",
    quote:
      "La plateforme est nickel, le suivi vraiment personnalisé. J'ai pu travailler le soir après le boulot. Examen passé du premier coup.",
  },
  {
    id: "aicha-l-2026",
    name: "Aïcha L.",
    year: 2026,
    formationSlug: "capacite-plus-3-5t",
    rating: 5,
    role: "Dirigeante d'entreprise",
    city: "Bondy",
    quote:
      "J'ai créé mon entreprise de transport grâce à cette formation. L'équipe répond très vite, c'est rassurant pour un projet pareil.",
  },
  {
    id: "jean-marc-d-2026",
    name: "Jean-Marc D.",
    year: 2026,
    formationSlug: "fimo-fco",
    rating: 4,
    role: "Conducteur SPL",
    city: "Lognes",
    quote:
      "Le format mixte est top : la théorie en ligne, le pratique en centre. Ça change des journées de formation interminables.",
  },
  {
    id: "fatou-d-2026",
    name: "Fatou D.",
    year: 2026,
    formationSlug: "ecsr",
    rating: 5,
    role: "Monitrice d'auto-école",
    city: "Saint-Denis",
    quote:
      "Formation complète et exigeante, mais l'accompagnement m'a portée jusqu'au bout. Je recommande vivement à toutes celles qui hésitent.",
  },
  {
    id: "mohamed-h-2026",
    name: "Mohamed H.",
    year: 2026,
    formationSlug: "taxi-vtc",
    rating: 5,
    role: "Chauffeur VTC indépendant",
    city: "Paris",
    quote:
      "J'ai obtenu ma carte du premier coup. Les modules sur la réglementation Taxi/VTC sont vraiment clairs, même pour quelqu'un comme moi qui n'avait jamais étudié depuis longtemps.",
  },
  {
    id: "stephanie-r-2026",
    name: "Stéphanie R.",
    year: 2026,
    formationSlug: "ertv",
    rating: 4,
    role: "Régulatrice TRV",
    city: "Bobigny",
    quote:
      "J'avais besoin d'un titre reconnu pour évoluer dans mon entreprise. Le programme est dense mais bien structuré, et le coach est top.",
  },
  {
    id: "pierre-l-2026",
    name: "Pierre L.",
    year: 2026,
    formationSlug: "commissionnaire",
    rating: 5,
    role: "Commissionnaire de transport",
    city: "Roissy",
    quote:
      "Préparation très complète à l'examen national. Les cas pratiques internationaux (Incoterms, CMR) sont vraiment utiles. Je peux maintenant gérer mon activité sereinement.",
  },
  {
    id: "amira-k-2026",
    name: "Amira K.",
    year: 2026,
    formationSlug: "capacite-3-5t",
    rating: 5,
    role: "Auto-entrepreneur livraison",
    city: "Meaux",
    quote:
      "Format à distance parfait pour mon emploi du temps. J'ai pu démarrer mon activité de coursier dès la fin de la formation.",
  },
  {
    id: "anonyme-employer-2025",
    name: "Direction RH",
    year: 2025,
    formationSlug: null,
    rating: 5,
    role: "Entreprise transport — 80 conducteurs",
    city: "Île-de-France",
    quote:
      "Notre référence pour la FCO de tous nos chauffeurs. Suivi administratif impeccable, factures OPCO claires, taux de réussite 100% sur 3 sessions.",
  },
];

export function listFormationSlugsWithTestimonials(): string[] {
  return Array.from(
    new Set(
      TESTIMONIALS.filter((t) => t.formationSlug).map((t) => t.formationSlug!)
    )
  );
}

export function avgRating(): number {
  if (TESTIMONIALS.length === 0) return 0;
  return (
    TESTIMONIALS.reduce((s, t) => s + t.rating, 0) / TESTIMONIALS.length
  );
}
