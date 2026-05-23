"use client";

import { useEffect, useRef } from "react";

/**
 * Confettis légers sur un seul <canvas> (GPU, pas de DOM massif, ~1 rAF).
 * One-shot : se nettoie tout seul après `durationMs`. Contenu dans son parent
 * positionné (absolute inset-0). À ne monter QUE si le mouvement est autorisé
 * (le parent gère prefers-reduced-motion).
 */
export function ConfettiBurst({
  count = 80,
  colors,
  durationMs = 2600,
  originY = 0.4,
}: {
  count?: number;
  colors?: string[];
  durationMs?: number;
  originY?: number;
}) {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    const parent = canvas?.parentElement;
    if (!canvas || !parent) return;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    let W = 0;
    let H = 0;
    function resize() {
      const r = parent!.getBoundingClientRect();
      W = r.width;
      H = r.height;
      canvas!.width = W * dpr;
      canvas!.height = H * dpr;
      canvas!.style.width = `${W}px`;
      canvas!.style.height = `${H}px`;
      ctx!.setTransform(dpr, 0, 0, dpr, 0, 0);
    }
    resize();

    const palette =
      colors && colors.length ? colors : ["#9FE220", "#2530D9", "#a16207", "#10b981"];

    type P = {
      x: number;
      y: number;
      vx: number;
      vy: number;
      size: number;
      rot: number;
      vr: number;
      color: string;
      rect: boolean;
      life: number;
    };

    const spawn = (): P => {
      const angle = -Math.PI / 2 + (Math.random() - 0.5) * 1.7;
      const speed = 4.5 + Math.random() * 7.5;
      return {
        x: W / 2 + (Math.random() - 0.5) * W * 0.32,
        y: H * originY,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed - 2,
        size: 5 + Math.random() * 5,
        rot: Math.random() * Math.PI,
        vr: (Math.random() - 0.5) * 0.32,
        color: palette[(Math.random() * palette.length) | 0],
        rect: Math.random() < 0.55,
        life: 1,
      };
    };

    const parts: P[] = Array.from({ length: count }, spawn);
    const gravity = 0.17;
    const drag = 0.992;
    let raf = 0;
    const start = performance.now();

    function frame(now: number) {
      const t = now - start;
      ctx!.clearRect(0, 0, W, H);
      const fadeFrom = durationMs * 0.55;
      for (const p of parts) {
        p.vy += gravity;
        p.vx *= drag;
        p.vy *= drag;
        p.x += p.vx;
        p.y += p.vy;
        p.rot += p.vr;
        if (t > fadeFrom)
          p.life = Math.max(0, 1 - (t - fadeFrom) / (durationMs - fadeFrom));
        ctx!.globalAlpha = p.life;
        ctx!.save();
        ctx!.translate(p.x, p.y);
        ctx!.rotate(p.rot);
        ctx!.fillStyle = p.color;
        if (p.rect) ctx!.fillRect(-p.size / 2, -p.size / 2, p.size, p.size * 0.62);
        else {
          ctx!.beginPath();
          ctx!.arc(0, 0, p.size / 2, 0, Math.PI * 2);
          ctx!.fill();
        }
        ctx!.restore();
      }
      ctx!.globalAlpha = 1;
      if (t < durationMs) raf = requestAnimationFrame(frame);
    }
    raf = requestAnimationFrame(frame);
    window.addEventListener("resize", resize);
    return () => {
      cancelAnimationFrame(raf);
      window.removeEventListener("resize", resize);
    };
  }, [count, colors, durationMs, originY]);

  return (
    <canvas
      ref={canvasRef}
      aria-hidden
      className="pointer-events-none absolute inset-0 z-10"
    />
  );
}
