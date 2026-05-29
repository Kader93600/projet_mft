// =====================================================================
// Catalogue de libellés (tags) pour la boîte de réception.
// Pensé pour un OF transport : public stagiaire / formateur, financements,
// formations principales du catalogue, et états de traitement.
// =====================================================================

export type LabelTone = "blue" | "violet" | "lime" | "gold" | "rose" | "amber" | "teal" | "navy" | "slate" | "cyan";

export interface EmailLabel {
  id: string;
  name: string;
  emoji: string;
  tone: LabelTone;
}

export const EMAIL_LABELS: EmailLabel[] = [
  // Personnes
  { id: "stagiaire", name: "Stagiaire", emoji: "🎓", tone: "blue" },
  { id: "formateur", name: "Formateur", emoji: "👨‍🏫", tone: "violet" },
  { id: "prospect", name: "Prospect", emoji: "🎯", tone: "slate" },
  { id: "financeur", name: "Financeur", emoji: "🏢", tone: "navy" },
  // Financements
  { id: "cpf", name: "CPF", emoji: "💼", tone: "gold" },
  { id: "opco", name: "OPCO", emoji: "🏛️", tone: "navy" },
  { id: "france-travail", name: "France Travail", emoji: "🏛️", tone: "blue" },
  { id: "paiement", name: "Paiement", emoji: "💰", tone: "rose" },
  // Conformité / administratif
  { id: "qualiopi", name: "Qualiopi", emoji: "📋", tone: "lime" },
  { id: "convention", name: "Convention", emoji: "✍️", tone: "amber" },
  { id: "convocation", name: "Convocation", emoji: "📅", tone: "amber" },
  { id: "emargement", name: "Émargement", emoji: "🖊️", tone: "amber" },
  { id: "signature", name: "Signature", emoji: "🪶", tone: "amber" },
  { id: "document", name: "Document", emoji: "📎", tone: "slate" },
  { id: "reclamation", name: "Réclamation", emoji: "📝", tone: "rose" },
  // Formations transport
  { id: "gotrm", name: "GOTRM", emoji: "🚚", tone: "navy" },
  { id: "capacite-3-5t", name: "Capacité ≤ 3,5 t", emoji: "🚐", tone: "teal" },
  { id: "capacite-plus-3-5t", name: "Capacité > 3,5 t", emoji: "🚛", tone: "navy" },
  { id: "fimo-fco", name: "FIMO / FCO", emoji: "🚛", tone: "amber" },
  { id: "taxi-vtc", name: "Taxi / VTC", emoji: "🚕", tone: "amber" },
  { id: "ertv", name: "ERTV", emoji: "🚌", tone: "violet" },
  // Pédagogie / activité
  { id: "session-live", name: "Session live", emoji: "🎥", tone: "violet" },
  { id: "examen", name: "Examen", emoji: "📝", tone: "gold" },
  { id: "absence", name: "Absence", emoji: "🕒", tone: "amber" },
  // États
  { id: "urgent", name: "Urgent", emoji: "🚨", tone: "rose" },
  { id: "a-traiter", name: "À traiter", emoji: "⏳", tone: "amber" },
  { id: "en-cours", name: "En cours", emoji: "🔄", tone: "blue" },
  { id: "resolu", name: "Résolu", emoji: "✅", tone: "lime" },
];

const BY_ID = new Map(EMAIL_LABELS.map((l) => [l.id, l]));
export const findLabel = (id: string): EmailLabel | undefined => BY_ID.get(id);

// Classes Tailwind par tonalité (bg + texte + bordure, déclinaison light).
export const LABEL_TONE_CLASSES: Record<LabelTone, string> = {
  blue: "bg-blue-50 text-blue-700 border-blue-200",
  violet: "bg-violet-50 text-violet-700 border-violet-200",
  lime: "bg-signal-50 text-signal-800 border-signal-200",
  gold: "bg-gold-50 text-gold-800 border-gold-200",
  rose: "bg-rose-50 text-rose-700 border-rose-200",
  amber: "bg-amber-50 text-amber-800 border-amber-200",
  teal: "bg-teal-50 text-teal-700 border-teal-200",
  navy: "bg-navy-50 text-navy-800 border-navy-200",
  slate: "bg-slate-100 text-slate-700 border-slate-200",
  cyan: "bg-cyan-50 text-cyan-700 border-cyan-200",
};
