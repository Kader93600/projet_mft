import Link from "next/link";
import { notFound } from "next/navigation";
import {
  ArrowRight,
  ArrowLeft,
  Clock,
  Target,
  CheckCircle2,
  Layers,
  GraduationCap,
  Users,
  Sparkles,
  Truck,
  Bus,
  Car,
  Briefcase,
  Package,
  Award,
  ShieldCheck,
  ClipboardCheck,
  TrendingUp,
  HelpCircle,
} from "lucide-react";
import { SiteShell } from "@/components/site/site-shell";
import { JsonLd, courseSchema, breadcrumbSchema } from "@/components/seo/json-ld";
import { formationFaq, faqSchema } from "@/lib/formation-faq";
import {
  FORMATIONS,
  findFormation,
  FUNDING_LABELS,
} from "@/lib/formations-config";
import { LEGAL } from "@/lib/legal-config";

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
  distanciel: "À distance (FOAD)",
  mixte: "Mixte présentiel + distanciel",
};

export const revalidate = 600;

export async function generateStaticParams() {
  return FORMATIONS.map((f) => ({ slug: f.slug }));
}

export async function generateMetadata({
  params,
}: {
  params: { slug: string };
}) {
  const f = findFormation(params.slug);
  if (!f) return { title: "Formation introuvable" };

  // Titre SEO dédié (title.absolute → PAS de suffixe marque, évite la
  // troncature en SERP) ; fallback sur l'ancien format si non renseigné.
  const seoTitle = f.seoTitle ?? `${f.code} — ${f.title}`;
  const seoDescription = f.seoDescription ?? f.tagline;
  const canonicalPath = `/formations/${f.slug}`;

  return {
    title: { absolute: seoTitle },
    description: seoDescription,
    alternates: { canonical: canonicalPath },
    // Open Graph différencié par fiche (sinon les 8 formations partagent
    // le même aperçu social). L'image OG dynamique (opengraph-image.tsx)
    // est reprise avec un alt spécifique à la formation.
    openGraph: {
      type: "website",
      title: seoTitle,
      description: seoDescription,
      url: canonicalPath,
      images: [
        {
          url: `${canonicalPath}/opengraph-image`,
          width: 1200,
          height: 630,
          alt: `${f.code} — ${f.title}`,
        },
      ],
    },
    twitter: {
      card: "summary_large_image",
      title: seoTitle,
      description: seoDescription,
    },
  };
}

export default function FormationPage({ params }: { params: { slug: string } }) {
  const f = findFormation(params.slug);
  if (!f) notFound();
  const Icon = ICONS[f.iconName] ?? Truck;

  // Lien vers les autres formations en bas de page
  const others = FORMATIONS.filter((x) => x.slug !== f.slug).slice(0, 3);

  // SEO : Course + Breadcrumb + FAQ structurés
  const breadcrumb = breadcrumbSchema([
    { name: "Accueil", url: `${LEGAL.website}/` },
    { name: "Formations", url: `${LEGAL.website}/formations` },
    { name: f.title, url: `${LEGAL.website}/formations/${f.slug}` },
  ]);
  const faq = formationFaq(f);

  return (
    <SiteShell>
      <JsonLd schema={courseSchema(f)} />
      <JsonLd schema={breadcrumb} />
      <JsonLd schema={faqSchema(faq)} />
      {/* Hero formation */}
      <section className="relative overflow-hidden border-b border-white/5">
        <div
          aria-hidden="true"
          className="absolute inset-0"
          style={{
            background: `radial-gradient(ellipse at 80% 0%, ${f.accent ?? "#9FE220"}1f 0%, transparent 60%), radial-gradient(ellipse at 0% 100%, ${f.accent ?? "#9FE220"}10 0%, transparent 60%)`,
          }}
        />
        <div className="absolute inset-0 bg-mesh-night opacity-70" />
        <div
          className="absolute inset-0 bg-grid-night opacity-25"
          style={{
            backgroundSize: "56px 56px",
            maskImage:
              "linear-gradient(to bottom, black 0%, black 60%, transparent 100%)",
          }}
        />

        <div className="relative max-w-7xl mx-auto px-6 py-12 md:py-20 grid lg:grid-cols-3 gap-10 items-start">
          {/* Texte */}
          <div className="lg:col-span-2">
            <Link
              href="/formations"
              className="inline-flex items-center gap-1.5 text-sm text-white/60 hover:text-white"
            >
              <ArrowLeft className="h-4 w-4" />
              Toutes les formations
            </Link>

            <div className="mt-6 flex items-center gap-3">
              <div
                className="h-12 w-12 rounded-xl flex items-center justify-center"
                style={{
                  backgroundColor: `${f.accent ?? "#9FE220"}22`,
                  border: `1px solid ${f.accent ?? "#9FE220"}55`,
                }}
              >
                <Icon
                  className="h-6 w-6"
                  style={{ color: f.accent ?? "#9FE220" }}
                />
              </div>
              <div>
                <div className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-400">
                  {f.code}
                </div>
                {f.rncpCode && (
                  <div className="text-xs text-white/50 mt-0.5">
                    {f.rncpCode}
                    {f.level ? ` · Niveau ${f.level}` : ""}
                  </div>
                )}
              </div>
            </div>

            <h1 className="mt-6 font-display text-3xl md:text-5xl font-semibold tracking-[-0.02em] leading-[1.05]">
              {f.title}
            </h1>
            <p className="mt-4 text-lg text-white/75 max-w-2xl">{f.tagline}</p>

            <div className="mt-8 flex flex-wrap gap-3">
              <Link
                href={`/contact?formation=${f.slug}`}
                className="group inline-flex items-center gap-2 rounded-2xl bg-signal-500 text-night px-6 py-3 text-sm font-semibold shadow-glow-signal transition-[transform,background-color] duration-200 ease-premium hover:bg-signal-400 active:scale-[0.98] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/70 focus-visible:ring-offset-2 focus-visible:ring-offset-night motion-reduce:transition-none"
              >
                Demander un devis
                <ArrowRight className="h-4 w-4 transition-transform duration-200 ease-premium group-hover:translate-x-0.5 motion-reduce:transition-none" />
              </Link>
              <Link
                href={`/tarifs?formation=${f.slug}`}
                className="inline-flex items-center gap-2 rounded-2xl border border-white/15 bg-white/5 backdrop-blur px-6 py-3 text-sm font-semibold transition-[transform,background-color] duration-200 ease-premium hover:bg-white/10 active:scale-[0.98] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/60 focus-visible:ring-offset-2 focus-visible:ring-offset-night motion-reduce:transition-none"
              >
                Voir les tarifs
              </Link>
            </div>
          </div>

          {/* Carte d'identité */}
          <aside className="lg:col-span-1">
            <div className="rounded-2xl border border-white/10 bg-white/[0.04] backdrop-blur p-6 space-y-4">
              <InfoRow icon={Clock} label="Durée" value={f.duration} />
              <InfoRow
                icon={Layers}
                label="Modalité"
                value={MODALITY_LABEL[f.modality]}
              />
              <InfoRow icon={Users} label="Public visé" value={f.audience} />
              <InfoRow
                icon={GraduationCap}
                label="Prérequis"
                value={f.prerequisites}
              />
              <div>
                <div className="text-[11px] font-semibold uppercase tracking-[0.16em] text-white/60 mb-2">
                  Financements
                </div>
                <div className="flex flex-wrap gap-1.5">
                  {f.funding.map((k) => (
                    <span
                      key={k}
                      className="text-[11px] px-2.5 py-0.5 rounded-md bg-signal-500/15 border border-signal-500/30 text-signal-300"
                    >
                      {FUNDING_LABELS[k]}
                    </span>
                  ))}
                </div>
              </div>
            </div>
          </aside>
        </div>
      </section>

      <main className="max-w-7xl mx-auto px-6 py-16 md:py-20 grid lg:grid-cols-3 gap-12">
        <div className="lg:col-span-2 space-y-14">
          {/* Description */}
          <section>
            <h2 className="font-display text-2xl md:text-3xl font-semibold">
              La formation
            </h2>
            <p className="mt-4 text-white/75 leading-relaxed">{f.description}</p>
          </section>

          {/* Objectifs */}
          <section>
            <div className="flex items-center gap-2 mb-4">
              <Target className="h-5 w-5 text-signal-400" />
              <h2 className="font-display text-2xl md:text-3xl font-semibold">
                Objectifs pédagogiques
              </h2>
            </div>
            <ul className="space-y-3">
              {f.objectives.map((o) => (
                <li
                  key={o}
                  className="flex items-start gap-3 rounded-xl border border-white/10 bg-night-100 p-4"
                >
                  <CheckCircle2 className="h-5 w-5 text-signal-400 shrink-0 mt-0.5" />
                  <span className="text-white/85 text-[15px]">{o}</span>
                </li>
              ))}
            </ul>
          </section>

          {/* Programme */}
          <section>
            <div className="flex items-center gap-2 mb-4">
              <Layers className="h-5 w-5 text-signal-400" />
              <h2 className="font-display text-2xl md:text-3xl font-semibold">
                Programme détaillé
              </h2>
            </div>
            <div className="space-y-4">
              {f.program.map((p, i) => (
                <details
                  key={p.title}
                  className="group rounded-xl border border-white/10 bg-night-100 overflow-hidden"
                  open={i === 0}
                >
                  <summary className="cursor-pointer list-none px-5 py-4 flex items-center justify-between gap-3 hover:bg-white/[0.03]">
                    <span className="font-semibold">{p.title}</span>
                    <span className="text-signal-400 group-open:rotate-180 transition-transform">
                      <ArrowRight className="h-4 w-4 rotate-90" />
                    </span>
                  </summary>
                  <ul className="px-5 pb-5 space-y-2">
                    {p.details.map((d) => (
                      <li
                        key={d}
                        className="flex items-start gap-2.5 text-sm text-white/75"
                      >
                        <span className="h-1.5 w-1.5 rounded-full bg-signal-500 shrink-0 mt-2" />
                        <span>{d}</span>
                      </li>
                    ))}
                  </ul>
                </details>
              ))}
            </div>

            {/* Modules complémentaires — HORS blocs RNCP. Présentés dans
                un encart visuellement distinct (exigence EDOF / France
                Compétences : ne pas confondre avec les blocs certifiants). */}
            {f.complementaryModules && (
              <div className="mt-6 rounded-xl border border-dashed border-white/15 bg-white/[0.02] p-5">
                <div className="flex items-center gap-2 mb-1.5">
                  <Sparkles className="h-4 w-4 text-white/50" />
                  <h3 className="font-semibold text-white/90">
                    {f.complementaryModules.title}
                  </h3>
                </div>
                <p className="text-xs text-white/50 mb-3">
                  Atouts pédagogiques de notre centre, proposés en complément
                  du titre professionnel (hors compétences certifiées par
                  l'État).
                </p>
                <ul className="space-y-2">
                  {f.complementaryModules.details.map((d) => (
                    <li
                      key={d}
                      className="flex items-start gap-2.5 text-sm text-white/70"
                    >
                      <span className="h-1.5 w-1.5 rounded-full bg-white/40 shrink-0 mt-2" />
                      <span>{d}</span>
                    </li>
                  ))}
                </ul>
              </div>
            )}
          </section>

          {/* Compétences */}
          <section>
            <div className="flex items-center gap-2 mb-4">
              <Sparkles className="h-5 w-5 text-signal-400" />
              <h2 className="font-display text-2xl md:text-3xl font-semibold">
                Compétences visées
              </h2>
            </div>
            <div className="flex flex-wrap gap-2">
              {f.skills.map((s) => (
                <span
                  key={s}
                  className="px-3 py-1.5 rounded-full bg-brand-600/20 border border-brand-500/40 text-brand-100 text-sm"
                >
                  {s}
                </span>
              ))}
            </div>
          </section>

          {/* Modalités d'évaluation (Qualiopi — critère 1) */}
          <section>
            <div className="flex items-center gap-2 mb-4">
              <ClipboardCheck className="h-5 w-5 text-signal-400" />
              <h2 className="font-display text-2xl md:text-3xl font-semibold">
                Modalités d'évaluation
              </h2>
            </div>
            <p className="text-white/80 leading-relaxed rounded-xl border border-white/10 bg-night-100 p-5">
              {f.assessment}
            </p>
          </section>

          {/* Débouchés & suites de parcours (Qualiopi — critère 1) */}
          <section>
            <div className="flex items-center gap-2 mb-4">
              <TrendingUp className="h-5 w-5 text-signal-400" />
              <h2 className="font-display text-2xl md:text-3xl font-semibold">
                Débouchés &amp; suites de parcours
              </h2>
            </div>
            <ul className="space-y-3">
              {f.outcomes.map((o) => (
                <li
                  key={o}
                  className="flex items-start gap-3 rounded-xl border border-white/10 bg-night-100 p-4"
                >
                  <ArrowRight className="h-5 w-5 text-signal-400 shrink-0 mt-0.5" />
                  <span className="text-white/85 text-[15px]">{o}</span>
                </li>
              ))}
            </ul>
          </section>

          {/* FAQ — contenu longue traîne + éligibilité rich snippet
              (JSON-LD FAQPage injecté en tête de page). */}
          <section>
            <div className="flex items-center gap-2 mb-4">
              <HelpCircle className="h-5 w-5 text-signal-400" />
              <h2 className="font-display text-2xl md:text-3xl font-semibold">
                Questions fréquentes
              </h2>
            </div>
            <div className="space-y-3">
              {faq.map((item, i) => (
                <details
                  key={item.question}
                  className="group rounded-xl border border-white/10 bg-night-100 overflow-hidden"
                  open={i === 0}
                >
                  <summary className="cursor-pointer list-none px-5 py-4 flex items-center justify-between gap-3 hover:bg-white/[0.03]">
                    <span className="font-semibold text-[15px]">
                      {item.question}
                    </span>
                    <span className="text-signal-400 group-open:rotate-180 transition-transform shrink-0">
                      <ArrowRight className="h-4 w-4 rotate-90" />
                    </span>
                  </summary>
                  <p className="px-5 pb-5 text-white/75 text-[15px] leading-relaxed">
                    {item.answer}
                  </p>
                </details>
              ))}
            </div>
          </section>
        </div>

        {/* Sidebar CTA + autres formations */}
        <aside className="lg:col-span-1 lg:sticky lg:top-20 self-start space-y-6">
          <div className="rounded-2xl bg-gradient-to-br from-brand-700 to-brand-900 p-6 text-white shadow-glow-brand relative overflow-hidden">
            <div
              aria-hidden="true"
              className="absolute -top-10 -right-10 h-40 w-40 rounded-full bg-signal-500/20 blur-3xl"
            />
            <div className="relative">
              <div className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-300">
                Prêt à démarrer ?
              </div>
              <h3 className="mt-2 font-display text-xl font-semibold leading-tight">
                Étudions votre dossier en 24 h.
              </h3>
              <p className="mt-3 text-sm text-white/80">
                Devis et plan de financement sur-mesure (CPF, OPCO, France
                Travail, auto-financement).
              </p>
              <Link
                href={`/contact?formation=${f.slug}`}
                className="mt-5 inline-flex items-center gap-2 rounded-xl bg-signal-500 text-night px-4 py-2.5 text-sm font-semibold hover:bg-signal-400 transition w-full justify-center"
              >
                Être rappelé(e)
                <ArrowRight className="h-3.5 w-3.5" />
              </Link>
            </div>
          </div>

          <div>
            <div className="text-[11px] font-semibold uppercase tracking-[0.18em] text-white/60 mb-3">
              Autres formations
            </div>
            <div className="space-y-2">
              {others.map((o) => (
                <Link
                  key={o.slug}
                  href={`/formations/${o.slug}`}
                  className="flex items-center justify-between gap-2 px-4 py-3 rounded-xl border border-white/10 bg-night-100 hover:border-signal-500/40 hover:bg-white/[0.04] transition"
                >
                  <span>
                    <div className="text-[10px] uppercase tracking-wider text-white/60">
                      {o.code}
                    </div>
                    <div className="text-sm font-medium text-white truncate max-w-[200px]">
                      {o.title}
                    </div>
                  </span>
                  <ArrowRight className="h-4 w-4 text-white/60" />
                </Link>
              ))}
            </div>
          </div>
        </aside>
      </main>
    </SiteShell>
  );
}

function InfoRow({
  icon: Icon,
  label,
  value,
}: {
  icon: any;
  label: string;
  value: string;
}) {
  return (
    <div>
      <div className="flex items-center gap-2 text-[11px] font-semibold uppercase tracking-[0.16em] text-white/60 mb-1">
        <Icon className="h-3.5 w-3.5" />
        {label}
      </div>
      <div className="text-sm text-white/85 leading-relaxed">{value}</div>
    </div>
  );
}
