import Link from "next/link";
import { SiteShell, PageHero } from "@/components/site/site-shell";
import {
  TESTIMONIALS,
  avgRating,
  listFormationSlugsWithTestimonials,
} from "@/lib/testimonials-config";
import { findFormation, FORMATIONS } from "@/lib/formations-config";
import { LEGAL } from "@/lib/legal-config";
import { Star, Filter, Quote, ArrowRight } from "lucide-react";

export const metadata = {
  title: "Témoignages stagiaires",
  alternates: { canonical: "/temoignages" },
  description: `Avis et témoignages des stagiaires de nos formations transport (GOTRM, FIMO, capacité, taxi/VTC). Note moyenne ${avgRating().toFixed(1)}/5 sur ${TESTIMONIALS.length} témoignages. Centre certifié Qualiopi à ${LEGAL.address.city}.`,
};

export const revalidate = 3600;

export default function TemoignagesPage({
  searchParams,
}: {
  searchParams?: { f?: string };
}) {
  const filter = searchParams?.f ?? "";
  const filtered = filter
    ? TESTIMONIALS.filter((t) => t.formationSlug === filter)
    : TESTIMONIALS;

  const usedSlugs = listFormationSlugsWithTestimonials();
  const avg = avgRating();
  const fiveStars = TESTIMONIALS.filter((t) => t.rating === 5).length;

  return (
    <SiteShell>
      <PageHero
        eyebrow="Témoignages"
        title={
          <>
            Avis et témoignages de nos{" "}
            <span className="italic text-signal-400">stagiaires</span>.
          </>
        }
        description={
          <>
            <strong className="text-white">{avg.toFixed(1)}/5</strong> de
            satisfaction moyenne sur {TESTIMONIALS.length} témoignages —
            stagiaires et entreprises confondus.
          </>
        }
      />

      {/* Filtres */}
      <section className="sticky top-16 z-20 border-b border-white/5 bg-night/85 backdrop-blur-md">
        <div className="max-w-7xl mx-auto px-6 py-4 flex flex-wrap items-center gap-2">
          <span className="inline-flex items-center gap-1.5 text-[11px] font-semibold uppercase tracking-[0.16em] text-white/60 mr-2">
            <Filter className="h-3.5 w-3.5" />
            Filtrer par formation
          </span>
          <FilterPill href="/temoignages" label="Toutes" active={!filter} />
          {FORMATIONS.filter((f) => usedSlugs.includes(f.slug)).map((f) => (
            <FilterPill
              key={f.slug}
              href={`/temoignages?f=${f.slug}`}
              label={f.code}
              active={filter === f.slug}
              accent={f.accent}
            />
          ))}
        </div>
      </section>

      <main className="max-w-6xl mx-auto px-6 py-12 md:py-16">
        {/* Stats */}
        <section className="grid sm:grid-cols-3 gap-4 mb-12">
          <Stat label="Note moyenne" value={`${avg.toFixed(1)}/5`} icon={Star} />
          <Stat
            label="Témoignages 5 étoiles"
            value={`${fiveStars}/${TESTIMONIALS.length}`}
          />
          <Stat
            label="Formations couvertes"
            value={`${usedSlugs.length} / ${FORMATIONS.length}`}
          />
        </section>

        {/* Grille témoignages */}
        {filtered.length === 0 ? (
          <div className="rounded-2xl border border-white/10 bg-night-100 p-12 text-center">
            <div className="text-white/60">
              Aucun témoignage pour cette formation. Les premiers retours
              arrivent !
            </div>
            <Link
              href="/temoignages"
              className="mt-4 inline-flex items-center gap-1.5 text-sm text-signal-400 hover:text-signal-300"
            >
              Voir tous les témoignages
              <ArrowRight className="h-3.5 w-3.5" />
            </Link>
          </div>
        ) : (
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-5">
            {filtered.map((t) => {
              const f = t.formationSlug ? findFormation(t.formationSlug) : null;
              return (
                <article
                  key={t.id}
                  className="relative overflow-hidden rounded-2xl border border-white/10 bg-night-100 p-6 hover:border-signal-500/30 transition flex flex-col"
                >
                  {f && (
                    <div
                      aria-hidden="true"
                      className="absolute -top-10 -right-10 h-32 w-32 rounded-full opacity-10 blur-2xl"
                      style={{ backgroundColor: f.accent }}
                    />
                  )}

                  <div className="relative flex-1 flex flex-col">
                    <div className="flex items-start justify-between gap-3 mb-4">
                      <Quote className="h-6 w-6 text-signal-400 shrink-0" />
                      <Stars rating={t.rating} />
                    </div>

                    <blockquote className="text-white/85 text-[15px] leading-relaxed flex-1">
                      {t.quote}
                    </blockquote>

                    <footer className="mt-6 pt-5 border-t border-white/10">
                      <div className="font-semibold text-white">{t.name}</div>
                      <div className="text-xs text-white/55 mt-0.5">
                        {t.role && <>{t.role}</>}
                        {t.city && <> · {t.city}</>}
                        {" · Promo "}{t.year}
                      </div>
                      {f && (
                        <Link
                          href={`/formations/${f.slug}`}
                          className="mt-3 inline-flex items-center gap-1.5 text-[10px] uppercase tracking-wider px-2 py-0.5 rounded-md border hover:border-signal-500/40 transition"
                          style={{
                            backgroundColor: `${f.accent}15`,
                            color: f.accent,
                            borderColor: `${f.accent}55`,
                          }}
                        >
                          {f.code}
                        </Link>
                      )}
                    </footer>
                  </div>
                </article>
              );
            })}
          </div>
        )}

        {/* CTA */}
        <section className="mt-16 rounded-3xl bg-gradient-to-br from-brand-700 to-brand-900 p-10 md:p-14 relative overflow-hidden">
          <div
            aria-hidden="true"
            className="absolute -top-16 -right-16 h-60 w-60 rounded-full bg-signal-500/20 blur-3xl"
          />
          <div className="relative max-w-2xl">
            <div className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-300">
              Vous aussi, lancez-vous
            </div>
            <h2 className="mt-3 font-display text-3xl md:text-4xl font-semibold text-white">
              Rejoignez nos{" "}
              <span className="italic text-signal-400">prochains diplômés</span>.
            </h2>
            <p className="mt-4 text-white/80 leading-relaxed">
              {TESTIMONIALS.length} stagiaires ont fait confiance à{" "}
              {LEGAL.brand}. Démarrez votre parcours dès aujourd'hui.
            </p>
            <div className="mt-6 flex flex-wrap gap-3">
              <Link
                href="/formations"
                className="inline-flex items-center gap-2 rounded-2xl bg-signal-500 text-night px-6 py-3 text-sm font-semibold hover:bg-signal-400 transition shadow-glow-signal"
              >
                Voir nos formations
                <ArrowRight className="h-4 w-4" />
              </Link>
              <Link
                href="/contact"
                className="inline-flex items-center gap-2 rounded-2xl border border-white/20 bg-white/5 backdrop-blur px-6 py-3 text-sm font-semibold text-white hover:bg-white/10 transition"
              >
                Nous contacter
              </Link>
            </div>
          </div>
        </section>
      </main>
    </SiteShell>
  );
}

function Stars({ rating }: { rating: number }) {
  return (
    <div className="flex gap-0.5">
      {[1, 2, 3, 4, 5].map((n) => (
        <Star
          key={n}
          className={
            "h-3.5 w-3.5 " +
            (n <= rating
              ? "text-signal-400 fill-signal-400"
              : "text-white/20")
          }
        />
      ))}
    </div>
  );
}

function FilterPill({
  href,
  label,
  active,
  accent,
}: {
  href: string;
  label: string;
  active: boolean;
  accent?: string;
}) {
  return (
    <Link
      href={href}
      className={
        "inline-flex items-center px-3 py-1.5 rounded-full text-xs font-medium border transition " +
        (active
          ? "text-night border-transparent"
          : "bg-white/5 text-white/70 border-white/10 hover:bg-white/10")
      }
      style={
        active
          ? {
              backgroundColor: accent ?? "#FFFFFF",
              color: "#0B0F24",
              borderColor: accent ?? "#FFFFFF",
            }
          : undefined
      }
    >
      {label}
    </Link>
  );
}

function Stat({
  label,
  value,
  icon: Icon,
}: {
  label: string;
  value: string;
  icon?: any;
}) {
  return (
    <div className="rounded-2xl border border-white/10 bg-night-100 p-5 text-center">
      <div className="flex items-center justify-center gap-1.5 text-[11px] uppercase tracking-[0.16em] text-white/60">
        {Icon && <Icon className="h-3 w-3 text-signal-400" />}
        {label}
      </div>
      <div className="mt-2 font-display text-3xl font-semibold text-white">
        {value}
      </div>
    </div>
  );
}
