"use client";

import { useEffect, useRef, useState } from "react";

interface ScrollRevealProps {
  children: React.ReactNode;
  /** Delay before animation starts, in ms. */
  delay?: number;
  /** Distance to travel up in px. Default 24. */
  distance?: number;
  /** Animation duration in ms. Default 700. */
  duration?: number;
  /** Threshold to trigger (0-1). Default 0.1 (10% visible). */
  threshold?: number;
  /** Don't re-trigger once revealed (default true). */
  once?: boolean;
  /** Custom className for the wrapper. */
  className?: string;
  /** Use display:contents to avoid creating an extra DOM box. Default false. */
  asFragment?: boolean;
}

/**
 * Reveal children when scrolled into view.
 *
 * - Uses IntersectionObserver (no JS animation library).
 * - Respects `prefers-reduced-motion`: skips animation entirely.
 * - Curve: cubic-bezier(0.22, 1, 0.36, 1) per DESIGN.md (premium ease-out).
 *
 * Usage:
 *   <ScrollReveal delay={100}>...</ScrollReveal>
 */
export function ScrollReveal({
  children,
  delay = 0,
  distance = 24,
  duration = 700,
  threshold = 0.1,
  once = true,
  className,
  asFragment = false,
}: ScrollRevealProps) {
  const ref = useRef<HTMLDivElement>(null);
  const [visible, setVisible] = useState(false);
  const [reduced, setReduced] = useState(false);

  useEffect(() => {
    if (typeof window === "undefined") return;
    const mq = window.matchMedia("(prefers-reduced-motion: reduce)");
    setReduced(mq.matches);
    const handler = () => setReduced(mq.matches);
    mq.addEventListener("change", handler);
    return () => mq.removeEventListener("change", handler);
  }, []);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    if (reduced) {
      setVisible(true);
      return;
    }
    const obs = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            setVisible(true);
            if (once) obs.disconnect();
          } else if (!once) {
            setVisible(false);
          }
        }
      },
      { threshold, rootMargin: "0px 0px -10% 0px" }
    );
    obs.observe(el);
    return () => obs.disconnect();
  }, [reduced, once, threshold]);

  const style: React.CSSProperties = reduced
    ? {}
    : {
        opacity: visible ? 1 : 0,
        transform: visible ? "translateY(0)" : `translateY(${distance}px)`,
        transition: `opacity ${duration}ms cubic-bezier(0.22, 1, 0.36, 1) ${delay}ms, transform ${duration}ms cubic-bezier(0.22, 1, 0.36, 1) ${delay}ms`,
        willChange: visible ? "auto" : "opacity, transform",
      };

  return (
    <div ref={ref} className={className} style={style}>
      {children}
    </div>
  );
}
