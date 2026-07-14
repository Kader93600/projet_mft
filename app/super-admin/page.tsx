import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  UserCog,
  ShieldCheck,
  Activity,
  Users,
  Building2,
  Crown,
  ArrowRight,
  AlertTriangle,
} from "lucide-react";

export const dynamic = "force-dynamic";

export default async function SuperAdminPage() {
  const supabase = await createClient();

  const [
    { count: totalUsers },
    { count: totalAdmins },
    { count: totalTrainers },
    { count: totalStudents },
    { data: recentAudit },
    { count: totalFormations },
  ] = await Promise.all([
    supabase.from("profiles").select("*", { count: "exact", head: true }),
    supabase
      .from("profiles")
      .select("*", { count: "exact", head: true })
      .in("role", ["admin", "super_admin"]),
    supabase
      .from("profiles")
      .select("*", { count: "exact", head: true })
      .eq("role", "trainer"),
    supabase
      .from("profiles")
      .select("*", { count: "exact", head: true })
      .eq("role", "student"),
    supabase
      .from("audit_logs")
      .select("*, actor:profiles!audit_logs_actor_id_fkey(full_name, email)")
      .order("created_at", { ascending: false })
      .limit(10),
    supabase.from("formations").select("*", { count: "exact", head: true }),
  ]);

  return (
    <div className="space-y-10">
      <header>
        <div className="inline-flex items-center gap-2 mb-3">
          <Crown className="h-5 w-5 text-signal-600" />
          <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-700">
            Pilotage plateforme
          </span>
        </div>
        <h1 className="font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Vue d'ensemble
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Console super administrateur : gestion des rôles, audit des actions
          sensibles, configuration globale.
        </p>
      </header>

      {/* KPIs */}
      <section className="grid sm:grid-cols-2 lg:grid-cols-5 gap-4">
        <Kpi
          icon={Users}
          label="Utilisateurs"
          value={totalUsers ?? 0}
          tone="brand"
        />
        <Kpi
          icon={Crown}
          label="Admins"
          value={totalAdmins ?? 0}
          tone="signal"
        />
        <Kpi
          icon={ShieldCheck}
          label="Formateurs"
          value={totalTrainers ?? 0}
          tone="brand"
        />
        <Kpi
          icon={Users}
          label="Stagiaires"
          value={totalStudents ?? 0}
          tone="brand"
        />
        <Kpi
          icon={Building2}
          label="Formations"
          value={totalFormations ?? 0}
          tone="signal"
        />
      </section>

      {/* Actions rapides */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4">
          Actions rapides
        </h2>
        <div className="grid md:grid-cols-3 gap-4">
          <ActionCard
            href="/super-admin/roles"
            icon={UserCog}
            title="Gérer les rôles"
            desc="Promouvoir un utilisateur en formateur, admin ou super-admin."
          />
          <ActionCard
            href="/super-admin/permissions"
            icon={ShieldCheck}
            title="Habilitations formateurs"
            desc="Affecter les formateurs à leurs formations."
          />
          <ActionCard
            href="/super-admin/audit"
            icon={Activity}
            title="Journal d'audit"
            desc="Voir les actions sensibles tracées."
          />
        </div>
      </section>

      {/* Audit log récent */}
      <section>
        <div className="flex items-center justify-between mb-4">
          <h2 className="font-display text-xl font-semibold text-navy-900">
            Activité récente (audit)
          </h2>
          <Link
            href="/super-admin/audit"
            className="text-sm font-medium text-brand-700 hover:text-brand-800 inline-flex items-center gap-1.5"
          >
            Tout voir <ArrowRight className="h-3.5 w-3.5" />
          </Link>
        </div>
        <Card>
          <CardBody className="p-0">
            {(recentAudit ?? []).length === 0 ? (
              <div className="p-10 text-center text-sm text-slate-500">
                Aucun événement consigné pour le moment.
              </div>
            ) : (
              <ul className="divide-y divide-navy-50">
                {(recentAudit ?? []).map((row: any) => (
                  <li key={row.id} className="px-6 py-3 flex items-center gap-4">
                    <Badge tone="navy" size="sm">
                      {row.action}
                    </Badge>
                    <div className="flex-1 min-w-0 text-sm">
                      <div className="text-navy-900">
                        {row.actor?.full_name ?? row.actor?.email ?? "système"}
                      </div>
                      <div className="text-xs text-slate-500 truncate">
                        {row.target_type ? `${row.target_type} #${row.target_id?.slice(0, 8)}` : "—"}
                        {row.payload?.from && row.payload?.to ? (
                          <> · {row.payload.from} → <strong>{row.payload.to}</strong></>
                        ) : null}
                      </div>
                    </div>
                    <div className="text-[11px] text-slate-400 whitespace-nowrap">
                      {new Date(row.created_at).toLocaleString("fr-FR")}
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </CardBody>
        </Card>
      </section>

      {/* Avertissement */}
      <Card>
        <CardBody className="flex items-start gap-3">
          <div className="h-10 w-10 rounded-xl bg-amber-50 border border-amber-200 text-amber-700 flex items-center justify-center shrink-0">
            <AlertTriangle className="h-5 w-5" />
          </div>
          <div className="text-sm text-slate-700 leading-relaxed">
            <CardTitle className="text-base">Pouvoirs régaliens</CardTitle>
            <p className="mt-1">
              Vos actions sont automatiquement journalisées dans la table{" "}
              <code className="text-xs">audit_logs</code>. Toute modification de
              rôle ou de permission doit être justifiable. Vous ne pouvez pas
              modifier votre propre rôle (sécurité).
            </p>
          </div>
        </CardBody>
      </Card>
    </div>
  );
}

function Kpi({
  icon: Icon,
  label,
  value,
  tone,
}: {
  icon: any;
  label: string;
  value: number;
  tone: "brand" | "signal";
}) {
  const toneClass =
    tone === "signal"
      ? "bg-signal-500/15 border-signal-500/30 text-signal-700"
      : "bg-brand-50 border-brand-200 text-brand-700";
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

function ActionCard({
  href,
  icon: Icon,
  title,
  desc,
}: {
  href: string;
  icon: any;
  title: string;
  desc: string;
}) {
  return (
    <Link
      href={href}
      className="group rounded-2xl border border-navy-100 bg-white hover:border-brand-300 hover:shadow-soft transition p-6 flex flex-col"
    >
      <div className="h-11 w-11 rounded-xl bg-gradient-to-br from-brand-600 to-brand-800 text-signal-400 flex items-center justify-center">
        <Icon className="h-5 w-5" />
      </div>
      <CardTitle className="mt-4">{title}</CardTitle>
      <p className="mt-1.5 text-sm text-slate-600">{desc}</p>
      <span className="mt-4 inline-flex items-center gap-1.5 text-sm font-medium text-brand-700 group-hover:gap-3 transition-all">
        Ouvrir <ArrowRight className="h-3.5 w-3.5" />
      </span>
    </Link>
  );
}
