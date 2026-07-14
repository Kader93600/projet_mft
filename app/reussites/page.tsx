import { createClient } from "@/lib/supabase/server";
import { BadgeCard } from "@/components/badge-card";
import { Card, CardBody } from "@/components/ui/card";
import { Sparkles, Flame, History, Award } from "lucide-react";
import {
  computeBadgeProgress,
  type BadgeCriteria,
  type UserStats,
} from "@/lib/gamification/badge-progress";
import { RankHero } from "@/components/gamification/rank-hero";
import { xpLevelFromTotal } from "@/lib/gamification/ranks";
import type { Tables } from "@/lib/database.types";

// ── Types des lignes lues (dérivés des `select` ci-dessous) ────────────
type BadgeRow = Tables<"badges">;
type UserBadgeRow = Pick<Tables<"user_badges">, "badge_id" | "earned_at">;
type XpStatRow = Pick<Tables<"xp_events">, "points" | "created_at">;
type XpHistoryRow = Pick<
  Tables<"xp_events">,
  "id" | "kind" | "points" | "ref_id" | "created_at"
>;
/** Ligne renvoyée par la RPC `user_streak(p_user uuid)`. */
type StreakRow = { current_streak: number; longest_streak: number };
type PassedAttemptRow = Pick<Tables<"quiz_attempts">, "quiz_id" | "passed">;
type PerfectAttemptRow = Pick<Tables<"quiz_attempts">, "id" | "percentage">;
type MockExamAttemptRow = Pick<Tables<"quiz_attempts">, "id" | "passed">;
type LessonDoneRow = Pick<Tables<"lesson_progress">, "lesson_id">;
/** `lessons` + embed `modules!inner(bloc_id)`. */
type BlocLessonRow = Pick<Tables<"lessons">, "id"> & {
  modules: Pick<Tables<"modules">, "bloc_id"> | null;
};
/** `lesson_progress` + embed `lessons!inner(modules!inner(bloc_id))`. */
type BlocLessonDoneRow = Pick<Tables<"lesson_progress">, "lesson_id"> & {
  lessons: { modules: Pick<Tables<"modules">, "bloc_id"> | null } | null;
};
/** `quiz_attempts` + embed `quizzes!inner(modules!inner(bloc_id))`. */
type BlocExamPassedRow = Pick<Tables<"quiz_attempts">, "id"> & {
  quizzes: { modules: Pick<Tables<"modules">, "bloc_id"> | null } | null;
};

const CATEGORY_LABEL: Record<string, string> = {
  progression: "Progression",
  regularite: "Régularité",
  excellence: "Excellence",
  maitrise: "Maîtrise",
};

const XP_KIND_LABEL: Record<string, string> = {
  lesson_completed: "Leçon terminée",
  quiz_passed: "Quiz réussi",
  quiz_perfect: "Score parfait",
  mock_exam_passed: "Examen blanc réussi",
  streak_bonus: "Bonus de série",
  badge_earned: "Badge débloqué",
  daily_login: "Connexion du jour",
};

export default async function ReussitesPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  // ─── Données agrégées ────────────────────────────────────────────────
  // On fait toutes les requêtes nécessaires en parallèle pour calculer :
  //   - le récap XP + niveau + streak
  //   - les badges (catalogue + ceux débloqués)
  //   - les stocks pour la progression vers les badges verrouillés
  //   - l'historique XP des 20 derniers événements
  const [
    { data: badgesData },
    { data: myBadgesData },
    { data: statsData },
    { data: streakData },
    { data: passedAttemptsData },
    { data: perfectAttemptsData },
    { data: mockExamAttemptsData },
    { data: lessonsDoneData },
    { data: blocLessonsData },
    { data: blocLessonsDoneData },
    { data: blocExamsPassedData },
    { data: xpHistoryData },
  ] = await Promise.all([
    supabase.from("badges").select("*").eq("active", true).order("order"),
    supabase
      .from("user_badges")
      .select("badge_id, earned_at")
      .eq("user_id", user.id),
    supabase
      .from("xp_events")
      .select("points, created_at")
      .eq("user_id", user.id),
    supabase.rpc("user_streak", { p_user: user.id }),
    // Stocks pour la progression
    supabase
      .from("quiz_attempts")
      .select("quiz_id, passed")
      .eq("user_id", user.id)
      .eq("passed", true),
    supabase
      .from("quiz_attempts")
      .select("id, percentage")
      .eq("user_id", user.id)
      .eq("percentage", 100),
    supabase
      .from("quiz_attempts")
      .select("id, passed, quizzes!inner(is_mock_exam)")
      .eq("user_id", user.id)
      .eq("passed", true)
      .eq("quizzes.is_mock_exam", true),
    supabase
      .from("lesson_progress")
      .select("lesson_id")
      .eq("user_id", user.id)
      .eq("completed", true),
    // Stats par bloc — pour bloc_mastered
    supabase
      .from("lessons")
      .select("id, modules!inner(bloc_id)"),
    supabase
      .from("lesson_progress")
      .select("lesson_id, lessons!inner(modules!inner(bloc_id))")
      .eq("user_id", user.id)
      .eq("completed", true),
    supabase
      .from("quiz_attempts")
      .select("id, quizzes!inner(modules!inner(bloc_id))")
      .eq("user_id", user.id)
      .eq("passed", true),
    // Historique XP — 20 derniers événements
    supabase
      .from("xp_events")
      .select("id, kind, points, ref_id, created_at")
      .eq("user_id", user.id)
      .order("created_at", { ascending: false })
      .limit(20),
  ]);

  const badges = badgesData as BadgeRow[] | null;
  const myBadges = myBadgesData as UserBadgeRow[] | null;
  const stats = statsData as XpStatRow[] | null;
  const streak = streakData as StreakRow[] | null;
  const passedAttempts = passedAttemptsData as PassedAttemptRow[] | null;
  const perfectAttempts = perfectAttemptsData as PerfectAttemptRow[] | null;
  const mockExamAttempts = mockExamAttemptsData as MockExamAttemptRow[] | null;
  const lessonsDone = lessonsDoneData as LessonDoneRow[] | null;
  const blocLessons = blocLessonsData as BlocLessonRow[] | null;
  const blocLessonsDone = blocLessonsDoneData as BlocLessonDoneRow[] | null;
  const blocExamsPassed = blocExamsPassedData as BlocExamPassedRow[] | null;
  const xpHistory = xpHistoryData as XpHistoryRow[] | null;

  // ─── Index des badges débloqués ──────────────────────────────────────
  const earnedMap = new Map<string, string>(
    (myBadges || []).map((b) => [b.badge_id, b.earned_at])
  );

  const earnedList = (badges || []).filter((b) => earnedMap.has(b.id));

  // ─── Stats par bloc (pour bloc_mastered) ────────────────────────────
  const blocStats = new Map<
    number,
    { totalLessons: number; doneLessons: number; examsPassed: number }
  >();
  (blocLessons ?? []).forEach((row) => {
    const blocId = row.modules?.bloc_id;
    if (blocId == null) return;
    const s = blocStats.get(blocId) ?? {
      totalLessons: 0,
      doneLessons: 0,
      examsPassed: 0,
    };
    s.totalLessons++;
    blocStats.set(blocId, s);
  });
  (blocLessonsDone ?? []).forEach((row) => {
    const blocId = row.lessons?.modules?.bloc_id;
    if (blocId == null) return;
    const s = blocStats.get(blocId) ?? {
      totalLessons: 0,
      doneLessons: 0,
      examsPassed: 0,
    };
    s.doneLessons++;
    blocStats.set(blocId, s);
  });
  (blocExamsPassed ?? []).forEach((row) => {
    const blocId = row.quizzes?.modules?.bloc_id;
    if (blocId == null) return;
    const s = blocStats.get(blocId) ?? {
      totalLessons: 0,
      doneLessons: 0,
      examsPassed: 0,
    };
    s.examsPassed++;
    blocStats.set(blocId, s);
  });

  const userStats: UserStats = {
    quizPassedCount: new Set((passedAttempts ?? []).map((r) => r.quiz_id)).size,
    perfectScoreCount: (perfectAttempts ?? []).length,
    mockExamPassedCount: (mockExamAttempts ?? []).length,
    lessonsCompletedCount: (lessonsDone ?? []).length,
    blocStats,
  };

  // ─── XP / Niveau / Streak (cartes hero) ──────────────────────────────
  // Calcul direct depuis xp_events (robuste quel que soit le rôle ; la vue
  // user_gamification est filtrée role='student' pour le classement).
  const xpRows = stats ?? [];
  const totalXp = xpRows.reduce((s, r) => s + (r.points ?? 0), 0);
  const level = xpLevelFromTotal(totalXp);
  const activeDays = new Set(
    xpRows.map((r) => String(r.created_at).slice(0, 10))
  ).size;
  const curStart = ((level - 1) * level) / 2 * 100;
  const nextStart = (level * (level + 1)) / 2 * 100;
  const pct = Math.min(
    100,
    Math.round(((totalXp - curStart) / Math.max(1, nextStart - curStart)) * 100)
  );
  const currentStreak = streak?.[0]?.current_streak ?? 0;
  const longestStreak = streak?.[0]?.longest_streak ?? 0;

  // ─── Groupement par catégorie ────────────────────────────────────────
  const byCategory: Record<string, BadgeRow[]> = {};
  (badges || []).forEach((b) => {
    const c = b.category ?? "progression";
    if (!byCategory[c]) byCategory[c] = [];
    byCategory[c].push(b);
  });

  return (
    <div className="space-y-10">
      <header>
        <span className="eyebrow text-gold-700">Vos réussites</span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Badges & progression
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Chaque étape franchie débloque un badge. Ils reflètent votre
          engagement et votre maîtrise des blocs de compétence.
        </p>
      </header>

      {/* ─── Hero : Rang + Niveau + XP + Streak ─────────────────────── */}
      <RankHero
        level={level}
        totalXp={totalXp}
        nextStart={nextStart}
        pct={pct}
        currentStreak={currentStreak}
        longestStreak={longestStreak}
      />

      {/* ─── Stats compactes ───────────────────────────────────────── */}
      <div className="grid md:grid-cols-3 gap-4">
        <Card>
          <CardBody className="flex items-center gap-4">
            <div className="h-12 w-12 rounded-xl bg-gold-50 border border-gold-200 text-gold-700 flex items-center justify-center shrink-0">
              <Award className="h-6 w-6" />
            </div>
            <div>
              <div className="text-xs uppercase tracking-wider text-slate-500">
                Badges débloqués
              </div>
              <div className="font-display text-2xl font-semibold text-navy-900 tabular-nums">
                {earnedList.length}{" "}
                <span className="text-slate-400 text-lg font-normal">
                  / {(badges || []).length}
                </span>
              </div>
            </div>
          </CardBody>
        </Card>
        <Card>
          <CardBody className="flex items-center gap-4">
            <div className="h-12 w-12 rounded-xl bg-navy-50 border border-navy-100 text-navy-800 flex items-center justify-center shrink-0">
              <Sparkles className="h-6 w-6" />
            </div>
            <div>
              <div className="text-xs uppercase tracking-wider text-slate-500">
                Total XP
              </div>
              <div className="font-display text-2xl font-semibold text-navy-900 tabular-nums">
                {totalXp}
              </div>
            </div>
          </CardBody>
        </Card>
        <Card>
          <CardBody className="flex items-center gap-4">
            <div className="h-12 w-12 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-700 flex items-center justify-center shrink-0">
              <Flame className="h-6 w-6" />
            </div>
            <div>
              <div className="text-xs uppercase tracking-wider text-slate-500">
                Jours actifs
              </div>
              <div className="font-display text-2xl font-semibold text-navy-900 tabular-nums">
                {activeDays}
              </div>
            </div>
          </CardBody>
        </Card>
      </div>

      {/* ─── Badges par catégorie ──────────────────────────────────── */}
      {Object.entries(byCategory).map(([cat, list]) => (
        <section key={cat}>
          <h2 className="font-display text-xl font-semibold text-navy-900 tracking-tight mb-4">
            {CATEGORY_LABEL[cat] ?? cat}
          </h2>
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {list.map((b) => {
              const isEarned = earnedMap.has(b.id);
              // `badges.criteria` est un jsonb au format BadgeCriteria.
              const progress = isEarned
                ? null
                : computeBadgeProgress(
                    (b.criteria ?? null) as BadgeCriteria | null,
                    userStats
                  );
              return (
                <BadgeCard
                  key={b.id}
                  badge={b}
                  earned={isEarned}
                  earnedAt={earnedMap.get(b.id) ?? null}
                  progress={progress}
                />
              );
            })}
          </div>
        </section>
      ))}

      {/* ─── Historique XP (20 derniers événements) ─────────────────── */}
      {(xpHistory ?? []).length > 0 && (
        <section>
          <h2 className="font-display text-xl font-semibold text-navy-900 tracking-tight mb-4 inline-flex items-center gap-2">
            <History className="h-5 w-5 text-gold-700" />
            Activité récente
          </h2>
          <Card>
            <CardBody className="p-0">
              <ul className="divide-y divide-navy-50">
                {(xpHistory ?? []).map((e) => {
                  const date = new Date(e.created_at);
                  return (
                    <li
                      key={e.id}
                      className="flex items-center justify-between gap-3 px-5 py-3"
                    >
                      <div className="min-w-0 flex-1">
                        <div className="text-sm font-medium text-navy-900">
                          {XP_KIND_LABEL[e.kind] ?? e.kind}
                        </div>
                        <div className="text-xs text-slate-500">
                          {date.toLocaleDateString("fr-FR", {
                            day: "2-digit",
                            month: "short",
                            year: "numeric",
                          })}
                          {" · "}
                          {date.toLocaleTimeString("fr-FR", {
                            hour: "2-digit",
                            minute: "2-digit",
                          })}
                        </div>
                      </div>
                      <div className="font-display font-semibold text-gold-700 tabular-nums shrink-0">
                        +{e.points} XP
                      </div>
                    </li>
                  );
                })}
              </ul>
            </CardBody>
          </Card>
        </section>
      )}
    </div>
  );
}
