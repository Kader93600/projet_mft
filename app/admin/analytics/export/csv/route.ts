// Export CSV (Excel-compatible) des tendances analytics — staff only.
import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { isStaff } from "@/lib/permissions";
import { toCsv, csvHeaders } from "@/lib/csv";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function GET() {
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
  if (!me?.role || !isStaff(me.role)) {
    return NextResponse.json({ error: "forbidden" }, { status: 403 });
  }

  const { data: trends } = await supabase
    .from("vw_admin_trends_30d")
    .select("day, signups, quiz_attempts, payments")
    .order("day");

  const rows = (trends ?? []).map((r: any) => ({
    Date: r.day,
    Inscriptions: r.signups ?? 0,
    "Tentatives quiz": r.quiz_attempts ?? 0,
    Paiements: r.payments ?? 0,
  }));

  // BOM UTF-8 pour qu'Excel affiche correctement les accents.
  const csv = "﻿" + toCsv(rows);
  return new NextResponse(csv, {
    headers: csvHeaders("analytics-tendances-30j.csv"),
  });
}
