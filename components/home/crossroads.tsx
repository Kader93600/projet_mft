"use client";
import * as React from "react";
import { useRouter } from "next/navigation";
import { FORMATIONS } from "@/lib/formations-config";

/**
 * Constellation atomique — le hub central pulse, 3 orbites contre-rotatives
 * portent des électrons qui parcourent réellement leur trajectoire (SMIL
 * animateMotion + mpath), et 8 nœuds-formations sont placés en cercle
 * autour du noyau.
 *
 * Lecture du visuel :
 *  - Noyau = la toque (l'apprenant) avec halo signal pulsant
 *  - 3 orbites elliptiques (rotation 25° / 85° / 145°) → effet d'atome 3D
 *  - 5 électrons qui glissent le long de chaque orbite (offsets répartis)
 *  - 8 nœuds-formations sur un cercle r=240 ; ligne pointillée vers le hub
 *  - Starfield léger (12 points qui scintillent)
 *
 * Interactions :
 *  - Hover/focus sur un nœud → halo accent, ligne illuminée, tagline
 *    flottante. Click/Enter/Espace → navigation vers /formations/{slug}.
 *
 * Perfs :
 *  - Tout SVG, animations CSS/SMIL GPU
 *  - prefers-reduced-motion : orbites figées, scintillement coupé
 *  - Aucun JS de boucle (RAF) — uniquement state React pour l'hover
 */
export function Crossroads() {
  const formations = FORMATIONS.slice(0, 8);
  const cx = 400;
  const cy = 300;
  const ringR = 240;

  // 8 nœuds répartis autour d'un cercle, départ vers le haut-gauche
  // pour aérer la zone du label "Hub" sous le noyau.
  const nodes = formations.map((f, i) => {
    const a = (i / formations.length) * Math.PI * 2 - Math.PI / 2;
    return {
      ...f,
      x: cx + ringR * Math.cos(a),
      y: cy + ringR * Math.sin(a),
      angle: a,
      side: Math.cos(a) >= 0 ? ("right" as const) : ("left" as const),
      verticalSide: Math.sin(a) < -0.2 ? "top" : Math.sin(a) > 0.2 ? "bottom" : "mid",
    };
  });

  // 3 orbites : (rotation, rx, ry, durée d'un tour, sens)
  const orbits = [
    { rot: 25, rx: 300, ry: 100, dur: 18, dir: 1 },
    { rot: 85, rx: 280, ry: 90, dur: 22, dir: -1 },
    { rot: 145, rx: 320, ry: 110, dur: 26, dir: 1 },
  ];

  // Starfield (positions stables — déterministes)
  const stars = React.useMemo(() => {
    const pts: { x: number; y: number; r: number; d: number }[] = [];
    let seed = 1337;
    const rand = () => {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      return seed / 0x7fffffff;
    };
    for (let i = 0; i < 28; i++) {
      pts.push({
        x: 30 + rand() * 740,
        y: 30 + rand() * 540,
        r: 0.6 + rand() * 1.1,
        d: 2 + rand() * 4,
      });
    }
    return pts;
  }, []);

  const router = useRouter();
  const [hoverIdx, setHoverIdx] = React.useState<number | null>(null);

  return (
    <div
      className="relative w-full max-w-3xl mx-auto select-none"
      style={{ aspectRatio: "4 / 3" }}
    >
      {/* Halo de fond (sous le SVG) */}
      <div
        aria-hidden
        className="absolute inset-0 pointer-events-none"
        style={{
          background:
            "radial-gradient(ellipse 60% 55% at 50% 52%, rgba(159,226,32,0.18) 0%, rgba(56,69,229,0.14) 38%, transparent 72%)",
          filter: "blur(28px)",
        }}
      />

      <svg
        viewBox="0 0 800 600"
        className="relative z-10 w-full h-full"
        aria-label="Constellation atomique des formations"
        preserveAspectRatio="xMidYMid meet"
      >
        <defs>
          {/* Halo nucléaire vert signal → bleu profond */}
          <radialGradient id="ca-core" cx="50%" cy="50%" r="50%">
            <stop offset="0%" stopColor="#C7FF6B" stopOpacity="1" />
            <stop offset="35%" stopColor="#9FE220" stopOpacity="0.85" />
            <stop offset="70%" stopColor="#3845E5" stopOpacity="0.35" />
            <stop offset="100%" stopColor="#0E1240" stopOpacity="0" />
          </radialGradient>

          {/* Glow des électrons (filtre réutilisable) */}
          <filter id="ca-glow" x="-100%" y="-100%" width="300%" height="300%">
            <feGaussianBlur stdDeviation="2.4" result="b" />
            <feMerge>
              <feMergeNode in="b" />
              <feMergeNode in="SourceGraphic" />
            </feMerge>
          </filter>

          <filter id="ca-glow-strong" x="-100%" y="-100%" width="300%" height="300%">
            <feGaussianBlur stdDeviation="5" result="b" />
            <feMerge>
              <feMergeNode in="b" />
              <feMergeNode in="SourceGraphic" />
            </feMerge>
          </filter>

          {/* Trois trajectoires elliptiques — utilisées par mpath */}
          {orbits.map((o, i) => (
            <path
              key={i}
              id={`ca-orbit-${i}`}
              d={`M ${cx + o.rx},${cy} A ${o.rx},${o.ry} 0 1,${
                o.dir === 1 ? 1 : 0
              } ${cx - o.rx},${cy} A ${o.rx},${o.ry} 0 1,${
                o.dir === 1 ? 1 : 0
              } ${cx + o.rx},${cy}`}
              fill="none"
            />
          ))}
        </defs>

        {/* ─── Starfield ───────────────────────────────────────────────── */}
        <g aria-hidden className="motion-reduce:[&_animate]:hidden">
          {stars.map((s, i) => (
            <circle
              key={i}
              cx={s.x}
              cy={s.y}
              r={s.r}
              fill="#FFFFFF"
              opacity="0.35"
            >
              <animate
                attributeName="opacity"
                values="0.15;0.6;0.15"
                dur={`${s.d}s`}
                begin={`${(i % 5) * 0.6}s`}
                repeatCount="indefinite"
              />
            </circle>
          ))}
        </g>

        {/* ─── Orbites + électrons ─────────────────────────────────────── */}
        {orbits.map((o, i) => (
          <g
            key={i}
            transform={`rotate(${o.rot} ${cx} ${cy})`}
            opacity="0.9"
          >
            {/* Trace de l'orbite (faible) */}
            <ellipse
              cx={cx}
              cy={cy}
              rx={o.rx}
              ry={o.ry}
              fill="none"
              stroke={
                i === 0
                  ? "rgba(159,226,32,0.18)"
                  : "rgba(199,219,255,0.10)"
              }
              strokeWidth={i === 0 ? 0.8 : 0.6}
              strokeDasharray={i === 0 ? "0" : "1.5 4"}
            />

            {/* Électrons : 2 par orbite, déphasés */}
            <circle
              r="3.2"
              fill={i === 0 ? "#C7FF6B" : i === 1 ? "#7B8AFF" : "#9FE220"}
              filter="url(#ca-glow)"
              className="motion-reduce:hidden"
            >
              <animateMotion
                dur={`${o.dur}s`}
                repeatCount="indefinite"
                rotate="auto"
              >
                <mpath href={`#ca-orbit-${i}`} />
              </animateMotion>
            </circle>
            <circle
              r="2.2"
              fill={i === 0 ? "#9FE220" : i === 1 ? "#5C6AF2" : "#C7FF6B"}
              filter="url(#ca-glow)"
              className="motion-reduce:hidden"
              opacity="0.85"
            >
              <animateMotion
                dur={`${o.dur}s`}
                repeatCount="indefinite"
                rotate="auto"
                begin={`${o.dur / 2}s`}
              >
                <mpath href={`#ca-orbit-${i}`} />
              </animateMotion>
            </circle>
          </g>
        ))}

        {/* ─── 8 lignes pointillées hub → nœuds (sous les nœuds) ────────── */}
        {nodes.map((n, i) => {
          const isActive = hoverIdx === i;
          const accent = n.accent ?? "#9FE220";
          return (
            <line
              key={n.slug}
              x1={cx}
              y1={cy}
              x2={n.x}
              y2={n.y}
              stroke={isActive ? accent : "rgba(255,255,255,0.12)"}
              strokeWidth={isActive ? 1.2 : 0.7}
              strokeDasharray={isActive ? "0" : "2 5"}
              opacity={isActive ? 0.9 : 0.55}
              style={{
                transition: "stroke 0.35s ease-out, stroke-width 0.35s ease-out, opacity 0.35s ease-out",
                filter: isActive ? `drop-shadow(0 0 4px ${accent})` : undefined,
              }}
            />
          );
        })}

        {/* ─── Noyau / hub ─────────────────────────────────────────────── */}
        <g transform={`translate(${cx} ${cy})`}>
          {/* Halo radial pulsant */}
          <circle
            r="84"
            fill="url(#ca-core)"
            className="motion-reduce:hidden"
          >
            <animate
              attributeName="r"
              values="74;94;74"
              dur="3.6s"
              repeatCount="indefinite"
            />
            <animate
              attributeName="opacity"
              values="0.55;0.95;0.55"
              dur="3.6s"
              repeatCount="indefinite"
            />
          </circle>

          {/* Anneau interne */}
          <circle
            r="48"
            fill="none"
            stroke="rgba(199,255,107,0.55)"
            strokeWidth="0.6"
            strokeDasharray="2 3"
            className="motion-reduce:hidden"
            style={{
              animation: "spin-slow 22s linear infinite",
              transformOrigin: `${cx}px ${cy}px`,
              transformBox: "fill-box",
            }}
          />

          {/* Disque noyau */}
          <circle r="34" fill="#0E1240" stroke="rgba(255,255,255,0.18)" strokeWidth="1" />
          <circle r="34" fill="url(#ca-core)" opacity="0.55" />

          {/* Pictogramme toque */}
          <g
            filter="url(#ca-glow-strong)"
            className="motion-reduce:[&_*]:[animation:none]"
            style={{ animation: "float-y 5.4s ease-in-out infinite" }}
          >
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

          <text
            y="56"
            textAnchor="middle"
            fill="#FFFFFF"
            fontSize="10"
            fontWeight="700"
            style={{ letterSpacing: "0.22em", textTransform: "uppercase" }}
            opacity="0.85"
          >
            Vous
          </text>
        </g>

        {/* ─── Nœuds-formations (au-dessus de tout) ────────────────────── */}
        {nodes.map((n, i) => {
          const isActive = hoverIdx === i;
          const accent = n.accent ?? "#9FE220";

          // Décale le label vers l'extérieur (radial)
          const labelOffset = 18;
          const lx = n.x + Math.cos(n.angle) * labelOffset;
          const ly = n.y + Math.sin(n.angle) * labelOffset;

          // Largeur approx du pill
          const w = n.code.length * 7.5 + 18;
          const h = 22;
          const rectX = n.side === "left" ? -w - 8 : 8;
          const textX = n.side === "left" ? -12 : 12;
          const textAnchor = n.side === "left" ? "end" : "start";

          const onActivate = () => router.push(`/formations/${n.slug}`);

          return (
            <g
              key={n.slug}
              role="link"
              tabIndex={0}
              aria-label={n.title}
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
              style={{
                cursor: "pointer",
                outline: "none",
                animation: `fade-up 0.6s cubic-bezier(0.22, 1, 0.36, 1) ${
                  0.2 + i * 0.06
                }s both`,
              }}
              className="motion-reduce:[animation:none]"
            >
              {/* Halo accent au hover */}
              <circle
                cx={n.x}
                cy={n.y}
                r={isActive ? 22 : 0}
                fill={accent}
                opacity={isActive ? 0.18 : 0}
                style={{
                  transition: "r 0.35s ease-out, opacity 0.35s ease-out",
                }}
              />

              {/* Anneau extérieur du nœud */}
              <circle
                cx={n.x}
                cy={n.y}
                r={isActive ? 11 : 8}
                fill="rgba(15, 18, 64, 0.92)"
                stroke={accent}
                strokeWidth={isActive ? 2 : 1.2}
                style={{
                  transition: "r 0.3s ease-out, stroke-width 0.3s ease-out",
                  filter: isActive ? `drop-shadow(0 0 8px ${accent})` : undefined,
                }}
              />

              {/* Cœur du nœud */}
              <circle
                cx={n.x}
                cy={n.y}
                r={isActive ? 5 : 3.5}
                fill={accent}
                style={{
                  transition: "r 0.3s ease-out",
                }}
              />

              {/* Pulse animé sur le nœud actif */}
              {isActive && (
                <circle
                  cx={n.x}
                  cy={n.y}
                  r="11"
                  fill="none"
                  stroke={accent}
                  strokeWidth="1"
                  className="motion-reduce:hidden"
                >
                  <animate
                    attributeName="r"
                    values="11;26"
                    dur="1.4s"
                    repeatCount="indefinite"
                  />
                  <animate
                    attributeName="opacity"
                    values="0.7;0"
                    dur="1.4s"
                    repeatCount="indefinite"
                  />
                </circle>
              )}

              {/* Pill code formation */}
              <g transform={`translate(${lx} ${ly})`}>
                <rect
                  x={rectX}
                  y={-h / 2}
                  rx={h / 2}
                  ry={h / 2}
                  width={w}
                  height={h}
                  fill={isActive ? accent : "rgba(15, 18, 64, 0.92)"}
                  stroke={isActive ? accent : "rgba(255,255,255,0.18)"}
                  strokeWidth="1"
                  style={{
                    transition: "fill 0.3s, stroke 0.3s",
                    filter: isActive
                      ? `drop-shadow(0 0 12px ${accent}cc)`
                      : "drop-shadow(0 4px 10px rgba(0,0,0,0.35))",
                  }}
                />
                <text
                  x={textX}
                  y="4"
                  textAnchor={textAnchor}
                  fill={isActive ? "#0E1240" : "#FFFFFF"}
                  fontSize="11"
                  fontWeight="700"
                  style={{
                    letterSpacing: "0.06em",
                    transition: "fill 0.3s",
                  }}
                >
                  {n.code}
                </text>
              </g>
            </g>
          );
        })}
      </svg>

      {/* ─── Tagline flottante (au-dessus du SVG) ──────────────────────── */}
      <div
        className={
          "pointer-events-none absolute left-1/2 -translate-x-1/2 bottom-3 " +
          "px-4 py-2.5 rounded-2xl bg-night-100/95 backdrop-blur " +
          "border border-white/10 text-white max-w-sm text-center " +
          "transition-[opacity,transform] duration-300 ease-out"
        }
        style={{
          opacity: hoverIdx !== null ? 1 : 0,
          transform:
            hoverIdx !== null
              ? "translate(-50%, 0)"
              : "translate(-50%, 6px)",
          boxShadow:
            hoverIdx !== null
              ? `0 18px 40px -10px ${
                  formations[hoverIdx]?.accent ?? "#9FE220"
                }55`
              : undefined,
        }}
        aria-live="polite"
      >
        {hoverIdx !== null && (
          <>
            <div
              className="text-[10px] font-bold uppercase tracking-[0.2em]"
              style={{ color: formations[hoverIdx].accent ?? "#9FE220" }}
            >
              {formations[hoverIdx].code} · {formations[hoverIdx].duration}
            </div>
            <div className="font-display text-[13px] font-semibold leading-tight mt-0.5">
              {formations[hoverIdx].title}
            </div>
            <div className="text-[11px] text-white/65 mt-1 leading-snug">
              {formations[hoverIdx].tagline}
            </div>
          </>
        )}
      </div>
    </div>
  );
}
