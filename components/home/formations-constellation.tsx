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
 * Constellation des formations : logo de l'école au centre, 8 formations
 * disposées en cercle autour (desktop). Mobile : grille classique.
 *
 * Animations :
 *  - Stagger fade-up à l'entrée (50ms par item, en spirale depuis le centre)
 *  - Hover : carte qui se lève + glow accent + arrow translate
 *  - Lignes de connexion (SVG) qui se dessinent à l'entrée (draw-path)
 *  - Logo central : pulse glow signal très subtil
 *
 * Tout respecte motion-reduce.
 */
export function FormationsConstellation() {
  const items = FORMATIONS;
  const total = items.length;
  // 8 positions sur un cercle, centrées sur 90° (haut) → -90° (bas)
  // On part du haut puis on tourne dans le sens horaire.
  const radius = 38; // % du conteneur
  const positions = items.map((_, i) => {
    const angle = (i / total) * Math.PI * 2 - Math.PI / 2; // commence en haut
    return {
      // x/y en pourcentage relatif au conteneur (centre = 50%)
      x: 50 + radius * Math.cos(angle),
      y: 50 + radius * Math.sin(angle),
      angle: (angle * 180) / Math.PI,
    };
  });

  const [hoveredSlug, setHoveredSlug] = useState<string | null>(null);

  return (
    <section
      id="formations"
      className="relative py-20 md:py-28 bg-white/[0.02] border-y border-white/5 overflow-hidden"
    >
      {/* Fond décoratif : grille subtile + halo signal central */}
      <div
        aria-hidden
        className="absolute inset-0 pointer-events-none opacity-30"
        style={{
          background:
            "radial-gradient(ellipse at center, rgba(159,226,32,0.10) 0%, transparent 50%), radial-gradient(ellipse at center, rgba(37,48,217,0.18) 0%, transparent 70%)",
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

        {/* DESKTOP — orbite ≥ md */}
        <div
          className="hidden md:block relative mt-16 mx-auto"
          style={{ width: "min(720px, 90vw)", aspectRatio: "1 / 1" }}
          onMouseLeave={() => setHoveredSlug(null)}
        >
          {/* Cercles concentriques décoratifs */}
          <svg
            aria-hidden
            className="absolute inset-0 w-full h-full pointer-events-none"
            viewBox="0 0 100 100"
            preserveAspectRatio="xMidYMid meet"
          >
            <defs>
              <radialGradient id="ring-grad" cx="50%" cy="50%" r="50%">
                <stop offset="60%" stopColor="rgba(255,255,255,0)" />
                <stop offset="100%" stopColor="rgba(159,226,32,0.12)" />
              </radialGradient>
            </defs>
            <circle
              cx="50"
              cy="50"
              r={radius}
              fill="none"
              stroke="rgba(255,255,255,0.08)"
              strokeWidth="0.2"
              strokeDasharray="0.8 0.6"
              className="motion-reduce:hidden animate-[spin-slow_60s_linear_infinite]"
              style={{ transformOrigin: "50% 50%" }}
            />
            <circle
              cx="50"
              cy="50"
              r={radius - 8}
              fill="none"
              stroke="rgba(159,226,32,0.10)"
              strokeWidth="0.15"
            />
            <circle
              cx="50"
              cy="50"
              r="14"
              fill="url(#ring-grad)"
              opacity="0.6"
            />
            {/* Lignes de connexion logo ↔ chaque formation */}
            {positions.map((p, i) => (
              <line
                key={i}
                x1="50"
                y1="50"
                x2={p.x}
                y2={p.y}
                stroke={
                  hoveredSlug === items[i].slug
                    ? items[i].accent ?? "#9FE220"
                    : "rgba(255,255,255,0.06)"
                }
                strokeWidth={hoveredSlug === items[i].slug ? "0.25" : "0.15"}
                strokeDasharray="0.6 0.4"
                style={{
                  transition: "stroke 0.4s ease-out, stroke-width 0.4s ease-out",
                  animation: `draw-path 1.2s ease-out ${i * 80}ms both`,
                }}
              />
            ))}
          </svg>

          {/* Logo central */}
          <div
            className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 z-10"
            style={{ animation: "fade-up 0.6s ease-out 0.2s both" }}
          >
            <div className="relative">
              {/* Halo pulsant */}
              <div
                aria-hidden
                className="absolute inset-0 -m-6 rounded-full motion-reduce:hidden"
                style={{
                  background:
                    "radial-gradient(circle, rgba(159,226,32,0.25) 0%, transparent 70%)",
                  animation: "glow-pulse 4s ease-in-out infinite",
                }}
              />
              <div className="relative h-28 w-28 rounded-3xl bg-night-100 border border-white/10 flex items-center justify-center shadow-glow-signal">
                <LogoMark className="h-16 w-16" variant="light" />
              </div>
              <div className="mt-3 text-center">
                <div className="text-[10px] font-bold uppercase tracking-[0.18em] text-white/50">
                  Votre école
                </div>
                <div className="text-sm font-display font-semibold text-white mt-0.5">
                  MA FORMATION
                </div>
                <div className="text-sm font-display font-extrabold text-signal-400 -mt-0.5">
                  TRANSPORT
                </div>
              </div>
            </div>
          </div>

          {/* 8 formations en orbite */}
          {items.map((f, i) => {
            const Icon = ICONS[f.iconName] ?? Truck;
            const p = positions[i];
            const accent = f.accent ?? "#9FE220";
            const isHovered = hoveredSlug === f.slug;
            return (
              <Link
                key={f.slug}
                href={`/formations/${f.slug}`}
                onMouseEnter={() => setHoveredSlug(f.slug)}
                className="group absolute z-20"
                style={{
                  left: `${p.x}%`,
                  top: `${p.y}%`,
                  transform: "translate(-50%, -50%)",
                  animation: `fade-up 0.6s cubic-bezier(0.22, 1, 0.36, 1) ${
                    300 + i * 80
                  }ms both`,
                }}
              >
                <div
                  className={
                    "relative w-44 rounded-2xl border bg-night-100/80 backdrop-blur-md p-3.5 " +
                    "transition-[transform,box-shadow,border-color,background] duration-300 " +
                    "motion-reduce:transition-none " +
                    (isHovered
                      ? "scale-[1.06] -translate-y-1 shadow-raised border-white/30 bg-night-100"
                      : "border-white/10 hover:border-white/20 hover:scale-[1.04] motion-reduce:hover:scale-100")
                  }
                  style={{
                    boxShadow: isHovered
                      ? `0 14px 40px -10px ${accent}66, 0 0 0 1px ${accent}33`
                      : undefined,
                  }}
                >
                  {/* Halo accent */}
                  <div
                    aria-hidden
                    className="absolute -top-8 -right-8 h-20 w-20 rounded-full pointer-events-none transition-opacity duration-500"
                    style={{
                      background: `radial-gradient(circle, ${accent}40 0%, transparent 70%)`,
                      opacity: isHovered ? 1 : 0,
                    }}
                  />

                  <div className="relative flex items-start gap-2.5">
                    <div
                      className="h-9 w-9 rounded-xl flex items-center justify-center shrink-0"
                      style={{
                        background: `${accent}1F`,
                        border: `1px solid ${accent}55`,
                        color: accent,
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
                    <span className="text-white/45 truncate">{f.duration}</span>
                    <ArrowRight
                      className="h-3 w-3 shrink-0 transition-transform"
                      style={{
                        color: accent,
                        transform: isHovered
                          ? "translateX(2px)"
                          : "translateX(0)",
                      }}
                    />
                  </div>
                </div>
              </Link>
            );
          })}
        </div>

        {/* MOBILE — fallback grille */}
        <div className="md:hidden mt-12 space-y-6">
          {/* Logo en haut */}
          <div className="flex justify-center">
            <div className="relative h-20 w-20 rounded-2xl bg-night-100 border border-white/10 flex items-center justify-center shadow-glow-signal">
              <LogoMark className="h-12 w-12" variant="light" />
            </div>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            {items.map((f, i) => {
              const Icon = ICONS[f.iconName] ?? Truck;
              const accent = f.accent ?? "#9FE220";
              return (
                <Link
                  key={f.slug}
                  href={`/formations/${f.slug}`}
                  className="group rounded-2xl border border-white/10 bg-night-100 p-4 transition-all hover:border-white/30 hover:-translate-y-0.5"
                  style={{
                    animation: `fade-up 0.5s ease-out ${i * 50}ms both`,
                  }}
                >
                  <div className="flex items-start gap-3">
                    <div
                      className="h-10 w-10 rounded-xl flex items-center justify-center shrink-0"
                      style={{
                        background: `${accent}1F`,
                        border: `1px solid ${accent}55`,
                        color: accent,
                      }}
                    >
                      <Icon className="h-5 w-5" />
                    </div>
                    <div className="min-w-0">
                      <div
                        className="text-[10px] font-bold uppercase tracking-wider"
                        style={{ color: accent }}
                      >
                        {f.code}
                      </div>
                      <div className="text-sm font-semibold text-white mt-0.5 leading-tight">
                        {f.title}
                      </div>
                      <div className="mt-1 text-xs text-white/55 line-clamp-2">
                        {f.tagline}
                      </div>
                    </div>
                  </div>
                </Link>
              );
            })}
          </div>
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
