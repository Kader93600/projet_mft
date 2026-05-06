import { NextResponse } from "next/server";
import { requireAdmin } from "@/lib/admin-guard";
import { toCsv, csvHeaders, fmtDateTime } from "@/lib/csv";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * Export CSV des utilisateurs.
 * Inclut nom, email, rôle, statut compte, dates, stats agrégées.
 * Réservé admin.
 */
export async function GET() {
  const { supabase } = await requireAdmin();

  const [{ data: users, error }, { data: attempts }] = await Promise.all([
    supabase
      .from("profiles")
      .select(
        "id, full_name, email, role, level, group_id, disabled, created_at, last_sign_in_at, groups(name)"
      )
      .order("created_at", { ascending: false }),
    supabase.from("quiz_attempts").select("user_id, percentage, passed"),
  ]);

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  const stats = new Map<string, { count: number; avg: number; passed: number }>();
  (attempts ?? []).forEach((a: any) => {
    const cur = stats.get(a.user_id) ?? { count: 0, avg: 0, passed: 0 };
    cur.count++;
    cur.avg = (cur.avg * (cur.count - 1) + (a.percentage || 0)) / cur.count;
    if (a.passed) cur.passed++;
    stats.set(a.user_id, cur);
  });

  const rows = (users ?? []).map((u: any) => {
    const s = stats.get(u.id);
    return {
      "Nom complet": u.full_name ?? "",
      Email: u.email ?? "",
      Rôle: u.role ?? "",
      Niveau: u.level ?? "",
      Classe: u.groups?.name ?? "",
      Statut: u.disabled ? "Désactivé" : "Actif",
      "Quiz tentés": s?.count ?? 0,
      "Quiz réussis": s?.passed ?? 0,
      "Score moyen (%)": Math.round(s?.avg ?? 0),
      "Inscrit le": fmtDateTime(u.created_at),
      "Dernière connexion": fmtDateTime(u.last_sign_in_at),
    };
  });

  const csv = toCsv(rows);
  const filename = `utilisateurs-${new Date().toISOString().slice(0, 10)}.csv`;
  return new Response(csv, { headers: csvHeaders(filename) });
}
