"use client";

import { useState, useTransition } from "react";
import {
  CalendarClock,
  Video,
  MapPin,
  CheckCircle2,
  Clock3,
  ChevronRight,
  CalendarDays,
  ShieldCheck,
  AlertCircle,
  Loader2,
  PenLine,
  Sparkles,
  ExternalLink,
  KeyRound,
  XCircle,
  Users,
} from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { selfRegister, selfUnregister, signAttendance } from "./actions";

type Attendance = {
  signed_at: string;
  validated_at: string | null;
} | null;

type Session = {
  id: string;
  title: string;
  description: string | null;
  kind: "presentiel" | "distanciel" | "hybride";
  status: string;
  start_at: string;
  end_at: string;
  location: string | null;
  meeting_provider: string | null;
  max_participants: number | null;
  formations: {
    slug: string;
    title: string;
    code: string;
    accent_color: string | null;
  };
  trainer: { full_name: string | null } | null;
  my_status: "invited" | "confirmed" | "cancelled" | "no_show" | null;
  my_attendance: Attendance;
  meeting_url?: string | null;
  meeting_password?: string | null;
};

function fmt(iso: string): string {
  return new Date(iso).toLocaleString("fr-FR", {
    weekday: "long",
    day: "2-digit",
    month: "long",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function fmtShort(iso: string): string {
  return new Date(iso).toLocaleString("fr-FR", {
    day: "2-digit",
    month: "short",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function durationMin(start: string, end: string): string {
  const ms = new Date(end).getTime() - new Date(start).getTime();
  const min = Math.round(ms / 60_000);
  if (min < 60) return `${min} min`;
  const h = Math.floor(min / 60);
  const m = min % 60;
  return m ? `${h}h${String(m).padStart(2, "0")}` : `${h}h`;
}

function canSignNow(start: string, end: string): boolean {
  const now = Date.now();
  const s = new Date(start).getTime() - 30 * 60_000;
  const e = new Date(end).getTime() + 24 * 3600_000;
  return now >= s && now <= e;
}

export function StudentSessionsList({
  upcoming,
  past,
  userId,
}: {
  upcoming: Session[];
  past: Session[];
  userId: string;
}) {
  const [tab, setTab] = useState<"upcoming" | "past">("upcoming");
  const list = tab === "upcoming" ? upcoming : past;

  return (
    <div className="space-y-5">
      <div className="flex items-center gap-2 border-b border-navy-100 pb-1">
        <TabBtn
          active={tab === "upcoming"}
          onClick={() => setTab("upcoming")}
          label="À venir"
          count={upcoming.length}
        />
        <TabBtn
          active={tab === "past"}
          onClick={() => setTab("past")}
          label="Passées"
          count={past.length}
        />
      </div>

      {list.length === 0 ? (
        <EmptyState future={tab === "upcoming"} />
      ) : (
        <ul className="grid gap-4">
          {list.map((s) => (
            <SessionCard
              key={s.id}
              session={s}
              isPast={tab === "past"}
              userId={userId}
            />
          ))}
        </ul>
      )}
    </div>
  );
}

function TabBtn({
  active,
  onClick,
  label,
  count,
}: {
  active: boolean;
  onClick: () => void;
  label: string;
  count: number;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={
        "inline-flex items-center gap-2 px-3 py-1.5 rounded-t-lg text-sm font-medium transition " +
        (active
          ? "bg-white text-navy-950 border border-navy-100 border-b-white relative top-px"
          : "text-slate-500 hover:text-navy-900 hover:bg-ivory")
      }
    >
      {label}
      <span
        className={
          "tabular-nums text-[11px] px-1.5 py-0.5 rounded-md " +
          (active ? "bg-signal-100 text-signal-800" : "bg-slate-100 text-slate-600")
        }
      >
        {count}
      </span>
    </button>
  );
}

function EmptyState({ future }: { future: boolean }) {
  return (
    <div className="rounded-2xl border border-dashed border-navy-200 bg-white px-8 py-12 text-center">
      <CalendarDays className="h-10 w-10 text-slate-300 mx-auto mb-3" />
      <p className="font-semibold text-navy-900">
        {future
          ? "Aucune session à venir pour le moment"
          : "Aucune session passée"}
      </p>
      <p className="mt-1 text-sm text-slate-500">
        {future
          ? "Vos formateurs publient régulièrement de nouveaux créneaux. Revenez bientôt."
          : "Vos sessions terminées s'afficheront ici avec le certificat d'assiduité."}
      </p>
    </div>
  );
}

function SessionCard({
  session,
  isPast,
  userId,
}: {
  session: Session;
  isPast: boolean;
  userId: string;
}) {
  const [pending, startTransition] = useTransition();
  const [error, setError] = useState<string | null>(null);
  const [feedback, setFeedback] = useState<"idle" | "ok">("idle");

  const isEnrolled =
    session.my_status === "confirmed" || session.my_status === "invited";
  const hasSigned = !!session.my_attendance;
  const canSign = canSignNow(session.start_at, session.end_at);
  const startSoon =
    new Date(session.start_at).getTime() - Date.now() < 24 * 3600_000 &&
    new Date(session.start_at).getTime() - Date.now() > 0;
  const meetingReveal =
    new Date(session.start_at).getTime() - Date.now() < 30 * 60_000;

  function act(fn: () => Promise<void>) {
    setError(null);
    startTransition(async () => {
      try {
        await fn();
        setFeedback("ok");
        setTimeout(() => setFeedback("idle"), 2000);
      } catch (e: any) {
        setError(e.message ?? "Erreur");
      }
    });
  }

  return (
    <li className="rounded-2xl border border-navy-100 bg-white overflow-hidden hover:shadow-soft transition">
      <div className="flex flex-col md:flex-row">
        {/* Bandeau date */}
        <div className="md:w-32 shrink-0 bg-gradient-to-br from-navy-950 to-navy-900 text-white px-4 py-5 flex md:flex-col items-center md:items-start justify-between md:justify-center gap-2">
          <div>
            <div className="text-[10px] uppercase tracking-wider text-white/60 font-semibold">
              {new Date(session.start_at).toLocaleDateString("fr-FR", {
                weekday: "short",
              })}
            </div>
            <div className="font-display text-4xl font-semibold leading-none mt-1">
              {new Date(session.start_at).getDate()}
            </div>
            <div className="text-[12px] text-white/70 mt-1 capitalize">
              {new Date(session.start_at).toLocaleDateString("fr-FR", {
                month: "long",
              })}
            </div>
          </div>
          <div className="text-[13px] font-medium text-signal-300 md:mt-3 inline-flex items-center gap-1">
            <Clock3 className="h-3 w-3" />
            {new Date(session.start_at).toLocaleTimeString("fr-FR", {
              hour: "2-digit",
              minute: "2-digit",
            })}
          </div>
        </div>

        {/* Contenu */}
        <div className="flex-1 min-w-0 p-5">
          <div className="flex items-center gap-2 flex-wrap mb-2">
            <Badge tone="slate" size="sm">
              {session.kind === "presentiel" && (
                <MapPin className="h-3 w-3" />
              )}
              {session.kind === "distanciel" && (
                <Video className="h-3 w-3" />
              )}
              {session.kind === "hybride" && (
                <CalendarDays className="h-3 w-3" />
              )}
              {session.kind === "presentiel"
                ? "Présentiel"
                : session.kind === "distanciel"
                  ? "Distanciel"
                  : "Hybride"}
            </Badge>
            <span className="text-[11.5px] text-slate-500">
              {session.formations.title}
            </span>
            {startSoon && !isPast && (
              <Badge tone="gold" size="sm">
                <Sparkles className="h-3 w-3" />
                Bientôt
              </Badge>
            )}
            {hasSigned && (
              <Badge tone="success" size="sm">
                <CheckCircle2 className="h-3 w-3" />
                Émargé
              </Badge>
            )}
            {session.status === "cancelled" && (
              <Badge tone="rose" size="sm">
                <XCircle className="h-3 w-3" />
                Annulée
              </Badge>
            )}
          </div>

          <h3 className="font-display text-lg font-semibold text-navy-950 leading-tight">
            {session.title}
          </h3>
          {session.description && (
            <p className="mt-1 text-sm text-slate-600 line-clamp-2">
              {session.description}
            </p>
          )}

          <div className="mt-3 text-xs text-slate-600 flex items-center gap-x-4 gap-y-1 flex-wrap">
            <span className="inline-flex items-center gap-1">
              <CalendarClock className="h-3 w-3" />
              {durationMin(session.start_at, session.end_at)}
            </span>
            {session.location && (
              <span className="inline-flex items-center gap-1 truncate max-w-[260px]">
                <MapPin className="h-3 w-3 shrink-0" />
                <span className="truncate">{session.location}</span>
              </span>
            )}
            {session.meeting_provider && (
              <span className="inline-flex items-center gap-1 capitalize">
                <Video className="h-3 w-3" />
                {session.meeting_provider}
              </span>
            )}
            {session.trainer?.full_name && (
              <span className="inline-flex items-center gap-1">
                <ShieldCheck className="h-3 w-3" />
                {session.trainer.full_name}
              </span>
            )}
          </div>

          {/* Lien visio (révélé 30 min avant) */}
          {isEnrolled &&
            session.meeting_url &&
            meetingReveal &&
            session.status !== "cancelled" && (
              <div className="mt-3 rounded-lg bg-signal-50 border border-signal-200 px-3 py-2.5 flex items-center justify-between gap-3 flex-wrap">
                <div>
                  <div className="text-[11px] uppercase tracking-wider text-signal-800 font-semibold">
                    Lien de connexion ouvert
                  </div>
                  {session.meeting_password && (
                    <div className="text-xs text-navy-900 mt-0.5 inline-flex items-center gap-1">
                      <KeyRound className="h-3 w-3" />
                      Code :{" "}
                      <code className="ml-1 px-1.5 py-0.5 rounded bg-white border border-signal-200 font-mono">
                        {session.meeting_password}
                      </code>
                    </div>
                  )}
                </div>
                <a
                  href={session.meeting_url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-1.5 text-sm font-semibold text-signal-800 hover:text-signal-900"
                >
                  Rejoindre
                  <ExternalLink className="h-3.5 w-3.5" />
                </a>
              </div>
            )}

          {error && (
            <div className="mt-3 flex items-center gap-2 rounded-lg bg-rose-50 border border-rose-200 px-3 py-2 text-sm text-rose-800">
              <AlertCircle className="h-4 w-4" />
              {error}
            </div>
          )}

          {/* Actions */}
          <div className="mt-4 flex items-center gap-2 flex-wrap">
            {!isPast && session.status !== "cancelled" && (
              <>
                {!isEnrolled ? (
                  <Button
                    variant="gold"
                    size="sm"
                    disabled={pending}
                    onClick={() => act(() => selfRegister(session.id))}
                  >
                    {pending ? (
                      <Loader2 className="h-3.5 w-3.5 animate-spin" />
                    ) : (
                      <CheckCircle2 className="h-3.5 w-3.5" />
                    )}
                    Je m'inscris
                  </Button>
                ) : (
                  <>
                    {canSign && !hasSigned && (
                      <Button
                        variant="gold"
                        size="sm"
                        disabled={pending}
                        onClick={() =>
                          act(() => signAttendance(session.id, "online_click"))
                        }
                      >
                        {pending ? (
                          <Loader2 className="h-3.5 w-3.5 animate-spin" />
                        ) : (
                          <PenLine className="h-3.5 w-3.5" />
                        )}
                        Émarger maintenant
                      </Button>
                    )}
                    {!canSign && !hasSigned && (
                      <span className="text-[12px] text-slate-500 inline-flex items-center gap-1">
                        <Clock3 className="h-3 w-3" />
                        Émargement ouvert 30 min avant le début
                      </span>
                    )}
                    {hasSigned && (
                      <span className="text-[12px] text-emerald-700 inline-flex items-center gap-1 font-medium">
                        <CheckCircle2 className="h-3.5 w-3.5" />
                        Vous avez émargé à{" "}
                        {fmtShort(session.my_attendance!.signed_at)}
                      </span>
                    )}
                    {!hasSigned && (
                      <Button
                        variant="ghost"
                        size="sm"
                        disabled={pending}
                        onClick={() => {
                          if (!confirm("Vous désinscrire de cette session ?"))
                            return;
                          act(() => selfUnregister(session.id));
                        }}
                      >
                        Me désinscrire
                      </Button>
                    )}
                  </>
                )}
              </>
            )}
            {isPast && hasSigned && (
              <span className="text-[12px] text-emerald-700 inline-flex items-center gap-1 font-medium">
                <ShieldCheck className="h-3.5 w-3.5" />
                Présence validée{" "}
                {session.my_attendance!.validated_at && "(Qualiopi)"}
              </span>
            )}
            {isPast && isEnrolled && !hasSigned && (
              <span className="text-[12px] text-slate-500 inline-flex items-center gap-1">
                <XCircle className="h-3.5 w-3.5" />
                Pas d'émargement enregistré
              </span>
            )}
          </div>
        </div>
      </div>
    </li>
  );
}
