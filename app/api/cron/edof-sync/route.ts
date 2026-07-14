// =====================================================================
// GET /api/cron/edof-sync — synchronisation incrémentale des dossiers
// CPF depuis EDOF. INERTE tant que l'API EDOF n'est pas configurée.
//
// Auth : header Authorization: Bearer ${CRON_SECRET} (comme les autres crons).
// Flux (volume moyen → pull incrémental paginé, upsert idempotent) :
//   1. lister les dossiers EDOF maj depuis le dernier curseur
//   2. upsert dans cpf_edof_dossiers (clé : edof_dossier_id)
//   3. avancer le curseur de synchro
// La réconciliation vers enrollments (mutation de statut) est volontairement
// laissée à une étape 2 (règles métier à valider) : ce cron NE modifie PAS
// les inscriptions automatiquement.
// =====================================================================

import { NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { createEdofClient, EdofNotImplementedError } from "@/lib/edof/client";
import { isEdofConfigured, isEdofFeatureEnabled } from "@/lib/edof/config";
import type { Json } from "@/lib/database.types";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

const CRON_SECRET = process.env.CRON_SECRET;
const PAGE_SIZE = 100; // volume moyen → pagination raisonnable

/**
 * Curseur de synchro EDOF (table `edof_sync_state`, ligne singleton id=true).
 * Table absente de `supabase/schema.sql` (feature EDOF encore inerte) → pas
 * de `Tables<"edof_sync_state">` disponible : la forme lue est décrite ici.
 */
type EdofSyncStateRow = {
  last_pulled_at: string | null;
};

export async function GET(req: Request) {
  if (!CRON_SECRET) {
    return NextResponse.json({ error: "cron_not_configured" }, { status: 500 });
  }
  if (req.headers.get("authorization") !== `Bearer ${CRON_SECRET}`) {
    return NextResponse.json({ error: "forbidden" }, { status: 403 });
  }

  // Garde : tant que l'accès CDC n'est pas branché, on ne tente rien.
  if (!isEdofFeatureEnabled() || !isEdofConfigured()) {
    return NextResponse.json({
      skipped: "edof_not_configured",
      detail:
        "Active FEATURE_EDOF et renseigne les variables EDOF_* une fois l'accès CDC obtenu.",
    });
  }

  const supabase = createAdminClient();
  const client = createEdofClient();

  // Curseur incrémental
  const { data: rawState } = await supabase
    .from("edof_sync_state")
    .select("last_pulled_at")
    .eq("id", true)
    .maybeSingle();
  const state = rawState as EdofSyncStateRow | null;
  const since = state?.last_pulled_at ?? undefined;

  try {
    let page = 1;
    let upserted = 0;
    const runAt = new Date().toISOString();

    // Pagination simple (volume moyen). Idempotent via onConflict edof_dossier_id.
    for (;;) {
      const dossiers = await client.listDossiers({
        since,
        page,
        pageSize: PAGE_SIZE,
      });
      if (!dossiers.length) break;

      const rows = dossiers.map((d) => ({
        edof_dossier_id: d.edofId,
        status: d.status,
        learner_full_name: d.learnerFullName,
        learner_email: d.learnerEmail,
        formation_label: d.formationLabel,
        amount_cents: d.amountCents,
        // `cpf_edof_dossiers.raw` : jsonb d'audit (payload EDOF brut).
        raw: (d.raw ?? null) as Json,
        last_synced_at: runAt,
      }));
      const { error } = await supabase
        .from("cpf_edof_dossiers")
        .upsert(rows, { onConflict: "edof_dossier_id" });
      if (error) {
        return NextResponse.json(
          { error: "upsert_failed", message: error.message },
          { status: 500 },
        );
      }
      upserted += rows.length;
      if (dossiers.length < PAGE_SIZE) break;
      page += 1;
    }

    await supabase.from("edof_sync_state").upsert(
      {
        id: true,
        last_pulled_at: runAt,
        last_run_at: runAt,
        last_result: { upserted },
      },
      { onConflict: "id" },
    );

    return NextResponse.json({ ok: true, upserted });
  } catch (e) {
    // L'adapter HTTP n'est pas encore écrit : on le signale clairement
    // sans casser le cron (statut 200 « pending »).
    if (e instanceof EdofNotImplementedError) {
      return NextResponse.json({
        pending: "edof_adapter_not_implemented",
        detail: e.message,
      });
    }
    return NextResponse.json(
      { error: "sync_failed", message: (e as Error)?.message },
      { status: 500 },
    );
  }
}
