import Link from "next/link";
import { ArrowLeft, Home, Search, Compass } from "lucide-react";
import { Logo } from "@/components/ui/logo";
import { LegalFooter } from "@/components/legal/legal-footer";

export default function NotFound() {
  return (
    <div className="min-h-screen bg-night text-white flex flex-col">
      <header className="border-b border-white/5">
        <div className="max-w-7xl mx-auto px-6 h-16 flex items-center">
          <Link href="/">
            <Logo variant="light" size="sm" />
          </Link>
        </div>
      </header>

      <main className="flex-1 flex items-center justify-center px-6 py-20">
        <div className="max-w-md text-center">
          <div className="relative inline-block mb-8">
            <div
              aria-hidden="true"
              className="absolute inset-0 bg-signal-500/20 blur-3xl"
            />
            <div className="relative font-display text-8xl md:text-9xl font-bold bg-gradient-to-br from-signal-300 via-signal-500 to-brand-500 bg-clip-text text-transparent">
              404
            </div>
          </div>

          <div className="inline-flex items-center gap-1.5 rounded-full border border-white/10 bg-white/5 px-3.5 py-1.5 text-xs font-medium text-white/70 mb-4">
            <Compass className="h-3.5 w-3.5 text-signal-400" />
            Mauvaise sortie
          </div>

          <h1 className="font-display text-3xl md:text-4xl font-semibold tracking-tight">
            Cette page n'existe pas.
          </h1>
          <p className="mt-4 text-white/65 leading-relaxed">
            Vous avez peut-être suivi un lien obsolète ou tapé une URL
            incorrecte. Pas de panique, on vous remet sur la bonne route.
          </p>

          <div className="mt-8 flex flex-wrap justify-center gap-3">
            <Link
              href="/"
              className="inline-flex items-center gap-2 rounded-2xl bg-signal-500 text-night px-5 py-3 text-sm font-semibold hover:bg-signal-400 transition shadow-glow-signal"
            >
              <Home className="h-4 w-4" />
              Retour à l'accueil
            </Link>
            <Link
              href="/formations"
              className="inline-flex items-center gap-2 rounded-2xl border border-white/15 bg-white/5 backdrop-blur px-5 py-3 text-sm font-semibold hover:bg-white/10 transition"
            >
              <Search className="h-4 w-4" />
              Voir nos formations
            </Link>
          </div>

          <Link
            href="/contact"
            className="mt-6 inline-flex items-center gap-1.5 text-sm text-white/50 hover:text-white"
          >
            <ArrowLeft className="h-3.5 w-3.5" />
            Contacter le support
          </Link>
        </div>
      </main>

      <LegalFooter variant="dark" />
    </div>
  );
}
