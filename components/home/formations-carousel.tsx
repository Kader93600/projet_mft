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

/**
 * Carrousel de flip cards 3D — remplace la constellation orbitale.
 *
 * Mécanique :
 *  - Scroller horizontal avec scroll-snap (1 carte centrée = 1 snap)
 *  - Chaque carte est un conteneur avec perspective 1400px ; l'enfant
 *    flippe en rotateY(180deg) au hover (desktop) ou via data-flipped
 *    après un tap (mobile, sans hover).
 *  - IntersectionObserver pour suivre la carte centrée → indicateurs.
 *  - Boutons prev/next desktop, dots responsive.
 *
 * Face avant : icône glow accent + code + niveau RNCP, titre, durée,
 *              hint "Retourner".
 * Face arrière : code, RNCP, titre complet, baseline, durée + modalité +
 *               public, CTA "Découvrir la formation".
 */
export function FormationsCarousel() {
  const scrollerRef = React.useRef<HTMLDivElement>(null);
  const [activeIdx, setActiveIdx] = React.useState(0);
  const [flippedSlugs, setFlippedSlugs] = React.useState<Set<string>>(
    () => new Set()
  );

  const scrollToCard = (idx: number) => {
    const el = scrollerRef.current;
    if (!el) return;
    const card = el.children[idx] as HTMLElement | undefined;
    if (!card) return;
    const target =
      card.offsetLeft - (el.clientWidth - card.clientWidth) / 2 - el.offsetLeft;
    el.scrollTo({ left: target, behavior: "smooth" });
  };

  const next = () =>
    scrollToCard(Math.min(activeIdx + 1, FORMATIONS.length - 1));
  const prev = () => scrollToCard(Math.max(activeIdx - 1, 0));

  const toggleFlip = (slug: string) => {
    setFlippedSlugs((prev) => {
      const n = new Set(prev);
      if (n.has(slug)) n.delete(slug);
      else n.add(slug);
      return n;
    });
  };

  // Track centered card via IntersectionObserver
  React.useEffect(() => {
    const el = scrollerRef.current;
    if (!el) return;
    const observer = new IntersectionObserver(
      (entries) => {
        let bestRatio = 0;
        let bestTarget: Element | null = null;
        entries.forEach((e) => {
          if (e.intersectionRatio > bestRatio) {
            bestRatio = e.intersectionRatio;
            bestTarget = e.target;
          }
        });
        if (bestTarget && bestRatio > 0.55) {
          const idx = Number((bestTarget as HTMLElement).dataset.idx);
          if (!Number.isNaN(idx)) setActiveIdx(idx);
        }
      },
      {
        root: el,
        threshold: [0.4, 0.6, 0.8, 1],
      }
    );
    Array.from(el.children).forEach((child) => observer.observe(child));
    return () => observer.disconnect();
  }, []);

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
            Survolez (ou tapez) une carte pour révéler la formation : niveau
            RNCP, durée, public visé, et accès direct à la fiche détaillée.
          </p>
        </div>

        {/* Carrousel ─────────────────────────────────────────────────── */}
        <div className="relative mt-12">
          {/* Boutons prev/next (desktop) */}
          <button
            type="button"
            onClick={prev}
            disabled={activeIdx === 0}
            aria-label="Formation précédente"
            className="hidden md:grid absolute left-3 top-[42%] -translate-y-1/2 z-20 h-12 w-12 place-items-center rounded-full bg-night-100/85 backdrop-blur-md border border-white/15 text-white shadow-2xl hover:bg-night-50 hover:border-signal-400/60 hover:scale-105 transition disabled:opacity-25 disabled:pointer-events-none"
          >
            <ArrowLeft className="h-5 w-5" />
          </button>
          <button
            type="button"
            onClick={next}
            disabled={activeIdx === FORMATIONS.length - 1}
            aria-label="Formation suivante"
            className="hidden md:grid absolute right-3 top-[42%] -translate-y-1/2 z-20 h-12 w-12 place-items-center rounded-full bg-night-100/85 backdrop-blur-md border border-white/15 text-white shadow-2xl hover:bg-night-50 hover:border-signal-400/60 hover:scale-105 transition disabled:opacity-25 disabled:pointer-events-none"
          >
            <ArrowRight className="h-5 w-5" />
          </button>

          {/* Bord fade gauche / droite */}
          <div
            aria-hidden
            className="hidden md:block pointer-events-none absolute left-0 top-0 bottom-12 w-16 z-10"
            style={{
              background:
                "linear-gradient(to right, rgba(8,11,42,0.95) 0%, transparent 100%)",
            }}
          />
          <div
            aria-hidden
            className="hidden md:block pointer-events-none absolute right-0 top-0 bottom-12 w-16 z-10"
            style={{
              background:
                "linear-gradient(to left, rgba(8,11,42,0.95) 0%, transparent 100%)",
            }}
          />

          {/* Scroller */}
          <div
            ref={scrollerRef}
            className="flex gap-5 overflow-x-auto snap-x snap-mandatory scroll-smooth pb-8 pt-6 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"
            style={{
              paddingLeft: "max(1.5rem, calc(50% - 165px))",
              paddingRight: "max(1.5rem, calc(50% - 165px))",
            }}
          >
            {FORMATIONS.map((f, i) => (
              <FlipCard
                key={f.slug}
                formation={f}
                idx={i}
                flipped={flippedSlugs.has(f.slug)}
                onToggle={() => toggleFlip(f.slug)}
                isCenter={i === activeIdx}
              />
            ))}
          </div>

          {/* Dots indicator */}
          <div className="flex justify-center items-center gap-1.5 mt-2">
            {FORMATIONS.map((f, i) => (
              <button
                key={f.slug}
                type="button"
                onClick={() => scrollToCard(i)}
                aria-label={`Aller à ${f.code}`}
                aria-current={i === activeIdx}
                className={
                  "h-1.5 rounded-full transition-all duration-300 " +
                  (i === activeIdx
                    ? "w-8 bg-signal-400 shadow-[0_0_12px_rgba(159,226,32,0.7)]"
                    : "w-1.5 bg-white/20 hover:bg-white/40")
                }
              />
            ))}
          </div>
        </div>

        <div className="mt-10 text-center">
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
  idx,
  flipped,
  onToggle,
  isCenter,
}: {
  formation: (typeof FORMATIONS)[number];
  idx: number;
  flipped: boolean;
  onToggle: () => void;
  isCenter: boolean;
}) {
  const Icon = ICONS[formation.iconName] ?? Truck;
  const accent = formation.accent ?? "#9FE220";

  return (
    <div
      data-idx={idx}
      className={
        "snap-center shrink-0 w-[260px] sm:w-[280px] md:w-[300px] " +
        "transition-[transform,opacity] duration-500 " +
        (isCenter
          ? "scale-100 opacity-100"
          : "scale-[0.92] opacity-70")
      }
      style={{ aspectRatio: "3 / 4" }}
    >
      <div
        className="group relative w-full h-full cursor-pointer"
        style={{ perspective: "1400px" }}
        data-flipped={flipped ? "true" : "false"}
        onClick={(e) => {
          // Don't toggle if click was on inner CTA link
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
          flipped ? "Face avant" : "Face arrière"
        } visible. Tapez pour retourner.`}
      >
        {/* Ombre dynamique sous la carte */}
        <div
          aria-hidden
          className="absolute -bottom-4 left-1/2 -translate-x-1/2 w-[80%] h-8 rounded-full blur-2xl pointer-events-none transition-opacity duration-500 group-hover:opacity-90"
          style={{
            background: `radial-gradient(ellipse, ${accent}80 0%, transparent 70%)`,
            opacity: 0.5,
          }}
        />

        <div
          className={
            "relative w-full h-full transition-transform duration-[800ms] " +
            "ease-[cubic-bezier(0.16,1,0.3,1)] [transform-style:preserve-3d] " +
            "md:group-hover:[transform:rotateY(180deg)] " +
            "group-data-[flipped=true]:[transform:rotateY(180deg)] " +
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
            {/* Icône XL en filigrane */}
            <Icon
              className="absolute -bottom-10 -right-10 h-64 w-64 pointer-events-none"
              style={{ color: accent, opacity: 0.07 }}
              strokeWidth={1.1}
            />

            {/* Halo top-left */}
            <div
              aria-hidden
              className="absolute -top-16 -left-16 h-44 w-44 rounded-full pointer-events-none"
              style={{
                background: `radial-gradient(circle, ${accent}33 0%, transparent 70%)`,
              }}
            />

            {/* Particules signal subtiles */}
            <Sparkles
              aria-hidden
              className="absolute top-5 right-5 h-3.5 w-3.5 motion-reduce:hidden"
              style={{ color: accent, animation: "glow-pulse 4s ease-in-out infinite" }}
            />

            <div className="relative z-10 h-full flex flex-col p-6">
              {/* Top : code + niveau */}
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

              {/* Centre : icône glow */}
              <div className="flex-1 flex items-center justify-center">
                <div
                  className="relative h-24 w-24 rounded-3xl grid place-items-center transition-transform duration-500 md:group-hover:scale-110"
                  style={{
                    background: `linear-gradient(135deg, ${accent}33, ${accent}11)`,
                    border: `1px solid ${accent}88`,
                    color: accent,
                    boxShadow: `0 0 40px ${accent}55, inset 0 0 0 1px rgba(255,255,255,0.04)`,
                  }}
                >
                  <Icon className="h-11 w-11" strokeWidth={1.6} />
                  {/* Anneau pulsant */}
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

              {/* Bas : titre + durée + hint */}
              <div>
                <div className="font-display text-[17px] font-semibold text-white leading-snug line-clamp-2">
                  {formation.title}
                </div>
                <div className="mt-3 flex items-center justify-between gap-2">
                  <span className="inline-flex items-center gap-1.5 text-[11px] text-white/60">
                    <Clock className="h-3 w-3" />
                    {formation.duration}
                  </span>
                  <span className="inline-flex items-center gap-1 text-[10px] font-semibold text-white/40 group-hover:text-white/85 transition-colors">
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
            {/* Décor : halo accent en bas */}
            <div
              aria-hidden
              className="absolute -bottom-20 -right-20 h-52 w-52 rounded-full pointer-events-none"
              style={{
                background: `radial-gradient(circle, ${accent}33 0%, transparent 70%)`,
              }}
            />

            {/* Top : code + RNCP */}
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

            {/* Titre complet */}
            <h3 className="mt-4 font-display text-[15px] font-semibold text-white leading-tight">
              {formation.title}
            </h3>

            {/* Tagline */}
            <p className="mt-2 text-[12px] text-white/65 leading-relaxed line-clamp-3">
              {formation.tagline}
            </p>

            {/* Infos clés */}
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

            {/* CTA */}
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
