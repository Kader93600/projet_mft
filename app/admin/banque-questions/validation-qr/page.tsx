import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { ArrowLeft, Filter, CheckCircle2 } from "lucide-react";
import { findFormation, FORMATIONS } from "@/lib/formations-config";
import { QrEditor } from "./qr-editor";
import { ActivateAllButton } from "./activate-all-button";

export const dynamic = "force-dynamic";

export default async function ValidationQrPage({
  searchParams,
}: {
  searchParams?: { f?: string; module?: string };
}) {
  const supabase = createClient();
  const slug = searchParams?.f ?? "capacite-3-5t";
  const moduleFilter = searchParams?.module ?? "";

  const formation = findFormation(slug);
  if (!formation) return <div>Formation introuvable</div>;

  const { data: dbF } = await supabase
    .from("formations")
    .select("id")
    .eq("slug", slug)
    .single();
  if (!dbF) return <div>Formation absente en BDD.</div>;

  let query = supabase
    .from("question_bank")
    .select(
      "id, statement, expected_answer, scoring_grid, max_score, difficulty, tags, source_ref, active"
    )
    .eq("formation_id", dbF.id)
    .eq("type", "qr")
    .order("source_ref", { ascending: true });

  if (moduleFilter) {
    query = query.contains("tags", [`module-${moduleFilter}`]);
  }

  const { data: questions } = await query;
  const list = (questions ?? []) as any[];
  const inactiveCount = list.filter((q) => !q.active).length;

  // Stats par module
  const moduleCounts: Record<string, { total: number; inactive: number }> = {};
  for (const letter of ["a", "b", "c", "d", "e", "f"]) {
    const { data: rows } = await supabase
      .from("question_bank")
      .select("active")
      .eq("formation_id", dbF.id)
      .eq("type", "qr")
      .contains("tags", [`module-${letter}`]);
    const total = rows?.length ?? 0;
    const inactive = (rows ?? []).filter((r: any) => !r.active).length;
    moduleCounts[letter] = { total, inactive };
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
          Validation des questions rédigées (QR)
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Ajoutez la <strong>réponse-modèle</strong> et le <strong>barème</strong> à
          chaque QR avant de l'activer. Ces éléments seront visibles uniquement
          par les formateurs lors de la correction des copies.
        </p>
      </header>

      {/* Filtres modules */}
      <section className="flex flex-wrap items-center gap-2">
        <span className="inline-flex items-center gap-1.5 text-[11px] font-semibold uppercase tracking-[0.16em] text-slate-500 mr-2">
          <Filter className="h-3.5 w-3.5" /> Module
        </span>
        <FilterPill
          href={`/admin/banque-questions/validation-qr?f=${slug}`}
          label={`Tous (${list.length})`}
          active={!moduleFilter}
        />
        {(["a", "b", "c", "d", "e", "f"] as const).map((letter) => (
          <FilterPill
            key={letter}
            href={`/admin/banque-questions/validation-qr?f=${slug}&module=${letter}`}
            label={`${letter.toUpperCase()} (${moduleCounts[letter].total})`}
            active={moduleFilter === letter}
            highlight={moduleCounts[letter].inactive > 0}
          />
        ))}
      </section>

      {/* Activation en lot */}
      {inactiveCount > 0 && (
        <Card variant="gold">
          <CardBody className="flex items-center justify-between gap-4 flex-wrap">
            <div>
              <div className="font-display text-base font-semibold text-navy-900">
                {inactiveCount} QR inactive{inactiveCount > 1 ? "s" : ""}
              </div>
              <p className="text-sm text-slate-600 mt-1">
                Activer en lot toutes les QR de cette formation. Tu pourras
                affiner les réponses-modèles ensuite.
              </p>
            </div>
            <ActivateAllButton formationSlug={slug} count={inactiveCount} />
          </CardBody>
        </Card>
      )}

      {/* Liste */}
      {list.length === 0 ? (
        <Card>
          <CardBody className="text-center py-14">
            <CheckCircle2 className="mx-auto h-10 w-10 text-emerald-600" />
            <h3 className="mt-4 font-display text-lg font-semibold text-navy-900">
              Aucune QR pour ce filtre
            </h3>
          </CardBody>
        </Card>
      ) : (
        <div className="space-y-4">
          {list.map((q: any, i: number) => (
            <QrEditor
              key={q.id}
              question={q}
              index={i + 1}
              total={list.length}
            />
          ))}
        </div>
      )}
    </div>
  );
}

function FilterPill({
  href,
  label,
  active,
  highlight,
}: {
  href: string;
  label: string;
  active: boolean;
  highlight?: boolean;
}) {
  return (
    <Link
      href={href}
      className={
        "px-3 py-1.5 rounded-full text-xs font-medium border transition relative " +
        (active
          ? "bg-navy-900 text-white border-navy-900"
          : "bg-white text-slate-600 border-navy-100 hover:border-navy-300")
      }
    >
      {label}
      {highlight && !active && (
        <span className="absolute -top-1 -right-1 h-2 w-2 rounded-full bg-rose-500" />
      )}
    </Link>
  );
}
