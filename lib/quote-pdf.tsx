// Génération du PDF de devis (réutilise les composants partagés pdf-shared).
// Server-only (renderToBuffer = Node). Appelé par l'action CRM sendQuote.
import {
  Document,
  Page,
  Text,
  View,
  renderToBuffer,
} from "@react-pdf/renderer";
import React from "react";
import { pdfStyles, PdfHeader, PdfFooter, PdfPartyOf } from "./pdf-shared";

export interface QuoteData {
  ref: string;
  client: { fullName: string; email: string; phone?: string | null };
  formationTitle: string;
  durationLabel: string;
  modalityLabel: string;
  fundingLabel: string;
  hours?: string | null;
  startDate?: string | null; // ISO
  amountEuros: number; // net de TVA
  validityDays: number;
  notes?: string | null;
}

function eur(n: number) {
  return new Intl.NumberFormat("fr-FR", {
    style: "currency",
    currency: "EUR",
  })
    .format(Number.isFinite(n) ? n : 0)
    // Helvetica ne rend pas les espaces insécables (U+202F/U+00A0) →
    // "4 000 €" s'affichait "4/000 €".
    .replace(/\s/g, " ");
}

function frDate(iso?: string | null) {
  if (!iso) return "—";
  return new Intl.DateTimeFormat("fr-FR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  }).format(new Date(iso));
}

function QuoteDoc({ data }: { data: QuoteData }) {
  const validUntil = new Date();
  validUntil.setDate(validUntil.getDate() + (data.validityDays || 30));

  const rows: Array<[string, string]> = [["Formation", data.formationTitle]];
  if (data.durationLabel) rows.push(["Durée", data.durationLabel]);
  if (data.hours) rows.push(["Volume horaire", data.hours]);
  if (data.modalityLabel) rows.push(["Modalité", data.modalityLabel]);
  if (data.fundingLabel) rows.push(["Financement envisagé", data.fundingLabel]);
  rows.push(["Début prévu", frDate(data.startDate)]);

  return (
    <Document>
      <Page size="A4" style={pdfStyles.page}>
        <PdfHeader refLabel={data.ref} type="Devis" />
        <Text style={pdfStyles.title}>Devis de formation</Text>
        <Text style={pdfStyles.subtitle}>
          Valable jusqu'au {frDate(validUntil.toISOString())} ·{" "}
          {data.validityDays || 30} jours
        </Text>

        <Text style={pdfStyles.partyTitle}>Organisme de formation</Text>
        <PdfPartyOf />

        <Text style={pdfStyles.partyTitle}>Bénéficiaire</Text>
        <View style={pdfStyles.partyBlock}>
          <Text style={pdfStyles.party}>
            <Text style={{ fontWeight: "bold" }}>{data.client.fullName}</Text>
          </Text>
          <Text style={pdfStyles.party}>{data.client.email}</Text>
          {data.client.phone ? (
            <Text style={pdfStyles.party}>{data.client.phone}</Text>
          ) : null}
        </View>

        <Text style={pdfStyles.sectionTitle}>Détail de la prestation</Text>
        <View style={pdfStyles.table}>
          {rows.map(([k, v], i) => (
            <View
              key={k}
              style={i === rows.length - 1 ? pdfStyles.trLast : pdfStyles.tr}
            >
              <Text style={pdfStyles.th}>{k}</Text>
              <Text style={pdfStyles.td}>{v}</Text>
            </View>
          ))}
        </View>

        <View style={pdfStyles.totalRow}>
          <Text style={pdfStyles.totalLabel}>Total net de TVA</Text>
          <Text style={pdfStyles.totalValue}>{eur(data.amountEuros)}</Text>
        </View>
        <Text
          style={{
            fontSize: 8,
            color: "#64748b",
            textAlign: "right",
            marginTop: 2,
          }}
        >
          TVA non applicable, art. 261-4-4°-a du CGI (organisme de formation).
        </Text>

        <Text style={pdfStyles.sectionTitle}>Conditions</Text>
        <Text style={pdfStyles.smallP}>
          • Devis valable {data.validityDays || 30} jours à compter de sa date
          d'émission.
        </Text>
        <Text style={pdfStyles.smallP}>
          • Prestation susceptible d'une prise en charge (CPF, OPCO, France
          Travail, employeur) selon votre situation.
        </Text>
        <Text style={pdfStyles.smallP}>
          • L'inscription est confirmée à réception de la convention de
          formation signée.
        </Text>
        {data.notes ? (
          <Text style={pdfStyles.sectionTitle}>Précisions</Text>
        ) : null}
        {data.notes ? (
          <Text style={pdfStyles.smallP}>{data.notes}</Text>
        ) : null}

        <Text style={{ fontSize: 9, marginTop: 16, color: "#0f172a" }}>
          Bon pour accord (date, signature et mention « lu et approuvé ») :
        </Text>
        <View
          style={{
            height: 52,
            borderWidth: 0.5,
            borderColor: "#cbd5e1",
            borderRadius: 4,
            marginTop: 6,
            width: "55%",
          }}
        />

        <PdfFooter pageInfo="Devis — sans valeur de facture" />
      </Page>
    </Document>
  );
}

export async function renderQuotePdf(data: QuoteData): Promise<Buffer> {
  return renderToBuffer(<QuoteDoc data={data} />);
}
