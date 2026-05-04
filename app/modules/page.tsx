import { createClient } from "@/lib/supabase/server";
import { ModuleCard, type ModuleCardData } from "@/components/modules/module-card";
import { FormationBadge } from "@/components/formation/formation-badge";
import { findFormation, FORMATIONS } from "@/lib/formations-config";
import { Layers, BookOpen, AlertCircle } from "lucide-react";

export const dynamic = "force-dynamic";

/**
 * Catalogue stagiaire — refonte 2026-05.
 *
 * Logique :
 *  - Modules groupés par FORMATION (pas par bloc, qui était un concept GOTRM
 *    appliqué à tort à toutes les formations).
 *  - Section par formation avec header (badge XL + titre + description) et
 *    grille de cards premium.
 *  - Modules orphelins (sans formation rattachée) regroupés en bandeau ambre.
 *  - Chaque card : ModuleCard avec stripe accent + hover overlay.
 */
export default async function ModulesPage() {
  const supabase = createClient();

  const [{ data: modules }, { data: links }, { data: lessons }, { data: quizzes }] =
    await Promise.all([
      supabase.from("modules").select("*").order("order"),
      supabase.from("formation_modules").select("module_id, formation:formations(slug)"),
      supabase.from("lessons").select("module_id"),
      supabase.from("quizzes").select("module_id"),
    ]);

  // Index module_id → formation_slug
  const formationByModule = new Map<string, string>();
  (links ?? []).forEach((l: any) => {
    if (l.formation?.slug && !formationByModule.has(l.module_id)) {
      formationByModule.set(l.module_id, l.formation.slug);
    }
  });

  // Comptes par module
  const lessonCount = new Map<string, number>();
  (lessons ?? []).forEach((l: any) => {
    lessonCount.set(l.module_id, (lessonCount.get(l.module_id) ?? 0) + 1);
  });
  const quizCount = new Map<string, number>();
  (quizzes ?? []).forEach((q: any) => {
    quizCount.set(q.module_id, (quizCount.get(q.module_id) ?? 0) + 1);
  });

  // Mappe module → ModuleCardData
  const cards: ModuleCardData[] = (modules ?? []).map((m: any) => ({
    id: m.id,
    slug: m.slug,
    title: m.title,
    summary: m.summary,
    duration_min: m.duration_min,
    difficulty: m.difficulty,
    formation_slug: formationByModule.get(m.id) ?? null,
    lessons_count: lessonCount.get(m.id) ?? 0,
    quizzes_count: quizCount.get(m.id) ?? 0,
    tagline: null,
  }));

  // Groupement par formation, dans l'ordre de FORMATIONS
  const grouped = FORMATIONS.map((f) => ({
    formation: f,
    modules: cards.filter((c) => c.formation_slug === f.slug),
  })).filter((g) => g.modules.length > 0);

  const orphans = cards.filter((c) => !c.formation_slug);
  const totalModules = cards.length;
  const totalLessons = (lessons ?? []).length;

  return (
    <div className="space-y-12">
      {/* Hero */}
      <header>
        <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-700">
          Vos parcours
        </span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Modules de formation
        </h1>
        <p className="mt-2 text-[15px] text-slate-600 max-w-2xl leading-relaxed">
          Le contenu pédagogique organisé par formation. Chaque module regroupe
          des leçons, des quiz d'entraînement et un examen blanc.
        </p>

        {/* Stats discrètes */}
        <div className="mt-5 flex flex-wrap items-center gap-x-5 gap-y-2 text-[12px] text-slate-500">
          <span className="inline-flex items-center gap-1.5">
            <Layers className="h-3.5 w-3.5" />
            {totalModules} module{totalModules > 1 ? "s" : ""}
          </span>
          <span className="inline-flex items-center gap-1.5">
            <BookOpen className="h-3.5 w-3.5" />
            {totalLessons} leçon{totalLessons > 1 ? "s" : ""}
          </span>
          <span className="inline-flex items-center gap-1.5">
            <span
              aria-hidden
              className="h-1.5 w-1.5 rounded-full bg-signal-500"
            />
            {grouped.length} formation{grouped.length > 1 ? "s" : ""}
          </span>
        </div>
      </header>

      {/* Sections par formation */}
      {grouped.map(({ formation, modules: mods }, sectionIdx) => (
        <FormationSection
          key={formation.slug}
          formationSlug={formation.slug}
          modules={mods}
          sectionIdx={sectionIdx}
        />
      ))}

      {/* Modules orphelins */}
      {orphans.length > 0 && (
        <section className="space-y-4">
          <div className="flex items-start gap-3 rounded-2xl bg-amber-50 border border-amber-200 px-4 py-3">
            <AlertCircle className="h-4 w-4 mt-0.5 text-amber-700 shrink-0" />
            <div className="text-[13px] text-amber-900">
              <strong>
                {orphans.length} module{orphans.length > 1 ? "s" : ""} non rattaché
                {orphans.length > 1 ? "s" : ""} à une formation
              </strong>
              . Visible uniquement par le staff.
            </div>
          </div>
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-5">
            {orphans.map((m, i) => (
              <div
                key={m.id}
                style={{
                  animation: `fade-up 0.5s ease-out ${i * 60}ms both`,
                }}
              >
                <ModuleCard module={m} />
              </div>
            ))}
          </div>
        </section>
      )}

      {/* État vide global */}
      {grouped.length === 0 && orphans.length === 0 && (
        <div className="rounded-3xl border border-navy-100 bg-white px-8 py-16 text-center shadow-soft">
          <BookOpen className="mx-auto h-8 w-8 text-slate-300" />
          <h2 className="mt-4 font-display text-xl font-semibold text-navy-900">
            Aucun module disponible
          </h2>
          <p className="mt-2 text-sm text-slate-600 max-w-md mx-auto">
            Le contenu sera publié progressivement par votre équipe pédagogique.
          </p>
        </div>
      )}
    </div>
  );
}

function FormationSection({
  formationSlug,
  modules,
  sectionIdx,
}: {
  formationSlug: string;
  modules: ModuleCardData[];
  sectionIdx: number;
}) {
  const f = findFormation(formationSlug);
  if (!f) return null;
  const accent = f.accent ?? "#9FE220";
  const totalDuration = modules.reduce((acc, m) => acc + (m.duration_min ?? 0), 0);
  const hours = totalDuration > 0 ? Math.round((totalDuration / 60) * 10) / 10 : 0;

  return (
    <section
      className="space-y-5"
      style={{
        animation: `fade-up 0.5s ease-out ${sectionIdx * 80}ms both`,
      }}
    >
      {/* Header de formation */}
      <div className="relative overflow-hidden rounded-2xl border border-navy-100 bg-gradient-to-br from-white via-white to-navy-50/30 p-5 md:p-6">
        {/* Wash de couleur formation très discret en arrière-plan */}
        <div
          aria-hidden
          className="absolute -top-12 -right-12 h-40 w-40 rounded-full pointer-events-none opacity-40"
          style={{
            background: `radial-gradient(circle, ${accent}33 0%, transparent 70%)`,
          }}
        />

        <div className="relative flex items-start justify-between gap-4 flex-wrap">
          <div className="min-w-0 max-w-2xl">
            <FormationBadge slug={formationSlug} size="md" icon withTitle />
            <h2 className="mt-3 font-display text-xl md:text-2xl font-semibold text-navy-900 leading-tight tracking-tight">
              {f.title}
            </h2>
            {f.tagline && (
              <p className="mt-1.5 text-[14px] text-slate-600 leading-relaxed">
                {f.tagline}
              </p>
            )}
          </div>

          <div className="flex flex-col items-end gap-1 shrink-0">
            <span
              className="inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-[11px] font-semibold tracking-wider"
              style={{
                background: `${accent}1A`,
                color: "#0E1240",
                border: `1px solid ${accent}50`,
              }}
            >
              {modules.length} module{modules.length > 1 ? "s" : ""}
            </span>
            {hours > 0 && (
              <span className="text-[11px] text-slate-500">~{hours} h de contenu</span>
            )}
          </div>
        </div>
      </div>

      {/* Grille de modules */}
      <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-5">
        {modules.map((m, i) => (
          <div
            key={m.id}
            style={{
              animation: `fade-up 0.45s ease-out ${
                sectionIdx * 80 + i * 50
              }ms both`,
            }}
          >
            <ModuleCard module={m} />
          </div>
        ))}
      </div>
    </section>
  );
}
