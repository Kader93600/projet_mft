"use client";

/**
 * Toggle de langue UI (FR / EN).
 *
 * Définit le cookie NEXT_LOCALE puis recharge la page : la prochaine
 * requête vers les Server Components passe par i18n/request.ts qui
 * lit le cookie et sert les bonnes traductions.
 *
 * Pas de routing /fr ou /en — l'URL reste inchangée. Compromis :
 * pas de SEO multilingue natif (à voir si besoin plus tard).
 */
import { useState, useTransition, useEffect } from "react";
import { useRouter } from "next/navigation";
import { Globe } from "lucide-react";
import { cn } from "@/lib/utils";

type Locale = "fr" | "en";

const LABELS: Record<Locale, string> = {
  fr: "FR",
  en: "EN",
};

const A11Y: Record<Locale, string> = {
  fr: "Français",
  en: "English",
};

export function LocaleToggle({ className }: { className?: string }) {
  const router = useRouter();
  const [, startTransition] = useTransition();
  const [current, setCurrent] = useState<Locale>("fr");

  // Lit la valeur du cookie au mount (côté client, après hydration)
  useEffect(() => {
    const m = document.cookie.match(/(?:^|; )NEXT_LOCALE=([^;]+)/);
    if (m && (m[1] === "fr" || m[1] === "en")) {
      setCurrent(m[1]);
    }
  }, []);

  function setLocale(loc: Locale) {
    if (loc === current) return;
    // Cookie 1 an, sameSite Lax, partagé sur tout le site
    document.cookie = `NEXT_LOCALE=${loc}; Path=/; Max-Age=${60 * 60 * 24 * 365}; SameSite=Lax`;
    setCurrent(loc);
    // Refresh des Server Components pour recharger les traductions
    startTransition(() => {
      router.refresh();
    });
  }

  return (
    <div
      role="group"
      aria-label="Choix de la langue"
      className={cn(
        "inline-flex items-center rounded-xl border border-navy-100 bg-ivory p-0.5",
        "dark:border-[hsl(var(--border))] dark:bg-[hsl(var(--surface-2))]",
        className
      )}
    >
      <Globe
        className="h-3 w-3 ml-1.5 text-slate-400 dark:text-[hsl(var(--text-muted))]"
        aria-hidden
      />
      {(["fr", "en"] as Locale[]).map((loc) => (
        <button
          key={loc}
          type="button"
          onClick={() => setLocale(loc)}
          aria-label={A11Y[loc]}
          aria-pressed={current === loc}
          title={A11Y[loc]}
          className={cn(
            "h-7 px-2 rounded-lg flex items-center justify-center text-[11px] font-semibold transition-colors",
            current === loc
              ? "bg-white text-navy-900 shadow-soft dark:bg-[hsl(var(--surface))] dark:text-[hsl(var(--text))]"
              : "text-slate-500 hover:text-navy-900 dark:text-[hsl(var(--text-muted))] dark:hover:text-[hsl(var(--text))]"
          )}
        >
          {LABELS[loc]}
        </button>
      ))}
    </div>
  );
}
