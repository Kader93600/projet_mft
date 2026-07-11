"use client";

import { useEffect, useState } from "react";

/**
 * Fine barre de progression de lecture en haut de page (articles/guides).
 * Détail éditorial discret : indique l'avancement dans la lecture longue.
 *
 * Perf (règles Emil) : animée via `transform: scaleX` uniquement (GPU, pas
 * de layout/paint), lecture du scroll throttlée par requestAnimationFrame,
 * listener passif. Aucune librairie. Purement décorative → aria-hidden.
 */
export function ReadingProgress() {
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    let raf = 0;
    const update = () => {
      const el = document.documentElement;
      const scrollable = el.scrollHeight - el.clientHeight;
      const p = scrollable > 0 ? el.scrollTop / scrollable : 0;
      setProgress(Math.min(1, Math.max(0, p)));
      raf = 0;
    };
    const onScroll = () => {
      if (!raf) raf = requestAnimationFrame(update);
    };
    window.addEventListener("scroll", onScroll, { passive: true });
    update();
    return () => {
      window.removeEventListener("scroll", onScroll);
      if (raf) cancelAnimationFrame(raf);
    };
  }, []);

  return (
    <div
      className="fixed inset-x-0 top-0 z-40 h-[3px] bg-transparent"
      aria-hidden
    >
      <div
        className="h-full origin-left bg-signal-500 transition-transform duration-100 ease-out will-change-transform"
        style={{ transform: `scaleX(${progress})` }}
      />
    </div>
  );
}
