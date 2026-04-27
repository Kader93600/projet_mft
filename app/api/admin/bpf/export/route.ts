import { NextResponse } from "next/server";
import { isStaff } from "@/lib/permissions";
import { createClient } from "@/lib/supabase/server";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

function csvEscape(v: any): string {
  if (v === null || v === undefined) return "";
  const s = String(v);
  return /[",\n;]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
}

function toCsv(rows: Record<string, any>[]): string {
  if (rows.length === 0) return "";
  const headers = Object.keys(rows[0]);
  const lines = [headers.join(";")];
  for (const r of rows) {
    lines.push(headers.map((h) => csvEscape(r[h])).join(";"));
  }
  // BOM UTF-8 pour Excel FR
  return "﻿" + lines.join("\n");
}

export async function GET(req: Request) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: "unauth" }, { status: 401 });
  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .single();
  if (!isStaff(profile?.role)) {
    return NextResponse.json({ error: "forbidden" }, { status: 403 });
  }

  const url = new URL(req.url);
  const year = Number(url.searchParams.get("year") ?? new Date().getFullYear() - 1);
  const type = url.searchParams.get("type") ?? "stagiaires";

  let rows: Record<string, any>[] = [];
  let filename = "bpf.csv";

  if (type === "stagiaires") {
    const { data } = await supabase.rpc("bpf_hours_for_year", { p_year: year });
    rows = (data ?? []).map((r: any) => ({
      email: r.email,
      nom_complet: r.full_name ?? "",
      heures_realisees: Number(r.hours_done ?? 0).toFixed(2),
    }));
    filename = `bpf-stagiaires-${year}.csv`;
  } else if (type === "recettes") {
    const { data } = await supabase
      .from("bpf_revenue_by_funder")
      .select("*")
      .eq("year", year);
    rows = (data ?? []).map((r: any) => ({
      type_financement: r.funding_kind,
      financeur: r.funder_name,
      stagiaires: r.stagiaires_count,
      recette_eur: ((r.revenue_cents ?? 0) / 100).toFixed(2),
    }));
    filename = `bpf-recettes-${year}.csv`;
  } else {
    return NextResponse.json({ error: "unknown_type" }, { status: 400 });
  }

  const csv = toCsv(rows);
  return new NextResponse(csv, {
    status: 200,
    headers: {
      "Content-Type": "text/csv; charset=utf-8",
      "Content-Disposition": `attachment; filename="${filename}"`,
      "Cache-Control": "no-store",
    },
  });
}
