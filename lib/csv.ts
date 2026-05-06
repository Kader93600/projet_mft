// =====================================================================
// Helper minimaliste pour générer un CSV conforme RFC 4180
// =====================================================================
// - Sépare les valeurs par virgule
// - Échappe les cellules contenant , " \n \r en les entourant de "
//   et en doublant les " internes
// - Ajoute un BOM UTF-8 pour qu'Excel ouvre correctement les accents

export type CsvRow = Record<string, string | number | boolean | null | undefined>;

function escapeCell(v: unknown): string {
  if (v === null || v === undefined) return "";
  const s = String(v);
  if (/[",\n\r]/.test(s)) {
    return `"${s.replace(/"/g, '""')}"`;
  }
  return s;
}

export function toCsv(rows: CsvRow[], columns?: string[]): string {
  if (rows.length === 0 && !columns) return "";
  const cols = columns ?? Object.keys(rows[0] ?? {});
  const header = cols.join(",");
  const lines = rows.map((r) =>
    cols.map((c) => escapeCell(r[c])).join(",")
  );
  // BOM UTF-8 pour Excel
  return "﻿" + [header, ...lines].join("\r\n");
}

export function csvHeaders(filename: string): HeadersInit {
  // RFC 6266 — filename UTF-8 escaping
  const safe = filename.replace(/[^\w.\-]/g, "_");
  return {
    "Content-Type": "text/csv; charset=utf-8",
    "Content-Disposition": `attachment; filename="${safe}"; filename*=UTF-8''${encodeURIComponent(filename)}`,
    "Cache-Control": "no-store",
  };
}

export function fmtDate(d: string | null | undefined): string {
  if (!d) return "";
  try {
    return new Date(d).toISOString().slice(0, 10);
  } catch {
    return "";
  }
}

export function fmtDateTime(d: string | null | undefined): string {
  if (!d) return "";
  try {
    return new Date(d).toISOString().replace("T", " ").slice(0, 19);
  } catch {
    return "";
  }
}
