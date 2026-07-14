// =====================================================================
// GET /api/tutor/quota
//
// Retourne l'état du quota mensuel du stagiaire courant pour l'UI
// (afficher un compteur "X/200 utilisés" dans le drawer, par exemple).
// =====================================================================

import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { getQuotaStatus } from "@/lib/tutor/quota";
import { getTutorAccess } from "@/lib/tutor/access";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function GET() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: "unauth" }, { status: 401 });
  }

  const access = await getTutorAccess();
  if (!access.allowed) {
    return NextResponse.json(
      { error: "forbidden", reason: access.reason },
      { status: 403 }
    );
  }

  const { data: roleData } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();
  const isStaff =
    roleData?.role === "admin" ||
    roleData?.role === "super_admin" ||
    roleData?.role === "trainer";

  const quota = await getQuotaStatus(user.id, isStaff);

  return NextResponse.json({
    used: quota.used,
    limit: quota.limit === Infinity ? null : quota.limit,
    percent: quota.percent,
    allowed: quota.allowed,
    resets_at: quota.resets_at,
    is_staff: isStaff,
  });
}
