import { findFormation } from "@/lib/formations-config";

/**
 * Bandeau coloré horizontal de 4px en haut d'une page.
 * Sert de signal visuel immédiat pour identifier la formation
 * sans avoir besoin de lire un badge.
 *
 * @example
 * <FormationStripe slug="capacite-3-5t" />
 */
export function FormationStripe({
  slug,
  height = 4,
  className,
}: {
  slug?: string | null;
  height?: number;
  className?: string;
}) {
  const f = slug ? findFormation(slug) : null;
  if (!f) return null;
  return (
    <div
      className={"w-full " + (className ?? "")}
      style={{
        height: `${height}px`,
        background: `linear-gradient(90deg, ${f.accent}, ${f.accent}80)`,
      }}
      aria-hidden="true"
    />
  );
}
