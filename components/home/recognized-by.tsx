"use client";

import {
  Landmark,
  ShieldCheck,
  Award,
  Wallet,
  Briefcase,
  Building2,
  Compass,
} from "lucide-react";

type Org = {
  name: string;
  short: string;
  Icon: any;
  /** Couleur d'accent (hex) — utilisée pour le glow / icône */
  accent: string;
  category: string;
};

/**
 * Carrousel marquee glassmorphism — “Reconnu par”.
 *
 * - Deux rangées qui défilent en sens opposés (effet de profondeur)
 * - Cards glass (bg blanche très translucide + blur), bord lumineux
 * - Hover : scale + glow accent + texte plus net + arrêt de l'animation
 * - Masques fade sur les bords pour un fondu propre
 * - Désactivé en motion-reduce : fallback grille flex-wrap
 */
const ORGS: Org[] = [
  {
    name: "Ministère du Travail",
    short: "Min. du Travail",
    Icon: Landmark,
    accent: "#5C6AF2",
    category: "Tutelle",
  },
  {
    name: "Qualiopi",
    short: "Qualiopi",
    Icon: ShieldCheck,
    accent: "#9FE220",
    category: "Certification qualité",
  },
  {
    name: "France Compétences",
    short: "France Compétences",
    Icon: Award,
    accent: "#F2A65C",
    category: "Régulateur",
  },
  {
    name: "Mon Compte Formation",
    short: "MonCompteFormation",
    Icon: Wallet,
    accent: "#5C6AF2",
    category: "Financement",
  },
  {
    name: "France Travail",
    short: "France Travail",
    Icon: Briefcase,
    accent: "#9FE220",
    category: "Insertion",
  },
  {
    name: "OPCO Mobilités",
    short: "OPCO Mobilités",
    Icon: Building2,
    accent: "#F25C8A",
    category: "Branche",
  },
  {
    name: "DREAL",
    short: "DREAL",
    Icon: Compass,
    accent: "#5C6AF2",
    category: "Réglementation",
  },
];

function Card({ org }: { org: Org }) {
  const { name, short, Icon, accent, category } = org;
  return (
    <div
      className="group relative flex items-center gap-3 rounded-2xl border border-white/10 bg-white/[0.04] backdrop-blur-md px-4 py-3 min-w-[16rem] transition-[transform,background-color,border-color] duration-200 ease-premium hover:bg-white/[0.08] hover:border-white/25 hover:-translate-y-0.5 motion-reduce:transition-none motion-reduce:hover:translate-y-0"
      style={
        {
          // Glow accent au hover via CSS variable
          ["--c" as any]: accent,
        } as React.CSSProperties
      }
    >
      {/* Halo qui s'allume au hover */}
      <div
        aria-hidden
        className="absolute -inset-px rounded-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none"
        style={{
          background: `radial-gradient(120% 80% at 0% 0%, ${accent}26 0%, transparent 60%)`,
        }}
      />
      <div
        className="h-10 w-10 rounded-xl flex items-center justify-center shrink-0 transition-transform duration-300 group-hover:scale-110"
        style={{
          background: `${accent}1A`,
          border: `1px solid ${accent}66`,
          color: accent,
        }}
      >
        <Icon className="h-5 w-5" />
      </div>
      <div className="min-w-0">
        <div className="text-[9px] font-bold uppercase tracking-[0.18em] text-white/60 group-hover:text-white/65 transition-colors">
          {category}
        </div>
        <div className="font-display text-sm font-semibold text-white/85 group-hover:text-white whitespace-nowrap transition-colors">
          {short}
        </div>
      </div>
    </div>
  );
}

export function RecognizedBy() {
  // Deux séries dupliquées pour boucle parfaite (translateX -50%)
  const row = [...ORGS, ...ORGS];

  return (
    <section className="relative border-y border-white/5 bg-gradient-to-b from-white/[0.02] via-white/[0.03] to-white/[0.02] py-12 overflow-hidden">
      {/* Halo de fond très subtil */}
      <div
        aria-hidden
        className="absolute inset-0 pointer-events-none opacity-50"
        style={{
          background:
            "radial-gradient(ellipse 70% 50% at 50% 50%, rgba(159,226,32,0.06) 0%, transparent 60%)",
        }}
      />

      <div className="relative max-w-7xl mx-auto px-6">
        <div className="flex flex-col items-center justify-center mb-7">
          <span className="text-[10px] font-semibold uppercase tracking-[0.22em] text-white/60 inline-flex items-center gap-2">
            <span
              aria-hidden
              className="h-px w-10 bg-gradient-to-r from-transparent to-white/40"
            />
            Reconnu et référencé par
            <span
              aria-hidden
              className="h-px w-10 bg-gradient-to-l from-transparent to-white/40"
            />
          </span>
          <p className="mt-2 text-center text-xs text-white/55 max-w-md">
            Une école certifiée et financée par les principaux organismes du
            transport et de la formation professionnelle.
          </p>
        </div>

        {/* Marquee — fallback grille en motion-reduce */}
        <div
          className="relative motion-reduce:hidden"
          style={{
            maskImage:
              "linear-gradient(to right, transparent 0, black 8%, black 92%, transparent 100%)",
            WebkitMaskImage:
              "linear-gradient(to right, transparent 0, black 8%, black 92%, transparent 100%)",
          }}
        >
          {/* Rangée 1 — gauche → droite */}
          <div
            className="flex gap-4 [&:hover>*]:[animation-play-state:paused]"
            style={{ width: "max-content" }}
          >
            <div
              className="flex gap-4 animate-marquee-x"
              style={{ width: "max-content" }}
            >
              {row.map((o, i) => (
                <Card key={`r1-${i}`} org={o} />
              ))}
            </div>
          </div>

          {/* Rangée 2 — droite → gauche (offset) */}
          <div
            className="flex gap-4 mt-4"
            style={{ width: "max-content" }}
          >
            <div
              className="flex gap-4 animate-marquee-x"
              style={{
                width: "max-content",
                animationDirection: "reverse",
                animationDuration: "55s",
              }}
            >
              {row
                .slice()
                .reverse()
                .map((o, i) => (
                  <Card key={`r2-${i}`} org={o} />
                ))}
            </div>
          </div>
        </div>

        {/* Fallback motion-reduce */}
        <div className="hidden motion-reduce:flex flex-wrap justify-center gap-3">
          {ORGS.map((o, i) => (
            <Card key={`mr-${i}`} org={o} />
          ))}
        </div>
      </div>
    </section>
  );
}
