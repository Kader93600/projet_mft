import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { redirect } from "next/navigation";
import Link from "next/link";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { CalendarClock, ChevronRight, ClipboardCheck } from "lucide-react";

export const dynamic = "force-dynamic";

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

export default async function EmargementAdminPage() {
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

  // Lecture service-role (RLS ne donne l'accès qu'aux admins) après contrôle.
  const db = createAdminClient();
  let q = db
    .from("attendance_sessions")
    .select("id, title, starts_at, ends_at, half_day, location, trainer_id")
    .order("starts_at", { ascending: false })
    .limit(80);
  if (isTrainer) q = q.eq("trainer_id", user.id);
  const { data: sessions } = await q;

  const ids = (sessions ?? []).map((s: any) => s.id);
  const expected = new Map<string, number>();
  const signed = new Map<string, number>();
  if (ids.length) {
    const [{ data: atts }, { data: sigs }] = await Promise.all([
      db.from("attendance_attendees").select("session_id").in("session_id", ids),
      db.from("attendance_signatures").select("session_id").in("session_id", ids),
    ]);
    for (const a of atts ?? []) {
      expected.set(a.session_id, (expected.get(a.session_id) ?? 0) + 1);
    }
    for (const s of sigs ?? []) {
      signed.set(s.session_id, (signed.get(s.session_id) ?? 0) + 1);
    }
  }

  const list = (sessions ?? []) as any[];

  return (
    <div className="space-y-8">
      <header>
        <span className="eyebrow text-gold-700 inline-flex items-center gap-1.5">
          <ClipboardCheck className="h-3.5 w-3.5" />
          Qualiopi · Présence
        </span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Feuilles d'émargement
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Présence aux sessions présentielles (matin / après-midi). Consultez qui
          a signé, téléchargez la feuille d'émargement et suivez les absences.
          {isTrainer && " Limité à vos sessions."}
        </p>
      </header>

      {list.length === 0 ? (
        <Card>
          <CardBody className="text-center py-12 text-slate-500 text-sm">
            <ClipboardCheck className="h-8 w-8 mx-auto mb-2 text-slate-300" />
            Aucune session pour le moment.
          </CardBody>
        </Card>
      ) : (
        <Card>
          <CardBody className="p-0">
            <ul className="divide-y divide-navy-50">
              {list.map((s) => {
                const exp = expected.get(s.id) ?? 0;
                const sig = signed.get(s.id) ?? 0;
                const complete = exp > 0 && sig >= exp;
                return (
                  <li key={s.id}>
                    <Link
                      href={`/admin/emargement/${s.id}`}
                      className="flex items-center gap-4 px-5 py-3.5 hover:bg-navy-50/30"
                    >
                      <div className="min-w-0 flex-1">
                        <div className="flex items-center gap-2 flex-wrap">
                          <span className="font-medium text-navy-900">
                            {s.title}
                          </span>
                          <Badge tone="navy" size="sm">
                            {HALFDAY[s.half_day] ?? s.half_day}
                          </Badge>
                        </div>
                        <div className="text-xs text-slate-500 mt-0.5 capitalize">
                          {fmtDay(s.starts_at)} · {fmtTime(s.starts_at)}
                          {s.location ? ` · ${s.location}` : ""}
                        </div>
                      </div>
                      <Badge
                        tone={complete ? "success" : sig > 0 ? "gold" : "slate"}
                        size="sm"
                      >
                        {sig} / {exp} signé{sig > 1 ? "s" : ""}
                      </Badge>
                      <ChevronRight className="h-4 w-4 text-slate-400 shrink-0" />
                    </Link>
                  </li>
                );
              })}
            </ul>
          </CardBody>
        </Card>
      )}
    </div>
  );
}
