"use client";
import * as React from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useTranslations } from "next-intl";
import { cn } from "@/lib/utils";
import { ChevronDown } from "lucide-react";
import type { NavGroup, NavItem } from "./nav-groups";

const STORAGE_KEY = "gotrm.nav.collapsed.v1";

interface Props {
  groups: NavGroup[];
  variant?: "light" | "dark";
  /**
   * Pastilles de notification par `href`. Une valeur > 0 affiche une
   * pastille discrète à droite de l'item. Idéal pour des compteurs
   * type « emails non lus ». Le rendu reste silencieux à 0.
   */
  badges?: Record<string, number>;
}

function isActive(pathname: string, href: string, exact?: boolean) {
  if (exact) return pathname === href;
  return pathname === href || pathname.startsWith(href + "/");
}

/** Une branche est « active » si l'item ou l'une de ses sous-pages l'est. */
function branchIsActive(pathname: string, item: NavItem) {
  if (isActive(pathname, item.href, item.exact)) return true;
  return (item.children ?? []).some((c) => isActive(pathname, c.href, c.exact));
}

/**
 * Navigation latérale à 3 niveaux :
 *  1. Sections (Pilotage, Personnes…) — ouvertes par défaut, repliables une à
 *     une (plusieurs peuvent rester ouvertes ; état mémorisé en localStorage).
 *  2. Pages — toujours visibles dans leur section.
 *  3. Sous-pages (children) — affichées en retrait sous leur page parente, et
 *     uniquement quand on se trouve sur cette branche (ex. « Signatures » sous
 *     « Vue d'ensemble »). Déroulé animé via grid-template-rows 0fr → 1fr +
 *     fondu (courbe ease-premium, neutralisé sous prefers-reduced-motion).
 */
export function SidebarNav({ groups, variant = "light", badges }: Props) {
  const pathname = usePathname();
  const t = useTranslations();
  const [collapsed, setCollapsed] = React.useState<Record<string, boolean>>({});

  React.useEffect(() => {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (raw) setCollapsed(JSON.parse(raw));
    } catch {}
  }, []);

  function toggle(label: string) {
    setCollapsed((c) => {
      const next = { ...c, [label]: !c[label] };
      try {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
      } catch {}
      return next;
    });
  }

  const dark = variant === "dark";
  const ringFocus = dark
    ? "focus-visible:ring-white/30"
    : "focus-visible:ring-navy-600/30";

  return (
    <nav className="flex-1 px-3 py-4 space-y-3 overflow-y-auto">
      {groups.map((g) => {
        // Une section reste ouverte par défaut ; elle est forcée ouverte si
        // elle contient la route active (ou une sous-page active).
        const hasActive = g.items.some((i) => branchIsActive(pathname, i));
        const isOpen = !(collapsed[g.labelKey] ?? false) || hasActive;
        const groupLabel = t(g.labelKey);
        return (
          <div key={g.labelKey}>
            <button
              type="button"
              onClick={() => toggle(g.labelKey)}
              aria-expanded={isOpen}
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
            {isOpen && (
              <div className="mt-1 space-y-0.5">
                {g.items.map((item) => {
                  const active = isActive(pathname, item.href, item.exact);
                  const kids = item.children ?? [];
                  const branchActive = branchIsActive(pathname, item);
                  return (
                    <div key={item.href}>
                      <Link
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
                        {(() => {
                          const count = badges?.[item.href] ?? 0;
                          if (count > 0) {
                            return (
                              <span
                                aria-label={`${count} nouveau${count > 1 ? "x" : ""}`}
                                className={cn(
                                  "ml-auto inline-flex h-[18px] min-w-[18px] items-center justify-center rounded-full px-1.5 text-[10px] font-bold tabular-nums motion-safe:animate-[fade-in_180ms_ease-out]",
                                  "bg-signal-500 text-night-900 shadow-[0_0_0_3px_rgba(159,226,32,0.12)]"
                                )}
                              >
                                {count > 99 ? "99+" : count}
                              </span>
                            );
                          }
                          if (active) {
                            return (
                              <span className="ml-auto h-1.5 w-1.5 rounded-full bg-gold-400" />
                            );
                          }
                          return null;
                        })()}
                      </Link>

                      {/* Sous-pages contextuelles : visibles uniquement sur la
                          branche active, déroulé animé (grid-rows 0fr→1fr). */}
                      {kids.length > 0 && (
                        <div
                          className={cn(
                            "grid transition-[grid-template-rows] duration-300 ease-premium motion-reduce:transition-none",
                            branchActive ? "grid-rows-[1fr]" : "grid-rows-[0fr]"
                          )}
                        >
                          <div
                            className={cn(
                              "min-h-0 overflow-hidden transition-opacity duration-200 ease-premium motion-reduce:transition-none",
                              branchActive ? "opacity-100" : "opacity-0"
                            )}
                            {...(branchActive ? {} : ({ inert: "" } as any))}
                          >
                            <div
                              className={cn(
                                "mt-0.5 ml-[1.375rem] space-y-0.5 border-l pl-3",
                                dark ? "border-white/10" : "border-navy-100"
                              )}
                            >
                              {kids.map((child) => {
                                const cActive = isActive(
                                  pathname,
                                  child.href,
                                  child.exact
                                );
                                return (
                                  <Link
                                    key={child.href}
                                    href={child.href}
                                    aria-current={cActive ? "page" : undefined}
                                    className={cn(
                                      "relative flex items-center gap-2.5 px-3 py-1.5 rounded-lg text-[13px] transition-colors",
                                      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset",
                                      ringFocus,
                                      dark
                                        ? cActive
                                          ? "bg-white/10 text-white font-medium"
                                          : "text-white/55 hover:bg-white/5 hover:text-white"
                                        : cActive
                                          ? "bg-navy-100 text-navy-900 font-medium"
                                          : "text-slate-500 hover:bg-navy-50 hover:text-navy-900"
                                    )}
                                  >
                                    <child.icon className="w-3.5 h-3.5 shrink-0 opacity-80" />
                                    <span className="truncate">
                                      {t(child.labelKey)}
                                    </span>
                                  </Link>
                                );
                              })}
                            </div>
                          </div>
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        );
      })}
    </nav>
  );
}
