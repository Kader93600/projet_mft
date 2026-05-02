// Layout commun pour les pages publiques (vitrine).
import Link from "next/link";
import { ArrowRight } from "lucide-react";
import { Logo } from "@/components/ui/logo";
import { LegalFooter } from "@/components/legal/legal-footer";
import { LEGAL } from "@/lib/legal-config";

export function SiteShell({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-night text-white">
      <SiteHeader />
      {children}
      <SiteFooterContact />
      <LegalFooter variant="dark" />
    </div>
  );
}

export function SiteHeader() {
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
          <Link href="/temoignages" className="hover:text-white transition">
            Témoignages
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

function SiteFooterContact() {
  return (
    <section className="bg-night border-t border-white/5">
      <div className="max-w-7xl mx-auto px-6 py-12 grid md:grid-cols-3 gap-10">
        <div>
          <Logo variant="light" size="md" />
          <p className="mt-4 text-sm text-white/60 leading-relaxed">
            {LEGAL.shortDescription}
          </p>
        </div>
        <div>
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
                Contact
              </Link>
            </li>
            <li>
              <Link href="/login" className="hover:text-white">
                Espace stagiaire
              </Link>
            </li>
          </ul>
        </div>
        <div>
          <div className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-400 mb-3">
            Contact
          </div>
          <div className="space-y-1.5 text-sm text-white/70">
            <div>{LEGAL.address.street}</div>
            <div>
              {LEGAL.address.postalCode} {LEGAL.address.city}
            </div>
            <a
              href={`mailto:${LEGAL.email}`}
              className="block hover:text-white"
            >
              {LEGAL.email}
            </a>
            <a
              href={`tel:${LEGAL.phone.replace(/\s/g, "")}`}
              className="block hover:text-white"
            >
              {LEGAL.phone}
            </a>
          </div>
        </div>
      </div>
    </section>
  );
}

/** Hero hauteur réduite pour pages internes. */
export function PageHero({
  eyebrow,
  title,
  description,
}: {
  eyebrow: string;
  title: React.ReactNode;
  description?: React.ReactNode;
}) {
  return (
    <section className="relative overflow-hidden border-b border-white/5">
      <div className="absolute inset-0 bg-mesh-night opacity-80" />
      <div
        className="absolute inset-0 bg-grid-night opacity-30"
        style={{
          backgroundSize: "56px 56px",
          maskImage:
            "linear-gradient(to bottom, black 0%, black 50%, transparent 100%)",
        }}
      />
      <div className="relative max-w-7xl mx-auto px-6 py-16 md:py-24 text-center">
        <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-400">
          {eyebrow}
        </span>
        <h1 className="mt-3 font-display text-4xl md:text-6xl font-semibold tracking-[-0.02em] leading-[1.05]">
          {title}
        </h1>
        {description && (
          <p className="mt-5 text-white/70 text-lg max-w-2xl mx-auto">
            {description}
          </p>
        )}
      </div>
    </section>
  );
}
