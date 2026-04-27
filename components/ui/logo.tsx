import { cn } from "@/lib/utils";

/**
 * Logo MA FORMATION TRANSPORT — reproduction SVG du logo officiel.
 * Cercle bleu + route en perspective vert lime + toque universitaire bleue.
 *
 * variant="dark"  → marque bleue sur fond clair
 * variant="light" → marque blanche sur fond sombre (dégradé subtil)
 */
export function Logo({
  className,
  variant = "dark",
  withText = true,
  size = "md",
}: {
  className?: string;
  variant?: "dark" | "light";
  withText?: boolean;
  size?: "sm" | "md" | "lg";
}) {
  const markSize =
    size === "sm" ? "h-8 w-8" : size === "lg" ? "h-12 w-12" : "h-10 w-10";
  const isLight = variant === "light";
  const titleColor = isLight ? "text-white" : "text-brand-700";
  const subColor = isLight ? "text-signal-400" : "text-signal-600";
  const labelSize =
    size === "sm" ? "text-[14px]" : size === "lg" ? "text-[19px]" : "text-[16px]";

  return (
    <span
      className={cn(
        "inline-flex items-center gap-2.5",
        className
      )}
      aria-label="MA FORMATION TRANSPORT"
    >
      <LogoMark className={markSize} variant={variant} />
      {withText && (
        <span className="flex flex-col leading-none">
          <span
            className={cn(
              "font-sans font-bold tracking-tight",
              labelSize,
              titleColor
            )}
          >
            MA FORMATION
          </span>
          <span
            className={cn(
              "font-sans font-extrabold tracking-tight mt-0.5",
              labelSize,
              subColor
            )}
          >
            TRANSPORT
          </span>
        </span>
      )}
    </span>
  );
}

/** Le pictogramme seul (cercle bleu + route + toque). */
export function LogoMark({
  className,
  variant = "dark",
}: {
  className?: string;
  variant?: "dark" | "light";
}) {
  const ringColor = variant === "light" ? "#FFFFFF" : "#2530D9";
  const tassel = variant === "light" ? "#FFFFFF" : "#2530D9";
  const cap = variant === "light" ? "#FFFFFF" : "#2530D9";
  const road = "#9FE220"; // toujours signal vert

  return (
    <svg
      viewBox="0 0 64 64"
      className={className}
      aria-hidden="true"
    >
      {/* Cercle */}
      <circle
        cx="32"
        cy="36"
        r="22"
        fill="none"
        stroke={ringColor}
        strokeWidth="3.5"
      />
      {/* Route en perspective : trapèze inversé avec lignes médianes */}
      <g>
        <path
          d="M22 56 L42 56 L36 22 L28 22 Z"
          fill={road}
        />
        {/* Bandes blanches centrales */}
        <rect x="31.2" y="26" width="1.6" height="4" fill="#FFFFFF" rx="0.4" />
        <rect x="31.1" y="33" width="1.8" height="5" fill="#FFFFFF" rx="0.4" />
        <rect x="30.9" y="42" width="2.2" height="6" fill="#FFFFFF" rx="0.5" />
        <rect x="30.6" y="51" width="2.8" height="4" fill="#FFFFFF" rx="0.6" />
      </g>
      {/* Toque universitaire */}
      <g>
        {/* Plateau (losange) */}
        <path
          d="M32 6 L52 14 L32 22 L12 14 Z"
          fill={cap}
        />
        {/* Pompon */}
        <circle cx="48" cy="14" r="1.6" fill={tassel} />
        <line
          x1="48"
          y1="14"
          x2="48"
          y2="22"
          stroke={tassel}
          strokeWidth="1.4"
          strokeLinecap="round"
        />
        <circle cx="48" cy="22.5" r="1.4" fill={tassel} />
      </g>
    </svg>
  );
}
