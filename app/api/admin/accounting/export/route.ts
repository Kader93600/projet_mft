// =====================================================================
// GET /api/admin/accounting/export?year=YYYY
//
// Export comptable — journal des ventes (inscriptions + montants) sur
// une année, au format CSV pour l'expert-comptable. Staff uniquement.
// Lecture en service_role (export financier = doit être COMPLET, pas
// tronqué par une RLS). Logique de mapping/totaux : lib/accounting-export.
// =====================================================================

import { NextResponse } from "next/server";
import { requireAdmin } from "@/lib/admin-guard";
import { toCsv, csvHeaders } from "@/lib/csv";
import {
  buildSalesJournal,
  SALES_JOURNAL_COLUMNS,
  type EnrollmentForAccounting,
} from "@/lib/accounting-export";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function GET(req: Request) {
  let service: Awaited<ReturnType<typeof requireAdmin>>["service"];
  try {
    ({ service } = await requireAdmin());
  } catch {
    return NextResponse.json({ error: "forbidden" }, { status: 403 });
  }

  const url = new URL(req.url);
  const year = Number(
    url.searchParams.get("year") ?? new Date().getFullYear(),
  );
  if (!Number.isInteger(year) || year < 2000 || year > 2100) {
    return NextResponse.json({ error: "invalid_year" }, { status: 400 });
  }
  const from = `${year}-01-01`;
  const to = `${year}-12-31T23:59:59`;

  const { data, error } = await service
    .from("enrollments")
    .select(
      "created_at, start_date, status, funding_kind, pack, " +
        "total_amount_cents, paid_amount_cents, " +
        "formation:formations(title), funder:funders(name), " +
        "student:profiles!user_id(full_name, email)",
    )
    .gte("created_at", from)
    .lte("created_at", to)
    .order("created_at", { ascending: true });

  if (error) {
    return NextResponse.json(
      { error: "fetch_failed", message: error.message },
      { status: 500 },
    );
  }

  const enrollments: EnrollmentForAccounting[] = (data ?? []).map((e: any) => ({
    created_at: e.created_at,
    start_date: e.start_date,
    status: e.status,
    funding_kind: e.funding_kind,
    pack: e.pack,
    total_amount_cents: e.total_amount_cents,
    paid_amount_cents: e.paid_amount_cents,
    formation_title: e.formation?.title ?? null,
    funder_name: e.funder?.name ?? null,
    student_name: e.student?.full_name ?? null,
    student_email: e.student?.email ?? null,
  }));

  const rows = buildSalesJournal(enrollments);
  const csv = toCsv(
    rows as unknown as Record<string, string>[],
    SALES_JOURNAL_COLUMNS.map((c) => c.key),
  );

  return new NextResponse(csv, {
    status: 200,
    headers: csvHeaders(`journal-ventes-${year}.csv`),
  });
}
