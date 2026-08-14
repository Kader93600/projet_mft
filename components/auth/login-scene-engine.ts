// =====================================================================
// Moteur canvas de la scène de connexion « Le Convoi » (concept A+
// validé client le 22/07/2026, prévisualisé hors projet avant intégration).
//
// Autonome : zéro dépendance, sprites vectoriels HD pré-rendus au
// chargement/resize, boucle rAF qui ne fait que composer (~0,1 ms/frame
// mesuré). Pause automatique quand l'onglet est masqué, variante mobile
// allégée (< 520 px), mode prefers-reduced-motion en plan fixe.
//
// Chargé UNIQUEMENT via import() dynamique par components/auth/login-scene.tsx
// (code-splitté : aucun poids sur le First Load des autres pages).
//
// @ts-nocheck : moteur d'animation JS pur validé visuellement en préviz ;
// la surface publique est typée ci-dessous (LoginSceneApi), l'interne
// (géométrie canvas) n'apporterait que du bruit de typage.
// =====================================================================
// @ts-nocheck

export interface LoginSceneApi {
  /** idle = croisière · connecting = accélération/loader · success = caméra qui avance */
  setState(state: "idle" | "connecting" | "success"): void;
  /** Position du pointeur normalisée (0..1) pour la parallaxe. */
  setPointer(nx: number, ny: number): void;
  /** Mode animations réduites : plan fixe sans boucle. */
  setReduced(reduced: boolean): void;
  destroy(): void;
}

// @ts-nocheck

/* ════════════════════════════════════════════════════════════════════
   CONCEPT A+ · Le Convoi réaliste — scène canvas cinématographique.
   Sprites HD pré-rendus (véhicules, halos, cônes, décor), boucle qui ne
   fait que composer : budget < 3,5 ms/frame. Part 1/3 : infra + flotte.
   ════════════════════════════════════════════════════════════════════ */
export function initLoginScene(canvas: HTMLCanvasElement): LoginSceneApi {
  const ctx = canvas.getContext("2d");
  const HD = 2;                      // suréchantillonnage interne des sprites
  const FONT = 'ui-sans-serif, -apple-system, "Segoe UI", sans-serif';

  let W = 0, H = 0, dpr = 1, mobile = false;
  let state = "idle", reduced = false, destroyed = false;
  let raf = 0, lastT = 0, worldT = 0;
  let speed = 1, speedTarget = 1;    // multiplicateur global du convoi
  let camScale = 1, camScaleT = 1;   // zoom caméra (success)
  let veil = 0, veilT = 0;           // voile navy final
  const ptr = { x: 0.5, y: 0.5, sx: 0.5, sy: 0.5 };

  /* ── Utilitaires ─────────────────────────────────────────────────── */
  const lerp = (a, b, t) => a + (b - a) * t;
  const clamp = (v, a, b) => v < a ? a : v > b ? b : v;
  const easeIO = (t) => t < 0.5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2;
  function mk(w, h) {
    const c = document.createElement("canvas");
    c.width = Math.max(2, Math.round(w)); c.height = Math.max(2, Math.round(h));
    return c;
  }
  function rr(g, x, y, w, h, r) {
    const q = Math.min(r, w / 2, h / 2);
    g.beginPath();
    g.moveTo(x + q, y);
    g.arcTo(x + w, y, x + w, y + h, q);
    g.arcTo(x + w, y + h, x, y + h, q);
    g.arcTo(x, y + h, x, y, q);
    g.arcTo(x, y, x + w, y, q);
    g.closePath();
  }
  /* Halo radial pré-rendu (bloom des feux, projecteurs, lampadaires). */
  function glowSprite(r, rgb, a) {
    const c = mk(r * 2, r * 2), g = c.getContext("2d");
    const gr = g.createRadialGradient(r, r, 0, r, r, r);
    gr.addColorStop(0, `rgba(${rgb},${a})`);
    gr.addColorStop(0.4, `rgba(${rgb},${a * 0.35})`);
    gr.addColorStop(1, `rgba(${rgb},0)`);
    g.fillStyle = gr; g.fillRect(0, 0, r * 2, r * 2);
    return c;
  }
  /* Cône de phare au sol, pointe à gauche → s'évase vers la droite. */
  function coneSprite(len, hNear, rgb, a) {
    const c = mk(len, hNear * 2), g = c.getContext("2d");
    const gr = g.createLinearGradient(0, 0, len, 0);
    gr.addColorStop(0, `rgba(${rgb},${a})`);
    gr.addColorStop(1, `rgba(${rgb},0)`);
    g.fillStyle = gr;
    g.beginPath();
    g.moveTo(0, hNear * 0.75);
    g.lineTo(len, 0);
    g.lineTo(len, hNear * 2);
    g.lineTo(0, hNear * 1.25);
    g.closePath(); g.fill();
    return c;
  }
  /* Ombre portée douce (AO) sous châssis / plateau. */
  function aoSprite(w, h, a) {
    const c = mk(w, h), g = c.getContext("2d");
    const gr = g.createRadialGradient(w / 2, h / 2, 1, w / 2, h / 2, w / 2);
    gr.addColorStop(0, `rgba(2,4,12,${a})`);
    gr.addColorStop(1, "rgba(2,4,12,0)");
    g.fillStyle = gr;
    g.save(); g.translate(w / 2, h / 2); g.scale(1, h / w); g.translate(-w / 2, -w / 2);
    g.fillRect(0, 0, w, w); g.restore();
    return c;
  }

  /* ── Roues : pneu + jante détaillée, tournées au blit ────────────── */
  function wheelSprite(r) {
    const s = r * HD, c = mk(s * 2, s * 2), g = c.getContext("2d");
    const cx = s, cy = s;
    let gr = g.createRadialGradient(cx, cy - s * 0.3, s * 0.2, cx, cy, s);
    gr.addColorStop(0, "#232840"); gr.addColorStop(0.8, "#0B0E1F"); gr.addColorStop(1, "#05060F");
    g.fillStyle = gr; g.beginPath(); g.arc(cx, cy, s, 0, 7); g.fill();
    g.strokeStyle = "rgba(255,255,255,0.06)"; g.lineWidth = 1;
    g.beginPath(); g.arc(cx, cy, s - 1, 0, 7); g.stroke();
    const rim = s * 0.56;
    gr = g.createRadialGradient(cx, cy - rim * 0.4, rim * 0.1, cx, cy, rim);
    gr.addColorStop(0, "#3D4577"); gr.addColorStop(1, "#181D3C");
    g.fillStyle = gr; g.beginPath(); g.arc(cx, cy, rim, 0, 7); g.fill();
    g.fillStyle = "#4A538C";
    for (let i = 0; i < 6; i++) {                       // 6 branches
      g.save(); g.translate(cx, cy); g.rotate(i * Math.PI / 3);
      rr(g, -rim * 0.11, -rim * 0.92, rim * 0.22, rim * 0.84, rim * 0.1); g.fill();
      g.restore();
    }
    g.fillStyle = "#0E1230"; g.beginPath(); g.arc(cx, cy, rim * 0.24, 0, 7); g.fill();
    g.fillStyle = "#565F9E"; g.beginPath(); g.arc(cx, cy, rim * 0.12, 0, 7); g.fill();
    return c;
  }

  /* ── Peinture commune de carrosserie ─────────────────────────────
     Chaque type fournit : outline(g,L,Hv) trace le chemin fermé de la
     caisse ; windows(g,L,Hv) et details(g,L,Hv) peignent par-dessus.
     Le factory ajoute : dégradé vertical, ligne d'épaule lumineuse,
     passages de roues sombres, gabarits orange (poids lourds).      */
  function paintGlass(g, x, y, w, h, r) {
    const gr = g.createLinearGradient(0, y, 0, y + h);
    gr.addColorStop(0, "#0E1330"); gr.addColorStop(1, "#05070F");
    g.fillStyle = gr; rr(g, x, y, w, h, r); g.fill();
    g.save(); rr(g, x, y, w, h, r); g.clip();          // strie de reflet
    g.fillStyle = "rgba(255,255,255,0.09)";
    g.beginPath();
    g.moveTo(x + w * 0.18, y); g.lineTo(x + w * 0.34, y);
    g.lineTo(x + w * 0.10, y + h); g.lineTo(x - w * 0.02, y + h);
    g.closePath(); g.fill();
    g.restore();
    g.strokeStyle = "rgba(255,255,255,0.10)"; g.lineWidth = 1;
    rr(g, x, y, w, h, r); g.stroke();
  }
  function buildVehicle(spec) {
    const L = spec.L * HD, Hv = spec.H * HD;
    const c = mk(L, Hv), g = c.getContext("2d");
    g.save();
    spec.outline(g, L, Hv);
    const gr = g.createLinearGradient(0, 0, 0, Hv);
    gr.addColorStop(0, spec.top); gr.addColorStop(0.55, spec.mid); gr.addColorStop(1, spec.low);
    g.fillStyle = gr; g.fill();
    g.save(); spec.outline(g, L, Hv); g.clip();
    g.fillStyle = "rgba(255,255,255,0.10)";            // ligne d'épaule
    g.fillRect(0, Hv * spec.shoulder, L, HD);
    g.fillStyle = "rgba(0,0,0,0.25)";                  // bas de caisse
    g.fillRect(0, Hv - 5 * HD, L, 5 * HD);
    if (spec.windows) spec.windows(g, L, Hv);
    if (spec.details) spec.details(g, L, Hv);
    for (const w of spec.wheels) {                     // passages de roues
      g.fillStyle = "#04060E";
      g.beginPath(); g.arc(w.x * HD, Hv, (w.r + 3) * HD, Math.PI, 0); g.fill();
    }
    g.restore();
    spec.outline(g, L, Hv);
    g.strokeStyle = "rgba(255,255,255,0.07)"; g.lineWidth = 1; g.stroke();
    g.restore();
    return {
      L: spec.L, H: spec.H, body: c,
      wheels: spec.wheels.map((w) => ({ x: w.x, r: w.r, sp: wheelSprite(w.r) })),
      head: spec.head, tail: spec.tail,               // {x,y} des feux
      cone: coneSprite(spec.coneLen || 150, 16, "255,243,209", 0.13),
      ao: aoSprite(spec.L * 1.05, spec.H * 0.30, 0.5),
      roof: spec.roof || null,                        // enseigne lumineuse
      marker: !!spec.marker,                          // gabarits orange PL
      ind: spec.ind || null,                          // ancre clignotant
    };
  }

  /* ── La flotte ───────────────────────────────────────────────────── */
  const glowHead = glowSprite(16, "255,244,214", 0.85);
  const glowTail = glowSprite(11, "255,90,90", 0.7);
  const glowStop = glowSprite(15, "255,70,70", 0.95);
  const glowInd = glowSprite(10, "255,176,64", 0.9);
  const glowLimeS = glowSprite(12, "159,226,32", 0.5);

  /* Logo MFT : casquette de diplômé bleue au-dessus d'un cercle route lime.
     Dessiné en vectoriel sur une plaque claire (sérigraphie de remorque). */
  function drawLogoMFT(g, x, y, s) {
    g.save(); g.translate(x, y); g.scale(s, s);
    g.fillStyle = "rgba(250,250,252,0.96)";            // plaque sérigraphiée
    rr(g, 0, 0, 46, 42, 5); g.fill();
    const BLUE = "#2530D9", LIME = "#76B900";
    g.strokeStyle = BLUE; g.lineWidth = 2.6;           // cercle
    g.beginPath(); g.arc(23, 26, 11, 0, 7); g.stroke();
    g.save();                                          // route dans le cercle
    g.beginPath(); g.arc(23, 26, 9.7, 0, 7); g.clip();
    g.fillStyle = LIME;
    g.beginPath(); g.moveTo(20, 36); g.lineTo(26, 36); g.lineTo(24.4, 16); g.lineTo(21.6, 16);
    g.closePath(); g.fill();
    g.fillStyle = "#FFFFFF";                           // pointillés
    g.fillRect(22.6, 18, 0.9, 3); g.fillRect(22.6, 24, 0.9, 3.4); g.fillRect(22.6, 31, 0.9, 3.6);
    g.restore();
    g.fillStyle = BLUE;                                // casquette (mortier)
    g.beginPath(); g.moveTo(23, 6); g.lineTo(40, 12.5); g.lineTo(23, 19); g.lineTo(6, 12.5);
    g.closePath(); g.fill();
    g.fillRect(10.5, 13.5, 2, 7.5);                    // gland
    g.fillRect(9.6, 20.5, 3.8, 2.6);
    g.restore();
  }

  function mkSemi() {                                  // GOTRM : tracteur + tautliner
    return buildVehicle({
      L: 430, H: 88, top: "#333A6C", mid: "#20264F", low: "#12163A",
      shoulder: 0.46, marker: true, coneLen: 190,
      wheels: [{ x: 396, r: 13.5 }, { x: 330, r: 13.5 }, { x: 138, r: 13 }, { x: 108, r: 13 }, { x: 78, r: 13 }],
      head: { x: 428, y: 62 }, tail: { x: 2, y: 58 },
      outline(g, L, Hv) {
        const c = 340 * HD;                            // départ cabine
        g.beginPath();
        g.moveTo(2, Hv * 0.16);                        // haut remorque
        g.lineTo(c - 6 * HD, Hv * 0.16);
        g.lineTo(c - 6 * HD, Hv * 0.34);               // col de cygne
        g.lineTo(c + 8 * HD, Hv * 0.34);
        g.lineTo(c + 8 * HD, Hv * 0.10);               // toit cabine + déflecteur
        g.quadraticCurveTo(c + 46 * HD, Hv * 0.06, c + 60 * HD, Hv * 0.22);
        g.lineTo(L - 6 * HD, Hv * 0.46);               // pare-brise incliné
        g.quadraticCurveTo(L, Hv * 0.50, L - HD, Hv * 0.62);
        g.lineTo(L - HD, Hv * 0.94); g.lineTo(2, Hv * 0.94);
        g.closePath();
      },
      windows(g, L, Hv) {
        paintGlass(g, 352 * HD, Hv * 0.20, 52 * HD, Hv * 0.26, 3 * HD);
        g.fillStyle = "#12173A";                       // rétroviseurs
        rr(g, 348 * HD, Hv * 0.14, 3 * HD, 12 * HD, HD); g.fill();
        rr(g, 406 * HD, Hv * 0.16, 3 * HD, 11 * HD, HD); g.fill();
      },
      details(g, L, Hv) {
        g.fillStyle = "rgba(255,255,255,0.04)";        // bâche : couture verticale
        for (let x = 20; x < 320; x += 26) g.fillRect(x * HD, Hv * 0.20, HD, Hv * 0.60);
        g.fillStyle = "rgba(0,0,0,0.30)";              // rail inférieur + jupe
        g.fillRect(6 * HD, Hv * 0.74, 320 * HD, 3 * HD);
        rr(g, 150 * HD, Hv * 0.80, 120 * HD, Hv * 0.12, 3 * HD); g.fill();
        rr(g, 346 * HD, Hv * 0.70, 40 * HD, Hv * 0.16, 3 * HD);  // réservoir
        g.fillStyle = "#1B2148"; g.fill();
        g.strokeStyle = "rgba(255,255,255,0.10)"; g.strokeRect(348 * HD, Hv * 0.72, 36 * HD, Hv * 0.11);
        g.fillStyle = "#141A3E";                       // calandre
        for (let i = 0; i < 3; i++) g.fillRect((L - 14 * HD), Hv * (0.52 + i * 0.07), 11 * HD, 3 * HD);
        drawLogoMFT(g, 26 * HD, Hv * 0.30, HD * 0.92);  // logo sérigraphié
        g.font = `600 ${13 * HD}px ${FONT}`;           // livrée société
        g.fillStyle = "rgba(255,255,255,0.85)";
        g.fillText("MA FORMATION TRANSPORT", 78 * HD, Hv * 0.47);
        g.fillStyle = "rgba(159,226,32,0.75)";
        g.fillRect(78 * HD, Hv * 0.52, 96 * HD, 2 * HD);
        g.font = `500 ${7 * HD}px ${FONT}`;
        g.fillStyle = "rgba(255,255,255,0.35)";
        g.fillText("Formations GOTRM et Capacité de transport", 78 * HD, Hv * 0.60);
      },
    });
  }
  function mkAutocar() {                               // FIMO / FCO
    return buildVehicle({
      L: 300, H: 76, top: "#3A416F", mid: "#242A55", low: "#141942",
      shoulder: 0.30, marker: true, coneLen: 160,
      wheels: [{ x: 58, r: 12 }, { x: 238, r: 12 }],
      head: { x: 298, y: 56 }, tail: { x: 2, y: 52 },
      outline(g, L, Hv) {
        g.beginPath();
        g.moveTo(4 * HD, Hv * 0.10);
        g.lineTo(L - 22 * HD, Hv * 0.08);
        g.quadraticCurveTo(L - 4 * HD, Hv * 0.10, L - 2 * HD, Hv * 0.34);
        g.lineTo(L - 2 * HD, Hv * 0.92); g.lineTo(2, Hv * 0.92);
        g.lineTo(2, Hv * 0.22); g.quadraticCurveTo(2, Hv * 0.10, 4 * HD, Hv * 0.10);
        g.closePath();
      },
      windows(g, L, Hv) {
        paintGlass(g, 12 * HD, Hv * 0.18, L - 40 * HD, Hv * 0.26, 4 * HD);
        g.fillStyle = "rgba(255,196,120,0.08)";        // lueur d'habitacle
        for (let x = 22; x < 270; x += 34) g.fillRect(x * HD, Hv * 0.22, 22 * HD, Hv * 0.16);
        paintGlass(g, L - 24 * HD, Hv * 0.14, 20 * HD, Hv * 0.34, 3 * HD);
      },
      details(g, L, Hv) {
        g.fillStyle = "#1A2048";                       // pods de clim
        rr(g, 60 * HD, Hv * 0.02, 60 * HD, Hv * 0.07, 3 * HD); g.fill();
        rr(g, 160 * HD, Hv * 0.02, 60 * HD, Hv * 0.07, 3 * HD); g.fill();
        g.fillStyle = "rgba(255,255,255,0.06)";        // jupe chromée
        g.fillRect(6 * HD, Hv * 0.62, L - 12 * HD, HD);
        g.fillStyle = "rgba(0,0,0,0.25)";              // soute bagages
        rr(g, 30 * HD, Hv * 0.66, 100 * HD, Hv * 0.20, 3 * HD); g.fill();
        rr(g, 150 * HD, Hv * 0.66, 60 * HD, Hv * 0.20, 3 * HD); g.fill();
      },
    });
  }

  function mkPorteur() {                               // CAPACITÉ > 3,5 T
    return buildVehicle({
      L: 232, H: 80, top: "#31386A", mid: "#1F254E", low: "#121639",
      shoulder: 0.42, marker: true, coneLen: 150,
      wheels: [{ x: 196, r: 12.5 }, { x: 46, r: 12.5 }],
      head: { x: 230, y: 58 }, tail: { x: 2, y: 54 },
      outline(g, L, Hv) {
        const c = 158 * HD;                            // caisse | cabine
        g.beginPath();
        g.moveTo(2, Hv * 0.12); g.lineTo(c, Hv * 0.12); g.lineTo(c, Hv * 0.26);
        g.lineTo(c + 10 * HD, Hv * 0.26);
        g.quadraticCurveTo(c + 34 * HD, Hv * 0.22, c + 44 * HD, Hv * 0.34);
        g.lineTo(L - 6 * HD, Hv * 0.50);
        g.quadraticCurveTo(L, Hv * 0.54, L - HD, Hv * 0.66);
        g.lineTo(L - HD, Hv * 0.92); g.lineTo(2, Hv * 0.92);
        g.closePath();
      },
      windows(g, L, Hv) {
        paintGlass(g, 172 * HD, Hv * 0.30, 40 * HD, Hv * 0.24, 3 * HD);
        g.fillStyle = "#111637";
        rr(g, 168 * HD, Hv * 0.24, 3 * HD, 10 * HD, HD); g.fill();
      },
      details(g, L, Hv) {
        g.strokeStyle = "rgba(255,255,255,0.05)"; g.lineWidth = HD;   // portes AR
        g.strokeRect(6 * HD, Hv * 0.16, 150 * HD, Hv * 0.68);
        g.beginPath(); g.moveTo(81 * HD, Hv * 0.16); g.lineTo(81 * HD, Hv * 0.84); g.stroke();
        g.fillStyle = "rgba(0,0,0,0.28)";              // hayon replié
        rr(g, 8 * HD, Hv * 0.84, 146 * HD, Hv * 0.06, 2 * HD); g.fill();
      },
    });
  }
  function mkUtilitaire() {                            // CAPACITÉ ≤ 3,5 T
    return buildVehicle({
      L: 152, H: 60, top: "#3B4276", mid: "#262C58", low: "#151A40",
      shoulder: 0.40, coneLen: 130,
      wheels: [{ x: 124, r: 10 }, { x: 32, r: 10 }],
      head: { x: 150, y: 42 }, tail: { x: 2, y: 38 },
      outline(g, L, Hv) {
        g.beginPath();
        g.moveTo(2, Hv * 0.10);
        g.lineTo(84 * HD, Hv * 0.10);
        g.quadraticCurveTo(112 * HD, Hv * 0.12, 132 * HD, Hv * 0.42);  // pare-brise très incliné
        g.quadraticCurveTo(L - 2 * HD, Hv * 0.50, L - HD, Hv * 0.66);
        g.lineTo(L - HD, Hv * 0.90); g.lineTo(2, Hv * 0.90);
        g.closePath();
      },
      windows(g, L, Hv) {
        paintGlass(g, 92 * HD, Hv * 0.18, 34 * HD, Hv * 0.28, 3 * HD);
        paintGlass(g, 66 * HD, Hv * 0.20, 22 * HD, Hv * 0.24, 2 * HD);
      },
      details(g, L, Hv) {
        g.strokeStyle = "rgba(255,255,255,0.06)"; g.lineWidth = HD;   // porte coulissante
        g.beginPath(); g.moveTo(64 * HD, Hv * 0.50); g.lineTo(64 * HD, Hv * 0.86); g.stroke();
        g.beginPath(); g.moveTo(6 * HD, Hv * 0.48); g.lineTo(60 * HD, Hv * 0.48); g.stroke();
        g.strokeStyle = "rgba(255,255,255,0.25)";                     // antenne
        g.beginPath(); g.moveTo(86 * HD, Hv * 0.10); g.lineTo(90 * HD, Hv * 0.01); g.stroke();
      },
    });
  }
  function mkTaxi() {                                  // TAXI-VTC : berline statutaire
    return buildVehicle({
      L: 150, H: 42, top: "#3E4680", mid: "#272E5C", low: "#161B44",
      shoulder: 0.52, coneLen: 130,
      wheels: [{ x: 118, r: 10 }, { x: 32, r: 10 }],
      head: { x: 148, y: 27 }, tail: { x: 2, y: 24 },
      roof: { x: 72, y: 0, w: 22, h: 9, text: "TAXI" },
      outline(g, L, Hv) {
        g.beginPath();
        g.moveTo(4 * HD, Hv * 0.46);
        g.quadraticCurveTo(10 * HD, Hv * 0.20, 44 * HD, Hv * 0.16);   // custode
        g.quadraticCurveTo(72 * HD, Hv * 0.04, 96 * HD, Hv * 0.16);   // pavillon fuyant
        g.quadraticCurveTo(128 * HD, Hv * 0.30, 142 * HD, Hv * 0.48);
        g.quadraticCurveTo(L, Hv * 0.54, L - 2 * HD, Hv * 0.70);
        g.lineTo(L - 2 * HD, Hv * 0.88); g.lineTo(2, Hv * 0.88);
        g.lineTo(2, Hv * 0.62);
        g.closePath();
      },
      windows(g, L, Hv) {
        paintGlass(g, 46 * HD, Hv * 0.18, 26 * HD, Hv * 0.26, 3 * HD);
        paintGlass(g, 76 * HD, Hv * 0.18, 26 * HD, Hv * 0.26, 3 * HD);
        g.fillStyle = "rgba(255,255,255,0.16)";        // ligne chromée de vitrage
        g.fillRect(42 * HD, Hv * 0.46, 66 * HD, HD);
      },
      details(g, L, Hv) {
        g.fillStyle = "rgba(255,255,255,0.07)";        // poignées
        rr(g, 62 * HD, Hv * 0.54, 7 * HD, 2 * HD, HD); g.fill();
        rr(g, 92 * HD, Hv * 0.54, 7 * HD, 2 * HD, HD); g.fill();
      },
    });
  }
  function mkEcole() {                                 // ECSR : compacte auto-école
    return buildVehicle({
      L: 120, H: 44, top: "#3A4174", mid: "#252B57", low: "#151A41",
      shoulder: 0.52, coneLen: 115,
      wheels: [{ x: 94, r: 9.5 }, { x: 26, r: 9.5 }],
      head: { x: 118, y: 28 }, tail: { x: 2, y: 25 },
      roof: { x: 48, y: 0, w: 26, h: 10, text: "AUTO-ÉCOLE", tri: true },
      ind: { x: 116, y: 34 },
      outline(g, L, Hv) {
        g.beginPath();
        g.moveTo(4 * HD, Hv * 0.34);                   // hayon presque droit
        g.quadraticCurveTo(20 * HD, Hv * 0.12, 52 * HD, Hv * 0.12);
        g.quadraticCurveTo(84 * HD, Hv * 0.14, 102 * HD, Hv * 0.40);
        g.quadraticCurveTo(L - 2 * HD, Hv * 0.50, L - 2 * HD, Hv * 0.68);
        g.lineTo(L - 2 * HD, Hv * 0.88); g.lineTo(2, Hv * 0.88);
        g.closePath();
      },
      windows(g, L, Hv) {
        paintGlass(g, 26 * HD, Hv * 0.20, 26 * HD, Hv * 0.24, 3 * HD);
        paintGlass(g, 56 * HD, Hv * 0.20, 30 * HD, Hv * 0.26, 3 * HD);
      },
      details(g, L, Hv) {
        g.fillStyle = "#12173A";                       // double rétroviseur
        rr(g, 96 * HD, Hv * 0.34, 5 * HD, 4 * HD, HD); g.fill();
        rr(g, 22 * HD, Hv * 0.32, 4 * HD, 3 * HD, HD); g.fill();
      },
    });
  }

  /* ── Décor : ciel, skyline, terminal, route, mobilier ────────────── */
  let sky, skyline, terminal, lamp, pool, rail, signSprite, shelter, silhouette;
  let asphaltNoise, fogBand, forkliftSp, paletteSp, spotGlow;
  const stars = [];

  function prerenderDecor() {
    /* Ciel */
    sky = mk(W, H);
    let g = sky.getContext("2d");
    let gr = g.createLinearGradient(0, 0, 0, H);
    gr.addColorStop(0, "#060916"); gr.addColorStop(0.55, "#0B1029"); gr.addColorStop(1, "#10163F");
    g.fillStyle = gr; g.fillRect(0, 0, W, H);
    gr = g.createRadialGradient(W * 0.86, H * 0.06, 10, W * 0.86, H * 0.06, W * 0.5);
    gr.addColorStop(0, "rgba(159,226,32,0.045)"); gr.addColorStop(1, "rgba(159,226,32,0)");
    g.fillStyle = gr; g.fillRect(0, 0, W, H);
    stars.length = 0;
    const n = mobile ? 22 : 42;
    for (let i = 0; i < n; i++) {
      stars.push({ x: Math.random() * W, y: Math.random() * H * 0.34,
        r: 0.5 + Math.random() * 0.9, ph: Math.random() * 7, sp: 0.3 + Math.random() * 0.8 });
    }
    /* Skyline lointaine, légèrement floutée (dessinée petite puis agrandie) */
    const skH = Math.round(H * 0.16), small = mk(W / 3, skH / 3);
    g = small.getContext("2d");
    g.scale(1 / 3, 1 / 3);
    g.fillStyle = "#141A3E";
    let x = -20;
    let i = 0;
    while (x < W + 40) {
      const bw = 46 + ((i * 37) % 70), bh = skH * (0.30 + ((i * 53) % 47) / 100);
      g.fillRect(x, skH - bh, bw, bh);
      if (i % 4 === 1) {                                // grue portique
        g.fillRect(x + bw + 6, skH - bh - 26, 4, bh + 26);
        g.fillRect(x + bw - 10, skH - bh - 26, 44, 4);
      }
      if (i % 5 === 3) {                                // château d'eau
        g.beginPath(); g.arc(x + bw + 18, skH - bh - 6, 9, 0, 7); g.fill();
        g.fillRect(x + bw + 16, skH - bh - 6, 4, bh + 6);
      }
      g.fillStyle = "rgba(255,214,140,0.55)";           // fenêtres allumées
      for (let k = 0; k < 4; k++) {
        if ((i * 7 + k * 13) % 3 === 0) g.fillRect(x + 6 + k * 9, skH - bh + 6 + ((k * 17) % 18), 2, 2);
      }
      g.fillStyle = "#141A3E";
      x += bw + 14; i++;
    }
    skyline = mk(W, skH);
    g = skyline.getContext("2d");
    g.imageSmoothingEnabled = true;
    g.drawImage(small, 0, 0, W, skH);                   // agrandissement = flou doux
    g.fillStyle = "rgba(11,15,36,0.35)";                // désaturation profondeur
    g.fillRect(0, 0, W, skH);
    /* Brume d'horizon */
    fogBand = mk(W, Math.round(H * 0.12));
    g = fogBand.getContext("2d");
    gr = g.createLinearGradient(0, 0, 0, fogBand.height);
    gr.addColorStop(0, "rgba(35,43,102,0)");
    gr.addColorStop(0.6, "rgba(35,43,102,0.34)");
    gr.addColorStop(1, "rgba(35,43,102,0)");
    g.fillStyle = gr; g.fillRect(0, 0, W, fogBand.height);
    /* Terminal logistique du commissionnaire */
    terminal = mk(420, 130);
    g = terminal.getContext("2d");
    g.fillStyle = "#161C42";                            // entrepôt à sheds
    g.beginPath(); g.moveTo(0, 130);
    g.lineTo(0, 52);
    for (let s = 0; s < 5; s++) { g.lineTo(18 + s * 44, 30); g.lineTo(44 + s * 44, 52); }
    g.lineTo(240, 130); g.closePath(); g.fill();
    g.fillStyle = "rgba(255,214,140,0.5)";              // porte de quai éclairée
    g.fillRect(36, 92, 26, 38);
    g.fillStyle = "rgba(159,226,32,0.55)";              // enseigne discrète
    g.fillRect(150, 46, 34, 3);
    g.font = `600 9px ${FONT}`; g.fillStyle = "rgba(255,255,255,0.5)";
    g.fillText("TERMINAL MFT", 118, 42);
    const cCol = ["#1D2450", "#232B5E", "#182050"];     // pile de conteneurs
    for (let r = 0; r < 2; r++) for (let k = 0; k < 3 - r; k++) {
      g.fillStyle = cCol[(r + k) % 3];
      g.fillRect(258 + k * 46 + r * 20, 104 - r * 22, 44, 20);
      g.strokeStyle = "rgba(255,255,255,0.05)";
      for (let v = 6; v < 44; v += 7) { g.beginPath(); g.moveTo(258 + k * 46 + r * 20 + v, 106 - r * 22); g.lineTo(258 + k * 46 + r * 20 + v, 122 - r * 22); g.stroke(); }
    }
    g.strokeStyle = "#232B5E"; g.lineWidth = 5;         // portique
    g.beginPath(); g.moveTo(252, 130); g.lineTo(252, 20); g.lineTo(412, 20); g.lineTo(412, 130); g.stroke();
    g.fillStyle = "#232B5E"; g.fillRect(300, 20, 34, 10);
    spotGlow = glowSprite(60, "255,214,140", 0.16);
    /* Chariot élévateur + palette */
    forkliftSp = mk(56, 40); g = forkliftSp.getContext("2d");
    g.fillStyle = "#252C58"; rr(g, 14, 10, 26, 20, 3); g.fill();       // châssis
    g.fillStyle = "#12173A"; rr(g, 18, 2, 16, 12, 2); g.fill();        // arceau
    g.fillStyle = "#0A0D22"; g.beginPath(); g.arc(20, 34, 6, 0, 7); g.fill();
    g.beginPath(); g.arc(40, 34, 5, 0, 7); g.fill();
    g.fillStyle = "#3A4270"; g.fillRect(46, 4, 3, 32);                 // mât
    g.fillRect(46, 30, 10, 3);                                         // fourches
    paletteSp = mk(30, 12); g = paletteSp.getContext("2d");
    g.fillStyle = "#3A2F1E"; g.fillRect(0, 0, 30, 4); g.fillRect(2, 8, 26, 4);
    g.fillRect(3, 4, 4, 4); g.fillRect(13, 4, 4, 4); g.fillRect(23, 4, 4, 4);
    /* Lampadaire + flaque */
    lamp = mk(60, 200); g = lamp.getContext("2d");
    gr = g.createLinearGradient(0, 0, 0, 200);
    gr.addColorStop(0, "#2A315E"); gr.addColorStop(1, "#141939");
    g.fillStyle = gr; g.fillRect(6, 18, 5, 182);
    g.beginPath(); g.moveTo(8, 22); g.quadraticCurveTo(10, 2, 48, 6);  // crosse
    g.lineWidth = 4; g.strokeStyle = gr; g.stroke();
    g.fillStyle = "#EFE6C8"; rr(g, 40, 2, 16, 6, 3); g.fill();         // tête LED
    pool = mk(150, 44); g = pool.getContext("2d");
    gr = g.createRadialGradient(75, 22, 2, 75, 22, 74);
    gr.addColorStop(0, "rgba(255,240,200,0.13)"); gr.addColorStop(1, "rgba(255,240,200,0)");
    g.fillStyle = gr;
    g.save(); g.translate(75, 22); g.scale(1, 0.3); g.translate(-75, -75);
    g.fillRect(0, 0, 150, 150); g.restore();
    /* Glissière de sécurité (tuile répétable, profil W) */
    rail = mk(120, 34); g = rail.getContext("2d");
    g.fillStyle = "#1A2047"; g.fillRect(14, 12, 5, 22); g.fillRect(74, 12, 5, 22);
    gr = g.createLinearGradient(0, 0, 0, 14);
    gr.addColorStop(0, "#3A4272"); gr.addColorStop(0.5, "#232A55"); gr.addColorStop(1, "#3A4272");
    g.fillStyle = gr; g.fillRect(0, 2, 120, 14);
    g.fillStyle = "rgba(255,255,255,0.10)"; g.fillRect(0, 8, 120, 2);
    /* Bruit d'asphalte (bande discrète) */
    asphaltNoise = mk(240, 80); g = asphaltNoise.getContext("2d");
    for (let k = 0; k < 340; k++) {
      g.fillStyle = `rgba(255,255,255,${0.015 + Math.random() * 0.03})`;
      g.fillRect(Math.random() * 240, Math.random() * 80, 1.4, 1);
    }
    /* Panneau de direction français « Ma Formation Transport → » */
    signSprite = mk(250, 190); g = signSprite.getContext("2d");
    g.fillStyle = "#585F72"; g.fillRect(52, 60, 7, 130); g.fillRect(186, 60, 7, 130);  // mâts
    g.fillStyle = "#464C5C"; g.fillRect(50, 96, 11, 5); g.fillRect(184, 96, 11, 5);    // colliers
    gr = g.createLinearGradient(0, 8, 0, 78);
    gr.addColorStop(0, "#1E4AA5"); gr.addColorStop(1, "#153577");                      // bleu signalisation
    rr(g, 14, 8, 222, 70, 9); g.fillStyle = gr; g.fill();
    g.strokeStyle = "rgba(255,255,255,0.92)"; g.lineWidth = 4; rr(g, 19, 13, 212, 60, 6); g.stroke();
    g.font = `600 21px ${FONT}`; g.fillStyle = "rgba(255,255,255,0.96)";
    g.textAlign = "center";
    g.fillText("Ma Formation", 112, 38);
    g.fillText("Transport", 100, 62);
    g.font = `700 30px ${FONT}`;
    g.fillText("→", 202, 56);
    g.textAlign = "left";
    gr = g.createLinearGradient(0, 78, 0, 8);                                          // balayage des phares
    gr.addColorStop(0, "rgba(255,244,214,0.16)"); gr.addColorStop(1, "rgba(255,244,214,0)");
    rr(g, 14, 8, 222, 70, 9); g.fillStyle = gr; g.fill();
    /* Abribus + silhouette du passager */
    shelter = mk(84, 74); g = shelter.getContext("2d");
    g.fillStyle = "#1A2047"; g.fillRect(4, 0, 76, 6);
    g.fillStyle = "rgba(120,140,220,0.12)"; g.fillRect(8, 6, 68, 54);
    g.strokeStyle = "#232A55"; g.lineWidth = 3;
    g.strokeRect(8, 6, 68, 54); g.beginPath(); g.moveTo(42, 6); g.lineTo(42, 60); g.stroke();
    g.fillStyle = "#1A2047"; g.fillRect(6, 60, 4, 14); g.fillRect(74, 60, 4, 14);
    silhouette = mk(22, 46); g = silhouette.getContext("2d");
    g.fillStyle = "#0B0F26";
    g.beginPath(); g.arc(11, 6, 5, 0, 7); g.fill();                                    // tête
    rr(g, 5, 12, 12, 22, 5); g.fill();                                                 // buste + manteau
    g.fillRect(7, 33, 4, 12); g.fillRect(12, 33, 4, 12);                               // jambes
    rr(g, 15, 22, 6, 9, 2); g.fill();                                                  // sacoche
  }

  /* ── Enseignes de toit lumineuses (taxi / auto-école) ────────────── */
  function roofSprite(spec) {
    const w = spec.w * HD * 2, h = spec.h * HD * 2;
    const c = mk(w, h + 6), g = c.getContext("2d");
    if (spec.tri) {                                    // triangle auto-école
      g.fillStyle = "rgba(240,246,255,0.92)";
      g.beginPath(); g.moveTo(w * 0.5, 2); g.lineTo(w * 0.94, h); g.lineTo(w * 0.06, h);
      g.closePath(); g.fill();
      g.fillStyle = "#12173A";
      g.font = `700 ${Math.round(h * 0.34)}px ${FONT}`; g.textAlign = "center";
      g.fillText("AUTO", w / 2, h * 0.62);
      g.fillText("ÉCOLE", w / 2, h * 0.95);
    } else {
      const gr = g.createLinearGradient(0, 0, 0, h);
      gr.addColorStop(0, "#FDF7DE"); gr.addColorStop(1, "#E8DFB8");
      g.fillStyle = gr; rr(g, 2, 2, w - 4, h - 2, 4); g.fill();
      g.fillStyle = "#12173A";
      g.font = `700 ${Math.round(h * 0.62)}px ${FONT}`; g.textAlign = "center";
      g.fillText(spec.text, w / 2, h * 0.72);
    }
    return c;
  }

  /* ── Flotte + files ──────────────────────────────────────────────── */
  const F = { semi: mkSemi(), autocar: mkAutocar(), porteur: mkPorteur(),
              util: mkUtilitaire(), taxi: mkTaxi(), ecole: mkEcole() };
  for (const k of ["taxi", "ecole"]) F[k].roofSp = roofSprite(F[k].roof);

  const near = [];      // voie proche, gauche → droite
  const far = [];       // voie lointaine, droite → gauche
  let nearOrder, farOrder, nearIdx = 0, farIdx = 0;
  let groundOff = 0, farSpawnIn = 2.5;
  let script;           // scène taxi
  let S = 1;            // échelle d'affichage voie proche

  function vScale() { return clamp(W / 980, 0.60, 1.0) * (mobile ? 0.92 : 1); }
  function laneY() { return H * 0.795; }
  function farY() { return H * 0.635; }

  function spawnNear(x) {
    const kind = nearOrder[nearIdx++ % nearOrder.length];
    const veh = F[kind];
    near.push({
      kind, veh, x, y: 0, v: (92 + Math.random() * 10),
      ph: Math.random() * 7, wheelA: 0, brake: 0, ind: 0, indT: kind === "ecole" ? 3.6 : 0,
      settle: kind === "ecole" ? 1 : 0,
    });
  }
  function resetTraffic() {
    near.length = 0; far.length = 0; nearIdx = 0; farIdx = 0;
    nearOrder = mobile ? ["semi", "taxi", "util"] : ["semi", "util", "taxi", "ecole", "porteur"];
    farOrder = ["autocar", "porteur"];
    /* Convoi PRÉ-PEUPLÉ dès la première frame : semi en vedette. */
    let x = W * 0.62;
    spawnNear(x);
    for (let i = 1; i < (mobile ? 2 : 3); i++) {
      const prev = near[near.length - 1];
      x = prev.x - prev.veh.L * S - (95 + Math.random() * 60);
      spawnNear(x);
    }
    if (!mobile) far.push({ kind: "autocar", veh: F.autocar, x: W * 0.30, v: 55, ph: 2, wheelA: 0 });
    script = { t: 14, phase: "wait", px: 0, pa: 0 };
    groundOff = 0;
  }

  /* Mobilier en coordonnées monde (défile en mode connecting) */
  const SPAN = 1600;
  function worldX(wx, k) {                             // k = facteur de parallaxe
    const off = groundOff * k + (ptr.sx - 0.5) * -22 * k;
    let x = (wx - off) % SPAN;
    if (x < -300) x += SPAN;
    return x;
  }

  /* ── Boucle ──────────────────────────────────────────────────────── */
  function frame(t) {
    if (destroyed) return;
    raf = requestAnimationFrame(frame);
    // Canvas encore sans dimensions (onglet caché, display:none) :
    // resize() n'a pas pu initialiser le trafic, on attend le layout.
    if (!W || !H || !nearOrder) { lastT = t; return; }
    const dt = Math.min(0.05, (t - lastT) / 1000 || 0.016);
    lastT = t; worldT += dt;
    ptr.sx = lerp(ptr.sx, ptr.x, 0.05); ptr.sy = lerp(ptr.sy, ptr.y, 0.05);
    speed = lerp(speed, speedTarget, 1 - Math.pow(0.002, dt));   // rampe naturelle
    camScale = lerp(camScale, camScaleT, 1 - Math.pow(0.008, dt));
    veil = lerp(veil, veilT, 1 - Math.pow(0.01, dt));
    if (speed > 1.04) groundOff += (speed - 1) * 300 * dt;

    /* Trafic voie proche : avance, espacement mini, recyclage. */
    for (let i = near.length - 1; i >= 0; i--) {
      const o = near[i];
      let vGoal = o.v;
      if (script && o.kind === "taxi") vGoal = taxiGoal(o, dt);
      const ahead = nearest(o);
      const gap = ahead ? ahead.x - (o.x + o.veh.L * S) : 1e9;
      if (gap < 70 * S) vGoal = Math.min(vGoal, ahead.v * 0.94);  // ne colle jamais
      const vOld = o.vNow ?? vGoal;
      o.vNow = lerp(vOld, vGoal, 1 - Math.pow(0.01, dt));
      o.brake = clamp(lerp(o.brake, vOld - o.vNow > 2 ? 1 : 0, 0.2), 0, 1);
      const vScreen = o.vNow * speed * (speed > 1.04 ? 0.42 : 1);  // caméra qui suit
      o.x += vScreen * dt;
      o.wheelA += (vScreen + (speed > 1.04 ? (speed - 1) * 300 : 0)) * dt / (o.veh.wheels[0].r * S);
      if (o.indT > 0) { o.indT -= dt; o.ind = (worldT * 1.2) % 1 < 0.5 ? 1 : 0; } else o.ind = 0;
      if (o.settle > 0) { o.settle = Math.max(0, o.settle - dt / 1.6); o.y = 12 * S * easeIO(o.settle); }
      if (o.x > W + 80) near.splice(i, 1);
    }
    const last = near.reduce((m, o) => (o.x < m ? o.x : m), 1e9);
    if (near.length < (mobile ? 3 : 4) && last > 140) {
      spawnNear(last - (F[nearOrder[nearIdx % nearOrder.length]].L * S + 95 + Math.random() * 70));
    }
    /* Voie lointaine (droite → gauche) */
    if (!mobile) {
      farSpawnIn -= dt;
      if (far.length < 2 && farSpawnIn <= 0) {
        const kind = farOrder[farIdx++ % farOrder.length];
        far.push({ kind, veh: F[kind], x: W + 200, v: 52 + Math.random() * 8, ph: Math.random() * 7, wheelA: 0 });
        farSpawnIn = 6 + Math.random() * 5;
      }
      for (let i = far.length - 1; i >= 0; i--) {
        const o = far[i];
        o.x -= o.v * speed * dt;
        o.wheelA += o.v * speed * dt / (o.veh.wheels[0].r * S * 0.55);
        if (o.x < -o.veh.L * S) far.splice(i, 1);
      }
    }
    draw();
  }
  function nearest(o) {
    let best = null;
    for (const p of near) if (p !== o && p.x > o.x && (!best || p.x < best.x)) best = p;
    return best;
  }

  /* Scène scriptée : le taxi charge un passager (desktop, idle). */
  function shelterX() { return worldX(Math.min(W * 0.60, SPAN - 420), 1); }
  function taxiGoal(o, dt) {
    const sx = shelterX();
    switch (script.phase) {
      case "wait":
        if (state === "idle" && !mobile) { script.t -= dt; if (script.t <= 0 && o.x < sx - 260 * S && sx < W - 240) { script.phase = "approach"; } }
        return o.v;
      case "approach": {
        o.yOff = lerp(o.yOff || 0, 15 * S, 0.03);                  // se déporte côté accotement
        const d = sx - 40 * S - (o.x + o.veh.L * S);
        if (d < 4) { script.phase = "board"; script.t = 2.6; script.pa = 0; }
        return clamp(d * 0.9, 6, o.v);                             // freinage doux
      }
      case "board":
        script.t -= dt; script.pa = clamp(script.pa + dt / 1.6, 0, 1);
        if (script.t <= 0) { script.phase = "depart"; script.t = 3.4; }
        return 0;
      case "depart":
        script.t -= dt;
        o.ind = (worldT * 1.2) % 1 < 0.5 ? 1 : 0;
        o.yOff = lerp(o.yOff || 0, 0, 0.03);
        if (script.t <= 0) { script.phase = "wait"; script.t = 30 + Math.random() * 12; o.ind = 0; }
        return o.v;
    }
    return o.v;
  }

  /* ── Rendu ───────────────────────────────────────────────────────── */
  function blitVehicle(o, scale, y, dim) {
    const v = o.veh, L = v.L * scale, Hh = v.H * scale;
    const bob = reduced ? 0 : Math.sin(worldT * 12.6 + o.ph) * 0.8 * scale;
    const pitch = reduced ? 0 : clamp((speed - 1) * 0.012 + (o.brake || 0) * -0.008, -0.02, 0.03);
    const x = o.x, gy = y + (o.yOff || 0) + bob;
    const lift = v.wheels[0].r * scale * 0.85;
    ctx.save();
    ctx.translate(x + L / 2, gy);
    ctx.rotate(-pitch);
    if (dim) ctx.globalAlpha = 0.82;
    ctx.drawImage(v.ao, -L * 0.55, -Hh * 0.06, L * 1.1, Hh * 0.3);
    ctx.drawImage(v.body, -L / 2, -Hh - lift, L, Hh);
    for (const w of v.wheels) {                                    // roues en rotation
      const wx = -L / 2 + w.x * scale, wr = w.r * scale;
      ctx.save(); ctx.translate(wx, -w.r * scale + 0.5); ctx.rotate(o.wheelA);
      ctx.drawImage(w.sp, -wr, -wr, wr * 2, wr * 2); ctx.restore();
    }
    /* Éclairage : cône avant + feux */
    if (!dim) {
      ctx.globalAlpha = 0.9;
      ctx.drawImage(v.cone, L / 2 - 4, -v.head.y * scale * 0.4, v.cone.width * scale, v.cone.height * scale * 0.5);
    }
    const hx = -L / 2 + v.head.x * scale, hy = -Hh - lift + v.head.y * scale;
    ctx.globalAlpha = 1;
    ctx.drawImage(glowHead, hx - 8, hy - 8, 16, 16);
    const tx = -L / 2 + v.tail.x * scale, ty = -Hh - lift + v.tail.y * scale;
    ctx.drawImage(o.brake > 0.5 ? glowStop : glowTail, tx - 7, ty - 7, 14, 14);
    if (o.ind) {                                                   // clignotants ambrés
      ctx.drawImage(glowInd, hx - 5, hy + 4, 10, 10);
      ctx.drawImage(glowInd, tx - 5, ty + 4, 10, 10);
    }
    if (v.marker) {                                                // gabarits orange
      ctx.fillStyle = "rgba(255,150,54,0.85)";
      for (let mX = -L / 2 + 12 * scale; mX < L / 2 - 8 * scale; mX += 34 * scale) {
        ctx.fillRect(mX, -Hh * 0.16 - lift, 1.6, 1.6);
      }
    }
    if (v.roofSp) {                                                // enseigne lumineuse
      const r = v.roof, rw = r.w * scale, rh = r.h * scale;
      const rx = -L / 2 + r.x * scale;
      ctx.drawImage(glowLimeS, rx + rw / 2 - 9, -Hh - lift - rh - 7, 18, 18);
      ctx.drawImage(v.roofSp, rx, -Hh - lift - rh - 1, rw, rh + 2);
    }
    /* Halo de lampadaire : le véhicule s'éclaircit en passant dessous */
    for (let li = 0; li < lampsX.length; li++) {
      const d = Math.abs(x + L / 2 - lampsX[li]);
      if (d < 100) {
        ctx.globalAlpha = 0.10 * (1 - d / 100);
        ctx.drawImage(v.body, -L / 2, -Hh - lift, L, Hh);
        ctx.globalAlpha = 1;
        break;
      }
    }
    ctx.restore();
  }

  let lampsX = [];
  function draw() {
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    /* Caméra success : avance vers le point de fuite à droite */
    if (camScale > 1.001) {
      ctx.translate(W * 0.72, H * 0.5); ctx.scale(camScale, camScale);
      ctx.translate(-W * 0.72, -H * 0.5);
    }
    ctx.drawImage(sky, 0, 0);
    ctx.fillStyle = "#EDF1FF";
    for (const s of stars) {                                       // scintillement
      ctx.globalAlpha = 0.25 + 0.5 * (0.5 + 0.5 * Math.sin(worldT * s.sp + s.ph));
      ctx.fillRect(s.x + (ptr.sx - 0.5) * -3, s.y, s.r, s.r);
    }
    ctx.globalAlpha = 1;
    const horizon = H * 0.44;
    ctx.drawImage(skyline, (ptr.sx - 0.5) * -6 - 8, horizon - skyline.height, W + 16, skyline.height);
    /* Terminal logistique (plan moyen, parallaxe 0.35) */
    const tx = worldX(520, 0.35), tw = mobile ? 300 : 400;
    ctx.drawImage(spotGlow, tx + tw * 0.15, horizon - 90, 120, 120);
    ctx.drawImage(terminal, tx, horizon - tw * 0.31, tw, tw * 0.31);
    /* Chariot élévateur en navette avec sa palette */
    if (!reduced) {
      const k = (Math.sin(worldT * 0.35) + 1) / 2;                 // aller-retour 9 s
      const fx = tx + tw * 0.18 + k * tw * 0.34;
      ctx.save(); if (Math.cos(worldT * 0.35) < 0) { ctx.translate(fx * 2 + 42, 0); ctx.scale(-1, 1); }
      ctx.drawImage(forkliftSp, fx, horizon - 32, 42, 30);
      ctx.drawImage(paletteSp, fx + 30, horizon - 12, 20, 8);
      ctx.restore();
    }
    ctx.drawImage(fogBand, 0, horizon - fogBand.height * 0.55);
    /* Route */
    const roadTop = H * 0.55, roadBot = H * 0.92;
    let gr = ctx.createLinearGradient(0, roadTop, 0, roadBot);
    gr.addColorStop(0, "#0B0F28"); gr.addColorStop(1, "#12173A");
    ctx.fillStyle = gr; ctx.fillRect(0, roadTop, W, roadBot - roadTop);
    ctx.globalAlpha = 0.5; ctx.drawImage(asphaltNoise, 0, roadBot - 90, W, 84); ctx.globalAlpha = 1;
    ctx.fillStyle = "rgba(255,255,255,0.16)";                      // rives
    ctx.fillRect(0, roadTop + 4, W, 1.5);
    ctx.fillRect(0, roadBot - 8, W, 2);
    for (let x = worldX(0, 1) % 90 - 90; x < W; x += 90) {         // axe pointillé
      ctx.fillStyle = "rgba(255,255,255,0.22)";
      ctx.fillRect(x, H * 0.705, 34, 2.5);
    }
    for (let x = worldX(40, 1) % 300 - 300; x < W; x += 300) {     // joints de chaussée
      ctx.fillStyle = "rgba(0,0,0,0.18)"; ctx.fillRect(x, roadTop + 6, 1.5, roadBot - roadTop - 14);
    }
    /* Panneau de direction (plan moyen route, avant les véhicules) */
    const sgx = worldX(Math.min(W * 0.76, W - 214, SPAN - 230), 1);
    if (sgx > -260 && sgx < W + 40) {
      const sgw = clamp(H * 0.30, 132, 200), sgh = sgw * 0.76;
      ctx.drawImage(signSprite, sgx, H * 0.565 - sgh, sgw, sgh);
    }
    /* Abribus de la scène taxi */
    if (!mobile) {
      const shx = shelterX();
      if (shx > -100 && shx < W + 40) {
        ctx.drawImage(shelter, shx, H * 0.845 - 62, 70, 62);
        if (script.phase === "approach" || script.phase === "board") {
          const taxi = near.find((o) => o.kind === "taxi");
          if (taxi) {
            const doorX = taxi.x + taxi.veh.L * S * 0.62;
            const px = lerp(shx + 18, doorX, script.pa);
            ctx.globalAlpha = 1 - Math.max(0, script.pa - 0.85) / 0.15;   // fondu en montant
            ctx.drawImage(silhouette, px, H * 0.845 - 38, 16, 34);
            ctx.globalAlpha = 1;
          }
        }
      }
    }
    /* Lampadaires + flaques */
    lampsX.length = 0;
    const lampSpan = mobile ? 520 : 340;
    for (let wx = 60; wx < SPAN; wx += lampSpan) {
      const x = worldX(wx, 1);
      if (x < -80 || x > W + 80) continue;
      lampsX.push(x + 44);
      ctx.drawImage(lamp, x, H * 0.545, 42, 150);
      ctx.drawImage(pool, x - 20, H * 0.775, 130, 38);
    }
    /* Voie lointaine (petits, assombris) puis convoi vedette */
    if (!mobile) for (const o of far) {
      ctx.save(); ctx.translate(o.x + o.veh.L * S * 0.55, 0); ctx.scale(-1, 1);
      ctx.translate(-(o.x + o.veh.L * S * 0.55), 0);
      blitVehicle(o, S * 0.55, farY(), true);
      ctx.restore();
    }
    for (const o of near) blitVehicle(o, S, laneY(), false);
    /* Traînées lumineuses en accélération */
    if (speed > 1.5 && !reduced) {
      ctx.globalAlpha = clamp((speed - 1.5) / 2, 0, 0.35);
      for (const o of near) {
        const v = o.veh, hx = o.x + v.head.x * S, hy = laneY() - v.H * S + v.head.y * S;
        gr = ctx.createLinearGradient(hx - 150, 0, hx, 0);
        gr.addColorStop(0, "rgba(255,244,214,0)"); gr.addColorStop(1, "rgba(255,244,214,0.5)");
        ctx.fillStyle = gr; ctx.fillRect(hx - 150, hy - 1.5, 150, 3);
      }
      ctx.globalAlpha = 1;
    }
    /* Glissière premier plan */
    for (let x = worldX(0, 1.15) % 110 - 110; x < W; x += 110) {
      ctx.drawImage(rail, x, H * 0.875, 112, 32);
    }
    /* Voile final */
    if (veil > 0.01) {
      ctx.fillStyle = `rgba(11,15,36,${veil * 0.65})`;
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
      ctx.fillRect(0, 0, W, H);
    }
  }

  /* ── Cycle de vie ────────────────────────────────────────────────── */
  function resize() {
    const r = canvas.getBoundingClientRect();
    if (!r.width || !r.height) return;
    mobile = r.width < 520;
    dpr = Math.min(window.devicePixelRatio || 1, mobile ? 1.75 : 2);
    W = r.width; H = r.height;
    canvas.width = Math.round(W * dpr); canvas.height = Math.round(H * dpr);
    S = vScale();
    prerenderDecor();
    resetTraffic();
    if (reduced) drawStill();
  }
  function drawStill() {
    /* Mode animations réduites : plan fixe (convoi arrêté sous les
       lampadaires, phares allumés), redessiné aux changements d'état. */
    if (!W || !H || !nearOrder) return;
    speed = 1; groundOff = 0;
    near.length = 0; nearIdx = 0; spawnNear(W * 0.40); near[0].vNow = 0;
    if (!mobile) { nearIdx = 2; spawnNear(W * 0.40 - F.taxi.L * S - 130); near[1] && (near[1].vNow = 0); }
    worldT = 0; draw();
  }
  const ro = new ResizeObserver(resize);
  ro.observe(canvas);
  const onVis = () => {
    if (document.hidden) { cancelAnimationFrame(raf); raf = 0; }
    else if (!raf && !reduced && !destroyed) { lastT = performance.now(); raf = requestAnimationFrame(frame); }
  };
  document.addEventListener("visibilitychange", onVis);
  resize();
  if (!document.hidden) raf = requestAnimationFrame(frame);

  return {
    setState(s) {
      state = s;
      if (s === "idle") { speedTarget = 1; camScaleT = 1; veilT = 0; if (script) { script.phase = "wait"; script.t = 14; } }
      if (s === "connecting") { speedTarget = 3; camScaleT = 1.015; veilT = 0; }
      if (s === "success") { speedTarget = 3.6; camScaleT = 1.12; veilT = 1; }
      if (reduced) drawStill();
    },
    setPointer(nx, ny) { ptr.x = nx; ptr.y = ny; },
    setReduced(r) {
      reduced = r;
      if (r) { cancelAnimationFrame(raf); raf = 0; drawStill(); }
      else if (!raf && !document.hidden) { lastT = performance.now(); raf = requestAnimationFrame(frame); }
    },
    destroy() {
      destroyed = true;
      cancelAnimationFrame(raf);
      ro.disconnect();
      document.removeEventListener("visibilitychange", onVis);
    },
  };
};
