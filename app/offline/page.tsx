import Link from "next/link";
import { getTranslations } from "next-intl/server";
import { WifiOff, RefreshCw } from "lucide-react";

export const metadata = {
  title: "Hors connexion",
};

/**
 * Page affichée par le service worker quand l'utilisateur tente une
 * navigation alors qu'il n'a plus de réseau.
 *
 * Précachée à l'install du SW (cf. public/sw.js).
 */
export default async function OfflinePage() {
  const t = await getTranslations("offline");

  return (
    <main className="min-h-screen bg-ivory dark:bg-[hsl(var(--bg))] text-navy-900 dark:text-[hsl(var(--text))] flex items-center justify-center px-6">
      <div className="max-w-md text-center">
        <div className="mx-auto h-16 w-16 rounded-2xl bg-navy-50 dark:bg-[hsl(var(--surface))] text-navy-900 dark:text-signal-300 flex items-center justify-center mb-6 border border-navy-100 dark:border-[hsl(var(--border))]">
          <WifiOff className="h-7 w-7" />
        </div>
        <h1 className="font-display text-2xl md:text-3xl font-semibold tracking-tight">
          {t("title")}
        </h1>
        <p className="mt-3 text-slate-600 dark:text-[hsl(var(--text-muted))] text-[15px] leading-relaxed">
          {t("description")}
        </p>
        <div className="mt-7 flex items-center justify-center gap-3 flex-wrap">
          <a
            href="/dashboard"
            className="inline-flex items-center gap-2 h-11 px-5 rounded-xl bg-navy-900 text-white dark:bg-signal-500 dark:text-navy-950 font-semibold text-sm hover:bg-navy-800 dark:hover:bg-signal-400 transition"
          >
            <RefreshCw className="h-4 w-4" />
            {t("retry")}
          </a>
          <Link
            href="/"
            className="inline-flex items-center gap-2 h-11 px-5 rounded-xl border border-navy-200 dark:border-[hsl(var(--border))] text-navy-900 dark:text-[hsl(var(--text))] font-semibold text-sm hover:bg-navy-50 dark:hover:bg-[hsl(var(--surface))] transition"
          >
            {t("home")}
          </Link>
        </div>
        <p className="mt-8 text-xs text-slate-400 dark:text-[hsl(var(--text-muted))]">
          {t("tip")}
        </p>
      </div>
    </main>
  );
}
