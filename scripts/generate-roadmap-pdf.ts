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
const OUTPUT = resolve(__dirname, "output", "MFT-Roadmap-Checklist.pdf");
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
          },
        ],
      },
      {
        title: "P0 #2 — Variables d'environnement",
        steps: [
          {
            title: "Compte Resend + domaine vérifié (DKIM/SPF) pour les emails",
            detail:
              "Permet : confirmation d'inscription, reset password, notifications stagiaire.",
          },
          {
            title: "Générer CRON_SECRET et l'ajouter à Vercel",
            detail:
              "Sécurise le cron quotidien /api/cron/inactivity (relance stagiaires inactifs).",
          },
          {
            title:
              "Compte Stripe (mode Live) + clé secrète + webhook signing secret",
            detail:
              "Encaissement des inscriptions B2C et OPCO. Indispensable si ventes directes.",
          },
          {
            title: "VAPID keys pour les Web Push notifications",
            detail: "Notifications navigateur (rappels modules, corrections).",
          },
          {
            title: "Upstash Redis (optionnel) pour rate-limit auth",
            detail:
              "Protège login/signup contre brute-force. Recommandé à partir de 50 stagiaires.",
          },
          {
            title: "Renseigner toutes les vars sur Vercel (Production)",
          },
          {
            title: "Re-déployer + smoke-test sur l'URL de prod",
          },
        ],
      },
      {
        title: "P0 #3 — Domaine custom + DNS",
        steps: [
          {
            title: "Acheter le domaine maformationtransport.fr",
            detail: "Registrar recommandé : OVH, Gandi ou Cloudflare.",
          },
          {
            title:
              "Configurer les DNS chez Vercel (A/CNAME + ALIAS pour la racine)",
          },
          { title: "Vérifier la propagation (https://dnschecker.org)" },
          {
            title:
              "Activer le HTTPS automatique Vercel (Let's Encrypt managé)",
          },
          {
            title:
              "Configurer la redirection www -> racine (ou inverse selon préférence)",
          },
          {
            title:
              "Mettre à jour les emails dans Supabase (URL site dans Auth Settings)",
          },
        ],
      },
      {
        title: "P0 #4 — Tunnel Stripe end-to-end",
        steps: [
          {
            title: "Créer 1 produit Stripe par formation (avec price récurrent ou one-shot)",
          },
          {
            title:
              "Brancher /api/checkout/session sur le price_id correspondant",
          },
          {
            title:
              "Tester un paiement complet en mode Test (carte 4242 4242 4242 4242)",
          },
          {
            title:
              "Vérifier que le webhook stripe -> /api/stripe/webhook crée bien l'enrolment",
          },
          {
            title: "Activer Stripe Tax (TVA auto pour les formations) si applicable",
          },
          {
            title: "Bascule en mode Live + 1er paiement réel à 1€ par toi-même",
          },
          {
            title: "Configurer un email de réception Stripe (alertes paiements)",
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
          },
          {
            title:
              "CCP2 — Manager l'équipe de conduite (modules + études de cas)",
          },
          {
            title:
              "CCP3 — Gérer la relation client et la qualité de service",
          },
          { title: "Banque de questions QR (30+) pour la session blanche" },
          {
            title: "Vidéos pédagogiques (au moins 1 par CCP, 5–10 min chacune)",
          },
        ],
      },
      {
        title: "P1 #2 — Capacité de transport <= 3,5 t",
        steps: [
          { title: "Module 1 : Réglementation transport léger" },
          { title: "Module 2 : Gestion d'entreprise (compta, fiscal, RH)" },
          { title: "Module 3 : Sécurité et environnement" },
          { title: "Quiz blanc Capacité (calé sur le format DREAL)" },
          { title: "Examen blanc téléchargeable (PDF)" },
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
        steps: [
          {
            title:
              "Brancher Sentry (errors front + back) avec source maps Vercel",
          },
          {
            title: "Brancher PostHog (events stagiaire : start quiz, finish module...)",
          },
          {
            title: "Dashboard admin temps réel (stagiaires actifs, taux complétion)",
          },
          {
            title:
              "Alertes Slack/Email sur erreurs critiques (Sentry -> webhook)",
          },
        ],
      },
      {
        title: "P2 #2 — Tests & CI",
        steps: [
          {
            title:
              "Couverture tests unitaires (Vitest) sur lib/ critiques (markdown, scoring, utils)",
          },
          { title: "Tests d'intégration sur les routes API server actions" },
          {
            title:
              "Storybook pour les composants UI (Button, Card, ProgressBar...)",
          },
          {
            title:
              "GitHub Actions : lint + typecheck + tests E2E sur chaque PR",
          },
          {
            title:
              "Lighthouse CI : score perf/a11y/SEO sur chaque déploiement",
          },
        ],
      },
      {
        title: "P2 #3 — UX/Accessibilité",
        steps: [
          {
            title:
              "Audit WCAG 2.1 AA complet (contraste, focus visible, ARIA roles)",
          },
          {
            title: "Tests sur lecteurs d'écran (VoiceOver iOS, NVDA Windows)",
          },
          { title: "Mode sombre/clair (toggle utilisateur)" },
          { title: "PWA installable (manifest + icônes + offline minimal)" },
          { title: "Internationalisation FR/EN (next-intl)" },
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
            title: "Visioconférence intégrée (Daily.co ou LiveKit) pour cours live",
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
    .replace(/[•]/g, "·");
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
    "De la mise en production aux évolutions stratégiques V2",
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
  page.drawText("Édité le " + date, {
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
    "Quatre niveaux de priorité, chacun découpé en étapes concrètes.",
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
