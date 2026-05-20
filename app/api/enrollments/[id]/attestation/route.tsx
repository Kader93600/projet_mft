import { NextResponse } from "next/server";
import {
  Document,
  Page,
  Text,
  View,
  renderToBuffer,
} from "@react-pdf/renderer";
import React from "react";
import { createClient } from "@/lib/supabase/server";
import { canAccessEnrollment } from "@/lib/enrollment-access";
import { LEGAL } from "@/lib/legal-config";
import {
  pdfStyles,
  PdfHeader,
  PdfFooter,
  fmtDatePdf,
} from "@/lib/pdf-shared";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

const MODALITY_LABEL: Record<string, string> = {
  presentiel: "Présentiel",
  distanciel: "Formation à distance (FOAD)",
  mixte: "Mixte présentiel + distanciel",
};

interface Props {
  ref: string;
  stagiaire: { fullName: string; email: string };
  e: any;
  hoursDone: number;
  attendanceRate: number; // 0..1
  successRate: number; // 0..1 (quiz passés / total)
}

function Doc({ ref, stagiaire, e, hoursDone, attendanceRate, successRate }: Props) {
  return (
    <Document>
      <Page size="A4" style={pdfStyles.page}>
        <PdfHeader refLabel={ref} type="Attestation" />
        <Text style={pdfStyles.title}>Attestation de fin de formation</Text>
        <Text style={pdfStyles.subtitle}>
          Article L. 6353-1 du Code du travail
        </Text>

        <View style={pdfStyles.block}>
          <Text style={{ fontSize: 10, marginBottom: 6 }}>
            Je soussigné(e), {LEGAL.director}, agissant en qualité de
            représentant légal de {LEGAL.legalName}, organisme de formation
            déclaré sous le n° {LEGAL.trainingActivityNumber}, atteste que :
          </Text>
        </View>

        <View
          style={[
            pdfStyles.partyBlock,
            { marginVertical: 12, paddingVertical: 6 },
          ]}
        >
          <Text style={[pdfStyles.party, { fontSize: 12, fontWeight: "bold" }]}>
            {stagiaire.fullName}
          </Text>
          <Text style={pdfStyles.party}>{stagiaire.email}</Text>
        </View>

        <Text style={pdfStyles.smallP}>
          a suivi l'action de formation suivante au sein de notre organisme :
        </Text>

        <Text style={pdfStyles.sectionTitle}>Action de formation</Text>
        <View style={pdfStyles.table}>
          <View style={pdfStyles.tr}>
            <Text style={pdfStyles.th}>Intitulé</Text>
            <Text style={pdfStyles.td}>
              {e.session_label ?? `Préparation au titre ${LEGAL.rncpCode}`}
            </Text>
          </View>
          <View style={pdfStyles.tr}>
            <Text style={pdfStyles.th}>Référentiel</Text>
            <Text style={pdfStyles.td}>
              {LEGAL.rncpCode} — {LEGAL.rncpTitle}
            </Text>
          </View>
          <View style={pdfStyles.tr}>
            <Text style={pdfStyles.th}>Période</Text>
            <Text style={pdfStyles.td}>
              du {fmtDatePdf(e.start_date)} au {fmtDatePdf(e.end_date)}
            </Text>
          </View>
          <View style={pdfStyles.tr}>
            <Text style={pdfStyles.th}>Durée prévue</Text>
            <Text style={pdfStyles.td}>
              {e.hours_total ? `${e.hours_total} heures` : "—"}
            </Text>
          </View>
          <View style={pdfStyles.tr}>
            <Text style={pdfStyles.th}>Durée réalisée</Text>
            <Text style={pdfStyles.td}>{hoursDone.toFixed(1)} heures</Text>
          </View>
          <View style={pdfStyles.tr}>
            <Text style={pdfStyles.th}>Taux d'assiduité</Text>
            <Text style={pdfStyles.td}>{Math.round(attendanceRate * 100)} %</Text>
          </View>
          <View style={pdfStyles.trLast}>
            <Text style={pdfStyles.th}>Modalité</Text>
            <Text style={pdfStyles.td}>
              {MODALITY_LABEL[e.modality ?? "distanciel"]}
            </Text>
          </View>
        </View>

        <Text style={pdfStyles.sectionTitle}>Évaluation des acquis</Text>
        <Text style={pdfStyles.smallP}>
          Conformément au programme et aux objectifs définis, les acquis ont
          été évalués par : quiz formatifs en fin de leçon, examens blancs en
          conditions réelles, suivi pédagogique individuel.
        </Text>
        <View style={pdfStyles.table}>
          <View style={pdfStyles.tr}>
            <Text style={pdfStyles.th}>Taux de réussite aux quiz</Text>
            <Text style={pdfStyles.td}>{Math.round(successRate * 100)} %</Text>
          </View>
          <View style={pdfStyles.trLast}>
            <Text style={pdfStyles.th}>Niveau atteint</Text>
            <Text style={pdfStyles.td}>
              {successRate >= 0.7
                ? "Objectifs pédagogiques atteints — préparé(e) à l'examen final"
                : "Objectifs partiellement atteints — un complément est recommandé"}
            </Text>
          </View>
        </View>

        <Text style={pdfStyles.smallP}>
          Cette attestation ne préjuge pas de l'obtention du titre
          professionnel <Text style={{ fontWeight: "bold" }}>{LEGAL.rncpCode}</Text>,
          qui reste subordonné à la réussite des épreuves officielles devant le
          jury.
        </Text>

        <Text style={pdfStyles.smallP}>
          Fait pour servir et valoir ce que de droit.
        </Text>

        <View style={{ marginTop: 30, alignItems: "flex-end" }}>
          <Text style={pdfStyles.smallP}>
            Fait à {LEGAL.address.city},
          </Text>
          <Text style={pdfStyles.smallP}>
            le{" "}
            {new Intl.DateTimeFormat("fr-FR", {
              day: "2-digit",
              month: "long",
              year: "numeric",
            }).format(new Date())}
            .
          </Text>
          <Text style={[pdfStyles.smallP, { marginTop: 14 }]}>
            {LEGAL.director}
          </Text>
          <Text style={[pdfStyles.smallP, { fontStyle: "italic" }]}>
            Pour {LEGAL.legalName}
          </Text>
        </View>

        <PdfFooter pageInfo="Attestation de fin de formation — Page 1 / 1" />
      </Page>
    </Document>
  );
}

export async function GET(
  _req: Request,
  { params }: { params: { id: string } }
) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: "unauth" }, { status: 401 });

  const { data: enrollment } = await supabase
    .from("enrollments")
    .select("*, user:profiles!user_id(id, full_name, email)")
    .eq("id", params.id)
    .maybeSingle();
  if (!enrollment) {
    return NextResponse.json({ error: "not_found" }, { status: 404 });
  }
  if (!(await canAccessEnrollment(user.id, (enrollment as any).user_id))) {
    return NextResponse.json({ error: "forbidden" }, { status: 403 });
  }
  const stagiaire = (enrollment as any).user;
  if (!stagiaire) {
    return NextResponse.json({ error: "stagiaire_missing" }, { status: 500 });
  }

  // Heures réalisées : on agrège lesson_progress (durée_seconds) si présent,
  // sinon estimation 0.5 h par leçon complétée.
  const { data: lp } = await supabase
    .from("lesson_progress")
    .select("completed, duration_seconds")
    .eq("user_id", stagiaire.id);
  const hoursDone =
    (lp ?? []).reduce(
      (sum: number, r: any) =>
        sum +
        (r.duration_seconds ? r.duration_seconds / 3600 : r.completed ? 0.5 : 0),
      0
    );

  // Émargements signés / total attendus
  const { data: att } = await supabase
    .from("attendance_attendees")
    .select(
      "session_id, signed:attendance_signatures!attendance_signatures_session_id_fkey(id)"
    )
    .eq("user_id", stagiaire.id);
  const totalSessions = (att ?? []).length;
  const signedSessions = (att ?? []).filter(
    (r: any) => (r.signed ?? []).length > 0
  ).length;
  const attendanceRate = totalSessions
    ? signedSessions / totalSessions
    : Math.min(1, hoursDone / Math.max(1, enrollment.hours_total ?? hoursDone));

  // Taux de réussite aux quiz
  const { data: qa } = await supabase
    .from("quiz_attempts")
    .select("passed")
    .eq("user_id", stagiaire.id)
    .not("finished_at", "is", null);
  const total = (qa ?? []).length;
  const passed = (qa ?? []).filter((r: any) => r.passed).length;
  const successRate = total ? passed / total : 0;

  const ref = String(params.id).slice(0, 8).toUpperCase();
  const buffer = await renderToBuffer(
    <Doc
      ref={ref}
      stagiaire={{
        fullName: stagiaire.full_name ?? stagiaire.email,
        email: stagiaire.email,
      }}
      e={enrollment}
      hoursDone={hoursDone}
      attendanceRate={attendanceRate}
      successRate={successRate}
    />
  );

  return new NextResponse(buffer as any, {
    status: 200,
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `inline; filename="attestation-${ref}.pdf"`,
      "Cache-Control": "private, no-store",
    },
  });
}
