import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  CalendarPlus,
  CalendarClock,
  Video,
  MapPin,
  Users,
  ChevronRight,
  CalendarDays,
  Clock3,
  Sparkles,
  GraduationCap,
} from "lucide-react";

export const dynamic = "force-dynamic";

const STATUS_LABEL: Record<string, { label: string; tone: any }> = {
  scheduled: { label: "Planifiée", tone: "navy" },
  in_progress: { label: "En cours", tone: "success" },
  completed: { label: "Terminée", tone: "slate" },
  cancelled: { label: "Annulée", tone: "rose" },
};

const KIND_LABEL: Record<string, { label: string; icon: any }> = {
  presentiel: { label: "Présentiel", icon: MapPin },
  distanciel: { label: "Distanciel", icon: Video },
  hybride: { label: "Hybride", icon: CalendarDays },
};

function fmtDuration(start: string, end: string): string {
  const ms = new Date(end).getTime() - new Date(start).getTime();
  const minutes = Math.round(ms / 60_000);
  if (minutes < 60) return `${minutes} min`;
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  return m ? `${h}h${String(m).padStart(2, "0")}` : `${h}h`;
}

export default async function FormateurSessionsPage({
  searchParams,
}: {
  searchParams?: { filter?: string };
}) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  // Formations habilitées du formateur
  const { data: habilitations } = await supabase
    .from("trainer_formations")
    .select("formation_id, formations!inner(id, slug, title)")
    .eq("trainer_id", user.id);

  const formationIds = (habilitations ?? []).map((h: any) => h.formation_id);

  if (formationIds.length === 0) {
    return (
      <div className="space-y-8">
        <header>
          <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-brand-700">
            Espace formateur
          </span>
          <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
            Sessions en direct
          </h1>
        </header>
        <div className="rounded-2xl border border-dashed border-navy-200 bg-white px-8 py-16 text-center">
          <GraduationCap className="h-10 w-10 text-slate-300 mx-auto mb-3" />
          <p className="font-semibold text-navy-900">
            Aucune habilitation enregistrée
          </p>
          <p className="mt-1 text-sm text-slate-500 max-w-md mx-auto">
            Demandez à l'administrateur de vous rattacher à une ou plusieurs
            formations pour pouvoir planifier des sessions.
          </p>
        </div>
      </div>
    );
  }

  const filter = searchParams?.filter ?? "upcoming";
  const now = new Date().toISOString();

  let query = supabase
    .from("live_sessions")
    .select(
      `
        id, title, kind, status, start_at, end_at, location,
        meeting_provider, max_participants, formation_id,
        formations!inner(slug, title, accent_color),
        enrollments:session_enrollments(user_id, status),
        attendance:session_attendance(user_id)
      `
    )
    .in("formation_id", formationIds)
    .order("start_at", { ascending: false });

  if (filter === "upcoming") {
    query = query.gte("end_at", now).neq("status", "cancelled");
  } else if (filter === "past") {
    query = query.lt("end_at", now);
  } else if (filter === "cancelled") {
    query = query.eq("status", "cancelled");
  } else if (filter === "mine") {
    query = query.eq("trainer_id", user.id);
  }

  const { data: sessions } = await query;

  const [upcoming, past, cancelled, mine] = await Promise.all([
    supabase
      .from("live_sessions")
      .select("*", { count: "exact", head: true })
      .in("formation_id", formationIds)
      .gte("end_at", now)
      .neq("status", "cancelled"),
    supabase
      .from("live_sessions")
      .select("*", { count: "exact", head: true })
      .in("formation_id", formationIds)
      .lt("end_at", now),
    supabase
      .from("live_sessions")
      .select("*", { count: "exact", head: true })
      .in("formation_id", formationIds)
      .eq("status", "cancelled"),
    supabase
      .from("live_sessions")
      .select("*", { count: "exact", head: true })
      .in("formation_id", formationIds)
      .eq("trainer_id", user.id),
  ]);

  return (
    <div className="space-y-8">
      <header className="flex items-end justify-between gap-4 flex-wrap">
        <div>
          <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-brand-700">
            Espace formateur
          </span>
          <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
            Sessions en direct
          </h1>
          <p className="mt-2 text-slate-600 max-w-2xl">
            Webinaires, ateliers et présentiel pour vos stagiaires Premium.
            Visioconférences Zoom / Teams / Meet et émargement Qualiopi.
          </p>
        </div>
        <Link href="/formateur/sessions/new">
          <Button variant="gold" size="md">
            <CalendarPlus className="h-4 w-4" />
            Planifier une session
          </Button>
        </Link>
      </header>

      <div className="flex items-center gap-2 flex-wrap border-b border-navy-100 pb-1">
        <FilterTab
          href="/formateur/sessions?filter=upcoming"
          active={filter === "upcoming"}
          label="À venir"
          count={upcoming.count ?? 0}
        />
        <FilterTab
          href="/formateur/sessions?filter=mine"
          active={filter === "mine"}
          label="Animées par moi"
          count={mine.count ?? 0}
        />
        <FilterTab
          href="/formateur/sessions?filter=past"
          active={filter === "past"}
          label="Passées"
          count={past.count ?? 0}
        />
        <FilterTab
          href="/formateur/sessions?filter=cancelled"
          active={filter === "cancelled"}
          label="Annulées"
          count={cancelled.count ?? 0}
        />
      </div>

      {!sessions?.length ? (
        <div className="rounded-2xl border border-dashed border-navy-200 bg-ivory/50 px-8 py-16 text-center">
          <div className="mx-auto h-14 w-14 rounded-2xl bg-signal-500/10 flex items-center justify-center mb-4">
            <CalendarDays className="h-7 w-7 text-signal-700" />
          </div>
          <h3 className="font-display text-lg font-semibold text-navy-950">
            {filter === "past"
              ? "Aucune session passée"
              : filter === "cancelled"
                ? "Aucune session annulée"
                : filter === "mine"
                  ? "Vous n'animez aucune session pour l'instant"
                  : "Aucune session planifiée"}
          </h3>
          <p className="mt-2 text-sm text-slate-600 max-w-md mx-auto">
            Planifiez une session présentielle ou distancielle pour vos
            stagiaires Premium. Émargement horodaté inclus.
          </p>
          <Link href="/formateur/sessions/new" className="inline-block mt-5">
            <Button variant="gold" size="md">
              <CalendarPlus className="h-4 w-4" />
              Planifier une session
            </Button>
          </Link>
        </div>
      ) : (
        <ul className="grid gap-3">
          {sessions.map((s: any) => {
            const Kind = KIND_LABEL[s.kind] ?? KIND_LABEL.distanciel;
            const Status = STATUS_LABEL[s.status] ?? STATUS_LABEL.scheduled;
            const enrolled = (s.enrollments ?? []).filter(
              (e: any) => e.status === "confirmed" || e.status === "invited"
            ).length;
            const attended = (s.attendance ?? []).length;
            const startSoon =
              new Date(s.start_at).getTime() - Date.now() < 24 * 3600_000 &&
              new Date(s.start_at).getTime() - Date.now() > 0;
            return (
              <li key={s.id}>
                <Link
                  href={`/formateur/sessions/${s.id}`}
                  className="group flex items-stretch rounded-2xl border border-navy-100 bg-white overflow-hidden hover:border-signal-500/40 hover:shadow-soft transition"
                >
                  <div className="shrink-0 w-24 md:w-28 bg-ivory border-r border-navy-100 px-3 py-4 flex flex-col items-center justify-center text-center">
                    <div className="text-[10px] uppercase tracking-wider text-slate-500 font-semibold">
                      {new Date(s.start_at).toLocaleDateString("fr-FR", {
                        month: "short",
                      })}
                    </div>
                    <div className="font-display text-3xl font-semibold text-navy-950 leading-none mt-1">
                      {new Date(s.start_at).getDate()}
                    </div>
                    <div className="text-[11px] text-slate-500 mt-1.5">
                      {new Date(s.start_at).toLocaleTimeString("fr-FR", {
                        hour: "2-digit",
                        minute: "2-digit",
                      })}
                    </div>
                  </div>

                  <div className="flex-1 min-w-0 px-4 py-3.5">
                    <div className="flex items-center gap-2 flex-wrap mb-1.5">
                      <Badge tone={Status.tone} size="sm">
                        {s.status === "in_progress" && (
                          <Clock3 className="h-3 w-3" />
                        )}
                        {Status.label}
                      </Badge>
                      <Badge tone="slate" size="sm">
                        <Kind.icon className="h-3 w-3" />
                        {Kind.label}
                      </Badge>
                      <span className="text-[11px] text-slate-500">
                        {(s.formations as any)?.title}
                      </span>
                      {startSoon && (
                        <Badge tone="gold" size="sm">
                          <Sparkles className="h-3 w-3" />
                          Bientôt
                        </Badge>
                      )}
                    </div>
                    <h3 className="font-display text-[15.5px] font-semibold text-navy-950 truncate">
                      {s.title}
                    </h3>
                    <div className="mt-1.5 text-xs text-slate-600 flex items-center gap-3 flex-wrap">
                      <span className="inline-flex items-center gap-1">
                        <CalendarClock className="h-3 w-3" />
                        {fmtDuration(s.start_at, s.end_at)}
                      </span>
                      {s.location && (
                        <span className="inline-flex items-center gap-1 truncate max-w-[200px]">
                          <MapPin className="h-3 w-3 shrink-0" />
                          <span className="truncate">{s.location}</span>
                        </span>
                      )}
                      {s.meeting_provider && (
                        <span className="inline-flex items-center gap-1 capitalize">
                          <Video className="h-3 w-3" />
                          {s.meeting_provider}
                        </span>
                      )}
                      <span className="inline-flex items-center gap-1">
                        <Users className="h-3 w-3" />
                        {enrolled}
                        {s.max_participants ? ` / ${s.max_participants}` : ""}
                        {filter === "past" && (
                          <span className="text-emerald-700">
                            · {attended} émargés
                          </span>
                        )}
                      </span>
                    </div>
                  </div>

                  <div className="shrink-0 flex items-center pr-4 text-slate-300 group-hover:text-navy-700 transition">
                    <ChevronRight className="h-5 w-5" />
                  </div>
                </Link>
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}

function FilterTab({
  href,
  active,
  label,
  count,
}: {
  href: string;
  active: boolean;
  label: string;
  count?: number;
}) {
  return (
    <Link
      href={href}
      className={
        "inline-flex items-center gap-2 px-3 py-1.5 rounded-t-lg text-sm font-medium transition " +
        (active
          ? "bg-white text-navy-950 border border-navy-100 border-b-white relative top-px"
          : "text-slate-500 hover:text-navy-900 hover:bg-ivory")
      }
    >
      {label}
      {typeof count === "number" && (
        <span
          className={
            "tabular-nums text-[11px] px-1.5 py-0.5 rounded-md " +
            (active ? "bg-signal-100 text-signal-800" : "bg-slate-100 text-slate-600")
          }
        >
          {count}
        </span>
      )}
    </Link>
  );
}
