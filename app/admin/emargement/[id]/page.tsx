import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import type { Tables } from "@/lib/database.types";
import { redirect, notFound } from "next/navigation";
import Link from "next/link";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  ArrowLeft,
  Download,
  CheckCircle2,
  XCircle,
  MapPin,
} from "lucide-react";

export const dynamic = "force-dynamic";

/** `attendance_sessions` — select("*") */
type SessionRow = Tables<"attendance_sessions">;
/** `profiles` — select("id, full_name, email") */
type AttendeeProfile = Pick<Tables<"profiles">, "id" | "full_name" | "email">;
/** `attendance_signatures` — select("user_id, signed_at, signature_data, signature_ip") */
type SignatureRow = Pick<
  Tables<"attendance_signatures">,
  "user_id" | "signed_at" | "signature_data" | "signature_ip"
>;
/** `attendance_attendees` — select("user_id") */
type AttendeeRow = Pick<Tables<"attendance_attendees">, "user_id">;

const HALFDAY: Record<string, string> = {
  matin: "Matin",
  apres_midi: "Après-midi",
  journee: "Journée",
};

function fmtDay(iso: string) {
  return new Intl.DateTimeFormat("fr-FR", {
    weekday: "long",
    day: "2-digit",
    month: "long",
    year: "numeric",
  }).format(new Date(iso));
}
function fmtTime(iso: string) {
  return new Intl.DateTimeFormat("fr-FR", {
    hour: "2-digit",
    minute: "2-digit",
  }).format(new Date(iso));
}

export default async function EmargementDetailPage({
  params,
}: {
  params: { id: string };
}) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: me } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();
  const role = me?.role;
  const isAdmin = role === "admin" || role === "super_admin";
  const isTrainer = role === "trainer";
  if (!isAdmin && !isTrainer) redirect("/dashboard");

  const db = createAdminClient();
  const { data: sessionData } = await db
    .from("attendance_sessions")
    .select("*")
    .eq("id", params.id)
    .maybeSingle();
  const session: SessionRow | null = sessionData;
  if (!session) notFound();
  if (isTrainer && session.trainer_id !== user.id) {
    redirect("/admin/emargement");
  }

  const { data: attendees } = await db
    .from("attendance_attendees")
    .select("user_id")
    .eq("session_id", params.id);
  const userIds = ((attendees ?? []) as AttendeeRow[]).map((a) => a.user_id);

  const { data: profilesData } = userIds.length
    ? await db.from("profiles").select("id, full_name, email").in("id", userIds)
    : { data: [] };
  const profiles: AttendeeProfile[] = profilesData ?? [];
  const { data: sigsData } = await db
    .from("attendance_signatures")
    .select("user_id, signed_at, signature_data, signature_ip")
    .eq("session_id", params.id);
  const sigs: SignatureRow[] = sigsData ?? [];

  const profMap = new Map<string, AttendeeProfile>(
    profiles.map((p) => [p.id, p])
  );
  const sigMap = new Map<string, SignatureRow>(sigs.map((s) => [s.user_id, s]));
  const rows = userIds
    .map((uid) => ({ uid, profile: profMap.get(uid), sig: sigMap.get(uid) }))
    .sort((a, b) =>
      (a.profile?.full_name ?? "").localeCompare(b.profile?.full_name ?? "")
    );
  const signedCount = rows.filter((r) => r.sig).length;

  return (
    <div className="space-y-6">
      <Link
        href="/admin/emargement"
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
      >
        <ArrowLeft className="h-4 w-4" /> Émargement
      </Link>

      <header className="flex items-start justify-between gap-4 flex-wrap">
        <div>
          <div className="flex items-center gap-2 flex-wrap">
            <h1 className="font-display text-2xl md:text-3xl font-semibold text-navy-950 tracking-tight">
              {session.title}
            </h1>
            <Badge tone="navy" size="sm">
              {HALFDAY[session.half_day] ?? session.half_day}
            </Badge>
          </div>
          <p className="mt-1 text-sm text-slate-600 capitalize">
            {fmtDay(session.starts_at)} · {fmtTime(session.starts_at)} –{" "}
            {fmtTime(session.ends_at)}
          </p>
          {session.location && (
            <p className="mt-1 text-xs text-slate-500 inline-flex items-center gap-1">
              <MapPin className="h-3 w-3" /> {session.location}
            </p>
          )}
        </div>
        <a
          href={`/api/admin/emargement/${params.id}`}
          target="_blank"
          className="inline-flex items-center gap-2 rounded-lg bg-navy-900 hover:bg-navy-800 text-white px-3.5 py-2 text-sm font-semibold transition-colors"
        >
          <Download className="h-4 w-4" /> Feuille d'émargement (PDF)
        </a>
      </header>

      <Badge tone={signedCount >= rows.length && rows.length > 0 ? "success" : "gold"}>
        {signedCount} / {rows.length} signature{signedCount > 1 ? "s" : ""}
      </Badge>

      <Card>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-navy-50/60 text-[11px] uppercase tracking-wider text-slate-600">
                <th className="text-left px-5 py-3 font-semibold">Stagiaire</th>
                <th className="text-left px-5 py-3 font-semibold">Présence</th>
                <th className="text-left px-5 py-3 font-semibold">Signature</th>
                <th className="text-left px-5 py-3 font-semibold">Heure</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((r) => (
                <tr key={r.uid} className="border-t border-navy-50">
                  <td className="px-5 py-3">
                    <div className="font-medium text-navy-900">
                      {r.profile?.full_name ?? "—"}
                    </div>
                    <div className="text-xs text-slate-500">
                      {r.profile?.email}
                    </div>
                  </td>
                  <td className="px-5 py-3">
                    {r.sig ? (
                      <Badge tone="success" size="sm">
                        <CheckCircle2 className="h-3 w-3" /> Présent
                      </Badge>
                    ) : (
                      <Badge tone="rose" size="sm">
                        <XCircle className="h-3 w-3" /> Absent
                      </Badge>
                    )}
                  </td>
                  <td className="px-5 py-3">
                    {r.sig?.signature_data ? (
                      // eslint-disable-next-line @next/next/no-img-element
                      <img
                        src={r.sig.signature_data}
                        alt="Signature"
                        className="h-9 w-auto max-w-[140px] rounded border border-navy-100 bg-white"
                      />
                    ) : (
                      <span className="text-slate-300 text-xs">—</span>
                    )}
                  </td>
                  <td className="px-5 py-3 text-xs text-slate-500 whitespace-nowrap">
                    {r.sig ? fmtTime(r.sig.signed_at) : "—"}
                  </td>
                </tr>
              ))}
              {rows.length === 0 && (
                <tr>
                  <td colSpan={4} className="px-5 py-12 text-center text-slate-400">
                    Aucun stagiaire inscrit à cette session.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}
