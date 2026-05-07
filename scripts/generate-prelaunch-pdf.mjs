// =====================================================================
// Génère un PDF "Checklist pré-production" à envoyer au client.
// Usage : npx tsx scripts/generate-prelaunch-pdf.mjs
// Output : scripts/output/checklist-pre-production.pdf
// =====================================================================

import React from "react";
import {
  Document,
  Page,
  Text,
  View,
  StyleSheet,
  renderToFile,
  Svg,
  Circle,
  Path,
  Rect,
  Line,
} from "@react-pdf/renderer";
import { mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const OUTPUT = resolve(__dirname, "output", "checklist-pre-production.pdf");
mkdirSync(dirname(OUTPUT), { recursive: true });

// ---------- Couleurs ----------
const NAVY = "#0E1240";
const NAVY_LIGHT = "#1f2547";
const BRAND = "#2530D9";
const SIGNAL = "#9FE220";
const GOLD_700 = "#a16207";
const ROSE = "#e11d48";
const ROSE_LIGHT = "#fef2f2";
const AMBER = "#d97706";
const AMBER_LIGHT = "#fef3c7";
const EMERALD = "#059669";
const EMERALD_LIGHT = "#d1fae5";
const SLATE_500 = "#64748b";
const SLATE_700 = "#334155";
const SLATE_900 = "#0f172a";
const NAVY_50 = "#f8fafc";

// ---------- Styles ----------
const s = StyleSheet.create({
  page: {
    paddingTop: 38,
    paddingBottom: 60,
    paddingHorizontal: 44,
    fontFamily: "Helvetica",
    fontSize: 10,
    color: SLATE_900,
  },
  topBar: { height: 4, backgroundColor: SIGNAL, marginBottom: 16 },
  brandRow: { flexDirection: "row", alignItems: "center", gap: 10, marginBottom: 6 },
  brandTitle: { fontSize: 13, fontWeight: "bold", color: NAVY, letterSpacing: 0.4 },
  brandSubTitle: {
    fontSize: 13,
    fontWeight: "bold",
    color: "#609015",
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
  sectionWrap: { marginTop: 14, marginBottom: 4 },
  sectionRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    marginBottom: 8,
  },
  sectionPill: {
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 4,
    fontSize: 9,
    fontWeight: "bold",
    letterSpacing: 0.6,
    textTransform: "uppercase",
  },
  sectionTitle: {
    fontSize: 13,
    fontWeight: "bold",
    color: NAVY,
    letterSpacing: -0.2,
  },
  sectionSub: {
    fontSize: 9,
    color: SLATE_500,
    marginTop: 1,
    marginBottom: 8,
  },
  itemCard: {
    borderWidth: 1,
    borderColor: "#e2e8f0",
    borderRadius: 6,
    padding: 10,
    marginBottom: 8,
    backgroundColor: "#fff",
  },
  itemHead: {
    flexDirection: "row",
    alignItems: "flex-start",
    gap: 8,
    marginBottom: 4,
  },
  itemNum: {
    width: 18,
    height: 18,
    borderRadius: 9,
    fontSize: 9,
    fontWeight: "bold",
    color: "#fff",
    textAlign: "center",
    paddingTop: 3,
  },
  itemTitle: {
    flex: 1,
    fontSize: 11,
    fontWeight: "bold",
    color: NAVY,
    lineHeight: 1.3,
  },
  itemTime: {
    fontSize: 8.5,
    color: SLATE_500,
    fontWeight: "bold",
  },
  itemBody: {
    fontSize: 9.5,
    color: SLATE_700,
    lineHeight: 1.5,
    marginTop: 2,
  },
  itemBullet: {
    flexDirection: "row",
    gap: 6,
    marginTop: 4,
    fontSize: 9.5,
    color: SLATE_700,
  },
  itemBulletDot: { color: BRAND, fontWeight: "bold" },
  timelineWrap: {
    marginTop: 14,
    backgroundColor: NAVY_50,
    borderRadius: 8,
    padding: 12,
    borderWidth: 1,
    borderColor: "#e2e8f0",
  },
  timelineTitle: {
    fontSize: 11,
    fontWeight: "bold",
    color: NAVY,
    marginBottom: 8,
  },
  timelineRow: {
    flexDirection: "row",
    paddingVertical: 4,
    borderBottomWidth: 1,
    borderBottomColor: "#e2e8f0",
  },
  timelineRowLast: { borderBottomWidth: 0 },
  timelineDay: {
    width: 50,
    fontSize: 9,
    fontWeight: "bold",
    color: NAVY,
  },
  timelineTask: { flex: 1, fontSize: 9, color: SLATE_700, lineHeight: 1.4 },
  timelineDur: {
    width: 60,
    fontSize: 8.5,
    color: SLATE_500,
    textAlign: "right",
  },
  footer: {
    position: "absolute",
    bottom: 30,
    left: 44,
    right: 44,
    paddingTop: 8,
    borderTopWidth: 1,
    borderTopColor: "#e2e8f0",
    flexDirection: "row",
    justifyContent: "space-between",
    fontSize: 7.5,
    color: SLATE_500,
  },
  pageNum: { fontSize: 8, color: SLATE_500 },
  totalBlock: {
    marginTop: 10,
    backgroundColor: SIGNAL + "15",
    borderWidth: 1,
    borderColor: SIGNAL + "60",
    borderRadius: 8,
    padding: 12,
  },
  totalTitle: {
    fontSize: 11,
    fontWeight: "bold",
    color: NAVY,
    marginBottom: 4,
  },
  totalText: { fontSize: 10, color: SLATE_700, lineHeight: 1.5 },
});

// ---------- Logo SVG ----------
function PdfLogo() {
  const C = React.createElement;
  return C(
    Svg,
    { width: 32, height: 32, viewBox: "0 0 64 64" },
    C(Circle, {
      cx: 32,
      cy: 36,
      r: 22,
      stroke: BRAND,
      strokeWidth: 3.5,
      fill: "none",
    }),
    C(Path, { d: "M22 56 L42 56 L36 22 L28 22 Z", fill: SIGNAL }),
    C(Rect, { x: 31.2, y: 26, width: 1.6, height: 4, fill: "#FFFFFF" }),
    C(Rect, { x: 31.1, y: 33, width: 1.8, height: 5, fill: "#FFFFFF" }),
    C(Rect, { x: 30.9, y: 42, width: 2.2, height: 6, fill: "#FFFFFF" }),
    C(Rect, { x: 30.6, y: 51, width: 2.8, height: 4, fill: "#FFFFFF" }),
    C(Path, { d: "M32 6 L52 14 L32 22 L12 14 Z", fill: BRAND }),
    C(Circle, { cx: 48, cy: 14, r: 1.6, fill: BRAND }),
    C(Line, {
      x1: 48,
      y1: 14,
      x2: 48,
      y2: 22,
      stroke: BRAND,
      strokeWidth: 1.4,
      strokeLinecap: "round",
    }),
    C(Circle, { cx: 48, cy: 22.5, r: 1.4, fill: BRAND })
  );
}

// ---------- Composants ----------
const C = React.createElement;

function Pill({ label, bg, color }) {
  return C(Text, { style: [s.sectionPill, { backgroundColor: bg, color }] }, label);
}

function ItemNum({ n, color }) {
  return C(
    Text,
    { style: [s.itemNum, { backgroundColor: color }] },
    String(n)
  );
}

function Item({ n, accent, title, time, body, bullets }) {
  return C(
    View,
    { style: s.itemCard, wrap: false },
    C(
      View,
      { style: s.itemHead },
      C(ItemNum, { n, color: accent }),
      C(Text, { style: s.itemTitle }, title),
      time && C(Text, { style: s.itemTime }, time)
    ),
    body && C(Text, { style: s.itemBody }, body),
    bullets &&
      bullets.length > 0 &&
      C(
        View,
        {},
        ...bullets.map((b, i) =>
          C(
            View,
            { key: i, style: s.itemBullet },
            C(Text, { style: s.itemBulletDot }, "›"),
            C(Text, { style: { flex: 1 } }, b)
          )
        )
      )
  );
}

function SectionHeader({ pill, pillBg, pillColor, title, sub }) {
  return C(
    View,
    { style: s.sectionWrap },
    C(
      View,
      { style: s.sectionRow },
      C(Pill, { label: pill, bg: pillBg, color: pillColor }),
      C(Text, { style: s.sectionTitle }, title)
    ),
    sub && C(Text, { style: s.sectionSub }, sub)
  );
}

function Footer({ pageNum, total, brand }) {
  return C(
    View,
    { style: s.footer, fixed: true },
    C(Text, {}, `${brand} · Document confidentiel — destiné au client`),
    C(
      Text,
      { style: s.pageNum, render: ({ pageNumber, totalPages }) => `${pageNumber} / ${totalPages}` }
    )
  );
}

// ---------- Données ----------
const TODAY = new Date().toLocaleDateString("fr-FR", {
  day: "2-digit",
  month: "long",
  year: "numeric",
});
const BRAND_NAME = "MA FORMATION TRANSPORT";

// ---------- Document ----------
function ChecklistDoc() {
  return C(
    Document,
    { title: "Checklist pré-production", author: BRAND_NAME },

    // ============ PAGE 1 ============
    C(
      Page,
      { size: "A4", style: s.page },
      C(View, { style: s.topBar }),
      C(
        View,
        { style: s.brandRow },
        C(PdfLogo, {}),
        C(
          View,
          {},
          C(Text, { style: s.brandTitle }, "MA FORMATION"),
          C(Text, { style: s.brandSubTitle }, "TRANSPORT")
        )
      ),
      C(
        Text,
        { style: s.metaLine },
        `Note technique · Préparée le ${TODAY}`
      ),

      C(Text, { style: s.h1 }, "Checklist pré-production"),
      C(
        Text,
        { style: s.intro },
        "La plateforme est fonctionnellement prête : authentification, parcours stagiaire, quiz, examens blancs, multi-formations, espace admin et exports PDF officiels sont opérationnels et testés. Cette note récapitule les actions opérationnelles restant à finaliser avant l'ouverture aux stagiaires, classées par criticité réelle."
      ),

      // SHOW-STOPPERS
      C(SectionHeader, {
        pill: "Bloquants",
        pillBg: ROSE_LIGHT,
        pillColor: ROSE,
        title: "Sans ces actions, pas de mise en ligne sérieuse",
        sub: "Délai estimé : 30 minutes à 4 heures (selon DNS).",
      }),

      C(Item, {
        n: 1,
        accent: ROSE,
        title: "Migrations base de données",
        time: "15 min",
        body:
          "Trois scripts SQL idempotents à exécuter dans l'ordre dans le SQL Editor Supabase. Sans ces migrations, deux failles persistent : un stagiaire peut techniquement lire le contenu des autres formations (perte de propriété intellectuelle), et certaines requêtes raliront fortement au-delà de 500 utilisateurs.",
        bullets: [
          "supabase/multi_formation_sprint2.sql — verrouillage RLS lecture par formation",
          "supabase/p2_indexes_and_hardening.sql — indexes composites + NOT NULL formation_id",
          "supabase/fix_autofill_formation_fallback.sql — trigger 3 paliers anti-orphelin",
        ],
      }),

      C(Item, {
        n: 2,
        accent: ROSE,
        title: "Variables d'environnement Vercel",
        time: "10 min",
        body:
          "Sans ces variables, plusieurs flux clés sont cassés : la création/suppression d'utilisateurs admin est impossible, les emails d'invitation ne partent pas, les notifications de leads ne sont pas reçues.",
        bullets: [
          "SUPABASE_SERVICE_ROLE_KEY (Supabase Dashboard → API Keys → service_role)",
          "RESEND_API_KEY + EMAIL_FROM_ADDRESS (compte gratuit resend.com)",
          "LEADS_NOTIFY_EMAIL (votre adresse pour recevoir les nouveaux leads)",
          "NEXT_PUBLIC_APP_URL (URL prod, indispensable pour les liens d'invitation)",
        ],
      }),

      C(Item, {
        n: 3,
        accent: ROSE,
        title: "SMTP custom dans Supabase Auth",
        time: "5 min",
        body:
          "Le SMTP intégré Supabase a un quota dur de 3 à 4 emails par heure (déjà rencontré en démonstration). Avec un SMTP custom Resend, le quota passe à 3 000 emails par mois en plan gratuit. Configuration : Supabase Dashboard → Authentication → SMTP Settings.",
      }),

      C(Item, {
        n: 4,
        accent: ROSE,
        title: "Domaine et certificat SSL",
        time: "Variable (DNS 2 à 4 h)",
        body:
          "Le domaine custom (à choisir et acheter) permet trois points essentiels : la vérification du domaine sur Resend pour que les emails arrivent en boîte de réception et non en spam, un certificat SSL Let's Encrypt automatique sur Vercel, et une URL professionnelle rassurante pour les stagiaires.",
      }),

      C(Item, {
        n: 5,
        accent: ROSE,
        title: "Test de restauration de backup Supabase",
        time: "30 min",
        body:
          "Les backups quotidiens sont actifs par défaut, mais le scénario de restauration n'a jamais été testé. À faire au moins une fois sur un projet Supabase de staging : restaurer un backup, vérifier que les tables critiques sont bien présentes, documenter le RTO/RPO réels (typiquement 15 à 30 minutes).",
      }),

      C(Footer, { brand: BRAND_NAME })
    ),

    // ============ PAGE 2 ============
    C(
      Page,
      { size: "A4", style: s.page },
      C(View, { style: s.topBar }),

      // IMPORTANT
      C(SectionHeader, {
        pill: "Important",
        pillBg: AMBER_LIGHT,
        pillColor: AMBER,
        title: "Qualité attendue implicitement par les stagiaires",
        sub:
          "Délai cumulé estimé : environ 2 heures.",
      }),

      C(Item, {
        n: 6,
        accent: AMBER,
        title: "Renseigner les données réelles de l'organisme",
        time: "5 min",
        body:
          "Une mise à jour SQL pour que les certificats, attestations et autres documents officiels exportés en PDF (cf. parcours certificat de réalisation, attestation Qualiopi) sortent avec le SIRET, l'adresse et les coordonnées réelles de votre organisme — pas avec les valeurs de placeholder.",
        bullets: [
          "Table public.formation_settings : organisme_nom, organisme_siret, organisme_num_da, adresse, email, téléphone, responsable pédagogique",
        ],
      }),

      C(Item, {
        n: 7,
        accent: AMBER,
        title: "Instrumenter Sentry",
        time: "15 min",
        body:
          "Sans monitoring d'erreurs, vous apprenez qu'il y a un bug uniquement quand un stagiaire vous le signale. Sentry capte chaque erreur côté client et serveur en temps réel, avec stack trace, contexte utilisateur et reproduction. Plan gratuit : 5 000 événements par mois.",
        bullets: [
          "npx @sentry/wizard@latest -i nextjs (tout est automatique)",
          "Ajouter NEXT_PUBLIC_SENTRY_DSN sur Vercel",
        ],
      }),

      C(Item, {
        n: 8,
        accent: AMBER,
        title: "Audit de contenu côté admin",
        time: "30 min à 1 h",
        body:
          "Une passe rapide en mode staff pour vérifier l'intégrité du catalogue avant la mise en ligne : toutes les formations actives ont leurs modules seedés, l'ordre d'affichage est cohérent (pas de doublon, pas de gap), chaque module a au moins un quiz d'entraînement et un examen blanc, le glossaire couvre les formations payantes.",
      }),

      C(Item, {
        n: 9,
        accent: AMBER,
        title: "Tests end-to-end",
        time: "10 min",
        body:
          "La suite Playwright est en place avec trois parcours critiques : cloisonnement multi-formation (un stagiaire ne peut pas accéder au contenu d'une autre formation), soumission complète d'un quiz mixte QCM + questions rédigées, correction manuelle par le formateur. Il reste à provisionner les comptes test dans .env.test puis npx playwright test.",
      }),

      C(Item, {
        n: 10,
        accent: AMBER,
        title: "Pages légales avec données réelles",
        time: "15 min",
        body:
          "Vérifier les pages CGU, CGV, mentions légales, politique de confidentialité avec : SIRET, adresse, email DPO, hébergeur (Vercel + Supabase), références aux droits RGPD du stagiaire (accès, rectification, effacement, portabilité). Modèles déjà rédigés, à compléter avec les données réelles.",
      }),

      C(Footer, { brand: BRAND_NAME })
    ),

    // ============ PAGE 3 ============
    C(
      Page,
      { size: "A4", style: s.page },
      C(View, { style: s.topBar }),

      // NICE TO HAVE
      C(SectionHeader, {
        pill: "Recommandé",
        pillBg: EMERALD_LIGHT,
        pillColor: EMERALD,
        title: "Polish post-lancement (optionnel)",
        sub: "À planifier dans les 30 jours suivant l'ouverture.",
      }),

      C(Item, {
        n: 11,
        accent: EMERALD,
        title: "Page de status / banner d'incident",
        body:
          "Si Vercel ou Supabase rencontrent un incident, les stagiaires voient aujourd'hui une page d'erreur générique. Une page /status ou un banner informatif rassure et limite les sollicitations support.",
      }),

      C(Item, {
        n: 12,
        accent: EMERALD,
        title: "Vidéo d'onboarding admin",
        body:
          "Une vidéo Loom de 10 minutes pour votre équipe pédagogique : comment inviter un stagiaire, gérer les leads entrants, exporter les données en CSV, traiter un email rebondi. Investissement minimal qui réduit fortement les questions de support en phase d'amorçage.",
      }),

      C(Item, {
        n: 13,
        accent: EMERALD,
        title: "Audit performance Lighthouse",
        body:
          "À lancer sur le domaine de production une fois le SSL en place. Score cible : supérieur à 85 sur mobile. Si le score est inférieur à 70, optimisations à prévoir (lazy loading des images, code splitting bundle).",
      }),

      C(Item, {
        n: 14,
        accent: EMERALD,
        title: "Page \"Mes formations\" et switcher header",
        body:
          "Pour les stagiaires inscrits à plusieurs formations simultanément, une page dédiée et un sélecteur dans le header sont préparés en backend (multi-formation Sprint 2). À activer quand un cas réel multi-inscription apparaît dans la base.",
      }),

      C(Item, {
        n: 15,
        accent: EMERALD,
        title: "Mise en avant des achievements",
        body:
          "La gamification (XP, badges, série de connexions) est en place côté base. Les composants RecentAchievements et XpWidget sont déjà sur le tableau de bord, mais peu mis en avant. Possible boost d'engagement à explorer après les premiers retours stagiaires.",
      }),

      // PLAN RECOMMANDÉ
      C(
        View,
        { style: s.timelineWrap },
        C(Text, { style: s.timelineTitle }, "Plan recommandé sur 7 jours"),
        ...[
          ["Jour 1", "Migrations SQL + variables Vercel + SMTP Resend", "30 min"],
          ["Jour 2", "Achat domaine et configuration DNS", "Variable"],
          ["Jour 3", "Test backup + données organisme + Sentry", "1 h"],
          ["Jour 4", "Audit catalogue avec un compte stagiaire test", "1-2 h"],
          ["Jour 5", "Tests e2e + finalisation pages légales", "30 min"],
          ["Jour 6", "Smoke test full parcours en production", "30 min"],
          ["Jour 7", "Buffer et résolution de tout point résiduel", "—"],
        ].map(([d, t, dur], i, a) =>
          C(
            View,
            {
              key: i,
              style: [s.timelineRow, i === a.length - 1 && s.timelineRowLast],
            },
            C(Text, { style: s.timelineDay }, d),
            C(Text, { style: s.timelineTask }, t),
            C(Text, { style: s.timelineDur }, dur)
          )
        )
      ),

      // TOTAL
      C(
        View,
        { style: s.totalBlock, wrap: false },
        C(Text, { style: s.totalTitle }, "Charge totale estimée"),
        C(
          Text,
          { style: s.totalText },
          "Environ 6 à 8 heures d'opérations étalées sur 7 jours. La plateforme est techniquement aboutie : ce qui reste relève de l'ops (DNS, comptes externes, données réelles d'organisme) et de la validation finale, pas du développement."
        )
      ),

      C(Footer, { brand: BRAND_NAME })
    )
  );
}

// ---------- Render ----------
async function main() {
  console.log("[pdf] rendering…");
  await renderToFile(C(ChecklistDoc, {}), OUTPUT);
  console.log(`[pdf] OK → ${OUTPUT}`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
