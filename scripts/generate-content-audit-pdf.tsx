// =====================================================================
// Génère un PDF "État des lieux pédagogique" pour le client.
// Récap : leçons, QCM, QR, quiz, examens blancs par formation.
// Usage : npx tsx scripts/generate-content-audit-pdf.tsx
// Output : scripts/output/etat-des-lieux-pedagogique.pdf
// =====================================================================

import React from "react";
import {
  Document,
  Page,
  Text,
  View,
  StyleSheet,
  renderToFile,
} from "@react-pdf/renderer";
import { mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const OUTPUT = resolve(__dirname, "output", "etat-des-lieux-pedagogique.pdf");
mkdirSync(dirname(OUTPUT), { recursive: true });

// ---------- Couleurs (alignées DESIGN.md) ----------
const NAVY = "#0E1240";
const NAVY_LIGHT = "#1f2547";
const BRAND = "#2530D9";
const SIGNAL = "#9FE220";
const SIGNAL_DARK = "#609015";
const EMERALD = "#059669";
const EMERALD_LIGHT = "#d1fae5";
const SLATE_500 = "#64748b";
const SLATE_700 = "#334155";
const SLATE_900 = "#0f172a";
const NAVY_50 = "#f8fafc";
const NAVY_100 = "#eef0f7";
const ROW_ALT = "#fbfcfe";

// ---------- Styles ----------
const s = StyleSheet.create({
  page: {
    paddingTop: 38,
    paddingBottom: 60,
    paddingHorizontal: 44,
    fontFamily: "Helvetica",
    fontSize: 9.5,
    color: SLATE_900,
  },
  topBar: { height: 4, backgroundColor: SIGNAL, marginBottom: 16 },
  brandRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
    marginBottom: 6,
  },
  brandTitle: {
    fontSize: 13,
    fontWeight: "bold",
    color: NAVY,
    letterSpacing: 0.4,
  },
  brandSubTitle: {
    fontSize: 13,
    fontWeight: "bold",
    color: SIGNAL_DARK,
    letterSpacing: 0.4,
    marginTop: 1,
  },
  metaLine: { fontSize: 8, color: SLATE_500, marginTop: 2 },
  h1: {
    fontSize: 22,
    fontWeight: "bold",
    color: NAVY,
    marginTop: 16,
    marginBottom: 4,
    letterSpacing: -0.3,
  },
  intro: {
    fontSize: 10,
    color: SLATE_700,
    lineHeight: 1.55,
    marginBottom: 14,
  },
  sectionTitle: {
    backgroundColor: NAVY,
    color: "white",
    padding: 8,
    borderRadius: 4,
    marginTop: 14,
    marginBottom: 6,
    fontSize: 11,
    fontWeight: "bold",
    letterSpacing: 0.2,
  },
  sectionSub: {
    fontSize: 9,
    color: SLATE_500,
    marginBottom: 6,
    fontStyle: "italic",
  },
  // Table
  tHead: {
    flexDirection: "row",
    backgroundColor: NAVY_100,
    paddingVertical: 6,
    paddingHorizontal: 6,
    borderTopLeftRadius: 4,
    borderTopRightRadius: 4,
    fontSize: 8.5,
    fontWeight: "bold",
    color: NAVY,
    letterSpacing: 0.3,
    textTransform: "uppercase",
  },
  tRow: {
    flexDirection: "row",
    paddingVertical: 5,
    paddingHorizontal: 6,
    fontSize: 9,
    borderBottomWidth: 0.5,
    borderBottomColor: NAVY_100,
  },
  tRowAlt: {
    flexDirection: "row",
    paddingVertical: 5,
    paddingHorizontal: 6,
    fontSize: 9,
    borderBottomWidth: 0.5,
    borderBottomColor: NAVY_100,
    backgroundColor: ROW_ALT,
  },
  tTotal: {
    flexDirection: "row",
    paddingVertical: 6,
    paddingHorizontal: 6,
    fontSize: 9,
    fontWeight: "bold",
    backgroundColor: NAVY_100,
    color: NAVY,
    borderBottomLeftRadius: 4,
    borderBottomRightRadius: 4,
  },
  // Column widths
  colModule: { flex: 4, color: SLATE_900 },
  colNum: { width: 40, textAlign: "right" },
  colNumWide: { width: 56, textAlign: "right" },
  // KPI cards
  kpiGrid: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 10,
    marginTop: 10,
    marginBottom: 8,
  },
  kpiCard: {
    flex: 1,
    minWidth: 140,
    borderRadius: 8,
    padding: 12,
    borderWidth: 1,
    borderColor: NAVY_100,
    backgroundColor: NAVY_50,
  },
  kpiLabel: {
    fontSize: 8.5,
    color: SLATE_500,
    textTransform: "uppercase",
    letterSpacing: 0.6,
    fontWeight: "bold",
    marginBottom: 4,
  },
  kpiValue: {
    fontSize: 22,
    fontWeight: "bold",
    color: NAVY,
    letterSpacing: -0.5,
  },
  kpiUnit: { fontSize: 9, color: SLATE_500, marginTop: 2 },
  // Note box
  noteBox: {
    backgroundColor: EMERALD_LIGHT,
    borderLeftWidth: 3,
    borderLeftColor: EMERALD,
    padding: 10,
    borderRadius: 4,
    marginTop: 12,
    marginBottom: 10,
  },
  noteTitle: {
    fontSize: 9.5,
    fontWeight: "bold",
    color: EMERALD,
    marginBottom: 4,
  },
  noteBody: { fontSize: 9, color: SLATE_700, lineHeight: 1.5 },
  // Bullet
  bullet: {
    flexDirection: "row",
    fontSize: 9.5,
    color: SLATE_700,
    lineHeight: 1.55,
    marginBottom: 3,
  },
  bulletDot: { width: 12, color: BRAND, fontWeight: "bold" },
  // Footer
  pageFooter: {
    position: "absolute",
    bottom: 24,
    left: 44,
    right: 44,
    fontSize: 8,
    color: SLATE_500,
    textAlign: "center",
    borderTopWidth: 0.5,
    borderTopColor: NAVY_100,
    paddingTop: 8,
  },
});

// ---------- Données (chiffres issus du script audit_content.py) ----------

interface Row {
  label: string;
  lessons: number;
  qcm: number;
  qr: number;
  practice: number;
  mock: number;
  note?: string; // ex: "v3 dense"
}

const CAPA_ROWS: Row[] = [
  { label: "Module A · Cadre juridique", lessons: 5, qcm: 60, qr: 0, practice: 4, mock: 1, note: "v3" },
  { label: "Module B · Activité commerciale", lessons: 3, qcm: 36, qr: 0, practice: 3, mock: 1, note: "v3" },
  { label: "Module C · Cadre réglementaire transport", lessons: 4, qcm: 48, qr: 7, practice: 5, mock: 1, note: "v3" },
  { label: "Module D · Activité financière", lessons: 4, qcm: 48, qr: 25, practice: 8, mock: 1, note: "v3" },
  { label: "Module E · Salariés et droit social", lessons: 4, qcm: 48, qr: 15, practice: 6, mock: 1, note: "v3" },
  { label: "Module F · Sécurité", lessons: 4, qcm: 48, qr: 7, practice: 4, mock: 1, note: "v3" },
];
const CAPA_TOTAL: Row = {
  label: "Total Capacité ≤ 3,5 t",
  lessons: 24, qcm: 288, qr: 54, practice: 30, mock: 6,
};

// GOTRM v4 livret CCP1 — refonte mai 2026 alignée sur le Livret CCP1
// GOTRM V2 transmis par le client (RNCP 40990, 17 chapitres en 7 parties).
// Les anciens BC01-01 à BC03-02 + MSP + dossier pro v2/v3 sont remplacés.
const GOTRM_ROWS: Row[] = [
  { label: "Ch 1 · Environnement du transport routier", lessons: 1, qcm: 10, qr: 3, practice: 1, mock: 0, note: "v4 livret" },
  { label: "Ch 2 · Véhicules, carrosseries et marchandises", lessons: 1, qcm: 12, qr: 3, practice: 1, mock: 0, note: "v4 livret" },
  { label: "Ch 3 · Analyser une demande et faisabilité", lessons: 1, qcm: 10, qr: 3, practice: 1, mock: 0, note: "v4 livret" },
  { label: "Ch 4 · Coût de revient et tarification", lessons: 1, qcm: 12, qr: 4, practice: 1, mock: 0, note: "v4 livret" },
  { label: "Ch 5 · Rédiger une offre commerciale", lessons: 1, qcm: 10, qr: 3, practice: 1, mock: 0, note: "v4 livret" },
  { label: "Ch 6 · Affecter les moyens matériels et humains", lessons: 1, qcm: 10, qr: 3, practice: 1, mock: 0, note: "v4 livret" },
  { label: "Ch 7 · Documents de transport", lessons: 1, qcm: 10, qr: 3, practice: 1, mock: 0, note: "v4 livret" },
  { label: "Ch 8 · Planifier et optimiser les opérations", lessons: 1, qcm: 10, qr: 3, practice: 1, mock: 0, note: "v4 livret" },
  { label: "Ch 9 · Réglementation sociale européenne (RSE)", lessons: 1, qcm: 12, qr: 4, practice: 1, mock: 0, note: "v4 livret" },
  { label: "Ch 10 · Encadrer une équipe de conducteurs", lessons: 1, qcm: 12, qr: 4, practice: 1, mock: 0, note: "v4 livret" },
  { label: "Ch 11 · Suivi d'exploitation et aléas", lessons: 1, qcm: 12, qr: 4, practice: 1, mock: 0, note: "v4 livret" },
  { label: "Ch 12 · Facturation, litiges et clôture", lessons: 1, qcm: 12, qr: 4, practice: 1, mock: 0, note: "v4 livret" },
  { label: "Ch 13 · KPI et analyse financière", lessons: 1, qcm: 12, qr: 4, practice: 1, mock: 0, note: "v4 livret" },
  { label: "Ch 14 · Obligations environnementales et RSE", lessons: 1, qcm: 10, qr: 3, practice: 1, mock: 0, note: "v4 livret" },
  { label: "Ch 15 · Transport international opérationnel", lessons: 1, qcm: 12, qr: 4, practice: 1, mock: 0, note: "v4 livret" },
  { label: "Ch 16 · Gestion des supports de charge", lessons: 1, qcm: 8, qr: 3, practice: 1, mock: 0, note: "v4 livret" },
  { label: "Ch 17 · L'anglais professionnel en transport", lessons: 1, qcm: 10, qr: 3, practice: 1, mock: 0, note: "v4 livret" },
];
const GOTRM_TOTAL: Row = {
  label: "Total GOTRM CCP1 (v4 livret)",
  lessons: 17, qcm: 184, qr: 62, practice: 17, mock: 0,
};

const EXAM_BLANC_ROWS: Row[] = [
  { label: "CCP1 · Examen blanc final transversal (30 QCM + 6 QR)", lessons: 1, qcm: 0, qr: 0, practice: 0, mock: 1 },
];
const EXAM_BLANC_TOTAL: Row = {
  label: "Total examens blancs CCP1",
  lessons: 1, qcm: 0, qr: 0, practice: 0, mock: 1,
};

// Totaux globaux : Capa (24/288/54/30/6) + GOTRM CCP1 (17/184/62/17/0) + Examen blanc final CCP1 (1/0/0/0/1)
const GRAND_TOTAL = {
  lessons: 42,        // 24 + 17 + 1
  qcm: 472,           // 288 + 184 + 0
  qr: 116,            // 54 + 62 + 0
  questions: 588,     // 472 + 116
  practice: 47,       // 30 + 17 + 0
  mock: 7,            // 6 + 0 + 1
  evals: 54,          // 47 + 7
};

// ---------- Composants ----------

const Header: React.FC<{ title: string }> = ({ title }) => (
  <View fixed>
    <View style={s.topBar} />
    <View style={s.brandRow}>
      <Text style={s.brandTitle}>MA FORMATION</Text>
      <Text style={s.brandSubTitle}>TRANSPORT</Text>
    </View>
    <Text style={s.metaLine}>{title}</Text>
  </View>
);

const Footer: React.FC = () => (
  <Text
    style={s.pageFooter}
    fixed
    render={({ pageNumber, totalPages }) =>
      `MA FORMATION TRANSPORT · État des lieux pédagogique · Page ${pageNumber} / ${totalPages}`
    }
  />
);

const Bullet: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <View style={s.bullet}>
    <Text style={s.bulletDot}>•</Text>
    <Text style={{ flex: 1 }}>{children}</Text>
  </View>
);

const TableHead: React.FC = () => (
  <View style={s.tHead}>
    <Text style={s.colModule}>Module</Text>
    <Text style={s.colNum}>Leçons</Text>
    <Text style={s.colNum}>QCM</Text>
    <Text style={s.colNum}>QR</Text>
    <Text style={s.colNumWide}>Entraîn.</Text>
    <Text style={s.colNumWide}>Examens</Text>
  </View>
);

const TableRow: React.FC<{ row: Row; alt: boolean }> = ({ row, alt }) => (
  <View style={alt ? s.tRowAlt : s.tRow} wrap={false}>
    <Text style={s.colModule}>
      {row.label}
      {row.note ? `   (${row.note})` : ""}
    </Text>
    <Text style={s.colNum}>{row.lessons || "—"}</Text>
    <Text style={s.colNum}>{row.qcm || "—"}</Text>
    <Text style={s.colNum}>{row.qr || "—"}</Text>
    <Text style={s.colNumWide}>{row.practice || "—"}</Text>
    <Text style={s.colNumWide}>{row.mock || "—"}</Text>
  </View>
);

const TableTotal: React.FC<{ row: Row }> = ({ row }) => (
  <View style={s.tTotal} wrap={false}>
    <Text style={s.colModule}>{row.label}</Text>
    <Text style={s.colNum}>{row.lessons}</Text>
    <Text style={s.colNum}>{row.qcm}</Text>
    <Text style={s.colNum}>{row.qr}</Text>
    <Text style={s.colNumWide}>{row.practice}</Text>
    <Text style={s.colNumWide}>{row.mock}</Text>
  </View>
);

const KpiCard: React.FC<{
  label: string;
  value: number;
  unit?: string;
}> = ({ label, value, unit }) => (
  <View style={s.kpiCard}>
    <Text style={s.kpiLabel}>{label}</Text>
    <Text style={s.kpiValue}>{value.toLocaleString("fr-FR")}</Text>
    {unit ? <Text style={s.kpiUnit}>{unit}</Text> : null}
  </View>
);

// ---------- Pages ----------

const PageCover: React.FC = () => (
  <Page size="A4" style={s.page}>
    <Header title="État des lieux pédagogique · synthèse client" />
    <Footer />

    <Text style={s.h1}>État des lieux pédagogique</Text>
    <Text style={s.intro}>
      Ce document présente l'inventaire complet du contenu pédagogique
      actuellement en base sur la plateforme MA FORMATION TRANSPORT :
      leçons rédigées, banque de questions (QCM et QR), quiz d'entraînement
      et examens blancs. Les chiffres sont arrêtés au {new Date().toLocaleDateString("fr-FR")}.
    </Text>

    <View style={s.kpiGrid}>
      <KpiCard label="Leçons" value={GRAND_TOTAL.lessons} unit="modules pédagogiques" />
      <KpiCard label="Questions" value={GRAND_TOTAL.questions} unit="QCM + QR" />
      <KpiCard label="Évaluations" value={GRAND_TOTAL.evals} unit="quiz + examens" />
    </View>

    <View style={s.kpiGrid}>
      <KpiCard label="QCM" value={GRAND_TOTAL.qcm} unit="choix multiples" />
      <KpiCard label="QR" value={GRAND_TOTAL.qr} unit="questions rédigées" />
      <KpiCard label="Examens blancs" value={GRAND_TOTAL.mock} unit="format épreuve réelle" />
    </View>

    <Text style={s.sectionTitle}>1 · Capacité ≤ 3,5 tonnes</Text>
    <Text style={s.sectionSub}>
      Formation refondue en mai 2026 — standard pédagogique v3 dense
      (leçons 2 000-2 500 mots, cas pratiques chiffrés, mémos imprimables,
      références juridiques).
    </Text>
    <TableHead />
    {CAPA_ROWS.map((r, i) => (
      <TableRow key={r.label} row={r} alt={i % 2 === 1} />
    ))}
    <TableTotal row={CAPA_TOTAL} />

    <View style={s.noteBox}>
      <Text style={s.noteTitle}>Standard v3 dense — caractéristiques</Text>
      <Text style={s.noteBody}>
        12 QCM par leçon · 5 à 8 QR cas pratiques par module · examen blanc
        au format de l'épreuve réelle (60 min, seuil 50 %, 13-15 QCM
        transversaux + 5 QR). Sources juridiques citées : Code de commerce,
        Code des transports, contrat-type général (déc. 99-269), CMR
        (Convention Genève 1956), LME 2008.
      </Text>
    </View>
  </Page>
);

const PageGotrm: React.FC = () => (
  <Page size="A4" style={s.page}>
    <Header title="Inventaire GOTRM · RNCP 40990" />
    <Footer />

    <Text style={s.sectionTitle}>2 · GOTRM CCP1 (RNCP 40990) — refonte v4 livret</Text>
    <Text style={s.sectionSub}>
      Gestionnaire d'Opérations de Transport Routier de Marchandises —
      Certificat de Compétences Professionnelles n° 1. Architecture
      reconstruite mai 2026 à partir du Livret CCP1 GOTRM V2 transmis
      par le client : 17 chapitres répartis en 7 parties, contenu
      strictement aligné sur le référentiel.
    </Text>
    <TableHead />
    {GOTRM_ROWS.map((r, i) => (
      <TableRow key={r.label} row={r} alt={i % 2 === 1} />
    ))}
    <TableTotal row={GOTRM_TOTAL} />

    <Text style={s.sectionTitle}>3 · CCP1 — examen blanc final transversal</Text>
    <Text style={s.sectionSub}>
      Examen blanc reproduisant les conditions de l'épreuve nationale
      (30 QCM transversaux des 17 chapitres + 6 QR cas pratique métier,
      durée 120 minutes, seuil 50 %). Réutilise la banque de questions —
      pas de double comptage avec les modules ci-dessus.
    </Text>
    <TableHead />
    {EXAM_BLANC_ROWS.map((r, i) => (
      <TableRow key={r.label} row={r} alt={i % 2 === 1} />
    ))}
    <TableTotal row={EXAM_BLANC_TOTAL} />

    <View style={s.noteBox}>
      <Text style={s.noteTitle}>Roadmap CCP 2 et CCP 3</Text>
      <Text style={s.noteBody}>
        Le titre professionnel GOTRM se compose de 3 CCP. Le CCP1 est
        complet et conforme au livret transmis par le client. Les livrets
        CCP 2 et CCP 3 seront produits dès leur transmission, en suivant
        la même méthode (1 chapitre = 1 module, contenu strictement issu
        du livret, examen blanc transversal final par CCP).
      </Text>
    </View>
  </Page>
);

const PageMethodologie: React.FC = () => (
  <Page size="A4" style={s.page}>
    <Header title="Méthodologie et synthèse" />
    <Footer />

    <Text style={s.sectionTitle}>4 · Synthèse globale</Text>
    <View style={s.kpiGrid}>
      <KpiCard label="Total leçons" value={GRAND_TOTAL.lessons} />
      <KpiCard label="Total QCM" value={GRAND_TOTAL.qcm} />
      <KpiCard label="Total QR" value={GRAND_TOTAL.qr} />
    </View>
    <View style={s.kpiGrid}>
      <KpiCard label="Total questions" value={GRAND_TOTAL.questions} />
      <KpiCard label="Quiz d'entraînement" value={GRAND_TOTAL.practice} />
      <KpiCard label="Examens blancs" value={GRAND_TOTAL.mock} />
    </View>

    <Text style={s.sectionTitle}>5 · Méthode de comptage</Text>
    <Bullet>
      Chiffres extraits automatiquement des fichiers SQL de production
      (script Python audit_content.py).
    </Bullet>
    <Bullet>
      Chaque question a une référence unique (source_ref) en base — pas
      de doublons inter-modules.
    </Bullet>
    <Bullet>
      L'examen blanc final CCP1 réutilise la banque de questions des
      17 chapitres : il n'ajoute pas de questions nouvelles mais compose
      un examen transversal de 30 QCM + 6 QR (120 min, seuil 50 %).
    </Bullet>
    <Bullet>
      Les modules « exploitation transport » et « dossier professionnel »
      contiennent des supports pédagogiques différents (cas DP, scénarios
      d'oral) sans QCM traditionnel.
    </Bullet>

    <Text style={s.sectionTitle}>6 · Format des évaluations</Text>
    <Bullet>
      <Text style={{ fontWeight: "bold" }}>Quiz d'entraînement</Text> :
      12 QCM par quiz, seuil 70 %, sans limite de temps, 5 tentatives
      autorisées. Une correction détaillée par question.
    </Bullet>
    <Bullet>
      <Text style={{ fontWeight: "bold" }}>Examens blancs (modules)</Text> :
      13-15 QCM transversaux + 5 QR cas pratiques, durée 60 minutes,
      seuil 50 % (équivalent examen réel).
    </Bullet>
    <Bullet>
      <Text style={{ fontWeight: "bold" }}>Examens blancs synthétiques</Text> :
      30 QCM + 2 QR sur l'ensemble du bloc (BC01, BC02 ou BC03), durée
      90 minutes, seuil 50 %.
    </Bullet>
    <Bullet>
      <Text style={{ fontWeight: "bold" }}>Mise en Situation Professionnelle</Text> :
      cas pratique complet de fin de parcours (4 QR longues, durée libre),
      simulation de l'épreuve d'oral RNCP.
    </Bullet>

    <Text style={s.sectionTitle}>7 · Standard pédagogique v3 dense</Text>
    <Bullet>Objectifs pédagogiques explicites en début de leçon.</Bullet>
    <Bullet>Introduction métier et chiffres clés.</Bullet>
    <Bullet>Sections numérotées avec tableaux de synthèse.</Bullet>
    <Bullet>2 à 3 cas pratiques chiffrés par leçon (corrigés détaillés).</Bullet>
    <Bullet>Schémas ASCII et arborescences pour visualiser les processus.</Bullet>
    <Bullet>Sections "Points de vigilance" et "Astuces pro" terrain.</Bullet>
    <Bullet>"Ce que l'examinateur peut demander" en fin de leçon.</Bullet>
    <Bullet>Mémo synthèse imprimable (tableau + alertes clés).</Bullet>

    <View style={s.noteBox}>
      <Text style={s.noteTitle}>Conformité Qualiopi</Text>
      <Text style={s.noteBody}>
        Le contenu est tracé en base avec versioning (table lesson_versions),
        dates de mise à jour, et liens vers les référentiels officiels
        (RNCP 40990 pour GOTRM, décision du 2 avril 2012 pour la Capacité
        ≤ 3,5 t). Tous les seeds SQL sont idempotents et auditables.
      </Text>
    </View>
  </Page>
);

// ---------- Document ----------
const Doc: React.FC = () => (
  <Document
    title="État des lieux pédagogique — MA FORMATION TRANSPORT"
    author="MA FORMATION TRANSPORT"
    subject="Inventaire des contenus pédagogiques (leçons, questions, évaluations)"
  >
    <PageCover />
    <PageGotrm />
    <PageMethodologie />
  </Document>
);

// ---------- Génération ----------
(async () => {
  console.log("→ Génération du PDF...");
  await renderToFile(<Doc />, OUTPUT);
  console.log(`✓ PDF généré : ${OUTPUT}`);
})();
