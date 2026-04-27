import { NextResponse } from "next/server";
import { createClient } from "@supabase/supabase-js";
import { sendEmail, emailLayout } from "@/lib/email";
import { LEGAL } from "@/lib/legal-config";
import { captureException } from "@/lib/observability";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

// À déclencher quotidiennement par :
//   - cron Vercel : ajouter dans vercel.json `{ "crons": [{ "path": "/api/cron/inactivity", "schedule": "0 8 * * *" }] }`
//   - GitHub Actions / Supabase Edge Functions / cron-job.org
// Authentification : header Authorization: Bearer ${CRON_SECRET}.
const CRON_SECRET = process.env.CRON_SECRET;

export async function GET(req: Request) {
  if (!CRON_SECRET) {
    return NextResponse.json({ error: "cron_not_configured" }, { status: 500 });
  }
  const auth = req.headers.get("authorization");
  if (auth !== `Bearer ${CRON_SECRET}`) {
    return NextResponse.json({ error: "forbidden" }, { status: 403 });
  }

  // Service role pour bypass RLS sur la RPC (qui est SECURITY DEFINER, mais
  // public.is_admin() retourne false sans contexte utilisateur — d'où le check
  // pg_has_role 'service_role' dans la fonction).
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL!;
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY!;
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
    // Récupérer les inactifs avant la RPC (pour pouvoir leur envoyer un email)
    const { data: alerts } = await supabase
      .from("inactivity_alerts")
      .select("user_id, full_name, email, days_inactive");

    const { data: rpcRes, error } = await supabase.rpc("run_inactivity_check");
    if (error) {
      await captureException(error, { tags: { task: "inactivity" } });
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    // Email aux nouvellement notifiés (ceux dont last_pinged_at était nul ou >7j)
    const toEmail = (alerts ?? []).slice(0, 50);
    let sent = 0;
    for (const a of toEmail) {
      const r = await sendEmail({
        to: a.email,
        subject: "On vous attend pour reprendre votre formation",
        html: emailLayout(
          "Reprenons votre préparation !",
          `<p>Bonjour ${a.full_name ?? ""},</p>
           <p>Votre dernière activité sur la plateforme remonte à <strong>${Math.round(a.days_inactive)} jours</strong>. La régularité est la clé de la réussite à l'examen ${LEGAL.rncpCode}.</p>
           <p style="margin:24px 0">
             <a href="${process.env.NEXT_PUBLIC_APP_URL}/dashboard" style="display:inline-block;padding:12px 22px;background:#0E1240;color:#fff;text-decoration:none;border-radius:12px;font-weight:500">Reprendre maintenant</a>
           </p>
           <p style="font-size:13px;color:#64748B">Besoin d'aide ? Répondez à cet email — votre référent pédagogique vous recontactera sous 24 h.</p>`
        ),
        tags: [{ name: "kind", value: "inactivity" }],
      });
      if (r.ok) sent++;
    }

    return NextResponse.json({
      ok: true,
      notified: rpcRes?.[0]?.notified_users ?? 0,
      emails_sent: sent,
    });
  } catch (e) {
    await captureException(e, { tags: { task: "inactivity" } });
    return NextResponse.json({ error: "task_failed" }, { status: 500 });
  }
}
