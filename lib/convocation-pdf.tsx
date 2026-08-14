// =====================================================================
// Templates PDF des convocations (candidat + jury) — 3 modèles :
//   classique : institutionnel, centré, sobre (esprit attestation)
//   moderne   : encadrés, hiérarchie forte (design validé client)
//   compact   : l'essentiel sur une page dense
// Rendu serveur uniquement (@react-pdf/renderer), pattern identique aux
// exports de app/admin/reports/export/*.
// =====================================================================

import React from "react";
import {
  Document, Page, Text, View, StyleSheet, renderToBuffer,
} from "@react-pdf/renderer";
import { PdfLogoMark } from "@/lib/pdf-logo";
import {
  resolveConvocation, formatDateFr, sessionText, civiliteLongue,
  type ConvocationPayload, type ConvocationTemplate, type ResolvedConvocation,
} from "@/lib/convocations";

const NAVY = "#0E1240";
const BRAND = "#2530D9";
const LIME = "#9FE220";
const LIME_DARK = "#5a7f12";
const INK = "#0f172a";
const SOFT = "#64748b";
const FAINT = "#94a3b8";
const LINE = "#e2e8f0";
const IVORY = "#FAF9F5";

/* ── Contenu commun résolu depuis le payload ────────────────────────── */

/* ── Styles partagés ────────────────────────────────────────────────── */

const s = StyleSheet.create({
  // paddingBottom > pied de page fixe (bottom 22 + ~28 de hauteur) pour
  // que le contenu qui déborde ne chevauche jamais le footer.
  page: { paddingTop: 46, paddingHorizontal: 46, paddingBottom: 56, fontSize: 10, fontFamily: "Helvetica", color: INK, lineHeight: 1.5 },
  topBar: { position: "absolute", top: 0, left: 0, right: 0, height: 7, backgroundColor: LIME },
  brandRow: { flexDirection: "row", alignItems: "center", gap: 10, marginBottom: 4 },
  brandName: { fontSize: 13, fontFamily: "Helvetica-Bold", color: NAVY, letterSpacing: 0.4 },
  brandGreen: { color: LIME_DARK },
  brandSub: { fontSize: 7.5, color: SOFT, marginTop: 2 },
  label: { fontSize: 6.8, fontFamily: "Helvetica-Bold", color: FAINT, letterSpacing: 1.4, marginBottom: 3, textTransform: "uppercase" },
  footer: {
    position: "absolute", bottom: 22, left: 46, right: 46,
    borderTopWidth: 1, borderTopColor: LINE, paddingTop: 7,
    flexDirection: "row", justifyContent: "space-between",
    fontSize: 7.2, color: FAINT,
  },
  signBlock: { width: 190, marginTop: 6 },
  signFonction: { fontSize: 9, color: SOFT },
  signNom: { fontSize: 10.5, fontFamily: "Helvetica-Bold", color: NAVY, marginTop: 1 },
  signZone: { height: 40, borderWidth: 1, borderColor: LINE, borderStyle: "dashed", borderRadius: 5, marginTop: 6, backgroundColor: "#FCFCFE" },
  signCap: { fontSize: 6.6, color: FAINT, marginTop: 3, textAlign: "center", letterSpacing: 0.8 },
  puce: { width: 4, height: 4, borderRadius: 2, backgroundColor: LIME_DARK, marginTop: 4.5, marginRight: 6 },
  consigneRow: { flexDirection: "row", marginBottom: 3.5 },
  consigneDetail: { color: SOFT, fontSize: 9 },
});

function Brand({ sub }: { sub?: string }) {
  return (
    <View style={s.brandRow}>
      <PdfLogoMark size={34} />
      <View>
        <Text style={s.brandName}>
          MA FORMATION <Text style={s.brandGreen}>TRANSPORT</Text>
        </Text>
        <Text style={s.brandSub}>{sub ?? "Centre de formation aux métiers du transport et de la logistique"}</Text>
      </View>
    </View>
  );
}

function Footer({ p }: { p: ConvocationPayload }) {
  return (
    <View style={s.footer} fixed>
      <Text>
        MA FORMATION TRANSPORT · {p.lieu.adresse || "39 avenue des Sablons Bouillants"}, {p.lieu.code_postal || "77100"} {p.lieu.ville || "MEAUX"} · {p.contact.telephone} · {p.contact.email}
      </Text>
      <Text>Réf. {p.reference}</Text>
    </View>
  );
}

function Consignes({ items, compact }: { items: ResolvedConvocation["consignes"]; compact?: boolean }) {
  return (
    <View>
      {items.map((c, i) => (
        <View key={i} style={[s.consigneRow, compact ? { marginBottom: 2 } : {}]}>
          <View style={s.puce} />
          <Text style={{ flex: 1 }}>
            {c.label}
            {c.detail ? <Text style={s.consigneDetail}>  ({c.detail})</Text> : null}
          </Text>
        </View>
      ))}
    </View>
  );
}

function Signature({ p }: { p: ConvocationPayload }) {
  return (
    <View style={{ flexDirection: "row", justifyContent: "flex-end" }} wrap={false}>
      <View style={s.signBlock}>
        <Text style={s.signFonction}>{p.signataire.fonction}</Text>
        <Text style={s.signNom}>{p.signataire.nom || " "}</Text>
        <View style={s.signZone} />
        <Text style={s.signCap}>SIGNATURE ET CACHET DU CENTRE</Text>
      </View>
    </View>
  );
}

/* ── Modèle MODERNE (design validé) ─────────────────────────────────── */

const m = StyleSheet.create({
  rule: { flexDirection: "row", height: 2.5, borderRadius: 2, marginTop: 8, marginBottom: 10, overflow: "hidden" },
  destBox: { width: 210, padding: 10, backgroundColor: IVORY, borderWidth: 1, borderColor: LINE, borderRadius: 6, marginLeft: "auto" },
  objetRow: { flexDirection: "row", gap: 8, marginTop: 10, marginBottom: 9 },
  objetBar: { width: 3, backgroundColor: LIME, borderRadius: 2 },
  objetTitre: { fontSize: 12.5, fontFamily: "Helvetica-Bold", color: NAVY, lineHeight: 1.3 },
  objetRef: { fontSize: 7.4, color: FAINT, marginTop: 3 },
  grid: { borderWidth: 1, borderColor: LINE, borderRadius: 7, overflow: "hidden", marginVertical: 9 },
  gridHead: {
    backgroundColor: NAVY, paddingVertical: 5, paddingHorizontal: 11,
    flexDirection: "row", justifyContent: "space-between",
  },
  gridHeadTxt: { fontSize: 6.8, fontFamily: "Helvetica-Bold", color: "#fff", letterSpacing: 1.4 },
  gridHeadTag: { fontSize: 6.8, fontFamily: "Helvetica-Bold", color: LIME, letterSpacing: 1.4 },
  gridRow: { flexDirection: "row" },
  gridCell: { flex: 1, padding: 10, borderRightWidth: 1, borderRightColor: LINE },
  gridCellLast: { borderRightWidth: 0 },
  gridStrong: { fontFamily: "Helvetica-Bold", color: NAVY, fontSize: 10.2, marginBottom: 1 },
});

function TemplateModerne({ p }: { p: ConvocationPayload }) {
  const r = resolveConvocation(p);
  return (
    <Page size="A4" style={s.page}>
      <View style={s.topBar} fixed />
      <Brand />
      <View style={m.rule}>
        <View style={{ width: 58, backgroundColor: NAVY }} />
        <View style={{ width: 24, backgroundColor: LIME }} />
        <View style={{ flex: 1, backgroundColor: LINE }} />
      </View>

      <View style={{ flexDirection: "row" }}>
        <View style={{ flex: 1 }}>
          <Text style={s.label}>Centre organisateur</Text>
          <Text style={{ fontFamily: "Helvetica-Bold", color: NAVY }}>MA FORMATION TRANSPORT</Text>
          <Text style={{ color: SOFT }}>{p.lieu.adresse}</Text>
          <Text style={{ color: SOFT }}>{p.lieu.code_postal} {p.lieu.ville}</Text>
          <Text style={{ color: SOFT, marginTop: 3 }}>Tél. {p.contact.telephone}</Text>
          <Text style={{ color: SOFT }}>{p.contact.email}</Text>
        </View>
        <View style={m.destBox}>
          <Text style={s.label}>Destinataire</Text>
          {r.destinataireLignes.map((l, i) => (
            <Text key={i} style={i === 0 ? { fontFamily: "Helvetica-Bold", color: NAVY } : { color: SOFT }}>{l}</Text>
          ))}
        </View>
      </View>

      <View style={m.objetRow}>
        <View style={m.objetBar} />
        <View style={{ flex: 1 }}>
          <Text style={s.label}>Objet</Text>
          <Text style={m.objetTitre}>
            {r.titreDoc} · {r.sousTitre}
          </Text>
          <Text style={{ fontSize: 10, color: INK, marginTop: 2 }}>
            {p.epreuve.type}{p.epreuve.intitule ? ` : ${p.epreuve.intitule}` : ""}
          </Text>
          <Text style={m.objetRef}>
            {p.formation.titre}{p.formation.certification ? ` · ${p.formation.certification}` : ""}
            {p.session.label ? ` · ${sessionText(p.session.label)}` : ""} · Réf. {p.reference}
          </Text>
        </View>
      </View>

      <Text style={{ marginBottom: 6 }}>
        {civiliteLongue(p.destinataire.civilite)},
      </Text>
      <Text style={{ marginBottom: 6 }}>
        {p.kind === "jury"
          ? `Vous avez accepté d'être désigné en tant que ${p.destinataire.role_jury?.toLowerCase() || "membre de jury"} pour la session d'examen visant l'obtention du titre professionnel ${p.formation.titre}. Nous vous remercions de bien vouloir vous présenter aux date, heure et lieu indiqués ci-dessous.`
          : `Dans le cadre de votre parcours ${p.formation.titre}, vous êtes convoqué à l'épreuve mentionnée ci-dessous. Nous vous remercions de bien vouloir vous présenter aux date, heure et lieu indiqués, muni des documents demandés.`}
      </Text>

      <View style={m.grid} wrap={false}>
        <View style={m.gridHead}>
          <Text style={m.gridHeadTxt}>INFORMATIONS PRATIQUES</Text>
          <Text style={m.gridHeadTag}>À CONSERVER</Text>
        </View>
        <View style={m.gridRow}>
          {r.infosGrid.map((cell, i) => (
            <View key={cell.label} style={[m.gridCell, i === r.infosGrid.length - 1 ? m.gridCellLast : {}]}>
              <Text style={s.label}>{cell.label}</Text>
              {cell.lines.map((l, j) => (
                <Text key={j} style={j === 0 ? m.gridStrong : { color: INK, fontSize: 9.4 }}>{l}</Text>
              ))}
            </View>
          ))}
        </View>
      </View>

      {r.consignes.length > 0 && (
        <View wrap={false} style={{ marginBottom: 6 }}>
          <Text style={[s.label, { marginBottom: 5 }]}>
            {p.kind === "jury" ? "Informations et documents" : "Consignes à respecter"}
          </Text>
          <Consignes items={r.consignes} />
        </View>
      )}

      {p.remarques ? (
        <View style={{ backgroundColor: IVORY, borderWidth: 1, borderColor: LINE, borderRadius: 6, padding: 9, marginBottom: 8 }} wrap={false}>
          <Text style={s.label}>Remarques</Text>
          <Text>{p.remarques}</Text>
        </View>
      ) : null}

      <Text style={{ marginTop: 2 }}>
        Nous vous prions d'agréer, {civiliteLongue(p.destinataire.civilite)}, l'expression de notre considération distinguée.
      </Text>

      <Signature p={p} />
      <Footer p={p} />
    </Page>
  );
}

/* ── Modèle CLASSIQUE (institutionnel centré) ───────────────────────── */

const k = StyleSheet.create({
  title: {
    fontSize: 21, fontFamily: "Helvetica-Bold", color: NAVY, textAlign: "center",
    letterSpacing: 3, marginTop: 14, marginBottom: 4,
  },
  underline: { width: 76, height: 2, backgroundColor: LIME, alignSelf: "center", marginBottom: 6 },
  subT: { fontSize: 10.5, color: SOFT, textAlign: "center", marginBottom: 12 },
  table: { borderWidth: 1, borderColor: LINE, marginVertical: 9 },
  tr: { flexDirection: "row", borderBottomWidth: 1, borderBottomColor: LINE },
  th: {
    width: 130, paddingHorizontal: 8, paddingVertical: 5.5, backgroundColor: IVORY, fontSize: 7.2,
    fontFamily: "Helvetica-Bold", color: SOFT, letterSpacing: 1, textTransform: "uppercase",
  },
  td: { flex: 1, paddingHorizontal: 8, paddingVertical: 5.5 },
});

function TemplateClassique({ p }: { p: ConvocationPayload }) {
  const r = resolveConvocation(p);
  const allRows: Array<[string, string[]]> = [
    ["Destinataire", r.destinataireLignes],
    ["Formation", [p.formation.titre, p.formation.certification ?? "", p.formation.bloc ?? ""].filter(Boolean)],
    ["Session", [p.session.label, p.session.groupe ? `Groupe : ${p.session.groupe}` : ""].filter(Boolean)],
    ["Épreuve", [`${p.epreuve.type}${p.epreuve.intitule ? ` : ${p.epreuve.intitule}` : ""}`]],
    ...r.infosGrid.map((c) => [c.label, c.lines] as [string, string[]]),
  ];
  const rows = allRows.filter(([, lines]) => lines.length > 0);

  return (
    <Page size="A4" style={s.page}>
      <View style={s.topBar} fixed />
      <View style={{ alignItems: "center", marginTop: 4 }}>
        <PdfLogoMark size={44} />
        <Text style={{ fontSize: 15, fontFamily: "Helvetica-Bold", color: NAVY, marginTop: 6, letterSpacing: 0.6 }}>
          MA FORMATION <Text style={{ color: LIME_DARK }}>TRANSPORT</Text>
        </Text>
        <Text style={{ fontSize: 8, color: SOFT, marginTop: 2 }}>
          Centre de formation aux métiers du transport et de la logistique
        </Text>
      </View>

      <Text style={k.title}>{r.titreDoc}</Text>
      <View style={k.underline} />
      <Text style={k.subT}>{r.sousTitre} · Réf. {p.reference}</Text>

      <View style={k.table}>
        {rows.map(([label, lines], i) => (
          <View key={label + i} style={[k.tr, i === rows.length - 1 ? { borderBottomWidth: 0 } : {}]}>
            <Text style={k.th}>{label}</Text>
            <View style={k.td}>
              {lines.map((l, j) => (
                <Text key={j} style={j === 0 ? { fontFamily: "Helvetica-Bold", color: NAVY } : { color: INK }}>{l}</Text>
              ))}
            </View>
          </View>
        ))}
      </View>

      {r.consignes.length > 0 && (
        <View wrap={false} style={{ marginBottom: 6 }}>
          <Text style={[s.label, { marginBottom: 5 }]}>
            {p.kind === "jury" ? "Informations et documents" : "Consignes à respecter"}
          </Text>
          <Consignes items={r.consignes} />
        </View>
      )}

      {p.remarques ? <Text style={{ marginBottom: 8, color: INK }}>Remarques : {p.remarques}</Text> : null}

      <Text>
        La présente convocation est à conserver et à présenter le jour de l'épreuve.
      </Text>

      <Signature p={p} />
      <Footer p={p} />
    </Page>
  );
}

/* ── Modèle COMPACT (une page essentielle) ──────────────────────────── */

function TemplateCompact({ p }: { p: ConvocationPayload }) {
  const r = resolveConvocation(p);
  return (
    <Page size="A4" style={[s.page, { fontSize: 9.4 }]}>
      <View style={s.topBar} fixed />
      <View style={{ flexDirection: "row", justifyContent: "space-between", alignItems: "center" }}>
        <Brand sub={`${r.titreDoc} · ${r.sousTitre}`} />
        <View style={{ alignItems: "flex-end" }}>
          <Text style={{ fontSize: 7.2, color: FAINT }}>Réf. {p.reference}</Text>
          <Text style={{ fontSize: 7.2, color: FAINT }}>{formatDateFr(p.horaires.date)}</Text>
        </View>
      </View>
      <View style={{ height: 1.5, backgroundColor: NAVY, marginTop: 8, marginBottom: 12 }} />

      <View style={{ flexDirection: "row", gap: 14 }}>
        <View style={{ flex: 1.15 }}>
          <Text style={s.label}>Destinataire</Text>
          {r.destinataireLignes.map((l, i) => (
            <Text key={i} style={i === 0 ? { fontFamily: "Helvetica-Bold", color: NAVY, fontSize: 10.5 } : { color: SOFT }}>{l}</Text>
          ))}
          <Text style={[s.label, { marginTop: 9 }]}>Formation</Text>
          <Text style={{ color: INK }}>{p.formation.titre}</Text>
          {p.session.label ? <Text style={{ color: SOFT }}>{sessionText(p.session.label)}</Text> : null}
          <Text style={[s.label, { marginTop: 9 }]}>Épreuve</Text>
          <Text style={{ color: INK }}>
            {p.epreuve.type}{p.epreuve.intitule ? ` : ${p.epreuve.intitule}` : ""}
          </Text>
        </View>
        <View style={{ flex: 1, backgroundColor: IVORY, borderWidth: 1, borderColor: LINE, borderRadius: 7, padding: 11 }}>
          {r.infosGrid.map((cell) => (
            <View key={cell.label} style={{ marginBottom: 8 }}>
              <Text style={s.label}>{cell.label}</Text>
              {cell.lines.map((l, j) => (
                <Text key={j} style={j === 0 ? { fontFamily: "Helvetica-Bold", color: NAVY } : { color: INK, fontSize: 9 }}>{l}</Text>
              ))}
            </View>
          ))}
        </View>
      </View>

      {r.consignes.length > 0 && (
        <View style={{ marginTop: 12 }} wrap={false}>
          <Text style={[s.label, { marginBottom: 4 }]}>Consignes</Text>
          <Consignes items={r.consignes} compact />
        </View>
      )}
      {p.remarques ? (
        <Text style={{ marginTop: 6, color: SOFT }}>Remarques : {p.remarques}</Text>
      ) : null}

      <Signature p={p} />
      <Footer p={p} />
    </Page>
  );
}

/* ── Rendu ──────────────────────────────────────────────────────────── */

function pageFor(p: ConvocationPayload, template: ConvocationTemplate, key?: string) {
  if (template === "classique") return <TemplateClassique p={p} key={key} />;
  if (template === "compact") return <TemplateCompact p={p} key={key} />;
  return <TemplateModerne p={p} key={key} />;
}

/** PDF d'une convocation. */
export async function renderConvocationPdf(
  payload: ConvocationPayload,
  template: ConvocationTemplate,
): Promise<Buffer> {
  return renderToBuffer(
    <Document title={`Convocation ${payload.reference}`} author="MA FORMATION TRANSPORT">
      {pageFor(payload, template)}
    </Document>,
  );
}

/** PDF unique contenant plusieurs convocations (génération en masse). */
export async function renderConvocationsPdf(
  items: Array<{ payload: ConvocationPayload; template: ConvocationTemplate }>,
): Promise<Buffer> {
  return renderToBuffer(
    <Document title="Convocations" author="MA FORMATION TRANSPORT">
      {items.map((it, i) => pageFor(it.payload, it.template, it.payload.reference + i))}
    </Document>,
  );
}
