import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  ArrowLeft,
  ChevronLeft,
  ChevronRight,
  CheckCircle2,
  AlertTriangle,
  Sparkles,
} from "lucide-react";
import { findFormation } from "@/lib/formations-config";
import { getQuestionFilterConfig } from "@/lib/question-filters";
import { ValidationForm } from "./validation-form";
import type { Tables } from "@/lib/database.types";

export const dynamic = "force-dynamic";

const PAGE_SIZE = 20;

/**
 * Ligne de `question_bank` telle que sélectionnée ici. `choices` est une
 * colonne JSONB (type `Json` en base) : on documente ici sa forme réelle,
 * qui est le contrat d'import des QCM (cf. lib/question-import).
 */
type QuestionRow = Pick<
  Tables<"question_bank">,
  "id" | "statement" | "tags" | "source_ref" | "difficulty" | "type"
> & {
  choices: { id: string; label: string; is_correct: boolean }[];
};

export default async function ValidationPage({
  searchParams,
}: {
  searchParams?: { f?: string; page?: string; module?: string };
}) {
  const supabase = createClient();
  const slug = searchParams?.f ?? "capacite-3-5t";
  const page = Math.max(1, parseInt(searchParams?.page ?? "1", 10));
  const groupFilter = searchParams?.module ?? "";

  const formation = findFormation(slug);
  if (!formation) {
    return <div>Formation introuvable</div>;
  }

  const { data: dbFormation } = await supabase
    .from("formations")
    .select("id")
    .eq("slug", slug)
    .single();
  if (!dbFormation) {
    return <div>Formation absente en BDD. Jouez d'abord formations_v2.sql.</div>;
  }

  // Filtres adaptés à la formation (Chapitre pour GOTRM, Module pour Capa…)
  const filterConfig = getQuestionFilterConfig(slug);

  // Liste des questions à valider (active=false, type=qcm)
  let query = supabase
    .from("question_bank")
    .select("id, statement, choices, tags, source_ref, difficulty, type", {
      count: "exact",
    })
    .eq("formation_id", dbFormation.id)
    .eq("type", "qcm")
    .eq("active", false)
    .order("source_ref", { ascending: true });

  if (groupFilter) {
    query = query.contains("tags", [
      `${filterConfig.tagPrefix}${groupFilter}`,
    ]);
  }

  const { data: questions, count } = await query.range(
    (page - 1) * PAGE_SIZE,
    page * PAGE_SIZE - 1
  );

  const total = count ?? 0;
  const totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));

  // Agrège les counts par clé en une seule requête (au lieu de N requêtes
  // parallèles). On embarque les clés extra trouvées hors config.
  const { data: tagRows } = await supabase
    .from("question_bank")
    .select("tags")
    .eq("formation_id", dbFormation.id)
    .eq("type", "qcm")
    .eq("active", false);

  const groupCounts: Record<string, number> = {};
  for (const k of filterConfig.keys) groupCounts[k] = 0;
  const extraKeys = new Set<string>();
  for (const row of (tagRows ?? []) as Pick<
    Tables<"question_bank">,
    "tags"
  >[]) {
    const tags: string[] = row.tags ?? [];
    for (const t of tags) {
      if (!t.startsWith(filterConfig.tagPrefix)) continue;
      const k = t.slice(filterConfig.tagPrefix.length);
      if (!(k in groupCounts)) {
        groupCounts[k] = 0;
        if (!filterConfig.keys.includes(k)) extraKeys.add(k);
      }
      groupCounts[k] += 1;
    }
  }
  const orderedKeys: string[] = [
    ...filterConfig.keys,
    ...Array.from(extraKeys).sort((a, b) => {
      const na = parseInt(a, 10);
      const nb = parseInt(b, 10);
      if (!isNaN(na) && !isNaN(nb)) return na - nb;
      return a.localeCompare(b);
    }),
  ];

  return (
    <div className="space-y-8">
      <Link
        href="/admin/banque-questions"
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
      >
        <ArrowLeft className="h-4 w-4" /> Banque de questions
      </Link>

      <header>
        <span
          className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-md text-xs font-semibold uppercase tracking-wider"
          style={{
            backgroundColor: `${formation.accent}22`,
            color: formation.accent,
            border: `1px solid ${formation.accent}55`,
          }}
        >
          {formation.code}
        </span>
        <h1 className="mt-3 font-display text-3xl font-semibold text-navy-950">
          Validation des QCM importés
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Pour chaque question, sélectionnez la bonne réponse puis cliquez sur{" "}
          <strong>Valider et activer</strong>. La question entrera alors en
          circulation pour les quiz et examens.
        </p>
      </header>

      {/* Filtres par chapitre / module selon la formation */}
      <section className="flex flex-wrap items-center gap-2">
        <span className="text-[11px] font-semibold uppercase tracking-[0.16em] text-slate-500 mr-2">
          {filterConfig.label}
        </span>
        <FilterPill
          href={`/admin/banque-questions/validation?f=${slug}`}
          label={`Tous (${Object.values(groupCounts).reduce(
            (s, n) => s + n,
            0,
          )})`}
          active={!groupFilter}
        />
        {orderedKeys.map((key) => (
          <FilterPill
            key={key}
            href={`/admin/banque-questions/validation?f=${slug}&module=${key}`}
            label={`${filterConfig.formatPill(key)} (${groupCounts[key] ?? 0})`}
            active={groupFilter === key}
          />
        ))}
      </section>

      {/* État vide */}
      {total === 0 ? (
        <Card>
          <CardBody className="text-center py-14 px-6">
            <div className="mx-auto h-12 w-12 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-700 flex items-center justify-center">
              <CheckCircle2 className="h-6 w-6" />
            </div>
            <h3 className="mt-4 font-display text-xl font-semibold text-navy-900">
              Tout est validé
            </h3>
            <p className="mt-2 text-sm text-slate-600 max-w-md mx-auto">
              {groupFilter
                ? `Aucun QCM en attente pour ${filterConfig.formatLong ? filterConfig.formatLong(groupFilter) : filterConfig.formatPill(groupFilter)}.`
                : "Aucun QCM en attente de validation pour cette formation."}
            </p>
            <Link
              href="/admin/banque-questions"
              className="mt-5 inline-flex items-center gap-1.5 text-sm font-medium text-brand-700 hover:text-brand-900"
            >
              Retour à la banque
            </Link>
          </CardBody>
        </Card>
      ) : (
        <>
          {/* Liste */}
          <section className="space-y-4">
            {((questions ?? []) as QuestionRow[]).map((q, idx) => (
              <ValidationForm
                key={q.id}
                question={q}
                indexInPage={(page - 1) * PAGE_SIZE + idx + 1}
                totalPending={total}
              />
            ))}
          </section>

          {/* Pagination */}
          <section className="flex items-center justify-between border-t border-navy-100 pt-4">
            <span className="text-sm text-slate-600">
              Page <strong>{page}</strong> / {totalPages} ·{" "}
              <strong>{total}</strong> QCM en attente
            </span>
            <div className="flex gap-2">
              {page > 1 && (
                <Link
                  href={`/admin/banque-questions/validation?f=${slug}${
                    groupFilter ? `&module=${groupFilter}` : ""
                  }&page=${page - 1}`}
                  className="inline-flex items-center gap-1 rounded-lg border border-navy-200 px-3 py-1.5 text-sm hover:bg-navy-50"
                >
                  <ChevronLeft className="h-4 w-4" />
                  Précédent
                </Link>
              )}
              {page < totalPages && (
                <Link
                  href={`/admin/banque-questions/validation?f=${slug}${
                    groupFilter ? `&module=${groupFilter}` : ""
                  }&page=${page + 1}`}
                  className="inline-flex items-center gap-1 rounded-lg bg-navy-900 text-white px-3 py-1.5 text-sm hover:bg-navy-800"
                >
                  Suivant
                  <ChevronRight className="h-4 w-4" />
                </Link>
              )}
            </div>
          </section>
        </>
      )}
    </div>
  );
}

function FilterPill({
  href,
  label,
  active,
}: {
  href: string;
  label: string;
  active: boolean;
}) {
  return (
    <Link
      href={href}
      className={
        "px-3 py-1.5 rounded-full text-xs font-medium border transition " +
        (active
          ? "bg-navy-900 text-white border-navy-900"
          : "bg-white text-slate-600 border-navy-100 hover:border-navy-300")
      }
    >
      {label}
    </Link>
  );
}
