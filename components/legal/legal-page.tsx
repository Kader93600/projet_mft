import Link from "next/link";
import { ArrowLeft } from "lucide-react";

export function LegalPage({
  eyebrow,
  title,
  intro,
  children,
  lastUpdate,
}: {
  eyebrow: string;
  title: string;
  intro?: React.ReactNode;
  children: React.ReactNode;
  lastUpdate?: string;
}) {
  return (
    <div className="min-h-screen bg-ivory text-ink">
      <header className="bg-navy-950 text-white">
        <div className="max-w-3xl mx-auto px-6 py-12">
          <Link
            href="/"
            className="inline-flex items-center gap-1.5 text-sm text-white/60 hover:text-white"
          >
            <ArrowLeft className="h-4 w-4" /> Accueil
          </Link>
          <span className="block mt-6 text-[11px] font-semibold uppercase tracking-[0.18em] text-gold-300">
            {eyebrow}
          </span>
          <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold">
            {title}
          </h1>
          {intro && (
            <div className="mt-3 text-white/70 max-w-2xl text-[15px] leading-relaxed">
              {intro}
            </div>
          )}
        </div>
      </header>

      <main className="max-w-3xl mx-auto px-6 py-12 space-y-10 prose-legal">
        {children}
        {lastUpdate && (
          <div className="border-t border-navy-100 pt-6 text-sm text-slate-500">
            Dernière mise à jour : {lastUpdate}.
          </div>
        )}
      </main>
    </div>
  );
}

export function Section({
  number,
  title,
  children,
}: {
  number?: string;
  title: string;
  children: React.ReactNode;
}) {
  return (
    <section>
      <h2 className="font-display text-xl md:text-2xl font-semibold text-navy-950 mb-3">
        {number && (
          <span className="text-gold-700 font-mono mr-2">{number}.</span>
        )}
        {title}
      </h2>
      <div className="text-slate-700 leading-relaxed space-y-3">{children}</div>
    </section>
  );
}

export function DataRow({
  label,
  value,
}: {
  label: string;
  value: React.ReactNode;
}) {
  return (
    <div className="grid grid-cols-1 sm:grid-cols-3 gap-1 sm:gap-4 py-2 border-b border-navy-50 last:border-0">
      <dt className="text-sm text-slate-500 sm:col-span-1">{label}</dt>
      <dd className="text-sm text-navy-900 font-medium sm:col-span-2 break-words">
        {value}
      </dd>
    </div>
  );
}
