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
import { computeUnlockedModuleIds } from "@/lib/module-unlock";
import type { Tables } from "@/lib/database.types";

export const dynamic = "force-dynamic";

// ── Formes exactes des lignes lues (miroir des `.select(...)` ci-dessous) ──
type FormationLink = { formation: Pick<Tables<"formations">, "slug"> | null };
type FormationModuleRow = Pick<Tables<"formation_modules">, "module_id"> &
  FormationLink;
type FormationQuizRow = Pick<Tables<"formation_quizzes">, "quiz_id"> &
  FormationLink;

/** Quiz + module embarqué (select `..., modules(id, title, slug, order)`). */
type ExamQuizRow = Pick<
  Tables<"quizzes">,
  | "id"
  | "title"
  | "description"
  | "type"
  | "is_mock_exam"
  | "pass_threshold"
  | "time_limit_s"
  | "timer_enabled"
  | "max_attempts"
  | "retake_delay_hours"
  | "module_id"
> & {
  modules: Pick<Tables<"modules">, "id" | "title" | "slug" | "order"> | null;
};

/**
 * Tentative + titre du quiz embarqué.
 * NB : `completed_at` est demandé par le `.select(...)` ci-dessous mais
 * n'existe PAS dans `supabase/schema.sql` (quiz_attempts n'a que
 * `started_at` / `finished_at`). On garde la forme telle qu'elle est lue
 * pour ne rien changer au comportement — à corriger séparément.
 */
type ExamAttemptRow = Pick<
  Tables<"quiz_attempts">,
  "id" | "quiz_id" | "percentage" | "finished_at" | "passed" | "duration_s" | "status"
> & {
  completed_at: string | null;
  quizzes: Pick<Tables<"quizzes">, "title"> | null;
};

/** Carte d'examen enrichie transmise aux composants clients. */
type EnrichedExam = {
  id: string;
  title: string;
  description: string | null;
  formation_slug: string | null;
  module_id: string | null;
  module_title: string | null;
  module_order: number;
  scope: "module" | "global";
  time_limit_s: number | null;
  timer_enabled: boolean;
  max_attempts: number | null;
  retake_delay_hours: number;
  pass_threshold: number;
  is_mock_exam: boolean;
  question_count: number;
  user_stats: UserExamStats | null;
  locked: boolean;
};

type UserExamStats = {
  bestPercent: number;
  lastAt: string;
  count: number;
  passed: boolean;
};

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

  // Inscriptions actives → formations accessibles. Staff voit toutes
  // les formations actives ; student via ses enrollments (client
  // session, RLS réparées).
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
      enrolledFormationIds = (
        (allFormations ?? []) as Pick<Tables<"formations">, "id">[]
      ).map((f) => f.id);
    } else {
      const { data: enrollments } = await supabase
        .from("enrollments")
        .select("formation_id, status")
        .eq("user_id", user.id)
        .not("formation_id", "is", null)
        .neq("status", "refuse")
        .neq("status", "abandon");
      enrolledFormationIds = (
        (enrollments ?? []) as Pick<
          Tables<"enrollments">,
          "formation_id" | "status"
        >[]
      )
        .map((e) => e.formation_id)
        .filter((id): id is string => !!id);
    }
  }
  // Lectures catalogue via client session (RLS scopées réparées)
  const reader = supabase;

  // Modules accessibles via formation_modules
  let allowedModuleIds: string[] = [];
  const moduleToFormation = new Map<string, string>();
  if (enrolledFormationIds.length > 0) {
    // `overrideTypes` : sans le générique `Database` sur le client, supabase-js
    // ne connaît pas la cardinalité des embeds et les infère en tableau, alors
    // que PostgREST renvoie bien un objet (relation *-vers-un).
    const { data: fm } = await reader
      .from("formation_modules")
      .select("module_id, formation:formations(slug)")
      .in("formation_id", enrolledFormationIds)
      .overrideTypes<FormationModuleRow[], { merge: false }>();
    for (const row of fm ?? []) {
      const slug = row.formation?.slug;
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
      .in("formation_id", enrolledFormationIds)
      .overrideTypes<FormationQuizRow[], { merge: false }>();
    for (const row of fq ?? []) {
      const slug = row.formation?.slug;
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
      : Promise.resolve({ data: [] as ExamQuizRow[] });

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
      : Promise.resolve({ data: [] as ExamQuizRow[] });

  const [{ data: modScopedData }, { data: globalData }] = await Promise.all([
    moduleScopedPromise,
    globalPromise,
  ]);
  const modScoped = (modScopedData ?? []) as ExamQuizRow[];
  const globalRaw = (globalData ?? []) as ExamQuizRow[];

  // Comptage de questions
  const allQuizIds = [
    ...modScoped.map((q) => q.id),
    ...globalRaw.map((q) => q.id),
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
  for (const row of (bankLinks ?? []) as Pick<
    Tables<"quiz_question_bank">,
    "quiz_id"
  >[])
    questionCount.set(row.quiz_id, (questionCount.get(row.quiz_id) ?? 0) + 1);
  for (const row of (inlineQs ?? []) as Pick<
    Tables<"questions">,
    "quiz_id"
  >[])
    questionCount.set(row.quiz_id, (questionCount.get(row.quiz_id) ?? 0) + 1);

  // Stats user agrégées + historique complet (10 dernières tentatives)
  let userAttempts = new Map<string, UserExamStats>();
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
    const { data: attemptsData } = await reader
      .from("quiz_attempts")
      .select(
        "id, quiz_id, percentage, completed_at, finished_at, passed, duration_s, status, quizzes(title)",
      )
      .eq("user_id", user.id)
      .in("quiz_id", allQuizIds)
      .order("finished_at", { ascending: false })
      .overrideTypes<ExamAttemptRow[], { merge: false }>();
    const attempts = attemptsData ?? [];
    for (const a of attempts) {
      const prev = userAttempts.get(a.quiz_id);
      // Une copie en attente de correction (awaiting_review) a
      // percentage = null : on ne la compte PAS comme 0 % dans le best
      // score / passed (sinon affichage trompeur "échec" alors qu'elle
      // n'est juste pas encore corrigée). Seules les tentatives notées
      // (percentage non-null) entrent dans bestPercent/passed.
      const isGraded =
        typeof a.percentage === "number" && a.status !== "awaiting_review";
      const p = isGraded ? a.percentage : null;
      userAttempts.set(a.quiz_id, {
        bestPercent:
          p !== null
            ? Math.max(prev?.bestPercent ?? 0, p)
            : prev?.bestPercent ?? 0,
        lastAt:
          !prev || (a.completed_at && a.completed_at > prev.lastAt)
            ? a.completed_at ?? prev?.lastAt ?? ""
            : prev.lastAt,
        count: (prev?.count ?? 0) + 1,
        passed: prev?.passed || (isGraded && !!a.passed),
      });
    }
    attemptHistory = attempts
      .filter(
        (a): a is ExamAttemptRow & { finished_at: string } => !!a.finished_at,
      )
      .slice(0, 10)
      .map((a) => ({
        id: a.id,
        quiz_id: a.quiz_id,
        quiz_title: a.quizzes?.title ?? "Examen",
        percentage: a.percentage ?? 0,
        passed: !!a.passed,
        finished_at: a.finished_at,
        duration_s: a.duration_s ?? null,
      }));
  }

  // Verrouillage linéaire — STRICTEMENT aligné sur /modules : un examen
  // blanc DE MODULE est verrouillé tant que les leçons du module
  // précédent ne sont pas terminées. Les examens GLOBAUX (finaux) ne
  // sont jamais verrouillés par ce mécanisme. Comme sur /modules, le
  // verrouillage s'applique à TOUS les comptes (staff compris) selon
  // leur propre progression — pas d'exemption.
  let unlockedModuleIds = new Set<string>();
  if (user && allowedModuleIds.length > 0) {
    unlockedModuleIds = await computeUnlockedModuleIds(
      reader,
      user.id,
      allowedModuleIds,
      moduleToFormation,
    );
  }
  const isModuleLocked = (moduleId: string | null): boolean => {
    if (!user) return false;
    if (!moduleId) return false;
    return !unlockedModuleIds.has(moduleId);
  };

  const enrichExam = (
    q: ExamQuizRow,
    scope: "module" | "global",
  ): EnrichedExam => {
    const formationSlug =
      scope === "module"
        ? (q.module_id ? moduleToFormation.get(q.module_id) : undefined) ?? null
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
      locked: scope === "module" ? isModuleLocked(q.module_id) : false,
    };
  };

  let moduleExams: EnrichedExam[] = modScoped
    .map((q) => enrichExam(q, "module"))
    .filter((q) => !!q.formation_slug);
  let globalExams: EnrichedExam[] = globalRaw
    .map((q) => enrichExam(q, "global"))
    .filter((q) => !!q.formation_slug);

  if (filterFormation) {
    moduleExams = moduleExams.filter(
      (q) => q.formation_slug === filterFormation,
    );
    globalExams = globalExams.filter(
      (q) => q.formation_slug === filterFormation,
    );
  }

  const totalExams = moduleExams.length + globalExams.length;
  const passedExams = [...moduleExams, ...globalExams].filter(
    (q) => q.user_stats?.passed,
  ).length;

  // Formations affichables dans les chips
  const availableFormations = FORMATIONS.filter((f) => {
    return (
      moduleExams.some((q) => q.formation_slug === f.slug) ||
      globalExams.some((q) => q.formation_slug === f.slug) ||
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
  rows: ExamQuizRow[] | null,
  moduleToFormation: Map<string, string>,
  slug: string,
): boolean {
  return (rows ?? []).some(
    (q) =>
      (q.module_id ? moduleToFormation.get(q.module_id) : undefined) === slug,
  );
}

function globalExistsForFormation(
  rows: ExamQuizRow[] | null,
  quizToFormation: Map<string, string>,
  slug: string,
): boolean {
  return (rows ?? []).some((q) => quizToFormation.get(q.id) === slug);
}
