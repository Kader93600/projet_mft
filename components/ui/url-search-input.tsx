"use client";

import { useEffect, useRef, useState } from "react";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { Search } from "lucide-react";
import { cn } from "@/lib/utils";

/**
 * Champ de recherche qui pilote un paramètre d'URL (debounce 300 ms), pour
 * les listes rendues côté serveur (Server Components). Réinitialise `page`
 * à chaque nouvelle recherche. Réutilisable (CRM, sessions, etc.).
 */
export function UrlSearchInput({
  param = "q",
  placeholder = "Rechercher…",
  className,
}: {
  param?: string;
  placeholder?: string;
  className?: string;
}) {
  const router = useRouter();
  const pathname = usePathname();
  const params = useSearchParams();
  const [value, setValue] = useState(params.get(param) ?? "");
  const first = useRef(true);

  // Resync si l'URL change ailleurs (navigation, reset de filtre…).
  useEffect(() => {
    setValue(params.get(param) ?? "");
  }, [params, param]);

  useEffect(() => {
    if (first.current) {
      first.current = false;
      return;
    }
    const id = setTimeout(() => {
      const next = new URLSearchParams(params.toString());
      const v = value.trim();
      if (v) next.set(param, v);
      else next.delete(param);
      next.delete("page");
      const qs = next.toString();
      router.replace(qs ? `${pathname}?${qs}` : pathname, { scroll: false });
    }, 300);
    return () => clearTimeout(id);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [value]);

  return (
    <div className={cn("relative", className)}>
      <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
      <input
        type="search"
        value={value}
        onChange={(e) => setValue(e.target.value)}
        placeholder={placeholder}
        className="h-10 w-full rounded-lg border border-navy-200 bg-white pl-9 pr-3 text-sm text-navy-900 placeholder:text-slate-400 focus:border-navy-600 focus:outline-none focus:ring-2 focus:ring-navy-600/15 dark:bg-[hsl(var(--surface))] dark:text-[hsl(var(--text))] dark:border-[hsl(var(--border))]"
      />
    </div>
  );
}
