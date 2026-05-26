/* eslint-disable */
// =====================================================================
// Génère le PowerPoint d'audit/présentation — Formation Capacité ≤ 3,5 t
// Destiné à l'administration française. Charte MA FORMATION TRANSPORT.
//   node scripts/build-pptx.js
//   -> livraison/capacite-3-5t-audit-administration.pptx
// =====================================================================
const pptxgen = require("pptxgenjs");
const React = require("react");
const ReactDOMServer = require("react-dom/server");
const sharp = require("sharp");
const FA = require("react-icons/fa");

// ─── Charte ──────────────────────────────────────────────────────────
const C = {
  night: "0B0F24",
  navy: "0E1240",
  navy2: "161B3D",
  brand: "2530D9",
  lime: "9FE220",
  lime700: "5C8A0F",
  gold: "A16207",
  ivory: "FAF8F4",
  surface: "F1EEE7",
  paper: "FFFFFF",
  ink: "0E1240",
  slate: "44506B",
  muted: "6B7793",
  faint: "9AA3B8",
  border: "E4DFD5",
  borderDark: "242C55",
  white: "FFFFFF",
  whiteDim: "C7CCDA",
};
const W = 13.333, H = 7.5, M = 0.75;
const SHOT_ASPECT = 820 / 1280; // h/w des captures

const mkShadow = (o = {}) => ({
  type: "outer", color: "0E1240", blur: o.blur ?? 9,
  offset: o.offset ?? 3, angle: 135, opacity: o.opacity ?? 0.12,
});

// ─── Rasterisation SVG/icônes ────────────────────────────────────────
async function svgToPng(svg, px = 320) {
  const buf = await sharp(Buffer.from(svg)).resize(px, px, { fit: "contain", background: { r: 0, g: 0, b: 0, alpha: 0 } }).png().toBuffer();
  return "image/png;base64," + buf.toString("base64");
}
async function iconPng(Comp, color = "#9FE220", px = 256) {
  const svg = ReactDOMServer.renderToStaticMarkup(React.createElement(Comp, { color, size: String(px) }));
  const buf = await sharp(Buffer.from(svg)).png().toBuffer();
  return "image/png;base64," + buf.toString("base64");
}

const LOGO_SVG = `<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
<circle cx="50" cy="50" r="46" fill="#0E1240" stroke="#9FE220" stroke-width="3"/>
<path d="M37 80 L46 44 L54 44 L63 80 Z" fill="#9FE220"/>
<rect x="48.8" y="68" width="2.4" height="7" fill="#0E1240"/>
<rect x="49" y="55" width="2" height="6" fill="#0E1240"/>
<path d="M30 38 L50 29 L70 38 L50 47 Z" fill="#FFFFFF"/>
<path d="M62 42.5 L62 51" stroke="#9FE220" stroke-width="2.2"/>
<circle cx="62" cy="52.6" r="2.2" fill="#9FE220"/></svg>`;

const ICONS = {
  route: FA.FaRoute, cap: FA.FaGraduationCap, student: FA.FaUserGraduate,
  trainer: FA.FaChalkboardTeacher, admin: FA.FaUserShield, crown: FA.FaCrown,
  sign: FA.FaFileSignature, clip: FA.FaClipboardCheck, book: FA.FaBookOpen,
  trophy: FA.FaTrophy, chart: FA.FaChartLine, shield: FA.FaShieldAlt,
  lock: FA.FaLock, cloud: FA.FaCloud, check: FA.FaCheckCircle, bell: FA.FaBell,
  file: FA.FaFileAlt, users: FA.FaUsers, db: FA.FaDatabase, cal: FA.FaCalendarCheck,
  euro: FA.FaEuroSign, id: FA.FaIdCard, upload: FA.FaCloudUploadAlt, list: FA.FaClipboardList,
  cog: FA.FaCog, pen: FA.FaPenFancy, video: FA.FaVideo, tags: FA.FaTags,
  inbox: FA.FaInbox, archive: FA.FaArchive, server: FA.FaServer, handshake: FA.FaHandshake,
  compass: FA.FaCompass, gauge: FA.FaTachometerAlt, medal: FA.FaMedal,
};

// =====================================================================
async function main() {
  const pres = new pptxgen();
  pres.defineLayout({ name: "MFT", width: W, height: H });
  pres.layout = "MFT";
  pres.author = "MA FORMATION TRANSPORT";
  pres.title = "Capacité ≤ 3,5 t — Dossier de présentation (administration)";

  const LOGO = await svgToPng(LOGO_SVG, 360);
  const IC = {}; // icônes lime
  const ICW = {}; // icônes blanches
  for (const [k, Comp] of Object.entries(ICONS)) {
    IC[k] = await iconPng(Comp, "#9FE220");
    ICW[k] = await iconPng(Comp, "#FFFFFF");
  }
  const ICN = {
    check: await iconPng(FA.FaCheckCircle, "#5C8A0F"),
  };

  let pageNo = 0;
  const TOTAL = 20;

  // ── Helpers de mise en page ────────────────────────────────────────
  function footer(slide, dark = false) {
    pageNo++;
    const col = dark ? C.faint : C.muted;
    if (!dark) slide.addShape(pres.shapes.LINE, { x: M, y: 7.04, w: W - 2 * M, h: 0, line: { color: C.border, width: 0.75 } });
    slide.addText("MA FORMATION TRANSPORT  ·  Capacité de transport ≤ 3,5 t", { x: M, y: 7.08, w: 8, h: 0.3, fontSize: 8, color: col, align: "left", fontFace: "Calibri", margin: 0 });
    slide.addText(`Confidentiel · destiné à l'administration · ${pageNo}/${TOTAL}`, { x: W - M - 5, y: 7.08, w: 5, h: 0.3, fontSize: 8, color: col, align: "right", fontFace: "Calibri", margin: 0 });
  }
  function eyebrow(slide, text, dark = false, y = 0.52) {
    slide.addText(text.toUpperCase(), { x: M, y, w: W - 2 * M, h: 0.3, fontSize: 11, bold: true, color: dark ? C.lime : C.lime700, charSpacing: 3, fontFace: "Calibri", margin: 0 });
  }
  function title(slide, text, dark = false, y = 0.82, size = 30) {
    slide.addText(text, { x: M, y, w: W - 2 * M, h: 0.9, fontSize: size, bold: true, color: dark ? C.white : C.navy, fontFace: "Calibri", margin: 0, lineSpacingMultiple: 1.0 });
  }
  function logoMark(slide, x, y, d, withText = true, dark = false) {
    slide.addImage({ data: LOGO, x, y, w: d, h: d });
    if (withText) {
      slide.addText([
        { text: "MA FORMATION\n", options: { bold: true, color: dark ? C.white : C.brand, fontSize: 12 } },
        { text: "TRANSPORT", options: { bold: true, color: dark ? C.lime : C.lime700, fontSize: 12 } },
      ], { x: x + d + 0.12, y: y - 0.04, w: 2.6, h: d + 0.1, fontFace: "Calibri", valign: "middle", lineSpacingMultiple: 0.95, margin: 0 });
    }
  }
  function pill(slide, x, y, text, dark = false) {
    const w = 0.16 + text.length * 0.072;
    slide.addShape(pres.shapes.ROUNDED_RECTANGLE, { x, y, w, h: 0.34, rectRadius: 0.17, fill: { color: dark ? C.navy2 : C.surface }, line: { color: dark ? C.borderDark : C.border, width: 0.75 } });
    slide.addText(text, { x, y, w, h: 0.34, fontSize: 9, bold: true, color: dark ? C.lime : C.lime700, align: "center", valign: "middle", fontFace: "Calibri", charSpacing: 1, margin: 0 });
    return w;
  }
  function badge(slide, x, y, d, key, dark = false) {
    slide.addShape(pres.shapes.OVAL, { x, y, w: d, h: d, fill: { color: dark ? C.navy2 : C.navy } });
    const p = d * 0.27;
    slide.addImage({ data: IC[key], x: x + p, y: y + p, w: d - 2 * p, h: d - 2 * p });
  }
  // Carte "icône + titre + texte"
  function infoCard(slide, x, y, w, h, key, head, body, opts = {}) {
    slide.addShape(pres.shapes.RECTANGLE, { x, y, w, h, fill: { color: C.paper }, line: { color: C.border, width: 0.75 }, shadow: mkShadow() });
    badge(slide, x + 0.22, y + 0.22, 0.52, key);
    slide.addText(head, { x: x + 0.9, y: y + 0.2, w: w - 1.05, h: 0.5, fontSize: 12.5, bold: true, color: C.navy, fontFace: "Calibri", valign: "middle", margin: 0 });
    if (body) slide.addText(body, { x: x + 0.24, y: y + 0.82, w: w - 0.48, h: h - 0.95, fontSize: 9.5, color: C.slate, fontFace: "Calibri", valign: "top", margin: 0, lineSpacingMultiple: 1.02 });
  }
  // Capture dans un cadre "navigateur"
  function shot(slide, imgPath, x, y, w, urlLabel) {
    const barH = 0.3;
    const imgH = w * SHOT_ASPECT;
    slide.addShape(pres.shapes.RECTANGLE, { x, y, w, h: barH + imgH, fill: { color: C.paper }, line: { color: C.border, width: 1 }, shadow: mkShadow({ blur: 12, offset: 4, opacity: 0.16 }) });
    slide.addShape(pres.shapes.RECTANGLE, { x, y, w, h: barH, fill: { color: C.navy } });
    [["F87171", 0], ["FBBF24", 0.16], ["9FE220", 0.32]].forEach(([c, dx]) =>
      slide.addShape(pres.shapes.OVAL, { x: x + 0.14 + dx, y: y + barH / 2 - 0.05, w: 0.1, h: 0.1, fill: { color: c } }));
    slide.addShape(pres.shapes.ROUNDED_RECTANGLE, { x: x + 0.7, y: y + 0.05, w: w - 1.0, h: barH - 0.1, rectRadius: 0.08, fill: { color: C.navy2 } });
    slide.addText(urlLabel, { x: x + 0.8, y: y + 0.04, w: w - 1.2, h: barH - 0.08, fontSize: 7.5, color: C.whiteDim, valign: "middle", fontFace: "Calibri", margin: 0 });
    slide.addImage({ path: imgPath, x, y: y + barH, w, h: imgH });
    return barH + imgH;
  }
  function bullets(slide, x, y, w, items, dark = false, size = 11.5, gap = 9) {
    slide.addText(items.map((t, i) => ({
      text: t,
      options: { bullet: { code: "2022", indent: 14 }, color: dark ? C.whiteDim : C.slate, breakLine: true, paraSpaceAfter: gap },
    })), { x, y, w, h: 4.5, fontSize: size, fontFace: "Calibri", color: dark ? C.whiteDim : C.slate, valign: "top", margin: 0, lineSpacingMultiple: 1.04 });
  }
  // ligne "check + texte"
  function checkRow(slide, x, y, w, head, body) {
    slide.addImage({ data: ICN.check, x, y: y + 0.02, w: 0.2, h: 0.2 });
    slide.addText([
      { text: head + "  ", options: { bold: true, color: C.navy } },
      { text: body || "", options: { color: C.slate } },
    ], { x: x + 0.32, y: y - 0.04, w: w - 0.32, h: 0.5, fontSize: 10, fontFace: "Calibri", valign: "top", margin: 0, lineSpacingMultiple: 1.0 });
  }

  // =================================================================
  // 1 — TITRE (sombre)
  // =================================================================
  {
    const s = pres.addSlide();
    s.background = { color: C.night };
    s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: W, h: 0.12, fill: { color: C.lime } });
    logoMark(s, M, 0.5, 0.6, true, true);
    s.addText("DOSSIER DE PRÉSENTATION  ·  AUDIT & VALIDATION", { x: M, y: 2.5, w: 11, h: 0.4, fontSize: 13, bold: true, color: C.lime, charSpacing: 3, fontFace: "Calibri", margin: 0 });
    s.addText([
      { text: "Formation Capacité de transport\n", options: { color: C.white } },
      { text: "de marchandises ", options: { color: C.white } },
      { text: "(≤ 3,5 t)", options: { color: C.lime } },
    ], { x: M, y: 3.0, w: 11.8, h: 1.9, fontSize: 44, bold: true, fontFace: "Calibri", lineSpacingMultiple: 1.0, margin: 0 });
    s.addText("MA FORMATION TRANSPORT — organisme de formation certifié Qualiopi, spécialisé dans les métiers du transport routier.", { x: M, y: 4.95, w: 9.6, h: 0.7, fontSize: 14, color: C.whiteDim, fontFace: "Calibri", margin: 0, lineSpacingMultiple: 1.05 });
    let px = M;
    ["QUALIOPI CW202525-4287", "NDA 11 77 09 47177", "DREETS ÎLE-DE-FRANCE", "SIRET 908 851 280 00028"].forEach((t) => { px += pill(s, px, 5.8, t, true) + 0.16; });
    s.addText("Document destiné à l'administration  ·  Édition mai 2026", { x: M, y: 6.95, w: 11, h: 0.3, fontSize: 9, color: C.faint, fontFace: "Calibri", margin: 0 });
  }

  // =================================================================
  // 2 — SOMMAIRE (clair)
  // =================================================================
  {
    const s = pres.addSlide();
    s.background = { color: C.ivory };
    eyebrow(s, "Sommaire");
    title(s, "Ce que présente ce dossier");
    const items = [
      "Présentation de l'école et de la formation",
      "Le parcours d'inscription d'un stagiaire",
      "L'expérience et le suivi du stagiaire",
      "Le rôle des formateurs",
      "Le rôle de l'administration",
      "Conformité et exigences Qualiopi",
      "La technique, expliquée simplement",
      "Pilotage et analytics",
      "Conclusion",
    ];
    const colX = [M, 7.0];
    items.forEach((it, i) => {
      const col = i < 5 ? 0 : 1;
      const row = col === 0 ? i : i - 5;
      const x = colX[col], y = 1.95 + row * 0.92;
      s.addShape(pres.shapes.OVAL, { x, y, w: 0.5, h: 0.5, fill: { color: C.navy } });
      s.addText(String(i + 1).padStart(2, "0"), { x, y, w: 0.5, h: 0.5, fontSize: 13, bold: true, color: C.lime, align: "center", valign: "middle", fontFace: "Calibri", margin: 0 });
      s.addText(it, { x: x + 0.7, y, w: 5.0, h: 0.5, fontSize: 13, bold: true, color: C.navy, valign: "middle", fontFace: "Calibri", margin: 0 });
    });
    footer(s);
  }

  // =================================================================
  // 3 — INTRODUCTION : école + identité
  // =================================================================
  {
    const s = pres.addSlide();
    s.background = { color: C.ivory };
    eyebrow(s, "01 · Introduction");
    title(s, "MA FORMATION TRANSPORT");
    s.addText("Centre de formation français spécialisé dans les métiers du transport routier de marchandises et de voyageurs. La plateforme est l'école en ligne de l'organisme : elle digitalise tout le parcours, de l'inscription à la certification, tout en industrialisant la traçabilité administrative attendue d'un organisme certifié Qualiopi.", { x: M, y: 1.75, w: 7.1, h: 1.7, fontSize: 12.5, color: C.slate, fontFace: "Calibri", margin: 0, lineSpacingMultiple: 1.06 });
    s.addText("Notre vision", { x: M, y: 3.5, w: 6, h: 0.4, fontSize: 14, bold: true, color: C.navy, fontFace: "Calibri", margin: 0 });
    const vis = [
      "Maximiser la réussite des stagiaires aux examens officiels",
      "Offrir une expérience d'apprentissage moderne et engageante",
      "Garantir une conformité administrative complète et prouvable",
    ];
    bullets(s, M, 3.95, 7.0, vis, false, 12, 8);
    // Carte identité (droite)
    const cx = 8.15, cw = W - M - cx;
    s.addShape(pres.shapes.RECTANGLE, { x: cx, y: 1.75, w: cw, h: 4.95, fill: { color: C.navy }, shadow: mkShadow({ blur: 12, offset: 4, opacity: 0.18 }) });
    s.addShape(pres.shapes.RECTANGLE, { x: cx, y: 1.75, w: cw, h: 0.1, fill: { color: C.lime } });
    s.addText("CARTE D'IDENTITÉ DE L'ORGANISME", { x: cx + 0.35, y: 2.05, w: cw - 0.7, h: 0.3, fontSize: 10, bold: true, color: C.lime, charSpacing: 2, fontFace: "Calibri", margin: 0 });
    const idRows = [
      ["Raison sociale", "MA FORMATION TRANSPORT (SAS)"],
      ["SIRET", "908 851 280 00028"],
      ["Code APE", "8559B — Autres enseignements"],
      ["N° déclaration (NDA)", "11 77 09 47177 · DREETS Île-de-France"],
      ["Certification", "Qualiopi CW202525-4287 (BCI France)"],
      ["Siège", "39 av. des Sablons Bouillants, 77100 Meaux"],
      ["Hébergement", "Union européenne (datacenters Paris / Francfort)"],
    ];
    let yy = 2.5;
    idRows.forEach(([k, v]) => {
      s.addText(k.toUpperCase(), { x: cx + 0.35, y: yy, w: cw - 0.7, h: 0.22, fontSize: 8, bold: true, color: C.faint, charSpacing: 1, fontFace: "Calibri", margin: 0 });
      s.addText(v, { x: cx + 0.35, y: yy + 0.2, w: cw - 0.7, h: 0.32, fontSize: 11, bold: true, color: C.white, fontFace: "Calibri", margin: 0 });
      yy += 0.57;
    });
    footer(s);
  }

  // =================================================================
  // 4 — FOCUS Capacité ≤ 3,5 t
  // =================================================================
  {
    const s = pres.addSlide();
    s.background = { color: C.ivory };
    eyebrow(s, "01 · Introduction");
    title(s, "Focus : la Capacité de transport (≤ 3,5 t)");
    s.addText("Attestation de capacité professionnelle permettant d'exercer l'activité de transporteur routier léger de marchandises (véhicules de 3,5 tonnes et moins). La plateforme prépare le stagiaire à l'examen, avec un parcours en six modules couvrant l'ensemble du programme réglementaire.", { x: M, y: 1.7, w: W - 2 * M, h: 0.95, fontSize: 12.5, color: C.slate, fontFace: "Calibri", margin: 0, lineSpacingMultiple: 1.05 });
    const mods = [
      ["A", "Droit civil & commercial", "book"],
      ["B", "Gestion commerciale", "chart"],
      ["C", "Réglementation transport", "shield"],
      ["D", "Gestion financière", "euro"],
      ["E", "Gestion sociale & salariés", "users"],
      ["F", "Sécurité & réglementation technique", "lock"],
    ];
    const gw = (W - 2 * M - 2 * 0.3) / 3, gh = 1.35;
    mods.forEach((m, i) => {
      const col = i % 3, rowi = Math.floor(i / 3);
      const x = M + col * (gw + 0.3), y = 2.85 + rowi * (gh + 0.3);
      s.addShape(pres.shapes.RECTANGLE, { x, y, w: gw, h: gh, fill: { color: C.paper }, line: { color: C.border, width: 0.75 }, shadow: mkShadow() });
      s.addShape(pres.shapes.RECTANGLE, { x, y, w: 0.09, h: gh, fill: { color: C.lime } });
      badge(s, x + 0.28, y + 0.26, 0.5, m[2]);
      s.addText("MODULE " + m[0], { x: x + 0.95, y: y + 0.26, w: gw - 1.1, h: 0.25, fontSize: 9, bold: true, color: C.lime700, charSpacing: 1, fontFace: "Calibri", margin: 0 });
      s.addText(m[1], { x: x + 0.95, y: y + 0.5, w: gw - 1.1, h: 0.6, fontSize: 12.5, bold: true, color: C.navy, fontFace: "Calibri", margin: 0, valign: "top", lineSpacingMultiple: 0.98 });
    });
    s.addText([
      { text: "Modalité  ", options: { bold: true, color: C.navy } },
      { text: "Parcours souple : chaque module et quiz peut être travaillé librement (le stagiaire prépare l'examen officiel externe). Contenu dense : 6 modules, des centaines de leçons et de questions d'entraînement.", options: { color: C.slate } },
    ], { x: M, y: 6.35, w: W - 2 * M, h: 0.5, fontSize: 10.5, fontFace: "Calibri", margin: 0, lineSpacingMultiple: 1.0 });
    footer(s);
  }

  // =================================================================
  // 5 — Parcours d'inscription (timeline + packs)
  // =================================================================
  {
    const s = pres.addSlide();
    s.background = { color: C.ivory };
    eyebrow(s, "02 · Inscription");
    title(s, "Le parcours d'inscription d'un stagiaire");
    const steps = [
      ["01", "Avant inscription", "Demande via le formulaire ou prise de contact ; suivi dans le CRM.", "inbox"],
      ["02", "Création du dossier", "L'administration crée le compte et le dossier (état civil, financement).", "id"],
      ["03", "Choix formation & pack", "Capacité ≤ 3,5 t + niveau d'accompagnement (Initial, Medium, Premium).", "tags"],
      ["04", "Compte activé", "Invitation par e-mail ; le stagiaire définit son mot de passe.", "check"],
    ];
    const cw = (W - 2 * M - 3 * 0.3) / 4;
    steps.forEach((st, i) => {
      const x = M + i * (cw + 0.3), y = 1.85;
      s.addShape(pres.shapes.RECTANGLE, { x, y, w: cw, h: 2.15, fill: { color: C.paper }, line: { color: C.border, width: 0.75 }, shadow: mkShadow() });
      badge(s, x + 0.26, y + 0.28, 0.56, st[3]);
      s.addText(st[0], { x: x + cw - 1.0, y: y + 0.26, w: 0.85, h: 0.5, fontSize: 22, bold: true, color: C.surface === C.surface ? "E7E3D8" : C.faint, align: "right", fontFace: "Calibri", margin: 0 });
      s.addText(st[1], { x: x + 0.26, y: y + 0.95, w: cw - 0.5, h: 0.4, fontSize: 12.5, bold: true, color: C.navy, fontFace: "Calibri", margin: 0 });
      s.addText(st[2], { x: x + 0.26, y: y + 1.35, w: cw - 0.5, h: 0.7, fontSize: 9.5, color: C.slate, fontFace: "Calibri", margin: 0, valign: "top", lineSpacingMultiple: 1.02 });
      if (i < 3) s.addText("›", { x: x + cw - 0.04, y: y + 0.75, w: 0.38, h: 0.6, fontSize: 22, bold: true, color: C.lime700, align: "center", valign: "middle", fontFace: "Calibri", margin: 0 });
    });
    s.addText("Trois niveaux d'accompagnement", { x: M, y: 4.35, w: 8, h: 0.4, fontSize: 14, bold: true, color: C.navy, fontFace: "Calibri", margin: 0 });
    const packs = [
      ["INITIAL", "Préparation autonome : cours, entraînements, quiz et tuteur IA en accès complet.", C.lime700],
      ["MEDIUM", "Tout l'Initial, plus un formateur attitré pour le suivi et la correction.", C.brand],
      ["PREMIUM", "Tout le Medium, plus des sessions en direct (présentiel / visioconférence).", C.gold],
    ];
    const pw = (W - 2 * M - 2 * 0.3) / 3;
    packs.forEach((p, i) => {
      const x = M + i * (pw + 0.3), y = 4.85;
      s.addShape(pres.shapes.RECTANGLE, { x, y, w: pw, h: 1.55, fill: { color: C.paper }, line: { color: C.border, width: 0.75 }, shadow: mkShadow() });
      s.addShape(pres.shapes.RECTANGLE, { x, y, w: pw, h: 0.5, fill: { color: C.navy } });
      s.addText(p[0], { x, y, w: pw, h: 0.5, fontSize: 13, bold: true, color: C.lime, align: "center", valign: "middle", charSpacing: 2, fontFace: "Calibri", margin: 0 });
      s.addText(p[1], { x: x + 0.24, y: y + 0.66, w: pw - 0.48, h: 0.8, fontSize: 10, color: C.slate, fontFace: "Calibri", margin: 0, valign: "top", lineSpacingMultiple: 1.04 });
    });
    footer(s);
  }

  // =================================================================
  // 6 — Première connexion : identité, signatures, documents
  // =================================================================
  {
    const s = pres.addSlide();
    s.background = { color: C.ivory };
    eyebrow(s, "02 · Inscription");
    title(s, "Première connexion : identité, signatures, documents");
    s.addText("À sa première connexion, le stagiaire suit un parcours d'entrée guidé et sécurisé avant d'accéder aux contenus.", { x: M, y: 1.7, w: W - 2 * M, h: 0.5, fontSize: 12, color: C.slate, fontFace: "Calibri", margin: 0 });
    const flow = [
      ["lock", "Connexion sécurisée", "Mot de passe personnel défini via le lien d'invitation."],
      ["id", "Validation de l'identité", "Vérification des informations du dossier."],
      ["sign", "Signature électronique", "Signature manuscrite des documents obligatoires, horodatée."],
      ["clip", "Émargement numérique", "Présence signée à chaque session, valeur de preuve."],
    ];
    let y = 2.35;
    flow.forEach((f) => {
      badge(s, M, y, 0.5, f[0]);
      s.addText([
        { text: f[1] + "   ", options: { bold: true, color: C.navy, fontSize: 12.5 } },
        { text: f[2], options: { color: C.slate, fontSize: 10.5 } },
      ], { x: M + 0.7, y: y - 0.02, w: 6.2, h: 0.55, fontFace: "Calibri", valign: "middle", margin: 0, lineSpacingMultiple: 1.0 });
      y += 0.92;
    });
    // Carte documents obligatoires (droite)
    const cx = 7.7, cw = W - M - cx;
    s.addShape(pres.shapes.RECTANGLE, { x: cx, y: 2.2, w: cw, h: 4.2, fill: { color: C.surface }, line: { color: C.border, width: 0.75 } });
    badge(s, cx + 0.3, y = 2.45, 0.5, "sign");
    s.addText("Documents obligatoires signés", { x: cx + 0.95, y: 2.45, w: cw - 1.1, h: 0.5, fontSize: 13, bold: true, color: C.navy, valign: "middle", fontFace: "Calibri", margin: 0 });
    bullets(s, cx + 0.35, 3.2, cw - 0.7, [
      "Règlement intérieur",
      "Conditions générales (CGU / CGV)",
      "Convention / contrat de formation",
      "Livret d'accueil du stagiaire",
    ], false, 11.5, 7);
    s.addShape(pres.shapes.LINE, { x: cx + 0.35, y: 5.35, w: cw - 0.7, h: 0, line: { color: C.border, width: 0.75 } });
    s.addText([
      { text: "Preuve & sécurité.  ", options: { bold: true, color: C.lime700 } },
      { text: "Chaque signature est horodatée, scellée par une empreinte SHA-256 (avec adresse IP et appareil) et conservée de façon sécurisée.", options: { color: C.slate } },
    ], { x: cx + 0.35, y: 5.5, w: cw - 0.7, h: 0.8, fontSize: 10, fontFace: "Calibri", margin: 0, valign: "top", lineSpacingMultiple: 1.04 });
    footer(s);
  }

  // =================================================================
  // 7 — DIVIDER (sombre) : L'expérience stagiaire
  // =================================================================
  {
    const s = pres.addSlide();
    s.background = { color: C.night };
    s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 0.14, h: H, fill: { color: C.lime } });
    logoMark(s, M, 0.55, 0.5, true, true);
    s.addText("03", { x: M, y: 2.4, w: 4, h: 1.8, fontSize: 120, bold: true, color: C.navy2, fontFace: "Calibri", margin: 0 });
    s.addText("SECTION 03", { x: M, y: 4.2, w: 8, h: 0.3, fontSize: 12, bold: true, color: C.lime, charSpacing: 3, fontFace: "Calibri", margin: 0 });
    s.addText("L'expérience et le suivi du stagiaire", { x: M, y: 4.55, w: 10.5, h: 0.9, fontSize: 34, bold: true, color: C.white, fontFace: "Calibri", margin: 0 });
    s.addText("Tableau de bord, modules, évaluations, progression et documents : tout ce que vit le stagiaire, et tout ce qui est tracé.", { x: M, y: 5.5, w: 10, h: 0.7, fontSize: 13, color: C.whiteDim, fontFace: "Calibri", margin: 0, lineSpacingMultiple: 1.05 });
    footer(s, true);
  }

  // =================================================================
  // 8 — Dashboard stagiaire (capture)
  // =================================================================
  {
    const s = pres.addSlide();
    s.background = { color: C.ivory };
    eyebrow(s, "03 · Stagiaire");
    title(s, "Un tableau de bord qui guide le stagiaire");
    shot(s, "livraison/screenshots/dashboard.png", M, 1.85, 7.4, "app.maformationtransport.fr  ·  Tableau de bord");
    const bx = 8.5;
    s.addText("À chaque connexion, le stagiaire sait quoi faire.", { x: bx, y: 1.95, w: W - M - bx, h: 0.6, fontSize: 12.5, bold: true, color: C.navy, fontFace: "Calibri", margin: 0, lineSpacingMultiple: 1.02 });
    bullets(s, bx, 2.75, W - M - bx, [
      "Formation en cours et progression globale",
      "Prochaine action recommandée (module à reprendre)",
      "Niveau, points d'expérience et série de connexion",
      "Accès direct aux modules, quiz et examens",
      "Planning, notifications et messagerie",
      "Documents et résultats à portée de clic",
    ], false, 11, 9);
    footer(s);
  }

  // =================================================================
  // 9 — Modules pédagogiques (capture)
  // =================================================================
  {
    const s = pres.addSlide();
    s.background = { color: C.ivory };
    eyebrow(s, "03 · Stagiaire · Pédagogie");
    title(s, "Des modules pédagogiques structurés");
    const bx = M, bw = 5.7;
    s.addText("Un contenu dense, clair et conforme au programme.", { x: bx, y: 1.95, w: bw, h: 0.6, fontSize: 12.5, bold: true, color: C.navy, fontFace: "Calibri", margin: 0 });
    bullets(s, bx, 2.7, bw, [
      "Cours détaillés : texte riche, illustrations, tableaux et annexes",
      "Vidéo d'introduction et durée estimée par module",
      "Leçons et quiz regroupés par module",
      "Validation de chaque leçon et suivi de lecture",
      "Déverrouillage progressif et logique du parcours",
    ], false, 11.5, 10);
    shot(s, "livraison/screenshots/module.png", 6.7, 1.85, 5.9, "·  Module D — Activité financière");
    footer(s);
  }

  // =================================================================
  // 10 — Quiz & examens (capture)
  // =================================================================
  {
    const s = pres.addSlide();
    s.background = { color: C.ivory };
    eyebrow(s, "03 · Stagiaire · Évaluation");
    title(s, "Évaluations : du QCM à l'épreuve rédigée");
    shot(s, "livraison/screenshots/quiz.png", M, 1.85, 6.2, "·  Quiz d'entraînement");
    const bx = 7.3, bw = W - M - bx;
    const rows = [
      ["clip", "QCM auto-corrigés", "Correction et explications immédiates, seuil de réussite paramétrable."],
      ["pen", "Questions rédigées (QR)", "Réponses libres corrigées par le formateur, au plus près de l'examen."],
      ["shield", "Examens blancs", "Conditions réelles : minuteur, plein écran, anti-triche."],
      ["check", "Correction & validation", "Notes, commentaires et validation par le formateur."],
    ];
    let y = 2.0;
    rows.forEach((r) => {
      badge(s, bx, y, 0.48, r[0]);
      s.addText(r[1], { x: bx + 0.66, y: y - 0.04, w: bw - 0.66, h: 0.3, fontSize: 12, bold: true, color: C.navy, fontFace: "Calibri", margin: 0 });
      s.addText(r[2], { x: bx + 0.66, y: y + 0.26, w: bw - 0.66, h: 0.6, fontSize: 9.5, color: C.slate, fontFace: "Calibri", margin: 0, valign: "top", lineSpacingMultiple: 1.02 });
      y += 1.02;
    });
    footer(s);
  }

  // =================================================================
  // 11 — Suivi & gamification (capture)
  // =================================================================
  {
    const s = pres.addSlide();
    s.background = { color: C.ivory };
    eyebrow(s, "03 · Stagiaire · Suivi");
    title(s, "Progression, résultats et motivation");
    const bx = M, bw = 5.7;
    bullets(s, bx, 2.0, bw, [
      "Progression détaillée par module et par bloc",
      "Statistiques et résultats consultables à tout moment",
      "Badges, rangs (Débutant à Master) et points d'expérience",
      "Série de connexion qui récompense la régularité",
      "Remédiation : après un échec, les leçons à revoir sont proposées",
    ], false, 11.5, 10);
    s.addText("La gamification soutient l'effort, sans transformer la formation en jeu : l'objectif reste la réussite à l'examen.", { x: bx, y: 5.45, w: bw, h: 0.9, fontSize: 10.5, italic: true, color: C.muted, fontFace: "Calibri", margin: 0, lineSpacingMultiple: 1.05 });
    shot(s, "livraison/screenshots/reussites.png", 6.7, 1.85, 5.9, "·  Réussites & badges");
    footer(s);
  }

  // =================================================================
  // 12 — Documents & administratif (stagiaire)
  // =================================================================
  {
    const s = pres.addSlide();
    s.background = { color: C.ivory };
    eyebrow(s, "03 · Stagiaire · Administratif");
    title(s, "Documents & démarches du stagiaire");
    const cards = [
      ["upload", "Dépôt de documents", "Le stagiaire téléverse ses justificatifs (PDF, images) directement depuis son espace."],
      ["file", "Conventions & attestations", "Documents contractuels accessibles ; attestations et certificats téléchargeables."],
      ["bell", "Notifications e-mail", "Confirmations et rappels automatiques à chaque étape importante."],
      ["clip", "Suivi administratif", "Statut du dossier, signatures et émargements consultables et tracés."],
    ];
    const cw = (W - 2 * M - 0.3) / 2, ch = 1.95;
    cards.forEach((c, i) => {
      const x = M + (i % 2) * (cw + 0.3), y = 2.0 + Math.floor(i / 2) * (ch + 0.3);
      infoCard(s, x, y, cw, ch, c[0], c[1], c[2]);
    });
    footer(s);
  }

  // =================================================================
  // 13 — Formateurs
  // =================================================================
  {
    const s = pres.addSlide();
    s.background = { color: C.ivory };
    eyebrow(s, "04 · Encadrement");
    title(s, "Le rôle du formateur");
    s.addText("Le formateur encadre les stagiaires de ses formations et garantit la qualité pédagogique.", { x: M, y: 1.7, w: W - 2 * M, h: 0.4, fontSize: 12, color: C.slate, fontFace: "Calibri", margin: 0 });
    const items = [
      ["student", "Suivi des stagiaires", "Progression individuelle et par groupe."],
      ["pen", "Correction des QR", "Notes, barème et commentaires personnalisés."],
      ["check", "Validation des examens", "Décision finale sur les copies (l'IA assiste, n'arbitre pas)."],
      ["chart", "Statistiques pédagogiques", "Taux de réussite, points de difficulté."],
      ["video", "Sessions en direct", "Présentiel et visioconférence (Zoom, Teams, Meet)."],
      ["clip", "Émargements & gestion", "Contre-signature des présences, gestion du contenu."],
    ];
    const cw = (W - 2 * M - 2 * 0.3) / 3, ch = 1.85;
    items.forEach((it, i) => {
      const x = M + (i % 3) * (cw + 0.3), y = 2.3 + Math.floor(i / 3) * (ch + 0.3);
      infoCard(s, x, y, cw, ch, it[0], it[1], it[2]);
    });
    footer(s);
  }

  // =================================================================
  // 14 — Admins
  // =================================================================
  {
    const s = pres.addSlide();
    s.background = { color: C.ivory };
    eyebrow(s, "05 · Administration");
    title(s, "Le rôle de l'administration de l'école");
    const items = [
      ["users", "Utilisateurs & classes"],
      ["cap", "Formations & modules"],
      ["inbox", "Inscriptions & financeurs"],
      ["sign", "Signatures"],
      ["file", "Documents & conventions"],
      ["chart", "Analytics & exports"],
      ["cog", "Groupes & affectations"],
      ["shield", "Conformité & qualité"],
    ];
    const cw = (W - 2 * M - 3 * 0.3) / 4, ch = 1.75;
    items.forEach((it, i) => {
      const x = M + (i % 4) * (cw + 0.3), y = 2.0 + Math.floor(i / 4) * (ch + 0.35);
      s.addShape(pres.shapes.RECTANGLE, { x, y, w: cw, h: ch, fill: { color: C.paper }, line: { color: C.border, width: 0.75 }, shadow: mkShadow() });
      badge(s, x + cw / 2 - 0.34, y + 0.3, 0.68, it[0]);
      s.addText(it[1], { x: x + 0.12, y: y + 1.12, w: cw - 0.24, h: 0.55, fontSize: 11.5, bold: true, color: C.navy, align: "center", valign: "top", fontFace: "Calibri", margin: 0, lineSpacingMultiple: 0.98 });
    });
    footer(s);
  }

  // =================================================================
  // 15 — DIVIDER (sombre) : Conformité & Qualiopi
  // =================================================================
  {
    const s = pres.addSlide();
    s.background = { color: C.night };
    s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 0.14, h: H, fill: { color: C.lime } });
    logoMark(s, M, 0.55, 0.5, true, true);
    s.addText("06", { x: M, y: 2.4, w: 4, h: 1.8, fontSize: 120, bold: true, color: C.navy2, fontFace: "Calibri", margin: 0 });
    s.addText("SECTION 06", { x: M, y: 4.2, w: 8, h: 0.3, fontSize: 12, bold: true, color: C.lime, charSpacing: 3, fontFace: "Calibri", margin: 0 });
    s.addText("Conformité & exigences Qualiopi", { x: M, y: 4.55, w: 10.5, h: 0.9, fontSize: 34, bold: true, color: C.white, fontFace: "Calibri", margin: 0 });
    s.addText("L'organisme est certifié Qualiopi. La plateforme industrialise la production des preuves attendues lors d'un audit.", { x: M, y: 5.5, w: 10.5, h: 0.7, fontSize: 13, color: C.whiteDim, fontFace: "Calibri", margin: 0, lineSpacingMultiple: 1.05 });
    footer(s, true);
  }

  // =================================================================
  // 16 — Conformité : les preuves
  // =================================================================
  {
    const s = pres.addSlide();
    s.background = { color: C.ivory };
    eyebrow(s, "06 · Conformité");
    title(s, "Les preuves attendues d'un organisme certifié");
    const rows = [
      ["Adaptation à l'entrée", "Test de positionnement conservé au dossier."],
      ["Signatures obligatoires", "Documents acceptés et signés, horodatés et scellés."],
      ["Émargement matin / après-midi", "Présences signées par demi-journée, contre-signées par le formateur."],
      ["Suivi des présences & assiduité", "Émargement détaillé par séance, y compris à distance (FOAD)."],
      ["Suivi pédagogique", "Progression, résultats et corrections tracés."],
      ["Satisfaction & réclamations", "Enquêtes à chaud et à froid ; procédure de réclamation."],
      ["Statistiques & indicateurs", "Indicateurs qualité et taux de réussite consolidés."],
      ["Archivage & exports", "Conservation, journal d'audit et exports (BPF, CSV)."],
    ];
    const cw = (W - 2 * M - 0.5) / 2;
    rows.forEach((r, i) => {
      const x = M + (i % 2) * (cw + 0.5), y = 1.95 + Math.floor(i / 2) * 1.18;
      checkRow(s, x, y, cw, r[0], r[1]);
    });
    footer(s);
  }

  // =================================================================
  // 17 — Traçabilité & preuve (capture émargement)
  // =================================================================
  {
    const s = pres.addSlide();
    s.background = { color: C.ivory };
    eyebrow(s, "06 · Conformité");
    title(s, "Traçabilité : prouver qui a fait quoi, et quand");
    shot(s, "livraison/screenshots/emargement.png", M, 1.85, 6.6, "·  Émargement du stagiaire");
    const bx = 7.7, bw = W - M - bx;
    const rows = [
      ["sign", "Signature scellée", "Empreinte SHA-256 + IP + horodatage : preuve d'intégrité (indicateur 11)."],
      ["archive", "Journal d'audit", "Historique des actions sensibles, conservé 5 ans."],
      ["chart", "Reporting BPF", "Synthèse du Bilan Pédagogique et Financier, prête à exporter."],
      ["lock", "Données protégées", "Hébergement UE, accès cloisonnés, conformité RGPD."],
    ];
    let y = 2.0;
    rows.forEach((r) => {
      badge(s, bx, y, 0.48, r[0]);
      s.addText(r[1], { x: bx + 0.66, y: y - 0.04, w: bw - 0.66, h: 0.3, fontSize: 12, bold: true, color: C.navy, fontFace: "Calibri", margin: 0 });
      s.addText(r[2], { x: bx + 0.66, y: y + 0.26, w: bw - 0.66, h: 0.6, fontSize: 9.5, color: C.slate, fontFace: "Calibri", margin: 0, valign: "top", lineSpacingMultiple: 1.02 });
      y += 1.05;
    });
    footer(s);
  }

  // =================================================================
  // 18 — Technique simplifiée
  // =================================================================
  {
    const s = pres.addSlide();
    s.background = { color: C.ivory };
    eyebrow(s, "07 · Technique");
    title(s, "La technique, expliquée simplement");
    const cards = [
      ["shield", "Sécurité des données", "Chaque utilisateur n'accède qu'à ses propres données : la séparation est appliquée au cœur de la base."],
      ["cloud", "Hébergement en Europe", "Données hébergées dans l'Union européenne (Paris / Francfort)."],
      ["db", "Sauvegardes", "Sauvegardes régulières et fichiers stockés de façon privée."],
      ["lock", "Accès sécurisés", "Connexion protégée, quatre niveaux d'accès, parcours d'entrée guidé."],
      ["check", "Protection (RGPD)", "Consentements, export et suppression des données sur demande."],
      ["gauge", "Performance & fiabilité", "Pages rapides, surveillance des erreurs et contrôles automatiques."],
    ];
    const cw = (W - 2 * M - 2 * 0.3) / 3, ch = 1.95;
    cards.forEach((c, i) => {
      const x = M + (i % 3) * (cw + 0.3), y = 2.0 + Math.floor(i / 3) * (ch + 0.3);
      infoCard(s, x, y, cw, ch, c[0], c[1], c[2]);
    });
    footer(s);
  }

  // =================================================================
  // 19 — Analytics & pilotage
  // =================================================================
  {
    const s = pres.addSlide();
    s.background = { color: C.ivory };
    eyebrow(s, "08 · Pilotage");
    title(s, "Le pilotage par la donnée");
    const stats = [
      ["Temps réel", "Tableaux de bord"],
      ["Par formation", "Réussite & activité"],
      ["À risque", "Stagiaires en alerte"],
      ["BPF / CSV", "Exports prêts"],
    ];
    const sw = (W - 2 * M - 3 * 0.3) / 4;
    stats.forEach((st, i) => {
      const x = M + i * (sw + 0.3), y = 1.95;
      s.addShape(pres.shapes.RECTANGLE, { x, y, w: sw, h: 1.5, fill: { color: C.navy }, shadow: mkShadow({ opacity: 0.16 }) });
      s.addText(st[0], { x: x + 0.2, y: y + 0.28, w: sw - 0.4, h: 0.6, fontSize: 19, bold: true, color: C.lime, fontFace: "Calibri", margin: 0 });
      s.addText(st[1], { x: x + 0.2, y: y + 0.95, w: sw - 0.4, h: 0.4, fontSize: 10, color: C.whiteDim, fontFace: "Calibri", margin: 0 });
    });
    s.addText("Ce que l'administration peut suivre", { x: M, y: 3.8, w: 8, h: 0.4, fontSize: 14, bold: true, color: C.navy, fontFace: "Calibri", margin: 0 });
    const colw = (W - 2 * M - 0.5) / 2;
    bullets(s, M, 4.3, colw, [
      "Progression globale et par groupe",
      "Taux de réussite par module et par formation",
      "Détection des stagiaires en difficulté",
    ], false, 11.5, 9);
    bullets(s, M + colw + 0.5, 4.3, colw, [
      "Suivi de l'activité et de l'assiduité",
      "Indicateurs qualité et satisfaction",
      "Exports comptables et reporting BPF",
    ], false, 11.5, 9);
    footer(s);
  }

  // =================================================================
  // 20 — CONCLUSION (sombre)
  // =================================================================
  {
    const s = pres.addSlide();
    s.background = { color: C.night };
    s.addShape(pres.shapes.RECTANGLE, { x: 0, y: H - 0.12, w: W, h: 0.12, fill: { color: C.lime } });
    logoMark(s, M, 0.55, 0.55, true, true);
    s.addText("EN CONCLUSION", { x: M, y: 2.0, w: 10, h: 0.35, fontSize: 12, bold: true, color: C.lime, charSpacing: 3, fontFace: "Calibri", margin: 0 });
    s.addText("Une école moderne, conforme et sérieuse.", { x: M, y: 2.4, w: 11.5, h: 1.0, fontSize: 36, bold: true, color: C.white, fontFace: "Calibri", margin: 0, lineSpacingMultiple: 1.0 });
    const pts = [
      ["compass", "Un parcours pédagogique clair, de l'inscription à la certification."],
      ["clip", "Un suivi pédagogique et administratif complet et tracé."],
      ["shield", "Une conformité pensée pour les exigences françaises et Qualiopi."],
      ["lock", "Des données sécurisées, hébergées en Europe."],
    ];
    let y = 3.75;
    pts.forEach((p) => {
      s.addShape(pres.shapes.OVAL, { x: M, y, w: 0.44, h: 0.44, fill: { color: C.navy2 } });
      const pad = 0.44 * 0.27;
      s.addImage({ data: IC[p[0]], x: M + pad, y: y + pad, w: 0.44 - 2 * pad, h: 0.44 - 2 * pad });
      s.addText(p[1], { x: M + 0.62, y: y - 0.04, w: 8.5, h: 0.5, fontSize: 12.5, color: C.whiteDim, valign: "middle", fontFace: "Calibri", margin: 0 });
      y += 0.62;
    });
    // bandeau identité
    s.addShape(pres.shapes.LINE, { x: M, y: 6.5, w: W - 2 * M, h: 0, line: { color: C.borderDark, width: 0.75 } });
    s.addText([
      { text: "MA FORMATION TRANSPORT (SAS)  ·  SIRET 908 851 280 00028  ·  NDA 11 77 09 47177  ·  Qualiopi CW202525-4287\n", options: { color: C.whiteDim, bold: true } },
      { text: "39 av. des Sablons Bouillants, 77100 Meaux  ·  contact@maformationtransport.fr  ·  01 60 09 54 47", options: { color: C.faint } },
    ], { x: M, y: 6.62, w: W - 2 * M, h: 0.7, fontSize: 9, fontFace: "Calibri", margin: 0, lineSpacingMultiple: 1.1 });
  }

  await pres.writeFile({ fileName: "livraison/capacite-3-5t-audit-administration.pptx" });
  console.log("✓ PPTX généré : livraison/capacite-3-5t-audit-administration.pptx (" + pageNo + " pieds de page, ~20 slides)");
}

main().catch((e) => { console.error(e); process.exit(1); });
