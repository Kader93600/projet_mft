"use client";

import { useEffect, useRef, useState } from "react";

/**
 * Hook : anime un nombre depuis sa valeur précédente vers sa valeur cible.
 * Utile pour les prix qui changent (sélection de formation), les KPIs au
 * scroll, etc.
 *
 * - Respecte `prefers-reduced-motion`: renvoie directement la valeur cible.
 * - Easing : cubic-bezier(0.22, 1, 0.36, 1) — premium ease-out de DESIGN.md.
 * - Durée par défaut 500 ms.
 *
 * @example
 *   const displayed = useCountUp(priceCents);
 *   <span>{fmtEuros(displayed)}</span>
 */
export function useCountUp(target: number, durationMs = 500): number {
  const [value, setValue] = useState(target);
  const fromRef = useRef(target);
  const rafRef = useRef<number | null>(null);
  const reducedRef = useRef(false);

  useEffect(() => {
    if (typeof window !== "undefined") {
      const mq = window.matchMedia("(prefers-reduced-motion: reduce)");
      reducedRef.current = mq.matches;
    }
  }, []);

  useEffect(() => {
    if (reducedRef.current) {
      setValue(target);
      fromRef.current = target;
      return;
    }
    const from = fromRef.current;
    if (from === target) return;

    const start = performance.now();
    const ease = (t: number) => {
      // cubic-bezier(0.22, 1, 0.36, 1) approximée pour t in [0,1]
      // équivalent quart-out qui donne le même feel premium
      return 1 - Math.pow(1 - t, 4);
    };

    const step = (now: number) => {
      const elapsed = now - start;
      const t = Math.min(1, elapsed / durationMs);
      const v = from + (target - from) * ease(t);
      setValue(v);
      if (t < 1) {
        rafRef.current = requestAnimationFrame(step);
      } else {
        setValue(target);
        fromRef.current = target;
      }
    };
    rafRef.current = requestAnimationFrame(step);

    return () => {
      if (rafRef.current != null) cancelAnimationFrame(rafRef.current);
    };
  }, [target, durationMs]);

  return value;
}
