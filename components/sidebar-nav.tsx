"use client";
import * as React from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";
import { ChevronDown } from "lucide-react";
import type { NavGroup } from "./nav-groups";

const STORAGE_KEY = "gotrm.nav.collapsed.v1";

interface Props {
  groups: NavGroup[];
  variant?: "light" | "dark";
}

function isActive(pathname: string, href: string, exact?: boolean) {
  if (exact) return pathname === href;
  return pathname === href || pathname.startsWith(href + "/");
}

export function SidebarNav({ groups, variant = "light" }: Props) {
  const pathname = usePathname();
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

  return (
    <nav className="flex-1 px-3 py-4 space-y-3 overflow-y-auto">
      {groups.map((g) => {
        // Auto-ouvrir un groupe qui contient la route active
        const hasActive = g.items.some((i) => isActive(pathname, i.href, i.exact));
        const isOpen = !(collapsed[g.label] ?? false) || hasActive;
        return (
          <div key={g.label}>
            <button
              type="button"
              onClick={() => toggle(g.label)}
              className={cn(
                "w-full flex items-center justify-between px-3 py-1.5 text-[10px] font-semibold uppercase tracking-[0.14em] rounded-lg transition-colors",
                dark
                  ? "text-white/45 hover:text-white/70"
                  : "text-slate-400 hover:text-slate-600"
              )}
            >
              <span>{g.label}</span>
              <ChevronDown
                className={cn(
                  "h-3 w-3 transition-transform",
                  !isOpen && "-rotate-90"
                )}
              />
            </button>
            {isOpen && (
              <div className="mt-1 space-y-0.5">
                {g.items.map((item) => {
                  const active = isActive(pathname, item.href, item.exact);
                  return (
                    <Link
                      key={item.href}
                      href={item.href}
                      className={cn(
                        "relative flex items-center gap-3 px-3 py-2 rounded-xl text-sm font-medium transition-colors",
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
                        className={cn(
                          "w-4 h-4",
                          active && (dark ? "text-gold-400" : "text-gold-400")
                        )}
                      />
                      <span className="truncate">{item.label}</span>
                      {active && (
                        <span className="absolute right-3 h-1.5 w-1.5 rounded-full bg-gold-400" />
                      )}
                    </Link>
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
