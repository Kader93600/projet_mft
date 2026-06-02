import type { NextRequest } from "next/server";
import ExcelJS from "exceljs";
import { requireAdmin } from "@/lib/admin-guard";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * Export XLSX des utilisateurs, respectant les filtres de la liste :
 *   ?q=...        recherche nom/email (ILIKE, base entière)
 *   ?role=...     student | trainer | admin | super_admin
 *   ?group=...    <uuid> | none (sans classe)
 *   ?status=...   active | disabled
 * Inclut l'identité complète (prénom, nom, adresse…) + stats agrégées.
 * Réservé admin.
 */
export async function GET(req: NextRequest) {
  const { supabase } = await requireAdmin();
  const sp = req.nextUrl.searchParams;
  const q = (sp.get("q") ?? "").trim();
  const role = sp.get("role") ?? "all";
  const group = sp.get("group") ?? "all";
  const status = sp.get("status") ?? "all";

  // ── Requête profils, filtres serveur (toute la base, pas la page) ──
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

  // ── Stats quiz agrégées pour les utilisateurs exportés ──
  const ids = (users ?? []).map((u: any) => u.id);
  const statsByUser = new Map<
    string,
    { count: number; avg: number; passed: number }
  >();
  if (ids.length > 0) {
    const { data: attempts } = await supabase
      .from("quiz_attempts")
      .select("user_id, percentage, passed")
      .in("user_id", ids);
    (attempts ?? []).forEach((a: any) => {
      const cur =
        statsByUser.get(a.user_id) ?? { count: 0, avg: 0, passed: 0 };
      cur.count++;
      cur.avg = (cur.avg * (cur.count - 1) + (a.percentage || 0)) / cur.count;
      if (a.passed) cur.passed++;
      statsByUser.set(a.user_id, cur);
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
  const fmtDate = (d: string | null) => {
    if (!d) return "";
    try {
      return new Date(d).toLocaleDateString("fr-FR");
    } catch {
      return "";
    }
  };
  const fmtDateTime = (d: string | null) => {
    if (!d) return "";
    try {
      return new Date(d).toLocaleString("fr-FR", {
        dateStyle: "short",
        timeStyle: "short",
      });
    } catch {
      return "";
    }
  };

  // ── Construction du classeur ──
  const wb = new ExcelJS.Workbook();
  wb.creator = "MA FORMATION TRANSPORT";
  wb.created = new Date();
  const ws = wb.addWorksheet("Utilisateurs", {
    views: [{ state: "frozen", ySplit: 1 }],
  });

  ws.columns = [
    { header: "Prénom", key: "first_name", width: 18 },
    { header: "Nom", key: "last_name", width: 20 },
    { header: "Nom complet", key: "full_name", width: 26 },
    { header: "Email", key: "email", width: 30 },
    { header: "Téléphone", key: "phone", width: 16 },
    { header: "Date de naissance", key: "date_naissance", width: 16 },
    { header: "Adresse", key: "adresse", width: 30 },
    { header: "Code postal", key: "code_postal", width: 12 },
    { header: "Ville", key: "ville", width: 20 },
    { header: "Pays", key: "pays", width: 14 },
    { header: "Rôle", key: "role", width: 18 },
    { header: "Niveau", key: "level", width: 14 },
    { header: "Classe", key: "classe", width: 20 },
    { header: "Statut", key: "statut", width: 12 },
    { header: "Quiz tentés", key: "quiz_count", width: 12 },
    { header: "Quiz réussis", key: "quiz_passed", width: 12 },
    { header: "Score moyen (%)", key: "avg_score", width: 16 },
    { header: "Inscrit le", key: "created_at", width: 14 },
    { header: "Dernière connexion", key: "last_sign_in_at", width: 18 },
  ];

  // En-tête stylé (navy + texte clair).
  const headerRow = ws.getRow(1);
  headerRow.font = { bold: true, color: { argb: "FFFFFFFF" }, size: 11 };
  headerRow.alignment = { vertical: "middle", horizontal: "left" };
  headerRow.height = 22;
  headerRow.eachCell((cell) => {
    cell.fill = {
      type: "pattern",
      pattern: "solid",
      fgColor: { argb: "FF0E1240" },
    };
  });

  // Anti formula-injection : neutralise les cellules texte commençant par
  // = + - @ (interprétées comme formules par Excel).
  const safe = (v: any) => {
    if (v === null || v === undefined) return "";
    const s = String(v);
    return /^[=+\-@\t\r]/.test(s) ? "'" + s : s;
  };

  for (const u of (users ?? []) as any[]) {
    const s = statsByUser.get(u.id);
    ws.addRow({
      first_name: safe(u.first_name ?? ""),
      last_name: safe(u.last_name ?? ""),
      full_name: safe(u.full_name ?? ""),
      email: safe(u.email ?? ""),
      phone: safe(u.phone ?? ""),
      date_naissance: fmtDate(u.date_naissance),
      adresse: safe(u.adresse ?? ""),
      code_postal: safe(u.code_postal ?? ""),
      ville: safe(u.ville ?? ""),
      pays: safe(u.pays ?? ""),
      role: ROLE_LABEL[u.role] ?? u.role ?? "",
      level: LEVEL_LABEL[u.level] ?? u.level ?? "",
      classe: safe(u.groups?.name ?? ""),
      statut: u.disabled ? "Désactivé" : "Actif",
      quiz_count: s?.count ?? 0,
      quiz_passed: s?.passed ?? 0,
      avg_score: Math.round(s?.avg ?? 0),
      created_at: fmtDate(u.created_at),
      last_sign_in_at: fmtDateTime(u.last_sign_in_at),
    });
  }

  // Filtre auto sur toute la plage + bordure légère sur l'en-tête.
  const lastCol = ws.columnCount;
  ws.autoFilter = {
    from: { row: 1, column: 1 },
    to: { row: 1, column: lastCol },
  };

  const buffer = await wb.xlsx.writeBuffer();
  const filename = `utilisateurs-${new Date().toISOString().slice(0, 10)}.xlsx`;

  return new Response(buffer, {
    headers: {
      "Content-Type":
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      "Content-Disposition": `attachment; filename="${filename}"; filename*=UTF-8''${encodeURIComponent(filename)}`,
      "Cache-Control": "no-store",
    },
  });
}
