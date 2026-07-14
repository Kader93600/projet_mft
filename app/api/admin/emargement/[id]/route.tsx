// Feuille d'émargement (PDF) d'une session : présents, absents, signatures.
import { NextResponse } from "next/server";
import {
  Document,
  Page,
  Text,
  View,
  Image,
  renderToBuffer,
} from "@react-pdf/renderer";
import React from "react";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { pdfStyles, PdfHeader, PdfFooter } from "@/lib/pdf-shared";
import type { Tables } from "@/lib/database.types";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

type AttendanceSession = Tables<"attendance_sessions">;
type Attendee = Pick<Tables<"attendance_attendees">, "user_id">;
type AttendeeProfile = Pick<Tables<"profiles">, "id" | "full_name">;
type AttendanceSignature = Pick<
  Tables<"attendance_signatures">,
  "user_id" | "signed_at" | "signature_data"
>;

const HALFDAY: Record<string, string> = {
  matin: "Matin",
  apres_midi: "Après-midi",
  journee: "Journée",
};

function frDate(iso: string) {
  return new Intl.DateTimeFormat("fr-FR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  }).format(new Date(iso));
}
function frTime(iso: string) {
  return new Intl.DateTimeFormat("fr-FR", {
    hour: "2-digit",
    minute: "2-digit",
  }).format(new Date(iso));
}

interface Row {
  name: string;
  present: boolean;
  signature?: string | null;
  signedAt?: string | null;
}

function Doc({
  refLabel,
  session,
  rows,
}: {
  refLabel: string;
  session: AttendanceSession;
  rows: Row[];
}) {
  return (
    <Document>
      <Page size="A4" style={pdfStyles.page}>
        <PdfHeader refLabel={refLabel} type="Émargement" />
        <Text style={pdfStyles.title}>Feuille d'émargement</Text>
        <Text style={pdfStyles.subtitle}>
          {session.title} — {HALFDAY[session.half_day] ?? session.half_day}
        </Text>

        <View style={pdfStyles.block}>
          <Text style={pdfStyles.smallP}>
            Date : {frDate(session.starts_at)} ({frTime(session.starts_at)} –{" "}
            {frTime(session.ends_at)})
          </Text>
          {session.location ? (
            <Text style={pdfStyles.smallP}>Lieu : {session.location}</Text>
          ) : null}
        </View>

        <View style={pdfStyles.table}>
          <View style={pdfStyles.tr}>
            <Text style={[pdfStyles.th, { width: "40%" }]}>Stagiaire</Text>
            <Text style={[pdfStyles.th, { width: "18%" }]}>Présence</Text>
            <Text style={[pdfStyles.th, { width: "27%" }]}>Signature</Text>
            <Text style={[pdfStyles.th, { width: "15%" }]}>Heure</Text>
          </View>
          {rows.map((r, i) => (
            <View
              key={i}
              style={i === rows.length - 1 ? pdfStyles.trLast : pdfStyles.tr}
            >
              <Text style={[pdfStyles.td, { width: "40%" }]}>{r.name}</Text>
              <Text style={[pdfStyles.td, { width: "18%" }]}>
                {r.present ? "Présent" : "Absent"}
              </Text>
              <View style={[pdfStyles.td, { width: "27%" }]}>
                {r.signature ? (
                  // eslint-disable-next-line jsx-a11y/alt-text
                  (<Image
                    src={r.signature}
                    style={{ width: 90, height: 30, objectFit: "contain" }}
                  />)
                ) : (
                  <Text style={{ color: "#94a3b8" }}>—</Text>
                )}
              </View>
              <Text style={[pdfStyles.td, { width: "15%", fontSize: 9 }]}>
                {r.signedAt ? frTime(r.signedAt) : "—"}
              </Text>
            </View>
          ))}
        </View>

        <Text style={{ marginTop: 16, fontSize: 9, color: "#0f172a" }}>
          Formateur : {session.trainer_signature_name ?? "____________________"}
          {session.trainer_signed_at
            ? ` (signé le ${frDate(session.trainer_signed_at)})`
            : ""}
        </Text>

        <PdfFooter pageInfo="Feuille d'émargement — preuve Qualiopi" />
      </Page>
    </Document>
  );
}

export async function GET(_req: Request, props: { params: Promise<{ id: string }> }) {
  const params = await props.params;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: "unauth" }, { status: 401 });
  const { data: me } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();
  const role = me?.role;
  const isAdmin = role === "admin" || role === "super_admin";
  const isTrainer = role === "trainer";
  if (!isAdmin && !isTrainer) {
    return NextResponse.json({ error: "forbidden" }, { status: 403 });
  }

  const db = createAdminClient();
  const { data: sessionRow } = await db
    .from("attendance_sessions")
    .select("*")
    .eq("id", params.id)
    .maybeSingle();
  if (!sessionRow) return NextResponse.json({ error: "not_found" }, { status: 404 });
  const session = sessionRow as AttendanceSession;
  if (isTrainer && session.trainer_id !== user.id) {
    return NextResponse.json({ error: "forbidden" }, { status: 403 });
  }

  const { data: attendees } = await db
    .from("attendance_attendees")
    .select("user_id")
    .eq("session_id", params.id);
  const userIds = ((attendees ?? []) as Attendee[]).map((a) => a.user_id);
  const { data: profiles } = userIds.length
    ? await db.from("profiles").select("id, full_name").in("id", userIds)
    : { data: [] as AttendeeProfile[] };
  const { data: sigs } = await db
    .from("attendance_signatures")
    .select("user_id, signed_at, signature_data")
    .eq("session_id", params.id);

  const profMap = new Map(
    ((profiles ?? []) as AttendeeProfile[]).map((p) => [p.id, p] as const)
  );
  const sigMap = new Map(
    ((sigs ?? []) as AttendanceSignature[]).map((s) => [s.user_id, s] as const)
  );
  const rows: Row[] = userIds
    .map((uid: string) => {
      const sig = sigMap.get(uid);
      return {
        name: profMap.get(uid)?.full_name ?? "—",
        present: !!sig,
        signature: sig?.signature_data ?? null,
        signedAt: sig?.signed_at ?? null,
      };
    })
    .sort((a, b) => a.name.localeCompare(b.name));

  const refLabel = String(params.id).replace(/-/g, "").slice(0, 8).toUpperCase();
  const buffer = await renderToBuffer(
    <Doc refLabel={refLabel} session={session} rows={rows} />
  );

  // `as any` conservé : quirk de typage tiers. `renderToBuffer` renvoie un
  // `Buffer<ArrayBufferLike>` (Node) que lib.dom refuse comme `BodyInit`
  // (qui attend un `ArrayBufferView<ArrayBuffer>`). Toute alternative typée
  // (copie en Uint8Array) modifierait le runtime.
  return new NextResponse(buffer as any, {
    status: 200,
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `inline; filename="emargement-${refLabel}.pdf"`,
      "Cache-Control": "private, no-store",
    },
  });
}
