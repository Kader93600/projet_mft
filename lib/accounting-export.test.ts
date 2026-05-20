import { describe, it, expect } from "vitest";
import {
  centsToEuro,
  toSalesJournalRow,
  buildSalesJournal,
  summarizeSalesJournal,
  type EnrollmentForAccounting,
} from "./accounting-export";

const base: EnrollmentForAccounting = {
  created_at: "2026-03-15T10:30:00Z",
  start_date: "2026-04-01",
  status: "en_cours",
  funding_kind: "cpf",
  pack: "medium",
  total_amount_cents: 150000,
  paid_amount_cents: 50000,
  formation_title: "Capacité ≤ 3,5t",
  funder_name: "Caisse des Dépôts",
  student_name: "Jean Dupont",
  student_email: "jean@example.fr",
};

describe("centsToEuro", () => {
  it("convertit les centimes en euros à 2 décimales", () => {
    expect(centsToEuro(150000)).toBe("1500.00");
    expect(centsToEuro(99)).toBe("0.99");
    expect(centsToEuro(0)).toBe("0.00");
  });
  it("tolère null/undefined → 0.00", () => {
    expect(centsToEuro(null)).toBe("0.00");
    expect(centsToEuro(undefined)).toBe("0.00");
  });
});

describe("toSalesJournalRow", () => {
  it("mappe une inscription complète", () => {
    const r = toSalesJournalRow(base);
    expect(r.date).toBe("2026-03-15"); // tronqué à la date
    expect(r.stagiaire).toBe("Jean Dupont");
    expect(r.formation).toBe("Capacité ≤ 3,5t");
    expect(r.mode_financement).toBe("CPF"); // libellé lisible
    expect(r.financeur).toBe("Caisse des Dépôts");
    expect(r.montant_total_eur).toBe("1500.00");
    expect(r.montant_paye_eur).toBe("500.00");
    expect(r.reste_du_eur).toBe("1000.00"); // total - payé
    expect(r.statut).toBe("en_cours");
  });

  it("retombe sur start_date si created_at absent", () => {
    expect(toSalesJournalRow({ ...base, created_at: null }).date).toBe(
      "2026-04-01",
    );
  });

  it("gère les champs manquants sans casser", () => {
    const r = toSalesJournalRow({
      created_at: null,
      start_date: null,
      status: null,
      funding_kind: null,
      pack: null,
      total_amount_cents: null,
      paid_amount_cents: null,
      formation_title: null,
      funder_name: null,
      student_name: null,
      student_email: null,
    });
    expect(r.date).toBe("");
    expect(r.montant_total_eur).toBe("0.00");
    expect(r.reste_du_eur).toBe("0.00");
    expect(r.mode_financement).toBe("");
  });

  it("conserve un funding_kind inconnu tel quel", () => {
    expect(
      toSalesJournalRow({ ...base, funding_kind: "mecene" }).mode_financement,
    ).toBe("mecene");
  });
});

describe("summarizeSalesJournal", () => {
  it("agrège total, payé et reste dû", () => {
    const rows = buildSalesJournal([
      base,
      { ...base, total_amount_cents: 100000, paid_amount_cents: 100000 },
    ]);
    const s = summarizeSalesJournal(rows);
    expect(s.count).toBe(2);
    expect(s.totalEur).toBe("2500.00"); // 1500 + 1000
    expect(s.paidEur).toBe("1500.00"); // 500 + 1000
    expect(s.dueEur).toBe("1000.00"); // 2500 - 1500
  });

  it("journal vide → totaux à zéro", () => {
    const s = summarizeSalesJournal([]);
    expect(s).toEqual({
      count: 0,
      totalEur: "0.00",
      paidEur: "0.00",
      dueEur: "0.00",
    });
  });
});
