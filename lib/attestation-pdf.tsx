// PDF d'attestation d'acceptation des documents (preuve).
// Partagé entre la route stagiaire (/api/me/...) et la route admin.
import {
  Document,
  Page,
  Text,
  View,
  Image,
  renderToBuffer,
} from "@react-pdf/renderer";
import React from "react";
import { pdfStyles, PdfHeader, PdfFooter, PdfPartyOf } from "./pdf-shared";

export interface AttestationRow {
  title: string;
  version: number;
  acceptedAt: string;
  ip?: string | null;
}

export interface AttestationInput {
  refLabel: string;
  name: string;
  email: string;
  rows: AttestationRow[];
  /** Image PNG (data URL) de la signature de référence, si disponible. */
  signatureImage?: string | null;
}

function frDateTime(iso: string) {
  return new Intl.DateTimeFormat("fr-FR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  }).format(new Date(iso));
}

function Doc({ refLabel, name, email, rows, signatureImage }: AttestationInput) {
  return (
    <Document>
      <Page size="A4" style={pdfStyles.page}>
        <PdfHeader refLabel={refLabel} type="Attestation" />
        <Text style={pdfStyles.title}>Attestation d'acceptation</Text>
        <Text style={pdfStyles.subtitle}>
          Documents administratifs acceptés par signature électronique
        </Text>

        <Text style={pdfStyles.partyTitle}>Organisme de formation</Text>
        <PdfPartyOf />

        <Text style={pdfStyles.partyTitle}>Signataire</Text>
        <View style={pdfStyles.partyBlock}>
          <Text style={pdfStyles.party}>
            <Text style={{ fontWeight: "bold" }}>{name}</Text>
          </Text>
          <Text style={pdfStyles.party}>{email}</Text>
        </View>

        <Text style={pdfStyles.sectionTitle}>Documents acceptés</Text>
        <View style={pdfStyles.table}>
          <View style={pdfStyles.tr}>
            <Text style={[pdfStyles.th, { width: "55%" }]}>Document</Text>
            <Text style={[pdfStyles.th, { width: "15%" }]}>Version</Text>
            <Text style={[pdfStyles.th, { width: "30%" }]}>Accepté le</Text>
          </View>
          {rows.map((r, i) => (
            <View
              key={i}
              style={i === rows.length - 1 ? pdfStyles.trLast : pdfStyles.tr}
            >
              <Text style={[pdfStyles.td, { width: "55%" }]}>{r.title}</Text>
              <Text style={[pdfStyles.td, { width: "15%" }]}>v{r.version}</Text>
              <View style={[pdfStyles.td, { width: "30%" }]}>
                <Text style={{ fontSize: 9 }}>{frDateTime(r.acceptedAt)}</Text>
                {r.ip ? (
                  <Text style={{ fontSize: 7, color: "#94a3b8" }}>
                    IP {r.ip}
                  </Text>
                ) : null}
              </View>
            </View>
          ))}
        </View>

        <Text style={pdfStyles.sectionTitle}>Valeur de l'acceptation</Text>
        <Text style={pdfStyles.smallP}>
          Le signataire, identifié par son compte personnel, a consulté puis
          accepté chacun des documents ci-dessus. Chaque acceptation a été
          horodatée et enregistrée de manière immuable (signature électronique
          simple, au sens du règlement eIDAS).
        </Text>

        {signatureImage ? (
          <View style={{ marginTop: 14 }}>
            <Text style={{ fontSize: 9, color: "#0f172a", marginBottom: 4 }}>
              Signature du stagiaire :
            </Text>
            <Image
              src={signatureImage}
              style={{ width: 170, height: 64, objectFit: "contain" }}
            />
          </View>
        ) : null}

        <PdfFooter pageInfo="Attestation d'acceptation des documents" />
      </Page>
    </Document>
  );
}

export async function renderAttestationPdf(
  input: AttestationInput
): Promise<Buffer> {
  return renderToBuffer(<Doc {...input} />);
}
