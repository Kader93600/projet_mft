"use client";

import { useRef, useState, useEffect, type ReactNode } from "react";
import { LayoutDashboard, Globe, GraduationCap, Banknote } from "lucide-react";

type TabId = "overview" | "vitrine" | "pedagogie" | "business";

const TABS: { id: TabId; label: string; Icon: any }[] = [
  { id: "overview", label: "Vue d'ensemble", Icon: LayoutDashboard },
  { id: "vitrine", label: "Vitrine", Icon: Globe },
  { id: "pedagogie", label: "Pédagogie", Icon: GraduationCap },
  { id: "business", label: "Business", Icon: Banknote },
];

/**
 * Onglets thématiques du dashboard analytics.
 *
 * Chaque panneau est rendu côté serveur puis passé en prop (ReactNode) : le
 * basculement est instantané (état client, aucune requête réseau). Seul le
 * panneau actif est monté → les graphiques recharts se mesurent correctement.
 *
 * L'indicateur coulissant est piloté en CSS (transform + width) pour rester
 * fluide et interruptible, sans dépendance d'animation externe.
 */
export function AnalyticsTabs({
  overview,
  vitrine,
  pedagogie,
  business,
  filter,
}: {
  overview: ReactNode;
  vitrine: ReactNode;
  pedagogie: ReactNode;
  business: ReactNode;
  filter?: ReactNode;
}) {
  const [active, setActive] = useState<TabId>("overview");
  const panels: Record<TabId, ReactNode> = {
    overview,
    vitrine,
    pedagogie,
    business,
  };

  // Indicateur coulissant : mesure du bouton actif.
  const btnRefs = useRef<Record<string, HTMLButtonElement | null>>({});
  const [ind, setInd] = useState<{ left: number; width: number }>({
    left: 0,
    width: 0,
  });

  useEffect(() => {
    function measure() {
      const btn = btnRefs.current[active];
      if (btn) setInd({ left: btn.offsetLeft, width: btn.offsetWidth });
    }
    measure();
    window.addEventListener("resize", measure);
    return () => window.removeEventListener("resize", measure);
  }, [active]);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <div
          role="tablist"
          aria-label="Sections du tableau de bord"
          className="relative inline-flex rounded-xl bg-ivory dark:bg-white/5 border border-navy-100 dark:border-white/10 p-1 gap-0.5"
        >
          {/* Pilule coulissante (sous le texte) */}
          <span
            aria-hidden
            className="absolute top-1 bottom-1 left-0 rounded-lg bg-white dark:bg-white/10 shadow-soft transition-[transform,width,opacity] duration-300 ease-premium motion-reduce:transition-none"
            style={{
              transform: `translateX(${ind.left}px)`,
              width: ind.width ? `${ind.width}px` : 0,
              opacity: ind.width ? 1 : 0,
            }}
          />
          {TABS.map((t) => {
            const isActive = t.id === active;
            return (
              <button
                key={t.id}
                ref={(el) => {
                  btnRefs.current[t.id] = el;
                }}
                role="tab"
                type="button"
                aria-selected={isActive}
                onClick={() => setActive(t.id)}
                className={
                  "relative z-10 inline-flex items-center gap-2 px-3 sm:px-4 py-2 rounded-lg text-[13px] font-semibold transition-colors duration-200 " +
                  (isActive
                    ? "text-navy-950 dark:text-white"
                    : "text-slate-500 dark:text-white/60 hover:text-navy-900 dark:hover:text-white")
                }
              >
                <t.Icon className="h-4 w-4 shrink-0" />
                <span>{t.label}</span>
              </button>
            );
          })}
        </div>
        {filter && <div className="shrink-0">{filter}</div>}
      </div>

      <div
        key={active}
        role="tabpanel"
        className="space-y-6 motion-safe:animate-fade-up"
      >
        {panels[active]}
      </div>
    </div>
  );
}
