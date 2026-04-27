import { NextResponse } from "next/server";
import {
  Document,
  Page,
  Text,
  View,
  StyleSheet,
  renderToBuffer,
} from "@react-pdf/renderer";
import React from "react";
import { LEGAL } from "@/lib/legal-config";

export const runtime = "nodejs";
export const dynamic = "force-static";

const styles = StyleSheet.create({
  page: {
    padding: 50,
    fontSize: 11,
    fontFamily: "Helvetica",
    color: "#0f172a",
    lineHeight: 1.5,
  },
  title: {
    fontSize: 18,
    fontWeight: "bold",
    color: "#0E1240",
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 9,
    color: "#64748b",
    marginBottom: 24,
    textTransform: "uppercase",
    letterSpacing: 1.5,
  },
  block: { marginBottom: 14 },
  label: {
    fontSize: 9,
    color: "#64748b",
    textTransform: "uppercase",
    letterSpacing: 1,
    marginBottom: 2,
  },
  value: { fontSize: 11, color: "#0E1240" },
  underline: {
    borderBottomWidth: 0.6,
    borderBottomColor: "#0E1240",
    marginTop: 18,
    marginBottom: 4,
    height: 14,
  },
  footer: {
    position: "absolute",
    bottom: 30,
    left: 50,
    right: 50,
    fontSize: 8,
    color: "#64748b",
    borderTopWidth: 0.5,
    borderTopColor: "#cbd5e1",
    paddingTop: 6,
  },
  notice: {
    fontSize: 9,
    color: "#64748b",
    fontStyle: "italic",
    marginTop: 6,
  },
});

function Doc() {
  return (
    <Document>
      <Page size="A4" style={styles.page}>
        <Text style={styles.title}>Formulaire de rétractation</Text>
        <Text style={styles.subtitle}>
          Article L. 221-18 du Code de la consommation
        </Text>

        <View style={styles.block}>
          <Text style={styles.label}>À l'attention de</Text>
          <Text style={styles.value}>{LEGAL.legalName}</Text>
          <Text style={styles.value}>{LEGAL.address.street}</Text>
          <Text style={styles.value}>
            {LEGAL.address.postalCode} {LEGAL.address.city}
          </Text>
          <Text style={styles.value}>{LEGAL.email}</Text>
        </View>

        <View style={styles.block}>
          <Text style={styles.value}>
            Je soussigné(e) notifie par la présente ma rétractation du contrat
            portant sur la prestation de service de formation suivante :
          </Text>
        </View>

        <View style={styles.block}>
          <Text style={styles.label}>Action de formation</Text>
          <View style={styles.underline} />
        </View>
        <View style={styles.block}>
          <Text style={styles.label}>Numéro de dossier (si connu)</Text>
          <View style={styles.underline} />
        </View>
        <View style={styles.block}>
          <Text style={styles.label}>Commandée le</Text>
          <View style={styles.underline} />
        </View>
        <View style={styles.block}>
          <Text style={styles.label}>Convention signée le</Text>
          <View style={styles.underline} />
        </View>
        <View style={styles.block}>
          <Text style={styles.label}>Nom du / des stagiaire(s)</Text>
          <View style={styles.underline} />
        </View>
        <View style={styles.block}>
          <Text style={styles.label}>Adresse complète</Text>
          <View style={styles.underline} />
          <View style={styles.underline} />
        </View>
        <View style={styles.block}>
          <Text style={styles.label}>Date de la présente</Text>
          <View style={styles.underline} />
        </View>
        <View style={styles.block}>
          <Text style={styles.label}>Signature</Text>
          <View style={[styles.underline, { height: 50 }]} />
        </View>

        <Text style={styles.notice}>
          Délai de 14 jours calendaires à compter du lendemain de la signature
          du contrat. À renvoyer par email ou par courrier à l'adresse
          ci-dessus. Pour respecter le délai, il suffit que votre communication
          soit envoyée avant l'expiration de la période de 14 jours.
        </Text>

        <View style={styles.footer} fixed>
          <Text>
            {LEGAL.legalName} — SIRET {LEGAL.siret} — Numéro d'activité OF :{" "}
            {LEGAL.trainingActivityNumber}
          </Text>
        </View>
      </Page>
    </Document>
  );
}

export async function GET() {
  const buffer = await renderToBuffer(<Doc />);
  return new NextResponse(buffer as any, {
    status: 200,
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": 'inline; filename="formulaire-retractation.pdf"',
      "Cache-Control": "public, max-age=86400",
    },
  });
}
