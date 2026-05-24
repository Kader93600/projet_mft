// Export CSV (Excel) des documents stagiaires — staff only, filtres honorés.
import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { isStaff } from "@/lib/permissions";
import { toCsv, csvHeaders } from "@/lib/csv";
import {
  reasonLabel,
  fileKind,
  formatBytes,
  DOC_STATUS,
} from "@/lib/student-documents";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function GET(req: NextRequest) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: "unauth" }, { status: 401 });
  const { data: me } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();
  const role = (me as any)?.role;
  if (!isStaff(role) && role !== "trainer") {
    return NextResponse.json({ error: "forbidden" }, { status: 403 });
  }

  const sp = req.nextUrl.searchParams;
  const admin = createAdminClient();
  let query = admin
    .from("student_documents")
    .select(
      "title, reason, custom_reason, status, file_name, size_bytes, created_at, admin_note, profiles(full_name, email), formations(title)"
    )
    .order("created_at", { ascending: false })
    .limit(2000);
  if (sp.get("formation")) query = query.eq("formation_id", sp.get("formation")!);
  if (sp.get("motif")) query = query.eq("reason", sp.get("motif")!);
  if (sp.get("statut")) query = query.eq("status", sp.get("statut")!);

  const { data } = await query;
  let docs = (data ?? []) as any[];
  const q = sp.get("q")?.trim().toLowerCase();
  if (q) {
    docs = docs.filter((d) =>
      (d.profiles?.full_name || d.profiles?.email || "")
        .toLowerCase()
        .includes(q)
    );
  }

  const rows = docs.map((d) => ({
    Stagiaire: d.profiles?.full_name || d.profiles?.email || "",
    Formation: d.formations?.title ?? "",
    Titre: d.title,
    Motif: reasonLabel(d.reason, d.custom_reason),
    Type: fileKind(d.file_name).toUpperCase(),
    Taille: formatBytes(d.size_bytes ?? 0),
    Statut: (DOC_STATUS as any)[d.status]?.label ?? d.status,
    "Importé le": new Date(d.created_at).toLocaleString("fr-FR", {
      timeZone: "Europe/Paris",
    }),
    Remarque: d.admin_note ?? "",
  }));

  // BOM UTF-8 pour qu'Excel affiche correctement les accents.
  const csv = "﻿" + toCsv(rows);
  return new NextResponse(csv, {
    headers: csvHeaders("documents-stagiaires.csv"),
  });
}
