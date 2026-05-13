"use client";

import { useState, useMemo } from "react";
import Link from "next/link";
import {
  ArrowRight,
  Check,
  Sparkles,
  MessageCircle,
  Users,
  Lock,
  Brain,
  GraduationCap,
} from "lucide-react";
import { FORMATIONS } from "@/lib/formations-config";
import { fmtEuros, type PackSlug } from "@/lib/packs";
import { useCountUp } from "@/lib/use-count-up";
import { ScrollReveal } from "@/components/site/scroll-reveal";

interface PriceEntry {
  formationSlug: string;
  pack: PackSlug;
  priceCents: number;
  compareAtCents: number | null;
}

interface Props {
  prices: PriceEntry[];
  defaultFormationSlug?: string;
}

/**
 * Section "Choisissez votre rythme" — cœur de la page /tarifs vitrine.
 *
 * Animations (révision 2026-05) :
 *   - Stagger entrance des cards (ScrollReveal avec delays)
 *   - Count-up sur les prix au changement de formation
 *   - Hover lift + glow per pack
 *   - Premium : shimmer doré perpétuel (motion-reduce respect)
 *   - Crossfade des cards au changement de formation
 */
export function PricingSection({ prices, defaultFormationSlug }: Props) {
  const formationsWithPrices = useMemo(() => {
    const slugs = new Set(prices.map((p) => p.formationSlug));
    return FORMATIONS.filter((f) => slugs.has(f.slug));
  }, [prices]);

  const initialSlug =
    defaultFormationSlug &&
    formationsWithPrices.some((f) => f.slug === defaultFormationSlug)
      ? defaultFormationSlug
      : formationsWithPrices[0]?.slug ?? FORMATIONS[0].slug;

  const [selectedSlug, setSelectedSlug] = useState<string>(initialSlug);
  const selectedFormation = FORMATIONS.find((f) => f.slug === selectedSlug);
  const accent = selectedFormation?.accent ?? "#9FE220";

  const priceForPack = useMemo(() => {
    const map: Record<PackSlug, PriceEntry | undefined> = {
      initial: undefined,
      medium: undefined,
      premium: undefined,
    };
    for (const p of prices) {
      if (p.formationSlug === selectedSlug) map[p.pack] = p;
    }
    return map;
  }, [prices, selectedSlug]);

  const isCapaciteOnly = selectedSlug === "capacite-3-5t";

  return (
    <section
      className="relative px-6 pt-16 pb-24 md:pb-32"
      aria-labelledby="pricing-heading"
    >
      {/* En-tête de section */}
      <div className="max-w-6xl mx-auto">
        <ScrollReveal>
          <div className="flex items-center gap-2.5 mb-4">
            <span className="text-[11px] font-bold uppercase tracking-[0.2em] text-signal-400">
              Tarifs · Achat unique
            </span>
            <span className="h-px flex-1 max-w-[60px] bg-signal-500/30" />
          </div>
        </ScrollReveal>

        <ScrollReveal delay={80}>
          <h2
            id="pricing-heading"
            className="font-display text-4xl md:text-5xl lg:text-6xl font-semibold text-white tracking-tight max-w-3xl"
            style={{ letterSpacing: "-0.025em", lineHeight: 1.05 }}
          >
            Choisissez votre rythme,{" "}
            <span className="italic font-normal text-signal-400">
              pas le nôtre
            </span>
            .
          </h2>
        </ScrollReveal>

        <ScrollReveal delay={160}>
          <p className="mt-6 text-lg text-white/65 max-w-2xl leading-relaxed">
            Trois manières de réussir, selon votre disponibilité et le suivi
            dont vous avez besoin. Aucune n'est meilleure : chacune est conçue
            pour un profil précis.
          </p>
        </ScrollReveal>

        {/* Sélecteur formation */}
        <ScrollReveal delay={240}>
          <div className="mt-12">
            <div className="text-[11px] font-bold uppercase tracking-[0.18em] text-white/45 mb-3">
              Pour quelle formation ?
            </div>
            <div className="-mx-6 px-6 overflow-x-auto scrollbar-thin scrollbar-track-transparent scrollbar-thumb-white/10">
              <div className="flex gap-2.5 pb-2 min-w-max">
                {formationsWithPrices.map((f, i) => {
                  const isActive = f.slug === selectedSlug;
                  return (
                    <button
                      key={f.slug}
                      type="button"
                      onClick={() => setSelectedSlug(f.slug)}
                      className={
                        "inline-flex items-center gap-2 px-4 py-2 rounded-full text-sm font-semibold whitespace-nowrap " +
                        "transition-all duration-300 motion-reduce:transition-none " +
                        (isActive
                          ? "bg-white text-night-900 scale-[1.03]"
                          : "bg-white/[0.06] text-white/70 border border-white/10 hover:bg-white/[0.10] hover:text-white hover:-translate-y-0.5 motion-reduce:transform-none")
                      }
                      style={
                        isActive
                          ? {
                              boxShadow: `0 0 0 1px ${f.accent}, 0 8px 28px -10px ${f.accent}70`,
                              transitionTimingFunction:
                                "cubic-bezier(0.22, 1, 0.36, 1)",
                            }
                          : {
                              transitionTimingFunction:
                                "cubic-bezier(0.22, 1, 0.36, 1)",
                            }
                      }
                    >
                      <span
                        className="inline-block w-2 h-2 rounded-full transition-all duration-300"
                        style={{
                          backgroundColor: f.accent,
                          boxShadow: isActive
                            ? `0 0 12px ${f.accent}`
                            : "none",
                        }}
                      />
                      {f.code}
                    </button>
                  );
                })}
              </div>
            </div>
          </div>
        </ScrollReveal>
      </div>

      {/* Cards : entrance staggerée + crossfade au change de formation */}
      <div
        className="mt-12 md:mt-16 max-w-6xl mx-auto animate-tarif-fade-in motion-reduce:animate-none"
        key={selectedSlug}
      >
        {isCapaciteOnly ? (
          <CapaciteOnlyLayout
            priceCents={priceForPack.initial?.priceCents ?? null}
            compareAtCents={priceForPack.initial?.compareAtCents ?? null}
            formationCode={selectedFormation?.code ?? "Capacité ≤ 3,5 t"}
            formationSlug={selectedSlug}
          />
        ) : (
          <div className="grid lg:grid-cols-12 gap-5 md:gap-6 items-stretch">
            <ScrollReveal delay={0} distance={32} className="lg:col-span-4">
              <InitialCard
                priceCents={priceForPack.initial?.priceCents ?? null}
                compareAtCents={priceForPack.initial?.compareAtCents ?? null}
                formationSlug={selectedSlug}
              />
            </ScrollReveal>
            <ScrollReveal delay={120} distance={32} className="lg:col-span-4">
              <MediumCard
                priceCents={priceForPack.medium?.priceCents ?? null}
                compareAtCents={priceForPack.medium?.compareAtCents ?? null}
                formationSlug={selectedSlug}
              />
            </ScrollReveal>
            <ScrollReveal delay={240} distance={32} className="lg:col-span-4">
              <PremiumCard
                priceCents={priceForPack.premium?.priceCents ?? null}
                compareAtCents={priceForPack.premium?.compareAtCents ?? null}
                formationSlug={selectedSlug}
                accent={accent}
              />
            </ScrollReveal>
          </div>
        )}

        <ScrollReveal delay={400}>
          <p className="mt-10 text-center text-sm text-white/45">
            Tarifs nets, exonérés de TVA (art. 261-4-4° CGI). Achat unique
            sans engagement. Financement CPF, OPCO, employeur, France Travail.
          </p>
        </ScrollReveal>
      </div>
    </section>
  );
}

// =====================================================================
// AnimatedPrice — prix avec count-up animé au changement
// =====================================================================
function AnimatedPrice({
  priceCents,
  size,
}: {
  priceCents: number | null;
  size: "lg" | "xl";
}) {
  const target = priceCents ?? 0;
  const displayed = useCountUp(target, 600);

  if (priceCents == null) {
    return (
      <span
        className={
          "font-display font-semibold text-white tracking-tight " +
          (size === "xl" ? "text-5xl" : "text-4xl")
        }
      >
        —
      </span>
    );
  }

  return (
    <span
      className={
        "font-display font-semibold tracking-tight text-white tabular-nums " +
        (size === "xl" ? "text-5xl" : "text-4xl")
      }
      style={size === "xl" ? { letterSpacing: "-0.03em" } : undefined}
    >
      {fmtEuros(Math.round(displayed))}
    </span>
  );
}

// =====================================================================
// INITIAL — Card compacte, ton sobre, autonome
// =====================================================================
function InitialCard({
  priceCents,
  compareAtCents,
  formationSlug,
}: {
  priceCents: number | null;
  compareAtCents: number | null;
  formationSlug: string;
}) {
  return (
    <article
      className={
        "relative flex flex-col rounded-3xl bg-white/[0.03] border border-white/10 p-7 md:p-8 backdrop-blur-sm h-full " +
        "transition-all duration-500 motion-reduce:transition-none " +
        "hover:bg-white/[0.05] hover:border-white/20 hover:-translate-y-1 motion-reduce:hover:transform-none"
      }
      style={{ transitionTimingFunction: "cubic-bezier(0.22, 1, 0.36, 1)" }}
      aria-labelledby="pack-initial-title"
    >
      <div className="text-[11px] font-bold uppercase tracking-[0.18em] text-white/50 mb-2">
        Pack Initial
      </div>
      <h3
        id="pack-initial-title"
        className="font-display text-2xl font-semibold text-white"
      >
        Prêt à réussir, à votre rythme.
      </h3>
      <p className="mt-2 text-[14.5px] text-white/55 leading-relaxed">
        Tous les cours, les exercices et les examens blancs. Vous avancez
        seul·e mais jamais perdu·e : l'IA corrige tout en temps réel.
      </p>

      <div className="mt-7 flex items-baseline gap-2">
        <AnimatedPrice priceCents={priceCents} size="lg" />
        {compareAtCents != null && (
          <span className="text-sm text-white/35 line-through">
            {fmtEuros(compareAtCents)}
          </span>
        )}
      </div>
      <div className="text-[12px] text-white/45 mt-1">
        Net, exonéré TVA · Paiement unique
      </div>

      <ul className="mt-7 space-y-3 text-[14.5px] text-white/80">
        <FeatureLine>Tous les cours détaillés et fiches synthèse</FeatureLine>
        <FeatureLine>Exercices et examens blancs illimités</FeatureLine>
        <FeatureLine>
          <span className="inline-flex items-center gap-1.5">
            <Brain className="h-3.5 w-3.5 text-signal-400" />
            QR et examens blancs corrigés par IA
          </span>
        </FeatureLine>
        <FeatureLine>Certificat de fin de formation</FeatureLine>
        <FeatureLine>Accès illimité 18 mois</FeatureLine>
      </ul>

      <div className="mt-auto pt-8">
        <CTAButton
          formationSlug={formationSlug}
          pack="initial"
          variant="ghost"
          label="Choisir Initial"
        />
      </div>
    </article>
  );
}

// =====================================================================
// MEDIUM — Pack intermédiaire, hover signal-glow
// =====================================================================
function MediumCard({
  priceCents,
  compareAtCents,
  formationSlug,
}: {
  priceCents: number | null;
  compareAtCents: number | null;
  formationSlug: string;
}) {
  return (
    <article
      className={
        "relative flex flex-col rounded-3xl bg-white/[0.05] border border-signal-500/20 p-7 md:p-8 backdrop-blur-sm h-full " +
        "transition-all duration-500 motion-reduce:transition-none " +
        "hover:bg-white/[0.07] hover:border-signal-500/40 hover:-translate-y-1 motion-reduce:hover:transform-none"
      }
      style={{
        transitionTimingFunction: "cubic-bezier(0.22, 1, 0.36, 1)",
      }}
      aria-labelledby="pack-medium-title"
    >
      {/* Glow signal-lime au hover */}
      <div
        aria-hidden
        className="absolute inset-0 rounded-3xl pointer-events-none opacity-0 transition-opacity duration-500 motion-reduce:transition-none hover:opacity-100"
        style={{
          boxShadow:
            "0 24px 60px -20px rgba(159, 226, 32, 0.20), 0 0 0 1px rgba(159, 226, 32, 0.10)",
        }}
      />

      <div className="text-[11px] font-bold uppercase tracking-[0.18em] text-signal-400 mb-2">
        Pack Medium
      </div>
      <h3
        id="pack-medium-title"
        className="font-display text-2xl font-semibold text-white"
      >
        Avec un formateur attitré.
      </h3>
      <p className="mt-2 text-[14.5px] text-white/65 leading-relaxed">
        Tout l'Initial, plus une{" "}
        <strong className="text-white">messagerie privée</strong> avec votre
        formateur dédié, joignable du début à la fin de votre parcours.
      </p>

      <div className="mt-7 flex items-baseline gap-2">
        <AnimatedPrice priceCents={priceCents} size="lg" />
        {compareAtCents != null && (
          <span className="text-sm text-white/35 line-through">
            {fmtEuros(compareAtCents)}
          </span>
        )}
      </div>
      <div className="text-[12px] text-white/55 mt-1">
        Net, exonéré TVA · Paiement unique
      </div>

      <ul className="mt-7 space-y-3 text-[14.5px] text-white/85">
        <FeatureLine highlight>Tout l'Initial</FeatureLine>
        <FeatureLine highlight>
          <span className="inline-flex items-center gap-1.5">
            <MessageCircle className="h-3.5 w-3.5 text-signal-400" />
            Messagerie avec un formateur attitré
          </span>
        </FeatureLine>
        <FeatureLine highlight>Réponses sous 24 h ouvrées</FeatureLine>
        <FeatureLine highlight>
          Corrections personnalisées sur demande
        </FeatureLine>
      </ul>

      <div className="mt-auto pt-8">
        <CTAButton
          formationSlug={formationSlug}
          pack="medium"
          variant="secondary"
          label="Choisir Medium"
        />
      </div>
    </article>
  );
}

// =====================================================================
// PREMIUM — Vedette : shimmer doré + glow permanent + hover lift
// =====================================================================
function PremiumCard({
  priceCents,
  compareAtCents,
  formationSlug,
  accent,
}: {
  priceCents: number | null;
  compareAtCents: number | null;
  formationSlug: string;
  accent: string;
}) {
  return (
    <article
      className={
        "relative flex flex-col rounded-3xl p-7 md:p-9 overflow-hidden h-full group " +
        "transition-all duration-500 motion-reduce:transition-none " +
        "hover:-translate-y-1.5 motion-reduce:hover:transform-none"
      }
      aria-labelledby="pack-premium-title"
      style={{
        background:
          "linear-gradient(165deg, rgba(161, 98, 7, 0.20) 0%, rgba(11, 15, 36, 0.95) 50%, rgba(11, 15, 36, 1) 100%)",
        border: "1px solid rgba(245, 158, 11, 0.35)",
        boxShadow:
          "0 0 0 1px rgba(245, 158, 11, 0.10), 0 24px 60px -20px rgba(161, 98, 7, 0.30)",
        transitionTimingFunction: "cubic-bezier(0.22, 1, 0.36, 1)",
      }}
    >
      {/* Filet doré décoratif top — animé en shimmer permanent */}
      <div
        aria-hidden
        className="absolute top-0 left-0 right-0 h-px motion-reduce:hidden"
        style={{
          background:
            "linear-gradient(90deg, transparent 0%, #F59E0B 30%, #FCD34D 50%, #F59E0B 70%, transparent 100%)",
          backgroundSize: "200% 100%",
          animation: "shimmer-x 4s ease-in-out infinite",
        }}
      />
      {/* Fallback statique pour reduced-motion */}
      <div
        aria-hidden
        className="absolute top-0 left-0 right-0 h-px hidden motion-reduce:block"
        style={{
          background:
            "linear-gradient(90deg, transparent 0%, #F59E0B 50%, transparent 100%)",
        }}
      />

      {/* Glow doré qui pulse subtilement */}
      <div
        aria-hidden
        className="absolute inset-0 rounded-3xl pointer-events-none motion-reduce:hidden"
        style={{
          boxShadow:
            "inset 0 0 80px -20px rgba(245, 158, 11, 0.15), 0 32px 80px -24px rgba(161, 98, 7, 0.40)",
          opacity: 0.6,
          animation: "premium-glow 5s ease-in-out infinite",
        }}
      />

      {/* Badge "Recommandé" — flottement subtil */}
      <div
        className="absolute top-5 right-5 motion-reduce:animate-none"
        style={{
          animation: "badge-float 3.5s ease-in-out infinite",
        }}
      >
        <div
          className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider"
          style={{
            backgroundColor: "rgba(245, 158, 11, 0.15)",
            color: "#FCD34D",
            border: "1px solid rgba(245, 158, 11, 0.30)",
          }}
        >
          <Sparkles className="h-3 w-3" />
          Recommandé
        </div>
      </div>

      <div
        className="text-[11px] font-bold uppercase tracking-[0.18em] mb-2 relative"
        style={{ color: "#FCD34D" }}
      >
        Pack Premium
      </div>
      <h3
        id="pack-premium-title"
        className="font-display text-3xl font-semibold text-white relative"
        style={{ letterSpacing: "-0.02em", lineHeight: 1.1 }}
      >
        Vous ne formez pas seul·e.
        <br />
        <span
          className="italic font-normal"
          style={{ color: "#FCD34D" }}
        >
          Vous formez avec nous.
        </span>
      </h3>
      <p className="mt-3 text-[15px] text-white/75 leading-relaxed relative">
        Sessions présentielles en salle, accompagnement humain rapproché,
        accès Zoom : c'est le pack pour celles et ceux qui veulent maximiser
        leurs chances de réussir <em>vraiment</em> à l'examen.
      </p>

      <div className="mt-7 flex items-baseline gap-2 relative">
        <AnimatedPrice priceCents={priceCents} size="xl" />
        {compareAtCents != null && (
          <span className="text-sm text-white/40 line-through">
            {fmtEuros(compareAtCents)}
          </span>
        )}
      </div>
      <div className="text-[12px] text-white/60 mt-1 relative">
        Net, exonéré TVA · Paiement unique
      </div>

      <ul className="mt-7 space-y-3 text-[15px] text-white/90 relative">
        <FeatureLine highlight goldAccent>
          <strong>Tout le Medium</strong>, et bien plus :
        </FeatureLine>
        <FeatureLine highlight goldAccent>
          <span className="inline-flex items-center gap-1.5">
            <Users className="h-3.5 w-3.5" style={{ color: "#FCD34D" }} />
            Sessions présentielles en salle (planning admin)
          </span>
        </FeatureLine>
        <FeatureLine highlight goldAccent>
          <span className="inline-flex items-center gap-1.5">
            <GraduationCap
              className="h-3.5 w-3.5"
              style={{ color: "#FCD34D" }}
            />
            Accès Zoom pour suivre à distance
          </span>
        </FeatureLine>
        <FeatureLine highlight goldAccent>
          Suivi rapproché avec votre formateur attitré
        </FeatureLine>
        <FeatureLine highlight goldAccent>
          Priorité sur les retours d'examen blanc
        </FeatureLine>
      </ul>

      <div className="mt-auto pt-8 relative">
        <CTAButton
          formationSlug={formationSlug}
          pack="premium"
          variant="gold"
          label="Choisir Premium"
        />
      </div>
    </article>
  );
}

// =====================================================================
// CAPACITÉ ≤ 3,5 T — Layout spécifique
// =====================================================================
function CapaciteOnlyLayout({
  priceCents,
  compareAtCents,
  formationCode,
  formationSlug,
}: {
  priceCents: number | null;
  compareAtCents: number | null;
  formationCode: string;
  formationSlug: string;
}) {
  return (
    <div className="grid lg:grid-cols-12 gap-6 items-stretch">
      <ScrollReveal delay={0} distance={32} className="lg:col-span-7">
        <InitialCard
          priceCents={priceCents}
          compareAtCents={compareAtCents}
          formationSlug={formationSlug}
        />
      </ScrollReveal>
      <ScrollReveal delay={150} distance={32} className="lg:col-span-5">
        <div className="rounded-3xl bg-white/[0.03] border border-white/10 p-7 md:p-8 flex flex-col justify-center h-full transition-all duration-500 motion-reduce:transition-none hover:bg-white/[0.05] hover:border-white/20">
          <Lock className="h-5 w-5 text-white/40 mb-3" />
          <h3 className="font-display text-xl font-semibold text-white">
            Pourquoi un seul pack ?
          </h3>
          <p className="mt-3 text-[14.5px] text-white/65 leading-relaxed">
            La <strong className="text-white">Capacité ≤ 3,5 t</strong> est
            une formation courte et standardisée (105 h théorie). L'examen
            est national, sur QCM uniquement : un suivi rapproché ou des
            sessions présentielles n'apportent pas de valeur ajoutée
            significative.
          </p>
          <p className="mt-3 text-[14.5px] text-white/65 leading-relaxed">
            Le <strong className="text-signal-400">pack Initial</strong>{" "}
            couvre 100 % du programme, avec correction automatique par IA
            des QR. C'est l'offre adaptée.
          </p>
          <Link
            href="/formations/capacite-3-5t"
            className="mt-6 inline-flex items-center gap-1.5 text-sm font-semibold text-white/80 hover:text-white transition group"
          >
            Voir le programme détaillé
            <ArrowRight className="h-3.5 w-3.5 group-hover:translate-x-0.5 transition" />
          </Link>
        </div>
      </ScrollReveal>
    </div>
  );
}

// =====================================================================
// Helpers
// =====================================================================
function FeatureLine({
  children,
  highlight,
  goldAccent,
}: {
  children: React.ReactNode;
  highlight?: boolean;
  goldAccent?: boolean;
}) {
  return (
    <li className="flex items-start gap-2.5">
      <Check
        className="h-4 w-4 mt-0.5 shrink-0"
        style={{
          color: goldAccent
            ? "#FCD34D"
            : highlight
              ? "#9FE220"
              : "rgba(255, 255, 255, 0.45)",
        }}
        strokeWidth={2.5}
      />
      <span className="text-[14.5px] leading-relaxed">{children}</span>
    </li>
  );
}

function CTAButton({
  formationSlug,
  pack,
  variant,
  label,
}: {
  formationSlug: string;
  pack: PackSlug;
  variant: "ghost" | "secondary" | "gold";
  label: string;
}) {
  const styles =
    variant === "gold"
      ? "bg-amber-500 text-night-900 hover:bg-amber-400 hover:shadow-[0_8px_24px_-8px_rgba(245,158,11,0.6)]"
      : variant === "secondary"
        ? "bg-signal-500 text-night-900 hover:bg-signal-400 hover:shadow-[0_8px_24px_-8px_rgba(159,226,32,0.6)]"
        : "bg-white/[0.08] text-white border border-white/15 hover:bg-white/[0.14] hover:border-white/25";
  return (
    <Link
      href={`/inscription?formation=${formationSlug}&pack=${pack}`}
      className={
        "group inline-flex items-center justify-center gap-2 w-full px-5 py-3 rounded-xl text-sm font-semibold " +
        "transition-all duration-300 motion-reduce:transition-none " +
        styles
      }
      style={{ transitionTimingFunction: "cubic-bezier(0.22, 1, 0.36, 1)" }}
    >
      {label}
      <ArrowRight
        className="h-4 w-4 transition-transform duration-300 motion-reduce:transition-none group-hover:translate-x-1"
        style={{ transitionTimingFunction: "cubic-bezier(0.22, 1, 0.36, 1)" }}
      />
    </Link>
  );
}
