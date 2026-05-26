/**
 * Capture des captures d'écran réelles (compte stagiaire de TEST) pour le
 * dossier PDF. Aucune donnée personnelle réelle : seul le compte seedé
 * stagiaire-e2e@test.local est utilisé.
 *
 * Pré-requis : serveur dev lancé (charge .env.local) + .env.test (identifiants).
 * Lancement : E2E_BASE_URL=http://localhost:3210 npx tsx scripts/shoot-screenshots.ts
 */
import { chromium } from "@playwright/test";
import { login, dismissBanners } from "../e2e/helpers/auth";
import fs from "node:fs";

function loadEnvFile(p: string) {
  if (!fs.existsSync(p)) return;
  for (const line of fs.readFileSync(p, "utf8").split("\n")) {
    const m = /^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/.exec(line);
    if (!m) continue;
    let v = m[2].trim();
    if (
      (v.startsWith('"') && v.endsWith('"')) ||
      (v.startsWith("'") && v.endsWith("'"))
    )
      v = v.slice(1, -1);
    if (!process.env[m[1]]) process.env[m[1]] = v;
  }
}
loadEnvFile(".env.test");

const BASE = process.env.E2E_BASE_URL ?? "http://localhost:3000";
const OUT = "livraison/screenshots";
fs.mkdirSync(OUT, { recursive: true });

// État de démo découvert par _enroll-test-student.ts (quiz/module accessibles).
let state: any = {};
try {
  state = JSON.parse(fs.readFileSync(`${OUT}/_state.json`, "utf8"));
} catch {}
const quizId = process.env.SHOT_QUIZ_ID || state.quizId || process.env.E2E_QUIZ_ID || "";

const SHOTS: { name: string; path: string }[] = [
  { name: "dashboard", path: "/dashboard" },
  { name: "modules", path: "/modules" },
  ...(state.moduleSlug ? [{ name: "module", path: `/modules/${state.moduleSlug}` }] : []),
  { name: "exercices", path: "/exercices" },
  { name: "examens-blancs", path: "/examens-blancs" },
  ...(quizId ? [{ name: "quiz", path: `/quiz/${quizId}` }] : []),
  { name: "emargement", path: "/emargement" },
  { name: "stats", path: "/stats" },
  { name: "reussites", path: "/reussites" },
];

async function main() {
  const browser = await chromium.launch();
  const ctx = await browser.newContext({
    baseURL: BASE,
    viewport: { width: 1280, height: 820 },
    deviceScaleFactor: 2,
    locale: "fr-FR",
    colorScheme: "light",
  });
  const page = await ctx.newPage();

  console.log(`[shots] login sur ${BASE} ...`);
  await login(
    page,
    process.env.E2E_STUDENT_EMAIL ?? "",
    process.env.E2E_STUDENT_PASSWORD ?? ""
  );
  console.log("[shots] connecté.");

  for (const shot of SHOTS) {
    try {
      await page.goto(shot.path, { waitUntil: "networkidle", timeout: 30_000 });
      await dismissBanners(page);
      await page.waitForTimeout(1500); // laisser les animations se poser
      await page.screenshot({ path: `${OUT}/${shot.name}.png` });
      console.log(`[shots] OK  ${shot.name}  (${shot.path})  -> url=${page.url()}`);
    } catch (e: any) {
      console.log(`[shots] ECHEC ${shot.name} (${shot.path}) : ${e?.message ?? e}`);
    }
  }

  await browser.close();
  console.log("[shots] terminé.");
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
