import type { NextRequest } from "next/server";
import { requireAdmin } from "@/lib/admin-guard";
import { toCsv, csvHeaders, fmtDate, fmtDateTime } from "@/lib/csv";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * Export CSV des utilisateurs, respectant les filtres de la liste :
 *   ?q=...      recherche nom/email (ILIKE, base entière)
 *   ?role=...   student | trainer | admin | super_admin
 *   ?group=...  <uuid> | none (sans classe)
 *   ?status=... active | disabled
 * Inclut l'identité complète + stats agrégées. Réservé admin.
 */
export async function GET(req: NextRequest) {
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
  const sp = req.nextUrl.searchParams;
  const q = (sp.get("q") ?? "").trim();
  const role = sp.get("role") ?? "all";
  const group = sp.get("group") ?? "all";
  const status = sp.get("status") ?? "all";

  let query = supabase
    .from("profiles")
    .select(
      "id, full_name, first_name, last_name, email, phone, role, level, " +
        "date_naissance, adresse, code_postal, ville, pays, disabled, " +
        "created_at, last_sign_in_at, group_id, groups(name)"
    )
    .order("created_at", { ascending: false });

  if (q) {
    const safe = q.replace(/[%_]/g, "\\$&");
    query = query.or(`email.ilike.%${safe}%,full_name.ilike.%${safe}%`);
  }
  if (["student", "trainer", "admin", "super_admin"].includes(role)) {
    query = query.eq("role", role);
  }
  if (group === "none") query = query.is("group_id", null);
  else if (group !== "all" && group) query = query.eq("group_id", group);
  if (status === "active") query = query.eq("disabled", false);
  else if (status === "disabled") query = query.eq("disabled", true);

  const { data: users, error } = await query;
  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }

  const userIds = (users ?? []).map((u: any) => u.id);
  const stats = new Map<string, { count: number; avg: number; passed: number }>();
  if (userIds.length > 0) {
    const { data: attempts } = await supabase
      .from("quiz_attempts")
      .select("user_id, percentage, passed")
      .in("user_id", userIds);
    (attempts ?? []).forEach((a: any) => {
      const cur = stats.get(a.user_id) ?? { count: 0, avg: 0, passed: 0 };
      cur.count++;
      cur.avg = (cur.avg * (cur.count - 1) + (a.percentage || 0)) / cur.count;
      if (a.passed) cur.passed++;
      stats.set(a.user_id, cur);
    });
  }

  const ROLE_LABEL: Record<string, string> = {
    student: "Stagiaire",
    trainer: "Formateur",
    admin: "Administrateur",
    super_admin: "Super administrateur",
  };
  const LEVEL_LABEL: Record<string, string> = {
    debutant: "Débutant",
    intermediaire: "Intermédiaire",
    avance: "Avancé",
  };

  const rows = (users ?? []).map((u: any) => {
    const s = stats.get(u.id);
    return {
      Prénom: u.first_name ?? "",
      Nom: u.last_name ?? "",
      "Nom complet": u.full_name ?? "",
      Email: u.email ?? "",
      Téléphone: u.phone ?? "",
      "Date de naissance": fmtDate(u.date_naissance),
      Adresse: u.adresse ?? "",
      "Code postal": u.code_postal ?? "",
      Ville: u.ville ?? "",
      Pays: u.pays ?? "",
      Rôle: ROLE_LABEL[u.role] ?? u.role ?? "",
      Niveau: LEVEL_LABEL[u.level] ?? u.level ?? "",
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
