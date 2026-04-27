import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { ShieldCheck, Trash2, AlertTriangle, Activity } from "lucide-react";
import { setDeletionStatus, anonymizeUser } from "./actions";

export const dynamic = "force-dynamic";

const STATUS_TONE: Record<string, "gold" | "navy" | "success" | "slate" | "rose"> = {
  pending: "gold",
  approved: "navy",
  executed: "success",
  refused: "rose",
  cancelled: "slate",
};

export default async function AdminRgpdPage() {
  const supabase = createClient();

  const [{ data: requests }, { data: log }, { data: consents }] =
    await Promise.all([
      supabase
        .from("deletion_requests")
        .select(
          "*, user:profiles!deletion_requests_user_id_fkey(id, full_name, email, disabled)"
        )
        .order("requested_at", { ascending: false })
        .limit(200),
      supabase
        .from("data_access_log")
        .select(
          "*, user:profiles!data_access_log_user_id_fkey(full_name, email)"
        )
        .order("created_at", { ascending: false })
        .limit(50),
      supabase.from("user_consents").select("kind, granted"),
    ]);

  const reqs = requests ?? [];
  const pending = reqs.filter((r: any) => r.status === "pending").length;
  const approved = reqs.filter((r: any) => r.status === "approved").length;
  const executed = reqs.filter((r: any) => r.status === "executed").length;

  const consentStats: Record<string, { granted: number; denied: number }> = {};
  (consents ?? []).forEach((c: any) => {
    consentStats[c.kind] = consentStats[c.kind] ?? { granted: 0, denied: 0 };
    if (c.granted) consentStats[c.kind].granted++;
    else consentStats[c.kind].denied++;
  });

  return (
    <div className="space-y-10">
      <header className="flex items-start justify-between gap-4 flex-wrap">
        <div>
          <span className="eyebrow text-gold-700">Conformité</span>
          <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
            RGPD & confidentialité
          </h1>
          <p className="mt-2 text-slate-600 max-w-2xl">
            Gestion des demandes d'effacement, journal d'accès aux données et
            statistiques de consentement.
          </p>
        </div>
      </header>

      {/* KPIs */}
      <section className="grid sm:grid-cols-3 gap-4">
        <Kpi label="Demandes en attente" value={pending} icon={AlertTriangle} tone="gold" />
        <Kpi label="Approuvées" value={approved} icon={ShieldCheck} tone="navy" />
        <Kpi label="Exécutées" value={executed} icon={Trash2} tone="success" />
      </section>

      {/* Demandes de suppression */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4">
          Demandes de suppression (Art. 17)
        </h2>
        <Card>
          <CardBody className="p-0">
            {reqs.length === 0 ? (
              <div className="p-10 text-center text-slate-500 text-sm">
                Aucune demande pour le moment.
              </div>
            ) : (
              <table className="w-full text-sm">
                <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                  <tr>
                    <th className="text-left px-6 py-3">Stagiaire</th>
                    <th className="text-left px-6 py-3">Demandée le</th>
                    <th className="text-left px-6 py-3">Motif</th>
                    <th className="text-left px-6 py-3">Statut</th>
                    <th className="text-right px-6 py-3">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {reqs.map((r: any) => (
                    <tr key={r.id} className="border-t border-navy-50 align-top">
                      <td className="px-6 py-4">
                        <div className="font-medium text-navy-900">
                          {r.user?.full_name ?? r.user?.email ?? r.user_id}
                        </div>
                        <div className="text-xs text-slate-500">
                          {r.user?.email}
                        </div>
                      </td>
                      <td className="px-6 py-4 text-slate-600">
                        {new Date(r.requested_at).toLocaleString("fr-FR")}
                      </td>
                      <td className="px-6 py-4 text-slate-600 max-w-xs">
                        {r.reason ?? <span className="italic">(aucun)</span>}
                      </td>
                      <td className="px-6 py-4">
                        <Badge tone={STATUS_TONE[r.status] ?? "slate"} size="sm">
                          {r.status}
                        </Badge>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex flex-wrap justify-end gap-2">
                          {r.status === "pending" && (
                            <>
                              <form
                                action={async () => {
                                  "use server";
                                  await setDeletionStatus(r.id, "approved");
                                }}
                              >
                                <Button type="submit" size="sm" variant="ghost">
                                  Approuver
                                </Button>
                              </form>
                              <form
                                action={async () => {
                                  "use server";
                                  await setDeletionStatus(r.id, "refused");
                                }}
                              >
                                <Button
                                  type="submit"
                                  size="sm"
                                  variant="ghost"
                                  className="text-rose-700"
                                >
                                  Refuser
                                </Button>
                              </form>
                            </>
                          )}
                          {(r.status === "approved" || r.status === "pending") && (
                            <form
                              action={async () => {
                                "use server";
                                await anonymizeUser(r.user_id);
                              }}
                            >
                              <Button
                                type="submit"
                                size="sm"
                                variant="gold"
                              >
                                <Trash2 className="h-3.5 w-3.5" /> Anonymiser
                              </Button>
                            </form>
                          )}
                          {r.user?.disabled && (
                            <Badge tone="slate" size="sm">
                              Compte désactivé
                            </Badge>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </CardBody>
        </Card>
      </section>

      {/* Consentements globaux */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4">
          Consentements (vue globale)
        </h2>
        <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {Object.entries(consentStats).map(([kind, s]) => {
            const total = s.granted + s.denied;
            const rate = total ? Math.round((s.granted / total) * 100) : 0;
            return (
              <Card key={kind}>
                <CardBody>
                  <div className="text-xs uppercase tracking-wider text-slate-500">
                    {kind}
                  </div>
                  <div className="mt-1 font-display text-2xl font-semibold text-navy-900">
                    {rate}%
                  </div>
                  <div className="text-xs text-slate-500 mt-1">
                    {s.granted} acceptés / {s.denied} refusés
                  </div>
                </CardBody>
              </Card>
            );
          })}
        </div>
      </section>

      {/* Journal d'accès */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 flex items-center gap-2">
          <Activity className="h-5 w-5 text-slate-500" /> Journal d'accès aux
          données (50 derniers)
        </h2>
        <Card>
          <CardBody className="p-0">
            {(log ?? []).length === 0 ? (
              <div className="p-10 text-center text-slate-500 text-sm">
                Aucune entrée.
              </div>
            ) : (
              <table className="w-full text-sm">
                <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                  <tr>
                    <th className="text-left px-6 py-3">Date</th>
                    <th className="text-left px-6 py-3">Utilisateur</th>
                    <th className="text-left px-6 py-3">Action</th>
                    <th className="text-left px-6 py-3">Périmètre</th>
                  </tr>
                </thead>
                <tbody>
                  {(log ?? []).map((l: any) => (
                    <tr key={l.id} className="border-t border-navy-50">
                      <td className="px-6 py-3 text-slate-600">
                        {new Date(l.created_at).toLocaleString("fr-FR")}
                      </td>
                      <td className="px-6 py-3">
                        {l.user?.full_name ?? l.user?.email ?? l.user_id}
                      </td>
                      <td className="px-6 py-3 font-medium text-navy-900">
                        {l.action}
                      </td>
                      <td className="px-6 py-3 text-slate-600">
                        {l.scope ?? "—"}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </CardBody>
        </Card>
      </section>
    </div>
  );
}

function Kpi({
  label,
  value,
  icon: Icon,
  tone,
}: {
  label: string;
  value: number;
  icon: any;
  tone: "gold" | "navy" | "success";
}) {
  const toneClass =
    tone === "gold"
      ? "bg-gold-50 text-gold-800 border-gold-200"
      : tone === "navy"
      ? "bg-navy-50 text-navy-900 border-navy-100"
      : "bg-emerald-50 text-emerald-800 border-emerald-200";
  return (
    <Card>
      <CardBody>
        <div className="flex items-center justify-between gap-3">
          <div>
            <div className="text-xs uppercase tracking-wider text-slate-500">
              {label}
            </div>
            <div className="mt-1 font-display text-3xl font-semibold text-navy-900">
              {value}
            </div>
          </div>
          <div
            className={
              "h-10 w-10 rounded-xl border flex items-center justify-center " +
              toneClass
            }
          >
            <Icon className="h-5 w-5" />
          </div>
        </div>
      </CardBody>
    </Card>
  );
}
