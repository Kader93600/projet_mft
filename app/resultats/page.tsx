import type { Metadata } from "next";
import { SiteShell, PageHero } from "@/components/site/site-shell";
import { RESULTS } from "@/lib/results-config";
import { LEGAL, LEGAL_DATE_FR } from "@/lib/legal-config";
import { Info, CalendarDays, RefreshCw } from "lucide-react";

export const metadata: Metadata = {
  title: "Indicateurs de résultats",
  alternates: { canonical: "/resultats" },
  description:
    "Taux de satisfaction, de réussite et d'insertion de nos formations. Indicateurs publiés conformément à notre certification Qualiopi.",
};

export default function ResultatsPage() {
  const hasData = RESULTS.indicators.some((i) => i.value !== null);

  return (
    <SiteShell>
      <PageHero
        eyebrow="Transparence"
        title={
          <>
            Nos indicateurs <span className="text-signal-400">de résultats</span>
          </>
        }
        description="Conformément à notre certification Qualiopi, nous publions ici les indicateurs de résultats de nos formations, actualisés à chaque session."
      />

      <section className="max-w-7xl mx-auto px-6 py-16 md:py-20">
        <div className="flex flex-wrap items-center gap-3 text-sm text-white/60 mb-8">
          <span className="inline-flex items-center gap-2 rounded-full border border-white/15 bg-white/5 px-3 py-1.5">
            <CalendarDays className="h-3.5 w-3.5 text-signal-400" />
            Période : {RESULTS.referencePeriod}
          </span>
          <span className="inline-flex items-center gap-2 rounded-full border border-white/15 bg-white/5 px-3 py-1.5">
            <RefreshCw className="h-3.5 w-3.5 text-signal-400" />
            Mise à jour : {LEGAL_DATE_FR.format(new Date(RESULTS.lastUpdate))}
          </span>
        </div>

        {!hasData && (
          <div className="mb-10 flex items-start gap-3 rounded-2xl border border-signal-500/30 bg-signal-500/10 p-5">
            <Info className="h-5 w-5 text-signal-300 shrink-0 mt-0.5" />
            <p className="text-white/80 text-[15px] leading-relaxed max-w-3xl">
              {RESULTS.pendingNote}
            </p>
          </div>
        )}

        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {RESULTS.indicators.map((ind) => (
            <div
              key={ind.key}
              className="rounded-2xl border border-white/10 bg-white/[0.04] p-6 transition-colors duration-200 hover:border-white/20"
            >
              <div className="text-[11px] font-semibold uppercase tracking-[0.16em] text-white/45">
                {ind.label}
              </div>
              <div className="mt-3 min-h-[2.5rem] flex items-end">
                {ind.value ? (
                  <span className="font-display text-4xl font-semibold text-signal-300 leading-none">
                    {ind.value}
                  </span>
                ) : (
                  <span className="text-sm font-medium text-white/35">
                    Publié après la 1ʳᵉ cohorte
                  </span>
                )}
              </div>
              <p className="mt-3 text-sm text-white/55 leading-relaxed">
                {ind.help}
              </p>
            </div>
          ))}
        </div>

        <p className="mt-10 text-xs text-white/40 max-w-2xl leading-relaxed">
          Indicateurs calculés à partir de nos enquêtes de satisfaction et des
          résultats aux examens, mis à jour à chaque session. Pour toute
          question :{" "}
          <a
            href={`mailto:${LEGAL.email}`}
            className="underline hover:text-white/70"
          >
            {LEGAL.email}
          </a>
          .
        </p>
      </section>
    </SiteShell>
  );
}
