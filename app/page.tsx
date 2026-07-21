import Link from "next/link";
import { getTranslations } from "next-intl/server";
import {
  ArrowRight,
  ShieldCheck,
  Sparkles,
  Users,
  Target,
  TrendingUp,
  MapPin,
  Phone,
  Mail,
} from "lucide-react";
import { Logo } from "@/components/ui/logo";
import { SiteMobileMenu } from "@/components/site/site-mobile-menu";
import { Crossroads } from "@/components/home/crossroads";
import { FaqSection, FAQ_ITEMS } from "@/components/home/faq";
import { JsonLd, faqSchema, localBusinessSchema } from "@/components/seo/json-ld";
import { FormationsCarousel } from "@/components/home/formations-carousel";
import { RecognizedBy } from "@/components/home/recognized-by";
import { LegalFooter } from "@/components/legal/legal-footer";
import { LEGAL } from "@/lib/legal-config";

type HomeT = Awaited<ReturnType<typeof getTranslations<"home">>>;

export const metadata = {
  // `absolute` : ne pas appliquer le template du layout (évite la marque
  // dupliquée « … · MA FORMATION TRANSPORT »).
  title: { absolute: `${LEGAL.brand} — L'école des pros du transport` },
  description:
    "Centre de formation spécialisé transport routier de marchandises et de voyageurs. GOTRM, ERTV, ECSR, FIMO/FCO, Taxi/VTC, capacités de transport. Certifié Qualiopi.",
  // Canonical racine. Next normalise en « …fr » (sans slash) via
  // metadataBase ; le sitemap est aligné sur cette même forme sans slash.
  alternates: { canonical: "/" },
};

export default async function HomePage() {
  const t = await getTranslations("home");
  return (
    <div className="min-h-screen bg-night text-white">
      <JsonLd schema={faqSchema(FAQ_ITEMS)} />
      <JsonLd schema={localBusinessSchema()} />
      <Header t={t} />
      {/* Landmark principal : navigation lecteur d'écran + cible du skip-link */}
      <main>
        <Hero t={t} />
        <RecognizedBy />
        <Pillars t={t} />
        <FormationsCarousel />
        <Experience t={t} />
        <Stats t={t} />
        <Testimonials />
        <Funding t={t} />
        <FaqSection />
        <FinalCTA t={t} />
      </main>
      <FooterContact t={t} />
      <LegalFooter variant="dark" />
    </div>
  );
}

/* =============================================================== HEADER */
function Header({ t }: { t: HomeT }) {
  return (
    <header className="sticky top-0 z-30 border-b border-white/5 bg-night/80 backdrop-blur-md">
      <div className="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
        <Link href="/">
          <Logo variant="light" size="sm" />
        </Link>
        <nav className="hidden md:flex items-center gap-7 text-sm font-medium text-white/70">
          <Link href="/formations" className="hover:text-white transition-colors duration-200 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/40">
            {t("navFormations")}
          </Link>
          <Link href="/ecole" className="hover:text-white transition-colors duration-200 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/40">
            {t("navSchool")}
          </Link>
          <Link href="/financements" className="hover:text-white transition-colors duration-200 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/40">
            {t("navFunding")}
          </Link>
          <Link href="/tarifs" className="hover:text-white transition-colors duration-200 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/40">
            {t("navPricing")}
          </Link>
          <Link href="/temoignages" className="hover:text-white transition-colors duration-200 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/40">
            {t("navTestimonials")}
          </Link>
          <Link href="/blog" className="hover:text-white transition-colors duration-200 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/40">
            Guides
          </Link>
          <Link href="/contact" className="hover:text-white transition-colors duration-200 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/40">
            {t("navContact")}
          </Link>
        </nav>
        <div className="flex items-center gap-3">
          {/* Même hiérarchie CTA que SiteShell : devis = bouton saillant. */}
          <Link
            href="/login"
            className="hidden md:inline text-sm text-white/70 hover:text-white transition-colors duration-200 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/40"
          >
            {t("studentSpace")}
          </Link>
          {/* Masqué < sm : le CTA devis est déjà dans le menu mobile et le
              hero ; à 2 lignes il débordait du header h-16 sur mobile. */}
          <Link
            href="/contact"
            className="hidden sm:inline-flex items-center gap-1.5 whitespace-nowrap rounded-xl bg-signal-500 text-night-900 px-4 py-2.5 text-sm font-semibold shadow-glow-signal transition-[transform,background-color] duration-200 ease-premium hover:bg-signal-400 active:scale-[0.98] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/70 focus-visible:ring-offset-2 focus-visible:ring-offset-night motion-reduce:transition-none"
          >
            {t("requestQuote")}
            <ArrowRight className="h-3.5 w-3.5" />
          </Link>
          <SiteMobileMenu />
        </div>
      </div>
    </header>
  );
}

/* =============================================================== HERO */
function Hero({ t }: { t: HomeT }) {
  // Stagger : 0ms (badge) → 80 → 160 → 240 → 320 → 400 (KPIs)
  const stagger = (delayMs: number) => ({
    animation: "fade-up 0.7s cubic-bezier(0.22, 1, 0.36, 1) both",
    animationDelay: `${delayMs}ms`,
  });

  // KPIs : uniquement des faits vérifiables. Pas de chiffres de cohorte
  // tant que lib/results-config.ts n'a rien de publié (source unique).
  const kpis = [
    { value: "8", label: t("kpiFormations") },
    { value: "100 %", label: t("kpiFunding") },
    { value: "24 h", label: t("kpiResponse") },
    { value: "Qualiopi", label: t("kpiQualiopi") },
  ];

  return (
    <section id="main-content" tabIndex={-1} className="relative overflow-hidden pt-14 pb-24 md:pt-24 md:pb-32 lg:pt-28 lg:pb-36">
      {/* Backgrounds — mesh signal + grille tech, masquée vers le bas */}
      <div className="absolute inset-0 bg-mesh-night opacity-95 pointer-events-none" />
      <div
        className="absolute inset-0 bg-grid-night opacity-30 pointer-events-none"
        style={{
          backgroundSize: "64px 64px",
          maskImage:
            "linear-gradient(to bottom, transparent 0%, black 18%, black 65%, transparent 100%)",
        }}
      />
      {/* Halo doux brand-signal en bas-gauche pour profondeur */}
      <div
        aria-hidden
        className="absolute -bottom-32 -left-24 h-[28rem] w-[28rem] rounded-full pointer-events-none"
        style={{
          background:
            "radial-gradient(circle, rgba(37,48,217,0.35) 0%, rgba(37,48,217,0) 60%)",
        }}
      />

      <div className="relative max-w-7xl mx-auto px-6 grid lg:grid-cols-[1.05fr_1fr] gap-14 lg:gap-10 items-center">
        {/* Texte */}
        <div className="text-center lg:text-left">
          {/* Badge */}
          <div
            style={stagger(0)}
            className="inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/[0.04] backdrop-blur px-3.5 py-1.5 text-[11px] font-medium tracking-wide text-white/75"
          >
            <span
              className="h-1.5 w-1.5 rounded-full bg-signal-400 animate-glow-pulse motion-reduce:animate-none"
              aria-hidden
            />
            {t("heroBadge")}
          </div>

          {/* H1 — Apple/Stripe scale, punch sur "Sérieusement." */}
          <h1
            style={stagger(80)}
            className="mt-6 font-display font-semibold text-white leading-[1.02] tracking-[-0.025em] text-[44px] sm:text-[56px] md:text-[68px] lg:text-[80px]"
          >
            {t("heroTitle1")}
            <span className="block mt-1.5 bg-gradient-to-r from-signal-300 via-signal-400 to-signal-500 bg-clip-text text-transparent">
              {t("heroTitle2")}
            </span>
          </h1>

          {/* Sous-titre — court, autoritaire */}
          <p
            style={stagger(160)}
            className="mt-7 text-base md:text-lg text-white/65 max-w-xl mx-auto lg:mx-0 leading-relaxed"
          >
            {t("heroSubtitle")}
          </p>

          {/* CTAs */}
          <div
            style={stagger(240)}
            className="mt-9 flex flex-wrap justify-center lg:justify-start gap-3"
          >
            <Link
              href="/formations"
              className="group relative inline-flex items-center gap-2 rounded-2xl bg-signal-500 text-night-900 px-6 py-3.5 text-[15px] font-semibold shadow-glow-signal transition-[transform,background-color] duration-200 ease-premium hover:bg-signal-400 hover:-translate-y-0.5 active:translate-y-0 active:scale-[0.98] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/70 focus-visible:ring-offset-2 focus-visible:ring-offset-night motion-reduce:transition-none motion-reduce:hover:translate-y-0"
            >
              {t("ctaDiscover")}
              <ArrowRight className="h-4 w-4 transition-transform duration-200 ease-premium group-hover:translate-x-0.5 motion-reduce:group-hover:translate-x-0" />
            </Link>
            <Link
              href="#experience"
              className="inline-flex items-center gap-2 rounded-2xl border border-white/15 bg-white/[0.03] backdrop-blur px-6 py-3.5 text-[15px] font-semibold text-white/90 transition-[transform,background-color,border-color] duration-200 ease-premium hover:bg-white/[0.07] hover:border-white/25 active:scale-[0.98] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/60 focus-visible:ring-offset-2 focus-visible:ring-offset-night motion-reduce:transition-none"
            >
              {t("ctaHow")}
            </Link>
          </div>

          {/* KPI strip — preuve sobre */}
          <dl
            style={stagger(400)}
            className="mt-12 grid grid-cols-2 sm:grid-cols-4 gap-x-6 gap-y-5 max-w-xl mx-auto lg:mx-0 border-t border-white/5 pt-7"
          >
            {kpis.map((k) => (
              <div key={k.label} className="text-center lg:text-left">
                <dt className="font-display text-2xl md:text-[28px] font-semibold text-white tracking-tight tabular-nums">
                  {k.value}
                </dt>
                <dd className="mt-1 text-[11px] uppercase tracking-[0.14em] text-white/50">
                  {k.label}
                </dd>
              </div>
            ))}
          </dl>
        </div>

        {/* Illustration — Carrefour 3D, fade-in léger */}
        <div className="relative" style={stagger(120)}>
          <div
            aria-hidden
            className="absolute inset-0 -z-10 rounded-[3rem]"
            style={{
              background:
                "radial-gradient(closest-side, rgba(159,226,32,0.10), rgba(159,226,32,0) 70%)",
            }}
          />
          <Crossroads />
        </div>
      </div>
    </section>
  );
}

/* =============================================================== PILLARS */
function Pillars({ t }: { t: HomeT }) {
  const items = [
    { icon: Target, title: t("pillar1Title"), desc: t("pillar1Desc") },
    { icon: TrendingUp, title: t("pillar2Title"), desc: t("pillar2Desc") },
    { icon: Users, title: t("pillar3Title"), desc: t("pillar3Desc") },
    { icon: ShieldCheck, title: t("pillar4Title"), desc: t("pillar4Desc") },
  ];
  return (
    <section className="py-20 md:py-28">
      <div className="max-w-6xl mx-auto px-6">
        <div className="text-center max-w-2xl mx-auto">
          <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-400">
            {t("pillarsEyebrowPrefix")} {LEGAL.brand}
          </span>
          <h2 className="mt-3 font-display text-3xl md:text-5xl font-semibold tracking-tight">
            {t("pillarsTitle1")}{" "}
            <span className="italic text-signal-400">{t("pillarsTitle2")}</span>.
          </h2>
        </div>

        <div className="mt-14 grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {items.map(({ icon: Icon, title, desc }) => (
            <div
              key={title}
              className="rounded-2xl border border-white/10 bg-white/[0.03] backdrop-blur-sm p-6 transition-[background-color,border-color] duration-200 ease-premium hover:border-signal-500/40 hover:bg-white/[0.05]"
            >
              <div className="h-11 w-11 rounded-xl bg-brand-600/20 border border-brand-500/30 text-signal-400 flex items-center justify-center">
                <Icon className="h-5 w-5" />
              </div>
              <h3 className="mt-5 font-display text-lg font-semibold">{title}</h3>
              <p className="mt-1.5 text-sm text-white/60 leading-relaxed">
                {desc}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* =============================================================== EXPERIENCE */
function Experience({ t }: { t: HomeT }) {
  const steps = [
    { n: "01", title: t("step1Title"), desc: t("step1Desc") },
    { n: "02", title: t("step2Title"), desc: t("step2Desc") },
    { n: "03", title: t("step3Title"), desc: t("step3Desc") },
    { n: "04", title: t("step4Title"), desc: t("step4Desc") },
  ];
  return (
    <section id="experience" className="py-20 md:py-28 scroll-mt-20">
      <div className="max-w-6xl mx-auto px-6">
        <div className="text-center max-w-2xl mx-auto">
          <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-400">
            {t("experienceEyebrow")}
          </span>
          <h2 className="mt-3 font-display text-3xl md:text-5xl font-semibold tracking-tight">
            {t("experienceTitle1")}{" "}
            <span className="italic text-signal-400">{t("experienceTitle2")}</span>
            {t("experienceTitle3")}
          </h2>
        </div>

        <div className="mt-14 grid md:grid-cols-2 lg:grid-cols-4 gap-4 relative">
          {/* Ligne pointillée derrière */}
          <div
            aria-hidden="true"
            className="hidden lg:block absolute top-8 left-12 right-12 h-px"
            style={{
              backgroundImage:
                "linear-gradient(to right, rgba(159,226,32,0.4) 0, rgba(159,226,32,0.4) 6px, transparent 6px, transparent 14px)",
              backgroundSize: "14px 1px",
            }}
          />

          {steps.map((s) => (
            <div
              key={s.n}
              className="relative rounded-2xl border border-white/10 bg-night-100 p-6"
            >
              <div className="h-12 w-12 rounded-xl bg-gradient-to-br from-signal-500 to-brand-500 text-night flex items-center justify-center font-display font-bold text-base">
                {s.n}
              </div>
              <h3 className="mt-5 font-display text-lg font-semibold">
                {s.title}
              </h3>
              <p className="mt-2 text-sm text-white/60 leading-relaxed">
                {s.desc}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* =============================================================== STATS */
function Stats({ t }: { t: HomeT }) {
  const stats = [
    { value: "8", label: t("statsLabel1") },
    { value: "100%", label: t("statsLabel2") },
    { value: "Qualiopi", label: t("statsLabel3") },
    { value: "Meaux", label: t("statsLabel4") },
  ];
  return (
    <section className="py-16 md:py-20 bg-gradient-to-b from-brand-950 to-night-300 border-y border-white/5">
      <div className="max-w-6xl mx-auto px-6 grid grid-cols-2 md:grid-cols-4 gap-8">
        {stats.map((s) => (
          <div key={s.label} className="text-center">
            <div className="font-display text-4xl md:text-5xl font-semibold tracking-tight bg-gradient-to-br from-signal-300 to-signal-500 bg-clip-text text-transparent">
              {s.value}
            </div>
            <div className="mt-2 text-xs uppercase tracking-[0.16em] text-white/50">
              {s.label}
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}

/* =============================================================== TESTIMONIALS */
// Les citations restent dans la langue d'origine (FR) — ce sont des
// témoignages réels de stagiaires. Seuls les chrome (eyebrow/titre) sont
// traduits. Si besoin de bilingue intégral, ajouter un champ quote_en au
// modèle de TESTIMONIALS.
function Testimonials() {
  const items = [
    {
      name: "Karim B.",
      role: "Stagiaire GOTRM, 2026",
      quote:
        "La plateforme est nickel, le suivi vraiment personnalisé. J'ai pu travailler le soir après le boulot. Examen passé du premier coup.",
    },
    {
      name: "Aïcha L.",
      role: "Capacité +3,5 t",
      quote:
        "J'ai créé mon entreprise de transport grâce à cette formation. L'équipe répond très vite, c'est rassurant pour un projet pareil.",
    },
    {
      name: "Jean-Marc D.",
      role: "FCO renouvellement",
      quote:
        "Le format mixte est top : la théorie en ligne, le pratique en centre. Ça change des journées de formation interminables.",
    },
  ];
  return (
    <section className="py-20 md:py-28">
      <div className="max-w-6xl mx-auto px-6">
        <div className="text-center max-w-2xl mx-auto">
          <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-400">
            Témoignages
          </span>
          <h2 className="mt-3 font-display text-3xl md:text-5xl font-semibold tracking-tight">
            Ils nous ont fait <span className="italic text-signal-400">confiance</span>.
          </h2>
        </div>

        <div className="mt-14 grid md:grid-cols-3 gap-4">
          {items.map((t) => (
            <figure
              key={t.name}
              className="rounded-2xl border border-white/10 bg-night-100 p-6 flex flex-col"
            >
              <div className="text-signal-400 font-display text-3xl leading-none">
                "
              </div>
              <blockquote className="mt-2 text-white/80 text-[15px] leading-relaxed flex-1">
                {t.quote}
              </blockquote>
              <figcaption className="mt-6 pt-5 border-t border-white/10">
                <div className="font-semibold text-white">{t.name}</div>
                <div className="text-xs text-white/50 mt-0.5">{t.role}</div>
              </figcaption>
            </figure>
          ))}
        </div>
      </div>
    </section>
  );
}

/* =============================================================== FUNDING */
function Funding({ t }: { t: HomeT }) {
  const items = [
    { label: t("fund1Label"), desc: t("fund1Desc") },
    { label: t("fund2Label"), desc: t("fund2Desc") },
    { label: t("fund3Label"), desc: t("fund3Desc") },
    { label: t("fund4Label"), desc: t("fund4Desc") },
    { label: t("fund5Label"), desc: t("fund5Desc") },
    { label: t("fund6Label"), desc: t("fund6Desc") },
  ];
  return (
    <section className="py-20 md:py-28 bg-white/[0.02] border-y border-white/5">
      <div className="max-w-6xl mx-auto px-6 grid lg:grid-cols-3 gap-10">
        <div>
          <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-400">
            {t("fundingEyebrow")}
          </span>
          <h2 className="mt-3 font-display text-3xl md:text-4xl font-semibold tracking-tight">
            {t("fundingTitle1")} <span className="italic text-signal-400">{t("fundingTitle2")}</span>.
          </h2>
          <p className="mt-4 text-white/70 leading-relaxed">
            {t("fundingBody")}
          </p>
          <Link
            href="/financements"
            className="mt-6 inline-flex items-center gap-1.5 text-sm font-medium text-signal-400 hover:text-signal-300"
          >
            {t("testEligibility")}
            <ArrowRight className="h-3.5 w-3.5" />
          </Link>
        </div>
        <div className="lg:col-span-2 grid sm:grid-cols-2 gap-3">
          {items.map((it) => (
            <div
              key={it.label}
              className="rounded-xl border border-white/10 bg-night-100 p-5"
            >
              <div className="font-medium text-white">{it.label}</div>
              <div className="mt-1 text-xs text-white/55">{it.desc}</div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* =============================================================== FINAL CTA */
function FinalCTA({ t }: { t: HomeT }) {
  return (
    <section className="py-20 md:py-28">
      <div className="max-w-4xl mx-auto px-6">
        <div className="relative overflow-hidden rounded-5xl bg-gradient-to-br from-brand-700 via-brand-600 to-brand-800 p-10 md:p-16 text-center shadow-glow-brand">
          <div className="absolute inset-0 bg-mesh-night opacity-50 pointer-events-none" />
          <div
            aria-hidden="true"
            className="absolute -top-20 -right-20 h-72 w-72 rounded-full bg-signal-500/20 blur-3xl"
          />

          <div className="relative">
            <span className="inline-flex items-center gap-1.5 rounded-full bg-white/10 border border-white/20 px-3 py-1 text-xs font-medium">
              <Sparkles className="w-3.5 h-3.5 text-signal-400" />
              {t("finalCtaBadge")}
            </span>
            <h2 className="mt-5 font-display text-3xl md:text-5xl font-semibold tracking-tight">
              {t("finalCtaTitle1")}{" "}
              <span className="italic text-signal-400">{t("finalCtaTitle2")}</span>.
            </h2>
            <p className="mt-4 text-white/80 max-w-xl mx-auto">
              {t("finalCtaBody")}
            </p>
            <div className="mt-8 flex flex-wrap justify-center gap-3">
              <Link
                href="/contact"
                className="group inline-flex items-center gap-2 rounded-2xl bg-signal-500 text-night px-6 py-3.5 text-sm font-semibold shadow-glow-signal transition-[transform,background-color] duration-200 ease-premium hover:bg-signal-400 active:scale-[0.98] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/70 focus-visible:ring-offset-2 focus-visible:ring-offset-night motion-reduce:transition-none"
              >
                {t("ctaBeCalled")}
                <ArrowRight className="h-4 w-4 transition-transform duration-200 ease-premium group-hover:translate-x-0.5 motion-reduce:transition-none" />
              </Link>
              <Link
                href="/formations"
                className="inline-flex items-center gap-2 rounded-2xl border border-white/20 bg-white/5 backdrop-blur px-6 py-3.5 text-sm font-semibold transition-[transform,background-color] duration-200 ease-premium hover:bg-white/10 active:scale-[0.98] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/60 focus-visible:ring-offset-2 focus-visible:ring-offset-night motion-reduce:transition-none"
              >
                {t("ctaSeeFormations")}
              </Link>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

/* =============================================================== FOOTER CONTACT */
function FooterContact({ t }: { t: HomeT }) {
  return (
    <section className="bg-night border-t border-white/5">
      <div className="max-w-7xl mx-auto px-6 py-16 grid md:grid-cols-3 gap-10">
        <div className="md:col-span-1">
          <Logo variant="light" size="md" />
          <p className="mt-4 text-sm text-white/60 leading-relaxed">
            {LEGAL.shortDescription}
          </p>
        </div>
        <div className="md:col-span-1">
          <div className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-400 mb-3">
            {t("centerLabel")}
          </div>
          <div className="space-y-2 text-sm text-white/70">
            <div className="flex items-start gap-2.5">
              <MapPin className="h-4 w-4 text-signal-400 shrink-0 mt-0.5" />
              <span>
                {LEGAL.address.street}
                <br />
                {LEGAL.address.postalCode} {LEGAL.address.city}
              </span>
            </div>
            <a
              href={`mailto:${LEGAL.email}`}
              className="flex items-center gap-2.5 hover:text-white"
            >
              <Mail className="h-4 w-4 text-signal-400 shrink-0" />
              {LEGAL.email}
            </a>
            <a
              href={`tel:${LEGAL.phone.replace(/\s/g, "")}`}
              className="flex items-center gap-2.5 hover:text-white"
            >
              <Phone className="h-4 w-4 text-signal-400 shrink-0" />
              {LEGAL.phone}
            </a>
          </div>
        </div>
        <div className="md:col-span-1">
          <div className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-400 mb-3">
            {t("sitemap")}
          </div>
          <ul className="space-y-1.5 text-sm text-white/70">
            <li>
              <Link href="/formations" className="hover:text-white transition-colors duration-200 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/40">
                {t("footerAllFormations")}
              </Link>
            </li>
            <li>
              <Link href="/ecole" className="hover:text-white transition-colors duration-200 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/40">
                {t("navSchool")}
              </Link>
            </li>
            <li>
              <Link href="/financements" className="hover:text-white transition-colors duration-200 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/40">
                {t("navFunding")}
              </Link>
            </li>
            <li>
              <Link href="/tarifs" className="hover:text-white transition-colors duration-200 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/40">
                {t("navPricing")}
              </Link>
            </li>
            <li>
              <Link href="/temoignages" className="hover:text-white transition-colors duration-200 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/40">
                {t("navTestimonials")}
              </Link>
            </li>
            <li>
              <Link href="/contact" className="hover:text-white transition-colors duration-200 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/40">
                {t("footerContact")}
              </Link>
            </li>
            <li>
              <Link href="/login" className="hover:text-white transition-colors duration-200 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/40">
                {t("studentSpace")}
              </Link>
            </li>
          </ul>
        </div>
      </div>
    </section>
  );
}
