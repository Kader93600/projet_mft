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
import type { Tables } from "@/lib/database.types";
import { canAccessEnrollment } from "@/lib/enrollment-access";
import { LEGAL } from "@/lib/legal-config";
import { resolveEnrollmentFormation } from "@/lib/enrollment-formation";
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

/** Profil stagiaire embarqué dans le select `user:profiles!user_id(...)`. */
type StagiaireProfile = Pick<
  Tables<"profiles">,
  "full_name" | "email" | "adresse" | "code_postal" | "ville"
>;

/** Ligne `enrollments` (select `*`) + embed `user`. */
type EnrollmentWithUser = Tables<"enrollments"> & {
  user: StagiaireProfile | null;
};

interface Props {
  refLabel: string;
  stagiaire: {
    fullName: string;
    email: string;
    address?: string | null;
  };
  e: EnrollmentWithUser;
}

function Doc({ refLabel, stagiaire, e }: Props) {
  const f = resolveEnrollmentFormation(e);
  return (
    <Document>
      <Page size="A4" style={pdfStyles.page}>
        <PdfHeader refLabel={refLabel} type="Convocation" />
        <Text style={pdfStyles.title}>Convocation à formation</Text>
        <Text style={pdfStyles.subtitle}>
          Indicateur Qualiopi 4 — information préalable du stagiaire
        </Text>

        <View style={pdfStyles.block}>
          <Text style={{ fontSize: 11, marginBottom: 12 }}>
            Madame, Monsieur {stagiaire.fullName},
          </Text>
          <Text style={{ fontSize: 10, marginBottom: 6 }}>
            Nous avons le plaisir de vous confirmer votre inscription à la
            session de formation suivante. Merci de prendre connaissance des
            modalités ci-dessous.
          </Text>
        </View>

        <Text style={pdfStyles.sectionTitle}>Modalités de la session</Text>
        <View style={pdfStyles.table}>
          <View style={pdfStyles.tr}>
            <Text style={pdfStyles.th}>Intitulé</Text>
            <Text style={pdfStyles.td}>{f.title}</Text>
          </View>
          <View style={pdfStyles.tr}>
            <Text style={pdfStyles.th}>Référentiel</Text>
            <Text style={pdfStyles.td}>
              {f.rncpCode ? `${f.rncpCode} — ${f.title}` : f.code}
            </Text>
          </View>
          <View style={pdfStyles.tr}>
            <Text style={pdfStyles.th}>Date de début</Text>
            <Text style={pdfStyles.td}>{fmtDatePdf(e.start_date)}</Text>
          </View>
          <View style={pdfStyles.tr}>
            <Text style={pdfStyles.th}>Date de fin prévue</Text>
            <Text style={pdfStyles.td}>{fmtDatePdf(e.end_date)}</Text>
          </View>
          <View style={pdfStyles.tr}>
            <Text style={pdfStyles.th}>Durée totale</Text>
            <Text style={pdfStyles.td}>
              {f.hoursTotal ? `${f.hoursTotal} heures` : "À préciser"}
            </Text>
          </View>
          <View style={pdfStyles.tr}>
            <Text style={pdfStyles.th}>Modalité</Text>
            <Text style={pdfStyles.td}>{MODALITY_LABEL[f.modality]}</Text>
          </View>
          <View style={pdfStyles.tr}>
            <Text style={pdfStyles.th}>Lieu</Text>
            <Text style={pdfStyles.td}>{f.location}</Text>
          </View>
          <View style={pdfStyles.trLast}>
            <Text style={pdfStyles.th}>Horaires</Text>
            <Text style={pdfStyles.td}>
              Accès 24 h / 24 — sessions live planifiées en semaine 18 h-20 h
            </Text>
          </View>
        </View>

        <Text style={pdfStyles.sectionTitle}>Objectifs pédagogiques</Text>
        <Text style={pdfStyles.smallP}>{f.objectives}</Text>

        <Text style={pdfStyles.sectionTitle}>Prérequis</Text>
        <Text style={pdfStyles.smallP}>
          {f.prerequisites}
        </Text>

        <Text style={pdfStyles.sectionTitle}>Modalités d'évaluation</Text>
        <Text style={pdfStyles.smallP}>
          • Quiz d'évaluation continue après chaque module.{"\n"}
          • 2 examens blancs en conditions réelles (durée, plein écran,
          détection de sortie d'onglet).{"\n"}
          • Examen final officiel devant jury en fin de parcours.{"\n"}
          • Attestation de fin de formation remise systématiquement (art.
          L. 6353-1 Code du travail).
        </Text>

        <Text style={pdfStyles.sectionTitle}>Accessibilité — Référent handicap</Text>
        <Text style={pdfStyles.smallP}>
          Pour toute situation de handicap nécessitant des adaptations, merci
          de contacter notre référent à{" "}
          {LEGAL.qualiopi.accessibilityContact}. Nous étudierons ensemble les
          aménagements possibles avant le démarrage.
        </Text>

        <Text style={pdfStyles.sectionTitle}>
          Documents joints / à consulter
        </Text>
        <Text style={pdfStyles.smallP}>
          • Convention de formation (signée).{"\n"}
          • Règlement intérieur : {LEGAL.website}/reglement-interieur{"\n"}
          • CGV : {LEGAL.website}/cgv{"\n"}
          • Politique de confidentialité : {LEGAL.website}/confidentialite
        </Text>

        <Text style={pdfStyles.sectionTitle}>Contacts</Text>
        <Text style={pdfStyles.smallP}>
          Pédagogique : {LEGAL.email}{"\n"}
          Administratif : {LEGAL.email}{"\n"}
          Téléphone : {LEGAL.phone}
        </Text>

        <Text style={[pdfStyles.smallP, { marginTop: 14, fontStyle: "italic" }]}>
          Nous vous souhaitons une excellente formation.
        </Text>
        <Text style={[pdfStyles.smallP, { marginTop: 4 }]}>
          {LEGAL.director}
          {"\n"}
          Pour {LEGAL.legalName}
        </Text>

        <PdfFooter pageInfo="Convocation — Page 1 / 1" />
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
  if (!user) {
    return NextResponse.json({ error: "unauth" }, { status: 401 });
  }

  const { data: enrollmentRaw } = await supabase
    .from("enrollments")
    .select(
      "*, user:profiles!user_id(full_name, email, adresse, code_postal, ville)"
    )
    .eq("id", params.id)
    .maybeSingle();

  const enrollment = enrollmentRaw as EnrollmentWithUser | null;
  if (!enrollment) {
    return NextResponse.json({ error: "not_found" }, { status: 404 });
  }
  if (!(await canAccessEnrollment(user.id, enrollment.user_id))) {
    return NextResponse.json({ error: "forbidden" }, { status: 403 });
  }
  const stagiaire = enrollment.user;
  if (!stagiaire) {
    return NextResponse.json({ error: "stagiaire_missing" }, { status: 500 });
  }
  if (!enrollment.start_date) {
    return NextResponse.json(
      {
        error: "start_date_required",
        message:
          "La convocation ne peut être générée qu'une fois la date de démarrage confirmée.",
      },
      { status: 400 }
    );
  }

  const ref = String(params.id).slice(0, 8).toUpperCase();
  const buffer = await renderToBuffer(
    <Doc
      refLabel={ref}
      stagiaire={{
        fullName: stagiaire.full_name ?? stagiaire.email,
        email: stagiaire.email,
        address:
          [
            stagiaire.adresse,
            [stagiaire.code_postal, stagiaire.ville]
              .filter(Boolean)
              .join(" "),
          ]
            .filter(Boolean)
            .join(", ") || null,
      }}
      e={enrollment}
    />
  );

  // NOTE: `as any` conservé — quirk de types : `renderToBuffer` (@react-pdf)
  // renvoie un `Buffer<ArrayBufferLike>` (@types/node), non assignable au
  // `BodyInit` (undici/DOM) attendu par NextResponse. Aucun type précis
  // possible sans copier le buffer (ce qui changerait le runtime).
  return new NextResponse(buffer as any, {
    status: 200,
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `inline; filename="convocation-${ref}.pdf"`,
      "Cache-Control": "private, no-store",
    },
  });
}
