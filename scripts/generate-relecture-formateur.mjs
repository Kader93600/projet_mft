// =====================================================================
// Génère le dossier de relecture formateur : toutes les questions
// rédigées (QR) dont le corrigé contient une donnée réglementaire
// marquée « À CONFIRMER » / « NON VÉRIFIÉ » par les agents de rédaction.
//
// Sources des marqueurs :
//   1. Commentaires des 3 fichiers de corrigés (supabase/2026_07_13_
//      corriges_qr_capa_leger.sql, 2026_07_14_corriges_qr_gotrm.sql,
//      2026_07_14_corriges_qr_6formations.sql), rattachés par source_ref
//   2. Marqueurs présents dans le texte des corrigés en base
//
// Usage : node --env-file=.env.local scripts/generate-relecture-formateur.mjs
// Sorties : livraison/relecture-corriges-formateur.{html,csv}
//           (PDF : imprimer le HTML, cf. tâche appelante)
// =====================================================================

import { readFileSync, writeFileSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const URL_BASE = process.env.NEXT_PUBLIC_SUPABASE_URL;
const KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
if (!URL_BASE || !KEY) {
  console.error("env manquantes (NEXT_PUBLIC_SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY)");
  process.exit(1);
}
const HEADERS = { apikey: KEY, Authorization: `Bearer ${KEY}` };

async function rest(path) {
  const res = await fetch(`${URL_BASE}/rest/v1/${path}`, { headers: HEADERS });
  if (!res.ok) throw new Error(`${path} → ${res.status} ${await res.text()}`);
  return res.json();
}

/* ── 1. Parse des marqueurs dans les fichiers SQL ───────────────────── */
const FILES = [
  "supabase/2026_07_13_corriges_qr_capa_leger.sql",
  "supabase/2026_07_14_corriges_qr_gotrm.sql",
  "supabase/2026_07_14_corriges_qr_6formations.sql",
];
// Formats : «-- ⚠️ À CONFIRMER [ref] : note»  et  «-- ⚠️ REF : note»
const RE_BRACKET = /^--\s*⚠️\s*À CONFIRMER\s*\[([^\]]+)\]\s*:\s*(.+)$/u;
const RE_PLAIN = /^--\s*⚠️\s*([A-Z0-9][A-Za-z0-9\-_.:#]+)\s*:\s*(.+)$/u;

const byRef = new Map(); // source_ref → { note }
for (const rel of FILES) {
  const lines = readFileSync(resolve(ROOT, rel), "utf-8").split("\n");
  for (const line of lines) {
    const m = line.match(RE_BRACKET) || line.match(RE_PLAIN);
    if (!m) continue;
    const [, ref, note] = m;
    if (/des 370|corrigés portent/.test(line)) continue; // lignes d'entête
    const prev = byRef.get(ref);
    byRef.set(ref, { note: prev ? prev.note + " • " + note.trim() : note.trim() });
  }
}
console.log("marqueurs fichiers :", byRef.size);

/* ── 2. Charge la banque (QR) + référentiels ────────────────────────── */
const [formations, modules] = await Promise.all([
  rest("formations?select=id,slug,title"),
  rest("modules?select=id,title"),
]);
const fById = new Map(formations.map((f) => [f.id, f]));
const mById = new Map(modules.map((m) => [m.id, m]));

const qrs = [];
for (let from = 0; ; from += 500) {
  const page = await rest(
    `question_bank?type=eq.qr&select=id,source_ref,statement,expected_answer,formation_id,module_id&order=id&limit=500&offset=${from}`,
  );
  qrs.push(...page);
  if (page.length < 500) break;
}
console.log("QR en base :", qrs.length);

/* ── 3. Fusion : marqueurs fichiers + marqueurs dans le texte en base ── */
/** Énoncés stockés en HTML riche (TipTap) → texte brut lisible. */
function plainText(s) {
  return String(s ?? "")
    .replace(/<[^>]+>/g, " ")
    .replace(/&nbsp;/g, " ")
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&(?:rsquo|#8217);/g, "'")
    .replace(/&(?:eacute|#233);/g, "é")
    .replace(/\s+/g, " ")
    .trim();
}

/* ── Filtre : verdicts de la passe de validation sourcée (23/07) ─────
   livraison/validation-corriges.json : les items "confirme" (donnée
   vérifiée exacte) et "applique" (corrigé rectifié en base) sortent du
   dossier ; seuls les "irresolu" restent à l'arbitrage du formateur. */
let resolved = new Set();
try {
  const validation = JSON.parse(readFileSync(resolve(ROOT, "livraison/validation-corriges.json"), "utf-8"));
  resolved = new Set(validation.filter((v) => v.statut !== "irresolu").map((v) => v.id));
  console.log("items résolus par la validation :", resolved.size);
} catch {
  console.log("(pas de fichier de validation : dossier complet)");
}

const IN_TEXT = /(À CONFIRMER|NON VÉRIFIÉ)/u;
const items = [];
for (const q of qrs) {
  const fromFile = byRef.get(q.source_ref ?? "");
  const inText = IN_TEXT.test(q.expected_answer ?? "");
  if (!fromFile && !inText) continue;
  if (resolved.has(q.id)) continue; // validé par la passe sourcée du 23/07
  let note = fromFile?.note ?? "";
  if (inText) {
    // Extrait les segments [À CONFIRMER ...] du corrigé lui-même
    const segs = (q.expected_answer.match(/\[(?:À CONFIRMER|NON VÉRIFIÉ)[^\]]*\]/gu) ?? [])
      .map((s) => s.slice(1, -1).trim());
    if (segs.length) note = note ? note + " • " + segs.join(" • ") : segs.join(" • ");
    else if (!note) note = "Marqueur présent dans le corrigé (voir texte complet en admin).";
  }
  const f = fById.get(q.formation_id) ?? { slug: "?", title: "Formation inconnue" };
  items.push({
    formation: f.title, slug: f.slug,
    module: mById.get(q.module_id)?.title ?? "Hors module",
    ref: q.source_ref ?? q.id,
    id: q.id,
    question: plainText(q.statement).slice(0, 240),
    note: note.replace(/\s+/g, " "),
  });
}
items.sort((a, b) => a.formation.localeCompare(b.formation) || a.module.localeCompare(b.module) || a.ref.localeCompare(b.ref));
console.log("questions à relire :", items.length);

/* ── 4. CSV (suivi Excel, UTF-8 BOM, séparateur ;) ──────────────────── */
const esc = (s) => `"${String(s).replace(/"/g, '""')}"`;
const csv = ["﻿Formation;Module;Référence;Question;Point à vérifier;Statut (à remplir)"]
  .concat(items.map((i) => [i.formation, i.module, i.ref, i.question, i.note, ""].map(esc).join(";")))
  .join("\n");
writeFileSync(resolve(ROOT, "livraison/relecture-corriges-formateur.csv"), csv);

/* ── 5. HTML imprimable (charte MFT) ────────────────────────────────── */
const groups = new Map();
for (const i of items) {
  if (!groups.has(i.formation)) groups.set(i.formation, []);
  groups.get(i.formation).push(i);
}
const escH = (s) => String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
let sections = "";
for (const [formation, list] of groups) {
  sections += `
  <section>
    <h2><span>${escH(formation)}</span><em>${list.length} corrigé${list.length > 1 ? "s" : ""} à relire</em></h2>
    ${list.map((i) => `
    <article>
      <div class="check">☐</div>
      <div class="body">
        <div class="meta">${escH(i.module)} · <code>${escH(i.ref)}</code></div>
        <div class="q">${escH(i.question)}${i.question.length >= 240 ? "…" : ""}</div>
        <div class="note"><b>À vérifier :</b> ${escH(i.note)}</div>
      </div>
    </article>`).join("")}
  </section>`;
}
const html = `<!doctype html><html lang="fr"><head><meta charset="utf-8">
<title>Relecture des corrigés — dossier formateur</title>
<style>
  :root { --navy:#0E1240; --ink:#0f172a; --soft:#64748b; --line:#e2e8f0; --lime:#5a7f12; }
  * { margin:0; padding:0; box-sizing:border-box; }
  body { font:10.5pt/1.5 -apple-system,"Segoe UI",Roboto,sans-serif; color:var(--ink); padding:34px 40px; }
  header { border-bottom:3px solid var(--navy); padding-bottom:14px; margin-bottom:20px; }
  .eyebrow { font-size:8.5pt; letter-spacing:.18em; font-weight:700; color:var(--lime); }
  h1 { font-size:19pt; color:var(--navy); letter-spacing:-.01em; margin-top:4px; }
  .lead { color:var(--soft); font-size:9.5pt; margin-top:6px; max-width:70ch; }
  section { margin-top:18px; break-inside:auto; }
  h2 { display:flex; justify-content:space-between; align-items:baseline; font-size:12.5pt; color:var(--navy);
       border-bottom:1px solid var(--line); padding-bottom:5px; margin-bottom:8px; break-after:avoid; }
  h2 em { font:600 8.5pt/1 inherit; color:var(--soft); font-style:normal; }
  article { display:flex; gap:10px; padding:8px 0; border-bottom:1px solid var(--line); break-inside:avoid; }
  .check { font-size:13pt; color:var(--navy); line-height:1.2; }
  .meta { font-size:8pt; color:var(--soft); text-transform:uppercase; letter-spacing:.06em; }
  .meta code { text-transform:none; letter-spacing:0; background:#f1f5f9; padding:1px 4px; border-radius:3px; }
  .q { font-weight:600; margin-top:2px; }
  .note { margin-top:3px; font-size:9.5pt; color:#334155; background:#fffbeb; border:1px solid #fde68a;
          border-radius:6px; padding:5px 8px; }
  .note b { color:#92400e; }
  footer { margin-top:22px; font-size:8pt; color:var(--soft); }
  @page { margin: 12mm 10mm; }
</style></head><body>
<header>
  <div class="eyebrow">DOSSIER DE RELECTURE FORMATEUR</div>
  <h1>Corrigés à valider avant usage certifiant</h1>
  <p class="lead">Lors de la rédaction des réponses modèles, chaque donnée réglementaire incertaine a été
  volontairement signalée plutôt qu'inventée. Une passe de validation sourcée (23/07/2026) a vérifié
  chaque point contre les sources officielles : 86 confirmés et 35 corrigés en base (voir le rapport
  de validation joint). Ce dossier liste les ${items.length} questions RESTANTES :
  des arbitrages pédagogiques (énoncé à clarifier, convention de correction) plutôt que des faits : pour chacune, vérifier le point signalé, corriger le corrigé si besoin dans
  Admin → Banque de questions (référence indiquée), puis cocher. Généré le ${new Date().toLocaleDateString("fr-FR")}.</p>
</header>
${sections}
<footer>MA FORMATION TRANSPORT · Relecture des corrigés · ${items.length} éléments · Compagnon tableur : relecture-corriges-formateur.csv</footer>
</body></html>`;
writeFileSync(resolve(ROOT, "livraison/relecture-corriges-formateur.html"), html);
console.log("écrit : livraison/relecture-corriges-formateur.{html,csv}");
