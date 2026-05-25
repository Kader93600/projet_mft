"use client";

import { cn } from "@/lib/utils";
import { ChevronUp, ChevronDown, ChevronsUpDown } from "lucide-react";

export type SortDir = "asc" | "desc";
export interface SortState<K extends string = string> {
  key: K | null;
  dir: SortDir;
}

/**
 * Bascule de tri : recliquer la même colonne inverse le sens, sinon on passe
 * sur la nouvelle colonne en ordre ascendant.
 */
export function nextSort<K extends string>(cur: SortState<K>, key: K): SortState<K> {
  return cur.key === key
    ? { key, dir: cur.dir === "asc" ? "desc" : "asc" }
    : { key, dir: "asc" };
}

/** Comparateurs prêts à l'emploi (FR-aware pour les chaînes). */
export const cmpStr = (a: string | null | undefined, b: string | null | undefined) =>
  (a ?? "").localeCompare(b ?? "", "fr");
export const cmpNum = (a: number | null | undefined, b: number | null | undefined) =>
  (a ?? 0) - (b ?? 0);

/**
 * En-tête de colonne triable, cohérent dans tout le back-office : clic = tri,
 * chevron ↑/↓ sur la colonne active, indice discret au survol des autres.
 */
export function SortHeader<K extends string>({
  label,
  col,
  sort,
  onSort,
  align = "left",
  className,
}: {
  label: string;
  col: K;
  sort: SortState<K>;
  onSort: (k: K) => void;
  align?: "left" | "right";
  className?: string;
}) {
  const active = sort.key === col;
  return (
    <th
      aria-sort={active ? (sort.dir === "asc" ? "ascending" : "descending") : "none"}
      className={cn(
        "px-4 py-3 font-semibold",
        align === "right" ? "text-right" : "text-left",
        className
      )}
    >
      <button
        type="button"
        onClick={() => onSort(col)}
        className={cn(
          "group/sort inline-flex items-center gap-1 uppercase tracking-wider transition-colors hover:text-navy-900 dark:hover:text-[hsl(var(--text))]",
          align === "right" && "flex-row-reverse",
          active && "text-navy-900 dark:text-[hsl(var(--text))]"
        )}
      >
        <span>{label}</span>
        {active ? (
          sort.dir === "asc" ? (
            <ChevronUp className="h-3.5 w-3.5" />
          ) : (
            <ChevronDown className="h-3.5 w-3.5" />
          )
        ) : (
          <ChevronsUpDown className="h-3.5 w-3.5 opacity-0 transition-opacity group-hover/sort:opacity-60" />
        )}
      </button>
    </th>
  );
}
