"use client";

import { useEffect, useRef, useState, type ReactNode } from "react";

/**
 * Animation Apple-style : reveal au scroll.
 *
 * Quand l'élément entre dans le viewport :
 *  - opacity 0 → 1
 *  - translateY 24px → 0
 *  - Légère scale (0.985 → 1) pour effet "soft pop"
 *
 * Easing : cubic-bezier(0.22, 1, 0.36, 1) (ease-out-expo, conforme
 * DESIGN.md). Durée 700ms.
 *
 * `delay` pour stagger les éléments d'une liste.
 *
 * Désactivé si `prefers-reduced-motion: reduce` → l'élément apparaît
 * directement sans animation.
 *
 * Performance : un seul IntersectionObserver par instance, déconnecté
 * une fois la cible visible (ne gaspille pas de CPU).
 */
export function ScrollReveal({
  children,
  delay = 0,
  className = "",
}: {
  children: ReactNode;
  /** Délai en ms avant de démarrer l'animation (utile pour stagger). */
  delay?: number;
  className?: string;
}) {
  const ref = useRef<HTMLDivElement | null>(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    if (
      typeof window !== "undefined" &&
      window.matchMedia("(prefers-reduced-motion: reduce)").matches
    ) {
      setVisible(true);
      return;
    }

    const obs = new IntersectionObserver(
      (entries) => {
        for (const e of entries) {
          if (e.isIntersecting) {
            setVisible(true);
            obs.disconnect();
            break;
          }
        }
      },
      {
        rootMargin: "0px 0px -10% 0px",
        threshold: 0.05,
      }
    );

    obs.observe(el);
    return () => obs.disconnect();
  }, []);

  const style: React.CSSProperties = {
    opacity: visible ? 1 : 0,
    transform: visible ? "translateY(0) scale(1)" : "translateY(24px) scale(0.985)",
    transition:
      "opacity 700ms cubic-bezier(0.22, 1, 0.36, 1), transform 700ms cubic-bezier(0.22, 1, 0.36, 1)",
    transitionDelay: visible && delay > 0 ? `${delay}ms` : "0ms",
    willChange: visible ? "auto" : "opacity, transform",
  };

  return (
    <div ref={ref} className={className} style={style}>
      {children}
    </div>
  );
}
