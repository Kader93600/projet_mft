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
  PdfPartyOf,
  fmtEurosPdf,
  fmtDatePdf,
} from "@/lib/pdf-shared";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

const FUNDING_LABEL: Record<string, string> = {
  opco: "OPCO (entreprise)",
  cpf: "CPF / Mon Compte Formation",
  employeur: "Employeur",
  pole_emploi: "France Travail",
  auto: "Auto-financement",
  autre: "Autre",
};

const MODALITY_LABEL: Record<string, string> = {
  presentiel: "Présentiel",
  distanciel: "Formation à distance (FOAD)",
  mixte: "Mixte présentiel + distanciel",
};

/**
 * Résultat exact du select ci-dessous :
 *   "*, user:profiles!user_id(full_name, email, phone), funder:funders(name, kind)"
 * (le client Supabase n'est pas câblé sur `Database` globalement).
 */
type EnrollmentWithRelations = Tables<"enrollments"> & {
  user: Pick<Tables<"profiles">, "full_name" | "email" | "phone"> | null;
  funder: Pick<Tables<"funders">, "name" | "kind"> | null;
};

interface Props {
  refLabel: string;
  stagiaire: { fullName: string; email: string; phone?: string | null };
  funder?: Pick<Tables<"funders">, "name" | "kind"> | null;
  e: Tables<"enrollments">;
  validityDate: string;
}

function Doc({ refLabel, stagiaire, funder, e, validityDate }: Props) {
  const ht = e.total_amount_cents ?? 0;
  const f = resolveEnrollmentFormation(e);
  return (
    <Document>
      <Page size="A4" style={pdfStyles.page}>
        <PdfHeader refLabel={refLabel} type="Devis" />
        <Text style={pdfStyles.title}>Devis de formation</Text>
        <Text style={pdfStyles.subtitle}>
          Valable jusqu'au {validityDate} — non engageant
        </Text>

        <Text style={pdfStyles.partyTitle}>Émetteur</Text>
        <PdfPartyOf />

        <Text style={pdfStyles.partyTitle}>Destinataire</Text>
        <View style={pdfStyles.partyBlock}>
          <Text style={pdfStyles.party}>{stagiaire.fullName}</Text>
          <Text style={pdfStyles.party}>{stagiaire.email}</Text>
          {stagiaire.phone && (
            <Text style={pdfStyles.party}>{stagiaire.phone}</Text>
          )}
          {funder && (
            <Text style={pdfStyles.party}>
              Financeur pressenti : {funder.name} (
              {FUNDING_LABEL[funder.kind] ?? funder.kind})
            </Text>
          )}
        </View>

        <Text style={pdfStyles.sectionTitle}>Action de formation proposée</Text>
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
            <Text style={pdfStyles.th}>Durée</Text>
            <Text style={pdfStyles.td}>
              {f.hoursTotal ? `${f.hoursTotal} heures` : "À préciser"}
            </Text>
          </View>
          <View style={pdfStyles.tr}>
            <Text style={pdfStyles.th}>Modalité</Text>
            <Text style={pdfStyles.td}>{MODALITY_LABEL[f.modality]}</Text>
          </View>
          <View style={pdfStyles.tr}>
            <Text style={pdfStyles.th}>Démarrage prévu</Text>
            <Text style={pdfStyles.td}>{fmtDatePdf(e.start_date)}</Text>
          </View>
          <View style={pdfStyles.trLast}>
            <Text style={pdfStyles.th}>Fin prévue</Text>
            <Text style={pdfStyles.td}>{fmtDatePdf(e.end_date)}</Text>
          </View>
        </View>

        <Text style={pdfStyles.sectionTitle}>Tarif</Text>
        <View style={pdfStyles.table}>
          <View style={pdfStyles.tr}>
            <Text style={pdfStyles.th}>Coût pédagogique net</Text>
            <Text style={pdfStyles.td}>{fmtEurosPdf(ht)}</Text>
          </View>
          <View style={pdfStyles.trLast}>
            <Text style={pdfStyles.th}>TVA</Text>
            <Text style={pdfStyles.td}>
              Exonération article 261-4-4° du CGI
            </Text>
          </View>
        </View>

        <View style={pdfStyles.totalRow}>
          <Text style={pdfStyles.totalLabel}>Total à régler</Text>
          <Text style={pdfStyles.totalValue}>{fmtEurosPdf(ht)}</Text>
        </View>

        <Text style={pdfStyles.sectionTitle}>Conditions</Text>
        <Text style={pdfStyles.smallP}>
          • Devis valable jusqu'au {validityDate}.{"\n"}
          • Pour valider votre inscription, retournez ce devis signé avec la
          mention « Bon pour accord » à {LEGAL.email}.{"\n"}
          • Une convention de formation sera ensuite émise (article L. 6353-2
          du Code du travail).{"\n"}
          • Délai de rétractation B2C de 14 jours après signature de la
          convention (formulaire sur {LEGAL.website}/retractation).
        </Text>

        <PdfFooter pageInfo="Devis — Page 1 / 1" />
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
  if (!user) {
    return NextResponse.json({ error: "unauth" }, { status: 401 });
  }

  const { data } = await supabase
    .from("enrollments")
    .select(
      "*, user:profiles!user_id(full_name, email, phone), funder:funders(name, kind)"
    )
    .eq("id", params.id)
    .maybeSingle();

  const enrollment = data as EnrollmentWithRelations | null;
  if (!enrollment) {
    return NextResponse.json({ error: "not_found" }, { status: 404 });
  }
  // Défense en profondeur : owner OU staff uniquement
  if (!(await canAccessEnrollment(user.id, enrollment.user_id))) {
    return NextResponse.json({ error: "forbidden" }, { status: 403 });
  }
  const stagiaire = enrollment.user;
  if (!stagiaire) {
    return NextResponse.json({ error: "stagiaire_missing" }, { status: 500 });
  }

  const ref = String(params.id).slice(0, 8).toUpperCase();
  const validity = new Date();
  validity.setDate(validity.getDate() + 30);
  const validityDate = new Intl.DateTimeFormat("fr-FR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  }).format(validity);

  const buffer = await renderToBuffer(
    <Doc
      refLabel={ref}
      stagiaire={{
        fullName: stagiaire.full_name ?? stagiaire.email,
        email: stagiaire.email,
        phone: stagiaire.phone,
      }}
      funder={enrollment.funder ?? null}
      e={enrollment}
      validityDate={validityDate}
    />
  );

  return new NextResponse(buffer as BodyInit, {
    status: 200,
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `inline; filename="devis-${ref}.pdf"`,
      "Cache-Control": "private, no-store",
    },
  });
}
