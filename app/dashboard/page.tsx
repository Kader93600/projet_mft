import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ProgressBar, RadialProgress } from "@/components/ui/progress";
import { Button } from "@/components/ui/button";
import { blocTone, scoreColor, formatDate } from "@/lib/utils";
import { SurveyBanner } from "@/components/survey-banner";
import { AnnouncementBanner } from "@/components/announcement-banner";
import { MyFormationsSection } from "@/components/student/my-formations-section";
import { StudentAwaitingReviews } from "@/components/student/awaiting-reviews";
import { PlacementSummary } from "@/components/placement-summary";
import { RecentAchievements } from "@/components/recent-achievements";
import { NextSessionCard } from "@/components/next-session-card";
import { XpWidget } from "@/components/xp-widget";
import {
  BookOpen,
  ClipboardCheck,
  Flame,
  Trophy,
  ArrowRight,
  Clock,
  Target,
  Sparkles,
  TrendingUp,
} from "lucide-react";

export default async function DashboardPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const [{ data: profile }, { data: modules }, { data: progress }, { data: attempts }] =
    await Promise.all([
      supabase.from("profiles").select("*").eq("id", user.id).single(),
      supabase
        .from("modules")
        .select("id, title, slug, duration_min, bloc_id, blocs(code, title)")
        .order("bloc_id"),
      supabase.from("lesson_progress").select("lesson_id, completed").eq("user_id", user.id),
      supabase
        .from("quiz_attempts")
        .select("id, percentage, passed, finished_at, quizzes(title)")
        .eq("user_id", user.id)
        .order("finished_at", { ascending: false })
        .limit(5),
    ]);

  const { count: totalLessons } = await supabase
    .from("lessons")
    .select("*", { count: "exact", head: true });
  const completedLessons = progress?.filter((p) => p.completed).length || 0;
  const progressPct = totalLessons ? Math.round((completedLessons / totalLessons) * 100) : 0;

  const avgScore =
    attempts && attempts.length > 0
      ? Math.round(attempts.reduce((s, a) => s + a.percentage, 0) / attempts.length)
      : 0;

  const firstName = profile?.full_name?.split(" ")[0] || "étudiant";

  return (
    <div className="space-y-10">
      {/* Annonces publiées (épinglées d'abord) */}
      <AnnouncementBanner />

      {/* Bannière enquête satisfaction (conditionnelle) */}
      <SurveyBanner progressPct={progressPct} />

      {/* Copies en attente de correction (QR) */}
      <StudentAwaitingReviews />

      {/* Mes formations (multi-formations) */}
      <MyFormationsSection />

      {/* Hero / Welcome */}
      <section className="grid lg:grid-cols-[1.4fr_1fr] gap-6">
        <Card variant="solid-navy" className="relative overflow-hidden">
          <div className="absolute inset-0 bg-mesh-navy opacity-50" />
          <div className="absolute inset-0 bg-grid-navy opacity-[0.08]" />
          <CardBody className="relative p-8">
            <div className="flex items-center gap-2 mb-3">
              <Sparkles className="h-4 w-4 text-gold-400" />
              <span className="eyebrow text-gold-300">Session en cours</span>
            </div>
            <h1 className="font-display text-3xl md:text-4xl font-semibold tracking-tight">
              Bonjour, {firstName}.
            </h1>
            <p className="mt-3 text-white/70 text-[15px] max-w-lg leading-relaxed">
              Vous êtes à{" "}
              <span className="relative inline-flex items-baseline">
                <span className="font-display text-2xl font-semibold bg-gradient-to-r from-signal-300 to-signal-500 bg-clip-text text-transparent tabular-nums">
                  {progressPct}%
                </span>
                <span
                  aria-hidden
                  className="absolute -inset-x-1 -bottom-0.5 h-px bg-gradient-to-r from-signal-400/0 via-signal-400/60 to-signal-400/0"
                />
              </span>{" "}
              de votre préparation. Reprenez là où vous vous êtes arrêté et
              maintenez votre élan.
            </p>
            <div className="mt-6 flex flex-wrap gap-3">
              <Link href="/modules">
                <Button variant="gold" size="lg" className="group">
                  Reprendre la formation
                  <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-0.5" />
                </Button>
              </Link>
              <Link href="/quiz">
                <Button size="lg" className="bg-white/10 hover:bg-white/15 text-white border border-white/15 shadow-none">
                  Lancer un quiz
                </Button>
              </Link>
            </div>
          </CardBody>
        </Card>

        <Card className="relative overflow-hidden">
          <CardBody className="flex items-center gap-6 h-full">
            <RadialProgress value={progressPct} size={112} strokeWidth={10} />
            <div>
              <div className="eyebrow text-gold-700">Progression globale</div>
              <div className="mt-1 font-display text-2xl font-semibold text-navy-900">
                {completedLessons} / {totalLessons ?? 0}
              </div>
              <p className="text-sm text-slate-600 mt-1">leçons terminées</p>
              <div className="mt-4 flex items-center gap-1.5 text-xs text-emerald-700 font-medium">
                <TrendingUp className="h-3.5 w-3.5" />
                Bonne dynamique
              </div>
            </div>
          </CardBody>
        </Card>
      </section>

      {/* XP / Niveau / Streak */}
      <XpWidget />

      {/* Prochain rendez-vous d'accompagnement */}
      <NextSessionCard />

      {/* Positionnement initial */}
      <PlacementSummary />

      {/* Badges & certificats récents */}
      <RecentAchievements />

      {/* KPI row */}
      <section className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          icon={BookOpen}
          label="Leçons terminées"
          value={`${completedLessons}`}
          hint={`sur ${totalLessons ?? 0}`}
          color="brand"
        />
        <StatCard
          icon={Flame}
          label="Progression"
          value={`${progressPct}%`}
          hint="préparation globale"
          color="amber"
        />
        <StatCard
          icon={Trophy}
          label="Score moyen"
          value={`${avgScore}%`}
          hint="sur vos quiz"
          color="signal"
        />
        <StatCard
          icon={ClipboardCheck}
          label="Quiz passés"
          value={String(attempts?.length ?? 0)}
          hint="entraînements + examens"
          color="emerald"
        />
      </section>

      {/* Continue la formation */}
      <section>
        <div className="flex items-end justify-between mb-5">
          <div>
            <span className="eyebrow text-gold-700">Parcours</span>
            <h2 className="mt-1 font-display text-2xl font-semibold text-navy-900 tracking-tight">
              Continuer la formation
            </h2>
          </div>
          <Link
            href="/modules"
            className="text-sm font-medium text-navy-900 hover:text-gold-700 inline-flex items-center gap-1"
          >
            Voir tout
            <ArrowRight className="h-3.5 w-3.5" />
          </Link>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
          {modules?.slice(0, 6).map((m: any) => (
            <Link key={m.id} href={`/modules/${m.slug}`} className="group">
              <Card className="h-full transition-all group-hover:-translate-y-0.5 group-hover:shadow-raised">
                <CardBody className="flex flex-col h-full">
                  <div className="flex items-start justify-between gap-3">
                    <Badge tone={blocTone(m.blocs?.code)} size="sm">
                      {m.blocs?.code}
                    </Badge>
                    <span className="inline-flex items-center gap-1 text-xs text-slate-500">
                      <Clock className="h-3 w-3" /> {m.duration_min} min
                    </span>
                  </div>
                  <h3 className="mt-4 font-display text-lg font-semibold text-navy-900 leading-snug">
                    {m.title}
                  </h3>
                  <p className="text-xs text-slate-500 mt-1 line-clamp-2">
                    {m.blocs?.title}
                  </p>
                  <div className="mt-auto pt-5 flex items-center justify-between text-sm font-medium text-navy-900">
                    <span className="inline-flex items-center gap-1 group-hover:text-gold-700 transition-colors">
                      Reprendre
                      <ArrowRight className="h-3.5 w-3.5 transition-transform group-hover:translate-x-0.5" />
                    </span>
                  </div>
                </CardBody>
              </Card>
            </Link>
          ))}
        </div>
      </section>

      {/* Derniers résultats + Objectif */}
      <section className="grid lg:grid-cols-[1.4fr_1fr] gap-6">
        <div>
          <div className="flex items-end justify-between mb-5">
            <div>
              <span className="eyebrow text-gold-700">Activité</span>
              <h2 className="mt-1 font-display text-2xl font-semibold text-navy-900 tracking-tight">
                Derniers résultats
              </h2>
            </div>
            <Link
              href="/stats"
              className="text-sm font-medium text-navy-900 hover:text-gold-700 inline-flex items-center gap-1"
            >
              Statistiques
              <ArrowRight className="h-3.5 w-3.5" />
            </Link>
          </div>

          {attempts && attempts.length > 0 ? (
            <Card>
              <div className="divide-y divide-navy-50">
                {attempts.map((a: any) => (
                  <div
                    key={a.id}
                    className="flex items-center justify-between px-6 py-4"
                  >
                    <div className="min-w-0">
                      <div className="font-medium text-navy-900 truncate">
                        {a.quizzes?.title}
                      </div>
                      <div className="text-xs text-slate-500 mt-0.5">
                        {a.finished_at && formatDate(a.finished_at)}
                      </div>
                    </div>
                    <div className="flex items-center gap-3">
                      {a.passed ? (
                        <Badge tone="success" size="sm">Réussi</Badge>
                      ) : (
                        <Badge tone="slate" size="sm">À retravailler</Badge>
                      )}
                      <div className={`font-display font-semibold text-xl ${scoreColor(a.percentage)}`}>
                        {a.percentage}%
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </Card>
          ) : (
            <Card>
              <CardBody className="text-center py-10">
                <div className="mx-auto h-12 w-12 rounded-xl bg-navy-50 text-navy-700 flex items-center justify-center">
                  <ClipboardCheck className="h-5 w-5" />
                </div>
                <p className="mt-4 font-medium text-navy-900">Aucun quiz pour le moment.</p>
                <p className="text-sm text-slate-600 mt-1">
                  Lancez votre premier entraînement pour mesurer votre niveau.
                </p>
                <Link href="/quiz" className="inline-block mt-5">
                  <Button size="md">Commencer un quiz</Button>
                </Link>
              </CardBody>
            </Card>
          )}
        </div>

        <Card variant="gold">
          <CardBody>
            <div className="flex items-center gap-2">
              <Target className="h-4 w-4 text-gold-700" />
              <span className="eyebrow text-gold-800">Objectif hebdo</span>
            </div>
            <h3 className="mt-3 font-display text-xl font-semibold text-navy-900">
              Terminer 5 leçons cette semaine
            </h3>
            <p className="text-sm text-slate-600 mt-2">
              Maintenez un rythme régulier pour ancrer les connaissances clés du référentiel.
            </p>
            <div className="mt-5">
              <ProgressBar value={Math.min(100, (completedLessons % 5) * 20)} variant="gradient" />
              <div className="mt-2 flex justify-between text-xs text-slate-600">
                <span>{completedLessons % 5} / 5 leçons</span>
                <span>Semaine en cours</span>
              </div>
            </div>
          </CardBody>
        </Card>
      </section>
    </div>
  );
}

type StatColor = "brand" | "signal" | "amber" | "emerald";

const STAT_COLORS: Record<
  StatColor,
  { iconBg: string; iconText: string; halo: string; bar: string }
> = {
  brand: {
    iconBg: "bg-brand-50",
    iconText: "text-brand-700",
    halo: "rgba(37,48,217,0.18)",
    bar: "bg-brand-500",
  },
  signal: {
    iconBg: "bg-signal-100",
    iconText: "text-signal-800",
    halo: "rgba(159,226,32,0.28)",
    bar: "bg-signal-500",
  },
  amber: {
    iconBg: "bg-amber-100",
    iconText: "text-amber-700",
    halo: "rgba(245,158,11,0.22)",
    bar: "bg-amber-500",
  },
  emerald: {
    iconBg: "bg-emerald-50",
    iconText: "text-emerald-700",
    halo: "rgba(16,185,129,0.22)",
    bar: "bg-emerald-500",
  },
};

function StatCard({
  icon: Icon,
  label,
  value,
  hint,
  color = "brand",
}: {
  icon: any;
  label: string;
  value: string;
  hint?: string;
  color?: StatColor;
}) {
  const c = STAT_COLORS[color];
  return (
    <Card className="relative overflow-hidden group transition-shadow duration-300 hover:shadow-raised">
      {/* Halo radial coloré, doux, animé au hover */}
      <div
        aria-hidden
        className="absolute -top-16 -right-16 h-40 w-40 rounded-full pointer-events-none opacity-60 group-hover:opacity-100 transition-opacity duration-500"
        style={{ background: `radial-gradient(circle, ${c.halo} 0%, transparent 70%)` }}
      />
      {/* Barre verticale d'accent à gauche */}
      <span
        aria-hidden
        className={
          "absolute left-0 top-4 bottom-4 w-[3px] rounded-r-full opacity-80 " + c.bar
        }
      />
      <CardBody className="relative flex items-start gap-4">
        <div
          className={
            "h-11 w-11 rounded-xl flex items-center justify-center shrink-0 transition-transform duration-300 group-hover:scale-105 motion-reduce:group-hover:scale-100 " +
            c.iconBg +
            " " +
            c.iconText
          }
        >
          <Icon className="h-5 w-5" />
        </div>
        <div className="min-w-0">
          <div className="text-[11px] uppercase tracking-wider text-slate-500 font-medium">
            {label}
          </div>
          <div className="font-display text-[28px] font-semibold text-navy-900 mt-0.5 leading-none tabular-nums">
            {value}
          </div>
          {hint && <div className="text-xs text-slate-500 mt-1.5">{hint}</div>}
        </div>
      </CardBody>
    </Card>
  );
}
