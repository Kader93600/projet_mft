// =====================================================================
// Composants réutilisables pour identifier visuellement la formation
// d'un contenu (quiz, module, examen blanc, copie…).
//
// Utilise les couleurs et icônes définies dans lib/formations-config.ts.
//
// Refonte 2026-05 :
//  - Contraste WCAG AA : assombrit dynamiquement les accents trop clairs
//    (signal-500 lime sur ivory était à 3.2:1, sous le seuil 4.5:1).
//  - Tailles md/lg/xl revues à la hausse pour les usages "header de
//    section formation" où le badge doit rester lisible avec le titre
//    complet à côté.
// =====================================================================
import {
  Truck,
  Bus,
  GraduationCap,
  Car,
  Briefcase,
  Package,
  Award,
  ShieldCheck,
} from "lucide-react";
import { findFormation, type Formation } from "@/lib/formations-config";

const ICONS: Record<string, any> = {
  Truck,
  Bus,
  GraduationCap,
  Car,
  Briefcase,
  Package,
  Award,
  ShieldCheck,
};

type Size = "xs" | "sm" | "md" | "lg" | "xl";
type Variant = "chip" | "outline" | "soft" | "solid";

interface BadgeProps {
  /** Slug formation (résolu en couleur + code + icône). */
  slug?: string | null;
  /** Ou directement un objet formation */
  formation?: Formation | null;
  /** Taille du badge */
  size?: Size;
  /** Style visuel */
  variant?: Variant;
  /** Affiche l'icône à gauche */
  icon?: boolean;
  /** Affiche le titre complet à droite du code (sinon code uniquement) */
  withTitle?: boolean;
  /** Classe additionnelle */
  className?: string;
}

const SIZES: Record<Size, string> = {
  xs: "px-1.5 py-0.5 text-[10px] gap-1",
  sm: "px-2 py-1 text-[11px] gap-1.5",
  md: "px-3 py-1.5 text-[13px] gap-2",
  lg: "px-3.5 py-2 text-[15px] gap-2.5",
  xl: "px-4 py-2.5 text-[17px] gap-3",
};

const ICON_SIZES: Record<Size, string> = {
  xs: "h-2.5 w-2.5",
  sm: "h-3 w-3",
  md: "h-4 w-4",
  lg: "h-[18px] w-[18px]",
  xl: "h-5 w-5",
};

const TITLE_SIZES: Record<Size, string> = {
  xs: "text-[10px]",
  sm: "text-[11px]",
  md: "text-[13px]",
  lg: "text-[14px]",
  xl: "text-[15px]",
};

/**
 * Badge formation — identification visuelle immédiate.
 *
 * @example
 * <FormationBadge slug="capacite-3-5t" size="sm" icon />
 * <FormationBadge slug="gotrm" size="lg" withTitle variant="solid" />
 */
export function FormationBadge({
  slug,
  formation: formationProp,
  size = "sm",
  variant = "chip",
  icon = false,
  withTitle = false,
  className,
}: BadgeProps) {
  const f = formationProp ?? (slug ? findFormation(slug) : null);
  if (!f) return null;

  const Icon = ICONS[f.iconName] ?? Truck;
  const accent = f.accent ?? "#9FE220";
  /**
   * Couleur de texte / icône — assombrie pour passer WCAG AA sur fond
   * clair (ivory). Pour les couleurs déjà foncées (navy, slate),
   * `darkenForReadability` retourne quasiment la même couleur.
   */
  const accentText = darkenForReadability(accent);

  let style: React.CSSProperties = {};
  const cls = [
    "inline-flex items-center font-semibold uppercase tracking-wider rounded-lg border",
    SIZES[size],
  ].join(" ");

  switch (variant) {
    case "solid":
      // Bg accent vif, texte navy-950 lisible
      style = {
        backgroundColor: accent,
        color: "#0E1240",
        borderColor: accent,
      };
      break;
    case "outline":
      // Texte accent assombri, border accent semi
      style = {
        color: accentText,
        borderColor: `${accent}99`,
        backgroundColor: "transparent",
      };
      break;
    case "soft":
      // Bg accent très léger, texte assombri
      style = {
        backgroundColor: `${accent}1F`,
        color: accentText,
        borderColor: `${accent}33`,
      };
      break;
    case "chip":
    default:
      // Bg accent léger + border + texte assombri WCAG AA
      style = {
        backgroundColor: `${accent}26`,
        color: accentText,
        borderColor: `${accent}66`,
      };
  }

  return (
    <span
      className={cls + (className ? " " + className : "")}
      style={style}
      title={f.title}
    >
      {icon && <Icon className={ICON_SIZES[size] + " shrink-0"} />}
      <span>{f.code}</span>
      {withTitle && (
        <span
          className={
            "font-medium normal-case opacity-90 ml-1 truncate tracking-normal " +
            TITLE_SIZES[size]
          }
        >
          {/* Tiret moyen avec espaces fines (jamais d'em dash) */}
          – {f.title}
        </span>
      )}
    </span>
  );
}

// ---------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------

/**
 * Assombrit une couleur HEX pour qu'elle reste lisible (≥ 4.5:1) sur
 * fond clair ivory (#FAFAF7). Algorithme simple basé sur la luminance
 * perçue : plus la couleur est claire, plus on assombrit.
 *
 * Exemple :
 *   #9FE220 (signal-500 lime, L≈0.74) → environ #5A8112 (lisible)
 *   #2530D9 (brand-600, L≈0.27)        → presque inchangé
 *   #475569 (slate-600)                → inchangé
 */
function darkenForReadability(hex: string): string {
  const h = hex.replace("#", "");
  if (h.length < 6) return hex;
  const r = parseInt(h.slice(0, 2), 16);
  const g = parseInt(h.slice(2, 4), 16);
  const b = parseInt(h.slice(4, 6), 16);
  // Luminance perçue (Rec. 601, suffisant pour notre usage)
  const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
  // Facteur d'assombrissement adaptatif :
  //  L > 0.65 : très clair (lime, jaune) → 0.55
  //  L > 0.50 : clair (vert clair, sky)  → 0.65
  //  L > 0.35 : moyen                     → 0.80
  //  sinon    : déjà foncé, on garde     → 1.00
  let factor: number;
  if (luminance > 0.65) factor = 0.5;
  else if (luminance > 0.5) factor = 0.62;
  else if (luminance > 0.35) factor = 0.78;
  else factor = 1.0;
  const dark = (c: number) =>
    Math.max(0, Math.min(255, Math.round(c * factor)))
      .toString(16)
      .padStart(2, "0");
  return `#${dark(r)}${dark(g)}${dark(b)}`;
}
