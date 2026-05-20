import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { AlertTriangle, ExternalLink, Mail } from "lucide-react";
import Link from "next/link";

export const dynamic = "force-dynamic";

function fmtDateTime(iso: string) {
  return new Intl.DateTimeFormat("fr-FR", {
    dateStyle: "short",
    timeStyle: "short",
  }).format(new Date(iso));
}

export default async function AdminAlertsPage() {
  const supabase = createClient();

  const [{ data: alerts }, { data: pings }] = await Promise.all([
    supabase
      .from("inactivity_alerts")
      .select("*")
      .order("days_inactive", { ascending: false })
      .limit(200),
    supabase
      .from("inactivity_pings")
      .select("user_id, last_pinged_at, ping_count"),
  ]);

  const pingMap = new Map(
    (pings ?? []).map((p: any) => [p.user_id, p])
  );

  return (
    <div className="space-y-10">
      <header>
        <span className="eyebrow text-gold-700">Suivi pédagogique</span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Alertes d'inactivité
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Stagiaires en formation active sans connexion ni progression depuis
          plus de 7 jours. Indicateur Qualiopi 22.
        </p>
      </header>

      <Card>
        <CardBody className="p-0">
          {(alerts ?? []).length === 0 ? (
            <div className="p-10 text-center text-sm text-slate-500">
              ✅ Tous les stagiaires actifs sont à jour.
            </div>
          ) : (
            <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                <tr>
                  <th className="text-left px-6 py-3">Stagiaire</th>
                  <th className="text-left px-6 py-3">Dernière activité</th>
                  <th className="text-left px-6 py-3">Inactif depuis</th>
                  <th className="text-left px-6 py-3">Relances envoyées</th>
                  <th className="text-right px-6 py-3">Actions</th>
                </tr>
              </thead>
              <tbody>
                {(alerts ?? []).map((a: any) => {
                  const days = Math.round(Number(a.days_inactive));
                  const ping = pingMap.get(a.user_id) as any;
                  const tone =
                    days >= 21 ? "rose" : days >= 14 ? "gold" : "navy";
                  return (
                    <tr key={a.user_id} className="border-t border-navy-50">
                      <td className="px-6 py-3">
                        <div className="font-medium text-navy-900">
                          {a.full_name ?? a.email}
                        </div>
                        <div className="text-xs text-slate-500">{a.email}</div>
                      </td>
                      <td className="px-6 py-3 text-slate-600">
                        {fmtDateTime(a.last_activity_at)}
                      </td>
                      <td className="px-6 py-3">
                        <Badge tone={tone as any} size="sm">
                          <AlertTriangle className="h-3 w-3" /> {days} j
                        </Badge>
                      </td>
                      <td className="px-6 py-3 text-slate-600">
                        {ping ? (
                          <>
                            {ping.ping_count} (dernière :{" "}
                            {fmtDateTime(ping.last_pinged_at)})
                          </>
                        ) : (
                          <span className="text-slate-400">—</span>
                        )}
                      </td>
                      <td className="px-6 py-3 text-right">
                        <div className="inline-flex gap-2">
                          <a
                            href={`mailto:${a.email}`}
                            className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-navy-200 text-sm text-navy-900 hover:bg-navy-50"
                          >
                            <Mail className="h-3.5 w-3.5" /> Relancer
                          </a>
                          <Link
                            href={`/admin/users?q=${encodeURIComponent(a.email)}`}
                            className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-navy-200 text-sm text-navy-900 hover:bg-navy-50"
                          >
                            Fiche <ExternalLink className="h-3.5 w-3.5" />
                          </Link>
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
            </div>
          )}
        </CardBody>
      </Card>

      <div className="text-xs text-slate-500">
        Vérification quotidienne automatique via{" "}
        <code>/api/cron/inactivity</code>. Les relances sont envoyées au
        stagiaire (notification + email) et notifiées aux admins, avec
        idempotence 7 jours.
      </div>
    </div>
  );
}
