import Link from "next/link";
import {
  ArrowRight,
  Clock,
  Truck,
  Bus,
  GraduationCap,
  Car,
  Briefcase,
  Package,
  Award,
  ShieldCheck,
  Filter,
  X,
} from "lucide-react";
import { SiteShell, PageHero } from "@/components/site/site-shell";
import {
  FORMATIONS,
  CATEGORIES,
  FUNDING_LABELS,
  type FundingKey,
  type Formation,
} from "@/lib/formations-config";
import { LEGAL } from "@/lib/legal-config";

export const metadata = {
  // title.absolute : mot-clé en tête, sans suffixe marque (évite la
  // troncature). Reflète l'école généraliste (4 familles de métiers).
  title: {
    absolute: "Nos formations transport à Meaux — 8 cursus certifiants",
  },
  alternates: { canonical: "/formations" },
  description:
    "Centre de formation aux métiers du transport à Meaux : GOTRM, ERTV, FIMO/FCO, ECSR, taxi/VTC, capacité et commissionnaire. Certifié Qualiopi, éligible CPF.",
};

export const revalidate = 300;

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

const CATEGORY_KEYS = Object.keys(CATEGORIES) as Formation["category"][];
const FUNDING_KEYS: FundingKey[] = [
  "cpf",
  "opco",
  "employeur",
  "pole_emploi",
  "auto",
  "transitions_pro",
];

export default async function FormationsPage(
  props: {
    searchParams?: Promise<{ cat?: string; finance?: string }>;
  }
) {
  const searchParams = await props.searchParams;
  const cat = (searchParams?.cat ?? "").trim();
  const finance = (searchParams?.finance ?? "").trim();

  // Filtrage
  let filtered = FORMATIONS;
  if (cat && CATEGORY_KEYS.includes(cat as Formation["category"])) {
    filtered = filtered.filter((f) => f.category === cat);
  }
  if (finance && FUNDING_KEYS.includes(finance as FundingKey)) {
    filtered = filtered.filter((f) =>
      f.funding.includes(finance as FundingKey)
    );
  }

  const groups = CATEGORY_KEYS.map((key) => ({
    key,
    ...CATEGORIES[key],
    items: filtered.filter((f) => f.category === key),
  })).filter((g) => g.items.length > 0);

  const hasFilters = !!cat || !!finance;

  return (
    <SiteShell>
      <PageHero
        eyebrow="Catalogue"
        title={
          <>
            Toutes nos{" "}
            <span className="italic text-signal-400">formations</span> transport.
          </>
        }
        description={
          <>
            Marchandises, voyageurs, enseignement de la conduite, capacités
            professionnelles : {FORMATIONS.length} formations pour évoluer ou
            créer votre activité.
          </>
        }
      />

      {/* Barre de filtres.
          Mobile : ruban horizontal scrollable sur une seule ligne — empilées,
          les chips occupaient ~55 % du viewport sous le header sticky.
          Desktop (md+) : wrap classique multi-lignes. */}
      <section className="sticky top-16 z-20 border-b border-white/5 bg-night/85 backdrop-blur-md">
        <div className="max-w-7xl mx-auto py-3 md:py-4 md:px-6 flex flex-nowrap md:flex-wrap items-center gap-2 overflow-x-auto md:overflow-visible px-6 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
          <span className="inline-flex shrink-0 items-center gap-1.5 text-[11px] font-semibold uppercase tracking-[0.16em] text-white/60 mr-2">
            <Filter className="h-3.5 w-3.5" />
            Filtres
          </span>

          {/* Pill "Toutes" */}
          <FilterPill
            href="/formations"
            label="Toutes"
            active={!hasFilters}
          />

          {/* Catégories */}
          {CATEGORY_KEYS.map((k) => (
            <FilterPill
              key={k}
              href={
                "/formations?cat=" + k + (finance ? `&finance=${finance}` : "")
              }
              label={CATEGORIES[k].label}
              active={cat === k}
            />
          ))}

          <span className="mx-3 hidden md:inline-block h-5 w-px bg-white/10" />

          {/* Financements */}
          {FUNDING_KEYS.map((f) => (
            <FilterPill
              key={f}
              href={"/formations?finance=" + f + (cat ? `&cat=${cat}` : "")}
              label={FUNDING_LABELS[f]}
              active={finance === f}
              variant="brand"
            />
          ))}

          {hasFilters && (
            <Link
              href="/formations"
              className="ml-auto inline-flex shrink-0 items-center gap-1.5 whitespace-nowrap pl-2 text-xs text-white/55 hover:text-white"
            >
              <X className="h-3 w-3" />
              Effacer
            </Link>
          )}
        </div>
      </section>

      <main id="main-content" tabIndex={-1} className="max-w-7xl mx-auto px-6 py-12 md:py-16 space-y-16">
        {groups.length === 0 ? (
          <div className="rounded-2xl border border-white/10 bg-night-100 p-12 text-center">
            <div className="text-white/60">
              Aucune formation ne correspond à ces filtres.
            </div>
            <Link
              href="/formations"
              className="mt-4 inline-flex items-center gap-1.5 text-sm text-signal-400 hover:text-signal-300"
            >
              Réinitialiser
              <ArrowRight className="h-3.5 w-3.5" />
            </Link>
          </div>
        ) : (
          groups.map((g) => (
            <section key={g.key}>
              <div className="flex items-end justify-between flex-wrap gap-4 mb-8">
                <div>
                  <h2 className="font-display text-2xl md:text-3xl font-semibold">
                    {g.label}
                  </h2>
                  <p className="text-white/60 mt-1">{g.description}</p>
                </div>
                <span className="text-[11px] uppercase tracking-[0.18em] text-white/60">
                  {g.items.length} formation{g.items.length > 1 ? "s" : ""}
                </span>
              </div>

              <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-5">
                {g.items.map((f) => {
                  const Icon = ICONS[f.iconName] ?? Truck;
                  return (
                    <article
                      key={f.slug}
                      className="group relative overflow-hidden rounded-2xl border border-white/10 bg-night-100 flex flex-col transition-[transform,border-color] duration-200 ease-premium hover:border-signal-500/40 hover:-translate-y-1 motion-reduce:transition-none motion-reduce:hover:translate-y-0"
                    >
                      <div
                        aria-hidden="true"
                        className="absolute -top-12 -right-12 h-40 w-40 rounded-full opacity-15 group-hover:opacity-30 transition-opacity blur-2xl"
                        style={{ backgroundColor: f.accent ?? "#9FE220" }}
                      />
                      <div className="relative p-6 flex flex-col flex-1">
                        <div className="flex items-start justify-between gap-3">
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
                          {f.level && (
                            <span className="text-[10px] font-semibold uppercase tracking-wider px-2 py-0.5 rounded-md bg-signal-500/15 border border-signal-500/30 text-signal-300">
                              Niveau {f.level}
                            </span>
                          )}
                        </div>

                        <div className="mt-4 text-[11px] font-semibold uppercase tracking-[0.16em] text-white/50">
                          {f.code}
                        </div>
                        <h3 className="mt-1 font-display text-lg font-semibold leading-tight">
                          {f.title}
                        </h3>
                        <p className="mt-2 text-sm text-white/65 leading-relaxed">
                          {f.tagline}
                        </p>

                        <div className="mt-5 flex items-center gap-3 text-xs text-white/55">
                          <span className="inline-flex items-center gap-1.5">
                            <Clock className="h-3.5 w-3.5" />
                            {f.duration}
                          </span>
                          {f.rncpCode && (
                            <span className="inline-flex items-center gap-1.5">
                              <Award className="h-3.5 w-3.5" />
                              {f.rncpCode}
                            </span>
                          )}
                        </div>

                        <div className="mt-5 flex flex-wrap gap-1.5">
                          {f.funding.map((k) => (
                            <span
                              key={k}
                              className={
                                "text-[10px] uppercase tracking-wider px-2 py-0.5 rounded-md border " +
                                (finance === k
                                  ? "bg-signal-500/20 border-signal-500/40 text-signal-300"
                                  : "bg-white/5 border-white/10 text-white/55")
                              }
                            >
                              {FUNDING_LABELS[k]}
                            </span>
                          ))}
                        </div>

                        <div className="mt-auto pt-6">
                          <Link
                            href={`/formations/${f.slug}`}
                            className="inline-flex items-center gap-1.5 text-sm font-medium text-signal-400 hover:text-signal-300 transition-colors duration-200"
                          >
                            Voir la formation
                            <ArrowRight className="h-3.5 w-3.5" />
                          </Link>
                        </div>
                      </div>
                    </article>
                  );
                })}
              </div>
            </section>
          ))
        )}
      </main>
    </SiteShell>
  );
}

function FilterPill({
  href,
  label,
  active,
  variant = "default",
}: {
  href: string;
  label: string;
  active: boolean;
  variant?: "default" | "brand";
}) {
  const activeCls =
    variant === "brand"
      ? "bg-signal-500 text-night border-signal-500"
      : "bg-white text-night border-white";
  const inactiveCls = "bg-white/5 text-white/70 border-white/10 hover:bg-white/10";
  return (
    <Link
      href={href}
      className={
        "inline-flex shrink-0 items-center whitespace-nowrap px-3 py-1.5 rounded-full text-xs font-medium border transition " +
        (active ? activeCls : inactiveCls)
      }
    >
      {label}
    </Link>
  );
}
