import Link from "next/link";
import { ChevronRight, Home } from "lucide-react";
import { findFormation } from "@/lib/formations-config";
import { FormationBadge } from "./formation-badge";

interface Crumb {
  label: string;
  href?: string;
}

/**
 * Breadcrumb intelligent qui met la formation en évidence visuellement.
 *
 * @example
 * <FormationBreadcrumb
 *   formationSlug="capacite-3-5t"
 *   trail={[
 *     { label: "Examens blancs", href: "/quiz" },
 *     { label: "Examen blanc n°3" },
 *   ]}
 * />
 */
export function FormationBreadcrumb({
  formationSlug,
  trail,
  rootHref = "/dashboard",
  rootLabel = "Accueil",
}: {
  formationSlug?: string | null;
  trail: Crumb[];
  rootHref?: string;
  rootLabel?: string;
}) {
  const f = formationSlug ? findFormation(formationSlug) : null;

  return (
    <nav
      aria-label="Fil d'Ariane"
      className="flex items-center gap-1.5 text-sm text-slate-600 flex-wrap"
    >
      <Link
        href={rootHref}
        className="inline-flex items-center gap-1 hover:text-navy-900"
      >
        <Home className="h-3.5 w-3.5" />
        <span className="sr-only md:not-sr-only">{rootLabel}</span>
      </Link>

      {f && (
        <>
          <ChevronRight className="h-3.5 w-3.5 text-slate-300" />
          <FormationBadge slug={f.slug} size="sm" icon />
        </>
      )}

      {trail.map((c, i) => (
        <span key={i} className="inline-flex items-center gap-1.5">
          <ChevronRight className="h-3.5 w-3.5 text-slate-300" />
          {c.href ? (
            <Link href={c.href} className="hover:text-navy-900">
              {c.label}
            </Link>
          ) : (
            <span className="text-navy-900 font-medium">{c.label}</span>
          )}
        </span>
      ))}
    </nav>
  );
}
