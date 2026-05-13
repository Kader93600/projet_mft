"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import {
  Check,
  Sparkles,
  MessageCircle,
  Users,
  Lock,
  Brain,
  GraduationCap,
  Info,
} from "lucide-react";
import { FORMATIONS, type Formation } from "@/lib/formations-config";
import {
  PACK_SLUGS,
  fmtEuros,
  isPackAvailableForFormation,
  type PackSlug,
} from "@/lib/packs";
import { useCountUp } from "@/lib/use-count-up";

interface PriceEntry {
  formationSlug: string;
  pack: PackSlug;
  priceCents: number;
  compareAtCents: number | null;
}

interface Props {
  prices: PriceEntry[];
  /** Slug pré-sélectionné depuis ?formation=… (passé par /tarifs). */
  defaultFormationSlug?: string;
  /** Pack pré-sélectionné depuis ?pack=… (passé par /tarifs). */
  defaultPackSlug?: PackSlug;
}

/**
 * Sélecteur de pack premium pour la page /inscription (in-app).
 *
 * - Affiche une formation chip-selector si plusieurs formations sont
 *   disponibles à l'achat (sinon : on cache et on locke la formation).
 * - Affiche 3 cards Initial / Medium / Premium (Capacité ≤ 3,5 t : 1 seule).
 * - Click sur une card = sélection (ring + scale + shadow).
 * - Prix animés en count-up lorsqu'on change de formation.
 * - Hidden inputs `formation_slug` et `pack_slug` injectés dans le form parent.
 */
export function PackPicker({
  prices,
  defaultFormationSlug,
  defaultPackSlug,
}: Props) {
  const formationsWithPrices = useMemo(() => {
    const slugs = new Set(prices.map((p) => p.formationSlug));
    return FORMATIONS.filter((f) => slugs.has(f.slug));
  }, [prices]);

  const initialFormationSlug =
    defaultFormationSlug &&
    formationsWithPrices.some((f) => f.slug === defaultFormationSlug)
      ? defaultFormationSlug
      : formationsWithPrices[0]?.slug ?? FORMATIONS[0].slug;

  const [formationSlug, setFormationSlug] = useState<string>(
    initialFormationSlug,
  );

  const formation: Formation | undefined = FORMATIONS.find(
    (f) => f.slug === formationSlug,
  );

  const availablePacks: PackSlug[] = useMemo(
    () => PACK_SLUGS.filter((p) => isPackAvailableForFormation(p, formationSlug)),
    [formationSlug],
  );

  const isCapaciteOnly = formationSlug === "capacite-3-5t";

  // Pack actif (par défaut : pré-rempli depuis URL, sinon medium si dispo,
  // sinon initial). Capacité : forcément initial.
  const computeInitialPack = (): PackSlug => {
    if (isCapaciteOnly) return "initial";
    if (defaultPackSlug && availablePacks.includes(defaultPackSlug)) {
      return defaultPackSlug;
    }
    return availablePacks.includes("medium") ? "medium" : "initial";
  };

  const [selectedPack, setSelectedPack] = useState<PackSlug>(computeInitialPack());

  // Si on change de formation et que le pack actuel n'est plus dispo, on
  // bascule sur le pack par défaut (cas Capacité).
  const onChangeFormation = (slug: string) => {
    setFormationSlug(slug);
    const newAvailable = PACK_SLUGS.filter((p) =>
      isPackAvailableForFormation(p, slug),
    );
    if (!newAvailable.includes(selectedPack)) {
      setSelectedPack(slug === "capacite-3-5t" ? "initial" : "medium");
    }
  };

  // Map prix actuel pour la formation sélectionnée
  const priceForPack = useMemo(() => {
    const map: Record<PackSlug, PriceEntry | undefined> = {
      initial: undefined,
      medium: undefined,
      premium: undefined,
    };
    for (const p of prices) {
      if (p.formationSlug === formationSlug) map[p.pack] = p;
    }
    return map;
  }, [prices, formationSlug]);

  const selectedPrice = priceForPack[selectedPack];

  return (
    <div className="space-y-7">
      {/* Hidden inputs pour le form parent */}
      <input type="hidden" name="formation_slug" value={formationSlug} />
      <input type="hidden" name="pack_slug" value={selectedPack} />

      {/* ── Sélecteur de formation (si plusieurs dispos) ─────────────── */}
      {formationsWithPrices.length > 1 && (
        <div>
          <div className="text-[11px] font-bold uppercase tracking-[0.16em] text-slate-500 mb-2.5">
            Pour quelle formation ?
          </div>
          <div className="-mx-2 px-2 overflow-x-auto no-scrollbar">
            <div className="flex gap-2 pb-1 min-w-max">
              {formationsWithPrices.map((f) => {
                const isActive = f.slug === formationSlug;
                return (
                  <button
                    key={f.slug}
                    type="button"
                    onClick={() => onChangeFormation(f.slug)}
                    aria-pressed={isActive}
                    className={
                      "inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full text-[13px] font-semibold whitespace-nowrap " +
                      "transition-all duration-300 motion-reduce:transition-none border " +
                      (isActive
                        ? "bg-navy-950 text-white border-navy-950 shadow-soft"
                        : "bg-white text-navy-800 border-navy-100 hover:border-navy-300 hover:-translate-y-0.5 motion-reduce:hover:transform-none")
                    }
                    style={{
                      transitionTimingFunction:
                        "cubic-bezier(0.22, 1, 0.36, 1)",
                    }}
                  >
                    <span
                      className="inline-block w-1.5 h-1.5 rounded-full"
                      style={{ backgroundColor: f.accent ?? "#9FE220" }}
                    />
                    {f.code}
                  </button>
                );
              })}
            </div>
          </div>
        </div>
      )}

      {/* ── Bandeau formation pré-sélectionnée (1 seule formation) ────── */}
      {formationsWithPrices.length === 1 && formation && (
        <div className="rounded-xl border border-gold-300 bg-gold-50 px-4 py-3 text-sm text-navy-900 flex items-start gap-2.5">
          <Sparkles className="h-4 w-4 text-gold-700 mt-0.5 shrink-0" />
          <div>
            <div className="text-[10px] font-semibold uppercase tracking-[0.16em] text-gold-700">
              Formation pré-sélectionnée
            </div>
            <div className="font-medium mt-0.5">
              {formation.code} — {formation.title}
            </div>
          </div>
        </div>
      )}

      {/* ── Cards de packs ───────────────────────────────────────────── */}
      {isCapaciteOnly ? (
        <CapaciteOnlyPanel
          priceCents={priceForPack.initial?.priceCents ?? null}
          compareAtCents={priceForPack.initial?.compareAtCents ?? null}
          formationCode={formation?.code ?? "Capacité ≤ 3,5 t"}
        />
      ) : (
        <div
          className="grid md:grid-cols-3 gap-4 md:gap-5 items-stretch animate-tarif-fade-in motion-reduce:animate-none"
          key={formationSlug}
          role="radiogroup"
          aria-label="Choisir votre pack"
        >
          <PackCard
            slug="initial"
            selected={selectedPack === "initial"}
            onSelect={() => setSelectedPack("initial")}
            priceCents={priceForPack.initial?.priceCents ?? null}
            compareAtCents={priceForPack.initial?.compareAtCents ?? null}
          />
          <PackCard
            slug="medium"
            selected={selectedPack === "medium"}
            onSelect={() => setSelectedPack("medium")}
            priceCents={priceForPack.medium?.priceCents ?? null}
            compareAtCents={priceForPack.medium?.compareAtCents ?? null}
          />
          <PackCard
            slug="premium"
            selected={selectedPack === "premium"}
            onSelect={() => setSelectedPack("premium")}
            priceCents={priceForPack.premium?.priceCents ?? null}
            compareAtCents={priceForPack.premium?.compareAtCents ?? null}
          />
        </div>
      )}

      {/* ── Récap pack sélectionné ───────────────────────────────────── */}
      <RecapBlock
        pack={selectedPack}
        priceCents={selectedPrice?.priceCents ?? null}
        compareAtCents={selectedPrice?.compareAtCents ?? null}
      />

      {/* ── Lien vers /tarifs pour comparer ──────────────────────────── */}
      <div className="flex items-center justify-between gap-3 text-[13px] text-slate-600 flex-wrap">
        <div className="inline-flex items-center gap-2">
          <Info className="h-3.5 w-3.5 text-slate-400" />
          Tous les prix sont nets, exonérés de TVA (art. 261-4-4° CGI).
        </div>
        <Link
          href="/tarifs"
          className="inline-flex items-center gap-1 font-semibold text-navy-900 hover:text-navy-950 underline decoration-signal-500/40 underline-offset-4 hover:decoration-signal-500"
        >
          Comparer les packs en détail
        </Link>
      </div>
    </div>
  );
}

// =====================================================================
// PackCard — card sélectionnable, 3 variants (initial / medium / premium)
// =====================================================================
function PackCard({
  slug,
  selected,
  onSelect,
  priceCents,
  compareAtCents,
}: {
  slug: PackSlug;
  selected: boolean;
  onSelect: () => void;
  priceCents: number | null;
  compareAtCents: number | null;
}) {
  const variant = useMemo(() => packVariant(slug), [slug]);

  return (
    <button
      type="button"
      onClick={onSelect}
      role="radio"
      aria-checked={selected}
      className={
        "relative flex flex-col text-left rounded-2xl p-5 md:p-6 h-full overflow-hidden " +
        "transition-all duration-300 motion-reduce:transition-none " +
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 " +
        "focus-visible:ring-offset-ivory focus-visible:ring-navy-600 " +
        (selected
          ? variant.containerSelected + " scale-[1.015] motion-reduce:scale-100"
          : variant.containerIdle +
            " hover:-translate-y-0.5 motion-reduce:hover:transform-none")
      }
      style={{
        transitionTimingFunction: "cubic-bezier(0.22, 1, 0.36, 1)",
        ...(selected ? variant.styleSelected : variant.styleIdle),
      }}
    >
      {/* Filet doré animé top (Premium uniquement) */}
      {slug === "premium" && (
        <>
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
          <div
            aria-hidden
            className="absolute top-0 left-0 right-0 h-px hidden motion-reduce:block"
            style={{
              background:
                "linear-gradient(90deg, transparent 0%, #F59E0B 50%, transparent 100%)",
            }}
          />
        </>
      )}

      {/* Badge "Sélectionné" (top-right) — toujours visible une fois choisi */}
      {selected && (
        <div className="absolute top-3 right-3 z-10">
          <div
            className={
              "inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[9.5px] font-bold uppercase tracking-[0.12em] " +
              variant.checkPill
            }
          >
            <Check className="h-3 w-3" strokeWidth={3} />
            Sélectionné
          </div>
        </div>
      )}

      {/* Badge "Recommandé" sur Premium (visible si non sélectionné) */}
      {slug === "premium" && !selected && (
        <div
          className="absolute top-3 right-3 motion-reduce:animate-none"
          style={{ animation: "badge-float 3.5s ease-in-out infinite" }}
        >
          <div
            className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[9.5px] font-bold uppercase tracking-[0.12em]"
            style={{
              backgroundColor: "rgba(245, 158, 11, 0.14)",
              color: "#92400E",
              border: "1px solid rgba(245, 158, 11, 0.30)",
            }}
          >
            <Sparkles className="h-3 w-3" />
            Recommandé
          </div>
        </div>
      )}

      <div
        className={
          "text-[10px] font-bold uppercase tracking-[0.18em] mb-1.5 " +
          variant.eyebrowColor
        }
      >
        Pack {variant.name}
      </div>
      <h3 className="font-display text-[17px] md:text-lg font-semibold text-navy-950 leading-tight">
        {variant.title}
      </h3>
      <p className="mt-1.5 text-[13px] text-slate-600 leading-relaxed">
        {variant.subtitle}
      </p>

      <div className="mt-5 flex items-baseline gap-1.5">
        <AnimatedPrice priceCents={priceCents} variant={slug} />
        {compareAtCents != null && (
          <span className="text-xs text-slate-400 line-through">
            {fmtEuros(compareAtCents)}
          </span>
        )}
      </div>
      <div className="text-[10.5px] text-slate-500 mt-0.5">
        Net · Paiement unique
      </div>

      <ul className="mt-5 space-y-2 text-[13px] text-slate-700 flex-1">
        {variant.features.map((f, i) => (
          <li key={i} className="flex items-start gap-2">
            <Check
              className="h-3.5 w-3.5 mt-0.5 shrink-0"
              strokeWidth={2.5}
              style={{ color: variant.checkColor }}
            />
            <span className="leading-relaxed">{f}</span>
          </li>
        ))}
      </ul>
    </button>
  );
}

// =====================================================================
// AnimatedPrice — RAF count-up sur changement de formation
// =====================================================================
function AnimatedPrice({
  priceCents,
  variant,
}: {
  priceCents: number | null;
  variant: PackSlug;
}) {
  const target = priceCents ?? 0;
  const displayed = useCountUp(target, 600);

  if (priceCents == null) {
    return (
      <span className="font-display text-2xl font-semibold text-slate-300">
        —
      </span>
    );
  }
  return (
    <span
      className={
        "font-display font-semibold tracking-tight tabular-nums " +
        (variant === "premium"
          ? "text-3xl text-navy-950"
          : "text-2xl md:text-[26px] text-navy-950")
      }
      style={{ letterSpacing: "-0.02em" }}
    >
      {fmtEuros(Math.round(displayed))}
    </span>
  );
}

// =====================================================================
// RecapBlock — sticky récap du pack sélectionné, fond signal pour CTA mental
// =====================================================================
function RecapBlock({
  pack,
  priceCents,
  compareAtCents,
}: {
  pack: PackSlug;
  priceCents: number | null;
  compareAtCents: number | null;
}) {
  const v = packVariant(pack);
  const target = priceCents ?? 0;
  const displayed = useCountUp(target, 600);

  return (
    <div
      className={
        "rounded-2xl p-4 md:p-5 border flex items-center justify-between gap-4 flex-wrap " +
        "transition-colors duration-300 motion-reduce:transition-none " +
        v.recapBg
      }
    >
      <div className="flex items-center gap-3 min-w-0">
        <div
          className={
            "h-10 w-10 rounded-xl inline-flex items-center justify-center shrink-0 " +
            v.recapIconBg
          }
        >
          <Sparkles
            className="h-4 w-4"
            style={{ color: v.checkColor }}
          />
        </div>
        <div className="min-w-0">
          <div className="text-[10.5px] font-bold uppercase tracking-[0.18em] text-slate-500">
            Votre choix
          </div>
          <div className="font-display text-base font-semibold text-navy-950 truncate">
            Pack {v.name}{" "}
            <span className="text-slate-500 font-normal text-sm">
              · {v.tagline}
            </span>
          </div>
        </div>
      </div>
      <div className="text-right shrink-0">
        <div className="font-display text-2xl font-semibold text-navy-950 tabular-nums">
          {priceCents != null ? fmtEuros(Math.round(displayed)) : "—"}
        </div>
        {compareAtCents != null && (
          <div className="text-xs text-slate-400 line-through">
            {fmtEuros(compareAtCents)}
          </div>
        )}
      </div>
    </div>
  );
}

// =====================================================================
// CapaciteOnlyPanel — un seul pack, on bloque la sélection
// =====================================================================
function CapaciteOnlyPanel({
  priceCents,
  compareAtCents,
  formationCode,
}: {
  priceCents: number | null;
  compareAtCents: number | null;
  formationCode: string;
}) {
  const v = packVariant("initial");
  const target = priceCents ?? 0;
  const displayed = useCountUp(target, 600);

  return (
    <div className="grid md:grid-cols-2 gap-4 md:gap-5 items-stretch animate-tarif-fade-in motion-reduce:animate-none">
      {/* La card Initial reste "sélectionnée" implicitement */}
      <div
        className="relative flex flex-col rounded-2xl p-5 md:p-6 bg-white border overflow-hidden"
        style={{
          borderColor: "rgba(159, 226, 32, 0.55)",
          boxShadow: "0 0 0 1px rgba(159, 226, 32, 0.25), 0 8px 24px -16px rgba(14,18,64,0.12)",
        }}
      >
        <div className="absolute top-3 right-3">
          <div className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[9.5px] font-bold uppercase tracking-[0.12em] bg-signal-500 text-night-900">
            <Check className="h-3 w-3" strokeWidth={3} />
            Sélectionné
          </div>
        </div>
        <div className="text-[10px] font-bold uppercase tracking-[0.18em] text-signal-700 mb-1.5">
          Pack Initial
        </div>
        <h3 className="font-display text-[17px] md:text-lg font-semibold text-navy-950 leading-tight">
          Prêt à réussir, à votre rythme.
        </h3>
        <p className="mt-1.5 text-[13px] text-slate-600 leading-relaxed">
          Tout le programme {formationCode}, exercices et examens blancs. L'IA
          corrige vos réponses en temps réel.
        </p>
        <div className="mt-5 flex items-baseline gap-1.5">
          {priceCents != null ? (
            <span className="font-display text-2xl md:text-[26px] font-semibold tracking-tight text-navy-950 tabular-nums">
              {fmtEuros(Math.round(displayed))}
            </span>
          ) : (
            <span className="font-display text-2xl font-semibold text-slate-300">
              —
            </span>
          )}
          {compareAtCents != null && (
            <span className="text-xs text-slate-400 line-through">
              {fmtEuros(compareAtCents)}
            </span>
          )}
        </div>
        <div className="text-[10.5px] text-slate-500 mt-0.5">
          Net · Paiement unique
        </div>
        <ul className="mt-5 space-y-2 text-[13px] text-slate-700">
          {v.features.map((f, i) => (
            <li key={i} className="flex items-start gap-2">
              <Check
                className="h-3.5 w-3.5 mt-0.5 shrink-0 text-signal-600"
                strokeWidth={2.5}
              />
              <span className="leading-relaxed">{f}</span>
            </li>
          ))}
        </ul>
      </div>

      {/* Explainer "pourquoi un seul pack" */}
      <div className="rounded-2xl border border-navy-100 bg-ivory p-5 md:p-6 flex flex-col justify-center">
        <Lock className="h-4 w-4 text-slate-400 mb-2" />
        <h3 className="font-display text-base font-semibold text-navy-950">
          Pourquoi un seul pack ?
        </h3>
        <p className="mt-2 text-[13px] text-slate-600 leading-relaxed">
          La <strong className="text-navy-900">Capacité ≤ 3,5 t</strong> est
          une formation courte et standardisée (105 h théorie). L'examen est
          national, sur QCM uniquement&nbsp;: un suivi rapproché ou des
          sessions présentielles n'apportent pas de valeur ajoutée
          significative.
        </p>
        <p className="mt-2 text-[13px] text-slate-600 leading-relaxed">
          Le <strong className="text-signal-700">pack Initial</strong> couvre
          100&nbsp;% du programme, avec correction automatique par IA des QR.
          C'est l'offre adaptée.
        </p>
      </div>
    </div>
  );
}

// =====================================================================
// packVariant — styles & contenu par pack (helper)
// =====================================================================
function packVariant(slug: PackSlug) {
  switch (slug) {
    case "initial":
      return {
        name: "Initial",
        tagline: "Autonome",
        title: "Préparation autonome, IA toujours présente.",
        subtitle:
          "Tous les cours, exercices et corrigés. L'IA évalue vos QR et examens blancs en temps réel.",
        features: [
          "Tous les cours détaillés",
          "Exercices et examens blancs illimités",
          (
            <span key="ai" className="inline-flex items-center gap-1.5">
              <Brain className="h-3 w-3 text-signal-600" />
              QR et examens corrigés par IA
            </span>
          ),
          "Certificat de fin de formation",
          "Accès illimité 18 mois",
        ] as React.ReactNode[],
        containerIdle:
          "bg-white border border-navy-100 hover:border-navy-200 shadow-soft",
        containerSelected:
          "bg-white border border-signal-500/55 shadow-raised",
        styleIdle: {},
        styleSelected: {
          boxShadow:
            "0 0 0 1px rgba(159, 226, 32, 0.55), 0 12px 32px -16px rgba(159,226,32,0.30)",
        },
        eyebrowColor: "text-signal-700",
        checkColor: "#609015",
        checkPill: "bg-signal-500 text-night-900",
        recapBg: "bg-ivory border-navy-100",
        recapIconBg: "bg-signal-100/60",
      };
    case "medium":
      return {
        name: "Medium",
        tagline: "Formateur dédié",
        title: "Avec un formateur attitré.",
        subtitle:
          "Tout l'Initial + une messagerie privée avec votre formateur dédié, du début à la fin.",
        features: [
          "Tout l'Initial inclus",
          (
            <span key="msg" className="inline-flex items-center gap-1.5">
              <MessageCircle className="h-3 w-3 text-brand-600" />
              Messagerie avec un formateur attitré
            </span>
          ),
          "Réponses sous 24 h ouvrées",
          "Corrections personnalisées sur demande",
        ] as React.ReactNode[],
        containerIdle:
          "bg-white border border-brand-100 hover:border-brand-200 shadow-soft",
        containerSelected:
          "bg-white border border-brand-500/55 shadow-raised",
        styleIdle: {},
        styleSelected: {
          boxShadow:
            "0 0 0 1px rgba(37, 48, 217, 0.55), 0 12px 32px -16px rgba(37,48,217,0.30)",
        },
        eyebrowColor: "text-brand-700",
        checkColor: "#2530D9",
        checkPill: "bg-brand-600 text-white",
        recapBg: "bg-brand-50/40 border-brand-100",
        recapIconBg: "bg-brand-100/60",
      };
    case "premium":
      return {
        name: "Premium",
        tagline: "Accompagnement complet",
        title: "Vous ne formez pas seul·e. Vous formez avec nous.",
        subtitle:
          "Sessions présentielles, accompagnement humain rapproché, accès Zoom : pour maximiser vos chances.",
        features: [
          "Tout le Medium inclus",
          (
            <span key="live" className="inline-flex items-center gap-1.5">
              <Users className="h-3 w-3" style={{ color: "#92400E" }} />
              Sessions présentielles en salle
            </span>
          ),
          (
            <span key="zoom" className="inline-flex items-center gap-1.5">
              <GraduationCap className="h-3 w-3" style={{ color: "#92400E" }} />
              Accès Zoom pour suivre à distance
            </span>
          ),
          "Suivi rapproché avec votre formateur attitré",
          "Priorité sur les retours d'examen blanc",
        ] as React.ReactNode[],
        containerIdle:
          "bg-gradient-to-br from-amber-50/60 via-white to-white border border-amber-200 hover:border-amber-300 shadow-raised",
        containerSelected:
          "bg-gradient-to-br from-amber-50/80 via-white to-white border border-amber-400 shadow-float",
        styleIdle: {},
        styleSelected: {
          boxShadow:
            "0 0 0 1px rgba(245, 158, 11, 0.65), 0 16px 40px -16px rgba(161,98,7,0.30)",
        },
        eyebrowColor: "text-amber-700",
        checkColor: "#B45309",
        checkPill: "bg-amber-500 text-night-900",
        recapBg: "bg-amber-50/60 border-amber-200",
        recapIconBg: "bg-amber-100/70",
      };
  }
}
