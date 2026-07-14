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
import type { Tables } from "@/lib/database.types";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/** Ligne renvoyée par le `select` ci-dessous (colonnes + 2 embeds to-one). */
type DocRow = Pick<
  Tables<"student_documents">,
  | "title"
  | "reason"
  | "custom_reason"
  | "status"
  | "file_name"
  | "size_bytes"
  | "created_at"
  | "admin_note"
> & {
  profiles: Pick<Tables<"profiles">, "full_name" | "email"> | null;
  formations: Pick<Tables<"formations">, "title"> | null;
};

/** DOC_STATUS est indexé par un statut libre côté BDD (colonne `text`). */
const DOC_STATUS_BY_KEY: Record<
  string,
  { label: string; tone: string } | undefined
> = DOC_STATUS;

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
  const role = (me as Pick<Tables<"profiles">, "role"> | null)?.role;
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

  // `overrideTypes` (API officielle supabase-js, compile-time uniquement) :
  // le client n'étant pas typé globalement, les embeds `profiles`/`formations`
  // sont inférés comme des tableaux alors qu'il s'agit de relations to-one.
  const { data } = await query.overrideTypes<DocRow[], { merge: false }>();
  let docs: DocRow[] = data ?? [];
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
    Statut: DOC_STATUS_BY_KEY[d.status]?.label ?? d.status,
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
