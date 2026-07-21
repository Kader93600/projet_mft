// =====================================================================
// GET /api/cron/data-retention
//
// Cron quotidien (Vercel Cron) : applique les durées de conservation RGPD
// via la fonction SQL public.run_data_retention_purge() (voir
// supabase/2026_07_13_data_retention_purge.sql et le registre des
// traitements). Purge uniquement les catégories « journaux / mesure » ;
// les données à contrainte légale ne sont pas touchées.
//
// Authentification : header Authorization: Bearer ${CRON_SECRET}.
// Idempotent : rejouable sans effet de bord (rien à supprimer deux fois).
// =====================================================================

import { NextResponse } from "next/server";
import { timingSafeEqualStr } from "@/lib/timing-safe";
import { createClient } from "@supabase/supabase-js";
import { captureException } from "@/lib/observability";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

const CRON_SECRET = process.env.CRON_SECRET;

export async function GET(req: Request) {
  if (!CRON_SECRET) {
    return NextResponse.json({ error: "cron_not_configured" }, { status: 500 });
  }
  const auth = req.headers.get("authorization");
  if (!timingSafeEqualStr(auth, `Bearer ${CRON_SECRET}`)) {
    return NextResponse.json({ error: "forbidden" }, { status: 403 });
  }

  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!url || !key) {
    return NextResponse.json(
      { error: "supabase_not_configured" },
      { status: 500 }
    );
  }

  const supabase = createClient(url, key, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data, error } = await supabase.rpc("run_data_retention_purge");
  if (error) {
    captureException(error, { tags: { where: "cron/data-retention" } });
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }

  return NextResponse.json({ ok: true, purged: data });
}
