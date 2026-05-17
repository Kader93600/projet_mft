// =====================================================================
// Génère un PDF "Roadmap MA FORMATION TRANSPORT" avec cases à cocher
// INTERACTIVES (clic direct dans le PDF) — étape par étape pour chaque
// priorité (P0, P1, P2, P3).
//
// Usage  : npx tsx scripts/generate-roadmap-pdf.ts
// Output : scripts/output/MFT-Roadmap-Checklist.pdf
// =====================================================================

import { PDFDocument, StandardFonts, rgb, PDFPage, PDFFont } from "pdf-lib";
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const VERSION = "v4";
const OUTPUT = resolve(__dirname, "output", `MFT-Roadmap-Checklist-${VERSION}.pdf`);
mkdirSync(dirname(OUTPUT), { recursive: true });

// ---------- Palette ----------
const NAVY = rgb(0.055, 0.071, 0.251);
const BRAND = rgb(0.145, 0.188, 0.851);
const SIGNAL = rgb(0.624, 0.886, 0.125);
const SLATE_900 = rgb(0.059, 0.09, 0.165);
const SLATE_700 = rgb(0.2, 0.255, 0.333);
const SLATE_500 = rgb(0.392, 0.455, 0.545);
const SLATE_300 = rgb(0.796, 0.835, 0.882);
const SLATE_100 = rgb(0.945, 0.961, 0.976);
const ROSE = rgb(0.882, 0.114, 0.282);
const AMBER = rgb(0.851, 0.467, 0.024);
const EMERALD = rgb(0.024, 0.588, 0.412);
const VIOLET = rgb(0.486, 0.227, 0.929);

// ---------- Layout ----------
const PAGE_W = 595.28;
const PAGE_H = 841.89;
const M_LEFT = 48;
const M_RIGHT = 48;
const M_TOP = 56;
const M_BOTTOM = 64;
const CONTENT_W = PAGE_W - M_LEFT - M_RIGHT;

// ---------- Données ----------
type Step = {
  title: string;
  detail?: string;
  done?: boolean;
};
type Section = {
  code: string; // "P0", "P1"…
  label: string; // "Bloquants pour ouverture"
  color: ReturnType<typeof rgb>;
  intro: string;
  blocks: { title: string; status?: "done" | "wip" | "todo"; steps: Step[] }[];
};

// Chantiers majeurs livrés depuis la roadmap v3 (mai 2026).
// Affichés sur la page "Ce qui a été livré récemment".
type Delivery = { title: string; desc: string };
const RECENT_DELIVERIES: Delivery[] = [
  {
    title: "Vidéos intro Capa ≤ 3,5 t — 6 modules avec player HTML5 natif",
    desc:
      "6 vidéos d'introduction (modules A à F, ~3 min chacune) hébergées dans Supabase Storage privé (bucket module-intro-videos, signed URL 1h). Composant <ModuleIntroVideo /> Server Component avec player 16:9, badge gold, durée affichée. Pipeline d'import automatisé (scripts/import-capa-intro-videos.ts) avec détection auto du module via convention de nommage + extraction durée MP4 zéro-dépendance. Infra réutilisable pour les futures vidéos GOTRM/CCP3.",
  },
  {
    title: "Banque QR CCP1 — 66 exercices rédigés + 23 annexes",
    desc:
      "Import automatisé via scripts/import-ccp1-qr.ts à partir des 89 PDFs client : 66 QR (17 chapitres) + 23 annexes PDF uploadées dans le bucket Storage privé. Format pro (bandeau navy, sections contexte/travail/annexe colorées, tableaux préservés). Compatible correction formateur, scoring, statistiques, examens blancs.",
  },
  {
    title: "GOTRM complet — CCP3 importé (Optimiser les moyens du transport)",
    desc:
      "Le CCP3 du Titre Pro GOTRM est en ligne : 12 chapitres / 72 leçons (management d'équipe, CCNTR, temps de service, prépaie, formation pro, recrutement, QVCT, coûts d'exploitation, seuil de rentabilité, SIG/BFR/FRNG/CAF, budget, qualité). Avec CCP1 + CCP2 déjà livrés, le titre complet (RNCP 40990) est désormais accessible aux stagiaires.",
  },
  {
    title: "i18n FR / EN — Parcours stagiaire 100 % bilingue",
    desc:
      "27 namespaces, ~600 clés. Login, dashboard, modules, exercices, examens blancs, expérience quiz complète (intro + runner + résultats), accompagnement, sessions Premium, home publique, tarifs. Toggle FR/EN dans la topbar + cookie NEXT_LOCALE persistant 1 an.",
  },
  {
    title: "Observabilité — Sentry + PostHog + Dashboard admin",
    desc:
      "Sentry @sentry/nextjs avec tunnel /monitoring (anti-adblock) côté front et back. PostHog Cloud EU via /ingest. Dashboard admin temps réel : KPIs stagiaires actifs, funnel d'acquisition, heatmap d'usage, filtre par période, exports PDF, mode TV pour les bureaux.",
  },
  {
    title: "Tests & CI — Vitest + GitHub Actions + Lighthouse + Storybook",
    desc:
      "126 tests unitaires Vitest (lib/permissions, markdown, scoring, parsers, email, admin-guard). Workflow GitHub Actions complet (lint + typecheck + tests + E2E Playwright + Lighthouse CI). Storybook 8 pour les composants UI. Tests d'intégration sur les server actions.",
  },
  {
    title: "UX / A11y — Dark mode + PWA installable + WCAG 2.1 AA",
    desc:
      "Dark mode complet via CSS variables (--bg, --surface, --text, --border). PWA installable avec manifest + maskable icons + shortcuts + service worker offline. Skip links, focus visible, aria-labels conformes WCAG 2.1 AA.",
  },
  {
    title: "P0 #1 levé — CI E2E branchée sur GitHub Actions",
    desc:
      "Dernière tâche P0 résolue. Le pipeline CI .github/workflows/e2e.yml exécute désormais les 9 tests E2E Playwright sur chaque PR. La plateforme est 25/25 sur les bloquants d'ouverture.",
  },
];

const SECTIONS: Section[] = [
  {
    code: "P0",
    label: "Bloquants pour ouverture",
    color: ROSE,
    intro:
      "Tâches indispensables avant d'ouvrir la plateforme aux premiers stagiaires. Aucune ne peut être reportée.",
    blocks: [
      {
        title: "P0 #1 — Tests E2E verts (qualité produit)",
        status: "done",
        steps: [
          { title: "Créer le seed de test e2e_seed.sql", done: true },
          {
            title: "Aligner les helpers Playwright (auth, dismiss banners)",
            done: true,
          },
          {
            title:
              "Corriger les 3 bugs prod découverts par les tests (passed nullable, RLS formateur, compteur QR)",
            done: true,
          },
          {
            title: "Atteindre 9/9 tests verts en local (~47s)",
            done: true,
          },
          {
            title: "Brancher le pipeline CI (GitHub Actions) sur les tests E2E",
            done: true,
            detail: "Workflow .github/workflows/e2e.yml actif sur chaque PR.",
          },
        ],
      },
      {
        title: "P0 #2 — Variables d'environnement",
        status: "done",
        steps: [
          {
            title: "Compte Resend + domaine vérifié (DKIM/SPF) pour les emails",
            detail:
              "Opérationnel — confirmations, reset password, notifications.",
            done: true,
          },
          {
            title: "Générer CRON_SECRET et l'ajouter à Vercel",
            detail: "Cron quotidien /api/cron/inactivity actif.",
            done: true,
          },
          {
            title:
              "Compte Stripe (mode Live) + clé secrète + webhook signing secret",
            detail: "Encaissements opérationnels.",
            done: true,
          },
          {
            title: "VAPID keys pour les Web Push notifications",
            detail: "Rappels modules / corrections / sessions live actifs.",
            done: true,
          },
          {
            title: "Upstash Redis (optionnel) pour rate-limit auth",
            detail: "Brute-force protection en place.",
            done: true,
          },
          {
            title: "Renseigner toutes les vars sur Vercel (Production)",
            done: true,
          },
          {
            title: "Re-déployer + smoke-test sur l'URL de prod",
            detail: "https://maformationtransport.fr en ligne.",
            done: true,
          },
        ],
      },
      {
        title: "P0 #3 — Domaine custom + DNS",
        status: "done",
        steps: [
          { title: "Acheter le domaine maformationtransport.fr", done: true },
          {
            title:
              "Configurer les DNS chez Vercel (A/CNAME + ALIAS pour la racine)",
            done: true,
          },
          {
            title: "Vérifier la propagation (https://dnschecker.org)",
            done: true,
          },
          {
            title: "Activer le HTTPS automatique Vercel (Let's Encrypt managé)",
            detail: "Certificat SSL actif.",
            done: true,
          },
          { title: "Configurer la redirection www -> racine", done: true },
          {
            title:
              "Mettre à jour les emails dans Supabase (URL site dans Auth Settings)",
            done: true,
          },
        ],
      },
      {
        title: "P0 #4 — Tunnel Stripe end-to-end",
        status: "done",
        steps: [
          {
            title:
              "Créer 1 produit Stripe par formation (price récurrent ou one-shot)",
            done: true,
          },
          {
            title: "Brancher /api/checkout/session sur le price_id correspondant",
            done: true,
          },
          {
            title:
              "Tester un paiement complet en mode Test (carte 4242 4242 4242 4242)",
            done: true,
          },
          {
            title:
              "Vérifier que le webhook stripe -> /api/stripe/webhook crée bien l'enrolment",
            done: true,
          },
          {
            title:
              "Activer Stripe Tax (TVA auto pour les formations) si applicable",
            done: true,
          },
          {
            title: "Bascule en mode Live + 1er paiement réel à 1€ par toi-même",
            done: true,
          },
          {
            title: "Configurer un email de réception Stripe (alertes paiements)",
            done: true,
          },
        ],
      },
    ],
  },
  {
    code: "P1",
    label: "Contenu pédagogique à enrichir",
    color: AMBER,
    intro:
      "Tâches de contenu — la plateforme fonctionne, mais il faut remplir les modules pour qu'elle soit utile.",
    blocks: [
      {
        title: "P1 #1 — Compléter la formation GOTRM (RNCP 40990)",
        steps: [
          {
            title: "CCP1 — Organiser et superviser l'exploitation (modules + quiz)",
            detail: "17 chapitres + examen blanc final + 18 quiz d'entraînement.",
            done: true,
          },
          {
            title:
              "CCP2 — Manager l'équipe de conduite (modules + études de cas)",
            detail: "Cours générés depuis PDF : 12 chapitres / 74 leçons.",
            done: true,
          },
          {
            title:
              "CCP3 — Gérer la relation client et la qualité de service",
            detail: "12 chapitres / 72 leçons importés depuis le PDF client.",
            done: true,
          },
          {
            title: "Banque de questions QR (30+) pour la session blanche",
            detail: "66 QR importés depuis les PDFs client (17 chapitres) + 23 annexes liées dans Storage.",
            done: true,
          },
          {
            title: "Vidéos pédagogiques (au moins 1 par CCP, 5–10 min chacune)",
          },
        ],
      },
      {
        title: "P1 #2 — Capacité de transport <= 3,5 t",
        status: "done",
        steps: [
          {
            title: "Module A — Droit civil et commercial",
            detail: "540 min, 5 leçons, 5 quiz.",
            done: true,
          },
          {
            title: "Module B — L'entreprise et son activité commerciale",
            done: true,
          },
          {
            title:
              "Module C — Cadre réglementaire du transport (DREAL, CRSR, CGT)",
            done: true,
          },
          {
            title: "Module D — Activité financière (compta, bilan, coût kilométrique)",
            done: true,
          },
          { title: "Module E — Salariés et droit social", done: true },
          {
            title: "Module F — Sécurité (FIMO/FCO, ADR, véhicule)",
            done: true,
          },
          {
            title: "Examen blanc Capacité (calé sur le format DREAL)",
            done: true,
          },
        ],
      },
      {
        title: "P1 #3 — Autres formations transport",
        steps: [
          { title: "FIMO/FCO marchandises (modules d'introduction)" },
          { title: "Taxi / VTC (modules réglementation locale)" },
          { title: "ADR Matières dangereuses (option différée)" },
        ],
      },
      {
        title: "P1 #4 — Médias",
        steps: [
          {
            title: "Tournage vidéo intro formateur (1 min, page d'accueil)",
          },
          {
            title:
              "Photos formateurs + témoignages stagiaires (page À propos / Témoignages)",
          },
          {
            title:
              "Visuels formations (1 image hero par formation, optimisée WebP)",
          },
        ],
      },
    ],
  },
  {
    code: "P2",
    label: "Qualité & Observabilité",
    color: BRAND,
    intro:
      "Améliorations techniques pour scaler proprement (50+ stagiaires actifs, équipe formateurs).",
    blocks: [
      {
        title: "P2 #1 — Monitoring & analytics",
        status: "done",
        steps: [
          {
            title:
              "Brancher Sentry (errors front + back) avec source maps Vercel",
            detail: "Projet javascript-nextjs connecté · dashboard actif sur sentry.io.",
            done: true,
          },
          {
            title:
              "Brancher PostHog (events stagiaire : start quiz, finish module...)",
            detail:
              "Cloud EU via tunnel /ingest (anti-adblock). Events trackés automatiquement.",
            done: true,
          },
          {
            title:
              "Dashboard admin temps réel (stagiaires actifs, taux complétion)",
            detail:
              "Lot 1 + Lot 2 : KPIs, Funnel, Heatmap, filtre période, exports PDF, Mode TV.",
            done: true,
          },
          {
            title:
              "Alertes Slack/Email sur erreurs critiques (Sentry -> webhook)",
            detail:
              "3 règles actives sur sentry.io : Nouvelle erreur production · Pic d'erreurs détecté · Erreur route critique.",
            done: true,
          },
        ],
      },
      {
        title: "P2 #2 — Tests & CI",
        status: "done",
        steps: [
          {
            title:
              "Couverture tests unitaires (Vitest) sur lib/ critiques (markdown, scoring, utils)",
            detail: "126 tests verts dans 9 fichiers (lib/permissions, markdown, parsers, admin-guard...).",
            done: true,
          },
          {
            title: "Tests d'intégration sur les routes API server actions",
            detail: "Server actions critiques couvertes (email, admin-guard).",
            done: true,
          },
          {
            title:
              "Storybook pour les composants UI (Button, Card, ProgressBar...)",
            detail: "Storybook 8 + addons (a11y, viewport, themes).",
            done: true,
          },
          {
            title:
              "GitHub Actions : lint + typecheck + tests E2E sur chaque PR",
            detail: "Workflows ci.yml + e2e.yml + lighthouse.yml actifs.",
            done: true,
          },
          {
            title:
              "Lighthouse CI : score perf/a11y/SEO sur chaque déploiement",
            detail: ".lighthouserc.json + assertions sur score >= 90.",
            done: true,
          },
        ],
      },
      {
        title: "P2 #3 — UX/Accessibilité",
        steps: [
          {
            title:
              "Audit WCAG 2.1 AA complet (contraste, focus visible, ARIA roles)",
            detail: "Skip links, focus visible, aria-labels, contraste vérifié.",
            done: true,
          },
          {
            title: "Tests sur lecteurs d'écran (VoiceOver iOS, NVDA Windows)",
          },
          {
            title: "Mode sombre/clair (toggle utilisateur)",
            detail:
              "ThemeToggle + CSS variables (--bg, --surface, --text, --border) propagées partout.",
            done: true,
          },
          {
            title: "PWA installable (manifest + icônes + offline minimal)",
            detail:
              "manifest.webmanifest + maskable icons + shortcuts + service worker offline.",
            done: true,
          },
          {
            title: "Internationalisation FR/EN (next-intl)",
            detail:
              "27 namespaces · ~600 clés · toggle FR/EN dans la topbar · parcours stagiaire 100 % bilingue.",
            done: true,
          },
        ],
      },
    ],
  },
  {
    code: "P3",
    label: "Roadmap V2 — Croissance",
    color: VIOLET,
    intro:
      "Évolutions stratégiques après 6 mois de production. À discuter avec le client selon traction.",
    blocks: [
      {
        title: "P3 #1 — Pédagogie augmentée",
        steps: [
          {
            title: "Visioconférence intégrée pour cours live",
            detail:
              "Livré via Phase 7 : intégration Zoom · Teams · Meet pour les sessions Premium.",
            done: true,
          },
          {
            title:
              "IA tuteur (RAG sur les modules) — chatbot stagiaire personnalisé",
          },
          {
            title:
              "Application mobile (React Native ou PWA renforcée) pour modules offline",
          },
          {
            title: "Gamification : badges, leaderboard, séries de jours",
          },
        ],
      },
      {
        title: "P3 #2 — Business & comptes pros",
        steps: [
          {
            title: "Multi-tenant (1 espace dédié par entreprise cliente)",
          },
          {
            title:
              "Dashboard financeur (OPCO, Pôle Emploi) avec exports CSV/PDF",
          },
          {
            title:
              "Programme d'affiliation (lien parrainage + commission auto)",
          },
          {
            title:
              "Marketplace de formateurs externes (les formateurs créent et vendent leurs propres parcours)",
          },
        ],
      },
      {
        title: "P3 #3 — Marketing & data",
        steps: [
          {
            title:
              "Stats communication automatisées (Instagram/LinkedIn -> dashboard interne)",
          },
          {
            title:
              "Funnel d'acquisition complet (UTM tracking + attribution multi-touch)",
          },
          { title: "CRM léger intégré (suivi des prospects en pré-inscription)" },
          {
            title:
              "Programme de fidélité (réduction sur 2ᵉ formation, certificat doré)",
          },
        ],
      },
    ],
  },
];

// ---------- Helpers dessin ----------
// WinAnsi couvre Latin-1 + quelques signes typographiques mais pas
// les exposants/flèches/maths Unicode. On normalise pour rester safe.
function sanitize(text: string): string {
  return text
    .replace(/[ᵉ]/g, "e")
    .replace(/[ᵃ]/g, "a")
    .replace(/[ᵒ]/g, "o")
    .replace(/[→]/g, "->")
    .replace(/[←]/g, "<-")
    .replace(/[≤]/g, "<=")
    .replace(/[≥]/g, ">=")
    .replace(/[•]/g, "·")
    .replace(/[✓]/g, "v")
    .replace(/[✗✕]/g, "x")
    .replace(/[…]/g, "...");
}
function wrapText(
  text: string,
  font: PDFFont,
  size: number,
  maxWidth: number,
): string[] {
  const clean = sanitize(text);
  const words = clean.split(/\s+/);
  const lines: string[] = [];
  let current = "";
  for (const word of words) {
    const test = current ? current + " " + word : word;
    if (font.widthOfTextAtSize(test, size) > maxWidth) {
      if (current) lines.push(current);
      current = word;
    } else {
      current = test;
    }
  }
  if (current) lines.push(current);
  return lines;
}

// ---------- Génération ----------
async function main() {
  const pdf = await PDFDocument.create();
  pdf.setTitle("MA FORMATION TRANSPORT — Roadmap & Checklist");
  pdf.setAuthor("MA FORMATION TRANSPORT");
  pdf.setSubject("Plan de lancement étape par étape avec cases à cocher interactives");
  pdf.setCreator("scripts/generate-roadmap-pdf.ts");

  const fontReg = await pdf.embedFont(StandardFonts.Helvetica);
  const fontBold = await pdf.embedFont(StandardFonts.HelveticaBold);
  const fontItalic = await pdf.embedFont(StandardFonts.HelveticaOblique);

  const form = pdf.getForm();
  let checkboxCounter = 0;

  type Cursor = { page: PDFPage; y: number; pageIndex: number };

  function newPage(): Cursor {
    const page = pdf.addPage([PAGE_W, PAGE_H]);
    // Footer minimal — numérotation ajoutée à la fin
    return { page, y: PAGE_H - M_TOP, pageIndex: pdf.getPageCount() };
  }

  function ensureSpace(c: Cursor, needed: number): Cursor {
    if (c.y - needed < M_BOTTOM) return newPage();
    return c;
  }

  let cur = newPage();

  // ----- Page de garde -----
  drawCover(cur.page, fontBold, fontReg, fontItalic);
  cur = newPage();

  // ----- Sommaire / résumé -----
  drawSummaryHeader(cur.page, fontBold, fontReg);
  cur.y = PAGE_H - M_TOP - 110;

  // Carte spéciale "Livré récemment"
  cur.page.drawRectangle({
    x: M_LEFT,
    y: cur.y - 38,
    width: CONTENT_W,
    height: 44,
    color: rgb(0.96, 0.99, 0.93),
    borderColor: EMERALD,
    borderWidth: 1.2,
  });
  cur.page.drawRectangle({
    x: M_LEFT,
    y: cur.y - 38,
    width: 6,
    height: 44,
    color: EMERALD,
  });
  // Pastille verte avec coche dessinée à la main
  cur.page.drawCircle({
    x: M_LEFT + 22,
    y: cur.y - 16,
    size: 7,
    color: EMERALD,
  });
  cur.page.drawLine({
    start: { x: M_LEFT + 19, y: cur.y - 16 },
    end: { x: M_LEFT + 22, y: cur.y - 19 },
    thickness: 1.5,
    color: rgb(1, 1, 1),
  });
  cur.page.drawLine({
    start: { x: M_LEFT + 22, y: cur.y - 19 },
    end: { x: M_LEFT + 26, y: cur.y - 13 },
    thickness: 1.5,
    color: rgb(1, 1, 1),
  });
  cur.page.drawText("Livré depuis la dernière roadmap", {
    x: M_LEFT + 36,
    y: cur.y - 14,
    size: 12,
    font: fontBold,
    color: NAVY,
  });
  cur.page.drawText(
    `${RECENT_DELIVERIES.length} chantiers complets  ·  voir page 3`,
    {
      x: M_LEFT + 18,
      y: cur.y - 30,
      size: 9,
      font: fontReg,
      color: SLATE_700,
    },
  );
  cur.y -= 56;

  for (const sec of SECTIONS) {
    const totalSteps = sec.blocks.reduce((acc, b) => acc + b.steps.length, 0);
    const doneSteps = sec.blocks.reduce(
      (acc, b) => acc + b.steps.filter((s) => s.done).length,
      0,
    );
    cur.page.drawRectangle({
      x: M_LEFT,
      y: cur.y - 38,
      width: CONTENT_W,
      height: 44,
      color: SLATE_100,
      borderColor: sec.color,
      borderWidth: 1.2,
    });
    cur.page.drawRectangle({
      x: M_LEFT,
      y: cur.y - 38,
      width: 6,
      height: 44,
      color: sec.color,
    });
    cur.page.drawText(sec.code + " — " + sec.label, {
      x: M_LEFT + 18,
      y: cur.y - 14,
      size: 12,
      font: fontBold,
      color: NAVY,
    });
    cur.page.drawText(`${doneSteps}/${totalSteps} tâches complétées`, {
      x: M_LEFT + 18,
      y: cur.y - 30,
      size: 9,
      font: fontReg,
      color: SLATE_700,
    });
    cur.y -= 56;
  }

  // Jalon
  cur.y -= 4;
  cur.page.drawRectangle({
    x: M_LEFT,
    y: cur.y - 56,
    width: CONTENT_W,
    height: 60,
    color: rgb(0.96, 0.99, 0.93),
    borderColor: SIGNAL,
    borderWidth: 1.4,
  });
  cur.page.drawText("Jalon « Plateforme commercialisable »", {
    x: M_LEFT + 18,
    y: cur.y - 22,
    size: 11.5,
    font: fontBold,
    color: NAVY,
  });
  cur.page.drawText(
    sanitize(
      "Tous les P0 sont levés + observabilité prod + plateforme bilingue FR/EN.",
    ),
    {
      x: M_LEFT + 18,
      y: cur.y - 40,
      size: 9.5,
      font: fontReg,
      color: SLATE_700,
    },
  );

  // ----- Page "Livré récemment" -----
  cur = newPage();
  drawRecentDeliveries(cur.page, fontBold, fontReg, fontItalic);

  // ----- Sections -----
  for (const sec of SECTIONS) {
    cur = newPage();
    drawSectionHeader(cur.page, sec, fontBold, fontReg);
    cur.y = PAGE_H - M_TOP - 130;

    for (const block of sec.blocks) {
      // Titre du bloc
      cur = ensureSpace(cur, 60);
      cur.page.drawText(block.title, {
        x: M_LEFT,
        y: cur.y,
        size: 13,
        font: fontBold,
        color: NAVY,
      });
      // Trait sous le titre
      cur.page.drawLine({
        start: { x: M_LEFT, y: cur.y - 5 },
        end: { x: M_LEFT + 60, y: cur.y - 5 },
        thickness: 2,
        color: sec.color,
      });
      cur.y -= 22;

      for (const step of block.steps) {
        // Wrap titre + détail
        const titleLines = wrapText(step.title, fontReg, 10.5, CONTENT_W - 36);
        const detailLines = step.detail
          ? wrapText(step.detail, fontItalic, 9, CONTENT_W - 36)
          : [];
        const lineHeight = 13;
        const detailLineHeight = 11;
        const blockH =
          titleLines.length * lineHeight +
          detailLines.length * detailLineHeight +
          (detailLines.length ? 4 : 0) +
          10;

        cur = ensureSpace(cur, blockH);

        // Checkbox interactive
        const cbX = M_LEFT;
        const cbY = cur.y - 11;
        const cbSize = 12;
        checkboxCounter += 1;
        const cb = form.createCheckBox(`task_${checkboxCounter}`);
        cb.addToPage(cur.page, {
          x: cbX,
          y: cbY,
          width: cbSize,
          height: cbSize,
          borderColor: sec.color,
          backgroundColor: rgb(1, 1, 1),
          borderWidth: 1.2,
        });
        if (step.done) cb.check();

        // Texte titre
        const textX = M_LEFT + 22;
        let yy = cur.y;
        for (let i = 0; i < titleLines.length; i++) {
          cur.page.drawText(titleLines[i], {
            x: textX,
            y: yy,
            size: 10.5,
            font: step.done ? fontReg : fontBold,
            color: step.done ? SLATE_500 : SLATE_900,
          });
          // strike-through si done
          if (step.done) {
            const w = fontReg.widthOfTextAtSize(titleLines[i], 10.5);
            cur.page.drawLine({
              start: { x: textX, y: yy + 3 },
              end: { x: textX + w, y: yy + 3 },
              thickness: 0.6,
              color: SLATE_500,
            });
          }
          yy -= lineHeight;
        }
        // Détail
        if (detailLines.length) {
          yy -= 2;
          for (const l of detailLines) {
            cur.page.drawText(l, {
              x: textX,
              y: yy,
              size: 9,
              font: fontItalic,
              color: SLATE_500,
            });
            yy -= detailLineHeight;
          }
        }
        cur.y = yy - 6;
      }
      cur.y -= 8;
    }
  }

  // ----- Page finale : signatures -----
  cur = newPage();
  drawClosing(cur.page, fontBold, fontReg, fontItalic, form);

  // ----- Footer (numérotation) -----
  const total = pdf.getPageCount();
  for (let i = 0; i < total; i++) {
    const p = pdf.getPage(i);
    p.drawText(`MA FORMATION TRANSPORT  ·  Roadmap & Checklist`, {
      x: M_LEFT,
      y: 28,
      size: 8,
      font: fontReg,
      color: SLATE_500,
    });
    const pageStr = `Page ${i + 1} / ${total}`;
    const w = fontReg.widthOfTextAtSize(pageStr, 8);
    p.drawText(pageStr, {
      x: PAGE_W - M_RIGHT - w,
      y: 28,
      size: 8,
      font: fontReg,
      color: SLATE_500,
    });
    // Liseré bas
    p.drawLine({
      start: { x: M_LEFT, y: 42 },
      end: { x: PAGE_W - M_RIGHT, y: 42 },
      thickness: 0.5,
      color: SLATE_300,
    });
  }

  const bytes = await pdf.save();
  writeFileSync(OUTPUT, bytes);
  console.log("✅ PDF généré :", OUTPUT);
  console.log(`   ${checkboxCounter} cases à cocher interactives`);
  console.log(`   ${total} pages`);
}

// ---------- Couvertures / sections ----------
function drawCover(
  page: PDFPage,
  bold: PDFFont,
  reg: PDFFont,
  italic: PDFFont,
) {
  // Bandeau navy plein
  page.drawRectangle({
    x: 0,
    y: PAGE_H - 280,
    width: PAGE_W,
    height: 280,
    color: NAVY,
  });
  // Bande signal en bas du bandeau
  page.drawRectangle({
    x: 0,
    y: PAGE_H - 286,
    width: PAGE_W,
    height: 6,
    color: SIGNAL,
  });
  // Eyebrow
  page.drawText("PLAN DE LANCEMENT  ·  PRÉSENTATION CLIENT", {
    x: M_LEFT,
    y: PAGE_H - 90,
    size: 9,
    font: bold,
    color: SIGNAL,
  });
  // Titre
  page.drawText("Roadmap", {
    x: M_LEFT,
    y: PAGE_H - 145,
    size: 42,
    font: bold,
    color: rgb(1, 1, 1),
  });
  page.drawText("MA FORMATION TRANSPORT", {
    x: M_LEFT,
    y: PAGE_H - 195,
    size: 22,
    font: reg,
    color: rgb(1, 1, 1),
  });
  page.drawText(
    "Plateforme bilingue + observabilité production — V4",
    {
      x: M_LEFT,
      y: PAGE_H - 230,
      size: 11,
      font: italic,
      color: rgb(0.85, 0.88, 0.95),
    },
  );

  // Bloc d'intro
  page.drawText("Comment lire ce document", {
    x: M_LEFT,
    y: PAGE_H - 330,
    size: 13,
    font: bold,
    color: NAVY,
  });
  const intro =
    "Ce document liste les étapes de lancement et d'évolution de la plateforme, regroupées par niveau de priorité. Chaque tâche est associée à une case à cocher interactive : vous pouvez cocher directement dans le PDF (lecteur Acrobat, Aperçu, navigateur).";
  const lines = wrapText(intro, reg, 10.5, CONTENT_W);
  let y = PAGE_H - 354;
  for (const l of lines) {
    page.drawText(l, { x: M_LEFT, y, size: 10.5, font: reg, color: SLATE_700 });
    y -= 14;
  }

  // Légende des niveaux
  const legend = [
    { code: "P0", label: "Bloquants pour ouverture", color: ROSE },
    { code: "P1", label: "Contenu pédagogique", color: AMBER },
    { code: "P2", label: "Qualité & observabilité", color: BRAND },
    { code: "P3", label: "Roadmap V2 (croissance)", color: VIOLET },
  ];
  y -= 16;
  page.drawText("Niveaux de priorité", {
    x: M_LEFT,
    y,
    size: 13,
    font: bold,
    color: NAVY,
  });
  y -= 22;
  for (const item of legend) {
    page.drawRectangle({
      x: M_LEFT,
      y: y - 4,
      width: 14,
      height: 14,
      color: item.color,
    });
    page.drawText(item.code, {
      x: M_LEFT + 24,
      y,
      size: 11,
      font: bold,
      color: NAVY,
    });
    page.drawText("— " + item.label, {
      x: M_LEFT + 50,
      y,
      size: 11,
      font: reg,
      color: SLATE_700,
    });
    y -= 22;
  }

  // Date
  const date = new Date().toLocaleDateString("fr-FR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  });
  page.drawText("Édité le " + date + "  ·  Version 4", {
    x: M_LEFT,
    y: 80,
    size: 9,
    font: italic,
    color: SLATE_500,
  });
}

function drawSummaryHeader(page: PDFPage, bold: PDFFont, reg: PDFFont) {
  page.drawText("SOMMAIRE", {
    x: M_LEFT,
    y: PAGE_H - M_TOP,
    size: 9,
    font: bold,
    color: SLATE_500,
  });
  page.drawText("Vue d'ensemble", {
    x: M_LEFT,
    y: PAGE_H - M_TOP - 30,
    size: 22,
    font: bold,
    color: NAVY,
  });
  page.drawText(
    "Quatre niveaux de priorité, plus un récapitulatif des livraisons récentes.",
    {
      x: M_LEFT,
      y: PAGE_H - M_TOP - 54,
      size: 10.5,
      font: reg,
      color: SLATE_700,
    },
  );
  page.drawLine({
    start: { x: M_LEFT, y: PAGE_H - M_TOP - 70 },
    end: { x: M_LEFT + 60, y: PAGE_H - M_TOP - 70 },
    thickness: 2,
    color: SIGNAL,
  });
}

// Page dédiée — récap des chantiers livrés depuis la roadmap v3.
function drawRecentDeliveries(
  page: PDFPage,
  bold: PDFFont,
  reg: PDFFont,
  italic: PDFFont,
) {
  // Bandeau navy + bande signal
  page.drawRectangle({
    x: 0,
    y: PAGE_H - 110,
    width: PAGE_W,
    height: 110,
    color: NAVY,
  });
  page.drawRectangle({
    x: 0,
    y: PAGE_H - 116,
    width: PAGE_W,
    height: 6,
    color: SIGNAL,
  });
  // Eyebrow
  page.drawRectangle({
    x: M_LEFT,
    y: PAGE_H - 60,
    width: 110,
    height: 22,
    color: SIGNAL,
  });
  page.drawText("LIVRÉ MAI 2026", {
    x: M_LEFT + 10,
    y: PAGE_H - 54,
    size: 10,
    font: bold,
    color: NAVY,
  });
  page.drawText("Ce qui a été livré récemment", {
    x: M_LEFT,
    y: PAGE_H - 95,
    size: 22,
    font: bold,
    color: rgb(1, 1, 1),
  });

  let y = PAGE_H - 160;
  page.drawText(
    `${RECENT_DELIVERIES.length} chantiers majeurs livrés en production depuis la roadmap v3.`,
    {
      x: M_LEFT,
      y,
      size: 10.5,
      font: reg,
      color: SLATE_700,
    },
  );
  y -= 24;

  for (const d of RECENT_DELIVERIES) {
    const titleLines = wrapText(d.title, bold, 11.5, CONTENT_W - 24);
    const descLines = wrapText(d.desc, reg, 9.5, CONTENT_W - 24);
    const blockH =
      titleLines.length * 14 + descLines.length * 12 + 22;

    // Carte
    page.drawRectangle({
      x: M_LEFT,
      y: y - blockH + 8,
      width: CONTENT_W,
      height: blockH,
      color: rgb(0.97, 0.99, 0.94),
      borderColor: EMERALD,
      borderWidth: 1,
    });
    // Liseré gauche
    page.drawRectangle({
      x: M_LEFT,
      y: y - blockH + 8,
      width: 4,
      height: blockH,
      color: EMERALD,
    });

    let yy = y;
    // Pastille LIVRÉ
    page.drawText("LIVRÉ", {
      x: M_LEFT + CONTENT_W - 50,
      y: yy - 4,
      size: 8.5,
      font: bold,
      color: EMERALD,
    });
    for (const l of titleLines) {
      page.drawText(l, {
        x: M_LEFT + 16,
        y: yy,
        size: 11.5,
        font: bold,
        color: NAVY,
      });
      yy -= 14;
    }
    yy -= 2;
    for (const l of descLines) {
      page.drawText(l, {
        x: M_LEFT + 16,
        y: yy,
        size: 9.5,
        font: reg,
        color: SLATE_700,
      });
      yy -= 12;
    }
    y -= blockH + 8;
  }
}

function drawSectionHeader(
  page: PDFPage,
  sec: Section,
  bold: PDFFont,
  reg: PDFFont,
) {
  // Bandeau couleur
  page.drawRectangle({
    x: 0,
    y: PAGE_H - 90,
    width: PAGE_W,
    height: 90,
    color: NAVY,
  });
  page.drawRectangle({
    x: 0,
    y: PAGE_H - 96,
    width: PAGE_W,
    height: 6,
    color: sec.color,
  });
  page.drawText(sec.code, {
    x: M_LEFT,
    y: PAGE_H - 50,
    size: 32,
    font: bold,
    color: sec.color,
  });
  page.drawText(sec.label, {
    x: M_LEFT + 70,
    y: PAGE_H - 50,
    size: 18,
    font: bold,
    color: rgb(1, 1, 1),
  });
  // Sous-titre
  const intro = wrapText(sec.intro, reg, 10, CONTENT_W);
  let y = PAGE_H - 75;
  for (const l of intro) {
    page.drawText(l, {
      x: M_LEFT + 70,
      y,
      size: 9.5,
      font: reg,
      color: rgb(0.85, 0.88, 0.95),
    });
    y -= 12;
  }
}

function drawClosing(
  page: PDFPage,
  bold: PDFFont,
  reg: PDFFont,
  italic: PDFFont,
  form: ReturnType<PDFDocument["getForm"]>,
) {
  page.drawRectangle({
    x: 0,
    y: PAGE_H - 90,
    width: PAGE_W,
    height: 90,
    color: NAVY,
  });
  page.drawRectangle({
    x: 0,
    y: PAGE_H - 96,
    width: PAGE_W,
    height: 6,
    color: SIGNAL,
  });
  page.drawText("Validation", {
    x: M_LEFT,
    y: PAGE_H - 50,
    size: 24,
    font: bold,
    color: rgb(1, 1, 1),
  });
  page.drawText("Document de cadrage — accord client", {
    x: M_LEFT,
    y: PAGE_H - 75,
    size: 11,
    font: italic,
    color: rgb(0.85, 0.88, 0.95),
  });

  let y = PAGE_H - 140;
  page.drawText("Notes & remarques client", {
    x: M_LEFT,
    y,
    size: 13,
    font: bold,
    color: NAVY,
  });
  y -= 16;
  // Champ texte multiligne
  const tf = form.createTextField("notes_client");
  tf.enableMultiline();
  tf.addToPage(page, {
    x: M_LEFT,
    y: y - 110,
    width: CONTENT_W,
    height: 110,
    borderColor: SLATE_300,
    backgroundColor: SLATE_100,
  });
  y -= 130;

  // Signatures
  y -= 30;
  page.drawText("Signatures", {
    x: M_LEFT,
    y,
    size: 13,
    font: bold,
    color: NAVY,
  });
  y -= 28;

  const colW = (CONTENT_W - 24) / 2;
  // Client
  page.drawText("Client", {
    x: M_LEFT,
    y,
    size: 10,
    font: bold,
    color: SLATE_700,
  });
  const tfNomClient = form.createTextField("nom_client");
  tfNomClient.addToPage(page, {
    x: M_LEFT,
    y: y - 26,
    width: colW,
    height: 22,
    borderColor: SLATE_300,
  });
  page.drawText("Nom & date", {
    x: M_LEFT,
    y: y - 38,
    size: 8,
    font: italic,
    color: SLATE_500,
  });

  // Prestataire
  page.drawText("MA FORMATION TRANSPORT", {
    x: M_LEFT + colW + 24,
    y,
    size: 10,
    font: bold,
    color: SLATE_700,
  });
  const tfNomMft = form.createTextField("nom_mft");
  tfNomMft.addToPage(page, {
    x: M_LEFT + colW + 24,
    y: y - 26,
    width: colW,
    height: 22,
    borderColor: SLATE_300,
  });
  page.drawText("Nom & date", {
    x: M_LEFT + colW + 24,
    y: y - 38,
    size: 8,
    font: italic,
    color: SLATE_500,
  });

  // Footer info
  page.drawText(
    "Document conçu pour être complété directement dans un lecteur PDF (Acrobat Reader, Aperçu macOS, Chrome, Firefox).",
    {
      x: M_LEFT,
      y: 90,
      size: 8.5,
      font: italic,
      color: SLATE_500,
    },
  );
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
