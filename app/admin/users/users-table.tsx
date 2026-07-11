"use client";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { useToast } from "@/components/ui/toast";
import { ConfirmAction } from "@/components/ui/confirm-action";
import {
  SortHeader,
  nextSort,
  cmpStr,
  cmpNum,
  type SortState,
} from "@/components/ui/sortable";
import { useEmailComposer } from "@/components/email/email-composer-provider";
import { formatDate, initials, scoreColor } from "@/lib/utils";
import {
  Search,
  Mail,
  Eye,
  UserX,
  UserCheck,
  Trash2,
  RotateCcw,
  ChevronLeft,
  ChevronRight,
  FileSpreadsheet,
  Download,
  Send,
} from "lucide-react";
import Link from "next/link";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { useState, useTransition, useMemo, useRef, useEffect } from "react";
import {
  deleteUser,
  resetUserResults,
  toggleUserDisabled,
  updateUserProfile,
  resendUserInvitation,
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

// Couleur unique par rôle, cohérente avec les boutons "créer" en haut de page.
// Dégradé sémantique du privilège : vert → bleu → ambre → rouge.
const ROLE_TONE: Record<Role, "gold" | "navy" | "amber" | "rose"> = {
  student: "gold", // vert (= bouton Stagiaire)
  trainer: "navy", // bleu (= bouton Formateur)
  admin: "amber", // ambre (= bouton Admin)
  super_admin: "rose", // rouge — privilège le plus élevé
};

// Ordre de privilège pour le tri par rôle.
const ROLE_ORDER: Record<Role, number> = {
  student: 0,
  trainer: 1,
  admin: 2,
  super_admin: 3,
};

type UserSortKey =
  | "name"
  | "group"
  | "role"
  | "activity"
  | "score"
  | "lastSignIn"
  | "status";

interface Group {
  id: string;
  name: string;
  color: string;
}

interface Pagination {
  page: number;
  pageSize: number;
  total: number;
  totalPages: number;
  q: string;
}

export function UsersTable({
  users,
  groups,
  pagination,
}: {
  users: User[];
  groups: Group[];
  pagination: Pagination;
}) {
  const { toast } = useToast();
  const composer = useEmailComposer();
  const [isPending, startTransition] = useTransition();
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();

  // Recherche server-side : auto-submit avec debounce 300 ms
  const [search, setSearch] = useState(pagination.q);
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  useEffect(() => {
    setSearch(searchParams.get("q") ?? "");
  }, [searchParams]);

  function updateUrl(patch: Record<string, string | null>) {
    const sp = new URLSearchParams(searchParams.toString());
    for (const [k, v] of Object.entries(patch)) {
      if (v === null || v === "") sp.delete(k);
      else sp.set(k, v);
    }
    const qs = sp.toString();
    router.replace(qs ? `${pathname}?${qs}` : pathname);
  }

  function onSearchChange(next: string) {
    setSearch(next);
    if (debounceRef.current) clearTimeout(debounceRef.current);
    debounceRef.current = setTimeout(() => {
      // À chaque changement de recherche, on revient page 1
      updateUrl({ q: next.trim() || null, page: null });
    }, 300);
  }

  // Filtres client : rôle, classe, statut — opèrent sur la page courante.
  const [roleFilter, setRoleFilter] = useState<string>("all");
  const [groupFilter, setGroupFilter] = useState<string>("all");
  const [statusFilter, setStatusFilter] = useState<string>("all");
  const [sort, setSort] = useState<SortState<UserSortKey>>({
    key: null,
    dir: "asc",
  });

  const filtered = useMemo(() => {
    return users.filter((u) => {
      if (roleFilter !== "all" && u.role !== roleFilter) return false;
      if (groupFilter !== "all") {
        if (groupFilter === "none" && u.group_id !== null) return false;
        if (groupFilter !== "none" && u.group_id !== groupFilter) return false;
      }
      if (statusFilter === "active" && u.disabled) return false;
      if (statusFilter === "disabled" && !u.disabled) return false;
      return true;
    });
  }, [users, roleFilter, groupFilter, statusFilter]);

  const groupsById = useMemo(
    () => new Map(groups.map((g) => [g.id, g])),
    [groups]
  );

  // Construit la query string d'export en reflétant les filtres actifs
  // (recherche serveur + rôle/classe/statut). L'export couvre TOUTE la
  // base filtrée, pas seulement la page affichée.
  const exportQuery = useMemo(() => {
    const sp = new URLSearchParams();
    if (search.trim()) sp.set("q", search.trim());
    if (roleFilter !== "all") sp.set("role", roleFilter);
    if (groupFilter !== "all") sp.set("group", groupFilter);
    if (statusFilter !== "all") sp.set("status", statusFilter);
    const qs = sp.toString();
    return qs ? `?${qs}` : "";
  }, [search, roleFilter, groupFilter, statusFilter]);

  const hasActiveFilters =
    !!search.trim() ||
    roleFilter !== "all" ||
    groupFilter !== "all" ||
    statusFilter !== "all";

  // Tri par en-tête — opère sur la page courante (comme les filtres client).
  const sorted = useMemo(() => {
    if (!sort.key) return filtered;
    const key = sort.key;
    const arr = [...filtered];
    arr.sort((a, b) => {
      let c = 0;
      switch (key) {
        case "name":
          c = cmpStr(a.full_name || a.email, b.full_name || b.email);
          break;
        case "group":
          c = cmpStr(
            a.group_id ? groupsById.get(a.group_id)?.name : "",
            b.group_id ? groupsById.get(b.group_id)?.name : ""
          );
          break;
        case "role":
          c = (ROLE_ORDER[a.role] ?? 9) - (ROLE_ORDER[b.role] ?? 9);
          break;
        case "activity":
          c = cmpNum(a.attempts_count, b.attempts_count);
          break;
        case "score":
          c = cmpNum(a.avg_score, b.avg_score);
          break;
        case "lastSignIn":
          c = cmpStr(a.last_sign_in_at ?? "", b.last_sign_in_at ?? "");
          break;
        case "status":
          c = cmpNum(a.disabled ? 1 : 0, b.disabled ? 1 : 0);
          break;
      }
      return sort.dir === "asc" ? c : -c;
    });
    return arr;
  }, [filtered, sort, groupsById]);

  function toggleSort(key: UserSortKey) {
    setSort((s) => nextSort(s, key));
  }

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
              type="search"
              placeholder="Rechercher par nom ou email (toute la base)…"
              value={search}
              onChange={(e) => onSearchChange(e.target.value)}
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

      {/* Barre d'export — respecte les filtres actifs */}
      <div className="flex items-center justify-between gap-3 flex-wrap px-1">
        <p className="text-xs text-slate-500">
          {hasActiveFilters
            ? "L'export reprend les filtres actifs (toute la base correspondante)."
            : "L'export couvre l'ensemble des comptes."}
        </p>
        <div className="flex items-center gap-2">
          <a
            href={`/api/admin/export/users/xlsx${exportQuery}`}
            className="inline-flex items-center gap-2 h-9 px-3 rounded-lg border border-emerald-200 bg-emerald-50 text-sm font-medium text-emerald-800 hover:bg-emerald-100 hover:border-emerald-300 transition active:scale-[0.98]"
            title="Exporter en XLSX (Excel) avec toutes les informations, filtres appliqués"
          >
            <FileSpreadsheet className="h-4 w-4" /> Export Excel
          </a>
          <a
            href={`/api/admin/export/users${exportQuery}`}
            className="inline-flex items-center gap-2 h-9 px-3 rounded-lg border border-navy-200 bg-white text-sm text-navy-800 hover:bg-navy-50 transition active:scale-[0.98]"
            title="Exporter en CSV, filtres appliqués"
          >
            <Download className="h-4 w-4" /> CSV
          </a>
        </div>
      </div>

      {/* Table */}
      <Card>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-navy-50/60 text-[11px] uppercase tracking-wider text-slate-600">
                <SortHeader label="Utilisateur" col="name" sort={sort} onSort={toggleSort} className="px-4" />
                <SortHeader label="Classe" col="group" sort={sort} onSort={toggleSort} className="hidden xl:table-cell px-3" />
                <SortHeader label="Rôle" col="role" sort={sort} onSort={toggleSort} className="hidden md:table-cell px-3" />
                <SortHeader label="Activité" col="activity" sort={sort} onSort={toggleSort} className="hidden lg:table-cell px-3" />
                <SortHeader label="Score moy." col="score" sort={sort} onSort={toggleSort} className="hidden lg:table-cell px-3" />
                <SortHeader label="Dernière conn." col="lastSignIn" sort={sort} onSort={toggleSort} className="hidden xl:table-cell px-3" />
                <SortHeader label="Statut" col="status" sort={sort} onSort={toggleSort} className="hidden md:table-cell px-3" />
                <th className="hidden lg:table-cell text-left px-3 py-3 font-semibold">Accès</th>
                <th className="text-right px-3 py-3 font-semibold">Actions</th>
              </tr>
            </thead>
            <tbody>
              {sorted.map((u) => {
                const group = u.group_id ? groupsById.get(u.group_id) : null;
                return (
                  <tr
                    key={u.id}
                    className="border-t border-navy-50 hover:bg-navy-50/30"
                  >
                    <td className="px-4 py-3.5">
                      <Link
                        href={`/admin/users/${u.id}`}
                        className="flex items-center gap-3 group"
                      >
                        <div className="h-9 w-9 rounded-full bg-navy-900 text-gold-400 flex items-center justify-center font-semibold text-[11px]">
                          {initials(u.full_name || u.email)}
                        </div>
                        {/* truncate + max-w : un email très long ne doit pas
                            élargir toute la colonne (title = info complète). */}
                        <div className="min-w-0">
                          <div className="font-medium text-navy-900 group-hover:text-gold-700 truncate max-w-[220px]">
                            {u.full_name || "—"}
                          </div>
                          <div
                            className="text-xs text-slate-500 truncate max-w-[220px]"
                            title={u.email}
                          >
                            {u.email}
                          </div>
                        </div>
                      </Link>
                    </td>
                    <td className="hidden xl:table-cell px-3 py-3.5">
                      {group ? (
                        <Badge tone="navy">{group.name}</Badge>
                      ) : (
                        <span className="text-xs text-slate-400">—</span>
                      )}
                    </td>
                    <td className="hidden md:table-cell px-3 py-3.5">
                      <Badge tone={ROLE_TONE[u.role] ?? "slate"}>
                        {ROLE_LABEL[u.role] ?? u.role}
                      </Badge>
                    </td>
                    <td className="hidden lg:table-cell px-3 py-3.5">
                      <div className="text-xs">
                        <strong className="text-navy-900">{u.attempts_count}</strong>
                        <span className="text-slate-500"> quiz</span>
                      </div>
                    </td>
                    <td className="hidden lg:table-cell px-3 py-3.5">
                      {u.attempts_count > 0 ? (
                        <span className={`font-semibold ${scoreColor(u.avg_score)}`}>
                          {u.avg_score}%
                        </span>
                      ) : (
                        <span className="text-xs text-slate-400">—</span>
                      )}
                    </td>
                    <td className="hidden xl:table-cell px-3 py-3.5 text-xs text-slate-500">
                      {u.last_sign_in_at ? formatDate(u.last_sign_in_at) : "Jamais"}
                    </td>
                    <td className="hidden md:table-cell px-3 py-3.5">
                      {u.disabled ? (
                        <Badge tone="slate">Désactivé</Badge>
                      ) : (
                        <Badge tone="success">Actif</Badge>
                      )}
                    </td>
                    <td className="hidden lg:table-cell px-3 py-3.5">
                      {u.last_sign_in_at ? (
                        <Badge tone="success" size="sm">Activé</Badge>
                      ) : (
                        <Badge tone="gold" size="sm">En attente</Badge>
                      )}
                    </td>
                    <td className="px-4 py-3.5">
                      <div className="flex items-center justify-end gap-1">
                        {/* Renvoyer l'invitation — uniquement comptes jamais connectés */}
                        {!u.last_sign_in_at && !u.disabled && (
                          <button
                            type="button"
                            onClick={() =>
                              run(
                                () => resendUserInvitation(u.id),
                                "Invitation renvoyée"
                              )
                            }
                            disabled={isPending}
                            title="Renvoyer l'invitation"
                            aria-label="Renvoyer l'invitation"
                            className="inline-flex h-7 w-7 items-center justify-center rounded-lg border border-brand-200 text-brand-700 hover:bg-brand-50 transition active:scale-[0.97] disabled:opacity-50"
                          >
                            <Send className="h-3.5 w-3.5" />
                          </button>
                        )}
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
                        <button
                          type="button"
                          onClick={() => {
                            const fn = u.full_name || "";
                            const [p, ...r] = fn.split(" ");
                            composer.open({
                              to: u.email,
                              relatedUserId: u.id,
                              variables: { prenom: p || fn, nom: r.join(" ") },
                            });
                          }}
                          title={`Écrire un email — ${u.email}`}
                          aria-label={`Écrire un email — ${u.email}`}
                          className="inline-flex h-7 w-7 items-center justify-center rounded-lg border border-navy-200 text-navy-800 hover:bg-navy-50 transition"
                        >
                          <Mail className="h-3.5 w-3.5" />
                        </button>

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
                        <ConfirmAction
                          action={() => resetUserResults(u.id)}
                          title="Réinitialiser les résultats ?"
                          description={`Toutes les tentatives de quiz, vues de leçons et progressions de ${
                            u.full_name ?? u.email
                          } seront effacées. Le compte reste actif.`}
                          confirmLabel="Réinitialiser"
                          successMsg="Résultats réinitialisés"
                          iconLabel="Réinitialiser tous les résultats et la progression"
                          icon={<RotateCcw className="h-3.5 w-3.5" />}
                          tone="rose"
                          disabled={isPending}
                        />

                        {/* Supprimer */}
                        <ConfirmAction
                          action={async () => {
                            const res = await deleteUser(u.id);
                            if (!res.ok) throw new Error(res.error);
                            router.refresh();
                          }}
                          title="Supprimer ce compte ?"
                          description={`Supprime définitivement le compte ${u.email}. Toutes les données personnelles, progressions et résultats seront perdus.`}
                          confirmLabel="Supprimer"
                          successMsg="Compte supprimé"
                          iconLabel="Supprimer définitivement le compte"
                          icon={<Trash2 className="h-3.5 w-3.5" />}
                          tone="rose"
                          variant="solid"
                          disabled={isPending}
                        />
                      </div>
                    </td>
                  </tr>
                );
              })}
              {filtered.length === 0 && (
                <tr>
                  <td colSpan={9} className="px-5 py-16 text-center text-slate-400">
                    {pagination.total === 0
                      ? "Aucun utilisateur dans la base."
                      : "Aucun utilisateur ne correspond aux filtres sur cette page."}
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </Card>

      {/* Pagination — bas de table */}
      {pagination.totalPages > 1 && (
        <div className="flex items-center justify-between gap-3 flex-wrap">
          <div className="text-xs text-slate-500">
            Page <strong className="text-navy-900">{pagination.page}</strong> sur{" "}
            <strong className="text-navy-900">{pagination.totalPages}</strong>
            {" · "}
            {Math.min(
              (pagination.page - 1) * pagination.pageSize + 1,
              pagination.total
            )}
            –
            {Math.min(pagination.page * pagination.pageSize, pagination.total)}{" "}
            sur {pagination.total}
            {(roleFilter !== "all" ||
              groupFilter !== "all" ||
              statusFilter !== "all") && (
              <span className="ml-2 text-amber-700">
                · Filtres actifs sur cette page uniquement
              </span>
            )}
          </div>
          <div className="flex items-center gap-1">
            <button
              type="button"
              disabled={pagination.page <= 1}
              onClick={() =>
                updateUrl({ page: String(Math.max(1, pagination.page - 1)) })
              }
              className="inline-flex h-9 items-center gap-1 rounded-lg border border-navy-200 bg-white px-3 text-sm text-navy-800 hover:bg-navy-50 transition disabled:opacity-40 disabled:cursor-not-allowed"
            >
              <ChevronLeft className="h-4 w-4" /> Précédent
            </button>
            <button
              type="button"
              disabled={pagination.page >= pagination.totalPages}
              onClick={() =>
                updateUrl({
                  page: String(
                    Math.min(pagination.totalPages, pagination.page + 1)
                  ),
                })
              }
              className="inline-flex h-9 items-center gap-1 rounded-lg border border-navy-200 bg-white px-3 text-sm text-navy-800 hover:bg-navy-50 transition disabled:opacity-40 disabled:cursor-not-allowed"
            >
              Suivant <ChevronRight className="h-4 w-4" />
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
