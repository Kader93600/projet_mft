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
import { createClient } from "@/lib/supabase/server";
import { LEGAL } from "@/lib/legal-config";
import { resolveEnrollmentFormation } from "@/lib/enrollment-formation";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

const styles = StyleSheet.create({
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
  ref: {
    fontSize: 8,
    color: "#64748b",
    textAlign: "right",
  },
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
  table: {
    marginTop: 4,
    borderWidth: 0.5,
    borderColor: "#cbd5e1",
  },
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
  signRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    marginTop: 28,
  },
  signBox: {
    width: "47%",
    minHeight: 90,
    borderWidth: 0.5,
    borderColor: "#cbd5e1",
    padding: 8,
  },
  signLabel: {
    fontSize: 8,
    color: "#64748b",
    textTransform: "uppercase",
    letterSpacing: 0.5,
    marginBottom: 4,
  },
  signName: { fontSize: 9, color: "#0E1240", marginBottom: 16 },
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
  page2Title: {
    fontSize: 13,
    fontWeight: "bold",
    color: "#0E1240",
    marginBottom: 8,
  },
  smallP: {
    fontSize: 9,
    marginBottom: 5,
    color: "#0f172a",
    lineHeight: 1.45,
  },
});

function fmtEuros(cents: number) {
  return new Intl.NumberFormat("fr-FR", {
    style: "currency",
    currency: "EUR",
  }).format((cents ?? 0) / 100);
}

function fmtDate(iso: string | null | undefined) {
  if (!iso) return "—";
  return new Intl.DateTimeFormat("fr-FR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  }).format(new Date(iso));
}

const FUNDING_LABEL: Record<string, string> = {
  opco: "OPCO",
  cpf: "CPF / Mon Compte Formation",
  employeur: "Employeur",
  pole_emploi: "France Travail (Pôle Emploi)",
  auto: "Auto-financement",
  autre: "Autre",
};

const MODALITY_LABEL: Record<string, string> = {
  presentiel: "Présentiel",
  distanciel: "Formation à distance (FOAD)",
  mixte: "Mixte (présentiel + distanciel)",
};

interface DocProps {
  ref: string;
  stagiaire: {
    fullName: string;
    email: string;
    phone?: string | null;
    address?: string | null;
  };
  funder?: { name: string; kind: string } | null;
  e: any;
}

function Doc({ ref, stagiaire, funder, e }: DocProps) {
  const isB2B = e.funding_kind !== "auto" && e.funding_kind !== "cpf";
  const f = resolveEnrollmentFormation(e);

  return (
    <Document>
      {/* Page 1 — convention */}
      <Page size="A4" style={styles.page}>
        <View style={styles.header}>
          <View>
            <Text style={styles.brand}>{LEGAL.brand}</Text>
            <Text style={styles.brandSub}>
              Organisme de formation · {LEGAL.trainingActivityNumber}
            </Text>
          </View>
          <View>
            <Text style={styles.ref}>Convention n° {ref}</Text>
            <Text style={styles.ref}>Émise le {fmtDate(new Date().toISOString())}</Text>
          </View>
        </View>

        <Text style={styles.title}>Convention de formation professionnelle</Text>
        <Text style={styles.subtitle}>
          Articles L. 6353-1 et L. 6353-2 du Code du travail
        </Text>

        <Text style={styles.partyTitle}>Entre les soussignés</Text>
        <View style={styles.partyBlock}>
          <Text style={styles.party}>
            <Text style={{ fontWeight: "bold" }}>L'organisme de formation : </Text>
            {LEGAL.legalName}
          </Text>
          <Text style={styles.party}>
            {LEGAL.address.street} — {LEGAL.address.postalCode}{" "}
            {LEGAL.address.city}
          </Text>
          <Text style={styles.party}>
            SIRET {LEGAL.siret} · N° activité OF {LEGAL.trainingActivityNumber}
          </Text>
          <Text style={styles.party}>
            Représenté par {LEGAL.director}, ci-après désigné « l'Organisme ».
          </Text>
        </View>

        {isB2B && funder && (
          <View>
            <Text style={styles.partyTitle}>Et</Text>
            <View style={styles.partyBlock}>
              <Text style={styles.party}>
                <Text style={{ fontWeight: "bold" }}>Le financeur : </Text>
                {funder.name}
              </Text>
              <Text style={styles.party}>
                Type : {FUNDING_LABEL[funder.kind] ?? funder.kind}
              </Text>
              <Text style={styles.party}>Ci-après désigné « le Financeur ».</Text>
            </View>
          </View>
        )}

        <Text style={styles.partyTitle}>Et</Text>
        <View style={styles.partyBlock}>
          <Text style={styles.party}>
            <Text style={{ fontWeight: "bold" }}>Le stagiaire : </Text>
            {stagiaire.fullName}
          </Text>
          <Text style={styles.party}>{stagiaire.email}</Text>
          {stagiaire.phone && <Text style={styles.party}>{stagiaire.phone}</Text>}
          {stagiaire.address && <Text style={styles.party}>{stagiaire.address}</Text>}
          <Text style={styles.party}>Ci-après désigné « le Stagiaire ».</Text>
        </View>

        <Text style={styles.sectionTitle}>Article 1 — Objet</Text>
        <Text style={styles.p}>
          La présente convention a pour objet la formation préparant au titre
          professionnel{" "}
          {f.rncpCode ? (
            <>
              <Text style={{ fontWeight: "bold" }}>{f.rncpCode}</Text> — {f.title},
              inscrit au Répertoire National des Certifications Professionnelles
              (France Compétences).
            </>
          ) : (
            <>
              <Text style={{ fontWeight: "bold" }}>{f.title}</Text>{" "}
              ({f.code}).
            </>
          )}
        </Text>

        <Text style={styles.sectionTitle}>Article 2 — Caractéristiques de l'action</Text>
        <View style={styles.table}>
          <View style={styles.tr}>
            <Text style={styles.th}>Intitulé</Text>
            <Text style={styles.td}>{f.title}</Text>
          </View>
          <View style={styles.tr}>
            <Text style={styles.th}>Modalité</Text>
            <Text style={styles.td}>
              {MODALITY_LABEL[e.modality ?? "distanciel"]}
            </Text>
          </View>
          <View style={styles.tr}>
            <Text style={styles.th}>Lieu</Text>
            <Text style={styles.td}>
              {e.location ?? "À distance — plateforme " + LEGAL.brand}
            </Text>
          </View>
          <View style={styles.tr}>
            <Text style={styles.th}>Date de début</Text>
            <Text style={styles.td}>{fmtDate(e.start_date)}</Text>
          </View>
          <View style={styles.tr}>
            <Text style={styles.th}>Date de fin prévue</Text>
            <Text style={styles.td}>{fmtDate(e.end_date)}</Text>
          </View>
          <View style={styles.tr}>
            <Text style={styles.th}>Durée totale</Text>
            <Text style={styles.td}>
              {e.hours_total ? `${e.hours_total} heures` : "À préciser"}
            </Text>
          </View>
          <View style={styles.tr}>
            <Text style={styles.th}>Prérequis</Text>
            <Text style={styles.td}>
              {f.prerequisites}
            </Text>
          </View>
          <View style={styles.trLast}>
            <Text style={styles.th}>Objectifs</Text>
            <Text style={styles.td}>{f.objectives}</Text>
          </View>
        </View>

        <Text style={styles.sectionTitle}>Article 3 — Financement</Text>
        <View style={styles.table}>
          <View style={styles.tr}>
            <Text style={styles.th}>Mode de financement</Text>
            <Text style={styles.td}>{FUNDING_LABEL[e.funding_kind]}</Text>
          </View>
          <View style={styles.tr}>
            <Text style={styles.th}>Coût pédagogique</Text>
            <Text style={styles.td}>
              {fmtEuros(e.total_amount_cents)} (net de TVA, art. 261-4-4° CGI)
            </Text>
          </View>
          <View style={styles.trLast}>
            <Text style={styles.th}>Financeur</Text>
            <Text style={styles.td}>{funder?.name ?? "Stagiaire (auto-financement)"}</Text>
          </View>
        </View>

        <Text style={styles.sectionTitle}>Article 4 — Engagements</Text>
        <Text style={styles.p}>
          L'Organisme s'engage à dispenser la formation conformément au
          programme défini, à fournir les supports pédagogiques nécessaires, à
          assurer le suivi et l'évaluation des acquis, et à délivrer une
          attestation de fin de formation.
        </Text>
        <Text style={styles.p}>
          Le Stagiaire s'engage à suivre l'intégralité de la formation, à
          respecter le règlement intérieur de l'Organisme (disponible sur{" "}
          {LEGAL.website}/reglement-interieur) et à participer aux évaluations.
        </Text>

        <View style={styles.footer} fixed>
          <Text>
            {LEGAL.legalName} · {LEGAL.address.street}, {LEGAL.address.postalCode}{" "}
            {LEGAL.address.city} · SIRET {LEGAL.siret} · N° activité OF{" "}
            {LEGAL.trainingActivityNumber} — Page 1 / 2
          </Text>
        </View>
      </Page>

      {/* Page 2 — articles + signatures */}
      <Page size="A4" style={styles.page}>
        <Text style={styles.page2Title}>Articles complémentaires</Text>

        <Text style={styles.sectionTitle}>Article 5 — Droit de rétractation (B2C)</Text>
        <Text style={styles.smallP}>
          Conformément à l'article L. 221-18 du Code de la consommation, le
          Stagiaire personne physique agissant à des fins n'entrant pas dans le
          cadre de son activité professionnelle dispose d'un délai de 14 jours
          calendaires à compter de la signature pour se rétracter, sans
          motivation. Le formulaire est disponible sur {LEGAL.website}/retractation.
        </Text>

        <Text style={styles.sectionTitle}>Article 6 — Annulation et report</Text>
        <Text style={styles.smallP}>
          En cas d'annulation par le Stagiaire moins de 10 jours ouvrés avant
          le démarrage, 30 % du coût pédagogique restent dus. Au-delà du
          démarrage, l'intégralité reste due, sauf motif légitime
          (certificat médical, force majeure). L'Organisme peut reporter la
          session si le nombre de Stagiaires est insuffisant.
        </Text>

        <Text style={styles.sectionTitle}>Article 7 — Suivi et évaluation</Text>
        <Text style={styles.smallP}>
          L'exécution est tracée par les feuilles d'émargement (signature
          électronique pour les sessions synchrones, traces d'activité pour
          les sessions asynchrones). Les évaluations comprennent des quiz, un
          examen blanc et une évaluation finale. Une attestation est remise à
          l'issue.
        </Text>

        <Text style={styles.sectionTitle}>Article 8 — Données personnelles</Text>
        <Text style={styles.smallP}>
          Les données du Stagiaire sont traitées conformément au RGPD et à
          notre politique de confidentialité ({LEGAL.website}/confidentialite).
          Délégué à la protection des données : {LEGAL.dpoEmail}.
        </Text>

        <Text style={styles.sectionTitle}>Article 9 — Litiges</Text>
        <Text style={styles.smallP}>
          Tout litige fera l'objet d'une tentative de résolution amiable. Le
          consommateur peut saisir gratuitement le médiateur :{" "}
          {LEGAL.mediator.name}. À défaut, les tribunaux français sont
          compétents.
        </Text>

        <Text style={styles.sectionTitle}>Article 10 — Acceptation</Text>
        <Text style={styles.smallP}>
          La signature de la présente convention vaut acceptation pleine et
          entière par les parties. Fait en deux exemplaires originaux, un
          pour chacune des parties.
        </Text>

        <View style={styles.signRow}>
          <View style={styles.signBox}>
            <Text style={styles.signLabel}>L'organisme</Text>
            <Text style={styles.signName}>
              {LEGAL.director}, pour {LEGAL.legalName}
            </Text>
            <Text style={styles.signLabel}>Date et signature</Text>
          </View>
          <View style={styles.signBox}>
            <Text style={styles.signLabel}>Le stagiaire</Text>
            <Text style={styles.signName}>{stagiaire.fullName}</Text>
            <Text style={styles.signLabel}>
              Date, mention « Lu et approuvé » et signature
            </Text>
          </View>
        </View>

        {isB2B && funder && (
          <View style={[styles.signRow, { marginTop: 12 }]}>
            <View style={styles.signBox}>
              <Text style={styles.signLabel}>Le financeur</Text>
              <Text style={styles.signName}>{funder.name}</Text>
              <Text style={styles.signLabel}>Date, cachet et signature</Text>
            </View>
            <View style={[styles.signBox, { borderColor: "transparent" }]} />
          </View>
        )}

        <View style={styles.footer} fixed>
          <Text>
            {LEGAL.legalName} · Convention n° {ref} · Page 2 / 2
          </Text>
        </View>
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

  const { data: enrollment, error } = await supabase
    .from("enrollments")
    .select(
      "*, user:profiles!enrollments_user_id_fkey(full_name, email, phone, address), funder:funders(name, kind)"
    )
    .eq("id", params.id)
    .maybeSingle();

  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  if (!enrollment) return NextResponse.json({ error: "not_found" }, { status: 404 });

  const stagiaire = (enrollment as any).user;
  if (!stagiaire) {
    return NextResponse.json({ error: "stagiaire_missing" }, { status: 500 });
  }

  const ref = String(params.id).slice(0, 8).toUpperCase();
  const buffer = await renderToBuffer(
    <Doc
      ref={ref}
      stagiaire={{
        fullName: stagiaire.full_name ?? stagiaire.email,
        email: stagiaire.email,
        phone: stagiaire.phone,
        address: stagiaire.address,
      }}
      funder={(enrollment as any).funder ?? null}
      e={enrollment}
    />
  );

  return new NextResponse(buffer as any, {
    status: 200,
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `inline; filename="convention-${ref}.pdf"`,
      "Cache-Control": "private, no-store",
    },
  });
}
