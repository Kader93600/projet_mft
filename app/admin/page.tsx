import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import Link from "next/link";
import {
  Users,
  UsersRound,
  BookOpen,
  ClipboardList,
  TrendingUp,
  Activity,
  Clock,
  Award,
  ArrowRight,
} from "lucide-react";
import { formatDate, initials } from "@/lib/utils";
import { Badge } from "@/components/ui/badge";
import { FormationPipeline } from "@/components/admin/formation-pipeline";
import { LEGAL } from "@/lib/legal-config";

export const dynamic = "force-dynamic";

export default async function AdminHome() {
  const supabase = createClient();

  const [
    { count: usersCount },
    { count: groupsCount },
    { count: modulesCount },
    { count: quizCount },
    { count: attemptsCount },
    { data: recentUsers },
    { data: recentAttempts },
    { data: allAttempts },
  ] = await Promise.all([
    supabase.from("profiles").select("*", { count: "exact", head: true }),
    supabase.from("groups").select("*", { count: "exact", head: true }),
    supabase.from("modules").select("*", { count: "exact", head: true }),
    supabase.from("quizzes").select("*", { count: "exact", head: true }),
    supabase.from("quiz_attempts").select("*", { count: "exact", head: true }),
    supabase
      .from("profiles")
      .select("id, full_name, email, created_at, role")
      .order("created_at", { ascending: false })
      .limit(5),
    supabase
      .from("quiz_attempts")
      .select("id, percentage, passed, started_at, user_id, quiz_id, quizzes(title), profiles(full_name, email)")
      .order("started_at", { ascending: false })
      .limit(6),
    supabase.from("quiz_attempts").select("percentage, started_at"),
  ]);

  const avg =
    allAttempts && allAttempts.length > 0
      ? Math.round(
          allAttempts.reduce((s, d) => s + (d.percentage || 0), 0) / allAttempts.length
        )
      : 0;

  const weekAgo = Date.now() - 7 * 24 * 3600 * 1000;
  const weekCount =
    allAttempts?.filter((a) => new Date(a.started_at).getTime() >= weekAgo).length ?? 0;

  const kpis = [
    {
      label: "Stagiaires",
      value: usersCount ?? 0,
      icon: Users,
      tone: "navy",
      href: "/admin/users",
    },
    {
      label: "Classes",
      value: groupsCount ?? 0,
      icon: UsersRound,
      tone: "gold",
      href: "/admin/groups",
    },
    {
      label: "Cours",
      value: modulesCount ?? 0,
      icon: BookOpen,
      tone: "emerald",
      href: "/admin/modules",
    },
    {
      label: "Quiz",
      value: quizCount ?? 0,
      icon: ClipboardList,
      tone: "violet",
      href: "/admin/quizzes",
    },
  ];

  const toneClasses: Record<string, string> = {
    navy: "bg-navy-50 text-navy-700",
    gold: "bg-gold-50 text-gold-700",
    emerald: "bg-emerald-50 text-emerald-700",
    violet: "bg-violet-50 text-violet-700",
  };

  return (
    <div className="space-y-8">
      <header>
        <span className="eyebrow text-signal-700">Console administration</span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Vue d'ensemble
        </h1>
        <p className="mt-2 text-slate-600">
          Pilotage de la plateforme {LEGAL.brand}.
        </p>
      </header>

      {/* Pipeline business par formation */}
      <FormationPipeline />

      {/* KPIs */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {kpis.map((k) => (
          <Link key={k.label} href={k.href}>
            <Card className="hover:-translate-y-0.5 transition-transform cursor-pointer">
              <CardBody>
                <div className="flex items-start justify-between">
                  <div>
                    <div className="text-[11px] uppercase tracking-wider text-slate-500 font-semibold">
                      {k.label}
                    </div>
                    <div className="mt-2 font-display text-3xl font-semibold text-navy-950">
                      {k.value}
                    </div>
                  </div>
                  <div
                    className={`h-10 w-10 rounded-xl flex items-center justify-center ${toneClasses[k.tone]}`}
                  >
                    <k.icon className="h-5 w-5" />
                  </div>
                </div>
              </CardBody>
            </Card>
          </Link>
        ))}
      </div>

      {/* Stats complémentaires */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card>
          <CardBody>
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-xl bg-navy-50 flex items-center justify-center">
                <Activity className="h-5 w-5 text-navy-700" />
              </div>
              <div>
                <div className="text-xs text-slate-500">Tentatives totales</div>
                <div className="font-display text-xl font-semibold text-navy-950">
                  {attemptsCount ?? 0}
                </div>
              </div>
            </div>
          </CardBody>
        </Card>
        <Card>
          <CardBody>
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-xl bg-emerald-50 flex items-center justify-center">
                <TrendingUp className="h-5 w-5 text-emerald-700" />
              </div>
              <div>
                <div className="text-xs text-slate-500">Score moyen</div>
                <div className="font-display text-xl font-semibold text-navy-950">
                  {avg}%
                </div>
              </div>
            </div>
          </CardBody>
        </Card>
        <Card>
          <CardBody>
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-xl bg-gold-50 flex items-center justify-center">
                <Clock className="h-5 w-5 text-gold-700" />
              </div>
              <div>
                <div className="text-xs text-slate-500">Activité (7 derniers jours)</div>
                <div className="font-display text-xl font-semibold text-navy-950">
                  {weekCount} tentatives
                </div>
              </div>
            </div>
          </CardBody>
        </Card>
      </div>

      {/* Deux colonnes : récents */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        <Card>
          <div className="flex items-center justify-between px-6 pt-5 pb-3 border-b border-navy-50">
            <CardTitle className="text-base">Derniers inscrits</CardTitle>
            <Link
              href="/admin/users"
              className="text-xs font-semibold text-navy-700 hover:text-navy-900 inline-flex items-center gap-1"
            >
              Voir tous <ArrowRight className="h-3 w-3" />
            </Link>
          </div>
          <div className="divide-y divide-navy-50">
            {(recentUsers ?? []).map((u) => (
              <Link
                key={u.id}
                href={`/admin/users/${u.id}`}
                className="flex items-center gap-3 px-6 py-3 hover:bg-navy-50/40 transition-colors"
              >
                <div className="h-9 w-9 rounded-full bg-navy-900 text-gold-400 flex items-center justify-center text-xs font-semibold">
                  {initials(u.full_name || u.email)}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="font-medium text-navy-900 text-sm truncate">
                    {u.full_name || u.email}
                  </div>
                  <div className="text-xs text-slate-500 truncate">{u.email}</div>
                </div>
                <span className="text-xs text-slate-500">{formatDate(u.created_at)}</span>
              </Link>
            ))}
            {(recentUsers ?? []).length === 0 && (
              <div className="px-6 py-8 text-center text-sm text-slate-400">
                Aucun utilisateur
              </div>
            )}
          </div>
        </Card>

        <Card>
          <div className="flex items-center justify-between px-6 pt-5 pb-3 border-b border-navy-50">
            <CardTitle className="text-base">Dernières tentatives</CardTitle>
            <Link
              href="/admin/analytics"
              className="text-xs font-semibold text-navy-700 hover:text-navy-900 inline-flex items-center gap-1"
            >
              Analytiques <ArrowRight className="h-3 w-3" />
            </Link>
          </div>
          <div className="divide-y divide-navy-50">
            {(recentAttempts ?? []).map((a: any) => (
              <div key={a.id} className="flex items-center gap-3 px-6 py-3">
                <div className="h-9 w-9 rounded-lg bg-navy-50 flex items-center justify-center">
                  <Award className="h-4 w-4 text-navy-700" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="font-medium text-navy-900 text-sm truncate">
                    {a.quizzes?.title ?? "Quiz"}
                  </div>
                  <div className="text-xs text-slate-500 truncate">
                    {a.profiles?.full_name || a.profiles?.email}
                  </div>
                </div>
                <Badge tone={a.passed ? "success" : "slate"}>{a.percentage}%</Badge>
              </div>
            ))}
            {(recentAttempts ?? []).length === 0 && (
              <div className="px-6 py-8 text-center text-sm text-slate-400">
                Aucune tentative
              </div>
            )}
          </div>
        </Card>
      </div>
    </div>
  );
}
