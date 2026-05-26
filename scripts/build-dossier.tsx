/* eslint-disable @next/next/no-img-element */
// =====================================================================
// Générateur du DOSSIER DE PRÉSENTATION PREMIUM (PDF)
// MA FORMATION TRANSPORT — synthèse de l'audit multi-agents.
// Lancement :  npx tsx scripts/build-dossier.tsx
// Sortie    :  livraison/dossier-premium-mft.pdf
// =====================================================================
import React from "react";
import {
  Document,
  Page,
  View,
  Text,
  Svg,
  Path,
  Circle,
  Rect,
  Line,
  StyleSheet,
  renderToFile,
} from "@react-pdf/renderer";

// ─── Tokens ──────────────────────────────────────────────────────────
const C = {
  night: "#0B0F24", // fond sombre vitrine
  navy: "#0E1240", // navy d'autorité
  navy2: "#161B3D",
  brand: "#2530D9", // bleu royal
  lime: "#9FE220", // signal
  lime700: "#5C8A0F", // lime lisible sur clair
  gold: "#A16207",
  ivory: "#FAF8F4",
  surface: "#F4F2EC",
  paper: "#FFFFFF",
  ink: "#0E1240",
  slate: "#475569",
  muted: "#64748B",
  faint: "#94A3B8",
  border: "#E7E3DB",
  borderDark: "#222A55",
  white: "#FFFFFF",
  whiteDim: "rgba(255,255,255,0.62)",
  whiteFaint: "rgba(255,255,255,0.40)",
};

const PAGE_PAD = 50;

const s = StyleSheet.create({
  // pages
  pageLight: {
    backgroundColor: C.ivory,
    color: C.ink,
    paddingTop: 44,
    paddingBottom: 64,
    paddingHorizontal: PAGE_PAD,
    fontFamily: "Helvetica",
    fontSize: 9.5,
    lineHeight: 1.5,
  },
  pageDark: {
    backgroundColor: C.night,
    color: C.white,
    paddingTop: PAGE_PAD,
    paddingBottom: PAGE_PAD,
    paddingHorizontal: PAGE_PAD,
    fontFamily: "Helvetica",
    fontSize: 9.5,
    lineHeight: 1.5,
  },
  // typography
  eyebrow: {
    fontFamily: "Helvetica-Bold",
    fontSize: 8,
    letterSpacing: 2,
    color: C.lime700,
    textTransform: "uppercase",
  },
  eyebrowOnDark: { color: C.lime },
  h1: { fontFamily: "Helvetica-Bold", fontSize: 21, color: C.navy, letterSpacing: -0.3, lineHeight: 1.2 },
  h2: { fontFamily: "Helvetica-Bold", fontSize: 13.5, color: C.navy, letterSpacing: -0.2 },
  h3: { fontFamily: "Helvetica-Bold", fontSize: 10.5, color: C.navy },
  p: { fontSize: 9.5, color: C.slate, lineHeight: 1.55 },
  pTight: { fontSize: 9, color: C.slate, lineHeight: 1.5 },
  small: { fontSize: 8, color: C.muted, lineHeight: 1.45 },
  // footer
  footer: {
    position: "absolute",
    bottom: 26,
    left: PAGE_PAD,
    right: PAGE_PAD,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    borderTopWidth: 0.5,
    borderTopColor: C.border,
    paddingTop: 7,
  },
  footerTxt: { fontSize: 7, color: C.faint, letterSpacing: 0.4 },
});

// ─── Logo (SVG reproduit : cercle navy, route lime en perspective, toque) ─
function Mark({ size = 30 }: { size?: number }) {
  return (
    <Svg viewBox="0 0 100 100" style={{ width: size, height: size }}>
      <Circle cx="50" cy="50" r="47" fill={C.navy} stroke={C.lime} strokeWidth="2" />
      {/* route en perspective */}
      <Path d="M37 80 L46 44 L54 44 L63 80 Z" fill={C.lime} />
      <Rect x="49" y="68" width="2.2" height="7" fill={C.navy} />
      <Rect x="49.2" y="55" width="1.8" height="6" fill={C.navy} />
      {/* toque universitaire */}
      <Path d="M31 38 L50 30 L69 38 L50 46 Z" fill={C.white} />
      <Path d="M61 42 L61 51" stroke={C.lime} strokeWidth="2" />
      <Circle cx="61" cy="52.5" r="2" fill={C.lime} />
    </Svg>
  );
}

function Wordmark({ light = false, size = 13 }: { light?: boolean; size?: number }) {
  return (
    <View>
      <Text style={{ fontFamily: "Helvetica-Bold", fontSize: size, color: light ? C.white : C.brand, letterSpacing: 0.2 }}>
        MA FORMATION
      </Text>
      <Text style={{ fontFamily: "Helvetica-Bold", fontSize: size, color: light ? C.lime : C.lime700, letterSpacing: 0.2, marginTop: -2 }}>
        TRANSPORT
      </Text>
    </View>
  );
}

// ─── Footer ──────────────────────────────────────────────────────────
function Footer() {
  return (
    <View style={s.footer} fixed>
      <Text style={s.footerTxt}>MA FORMATION TRANSPORT · Dossier de présentation</Text>
      <Text
        style={s.footerTxt}
        render={({ pageNumber, totalPages }) => `${pageNumber} / ${totalPages}`}
      />
    </View>
  );
}

// ─── Briques de contenu ──────────────────────────────────────────────
function Pill({ label, dark = false, tone = "lime" }: { label: string; dark?: boolean; tone?: "lime" | "gold" | "navy" }) {
  const bg = dark
    ? "rgba(159,226,32,0.14)"
    : tone === "gold"
      ? "#FBF3DE"
      : tone === "navy"
        ? "#E9EBFA"
        : "#EEF8DC";
  const fg = dark ? C.lime : tone === "gold" ? C.gold : tone === "navy" ? C.brand : C.lime700;
  const bd = dark ? "rgba(159,226,32,0.35)" : tone === "gold" ? "#EAD9A8" : tone === "navy" ? "#C9CEF4" : "#D4E8AE";
  return (
    <View
      style={{
        backgroundColor: bg,
        borderWidth: 0.75,
        borderColor: bd,
        borderRadius: 20,
        paddingVertical: 3,
        paddingHorizontal: 9,
        marginRight: 6,
        marginBottom: 6,
      }}
    >
      <Text style={{ fontSize: 7.5, fontFamily: "Helvetica-Bold", color: fg, letterSpacing: 0.5 }}>{label}</Text>
    </View>
  );
}

function Bullet({ children, dark = false }: { children: React.ReactNode; dark?: boolean }) {
  return (
    <View style={{ flexDirection: "row", marginBottom: 3.5 }}>
      <View style={{ width: 4, height: 4, borderRadius: 2, backgroundColor: C.lime700, marginTop: 4, marginRight: 7 }} />
      <Text style={{ flex: 1, fontSize: 9, color: dark ? C.whiteDim : C.slate, lineHeight: 1.5 }}>{children}</Text>
    </View>
  );
}

function SectionHead({ n, title, intro }: { n: string; title: string; intro?: string }) {
  return (
    <View style={{ marginBottom: 16 }}>
      <View style={{ flexDirection: "row", alignItems: "center", marginBottom: 6 }}>
        <View
          style={{
            backgroundColor: C.navy,
            borderRadius: 6,
            paddingVertical: 3,
            paddingHorizontal: 7,
            marginRight: 8,
          }}
        >
          <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 8.5, color: C.lime, letterSpacing: 1 }}>
            {`SECTION ${n}`}
          </Text>
        </View>
        <View style={{ flex: 1, height: 0.75, backgroundColor: C.border }} />
      </View>
      <Text style={s.h1}>{title}</Text>
      {intro ? <Text style={[s.p, { marginTop: 9 }]}>{intro}</Text> : null}
    </View>
  );
}

function Card({
  children,
  style,
  accent,
}: {
  children: React.ReactNode;
  style?: any;
  accent?: boolean;
}) {
  return (
    <View
      wrap={false}
      style={[
        {
          backgroundColor: C.paper,
          borderWidth: 0.75,
          borderColor: C.border,
          borderRadius: 10,
          padding: 12,
        },
        accent ? { borderColor: "#D4E8AE", backgroundColor: "#FCFEF7" } : {},
        style,
      ]}
    >
      {children}
    </View>
  );
}

function KpiTile({ value, label }: { value: string; label: string }) {
  return (
    <View
      style={{
        width: "31%",
        backgroundColor: C.paper,
        borderWidth: 0.75,
        borderColor: C.border,
        borderRadius: 10,
        paddingVertical: 12,
        paddingHorizontal: 12,
        marginBottom: 10,
      }}
    >
      <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 19, color: C.navy }}>{value}</Text>
      <Text style={{ fontSize: 7.5, color: C.muted, marginTop: 3, textTransform: "uppercase", letterSpacing: 0.6 }}>
        {label}
      </Text>
    </View>
  );
}

function Callout({ title, children, tone = "navy" }: { title: string; children: React.ReactNode; tone?: "navy" | "lime" | "gold" }) {
  const bg = tone === "lime" ? "#F2FADF" : tone === "gold" ? "#FBF5E6" : "#EEF0FB";
  const bar = tone === "lime" ? C.lime700 : tone === "gold" ? C.gold : C.brand;
  return (
    <View wrap={false} style={{ backgroundColor: bg, borderRadius: 10, padding: 12, marginTop: 4, marginBottom: 6, flexDirection: "row" }}>
      <View style={{ width: 3, borderRadius: 2, backgroundColor: bar, marginRight: 10 }} />
      <View style={{ flex: 1 }}>
        <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 9.5, color: C.navy, marginBottom: 3 }}>{title}</Text>
        <Text style={{ fontSize: 8.7, color: C.slate, lineHeight: 1.5 }}>{children}</Text>
      </View>
    </View>
  );
}

// Feature card : titre + objectif + fonctionnement + bénéfices
function Feature({
  title,
  objectif,
  fonctionnement,
  benefices,
}: {
  title: string;
  objectif: string;
  fonctionnement: string;
  benefices: string[];
}) {
  return (
    <Card style={{ width: "48.5%", marginBottom: 11 }}>
      <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 10.5, color: C.navy, marginBottom: 5 }}>{title}</Text>
      <Text style={{ fontSize: 8.4, color: C.slate, lineHeight: 1.45, marginBottom: 4 }}>
        <Text style={{ fontFamily: "Helvetica-Bold", color: C.lime700 }}>Objectif. </Text>
        {objectif}
      </Text>
      <Text style={{ fontSize: 8.4, color: C.slate, lineHeight: 1.45, marginBottom: 6 }}>
        <Text style={{ fontFamily: "Helvetica-Bold", color: C.navy }}>Fonctionnement. </Text>
        {fonctionnement}
      </Text>
      <View style={{ flexDirection: "row", flexWrap: "wrap" }}>
        {benefices.map((b, i) => (
          <View key={i} style={{ backgroundColor: C.surface, borderRadius: 5, paddingVertical: 2, paddingHorizontal: 6, marginRight: 5, marginBottom: 4 }}>
            <Text style={{ fontSize: 7, color: C.muted, fontFamily: "Helvetica-Bold", letterSpacing: 0.3 }}>{b}</Text>
          </View>
        ))}
      </View>
    </Card>
  );
}

// ─── COUVERTURE ──────────────────────────────────────────────────────
function Cover() {
  return (
    <Page size="A4" style={s.pageDark}>
      {/* filet lime décoratif */}
      <View style={{ position: "absolute", top: 0, left: 0, right: 0, height: 6, backgroundColor: C.lime }} />
      <View style={{ flexDirection: "row", alignItems: "center", marginTop: 14 }}>
        <Mark size={40} />
        <View style={{ marginLeft: 12 }}>
          <Wordmark light size={15} />
        </View>
      </View>

      <View style={{ flexGrow: 1, justifyContent: "center" }}>
        <Text style={[s.eyebrow, s.eyebrowOnDark]}>Dossier professionnel · Confidentiel</Text>
        <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 40, color: C.white, letterSpacing: -1, marginTop: 14, lineHeight: 1.05 }}>
          La plateforme de
        </Text>
        <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 40, color: C.white, letterSpacing: -1, lineHeight: 1.05 }}>
          formation des pros
        </Text>
        <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 40, color: C.lime, letterSpacing: -1, lineHeight: 1.05 }}>
          du transport.
        </Text>
        <Text style={{ fontSize: 12, color: C.whiteDim, marginTop: 18, maxWidth: 380, lineHeight: 1.55 }}>
          Un LMS sur mesure pour la préparation aux titres professionnels du transport routier,
          pensé pour la réussite des stagiaires et la conformité d'un organisme de formation certifié Qualiopi.
        </Text>

        <View style={{ flexDirection: "row", flexWrap: "wrap", marginTop: 24 }}>
          <Pill label="QUALIOPI-READY" dark />
          <Pill label="RNCP 40990" dark />
          <Pill label="8 FORMATIONS" dark />
          <Pill label="4 ROLES UTILISATEURS" dark />
          <Pill label="NEXT.JS + SUPABASE" dark />
        </View>
      </View>

      <View style={{ borderTopWidth: 0.75, borderTopColor: C.borderDark, paddingTop: 12, flexDirection: "row", justifyContent: "space-between" }}>
        <View>
          <Text style={{ fontSize: 8.5, color: C.white, fontFamily: "Helvetica-Bold" }}>MA FORMATION TRANSPORT — SAS</Text>
          <Text style={{ fontSize: 8, color: C.whiteFaint, marginTop: 2 }}>Meaux (77) · SIRET 908 851 280 00028 · NDA 11 77 09 47177</Text>
        </View>
        <Text style={{ fontSize: 8, color: C.whiteFaint }}>Édition Mai 2026</Text>
      </View>
    </Page>
  );
}

// ─── SOMMAIRE + EN BREF ──────────────────────────────────────────────
const TOC = [
  ["01", "Présentation générale", "Concept, plateforme, formations et vision"],
  ["02", "Rôles utilisateurs", "Stagiaire, formateur, admin, super-admin"],
  ["03", "Fonctionnalités principales", "Objectif, fonctionnement et bénéfices"],
  ["04", "Logique pédagogique", "Modules, quiz, examens, progression, gamification"],
  ["05", "Administratif & Qualiopi", "Signatures, émargement, documents, traçabilité"],
  ["06", "Technique, expliquée simplement", "Sécurité, hébergement, performances, évolutivité"],
  ["07", "Design & expérience", "Interface premium, animations, accessibilité"],
  ["08", "Analytics & pilotage", "Tableaux de bord, KPIs et rapports"],
  ["09", "Vision & perspectives", "IA, SaaS multi-écoles, mobile, CPF"],
];

function TocPage() {
  return (
    <Page size="A4" style={s.pageLight}>
      <Footer />
      <SectionHead n="—" title="Sommaire" intro="Ce dossier présente l'ensemble de la plateforme : son concept, ses utilisateurs, ses fonctionnalités, sa logique pédagogique, sa conformité administrative française et sa vision. Il est rédigé pour être clair, y compris pour un lecteur non technique." />

      <View style={{ marginBottom: 18 }}>
        {TOC.map(([n, t, d]) => (
          <View key={n} style={{ flexDirection: "row", alignItems: "center", paddingVertical: 7, borderBottomWidth: 0.5, borderBottomColor: C.border }}>
            <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 12, color: C.lime700, width: 30 }}>{n}</Text>
            <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 10.5, color: C.navy, width: 180 }}>{t}</Text>
            <Text style={{ fontSize: 8.5, color: C.muted, flex: 1 }}>{d}</Text>
          </View>
        ))}
      </View>

      <Text style={s.eyebrow}>La plateforme en bref</Text>
      <View style={{ flexDirection: "row", flexWrap: "wrap", justifyContent: "space-between", marginTop: 8 }}>
        <KpiTile value="8" label="Formations métier" />
        <KpiTile value="95+" label="Tables de données" />
        <KpiTile value="4" label="Rôles & espaces" />
        <KpiTile value="420+" label="Écrans applicatifs" />
        <KpiTile value="100 %" label="Tables sécurisées (RLS)" />
        <KpiTile value="0,9+" label="Accessibilité (gate CI)" />
      </View>
    </Page>
  );
}

// ─── DIVIDER de section (page sombre) ────────────────────────────────
function Divider({ n, title, sub, points }: { n: string; title: string; sub: string; points: string[] }) {
  return (
    <Page size="A4" style={s.pageDark}>
      <View style={{ position: "absolute", top: 0, left: 0, bottom: 0, width: 5, backgroundColor: C.lime }} />
      <View style={{ flexDirection: "row", alignItems: "center" }}>
        <Mark size={26} />
        <Text style={{ marginLeft: 10, fontSize: 9, color: C.whiteFaint, fontFamily: "Helvetica-Bold", letterSpacing: 1 }}>
          MA FORMATION TRANSPORT
        </Text>
      </View>
      <View style={{ flexGrow: 1, justifyContent: "center" }}>
        <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 74, color: "rgba(159,226,32,0.20)", letterSpacing: -2, lineHeight: 1, marginBottom: 18 }}>{n}</Text>
        <Text style={[s.eyebrow, s.eyebrowOnDark]}>{`Section ${n}`}</Text>
        <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 30, color: C.white, letterSpacing: -0.6, marginTop: 9, maxWidth: 440, lineHeight: 1.15 }}>{title}</Text>
        <Text style={{ fontSize: 11, color: C.whiteDim, marginTop: 12, maxWidth: 400, lineHeight: 1.55 }}>{sub}</Text>
        <View style={{ marginTop: 20, maxWidth: 420 }}>
          {points.map((p, i) => (
            <View key={i} style={{ flexDirection: "row", marginBottom: 5 }}>
              <Text style={{ color: C.lime, fontFamily: "Helvetica-Bold", marginRight: 8, fontSize: 9 }}>{String(i + 1).padStart(2, "0")}</Text>
              <Text style={{ flex: 1, fontSize: 9.5, color: C.whiteDim }}>{p}</Text>
            </View>
          ))}
        </View>
      </View>
    </Page>
  );
}

// =====================================================================
//  CONTENU DES SECTIONS
// =====================================================================

// 01 — Présentation
const FORMATIONS: [string, string, string][] = [
  ["GOTRM", "Titre pro · RNCP 40990 · niveau 5", "Gestionnaire des opérations de transport routier de marchandises"],
  ["ERTV", "Titre pro · niveau 4", "Exploitant régulation transport de voyageurs"],
  ["ECSR", "Titre pro · niveau 5", "Enseignant de la conduite et de la sécurité routière"],
  ["Capacité légère", "Attestation · 3,5 t et moins", "Capacité de transport de marchandises (véhicules légers)"],
  ["Capacité lourde", "Attestation · plus de 3,5 t", "Capacité de transport de marchandises (poids lourds)"],
  ["FIMO / FCO", "Obligatoire conducteurs", "Formation initiale et continue des conducteurs"],
  ["Taxi & VTC", "Examen professionnel", "Préparation aux examens taxi et VTC"],
  ["Commissionnaire", "Attestation de capacité", "Commissionnaire de transport"],
];

function Sec01() {
  return (
    <Page size="A4" style={s.pageLight}>
      <Footer />
      <SectionHead
        n="01"
        title="Présentation générale"
        intro="MA FORMATION TRANSPORT est un organisme de formation français spécialisé dans les métiers du transport routier de marchandises et de voyageurs. La plateforme est son école en ligne : un LMS (Learning Management System) sur mesure qui digitalise l'intégralité du parcours, de l'inscription à la certification, tout en industrialisant la conformité réglementaire."
      />

      <View style={{ flexDirection: "row", justifyContent: "space-between", marginBottom: 14 }}>
        <Card style={{ width: "31.5%" }}>
          <Text style={s.h3}>Le concept</Text>
          <Text style={[s.pTight, { marginTop: 4 }]}>
            Une école 100 % digitale, accessible 24h/24, qui combine cours structurés, entraînements,
            examens blancs et accompagnement humain pour préparer aux titres officiels du transport.
          </Text>
        </Card>
        <Card style={{ width: "31.5%" }}>
          <Text style={s.h3}>La plateforme</Text>
          <Text style={[s.pTight, { marginTop: 4 }]}>
            Un produit unique pour quatre publics (stagiaire, formateur, administration, direction),
            chacun avec son espace dédié, ses droits et ses outils, sur une base de données commune et sécurisée.
          </Text>
        </Card>
        <Card style={{ width: "31.5%" }}>
          <Text style={s.h3}>La vision</Text>
          <Text style={[s.pTight, { marginTop: 4 }]}>
            Faire d'un centre de formation exigeant une plateforme moderne, mesurable et conforme,
            capable de grandir vers un modèle multi-écoles (SaaS) sans rien sacrifier à la qualité.
          </Text>
        </Card>
      </View>

      <Text style={s.h2}>Objectifs de la plateforme</Text>
      <View style={{ marginTop: 7, marginBottom: 14 }}>
        <Bullet>Maximiser la réussite aux examens grâce à un parcours adaptatif et des entraînements proches des épreuves réelles.</Bullet>
        <Bullet>Offrir une expérience d'apprentissage moderne et engageante, qui donne envie de revenir chaque jour.</Bullet>
        <Bullet>Donner à l'équipe pédagogique des outils de suivi et de correction efficaces.</Bullet>
        <Bullet>Garantir une traçabilité administrative complète (présence, signatures, documents) attendue d'un organisme certifié.</Bullet>
        <Bullet>Piloter l'activité par la donnée : inscriptions, progression, satisfaction, chiffre d'affaires.</Bullet>
      </View>

      <Text style={s.h2}>Un catalogue de 8 formations</Text>
      <Text style={[s.pTight, { marginTop: 4, marginBottom: 9 }]}>
        Chaque formation est décrite avec ses objectifs, prérequis, public visé, programme par blocs de compétences,
        modalités d'évaluation et débouchés, conformément aux attendus d'un organisme de formation.
      </Text>
      <View style={{ flexDirection: "row", flexWrap: "wrap", justifyContent: "space-between" }}>
        {FORMATIONS.map(([code, tag, desc]) => (
          <View key={code} wrap={false} style={{ width: "48.5%", flexDirection: "row", alignItems: "flex-start", backgroundColor: C.paper, borderWidth: 0.75, borderColor: C.border, borderRadius: 9, padding: 10, marginBottom: 9 }}>
            <View style={{ width: 4, alignSelf: "stretch", borderRadius: 2, backgroundColor: C.lime, marginRight: 9 }} />
            <View style={{ flex: 1 }}>
              <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 10, color: C.navy }}>{code}</Text>
              <Text style={{ fontSize: 7, color: C.lime700, fontFamily: "Helvetica-Bold", letterSpacing: 0.4, marginTop: 1, textTransform: "uppercase" }}>{tag}</Text>
              <Text style={{ fontSize: 8.2, color: C.slate, marginTop: 3, lineHeight: 1.4 }}>{desc}</Text>
            </View>
          </View>
        ))}
      </View>
    </Page>
  );
}

// 02 — Rôles
function RoleCard({ emoji, title, sub, items }: { emoji: string; title: string; sub: string; items: string[] }) {
  return (
    <Card style={{ width: "48.5%", marginBottom: 11 }}>
      <View style={{ flexDirection: "row", alignItems: "center", marginBottom: 6 }}>
        <View style={{ width: 26, height: 26, borderRadius: 7, backgroundColor: C.navy, alignItems: "center", justifyContent: "center", marginRight: 8 }}>
          <Text style={{ color: C.lime, fontFamily: "Helvetica-Bold", fontSize: 11 }}>{emoji}</Text>
        </View>
        <View style={{ flex: 1 }}>
          <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 11, color: C.navy }}>{title}</Text>
          <Text style={{ fontSize: 7.6, color: C.muted }}>{sub}</Text>
        </View>
      </View>
      {items.map((it, i) => (
        <Bullet key={i}>{it}</Bullet>
      ))}
    </Card>
  );
}

const MATRIX: [string, boolean[]][] = [
  // [capability, [Stagiaire, Formateur, Admin, Super-admin]]
  ["Suivre les cours, quiz et examens", [true, false, false, false]],
  ["Voir sa progression et ses résultats", [true, true, true, true]],
  ["Corriger les questions rédigées", [false, true, true, true]],
  ["Gérer le contenu pédagogique", [false, true, true, true]],
  ["Gérer les utilisateurs et les classes", [false, false, true, true]],
  ["Gérer inscriptions, financeurs, paiements", [false, false, true, true]],
  ["Suivre signatures et émargements", [false, true, true, true]],
  ["Analytics et rapports (BPF, Qualiopi)", [false, false, true, true]],
  ["Gérer permissions et sécurité", [false, false, false, true]],
  ["Paramétrage avancé de la plateforme", [false, false, false, true]],
];

function Sec02() {
  return (
    <Page size="A4" style={s.pageLight}>
      <Footer />
      <SectionHead
        n="02"
        title="Les rôles utilisateurs"
        intro="La plateforme distingue quatre profils, chacun avec son espace, ses droits et ses outils. Les accès sont strictement cloisonnés au niveau de la base de données : chaque profil ne voit et ne fait que ce qui le concerne."
      />

      <View style={{ flexDirection: "row", flexWrap: "wrap", justifyContent: "space-between" }}>
        <RoleCard
          emoji="S"
          title="Stagiaire"
          sub="L'apprenant"
          items={[
            "Tableau de bord personnalisé qui indique la prochaine action à faire",
            "Modules, leçons, glossaire et ressources pédagogiques",
            "Quiz d'entraînement, examens blancs et examens globaux",
            "Progression, statistiques, badges, XP et rangs",
            "Signatures des documents et émargement des sessions",
            "Documents personnels, messagerie, notifications, tuteur IA",
            "Résultats détaillés et remédiation après chaque évaluation",
          ]}
        />
        <RoleCard
          emoji="F"
          title="Formateur"
          sub="L'encadrement pédagogique"
          items={[
            "Suivi pédagogique des stagiaires de ses formations",
            "Correction des questions rédigées, notes et commentaires",
            "Gestion des modules, leçons et de la banque de questions",
            "Animation des sessions en direct (présentiel / visio)",
            "Suivi des émargements et de l'assiduité",
            "Statistiques de progression par stagiaire et par groupe",
          ]}
        />
        <RoleCard
          emoji="A"
          title="Administrateur"
          sub="La gestion de l'organisme"
          items={[
            "Gestion des utilisateurs, classes et affectations",
            "Gestion des formations, modules, quiz et examens",
            "Inscriptions, financeurs, paiements et CRM commercial",
            "Documents : conventions, convocations, attestations, devis",
            "Suivi administratif, signatures et émargements",
            "Analytics, exports, rapports BPF et Qualiopi",
          ]}
        />
        <RoleCard
          emoji="SA"
          title="Super-administrateur"
          sub="La direction"
          items={[
            "Accès total à la plateforme et supervision complète",
            "Gestion des rôles, permissions et sécurité",
            "Changement de rôle régalien, journalisé et protégé",
            "Analytics globaux et pilotage stratégique",
            "Paramétrage avancé et configuration de la plateforme",
          ]}
        />
      </View>

      <Text style={[s.h2, { marginTop: 6 }]}>Matrice des accès</Text>
      <Text style={[s.small, { marginTop: 3, marginBottom: 8 }]}>
        Synthèse des droits par rôle. Les autorisations sont appliquées côté serveur et au niveau base de données (sécurité par les lignes).
      </Text>
      <View style={{ borderWidth: 0.75, borderColor: C.border, borderRadius: 9, overflow: "hidden" }}>
        <View style={{ flexDirection: "row", backgroundColor: C.navy }}>
          <Text style={{ flex: 1, padding: 6, fontSize: 7.6, color: C.white, fontFamily: "Helvetica-Bold" }}>Capacité</Text>
          {["Stagiaire", "Formateur", "Admin", "Super-admin"].map((h) => (
            <Text key={h} style={{ width: 64, padding: 6, fontSize: 7, color: C.lime, fontFamily: "Helvetica-Bold", textAlign: "center" }}>{h}</Text>
          ))}
        </View>
        {MATRIX.map(([cap, vals], i) => (
          <View key={cap} style={{ flexDirection: "row", backgroundColor: i % 2 ? C.surface : C.paper, borderTopWidth: 0.5, borderTopColor: C.border }}>
            <Text style={{ flex: 1, padding: 6, fontSize: 7.8, color: C.slate }}>{cap}</Text>
            {vals.map((v, j) => (
              <View key={j} style={{ width: 64, padding: 6, alignItems: "center", justifyContent: "center" }}>
                {v ? (
                  <View style={{ width: 7, height: 7, borderRadius: 4, backgroundColor: C.lime700 }} />
                ) : (
                  <Text style={{ fontSize: 8, color: C.faint }}>-</Text>
                )}
              </View>
            ))}
          </View>
        ))}
      </View>
    </Page>
  );
}

// 03 — Fonctionnalités
function Sec03() {
  return (
    <Page size="A4" style={s.pageLight}>
      <Footer />
      <SectionHead
        n="03"
        title="Fonctionnalités principales"
        intro="Pour chaque fonctionnalité : son objectif, son fonctionnement et ses bénéfices (métier, pédagogique, administratif)."
      />
      <View style={{ flexDirection: "row", flexWrap: "wrap", justifyContent: "space-between" }}>
        <Feature
          title="Parcours adaptatif"
          objectif="Guider chaque stagiaire vers la bonne étape, sans le perdre."
          fonctionnement="Les modules se déverrouillent au fur et à mesure (mode strict ou flexible selon la formation) ; le tableau de bord calcule la prochaine action."
          benefices={["RÉUSSITE", "ENGAGEMENT", "SUIVI"]}
        />
        <Feature
          title="Quiz QCM auto-corrigés"
          objectif="Entraîner et évaluer instantanément les connaissances."
          fonctionnement="Seuil de réussite, nombre de tentatives, délai entre essais, mélange des questions ; correction et explications immédiates."
          benefices={["PÉDAGOGIE", "GAIN DE TEMPS"]}
        />
        <Feature
          title="Questions rédigées (QR)"
          objectif="Préparer les épreuves rédigées du jury, pas seulement le QCM."
          fonctionnement="Réponses libres avec réponse-modèle et barème ; correction par le formateur, notes et commentaires personnalisés."
          benefices={["FIDÉLITÉ EXAMEN", "QUALITÉ"]}
        />
        <Feature
          title="Examens blancs"
          objectif="Mettre le stagiaire en conditions réelles d'examen."
          fonctionnement="Mode strict : plein écran obligatoire, minuteur, détection des sorties d'écran, blocage du copier-coller, reprise après coupure."
          benefices={["RÉUSSITE", "ÉQUITÉ"]}
        />
        <Feature
          title="Test de positionnement"
          objectif="Adapter le parcours dès l'entrée (exigence Qualiopi)."
          fonctionnement="Questionnaire par bloc, score calculé côté serveur, recommandation du bloc d'entrée le plus pertinent."
          benefices={["INDIVIDUALISATION", "CONFORMITÉ"]}
        />
        <Feature
          title="Correction assistée par IA"
          objectif="Aider le formateur à corriger plus vite et plus régulièrement."
          fonctionnement="L'IA propose un pré-score, une appréciation et des critères ; le formateur reste seul décisionnaire de la note finale."
          benefices={["PRODUCTIVITÉ", "RÉGULARITÉ"]}
        />
        <Feature
          title="Tuteur IA pédagogique"
          objectif="Répondre aux questions du stagiaire à tout moment."
          fonctionnement="Assistant conversationnel encadré par des quotas, ancré sur le contenu des leçons."
          benefices={["AUTONOMIE", "SUPPORT 24/7"]}
        />
        <Feature
          title="Gamification"
          objectif="Soutenir la motivation et la régularité."
          fonctionnement="Points d'expérience, 5 rangs (Débutant à Master), badges, série de connexion, classement avec retrait possible."
          benefices={["ENGAGEMENT", "RÉTENTION"]}
        />
        <Feature
          title="Signature électronique"
          objectif="Recueillir et prouver l'acceptation des documents obligatoires."
          fonctionnement="Lecture, acceptation et signature manuscrite horodatées, empreinte de sécurité (hash), adresse et appareil enregistrés."
          benefices={["CONFORMITÉ", "PREUVE OPPOSABLE"]}
        />
        <Feature
          title="Émargement horodaté"
          objectif="Prouver l'assiduité, en présentiel comme à distance."
          fonctionnement="Signature par demi-journée (matin / après-midi) et contre-signature du formateur ; émargement détaillé par leçon pour la FOAD."
          benefices={["QUALIOPI", "TRAÇABILITÉ"]}
        />
        <Feature
          title="Génération de documents"
          objectif="Produire les documents contractuels en un clic."
          fonctionnement="Conventions, convocations, devis, attestations et certificats générés en PDF, alimentés par l'identité légale de l'organisme."
          benefices={["GAIN DE TEMPS", "CONFORMITÉ"]}
        />
        <Feature
          title="Pilotage & rapports"
          objectif="Décider grâce à la donnée et préparer le BPF."
          fonctionnement="Tableaux de bord temps réel, indicateurs Qualiopi, exports CSV et synthèse du Bilan Pédagogique et Financier."
          benefices={["PILOTAGE", "REPORTING"]}
        />
      </View>
    </Page>
  );
}

// 04 — Pédagogie
function Step({ n, title, text }: { n: string; title: string; text: string }) {
  return (
    <View style={{ flexDirection: "row", marginBottom: 9 }}>
      <View style={{ alignItems: "center", marginRight: 10 }}>
        <View style={{ width: 20, height: 20, borderRadius: 10, backgroundColor: C.navy, alignItems: "center", justifyContent: "center" }}>
          <Text style={{ color: C.lime, fontFamily: "Helvetica-Bold", fontSize: 8.5 }}>{n}</Text>
        </View>
        <View style={{ width: 1, flex: 1, backgroundColor: C.border, marginTop: 2 }} />
      </View>
      <View style={{ flex: 1, paddingBottom: 2 }}>
        <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 9.5, color: C.navy }}>{title}</Text>
        <Text style={{ fontSize: 8.6, color: C.slate, marginTop: 2, lineHeight: 1.45 }}>{text}</Text>
      </View>
    </View>
  );
}

function Sec04() {
  return (
    <Page size="A4" style={s.pageLight}>
      <Footer />
      <SectionHead
        n="04"
        title="La logique pédagogique"
        intro="La plateforme n'est pas un simple catalogue de cours : c'est un dispositif de formation structuré par les référentiels officiels, qui mène le stagiaire de l'évaluation initiale jusqu'à la certification."
      />

      <Text style={s.h2}>Une architecture fidèle aux référentiels</Text>
      <View style={{ flexDirection: "row", justifyContent: "space-between", marginTop: 8, marginBottom: 14 }}>
        <Card style={{ width: "31.5%" }}>
          <Text style={s.h3}>Blocs de compétences</Text>
          <Text style={[s.pTight, { marginTop: 3 }]}>Le découpage suit le titre officiel. Pour le GOTRM : trois blocs (BC1, BC2, BC3) conformes au référentiel RNCP.</Text>
        </Card>
        <Card style={{ width: "31.5%" }}>
          <Text style={s.h3}>Modules & leçons</Text>
          <Text style={[s.pTight, { marginTop: 3 }]}>Chaque bloc se compose de modules, eux-mêmes faits de leçons (contenu riche, durée estimée, vidéo d'intro, versionnage).</Text>
        </Card>
        <Card style={{ width: "31.5%" }}>
          <Text style={s.h3}>Réutilisation</Text>
          <Text style={[s.pTight, { marginTop: 3 }]}>Un même module peut servir plusieurs formations, avec un ordre de parcours propre à chacune.</Text>
        </Card>
      </View>

      <Text style={s.h2}>Évaluations : du QCM à l'épreuve rédigée</Text>
      <View style={{ marginTop: 7, marginBottom: 12 }}>
        <Bullet><Text style={{ fontFamily: "Helvetica-Bold", color: C.navy }}>QCM auto-corrigés</Text> : entraînement et évaluation instantanés, paramétrables (seuil, tentatives, minuteur).</Bullet>
        <Bullet><Text style={{ fontFamily: "Helvetica-Bold", color: C.navy }}>Questions rédigées</Text> : réponses libres notées par le formateur, au plus près des épreuves du jury.</Bullet>
        <Bullet><Text style={{ fontFamily: "Helvetica-Bold", color: C.navy }}>Examens blancs et globaux</Text> : conditions réelles, mode strict anti-triche.</Bullet>
        <Bullet><Text style={{ fontFamily: "Helvetica-Bold", color: C.navy }}>Positionnement initial</Text> : adapte le point d'entrée du parcours.</Bullet>
      </View>

      <Callout title="Une boucle vertueuse résultat puis remédiation" tone="lime">
        Après chaque évaluation, le stagiaire voit sa correction détaillée. En cas d'échec, la plateforme lui propose
        automatiquement de revoir les leçons concernées : l'erreur devient un point d'entrée vers la bonne ressource.
      </Callout>

      <Text style={[s.h2, { marginTop: 10 }]}>Le parcours type d'un stagiaire</Text>
      <View style={{ marginTop: 9 }}>
        <Step n="1" title="Entrée & signatures" text="Inscription, acceptation et signature des documents obligatoires, puis test de positionnement." />
        <Step n="2" title="Tableau de bord" text="Le stagiaire arrive sur un écran qui lui indique précisément le prochain module à reprendre." />
        <Step n="3" title="Apprentissage" text="Leçons en timeline, vidéos d'introduction, contenu riche, validation de chaque leçon." />
        <Step n="4" title="Évaluation" text="Quiz d'entraînement (correction immédiate) puis examen blanc en conditions réelles." />
        <Step n="5" title="Résultat & remédiation" text="Célébration calibrée selon le score, correction détaillée, leçons à revoir en cas d'échec." />
        <Step n="6" title="Validation" text="Attestation par bloc acquis ; certificat final lorsque tous les blocs sont validés." />
      </View>

      <Callout title="Gamification non infantilisante" tone="navy">
        Points d'expérience, rangs (Débutant à Master), badges et série de connexion récompensent la régularité
        et l'effort, sans transformer la formation en jeu : l'objectif reste la réussite à l'examen.
      </Callout>
    </Page>
  );
}

// 05 — Qualiopi
function ConfRow({ exigence, reponse }: { exigence: string; reponse: string }) {
  return (
    <View style={{ flexDirection: "row", borderTopWidth: 0.5, borderTopColor: C.border, paddingVertical: 7 }}>
      <View style={{ width: 16, alignItems: "center", paddingTop: 1 }}>
        <View style={{ width: 8, height: 8, borderRadius: 4, backgroundColor: C.lime700 }} />
      </View>
      <Text style={{ width: 150, fontSize: 8.4, color: C.navy, fontFamily: "Helvetica-Bold" }}>{exigence}</Text>
      <Text style={{ flex: 1, fontSize: 8.4, color: C.slate, lineHeight: 1.45 }}>{reponse}</Text>
    </View>
  );
}

function Sec05() {
  return (
    <Page size="A4" style={s.pageLight}>
      <Footer />
      <SectionHead
        n="05"
        title="Administratif & conformité Qualiopi"
        intro="L'organisme est certifié Qualiopi (certificat CW202525-4287, BCI France) et déclaré auprès de la DREETS Île-de-France (NDA 11 77 09 47177). La plateforme industrialise la production des preuves attendues : signatures, émargements, documents contractuels, traçabilité et reporting."
      />

      <Text style={s.h2}>Ce qui rend la plateforme conforme</Text>
      <View style={{ marginTop: 6, marginBottom: 12, borderWidth: 0.75, borderColor: C.border, borderRadius: 9, paddingHorizontal: 12, paddingBottom: 4, backgroundColor: C.paper }}>
        <ConfRow exigence="Adaptation à l'entrée" reponse="Test de positionnement avec recommandation de parcours, conservé au dossier du stagiaire." />
        <ConfRow exigence="Signatures obligatoires" reponse="Acceptation et signature horodatées (règlement intérieur, livret d'accueil, CGV), avec empreinte de sécurité, adresse et appareil enregistrés." />
        <ConfRow exigence="Émargement & assiduité" reponse="Signature par demi-journée et contre-signature du formateur en présentiel ; émargement détaillé par leçon avec durée pour la formation à distance." />
        <ConfRow exigence="Documents contractuels" reponse="Conventions de formation, convocations, devis, attestations et certificats générés automatiquement et aux mentions légales à jour." />
        <ConfRow exigence="Suivi & traçabilité" reponse="Journal d'audit des actions sensibles (conservation 5 ans), historique de progression et de correction." />
        <ConfRow exigence="Satisfaction" reponse="Enquêtes à chaud et à froid (90 jours après la fin), avec synthèse et indice de recommandation." />
        <ConfRow exigence="Réclamations & médiation" reponse="Procédure publique en trois étapes avec délais d'engagement, et voie de médiation." />
        <ConfRow exigence="Accessibilité (handicap)" reponse="Référent et contact dédiés, prise en compte des situations de handicap." />
        <ConfRow exigence="Reporting BPF / DGEFP" reponse="Synthèse du Bilan Pédagogique et Financier (mappée sur le CERFA), exports CSV et journal des ventes." />
      </View>

      <View style={{ flexDirection: "row", justifyContent: "space-between" }}>
        <Card style={{ width: "48.5%" }} accent>
          <Text style={s.h3}>RGPD intégré nativement</Text>
          <View style={{ marginTop: 4 }}>
            <Bullet>Recueil et journalisation des consentements</Bullet>
            <Bullet>Export de ses données personnelles (droit d'accès)</Bullet>
            <Bullet>Anonymisation sur demande (droit à l'effacement)</Bullet>
            <Bullet>Journal des accès aux données et registre des demandes</Bullet>
          </View>
        </Card>
        <Card style={{ width: "48.5%" }}>
          <Text style={s.h3}>Gestion administrative</Text>
          <View style={{ marginTop: 4 }}>
            <Bullet>Inscriptions et dossiers par financeur (CPF, OPCO, France Travail, employeur, auto-financement)</Bullet>
            <Bullet>CRM commercial et suivi des prospects</Bullet>
            <Bullet>Entreprises clientes et conventions</Bullet>
            <Bullet>Fondations d'intégration EDOF (CPF) prêtes à activer</Bullet>
          </View>
        </Card>
      </View>

      <Callout title="Une conception orientée preuve" tone="gold">
        Chaque action sensible est horodatée, tracée et protégée. Cette logique (empreintes de sécurité, journaux,
        cloisonnement des données) correspond exactement à ce qu'un auditeur Qualiopi attend : pouvoir prouver,
        à tout moment, ce qui a été fait, par qui et quand.
      </Callout>
    </Page>
  );
}

// 06 — Technique simplifiée
function Sec06() {
  return (
    <Page size="A4" style={s.pageLight}>
      <Footer />
      <SectionHead
        n="06"
        title="La technique, expliquée simplement"
        intro="Cette section vulgarise les fondations techniques de la plateforme, sans jargon. L'idée : montrer que la maison est solide, sûre et prête à grandir."
      />

      <View style={{ flexDirection: "row", flexWrap: "wrap", justifyContent: "space-between" }}>
        <Card style={{ width: "48.5%", marginBottom: 11 }}>
          <Text style={s.h3}>Sécurité des données</Text>
          <Text style={[s.pTight, { marginTop: 3 }]}>
            Chaque utilisateur ne peut accéder qu'à ses propres données : la séparation est appliquée directement dans
            la base de données (et non seulement dans l'écran), ce qui est la garantie la plus forte. Les actions
            sensibles sont protégées et journalisées.
          </Text>
        </Card>
        <Card style={{ width: "48.5%", marginBottom: 11 }}>
          <Text style={s.h3}>Comptes & accès</Text>
          <Text style={[s.pTight, { marginTop: 3 }]}>
            Connexion sécurisée, invitations par e-mail, réinitialisation de mot de passe protégée. Quatre niveaux
            d'accès (stagiaire, formateur, admin, direction) avec des droits précis. Un parcours d'entrée guidé
            (signatures, positionnement) avant l'accès complet.
          </Text>
        </Card>
        <Card style={{ width: "48.5%", marginBottom: 11 }}>
          <Text style={s.h3}>Hébergement & sauvegardes</Text>
          <Text style={[s.pTight, { marginTop: 3 }]}>
            Données hébergées en Europe (centres de données AWS Paris et Francfort, via Supabase), un atout pour la
            confidentialité et le RGPD. Les fichiers (documents, signatures) sont stockés de façon privée et
            sauvegardés.
          </Text>
        </Card>
        <Card style={{ width: "48.5%", marginBottom: 11 }}>
          <Text style={s.h3}>Performances</Text>
          <Text style={[s.pTight, { marginTop: 3 }]}>
            Les pages sont optimisées pour charger vite, même avec beaucoup de contenu : les données sont récupérées
            de façon groupée et les calculs lourds sont délégués à la base. L'expérience reste fluide sur mobile
            comme sur ordinateur.
          </Text>
        </Card>
        <Card style={{ width: "48.5%", marginBottom: 11 }}>
          <Text style={s.h3}>Fiabilité & qualité</Text>
          <Text style={[s.pTight, { marginTop: 3 }]}>
            Le code est testé automatiquement à chaque modification, avec un contrôle d'accessibilité bloquant. Une
            surveillance des erreurs en temps réel permet de détecter et corriger rapidement tout incident.
          </Text>
        </Card>
        <Card style={{ width: "48.5%", marginBottom: 11 }}>
          <Text style={s.h3}>Évolutivité</Text>
          <Text style={[s.pTight, { marginTop: 3 }]}>
            L'architecture est pensée multi-centres : la plateforme peut accueillir d'autres écoles ou financeurs,
            chacun avec son espace, sans tout reconstruire. C'est la base d'un futur modèle SaaS.
          </Text>
        </Card>
      </View>

      <Callout title="La pile technologique, en clair" tone="navy">
        La plateforme s'appuie sur des technologies modernes et éprouvées, utilisées par les plus grandes entreprises du
        web : Next.js et React (interface rapide et fluide), Supabase (base de données et sécurité), Tailwind CSS
        (design cohérent). Concrètement : un produit rapide, sûr, et facile à faire évoluer.
      </Callout>
    </Page>
  );
}

// 07 — Design & UX
function Sec07() {
  return (
    <Page size="A4" style={s.pageLight}>
      <Footer />
      <SectionHead
        n="07"
        title="Design & expérience utilisateur"
        intro="L'interface vise un niveau de finition rare dans la formation en ligne, dans l'esprit des meilleurs produits du web (Apple, Stripe, Linear). Le soin du détail sert l'apprentissage : une expérience agréable donne envie de revenir."
      />
      <View style={{ flexDirection: "row", flexWrap: "wrap", justifyContent: "space-between" }}>
        <Card style={{ width: "48.5%", marginBottom: 11 }}>
          <Text style={s.h3}>Un design system cohérent</Text>
          <Text style={[s.pTight, { marginTop: 3 }]}>
            Une charte documentée (couleurs de marque navy et vert signal, typographies, ombres, composants) garantit
            une apparence homogène sur tous les écrans, du cours public au back-office.
          </Text>
        </Card>
        <Card style={{ width: "48.5%", marginBottom: 11 }}>
          <Text style={s.h3}>Animations premium</Text>
          <Text style={[s.pTight, { marginTop: 3 }]}>
            Des transitions douces et rapides (courbe d'animation unifiée), des célébrations à la réussite (confettis,
            anneaux de score), un retour visuel immédiat à chaque action. Le tout reste discret et jamais gênant.
          </Text>
        </Card>
        <Card style={{ width: "48.5%", marginBottom: 11 }}>
          <Text style={s.h3}>Responsive & mobile</Text>
          <Text style={[s.pTight, { marginTop: 3 }]}>
            L'interface s'adapte à toutes les tailles d'écran. Sur mobile, une navigation dédiée et des listes
            optimisées garantissent le confort, y compris pour réviser dans les transports.
          </Text>
        </Card>
        <Card style={{ width: "48.5%", marginBottom: 11 }}>
          <Text style={s.h3}>Accessibilité</Text>
          <Text style={[s.pTight, { marginTop: 3 }]}>
            Liens d'évitement, navigation au clavier, respect des préférences de réduction de mouvement, contrastes
            vérifiés. Un contrôle automatique bloque toute régression d'accessibilité.
          </Text>
        </Card>
        <Card style={{ width: "48.5%", marginBottom: 11 }}>
          <Text style={s.h3}>Navigation efficace</Text>
          <Text style={[s.pTight, { marginTop: 3 }]}>
            Menu latéral organisé, palette de commandes au clavier pour aller partout en deux touches, fil d'Ariane,
            recherche intégrée. Le back-office est conçu pour la rapidité d'usage au quotidien.
          </Text>
        </Card>
        <Card style={{ width: "48.5%", marginBottom: 11 }}>
          <Text style={s.h3}>Mode clair & sombre</Text>
          <Text style={[s.pTight, { marginTop: 3 }]}>
            Un mode sombre soigné est disponible, ainsi qu'une mise en page d'impression dédiée pour les exports PDF
            administratifs. L'interface est entièrement en français (et prête pour l'anglais).
          </Text>
        </Card>
      </View>
      <Callout title="Le détail qui change tout" tone="lime">
        Les barres de progression se remplissent au défilement, les sous-menus se déroulent en souplesse, le sélecteur
        de date se remplit au clavier comme au calendrier. Ces dizaines de micro-attentions, invisibles une à une,
        produisent ensemble une impression de qualité et de sérieux.
      </Callout>
    </Page>
  );
}

// 08 — Analytics
function Sec08() {
  return (
    <Page size="A4" style={s.pageLight}>
      <Footer />
      <SectionHead
        n="08"
        title="Analytics & pilotage"
        intro="La plateforme transforme l'activité en indicateurs clairs pour décider : qui progresse, qui décroche, ce qui se vend, et ce qui doit être amélioré."
      />
      <View style={{ flexDirection: "row", flexWrap: "wrap", justifyContent: "space-between", marginBottom: 6 }}>
        <KpiTile value="Temps réel" label="Tableaux de bord" />
        <KpiTile value="Funnel" label="Conversion des leads" />
        <KpiTile value="À risque" label="Stagiaires en alerte" />
        <KpiTile value="Par formation" label="Chiffre d'affaires" />
        <KpiTile value="Satisfaction" label="Enquêtes & NPS" />
        <KpiTile value="Exports" label="CSV & BPF" />
      </View>
      <View style={{ flexDirection: "row", justifyContent: "space-between", marginTop: 4 }}>
        <Card style={{ width: "48.5%" }}>
          <Text style={s.h3}>Pilotage pédagogique</Text>
          <View style={{ marginTop: 4 }}>
            <Bullet>Progression individuelle et par groupe</Bullet>
            <Bullet>Détection des stagiaires en difficulté et alertes d'inactivité</Bullet>
            <Bullet>Taux de réussite par module et par formation</Bullet>
            <Bullet>Suivi des corrections en attente</Bullet>
          </View>
        </Card>
        <Card style={{ width: "48.5%" }}>
          <Text style={s.h3}>Pilotage commercial & qualité</Text>
          <View style={{ marginTop: 4 }}>
            <Bullet>Entonnoir de conversion des prospects (CRM)</Bullet>
            <Bullet>Revenus par formation et par offre</Bullet>
            <Bullet>Sources d'acquisition et performance des campagnes</Bullet>
            <Bullet>Satisfaction, recommandation et indicateurs Qualiopi</Bullet>
          </View>
        </Card>
      </View>
      <Callout title="De la donnée à la décision" tone="navy">
        Les calculs lourds sont préparés côté base de données, ce qui rend les tableaux de bord rapides et fiables.
        Les exports permettent de préparer le Bilan Pédagogique et Financier et de partager les chiffres avec les
        financeurs en quelques clics.
      </Callout>
    </Page>
  );
}

// 09 — Vision
function VisionItem({ title, text }: { title: string; text: string }) {
  return (
    <View style={{ width: "48.5%", marginBottom: 10, flexDirection: "row" }}>
      <View style={{ width: 7, height: 7, borderRadius: 4, backgroundColor: C.lime, marginTop: 3, marginRight: 8 }} />
      <View style={{ flex: 1 }}>
        <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 9.5, color: C.white }}>{title}</Text>
        <Text style={{ fontSize: 8.5, color: C.whiteDim, marginTop: 2, lineHeight: 1.45 }}>{text}</Text>
      </View>
    </View>
  );
}

function Sec09() {
  return (
    <Page size="A4" style={s.pageDark}>
      <Footer />
      <View style={{ flexDirection: "row", alignItems: "center", marginBottom: 6 }}>
        <View style={{ backgroundColor: "rgba(159,226,32,0.14)", borderRadius: 6, paddingVertical: 3, paddingHorizontal: 7, marginRight: 8 }}>
          <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 8.5, color: C.lime, letterSpacing: 1 }}>SECTION 09</Text>
        </View>
        <View style={{ flex: 1, height: 0.75, backgroundColor: C.borderDark }} />
      </View>
      <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 21, color: C.white, letterSpacing: -0.3, lineHeight: 1.2 }}>Vision & perspectives</Text>
      <Text style={{ fontSize: 9.5, color: C.whiteDim, marginTop: 9, maxWidth: 460, lineHeight: 1.55 }}>
        La plateforme est déjà une base solide. Sa conception ouvre des perspectives concrètes pour les prochaines étapes,
        sans réécriture lourde.
      </Text>

      <View style={{ flexDirection: "row", flexWrap: "wrap", justifyContent: "space-between", marginTop: 18 }}>
        <VisionItem title="IA pédagogique étendue" text="Tuteur enrichi, recommandations de révision personnalisées et génération de questions à grande échelle." />
        <VisionItem title="Correction intelligente" text="Assistance à la correction des copies de plus en plus fine, le formateur gardant la décision finale." />
        <VisionItem title="SaaS multi-écoles" text="Ouvrir la plateforme à d'autres organismes, chacun avec sa marque et son espace (modèle white-label)." />
        <VisionItem title="CPF & EDOF" text="Activation de l'intégration EDOF (Mon Compte Formation) déjà préparée côté technique." />
        <VisionItem title="Application mobile" text="Une expérience mobile native pour réviser et s'entraîner hors connexion." />
        <VisionItem title="Automatisations" text="Relances, convocations et rapports envoyés automatiquement aux bons moments." />
        <VisionItem title="Prédictions IA" text="Anticiper le risque de décrochage et déclencher un accompagnement avant l'échec." />
        <VisionItem title="Qualiopi avancé" text="Tableau de bord de conformité en continu et préparation automatisée des audits." />
      </View>

      <View style={{ marginTop: 14, backgroundColor: C.navy2, borderRadius: 12, padding: 16, borderWidth: 0.75, borderColor: C.borderDark }}>
        <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 12, color: C.lime }}>En résumé</Text>
        <Text style={{ fontSize: 9.5, color: C.whiteDim, marginTop: 5, lineHeight: 1.55 }}>
          Une plateforme déjà complète, sécurisée et conforme, conçue pour la réussite des stagiaires et la sérénité de
          l'organisme, avec un chemin de croissance clair vers un produit multi-écoles.
        </Text>
      </View>
    </Page>
  );
}

// ─── DOS / 4e de couverture ──────────────────────────────────────────
function BackCover() {
  return (
    <Page size="A4" style={s.pageDark}>
      <View style={{ position: "absolute", bottom: 0, left: 0, right: 0, height: 6, backgroundColor: C.lime }} />
      <View style={{ flexDirection: "row", alignItems: "center", marginTop: 6 }}>
        <Mark size={32} />
        <View style={{ marginLeft: 10 }}>
          <Wordmark light size={13} />
        </View>
      </View>

      <View style={{ flexGrow: 1, justifyContent: "center" }}>
        <Text style={[s.eyebrow, s.eyebrowOnDark]}>Merci</Text>
        <Text style={{ fontFamily: "Helvetica-Bold", fontSize: 26, color: C.white, marginTop: 10, maxWidth: 420, lineHeight: 1.15 }}>
          Une école moderne, mesurable et conforme.
        </Text>
        <Text style={{ fontSize: 10, color: C.whiteDim, marginTop: 12, maxWidth: 400, lineHeight: 1.55 }}>
          Ce dossier est une synthèse réalisée à partir d'un audit complet de la plateforme (technique, expérience,
          pédagogie et conformité). Il peut être présenté à des clients, des écoles partenaires, des financeurs ou des
          investisseurs.
        </Text>
      </View>

      <View style={{ borderTopWidth: 0.75, borderTopColor: C.borderDark, paddingTop: 14 }}>
        <View style={{ flexDirection: "row", justifyContent: "space-between" }}>
          <View style={{ width: "48%" }}>
            <Text style={{ fontSize: 8.5, color: C.white, fontFamily: "Helvetica-Bold", marginBottom: 4 }}>Organisme</Text>
            <Text style={{ fontSize: 8, color: C.whiteDim, lineHeight: 1.5 }}>MA FORMATION TRANSPORT (SAS)</Text>
            <Text style={{ fontSize: 8, color: C.whiteDim, lineHeight: 1.5 }}>39 Avenue des Sablons Bouillants, 77100 Meaux</Text>
            <Text style={{ fontSize: 8, color: C.whiteDim, lineHeight: 1.5 }}>SIRET 908 851 280 00028 · APE 8559B</Text>
          </View>
          <View style={{ width: "48%" }}>
            <Text style={{ fontSize: 8.5, color: C.white, fontFamily: "Helvetica-Bold", marginBottom: 4 }}>Conformité & contact</Text>
            <Text style={{ fontSize: 8, color: C.whiteDim, lineHeight: 1.5 }}>NDA DREETS 11 77 09 47177 · Qualiopi CW202525-4287</Text>
            <Text style={{ fontSize: 8, color: C.whiteDim, lineHeight: 1.5 }}>contact@maformationtransport.fr · 01 60 09 54 47</Text>
            <Text style={{ fontSize: 8, color: C.whiteDim, lineHeight: 1.5 }}>maformationtransport.fr</Text>
          </View>
        </View>
        <Text style={{ fontSize: 7, color: C.whiteFaint, marginTop: 12 }}>
          Document confidentiel · Édition Mai 2026 · La certification Qualiopi est délivrée à l'organisme de formation ; la plateforme en outille la production des preuves.
        </Text>
      </View>
    </Page>
  );
}

// ─── DOCUMENT ────────────────────────────────────────────────────────
function Dossier() {
  return (
    <Document
      title="Dossier de présentation — MA FORMATION TRANSPORT"
      author="MA FORMATION TRANSPORT"
      subject="Présentation de la plateforme e-learning (audit complet)"
      creator="MA FORMATION TRANSPORT"
    >
      <Cover />
      <TocPage />

      <Divider n="01" title="Présentation générale" sub="Le concept, la plateforme, le catalogue de formations, les utilisateurs et la vision globale." points={["L'école 100 % digitale du transport", "Une plateforme, quatre publics", "Huit formations métier", "Une vision multi-écoles"]} />
      <Sec01 />

      <Divider n="02" title="Les rôles utilisateurs" sub="Quatre profils, quatre espaces, des droits cloisonnés au niveau de la base de données." points={["Stagiaire : apprendre et progresser", "Formateur : encadrer et corriger", "Admin : gérer l'organisme", "Super-admin : superviser et sécuriser"]} />
      <Sec02 />

      <Divider n="03" title="Fonctionnalités principales" sub="Pour chaque brique : objectif, fonctionnement et bénéfices métier, pédagogique et administratif." points={["Apprentissage adaptatif", "Évaluations QCM et rédigées", "IA d'aide à la correction", "Conformité et documents"]} />
      <Sec03 />

      <Divider n="04" title="La logique pédagogique" sub="Un dispositif structuré par les référentiels officiels, de l'évaluation initiale à la certification." points={["Blocs, modules, leçons", "QCM, QR, examens blancs", "Progression et déverrouillage", "Gamification et remédiation"]} />
      <Sec04 />

      <Divider n="05" title="Administratif & Qualiopi" sub="La plateforme industrialise la production des preuves attendues d'un organisme de formation certifié." points={["Signatures horodatées", "Émargement présentiel et FOAD", "Documents contractuels", "Traçabilité, RGPD, BPF"]} />
      <Sec05 />

      <Divider n="06" title="La technique, simplement" sub="Les fondations de la plateforme expliquées sans jargon, pour un lecteur non technique." points={["Sécurité par la base de données", "Hébergement européen", "Performances et fiabilité", "Prête à grandir"]} />
      <Sec06 />

      <Divider n="07" title="Design & expérience" sub="Une interface premium au service de l'apprentissage, dans l'esprit des meilleurs produits du web." points={["Design system cohérent", "Animations soignées", "Responsive et accessible", "Navigation efficace"]} />
      <Sec07 />

      <Divider n="08" title="Analytics & pilotage" sub="Transformer l'activité en indicateurs clairs pour décider et rendre compte." points={["Progression et risque", "Conversion et revenus", "Satisfaction et qualité", "Exports et BPF"]} />
      <Sec08 />

      <Sec09 />
      <BackCover />
    </Document>
  );
}

// ─── RENDU ───────────────────────────────────────────────────────────
const OUT = "livraison/dossier-premium-mft.pdf";
renderToFile(<Dossier />, OUT)
  .then(() => {
    // eslint-disable-next-line no-console
    console.log(`✓ PDF généré : ${OUT}`);
  })
  .catch((e) => {
    // eslint-disable-next-line no-console
    console.error("Échec génération PDF :", e);
    process.exit(1);
  });
