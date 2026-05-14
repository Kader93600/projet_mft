"use client";

import { useEffect, useState } from "react";
import { ChevronDown, Lock } from "lucide-react";
import { ModuleCard, type ModuleCardData } from "./module-card";
import type { ModuleProgress } from "@/lib/module-progress";

interface CcpBloc {
  code: string;
  title: string;
  ccpLabel: string;
  modules: (ModuleCardData & { __progress: ModuleProgress })[];
}

/**
 * Accordion CCP avec animation premium "grid-template-rows" :
 *
 *   grid-template-rows: 0fr → 1fr
 *   transition cubic-bezier(0.22, 1, 0.36, 1) 380ms
 *
 * Cette technique permet d'animer la hauteur EXACTE du contenu sans
 * connaître sa hauteur à l'avance (≠ max-height bricolage). GPU-friendly,
 * pas de saccade, accessible (les éléments restent dans le DOM).
 *
 * Bonus : chevron qui rotate, fade-in du contenu, persistence dans
 * localStorage du dernier état d'ouverture pour ne pas tout replier
 * au refresh.
 */
export function CcpAccordion({
  blocs,
  sectionIdx = 0,
  storageKey = "ccp-accordion",
}: {
  blocs: CcpBloc[];
  sectionIdx?: number;
  /** Clé localStorage pour persister l'état (1 par formation idéalement). */
  storageKey?: string;
}) {
  // Par défaut : ouvre tout (priorité à la découverte). Lecture
  // localStorage après mount pour éviter l'hydration mismatch.
  const [openSet, setOpenSet] = useState<Set<string>>(
    () => new Set(blocs.map((b) => b.code)),
  );
  const [hydrated, setHydrated] = useState(false);

  useEffect(() => {
    setHydrated(true);
    try {
      const raw = window.localStorage.getItem(storageKey);
      if (raw) {
        const arr = JSON.parse(raw);
        if (Array.isArray(arr)) {
          setOpenSet(new Set(arr.filter((s) => typeof s === "string")));
        }
      }
    } catch {
      /* ignore */
    }
  }, [storageKey]);

  const toggle = (code: string) => {
    const next = new Set(openSet);
    if (next.has(code)) next.delete(code);
    else next.add(code);
    setOpenSet(next);
    if (hydrated) {
      try {
        window.localStorage.setItem(storageKey, JSON.stringify([...next]));
      } catch {
        /* ignore */
      }
    }
  };

  const allOpen = blocs.every((b) => openSet.has(b.code));
  const setAll = (open: boolean) => {
    const next = new Set<string>(open ? blocs.map((b) => b.code) : []);
    setOpenSet(next);
    if (hydrated) {
      try {
        window.localStorage.setItem(storageKey, JSON.stringify([...next]));
      } catch {
        /* ignore */
      }
    }
  };

  return (
    <div className="space-y-6">
      {/* Bandeau actions globales */}
      <div className="flex items-center justify-end">
        <button
          type="button"
          onClick={() => setAll(!allOpen)}
          className="inline-flex items-center gap-1.5 text-[12px] font-semibold text-navy-700 hover:text-navy-950 transition px-2.5 py-1 rounded-md hover:bg-navy-50"
        >
          <ChevronDown
            className={
              "h-3.5 w-3.5 transition-transform duration-300 " +
              (allOpen ? "rotate-180" : "rotate-0")
            }
            style={{ transitionTimingFunction: "cubic-bezier(0.22, 1, 0.36, 1)" }}
          />
          {allOpen ? "Tout réduire" : "Tout déplier"}
        </button>
      </div>

      {blocs.map((b, bi) => {
        const isOpen = openSet.has(b.code);
        const doneInBloc = b.modules.filter((m) => m.state === "done").length;
        const inProgress = b.modules.filter(
          (m) => m.state === "in-progress",
        ).length;
        const allLocked = b.modules.every((m) => m.state === "locked");

        return (
          <section
            key={b.code}
            className="rounded-3xl border border-navy-100 bg-white overflow-hidden"
            style={{
              animation: `fade-up 0.5s ease-out ${
                sectionIdx * 80 + bi * 100
              }ms both`,
            }}
          >
            <button
              type="button"
              onClick={() => toggle(b.code)}
              aria-expanded={isOpen}
              aria-controls={`ccp-${b.code}-content`}
              className="w-full flex flex-wrap items-center justify-between gap-3 text-left px-4 py-3 md:px-6 md:py-4 hover:bg-ivory transition-colors group"
            >
              <div className="min-w-0 flex items-start gap-3">
                <ChevronDown
                  className={
                    "h-4 w-4 mt-1 text-slate-400 shrink-0 transition-transform " +
                    (isOpen ? "rotate-0" : "-rotate-90") +
                    " group-hover:text-navy-900"
                  }
                  style={{
                    transition: "transform 320ms cubic-bezier(0.22, 1, 0.36, 1)",
                  }}
                />
                <div>
                  <div className="text-[10.5px] font-bold uppercase tracking-[0.18em] text-signal-700">
                    {b.ccpLabel}
                  </div>
                  <h4 className="mt-0.5 font-display text-[16px] font-semibold text-navy-950 tracking-tight">
                    {b.title || "Modules"}
                  </h4>
                </div>
              </div>
              <div className="text-[12px] text-slate-500 inline-flex items-center gap-2 flex-wrap shrink-0">
                <span>
                  <strong className="text-navy-900">{b.modules.length}</strong>{" "}
                  module{b.modules.length > 1 ? "s" : ""}
                </span>
                {doneInBloc > 0 && (
                  <span className="text-emerald-700">
                    · {doneInBloc} terminé{doneInBloc > 1 ? "s" : ""}
                  </span>
                )}
                {inProgress > 0 && (
                  <span className="text-signal-700">
                    · {inProgress} en cours
                  </span>
                )}
                {allLocked && (
                  <span className="inline-flex items-center gap-1 text-slate-400">
                    <Lock className="h-3 w-3" />
                    Verrouillé
                  </span>
                )}
              </div>
            </button>

            {/* Wrapper d'animation : grid-template-rows 0fr ↔ 1fr.
                Technique moderne (Chrome 117+/Safari 17+/Firefox 122+)
                pour animer la hauteur exacte du contenu sans JS. */}
            <div
              id={`ccp-${b.code}-content`}
              className="ccp-collapsible"
              data-open={isOpen ? "true" : "false"}
              aria-hidden={!isOpen}
            >
              <div className="ccp-collapsible-inner">
                <div className="px-4 pb-4 md:px-6 md:pb-5 pt-1">
                  <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 md:gap-5">
                    {b.modules.map((m, i) => (
                      <div
                        key={m.id}
                        style={{
                          animation: isOpen
                            ? `fade-up 0.45s ease-out ${i * 40}ms both`
                            : undefined,
                        }}
                      >
                        <ModuleCard module={m} />
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          </section>
        );
      })}
    </div>
  );
}
