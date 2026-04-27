import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Users,
  CheckCircle2,
  AlertTriangle,
  Sparkles,
  ArrowRight,
  Calendar,
  Clock,
  GraduationCap,
  Award,
  Layers,
} from "lucide-react";
import { findFormation } from "@/lib/formations-config";
import { cn } from "@/lib/utils";

export const dynamic = "force-dynamic";

export default async function FormateurDashboard({
  searchParams,
}: {
  searchParams?: { f?: string };
}) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  // Habilitations du formateur
  const { data: habilitations } = await supabase
    .from("trainer_formation_overview")
    .select("*")
    .eq("trainer_id", user.id);

  const habList = (habilitations ?? []) as any[];

  // Copies en attente de correction (vue créée en S7.2)
  const { count: pendingCorrections } = await supabase
    .from("pending_qr_corrections")
    .select("*", { count: "exact", head: true });

  // Onglet actif (slug ou "all")
  const activeSlug = searchParams?.f ?? "all";
  const activeHab =
    activeSlug !== "all"
      ? habList.find((h: any) => h.slug === activeSlug)
      : null;

  // Mes stagiaires (filtrés par formation si onglet actif)
  let studentsQuery = supabase
    .from("trainer_my_students")
    .select("*")
    .eq("trainer_id", user.id);
  if (activeSlug !== "all") {
    studentsQuery = studentsQuery.eq("formation_slug", activeSlug);
  }
  const { data: students } = await studentsQuery;

  const list = (students ?? []) as any[];

  // Métriques
  const total = list.length;
  const actifs = list.filter(
    (s: any) =>
      s.last_activity_at &&
      Date.now() - new Date(s.last_activity_at).getTime() <
        7 * 24 * 60 * 60 * 1000
  ).length;
  const inactifs = total - actifs;
  const totalLessonsDone = list.reduce(
    (sum: number, s: any) => sum + (s.lessons_done ?? 0),
    0
  );
  const totalQuizzesPassed = list.reduce(
    (sum: number, s: any) => sum + (s.quizzes_passed ?? 0),
    0
  );

  return (
    <div className="space-y-10">
      <header>
        <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-brand-700">
          Espace formateur
        </span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Tableau de bord
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Vue d'ensemble de vos stagiaires et de leur progression. Filtrez par
          formation pour vous concentrer sur une cohorte.
        </p>
      </header>

      {/* Bandeau alerte : copies à corriger */}
      {pendingCorrections && pendingCorrections > 0 ? (
        <Link
          href="/formateur/corrections"
          className="block rounded-2xl border-2 border-rose-300 bg-gradient-to-r from-rose-50 to-amber-50 p-5 hover:shadow-soft transition group"
        >
          <div className="flex items-center gap-4">
            <div className="h-12 w-12 rounded-xl bg-rose-100 border border-rose-200 text-rose-700 flex items-center justify-center shrink-0">
              <AlertTriangle className="h-6 w-6" />
            </div>
            <div className="flex-1 min-w-0">
              <div className="text-[10px] font-semibold uppercase tracking-[0.16em] text-rose-700">
                Action requise
              </div>
              <div className="font-display text-lg font-semibold text-navy-900 mt-0.5">
                {pendingCorrections} copie{pendingCorrections > 1 ? "s" : ""}{" "}
                en attente de correction
              </div>
              <div className="text-xs text-slate-600 mt-0.5">
                Les stagiaires reçoivent leur note dès que vous finalisez.
              </div>
            </div>
            <ArrowRight className="h-5 w-5 text-rose-700 group-hover:translate-x-1 transition" />
          </div>
        </Link>
      ) : null}

      {/* Onglets formations habilitées */}
      {habList.length === 0 ? (
        <Card>
          <CardBody className="text-center py-10">
            <div className="mx-auto h-12 w-12 rounded-2xl bg-amber-50 border border-amber-200 text-amber-700 flex items-center justify-center">
              <AlertTriangle className="h-6 w-6" />
            </div>
            <h3 className="mt-4 font-display text-lg font-semibold text-navy-900">
              Aucune habilitation
            </h3>
            <p className="mt-2 text-sm text-slate-600 max-w-md mx-auto">
              Demandez à un administrateur de vous habiliter sur une ou
              plusieurs formations pour commencer à encadrer des stagiaires.
            </p>
          </CardBody>
        </Card>
      ) : (
        <section>
          <div className="flex items-center gap-2 mb-3">
            <GraduationCap className="h-4 w-4 text-brand-700" />
            <span className="text-[11px] font-semibold uppercase tracking-[0.16em] text-slate-500">
              Mes habilitations ({habList.length})
            </span>
          </div>

          <div className="flex flex-wrap gap-2 border-b border-navy-100 pb-4">
            <TabPill
              href="/formateur"
              label={`Toutes (${habList.length})`}
              active={activeSlug === "all"}
              accent="#2530D9"
            />
            {habList.map((h: any) => {
              const f = findFormation(h.slug);
              return (
                <TabPill
                  key={h.slug}
                  href={`/formateur?f=${h.slug}`}
                  label={`${h.code} (${h.active_students ?? 0})`}
                  active={activeSlug === h.slug}
                  accent={f?.accent ?? "#2530D9"}
                  isLead={h.is_lead}
                />
              );
            })}
          </div>
        </section>
      )}

      {/* Bandeau formation active */}
      {activeHab && (
        <section
          className="rounded-2xl border-2 p-5 relative overflow-hidden"
          style={{
            borderColor: `${findFormation(activeHab.slug)?.accent ?? "#2530D9"}55`,
          }}
        >
          <div
            aria-hidden="true"
            className="absolute -top-12 -right-12 h-40 w-40 rounded-full opacity-15 blur-2xl"
            style={{
              backgroundColor:
                findFormation(activeHab.slug)?.accent ?? "#2530D9",
            }}
          />
          <div className="relative flex items-start justify-between gap-4 flex-wrap">
            <div>
              <div className="text-[10px] font-semibold uppercase tracking-[0.16em] text-slate-500">
                Cohorte active · {activeHab.code}
              </div>
              <h3 className="mt-1 font-display text-xl font-semibold text-navy-900">
                {activeHab.title}
              </h3>
              <div className="mt-2 flex flex-wrap gap-1.5">
                {activeHab.is_lead && (
                  <Badge tone="gold" size="sm">
                    <Award className="h-3 w-3" /> Référent pédagogique
                  </Badge>
                )}
                {activeHab.can_grade && (
                  <Badge tone="success" size="sm">
                    <CheckCircle2 className="h-3 w-3" /> Notation
                  </Badge>
                )}
                {activeHab.can_edit_content && (
                  <Badge tone="navy" size="sm">
                    <Layers className="h-3 w-3" /> Édition contenus
                  </Badge>
                )}
              </div>
            </div>
            <Link
              href={`/formations/${activeHab.slug}`}
              target="_blank"
              rel="noopener noreferrer"
              className="text-sm font-medium text-brand-700 hover:text-brand-900 inline-flex items-center gap-1.5"
            >
              Page publique <ArrowRight className="h-3.5 w-3.5" />
            </Link>
          </div>
        </section>
      )}

      {/* KPIs de la sélection */}
      <section className="grid sm:grid-cols-4 gap-4">
        <Kpi icon={Users} label="Stagiaires" value={total} tone="brand" />
        <Kpi
          icon={CheckCircle2}
          label="Actifs (7 j)"
          value={actifs}
          tone="success"
        />
        <Kpi
          icon={AlertTriangle}
          label="Inactifs > 7 j"
          value={inactifs}
          tone={inactifs > 0 ? "rose" : "brand"}
        />
        <Kpi
          icon={Sparkles}
          label="Leçons / quiz"
          value={`${totalLessonsDone}/${totalQuizzesPassed}`}
          tone="brand"
        />
      </section>

      {/* Liste stagiaires */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4">
          {activeSlug === "all"
            ? "Tous mes stagiaires"
            : `Stagiaires ${activeHab?.code ?? ""}`}
        </h2>
        <Card>
          <CardBody className="p-0">
            {list.length === 0 ? (
              <div className="p-10 text-center text-sm text-slate-500">
                {activeSlug === "all"
                  ? "Aucun stagiaire ne vous est encore affecté."
                  : "Aucun stagiaire affecté sur cette formation."}
              </div>
            ) : (
              <ul className="divide-y divide-navy-50">
                {list.map((s: any) => {
                  const lastAt = s.last_activity_at
                    ? new Date(s.last_activity_at)
                    : null;
                  const daysSince = lastAt
                    ? Math.floor(
                        (Date.now() - lastAt.getTime()) /
                          (24 * 60 * 60 * 1000)
                      )
                    : null;
                  const formation = s.formation_slug
                    ? findFormation(s.formation_slug)
                    : null;
                  const isInactive = daysSince !== null && daysSince > 7;
                  return (
                    <li
                      key={s.student_id}
                      className="px-6 py-4 flex items-center gap-4"
                    >
                      <div className="h-10 w-10 rounded-full bg-gradient-to-br from-brand-500 to-brand-700 text-white flex items-center justify-center font-bold text-sm shrink-0">
                        {(s.full_name ?? s.email)?.[0]?.toUpperCase() ?? "?"}
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="font-medium text-navy-900 truncate">
                          {s.full_name ?? s.email}
                        </div>
                        <div className="text-xs text-slate-500 mt-0.5 flex items-center gap-3 flex-wrap">
                          {formation && (
                            <span className="inline-flex items-center gap-1">
                              <Sparkles className="h-3 w-3 text-brand-700" />
                              {formation.code}
                            </span>
                          )}
                          <span className="inline-flex items-center gap-1">
                            <CheckCircle2 className="h-3 w-3" />
                            {s.lessons_done ?? 0} leçons
                          </span>
                          <span className="inline-flex items-center gap-1">
                            <Sparkles className="h-3 w-3" />
                            {s.quizzes_passed ?? 0} quiz
                          </span>
                        </div>
                      </div>
                      <div className="text-right shrink-0">
                        {lastAt ? (
                          isInactive ? (
                            <Badge tone="rose" size="sm">
                              <AlertTriangle className="h-3 w-3" />
                              Inactif {daysSince} j
                            </Badge>
                          ) : (
                            <Badge tone="success" size="sm">
                              <Clock className="h-3 w-3" />
                              Actif
                            </Badge>
                          )
                        ) : (
                          <Badge tone="slate" size="sm">
                            Jamais connecté
                          </Badge>
                        )}
                        <div className="text-[10px] text-slate-400 mt-1">
                          {lastAt
                            ? lastAt.toLocaleDateString("fr-FR")
                            : "—"}
                        </div>
                      </div>
                      <Link
                        href={`/formateur/stagiaires/${s.student_id}`}
                        className="text-slate-400 hover:text-brand-700"
                        aria-label="Voir le stagiaire"
                      >
                        <ArrowRight className="h-4 w-4" />
                      </Link>
                    </li>
                  );
                })}
              </ul>
            )}
          </CardBody>
        </Card>
      </section>

      {/* Liens rapides */}
      <section className="grid md:grid-cols-2 gap-4">
        <Link
          href="/formateur/sessions"
          className="rounded-2xl border border-navy-100 bg-white p-6 hover:border-signal-500/50 hover:shadow-soft transition group"
        >
          <div className="h-10 w-10 rounded-xl bg-signal-500/15 border border-signal-500/30 text-signal-700 flex items-center justify-center">
            <Calendar className="h-5 w-5" />
          </div>
          <CardTitle className="mt-4">Sessions à animer</CardTitle>
          <p className="text-sm text-slate-600 mt-1">
            Planning live + feuilles d'émargement à signer.
          </p>
          <span className="mt-4 inline-flex items-center gap-1.5 text-sm font-medium text-signal-700 group-hover:gap-3 transition-all">
            Ouvrir <ArrowRight className="h-3.5 w-3.5" />
          </span>
        </Link>

        <Link
          href="/formateur/messages"
          className="rounded-2xl border border-navy-100 bg-white p-6 hover:border-brand-300 hover:shadow-soft transition group"
        >
          <div className="h-10 w-10 rounded-xl bg-brand-100 border border-brand-200 text-brand-700 flex items-center justify-center">
            <Users className="h-5 w-5" />
          </div>
          <CardTitle className="mt-4">Messagerie stagiaires</CardTitle>
          <p className="text-sm text-slate-600 mt-1">
            Échanges directs (questions, feedback, conseils).
          </p>
          <span className="mt-4 inline-flex items-center gap-1.5 text-sm font-medium text-brand-700 group-hover:gap-3 transition-all">
            Ouvrir <ArrowRight className="h-3.5 w-3.5" />
          </span>
        </Link>
      </section>
    </div>
  );
}

function TabPill({
  href,
  label,
  active,
  accent,
  isLead,
}: {
  href: string;
  label: string;
  active: boolean;
  accent: string;
  isLead?: boolean;
}) {
  return (
    <Link
      href={href}
      className={cn(
        "inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full text-sm font-medium border transition relative",
        active
          ? "text-white shadow-soft"
          : "bg-white text-slate-700 border-navy-100 hover:border-navy-300"
      )}
      style={
        active
          ? {
              backgroundColor: accent,
              borderColor: accent,
              color: "#fff",
            }
          : undefined
      }
    >
      {isLead && (
        <Award
          className={cn("h-3 w-3", active ? "text-white" : "text-amber-600")}
        />
      )}
      {label}
    </Link>
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
  value: number | string;
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
            <div className="mt-1 font-display text-3xl font-semibold text-navy-900">
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
