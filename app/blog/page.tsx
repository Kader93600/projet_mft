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

export default function BlogIndexPage() {
  const articles = articlesSorted();

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
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {articles.map((a) => (
              <Link
                key={a.slug}
                href={`/blog/${a.slug}`}
                className="group relative flex flex-col overflow-hidden rounded-2xl border border-white/10 bg-night-100 p-6 transition-[transform,border-color] duration-200 ease-premium hover:border-signal-500/40 hover:-translate-y-1 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-signal-400 motion-reduce:transition-none motion-reduce:hover:translate-y-0"
              >
                <span
                  className={
                    "inline-flex self-start items-center rounded-full border px-2.5 py-0.5 text-[11px] font-semibold " +
                    (CATEGORY_TONE[a.category] ??
                      "bg-white/10 text-white/70 border-white/15")
                  }
                >
                  {a.category}
                </span>

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
      </main>
    </SiteShell>
  );
}
