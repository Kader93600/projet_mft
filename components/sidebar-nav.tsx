"use client";
import * as React from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useTranslations } from "next-intl";
import { cn } from "@/lib/utils";
import { ChevronDown } from "lucide-react";
import type { NavGroup } from "./nav-groups";

interface Props {
  groups: NavGroup[];
  variant?: "light" | "dark";
}

function isActive(pathname: string, href: string, exact?: boolean) {
  if (exact) return pathname === href;
  return pathname === href || pathname.startsWith(href + "/");
}

/**
 * Navigation latérale en accordéon exclusif : une seule section est ouverte à
 * la fois. La section qui contient la route active s'ouvre automatiquement et
 * les autres se replient — y compris à chaque navigation. Le déroulé / repli
 * est animé via `grid-template-rows` (0fr → 1fr), sans hauteur magique ni
 * mesure JS, doublé d'un fondu d'opacité sur le contenu (esprit Emil :
 * courbe ease-out marquée, < 300 ms, désactivé sous prefers-reduced-motion).
 */
export function SidebarNav({ groups, variant = "light" }: Props) {
  const pathname = usePathname();
  const t = useTranslations();

  // Clé de la section contenant la route active (sinon la 1ʳᵉ section).
  const activeGroupKey = React.useMemo(() => {
    const g = groups.find((gr) =>
      gr.items.some((i) => isActive(pathname, i.href, i.exact))
    );
    return g?.labelKey ?? groups[0]?.labelKey ?? null;
  }, [groups, pathname]);

  const [openKey, setOpenKey] = React.useState<string | null>(activeGroupKey);

  // À chaque navigation, la section de la page courante s'ouvre et les autres
  // se replient.
  React.useEffect(() => {
    setOpenKey(activeGroupKey);
  }, [activeGroupKey]);

  function toggle(label: string) {
    setOpenKey((cur) => (cur === label ? null : label));
  }

  const dark = variant === "dark";
  const ringFocus = dark
    ? "focus-visible:ring-white/30"
    : "focus-visible:ring-navy-600/30";

  return (
    <nav className="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
      {groups.map((g) => {
        const isOpen = openKey === g.labelKey;
        const groupLabel = t(g.labelKey);
        const panelId = `nav-panel-${g.labelKey.replace(/[^a-zA-Z0-9]+/g, "-")}`;
        return (
          <div key={g.labelKey}>
            <button
              type="button"
              onClick={() => toggle(g.labelKey)}
              aria-expanded={isOpen}
              aria-controls={panelId}
              className={cn(
                "w-full flex items-center justify-between px-3 py-1.5 text-[10px] font-semibold uppercase tracking-[0.14em] rounded-lg transition-colors",
                "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset",
                ringFocus,
                dark
                  ? "text-white/45 hover:text-white/70"
                  : "text-slate-400 hover:text-slate-600"
              )}
            >
              <span>{groupLabel}</span>
              <ChevronDown
                className={cn(
                  "h-3 w-3 transition-transform duration-300 ease-premium motion-reduce:transition-none",
                  !isOpen && "-rotate-90"
                )}
              />
            </button>

            {/* Panneau accordéon : grid-template-rows 0fr → 1fr. Le wrapper
                interne (min-h-0 + overflow-hidden) permet le repli total. */}
            <div
              id={panelId}
              className={cn(
                "grid transition-[grid-template-rows] duration-300 ease-premium motion-reduce:transition-none",
                isOpen ? "grid-rows-[1fr]" : "grid-rows-[0fr]"
              )}
            >
              <div
                className={cn(
                  "min-h-0 overflow-hidden transition-opacity duration-200 ease-premium motion-reduce:transition-none",
                  isOpen ? "opacity-100" : "opacity-0"
                )}
                {...(isOpen ? {} : ({ inert: "" } as any))}
              >
                <div className="mt-1 space-y-0.5 pb-1">
                  {g.items.map((item) => {
                    const active = isActive(pathname, item.href, item.exact);
                    return (
                      <Link
                        key={item.href}
                        href={item.href}
                        aria-current={active ? "page" : undefined}
                        className={cn(
                          "relative flex items-center gap-3 px-3 py-2 rounded-xl text-sm font-medium transition-colors",
                          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset",
                          ringFocus,
                          dark
                            ? active
                              ? "bg-white/10 text-white shadow-soft"
                              : "text-white/65 hover:bg-white/5 hover:text-white"
                            : active
                              ? "bg-navy-900 text-white shadow-soft"
                              : "text-slate-600 hover:bg-navy-50 hover:text-navy-900"
                        )}
                      >
                        <item.icon
                          className={cn("w-4 h-4", active && "text-gold-400")}
                        />
                        <span className="truncate">{t(item.labelKey)}</span>
                        {active && (
                          <span className="absolute right-3 h-1.5 w-1.5 rounded-full bg-gold-400" />
                        )}
                      </Link>
                    );
                  })}
                </div>
              </div>
            </div>
          </div>
        );
      })}
    </nav>
  );
}
