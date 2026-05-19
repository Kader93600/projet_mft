// =====================================================================
// Pitch Deck — Dossier de présentation MA FORMATION TRANSPORT
// =====================================================================
// PDF premium type SaaS moderne (Stripe / Linear / Vercel) pour
// présenter la plateforme à un client, investisseur ou partenaire.
//
// Génération :
//   npx tsx scripts/generate-pitch-deck.ts
//
// Sortie : scripts/output/MFT-Pitch-Deck-v1.pdf
// =====================================================================

import {
  Document,
  Page,
  Text,
  View,
  StyleSheet,
  renderToFile,
  Svg,
  Path,
  Circle,
  Rect,
  Line,
  G,
} from "@react-pdf/renderer";
import React from "react";
import { mkdirSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const OUTPUT = resolve(__dirname, "output", "MFT-Pitch-Deck-v1.pdf");
mkdirSync(dirname(OUTPUT), { recursive: true });

// ─── Palette MFT ─────────────────────────────────────────────────────
const NAVY_950 = "#0B0E2A";
const NAVY_900 = "#0E1240";
const NAVY_800 = "#161B57";
const NAVY_700 = "#1F267A";
const BRAND = "#2530D9";
const GOLD = "#F5B100";
const GOLD_DARK = "#D97706";
const SIGNAL = "#9FE220";
const SIGNAL_DARK = "#7BB113";
const IVORY = "#FAF8F4";
const SLATE_900 = "#0F172A";
const SLATE_700 = "#334155";
const SLATE_500 = "#64748B";
const SLATE_300 = "#CBD5E1";
const SLATE_100 = "#F1F5F9";
const SLATE_50 = "#F8FAFC";
const WHITE = "#FFFFFF";
const EMERALD = "#10B981";
const ROSE = "#E11D48";
const AMBER = "#D97706";
const VIOLET = "#7C3AED";

const C = React.createElement;

// ─── Logo SVG ────────────────────────────────────────────────────────
function Logo({ size = 48, dark = false }: { size?: number; dark?: boolean }) {
  const stroke = dark ? WHITE : NAVY_900;
  const road = SIGNAL;
  return C(
    Svg,
    { width: size, height: size, viewBox: "0 0 64 64" },
    C(Circle, {
      cx: 32, cy: 32, r: 26,
      stroke, strokeWidth: 3, fill: "none",
    }),
    // Toque
    C(Path, {
      d: "M 22 26 L 32 22 L 42 26 L 32 30 Z",
      fill: stroke,
    }),
    C(Rect, { x: 31, y: 26, width: 1.5, height: 6, fill: stroke }),
    // Route en perspective
    C(Path, {
      d: "M 22 46 L 26 36 L 38 36 L 42 46 Z",
      fill: road,
    }),
    // Lignes de route
    C(Line, {
      x1: 30, y1: 38, x2: 31, y2: 44,
      stroke: WHITE, strokeWidth: 0.8, strokeDasharray: "1 1.5",
    }),
    C(Line, {
      x1: 34, y1: 38, x2: 33, y2: 44,
      stroke: WHITE, strokeWidth: 0.8, strokeDasharray: "1 1.5",
    })
  );
}

// ─── Styles globaux ──────────────────────────────────────────────────
const s = StyleSheet.create({
  // Pages
  pageDefault: {
    backgroundColor: IVORY,
    padding: 48,
    fontFamily: "Helvetica",
    color: SLATE_900,
    fontSize: 11,
  },
  pageCover: {
    backgroundColor: NAVY_950,
    color: WHITE,
    fontFamily: "Helvetica",
    padding: 0,
  },
  pageSection: {
    backgroundColor: NAVY_900,
    color: WHITE,
    fontFamily: "Helvetica",
    padding: 0,
  },

  // Header de page
  pageHeader: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginBottom: 32,
    paddingBottom: 12,
    borderBottomWidth: 0.5,
    borderBottomColor: SLATE_300,
  },
  pageHeaderLeft: { flexDirection: "row", alignItems: "center", gap: 8 },
  pageHeaderBrand: {
    fontSize: 9, fontWeight: "bold", letterSpacing: 2,
    color: NAVY_900, textTransform: "uppercase",
  },
  pageHeaderChapter: {
    fontSize: 9, color: SLATE_500, letterSpacing: 1,
    textTransform: "uppercase",
  },

  // Eyebrow + titre + sous-titre
  eyebrow: {
    fontSize: 9, fontWeight: "bold", letterSpacing: 2,
    color: GOLD_DARK, textTransform: "uppercase", marginBottom: 8,
  },
  h1: {
    fontSize: 32, fontWeight: "bold", color: NAVY_900,
    marginBottom: 8, letterSpacing: -0.5,
  },
  h2: {
    fontSize: 22, fontWeight: "bold", color: NAVY_900,
    marginBottom: 6, letterSpacing: -0.3,
  },
  h3: {
    fontSize: 14, fontWeight: "bold", color: NAVY_900,
    marginBottom: 4,
  },
  lead: {
    fontSize: 13, color: SLATE_700, lineHeight: 1.55,
    marginBottom: 16,
  },
  body: {
    fontSize: 10.5, color: SLATE_700, lineHeight: 1.55,
  },
  small: { fontSize: 9, color: SLATE_500 },

  // Cards
  card: {
    backgroundColor: WHITE,
    borderRadius: 10,
    padding: 16,
    borderWidth: 0.5,
    borderColor: SLATE_300,
  },
  cardElevated: {
    backgroundColor: WHITE,
    borderRadius: 12,
    padding: 18,
    borderWidth: 0.5,
    borderColor: SLATE_300,
    // pas de boxShadow dans react-pdf, on simule avec une bordure colorée
  },
  cardBrand: {
    backgroundColor: NAVY_900,
    color: WHITE,
    borderRadius: 12,
    padding: 18,
  },
  cardGold: {
    backgroundColor: "#FEF3C7",
    borderRadius: 12,
    padding: 18,
    borderWidth: 0.5,
    borderColor: GOLD,
  },

  // Pied de page
  pageFooter: {
    position: "absolute",
    bottom: 24,
    left: 48,
    right: 48,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingTop: 8,
    borderTopWidth: 0.5,
    borderTopColor: SLATE_300,
  },
  pageFooterText: { fontSize: 8, color: SLATE_500 },
});

// ─── Composants réutilisables ────────────────────────────────────────

function PageHeader({ chapter }: { chapter: string }) {
  return C(
    View,
    { style: s.pageHeader },
    C(
      View,
      { style: s.pageHeaderLeft },
      C(Logo, { size: 20 }),
      C(Text, { style: s.pageHeaderBrand }, "MA FORMATION TRANSPORT")
    ),
    C(Text, { style: s.pageHeaderChapter }, chapter)
  );
}

function PageFooter({ pageNo, total }: { pageNo: number; total: number }) {
  return C(
    View,
    { style: s.pageFooter, fixed: true },
    C(Text, { style: s.pageFooterText }, "MFT · Dossier de présentation · 2026"),
    C(
      Text,
      { style: s.pageFooterText },
      `${pageNo} / ${total}`
    )
  );
}

function Eyebrow({ children, color = GOLD_DARK }: { children: string; color?: string }) {
  return C(
    Text,
    { style: [s.eyebrow, { color }] },
    children
  );
}

// Card avec bordure latérale de couleur (style Linear / Notion)
function FeatureCard({
  title,
  description,
  accent = GOLD,
  size = "default",
}: {
  title: string;
  description: string;
  accent?: string;
  size?: "default" | "small";
}) {
  const padding = size === "small" ? 12 : 16;
  const titleSize = size === "small" ? 11 : 13;
  const bodySize = size === "small" ? 9 : 10.5;
  return C(
    View,
    {
      style: {
        flexDirection: "row",
        backgroundColor: WHITE,
        borderRadius: 8,
        borderWidth: 0.5,
        borderColor: SLATE_300,
        overflow: "hidden",
        minHeight: size === "small" ? 60 : 80,
      },
    },
    C(View, {
      style: {
        width: 4,
        backgroundColor: accent,
      },
    }),
    C(
      View,
      { style: { flex: 1, padding } },
      C(
        Text,
        { style: { fontSize: titleSize, fontWeight: "bold", color: NAVY_900, marginBottom: 4 } },
        title
      ),
      C(
        Text,
        { style: { fontSize: bodySize, color: SLATE_700, lineHeight: 1.5 } },
        description
      )
    )
  );
}

// Stat card (KPI)
function StatCard({
  value,
  label,
  hint,
  color = NAVY_900,
}: {
  value: string;
  label: string;
  hint?: string;
  color?: string;
}) {
  return C(
    View,
    {
      style: {
        backgroundColor: WHITE,
        borderRadius: 10,
        padding: 16,
        borderWidth: 0.5,
        borderColor: SLATE_300,
        flex: 1,
      },
    },
    C(
      Text,
      {
        style: {
          fontSize: 28,
          fontWeight: "bold",
          color,
          letterSpacing: -0.5,
        },
      },
      value
    ),
    C(
      Text,
      {
        style: {
          fontSize: 9,
          color: SLATE_500,
          textTransform: "uppercase",
          letterSpacing: 1.2,
          marginTop: 4,
        },
      },
      label
    ),
    hint
      ? C(
          Text,
          { style: { fontSize: 8, color: SLATE_500, marginTop: 6 } },
          hint
        )
      : null
  );
}

// Badge coloré
function Badge({ children, color = NAVY_900, bg }: { children: string; color?: string; bg?: string }) {
  return C(
    View,
    {
      style: {
        backgroundColor: bg ?? "rgba(245, 177, 0, 0.15)",
        paddingHorizontal: 8,
        paddingVertical: 3,
        borderRadius: 4,
        alignSelf: "flex-start",
      },
    },
    C(
      Text,
      {
        style: {
          fontSize: 8,
          fontWeight: "bold",
          color,
          textTransform: "uppercase",
          letterSpacing: 1,
        },
      },
      children
    )
  );
}

// Bullet list item
function Bullet({ children, color = GOLD }: { children: string; color?: string }) {
  return C(
    View,
    { style: { flexDirection: "row", marginBottom: 6 } },
    C(
      View,
      {
        style: {
          width: 4,
          height: 4,
          borderRadius: 2,
          backgroundColor: color,
          marginRight: 8,
          marginTop: 6,
        },
      }
    ),
    C(
      Text,
      { style: { flex: 1, fontSize: 10.5, color: SLATE_700, lineHeight: 1.5 } },
      children
    )
  );
}

// ─── PAGE 1 — COUVERTURE ─────────────────────────────────────────────
function Cover() {
  return C(
    Page,
    { size: "A4", style: s.pageCover },
    // Fond avec dégradé simulé (rectangles superposés)
    C(View, {
      style: {
        position: "absolute", top: 0, left: 0, right: 0, bottom: 0,
        backgroundColor: NAVY_950,
      },
    }),
    // Accent gold en haut
    C(View, {
      style: {
        position: "absolute",
        top: 0,
        left: 0,
        right: 0,
        height: 4,
        backgroundColor: GOLD,
      },
    }),
    // Accent signal en bas
    C(View, {
      style: {
        position: "absolute",
        bottom: 0,
        left: 0,
        right: 0,
        height: 4,
        backgroundColor: SIGNAL,
      },
    }),
    // Cercles décoratifs
    C(View, {
      style: {
        position: "absolute",
        top: -80, right: -80,
        width: 250, height: 250,
        borderRadius: 125,
        backgroundColor: NAVY_800,
        opacity: 0.5,
      },
    }),
    C(View, {
      style: {
        position: "absolute",
        bottom: -100, left: -50,
        width: 320, height: 320,
        borderRadius: 160,
        backgroundColor: NAVY_800,
        opacity: 0.3,
      },
    }),
    // Contenu
    C(
      View,
      { style: { padding: 64, flex: 1, justifyContent: "space-between" } },
      // Header logo
      C(
        View,
        { style: { flexDirection: "row", alignItems: "center", gap: 12 } },
        C(Logo, { size: 56, dark: true }),
        C(
          View,
          {},
          C(
            Text,
            {
              style: {
                fontSize: 11,
                color: GOLD,
                fontWeight: "bold",
                letterSpacing: 3,
                textTransform: "uppercase",
              },
            },
            "MA FORMATION"
          ),
          C(
            Text,
            {
              style: {
                fontSize: 11,
                color: SIGNAL,
                fontWeight: "bold",
                letterSpacing: 3,
                textTransform: "uppercase",
                marginTop: 2,
              },
            },
            "TRANSPORT"
          )
        )
      ),
      // Bloc central
      C(
        View,
        { style: { gap: 16 } },
        C(
          Text,
          {
            style: {
              fontSize: 9,
              color: GOLD,
              fontWeight: "bold",
              letterSpacing: 3,
              textTransform: "uppercase",
            },
          },
          "Dossier de présentation · 2026"
        ),
        C(
          Text,
          {
            style: {
              fontSize: 48,
              color: WHITE,
              fontWeight: "bold",
              letterSpacing: -1.5,
              lineHeight: 1.05,
            },
          },
          "L'école qui forme"
        ),
        C(
          Text,
          {
            style: {
              fontSize: 48,
              color: SIGNAL,
              fontWeight: "bold",
              letterSpacing: -1.5,
              lineHeight: 1.05,
            },
          },
          "les pros du transport."
        ),
        C(
          Text,
          {
            style: {
              fontSize: 14,
              color: SLATE_300,
              lineHeight: 1.6,
              marginTop: 8,
              maxWidth: 460,
            },
          },
          "Plateforme e-learning haut de gamme pour la préparation aux titres professionnels du secteur transport en France. Multi-formations, multi-rôles, multi-tenant. IA pédagogique. Conforme Qualiopi et RNCP."
        )
      ),
      // Footer
      C(
        View,
        { style: { gap: 4 } },
        C(
          View,
          {
            style: {
              flexDirection: "row",
              gap: 24,
              paddingTop: 16,
              borderTopWidth: 0.5,
              borderTopColor: NAVY_700,
            },
          },
          C(StatLite, { value: "8", label: "Formations" }),
          C(StatLite, { value: "300+", label: "Leçons" }),
          C(StatLite, { value: "1500+", label: "Questions" }),
          C(StatLite, { value: "Premium", label: "IA Tuteur" })
        ),
        C(
          Text,
          {
            style: {
              fontSize: 9,
              color: SLATE_500,
              marginTop: 24,
              letterSpacing: 1,
            },
          },
          "maformationtransport.fr · v1.0 · Confidentiel"
        )
      )
    )
  );
}

function StatLite({ value, label }: { value: string; label: string }) {
  return C(
    View,
    {},
    C(
      Text,
      {
        style: {
          fontSize: 24,
          color: WHITE,
          fontWeight: "bold",
          letterSpacing: -0.5,
        },
      },
      value
    ),
    C(
      Text,
      {
        style: {
          fontSize: 8,
          color: GOLD,
          textTransform: "uppercase",
          letterSpacing: 1.5,
          marginTop: 2,
        },
      },
      label
    )
  );
}

// ─── PAGE 2 — SOMMAIRE ───────────────────────────────────────────────
const TOC = [
  { num: "01", title: "Vision & concept", page: 3 },
  { num: "02", title: "Cible & rôles utilisateurs", page: 5 },
  { num: "03", title: "Catalogue des formations", page: 6 },
  { num: "04", title: "Architecture de la plateforme", page: 8 },
  { num: "05", title: "Approche pédagogique", page: 10 },
  { num: "06", title: "Import PDF intelligent", page: 13 },
  { num: "07", title: "Design & expérience utilisateur", page: 14 },
  { num: "08", title: "Fonctionnalités avancées", page: 16 },
  { num: "09", title: "Sécurité, RGPD & conformité", page: 18 },
  { num: "10", title: "Stack technique", page: 19 },
  { num: "11", title: "Vision business & potentiel SaaS", page: 21 },
  { num: "12", title: "Roadmap & évolutions futures", page: 23 },
  { num: "13", title: "Forces du projet & conclusion", page: 24 },
];

function TocPage() {
  return C(
    Page,
    { size: "A4", style: s.pageDefault },
    C(PageHeader, { chapter: "Sommaire" }),
    C(Eyebrow, {}, "Table des matières"),
    C(Text, { style: [s.h1, { marginBottom: 32 }] }, "Plan du document"),
    C(
      View,
      { style: { gap: 4 } },
      ...TOC.map((item) =>
        C(
          View,
          {
            key: item.num,
            style: {
              flexDirection: "row",
              alignItems: "center",
              paddingVertical: 10,
              borderBottomWidth: 0.5,
              borderBottomColor: SLATE_100,
            },
          },
          C(
            Text,
            {
              style: {
                fontSize: 10,
                color: GOLD_DARK,
                fontWeight: "bold",
                width: 40,
                letterSpacing: 1,
              },
            },
            item.num
          ),
          C(
            Text,
            {
              style: {
                fontSize: 13,
                color: NAVY_900,
                fontWeight: "bold",
                flex: 1,
              },
            },
            item.title
          ),
          C(
            Text,
            { style: { fontSize: 10, color: SLATE_500 } },
            `p. ${item.page}`
          )
        )
      )
    ),
    C(PageFooter, { pageNo: 2, total: 26 })
  );
}

// ─── PAGE 3-4 — VISION & CONCEPT ─────────────────────────────────────
function VisionPage() {
  return C(
    Page,
    { size: "A4", style: s.pageDefault },
    C(PageHeader, { chapter: "01 · Vision & concept" }),
    C(Eyebrow, {}, "Notre raison d'être"),
    C(Text, { style: s.h1 }, "Repenser la formation"),
    C(Text, { style: [s.h1, { color: GOLD_DARK, marginTop: -4 }] }, "transport en France."),
    C(
      Text,
      { style: [s.lead, { marginTop: 16, marginBottom: 24 }] },
      "MFT est une plateforme e-learning complète, pensée pour les organismes de formation transport et leurs stagiaires. Elle combine la rigueur Qualiopi, la modernité d'un SaaS B2B et l'intelligence d'un tuteur IA."
    ),
    // 3 colonnes : Problème · Solution · Différence
    C(
      View,
      { style: { flexDirection: "row", gap: 12, marginBottom: 24 } },
      C(
        View,
        { style: { flex: 1 } },
        C(Badge, { color: ROSE, bg: "#FEE2E2" }, "Le problème"),
        C(Text, { style: [s.h3, { marginTop: 8 }] }, "Le marché historique"),
        C(
          Text,
          { style: [s.body, { marginTop: 6 }] },
          "Les centres de formation transport s'appuient sur PowerPoint, classeurs papier, et un suivi pédagogique manuel. Le RNCP exige des preuves de progression que les outils actuels rendent coûteuses à produire."
        )
      ),
      C(
        View,
        { style: { flex: 1 } },
        C(Badge, { color: SIGNAL_DARK, bg: "#ECFCCB" }, "La solution"),
        C(Text, { style: [s.h3, { marginTop: 8 }] }, "MFT, plateforme tout-en-un"),
        C(
          Text,
          { style: [s.body, { marginTop: 6 }] },
          "Modules pédagogiques, quiz auto-corrigés, examens blancs, suivi temps réel, IA tuteur 24/7, et exports Qualiopi en un clic. Le tout aligné sur les référentiels RNCP officiels."
        )
      ),
      C(
        View,
        { style: { flex: 1 } },
        C(Badge, { color: VIOLET, bg: "#EDE9FE" }, "La différence"),
        C(Text, { style: [s.h3, { marginTop: 8 }] }, "Pensé pour le transport"),
        C(
          Text,
          { style: [s.body, { marginTop: 6 }] },
          "Là où les LMS génériques s'adaptent mal, MFT est conçue spécifiquement pour le RNCP transport : GOTRM, Capacité, FIMO/FCO, Taxi/VTC. La verticalisation produit la qualité pédagogique."
        )
      )
    ),
    // Encart Mission
    C(
      View,
      { style: [s.cardBrand, { marginTop: 16 }] },
      C(
        Text,
        {
          style: {
            fontSize: 9,
            color: GOLD,
            fontWeight: "bold",
            letterSpacing: 2,
            textTransform: "uppercase",
            marginBottom: 8,
          },
        },
        "Notre mission"
      ),
      C(
        Text,
        {
          style: {
            fontSize: 16,
            color: WHITE,
            lineHeight: 1.5,
            fontStyle: "italic",
          },
        },
        "« Donner aux organismes de formation transport les outils qu'ils méritent : moderne, fiable, Qualiopi-ready. Et aux stagiaires une expérience d'apprentissage à la hauteur des enjeux professionnels qu'ils préparent. »"
      )
    ),
    C(PageFooter, { pageNo: 3, total: 26 })
  );
}

// ─── PAGE 4 — CIBLE & RÔLES ──────────────────────────────────────────
function RolesPage() {
  return C(
    Page,
    { size: "A4", style: s.pageDefault },
    C(PageHeader, { chapter: "02 · Cible & rôles utilisateurs" }),
    C(Eyebrow, {}, "Qui utilise MFT"),
    C(Text, { style: s.h1 }, "Quatre rôles, un seul produit."),
    C(
      Text,
      { style: [s.lead, { marginTop: 8 }] },
      "Chaque utilisateur entre dans son propre espace dès la connexion. Les permissions sont gérées par Row Level Security au niveau de la base : la sécurité est appliquée même si une route est mal protégée côté client."
    ),
    // 4 cards rôles
    C(
      View,
      { style: { gap: 12, marginTop: 16 } },
      C(RoleCard, {
        title: "Stagiaire",
        subtitle: "L'apprenant — utilisateur principal",
        accent: SIGNAL_DARK,
        accentBg: "#ECFCCB",
        features: [
          "Accès aux modules, leçons et fiches synthèse de sa formation",
          "QCM et QR (questions rédigées) corrigés par IA ou formateur",
          "Examens blancs, timer, anti-triche, statistiques détaillées",
          "Gamification : XP, badges, série de jours, classement",
          "IA tuteur 24/7 (pack Premium), parrainage, fidélité",
          "PWA installable, mode offline pour zones blanches",
        ],
      }),
      C(RoleCard, {
        title: "Formateur",
        subtitle: "Le pédagogue — accompagnement personnalisé",
        accent: BRAND,
        accentBg: "#E0E7FF",
        features: [
          "Tableau de bord des stagiaires attribués",
          "Correction des QR avec proposition IA (Claude Sonnet 4.6)",
          "Validation des notes finales avant publication",
          "Messagerie privée avec ses stagiaires (Pack Medium+)",
          "Sessions présentielles planifiées (Pack Premium)",
        ],
      }),
      C(RoleCard, {
        title: "Administrateur",
        subtitle: "Le gestionnaire — pilotage de l'organisme",
        accent: GOLD_DARK,
        accentBg: "#FEF3C7",
        features: [
          "Gestion complète des stagiaires, formateurs, inscriptions",
          "CRM intégré : pipeline prospects + relances automatiques",
          "Tableau de bord analytics + funnel UTM par canal marketing",
          "Validation des récompenses parrainage, monitoring coûts IA",
          "BPF (Bilan Pédagogique & Financier) auto-généré",
          "Gestion multi-tenant : entreprises clientes & comptes pros",
        ],
      }),
      C(RoleCard, {
        title: "Super Admin",
        subtitle: "Le pilote technique — sécurité et conformité",
        accent: VIOLET,
        accentBg: "#EDE9FE",
        features: [
          "Gestion des rôles et permissions fines (RLS)",
          "Audit log RGPD : qui a fait quoi, quand",
          "Configuration des formations et référentiels RNCP",
          "Override des politiques de sécurité (2FA, sessions)",
        ],
      })
    ),
    C(PageFooter, { pageNo: 4, total: 26 })
  );
}

function RoleCard({
  title,
  subtitle,
  accent,
  accentBg,
  features,
}: {
  title: string;
  subtitle: string;
  accent: string;
  accentBg: string;
  features: string[];
}) {
  return C(
    View,
    {
      style: {
        flexDirection: "row",
        backgroundColor: WHITE,
        borderRadius: 10,
        borderWidth: 0.5,
        borderColor: SLATE_300,
        overflow: "hidden",
      },
    },
    C(View, { style: { width: 5, backgroundColor: accent } }),
    C(
      View,
      { style: { flex: 1, padding: 14 } },
      C(
        View,
        { style: { flexDirection: "row", alignItems: "center", gap: 8, marginBottom: 8 } },
        C(View, {
          style: {
            backgroundColor: accentBg,
            paddingHorizontal: 8,
            paddingVertical: 3,
            borderRadius: 4,
          },
        }, C(Text, {
          style: {
            fontSize: 8,
            fontWeight: "bold",
            color: accent,
            textTransform: "uppercase",
            letterSpacing: 1,
          },
        }, title)),
        C(Text, { style: { fontSize: 10, color: SLATE_500 } }, subtitle)
      ),
      ...features.map((f, i) =>
        C(
          View,
          {
            key: i,
            style: { flexDirection: "row", marginTop: 3 },
          },
          C(Text, { style: { fontSize: 9.5, color: accent, marginRight: 6, marginTop: 0.5 } }, "•"),
          C(
            Text,
            { style: { fontSize: 9.5, color: SLATE_700, flex: 1, lineHeight: 1.5 } },
            f
          )
        )
      )
    )
  );
}

// ─── PAGE 5-6 — FORMATIONS ───────────────────────────────────────────
const FORMATIONS = [
  { code: "GOTRM", title: "Gestionnaire des Opérations de Transport Routier de Marchandises", rncp: "RNCP 40990", level: "Bac+2", duration: "12 mois", color: BRAND, modules: 41, lessons: 230 },
  { code: "Capa ≤3,5t", title: "Capacité de transport léger", rncp: "Capacité DREAL", level: "Pro", duration: "3 mois", color: SIGNAL_DARK, modules: 6, lessons: 48 },
  { code: "ECSR", title: "Enseignant de la Conduite et de la Sécurité Routière", rncp: "RNCP 35846", level: "Bac+2", duration: "12 mois", color: GOLD_DARK, modules: 24, lessons: 145 },
  { code: "ERTV", title: "Enseignant de la Route — Transport de Voyageurs", rncp: "RNCP en cours", level: "Pro", duration: "9 mois", color: VIOLET, modules: 18, lessons: 110 },
  { code: "FIMO/FCO", title: "Formation Initiale Minimale / Continue Obligatoire", rncp: "Obligation légale", level: "Pro", duration: "5 jours / 35h", color: ROSE, modules: 8, lessons: 52 },
  { code: "Taxi / VTC", title: "Préparation à la carte professionnelle Taxi & VTC", rncp: "Examen préfectoral", level: "Pro", duration: "4 mois", color: AMBER, modules: 12, lessons: 78 },
];

function FormationsPage() {
  return C(
    Page,
    { size: "A4", style: s.pageDefault },
    C(PageHeader, { chapter: "03 · Catalogue des formations" }),
    C(Eyebrow, {}, "Catalogue complet"),
    C(Text, { style: s.h1 }, "Multi-formations,"),
    C(Text, { style: [s.h1, { color: GOLD_DARK, marginTop: -4 }] }, "un seul espace stagiaire."),
    C(
      Text,
      { style: [s.lead, { marginTop: 12, marginBottom: 16 }] },
      "MFT couvre les 6 grandes familles de formations transport en France. Le contenu pédagogique est filtré automatiquement selon les enrollments du stagiaire : un Capacité ne voit que ses 6 modules, un GOTRM voit ses 41."
    ),
    C(
      View,
      { style: { gap: 10 } },
      ...FORMATIONS.map((f) =>
        C(
          View,
          {
            key: f.code,
            style: {
              flexDirection: "row",
              backgroundColor: WHITE,
              borderRadius: 10,
              borderWidth: 0.5,
              borderColor: SLATE_300,
              overflow: "hidden",
            },
          },
          C(View, {
            style: {
              width: 80,
              backgroundColor: f.color,
              padding: 12,
              justifyContent: "center",
              alignItems: "center",
            },
          },
            C(Text, { style: { fontSize: 13, fontWeight: "bold", color: WHITE, letterSpacing: 0.5 } }, f.code)),
          C(
            View,
            { style: { flex: 1, padding: 12 } },
            C(Text, { style: { fontSize: 12, fontWeight: "bold", color: NAVY_900, marginBottom: 4 } }, f.title),
            C(
              View,
              { style: { flexDirection: "row", gap: 14, marginTop: 6 } },
              C(MetaItem, { label: "Réf.", value: f.rncp }),
              C(MetaItem, { label: "Niveau", value: f.level }),
              C(MetaItem, { label: "Durée", value: f.duration }),
              C(MetaItem, { label: "Modules", value: String(f.modules) }),
              C(MetaItem, { label: "Leçons", value: String(f.lessons) })
            )
          )
        )
      )
    ),
    // Encart Pack Initial/Medium/Premium
    C(
      View,
      { style: [s.cardGold, { marginTop: 16, flexDirection: "row", gap: 12 }] },
      C(View, { style: { flex: 1 } },
        C(Text, { style: { fontSize: 9, fontWeight: "bold", color: GOLD_DARK, letterSpacing: 1.5, textTransform: "uppercase", marginBottom: 6 } }, "Trois packs par formation"),
        C(Text, { style: { fontSize: 11, color: SLATE_700, lineHeight: 1.5 } },
          "Chaque formation se décline en 3 niveaux : Initial (autonomie + IA correction QR), Medium (formateur attitré + messagerie privée), Premium (sessions présentielles + Zoom + IA tuteur 24/7). Tarifs sur devis selon le financement (CPF, OPCO, employeur, France Travail).")
      ),
      C(View, { style: { flexDirection: "row", gap: 4 } },
        C(PackPill, { name: "INITIAL", color: SIGNAL_DARK }),
        C(PackPill, { name: "MEDIUM", color: BRAND }),
        C(PackPill, { name: "PREMIUM", color: GOLD_DARK })
      )
    ),
    C(PageFooter, { pageNo: 5, total: 26 })
  );
}

function MetaItem({ label, value }: { label: string; value: string }) {
  return C(
    View,
    {},
    C(Text, { style: { fontSize: 7.5, color: SLATE_500, textTransform: "uppercase", letterSpacing: 1 } }, label),
    C(Text, { style: { fontSize: 10, fontWeight: "bold", color: NAVY_900, marginTop: 1 } }, value)
  );
}

function PackPill({ name, color }: { name: string; color: string }) {
  return C(
    View,
    {
      style: {
        backgroundColor: color,
        paddingHorizontal: 10,
        paddingVertical: 10,
        borderRadius: 6,
      },
    },
    C(Text, { style: { fontSize: 9, fontWeight: "bold", color: WHITE, letterSpacing: 1.5 } }, name)
  );
}

// ─── PAGE 7-8 — ARCHITECTURE ─────────────────────────────────────────
function ArchitecturePage() {
  return C(
    Page,
    { size: "A4", style: s.pageDefault },
    C(PageHeader, { chapter: "04 · Architecture" }),
    C(Eyebrow, {}, "Vue d'ensemble système"),
    C(Text, { style: s.h1 }, "Une architecture moderne,"),
    C(Text, { style: [s.h1, { color: GOLD_DARK, marginTop: -4 }] }, "pensée pour le scaling."),
    C(
      Text,
      { style: [s.lead, { marginTop: 12, marginBottom: 16 }] },
      "Stack serverless full-managed : Next.js 14 (App Router) sur Vercel, base PostgreSQL managée chez Supabase, IA Anthropic Claude Sonnet 4.6 + OpenAI embeddings. Zéro DevOps, scaling automatique."
    ),
    // Diagramme architecture (boîtes empilées)
    C(
      View,
      { style: { gap: 10 } },
      // Layer 1 : Client
      C(ArchLayer, {
        name: "Couche utilisateur",
        color: SIGNAL_DARK,
        bg: "#ECFCCB",
        items: ["Navigateur web (PWA)", "App mobile (PWA install)", "Mode offline (Service Worker)"],
      }),
      C(ArchArrow, {}),
      // Layer 2 : Next.js
      C(ArchLayer, {
        name: "Couche application (Vercel)",
        color: BRAND,
        bg: "#E0E7FF",
        items: [
          "Next.js 14 — App Router, Server Components, Server Actions",
          "Auth middleware, i18n (FR/EN), Tailwind CSS",
          "API Routes : Stripe, Resend, IA tuteur, cron jobs",
        ],
      }),
      C(ArchArrow, {}),
      // Layer 3 : Supabase
      C(ArchLayer, {
        name: "Couche données (Supabase)",
        color: GOLD_DARK,
        bg: "#FEF3C7",
        items: [
          "PostgreSQL 15 — 80+ tables, RLS sur toutes les tables sensibles",
          "Storage (vidéos intro, PDFs, exports)",
          "Auth (sessions, OAuth, magic links)",
          "pgvector pour le RAG IA tuteur (896 chunks embeddés)",
        ],
      }),
      C(ArchArrow, {}),
      // Layer 4 : Services externes
      C(ArchLayer, {
        name: "Services externes",
        color: VIOLET,
        bg: "#EDE9FE",
        items: [
          "Anthropic Claude Sonnet 4.6 — chat tuteur RAG + correction QR",
          "OpenAI text-embedding-3-small — vectorisation contenu",
          "Stripe Checkout + Webhooks — paiements & abonnements",
          "Resend — emails transactionnels (confirmations, relances)",
          "Sentry + PostHog (EU) — observabilité & analytics",
        ],
      })
    ),
    C(PageFooter, { pageNo: 6, total: 26 })
  );
}

function ArchLayer({
  name,
  color,
  bg,
  items,
}: {
  name: string;
  color: string;
  bg: string;
  items: string[];
}) {
  return C(
    View,
    {
      style: {
        backgroundColor: WHITE,
        borderRadius: 10,
        borderWidth: 0.5,
        borderColor: color,
        padding: 14,
      },
    },
    C(
      View,
      { style: { flexDirection: "row", alignItems: "center", gap: 8, marginBottom: 8 } },
      C(View, {
        style: {
          backgroundColor: bg,
          paddingHorizontal: 8,
          paddingVertical: 3,
          borderRadius: 4,
        },
      }, C(Text, {
        style: {
          fontSize: 9,
          fontWeight: "bold",
          color,
          textTransform: "uppercase",
          letterSpacing: 1.5,
        },
      }, name))
    ),
    C(
      View,
      { style: { gap: 2 } },
      ...items.map((it, i) =>
        C(
          View,
          { key: i, style: { flexDirection: "row", marginTop: 2 } },
          C(Text, { style: { fontSize: 9, color, marginRight: 6 } }, "▸"),
          C(Text, { style: { fontSize: 10, color: SLATE_700, flex: 1, lineHeight: 1.45 } }, it)
        )
      )
    )
  );
}

function ArchArrow() {
  return C(
    View,
    { style: { alignItems: "center", paddingVertical: 2 } },
    C(Text, { style: { fontSize: 12, color: SLATE_300 } }, "▼")
  );
}

// ─── PAGE 9 — TECH STACK détaillée ───────────────────────────────────
function TechStackPage() {
  return C(
    Page,
    { size: "A4", style: s.pageDefault },
    C(PageHeader, { chapter: "04 · Architecture" }),
    C(Eyebrow, {}, "Détails techniques"),
    C(Text, { style: s.h1 }, "Le stack en détail."),
    C(
      Text,
      { style: [s.lead, { marginTop: 12, marginBottom: 16 }] },
      "Chaque brique a été choisie pour sa qualité, sa documentation et sa pérennité. Pas de framework artisanal, pas de dette technique."
    ),
    C(
      View,
      { style: { flexDirection: "row", gap: 10, marginBottom: 10 } },
      C(TechCol, {
        title: "Frontend",
        accent: SIGNAL_DARK,
        items: [
          { name: "Next.js 14", desc: "App Router, RSC, Server Actions" },
          { name: "React 18", desc: "Strict mode, Suspense" },
          { name: "TypeScript", desc: "Mode strict, zéro any" },
          { name: "Tailwind CSS", desc: "Design system tokens" },
          { name: "next-intl", desc: "i18n FR / EN, 27 namespaces" },
          { name: "Framer Motion", desc: "Animations subtiles" },
        ],
      }),
      C(TechCol, {
        title: "Backend",
        accent: BRAND,
        items: [
          { name: "Supabase", desc: "PostgreSQL 15 managé" },
          { name: "Row Level Security", desc: "Sécurité par défaut" },
          { name: "Edge Functions", desc: "Logique métier serveur" },
          { name: "pgvector", desc: "RAG IA tuteur" },
          { name: "Storage S3-compat.", desc: "Médias et exports" },
          { name: "Auth multi-provider", desc: "Email, magic link, OAuth" },
        ],
      }),
      C(TechCol, {
        title: "IA & DevOps",
        accent: GOLD_DARK,
        items: [
          { name: "Claude Sonnet 4.6", desc: "Tuteur RAG + correction QR" },
          { name: "OpenAI embeddings", desc: "text-embedding-3-small" },
          { name: "Stripe Checkout", desc: "Paiements + webhooks" },
          { name: "Resend", desc: "Emails transactionnels" },
          { name: "Sentry + PostHog EU", desc: "Observability RGPD" },
          { name: "Vercel + GitHub CI", desc: "Deploy auto, sourcemaps" },
        ],
      })
    ),
    // Encart KPIs techniques
    C(
      View,
      { style: { marginTop: 16, flexDirection: "row", gap: 8 } },
      C(StatCard, { value: "100%", label: "TypeScript", hint: "Zéro any, mode strict" }),
      C(StatCard, { value: "<2s", label: "Lighthouse FCP", hint: "Cold start optimisé" }),
      C(StatCard, { value: "9/9", label: "Tests E2E", hint: "Playwright CI" }),
      C(StatCard, { value: "WCAG 2.1 AA", label: "Accessibilité", hint: "Audit Lighthouse" })
    ),
    C(PageFooter, { pageNo: 7, total: 26 })
  );
}

function TechCol({
  title,
  accent,
  items,
}: {
  title: string;
  accent: string;
  items: Array<{ name: string; desc: string }>;
}) {
  return C(
    View,
    {
      style: {
        flex: 1,
        backgroundColor: WHITE,
        borderRadius: 10,
        borderWidth: 0.5,
        borderColor: SLATE_300,
        padding: 14,
      },
    },
    C(Text, {
      style: {
        fontSize: 9,
        fontWeight: "bold",
        color: accent,
        textTransform: "uppercase",
        letterSpacing: 1.5,
        marginBottom: 10,
        paddingBottom: 6,
        borderBottomWidth: 1,
        borderBottomColor: accent,
      },
    }, title),
    C(
      View,
      { style: { gap: 8 } },
      ...items.map((it, i) =>
        C(
          View,
          { key: i },
          C(Text, { style: { fontSize: 10, fontWeight: "bold", color: NAVY_900 } }, it.name),
          C(Text, { style: { fontSize: 8.5, color: SLATE_500, marginTop: 1 } }, it.desc)
        )
      )
    )
  );
}

// ─── PAGE 10-12 — PÉDAGOGIE ──────────────────────────────────────────
function PedagogiePage1() {
  return C(
    Page,
    { size: "A4", style: s.pageDefault },
    C(PageHeader, { chapter: "05 · Approche pédagogique" }),
    C(Eyebrow, {}, "Notre méthode"),
    C(Text, { style: s.h1 }, "Apprendre, s'entraîner,"),
    C(Text, { style: [s.h1, { color: GOLD_DARK, marginTop: -4 }] }, "valider, certifier."),
    C(
      Text,
      { style: [s.lead, { marginTop: 12, marginBottom: 20 }] },
      "Le parcours pédagogique MFT est structuré en 4 phases qui s'enchaînent naturellement, avec des garde-fous pour empêcher le stagiaire de s'égarer ou de griller des étapes."
    ),
    // 4 phases
    C(
      View,
      { style: { gap: 10 } },
      C(PhaseCard, {
        num: "01", phase: "Apprendre",
        title: "Modules pédagogiques détaillés",
        desc: "Chaque formation se décompose en chapitres (modules) et leçons. Contenu Markdown riche : titres, listes, tableaux, callouts, vidéos d'intro, fiches synthèse. Suivi de progression au niveau de la leçon (pas du module).",
        accent: SIGNAL_DARK,
      }),
      C(PhaseCard, {
        num: "02", phase: "S'entraîner",
        title: "QCM et questions rédigées (QR)",
        desc: "Banque de 1500+ questions corrigées. QCM auto-corrigés en temps réel, QR avec proposition IA + validation formateur. Mode pratique illimité, exercices ciblés par module ou par bloc de compétence.",
        accent: BRAND,
      }),
      C(PhaseCard, {
        num: "03", phase: "Valider",
        title: "Examens blancs synthétiques",
        desc: "Examen blanc par bloc de compétence + examen blanc final transversal. Timer réaliste, anti-triche (focus loss, fullscreen), questions tirées aléatoirement de la banque, scoring sur barème officiel RNCP.",
        accent: GOLD_DARK,
      }),
      C(PhaseCard, {
        num: "04", phase: "Certifier",
        title: "Attestations & certificats",
        desc: "Génération automatique d'attestations par bloc validé. Certificat final PDF officiel quand tous les blocs sont validés. Version dorée pour les stagiaires fidèles (2+ certificats finals).",
        accent: VIOLET,
      })
    ),
    C(PageFooter, { pageNo: 8, total: 26 })
  );
}

function PhaseCard({
  num, phase, title, desc, accent,
}: {
  num: string;
  phase: string;
  title: string;
  desc: string;
  accent: string;
}) {
  return C(
    View,
    {
      style: {
        flexDirection: "row",
        backgroundColor: WHITE,
        borderRadius: 10,
        borderWidth: 0.5,
        borderColor: SLATE_300,
        padding: 14,
        gap: 14,
      },
    },
    // Numéro circle
    C(
      View,
      {
        style: {
          width: 48, height: 48,
          borderRadius: 24,
          backgroundColor: accent,
          alignItems: "center",
          justifyContent: "center",
        },
      },
      C(Text, { style: { fontSize: 14, fontWeight: "bold", color: WHITE, letterSpacing: 0.5 } }, num)
    ),
    C(
      View,
      { style: { flex: 1 } },
      C(Text, {
        style: {
          fontSize: 8,
          fontWeight: "bold",
          color: accent,
          letterSpacing: 1.5,
          textTransform: "uppercase",
          marginBottom: 4,
        },
      }, phase),
      C(Text, { style: { fontSize: 13, fontWeight: "bold", color: NAVY_900, marginBottom: 4 } }, title),
      C(Text, { style: { fontSize: 10, color: SLATE_700, lineHeight: 1.5 } }, desc)
    )
  );
}

function PedagogiePage2() {
  return C(
    Page,
    { size: "A4", style: s.pageDefault },
    C(PageHeader, { chapter: "05 · Approche pédagogique" }),
    C(Eyebrow, {}, "Gamification & engagement"),
    C(Text, { style: s.h1 }, "Maintenir la motivation."),
    C(
      Text,
      { style: [s.lead, { marginTop: 12, marginBottom: 16 }] },
      "Un stagiaire qui décroche est un stagiaire qui ne valide pas. MFT intègre une couche de gamification éprouvée, sans tomber dans l'infantilisation : XP, niveaux, badges, séries de jours, classement public anonymisé."
    ),
    // 2 colonnes : gamif + IA
    C(
      View,
      { style: { flexDirection: "row", gap: 12 } },
      // Gauche : Gamification
      C(
        View,
        { style: { flex: 1, gap: 10 } },
        C(Text, { style: s.h2 }, "Gamification"),
        C(FeatureCard, {
          title: "XP & niveaux",
          description: "10 XP par leçon, 20 XP par quiz réussi, 50 XP par examen blanc, 15 XP par score parfait. Niveaux quadratiques (Lvl 5 = 1500 XP).",
          accent: SIGNAL_DARK,
        }),
        C(FeatureCard, {
          title: "Séries de jours",
          description: "Bonus quotidien à la connexion (5 XP) + bonus de série progressif (min(streak × 5, 50) à partir de 3 jours consécutifs).",
          accent: GOLD,
        }),
        C(FeatureCard, {
          title: "Badges & certificats",
          description: "Catalogue de badges (Bronze/Silver/Gold) par catégorie (progression, régularité, excellence, maîtrise). Progression visible sur chaque badge à débloquer.",
          accent: BRAND,
        }),
        C(FeatureCard, {
          title: "Classement public",
          description: "Top 50 anonymisé par initiales. Périodes semaine/mois/total. Opt-out RGPD disponible dans les paramètres de confidentialité.",
          accent: VIOLET,
        })
      ),
      // Droite : IA Tuteur
      C(
        View,
        { style: { flex: 1, gap: 10 } },
        C(Text, { style: s.h2 }, "IA tuteur (Premium)"),
        C(
          View,
          { style: [s.cardBrand, { gap: 8 }] },
          C(Badge, { color: GOLD, bg: "rgba(245, 177, 0, 0.2)" }, "Claude Sonnet 4.6"),
          C(Text, { style: { fontSize: 14, fontWeight: "bold", color: WHITE, marginTop: 4 } }, "Un tuteur 24/7 par stagiaire"),
          C(Text, { style: { fontSize: 10, color: SLATE_300, lineHeight: 1.5 } },
            "Chatbot RAG entraîné sur les modules de la formation du stagiaire (pgvector + 896 chunks embeddés). Il cite ses sources avec un lien direct vers la leçon, refuse les questions hors-domaine, et propose des notes provisoires de correction QR validées ensuite par le formateur."),
          C(View, { style: { borderTopWidth: 0.5, borderTopColor: NAVY_700, paddingTop: 8, marginTop: 4 } },
            C(Text, { style: { fontSize: 8, color: SIGNAL, letterSpacing: 1.5, textTransform: "uppercase", fontWeight: "bold", marginBottom: 4 } }, "Garde-fous"),
            C(Text, { style: { fontSize: 9, color: SLATE_300, lineHeight: 1.5 } },
              "Modération pré-prompt · Quota 200 msg/mois · Rate limit 5/min · Refus si similarité < 0.7 · Logs purge 90j")
          )
        ),
        C(FeatureCard, {
          title: "Correction QR par IA",
          description: "Claude propose un score + un feedback markdown + le détail des critères. Le formateur valide ou ajuste en 1 clic avant publication.",
          accent: GOLD_DARK,
        }),
        C(FeatureCard, {
          title: "Quota & monitoring",
          description: "Page admin dédiée : coût mensuel, top consommateurs, top campagnes, audit des refus modération.",
          accent: SLATE_700,
          size: "small",
        })
      )
    ),
    C(PageFooter, { pageNo: 9, total: 26 })
  );
}

function PedagogiePage3() {
  return C(
    Page,
    { size: "A4", style: s.pageDefault },
    C(PageHeader, { chapter: "05 · Approche pédagogique" }),
    C(Eyebrow, {}, "Suivi pédagogique"),
    C(Text, { style: s.h1 }, "Visibilité totale,"),
    C(Text, { style: [s.h1, { color: GOLD_DARK, marginTop: -4 }] }, "pour les trois acteurs."),
    C(
      Text,
      { style: [s.lead, { marginTop: 12, marginBottom: 20 }] },
      "Stagiaire, formateur et administrateur disposent chacun de tableaux de bord temps réel adaptés à leur usage."
    ),
    C(
      View,
      { style: { gap: 12 } },
      C(DashCard, {
        title: "Tableau de bord stagiaire",
        accent: SIGNAL_DARK,
        items: [
          "Progression globale (% leçons terminées)",
          "Score moyen et historique des tentatives",
          "Prochain module suggéré (continue card)",
          "Annonces, badges récents, série de jours",
          "Récap formations (multi-formations possible)",
          "Examens blancs disponibles + résultats",
        ],
      }),
      C(DashCard, {
        title: "Espace formateur",
        accent: BRAND,
        items: [
          "Mes stagiaires (filtrables par formation)",
          "File de correction QR avec proposition IA",
          "Messagerie privée par stagiaire (Pack Medium+)",
          "Stats par stagiaire : score, progression, dernière activité",
          "Alertes inactivité (>14 jours)",
          "Vue des examens blancs corrigés ou en attente",
        ],
      }),
      C(DashCard, {
        title: "Tableau de bord administrateur",
        accent: GOLD_DARK,
        items: [
          "KPIs temps réel : actifs 7j, revenus 30j, à risque",
          "Funnel d'acquisition (5 étapes : signup → payer)",
          "Heatmap d'activité hebdomadaire (7j × 24h)",
          "Indicateurs Qualiopi (auto-générés)",
          "Top stagiaires, quiz outliers (questions trop dures/faciles)",
          "Revenue par formation × pack, financeurs, organisations",
        ],
      })
    ),
    C(PageFooter, { pageNo: 10, total: 26 })
  );
}

function DashCard({
  title,
  accent,
  items,
}: {
  title: string;
  accent: string;
  items: string[];
}) {
  // 2 colonnes
  const half = Math.ceil(items.length / 2);
  const col1 = items.slice(0, half);
  const col2 = items.slice(half);
  return C(
    View,
    {
      style: {
        backgroundColor: WHITE,
        borderRadius: 10,
        borderWidth: 0.5,
        borderColor: SLATE_300,
        overflow: "hidden",
      },
    },
    C(View, {
      style: {
        backgroundColor: accent,
        paddingHorizontal: 14,
        paddingVertical: 8,
      },
    }, C(Text, { style: { fontSize: 11, fontWeight: "bold", color: WHITE, letterSpacing: 0.5 } }, title)),
    C(
      View,
      { style: { flexDirection: "row", padding: 14, gap: 12 } },
      C(
        View,
        { style: { flex: 1 } },
        ...col1.map((it, i) =>
          C(
            View,
            { key: i, style: { flexDirection: "row", marginTop: 4 } },
            C(Text, { style: { fontSize: 10, color: accent, marginRight: 6 } }, "✓"),
            C(Text, { style: { fontSize: 9.5, color: SLATE_700, flex: 1, lineHeight: 1.45 } }, it)
          )
        )
      ),
      C(
        View,
        { style: { flex: 1 } },
        ...col2.map((it, i) =>
          C(
            View,
            { key: i, style: { flexDirection: "row", marginTop: 4 } },
            C(Text, { style: { fontSize: 10, color: accent, marginRight: 6 } }, "✓"),
            C(Text, { style: { fontSize: 9.5, color: SLATE_700, flex: 1, lineHeight: 1.45 } }, it)
          )
        )
      )
    )
  );
}

// ─── PAGE 13 — IMPORT PDF ────────────────────────────────────────────
function ImportPdfPage() {
  return C(
    Page,
    { size: "A4", style: s.pageDefault },
    C(PageHeader, { chapter: "06 · Import PDF intelligent" }),
    C(Eyebrow, {}, "Productivité éditoriale"),
    C(Text, { style: s.h1 }, "Du PDF brut à la leçon"),
    C(Text, { style: [s.h1, { color: GOLD_DARK, marginTop: -4 }] }, "publiable en 5 minutes."),
    C(
      Text,
      { style: [s.lead, { marginTop: 12, marginBottom: 20 }] },
      "Le système d'import PDF est l'un des outils internes les plus distinctifs : il transforme un PDF source (référentiel RNCP, support papier, polycopié) en leçons structurées, avec tableaux préservés, annexes uploadées, et éditeur WYSIWYG."
    ),
    // Pipeline d'import en étapes
    C(
      View,
      { style: { gap: 8 } },
      C(PipelineStep, {
        num: "1", title: "Upload PDF source",
        desc: "Drop & drop du fichier PDF (jusqu'à 50 MB). Parsing pdf-parse côté serveur : extraction texte + détection des structures.",
        accent: SIGNAL_DARK,
      }),
      C(PipelineStep, {
        num: "2", title: "Reconstruction des tableaux",
        desc: "Détection des grilles tabulaires (espacements verticaux/horizontaux), reconstitution en tableaux Markdown GFM. Les barèmes, plannings, fiches techniques sont préservés.",
        accent: BRAND,
      }),
      C(PipelineStep, {
        num: "3", title: "Édition WYSIWYG (Tiptap)",
        desc: "Éditeur riche style Notion / Google Docs : titres H1-H4, listes, tableaux, callouts pédagogiques (🎯 Objectifs, 📌 À retenir, ⚠ Attention, 💡 Astuce), images, liens. Sauvegarde automatique.",
        accent: GOLD_DARK,
      }),
      C(PipelineStep, {
        num: "4", title: "Découpage par leçons",
        desc: "Détection auto des séparateurs (titres niveaux, sauts de page) et découpage en N leçons. L'admin peut ré-arranger, fusionner, scinder via drag & drop.",
        accent: VIOLET,
      }),
      C(PipelineStep, {
        num: "5", title: "Annexes & médias",
        desc: "Les annexes (extraits de référentiels, fiches techniques) sont uploadées dans Supabase Storage et liées à chaque question rédigée. Affichage in-app dans le quiz runner.",
        accent: ROSE,
      }),
      C(PipelineStep, {
        num: "6", title: "Publication",
        desc: "Validation finale + activation. Les stagiaires voient le nouveau contenu immédiatement via Server Components (pas de cache statique). RLS appliquée.",
        accent: EMERALD,
      })
    ),
    C(
      View,
      { style: [s.cardGold, { marginTop: 16 }] },
      C(Text, { style: { fontSize: 10.5, color: SLATE_900, lineHeight: 1.5, fontStyle: "italic" } },
        "Application concrète : la banque CCP1 GOTRM (66 questions rédigées + 23 annexes PDF) a été importée en 4 heures de travail effectif via ce pipeline, à partir d'un dossier de 89 PDFs sources fournis par le client.")
    ),
    C(PageFooter, { pageNo: 11, total: 26 })
  );
}

function PipelineStep({
  num, title, desc, accent,
}: {
  num: string; title: string; desc: string; accent: string;
}) {
  return C(
    View,
    {
      style: {
        flexDirection: "row",
        gap: 12,
        backgroundColor: WHITE,
        borderRadius: 8,
        borderWidth: 0.5,
        borderColor: SLATE_300,
        padding: 12,
      },
    },
    C(View, {
      style: {
        width: 28, height: 28,
        borderRadius: 14,
        backgroundColor: accent,
        alignItems: "center",
        justifyContent: "center",
      },
    },
      C(Text, { style: { fontSize: 12, fontWeight: "bold", color: WHITE } }, num)),
    C(
      View,
      { style: { flex: 1 } },
      C(Text, { style: { fontSize: 12, fontWeight: "bold", color: NAVY_900 } }, title),
      C(Text, { style: { fontSize: 9.5, color: SLATE_700, marginTop: 2, lineHeight: 1.45 } }, desc)
    )
  );
}

// ─── PAGE 14 — DESIGN & UX ───────────────────────────────────────────
function DesignPage() {
  return C(
    Page,
    { size: "A4", style: s.pageDefault },
    C(PageHeader, { chapter: "07 · Design & UX" }),
    C(Eyebrow, {}, "Identité visuelle"),
    C(Text, { style: s.h1 }, "Un design pensé"),
    C(Text, { style: [s.h1, { color: GOLD_DARK, marginTop: -4 }] }, "pour la confiance."),
    C(
      Text,
      { style: [s.lead, { marginTop: 12, marginBottom: 16 }] },
      "Inspirations : Apple (clarté), Stripe (densité maîtrisée), Notion (édition riche), Linear (motion subtile). Le résultat est une plateforme dense en information mais jamais saturée, avec une typographie soignée et des animations dosées."
    ),
    // Palette
    C(View, { style: { marginBottom: 16 } },
      C(Text, { style: [s.h3, { marginBottom: 8 }] }, "Palette officielle"),
      C(
        View,
        { style: { flexDirection: "row", gap: 6 } },
        C(ColorSwatch, { color: NAVY_900, name: "Navy", hex: "#0E1240" }),
        C(ColorSwatch, { color: GOLD, name: "Gold", hex: "#F5B100" }),
        C(ColorSwatch, { color: SIGNAL, name: "Signal", hex: "#9FE220" }),
        C(ColorSwatch, { color: IVORY, name: "Ivory", hex: "#FAF8F4", textDark: true }),
        C(ColorSwatch, { color: SLATE_700, name: "Slate", hex: "#334155" })
      )
    ),
    // 4 principes
    C(Text, { style: [s.h3, { marginBottom: 8 }] }, "Principes de design"),
    C(
      View,
      { style: { flexDirection: "row", gap: 8, marginBottom: 12 } },
      C(PrincipleCard, {
        title: "Sobriété",
        desc: "Espacements généreux, hiérarchie claire, pas d'élément décoratif gratuit. Chaque pixel sert l'utilisateur.",
      }),
      C(PrincipleCard, {
        title: "Lisibilité",
        desc: "Body 65–75 ch maximum, contrastes WCAG AA, typo display + monospace pour les chiffres tabulaires.",
      }),
      C(PrincipleCard, {
        title: "Motion subtile",
        desc: "Ease-out exponentiel, durées 200–400 ms, respect de prefers-reduced-motion. Pas de bounce, pas d'élastique.",
      }),
      C(PrincipleCard, {
        title: "Mobile-first",
        desc: "PWA installable, design responsive jusqu'à 320 px. Sidebar mobile, dark mode complet, tap targets ≥ 44 px.",
      })
    ),
    // Composants UI
    C(Text, { style: [s.h3, { marginBottom: 8 }] }, "Bibliothèque de composants"),
    C(
      View,
      { style: { flexDirection: "row", flexWrap: "wrap", gap: 6 } },
      ...[
        "Cards", "Badges", "ProgressBar", "RadialProgress",
        "Modal", "Drawer", "Toast", "Tooltip",
        "DataTable", "Pagination", "SearchPalette", "MarkdownDisplay",
        "QuizRunner", "QrEditor", "FormationStripe", "FormationBadge",
        "ConfettiBurst", "ScrollReveal", "ThemeToggle", "LocaleToggle",
      ].map((c) => C(View, {
        key: c,
        style: {
          backgroundColor: WHITE,
          borderWidth: 0.5,
          borderColor: SLATE_300,
          paddingHorizontal: 8,
          paddingVertical: 4,
          borderRadius: 4,
        },
      }, C(Text, { style: { fontSize: 8.5, color: SLATE_700, fontFamily: "Courier" } }, c)))
    ),
    C(PageFooter, { pageNo: 12, total: 26 })
  );
}

function ColorSwatch({ color, name, hex, textDark }: { color: string; name: string; hex: string; textDark?: boolean }) {
  return C(
    View,
    { style: { flex: 1 } },
    C(View, {
      style: {
        backgroundColor: color,
        height: 50,
        borderRadius: 6,
        borderWidth: textDark ? 0.5 : 0,
        borderColor: SLATE_300,
        marginBottom: 4,
      },
    }),
    C(Text, { style: { fontSize: 9, fontWeight: "bold", color: NAVY_900 } }, name),
    C(Text, { style: { fontSize: 8, color: SLATE_500, fontFamily: "Courier" } }, hex)
  );
}

function PrincipleCard({ title, desc }: { title: string; desc: string }) {
  return C(
    View,
    {
      style: {
        flex: 1,
        backgroundColor: WHITE,
        borderRadius: 8,
        padding: 12,
        borderWidth: 0.5,
        borderColor: SLATE_300,
      },
    },
    C(Text, { style: { fontSize: 11, fontWeight: "bold", color: NAVY_900, marginBottom: 4 } }, title),
    C(Text, { style: { fontSize: 9, color: SLATE_700, lineHeight: 1.5 } }, desc)
  );
}

// ─── PAGE 15-17 — FONCTIONNALITÉS ────────────────────────────────────
function FeaturesPage() {
  return C(
    Page,
    { size: "A4", style: s.pageDefault },
    C(PageHeader, { chapter: "08 · Fonctionnalités avancées" }),
    C(Eyebrow, {}, "Ce qui fait la différence"),
    C(Text, { style: s.h1 }, "Au-delà du LMS classique."),
    C(
      Text,
      { style: [s.lead, { marginTop: 12, marginBottom: 16 }] },
      "MFT ne se contente pas d'être un LMS : c'est une plateforme business complète qui gère le marketing, le commercial, le suivi pédagogique et la conformité dans un seul espace."
    ),
    // Grille 2x3
    C(
      View,
      { style: { gap: 10 } },
      C(View, { style: { flexDirection: "row", gap: 10 } },
        C(BigFeature, {
          title: "IA Tuteur (Premium)",
          tag: "Premium",
          tagColor: GOLD_DARK,
          desc: "Chat 24/7 RAG sur les modules de la formation. Streaming SSE, citations sourcées, modération pré-prompt, quota 200 msg/mois. Claude Sonnet 4.6 + OpenAI embeddings (pgvector).",
        }),
        C(BigFeature, {
          title: "Correction QR par IA",
          tag: "Tous packs",
          tagColor: SIGNAL_DARK,
          desc: "Claude propose un score + appréciation + critères pour chaque question rédigée. Validation systématique du formateur en 1 clic. Réduit le temps de correction de 70 %.",
        })
      ),
      C(View, { style: { flexDirection: "row", gap: 10 } },
        C(BigFeature, {
          title: "PWA & Offline",
          tag: "Mobile",
          tagColor: BRAND,
          desc: "Installation native sur iOS / Android via le navigateur. Cache stale-while-revalidate sur les leçons. Quiz d'entraînement passables hors-ligne, sync différée au retour réseau.",
        }),
        C(BigFeature, {
          title: "CRM intégré",
          tag: "Admin",
          tagColor: VIOLET,
          desc: "Pipeline prospects (Nouveau → Contacté → Devis → Inscrit). Assignation, notes 5 types, relances, snooze, audit trail auto. Cron quotidien email récap aux admins.",
        })
      ),
      C(View, { style: { flexDirection: "row", gap: 10 } },
        C(BigFeature, {
          title: "Funnel UTM",
          tag: "Marketing",
          tagColor: GOLD_DARK,
          desc: "Tracking first-touch via cookie httpOnly. Attribution par source (Instagram, LinkedIn, Google) × medium × campagne. Tableau visiteurs → signups → conversions par canal.",
        }),
        C(BigFeature, {
          title: "Parrainage & Fidélité",
          tag: "Croissance",
          tagColor: SIGNAL_DARK,
          desc: "Parrain reçoit 50 € de crédit + filleul -10 %. Programme fidélité 4 tiers (None/Bronze/Silver/Gold) avec réductions auto cumulables. Certificats dorés pour les fidèles.",
        })
      )
    ),
    C(PageFooter, { pageNo: 13, total: 26 })
  );
}

function BigFeature({
  title,
  tag,
  tagColor,
  desc,
}: {
  title: string;
  tag: string;
  tagColor: string;
  desc: string;
}) {
  return C(
    View,
    {
      style: {
        flex: 1,
        backgroundColor: WHITE,
        borderRadius: 10,
        padding: 14,
        borderWidth: 0.5,
        borderColor: SLATE_300,
      },
    },
    C(
      View,
      { style: { flexDirection: "row", alignItems: "center", justifyContent: "space-between", marginBottom: 6 } },
      C(Text, { style: { fontSize: 12, fontWeight: "bold", color: NAVY_900 } }, title),
      C(View, {
        style: {
          backgroundColor: tagColor,
          paddingHorizontal: 6,
          paddingVertical: 2,
          borderRadius: 3,
        },
      }, C(Text, { style: { fontSize: 7, fontWeight: "bold", color: WHITE, letterSpacing: 1, textTransform: "uppercase" } }, tag))
    ),
    C(Text, { style: { fontSize: 9.5, color: SLATE_700, lineHeight: 1.5 } }, desc)
  );
}

function FeaturesPage2() {
  return C(
    Page,
    { size: "A4", style: s.pageDefault },
    C(PageHeader, { chapter: "08 · Fonctionnalités avancées" }),
    C(Eyebrow, {}, "Multi-tenant & financeur"),
    C(Text, { style: s.h1 }, "Pensé pour le B2B."),
    C(
      Text,
      { style: [s.lead, { marginTop: 12, marginBottom: 16 }] },
      "Les organismes de formation ont des clients institutionnels (entreprises, OPCO, France Travail) qui exigent des portails dédiés et des exports conformes. MFT le fait nativement."
    ),
    C(
      View,
      { style: { gap: 12 } },
      C(BigSection, {
        title: "Multi-tenant entreprise",
        kicker: "Vendre à des transporteurs",
        desc: "Une entreprise cliente peut acheter N formations pour ses salariés et avoir son propre espace : tableau de bord, équipe (org_admin / org_viewer / org_learner), inscriptions consolidées, historique de facturation.",
        bullets: [
          "Espace /organisation dédié avec branding (logo, couleur primaire)",
          "Inscription groupée : pré-réserver des places sans email des stagiaires",
          "Stripe checkout avec organization_id, facturation centralisée",
          "RLS stricte : isolation cross-orga testée Playwright",
        ],
        accent: BRAND,
      }),
      C(BigSection, {
        title: "Portail financeur (OPCO, CPF, France Travail)",
        kicker: "Conformité institutionnelle",
        desc: "Chaque financeur dispose d'un portail temps réel pour suivre les stagiaires qu'il finance, avec exports Qualiopi en un clic.",
        bullets: [
          "KPIs : stagiaires financés, progression moyenne, certifications, vigilance (>14j d'inactivité)",
          "Drill-down par stagiaire : progression, score, échéances de paiement, résultats",
          "Notifications automatiques sur les jalons (entrée formation, examen blanc, certif)",
          "Exports CSV + JSON pour intégration aux SI financeur",
          "RLS : ne voit que les enrollments dont il est rattaché en tant que funder",
        ],
        accent: GOLD_DARK,
      })
    ),
    C(PageFooter, { pageNo: 14, total: 26 })
  );
}

function BigSection({
  title, kicker, desc, bullets, accent,
}: {
  title: string;
  kicker: string;
  desc: string;
  bullets: string[];
  accent: string;
}) {
  return C(
    View,
    {
      style: {
        backgroundColor: WHITE,
        borderRadius: 12,
        padding: 18,
        borderLeftWidth: 4,
        borderLeftColor: accent,
        borderTopWidth: 0.5,
        borderTopColor: SLATE_300,
        borderRightWidth: 0.5,
        borderRightColor: SLATE_300,
        borderBottomWidth: 0.5,
        borderBottomColor: SLATE_300,
      },
    },
    C(Text, {
      style: { fontSize: 8, fontWeight: "bold", color: accent, letterSpacing: 1.5, textTransform: "uppercase" },
    }, kicker),
    C(Text, { style: { fontSize: 16, fontWeight: "bold", color: NAVY_900, marginTop: 4, marginBottom: 6 } }, title),
    C(Text, { style: { fontSize: 10.5, color: SLATE_700, lineHeight: 1.55, marginBottom: 10 } }, desc),
    C(
      View,
      { style: { gap: 4 } },
      ...bullets.map((b, i) =>
        C(
          View,
          { key: i, style: { flexDirection: "row" } },
          C(Text, { style: { fontSize: 10, color: accent, marginRight: 6, marginTop: 0.5 } }, "▸"),
          C(Text, { style: { fontSize: 10, color: SLATE_700, flex: 1, lineHeight: 1.5 } }, b)
        )
      )
    )
  );
}

// ─── PAGE 18 — SÉCURITÉ & RGPD ───────────────────────────────────────
function SecurityPage() {
  return C(
    Page,
    { size: "A4", style: s.pageDefault },
    C(PageHeader, { chapter: "09 · Sécurité & RGPD" }),
    C(Eyebrow, {}, "Conformité by design"),
    C(Text, { style: s.h1 }, "Confiance, conformité,"),
    C(Text, { style: [s.h1, { color: GOLD_DARK, marginTop: -4 }] }, "responsabilité."),
    C(
      Text,
      { style: [s.lead, { marginTop: 12, marginBottom: 20 }] },
      "Les données pédagogiques et personnelles des stagiaires sont sensibles. MFT a été conçue dès le départ avec une approche security-by-default et privacy-by-design."
    ),
    C(
      View,
      { style: { gap: 12 } },
      C(SecuritySection, {
        title: "Row Level Security (RLS)",
        items: [
          "Activée sur 100 % des tables sensibles (profiles, enrollments, lessons, certificates…)",
          "Policies par rôle (student, trainer, admin, super_admin) + par scope (own, formation, organization)",
          "Tests d'isolation cross-organisation via Playwright",
        ],
      }),
      C(SecuritySection, {
        title: "Hébergement & souveraineté",
        items: [
          "Supabase région EU (Frankfurt) — données hébergées en Europe",
          "Vercel EU + PostHog EU — analytics RGPD-natif",
          "Anthropic UK + OpenAI US — DPA signés, données non utilisées pour l'entraînement",
        ],
      }),
      C(SecuritySection, {
        title: "Authentification",
        items: [
          "Sessions sécurisées via Supabase Auth (cookies httpOnly, SameSite Lax)",
          "Magic links + email/password + OAuth (Google, Microsoft)",
          "2FA optionnelle (TOTP) pour les comptes admin",
          "Verrouillage de compte après tentatives échouées",
        ],
      }),
      C(SecuritySection, {
        title: "RGPD & droit des stagiaires",
        items: [
          "Page /mes-donnees : consultation + export JSON de toutes les données personnelles",
          "Suppression de compte sur demande (avec délai légal RGPD)",
          "Cookie banner conforme : tracking marketing opt-in, fonctionnel par défaut",
          "Audit log : qui a accédé à quelles données et quand",
          "Documentation publique : /confidentialite, /mentions-legales, /cgu, /cgv",
        ],
      })
    ),
    C(PageFooter, { pageNo: 15, total: 26 })
  );
}

function SecuritySection({ title, items }: { title: string; items: string[] }) {
  return C(
    View,
    {
      style: {
        backgroundColor: WHITE,
        borderRadius: 8,
        padding: 14,
        borderWidth: 0.5,
        borderColor: SLATE_300,
      },
    },
    C(Text, { style: { fontSize: 12, fontWeight: "bold", color: NAVY_900, marginBottom: 6 } }, title),
    C(
      View,
      { style: { gap: 3 } },
      ...items.map((it, i) =>
        C(
          View,
          { key: i, style: { flexDirection: "row" } },
          C(Text, { style: { fontSize: 10, color: SIGNAL_DARK, marginRight: 6 } }, "✓"),
          C(Text, { style: { fontSize: 10, color: SLATE_700, flex: 1, lineHeight: 1.5 } }, it)
        )
      )
    )
  );
}

// ─── PAGE 19-20 — BUSINESS & VISION ──────────────────────────────────
function BusinessPage() {
  return C(
    Page,
    { size: "A4", style: s.pageDefault },
    C(PageHeader, { chapter: "11 · Vision business" }),
    C(Eyebrow, {}, "Potentiel commercial"),
    C(Text, { style: s.h1 }, "Au-delà de MFT :"),
    C(Text, { style: [s.h1, { color: GOLD_DARK, marginTop: -4 }] }, "un SaaS multi-vertical."),
    C(
      Text,
      { style: [s.lead, { marginTop: 12, marginBottom: 16 }] },
      "MFT a été pensé dès l'origine comme un produit reproductible. La verticalisation transport n'est qu'un point d'entrée — l'architecture multi-tenant et le moteur pédagogique sont génériques."
    ),
    // 3 axes business
    C(
      View,
      { style: { flexDirection: "row", gap: 10, marginBottom: 14 } },
      C(BizCard, {
        title: "B2C — Stagiaires individuels",
        market: "300 000 candidats / an en France (estimation)",
        revenue: "Pack Initial 1500-4000 € · Premium 2500-6000 €",
        bullet: "Financements : CPF, France Travail, auto",
      }),
      C(BizCard, {
        title: "B2B — Entreprises clientes",
        market: "Transporteurs, gestionnaires de flottes, écoles routières",
        revenue: "Pack groupé · Tarif sur devis · Renouvellement annuel",
        bullet: "Inscription groupée + portail dédié",
      }),
      C(BizCard, {
        title: "B2B — Organismes de formation",
        market: "200+ centres Qualiopi transport en France",
        revenue: "Licence SaaS white-label · 500-2000 € / mois",
        bullet: "Multi-tenant + branding personnalisé",
      })
    ),
    // Encart SaaS / White-label
    C(
      View,
      { style: [s.cardBrand, { marginTop: 8 }] },
      C(Text, {
        style: {
          fontSize: 9,
          color: GOLD,
          fontWeight: "bold",
          letterSpacing: 2,
          textTransform: "uppercase",
          marginBottom: 8,
        },
      }, "Évolution SaaS multi-tenant"),
      C(Text, {
        style: {
          fontSize: 13,
          color: WHITE,
          fontWeight: "bold",
          marginBottom: 8,
        },
      }, "De plateforme propriétaire à produit white-label."),
      C(Text, {
        style: {
          fontSize: 10.5,
          color: SLATE_300,
          lineHeight: 1.55,
        },
      }, "Le code MFT supporte techniquement la mise en place d'un mode multi-tenant Saas où chaque organisme de formation aurait son propre sous-domaine, son branding, ses formations, ses stagiaires. Les briques structurelles (RLS, organizations, multi-formations, multi-packs) sont déjà en place."),
      C(View, { style: { flexDirection: "row", gap: 12, marginTop: 12, paddingTop: 12, borderTopWidth: 0.5, borderTopColor: NAVY_700 } },
        C(MiniStat, { value: "1-2", label: "Semaines de dev par tenant" }),
        C(MiniStat, { value: "500€+", label: "MRR par tenant (estimation)" }),
        C(MiniStat, { value: "10x", label: "Marges vs livraison sur mesure" })
      )
    ),
    C(PageFooter, { pageNo: 16, total: 26 })
  );
}

function BizCard({
  title, market, revenue, bullet,
}: {
  title: string;
  market: string;
  revenue: string;
  bullet: string;
}) {
  return C(
    View,
    {
      style: {
        flex: 1,
        backgroundColor: WHITE,
        borderRadius: 8,
        padding: 12,
        borderWidth: 0.5,
        borderColor: SLATE_300,
      },
    },
    C(Text, { style: { fontSize: 11, fontWeight: "bold", color: NAVY_900, marginBottom: 6 } }, title),
    C(View, { style: { marginBottom: 4 } },
      C(Text, { style: { fontSize: 7.5, color: SLATE_500, textTransform: "uppercase", letterSpacing: 1 } }, "Marché"),
      C(Text, { style: { fontSize: 9.5, color: SLATE_700, marginTop: 1 } }, market)),
    C(View, { style: { marginBottom: 4 } },
      C(Text, { style: { fontSize: 7.5, color: SLATE_500, textTransform: "uppercase", letterSpacing: 1 } }, "Modèle revenu"),
      C(Text, { style: { fontSize: 9.5, color: SLATE_700, marginTop: 1 } }, revenue)),
    C(View, {},
      C(Text, { style: { fontSize: 7.5, color: SLATE_500, textTransform: "uppercase", letterSpacing: 1 } }, "Avantage"),
      C(Text, { style: { fontSize: 9.5, color: SLATE_700, marginTop: 1, fontStyle: "italic" } }, bullet))
  );
}

function MiniStat({ value, label }: { value: string; label: string }) {
  return C(View, { style: { flex: 1 } },
    C(Text, { style: { fontSize: 20, color: WHITE, fontWeight: "bold", letterSpacing: -0.5 } }, value),
    C(Text, { style: { fontSize: 8, color: SIGNAL, textTransform: "uppercase", letterSpacing: 1.5, marginTop: 2 } }, label));
}

// ─── PAGE 21 — ROADMAP FUTURE ────────────────────────────────────────
function RoadmapPage() {
  const roadmap = [
    { quarter: "Q3 2026", title: "Mode multi-tenant SaaS complet", status: "En cours" },
    { quarter: "Q3 2026", title: "Application mobile native (React Native)", status: "À étudier" },
    { quarter: "Q4 2026", title: "Stats réseaux sociaux (Instagram + LinkedIn API)", status: "À démarrer" },
    { quarter: "Q4 2026", title: "API publique partenaire (OAuth pour OPCO)", status: "À planifier" },
    { quarter: "Q1 2027", title: "Tuteur IA en synthèse vocale (Whisper + ElevenLabs)", status: "Exploration" },
    { quarter: "Q1 2027", title: "Génération auto de quiz par IA (Claude tool use)", status: "Exploration" },
    { quarter: "Q2 2027", title: "Marketplace de formateurs externes (Stripe Connect)", status: "À valider" },
    { quarter: "Q2 2027", title: "Programme de fidélité étendu (réductions partenaires)", status: "À étudier" },
  ];
  return C(
    Page,
    { size: "A4", style: s.pageDefault },
    C(PageHeader, { chapter: "12 · Roadmap" }),
    C(Eyebrow, {}, "Où on va"),
    C(Text, { style: s.h1 }, "La suite naturelle."),
    C(
      Text,
      { style: [s.lead, { marginTop: 12, marginBottom: 20 }] },
      "MFT v1 couvre déjà l'essentiel d'un LMS premium. La roadmap suivante densifie le produit sans le complexifier — chaque évolution renforce un axe stratégique (conversion, rétention, monétisation, conformité)."
    ),
    // Timeline verticale
    C(
      View,
      { style: { gap: 10 } },
      ...roadmap.map((r, i) =>
        C(
          View,
          {
            key: i,
            style: {
              flexDirection: "row",
              gap: 12,
              alignItems: "flex-start",
            },
          },
          C(View, {
            style: {
              width: 70,
              paddingTop: 4,
            },
          }, C(Text, { style: { fontSize: 9, fontWeight: "bold", color: GOLD_DARK, letterSpacing: 1.5, textTransform: "uppercase" } }, r.quarter)),
          C(View, {
            style: {
              width: 8, height: 8,
              borderRadius: 4,
              backgroundColor: GOLD,
              marginTop: 8,
            },
          }),
          C(
            View,
            {
              style: {
                flex: 1,
                backgroundColor: WHITE,
                borderRadius: 8,
                padding: 12,
                borderWidth: 0.5,
                borderColor: SLATE_300,
                flexDirection: "row",
                alignItems: "center",
                justifyContent: "space-between",
              },
            },
            C(Text, { style: { fontSize: 11, fontWeight: "bold", color: NAVY_900, flex: 1 } }, r.title),
            C(View, {
              style: {
                backgroundColor: SLATE_100,
                paddingHorizontal: 6,
                paddingVertical: 2,
                borderRadius: 3,
              },
            }, C(Text, { style: { fontSize: 8, color: SLATE_700, fontWeight: "bold", letterSpacing: 0.5 } }, r.status))
          )
        )
      )
    ),
    C(PageFooter, { pageNo: 17, total: 26 })
  );
}

// ─── PAGE 22 — FORCES & CONCLUSION ───────────────────────────────────
function ForcesPage() {
  return C(
    Page,
    { size: "A4", style: s.pageDefault },
    C(PageHeader, { chapter: "13 · Forces du projet" }),
    C(Eyebrow, {}, "Pourquoi MFT"),
    C(Text, { style: s.h1 }, "Les 8 forces"),
    C(Text, { style: [s.h1, { color: GOLD_DARK, marginTop: -4 }] }, "qui font la différence."),
    C(
      View,
      { style: { gap: 10, marginTop: 16 } },
      C(
        View,
        { style: { flexDirection: "row", gap: 10 } },
        C(ForceCard, { num: "01", title: "Verticalisation transport", desc: "Pas un LMS générique adapté à l'arrache : un produit conçu nativement pour les 6 grandes formations transport en France." }),
        C(ForceCard, { num: "02", title: "Qualiopi-ready", desc: "Tous les indicateurs Qualiopi sont auto-générés. BPF, présence, suivi, accompagnement — exports en un clic." })
      ),
      C(
        View,
        { style: { flexDirection: "row", gap: 10 } },
        C(ForceCard, { num: "03", title: "IA pédagogique mature", desc: "Pas du gadget : RAG production-ready, modération, quota, monitoring. Cost-aware par stagiaire." }),
        C(ForceCard, { num: "04", title: "Multi-tenant natif", desc: "Architecture RLS testée, isolation cross-orga vérifiée. Permet l'évolution SaaS sans refonte." })
      ),
      C(
        View,
        { style: { flexDirection: "row", gap: 10 } },
        C(ForceCard, { num: "05", title: "Outils internes premium", desc: "Import PDF intelligent, éditeur WYSIWYG, génération auto de certificats. La productivité éditoriale fait la différence." }),
        C(ForceCard, { num: "06", title: "RGPD & sécurité", desc: "EU-only, RLS partout, audit log, DPA Anthropic signé. Conforme par défaut, pas en bricolage." })
      ),
      C(
        View,
        { style: { flexDirection: "row", gap: 10 } },
        C(ForceCard, { num: "07", title: "CRM + marketing intégrés", desc: "Du prospect à la conversion à la fidélisation, le tout dans une seule plateforme. Pas de bricolage Excel ou Notion." }),
        C(ForceCard, { num: "08", title: "Pensé pour le scaling", desc: "Stack serverless full-managed, zéro DevOps, scaling auto. De 10 à 10 000 stagiaires sans changer une ligne." })
      )
    ),
    C(PageFooter, { pageNo: 18, total: 26 })
  );
}

function ForceCard({ num, title, desc }: { num: string; title: string; desc: string }) {
  return C(
    View,
    {
      style: {
        flex: 1,
        backgroundColor: WHITE,
        borderRadius: 8,
        padding: 12,
        borderWidth: 0.5,
        borderColor: SLATE_300,
      },
    },
    C(Text, {
      style: {
        fontSize: 9,
        fontWeight: "bold",
        color: GOLD_DARK,
        letterSpacing: 1.5,
        marginBottom: 4,
      },
    }, num),
    C(Text, { style: { fontSize: 11, fontWeight: "bold", color: NAVY_900, marginBottom: 4 } }, title),
    C(Text, { style: { fontSize: 9.5, color: SLATE_700, lineHeight: 1.5 } }, desc)
  );
}

// ─── PAGE 23 — CONCLUSION ────────────────────────────────────────────
function ConclusionPage() {
  return C(
    Page,
    { size: "A4", style: s.pageCover },
    C(View, {
      style: {
        position: "absolute", top: 0, left: 0, right: 0, bottom: 0,
        backgroundColor: NAVY_950,
      },
    }),
    C(View, {
      style: {
        position: "absolute", top: 0, left: 0, right: 0, height: 4,
        backgroundColor: GOLD,
      },
    }),
    C(View, {
      style: {
        position: "absolute", bottom: 0, left: 0, right: 0, height: 4,
        backgroundColor: SIGNAL,
      },
    }),
    C(
      View,
      { style: { padding: 64, flex: 1, justifyContent: "center" } },
      C(View, { style: { marginBottom: 32 } }, C(Logo, { size: 56, dark: true })),
      C(Text, {
        style: {
          fontSize: 9,
          color: GOLD,
          fontWeight: "bold",
          letterSpacing: 3,
          textTransform: "uppercase",
          marginBottom: 12,
        },
      }, "Conclusion"),
      C(Text, {
        style: {
          fontSize: 40,
          color: WHITE,
          fontWeight: "bold",
          lineHeight: 1.1,
          letterSpacing: -1,
          marginBottom: 20,
        },
      }, "Une plateforme prête,"),
      C(Text, {
        style: {
          fontSize: 40,
          color: SIGNAL,
          fontWeight: "bold",
          lineHeight: 1.1,
          letterSpacing: -1,
          marginBottom: 32,
        },
      }, "à exploiter dès demain."),
      C(Text, {
        style: {
          fontSize: 13,
          color: SLATE_300,
          lineHeight: 1.7,
          maxWidth: 480,
          marginBottom: 32,
        },
      }, "MFT n'est pas un projet en cours de développement : c'est un produit fini, déployé, testé, et utilisable immédiatement. La technique est solide, le design est moderne, la pédagogie est sérieuse, la conformité est intégrée. Reste à raconter cette histoire — à vos clients, à vos partenaires, à vos investisseurs."),
      // CTA box
      C(
        View,
        {
          style: {
            backgroundColor: NAVY_800,
            borderRadius: 12,
            padding: 24,
            borderLeftWidth: 4,
            borderLeftColor: GOLD,
          },
        },
        C(Text, {
          style: {
            fontSize: 9,
            color: GOLD,
            fontWeight: "bold",
            letterSpacing: 2,
            textTransform: "uppercase",
            marginBottom: 6,
          },
        }, "Pour aller plus loin"),
        C(Text, { style: { fontSize: 14, fontWeight: "bold", color: WHITE, marginBottom: 8 } }, "Démonstration & devis"),
        C(Text, { style: { fontSize: 11, color: SLATE_300, lineHeight: 1.5 } },
          "Démo personnalisée disponible sur demande. Comptez 45 minutes pour parcourir l'espace stagiaire, le tableau de bord formateur, l'admin, le CRM, l'IA tuteur, et le système d'import PDF.")
      ),
      C(
        View,
        {
          style: {
            marginTop: 40,
            flexDirection: "row",
            justifyContent: "space-between",
            alignItems: "flex-end",
          },
        },
        C(View, {},
          C(Text, { style: { fontSize: 11, color: WHITE, fontWeight: "bold" } }, "MA FORMATION TRANSPORT"),
          C(Text, { style: { fontSize: 10, color: SLATE_500, marginTop: 4 } }, "maformationtransport.fr"),
          C(Text, { style: { fontSize: 10, color: SLATE_500 } }, "contact@maformationtransport.fr")
        ),
        C(Text, {
          style: {
            fontSize: 8,
            color: SLATE_500,
            letterSpacing: 1,
          },
        }, "Document confidentiel · v1.0 · 2026")
      )
    )
  );
}

// ─── ASSEMBLAGE ──────────────────────────────────────────────────────
function Deck() {
  return C(
    Document,
    {
      title: "MA FORMATION TRANSPORT — Dossier de présentation",
      author: "MFT",
      subject: "Plateforme e-learning transport — Dossier projet",
      creator: "MFT Generator",
    },
    Cover(),
    TocPage(),
    VisionPage(),
    RolesPage(),
    FormationsPage(),
    ArchitecturePage(),
    TechStackPage(),
    PedagogiePage1(),
    PedagogiePage2(),
    PedagogiePage3(),
    ImportPdfPage(),
    DesignPage(),
    FeaturesPage(),
    FeaturesPage2(),
    SecurityPage(),
    BusinessPage(),
    RoadmapPage(),
    ForcesPage(),
    ConclusionPage()
  );
}

// ─── MAIN ────────────────────────────────────────────────────────────
async function main() {
  console.log("🎨 Génération du pitch deck MFT…");
  await renderToFile(Deck() as any, OUTPUT);
  console.log(`✅ PDF généré : ${OUTPUT}`);
}

main().catch((e) => {
  console.error("❌ Erreur :", e);
  process.exit(1);
});
