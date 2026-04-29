// =====================================================================
// Composants réutilisables pour identifier visuellement la formation
// d'un contenu (quiz, module, examen blanc, copie…).
//
// Utilise les couleurs et icônes définies dans lib/formations-config.ts.
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

type Size = "xs" | "sm" | "md" | "lg";
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
  sm: "px-2 py-0.5 text-[11px] gap-1.5",
  md: "px-2.5 py-1 text-xs gap-1.5",
  lg: "px-3 py-1.5 text-sm gap-2",
};

const ICON_SIZES: Record<Size, string> = {
  xs: "h-2.5 w-2.5",
  sm: "h-3 w-3",
  md: "h-3.5 w-3.5",
  lg: "h-4 w-4",
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

  let style: React.CSSProperties = {};
  let cls = "inline-flex items-center font-semibold uppercase tracking-wider rounded-md border ";
  cls += SIZES[size];

  switch (variant) {
    case "solid":
      style = { backgroundColor: accent, color: "#0E1240", borderColor: accent };
      break;
    case "outline":
      style = { color: accent, borderColor: `${accent}80`, backgroundColor: "transparent" };
      break;
    case "soft":
      style = { backgroundColor: `${accent}15`, color: accent, borderColor: "transparent" };
      break;
    case "chip":
    default:
      style = {
        backgroundColor: `${accent}22`,
        color: accent,
        borderColor: `${accent}55`,
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
        <span className="font-normal normal-case opacity-90 ml-1 truncate">
          — {f.title}
        </span>
      )}
    </span>
  );
}
