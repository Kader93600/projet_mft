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
import { accentVars } from "@/lib/formation-accent";

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
   * L'accent est émis en VARIABLES CSS (jeu clair + jeu sombre), jamais en
   * color/background direct : un style inline ne peut pas être surchargé par
   * une règle `.dark`. C'est donc le CSS qui choisit le jeu selon le thème
   * (cf. lib/formation-accent.ts et `.formation-accent` dans globals.css).
   *
   * Sans ça, les accents déjà foncés (ex. #2530D9 pour « Capacité > 3,5 t »)
   * restaient en bleu profond sur fond navy : 2,07:1, illisible.
   */
  const style = accentVars(accent, variant);
  const cls = [
    "formation-accent",
    "inline-flex items-center font-semibold uppercase tracking-wider rounded-lg border",
    SIZES[size],
  ].join(" ");

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
