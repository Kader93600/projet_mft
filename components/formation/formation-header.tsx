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
import { findFormation } from "@/lib/formations-config";
import { accentVars } from "@/lib/formation-accent";
import { FormationStripe } from "./formation-stripe";

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

/**
 * En-tête de page coloré dynamiquement selon la formation.
 *
 * Combine :
 *   - Stripe couleur formation en haut
 *   - Halo radial de l'accent
 *   - Icône formation + code dans l'eyebrow
 *   - Titre + description
 *
 * @example
 * <FormationHeader
 *   slug="capacite-3-5t"
 *   eyebrow="Examen blanc"
 *   title="Examen blanc n°3"
 *   description="40 QCM + 5 QR · Durée 1h30"
 * />
 */
export function FormationHeader({
  slug,
  eyebrow,
  title,
  description,
  rightAction,
}: {
  slug?: string | null;
  eyebrow: string;
  title: React.ReactNode;
  description?: React.ReactNode;
  rightAction?: React.ReactNode;
}) {
  const f = slug ? findFormation(slug) : null;
  const accent = f?.accent ?? "#9FE220";
  const Icon = f ? ICONS[f.iconName] ?? Truck : null;

  return (
    <div className="relative">
      {/* Stripe couleur formation */}
      <FormationStripe slug={slug} />

      <div className="relative pt-6 pb-2">
        {/* Halo subtil de l'accent */}
        <div
          aria-hidden="true"
          className="absolute -top-4 -right-8 h-40 w-40 rounded-full opacity-10 blur-3xl pointer-events-none"
          style={{ backgroundColor: accent }}
        />

        <div className="relative flex items-start justify-between gap-4 flex-wrap">
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 mb-2">
              {Icon && (
                <span
                  className="h-7 w-7 rounded-lg flex items-center justify-center shrink-0 border formation-accent"
                  style={accentVars(accent)}
                >
                  {/* L'icône hérite de `currentColor` posé par `formation-accent`. */}
                  <Icon className="h-4 w-4" />
                </span>
              )}
              <span
                className="text-[10px] font-bold uppercase tracking-[0.18em] formation-accent-text"
                style={accentVars(accent)}
              >
                {f ? `${f.code} · ${eyebrow}` : eyebrow}
              </span>
            </div>
            <h1 className="font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
              {title}
            </h1>
            {description && (
              <p className="mt-2 text-slate-600 max-w-2xl">{description}</p>
            )}
          </div>
          {rightAction && (
            <div className="shrink-0">{rightAction}</div>
          )}
        </div>
      </div>
    </div>
  );
}
