"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { Menu, X, ArrowRight } from "lucide-react";

// Liens de la nav vitrine (mêmes que la nav desktop du SiteHeader).
const NAV = [
  { href: "/formations", label: "Formations" },
  { href: "/ecole", label: "L'école" },
  { href: "/financements", label: "Financements" },
  { href: "/tarifs", label: "Tarifs" },
  { href: "/temoignages", label: "Témoignages" },
  { href: "/contact", label: "Contact" },
];

/**
 * Menu de navigation mobile pour la vitrine (visible < md uniquement).
 * Le SiteHeader cache la nav desktop sous 768px : sans ce menu, les pages
 * Formations/Tarifs/Financements/Contact seraient inatteignables au doigt.
 *
 * Accessibilité : bouton aria-expanded + aria-controls, fermeture à Échap
 * et au clic sur l'overlay, scroll du body verrouillé à l'ouverture.
 * Motion : courbe ease-premium, neutralisée sous prefers-reduced-motion.
 */
export function SiteMobileMenu() {
  const [open, setOpen] = useState(false);

  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") setOpen(false);
    };
    window.addEventListener("keydown", onKey);
    const prevOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      window.removeEventListener("keydown", onKey);
      document.body.style.overflow = prevOverflow;
    };
  }, [open]);

  return (
    <div className="md:hidden">
      <button
        type="button"
        onClick={() => setOpen(true)}
        aria-label="Ouvrir le menu"
        aria-expanded={open}
        aria-controls="site-mobile-menu"
        className="inline-flex h-9 w-9 items-center justify-center rounded-lg text-white/80 transition-[transform,background-color,color] duration-200 ease-premium hover:bg-white/10 hover:text-white active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/50 motion-reduce:transition-none motion-reduce:active:scale-100"
      >
        <Menu className="h-5 w-5" />
      </button>

      {open && (
        <div id="site-mobile-menu" className="fixed inset-0 z-50" role="dialog" aria-modal="true" aria-label="Menu">
          {/* Overlay */}
          <div
            className="absolute inset-0 bg-night/80 backdrop-blur-sm motion-safe:animate-[fade-up_0.2s_ease-out]"
            onClick={() => setOpen(false)}
          />
          {/* Panneau */}
          <div className="absolute top-0 inset-x-0 bg-night border-b border-white/10 shadow-float px-6 pt-4 pb-6">
            <div className="flex items-center justify-end h-8">
              <button
                type="button"
                onClick={() => setOpen(false)}
                aria-label="Fermer le menu"
                className="inline-flex h-9 w-9 items-center justify-center rounded-lg text-white/80 transition-[transform,background-color,color] duration-200 ease-premium hover:bg-white/10 hover:text-white active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/50 motion-reduce:transition-none motion-reduce:active:scale-100"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <nav className="mt-2 flex flex-col">
              {NAV.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  onClick={() => setOpen(false)}
                  className="py-3 text-[17px] font-medium text-white/85 border-b border-white/5 transition-colors duration-200 hover:text-white focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/40 rounded"
                >
                  {item.label}
                </Link>
              ))}
            </nav>

            <div className="mt-5 flex flex-col gap-2.5">
              <Link
                href="/contact"
                onClick={() => setOpen(false)}
                className="inline-flex items-center justify-center gap-2 rounded-xl border border-white/15 px-4 py-3 text-sm font-semibold text-white/90 transition-[transform,background-color,border-color] duration-200 ease-premium hover:bg-white/10 hover:border-white/25 active:scale-[0.98] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/50 motion-reduce:transition-none"
              >
                Demander un devis
              </Link>
              <Link
                href="/login"
                onClick={() => setOpen(false)}
                className="group inline-flex items-center justify-center gap-1.5 rounded-xl bg-signal-500 text-night-900 px-4 py-3 text-sm font-semibold shadow-glow-signal transition-[transform,background-color] duration-200 ease-premium hover:bg-signal-400 active:scale-[0.98] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/70 focus-visible:ring-offset-2 focus-visible:ring-offset-night motion-reduce:transition-none"
              >
                Espace stagiaire
                <ArrowRight className="h-3.5 w-3.5 transition-transform duration-200 ease-premium group-hover:translate-x-0.5 motion-reduce:transition-none" />
              </Link>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
