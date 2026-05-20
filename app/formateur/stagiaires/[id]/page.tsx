import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { ProgressBar } from "@/components/ui/progress";
import { computeRiskScore, RISK_LEVEL_LABEL } from "@/lib/risk-score";
import {
  ArrowLeft,
  Mail,
  Phone,
  Calendar,
  CheckCircle2,
  Sparkles,
  Trophy,
  Activity,
  AlertTriangle,
  TrendingUp,
  BookOpen,
  Award,
  MessageCircle,
} from "lucide-react";
import { findFormation } from "@/lib/formations-config";
import { initials } from "@/lib/utils";

export const dynamic = "force-dynamic";

export default async function StudentDetailPage({
  params,
}: {
  params: { id: string };
}) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  // Sécurité : seul le formateur affecté ou un admin peut voir
  const { data: meProfile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .single();

  const isStaff =
    meProfile?.role === "admin" || meProfile?.role === "super_admin";

  let isAuthorized = isStaff;
  if (!isAuthorized) {
    const { data: assignment } = await supabase
      .from("trainer_assignments")
      .select("id")
      .eq("trainer_id", user.id)
      .eq("student_id", params.id)
      .maybeSingle();
    isAuthorized = !!assignment;
  }
  if (!isAuthorized) redirect("/formateur");

  // Charger le stagiaire
  const { data: student } = await supabase
    .from("profiles")
    .select("id, full_name, email, phone, level, created_at, disabled")
    .eq("id", params.id)
    .single();
  if (!student) notFound();

  // Données pédagogiques
  const [
    { data: enrollments },
    { data: lessonProgress },
    { data: quizAttempts },
    { data: xpEvents },
    { data: badges },
  ] = await Promise.all([
    supabase
      .from("enrollments")
      .select("id, formation_slug, status, start_date, end_date, session_label")
      .eq("user_id", params.id)
      .order("created_at", { ascending: false }),
    supabase
      .from("lesson_progress")
      .select("lesson_id, completed, completed_at")
      .eq("user_id", params.id),
    supabase
      .from("quiz_attempts")
      .select("id, percentage, passed, finished_at, mode, quiz_id, quizzes(title, is_mock_exam)")
      .eq("user_id", params.id)
      .not("finished_at", "is", null)
      .order("finished_at", { ascending: false })
      .limit(15),
    supabase
      .from("xp_events")
      .select("created_at")
      .eq("user_id", params.id)
      .order("created_at", { ascending: false })
      .limit(1),
    supabase
      .from("user_badges")
      .select("badge_id, earned_at, badges(name, description)")
      .eq("user_id", params.id)
      .order("earned_at", { ascending: false }),
  ]);

  // Modules + leçons (pour calculer progression par module)
  const { data: modules } = await supabase
    .from("modules")
    .select("id, title, slug, blocs(code, title)")
    .order("order");
  const { data: allLessons } = await supabase
    .from("lessons")
    .select("id, module_id");

  // Métriques
  const lessonsByModule = new Map<string, string[]>();
  (allLessons ?? []).forEach((l: any) => {
    const arr = lessonsByModule.get(l.module_id) ?? [];
    arr.push(l.id);
    lessonsByModule.set(l.module_id, arr);
  });
  const completedLessonIds = new Set(
    (lessonProgress ?? [])
      .filter((p: any) => p.completed)
      .map((p: any) => p.lesson_id)
  );
  const moduleProgress = (modules ?? []).map((m: any) => {
    const lessonIds = lessonsByModule.get(m.id) ?? [];
    const done = lessonIds.filter((id) => completedLessonIds.has(id)).length;
    const total = lessonIds.length;
    const pct = total ? Math.round((done / total) * 100) : 0;
    return { ...m, done, total, pct };
  });

  const totalLessonsDone = completedLessonIds.size;
  const totalQuizzesPassed = (quizAttempts ?? []).filter((a: any) => a.passed).length;
  const avgScore =
    quizAttempts && quizAttempts.length > 0
      ? Math.round(
          quizAttempts.reduce(
            (s: number, a: any) => s + (a.percentage ?? 0),
            0
          ) / quizAttempts.length
        )
      : 0;

  const lastXp = (xpEvents ?? [])[0]?.created_at;
  const daysSinceLastActivity = lastXp
    ? Math.floor(
        (Date.now() - new Date(lastXp).getTime()) / (24 * 60 * 60 * 1000)
      )
    : null;

  // Score de risque de décrochage (heuristique transparente, lib/risk-score)
  const totalLessonsAll = moduleProgress.reduce(
    (s: number, m: any) => s + m.total,
    0
  );
  const completionPct = totalLessonsAll
    ? Math.round((totalLessonsDone / totalLessonsAll) * 100)
    : 0;
  const risk = computeRiskScore({
    completionPct,
    avgScorePct: avgScore,
    daysSinceLastActivity,
    attemptsCount: (quizAttempts ?? []).length,
  });
  const riskTone =
    risk.level === "eleve"
      ? "rose"
      : risk.level === "moyen"
        ? "gold"
        : "success";

  return (
    <div className="space-y-8">
      <Link
        href="/formateur"
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
      >
        <ArrowLeft className="h-4 w-4" /> Retour aux stagiaires
      </Link>

      {/* Header stagiaire */}
      <header className="flex items-start gap-5 flex-wrap">
        <div className="h-16 w-16 rounded-full bg-gradient-to-br from-brand-500 to-brand-700 text-white flex items-center justify-center font-display text-xl font-bold shrink-0">
          {initials(student.full_name ?? student.email ?? "?")}
        </div>
        <div className="flex-1 min-w-0">
          <h1 className="font-display text-3xl font-semibold text-navy-950 tracking-tight">
            {student.full_name ?? student.email}
          </h1>
          <div className="mt-2 flex flex-wrap items-center gap-x-4 gap-y-1 text-sm text-slate-600">
            <a
              href={`mailto:${student.email}`}
              className="inline-flex items-center gap-1.5 hover:text-brand-700"
            >
              <Mail className="h-3.5 w-3.5" />
              {student.email}
            </a>
            {student.phone && (
              <a
                href={`tel:${student.phone}`}
                className="inline-flex items-center gap-1.5 hover:text-brand-700"
              >
                <Phone className="h-3.5 w-3.5" />
                {student.phone}
              </a>
            )}
            <span className="inline-flex items-center gap-1.5">
              <Calendar className="h-3.5 w-3.5" />
              Inscrit{" "}
              {new Date(student.created_at).toLocaleDateString("fr-FR", {
                month: "short",
                year: "numeric",
              })}
            </span>
            {student.disabled && (
              <Badge tone="rose" size="sm">
                Compte désactivé
              </Badge>
            )}
          </div>
        </div>
        <div className="flex gap-2">
          <Link href={`/messages?to=${student.id}`}>
            <Button variant="secondary">
              <MessageCircle className="h-4 w-4" />
              Envoyer un message
            </Button>
          </Link>
        </div>
      </header>

      {/* Risque de décrochage (heuristique) */}
      <Card
        className={
          risk.level === "eleve"
            ? "border-rose-200"
            : risk.level === "moyen"
              ? "border-gold-200"
              : "border-emerald-200"
        }
      >
        <CardBody>
          <div className="flex items-start justify-between gap-4 flex-wrap">
            <div className="flex items-center gap-3">
              <div
                className={
                  "h-12 w-12 rounded-xl flex items-center justify-center font-display text-lg font-semibold tabular-nums shrink-0 " +
                  (risk.level === "eleve"
                    ? "bg-rose-100 text-rose-700"
                    : risk.level === "moyen"
                      ? "bg-gold-100 text-gold-800"
                      : "bg-emerald-100 text-emerald-700")
                }
                aria-hidden
              >
                {risk.score}
              </div>
              <div>
                <div className="text-[10px] uppercase tracking-wider text-slate-500 font-semibold">
                  Risque de décrochage
                </div>
                <Badge tone={riskTone as any} size="sm" className="mt-1">
                  {RISK_LEVEL_LABEL[risk.level]}
                </Badge>
              </div>
            </div>
            <ul className="flex-1 min-w-[14rem] space-y-1 text-sm text-slate-700">
              {risk.factors.map((f) => (
                <li key={f} className="flex items-start gap-2">
                  <span
                    className={
                      "mt-1.5 h-1.5 w-1.5 rounded-full shrink-0 " +
                      (risk.level === "faible"
                        ? "bg-emerald-500"
                        : "bg-slate-400")
                    }
                  />
                  {f}
                </li>
              ))}
            </ul>
          </div>
          <p className="mt-3 text-[11px] text-slate-400">
            Score heuristique (inactivité, progression, score, engagement) — aide
            à la priorisation, non contractuel.
          </p>
        </CardBody>
      </Card>

      {/* KPIs */}
      <section className="grid sm:grid-cols-4 gap-4">
        <Kpi
          icon={CheckCircle2}
          label="Leçons complétées"
          value={totalLessonsDone}
          tone="brand"
        />
        <Kpi
          icon={Sparkles}
          label="Exercices réussis"
          value={totalQuizzesPassed}
          tone="brand"
        />
        <Kpi
          icon={TrendingUp}
          label="Score moyen"
          value={`${avgScore}%`}
          tone={avgScore >= 70 ? "success" : avgScore >= 50 ? "brand" : "rose"}
        />
        <Kpi
          icon={Activity}
          label="Dernière activité"
          value={
            daysSinceLastActivity === null
              ? "—"
              : daysSinceLastActivity === 0
              ? "Aujourd'hui"
              : `Il y a ${daysSinceLastActivity} j`
          }
          tone={
            daysSinceLastActivity === null || daysSinceLastActivity > 7
              ? "rose"
              : "success"
          }
        />
      </section>

      {/* Inscriptions / formations suivies */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4">
          Formations suivies ({(enrollments ?? []).length})
        </h2>
        {(enrollments ?? []).length === 0 ? (
          <Card>
            <CardBody className="text-sm text-slate-500 py-6 text-center">
              Aucune inscription enregistrée pour ce stagiaire.
            </CardBody>
          </Card>
        ) : (
          <div className="grid md:grid-cols-2 gap-3">
            {(enrollments ?? []).map((e: any) => {
              const f = e.formation_slug ? findFormation(e.formation_slug) : null;
              return (
                <Card key={e.id}>
                  <CardBody>
                    <div className="flex items-start justify-between gap-3">
                      <div>
                        <div className="text-[10px] font-semibold uppercase tracking-[0.16em] text-slate-500">
                          {f?.code ?? "Formation"}
                        </div>
                        <div className="font-medium text-navy-900 mt-0.5">
                          {f?.title ?? e.session_label ?? "Sans titre"}
                        </div>
                        <div className="text-xs text-slate-500 mt-1">
                          {e.start_date
                            ? `Démarré le ${new Date(e.start_date).toLocaleDateString("fr-FR")}`
                            : "Date à confirmer"}
                        </div>
                      </div>
                      <Badge tone="navy" size="sm">
                        {e.status}
                      </Badge>
                    </div>
                  </CardBody>
                </Card>
              );
            })}
          </div>
        )}
      </section>

      {/* Progression module par module */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 flex items-center gap-2">
          <BookOpen className="h-5 w-5 text-brand-700" />
          Progression par module
        </h2>
        <Card>
          <CardBody className="p-0">
            {moduleProgress.length === 0 ? (
              <div className="p-6 text-sm text-slate-500 text-center">
                Aucun module chargé.
              </div>
            ) : (
              <ul className="divide-y divide-navy-50">
                {moduleProgress.map((m: any) => (
                  <li key={m.id} className="px-6 py-4">
                    <div className="flex items-center justify-between gap-4 mb-2">
                      <div className="flex-1 min-w-0">
                        <div className="text-[10px] font-semibold uppercase tracking-wider text-slate-500">
                          {m.blocs?.code ?? "—"}
                        </div>
                        <div className="font-medium text-navy-900 truncate">
                          {m.title}
                        </div>
                      </div>
                      <div className="text-right shrink-0">
                        <div className="font-display text-base font-semibold text-navy-900">
                          {m.pct}%
                        </div>
                        <div className="text-[10px] text-slate-500">
                          {m.done}/{m.total} leçons
                        </div>
                      </div>
                    </div>
                    <ProgressBar value={m.pct} />
                  </li>
                ))}
              </ul>
            )}
          </CardBody>
        </Card>
      </section>

      {/* Historique des quiz */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 flex items-center gap-2">
          <Sparkles className="h-5 w-5 text-brand-700" />
          Historique des quiz (15 derniers)
        </h2>
        <Card>
          <CardBody className="p-0">
            {(quizAttempts ?? []).length === 0 ? (
              <div className="p-6 text-sm text-slate-500 text-center">
                Aucun quiz complété pour le moment.
              </div>
            ) : (
              <table className="w-full text-sm">
                <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                  <tr>
                    <th className="text-left px-6 py-3">Exercice</th>
                    <th className="text-left px-3 py-3">Mode</th>
                    <th className="text-right px-3 py-3">Score</th>
                    <th className="text-left px-3 py-3">Statut</th>
                    <th className="text-right px-6 py-3">Date</th>
                  </tr>
                </thead>
                <tbody>
                  {(quizAttempts ?? []).map((a: any) => (
                    <tr key={a.id} className="border-t border-navy-50">
                      <td className="px-6 py-3 text-navy-900 max-w-xs truncate">
                        {a.quizzes?.title ?? "—"}
                      </td>
                      <td className="px-3 py-3">
                        {a.quizzes?.is_mock_exam ? (
                          <Badge tone="gold" size="sm">
                            Examen blanc
                          </Badge>
                        ) : (
                          <span className="text-xs text-slate-500">
                            {a.mode ?? "entrainement"}
                          </span>
                        )}
                      </td>
                      <td className="px-3 py-3 text-right font-mono font-medium">
                        {a.percentage ?? 0}%
                      </td>
                      <td className="px-3 py-3">
                        {a.passed ? (
                          <Badge tone="success" size="sm">
                            <CheckCircle2 className="h-3 w-3" />
                            Réussi
                          </Badge>
                        ) : (
                          <Badge tone="rose" size="sm">
                            <AlertTriangle className="h-3 w-3" />
                            Échec
                          </Badge>
                        )}
                      </td>
                      <td className="px-6 py-3 text-right text-xs text-slate-500">
                        {a.finished_at
                          ? new Date(a.finished_at).toLocaleDateString("fr-FR")
                          : "—"}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </CardBody>
        </Card>
      </section>

      {/* Badges */}
      {(badges ?? []).length > 0 && (
        <section>
          <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 flex items-center gap-2">
            <Trophy className="h-5 w-5 text-brand-700" />
            Réussites ({(badges ?? []).length})
          </h2>
          <div className="flex flex-wrap gap-2">
            {(badges ?? []).map((b: any, i: number) => (
              <span
                key={i}
                className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-amber-50 border border-amber-200 text-amber-900 text-sm"
              >
                <Award className="h-3.5 w-3.5" />
                {b.badges?.name ?? "Badge"}
              </span>
            ))}
          </div>
        </section>
      )}
    </div>
  );
}

function Kpi({
  icon: Icon,
  label,
  value,
  tone,
}: {
  icon: any;
  label: string;
  value: string | number;
  tone: "brand" | "success" | "rose";
}) {
  const toneClass =
    tone === "success"
      ? "bg-emerald-50 text-emerald-800 border-emerald-200"
      : tone === "rose"
      ? "bg-rose-50 text-rose-800 border-rose-200"
      : "bg-brand-50 text-brand-700 border-brand-200";
  return (
    <Card>
      <CardBody>
        <div className="flex items-center justify-between gap-3">
          <div>
            <div className="text-xs uppercase tracking-wider text-slate-500">
              {label}
            </div>
            <div className="mt-1 font-display text-2xl font-semibold text-navy-900">
              {value}
            </div>
          </div>
          <div
            className={
              "h-10 w-10 rounded-xl border flex items-center justify-center " +
              toneClass
            }
          >
            <Icon className="h-5 w-5" />
          </div>
        </div>
      </CardBody>
    </Card>
  );
}
