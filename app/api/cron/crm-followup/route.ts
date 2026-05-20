// =====================================================================
// GET /api/cron/crm-followup
//
// Cron quotidien (08:00 UTC) déclenché par Vercel Cron.
// Authentification : header Authorization: Bearer ${CRON_SECRET}.
//
// Pour chaque admin qui a au moins 1 lead dont la relance est due
// aujourd'hui (next_followup_at <= now() et pas en pause) :
//   • Insère une notification in-app (table notifications)
//   • Envoie un email récapitulatif via Resend
//
// Idempotent : si on le relance dans la même journée, on ne double pas
// les emails (dédup via une notification du jour déjà créée).
// =====================================================================

import { NextResponse } from "next/server";
import { createClient } from "@supabase/supabase-js";
import { sendEmail, crmFollowupReminderEmail } from "@/lib/email";
import { LEGAL } from "@/lib/legal-config";
import { captureException } from "@/lib/observability";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

const CRON_SECRET = process.env.CRON_SECRET;

export async function GET(req: Request) {
  if (!CRON_SECRET) {
    return NextResponse.json({ error: "cron_not_configured" }, { status: 500 });
  }
  const auth = req.headers.get("authorization");
  if (auth !== `Bearer ${CRON_SECRET}`) {
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
    auth: { persistSession: false },
  });

  try {
    // 1. Récupère tous les leads dont la relance est due, groupés par admin
    // ⚠️ PostgREST n'évalue PAS now() dans une valeur de filtre (traité
    // comme littéral texte). On calcule le timestamp côté JS pour que
    // la branche "snooze expiré" fonctionne réellement.
    const nowIso = new Date().toISOString();
    const { data: dueLeads, error: leadsErr } = await supabase
      .from("enrollment_requests")
      .select(`
        id, full_name, email, status, next_followup_at, assigned_to_admin_id,
        admin:profiles!enrollment_requests_assigned_to_admin_id_fkey ( id, full_name, email )
      `)
      .not("assigned_to_admin_id", "is", null)
      .lte("next_followup_at", nowIso)
      .or(`snoozed_until.is.null,snoozed_until.lte.${nowIso}`)
      .in("status", ["nouveau", "contacte", "devis_envoye"]);

    if (leadsErr) {
      await captureException(leadsErr, {
        tags: { service: "cron", job: "crm-followup", stage: "fetch_leads" },
      });
      return NextResponse.json(
        { error: "fetch_failed", message: leadsErr.message },
        { status: 500 }
      );
    }

    type LeadRow = {
      id: string;
      full_name: string;
      email: string;
      status: string;
      next_followup_at: string;
    };
    type AdminEntry = {
      admin: { id: string; full_name: string | null; email: string };
      leads: LeadRow[];
    };
    const leadsByAdmin = new Map<string, AdminEntry>();

    for (const lead of (dueLeads ?? []) as any[]) {
      const adminId = lead.assigned_to_admin_id;
      if (!adminId || !lead.admin) continue;
      const entry: AdminEntry = leadsByAdmin.get(adminId) ?? {
        admin: lead.admin,
        leads: [],
      };
      entry.leads.push({
        id: lead.id,
        full_name: lead.full_name,
        email: lead.email,
        status: lead.status,
        next_followup_at: lead.next_followup_at,
      });
      leadsByAdmin.set(adminId, entry);
    }

    // 2. Pour chaque admin, génère notification + email (dédup par date)
    const todayDateStr = new Date().toISOString().slice(0, 10);
    let notifsCreated = 0;
    let emailsSent = 0;

    for (const [adminId, entry] of leadsByAdmin) {
      // Dédup notification : on cherche si on a déjà notifié cet admin
      // aujourd'hui (via le link_url qui contient la date)
      const { data: existing } = await supabase
        .from("notifications")
        .select("id")
        .eq("user_id", adminId)
        .eq("link_url", `/admin/crm?reminded=${todayDateStr}`)
        .maybeSingle();

      if (existing) continue;

      // Insert notification
      const count = entry.leads.length;
      await supabase.from("notifications").insert({
        user_id: adminId,
        type: "system",
        title: `${count} relance${count > 1 ? "s" : ""} CRM aujourd'hui`,
        body: `Vous avez ${count} prospect${count > 1 ? "s" : ""} à recontacter.`,
        link_url: `/admin/crm?reminded=${todayDateStr}`,
      });
      notifsCreated++;

      // Email récap
      if (entry.admin.email) {
        const tmpl = crmFollowupReminderEmail({
          adminFullName: entry.admin.full_name,
          leads: entry.leads.map((l) => ({
            id: l.id,
            fullName: l.full_name,
            email: l.email,
            status: l.status,
            nextFollowupAt: l.next_followup_at,
          })),
          crmUrl: `${LEGAL.website}/admin/crm`,
        });
        await sendEmail({
          to: entry.admin.email,
          ...tmpl,
          tags: [{ name: "kind", value: "crm_followup" }],
        });
        emailsSent++;
      }
    }

    return NextResponse.json({
      ok: true,
      admins_notified: notifsCreated,
      emails_sent: emailsSent,
      leads_total: dueLeads?.length ?? 0,
    });
  } catch (e) {
    await captureException(e, {
      tags: { service: "cron", job: "crm-followup" },
    });
    return NextResponse.json({ error: "cron_failed" }, { status: 500 });
  }
}
