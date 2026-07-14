import Link from "next/link";
import { ArrowLeft } from "lucide-react";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

export const dynamic = "force-dynamic";

export default async function AuditLogPage() {
  const supabase = await createClient();
  const { data: rows } = await supabase
    .from("audit_logs")
    .select("*, actor:profiles!audit_logs_actor_id_fkey(full_name, email)")
    .order("created_at", { ascending: false })
    .limit(200);

  return (
    <div className="space-y-8">
      <Link
        href="/super-admin"
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
      >
        <ArrowLeft className="h-4 w-4" /> Vue d'ensemble
      </Link>

      <header>
        <h1 className="font-display text-3xl font-semibold text-navy-950">
          Journal d'audit
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          200 dernières actions sensibles tracées (changements de rôle,
          modifications de permissions, accès aux données personnelles).
        </p>
      </header>

      <Card>
        <CardBody className="p-0">
          {(rows ?? []).length === 0 ? (
            <div className="p-10 text-center text-sm text-slate-500">
              Aucun événement consigné.
            </div>
          ) : (
            <table className="w-full text-sm">
              <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                <tr>
                  <th className="text-left px-6 py-3">Date</th>
                  <th className="text-left px-3 py-3">Action</th>
                  <th className="text-left px-3 py-3">Acteur</th>
                  <th className="text-left px-3 py-3">Cible</th>
                  <th className="text-left px-6 py-3">Détails</th>
                </tr>
              </thead>
              <tbody>
                {(rows ?? []).map((row: any) => (
                  <tr key={row.id} className="border-t border-navy-50">
                    <td className="px-6 py-3 text-slate-600 whitespace-nowrap">
                      {new Date(row.created_at).toLocaleString("fr-FR")}
                    </td>
                    <td className="px-3 py-3">
                      <Badge tone="navy" size="sm">
                        {row.action}
                      </Badge>
                    </td>
                    <td className="px-3 py-3 text-navy-900">
                      {row.actor?.full_name ?? row.actor?.email ?? "—"}
                    </td>
                    <td className="px-3 py-3 text-slate-600">
                      {row.target_type ? (
                        <code className="text-xs">
                          {row.target_type} #{row.target_id?.slice(0, 8)}
                        </code>
                      ) : (
                        "—"
                      )}
                    </td>
                    <td className="px-6 py-3 text-slate-600 max-w-md truncate">
                      {row.payload ? (
                        <code className="text-xs">
                          {JSON.stringify(row.payload)}
                        </code>
                      ) : (
                        "—"
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </CardBody>
      </Card>
    </div>
  );
}
