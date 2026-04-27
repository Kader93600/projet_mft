import Link from "next/link";
import { ArrowLeft } from "lucide-react";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { RoleSelect } from "./role-select";

export const dynamic = "force-dynamic";

export default async function RolesPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data: users } = await supabase
    .from("profiles")
    .select("id, full_name, email, role, disabled")
    .order("full_name", { ascending: true })
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
          Gestion des rôles
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Promouvoir ou rétrograder un utilisateur. Toute modification est
          journalisée dans l'audit log.
        </p>
      </header>

      <Card>
        <CardBody className="p-0">
          <table className="w-full text-sm">
            <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
              <tr>
                <th className="text-left px-6 py-3">Utilisateur</th>
                <th className="text-left px-3 py-3">Email</th>
                <th className="text-left px-3 py-3">Rôle actuel</th>
                <th className="text-right px-6 py-3">Modifier</th>
              </tr>
            </thead>
            <tbody>
              {(users ?? []).map((u: any) => (
                <tr key={u.id} className="border-t border-navy-50">
                  <td className="px-6 py-3 font-medium text-navy-900">
                    {u.full_name ?? "—"}
                    {u.disabled && (
                      <Badge tone="rose" size="sm" className="ml-2">
                        Désactivé
                      </Badge>
                    )}
                  </td>
                  <td className="px-3 py-3 text-slate-600">{u.email}</td>
                  <td className="px-3 py-3">
                    <RoleBadge role={u.role} />
                  </td>
                  <td className="px-6 py-3 text-right">
                    {u.id === user.id ? (
                      <span className="text-xs text-slate-400 italic">
                        (vous)
                      </span>
                    ) : (
                      <RoleSelect userId={u.id} currentRole={u.role} />
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </CardBody>
      </Card>
    </div>
  );
}

function RoleBadge({ role }: { role: string }) {
  const map: Record<string, { tone: any; label: string }> = {
    student: { tone: "slate", label: "Stagiaire" },
    trainer: { tone: "navy", label: "Formateur" },
    admin: { tone: "gold", label: "Admin" },
    super_admin: { tone: "success", label: "Super-admin" },
  };
  const m = map[role] ?? { tone: "slate", label: role };
  return (
    <Badge tone={m.tone} size="sm">
      {m.label}
    </Badge>
  );
}
