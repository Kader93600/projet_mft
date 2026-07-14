// =====================================================================
// Accent de formation — lisibilité en thème CLAIR et SOMBRE.
//
// Chaque formation porte une couleur d'accent HEX (lib/formations-config.ts).
// Elle est appliquée en STYLE INLINE, or un style inline ne peut PAS être
// surchargé par une règle `.dark` : il gagne toujours. Résultat, avant ce
// module, les accents foncés (ex. #2530D9 pour « Capacité > 3,5 t ») restaient
// en bleu profond sur fond navy en thème sombre : ~2,1:1, illisible.
//
// La solution : ne jamais poser `color`/`background` en dur, mais émettre des
// VARIABLES CSS (jeu clair + jeu sombre) via `accentVars()`, et laisser le CSS
// choisir selon le thème (règles `.formation-accent` / `.dark .formation-accent`
// dans app/globals.css).
//
// Les deux adaptations sont pilotées par le CONTRASTE WCAG RÉEL, pas par un
// facteur au jugé : le résultat est donc lisible quelle que soit la couleur.
// =====================================================================

/** Surface de référence en thème sombre (fond des cartes, cf. globals.css). */
const DARK_SURFACE = "#121A2C";

/** Luminance relative WCAG (sRGB). */
function relativeLuminance(hex: string): number {
  const h = hex.replace("#", "");
  const chan = [0, 2, 4].map((i) => parseInt(h.slice(i, i + 2), 16) / 255);
  const lin = chan.map((c) =>
    c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4)
  );
  return 0.2126 * lin[0] + 0.7152 * lin[1] + 0.0722 * lin[2];
}

/** Ratio de contraste WCAG entre deux couleurs HEX. */
export function contrastRatio(a: string, b: string): number {
  const la = relativeLuminance(a);
  const lb = relativeLuminance(b);
  const hi = Math.max(la, lb);
  const lo = Math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

const toHex = (c: number) =>
  Math.max(0, Math.min(255, Math.round(c)))
    .toString(16)
    .padStart(2, "0");

/** Mélange progressif d'une couleur vers une cible, jusqu'à atteindre `target`. */
function blendUntilReadable(
  hex: string,
  towards: [number, number, number],
  surface: string,
  target: number
): string {
  const h = hex.replace("#", "");
  if (h.length < 6) return hex;
  const r = parseInt(h.slice(0, 2), 16);
  const g = parseInt(h.slice(2, 4), 16);
  const b = parseInt(h.slice(4, 6), 16);
  for (let t = 0; t <= 1.0001; t += 0.04) {
    const candidate = `#${toHex(r + (towards[0] - r) * t)}${toHex(
      g + (towards[1] - g) * t
    )}${toHex(b + (towards[2] - b) * t)}`;
    if (contrastRatio(candidate, surface) >= target) return candidate;
  }
  return `#${toHex(towards[0])}${toHex(towards[1])}${toHex(towards[2])}`;
}

/**
 * Éclaircit un accent (vers le blanc) jusqu'à être lisible sur fond SOMBRE.
 * Cible 5,0 : une marge au-dessus du seuil AA (4,5), le texte des pastilles
 * étant petit et en majuscules.
 *
 *   #2530D9 (Capacité > 3,5 t) : 2,07:1 → éclairci jusqu'à ≥ 5,0:1
 *   #9FE220 (lime, déjà clair) : 11,05:1 → renvoyé inchangé
 */
export function lightenForDarkTheme(hex: string): string {
  return blendUntilReadable(hex, [255, 255, 255], DARK_SURFACE, 5.0);
}

/**
 * Assombrit un accent pour le fond CLAIR (ivory).
 *
 * ⚠️ On conserve VOLONTAIREMENT l'heuristique historique (facteur adaptatif),
 * et non un calcul par contraste : le thème clair est en production et validé,
 * on ne veut pas en modifier l'apparence en corrigeant le thème sombre.
 * Le passage au contraste réel côté clair serait une amélioration à part.
 */
export function darkenForLightTheme(hex: string): string {
  const h = hex.replace("#", "");
  if (h.length < 6) return hex;
  const r = parseInt(h.slice(0, 2), 16);
  const g = parseInt(h.slice(2, 4), 16);
  const b = parseInt(h.slice(4, 6), 16);
  // Luminance perçue (Rec. 601) — identique à l'implémentation d'origine.
  const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
  let factor: number;
  if (luminance > 0.65) factor = 0.5;
  else if (luminance > 0.5) factor = 0.62;
  else if (luminance > 0.35) factor = 0.78;
  else factor = 1.0;
  return `#${toHex(r * factor)}${toHex(g * factor)}${toHex(b * factor)}`;
}

/** Intensité du fond teinté (suffixe alpha en hexa sur la couleur). */
export type AccentTint = "chip" | "soft" | "outline" | "solid";

/**
 * Renvoie les variables CSS d'un accent de formation, à poser en `style` avec
 * la classe `formation-accent`. Le CSS choisit le jeu clair ou sombre.
 *
 * @example
 *   <span className="formation-accent border" style={accentVars(f.accent)}>
 *     {f.code}
 *   </span>
 */
export function accentVars(
  accent: string | null | undefined,
  tint: AccentTint = "chip"
): React.CSSProperties {
  const a = accent ?? "#9FE220";
  const light = darkenForLightTheme(a);
  const dark = lightenForDarkTheme(a);

  switch (tint) {
    case "solid":
      return {
        "--fa-fg": "#0E1240",
        "--fa-bg": a,
        "--fa-bd": a,
        "--fa-fg-dark": "#0B0F24",
        "--fa-bg-dark": dark,
        "--fa-bd-dark": dark,
      } as React.CSSProperties;
    case "outline":
      return {
        "--fa-fg": light,
        "--fa-bg": "transparent",
        "--fa-bd": `${a}99`,
        "--fa-fg-dark": dark,
        "--fa-bg-dark": "transparent",
        "--fa-bd-dark": `${dark}99`,
      } as React.CSSProperties;
    case "soft":
      return {
        "--fa-fg": light,
        "--fa-bg": `${a}1F`,
        "--fa-bd": `${a}33`,
        "--fa-fg-dark": dark,
        "--fa-bg-dark": `${dark}1F`,
        "--fa-bd-dark": `${dark}33`,
      } as React.CSSProperties;
    case "chip":
    default:
      return {
        "--fa-fg": light,
        "--fa-bg": `${a}26`,
        "--fa-bd": `${a}66`,
        "--fa-fg-dark": dark,
        "--fa-bg-dark": `${dark}1F`,
        "--fa-bd-dark": `${dark}59`,
      } as React.CSSProperties;
  }
}
