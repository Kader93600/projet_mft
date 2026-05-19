// =====================================================================
// /examens-blancs — Cockpit EXAMENS BLANCS du stagiaire (refonte 2026-05).
//
// Regroupe en UNE SEULE page :
//   - les examens blancs par module (quizzes.module_id NOT NULL, type=examen
//     OR is_mock_exam=true)
//   - les examens blancs globaux (module_id NULL, ou marqués globaux)
//
// Vibe : style "officiel", gold/amber accent, timer visible, scoring réel,
// historique des tentatives.
// =====================================================================

import { getTranslations } from "next-intl/server";
import { createClient } from "@/lib/supabase/server";
import { FormationBadge } from "@/components/formation/formation-badge";
import { FORMATIONS } from "@/lib/formations-config";
import {
  GraduationCap,
  Trophy,
  Clock,
  ShieldCheck,
  Filter,
} from "lucide-react";
import { ExamensTabs } from "./examens-tabs";
import { AttemptsHistory } from "./attempts-history";

export const dynamic = "force-dynamic";

export default async function ExamensBlancsPage({
  searchParams,
}: {
  searchParams?: { f?: string; tab?: string };
}) {
  const t = await getTranslations("examensBlancs");
  const supabase = createClient();
  const filterFormation = searchParams?.f ?? null;
  const tab = (searchParams?.tab === "global" ? "global" : "module") as
    | "module"
    | "global";

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
  // Staff : bypass — voit toutes les formations actives.
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
        .not("formation_id", "is", null)
        .neq("status", "refuse")
        .neq("status", "abandon");
      enrolledFormationIds = (enrollments ?? [])
        .map((e: any) => e.formation_id)
        .filter(Boolean);
    }
  }
  // Reader pour les fetches catalogue (bypass RLS sur quizzes pour student)
  const reader = isStaffUser ? supabase : ac();

  // Modules accessibles via formation_modules
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

  // Quiz par formation directe (pour les examens GLOBAUX rattachés via
  // formation_quizzes plutôt que via un module)
  let quizIdsByFormation = new Map<string, string>();
  if (enrolledFormationIds.length > 0) {
    const { data: fq } = await reader
      .from("formation_quizzes")
      .select("quiz_id, formation:formations(slug)")
      .in("formation_id", enrolledFormationIds);
    for (const row of fq ?? []) {
      const slug = (row as any).formation?.slug;
      if (slug) quizIdsByFormation.set(row.quiz_id, slug);
    }
  }
  const globalQuizIds = Array.from(quizIdsByFormation.keys());

  // Fetch examens (type='examen' OR is_mock_exam=true)
  const orFilter = "type.eq.examen,is_mock_exam.eq.true";

  const moduleScopedPromise =
    allowedModuleIds.length > 0
      ? reader
          .from("quizzes")
          .select(
            "id, title, description, type, is_mock_exam, pass_threshold, " +
              "time_limit_s, timer_enabled, max_attempts, retake_delay_hours, " +
              "module_id, modules(id, title, slug, order)",
          )
          .in("module_id", allowedModuleIds)
          .or(orFilter)
      : Promise.resolve({ data: [] as any[] });

  const globalPromise =
    globalQuizIds.length > 0
      ? reader
          .from("quizzes")
          .select(
            "id, title, description, type, is_mock_exam, pass_threshold, " +
              "time_limit_s, timer_enabled, max_attempts, retake_delay_hours, " +
              "module_id, modules(id, title, slug, order)",
          )
          .in("id", globalQuizIds)
          .is("module_id", null)
          .or(orFilter)
      : Promise.resolve({ data: [] as any[] });

  const [{ data: modScoped }, { data: globalRaw }] = await Promise.all([
    moduleScopedPromise,
    globalPromise,
  ]);

  // Comptage de questions
  const allQuizIds = [
    ...(modScoped ?? []).map((q: any) => q.id),
    ...(globalRaw ?? []).map((q: any) => q.id),
  ];
  const [{ data: bankLinks }, { data: inlineQs }] =
    allQuizIds.length > 0
      ? await Promise.all([
          reader
            .from("quiz_question_bank")
            .select("quiz_id")
            .in("quiz_id", allQuizIds),
          reader
            .from("questions")
            .select("quiz_id")
            .in("quiz_id", allQuizIds),
        ])
      : [
          { data: [] as { quiz_id: string }[] },
          { data: [] as { quiz_id: string }[] },
        ];
  const questionCount = new Map<string, number>();
  for (const row of bankLinks ?? [])
    questionCount.set(row.quiz_id, (questionCount.get(row.quiz_id) ?? 0) + 1);
  for (const row of inlineQs ?? [])
    questionCount.set(row.quiz_id, (questionCount.get(row.quiz_id) ?? 0) + 1);

  // Stats user agrégées + historique complet (10 dernières tentatives)
  let userAttempts = new Map<
    string,
    { bestPercent: number; lastAt: string; count: number; passed: boolean }
  >();
  type AttemptHistoryRow = {
    id: string;
    quiz_id: string;
    quiz_title: string;
    percentage: number;
    passed: boolean;
    finished_at: string;
    duration_s: number | null;
  };
  let attemptHistory: AttemptHistoryRow[] = [];
  if (user && allQuizIds.length > 0) {
    const { data: attempts } = await reader
      .from("quiz_attempts")
      .select(
        "id, quiz_id, percentage, completed_at, finished_at, passed, duration_s, quizzes(title)",
      )
      .eq("user_id", user.id)
      .in("quiz_id", allQuizIds)
      .order("finished_at", { ascending: false });
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
        passed: prev?.passed || !!a.passed,
      });
    }
    attemptHistory = (attempts ?? [])
      .filter((a: any) => a.finished_at)
      .slice(0, 10)
      .map((a: any) => ({
        id: a.id,
        quiz_id: a.quiz_id,
        quiz_title: a.quizzes?.title ?? "Examen",
        percentage: a.percentage ?? 0,
        passed: !!a.passed,
        finished_at: a.finished_at,
        duration_s: a.duration_s ?? null,
      }));
  }

  const enrichExam = (q: any, scope: "module" | "global") => {
    const formationSlug =
      scope === "module"
        ? moduleToFormation.get(q.module_id) ?? null
        : quizIdsByFormation.get(q.id) ?? null;
    return {
      id: q.id,
      title: q.title,
      description: q.description,
      formation_slug: formationSlug,
      module_id: q.module_id,
      module_title: q.modules?.title ?? null,
      module_order: q.modules?.order ?? 0,
      scope,
      time_limit_s: q.time_limit_s,
      timer_enabled: q.timer_enabled,
      max_attempts: q.max_attempts,
      retake_delay_hours: q.retake_delay_hours,
      pass_threshold: q.pass_threshold,
      is_mock_exam: q.is_mock_exam,
      question_count: questionCount.get(q.id) ?? 0,
      user_stats: userAttempts.get(q.id) ?? null,
    };
  };

  let moduleExams = (modScoped ?? [])
    .map((q: any) => enrichExam(q, "module"))
    .filter((q: any) => !!q.formation_slug);
  let globalExams = (globalRaw ?? [])
    .map((q: any) => enrichExam(q, "global"))
    .filter((q: any) => !!q.formation_slug);

  if (filterFormation) {
    moduleExams = moduleExams.filter(
      (q: any) => q.formation_slug === filterFormation,
    );
    globalExams = globalExams.filter(
      (q: any) => q.formation_slug === filterFormation,
    );
  }

  const totalExams = moduleExams.length + globalExams.length;
  const passedExams = [...moduleExams, ...globalExams].filter(
    (q: any) => q.user_stats?.passed,
  ).length;

  // Formations affichables dans les chips
  const availableFormations = FORMATIONS.filter((f) => {
    return (
      moduleExams.some((q: any) => q.formation_slug === f.slug) ||
      globalExams.some((q: any) => q.formation_slug === f.slug) ||
      moduleScopedExistsForFormation(modScoped, moduleToFormation, f.slug) ||
      globalExistsForFormation(globalRaw, quizIdsByFormation, f.slug)
    );
  });

  return (
    <div className="space-y-8">
      {/* ----- Hero ----- */}
      <header className="space-y-3">
        <div className="inline-flex items-center gap-2 px-2.5 py-1 rounded-full bg-amber-50 border border-amber-200 text-amber-900 text-[11px] font-bold uppercase tracking-[0.16em]">
          <GraduationCap className="h-3 w-3" />
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
        {totalExams > 0 && (
          <div className="flex items-center gap-4 text-[13px] text-slate-600 flex-wrap pt-2">
            <span className="inline-flex items-center gap-1.5">
              <ShieldCheck className="h-3.5 w-3.5 text-amber-700" />
              {t("countAvailable", { count: totalExams })}
            </span>
            {passedExams > 0 && (
              <span className="inline-flex items-center gap-1.5 text-emerald-700">
                <Trophy className="h-3.5 w-3.5" />
                {t("countPassed", { count: passedExams })}
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
              href={`/examens-blancs${tab === "global" ? "?tab=global" : ""}`}
              label={t("filterAll")}
              active={!filterFormation}
            />
            {availableFormations.map((f) => (
              <FormationChip
                key={f.slug}
                href={`/examens-blancs?f=${f.slug}${tab === "global" ? "&tab=global" : ""}`}
                label={f.code}
                accent={f.accent}
                active={filterFormation === f.slug}
              />
            ))}
          </div>
        </section>
      )}

      {/* ----- Historique des tentatives ----- */}
      {attemptHistory.length > 0 && (
        <AttemptsHistory attempts={attemptHistory} />
      )}

      {/* ----- Tabs : par module / globaux ----- */}
      <ExamensTabs
        moduleExams={moduleExams}
        globalExams={globalExams}
        activeTab={tab}
        filterFormation={filterFormation}
      />

      {/* État vide */}
      {totalExams === 0 && (
        <div className="rounded-2xl border-2 border-dashed border-navy-100 bg-ivory p-10 text-center">
          <GraduationCap className="h-10 w-10 mx-auto text-slate-400" />
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

function moduleScopedExistsForFormation(
  rows: any[] | null,
  moduleToFormation: Map<string, string>,
  slug: string,
): boolean {
  return (rows ?? []).some(
    (q: any) => moduleToFormation.get(q.module_id) === slug,
  );
}

function globalExistsForFormation(
  rows: any[] | null,
  quizToFormation: Map<string, string>,
  slug: string,
): boolean {
  return (rows ?? []).some((q: any) => quizToFormation.get(q.id) === slug);
}
