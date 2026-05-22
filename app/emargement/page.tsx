import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  CalendarClock,
  CheckCircle2,
  PenLine,
  ShieldCheck,
  Clock,
  AlertTriangle,
} from "lucide-react";
import { signAttendance } from "./actions";

export const dynamic = "force-dynamic";

const HALFDAY_LABEL: Record<string, string> = {
  matin: "Matin",
  apres_midi: "Après-midi",
  journee: "Journée",
};

function fmtDate(iso: string) {
  return new Intl.DateTimeFormat("fr-FR", {
    weekday: "long",
    day: "2-digit",
    month: "long",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  }).format(new Date(iso));
}

function isOpenForSigning(starts: string, ends: string) {
  const now = Date.now();
  const startMs = new Date(starts).getTime() - 30 * 60_000;
  const endMs = new Date(ends).getTime() + 24 * 3600_000;
  return now >= startMs && now <= endMs;
}

export default async function EmargementPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data: rows } = await supabase
    .from("attendance_attendees")
    .select(
      "session:attendance_sessions(*), signed:attendance_signatures!attendance_signatures_session_id_fkey(id, signed_at, signature_name, signature_hash)"
    )
    .eq("user_id", user.id);

  // Signature de référence (dessinée lors de la signature obligatoire),
  // réutilisée pour l'émargement.
  const { data: sigRow } = await supabase
    .from("user_signatures")
    .select("signature_data")
    .eq("user_id", user.id)
    .maybeSingle();
  const refSignature = (sigRow as any)?.signature_data ?? null;

  const now = Date.now();
  const sessions = (rows ?? [])
    .map((r: any) => ({
      ...r.session,
      signature: (r.signed ?? []).find((s: any) => s) ?? null,
    }))
    .sort(
      (a: any, b: any) =>
        new Date(a.starts_at).getTime() - new Date(b.starts_at).getTime()
    );

  const upcoming = sessions.filter(
    (s: any) => new Date(s.ends_at).getTime() + 24 * 3600_000 >= now
  );
  const past = sessions.filter(
    (s: any) => new Date(s.ends_at).getTime() + 24 * 3600_000 < now
  );

  return (
    <div className="space-y-10">
      <header>
        <span className="eyebrow text-gold-700">Présence</span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Mes feuilles d'émargement
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Signez chaque session synchrone (cours en direct, examen blanc, jury)
          pour valider votre présence. Vos signatures sont horodatées et
          tiennent lieu de preuve Qualiopi.
        </p>
      </header>

      <section>
        <h2 className="font-display text-lg font-semibold text-navy-900 mb-4">
          Sessions en cours / à venir
        </h2>
        <div className="space-y-3">
          {upcoming.length === 0 && (
            <Card>
              <CardBody className="text-center text-sm text-slate-500 py-10">
                Aucune session synchrone planifiée pour le moment.
              </CardBody>
            </Card>
          )}
          {upcoming.map((s: any) => {
            const open = isOpenForSigning(s.starts_at, s.ends_at);
            const signed = !!s.signature;
            return (
              <Card key={s.id}>
                <CardBody>
                  <div className="flex items-start justify-between gap-4 flex-wrap">
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2">
                        <CalendarClock className="h-4 w-4 text-gold-700" />
                        <Badge tone="navy" size="sm">
                          {HALFDAY_LABEL[s.half_day]}
                        </Badge>
                      </div>
                      <CardTitle className="mt-2">{s.title}</CardTitle>
                      <p className="text-sm text-slate-600 mt-1">
                        {fmtDate(s.starts_at)}
                      </p>
                      {s.location && (
                        <p className="text-xs text-slate-500 mt-1">
                          📍 {s.location}
                        </p>
                      )}
                    </div>
                    {signed ? (
                      <div className="text-right text-sm">
                        <Badge tone="success" size="sm">
                          <CheckCircle2 className="h-3 w-3" /> Signée
                        </Badge>
                        <div className="text-xs text-slate-500 mt-1">
                          {fmtDate(s.signature.signed_at)}
                        </div>
                      </div>
                    ) : open ? (
                      <Badge tone="gold" size="sm">
                        <Clock className="h-3 w-3" /> À signer
                      </Badge>
                    ) : (
                      <Badge tone="slate" size="sm">
                        Pas encore ouverte
                      </Badge>
                    )}
                  </div>

                  {!signed && open && (
                    <form
                      action={async (fd) => {
                        "use server";
                        await signAttendance(s.id, fd);
                      }}
                      className="mt-5 space-y-3"
                    >
                      {refSignature ? (
                        <div className="inline-block rounded-xl border border-navy-100 bg-slate-50/60 p-3">
                          <div className="text-[11px] uppercase tracking-wider text-slate-500 mb-1.5">
                            Votre signature
                          </div>
                          {/* eslint-disable-next-line @next/next/no-img-element */}
                          <img
                            src={refSignature}
                            alt="Votre signature"
                            className="h-12 w-auto max-w-[200px]"
                          />
                        </div>
                      ) : (
                        <div className="rounded-xl border border-amber-200 bg-amber-50 p-3 text-xs text-amber-800">
                          Vous n'avez pas encore de signature de référence.{" "}
                          <a
                            href="/signature-obligatoire"
                            className="underline font-medium"
                          >
                            Signez d'abord vos documents
                          </a>
                          .
                        </div>
                      )}
                      <label className="flex items-start gap-2 text-xs text-slate-600">
                        <input
                          type="checkbox"
                          name="ack"
                          required
                          className="mt-0.5 h-4 w-4 rounded border-navy-300"
                        />
                        <span>
                          Je certifie ma présence effective à cette session. Ma
                          signature de référence est apposée, horodatée et
                          IP-tracée, et tient lieu de feuille d'émargement
                          officielle.
                        </span>
                      </label>
                      <Button
                        type="submit"
                        variant="gold"
                        disabled={!refSignature}
                      >
                        <PenLine className="h-4 w-4" /> Signer ma présence
                      </Button>
                    </form>
                  )}

                  {!signed && !open && (
                    <div className="mt-4 text-xs text-slate-500 flex items-center gap-2">
                      <AlertTriangle className="h-3.5 w-3.5" /> La signature
                      sera disponible 30 min avant le début et jusqu'à 24 h
                      après la fin de la session.
                    </div>
                  )}

                  {signed && s.signature.signature_hash && (
                    <details className="mt-4 text-xs text-slate-500">
                      <summary className="cursor-pointer">
                        Empreinte de preuve (SHA-256)
                      </summary>
                      <code className="mt-1 block break-all bg-navy-50 p-2 rounded-lg text-[10px]">
                        {s.signature.signature_hash}
                      </code>
                    </details>
                  )}
                </CardBody>
              </Card>
            );
          })}
        </div>
      </section>

      {past.length > 0 && (
        <section>
          <h2 className="font-display text-lg font-semibold text-navy-900 mb-4">
            Historique
          </h2>
          <Card>
            <CardBody className="p-0 divide-y divide-navy-50">
              {past.map((s: any) => (
                <div
                  key={s.id}
                  className="px-5 py-3 flex items-center gap-4 text-sm"
                >
                  <div className="flex-1 min-w-0">
                    <div className="font-medium text-navy-900 truncate">
                      {s.title}
                    </div>
                    <div className="text-xs text-slate-500">
                      {fmtDate(s.starts_at)}
                    </div>
                  </div>
                  {s.signature ? (
                    <Badge tone="success" size="sm">
                      <CheckCircle2 className="h-3 w-3" /> Signée
                    </Badge>
                  ) : (
                    <Badge tone="rose" size="sm">
                      Non signée
                    </Badge>
                  )}
                </div>
              ))}
            </CardBody>
          </Card>
        </section>
      )}

      <div className="text-xs text-slate-500 flex items-start gap-2">
        <ShieldCheck className="h-3.5 w-3.5 mt-0.5 shrink-0" />
        <span>
          Conformité Qualiopi — indicateur 11. Empreinte SHA-256 + IP +
          horodatage stockés pour preuve d'intégrité.
        </span>
      </div>
    </div>
  );
}
