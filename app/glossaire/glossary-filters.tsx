"use client";

import { useEffect, useRef, useState } from "react";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";
import { Search } from "lucide-react";

/**
 * Filtres glossaire — auto-submit avec debounce.
 *
 * - L'input de recherche met à jour l'URL après 250 ms d'inactivité au
 *   clavier → la page se re-render server-side avec les nouvelles
 *   searchParams. Pas de bouton "Filtrer" nécessaire.
 * - Les dropdowns (formation / bloc) auto-submit immédiatement au
 *   changement de valeur.
 * - Le lien "Réinitialiser" garde son comportement (Link vers /glossaire).
 *
 * Côté serveur, GlossairePage continue de lire searchParams comme avant
 * — aucune autre modification de la page n'est nécessaire.
 */
export function GlossaryFilters({
  initialQ,
  initialFormation,
  initialBloc,
  formations,
  blocs,
  hasTransversalBloc,
}: {
  initialQ: string;
  initialFormation: string;
  initialBloc: string;
  formations: Array<{ slug: string; code: string; title: string }>;
  blocs: Array<{ id: number; code: string; title: string }>;
  hasTransversalBloc: boolean;
}) {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();

  const [q, setQ] = useState(initialQ);
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  // Re-sync si l'URL change de manière externe (lien Réinitialiser, back…)
  useEffect(() => {
    setQ(searchParams.get("q") ?? "");
  }, [searchParams]);

  function updateUrl(patch: Record<string, string>) {
    const sp = new URLSearchParams(searchParams.toString());
    for (const [k, v] of Object.entries(patch)) {
      if (v) sp.set(k, v);
      else sp.delete(k);
    }
    const qs = sp.toString();
    router.replace(qs ? `${pathname}?${qs}` : pathname);
  }

  function onQChange(next: string) {
    setQ(next);
    if (debounceRef.current) clearTimeout(debounceRef.current);
    debounceRef.current = setTimeout(() => {
      updateUrl({ q: next.trim() });
    }, 250);
  }

  const hasAnyFilter = !!(q || initialFormation || initialBloc);

  return (
    <div className="flex flex-wrap gap-2 items-center">
      <div className="relative flex-1 min-w-[240px]">
        <Search className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
        <input
          type="search"
          value={q}
          onChange={(e) => onQChange(e.target.value)}
          placeholder="Rechercher un terme, une définition…"
          autoComplete="off"
          className="h-10 w-full rounded-xl border border-navy-200 bg-white pl-9 pr-3 text-sm text-navy-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-navy-600/15 focus:border-navy-600"
        />
      </div>

      {formations.length > 1 && (
        <select
          value={initialFormation}
          onChange={(e) => updateUrl({ formation: e.target.value })}
          className="h-10 rounded-xl border border-navy-200 bg-white px-3 text-sm text-navy-900"
        >
          <option value="">Mes formations</option>
          {formations.map((f) => (
            <option key={f.slug} value={f.slug}>
              {f.code} — {f.title}
            </option>
          ))}
          <option value="none">Transversal</option>
        </select>
      )}

      {blocs.length > 0 && (
        <select
          value={initialBloc}
          onChange={(e) => updateUrl({ bloc: e.target.value })}
          className="h-10 rounded-xl border border-navy-200 bg-white px-3 text-sm text-navy-900"
        >
          <option value="">Tous les blocs</option>
          {blocs.map((b) => (
            <option key={b.id} value={String(b.id)}>
              {b.code} — {b.title}
            </option>
          ))}
          {hasTransversalBloc && <option value="none">Transversal</option>}
        </select>
      )}

      {hasAnyFilter && (
        <Link
          href="/glossaire"
          className="h-10 inline-flex items-center px-3 rounded-xl text-sm text-slate-600 hover:text-navy-900"
        >
          Réinitialiser
        </Link>
      )}
    </div>
  );
}
