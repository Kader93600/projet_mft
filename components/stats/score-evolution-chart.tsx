"use client";
import { useEffect, useMemo, useRef, useState } from "react";

interface Attempt {
  finished_at: string | null;
  percentage: number;
}

/**
 * Courbe d'évolution du score moyen (rolling 7 jours) sur les 30 derniers jours.
 * SVG pur, animé au scroll-in via IntersectionObserver.
 *
 * - Trait `signal` qui se dessine de gauche à droite (stroke-dashoffset)
 * - Aire en gradient brand→signal avec fade-in
 * - Points de données qui apparaissent un à un
 * - Tooltip au hover affichant la date + valeur
 */
export function ScoreEvolutionChart({
  attempts,
  passThreshold = 70,
}: {
  attempts: Attempt[];
  passThreshold?: number;
}) {
  const ref = useRef<SVGSVGElement | null>(null);
  const [animated, setAnimated] = useState(false);
  const [hover, setHover] = useState<{ x: number; y: number; v: number; date: string } | null>(null);

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
  }, []);

  // Préparer les 30 derniers jours
  const series = useMemo(() => {
    const days = 30;
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const result: { date: Date; avg: number | null }[] = [];

    for (let i = days - 1; i >= 0; i--) {
      const d = new Date(today);
      d.setDate(d.getDate() - i);
      // Rolling 7 jours autour de ce jour
      const windowStart = +d - 6 * 86400000;
      const windowEnd = +d + 86400000;
      const inWindow = attempts.filter((a) => {
        if (!a.finished_at) return false;
        const t = +new Date(a.finished_at);
        return t >= windowStart && t < windowEnd;
      });
      if (inWindow.length === 0) {
        result.push({ date: d, avg: null });
      } else {
        const avg =
          inWindow.reduce((s, a) => s + a.percentage, 0) / inWindow.length;
        result.push({ date: d, avg: Math.round(avg) });
      }
    }
    return result;
  }, [attempts]);

  const W = 600;
  const H = 200;
  const padX = 32;
  const padY = 18;
  const innerW = W - padX * 2;
  const innerH = H - padY * 2;

  // Si pas assez de données : empty state
  const hasData = series.some((s) => s.avg !== null);

  // Coordonnées des points (pour les jours avec données)
  const points = series.map((s, i) => {
    const x = padX + (innerW * i) / (series.length - 1 || 1);
    const v = s.avg ?? 0;
    const y = padY + innerH - (innerH * v) / 100;
    return { x, y, v, date: s.date, hasData: s.avg !== null };
  });

  // Path : on lie uniquement les points avec données
  const pathPts = points.filter((p) => p.hasData);
  const pathD = pathPts
    .map((p, i) => `${i === 0 ? "M" : "L"}${p.x.toFixed(1)},${p.y.toFixed(1)}`)
    .join(" ");

  // Aire fermée
  const areaD = pathPts.length
    ? `${pathD} L${pathPts[pathPts.length - 1].x.toFixed(1)},${(padY + innerH).toFixed(1)} L${pathPts[0].x.toFixed(1)},${(padY + innerH).toFixed(1)} Z`
    : "";

  // Approximation longueur du path pour stroke-dashoffset
  const pathLength = pathPts.reduce((acc, p, i) => {
    if (i === 0) return 0;
    const prev = pathPts[i - 1];
    return acc + Math.hypot(p.x - prev.x, p.y - prev.y);
  }, 0);

  if (!hasData) {
    return (
      <div className="rounded-xl border border-navy-100 bg-navy-50/30 p-8 text-center text-sm text-slate-500">
        Pas encore assez de données — vos prochains quiz alimenteront cette courbe.
      </div>
    );
  }

  const fmt = (d: Date) =>
    d.toLocaleDateString("fr-FR", { day: "2-digit", month: "short" });

  return (
    <div className="relative">
      <svg
        ref={ref}
        viewBox={`0 0 ${W} ${H}`}
        className="w-full h-auto select-none"
        role="img"
        aria-label="Évolution du score moyen sur 30 jours"
      >
        <defs>
          <linearGradient id="score-area" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor="rgba(159,226,32,0.35)" />
            <stop offset="100%" stopColor="rgba(159,226,32,0.02)" />
          </linearGradient>
          <linearGradient id="score-stroke" x1="0" y1="0" x2="1" y2="0">
            <stop offset="0%" stopColor="#2530D9" />
            <stop offset="100%" stopColor="#9FE220" />
          </linearGradient>
        </defs>

        {/* Grid horizontale 0/50/100 */}
        {[0, 50, 100].map((y) => {
          const yPos = padY + innerH - (innerH * y) / 100;
          return (
            <g key={y}>
              <line
                x1={padX}
                x2={W - padX}
                y1={yPos}
                y2={yPos}
                stroke="rgba(14,18,64,0.08)"
                strokeDasharray={y === 0 ? undefined : "2 4"}
              />
              <text
                x={padX - 6}
                y={yPos + 3}
                textAnchor="end"
                fontSize="9"
                fill="rgba(100,116,139,0.7)"
                fontFamily="var(--font-jetbrains)"
              >
                {y}
              </text>
            </g>
          );
        })}

        {/* Ligne du seuil */}
        <line
          x1={padX}
          x2={W - padX}
          y1={padY + innerH - (innerH * passThreshold) / 100}
          y2={padY + innerH - (innerH * passThreshold) / 100}
          stroke="rgba(245,158,11,0.5)"
          strokeWidth="0.7"
          strokeDasharray="3 3"
        />
        <text
          x={W - padX - 4}
          y={padY + innerH - (innerH * passThreshold) / 100 - 4}
          textAnchor="end"
          fontSize="9"
          fill="rgba(180,83,9,0.85)"
          fontWeight="600"
        >
          Seuil {passThreshold}%
        </text>

        {/* Aire */}
        {areaD && (
          <path
            d={areaD}
            fill="url(#score-area)"
            opacity={animated ? 1 : 0}
            style={{
              transition: "opacity 0.6s ease-out 0.6s",
            }}
          />
        )}

        {/* Trait principal — animation draw */}
        {pathD && (
          <path
            d={pathD}
            fill="none"
            stroke="url(#score-stroke)"
            strokeWidth="2.2"
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeDasharray={pathLength}
            strokeDashoffset={animated ? 0 : pathLength}
            style={{
              transition:
                "stroke-dashoffset 1400ms cubic-bezier(0.22, 1, 0.36, 1)",
            }}
          />
        )}

        {/* Points + zones de hover */}
        {pathPts.map((p, i) => (
          <g
            key={i}
            onMouseEnter={() =>
              setHover({ x: p.x, y: p.y, v: p.v, date: fmt(p.date) })
            }
            onMouseLeave={() => setHover(null)}
            style={{ cursor: "pointer" }}
          >
            <circle
              cx={p.x}
              cy={p.y}
              r="3.5"
              fill="white"
              stroke="#2530D9"
              strokeWidth="1.6"
              opacity={animated ? 1 : 0}
              style={{
                transition: `opacity 0.3s ease-out ${
                  900 + i * 30
                }ms, r 0.2s ease-out`,
              }}
            />
            {/* Zone de hover invisible plus grande */}
            <circle cx={p.x} cy={p.y} r="14" fill="transparent" />
          </g>
        ))}

        {/* Tooltip */}
        {hover && (
          <g pointerEvents="none">
            <rect
              x={Math.min(hover.x - 28, W - 60)}
              y={hover.y - 32}
              width="56"
              height="22"
              rx="6"
              fill="#0E1240"
            />
            <text
              x={Math.min(hover.x, W - 32) - 28 + 28}
              y={hover.y - 18}
              textAnchor="middle"
              fontSize="10"
              fill="white"
              fontWeight="600"
              fontFamily="var(--font-jetbrains)"
            >
              {hover.v}%
            </text>
            <text
              x={Math.min(hover.x, W - 32) - 28 + 28}
              y={hover.y - 7}
              textAnchor="middle"
              fontSize="8"
              fill="rgba(255,255,255,0.6)"
            >
              {hover.date}
            </text>
          </g>
        )}

        {/* Labels axe X — 4 dates équiréparties */}
        {[0, Math.floor(series.length / 3), Math.floor((2 * series.length) / 3), series.length - 1].map(
          (i) => {
            const p = points[i];
            return (
              <text
                key={i}
                x={p.x}
                y={H - 4}
                textAnchor="middle"
                fontSize="9"
                fill="rgba(100,116,139,0.8)"
                fontFamily="var(--font-inter)"
              >
                {fmt(p.date)}
              </text>
            );
          }
        )}
      </svg>
    </div>
  );
}
