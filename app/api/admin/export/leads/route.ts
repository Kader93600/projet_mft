import { NextResponse } from "next/server";
import { requireAdmin } from "@/lib/admin-guard";
import { toCsv, csvHeaders, fmtDateTime } from "@/lib/csv";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * Export CSV des leads (enrollment_requests).
 * Réservé admin via requireAdmin().
 */
export async function GET() {
  const { supabase } = await requireAdmin();

  const { data, error } = await supabase
    .from("enrollment_requests")
    .select(
      "full_name, email, phone, funding_kind, message, status, created_at, formation_slug"
    )
    .order("created_at", { ascending: false });

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  const rows = (data ?? []).map((r: any) => ({
    "Nom complet": r.full_name ?? "",
    Email: r.email ?? "",
    Téléphone: r.phone ?? "",
    Financement: r.funding_kind ?? "",
    "Formation visée": r.formation_slug ?? "",
    Statut: r.status ?? "",
    Message: (r.message ?? "").replace(/\r?\n/g, " · ").slice(0, 500),
    "Reçu le": fmtDateTime(r.created_at),
  }));

  const csv = toCsv(rows);
  const filename = `leads-${new Date().toISOString().slice(0, 10)}.csv`;
  return new Response(csv, { headers: csvHeaders(filename) });
}
