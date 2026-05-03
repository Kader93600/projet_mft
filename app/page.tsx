import Link from "next/link";
import {
  ArrowRight,
  Award,
  CheckCircle2,
  ShieldCheck,
  Sparkles,
  Users,
  Target,
  TrendingUp,
  MapPin,
  Phone,
  Mail,
  Truck,
  Bus,
  GraduationCap,
  Car,
  Briefcase,
  Package,
} from "lucide-react";
import { Logo } from "@/components/ui/logo";
import { Crossroads } from "@/components/home/crossroads";
import { FaqSection } from "@/components/home/faq";
import { FormationsConstellation } from "@/components/home/formations-constellation";
import { RecognizedBy } from "@/components/home/recognized-by";
import { LegalFooter } from "@/components/legal/legal-footer";
import { LEGAL } from "@/lib/legal-config";
import { FORMATIONS, listByCategory } from "@/lib/formations-config";

export const metadata = {
  title: `${LEGAL.brand} — L'école des pros du transport`,
  description:
    "Centre de formation spécialisé transport routier de marchandises et de voyageurs. GOTRM, ERTV, ECSR, FIMO/FCO, Taxi/VTC, capacités de transport. Certifié Qualiopi.",
};

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

export default function HomePage() {
  return (
    <div className="min-h-screen bg-night text-white">
      <Header />
      <Hero />
      <RecognizedBy />
      <Pillars />
      <FormationsConstellation />
      <Experience />
      <Stats />
      <Testimonials />
      <Funding />
      <FaqSection />
      <FinalCTA />
      <FooterContact />
      <LegalFooter variant="dark" />
    </div>
  );
}

/* =============================================================== HEADER */
function Header() {
  return (
    <header className="sticky top-0 z-30 border-b border-white/5 bg-night/80 backdrop-blur-md">
      <div className="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
        <Link href="/">
          <Logo variant="light" size="sm" />
        </Link>
        <nav className="hidden md:flex items-center gap-7 text-sm font-medium text-white/70">
          <Link href="/formations" className="hover:text-white transition">
            Formations
          </Link>
          <Link href="/ecole" className="hover:text-white transition">
            L'école
          </Link>
          <Link href="/financements" className="hover:text-white transition">
            Financements
          </Link>
          <Link href="/contact" className="hover:text-white transition">
            Contact
          </Link>
        </nav>
        <div className="flex items-center gap-3">
          <Link
            href="/contact"
            className="hidden md:inline text-sm text-white/70 hover:text-white transition"
          >
            Demander un devis
          </Link>
          <Link
            href="/login"
            className="inline-flex items-center gap-1.5 rounded-xl bg-signal-500 text-night-900 px-4 py-2 text-sm font-semibold hover:bg-signal-400 transition shadow-glow-signal"
          >
            Espace stagiaire
            <ArrowRight className="h-3.5 w-3.5" />
          </Link>
        </div>
      </div>
    </header>
  );
}

/* =============================================================== HERO */
function Hero() {
  // Stagger : 0ms (badge) → 80 → 160 → 240 → 320 → 400 (KPIs)
  const stagger = (delayMs: number) => ({
    animation: "fade-up 0.7s cubic-bezier(0.22, 1, 0.36, 1) both",
    animationDelay: `${delayMs}ms`,
  });

  const kpis = [
    { value: "8", label: "formations" },
    { value: "1 200+", label: "stagiaires formés" },
    { value: "87 %", label: "taux de réussite" },
    { value: "Qualiopi", label: "certifié" },
  ];

  return (
    <section className="relative overflow-hidden pt-14 pb-24 md:pt-24 md:pb-32 lg:pt-28 lg:pb-36">
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
            Certifié Qualiopi · 8 formations transport
          </div>

          {/* H1 — Apple/Stripe scale, punch sur "Sérieusement." */}
          <h1
            style={stagger(80)}
            className="mt-6 font-display font-semibold text-white leading-[1.02] tracking-[-0.025em] text-[44px] sm:text-[56px] md:text-[68px] lg:text-[80px]"
          >
            Formez-vous au transport.
            <span className="block mt-1.5 bg-gradient-to-r from-signal-300 via-signal-400 to-signal-500 bg-clip-text text-transparent">
              Sérieusement.
            </span>
          </h1>

          {/* Sous-titre — court, autoritaire */}
          <p
            style={stagger(160)}
            className="mt-7 text-base md:text-lg text-white/65 max-w-xl mx-auto lg:mx-0 leading-relaxed"
          >
            Préparation aux titres pros et certifications du transport
            routier. Plateforme premium, formateurs experts, financements
            CPF · OPCO · France Travail.
          </p>

          {/* CTAs */}
          <div
            style={stagger(240)}
            className="mt-9 flex flex-wrap justify-center lg:justify-start gap-3"
          >
            <Link
              href="/formations"
              className="group relative inline-flex items-center gap-2 rounded-2xl bg-signal-500 text-night-900 px-6 py-3.5 text-[15px] font-semibold transition hover:bg-signal-400 hover:-translate-y-0.5 shadow-glow-signal motion-reduce:hover:translate-y-0"
            >
              Découvrir les formations
              <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-0.5 motion-reduce:group-hover:translate-x-0" />
            </Link>
            <Link
              href="#experience"
              className="inline-flex items-center gap-2 rounded-2xl border border-white/15 bg-white/[0.03] backdrop-blur px-6 py-3.5 text-[15px] font-semibold text-white/90 hover:bg-white/[0.07] hover:border-white/25 transition"
            >
              Comment ça marche
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
function Pillars() {
  const items = [
    {
      icon: Target,
      title: "Expertise métier",
      desc: "Formateurs issus du terrain, contenus mis à jour selon les évolutions réglementaires (R561, AETR, Loi LOM).",
    },
    {
      icon: TrendingUp,
      title: "Taux de réussite",
      desc: "Une pédagogie orientée résultat : examens blancs en conditions réelles et corrections personnalisées.",
    },
    {
      icon: Users,
      title: "Accompagnement humain",
      desc: "Un coach pédagogique dédié, des sessions live mensuelles et une hotline sous 24h ouvrées.",
    },
    {
      icon: ShieldCheck,
      title: "Plateforme moderne",
      desc: "Application accessible 24/7, fiches PDF, vidéos, suivi de progression et certificats officiels.",
    },
  ];
  return (
    <section className="py-20 md:py-28">
      <div className="max-w-6xl mx-auto px-6">
        <div className="text-center max-w-2xl mx-auto">
          <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-400">
            Pourquoi {LEGAL.brand}
          </span>
          <h2 className="mt-3 font-display text-3xl md:text-5xl font-semibold tracking-tight">
            La rigueur d'un centre,{" "}
            <span className="italic text-signal-400">l'agilité du digital</span>.
          </h2>
        </div>

        <div className="mt-14 grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {items.map(({ icon: Icon, title, desc }) => (
            <div
              key={title}
              className="rounded-2xl border border-white/10 bg-white/[0.03] backdrop-blur-sm p-6 hover:border-signal-500/40 hover:bg-white/[0.05] transition"
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

/* =============================================================== CATALOG */
function FormationsCatalog() {
  const groups = listByCategory().filter((g) => g.items.length > 0);
  return (
    <section id="formations" className="py-20 md:py-28 bg-white/[0.02] border-y border-white/5">
      <div className="max-w-7xl mx-auto px-6">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div className="max-w-2xl">
            <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-400">
              Catalogue
            </span>
            <h2 className="mt-3 font-display text-3xl md:text-5xl font-semibold tracking-tight">
              Toutes nos formations transport.
            </h2>
            <p className="mt-3 text-white/70 text-lg">
              Marchandises, voyageurs, enseignement, capacités professionnelles
              — choisissez votre voie.
            </p>
          </div>
          <Link
            href="/formations"
            className="inline-flex items-center gap-1.5 text-sm font-medium text-signal-400 hover:text-signal-300"
          >
            Voir le catalogue complet
            <ArrowRight className="h-3.5 w-3.5" />
          </Link>
        </div>

        <div className="mt-12 space-y-12">
          {groups.map((group) => (
            <div key={group.key}>
              <h3 className="font-display text-xl font-semibold text-white/90 mb-1">
                {group.label}
              </h3>
              <p className="text-sm text-white/50 mb-5">{group.description}</p>
              <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
                {group.items.map((f) => {
                  const Icon = ICONS[f.iconName] ?? Truck;
                  return (
                    <Link
                      key={f.slug}
                      href={`/formations/${f.slug}`}
                      className="group rounded-2xl border border-white/10 bg-night-100 p-6 hover:border-signal-500/40 hover:-translate-y-1 transition-all relative overflow-hidden"
                    >
                      {/* Glow accent */}
                      <div
                        aria-hidden="true"
                        className="absolute -top-12 -right-12 h-32 w-32 rounded-full opacity-20 group-hover:opacity-40 transition-opacity blur-2xl"
                        style={{ backgroundColor: f.accent ?? "#9FE220" }}
                      />

                      <div className="relative">
                        <div
                          className="h-11 w-11 rounded-xl flex items-center justify-center"
                          style={{
                            backgroundColor: `${f.accent ?? "#9FE220"}22`,
                            border: `1px solid ${f.accent ?? "#9FE220"}55`,
                          }}
                        >
                          <Icon
                            className="h-5 w-5"
                            style={{ color: f.accent ?? "#9FE220" }}
                          />
                        </div>
                        <div className="mt-4 text-[11px] font-semibold uppercase tracking-[0.16em] text-white/50">
                          {f.code}
                        </div>
                        <h4 className="mt-1 font-display text-lg font-semibold leading-tight">
                          {f.title}
                        </h4>
                        <p className="mt-2 text-sm text-white/60 line-clamp-2">
                          {f.tagline}
                        </p>
                        <div className="mt-5 flex flex-wrap gap-1.5">
                          {f.funding.slice(0, 3).map((k) => (
                            <span
                              key={k}
                              className="text-[10px] uppercase tracking-wider px-2 py-0.5 rounded-md bg-white/5 border border-white/10 text-white/60"
                            >
                              {k}
                            </span>
                          ))}
                        </div>
                        <div className="mt-5 inline-flex items-center gap-1.5 text-sm font-medium text-signal-400 group-hover:gap-3 transition-all">
                          Découvrir
                          <ArrowRight className="h-3.5 w-3.5" />
                        </div>
                      </div>
                    </Link>
                  );
                })}
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* =============================================================== EXPERIENCE */
function Experience() {
  const steps = [
    {
      n: "01",
      title: "Vous choisissez",
      desc: "Sélectionnez la formation alignée avec votre projet professionnel — un conseiller vous appelle sous 24 h.",
    },
    {
      n: "02",
      title: "On monte le dossier",
      desc: "Devis, convention de formation, dossier de financement OPCO/CPF/France Travail. Vous n'avez qu'à signer.",
    },
    {
      n: "03",
      title: "Vous apprenez",
      desc: "Plateforme 24/7, sessions live, coach pédagogique dédié. Examens blancs en conditions réelles.",
    },
    {
      n: "04",
      title: "Vous réussissez",
      desc: "Préparation à l'examen final, remise du titre ou de l'attestation. On reste à vos côtés ensuite.",
    },
  ];
  return (
    <section id="experience" className="py-20 md:py-28 scroll-mt-20">
      <div className="max-w-6xl mx-auto px-6">
        <div className="text-center max-w-2xl mx-auto">
          <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-400">
            Parcours stagiaire
          </span>
          <h2 className="mt-3 font-display text-3xl md:text-5xl font-semibold tracking-tight">
            Une trajectoire <span className="italic text-signal-400">claire</span>,
            de l'envie au diplôme.
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
function Stats() {
  const stats = [
    { value: "8", label: "Formations transport" },
    { value: "100%", label: "À distance ou en présentiel" },
    { value: "Qualiopi", label: "Certifié" },
    { value: "Meaux", label: "Centre en Île-de-France" },
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
function Funding() {
  const items = [
    { label: "CPF / Mon Compte Formation", desc: "Mobilisez vos droits acquis." },
    { label: "OPCO", desc: "Prise en charge employeur via votre OPCO." },
    { label: "France Travail", desc: "Aide individuelle à la formation (AIF)." },
    { label: "Auto-financement", desc: "Paiement en 3 ou 4 fois sans frais." },
    { label: "Transitions Pro", desc: "Pour les projets de reconversion." },
    { label: "Plan employeur", desc: "Inscription dans le plan de développement." },
  ];
  return (
    <section className="py-20 md:py-28 bg-white/[0.02] border-y border-white/5">
      <div className="max-w-6xl mx-auto px-6 grid lg:grid-cols-3 gap-10">
        <div>
          <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-400">
            Financements
          </span>
          <h2 className="mt-3 font-display text-3xl md:text-4xl font-semibold tracking-tight">
            Tous les dispositifs <span className="italic text-signal-400">acceptés</span>.
          </h2>
          <p className="mt-4 text-white/70 leading-relaxed">
            Nos formations sont éligibles à l'ensemble des dispositifs de
            financement professionnels. Notre équipe vous accompagne dans le
            montage du dossier.
          </p>
          <Link
            href="/financements"
            className="mt-6 inline-flex items-center gap-1.5 text-sm font-medium text-signal-400 hover:text-signal-300"
          >
            Tester mon éligibilité
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
function FinalCTA() {
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
              Démarrez votre projet
            </span>
            <h2 className="mt-5 font-display text-3xl md:text-5xl font-semibold tracking-tight">
              Trouvons ensemble{" "}
              <span className="italic text-signal-400">votre formation</span>.
            </h2>
            <p className="mt-4 text-white/80 max-w-xl mx-auto">
              Un conseiller vous rappelle sous 24 h ouvrées pour étudier votre
              projet et votre éligibilité au financement.
            </p>
            <div className="mt-8 flex flex-wrap justify-center gap-3">
              <Link
                href="/contact"
                className="inline-flex items-center gap-2 rounded-2xl bg-signal-500 text-night px-6 py-3.5 text-sm font-semibold hover:bg-signal-400 shadow-glow-signal transition"
              >
                Être rappelé(e)
                <ArrowRight className="h-4 w-4" />
              </Link>
              <Link
                href="/formations"
                className="inline-flex items-center gap-2 rounded-2xl border border-white/20 bg-white/5 backdrop-blur px-6 py-3.5 text-sm font-semibold hover:bg-white/10 transition"
              >
                Voir les formations
              </Link>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

/* =============================================================== FOOTER CONTACT */
function FooterContact() {
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
            Centre de formation
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
            Plan du site
          </div>
          <ul className="space-y-1.5 text-sm text-white/70">
            <li>
              <Link href="/formations" className="hover:text-white">
                Toutes les formations
              </Link>
            </li>
            <li>
              <Link href="/ecole" className="hover:text-white">
                L'école
              </Link>
            </li>
            <li>
              <Link href="/financements" className="hover:text-white">
                Financements
              </Link>
            </li>
            <li>
              <Link href="/contact" className="hover:text-white">
                Nous contacter
              </Link>
            </li>
            <li>
              <Link href="/login" className="hover:text-white">
                Espace stagiaire
              </Link>
            </li>
          </ul>
        </div>
      </div>
    </section>
  );
}
