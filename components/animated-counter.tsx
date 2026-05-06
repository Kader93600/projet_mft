"use client";

import { useEffect, useRef, useState } from "react";

/**
 * Compteur animé qui s'incrémente de 0 → value quand l'élément entre
 * dans le viewport. Easing ease-out-expo pour un finish doux.
 *
 * Respecte prefers-reduced-motion : affiche directement la valeur finale.
 *
 * Usage :
 *   <AnimatedCounter value={87} duration={1200} suffix="%" />
 *   <AnimatedCounter value={142} prefix="" suffix=" tentatives" />
 */
export function AnimatedCounter({
  value,
  duration = 900,
  prefix = "",
  suffix = "",
  decimals = 0,
  className = "",
}: {
  value: number;
  duration?: number;
  prefix?: string;
  suffix?: string;
  decimals?: number;
  className?: string;
}) {
  const [display, setDisplay] = useState(0);
  const ref = useRef<HTMLSpanElement | null>(null);
  const startedRef = useRef(false);

  useEffect(() => {
    if (
      typeof window !== "undefined" &&
      window.matchMedia("(prefers-reduced-motion: reduce)").matches
    ) {
      setDisplay(value);
      startedRef.current = true;
      return;
    }

    const el = ref.current;
    if (!el) return;

    const obs = new IntersectionObserver(
      (entries) => {
        for (const e of entries) {
          if (e.isIntersecting && !startedRef.current) {
            startedRef.current = true;
            const start = performance.now();
            const from = 0;
            const to = value;
            // ease-out-expo (DESIGN.md)
            const ease = (t: number) =>
              t === 1 ? 1 : 1 - Math.pow(2, -10 * t);

            const tick = (now: number) => {
              const elapsed = now - start;
              const t = Math.min(1, elapsed / duration);
              const v = from + (to - from) * ease(t);
              setDisplay(v);
              if (t < 1) requestAnimationFrame(tick);
              else setDisplay(to);
            };
            requestAnimationFrame(tick);
            obs.disconnect();
            break;
          }
        }
      },
      { threshold: 0.2 }
    );
    obs.observe(el);
    return () => obs.disconnect();
  }, [value, duration]);

  return (
    <span ref={ref} className={className}>
      {prefix}
      {display.toFixed(decimals)}
      {suffix}
    </span>
  );
}
