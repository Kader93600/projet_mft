"use client";
import { useEffect, useRef, useState } from "react";
import { cn } from "@/lib/utils";

/**
 * Barre de progression animée. Démarre à 0 et fluidement remplit jusqu'à
 * `value` quand le composant entre dans le viewport (IntersectionObserver).
 *
 * Respecte `prefers-reduced-motion`.
 */
export function ProgressBar({
  value,
  className,
  variant = "navy",
}: {
  value: number;
  className?: string;
  variant?: "navy" | "gold" | "gradient";
}) {
  const v = Math.min(100, Math.max(0, value));
  const ref = useRef<HTMLDivElement | null>(null);
  const [animated, setAnimated] = useState(false);

  useEffect(() => {
    if (typeof window === "undefined") return;
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    if (reduce) {
      setAnimated(true);
      return;
    }
    const el = ref.current;
    if (!el) return;
    const io = new IntersectionObserver(
      (entries) => {
        for (const e of entries) {
          if (e.isIntersecting) {
            // Petit délai pour donner le sentiment de remplissage progressif
            window.setTimeout(() => setAnimated(true), 80);
            io.disconnect();
            break;
          }
        }
      },
      { threshold: 0.2 }
    );
    io.observe(el);
    return () => io.disconnect();
  }, []);

  const fill = {
    navy: "bg-navy-900",
    gold: "bg-gold-500",
    gradient: "bg-gradient-to-r from-navy-800 via-navy-600 to-gold-500",
  }[variant];

  return (
    <div
      ref={ref}
      className={cn(
        "w-full h-1.5 rounded-full bg-navy-100 dark:bg-[hsl(var(--border))] overflow-hidden",
        className
      )}
      role="progressbar"
      aria-valuenow={v}
      aria-valuemin={0}
      aria-valuemax={100}
    >
      <div
        className={cn(
          "h-full rounded-full",
          fill,
          // cubic-bezier "out-quart" pour une montée premium (rapide puis ralentit)
          "transition-[width] duration-[1100ms] ease-[cubic-bezier(0.22,1,0.36,1)]"
        )}
        style={{ width: animated ? `${v}%` : "0%" }}
      />
    </div>
  );
}

/**
 * Radial progress animé : même principe, démarre à 0 et remplit jusqu'à
 * `value` quand le composant entre dans le viewport. Le label numérique
 * compte de 0 → value en parallèle (count-up).
 */
export function RadialProgress({
  value,
  size = 96,
  strokeWidth = 8,
  label,
}: {
  value: number;
  size?: number;
  strokeWidth?: number;
  label?: React.ReactNode;
}) {
  const v = Math.min(100, Math.max(0, value));
  const radius = (size - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;

  const ref = useRef<HTMLDivElement | null>(null);
  const [animated, setAnimated] = useState(false);
  const [displayed, setDisplayed] = useState(0);

  useEffect(() => {
    if (typeof window === "undefined") return;
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    if (reduce) {
      setAnimated(true);
      setDisplayed(v);
      return;
    }
    const el = ref.current;
    if (!el) return;
    const io = new IntersectionObserver(
      (entries) => {
        for (const e of entries) {
          if (e.isIntersecting) {
            setAnimated(true);
            io.disconnect();
            break;
          }
        }
      },
      { threshold: 0.2 }
    );
    io.observe(el);
    return () => io.disconnect();
  }, [v]);

  // Count-up du label numérique
  useEffect(() => {
    if (!animated) return;
    if (typeof window === "undefined") return;
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    if (reduce) {
      setDisplayed(v);
      return;
    }
    let start: number | null = null;
    const dur = 1100;
    let raf = 0;
    const tick = (t: number) => {
      if (start === null) start = t;
      const p = Math.min(1, (t - start) / dur);
      // Ease out quart
      const eased = 1 - Math.pow(1 - p, 4);
      setDisplayed(Math.round(eased * v));
      if (p < 1) raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, [animated, v]);

  const offset = circumference - ((animated ? v : 0) / 100) * circumference;

  return (
    <div
      ref={ref}
      className="relative inline-flex items-center justify-center"
      role="progressbar"
      aria-valuenow={v}
      aria-valuemin={0}
      aria-valuemax={100}
    >
      <svg width={size} height={size} className="-rotate-90">
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          strokeWidth={strokeWidth}
          className="stroke-navy-100 fill-none"
        />
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          strokeWidth={strokeWidth}
          className="stroke-navy-900 fill-none"
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={offset}
          style={{
            transition:
              "stroke-dashoffset 1100ms cubic-bezier(0.22, 1, 0.36, 1)",
          }}
        />
      </svg>
      <div className="absolute inset-0 flex items-center justify-center">
        {label ?? (
          <span className="font-display text-xl font-semibold text-navy-900 tabular-nums">
            {displayed}%
          </span>
        )}
      </div>
    </div>
  );
}
