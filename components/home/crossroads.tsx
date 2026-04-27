"use client";
import * as React from "react";
import { useRouter } from "next/navigation";
import { FORMATIONS } from "@/lib/formations-config";

/**
 * Hero "Carrefour" — 8 routes qui rayonnent depuis un point central
 * (le stagiaire) vers les 8 formations. SVG vectoriel + perspective
 * CSS 3D pour rendu immersif sans Three.js.
 *
 * Astuces perfs :
 *  - Tout en SVG (un seul nœud) → < 8 Ko
 *  - Animations CSS GPU only (transform/opacity) → 60fps
 *  - prefers-reduced-motion respecté
 */
export function Crossroads() {
  // 8 routes équiréparties autour d'un cercle, mais on les garde
  // dans un demi-supérieur pour ressembler à un horizon en perspective.
  const formations = FORMATIONS.slice(0, 8);
  const radius = 230;
  const centerX = 320;
  const centerY = 320;
  // angles entre -160° et -20° (en haut, en éventail)
  const startDeg = -170;
  const endDeg = -10;
  const step = (endDeg - startDeg) / (formations.length - 1);

  const router = useRouter();
  const [hoverIdx, setHoverIdx] = React.useState<number | null>(null);

  return (
    <div
      className="relative w-full max-w-3xl mx-auto select-none"
      style={{ aspectRatio: "1 / 0.78" }}
    >
      {/* Gradient lumineux derrière */}
      <div
        aria-hidden="true"
        className="absolute inset-0 pointer-events-none"
        style={{
          background:
            "radial-gradient(ellipse at 50% 80%, rgba(159,226,32,0.18) 0%, rgba(37,48,217,0.10) 35%, transparent 70%)",
          filter: "blur(20px)",
        }}
      />

      <svg
        viewBox="0 0 640 500"
        className="relative z-10 w-full h-full"
        aria-label="Carrefour des formations MA FORMATION TRANSPORT"
      >
        <defs>
          {/* Gradient pour les routes (point central → bord) */}
          <radialGradient id="roadGrad" cx="50%" cy="100%" r="100%">
            <stop offset="0%" stopColor="#9FE220" stopOpacity="1" />
            <stop offset="60%" stopColor="#3845E5" stopOpacity="0.6" />
            <stop offset="100%" stopColor="#0E1240" stopOpacity="0.1" />
          </radialGradient>

          {/* Glow pour le hub central */}
          <radialGradient id="hubGlow" cx="50%" cy="50%" r="50%">
            <stop offset="0%" stopColor="#9FE220" stopOpacity="0.9" />
            <stop offset="60%" stopColor="#3845E5" stopOpacity="0.4" />
            <stop offset="100%" stopColor="#0E1240" stopOpacity="0" />
          </radialGradient>

          {/* Halo carte de fond */}
          <linearGradient id="floorGrad" x1="0" x2="0" y1="0" y2="1">
            <stop offset="0%" stopColor="#0E1240" stopOpacity="0" />
            <stop offset="100%" stopColor="#0E1240" stopOpacity="0.6" />
          </linearGradient>

          {/* Filtre glow réutilisable */}
          <filter id="glow">
            <feGaussianBlur stdDeviation="3" result="blur" />
            <feMerge>
              <feMergeNode in="blur" />
              <feMergeNode in="SourceGraphic" />
            </feMerge>
          </filter>
        </defs>

        {/* Sol perspective : grille en demi-cercle */}
        <g
          aria-hidden="true"
          style={{
            transform: "perspective(900px) rotateX(64deg) translateY(60px)",
            transformOrigin: "320px 360px",
            transformBox: "fill-box",
          }}
        >
          {/* Cercles concentriques */}
          {[60, 120, 180, 240, 300].map((r, i) => (
            <circle
              key={r}
              cx={centerX}
              cy={centerY}
              r={r}
              fill="none"
              stroke="rgba(255,255,255,0.06)"
              strokeWidth="0.6"
              style={{
                animation: `spin-slow ${30 + i * 4}s linear infinite ${i % 2 ? "" : "reverse"}`,
                transformOrigin: `${centerX}px ${centerY}px`,
              }}
            />
          ))}
          {/* Halo sol */}
          <ellipse
            cx={centerX}
            cy={centerY}
            rx="320"
            ry="120"
            fill="url(#floorGrad)"
          />
        </g>

        {/* Routes — 8 rayons */}
        {formations.map((f, i) => {
          const angleDeg = startDeg + step * i;
          const angle = (angleDeg * Math.PI) / 180;
          const endX = centerX + radius * Math.cos(angle);
          const endY = centerY + radius * Math.sin(angle);
          const isHover = hoverIdx === i;
          const accent = f.accent ?? "#9FE220";

          // largeur de la route à l'arrivée (dégrade vers le bord)
          const widthFar = isHover ? 14 : 10;

          // Le path : trapèze allant du centre (point) vers (endX, endY) avec largeur croissante
          const perp = angle + Math.PI / 2;
          const halfWFar = widthFar / 2;
          const x1 = endX + halfWFar * Math.cos(perp);
          const y1 = endY + halfWFar * Math.sin(perp);
          const x2 = endX - halfWFar * Math.cos(perp);
          const y2 = endY - halfWFar * Math.sin(perp);

          const onActivate = () => router.push(`/formations/${f.slug}`);
          return (
            <g
              key={f.slug}
              role="link"
              tabIndex={0}
              aria-label={f.title}
              onMouseEnter={() => setHoverIdx(i)}
              onMouseLeave={() => setHoverIdx(null)}
              onFocus={() => setHoverIdx(i)}
              onBlur={() => setHoverIdx(null)}
              onClick={onActivate}
              onKeyDown={(e) => {
                if (e.key === "Enter" || e.key === " ") {
                  e.preventDefault();
                  onActivate();
                }
              }}
              style={{ cursor: "pointer", outline: "none" }}
            >
                  {/* Route trapézoïdale (apparition en cascade) */}
                  <path
                    d={`M ${centerX} ${centerY} L ${x1} ${y1} L ${x2} ${y2} Z`}
                    fill={isHover ? accent : "url(#roadGrad)"}
                    opacity={isHover ? 0.95 : 0.55}
                    style={{
                      transition: "fill 0.3s, opacity 0.3s",
                      filter: isHover
                        ? "drop-shadow(0 0 10px rgba(159,226,32,0.45))"
                        : undefined,
                      animation: `fade-up 0.6s ease-out ${0.15 + i * 0.08}s backwards`,
                      transformOrigin: `${centerX}px ${centerY}px`,
                    }}
                  />
                  {/* Ligne médiane animée */}
                  <line
                    x1={centerX}
                    y1={centerY}
                    x2={endX}
                    y2={endY}
                    stroke="rgba(255,255,255,0.55)"
                    strokeWidth={1.4}
                    strokeDasharray="6 8"
                    strokeLinecap="round"
                    style={{
                      animation: `road-pulse ${2 + (i % 3) * 0.5}s ease-in-out infinite`,
                    }}
                  />

                  {/* Carte/badge au bout de la route */}
                  <g transform={`translate(${endX} ${endY})`}>
                    <FormationBadge
                      code={f.code}
                      accent={accent}
                      isActive={isHover}
                      side={endX > centerX ? "right" : "left"}
                      yOffset={endY < 250 ? -10 : 10}
                    />
                  </g>
            </g>
          );
        })}

        {/* Hub central — toque universitaire stylisée */}
        <g transform={`translate(${centerX} ${centerY})`} filter="url(#glow)">
          {/* Lueur */}
          <circle r="36" fill="url(#hubGlow)" />
          {/* Pictogramme toque */}
          <g style={{ animation: "float-slow 6s ease-in-out infinite" }}>
            <path
              d="M0 -16 L 22 -7 L 0 2 L -22 -7 Z"
              fill="#FFFFFF"
            />
            <line
              x1="18"
              y1="-7"
              x2="18"
              y2="6"
              stroke="#FFFFFF"
              strokeWidth="1.6"
              strokeLinecap="round"
            />
            <circle cx="18" cy="8" r="1.8" fill="#9FE220" />
            <circle r="6" fill="#9FE220" cy="2" />
          </g>
          {/* Texte */}
          <text
            y="34"
            textAnchor="middle"
            fill="#FFFFFF"
            fontSize="10"
            fontWeight="600"
            style={{ letterSpacing: "0.18em", textTransform: "uppercase" }}
            opacity="0.7"
          >
            Vous
          </text>
        </g>
      </svg>

      {/* Annotation du parcours mis en surbrillance */}
      {hoverIdx !== null && (
        <div
          className="absolute left-1/2 -translate-x-1/2 bottom-0 px-4 py-2 rounded-xl bg-night-100/90 backdrop-blur border border-white/10 text-white text-sm shadow-glow-brand"
          aria-live="polite"
        >
          <div className="text-[10px] font-semibold uppercase tracking-[0.18em] text-signal-400">
            {formations[hoverIdx].code}
          </div>
          <div className="font-medium">{formations[hoverIdx].title}</div>
        </div>
      )}
    </div>
  );
}

function FormationBadge({
  code,
  accent,
  isActive,
  side,
  yOffset,
}: {
  code: string;
  accent: string;
  isActive: boolean;
  side: "left" | "right";
  yOffset: number;
}) {
  const dx = side === "left" ? -10 : 10;
  const align = side === "left" ? "end" : "start";
  // Approximation de la largeur du texte pour dessiner un fond
  const w = code.length * 7.5 + 14;
  const h = 20;
  const rectX = side === "left" ? -w - 6 : 6;

  return (
    <g
      transform={`translate(${dx} ${yOffset})`}
      style={{
        transition: "transform 0.3s",
        transform: isActive
          ? `translate(${dx + (side === "left" ? -4 : 4)}px, ${yOffset - 2}px)`
          : undefined,
      }}
    >
      <rect
        x={rectX}
        y={-h / 2}
        rx={h / 2}
        ry={h / 2}
        width={w}
        height={h}
        fill={isActive ? accent : "rgba(15, 18, 64, 0.85)"}
        stroke={isActive ? accent : "rgba(255,255,255,0.18)"}
        strokeWidth="1"
        style={{
          transition: "fill 0.3s, stroke 0.3s",
          filter: isActive
            ? `drop-shadow(0 0 10px ${accent}aa)`
            : undefined,
        }}
      />
      <text
        x={side === "left" ? -10 : 10}
        y="3.5"
        textAnchor={align}
        fill={isActive ? "#0E1240" : "#FFFFFF"}
        fontSize="10"
        fontWeight="700"
        style={{ letterSpacing: "0.04em" }}
      >
        {code}
      </text>
    </g>
  );
}
