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

/** Pixels par tick de scroll auto (lent, défilement continu). */
const AUTO_SCROLL_STEP = 1;
/** Intervalle entre 2 ticks (ms). */
const AUTO_SCROLL_INTERVAL = 30;
/** Décalage manuel quand on clique sur les flèches. */
const MANUAL_SCROLL_AMOUNT = 320;

/**
 * Carousel des formations avec :
 *  - Scroll horizontal natif (overflow-x: auto, scroll-snap)
 *  - Auto-scroll continu via setInterval (1px / 30ms ≈ 33px/s)
 *  - Pause au hover, focus, touch, ou flip d'une carte
 *  - Flèches gauche/droite pour navigation manuelle
 *  - Boucle visuelle : duplication des cartes pour seamless wrap
 *  - Cartes flip 3D individuelles (UX inchangée)
 *  - prefers-reduced-motion : pas d'auto-scroll, scroll manuel only
 */
export function FormationsCarousel() {
  const scrollRef = React.useRef<HTMLDivElement>(null);
  const [flippedSlugs, setFlippedSlugs] = React.useState<Set<string>>(
    () => new Set()
  );
  const [isPaused, setIsPaused] = React.useState(false);
  const [reducedMotion, setReducedMotion] = React.useState(false);
  const touchTimerRef = React.useRef<ReturnType<typeof setTimeout> | null>(
    null
  );

  // Détecte prefers-reduced-motion
  React.useEffect(() => {
    if (typeof window === "undefined") return;
    const mq = window.matchMedia("(prefers-reduced-motion: reduce)");
    setReducedMotion(mq.matches);
    const onChange = (e: MediaQueryListEvent) => setReducedMotion(e.matches);
    mq.addEventListener("change", onChange);
    return () => mq.removeEventListener("change", onChange);
  }, []);

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
    setIsPaused(true);
    touchTimerRef.current = setTimeout(() => setIsPaused(false), 4000);
  };

  // Pause si flip ou touch récent
  const shouldPause = flippedSlugs.size > 0 || isPaused;

  // Auto-scroll : 1px par tick
  React.useEffect(() => {
    if (reducedMotion) return;
    if (shouldPause) return;
    const el = scrollRef.current;
    if (!el) return;

    const id = window.setInterval(() => {
      if (!scrollRef.current) return;
      const node = scrollRef.current;
      const max = node.scrollWidth - node.clientWidth;
      if (node.scrollLeft >= max - 1) {
        // Boucle : retour au début sans animation
        node.scrollLeft = 0;
      } else {
        node.scrollLeft += AUTO_SCROLL_STEP;
      }
    }, AUTO_SCROLL_INTERVAL);

    return () => window.clearInterval(id);
  }, [reducedMotion, shouldPause]);

  React.useEffect(() => {
    return () => {
      if (touchTimerRef.current) clearTimeout(touchTimerRef.current);
    };
  }, []);

  const scrollByAmount = (amount: number) => {
    const node = scrollRef.current;
    if (!node) return;
    // Pause l'auto-scroll quelques secondes après un click manuel
    setIsPaused(true);
    if (touchTimerRef.current) clearTimeout(touchTimerRef.current);
    touchTimerRef.current = setTimeout(() => setIsPaused(false), 4000);
    node.scrollBy({ left: amount, behavior: "smooth" });
  };

  // Duplique les formations pour la boucle visuelle
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
            détail. Utilisez les flèches pour naviguer plus vite.
          </p>
        </div>

        {/* Carousel ─────────────────────────────────────────────────── */}
        <div
          className="relative mt-12 group/carousel"
          onMouseEnter={() => setIsPaused(true)}
          onMouseLeave={() => setIsPaused(false)}
          onTouchStart={handleTouchStart}
        >
          {/* Flèche gauche */}
          <button
            type="button"
            onClick={() => scrollByAmount(-MANUAL_SCROLL_AMOUNT)}
            aria-label="Faire défiler vers la gauche"
            className="absolute left-2 sm:left-3 top-1/2 -translate-y-1/2 z-10 h-11 w-11 rounded-full bg-night-300/90 border border-white/15 text-white backdrop-blur-md shadow-float flex items-center justify-center transition-all duration-200 hover:bg-night-200 hover:border-signal-400/60 hover:scale-105 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-signal-400 focus-visible:ring-offset-2 focus-visible:ring-offset-night"
          >
            <ArrowLeft className="h-5 w-5" />
          </button>

          {/* Flèche droite */}
          <button
            type="button"
            onClick={() => scrollByAmount(MANUAL_SCROLL_AMOUNT)}
            aria-label="Faire défiler vers la droite"
            className="absolute right-2 sm:right-3 top-1/2 -translate-y-1/2 z-10 h-11 w-11 rounded-full bg-night-300/90 border border-white/15 text-white backdrop-blur-md shadow-float flex items-center justify-center transition-all duration-200 hover:bg-night-200 hover:border-signal-400/60 hover:scale-105 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-signal-400 focus-visible:ring-offset-2 focus-visible:ring-offset-night"
          >
            <ArrowRight className="h-5 w-5" />
          </button>

          {/* Container scrollable */}
          <div
            ref={scrollRef}
            className="overflow-x-auto overflow-y-hidden no-scrollbar py-6 scroll-smooth"
            style={{
              maskImage:
                "linear-gradient(to right, transparent 0, black 6%, black 94%, transparent 100%)",
              WebkitMaskImage:
                "linear-gradient(to right, transparent 0, black 6%, black 94%, transparent 100%)",
              scrollSnapType: "x proximity",
            }}
            tabIndex={0}
            aria-label="Liste des formations transport — utilisez les flèches du clavier pour naviguer"
            onKeyDown={(e) => {
              if (e.key === "ArrowLeft") {
                e.preventDefault();
                scrollByAmount(-MANUAL_SCROLL_AMOUNT);
              } else if (e.key === "ArrowRight") {
                e.preventDefault();
                scrollByAmount(MANUAL_SCROLL_AMOUNT);
              }
            }}
          >
            <div className="flex gap-5 w-max px-12 sm:px-16">
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
      style={{ aspectRatio: "3 / 4", scrollSnapAlign: "center" }}
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
