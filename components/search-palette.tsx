"use client";
import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useTranslations } from "next-intl";
import {
  ArrowRight,
  BookOpen,
  ClipboardCheck,
  Command as CommandIcon,
  FileText,
  Library,
  Search,
  X,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { STUDENT_GROUPS, ADMIN_GROUPS } from "@/components/nav-groups";

type Result = {
  kind: "module" | "lesson" | "quiz" | "glossary";
  id: string;
  title: string;
  subtitle: string;
  url: string;
  bloc_code: string;
  rank: number;
};

// Commande de navigation (réutilise le registre nav-groups, role-aware).
type Command = {
  href: string;
  label: string;
  group: string;
  icon: any;
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

type Role = "student" | "trainer" | "admin" | "super_admin";

export function SearchPalette({ role = "student" }: { role?: Role }) {
  const [open, setOpen] = useState(false);
  const [q, setQ] = useState("");
  const [results, setResults] = useState<Result[]>([]);
  const [loading, setLoading] = useState(false);
  const [cursor, setCursor] = useState(0);
  const inputRef = useRef<HTMLInputElement>(null);
  const router = useRouter();
  const t = useTranslations();

  // ── Commandes de navigation, filtrées par rôle ──────────────────────
  // Tout le monde voit la nav stagiaire ; admin/super_admin ajoutent la
  // nav admin. (Cohérent avec ce que l'AppShell expose déjà.)
  const commands = useMemo<Command[]>(() => {
    const groups =
      role === "admin" || role === "super_admin"
        ? [...STUDENT_GROUPS, ...ADMIN_GROUPS]
        : STUDENT_GROUPS;
    return groups.flatMap((g) =>
      g.items.map((it) => ({
        href: it.href,
        label: t(it.labelKey),
        group: t(g.labelKey),
        icon: it.icon,
      })),
    );
  }, [role, t]);

  // Commandes filtrées par la saisie (match libellé ou href).
  const cmdMatches = useMemo(() => {
    const term = q.trim().toLowerCase();
    if (!term) return commands; // requête vide → menu de navigation complet
    return commands.filter(
      (c) =>
        c.label.toLowerCase().includes(term) ||
        c.href.toLowerCase().includes(term),
    );
  }, [q, commands]);

  // Quand on tape, on borne les commandes pour laisser de la place au
  // contenu ; à vide, on montre tout (c'est le « menu »).
  const shownCommands = q.trim() ? cmdMatches.slice(0, 6) : cmdMatches;

  // Liste unifiée pour la navigation clavier : commandes puis contenu.
  const navItems = useMemo(
    () => [
      ...shownCommands.map((c) => ({ type: "cmd" as const, cmd: c })),
      ...results.map((r) => ({ type: "result" as const, result: r })),
    ],
    [shownCommands, results],
  );

  // Raccourcis clavier globaux (⌘K / Ctrl+K, "/", Esc)
  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === "k") {
        e.preventDefault();
        setOpen((v) => !v);
      } else if (
        e.key === "/" &&
        document.activeElement?.tagName !== "INPUT" &&
        document.activeElement?.tagName !== "TEXTAREA"
      ) {
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

  // Réinitialise le curseur quand la liste change.
  useEffect(() => {
    setCursor(0);
  }, [q]);

  // Recherche de contenu (debounce) — inchangée.
  useEffect(() => {
    if (q.trim().length < 2) {
      setResults([]);
      return;
    }
    const ctrl = new AbortController();
    const timer = setTimeout(async () => {
      setLoading(true);
      try {
        const r = await fetch(`/api/search?q=${encodeURIComponent(q)}`, {
          signal: ctrl.signal,
        });
        const j = await r.json();
        setResults(j.results ?? []);
      } catch {
        /* noop */
      } finally {
        setLoading(false);
      }
    }, 180);
    return () => {
      ctrl.abort();
      clearTimeout(timer);
    };
  }, [q]);

  const goResult = useCallback(
    (r: Result) => {
      setOpen(false);
      router.push(r.url);
    },
    [router],
  );

  const goCommand = useCallback(
    (c: Command) => {
      setOpen(false);
      router.push(c.href);
    },
    [router],
  );

  function onKey(e: React.KeyboardEvent<HTMLInputElement>) {
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setCursor((c) => Math.min(c + 1, navItems.length - 1));
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setCursor((c) => Math.max(c - 1, 0));
    } else if (e.key === "Enter") {
      e.preventDefault();
      const sel = navItems[cursor];
      if (sel?.type === "cmd") goCommand(sel.cmd);
      else if (sel?.type === "result") goResult(sel.result);
      else if (q.trim().length >= 2) {
        setOpen(false);
        router.push(`/recherche?q=${encodeURIComponent(q)}`);
      }
    }
  }

  const hasQuery = q.trim().length >= 2;

  return (
    <>
      {/* Trigger */}
      <button
        type="button"
        onClick={() => setOpen(true)}
        aria-label="Rechercher ou naviguer (Ctrl+K)"
        className="inline-flex items-center gap-2 h-9 px-3 rounded-xl border border-navy-100 bg-ivory text-sm text-slate-500 hover:text-navy-900 hover:border-navy-200"
      >
        <Search className="h-4 w-4" />
        <span className="hidden md:inline">Rechercher ou naviguer…</span>
        <kbd className="hidden md:inline ml-2 px-1.5 py-0.5 rounded bg-white border border-navy-100 text-[10px] font-mono text-slate-500">
          ⌘K
        </kbd>
      </button>

      {open && (
        <div
          role="dialog"
          aria-label="Recherche et navigation"
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
                placeholder="Aller à une page, ou rechercher un module, une leçon, un terme…"
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
              {/* ── Commandes (navigation) ── */}
              {shownCommands.length > 0 && (
                <div>
                  <div className="px-4 pt-3 pb-1 text-[10px] font-semibold uppercase tracking-wider text-slate-400 flex items-center gap-1.5">
                    <CommandIcon className="h-3 w-3" />
                    {hasQuery ? "Commandes" : "Navigation"}
                  </div>
                  {shownCommands.map((c, i) => {
                    const Icon = c.icon;
                    const active = i === cursor;
                    return (
                      <button
                        key={c.href}
                        type="button"
                        onClick={() => goCommand(c)}
                        onMouseEnter={() => setCursor(i)}
                        className={cn(
                          "w-full text-left flex items-center gap-3 px-4 py-2.5",
                          active ? "bg-gold-50" : "hover:bg-navy-50",
                        )}
                      >
                        <div
                          className={cn(
                            "h-8 w-8 rounded-lg flex items-center justify-center shrink-0",
                            active
                              ? "bg-gold-500 text-navy-900"
                              : "bg-navy-50 text-navy-700",
                          )}
                        >
                          <Icon className="h-4 w-4" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="font-medium text-navy-900 text-[14px] truncate">
                            {c.label}
                          </div>
                          <div className="text-[11px] text-slate-400 truncate">
                            {c.group}
                          </div>
                        </div>
                        {active && (
                          <ArrowRight className="h-3.5 w-3.5 text-gold-700 shrink-0" />
                        )}
                      </button>
                    );
                  })}
                </div>
              )}

              {/* ── Contenu (recherche) ── */}
              {loading && (
                <div className="px-4 py-4 text-sm text-slate-500">
                  Recherche…
                </div>
              )}
              {hasQuery && results.length > 0 && (
                <div className="px-4 pt-3 pb-1 text-[10px] font-semibold uppercase tracking-wider text-slate-400 flex items-center gap-1.5 border-t border-navy-50">
                  <Search className="h-3 w-3" />
                  Contenu
                </div>
              )}
              {results.map((r, i) => {
                const Icon = ICONS[r.kind];
                const idx = shownCommands.length + i;
                const active = idx === cursor;
                return (
                  <button
                    key={`${r.kind}-${r.id}`}
                    type="button"
                    onClick={() => goResult(r)}
                    onMouseEnter={() => setCursor(idx)}
                    className={cn(
                      "w-full text-left flex items-start gap-3 px-4 py-3 border-b border-navy-50 last:border-0",
                      active ? "bg-gold-50" : "hover:bg-navy-50",
                    )}
                  >
                    <div
                      className={cn(
                        "h-9 w-9 rounded-lg flex items-center justify-center shrink-0",
                        active
                          ? "bg-gold-500 text-navy-900"
                          : "bg-navy-50 text-navy-700",
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
                      <div className="text-xs text-slate-500 truncate">
                        {r.subtitle}
                      </div>
                    </div>
                  </button>
                );
              })}

              {/* États vides */}
              {hasQuery &&
                !loading &&
                results.length === 0 &&
                cmdMatches.length === 0 && (
                  <div className="px-4 py-6 text-sm text-slate-500">
                    Aucun résultat.
                  </div>
                )}
            </div>

            {/* Pied : aide clavier + lien recherche complète */}
            <div className="border-t border-navy-100 px-4 py-2 flex items-center justify-between text-[11px] text-slate-500 bg-ivory">
              <span className="hidden sm:flex items-center gap-2">
                <kbd className="px-1 border rounded">↑</kbd>
                <kbd className="px-1 border rounded">↓</kbd>
                naviguer
                <kbd className="px-1 border rounded ml-1">↵</kbd>
                ouvrir
                <kbd className="px-1 border rounded ml-1">esc</kbd>
                fermer
              </span>
              {hasQuery && (
                <Link
                  href={`/recherche?q=${encodeURIComponent(q)}`}
                  onClick={() => setOpen(false)}
                  className="font-medium text-navy-900 hover:text-gold-700"
                >
                  Voir tous les résultats →
                </Link>
              )}
            </div>
          </div>
        </div>
      )}
    </>
  );
}
