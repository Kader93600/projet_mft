"use client";
import * as React from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";
import { Menu, X } from "lucide-react";
import type { NavGroup } from "./nav-groups";

interface Props {
  groups: NavGroup[];
  label?: string;
}

export function MobileNavSheet({ groups, label = "Plus" }: Props) {
  const [open, setOpen] = React.useState(false);
  const pathname = usePathname();

  React.useEffect(() => {
    setOpen(false);
  }, [pathname]);

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        className="flex flex-col items-center gap-1 min-w-[60px] px-2 py-1 text-[10px] font-semibold tracking-wide text-slate-500"
        aria-label="Ouvrir le menu"
      >
        <Menu className="w-5 h-5" />
        {label}
      </button>

      {open && (
        <div className="fixed inset-0 z-50 md:hidden">
          <div
            className="absolute inset-0 bg-navy-950/50 backdrop-blur-sm"
            onClick={() => setOpen(false)}
          />
          <div className="absolute inset-x-0 bottom-0 max-h-[85vh] bg-white rounded-t-3xl shadow-float overflow-y-auto">
            <div className="sticky top-0 bg-white border-b border-navy-100 px-5 py-4 flex items-center justify-between">
              <div className="font-display text-lg font-semibold text-navy-950">
                Navigation
              </div>
              <button
                type="button"
                onClick={() => setOpen(false)}
                className="h-9 w-9 rounded-lg hover:bg-navy-50 flex items-center justify-center"
                aria-label="Fermer"
              >
                <X className="h-4 w-4" />
              </button>
            </div>
            <div className="p-5 space-y-5">
              {groups.map((g) => (
                <div key={g.label}>
                  <div className="text-[10px] font-semibold uppercase tracking-[0.14em] text-slate-400 mb-2">
                    {g.label}
                  </div>
                  <div className="grid grid-cols-2 gap-2">
                    {g.items.map((it) => {
                      const active =
                        pathname === it.href ||
                        pathname.startsWith(it.href + "/");
                      return (
                        <Link
                          key={it.href}
                          href={it.href}
                          className={cn(
                            "flex items-center gap-2 px-3 py-3 rounded-xl text-sm font-medium border transition",
                            active
                              ? "bg-navy-900 text-white border-navy-900"
                              : "bg-white text-navy-900 border-navy-100 hover:bg-navy-50"
                          )}
                        >
                          <it.icon className="w-4 h-4 shrink-0" />
                          <span className="truncate">{it.label}</span>
                        </Link>
                      );
                    })}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}
    </>
  );
}
