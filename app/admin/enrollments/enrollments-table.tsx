"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import {
  Mail,
  Pencil,
  Trophy,
  Ban,
  Trash2,
  GraduationCap,
  Search,
  X,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Badge } from "@/components/ui/badge";
import { PackChip } from "@/components/ui/pack-chip";
import { ConfirmAction } from "@/components/ui/confirm-action";
import { SortHeader, nextSort, type SortState } from "@/components/ui/sortable";
import { findFormation } from "@/lib/formations-config";
import { deleteEnrollment, setEnrollmentStatus } from "./actions";

const STATUS_TONE: Record<string, "gold" | "navy" | "success" | "slate" | "rose"> = {
  prospect: "slate",
  devis: "gold",
  accord_financeur: "gold",
  a_payer: "gold",
  en_cours: "navy",
  termine: "success",
  abandon: "slate",
  refuse: "rose",
};
const STATUS_LABEL: Record<string, string> = {
  prospect: "Prospect",
  devis: "Devis",
  accord_financeur: "Accord financeur",
  a_payer: "À payer",
  en_cours: "En cours",
  termine: "Terminé",
  abandon: "Abandon",
  refuse: "Refusé",
};
const PACK_ORDER: Record<string, number> = { initial: 0, medium: 1, premium: 2 };

function fmtEuros(cents: number) {
  return ((cents ?? 0) / 100).toLocaleString("fr-FR", {
    style: "currency",
    currency: "EUR",
  });
}

type SortKey =
  | "name"
  | "formation"
  | "pack"
  | "funder"
  | "session"
  | "montant"
  | "paye"
  | "statut";

interface Row {
  e: any;
  name: string;
  email: string;
  formationSlug: string;
  formationCode: string;
  formationTitle: string;
  formationAccent: string | null;
  pack: string;
  funder: string;
  session: string;
  startDate: string;
  endDate: string;
  montant: number;
  paye: number;
  statut: string;
}

export function EnrollmentsTable({ enrollments }: { enrollments: any[] }) {
  const [q, setQ] = useState("");
  const [fFormation, setFFormation] = useState("");
  const [fPack, setFPack] = useState("");
  const [fStatut, setFStatut] = useState("");
  const [sort, setSort] = useState<SortState<SortKey>>({ key: null, dir: "asc" });

  const rows = useMemo<Row[]>(
    () =>
      (enrollments ?? []).map((e) => {
        const formation = e.formation_slug ? findFormation(e.formation_slug) : null;
        return {
          e,
          name: e.user?.full_name ?? e.user?.email ?? "",
          email: e.user?.email ?? "",
          formationSlug: e.formation_slug ?? "",
          formationCode: formation?.code ?? "",
          formationTitle: formation?.title ?? "",
          formationAccent: formation?.accent ?? null,
          pack: e.pack ?? "initial",
          funder: e.funder?.name ?? e.funding_kind ?? "",
          session: e.session_label ?? "",
          startDate: e.start_date ?? "",
          endDate: e.end_date ?? "",
          montant: e.total_amount_cents ?? 0,
          paye: e.paid_amount_cents ?? 0,
          statut: e.status ?? "",
        };
      }),
    [enrollments]
  );

  // Options de filtre dérivées des données présentes.
  const formationOptions = useMemo(() => {
    const map = new Map<string, string>();
    let hasNone = false;
    for (const r of rows) {
      if (!r.formationSlug) hasNone = true;
      else if (!map.has(r.formationSlug))
        map.set(r.formationSlug, r.formationCode || r.formationSlug);
    }
    const opts = [...map.entries()].sort((a, b) => a[1].localeCompare(b[1], "fr"));
    return { opts, hasNone };
  }, [rows]);

  const statutOptions = useMemo(() => {
    const set = new Set<string>();
    for (const r of rows) if (r.statut) set.add(r.statut);
    return [...set].sort((a, b) =>
      (STATUS_LABEL[a] ?? a).localeCompare(STATUS_LABEL[b] ?? b, "fr")
    );
  }, [rows]);

  const filtered = useMemo(() => {
    const term = q.trim().toLowerCase();
    return rows.filter((r) => {
      if (
        term &&
        !(
          r.name.toLowerCase().includes(term) ||
          r.email.toLowerCase().includes(term) ||
          r.formationCode.toLowerCase().includes(term) ||
          r.formationTitle.toLowerCase().includes(term)
        )
      )
        return false;
      if (fFormation) {
        if (fFormation === "__none__") {
          if (r.formationSlug) return false;
        } else if (r.formationSlug !== fFormation) return false;
      }
      if (fPack && r.pack !== fPack) return false;
      if (fStatut && r.statut !== fStatut) return false;
      return true;
    });
  }, [rows, q, fFormation, fPack, fStatut]);

  const sorted = useMemo(() => {
    if (!sort.key) return filtered;
    const key = sort.key;
    const arr = [...filtered];
    arr.sort((a, b) => {
      let c = 0;
      switch (key) {
        case "name":
          c = a.name.localeCompare(b.name, "fr");
          break;
        case "formation":
          c = a.formationCode.localeCompare(b.formationCode, "fr");
          break;
        case "pack":
          c = (PACK_ORDER[a.pack] ?? 9) - (PACK_ORDER[b.pack] ?? 9);
          break;
        case "funder":
          c = a.funder.localeCompare(b.funder, "fr");
          break;
        case "session":
          c = a.startDate.localeCompare(b.startDate);
          break;
        case "montant":
          c = a.montant - b.montant;
          break;
        case "paye":
          c = a.paye - b.paye;
          break;
        case "statut":
          c = (STATUS_LABEL[a.statut] ?? a.statut).localeCompare(
            STATUS_LABEL[b.statut] ?? b.statut,
            "fr"
          );
          break;
      }
      return sort.dir === "asc" ? c : -c;
    });
    return arr;
  }, [filtered, sort]);

  function toggleSort(key: SortKey) {
    setSort((s) => nextSort(s, key));
  }

  const hasFilters = q || fFormation || fPack || fStatut;
  function resetFilters() {
    setQ("");
    setFFormation("");
    setFPack("");
    setFStatut("");
  }

  const selectCls =
    "h-9 rounded-lg border border-navy-200 bg-white px-2.5 text-sm text-navy-800 focus:border-navy-600 focus:outline-none focus:ring-2 focus:ring-navy-600/15 dark:bg-[hsl(var(--surface))] dark:text-[hsl(var(--text))] dark:border-[hsl(var(--border))]";

  return (
    <div className="rounded-2xl border border-navy-100 bg-white shadow-soft overflow-hidden dark:bg-[hsl(var(--surface))] dark:border-[hsl(var(--border))]">
      {/* Barre de filtres */}
      <div className="flex flex-wrap items-center gap-2 border-b border-navy-50 p-3 dark:border-[hsl(var(--border))]">
        <div className="relative flex-1 min-w-[200px]">
          <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Rechercher (nom, email, formation)…"
            className="h-9 w-full rounded-lg border border-navy-200 bg-white pl-9 pr-3 text-sm text-navy-900 placeholder:text-slate-400 focus:border-navy-600 focus:outline-none focus:ring-2 focus:ring-navy-600/15 dark:bg-[hsl(var(--surface))] dark:text-[hsl(var(--text))] dark:border-[hsl(var(--border))]"
          />
        </div>
        <select
          value={fFormation}
          onChange={(e) => setFFormation(e.target.value)}
          className={selectCls}
          aria-label="Filtrer par formation"
        >
          <option value="">Toutes formations</option>
          {formationOptions.opts.map(([slug, code]) => (
            <option key={slug} value={slug}>
              {code}
            </option>
          ))}
          {formationOptions.hasNone && (
            <option value="__none__">Sans formation</option>
          )}
        </select>
        <select
          value={fPack}
          onChange={(e) => setFPack(e.target.value)}
          className={selectCls}
          aria-label="Filtrer par pack"
        >
          <option value="">Tous packs</option>
          <option value="initial">Initial</option>
          <option value="medium">Medium</option>
          <option value="premium">Premium</option>
        </select>
        <select
          value={fStatut}
          onChange={(e) => setFStatut(e.target.value)}
          className={selectCls}
          aria-label="Filtrer par statut"
        >
          <option value="">Tous statuts</option>
          {statutOptions.map((s) => (
            <option key={s} value={s}>
              {STATUS_LABEL[s] ?? s}
            </option>
          ))}
        </select>
        {hasFilters && (
          <button
            type="button"
            onClick={resetFilters}
            className="inline-flex h-9 items-center gap-1 rounded-lg border border-navy-200 px-2.5 text-xs font-medium text-slate-600 transition-colors hover:bg-navy-50 hover:text-navy-900 dark:border-[hsl(var(--border))] dark:hover:bg-white/5"
          >
            <X className="h-3.5 w-3.5" /> Réinitialiser
          </button>
        )}
        <span className="ml-auto text-xs tabular-nums text-slate-500">
          {sorted.length} / {rows.length} dossier{rows.length > 1 ? "s" : ""}
        </span>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600 dark:bg-[hsl(var(--surface-2))] dark:text-[hsl(var(--text-muted))]">
            <tr>
              <SortHeader label="Stagiaire" col="name" sort={sort} onSort={toggleSort} />
              <SortHeader
                label="Formation"
                col="formation"
                sort={sort}
                onSort={toggleSort}
                className="hidden md:table-cell"
              />
              <SortHeader
                label="Pack"
                col="pack"
                sort={sort}
                onSort={toggleSort}
                className="hidden md:table-cell"
              />
              <SortHeader
                label="Financeur"
                col="funder"
                sort={sort}
                onSort={toggleSort}
                className="hidden lg:table-cell"
              />
              <SortHeader
                label="Session"
                col="session"
                sort={sort}
                onSort={toggleSort}
                className="hidden xl:table-cell"
              />
              <SortHeader
                label="Montant"
                col="montant"
                sort={sort}
                onSort={toggleSort}
                align="right"
                className="hidden sm:table-cell"
              />
              <SortHeader
                label="Payé"
                col="paye"
                sort={sort}
                onSort={toggleSort}
                align="right"
                className="hidden lg:table-cell"
              />
              <SortHeader
                label="Statut"
                col="statut"
                sort={sort}
                onSort={toggleSort}
                className="hidden sm:table-cell"
              />
              <th className="whitespace-nowrap px-4 py-3 text-right">Actions</th>
            </tr>
          </thead>
          <tbody>
            {sorted.map((r) => (
              <tr
                key={r.e.id}
                className="border-t border-navy-50 dark:border-[hsl(var(--border))]"
              >
                <td className="px-4 py-3">
                  <div className="font-medium text-navy-900 dark:text-[hsl(var(--text))]">
                    {r.name}
                  </div>
                  <div className="text-xs text-slate-500">{r.email}</div>
                  {/* Récap mobile : formation + pack quand les colonnes sont masquées */}
                  <div className="mt-1 flex flex-wrap items-center gap-1.5 md:hidden">
                    <FormationChip
                      code={r.formationCode}
                      title={r.formationTitle}
                      accent={r.formationAccent}
                    />
                    <PackChip pack={r.pack} />
                  </div>
                </td>
                <td className="hidden px-4 py-3 align-middle md:table-cell">
                  <FormationChip
                    code={r.formationCode}
                    title={r.formationTitle}
                    accent={r.formationAccent}
                  />
                </td>
                <td className="hidden px-4 py-3 align-middle md:table-cell">
                  <PackChip pack={r.pack} />
                </td>
                <td className="hidden px-4 py-3 align-middle text-slate-700 dark:text-[hsl(var(--text-muted))] lg:table-cell">
                  {r.funder || "—"}
                </td>
                <td className="hidden px-4 py-3 align-middle text-slate-600 dark:text-[hsl(var(--text-muted))] xl:table-cell">
                  {r.session || "—"}
                  <div className="text-xs text-slate-400">
                    {r.startDate || "—"} → {r.endDate || "—"}
                  </div>
                </td>
                <td className="hidden px-4 py-3 text-right align-middle font-medium tabular-nums sm:table-cell text-navy-900 dark:text-[hsl(var(--text))]">
                  {fmtEuros(r.montant)}
                </td>
                <td className="hidden px-4 py-3 text-right align-middle tabular-nums lg:table-cell text-slate-700 dark:text-[hsl(var(--text-muted))]">
                  {fmtEuros(r.paye)}
                </td>
                <td className="hidden px-4 py-3 align-middle sm:table-cell">
                  <Badge tone={STATUS_TONE[r.statut] ?? "slate"} size="sm">
                    {STATUS_LABEL[r.statut] ?? r.statut}
                  </Badge>
                </td>
                <td className="px-4 py-3 align-middle">
                  <EnrollmentActions enrollment={r.e} />
                </td>
              </tr>
            ))}
            {sorted.length === 0 && (
              <tr>
                <td colSpan={9} className="px-4 py-6 text-sm text-slate-500">
                  {rows.length === 0
                    ? "Aucun dossier enregistré."
                    : "Aucun dossier ne correspond aux filtres."}
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function FormationChip({
  code,
  title,
  accent,
}: {
  code: string;
  title: string;
  accent: string | null;
}) {
  if (!code) return <span className="text-xs italic text-slate-400">non précisée</span>;
  return (
    <span
      className="inline-flex items-center gap-1.5 self-start rounded-md border px-1.5 py-0.5 text-[11px] font-semibold uppercase tracking-wider"
      style={
        accent
          ? { backgroundColor: `${accent}15`, borderColor: `${accent}55`, color: accent }
          : undefined
      }
      title={title}
    >
      <GraduationCap className="h-3 w-3" />
      {code}
    </span>
  );
}

function EnrollmentActions({ enrollment: e }: { enrollment: any }) {
  const closed = ["termine", "abandon", "refuse"].includes(e.status);
  const inProgress = e.status === "en_cours";
  const userEmail = e.user?.email as string | undefined;

  return (
    <div className="flex items-center justify-end gap-1">
      {userEmail && (
        <a
          href={`mailto:${userEmail}`}
          title={`Email — ${userEmail}`}
          aria-label={`Email — ${userEmail}`}
          className="inline-flex h-7 w-7 items-center justify-center rounded-lg border border-navy-200 text-navy-800 transition hover:bg-navy-50 dark:border-[hsl(var(--border))] dark:text-[hsl(var(--text))] dark:hover:bg-white/5"
        >
          <Mail className="h-3.5 w-3.5" />
        </a>
      )}

      <Link
        href={`/admin/enrollments/${e.id}`}
        title="Gérer le dossier"
        aria-label="Gérer le dossier"
        className="inline-flex h-7 w-7 items-center justify-center rounded-lg border border-gold-200 text-gold-800 transition hover:bg-gold-50"
      >
        <Pencil className="h-3.5 w-3.5" />
      </Link>

      {inProgress && (
        <form action={setEnrollmentStatus.bind(null, e.id, "termine")}>
          <ActionBtn title="Marquer comme terminé" tone="navy" type="submit">
            <Trophy className="h-3.5 w-3.5" />
          </ActionBtn>
        </form>
      )}

      {!closed && (
        <form action={setEnrollmentStatus.bind(null, e.id, "abandon")}>
          <ActionBtn title="Marquer abandon" tone="rose" type="submit">
            <Ban className="h-3.5 w-3.5" />
          </ActionBtn>
        </form>
      )}

      <ConfirmAction
        action={deleteEnrollment.bind(null, e.id)}
        title="Supprimer ce dossier ?"
        description={`Supprime définitivement le dossier de ${
          e.user?.full_name ?? e.user?.email ?? "ce stagiaire"
        }. Toutes les informations financières et historiques liées seront perdues.`}
        confirmLabel="Supprimer"
        successMsg="Dossier supprimé"
        iconLabel="Supprimer définitivement"
        icon={<Trash2 className="h-3.5 w-3.5" />}
        tone="rose"
        variant="solid"
      />
    </div>
  );
}

function ActionBtn({
  children,
  title,
  tone = "navy",
  type,
  variant = "soft",
}: {
  children: React.ReactNode;
  title: string;
  tone?: "navy" | "gold" | "rose";
  type?: "button" | "submit";
  variant?: "soft" | "solid";
}) {
  const palette: Record<string, string> = {
    navy:
      variant === "solid"
        ? "bg-navy-900 text-white hover:bg-navy-800"
        : "border-navy-200 text-navy-800 hover:bg-navy-50 dark:border-[hsl(var(--border))] dark:text-[hsl(var(--text))] dark:hover:bg-white/5",
    gold:
      variant === "solid"
        ? "bg-gold-600 text-white hover:bg-gold-700"
        : "border-gold-200 text-gold-800 hover:bg-gold-50",
    rose:
      variant === "solid"
        ? "bg-rose-600 text-white hover:bg-rose-700"
        : "border-rose-200 text-rose-700 hover:bg-rose-50",
  };
  return (
    <button
      type={type ?? "button"}
      title={title}
      aria-label={title}
      className={`inline-flex h-7 w-7 items-center justify-center rounded-lg border transition ${
        variant === "solid" ? "border-transparent" : ""
      } ${palette[tone]}`}
    >
      {children}
    </button>
  );
}
