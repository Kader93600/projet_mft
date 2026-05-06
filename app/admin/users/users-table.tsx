"use client";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { useToast } from "@/components/ui/toast";
import { formatDate, initials, scoreColor } from "@/lib/utils";
import {
  Search,
  Mail,
  Eye,
  UserX,
  UserCheck,
  Trash2,
  RotateCcw,
} from "lucide-react";
import Link from "next/link";
import { useState, useTransition, useMemo } from "react";
import {
  deleteUser,
  resetUserResults,
  toggleUserDisabled,
  updateUserProfile,
} from "./actions";

type Role = "student" | "trainer" | "admin" | "super_admin";

interface User {
  id: string;
  email: string;
  full_name: string | null;
  role: Role;
  level: string;
  group_id: string | null;
  disabled: boolean;
  created_at: string;
  last_sign_in_at: string | null;
  attempts_count: number;
  avg_score: number;
}

const ROLE_LABEL: Record<Role, string> = {
  student: "Stagiaire",
  trainer: "Formateur",
  admin: "Admin",
  super_admin: "Super admin",
};

const ROLE_TONE: Record<Role, "slate" | "gold" | "navy" | "success"> = {
  student: "slate",
  trainer: "navy",
  admin: "gold",
  super_admin: "success",
};

interface Group {
  id: string;
  name: string;
  color: string;
}

export function UsersTable({
  users,
  groups,
}: {
  users: User[];
  groups: Group[];
}) {
  const { toast } = useToast();
  const [isPending, startTransition] = useTransition();
  const [search, setSearch] = useState("");
  const [roleFilter, setRoleFilter] = useState<string>("all");
  const [groupFilter, setGroupFilter] = useState<string>("all");
  const [statusFilter, setStatusFilter] = useState<string>("all");

  const filtered = useMemo(() => {
    return users.filter((u) => {
      if (roleFilter !== "all" && u.role !== roleFilter) return false;
      if (groupFilter !== "all") {
        if (groupFilter === "none" && u.group_id !== null) return false;
        if (groupFilter !== "none" && u.group_id !== groupFilter) return false;
      }
      if (statusFilter === "active" && u.disabled) return false;
      if (statusFilter === "disabled" && !u.disabled) return false;
      if (search.trim()) {
        const s = search.toLowerCase();
        return (
          u.email.toLowerCase().includes(s) ||
          (u.full_name ?? "").toLowerCase().includes(s)
        );
      }
      return true;
    });
  }, [users, search, roleFilter, groupFilter, statusFilter]);

  const groupsById = new Map(groups.map((g) => [g.id, g]));

  function run(fn: () => Promise<any>, okMsg: string) {
    startTransition(async () => {
      try {
        await fn();
        toast(okMsg, "success");
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  return (
    <div className="space-y-4">
      {/* Filtres */}
      <Card>
        <div className="p-4 grid grid-cols-1 md:grid-cols-4 gap-3">
          <div className="relative md:col-span-2">
            <Search className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
            <Input
              placeholder="Rechercher par nom ou email…"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="pl-10"
            />
          </div>
          <Select value={roleFilter} onChange={(e) => setRoleFilter(e.target.value)}>
            <option value="all">Tous les rôles</option>
            <option value="student">Stagiaires</option>
            <option value="trainer">Formateurs</option>
            <option value="admin">Administrateurs</option>
            <option value="super_admin">Super-admins</option>
          </Select>
          <Select
            value={groupFilter}
            onChange={(e) => setGroupFilter(e.target.value)}
          >
            <option value="all">Toutes les classes</option>
            <option value="none">Sans classe</option>
            {groups.map((g) => (
              <option key={g.id} value={g.id}>
                {g.name}
              </option>
            ))}
          </Select>
          <Select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="md:col-span-1"
          >
            <option value="all">Tous statuts</option>
            <option value="active">Actifs</option>
            <option value="disabled">Désactivés</option>
          </Select>
        </div>
      </Card>

      {/* Table */}
      <Card>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-navy-50/60 text-[11px] uppercase tracking-wider text-slate-600">
                <th className="text-left px-5 py-3 font-semibold">Utilisateur</th>
                <th className="text-left px-5 py-3 font-semibold">Classe</th>
                <th className="text-left px-5 py-3 font-semibold">Rôle</th>
                <th className="text-left px-5 py-3 font-semibold">Activité</th>
                <th className="text-left px-5 py-3 font-semibold">Score moy.</th>
                <th className="text-left px-5 py-3 font-semibold">Dernière conn.</th>
                <th className="text-left px-5 py-3 font-semibold">Statut</th>
                <th className="text-right px-5 py-3 font-semibold">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((u) => {
                const group = u.group_id ? groupsById.get(u.group_id) : null;
                return (
                  <tr
                    key={u.id}
                    className="border-t border-navy-50 hover:bg-navy-50/30"
                  >
                    <td className="px-5 py-3.5">
                      <Link
                        href={`/admin/users/${u.id}`}
                        className="flex items-center gap-3 group"
                      >
                        <div className="h-9 w-9 rounded-full bg-navy-900 text-gold-400 flex items-center justify-center font-semibold text-[11px]">
                          {initials(u.full_name || u.email)}
                        </div>
                        <div>
                          <div className="font-medium text-navy-900 group-hover:text-gold-700">
                            {u.full_name || "—"}
                          </div>
                          <div className="text-xs text-slate-500">{u.email}</div>
                        </div>
                      </Link>
                    </td>
                    <td className="px-5 py-3.5">
                      {group ? (
                        <Badge tone="navy">{group.name}</Badge>
                      ) : (
                        <span className="text-xs text-slate-400">—</span>
                      )}
                    </td>
                    <td className="px-5 py-3.5">
                      <Badge tone={ROLE_TONE[u.role] ?? "slate"}>
                        {ROLE_LABEL[u.role] ?? u.role}
                      </Badge>
                    </td>
                    <td className="px-5 py-3.5">
                      <div className="text-xs">
                        <strong className="text-navy-900">{u.attempts_count}</strong>
                        <span className="text-slate-500"> quiz</span>
                      </div>
                    </td>
                    <td className="px-5 py-3.5">
                      {u.attempts_count > 0 ? (
                        <span className={`font-semibold ${scoreColor(u.avg_score)}`}>
                          {u.avg_score}%
                        </span>
                      ) : (
                        <span className="text-xs text-slate-400">—</span>
                      )}
                    </td>
                    <td className="px-5 py-3.5 text-xs text-slate-500">
                      {u.last_sign_in_at ? formatDate(u.last_sign_in_at) : "Jamais"}
                    </td>
                    <td className="px-5 py-3.5">
                      {u.disabled ? (
                        <Badge tone="slate">Désactivé</Badge>
                      ) : (
                        <Badge tone="success">Actif</Badge>
                      )}
                    </td>
                    <td className="px-5 py-3.5">
                      <div className="flex items-center justify-end gap-1">
                        {/* Voir le profil */}
                        <Link
                          href={`/admin/users/${u.id}`}
                          title="Voir le profil"
                          aria-label="Voir le profil"
                          className="inline-flex h-7 w-7 items-center justify-center rounded-lg border border-gold-200 text-gold-800 hover:bg-gold-50 transition"
                        >
                          <Eye className="h-3.5 w-3.5" />
                        </Link>

                        {/* Contacter */}
                        <a
                          href={`mailto:${u.email}`}
                          title={`Envoyer un email — ${u.email}`}
                          aria-label={`Envoyer un email — ${u.email}`}
                          className="inline-flex h-7 w-7 items-center justify-center rounded-lg border border-navy-200 text-navy-800 hover:bg-navy-50 transition"
                        >
                          <Mail className="h-3.5 w-3.5" />
                        </a>

                        {/* Désactiver / Réactiver */}
                        <button
                          type="button"
                          disabled={isPending}
                          title={u.disabled ? "Réactiver le compte" : "Désactiver le compte"}
                          aria-label={u.disabled ? "Réactiver le compte" : "Désactiver le compte"}
                          onClick={() =>
                            run(
                              () => toggleUserDisabled(u.id, !u.disabled),
                              u.disabled ? "Compte réactivé" : "Compte désactivé"
                            )
                          }
                          className="inline-flex h-7 w-7 items-center justify-center rounded-lg border border-navy-200 text-navy-800 hover:bg-navy-50 transition disabled:opacity-50"
                        >
                          {u.disabled ? (
                            <UserCheck className="h-3.5 w-3.5" />
                          ) : (
                            <UserX className="h-3.5 w-3.5" />
                          )}
                        </button>

                        {/* Réinitialiser résultats */}
                        <button
                          type="button"
                          disabled={isPending}
                          title="Réinitialiser tous les résultats de quiz et la progression"
                          aria-label="Réinitialiser les résultats"
                          onClick={() => {
                            if (
                              confirm(
                                `Réinitialiser tous les résultats et la progression de "${
                                  u.full_name ?? u.email
                                }" ?`
                              )
                            )
                              run(
                                () => resetUserResults(u.id),
                                "Résultats réinitialisés"
                              );
                          }}
                          className="inline-flex h-7 w-7 items-center justify-center rounded-lg border border-rose-200 text-rose-700 hover:bg-rose-50 transition disabled:opacity-50"
                        >
                          <RotateCcw className="h-3.5 w-3.5" />
                        </button>

                        {/* Supprimer */}
                        <button
                          type="button"
                          disabled={isPending}
                          title="Supprimer définitivement le compte"
                          aria-label="Supprimer le compte"
                          onClick={() => {
                            if (
                              confirm(
                                `Supprimer définitivement le compte "${u.email}" ? Cette action est irréversible.`
                              )
                            )
                              run(() => deleteUser(u.id), "Compte supprimé");
                          }}
                          className="inline-flex h-7 w-7 items-center justify-center rounded-lg border border-transparent bg-rose-600 text-white hover:bg-rose-700 transition disabled:opacity-50"
                        >
                          <Trash2 className="h-3.5 w-3.5" />
                        </button>
                      </div>
                    </td>
                  </tr>
                );
              })}
              {filtered.length === 0 && (
                <tr>
                  <td colSpan={8} className="px-5 py-16 text-center text-slate-400">
                    Aucun utilisateur ne correspond aux filtres.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}
