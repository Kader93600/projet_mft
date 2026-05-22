// Attestation d'acceptation des documents administratifs signés par le stagiaire.
// Preuve récapitulative (PDF) : documents, versions, horodatage, signataire.
// Lit document_acceptances (lecture seule). Server-only (renderToBuffer = Node).
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
import { pdfStyles, PdfHeader, PdfFooter, PdfPartyOf } from "@/lib/pdf-shared";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

interface AccRow {
  title: string;
  version: number;
  acceptedAt: string;
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

function Doc({
  refLabel,
  name,
  email,
  rows,
}: {
  refLabel: string;
  name: string;
  email: string;
  rows: AccRow[];
}) {
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
              <Text style={[pdfStyles.td, { width: "15%" }]}>
                v{r.version}
              </Text>
              <Text style={[pdfStyles.td, { width: "30%", fontSize: 9 }]}>
                {frDateTime(r.acceptedAt)}
              </Text>
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
        <Text style={pdfStyles.smallP}>
          Ce récapitulatif est généré automatiquement à partir du registre des
          acceptations conservé par l'organisme de formation.
        </Text>

        <PdfFooter pageInfo="Attestation d'acceptation des documents" />
      </Page>
    </Document>
  );
}

export async function GET() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: "unauth" }, { status: 401 });
  }

  const [{ data: profile }, { data: acceptances }] = await Promise.all([
    supabase
      .from("profiles")
      .select("full_name, email")
      .eq("id", user.id)
      .maybeSingle(),
    supabase
      .from("document_acceptances")
      .select(
        "accepted_at, document_version, onboarding_documents(title)"
      )
      .eq("user_id", user.id)
      .order("accepted_at", { ascending: true }),
  ]);

  const rows: AccRow[] = (acceptances ?? []).map((a: any) => ({
    title: a.onboarding_documents?.title ?? "Document",
    version: a.document_version,
    acceptedAt: a.accepted_at,
  }));

  if (rows.length === 0) {
    return NextResponse.json({ error: "no_documents" }, { status: 404 });
  }

  const refLabel = `ATT-${String(user.id).replace(/-/g, "").slice(0, 8).toUpperCase()}`;
  const buffer = await renderToBuffer(
    <Doc
      refLabel={refLabel}
      name={profile?.full_name ?? profile?.email ?? "Stagiaire"}
      email={profile?.email ?? ""}
      rows={rows}
    />
  );

  return new NextResponse(buffer as any, {
    status: 200,
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `inline; filename="attestation-acceptation-${refLabel}.pdf"`,
      "Cache-Control": "private, no-store",
    },
  });
}
