import { createClient } from "@/lib/supabase/server";
import { isStaff } from "@/lib/permissions";
import { redirect } from "next/navigation";
import { Users, AlertTriangle, ListChecks, Trophy, Banknote, UserPlus, Calendar, Sparkles } from "lucide-react";
import { TvAutoRefresh } from "./tv-auto-refresh";

export const dynamic = "force-dynamic";

/**
 * Mode TV / kiosk pour afficher les KPIs principaux sur un écran de bureau.
 * Auto-refresh toutes les 30 secondes. Pas d'interactions. Pas de nav.
 *
 * URL : /admin/analytics/tv
 * Idéal pour un grand écran dans le bureau de l'admin / direction.
 */
export default async function AnalyticsTvPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .single();
  if (!isStaff(profile?.role)) redirect("/dashboard");

  const { data: k } = await supabase
    .from("vw_admin_kpis_realtime")
    .select("*")
    .single();

  const kpis = (k as any) ?? {
    active_students_7d: 0,
    at_risk_students: 0,
    quiz_attempts_7d: 0,
    pass_rate_30d: 0,
    revenue_30d_cents: 0,
    new_users_7d: 0,
    active_enrollments: 0,
    live_sessions_scheduled: 0,
    pending_corrections: 0,
  };

  const now = new Date();

  return (
    <div className="min-h-screen bg-gradient-to-br from-navy-950 via-navy-900 to-navy-950 text-white p-8 flex flex-col">
      <TvAutoRefresh />

      {/* Header */}
      <header className="flex items-end justify-between mb-12">
        <div>
          <div className="text-signal-300 text-sm font-semibold tracking-[0.18em] mb-2">
            DASHBOARD LIVE · MA FORMATION TRANSPORT
          </div>
          <h1 className="font-display text-5xl font-semibold tracking-tight">
            Pilotage en temps réel
          </h1>
        </div>
        <div className="text-right">
          <div className="text-signal-300 text-xs tracking-widest">
            DERNIÈRE MISE À JOUR
          </div>
          <div className="font-display text-2xl font-semibold tabular-nums">
            {now.toLocaleTimeString("fr-FR", {
              hour: "2-digit",
              minute: "2-digit",
              second: "2-digit",
            })}
          </div>
          <div className="text-xs text-slate-400 mt-1 inline-flex items-center gap-1.5">
            <span className="relative inline-flex h-2 w-2">
              <span className="absolute inline-flex h-full w-full rounded-full bg-signal-500 opacity-75 animate-ping" />
              <span className="relative inline-flex h-2 w-2 rounded-full bg-signal-500" />
            </span>
            Auto-refresh 30 s
          </div>
        </div>
      </header>

      {/* Grille KPIs */}
      <div className="grid grid-cols-3 gap-6 flex-1">
        <TvCard
          icon={Users}
          label="Stagiaires actifs"
          value={kpis.active_students_7d}
          hint="7 derniers jours"
          accent
        />
        <TvCard
          icon={ListChecks}
          label="Tentatives quiz"
          value={kpis.quiz_attempts_7d}
          hint="7 derniers jours"
        />
        <TvCard
          icon={Trophy}
          label="Taux de réussite"
          value={`${kpis.pass_rate_30d}%`}
          hint="30 derniers jours"
          accent={Number(kpis.pass_rate_30d) >= 70}
        />
        <TvCard
          icon={Banknote}
          label="CA"
          value={new Intl.NumberFormat("fr-FR", {
            style: "currency",
            currency: "EUR",
            maximumFractionDigits: 0,
          }).format((kpis.revenue_30d_cents ?? 0) / 100)}
          hint="30 derniers jours"
          accent
        />
        <TvCard
          icon={UserPlus}
          label="Nouveaux"
          value={kpis.new_users_7d}
          hint="Stagiaires 7j"
        />
        <TvCard
          icon={Calendar}
          label="Sessions à venir"
          value={kpis.live_sessions_scheduled}
          hint="Programmées"
        />
        <TvCard
          icon={AlertTriangle}
          label="À risque"
          value={kpis.at_risk_students}
          hint=">14 j inactifs"
          warning={kpis.at_risk_students > 0}
        />
        <TvCard
          icon={Sparkles}
          label="Copies à corriger"
          value={kpis.pending_corrections}
          hint="En attente formateur"
          warning={kpis.pending_corrections > 5}
        />
        <TvCard
          icon={Users}
          label="Inscriptions actives"
          value={kpis.active_enrollments}
          hint="Toutes formations"
        />
      </div>

      <footer className="mt-12 text-center text-xs text-slate-500 tracking-widest">
        APPUYEZ SUR ÉCHAP POUR QUITTER LE MODE TV · PLEIN ÉCRAN F11
      </footer>
    </div>
  );
}

function TvCard({
  icon: Icon,
  label,
  value,
  hint,
  accent,
  warning,
}: {
  icon: any;
  label: string;
  value: number | string;
  hint: string;
  accent?: boolean;
  warning?: boolean;
}) {
  return (
    <div
      className={
        "rounded-3xl p-8 border " +
        (accent
          ? "bg-gradient-to-br from-signal-500/15 to-signal-500/5 border-signal-500/30"
          : warning
            ? "bg-gradient-to-br from-rose-500/15 to-rose-500/5 border-rose-500/30"
            : "bg-white/[0.03] border-white/10")
      }
    >
      <div className="flex items-center gap-3 mb-6">
        <div
          className={
            "h-12 w-12 rounded-2xl flex items-center justify-center " +
            (accent
              ? "bg-signal-500/25 text-signal-300"
              : warning
                ? "bg-rose-500/25 text-rose-300"
                : "bg-white/5 text-slate-300")
          }
        >
          <Icon className="h-6 w-6" />
        </div>
        <div className="text-sm uppercase tracking-widest text-slate-400 font-semibold">
          {label}
        </div>
      </div>
      <div
        className={
          "font-display text-7xl font-bold tabular-nums leading-none mb-3 " +
          (accent
            ? "text-signal-300"
            : warning
              ? "text-rose-300"
              : "text-white")
        }
      >
        {value}
      </div>
      <div className="text-sm text-slate-400">{hint}</div>
    </div>
  );
}
