"use client";
import { useCallback, useEffect, useRef, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { BookOpen, ClipboardCheck, FileText, Library, Search, X } from "lucide-react";
import { cn } from "@/lib/utils";

type Result = {
  kind: "module" | "lesson" | "quiz" | "glossary";
  id: string;
  title: string;
  subtitle: string;
  url: string;
  bloc_code: string;
  rank: number;
};

const ICONS = {
  module: BookOpen,
  lesson: FileText,
  quiz: ClipboardCheck,
  glossary: Library,
} as const;

const KIND_LABEL: Record<Result["kind"], string> = {
  module: "Module",
  lesson: "Leçon",
  quiz: "Quiz",
  glossary: "Glossaire",
};

export function SearchPalette() {
  const [open, setOpen] = useState(false);
  const [q, setQ] = useState("");
  const [results, setResults] = useState<Result[]>([]);
  const [loading, setLoading] = useState(false);
  const [cursor, setCursor] = useState(0);
  const inputRef = useRef<HTMLInputElement>(null);
  const router = useRouter();

  // Raccourcis clavier
  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === "k") {
        e.preventDefault();
        setOpen((v) => !v);
      } else if (e.key === "/" && document.activeElement?.tagName !== "INPUT" && document.activeElement?.tagName !== "TEXTAREA") {
        e.preventDefault();
        setOpen(true);
      } else if (e.key === "Escape") {
        setOpen(false);
      }
    }
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, []);

  useEffect(() => {
    if (open) {
      setTimeout(() => inputRef.current?.focus(), 40);
    } else {
      setQ("");
      setResults([]);
      setCursor(0);
    }
  }, [open]);

  // Debounced fetch
  useEffect(() => {
    if (q.trim().length < 2) {
      setResults([]);
      return;
    }
    const ctrl = new AbortController();
    const t = setTimeout(async () => {
      setLoading(true);
      try {
        const r = await fetch(`/api/search?q=${encodeURIComponent(q)}`, {
          signal: ctrl.signal,
        });
        const j = await r.json();
        setResults(j.results ?? []);
        setCursor(0);
      } catch {
        /* noop */
      } finally {
        setLoading(false);
      }
    }, 180);
    return () => {
      ctrl.abort();
      clearTimeout(t);
    };
  }, [q]);

  const go = useCallback(
    (r: Result) => {
      setOpen(false);
      router.push(r.url);
    },
    [router]
  );

  function onKey(e: React.KeyboardEvent<HTMLInputElement>) {
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setCursor((c) => Math.min(c + 1, results.length - 1));
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setCursor((c) => Math.max(c - 1, 0));
    } else if (e.key === "Enter") {
      e.preventDefault();
      const r = results[cursor];
      if (r) go(r);
      else if (q.trim().length >= 2) {
        setOpen(false);
        router.push(`/recherche?q=${encodeURIComponent(q)}`);
      }
    }
  }

  return (
    <>
      {/* Trigger */}
      <button
        type="button"
        onClick={() => setOpen(true)}
        aria-label="Rechercher (Ctrl+K)"
        className="inline-flex items-center gap-2 h-9 px-3 rounded-xl border border-navy-100 bg-ivory text-sm text-slate-500 hover:text-navy-900 hover:border-navy-200"
      >
        <Search className="h-4 w-4" />
        <span className="hidden md:inline">Rechercher…</span>
        <kbd className="hidden md:inline ml-2 px-1.5 py-0.5 rounded bg-white border border-navy-100 text-[10px] font-mono text-slate-500">
          ⌘K
        </kbd>
      </button>

      {open && (
        <div
          role="dialog"
          aria-label="Recherche globale"
          className="fixed inset-0 z-[80] flex items-start justify-center pt-[10vh] px-4"
        >
          <div
            className="absolute inset-0 bg-navy-950/60 backdrop-blur-sm"
            onClick={() => setOpen(false)}
          />
          <div className="relative w-full max-w-2xl rounded-2xl bg-white shadow-raised border border-navy-100 overflow-hidden">
            <div className="flex items-center gap-3 px-4 py-3 border-b border-navy-100">
              <Search className="h-4 w-4 text-slate-400" />
              <input
                ref={inputRef}
                value={q}
                onChange={(e) => setQ(e.target.value)}
                onKeyDown={onKey}
                placeholder="Rechercher un module, une leçon, un quiz, un terme…"
                className="flex-1 bg-transparent outline-none text-[15px] text-navy-900 placeholder:text-slate-400"
              />
              <button
                onClick={() => setOpen(false)}
                className="h-7 w-7 rounded-lg hover:bg-navy-50 flex items-center justify-center text-slate-500"
                aria-label="Fermer"
              >
                <X className="h-4 w-4" />
              </button>
            </div>

            <div className="max-h-[50vh] overflow-y-auto">
              {loading && (
                <div className="px-4 py-6 text-sm text-slate-500">Recherche…</div>
              )}
              {!loading && q.trim().length < 2 && (
                <div className="px-4 py-6 text-sm text-slate-500">
                  Tapez au moins 2 caractères. Utilisez <kbd className="px-1 border rounded">↑</kbd>{" "}
                  <kbd className="px-1 border rounded">↓</kbd> pour naviguer,{" "}
                  <kbd className="px-1 border rounded">Entrée</kbd> pour ouvrir.
                </div>
              )}
              {!loading && q.trim().length >= 2 && results.length === 0 && (
                <div className="px-4 py-6 text-sm text-slate-500">Aucun résultat.</div>
              )}
              {results.map((r, i) => {
                const Icon = ICONS[r.kind];
                const active = i === cursor;
                return (
                  <button
                    key={`${r.kind}-${r.id}`}
                    type="button"
                    onClick={() => go(r)}
                    onMouseEnter={() => setCursor(i)}
                    className={cn(
                      "w-full text-left flex items-start gap-3 px-4 py-3 border-b border-navy-50 last:border-0",
                      active ? "bg-gold-50" : "hover:bg-navy-50"
                    )}
                  >
                    <div
                      className={cn(
                        "h-9 w-9 rounded-lg flex items-center justify-center shrink-0",
                        active
                          ? "bg-gold-500 text-navy-900"
                          : "bg-navy-50 text-navy-700"
                      )}
                    >
                      <Icon className="h-4 w-4" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2">
                        <span className="text-[10px] font-semibold uppercase tracking-wide text-slate-500">
                          {KIND_LABEL[r.kind]}
                        </span>
                        {r.bloc_code && r.bloc_code !== "—" && (
                          <span className="text-[10px] font-semibold px-1.5 py-0.5 rounded bg-navy-100 text-navy-800">
                            {r.bloc_code}
                          </span>
                        )}
                      </div>
                      <div className="font-medium text-navy-900 text-[15px] truncate">
                        {r.title}
                      </div>
                      <div className="text-xs text-slate-500 truncate">{r.subtitle}</div>
                    </div>
                  </button>
                );
              })}
            </div>

            {q.trim().length >= 2 && (
              <div className="border-t border-navy-100 px-4 py-2 flex items-center justify-between text-[11px] text-slate-500 bg-ivory">
                <span>{results.length} résultat{results.length > 1 ? "s" : ""}</span>
                <Link
                  href={`/recherche?q=${encodeURIComponent(q)}`}
                  onClick={() => setOpen(false)}
                  className="font-medium text-navy-900 hover:text-gold-700"
                >
                  Voir tous les résultats →
                </Link>
              </div>
            )}
          </div>
        </div>
      )}
    </>
  );
}
