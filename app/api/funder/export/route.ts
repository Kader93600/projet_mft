// =====================================================================
// GET /api/funder/export?format=csv|json
//
// Export du portfolio du financeur (anonymisable côté Démarches
// Simplifiées). PDF non géré ici (utilise /api/admin/bpf/export ou
// page dédiée avec @react-pdf/renderer).
// =====================================================================

import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { getFunderAccess } from "@/lib/funder/access";
import type { Views } from "@/lib/database.types";

type FunderStudentRow = Views<"funder_student_details">;

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function GET(req: NextRequest) {
  const access = await getFunderAccess();
  if (!access.allowed) {
    return NextResponse.json(
      { error: "forbidden", reason: access.reason },
      { status: 403 }
    );
  }

  const url = new URL(req.url);
  const format = (url.searchParams.get("format") ?? "csv").toLowerCase();
  if (format !== "csv" && format !== "json") {
    return NextResponse.json(
      { error: "invalid_format", message: "Use csv or json." },
      { status: 400 }
    );
  }

  const supabase = createClient();
  let query = supabase
    .from("funder_student_details")
    .select("*")
    .order("enrollment_created_at", { ascending: false });

  if (access.funder_id) {
    query = query.eq("funder_id", access.funder_id);
  }

  const { data, error } = await query;
  if (error) {
    return NextResponse.json(
      { error: "fetch_failed", message: error.message },
      { status: 500 }
    );
  }

  const rows = (data ?? []) as FunderStudentRow[];
  const today = new Date().toISOString().slice(0, 10);
  const filename = `mft-financeur-${today}.${format}`;

  if (format === "json") {
    const payload = {
      generated_at: new Date().toISOString(),
      funder_id: access.funder_id,
      funder_name: access.funder_name,
      total_students: rows.length,
      students: rows.map((r) => ({
        user_id: r.user_id,
        full_name: r.full_name,
        email: r.email,
        formation: r.formation_title,
        pack: r.pack,
        status: r.status,
        enrollment_created_at: r.enrollment_created_at,
        lessons_done: r.lessons_done,
        lessons_total: r.lessons_total,
        progress_pct:
          (r.lessons_total ?? 0) > 0
            ? Math.round(((r.lessons_done ?? 0) / (r.lessons_total as number)) * 100)
            : 0,
        avg_score: r.avg_score,
        mock_exam_attempted: r.mock_exam_attempted,
        certified: r.certified,
        last_active_at: r.last_active_at,
        amount_paid_cents: r.paid_amount_cents,
        amount_total_cents: r.total_amount_cents,
      })),
    };
    return new NextResponse(JSON.stringify(payload, null, 2), {
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Content-Disposition": `attachment; filename="${filename}"`,
      },
    });
  }

  // CSV
  const headers = [
    "nom_complet",
    "email",
    "formation",
    "pack",
    "statut",
    "inscription",
    "lecons_faites",
    "lecons_total",
    "progression_pct",
    "score_moyen",
    "examen_blanc",
    "certifie",
    "derniere_activite",
    "montant_paye_cts",
    "montant_total_cts",
  ];

  const escape = (v: unknown): string => {
    if (v === null || v === undefined) return "";
    let s = String(v);
    // Protection anti formula-injection (OWASP)
    if (/^[=+\-@\t\r]/.test(s)) s = "'" + s;
    if (/[",\n\r]/.test(s)) return `"${s.replace(/"/g, '""')}"`;
    return s;
  };

  const lines = [headers.join(",")];
  for (const r of rows) {
    const progress =
      (r.lessons_total ?? 0) > 0
        ? Math.round(((r.lessons_done ?? 0) / (r.lessons_total as number)) * 100)
        : 0;
    lines.push(
      [
        escape(r.full_name),
        escape(r.email),
        escape(r.formation_title),
        escape(r.pack),
        escape(r.status),
        escape(r.enrollment_created_at?.slice(0, 10)),
        escape(r.lessons_done),
        escape(r.lessons_total),
        escape(progress),
        escape(r.avg_score),
        escape(r.mock_exam_attempted ? "oui" : "non"),
        escape(r.certified ? "oui" : "non"),
        escape(r.last_active_at?.slice(0, 10)),
        escape(r.paid_amount_cents),
        escape(r.total_amount_cents),
      ].join(",")
    );
  }

  // BOM UTF-8 (﻿) pour qu'Excel affiche correctement les accents,
  // + séparateur de ligne RFC 4180 (\r\n).
  return new NextResponse("﻿" + lines.join("\r\n"), {
    headers: {
      "Content-Type": "text/csv; charset=utf-8",
      "Content-Disposition": `attachment; filename="${filename}"`,
    },
  });
}
