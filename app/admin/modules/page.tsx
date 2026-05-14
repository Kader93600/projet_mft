import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { FormationBadge } from "@/components/formation/formation-badge";
import { Button } from "@/components/ui/button";
import { findFormation, FORMATIONS } from "@/lib/formations-config";
import {
  Plus,
  ChevronRight,
  BookOpen,
  AlertCircle,
  GraduationCap,
  Clock,
  Target,
  ListChecks,
  Layers,
  Filter,
} from "lucide-react";
import { getAuthorizedFormationSlugs } from "@/lib/admin-guard";

export const dynamic = "force-dynamic";

/**
 * Admin · Liste des modules — refonte 2026-05.
 *
 * Densité d'info élevée (besoins admin), mais hiérarchie claire :
 *  - Header + stats globales + bouton "Nouveau module"
 *  - Filtre formation en chips horizontales (server-side via searchParams)
 *  - Bandeaux d'alerte (formateur scope, modules orphelins)
 *  - Une Card par formation contenant la liste compacte de ses modules
 *  - Card séparée pour les modules orphelins
 */
export default async function AdminModules({
  searchParams,
}: {
  searchParams?: { f?: string; b?: string };
}) {
  const supabase = createClient();

  const { slugs, isTrainerOnly } = await getAuthorizedFormationSlugs();
  const filterSlug = searchParams?.f && searchParams.f !== "all" ? searchParams.f : null;
  const filterBlocCode =
    searchParams?.b && searchParams.b !== "all" ? searchParams.b : null;

  const [
    { data: modules },
    { data: lessonRows },
    { data: quizRows },
    { data: formationModules },
    { data: blocs },
  ] = await Promise.all([
    supabase.from("modules").select("*").order("order"),
    supabase.from("lessons").select("module_id"),
    supabase.from("quizzes").select("module_id"),
    supabase
      .from("formation_modules")
      .select("module_id, formation:formations(slug, code)"),
    supabase
      .from("blocs")
      .select('id, code, title, "order"')
      .order("order"),
  ]);

  const lessonCount = new Map<string, number>();
  (lessonRows ?? []).forEach((l: any) => {
    lessonCount.set(l.module_id, (lessonCount.get(l.module_id) ?? 0) + 1);
  });
  const quizCount = new Map<string, number>();
  (quizRows ?? []).forEach((q: any) => {
    quizCount.set(q.module_id, (quizCount.get(q.module_id) ?? 0) + 1);
  });

  const formationByModule = new Map<string, string>();
  (formationModules ?? []).forEach((fm: any) => {
    if (fm.formation?.slug && !formationByModule.has(fm.module_id)) {
      formationByModule.set(fm.module_id, fm.formation.slug);
    }
  });

  // Filtre trainer
  const allowed = new Set(slugs);
  const scopedModules = (modules ?? []).filter((m: any) => {
    if (!isTrainerOnly) return true;
    const slug = formationByModule.get(m.id);
    return slug ? allowed.has(slug) : false;
  });

  // Index des blocs par id pour lookup rapide
  const blocsById = new Map<number, any>();
  for (const b of blocs ?? []) blocsById.set((b as any).id, b);

  // Détermine le mode de sous-filtre pour la formation sélectionnée :
  //   - "blocs" : la formation a plusieurs blocs (GOTRM avec CCP1/2/3)
  //     → on filtre par code de bloc
  //   - "modules" : la formation a tous ses modules dans le même bloc
  //     (Capacité ≤ 3,5 t avec modules A/B/C/D/E/F) → on filtre par
  //     slug de module individuel
  type SubFilterEntry = {
    /** Code de bloc OU slug de module selon le mode. */
    key: string;
    /** Label court ("CCP 2" ou "Module A"). */
    label: string;
    /** Sous-titre ("Piloter…" ou "Droit civil et commercial"). */
    subtitle: string;
    /** Ordre d'affichage. */
    order: number;
    /** Nombre de modules dans ce groupe. */
    count: number;
  };
  let subFilterMode: "blocs" | "modules" | "none" = "none";
  let subFilterEntries: SubFilterEntry[] = [];

  if (filterSlug) {
    const modulesOfFormation = scopedModules.filter(
      (m: any) => formationByModule.get(m.id) === filterSlug,
    );
    const blocCounts = new Map<number, number>();
    for (const m of modulesOfFormation) {
      if (!m.bloc_id) continue;
      blocCounts.set(m.bloc_id, (blocCounts.get(m.bloc_id) ?? 0) + 1);
    }

    if (blocCounts.size > 1) {
      // Mode "blocs" — chaque CCP devient un chip
      subFilterMode = "blocs";
      for (const [bid, count] of blocCounts) {
        const b = blocsById.get(bid);
        if (!b) continue;
        subFilterEntries.push({
          key: b.code,
          label: CCP_LABEL_BY_CODE[b.code] ?? b.code,
          subtitle: b.title ?? "",
          order: b.order ?? 999,
          count,
        });
      }
    } else if (modulesOfFormation.length > 1) {
      // Mode "modules" — chaque module devient un chip individuel
      subFilterMode = "modules";
      subFilterEntries = modulesOfFormation.map((m: any) => ({
        key: m.slug,
        // Tente d'extraire "Module X" depuis le titre (ex. "Module A —
        // Droit civil…" → "Module A"). Sinon fallback sur le slug.
        label: shortModuleLabel(m.title, m.slug),
        subtitle: stripModulePrefix(m.title),
        order: m.order ?? 999,
        count: 1,
      }));
    }
    subFilterEntries.sort((a, b) => a.order - b.order);
  }

  // Filtre formation user-driven + sous-filtre bloc/CCP/module
  const visibleModules = scopedModules.filter((m: any) => {
    if (filterSlug && formationByModule.get(m.id) !== filterSlug) return false;
    if (filterBlocCode && subFilterMode === "blocs") {
      const bloc = blocsById.get(m.bloc_id);
      if (bloc?.code !== filterBlocCode) return false;
    }
    if (filterBlocCode && subFilterMode === "modules") {
      // En mode modules, la valeur de ?b= contient un slug de module
      if (m.slug !== filterBlocCode) return false;
    }
    return true;
  });

  // Modules orphelins (admins seulement, et seulement si pas de filtre formation)
  const orphans =
    isTrainerOnly || filterSlug
      ? []
      : scopedModules.filter((m: any) => !formationByModule.has(m.id));

  // Groupement par formation pour l'affichage
  const grouped = FORMATIONS.filter((f) => !filterSlug || f.slug === filterSlug)
    .map((f) => ({
      formation: f,
      modules: visibleModules.filter(
        (m: any) => formationByModule.get(m.id) === f.slug
      ),
    }))
    .filter((g) => g.modules.length > 0);

  // Liste des formations dispo dans le filtre (selon scope)
  const availableFormations = (FORMATIONS ?? []).filter((f) => {
    if (isTrainerOnly && !allowed.has(f.slug)) return false;
    return scopedModules.some((m: any) => formationByModule.get(m.id) === f.slug);
  });

  const totalLessons = (lessonRows ?? []).filter((l: any) =>
    visibleModules.some((m: any) => m.id === l.module_id)
  ).length;
  const totalQuizzes = (quizRows ?? []).filter((q: any) =>
    visibleModules.some((m: any) => m.id === q.module_id)
  ).length;

  return (
    <div className="space-y-8">
      {/* Header */}
      <header className="flex items-end justify-between gap-4 flex-wrap">
        <div>
          <span className="eyebrow text-gold-700">Administration</span>
          <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
            Modules &amp; leçons
          </h1>
          <p className="mt-2 text-slate-600">
            Pilotez le contenu pédagogique de toutes les formations depuis un
            seul écran.
          </p>
          <div className="mt-3 flex flex-wrap items-center gap-x-5 gap-y-1.5 text-[12px] text-slate-500">
            <span className="inline-flex items-center gap-1.5">
              <Layers className="h-3.5 w-3.5" />
              {visibleModules.length} module{visibleModules.length > 1 ? "s" : ""}
            </span>
            <span className="inline-flex items-center gap-1.5">
              <BookOpen className="h-3.5 w-3.5" />
              {totalLessons} leçon{totalLessons > 1 ? "s" : ""}
            </span>
            <span className="inline-flex items-center gap-1.5">
              <ListChecks className="h-3.5 w-3.5" />
              {totalQuizzes} quiz
            </span>
            <span className="inline-flex items-center gap-1.5">
              <span aria-hidden className="h-1.5 w-1.5 rounded-full bg-signal-500" />
              {availableFormations.length} formation
              {availableFormations.length > 1 ? "s" : ""}
            </span>
          </div>
        </div>
        <div className="flex items-center gap-2 flex-wrap">
          <Link
            href="/admin/modules/import"
            className="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl border border-navy-200 bg-white text-navy-900 hover:bg-navy-50 hover:border-navy-300 font-semibold text-sm transition"
            title="Importer un livret de cours PDF (CHAPITRE N → Modules)"
          >
            <Plus className="h-4 w-4" />
            Importer un livret PDF
          </Link>
          <Link href="/admin/modules/new">
            <Button variant="gold">
              <Plus className="h-4 w-4" /> Nouveau module
            </Button>
          </Link>
        </div>
      </header>

      {/* Bandeau formateur : rappel du scope */}
      {isTrainerOnly && (
        <div className="rounded-2xl bg-emerald-50 border border-emerald-200 p-4 flex items-start gap-3">
          <GraduationCap className="h-5 w-5 text-emerald-700 shrink-0 mt-0.5" />
          <div className="text-sm text-emerald-900 flex-1">
            <strong>Espace formateur</strong> — vous voyez et modifiez
            uniquement les modules des formations sur lesquelles vous êtes
            habilité ({slugs.join(", ") || "aucune"}). Pour étendre votre
            périmètre, contactez votre administrateur.
          </div>
        </div>
      )}

      {/* Filtre formation en chips */}
      {availableFormations.length > 1 && (
        <FormationFilter
          available={availableFormations}
          activeSlug={filterSlug}
        />
      )}

      {/* Sous-filtre par CCP / module — adaptatif selon la formation :
          - GOTRM (plusieurs blocs) → CCP 1 / CCP 2 / CCP 3
          - Capacité (1 bloc, modules à plat) → Module A / B / C / … */}
      {filterSlug && subFilterEntries.length > 1 && (
        <BlocFilter
          formationSlug={filterSlug}
          available={subFilterEntries}
          activeCode={filterBlocCode}
          mode={subFilterMode}
        />
      )}

      {/* Modules orphelins (avertissement compact) */}
      {orphans.length > 0 && (
        <div className="rounded-2xl bg-amber-50 border border-amber-200 p-4 flex items-start gap-3">
          <AlertCircle className="h-5 w-5 text-amber-700 shrink-0 mt-0.5" />
          <div className="text-sm text-amber-900 flex-1">
            <strong>
              {orphans.length} module{orphans.length > 1 ? "s" : ""} sans
              formation associée
            </strong>{" "}
            — détaillés en bas de page. Chaque module doit être rattaché à une
            formation pour apparaître dans le parcours stagiaire.
          </div>
        </div>
      )}

      {/* Sections par formation */}
      {grouped.map(({ formation, modules: mods }) => (
        <FormationSection
          key={formation.slug}
          formationSlug={formation.slug}
          modules={mods}
          formationByModule={formationByModule}
          lessonCount={lessonCount}
          quizCount={quizCount}
        />
      ))}

      {/* Modules orphelins — section dédiée */}
      {orphans.length > 0 && (
        <section className="space-y-3">
          <header className="flex items-center justify-between">
            <h2 className="font-display text-lg font-semibold text-navy-900 tracking-tight inline-flex items-center gap-2">
              <AlertCircle className="h-4 w-4 text-amber-600" />
              Modules orphelins
            </h2>
            <span className="text-[12px] text-slate-500">
              {orphans.length} sans formation
            </span>
          </header>
          <div className="rounded-2xl border border-amber-200 bg-amber-50/30 overflow-hidden">
            <ul className="divide-y divide-amber-200/70">
              {orphans.map((m: any) => (
                <ModuleRow
                  key={m.id}
                  module={m}
                  lessonCount={lessonCount.get(m.id) ?? 0}
                  quizCount={quizCount.get(m.id) ?? 0}
                  orphan
                />
              ))}
            </ul>
          </div>
        </section>
      )}

      {/* État vide */}
      {grouped.length === 0 && orphans.length === 0 && (
        <div className="rounded-2xl border border-navy-100 bg-white px-8 py-16 text-center shadow-soft">
          <Layers className="mx-auto h-7 w-7 text-slate-300" />
          <h2 className="mt-4 font-display text-lg font-semibold text-navy-900">
            {filterSlug
              ? "Aucun module sur cette formation"
              : isTrainerOnly
              ? "Aucun module sur vos formations habilitées"
              : "Aucun module"}
          </h2>
          {!filterSlug && (
            <p className="mt-2 text-sm text-slate-600 max-w-md mx-auto">
              Créez votre premier module pour démarrer.
            </p>
          )}
        </div>
      )}
    </div>
  );
}

/* ─── Filtre formation (chips serveur via Link + searchParams) ──────── */

function FormationFilter({
  available,
  activeSlug,
}: {
  available: typeof FORMATIONS;
  activeSlug: string | null;
}) {
  const all = activeSlug === null;
  return (
    <div className="rounded-2xl border border-navy-100 bg-white p-3 shadow-soft">
      <div className="flex items-center gap-2 px-1.5 mb-2">
        <Filter className="h-3.5 w-3.5 text-slate-400" />
        <span className="text-[11px] font-semibold uppercase tracking-[0.14em] text-slate-500">
          Filtrer par formation
        </span>
      </div>
      <div className="flex flex-wrap gap-1.5">
        <Link
          href="/admin/modules"
          className={
            "inline-flex items-center gap-1.5 rounded-lg px-3 py-1.5 text-[12px] font-medium transition-colors " +
            (all
              ? "bg-navy-900 text-white"
              : "bg-navy-50 text-navy-800 hover:bg-navy-100")
          }
        >
          Toutes
        </Link>
        {available.map((f) => {
          const active = activeSlug === f.slug;
          const accent = f.accent ?? "#9FE220";
          return (
            <Link
              key={f.slug}
              href={`/admin/modules?f=${f.slug}`}
              className={
                "inline-flex items-center gap-1.5 rounded-lg px-3 py-1.5 text-[12px] font-medium transition-colors border"
              }
              style={{
                background: active ? accent : "white",
                color: active ? "#0E1240" : "#1e293b",
                borderColor: active ? accent : "rgb(226 232 240)",
              }}
            >
              <span
                aria-hidden
                className="h-1.5 w-1.5 rounded-full"
                style={{ background: active ? "#0E1240" : accent }}
              />
              {f.code}
            </Link>
          );
        })}
      </div>
    </div>
  );
}

/* ─── Section par formation ─────────────────────────────────────────── */

function FormationSection({
  formationSlug,
  modules,
  lessonCount,
  quizCount,
}: {
  formationSlug: string;
  modules: any[];
  formationByModule: Map<string, string>;
  lessonCount: Map<string, number>;
  quizCount: Map<string, number>;
}) {
  const f = findFormation(formationSlug);
  if (!f) return null;
  const accent = f.accent ?? "#9FE220";
  const totalDuration = modules.reduce(
    (acc: number, m: any) => acc + (m.duration_min ?? 0),
    0
  );

  return (
    <section className="space-y-3">
      <div className="flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <FormationBadge slug={formationSlug} size="sm" icon withTitle />
          <span className="text-[12px] text-slate-500">
            {modules.length} module{modules.length > 1 ? "s" : ""}
            {totalDuration > 0 && (
              <>
                {" "}· {Math.round((totalDuration / 60) * 10) / 10} h
              </>
            )}
          </span>
        </div>
      </div>

      <div
        className="rounded-2xl border bg-white shadow-soft overflow-hidden"
        style={{ borderColor: `${accent}33` }}
      >
        {/* Stripe accent fin */}
        <div
          aria-hidden
          className="h-0.5"
          style={{ background: `linear-gradient(90deg, ${accent}, ${accent}66)` }}
        />
        <ul className="divide-y divide-navy-50">
          {modules.map((m: any) => (
            <ModuleRow
              key={m.id}
              module={m}
              lessonCount={lessonCount.get(m.id) ?? 0}
              quizCount={quizCount.get(m.id) ?? 0}
            />
          ))}
        </ul>
      </div>
    </section>
  );
}

/* ─── Ligne module ──────────────────────────────────────────────────── */

function ModuleRow({
  module: m,
  lessonCount,
  quizCount,
  orphan = false,
}: {
  module: any;
  lessonCount: number;
  quizCount: number;
  orphan?: boolean;
}) {
  const difficultyLabel: Record<string, string> = {
    debutant: "Débutant",
    intermediaire: "Intermédiaire",
    avance: "Avancé",
  };
  return (
    <li>
      <Link
        href={`/admin/modules/${m.id}`}
        className="group flex items-center gap-4 px-5 py-3.5 hover:bg-navy-50/40 transition-colors"
      >
        {/* Numéro / ordre */}
        <span className="grid place-items-center h-8 w-8 shrink-0 rounded-lg bg-navy-50 text-navy-700 text-[12px] font-semibold tabular-nums font-mono">
          {m.order ?? "—"}
        </span>

        {/* Titre + slug */}
        <div className="min-w-0 flex-1">
          <div className="font-medium text-navy-900 group-hover:text-brand-700 transition-colors truncate">
            {m.title}
          </div>
          {m.slug && (
            <div className="mt-0.5 text-[11px] font-mono text-slate-400 truncate">
              /{m.slug}
            </div>
          )}
        </div>

        {/* Stats compactes */}
        <div className="hidden md:flex items-center gap-4 text-[12px] text-slate-600 shrink-0">
          <span className="inline-flex items-center gap-1">
            <BookOpen className="h-3.5 w-3.5 text-slate-400" />
            {lessonCount}
          </span>
          <span className="inline-flex items-center gap-1">
            <ListChecks className="h-3.5 w-3.5 text-slate-400" />
            {quizCount}
          </span>
          {m.duration_min ? (
            <span className="inline-flex items-center gap-1">
              <Clock className="h-3.5 w-3.5 text-slate-400" />
              {m.duration_min} min
            </span>
          ) : null}
          {m.difficulty ? (
            <span className="inline-flex items-center gap-1 capitalize">
              <Target className="h-3.5 w-3.5 text-slate-400" />
              {difficultyLabel[m.difficulty] ?? m.difficulty}
            </span>
          ) : null}
        </div>

        {/* Badge orphan */}
        {orphan && (
          <span className="hidden sm:inline-flex items-center gap-1 rounded-md bg-amber-100 text-amber-800 border border-amber-200 px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.14em]">
            Orphelin
          </span>
        )}

        {/* CTA */}
        <span className="inline-flex items-center gap-1 text-[12px] font-medium text-slate-500 group-hover:text-brand-700 transition-colors shrink-0">
          Éditer
          <ChevronRight className="h-3.5 w-3.5 transition-transform group-hover:translate-x-0.5 motion-reduce:group-hover:translate-x-0" />
        </span>
      </Link>
    </li>
  );
}

/* ─── Sous-filtre par bloc/CCP ──────────────────────────────────────── */

/**
 * Mapping code bloc → label CCP pour GOTRM. Les autres formations
 * (Capacité, FIMO…) tombent sur le code brut comme label.
 */
const CCP_LABEL_BY_CODE: Record<string, string> = {
  BC1: "CCP 1",
  BC2: "CCP 2",
  BC3: "CCP 3",
};

function BlocFilter({
  formationSlug,
  available,
  activeCode,
  mode,
}: {
  formationSlug: string;
  available: Array<{
    key: string;
    label: string;
    subtitle: string;
    order: number;
    count: number;
  }>;
  activeCode: string | null;
  mode: "blocs" | "modules" | "none";
}) {
  const all = activeCode === null;
  const filterTitle =
    mode === "modules" ? "Filtrer par module" : "Filtrer par CCP";
  return (
    <div className="rounded-2xl border border-navy-100 bg-white p-3 shadow-soft">
      <div className="flex items-center gap-2 px-1.5 mb-2">
        <Filter className="h-3.5 w-3.5 text-slate-400" />
        <span className="text-[11px] font-semibold uppercase tracking-[0.14em] text-slate-500">
          {filterTitle}
        </span>
      </div>
      <div className="flex flex-wrap gap-1.5">
        <Link
          href={`/admin/modules?f=${formationSlug}`}
          className={
            "inline-flex items-center gap-1.5 rounded-lg px-3 py-1.5 text-[12px] font-medium transition-colors " +
            (all
              ? "bg-navy-900 text-white"
              : "bg-navy-50 text-navy-800 hover:bg-navy-100")
          }
        >
          Tous
        </Link>
        {available.map((entry) => {
          const active = activeCode === entry.key;
          return (
            <Link
              key={entry.key}
              href={`/admin/modules?f=${formationSlug}&b=${entry.key}`}
              className={
                "inline-flex items-center gap-1.5 rounded-lg px-3 py-1.5 text-[12px] font-medium transition-colors border " +
                (active
                  ? "bg-signal-500 text-night-900 border-signal-500"
                  : "bg-white text-navy-800 border-navy-100 hover:border-navy-300 hover:bg-navy-50")
              }
              title={entry.subtitle}
            >
              <span className="font-semibold">{entry.label}</span>
              {entry.subtitle && (
                <span
                  className={
                    "text-[10.5px] " +
                    (active ? "text-night-900/70" : "text-slate-500")
                  }
                >
                  · {entry.subtitle}
                </span>
              )}
              {entry.count > 1 && (
                <span
                  className={
                    "ml-0.5 text-[10.5px] font-semibold tabular-nums " +
                    (active ? "text-night-900/70" : "text-slate-400")
                  }
                >
                  ({entry.count})
                </span>
              )}
            </Link>
          );
        })}
      </div>
    </div>
  );
}

/**
 * Extrait le label court d'un module : "Module A — Droit civil…" → "Module A".
 * Fallback sur le slug si pas de pattern reconnu.
 */
function shortModuleLabel(title: string, slug: string): string {
  if (!title) return slug;
  // Capa : "Module A — Droit…" / "Module A : …"
  const m = title.match(/^(Module\s+[A-Z\d]+(?:\.\d+)?)/i);
  if (m) return m[1];
  // Chapitre : "Chapitre 1 — …"
  const c = title.match(/^(Chapitre\s+\d+(?:\.\d+)?)/i);
  if (c) return c[1];
  // Fallback : 25 premiers chars
  return title.length > 25 ? title.slice(0, 25) + "…" : title;
}

/**
 * Retire le préfixe "Module X —" / "Chapitre N —" pour ne garder
 * que le sous-titre descriptif.
 */
function stripModulePrefix(title: string): string {
  if (!title) return "";
  return title
    .replace(/^(Module\s+[A-Z\d]+(?:\.\d+)?)\s*[—\-–:]\s*/i, "")
    .replace(/^(Chapitre\s+\d+(?:\.\d+)?)\s*[—\-–:]\s*/i, "")
    .trim();
}
