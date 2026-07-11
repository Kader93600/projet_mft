import Link from "next/link";
import { notFound } from "next/navigation";
import { SiteShell } from "@/components/site/site-shell";
import {
  JsonLd,
  articleSchema,
  breadcrumbSchema,
} from "@/components/seo/json-ld";
import { findArticle, articlesSorted, ARTICLES } from "@/lib/blog-config";
import { findFormation } from "@/lib/formations-config";
import { renderMarkdown } from "@/lib/markdown";
import { LEGAL } from "@/lib/legal-config";
import { ArrowLeft, ArrowRight, Clock, CalendarDays } from "lucide-react";

export const revalidate = 3600;

export function generateStaticParams() {
  return ARTICLES.map((a) => ({ slug: a.slug }));
}

export function generateMetadata({ params }: { params: { slug: string } }) {
  const a = findArticle(params.slug);
  if (!a) return { title: "Article introuvable" };
  const canonicalPath = `/blog/${a.slug}`;
  return {
    title: { absolute: a.seoTitle },
    description: a.seoDescription,
    alternates: { canonical: canonicalPath },
    openGraph: {
      type: "article",
      title: a.seoTitle,
      description: a.seoDescription,
      url: canonicalPath,
      publishedTime: a.publishedAt,
      modifiedTime: a.updatedAt,
    },
    twitter: {
      card: "summary_large_image",
      title: a.seoTitle,
      description: a.seoDescription,
    },
  };
}

function fmtDate(iso: string): string {
  return new Date(iso).toLocaleDateString("fr-FR", {
    day: "numeric",
    month: "long",
    year: "numeric",
  });
}

export default function ArticlePage({ params }: { params: { slug: string } }) {
  const a = findArticle(params.slug);
  if (!a) notFound();

  const html = renderMarkdown(a.body);

  const related = a.relatedFormations
    .map((slug) => findFormation(slug))
    .filter((f): f is NonNullable<typeof f> => Boolean(f));

  // Autres guides (hors article courant), max 2.
  const others = articlesSorted()
    .filter((x) => x.slug !== a.slug)
    .slice(0, 2);

  const breadcrumb = breadcrumbSchema([
    { name: "Accueil", url: `${LEGAL.website}/` },
    { name: "Guides", url: `${LEGAL.website}/blog` },
    { name: a.title, url: `${LEGAL.website}/blog/${a.slug}` },
  ]);

  return (
    <SiteShell>
      <JsonLd
        schema={articleSchema({
          title: a.title,
          description: a.seoDescription,
          slug: a.slug,
          datePublished: a.publishedAt,
          dateModified: a.updatedAt,
        })}
      />
      <JsonLd schema={breadcrumb} />

      {/* En-tête article */}
      <section className="relative overflow-hidden border-b border-white/5">
        <div className="absolute inset-0 bg-mesh-night opacity-70" />
        <div
          className="absolute inset-0 bg-grid-night opacity-25"
          style={{
            backgroundSize: "56px 56px",
            maskImage:
              "linear-gradient(to bottom, black 0%, black 60%, transparent 100%)",
          }}
        />
        <div className="relative max-w-3xl mx-auto px-6 py-14 md:py-20">
          <Link
            href="/blog"
            className="inline-flex items-center gap-1.5 text-sm text-white/60 hover:text-white transition-colors"
          >
            <ArrowLeft className="h-4 w-4" />
            Tous les guides
          </Link>

          <div className="mt-6 flex items-center gap-4 text-[11px] text-white/50">
            <span className="inline-flex items-center gap-1.5 text-signal-400 font-semibold uppercase tracking-[0.16em]">
              {a.category}
            </span>
            <span className="inline-flex items-center gap-1.5">
              <CalendarDays className="h-3 w-3" />
              <time dateTime={a.publishedAt}>{fmtDate(a.publishedAt)}</time>
            </span>
            <span className="inline-flex items-center gap-1.5">
              <Clock className="h-3 w-3" />
              {a.readingMinutes} min de lecture
            </span>
          </div>

          <h1 className="mt-4 font-display text-3xl md:text-4xl font-semibold tracking-[-0.02em] leading-[1.1]">
            {a.title}
          </h1>
          <p className="mt-4 text-lg text-white/75">{a.excerpt}</p>
        </div>
      </section>

      {/* Corps de l'article */}
      <main className="max-w-3xl mx-auto px-6 py-14 md:py-16">
        <article
          className="prose-lesson"
          dangerouslySetInnerHTML={{ __html: html }}
        />

        {/* Maillage interne : formations liées */}
        {related.length > 0 && (
          <aside className="mt-14 rounded-2xl border border-white/10 bg-night-100 p-6">
            <h2 className="font-display text-lg font-semibold text-white">
              Formations liées à ce guide
            </h2>
            <div className="mt-4 grid gap-3 sm:grid-cols-2">
              {related.map((f) => (
                <Link
                  key={f.slug}
                  href={`/formations/${f.slug}`}
                  className="group flex items-center justify-between gap-3 rounded-xl border border-white/10 bg-white/[0.03] px-4 py-3 transition-colors hover:border-signal-500/40 hover:bg-white/[0.06] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-signal-400"
                >
                  <span className="min-w-0">
                    <span className="block text-[11px] font-semibold uppercase tracking-wide text-signal-400">
                      {f.code}
                    </span>
                    <span className="block text-sm text-white/80 truncate">
                      {f.title}
                    </span>
                  </span>
                  <ArrowRight className="h-4 w-4 shrink-0 text-white/40 transition-transform group-hover:translate-x-0.5" />
                </Link>
              ))}
            </div>
          </aside>
        )}

        {/* CTA contact */}
        <div className="mt-8 rounded-2xl border border-signal-500/30 bg-signal-500/[0.06] p-6 text-center">
          <p className="text-white/85">
            Un projet de formation transport&nbsp;? Notre équipe vous répond
            sous 24&nbsp;h ouvrées.
          </p>
          <Link
            href="/contact"
            className="mt-4 inline-flex items-center gap-2 rounded-2xl bg-signal-500 text-night-900 px-6 py-3 text-sm font-semibold shadow-glow-signal transition-[transform,background-color] duration-200 ease-premium hover:bg-signal-400 active:scale-[0.98] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/70 focus-visible:ring-offset-2 focus-visible:ring-offset-night motion-reduce:transition-none"
          >
            Demander un devis gratuit
            <ArrowRight className="h-4 w-4" />
          </Link>
        </div>

        {/* Autres guides */}
        {others.length > 0 && (
          <section className="mt-14">
            <h2 className="font-display text-xl font-semibold text-white mb-5">
              À lire aussi
            </h2>
            <div className="grid gap-4 sm:grid-cols-2">
              {others.map((o) => (
                <Link
                  key={o.slug}
                  href={`/blog/${o.slug}`}
                  className="group rounded-2xl border border-white/10 bg-night-100 p-5 transition-[transform,border-color] duration-200 hover:border-signal-500/40 hover:-translate-y-1 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-signal-400 motion-reduce:hover:translate-y-0"
                >
                  <span className="text-[11px] font-semibold uppercase tracking-wide text-signal-400">
                    {o.category}
                  </span>
                  <span className="mt-2 block font-display font-semibold text-white group-hover:text-signal-300 transition-colors">
                    {o.title}
                  </span>
                </Link>
              ))}
            </div>
          </section>
        )}
      </main>
    </SiteShell>
  );
}
