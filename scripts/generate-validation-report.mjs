// =====================================================================
// Génère le rapport de validation sourcée des corrigés signalés :
// pour chaque point « À CONFIRMER », le verdict du fact-checking
// (recherche officielle + contre-vérification adversariale du 23/07),
// la justification et la source.
// Source de données : livraison/validation-corriges.json
// Usage : node --env-file=.env.local scripts/generate-validation-report.mjs
// Sortie : livraison/rapport-validation-corriges.html (PDF via Chromium)
// =====================================================================

import { readFileSync, writeFileSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const URL_BASE = process.env.NEXT_PUBLIC_SUPABASE_URL;
const KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
const H = { apikey: KEY, Authorization: `Bearer ${KEY}` };
async function rest(path) {
  const res = await fetch(`${URL_BASE}/rest/v1/${path}`, { headers: H });
  if (!res.ok) throw new Error(`${path} → ${res.status}`);
  return res.json();
}

const items = JSON.parse(readFileSync(resolve(ROOT, "livraison/validation-corriges.json"), "utf-8"));
const [formations, qrs] = await Promise.all([
  rest("formations?select=id,title"),
  (async () => {
    const all = [];
    for (let from = 0; ; from += 500) {
      const p = await rest(`question_bank?type=eq.qr&select=id,formation_id&order=id&limit=500&offset=${from}`);
      all.push(...p);
      if (p.length < 500) break;
    }
    return all;
  })(),
]);
const fById = new Map(formations.map((f) => [f.id, f.title]));
const formationOf = new Map(qrs.map((q) => [q.id, fById.get(q.formation_id) ?? "?"]));

const esc = (s) => String(s ?? "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
const srcLink = (s) => /^https?:\/\//.test(s) ? `<a href="${esc(s)}">${esc(s.replace(/^https?:\/\/(www\.)?/, "").split("/")[0])}</a>` : esc(s);

const byStatus = { applique: [], confirme: [], irresolu: [] };
for (const i of items) (byStatus[i.statut] ?? byStatus.irresolu).push(i);
for (const list of Object.values(byStatus)) {
  list.sort((a, b) => (formationOf.get(a.id) + a.ref).localeCompare(formationOf.get(b.id) + b.ref));
}

const corrRows = byStatus.applique.map((i) => `
  <article class="corr">
    <div class="meta">${esc(formationOf.get(i.id))} · <code>${esc(i.ref)}</code></div>
    <div class="just">${esc(i.justification)}</div>
    ${(i.remplacements ?? []).map((r) => `
    <div class="diff">
      <div class="old">${esc(r.ancien)}</div>
      <div class="new">${esc(r.nouveau)}</div>
    </div>`).join("")}
    <div class="src">Source : ${srcLink(i.source)}</div>
  </article>`).join("");

const confRows = byStatus.confirme.map((i) => `
  <tr><td><div class="meta">${esc(formationOf.get(i.id))}</div><code>${esc(i.ref)}</code></td>
  <td>${esc(i.justification)}<div class="src">Source : ${srcLink(i.source)}</div></td></tr>`).join("");

const irrRows = byStatus.irresolu.map((i) => `
  <tr><td><div class="meta">${esc(formationOf.get(i.id))}</div><code>${esc(i.ref)}</code></td>
  <td>${esc(i.justification)}</td></tr>`).join("");

const html = `<!doctype html><html lang="fr"><head><meta charset="utf-8">
<title>Rapport de validation des corrigés signalés</title>
<style>
  :root { --navy:#0E1240; --ink:#0f172a; --soft:#64748b; --line:#e2e8f0; --lime:#5a7f12; }
  * { margin:0; padding:0; box-sizing:border-box; }
  body { font:9.5pt/1.5 -apple-system,"Segoe UI",Roboto,sans-serif; color:var(--ink); padding:32px 38px; }
  header { border-bottom:3px solid var(--navy); padding-bottom:14px; }
  .eyebrow { font-size:8.5pt; letter-spacing:.18em; font-weight:700; color:var(--lime); }
  h1 { font-size:18pt; color:var(--navy); margin-top:4px; letter-spacing:-.01em; }
  .lead { color:var(--soft); font-size:9pt; margin-top:6px; max-width:75ch; }
  .stats { display:flex; gap:10px; margin:14px 0 4px; }
  .stat { flex:1; border:1px solid var(--line); border-radius:8px; padding:9px 12px; }
  .stat b { font-size:15pt; color:var(--navy); display:block; }
  .stat span { font-size:7.5pt; color:var(--soft); text-transform:uppercase; letter-spacing:.08em; }
  h2 { font-size:12.5pt; color:var(--navy); margin:20px 0 8px; break-after:avoid; }
  .meta { font-size:7.5pt; color:var(--soft); text-transform:uppercase; letter-spacing:.06em; }
  code { font-size:8pt; background:#f1f5f9; padding:1px 4px; border-radius:3px; }
  .corr { border:1px solid var(--line); border-radius:8px; padding:9px 12px; margin-bottom:8px; break-inside:avoid; }
  .just { margin-top:3px; }
  .diff { margin-top:6px; font-size:8.5pt; border-left:none; }
  .diff .old { background:#fef2f2; border:1px solid #fecaca; border-radius:5px 5px 0 0; padding:4px 8px; color:#7f1d1d; text-decoration:line-through; }
  .diff .new { background:#f0fdf4; border:1px solid #bbf7d0; border-top:none; border-radius:0 0 5px 5px; padding:4px 8px; color:#14532d; }
  .src { margin-top:5px; font-size:8pt; color:var(--soft); }
  .src a { color:var(--navy); }
  table { width:100%; border-collapse:collapse; }
  td { border-bottom:1px solid var(--line); padding:6px 8px 6px 0; vertical-align:top; }
  td:first-child { width:24%; }
  footer { margin-top:20px; font-size:7.5pt; color:var(--soft); }
  @page { margin:12mm 10mm; }
</style></head><body>
<header>
  <div class="eyebrow">RAPPORT DE VALIDATION · 23/07/2026</div>
  <h1>Validation sourcée des corrigés signalés</h1>
  <p class="lead">Les 166 points réglementaires marqués « À CONFIRMER » à la rédaction ont été vérifiés
  un par un contre les sources officielles (Légifrance, service-public, textes en vigueur en 2026),
  chaque correction proposée étant re-vérifiée par un contrôle contradictoire indépendant avant
  application. Les corrections retenues sont déjà appliquées dans la banque de questions.</p>
  <div class="stats">
    <div class="stat"><b>166</b><span>points vérifiés</span></div>
    <div class="stat"><b>86</b><span>confirmés exacts</span></div>
    <div class="stat"><b>35</b><span>corrigés en base</span></div>
    <div class="stat"><b>45</b><span>arbitrages formateur</span></div>
  </div>
</header>

<h2>1. Corrections appliquées dans la banque de questions (35)</h2>
${corrRows}

<h2>2. Données confirmées exactes (86)</h2>
<table>${confRows}</table>

<h2>3. Restent à l'arbitrage du formateur (45)</h2>
<p class="lead" style="margin-bottom:6px">Principalement des choix pédagogiques : énoncés à clarifier,
conventions de calcul propres à la grille de correction, annexes à fournir. Détail opérationnel dans
le dossier « relecture-corriges-formateur ».</p>
<table>${irrRows}</table>

<footer>MA FORMATION TRANSPORT · Validation des corrigés · méthode : recherche officielle + contre-vérification contradictoire · données : livraison/validation-corriges.json</footer>
</body></html>`;
writeFileSync(resolve(ROOT, "livraison/rapport-validation-corriges.html"), html);
console.log("écrit : livraison/rapport-validation-corriges.html");
