import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  HeartHandshake,
  CalendarDays,
  Video,
  MapPin,
  Phone,
  UserCheck,
  Mail,
  Pin,
  MessageCircle,
} from "lucide-react";

export const dynamic = "force-dynamic";

export default async function AccompagnementPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data: profile } = await supabase
    .from("profiles")
    .select("referent_id")
    .eq("id", user.id)
    .single();

  const refId = profile?.referent_id ?? null;

  const [{ data: referent }, { data: sessions }, { data: notes }] = await Promise.all([
    refId
      ? supabase
          .from("profiles")
          .select("id, full_name, email")
          .eq("id", refId)
          .single()
      : Promise.resolve({ data: null }),
    supabase
      .from("coaching_sessions")
      .select("*")
      .eq("user_id", user.id)
      .order("scheduled_at", { ascending: false })
      .limit(30),
    supabase
      .from("coaching_notes")
      .select("*")
      .eq("user_id", user.id)
      .eq("visible_to_student", true)
      .order("pinned", { ascending: false })
      .order("created_at", { ascending: false })
      .limit(30),
  ]);

  const now = Date.now();
  const upcoming = (sessions ?? []).filter(
    (s: any) => s.status === "prevue" && +new Date(s.scheduled_at) >= now
  );
  const past = (sessions ?? []).filter(
    (s: any) => !(s.status === "prevue" && +new Date(s.scheduled_at) >= now)
  );

  return (
    <div className="space-y-10">
      <header>
        <span className="eyebrow text-gold-700">Votre référent</span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Accompagnement pédagogique
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Votre référent formateur vous suit tout au long du parcours. Retrouvez
          ici ses rendez-vous, ses messages et ses recommandations.
        </p>
      </header>

      {/* Référent */}
      <section>
        {referent ? (
          <Card variant="gold">
            <CardBody className="flex flex-col md:flex-row md:items-center gap-5">
              <div className="h-16 w-16 rounded-2xl bg-gold-500 text-navy-900 flex items-center justify-center shrink-0">
                <HeartHandshake className="h-8 w-8" />
              </div>
              <div className="flex-1">
                <div className="text-xs uppercase tracking-wider text-gold-700">
                  Votre référent formateur
                </div>
                <div className="font-display text-xl font-semibold text-navy-900 mt-0.5">
                  {referent.full_name || referent.email}
                </div>
                <a
                  href={`mailto:${referent.email}`}
                  className="mt-1 inline-flex items-center gap-1.5 text-sm text-navy-700 hover:text-gold-800"
                >
                  <Mail className="h-4 w-4" /> {referent.email}
                </a>
              </div>
            </CardBody>
          </Card>
        ) : (
          <Card>
            <CardBody className="py-8 text-center space-y-2">
              <UserCheck className="h-8 w-8 text-slate-400 mx-auto" />
              <p className="text-sm text-slate-600 max-w-md mx-auto">
                Aucun référent ne vous est encore attribué. L'équipe
                pédagogique vous affectera prochainement un formateur.
              </p>
            </CardBody>
          </Card>
        )}
      </section>

      {/* Prochains rendez-vous */}
      <section>
        <div className="flex items-center gap-2 mb-4">
          <CalendarDays className="h-4 w-4 text-navy-700" />
          <h2 className="font-display text-xl font-semibold text-navy-900">
            Prochains rendez-vous
          </h2>
        </div>
        {upcoming.length === 0 ? (
          <Card>
            <CardBody className="py-8 text-center text-sm text-slate-500">
              Aucun rendez-vous programmé pour l'instant.
            </CardBody>
          </Card>
        ) : (
          <div className="grid md:grid-cols-2 gap-3">
            {upcoming.map((s: any) => (
              <SessionCard key={s.id} session={s} upcoming />
            ))}
          </div>
        )}
      </section>

      {/* Retours */}
      {notes && notes.length > 0 && (
        <section>
          <div className="flex items-center gap-2 mb-4">
            <MessageCircle className="h-4 w-4 text-gold-600" />
            <h2 className="font-display text-xl font-semibold text-navy-900">
              Retours de votre référent
            </h2>
          </div>
          <div className="space-y-3">
            {notes.map((n: any) => (
              <Card
                key={n.id}
                variant={n.pinned ? "gold" : "default"}
              >
                <CardBody>
                  {n.pinned && (
                    <div className="flex items-center gap-1 text-[11px] uppercase tracking-wider text-gold-700 mb-2">
                      <Pin className="h-3 w-3" /> Épinglé
                    </div>
                  )}
                  <div className="whitespace-pre-wrap text-navy-900 text-sm">
                    {n.body_md}
                  </div>
                  <div className="mt-2 text-[11px] text-slate-500">
                    Le{" "}
                    {new Date(n.created_at).toLocaleDateString("fr-FR", {
                      day: "2-digit",
                      month: "short",
                      year: "numeric",
                    })}
                  </div>
                </CardBody>
              </Card>
            ))}
          </div>
        </section>
      )}

      {/* Historique */}
      {past.length > 0 && (
        <section>
          <h2 className="font-display text-xl font-semibold text-navy-900 mb-4">
            Historique des sessions
          </h2>
          <div className="grid md:grid-cols-2 gap-3">
            {past.map((s: any) => (
              <SessionCard key={s.id} session={s} />
            ))}
          </div>
        </section>
      )}
    </div>
  );
}

function SessionCard({
  session,
  upcoming,
}: {
  session: any;
  upcoming?: boolean;
}) {
  const statusTone = {
    prevue: "navy",
    tenue: "success",
    annulee: "rose",
    no_show: "gold",
  }[session.status as string] as any;

  const modeIcon =
    session.mode === "visio" ? Video : session.mode === "tel" ? Phone : MapPin;
  const ModeIcon = modeIcon;

  return (
    <Card variant={upcoming ? "gold" : "default"}>
      <CardBody className="space-y-2">
        <div className="flex items-center justify-between gap-2">
          <div className="text-xs text-slate-500 uppercase tracking-wider">
            {new Date(session.scheduled_at).toLocaleDateString("fr-FR", {
              weekday: "short",
              day: "2-digit",
              month: "short",
              year: "numeric",
            })}{" "}
            ·{" "}
            {new Date(session.scheduled_at).toLocaleTimeString("fr-FR", {
              hour: "2-digit",
              minute: "2-digit",
            })}
          </div>
          <Badge tone={statusTone} size="sm">
            {session.status}
          </Badge>
        </div>
        <div className="flex items-center gap-2 text-sm text-navy-900">
          <ModeIcon className="h-4 w-4 text-gold-700" />
          <span className="capitalize">{session.mode}</span>
          <span className="text-slate-400">·</span>
          <span>{session.duration_min} min</span>
        </div>
        {session.agenda && (
          <div className="text-sm text-slate-700">{session.agenda}</div>
        )}
        {session.meeting_url && upcoming && (
          <a
            href={session.meeting_url}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-1 text-sm font-medium text-navy-900 hover:text-gold-700"
          >
            <Video className="h-4 w-4" /> Rejoindre la visio
          </a>
        )}
        {session.summary && !upcoming && (
          <details className="text-sm">
            <summary className="cursor-pointer text-xs font-medium text-navy-700 hover:text-gold-700">
              Compte-rendu
            </summary>
            <div className="mt-2 whitespace-pre-wrap text-slate-700">
              {session.summary}
            </div>
          </details>
        )}
      </CardBody>
    </Card>
  );
}
