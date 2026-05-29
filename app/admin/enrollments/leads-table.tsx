"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import {
  Mail,
  Phone,
  UserCheck,
  FileText,
  UserPlus,
  Ban,
  Trash2,
  MessageSquare,
  Clock,
  GraduationCap,
  Search,
  X,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Badge } from "@/components/ui/badge";
import { PackChip } from "@/components/ui/pack-chip";
import { ConfirmAction } from "@/components/ui/confirm-action";
import {
  SortHeader,
  nextSort,
  cmpStr,
  type SortState,
} from "@/components/ui/sortable";
import { useEmailComposer } from "@/components/email/email-composer-provider";
import { findFormation } from "@/lib/formations-config";
import { setRequestStatus, deleteEnrollmentRequest } from "./actions";

const REQUEST_STATUS_TONE: Record<string, "slate" | "navy" | "gold" | "success" | "rose"> = {
  nouveau: "slate",
  contacte: "navy",
  devis_envoye: "gold",
  inscrit: "success",
  refuse: "rose",
};
const REQUEST_STATUS_LABEL: Record<string, string> = {
  nouveau: "Nouveau",
  contacte: "Contacté",
  devis_envoye: "Devis envoyé",
  inscrit: "Inscrit",
  refuse: "Refusé",
};
const FUNDING_LABEL: Record<string, string> = {
  auto: "Auto",
  cpf: "CPF",
  opco: "OPCO",
  france_travail: "France Travail",
  employeur: "Employeur",
  autre: "Autre",
};
const FUNDING_TONE: Record<string, "slate" | "navy" | "gold" | "success"> = {
  auto: "slate",
  cpf: "navy",
  opco: "gold",
  france_travail: "success",
  employeur: "navy",
};

/**
 * Slug de la formation visée : `formation_slug` explicite, sinon parsé depuis
 * le message libre ("Formation visée : <slug>").
 */
function extractFormationSlug(req: any): string | null {
  if (req.formation_slug) return req.formation_slug as string;
  const m = (req.message as string | null)?.match(
    /Formation\s+vis[ée]e\s*:\s*([a-z0-9-]+)/i
  );
  return m ? m[1].toLowerCase() : null;
}

function relativeAge(iso: string): string {
  const days = Math.floor((Date.now() - new Date(iso).getTime()) / 86_400_000);
  if (days <= 0) return "aujourd'hui";
  if (days === 1) return "hier";
  if (days < 7) return `il y a ${days}j`;
  if (days < 30) return `il y a ${Math.floor(days / 7)}sem`;
  return `il y a ${Math.floor(days / 30)}mois`;
}

function fmtDateTime(iso: string): string {
  const d = new Date(iso);
  return `${d.toLocaleDateString("fr-FR", { day: "numeric", month: "short" })} · ${d.toLocaleTimeString("fr-FR", { hour: "2-digit", minute: "2-digit" })}`;
}

type LeadSortKey = "contact" | "formation" | "funding" | "statut" | "recue";

interface LeadRow {
  r: any;
  name: string;
  email: string;
  formationSlug: string;
  formationCode: string;
  formationTitle: string;
  formationAccent: string | null;
  packSlug: string | null;
  funding: string;
  statut: string;
  createdAt: string;
  cleanMessage: string;
}

export function LeadsTable({ requests }: { requests: any[] }) {
  const [q, setQ] = useState("");
  const [fStatut, setFStatut] = useState("");
  const [fFunding, setFFunding] = useState("");
  const [sort, setSort] = useState<SortState<LeadSortKey>>({
    key: null,
    dir: "asc",
  });

  const rows = useMemo<LeadRow[]>(
    () =>
      (requests ?? []).map((r) => {
        const slug = extractFormationSlug(r);
        const formation = slug ? findFormation(slug) : null;
        const message = typeof r.message === "string" ? r.message.trim() : "";
        const cleanMessage = message
          .replace(/Formation\s+vis[ée]e\s*:\s*[a-z0-9-]+\s*\.?\s*/i, "")
          .trim();
        return {
          r,
          name: r.full_name ?? "",
          email: r.email ?? "",
          formationSlug: slug ?? "",
          formationCode: formation?.code ?? "",
          formationTitle: formation?.title ?? "",
          formationAccent: formation?.accent ?? null,
          packSlug: r.pack_slug ?? null,
          funding: r.funding_kind ?? "",
          statut: r.status ?? "",
          createdAt: r.created_at ?? "",
          cleanMessage,
        };
      }),
    [requests]
  );

  const statutOptions = useMemo(() => {
    const set = new Set<string>();
    for (const r of rows) if (r.statut) set.add(r.statut);
    return [...set];
  }, [rows]);
  const fundingOptions = useMemo(() => {
    const set = new Set<string>();
    for (const r of rows) if (r.funding) set.add(r.funding);
    return [...set];
  }, [rows]);

  const filtered = useMemo(() => {
    const term = q.trim().toLowerCase();
    return rows.filter((row) => {
      if (
        term &&
        !(
          row.name.toLowerCase().includes(term) ||
          row.email.toLowerCase().includes(term) ||
          row.formationCode.toLowerCase().includes(term)
        )
      )
        return false;
      if (fStatut && row.statut !== fStatut) return false;
      if (fFunding && row.funding !== fFunding) return false;
      return true;
    });
  }, [rows, q, fStatut, fFunding]);

  const sorted = useMemo(() => {
    if (!sort.key) return filtered;
    const key = sort.key;
    const arr = [...filtered];
    arr.sort((a, b) => {
      let c = 0;
      switch (key) {
        case "contact":
          c = cmpStr(a.name, b.name);
          break;
        case "formation":
          c = cmpStr(a.formationCode, b.formationCode);
          break;
        case "funding":
          c = cmpStr(
            FUNDING_LABEL[a.funding] ?? a.funding,
            FUNDING_LABEL[b.funding] ?? b.funding
          );
          break;
        case "statut":
          c = cmpStr(
            REQUEST_STATUS_LABEL[a.statut] ?? a.statut,
            REQUEST_STATUS_LABEL[b.statut] ?? b.statut
          );
          break;
        case "recue":
          c = cmpStr(a.createdAt, b.createdAt);
          break;
      }
      return sort.dir === "asc" ? c : -c;
    });
    return arr;
  }, [filtered, sort]);

  function toggleSort(key: LeadSortKey) {
    setSort((s) => nextSort(s, key));
  }

  const hasFilters = q || fStatut || fFunding;
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
          value={fStatut}
          onChange={(e) => setFStatut(e.target.value)}
          className={selectCls}
          aria-label="Filtrer par statut"
        >
          <option value="">Tous statuts</option>
          {statutOptions.map((s) => (
            <option key={s} value={s}>
              {REQUEST_STATUS_LABEL[s] ?? s}
            </option>
          ))}
        </select>
        <select
          value={fFunding}
          onChange={(e) => setFFunding(e.target.value)}
          className={selectCls}
          aria-label="Filtrer par financement"
        >
          <option value="">Tous financements</option>
          {fundingOptions.map((f) => (
            <option key={f} value={f}>
              {FUNDING_LABEL[f] ?? f}
            </option>
          ))}
        </select>
        {hasFilters && (
          <button
            type="button"
            onClick={() => {
              setQ("");
              setFStatut("");
              setFFunding("");
            }}
            className="inline-flex h-9 items-center gap-1 rounded-lg border border-navy-200 px-2.5 text-xs font-medium text-slate-600 transition-colors hover:bg-navy-50 hover:text-navy-900 dark:border-[hsl(var(--border))] dark:hover:bg-white/5"
          >
            <X className="h-3.5 w-3.5" /> Réinitialiser
          </button>
        )}
        <span className="ml-auto text-xs tabular-nums text-slate-500">
          {sorted.length} / {rows.length} lead{rows.length > 1 ? "s" : ""}
        </span>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600 dark:bg-[hsl(var(--surface-2))] dark:text-[hsl(var(--text-muted))]">
            <tr>
              <SortHeader label="Contact" col="contact" sort={sort} onSort={toggleSort} />
              <SortHeader
                label="Formation & pack"
                col="formation"
                sort={sort}
                onSort={toggleSort}
                className="hidden md:table-cell"
              />
              <SortHeader
                label="Financement"
                col="funding"
                sort={sort}
                onSort={toggleSort}
                className="hidden md:table-cell"
              />
              <th className="hidden xl:table-cell px-4 py-3 text-left font-semibold">
                Message
              </th>
              <SortHeader
                label="Statut"
                col="statut"
                sort={sort}
                onSort={toggleSort}
                className="hidden sm:table-cell"
              />
              <SortHeader
                label="Reçue"
                col="recue"
                sort={sort}
                onSort={toggleSort}
                className="hidden lg:table-cell"
              />
              <th className="whitespace-nowrap px-4 py-3 text-right font-semibold">
                Actions
              </th>
            </tr>
          </thead>
          <tbody>
            {sorted.map((row) => (
              <tr
                key={row.r.id}
                className="border-t border-navy-50 dark:border-[hsl(var(--border))]"
              >
                <td className="px-4 py-3 align-top">
                  <div className="font-medium text-navy-900 dark:text-[hsl(var(--text))]">
                    {row.name}
                  </div>
                  <div className="mt-1 flex flex-wrap items-center gap-2 text-xs text-slate-500">
                    <a
                      href={`mailto:${row.email}`}
                      className="inline-flex items-center gap-1 hover:text-navy-900"
                    >
                      <Mail className="h-3 w-3" />
                      {row.email}
                    </a>
                    {row.r.phone && (
                      <a
                        href={`tel:${row.r.phone}`}
                        className="inline-flex items-center gap-1 hover:text-navy-900"
                      >
                        <Phone className="h-3 w-3" />
                        {row.r.phone}
                      </a>
                    )}
                  </div>
                </td>
                <td className="hidden px-4 py-3 align-top md:table-cell">
                  <div className="flex flex-col gap-1">
                    {row.formationCode ? (
                      <span
                        className="inline-flex items-center gap-1.5 self-start rounded-md border px-1.5 py-0.5 text-[11px] font-semibold uppercase tracking-wider"
                        style={{
                          backgroundColor: `${row.formationAccent}15`,
                          borderColor: `${row.formationAccent}55`,
                          color: row.formationAccent ?? undefined,
                        }}
                        title={row.formationTitle}
                      >
                        <GraduationCap className="h-3 w-3" />
                        {row.formationCode}
                      </span>
                    ) : (
                      <span className="text-xs italic text-slate-400">
                        non précisée
                      </span>
                    )}
                    {row.packSlug && <PackChip pack={row.packSlug} />}
                  </div>
                </td>
                <td className="hidden px-4 py-3 align-top md:table-cell">
                  <Badge tone={FUNDING_TONE[row.funding] ?? "slate"} size="sm">
                    {FUNDING_LABEL[row.funding] ??
                      String(row.funding).replace("_", " ")}
                  </Badge>
                </td>
                <td className="hidden max-w-[260px] px-4 py-3 align-top xl:table-cell">
                  {row.cleanMessage ? (
                    <div
                      className="line-clamp-3 text-xs leading-snug text-slate-700 dark:text-[hsl(var(--text-muted))]"
                      title={row.cleanMessage}
                    >
                      <MessageSquare className="mr-1 -mt-0.5 inline h-3 w-3 text-slate-400" />
                      {row.cleanMessage}
                    </div>
                  ) : (
                    <span className="text-xs italic text-slate-400">—</span>
                  )}
                </td>
                <td className="hidden px-4 py-3 align-top sm:table-cell">
                  <Badge tone={REQUEST_STATUS_TONE[row.statut] ?? "slate"} size="sm">
                    {REQUEST_STATUS_LABEL[row.statut] ?? row.statut}
                  </Badge>
                </td>
                <td
                  className="hidden whitespace-nowrap px-4 py-3 align-top lg:table-cell"
                  title={row.createdAt ? new Date(row.createdAt).toLocaleString("fr-FR") : ""}
                >
                  <div className="text-xs text-slate-700 dark:text-[hsl(var(--text-muted))]">
                    {row.createdAt ? fmtDateTime(row.createdAt) : "—"}
                  </div>
                  {row.createdAt && (
                    <div className="mt-0.5 inline-flex items-center gap-1 text-[11px] text-slate-500">
                      <Clock className="h-3 w-3" />
                      {relativeAge(row.createdAt)}
                    </div>
                  )}
                </td>
                <td className="px-4 py-3 align-top">
                  <LeadActions request={row.r} />
                </td>
              </tr>
            ))}
            {sorted.length === 0 && (
              <tr>
                <td colSpan={7} className="px-4 py-6 text-sm text-slate-500">
                  {rows.length === 0
                    ? "Aucun lead à traiter."
                    : "Aucun lead ne correspond aux filtres."}
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function LeadActions({ request: r }: { request: any }) {
  const composer = useEmailComposer();
  const isNouveau = r.status === "nouveau";
  const isContacte = r.status === "contacte";
  const formationSlug = extractFormationSlug(r);
  const fullName = (r.full_name as string) ?? "";
  const [firstName, ...restName] = fullName.split(" ");
  const convertUrl =
    `/admin/users/new` +
    `?email=${encodeURIComponent(r.email ?? "")}` +
    `&full_name=${encodeURIComponent(r.full_name ?? "")}` +
    `&phone=${encodeURIComponent(r.phone ?? "")}` +
    (formationSlug ? `&formation_slug=${encodeURIComponent(formationSlug)}` : "") +
    (r.funding_kind ? `&funding_kind=${encodeURIComponent(r.funding_kind)}` : "");

  return (
    <div className="flex items-center justify-end gap-1">
      {r.email && (
        <button
          type="button"
          onClick={() =>
            composer.open({
              to: r.email,
              context: "lead",
              variables: {
                prenom: firstName || fullName,
                nom: restName.join(" "),
                formation: formationSlug ? findFormation(formationSlug)?.title ?? "" : "",
              },
            })
          }
          title={`Écrire un email — ${r.email}`}
          aria-label={`Écrire un email — ${r.email}`}
          className="inline-flex h-7 w-7 items-center justify-center rounded-lg border border-navy-200 text-navy-800 transition hover:bg-navy-50 dark:border-[hsl(var(--border))] dark:text-[hsl(var(--text))] dark:hover:bg-white/5"
        >
          <Mail className="h-3.5 w-3.5" />
        </button>
      )}
      {isNouveau && (
        <form action={setRequestStatus.bind(null, r.id, "contacte")}>
          <ActionBtn title="Marquer comme contacté" tone="navy" type="submit">
            <UserCheck className="h-3.5 w-3.5" />
          </ActionBtn>
        </form>
      )}

      {isContacte && (
        <form action={setRequestStatus.bind(null, r.id, "devis_envoye")}>
          <ActionBtn title="Devis envoyé" tone="navy" type="submit">
            <FileText className="h-3.5 w-3.5" />
          </ActionBtn>
        </form>
      )}

      <Link
        href={convertUrl}
        title="Convertir en stagiaire (créer compte + dossier)"
        aria-label="Convertir en stagiaire"
        className="inline-flex h-7 w-7 items-center justify-center rounded-lg border border-signal-300 bg-signal-50 text-signal-800 transition hover:bg-signal-100"
      >
        <UserPlus className="h-3.5 w-3.5" />
      </Link>

      <form action={setRequestStatus.bind(null, r.id, "refuse")}>
        <ActionBtn title="Refuser ce lead" tone="rose" type="submit">
          <Ban className="h-3.5 w-3.5" />
        </ActionBtn>
      </form>

      <ConfirmAction
        action={deleteEnrollmentRequest.bind(null, r.id)}
        title="Supprimer ce lead ?"
        description={`Supprime définitivement la demande de ${r.full_name} (${r.email}).`}
        confirmLabel="Supprimer"
        successMsg="Lead supprimé"
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
