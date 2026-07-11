import Link from "next/link";
import { SiteShell, PageHero } from "@/components/site/site-shell";
import { articlesSorted } from "@/lib/blog-config";
import { ArrowRight, Clock, CalendarDays } from "lucide-react";

export const metadata = {
  title: { absolute: "Guides & conseils formation transport" },
  alternates: { canonical: "/blog" },
  description:
    "Guides pratiques sur les formations transport : capacité de marchandises, FIMO/FCO, taxi/VTC, financement CPF et France Travail. Conseils du centre à Meaux.",
};

export const revalidate = 3600;

const CATEGORY_TONE: Record<string, string> = {
  "Capacité de transport": "bg-signal-500/15 text-signal-300 border-signal-500/30",
  "Titres professionnels": "bg-brand-500/15 text-brand-200 border-brand-500/30",
  "Conducteurs (FIMO/FCO)": "bg-amber-500/15 text-amber-200 border-amber-500/30",
  "Taxi / VTC": "bg-violet-500/15 text-violet-200 border-violet-500/30",
  Financement: "bg-emerald-500/15 text-emerald-200 border-emerald-500/30",
};

function fmtDate(iso: string): string {
  return new Date(iso).toLocaleDateString("fr-FR", {
    day: "numeric",
    month: "long",
    year: "numeric",
  });
}

/** Pastille de catégorie (réutilisée sur la une et les cartes). */
function CategoryPill({ category }: { category: string }) {
  return (
    <span
      className={
        "inline-flex self-start items-center rounded-full border px-2.5 py-0.5 text-[11px] font-semibold " +
        (CATEGORY_TONE[category] ?? "bg-white/10 text-white/70 border-white/15")
      }
    >
      {category}
    </span>
  );
}

export default function BlogIndexPage() {
  const articles = articlesSorted();
  // Rythme éditorial : le guide le plus récent passe "à la une" (grande
  // carte 2 colonnes), les autres suivent en grille. On casse ainsi la
  // grille monotone de cartes identiques.
  const [featured, ...rest] = articles;

  return (
    <SiteShell>
      <PageHero
        eyebrow="Guides & conseils"
        title={
          <>
            Tout comprendre sur les{" "}
            <span className="italic text-signal-400">formations transport</span>.
          </>
        }
        description={
          <>
            Des guides clairs pour choisir votre formation, réussir vos examens
            et financer votre projet, écrits par notre équipe pédagogique.
          </>
        }
      />

      <main className="max-w-6xl mx-auto px-6 py-16 md:py-20">
        {articles.length === 0 ? (
          <div className="rounded-2xl border border-white/10 bg-night-100 p-12 text-center text-white/70">
            Nos premiers guides arrivent très bientôt.
          </div>
        ) : (
          <>
            {/* À la une — guide le plus récent, carte large 2 colonnes */}
            {featured && (
              <Link
                href={`/blog/${featured.slug}`}
                style={{ animation: "fade-up 0.5s ease-out both" }}
                className="group relative mb-6 grid gap-8 overflow-hidden rounded-3xl border border-white/10 bg-night-100 p-8 md:grid-cols-[1.45fr_1fr] md:p-10 transition-[transform,border-color] duration-200 ease-premium hover:border-signal-500/40 hover:-translate-y-1 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-signal-400 motion-reduce:transition-none motion-reduce:hover:translate-y-0"
              >
                {/* Halo signal discret en fond pour distinguer la une */}
                <div
                  aria-hidden
                  className="pointer-events-none absolute -right-24 -top-24 h-64 w-64 rounded-full opacity-60"
                  style={{
                    background:
                      "radial-gradient(circle, rgba(159,226,32,0.10) 0%, rgba(159,226,32,0) 65%)",
                  }}
                />
                <div className="relative">
                  <div className="flex items-center gap-3">
                    <span className="text-[10px] font-semibold uppercase tracking-[0.18em] text-signal-400">
                      À la une
                    </span>
                    <CategoryPill category={featured.category} />
                  </div>
                  <h2 className="mt-4 font-display text-2xl md:text-3xl font-semibold leading-[1.12] tracking-[-0.015em] text-white group-hover:text-signal-300 transition-colors">
                    {featured.title}
                  </h2>
                  <p className="mt-3 text-white/65 leading-relaxed line-clamp-3 md:line-clamp-4">
                    {featured.excerpt}
                  </p>
                </div>
                <div className="relative flex flex-col justify-center gap-5 border-t border-white/10 pt-6 md:border-l md:border-t-0 md:pl-8 md:pt-0">
                  <div className="flex items-center gap-4 text-[11px] text-white/45">
                    <span className="inline-flex items-center gap-1.5">
                      <CalendarDays className="h-3 w-3" />
                      {fmtDate(featured.publishedAt)}
                    </span>
                    <span className="inline-flex items-center gap-1.5">
                      <Clock className="h-3 w-3" />
                      {featured.readingMinutes} min de lecture
                    </span>
                  </div>
                  <span className="inline-flex items-center gap-2 text-sm font-semibold text-signal-400">
                    Lire le guide
                    <ArrowRight className="h-4 w-4 transition-transform duration-200 group-hover:translate-x-0.5 motion-reduce:transition-none" />
                  </span>
                </div>
              </Link>
            )}

            {/* Les autres guides — grille */}
            {rest.length > 0 && (
              <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
                {rest.map((a, i) => (
                  <Link
                    key={a.slug}
                    href={`/blog/${a.slug}`}
                    style={{
                      animation: "fade-up 0.5s ease-out both",
                      animationDelay: `${Math.min(i, 6) * 60 + 80}ms`,
                    }}
                    className="group relative flex flex-col overflow-hidden rounded-2xl border border-white/10 bg-night-100 p-6 transition-[transform,border-color] duration-200 ease-premium hover:border-signal-500/40 hover:-translate-y-1 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-signal-400 motion-reduce:transition-none motion-reduce:hover:translate-y-0"
                  >
                    <CategoryPill category={a.category} />

                    <h2 className="mt-4 font-display text-lg font-semibold leading-snug text-white group-hover:text-signal-300 transition-colors">
                      {a.title}
                    </h2>

                    <p className="mt-2 text-sm text-white/65 leading-relaxed line-clamp-3">
                      {a.excerpt}
                    </p>

                    <div className="mt-4 flex items-center gap-4 text-[11px] text-white/45">
                      <span className="inline-flex items-center gap-1.5">
                        <CalendarDays className="h-3 w-3" />
                        {fmtDate(a.publishedAt)}
                      </span>
                      <span className="inline-flex items-center gap-1.5">
                        <Clock className="h-3 w-3" />
                        {a.readingMinutes} min
                      </span>
                    </div>

                    <span className="mt-4 inline-flex items-center gap-1.5 text-sm font-medium text-signal-400">
                      Lire le guide
                      <ArrowRight className="h-3.5 w-3.5 transition-transform duration-200 group-hover:translate-x-0.5 motion-reduce:transition-none" />
                    </span>
                  </Link>
                ))}
              </div>
            )}
          </>
        )}
      </main>
    </SiteShell>
  );
}
