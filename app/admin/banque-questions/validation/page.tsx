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
import { ValidationForm } from "./validation-form";

export const dynamic = "force-dynamic";

const PAGE_SIZE = 20;

export default async function ValidationPage({
  searchParams,
}: {
  searchParams?: { f?: string; page?: string; module?: string };
}) {
  const supabase = createClient();
  const slug = searchParams?.f ?? "capacite-3-5t";
  const page = Math.max(1, parseInt(searchParams?.page ?? "1", 10));
  const moduleFilter = searchParams?.module ?? "";

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

  if (moduleFilter) {
    query = query.contains("tags", [`module-${moduleFilter}`]);
  }

  const { data: questions, count } = await query.range(
    (page - 1) * PAGE_SIZE,
    page * PAGE_SIZE - 1
  );

  const total = count ?? 0;
  const totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));

  // Stats par module pour le filtre
  const moduleCounts: Record<string, number> = {};
  for (const letter of ["a", "b", "c", "d", "e", "f"]) {
    const { count: c } = await supabase
      .from("question_bank")
      .select("*", { count: "exact", head: true })
      .eq("formation_id", dbFormation.id)
      .eq("type", "qcm")
      .eq("active", false)
      .contains("tags", [`module-${letter}`]);
    moduleCounts[letter] = c ?? 0;
  }

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

      {/* Filtres modules + page */}
      <section className="flex flex-wrap items-center gap-2">
        <span className="text-[11px] font-semibold uppercase tracking-[0.16em] text-slate-500 mr-2">
          Module
        </span>
        <FilterPill
          href={`/admin/banque-questions/validation?f=${slug}`}
          label={`Tous (${total + ["a", "b", "c", "d", "e", "f"].reduce(
            (s, l) => (l !== moduleFilter ? s + (moduleCounts[l] ?? 0) : s),
            0
          )})`}
          active={!moduleFilter}
        />
        {(["a", "b", "c", "d", "e", "f"] as const).map((letter) => (
          <FilterPill
            key={letter}
            href={`/admin/banque-questions/validation?f=${slug}&module=${letter}`}
            label={`${letter.toUpperCase()} (${moduleCounts[letter]})`}
            active={moduleFilter === letter}
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
              {moduleFilter
                ? `Aucun QCM en attente pour le module ${moduleFilter.toUpperCase()}.`
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
            {(questions ?? []).map((q: any, idx: number) => (
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
                    moduleFilter ? `&module=${moduleFilter}` : ""
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
                    moduleFilter ? `&module=${moduleFilter}` : ""
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
