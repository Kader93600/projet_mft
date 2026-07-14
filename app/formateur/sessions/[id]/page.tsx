import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import type { ComponentProps } from "react";
import { createClient } from "@/lib/supabase/server";
import type { Tables } from "@/lib/database.types";
import type { LucideIcon } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  ChevronLeft,
  CalendarClock,
  MapPin,
  Video,
  Users,
  Edit3,
  Clock3,
  Sparkles,
  ShieldCheck,
  Mail,
  ExternalLink,
  KeyRound,
  CalendarDays,
} from "lucide-react";
import { AttendanceTable } from "@/app/admin/sessions/[id]/attendance-table";
import { InviteStudentForm } from "@/app/admin/sessions/[id]/invite-student-form";
import { SessionActions } from "@/app/admin/sessions/[id]/session-actions";

export const dynamic = "force-dynamic";

/** Tons acceptés par <Badge tone={...}> (le type Tone n'est pas exporté). */
type BadgeTone = NonNullable<ComponentProps<typeof Badge>["tone"]>;

/** Profil « léger » tel que sélectionné dans les requêtes de cette page. */
type ProfileLite = Pick<Tables<"profiles">, "id" | "full_name" | "email">;

/** Formation embarquée dans le select de `live_sessions`. */
type SessionFormation = Pick<
  Tables<"formations">,
  "id" | "slug" | "title" | "code" | "accent_color"
>;

/** Ligne `live_sessions` + embeds du select ci-dessous. */
type SessionRow = Tables<"live_sessions"> & {
  formation: SessionFormation;
  trainer: ProfileLite | null;
};

/** Ligne `enrollments` + embed `profile` du select des candidats Premium. */
type PremiumEligibleRow = Pick<Tables<"enrollments">, "user_id"> & {
  profile: ProfileLite | null;
};

const STATUS_META: Record<string, { label: string; tone: BadgeTone }> = {
  scheduled: { label: "Planifiée", tone: "navy" },
  in_progress: { label: "En cours", tone: "success" },
  completed: { label: "Terminée", tone: "slate" },
  cancelled: { label: "Annulée", tone: "rose" },
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

function durationMin(start: string, end: string): number {
  return Math.round(
    (new Date(end).getTime() - new Date(start).getTime()) / 60_000
  );
}

export default async function FormateurSessionDetailPage(
  props: {
    params: Promise<{ id: string }>;
  }
) {
  const params = await props.params;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: sessionRaw } = await supabase
    .from("live_sessions")
    .select(
      `
        *,
        formation:formations!inner(id, slug, title, code, accent_color),
        trainer:profiles!live_sessions_trainer_id_fkey(id, full_name, email)
      `
    )
    .eq("id", params.id)
    .single();

  const session = sessionRaw as SessionRow | null;
  if (!session) notFound();

  // Vérif habilitation : le formateur doit être habilité sur la formation
  const { data: hab } = await supabase
    .from("trainer_formations")
    .select("trainer_id")
    .eq("trainer_id", user.id)
    .eq("formation_id", session.formation.id)
    .maybeSingle();

  if (!hab) {
    // Pas habilité : vérifier s'il est staff (admin/super_admin)
    const { data: me } = await supabase
      .from("profiles")
      .select("role")
      .eq("id", user.id)
      .single();
    if (me?.role !== "admin" && me?.role !== "super_admin") {
      redirect("/formateur/sessions");
    }
  }

  const { data: enrollments } = await supabase
    .from("session_enrollments")
    .select(
      "user_id, status, registered_at, cancelled_at, cancellation_reason"
    )
    .eq("session_id", params.id)
    .order("registered_at");

  const { data: attendance } = await supabase
    .from("session_attendance")
    .select("user_id, signed_at, method, ip_address, validated_at, notes")
    .eq("session_id", params.id);

  const userIds = (enrollments ?? []).map((e) => e.user_id);
  const { data: profilesRaw } = userIds.length
    ? await supabase
        .from("profiles")
        .select("id, full_name, email")
        .in("id", userIds)
    : { data: [] as ProfileLite[] };
  const profiles = (profilesRaw ?? []) as ProfileLite[];

  const { data: premiumEligible } = await supabase
    .from("enrollments")
    .select<string, PremiumEligibleRow>(
      "user_id, profile:profiles!inner(id, full_name, email)"
    )
    .eq("formation_id", session.formation.id)
    .eq("pack", "premium")
    .neq("status", "refuse")
    .neq("status", "abandon");

  const enrolledIds = new Set(userIds);
  const candidates = (premiumEligible ?? [])
    .map((e) => e.profile)
    .filter((p): p is ProfileLite => p !== null && !enrolledIds.has(p.id));

  const Status = STATUS_META[session.status] ?? STATUS_META.scheduled;
  const confirmedCount = (enrollments ?? []).filter(
    (e) => e.status === "confirmed" || e.status === "invited"
  ).length;
  const presentCount = attendance?.length ?? 0;
  const attendanceRate = confirmedCount
    ? Math.round((presentCount / confirmedCount) * 100)
    : 0;
  const inFuture = new Date(session.start_at).getTime() > Date.now();

  return (
    <div className="space-y-8">
      <div>
        <Link
          href="/formateur/sessions"
          className="inline-flex items-center gap-1 text-sm text-slate-600 hover:text-navy-900 transition"
        >
          <ChevronLeft className="h-4 w-4" />
          Retour aux sessions
        </Link>
        <div className="mt-3 flex items-start justify-between gap-4 flex-wrap">
          <div>
            <div className="flex items-center gap-2 flex-wrap mb-2">
              <Badge tone={Status.tone} size="sm">
                {session.status === "in_progress" && (
                  <Clock3 className="h-3 w-3" />
                )}
                {Status.label}
              </Badge>
              <Badge tone="slate" size="sm">
                {session.kind === "presentiel" && <MapPin className="h-3 w-3" />}
                {session.kind === "distanciel" && <Video className="h-3 w-3" />}
                {session.kind === "hybride" && (
                  <CalendarDays className="h-3 w-3" />
                )}
                {session.kind === "presentiel"
                  ? "Présentiel"
                  : session.kind === "distanciel"
                    ? "Distanciel"
                    : "Hybride"}
              </Badge>
              <Badge tone="bc1" size="sm">
                <Sparkles className="h-3 w-3" />
                Premium
              </Badge>
              <span className="text-[11.5px] text-slate-500">
                {session.formation.title}
              </span>
            </div>
            <h1 className="font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
              {session.title}
            </h1>
            {session.description && (
              <p className="mt-2 text-slate-600 max-w-2xl">
                {session.description}
              </p>
            )}
          </div>
          <div className="flex items-center gap-2">
            <Link href={`/formateur/sessions/${params.id}/edit`}>
              <Button variant="secondary" size="sm">
                <Edit3 className="h-4 w-4" />
                Modifier
              </Button>
            </Link>
            <SessionActions
              sessionId={params.id}
              status={session.status}
              basePath="/formateur/sessions"
            />
          </div>
        </div>
      </div>

      <div className="grid md:grid-cols-3 gap-4">
        <InfoCard
          icon={CalendarClock}
          label="Date & durée"
          value={fmt(session.start_at)}
          sub={`${durationMin(session.start_at, session.end_at)} minutes`}
        />
        {session.kind !== "distanciel" && session.location && (
          <InfoCard
            icon={MapPin}
            label="Lieu"
            value={session.location}
            sub="Présentiel"
          />
        )}
        {session.kind !== "presentiel" && session.meeting_url && (
          <div className="rounded-2xl border border-navy-100 bg-white p-5">
            <div className="flex items-center gap-2 text-[10px] uppercase tracking-wider text-slate-500 font-semibold mb-2">
              <Video className="h-3.5 w-3.5" />
              Visioconférence
            </div>
            <a
              href={session.meeting_url}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-1.5 font-semibold text-navy-950 hover:text-signal-700 transition break-all"
            >
              {session.meeting_provider
                ? session.meeting_provider.charAt(0).toUpperCase() +
                  session.meeting_provider.slice(1)
                : "Ouvrir la réunion"}
              <ExternalLink className="h-3.5 w-3.5 shrink-0" />
            </a>
            {session.meeting_password && (
              <div className="mt-2 inline-flex items-center gap-1 text-xs text-slate-600">
                <KeyRound className="h-3 w-3" />
                Code :{" "}
                <code className="ml-1 px-1.5 py-0.5 rounded bg-ivory border border-navy-100 font-mono">
                  {session.meeting_password}
                </code>
              </div>
            )}
          </div>
        )}
        <InfoCard
          icon={Users}
          label="Inscrits"
          value={`${confirmedCount}${
            session.max_participants ? ` / ${session.max_participants}` : ""
          }`}
          sub={
            session.status === "completed" || session.status === "in_progress"
              ? `${presentCount} émargés (${attendanceRate}%)`
              : "Pack Premium requis"
          }
        />
      </div>

      {session.notes_internal && (
        <div className="rounded-xl border border-gold-200 bg-gold-50 px-4 py-3">
          <div className="text-[10px] uppercase tracking-wider text-gold-800 font-semibold mb-1">
            Note interne (formateur)
          </div>
          <p className="text-sm text-navy-900">{session.notes_internal}</p>
        </div>
      )}

      <section>
        <div className="flex items-center justify-between gap-3 flex-wrap mb-3">
          <div>
            <h2 className="font-display text-xl font-semibold text-navy-950">
              Feuille d'émargement
            </h2>
            <p className="text-sm text-slate-600">
              {session.status === "scheduled"
                ? "L'émargement s'ouvre 30 min avant le début"
                : session.status === "in_progress"
                  ? "Émargement en cours — les stagiaires peuvent signer"
                  : session.status === "completed"
                    ? "Émargement clôturé — feuille horodatée archivée"
                    : "Session annulée"}
            </p>
          </div>
        </div>

        <AttendanceTable
          sessionId={params.id}
          enrollments={enrollments ?? []}
          attendance={attendance ?? []}
          profiles={profiles}
          sessionStatus={session.status}
        />
      </section>

      {(session.status === "scheduled" ||
        session.status === "in_progress") &&
        inFuture && (
          <section className="rounded-2xl border border-navy-100 bg-ivory/40 p-5">
            <div className="flex items-center gap-2 mb-3">
              <Mail className="h-4 w-4 text-signal-700" />
              <h3 className="font-display font-semibold text-navy-950">
                Inviter un stagiaire Premium
              </h3>
            </div>
            <InviteStudentForm
              sessionId={params.id}
              candidates={candidates}
            />
          </section>
        )}
    </div>
  );
}

function InfoCard({
  icon: Icon,
  label,
  value,
  sub,
}: {
  icon: LucideIcon;
  label: string;
  value: string;
  sub?: string;
}) {
  return (
    <div className="rounded-2xl border border-navy-100 bg-white p-5">
      <div className="flex items-center gap-2 text-[10px] uppercase tracking-wider text-slate-500 font-semibold mb-2">
        <Icon className="h-3.5 w-3.5" />
        {label}
      </div>
      <div className="font-display text-base font-semibold text-navy-950 leading-tight">
        {value}
      </div>
      {sub && <div className="text-[12px] text-slate-500 mt-1">{sub}</div>}
    </div>
  );
}
