// =====================================================================
// /exercices — Cockpit ENTRAÎNEMENT du stagiaire (refonte 2026-05).
//
// Le client a demandé une séparation nette entre :
//   - /exercices         → quiz de TYPE 'entrainement' (cette page)
//   - /examens-blancs    → quiz de TYPE 'examen' OR is_mock_exam=true
//
// Cette page :
//   - Hero personnalisé style "Mes exercices"
//   - Filtre par formation + module + difficulté
//   - Cards entraînement (ambiance signal-lime, vibe pédagogique)
//   - Stats personnelles : déjà tenté, score moyen
//   - Click → /quiz/[id] (runner existant)
// =====================================================================

import { getTranslations } from "next-intl/server";
import { createClient } from "@/lib/supabase/server";
import { FormationBadge } from "@/components/formation/formation-badge";
import { findFormation, FORMATIONS } from "@/lib/formations-config";
import { Dumbbell, BookOpen, Sparkles, Filter } from "lucide-react";
import { ExercicesCatalog } from "./exercices-catalog";

export const dynamic = "force-dynamic";

export default async function ExercicesPage({
  searchParams,
}: {
  searchParams?: { f?: string };
}) {
  const t = await getTranslations("exercices");
  const supabase = createClient();
  const filterFormation = searchParams?.f ?? null;

  const {
    data: { user },
  } = await supabase.auth.getUser();

  // Profil pour le prénom
  let firstName: string | null = null;
  if (user) {
    const { data: profile } = await supabase
      .from("profiles")
      .select("full_name")
      .eq("id", user.id)
      .maybeSingle();
    firstName = extractFirstName(profile?.full_name ?? null);
  }

  // Inscriptions actives → formations accessibles
  // Staff (admin/super_admin/trainer) : bypass — voit toutes les
  // formations actives sans dépendre des enrollments.
  // Student : bypass RLS via service_role (filtre user_id côté code).
  const { createAdminClient: ac } = await import("@/lib/supabase/admin");
  let enrolledFormationIds: string[] = [];
  let isStaffUser = false;
  if (user) {
    const { data: meRole } = await supabase
      .from("profiles")
      .select("role")
      .eq("id", user.id)
      .single();
    isStaffUser =
      meRole?.role === "admin" ||
      meRole?.role === "super_admin" ||
      meRole?.role === "trainer";

    if (isStaffUser) {
      const { data: allFormations } = await supabase
        .from("formations")
        .select("id")
        .eq("active", true);
      enrolledFormationIds = (allFormations ?? []).map((f: any) => f.id);
    } else {
      const admin = ac();
      const { data: enrollments } = await admin
        .from("enrollments")
        .select("formation_id, status")
        .eq("user_id", user.id)
        .neq("status", "refuse")
        .neq("status", "abandon");
      enrolledFormationIds = (enrollments ?? [])
        .map((e: any) => e.formation_id)
        .filter(Boolean);
    }
  }

  // Reader pour les fetches catalogue
  const reader = isStaffUser ? supabase : ac();

  // Mapping formation → modules (pour scoping des quizzes)
  let allowedModuleIds: string[] = [];
  const moduleToFormation = new Map<string, string>();
  if (enrolledFormationIds.length > 0) {
    const { data: fm } = await reader
      .from("formation_modules")
      .select("module_id, formation:formations(slug)")
      .in("formation_id", enrolledFormationIds);
    for (const row of fm ?? []) {
      const slug = (row as any).formation?.slug;
      if (slug) moduleToFormation.set(row.module_id, slug);
    }
    allowedModuleIds = Array.from(moduleToFormation.keys());
  }

  // Fetch quizzes ENTRAÎNEMENT uniquement
  let quizzes: any[] = [];
  if (allowedModuleIds.length > 0) {
    const { data } = await reader
      .from("quizzes")
      .select(
        "id, title, description, type, is_mock_exam, pass_threshold, " +
          "time_limit_s, timer_enabled, max_attempts, module_id, " +
          "modules(id, title, slug, bloc_id, order)",
      )
      .eq("type", "entrainement")
      .or("is_mock_exam.is.null,is_mock_exam.eq.false")
      .in("module_id", allowedModuleIds);
    quizzes = data ?? [];
  }

  // Fetch quiz_question_bank + questions inline pour compter le nb de questions
  const quizIds = quizzes.map((q) => q.id);
  const [{ data: bankLinks }, { data: inlineQs }] =
    quizIds.length > 0
      ? await Promise.all([
          reader
            .from("quiz_question_bank")
            .select("quiz_id")
            .in("quiz_id", quizIds),
          reader
            .from("questions")
            .select("quiz_id")
            .in("quiz_id", quizIds),
        ])
      : [
          { data: [] as { quiz_id: string }[] },
          { data: [] as { quiz_id: string }[] },
        ];
  const questionCount = new Map<string, number>();
  for (const row of bankLinks ?? []) {
    questionCount.set(row.quiz_id, (questionCount.get(row.quiz_id) ?? 0) + 1);
  }
  for (const row of inlineQs ?? []) {
    questionCount.set(row.quiz_id, (questionCount.get(row.quiz_id) ?? 0) + 1);
  }

  // Stats user pour chaque quiz
  let userAttempts = new Map<
    string,
    { bestPercent: number; lastAt: string; count: number }
  >();
  if (user && quizIds.length > 0) {
    const { data: attempts } = await reader
      .from("quiz_attempts")
      .select("quiz_id, percentage, completed_at")
      .eq("user_id", user.id)
      .in("quiz_id", quizIds);
    for (const a of attempts ?? []) {
      const prev = userAttempts.get(a.quiz_id);
      const p = a.percentage ?? 0;
      userAttempts.set(a.quiz_id, {
        bestPercent: Math.max(prev?.bestPercent ?? 0, p),
        lastAt:
          !prev || (a.completed_at && a.completed_at > prev.lastAt)
            ? a.completed_at ?? prev?.lastAt ?? ""
            : prev.lastAt,
        count: (prev?.count ?? 0) + 1,
      });
    }
  }

  // Enrichir + filtrer par formation si demandé
  let enrichedQuizzes = quizzes
    .map((q) => {
      const formationSlug = q.module_id
        ? moduleToFormation.get(q.module_id) ?? null
        : null;
      return {
        id: q.id,
        title: q.title,
        description: q.description,
        formation_slug: formationSlug,
        module_id: q.module_id,
        module_title: (q.modules as any)?.title ?? null,
        module_order: (q.modules as any)?.order ?? 0,
        bloc_id: (q.modules as any)?.bloc_id ?? null,
        time_limit_s: q.time_limit_s,
        timer_enabled: q.timer_enabled,
        max_attempts: q.max_attempts,
        pass_threshold: q.pass_threshold,
        question_count: questionCount.get(q.id) ?? 0,
        user_stats: userAttempts.get(q.id) ?? null,
      };
    })
    .filter((q) => !!q.formation_slug);

  if (filterFormation) {
    enrichedQuizzes = enrichedQuizzes.filter(
      (q) => q.formation_slug === filterFormation,
    );
  }

  // Liste des formations disponibles pour les chips
  const availableFormations = FORMATIONS.filter((f) =>
    enrichedQuizzes.some((q) => q.formation_slug === f.slug) ||
    quizzes.some((q) => moduleToFormation.get(q.module_id) === f.slug),
  );

  // Stats globales
  const totalQuizzes = enrichedQuizzes.length;
  const passedQuizzes = enrichedQuizzes.filter(
    (q) => (q.user_stats?.bestPercent ?? 0) >= q.pass_threshold,
  ).length;

  return (
    <div className="space-y-8">
      {/* ----- Hero ----- */}
      <header className="space-y-3">
        <div className="inline-flex items-center gap-2 px-2.5 py-1 rounded-full bg-signal-50 border border-signal-200 text-signal-800 text-[11px] font-bold uppercase tracking-[0.16em]">
          <Dumbbell className="h-3 w-3" />
          {t("badge")}
        </div>
        <h1 className="font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          {firstName ? t("titleWithName", { name: firstName }) : t("titleAnonymous")}
        </h1>
        <p className="text-slate-600 max-w-2xl leading-relaxed">
          {t("description")}{" "}
          <strong className="text-navy-900">
            {t("descriptionStrong")}
          </strong>
        </p>
        {totalQuizzes > 0 && (
          <div className="flex items-center gap-4 text-[13px] text-slate-600 flex-wrap pt-2">
            <span className="inline-flex items-center gap-1.5">
              <Sparkles className="h-3.5 w-3.5 text-signal-700" />
              {t("countAvailable", { count: totalQuizzes })}
            </span>
            {passedQuizzes > 0 && (
              <span className="inline-flex items-center gap-1.5 text-emerald-700">
                · {t("countPassed", { count: passedQuizzes })}
              </span>
            )}
          </div>
        )}
      </header>

      {/* ----- Filtre formation ----- */}
      {availableFormations.length > 1 && (
        <section className="rounded-2xl border border-navy-100 bg-white p-3">
          <div className="flex items-center gap-2 px-1.5 mb-2">
            <Filter className="h-3.5 w-3.5 text-slate-400" />
            <span className="text-[11px] font-semibold uppercase tracking-[0.14em] text-slate-500">
              {t("filterEyebrow")}
            </span>
          </div>
          <div className="flex flex-wrap gap-1.5">
            <FormationChip
              href="/exercices"
              label={t("filterAll")}
              active={!filterFormation}
            />
            {availableFormations.map((f) => (
              <FormationChip
                key={f.slug}
                href={`/exercices?f=${f.slug}`}
                label={f.code}
                accent={f.accent}
                active={filterFormation === f.slug}
              />
            ))}
          </div>
        </section>
      )}

      {/* ----- Catalogue (groupé par formation > module) ----- */}
      <ExercicesCatalog
        quizzes={enrichedQuizzes}
        formationsAvailable={availableFormations.map((f) => ({
          slug: f.slug,
          code: f.code,
          accent: f.accent ?? "#9FE220",
        }))}
      />

      {/* État vide */}
      {totalQuizzes === 0 && (
        <div className="rounded-2xl border-2 border-dashed border-navy-100 bg-ivory p-10 text-center">
          <BookOpen className="h-10 w-10 mx-auto text-slate-400" />
          <h3 className="mt-3 font-display text-lg font-semibold text-navy-900">
            {t("emptyTitle")}
          </h3>
          <p className="mt-2 text-sm text-slate-600 max-w-md mx-auto">
            {t("emptyHint")}
          </p>
        </div>
      )}
    </div>
  );
}

// ---------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------

function FormationChip({
  href,
  label,
  accent,
  active,
}: {
  href: string;
  label: string;
  accent?: string;
  active: boolean;
}) {
  return (
    <a
      href={href}
      className={
        "inline-flex items-center gap-1.5 rounded-lg px-3 py-1.5 text-[12px] font-medium border transition-colors " +
        (active
          ? "bg-navy-900 text-white border-navy-900"
          : "bg-white text-navy-800 border-navy-100 hover:border-navy-300 hover:bg-navy-50")
      }
    >
      {accent && (
        <span
          className="inline-block h-1.5 w-1.5 rounded-full"
          style={{ background: accent }}
        />
      )}
      {label}
    </a>
  );
}

function extractFirstName(fullName: string | null): string | null {
  if (!fullName) return null;
  const first = fullName.trim().split(/\s+/)[0];
  if (!first) return null;
  return first
    .split("-")
    .map((p) => p.charAt(0).toUpperCase() + p.slice(1).toLowerCase())
    .join("-");
}
