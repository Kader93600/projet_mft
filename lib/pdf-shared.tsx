// Composants partagés pour les PDF (devis, convocation, convention).
import { StyleSheet, Text, View } from "@react-pdf/renderer";
import React from "react";
import { LEGAL } from "./legal-config";

export const pdfStyles = StyleSheet.create({
  page: {
    padding: 50,
    fontSize: 10,
    fontFamily: "Helvetica",
    color: "#0f172a",
    lineHeight: 1.5,
  },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-start",
    marginBottom: 24,
    borderBottomWidth: 2,
    borderBottomColor: "#0E1240",
    paddingBottom: 12,
  },
  brand: {
    fontSize: 18,
    fontWeight: "bold",
    color: "#0E1240",
    letterSpacing: 1.5,
  },
  brandSub: {
    fontSize: 8,
    color: "#64748b",
    textTransform: "uppercase",
    letterSpacing: 1,
    marginTop: 2,
  },
  ref: { fontSize: 8, color: "#64748b", textAlign: "right" },
  title: {
    fontSize: 16,
    fontWeight: "bold",
    color: "#0E1240",
    textAlign: "center",
    marginBottom: 4,
    textTransform: "uppercase",
    letterSpacing: 1.5,
  },
  subtitle: {
    fontSize: 9,
    color: "#64748b",
    textAlign: "center",
    marginBottom: 18,
    fontStyle: "italic",
  },
  block: { marginBottom: 14 },
  partyTitle: {
    fontSize: 9,
    fontWeight: "bold",
    color: "#609015",
    textTransform: "uppercase",
    letterSpacing: 1,
    marginTop: 14,
    marginBottom: 4,
  },
  partyBlock: {
    paddingLeft: 8,
    borderLeftWidth: 2,
    borderLeftColor: "#cbd5e1",
    marginBottom: 8,
  },
  party: { fontSize: 10, color: "#0E1240", marginBottom: 1 },
  sectionTitle: {
    fontSize: 11,
    fontWeight: "bold",
    color: "#0E1240",
    marginTop: 12,
    marginBottom: 4,
  },
  p: { marginBottom: 4 },
  table: { marginTop: 4, borderWidth: 0.5, borderColor: "#cbd5e1" },
  tr: {
    flexDirection: "row",
    borderBottomWidth: 0.5,
    borderBottomColor: "#e2e8f0",
  },
  trLast: { flexDirection: "row" },
  th: {
    backgroundColor: "#f8fafc",
    fontSize: 8,
    color: "#64748b",
    padding: 5,
    width: "35%",
    textTransform: "uppercase",
    letterSpacing: 0.5,
  },
  td: { fontSize: 10, padding: 5, width: "65%", color: "#0E1240" },
  totalRow: {
    flexDirection: "row",
    justifyContent: "flex-end",
    marginTop: 8,
    paddingTop: 8,
    borderTopWidth: 1,
    borderTopColor: "#0E1240",
  },
  totalLabel: { fontSize: 11, color: "#64748b", marginRight: 12 },
  totalValue: { fontSize: 14, fontWeight: "bold", color: "#0E1240" },
  footer: {
    position: "absolute",
    bottom: 24,
    left: 50,
    right: 50,
    fontSize: 7,
    color: "#94a3b8",
    borderTopWidth: 0.5,
    borderTopColor: "#cbd5e1",
    paddingTop: 4,
    textAlign: "center",
  },
  smallP: {
    fontSize: 9,
    marginBottom: 5,
    color: "#0f172a",
    lineHeight: 1.45,
  },
});

export function PdfHeader({ ref, type }: { ref: string; type: string }) {
  const today = new Intl.DateTimeFormat("fr-FR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  }).format(new Date());
  return (
    <View style={pdfStyles.header}>
      <View>
        <Text style={pdfStyles.brand}>{LEGAL.brand}</Text>
        <Text style={pdfStyles.brandSub}>
          Organisme de formation · {LEGAL.trainingActivityNumber}
        </Text>
      </View>
      <View>
        <Text style={pdfStyles.ref}>
          {type} n° {ref}
        </Text>
        <Text style={pdfStyles.ref}>Émis le {today}</Text>
      </View>
    </View>
  );
}

export function PdfFooter({ pageInfo }: { pageInfo: string }) {
  return (
    <View style={pdfStyles.footer} fixed>
      <Text>
        {LEGAL.legalName} · SIRET {LEGAL.siret} · N° activité OF{" "}
        {LEGAL.trainingActivityNumber} — {pageInfo}
      </Text>
    </View>
  );
}

export function PdfPartyOf() {
  return (
    <View style={pdfStyles.partyBlock}>
      <Text style={pdfStyles.party}>
        <Text style={{ fontWeight: "bold" }}>L'organisme : </Text>
        {LEGAL.legalName}
      </Text>
      <Text style={pdfStyles.party}>
        {LEGAL.address.street} — {LEGAL.address.postalCode}{" "}
        {LEGAL.address.city}
      </Text>
      <Text style={pdfStyles.party}>
        SIRET {LEGAL.siret} · N° activité OF {LEGAL.trainingActivityNumber}
      </Text>
      <Text style={pdfStyles.party}>{LEGAL.email}</Text>
    </View>
  );
}

export function fmtEurosPdf(cents: number) {
  return new Intl.NumberFormat("fr-FR", {
    style: "currency",
    currency: "EUR",
  }).format((cents ?? 0) / 100);
}

export function fmtDatePdf(iso: string | null | undefined) {
  if (!iso) return "—";
  return new Intl.DateTimeFormat("fr-FR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  }).format(new Date(iso));
}
