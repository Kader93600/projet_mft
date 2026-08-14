// =====================================================================
// Module Convocations PDF — types, constantes et helpers partagés
// entre le formulaire (client), les server actions et les templates PDF.
// =====================================================================

export type ConvocationKind = "candidat" | "jury";
export type ConvocationTemplate = "classique" | "moderne" | "compact";
export type ConvocationStatus =
  | "brouillon" | "generee" | "envoyee" | "confirmee" | "annulee" | "modifiee";

/** Libellés + tonalité d'affichage des statuts (badges de l'historique). */
export const STATUTS: Record<ConvocationStatus, { label: string; tone: string }> = {
  brouillon: { label: "Brouillon", tone: "bg-slate-100 text-slate-700 border-slate-200" },
  generee: { label: "Générée", tone: "bg-navy-50 text-navy-800 border-navy-200" },
  envoyee: { label: "Envoyée", tone: "bg-blue-50 text-blue-800 border-blue-200" },
  confirmee: { label: "Confirmée", tone: "bg-emerald-50 text-emerald-800 border-emerald-200" },
  annulee: { label: "Annulée", tone: "bg-rose-50 text-rose-700 border-rose-200" },
  modifiee: { label: "Modifiée", tone: "bg-amber-50 text-amber-800 border-amber-200" },
};

export const TEMPLATES: Record<ConvocationTemplate, { label: string; hint: string }> = {
  classique: { label: "Classique", hint: "Institutionnel et administratif" },
  moderne: { label: "Moderne", hint: "Encadrés et hiérarchie visuelle" },
  compact: { label: "Compact", hint: "L'essentiel sur une page" },
};

export const TYPES_EPREUVE = [
  "Épreuve écrite", "Épreuve orale", "Épreuve pratique",
  "Entretien", "Soutenance", "Mise en situation professionnelle",
  "Questionnaire professionnel", "Session d'examen", "Autre",
] as const;

export const ROLES_JURY = [
  "Président du jury", "Membre du jury", "Jury professionnel",
  "Examinateur", "Évaluateur", "Observateur", "Autre",
] as const;

/** Consignes activables (candidat). L'ordre est celui d'affichage. */
export const CONSIGNES_CANDIDAT = [
  { id: "piece_identite", label: "Pièce d'identité en cours de validité", defaut: true },
  { id: "convocation", label: "Apporter la présente convocation", defaut: true },
  { id: "arrivee_avance", label: "Se présenter en avance (délai ci-dessous)", defaut: true },
  { id: "materiel", label: "Matériel spécifique à apporter", defaut: false },
  { id: "calculatrice_ok", label: "Calculatrice autorisée", defaut: false },
  { id: "calculatrice_ko", label: "Calculatrice interdite", defaut: false },
  { id: "telephone_ko", label: "Téléphone éteint et rangé pendant l'épreuve", defaut: true },
  { id: "documents_ok", label: "Documents autorisés (préciser)", defaut: false },
  { id: "documents_ko", label: "Aucun document personnel autorisé", defaut: false },
  { id: "tenue", label: "Consignes vestimentaires / EPI", defaut: false },
  { id: "securite", label: "Consignes de sécurité du site", defaut: false },
] as const;

/** Blocs d'information activables (jury). */
export const INFOS_JURY = [
  { id: "piece_identite", label: "Pièce d'identité en cours de validité", defaut: true },
  { id: "convocation", label: "Apporter la présente convocation", defaut: true },
  { id: "nb_candidats", label: "Nombre de candidats à évaluer", defaut: true },
  { id: "liste_candidats", label: "Liste nominative des candidats", defaut: false },
  { id: "duree_par_candidat", label: "Durée moyenne par candidat", defaut: true },
  { id: "grille", label: "Grille d'évaluation fournie sur place", defaut: true },
  { id: "documents_signer", label: "Documents à signer (émargement, PV)", defaut: true },
  { id: "remuneration", label: "Rémunération / indemnisation", defaut: false },
  { id: "frais", label: "Frais de déplacement", defaut: false },
  { id: "epi", label: "Équipements de protection individuelle", defaut: false },
] as const;

/** Contenu complet d'une convocation : le snapshot stocké en base
 *  (payload jsonb) et la source unique des templates PDF + aperçu. */
export interface ConvocationPayload {
  kind: ConvocationKind;
  reference: string;
  destinataire: {
    civilite: "Monsieur" | "Madame" | "";
    nom: string;
    prenom: string;
    identifiant?: string;
    email?: string;
    telephone?: string;
    /** Jury uniquement */
    fonction?: string;
    organisation?: string;
    role_jury?: string;
  };
  formation: { titre: string; certification?: string; bloc?: string };
  session: { label: string; debut?: string; fin?: string; groupe?: string };
  epreuve: { type: string; intitule: string };
  horaires: {
    date: string;              // ISO yyyy-mm-dd
    convocation?: string;      // "08:45"
    debut: string;             // "09:00"
    fin?: string;
    duree?: string;            // "1 h 30"
    arrivee_minutes?: number;  // se présenter X minutes avant
    pause?: string;            // jury
  };
  lieu: {
    nom: string; adresse: string; code_postal: string; ville: string;
    salle?: string; etage?: string; acces?: string;
  };
  /** Consignes cochées (ids de CONSIGNES_CANDIDAT / INFOS_JURY). */
  consignes: string[];
  /** Précisions texte associées à certaines consignes. */
  details: {
    materiel?: string; documents_ok?: string; tenue?: string; securite?: string;
    nb_candidats?: string; liste_candidats?: string; duree_par_candidat?: string;
    remuneration?: string; frais?: string;
  };
  remarques?: string;
  signataire: { fonction: string; nom: string };
  contact: { telephone: string; email: string };
}

export interface ConvocationRow {
  id: string;
  kind: ConvocationKind;
  status: ConvocationStatus;
  reference: string;
  payload: ConvocationPayload;
  template: ConvocationTemplate;
  file_name: string;
  session_label: string | null;
  exam_date: string | null;
  batch_id: string | null;
  created_at: string;
  updated_at: string;
}

/* ── Helpers ────────────────────────────────────────────────────────── */

const sansAccents = (s: string) =>
  s.normalize("NFD").replace(/[̀-ͯ]/g, "");

/** `Convocation_Jean_Dupont_15-09-2026.pdf` / `Convocation_Jury_Martin_...` */
export function buildFileName(p: ConvocationPayload): string {
  const qui = [p.destinataire.prenom, p.destinataire.nom]
    .filter(Boolean)
    .map((s) => sansAccents(s).replace(/[^A-Za-z0-9-]+/g, "-").replace(/^-|-$/g, ""))
    .join("_") || "Destinataire";
  const date = p.horaires.date
    ? p.horaires.date.split("-").reverse().join("-")
    : "date";
  const prefix = p.kind === "jury" ? "Convocation_Jury" : "Convocation";
  return `${prefix}_${qui}_${date}.pdf`;
}

/** Référence courte lisible : CONV-CAND-20260915-A7K2 */
export function buildReference(kind: ConvocationKind, dateIso: string): string {
  const d = (dateIso || "").replace(/-/g, "") || "00000000";
  const rand = Math.random().toString(36).slice(2, 6).toUpperCase();
  return `CONV-${kind === "jury" ? "JURY" : "CAND"}-${d}-${rand}`;
}

export function formatDateFr(iso: string | null | undefined): string {
  if (!iso) return "";
  const d = new Date(iso + "T12:00:00");
  if (Number.isNaN(d.getTime())) return iso;
  return d.toLocaleDateString("fr-FR", {
    weekday: "long", day: "numeric", month: "long", year: "numeric",
  });
}

export function formatHeure(h: string | undefined): string {
  if (!h) return "";
  const [hh, mm] = h.split(":");
  return `${hh} h ${mm ?? "00"}`;
}

/** « Session septembre 2026 » saisi tel quel : ne pas re-préfixer. */
export function sessionText(label: string): string {
  return /^\s*session/i.test(label) ? label : `Session ${label}`;
}

/** Salutation de lettre : « Monsieur, » plutôt que « M., ». */
export function civiliteLongue(civilite: string | null | undefined): string {
  const c = (civilite ?? "").trim().toLowerCase();
  if (c === "m." || c === "m" || c === "monsieur") return "Monsieur";
  if (c === "mme" || c === "madame") return "Madame";
  return "Madame, Monsieur";
}

/** Ajoute des minutes à une heure "HH:MM" (planning automatique). */
export function addMinutes(heure: string, minutes: number): string {
  const [h, m] = heure.split(":").map(Number);
  const total = (h * 60 + m + minutes + 24 * 60) % (24 * 60);
  return `${String(Math.floor(total / 60)).padStart(2, "0")}:${String(total % 60).padStart(2, "0")}`;
}

/** Planning auto de la génération en masse : créneaux successifs
 *  (heure de début, durée par candidat, pause entre candidats). */
export function computeSchedule(
  premierCreneau: string,
  dureeMinutes: number,
  pauseMinutes: number,
  nombre: number,
): Array<{ debut: string; fin: string }> {
  const slots: Array<{ debut: string; fin: string }> = [];
  let debut = premierCreneau;
  for (let i = 0; i < nombre; i++) {
    const fin = addMinutes(debut, dureeMinutes);
    slots.push({ debut, fin });
    debut = addMinutes(fin, pauseMinutes);
  }
  return slots;
}

/** Contenu affichable résolu depuis un payload : partagé entre les
 *  templates PDF (serveur) et l'aperçu temps réel (client). */
export interface ResolvedConvocation {
  titreDoc: string;
  sousTitre: string;
  destinataireLignes: string[];
  consignes: Array<{ label: string; detail?: string }>;
  infosGrid: Array<{ label: string; lines: string[] }>;
}

export function resolveConvocation(p: ConvocationPayload): ResolvedConvocation {
  const jury = p.kind === "jury";
  const dico = jury ? INFOS_JURY : CONSIGNES_CANDIDAT;
  const consignes: ResolvedConvocation["consignes"] = [];
  for (const c of dico) {
    if (!p.consignes.includes(c.id)) continue;
    if (c.id === "arrivee_avance" && p.horaires.arrivee_minutes) {
      consignes.push({ label: `Se présenter ${p.horaires.arrivee_minutes} minutes avant le début de l'épreuve` });
      continue;
    }
    const detail = (p.details as Record<string, string | undefined>)[c.id];
    consignes.push({ label: c.label, detail: detail || undefined });
  }

  const d = p.destinataire;
  const destinataireLignes = [
    [d.civilite, d.prenom, d.nom].filter(Boolean).join(" "),
    jury && d.fonction ? d.fonction : "",
    jury && d.organisation ? d.organisation : "",
    jury && d.role_jury ? `Rôle : ${d.role_jury}` : "",
    !jury && d.identifiant ? `Identifiant candidat : ${d.identifiant}` : "",
    d.email ?? "",
    d.telephone ?? "",
  ].filter(Boolean);

  const horaireLines: string[] = [];
  if (p.horaires.convocation) horaireLines.push(`Convocation : ${formatHeure(p.horaires.convocation)}`);
  horaireLines.push(`Début : ${formatHeure(p.horaires.debut)}`);
  if (p.horaires.fin) horaireLines.push(`Fin prévue : ${formatHeure(p.horaires.fin)}`);
  if (p.horaires.duree) horaireLines.push(`Durée : ${p.horaires.duree}`);
  if (jury && p.horaires.pause) horaireLines.push(`Pause : ${p.horaires.pause}`);

  const lieuLines = [
    p.lieu.nom,
    p.lieu.adresse,
    `${p.lieu.code_postal} ${p.lieu.ville}`.trim(),
    p.lieu.salle ? `Salle : ${p.lieu.salle}${p.lieu.etage ? ` (${p.lieu.etage})` : ""}` : "",
    p.lieu.acces ?? "",
  ].filter(Boolean);

  return {
    titreDoc: "CONVOCATION",
    sousTitre: jury ? "Membre du jury d'examen" : "Candidat à l'examen",
    destinataireLignes,
    consignes,
    infosGrid: [
      { label: "Date", lines: [formatDateFr(p.horaires.date) || "Date à définir"] },
      { label: "Horaires", lines: horaireLines },
      { label: "Lieu", lines: lieuLines.length ? lieuLines : ["Lieu à définir"] },
    ],
  };
}

/** Payload vierge prérempli avec les valeurs du centre. */
export function emptyPayload(kind: ConvocationKind): ConvocationPayload {
  return {
    kind,
    reference: "",
    destinataire: { civilite: "", nom: "", prenom: "" },
    formation: { titre: "" },
    session: { label: "" },
    epreuve: { type: kind === "jury" ? "Session d'examen" : "Épreuve écrite", intitule: "" },
    horaires: { date: "", debut: "09:00", arrivee_minutes: 15 },
    lieu: { nom: "", adresse: "", code_postal: "", ville: "" },
    consignes: (kind === "jury" ? INFOS_JURY : CONSIGNES_CANDIDAT)
      .filter((c) => c.defaut)
      .map((c) => c.id),
    details: {},
    signataire: { fonction: "Le responsable de session", nom: "" },
    contact: { telephone: "01 60 09 54 47", email: "contact@maformationtransport.fr" },
  };
}
