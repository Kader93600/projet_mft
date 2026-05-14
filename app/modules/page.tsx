import { createClient } from "@/lib/supabase/server";
import { ModuleCard, type ModuleCardData } from "@/components/modules/module-card";
import { ContinueCard } from "@/components/modules/continue-card";
import { FormationProgress } from "@/components/modules/formation-progress";
import { FormationBadge } from "@/components/formation/formation-badge";
import { findFormation, FORMATIONS } from "@/lib/formations-config";
import {
  applyLinearLocking,
  computeModulePercent,
  computeModuleState,
  getModuleKind,
  getUnlockMode,
  pickNextModule,
  type ModuleProgress,
} from "@/lib/module-progress";
import { AlertCircle, BookOpen, GraduationCap, Layers, Lock } from "lucide-react";

export const dynamic = "force-dynamic";

/**
 * Catalogue stagiaire — refonte 2026-05 (cockpit).
 *
 * Pivot stratégique : la page n'est plus un catalogue admin mais un
 * cockpit d'apprentissage qui répond à "que dois-je faire maintenant ?".
 *
 *  - Hero personnalisé "Bonjour [Prénom]"
 *  - ContinueCard avec CTA principal (signal-500) — exclusif sur l'écran
 *  - Progression globale par formation (barre compacte)
 *  - Sections par formation, sous-groupées :
 *      • Cours (modules 'course')
 *      • Préparer l'examen final (exam + final)
 *  - États visuels par module : terminé / en cours / non commencé / verrouillé
 *  - Verrouillage linéaire (un module est déverrouillé si le précédent
 *    est terminé)
 *
 * Données :
 *  - profiles : full_name (pour le prénom)
 *  - enrollments : formation active (statut != refuse/abandon)
 *  - formation_modules : ordre + rattachement
 *  - lessons : compte par module
 *  - lesson_views : leçons complétées (`completed = true`)
 *  - quizzes : compte par module
 *  - quiz_attempts : passed = true → quiz validé
 */
export default async function ModulesPage() {
  const supabase = createClient();

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

  // Formations où le stagiaire est inscrit (1 ou plusieurs)
  // + formation active (la "courante" — sera mise en premier visuellement)
  let enrolledFormationIds: string[] = [];
  let activeFormationSlug: string | null = null;
  if (user) {
    const { data: enrollments } = await supabase
      .from("enrollments")
      .select("formation_id, formation_slug, status, created_at")
      .eq("user_id", user.id)
      .not("formation_id", "is", null)
      .not("status", "in", "(refuse,abandon)")
      .order("created_at", { ascending: false });
    enrolledFormationIds = (enrollments ?? [])
      .map((e: any) => e.formation_id as string)
      .filter(Boolean);
    // active = en_cours en priorité, sinon le plus récent
    const sorted = [...(enrollments ?? [])].sort((a: any, b: any) => {
      const ar = a.status === "en_cours" ? 0 : 1;
      const br = b.status === "en_cours" ? 0 : 1;
      if (ar !== br) return ar - br;
      return (
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
      );
    });
    activeFormationSlug = (sorted[0] as any)?.formation_slug ?? null;
  }

  // Filtrage par formation : on récupère uniquement les modules rattachés
  // aux formations où le stagiaire est inscrit.
  let allowedModuleIds: string[] = [];
  let links: any[] = [];
  if (enrolledFormationIds.length > 0) {
    const { data: linkRows } = await supabase
      .from("formation_modules")
      .select("module_id, display_order, formation:formations(slug)")
      .in("formation_id", enrolledFormationIds);
    links = linkRows ?? [];
    allowedModuleIds = Array.from(
      new Set(links.map((l: any) => l.module_id as string))
    );
  }

  // Données catalogue (filtrées)
  const noModules = allowedModuleIds.length === 0;
  const [
    { data: modules },
    { data: lessonsRaw },
    { data: quizzesRaw },
  ] = noModules
    ? [
        { data: [] as any[] },
        { data: [] as any[] },
        { data: [] as any[] },
      ]
    : await Promise.all([
        supabase
          .from("modules")
          .select("*")
          .in("id", allowedModuleIds)
          .order("order"),
        supabase
          .from("lessons")
          .select("id, module_id")
          .in("module_id", allowedModuleIds),
        supabase
          .from("quizzes")
          .select("id, module_id")
          .in("module_id", allowedModuleIds),
      ]);

  // Blocs (CCP) : on les charge tous pour pouvoir grouper les modules.
  // Pour GOTRM : BC1 = CCP1, BC2 = CCP2, BC3 = CCP3.
  const { data: blocsRaw } = await supabase
    .from("blocs")
    .select('id, code, title, "order"')
    .order("order");
  const blocsById = new Map<
    number,
    { id: number; code: string; title: string; order: number }
  >();
  for (const b of blocsRaw ?? []) {
    blocsById.set((b as any).id, b as any);
  }

  // Données de progression utilisateur
  // ⚠️ 2 sources pour le statut "leçon terminée" :
  //   - lesson_progress : marqué explicitement via le bouton "Marquer terminé"
  //   - lesson_views    : tracking implicite (ping après lecture complète)
  // On fait l'UNION (completed=true dans l'une OU l'autre suffit) pour
  // éviter qu'un user ayant cliqué "Marquer terminé" voie 0/5 ici alors
  // que la page détail affiche 5/5.
  let lessonViews: { lesson_id: string; completed: boolean; last_ping_at: string }[] =
    [];
  let lessonProgressDone: Set<string> = new Set();
  let quizAttempts: {
    quiz_id: string;
    passed: boolean;
    finished_at: string | null;
  }[] = [];
  if (user) {
    const [{ data: views }, { data: progressRows }, { data: attempts }] =
      await Promise.all([
        supabase
          .from("lesson_views")
          .select("lesson_id, completed, last_ping_at")
          .eq("user_id", user.id),
        supabase
          .from("lesson_progress")
          .select("lesson_id, completed")
          .eq("user_id", user.id)
          .eq("completed", true),
        supabase
          .from("quiz_attempts")
          .select("quiz_id, passed, finished_at")
          .eq("user_id", user.id),
      ]);
    lessonViews = views ?? [];
    lessonProgressDone = new Set(
      (progressRows ?? []).map((r: any) => r.lesson_id as string)
    );
    quizAttempts = attempts ?? [];
  }

  // Index pour l'agrégation
  const formationByModule = new Map<string, string>();
  const orderByModule = new Map<string, number>();
  (links ?? []).forEach((l: any) => {
    if (l.formation?.slug && !formationByModule.has(l.module_id)) {
      formationByModule.set(l.module_id, l.formation.slug);
    }
    if (l.display_order != null && !orderByModule.has(l.module_id)) {
      orderByModule.set(l.module_id, l.display_order);
    }
  });

  const lessonsByModule = new Map<string, string[]>();
  (lessonsRaw ?? []).forEach((l: any) => {
    if (!lessonsByModule.has(l.module_id)) lessonsByModule.set(l.module_id, []);
    lessonsByModule.get(l.module_id)!.push(l.id);
  });

  const quizzesByModule = new Map<string, string[]>();
  (quizzesRaw ?? []).forEach((q: any) => {
    if (!quizzesByModule.has(q.module_id)) quizzesByModule.set(q.module_id, []);
    quizzesByModule.get(q.module_id)!.push(q.id);
  });

  // Union des 2 sources : leçon "done" si lesson_views.completed OU
  // lesson_progress.completed (cf. commentaire plus haut).
  const completedLessonIds = new Set<string>([
    ...lessonViews.filter((v) => v.completed).map((v) => v.lesson_id),
    ...lessonProgressDone,
  ]);
  const passedQuizIds = new Set(
    quizAttempts.filter((a) => a.passed).map((a) => a.quiz_id)
  );
  // Quiz essayés (au moins 1 tentative, peu importe le score) — utilisé par
  // les formations en mode déverrouillage 'flexible' (ex: Capacité ≤ 3,5 t).
  const attemptedQuizIds = new Set(quizAttempts.map((a) => a.quiz_id));

  // Dernière interaction par module : max(last_ping_at, finished_at)
  const lastTouchByModule = new Map<string, string>();
  for (const [mid, lessonIds] of lessonsByModule) {
    let max: string | null = null;
    for (const lid of lessonIds) {
      const view = lessonViews.find((v) => v.lesson_id === lid);
      if (view?.last_ping_at) {
        if (!max || view.last_ping_at > max) max = view.last_ping_at;
      }
    }
    if (max) lastTouchByModule.set(mid, max);
  }
  for (const [mid, quizIds] of quizzesByModule) {
    let max = lastTouchByModule.get(mid) ?? null;
    for (const qid of quizIds) {
      const attempt = quizAttempts.find((a) => a.quiz_id === qid);
      const ts = attempt?.finished_at;
      if (ts) {
        if (!max || ts > max) max = ts;
      }
    }
    if (max) lastTouchByModule.set(mid, max);
  }

  // Construction des ModuleProgress + ModuleCardData
  const allCards: (ModuleCardData & { __progress: ModuleProgress })[] = (
    modules ?? []
  ).map((m: any) => {
    const lessonIds = lessonsByModule.get(m.id) ?? [];
    const quizIds = quizzesByModule.get(m.id) ?? [];
    const lessonsTotal = lessonIds.length;
    const lessonsDone = lessonIds.filter((id) => completedLessonIds.has(id))
      .length;
    const quizzesTotal = quizIds.length;
    const quizzesPassed = quizIds.filter((id) => passedQuizIds.has(id)).length;
    const quizzesAttempted = quizIds.filter((id) => attemptedQuizIds.has(id))
      .length;
    const hasAnyAttempt =
      lessonsDone > 0 ||
      quizzesPassed > 0 ||
      lessonIds.some((id) => lessonViews.some((v) => v.lesson_id === id)) ||
      quizIds.some((id) => quizAttempts.some((a) => a.quiz_id === id));

    // Mode de déverrouillage : 'flexible' pour Capacité ≤ 3,5 t, 'strict'
    // ailleurs (révision client 2026-05).
    const formationSlug = formationByModule.get(m.id) ?? null;
    const unlockMode = getUnlockMode(formationSlug);

    const baseState = computeModuleState({
      lessonsTotal,
      lessonsDone,
      quizzesTotal,
      quizzesPassed,
      quizzesAttempted,
      hasAnyAttempt,
      unlockMode,
    });

    const percent = computeModulePercent({
      lessonsTotal,
      lessonsDone,
      quizzesTotal,
      quizzesPassed,
      quizzesAttempted,
      unlockMode,
    });

    const kind = getModuleKind(m.slug);
    const order = orderByModule.get(m.id) ?? m.order ?? 0;

    const progress: ModuleProgress = {
      slug: m.slug,
      id: m.id,
      kind,
      order,
      lessonsTotal,
      lessonsDone,
      quizzesTotal,
      quizzesPassed,
      quizzesAttempted,
      percent,
      state: baseState,
      lastTouchedAt: lastTouchByModule.get(m.id) ?? null,
      formationSlug: formationSlug ?? undefined,
    };

    return {
      id: m.id,
      slug: m.slug,
      title: m.title,
      summary: m.summary,
      duration_min: m.duration_min,
      difficulty: m.difficulty,
      formation_slug: formationSlug,
      lessons_count: lessonsTotal,
      quizzes_count: quizzesTotal,
      lessons_done: lessonsDone,
      tagline: null,
      state: baseState,
      kind,
      percent,
      __progress: progress,
      // Info bloc (CCP) — utilisée pour grouper les modules GOTRM
      // par CCP1/CCP2/CCP3 sur la page stagiaire.
      __bloc: m.bloc_id ? blocsById.get(m.bloc_id) ?? null : null,
    };
  });

  // Groupement par formation, dans l'ordre de FORMATIONS
  // (on conserve toutes les formations qui ont des modules visibles ; la
  // formation active sera mise en premier, les autres restent visibles
  // pour ne pas masquer le catalogue staff/admin).
  const grouped = FORMATIONS.map((f) => {
    const modulesOfFormation = allCards.filter(
      (c) => c.formation_slug === f.slug
    );
    // Verrouillage linéaire appliqué sur les modules de cette formation
    const progressList = modulesOfFormation.map((c) => c.__progress);
    const lockedProgressList = applyLinearLocking(progressList);
    const lockedById = new Map(lockedProgressList.map((p) => [p.id, p]));
    const cards = modulesOfFormation.map((c) => {
      const lp = lockedById.get(c.id)!;
      return {
        ...c,
        state: lp.state,
        __progress: lp,
      };
    });
    return { formation: f, modules: cards };
  }).filter((g) => g.modules.length > 0);

  // Tri : formation active en premier
  if (activeFormationSlug) {
    grouped.sort((a, b) => {
      if (a.formation.slug === activeFormationSlug) return -1;
      if (b.formation.slug === activeFormationSlug) return 1;
      return 0;
    });
  }

  // Calcul de la formation active réelle (pour la ContinueCard)
  // Priorité : formation enrollment > première formation visible
  const primaryGroup = grouped[0];
  const primaryProgressList = primaryGroup
    ? primaryGroup.modules.map((c) => c.__progress)
    : [];
  const nextModule = primaryGroup ? pickNextModule(primaryProgressList) : null;
  const nextModuleData = nextModule
    ? primaryGroup!.modules.find((c) => c.id === nextModule.id)
    : null;
  const allDoneInPrimary =
    primaryGroup &&
    primaryGroup.modules.length > 0 &&
    primaryGroup.modules.every((c) => c.state === "done");
  const globalPercent =
    primaryProgressList.length === 0
      ? 0
      : Math.round(
          primaryProgressList.reduce((acc, p) => acc + p.percent, 0) /
            primaryProgressList.length
        );

  const orphans = allCards.filter((c) => !c.formation_slug);
  const totalModules = allCards.length;

  return (
    <div className="space-y-10 md:space-y-12">
      {/* ----- Hero personnalisé ----- */}
      <header>
        <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-700">
          Tableau de bord
        </span>
        <h1 className="mt-2 font-display text-[28px] md:text-4xl font-semibold text-navy-950 tracking-tight leading-tight">
          {firstName ? `Bonjour ${firstName},` : "Bonjour,"}{" "}
          <span className="text-slate-600 font-normal">voici votre formation.</span>
        </h1>
      </header>

      {/* ----- ContinueCard ----- */}
      {primaryGroup &&
        (nextModule || allDoneInPrimary) && (
          <ContinueCard
            firstName={firstName}
            nextModule={nextModule}
            moduleData={
              nextModuleData
                ? {
                    slug: nextModuleData.slug,
                    title: nextModuleData.title,
                    formation_slug: nextModuleData.formation_slug,
                    duration_min: nextModuleData.duration_min,
                  }
                : undefined
            }
            allDone={!!allDoneInPrimary}
            globalPercent={globalPercent}
          />
        )}

      {/* ----- Sections par formation ----- */}
      {grouped.map(({ formation, modules: mods }, sectionIdx) => {
        const courses = mods.filter((m) => m.kind === "course");
        const exams = mods.filter((m) => m.kind === "exam");
        const finals = mods.filter((m) => m.kind === "final");
        const examFinalCount = exams.length + finals.length;
        const modulesDone = mods.filter((m) => m.state === "done").length;
        const isPrimary = sectionIdx === 0;

        return (
          <section
            key={formation.slug}
            className="space-y-6"
            style={{
              animation: `fade-up 0.5s ease-out ${sectionIdx * 80}ms both`,
            }}
          >
            {/* Header de formation */}
            <div className="flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
              <div className="min-w-0">
                <FormationBadge
                  slug={formation.slug}
                  size="lg"
                  icon
                  withTitle
                />
                {formation.tagline && (
                  <p className="mt-2 text-[14px] text-slate-600 leading-relaxed max-w-2xl">
                    {formation.tagline}
                  </p>
                )}
              </div>
              <div className="md:w-72 shrink-0">
                <FormationProgress
                  formationSlug={formation.slug}
                  modulesTotal={mods.length}
                  modulesDone={modulesDone}
                />
              </div>
            </div>

            {/* Sous-section Cours */}
            {courses.length > 0 && (
              <SubsectionCourses
                modules={courses}
                sectionIdx={sectionIdx}
                showHeader={examFinalCount > 0}
              />
            )}

            {/* Sous-section Préparer l'examen final */}
            {examFinalCount > 0 && (
              <SubsectionExams
                exams={exams}
                finals={finals}
                sectionIdx={sectionIdx}
              />
            )}
          </section>
        );
      })}

      {/* ----- Modules orphelins (admin) ----- */}
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
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 md:gap-5">
            {orphans.map((m) => (
              <ModuleCard key={m.id} module={m} />
            ))}
          </div>
        </section>
      )}

      {/* ----- État vide global ----- */}
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

      {/* ----- Pied : compteur discret pour les staff/admins ----- */}
      {totalModules > 0 && (
        <footer className="pt-2 text-[11.5px] text-slate-400">
          <span className="inline-flex items-center gap-1.5">
            <Layers className="h-3 w-3" />
            {totalModules} module{totalModules > 1 ? "s" : ""} au catalogue
          </span>
        </footer>
      )}
    </div>
  );
}

// ---------------------------------------------------------------------
// Sous-sections
// ---------------------------------------------------------------------

function SubsectionCourses({
  modules,
  sectionIdx,
  showHeader,
}: {
  modules: (ModuleCardData & { __progress: ModuleProgress })[];
  sectionIdx: number;
  showHeader: boolean;
}) {
  // Sous-groupement par bloc (CCP) si la formation a des modules dans
  // plusieurs blocs. Pour GOTRM : BC1=CCP1, BC2=CCP2, BC3=CCP3.
  // Si tous les modules sont dans un même bloc OU sans bloc, on
  // retombe sur le rendu simple (1 grille).
  const blocsMap = new Map<
    string,
    {
      code: string;
      title: string;
      order: number;
      modules: typeof modules;
    }
  >();
  for (const m of modules) {
    const blocCode = (m as any).__bloc?.code ?? "_other";
    const blocTitle = (m as any).__bloc?.title ?? "";
    const blocOrder = (m as any).__bloc?.order ?? 999;
    if (!blocsMap.has(blocCode)) {
      blocsMap.set(blocCode, {
        code: blocCode,
        title: blocTitle,
        order: blocOrder,
        modules: [],
      });
    }
    blocsMap.get(blocCode)!.modules.push(m);
  }
  const blocs = Array.from(blocsMap.values()).sort(
    (a, b) => a.order - b.order,
  );
  const useBlocGroups = blocs.length > 1;

  // Mapping code BC → label CCP (pour GOTRM seulement, sans toucher
  // les autres formations qui n'ont pas cette nomenclature)
  const ccpLabelByCode: Record<string, string> = {
    BC1: "CCP 1",
    BC2: "CCP 2",
    BC3: "CCP 3",
  };

  if (!useBlocGroups) {
    return (
      <div className="space-y-4">
        {showHeader && (
          <div className="flex items-baseline gap-2">
            <h3 className="font-display text-[15px] font-semibold text-navy-900 tracking-tight">
              Modules de cours
            </h3>
            <span className="text-[12px] text-slate-500">
              {modules.length} module{modules.length > 1 ? "s" : ""}
            </span>
          </div>
        )}
        <ModulesGrid modules={modules} sectionIdx={sectionIdx} />
      </div>
    );
  }

  // Sous-groupement visuel par CCP — chaque bloc devient une "carte"
  // avec son header (CCP X — Titre) et sa propre grille de modules.
  return (
    <div className="space-y-6">
      {blocs.map((b, bi) => {
        const doneInBloc = b.modules.filter(
          (m) => m.state === "done",
        ).length;
        const inProgress = b.modules.filter(
          (m) => m.state === "in-progress",
        ).length;
        const ccpLabel = ccpLabelByCode[b.code] ?? b.code;
        return (
          <section
            key={b.code}
            className="rounded-3xl border border-navy-100 bg-white px-4 py-4 md:px-6 md:py-5"
            style={{
              animation: `fade-up 0.5s ease-out ${
                sectionIdx * 80 + bi * 100
              }ms both`,
            }}
          >
            <header className="flex flex-wrap items-baseline justify-between gap-3 mb-4">
              <div className="min-w-0">
                <div className="text-[10.5px] font-bold uppercase tracking-[0.18em] text-signal-700">
                  {ccpLabel}
                </div>
                <h4 className="mt-0.5 font-display text-[16px] font-semibold text-navy-950 tracking-tight">
                  {b.title || "Modules"}
                </h4>
              </div>
              <div className="text-[12px] text-slate-500 inline-flex items-center gap-2 flex-wrap">
                <span>
                  <strong className="text-navy-900">{b.modules.length}</strong>{" "}
                  module{b.modules.length > 1 ? "s" : ""}
                </span>
                {doneInBloc > 0 && (
                  <span className="text-emerald-700">
                    · {doneInBloc} terminé{doneInBloc > 1 ? "s" : ""}
                  </span>
                )}
                {inProgress > 0 && (
                  <span className="text-signal-700">
                    · {inProgress} en cours
                  </span>
                )}
              </div>
            </header>
            <ModulesGrid modules={b.modules} sectionIdx={sectionIdx + bi} />
          </section>
        );
      })}
    </div>
  );
}

function ModulesGrid({
  modules,
  sectionIdx,
}: {
  modules: (ModuleCardData & { __progress: ModuleProgress })[];
  sectionIdx: number;
}) {
  return (
    <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 md:gap-5">
      {modules.map((m, i) => (
        <div
          key={m.id}
          style={{
            animation: `fade-up 0.45s ease-out ${sectionIdx * 80 + i * 40}ms both`,
          }}
        >
          <ModuleCard module={m} />
        </div>
      ))}
    </div>
  );
}

function SubsectionExams({
  exams,
  finals,
  sectionIdx,
}: {
  exams: (ModuleCardData & { __progress: ModuleProgress })[];
  finals: (ModuleCardData & { __progress: ModuleProgress })[];
  sectionIdx: number;
}) {
  const all = [...exams, ...finals];
  const allLocked = all.every((m) => m.state === "locked");

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-baseline justify-between gap-3">
        <div className="flex items-baseline gap-2">
          <h3 className="font-display text-[15px] font-semibold text-navy-900 tracking-tight inline-flex items-center gap-1.5">
            <GraduationCap className="h-4 w-4 text-amber-700" />
            Préparer l&rsquo;examen final
          </h3>
          <span className="text-[12px] text-slate-500">
            {exams.length} examen{exams.length > 1 ? "s" : ""} blanc
            {exams.length > 1 ? "s" : ""}
            {finals.length > 0 && ` + ${finals.length} préparation${finals.length > 1 ? "s" : ""} jury`}
          </span>
        </div>
        {allLocked && (
          <span className="inline-flex items-center gap-1.5 text-[12px] text-slate-500">
            <Lock className="h-3 w-3" />
            Disponibles après les modules de cours
          </span>
        )}
      </div>
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 md:gap-5">
        {all.map((m, i) => (
          <div
            key={m.id}
            style={{
              animation: `fade-up 0.45s ease-out ${
                sectionIdx * 80 + i * 40 + 100
              }ms both`,
            }}
          >
            <ModuleCard module={m} />
          </div>
        ))}
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------

function extractFirstName(fullName: string | null): string | null {
  if (!fullName) return null;
  const trimmed = fullName.trim();
  if (!trimmed) return null;
  const first = trimmed.split(/\s+/)[0];
  if (!first) return null;
  // Capitalisation propre : "JEAN-PIERRE" → "Jean-Pierre", "marie" → "Marie"
  return first
    .toLowerCase()
    .split("-")
    .map((p) => (p ? p[0].toUpperCase() + p.slice(1) : p))
    .join("-");
}
