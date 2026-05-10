"use client";
import * as React from "react";
import Link from "next/link";
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
  ArrowLeft,
  RotateCw,
  Clock,
  MapPin,
  Users,
  Sparkles,
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

const MODALITY_LABEL: Record<string, string> = {
  presentiel: "Présentiel",
  distanciel: "100 % en ligne",
  mixte: "Mixte présentiel / distanciel",
};

/** Vitesse normale du défilement auto (secondes pour 1 boucle complète). */
const NORMAL_DURATION_S = 35;
/** Durée de l'accélération quand on clique une flèche. */
const BOOST_DURATION_MS = 1500;
/** Vitesse boostée (temporaire, à chaque click flèche) — plus doux que 4s. */
const BOOST_DURATION_S = 10;

/**
 * Marquee infini des formations — défile lentement et en continu, avec
 * cartes flip 3D individuelles + flèches gauche/droite pour boost manuel.
 *
 *  - Inner row : flex gap, width: max-content, animation translateX 0 → -50%
 *  - Cartes dupliquées (×2) → boucle parfaitement sans saut
 *  - Auto-pause au hover, flip de carte, ou touch récent
 *  - Flèches gauche/droite : boost temporaire (4s/loop pendant 1,5s)
 *    → effet "fast-forward" / "rewind" instinctif
 *  - prefers-reduced-motion : marquee figée
 */
export function FormationsCarousel() {
  const [flippedSlugs, setFlippedSlugs] = React.useState<Set<string>>(
    () => new Set()
  );
  const [touchPaused, setTouchPaused] = React.useState(false);
  const [boostMode, setBoostMode] = React.useState<"normal" | "fwd" | "bwd">(
    "normal"
  );
  const touchTimerRef = React.useRef<ReturnType<typeof setTimeout> | null>(
    null
  );
  const boostTimerRef = React.useRef<ReturnType<typeof setTimeout> | null>(
    null
  );

  const toggleFlip = (slug: string) => {
    setFlippedSlugs((prev) => {
      const n = new Set(prev);
      if (n.has(slug)) n.delete(slug);
      else n.add(slug);
      return n;
    });
  };

  const handleTouchStart = () => {
    if (touchTimerRef.current) clearTimeout(touchTimerRef.current);
    setTouchPaused(true);
    touchTimerRef.current = setTimeout(() => setTouchPaused(false), 4000);
  };

  const handleArrow = (direction: "fwd" | "bwd") => {
    if (boostTimerRef.current) clearTimeout(boostTimerRef.current);
    setBoostMode(direction);
    boostTimerRef.current = setTimeout(() => {
      setBoostMode("normal");
    }, BOOST_DURATION_MS);
  };

  React.useEffect(() => {
    return () => {
      if (touchTimerRef.current) clearTimeout(touchTimerRef.current);
      if (boostTimerRef.current) clearTimeout(boostTimerRef.current);
    };
  }, []);

  // Pause si flip ou touch récent
  const isPaused = flippedSlugs.size > 0 || touchPaused;

  // Calcule l'animation selon le mode
  // Convention :
  //   - Click flèche GAUCHE (←) → "bwd" → contenu défile vers la GAUCHE (sens normal, accéléré)
  //   - Click flèche DROITE (→) → "fwd" → contenu défile vers la DROITE (sens reverse, accéléré)
  const animationDuration =
    boostMode === "normal" ? `${NORMAL_DURATION_S}s` : `${BOOST_DURATION_S}s`;
  const animationDirection = boostMode === "fwd" ? "reverse" : "normal";

  // Duplique les formations pour la boucle parfaite
  const items = [...FORMATIONS, ...FORMATIONS];

  return (
    <section
      id="formations"
      className="relative py-20 md:py-28 bg-white/[0.02] border-y border-white/5 overflow-hidden"
    >
      {/* Halo de fond */}
      <div
        aria-hidden
        className="absolute inset-0 pointer-events-none opacity-50"
        style={{
          background:
            "radial-gradient(ellipse 60% 55% at 50% 50%, rgba(159,226,32,0.10) 0%, rgba(56,69,229,0.18) 40%, transparent 75%)",
        }}
      />

      <div className="relative max-w-7xl mx-auto">
        <div className="px-6 text-center max-w-2xl mx-auto">
          <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-400">
            Catalogue
          </span>
          <h2 className="mt-3 font-display text-3xl md:text-5xl font-semibold tracking-tight text-white">
            Toutes nos formations transport.
          </h2>
          <p className="mt-3 text-white/70 text-base md:text-lg leading-relaxed">
            Survolez (ou tapez) une carte pour la retourner et accéder au
            détail. Le défilement se met en pause automatiquement.
          </p>
        </div>

        {/* Marquee ───────────────────────────────────────────────────── */}
        <div
          className="relative mt-12"
          onTouchStart={handleTouchStart}
        >
          {/* Flèche gauche (rewind) */}
          <button
            type="button"
            onClick={() => handleArrow("bwd")}
            aria-label="Revenir en arrière dans le carrousel"
            className="absolute left-2 sm:left-4 top-1/2 -translate-y-1/2 z-20 h-11 w-11 rounded-full bg-night-300/90 border border-white/15 text-white backdrop-blur-md shadow-float flex items-center justify-center transition-all duration-200 hover:bg-night-200 hover:border-signal-400/60 hover:scale-110 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-signal-400 focus-visible:ring-offset-2 focus-visible:ring-offset-night"
          >
            <ArrowLeft className="h-5 w-5" />
          </button>

          {/* Flèche droite (fast-forward) */}
          <button
            type="button"
            onClick={() => handleArrow("fwd")}
            aria-label="Avancer rapidement dans le carrousel"
            className="absolute right-2 sm:right-4 top-1/2 -translate-y-1/2 z-20 h-11 w-11 rounded-full bg-night-300/90 border border-white/15 text-white backdrop-blur-md shadow-float flex items-center justify-center transition-all duration-200 hover:bg-night-200 hover:border-signal-400/60 hover:scale-110 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-signal-400 focus-visible:ring-offset-2 focus-visible:ring-offset-night"
          >
            <ArrowRight className="h-5 w-5" />
          </button>

          <div
            style={{
              // Masques fade gauche/droite (les cartes apparaissent/disparaissent en douceur)
              maskImage:
                "linear-gradient(to right, transparent 0, black 6%, black 94%, transparent 100%)",
              WebkitMaskImage:
                "linear-gradient(to right, transparent 0, black 6%, black 94%, transparent 100%)",
            }}
          >
            {/* Wrapper marquee : pause au hover (CSS) + pause forcée si flip ou touch */}
            <div className="group overflow-hidden py-6">
              <div
                className="flex gap-5 w-max group-hover:[animation-play-state:paused] motion-reduce:!animation-none"
                style={{
                  animation: `marquee-x ${animationDuration} linear infinite`,
                  animationDirection,
                  animationPlayState: isPaused ? "paused" : undefined,
                }}
              >
                {items.map((f, i) => (
                  <FlipCard
                    key={`${f.slug}-${i}`}
                    formation={f}
                    flipped={flippedSlugs.has(f.slug)}
                    onToggle={() => toggleFlip(f.slug)}
                  />
                ))}
              </div>
            </div>
          </div>
        </div>

        <div className="mt-8 text-center">
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

/* ─── Flip Card ────────────────────────────────────────────────────── */

function FlipCard({
  formation,
  flipped,
  onToggle,
}: {
  formation: (typeof FORMATIONS)[number];
  flipped: boolean;
  onToggle: () => void;
}) {
  const Icon = ICONS[formation.iconName] ?? Truck;
  const accent = formation.accent ?? "#9FE220";

  return (
    <div
      className="shrink-0 w-[260px] sm:w-[280px] md:w-[300px]"
      style={{ aspectRatio: "3 / 4" }}
    >
      <div
        className="flip-card group/card relative w-full h-full cursor-pointer"
        style={{ perspective: "1400px" }}
        data-flipped={flipped ? "true" : "false"}
        onClick={(e) => {
          if ((e.target as HTMLElement).closest("a")) return;
          onToggle();
        }}
        onKeyDown={(e) => {
          if (e.key === "Enter" || e.key === " ") {
            e.preventDefault();
            onToggle();
          }
        }}
        role="button"
        tabIndex={0}
        aria-label={`${formation.code} — ${formation.title}. ${
          flipped ? "Face arrière" : "Face avant"
        } visible. Tapez pour retourner.`}
      >
        {/* Ombre sous la carte */}
        <div
          aria-hidden
          className="absolute -bottom-4 left-1/2 -translate-x-1/2 w-[80%] h-8 rounded-full blur-2xl pointer-events-none transition-opacity duration-500 group-hover/card:opacity-90"
          style={{
            background: `radial-gradient(ellipse, ${accent}80 0%, transparent 70%)`,
            opacity: 0.5,
          }}
        />

        <div
          className={
            "relative w-full h-full transition-transform duration-[800ms] " +
            "ease-[cubic-bezier(0.16,1,0.3,1)] [transform-style:preserve-3d] " +
            "md:group-hover/card:[transform:rotateY(180deg)] " +
            "group-data-[flipped=true]/card:[transform:rotateY(180deg)] " +
            "motion-reduce:transition-none"
          }
        >
          {/* ─── Face avant ─────────────────────────────────────────── */}
          <div
            className="absolute inset-0 rounded-[1.5rem] overflow-hidden border [backface-visibility:hidden] [-webkit-backface-visibility:hidden]"
            style={{
              borderColor: `${accent}55`,
              background: `linear-gradient(155deg, ${accent}2A 0%, rgba(15,18,64,0.96) 55%, rgba(15,18,64,1) 100%)`,
              boxShadow: `0 24px 60px -12px ${accent}44, inset 0 0 0 1px rgba(255,255,255,0.04)`,
            }}
          >
            <Icon
              className="absolute -bottom-10 -right-10 h-64 w-64 pointer-events-none"
              style={{ color: accent, opacity: 0.07 }}
              strokeWidth={1.1}
            />

            <div
              aria-hidden
              className="absolute -top-16 -left-16 h-44 w-44 rounded-full pointer-events-none"
              style={{
                background: `radial-gradient(circle, ${accent}33 0%, transparent 70%)`,
              }}
            />

            <Sparkles
              aria-hidden
              className="absolute top-5 right-5 h-3.5 w-3.5 motion-reduce:hidden"
              style={{
                color: accent,
                animation: "glow-pulse 4s ease-in-out infinite",
              }}
            />

            <div className="relative z-10 h-full flex flex-col p-6">
              <div className="flex items-start justify-between gap-2">
                <div className="inline-flex items-center gap-2">
                  <span
                    className="h-2 w-2 rounded-full"
                    style={{
                      backgroundColor: accent,
                      boxShadow: `0 0 8px ${accent}`,
                    }}
                  />
                  <span
                    className="text-[11px] font-bold uppercase tracking-[0.18em]"
                    style={{ color: accent }}
                  >
                    {formation.code}
                  </span>
                </div>
                {formation.level && (
                  <span className="text-[10px] font-semibold rounded-md bg-white/8 text-white/85 px-2 py-0.5 border border-white/10 whitespace-nowrap">
                    Niv. {formation.level} RNCP
                  </span>
                )}
              </div>

              <div className="flex-1 flex items-center justify-center">
                <div
                  className="relative h-24 w-24 rounded-3xl grid place-items-center transition-transform duration-500 md:group-hover/card:scale-110"
                  style={{
                    background: `linear-gradient(135deg, ${accent}33, ${accent}11)`,
                    border: `1px solid ${accent}88`,
                    color: accent,
                    boxShadow: `0 0 40px ${accent}55, inset 0 0 0 1px rgba(255,255,255,0.04)`,
                  }}
                >
                  <Icon className="h-11 w-11" strokeWidth={1.6} />
                  <span
                    aria-hidden
                    className="absolute inset-0 rounded-3xl border motion-reduce:hidden"
                    style={{
                      borderColor: `${accent}66`,
                      animation: "glow-pulse 3s ease-in-out infinite",
                    }}
                  />
                </div>
              </div>

              <div>
                <div className="font-display text-[17px] font-semibold text-white leading-snug line-clamp-2">
                  {formation.title}
                </div>
                <div className="mt-3 flex items-center justify-between gap-2">
                  <span className="inline-flex items-center gap-1.5 text-[11px] text-white/60">
                    <Clock className="h-3 w-3" />
                    {formation.duration}
                  </span>
                  <span className="inline-flex items-center gap-1 text-[10px] font-semibold text-white/40 group-hover/card:text-white/85 transition-colors">
                    <RotateCw className="h-3 w-3" />
                    Retourner
                  </span>
                </div>
              </div>
            </div>
          </div>

          {/* ─── Face arrière ───────────────────────────────────────── */}
          <div
            className="absolute inset-0 rounded-[1.5rem] overflow-hidden border [backface-visibility:hidden] [-webkit-backface-visibility:hidden] [transform:rotateY(180deg)] flex flex-col p-6"
            style={{
              borderColor: `${accent}88`,
              background:
                "linear-gradient(180deg, rgba(20,24,80,0.98) 0%, rgba(15,18,64,0.98) 100%)",
              boxShadow: `inset 0 0 40px ${accent}22, 0 24px 60px -12px ${accent}66`,
            }}
          >
            <div
              aria-hidden
              className="absolute -bottom-20 -right-20 h-52 w-52 rounded-full pointer-events-none"
              style={{
                background: `radial-gradient(circle, ${accent}33 0%, transparent 70%)`,
              }}
            />

            <div className="flex items-start justify-between gap-2">
              <div className="inline-flex items-center gap-1.5">
                <Icon
                  className="h-4 w-4"
                  style={{ color: accent }}
                  strokeWidth={1.6}
                />
                <span
                  className="text-[11px] font-bold uppercase tracking-[0.18em]"
                  style={{ color: accent }}
                >
                  {formation.code}
                </span>
              </div>
              {formation.rncpCode && (
                <span className="text-[9px] font-semibold rounded-md bg-white/8 text-white/75 px-1.5 py-0.5 border border-white/10 whitespace-nowrap">
                  {formation.rncpCode}
                </span>
              )}
            </div>

            <h3 className="mt-4 font-display text-[15px] font-semibold text-white leading-tight">
              {formation.title}
            </h3>

            <p className="mt-2 text-[12px] text-white/65 leading-relaxed line-clamp-3">
              {formation.tagline}
            </p>

            <ul className="mt-4 space-y-2.5 text-[11.5px]">
              <li className="flex items-start gap-2.5 text-white/75">
                <Clock
                  className="h-3.5 w-3.5 shrink-0 mt-0.5"
                  style={{ color: accent }}
                />
                <span>{formation.duration}</span>
              </li>
              <li className="flex items-start gap-2.5 text-white/75">
                <MapPin
                  className="h-3.5 w-3.5 shrink-0 mt-0.5"
                  style={{ color: accent }}
                />
                <span>{MODALITY_LABEL[formation.modality]}</span>
              </li>
              <li className="flex items-start gap-2.5 text-white/75">
                <Users
                  className="h-3.5 w-3.5 shrink-0 mt-0.5"
                  style={{ color: accent }}
                />
                <span className="line-clamp-2">{formation.audience}</span>
              </li>
            </ul>

            <Link
              href={`/formations/${formation.slug}`}
              className="mt-auto inline-flex w-full items-center justify-center gap-2 rounded-xl px-4 py-3 text-sm font-bold text-night-900 transition-transform hover:scale-[1.02]"
              style={{
                background: accent,
                boxShadow: `0 10px 28px -6px ${accent}99`,
              }}
              onClick={(e) => e.stopPropagation()}
            >
              Découvrir la formation
              <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
