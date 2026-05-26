"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { Search } from "lucide-react";
import { DOC_REASONS, DOC_STATUS } from "@/lib/student-documents";

export function DocumentsFilters({
  formations,
}: {
  formations: { id: string; title: string }[];
}) {
  const router = useRouter();
  const params = useSearchParams();
  const [q, setQ] = useState(params?.get("q") ?? "");
  const firstRender = useRef(true);

  function apply(next: URLSearchParams) {
    router.replace(`?${next.toString()}`, { scroll: false });
  }

  function setParam(key: string, value: string) {
    const next = new URLSearchParams(params?.toString() ?? "");
    if (value) next.set(key, value);
    else next.delete(key);
    apply(next);
  }

  // Recherche stagiaire debouncée.
  useEffect(() => {
    if (firstRender.current) {
      firstRender.current = false;
      return;
    }
    const id = setTimeout(() => setParam("q", q.trim()), 350);
    return () => clearTimeout(id);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [q]);

  const selectCls =
    "h-10 rounded-lg border border-navy-200 bg-white px-3 text-sm text-navy-900 focus:border-navy-600 focus:outline-none focus:ring-2 focus:ring-navy-600/15 dark:border-[hsl(var(--border))] dark:bg-[hsl(var(--surface))] dark:text-[hsl(var(--text))]";

  return (
    <div className="flex flex-wrap items-center gap-2">
      <div className="relative">
        <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
        <input
          value={q}
          onChange={(e) => setQ(e.target.value)}
          placeholder="Rechercher un stagiaire…"
          className="h-10 w-56 rounded-lg border border-navy-200 bg-white pl-9 pr-3 text-sm text-navy-900 focus:border-navy-600 focus:outline-none focus:ring-2 focus:ring-navy-600/15 dark:border-[hsl(var(--border))] dark:bg-[hsl(var(--surface))] dark:text-[hsl(var(--text))]"
        />
      </div>

      <select
        value={params?.get("formation") ?? ""}
        onChange={(e) => setParam("formation", e.target.value)}
        className={selectCls}
      >
        <option value="">Toutes formations</option>
        {formations.map((f) => (
          <option key={f.id} value={f.id}>
            {f.title}
          </option>
        ))}
      </select>

      <select
        value={params?.get("motif") ?? ""}
        onChange={(e) => setParam("motif", e.target.value)}
        className={selectCls}
      >
        <option value="">Tous motifs</option>
        {DOC_REASONS.map((r) => (
          <option key={r.key} value={r.key}>
            {r.label}
          </option>
        ))}
      </select>

      <select
        value={params?.get("statut") ?? ""}
        onChange={(e) => setParam("statut", e.target.value)}
        className={selectCls}
      >
        <option value="">Tous statuts</option>
        {Object.entries(DOC_STATUS).map(([k, v]) => (
          <option key={k} value={k}>
            {v.label}
          </option>
        ))}
      </select>

      {/* Tri (liste de cartes → menu déroulant plutôt qu'en-têtes) */}
      <select
        value={params?.get("sort") ?? ""}
        onChange={(e) => setParam("sort", e.target.value)}
        className={selectCls}
        aria-label="Trier les documents"
      >
        <option value="">Tri : plus récents</option>
        <option value="date_asc">Plus anciens</option>
        <option value="name">Stagiaire (A→Z)</option>
        <option value="statut">Statut</option>
        <option value="formation">Formation</option>
      </select>
    </div>
  );
}
