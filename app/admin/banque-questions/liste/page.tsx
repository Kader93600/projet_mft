import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  ArrowLeft,
  Filter,
  Search,
  CheckCircle2,
  AlertTriangle,
  Edit3,
  ChevronLeft,
  ChevronRight,
  Trash2,
} from "lucide-react";
import { findFormation, FORMATIONS } from "@/lib/formations-config";
import { getQuestionFilterConfig } from "@/lib/question-filters";
import { ToggleActiveButton } from "./toggle-active-button";
import { ConfirmAction } from "@/components/ui/confirm-action";
import { deleteQuestion } from "../validation-qr/actions";

export const dynamic = "force-dynamic";

const PAGE_SIZE = 25;

// Labels affichés dans le sélecteur "Cours" (par défaut : modules Capacité)
// Note : pour GOTRM le filtre devient automatiquement "Chapitre" via
// getQuestionFilterConfig() ci-dessous.
const MODULE_LABELS: Record<string, string> = {
  a: "A — Droit",
  b: "B — Commercial",
  c: "C — Réglementation",
  d: "D — Financier",
  e: "E — Salariés",
  f: "F — Sécurité",
};

export default async function BanqueQuestionsListPage({
  searchParams,
}: {
  searchParams?: {
    f?: string;
    q?: string;
    type?: string;
    status?: string;
    module?: string;
    page?: string;
  };
}) {
  const supabase = createClient();

  const formationSlug = searchParams?.f ?? "";
  const search = (searchParams?.q ?? "").trim();
  const typeFilter = searchParams?.type ?? "";
  const statusFilter = searchParams?.status ?? "";
  const moduleFilter = searchParams?.module ?? "";
  const page = Math.max(1, parseInt(searchParams?.page ?? "1", 10));

  // Construction de la requête
  let query = supabase
    .from("question_bank")
    .select("id, statement, type, choices, difficulty, tags, active, source_ref", {
      count: "exact",
    })
    .order("source_ref", { ascending: true });

  if (formationSlug) {
    const f = findFormation(formationSlug);
    if (f) {
      const { data: dbFormation } = await supabase
        .from("formations")
        .select("id")
        .eq("slug", formationSlug)
        .single();
      if (dbFormation) {
        query = query.eq("formation_id", dbFormation.id);
      }
    }
  }
  if (typeFilter === "qcm" || typeFilter === "qr") {
    query = query.eq("type", typeFilter);
  }
  if (statusFilter === "active") query = query.eq("active", true);
  if (statusFilter === "inactive") query = query.eq("active", false);
  // Filtre par "groupe" (Chapitre pour GOTRM, Module pour Capacité…).
  // Le préfixe du tag dépend de la formation sélectionnée.
  const filterConfig = getQuestionFilterConfig(formationSlug);
  if (moduleFilter)
    query = query.contains("tags", [`${filterConfig.tagPrefix}${moduleFilter}`]);
  if (search) query = query.ilike("statement", `%${search}%`);

  const { data, count } = await query.range(
    (page - 1) * PAGE_SIZE,
    page * PAGE_SIZE - 1
  );

  const total = count ?? 0;
  const totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));
  const formation = formationSlug ? findFormation(formationSlug) : null;

  // Helper pour construire des URLs avec les filtres conservés
  const buildUrl = (overrides: Record<string, string | undefined>) => {
    const params = new URLSearchParams();
    const merged = {
      f: formationSlug,
      q: search,
      type: typeFilter,
      status: statusFilter,
      module: moduleFilter,
      ...overrides,
    };
    Object.entries(merged).forEach(([k, v]) => {
      if (v) params.set(k, v);
    });
    const qs = params.toString();
    return `/admin/banque-questions/liste${qs ? "?" + qs : ""}`;
  };

  return (
    <div className="space-y-8">
      <Link
        href="/admin/banque-questions"
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
      >
        <ArrowLeft className="h-4 w-4" /> Banque de questions
      </Link>

      <header>
        <h1 className="font-display text-3xl font-semibold text-navy-950">
          Liste des questions
        </h1>
        <p className="mt-2 text-slate-600">
          Recherchez, filtrez, désactivez ou éditez les questions de la banque.
        </p>
      </header>

      {/* Barre de recherche + filtres */}
      <section className="space-y-3">
        <form method="get" className="flex gap-2 flex-wrap">
          {formationSlug && (
            <input type="hidden" name="f" value={formationSlug} />
          )}
          {typeFilter && <input type="hidden" name="type" value={typeFilter} />}
          {statusFilter && (
            <input type="hidden" name="status" value={statusFilter} />
          )}
          {moduleFilter && (
            <input type="hidden" name="module" value={moduleFilter} />
          )}
          <div className="relative flex-1 min-w-[260px]">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
            <input
              type="search"
              name="q"
              defaultValue={search}
              placeholder="Rechercher dans les énoncés…"
              className="w-full pl-10 pr-3 h-10 rounded-xl border border-navy-200 bg-white text-sm"
            />
          </div>
          <button
            type="submit"
            className="h-10 px-4 rounded-xl bg-navy-900 text-white text-sm font-medium hover:bg-navy-800"
          >
            Rechercher
          </button>
        </form>

        {/* Filtres formation */}
        <div className="flex flex-wrap gap-2 items-center">
          <span className="text-[11px] font-semibold uppercase tracking-[0.16em] text-slate-500 mr-2">
            <Filter className="h-3.5 w-3.5 inline" /> Formation
          </span>
          <FilterPill
            href={buildUrl({ f: undefined, page: "1" })}
            label="Toutes"
            active={!formationSlug}
          />
          {FORMATIONS.map((f) => (
            <FilterPill
              key={f.slug}
              href={buildUrl({ f: f.slug, page: "1" })}
              label={f.code}
              active={formationSlug === f.slug}
              accent={f.accent}
            />
          ))}
        </div>

        {/* Filtres type / statut / module */}
        <div className="flex flex-wrap gap-3">
          <SelectFilter
            label="Type"
            value={typeFilter}
            options={[
              { v: "", l: "Tous" },
              { v: "qcm", l: "QCM" },
              { v: "qr", l: "Questions rédigées" },
            ]}
            buildUrl={(v) => buildUrl({ type: v || undefined, page: "1" })}
          />
          <SelectFilter
            label="Statut"
            value={statusFilter}
            options={[
              { v: "", l: "Tous" },
              { v: "active", l: "Actives" },
              { v: "inactive", l: "Inactives" },
            ]}
            buildUrl={(v) => buildUrl({ status: v || undefined, page: "1" })}
          />
          <SelectFilter
            label={filterConfig.label}
            value={moduleFilter}
            options={[
              { v: "", l: "Tous" },
              ...filterConfig.keys.map((k) => ({
                v: k,
                l: filterConfig.formatLong
                  ? filterConfig.formatLong(k)
                  : filterConfig.formatPill(k),
              })),
            ]}
            buildUrl={(v) => buildUrl({ module: v || undefined, page: "1" })}
          />
        </div>
      </section>

      {/* Compteur */}
      <div className="text-sm text-slate-600">
        <strong className="text-navy-900">{total}</strong> question
        {total > 1 ? "s" : ""} trouvée{total > 1 ? "s" : ""}
        {formation && (
          <>
            {" "}
            ·{" "}
            <span
              className="inline-flex items-center px-2 py-0.5 rounded text-xs font-semibold"
              style={{
                backgroundColor: `${formation.accent}22`,
                color: formation.accent,
                border: `1px solid ${formation.accent}55`,
              }}
            >
              {formation.code}
            </span>
          </>
        )}
      </div>

      {/* Liste */}
      <Card>
        <CardBody className="p-0">
          {(data ?? []).length === 0 ? (
            <div className="p-10 text-center text-sm text-slate-500">
              Aucune question ne correspond aux filtres.
            </div>
          ) : (
            <ul className="divide-y divide-navy-50">
              {(data ?? []).map((q: any) => {
                // Détecte le tag de groupe : chapitre-N ou module-X selon
                // la nomenclature pédagogique de la formation.
                const groupTag = q.tags?.find((t: string) =>
                  t.startsWith(filterConfig.tagPrefix)
                );
                const groupKey = groupTag
                  ? groupTag.slice(filterConfig.tagPrefix.length)
                  : null;
                const groupLabel = groupKey
                  ? filterConfig.formatPill(groupKey)
                  : "?";
                const correctChoices = (q.choices ?? []).filter(
                  (c: any) => c.is_correct
                );
                return (
                  <li key={q.id} className="px-6 py-4">
                    <div className="flex items-start gap-3">
                      <div className="flex flex-col items-center gap-1 shrink-0">
                        <Badge
                          tone={q.type === "qr" ? "gold" : "navy"}
                          size="sm"
                        >
                          {q.type.toUpperCase()}
                        </Badge>
                        <span className="text-[10px] font-semibold text-slate-400">
                          {groupLabel}
                        </span>
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="text-sm text-navy-900 leading-relaxed">
                          {q.statement}
                        </p>
                        <div className="mt-2 flex items-center gap-2 flex-wrap text-[11px]">
                          <span className="text-slate-500">
                            {q.difficulty}
                          </span>
                          {q.type === "qcm" && (
                            <span className="text-slate-500">
                              · {q.choices?.length ?? 0} choix
                              {correctChoices.length === 0 && (
                                <span className="ml-1 text-rose-600 font-semibold">
                                  (aucune bonne réponse)
                                </span>
                              )}
                            </span>
                          )}
                          {q.source_ref && (
                            <code className="text-[10px] font-mono text-slate-400">
                              {q.source_ref}
                            </code>
                          )}
                        </div>
                      </div>
                      <div className="flex items-center gap-2 shrink-0">
                        {q.active ? (
                          <Badge tone="success" size="sm">
                            <CheckCircle2 className="h-3 w-3" />
                            Active
                          </Badge>
                        ) : (
                          <Badge tone="rose" size="sm">
                            <AlertTriangle className="h-3 w-3" />
                            Inactive
                          </Badge>
                        )}
                        <ToggleActiveButton
                          questionId={q.id}
                          active={q.active}
                        />
                        <Link
                          href={`/admin/banque-questions/liste/${q.id}`}
                          className="h-8 w-8 rounded-lg border border-navy-200 hover:bg-navy-50 flex items-center justify-center text-slate-600"
                          aria-label="Éditer"
                        >
                          <Edit3 className="h-3.5 w-3.5" />
                        </Link>
                        <ConfirmAction
                          action={deleteQuestion.bind(null, q.id)}
                          title="Supprimer cette question ?"
                          description={`L'énoncé "${(q.statement ?? "").slice(0, 100)}${(q.statement ?? "").length > 100 ? "…" : ""}" sera supprimé définitivement, ainsi que son rattachement à tous les quiz. Cette action est irréversible.`}
                          confirmLabel="Supprimer définitivement"
                          successMsg="Question supprimée"
                          icon={<Trash2 className="h-3.5 w-3.5" />}
                          iconLabel="Supprimer la question"
                          tone="rose"
                          variant="soft"
                        />
                      </div>
                    </div>
                  </li>
                );
              })}
            </ul>
          )}
        </CardBody>
      </Card>

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex items-center justify-between border-t border-navy-100 pt-4">
          <span className="text-sm text-slate-600">
            Page <strong>{page}</strong> / {totalPages}
          </span>
          <div className="flex gap-2">
            {page > 1 && (
              <Link
                href={buildUrl({ page: String(page - 1) })}
                className="inline-flex items-center gap-1 rounded-lg border border-navy-200 px-3 py-1.5 text-sm hover:bg-navy-50"
              >
                <ChevronLeft className="h-4 w-4" />
                Précédent
              </Link>
            )}
            {page < totalPages && (
              <Link
                href={buildUrl({ page: String(page + 1) })}
                className="inline-flex items-center gap-1 rounded-lg bg-navy-900 text-white px-3 py-1.5 text-sm hover:bg-navy-800"
              >
                Suivant
                <ChevronRight className="h-4 w-4" />
              </Link>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

function FilterPill({
  href,
  label,
  active,
  accent,
}: {
  href: string;
  label: string;
  active: boolean;
  accent?: string;
}) {
  return (
    <Link
      href={href}
      className={
        "px-3 py-1.5 rounded-full text-xs font-medium border transition " +
        (active
          ? "text-white border-transparent"
          : "bg-white text-slate-600 border-navy-100 hover:border-navy-300")
      }
      style={
        active
          ? {
              backgroundColor: accent ?? "#0F2A4A",
              borderColor: accent ?? "#0F2A4A",
            }
          : undefined
      }
    >
      {label}
    </Link>
  );
}

function SelectFilter({
  label,
  value,
  options,
  buildUrl,
}: {
  label: string;
  value: string;
  options: { v: string; l: string }[];
  buildUrl: (v: string) => string;
}) {
  return (
    <div className="flex items-center gap-1.5">
      <span className="text-[11px] uppercase tracking-wider text-slate-500">
        {label}
      </span>
      <div className="flex gap-1">
        {options.map((opt) => (
          <Link
            key={opt.v}
            href={buildUrl(opt.v)}
            className={
              "px-2.5 py-1 rounded-md text-xs font-medium border transition " +
              (value === opt.v
                ? "bg-navy-900 text-white border-navy-900"
                : "bg-white text-slate-600 border-navy-100 hover:border-navy-300")
            }
          >
            {opt.l}
          </Link>
        ))}
      </div>
    </div>
  );
}
