import Link from "next/link";
import { getTranslations } from "next-intl/server";
import { SiteShell } from "@/components/site/site-shell";
import { listActivePackPrices } from "@/lib/pricing-server";
import { TESTIMONIALS } from "@/lib/testimonials-config";
import { FORMATIONS } from "@/lib/formations-config";
import { LEGAL } from "@/lib/legal-config";
import { PricingSection } from "./pricing-section";
import {
  ShieldCheck,
  Wallet,
  Trophy,
  Star,
  Quote,
  ArrowRight,
  Sparkles,
} from "lucide-react";

export const dynamic = "force-dynamic";

export const metadata = {
  title: "Tarifs et packs",
  alternates: { canonical: "/tarifs" },
  description: `Trois packs (Initial, Medium, Premium) pour toutes nos formations transport. Achat unique, sans engagement. Financement CPF, OPCO, employeur, France Travail.`,
};

interface PageProps {
  searchParams?: { formation?: string };
}

export default async function TarifsPage({ searchParams }: PageProps) {
  const t = await getTranslations("tarifs");
  const prices = await listActivePackPrices();
  const defaultFormationSlug = searchParams?.formation;

  // Sélection des 4 meilleurs témoignages (4-5 étoiles)
  const top = TESTIMONIALS.filter((t) => t.rating >= 4).slice(0, 4);

  return (
    <SiteShell>
      {/* Hero dark */}
      <section id="main-content" tabIndex={-1} className="relative px-6 pt-24 pb-12 md:pt-32 md:pb-16 overflow-hidden">
        {/* Halo radial signal-lime */}
        <div
          aria-hidden
          className="absolute inset-0 pointer-events-none opacity-60"
          style={{
            background:
              "radial-gradient(ellipse 80% 50% at 50% 0%, rgba(159, 226, 32, 0.10) 0%, transparent 60%)",
          }}
        />
        {/* Grille tech subtile */}
        <div
          aria-hidden
          className="absolute inset-0 pointer-events-none bg-grid-night opacity-30"
          style={{ backgroundSize: "44px 44px" }}
        />

        <div className="relative max-w-6xl mx-auto">
          <div className="max-w-3xl">
            <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-white/[0.06] border border-white/10 mb-7">
              <Sparkles className="h-3.5 w-3.5 text-signal-400" />
              <span className="text-[12px] font-semibold tracking-wide text-white/85">
                {t("qualiopiBadge", { rncp: LEGAL.rncpCode })}
              </span>
            </div>

            <h1
              className="font-display text-5xl md:text-6xl lg:text-7xl font-semibold text-white tracking-tight leading-[1.02]"
              style={{ letterSpacing: "-0.03em" }}
            >
              {t("heroTitle1")}
              <br />
              <span className="italic font-normal text-signal-400">
                {t("heroTitle2")}
              </span>
            </h1>

            <p className="mt-7 text-lg md:text-xl text-white/70 leading-relaxed max-w-2xl">
              {t("heroSubtitle")}{" "}
              <strong className="text-white">{t("heroSubtitleStrong")}</strong>
              {t("heroSubtitleAfter")}
            </p>

            <div className="mt-10 flex flex-wrap items-center gap-3">
              <a
                href="#pricing-heading"
                className="group inline-flex items-center gap-2 px-5 py-3 rounded-xl text-sm font-semibold bg-signal-500 text-night-900 transition-[transform,background-color] duration-200 ease-out hover:bg-signal-400 active:scale-[0.98] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/80 focus-visible:ring-offset-2 focus-visible:ring-offset-night motion-reduce:transition-none"
              >
                {t("ctaSeePacks")}
                <ArrowRight className="h-4 w-4 transition-transform duration-200 ease-out group-hover:translate-x-0.5 motion-reduce:transition-none" />
              </a>
              <Link
                href="/financements"
                className="inline-flex items-center gap-2 px-5 py-3 rounded-xl text-sm font-semibold bg-white/[0.06] text-white border border-white/10 transition-[transform,background-color,border-color] duration-200 ease-out hover:bg-white/[0.10] hover:border-white/20 active:scale-[0.98] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/80 focus-visible:ring-offset-2 focus-visible:ring-offset-night motion-reduce:transition-none"
              >
                {t("ctaFinancing")}
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Packs (cœur de la page) */}
      <PricingSection
        prices={prices}
        defaultFormationSlug={defaultFormationSlug}
      />

      {/* Bande garanties — 3 cartes différentes (pas grid identique) */}
      <section className="relative px-6 py-20 bg-white/[0.02] border-y border-white/5">
        <div className="max-w-6xl mx-auto">
          <div className="text-[11px] font-bold uppercase tracking-[0.2em] text-signal-400 mb-3">
            {t("whyEyebrow")}
          </div>
          <h2
            className="font-display text-3xl md:text-4xl font-semibold text-white tracking-tight max-w-2xl"
            style={{ letterSpacing: "-0.02em" }}
          >
            {t("whyTitle")}
          </h2>

          <div className="mt-12 grid lg:grid-cols-3 gap-5 md:gap-6">
            {/* Garantie 1 — Qualiopi (avec numéro mono) */}
            <article className="rounded-2xl bg-white/[0.04] border border-white/10 p-7">
              <div className="flex items-center gap-3 mb-5">
                <div className="h-10 w-10 rounded-xl bg-signal-500/15 border border-signal-500/30 text-signal-400 flex items-center justify-center">
                  <ShieldCheck className="h-5 w-5" />
                </div>
                <div className="text-[10px] uppercase tracking-[0.18em] font-bold text-white/60">
                  {t("guarantee1Eyebrow")}
                </div>
              </div>
              <div className="font-display text-xl text-white font-semibold mb-1">
                {t("guarantee1Title")}
              </div>
              <div className="text-[13px] text-white/55 font-mono">
                {LEGAL.qualiopiNumber}
              </div>
              <p className="mt-4 text-[14.5px] text-white/70 leading-relaxed">
                {t("guarantee1Body")}
              </p>
            </article>

            {/* Garantie 2 — Financements (avec CTA inline) */}
            <article className="rounded-2xl bg-white/[0.04] border border-white/10 p-7">
              <div className="flex items-center gap-3 mb-5">
                <div className="h-10 w-10 rounded-xl bg-signal-500/15 border border-signal-500/30 text-signal-400 flex items-center justify-center">
                  <Wallet className="h-5 w-5" />
                </div>
                <div className="text-[10px] uppercase tracking-[0.18em] font-bold text-white/60">
                  {t("guarantee2Eyebrow")}
                </div>
              </div>
              <div className="font-display text-xl text-white font-semibold mb-3">
                {t("guarantee2Title")}
              </div>
              <p className="text-[14.5px] text-white/70 leading-relaxed mb-3">
                {t("guarantee2Body")}
              </p>
              <Link
                href="/financements"
                className="group inline-flex items-center gap-1 text-[13px] font-semibold text-signal-400 hover:text-signal-300 transition-colors duration-200 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-signal-500/70"
              >
                {t("guarantee2Cta")}
                <ArrowRight className="h-3 w-3 transition-transform duration-200 ease-out group-hover:translate-x-0.5 motion-reduce:transition-none" />
              </Link>
            </article>

            {/* Garantie 3 — Garantie réussite (palette dorée pour différencier) */}
            <article
              className="rounded-2xl border p-7 relative overflow-hidden"
              style={{
                background:
                  "linear-gradient(160deg, rgba(245, 158, 11, 0.10) 0%, rgba(11, 15, 36, 0.6) 100%)",
                borderColor: "rgba(245, 158, 11, 0.25)",
              }}
            >
              <div className="flex items-center gap-3 mb-5">
                <div
                  className="h-10 w-10 rounded-xl border flex items-center justify-center"
                  style={{
                    background: "rgba(245, 158, 11, 0.12)",
                    borderColor: "rgba(245, 158, 11, 0.35)",
                    color: "#FCD34D",
                  }}
                >
                  <Trophy className="h-5 w-5" />
                </div>
                <div
                  className="text-[10px] uppercase tracking-[0.18em] font-bold"
                  style={{ color: "rgba(252, 211, 77, 0.7)" }}
                >
                  {t("guarantee3Eyebrow")}
                </div>
              </div>
              <div
                className="font-display text-xl font-semibold mb-1"
                style={{ color: "#FCD34D" }}
              >
                {t("guarantee3Title")}
              </div>
              <p className="mt-4 text-[14.5px] text-white/75 leading-relaxed">
                {t("guarantee3Body")}
              </p>
            </article>
          </div>
        </div>
      </section>

      {/* Témoignages */}
      <TestimonialsSection testimonials={top} t={t} />

      {/* CTA final */}
      <section className="relative px-6 py-24 md:py-32 text-center overflow-hidden">
        <div
          aria-hidden
          className="absolute inset-0 pointer-events-none opacity-60"
          style={{
            background:
              "radial-gradient(ellipse 60% 50% at 50% 100%, rgba(245, 158, 11, 0.08) 0%, transparent 60%)",
          }}
        />
        <div className="relative max-w-3xl mx-auto">
          <h2
            className="font-display text-4xl md:text-5xl font-semibold text-white tracking-tight"
            style={{ letterSpacing: "-0.025em", lineHeight: 1.1 }}
          >
            {t("finalCtaTitle")}
          </h2>
          <p className="mt-5 text-lg text-white/65 leading-relaxed">
            {t("finalCtaBody")}
          </p>
          <div className="mt-10 flex flex-wrap items-center justify-center gap-3">
            <Link
              href="/formations"
              className="group inline-flex items-center gap-2 px-6 py-3.5 rounded-xl text-sm font-semibold bg-signal-500 text-night-900 transition-[transform,background-color] duration-200 ease-out hover:bg-signal-400 active:scale-[0.98] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/80 focus-visible:ring-offset-2 focus-visible:ring-offset-night motion-reduce:transition-none"
            >
              {t("finalCtaChoose")}
              <ArrowRight className="h-4 w-4 transition-transform duration-200 ease-out group-hover:translate-x-0.5 motion-reduce:transition-none" />
            </Link>
            <Link
              href="/contact"
              className="inline-flex items-center gap-2 px-6 py-3.5 rounded-xl text-sm font-semibold bg-white/[0.06] text-white border border-white/10 transition-[transform,background-color,border-color] duration-200 ease-out hover:bg-white/[0.10] hover:border-white/20 active:scale-[0.98] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/80 focus-visible:ring-offset-2 focus-visible:ring-offset-night motion-reduce:transition-none"
            >
              {t("finalCtaAdvisor")}
            </Link>
          </div>
        </div>
      </section>
    </SiteShell>
  );
}

// =====================================================================
// Section Témoignages
// =====================================================================
type TarifsT = Awaited<ReturnType<typeof getTranslations<"tarifs">>>;

function TestimonialsSection({
  testimonials,
  t,
}: {
  testimonials: typeof TESTIMONIALS;
  t: TarifsT;
}) {
  if (testimonials.length === 0) return null;
  return (
    <section className="relative px-6 py-20 md:py-28">
      <div className="max-w-6xl mx-auto">
        <div className="text-[11px] font-bold uppercase tracking-[0.2em] text-signal-400 mb-3">
          {t("testimonialsEyebrow")}
        </div>
        <h2
          className="font-display text-3xl md:text-4xl font-semibold text-white tracking-tight max-w-2xl"
          style={{ letterSpacing: "-0.02em" }}
        >
          {t("testimonialsTitle1")}{" "}
          <span className="italic font-normal text-white/55">
            {t("testimonialsTitle2")}
          </span>
        </h2>

        <div className="mt-12 grid md:grid-cols-2 gap-5 md:gap-6">
          {testimonials.map((t, i) => {
            const formation = t.formationSlug
              ? FORMATIONS.find((f) => f.slug === t.formationSlug)
              : null;
            return (
              <article
                key={t.id}
                className={
                  "relative rounded-3xl border p-7 md:p-8 backdrop-blur-sm transition-colors hover:bg-white/[0.05] " +
                  (i === 0
                    ? "bg-white/[0.04] border-signal-500/15"
                    : "bg-white/[0.025] border-white/10")
                }
              >
                <Quote className="h-7 w-7 text-signal-400/40 mb-4" />
                <p className="text-[15.5px] text-white/85 leading-relaxed">
                  « {t.quote} »
                </p>
                <div className="mt-6 pt-6 border-t border-white/10 flex items-center justify-between gap-4">
                  <div className="min-w-0">
                    <div className="font-semibold text-white text-[14.5px]">
                      {t.name}
                    </div>
                    <div className="text-[13px] text-white/55 mt-0.5">
                      {[t.role, t.city].filter(Boolean).join(" · ")}
                    </div>
                  </div>
                  {formation && (
                    <span
                      className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md text-[11px] font-semibold whitespace-nowrap"
                      style={{
                        backgroundColor: `${formation.accent}20`,
                        color: formation.accent,
                        border: `1px solid ${formation.accent}40`,
                      }}
                    >
                      {formation.code}
                    </span>
                  )}
                </div>
                <div className="absolute top-7 right-7 flex gap-0.5">
                  {Array.from({ length: 5 }).map((_, j) => (
                    <Star
                      key={j}
                      className={
                        "h-3 w-3 " +
                        (j < t.rating
                          ? "fill-signal-400 text-signal-400"
                          : "text-white/15")
                      }
                    />
                  ))}
                </div>
              </article>
            );
          })}
        </div>

        <div className="mt-10 text-center">
          <Link
            href="/temoignages"
            className="group inline-flex items-center gap-1.5 text-sm font-semibold text-white/70 hover:text-white transition-colors duration-200 rounded-md focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/80"
          >
            {t("seeAllTestimonials")}
            <ArrowRight className="h-3.5 w-3.5 transition-transform duration-200 ease-out group-hover:translate-x-0.5 motion-reduce:transition-none" />
          </Link>
        </div>
      </div>
    </section>
  );
}
