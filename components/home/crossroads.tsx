"use client";
import * as React from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { FORMATIONS } from "@/lib/formations-config";
import {
  Truck,
  Bus,
  GraduationCap,
  Car,
  Briefcase,
  Package,
  Award,
  ShieldCheck,
  ArrowRight,
  X,
} from "lucide-react";

const ICONS: Record<string, any> = {
  Truck,
  Bus,
  GraduationCap,
  Car,
  Briefcase,
  Package,
  Award,
  ShieldCheck,
};

/**
 * Constellation atomique — 8 formations qui orbitent réellement autour
 * du noyau central (toque + halo signal).
 *
 * Mécanique :
 *  - Chaque formation est un nœud HTML positionné au centre, monté dans
 *    un "rotor" qui tourne via CSS @keyframes (transform: rotate).
 *  - Un offset radial (translateY −R) place le nœud sur l'orbite.
 *  - Une contre-rotation (rotate inverse, même durée) garde le pill droit.
 *  - Au hover/focus/tap : `data-paused` fige uniquement ce nœud, dim les
 *    autres et ouvre une CARD premium centrée par-dessus le hub.
 *
 *  - Container queries (cqi) → rayon d'orbite responsive sans JS.
 *  - SVG décoratif uniquement (orbites + électrons + starfield).
 *  - prefers-reduced-motion : orbites figées, scintillement coupé.
 */
export function Crossroads() {
  const formations = FORMATIONS.slice(0, 8);
  const router = useRouter();
  const [activeIdx, setActiveIdx] = React.useState<number | null>(null);

  // Période d'une révolution complète. Une rotation lente reste lisible.
  const PERIOD = 90;

  // Decoratif : starfield positions stables (déterministe pour SSR)
  const stars = React.useMemo(() => {
    const pts: { x: number; y: number; r: number; d: number; b: number }[] = [];
    let seed = 24601;
    const rand = () => {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      return seed / 0x7fffffff;
    };
    for (let i = 0; i < 32; i++) {
      pts.push({
        x: 30 + rand() * 740,
        y: 30 + rand() * 540,
        r: 0.5 + rand() * 1.2,
        d: 2.4 + rand() * 4,
        b: rand() * 4,
      });
    }
    return pts;
  }, []);

  const active = activeIdx !== null ? formations[activeIdx] : null;
  const ActiveIcon = active ? ICONS[active.iconName] ?? Truck : null;

  const close = () => setActiveIdx(null);

  return (
    <div
      className="relative w-full max-w-3xl mx-auto select-none"
      style={
        {
          aspectRatio: "4 / 3",
          containerType: "size",
          // Rayon d'orbite en unités container-query : 36% de la dimension la plus petite
          ["--orbit-r" as any]: "min(34cqi, 34cqb)",
        } as React.CSSProperties
      }
      onPointerLeave={() => setActiveIdx(null)}
    >
      {/* Décor SVG : starfield + orbites + électrons */}
      <svg
        viewBox="0 0 800 600"
        className="absolute inset-0 w-full h-full pointer-events-none"
        preserveAspectRatio="xMidYMid meet"
        aria-hidden
      >
        <defs>
          <radialGradient id="cr-core" cx="50%" cy="50%" r="50%">
            <stop offset="0%" stopColor="#C7FF6B" stopOpacity="1" />
            <stop offset="35%" stopColor="#9FE220" stopOpacity="0.85" />
            <stop offset="70%" stopColor="#3845E5" stopOpacity="0.32" />
            <stop offset="100%" stopColor="#0E1240" stopOpacity="0" />
          </radialGradient>
          <filter id="cr-glow" x="-100%" y="-100%" width="300%" height="300%">
            <feGaussianBlur stdDeviation="2.4" />
          </filter>
          <path
            id="cr-orbit-a"
            d="M 700,300 A 300,100 25 1,1 100,300 A 300,100 25 1,1 700,300"
            fill="none"
          />
          <path
            id="cr-orbit-b"
            d="M 690,300 A 290,90 -35 1,0 110,300 A 290,90 -35 1,0 690,300"
            fill="none"
          />
        </defs>

        {/* Starfield (animation SMIL : scintillement aléatoire) */}
        <g>
          {stars.map((s, i) => (
            <circle
              key={i}
              cx={s.x}
              cy={s.y}
              r={s.r}
              fill="#FFFFFF"
              opacity="0.35"
              className="motion-reduce:[&>animate]:hidden"
            >
              <animate
                attributeName="opacity"
                values="0.15;0.7;0.15"
                dur={`${s.d}s`}
                begin={`${s.b}s`}
                repeatCount="indefinite"
              />
            </circle>
          ))}
        </g>

        {/* Orbites décoratives */}
        <g
          transform="rotate(25 400 300)"
          style={{ opacity: activeIdx !== null ? 0.4 : 1, transition: "opacity 0.4s" }}
        >
          <use href="#cr-orbit-a" stroke="rgba(159,226,32,0.18)" strokeWidth="0.8" />
          {/* Électrons sur orbite A */}
          <circle r="3.4" fill="#C7FF6B" filter="url(#cr-glow)" className="motion-reduce:hidden">
            <animateMotion dur="18s" repeatCount="indefinite">
              <mpath href="#cr-orbit-a" />
            </animateMotion>
          </circle>
          <circle r="2.4" fill="#9FE220" filter="url(#cr-glow)" opacity="0.85" className="motion-reduce:hidden">
            <animateMotion dur="18s" repeatCount="indefinite" begin="9s">
              <mpath href="#cr-orbit-a" />
            </animateMotion>
          </circle>
        </g>

        <g
          transform="rotate(-35 400 300)"
          style={{ opacity: activeIdx !== null ? 0.35 : 0.85, transition: "opacity 0.4s" }}
        >
          <use href="#cr-orbit-b" stroke="rgba(199,219,255,0.12)" strokeWidth="0.6" strokeDasharray="1.5 4" />
          <circle r="2.6" fill="#7B8AFF" filter="url(#cr-glow)" className="motion-reduce:hidden">
            <animateMotion dur="22s" repeatCount="indefinite">
              <mpath href="#cr-orbit-b" />
            </animateMotion>
          </circle>
        </g>
      </svg>

      {/* Hub central (caché quand une formation est active) */}
      <div
        className={
          "absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 z-10 " +
          "transition-[opacity,transform,filter] duration-500 " +
          (activeIdx !== null
            ? "opacity-30 scale-90 blur-[2px]"
            : "opacity-100 scale-100")
        }
      >
        <div className="relative w-[clamp(112px,22cqi,160px)] aspect-square">
          {/* Halo pulsant */}
          <div
            aria-hidden
            className="absolute -inset-6 rounded-full motion-reduce:hidden"
            style={{
              background:
                "radial-gradient(circle, rgba(159,226,32,0.42) 0%, rgba(56,69,229,0.18) 45%, transparent 75%)",
              animation: "glow-pulse 3.6s ease-in-out infinite",
            }}
          />
          {/* Anneau */}
          <div
            aria-hidden
            className="absolute inset-0 rounded-full border border-signal-400/35 motion-reduce:hidden"
            style={{ animation: "spin-slow 24s linear infinite" }}
          />
          {/* Disque + toque */}
          <div className="absolute inset-2 rounded-full bg-night-100 border border-white/15 grid place-items-center shadow-glow-signal">
            <GraduationCap className="w-1/2 h-1/2 text-white drop-shadow-[0_0_8px_rgba(159,226,32,0.7)]" />
          </div>
          {/* Label "Vous" */}
          <div className="absolute -bottom-7 left-1/2 -translate-x-1/2 text-[10px] font-bold uppercase tracking-[0.22em] text-white/85 whitespace-nowrap">
            Vous
          </div>
        </div>
      </div>

      {/* 8 formations qui orbitent ─────────────────────────────────────── */}
      {formations.map((f, i) => {
        const isActive = activeIdx === i;
        const accent = f.accent ?? "#9FE220";
        // Décalage initial : chaque nœud démarre à un angle différent (i*45°)
        // grâce au animationDelay négatif (i × period/8).
        const delay = -(i * (PERIOD / 8));

        return (
          <div
            key={f.slug}
            className={
              "cr-rotor absolute inset-0 grid place-items-center pointer-events-none " +
              "motion-reduce:!animate-none"
            }
            data-paused={isActive ? "true" : "false"}
            style={
              {
                animation: `cr-spin ${PERIOD}s linear infinite`,
                animationDelay: `${delay}s`,
                animationPlayState: isActive ? "paused" : "running",
                opacity: activeIdx !== null && !isActive ? 0.2 : 1,
                transition: "opacity 0.4s ease-out",
              } as React.CSSProperties
            }
          >
            {/* Bras radial — translate vers l'orbite */}
            <div
              className="absolute"
              style={{
                transform: "translateY(calc(-1 * var(--orbit-r)))",
              }}
            >
              {/* Contre-rotation pour garder le pill droit */}
              <div
                className="cr-counter motion-reduce:!animate-none pointer-events-auto"
                style={{
                  animation: `cr-spin-reverse ${PERIOD}s linear infinite`,
                  animationDelay: `${delay}s`,
                  animationPlayState: isActive ? "paused" : "running",
                }}
              >
                <FormationOrb
                  formation={f}
                  accent={accent}
                  isActive={isActive}
                  isDimmed={activeIdx !== null && !isActive}
                  onActivate={() => setActiveIdx(i)}
                />
              </div>
            </div>
          </div>
        );
      })}

      {/* CARD premium centrée — apparaît au hover/tap ─────────────────── */}
      <div
        className={
          "absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 z-30 " +
          "w-[min(420px,86%)] " +
          "transition-[opacity,transform] duration-300 ease-[cubic-bezier(0.16,1,0.3,1)]"
        }
        style={{
          opacity: active ? 1 : 0,
          transform: active
            ? "translate(-50%, -50%) scale(1)"
            : "translate(-50%, -50%) scale(0.94)",
          pointerEvents: active ? "auto" : "none",
        }}
        role="dialog"
        aria-modal="false"
        aria-hidden={!active}
      >
        {active && ActiveIcon && (
          <div
            className="relative rounded-2xl border bg-night-100/95 backdrop-blur-xl p-5 shadow-2xl"
            style={{
              borderColor: `${active.accent ?? "#9FE220"}55`,
              boxShadow: `0 30px 70px -10px ${active.accent ?? "#9FE220"}66, inset 0 0 0 1px ${
                active.accent ?? "#9FE220"
              }22`,
            }}
            onPointerEnter={() => setActiveIdx(activeIdx)}
          >
            {/* Halo accent dans le coin */}
            <div
              aria-hidden
              className="absolute -top-12 -right-12 h-32 w-32 rounded-full pointer-events-none"
              style={{
                background: `radial-gradient(circle, ${active.accent ?? "#9FE220"}55 0%, transparent 70%)`,
              }}
            />

            {/* Bouton fermer (utile sur mobile / touch) */}
            <button
              type="button"
              onClick={close}
              aria-label="Fermer"
              className="absolute top-2.5 right-2.5 h-7 w-7 rounded-full bg-white/5 hover:bg-white/15 text-white/60 hover:text-white grid place-items-center transition-colors"
            >
              <X className="h-3.5 w-3.5" />
            </button>

            {/* Header : icône + code + durée */}
            <div className="flex items-center gap-3 pr-6">
              <div
                className="h-12 w-12 rounded-2xl grid place-items-center shrink-0"
                style={{
                  background: `${active.accent ?? "#9FE220"}1F`,
                  border: `1px solid ${active.accent ?? "#9FE220"}66`,
                  color: active.accent ?? "#9FE220",
                  boxShadow: `0 0 24px ${active.accent ?? "#9FE220"}44`,
                }}
              >
                <ActiveIcon className="h-6 w-6" />
              </div>
              <div className="min-w-0">
                <div
                  className="text-[11px] font-bold uppercase tracking-[0.18em]"
                  style={{ color: active.accent ?? "#9FE220" }}
                >
                  {active.code}
                </div>
                <div className="text-[11px] text-white/55 truncate">
                  {active.duration} · {active.modality === "distanciel" ? "100 % en ligne" : active.modality}
                </div>
              </div>
            </div>

            {/* Titre */}
            <h3 className="mt-4 font-display text-lg font-semibold text-white leading-snug">
              {active.title}
            </h3>

            {/* Tagline */}
            <p className="mt-2 text-[13px] text-white/70 leading-relaxed">
              {active.tagline}
            </p>

            {/* CTA */}
            <div className="mt-5 flex items-center gap-3">
              <Link
                href={`/formations/${active.slug}`}
                className="inline-flex items-center gap-2 rounded-xl px-4 py-2.5 text-sm font-semibold text-night-900 transition-transform hover:scale-[1.02]"
                style={{
                  background: active.accent ?? "#9FE220",
                  boxShadow: `0 8px 24px -4px ${active.accent ?? "#9FE220"}88`,
                }}
              >
                Découvrir la formation
                <ArrowRight className="h-4 w-4" />
              </Link>
              <button
                type="button"
                onClick={close}
                className="text-[12px] text-white/55 hover:text-white/85 transition-colors"
              >
                Continuer l'orbite
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Animations CSS injectées (clés rotor / contre-rotor) */}
      <style jsx>{`
        @keyframes cr-spin {
          to {
            transform: rotate(360deg);
          }
        }
        @keyframes cr-spin-reverse {
          to {
            transform: rotate(-360deg);
          }
        }
        .cr-rotor {
          will-change: transform;
        }
        .cr-counter {
          will-change: transform;
        }
        @media (prefers-reduced-motion: reduce) {
          .cr-rotor,
          .cr-counter {
            animation: none !important;
          }
        }
      `}</style>
    </div>
  );
}

/* ───────────────────────────────────────────────────────────────────────
 * Pill formation — affichage compact orbital
 * ─────────────────────────────────────────────────────────────────────── */
function FormationOrb({
  formation,
  accent,
  isActive,
  isDimmed,
  onActivate,
}: {
  formation: (typeof FORMATIONS)[number];
  accent: string;
  isActive: boolean;
  isDimmed: boolean;
  onActivate: () => void;
}) {
  const Icon = ICONS[formation.iconName] ?? Truck;
  return (
    <button
      type="button"
      onPointerEnter={onActivate}
      onFocus={onActivate}
      onClick={onActivate}
      aria-label={formation.title}
      className={
        "group relative inline-flex items-center gap-2 rounded-full pl-1 pr-3.5 py-1 " +
        "border bg-night-100/95 backdrop-blur-md shadow-[0_8px_24px_-8px_rgba(0,0,0,0.55)] " +
        "transition-[transform,box-shadow,border-color,background] duration-300 " +
        "focus:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-offset-night-100 " +
        (isActive
          ? "scale-[1.12]"
          : isDimmed
          ? "scale-[0.92]"
          : "hover:scale-[1.06]")
      }
      style={{
        borderColor: isActive ? accent : "rgba(255,255,255,0.16)",
        boxShadow: isActive
          ? `0 12px 36px -6px ${accent}99, 0 0 0 2px ${accent}88`
          : undefined,
      }}
    >
      {/* Pastille icône */}
      <span
        className="grid place-items-center h-7 w-7 rounded-full shrink-0 transition-colors"
        style={{
          background: isActive ? accent : `${accent}22`,
          color: isActive ? "#0E1240" : accent,
          border: `1px solid ${accent}88`,
        }}
      >
        <Icon className="h-3.5 w-3.5" />
      </span>

      {/* Code formation */}
      <span
        className="font-display text-[13px] font-bold tracking-wide whitespace-nowrap"
        style={{
          color: isActive ? accent : "#FFFFFF",
          textShadow: isActive ? `0 0 12px ${accent}aa` : undefined,
        }}
      >
        {formation.code}
      </span>

      {/* Pulse animé sur l'actif */}
      {isActive && (
        <span
          aria-hidden
          className="absolute inset-0 rounded-full pointer-events-none motion-reduce:hidden"
          style={{
            border: `1.5px solid ${accent}`,
            animation: "cr-pulse 1.6s ease-out infinite",
          }}
        />
      )}

      <style jsx>{`
        @keyframes cr-pulse {
          0% {
            transform: scale(1);
            opacity: 0.7;
          }
          100% {
            transform: scale(1.55);
            opacity: 0;
          }
        }
      `}</style>
    </button>
  );
}
