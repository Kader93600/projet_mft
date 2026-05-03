"use client";

import Link from "next/link";
import { useState } from "react";
import { LogoMark } from "@/components/ui/logo";
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
 * Constellation atomique : le logo de l'école est le noyau, les 8 formations
 * gravitent autour comme des électrons sur deux orbites contre-rotatives.
 *
 *  - Desktop (≥ md) : orbite réelle avec positions calculées en pourcentage
 *    sur un conteneur carré responsive (clamp 540 → 720 px).
 *  - Mobile : version compacte avec mini-orbite + tap pour activer une
 *    formation (affiche tagline avant de naviguer).
 *
 *  Animations (toutes désactivées en motion-reduce) :
 *   - Stagger fade-up à l'apparition (depuis le centre vers l'extérieur)
 *   - Orbite tournante en arrière-plan (CSS spin-slow contre-rotatif)
 *   - Léger flottement vertical de chaque carte (animation `float-y`)
 *   - Halo pulsant signal sur le logo central
 *   - Hover/focus/tap : glow accent + scale + ligne SVG mise en avant +
 *     tagline qui apparaît sous la carte
 */
export function FormationsConstellation() {
  const items = FORMATIONS;
  const total = items.length;
  const radius = 38;
  const positions = items.map((_, i) => {
    const angle = (i / total) * Math.PI * 2 - Math.PI / 2;
    return {
      x: 50 + radius * Math.cos(angle),
      y: 50 + radius * Math.sin(angle),
      angle: (angle * 180) / Math.PI,
    };
  });

  const [activeSlug, setActiveSlug] = useState<string | null>(null);

  return (
    <section
      id="formations"
      className="relative py-20 md:py-28 bg-white/[0.02] border-y border-white/5 overflow-hidden"
    >
      {/* Halos décoratifs (signal + brand) */}
      <div
        aria-hidden
        className="absolute inset-0 pointer-events-none opacity-40"
        style={{
          background:
            "radial-gradient(ellipse 50% 60% at center, rgba(159,226,32,0.12) 0%, transparent 60%), radial-gradient(ellipse 80% 80% at center, rgba(37,48,217,0.20) 0%, transparent 70%)",
        }}
      />

      <div className="relative max-w-7xl mx-auto px-6">
        <div className="text-center max-w-2xl mx-auto">
          <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-400">
            Catalogue
          </span>
          <h2 className="mt-3 font-display text-3xl md:text-5xl font-semibold tracking-tight text-white">
            Toutes nos formations transport.
          </h2>
          <p className="mt-3 text-white/70 text-base md:text-lg leading-relaxed">
            Marchandises, voyageurs, capacités, certifications professionnelles —
            choisissez votre voie autour de notre expertise pédagogique.
          </p>
        </div>

        {/* DESKTOP — orbite ≥ md ============================================ */}
        <div
          className="hidden md:flex justify-center mt-16"
          onMouseLeave={() => setActiveSlug(null)}
        >
          <div
            className="relative aspect-square"
            style={{ width: "min(720px, 88vw)" }}
          >
            {/* Anneaux orbitaux animés (counter-rotation) ----------------- */}
            <div
              aria-hidden
              className="absolute inset-0 motion-reduce:hidden"
              style={{
                animation: "spin-slow 90s linear infinite",
                transformOrigin: "50% 50%",
              }}
            >
              <svg
                className="w-full h-full"
                viewBox="0 0 100 100"
                preserveAspectRatio="xMidYMid meet"
              >
                <circle
                  cx="50"
                  cy="50"
                  r={radius}
                  fill="none"
                  stroke="rgba(255,255,255,0.10)"
                  strokeWidth="0.18"
                  strokeDasharray="0.7 0.7"
                />
              </svg>
            </div>
            <div
              aria-hidden
              className="absolute inset-0 motion-reduce:hidden"
              style={{
                animation: "spin-slow 70s linear infinite reverse",
                transformOrigin: "50% 50%",
              }}
            >
              <svg
                className="w-full h-full"
                viewBox="0 0 100 100"
                preserveAspectRatio="xMidYMid meet"
              >
                <circle
                  cx="50"
                  cy="50"
                  r={radius - 10}
                  fill="none"
                  stroke="rgba(159,226,32,0.16)"
                  strokeWidth="0.12"
                  strokeDasharray="0.4 1"
                />
              </svg>
            </div>

            {/* Halo central + lignes de connexion ---------------------------- */}
            <svg
              aria-hidden
              className="absolute inset-0 w-full h-full pointer-events-none"
              viewBox="0 0 100 100"
              preserveAspectRatio="xMidYMid meet"
            >
              <defs>
                <radialGradient id="core-grad" cx="50%" cy="50%" r="50%">
                  <stop offset="0%" stopColor="rgba(159,226,32,0.30)" />
                  <stop offset="60%" stopColor="rgba(159,226,32,0.05)" />
                  <stop offset="100%" stopColor="rgba(159,226,32,0)" />
                </radialGradient>
              </defs>
              <circle cx="50" cy="50" r="18" fill="url(#core-grad)" />
              {positions.map((p, i) => {
                const isActive = activeSlug === items[i].slug;
                const accent = items[i].accent ?? "#9FE220";
                return (
                  <line
                    key={i}
                    x1="50"
                    y1="50"
                    x2={p.x}
                    y2={p.y}
                    stroke={isActive ? accent : "rgba(255,255,255,0.07)"}
                    strokeWidth={isActive ? "0.32" : "0.14"}
                    strokeDasharray={isActive ? "0" : "0.6 0.5"}
                    style={{
                      transition:
                        "stroke 0.4s ease-out, stroke-width 0.4s ease-out",
                      animation: `draw-path 1.2s ease-out ${i * 90}ms both`,
                      filter: isActive
                        ? `drop-shadow(0 0 1.5px ${accent})`
                        : undefined,
                    }}
                  />
                );
              })}
            </svg>

            {/* Logo central (noyau) ------------------------------------------ */}
            <div
              className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 z-10"
              style={{ animation: "fade-up 0.6s ease-out 0.2s both" }}
            >
              <div className="relative flex flex-col items-center">
                {/* Halo pulsant */}
                <div
                  aria-hidden
                  className="absolute -inset-8 rounded-full motion-reduce:hidden"
                  style={{
                    background:
                      "radial-gradient(circle, rgba(159,226,32,0.35) 0%, transparent 65%)",
                    animation: "glow-pulse 4s ease-in-out infinite",
                  }}
                />
                {/* Anneau autour du noyau */}
                <div
                  aria-hidden
                  className="absolute inset-0 -m-3 rounded-[2rem] border border-signal-400/30 motion-reduce:hidden"
                  style={{
                    animation: "glow-pulse 4s ease-in-out infinite",
                  }}
                />
                <div className="relative h-32 w-32 rounded-3xl bg-night-100 border border-white/15 flex items-center justify-center shadow-glow-signal">
                  <LogoMark className="h-20 w-20" variant="light" />
                </div>
                <div className="mt-4 text-center">
                  <div className="text-[10px] font-bold uppercase tracking-[0.2em] text-white/55">
                    Votre école
                  </div>
                  <div className="text-sm font-display font-semibold text-white mt-1 leading-tight">
                    MA FORMATION
                  </div>
                  <div className="text-sm font-display font-extrabold text-signal-400 leading-tight">
                    TRANSPORT
                  </div>
                </div>
              </div>
            </div>

            {/* 8 formations en orbite --------------------------------------- */}
            {items.map((f, i) => {
              const Icon = ICONS[f.iconName] ?? Truck;
              const p = positions[i];
              const accent = f.accent ?? "#9FE220";
              const isActive = activeSlug === f.slug;
              return (
                <div
                  key={f.slug}
                  className="absolute z-20"
                  style={{
                    left: `${p.x}%`,
                    top: `${p.y}%`,
                    transform: "translate(-50%, -50%)",
                    animation: `fade-up 0.6s cubic-bezier(0.22, 1, 0.36, 1) ${
                      300 + i * 80
                    }ms both`,
                  }}
                >
                  {/* Wrapper avec flottement vertical (subtil) */}
                  <div
                    className="motion-reduce:!animate-none"
                    style={{
                      animation: `float-y 6s ease-in-out ${i * 0.4}s infinite`,
                    }}
                  >
                    <Link
                      href={`/formations/${f.slug}`}
                      onMouseEnter={() => setActiveSlug(f.slug)}
                      onFocus={() => setActiveSlug(f.slug)}
                      onBlur={() => setActiveSlug(null)}
                      className="group block focus:outline-none"
                    >
                      <div
                        className={
                          "relative w-44 rounded-2xl border bg-night-100/85 backdrop-blur-md p-3.5 " +
                          "transition-[transform,box-shadow,border-color,background] duration-300 " +
                          "motion-reduce:transition-none " +
                          (isActive
                            ? "scale-[1.08] -translate-y-1 border-white/30 bg-night-100"
                            : "border-white/10 group-hover:border-white/25 group-hover:scale-[1.04] motion-reduce:group-hover:scale-100")
                        }
                        style={{
                          boxShadow: isActive
                            ? `0 18px 50px -10px ${accent}80, 0 0 0 1px ${accent}55, inset 0 0 24px ${accent}14`
                            : undefined,
                        }}
                      >
                        {/* Halo accent en hover */}
                        <div
                          aria-hidden
                          className="absolute -top-10 -right-10 h-24 w-24 rounded-full pointer-events-none transition-opacity duration-500"
                          style={{
                            background: `radial-gradient(circle, ${accent}55 0%, transparent 70%)`,
                            opacity: isActive ? 1 : 0,
                          }}
                        />

                        <div className="relative flex items-start gap-2.5">
                          <div
                            className="h-9 w-9 rounded-xl flex items-center justify-center shrink-0 transition-transform duration-300"
                            style={{
                              background: `${accent}1F`,
                              border: `1px solid ${accent}55`,
                              color: accent,
                              transform: isActive ? "scale(1.1)" : "scale(1)",
                            }}
                          >
                            <Icon className="h-4 w-4" />
                          </div>
                          <div className="min-w-0">
                            <div
                              className="text-[10px] font-bold uppercase tracking-wider"
                              style={{ color: accent }}
                            >
                              {f.code}
                            </div>
                            <div className="text-[13px] font-semibold text-white leading-tight mt-0.5 line-clamp-2">
                              {f.title}
                            </div>
                          </div>
                        </div>
                        <div className="mt-2.5 flex items-center justify-between text-[11px]">
                          <span className="text-white/45 truncate">
                            {f.duration}
                          </span>
                          <ArrowRight
                            className="h-3 w-3 shrink-0 transition-transform"
                            style={{
                              color: accent,
                              transform: isActive
                                ? "translateX(3px)"
                                : "translateX(0)",
                            }}
                          />
                        </div>
                      </div>

                      {/* Tagline qui apparaît au hover (tooltip) */}
                      <div
                        className={
                          "absolute left-1/2 top-full mt-2 -translate-x-1/2 w-52 " +
                          "rounded-xl bg-night-50/95 backdrop-blur-sm border border-white/10 " +
                          "px-3 py-2 text-[11px] text-white/80 leading-snug pointer-events-none " +
                          "transition-[opacity,transform] duration-300 ease-out " +
                          (isActive
                            ? "opacity-100 translate-y-0"
                            : "opacity-0 -translate-y-1")
                        }
                        style={{
                          boxShadow: isActive
                            ? `0 12px 30px -8px ${accent}55`
                            : undefined,
                        }}
                      >
                        {f.tagline}
                      </div>
                    </Link>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* MOBILE — mini-orbite + tap activation ============================ */}
        <div className="md:hidden mt-12">
          <div className="relative mx-auto aspect-square w-full max-w-sm">
            {/* Anneau */}
            <div
              aria-hidden
              className="absolute inset-0 motion-reduce:hidden"
              style={{
                animation: "spin-slow 80s linear infinite",
                transformOrigin: "50% 50%",
              }}
            >
              <svg
                className="w-full h-full"
                viewBox="0 0 100 100"
                preserveAspectRatio="xMidYMid meet"
              >
                <circle
                  cx="50"
                  cy="50"
                  r="38"
                  fill="none"
                  stroke="rgba(255,255,255,0.10)"
                  strokeWidth="0.25"
                  strokeDasharray="0.7 0.7"
                />
              </svg>
            </div>

            {/* Logo central */}
            <div className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 z-10">
              <div
                aria-hidden
                className="absolute -inset-6 rounded-full motion-reduce:hidden"
                style={{
                  background:
                    "radial-gradient(circle, rgba(159,226,32,0.35) 0%, transparent 65%)",
                  animation: "glow-pulse 4s ease-in-out infinite",
                }}
              />
              <div className="relative h-20 w-20 rounded-2xl bg-night-100 border border-white/15 flex items-center justify-center shadow-glow-signal">
                <LogoMark className="h-12 w-12" variant="light" />
              </div>
            </div>

            {/* 8 puces formations en orbite (icônes seulement) */}
            {items.map((f, i) => {
              const Icon = ICONS[f.iconName] ?? Truck;
              const p = positions[i];
              const accent = f.accent ?? "#9FE220";
              const isActive = activeSlug === f.slug;
              return (
                <button
                  key={f.slug}
                  type="button"
                  onClick={() => setActiveSlug(isActive ? null : f.slug)}
                  className="absolute z-20 focus:outline-none"
                  style={{
                    left: `${p.x}%`,
                    top: `${p.y}%`,
                    transform: "translate(-50%, -50%)",
                    animation: `fade-up 0.5s ease-out ${200 + i * 60}ms both`,
                  }}
                  aria-label={f.title}
                >
                  <span
                    className={
                      "h-12 w-12 rounded-2xl flex items-center justify-center transition-all duration-300 " +
                      (isActive
                        ? "scale-110"
                        : "scale-100 active:scale-95")
                    }
                    style={{
                      background: `${accent}22`,
                      border: `1px solid ${accent}88`,
                      color: accent,
                      boxShadow: isActive
                        ? `0 0 0 4px ${accent}33, 0 12px 30px -8px ${accent}88`
                        : undefined,
                    }}
                  >
                    <Icon className="h-5 w-5" />
                  </span>
                </button>
              );
            })}
          </div>

          {/* Carte détail de la formation active (mobile) */}
          <div className="mt-6 min-h-[7rem]">
            {(() => {
              const f =
                items.find((x) => x.slug === activeSlug) ?? items[0];
              const Icon = ICONS[f.iconName] ?? Truck;
              const accent = f.accent ?? "#9FE220";
              return (
                <Link
                  href={`/formations/${f.slug}`}
                  className="block rounded-2xl border bg-night-100 p-4 transition-all"
                  style={{
                    borderColor: `${accent}55`,
                    boxShadow: `0 12px 32px -10px ${accent}55, inset 0 0 0 1px ${accent}22`,
                  }}
                >
                  <div className="flex items-start gap-3">
                    <div
                      className="h-11 w-11 rounded-xl flex items-center justify-center shrink-0"
                      style={{
                        background: `${accent}1F`,
                        border: `1px solid ${accent}55`,
                        color: accent,
                      }}
                    >
                      <Icon className="h-5 w-5" />
                    </div>
                    <div className="min-w-0 flex-1">
                      <div
                        className="text-[10px] font-bold uppercase tracking-wider"
                        style={{ color: accent }}
                      >
                        {f.code}
                      </div>
                      <div className="text-sm font-semibold text-white mt-0.5 leading-tight">
                        {f.title}
                      </div>
                      <div className="mt-1 text-xs text-white/65 line-clamp-2">
                        {f.tagline}
                      </div>
                    </div>
                    <ArrowRight
                      className="h-4 w-4 shrink-0 mt-1"
                      style={{ color: accent }}
                    />
                  </div>
                </Link>
              );
            })()}
          </div>
          <p className="mt-3 text-center text-[11px] text-white/45">
            {activeSlug
              ? "Touchez à nouveau pour fermer · ou la carte pour ouvrir"
              : "Touchez une formation pour la mettre en avant"}
          </p>
        </div>

        <div className="mt-12 text-center">
          <Link
            href="/formations"
            className="inline-flex items-center gap-1.5 text-sm font-medium text-signal-400 hover:text-signal-300 transition-colors"
          >
            Voir le catalogue détaillé
            <ArrowRight className="h-3.5 w-3.5" />
          </Link>
        </div>
      </div>
    </section>
  );
}
