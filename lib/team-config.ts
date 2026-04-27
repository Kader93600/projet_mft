// =====================================================================
// Équipe pédagogique — données affichées sur /ecole
// À compléter avec les vrais profils. Photos optionnelles : si `photo`
// est absent, on affiche les initiales sur fond gradient marque.
// =====================================================================

export interface TeamMember {
  /** Slug pour future page individuelle. */
  slug: string;
  /** Nom complet. */
  name: string;
  /** Rôle / titre. */
  role: string;
  /** Bio courte (1-2 phrases). */
  bio: string;
  /** Photo URL (publique, /public/team/...) — optionnelle. */
  photo?: string;
  /** Domaines d'expertise (chips). */
  expertise: string[];
  /** Lien LinkedIn — optionnel. */
  linkedin?: string;
}

export const TEAM: TeamMember[] = [
  {
    slug: "directeur",
    name: "[À COMPLÉTER : prénom nom]",
    role: "Directeur de la formation",
    bio: "Plus de 15 ans dans le secteur du transport routier. Ancien dirigeant d'entreprise de transport, il pilote la pédagogie et la stratégie de l'école.",
    expertise: ["Pilotage", "Réglementation TRM", "Qualiopi"],
  },
  {
    slug: "responsable-pedagogique",
    name: "[À COMPLÉTER : prénom nom]",
    role: "Responsable pédagogique",
    bio: "Formatrice expérimentée, elle conçoit les parcours et accompagne les stagiaires tout au long de leur formation.",
    expertise: ["Ingénierie pédagogique", "RNCP 40990", "Suivi stagiaires"],
  },
  {
    slug: "formateur-tr-marchandises",
    name: "[À COMPLÉTER : prénom nom]",
    role: "Formateur Transport de marchandises",
    bio: "Spécialiste du transport routier de marchandises, ancien exploitant. Anime les modules GOTRM, FIMO/FCO et capacité de transport.",
    expertise: ["GOTRM", "FIMO/FCO", "Capacité de transport"],
  },
  {
    slug: "formateur-tr-voyageurs",
    name: "[À COMPLÉTER : prénom nom]",
    role: "Formatrice Transport de voyageurs",
    bio: "Issue du milieu du transport de voyageurs, elle anime les modules ERTV et Taxi/VTC avec une approche orientée terrain.",
    expertise: ["ERTV", "Taxi/VTC", "Service client"],
  },
  {
    slug: "formateur-ecsr",
    name: "[À COMPLÉTER : prénom nom]",
    role: "Formateur ECSR",
    bio: "Moniteur d'auto-école diplômé d'État, expérience reconnue dans la formation à la sécurité routière et l'enseignement de la conduite.",
    expertise: ["Pédagogie REMC", "Sécurité routière", "Conduite"],
  },
  {
    slug: "referent-handicap",
    name: "[À COMPLÉTER : prénom nom]",
    role: "Référente handicap & accompagnement",
    bio: "Référente accessibilité, elle adapte les parcours pour les stagiaires en situation de handicap et coordonne le suivi individualisé.",
    expertise: ["Accessibilité", "RGAA", "Accompagnement"],
  },
];

export function initials(fullName: string): string {
  return fullName
    .replace(/\[.*?\]/g, "")
    .trim()
    .split(/\s+/)
    .map((p) => p[0])
    .filter(Boolean)
    .slice(0, 2)
    .join("")
    .toUpperCase() || "??";
}
