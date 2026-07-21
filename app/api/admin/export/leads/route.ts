import { NextResponse } from "next/server";
import { requireAdmin } from "@/lib/admin-guard";
import { toCsv, csvHeaders, fmtDateTime } from "@/lib/csv";
import { captureException } from "@/lib/observability";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * Export CSV des leads (enrollment_requests).
 * Réservé admin via requireAdmin().
 */
export async function GET() {
  // 401 propre (et non 500) si non authentifié / non admin.
  let supabase: Awaited<ReturnType<typeof requireAdmin>>["supabase"];
  try {
    ({ supabase } = await requireAdmin());
  } catch {
    return new Response(JSON.stringify({ error: "unauthorized" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  const { data, error } = await supabase
    .from("enrollment_requests")
    .select(
      "full_name, email, phone, funding_kind, message, status, created_at, formation_slug"
    )
    .order("created_at", { ascending: false });

  if (error) {
    await captureException(error, { tags: { route: "admin/export/leads" } });
    return NextResponse.json({ error: "export_failed" }, { status: 500 });
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
