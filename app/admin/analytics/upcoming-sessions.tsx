import Link from "next/link";
import {
  CalendarDays,
  Video,
  MapPin,
  Users,
  Clock3,
  CalendarRange,
} from "lucide-react";

interface UpcomingSession {
  id: string;
  title: string;
  kind: "presentiel" | "distanciel" | "hybride";
  start_at: string;
  end_at: string;
  status: string;
  max_participants: number | null;
  meeting_provider: string | null;
  formation_code: string;
  formation_title: string;
  accent_color: string | null;
  enrolled_count: number;
}

export function UpcomingSessionsSection({
  sessions,
}: {
  sessions: UpcomingSession[];
}) {
  if (sessions.length === 0) {
    return (
      <div className="rounded-2xl border border-navy-100 bg-white p-6 text-center">
        <CalendarRange className="h-8 w-8 text-slate-300 mx-auto mb-2" />
        <p className="text-sm text-slate-500">
          Aucune session live programmée dans les 14 prochains jours.
        </p>
      </div>
    );
  }

  return (
    <div className="rounded-2xl border border-navy-100 bg-white overflow-hidden">
      <div className="px-5 py-3 bg-ivory border-b border-navy-100 flex items-center justify-between flex-wrap gap-2">
        <div className="flex items-center gap-2">
          <CalendarDays className="h-4 w-4 text-brand-700" />
          <h3 className="font-display font-semibold text-navy-900">
            Sessions live à venir
          </h3>
          <span className="text-xs bg-navy-50 border border-navy-100 rounded-md px-1.5 py-0.5 text-slate-700">
            {sessions.length}
          </span>
        </div>
        <Link
          href="/admin/sessions"
          className="text-[11px] font-semibold text-brand-700 hover:text-brand-900"
        >
          Gérer →
        </Link>
      </div>
      <ul className="divide-y divide-navy-50">
        {sessions.slice(0, 10).map((s) => {
          const start = new Date(s.start_at);
          const daysAway = Math.round(
            (start.getTime() - Date.now()) / (1000 * 60 * 60 * 24)
          );
          const isToday = start.toDateString() === new Date().toDateString();
          const KindIcon =
            s.kind === "presentiel"
              ? MapPin
              : s.kind === "distanciel"
                ? Video
                : CalendarDays;
          return (
            <li key={s.id}>
              <Link
                href={`/admin/sessions/${s.id}`}
                className="flex items-center gap-3 px-5 py-2.5 hover:bg-ivory/40 transition"
              >
                <div className="w-12 shrink-0 text-center">
                  <div className="text-[10px] font-semibold uppercase text-slate-500">
                    {start.toLocaleDateString("fr-FR", { weekday: "short" })}
                  </div>
                  <div className="font-display text-xl font-semibold text-navy-950 leading-none">
                    {start.getDate()}
                  </div>
                  <div className="text-[10px] text-slate-500 mt-0.5">
                    {isToday
                      ? "Aujourd'hui"
                      : daysAway === 1
                        ? "Demain"
                        : `J+${daysAway}`}
                  </div>
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 flex-wrap mb-0.5">
                    <span
                      className="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-semibold"
                      style={{
                        backgroundColor: `${s.accent_color ?? "#0E1240"}22`,
                        color: s.accent_color ?? "#0E1240",
                      }}
                    >
                      {s.formation_code}
                    </span>
                    <span className="inline-flex items-center gap-1 text-[11px] text-slate-500">
                      <KindIcon className="h-3 w-3" />
                      {s.kind === "presentiel"
                        ? "Présentiel"
                        : s.kind === "distanciel"
                          ? s.meeting_provider ?? "Distanciel"
                          : "Hybride"}
                    </span>
                  </div>
                  <div className="text-sm font-medium text-navy-900 truncate">
                    {s.title}
                  </div>
                  <div className="text-[11px] text-slate-500 inline-flex items-center gap-2 mt-0.5">
                    <Clock3 className="h-3 w-3" />
                    {start.toLocaleTimeString("fr-FR", {
                      hour: "2-digit",
                      minute: "2-digit",
                    })}
                    <span>·</span>
                    <Users className="h-3 w-3" />
                    {s.enrolled_count}
                    {s.max_participants ? ` / ${s.max_participants}` : ""}
                  </div>
                </div>
              </Link>
            </li>
          );
        })}
      </ul>
    </div>
  );
}
