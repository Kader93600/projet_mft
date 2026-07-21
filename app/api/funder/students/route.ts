// =====================================================================
// GET /api/funder/students
//
// Liste des stagiaires du financeur (filtrable + paginée).
// Query params :
//   status   : filtrer par status (en_cours, termine, …) — optional
//   q        : recherche full_name / email — optional
//   limit    : default 50
//   offset   : default 0
// =====================================================================

import { NextRequest, NextResponse } from "next/server";
import { sanitizeSearchTerm } from "@/lib/search";
import { createClient } from "@/lib/supabase/server";
import { getFunderAccess } from "@/lib/funder/access";
import { captureException } from "@/lib/observability";

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
  const status = url.searchParams.get("status");
  const q = url.searchParams.get("q");
  const limit = Math.min(
    Math.max(Number(url.searchParams.get("limit") ?? "50"), 1),
    200
  );
  const offset = Math.max(Number(url.searchParams.get("offset") ?? "0"), 0);

  const supabase = await createClient();
  let query = supabase
    .from("funder_student_details")
    .select("*", { count: "exact" })
    .order("enrollment_created_at", { ascending: false });

  if (access.funder_id) {
    query = query.eq("funder_id", access.funder_id);
  }
  if (status) {
    query = query.eq("status", status);
  }
  if (q) {
    const safe = sanitizeSearchTerm(q);
    if (safe)
      query = query.or(`full_name.ilike.%${safe}%,email.ilike.%${safe}%`);
  }

  const { data, error, count } = await query.range(offset, offset + limit - 1);
  if (error) {
    await captureException(error, { tags: { route: "funder/students" } });
    return NextResponse.json({ error: "fetch_failed" }, { status: 500 });
  }

  return NextResponse.json({
    students: data ?? [],
    total: count ?? 0,
    limit,
    offset,
  });
}
