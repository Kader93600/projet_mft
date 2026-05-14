import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { getAuthorizedFormationSlugs } from "@/lib/admin-guard";
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
  CheckCircle2,
  XCircle,
  Clock3,
  Sparkles,
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

function fmtDateTime(iso: string): string {
  return new Date(iso).toLocaleString("fr-FR", {
    weekday: "short",
    day: "2-digit",
    month: "long",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function fmtDuration(start: string, end: string): string {
  const ms = new Date(end).getTime() - new Date(start).getTime();
  const minutes = Math.round(ms / 60_000);
  if (minutes < 60) return `${minutes} min`;
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  return m ? `${h}h${String(m).padStart(2, "0")}` : `${h}h`;
}

export default async function AdminSessionsPage({
  searchParams,
}: {
  searchParams?: { filter?: string };
}) {
  const supabase = createClient();
  const { slugs, isStaff } = await getAuthorizedFormationSlugs();

  // Pour les formateurs : ne lister que les sessions de leurs formations
  let query = supabase
    .from("live_sessions")
    .select(
      `
        id, title, kind, status, start_at, end_at, location,
        meeting_provider, max_participants, formation_id,
        formations!inner(slug, title, accent_color),
        trainer:profiles!live_sessions_trainer_id_fkey(id, full_name, email),
        enrollments:session_enrollments(user_id, status),
        attendance:session_attendance(user_id)
      `
    )
    .order("start_at", { ascending: false });

  if (!isStaff) {
    query = query.in("formations.slug", slugs.length ? slugs : ["__none__"]);
  }

  const filter = searchParams?.filter ?? "upcoming";
  const now = new Date().toISOString();
  if (filter === "upcoming") {
    query = query.gte("end_at", now).neq("status", "cancelled");
  } else if (filter === "past") {
    query = query.lt("end_at", now);
  } else if (filter === "cancelled") {
    query = query.eq("status", "cancelled");
  }

  const { data: sessions } = await query;

  // Compteurs pour les onglets
  const [upcoming, past, cancelled] = await Promise.all([
    supabase
      .from("live_sessions")
      .select("*", { count: "exact", head: true })
      .gte("end_at", now)
      .neq("status", "cancelled"),
    supabase
      .from("live_sessions")
      .select("*", { count: "exact", head: true })
      .lt("end_at", now),
    supabase
      .from("live_sessions")
      .select("*", { count: "exact", head: true })
      .eq("status", "cancelled"),
  ]);

  return (
    <div className="space-y-8">
      <header className="flex items-end justify-between gap-4 flex-wrap">
        <div>
          <span className="eyebrow text-signal-700">Premium · Sessions</span>
          <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
            Sessions présentielles &amp; distancielles
          </h1>
          <p className="mt-2 text-slate-600 max-w-2xl">
            Planning, visioconférences (Zoom / Teams / Meet) et émargement
            horodaté Qualiopi. Réservé aux stagiaires Premium.
          </p>
        </div>
        <Link href="/admin/sessions/new">
          <Button variant="gold" size="md">
            <CalendarPlus className="h-4 w-4" />
            Planifier une session
          </Button>
        </Link>
      </header>

      {/* Onglets de filtre */}
      <div className="flex items-center gap-2 flex-wrap border-b border-navy-100 pb-1">
        <FilterTab
          href="/admin/sessions?filter=upcoming"
          active={filter === "upcoming"}
          label="À venir"
          count={upcoming.count ?? 0}
        />
        <FilterTab
          href="/admin/sessions?filter=past"
          active={filter === "past"}
          label="Passées"
          count={past.count ?? 0}
        />
        <FilterTab
          href="/admin/sessions?filter=cancelled"
          active={filter === "cancelled"}
          label="Annulées"
          count={cancelled.count ?? 0}
        />
        <FilterTab
          href="/admin/sessions?filter=all"
          active={filter === "all"}
          label="Toutes"
        />
      </div>

      {/* Liste */}
      {!sessions?.length ? (
        <EmptyState filter={filter} />
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
                  href={`/admin/sessions/${s.id}`}
                  className="group flex items-stretch gap-0 rounded-2xl border border-navy-100 bg-white overflow-hidden hover:border-signal-500/40 hover:shadow-soft transition"
                >
                  {/* Bandeau date */}
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

                  {/* Contenu */}
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

function EmptyState({ filter }: { filter: string }) {
  return (
    <div className="rounded-2xl border border-dashed border-navy-200 bg-ivory/50 px-8 py-16 text-center">
      <div className="mx-auto h-14 w-14 rounded-2xl bg-signal-500/10 flex items-center justify-center mb-4">
        <CalendarDays className="h-7 w-7 text-signal-700" />
      </div>
      <h3 className="font-display text-lg font-semibold text-navy-950">
        {filter === "past"
          ? "Aucune session passée"
          : filter === "cancelled"
            ? "Aucune session annulée"
            : "Aucune session planifiée"}
      </h3>
      <p className="mt-2 text-sm text-slate-600 max-w-md mx-auto">
        Planifiez votre première session présentielle ou distancielle pour vos
        stagiaires Premium. Zoom, Teams, Meet — émargement horodaté inclus.
      </p>
      <Link href="/admin/sessions/new" className="inline-block mt-5">
        <Button variant="gold" size="md">
          <CalendarPlus className="h-4 w-4" />
          Planifier une session
        </Button>
      </Link>
    </div>
  );
}
