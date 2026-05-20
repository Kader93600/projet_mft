// =====================================================================
// Export comptable — journal des ventes (sales journal).
//
// Logique PURE (testable, sans dépendance Supabase) : transforme des
// lignes d'inscription enrichies en lignes de journal pour l'expert-
// comptable, et calcule les totaux. La route API se contente de lire
// les données puis d'appeler ces fonctions + lib/csv.
//
// NB : ce n'est PAS un FEC (Fichier des Écritures Comptables) au sens
// réglementaire strict — c'est un journal des ventes lisible et fiable.
// Un vrai FEC (18 colonnes normalisées, écritures débit/crédit) pourra
// être dérivé de ces données dans un second temps.
// =====================================================================

/** Ligne d'inscription enrichie (telle que lue depuis la DB via embeds). */
export interface EnrollmentForAccounting {
  created_at: string | null;
  start_date: string | null;
  status: string | null;
  funding_kind: string | null;
  pack: string | null;
  total_amount_cents: number | null;
  paid_amount_cents: number | null;
  formation_title: string | null;
  funder_name: string | null;
  student_name: string | null;
  student_email: string | null;
}

/** Ligne du journal des ventes (toutes valeurs en string, prêtes pour CSV). */
export interface SalesJournalRow {
  date: string;
  stagiaire: string;
  email: string;
  formation: string;
  pack: string;
  mode_financement: string;
  financeur: string;
  montant_total_eur: string;
  montant_paye_eur: string;
  reste_du_eur: string;
  statut: string;
}

/** Colonnes du CSV, dans l'ordre, avec en-têtes lisibles. */
export const SALES_JOURNAL_COLUMNS: { key: keyof SalesJournalRow; header: string }[] =
  [
    { key: "date", header: "date" },
    { key: "stagiaire", header: "stagiaire" },
    { key: "email", header: "email" },
    { key: "formation", header: "formation" },
    { key: "pack", header: "pack" },
    { key: "mode_financement", header: "mode_financement" },
    { key: "financeur", header: "financeur" },
    { key: "montant_total_eur", header: "montant_total_eur" },
    { key: "montant_paye_eur", header: "montant_paye_eur" },
    { key: "reste_du_eur", header: "reste_du_eur" },
    { key: "statut", header: "statut" },
  ];

const FUNDING_LABEL: Record<string, string> = {
  cpf: "CPF",
  opco: "OPCO",
  pole_emploi: "France Travail",
  employeur: "Employeur",
  transitions_pro: "Transitions Pro",
  auto: "Auto-financement",
};

/** Convertit des centimes en euros formatés "1234.50" (point décimal). */
export function centsToEuro(cents: number | null | undefined): string {
  return ((cents ?? 0) / 100).toFixed(2);
}

/** Mappe une inscription vers une ligne de journal. */
export function toSalesJournalRow(e: EnrollmentForAccounting): SalesJournalRow {
  const total = e.total_amount_cents ?? 0;
  const paid = e.paid_amount_cents ?? 0;
  const rawDate = e.created_at ?? e.start_date ?? "";
  return {
    date: rawDate ? rawDate.slice(0, 10) : "",
    stagiaire: e.student_name ?? "",
    email: e.student_email ?? "",
    formation: e.formation_title ?? "",
    pack: e.pack ?? "",
    mode_financement:
      FUNDING_LABEL[e.funding_kind ?? ""] ?? e.funding_kind ?? "",
    financeur: e.funder_name ?? "",
    montant_total_eur: centsToEuro(total),
    montant_paye_eur: centsToEuro(paid),
    reste_du_eur: centsToEuro(total - paid),
    statut: e.status ?? "",
  };
}

export function buildSalesJournal(
  rows: EnrollmentForAccounting[],
): SalesJournalRow[] {
  return rows.map(toSalesJournalRow);
}

export interface SalesJournalSummary {
  count: number;
  totalEur: string;
  paidEur: string;
  dueEur: string;
}

/** Totaux du journal (sur les montants déjà formatés en euros). */
export function summarizeSalesJournal(
  rows: SalesJournalRow[],
): SalesJournalSummary {
  let total = 0;
  let paid = 0;
  for (const r of rows) {
    total += Number(r.montant_total_eur) || 0;
    paid += Number(r.montant_paye_eur) || 0;
  }
  return {
    count: rows.length,
    totalEur: total.toFixed(2),
    paidEur: paid.toFixed(2),
    dueEur: (total - paid).toFixed(2),
  };
}
